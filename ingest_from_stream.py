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
READ_CHUNK_SIZE = 4096
SLEEP_WHEN_IDLE = 0.1


def clean_payload(payload: str) -> str:
    return re.sub(r'[\x00-\x1f\x7f-\x9f]', '', payload)


def ensure_schema(cur: sqlite3.Cursor) -> None:
    cur.execute("""
    CREATE TABLE IF NOT EXISTS events(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        session_id TEXT NOT NULL,
        seq INTEGER UNIQUE,
        tick INTEGER,
        cpu INTEGER,
        pid INTEGER,
        name TEXT,
        state INTEGER,
        type TEXT NOT NULL,
        reason INTEGER,
        scheduler TEXT,
        cpus INTEGER,
        time_slice INTEGER
    )
    """)

    cur.execute("""
    CREATE TABLE IF NOT EXISTS fs_events(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        session_id TEXT NOT NULL,
        seq INTEGER,
        tick INTEGER,
        fs_type INTEGER,
        pid INTEGER,
        inum INTEGER,
        blockno INTEGER,
        size INTEGER,
        name TEXT
    )
    """)

    cur.execute("""
    CREATE TABLE IF NOT EXISTS cpu_info(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        session_id TEXT NOT NULL,
        cpu INTEGER,
        active INTEGER,
        current_pid INTEGER,
        current_state TEXT,
        last_pid INTEGER,
        last_state TEXT,
        busy_percent INTEGER,
        active_ticks INTEGER,
        timestamp DATETIME DEFAULT CURRENT_TIMESTAMP
    )
    """)

    cur.execute("""
    CREATE TABLE IF NOT EXISTS proc_stats(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        session_id TEXT NOT NULL,
        total_created INTEGER,
        total_exited INTEGER,
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
        timestamp DATETIME DEFAULT CURRENT_TIMESTAMP
    )
    """)

    cur.execute("""
    CREATE INDEX IF NOT EXISTS idx_events_session_seq
    ON events(session_id, seq)
    """)

    cur.execute("""
    CREATE INDEX IF NOT EXISTS idx_events_type
    ON events(type)
    """)

    cur.execute("""
    CREATE INDEX IF NOT EXISTS idx_fs_events_session_seq
    ON fs_events(session_id, seq)
    """)

    cur.execute("""
    CREATE INDEX IF NOT EXISTS idx_cpu_info_session_cpu
    ON cpu_info(session_id, cpu)
    """)

    cur.execute("""
    CREATE INDEX IF NOT EXISTS idx_proc_stats_session
    ON proc_stats(session_id)
    """)


def extract_event_payloads(line: str) -> list[str]:
    payloads = []
    prefixes = ["EV {", "CPU {", "PROC {"]

    for prefix in prefixes:
        i = 0
        while True:
            start = line.find(prefix, i)
            if start == -1:
                break

            brace_start = line.find("{", start)
            if brace_start == -1:
                break

            depth = 0
            end = -1
            for j in range(brace_start, len(line)):
                if line[j] == "{":
                    depth += 1
                elif line[j] == "}":
                    depth -= 1
                    if depth == 0:
                        end = j
                        break

            if end == -1:
                break

            payloads.append(line[brace_start:end + 1])
            i = end + 1

    return payloads


def insert_fs_event(cur: sqlite3.Cursor, event: dict) -> None:
    cur.execute("""
    INSERT OR IGNORE INTO fs_events
    (session_id, seq, tick, fs_type, pid, inum, blockno, size, name)
    VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
    """, (
        SESSION_ID,
        event.get("seq"),
        event.get("tick"),
        event.get("fs_type", 0),
        event.get("pid", 0),
        event.get("inum", 0),
        event.get("block", 0),
        event.get("size", 0),
        event.get("name", "")
    ))


def insert_general_event(cur: sqlite3.Cursor, event: dict) -> None:
    cur.execute("""
    INSERT OR IGNORE INTO events
    (session_id, seq, tick, cpu, pid, name, state, type, reason, scheduler, cpus, time_slice)
    VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    """, (
        SESSION_ID,
        event.get("seq"),
        event.get("tick"),
        event.get("cpu"),
        event.get("pid"),
        event.get("name", ""),
        event.get("state"),
        event.get("type", ""),
        event.get("reason"),
        event.get("scheduler"),
        event.get("cpus"),
        event.get("time_slice")
    ))


def insert_cpu_info(cur: sqlite3.Cursor, event: dict) -> None:
    cur.execute("""
    INSERT INTO cpu_info
    (session_id, cpu, active, current_pid, current_state, last_pid, last_state, busy_percent, active_ticks)
    VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
    """, (
        SESSION_ID,
        event.get("cpu"),
        event.get("active"),
        event.get("current_pid"),
        event.get("current_state"),
        event.get("last_pid"),
        event.get("last_state"),
        event.get("busy_percent"),
        event.get("active_ticks")
    ))


def insert_proc_stats(cur: sqlite3.Cursor, event: dict) -> None:
    cur.execute("""
    INSERT INTO proc_stats
    (session_id, total_created, total_exited,
     current_unused, current_used, current_sleeping, current_runnable, current_running, current_zombie,
     unique_unused, unique_used, unique_sleeping, unique_runnable, unique_running, unique_zombie)
    VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    """, (
        SESSION_ID,
        event.get("total_created"),
        event.get("total_exited"),
        event.get("current", {}).get("UNUSED", 0),
        event.get("current", {}).get("USED", 0),
        event.get("current", {}).get("SLEEPING", 0),
        event.get("current", {}).get("RUNNABLE", 0),
        event.get("current", {}).get("RUNNING", 0),
        event.get("current", {}).get("ZOMBIE", 0),
        event.get("unique", {}).get("UNUSED", 0),
        event.get("unique", {}).get("USED", 0),
        event.get("unique", {}).get("SLEEPING", 0),
        event.get("unique", {}).get("RUNNABLE", 0),
        event.get("unique", {}).get("RUNNING", 0),
        event.get("unique", {}).get("ZOMBIE", 0)
    ))


def handle_event(cur: sqlite3.Cursor, event: dict) -> None:
    ev_type = event.get("type")

    if ev_type == "FS":
        insert_fs_event(cur, event)
    elif ev_type in ["SCHED_INFO", "ON_CPU", "OFF_CPU"]:
        insert_general_event(cur, event)
    elif "cpu" in event:  # CPU info
        insert_cpu_info(cur, event)
    elif "total_created" in event:  # PROC stats
        insert_proc_stats(cur, event)
    else:
        insert_general_event(cur, event)


def main() -> None:
    log_file = Path(LOG_PATH)
    if not log_file.exists():
        raise FileNotFoundError(f"Log file not found: {LOG_PATH}")

    con = sqlite3.connect(DB_PATH, timeout=10.0)
    cur = con.cursor()
    ensure_schema(cur)
    con.commit()

    pending = ""

    print(f"[INFO] Started ingestor. Session: {SESSION_ID}")
    print(f"[INFO] Log: {LOG_PATH}")
    print(f"[INFO] DB : {DB_PATH}")

    with open(LOG_PATH, "r", encoding="utf-8", errors="ignore") as f:
        while True:
            chunk = f.read(READ_CHUNK_SIZE)
            if not chunk:
                time.sleep(SLEEP_WHEN_IDLE)
                continue

            pending += chunk

            while "\n" in pending:
                line, pending = pending.split("\n", 1)

                payloads = extract_event_payloads(line)
                if not payloads:
                    continue

                for payload in payloads:
                    cleaned = clean_payload(payload)
                    try:
                        event = json.loads(cleaned)
                        handle_event(cur, event)
                        con.commit()
                        print(f"[OK] Saved seq={event.get('seq')} type={event.get('type')}")
                    except json.JSONDecodeError as e:
                        print(f"[ERR] JSON decode failed: {e} | payload={cleaned}")
                    except sqlite3.Error as e:
                        print(f"[ERR] SQLite failed: {e} | event={event if 'event' in locals() else cleaned}")
                    except Exception as e:
                        print(f"[ERR] Unexpected error: {e} | payload={cleaned}")


if __name__ == "__main__":
    main()
