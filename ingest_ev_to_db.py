#!/usr/bin/env python3

import sys, json, sqlite3

db = sqlite3.connect("events.db")
cur = db.cursor()

for line in sys.stdin:
    line = line.strip()
    if not line.startswith("EV "):
        continue
    ev = json.loads(line[3:])
    cur.execute(
        "INSERT OR IGNORE INTO events(seq,tick,cpu,pid,name,state,type) VALUES (?,?,?,?,?,?,?)",
        (ev["seq"], ev["tick"], ev["cpu"], ev["pid"], ev["name"], ev["state"], ev["type"])
    )
    db.commit()
