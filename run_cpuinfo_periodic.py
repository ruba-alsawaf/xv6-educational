#!/usr/bin/env python3
"""
Script to run cpuinfo command periodically in QEMU and collect the output
"""
import json
import sqlite3
import time
import uuid
import re
import subprocess
import sys
from pathlib import Path
from datetime import datetime

LOG_PATH = "qemu.log"
DB_PATH = "events.db"
SESSION_ID = str(uuid.uuid4())

def clean_payload(payload: str) -> str:
    return re.sub(r'[\x00-\x1f\x7f-\x9f]', '', payload)

def parse_cpu_info(line: str) -> dict | None:
    """Parse CPU info JSON from log line"""
    # Look for CPU {...} pattern - use balanced braces
    if 'CPU' not in line or '{' not in line:
        return None
    
    # Find the position of 'CPU'
    cpu_pos = line.find('CPU')
    if cpu_pos == -1:
        return None
    
    # Find the opening brace after CPU
    brace_start = line.find('{', cpu_pos)
    if brace_start == -1:
        return None
    
    # Match balanced braces
    depth = 0
    end = -1
    for i in range(brace_start, len(line)):
        if line[i] == '{':
            depth += 1
        elif line[i] == '}':
            depth -= 1
            if depth == 0:
                end = i
                break
    
    if end == -1:
        return None
    
    try:
        payload = line[brace_start:end+1]
        cleaned = clean_payload(payload)
        return json.loads(cleaned)
    except:
        return None

def parse_proc_stats(line: str) -> dict | None:
    """Parse PROC stats JSON from log line"""
    # Look for PROC {...} pattern - use balanced braces
    if 'PROC' not in line or '{' not in line:
        return None
    
    # Find the position of 'PROC'
    proc_pos = line.find('PROC')
    if proc_pos == -1:
        return None
    
    # Find the opening brace after PROC
    brace_start = line.find('{', proc_pos)
    if brace_start == -1:
        return None
    
    # Match balanced braces
    depth = 0
    end = -1
    for i in range(brace_start, len(line)):
        if line[i] == '{':
            depth += 1
        elif line[i] == '}':
            depth -= 1
            if depth == 0:
                end = i
                break
    
    if end == -1:
        return None
    
    try:
        payload = line[brace_start:end+1]
        cleaned = clean_payload(payload)
        return json.loads(cleaned)
    except:
        return None

def insert_cpu_info(cur: sqlite3.Cursor, event: dict) -> None:
    """Insert CPU info into database"""
    for cpu_entry in event.get("cpus", []):
        cur.execute("""
        INSERT INTO cpu_info
        (session_id, cpu_id, cpu, active, current_pid, current_name, current_process, current_state, last_pid, last_state, busy_percent, active_ticks, timeline)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        """, (
            SESSION_ID,
            cpu_entry.get("cpu_id"),
            cpu_entry.get("cpu"),
            cpu_entry.get("active"),
            cpu_entry.get("current_pid"),
            cpu_entry.get("current_name"),
            cpu_entry.get("current_process"),
            cpu_entry.get("current_state"),
            cpu_entry.get("last_pid"),
            cpu_entry.get("last_state"),
            cpu_entry.get("busy_percent"),
            cpu_entry.get("active_ticks"),
            json.dumps(cpu_entry.get("timeline", []))
        ))

def insert_proc_stats(cur: sqlite3.Cursor, event: dict) -> None:
    """Insert PROC stats into database"""
    system = event.get("system", event)
    cur.execute("""
    INSERT INTO proc_stats
    (session_id, total_created, total_exited, total_cpu_usage,
     current_unused, current_used, current_sleeping, current_runnable, current_running, current_zombie,
     unique_unused, unique_used, unique_sleeping, unique_runnable, unique_running, unique_zombie,
     ever_running, ever_sleeping, ever_zombie)
    VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    """, (
        SESSION_ID,
        system.get("total_created"),
        system.get("total_exited"),
        system.get("total_cpu_usage"),
        system.get("current", {}).get("UNUSED", 0),
        system.get("current", {}).get("USED", 0),
        system.get("current", {}).get("SLEEPING", 0),
        system.get("current", {}).get("RUNNABLE", 0),
        system.get("current", {}).get("RUNNING", 0),
        system.get("current", {}).get("ZOMBIE", 0),
        system.get("unique", {}).get("UNUSED", 0),
        system.get("unique", {}).get("USED", 0),
        system.get("unique", {}).get("SLEEPING", 0),
        system.get("unique", {}).get("RUNNABLE", 0),
        system.get("unique", {}).get("RUNNING", 0),
        system.get("unique", {}).get("ZOMBIE", 0),
        system.get("ever_running", 0),
        system.get("ever_sleeping", 0),
        system.get("ever_zombie", 0)
    ))

def has_column(cur: sqlite3.Cursor, table: str, column: str) -> bool:
    cur.execute(f"PRAGMA table_info({table})")
    return any(row[1] == column for row in cur.fetchall())


def ensure_schema(cur: sqlite3.Cursor) -> None:
    """Create database schema if not exists"""
    cur.execute("""
    CREATE TABLE IF NOT EXISTS cpu_info(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        session_id TEXT NOT NULL,
        cpu_id TEXT,
        cpu INTEGER,
        active INTEGER,
        current_pid INTEGER,
        current_name TEXT,
        current_process TEXT,
        current_state TEXT,
        last_pid INTEGER,
        last_state TEXT,
        busy_percent INTEGER,
        active_ticks INTEGER,
        timeline TEXT,
        timestamp DATETIME DEFAULT CURRENT_TIMESTAMP
    )
    """)

    cur.execute("""
    CREATE TABLE IF NOT EXISTS proc_stats(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        session_id TEXT NOT NULL,
        total_created INTEGER,
        total_exited INTEGER,
        total_cpu_usage INTEGER,
        current_unused INTEGER,
        current_used INTEGER,
        current_sleeping INTEGER,
        current_runnable INTEGER,
        current_running INTEGER,
        current_zombie INTEGER,
        unique_unused INTEGER,
        unique_used INTEGER,
        unique_sleeping INTEGER,
        unique_runnable INTEGER,
        unique_running INTEGER,
        unique_zombie INTEGER,
        ever_running INTEGER,
        ever_sleeping INTEGER,
        ever_zombie INTEGER,
        timestamp DATETIME DEFAULT CURRENT_TIMESTAMP
    )
    """)

    cur.execute("""
    CREATE INDEX IF NOT EXISTS idx_cpu_info_session_timestamp
    ON cpu_info(session_id, timestamp)
    """)

    cur.execute("""
    CREATE INDEX IF NOT EXISTS idx_proc_stats_session_timestamp
    ON proc_stats(session_id, timestamp)
    """)

    if not has_column(cur, "cpu_info", "cpu_id"):
        cur.execute("ALTER TABLE cpu_info ADD COLUMN cpu_id TEXT")
    if not has_column(cur, "cpu_info", "current_name"):
        cur.execute("ALTER TABLE cpu_info ADD COLUMN current_name TEXT")
    if not has_column(cur, "cpu_info", "current_process"):
        cur.execute("ALTER TABLE cpu_info ADD COLUMN current_process TEXT")
    if not has_column(cur, "cpu_info", "timeline"):
        cur.execute("ALTER TABLE cpu_info ADD COLUMN timeline TEXT")

    if not has_column(cur, "proc_stats", "total_cpu_usage"):
        cur.execute("ALTER TABLE proc_stats ADD COLUMN total_cpu_usage INTEGER")
    if not has_column(cur, "proc_stats", "ever_running"):
        cur.execute("ALTER TABLE proc_stats ADD COLUMN ever_running INTEGER")
    if not has_column(cur, "proc_stats", "ever_sleeping"):
        cur.execute("ALTER TABLE proc_stats ADD COLUMN ever_sleeping INTEGER")
    if not has_column(cur, "proc_stats", "ever_zombie"):
        cur.execute("ALTER TABLE proc_stats ADD COLUMN ever_zombie INTEGER")

def main() -> None:
    log_file = Path(LOG_PATH)
    if not log_file.exists():
        print(f"[ERR] Log file not found: {LOG_PATH}")
        return

    con = sqlite3.connect(DB_PATH, timeout=10.0)
    cur = con.cursor()
    ensure_schema(cur)
    con.commit()

    last_pos = 0
    print(f"[INFO] Started CPU Info periodic reader. Session: {SESSION_ID}")
    print(f"[INFO] Log: {LOG_PATH}")
    print(f"[INFO] DB : {DB_PATH}")
    print(f"[INFO] Running cpuinfo every 5 seconds...")

    try:
        while True:
            try:
                with open(LOG_PATH, "r", encoding="utf-8", errors="ignore") as f:
                    f.seek(last_pos)
                    lines = f.readlines()
                    last_pos = f.tell()

                    for line in lines:
                        cpu_event = parse_cpu_info(line)
                        if cpu_event:
                            try:
                                insert_cpu_info(cur, cpu_event)
                                insert_proc_stats(cur, cpu_event)
                                con.commit()
                                print(f"[OK] Saved CPU info and system stats")
                            except sqlite3.Error as e:
                                print(f"[ERR] SQLite failed: {e}")
                        else:
                            proc_event = parse_proc_stats(line)
                            if proc_event:
                                try:
                                    insert_proc_stats(cur, proc_event)
                                    con.commit()
                                    print(f"[OK] Saved PROC stats: created={proc_event.get('total_created')}")
                                except sqlite3.Error as e:
                                    print(f"[ERR] SQLite failed: {e}")

            except IOError:
                pass
            
            time.sleep(5)  # Wait 5 seconds before checking again

    except KeyboardInterrupt:
        print("\n[INFO] Shutting down...")
        con.close()
        sys.exit(0)

if __name__ == "__main__":
    main()
