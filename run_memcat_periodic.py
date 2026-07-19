#!/usr/bin/env python3
"""
Script to run memcat periodically in QEMU and save its output into events.db
"""
import re
import sqlite3
import time
import uuid
import sys
from pathlib import Path

LOG_PATH = "qemu.log"
DB_PATH = "events.db"
SESSION_ID = str(uuid.uuid4())

MEMCAT_RE = re.compile(
    r"#\d+\s+seq=(?P<seq>\d+)\s+tick=(?P<tick>\d+)\s+cpu=(?P<cpu>-?\d+)\s+pid=(?P<pid>-?\d+)"
    r"\s+type=(?P<type>\S+)\s+src=(?P<src>\S+)\s+va=(?P<va>[\da-fA-Fx]+)\s+pa=(?P<pa>[\da-fA-Fx]+)"
    r"\s+perm=(?P<perm>[^\s]*)\s+kind=(?P<kind>\S+)\s+name=(?P<name>\S+)\s+old=(?P<old>[\da-fA-Fx]+)\s+new=(?P<new>[\da-fA-Fx]+)"
)


def parse_int(value: str) -> int | None:
    try:
        return int(value, 0)
    except ValueError:
        return None


def parse_mem_event(line: str) -> dict | None:
    m = MEMCAT_RE.search(line)
    if not m:
        return None

    old_val = parse_int(m.group("old"))
    new_val = parse_int(m.group("new"))
    va_val = parse_int(m.group("va"))
    pa_val = parse_int(m.group("pa"))
    perm_val = m.group("perm") if m.group("perm") else None

    return {
        "seq": int(m.group("seq")),
        "tick": int(m.group("tick")),
        "cpu": int(m.group("cpu")),
        "pid": int(m.group("pid")),
        "type": m.group("type"),
        "src": m.group("src"),
        "va": va_val if va_val is not None else 0,
        "pa": pa_val if pa_val is not None else 0,
        "perm": perm_val,
        "kind": m.group("kind"),
        "name": m.group("name"),
        "old": old_val if old_val is not None else 0,
        "new": new_val if new_val is not None else 0,
    }


def insert_mem_event(cur: sqlite3.Cursor, event: dict) -> None:
    cur.execute(
        """
        INSERT INTO mem_events
        (session_id, seq, tick, cpu, pid, type, src, va, pa, perm, kind, name, old, new)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        """,
        (
            SESSION_ID,
            event["seq"],
            event["tick"],
            event["cpu"],
            event["pid"],
            event["type"],
            event["src"],
            event["va"],
            event["pa"],
            event["perm"],
            event["kind"],
            event["name"],
            event["old"],
            event["new"],
        ),
    )


def ensure_schema(cur: sqlite3.Cursor) -> None:
    cur.execute(
        """
        CREATE TABLE IF NOT EXISTS mem_events(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            session_id TEXT NOT NULL,
            seq INTEGER,
            tick INTEGER,
            cpu INTEGER,
            pid INTEGER,
            type TEXT,
            src TEXT,
            va INTEGER,
            pa INTEGER,
            perm TEXT,
            kind TEXT,
            name TEXT,
            old INTEGER,
            new INTEGER,
            timestamp DATETIME DEFAULT CURRENT_TIMESTAMP
        )
        """
    )

    cur.execute(
        """
        CREATE INDEX IF NOT EXISTS idx_mem_events_session_timestamp
        ON mem_events(session_id, timestamp)
        """
    )


def wait_for_log_file(path: Path) -> None:
    while not path.exists():
        print(f"[WAIT] Waiting for {path} to appear...")
        time.sleep(1)


def main() -> None:
    log_file = Path(LOG_PATH)
    print(f"[INFO] Memcat periodic ingestor starting. Session={SESSION_ID}")
    print(f"[INFO] Log file: {LOG_PATH}")
    print(f"[INFO] DB path: {DB_PATH}")

    wait_for_log_file(log_file)

    con = sqlite3.connect(DB_PATH, timeout=10.0)
    cur = con.cursor()
    ensure_schema(cur)
    con.commit()

    last_pos = 0
    print("[INFO] Ready. Parsing memcat lines every 5 seconds...")

    try:
        while True:
            try:
                with open(LOG_PATH, "r", encoding="utf-8", errors="ignore") as f:
                    f.seek(last_pos)
                    lines = f.readlines()
                    last_pos = f.tell()

                    for line in lines:
                        mem_event = parse_mem_event(line)
                        if mem_event:
                            try:
                                insert_mem_event(cur, mem_event)
                                con.commit()
                                print(f"[OK] Saved MEM event seq={mem_event['seq']} pid={mem_event['pid']} type={mem_event['type']}")
                            except sqlite3.Error as e:
                                print(f"[ERR] SQLite failed: {e}")
            except IOError:
                pass

            time.sleep(5)
    except KeyboardInterrupt:
        print("\n[INFO] Shutting down memcat ingestor...")
        con.close()
        sys.exit(0)


if __name__ == "__main__":
    main()
