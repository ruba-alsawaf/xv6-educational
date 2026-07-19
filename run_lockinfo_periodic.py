#!/usr/bin/env python3
import json
import sqlite3
import time
import uuid
import re
import subprocess
import threading
from pathlib import Path

LOG_PATH = "qemu.log"
DB_PATH = "events.db"
SESSION_ID = str(uuid.uuid4())

def extract_json(line: str, marker: str) -> dict | None:
    """Extract JSON object from line starting with marker"""
    if marker not in line or '{' not in line:
        return None
    
    pos = line.find(marker)
    brace_start = line.find('{', pos)
    if brace_start == -1:
        return None
    
    depth = 0
    for i in range(brace_start, len(line)):
        if line[i] == '{': depth += 1
        elif line[i] == '}': 
            depth -= 1
            if depth == 0:
                try:
                    payload = re.sub(r'[\x00-\x1f\x7f-\x9f]', '', line[brace_start:i+1])
                    return json.loads(payload)
                except:
                    return None
    return None

def ensure_schema(con: sqlite3.Connection) -> None:
    """Create database schema for locks if not exists"""
    con.execute("""CREATE TABLE IF NOT EXISTS lock_metrics(
        id INTEGER PRIMARY KEY AUTOINCREMENT, 
        session_id TEXT, 
        lock_name TEXT, 
        last_pid INTEGER, 
        proc_name TEXT, 
        cpu_id INTEGER, 
        last_hold_time INTEGER, 
        acq_count INTEGER, 
        contention INTEGER, 
        timestamp DATETIME DEFAULT CURRENT_TIMESTAMP
    )""")
    
    con.execute("CREATE INDEX IF NOT EXISTS idx_lock_metrics_session ON lock_metrics(session_id)")
    con.execute("CREATE INDEX IF NOT EXISTS idx_lock_metrics_name ON lock_metrics(lock_name)")
    con.commit()

def insert_lock_info(cur: sqlite3.Cursor, event: dict) -> None:
    """Insert parsed lock JSON into database"""
    cur.execute("""INSERT INTO lock_metrics
    (session_id, lock_name, last_pid, proc_name, cpu_id, last_hold_time, acq_count, contention)
    VALUES (?, ?, ?, ?, ?, ?, ?, ?)""", (
        SESSION_ID, 
        event.get("name", "unknown"),
        event.get("last_pid", -1),
        event.get("proc_name", ""),
        event.get("cpu_id", -1),
        event.get("last_hold_time", 0),
        event.get("acq_count", 0),
        event.get("contention", 0)
    ))

def run_qemu_and_log():
    """Run QEMU, save output to log, and periodically send 'lockinfo' command"""
    print("🚀 Starting xv6 in background...")
    
    # تشغيل النظام وتوجيه المدخلات والمخرجات
    process = subprocess.Popen(
        ["make", "qemu"], 
        stdin=subprocess.PIPE, 
        stdout=subprocess.PIPE, 
        stderr=subprocess.STDOUT,
        text=True
    )

    # مؤقت آلي لإرسال أمر lockinfo كل 3 ثواني
    def send_commands():
        time.sleep(4)  # انتظار إقلاع النظام
        while process.poll() is None:
            try:
                process.stdin.write("lockinfo\n")
                process.stdin.flush()
                time.sleep(3) # عدلي هذا الرقم لتسريع أو إبطاء جلب البيانات
            except:
                break

    threading.Thread(target=send_commands, daemon=True).start()

    # كتابة مخرجات النظام إلى ملف qemu.log
    with open(LOG_PATH, "w", encoding="utf-8") as f:
        for line in process.stdout:
            f.write(line)
            f.flush()

def main():
    # 1. تشغيل xv6 في Thread منفصل حتى لا يتوقف الكود
    qemu_thread = threading.Thread(target=run_qemu_and_log, daemon=True)
    qemu_thread.start()
    
    # إعطاء النظام ثانية ليقوم بإنشاء ملف اللوج
    time.sleep(1)
    
    if not Path(LOG_PATH).exists():
        open(LOG_PATH, 'w').close()
    
    con = sqlite3.connect(DB_PATH, timeout=30.0, check_same_thread=False)
    con.execute("PRAGMA journal_mode=WAL")
    con.execute("PRAGMA synchronous=NORMAL")
    cur = con.cursor()
    ensure_schema(con)
    
    last_pos = 0
    lock_count = 0
    
    print("📡 Listening for LOCK_EV data...")
    try:
        while qemu_thread.is_alive():
            try:
                with open(LOG_PATH, "r", encoding="utf-8", errors="ignore") as f:
                    f.seek(last_pos)
                    for line in f:
                        # البحث عن كلمة LOCK_EV التي أضفناها بدالة الطباعة بالكيرنل
                        lock_event = extract_json(line, "LOCK_EV")
                        if lock_event:
                            insert_lock_info(cur, lock_event)
                            lock_count += 1
                    
                    last_pos = f.tell()
                    
                    if lock_count > 0:
                        con.commit()
                        print(f"✓ Saved: {lock_count} new lock records to Database")
                        lock_count = 0
            except IOError:
                pass
            
            time.sleep(1) # تحقق من الملف كل ثانية
            
    except KeyboardInterrupt:
        print("\n🛑 Stopping system and saving database...")
        con.commit()
        con.close()

if __name__ == "__main__":
    main()
