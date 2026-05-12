#!/usr/bin/env python3

import json
import sqlite3
import re
import time
import uuid
from datetime import datetime
import traceback

LOG_PATH = "/mnt/c/Users/ASUS/rubaa/qemu.log"
DB_PATH = "/mnt/c/Users/ASUS/rubaa/events.db"

SESSION_ID = str(uuid.uuid4())
READ_CHUNK_SIZE = 4096
SLEEP_WHEN_IDLE = 0.1

def clean_payload(payload: str) -> str:
    """تنظيف البيانات من الأحرف غير الصالحة قبل التحويل لـ JSON"""
    return re.sub(r'[\x00-\x1f\x7f-\x9f]', '', payload)

def ensure_schema(cur: sqlite3.Cursor) -> None:
    """إنشاء الجداول اللازمة (الجدولة + نظام الملفات الجديد + حالة البفرات)"""
    
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
        seq INTEGER UNIQUE,
        session_id TEXT NOT NULL,
        tick INTEGER,
        pid INTEGER,
        layer TEXT,
        op_name TEXT,

    -- Bcache
        buf_id INTEGER,
        blockno INTEGER,
        ref INTEGER,
        old_ref INTEGER,
        valid INTEGER,
        old_valid INTEGER,

    -- Log layer (🔥 الجديد)
        log_n INTEGER,
        old_log_n INTEGER,
        outstanding INTEGER,
        old_outstanding INTEGER,
        committing INTEGER,
        old_committing INTEGER,

    --INODE
        inum INTEGER,
        inode_type INTEGER,
        old_inode_type INTEGER,
        inode_size INTEGER,
        old_inode_size INTEGER,
        locked INTEGER,
        old_locked INTEGER,    

    --directory, path, file (يمكن إضافة حقول خاصة بهم لاحقًا)
        path TEXT,
        elem TEXT,
        parent_inum INTEGER,
        target_inum INTEGER,
        offset INTEGER,

        file_ref INTEGER,
        old_file_ref INTEGER,
        file_off INTEGER,
        old_file_off INTEGER,
        readable INTEGER,
        writable INTEGER, 

        details TEXT,
        timestamp DATETIME DEFAULT CURRENT_TIMESTAMP
    )
    """)

    # 3. جدول الحالة اللحظية (للمربعات الـ 30 في الواجهة)
    cur.execute("""
    CREATE TABLE IF NOT EXISTS buffer_cache_state(
        buf_id INTEGER PRIMARY KEY,
        blockno INTEGER,
        refcnt INTEGER,
        is_valid INTEGER,
        is_dirty INTEGER,
        is_busy INTEGER,
        last_update_tick INTEGER
    )
    """)
    
    # ================= INODE LIVE STATE =================

    cur.execute("""
    CREATE TABLE IF NOT EXISTS inode_state(
        inum INTEGER PRIMARY KEY,
        refcnt INTEGER,
        is_valid INTEGER,
        inode_type INTEGER,
        inode_size INTEGER,
        is_locked INTEGER,
        last_update_tick INTEGER
    )
    """)
    cur.execute("""
    CREATE TABLE IF NOT EXISTS log_state(
    id INTEGER PRIMARY KEY CHECK(id=1),
    log_n INTEGER,
    outstanding INTEGER,
    committing INTEGER,
    last_update_tick INTEGER
    )
    """)
    # تهيئة مربعات البفر الـ 30
    for i in range(30):
        cur.execute("""
            INSERT OR IGNORE INTO buffer_cache_state 
            (buf_id, blockno, refcnt, is_valid, is_dirty, is_busy) 
            VALUES (?, -1, 0, 0, 0, 0)
        """, (i,))

    # فهارس لتحسين سرعة الاستعلام في الواجهة
    cur.execute("CREATE INDEX IF NOT EXISTS idx_fs_tick ON fs_events(tick)")
    cur.execute("CREATE INDEX IF NOT EXISTS idx_sched_tick ON events(tick)")

def parse_change(change_str):
    """تحويل '2->3' إلى (old=2, new=3)"""
    if not change_str:
        return None, None
    try:
        old, new = change_str.split("->")
        return int(old), int(new)
    except:
        return None, None

def handle_fs_event(cur: sqlite3.Cursor, data: dict):
    layer = data.get("layer")

    # ===================== BCACHE =====================
    if layer == "BCACHE" or layer == 1:
        state = data.get("state", {})
        changes = data.get("changes", {})
        buf = data.get("buf", {})

        old_ref, new_ref = parse_change(changes.get("ref"))
        old_valid, new_valid = parse_change(changes.get("valid"))

        cur.execute("""
        INSERT INTO fs_events (
            seq, session_id, tick, pid, layer, op_name,
            buf_id, blockno,
            ref, old_ref,
            valid, old_valid,
            details
        ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        """, (
            data.get('seq'),
            SESSION_ID,
            data.get('tick'),
            data.get('pid'),
            "BCACHE",
            data.get('op'),

            buf.get("id"),
            buf.get("block"),

            new_ref if new_ref is not None else state.get("ref"),
            old_ref,

            new_valid if new_valid is not None else state.get("valid"),
            old_valid,

            data.get("desc")
        ))

        # ================= UPDATE LIVE STATE =================

        current_ref = new_ref if new_ref is not None else state.get("ref", 0)
        current_valid = new_valid if new_valid is not None else state.get("valid", 0)

        cur.execute("""
        INSERT INTO buffer_cache_state (
            buf_id,
            blockno,
            refcnt,
            is_valid,
            is_busy,
            last_update_tick
        )
        VALUES (?, ?, ?, ?, ?, ?)

        ON CONFLICT(buf_id) DO UPDATE SET
            blockno = excluded.blockno,
            refcnt = excluded.refcnt,
            is_valid = excluded.is_valid,
            is_busy = excluded.is_busy,
            last_update_tick = excluded.last_update_tick
        """, (
            buf.get("id"),
            buf.get("block"),
            current_ref,
            current_valid,
            1 if current_ref > 0 else 0,
            data.get("tick")
        ))
    # ===================== LOG =====================
    elif layer == "LOG":
        state = data.get("state", {})
        changes = data.get("changes", {})

        old_n, new_n = parse_change(changes.get("log_n"))
        old_out, new_out = parse_change(changes.get("outstanding"))
        old_c, new_c = parse_change(changes.get("committing"))

        cur.execute("""
        INSERT INTO fs_events (
            session_id, tick, pid, layer, op_name,
            log_n, old_log_n,
            outstanding, old_outstanding,
            committing, old_committing,
            details
        ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        """, (
            SESSION_ID,
            data.get('tick'),
            data.get('pid'),
            "LOG",
            data.get('op'),

            new_n if new_n is not None else state.get("log_n"),
            old_n,

            new_out if new_out is not None else state.get("outstanding"),
            old_out,

            new_c if new_c is not None else state.get("committing"),
            old_c,

            data.get("desc")
        ))
        current_n = new_n if new_n is not None else state.get("log_n", 0)
        current_out = new_out if new_out is not None else state.get("outstanding", 0)
        current_commit = new_c if new_c is not None else state.get("committing", 0)
        cur.execute("""
        INSERT INTO log_state(
            id,
            log_n,
            outstanding,
            committing,
            last_update_tick
        )
        VALUES (1, ?, ?, ?, ?)

        ON CONFLICT(id) DO UPDATE SET
            log_n = excluded.log_n,
            outstanding = excluded.outstanding,
            committing = excluded.committing,
            last_update_tick = excluded.last_update_tick
        """, (
            current_n,
            current_out,
            current_commit,
            data.get("tick")
        ))

    elif layer == "BALLOC":
        state = data.get("state", {})
        changes = data.get("changes", {})

        old_bit, new_bit = parse_change(changes.get("bit"))

        cur.execute("""
        INSERT INTO fs_events (
            session_id, tick, pid, layer, op_name,
            blockno,
            details
        ) VALUES (?, ?, ?, ?, ?, ?, ?)
        """, (
            SESSION_ID,
            data.get('tick'),
            data.get('pid'),
            "BALLOC",
            data.get('op'),
            data.get('block'),
            f"{data.get('desc')} | bit {old_bit}->{new_bit}"
        ))

    elif layer == "INODE":
        inode = data.get("inode", {})
        state = data.get("state", {})
        changes = data.get("changes", {})

        old_ref, new_ref = parse_change(changes.get("ref"))
        old_valid, new_valid = parse_change(changes.get("valid"))
        old_type, new_type = parse_change(changes.get("type"))
        old_size, new_size = parse_change(changes.get("size"))
        old_locked, new_locked = parse_change(changes.get("locked"))

        cur.execute("""
        INSERT INTO fs_events (
            session_id,
            tick,
            pid,
            layer,
            op_name,
            inum,
            ref,
            old_ref,
            valid,
            old_valid,
            inode_type,
            old_inode_type,
            inode_size,
            old_inode_size,
            locked,
            old_locked,
            details
        ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        """, (
            SESSION_ID,
            data.get("tick"),
            data.get("pid"),
            "INODE",
            data.get("op"),

            inode.get("inum"),

            new_ref if new_ref is not None else state.get("ref"),
            old_ref,

            new_valid if new_valid is not None else state.get("valid"),
            old_valid,

            new_type if new_type is not None else state.get("type"),
            old_type,

            new_size if new_size is not None else state.get("size"),
            old_size,

            new_locked if new_locked is not None else state.get("locked"),
            old_locked,

            data.get("desc")
        ))
                # ================= UPDATE LIVE INODE STATE =================

        current_ref = new_ref if new_ref is not None else state.get("ref", 0)
        current_valid = new_valid if new_valid is not None else state.get("valid", 0)
        current_type = new_type if new_type is not None else state.get("type", 0)
        current_size = new_size if new_size is not None else state.get("size", 0)
        current_locked = new_locked if new_locked is not None else state.get("locked", 0)

        cur.execute("""
        INSERT INTO inode_state(
            inum,
            refcnt,
            is_valid,
            inode_type,
            inode_size,
            is_locked,
            last_update_tick
        )
        VALUES (?, ?, ?, ?, ?, ?, ?)

        ON CONFLICT(inum) DO UPDATE SET
            refcnt = excluded.refcnt,
            is_valid = excluded.is_valid,
            inode_type = excluded.inode_type,
            inode_size = excluded.inode_size,
            is_locked = excluded.is_locked,
            last_update_tick = excluded.last_update_tick
        """, (
            inode.get("inum"),
            current_ref,
            current_valid,
            current_type,
            current_size,
            current_locked,
            data.get("tick")
        ))
        # ===================== DIRECTORY =====================
    elif layer == "DIR":

        dirinfo = data.get("dir", {})

        cur.execute("""
        INSERT INTO fs_events (
            seq,
            session_id,
            tick,
            pid,
            layer,
            op_name,

            parent_inum,
            target_inum,
            offset,
            elem,

            details
        ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        """, (
            data.get("seq"),
            SESSION_ID,
            data.get("tick"),
            data.get("pid"),

            "DIR",
            data.get("op"),

            dirinfo.get("parent"),
            dirinfo.get("target"),
            dirinfo.get("offset"),
            dirinfo.get("name"),

            data.get("desc")
        ))
        # ===================== PATH =====================
    elif layer == "PATH":

        cur.execute("""
        INSERT INTO fs_events (
            session_id,
            tick,
            pid,
            layer,
            op_name,
            path,
            elem,
            details
        ) VALUES (?, ?, ?, ?, ?, ?, ?, ?)
        """, (
            SESSION_ID,
            data.get("tick"),
            data.get("pid"),

            "PATH",
            data.get("op"),

            data.get("path"),
            data.get("elem"),

            data.get("desc")
        ))
        # ===================== FILE =====================
    elif layer == "FILE":

        changes = data.get("changes", {})

        old_ref, new_ref = parse_change(changes.get("ref"))
        old_off, new_off = parse_change(changes.get("offset"))

        cur.execute("""
        INSERT INTO fs_events (
            session_id,
            tick,
            pid,
            layer,
            op_name,

            file_ref,
            old_file_ref,

            file_off,
            old_file_off,

            readable,
            writable,

            details
        ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        """, (
            SESSION_ID,
            data.get("tick"),
            data.get("pid"),

            "FILE",
            data.get("op"),

            new_ref if new_ref is not None else data.get("ref"),
            old_ref,

            new_off if new_off is not None else data.get("offset"),
            old_off,

            data.get("readable"),
            data.get("writable"),

            data.get("desc")
        ))       
def handle_scheduling_event(cur: sqlite3.Cursor, data: dict):
    """تخزين أحداث الجدولة كما هي"""
    try:
        cur.execute("""
        INSERT OR IGNORE INTO events
        (session_id, seq, tick, cpu, pid, name, state, type, reason, scheduler, cpus, time_slice)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        """, (
            SESSION_ID, data.get("seq"), data.get("tick"), data.get("cpu"),
            data.get("pid"), data.get("name", ""), data.get("state"),
            data.get("type", ""), data.get("reason"), data.get("scheduler"),
            data.get("cpus"), data.get("time_slice")
        ))
    except sqlite3.Error: pass

def extract_event_payloads(line: str) -> list[str]:
    """استخراج JSON كامل (يدعم nested objects)"""
    found = []
    brace_stack = 0
    start = -1

    for i, ch in enumerate(line):
        if ch == '{':
            if brace_stack == 0:
                start = i
            brace_stack += 1
        elif ch == '}':
            brace_stack -= 1
            if brace_stack == 0 and start != -1:
                found.append(line[start:i+1])
                start = -1

    return found



def main() -> None:
    con = sqlite3.connect(DB_PATH, timeout=30.0, isolation_level=None)
    cur = con.cursor()
    cur.execute("PRAGMA journal_mode=WAL;")
    ensure_schema(cur)
    con.commit()

    print(f"[INFO] Ingestor Active. Session: {SESSION_ID}")
    pending = ""

    with open(LOG_PATH, "r", encoding="utf-8", errors="ignore") as f:
        f.seek(0, 2) # قراءة حية (Tail)
        while True:
            chunk = f.read(READ_CHUNK_SIZE)
            if not chunk:
                time.sleep(SLEEP_WHEN_IDLE)
                continue

            pending += chunk
            while "\n" in pending:
                line, pending = pending.split("\n", 1)
                payloads = extract_event_payloads(line)
                
                for payload in payloads:
                    try:
                        clean_data = clean_payload(payload)
                        data = json.loads(clean_data)
                        
                        if "op" in data or "layer" in data:
                            handle_fs_event(cur, data)
                        else:
                            handle_scheduling_event(cur, data)
                    

                    except Exception as e:
                        print("[ERROR]", e)
                        traceback.print_exc()
                        print(payload)
                
                con.commit()

if __name__ == "__main__":
    main()