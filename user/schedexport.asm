
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
  60:	7e2000ef          	jal	842 <printf>
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
  98:	7aa000ef          	jal	842 <printf>
  9c:	b7e1                	j	64 <main+0x64>
    printf("EV {\"seq\":%d,\"tick\":%d,\"type\":\"ON_CPU\",\"cpu\":%d,\"pid\":%d,\"name\":\"%s\",\"state\":%d}\n",
  9e:	0104a803          	lw	a6,16(s1)
  a2:	ffc4a703          	lw	a4,-4(s1)
  a6:	ff84a683          	lw	a3,-8(s1)
  aa:	fd84a603          	lw	a2,-40(s1)
  ae:	fd44a583          	lw	a1,-44(s1)
  b2:	8562                	mv	a0,s8
  b4:	78e000ef          	jal	842 <printf>
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
  da:	91a50513          	addi	a0,a0,-1766 # 9f0 <malloc+0xf6>
  de:	764000ef          	jal	842 <printf>
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
  fa:	9c2c8c93          	addi	s9,s9,-1598 # ab8 <malloc+0x1be>
    printf("EV {\"seq\":%d,\"tick\":%d,\"type\":\"ON_CPU\",\"cpu\":%d,\"pid\":%d,\"name\":\"%s\",\"state\":%d}\n",
  fe:	00001c17          	auipc	s8,0x1
 102:	962c0c13          	addi	s8,s8,-1694 # a60 <malloc+0x166>
    printf("EV {\"seq\":%d,\"tick\":%d,\"type\":\"SCHED_INFO\",\"scheduler\":\"%s\",\"cpus\":%d,\"time_slice\":%d}\n",
 106:	00001b97          	auipc	s7,0x1
 10a:	902b8b93          	addi	s7,s7,-1790 # a08 <malloc+0x10e>
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

0000000000000484 <memread>:
.global memread
memread:
 li a7, SYS_memread
 484:	48e5                	li	a7,25
 ecall
 486:	00000073          	ecall
 ret
 48a:	8082                	ret

000000000000048c <getcpuinfo>:
.global getcpuinfo
getcpuinfo:
 li a7, SYS_getcpuinfo
 48c:	48e9                	li	a7,26
 ecall
 48e:	00000073          	ecall
 ret
 492:	8082                	ret

0000000000000494 <getprocstats>:
.global getprocstats
getprocstats:
 li a7, SYS_getprocstats
 494:	48ed                	li	a7,27
 ecall
 496:	00000073          	ecall
 ret
 49a:	8082                	ret

000000000000049c <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 49c:	1101                	addi	sp,sp,-32
 49e:	ec06                	sd	ra,24(sp)
 4a0:	e822                	sd	s0,16(sp)
 4a2:	1000                	addi	s0,sp,32
 4a4:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 4a8:	4605                	li	a2,1
 4aa:	fef40593          	addi	a1,s0,-17
 4ae:	f3fff0ef          	jal	3ec <write>
}
 4b2:	60e2                	ld	ra,24(sp)
 4b4:	6442                	ld	s0,16(sp)
 4b6:	6105                	addi	sp,sp,32
 4b8:	8082                	ret

00000000000004ba <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
 4ba:	715d                	addi	sp,sp,-80
 4bc:	e486                	sd	ra,72(sp)
 4be:	e0a2                	sd	s0,64(sp)
 4c0:	f84a                	sd	s2,48(sp)
 4c2:	f44e                	sd	s3,40(sp)
 4c4:	0880                	addi	s0,sp,80
 4c6:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
 4c8:	c6d1                	beqz	a3,554 <printint+0x9a>
 4ca:	0805d563          	bgez	a1,554 <printint+0x9a>
    neg = 1;
    x = -xx;
 4ce:	40b005b3          	neg	a1,a1
    neg = 1;
 4d2:	4305                	li	t1,1
  } else {
    x = xx;
  }

  i = 0;
 4d4:	fb840993          	addi	s3,s0,-72
  neg = 0;
 4d8:	86ce                	mv	a3,s3
  i = 0;
 4da:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 4dc:	00000817          	auipc	a6,0x0
 4e0:	64480813          	addi	a6,a6,1604 # b20 <digits>
 4e4:	88ba                	mv	a7,a4
 4e6:	0017051b          	addiw	a0,a4,1
 4ea:	872a                	mv	a4,a0
 4ec:	02c5f7b3          	remu	a5,a1,a2
 4f0:	97c2                	add	a5,a5,a6
 4f2:	0007c783          	lbu	a5,0(a5)
 4f6:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 4fa:	87ae                	mv	a5,a1
 4fc:	02c5d5b3          	divu	a1,a1,a2
 500:	0685                	addi	a3,a3,1
 502:	fec7f1e3          	bgeu	a5,a2,4e4 <printint+0x2a>
  if(neg)
 506:	00030c63          	beqz	t1,51e <printint+0x64>
    buf[i++] = '-';
 50a:	fd050793          	addi	a5,a0,-48
 50e:	00878533          	add	a0,a5,s0
 512:	02d00793          	li	a5,45
 516:	fef50423          	sb	a5,-24(a0)
 51a:	0028871b          	addiw	a4,a7,2

  while(--i >= 0)
 51e:	02e05563          	blez	a4,548 <printint+0x8e>
 522:	fc26                	sd	s1,56(sp)
 524:	377d                	addiw	a4,a4,-1
 526:	00e984b3          	add	s1,s3,a4
 52a:	19fd                	addi	s3,s3,-1
 52c:	99ba                	add	s3,s3,a4
 52e:	1702                	slli	a4,a4,0x20
 530:	9301                	srli	a4,a4,0x20
 532:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 536:	0004c583          	lbu	a1,0(s1)
 53a:	854a                	mv	a0,s2
 53c:	f61ff0ef          	jal	49c <putc>
  while(--i >= 0)
 540:	14fd                	addi	s1,s1,-1
 542:	ff349ae3          	bne	s1,s3,536 <printint+0x7c>
 546:	74e2                	ld	s1,56(sp)
}
 548:	60a6                	ld	ra,72(sp)
 54a:	6406                	ld	s0,64(sp)
 54c:	7942                	ld	s2,48(sp)
 54e:	79a2                	ld	s3,40(sp)
 550:	6161                	addi	sp,sp,80
 552:	8082                	ret
  neg = 0;
 554:	4301                	li	t1,0
 556:	bfbd                	j	4d4 <printint+0x1a>

0000000000000558 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 558:	711d                	addi	sp,sp,-96
 55a:	ec86                	sd	ra,88(sp)
 55c:	e8a2                	sd	s0,80(sp)
 55e:	e4a6                	sd	s1,72(sp)
 560:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 562:	0005c483          	lbu	s1,0(a1)
 566:	22048363          	beqz	s1,78c <vprintf+0x234>
 56a:	e0ca                	sd	s2,64(sp)
 56c:	fc4e                	sd	s3,56(sp)
 56e:	f852                	sd	s4,48(sp)
 570:	f456                	sd	s5,40(sp)
 572:	f05a                	sd	s6,32(sp)
 574:	ec5e                	sd	s7,24(sp)
 576:	e862                	sd	s8,16(sp)
 578:	8b2a                	mv	s6,a0
 57a:	8a2e                	mv	s4,a1
 57c:	8bb2                	mv	s7,a2
  state = 0;
 57e:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 580:	4901                	li	s2,0
 582:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 584:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 588:	06400c13          	li	s8,100
 58c:	a00d                	j	5ae <vprintf+0x56>
        putc(fd, c0);
 58e:	85a6                	mv	a1,s1
 590:	855a                	mv	a0,s6
 592:	f0bff0ef          	jal	49c <putc>
 596:	a019                	j	59c <vprintf+0x44>
    } else if(state == '%'){
 598:	03598363          	beq	s3,s5,5be <vprintf+0x66>
  for(i = 0; fmt[i]; i++){
 59c:	0019079b          	addiw	a5,s2,1
 5a0:	893e                	mv	s2,a5
 5a2:	873e                	mv	a4,a5
 5a4:	97d2                	add	a5,a5,s4
 5a6:	0007c483          	lbu	s1,0(a5)
 5aa:	1c048a63          	beqz	s1,77e <vprintf+0x226>
    c0 = fmt[i] & 0xff;
 5ae:	0004879b          	sext.w	a5,s1
    if(state == 0){
 5b2:	fe0993e3          	bnez	s3,598 <vprintf+0x40>
      if(c0 == '%'){
 5b6:	fd579ce3          	bne	a5,s5,58e <vprintf+0x36>
        state = '%';
 5ba:	89be                	mv	s3,a5
 5bc:	b7c5                	j	59c <vprintf+0x44>
      if(c0) c1 = fmt[i+1] & 0xff;
 5be:	00ea06b3          	add	a3,s4,a4
 5c2:	0016c603          	lbu	a2,1(a3)
      if(c1) c2 = fmt[i+2] & 0xff;
 5c6:	1c060863          	beqz	a2,796 <vprintf+0x23e>
      if(c0 == 'd'){
 5ca:	03878763          	beq	a5,s8,5f8 <vprintf+0xa0>
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 5ce:	f9478693          	addi	a3,a5,-108
 5d2:	0016b693          	seqz	a3,a3
 5d6:	f9c60593          	addi	a1,a2,-100
 5da:	e99d                	bnez	a1,610 <vprintf+0xb8>
 5dc:	ca95                	beqz	a3,610 <vprintf+0xb8>
        printint(fd, va_arg(ap, uint64), 10, 1);
 5de:	008b8493          	addi	s1,s7,8
 5e2:	4685                	li	a3,1
 5e4:	4629                	li	a2,10
 5e6:	000bb583          	ld	a1,0(s7)
 5ea:	855a                	mv	a0,s6
 5ec:	ecfff0ef          	jal	4ba <printint>
        i += 1;
 5f0:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 5f2:	8ba6                	mv	s7,s1
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 5f4:	4981                	li	s3,0
 5f6:	b75d                	j	59c <vprintf+0x44>
        printint(fd, va_arg(ap, int), 10, 1);
 5f8:	008b8493          	addi	s1,s7,8
 5fc:	4685                	li	a3,1
 5fe:	4629                	li	a2,10
 600:	000ba583          	lw	a1,0(s7)
 604:	855a                	mv	a0,s6
 606:	eb5ff0ef          	jal	4ba <printint>
 60a:	8ba6                	mv	s7,s1
      state = 0;
 60c:	4981                	li	s3,0
 60e:	b779                	j	59c <vprintf+0x44>
      if(c1) c2 = fmt[i+2] & 0xff;
 610:	9752                	add	a4,a4,s4
 612:	00274583          	lbu	a1,2(a4)
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 616:	f9460713          	addi	a4,a2,-108
 61a:	00173713          	seqz	a4,a4
 61e:	8f75                	and	a4,a4,a3
 620:	f9c58513          	addi	a0,a1,-100
 624:	18051363          	bnez	a0,7aa <vprintf+0x252>
 628:	18070163          	beqz	a4,7aa <vprintf+0x252>
        printint(fd, va_arg(ap, uint64), 10, 1);
 62c:	008b8493          	addi	s1,s7,8
 630:	4685                	li	a3,1
 632:	4629                	li	a2,10
 634:	000bb583          	ld	a1,0(s7)
 638:	855a                	mv	a0,s6
 63a:	e81ff0ef          	jal	4ba <printint>
        i += 2;
 63e:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 640:	8ba6                	mv	s7,s1
      state = 0;
 642:	4981                	li	s3,0
        i += 2;
 644:	bfa1                	j	59c <vprintf+0x44>
        printint(fd, va_arg(ap, uint32), 10, 0);
 646:	008b8493          	addi	s1,s7,8
 64a:	4681                	li	a3,0
 64c:	4629                	li	a2,10
 64e:	000be583          	lwu	a1,0(s7)
 652:	855a                	mv	a0,s6
 654:	e67ff0ef          	jal	4ba <printint>
 658:	8ba6                	mv	s7,s1
      state = 0;
 65a:	4981                	li	s3,0
 65c:	b781                	j	59c <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
 65e:	008b8493          	addi	s1,s7,8
 662:	4681                	li	a3,0
 664:	4629                	li	a2,10
 666:	000bb583          	ld	a1,0(s7)
 66a:	855a                	mv	a0,s6
 66c:	e4fff0ef          	jal	4ba <printint>
        i += 1;
 670:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 672:	8ba6                	mv	s7,s1
      state = 0;
 674:	4981                	li	s3,0
 676:	b71d                	j	59c <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
 678:	008b8493          	addi	s1,s7,8
 67c:	4681                	li	a3,0
 67e:	4629                	li	a2,10
 680:	000bb583          	ld	a1,0(s7)
 684:	855a                	mv	a0,s6
 686:	e35ff0ef          	jal	4ba <printint>
        i += 2;
 68a:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 68c:	8ba6                	mv	s7,s1
      state = 0;
 68e:	4981                	li	s3,0
        i += 2;
 690:	b731                	j	59c <vprintf+0x44>
        printint(fd, va_arg(ap, uint32), 16, 0);
 692:	008b8493          	addi	s1,s7,8
 696:	4681                	li	a3,0
 698:	4641                	li	a2,16
 69a:	000be583          	lwu	a1,0(s7)
 69e:	855a                	mv	a0,s6
 6a0:	e1bff0ef          	jal	4ba <printint>
 6a4:	8ba6                	mv	s7,s1
      state = 0;
 6a6:	4981                	li	s3,0
 6a8:	bdd5                	j	59c <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 16, 0);
 6aa:	008b8493          	addi	s1,s7,8
 6ae:	4681                	li	a3,0
 6b0:	4641                	li	a2,16
 6b2:	000bb583          	ld	a1,0(s7)
 6b6:	855a                	mv	a0,s6
 6b8:	e03ff0ef          	jal	4ba <printint>
        i += 1;
 6bc:	2905                	addiw	s2,s2,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 6be:	8ba6                	mv	s7,s1
      state = 0;
 6c0:	4981                	li	s3,0
 6c2:	bde9                	j	59c <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 16, 0);
 6c4:	008b8493          	addi	s1,s7,8
 6c8:	4681                	li	a3,0
 6ca:	4641                	li	a2,16
 6cc:	000bb583          	ld	a1,0(s7)
 6d0:	855a                	mv	a0,s6
 6d2:	de9ff0ef          	jal	4ba <printint>
        i += 2;
 6d6:	2909                	addiw	s2,s2,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 6d8:	8ba6                	mv	s7,s1
      state = 0;
 6da:	4981                	li	s3,0
        i += 2;
 6dc:	b5c1                	j	59c <vprintf+0x44>
 6de:	e466                	sd	s9,8(sp)
        printptr(fd, va_arg(ap, uint64));
 6e0:	008b8793          	addi	a5,s7,8
 6e4:	8cbe                	mv	s9,a5
 6e6:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 6ea:	03000593          	li	a1,48
 6ee:	855a                	mv	a0,s6
 6f0:	dadff0ef          	jal	49c <putc>
  putc(fd, 'x');
 6f4:	07800593          	li	a1,120
 6f8:	855a                	mv	a0,s6
 6fa:	da3ff0ef          	jal	49c <putc>
 6fe:	44c1                	li	s1,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 700:	00000b97          	auipc	s7,0x0
 704:	420b8b93          	addi	s7,s7,1056 # b20 <digits>
 708:	03c9d793          	srli	a5,s3,0x3c
 70c:	97de                	add	a5,a5,s7
 70e:	0007c583          	lbu	a1,0(a5)
 712:	855a                	mv	a0,s6
 714:	d89ff0ef          	jal	49c <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 718:	0992                	slli	s3,s3,0x4
 71a:	34fd                	addiw	s1,s1,-1
 71c:	f4f5                	bnez	s1,708 <vprintf+0x1b0>
        printptr(fd, va_arg(ap, uint64));
 71e:	8be6                	mv	s7,s9
      state = 0;
 720:	4981                	li	s3,0
 722:	6ca2                	ld	s9,8(sp)
 724:	bda5                	j	59c <vprintf+0x44>
        putc(fd, va_arg(ap, uint32));
 726:	008b8493          	addi	s1,s7,8
 72a:	000bc583          	lbu	a1,0(s7)
 72e:	855a                	mv	a0,s6
 730:	d6dff0ef          	jal	49c <putc>
 734:	8ba6                	mv	s7,s1
      state = 0;
 736:	4981                	li	s3,0
 738:	b595                	j	59c <vprintf+0x44>
        if((s = va_arg(ap, char*)) == 0)
 73a:	008b8993          	addi	s3,s7,8
 73e:	000bb483          	ld	s1,0(s7)
 742:	cc91                	beqz	s1,75e <vprintf+0x206>
        for(; *s; s++)
 744:	0004c583          	lbu	a1,0(s1)
 748:	c985                	beqz	a1,778 <vprintf+0x220>
          putc(fd, *s);
 74a:	855a                	mv	a0,s6
 74c:	d51ff0ef          	jal	49c <putc>
        for(; *s; s++)
 750:	0485                	addi	s1,s1,1
 752:	0004c583          	lbu	a1,0(s1)
 756:	f9f5                	bnez	a1,74a <vprintf+0x1f2>
        if((s = va_arg(ap, char*)) == 0)
 758:	8bce                	mv	s7,s3
      state = 0;
 75a:	4981                	li	s3,0
 75c:	b581                	j	59c <vprintf+0x44>
          s = "(null)";
 75e:	00000497          	auipc	s1,0x0
 762:	3ba48493          	addi	s1,s1,954 # b18 <malloc+0x21e>
        for(; *s; s++)
 766:	02800593          	li	a1,40
 76a:	b7c5                	j	74a <vprintf+0x1f2>
        putc(fd, '%');
 76c:	85be                	mv	a1,a5
 76e:	855a                	mv	a0,s6
 770:	d2dff0ef          	jal	49c <putc>
      state = 0;
 774:	4981                	li	s3,0
 776:	b51d                	j	59c <vprintf+0x44>
        if((s = va_arg(ap, char*)) == 0)
 778:	8bce                	mv	s7,s3
      state = 0;
 77a:	4981                	li	s3,0
 77c:	b505                	j	59c <vprintf+0x44>
 77e:	6906                	ld	s2,64(sp)
 780:	79e2                	ld	s3,56(sp)
 782:	7a42                	ld	s4,48(sp)
 784:	7aa2                	ld	s5,40(sp)
 786:	7b02                	ld	s6,32(sp)
 788:	6be2                	ld	s7,24(sp)
 78a:	6c42                	ld	s8,16(sp)
    }
  }
}
 78c:	60e6                	ld	ra,88(sp)
 78e:	6446                	ld	s0,80(sp)
 790:	64a6                	ld	s1,72(sp)
 792:	6125                	addi	sp,sp,96
 794:	8082                	ret
      if(c0 == 'd'){
 796:	06400713          	li	a4,100
 79a:	e4e78fe3          	beq	a5,a4,5f8 <vprintf+0xa0>
      } else if(c0 == 'l' && c1 == 'd'){
 79e:	f9478693          	addi	a3,a5,-108
 7a2:	0016b693          	seqz	a3,a3
      c1 = c2 = 0;
 7a6:	85b2                	mv	a1,a2
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 7a8:	4701                	li	a4,0
      } else if(c0 == 'u'){
 7aa:	07500513          	li	a0,117
 7ae:	e8a78ce3          	beq	a5,a0,646 <vprintf+0xee>
      } else if(c0 == 'l' && c1 == 'u'){
 7b2:	f8b60513          	addi	a0,a2,-117
 7b6:	e119                	bnez	a0,7bc <vprintf+0x264>
 7b8:	ea0693e3          	bnez	a3,65e <vprintf+0x106>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 7bc:	f8b58513          	addi	a0,a1,-117
 7c0:	e119                	bnez	a0,7c6 <vprintf+0x26e>
 7c2:	ea071be3          	bnez	a4,678 <vprintf+0x120>
      } else if(c0 == 'x'){
 7c6:	07800513          	li	a0,120
 7ca:	eca784e3          	beq	a5,a0,692 <vprintf+0x13a>
      } else if(c0 == 'l' && c1 == 'x'){
 7ce:	f8860613          	addi	a2,a2,-120
 7d2:	e219                	bnez	a2,7d8 <vprintf+0x280>
 7d4:	ec069be3          	bnez	a3,6aa <vprintf+0x152>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 7d8:	f8858593          	addi	a1,a1,-120
 7dc:	e199                	bnez	a1,7e2 <vprintf+0x28a>
 7de:	ee0713e3          	bnez	a4,6c4 <vprintf+0x16c>
      } else if(c0 == 'p'){
 7e2:	07000713          	li	a4,112
 7e6:	eee78ce3          	beq	a5,a4,6de <vprintf+0x186>
      } else if(c0 == 'c'){
 7ea:	06300713          	li	a4,99
 7ee:	f2e78ce3          	beq	a5,a4,726 <vprintf+0x1ce>
      } else if(c0 == 's'){
 7f2:	07300713          	li	a4,115
 7f6:	f4e782e3          	beq	a5,a4,73a <vprintf+0x1e2>
      } else if(c0 == '%'){
 7fa:	02500713          	li	a4,37
 7fe:	f6e787e3          	beq	a5,a4,76c <vprintf+0x214>
        putc(fd, '%');
 802:	02500593          	li	a1,37
 806:	855a                	mv	a0,s6
 808:	c95ff0ef          	jal	49c <putc>
        putc(fd, c0);
 80c:	85a6                	mv	a1,s1
 80e:	855a                	mv	a0,s6
 810:	c8dff0ef          	jal	49c <putc>
      state = 0;
 814:	4981                	li	s3,0
 816:	b359                	j	59c <vprintf+0x44>

0000000000000818 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 818:	715d                	addi	sp,sp,-80
 81a:	ec06                	sd	ra,24(sp)
 81c:	e822                	sd	s0,16(sp)
 81e:	1000                	addi	s0,sp,32
 820:	e010                	sd	a2,0(s0)
 822:	e414                	sd	a3,8(s0)
 824:	e818                	sd	a4,16(s0)
 826:	ec1c                	sd	a5,24(s0)
 828:	03043023          	sd	a6,32(s0)
 82c:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 830:	8622                	mv	a2,s0
 832:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 836:	d23ff0ef          	jal	558 <vprintf>
}
 83a:	60e2                	ld	ra,24(sp)
 83c:	6442                	ld	s0,16(sp)
 83e:	6161                	addi	sp,sp,80
 840:	8082                	ret

0000000000000842 <printf>:

void
printf(const char *fmt, ...)
{
 842:	711d                	addi	sp,sp,-96
 844:	ec06                	sd	ra,24(sp)
 846:	e822                	sd	s0,16(sp)
 848:	1000                	addi	s0,sp,32
 84a:	e40c                	sd	a1,8(s0)
 84c:	e810                	sd	a2,16(s0)
 84e:	ec14                	sd	a3,24(s0)
 850:	f018                	sd	a4,32(s0)
 852:	f41c                	sd	a5,40(s0)
 854:	03043823          	sd	a6,48(s0)
 858:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 85c:	00840613          	addi	a2,s0,8
 860:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 864:	85aa                	mv	a1,a0
 866:	4505                	li	a0,1
 868:	cf1ff0ef          	jal	558 <vprintf>
}
 86c:	60e2                	ld	ra,24(sp)
 86e:	6442                	ld	s0,16(sp)
 870:	6125                	addi	sp,sp,96
 872:	8082                	ret

0000000000000874 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 874:	1141                	addi	sp,sp,-16
 876:	e406                	sd	ra,8(sp)
 878:	e022                	sd	s0,0(sp)
 87a:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 87c:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 880:	00000797          	auipc	a5,0x0
 884:	7807b783          	ld	a5,1920(a5) # 1000 <freep>
 888:	a039                	j	896 <free+0x22>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 88a:	6398                	ld	a4,0(a5)
 88c:	00e7e463          	bltu	a5,a4,894 <free+0x20>
 890:	00e6ea63          	bltu	a3,a4,8a4 <free+0x30>
{
 894:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 896:	fed7fae3          	bgeu	a5,a3,88a <free+0x16>
 89a:	6398                	ld	a4,0(a5)
 89c:	00e6e463          	bltu	a3,a4,8a4 <free+0x30>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 8a0:	fee7eae3          	bltu	a5,a4,894 <free+0x20>
      break;
  if(bp + bp->s.size == p->s.ptr){
 8a4:	ff852583          	lw	a1,-8(a0)
 8a8:	6390                	ld	a2,0(a5)
 8aa:	02059813          	slli	a6,a1,0x20
 8ae:	01c85713          	srli	a4,a6,0x1c
 8b2:	9736                	add	a4,a4,a3
 8b4:	02e60563          	beq	a2,a4,8de <free+0x6a>
    bp->s.size += p->s.ptr->s.size;
    bp->s.ptr = p->s.ptr->s.ptr;
 8b8:	fec53823          	sd	a2,-16(a0)
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
 8bc:	4790                	lw	a2,8(a5)
 8be:	02061593          	slli	a1,a2,0x20
 8c2:	01c5d713          	srli	a4,a1,0x1c
 8c6:	973e                	add	a4,a4,a5
 8c8:	02e68263          	beq	a3,a4,8ec <free+0x78>
    p->s.size += bp->s.size;
    p->s.ptr = bp->s.ptr;
 8cc:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 8ce:	00000717          	auipc	a4,0x0
 8d2:	72f73923          	sd	a5,1842(a4) # 1000 <freep>
}
 8d6:	60a2                	ld	ra,8(sp)
 8d8:	6402                	ld	s0,0(sp)
 8da:	0141                	addi	sp,sp,16
 8dc:	8082                	ret
    bp->s.size += p->s.ptr->s.size;
 8de:	4618                	lw	a4,8(a2)
 8e0:	9f2d                	addw	a4,a4,a1
 8e2:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 8e6:	6398                	ld	a4,0(a5)
 8e8:	6310                	ld	a2,0(a4)
 8ea:	b7f9                	j	8b8 <free+0x44>
    p->s.size += bp->s.size;
 8ec:	ff852703          	lw	a4,-8(a0)
 8f0:	9f31                	addw	a4,a4,a2
 8f2:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 8f4:	ff053683          	ld	a3,-16(a0)
 8f8:	bfd1                	j	8cc <free+0x58>

00000000000008fa <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 8fa:	7139                	addi	sp,sp,-64
 8fc:	fc06                	sd	ra,56(sp)
 8fe:	f822                	sd	s0,48(sp)
 900:	f04a                	sd	s2,32(sp)
 902:	ec4e                	sd	s3,24(sp)
 904:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 906:	02051993          	slli	s3,a0,0x20
 90a:	0209d993          	srli	s3,s3,0x20
 90e:	09bd                	addi	s3,s3,15
 910:	0049d993          	srli	s3,s3,0x4
 914:	2985                	addiw	s3,s3,1
 916:	894e                	mv	s2,s3
  if((prevp = freep) == 0){
 918:	00000517          	auipc	a0,0x0
 91c:	6e853503          	ld	a0,1768(a0) # 1000 <freep>
 920:	c905                	beqz	a0,950 <malloc+0x56>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 922:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 924:	4798                	lw	a4,8(a5)
 926:	09377663          	bgeu	a4,s3,9b2 <malloc+0xb8>
 92a:	f426                	sd	s1,40(sp)
 92c:	e852                	sd	s4,16(sp)
 92e:	e456                	sd	s5,8(sp)
 930:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 932:	8a4e                	mv	s4,s3
 934:	6705                	lui	a4,0x1
 936:	00e9f363          	bgeu	s3,a4,93c <malloc+0x42>
 93a:	6a05                	lui	s4,0x1
 93c:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 940:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 944:	00000497          	auipc	s1,0x0
 948:	6bc48493          	addi	s1,s1,1724 # 1000 <freep>
  if(p == SBRK_ERROR)
 94c:	5afd                	li	s5,-1
 94e:	a83d                	j	98c <malloc+0x92>
 950:	f426                	sd	s1,40(sp)
 952:	e852                	sd	s4,16(sp)
 954:	e456                	sd	s5,8(sp)
 956:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 958:	00000797          	auipc	a5,0x0
 95c:	6b878793          	addi	a5,a5,1720 # 1010 <base>
 960:	00000717          	auipc	a4,0x0
 964:	6af73023          	sd	a5,1696(a4) # 1000 <freep>
 968:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 96a:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 96e:	b7d1                	j	932 <malloc+0x38>
        prevp->s.ptr = p->s.ptr;
 970:	6398                	ld	a4,0(a5)
 972:	e118                	sd	a4,0(a0)
 974:	a899                	j	9ca <malloc+0xd0>
  hp->s.size = nu;
 976:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 97a:	0541                	addi	a0,a0,16
 97c:	ef9ff0ef          	jal	874 <free>
  return freep;
 980:	6088                	ld	a0,0(s1)
      if((p = morecore(nunits)) == 0)
 982:	c125                	beqz	a0,9e2 <malloc+0xe8>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 984:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 986:	4798                	lw	a4,8(a5)
 988:	03277163          	bgeu	a4,s2,9aa <malloc+0xb0>
    if(p == freep)
 98c:	6098                	ld	a4,0(s1)
 98e:	853e                	mv	a0,a5
 990:	fef71ae3          	bne	a4,a5,984 <malloc+0x8a>
  p = sbrk(nu * sizeof(Header));
 994:	8552                	mv	a0,s4
 996:	a03ff0ef          	jal	398 <sbrk>
  if(p == SBRK_ERROR)
 99a:	fd551ee3          	bne	a0,s5,976 <malloc+0x7c>
        return 0;
 99e:	4501                	li	a0,0
 9a0:	74a2                	ld	s1,40(sp)
 9a2:	6a42                	ld	s4,16(sp)
 9a4:	6aa2                	ld	s5,8(sp)
 9a6:	6b02                	ld	s6,0(sp)
 9a8:	a03d                	j	9d6 <malloc+0xdc>
 9aa:	74a2                	ld	s1,40(sp)
 9ac:	6a42                	ld	s4,16(sp)
 9ae:	6aa2                	ld	s5,8(sp)
 9b0:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 9b2:	fae90fe3          	beq	s2,a4,970 <malloc+0x76>
        p->s.size -= nunits;
 9b6:	4137073b          	subw	a4,a4,s3
 9ba:	c798                	sw	a4,8(a5)
        p += p->s.size;
 9bc:	02071693          	slli	a3,a4,0x20
 9c0:	01c6d713          	srli	a4,a3,0x1c
 9c4:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 9c6:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 9ca:	00000717          	auipc	a4,0x0
 9ce:	62a73b23          	sd	a0,1590(a4) # 1000 <freep>
      return (void*)(p + 1);
 9d2:	01078513          	addi	a0,a5,16
  }
}
 9d6:	70e2                	ld	ra,56(sp)
 9d8:	7442                	ld	s0,48(sp)
 9da:	7902                	ld	s2,32(sp)
 9dc:	69e2                	ld	s3,24(sp)
 9de:	6121                	addi	sp,sp,64
 9e0:	8082                	ret
 9e2:	74a2                	ld	s1,40(sp)
 9e4:	6a42                	ld	s4,16(sp)
 9e6:	6aa2                	ld	s5,8(sp)
 9e8:	6b02                	ld	s6,0(sp)
 9ea:	b7f5                	j	9d6 <malloc+0xdc>
