#!/usr/bin/env python3
import sqlite3
from pathlib import Path

DB_PATH = "events.db"

def init_database():
    print(f"[INFO] Initializing database at {DB_PATH}...")
    
    # الاتصال بقاعدة البيانات (سيتم إنشاء الملف إذا لم يكن موجوداً)
    con = sqlite3.connect(DB_PATH)
    cur = con.cursor()

    # 1. إنشاء جدول مقاييس المعالج (CPU Metrics)
    cur.execute("""
        CREATE TABLE IF NOT EXISTS cpu_metrics(
            id INTEGER PRIMARY KEY, 
            session_id TEXT, 
            cpu_id TEXT, 
            active INTEGER,
            current_pid INTEGER, 
            proc_name TEXT, 
            current_state TEXT,
            context_eip TEXT, 
            context_esp TEXT, 
            busy_percent INTEGER,
            total_created INTEGER, 
            total_exited INTEGER, 
            ever_running INTEGER,
            ever_sleeping INTEGER, 
            ever_zombie INTEGER, 
            timestamp DATETIME DEFAULT CURRENT_TIMESTAMP
        )
    """)

    # 2. إنشاء جدول إحصائيات العمليات (Process Stats)
    cur.execute("""
        CREATE TABLE IF NOT EXISTS proc_stats(
            id INTEGER PRIMARY KEY, 
            session_id TEXT, 
            total_created INTEGER, 
            total_exited INTEGER,
            current_unused INTEGER, 
            current_used INTEGER, 
            current_sleeping INTEGER,
            current_runnable INTEGER, 
            current_running INTEGER, 
            current_zombie INTEGER,
            unique_unused INTEGER, 
            unique_used INTEGER, 
            unique_sleeping INTEGER,
            unique_runnable INTEGER, 
            unique_running INTEGER, 
            unique_zombie INTEGER,
            timestamp DATETIME DEFAULT CURRENT_TIMESTAMP
        )
    """)

    # 3. إنشاء جدول أحداث الذاكرة (Memory Events)
    cur.execute("""
        CREATE TABLE IF NOT EXISTS mem_events(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            session_id TEXT NOT NULL,
            seq INTEGER,
            tick INTEGER,
            cpu INTEGER,
            pid INTEGER,
            type TEXT,
            src TEXT,
            va INTEGER,
            pa INTEGER,
            perm TEXT,
            kind TEXT,
            name TEXT,
            old INTEGER,
            new INTEGER,
            timestamp DATETIME DEFAULT CURRENT_TIMESTAMP
        )
    """)

    # 4. إنشاء جدول الطلاب لتسجيل الدخول (Students)
    cur.execute("""
        CREATE TABLE IF NOT EXISTS Students (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            username TEXT NOT NULL UNIQUE,
            password TEXT NOT NULL
        )
    """)

    # 5. إنشاء الفهارس (Indexes) لتسريع عمليات البحث في الواجهات
    cur.execute("CREATE INDEX IF NOT EXISTS idx_cpu_metrics_session ON cpu_metrics(session_id)")
    cur.execute("CREATE INDEX IF NOT EXISTS idx_proc_stats_session ON proc_stats(session_id)")
    cur.execute("CREATE INDEX IF NOT EXISTS idx_mem_events_session_timestamp ON mem_events(session_id, timestamp)")

    # 6. إضافة مستخدم افتراضي لتجربة تسجيل الدخول (إذا لم يكن موجوداً)
    cur.execute("SELECT COUNT(*) FROM Students WHERE username = 'student'")
    if cur.fetchone()[0] == 0:
        cur.execute("INSERT INTO Students (username, password) VALUES ('student', '1234')")
        print("[INFO] Default student user created (username: student, password: 1234).")

    # حفظ التغييرات وإغلاق الاتصال
    con.commit()
    con.close()
    print("[INFO] Database initialization completed successfully. ✓")

if __name__ == "__main__":
    init_database()
