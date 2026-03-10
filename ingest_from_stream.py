
import sys, re, sqlite3, time

DB_PATH = "/home/ruba/xv6-test/events.db"

# يلتقط سطر مثل:
# seq=537 tick=8365 cpu=1 pid=2 name=sh state=4
pat = re.compile(
    r"seq=(\d+)\s+tick=(\d+)\s+cpu=(\d+)\s+pid=(\d+)\s+name=([^\s]+)\s+state=(\d+)"
)

def main():
    con = sqlite3.connect(DB_PATH)
    cur = con.cursor()
    cur.execute("""
    CREATE TABLE IF NOT EXISTS events(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      seq INTEGER,
      tick INTEGER,
      cpu INTEGER,
      pid INTEGER,
      name TEXT,
      state INTEGER
    )
    """)
    con.commit()

    # تسريع: commit على دفعات
    buf = []
    last_commit = time.time()
    BATCH = 200
    COMMIT_EVERY_SEC = 0.5

    for line in sys.stdin:
        m = pat.search(line)
        if not m:
            continue
        seq, tick, cpu, pid, name, state = m.groups()
        buf.append((int(seq), int(tick), int(cpu), int(pid), name, int(state)))

        now = time.time()
        if len(buf) >= BATCH or (buf and (now - last_commit) >= COMMIT_EVERY_SEC):
            cur.executemany(
                "INSERT INTO events(seq,tick,cpu,pid,name,state) VALUES (?,?,?,?,?,?)",
                buf
            )
            con.commit()
            buf.clear()
            last_commit = now

if __name__ == "__main__":
    main()
