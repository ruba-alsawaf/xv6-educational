#!/usr/bin/env python3
import json
import sqlite3
import time
import uuid
import re
from pathlib import Path

LOG_PATH = "qemu.log"
DB_PATH = "events.db"
SESSION_ID = str(uuid.uuid4())

def extract_json(line: str, marker: str) -> dict | None:
    """Extract JSON object from line starting with marker"""
    if marker not in line or '{' not in line:
        return None
    
    pos = line.find(marker)
    brace_start = line.find('{', pos)
    if brace_start == -1:
        return None
    
    depth = 0
    for i in range(brace_start, len(line)):
        if line[i] == '{': depth += 1
        elif line[i] == '}': 
            depth -= 1
            if depth == 0:
                try:
                    payload = re.sub(r'[\x00-\x1f\x7f-\x9f]', '', line[brace_start:i+1])
                    return json.loads(payload)
                except:
                    return None
    return None

def insert_cpu_info(cur: sqlite3.Cursor, event: dict) -> None:
    """Insert CPU info into database"""
    system = event.get("system", {})
    for cpu_data in event.get("cpus", []):
        cur.execute("""INSERT INTO cpu_metrics
        (session_id, cpu_id, active, current_pid, proc_name, current_state, 
         context_eip, context_esp, busy_percent, total_created, total_exited, ever_running, ever_sleeping, ever_zombie)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)""", (
            SESSION_ID, cpu_data.get("cpu_id"), cpu_data.get("active", 0),
            cpu_data.get("current_pid", 0), cpu_data.get("proc_name", ""),
            cpu_data.get("current_state", ""), cpu_data.get("context_eip", ""),
            cpu_data.get("context_esp", ""), cpu_data.get("busy_percent", 0),
            system.get("total_created", 0), system.get("total_exited", 0),
            system.get("ever_running", 0), system.get("ever_sleeping", 0),
            system.get("ever_zombie", 0)
        ))

def insert_proc_stats(cur: sqlite3.Cursor, event: dict) -> None:
    """Insert PROC stats into database"""
    cur.execute("""INSERT INTO proc_stats
    (session_id, total_created, total_exited, current_unused, current_used, 
     current_sleeping, current_runnable, current_running, current_zombie,
     unique_unused, unique_used, unique_sleeping, unique_runnable, unique_running, unique_zombie)
    VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)""", (
        SESSION_ID, event.get("total_created"), event.get("total_exited"),
        event.get("current", {}).get("UNUSED", 0), event.get("current", {}).get("USED", 0),
        event.get("current", {}).get("SLEEPING", 0), event.get("current", {}).get("RUNNABLE", 0),
        event.get("current", {}).get("RUNNING", 0), event.get("current", {}).get("ZOMBIE", 0),
        event.get("unique", {}).get("UNUSED", 0), event.get("unique", {}).get("USED", 0),
        event.get("unique", {}).get("SLEEPING", 0), event.get("unique", {}).get("RUNNABLE", 0),
        event.get("unique", {}).get("RUNNING", 0), event.get("unique", {}).get("ZOMBIE", 0)
    ))

def ensure_schema(con: sqlite3.Connection) -> None:
    """Create database schema if not exists"""
    con.execute("""CREATE TABLE IF NOT EXISTS cpu_metrics(
        id INTEGER PRIMARY KEY, session_id TEXT, cpu_id TEXT, active INTEGER,
        current_pid INTEGER, proc_name TEXT, current_state TEXT,
        context_eip TEXT, context_esp TEXT, busy_percent INTEGER,
        total_created INTEGER, total_exited INTEGER, ever_running INTEGER,
        ever_sleeping INTEGER, ever_zombie INTEGER, timestamp DATETIME DEFAULT CURRENT_TIMESTAMP
    )""")
    
    con.execute("""CREATE TABLE IF NOT EXISTS proc_stats(
        id INTEGER PRIMARY KEY, session_id TEXT, total_created INTEGER, total_exited INTEGER,
        current_unused INTEGER, current_used INTEGER, current_sleeping INTEGER,
        current_runnable INTEGER, current_running INTEGER, current_zombie INTEGER,
        unique_unused INTEGER, unique_used INTEGER, unique_sleeping INTEGER,
        unique_runnable INTEGER, unique_running INTEGER, unique_zombie INTEGER,
        timestamp DATETIME DEFAULT CURRENT_TIMESTAMP
    )""")
    
    con.execute("CREATE INDEX IF NOT EXISTS idx_cpu_metrics_session ON cpu_metrics(session_id)")
    con.execute("CREATE INDEX IF NOT EXISTS idx_proc_stats_session ON proc_stats(session_id)")
    con.commit()

def main():
    if not Path(LOG_PATH).exists():
        return
    
    con = sqlite3.connect(DB_PATH, timeout=30.0, check_same_thread=False)
    con.execute("PRAGMA journal_mode=WAL")
    con.execute("PRAGMA synchronous=NORMAL")
    con.execute("PRAGMA temp_store=MEMORY")
    cur = con.cursor()
    ensure_schema(con)
    
    last_pos = 0
    cpu_count = 0
    proc_count = 0
    
    try:
        while True:
            try:
                with open(LOG_PATH, "r", encoding="utf-8", errors="ignore") as f:
                    f.seek(last_pos)
                    for line in f:
                        cpu_event = extract_json(line, "CPU")
                        if cpu_event:
                            insert_cpu_info(cur, cpu_event)
                            cpu_count += len(cpu_event.get("cpus", []))
                        
                        proc_event = extract_json(line, "PROC")
                        if proc_event:
                            insert_proc_stats(cur, proc_event)
                            proc_count += 1
                    
                    last_pos = f.tell()
                    if cpu_count > 0 or proc_count > 0:
                        con.commit()
                        print(f"✓ Saved: {cpu_count} CPU records, {proc_count} PROC records")
                        cpu_count = 0
                        proc_count = 0
            except IOError:
                pass
            
            time.sleep(5)
    except KeyboardInterrupt:
        con.commit()
        con.close()

if __name__ == "__main__":
    main()
