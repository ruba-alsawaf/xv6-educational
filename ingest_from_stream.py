#!/usr/bin/env python3
import json
import sqlite3
import time
import uuid
import re

LOG_PATH = "/mnt/c/Users/ASUS/rubaa/qemu.log"
DB_PATH = "/mnt/c/Users/ASUS/rubaa/events.db"
SESSION_ID = str(uuid.uuid4())
BATCH_SIZE = 1 
SLEEP_WHEN_IDLE = 0.1

def clean_payload(payload):
    # إزالة أي أحرف تحكم غير مرئية قد تسبب فشل الـ JSON
    return re.sub(r'[\x00-\x1f\x7f-\x9f]', '', payload)

def ensure_schema(cur):
    cur.execute("""
    CREATE TABLE IF NOT EXISTS events(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        session_id TEXT, seq INTEGER UNIQUE, tick INTEGER,
        cpu INTEGER, pid INTEGER, name TEXT, state INTEGER, type TEXT
    )""")
    cur.execute("""
    CREATE TABLE IF NOT EXISTS fs_events(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        session_id TEXT, seq INTEGER, tick INTEGER, type INTEGER,
        pid INTEGER, inum INTEGER, blockno INTEGER, size INTEGER, name TEXT
    )""")

def extract_event_payloads(line):
    payloads = []
    i = 0
    while True:
        start = line.find("EV {", i)
        if start == -1: break
        brace_start = line.find("{", start)
        depth, end = 0, -1
        for j in range(brace_start, len(line)):
            if line[j] == "{": depth += 1
            elif line[j] == "}":
                depth -= 1
                if depth == 0:
                    end = j
                    break
        if end != -1:
            payloads.append(line[brace_start:end + 1])
            i = end + 1
        else: break
    return payloads

def main():
    con = sqlite3.connect(DB_PATH, timeout=10.0)
    cur = con.cursor()
    ensure_schema(cur)
    con.commit()

    pending = ""
    print(f"[INFO] Started Clean Ingestor. Session: {SESSION_ID}")

    with open(LOG_PATH, "r", encoding="utf-8", errors="ignore") as f:
        while True:
            chunk = f.read(4096)
            if not chunk:
                time.sleep(SLEEP_WHEN_IDLE)
                continue
            pending += chunk
            while "\n" in pending:
                line, pending = pending.split("\n", 1)
                for payload in extract_event_payloads(line):
                    cleaned = clean_payload(payload)
                    try:
                        event = json.loads(cleaned)
                        if event.get("type") == "FS":
                            cur.execute("INSERT INTO fs_events (session_id, seq, tick, type, pid, inum, blockno, size, name) VALUES (?,?,?,?,?,?,?,?,?)",
                                (SESSION_ID, event["seq"], event["tick"], event.get("fs_type", 0), event["pid"], event.get("inum", 0), event.get("block", 0), event.get("size", 0), event.get("name", "")))
                        else:
                            cur.execute("INSERT OR IGNORE INTO events (session_id, seq, tick, cpu, pid, name, state, type) VALUES (?,?,?,?,?,?,?,?)",
                                (SESSION_ID, event["seq"], event["tick"], event.get("cpu", 0), event["pid"], event.get("name", "unknown"), event.get("state", 0), event["type"]))
                        con.commit()
                        print(f"[OK] Saved seq={event['seq']}")
                    except Exception as e:
                        print(f"[ERR] {e}")

if __name__ == "__main__":
    main()
