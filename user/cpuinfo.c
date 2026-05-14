#include "user/user.h"
#include "kernel/procinfo.h"
#include "kernel/proc.h"
#include "kernel/schedlog.h"

#define MAX_HISTORY_EVENTS 16
#define MAX_HISTORY_NAME_LEN 32

static const char *state_names[PROC_STATE_COUNT] = {
  "UNUSED",
  "USED",
  "SLEEPING",
  "RUNNABLE",
  "RUNNING",
  "ZOMBIE",
};

static void
escape_json_string(const char *src, char *dst, int dstlen)
{
  int di = 0;
  for (int si = 0; src[si] != '\0' && di + 1 < dstlen; si++) {
    char c = src[si];
    if (c == '"' || c == '\\') {
      if (di + 2 < dstlen) {
        dst[di++] = '\\';
        dst[di++] = c;
      }
    } else if (c >= 0 && c < 0x20) {
      if (di + 6 < dstlen) {
        dst[di++] = '\\';
        dst[di++] = 'u';
        dst[di++] = '0';
        dst[di++] = '0';
        dst[di++] = "0123456789ABCDEF"[(c >> 4) & 0xF];
        dst[di++] = "0123456789ABCDEF"[c & 0xF];
      }
    } else {
      dst[di++] = c;
    }
  }
  dst[di] = '\0';
}

static void
safe_strcpy(char *dst, const char *src, int dstlen)
{
  int len = 0;
  while (src[len] != '\0' && len < dstlen - 1) {
    dst[len] = src[len];
    len++;
  }
  dst[len] = '\0';
}

int
main(void)
{
  static struct cpu_info cpus[NCPU];
  static struct proc_stats stats;
  static struct sched_event events[MAX_HISTORY_EVENTS];
  int n = getcpuinfo(cpus, NCPU);

  if (n < 0) {
    printf("getcpuinfo failed\n");
    exit(1);
  }

  if (getprocstats(&stats) < 0) {
    printf("getprocstats failed\n");
    exit(1);
  }

  static int history_count[NCPU];
  static struct {
    int pid;
    char name[PROC_NAME_LEN];
  } history[NCPU][MAX_HISTORY_EVENTS];

  for (int i = 0; i < NCPU; i++) {
    history_count[i] = 0;
  }

  int events_read = schedread(events, MAX_HISTORY_EVENTS);
  for (int i = 0; i < events_read; i++) {
    int cpu = events[i].cpu;
    if (cpu < 0 || cpu >= NCPU)
      continue;

    if (events[i].event_type == SCHED_EV_ON_CPU || events[i].event_type == SCHED_EV_OFF_CPU) {
      if (history_count[cpu] < MAX_HISTORY_EVENTS) {
        history[cpu][history_count[cpu]].pid = events[i].pid;
        safe_strcpy(history[cpu][history_count[cpu]].name,
                   events[i].name,
                   sizeof(history[cpu][history_count[cpu]].name));
        history_count[cpu]++;
      }
    }
  }

  int active_count = 0;
  int total_busy = 0;
  for (int i = 0; i < n; i++) {
    if (cpus[i].active)
      active_count++;
    total_busy += cpus[i].busy_percent;
  }

  int total_cpu_usage = n > 0 ? total_busy / n : 0;

  printf("{\"CPU\":{");
  printf("\"timestamp\":\"%d\",", uptime());
  printf("\"system\":{");
  printf("\"total_cpu_usage\":%d,", total_cpu_usage);
  printf("\"total_created\":%lu,", stats.total_created);
  printf("\"total_exited\":%lu,", stats.total_exited);
  printf("\"ever_running\":%lu,", stats.unique_count[RUNNING]);
  printf("\"ever_sleeping\":%lu,", stats.unique_count[SLEEPING]);
  printf("\"ever_zombie\":%lu", stats.unique_count[ZOMBIE]);
  printf("},");

  printf("\"cpus\":[");
  for (int i = 0; i < n; i++) {
    char current_name[PROC_NAME_LEN * 2];
    escape_json_string(cpus[i].current_name, current_name, sizeof(current_name));
    char current_process[MAX_HISTORY_NAME_LEN];
    char current_process_json[MAX_HISTORY_NAME_LEN * 2];
    if (cpus[i].current_pid > 0) {
      safe_strcpy(current_process, "pid ", sizeof(current_process));
      int len = strlen(current_process);
      int current_pid = cpus[i].current_pid;
      if (len < sizeof(current_process) - 1) {
        if (current_pid < 0) {
          current_process[len++] = '-';
          current_pid = -current_pid;
        }
        int pid = current_pid;
        char pidbuf[16];
        int pi = 0;
        if (pid == 0) {
          pidbuf[pi++] = '0';
        } else {
          int value = pid;
          char temp[16];
          int ti = 0;
          while (value > 0 && ti < (int)sizeof(temp)) {
            temp[ti++] = '0' + (value % 10);
            value /= 10;
          }
          while (ti > 0) {
            pidbuf[pi++] = temp[--ti];
          }
        }
        pidbuf[pi] = '\0';
        if (len + pi + 4 < sizeof(current_process)) {
          memmove(current_process + len, pidbuf, pi + 1);
          len += pi;
          current_process[len++] = ' ';
          current_process[len++] = '(';
          int remain = sizeof(current_process) - len - 2;
          if (remain > 0) {
            int copy_len = strlen(current_name);
            if (copy_len > remain)
              copy_len = remain;
            memmove(current_process + len, current_name, copy_len);
            len += copy_len;
          }
          if (len < sizeof(current_process) - 1) {
            current_process[len++] = ')';
          }
        }
      }
      current_process[len] = '\0';
    } else {
      safe_strcpy(current_process, "idle", sizeof(current_process));
    }
    escape_json_string(current_process, current_process_json, sizeof(current_process_json));

    if (i > 0)
      printf(",");
    printf("{\"cpu_id\":\"cpu%d\",", cpus[i].cpu);
    printf("\"cpu\":%d,", cpus[i].cpu);
    printf("\"state\":\"%s\",", cpus[i].active ? "Active" : "Idle");
    printf("\"active\":%d,", cpus[i].active);
    printf("\"current_pid\":%d,", cpus[i].current_pid);
    printf("\"current_name\":\"%s\",", current_name);
    printf("\"current_process\":\"%s\",", current_process_json);
    printf("\"current_state\":\"%s\",", cpus[i].current_state >= 0 && cpus[i].current_state < PROC_STATE_COUNT ? state_names[cpus[i].current_state] : "UNKNOWN");
    printf("\"last_pid\":%d,", cpus[i].last_pid);
    printf("\"last_state\":\"%s\",", cpus[i].last_state >= 0 && cpus[i].last_state < PROC_STATE_COUNT ? state_names[cpus[i].last_state] : "UNKNOWN");
    printf("\"busy_percent\":%d,", cpus[i].busy_percent);
    printf("\"active_ticks\":%lu,", cpus[i].active_ticks);
    printf("\"timeline\":[");
    for (int j = 0; j < history_count[cpus[i].cpu]; j++) {
      if (j > 0)
        printf(",");
      char timeline_name[PROC_NAME_LEN * 2];
      escape_json_string(history[cpus[i].cpu][j].name, timeline_name, sizeof(timeline_name));
      printf("\"pid %d (%s)\"", history[cpus[i].cpu][j].pid, timeline_name);
    }
    printf("}]");
  }
  printf("]}}");
  printf("\n");

  exit(0);
}
