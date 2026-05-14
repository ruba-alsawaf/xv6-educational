
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
  3e:	a3ec0c13          	addi	s8,s8,-1474 # a78 <malloc+0x1ce>
    printf("EV {\"seq\":%d,\"tick\":%d,\"type\":\"ON_CPU\",\"cpu\":%d,\"pid\":%d,\"name\":\"%s\",\"state\":%d}\n",
  42:	00001b97          	auipc	s7,0x1
  46:	9deb8b93          	addi	s7,s7,-1570 # a20 <malloc+0x176>
    printf("EV {\"seq\":%d,\"tick\":%d,\"type\":\"SCHED_INFO\",\"scheduler\":\"%s\",\"cpus\":%d,\"time_slice\":%d}\n",
  4a:	00001b17          	auipc	s6,0x1
  4e:	97eb0b13          	addi	s6,s6,-1666 # 9c8 <malloc+0x11e>
  52:	a041                	j	d2 <main+0xd2>
  54:	ff44a783          	lw	a5,-12(s1)
  58:	ff04a703          	lw	a4,-16(s1)
  5c:	fe048693          	addi	a3,s1,-32
  60:	fd84a603          	lw	a2,-40(s1)
  64:	fd44a583          	lw	a1,-44(s1)
  68:	855a                	mv	a0,s6
  6a:	78c000ef          	jal	7f6 <printf>
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
  a2:	754000ef          	jal	7f6 <printf>
  a6:	b7e1                	j	6e <main+0x6e>
    printf("EV {\"seq\":%d,\"tick\":%d,\"type\":\"ON_CPU\",\"cpu\":%d,\"pid\":%d,\"name\":\"%s\",\"state\":%d}\n",
  a8:	0104a803          	lw	a6,16(s1)
  ac:	ffc4a703          	lw	a4,-4(s1)
  b0:	ff84a683          	lw	a3,-8(s1)
  b4:	fd84a603          	lw	a2,-40(s1)
  b8:	fd44a583          	lw	a1,-44(s1)
  bc:	855e                	mv	a0,s7
  be:	738000ef          	jal	7f6 <printf>
  c2:	b775                	j	6e <main+0x6e>
      print_sched_event(&ev[i]);
    }

    pause(10);
  c4:	4529                	li	a0,10
  c6:	378000ef          	jal	43e <pause>
  for(int round = 0; round < 5; round++){
  ca:	2a85                	addiw	s5,s5,1
  cc:	4795                	li	a5,5
  ce:	02fa8b63          	beq	s5,a5,104 <main+0x104>
    int n = schedread(ev, 16);
  d2:	45c1                	li	a1,16
  d4:	b6040513          	addi	a0,s0,-1184
  d8:	386000ef          	jal	45e <schedread>
  dc:	8caa                	mv	s9,a0
    printf("round=%d n=%d\n", round, n);
  de:	862a                	mv	a2,a0
  e0:	85d6                	mv	a1,s5
  e2:	00001517          	auipc	a0,0x1
  e6:	8ce50513          	addi	a0,a0,-1842 # 9b0 <malloc+0x106>
  ea:	70c000ef          	jal	7f6 <printf>
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
 106:	298000ef          	jal	39e <exit>

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
 116:	288000ef          	jal	39e <exit>

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
 204:	1b2000ef          	jal	3b6 <read>
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
 250:	18e000ef          	jal	3de <open>
  if(fd < 0)
 254:	02054263          	bltz	a0,278 <stat+0x36>
 258:	e426                	sd	s1,8(sp)
 25a:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 25c:	85ca                	mv	a1,s2
 25e:	198000ef          	jal	3f6 <fstat>
 262:	892a                	mv	s2,a0
  close(fd);
 264:	8526                	mv	a0,s1
 266:	160000ef          	jal	3c6 <close>
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
 374:	0c2000ef          	jal	436 <sys_sbrk>
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
 38a:	0ac000ef          	jal	436 <sys_sbrk>
}
 38e:	60a2                	ld	ra,8(sp)
 390:	6402                	ld	s0,0(sp)
 392:	0141                	addi	sp,sp,16
 394:	8082                	ret

0000000000000396 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 396:	4885                	li	a7,1
 ecall
 398:	00000073          	ecall
 ret
 39c:	8082                	ret

000000000000039e <exit>:
.global exit
exit:
 li a7, SYS_exit
 39e:	4889                	li	a7,2
 ecall
 3a0:	00000073          	ecall
 ret
 3a4:	8082                	ret

00000000000003a6 <wait>:
.global wait
wait:
 li a7, SYS_wait
 3a6:	488d                	li	a7,3
 ecall
 3a8:	00000073          	ecall
 ret
 3ac:	8082                	ret

00000000000003ae <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 3ae:	4891                	li	a7,4
 ecall
 3b0:	00000073          	ecall
 ret
 3b4:	8082                	ret

00000000000003b6 <read>:
.global read
read:
 li a7, SYS_read
 3b6:	4895                	li	a7,5
 ecall
 3b8:	00000073          	ecall
 ret
 3bc:	8082                	ret

00000000000003be <write>:
.global write
write:
 li a7, SYS_write
 3be:	48c1                	li	a7,16
 ecall
 3c0:	00000073          	ecall
 ret
 3c4:	8082                	ret

00000000000003c6 <close>:
.global close
close:
 li a7, SYS_close
 3c6:	48d5                	li	a7,21
 ecall
 3c8:	00000073          	ecall
 ret
 3cc:	8082                	ret

00000000000003ce <kill>:
.global kill
kill:
 li a7, SYS_kill
 3ce:	4899                	li	a7,6
 ecall
 3d0:	00000073          	ecall
 ret
 3d4:	8082                	ret

00000000000003d6 <exec>:
.global exec
exec:
 li a7, SYS_exec
 3d6:	489d                	li	a7,7
 ecall
 3d8:	00000073          	ecall
 ret
 3dc:	8082                	ret

00000000000003de <open>:
.global open
open:
 li a7, SYS_open
 3de:	48bd                	li	a7,15
 ecall
 3e0:	00000073          	ecall
 ret
 3e4:	8082                	ret

00000000000003e6 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 3e6:	48c5                	li	a7,17
 ecall
 3e8:	00000073          	ecall
 ret
 3ec:	8082                	ret

00000000000003ee <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 3ee:	48c9                	li	a7,18
 ecall
 3f0:	00000073          	ecall
 ret
 3f4:	8082                	ret

00000000000003f6 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 3f6:	48a1                	li	a7,8
 ecall
 3f8:	00000073          	ecall
 ret
 3fc:	8082                	ret

00000000000003fe <link>:
.global link
link:
 li a7, SYS_link
 3fe:	48cd                	li	a7,19
 ecall
 400:	00000073          	ecall
 ret
 404:	8082                	ret

0000000000000406 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 406:	48d1                	li	a7,20
 ecall
 408:	00000073          	ecall
 ret
 40c:	8082                	ret

000000000000040e <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 40e:	48a5                	li	a7,9
 ecall
 410:	00000073          	ecall
 ret
 414:	8082                	ret

0000000000000416 <dup>:
.global dup
dup:
 li a7, SYS_dup
 416:	48a9                	li	a7,10
 ecall
 418:	00000073          	ecall
 ret
 41c:	8082                	ret

000000000000041e <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 41e:	48ad                	li	a7,11
 ecall
 420:	00000073          	ecall
 ret
 424:	8082                	ret

0000000000000426 <getcpuinfo>:
.global getcpuinfo
getcpuinfo:
 li a7, SYS_getcpuinfo
 426:	48e9                	li	a7,26
 ecall
 428:	00000073          	ecall
 ret
 42c:	8082                	ret

000000000000042e <getprocstats>:
.global getprocstats
getprocstats:
 li a7, SYS_getprocstats
 42e:	48ed                	li	a7,27
 ecall
 430:	00000073          	ecall
 ret
 434:	8082                	ret

0000000000000436 <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 436:	48b1                	li	a7,12
 ecall
 438:	00000073          	ecall
 ret
 43c:	8082                	ret

000000000000043e <pause>:
.global pause
pause:
 li a7, SYS_pause
 43e:	48b5                	li	a7,13
 ecall
 440:	00000073          	ecall
 ret
 444:	8082                	ret

0000000000000446 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 446:	48b9                	li	a7,14
 ecall
 448:	00000073          	ecall
 ret
 44c:	8082                	ret

000000000000044e <csread>:
.global csread
csread:
 li a7, SYS_csread
 44e:	48d9                	li	a7,22
 ecall
 450:	00000073          	ecall
 ret
 454:	8082                	ret

0000000000000456 <fsread>:
.global fsread
fsread:
 li a7, SYS_fsread
 456:	48dd                	li	a7,23
 ecall
 458:	00000073          	ecall
 ret
 45c:	8082                	ret

000000000000045e <schedread>:
.global schedread
schedread:
 li a7, SYS_schedread
 45e:	48e1                	li	a7,24
 ecall
 460:	00000073          	ecall
 ret
 464:	8082                	ret

0000000000000466 <memread>:
.global memread
memread:
 li a7, SYS_memread
 466:	48e5                	li	a7,25
 ecall
 468:	00000073          	ecall
 ret
 46c:	8082                	ret

000000000000046e <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 46e:	1101                	addi	sp,sp,-32
 470:	ec06                	sd	ra,24(sp)
 472:	e822                	sd	s0,16(sp)
 474:	1000                	addi	s0,sp,32
 476:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 47a:	4605                	li	a2,1
 47c:	fef40593          	addi	a1,s0,-17
 480:	f3fff0ef          	jal	3be <write>
}
 484:	60e2                	ld	ra,24(sp)
 486:	6442                	ld	s0,16(sp)
 488:	6105                	addi	sp,sp,32
 48a:	8082                	ret

000000000000048c <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
 48c:	715d                	addi	sp,sp,-80
 48e:	e486                	sd	ra,72(sp)
 490:	e0a2                	sd	s0,64(sp)
 492:	f84a                	sd	s2,48(sp)
 494:	0880                	addi	s0,sp,80
 496:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
 498:	c299                	beqz	a3,49e <printint+0x12>
 49a:	0805c363          	bltz	a1,520 <printint+0x94>
  neg = 0;
 49e:	4881                	li	a7,0
 4a0:	fb840693          	addi	a3,s0,-72
    x = -xx;
  } else {
    x = xx;
  }

  i = 0;
 4a4:	4781                	li	a5,0
  do{
    buf[i++] = digits[x % base];
 4a6:	00000517          	auipc	a0,0x0
 4aa:	63a50513          	addi	a0,a0,1594 # ae0 <digits>
 4ae:	883e                	mv	a6,a5
 4b0:	2785                	addiw	a5,a5,1
 4b2:	02c5f733          	remu	a4,a1,a2
 4b6:	972a                	add	a4,a4,a0
 4b8:	00074703          	lbu	a4,0(a4)
 4bc:	00e68023          	sb	a4,0(a3)
  }while((x /= base) != 0);
 4c0:	872e                	mv	a4,a1
 4c2:	02c5d5b3          	divu	a1,a1,a2
 4c6:	0685                	addi	a3,a3,1
 4c8:	fec773e3          	bgeu	a4,a2,4ae <printint+0x22>
  if(neg)
 4cc:	00088b63          	beqz	a7,4e2 <printint+0x56>
    buf[i++] = '-';
 4d0:	fd078793          	addi	a5,a5,-48
 4d4:	97a2                	add	a5,a5,s0
 4d6:	02d00713          	li	a4,45
 4da:	fee78423          	sb	a4,-24(a5)
 4de:	0028079b          	addiw	a5,a6,2

  while(--i >= 0)
 4e2:	02f05a63          	blez	a5,516 <printint+0x8a>
 4e6:	fc26                	sd	s1,56(sp)
 4e8:	f44e                	sd	s3,40(sp)
 4ea:	fb840713          	addi	a4,s0,-72
 4ee:	00f704b3          	add	s1,a4,a5
 4f2:	fff70993          	addi	s3,a4,-1
 4f6:	99be                	add	s3,s3,a5
 4f8:	37fd                	addiw	a5,a5,-1
 4fa:	1782                	slli	a5,a5,0x20
 4fc:	9381                	srli	a5,a5,0x20
 4fe:	40f989b3          	sub	s3,s3,a5
    putc(fd, buf[i]);
 502:	fff4c583          	lbu	a1,-1(s1)
 506:	854a                	mv	a0,s2
 508:	f67ff0ef          	jal	46e <putc>
  while(--i >= 0)
 50c:	14fd                	addi	s1,s1,-1
 50e:	ff349ae3          	bne	s1,s3,502 <printint+0x76>
 512:	74e2                	ld	s1,56(sp)
 514:	79a2                	ld	s3,40(sp)
}
 516:	60a6                	ld	ra,72(sp)
 518:	6406                	ld	s0,64(sp)
 51a:	7942                	ld	s2,48(sp)
 51c:	6161                	addi	sp,sp,80
 51e:	8082                	ret
    x = -xx;
 520:	40b005b3          	neg	a1,a1
    neg = 1;
 524:	4885                	li	a7,1
    x = -xx;
 526:	bfad                	j	4a0 <printint+0x14>

0000000000000528 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 528:	711d                	addi	sp,sp,-96
 52a:	ec86                	sd	ra,88(sp)
 52c:	e8a2                	sd	s0,80(sp)
 52e:	e0ca                	sd	s2,64(sp)
 530:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 532:	0005c903          	lbu	s2,0(a1)
 536:	28090663          	beqz	s2,7c2 <vprintf+0x29a>
 53a:	e4a6                	sd	s1,72(sp)
 53c:	fc4e                	sd	s3,56(sp)
 53e:	f852                	sd	s4,48(sp)
 540:	f456                	sd	s5,40(sp)
 542:	f05a                	sd	s6,32(sp)
 544:	ec5e                	sd	s7,24(sp)
 546:	e862                	sd	s8,16(sp)
 548:	e466                	sd	s9,8(sp)
 54a:	8b2a                	mv	s6,a0
 54c:	8a2e                	mv	s4,a1
 54e:	8bb2                	mv	s7,a2
  state = 0;
 550:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 552:	4481                	li	s1,0
 554:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 556:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 55a:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 55e:	06c00c93          	li	s9,108
 562:	a005                	j	582 <vprintf+0x5a>
        putc(fd, c0);
 564:	85ca                	mv	a1,s2
 566:	855a                	mv	a0,s6
 568:	f07ff0ef          	jal	46e <putc>
 56c:	a019                	j	572 <vprintf+0x4a>
    } else if(state == '%'){
 56e:	03598263          	beq	s3,s5,592 <vprintf+0x6a>
  for(i = 0; fmt[i]; i++){
 572:	2485                	addiw	s1,s1,1
 574:	8726                	mv	a4,s1
 576:	009a07b3          	add	a5,s4,s1
 57a:	0007c903          	lbu	s2,0(a5)
 57e:	22090a63          	beqz	s2,7b2 <vprintf+0x28a>
    c0 = fmt[i] & 0xff;
 582:	0009079b          	sext.w	a5,s2
    if(state == 0){
 586:	fe0994e3          	bnez	s3,56e <vprintf+0x46>
      if(c0 == '%'){
 58a:	fd579de3          	bne	a5,s5,564 <vprintf+0x3c>
        state = '%';
 58e:	89be                	mv	s3,a5
 590:	b7cd                	j	572 <vprintf+0x4a>
      if(c0) c1 = fmt[i+1] & 0xff;
 592:	00ea06b3          	add	a3,s4,a4
 596:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
 59a:	8636                	mv	a2,a3
      if(c1) c2 = fmt[i+2] & 0xff;
 59c:	c681                	beqz	a3,5a4 <vprintf+0x7c>
 59e:	9752                	add	a4,a4,s4
 5a0:	00274603          	lbu	a2,2(a4)
      if(c0 == 'd'){
 5a4:	05878363          	beq	a5,s8,5ea <vprintf+0xc2>
      } else if(c0 == 'l' && c1 == 'd'){
 5a8:	05978d63          	beq	a5,s9,602 <vprintf+0xda>
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if(c0 == 'u'){
 5ac:	07500713          	li	a4,117
 5b0:	0ee78763          	beq	a5,a4,69e <vprintf+0x176>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if(c0 == 'x'){
 5b4:	07800713          	li	a4,120
 5b8:	12e78963          	beq	a5,a4,6ea <vprintf+0x1c2>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if(c0 == 'p'){
 5bc:	07000713          	li	a4,112
 5c0:	14e78e63          	beq	a5,a4,71c <vprintf+0x1f4>
        printptr(fd, va_arg(ap, uint64));
      } else if(c0 == 'c'){
 5c4:	06300713          	li	a4,99
 5c8:	18e78e63          	beq	a5,a4,764 <vprintf+0x23c>
        putc(fd, va_arg(ap, uint32));
      } else if(c0 == 's'){
 5cc:	07300713          	li	a4,115
 5d0:	1ae78463          	beq	a5,a4,778 <vprintf+0x250>
        if((s = va_arg(ap, char*)) == 0)
          s = "(null)";
        for(; *s; s++)
          putc(fd, *s);
      } else if(c0 == '%'){
 5d4:	02500713          	li	a4,37
 5d8:	04e79563          	bne	a5,a4,622 <vprintf+0xfa>
        putc(fd, '%');
 5dc:	02500593          	li	a1,37
 5e0:	855a                	mv	a0,s6
 5e2:	e8dff0ef          	jal	46e <putc>
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 5e6:	4981                	li	s3,0
 5e8:	b769                	j	572 <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 10, 1);
 5ea:	008b8913          	addi	s2,s7,8
 5ee:	4685                	li	a3,1
 5f0:	4629                	li	a2,10
 5f2:	000ba583          	lw	a1,0(s7)
 5f6:	855a                	mv	a0,s6
 5f8:	e95ff0ef          	jal	48c <printint>
 5fc:	8bca                	mv	s7,s2
      state = 0;
 5fe:	4981                	li	s3,0
 600:	bf8d                	j	572 <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'd'){
 602:	06400793          	li	a5,100
 606:	02f68963          	beq	a3,a5,638 <vprintf+0x110>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 60a:	06c00793          	li	a5,108
 60e:	04f68263          	beq	a3,a5,652 <vprintf+0x12a>
      } else if(c0 == 'l' && c1 == 'u'){
 612:	07500793          	li	a5,117
 616:	0af68063          	beq	a3,a5,6b6 <vprintf+0x18e>
      } else if(c0 == 'l' && c1 == 'x'){
 61a:	07800793          	li	a5,120
 61e:	0ef68263          	beq	a3,a5,702 <vprintf+0x1da>
        putc(fd, '%');
 622:	02500593          	li	a1,37
 626:	855a                	mv	a0,s6
 628:	e47ff0ef          	jal	46e <putc>
        putc(fd, c0);
 62c:	85ca                	mv	a1,s2
 62e:	855a                	mv	a0,s6
 630:	e3fff0ef          	jal	46e <putc>
      state = 0;
 634:	4981                	li	s3,0
 636:	bf35                	j	572 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 638:	008b8913          	addi	s2,s7,8
 63c:	4685                	li	a3,1
 63e:	4629                	li	a2,10
 640:	000bb583          	ld	a1,0(s7)
 644:	855a                	mv	a0,s6
 646:	e47ff0ef          	jal	48c <printint>
        i += 1;
 64a:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 64c:	8bca                	mv	s7,s2
      state = 0;
 64e:	4981                	li	s3,0
        i += 1;
 650:	b70d                	j	572 <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 652:	06400793          	li	a5,100
 656:	02f60763          	beq	a2,a5,684 <vprintf+0x15c>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 65a:	07500793          	li	a5,117
 65e:	06f60963          	beq	a2,a5,6d0 <vprintf+0x1a8>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 662:	07800793          	li	a5,120
 666:	faf61ee3          	bne	a2,a5,622 <vprintf+0xfa>
        printint(fd, va_arg(ap, uint64), 16, 0);
 66a:	008b8913          	addi	s2,s7,8
 66e:	4681                	li	a3,0
 670:	4641                	li	a2,16
 672:	000bb583          	ld	a1,0(s7)
 676:	855a                	mv	a0,s6
 678:	e15ff0ef          	jal	48c <printint>
        i += 2;
 67c:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 67e:	8bca                	mv	s7,s2
      state = 0;
 680:	4981                	li	s3,0
        i += 2;
 682:	bdc5                	j	572 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 684:	008b8913          	addi	s2,s7,8
 688:	4685                	li	a3,1
 68a:	4629                	li	a2,10
 68c:	000bb583          	ld	a1,0(s7)
 690:	855a                	mv	a0,s6
 692:	dfbff0ef          	jal	48c <printint>
        i += 2;
 696:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 698:	8bca                	mv	s7,s2
      state = 0;
 69a:	4981                	li	s3,0
        i += 2;
 69c:	bdd9                	j	572 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint32), 10, 0);
 69e:	008b8913          	addi	s2,s7,8
 6a2:	4681                	li	a3,0
 6a4:	4629                	li	a2,10
 6a6:	000be583          	lwu	a1,0(s7)
 6aa:	855a                	mv	a0,s6
 6ac:	de1ff0ef          	jal	48c <printint>
 6b0:	8bca                	mv	s7,s2
      state = 0;
 6b2:	4981                	li	s3,0
 6b4:	bd7d                	j	572 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 6b6:	008b8913          	addi	s2,s7,8
 6ba:	4681                	li	a3,0
 6bc:	4629                	li	a2,10
 6be:	000bb583          	ld	a1,0(s7)
 6c2:	855a                	mv	a0,s6
 6c4:	dc9ff0ef          	jal	48c <printint>
        i += 1;
 6c8:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 6ca:	8bca                	mv	s7,s2
      state = 0;
 6cc:	4981                	li	s3,0
        i += 1;
 6ce:	b555                	j	572 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 6d0:	008b8913          	addi	s2,s7,8
 6d4:	4681                	li	a3,0
 6d6:	4629                	li	a2,10
 6d8:	000bb583          	ld	a1,0(s7)
 6dc:	855a                	mv	a0,s6
 6de:	dafff0ef          	jal	48c <printint>
        i += 2;
 6e2:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 6e4:	8bca                	mv	s7,s2
      state = 0;
 6e6:	4981                	li	s3,0
        i += 2;
 6e8:	b569                	j	572 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint32), 16, 0);
 6ea:	008b8913          	addi	s2,s7,8
 6ee:	4681                	li	a3,0
 6f0:	4641                	li	a2,16
 6f2:	000be583          	lwu	a1,0(s7)
 6f6:	855a                	mv	a0,s6
 6f8:	d95ff0ef          	jal	48c <printint>
 6fc:	8bca                	mv	s7,s2
      state = 0;
 6fe:	4981                	li	s3,0
 700:	bd8d                	j	572 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 16, 0);
 702:	008b8913          	addi	s2,s7,8
 706:	4681                	li	a3,0
 708:	4641                	li	a2,16
 70a:	000bb583          	ld	a1,0(s7)
 70e:	855a                	mv	a0,s6
 710:	d7dff0ef          	jal	48c <printint>
        i += 1;
 714:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 716:	8bca                	mv	s7,s2
      state = 0;
 718:	4981                	li	s3,0
        i += 1;
 71a:	bda1                	j	572 <vprintf+0x4a>
 71c:	e06a                	sd	s10,0(sp)
        printptr(fd, va_arg(ap, uint64));
 71e:	008b8d13          	addi	s10,s7,8
 722:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 726:	03000593          	li	a1,48
 72a:	855a                	mv	a0,s6
 72c:	d43ff0ef          	jal	46e <putc>
  putc(fd, 'x');
 730:	07800593          	li	a1,120
 734:	855a                	mv	a0,s6
 736:	d39ff0ef          	jal	46e <putc>
 73a:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 73c:	00000b97          	auipc	s7,0x0
 740:	3a4b8b93          	addi	s7,s7,932 # ae0 <digits>
 744:	03c9d793          	srli	a5,s3,0x3c
 748:	97de                	add	a5,a5,s7
 74a:	0007c583          	lbu	a1,0(a5)
 74e:	855a                	mv	a0,s6
 750:	d1fff0ef          	jal	46e <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 754:	0992                	slli	s3,s3,0x4
 756:	397d                	addiw	s2,s2,-1
 758:	fe0916e3          	bnez	s2,744 <vprintf+0x21c>
        printptr(fd, va_arg(ap, uint64));
 75c:	8bea                	mv	s7,s10
      state = 0;
 75e:	4981                	li	s3,0
 760:	6d02                	ld	s10,0(sp)
 762:	bd01                	j	572 <vprintf+0x4a>
        putc(fd, va_arg(ap, uint32));
 764:	008b8913          	addi	s2,s7,8
 768:	000bc583          	lbu	a1,0(s7)
 76c:	855a                	mv	a0,s6
 76e:	d01ff0ef          	jal	46e <putc>
 772:	8bca                	mv	s7,s2
      state = 0;
 774:	4981                	li	s3,0
 776:	bbf5                	j	572 <vprintf+0x4a>
        if((s = va_arg(ap, char*)) == 0)
 778:	008b8993          	addi	s3,s7,8
 77c:	000bb903          	ld	s2,0(s7)
 780:	00090f63          	beqz	s2,79e <vprintf+0x276>
        for(; *s; s++)
 784:	00094583          	lbu	a1,0(s2)
 788:	c195                	beqz	a1,7ac <vprintf+0x284>
          putc(fd, *s);
 78a:	855a                	mv	a0,s6
 78c:	ce3ff0ef          	jal	46e <putc>
        for(; *s; s++)
 790:	0905                	addi	s2,s2,1
 792:	00094583          	lbu	a1,0(s2)
 796:	f9f5                	bnez	a1,78a <vprintf+0x262>
        if((s = va_arg(ap, char*)) == 0)
 798:	8bce                	mv	s7,s3
      state = 0;
 79a:	4981                	li	s3,0
 79c:	bbd9                	j	572 <vprintf+0x4a>
          s = "(null)";
 79e:	00000917          	auipc	s2,0x0
 7a2:	33a90913          	addi	s2,s2,826 # ad8 <malloc+0x22e>
        for(; *s; s++)
 7a6:	02800593          	li	a1,40
 7aa:	b7c5                	j	78a <vprintf+0x262>
        if((s = va_arg(ap, char*)) == 0)
 7ac:	8bce                	mv	s7,s3
      state = 0;
 7ae:	4981                	li	s3,0
 7b0:	b3c9                	j	572 <vprintf+0x4a>
 7b2:	64a6                	ld	s1,72(sp)
 7b4:	79e2                	ld	s3,56(sp)
 7b6:	7a42                	ld	s4,48(sp)
 7b8:	7aa2                	ld	s5,40(sp)
 7ba:	7b02                	ld	s6,32(sp)
 7bc:	6be2                	ld	s7,24(sp)
 7be:	6c42                	ld	s8,16(sp)
 7c0:	6ca2                	ld	s9,8(sp)
    }
  }
}
 7c2:	60e6                	ld	ra,88(sp)
 7c4:	6446                	ld	s0,80(sp)
 7c6:	6906                	ld	s2,64(sp)
 7c8:	6125                	addi	sp,sp,96
 7ca:	8082                	ret

00000000000007cc <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 7cc:	715d                	addi	sp,sp,-80
 7ce:	ec06                	sd	ra,24(sp)
 7d0:	e822                	sd	s0,16(sp)
 7d2:	1000                	addi	s0,sp,32
 7d4:	e010                	sd	a2,0(s0)
 7d6:	e414                	sd	a3,8(s0)
 7d8:	e818                	sd	a4,16(s0)
 7da:	ec1c                	sd	a5,24(s0)
 7dc:	03043023          	sd	a6,32(s0)
 7e0:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 7e4:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 7e8:	8622                	mv	a2,s0
 7ea:	d3fff0ef          	jal	528 <vprintf>
}
 7ee:	60e2                	ld	ra,24(sp)
 7f0:	6442                	ld	s0,16(sp)
 7f2:	6161                	addi	sp,sp,80
 7f4:	8082                	ret

00000000000007f6 <printf>:

void
printf(const char *fmt, ...)
{
 7f6:	711d                	addi	sp,sp,-96
 7f8:	ec06                	sd	ra,24(sp)
 7fa:	e822                	sd	s0,16(sp)
 7fc:	1000                	addi	s0,sp,32
 7fe:	e40c                	sd	a1,8(s0)
 800:	e810                	sd	a2,16(s0)
 802:	ec14                	sd	a3,24(s0)
 804:	f018                	sd	a4,32(s0)
 806:	f41c                	sd	a5,40(s0)
 808:	03043823          	sd	a6,48(s0)
 80c:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 810:	00840613          	addi	a2,s0,8
 814:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 818:	85aa                	mv	a1,a0
 81a:	4505                	li	a0,1
 81c:	d0dff0ef          	jal	528 <vprintf>
}
 820:	60e2                	ld	ra,24(sp)
 822:	6442                	ld	s0,16(sp)
 824:	6125                	addi	sp,sp,96
 826:	8082                	ret

0000000000000828 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 828:	1141                	addi	sp,sp,-16
 82a:	e422                	sd	s0,8(sp)
 82c:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 82e:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 832:	00000797          	auipc	a5,0x0
 836:	7ce7b783          	ld	a5,1998(a5) # 1000 <freep>
 83a:	a02d                	j	864 <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 83c:	4618                	lw	a4,8(a2)
 83e:	9f2d                	addw	a4,a4,a1
 840:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 844:	6398                	ld	a4,0(a5)
 846:	6310                	ld	a2,0(a4)
 848:	a83d                	j	886 <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 84a:	ff852703          	lw	a4,-8(a0)
 84e:	9f31                	addw	a4,a4,a2
 850:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 852:	ff053683          	ld	a3,-16(a0)
 856:	a091                	j	89a <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 858:	6398                	ld	a4,0(a5)
 85a:	00e7e463          	bltu	a5,a4,862 <free+0x3a>
 85e:	00e6ea63          	bltu	a3,a4,872 <free+0x4a>
{
 862:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 864:	fed7fae3          	bgeu	a5,a3,858 <free+0x30>
 868:	6398                	ld	a4,0(a5)
 86a:	00e6e463          	bltu	a3,a4,872 <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 86e:	fee7eae3          	bltu	a5,a4,862 <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 872:	ff852583          	lw	a1,-8(a0)
 876:	6390                	ld	a2,0(a5)
 878:	02059813          	slli	a6,a1,0x20
 87c:	01c85713          	srli	a4,a6,0x1c
 880:	9736                	add	a4,a4,a3
 882:	fae60de3          	beq	a2,a4,83c <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 886:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 88a:	4790                	lw	a2,8(a5)
 88c:	02061593          	slli	a1,a2,0x20
 890:	01c5d713          	srli	a4,a1,0x1c
 894:	973e                	add	a4,a4,a5
 896:	fae68ae3          	beq	a3,a4,84a <free+0x22>
    p->s.ptr = bp->s.ptr;
 89a:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 89c:	00000717          	auipc	a4,0x0
 8a0:	76f73223          	sd	a5,1892(a4) # 1000 <freep>
}
 8a4:	6422                	ld	s0,8(sp)
 8a6:	0141                	addi	sp,sp,16
 8a8:	8082                	ret

00000000000008aa <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 8aa:	7139                	addi	sp,sp,-64
 8ac:	fc06                	sd	ra,56(sp)
 8ae:	f822                	sd	s0,48(sp)
 8b0:	f426                	sd	s1,40(sp)
 8b2:	ec4e                	sd	s3,24(sp)
 8b4:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 8b6:	02051493          	slli	s1,a0,0x20
 8ba:	9081                	srli	s1,s1,0x20
 8bc:	04bd                	addi	s1,s1,15
 8be:	8091                	srli	s1,s1,0x4
 8c0:	0014899b          	addiw	s3,s1,1
 8c4:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 8c6:	00000517          	auipc	a0,0x0
 8ca:	73a53503          	ld	a0,1850(a0) # 1000 <freep>
 8ce:	c915                	beqz	a0,902 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8d0:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 8d2:	4798                	lw	a4,8(a5)
 8d4:	08977a63          	bgeu	a4,s1,968 <malloc+0xbe>
 8d8:	f04a                	sd	s2,32(sp)
 8da:	e852                	sd	s4,16(sp)
 8dc:	e456                	sd	s5,8(sp)
 8de:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 8e0:	8a4e                	mv	s4,s3
 8e2:	0009871b          	sext.w	a4,s3
 8e6:	6685                	lui	a3,0x1
 8e8:	00d77363          	bgeu	a4,a3,8ee <malloc+0x44>
 8ec:	6a05                	lui	s4,0x1
 8ee:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 8f2:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 8f6:	00000917          	auipc	s2,0x0
 8fa:	70a90913          	addi	s2,s2,1802 # 1000 <freep>
  if(p == SBRK_ERROR)
 8fe:	5afd                	li	s5,-1
 900:	a081                	j	940 <malloc+0x96>
 902:	f04a                	sd	s2,32(sp)
 904:	e852                	sd	s4,16(sp)
 906:	e456                	sd	s5,8(sp)
 908:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 90a:	00000797          	auipc	a5,0x0
 90e:	70678793          	addi	a5,a5,1798 # 1010 <base>
 912:	00000717          	auipc	a4,0x0
 916:	6ef73723          	sd	a5,1774(a4) # 1000 <freep>
 91a:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 91c:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 920:	b7c1                	j	8e0 <malloc+0x36>
        prevp->s.ptr = p->s.ptr;
 922:	6398                	ld	a4,0(a5)
 924:	e118                	sd	a4,0(a0)
 926:	a8a9                	j	980 <malloc+0xd6>
  hp->s.size = nu;
 928:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 92c:	0541                	addi	a0,a0,16
 92e:	efbff0ef          	jal	828 <free>
  return freep;
 932:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 936:	c12d                	beqz	a0,998 <malloc+0xee>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 938:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 93a:	4798                	lw	a4,8(a5)
 93c:	02977263          	bgeu	a4,s1,960 <malloc+0xb6>
    if(p == freep)
 940:	00093703          	ld	a4,0(s2)
 944:	853e                	mv	a0,a5
 946:	fef719e3          	bne	a4,a5,938 <malloc+0x8e>
  p = sbrk(nu * sizeof(Header));
 94a:	8552                	mv	a0,s4
 94c:	a1fff0ef          	jal	36a <sbrk>
  if(p == SBRK_ERROR)
 950:	fd551ce3          	bne	a0,s5,928 <malloc+0x7e>
        return 0;
 954:	4501                	li	a0,0
 956:	7902                	ld	s2,32(sp)
 958:	6a42                	ld	s4,16(sp)
 95a:	6aa2                	ld	s5,8(sp)
 95c:	6b02                	ld	s6,0(sp)
 95e:	a03d                	j	98c <malloc+0xe2>
 960:	7902                	ld	s2,32(sp)
 962:	6a42                	ld	s4,16(sp)
 964:	6aa2                	ld	s5,8(sp)
 966:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 968:	fae48de3          	beq	s1,a4,922 <malloc+0x78>
        p->s.size -= nunits;
 96c:	4137073b          	subw	a4,a4,s3
 970:	c798                	sw	a4,8(a5)
        p += p->s.size;
 972:	02071693          	slli	a3,a4,0x20
 976:	01c6d713          	srli	a4,a3,0x1c
 97a:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 97c:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 980:	00000717          	auipc	a4,0x0
 984:	68a73023          	sd	a0,1664(a4) # 1000 <freep>
      return (void*)(p + 1);
 988:	01078513          	addi	a0,a5,16
  }
}
 98c:	70e2                	ld	ra,56(sp)
 98e:	7442                	ld	s0,48(sp)
 990:	74a2                	ld	s1,40(sp)
 992:	69e2                	ld	s3,24(sp)
 994:	6121                	addi	sp,sp,64
 996:	8082                	ret
 998:	7902                	ld	s2,32(sp)
 99a:	6a42                	ld	s4,16(sp)
 99c:	6aa2                	ld	s5,8(sp)
 99e:	6b02                	ld	s6,0(sp)
 9a0:	b7f5                	j	98c <malloc+0xe2>
