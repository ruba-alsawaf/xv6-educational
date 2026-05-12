# xv6 Memcat Monitor Implementation

## Overview
Implemented a complete memcat monitoring system parallel to the existing CPU scheduler monitor, including:
- Background ingestor script that parses memcat output from QEMU logs
- SQLite database persistence in `events.db` 
- Qt-based GUI window with live memory event visualization
- Periodic memcat command execution every 5 seconds
- Integrated into main dashboard

## File Structure

### Backend (Python Ingestor)
- **[run_memcat_periodic.py](run_memcat_periodic.py)** - New periodic ingestor script
  - Parses memcat output from `qemu.log` using regex
  - Extracts: seq, ticks, cpu, pid, type, source, name, oldsz, newsz
  - Inserts events into `mem_events` table with automatic timestamps
  - Runs every 5 seconds, polling for new log lines

### Database Schema
- **mem_events table** (created in `events.db`):
  - id, session_id, seq, ticks, cpu, pid
  - type (GROW, SHRINK, etc.)
  - source (KALLOC, KFREE, UVMALLOC, etc.)
  - name, oldsz, newsz, timestamp
  - Indexed on session_id + timestamp for fast queries

### GUI Components

#### C++ Classes
- **[gui/MainGUI/memcatUi/memcatWindow.h](gui/MainGUI/memcatUi/memcatWindow.h)**
  - QMainWindow subclass
  - Manages QEMU/ingestor process lifecycle
  - Sends periodic `memcat\n` commands to QEMU console

- **[gui/MainGUI/memcatUi/memcatWindow.cpp](gui/MainGUI/memcatUi/memcatWindow.cpp)**
  - Full implementation with:
    - Dual process management (QEMU + ingestor)
    - Timer-based memcat command dispatch (5s interval)
    - Database event loading (latest 200 events)
    - Status indicators and error handling

#### Integration
- **[gui/MainGUI/mainwindow.cpp](gui/MainGUI/mainwindow.cpp)** - Updated
  - Added "🧠 Memcat Monitor" button to dashboard
  - Connected to `onMemcatClicked()` handler

- **[gui/MainGUI/mainwindow.h](gui/MainGUI/mainwindow.h)** - Updated
  - Added `onMemcatClicked()` slot
  - Added `btnMemcat` button member

- **[gui/MainGUI/CMakeLists.txt](gui/MainGUI/CMakeLists.txt)** - Updated
  - Registered memcatWindow source files in build

## Workflow

1. **User clicks "Memcat Monitor"** in main GUI dashboard
2. **MemcatWindow launches**:
   - Connects to `events.db`
   - Starts QEMU (bash: `make qemu`)
   - Waits 2 seconds then starts ingestor (`python3 run_memcat_periodic.py`)

3. **Every 5 seconds**:
   - GUI sends `memcat\n` to QEMU stdin
   - QEMU executes memcat command
   - Output appears in `qemu.log`
   - Ingestor script reads new log lines
   - Regex extracts memcat events
   - Events inserted into `mem_events` table

4. **Table refreshes** with latest 200 events (descending by id):
   - seq, ticks, cpu, pid, type, source, name, old size, new size
   - Cleaned regularly to show newest events

5. **Process cleanup**:
   - Window close → terminates ingestor → terminates QEMU

## Key Features

✅ **Modular Design** - Separate files for scheduler and memcat (no coupling)
✅ **5-Second Polling** - Both command dispatch and ingestor use same interval
✅ **Beautiful Table UI** - Stretched columns, alternating rows, read-only selection
✅ **Status Indicators** - Color-coded labels show system state
✅ **Error Handling** - DB errors, process start failures handled gracefully
✅ **Auto-initialization** - Schema created automatically on first run
✅ **Scalable Queries** - Indexes on session_id + timestamp for performance

## Building & Running

```bash
cd gui/MainGUI
mkdir build && cd build
cmake ..
make

# Run the GUI
./MainGUI
```

The "Memcat Monitor" button will appear in the main dashboard alongside the CPU scheduler button.

## Memcat Output Format

The xv6 memcat command outputs lines like:
```
#0 seq=15 tick=1023 cpu=0 pid=5 type=GROW src=UVMALLOC name=sh old=0x1000 new=0x2000
```

The Python regex parser extracts all fields, then displays them in the GUI table.
