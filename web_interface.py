#!/usr/bin/env python3
from flask import Flask, render_template_string, jsonify
import sqlite3
import os

app = Flask(__name__)
DB_PATH = "events.db"

HTML_TEMPLATE = """
<!DOCTYPE html>
<html>
<head>
    <title>xv6 CPU and Process Stats</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; }
        table { border-collapse: collapse; width: 100%; margin-bottom: 20px; }
        th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }
        th { background-color: #f2f2f2; }
        .refresh { margin-bottom: 20px; }
    </style>
    <script>
        function refreshData() {
            location.reload();
        }
        setInterval(refreshData, 5000); // Auto refresh every 5 seconds
    </script>
</head>
<body>
    <h1>xv6 CPU and Process Statistics</h1>
    <button onclick="refreshData()">Refresh</button>

    <h2>CPU Information</h2>
    <table>
        <tr>
            <th>CPU</th>
            <th>Active</th>
            <th>Current PID</th>
            <th>Current State</th>
            <th>Last PID</th>
            <th>Last State</th>
            <th>Busy %</th>
            <th>Active Ticks</th>
            <th>Timestamp</th>
        </tr>
        {% for cpu in cpus %}
        <tr>
            <td>{{ cpu.cpu }}</td>
            <td>{{ cpu.active }}</td>
            <td>{{ cpu.current_pid }}</td>
            <td>{{ cpu.current_state }}</td>
            <td>{{ cpu.last_pid }}</td>
            <td>{{ cpu.last_state }}</td>
            <td>{{ cpu.busy_percent }}</td>
            <td>{{ cpu.active_ticks }}</td>
            <td>{{ cpu.timestamp }}</td>
        </tr>
        {% endfor %}
    </table>

    <h2>Process Statistics</h2>
    <table>
        <tr>
            <th>Total Created</th>
            <th>Total Exited</th>
            <th>Current UNUSED</th>
            <th>Current USED</th>
            <th>Current SLEEPING</th>
            <th>Current RUNNABLE</th>
            <th>Current RUNNING</th>
            <th>Current ZOMBIE</th>
            <th>Unique UNUSED</th>
            <th>Unique USED</th>
            <th>Unique SLEEPING</th>
            <th>Unique RUNNABLE</th>
            <th>Unique RUNNING</th>
            <th>Unique ZOMBIE</th>
            <th>Timestamp</th>
        </tr>
        {% for stat in proc_stats %}
        <tr>
            <td>{{ stat.total_created }}</td>
            <td>{{ stat.total_exited }}</td>
            <td>{{ stat.current_unused }}</td>
            <td>{{ stat.current_used }}</td>
            <td>{{ stat.current_sleeping }}</td>
            <td>{{ stat.current_runnable }}</td>
            <td>{{ stat.current_running }}</td>
            <td>{{ stat.current_zombie }}</td>
            <td>{{ stat.unique_unused }}</td>
            <td>{{ stat.unique_used }}</td>
            <td>{{ stat.unique_sleeping }}</td>
            <td>{{ stat.unique_runnable }}</td>
            <td>{{ stat.unique_running }}</td>
            <td>{{ stat.unique_zombie }}</td>
            <td>{{ stat.timestamp }}</td>
        </tr>
        {% endfor %}
    </table>

    <h2>Scheduler Events (Latest 50)</h2>
    <table>
        <tr>
            <th>Seq</th>
            <th>Tick</th>
            <th>Type</th>
            <th>CPU</th>
            <th>PID</th>
            <th>Name</th>
            <th>State</th>
            <th>Reason</th>
        </tr>
        {% for event in events %}
        <tr>
            <td>{{ event.seq }}</td>
            <td>{{ event.tick }}</td>
            <td>{{ event.type }}</td>
            <td>{{ event.cpu }}</td>
            <td>{{ event.pid }}</td>
            <td>{{ event.name }}</td>
            <td>{{ event.state }}</td>
            <td>{{ event.reason }}</td>
        </tr>
        {% endfor %}
    </table>
</body>
</html>
"""

@app.route('/')
def index():
    if not os.path.exists(DB_PATH):
        return "Database not found. Run ingest_from_stream.py first."

    con = sqlite3.connect(DB_PATH)
    cur = con.cursor()

    # Get latest CPU info
    cur.execute("""
        SELECT cpu, active, current_pid, current_state, last_pid, last_state, busy_percent, active_ticks, timestamp
        FROM cpu_info
        ORDER BY timestamp DESC
        LIMIT 10
    """)
    cpus = [dict(zip(['cpu', 'active', 'current_pid', 'current_state', 'last_pid', 'last_state', 'busy_percent', 'active_ticks', 'timestamp'], row)) for row in cur.fetchall()]

    # Get latest process stats
    cur.execute("""
        SELECT total_created, total_exited,
               current_unused, current_used, current_sleeping, current_runnable, current_running, current_zombie,
               unique_unused, unique_used, unique_sleeping, unique_runnable, unique_running, unique_zombie,
               timestamp
        FROM proc_stats
        ORDER BY timestamp DESC
        LIMIT 10
    """)
    proc_stats = [dict(zip(['total_created', 'total_exited',
                           'current_unused', 'current_used', 'current_sleeping', 'current_runnable', 'current_running', 'current_zombie',
                           'unique_unused', 'unique_used', 'unique_sleeping', 'unique_runnable', 'unique_running', 'unique_zombie',
                           'timestamp'], row)) for row in cur.fetchall()]

    # Get latest scheduler events
    cur.execute("""
        SELECT seq, tick, type, cpu, pid, name, state, reason
        FROM events
        ORDER BY seq DESC
        LIMIT 50
    """)
    events = [dict(zip(['seq', 'tick', 'type', 'cpu', 'pid', 'name', 'state', 'reason'], row)) for row in cur.fetchall()]

    con.close()

    return render_template_string(HTML_TEMPLATE, cpus=cpus, proc_stats=proc_stats, events=events)

@app.route('/api/cpu')
def api_cpu():
    if not os.path.exists(DB_PATH):
        return jsonify({"error": "Database not found"})

    con = sqlite3.connect(DB_PATH)
    cur = con.cursor()

    cur.execute("""
        SELECT cpu, active, current_pid, current_state, last_pid, last_state, busy_percent, active_ticks, timestamp
        FROM cpu_info
        ORDER BY timestamp DESC
        LIMIT 100
    """)
    cpus = [dict(zip(['cpu', 'active', 'current_pid', 'current_state', 'last_pid', 'last_state', 'busy_percent', 'active_ticks', 'timestamp'], row)) for row in cur.fetchall()]

    con.close()
    return jsonify(cpus)

@app.route('/api/proc')
def api_proc():
    if not os.path.exists(DB_PATH):
        return jsonify({"error": "Database not found"})

    con = sqlite3.connect(DB_PATH)
    cur = con.cursor()

    cur.execute("""
        SELECT total_created, total_exited,
               current_unused, current_used, current_sleeping, current_runnable, current_running, current_zombie,
               unique_unused, unique_used, unique_sleeping, unique_runnable, unique_running, unique_zombie,
               timestamp
        FROM proc_stats
        ORDER BY timestamp DESC
        LIMIT 100
    """)
    proc_stats = [dict(zip(['total_created', 'total_exited',
                           'current_unused', 'current_used', 'current_sleeping', 'current_runnable', 'current_running', 'current_zombie',
                           'unique_unused', 'unique_used', 'unique_sleeping', 'unique_runnable', 'unique_running', 'unique_zombie',
                           'timestamp'], row)) for row in cur.fetchall()]

    con.close()
    return jsonify(proc_stats)

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5000)
