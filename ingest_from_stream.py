#!/usr/bin/env python3
import json
import sqlite3
import time

LOG_PATH = "/home/ruba/xv6-test/qemu.log"
DB_PATH = "/home/ruba/xv6-test/events.db"

def main():
    con = sqlite3.connect(DB_PATH)
    cur = con.cursor()

    cur.execute("""
    CREATE TABLE IF NOT EXISTS events(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      seq INTEGER UNIQUE,
      tick INTEGER,
      cpu INTEGER,
      pid INTEGER,
      name TEXT,
      state INTEGER,
      type TEXT
    )
    """)
    con.commit()

    with open(LOG_PATH, "r", encoding="utf-8", errors="ignore") as f:
        f.seek(0, 0)

        while True:
            line = f.readline()
            if not line:
                time.sleep(0.1)
                continue

            line = line.strip()

            if not line.startswith("EV "):
                continue

            try:
                obj = json.loads(line[3:])
            except Exception:
                continue

            cur.execute(
                "INSERT OR IGNORE INTO events(seq,tick,cpu,pid,name,state,type) VALUES (?,?,?,?,?,?,?)",
                (
                    int(obj["seq"]),
                    int(obj["tick"]),
                    int(obj["cpu"]),
                    int(obj["pid"]),
                    obj["name"],
                    int(obj["state"]),
                    obj["type"],
                )
            )
            con.commit()

if __name__ == "__main__":
    main()