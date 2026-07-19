
#ifndef SPINLOCK_H
#define SPINLOCK_H

// Mutual exclusion lock.
struct spinlock {
  uint locked;       // Is the lock held?

  // For debugging:
  char *name;        // Name of lock.
  struct cpu *cpu;   // The cpu holding the lock.
  int pid;           // رقم العملية اللي ماسكة القفل
  uint64 start_time; // السطر الجديد: لحظة حجز القفل
  uint last_hold_time; // <-- السطر الجديد: مدة آخر حجز
  uint acq_count;
  char proc_name[16]; 
  int  cpu_id;        
  uint contention;
};

#endif // SPINLOCK_H
