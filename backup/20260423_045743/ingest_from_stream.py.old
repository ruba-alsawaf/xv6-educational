

#!/usr/bin/env python3
import json
import sqlite3
import time
import uuid
import re
from pathlib import Path

LOG_PATH = "/mnt/c/Users/ASUS/rubaa/qemu.log"
DB_PATH = "/mnt/c/Users/ASUS/rubaa/events.db"

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
        seq INTEGER UNIQUE,
        tick INTEGER,
        fs_type INTEGER,
        pid INTEGER,
        dev INTEGER,
        blockno INTEGER,
        old_blockno INTEGER,
        buf_id INTEGER,
        ref_before INTEGER,
        ref_after INTEGER,
        valid_before INTEGER,
        valid_after INTEGER,
        locked_before INTEGER,
        locked_after INTEGER,
        lru_before INTEGER,
        lru_after INTEGER,
        scan_dir INTEGER,
        scan_step INTEGER,
        found INTEGER,
        size INTEGER,
        inum INTEGER,  
        i_type INTEGER,  
        i_size INTEGER,  
        nlink INTEGER,   
        addrs TEXT ,
        name TEXT,
        op_name TEXT 
        
    )
    """)

    cur.execute("""
    CREATE TABLE IF NOT EXISTS buffer_state(
        buf_id INTEGER PRIMARY KEY,
        dev INTEGER,
        blockno INTEGER,
        refcnt INTEGER,
        valid INTEGER,
        locked INTEGER,
        lru_pos INTEGER,
        last_event_type INTEGER,
        last_seq INTEGER,
        session_id TEXT
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
    CREATE INDEX IF NOT EXISTS idx_fs_events_buf
    ON fs_events(buf_id)
    """)
     
   

def extract_event_payloads(line: str) -> list[str]:
    payloads = []
    i = 0

    while True:
        start = line.find("EV {", i)
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

def is_important_fs_event(event: dict) -> bool:
    fs_type = event.get("fs_type", 0)

    # كل الأحداث المهمة + اللوج
    if fs_type in [1,3,4,5,6,7,20,21,22,23,24,25,30,31, 40,41,42,43,44,45,46]:
        return True

    if fs_type == 2:
        if event.get("found") == 1:
            return True
        if event.get("scan_step") == 0:
            return True

    return False   

def get_op_name(event: dict) -> str:
    # نتحقق أولاً إذا كان الـ csexport قد أرسل الاسم جاهزاً في حقل "op"
    if "op" in event:
        return event["op"]
    
    # إذا لم يوجد، نستخدم القاموس بناءً على الرقم
    t = event.get("fs_type", 0)
    mapping = {
        20: "BEGIN_OP", 21: "LOG_WRITE", 22: "END_OP",
        23: "WRITE_LOG", 24: "COMMIT", 25: "INSTALL",
        30: "BALLOC", 31: "BFREE" ,
        40: "IALLOC", 41: "IGET", 42: "IPUT", 
        43: "ILOCK", 44: "IUNLOCK", 45: "IUPDATE", 46: "IBMAP"
    }
    return mapping.get(t, "FS")    


def insert_fs_event(cur: sqlite3.Cursor, event: dict) -> None:
    if not is_important_fs_event(event):
        return

    operation_name = get_op_name(event)
    
    # تحضير القيم بشكل نظيف لتجنب أخطاء التكرار
    try:
        cur.execute("""
        INSERT OR IGNORE INTO fs_events 
        (
            session_id, seq, tick, fs_type, pid, dev, blockno, old_blockno, buf_id,
            ref_before, ref_after, valid_before, valid_after,
            locked_before, locked_after, lru_before, lru_after,
            scan_dir, scan_step, found, size, 
            inum, i_type, i_size, nlink, addrs, name, op_name
        ) 
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        """, (
            SESSION_ID, 
            event.get("seq"), 
            event.get("tick"),
            event.get("fs_type", 0), 
            event.get("pid", 0), 
            event.get("dev", 0),
            event.get("block", -1), 
            event.get("old_block", -1), 
            event.get("buf_id", -1),
            event.get("ref_before", -1), 
            event.get("ref_after", -1), # سيستخدم كـ Ref Count في الواجهة
            event.get("valid_before", -1), 
            event.get("valid_after", -1),
            event.get("locked_before", -1), 
            event.get("locked_after", -1), # سيستخدم لرمز القفل 🔒
            event.get("lru_before", -1), 
            event.get("lru_after", -1),
            event.get("scan_dir", 0), 
            event.get("scan_step", 0),
            event.get("found", 0), 
            event.get("size", 0),
            event.get("inum", -1), # أساسي لربط السطر بالجدول
            event.get("i_type", 0), # لنوع الملف (أيقونة)
            event.get("i_size", 0), # الحجم الحالي
            event.get("nlink", 0), # Link Count
            event.get("addrs", "0,0,0,0,0,0,0,0,0,0,0,0,0"), # لرسم الـ Blocks
            event.get("name", ""), 
            operation_name
        ))
    except sqlite3.Error as e:
        print(f"[ERR] SQLite Insert Error: {e}")

def update_buffer_state(cur: sqlite3.Cursor, event: dict) -> None:
    # ملاحظة: هذه الدالة تبقى كما هي لأننا نريد تحديث "حالة البفر الحالية" 
    # دائماً لنعرف مكانه في الـ LRU، حتى لو لم نسجل الحدث في التاريخ.
    buf_id = event.get("buf_id", -1)
    if not isinstance(buf_id, int) or buf_id < 0 or buf_id >= 30:
        return

    cur.execute("""
    INSERT INTO buffer_state
    (buf_id, dev, blockno, refcnt, valid, locked, lru_pos, last_event_type, last_seq, session_id)
    VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    ON CONFLICT(buf_id) DO UPDATE SET
        dev = excluded.dev,
        blockno = excluded.blockno,
        refcnt = excluded.refcnt,
        valid = excluded.valid,
        locked = excluded.locked,
        lru_pos = excluded.lru_pos,
        last_event_type = excluded.last_event_type,
        last_seq = excluded.last_seq,
        session_id = excluded.session_id
    """, (
        buf_id, event.get("dev", 0), event.get("block", -1),
        event.get("ref_after", -1), event.get("valid_after", -1),
        event.get("locked_after", -1), event.get("lru_after", -1),
        event.get("fs_type", 0), event.get("seq", 0), SESSION_ID
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


def handle_event(cur: sqlite3.Cursor, event: dict) -> None:
    ev_type = event.get("type")

    if ev_type == "FS":
        update_buffer_state(cur, event)
        insert_fs_event(cur, event)
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
