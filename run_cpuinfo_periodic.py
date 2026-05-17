import json
import sqlite3
import time
import uuid
import re
from pathlib import Path

# الإعدادات الأساسية
LOG_PATH = "qemu.log"
DB_PATH = "events.db"
SESSION_ID = str(uuid.uuid4())

def clean_payload(payload: str) -> str:
    """تنظيف النص من أي محارف غريبة قد يطبعها xv6"""
    return re.sub(r'[\x00-\x1f\x7f-\x9f]', '', payload)

def parse_cpu_info(line: str) -> dict | None:
    """تحليل سطر الـ JSON الموحد"""
    if 'CPU {' not in line:
        return None
    try:
        start_idx = line.find('{')
        end_idx = line.rfind('}')
        if start_idx != -1 and end_idx != -1:
            payload = line[start_idx:end_idx+1]
            return json.loads(clean_payload(payload))
    except Exception as e:
        # قمنا بتحويلها إلى رسالة تلميح ناعمة لأن تداخل النصوص أمر طبيعي في الكيرنل المتعدد الأنوية
        pass 
    return None

def ensure_schema(cur: sqlite3.Cursor):
    """إنشاء الجدول المتوافق مع البيانات الجديدة"""
    cur.execute("""
    CREATE TABLE IF NOT EXISTS cpu_metrics (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        session_id TEXT,
        cpu_id TEXT,
        active INTEGER,
        current_pid INTEGER,
        current_state TEXT,
        busy_percent INTEGER,
        total_created INTEGER,
        total_exited INTEGER,
        ever_running INTEGER,
        ever_sleeping INTEGER,
        ever_zombie INTEGER,
        timestamp DATETIME DEFAULT CURRENT_TIMESTAMP
    )
    """)

def insert_data(cur: sqlite3.Cursor, data: dict):
    """إدخال بيانات كل كور على حدة مع العدادات العامة"""
    sys_stats = data.get("system", {})
    cpus_list = data.get("cpus", [])
    
    for cpu in cpus_list:
        cur.execute("""
        INSERT INTO cpu_metrics 
        (session_id, cpu_id, active, current_pid, current_state, 
         busy_percent, total_created, total_exited, 
         ever_running, ever_sleeping, ever_zombie)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        """, (
            SESSION_ID, 
            cpu.get("cpu_id"), 
            cpu.get("active"),
            cpu.get("current_pid"), 
            cpu.get("current_state"),
            cpu.get("busy_percent"), 
            sys_stats.get("total_created"),
            sys_stats.get("total_exited"),
            sys_stats.get("ever_running"),
            sys_stats.get("ever_sleeping"), 
            sys_stats.get("ever_zombie")
        ))

def main():
    con = sqlite3.connect(DB_PATH)
    cur = con.cursor()
    ensure_schema(cur)
    con.commit()

    print(f"--- [INFO] Started Monitoring ---")
    print(f"Session ID: {SESSION_ID}")
    print(f"Reading from: {LOG_PATH}")
    
    last_pos = 0

    try:
        while True:
            log_file = Path(LOG_PATH)
            if log_file.exists():
                # 🌟 تعديل الأمان: التحقق من إعادة تشغيل المحاكي وتصفير الملف
                current_size = log_file.stat().st_size
                if current_size < last_pos:
                    print("[INFO] Log file truncated (QEMU restarted). Resetting pointer.")
                    last_pos = 0

                with open(LOG_PATH, "r", encoding="utf-8", errors="ignore") as f:
                    f.seek(last_pos)
                    lines = f.readlines()
                    last_pos = f.tell()

                    # استخدام معالجة المعاملات (Transaction) السريعة في المجموعات لتعزيز الأداء
                    has_updates = False
                    for line in lines:
                        data = parse_cpu_info(line)
                        if data:
                            insert_data(cur, data)
                            has_updates = True
                    
                    if has_updates:
                        con.commit()
                        print(f"[OK] Saved snapshot to Database.")
            
            # تحديث كل 3 ثوانٍ
            time.sleep(3)
    except KeyboardInterrupt:
        con.close()
        print("\n[INFO] Script stopped by user.")

if __name__ == "__main__":
    main()
