
user/_ls:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <fmtname>:
#include "kernel/fs.h"
#include "kernel/fcntl.h"

char*
fmtname(char *path)
{
   0:	7179                	addi	sp,sp,-48
   2:	f406                	sd	ra,40(sp)
   4:	f022                	sd	s0,32(sp)
   6:	ec26                	sd	s1,24(sp)
   8:	1800                	addi	s0,sp,48
   a:	84aa                	mv	s1,a0
  static char buf[DIRSIZ+1];
  char *p;

  // Find first character after last slash.
  for(p=path+strlen(path); p >= path && *p != '/'; p--)
   c:	2b8000ef          	jal	2c4 <strlen>
  10:	02051793          	slli	a5,a0,0x20
  14:	9381                	srli	a5,a5,0x20
  16:	97a6                	add	a5,a5,s1
  18:	02f00693          	li	a3,47
  1c:	0097e963          	bltu	a5,s1,2e <fmtname+0x2e>
  20:	0007c703          	lbu	a4,0(a5)
  24:	00d70563          	beq	a4,a3,2e <fmtname+0x2e>
  28:	17fd                	addi	a5,a5,-1
  2a:	fe97fbe3          	bgeu	a5,s1,20 <fmtname+0x20>
    ;
  p++;
  2e:	00178493          	addi	s1,a5,1

  // Return blank-padded name.
  if(strlen(p) >= DIRSIZ)
  32:	8526                	mv	a0,s1
  34:	290000ef          	jal	2c4 <strlen>
  38:	2501                	sext.w	a0,a0
  3a:	47b5                	li	a5,13
  3c:	00a7f863          	bgeu	a5,a0,4c <fmtname+0x4c>
    return p;
  memmove(buf, p, strlen(p));
  memset(buf+strlen(p), ' ', DIRSIZ-strlen(p));
  buf[sizeof(buf)-1] = '\0';
  return buf;
}
  40:	8526                	mv	a0,s1
  42:	70a2                	ld	ra,40(sp)
  44:	7402                	ld	s0,32(sp)
  46:	64e2                	ld	s1,24(sp)
  48:	6145                	addi	sp,sp,48
  4a:	8082                	ret
  4c:	e84a                	sd	s2,16(sp)
  4e:	e44e                	sd	s3,8(sp)
  memmove(buf, p, strlen(p));
  50:	8526                	mv	a0,s1
  52:	272000ef          	jal	2c4 <strlen>
  56:	00001997          	auipc	s3,0x1
  5a:	fba98993          	addi	s3,s3,-70 # 1010 <buf.0>
  5e:	0005061b          	sext.w	a2,a0
  62:	85a6                	mv	a1,s1
  64:	854e                	mv	a0,s3
  66:	3c0000ef          	jal	426 <memmove>
  memset(buf+strlen(p), ' ', DIRSIZ-strlen(p));
  6a:	8526                	mv	a0,s1
  6c:	258000ef          	jal	2c4 <strlen>
  70:	0005091b          	sext.w	s2,a0
  74:	8526                	mv	a0,s1
  76:	24e000ef          	jal	2c4 <strlen>
  7a:	1902                	slli	s2,s2,0x20
  7c:	02095913          	srli	s2,s2,0x20
  80:	4639                	li	a2,14
  82:	9e09                	subw	a2,a2,a0
  84:	02000593          	li	a1,32
  88:	01298533          	add	a0,s3,s2
  8c:	262000ef          	jal	2ee <memset>
  buf[sizeof(buf)-1] = '\0';
  90:	00098723          	sb	zero,14(s3)
  return buf;
  94:	84ce                	mv	s1,s3
  96:	6942                	ld	s2,16(sp)
  98:	69a2                	ld	s3,8(sp)
  9a:	b75d                	j	40 <fmtname+0x40>

000000000000009c <ls>:

void
ls(char *path)
{
  9c:	d9010113          	addi	sp,sp,-624
  a0:	26113423          	sd	ra,616(sp)
  a4:	26813023          	sd	s0,608(sp)
  a8:	25213823          	sd	s2,592(sp)
  ac:	1c80                	addi	s0,sp,624
  ae:	892a                	mv	s2,a0
  char buf[512], *p;
  int fd;
  struct dirent de;
  struct stat st;

  if((fd = open(path, O_RDONLY)) < 0){
  b0:	4581                	li	a1,0
  b2:	4cc000ef          	jal	57e <open>
  b6:	06054363          	bltz	a0,11c <ls+0x80>
  ba:	24913c23          	sd	s1,600(sp)
  be:	84aa                	mv	s1,a0
    fprintf(2, "ls: cannot open %s\n", path);
    return;
  }

  if(fstat(fd, &st) < 0){
  c0:	d9840593          	addi	a1,s0,-616
  c4:	4d2000ef          	jal	596 <fstat>
  c8:	06054363          	bltz	a0,12e <ls+0x92>
    fprintf(2, "ls: cannot stat %s\n", path);
    close(fd);
    return;
  }

  switch(st.type){
  cc:	da041783          	lh	a5,-608(s0)
  d0:	4705                	li	a4,1
  d2:	06e78c63          	beq	a5,a4,14a <ls+0xae>
  d6:	37f9                	addiw	a5,a5,-2
  d8:	17c2                	slli	a5,a5,0x30
  da:	93c1                	srli	a5,a5,0x30
  dc:	02f76263          	bltu	a4,a5,100 <ls+0x64>
  case T_DEVICE:
  case T_FILE:
    printf("%s %d %d %d\n", fmtname(path), st.type, st.ino, (int) st.size);
  e0:	854a                	mv	a0,s2
  e2:	f1fff0ef          	jal	0 <fmtname>
  e6:	85aa                	mv	a1,a0
  e8:	da842703          	lw	a4,-600(s0)
  ec:	d9c42683          	lw	a3,-612(s0)
  f0:	da041603          	lh	a2,-608(s0)
  f4:	00001517          	auipc	a0,0x1
  f8:	a7c50513          	addi	a0,a0,-1412 # b70 <malloc+0x136>
  fc:	08b000ef          	jal	986 <printf>
      }
      printf("%s %d %d %d\n", fmtname(buf), st.type, st.ino, (int) st.size);
    }
    break;
  }
  close(fd);
 100:	8526                	mv	a0,s1
 102:	464000ef          	jal	566 <close>
 106:	25813483          	ld	s1,600(sp)
}
 10a:	26813083          	ld	ra,616(sp)
 10e:	26013403          	ld	s0,608(sp)
 112:	25013903          	ld	s2,592(sp)
 116:	27010113          	addi	sp,sp,624
 11a:	8082                	ret
    fprintf(2, "ls: cannot open %s\n", path);
 11c:	864a                	mv	a2,s2
 11e:	00001597          	auipc	a1,0x1
 122:	a2258593          	addi	a1,a1,-1502 # b40 <malloc+0x106>
 126:	4509                	li	a0,2
 128:	035000ef          	jal	95c <fprintf>
    return;
 12c:	bff9                	j	10a <ls+0x6e>
    fprintf(2, "ls: cannot stat %s\n", path);
 12e:	864a                	mv	a2,s2
 130:	00001597          	auipc	a1,0x1
 134:	a2858593          	addi	a1,a1,-1496 # b58 <malloc+0x11e>
 138:	4509                	li	a0,2
 13a:	023000ef          	jal	95c <fprintf>
    close(fd);
 13e:	8526                	mv	a0,s1
 140:	426000ef          	jal	566 <close>
    return;
 144:	25813483          	ld	s1,600(sp)
 148:	b7c9                	j	10a <ls+0x6e>
    if(strlen(path) + 1 + DIRSIZ + 1 > sizeof buf){
 14a:	854a                	mv	a0,s2
 14c:	178000ef          	jal	2c4 <strlen>
 150:	2541                	addiw	a0,a0,16
 152:	20000793          	li	a5,512
 156:	00a7f963          	bgeu	a5,a0,168 <ls+0xcc>
      printf("ls: path too long\n");
 15a:	00001517          	auipc	a0,0x1
 15e:	a2650513          	addi	a0,a0,-1498 # b80 <malloc+0x146>
 162:	025000ef          	jal	986 <printf>
      break;
 166:	bf69                	j	100 <ls+0x64>
 168:	25313423          	sd	s3,584(sp)
 16c:	25413023          	sd	s4,576(sp)
 170:	23513c23          	sd	s5,568(sp)
    strcpy(buf, path);
 174:	85ca                	mv	a1,s2
 176:	dc040513          	addi	a0,s0,-576
 17a:	102000ef          	jal	27c <strcpy>
    p = buf+strlen(buf);
 17e:	dc040513          	addi	a0,s0,-576
 182:	142000ef          	jal	2c4 <strlen>
 186:	1502                	slli	a0,a0,0x20
 188:	9101                	srli	a0,a0,0x20
 18a:	dc040793          	addi	a5,s0,-576
 18e:	00a78933          	add	s2,a5,a0
    *p++ = '/';
 192:	00190993          	addi	s3,s2,1
 196:	02f00793          	li	a5,47
 19a:	00f90023          	sb	a5,0(s2)
      printf("%s %d %d %d\n", fmtname(buf), st.type, st.ino, (int) st.size);
 19e:	00001a17          	auipc	s4,0x1
 1a2:	9d2a0a13          	addi	s4,s4,-1582 # b70 <malloc+0x136>
        printf("ls: cannot stat %s\n", buf);
 1a6:	00001a97          	auipc	s5,0x1
 1aa:	9b2a8a93          	addi	s5,s5,-1614 # b58 <malloc+0x11e>
    while(read(fd, &de, sizeof(de)) == sizeof(de)){
 1ae:	a031                	j	1ba <ls+0x11e>
        printf("ls: cannot stat %s\n", buf);
 1b0:	dc040593          	addi	a1,s0,-576
 1b4:	8556                	mv	a0,s5
 1b6:	7d0000ef          	jal	986 <printf>
    while(read(fd, &de, sizeof(de)) == sizeof(de)){
 1ba:	4641                	li	a2,16
 1bc:	db040593          	addi	a1,s0,-592
 1c0:	8526                	mv	a0,s1
 1c2:	394000ef          	jal	556 <read>
 1c6:	47c1                	li	a5,16
 1c8:	04f51463          	bne	a0,a5,210 <ls+0x174>
      if(de.inum == 0)
 1cc:	db045783          	lhu	a5,-592(s0)
 1d0:	d7ed                	beqz	a5,1ba <ls+0x11e>
      memmove(p, de.name, DIRSIZ);
 1d2:	4639                	li	a2,14
 1d4:	db240593          	addi	a1,s0,-590
 1d8:	854e                	mv	a0,s3
 1da:	24c000ef          	jal	426 <memmove>
      p[DIRSIZ] = 0;
 1de:	000907a3          	sb	zero,15(s2)
      if(stat(buf, &st) < 0){
 1e2:	d9840593          	addi	a1,s0,-616
 1e6:	dc040513          	addi	a0,s0,-576
 1ea:	1ba000ef          	jal	3a4 <stat>
 1ee:	fc0541e3          	bltz	a0,1b0 <ls+0x114>
      printf("%s %d %d %d\n", fmtname(buf), st.type, st.ino, (int) st.size);
 1f2:	dc040513          	addi	a0,s0,-576
 1f6:	e0bff0ef          	jal	0 <fmtname>
 1fa:	85aa                	mv	a1,a0
 1fc:	da842703          	lw	a4,-600(s0)
 200:	d9c42683          	lw	a3,-612(s0)
 204:	da041603          	lh	a2,-608(s0)
 208:	8552                	mv	a0,s4
 20a:	77c000ef          	jal	986 <printf>
 20e:	b775                	j	1ba <ls+0x11e>
 210:	24813983          	ld	s3,584(sp)
 214:	24013a03          	ld	s4,576(sp)
 218:	23813a83          	ld	s5,568(sp)
 21c:	b5d5                	j	100 <ls+0x64>

000000000000021e <main>:

int
main(int argc, char *argv[])
{
 21e:	1101                	addi	sp,sp,-32
 220:	ec06                	sd	ra,24(sp)
 222:	e822                	sd	s0,16(sp)
 224:	1000                	addi	s0,sp,32
  int i;

  if(argc < 2){
 226:	4785                	li	a5,1
 228:	02a7d763          	bge	a5,a0,256 <main+0x38>
 22c:	e426                	sd	s1,8(sp)
 22e:	e04a                	sd	s2,0(sp)
 230:	00858493          	addi	s1,a1,8
 234:	ffe5091b          	addiw	s2,a0,-2
 238:	02091793          	slli	a5,s2,0x20
 23c:	01d7d913          	srli	s2,a5,0x1d
 240:	05c1                	addi	a1,a1,16
 242:	992e                	add	s2,s2,a1
    ls(".");
    exit(0);
  }
  for(i=1; i<argc; i++)
    ls(argv[i]);
 244:	6088                	ld	a0,0(s1)
 246:	e57ff0ef          	jal	9c <ls>
  for(i=1; i<argc; i++)
 24a:	04a1                	addi	s1,s1,8
 24c:	ff249ce3          	bne	s1,s2,244 <main+0x26>
  exit(0);
 250:	4501                	li	a0,0
 252:	2ec000ef          	jal	53e <exit>
 256:	e426                	sd	s1,8(sp)
 258:	e04a                	sd	s2,0(sp)
    ls(".");
 25a:	00001517          	auipc	a0,0x1
 25e:	93e50513          	addi	a0,a0,-1730 # b98 <malloc+0x15e>
 262:	e3bff0ef          	jal	9c <ls>
    exit(0);
 266:	4501                	li	a0,0
 268:	2d6000ef          	jal	53e <exit>

000000000000026c <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start(int argc, char **argv)
{
 26c:	1141                	addi	sp,sp,-16
 26e:	e406                	sd	ra,8(sp)
 270:	e022                	sd	s0,0(sp)
 272:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
 274:	fabff0ef          	jal	21e <main>
  exit(r);
 278:	2c6000ef          	jal	53e <exit>

000000000000027c <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 27c:	1141                	addi	sp,sp,-16
 27e:	e422                	sd	s0,8(sp)
 280:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 282:	87aa                	mv	a5,a0
 284:	0585                	addi	a1,a1,1
 286:	0785                	addi	a5,a5,1
 288:	fff5c703          	lbu	a4,-1(a1)
 28c:	fee78fa3          	sb	a4,-1(a5)
 290:	fb75                	bnez	a4,284 <strcpy+0x8>
    ;
  return os;
}
 292:	6422                	ld	s0,8(sp)
 294:	0141                	addi	sp,sp,16
 296:	8082                	ret

0000000000000298 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 298:	1141                	addi	sp,sp,-16
 29a:	e422                	sd	s0,8(sp)
 29c:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 29e:	00054783          	lbu	a5,0(a0)
 2a2:	cb91                	beqz	a5,2b6 <strcmp+0x1e>
 2a4:	0005c703          	lbu	a4,0(a1)
 2a8:	00f71763          	bne	a4,a5,2b6 <strcmp+0x1e>
    p++, q++;
 2ac:	0505                	addi	a0,a0,1
 2ae:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 2b0:	00054783          	lbu	a5,0(a0)
 2b4:	fbe5                	bnez	a5,2a4 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 2b6:	0005c503          	lbu	a0,0(a1)
}
 2ba:	40a7853b          	subw	a0,a5,a0
 2be:	6422                	ld	s0,8(sp)
 2c0:	0141                	addi	sp,sp,16
 2c2:	8082                	ret

00000000000002c4 <strlen>:

uint
strlen(const char *s)
{
 2c4:	1141                	addi	sp,sp,-16
 2c6:	e422                	sd	s0,8(sp)
 2c8:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 2ca:	00054783          	lbu	a5,0(a0)
 2ce:	cf91                	beqz	a5,2ea <strlen+0x26>
 2d0:	0505                	addi	a0,a0,1
 2d2:	87aa                	mv	a5,a0
 2d4:	86be                	mv	a3,a5
 2d6:	0785                	addi	a5,a5,1
 2d8:	fff7c703          	lbu	a4,-1(a5)
 2dc:	ff65                	bnez	a4,2d4 <strlen+0x10>
 2de:	40a6853b          	subw	a0,a3,a0
 2e2:	2505                	addiw	a0,a0,1
    ;
  return n;
}
 2e4:	6422                	ld	s0,8(sp)
 2e6:	0141                	addi	sp,sp,16
 2e8:	8082                	ret
  for(n = 0; s[n]; n++)
 2ea:	4501                	li	a0,0
 2ec:	bfe5                	j	2e4 <strlen+0x20>

00000000000002ee <memset>:

void*
memset(void *dst, int c, uint n)
{
 2ee:	1141                	addi	sp,sp,-16
 2f0:	e422                	sd	s0,8(sp)
 2f2:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 2f4:	ca19                	beqz	a2,30a <memset+0x1c>
 2f6:	87aa                	mv	a5,a0
 2f8:	1602                	slli	a2,a2,0x20
 2fa:	9201                	srli	a2,a2,0x20
 2fc:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 300:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 304:	0785                	addi	a5,a5,1
 306:	fee79de3          	bne	a5,a4,300 <memset+0x12>
  }
  return dst;
}
 30a:	6422                	ld	s0,8(sp)
 30c:	0141                	addi	sp,sp,16
 30e:	8082                	ret

0000000000000310 <strchr>:

char*
strchr(const char *s, char c)
{
 310:	1141                	addi	sp,sp,-16
 312:	e422                	sd	s0,8(sp)
 314:	0800                	addi	s0,sp,16
  for(; *s; s++)
 316:	00054783          	lbu	a5,0(a0)
 31a:	cb99                	beqz	a5,330 <strchr+0x20>
    if(*s == c)
 31c:	00f58763          	beq	a1,a5,32a <strchr+0x1a>
  for(; *s; s++)
 320:	0505                	addi	a0,a0,1
 322:	00054783          	lbu	a5,0(a0)
 326:	fbfd                	bnez	a5,31c <strchr+0xc>
      return (char*)s;
  return 0;
 328:	4501                	li	a0,0
}
 32a:	6422                	ld	s0,8(sp)
 32c:	0141                	addi	sp,sp,16
 32e:	8082                	ret
  return 0;
 330:	4501                	li	a0,0
 332:	bfe5                	j	32a <strchr+0x1a>

0000000000000334 <gets>:

char*
gets(char *buf, int max)
{
 334:	711d                	addi	sp,sp,-96
 336:	ec86                	sd	ra,88(sp)
 338:	e8a2                	sd	s0,80(sp)
 33a:	e4a6                	sd	s1,72(sp)
 33c:	e0ca                	sd	s2,64(sp)
 33e:	fc4e                	sd	s3,56(sp)
 340:	f852                	sd	s4,48(sp)
 342:	f456                	sd	s5,40(sp)
 344:	f05a                	sd	s6,32(sp)
 346:	ec5e                	sd	s7,24(sp)
 348:	1080                	addi	s0,sp,96
 34a:	8baa                	mv	s7,a0
 34c:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 34e:	892a                	mv	s2,a0
 350:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 352:	4aa9                	li	s5,10
 354:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 356:	89a6                	mv	s3,s1
 358:	2485                	addiw	s1,s1,1
 35a:	0344d663          	bge	s1,s4,386 <gets+0x52>
    cc = read(0, &c, 1);
 35e:	4605                	li	a2,1
 360:	faf40593          	addi	a1,s0,-81
 364:	4501                	li	a0,0
 366:	1f0000ef          	jal	556 <read>
    if(cc < 1)
 36a:	00a05e63          	blez	a0,386 <gets+0x52>
    buf[i++] = c;
 36e:	faf44783          	lbu	a5,-81(s0)
 372:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 376:	01578763          	beq	a5,s5,384 <gets+0x50>
 37a:	0905                	addi	s2,s2,1
 37c:	fd679de3          	bne	a5,s6,356 <gets+0x22>
    buf[i++] = c;
 380:	89a6                	mv	s3,s1
 382:	a011                	j	386 <gets+0x52>
 384:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 386:	99de                	add	s3,s3,s7
 388:	00098023          	sb	zero,0(s3)
  return buf;
}
 38c:	855e                	mv	a0,s7
 38e:	60e6                	ld	ra,88(sp)
 390:	6446                	ld	s0,80(sp)
 392:	64a6                	ld	s1,72(sp)
 394:	6906                	ld	s2,64(sp)
 396:	79e2                	ld	s3,56(sp)
 398:	7a42                	ld	s4,48(sp)
 39a:	7aa2                	ld	s5,40(sp)
 39c:	7b02                	ld	s6,32(sp)
 39e:	6be2                	ld	s7,24(sp)
 3a0:	6125                	addi	sp,sp,96
 3a2:	8082                	ret

00000000000003a4 <stat>:

int
stat(const char *n, struct stat *st)
{
 3a4:	1101                	addi	sp,sp,-32
 3a6:	ec06                	sd	ra,24(sp)
 3a8:	e822                	sd	s0,16(sp)
 3aa:	e04a                	sd	s2,0(sp)
 3ac:	1000                	addi	s0,sp,32
 3ae:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 3b0:	4581                	li	a1,0
 3b2:	1cc000ef          	jal	57e <open>
  if(fd < 0)
 3b6:	02054263          	bltz	a0,3da <stat+0x36>
 3ba:	e426                	sd	s1,8(sp)
 3bc:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 3be:	85ca                	mv	a1,s2
 3c0:	1d6000ef          	jal	596 <fstat>
 3c4:	892a                	mv	s2,a0
  close(fd);
 3c6:	8526                	mv	a0,s1
 3c8:	19e000ef          	jal	566 <close>
  return r;
 3cc:	64a2                	ld	s1,8(sp)
}
 3ce:	854a                	mv	a0,s2
 3d0:	60e2                	ld	ra,24(sp)
 3d2:	6442                	ld	s0,16(sp)
 3d4:	6902                	ld	s2,0(sp)
 3d6:	6105                	addi	sp,sp,32
 3d8:	8082                	ret
    return -1;
 3da:	597d                	li	s2,-1
 3dc:	bfcd                	j	3ce <stat+0x2a>

00000000000003de <atoi>:

int
atoi(const char *s)
{
 3de:	1141                	addi	sp,sp,-16
 3e0:	e422                	sd	s0,8(sp)
 3e2:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 3e4:	00054683          	lbu	a3,0(a0)
 3e8:	fd06879b          	addiw	a5,a3,-48
 3ec:	0ff7f793          	zext.b	a5,a5
 3f0:	4625                	li	a2,9
 3f2:	02f66863          	bltu	a2,a5,422 <atoi+0x44>
 3f6:	872a                	mv	a4,a0
  n = 0;
 3f8:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 3fa:	0705                	addi	a4,a4,1
 3fc:	0025179b          	slliw	a5,a0,0x2
 400:	9fa9                	addw	a5,a5,a0
 402:	0017979b          	slliw	a5,a5,0x1
 406:	9fb5                	addw	a5,a5,a3
 408:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 40c:	00074683          	lbu	a3,0(a4)
 410:	fd06879b          	addiw	a5,a3,-48
 414:	0ff7f793          	zext.b	a5,a5
 418:	fef671e3          	bgeu	a2,a5,3fa <atoi+0x1c>
  return n;
}
 41c:	6422                	ld	s0,8(sp)
 41e:	0141                	addi	sp,sp,16
 420:	8082                	ret
  n = 0;
 422:	4501                	li	a0,0
 424:	bfe5                	j	41c <atoi+0x3e>

0000000000000426 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 426:	1141                	addi	sp,sp,-16
 428:	e422                	sd	s0,8(sp)
 42a:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 42c:	02b57463          	bgeu	a0,a1,454 <memmove+0x2e>
    while(n-- > 0)
 430:	00c05f63          	blez	a2,44e <memmove+0x28>
 434:	1602                	slli	a2,a2,0x20
 436:	9201                	srli	a2,a2,0x20
 438:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 43c:	872a                	mv	a4,a0
      *dst++ = *src++;
 43e:	0585                	addi	a1,a1,1
 440:	0705                	addi	a4,a4,1
 442:	fff5c683          	lbu	a3,-1(a1)
 446:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 44a:	fef71ae3          	bne	a4,a5,43e <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 44e:	6422                	ld	s0,8(sp)
 450:	0141                	addi	sp,sp,16
 452:	8082                	ret
    dst += n;
 454:	00c50733          	add	a4,a0,a2
    src += n;
 458:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 45a:	fec05ae3          	blez	a2,44e <memmove+0x28>
 45e:	fff6079b          	addiw	a5,a2,-1
 462:	1782                	slli	a5,a5,0x20
 464:	9381                	srli	a5,a5,0x20
 466:	fff7c793          	not	a5,a5
 46a:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 46c:	15fd                	addi	a1,a1,-1
 46e:	177d                	addi	a4,a4,-1
 470:	0005c683          	lbu	a3,0(a1)
 474:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 478:	fee79ae3          	bne	a5,a4,46c <memmove+0x46>
 47c:	bfc9                	j	44e <memmove+0x28>

000000000000047e <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 47e:	1141                	addi	sp,sp,-16
 480:	e422                	sd	s0,8(sp)
 482:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 484:	ca05                	beqz	a2,4b4 <memcmp+0x36>
 486:	fff6069b          	addiw	a3,a2,-1
 48a:	1682                	slli	a3,a3,0x20
 48c:	9281                	srli	a3,a3,0x20
 48e:	0685                	addi	a3,a3,1
 490:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 492:	00054783          	lbu	a5,0(a0)
 496:	0005c703          	lbu	a4,0(a1)
 49a:	00e79863          	bne	a5,a4,4aa <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 49e:	0505                	addi	a0,a0,1
    p2++;
 4a0:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 4a2:	fed518e3          	bne	a0,a3,492 <memcmp+0x14>
  }
  return 0;
 4a6:	4501                	li	a0,0
 4a8:	a019                	j	4ae <memcmp+0x30>
      return *p1 - *p2;
 4aa:	40e7853b          	subw	a0,a5,a4
}
 4ae:	6422                	ld	s0,8(sp)
 4b0:	0141                	addi	sp,sp,16
 4b2:	8082                	ret
  return 0;
 4b4:	4501                	li	a0,0
 4b6:	bfe5                	j	4ae <memcmp+0x30>

00000000000004b8 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 4b8:	1141                	addi	sp,sp,-16
 4ba:	e406                	sd	ra,8(sp)
 4bc:	e022                	sd	s0,0(sp)
 4be:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 4c0:	f67ff0ef          	jal	426 <memmove>
}
 4c4:	60a2                	ld	ra,8(sp)
 4c6:	6402                	ld	s0,0(sp)
 4c8:	0141                	addi	sp,sp,16
 4ca:	8082                	ret

00000000000004cc <sbrk>:

char *
sbrk(int n) {
 4cc:	1141                	addi	sp,sp,-16
 4ce:	e406                	sd	ra,8(sp)
 4d0:	e022                	sd	s0,0(sp)
 4d2:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
 4d4:	4585                	li	a1,1
 4d6:	0f0000ef          	jal	5c6 <sys_sbrk>
}
 4da:	60a2                	ld	ra,8(sp)
 4dc:	6402                	ld	s0,0(sp)
 4de:	0141                	addi	sp,sp,16
 4e0:	8082                	ret

00000000000004e2 <sbrklazy>:

char *
sbrklazy(int n) {
 4e2:	1141                	addi	sp,sp,-16
 4e4:	e406                	sd	ra,8(sp)
 4e6:	e022                	sd	s0,0(sp)
 4e8:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
 4ea:	4589                	li	a1,2
 4ec:	0da000ef          	jal	5c6 <sys_sbrk>
}
 4f0:	60a2                	ld	ra,8(sp)
 4f2:	6402                	ld	s0,0(sp)
 4f4:	0141                	addi	sp,sp,16
 4f6:	8082                	ret

00000000000004f8 <getcpuinfo>:

int
getcpuinfo(struct cpu_info *cpus, int ncpu)
{
 4f8:	1141                	addi	sp,sp,-16
 4fa:	e406                	sd	ra,8(sp)
 4fc:	e022                	sd	s0,0(sp)
 4fe:	0800                	addi	s0,sp,16
  // Stub: return 0 CPUs for now
  // In a full implementation, this would fetch CPU state from kernel
  memset(cpus, 0, ncpu * sizeof(struct cpu_info));
 500:	0025961b          	slliw	a2,a1,0x2
 504:	9e2d                	addw	a2,a2,a1
 506:	0036161b          	slliw	a2,a2,0x3
 50a:	4581                	li	a1,0
 50c:	de3ff0ef          	jal	2ee <memset>
  return 0;
}
 510:	4501                	li	a0,0
 512:	60a2                	ld	ra,8(sp)
 514:	6402                	ld	s0,0(sp)
 516:	0141                	addi	sp,sp,16
 518:	8082                	ret

000000000000051a <getprocstats>:

int
getprocstats(struct proc_stats *stats)
{
 51a:	1141                	addi	sp,sp,-16
 51c:	e406                	sd	ra,8(sp)
 51e:	e022                	sd	s0,0(sp)
 520:	0800                	addi	s0,sp,16
  // Stub: return zeros for now
  // In a full implementation, this would fetch process statistics from kernel
  memset(stats, 0, sizeof(struct proc_stats));
 522:	07000613          	li	a2,112
 526:	4581                	li	a1,0
 528:	dc7ff0ef          	jal	2ee <memset>
  return 0;
}
 52c:	4501                	li	a0,0
 52e:	60a2                	ld	ra,8(sp)
 530:	6402                	ld	s0,0(sp)
 532:	0141                	addi	sp,sp,16
 534:	8082                	ret

0000000000000536 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 536:	4885                	li	a7,1
 ecall
 538:	00000073          	ecall
 ret
 53c:	8082                	ret

000000000000053e <exit>:
.global exit
exit:
 li a7, SYS_exit
 53e:	4889                	li	a7,2
 ecall
 540:	00000073          	ecall
 ret
 544:	8082                	ret

0000000000000546 <wait>:
.global wait
wait:
 li a7, SYS_wait
 546:	488d                	li	a7,3
 ecall
 548:	00000073          	ecall
 ret
 54c:	8082                	ret

000000000000054e <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 54e:	4891                	li	a7,4
 ecall
 550:	00000073          	ecall
 ret
 554:	8082                	ret

0000000000000556 <read>:
.global read
read:
 li a7, SYS_read
 556:	4895                	li	a7,5
 ecall
 558:	00000073          	ecall
 ret
 55c:	8082                	ret

000000000000055e <write>:
.global write
write:
 li a7, SYS_write
 55e:	48c1                	li	a7,16
 ecall
 560:	00000073          	ecall
 ret
 564:	8082                	ret

0000000000000566 <close>:
.global close
close:
 li a7, SYS_close
 566:	48d5                	li	a7,21
 ecall
 568:	00000073          	ecall
 ret
 56c:	8082                	ret

000000000000056e <kill>:
.global kill
kill:
 li a7, SYS_kill
 56e:	4899                	li	a7,6
 ecall
 570:	00000073          	ecall
 ret
 574:	8082                	ret

0000000000000576 <exec>:
.global exec
exec:
 li a7, SYS_exec
 576:	489d                	li	a7,7
 ecall
 578:	00000073          	ecall
 ret
 57c:	8082                	ret

000000000000057e <open>:
.global open
open:
 li a7, SYS_open
 57e:	48bd                	li	a7,15
 ecall
 580:	00000073          	ecall
 ret
 584:	8082                	ret

0000000000000586 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 586:	48c5                	li	a7,17
 ecall
 588:	00000073          	ecall
 ret
 58c:	8082                	ret

000000000000058e <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 58e:	48c9                	li	a7,18
 ecall
 590:	00000073          	ecall
 ret
 594:	8082                	ret

0000000000000596 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 596:	48a1                	li	a7,8
 ecall
 598:	00000073          	ecall
 ret
 59c:	8082                	ret

000000000000059e <link>:
.global link
link:
 li a7, SYS_link
 59e:	48cd                	li	a7,19
 ecall
 5a0:	00000073          	ecall
 ret
 5a4:	8082                	ret

00000000000005a6 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 5a6:	48d1                	li	a7,20
 ecall
 5a8:	00000073          	ecall
 ret
 5ac:	8082                	ret

00000000000005ae <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 5ae:	48a5                	li	a7,9
 ecall
 5b0:	00000073          	ecall
 ret
 5b4:	8082                	ret

00000000000005b6 <dup>:
.global dup
dup:
 li a7, SYS_dup
 5b6:	48a9                	li	a7,10
 ecall
 5b8:	00000073          	ecall
 ret
 5bc:	8082                	ret

00000000000005be <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 5be:	48ad                	li	a7,11
 ecall
 5c0:	00000073          	ecall
 ret
 5c4:	8082                	ret

00000000000005c6 <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
 5c6:	48b1                	li	a7,12
 ecall
 5c8:	00000073          	ecall
 ret
 5cc:	8082                	ret

00000000000005ce <pause>:
.global pause
pause:
 li a7, SYS_pause
 5ce:	48b5                	li	a7,13
 ecall
 5d0:	00000073          	ecall
 ret
 5d4:	8082                	ret

00000000000005d6 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 5d6:	48b9                	li	a7,14
 ecall
 5d8:	00000073          	ecall
 ret
 5dc:	8082                	ret

00000000000005de <csread>:
.global csread
csread:
 li a7, SYS_csread
 5de:	48d9                	li	a7,22
 ecall
 5e0:	00000073          	ecall
 ret
 5e4:	8082                	ret

00000000000005e6 <fsread>:
.global fsread
fsread:
 li a7, SYS_fsread
 5e6:	48dd                	li	a7,23
 ecall
 5e8:	00000073          	ecall
 ret
 5ec:	8082                	ret

00000000000005ee <schedread>:
.global schedread
schedread:
 li a7, SYS_schedread
 5ee:	48e1                	li	a7,24
 ecall
 5f0:	00000073          	ecall
 ret
 5f4:	8082                	ret

00000000000005f6 <memread>:
.global memread
memread:
 li a7, SYS_memread
 5f6:	48e5                	li	a7,25
 ecall
 5f8:	00000073          	ecall
 ret
 5fc:	8082                	ret

00000000000005fe <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 5fe:	1101                	addi	sp,sp,-32
 600:	ec06                	sd	ra,24(sp)
 602:	e822                	sd	s0,16(sp)
 604:	1000                	addi	s0,sp,32
 606:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 60a:	4605                	li	a2,1
 60c:	fef40593          	addi	a1,s0,-17
 610:	f4fff0ef          	jal	55e <write>
}
 614:	60e2                	ld	ra,24(sp)
 616:	6442                	ld	s0,16(sp)
 618:	6105                	addi	sp,sp,32
 61a:	8082                	ret

000000000000061c <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
 61c:	715d                	addi	sp,sp,-80
 61e:	e486                	sd	ra,72(sp)
 620:	e0a2                	sd	s0,64(sp)
 622:	f84a                	sd	s2,48(sp)
 624:	0880                	addi	s0,sp,80
 626:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
 628:	c299                	beqz	a3,62e <printint+0x12>
 62a:	0805c363          	bltz	a1,6b0 <printint+0x94>
  neg = 0;
 62e:	4881                	li	a7,0
 630:	fb840693          	addi	a3,s0,-72
    x = -xx;
  } else {
    x = xx;
  }

  i = 0;
 634:	4781                	li	a5,0
  do{
    buf[i++] = digits[x % base];
 636:	00000517          	auipc	a0,0x0
 63a:	57250513          	addi	a0,a0,1394 # ba8 <digits>
 63e:	883e                	mv	a6,a5
 640:	2785                	addiw	a5,a5,1
 642:	02c5f733          	remu	a4,a1,a2
 646:	972a                	add	a4,a4,a0
 648:	00074703          	lbu	a4,0(a4)
 64c:	00e68023          	sb	a4,0(a3)
  }while((x /= base) != 0);
 650:	872e                	mv	a4,a1
 652:	02c5d5b3          	divu	a1,a1,a2
 656:	0685                	addi	a3,a3,1
 658:	fec773e3          	bgeu	a4,a2,63e <printint+0x22>
  if(neg)
 65c:	00088b63          	beqz	a7,672 <printint+0x56>
    buf[i++] = '-';
 660:	fd078793          	addi	a5,a5,-48
 664:	97a2                	add	a5,a5,s0
 666:	02d00713          	li	a4,45
 66a:	fee78423          	sb	a4,-24(a5)
 66e:	0028079b          	addiw	a5,a6,2

  while(--i >= 0)
 672:	02f05a63          	blez	a5,6a6 <printint+0x8a>
 676:	fc26                	sd	s1,56(sp)
 678:	f44e                	sd	s3,40(sp)
 67a:	fb840713          	addi	a4,s0,-72
 67e:	00f704b3          	add	s1,a4,a5
 682:	fff70993          	addi	s3,a4,-1
 686:	99be                	add	s3,s3,a5
 688:	37fd                	addiw	a5,a5,-1
 68a:	1782                	slli	a5,a5,0x20
 68c:	9381                	srli	a5,a5,0x20
 68e:	40f989b3          	sub	s3,s3,a5
    putc(fd, buf[i]);
 692:	fff4c583          	lbu	a1,-1(s1)
 696:	854a                	mv	a0,s2
 698:	f67ff0ef          	jal	5fe <putc>
  while(--i >= 0)
 69c:	14fd                	addi	s1,s1,-1
 69e:	ff349ae3          	bne	s1,s3,692 <printint+0x76>
 6a2:	74e2                	ld	s1,56(sp)
 6a4:	79a2                	ld	s3,40(sp)
}
 6a6:	60a6                	ld	ra,72(sp)
 6a8:	6406                	ld	s0,64(sp)
 6aa:	7942                	ld	s2,48(sp)
 6ac:	6161                	addi	sp,sp,80
 6ae:	8082                	ret
    x = -xx;
 6b0:	40b005b3          	neg	a1,a1
    neg = 1;
 6b4:	4885                	li	a7,1
    x = -xx;
 6b6:	bfad                	j	630 <printint+0x14>

00000000000006b8 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 6b8:	711d                	addi	sp,sp,-96
 6ba:	ec86                	sd	ra,88(sp)
 6bc:	e8a2                	sd	s0,80(sp)
 6be:	e0ca                	sd	s2,64(sp)
 6c0:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 6c2:	0005c903          	lbu	s2,0(a1)
 6c6:	28090663          	beqz	s2,952 <vprintf+0x29a>
 6ca:	e4a6                	sd	s1,72(sp)
 6cc:	fc4e                	sd	s3,56(sp)
 6ce:	f852                	sd	s4,48(sp)
 6d0:	f456                	sd	s5,40(sp)
 6d2:	f05a                	sd	s6,32(sp)
 6d4:	ec5e                	sd	s7,24(sp)
 6d6:	e862                	sd	s8,16(sp)
 6d8:	e466                	sd	s9,8(sp)
 6da:	8b2a                	mv	s6,a0
 6dc:	8a2e                	mv	s4,a1
 6de:	8bb2                	mv	s7,a2
  state = 0;
 6e0:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 6e2:	4481                	li	s1,0
 6e4:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 6e6:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 6ea:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 6ee:	06c00c93          	li	s9,108
 6f2:	a005                	j	712 <vprintf+0x5a>
        putc(fd, c0);
 6f4:	85ca                	mv	a1,s2
 6f6:	855a                	mv	a0,s6
 6f8:	f07ff0ef          	jal	5fe <putc>
 6fc:	a019                	j	702 <vprintf+0x4a>
    } else if(state == '%'){
 6fe:	03598263          	beq	s3,s5,722 <vprintf+0x6a>
  for(i = 0; fmt[i]; i++){
 702:	2485                	addiw	s1,s1,1
 704:	8726                	mv	a4,s1
 706:	009a07b3          	add	a5,s4,s1
 70a:	0007c903          	lbu	s2,0(a5)
 70e:	22090a63          	beqz	s2,942 <vprintf+0x28a>
    c0 = fmt[i] & 0xff;
 712:	0009079b          	sext.w	a5,s2
    if(state == 0){
 716:	fe0994e3          	bnez	s3,6fe <vprintf+0x46>
      if(c0 == '%'){
 71a:	fd579de3          	bne	a5,s5,6f4 <vprintf+0x3c>
        state = '%';
 71e:	89be                	mv	s3,a5
 720:	b7cd                	j	702 <vprintf+0x4a>
      if(c0) c1 = fmt[i+1] & 0xff;
 722:	00ea06b3          	add	a3,s4,a4
 726:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
 72a:	8636                	mv	a2,a3
      if(c1) c2 = fmt[i+2] & 0xff;
 72c:	c681                	beqz	a3,734 <vprintf+0x7c>
 72e:	9752                	add	a4,a4,s4
 730:	00274603          	lbu	a2,2(a4)
      if(c0 == 'd'){
 734:	05878363          	beq	a5,s8,77a <vprintf+0xc2>
      } else if(c0 == 'l' && c1 == 'd'){
 738:	05978d63          	beq	a5,s9,792 <vprintf+0xda>
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if(c0 == 'u'){
 73c:	07500713          	li	a4,117
 740:	0ee78763          	beq	a5,a4,82e <vprintf+0x176>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if(c0 == 'x'){
 744:	07800713          	li	a4,120
 748:	12e78963          	beq	a5,a4,87a <vprintf+0x1c2>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if(c0 == 'p'){
 74c:	07000713          	li	a4,112
 750:	14e78e63          	beq	a5,a4,8ac <vprintf+0x1f4>
        printptr(fd, va_arg(ap, uint64));
      } else if(c0 == 'c'){
 754:	06300713          	li	a4,99
 758:	18e78e63          	beq	a5,a4,8f4 <vprintf+0x23c>
        putc(fd, va_arg(ap, uint32));
      } else if(c0 == 's'){
 75c:	07300713          	li	a4,115
 760:	1ae78463          	beq	a5,a4,908 <vprintf+0x250>
        if((s = va_arg(ap, char*)) == 0)
          s = "(null)";
        for(; *s; s++)
          putc(fd, *s);
      } else if(c0 == '%'){
 764:	02500713          	li	a4,37
 768:	04e79563          	bne	a5,a4,7b2 <vprintf+0xfa>
        putc(fd, '%');
 76c:	02500593          	li	a1,37
 770:	855a                	mv	a0,s6
 772:	e8dff0ef          	jal	5fe <putc>
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
 776:	4981                	li	s3,0
 778:	b769                	j	702 <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 10, 1);
 77a:	008b8913          	addi	s2,s7,8
 77e:	4685                	li	a3,1
 780:	4629                	li	a2,10
 782:	000ba583          	lw	a1,0(s7)
 786:	855a                	mv	a0,s6
 788:	e95ff0ef          	jal	61c <printint>
 78c:	8bca                	mv	s7,s2
      state = 0;
 78e:	4981                	li	s3,0
 790:	bf8d                	j	702 <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'd'){
 792:	06400793          	li	a5,100
 796:	02f68963          	beq	a3,a5,7c8 <vprintf+0x110>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 79a:	06c00793          	li	a5,108
 79e:	04f68263          	beq	a3,a5,7e2 <vprintf+0x12a>
      } else if(c0 == 'l' && c1 == 'u'){
 7a2:	07500793          	li	a5,117
 7a6:	0af68063          	beq	a3,a5,846 <vprintf+0x18e>
      } else if(c0 == 'l' && c1 == 'x'){
 7aa:	07800793          	li	a5,120
 7ae:	0ef68263          	beq	a3,a5,892 <vprintf+0x1da>
        putc(fd, '%');
 7b2:	02500593          	li	a1,37
 7b6:	855a                	mv	a0,s6
 7b8:	e47ff0ef          	jal	5fe <putc>
        putc(fd, c0);
 7bc:	85ca                	mv	a1,s2
 7be:	855a                	mv	a0,s6
 7c0:	e3fff0ef          	jal	5fe <putc>
      state = 0;
 7c4:	4981                	li	s3,0
 7c6:	bf35                	j	702 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 7c8:	008b8913          	addi	s2,s7,8
 7cc:	4685                	li	a3,1
 7ce:	4629                	li	a2,10
 7d0:	000bb583          	ld	a1,0(s7)
 7d4:	855a                	mv	a0,s6
 7d6:	e47ff0ef          	jal	61c <printint>
        i += 1;
 7da:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 7dc:	8bca                	mv	s7,s2
      state = 0;
 7de:	4981                	li	s3,0
        i += 1;
 7e0:	b70d                	j	702 <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 7e2:	06400793          	li	a5,100
 7e6:	02f60763          	beq	a2,a5,814 <vprintf+0x15c>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 7ea:	07500793          	li	a5,117
 7ee:	06f60963          	beq	a2,a5,860 <vprintf+0x1a8>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 7f2:	07800793          	li	a5,120
 7f6:	faf61ee3          	bne	a2,a5,7b2 <vprintf+0xfa>
        printint(fd, va_arg(ap, uint64), 16, 0);
 7fa:	008b8913          	addi	s2,s7,8
 7fe:	4681                	li	a3,0
 800:	4641                	li	a2,16
 802:	000bb583          	ld	a1,0(s7)
 806:	855a                	mv	a0,s6
 808:	e15ff0ef          	jal	61c <printint>
        i += 2;
 80c:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 80e:	8bca                	mv	s7,s2
      state = 0;
 810:	4981                	li	s3,0
        i += 2;
 812:	bdc5                	j	702 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 814:	008b8913          	addi	s2,s7,8
 818:	4685                	li	a3,1
 81a:	4629                	li	a2,10
 81c:	000bb583          	ld	a1,0(s7)
 820:	855a                	mv	a0,s6
 822:	dfbff0ef          	jal	61c <printint>
        i += 2;
 826:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 828:	8bca                	mv	s7,s2
      state = 0;
 82a:	4981                	li	s3,0
        i += 2;
 82c:	bdd9                	j	702 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint32), 10, 0);
 82e:	008b8913          	addi	s2,s7,8
 832:	4681                	li	a3,0
 834:	4629                	li	a2,10
 836:	000be583          	lwu	a1,0(s7)
 83a:	855a                	mv	a0,s6
 83c:	de1ff0ef          	jal	61c <printint>
 840:	8bca                	mv	s7,s2
      state = 0;
 842:	4981                	li	s3,0
 844:	bd7d                	j	702 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 846:	008b8913          	addi	s2,s7,8
 84a:	4681                	li	a3,0
 84c:	4629                	li	a2,10
 84e:	000bb583          	ld	a1,0(s7)
 852:	855a                	mv	a0,s6
 854:	dc9ff0ef          	jal	61c <printint>
        i += 1;
 858:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 85a:	8bca                	mv	s7,s2
      state = 0;
 85c:	4981                	li	s3,0
        i += 1;
 85e:	b555                	j	702 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 860:	008b8913          	addi	s2,s7,8
 864:	4681                	li	a3,0
 866:	4629                	li	a2,10
 868:	000bb583          	ld	a1,0(s7)
 86c:	855a                	mv	a0,s6
 86e:	dafff0ef          	jal	61c <printint>
        i += 2;
 872:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 874:	8bca                	mv	s7,s2
      state = 0;
 876:	4981                	li	s3,0
        i += 2;
 878:	b569                	j	702 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint32), 16, 0);
 87a:	008b8913          	addi	s2,s7,8
 87e:	4681                	li	a3,0
 880:	4641                	li	a2,16
 882:	000be583          	lwu	a1,0(s7)
 886:	855a                	mv	a0,s6
 888:	d95ff0ef          	jal	61c <printint>
 88c:	8bca                	mv	s7,s2
      state = 0;
 88e:	4981                	li	s3,0
 890:	bd8d                	j	702 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 16, 0);
 892:	008b8913          	addi	s2,s7,8
 896:	4681                	li	a3,0
 898:	4641                	li	a2,16
 89a:	000bb583          	ld	a1,0(s7)
 89e:	855a                	mv	a0,s6
 8a0:	d7dff0ef          	jal	61c <printint>
        i += 1;
 8a4:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 8a6:	8bca                	mv	s7,s2
      state = 0;
 8a8:	4981                	li	s3,0
        i += 1;
 8aa:	bda1                	j	702 <vprintf+0x4a>
 8ac:	e06a                	sd	s10,0(sp)
        printptr(fd, va_arg(ap, uint64));
 8ae:	008b8d13          	addi	s10,s7,8
 8b2:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 8b6:	03000593          	li	a1,48
 8ba:	855a                	mv	a0,s6
 8bc:	d43ff0ef          	jal	5fe <putc>
  putc(fd, 'x');
 8c0:	07800593          	li	a1,120
 8c4:	855a                	mv	a0,s6
 8c6:	d39ff0ef          	jal	5fe <putc>
 8ca:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 8cc:	00000b97          	auipc	s7,0x0
 8d0:	2dcb8b93          	addi	s7,s7,732 # ba8 <digits>
 8d4:	03c9d793          	srli	a5,s3,0x3c
 8d8:	97de                	add	a5,a5,s7
 8da:	0007c583          	lbu	a1,0(a5)
 8de:	855a                	mv	a0,s6
 8e0:	d1fff0ef          	jal	5fe <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 8e4:	0992                	slli	s3,s3,0x4
 8e6:	397d                	addiw	s2,s2,-1
 8e8:	fe0916e3          	bnez	s2,8d4 <vprintf+0x21c>
        printptr(fd, va_arg(ap, uint64));
 8ec:	8bea                	mv	s7,s10
      state = 0;
 8ee:	4981                	li	s3,0
 8f0:	6d02                	ld	s10,0(sp)
 8f2:	bd01                	j	702 <vprintf+0x4a>
        putc(fd, va_arg(ap, uint32));
 8f4:	008b8913          	addi	s2,s7,8
 8f8:	000bc583          	lbu	a1,0(s7)
 8fc:	855a                	mv	a0,s6
 8fe:	d01ff0ef          	jal	5fe <putc>
 902:	8bca                	mv	s7,s2
      state = 0;
 904:	4981                	li	s3,0
 906:	bbf5                	j	702 <vprintf+0x4a>
        if((s = va_arg(ap, char*)) == 0)
 908:	008b8993          	addi	s3,s7,8
 90c:	000bb903          	ld	s2,0(s7)
 910:	00090f63          	beqz	s2,92e <vprintf+0x276>
        for(; *s; s++)
 914:	00094583          	lbu	a1,0(s2)
 918:	c195                	beqz	a1,93c <vprintf+0x284>
          putc(fd, *s);
 91a:	855a                	mv	a0,s6
 91c:	ce3ff0ef          	jal	5fe <putc>
        for(; *s; s++)
 920:	0905                	addi	s2,s2,1
 922:	00094583          	lbu	a1,0(s2)
 926:	f9f5                	bnez	a1,91a <vprintf+0x262>
        if((s = va_arg(ap, char*)) == 0)
 928:	8bce                	mv	s7,s3
      state = 0;
 92a:	4981                	li	s3,0
 92c:	bbd9                	j	702 <vprintf+0x4a>
          s = "(null)";
 92e:	00000917          	auipc	s2,0x0
 932:	27290913          	addi	s2,s2,626 # ba0 <malloc+0x166>
        for(; *s; s++)
 936:	02800593          	li	a1,40
 93a:	b7c5                	j	91a <vprintf+0x262>
        if((s = va_arg(ap, char*)) == 0)
 93c:	8bce                	mv	s7,s3
      state = 0;
 93e:	4981                	li	s3,0
 940:	b3c9                	j	702 <vprintf+0x4a>
 942:	64a6                	ld	s1,72(sp)
 944:	79e2                	ld	s3,56(sp)
 946:	7a42                	ld	s4,48(sp)
 948:	7aa2                	ld	s5,40(sp)
 94a:	7b02                	ld	s6,32(sp)
 94c:	6be2                	ld	s7,24(sp)
 94e:	6c42                	ld	s8,16(sp)
 950:	6ca2                	ld	s9,8(sp)
    }
  }
}
 952:	60e6                	ld	ra,88(sp)
 954:	6446                	ld	s0,80(sp)
 956:	6906                	ld	s2,64(sp)
 958:	6125                	addi	sp,sp,96
 95a:	8082                	ret

000000000000095c <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 95c:	715d                	addi	sp,sp,-80
 95e:	ec06                	sd	ra,24(sp)
 960:	e822                	sd	s0,16(sp)
 962:	1000                	addi	s0,sp,32
 964:	e010                	sd	a2,0(s0)
 966:	e414                	sd	a3,8(s0)
 968:	e818                	sd	a4,16(s0)
 96a:	ec1c                	sd	a5,24(s0)
 96c:	03043023          	sd	a6,32(s0)
 970:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 974:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 978:	8622                	mv	a2,s0
 97a:	d3fff0ef          	jal	6b8 <vprintf>
}
 97e:	60e2                	ld	ra,24(sp)
 980:	6442                	ld	s0,16(sp)
 982:	6161                	addi	sp,sp,80
 984:	8082                	ret

0000000000000986 <printf>:

void
printf(const char *fmt, ...)
{
 986:	711d                	addi	sp,sp,-96
 988:	ec06                	sd	ra,24(sp)
 98a:	e822                	sd	s0,16(sp)
 98c:	1000                	addi	s0,sp,32
 98e:	e40c                	sd	a1,8(s0)
 990:	e810                	sd	a2,16(s0)
 992:	ec14                	sd	a3,24(s0)
 994:	f018                	sd	a4,32(s0)
 996:	f41c                	sd	a5,40(s0)
 998:	03043823          	sd	a6,48(s0)
 99c:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 9a0:	00840613          	addi	a2,s0,8
 9a4:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 9a8:	85aa                	mv	a1,a0
 9aa:	4505                	li	a0,1
 9ac:	d0dff0ef          	jal	6b8 <vprintf>
}
 9b0:	60e2                	ld	ra,24(sp)
 9b2:	6442                	ld	s0,16(sp)
 9b4:	6125                	addi	sp,sp,96
 9b6:	8082                	ret

00000000000009b8 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 9b8:	1141                	addi	sp,sp,-16
 9ba:	e422                	sd	s0,8(sp)
 9bc:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 9be:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 9c2:	00000797          	auipc	a5,0x0
 9c6:	63e7b783          	ld	a5,1598(a5) # 1000 <freep>
 9ca:	a02d                	j	9f4 <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 9cc:	4618                	lw	a4,8(a2)
 9ce:	9f2d                	addw	a4,a4,a1
 9d0:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 9d4:	6398                	ld	a4,0(a5)
 9d6:	6310                	ld	a2,0(a4)
 9d8:	a83d                	j	a16 <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 9da:	ff852703          	lw	a4,-8(a0)
 9de:	9f31                	addw	a4,a4,a2
 9e0:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 9e2:	ff053683          	ld	a3,-16(a0)
 9e6:	a091                	j	a2a <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 9e8:	6398                	ld	a4,0(a5)
 9ea:	00e7e463          	bltu	a5,a4,9f2 <free+0x3a>
 9ee:	00e6ea63          	bltu	a3,a4,a02 <free+0x4a>
{
 9f2:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 9f4:	fed7fae3          	bgeu	a5,a3,9e8 <free+0x30>
 9f8:	6398                	ld	a4,0(a5)
 9fa:	00e6e463          	bltu	a3,a4,a02 <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 9fe:	fee7eae3          	bltu	a5,a4,9f2 <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 a02:	ff852583          	lw	a1,-8(a0)
 a06:	6390                	ld	a2,0(a5)
 a08:	02059813          	slli	a6,a1,0x20
 a0c:	01c85713          	srli	a4,a6,0x1c
 a10:	9736                	add	a4,a4,a3
 a12:	fae60de3          	beq	a2,a4,9cc <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 a16:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 a1a:	4790                	lw	a2,8(a5)
 a1c:	02061593          	slli	a1,a2,0x20
 a20:	01c5d713          	srli	a4,a1,0x1c
 a24:	973e                	add	a4,a4,a5
 a26:	fae68ae3          	beq	a3,a4,9da <free+0x22>
    p->s.ptr = bp->s.ptr;
 a2a:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 a2c:	00000717          	auipc	a4,0x0
 a30:	5cf73a23          	sd	a5,1492(a4) # 1000 <freep>
}
 a34:	6422                	ld	s0,8(sp)
 a36:	0141                	addi	sp,sp,16
 a38:	8082                	ret

0000000000000a3a <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 a3a:	7139                	addi	sp,sp,-64
 a3c:	fc06                	sd	ra,56(sp)
 a3e:	f822                	sd	s0,48(sp)
 a40:	f426                	sd	s1,40(sp)
 a42:	ec4e                	sd	s3,24(sp)
 a44:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 a46:	02051493          	slli	s1,a0,0x20
 a4a:	9081                	srli	s1,s1,0x20
 a4c:	04bd                	addi	s1,s1,15
 a4e:	8091                	srli	s1,s1,0x4
 a50:	0014899b          	addiw	s3,s1,1
 a54:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 a56:	00000517          	auipc	a0,0x0
 a5a:	5aa53503          	ld	a0,1450(a0) # 1000 <freep>
 a5e:	c915                	beqz	a0,a92 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 a60:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 a62:	4798                	lw	a4,8(a5)
 a64:	08977a63          	bgeu	a4,s1,af8 <malloc+0xbe>
 a68:	f04a                	sd	s2,32(sp)
 a6a:	e852                	sd	s4,16(sp)
 a6c:	e456                	sd	s5,8(sp)
 a6e:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 a70:	8a4e                	mv	s4,s3
 a72:	0009871b          	sext.w	a4,s3
 a76:	6685                	lui	a3,0x1
 a78:	00d77363          	bgeu	a4,a3,a7e <malloc+0x44>
 a7c:	6a05                	lui	s4,0x1
 a7e:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 a82:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 a86:	00000917          	auipc	s2,0x0
 a8a:	57a90913          	addi	s2,s2,1402 # 1000 <freep>
  if(p == SBRK_ERROR)
 a8e:	5afd                	li	s5,-1
 a90:	a081                	j	ad0 <malloc+0x96>
 a92:	f04a                	sd	s2,32(sp)
 a94:	e852                	sd	s4,16(sp)
 a96:	e456                	sd	s5,8(sp)
 a98:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 a9a:	00000797          	auipc	a5,0x0
 a9e:	58678793          	addi	a5,a5,1414 # 1020 <base>
 aa2:	00000717          	auipc	a4,0x0
 aa6:	54f73f23          	sd	a5,1374(a4) # 1000 <freep>
 aaa:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 aac:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 ab0:	b7c1                	j	a70 <malloc+0x36>
        prevp->s.ptr = p->s.ptr;
 ab2:	6398                	ld	a4,0(a5)
 ab4:	e118                	sd	a4,0(a0)
 ab6:	a8a9                	j	b10 <malloc+0xd6>
  hp->s.size = nu;
 ab8:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 abc:	0541                	addi	a0,a0,16
 abe:	efbff0ef          	jal	9b8 <free>
  return freep;
 ac2:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 ac6:	c12d                	beqz	a0,b28 <malloc+0xee>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 ac8:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 aca:	4798                	lw	a4,8(a5)
 acc:	02977263          	bgeu	a4,s1,af0 <malloc+0xb6>
    if(p == freep)
 ad0:	00093703          	ld	a4,0(s2)
 ad4:	853e                	mv	a0,a5
 ad6:	fef719e3          	bne	a4,a5,ac8 <malloc+0x8e>
  p = sbrk(nu * sizeof(Header));
 ada:	8552                	mv	a0,s4
 adc:	9f1ff0ef          	jal	4cc <sbrk>
  if(p == SBRK_ERROR)
 ae0:	fd551ce3          	bne	a0,s5,ab8 <malloc+0x7e>
        return 0;
 ae4:	4501                	li	a0,0
 ae6:	7902                	ld	s2,32(sp)
 ae8:	6a42                	ld	s4,16(sp)
 aea:	6aa2                	ld	s5,8(sp)
 aec:	6b02                	ld	s6,0(sp)
 aee:	a03d                	j	b1c <malloc+0xe2>
 af0:	7902                	ld	s2,32(sp)
 af2:	6a42                	ld	s4,16(sp)
 af4:	6aa2                	ld	s5,8(sp)
 af6:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 af8:	fae48de3          	beq	s1,a4,ab2 <malloc+0x78>
        p->s.size -= nunits;
 afc:	4137073b          	subw	a4,a4,s3
 b00:	c798                	sw	a4,8(a5)
        p += p->s.size;
 b02:	02071693          	slli	a3,a4,0x20
 b06:	01c6d713          	srli	a4,a3,0x1c
 b0a:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 b0c:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 b10:	00000717          	auipc	a4,0x0
 b14:	4ea73823          	sd	a0,1264(a4) # 1000 <freep>
      return (void*)(p + 1);
 b18:	01078513          	addi	a0,a5,16
  }
}
 b1c:	70e2                	ld	ra,56(sp)
 b1e:	7442                	ld	s0,48(sp)
 b20:	74a2                	ld	s1,40(sp)
 b22:	69e2                	ld	s3,24(sp)
 b24:	6121                	addi	sp,sp,64
 b26:	8082                	ret
 b28:	7902                	ld	s2,32(sp)
 b2a:	6a42                	ld	s4,16(sp)
 b2c:	6aa2                	ld	s5,8(sp)
 b2e:	6b02                	ld	s6,0(sp)
 b30:	b7f5                	j	b1c <malloc+0xe2>
