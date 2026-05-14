
user/_cpuinfo:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
  "UNUSED", "USED", "SLEEPING", "RUNNABLE", "RUNNING", "ZOMBIE"
};

int
main(void)
{
   0:	df010113          	addi	sp,sp,-528
   4:	20113423          	sd	ra,520(sp)
   8:	20813023          	sd	s0,512(sp)
   c:	f7ce                	sd	s3,488(sp)
   e:	0c00                	addi	s0,sp,528
  struct cpu_info cpus[NCPU];
  struct proc_stats stats;
  int n;

  n = getcpuinfo(cpus, NCPU);
  10:	45a1                	li	a1,8
  12:	e6040513          	addi	a0,s0,-416
  16:	422000ef          	jal	438 <getcpuinfo>
  if (n < 0 || getprocstats(&stats) < 0) {
  1a:	00054963          	bltz	a0,2c <main+0x2c>
  1e:	89aa                	mv	s3,a0
  20:	df040513          	addi	a0,s0,-528
  24:	41c000ef          	jal	440 <getprocstats>
  28:	02055363          	bgez	a0,4e <main+0x4e>
  2c:	ffa6                	sd	s1,504(sp)
  2e:	fbca                	sd	s2,496(sp)
  30:	f3d2                	sd	s4,480(sp)
  32:	efd6                	sd	s5,472(sp)
  34:	ebda                	sd	s6,464(sp)
  36:	e7de                	sd	s7,456(sp)
  38:	e3e2                	sd	s8,448(sp)
  3a:	ff66                	sd	s9,440(sp)
    printf("Error fetching system info\n");
  3c:	00001517          	auipc	a0,0x1
  40:	98c50513          	addi	a0,a0,-1652 # 9c8 <malloc+0x10c>
  44:	7c4000ef          	jal	808 <printf>
    exit(1);
  48:	4505                	li	a0,1
  4a:	366000ef          	jal	3b0 <exit>
  4e:	ffa6                	sd	s1,504(sp)
  50:	fbca                	sd	s2,496(sp)
  52:	f3d2                	sd	s4,480(sp)
  54:	efd6                	sd	s5,472(sp)
  56:	ebda                	sd	s6,464(sp)
  58:	e7de                	sd	s7,456(sp)
  5a:	e3e2                	sd	s8,448(sp)
  5c:	ff66                	sd	s9,440(sp)
  }

  printf("CPU {\"timestamp\":\"now\",\"system\":{");
  5e:	00001517          	auipc	a0,0x1
  62:	98a50513          	addi	a0,a0,-1654 # 9e8 <malloc+0x12c>
  66:	7a2000ef          	jal	808 <printf>
  printf("\"total_created\":%lu,\"total_exited\":%lu,", stats.total_created, stats.total_exited);
  6a:	e5843603          	ld	a2,-424(s0)
  6e:	e5043583          	ld	a1,-432(s0)
  72:	00001517          	auipc	a0,0x1
  76:	99e50513          	addi	a0,a0,-1634 # a10 <malloc+0x154>
  7a:	78e000ef          	jal	808 <printf>
  printf("\"ever_running\":%lu,\"ever_sleeping\":%lu,\"ever_zombie\":%lu},", 
  7e:	e4843683          	ld	a3,-440(s0)
  82:	e3043603          	ld	a2,-464(s0)
  86:	e4043583          	ld	a1,-448(s0)
  8a:	00001517          	auipc	a0,0x1
  8e:	9ae50513          	addi	a0,a0,-1618 # a38 <malloc+0x17c>
  92:	776000ef          	jal	808 <printf>
          stats.unique_count[4], stats.unique_count[2], stats.unique_count[5]);

  printf("\"cpus\":[");
  96:	00001517          	auipc	a0,0x1
  9a:	9e250513          	addi	a0,a0,-1566 # a78 <malloc+0x1bc>
  9e:	76a000ef          	jal	808 <printf>
  for (int i = 0; i < n; i++) {
  a2:	07305463          	blez	s3,10a <main+0x10a>
  a6:	e6040493          	addi	s1,s0,-416
  aa:	4901                	li	s2,0
    printf("{\"cpu_id\":\"cpu%d\",\"active\":%d,\"current_pid\":%d,\"current_state\":\"%s\",\"busy_percent\":%d}",
  ac:	4b95                	li	s7,5
  ae:	00001b17          	auipc	s6,0x1
  b2:	912b0b13          	addi	s6,s6,-1774 # 9c0 <malloc+0x104>
  b6:	00001c17          	auipc	s8,0x1
  ba:	a82c0c13          	addi	s8,s8,-1406 # b38 <state_names>
  be:	00001a97          	auipc	s5,0x1
  c2:	9caa8a93          	addi	s5,s5,-1590 # a88 <malloc+0x1cc>
           cpus[i].cpu, cpus[i].active, cpus[i].current_pid,
           cpus[i].current_state < PROC_STATE_COUNT ? state_names[cpus[i].current_state] : "UNK",
           cpus[i].busy_percent);
    
    if (i < n - 1) printf(",");
  c6:	fff98a1b          	addiw	s4,s3,-1
  ca:	00001c97          	auipc	s9,0x1
  ce:	a16c8c93          	addi	s9,s9,-1514 # ae0 <malloc+0x224>
  d2:	a821                	j	ea <main+0xea>
    printf("{\"cpu_id\":\"cpu%d\",\"active\":%d,\"current_pid\":%d,\"current_state\":\"%s\",\"busy_percent\":%d}",
  d4:	511c                	lw	a5,32(a0)
  d6:	8556                	mv	a0,s5
  d8:	730000ef          	jal	808 <printf>
    if (i < n - 1) printf(",");
  dc:	03494363          	blt	s2,s4,102 <main+0x102>
  for (int i = 0; i < n; i++) {
  e0:	2905                	addiw	s2,s2,1
  e2:	02848493          	addi	s1,s1,40
  e6:	03298263          	beq	s3,s2,10a <main+0x10a>
    printf("{\"cpu_id\":\"cpu%d\",\"active\":%d,\"current_pid\":%d,\"current_state\":\"%s\",\"busy_percent\":%d}",
  ea:	8526                	mv	a0,s1
  ec:	408c                	lw	a1,0(s1)
  ee:	40d0                	lw	a2,4(s1)
  f0:	4494                	lw	a3,8(s1)
           cpus[i].current_state < PROC_STATE_COUNT ? state_names[cpus[i].current_state] : "UNK",
  f2:	44dc                	lw	a5,12(s1)
    printf("{\"cpu_id\":\"cpu%d\",\"active\":%d,\"current_pid\":%d,\"current_state\":\"%s\",\"busy_percent\":%d}",
  f4:	875a                	mv	a4,s6
  f6:	fcfbcfe3          	blt	s7,a5,d4 <main+0xd4>
  fa:	078e                	slli	a5,a5,0x3
  fc:	97e2                	add	a5,a5,s8
  fe:	6398                	ld	a4,0(a5)
 100:	bfd1                	j	d4 <main+0xd4>
    if (i < n - 1) printf(",");
 102:	8566                	mv	a0,s9
 104:	704000ef          	jal	808 <printf>
 108:	bfe1                	j	e0 <main+0xe0>
  }
  printf("]}\n");
 10a:	00001517          	auipc	a0,0x1
 10e:	9de50513          	addi	a0,a0,-1570 # ae8 <malloc+0x22c>
 112:	6f6000ef          	jal	808 <printf>

  exit(0);
 116:	4501                	li	a0,0
 118:	298000ef          	jal	3b0 <exit>

000000000000011c <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start(int argc, char **argv)
{
 11c:	1141                	addi	sp,sp,-16
 11e:	e406                	sd	ra,8(sp)
 120:	e022                	sd	s0,0(sp)
 122:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
 124:	eddff0ef          	jal	0 <main>
  exit(r);
 128:	288000ef          	jal	3b0 <exit>

000000000000012c <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 12c:	1141                	addi	sp,sp,-16
 12e:	e422                	sd	s0,8(sp)
 130:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 132:	87aa                	mv	a5,a0
 134:	0585                	addi	a1,a1,1
 136:	0785                	addi	a5,a5,1
 138:	fff5c703          	lbu	a4,-1(a1)
 13c:	fee78fa3          	sb	a4,-1(a5)
 140:	fb75                	bnez	a4,134 <strcpy+0x8>
    ;
  return os;
}
 142:	6422                	ld	s0,8(sp)
 144:	0141                	addi	sp,sp,16
 146:	8082                	ret

0000000000000148 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 148:	1141                	addi	sp,sp,-16
 14a:	e422                	sd	s0,8(sp)
 14c:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 14e:	00054783          	lbu	a5,0(a0)
 152:	cb91                	beqz	a5,166 <strcmp+0x1e>
 154:	0005c703          	lbu	a4,0(a1)
 158:	00f71763          	bne	a4,a5,166 <strcmp+0x1e>
    p++, q++;
 15c:	0505                	addi	a0,a0,1
 15e:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 160:	00054783          	lbu	a5,0(a0)
 164:	fbe5                	bnez	a5,154 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 166:	0005c503          	lbu	a0,0(a1)
}
 16a:	40a7853b          	subw	a0,a5,a0
 16e:	6422                	ld	s0,8(sp)
 170:	0141                	addi	sp,sp,16
 172:	8082                	ret

0000000000000174 <strlen>:

uint
strlen(const char *s)
{
 174:	1141                	addi	sp,sp,-16
 176:	e422                	sd	s0,8(sp)
 178:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 17a:	00054783          	lbu	a5,0(a0)
 17e:	cf91                	beqz	a5,19a <strlen+0x26>
 180:	0505                	addi	a0,a0,1
 182:	87aa                	mv	a5,a0
 184:	86be                	mv	a3,a5
 186:	0785                	addi	a5,a5,1
 188:	fff7c703          	lbu	a4,-1(a5)
 18c:	ff65                	bnez	a4,184 <strlen+0x10>
 18e:	40a6853b          	subw	a0,a3,a0
 192:	2505                	addiw	a0,a0,1
    ;
  return n;
}
 194:	6422                	ld	s0,8(sp)
 196:	0141                	addi	sp,sp,16
 198:	8082                	ret
  for(n = 0; s[n]; n++)
 19a:	4501                	li	a0,0
 19c:	bfe5                	j	194 <strlen+0x20>

000000000000019e <memset>:

void*
memset(void *dst, int c, uint n)
{
 19e:	1141                	addi	sp,sp,-16
 1a0:	e422                	sd	s0,8(sp)
 1a2:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 1a4:	ca19                	beqz	a2,1ba <memset+0x1c>
 1a6:	87aa                	mv	a5,a0
 1a8:	1602                	slli	a2,a2,0x20
 1aa:	9201                	srli	a2,a2,0x20
 1ac:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 1b0:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 1b4:	0785                	addi	a5,a5,1
 1b6:	fee79de3          	bne	a5,a4,1b0 <memset+0x12>
  }
  return dst;
}
 1ba:	6422                	ld	s0,8(sp)
 1bc:	0141                	addi	sp,sp,16
 1be:	8082                	ret

00000000000001c0 <strchr>:

char*
strchr(const char *s, char c)
{
 1c0:	1141                	addi	sp,sp,-16
 1c2:	e422                	sd	s0,8(sp)
 1c4:	0800                	addi	s0,sp,16
  for(; *s; s++)
 1c6:	00054783          	lbu	a5,0(a0)
 1ca:	cb99                	beqz	a5,1e0 <strchr+0x20>
    if(*s == c)
 1cc:	00f58763          	beq	a1,a5,1da <strchr+0x1a>
  for(; *s; s++)
 1d0:	0505                	addi	a0,a0,1
 1d2:	00054783          	lbu	a5,0(a0)
 1d6:	fbfd                	bnez	a5,1cc <strchr+0xc>
      return (char*)s;
  return 0;
 1d8:	4501                	li	a0,0
}
 1da:	6422                	ld	s0,8(sp)
 1dc:	0141                	addi	sp,sp,16
 1de:	8082                	ret
  return 0;
 1e0:	4501                	li	a0,0
 1e2:	bfe5                	j	1da <strchr+0x1a>

00000000000001e4 <gets>:

char*
gets(char *buf, int max)
{
 1e4:	711d                	addi	sp,sp,-96
 1e6:	ec86                	sd	ra,88(sp)
 1e8:	e8a2                	sd	s0,80(sp)
 1ea:	e4a6                	sd	s1,72(sp)
 1ec:	e0ca                	sd	s2,64(sp)
 1ee:	fc4e                	sd	s3,56(sp)
 1f0:	f852                	sd	s4,48(sp)
 1f2:	f456                	sd	s5,40(sp)
 1f4:	f05a                	sd	s6,32(sp)
 1f6:	ec5e                	sd	s7,24(sp)
 1f8:	1080                	addi	s0,sp,96
 1fa:	8baa                	mv	s7,a0
 1fc:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 1fe:	892a                	mv	s2,a0
 200:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 202:	4aa9                	li	s5,10
 204:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 206:	89a6                	mv	s3,s1
 208:	2485                	addiw	s1,s1,1
 20a:	0344d663          	bge	s1,s4,236 <gets+0x52>
    cc = read(0, &c, 1);
 20e:	4605                	li	a2,1
 210:	faf40593          	addi	a1,s0,-81
 214:	4501                	li	a0,0
 216:	1b2000ef          	jal	3c8 <read>
    if(cc < 1)
 21a:	00a05e63          	blez	a0,236 <gets+0x52>
    buf[i++] = c;
 21e:	faf44783          	lbu	a5,-81(s0)
 222:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 226:	01578763          	beq	a5,s5,234 <gets+0x50>
 22a:	0905                	addi	s2,s2,1
 22c:	fd679de3          	bne	a5,s6,206 <gets+0x22>
    buf[i++] = c;
 230:	89a6                	mv	s3,s1
 232:	a011                	j	236 <gets+0x52>
 234:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 236:	99de                	add	s3,s3,s7
 238:	00098023          	sb	zero,0(s3)
  return buf;
}
 23c:	855e                	mv	a0,s7
 23e:	60e6                	ld	ra,88(sp)
 240:	6446                	ld	s0,80(sp)
 242:	64a6                	ld	s1,72(sp)
 244:	6906                	ld	s2,64(sp)
 246:	79e2                	ld	s3,56(sp)
 248:	7a42                	ld	s4,48(sp)
 24a:	7aa2                	ld	s5,40(sp)
 24c:	7b02                	ld	s6,32(sp)
 24e:	6be2                	ld	s7,24(sp)
 250:	6125                	addi	sp,sp,96
 252:	8082                	ret

0000000000000254 <stat>:

int
stat(const char *n, struct stat *st)
{
 254:	1101                	addi	sp,sp,-32
 256:	ec06                	sd	ra,24(sp)
 258:	e822                	sd	s0,16(sp)
 25a:	e04a                	sd	s2,0(sp)
 25c:	1000                	addi	s0,sp,32
 25e:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 260:	4581                	li	a1,0
 262:	18e000ef          	jal	3f0 <open>
  if(fd < 0)
 266:	02054263          	bltz	a0,28a <stat+0x36>
 26a:	e426                	sd	s1,8(sp)
 26c:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 26e:	85ca                	mv	a1,s2
 270:	198000ef          	jal	408 <fstat>
 274:	892a                	mv	s2,a0
  close(fd);
 276:	8526                	mv	a0,s1
 278:	160000ef          	jal	3d8 <close>
  return r;
 27c:	64a2                	ld	s1,8(sp)
}
 27e:	854a                	mv	a0,s2
 280:	60e2                	ld	ra,24(sp)
 282:	6442                	ld	s0,16(sp)
 284:	6902                	ld	s2,0(sp)
 286:	6105                	addi	sp,sp,32
 288:	8082                	ret
    return -1;
 28a:	597d                	li	s2,-1
 28c:	bfcd                	j	27e <stat+0x2a>

000000000000028e <atoi>:

int
atoi(const char *s)
{
 28e:	1141                	addi	sp,sp,-16
 290:	e422                	sd	s0,8(sp)
 292:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 294:	00054683          	lbu	a3,0(a0)
 298:	fd06879b          	addiw	a5,a3,-48
 29c:	0ff7f793          	zext.b	a5,a5
 2a0:	4625                	li	a2,9
 2a2:	02f66863          	bltu	a2,a5,2d2 <atoi+0x44>
 2a6:	872a                	mv	a4,a0
  n = 0;
 2a8:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 2aa:	0705                	addi	a4,a4,1
 2ac:	0025179b          	slliw	a5,a0,0x2
 2b0:	9fa9                	addw	a5,a5,a0
 2b2:	0017979b          	slliw	a5,a5,0x1
 2b6:	9fb5                	addw	a5,a5,a3
 2b8:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 2bc:	00074683          	lbu	a3,0(a4)
 2c0:	fd06879b          	addiw	a5,a3,-48
 2c4:	0ff7f793          	zext.b	a5,a5
 2c8:	fef671e3          	bgeu	a2,a5,2aa <atoi+0x1c>
  return n;
}
 2cc:	6422                	ld	s0,8(sp)
 2ce:	0141                	addi	sp,sp,16
 2d0:	8082                	ret
  n = 0;
 2d2:	4501                	li	a0,0
 2d4:	bfe5                	j	2cc <atoi+0x3e>

00000000000002d6 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 2d6:	1141                	addi	sp,sp,-16
 2d8:	e422                	sd	s0,8(sp)
 2da:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 2dc:	02b57463          	bgeu	a0,a1,304 <memmove+0x2e>
    while(n-- > 0)
 2e0:	00c05f63          	blez	a2,2fe <memmove+0x28>
 2e4:	1602                	slli	a2,a2,0x20
 2e6:	9201                	srli	a2,a2,0x20
 2e8:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 2ec:	872a                	mv	a4,a0
      *dst++ = *src++;
 2ee:	0585                	addi	a1,a1,1
 2f0:	0705                	addi	a4,a4,1
 2f2:	fff5c683          	lbu	a3,-1(a1)
 2f6:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 2fa:	fef71ae3          	bne	a4,a5,2ee <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 2fe:	6422                	ld	s0,8(sp)
 300:	0141                	addi	sp,sp,16
 302:	8082                	ret
    dst += n;
 304:	00c50733          	add	a4,a0,a2
    src += n;
 308:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 30a:	fec05ae3          	blez	a2,2fe <memmove+0x28>
 30e:	fff6079b          	addiw	a5,a2,-1
 312:	1782                	slli	a5,a5,0x20
 314:	9381                	srli	a5,a5,0x20
 316:	fff7c793          	not	a5,a5
 31a:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 31c:	15fd                	addi	a1,a1,-1
 31e:	177d                	addi	a4,a4,-1
 320:	0005c683          	lbu	a3,0(a1)
 324:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 328:	fee79ae3          	bne	a5,a4,31c <memmove+0x46>
 32c:	bfc9                	j	2fe <memmove+0x28>

000000000000032e <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 32e:	1141                	addi	sp,sp,-16
 330:	e422                	sd	s0,8(sp)
 332:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 334:	ca05                	beqz	a2,364 <memcmp+0x36>
 336:	fff6069b          	addiw	a3,a2,-1
 33a:	1682                	slli	a3,a3,0x20
 33c:	9281                	srli	a3,a3,0x20
 33e:	0685                	addi	a3,a3,1
 340:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 342:	00054783          	lbu	a5,0(a0)
 346:	0005c703          	lbu	a4,0(a1)
 34a:	00e79863          	bne	a5,a4,35a <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 34e:	0505                	addi	a0,a0,1
    p2++;
 350:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 352:	fed518e3          	bne	a0,a3,342 <memcmp+0x14>
  }
  return 0;
 356:	4501                	li	a0,0
 358:	a019                	j	35e <memcmp+0x30>
      return *p1 - *p2;
 35a:	40e7853b          	subw	a0,a5,a4
}
 35e:	6422                	ld	s0,8(sp)
 360:	0141                	addi	sp,sp,16
 362:	8082                	ret
  return 0;
 364:	4501                	li	a0,0
 366:	bfe5                	j	35e <memcmp+0x30>

0000000000000368 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 368:	1141                	addi	sp,sp,-16
 36a:	e406                	sd	ra,8(sp)
 36c:	e022                	sd	s0,0(sp)
 36e:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 370:	f67ff0ef          	jal	2d6 <memmove>
}
 374:	60a2                	ld	ra,8(sp)
 376:	6402                	ld	s0,0(sp)
 378:	0141                	addi	sp,sp,16
 37a:	8082                	ret

000000000000037c <sbrk>:

char *
sbrk(int n) {
 37c:	1141                	addi	sp,sp,-16
 37e:	e406                	sd	ra,8(sp)
 380:	e022                	sd	s0,0(sp)
 382:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
 384:	4585                	li	a1,1
 386:	0c2000ef          	jal	448 <sys_sbrk>
}
 38a:	60a2                	ld	ra,8(sp)
 38c:	6402                	ld	s0,0(sp)
 38e:	0141                	addi	sp,sp,16
 390:	8082                	ret

0000000000000392 <sbrklazy>:

char *
sbrklazy(int n) {
 392:	1141                	addi	sp,sp,-16
 394:	e406                	sd	ra,8(sp)
 396:	e022                	sd	s0,0(sp)
 398:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 39a:	4589                	li	a1,2
 39c:	0ac000ef          	jal	448 <sys_sbrk>
}
 3a0:	60a2                	ld	ra,8(sp)
 3a2:	6402                	ld	s0,0(sp)
 3a4:	0141                	addi	sp,sp,16
 3a6:	8082                	ret

00000000000003a8 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 3a8:	4885                	li	a7,1
 ecall
 3aa:	00000073          	ecall
 ret
 3ae:	8082                	ret

00000000000003b0 <exit>:
.global exit
exit:
 li a7, SYS_exit
 3b0:	4889                	li	a7,2
 ecall
 3b2:	00000073          	ecall
 ret
 3b6:	8082                	ret

00000000000003b8 <wait>:
.global wait
wait:
 li a7, SYS_wait
 3b8:	488d                	li	a7,3
 ecall
 3ba:	00000073          	ecall
 ret
 3be:	8082                	ret

00000000000003c0 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 3c0:	4891                	li	a7,4
 ecall
 3c2:	00000073          	ecall
 ret
 3c6:	8082                	ret

00000000000003c8 <read>:
.global read
read:
 li a7, SYS_read
 3c8:	4895                	li	a7,5
 ecall
 3ca:	00000073          	ecall
 ret
 3ce:	8082                	ret

00000000000003d0 <write>:
.global write
write:
 li a7, SYS_write
 3d0:	48c1                	li	a7,16
 ecall
 3d2:	00000073          	ecall
 ret
 3d6:	8082                	ret

00000000000003d8 <close>:
.global close
close:
 li a7, SYS_close
 3d8:	48d5                	li	a7,21
 ecall
 3da:	00000073          	ecall
 ret
 3de:	8082                	ret

00000000000003e0 <kill>:
.global kill
kill:
 li a7, SYS_kill
 3e0:	4899                	li	a7,6
 ecall
 3e2:	00000073          	ecall
 ret
 3e6:	8082                	ret

00000000000003e8 <exec>:
.global exec
exec:
 li a7, SYS_exec
 3e8:	489d                	li	a7,7
 ecall
 3ea:	00000073          	ecall
 ret
 3ee:	8082                	ret

00000000000003f0 <open>:
.global open
open:
 li a7, SYS_open
 3f0:	48bd                	li	a7,15
 ecall
 3f2:	00000073          	ecall
 ret
 3f6:	8082                	ret

00000000000003f8 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 3f8:	48c5                	li	a7,17
 ecall
 3fa:	00000073          	ecall
 ret
 3fe:	8082                	ret

0000000000000400 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 400:	48c9                	li	a7,18
 ecall
 402:	00000073          	ecall
 ret
 406:	8082                	ret

0000000000000408 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 408:	48a1                	li	a7,8
 ecall
 40a:	00000073          	ecall
 ret
 40e:	8082                	ret

0000000000000410 <link>:
.global link
link:
 li a7, SYS_link
 410:	48cd                	li	a7,19
 ecall
 412:	00000073          	ecall
 ret
 416:	8082                	ret

0000000000000418 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 418:	48d1                	li	a7,20
 ecall
 41a:	00000073          	ecall
 ret
 41e:	8082                	ret

0000000000000420 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 420:	48a5                	li	a7,9
 ecall
 422:	00000073          	ecall
 ret
 426:	8082                	ret

0000000000000428 <dup>:
.global dup
dup:
 li a7, SYS_dup
 428:	48a9                	li	a7,10
 ecall
 42a:	00000073          	ecall
 ret
 42e:	8082                	ret

0000000000000430 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 430:	48ad                	li	a7,11
 ecall
 432:	00000073          	ecall
 ret
 436:	8082                	ret

0000000000000438 <getcpuinfo>:
.global getcpuinfo
getcpuinfo:
 li a7, SYS_getcpuinfo
 438:	48e9                	li	a7,26
 ecall
 43a:	00000073          	ecall
 ret
 43e:	8082                	ret

0000000000000440 <getprocstats>:
.global getprocstats
getprocstats:
 li a7, SYS_getprocstats
 440:	48ed                	li	a7,27
 ecall
 442:	00000073          	ecall
 ret
 446:	8082                	ret

0000000000000448 <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 448:	48b1                	li	a7,12
 ecall
 44a:	00000073          	ecall
 ret
 44e:	8082                	ret

0000000000000450 <pause>:
.global pause
pause:
 li a7, SYS_pause
 450:	48b5                	li	a7,13
 ecall
 452:	00000073          	ecall
 ret
 456:	8082                	ret

0000000000000458 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 458:	48b9                	li	a7,14
 ecall
 45a:	00000073          	ecall
 ret
 45e:	8082                	ret

0000000000000460 <csread>:
.global csread
csread:
 li a7, SYS_csread
 460:	48d9                	li	a7,22
 ecall
 462:	00000073          	ecall
 ret
 466:	8082                	ret

0000000000000468 <fsread>:
.global fsread
fsread:
 li a7, SYS_fsread
 468:	48dd                	li	a7,23
 ecall
 46a:	00000073          	ecall
 ret
 46e:	8082                	ret

0000000000000470 <schedread>:
.global schedread
schedread:
 li a7, SYS_schedread
 470:	48e1                	li	a7,24
 ecall
 472:	00000073          	ecall
 ret
 476:	8082                	ret

0000000000000478 <memread>:
.global memread
memread:
 li a7, SYS_memread
 478:	48e5                	li	a7,25
 ecall
 47a:	00000073          	ecall
 ret
 47e:	8082                	ret

0000000000000480 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 480:	1101                	addi	sp,sp,-32
 482:	ec06                	sd	ra,24(sp)
 484:	e822                	sd	s0,16(sp)
 486:	1000                	addi	s0,sp,32
 488:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 48c:	4605                	li	a2,1
 48e:	fef40593          	addi	a1,s0,-17
 492:	f3fff0ef          	jal	3d0 <write>
}
 496:	60e2                	ld	ra,24(sp)
 498:	6442                	ld	s0,16(sp)
 49a:	6105                	addi	sp,sp,32
 49c:	8082                	ret

000000000000049e <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
 49e:	715d                	addi	sp,sp,-80
 4a0:	e486                	sd	ra,72(sp)
 4a2:	e0a2                	sd	s0,64(sp)
 4a4:	f84a                	sd	s2,48(sp)
 4a6:	0880                	addi	s0,sp,80
 4a8:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
 4aa:	c299                	beqz	a3,4b0 <printint+0x12>
 4ac:	0805c363          	bltz	a1,532 <printint+0x94>
  neg = 0;
 4b0:	4881                	li	a7,0
 4b2:	fb840693          	addi	a3,s0,-72
    x = -xx;
  } else {
    x = xx;
  }

  i = 0;
 4b6:	4781                	li	a5,0
  do{
    buf[i++] = digits[x % base];
 4b8:	00000517          	auipc	a0,0x0
 4bc:	6b050513          	addi	a0,a0,1712 # b68 <digits>
 4c0:	883e                	mv	a6,a5
 4c2:	2785                	addiw	a5,a5,1
 4c4:	02c5f733          	remu	a4,a1,a2
 4c8:	972a                	add	a4,a4,a0
 4ca:	00074703          	lbu	a4,0(a4)
 4ce:	00e68023          	sb	a4,0(a3)
  }while((x /= base) != 0);
 4d2:	872e                	mv	a4,a1
 4d4:	02c5d5b3          	divu	a1,a1,a2
 4d8:	0685                	addi	a3,a3,1
 4da:	fec773e3          	bgeu	a4,a2,4c0 <printint+0x22>
  if(neg)
 4de:	00088b63          	beqz	a7,4f4 <printint+0x56>
    buf[i++] = '-';
 4e2:	fd078793          	addi	a5,a5,-48
 4e6:	97a2                	add	a5,a5,s0
 4e8:	02d00713          	li	a4,45
 4ec:	fee78423          	sb	a4,-24(a5)
 4f0:	0028079b          	addiw	a5,a6,2

  while(--i >= 0)
 4f4:	02f05a63          	blez	a5,528 <printint+0x8a>
 4f8:	fc26                	sd	s1,56(sp)
 4fa:	f44e                	sd	s3,40(sp)
 4fc:	fb840713          	addi	a4,s0,-72
 500:	00f704b3          	add	s1,a4,a5
 504:	fff70993          	addi	s3,a4,-1
 508:	99be                	add	s3,s3,a5
 50a:	37fd                	addiw	a5,a5,-1
 50c:	1782                	slli	a5,a5,0x20
 50e:	9381                	srli	a5,a5,0x20
 510:	40f989b3          	sub	s3,s3,a5
    putc(fd, buf[i]);
 514:	fff4c583          	lbu	a1,-1(s1)
 518:	854a                	mv	a0,s2
 51a:	f67ff0ef          	jal	480 <putc>
  while(--i >= 0)
 51e:	14fd                	addi	s1,s1,-1
 520:	ff349ae3          	bne	s1,s3,514 <printint+0x76>
 524:	74e2                	ld	s1,56(sp)
 526:	79a2                	ld	s3,40(sp)
}
 528:	60a6                	ld	ra,72(sp)
 52a:	6406                	ld	s0,64(sp)
 52c:	7942                	ld	s2,48(sp)
 52e:	6161                	addi	sp,sp,80
 530:	8082                	ret
    x = -xx;
 532:	40b005b3          	neg	a1,a1
    neg = 1;
 536:	4885                	li	a7,1
    x = -xx;
 538:	bfad                	j	4b2 <printint+0x14>

000000000000053a <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 53a:	711d                	addi	sp,sp,-96
 53c:	ec86                	sd	ra,88(sp)
 53e:	e8a2                	sd	s0,80(sp)
 540:	e0ca                	sd	s2,64(sp)
 542:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 544:	0005c903          	lbu	s2,0(a1)
 548:	28090663          	beqz	s2,7d4 <vprintf+0x29a>
 54c:	e4a6                	sd	s1,72(sp)
 54e:	fc4e                	sd	s3,56(sp)
 550:	f852                	sd	s4,48(sp)
 552:	f456                	sd	s5,40(sp)
 554:	f05a                	sd	s6,32(sp)
 556:	ec5e                	sd	s7,24(sp)
 558:	e862                	sd	s8,16(sp)
 55a:	e466                	sd	s9,8(sp)
 55c:	8b2a                	mv	s6,a0
 55e:	8a2e                	mv	s4,a1
 560:	8bb2                	mv	s7,a2
  state = 0;
 562:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 564:	4481                	li	s1,0
 566:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 568:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 56c:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 570:	06c00c93          	li	s9,108
 574:	a005                	j	594 <vprintf+0x5a>
        putc(fd, c0);
 576:	85ca                	mv	a1,s2
 578:	855a                	mv	a0,s6
 57a:	f07ff0ef          	jal	480 <putc>
 57e:	a019                	j	584 <vprintf+0x4a>
    } else if(state == '%'){
 580:	03598263          	beq	s3,s5,5a4 <vprintf+0x6a>
  for(i = 0; fmt[i]; i++){
 584:	2485                	addiw	s1,s1,1
 586:	8726                	mv	a4,s1
 588:	009a07b3          	add	a5,s4,s1
 58c:	0007c903          	lbu	s2,0(a5)
 590:	22090a63          	beqz	s2,7c4 <vprintf+0x28a>
    c0 = fmt[i] & 0xff;
 594:	0009079b          	sext.w	a5,s2
    if(state == 0){
 598:	fe0994e3          	bnez	s3,580 <vprintf+0x46>
      if(c0 == '%'){
 59c:	fd579de3          	bne	a5,s5,576 <vprintf+0x3c>
        state = '%';
 5a0:	89be                	mv	s3,a5
 5a2:	b7cd                	j	584 <vprintf+0x4a>
      if(c0) c1 = fmt[i+1] & 0xff;
 5a4:	00ea06b3          	add	a3,s4,a4
 5a8:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
 5ac:	8636                	mv	a2,a3
      if(c1) c2 = fmt[i+2] & 0xff;
 5ae:	c681                	beqz	a3,5b6 <vprintf+0x7c>
 5b0:	9752                	add	a4,a4,s4
 5b2:	00274603          	lbu	a2,2(a4)
      if(c0 == 'd'){
 5b6:	05878363          	beq	a5,s8,5fc <vprintf+0xc2>
      } else if(c0 == 'l' && c1 == 'd'){
 5ba:	05978d63          	beq	a5,s9,614 <vprintf+0xda>
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if(c0 == 'u'){
 5be:	07500713          	li	a4,117
 5c2:	0ee78763          	beq	a5,a4,6b0 <vprintf+0x176>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if(c0 == 'x'){
 5c6:	07800713          	li	a4,120
 5ca:	12e78963          	beq	a5,a4,6fc <vprintf+0x1c2>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if(c0 == 'p'){
 5ce:	07000713          	li	a4,112
 5d2:	14e78e63          	beq	a5,a4,72e <vprintf+0x1f4>
        printptr(fd, va_arg(ap, uint64));
      } else if(c0 == 'c'){
 5d6:	06300713          	li	a4,99
 5da:	18e78e63          	beq	a5,a4,776 <vprintf+0x23c>
        putc(fd, va_arg(ap, uint32));
      } else if(c0 == 's'){
 5de:	07300713          	li	a4,115
 5e2:	1ae78463          	beq	a5,a4,78a <vprintf+0x250>
        if((s = va_arg(ap, char*)) == 0)
          s = "(null)";
        for(; *s; s++)
          putc(fd, *s);
      } else if(c0 == '%'){
 5e6:	02500713          	li	a4,37
 5ea:	04e79563          	bne	a5,a4,634 <vprintf+0xfa>
        putc(fd, '%');
 5ee:	02500593          	li	a1,37
 5f2:	855a                	mv	a0,s6
 5f4:	e8dff0ef          	jal	480 <putc>
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 5f8:	4981                	li	s3,0
 5fa:	b769                	j	584 <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 10, 1);
 5fc:	008b8913          	addi	s2,s7,8
 600:	4685                	li	a3,1
 602:	4629                	li	a2,10
 604:	000ba583          	lw	a1,0(s7)
 608:	855a                	mv	a0,s6
 60a:	e95ff0ef          	jal	49e <printint>
 60e:	8bca                	mv	s7,s2
      state = 0;
 610:	4981                	li	s3,0
 612:	bf8d                	j	584 <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'd'){
 614:	06400793          	li	a5,100
 618:	02f68963          	beq	a3,a5,64a <vprintf+0x110>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 61c:	06c00793          	li	a5,108
 620:	04f68263          	beq	a3,a5,664 <vprintf+0x12a>
      } else if(c0 == 'l' && c1 == 'u'){
 624:	07500793          	li	a5,117
 628:	0af68063          	beq	a3,a5,6c8 <vprintf+0x18e>
      } else if(c0 == 'l' && c1 == 'x'){
 62c:	07800793          	li	a5,120
 630:	0ef68263          	beq	a3,a5,714 <vprintf+0x1da>
        putc(fd, '%');
 634:	02500593          	li	a1,37
 638:	855a                	mv	a0,s6
 63a:	e47ff0ef          	jal	480 <putc>
        putc(fd, c0);
 63e:	85ca                	mv	a1,s2
 640:	855a                	mv	a0,s6
 642:	e3fff0ef          	jal	480 <putc>
      state = 0;
 646:	4981                	li	s3,0
 648:	bf35                	j	584 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 64a:	008b8913          	addi	s2,s7,8
 64e:	4685                	li	a3,1
 650:	4629                	li	a2,10
 652:	000bb583          	ld	a1,0(s7)
 656:	855a                	mv	a0,s6
 658:	e47ff0ef          	jal	49e <printint>
        i += 1;
 65c:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 65e:	8bca                	mv	s7,s2
      state = 0;
 660:	4981                	li	s3,0
        i += 1;
 662:	b70d                	j	584 <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 664:	06400793          	li	a5,100
 668:	02f60763          	beq	a2,a5,696 <vprintf+0x15c>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 66c:	07500793          	li	a5,117
 670:	06f60963          	beq	a2,a5,6e2 <vprintf+0x1a8>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 674:	07800793          	li	a5,120
 678:	faf61ee3          	bne	a2,a5,634 <vprintf+0xfa>
        printint(fd, va_arg(ap, uint64), 16, 0);
 67c:	008b8913          	addi	s2,s7,8
 680:	4681                	li	a3,0
 682:	4641                	li	a2,16
 684:	000bb583          	ld	a1,0(s7)
 688:	855a                	mv	a0,s6
 68a:	e15ff0ef          	jal	49e <printint>
        i += 2;
 68e:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 690:	8bca                	mv	s7,s2
      state = 0;
 692:	4981                	li	s3,0
        i += 2;
 694:	bdc5                	j	584 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 696:	008b8913          	addi	s2,s7,8
 69a:	4685                	li	a3,1
 69c:	4629                	li	a2,10
 69e:	000bb583          	ld	a1,0(s7)
 6a2:	855a                	mv	a0,s6
 6a4:	dfbff0ef          	jal	49e <printint>
        i += 2;
 6a8:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 6aa:	8bca                	mv	s7,s2
      state = 0;
 6ac:	4981                	li	s3,0
        i += 2;
 6ae:	bdd9                	j	584 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint32), 10, 0);
 6b0:	008b8913          	addi	s2,s7,8
 6b4:	4681                	li	a3,0
 6b6:	4629                	li	a2,10
 6b8:	000be583          	lwu	a1,0(s7)
 6bc:	855a                	mv	a0,s6
 6be:	de1ff0ef          	jal	49e <printint>
 6c2:	8bca                	mv	s7,s2
      state = 0;
 6c4:	4981                	li	s3,0
 6c6:	bd7d                	j	584 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 6c8:	008b8913          	addi	s2,s7,8
 6cc:	4681                	li	a3,0
 6ce:	4629                	li	a2,10
 6d0:	000bb583          	ld	a1,0(s7)
 6d4:	855a                	mv	a0,s6
 6d6:	dc9ff0ef          	jal	49e <printint>
        i += 1;
 6da:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 6dc:	8bca                	mv	s7,s2
      state = 0;
 6de:	4981                	li	s3,0
        i += 1;
 6e0:	b555                	j	584 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 6e2:	008b8913          	addi	s2,s7,8
 6e6:	4681                	li	a3,0
 6e8:	4629                	li	a2,10
 6ea:	000bb583          	ld	a1,0(s7)
 6ee:	855a                	mv	a0,s6
 6f0:	dafff0ef          	jal	49e <printint>
        i += 2;
 6f4:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 6f6:	8bca                	mv	s7,s2
      state = 0;
 6f8:	4981                	li	s3,0
        i += 2;
 6fa:	b569                	j	584 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint32), 16, 0);
 6fc:	008b8913          	addi	s2,s7,8
 700:	4681                	li	a3,0
 702:	4641                	li	a2,16
 704:	000be583          	lwu	a1,0(s7)
 708:	855a                	mv	a0,s6
 70a:	d95ff0ef          	jal	49e <printint>
 70e:	8bca                	mv	s7,s2
      state = 0;
 710:	4981                	li	s3,0
 712:	bd8d                	j	584 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 16, 0);
 714:	008b8913          	addi	s2,s7,8
 718:	4681                	li	a3,0
 71a:	4641                	li	a2,16
 71c:	000bb583          	ld	a1,0(s7)
 720:	855a                	mv	a0,s6
 722:	d7dff0ef          	jal	49e <printint>
        i += 1;
 726:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 728:	8bca                	mv	s7,s2
      state = 0;
 72a:	4981                	li	s3,0
        i += 1;
 72c:	bda1                	j	584 <vprintf+0x4a>
 72e:	e06a                	sd	s10,0(sp)
        printptr(fd, va_arg(ap, uint64));
 730:	008b8d13          	addi	s10,s7,8
 734:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 738:	03000593          	li	a1,48
 73c:	855a                	mv	a0,s6
 73e:	d43ff0ef          	jal	480 <putc>
  putc(fd, 'x');
 742:	07800593          	li	a1,120
 746:	855a                	mv	a0,s6
 748:	d39ff0ef          	jal	480 <putc>
 74c:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 74e:	00000b97          	auipc	s7,0x0
 752:	41ab8b93          	addi	s7,s7,1050 # b68 <digits>
 756:	03c9d793          	srli	a5,s3,0x3c
 75a:	97de                	add	a5,a5,s7
 75c:	0007c583          	lbu	a1,0(a5)
 760:	855a                	mv	a0,s6
 762:	d1fff0ef          	jal	480 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 766:	0992                	slli	s3,s3,0x4
 768:	397d                	addiw	s2,s2,-1
 76a:	fe0916e3          	bnez	s2,756 <vprintf+0x21c>
        printptr(fd, va_arg(ap, uint64));
 76e:	8bea                	mv	s7,s10
      state = 0;
 770:	4981                	li	s3,0
 772:	6d02                	ld	s10,0(sp)
 774:	bd01                	j	584 <vprintf+0x4a>
        putc(fd, va_arg(ap, uint32));
 776:	008b8913          	addi	s2,s7,8
 77a:	000bc583          	lbu	a1,0(s7)
 77e:	855a                	mv	a0,s6
 780:	d01ff0ef          	jal	480 <putc>
 784:	8bca                	mv	s7,s2
      state = 0;
 786:	4981                	li	s3,0
 788:	bbf5                	j	584 <vprintf+0x4a>
        if((s = va_arg(ap, char*)) == 0)
 78a:	008b8993          	addi	s3,s7,8
 78e:	000bb903          	ld	s2,0(s7)
 792:	00090f63          	beqz	s2,7b0 <vprintf+0x276>
        for(; *s; s++)
 796:	00094583          	lbu	a1,0(s2)
 79a:	c195                	beqz	a1,7be <vprintf+0x284>
          putc(fd, *s);
 79c:	855a                	mv	a0,s6
 79e:	ce3ff0ef          	jal	480 <putc>
        for(; *s; s++)
 7a2:	0905                	addi	s2,s2,1
 7a4:	00094583          	lbu	a1,0(s2)
 7a8:	f9f5                	bnez	a1,79c <vprintf+0x262>
        if((s = va_arg(ap, char*)) == 0)
 7aa:	8bce                	mv	s7,s3
      state = 0;
 7ac:	4981                	li	s3,0
 7ae:	bbd9                	j	584 <vprintf+0x4a>
          s = "(null)";
 7b0:	00000917          	auipc	s2,0x0
 7b4:	38090913          	addi	s2,s2,896 # b30 <malloc+0x274>
        for(; *s; s++)
 7b8:	02800593          	li	a1,40
 7bc:	b7c5                	j	79c <vprintf+0x262>
        if((s = va_arg(ap, char*)) == 0)
 7be:	8bce                	mv	s7,s3
      state = 0;
 7c0:	4981                	li	s3,0
 7c2:	b3c9                	j	584 <vprintf+0x4a>
 7c4:	64a6                	ld	s1,72(sp)
 7c6:	79e2                	ld	s3,56(sp)
 7c8:	7a42                	ld	s4,48(sp)
 7ca:	7aa2                	ld	s5,40(sp)
 7cc:	7b02                	ld	s6,32(sp)
 7ce:	6be2                	ld	s7,24(sp)
 7d0:	6c42                	ld	s8,16(sp)
 7d2:	6ca2                	ld	s9,8(sp)
    }
  }
}
 7d4:	60e6                	ld	ra,88(sp)
 7d6:	6446                	ld	s0,80(sp)
 7d8:	6906                	ld	s2,64(sp)
 7da:	6125                	addi	sp,sp,96
 7dc:	8082                	ret

00000000000007de <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 7de:	715d                	addi	sp,sp,-80
 7e0:	ec06                	sd	ra,24(sp)
 7e2:	e822                	sd	s0,16(sp)
 7e4:	1000                	addi	s0,sp,32
 7e6:	e010                	sd	a2,0(s0)
 7e8:	e414                	sd	a3,8(s0)
 7ea:	e818                	sd	a4,16(s0)
 7ec:	ec1c                	sd	a5,24(s0)
 7ee:	03043023          	sd	a6,32(s0)
 7f2:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 7f6:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 7fa:	8622                	mv	a2,s0
 7fc:	d3fff0ef          	jal	53a <vprintf>
}
 800:	60e2                	ld	ra,24(sp)
 802:	6442                	ld	s0,16(sp)
 804:	6161                	addi	sp,sp,80
 806:	8082                	ret

0000000000000808 <printf>:

void
printf(const char *fmt, ...)
{
 808:	711d                	addi	sp,sp,-96
 80a:	ec06                	sd	ra,24(sp)
 80c:	e822                	sd	s0,16(sp)
 80e:	1000                	addi	s0,sp,32
 810:	e40c                	sd	a1,8(s0)
 812:	e810                	sd	a2,16(s0)
 814:	ec14                	sd	a3,24(s0)
 816:	f018                	sd	a4,32(s0)
 818:	f41c                	sd	a5,40(s0)
 81a:	03043823          	sd	a6,48(s0)
 81e:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 822:	00840613          	addi	a2,s0,8
 826:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 82a:	85aa                	mv	a1,a0
 82c:	4505                	li	a0,1
 82e:	d0dff0ef          	jal	53a <vprintf>
}
 832:	60e2                	ld	ra,24(sp)
 834:	6442                	ld	s0,16(sp)
 836:	6125                	addi	sp,sp,96
 838:	8082                	ret

000000000000083a <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 83a:	1141                	addi	sp,sp,-16
 83c:	e422                	sd	s0,8(sp)
 83e:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 840:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 844:	00000797          	auipc	a5,0x0
 848:	7bc7b783          	ld	a5,1980(a5) # 1000 <freep>
 84c:	a02d                	j	876 <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 84e:	4618                	lw	a4,8(a2)
 850:	9f2d                	addw	a4,a4,a1
 852:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 856:	6398                	ld	a4,0(a5)
 858:	6310                	ld	a2,0(a4)
 85a:	a83d                	j	898 <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 85c:	ff852703          	lw	a4,-8(a0)
 860:	9f31                	addw	a4,a4,a2
 862:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 864:	ff053683          	ld	a3,-16(a0)
 868:	a091                	j	8ac <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 86a:	6398                	ld	a4,0(a5)
 86c:	00e7e463          	bltu	a5,a4,874 <free+0x3a>
 870:	00e6ea63          	bltu	a3,a4,884 <free+0x4a>
{
 874:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 876:	fed7fae3          	bgeu	a5,a3,86a <free+0x30>
 87a:	6398                	ld	a4,0(a5)
 87c:	00e6e463          	bltu	a3,a4,884 <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 880:	fee7eae3          	bltu	a5,a4,874 <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 884:	ff852583          	lw	a1,-8(a0)
 888:	6390                	ld	a2,0(a5)
 88a:	02059813          	slli	a6,a1,0x20
 88e:	01c85713          	srli	a4,a6,0x1c
 892:	9736                	add	a4,a4,a3
 894:	fae60de3          	beq	a2,a4,84e <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 898:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 89c:	4790                	lw	a2,8(a5)
 89e:	02061593          	slli	a1,a2,0x20
 8a2:	01c5d713          	srli	a4,a1,0x1c
 8a6:	973e                	add	a4,a4,a5
 8a8:	fae68ae3          	beq	a3,a4,85c <free+0x22>
    p->s.ptr = bp->s.ptr;
 8ac:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 8ae:	00000717          	auipc	a4,0x0
 8b2:	74f73923          	sd	a5,1874(a4) # 1000 <freep>
}
 8b6:	6422                	ld	s0,8(sp)
 8b8:	0141                	addi	sp,sp,16
 8ba:	8082                	ret

00000000000008bc <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 8bc:	7139                	addi	sp,sp,-64
 8be:	fc06                	sd	ra,56(sp)
 8c0:	f822                	sd	s0,48(sp)
 8c2:	f426                	sd	s1,40(sp)
 8c4:	ec4e                	sd	s3,24(sp)
 8c6:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 8c8:	02051493          	slli	s1,a0,0x20
 8cc:	9081                	srli	s1,s1,0x20
 8ce:	04bd                	addi	s1,s1,15
 8d0:	8091                	srli	s1,s1,0x4
 8d2:	0014899b          	addiw	s3,s1,1
 8d6:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 8d8:	00000517          	auipc	a0,0x0
 8dc:	72853503          	ld	a0,1832(a0) # 1000 <freep>
 8e0:	c915                	beqz	a0,914 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8e2:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 8e4:	4798                	lw	a4,8(a5)
 8e6:	08977a63          	bgeu	a4,s1,97a <malloc+0xbe>
 8ea:	f04a                	sd	s2,32(sp)
 8ec:	e852                	sd	s4,16(sp)
 8ee:	e456                	sd	s5,8(sp)
 8f0:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 8f2:	8a4e                	mv	s4,s3
 8f4:	0009871b          	sext.w	a4,s3
 8f8:	6685                	lui	a3,0x1
 8fa:	00d77363          	bgeu	a4,a3,900 <malloc+0x44>
 8fe:	6a05                	lui	s4,0x1
 900:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 904:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 908:	00000917          	auipc	s2,0x0
 90c:	6f890913          	addi	s2,s2,1784 # 1000 <freep>
  if(p == SBRK_ERROR)
 910:	5afd                	li	s5,-1
 912:	a081                	j	952 <malloc+0x96>
 914:	f04a                	sd	s2,32(sp)
 916:	e852                	sd	s4,16(sp)
 918:	e456                	sd	s5,8(sp)
 91a:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 91c:	00000797          	auipc	a5,0x0
 920:	6f478793          	addi	a5,a5,1780 # 1010 <base>
 924:	00000717          	auipc	a4,0x0
 928:	6cf73e23          	sd	a5,1756(a4) # 1000 <freep>
 92c:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 92e:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 932:	b7c1                	j	8f2 <malloc+0x36>
        prevp->s.ptr = p->s.ptr;
 934:	6398                	ld	a4,0(a5)
 936:	e118                	sd	a4,0(a0)
 938:	a8a9                	j	992 <malloc+0xd6>
  hp->s.size = nu;
 93a:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 93e:	0541                	addi	a0,a0,16
 940:	efbff0ef          	jal	83a <free>
  return freep;
 944:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 948:	c12d                	beqz	a0,9aa <malloc+0xee>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 94a:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 94c:	4798                	lw	a4,8(a5)
 94e:	02977263          	bgeu	a4,s1,972 <malloc+0xb6>
    if(p == freep)
 952:	00093703          	ld	a4,0(s2)
 956:	853e                	mv	a0,a5
 958:	fef719e3          	bne	a4,a5,94a <malloc+0x8e>
  p = sbrk(nu * sizeof(Header));
 95c:	8552                	mv	a0,s4
 95e:	a1fff0ef          	jal	37c <sbrk>
  if(p == SBRK_ERROR)
 962:	fd551ce3          	bne	a0,s5,93a <malloc+0x7e>
        return 0;
 966:	4501                	li	a0,0
 968:	7902                	ld	s2,32(sp)
 96a:	6a42                	ld	s4,16(sp)
 96c:	6aa2                	ld	s5,8(sp)
 96e:	6b02                	ld	s6,0(sp)
 970:	a03d                	j	99e <malloc+0xe2>
 972:	7902                	ld	s2,32(sp)
 974:	6a42                	ld	s4,16(sp)
 976:	6aa2                	ld	s5,8(sp)
 978:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 97a:	fae48de3          	beq	s1,a4,934 <malloc+0x78>
        p->s.size -= nunits;
 97e:	4137073b          	subw	a4,a4,s3
 982:	c798                	sw	a4,8(a5)
        p += p->s.size;
 984:	02071693          	slli	a3,a4,0x20
 988:	01c6d713          	srli	a4,a3,0x1c
 98c:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 98e:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 992:	00000717          	auipc	a4,0x0
 996:	66a73723          	sd	a0,1646(a4) # 1000 <freep>
      return (void*)(p + 1);
 99a:	01078513          	addi	a0,a5,16
  }
}
 99e:	70e2                	ld	ra,56(sp)
 9a0:	7442                	ld	s0,48(sp)
 9a2:	74a2                	ld	s1,40(sp)
 9a4:	69e2                	ld	s3,24(sp)
 9a6:	6121                	addi	sp,sp,64
 9a8:	8082                	ret
 9aa:	7902                	ld	s2,32(sp)
 9ac:	6a42                	ld	s4,16(sp)
 9ae:	6aa2                	ld	s5,8(sp)
 9b0:	6b02                	ld	s6,0(sp)
 9b2:	b7f5                	j	99e <malloc+0xe2>
