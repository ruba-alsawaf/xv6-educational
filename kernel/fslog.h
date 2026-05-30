#ifndef FSLOG_H
#define FSLOG_H

// ملاحظة: إذا كان هاد الملف موجود جوا مجلد kernel، الأفضل تغيري السطر لـ #include "types.h"
#include "kernel/types.h"

#define LAYER_BCACHE 1
#define LAYER_LOG    2
#define LAYER_BALLOC 3
#define LAYER_INODE  4
#define LAYER_DIR    5
#define LAYER_PATH   6
#define LAYER_FILE   7

#define FS_NM 32   // Maximum field size for names

enum {
  FS_ALLOC_BLOCK = 1,
  FS_CREATE_FILE = 2,
  FS_WRITE_FILE  = 3,
  FS_READ_FILE   = 4,
  FS_FREE_BLOCK  = 5,
  FS_BGET_HIT    = 6,
  FS_BGET_MISS   = 7,
  FS_BRELEASE    = 8,
  FS_INODE_PUT   = 9,
  FS_BREAD_REQ   = 10,
  FS_BGET_SCAN   = 11,
  FS_BREAD_FILL  = 12,
  FS_BWRITE      = 13,
  FS_LOG_BEGIN   = 14,
  FS_LOG_WRITE   = 15,
  FS_LOG_END     = 16,
  FS_LOG_WLOG    = 17,
  FS_LOG_WHEAD   = 18,
  FS_LOG_INSTALL = 19,
  FS_BLOCK_ALLOC = 20,
  FS_BLOCK_FREE  = 21,
  FS_INODE_ALLOC = 22,
  FS_INODE_GET   = 23,
  FS_INODE_LOCK  = 24,
  FS_INODE_UPDATE= 25,
  FS_DIR_LOOKUP  = 26,
  FS_DIR_LINK    = 27,
  FS_PATH_SEARCH = 28,
  FS_NAME_X      = 29,
  FS_IGET        = 30,
  FS_IGET_EXIST  = 31,
  FS_ILOCK       = 32,
  FS_IUNLOCK     = 33,
  FS_IUPDATE     = 34,
  FS_BALLOC_BIT  = 35,
  FS_BFREE_BIT   = 36,
  FS_DIRLOOKUP   = 37,
  FS_DIRLINK     = 38,
  FS_PATHSEARCH  = 39,
  FS_NAMEX       = 40
} __attribute__((packed));

struct fs_event {
  // الحقول المشتركة لكل الأحداث
  uint64 seq;
  uint ticks;
  int pid;
  int type;        // LAYER_BCACHE or LAYER_LOG or LAYER_BALLOC ...
  char op_name[16];
  char details[128];
  char name[FS_NM]; // اسم عام يستخدم في عدة أماكن
  
  // حقول عامة تُستخدم في عدة طبقات
  int blockno;      // للـ log.c و bio.c
  int old_blockno;  // البلوك القديم (للمسح)
  int inum;         // للـ fs.c (inode)
  int dev;          // الجهاز
  int buf_id;       // معرف البفر
  int h;            // متغير مساعد
  
  // حقول inode
  int i_type;
  int i_size;
  int nlink;
  
  // حقول ref counts عامة
  int ref_before;
  int ref_after;
  int valid_before;
  int valid_after;
  int locked_before;
  int locked_after;
  
  // حقول LRU tracking
  int lru_before;
  int lru_after;
  
  // حقول المسح والبحث
  int scan_dir;     // اتجاه المسح
  int scan_step;    // خطوة المسح
  int found;        // تم العثور عليه
  
  // حقول مشتركة للـ log events (للتوافق مع kernel/log.c)
  int old_log_n;
  int old_outstanding;
  int old_committing;
  int log_n;
  int outstanding;
  int committing;
  
  // حقول العناوين (للـ inode)
  uint addrs[13];

  // الحقول الخاصة بكل طبقة (يحجز مساحة لأكبرها فقط لتوفير الذاكرة)
  union {
      // حقول البفر كاش (Bcache)
      struct {
          int buf_id;
          int blockno;     // للـ bio.c
          int refcnt;
          int old_refcnt;
          int valid;
          int old_valid;
      } bcache;

      // حقول اللوغ (Log)
      struct {
          int log_n;
          int old_log_n;
          int outstanding;
          int old_outstanding;
          int committing;
          int old_committing;
      } log;

      // حقول الـ BALLOC
      struct {
          int blockno;     // للـ fs.c (balloc)
          int bit;
          int old_bit;
      } balloc;

      // ===== INODE =====
      struct {
          int inum;
          int ref;
          int old_ref;
          int valid_inode;
          int old_valid_inode;
          int type_inode;
          int old_type_inode;
          int size;
          int old_size;
          int locked;
          int old_locked;
      } inode;

      // ===== DIRECTORY =====
      struct {
          char path[128];
          char name[20];
          int parent_inum;
          int target_inum;
          int offset;
      } dir;

      // ===== FILE DESCRIPTOR =====
      struct {
          int fd;
          int file_type;
          int readable;
          int writable;
          int file_ref;
          int old_file_ref;
          int file_off;
          int old_file_off;
      } file;
  };
};

void fslog_init(void);
void fslog_push(struct fs_event *e);
int  fslog_read_many(struct fs_event *out, int max);
// دالة مخصصة لأحداث اللوغ لتبسيط الكود في log.c
void fslog_log_event(char* op, int n, int old_n, int out, int old_out, int comm, char* det);

#endif
