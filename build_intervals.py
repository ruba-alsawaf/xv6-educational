#!/usr/bin/env python3
import sqlite3
from pathlib import Path

DB_PATH = "events.db"


def get_latest_session_id(cur):
    cur.execute("""
        SELECT session_id
        FROM events
        GROUP BY session_id
        ORDER BY MAX(id) DESC
        LIMIT 1
    """)
    row = cur.fetchone()
    return row[0] if row else None


def load_sched_info(cur, session_id):
    cur.execute("""
        SELECT scheduler, cpus, time_slice, tick, seq
        FROM events
        WHERE session_id = ?
          AND type = 'SCHED_INFO'
        ORDER BY seq ASC
        LIMIT 1
    """, (session_id,))
    row = cur.fetchone()
    if not row:
        return None

    return {
        "scheduler": row[0],
        "cpus": row[1],
        "time_slice": row[2],
        "tick": row[3],
        "seq": row[4],
    }


def load_sched_events(cur, session_id):
    cur.execute("""
        SELECT seq, tick, cpu, pid, name, state, type, reason
        FROM events
        WHERE session_id = ?
          AND type IN ('ON_CPU', 'OFF_CPU')
        ORDER BY seq ASC
    """, (session_id,))
    rows = cur.fetchall()

    events = []
    for row in rows:
        events.append({
            "seq": row[0],
            "tick": row[1],
            "cpu": row[2],
            "pid": row[3],
            "name": row[4] or "",
            "state": row[5],
            "type": row[6],
            "reason": row[7],
        })
    return events


def events_to_intervals(events):
    intervals = []
    open_runs = {}   # key = (cpu, pid)

    for ev in events:
        ev_type = ev["type"]
        key = (ev["cpu"], ev["pid"])

        if ev_type == "ON_CPU":
            # إذا في interval مفتوح لنفس المفتاح، سكريه احتياطياً
            if key in open_runs:
                old = open_runs.pop(key)
                old["seq_end"] = ev["seq"]
                old["tick_end"] = ev["tick"]
                old["duration"] = ev["tick"] - old["tick_start"]
                old["off_reason"] = None
                old["closed_implicitly"] = 1
                intervals.append(old)

            open_runs[key] = {
                "seq_start": ev["seq"],
                "seq_end": None,
                "tick_start": ev["tick"],
                "tick_end": None,
                "duration": None,
                "cpu": ev["cpu"],
                "pid": ev["pid"],
                "name": ev["name"],
                "state_on_cpu": ev["state"],
                "off_reason": None,
                "closed_implicitly": 0,
            }

        elif ev_type == "OFF_CPU":
            if key in open_runs:
                run = open_runs.pop(key)
                run["seq_end"] = ev["seq"]
                run["tick_end"] = ev["tick"]
                run["duration"] = ev["tick"] - run["tick_start"]
                run["off_reason"] = ev["reason"]
                if not run["name"] and ev["name"]:
                    run["name"] = ev["name"]
                intervals.append(run)

    # أي interval ضل مفتوح
    for run in open_runs.values():
        intervals.append(run)

    return intervals


def ensure_intervals_schema(cur):
    cur.execute("""
        CREATE TABLE IF NOT EXISTS sched_intervals(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            session_id TEXT NOT NULL,
            seq_start INTEGER,
            seq_end INTEGER,
            tick_start INTEGER,
            tick_end INTEGER,
            duration INTEGER,
            cpu INTEGER,
            pid INTEGER,
            name TEXT,
            state_on_cpu INTEGER,
            off_reason INTEGER,
            closed_implicitly INTEGER DEFAULT 0
        )
    """)

    cur.execute("""
        CREATE INDEX IF NOT EXISTS idx_sched_intervals_session
        ON sched_intervals(session_id)
    """)


def save_intervals(cur, session_id, intervals):
    cur.execute("DELETE FROM sched_intervals WHERE session_id = ?", (session_id,))

    for it in intervals:
        cur.execute("""
            INSERT INTO sched_intervals(
                session_id,
                seq_start, seq_end,
                tick_start, tick_end, duration,
                cpu, pid, name, state_on_cpu,
                off_reason, closed_implicitly
            )
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        """, (
            session_id,
            it.get("seq_start"),
            it.get("seq_end"),
            it.get("tick_start"),
            it.get("tick_end"),
            it.get("duration"),
            it.get("cpu"),
            it.get("pid"),
            it.get("name"),
            it.get("state_on_cpu"),
            it.get("off_reason"),
            it.get("closed_implicitly", 0),
        ))


def main():
    db_file = Path(DB_PATH)
    if not db_file.exists():
        raise FileNotFoundError(f"DB not found: {DB_PATH}")

    con = sqlite3.connect(DB_PATH)
    cur = con.cursor()

    ensure_intervals_schema(cur)

    session_id = get_latest_session_id(cur)
    if not session_id:
        print("[ERR] No sessions found.")
        return

    info = load_sched_info(cur, session_id)
    events = load_sched_events(cur, session_id)
    intervals = events_to_intervals(events)

    save_intervals(cur, session_id, intervals)
    con.commit()

    print(f"[OK] Session: {session_id}")
    print(f"[OK] Scheduler info: {info}")
    print(f"[OK] Loaded events: {len(events)}")
    print(f"[OK] Built intervals: {len(intervals)}")

    print("\nFirst 10 intervals:")
    for item in intervals[:10]:
        print(item)


if __name__ == "__main__":
    main()