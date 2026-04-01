
user/_schedexport:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
  }
}

int
main(void)
{
   0:	b5010113          	addi	sp,sp,-1200
   4:	4a113423          	sd	ra,1192(sp)
   8:	4a813023          	sd	s0,1184(sp)
   c:	48913c23          	sd	s1,1176(sp)
  10:	49213823          	sd	s2,1168(sp)
  14:	49313423          	sd	s3,1160(sp)
  18:	49413023          	sd	s4,1152(sp)
  1c:	47513c23          	sd	s5,1144(sp)
  20:	47613823          	sd	s6,1136(sp)
  24:	47713423          	sd	s7,1128(sp)
  28:	47813023          	sd	s8,1120(sp)
  2c:	45913c23          	sd	s9,1112(sp)
  30:	45a13823          	sd	s10,1104(sp)
  34:	45b13423          	sd	s11,1096(sp)
  38:	4b010413          	addi	s0,sp,1200
  struct sched_event ev[16];

  for(int round = 0; round < 5; round++){
  3c:	4b01                	li	s6,0
    int n = schedread(ev, 16);
  3e:	b5040d93          	addi	s11,s0,-1200
  42:	4d41                	li	s10,16
  } else if(e->event_type == SCHED_EV_ON_CPU){
  44:	4a09                	li	s4,2
  } else if(e->event_type == SCHED_EV_OFF_CPU){
  46:	4a8d                	li	s5,3
  48:	a041                	j	c8 <main+0xc8>
    printf("EV {\"seq\":%d,\"tick\":%d,\"type\":\"SCHED_INFO\",\"scheduler\":\"%s\",\"cpus\":%d,\"time_slice\":%d}\n",
  4a:	ff44a783          	lw	a5,-12(s1)
  4e:	ff04a703          	lw	a4,-16(s1)
  52:	fe048693          	addi	a3,s1,-32
  56:	fd84a603          	lw	a2,-40(s1)
  5a:	fd44a583          	lw	a1,-44(s1)
  5e:	855e                	mv	a0,s7
  60:	7ca000ef          	jal	82a <printf>
    printf("round=%d n=%d\n", round, n);

    for(int i = 0; i < n; i++){
  64:	04448493          	addi	s1,s1,68
  68:	05248963          	beq	s1,s2,ba <main+0xba>
  if(e->event_type == SCHED_EV_INFO){
  6c:	87a6                	mv	a5,s1
  6e:	fdc4a703          	lw	a4,-36(s1)
  72:	fd370ce3          	beq	a4,s3,4a <main+0x4a>
  } else if(e->event_type == SCHED_EV_ON_CPU){
  76:	03470463          	beq	a4,s4,9e <main+0x9e>
  } else if(e->event_type == SCHED_EV_OFF_CPU){
  7a:	ff5715e3          	bne	a4,s5,64 <main+0x64>
    printf("EV {\"seq\":%d,\"tick\":%d,\"type\":\"OFF_CPU\",\"cpu\":%d,\"pid\":%d,\"name\":\"%s\",\"state\":%d,\"reason\":%d}\n",
  7e:	0144a883          	lw	a7,20(s1)
  82:	0104a803          	lw	a6,16(s1)
  86:	ffc4a703          	lw	a4,-4(s1)
  8a:	ff84a683          	lw	a3,-8(s1)
  8e:	fd84a603          	lw	a2,-40(s1)
  92:	fd44a583          	lw	a1,-44(s1)
  96:	8566                	mv	a0,s9
  98:	792000ef          	jal	82a <printf>
  9c:	b7e1                	j	64 <main+0x64>
    printf("EV {\"seq\":%d,\"tick\":%d,\"type\":\"ON_CPU\",\"cpu\":%d,\"pid\":%d,\"name\":\"%s\",\"state\":%d}\n",
  9e:	0104a803          	lw	a6,16(s1)
  a2:	ffc4a703          	lw	a4,-4(s1)
  a6:	ff84a683          	lw	a3,-8(s1)
  aa:	fd84a603          	lw	a2,-40(s1)
  ae:	fd44a583          	lw	a1,-44(s1)
  b2:	8562                	mv	a0,s8
  b4:	776000ef          	jal	82a <printf>
  b8:	b775                	j	64 <main+0x64>
      print_sched_event(&ev[i]);
    }

    pause(10);
  ba:	4529                	li	a0,10
  bc:	3a0000ef          	jal	45c <pause>
  for(int round = 0; round < 5; round++){
  c0:	2b05                	addiw	s6,s6,1
  c2:	4795                	li	a5,5
  c4:	04fb0663          	beq	s6,a5,110 <main+0x110>
    int n = schedread(ev, 16);
  c8:	85ea                	mv	a1,s10
  ca:	856e                	mv	a0,s11
  cc:	3b0000ef          	jal	47c <schedread>
  d0:	89aa                	mv	s3,a0
    printf("round=%d n=%d\n", round, n);
  d2:	862a                	mv	a2,a0
  d4:	85da                	mv	a1,s6
  d6:	00001517          	auipc	a0,0x1
  da:	90a50513          	addi	a0,a0,-1782 # 9e0 <malloc+0xfe>
  de:	74c000ef          	jal	82a <printf>
    for(int i = 0; i < n; i++){
  e2:	fd305ce3          	blez	s3,ba <main+0xba>
  e6:	b7c40493          	addi	s1,s0,-1156
  ea:	00499913          	slli	s2,s3,0x4
  ee:	994e                	add	s2,s2,s3
  f0:	090a                	slli	s2,s2,0x2
  f2:	9926                	add	s2,s2,s1
  if(e->event_type == SCHED_EV_INFO){
  f4:	4985                	li	s3,1
    printf("EV {\"seq\":%d,\"tick\":%d,\"type\":\"OFF_CPU\",\"cpu\":%d,\"pid\":%d,\"name\":\"%s\",\"state\":%d,\"reason\":%d}\n",
  f6:	00001c97          	auipc	s9,0x1
  fa:	9b2c8c93          	addi	s9,s9,-1614 # aa8 <malloc+0x1c6>
    printf("EV {\"seq\":%d,\"tick\":%d,\"type\":\"ON_CPU\",\"cpu\":%d,\"pid\":%d,\"name\":\"%s\",\"state\":%d}\n",
  fe:	00001c17          	auipc	s8,0x1
 102:	952c0c13          	addi	s8,s8,-1710 # a50 <malloc+0x16e>
    printf("EV {\"seq\":%d,\"tick\":%d,\"type\":\"SCHED_INFO\",\"scheduler\":\"%s\",\"cpus\":%d,\"time_slice\":%d}\n",
 106:	00001b97          	auipc	s7,0x1
 10a:	8f2b8b93          	addi	s7,s7,-1806 # 9f8 <malloc+0x116>
 10e:	bfb9                	j	6c <main+0x6c>
  }

  exit(0);
 110:	4501                	li	a0,0
 112:	2ba000ef          	jal	3cc <exit>

0000000000000116 <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start(int argc, char **argv)
{
 116:	1141                	addi	sp,sp,-16
 118:	e406                	sd	ra,8(sp)
 11a:	e022                	sd	s0,0(sp)
 11c:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
 11e:	ee3ff0ef          	jal	0 <main>
  exit(r);
 122:	2aa000ef          	jal	3cc <exit>

0000000000000126 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 126:	1141                	addi	sp,sp,-16
 128:	e406                	sd	ra,8(sp)
 12a:	e022                	sd	s0,0(sp)
 12c:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 12e:	87aa                	mv	a5,a0
 130:	0585                	addi	a1,a1,1
 132:	0785                	addi	a5,a5,1
 134:	fff5c703          	lbu	a4,-1(a1)
 138:	fee78fa3          	sb	a4,-1(a5)
 13c:	fb75                	bnez	a4,130 <strcpy+0xa>
    ;
  return os;
}
 13e:	60a2                	ld	ra,8(sp)
 140:	6402                	ld	s0,0(sp)
 142:	0141                	addi	sp,sp,16
 144:	8082                	ret

0000000000000146 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 146:	1141                	addi	sp,sp,-16
 148:	e406                	sd	ra,8(sp)
 14a:	e022                	sd	s0,0(sp)
 14c:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 14e:	00054783          	lbu	a5,0(a0)
 152:	cb91                	beqz	a5,166 <strcmp+0x20>
 154:	0005c703          	lbu	a4,0(a1)
 158:	00f71763          	bne	a4,a5,166 <strcmp+0x20>
    p++, q++;
 15c:	0505                	addi	a0,a0,1
 15e:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 160:	00054783          	lbu	a5,0(a0)
 164:	fbe5                	bnez	a5,154 <strcmp+0xe>
  return (uchar)*p - (uchar)*q;
 166:	0005c503          	lbu	a0,0(a1)
}
 16a:	40a7853b          	subw	a0,a5,a0
 16e:	60a2                	ld	ra,8(sp)
 170:	6402                	ld	s0,0(sp)
 172:	0141                	addi	sp,sp,16
 174:	8082                	ret

0000000000000176 <strlen>:

uint
strlen(const char *s)
{
 176:	1141                	addi	sp,sp,-16
 178:	e406                	sd	ra,8(sp)
 17a:	e022                	sd	s0,0(sp)
 17c:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 17e:	00054783          	lbu	a5,0(a0)
 182:	cf91                	beqz	a5,19e <strlen+0x28>
 184:	00150793          	addi	a5,a0,1
 188:	86be                	mv	a3,a5
 18a:	0785                	addi	a5,a5,1
 18c:	fff7c703          	lbu	a4,-1(a5)
 190:	ff65                	bnez	a4,188 <strlen+0x12>
 192:	40a6853b          	subw	a0,a3,a0
    ;
  return n;
}
 196:	60a2                	ld	ra,8(sp)
 198:	6402                	ld	s0,0(sp)
 19a:	0141                	addi	sp,sp,16
 19c:	8082                	ret
  for(n = 0; s[n]; n++)
 19e:	4501                	li	a0,0
 1a0:	bfdd                	j	196 <strlen+0x20>

00000000000001a2 <memset>:

void*
memset(void *dst, int c, uint n)
{
 1a2:	1141                	addi	sp,sp,-16
 1a4:	e406                	sd	ra,8(sp)
 1a6:	e022                	sd	s0,0(sp)
 1a8:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 1aa:	ca19                	beqz	a2,1c0 <memset+0x1e>
 1ac:	87aa                	mv	a5,a0
 1ae:	1602                	slli	a2,a2,0x20
 1b0:	9201                	srli	a2,a2,0x20
 1b2:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 1b6:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 1ba:	0785                	addi	a5,a5,1
 1bc:	fee79de3          	bne	a5,a4,1b6 <memset+0x14>
  }
  return dst;
}
 1c0:	60a2                	ld	ra,8(sp)
 1c2:	6402                	ld	s0,0(sp)
 1c4:	0141                	addi	sp,sp,16
 1c6:	8082                	ret

00000000000001c8 <strchr>:

char*
strchr(const char *s, char c)
{
 1c8:	1141                	addi	sp,sp,-16
 1ca:	e406                	sd	ra,8(sp)
 1cc:	e022                	sd	s0,0(sp)
 1ce:	0800                	addi	s0,sp,16
  for(; *s; s++)
 1d0:	00054783          	lbu	a5,0(a0)
 1d4:	cf81                	beqz	a5,1ec <strchr+0x24>
    if(*s == c)
 1d6:	00f58763          	beq	a1,a5,1e4 <strchr+0x1c>
  for(; *s; s++)
 1da:	0505                	addi	a0,a0,1
 1dc:	00054783          	lbu	a5,0(a0)
 1e0:	fbfd                	bnez	a5,1d6 <strchr+0xe>
      return (char*)s;
  return 0;
 1e2:	4501                	li	a0,0
}
 1e4:	60a2                	ld	ra,8(sp)
 1e6:	6402                	ld	s0,0(sp)
 1e8:	0141                	addi	sp,sp,16
 1ea:	8082                	ret
  return 0;
 1ec:	4501                	li	a0,0
 1ee:	bfdd                	j	1e4 <strchr+0x1c>

00000000000001f0 <gets>:

char*
gets(char *buf, int max)
{
 1f0:	711d                	addi	sp,sp,-96
 1f2:	ec86                	sd	ra,88(sp)
 1f4:	e8a2                	sd	s0,80(sp)
 1f6:	e4a6                	sd	s1,72(sp)
 1f8:	e0ca                	sd	s2,64(sp)
 1fa:	fc4e                	sd	s3,56(sp)
 1fc:	f852                	sd	s4,48(sp)
 1fe:	f456                	sd	s5,40(sp)
 200:	f05a                	sd	s6,32(sp)
 202:	ec5e                	sd	s7,24(sp)
 204:	e862                	sd	s8,16(sp)
 206:	1080                	addi	s0,sp,96
 208:	8baa                	mv	s7,a0
 20a:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 20c:	892a                	mv	s2,a0
 20e:	4481                	li	s1,0
    cc = read(0, &c, 1);
 210:	faf40b13          	addi	s6,s0,-81
 214:	4a85                	li	s5,1
  for(i=0; i+1 < max; ){
 216:	8c26                	mv	s8,s1
 218:	0014899b          	addiw	s3,s1,1
 21c:	84ce                	mv	s1,s3
 21e:	0349d463          	bge	s3,s4,246 <gets+0x56>
    cc = read(0, &c, 1);
 222:	8656                	mv	a2,s5
 224:	85da                	mv	a1,s6
 226:	4501                	li	a0,0
 228:	1bc000ef          	jal	3e4 <read>
    if(cc < 1)
 22c:	00a05d63          	blez	a0,246 <gets+0x56>
      break;
    buf[i++] = c;
 230:	faf44783          	lbu	a5,-81(s0)
 234:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 238:	0905                	addi	s2,s2,1
 23a:	ff678713          	addi	a4,a5,-10
 23e:	c319                	beqz	a4,244 <gets+0x54>
 240:	17cd                	addi	a5,a5,-13
 242:	fbf1                	bnez	a5,216 <gets+0x26>
    buf[i++] = c;
 244:	8c4e                	mv	s8,s3
      break;
  }
  buf[i] = '\0';
 246:	9c5e                	add	s8,s8,s7
 248:	000c0023          	sb	zero,0(s8)
  return buf;
}
 24c:	855e                	mv	a0,s7
 24e:	60e6                	ld	ra,88(sp)
 250:	6446                	ld	s0,80(sp)
 252:	64a6                	ld	s1,72(sp)
 254:	6906                	ld	s2,64(sp)
 256:	79e2                	ld	s3,56(sp)
 258:	7a42                	ld	s4,48(sp)
 25a:	7aa2                	ld	s5,40(sp)
 25c:	7b02                	ld	s6,32(sp)
 25e:	6be2                	ld	s7,24(sp)
 260:	6c42                	ld	s8,16(sp)
 262:	6125                	addi	sp,sp,96
 264:	8082                	ret

0000000000000266 <stat>:

int
stat(const char *n, struct stat *st)
{
 266:	1101                	addi	sp,sp,-32
 268:	ec06                	sd	ra,24(sp)
 26a:	e822                	sd	s0,16(sp)
 26c:	e04a                	sd	s2,0(sp)
 26e:	1000                	addi	s0,sp,32
 270:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 272:	4581                	li	a1,0
 274:	198000ef          	jal	40c <open>
  if(fd < 0)
 278:	02054263          	bltz	a0,29c <stat+0x36>
 27c:	e426                	sd	s1,8(sp)
 27e:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 280:	85ca                	mv	a1,s2
 282:	1a2000ef          	jal	424 <fstat>
 286:	892a                	mv	s2,a0
  close(fd);
 288:	8526                	mv	a0,s1
 28a:	16a000ef          	jal	3f4 <close>
  return r;
 28e:	64a2                	ld	s1,8(sp)
}
 290:	854a                	mv	a0,s2
 292:	60e2                	ld	ra,24(sp)
 294:	6442                	ld	s0,16(sp)
 296:	6902                	ld	s2,0(sp)
 298:	6105                	addi	sp,sp,32
 29a:	8082                	ret
    return -1;
 29c:	57fd                	li	a5,-1
 29e:	893e                	mv	s2,a5
 2a0:	bfc5                	j	290 <stat+0x2a>

00000000000002a2 <atoi>:

int
atoi(const char *s)
{
 2a2:	1141                	addi	sp,sp,-16
 2a4:	e406                	sd	ra,8(sp)
 2a6:	e022                	sd	s0,0(sp)
 2a8:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 2aa:	00054683          	lbu	a3,0(a0)
 2ae:	fd06879b          	addiw	a5,a3,-48
 2b2:	0ff7f793          	zext.b	a5,a5
 2b6:	4625                	li	a2,9
 2b8:	02f66963          	bltu	a2,a5,2ea <atoi+0x48>
 2bc:	872a                	mv	a4,a0
  n = 0;
 2be:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 2c0:	0705                	addi	a4,a4,1
 2c2:	0025179b          	slliw	a5,a0,0x2
 2c6:	9fa9                	addw	a5,a5,a0
 2c8:	0017979b          	slliw	a5,a5,0x1
 2cc:	9fb5                	addw	a5,a5,a3
 2ce:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 2d2:	00074683          	lbu	a3,0(a4)
 2d6:	fd06879b          	addiw	a5,a3,-48
 2da:	0ff7f793          	zext.b	a5,a5
 2de:	fef671e3          	bgeu	a2,a5,2c0 <atoi+0x1e>
  return n;
}
 2e2:	60a2                	ld	ra,8(sp)
 2e4:	6402                	ld	s0,0(sp)
 2e6:	0141                	addi	sp,sp,16
 2e8:	8082                	ret
  n = 0;
 2ea:	4501                	li	a0,0
 2ec:	bfdd                	j	2e2 <atoi+0x40>

00000000000002ee <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 2ee:	1141                	addi	sp,sp,-16
 2f0:	e406                	sd	ra,8(sp)
 2f2:	e022                	sd	s0,0(sp)
 2f4:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 2f6:	02b57563          	bgeu	a0,a1,320 <memmove+0x32>
    while(n-- > 0)
 2fa:	00c05f63          	blez	a2,318 <memmove+0x2a>
 2fe:	1602                	slli	a2,a2,0x20
 300:	9201                	srli	a2,a2,0x20
 302:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 306:	872a                	mv	a4,a0
      *dst++ = *src++;
 308:	0585                	addi	a1,a1,1
 30a:	0705                	addi	a4,a4,1
 30c:	fff5c683          	lbu	a3,-1(a1)
 310:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 314:	fee79ae3          	bne	a5,a4,308 <memmove+0x1a>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 318:	60a2                	ld	ra,8(sp)
 31a:	6402                	ld	s0,0(sp)
 31c:	0141                	addi	sp,sp,16
 31e:	8082                	ret
    while(n-- > 0)
 320:	fec05ce3          	blez	a2,318 <memmove+0x2a>
    dst += n;
 324:	00c50733          	add	a4,a0,a2
    src += n;
 328:	95b2                	add	a1,a1,a2
 32a:	fff6079b          	addiw	a5,a2,-1
 32e:	1782                	slli	a5,a5,0x20
 330:	9381                	srli	a5,a5,0x20
 332:	fff7c793          	not	a5,a5
 336:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 338:	15fd                	addi	a1,a1,-1
 33a:	177d                	addi	a4,a4,-1
 33c:	0005c683          	lbu	a3,0(a1)
 340:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 344:	fef71ae3          	bne	a4,a5,338 <memmove+0x4a>
 348:	bfc1                	j	318 <memmove+0x2a>

000000000000034a <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 34a:	1141                	addi	sp,sp,-16
 34c:	e406                	sd	ra,8(sp)
 34e:	e022                	sd	s0,0(sp)
 350:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 352:	c61d                	beqz	a2,380 <memcmp+0x36>
 354:	1602                	slli	a2,a2,0x20
 356:	9201                	srli	a2,a2,0x20
 358:	00c506b3          	add	a3,a0,a2
    if (*p1 != *p2) {
 35c:	00054783          	lbu	a5,0(a0)
 360:	0005c703          	lbu	a4,0(a1)
 364:	00e79863          	bne	a5,a4,374 <memcmp+0x2a>
      return *p1 - *p2;
    }
    p1++;
 368:	0505                	addi	a0,a0,1
    p2++;
 36a:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 36c:	fed518e3          	bne	a0,a3,35c <memcmp+0x12>
  }
  return 0;
 370:	4501                	li	a0,0
 372:	a019                	j	378 <memcmp+0x2e>
      return *p1 - *p2;
 374:	40e7853b          	subw	a0,a5,a4
}
 378:	60a2                	ld	ra,8(sp)
 37a:	6402                	ld	s0,0(sp)
 37c:	0141                	addi	sp,sp,16
 37e:	8082                	ret
  return 0;
 380:	4501                	li	a0,0
 382:	bfdd                	j	378 <memcmp+0x2e>

0000000000000384 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 384:	1141                	addi	sp,sp,-16
 386:	e406                	sd	ra,8(sp)
 388:	e022                	sd	s0,0(sp)
 38a:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 38c:	f63ff0ef          	jal	2ee <memmove>
}
 390:	60a2                	ld	ra,8(sp)
 392:	6402                	ld	s0,0(sp)
 394:	0141                	addi	sp,sp,16
 396:	8082                	ret

0000000000000398 <sbrk>:

char *
sbrk(int n) {
 398:	1141                	addi	sp,sp,-16
 39a:	e406                	sd	ra,8(sp)
 39c:	e022                	sd	s0,0(sp)
 39e:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
 3a0:	4585                	li	a1,1
 3a2:	0b2000ef          	jal	454 <sys_sbrk>
}
 3a6:	60a2                	ld	ra,8(sp)
 3a8:	6402                	ld	s0,0(sp)
 3aa:	0141                	addi	sp,sp,16
 3ac:	8082                	ret

00000000000003ae <sbrklazy>:

char *
sbrklazy(int n) {
 3ae:	1141                	addi	sp,sp,-16
 3b0:	e406                	sd	ra,8(sp)
 3b2:	e022                	sd	s0,0(sp)
 3b4:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 3b6:	4589                	li	a1,2
 3b8:	09c000ef          	jal	454 <sys_sbrk>
}
 3bc:	60a2                	ld	ra,8(sp)
 3be:	6402                	ld	s0,0(sp)
 3c0:	0141                	addi	sp,sp,16
 3c2:	8082                	ret

00000000000003c4 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 3c4:	4885                	li	a7,1
 ecall
 3c6:	00000073          	ecall
 ret
 3ca:	8082                	ret

00000000000003cc <exit>:
.global exit
exit:
 li a7, SYS_exit
 3cc:	4889                	li	a7,2
 ecall
 3ce:	00000073          	ecall
 ret
 3d2:	8082                	ret

00000000000003d4 <wait>:
.global wait
wait:
 li a7, SYS_wait
 3d4:	488d                	li	a7,3
 ecall
 3d6:	00000073          	ecall
 ret
 3da:	8082                	ret

00000000000003dc <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 3dc:	4891                	li	a7,4
 ecall
 3de:	00000073          	ecall
 ret
 3e2:	8082                	ret

00000000000003e4 <read>:
.global read
read:
 li a7, SYS_read
 3e4:	4895                	li	a7,5
 ecall
 3e6:	00000073          	ecall
 ret
 3ea:	8082                	ret

00000000000003ec <write>:
.global write
write:
 li a7, SYS_write
 3ec:	48c1                	li	a7,16
 ecall
 3ee:	00000073          	ecall
 ret
 3f2:	8082                	ret

00000000000003f4 <close>:
.global close
close:
 li a7, SYS_close
 3f4:	48d5                	li	a7,21
 ecall
 3f6:	00000073          	ecall
 ret
 3fa:	8082                	ret

00000000000003fc <kill>:
.global kill
kill:
 li a7, SYS_kill
 3fc:	4899                	li	a7,6
 ecall
 3fe:	00000073          	ecall
 ret
 402:	8082                	ret

0000000000000404 <exec>:
.global exec
exec:
 li a7, SYS_exec
 404:	489d                	li	a7,7
 ecall
 406:	00000073          	ecall
 ret
 40a:	8082                	ret

000000000000040c <open>:
.global open
open:
 li a7, SYS_open
 40c:	48bd                	li	a7,15
 ecall
 40e:	00000073          	ecall
 ret
 412:	8082                	ret

0000000000000414 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 414:	48c5                	li	a7,17
 ecall
 416:	00000073          	ecall
 ret
 41a:	8082                	ret

000000000000041c <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 41c:	48c9                	li	a7,18
 ecall
 41e:	00000073          	ecall
 ret
 422:	8082                	ret

0000000000000424 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 424:	48a1                	li	a7,8
 ecall
 426:	00000073          	ecall
 ret
 42a:	8082                	ret

000000000000042c <link>:
.global link
link:
 li a7, SYS_link
 42c:	48cd                	li	a7,19
 ecall
 42e:	00000073          	ecall
 ret
 432:	8082                	ret

0000000000000434 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 434:	48d1                	li	a7,20
 ecall
 436:	00000073          	ecall
 ret
 43a:	8082                	ret

000000000000043c <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 43c:	48a5                	li	a7,9
 ecall
 43e:	00000073          	ecall
 ret
 442:	8082                	ret

0000000000000444 <dup>:
.global dup
dup:
 li a7, SYS_dup
 444:	48a9                	li	a7,10
 ecall
 446:	00000073          	ecall
 ret
 44a:	8082                	ret

000000000000044c <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 44c:	48ad                	li	a7,11
 ecall
 44e:	00000073          	ecall
 ret
 452:	8082                	ret

0000000000000454 <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 454:	48b1                	li	a7,12
 ecall
 456:	00000073          	ecall
 ret
 45a:	8082                	ret

000000000000045c <pause>:
.global pause
pause:
 li a7, SYS_pause
 45c:	48b5                	li	a7,13
 ecall
 45e:	00000073          	ecall
 ret
 462:	8082                	ret

0000000000000464 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 464:	48b9                	li	a7,14
 ecall
 466:	00000073          	ecall
 ret
 46a:	8082                	ret

000000000000046c <csread>:
.global csread
csread:
 li a7, SYS_csread
 46c:	48d9                	li	a7,22
 ecall
 46e:	00000073          	ecall
 ret
 472:	8082                	ret

0000000000000474 <fsread>:
.global fsread
fsread:
 li a7, SYS_fsread
 474:	48dd                	li	a7,23
 ecall
 476:	00000073          	ecall
 ret
 47a:	8082                	ret

000000000000047c <schedread>:
.global schedread
schedread:
 li a7, SYS_schedread
 47c:	48e1                	li	a7,24
 ecall
 47e:	00000073          	ecall
 ret
 482:	8082                	ret

0000000000000484 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 484:	1101                	addi	sp,sp,-32
 486:	ec06                	sd	ra,24(sp)
 488:	e822                	sd	s0,16(sp)
 48a:	1000                	addi	s0,sp,32
 48c:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 490:	4605                	li	a2,1
 492:	fef40593          	addi	a1,s0,-17
 496:	f57ff0ef          	jal	3ec <write>
}
 49a:	60e2                	ld	ra,24(sp)
 49c:	6442                	ld	s0,16(sp)
 49e:	6105                	addi	sp,sp,32
 4a0:	8082                	ret

00000000000004a2 <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
 4a2:	715d                	addi	sp,sp,-80
 4a4:	e486                	sd	ra,72(sp)
 4a6:	e0a2                	sd	s0,64(sp)
 4a8:	f84a                	sd	s2,48(sp)
 4aa:	f44e                	sd	s3,40(sp)
 4ac:	0880                	addi	s0,sp,80
 4ae:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
 4b0:	c6d1                	beqz	a3,53c <printint+0x9a>
 4b2:	0805d563          	bgez	a1,53c <printint+0x9a>
    neg = 1;
    x = -xx;
 4b6:	40b005b3          	neg	a1,a1
    neg = 1;
 4ba:	4305                	li	t1,1
  } else {
    x = xx;
  }

  i = 0;
 4bc:	fb840993          	addi	s3,s0,-72
  neg = 0;
 4c0:	86ce                	mv	a3,s3
  i = 0;
 4c2:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 4c4:	00000817          	auipc	a6,0x0
 4c8:	64c80813          	addi	a6,a6,1612 # b10 <digits>
 4cc:	88ba                	mv	a7,a4
 4ce:	0017051b          	addiw	a0,a4,1
 4d2:	872a                	mv	a4,a0
 4d4:	02c5f7b3          	remu	a5,a1,a2
 4d8:	97c2                	add	a5,a5,a6
 4da:	0007c783          	lbu	a5,0(a5)
 4de:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 4e2:	87ae                	mv	a5,a1
 4e4:	02c5d5b3          	divu	a1,a1,a2
 4e8:	0685                	addi	a3,a3,1
 4ea:	fec7f1e3          	bgeu	a5,a2,4cc <printint+0x2a>
  if(neg)
 4ee:	00030c63          	beqz	t1,506 <printint+0x64>
    buf[i++] = '-';
 4f2:	fd050793          	addi	a5,a0,-48
 4f6:	00878533          	add	a0,a5,s0
 4fa:	02d00793          	li	a5,45
 4fe:	fef50423          	sb	a5,-24(a0)
 502:	0028871b          	addiw	a4,a7,2

  while(--i >= 0)
 506:	02e05563          	blez	a4,530 <printint+0x8e>
 50a:	fc26                	sd	s1,56(sp)
 50c:	377d                	addiw	a4,a4,-1
 50e:	00e984b3          	add	s1,s3,a4
 512:	19fd                	addi	s3,s3,-1
 514:	99ba                	add	s3,s3,a4
 516:	1702                	slli	a4,a4,0x20
 518:	9301                	srli	a4,a4,0x20
 51a:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 51e:	0004c583          	lbu	a1,0(s1)
 522:	854a                	mv	a0,s2
 524:	f61ff0ef          	jal	484 <putc>
  while(--i >= 0)
 528:	14fd                	addi	s1,s1,-1
 52a:	ff349ae3          	bne	s1,s3,51e <printint+0x7c>
 52e:	74e2                	ld	s1,56(sp)
}
 530:	60a6                	ld	ra,72(sp)
 532:	6406                	ld	s0,64(sp)
 534:	7942                	ld	s2,48(sp)
 536:	79a2                	ld	s3,40(sp)
 538:	6161                	addi	sp,sp,80
 53a:	8082                	ret
  neg = 0;
 53c:	4301                	li	t1,0
 53e:	bfbd                	j	4bc <printint+0x1a>

0000000000000540 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 540:	711d                	addi	sp,sp,-96
 542:	ec86                	sd	ra,88(sp)
 544:	e8a2                	sd	s0,80(sp)
 546:	e4a6                	sd	s1,72(sp)
 548:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 54a:	0005c483          	lbu	s1,0(a1)
 54e:	22048363          	beqz	s1,774 <vprintf+0x234>
 552:	e0ca                	sd	s2,64(sp)
 554:	fc4e                	sd	s3,56(sp)
 556:	f852                	sd	s4,48(sp)
 558:	f456                	sd	s5,40(sp)
 55a:	f05a                	sd	s6,32(sp)
 55c:	ec5e                	sd	s7,24(sp)
 55e:	e862                	sd	s8,16(sp)
 560:	8b2a                	mv	s6,a0
 562:	8a2e                	mv	s4,a1
 564:	8bb2                	mv	s7,a2
  state = 0;
 566:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 568:	4901                	li	s2,0
 56a:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 56c:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 570:	06400c13          	li	s8,100
 574:	a00d                	j	596 <vprintf+0x56>
        putc(fd, c0);
 576:	85a6                	mv	a1,s1
 578:	855a                	mv	a0,s6
 57a:	f0bff0ef          	jal	484 <putc>
 57e:	a019                	j	584 <vprintf+0x44>
    } else if(state == '%'){
 580:	03598363          	beq	s3,s5,5a6 <vprintf+0x66>
  for(i = 0; fmt[i]; i++){
 584:	0019079b          	addiw	a5,s2,1
 588:	893e                	mv	s2,a5
 58a:	873e                	mv	a4,a5
 58c:	97d2                	add	a5,a5,s4
 58e:	0007c483          	lbu	s1,0(a5)
 592:	1c048a63          	beqz	s1,766 <vprintf+0x226>
    c0 = fmt[i] & 0xff;
 596:	0004879b          	sext.w	a5,s1
    if(state == 0){
 59a:	fe0993e3          	bnez	s3,580 <vprintf+0x40>
      if(c0 == '%'){
 59e:	fd579ce3          	bne	a5,s5,576 <vprintf+0x36>
        state = '%';
 5a2:	89be                	mv	s3,a5
 5a4:	b7c5                	j	584 <vprintf+0x44>
      if(c0) c1 = fmt[i+1] & 0xff;
 5a6:	00ea06b3          	add	a3,s4,a4
 5aa:	0016c603          	lbu	a2,1(a3)
      if(c1) c2 = fmt[i+2] & 0xff;
 5ae:	1c060863          	beqz	a2,77e <vprintf+0x23e>
      if(c0 == 'd'){
 5b2:	03878763          	beq	a5,s8,5e0 <vprintf+0xa0>
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 5b6:	f9478693          	addi	a3,a5,-108
 5ba:	0016b693          	seqz	a3,a3
 5be:	f9c60593          	addi	a1,a2,-100
 5c2:	e99d                	bnez	a1,5f8 <vprintf+0xb8>
 5c4:	ca95                	beqz	a3,5f8 <vprintf+0xb8>
        printint(fd, va_arg(ap, uint64), 10, 1);
 5c6:	008b8493          	addi	s1,s7,8
 5ca:	4685                	li	a3,1
 5cc:	4629                	li	a2,10
 5ce:	000bb583          	ld	a1,0(s7)
 5d2:	855a                	mv	a0,s6
 5d4:	ecfff0ef          	jal	4a2 <printint>
        i += 1;
 5d8:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 5da:	8ba6                	mv	s7,s1
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 5dc:	4981                	li	s3,0
 5de:	b75d                	j	584 <vprintf+0x44>
        printint(fd, va_arg(ap, int), 10, 1);
 5e0:	008b8493          	addi	s1,s7,8
 5e4:	4685                	li	a3,1
 5e6:	4629                	li	a2,10
 5e8:	000ba583          	lw	a1,0(s7)
 5ec:	855a                	mv	a0,s6
 5ee:	eb5ff0ef          	jal	4a2 <printint>
 5f2:	8ba6                	mv	s7,s1
      state = 0;
 5f4:	4981                	li	s3,0
 5f6:	b779                	j	584 <vprintf+0x44>
      if(c1) c2 = fmt[i+2] & 0xff;
 5f8:	9752                	add	a4,a4,s4
 5fa:	00274583          	lbu	a1,2(a4)
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 5fe:	f9460713          	addi	a4,a2,-108
 602:	00173713          	seqz	a4,a4
 606:	8f75                	and	a4,a4,a3
 608:	f9c58513          	addi	a0,a1,-100
 60c:	18051363          	bnez	a0,792 <vprintf+0x252>
 610:	18070163          	beqz	a4,792 <vprintf+0x252>
        printint(fd, va_arg(ap, uint64), 10, 1);
 614:	008b8493          	addi	s1,s7,8
 618:	4685                	li	a3,1
 61a:	4629                	li	a2,10
 61c:	000bb583          	ld	a1,0(s7)
 620:	855a                	mv	a0,s6
 622:	e81ff0ef          	jal	4a2 <printint>
        i += 2;
 626:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 628:	8ba6                	mv	s7,s1
      state = 0;
 62a:	4981                	li	s3,0
        i += 2;
 62c:	bfa1                	j	584 <vprintf+0x44>
        printint(fd, va_arg(ap, uint32), 10, 0);
 62e:	008b8493          	addi	s1,s7,8
 632:	4681                	li	a3,0
 634:	4629                	li	a2,10
 636:	000be583          	lwu	a1,0(s7)
 63a:	855a                	mv	a0,s6
 63c:	e67ff0ef          	jal	4a2 <printint>
 640:	8ba6                	mv	s7,s1
      state = 0;
 642:	4981                	li	s3,0
 644:	b781                	j	584 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
 646:	008b8493          	addi	s1,s7,8
 64a:	4681                	li	a3,0
 64c:	4629                	li	a2,10
 64e:	000bb583          	ld	a1,0(s7)
 652:	855a                	mv	a0,s6
 654:	e4fff0ef          	jal	4a2 <printint>
        i += 1;
 658:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 65a:	8ba6                	mv	s7,s1
      state = 0;
 65c:	4981                	li	s3,0
 65e:	b71d                	j	584 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
 660:	008b8493          	addi	s1,s7,8
 664:	4681                	li	a3,0
 666:	4629                	li	a2,10
 668:	000bb583          	ld	a1,0(s7)
 66c:	855a                	mv	a0,s6
 66e:	e35ff0ef          	jal	4a2 <printint>
        i += 2;
 672:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 674:	8ba6                	mv	s7,s1
      state = 0;
 676:	4981                	li	s3,0
        i += 2;
 678:	b731                	j	584 <vprintf+0x44>
        printint(fd, va_arg(ap, uint32), 16, 0);
 67a:	008b8493          	addi	s1,s7,8
 67e:	4681                	li	a3,0
 680:	4641                	li	a2,16
 682:	000be583          	lwu	a1,0(s7)
 686:	855a                	mv	a0,s6
 688:	e1bff0ef          	jal	4a2 <printint>
 68c:	8ba6                	mv	s7,s1
      state = 0;
 68e:	4981                	li	s3,0
 690:	bdd5                	j	584 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 16, 0);
 692:	008b8493          	addi	s1,s7,8
 696:	4681                	li	a3,0
 698:	4641                	li	a2,16
 69a:	000bb583          	ld	a1,0(s7)
 69e:	855a                	mv	a0,s6
 6a0:	e03ff0ef          	jal	4a2 <printint>
        i += 1;
 6a4:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 6a6:	8ba6                	mv	s7,s1
      state = 0;
 6a8:	4981                	li	s3,0
 6aa:	bde9                	j	584 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 16, 0);
 6ac:	008b8493          	addi	s1,s7,8
 6b0:	4681                	li	a3,0
 6b2:	4641                	li	a2,16
 6b4:	000bb583          	ld	a1,0(s7)
 6b8:	855a                	mv	a0,s6
 6ba:	de9ff0ef          	jal	4a2 <printint>
        i += 2;
 6be:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 6c0:	8ba6                	mv	s7,s1
      state = 0;
 6c2:	4981                	li	s3,0
        i += 2;
 6c4:	b5c1                	j	584 <vprintf+0x44>
 6c6:	e466                	sd	s9,8(sp)
        printptr(fd, va_arg(ap, uint64));
 6c8:	008b8793          	addi	a5,s7,8
 6cc:	8cbe                	mv	s9,a5
 6ce:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 6d2:	03000593          	li	a1,48
 6d6:	855a                	mv	a0,s6
 6d8:	dadff0ef          	jal	484 <putc>
  putc(fd, 'x');
 6dc:	07800593          	li	a1,120
 6e0:	855a                	mv	a0,s6
 6e2:	da3ff0ef          	jal	484 <putc>
 6e6:	44c1                	li	s1,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 6e8:	00000b97          	auipc	s7,0x0
 6ec:	428b8b93          	addi	s7,s7,1064 # b10 <digits>
 6f0:	03c9d793          	srli	a5,s3,0x3c
 6f4:	97de                	add	a5,a5,s7
 6f6:	0007c583          	lbu	a1,0(a5)
 6fa:	855a                	mv	a0,s6
 6fc:	d89ff0ef          	jal	484 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 700:	0992                	slli	s3,s3,0x4
 702:	34fd                	addiw	s1,s1,-1
 704:	f4f5                	bnez	s1,6f0 <vprintf+0x1b0>
        printptr(fd, va_arg(ap, uint64));
 706:	8be6                	mv	s7,s9
      state = 0;
 708:	4981                	li	s3,0
 70a:	6ca2                	ld	s9,8(sp)
 70c:	bda5                	j	584 <vprintf+0x44>
        putc(fd, va_arg(ap, uint32));
 70e:	008b8493          	addi	s1,s7,8
 712:	000bc583          	lbu	a1,0(s7)
 716:	855a                	mv	a0,s6
 718:	d6dff0ef          	jal	484 <putc>
 71c:	8ba6                	mv	s7,s1
      state = 0;
 71e:	4981                	li	s3,0
 720:	b595                	j	584 <vprintf+0x44>
        if((s = va_arg(ap, char*)) == 0)
 722:	008b8993          	addi	s3,s7,8
 726:	000bb483          	ld	s1,0(s7)
 72a:	cc91                	beqz	s1,746 <vprintf+0x206>
        for(; *s; s++)
 72c:	0004c583          	lbu	a1,0(s1)
 730:	c985                	beqz	a1,760 <vprintf+0x220>
          putc(fd, *s);
 732:	855a                	mv	a0,s6
 734:	d51ff0ef          	jal	484 <putc>
        for(; *s; s++)
 738:	0485                	addi	s1,s1,1
 73a:	0004c583          	lbu	a1,0(s1)
 73e:	f9f5                	bnez	a1,732 <vprintf+0x1f2>
        if((s = va_arg(ap, char*)) == 0)
 740:	8bce                	mv	s7,s3
      state = 0;
 742:	4981                	li	s3,0
 744:	b581                	j	584 <vprintf+0x44>
          s = "(null)";
 746:	00000497          	auipc	s1,0x0
 74a:	3c248493          	addi	s1,s1,962 # b08 <malloc+0x226>
        for(; *s; s++)
 74e:	02800593          	li	a1,40
 752:	b7c5                	j	732 <vprintf+0x1f2>
        putc(fd, '%');
 754:	85be                	mv	a1,a5
 756:	855a                	mv	a0,s6
 758:	d2dff0ef          	jal	484 <putc>
      state = 0;
 75c:	4981                	li	s3,0
 75e:	b51d                	j	584 <vprintf+0x44>
        if((s = va_arg(ap, char*)) == 0)
 760:	8bce                	mv	s7,s3
      state = 0;
 762:	4981                	li	s3,0
 764:	b505                	j	584 <vprintf+0x44>
 766:	6906                	ld	s2,64(sp)
 768:	79e2                	ld	s3,56(sp)
 76a:	7a42                	ld	s4,48(sp)
 76c:	7aa2                	ld	s5,40(sp)
 76e:	7b02                	ld	s6,32(sp)
 770:	6be2                	ld	s7,24(sp)
 772:	6c42                	ld	s8,16(sp)
    }
  }
}
 774:	60e6                	ld	ra,88(sp)
 776:	6446                	ld	s0,80(sp)
 778:	64a6                	ld	s1,72(sp)
 77a:	6125                	addi	sp,sp,96
 77c:	8082                	ret
      if(c0 == 'd'){
 77e:	06400713          	li	a4,100
 782:	e4e78fe3          	beq	a5,a4,5e0 <vprintf+0xa0>
      } else if(c0 == 'l' && c1 == 'd'){
 786:	f9478693          	addi	a3,a5,-108
 78a:	0016b693          	seqz	a3,a3
      c1 = c2 = 0;
 78e:	85b2                	mv	a1,a2
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 790:	4701                	li	a4,0
      } else if(c0 == 'u'){
 792:	07500513          	li	a0,117
 796:	e8a78ce3          	beq	a5,a0,62e <vprintf+0xee>
      } else if(c0 == 'l' && c1 == 'u'){
 79a:	f8b60513          	addi	a0,a2,-117
 79e:	e119                	bnez	a0,7a4 <vprintf+0x264>
 7a0:	ea0693e3          	bnez	a3,646 <vprintf+0x106>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 7a4:	f8b58513          	addi	a0,a1,-117
 7a8:	e119                	bnez	a0,7ae <vprintf+0x26e>
 7aa:	ea071be3          	bnez	a4,660 <vprintf+0x120>
      } else if(c0 == 'x'){
 7ae:	07800513          	li	a0,120
 7b2:	eca784e3          	beq	a5,a0,67a <vprintf+0x13a>
      } else if(c0 == 'l' && c1 == 'x'){
 7b6:	f8860613          	addi	a2,a2,-120
 7ba:	e219                	bnez	a2,7c0 <vprintf+0x280>
 7bc:	ec069be3          	bnez	a3,692 <vprintf+0x152>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 7c0:	f8858593          	addi	a1,a1,-120
 7c4:	e199                	bnez	a1,7ca <vprintf+0x28a>
 7c6:	ee0713e3          	bnez	a4,6ac <vprintf+0x16c>
      } else if(c0 == 'p'){
 7ca:	07000713          	li	a4,112
 7ce:	eee78ce3          	beq	a5,a4,6c6 <vprintf+0x186>
      } else if(c0 == 'c'){
 7d2:	06300713          	li	a4,99
 7d6:	f2e78ce3          	beq	a5,a4,70e <vprintf+0x1ce>
      } else if(c0 == 's'){
 7da:	07300713          	li	a4,115
 7de:	f4e782e3          	beq	a5,a4,722 <vprintf+0x1e2>
      } else if(c0 == '%'){
 7e2:	02500713          	li	a4,37
 7e6:	f6e787e3          	beq	a5,a4,754 <vprintf+0x214>
        putc(fd, '%');
 7ea:	02500593          	li	a1,37
 7ee:	855a                	mv	a0,s6
 7f0:	c95ff0ef          	jal	484 <putc>
        putc(fd, c0);
 7f4:	85a6                	mv	a1,s1
 7f6:	855a                	mv	a0,s6
 7f8:	c8dff0ef          	jal	484 <putc>
      state = 0;
 7fc:	4981                	li	s3,0
 7fe:	b359                	j	584 <vprintf+0x44>

0000000000000800 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 800:	715d                	addi	sp,sp,-80
 802:	ec06                	sd	ra,24(sp)
 804:	e822                	sd	s0,16(sp)
 806:	1000                	addi	s0,sp,32
 808:	e010                	sd	a2,0(s0)
 80a:	e414                	sd	a3,8(s0)
 80c:	e818                	sd	a4,16(s0)
 80e:	ec1c                	sd	a5,24(s0)
 810:	03043023          	sd	a6,32(s0)
 814:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 818:	8622                	mv	a2,s0
 81a:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 81e:	d23ff0ef          	jal	540 <vprintf>
}
 822:	60e2                	ld	ra,24(sp)
 824:	6442                	ld	s0,16(sp)
 826:	6161                	addi	sp,sp,80
 828:	8082                	ret

000000000000082a <printf>:

void
printf(const char *fmt, ...)
{
 82a:	711d                	addi	sp,sp,-96
 82c:	ec06                	sd	ra,24(sp)
 82e:	e822                	sd	s0,16(sp)
 830:	1000                	addi	s0,sp,32
 832:	e40c                	sd	a1,8(s0)
 834:	e810                	sd	a2,16(s0)
 836:	ec14                	sd	a3,24(s0)
 838:	f018                	sd	a4,32(s0)
 83a:	f41c                	sd	a5,40(s0)
 83c:	03043823          	sd	a6,48(s0)
 840:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 844:	00840613          	addi	a2,s0,8
 848:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 84c:	85aa                	mv	a1,a0
 84e:	4505                	li	a0,1
 850:	cf1ff0ef          	jal	540 <vprintf>
}
 854:	60e2                	ld	ra,24(sp)
 856:	6442                	ld	s0,16(sp)
 858:	6125                	addi	sp,sp,96
 85a:	8082                	ret

000000000000085c <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 85c:	1141                	addi	sp,sp,-16
 85e:	e406                	sd	ra,8(sp)
 860:	e022                	sd	s0,0(sp)
 862:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 864:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 868:	00000797          	auipc	a5,0x0
 86c:	7987b783          	ld	a5,1944(a5) # 1000 <freep>
 870:	a039                	j	87e <free+0x22>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 872:	6398                	ld	a4,0(a5)
 874:	00e7e463          	bltu	a5,a4,87c <free+0x20>
 878:	00e6ea63          	bltu	a3,a4,88c <free+0x30>
{
 87c:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 87e:	fed7fae3          	bgeu	a5,a3,872 <free+0x16>
 882:	6398                	ld	a4,0(a5)
 884:	00e6e463          	bltu	a3,a4,88c <free+0x30>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 888:	fee7eae3          	bltu	a5,a4,87c <free+0x20>
      break;
  if(bp + bp->s.size == p->s.ptr){
 88c:	ff852583          	lw	a1,-8(a0)
 890:	6390                	ld	a2,0(a5)
 892:	02059813          	slli	a6,a1,0x20
 896:	01c85713          	srli	a4,a6,0x1c
 89a:	9736                	add	a4,a4,a3
 89c:	02e60563          	beq	a2,a4,8c6 <free+0x6a>
    bp->s.size += p->s.ptr->s.size;
    bp->s.ptr = p->s.ptr->s.ptr;
 8a0:	fec53823          	sd	a2,-16(a0)
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
 8a4:	4790                	lw	a2,8(a5)
 8a6:	02061593          	slli	a1,a2,0x20
 8aa:	01c5d713          	srli	a4,a1,0x1c
 8ae:	973e                	add	a4,a4,a5
 8b0:	02e68263          	beq	a3,a4,8d4 <free+0x78>
    p->s.size += bp->s.size;
    p->s.ptr = bp->s.ptr;
 8b4:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 8b6:	00000717          	auipc	a4,0x0
 8ba:	74f73523          	sd	a5,1866(a4) # 1000 <freep>
}
 8be:	60a2                	ld	ra,8(sp)
 8c0:	6402                	ld	s0,0(sp)
 8c2:	0141                	addi	sp,sp,16
 8c4:	8082                	ret
    bp->s.size += p->s.ptr->s.size;
 8c6:	4618                	lw	a4,8(a2)
 8c8:	9f2d                	addw	a4,a4,a1
 8ca:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 8ce:	6398                	ld	a4,0(a5)
 8d0:	6310                	ld	a2,0(a4)
 8d2:	b7f9                	j	8a0 <free+0x44>
    p->s.size += bp->s.size;
 8d4:	ff852703          	lw	a4,-8(a0)
 8d8:	9f31                	addw	a4,a4,a2
 8da:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 8dc:	ff053683          	ld	a3,-16(a0)
 8e0:	bfd1                	j	8b4 <free+0x58>

00000000000008e2 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 8e2:	7139                	addi	sp,sp,-64
 8e4:	fc06                	sd	ra,56(sp)
 8e6:	f822                	sd	s0,48(sp)
 8e8:	f04a                	sd	s2,32(sp)
 8ea:	ec4e                	sd	s3,24(sp)
 8ec:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 8ee:	02051993          	slli	s3,a0,0x20
 8f2:	0209d993          	srli	s3,s3,0x20
 8f6:	09bd                	addi	s3,s3,15
 8f8:	0049d993          	srli	s3,s3,0x4
 8fc:	2985                	addiw	s3,s3,1
 8fe:	894e                	mv	s2,s3
  if((prevp = freep) == 0){
 900:	00000517          	auipc	a0,0x0
 904:	70053503          	ld	a0,1792(a0) # 1000 <freep>
 908:	c905                	beqz	a0,938 <malloc+0x56>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 90a:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 90c:	4798                	lw	a4,8(a5)
 90e:	09377663          	bgeu	a4,s3,99a <malloc+0xb8>
 912:	f426                	sd	s1,40(sp)
 914:	e852                	sd	s4,16(sp)
 916:	e456                	sd	s5,8(sp)
 918:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 91a:	8a4e                	mv	s4,s3
 91c:	6705                	lui	a4,0x1
 91e:	00e9f363          	bgeu	s3,a4,924 <malloc+0x42>
 922:	6a05                	lui	s4,0x1
 924:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 928:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 92c:	00000497          	auipc	s1,0x0
 930:	6d448493          	addi	s1,s1,1748 # 1000 <freep>
  if(p == SBRK_ERROR)
 934:	5afd                	li	s5,-1
 936:	a83d                	j	974 <malloc+0x92>
 938:	f426                	sd	s1,40(sp)
 93a:	e852                	sd	s4,16(sp)
 93c:	e456                	sd	s5,8(sp)
 93e:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 940:	00000797          	auipc	a5,0x0
 944:	6d078793          	addi	a5,a5,1744 # 1010 <base>
 948:	00000717          	auipc	a4,0x0
 94c:	6af73c23          	sd	a5,1720(a4) # 1000 <freep>
 950:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 952:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 956:	b7d1                	j	91a <malloc+0x38>
        prevp->s.ptr = p->s.ptr;
 958:	6398                	ld	a4,0(a5)
 95a:	e118                	sd	a4,0(a0)
 95c:	a899                	j	9b2 <malloc+0xd0>
  hp->s.size = nu;
 95e:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 962:	0541                	addi	a0,a0,16
 964:	ef9ff0ef          	jal	85c <free>
  return freep;
 968:	6088                	ld	a0,0(s1)
      if((p = morecore(nunits)) == 0)
 96a:	c125                	beqz	a0,9ca <malloc+0xe8>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 96c:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 96e:	4798                	lw	a4,8(a5)
 970:	03277163          	bgeu	a4,s2,992 <malloc+0xb0>
    if(p == freep)
 974:	6098                	ld	a4,0(s1)
 976:	853e                	mv	a0,a5
 978:	fef71ae3          	bne	a4,a5,96c <malloc+0x8a>
  p = sbrk(nu * sizeof(Header));
 97c:	8552                	mv	a0,s4
 97e:	a1bff0ef          	jal	398 <sbrk>
  if(p == SBRK_ERROR)
 982:	fd551ee3          	bne	a0,s5,95e <malloc+0x7c>
        return 0;
 986:	4501                	li	a0,0
 988:	74a2                	ld	s1,40(sp)
 98a:	6a42                	ld	s4,16(sp)
 98c:	6aa2                	ld	s5,8(sp)
 98e:	6b02                	ld	s6,0(sp)
 990:	a03d                	j	9be <malloc+0xdc>
 992:	74a2                	ld	s1,40(sp)
 994:	6a42                	ld	s4,16(sp)
 996:	6aa2                	ld	s5,8(sp)
 998:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 99a:	fae90fe3          	beq	s2,a4,958 <malloc+0x76>
        p->s.size -= nunits;
 99e:	4137073b          	subw	a4,a4,s3
 9a2:	c798                	sw	a4,8(a5)
        p += p->s.size;
 9a4:	02071693          	slli	a3,a4,0x20
 9a8:	01c6d713          	srli	a4,a3,0x1c
 9ac:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 9ae:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 9b2:	00000717          	auipc	a4,0x0
 9b6:	64a73723          	sd	a0,1614(a4) # 1000 <freep>
      return (void*)(p + 1);
 9ba:	01078513          	addi	a0,a5,16
  }
}
 9be:	70e2                	ld	ra,56(sp)
 9c0:	7442                	ld	s0,48(sp)
 9c2:	7902                	ld	s2,32(sp)
 9c4:	69e2                	ld	s3,24(sp)
 9c6:	6121                	addi	sp,sp,64
 9c8:	8082                	ret
 9ca:	74a2                	ld	s1,40(sp)
 9cc:	6a42                	ld	s4,16(sp)
 9ce:	6aa2                	ld	s5,8(sp)
 9d0:	6b02                	ld	s6,0(sp)
 9d2:	b7f5                	j	9be <malloc+0xdc>
