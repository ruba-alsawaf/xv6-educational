
user/_cpuinfo:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
  "ZOMBIE",
};

int
main(void)
{
   0:	df010113          	addi	sp,sp,-528
   4:	20113423          	sd	ra,520(sp)
   8:	20813023          	sd	s0,512(sp)
   c:	0c00                	addi	s0,sp,528
  struct cpu_info cpus[NCPU];
  struct proc_stats stats;
  int n;

  n = getcpuinfo(cpus, NCPU);
   e:	45a1                	li	a1,8
  10:	e7040513          	addi	a0,s0,-400
  14:	526000ef          	jal	53a <getcpuinfo>
  if (n < 0) {
  18:	02054563          	bltz	a0,42 <main+0x42>
  1c:	ffa6                	sd	s1,504(sp)
  1e:	fbca                	sd	s2,496(sp)
  20:	f7ce                	sd	s3,488(sp)
  22:	f3d2                	sd	s4,480(sp)
  24:	efd6                	sd	s5,472(sp)
  26:	ebda                	sd	s6,464(sp)
  28:	85aa                	mv	a1,a0
    printf("getcpuinfo failed\n");
    exit(1);
  }

  int active = 0;
  for (int i = 0; i < n; i++) {
  2a:	14a05163          	blez	a0,16c <main+0x16c>
  2e:	e7040493          	addi	s1,s0,-400
  32:	02800913          	li	s2,40
  36:	03250933          	mul	s2,a0,s2
  3a:	9926                	add	s2,s2,s1
  3c:	87a6                	mv	a5,s1
  int active = 0;
  3e:	4601                	li	a2,0
  40:	a035                	j	6c <main+0x6c>
  42:	ffa6                	sd	s1,504(sp)
  44:	fbca                	sd	s2,496(sp)
  46:	f7ce                	sd	s3,488(sp)
  48:	f3d2                	sd	s4,480(sp)
  4a:	efd6                	sd	s5,472(sp)
  4c:	ebda                	sd	s6,464(sp)
  4e:	e7de                	sd	s7,456(sp)
  50:	e3e2                	sd	s8,448(sp)
    printf("getcpuinfo failed\n");
  52:	00001517          	auipc	a0,0x1
  56:	a7650513          	addi	a0,a0,-1418 # ac8 <malloc+0x10a>
  5a:	0b1000ef          	jal	90a <printf>
    exit(1);
  5e:	4505                	li	a0,1
  60:	452000ef          	jal	4b2 <exit>
  for (int i = 0; i < n; i++) {
  64:	02878793          	addi	a5,a5,40
  68:	01278663          	beq	a5,s2,74 <main+0x74>
    if (cpus[i].active)
  6c:	43d8                	lw	a4,4(a5)
  6e:	db7d                	beqz	a4,64 <main+0x64>
      active++;
  70:	2605                	addiw	a2,a2,1
  72:	bfcd                	j	64 <main+0x64>
  }

  printf("CPUs returned: %d active: %d\n", n, active);
  74:	00001517          	auipc	a0,0x1
  78:	a6c50513          	addi	a0,a0,-1428 # ae0 <malloc+0x122>
  7c:	08f000ef          	jal	90a <printf>
  for (int i = 0; i < n; i++) {
    printf("CPU {\"cpu\":%d,\"active\":%d,\"current_pid\":%d,\"current_state\":\"%s\",\"last_pid\":%d,\"last_state\":\"%s\",\"busy_percent\":%d,\"active_ticks\":%lu}\n",
  80:	4a15                	li	s4,5
  82:	00001997          	auipc	s3,0x1
  86:	a3e98993          	addi	s3,s3,-1474 # ac0 <malloc+0x102>
  8a:	00001b17          	auipc	s6,0x1
  8e:	c3eb0b13          	addi	s6,s6,-962 # cc8 <state_names>
  92:	00001a97          	auipc	s5,0x1
  96:	a6ea8a93          	addi	s5,s5,-1426 # b00 <malloc+0x142>
  9a:	a829                	j	b4 <main+0xb4>
  9c:	01853883          	ld	a7,24(a0)
  a0:	e046                	sd	a7,0(sp)
  a2:	02052883          	lw	a7,32(a0)
  a6:	8556                	mv	a0,s5
  a8:	063000ef          	jal	90a <printf>
  for (int i = 0; i < n; i++) {
  ac:	02848493          	addi	s1,s1,40
  b0:	0d248663          	beq	s1,s2,17c <main+0x17c>
    printf("CPU {\"cpu\":%d,\"active\":%d,\"current_pid\":%d,\"current_state\":\"%s\",\"last_pid\":%d,\"last_state\":\"%s\",\"busy_percent\":%d,\"active_ticks\":%lu}\n",
  b4:	8526                	mv	a0,s1
  b6:	408c                	lw	a1,0(s1)
  b8:	40d0                	lw	a2,4(s1)
  ba:	4494                	lw	a3,8(s1)
           cpus[i].cpu,
           cpus[i].active,
           cpus[i].current_pid,
           cpus[i].current_state >= 0 && cpus[i].current_state < PROC_STATE_COUNT ? state_names[cpus[i].current_state] : "UNKNOWN",
  bc:	44dc                	lw	a5,12(s1)
    printf("CPU {\"cpu\":%d,\"active\":%d,\"current_pid\":%d,\"current_state\":\"%s\",\"last_pid\":%d,\"last_state\":\"%s\",\"busy_percent\":%d,\"active_ticks\":%lu}\n",
  be:	0007881b          	sext.w	a6,a5
  c2:	874e                	mv	a4,s3
  c4:	010a6563          	bltu	s4,a6,ce <main+0xce>
  c8:	078e                	slli	a5,a5,0x3
  ca:	97da                	add	a5,a5,s6
  cc:	6398                	ld	a4,0(a5)
  ce:	491c                	lw	a5,16(a0)
           cpus[i].last_pid,
           cpus[i].last_state >= 0 && cpus[i].last_state < PROC_STATE_COUNT ? state_names[cpus[i].last_state] : "UNKNOWN",
  d0:	01452883          	lw	a7,20(a0)
    printf("CPU {\"cpu\":%d,\"active\":%d,\"current_pid\":%d,\"current_state\":\"%s\",\"last_pid\":%d,\"last_state\":\"%s\",\"busy_percent\":%d,\"active_ticks\":%lu}\n",
  d4:	0008831b          	sext.w	t1,a7
  d8:	884e                	mv	a6,s3
  da:	fc6a61e3          	bltu	s4,t1,9c <main+0x9c>
  de:	088e                	slli	a7,a7,0x3
  e0:	98da                	add	a7,a7,s6
  e2:	0008b803          	ld	a6,0(a7)
  e6:	bf5d                	j	9c <main+0x9c>
  e8:	e7de                	sd	s7,456(sp)
  ea:	e3e2                	sd	s8,448(sp)
           cpus[i].busy_percent,
           cpus[i].active_ticks);
  }

  if (getprocstats(&stats) < 0) {
    printf("getprocstats failed\n");
  ec:	00001517          	auipc	a0,0x1
  f0:	a9c50513          	addi	a0,a0,-1380 # b88 <malloc+0x1ca>
  f4:	017000ef          	jal	90a <printf>
    exit(1);
  f8:	4505                	li	a0,1
  fa:	3b8000ef          	jal	4b2 <exit>

  // Database format
  printf("PROC {\"total_created\":%lu,\"total_exited\":%lu,\"current\":{", stats.total_created, stats.total_exited);
  for (int i = 0; i < PROC_STATE_COUNT; i++) {
    printf("\"%s\":%lu", state_names[i], stats.current_count[i]);
    if (i < PROC_STATE_COUNT - 1) printf(",");
  fe:	8562                	mv	a0,s8
 100:	00b000ef          	jal	90a <printf>
  for (int i = 0; i < PROC_STATE_COUNT; i++) {
 104:	0a21                	addi	s4,s4,8
 106:	0921                	addi	s2,s2,8
 108:	01590b63          	beq	s2,s5,11e <main+0x11e>
    printf("\"%s\":%lu", state_names[i], stats.current_count[i]);
 10c:	00093603          	ld	a2,0(s2)
 110:	000a3583          	ld	a1,0(s4)
 114:	855e                	mv	a0,s7
 116:	7f4000ef          	jal	90a <printf>
    if (i < PROC_STATE_COUNT - 1) printf(",");
 11a:	ff6912e3          	bne	s2,s6,fe <main+0xfe>
  }
  printf("},\"unique\":{");
 11e:	00001517          	auipc	a0,0x1
 122:	b4a50513          	addi	a0,a0,-1206 # c68 <malloc+0x2aa>
 126:	7e4000ef          	jal	90a <printf>
  for (int i = 0; i < PROC_STATE_COUNT; i++) {
    printf("\"%s\":%lu", state_names[i], stats.unique_count[i]);
 12a:	00001917          	auipc	s2,0x1
 12e:	b2690913          	addi	s2,s2,-1242 # c50 <malloc+0x292>
    if (i < PROC_STATE_COUNT - 1) printf(",");
 132:	00001a17          	auipc	s4,0x1
 136:	b2ea0a13          	addi	s4,s4,-1234 # c60 <malloc+0x2a2>
 13a:	a801                	j	14a <main+0x14a>
 13c:	8552                	mv	a0,s4
 13e:	7cc000ef          	jal	90a <printf>
  for (int i = 0; i < PROC_STATE_COUNT; i++) {
 142:	09a1                	addi	s3,s3,8
 144:	04a1                	addi	s1,s1,8
 146:	01548a63          	beq	s1,s5,15a <main+0x15a>
    printf("\"%s\":%lu", state_names[i], stats.unique_count[i]);
 14a:	7890                	ld	a2,48(s1)
 14c:	0009b583          	ld	a1,0(s3)
 150:	854a                	mv	a0,s2
 152:	7b8000ef          	jal	90a <printf>
    if (i < PROC_STATE_COUNT - 1) printf(",");
 156:	ff6493e3          	bne	s1,s6,13c <main+0x13c>
  }
  printf("}}\n");
 15a:	00001517          	auipc	a0,0x1
 15e:	b1e50513          	addi	a0,a0,-1250 # c78 <malloc+0x2ba>
 162:	7a8000ef          	jal	90a <printf>

  exit(0);
 166:	4501                	li	a0,0
 168:	34a000ef          	jal	4b2 <exit>
  printf("CPUs returned: %d active: %d\n", n, active);
 16c:	4601                	li	a2,0
 16e:	4581                	li	a1,0
 170:	00001517          	auipc	a0,0x1
 174:	97050513          	addi	a0,a0,-1680 # ae0 <malloc+0x122>
 178:	792000ef          	jal	90a <printf>
  if (getprocstats(&stats) < 0) {
 17c:	e0040513          	addi	a0,s0,-512
 180:	3c2000ef          	jal	542 <getprocstats>
 184:	f60542e3          	bltz	a0,e8 <main+0xe8>
 188:	e7de                	sd	s7,456(sp)
 18a:	e3e2                	sd	s8,448(sp)
  printf("\nprocess stats:\n");
 18c:	00001517          	auipc	a0,0x1
 190:	a1450513          	addi	a0,a0,-1516 # ba0 <malloc+0x1e2>
 194:	776000ef          	jal	90a <printf>
  printf(" total created = %lu\n", stats.total_created);
 198:	e6043583          	ld	a1,-416(s0)
 19c:	00001517          	auipc	a0,0x1
 1a0:	a1c50513          	addi	a0,a0,-1508 # bb8 <malloc+0x1fa>
 1a4:	766000ef          	jal	90a <printf>
  printf(" total exited  = %lu\n", stats.total_exited);
 1a8:	e6843583          	ld	a1,-408(s0)
 1ac:	00001517          	auipc	a0,0x1
 1b0:	a2450513          	addi	a0,a0,-1500 # bd0 <malloc+0x212>
 1b4:	756000ef          	jal	90a <printf>
  for (int i = 0; i < PROC_STATE_COUNT; i++) {
 1b8:	00001997          	auipc	s3,0x1
 1bc:	b1098993          	addi	s3,s3,-1264 # cc8 <state_names>
 1c0:	e0040493          	addi	s1,s0,-512
 1c4:	e3040a93          	addi	s5,s0,-464
  printf(" total exited  = %lu\n", stats.total_exited);
 1c8:	8926                	mv	s2,s1
 1ca:	8a4e                	mv	s4,s3
    printf(" current %s = %lu  unique %s = %lu\n",
 1cc:	00001b17          	auipc	s6,0x1
 1d0:	a1cb0b13          	addi	s6,s6,-1508 # be8 <malloc+0x22a>
 1d4:	000a3583          	ld	a1,0(s4)
 1d8:	03093703          	ld	a4,48(s2)
 1dc:	86ae                	mv	a3,a1
 1de:	00093603          	ld	a2,0(s2)
 1e2:	855a                	mv	a0,s6
 1e4:	726000ef          	jal	90a <printf>
  for (int i = 0; i < PROC_STATE_COUNT; i++) {
 1e8:	0a21                	addi	s4,s4,8
 1ea:	0921                	addi	s2,s2,8
 1ec:	ff5914e3          	bne	s2,s5,1d4 <main+0x1d4>
  printf("PROC {\"total_created\":%lu,\"total_exited\":%lu,\"current\":{", stats.total_created, stats.total_exited);
 1f0:	e6843603          	ld	a2,-408(s0)
 1f4:	e6043583          	ld	a1,-416(s0)
 1f8:	00001517          	auipc	a0,0x1
 1fc:	a1850513          	addi	a0,a0,-1512 # c10 <malloc+0x252>
 200:	70a000ef          	jal	90a <printf>
  for (int i = 0; i < PROC_STATE_COUNT; i++) {
 204:	02848b13          	addi	s6,s1,40
  printf("PROC {\"total_created\":%lu,\"total_exited\":%lu,\"current\":{", stats.total_created, stats.total_exited);
 208:	8926                	mv	s2,s1
 20a:	8a4e                	mv	s4,s3
    printf("\"%s\":%lu", state_names[i], stats.current_count[i]);
 20c:	00001b97          	auipc	s7,0x1
 210:	a44b8b93          	addi	s7,s7,-1468 # c50 <malloc+0x292>
    if (i < PROC_STATE_COUNT - 1) printf(",");
 214:	00001c17          	auipc	s8,0x1
 218:	a4cc0c13          	addi	s8,s8,-1460 # c60 <malloc+0x2a2>
 21c:	bdc5                	j	10c <main+0x10c>

000000000000021e <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start(int argc, char **argv)
{
 21e:	1141                	addi	sp,sp,-16
 220:	e406                	sd	ra,8(sp)
 222:	e022                	sd	s0,0(sp)
 224:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
 226:	ddbff0ef          	jal	0 <main>
  exit(r);
 22a:	288000ef          	jal	4b2 <exit>

000000000000022e <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 22e:	1141                	addi	sp,sp,-16
 230:	e422                	sd	s0,8(sp)
 232:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 234:	87aa                	mv	a5,a0
 236:	0585                	addi	a1,a1,1
 238:	0785                	addi	a5,a5,1
 23a:	fff5c703          	lbu	a4,-1(a1)
 23e:	fee78fa3          	sb	a4,-1(a5)
 242:	fb75                	bnez	a4,236 <strcpy+0x8>
    ;
  return os;
}
 244:	6422                	ld	s0,8(sp)
 246:	0141                	addi	sp,sp,16
 248:	8082                	ret

000000000000024a <strcmp>:

int
strcmp(const char *p, const char *q)
{
 24a:	1141                	addi	sp,sp,-16
 24c:	e422                	sd	s0,8(sp)
 24e:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 250:	00054783          	lbu	a5,0(a0)
 254:	cb91                	beqz	a5,268 <strcmp+0x1e>
 256:	0005c703          	lbu	a4,0(a1)
 25a:	00f71763          	bne	a4,a5,268 <strcmp+0x1e>
    p++, q++;
 25e:	0505                	addi	a0,a0,1
 260:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 262:	00054783          	lbu	a5,0(a0)
 266:	fbe5                	bnez	a5,256 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 268:	0005c503          	lbu	a0,0(a1)
}
 26c:	40a7853b          	subw	a0,a5,a0
 270:	6422                	ld	s0,8(sp)
 272:	0141                	addi	sp,sp,16
 274:	8082                	ret

0000000000000276 <strlen>:

uint
strlen(const char *s)
{
 276:	1141                	addi	sp,sp,-16
 278:	e422                	sd	s0,8(sp)
 27a:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 27c:	00054783          	lbu	a5,0(a0)
 280:	cf91                	beqz	a5,29c <strlen+0x26>
 282:	0505                	addi	a0,a0,1
 284:	87aa                	mv	a5,a0
 286:	86be                	mv	a3,a5
 288:	0785                	addi	a5,a5,1
 28a:	fff7c703          	lbu	a4,-1(a5)
 28e:	ff65                	bnez	a4,286 <strlen+0x10>
 290:	40a6853b          	subw	a0,a3,a0
 294:	2505                	addiw	a0,a0,1
    ;
  return n;
}
 296:	6422                	ld	s0,8(sp)
 298:	0141                	addi	sp,sp,16
 29a:	8082                	ret
  for(n = 0; s[n]; n++)
 29c:	4501                	li	a0,0
 29e:	bfe5                	j	296 <strlen+0x20>

00000000000002a0 <memset>:

void*
memset(void *dst, int c, uint n)
{
 2a0:	1141                	addi	sp,sp,-16
 2a2:	e422                	sd	s0,8(sp)
 2a4:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 2a6:	ca19                	beqz	a2,2bc <memset+0x1c>
 2a8:	87aa                	mv	a5,a0
 2aa:	1602                	slli	a2,a2,0x20
 2ac:	9201                	srli	a2,a2,0x20
 2ae:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 2b2:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 2b6:	0785                	addi	a5,a5,1
 2b8:	fee79de3          	bne	a5,a4,2b2 <memset+0x12>
  }
  return dst;
}
 2bc:	6422                	ld	s0,8(sp)
 2be:	0141                	addi	sp,sp,16
 2c0:	8082                	ret

00000000000002c2 <strchr>:

char*
strchr(const char *s, char c)
{
 2c2:	1141                	addi	sp,sp,-16
 2c4:	e422                	sd	s0,8(sp)
 2c6:	0800                	addi	s0,sp,16
  for(; *s; s++)
 2c8:	00054783          	lbu	a5,0(a0)
 2cc:	cb99                	beqz	a5,2e2 <strchr+0x20>
    if(*s == c)
 2ce:	00f58763          	beq	a1,a5,2dc <strchr+0x1a>
  for(; *s; s++)
 2d2:	0505                	addi	a0,a0,1
 2d4:	00054783          	lbu	a5,0(a0)
 2d8:	fbfd                	bnez	a5,2ce <strchr+0xc>
      return (char*)s;
  return 0;
 2da:	4501                	li	a0,0
}
 2dc:	6422                	ld	s0,8(sp)
 2de:	0141                	addi	sp,sp,16
 2e0:	8082                	ret
  return 0;
 2e2:	4501                	li	a0,0
 2e4:	bfe5                	j	2dc <strchr+0x1a>

00000000000002e6 <gets>:

char*
gets(char *buf, int max)
{
 2e6:	711d                	addi	sp,sp,-96
 2e8:	ec86                	sd	ra,88(sp)
 2ea:	e8a2                	sd	s0,80(sp)
 2ec:	e4a6                	sd	s1,72(sp)
 2ee:	e0ca                	sd	s2,64(sp)
 2f0:	fc4e                	sd	s3,56(sp)
 2f2:	f852                	sd	s4,48(sp)
 2f4:	f456                	sd	s5,40(sp)
 2f6:	f05a                	sd	s6,32(sp)
 2f8:	ec5e                	sd	s7,24(sp)
 2fa:	1080                	addi	s0,sp,96
 2fc:	8baa                	mv	s7,a0
 2fe:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 300:	892a                	mv	s2,a0
 302:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 304:	4aa9                	li	s5,10
 306:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 308:	89a6                	mv	s3,s1
 30a:	2485                	addiw	s1,s1,1
 30c:	0344d663          	bge	s1,s4,338 <gets+0x52>
    cc = read(0, &c, 1);
 310:	4605                	li	a2,1
 312:	faf40593          	addi	a1,s0,-81
 316:	4501                	li	a0,0
 318:	1b2000ef          	jal	4ca <read>
    if(cc < 1)
 31c:	00a05e63          	blez	a0,338 <gets+0x52>
    buf[i++] = c;
 320:	faf44783          	lbu	a5,-81(s0)
 324:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 328:	01578763          	beq	a5,s5,336 <gets+0x50>
 32c:	0905                	addi	s2,s2,1
 32e:	fd679de3          	bne	a5,s6,308 <gets+0x22>
    buf[i++] = c;
 332:	89a6                	mv	s3,s1
 334:	a011                	j	338 <gets+0x52>
 336:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 338:	99de                	add	s3,s3,s7
 33a:	00098023          	sb	zero,0(s3)
  return buf;
}
 33e:	855e                	mv	a0,s7
 340:	60e6                	ld	ra,88(sp)
 342:	6446                	ld	s0,80(sp)
 344:	64a6                	ld	s1,72(sp)
 346:	6906                	ld	s2,64(sp)
 348:	79e2                	ld	s3,56(sp)
 34a:	7a42                	ld	s4,48(sp)
 34c:	7aa2                	ld	s5,40(sp)
 34e:	7b02                	ld	s6,32(sp)
 350:	6be2                	ld	s7,24(sp)
 352:	6125                	addi	sp,sp,96
 354:	8082                	ret

0000000000000356 <stat>:

int
stat(const char *n, struct stat *st)
{
 356:	1101                	addi	sp,sp,-32
 358:	ec06                	sd	ra,24(sp)
 35a:	e822                	sd	s0,16(sp)
 35c:	e04a                	sd	s2,0(sp)
 35e:	1000                	addi	s0,sp,32
 360:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 362:	4581                	li	a1,0
 364:	18e000ef          	jal	4f2 <open>
  if(fd < 0)
 368:	02054263          	bltz	a0,38c <stat+0x36>
 36c:	e426                	sd	s1,8(sp)
 36e:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 370:	85ca                	mv	a1,s2
 372:	198000ef          	jal	50a <fstat>
 376:	892a                	mv	s2,a0
  close(fd);
 378:	8526                	mv	a0,s1
 37a:	160000ef          	jal	4da <close>
  return r;
 37e:	64a2                	ld	s1,8(sp)
}
 380:	854a                	mv	a0,s2
 382:	60e2                	ld	ra,24(sp)
 384:	6442                	ld	s0,16(sp)
 386:	6902                	ld	s2,0(sp)
 388:	6105                	addi	sp,sp,32
 38a:	8082                	ret
    return -1;
 38c:	597d                	li	s2,-1
 38e:	bfcd                	j	380 <stat+0x2a>

0000000000000390 <atoi>:

int
atoi(const char *s)
{
 390:	1141                	addi	sp,sp,-16
 392:	e422                	sd	s0,8(sp)
 394:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 396:	00054683          	lbu	a3,0(a0)
 39a:	fd06879b          	addiw	a5,a3,-48
 39e:	0ff7f793          	zext.b	a5,a5
 3a2:	4625                	li	a2,9
 3a4:	02f66863          	bltu	a2,a5,3d4 <atoi+0x44>
 3a8:	872a                	mv	a4,a0
  n = 0;
 3aa:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 3ac:	0705                	addi	a4,a4,1
 3ae:	0025179b          	slliw	a5,a0,0x2
 3b2:	9fa9                	addw	a5,a5,a0
 3b4:	0017979b          	slliw	a5,a5,0x1
 3b8:	9fb5                	addw	a5,a5,a3
 3ba:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 3be:	00074683          	lbu	a3,0(a4)
 3c2:	fd06879b          	addiw	a5,a3,-48
 3c6:	0ff7f793          	zext.b	a5,a5
 3ca:	fef671e3          	bgeu	a2,a5,3ac <atoi+0x1c>
  return n;
}
 3ce:	6422                	ld	s0,8(sp)
 3d0:	0141                	addi	sp,sp,16
 3d2:	8082                	ret
  n = 0;
 3d4:	4501                	li	a0,0
 3d6:	bfe5                	j	3ce <atoi+0x3e>

00000000000003d8 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 3d8:	1141                	addi	sp,sp,-16
 3da:	e422                	sd	s0,8(sp)
 3dc:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 3de:	02b57463          	bgeu	a0,a1,406 <memmove+0x2e>
    while(n-- > 0)
 3e2:	00c05f63          	blez	a2,400 <memmove+0x28>
 3e6:	1602                	slli	a2,a2,0x20
 3e8:	9201                	srli	a2,a2,0x20
 3ea:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 3ee:	872a                	mv	a4,a0
      *dst++ = *src++;
 3f0:	0585                	addi	a1,a1,1
 3f2:	0705                	addi	a4,a4,1
 3f4:	fff5c683          	lbu	a3,-1(a1)
 3f8:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 3fc:	fef71ae3          	bne	a4,a5,3f0 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 400:	6422                	ld	s0,8(sp)
 402:	0141                	addi	sp,sp,16
 404:	8082                	ret
    dst += n;
 406:	00c50733          	add	a4,a0,a2
    src += n;
 40a:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 40c:	fec05ae3          	blez	a2,400 <memmove+0x28>
 410:	fff6079b          	addiw	a5,a2,-1
 414:	1782                	slli	a5,a5,0x20
 416:	9381                	srli	a5,a5,0x20
 418:	fff7c793          	not	a5,a5
 41c:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 41e:	15fd                	addi	a1,a1,-1
 420:	177d                	addi	a4,a4,-1
 422:	0005c683          	lbu	a3,0(a1)
 426:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 42a:	fee79ae3          	bne	a5,a4,41e <memmove+0x46>
 42e:	bfc9                	j	400 <memmove+0x28>

0000000000000430 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 430:	1141                	addi	sp,sp,-16
 432:	e422                	sd	s0,8(sp)
 434:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 436:	ca05                	beqz	a2,466 <memcmp+0x36>
 438:	fff6069b          	addiw	a3,a2,-1
 43c:	1682                	slli	a3,a3,0x20
 43e:	9281                	srli	a3,a3,0x20
 440:	0685                	addi	a3,a3,1
 442:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 444:	00054783          	lbu	a5,0(a0)
 448:	0005c703          	lbu	a4,0(a1)
 44c:	00e79863          	bne	a5,a4,45c <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 450:	0505                	addi	a0,a0,1
    p2++;
 452:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 454:	fed518e3          	bne	a0,a3,444 <memcmp+0x14>
  }
  return 0;
 458:	4501                	li	a0,0
 45a:	a019                	j	460 <memcmp+0x30>
      return *p1 - *p2;
 45c:	40e7853b          	subw	a0,a5,a4
}
 460:	6422                	ld	s0,8(sp)
 462:	0141                	addi	sp,sp,16
 464:	8082                	ret
  return 0;
 466:	4501                	li	a0,0
 468:	bfe5                	j	460 <memcmp+0x30>

000000000000046a <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 46a:	1141                	addi	sp,sp,-16
 46c:	e406                	sd	ra,8(sp)
 46e:	e022                	sd	s0,0(sp)
 470:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 472:	f67ff0ef          	jal	3d8 <memmove>
}
 476:	60a2                	ld	ra,8(sp)
 478:	6402                	ld	s0,0(sp)
 47a:	0141                	addi	sp,sp,16
 47c:	8082                	ret

000000000000047e <sbrk>:

char *
sbrk(int n) {
 47e:	1141                	addi	sp,sp,-16
 480:	e406                	sd	ra,8(sp)
 482:	e022                	sd	s0,0(sp)
 484:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
 486:	4585                	li	a1,1
 488:	0c2000ef          	jal	54a <sys_sbrk>
}
 48c:	60a2                	ld	ra,8(sp)
 48e:	6402                	ld	s0,0(sp)
 490:	0141                	addi	sp,sp,16
 492:	8082                	ret

0000000000000494 <sbrklazy>:

char *
sbrklazy(int n) {
 494:	1141                	addi	sp,sp,-16
 496:	e406                	sd	ra,8(sp)
 498:	e022                	sd	s0,0(sp)
 49a:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 49c:	4589                	li	a1,2
 49e:	0ac000ef          	jal	54a <sys_sbrk>
}
 4a2:	60a2                	ld	ra,8(sp)
 4a4:	6402                	ld	s0,0(sp)
 4a6:	0141                	addi	sp,sp,16
 4a8:	8082                	ret

00000000000004aa <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 4aa:	4885                	li	a7,1
 ecall
 4ac:	00000073          	ecall
 ret
 4b0:	8082                	ret

00000000000004b2 <exit>:
.global exit
exit:
 li a7, SYS_exit
 4b2:	4889                	li	a7,2
 ecall
 4b4:	00000073          	ecall
 ret
 4b8:	8082                	ret

00000000000004ba <wait>:
.global wait
wait:
 li a7, SYS_wait
 4ba:	488d                	li	a7,3
 ecall
 4bc:	00000073          	ecall
 ret
 4c0:	8082                	ret

00000000000004c2 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 4c2:	4891                	li	a7,4
 ecall
 4c4:	00000073          	ecall
 ret
 4c8:	8082                	ret

00000000000004ca <read>:
.global read
read:
 li a7, SYS_read
 4ca:	4895                	li	a7,5
 ecall
 4cc:	00000073          	ecall
 ret
 4d0:	8082                	ret

00000000000004d2 <write>:
.global write
write:
 li a7, SYS_write
 4d2:	48c1                	li	a7,16
 ecall
 4d4:	00000073          	ecall
 ret
 4d8:	8082                	ret

00000000000004da <close>:
.global close
close:
 li a7, SYS_close
 4da:	48d5                	li	a7,21
 ecall
 4dc:	00000073          	ecall
 ret
 4e0:	8082                	ret

00000000000004e2 <kill>:
.global kill
kill:
 li a7, SYS_kill
 4e2:	4899                	li	a7,6
 ecall
 4e4:	00000073          	ecall
 ret
 4e8:	8082                	ret

00000000000004ea <exec>:
.global exec
exec:
 li a7, SYS_exec
 4ea:	489d                	li	a7,7
 ecall
 4ec:	00000073          	ecall
 ret
 4f0:	8082                	ret

00000000000004f2 <open>:
.global open
open:
 li a7, SYS_open
 4f2:	48bd                	li	a7,15
 ecall
 4f4:	00000073          	ecall
 ret
 4f8:	8082                	ret

00000000000004fa <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 4fa:	48c5                	li	a7,17
 ecall
 4fc:	00000073          	ecall
 ret
 500:	8082                	ret

0000000000000502 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 502:	48c9                	li	a7,18
 ecall
 504:	00000073          	ecall
 ret
 508:	8082                	ret

000000000000050a <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 50a:	48a1                	li	a7,8
 ecall
 50c:	00000073          	ecall
 ret
 510:	8082                	ret

0000000000000512 <link>:
.global link
link:
 li a7, SYS_link
 512:	48cd                	li	a7,19
 ecall
 514:	00000073          	ecall
 ret
 518:	8082                	ret

000000000000051a <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 51a:	48d1                	li	a7,20
 ecall
 51c:	00000073          	ecall
 ret
 520:	8082                	ret

0000000000000522 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 522:	48a5                	li	a7,9
 ecall
 524:	00000073          	ecall
 ret
 528:	8082                	ret

000000000000052a <dup>:
.global dup
dup:
 li a7, SYS_dup
 52a:	48a9                	li	a7,10
 ecall
 52c:	00000073          	ecall
 ret
 530:	8082                	ret

0000000000000532 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 532:	48ad                	li	a7,11
 ecall
 534:	00000073          	ecall
 ret
 538:	8082                	ret

000000000000053a <getcpuinfo>:
.global getcpuinfo
getcpuinfo:
 li a7, SYS_getcpuinfo
 53a:	48e9                	li	a7,26
 ecall
 53c:	00000073          	ecall
 ret
 540:	8082                	ret

0000000000000542 <getprocstats>:
.global getprocstats
getprocstats:
 li a7, SYS_getprocstats
 542:	48ed                	li	a7,27
 ecall
 544:	00000073          	ecall
 ret
 548:	8082                	ret

000000000000054a <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 54a:	48b1                	li	a7,12
 ecall
 54c:	00000073          	ecall
 ret
 550:	8082                	ret

0000000000000552 <pause>:
.global pause
pause:
 li a7, SYS_pause
 552:	48b5                	li	a7,13
 ecall
 554:	00000073          	ecall
 ret
 558:	8082                	ret

000000000000055a <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 55a:	48b9                	li	a7,14
 ecall
 55c:	00000073          	ecall
 ret
 560:	8082                	ret

0000000000000562 <csread>:
.global csread
csread:
 li a7, SYS_csread
 562:	48d9                	li	a7,22
 ecall
 564:	00000073          	ecall
 ret
 568:	8082                	ret

000000000000056a <fsread>:
.global fsread
fsread:
 li a7, SYS_fsread
 56a:	48dd                	li	a7,23
 ecall
 56c:	00000073          	ecall
 ret
 570:	8082                	ret

0000000000000572 <schedread>:
.global schedread
schedread:
 li a7, SYS_schedread
 572:	48e1                	li	a7,24
 ecall
 574:	00000073          	ecall
 ret
 578:	8082                	ret

000000000000057a <memread>:
.global memread
memread:
 li a7, SYS_memread
 57a:	48e5                	li	a7,25
 ecall
 57c:	00000073          	ecall
 ret
 580:	8082                	ret

0000000000000582 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 582:	1101                	addi	sp,sp,-32
 584:	ec06                	sd	ra,24(sp)
 586:	e822                	sd	s0,16(sp)
 588:	1000                	addi	s0,sp,32
 58a:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 58e:	4605                	li	a2,1
 590:	fef40593          	addi	a1,s0,-17
 594:	f3fff0ef          	jal	4d2 <write>
}
 598:	60e2                	ld	ra,24(sp)
 59a:	6442                	ld	s0,16(sp)
 59c:	6105                	addi	sp,sp,32
 59e:	8082                	ret

00000000000005a0 <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
 5a0:	715d                	addi	sp,sp,-80
 5a2:	e486                	sd	ra,72(sp)
 5a4:	e0a2                	sd	s0,64(sp)
 5a6:	f84a                	sd	s2,48(sp)
 5a8:	0880                	addi	s0,sp,80
 5aa:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
 5ac:	c299                	beqz	a3,5b2 <printint+0x12>
 5ae:	0805c363          	bltz	a1,634 <printint+0x94>
  neg = 0;
 5b2:	4881                	li	a7,0
 5b4:	fb840693          	addi	a3,s0,-72
    x = -xx;
  } else {
    x = xx;
  }

  i = 0;
 5b8:	4781                	li	a5,0
  do{
    buf[i++] = digits[x % base];
 5ba:	00000517          	auipc	a0,0x0
 5be:	73e50513          	addi	a0,a0,1854 # cf8 <digits>
 5c2:	883e                	mv	a6,a5
 5c4:	2785                	addiw	a5,a5,1
 5c6:	02c5f733          	remu	a4,a1,a2
 5ca:	972a                	add	a4,a4,a0
 5cc:	00074703          	lbu	a4,0(a4)
 5d0:	00e68023          	sb	a4,0(a3)
  }while((x /= base) != 0);
 5d4:	872e                	mv	a4,a1
 5d6:	02c5d5b3          	divu	a1,a1,a2
 5da:	0685                	addi	a3,a3,1
 5dc:	fec773e3          	bgeu	a4,a2,5c2 <printint+0x22>
  if(neg)
 5e0:	00088b63          	beqz	a7,5f6 <printint+0x56>
    buf[i++] = '-';
 5e4:	fd078793          	addi	a5,a5,-48
 5e8:	97a2                	add	a5,a5,s0
 5ea:	02d00713          	li	a4,45
 5ee:	fee78423          	sb	a4,-24(a5)
 5f2:	0028079b          	addiw	a5,a6,2

  while(--i >= 0)
 5f6:	02f05a63          	blez	a5,62a <printint+0x8a>
 5fa:	fc26                	sd	s1,56(sp)
 5fc:	f44e                	sd	s3,40(sp)
 5fe:	fb840713          	addi	a4,s0,-72
 602:	00f704b3          	add	s1,a4,a5
 606:	fff70993          	addi	s3,a4,-1
 60a:	99be                	add	s3,s3,a5
 60c:	37fd                	addiw	a5,a5,-1
 60e:	1782                	slli	a5,a5,0x20
 610:	9381                	srli	a5,a5,0x20
 612:	40f989b3          	sub	s3,s3,a5
    putc(fd, buf[i]);
 616:	fff4c583          	lbu	a1,-1(s1)
 61a:	854a                	mv	a0,s2
 61c:	f67ff0ef          	jal	582 <putc>
  while(--i >= 0)
 620:	14fd                	addi	s1,s1,-1
 622:	ff349ae3          	bne	s1,s3,616 <printint+0x76>
 626:	74e2                	ld	s1,56(sp)
 628:	79a2                	ld	s3,40(sp)
}
 62a:	60a6                	ld	ra,72(sp)
 62c:	6406                	ld	s0,64(sp)
 62e:	7942                	ld	s2,48(sp)
 630:	6161                	addi	sp,sp,80
 632:	8082                	ret
    x = -xx;
 634:	40b005b3          	neg	a1,a1
    neg = 1;
 638:	4885                	li	a7,1
    x = -xx;
 63a:	bfad                	j	5b4 <printint+0x14>

000000000000063c <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 63c:	711d                	addi	sp,sp,-96
 63e:	ec86                	sd	ra,88(sp)
 640:	e8a2                	sd	s0,80(sp)
 642:	e0ca                	sd	s2,64(sp)
 644:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 646:	0005c903          	lbu	s2,0(a1)
 64a:	28090663          	beqz	s2,8d6 <vprintf+0x29a>
 64e:	e4a6                	sd	s1,72(sp)
 650:	fc4e                	sd	s3,56(sp)
 652:	f852                	sd	s4,48(sp)
 654:	f456                	sd	s5,40(sp)
 656:	f05a                	sd	s6,32(sp)
 658:	ec5e                	sd	s7,24(sp)
 65a:	e862                	sd	s8,16(sp)
 65c:	e466                	sd	s9,8(sp)
 65e:	8b2a                	mv	s6,a0
 660:	8a2e                	mv	s4,a1
 662:	8bb2                	mv	s7,a2
  state = 0;
 664:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 666:	4481                	li	s1,0
 668:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 66a:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 66e:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 672:	06c00c93          	li	s9,108
 676:	a005                	j	696 <vprintf+0x5a>
        putc(fd, c0);
 678:	85ca                	mv	a1,s2
 67a:	855a                	mv	a0,s6
 67c:	f07ff0ef          	jal	582 <putc>
 680:	a019                	j	686 <vprintf+0x4a>
    } else if(state == '%'){
 682:	03598263          	beq	s3,s5,6a6 <vprintf+0x6a>
  for(i = 0; fmt[i]; i++){
 686:	2485                	addiw	s1,s1,1
 688:	8726                	mv	a4,s1
 68a:	009a07b3          	add	a5,s4,s1
 68e:	0007c903          	lbu	s2,0(a5)
 692:	22090a63          	beqz	s2,8c6 <vprintf+0x28a>
    c0 = fmt[i] & 0xff;
 696:	0009079b          	sext.w	a5,s2
    if(state == 0){
 69a:	fe0994e3          	bnez	s3,682 <vprintf+0x46>
      if(c0 == '%'){
 69e:	fd579de3          	bne	a5,s5,678 <vprintf+0x3c>
        state = '%';
 6a2:	89be                	mv	s3,a5
 6a4:	b7cd                	j	686 <vprintf+0x4a>
      if(c0) c1 = fmt[i+1] & 0xff;
 6a6:	00ea06b3          	add	a3,s4,a4
 6aa:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
 6ae:	8636                	mv	a2,a3
      if(c1) c2 = fmt[i+2] & 0xff;
 6b0:	c681                	beqz	a3,6b8 <vprintf+0x7c>
 6b2:	9752                	add	a4,a4,s4
 6b4:	00274603          	lbu	a2,2(a4)
      if(c0 == 'd'){
 6b8:	05878363          	beq	a5,s8,6fe <vprintf+0xc2>
      } else if(c0 == 'l' && c1 == 'd'){
 6bc:	05978d63          	beq	a5,s9,716 <vprintf+0xda>
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if(c0 == 'u'){
 6c0:	07500713          	li	a4,117
 6c4:	0ee78763          	beq	a5,a4,7b2 <vprintf+0x176>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if(c0 == 'x'){
 6c8:	07800713          	li	a4,120
 6cc:	12e78963          	beq	a5,a4,7fe <vprintf+0x1c2>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if(c0 == 'p'){
 6d0:	07000713          	li	a4,112
 6d4:	14e78e63          	beq	a5,a4,830 <vprintf+0x1f4>
        printptr(fd, va_arg(ap, uint64));
      } else if(c0 == 'c'){
 6d8:	06300713          	li	a4,99
 6dc:	18e78e63          	beq	a5,a4,878 <vprintf+0x23c>
        putc(fd, va_arg(ap, uint32));
      } else if(c0 == 's'){
 6e0:	07300713          	li	a4,115
 6e4:	1ae78463          	beq	a5,a4,88c <vprintf+0x250>
        if((s = va_arg(ap, char*)) == 0)
          s = "(null)";
        for(; *s; s++)
          putc(fd, *s);
      } else if(c0 == '%'){
 6e8:	02500713          	li	a4,37
 6ec:	04e79563          	bne	a5,a4,736 <vprintf+0xfa>
        putc(fd, '%');
 6f0:	02500593          	li	a1,37
 6f4:	855a                	mv	a0,s6
 6f6:	e8dff0ef          	jal	582 <putc>
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 6fa:	4981                	li	s3,0
 6fc:	b769                	j	686 <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 10, 1);
 6fe:	008b8913          	addi	s2,s7,8
 702:	4685                	li	a3,1
 704:	4629                	li	a2,10
 706:	000ba583          	lw	a1,0(s7)
 70a:	855a                	mv	a0,s6
 70c:	e95ff0ef          	jal	5a0 <printint>
 710:	8bca                	mv	s7,s2
      state = 0;
 712:	4981                	li	s3,0
 714:	bf8d                	j	686 <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'd'){
 716:	06400793          	li	a5,100
 71a:	02f68963          	beq	a3,a5,74c <vprintf+0x110>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 71e:	06c00793          	li	a5,108
 722:	04f68263          	beq	a3,a5,766 <vprintf+0x12a>
      } else if(c0 == 'l' && c1 == 'u'){
 726:	07500793          	li	a5,117
 72a:	0af68063          	beq	a3,a5,7ca <vprintf+0x18e>
      } else if(c0 == 'l' && c1 == 'x'){
 72e:	07800793          	li	a5,120
 732:	0ef68263          	beq	a3,a5,816 <vprintf+0x1da>
        putc(fd, '%');
 736:	02500593          	li	a1,37
 73a:	855a                	mv	a0,s6
 73c:	e47ff0ef          	jal	582 <putc>
        putc(fd, c0);
 740:	85ca                	mv	a1,s2
 742:	855a                	mv	a0,s6
 744:	e3fff0ef          	jal	582 <putc>
      state = 0;
 748:	4981                	li	s3,0
 74a:	bf35                	j	686 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 74c:	008b8913          	addi	s2,s7,8
 750:	4685                	li	a3,1
 752:	4629                	li	a2,10
 754:	000bb583          	ld	a1,0(s7)
 758:	855a                	mv	a0,s6
 75a:	e47ff0ef          	jal	5a0 <printint>
        i += 1;
 75e:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 760:	8bca                	mv	s7,s2
      state = 0;
 762:	4981                	li	s3,0
        i += 1;
 764:	b70d                	j	686 <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 766:	06400793          	li	a5,100
 76a:	02f60763          	beq	a2,a5,798 <vprintf+0x15c>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 76e:	07500793          	li	a5,117
 772:	06f60963          	beq	a2,a5,7e4 <vprintf+0x1a8>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 776:	07800793          	li	a5,120
 77a:	faf61ee3          	bne	a2,a5,736 <vprintf+0xfa>
        printint(fd, va_arg(ap, uint64), 16, 0);
 77e:	008b8913          	addi	s2,s7,8
 782:	4681                	li	a3,0
 784:	4641                	li	a2,16
 786:	000bb583          	ld	a1,0(s7)
 78a:	855a                	mv	a0,s6
 78c:	e15ff0ef          	jal	5a0 <printint>
        i += 2;
 790:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 792:	8bca                	mv	s7,s2
      state = 0;
 794:	4981                	li	s3,0
        i += 2;
 796:	bdc5                	j	686 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 798:	008b8913          	addi	s2,s7,8
 79c:	4685                	li	a3,1
 79e:	4629                	li	a2,10
 7a0:	000bb583          	ld	a1,0(s7)
 7a4:	855a                	mv	a0,s6
 7a6:	dfbff0ef          	jal	5a0 <printint>
        i += 2;
 7aa:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 7ac:	8bca                	mv	s7,s2
      state = 0;
 7ae:	4981                	li	s3,0
        i += 2;
 7b0:	bdd9                	j	686 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint32), 10, 0);
 7b2:	008b8913          	addi	s2,s7,8
 7b6:	4681                	li	a3,0
 7b8:	4629                	li	a2,10
 7ba:	000be583          	lwu	a1,0(s7)
 7be:	855a                	mv	a0,s6
 7c0:	de1ff0ef          	jal	5a0 <printint>
 7c4:	8bca                	mv	s7,s2
      state = 0;
 7c6:	4981                	li	s3,0
 7c8:	bd7d                	j	686 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 7ca:	008b8913          	addi	s2,s7,8
 7ce:	4681                	li	a3,0
 7d0:	4629                	li	a2,10
 7d2:	000bb583          	ld	a1,0(s7)
 7d6:	855a                	mv	a0,s6
 7d8:	dc9ff0ef          	jal	5a0 <printint>
        i += 1;
 7dc:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 7de:	8bca                	mv	s7,s2
      state = 0;
 7e0:	4981                	li	s3,0
        i += 1;
 7e2:	b555                	j	686 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 7e4:	008b8913          	addi	s2,s7,8
 7e8:	4681                	li	a3,0
 7ea:	4629                	li	a2,10
 7ec:	000bb583          	ld	a1,0(s7)
 7f0:	855a                	mv	a0,s6
 7f2:	dafff0ef          	jal	5a0 <printint>
        i += 2;
 7f6:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 7f8:	8bca                	mv	s7,s2
      state = 0;
 7fa:	4981                	li	s3,0
        i += 2;
 7fc:	b569                	j	686 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint32), 16, 0);
 7fe:	008b8913          	addi	s2,s7,8
 802:	4681                	li	a3,0
 804:	4641                	li	a2,16
 806:	000be583          	lwu	a1,0(s7)
 80a:	855a                	mv	a0,s6
 80c:	d95ff0ef          	jal	5a0 <printint>
 810:	8bca                	mv	s7,s2
      state = 0;
 812:	4981                	li	s3,0
 814:	bd8d                	j	686 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 16, 0);
 816:	008b8913          	addi	s2,s7,8
 81a:	4681                	li	a3,0
 81c:	4641                	li	a2,16
 81e:	000bb583          	ld	a1,0(s7)
 822:	855a                	mv	a0,s6
 824:	d7dff0ef          	jal	5a0 <printint>
        i += 1;
 828:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 82a:	8bca                	mv	s7,s2
      state = 0;
 82c:	4981                	li	s3,0
        i += 1;
 82e:	bda1                	j	686 <vprintf+0x4a>
 830:	e06a                	sd	s10,0(sp)
        printptr(fd, va_arg(ap, uint64));
 832:	008b8d13          	addi	s10,s7,8
 836:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 83a:	03000593          	li	a1,48
 83e:	855a                	mv	a0,s6
 840:	d43ff0ef          	jal	582 <putc>
  putc(fd, 'x');
 844:	07800593          	li	a1,120
 848:	855a                	mv	a0,s6
 84a:	d39ff0ef          	jal	582 <putc>
 84e:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 850:	00000b97          	auipc	s7,0x0
 854:	4a8b8b93          	addi	s7,s7,1192 # cf8 <digits>
 858:	03c9d793          	srli	a5,s3,0x3c
 85c:	97de                	add	a5,a5,s7
 85e:	0007c583          	lbu	a1,0(a5)
 862:	855a                	mv	a0,s6
 864:	d1fff0ef          	jal	582 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 868:	0992                	slli	s3,s3,0x4
 86a:	397d                	addiw	s2,s2,-1
 86c:	fe0916e3          	bnez	s2,858 <vprintf+0x21c>
        printptr(fd, va_arg(ap, uint64));
 870:	8bea                	mv	s7,s10
      state = 0;
 872:	4981                	li	s3,0
 874:	6d02                	ld	s10,0(sp)
 876:	bd01                	j	686 <vprintf+0x4a>
        putc(fd, va_arg(ap, uint32));
 878:	008b8913          	addi	s2,s7,8
 87c:	000bc583          	lbu	a1,0(s7)
 880:	855a                	mv	a0,s6
 882:	d01ff0ef          	jal	582 <putc>
 886:	8bca                	mv	s7,s2
      state = 0;
 888:	4981                	li	s3,0
 88a:	bbf5                	j	686 <vprintf+0x4a>
        if((s = va_arg(ap, char*)) == 0)
 88c:	008b8993          	addi	s3,s7,8
 890:	000bb903          	ld	s2,0(s7)
 894:	00090f63          	beqz	s2,8b2 <vprintf+0x276>
        for(; *s; s++)
 898:	00094583          	lbu	a1,0(s2)
 89c:	c195                	beqz	a1,8c0 <vprintf+0x284>
          putc(fd, *s);
 89e:	855a                	mv	a0,s6
 8a0:	ce3ff0ef          	jal	582 <putc>
        for(; *s; s++)
 8a4:	0905                	addi	s2,s2,1
 8a6:	00094583          	lbu	a1,0(s2)
 8aa:	f9f5                	bnez	a1,89e <vprintf+0x262>
        if((s = va_arg(ap, char*)) == 0)
 8ac:	8bce                	mv	s7,s3
      state = 0;
 8ae:	4981                	li	s3,0
 8b0:	bbd9                	j	686 <vprintf+0x4a>
          s = "(null)";
 8b2:	00000917          	auipc	s2,0x0
 8b6:	40e90913          	addi	s2,s2,1038 # cc0 <malloc+0x302>
        for(; *s; s++)
 8ba:	02800593          	li	a1,40
 8be:	b7c5                	j	89e <vprintf+0x262>
        if((s = va_arg(ap, char*)) == 0)
 8c0:	8bce                	mv	s7,s3
      state = 0;
 8c2:	4981                	li	s3,0
 8c4:	b3c9                	j	686 <vprintf+0x4a>
 8c6:	64a6                	ld	s1,72(sp)
 8c8:	79e2                	ld	s3,56(sp)
 8ca:	7a42                	ld	s4,48(sp)
 8cc:	7aa2                	ld	s5,40(sp)
 8ce:	7b02                	ld	s6,32(sp)
 8d0:	6be2                	ld	s7,24(sp)
 8d2:	6c42                	ld	s8,16(sp)
 8d4:	6ca2                	ld	s9,8(sp)
    }
  }
}
 8d6:	60e6                	ld	ra,88(sp)
 8d8:	6446                	ld	s0,80(sp)
 8da:	6906                	ld	s2,64(sp)
 8dc:	6125                	addi	sp,sp,96
 8de:	8082                	ret

00000000000008e0 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 8e0:	715d                	addi	sp,sp,-80
 8e2:	ec06                	sd	ra,24(sp)
 8e4:	e822                	sd	s0,16(sp)
 8e6:	1000                	addi	s0,sp,32
 8e8:	e010                	sd	a2,0(s0)
 8ea:	e414                	sd	a3,8(s0)
 8ec:	e818                	sd	a4,16(s0)
 8ee:	ec1c                	sd	a5,24(s0)
 8f0:	03043023          	sd	a6,32(s0)
 8f4:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 8f8:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 8fc:	8622                	mv	a2,s0
 8fe:	d3fff0ef          	jal	63c <vprintf>
}
 902:	60e2                	ld	ra,24(sp)
 904:	6442                	ld	s0,16(sp)
 906:	6161                	addi	sp,sp,80
 908:	8082                	ret

000000000000090a <printf>:

void
printf(const char *fmt, ...)
{
 90a:	711d                	addi	sp,sp,-96
 90c:	ec06                	sd	ra,24(sp)
 90e:	e822                	sd	s0,16(sp)
 910:	1000                	addi	s0,sp,32
 912:	e40c                	sd	a1,8(s0)
 914:	e810                	sd	a2,16(s0)
 916:	ec14                	sd	a3,24(s0)
 918:	f018                	sd	a4,32(s0)
 91a:	f41c                	sd	a5,40(s0)
 91c:	03043823          	sd	a6,48(s0)
 920:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 924:	00840613          	addi	a2,s0,8
 928:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 92c:	85aa                	mv	a1,a0
 92e:	4505                	li	a0,1
 930:	d0dff0ef          	jal	63c <vprintf>
}
 934:	60e2                	ld	ra,24(sp)
 936:	6442                	ld	s0,16(sp)
 938:	6125                	addi	sp,sp,96
 93a:	8082                	ret

000000000000093c <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 93c:	1141                	addi	sp,sp,-16
 93e:	e422                	sd	s0,8(sp)
 940:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 942:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 946:	00000797          	auipc	a5,0x0
 94a:	6ba7b783          	ld	a5,1722(a5) # 1000 <freep>
 94e:	a02d                	j	978 <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 950:	4618                	lw	a4,8(a2)
 952:	9f2d                	addw	a4,a4,a1
 954:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 958:	6398                	ld	a4,0(a5)
 95a:	6310                	ld	a2,0(a4)
 95c:	a83d                	j	99a <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 95e:	ff852703          	lw	a4,-8(a0)
 962:	9f31                	addw	a4,a4,a2
 964:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 966:	ff053683          	ld	a3,-16(a0)
 96a:	a091                	j	9ae <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 96c:	6398                	ld	a4,0(a5)
 96e:	00e7e463          	bltu	a5,a4,976 <free+0x3a>
 972:	00e6ea63          	bltu	a3,a4,986 <free+0x4a>
{
 976:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 978:	fed7fae3          	bgeu	a5,a3,96c <free+0x30>
 97c:	6398                	ld	a4,0(a5)
 97e:	00e6e463          	bltu	a3,a4,986 <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 982:	fee7eae3          	bltu	a5,a4,976 <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 986:	ff852583          	lw	a1,-8(a0)
 98a:	6390                	ld	a2,0(a5)
 98c:	02059813          	slli	a6,a1,0x20
 990:	01c85713          	srli	a4,a6,0x1c
 994:	9736                	add	a4,a4,a3
 996:	fae60de3          	beq	a2,a4,950 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 99a:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 99e:	4790                	lw	a2,8(a5)
 9a0:	02061593          	slli	a1,a2,0x20
 9a4:	01c5d713          	srli	a4,a1,0x1c
 9a8:	973e                	add	a4,a4,a5
 9aa:	fae68ae3          	beq	a3,a4,95e <free+0x22>
    p->s.ptr = bp->s.ptr;
 9ae:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 9b0:	00000717          	auipc	a4,0x0
 9b4:	64f73823          	sd	a5,1616(a4) # 1000 <freep>
}
 9b8:	6422                	ld	s0,8(sp)
 9ba:	0141                	addi	sp,sp,16
 9bc:	8082                	ret

00000000000009be <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 9be:	7139                	addi	sp,sp,-64
 9c0:	fc06                	sd	ra,56(sp)
 9c2:	f822                	sd	s0,48(sp)
 9c4:	f426                	sd	s1,40(sp)
 9c6:	ec4e                	sd	s3,24(sp)
 9c8:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 9ca:	02051493          	slli	s1,a0,0x20
 9ce:	9081                	srli	s1,s1,0x20
 9d0:	04bd                	addi	s1,s1,15
 9d2:	8091                	srli	s1,s1,0x4
 9d4:	0014899b          	addiw	s3,s1,1
 9d8:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 9da:	00000517          	auipc	a0,0x0
 9de:	62653503          	ld	a0,1574(a0) # 1000 <freep>
 9e2:	c915                	beqz	a0,a16 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 9e4:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 9e6:	4798                	lw	a4,8(a5)
 9e8:	08977a63          	bgeu	a4,s1,a7c <malloc+0xbe>
 9ec:	f04a                	sd	s2,32(sp)
 9ee:	e852                	sd	s4,16(sp)
 9f0:	e456                	sd	s5,8(sp)
 9f2:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 9f4:	8a4e                	mv	s4,s3
 9f6:	0009871b          	sext.w	a4,s3
 9fa:	6685                	lui	a3,0x1
 9fc:	00d77363          	bgeu	a4,a3,a02 <malloc+0x44>
 a00:	6a05                	lui	s4,0x1
 a02:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 a06:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 a0a:	00000917          	auipc	s2,0x0
 a0e:	5f690913          	addi	s2,s2,1526 # 1000 <freep>
  if(p == SBRK_ERROR)
 a12:	5afd                	li	s5,-1
 a14:	a081                	j	a54 <malloc+0x96>
 a16:	f04a                	sd	s2,32(sp)
 a18:	e852                	sd	s4,16(sp)
 a1a:	e456                	sd	s5,8(sp)
 a1c:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 a1e:	00000797          	auipc	a5,0x0
 a22:	5f278793          	addi	a5,a5,1522 # 1010 <base>
 a26:	00000717          	auipc	a4,0x0
 a2a:	5cf73d23          	sd	a5,1498(a4) # 1000 <freep>
 a2e:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 a30:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 a34:	b7c1                	j	9f4 <malloc+0x36>
        prevp->s.ptr = p->s.ptr;
 a36:	6398                	ld	a4,0(a5)
 a38:	e118                	sd	a4,0(a0)
 a3a:	a8a9                	j	a94 <malloc+0xd6>
  hp->s.size = nu;
 a3c:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 a40:	0541                	addi	a0,a0,16
 a42:	efbff0ef          	jal	93c <free>
  return freep;
 a46:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 a4a:	c12d                	beqz	a0,aac <malloc+0xee>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 a4c:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 a4e:	4798                	lw	a4,8(a5)
 a50:	02977263          	bgeu	a4,s1,a74 <malloc+0xb6>
    if(p == freep)
 a54:	00093703          	ld	a4,0(s2)
 a58:	853e                	mv	a0,a5
 a5a:	fef719e3          	bne	a4,a5,a4c <malloc+0x8e>
  p = sbrk(nu * sizeof(Header));
 a5e:	8552                	mv	a0,s4
 a60:	a1fff0ef          	jal	47e <sbrk>
  if(p == SBRK_ERROR)
 a64:	fd551ce3          	bne	a0,s5,a3c <malloc+0x7e>
        return 0;
 a68:	4501                	li	a0,0
 a6a:	7902                	ld	s2,32(sp)
 a6c:	6a42                	ld	s4,16(sp)
 a6e:	6aa2                	ld	s5,8(sp)
 a70:	6b02                	ld	s6,0(sp)
 a72:	a03d                	j	aa0 <malloc+0xe2>
 a74:	7902                	ld	s2,32(sp)
 a76:	6a42                	ld	s4,16(sp)
 a78:	6aa2                	ld	s5,8(sp)
 a7a:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 a7c:	fae48de3          	beq	s1,a4,a36 <malloc+0x78>
        p->s.size -= nunits;
 a80:	4137073b          	subw	a4,a4,s3
 a84:	c798                	sw	a4,8(a5)
        p += p->s.size;
 a86:	02071693          	slli	a3,a4,0x20
 a8a:	01c6d713          	srli	a4,a3,0x1c
 a8e:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 a90:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 a94:	00000717          	auipc	a4,0x0
 a98:	56a73623          	sd	a0,1388(a4) # 1000 <freep>
      return (void*)(p + 1);
 a9c:	01078513          	addi	a0,a5,16
  }
}
 aa0:	70e2                	ld	ra,56(sp)
 aa2:	7442                	ld	s0,48(sp)
 aa4:	74a2                	ld	s1,40(sp)
 aa6:	69e2                	ld	s3,24(sp)
 aa8:	6121                	addi	sp,sp,64
 aaa:	8082                	ret
 aac:	7902                	ld	s2,32(sp)
 aae:	6a42                	ld	s4,16(sp)
 ab0:	6aa2                	ld	s5,8(sp)
 ab2:	6b02                	ld	s6,0(sp)
 ab4:	b7f5                	j	aa0 <malloc+0xe2>
