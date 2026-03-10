import socket, struct, sqlite3, time

SOCK_PATH = "/tmp/xv6-ev.sock"
DB_PATH = "/home/ruba/xv6-test/events.db"
EV_MAGIC = 0x31545645  # EVT1

def recv_exact(sock, n):
    b = bytearray()
    while len(b) < n:
        chunk = sock.recv(n - len(b))
        if not chunk:
            raise ConnectionError("socket closed")
        b += chunk
    return bytes(b)

def main():
    con = sqlite3.connect(DB_PATH)
    cur = con.cursor()
    cur.execute("""
    CREATE TABLE IF NOT EXISTS events(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      seq INTEGER, tick INTEGER, cpu INTEGER,
      type INTEGER, pid INTEGER, state INTEGER,
      name TEXT
    )
    """)
    con.commit()

    s = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
    while True:
        try:
            s.connect(SOCK_PATH)
            break
        except FileNotFoundError:
            time.sleep(0.05)

    EVREC_FMT = "<QIHHii16s"  # must match struct evrec
    EVREC_SIZE = struct.calcsize(EVREC_FMT)

    print("[ingest] connected to", SOCK_PATH)

    while True:
        magic = struct.unpack("<I", recv_exact(s, 4))[0]
        if magic != EV_MAGIC:
            # resync بسيطة
            continue

        length = struct.unpack("<H", recv_exact(s, 2))[0]
        payload = recv_exact(s, length)

        if length != EVREC_SIZE:
            continue

        seq,tick,cpu,etype,pid,state,name = struct.unpack(EVREC_FMT, payload)
        name = name.split(b"\x00",1)[0].decode("utf-8","replace")

        cur.execute(
            "INSERT INTO events(seq,tick,cpu,type,pid,state,name) VALUES (?,?,?,?,?,?,?)",
            (seq,tick,cpu,etype,pid,state,name)
        )
        con.commit()

if __name__ == "__main__":
    main()
