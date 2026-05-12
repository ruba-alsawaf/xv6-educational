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
    r"#\d+\s+seq=(?P<seq>\d+)\s+tick=(?P<ticks>\d+)\s+cpu=(?P<cpu>-?\d+)\s+pid=(?P<pid>-?\d+)"
    r"\s+type=(?P<type>\S+)\s+src=(?P<source>\S+)\s+name=(?P<name>\S+)\s+old=(?P<old>\S+)\s+new=(?P<new>\S+)"
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

    oldsz = parse_int(m.group("old"))
    newsz = parse_int(m.group("new"))

    return {
        "seq": int(m.group("seq")),
        "ticks": int(m.group("ticks")),
        "cpu": int(m.group("cpu")),
        "pid": int(m.group("pid")),
        "type": m.group("type"),
        "source": m.group("source"),
        "name": m.group("name"),
        "oldsz": oldsz if oldsz is not None else 0,
        "newsz": newsz if newsz is not None else 0,
    }


def insert_mem_event(cur: sqlite3.Cursor, event: dict) -> None:
    cur.execute(
        """
        INSERT INTO mem_events
        (session_id, seq, ticks, cpu, pid, type, source, name, oldsz, newsz)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        """,
        (
            SESSION_ID,
            event["seq"],
            event["ticks"],
            event["cpu"],
            event["pid"],
            event["type"],
            event["source"],
            event["name"],
            event["oldsz"],
            event["newsz"],
        ),
    )


def ensure_schema(cur: sqlite3.Cursor) -> None:
    cur.execute(
        """
        CREATE TABLE IF NOT EXISTS mem_events(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            session_id TEXT NOT NULL,
            seq INTEGER,
            ticks INTEGER,
            cpu INTEGER,
            pid INTEGER,
            type TEXT,
            source TEXT,
            name TEXT,
            oldsz INTEGER,
            newsz INTEGER,
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
                                print(f"[OK] Saved MEM event seq={mem_event['seq']} pid={mem_event['pid']}")
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
