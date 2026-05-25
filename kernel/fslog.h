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

enum {
  FS_ALLOC_BLOCK = 1,
  FS_CREATE_FILE = 2,
  FS_WRITE_FILE  = 3,
  FS_READ_FILE   = 4,
  FS_FREE_BLOCK  = 5,
  FS_BGET_HIT    = 6,   // موجودين هون وهاد بيكفي
  FS_BGET_MISS   = 7,
  FS_BRELEASE    = 8
} __attribute__((packed));

struct fs_event {
  // الحقول المشتركة لكل الأحداث
  uint64 seq;
  uint ticks;
  int pid;
  int type;        // LAYER_BCACHE or LAYER_LOG or LAYER_BALLOC ...
  char op_name[16];
  char details[128]; 

  // الحقول الخاصة بكل طبقة (يحجز مساحة لأكبرها فقط لتوفير الذاكرة)
  union {
      // حقول البفر كاش (Bcache)
      struct {
          int blockno;
          int buf_id;
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
