#!/usr/bin/env python3
"""
نظام محلل أحداث Buffer Cache في xv6
يقرأ الأحداث من QEMU Log ويخزنها في قاعدة بيانات SQLite
مع معالجة تفصيلية وشروحات محسنة
"""

import json
import sqlite3
import re
import time
import uuid
from pathlib import Path
from datetime import datetime

LOG_PATH = "/mnt/c/Users/ASUS/rubaa/qemu.log"
DB_PATH = "/mnt/c/Users/ASUS/rubaa/events.db"

SESSION_ID = str(uuid.uuid4())
READ_CHUNK_SIZE = 4096
SLEEP_WHEN_IDLE = 0.1

def clean_payload(payload: str) -> str:
    """تنظيف البيانات من الأحرف الغير صالحة"""
    return re.sub(r'[\x00-\x1f\x7f-\x9f]', '', payload)


def ensure_schema(cur: sqlite3.Cursor) -> None:
    """إنشء جداول قاعدة البيانات إذا لم تكن موجودة"""
    
    # جدول الأحداث العامة (scheduler events)
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

    # جدول أحداث نظام الملفات والبفرات (محسّن)
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
        addrs TEXT,
        name TEXT,
        op_name TEXT,
        
        -- حقول إضافية للتحليل المتقدم
        impact_score INTEGER DEFAULT 0,  -- درجة تأثير الحدث
        is_important INTEGER DEFAULT 1,  -- هل هذا حدث مهم
        timestamp DATETIME DEFAULT CURRENT_TIMESTAMP
    )
    """)

    # جدول حالة البفرات (محسّن)
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
        session_id TEXT,
        
        -- حقول إضافية
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
    )
    """)

    # جدول تاريخ البفرات (لتتبع التغييرات)
    cur.execute("""
    CREATE TABLE IF NOT EXISTS buffer_history(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        buf_id INTEGER,
        seq INTEGER,
        dev INTEGER,
        blockno INTEGER,
        refcnt INTEGER,
        valid INTEGER,
        locked INTEGER,
        lru_pos INTEGER,
        event_type INTEGER,
        session_id TEXT,
        timestamp DATETIME DEFAULT CURRENT_TIMESTAMP
    )
    """)

    # جدول الإحصائيات (مخزن مؤقت)
    cur.execute("""
    CREATE TABLE IF NOT EXISTS statistics(
        session_id TEXT PRIMARY KEY,
        total_hits INTEGER DEFAULT 0,
        total_misses INTEGER DEFAULT 0,
        total_reads INTEGER DEFAULT 0,
        total_writes INTEGER DEFAULT 0,
        last_updated DATETIME DEFAULT CURRENT_TIMESTAMP
    )
    """)

    # فهارس للأداء
    cur.execute("""
    CREATE INDEX IF NOT EXISTS idx_events_session_seq
    ON events(session_id, seq)
    """)

    cur.execute("""
    CREATE INDEX IF NOT EXISTS idx_fs_events_session_seq
    ON fs_events(session_id, seq)
    """)

    cur.execute("""
    CREATE INDEX IF NOT EXISTS idx_fs_events_buf
    ON fs_events(buf_id)
    """)

    cur.execute("""
    CREATE INDEX IF NOT EXISTS idx_fs_events_type
    ON fs_events(fs_type)
    """)

    cur.execute("""
    CREATE INDEX IF NOT EXISTS idx_buffer_history_buf
    ON buffer_history(buf_id, seq)
    """)


def extract_event_payloads(line: str) -> list[str]:
    """استخراج الأحداث من سطر واحد"""
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


def calculate_impact_score(event: dict) -> int:
    """حساب درجة تأثير الحدث على الأداء"""
    fs_type = event.get("fs_type", 0)
    score = 0
    
    if fs_type == 3:  # HIT
        score = 1  # أقل تأثيراً (سريع)
    elif fs_type == 4:  # MISS
        score = 5  # تأثير متوسط
    elif fs_type == 5:  # FILL (قراءة من القرص)
        score = 10  # تأثير كبير (بطيء)
    elif fs_type == 6:  # WRITE
        score = 8  # تأثير كبير
    elif fs_type in [20, 21, 22, 23, 24, 25]:  # LOG operations
        score = 3  # تأثير متوسط
    elif fs_type in [30, 31]:  # BALLOC, BFREE
        score = 2
    elif fs_type in [40, 41, 42, 43, 44, 45]:  # INODE operations
        score = 4
    
    return score


def is_important_fs_event(event: dict) -> bool:
    """تحديد ما إذا كان الحدث مهماً لعرضه"""
    fs_type = event.get("fs_type", 0)

    # الأحداث المهمة جداً (Buffer Cache)
    important_types = [3, 4, 5, 6, 7]  # HIT, MISS, FILL, WRITE, RELEASE
    
    if fs_type in important_types:
        return True

    # الأحداث المهمة المتوسطة
    medium_types = [20, 21, 22, 23, 24, 25]  # LOG operations
    if fs_type in medium_types:
        return event.get("found") == 1 or event.get("scan_step") == 0

    return False


def get_op_name(event: dict) -> str:
    """الحصول على اسم العملية"""
    if "op" in event:
        return event["op"]
    
    fs_type = event.get("fs_type", 0)
    mapping = {
        2: "BGET_SCAN",
        3: "BGET_HIT",
        4: "BGET_MISS",
        5: "BREAD_FILL",
        6: "BWRITE",
        7: "BRELEASE",
        
        20: "BEGIN_OP",
        21: "LOG_WRITE",
        22: "END_OP",
        23: "WRITE_LOG",
        24: "COMMIT",
        25: "INSTALL",
        
        30: "BALLOC",
        31: "BFREE",
        
        40: "IALLOC",
        41: "IGET",
        42: "IPUT",
        43: "ILOCK",
        44: "IUNLOCK",
        45: "IUPDATE",
        46: "IBMAP"
    }
    return mapping.get(fs_type, f"UNKNOWN_{fs_type}")


def insert_fs_event(cur: sqlite3.Cursor, event: dict) -> None:
    """إدراج حدث نظام ملفات محسّن"""
    if not is_important_fs_event(event):
        return

    operation_name = get_op_name(event)
    impact_score = calculate_impact_score(event)
    
    try:
        cur.execute("""
        INSERT OR IGNORE INTO fs_events 
        (
            session_id, seq, tick, fs_type, pid, dev, blockno, old_blockno, buf_id,
            ref_before, ref_after, valid_before, valid_after,
            locked_before, locked_after, lru_before, lru_after,
            scan_dir, scan_step, found, size, 
            inum, i_type, i_size, nlink, addrs, name, op_name,
            impact_score, is_important
        ) 
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
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
            event.get("ref_after", -1),
            event.get("valid_before", -1), 
            event.get("valid_after", -1),
            event.get("locked_before", -1), 
            event.get("locked_after", -1),
            event.get("lru_before", -1), 
            event.get("lru_after", -1),
            event.get("scan_dir", 0), 
            event.get("scan_step", 0),
            event.get("found", 0), 
            event.get("size", 0),
            event.get("inum", -1),
            event.get("i_type", 0),
            event.get("i_size", 0),
            event.get("nlink", 0),
            event.get("addrs", "0,0,0,0,0,0,0,0,0,0,0,0,0"),
            event.get("name", ""), 
            operation_name,
            impact_score,
            1  # is_important
        ))
    except sqlite3.Error as e:
        print(f"[ERR] SQLite Insert Error: {e}")


def update_buffer_state(cur: sqlite3.Cursor, event: dict) -> None:
    """تحديث حالة البفر الحالية وتسجيل التاريخ"""
    buf_id = event.get("buf_id", -1)
    if not isinstance(buf_id, int) or buf_id < 0 or buf_id >= 30:
        return

    try:
        # تحديث الحالة الحالية
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
            session_id = excluded.session_id,
            updated_at = CURRENT_TIMESTAMP
        """, (
            buf_id,
            event.get("dev", 0),
            event.get("block", -1),
            event.get("ref_after", -1),
            event.get("valid_after", -1),
            event.get("locked_after", -1),
            event.get("lru_after", -1),
            event.get("fs_type", 0),
            event.get("seq", 0),
            SESSION_ID
        ))

        # تسجيل التاريخ
        cur.execute("""
        INSERT INTO buffer_history
        (buf_id, seq, dev, blockno, refcnt, valid, locked, lru_pos, event_type, session_id)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        """, (
            buf_id,
            event.get("seq", 0),
            event.get("dev", 0),
            event.get("block", -1),
            event.get("ref_after", -1),
            event.get("valid_after", -1),
            event.get("locked_after", -1),
            event.get("lru_after", -1),
            event.get("fs_type", 0),
            SESSION_ID
        ))
    except sqlite3.Error as e:
        print(f"[ERR] Update buffer state error: {e}")


def update_statistics(cur: sqlite3.Cursor) -> None:
    """تحديث الإحصائيات المخزنة مؤقتاً"""
    try:
        # حساب الإحصائيات
        stats_query = """
        SELECT
            SUM(CASE WHEN fs_type = 3 THEN 1 ELSE 0 END) as hits,
            SUM(CASE WHEN fs_type = 4 THEN 1 ELSE 0 END) as misses,
            SUM(CASE WHEN fs_type = 5 THEN 1 ELSE 0 END) as reads,
            SUM(CASE WHEN fs_type = 6 THEN 1 ELSE 0 END) as writes
        FROM fs_events
        WHERE session_id = ?
        """

        cur.execute(stats_query, (SESSION_ID,))
        row = cur.fetchone()

        hits = row[0] or 0
        misses = row[1] or 0
        reads = row[2] or 0
        writes = row[3] or 0

        # تحديث جدول الإحصائيات
        cur.execute("""
        INSERT OR REPLACE INTO statistics
        (session_id, total_hits, total_misses, total_reads, total_writes, last_updated)
        VALUES (?, ?, ?, ?, ?, CURRENT_TIMESTAMP)
        """, (SESSION_ID, hits, misses, reads, writes))

        print(f"[STAT] Hits={hits} Misses={misses} Reads={reads} Writes={writes}")
    except sqlite3.Error as e:
        print(f"[ERR] Statistics update error: {e}")


def insert_general_event(cur: sqlite3.Cursor, event: dict) -> None:
    """إدراج حدث عام (scheduler event)"""
    try:
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
    except sqlite3.Error as e:
        print(f"[ERR] Insert general event error: {e}")


def handle_event(cur: sqlite3.Cursor, event: dict) -> None:
    """معالجة حدث واحد"""
    ev_type = event.get("type")

    if ev_type == "FS":
        update_buffer_state(cur, event)
        insert_fs_event(cur, event)
    else:
        insert_general_event(cur, event)


def main() -> None:
    """الدالة الرئيسية"""
    log_file = Path(LOG_PATH)
    if not log_file.exists():
        raise FileNotFoundError(f"Log file not found: {LOG_PATH}")

    con = sqlite3.connect(DB_PATH, timeout=10.0)
    cur = con.cursor()
    ensure_schema(cur)
    con.commit()

    pending = ""

    print(f"[INFO] ========== محلل Buffer Cache ==========")
    print(f"[INFO] Started ingestor. Session: {SESSION_ID}")
    print(f"[INFO] Log:  {LOG_PATH}")
    print(f"[INFO] DB:   {DB_PATH}")
    print(f"[INFO] Time: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    print(f"[INFO] ========================================\n")

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
                    except json.JSONDecodeError as e:
                        print(f"[WARN] JSON parse error: {e}")
                        continue

                con.commit()

                # تحديث الإحصائيات كل 100 حدث
                if cur.lastrowid % 100 == 0:
                    update_statistics(cur)
                    con.commit()


if __name__ == "__main__":
    main()
