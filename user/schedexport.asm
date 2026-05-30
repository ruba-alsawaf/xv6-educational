
user/_schedexport:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
  }
}

int
main(void)
{
   0:	b6010113          	addi	sp,sp,-1184
   4:	48113c23          	sd	ra,1176(sp)
   8:	48813823          	sd	s0,1168(sp)
   c:	48913423          	sd	s1,1160(sp)
  10:	49213023          	sd	s2,1152(sp)
  14:	47313c23          	sd	s3,1144(sp)
  18:	47413823          	sd	s4,1136(sp)
  1c:	47513423          	sd	s5,1128(sp)
  20:	47613023          	sd	s6,1120(sp)
  24:	45713c23          	sd	s7,1112(sp)
  28:	45813823          	sd	s8,1104(sp)
  2c:	45913423          	sd	s9,1096(sp)
  30:	4a010413          	addi	s0,sp,1184
  struct sched_event ev[16];

  for(int round = 0; round < 5; round++){
  34:	4a81                	li	s5,0
  } else if(e->event_type == SCHED_EV_ON_CPU){
  36:	4989                	li	s3,2
  } else if(e->event_type == SCHED_EV_OFF_CPU){
  38:	4a0d                	li	s4,3
    printf("EV {\"seq\":%d,\"tick\":%d,\"type\":\"OFF_CPU\",\"cpu\":%d,\"pid\":%d,\"name\":\"%s\",\"state\":%d,\"reason\":%d}\n",
  3a:	00001c17          	auipc	s8,0x1
  3e:	a5ec0c13          	addi	s8,s8,-1442 # a98 <malloc+0x1c0>
    printf("EV {\"seq\":%d,\"tick\":%d,\"type\":\"ON_CPU\",\"cpu\":%d,\"pid\":%d,\"name\":\"%s\",\"state\":%d}\n",
  42:	00001b97          	auipc	s7,0x1
  46:	9feb8b93          	addi	s7,s7,-1538 # a40 <malloc+0x168>
    printf("EV {\"seq\":%d,\"tick\":%d,\"type\":\"SCHED_INFO\",\"scheduler\":\"%s\",\"cpus\":%d,\"time_slice\":%d}\n",
  4a:	00001b17          	auipc	s6,0x1
  4e:	99eb0b13          	addi	s6,s6,-1634 # 9e8 <malloc+0x110>
  52:	a041                	j	d2 <main+0xd2>
  54:	ff44a783          	lw	a5,-12(s1)
  58:	ff04a703          	lw	a4,-16(s1)
  5c:	fe048693          	addi	a3,s1,-32
  60:	fd84a603          	lw	a2,-40(s1)
  64:	fd44a583          	lw	a1,-44(s1)
  68:	855a                	mv	a0,s6
  6a:	7ba000ef          	jal	824 <printf>
    int n = schedread(ev, 16);
    printf("round=%d n=%d\n", round, n);

    for(int i = 0; i < n; i++){
  6e:	04448493          	addi	s1,s1,68
  72:	05248963          	beq	s1,s2,c4 <main+0xc4>
  if(e->event_type == SCHED_EV_INFO){
  76:	87a6                	mv	a5,s1
  78:	fdc4a703          	lw	a4,-36(s1)
  7c:	fd970ce3          	beq	a4,s9,54 <main+0x54>
  } else if(e->event_type == SCHED_EV_ON_CPU){
  80:	03370463          	beq	a4,s3,a8 <main+0xa8>
  } else if(e->event_type == SCHED_EV_OFF_CPU){
  84:	ff4715e3          	bne	a4,s4,6e <main+0x6e>
    printf("EV {\"seq\":%d,\"tick\":%d,\"type\":\"OFF_CPU\",\"cpu\":%d,\"pid\":%d,\"name\":\"%s\",\"state\":%d,\"reason\":%d}\n",
  88:	0144a883          	lw	a7,20(s1)
  8c:	0104a803          	lw	a6,16(s1)
  90:	ffc4a703          	lw	a4,-4(s1)
  94:	ff84a683          	lw	a3,-8(s1)
  98:	fd84a603          	lw	a2,-40(s1)
  9c:	fd44a583          	lw	a1,-44(s1)
  a0:	8562                	mv	a0,s8
  a2:	782000ef          	jal	824 <printf>
  a6:	b7e1                	j	6e <main+0x6e>
    printf("EV {\"seq\":%d,\"tick\":%d,\"type\":\"ON_CPU\",\"cpu\":%d,\"pid\":%d,\"name\":\"%s\",\"state\":%d}\n",
  a8:	0104a803          	lw	a6,16(s1)
  ac:	ffc4a703          	lw	a4,-4(s1)
  b0:	ff84a683          	lw	a3,-8(s1)
  b4:	fd84a603          	lw	a2,-40(s1)
  b8:	fd44a583          	lw	a1,-44(s1)
  bc:	855e                	mv	a0,s7
  be:	766000ef          	jal	824 <printf>
  c2:	b775                	j	6e <main+0x6e>
      print_sched_event(&ev[i]);
    }

    pause(10);
  c4:	4529                	li	a0,10
  c6:	3a6000ef          	jal	46c <pause>
  for(int round = 0; round < 5; round++){
  ca:	2a85                	addiw	s5,s5,1
  cc:	4795                	li	a5,5
  ce:	02fa8b63          	beq	s5,a5,104 <main+0x104>
    int n = schedread(ev, 16);
  d2:	45c1                	li	a1,16
  d4:	b6040513          	addi	a0,s0,-1184
  d8:	3b4000ef          	jal	48c <schedread>
  dc:	8caa                	mv	s9,a0
    printf("round=%d n=%d\n", round, n);
  de:	862a                	mv	a2,a0
  e0:	85d6                	mv	a1,s5
  e2:	00001517          	auipc	a0,0x1
  e6:	8ee50513          	addi	a0,a0,-1810 # 9d0 <malloc+0xf8>
  ea:	73a000ef          	jal	824 <printf>
    for(int i = 0; i < n; i++){
  ee:	fd905be3          	blez	s9,c4 <main+0xc4>
  f2:	b8c40493          	addi	s1,s0,-1140
  f6:	004c9913          	slli	s2,s9,0x4
  fa:	9966                	add	s2,s2,s9
  fc:	090a                	slli	s2,s2,0x2
  fe:	9926                	add	s2,s2,s1
  if(e->event_type == SCHED_EV_INFO){
 100:	4c85                	li	s9,1
 102:	bf95                	j	76 <main+0x76>
  }

  exit(0);
 104:	4501                	li	a0,0
 106:	2d6000ef          	jal	3dc <exit>

000000000000010a <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start(int argc, char **argv)
{
 10a:	1141                	addi	sp,sp,-16
 10c:	e406                	sd	ra,8(sp)
 10e:	e022                	sd	s0,0(sp)
 110:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
 112:	eefff0ef          	jal	0 <main>
  exit(r);
 116:	2c6000ef          	jal	3dc <exit>

000000000000011a <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 11a:	1141                	addi	sp,sp,-16
 11c:	e422                	sd	s0,8(sp)
 11e:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 120:	87aa                	mv	a5,a0
 122:	0585                	addi	a1,a1,1
 124:	0785                	addi	a5,a5,1
 126:	fff5c703          	lbu	a4,-1(a1)
 12a:	fee78fa3          	sb	a4,-1(a5)
 12e:	fb75                	bnez	a4,122 <strcpy+0x8>
    ;
  return os;
}
 130:	6422                	ld	s0,8(sp)
 132:	0141                	addi	sp,sp,16
 134:	8082                	ret

0000000000000136 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 136:	1141                	addi	sp,sp,-16
 138:	e422                	sd	s0,8(sp)
 13a:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 13c:	00054783          	lbu	a5,0(a0)
 140:	cb91                	beqz	a5,154 <strcmp+0x1e>
 142:	0005c703          	lbu	a4,0(a1)
 146:	00f71763          	bne	a4,a5,154 <strcmp+0x1e>
    p++, q++;
 14a:	0505                	addi	a0,a0,1
 14c:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 14e:	00054783          	lbu	a5,0(a0)
 152:	fbe5                	bnez	a5,142 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 154:	0005c503          	lbu	a0,0(a1)
}
 158:	40a7853b          	subw	a0,a5,a0
 15c:	6422                	ld	s0,8(sp)
 15e:	0141                	addi	sp,sp,16
 160:	8082                	ret

0000000000000162 <strlen>:

uint
strlen(const char *s)
{
 162:	1141                	addi	sp,sp,-16
 164:	e422                	sd	s0,8(sp)
 166:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 168:	00054783          	lbu	a5,0(a0)
 16c:	cf91                	beqz	a5,188 <strlen+0x26>
 16e:	0505                	addi	a0,a0,1
 170:	87aa                	mv	a5,a0
 172:	86be                	mv	a3,a5
 174:	0785                	addi	a5,a5,1
 176:	fff7c703          	lbu	a4,-1(a5)
 17a:	ff65                	bnez	a4,172 <strlen+0x10>
 17c:	40a6853b          	subw	a0,a3,a0
 180:	2505                	addiw	a0,a0,1
    ;
  return n;
}
 182:	6422                	ld	s0,8(sp)
 184:	0141                	addi	sp,sp,16
 186:	8082                	ret
  for(n = 0; s[n]; n++)
 188:	4501                	li	a0,0
 18a:	bfe5                	j	182 <strlen+0x20>

000000000000018c <memset>:

void*
memset(void *dst, int c, uint n)
{
 18c:	1141                	addi	sp,sp,-16
 18e:	e422                	sd	s0,8(sp)
 190:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 192:	ca19                	beqz	a2,1a8 <memset+0x1c>
 194:	87aa                	mv	a5,a0
 196:	1602                	slli	a2,a2,0x20
 198:	9201                	srli	a2,a2,0x20
 19a:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 19e:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 1a2:	0785                	addi	a5,a5,1
 1a4:	fee79de3          	bne	a5,a4,19e <memset+0x12>
  }
  return dst;
}
 1a8:	6422                	ld	s0,8(sp)
 1aa:	0141                	addi	sp,sp,16
 1ac:	8082                	ret

00000000000001ae <strchr>:

char*
strchr(const char *s, char c)
{
 1ae:	1141                	addi	sp,sp,-16
 1b0:	e422                	sd	s0,8(sp)
 1b2:	0800                	addi	s0,sp,16
  for(; *s; s++)
 1b4:	00054783          	lbu	a5,0(a0)
 1b8:	cb99                	beqz	a5,1ce <strchr+0x20>
    if(*s == c)
 1ba:	00f58763          	beq	a1,a5,1c8 <strchr+0x1a>
  for(; *s; s++)
 1be:	0505                	addi	a0,a0,1
 1c0:	00054783          	lbu	a5,0(a0)
 1c4:	fbfd                	bnez	a5,1ba <strchr+0xc>
      return (char*)s;
  return 0;
 1c6:	4501                	li	a0,0
}
 1c8:	6422                	ld	s0,8(sp)
 1ca:	0141                	addi	sp,sp,16
 1cc:	8082                	ret
  return 0;
 1ce:	4501                	li	a0,0
 1d0:	bfe5                	j	1c8 <strchr+0x1a>

00000000000001d2 <gets>:

char*
gets(char *buf, int max)
{
 1d2:	711d                	addi	sp,sp,-96
 1d4:	ec86                	sd	ra,88(sp)
 1d6:	e8a2                	sd	s0,80(sp)
 1d8:	e4a6                	sd	s1,72(sp)
 1da:	e0ca                	sd	s2,64(sp)
 1dc:	fc4e                	sd	s3,56(sp)
 1de:	f852                	sd	s4,48(sp)
 1e0:	f456                	sd	s5,40(sp)
 1e2:	f05a                	sd	s6,32(sp)
 1e4:	ec5e                	sd	s7,24(sp)
 1e6:	1080                	addi	s0,sp,96
 1e8:	8baa                	mv	s7,a0
 1ea:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 1ec:	892a                	mv	s2,a0
 1ee:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 1f0:	4aa9                	li	s5,10
 1f2:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 1f4:	89a6                	mv	s3,s1
 1f6:	2485                	addiw	s1,s1,1
 1f8:	0344d663          	bge	s1,s4,224 <gets+0x52>
    cc = read(0, &c, 1);
 1fc:	4605                	li	a2,1
 1fe:	faf40593          	addi	a1,s0,-81
 202:	4501                	li	a0,0
 204:	1f0000ef          	jal	3f4 <read>
    if(cc < 1)
 208:	00a05e63          	blez	a0,224 <gets+0x52>
    buf[i++] = c;
 20c:	faf44783          	lbu	a5,-81(s0)
 210:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 214:	01578763          	beq	a5,s5,222 <gets+0x50>
 218:	0905                	addi	s2,s2,1
 21a:	fd679de3          	bne	a5,s6,1f4 <gets+0x22>
    buf[i++] = c;
 21e:	89a6                	mv	s3,s1
 220:	a011                	j	224 <gets+0x52>
 222:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 224:	99de                	add	s3,s3,s7
 226:	00098023          	sb	zero,0(s3)
  return buf;
}
 22a:	855e                	mv	a0,s7
 22c:	60e6                	ld	ra,88(sp)
 22e:	6446                	ld	s0,80(sp)
 230:	64a6                	ld	s1,72(sp)
 232:	6906                	ld	s2,64(sp)
 234:	79e2                	ld	s3,56(sp)
 236:	7a42                	ld	s4,48(sp)
 238:	7aa2                	ld	s5,40(sp)
 23a:	7b02                	ld	s6,32(sp)
 23c:	6be2                	ld	s7,24(sp)
 23e:	6125                	addi	sp,sp,96
 240:	8082                	ret

0000000000000242 <stat>:

int
stat(const char *n, struct stat *st)
{
 242:	1101                	addi	sp,sp,-32
 244:	ec06                	sd	ra,24(sp)
 246:	e822                	sd	s0,16(sp)
 248:	e04a                	sd	s2,0(sp)
 24a:	1000                	addi	s0,sp,32
 24c:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 24e:	4581                	li	a1,0
 250:	1cc000ef          	jal	41c <open>
  if(fd < 0)
 254:	02054263          	bltz	a0,278 <stat+0x36>
 258:	e426                	sd	s1,8(sp)
 25a:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 25c:	85ca                	mv	a1,s2
 25e:	1d6000ef          	jal	434 <fstat>
 262:	892a                	mv	s2,a0
  close(fd);
 264:	8526                	mv	a0,s1
 266:	19e000ef          	jal	404 <close>
  return r;
 26a:	64a2                	ld	s1,8(sp)
}
 26c:	854a                	mv	a0,s2
 26e:	60e2                	ld	ra,24(sp)
 270:	6442                	ld	s0,16(sp)
 272:	6902                	ld	s2,0(sp)
 274:	6105                	addi	sp,sp,32
 276:	8082                	ret
    return -1;
 278:	597d                	li	s2,-1
 27a:	bfcd                	j	26c <stat+0x2a>

000000000000027c <atoi>:

int
atoi(const char *s)
{
 27c:	1141                	addi	sp,sp,-16
 27e:	e422                	sd	s0,8(sp)
 280:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 282:	00054683          	lbu	a3,0(a0)
 286:	fd06879b          	addiw	a5,a3,-48
 28a:	0ff7f793          	zext.b	a5,a5
 28e:	4625                	li	a2,9
 290:	02f66863          	bltu	a2,a5,2c0 <atoi+0x44>
 294:	872a                	mv	a4,a0
  n = 0;
 296:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 298:	0705                	addi	a4,a4,1
 29a:	0025179b          	slliw	a5,a0,0x2
 29e:	9fa9                	addw	a5,a5,a0
 2a0:	0017979b          	slliw	a5,a5,0x1
 2a4:	9fb5                	addw	a5,a5,a3
 2a6:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 2aa:	00074683          	lbu	a3,0(a4)
 2ae:	fd06879b          	addiw	a5,a3,-48
 2b2:	0ff7f793          	zext.b	a5,a5
 2b6:	fef671e3          	bgeu	a2,a5,298 <atoi+0x1c>
  return n;
}
 2ba:	6422                	ld	s0,8(sp)
 2bc:	0141                	addi	sp,sp,16
 2be:	8082                	ret
  n = 0;
 2c0:	4501                	li	a0,0
 2c2:	bfe5                	j	2ba <atoi+0x3e>

00000000000002c4 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 2c4:	1141                	addi	sp,sp,-16
 2c6:	e422                	sd	s0,8(sp)
 2c8:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 2ca:	02b57463          	bgeu	a0,a1,2f2 <memmove+0x2e>
    while(n-- > 0)
 2ce:	00c05f63          	blez	a2,2ec <memmove+0x28>
 2d2:	1602                	slli	a2,a2,0x20
 2d4:	9201                	srli	a2,a2,0x20
 2d6:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 2da:	872a                	mv	a4,a0
      *dst++ = *src++;
 2dc:	0585                	addi	a1,a1,1
 2de:	0705                	addi	a4,a4,1
 2e0:	fff5c683          	lbu	a3,-1(a1)
 2e4:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 2e8:	fef71ae3          	bne	a4,a5,2dc <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 2ec:	6422                	ld	s0,8(sp)
 2ee:	0141                	addi	sp,sp,16
 2f0:	8082                	ret
    dst += n;
 2f2:	00c50733          	add	a4,a0,a2
    src += n;
 2f6:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 2f8:	fec05ae3          	blez	a2,2ec <memmove+0x28>
 2fc:	fff6079b          	addiw	a5,a2,-1
 300:	1782                	slli	a5,a5,0x20
 302:	9381                	srli	a5,a5,0x20
 304:	fff7c793          	not	a5,a5
 308:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 30a:	15fd                	addi	a1,a1,-1
 30c:	177d                	addi	a4,a4,-1
 30e:	0005c683          	lbu	a3,0(a1)
 312:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 316:	fee79ae3          	bne	a5,a4,30a <memmove+0x46>
 31a:	bfc9                	j	2ec <memmove+0x28>

000000000000031c <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 31c:	1141                	addi	sp,sp,-16
 31e:	e422                	sd	s0,8(sp)
 320:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 322:	ca05                	beqz	a2,352 <memcmp+0x36>
 324:	fff6069b          	addiw	a3,a2,-1
 328:	1682                	slli	a3,a3,0x20
 32a:	9281                	srli	a3,a3,0x20
 32c:	0685                	addi	a3,a3,1
 32e:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 330:	00054783          	lbu	a5,0(a0)
 334:	0005c703          	lbu	a4,0(a1)
 338:	00e79863          	bne	a5,a4,348 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 33c:	0505                	addi	a0,a0,1
    p2++;
 33e:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 340:	fed518e3          	bne	a0,a3,330 <memcmp+0x14>
  }
  return 0;
 344:	4501                	li	a0,0
 346:	a019                	j	34c <memcmp+0x30>
      return *p1 - *p2;
 348:	40e7853b          	subw	a0,a5,a4
}
 34c:	6422                	ld	s0,8(sp)
 34e:	0141                	addi	sp,sp,16
 350:	8082                	ret
  return 0;
 352:	4501                	li	a0,0
 354:	bfe5                	j	34c <memcmp+0x30>

0000000000000356 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 356:	1141                	addi	sp,sp,-16
 358:	e406                	sd	ra,8(sp)
 35a:	e022                	sd	s0,0(sp)
 35c:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 35e:	f67ff0ef          	jal	2c4 <memmove>
}
 362:	60a2                	ld	ra,8(sp)
 364:	6402                	ld	s0,0(sp)
 366:	0141                	addi	sp,sp,16
 368:	8082                	ret

000000000000036a <sbrk>:

char *
sbrk(int n) {
 36a:	1141                	addi	sp,sp,-16
 36c:	e406                	sd	ra,8(sp)
 36e:	e022                	sd	s0,0(sp)
 370:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
 372:	4585                	li	a1,1
 374:	0f0000ef          	jal	464 <sys_sbrk>
}
 378:	60a2                	ld	ra,8(sp)
 37a:	6402                	ld	s0,0(sp)
 37c:	0141                	addi	sp,sp,16
 37e:	8082                	ret

0000000000000380 <sbrklazy>:

char *
sbrklazy(int n) {
 380:	1141                	addi	sp,sp,-16
 382:	e406                	sd	ra,8(sp)
 384:	e022                	sd	s0,0(sp)
 386:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 388:	4589                	li	a1,2
 38a:	0da000ef          	jal	464 <sys_sbrk>
}
 38e:	60a2                	ld	ra,8(sp)
 390:	6402                	ld	s0,0(sp)
 392:	0141                	addi	sp,sp,16
 394:	8082                	ret

0000000000000396 <getcpuinfo>:

int
getcpuinfo(struct cpu_info *cpus, int ncpu)
{
 396:	1141                	addi	sp,sp,-16
 398:	e406                	sd	ra,8(sp)
 39a:	e022                	sd	s0,0(sp)
 39c:	0800                	addi	s0,sp,16
  // Stub: return 0 CPUs for now
  // In a full implementation, this would fetch CPU state from kernel
  memset(cpus, 0, ncpu * sizeof(struct cpu_info));
 39e:	0025961b          	slliw	a2,a1,0x2
 3a2:	9e2d                	addw	a2,a2,a1
 3a4:	0036161b          	slliw	a2,a2,0x3
 3a8:	4581                	li	a1,0
 3aa:	de3ff0ef          	jal	18c <memset>
  return 0;
}
 3ae:	4501                	li	a0,0
 3b0:	60a2                	ld	ra,8(sp)
 3b2:	6402                	ld	s0,0(sp)
 3b4:	0141                	addi	sp,sp,16
 3b6:	8082                	ret

00000000000003b8 <getprocstats>:

int
getprocstats(struct proc_stats *stats)
{
 3b8:	1141                	addi	sp,sp,-16
 3ba:	e406                	sd	ra,8(sp)
 3bc:	e022                	sd	s0,0(sp)
 3be:	0800                	addi	s0,sp,16
  // Stub: return zeros for now
  // In a full implementation, this would fetch process statistics from kernel
  memset(stats, 0, sizeof(struct proc_stats));
 3c0:	07000613          	li	a2,112
 3c4:	4581                	li	a1,0
 3c6:	dc7ff0ef          	jal	18c <memset>
  return 0;
}
 3ca:	4501                	li	a0,0
 3cc:	60a2                	ld	ra,8(sp)
 3ce:	6402                	ld	s0,0(sp)
 3d0:	0141                	addi	sp,sp,16
 3d2:	8082                	ret

00000000000003d4 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 3d4:	4885                	li	a7,1
 ecall
 3d6:	00000073          	ecall
 ret
 3da:	8082                	ret

00000000000003dc <exit>:
.global exit
exit:
 li a7, SYS_exit
 3dc:	4889                	li	a7,2
 ecall
 3de:	00000073          	ecall
 ret
 3e2:	8082                	ret

00000000000003e4 <wait>:
.global wait
wait:
 li a7, SYS_wait
 3e4:	488d                	li	a7,3
 ecall
 3e6:	00000073          	ecall
 ret
 3ea:	8082                	ret

00000000000003ec <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 3ec:	4891                	li	a7,4
 ecall
 3ee:	00000073          	ecall
 ret
 3f2:	8082                	ret

00000000000003f4 <read>:
.global read
read:
 li a7, SYS_read
 3f4:	4895                	li	a7,5
 ecall
 3f6:	00000073          	ecall
 ret
 3fa:	8082                	ret

00000000000003fc <write>:
.global write
write:
 li a7, SYS_write
 3fc:	48c1                	li	a7,16
 ecall
 3fe:	00000073          	ecall
 ret
 402:	8082                	ret

0000000000000404 <close>:
.global close
close:
 li a7, SYS_close
 404:	48d5                	li	a7,21
 ecall
 406:	00000073          	ecall
 ret
 40a:	8082                	ret

000000000000040c <kill>:
.global kill
kill:
 li a7, SYS_kill
 40c:	4899                	li	a7,6
 ecall
 40e:	00000073          	ecall
 ret
 412:	8082                	ret

0000000000000414 <exec>:
.global exec
exec:
 li a7, SYS_exec
 414:	489d                	li	a7,7
 ecall
 416:	00000073          	ecall
 ret
 41a:	8082                	ret

000000000000041c <open>:
.global open
open:
 li a7, SYS_open
 41c:	48bd                	li	a7,15
 ecall
 41e:	00000073          	ecall
 ret
 422:	8082                	ret

0000000000000424 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 424:	48c5                	li	a7,17
 ecall
 426:	00000073          	ecall
 ret
 42a:	8082                	ret

000000000000042c <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 42c:	48c9                	li	a7,18
 ecall
 42e:	00000073          	ecall
 ret
 432:	8082                	ret

0000000000000434 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 434:	48a1                	li	a7,8
 ecall
 436:	00000073          	ecall
 ret
 43a:	8082                	ret

000000000000043c <link>:
.global link
link:
 li a7, SYS_link
 43c:	48cd                	li	a7,19
 ecall
 43e:	00000073          	ecall
 ret
 442:	8082                	ret

0000000000000444 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 444:	48d1                	li	a7,20
 ecall
 446:	00000073          	ecall
 ret
 44a:	8082                	ret

000000000000044c <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 44c:	48a5                	li	a7,9
 ecall
 44e:	00000073          	ecall
 ret
 452:	8082                	ret

0000000000000454 <dup>:
.global dup
dup:
 li a7, SYS_dup
 454:	48a9                	li	a7,10
 ecall
 456:	00000073          	ecall
 ret
 45a:	8082                	ret

000000000000045c <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 45c:	48ad                	li	a7,11
 ecall
 45e:	00000073          	ecall
 ret
 462:	8082                	ret

0000000000000464 <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 464:	48b1                	li	a7,12
 ecall
 466:	00000073          	ecall
 ret
 46a:	8082                	ret

000000000000046c <pause>:
.global pause
pause:
 li a7, SYS_pause
 46c:	48b5                	li	a7,13
 ecall
 46e:	00000073          	ecall
 ret
 472:	8082                	ret

0000000000000474 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 474:	48b9                	li	a7,14
 ecall
 476:	00000073          	ecall
 ret
 47a:	8082                	ret

000000000000047c <csread>:
.global csread
csread:
 li a7, SYS_csread
 47c:	48d9                	li	a7,22
 ecall
 47e:	00000073          	ecall
 ret
 482:	8082                	ret

0000000000000484 <fsread>:
.global fsread
fsread:
 li a7, SYS_fsread
 484:	48dd                	li	a7,23
 ecall
 486:	00000073          	ecall
 ret
 48a:	8082                	ret

000000000000048c <schedread>:
.global schedread
schedread:
 li a7, SYS_schedread
 48c:	48e1                	li	a7,24
 ecall
 48e:	00000073          	ecall
 ret
 492:	8082                	ret

0000000000000494 <memread>:
.global memread
memread:
 li a7, SYS_memread
 494:	48e5                	li	a7,25
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
 4ae:	f4fff0ef          	jal	3fc <write>
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
 4c2:	0880                	addi	s0,sp,80
 4c4:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
 4c6:	c299                	beqz	a3,4cc <printint+0x12>
 4c8:	0805c363          	bltz	a1,54e <printint+0x94>
  neg = 0;
 4cc:	4881                	li	a7,0
 4ce:	fb840693          	addi	a3,s0,-72
    x = -xx;
  } else {
    x = xx;
  }

  i = 0;
 4d2:	4781                	li	a5,0
  do{
    buf[i++] = digits[x % base];
 4d4:	00000517          	auipc	a0,0x0
 4d8:	62c50513          	addi	a0,a0,1580 # b00 <digits>
 4dc:	883e                	mv	a6,a5
 4de:	2785                	addiw	a5,a5,1
 4e0:	02c5f733          	remu	a4,a1,a2
 4e4:	972a                	add	a4,a4,a0
 4e6:	00074703          	lbu	a4,0(a4)
 4ea:	00e68023          	sb	a4,0(a3)
  }while((x /= base) != 0);
 4ee:	872e                	mv	a4,a1
 4f0:	02c5d5b3          	divu	a1,a1,a2
 4f4:	0685                	addi	a3,a3,1
 4f6:	fec773e3          	bgeu	a4,a2,4dc <printint+0x22>
  if(neg)
 4fa:	00088b63          	beqz	a7,510 <printint+0x56>
    buf[i++] = '-';
 4fe:	fd078793          	addi	a5,a5,-48
 502:	97a2                	add	a5,a5,s0
 504:	02d00713          	li	a4,45
 508:	fee78423          	sb	a4,-24(a5)
 50c:	0028079b          	addiw	a5,a6,2

  while(--i >= 0)
 510:	02f05a63          	blez	a5,544 <printint+0x8a>
 514:	fc26                	sd	s1,56(sp)
 516:	f44e                	sd	s3,40(sp)
 518:	fb840713          	addi	a4,s0,-72
 51c:	00f704b3          	add	s1,a4,a5
 520:	fff70993          	addi	s3,a4,-1
 524:	99be                	add	s3,s3,a5
 526:	37fd                	addiw	a5,a5,-1
 528:	1782                	slli	a5,a5,0x20
 52a:	9381                	srli	a5,a5,0x20
 52c:	40f989b3          	sub	s3,s3,a5
    putc(fd, buf[i]);
 530:	fff4c583          	lbu	a1,-1(s1)
 534:	854a                	mv	a0,s2
 536:	f67ff0ef          	jal	49c <putc>
  while(--i >= 0)
 53a:	14fd                	addi	s1,s1,-1
 53c:	ff349ae3          	bne	s1,s3,530 <printint+0x76>
 540:	74e2                	ld	s1,56(sp)
 542:	79a2                	ld	s3,40(sp)
}
 544:	60a6                	ld	ra,72(sp)
 546:	6406                	ld	s0,64(sp)
 548:	7942                	ld	s2,48(sp)
 54a:	6161                	addi	sp,sp,80
 54c:	8082                	ret
    x = -xx;
 54e:	40b005b3          	neg	a1,a1
    neg = 1;
 552:	4885                	li	a7,1
    x = -xx;
 554:	bfad                	j	4ce <printint+0x14>

0000000000000556 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 556:	711d                	addi	sp,sp,-96
 558:	ec86                	sd	ra,88(sp)
 55a:	e8a2                	sd	s0,80(sp)
 55c:	e0ca                	sd	s2,64(sp)
 55e:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 560:	0005c903          	lbu	s2,0(a1)
 564:	28090663          	beqz	s2,7f0 <vprintf+0x29a>
 568:	e4a6                	sd	s1,72(sp)
 56a:	fc4e                	sd	s3,56(sp)
 56c:	f852                	sd	s4,48(sp)
 56e:	f456                	sd	s5,40(sp)
 570:	f05a                	sd	s6,32(sp)
 572:	ec5e                	sd	s7,24(sp)
 574:	e862                	sd	s8,16(sp)
 576:	e466                	sd	s9,8(sp)
 578:	8b2a                	mv	s6,a0
 57a:	8a2e                	mv	s4,a1
 57c:	8bb2                	mv	s7,a2
  state = 0;
 57e:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 580:	4481                	li	s1,0
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
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 58c:	06c00c93          	li	s9,108
 590:	a005                	j	5b0 <vprintf+0x5a>
        putc(fd, c0);
 592:	85ca                	mv	a1,s2
 594:	855a                	mv	a0,s6
 596:	f07ff0ef          	jal	49c <putc>
 59a:	a019                	j	5a0 <vprintf+0x4a>
    } else if(state == '%'){
 59c:	03598263          	beq	s3,s5,5c0 <vprintf+0x6a>
  for(i = 0; fmt[i]; i++){
 5a0:	2485                	addiw	s1,s1,1
 5a2:	8726                	mv	a4,s1
 5a4:	009a07b3          	add	a5,s4,s1
 5a8:	0007c903          	lbu	s2,0(a5)
 5ac:	22090a63          	beqz	s2,7e0 <vprintf+0x28a>
    c0 = fmt[i] & 0xff;
 5b0:	0009079b          	sext.w	a5,s2
    if(state == 0){
 5b4:	fe0994e3          	bnez	s3,59c <vprintf+0x46>
      if(c0 == '%'){
 5b8:	fd579de3          	bne	a5,s5,592 <vprintf+0x3c>
        state = '%';
 5bc:	89be                	mv	s3,a5
 5be:	b7cd                	j	5a0 <vprintf+0x4a>
      if(c0) c1 = fmt[i+1] & 0xff;
 5c0:	00ea06b3          	add	a3,s4,a4
 5c4:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
 5c8:	8636                	mv	a2,a3
      if(c1) c2 = fmt[i+2] & 0xff;
 5ca:	c681                	beqz	a3,5d2 <vprintf+0x7c>
 5cc:	9752                	add	a4,a4,s4
 5ce:	00274603          	lbu	a2,2(a4)
      if(c0 == 'd'){
 5d2:	05878363          	beq	a5,s8,618 <vprintf+0xc2>
      } else if(c0 == 'l' && c1 == 'd'){
 5d6:	05978d63          	beq	a5,s9,630 <vprintf+0xda>
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if(c0 == 'u'){
 5da:	07500713          	li	a4,117
 5de:	0ee78763          	beq	a5,a4,6cc <vprintf+0x176>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if(c0 == 'x'){
 5e2:	07800713          	li	a4,120
 5e6:	12e78963          	beq	a5,a4,718 <vprintf+0x1c2>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if(c0 == 'p'){
 5ea:	07000713          	li	a4,112
 5ee:	14e78e63          	beq	a5,a4,74a <vprintf+0x1f4>
        printptr(fd, va_arg(ap, uint64));
      } else if(c0 == 'c'){
 5f2:	06300713          	li	a4,99
 5f6:	18e78e63          	beq	a5,a4,792 <vprintf+0x23c>
        putc(fd, va_arg(ap, uint32));
      } else if(c0 == 's'){
 5fa:	07300713          	li	a4,115
 5fe:	1ae78463          	beq	a5,a4,7a6 <vprintf+0x250>
        if((s = va_arg(ap, char*)) == 0)
          s = "(null)";
        for(; *s; s++)
          putc(fd, *s);
      } else if(c0 == '%'){
 602:	02500713          	li	a4,37
 606:	04e79563          	bne	a5,a4,650 <vprintf+0xfa>
        putc(fd, '%');
 60a:	02500593          	li	a1,37
 60e:	855a                	mv	a0,s6
 610:	e8dff0ef          	jal	49c <putc>
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 614:	4981                	li	s3,0
 616:	b769                	j	5a0 <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 10, 1);
 618:	008b8913          	addi	s2,s7,8
 61c:	4685                	li	a3,1
 61e:	4629                	li	a2,10
 620:	000ba583          	lw	a1,0(s7)
 624:	855a                	mv	a0,s6
 626:	e95ff0ef          	jal	4ba <printint>
 62a:	8bca                	mv	s7,s2
      state = 0;
 62c:	4981                	li	s3,0
 62e:	bf8d                	j	5a0 <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'd'){
 630:	06400793          	li	a5,100
 634:	02f68963          	beq	a3,a5,666 <vprintf+0x110>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 638:	06c00793          	li	a5,108
 63c:	04f68263          	beq	a3,a5,680 <vprintf+0x12a>
      } else if(c0 == 'l' && c1 == 'u'){
 640:	07500793          	li	a5,117
 644:	0af68063          	beq	a3,a5,6e4 <vprintf+0x18e>
      } else if(c0 == 'l' && c1 == 'x'){
 648:	07800793          	li	a5,120
 64c:	0ef68263          	beq	a3,a5,730 <vprintf+0x1da>
        putc(fd, '%');
 650:	02500593          	li	a1,37
 654:	855a                	mv	a0,s6
 656:	e47ff0ef          	jal	49c <putc>
        putc(fd, c0);
 65a:	85ca                	mv	a1,s2
 65c:	855a                	mv	a0,s6
 65e:	e3fff0ef          	jal	49c <putc>
      state = 0;
 662:	4981                	li	s3,0
 664:	bf35                	j	5a0 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 666:	008b8913          	addi	s2,s7,8
 66a:	4685                	li	a3,1
 66c:	4629                	li	a2,10
 66e:	000bb583          	ld	a1,0(s7)
 672:	855a                	mv	a0,s6
 674:	e47ff0ef          	jal	4ba <printint>
        i += 1;
 678:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 67a:	8bca                	mv	s7,s2
      state = 0;
 67c:	4981                	li	s3,0
        i += 1;
 67e:	b70d                	j	5a0 <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 680:	06400793          	li	a5,100
 684:	02f60763          	beq	a2,a5,6b2 <vprintf+0x15c>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 688:	07500793          	li	a5,117
 68c:	06f60963          	beq	a2,a5,6fe <vprintf+0x1a8>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 690:	07800793          	li	a5,120
 694:	faf61ee3          	bne	a2,a5,650 <vprintf+0xfa>
        printint(fd, va_arg(ap, uint64), 16, 0);
 698:	008b8913          	addi	s2,s7,8
 69c:	4681                	li	a3,0
 69e:	4641                	li	a2,16
 6a0:	000bb583          	ld	a1,0(s7)
 6a4:	855a                	mv	a0,s6
 6a6:	e15ff0ef          	jal	4ba <printint>
        i += 2;
 6aa:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 6ac:	8bca                	mv	s7,s2
      state = 0;
 6ae:	4981                	li	s3,0
        i += 2;
 6b0:	bdc5                	j	5a0 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 6b2:	008b8913          	addi	s2,s7,8
 6b6:	4685                	li	a3,1
 6b8:	4629                	li	a2,10
 6ba:	000bb583          	ld	a1,0(s7)
 6be:	855a                	mv	a0,s6
 6c0:	dfbff0ef          	jal	4ba <printint>
        i += 2;
 6c4:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 6c6:	8bca                	mv	s7,s2
      state = 0;
 6c8:	4981                	li	s3,0
        i += 2;
 6ca:	bdd9                	j	5a0 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint32), 10, 0);
 6cc:	008b8913          	addi	s2,s7,8
 6d0:	4681                	li	a3,0
 6d2:	4629                	li	a2,10
 6d4:	000be583          	lwu	a1,0(s7)
 6d8:	855a                	mv	a0,s6
 6da:	de1ff0ef          	jal	4ba <printint>
 6de:	8bca                	mv	s7,s2
      state = 0;
 6e0:	4981                	li	s3,0
 6e2:	bd7d                	j	5a0 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 6e4:	008b8913          	addi	s2,s7,8
 6e8:	4681                	li	a3,0
 6ea:	4629                	li	a2,10
 6ec:	000bb583          	ld	a1,0(s7)
 6f0:	855a                	mv	a0,s6
 6f2:	dc9ff0ef          	jal	4ba <printint>
        i += 1;
 6f6:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 6f8:	8bca                	mv	s7,s2
      state = 0;
 6fa:	4981                	li	s3,0
        i += 1;
 6fc:	b555                	j	5a0 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 6fe:	008b8913          	addi	s2,s7,8
 702:	4681                	li	a3,0
 704:	4629                	li	a2,10
 706:	000bb583          	ld	a1,0(s7)
 70a:	855a                	mv	a0,s6
 70c:	dafff0ef          	jal	4ba <printint>
        i += 2;
 710:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 712:	8bca                	mv	s7,s2
      state = 0;
 714:	4981                	li	s3,0
        i += 2;
 716:	b569                	j	5a0 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint32), 16, 0);
 718:	008b8913          	addi	s2,s7,8
 71c:	4681                	li	a3,0
 71e:	4641                	li	a2,16
 720:	000be583          	lwu	a1,0(s7)
 724:	855a                	mv	a0,s6
 726:	d95ff0ef          	jal	4ba <printint>
 72a:	8bca                	mv	s7,s2
      state = 0;
 72c:	4981                	li	s3,0
 72e:	bd8d                	j	5a0 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 16, 0);
 730:	008b8913          	addi	s2,s7,8
 734:	4681                	li	a3,0
 736:	4641                	li	a2,16
 738:	000bb583          	ld	a1,0(s7)
 73c:	855a                	mv	a0,s6
 73e:	d7dff0ef          	jal	4ba <printint>
        i += 1;
 742:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 744:	8bca                	mv	s7,s2
      state = 0;
 746:	4981                	li	s3,0
        i += 1;
 748:	bda1                	j	5a0 <vprintf+0x4a>
 74a:	e06a                	sd	s10,0(sp)
        printptr(fd, va_arg(ap, uint64));
 74c:	008b8d13          	addi	s10,s7,8
 750:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 754:	03000593          	li	a1,48
 758:	855a                	mv	a0,s6
 75a:	d43ff0ef          	jal	49c <putc>
  putc(fd, 'x');
 75e:	07800593          	li	a1,120
 762:	855a                	mv	a0,s6
 764:	d39ff0ef          	jal	49c <putc>
 768:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 76a:	00000b97          	auipc	s7,0x0
 76e:	396b8b93          	addi	s7,s7,918 # b00 <digits>
 772:	03c9d793          	srli	a5,s3,0x3c
 776:	97de                	add	a5,a5,s7
 778:	0007c583          	lbu	a1,0(a5)
 77c:	855a                	mv	a0,s6
 77e:	d1fff0ef          	jal	49c <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 782:	0992                	slli	s3,s3,0x4
 784:	397d                	addiw	s2,s2,-1
 786:	fe0916e3          	bnez	s2,772 <vprintf+0x21c>
        printptr(fd, va_arg(ap, uint64));
 78a:	8bea                	mv	s7,s10
      state = 0;
 78c:	4981                	li	s3,0
 78e:	6d02                	ld	s10,0(sp)
 790:	bd01                	j	5a0 <vprintf+0x4a>
        putc(fd, va_arg(ap, uint32));
 792:	008b8913          	addi	s2,s7,8
 796:	000bc583          	lbu	a1,0(s7)
 79a:	855a                	mv	a0,s6
 79c:	d01ff0ef          	jal	49c <putc>
 7a0:	8bca                	mv	s7,s2
      state = 0;
 7a2:	4981                	li	s3,0
 7a4:	bbf5                	j	5a0 <vprintf+0x4a>
        if((s = va_arg(ap, char*)) == 0)
 7a6:	008b8993          	addi	s3,s7,8
 7aa:	000bb903          	ld	s2,0(s7)
 7ae:	00090f63          	beqz	s2,7cc <vprintf+0x276>
        for(; *s; s++)
 7b2:	00094583          	lbu	a1,0(s2)
 7b6:	c195                	beqz	a1,7da <vprintf+0x284>
          putc(fd, *s);
 7b8:	855a                	mv	a0,s6
 7ba:	ce3ff0ef          	jal	49c <putc>
        for(; *s; s++)
 7be:	0905                	addi	s2,s2,1
 7c0:	00094583          	lbu	a1,0(s2)
 7c4:	f9f5                	bnez	a1,7b8 <vprintf+0x262>
        if((s = va_arg(ap, char*)) == 0)
 7c6:	8bce                	mv	s7,s3
      state = 0;
 7c8:	4981                	li	s3,0
 7ca:	bbd9                	j	5a0 <vprintf+0x4a>
          s = "(null)";
 7cc:	00000917          	auipc	s2,0x0
 7d0:	32c90913          	addi	s2,s2,812 # af8 <malloc+0x220>
        for(; *s; s++)
 7d4:	02800593          	li	a1,40
 7d8:	b7c5                	j	7b8 <vprintf+0x262>
        if((s = va_arg(ap, char*)) == 0)
 7da:	8bce                	mv	s7,s3
      state = 0;
 7dc:	4981                	li	s3,0
 7de:	b3c9                	j	5a0 <vprintf+0x4a>
 7e0:	64a6                	ld	s1,72(sp)
 7e2:	79e2                	ld	s3,56(sp)
 7e4:	7a42                	ld	s4,48(sp)
 7e6:	7aa2                	ld	s5,40(sp)
 7e8:	7b02                	ld	s6,32(sp)
 7ea:	6be2                	ld	s7,24(sp)
 7ec:	6c42                	ld	s8,16(sp)
 7ee:	6ca2                	ld	s9,8(sp)
    }
  }
}
 7f0:	60e6                	ld	ra,88(sp)
 7f2:	6446                	ld	s0,80(sp)
 7f4:	6906                	ld	s2,64(sp)
 7f6:	6125                	addi	sp,sp,96
 7f8:	8082                	ret

00000000000007fa <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 7fa:	715d                	addi	sp,sp,-80
 7fc:	ec06                	sd	ra,24(sp)
 7fe:	e822                	sd	s0,16(sp)
 800:	1000                	addi	s0,sp,32
 802:	e010                	sd	a2,0(s0)
 804:	e414                	sd	a3,8(s0)
 806:	e818                	sd	a4,16(s0)
 808:	ec1c                	sd	a5,24(s0)
 80a:	03043023          	sd	a6,32(s0)
 80e:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 812:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 816:	8622                	mv	a2,s0
 818:	d3fff0ef          	jal	556 <vprintf>
}
 81c:	60e2                	ld	ra,24(sp)
 81e:	6442                	ld	s0,16(sp)
 820:	6161                	addi	sp,sp,80
 822:	8082                	ret

0000000000000824 <printf>:

void
printf(const char *fmt, ...)
{
 824:	711d                	addi	sp,sp,-96
 826:	ec06                	sd	ra,24(sp)
 828:	e822                	sd	s0,16(sp)
 82a:	1000                	addi	s0,sp,32
 82c:	e40c                	sd	a1,8(s0)
 82e:	e810                	sd	a2,16(s0)
 830:	ec14                	sd	a3,24(s0)
 832:	f018                	sd	a4,32(s0)
 834:	f41c                	sd	a5,40(s0)
 836:	03043823          	sd	a6,48(s0)
 83a:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 83e:	00840613          	addi	a2,s0,8
 842:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 846:	85aa                	mv	a1,a0
 848:	4505                	li	a0,1
 84a:	d0dff0ef          	jal	556 <vprintf>
}
 84e:	60e2                	ld	ra,24(sp)
 850:	6442                	ld	s0,16(sp)
 852:	6125                	addi	sp,sp,96
 854:	8082                	ret

0000000000000856 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 856:	1141                	addi	sp,sp,-16
 858:	e422                	sd	s0,8(sp)
 85a:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 85c:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 860:	00000797          	auipc	a5,0x0
 864:	7a07b783          	ld	a5,1952(a5) # 1000 <freep>
 868:	a02d                	j	892 <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 86a:	4618                	lw	a4,8(a2)
 86c:	9f2d                	addw	a4,a4,a1
 86e:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 872:	6398                	ld	a4,0(a5)
 874:	6310                	ld	a2,0(a4)
 876:	a83d                	j	8b4 <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 878:	ff852703          	lw	a4,-8(a0)
 87c:	9f31                	addw	a4,a4,a2
 87e:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 880:	ff053683          	ld	a3,-16(a0)
 884:	a091                	j	8c8 <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 886:	6398                	ld	a4,0(a5)
 888:	00e7e463          	bltu	a5,a4,890 <free+0x3a>
 88c:	00e6ea63          	bltu	a3,a4,8a0 <free+0x4a>
{
 890:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 892:	fed7fae3          	bgeu	a5,a3,886 <free+0x30>
 896:	6398                	ld	a4,0(a5)
 898:	00e6e463          	bltu	a3,a4,8a0 <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 89c:	fee7eae3          	bltu	a5,a4,890 <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 8a0:	ff852583          	lw	a1,-8(a0)
 8a4:	6390                	ld	a2,0(a5)
 8a6:	02059813          	slli	a6,a1,0x20
 8aa:	01c85713          	srli	a4,a6,0x1c
 8ae:	9736                	add	a4,a4,a3
 8b0:	fae60de3          	beq	a2,a4,86a <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 8b4:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 8b8:	4790                	lw	a2,8(a5)
 8ba:	02061593          	slli	a1,a2,0x20
 8be:	01c5d713          	srli	a4,a1,0x1c
 8c2:	973e                	add	a4,a4,a5
 8c4:	fae68ae3          	beq	a3,a4,878 <free+0x22>
    p->s.ptr = bp->s.ptr;
 8c8:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 8ca:	00000717          	auipc	a4,0x0
 8ce:	72f73b23          	sd	a5,1846(a4) # 1000 <freep>
}
 8d2:	6422                	ld	s0,8(sp)
 8d4:	0141                	addi	sp,sp,16
 8d6:	8082                	ret

00000000000008d8 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 8d8:	7139                	addi	sp,sp,-64
 8da:	fc06                	sd	ra,56(sp)
 8dc:	f822                	sd	s0,48(sp)
 8de:	f426                	sd	s1,40(sp)
 8e0:	ec4e                	sd	s3,24(sp)
 8e2:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 8e4:	02051493          	slli	s1,a0,0x20
 8e8:	9081                	srli	s1,s1,0x20
 8ea:	04bd                	addi	s1,s1,15
 8ec:	8091                	srli	s1,s1,0x4
 8ee:	0014899b          	addiw	s3,s1,1
 8f2:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 8f4:	00000517          	auipc	a0,0x0
 8f8:	70c53503          	ld	a0,1804(a0) # 1000 <freep>
 8fc:	c915                	beqz	a0,930 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8fe:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 900:	4798                	lw	a4,8(a5)
 902:	08977a63          	bgeu	a4,s1,996 <malloc+0xbe>
 906:	f04a                	sd	s2,32(sp)
 908:	e852                	sd	s4,16(sp)
 90a:	e456                	sd	s5,8(sp)
 90c:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 90e:	8a4e                	mv	s4,s3
 910:	0009871b          	sext.w	a4,s3
 914:	6685                	lui	a3,0x1
 916:	00d77363          	bgeu	a4,a3,91c <malloc+0x44>
 91a:	6a05                	lui	s4,0x1
 91c:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 920:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 924:	00000917          	auipc	s2,0x0
 928:	6dc90913          	addi	s2,s2,1756 # 1000 <freep>
  if(p == SBRK_ERROR)
 92c:	5afd                	li	s5,-1
 92e:	a081                	j	96e <malloc+0x96>
 930:	f04a                	sd	s2,32(sp)
 932:	e852                	sd	s4,16(sp)
 934:	e456                	sd	s5,8(sp)
 936:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 938:	00000797          	auipc	a5,0x0
 93c:	6d878793          	addi	a5,a5,1752 # 1010 <base>
 940:	00000717          	auipc	a4,0x0
 944:	6cf73023          	sd	a5,1728(a4) # 1000 <freep>
 948:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 94a:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 94e:	b7c1                	j	90e <malloc+0x36>
        prevp->s.ptr = p->s.ptr;
 950:	6398                	ld	a4,0(a5)
 952:	e118                	sd	a4,0(a0)
 954:	a8a9                	j	9ae <malloc+0xd6>
  hp->s.size = nu;
 956:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 95a:	0541                	addi	a0,a0,16
 95c:	efbff0ef          	jal	856 <free>
  return freep;
 960:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 964:	c12d                	beqz	a0,9c6 <malloc+0xee>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 966:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 968:	4798                	lw	a4,8(a5)
 96a:	02977263          	bgeu	a4,s1,98e <malloc+0xb6>
    if(p == freep)
 96e:	00093703          	ld	a4,0(s2)
 972:	853e                	mv	a0,a5
 974:	fef719e3          	bne	a4,a5,966 <malloc+0x8e>
  p = sbrk(nu * sizeof(Header));
 978:	8552                	mv	a0,s4
 97a:	9f1ff0ef          	jal	36a <sbrk>
  if(p == SBRK_ERROR)
 97e:	fd551ce3          	bne	a0,s5,956 <malloc+0x7e>
        return 0;
 982:	4501                	li	a0,0
 984:	7902                	ld	s2,32(sp)
 986:	6a42                	ld	s4,16(sp)
 988:	6aa2                	ld	s5,8(sp)
 98a:	6b02                	ld	s6,0(sp)
 98c:	a03d                	j	9ba <malloc+0xe2>
 98e:	7902                	ld	s2,32(sp)
 990:	6a42                	ld	s4,16(sp)
 992:	6aa2                	ld	s5,8(sp)
 994:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 996:	fae48de3          	beq	s1,a4,950 <malloc+0x78>
        p->s.size -= nunits;
 99a:	4137073b          	subw	a4,a4,s3
 99e:	c798                	sw	a4,8(a5)
        p += p->s.size;
 9a0:	02071693          	slli	a3,a4,0x20
 9a4:	01c6d713          	srli	a4,a3,0x1c
 9a8:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 9aa:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 9ae:	00000717          	auipc	a4,0x0
 9b2:	64a73923          	sd	a0,1618(a4) # 1000 <freep>
      return (void*)(p + 1);
 9b6:	01078513          	addi	a0,a5,16
  }
}
 9ba:	70e2                	ld	ra,56(sp)
 9bc:	7442                	ld	s0,48(sp)
 9be:	74a2                	ld	s1,40(sp)
 9c0:	69e2                	ld	s3,24(sp)
 9c2:	6121                	addi	sp,sp,64
 9c4:	8082                	ret
 9c6:	7902                	ld	s2,32(sp)
 9c8:	6a42                	ld	s4,16(sp)
 9ca:	6aa2                	ld	s5,8(sp)
 9cc:	6b02                	ld	s6,0(sp)
 9ce:	b7f5                	j	9ba <malloc+0xe2>
