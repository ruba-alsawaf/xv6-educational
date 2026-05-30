
user/_usertests:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <copyinstr1>:
}

// what if you pass ridiculous string pointers to system calls?
void
copyinstr1(char *s)
{
       0:	711d                	addi	sp,sp,-96
       2:	ec86                	sd	ra,88(sp)
       4:	e8a2                	sd	s0,80(sp)
       6:	e4a6                	sd	s1,72(sp)
       8:	e0ca                	sd	s2,64(sp)
       a:	fc4e                	sd	s3,56(sp)
       c:	1080                	addi	s0,sp,96
  uint64 addrs[] = { 0x80000000LL, 0x3fffffe000, 0x3ffffff000, 0x4000000000,
       e:	00008797          	auipc	a5,0x8
      12:	92278793          	addi	a5,a5,-1758 # 7930 <malloc+0x2682>
      16:	638c                	ld	a1,0(a5)
      18:	6790                	ld	a2,8(a5)
      1a:	6b94                	ld	a3,16(a5)
      1c:	6f98                	ld	a4,24(a5)
      1e:	739c                	ld	a5,32(a5)
      20:	fab43423          	sd	a1,-88(s0)
      24:	fac43823          	sd	a2,-80(s0)
      28:	fad43c23          	sd	a3,-72(s0)
      2c:	fce43023          	sd	a4,-64(s0)
      30:	fcf43423          	sd	a5,-56(s0)
                     0xffffffffffffffff };

  for(int ai = 0; ai < sizeof(addrs)/sizeof(addrs[0]); ai++){
      34:	fa840493          	addi	s1,s0,-88
      38:	fd040993          	addi	s3,s0,-48
    uint64 addr = addrs[ai];

    int fd = open((char *)addr, O_CREATE|O_WRONLY);
      3c:	0004b903          	ld	s2,0(s1)
      40:	20100593          	li	a1,513
      44:	854a                	mv	a0,s2
      46:	5ad040ef          	jal	4df2 <open>
    if(fd >= 0){
      4a:	00055c63          	bgez	a0,62 <copyinstr1+0x62>
  for(int ai = 0; ai < sizeof(addrs)/sizeof(addrs[0]); ai++){
      4e:	04a1                	addi	s1,s1,8
      50:	ff3496e3          	bne	s1,s3,3c <copyinstr1+0x3c>
      printf("open(%p) returned %d, not -1\n", (void*)addr, fd);
      exit(1);
    }
  }
}
      54:	60e6                	ld	ra,88(sp)
      56:	6446                	ld	s0,80(sp)
      58:	64a6                	ld	s1,72(sp)
      5a:	6906                	ld	s2,64(sp)
      5c:	79e2                	ld	s3,56(sp)
      5e:	6125                	addi	sp,sp,96
      60:	8082                	ret
      printf("open(%p) returned %d, not -1\n", (void*)addr, fd);
      62:	862a                	mv	a2,a0
      64:	85ca                	mv	a1,s2
      66:	00005517          	auipc	a0,0x5
      6a:	34a50513          	addi	a0,a0,842 # 53b0 <malloc+0x102>
      6e:	18c050ef          	jal	51fa <printf>
      exit(1);
      72:	4505                	li	a0,1
      74:	53f040ef          	jal	4db2 <exit>

0000000000000078 <bsstest>:
void
bsstest(char *s)
{
  int i;

  for(i = 0; i < sizeof(uninit); i++){
      78:	00009797          	auipc	a5,0x9
      7c:	53078793          	addi	a5,a5,1328 # 95a8 <uninit>
      80:	0000c697          	auipc	a3,0xc
      84:	c3868693          	addi	a3,a3,-968 # bcb8 <buf>
    if(uninit[i] != '\0'){
      88:	0007c703          	lbu	a4,0(a5)
      8c:	e709                	bnez	a4,96 <bsstest+0x1e>
  for(i = 0; i < sizeof(uninit); i++){
      8e:	0785                	addi	a5,a5,1
      90:	fed79ce3          	bne	a5,a3,88 <bsstest+0x10>
      94:	8082                	ret
{
      96:	1141                	addi	sp,sp,-16
      98:	e406                	sd	ra,8(sp)
      9a:	e022                	sd	s0,0(sp)
      9c:	0800                	addi	s0,sp,16
      printf("%s: bss test failed\n", s);
      9e:	85aa                	mv	a1,a0
      a0:	00005517          	auipc	a0,0x5
      a4:	33050513          	addi	a0,a0,816 # 53d0 <malloc+0x122>
      a8:	152050ef          	jal	51fa <printf>
      exit(1);
      ac:	4505                	li	a0,1
      ae:	505040ef          	jal	4db2 <exit>

00000000000000b2 <opentest>:
{
      b2:	1101                	addi	sp,sp,-32
      b4:	ec06                	sd	ra,24(sp)
      b6:	e822                	sd	s0,16(sp)
      b8:	e426                	sd	s1,8(sp)
      ba:	1000                	addi	s0,sp,32
      bc:	84aa                	mv	s1,a0
  fd = open("echo", 0);
      be:	4581                	li	a1,0
      c0:	00005517          	auipc	a0,0x5
      c4:	32850513          	addi	a0,a0,808 # 53e8 <malloc+0x13a>
      c8:	52b040ef          	jal	4df2 <open>
  if(fd < 0){
      cc:	02054263          	bltz	a0,f0 <opentest+0x3e>
  close(fd);
      d0:	50b040ef          	jal	4dda <close>
  fd = open("doesnotexist", 0);
      d4:	4581                	li	a1,0
      d6:	00005517          	auipc	a0,0x5
      da:	33250513          	addi	a0,a0,818 # 5408 <malloc+0x15a>
      de:	515040ef          	jal	4df2 <open>
  if(fd >= 0){
      e2:	02055163          	bgez	a0,104 <opentest+0x52>
}
      e6:	60e2                	ld	ra,24(sp)
      e8:	6442                	ld	s0,16(sp)
      ea:	64a2                	ld	s1,8(sp)
      ec:	6105                	addi	sp,sp,32
      ee:	8082                	ret
    printf("%s: open echo failed!\n", s);
      f0:	85a6                	mv	a1,s1
      f2:	00005517          	auipc	a0,0x5
      f6:	2fe50513          	addi	a0,a0,766 # 53f0 <malloc+0x142>
      fa:	100050ef          	jal	51fa <printf>
    exit(1);
      fe:	4505                	li	a0,1
     100:	4b3040ef          	jal	4db2 <exit>
    printf("%s: open doesnotexist succeeded!\n", s);
     104:	85a6                	mv	a1,s1
     106:	00005517          	auipc	a0,0x5
     10a:	31250513          	addi	a0,a0,786 # 5418 <malloc+0x16a>
     10e:	0ec050ef          	jal	51fa <printf>
    exit(1);
     112:	4505                	li	a0,1
     114:	49f040ef          	jal	4db2 <exit>

0000000000000118 <truncate2>:
{
     118:	7179                	addi	sp,sp,-48
     11a:	f406                	sd	ra,40(sp)
     11c:	f022                	sd	s0,32(sp)
     11e:	ec26                	sd	s1,24(sp)
     120:	e84a                	sd	s2,16(sp)
     122:	e44e                	sd	s3,8(sp)
     124:	1800                	addi	s0,sp,48
     126:	89aa                	mv	s3,a0
  unlink("truncfile");
     128:	00005517          	auipc	a0,0x5
     12c:	31850513          	addi	a0,a0,792 # 5440 <malloc+0x192>
     130:	4d3040ef          	jal	4e02 <unlink>
  int fd1 = open("truncfile", O_CREATE|O_TRUNC|O_WRONLY);
     134:	60100593          	li	a1,1537
     138:	00005517          	auipc	a0,0x5
     13c:	30850513          	addi	a0,a0,776 # 5440 <malloc+0x192>
     140:	4b3040ef          	jal	4df2 <open>
     144:	84aa                	mv	s1,a0
  write(fd1, "abcd", 4);
     146:	4611                	li	a2,4
     148:	00005597          	auipc	a1,0x5
     14c:	30858593          	addi	a1,a1,776 # 5450 <malloc+0x1a2>
     150:	483040ef          	jal	4dd2 <write>
  int fd2 = open("truncfile", O_TRUNC|O_WRONLY);
     154:	40100593          	li	a1,1025
     158:	00005517          	auipc	a0,0x5
     15c:	2e850513          	addi	a0,a0,744 # 5440 <malloc+0x192>
     160:	493040ef          	jal	4df2 <open>
     164:	892a                	mv	s2,a0
  int n = write(fd1, "x", 1);
     166:	4605                	li	a2,1
     168:	00005597          	auipc	a1,0x5
     16c:	2f058593          	addi	a1,a1,752 # 5458 <malloc+0x1aa>
     170:	8526                	mv	a0,s1
     172:	461040ef          	jal	4dd2 <write>
  if(n != -1){
     176:	57fd                	li	a5,-1
     178:	02f51563          	bne	a0,a5,1a2 <truncate2+0x8a>
  unlink("truncfile");
     17c:	00005517          	auipc	a0,0x5
     180:	2c450513          	addi	a0,a0,708 # 5440 <malloc+0x192>
     184:	47f040ef          	jal	4e02 <unlink>
  close(fd1);
     188:	8526                	mv	a0,s1
     18a:	451040ef          	jal	4dda <close>
  close(fd2);
     18e:	854a                	mv	a0,s2
     190:	44b040ef          	jal	4dda <close>
}
     194:	70a2                	ld	ra,40(sp)
     196:	7402                	ld	s0,32(sp)
     198:	64e2                	ld	s1,24(sp)
     19a:	6942                	ld	s2,16(sp)
     19c:	69a2                	ld	s3,8(sp)
     19e:	6145                	addi	sp,sp,48
     1a0:	8082                	ret
    printf("%s: write returned %d, expected -1\n", s, n);
     1a2:	862a                	mv	a2,a0
     1a4:	85ce                	mv	a1,s3
     1a6:	00005517          	auipc	a0,0x5
     1aa:	2ba50513          	addi	a0,a0,698 # 5460 <malloc+0x1b2>
     1ae:	04c050ef          	jal	51fa <printf>
    exit(1);
     1b2:	4505                	li	a0,1
     1b4:	3ff040ef          	jal	4db2 <exit>

00000000000001b8 <createtest>:
{
     1b8:	7179                	addi	sp,sp,-48
     1ba:	f406                	sd	ra,40(sp)
     1bc:	f022                	sd	s0,32(sp)
     1be:	ec26                	sd	s1,24(sp)
     1c0:	e84a                	sd	s2,16(sp)
     1c2:	1800                	addi	s0,sp,48
  name[0] = 'a';
     1c4:	06100793          	li	a5,97
     1c8:	fcf40c23          	sb	a5,-40(s0)
  name[2] = '\0';
     1cc:	fc040d23          	sb	zero,-38(s0)
     1d0:	03000493          	li	s1,48
  for(i = 0; i < N; i++){
     1d4:	06400913          	li	s2,100
    name[1] = '0' + i;
     1d8:	fc940ca3          	sb	s1,-39(s0)
    fd = open(name, O_CREATE|O_RDWR);
     1dc:	20200593          	li	a1,514
     1e0:	fd840513          	addi	a0,s0,-40
     1e4:	40f040ef          	jal	4df2 <open>
    close(fd);
     1e8:	3f3040ef          	jal	4dda <close>
  for(i = 0; i < N; i++){
     1ec:	2485                	addiw	s1,s1,1
     1ee:	0ff4f493          	zext.b	s1,s1
     1f2:	ff2493e3          	bne	s1,s2,1d8 <createtest+0x20>
  name[0] = 'a';
     1f6:	06100793          	li	a5,97
     1fa:	fcf40c23          	sb	a5,-40(s0)
  name[2] = '\0';
     1fe:	fc040d23          	sb	zero,-38(s0)
     202:	03000493          	li	s1,48
  for(i = 0; i < N; i++){
     206:	06400913          	li	s2,100
    name[1] = '0' + i;
     20a:	fc940ca3          	sb	s1,-39(s0)
    unlink(name);
     20e:	fd840513          	addi	a0,s0,-40
     212:	3f1040ef          	jal	4e02 <unlink>
  for(i = 0; i < N; i++){
     216:	2485                	addiw	s1,s1,1
     218:	0ff4f493          	zext.b	s1,s1
     21c:	ff2497e3          	bne	s1,s2,20a <createtest+0x52>
}
     220:	70a2                	ld	ra,40(sp)
     222:	7402                	ld	s0,32(sp)
     224:	64e2                	ld	s1,24(sp)
     226:	6942                	ld	s2,16(sp)
     228:	6145                	addi	sp,sp,48
     22a:	8082                	ret

000000000000022c <bigwrite>:
{
     22c:	715d                	addi	sp,sp,-80
     22e:	e486                	sd	ra,72(sp)
     230:	e0a2                	sd	s0,64(sp)
     232:	fc26                	sd	s1,56(sp)
     234:	f84a                	sd	s2,48(sp)
     236:	f44e                	sd	s3,40(sp)
     238:	f052                	sd	s4,32(sp)
     23a:	ec56                	sd	s5,24(sp)
     23c:	e85a                	sd	s6,16(sp)
     23e:	e45e                	sd	s7,8(sp)
     240:	0880                	addi	s0,sp,80
     242:	8baa                	mv	s7,a0
  unlink("bigwrite");
     244:	00005517          	auipc	a0,0x5
     248:	24450513          	addi	a0,a0,580 # 5488 <malloc+0x1da>
     24c:	3b7040ef          	jal	4e02 <unlink>
  for(sz = 499; sz < (MAXOPBLOCKS+2)*BSIZE; sz += 471){
     250:	1f300493          	li	s1,499
    fd = open("bigwrite", O_CREATE | O_RDWR);
     254:	00005a97          	auipc	s5,0x5
     258:	234a8a93          	addi	s5,s5,564 # 5488 <malloc+0x1da>
      int cc = write(fd, buf, sz);
     25c:	0000ca17          	auipc	s4,0xc
     260:	a5ca0a13          	addi	s4,s4,-1444 # bcb8 <buf>
  for(sz = 499; sz < (MAXOPBLOCKS+2)*BSIZE; sz += 471){
     264:	6b0d                	lui	s6,0x3
     266:	1c9b0b13          	addi	s6,s6,457 # 31c9 <rmdot+0x19>
    fd = open("bigwrite", O_CREATE | O_RDWR);
     26a:	20200593          	li	a1,514
     26e:	8556                	mv	a0,s5
     270:	383040ef          	jal	4df2 <open>
     274:	892a                	mv	s2,a0
    if(fd < 0){
     276:	04054563          	bltz	a0,2c0 <bigwrite+0x94>
      int cc = write(fd, buf, sz);
     27a:	8626                	mv	a2,s1
     27c:	85d2                	mv	a1,s4
     27e:	355040ef          	jal	4dd2 <write>
     282:	89aa                	mv	s3,a0
      if(cc != sz){
     284:	04a49863          	bne	s1,a0,2d4 <bigwrite+0xa8>
      int cc = write(fd, buf, sz);
     288:	8626                	mv	a2,s1
     28a:	85d2                	mv	a1,s4
     28c:	854a                	mv	a0,s2
     28e:	345040ef          	jal	4dd2 <write>
      if(cc != sz){
     292:	04951263          	bne	a0,s1,2d6 <bigwrite+0xaa>
    close(fd);
     296:	854a                	mv	a0,s2
     298:	343040ef          	jal	4dda <close>
    unlink("bigwrite");
     29c:	8556                	mv	a0,s5
     29e:	365040ef          	jal	4e02 <unlink>
  for(sz = 499; sz < (MAXOPBLOCKS+2)*BSIZE; sz += 471){
     2a2:	1d74849b          	addiw	s1,s1,471
     2a6:	fd6492e3          	bne	s1,s6,26a <bigwrite+0x3e>
}
     2aa:	60a6                	ld	ra,72(sp)
     2ac:	6406                	ld	s0,64(sp)
     2ae:	74e2                	ld	s1,56(sp)
     2b0:	7942                	ld	s2,48(sp)
     2b2:	79a2                	ld	s3,40(sp)
     2b4:	7a02                	ld	s4,32(sp)
     2b6:	6ae2                	ld	s5,24(sp)
     2b8:	6b42                	ld	s6,16(sp)
     2ba:	6ba2                	ld	s7,8(sp)
     2bc:	6161                	addi	sp,sp,80
     2be:	8082                	ret
      printf("%s: cannot create bigwrite\n", s);
     2c0:	85de                	mv	a1,s7
     2c2:	00005517          	auipc	a0,0x5
     2c6:	1d650513          	addi	a0,a0,470 # 5498 <malloc+0x1ea>
     2ca:	731040ef          	jal	51fa <printf>
      exit(1);
     2ce:	4505                	li	a0,1
     2d0:	2e3040ef          	jal	4db2 <exit>
      if(cc != sz){
     2d4:	89a6                	mv	s3,s1
        printf("%s: write(%d) ret %d\n", s, sz, cc);
     2d6:	86aa                	mv	a3,a0
     2d8:	864e                	mv	a2,s3
     2da:	85de                	mv	a1,s7
     2dc:	00005517          	auipc	a0,0x5
     2e0:	1dc50513          	addi	a0,a0,476 # 54b8 <malloc+0x20a>
     2e4:	717040ef          	jal	51fa <printf>
        exit(1);
     2e8:	4505                	li	a0,1
     2ea:	2c9040ef          	jal	4db2 <exit>

00000000000002ee <badwrite>:
// file is deleted? if the kernel has this bug, it will panic: balloc:
// out of blocks. assumed_free may need to be raised to be more than
// the number of free blocks. this test takes a long time.
void
badwrite(char *s)
{
     2ee:	7179                	addi	sp,sp,-48
     2f0:	f406                	sd	ra,40(sp)
     2f2:	f022                	sd	s0,32(sp)
     2f4:	ec26                	sd	s1,24(sp)
     2f6:	e84a                	sd	s2,16(sp)
     2f8:	e44e                	sd	s3,8(sp)
     2fa:	e052                	sd	s4,0(sp)
     2fc:	1800                	addi	s0,sp,48
  int assumed_free = 600;
  
  unlink("junk");
     2fe:	00005517          	auipc	a0,0x5
     302:	1d250513          	addi	a0,a0,466 # 54d0 <malloc+0x222>
     306:	2fd040ef          	jal	4e02 <unlink>
     30a:	25800913          	li	s2,600
  for(int i = 0; i < assumed_free; i++){
    int fd = open("junk", O_CREATE|O_WRONLY);
     30e:	00005997          	auipc	s3,0x5
     312:	1c298993          	addi	s3,s3,450 # 54d0 <malloc+0x222>
    if(fd < 0){
      printf("open junk failed\n");
      exit(1);
    }
    write(fd, (char*)0xffffffffffL, 1);
     316:	5a7d                	li	s4,-1
     318:	018a5a13          	srli	s4,s4,0x18
    int fd = open("junk", O_CREATE|O_WRONLY);
     31c:	20100593          	li	a1,513
     320:	854e                	mv	a0,s3
     322:	2d1040ef          	jal	4df2 <open>
     326:	84aa                	mv	s1,a0
    if(fd < 0){
     328:	04054d63          	bltz	a0,382 <badwrite+0x94>
    write(fd, (char*)0xffffffffffL, 1);
     32c:	4605                	li	a2,1
     32e:	85d2                	mv	a1,s4
     330:	2a3040ef          	jal	4dd2 <write>
    close(fd);
     334:	8526                	mv	a0,s1
     336:	2a5040ef          	jal	4dda <close>
    unlink("junk");
     33a:	854e                	mv	a0,s3
     33c:	2c7040ef          	jal	4e02 <unlink>
  for(int i = 0; i < assumed_free; i++){
     340:	397d                	addiw	s2,s2,-1
     342:	fc091de3          	bnez	s2,31c <badwrite+0x2e>
  }

  int fd = open("junk", O_CREATE|O_WRONLY);
     346:	20100593          	li	a1,513
     34a:	00005517          	auipc	a0,0x5
     34e:	18650513          	addi	a0,a0,390 # 54d0 <malloc+0x222>
     352:	2a1040ef          	jal	4df2 <open>
     356:	84aa                	mv	s1,a0
  if(fd < 0){
     358:	02054e63          	bltz	a0,394 <badwrite+0xa6>
    printf("open junk failed\n");
    exit(1);
  }
  if(write(fd, "x", 1) != 1){
     35c:	4605                	li	a2,1
     35e:	00005597          	auipc	a1,0x5
     362:	0fa58593          	addi	a1,a1,250 # 5458 <malloc+0x1aa>
     366:	26d040ef          	jal	4dd2 <write>
     36a:	4785                	li	a5,1
     36c:	02f50d63          	beq	a0,a5,3a6 <badwrite+0xb8>
    printf("write failed\n");
     370:	00005517          	auipc	a0,0x5
     374:	18050513          	addi	a0,a0,384 # 54f0 <malloc+0x242>
     378:	683040ef          	jal	51fa <printf>
    exit(1);
     37c:	4505                	li	a0,1
     37e:	235040ef          	jal	4db2 <exit>
      printf("open junk failed\n");
     382:	00005517          	auipc	a0,0x5
     386:	15650513          	addi	a0,a0,342 # 54d8 <malloc+0x22a>
     38a:	671040ef          	jal	51fa <printf>
      exit(1);
     38e:	4505                	li	a0,1
     390:	223040ef          	jal	4db2 <exit>
    printf("open junk failed\n");
     394:	00005517          	auipc	a0,0x5
     398:	14450513          	addi	a0,a0,324 # 54d8 <malloc+0x22a>
     39c:	65f040ef          	jal	51fa <printf>
    exit(1);
     3a0:	4505                	li	a0,1
     3a2:	211040ef          	jal	4db2 <exit>
  }
  close(fd);
     3a6:	8526                	mv	a0,s1
     3a8:	233040ef          	jal	4dda <close>
  unlink("junk");
     3ac:	00005517          	auipc	a0,0x5
     3b0:	12450513          	addi	a0,a0,292 # 54d0 <malloc+0x222>
     3b4:	24f040ef          	jal	4e02 <unlink>

  exit(0);
     3b8:	4501                	li	a0,0
     3ba:	1f9040ef          	jal	4db2 <exit>

00000000000003be <outofinodes>:
  }
}

void
outofinodes(char *s)
{
     3be:	715d                	addi	sp,sp,-80
     3c0:	e486                	sd	ra,72(sp)
     3c2:	e0a2                	sd	s0,64(sp)
     3c4:	fc26                	sd	s1,56(sp)
     3c6:	f84a                	sd	s2,48(sp)
     3c8:	f44e                	sd	s3,40(sp)
     3ca:	0880                	addi	s0,sp,80
  int nzz = 32*32;
  for(int i = 0; i < nzz; i++){
     3cc:	4481                	li	s1,0
    char name[32];
    name[0] = 'z';
     3ce:	07a00913          	li	s2,122
  for(int i = 0; i < nzz; i++){
     3d2:	40000993          	li	s3,1024
    name[0] = 'z';
     3d6:	fb240823          	sb	s2,-80(s0)
    name[1] = 'z';
     3da:	fb2408a3          	sb	s2,-79(s0)
    name[2] = '0' + (i / 32);
     3de:	41f4d71b          	sraiw	a4,s1,0x1f
     3e2:	01b7571b          	srliw	a4,a4,0x1b
     3e6:	009707bb          	addw	a5,a4,s1
     3ea:	4057d69b          	sraiw	a3,a5,0x5
     3ee:	0306869b          	addiw	a3,a3,48
     3f2:	fad40923          	sb	a3,-78(s0)
    name[3] = '0' + (i % 32);
     3f6:	8bfd                	andi	a5,a5,31
     3f8:	9f99                	subw	a5,a5,a4
     3fa:	0307879b          	addiw	a5,a5,48
     3fe:	faf409a3          	sb	a5,-77(s0)
    name[4] = '\0';
     402:	fa040a23          	sb	zero,-76(s0)
    unlink(name);
     406:	fb040513          	addi	a0,s0,-80
     40a:	1f9040ef          	jal	4e02 <unlink>
    int fd = open(name, O_CREATE|O_RDWR|O_TRUNC);
     40e:	60200593          	li	a1,1538
     412:	fb040513          	addi	a0,s0,-80
     416:	1dd040ef          	jal	4df2 <open>
    if(fd < 0){
     41a:	00054763          	bltz	a0,428 <outofinodes+0x6a>
      // failure is eventually expected.
      break;
    }
    close(fd);
     41e:	1bd040ef          	jal	4dda <close>
  for(int i = 0; i < nzz; i++){
     422:	2485                	addiw	s1,s1,1
     424:	fb3499e3          	bne	s1,s3,3d6 <outofinodes+0x18>
     428:	4481                	li	s1,0
  }

  for(int i = 0; i < nzz; i++){
    char name[32];
    name[0] = 'z';
     42a:	07a00913          	li	s2,122
  for(int i = 0; i < nzz; i++){
     42e:	40000993          	li	s3,1024
    name[0] = 'z';
     432:	fb240823          	sb	s2,-80(s0)
    name[1] = 'z';
     436:	fb2408a3          	sb	s2,-79(s0)
    name[2] = '0' + (i / 32);
     43a:	41f4d71b          	sraiw	a4,s1,0x1f
     43e:	01b7571b          	srliw	a4,a4,0x1b
     442:	009707bb          	addw	a5,a4,s1
     446:	4057d69b          	sraiw	a3,a5,0x5
     44a:	0306869b          	addiw	a3,a3,48
     44e:	fad40923          	sb	a3,-78(s0)
    name[3] = '0' + (i % 32);
     452:	8bfd                	andi	a5,a5,31
     454:	9f99                	subw	a5,a5,a4
     456:	0307879b          	addiw	a5,a5,48
     45a:	faf409a3          	sb	a5,-77(s0)
    name[4] = '\0';
     45e:	fa040a23          	sb	zero,-76(s0)
    unlink(name);
     462:	fb040513          	addi	a0,s0,-80
     466:	19d040ef          	jal	4e02 <unlink>
  for(int i = 0; i < nzz; i++){
     46a:	2485                	addiw	s1,s1,1
     46c:	fd3493e3          	bne	s1,s3,432 <outofinodes+0x74>
  }
}
     470:	60a6                	ld	ra,72(sp)
     472:	6406                	ld	s0,64(sp)
     474:	74e2                	ld	s1,56(sp)
     476:	7942                	ld	s2,48(sp)
     478:	79a2                	ld	s3,40(sp)
     47a:	6161                	addi	sp,sp,80
     47c:	8082                	ret

000000000000047e <copyin>:
{
     47e:	7159                	addi	sp,sp,-112
     480:	f486                	sd	ra,104(sp)
     482:	f0a2                	sd	s0,96(sp)
     484:	eca6                	sd	s1,88(sp)
     486:	e8ca                	sd	s2,80(sp)
     488:	e4ce                	sd	s3,72(sp)
     48a:	e0d2                	sd	s4,64(sp)
     48c:	fc56                	sd	s5,56(sp)
     48e:	1880                	addi	s0,sp,112
  uint64 addrs[] = { 0x80000000LL, 0x3fffffe000, 0x3ffffff000, 0x4000000000,
     490:	00007797          	auipc	a5,0x7
     494:	4a078793          	addi	a5,a5,1184 # 7930 <malloc+0x2682>
     498:	638c                	ld	a1,0(a5)
     49a:	6790                	ld	a2,8(a5)
     49c:	6b94                	ld	a3,16(a5)
     49e:	6f98                	ld	a4,24(a5)
     4a0:	739c                	ld	a5,32(a5)
     4a2:	f8b43c23          	sd	a1,-104(s0)
     4a6:	fac43023          	sd	a2,-96(s0)
     4aa:	fad43423          	sd	a3,-88(s0)
     4ae:	fae43823          	sd	a4,-80(s0)
     4b2:	faf43c23          	sd	a5,-72(s0)
  for(int ai = 0; ai < sizeof(addrs)/sizeof(addrs[0]); ai++){
     4b6:	f9840913          	addi	s2,s0,-104
     4ba:	fc040a93          	addi	s5,s0,-64
    int fd = open("copyin1", O_CREATE|O_WRONLY);
     4be:	00005a17          	auipc	s4,0x5
     4c2:	042a0a13          	addi	s4,s4,66 # 5500 <malloc+0x252>
    uint64 addr = addrs[ai];
     4c6:	00093983          	ld	s3,0(s2)
    int fd = open("copyin1", O_CREATE|O_WRONLY);
     4ca:	20100593          	li	a1,513
     4ce:	8552                	mv	a0,s4
     4d0:	123040ef          	jal	4df2 <open>
     4d4:	84aa                	mv	s1,a0
    if(fd < 0){
     4d6:	06054763          	bltz	a0,544 <copyin+0xc6>
    int n = write(fd, (void*)addr, 8192);
     4da:	6609                	lui	a2,0x2
     4dc:	85ce                	mv	a1,s3
     4de:	0f5040ef          	jal	4dd2 <write>
    if(n >= 0){
     4e2:	06055a63          	bgez	a0,556 <copyin+0xd8>
    close(fd);
     4e6:	8526                	mv	a0,s1
     4e8:	0f3040ef          	jal	4dda <close>
    unlink("copyin1");
     4ec:	8552                	mv	a0,s4
     4ee:	115040ef          	jal	4e02 <unlink>
    n = write(1, (char*)addr, 8192);
     4f2:	6609                	lui	a2,0x2
     4f4:	85ce                	mv	a1,s3
     4f6:	4505                	li	a0,1
     4f8:	0db040ef          	jal	4dd2 <write>
    if(n > 0){
     4fc:	06a04863          	bgtz	a0,56c <copyin+0xee>
    if(pipe(fds) < 0){
     500:	f9040513          	addi	a0,s0,-112
     504:	0bf040ef          	jal	4dc2 <pipe>
     508:	06054d63          	bltz	a0,582 <copyin+0x104>
    n = write(fds[1], (char*)addr, 8192);
     50c:	6609                	lui	a2,0x2
     50e:	85ce                	mv	a1,s3
     510:	f9442503          	lw	a0,-108(s0)
     514:	0bf040ef          	jal	4dd2 <write>
    if(n > 0){
     518:	06a04e63          	bgtz	a0,594 <copyin+0x116>
    close(fds[0]);
     51c:	f9042503          	lw	a0,-112(s0)
     520:	0bb040ef          	jal	4dda <close>
    close(fds[1]);
     524:	f9442503          	lw	a0,-108(s0)
     528:	0b3040ef          	jal	4dda <close>
  for(int ai = 0; ai < sizeof(addrs)/sizeof(addrs[0]); ai++){
     52c:	0921                	addi	s2,s2,8
     52e:	f9591ce3          	bne	s2,s5,4c6 <copyin+0x48>
}
     532:	70a6                	ld	ra,104(sp)
     534:	7406                	ld	s0,96(sp)
     536:	64e6                	ld	s1,88(sp)
     538:	6946                	ld	s2,80(sp)
     53a:	69a6                	ld	s3,72(sp)
     53c:	6a06                	ld	s4,64(sp)
     53e:	7ae2                	ld	s5,56(sp)
     540:	6165                	addi	sp,sp,112
     542:	8082                	ret
      printf("open(copyin1) failed\n");
     544:	00005517          	auipc	a0,0x5
     548:	fc450513          	addi	a0,a0,-60 # 5508 <malloc+0x25a>
     54c:	4af040ef          	jal	51fa <printf>
      exit(1);
     550:	4505                	li	a0,1
     552:	061040ef          	jal	4db2 <exit>
      printf("write(fd, %p, 8192) returned %d, not -1\n", (void*)addr, n);
     556:	862a                	mv	a2,a0
     558:	85ce                	mv	a1,s3
     55a:	00005517          	auipc	a0,0x5
     55e:	fc650513          	addi	a0,a0,-58 # 5520 <malloc+0x272>
     562:	499040ef          	jal	51fa <printf>
      exit(1);
     566:	4505                	li	a0,1
     568:	04b040ef          	jal	4db2 <exit>
      printf("write(1, %p, 8192) returned %d, not -1 or 0\n", (void*)addr, n);
     56c:	862a                	mv	a2,a0
     56e:	85ce                	mv	a1,s3
     570:	00005517          	auipc	a0,0x5
     574:	fe050513          	addi	a0,a0,-32 # 5550 <malloc+0x2a2>
     578:	483040ef          	jal	51fa <printf>
      exit(1);
     57c:	4505                	li	a0,1
     57e:	035040ef          	jal	4db2 <exit>
      printf("pipe() failed\n");
     582:	00005517          	auipc	a0,0x5
     586:	ffe50513          	addi	a0,a0,-2 # 5580 <malloc+0x2d2>
     58a:	471040ef          	jal	51fa <printf>
      exit(1);
     58e:	4505                	li	a0,1
     590:	023040ef          	jal	4db2 <exit>
      printf("write(pipe, %p, 8192) returned %d, not -1 or 0\n", (void*)addr, n);
     594:	862a                	mv	a2,a0
     596:	85ce                	mv	a1,s3
     598:	00005517          	auipc	a0,0x5
     59c:	ff850513          	addi	a0,a0,-8 # 5590 <malloc+0x2e2>
     5a0:	45b040ef          	jal	51fa <printf>
      exit(1);
     5a4:	4505                	li	a0,1
     5a6:	00d040ef          	jal	4db2 <exit>

00000000000005aa <copyout>:
{
     5aa:	7119                	addi	sp,sp,-128
     5ac:	fc86                	sd	ra,120(sp)
     5ae:	f8a2                	sd	s0,112(sp)
     5b0:	f4a6                	sd	s1,104(sp)
     5b2:	f0ca                	sd	s2,96(sp)
     5b4:	ecce                	sd	s3,88(sp)
     5b6:	e8d2                	sd	s4,80(sp)
     5b8:	e4d6                	sd	s5,72(sp)
     5ba:	e0da                	sd	s6,64(sp)
     5bc:	0100                	addi	s0,sp,128
  uint64 addrs[] = { 0LL, 0x80000000LL, 0x3fffffe000, 0x3ffffff000, 0x4000000000,
     5be:	00007797          	auipc	a5,0x7
     5c2:	37278793          	addi	a5,a5,882 # 7930 <malloc+0x2682>
     5c6:	7788                	ld	a0,40(a5)
     5c8:	7b8c                	ld	a1,48(a5)
     5ca:	7f90                	ld	a2,56(a5)
     5cc:	63b4                	ld	a3,64(a5)
     5ce:	67b8                	ld	a4,72(a5)
     5d0:	6bbc                	ld	a5,80(a5)
     5d2:	f8a43823          	sd	a0,-112(s0)
     5d6:	f8b43c23          	sd	a1,-104(s0)
     5da:	fac43023          	sd	a2,-96(s0)
     5de:	fad43423          	sd	a3,-88(s0)
     5e2:	fae43823          	sd	a4,-80(s0)
     5e6:	faf43c23          	sd	a5,-72(s0)
  for(int ai = 0; ai < sizeof(addrs)/sizeof(addrs[0]); ai++){
     5ea:	f9040913          	addi	s2,s0,-112
     5ee:	fc040b13          	addi	s6,s0,-64
    int fd = open("README", 0);
     5f2:	00005a17          	auipc	s4,0x5
     5f6:	fcea0a13          	addi	s4,s4,-50 # 55c0 <malloc+0x312>
    n = write(fds[1], "x", 1);
     5fa:	00005a97          	auipc	s5,0x5
     5fe:	e5ea8a93          	addi	s5,s5,-418 # 5458 <malloc+0x1aa>
    uint64 addr = addrs[ai];
     602:	00093983          	ld	s3,0(s2)
    int fd = open("README", 0);
     606:	4581                	li	a1,0
     608:	8552                	mv	a0,s4
     60a:	7e8040ef          	jal	4df2 <open>
     60e:	84aa                	mv	s1,a0
    if(fd < 0){
     610:	06054763          	bltz	a0,67e <copyout+0xd4>
    int n = read(fd, (void*)addr, 8192);
     614:	6609                	lui	a2,0x2
     616:	85ce                	mv	a1,s3
     618:	7b2040ef          	jal	4dca <read>
    if(n > 0){
     61c:	06a04a63          	bgtz	a0,690 <copyout+0xe6>
    close(fd);
     620:	8526                	mv	a0,s1
     622:	7b8040ef          	jal	4dda <close>
    if(pipe(fds) < 0){
     626:	f8840513          	addi	a0,s0,-120
     62a:	798040ef          	jal	4dc2 <pipe>
     62e:	06054c63          	bltz	a0,6a6 <copyout+0xfc>
    n = write(fds[1], "x", 1);
     632:	4605                	li	a2,1
     634:	85d6                	mv	a1,s5
     636:	f8c42503          	lw	a0,-116(s0)
     63a:	798040ef          	jal	4dd2 <write>
    if(n != 1){
     63e:	4785                	li	a5,1
     640:	06f51c63          	bne	a0,a5,6b8 <copyout+0x10e>
    n = read(fds[0], (void*)addr, 8192);
     644:	6609                	lui	a2,0x2
     646:	85ce                	mv	a1,s3
     648:	f8842503          	lw	a0,-120(s0)
     64c:	77e040ef          	jal	4dca <read>
    if(n > 0){
     650:	06a04d63          	bgtz	a0,6ca <copyout+0x120>
    close(fds[0]);
     654:	f8842503          	lw	a0,-120(s0)
     658:	782040ef          	jal	4dda <close>
    close(fds[1]);
     65c:	f8c42503          	lw	a0,-116(s0)
     660:	77a040ef          	jal	4dda <close>
  for(int ai = 0; ai < sizeof(addrs)/sizeof(addrs[0]); ai++){
     664:	0921                	addi	s2,s2,8
     666:	f9691ee3          	bne	s2,s6,602 <copyout+0x58>
}
     66a:	70e6                	ld	ra,120(sp)
     66c:	7446                	ld	s0,112(sp)
     66e:	74a6                	ld	s1,104(sp)
     670:	7906                	ld	s2,96(sp)
     672:	69e6                	ld	s3,88(sp)
     674:	6a46                	ld	s4,80(sp)
     676:	6aa6                	ld	s5,72(sp)
     678:	6b06                	ld	s6,64(sp)
     67a:	6109                	addi	sp,sp,128
     67c:	8082                	ret
      printf("open(README) failed\n");
     67e:	00005517          	auipc	a0,0x5
     682:	f4a50513          	addi	a0,a0,-182 # 55c8 <malloc+0x31a>
     686:	375040ef          	jal	51fa <printf>
      exit(1);
     68a:	4505                	li	a0,1
     68c:	726040ef          	jal	4db2 <exit>
      printf("read(fd, %p, 8192) returned %d, not -1 or 0\n", (void*)addr, n);
     690:	862a                	mv	a2,a0
     692:	85ce                	mv	a1,s3
     694:	00005517          	auipc	a0,0x5
     698:	f4c50513          	addi	a0,a0,-180 # 55e0 <malloc+0x332>
     69c:	35f040ef          	jal	51fa <printf>
      exit(1);
     6a0:	4505                	li	a0,1
     6a2:	710040ef          	jal	4db2 <exit>
      printf("pipe() failed\n");
     6a6:	00005517          	auipc	a0,0x5
     6aa:	eda50513          	addi	a0,a0,-294 # 5580 <malloc+0x2d2>
     6ae:	34d040ef          	jal	51fa <printf>
      exit(1);
     6b2:	4505                	li	a0,1
     6b4:	6fe040ef          	jal	4db2 <exit>
      printf("pipe write failed\n");
     6b8:	00005517          	auipc	a0,0x5
     6bc:	f5850513          	addi	a0,a0,-168 # 5610 <malloc+0x362>
     6c0:	33b040ef          	jal	51fa <printf>
      exit(1);
     6c4:	4505                	li	a0,1
     6c6:	6ec040ef          	jal	4db2 <exit>
      printf("read(pipe, %p, 8192) returned %d, not -1 or 0\n", (void*)addr, n);
     6ca:	862a                	mv	a2,a0
     6cc:	85ce                	mv	a1,s3
     6ce:	00005517          	auipc	a0,0x5
     6d2:	f5a50513          	addi	a0,a0,-166 # 5628 <malloc+0x37a>
     6d6:	325040ef          	jal	51fa <printf>
      exit(1);
     6da:	4505                	li	a0,1
     6dc:	6d6040ef          	jal	4db2 <exit>

00000000000006e0 <truncate1>:
{
     6e0:	711d                	addi	sp,sp,-96
     6e2:	ec86                	sd	ra,88(sp)
     6e4:	e8a2                	sd	s0,80(sp)
     6e6:	e4a6                	sd	s1,72(sp)
     6e8:	e0ca                	sd	s2,64(sp)
     6ea:	fc4e                	sd	s3,56(sp)
     6ec:	f852                	sd	s4,48(sp)
     6ee:	f456                	sd	s5,40(sp)
     6f0:	1080                	addi	s0,sp,96
     6f2:	8aaa                	mv	s5,a0
  unlink("truncfile");
     6f4:	00005517          	auipc	a0,0x5
     6f8:	d4c50513          	addi	a0,a0,-692 # 5440 <malloc+0x192>
     6fc:	706040ef          	jal	4e02 <unlink>
  int fd1 = open("truncfile", O_CREATE|O_WRONLY|O_TRUNC);
     700:	60100593          	li	a1,1537
     704:	00005517          	auipc	a0,0x5
     708:	d3c50513          	addi	a0,a0,-708 # 5440 <malloc+0x192>
     70c:	6e6040ef          	jal	4df2 <open>
     710:	84aa                	mv	s1,a0
  write(fd1, "abcd", 4);
     712:	4611                	li	a2,4
     714:	00005597          	auipc	a1,0x5
     718:	d3c58593          	addi	a1,a1,-708 # 5450 <malloc+0x1a2>
     71c:	6b6040ef          	jal	4dd2 <write>
  close(fd1);
     720:	8526                	mv	a0,s1
     722:	6b8040ef          	jal	4dda <close>
  int fd2 = open("truncfile", O_RDONLY);
     726:	4581                	li	a1,0
     728:	00005517          	auipc	a0,0x5
     72c:	d1850513          	addi	a0,a0,-744 # 5440 <malloc+0x192>
     730:	6c2040ef          	jal	4df2 <open>
     734:	84aa                	mv	s1,a0
  int n = read(fd2, buf, sizeof(buf));
     736:	02000613          	li	a2,32
     73a:	fa040593          	addi	a1,s0,-96
     73e:	68c040ef          	jal	4dca <read>
  if(n != 4){
     742:	4791                	li	a5,4
     744:	0af51863          	bne	a0,a5,7f4 <truncate1+0x114>
  fd1 = open("truncfile", O_WRONLY|O_TRUNC);
     748:	40100593          	li	a1,1025
     74c:	00005517          	auipc	a0,0x5
     750:	cf450513          	addi	a0,a0,-780 # 5440 <malloc+0x192>
     754:	69e040ef          	jal	4df2 <open>
     758:	89aa                	mv	s3,a0
  int fd3 = open("truncfile", O_RDONLY);
     75a:	4581                	li	a1,0
     75c:	00005517          	auipc	a0,0x5
     760:	ce450513          	addi	a0,a0,-796 # 5440 <malloc+0x192>
     764:	68e040ef          	jal	4df2 <open>
     768:	892a                	mv	s2,a0
  n = read(fd3, buf, sizeof(buf));
     76a:	02000613          	li	a2,32
     76e:	fa040593          	addi	a1,s0,-96
     772:	658040ef          	jal	4dca <read>
     776:	8a2a                	mv	s4,a0
  if(n != 0){
     778:	e949                	bnez	a0,80a <truncate1+0x12a>
  n = read(fd2, buf, sizeof(buf));
     77a:	02000613          	li	a2,32
     77e:	fa040593          	addi	a1,s0,-96
     782:	8526                	mv	a0,s1
     784:	646040ef          	jal	4dca <read>
     788:	8a2a                	mv	s4,a0
  if(n != 0){
     78a:	e155                	bnez	a0,82e <truncate1+0x14e>
  write(fd1, "abcdef", 6);
     78c:	4619                	li	a2,6
     78e:	00005597          	auipc	a1,0x5
     792:	f2a58593          	addi	a1,a1,-214 # 56b8 <malloc+0x40a>
     796:	854e                	mv	a0,s3
     798:	63a040ef          	jal	4dd2 <write>
  n = read(fd3, buf, sizeof(buf));
     79c:	02000613          	li	a2,32
     7a0:	fa040593          	addi	a1,s0,-96
     7a4:	854a                	mv	a0,s2
     7a6:	624040ef          	jal	4dca <read>
  if(n != 6){
     7aa:	4799                	li	a5,6
     7ac:	0af51363          	bne	a0,a5,852 <truncate1+0x172>
  n = read(fd2, buf, sizeof(buf));
     7b0:	02000613          	li	a2,32
     7b4:	fa040593          	addi	a1,s0,-96
     7b8:	8526                	mv	a0,s1
     7ba:	610040ef          	jal	4dca <read>
  if(n != 2){
     7be:	4789                	li	a5,2
     7c0:	0af51463          	bne	a0,a5,868 <truncate1+0x188>
  unlink("truncfile");
     7c4:	00005517          	auipc	a0,0x5
     7c8:	c7c50513          	addi	a0,a0,-900 # 5440 <malloc+0x192>
     7cc:	636040ef          	jal	4e02 <unlink>
  close(fd1);
     7d0:	854e                	mv	a0,s3
     7d2:	608040ef          	jal	4dda <close>
  close(fd2);
     7d6:	8526                	mv	a0,s1
     7d8:	602040ef          	jal	4dda <close>
  close(fd3);
     7dc:	854a                	mv	a0,s2
     7de:	5fc040ef          	jal	4dda <close>
}
     7e2:	60e6                	ld	ra,88(sp)
     7e4:	6446                	ld	s0,80(sp)
     7e6:	64a6                	ld	s1,72(sp)
     7e8:	6906                	ld	s2,64(sp)
     7ea:	79e2                	ld	s3,56(sp)
     7ec:	7a42                	ld	s4,48(sp)
     7ee:	7aa2                	ld	s5,40(sp)
     7f0:	6125                	addi	sp,sp,96
     7f2:	8082                	ret
    printf("%s: read %d bytes, wanted 4\n", s, n);
     7f4:	862a                	mv	a2,a0
     7f6:	85d6                	mv	a1,s5
     7f8:	00005517          	auipc	a0,0x5
     7fc:	e6050513          	addi	a0,a0,-416 # 5658 <malloc+0x3aa>
     800:	1fb040ef          	jal	51fa <printf>
    exit(1);
     804:	4505                	li	a0,1
     806:	5ac040ef          	jal	4db2 <exit>
    printf("aaa fd3=%d\n", fd3);
     80a:	85ca                	mv	a1,s2
     80c:	00005517          	auipc	a0,0x5
     810:	e6c50513          	addi	a0,a0,-404 # 5678 <malloc+0x3ca>
     814:	1e7040ef          	jal	51fa <printf>
    printf("%s: read %d bytes, wanted 0\n", s, n);
     818:	8652                	mv	a2,s4
     81a:	85d6                	mv	a1,s5
     81c:	00005517          	auipc	a0,0x5
     820:	e6c50513          	addi	a0,a0,-404 # 5688 <malloc+0x3da>
     824:	1d7040ef          	jal	51fa <printf>
    exit(1);
     828:	4505                	li	a0,1
     82a:	588040ef          	jal	4db2 <exit>
    printf("bbb fd2=%d\n", fd2);
     82e:	85a6                	mv	a1,s1
     830:	00005517          	auipc	a0,0x5
     834:	e7850513          	addi	a0,a0,-392 # 56a8 <malloc+0x3fa>
     838:	1c3040ef          	jal	51fa <printf>
    printf("%s: read %d bytes, wanted 0\n", s, n);
     83c:	8652                	mv	a2,s4
     83e:	85d6                	mv	a1,s5
     840:	00005517          	auipc	a0,0x5
     844:	e4850513          	addi	a0,a0,-440 # 5688 <malloc+0x3da>
     848:	1b3040ef          	jal	51fa <printf>
    exit(1);
     84c:	4505                	li	a0,1
     84e:	564040ef          	jal	4db2 <exit>
    printf("%s: read %d bytes, wanted 6\n", s, n);
     852:	862a                	mv	a2,a0
     854:	85d6                	mv	a1,s5
     856:	00005517          	auipc	a0,0x5
     85a:	e6a50513          	addi	a0,a0,-406 # 56c0 <malloc+0x412>
     85e:	19d040ef          	jal	51fa <printf>
    exit(1);
     862:	4505                	li	a0,1
     864:	54e040ef          	jal	4db2 <exit>
    printf("%s: read %d bytes, wanted 2\n", s, n);
     868:	862a                	mv	a2,a0
     86a:	85d6                	mv	a1,s5
     86c:	00005517          	auipc	a0,0x5
     870:	e7450513          	addi	a0,a0,-396 # 56e0 <malloc+0x432>
     874:	187040ef          	jal	51fa <printf>
    exit(1);
     878:	4505                	li	a0,1
     87a:	538040ef          	jal	4db2 <exit>

000000000000087e <writetest>:
{
     87e:	7139                	addi	sp,sp,-64
     880:	fc06                	sd	ra,56(sp)
     882:	f822                	sd	s0,48(sp)
     884:	f426                	sd	s1,40(sp)
     886:	f04a                	sd	s2,32(sp)
     888:	ec4e                	sd	s3,24(sp)
     88a:	e852                	sd	s4,16(sp)
     88c:	e456                	sd	s5,8(sp)
     88e:	e05a                	sd	s6,0(sp)
     890:	0080                	addi	s0,sp,64
     892:	8b2a                	mv	s6,a0
  fd = open("small", O_CREATE|O_RDWR);
     894:	20200593          	li	a1,514
     898:	00005517          	auipc	a0,0x5
     89c:	e6850513          	addi	a0,a0,-408 # 5700 <malloc+0x452>
     8a0:	552040ef          	jal	4df2 <open>
  if(fd < 0){
     8a4:	08054f63          	bltz	a0,942 <writetest+0xc4>
     8a8:	892a                	mv	s2,a0
     8aa:	4481                	li	s1,0
    if(write(fd, "aaaaaaaaaa", SZ) != SZ){
     8ac:	00005997          	auipc	s3,0x5
     8b0:	e7c98993          	addi	s3,s3,-388 # 5728 <malloc+0x47a>
    if(write(fd, "bbbbbbbbbb", SZ) != SZ){
     8b4:	00005a97          	auipc	s5,0x5
     8b8:	eaca8a93          	addi	s5,s5,-340 # 5760 <malloc+0x4b2>
  for(i = 0; i < N; i++){
     8bc:	06400a13          	li	s4,100
    if(write(fd, "aaaaaaaaaa", SZ) != SZ){
     8c0:	4629                	li	a2,10
     8c2:	85ce                	mv	a1,s3
     8c4:	854a                	mv	a0,s2
     8c6:	50c040ef          	jal	4dd2 <write>
     8ca:	47a9                	li	a5,10
     8cc:	08f51563          	bne	a0,a5,956 <writetest+0xd8>
    if(write(fd, "bbbbbbbbbb", SZ) != SZ){
     8d0:	4629                	li	a2,10
     8d2:	85d6                	mv	a1,s5
     8d4:	854a                	mv	a0,s2
     8d6:	4fc040ef          	jal	4dd2 <write>
     8da:	47a9                	li	a5,10
     8dc:	08f51863          	bne	a0,a5,96c <writetest+0xee>
  for(i = 0; i < N; i++){
     8e0:	2485                	addiw	s1,s1,1
     8e2:	fd449fe3          	bne	s1,s4,8c0 <writetest+0x42>
  close(fd);
     8e6:	854a                	mv	a0,s2
     8e8:	4f2040ef          	jal	4dda <close>
  fd = open("small", O_RDONLY);
     8ec:	4581                	li	a1,0
     8ee:	00005517          	auipc	a0,0x5
     8f2:	e1250513          	addi	a0,a0,-494 # 5700 <malloc+0x452>
     8f6:	4fc040ef          	jal	4df2 <open>
     8fa:	84aa                	mv	s1,a0
  if(fd < 0){
     8fc:	08054363          	bltz	a0,982 <writetest+0x104>
  i = read(fd, buf, N*SZ*2);
     900:	7d000613          	li	a2,2000
     904:	0000b597          	auipc	a1,0xb
     908:	3b458593          	addi	a1,a1,948 # bcb8 <buf>
     90c:	4be040ef          	jal	4dca <read>
  if(i != N*SZ*2){
     910:	7d000793          	li	a5,2000
     914:	08f51163          	bne	a0,a5,996 <writetest+0x118>
  close(fd);
     918:	8526                	mv	a0,s1
     91a:	4c0040ef          	jal	4dda <close>
  if(unlink("small") < 0){
     91e:	00005517          	auipc	a0,0x5
     922:	de250513          	addi	a0,a0,-542 # 5700 <malloc+0x452>
     926:	4dc040ef          	jal	4e02 <unlink>
     92a:	08054063          	bltz	a0,9aa <writetest+0x12c>
}
     92e:	70e2                	ld	ra,56(sp)
     930:	7442                	ld	s0,48(sp)
     932:	74a2                	ld	s1,40(sp)
     934:	7902                	ld	s2,32(sp)
     936:	69e2                	ld	s3,24(sp)
     938:	6a42                	ld	s4,16(sp)
     93a:	6aa2                	ld	s5,8(sp)
     93c:	6b02                	ld	s6,0(sp)
     93e:	6121                	addi	sp,sp,64
     940:	8082                	ret
    printf("%s: error: creat small failed!\n", s);
     942:	85da                	mv	a1,s6
     944:	00005517          	auipc	a0,0x5
     948:	dc450513          	addi	a0,a0,-572 # 5708 <malloc+0x45a>
     94c:	0af040ef          	jal	51fa <printf>
    exit(1);
     950:	4505                	li	a0,1
     952:	460040ef          	jal	4db2 <exit>
      printf("%s: error: write aa %d new file failed\n", s, i);
     956:	8626                	mv	a2,s1
     958:	85da                	mv	a1,s6
     95a:	00005517          	auipc	a0,0x5
     95e:	dde50513          	addi	a0,a0,-546 # 5738 <malloc+0x48a>
     962:	099040ef          	jal	51fa <printf>
      exit(1);
     966:	4505                	li	a0,1
     968:	44a040ef          	jal	4db2 <exit>
      printf("%s: error: write bb %d new file failed\n", s, i);
     96c:	8626                	mv	a2,s1
     96e:	85da                	mv	a1,s6
     970:	00005517          	auipc	a0,0x5
     974:	e0050513          	addi	a0,a0,-512 # 5770 <malloc+0x4c2>
     978:	083040ef          	jal	51fa <printf>
      exit(1);
     97c:	4505                	li	a0,1
     97e:	434040ef          	jal	4db2 <exit>
    printf("%s: error: open small failed!\n", s);
     982:	85da                	mv	a1,s6
     984:	00005517          	auipc	a0,0x5
     988:	e1450513          	addi	a0,a0,-492 # 5798 <malloc+0x4ea>
     98c:	06f040ef          	jal	51fa <printf>
    exit(1);
     990:	4505                	li	a0,1
     992:	420040ef          	jal	4db2 <exit>
    printf("%s: read failed\n", s);
     996:	85da                	mv	a1,s6
     998:	00005517          	auipc	a0,0x5
     99c:	e2050513          	addi	a0,a0,-480 # 57b8 <malloc+0x50a>
     9a0:	05b040ef          	jal	51fa <printf>
    exit(1);
     9a4:	4505                	li	a0,1
     9a6:	40c040ef          	jal	4db2 <exit>
    printf("%s: unlink small failed\n", s);
     9aa:	85da                	mv	a1,s6
     9ac:	00005517          	auipc	a0,0x5
     9b0:	e2450513          	addi	a0,a0,-476 # 57d0 <malloc+0x522>
     9b4:	047040ef          	jal	51fa <printf>
    exit(1);
     9b8:	4505                	li	a0,1
     9ba:	3f8040ef          	jal	4db2 <exit>

00000000000009be <writebig>:
{
     9be:	7139                	addi	sp,sp,-64
     9c0:	fc06                	sd	ra,56(sp)
     9c2:	f822                	sd	s0,48(sp)
     9c4:	f426                	sd	s1,40(sp)
     9c6:	f04a                	sd	s2,32(sp)
     9c8:	ec4e                	sd	s3,24(sp)
     9ca:	e852                	sd	s4,16(sp)
     9cc:	e456                	sd	s5,8(sp)
     9ce:	0080                	addi	s0,sp,64
     9d0:	8aaa                	mv	s5,a0
  fd = open("big", O_CREATE|O_RDWR);
     9d2:	20200593          	li	a1,514
     9d6:	00005517          	auipc	a0,0x5
     9da:	e1a50513          	addi	a0,a0,-486 # 57f0 <malloc+0x542>
     9de:	414040ef          	jal	4df2 <open>
     9e2:	89aa                	mv	s3,a0
  for(i = 0; i < MAXFILE; i++){
     9e4:	4481                	li	s1,0
    ((int*)buf)[0] = i;
     9e6:	0000b917          	auipc	s2,0xb
     9ea:	2d290913          	addi	s2,s2,722 # bcb8 <buf>
  for(i = 0; i < MAXFILE; i++){
     9ee:	10c00a13          	li	s4,268
  if(fd < 0){
     9f2:	06054463          	bltz	a0,a5a <writebig+0x9c>
    ((int*)buf)[0] = i;
     9f6:	00992023          	sw	s1,0(s2)
    if(write(fd, buf, BSIZE) != BSIZE){
     9fa:	40000613          	li	a2,1024
     9fe:	85ca                	mv	a1,s2
     a00:	854e                	mv	a0,s3
     a02:	3d0040ef          	jal	4dd2 <write>
     a06:	40000793          	li	a5,1024
     a0a:	06f51263          	bne	a0,a5,a6e <writebig+0xb0>
  for(i = 0; i < MAXFILE; i++){
     a0e:	2485                	addiw	s1,s1,1
     a10:	ff4493e3          	bne	s1,s4,9f6 <writebig+0x38>
  close(fd);
     a14:	854e                	mv	a0,s3
     a16:	3c4040ef          	jal	4dda <close>
  fd = open("big", O_RDONLY);
     a1a:	4581                	li	a1,0
     a1c:	00005517          	auipc	a0,0x5
     a20:	dd450513          	addi	a0,a0,-556 # 57f0 <malloc+0x542>
     a24:	3ce040ef          	jal	4df2 <open>
     a28:	89aa                	mv	s3,a0
  n = 0;
     a2a:	4481                	li	s1,0
    i = read(fd, buf, BSIZE);
     a2c:	0000b917          	auipc	s2,0xb
     a30:	28c90913          	addi	s2,s2,652 # bcb8 <buf>
  if(fd < 0){
     a34:	04054863          	bltz	a0,a84 <writebig+0xc6>
    i = read(fd, buf, BSIZE);
     a38:	40000613          	li	a2,1024
     a3c:	85ca                	mv	a1,s2
     a3e:	854e                	mv	a0,s3
     a40:	38a040ef          	jal	4dca <read>
    if(i == 0){
     a44:	c931                	beqz	a0,a98 <writebig+0xda>
    } else if(i != BSIZE){
     a46:	40000793          	li	a5,1024
     a4a:	08f51a63          	bne	a0,a5,ade <writebig+0x120>
    if(((int*)buf)[0] != n){
     a4e:	00092683          	lw	a3,0(s2)
     a52:	0a969163          	bne	a3,s1,af4 <writebig+0x136>
    n++;
     a56:	2485                	addiw	s1,s1,1
    i = read(fd, buf, BSIZE);
     a58:	b7c5                	j	a38 <writebig+0x7a>
    printf("%s: error: creat big failed!\n", s);
     a5a:	85d6                	mv	a1,s5
     a5c:	00005517          	auipc	a0,0x5
     a60:	d9c50513          	addi	a0,a0,-612 # 57f8 <malloc+0x54a>
     a64:	796040ef          	jal	51fa <printf>
    exit(1);
     a68:	4505                	li	a0,1
     a6a:	348040ef          	jal	4db2 <exit>
      printf("%s: error: write big file failed i=%d\n", s, i);
     a6e:	8626                	mv	a2,s1
     a70:	85d6                	mv	a1,s5
     a72:	00005517          	auipc	a0,0x5
     a76:	da650513          	addi	a0,a0,-602 # 5818 <malloc+0x56a>
     a7a:	780040ef          	jal	51fa <printf>
      exit(1);
     a7e:	4505                	li	a0,1
     a80:	332040ef          	jal	4db2 <exit>
    printf("%s: error: open big failed!\n", s);
     a84:	85d6                	mv	a1,s5
     a86:	00005517          	auipc	a0,0x5
     a8a:	dba50513          	addi	a0,a0,-582 # 5840 <malloc+0x592>
     a8e:	76c040ef          	jal	51fa <printf>
    exit(1);
     a92:	4505                	li	a0,1
     a94:	31e040ef          	jal	4db2 <exit>
      if(n != MAXFILE){
     a98:	10c00793          	li	a5,268
     a9c:	02f49663          	bne	s1,a5,ac8 <writebig+0x10a>
  close(fd);
     aa0:	854e                	mv	a0,s3
     aa2:	338040ef          	jal	4dda <close>
  if(unlink("big") < 0){
     aa6:	00005517          	auipc	a0,0x5
     aaa:	d4a50513          	addi	a0,a0,-694 # 57f0 <malloc+0x542>
     aae:	354040ef          	jal	4e02 <unlink>
     ab2:	04054c63          	bltz	a0,b0a <writebig+0x14c>
}
     ab6:	70e2                	ld	ra,56(sp)
     ab8:	7442                	ld	s0,48(sp)
     aba:	74a2                	ld	s1,40(sp)
     abc:	7902                	ld	s2,32(sp)
     abe:	69e2                	ld	s3,24(sp)
     ac0:	6a42                	ld	s4,16(sp)
     ac2:	6aa2                	ld	s5,8(sp)
     ac4:	6121                	addi	sp,sp,64
     ac6:	8082                	ret
        printf("%s: read only %d blocks from big", s, n);
     ac8:	8626                	mv	a2,s1
     aca:	85d6                	mv	a1,s5
     acc:	00005517          	auipc	a0,0x5
     ad0:	d9450513          	addi	a0,a0,-620 # 5860 <malloc+0x5b2>
     ad4:	726040ef          	jal	51fa <printf>
        exit(1);
     ad8:	4505                	li	a0,1
     ada:	2d8040ef          	jal	4db2 <exit>
      printf("%s: read failed %d\n", s, i);
     ade:	862a                	mv	a2,a0
     ae0:	85d6                	mv	a1,s5
     ae2:	00005517          	auipc	a0,0x5
     ae6:	da650513          	addi	a0,a0,-602 # 5888 <malloc+0x5da>
     aea:	710040ef          	jal	51fa <printf>
      exit(1);
     aee:	4505                	li	a0,1
     af0:	2c2040ef          	jal	4db2 <exit>
      printf("%s: read content of block %d is %d\n", s,
     af4:	8626                	mv	a2,s1
     af6:	85d6                	mv	a1,s5
     af8:	00005517          	auipc	a0,0x5
     afc:	da850513          	addi	a0,a0,-600 # 58a0 <malloc+0x5f2>
     b00:	6fa040ef          	jal	51fa <printf>
      exit(1);
     b04:	4505                	li	a0,1
     b06:	2ac040ef          	jal	4db2 <exit>
    printf("%s: unlink big failed\n", s);
     b0a:	85d6                	mv	a1,s5
     b0c:	00005517          	auipc	a0,0x5
     b10:	dbc50513          	addi	a0,a0,-580 # 58c8 <malloc+0x61a>
     b14:	6e6040ef          	jal	51fa <printf>
    exit(1);
     b18:	4505                	li	a0,1
     b1a:	298040ef          	jal	4db2 <exit>

0000000000000b1e <unlinkread>:
{
     b1e:	7179                	addi	sp,sp,-48
     b20:	f406                	sd	ra,40(sp)
     b22:	f022                	sd	s0,32(sp)
     b24:	ec26                	sd	s1,24(sp)
     b26:	e84a                	sd	s2,16(sp)
     b28:	e44e                	sd	s3,8(sp)
     b2a:	1800                	addi	s0,sp,48
     b2c:	89aa                	mv	s3,a0
  fd = open("unlinkread", O_CREATE | O_RDWR);
     b2e:	20200593          	li	a1,514
     b32:	00005517          	auipc	a0,0x5
     b36:	dae50513          	addi	a0,a0,-594 # 58e0 <malloc+0x632>
     b3a:	2b8040ef          	jal	4df2 <open>
  if(fd < 0){
     b3e:	0a054f63          	bltz	a0,bfc <unlinkread+0xde>
     b42:	84aa                	mv	s1,a0
  write(fd, "hello", SZ);
     b44:	4615                	li	a2,5
     b46:	00005597          	auipc	a1,0x5
     b4a:	dca58593          	addi	a1,a1,-566 # 5910 <malloc+0x662>
     b4e:	284040ef          	jal	4dd2 <write>
  close(fd);
     b52:	8526                	mv	a0,s1
     b54:	286040ef          	jal	4dda <close>
  fd = open("unlinkread", O_RDWR);
     b58:	4589                	li	a1,2
     b5a:	00005517          	auipc	a0,0x5
     b5e:	d8650513          	addi	a0,a0,-634 # 58e0 <malloc+0x632>
     b62:	290040ef          	jal	4df2 <open>
     b66:	84aa                	mv	s1,a0
  if(fd < 0){
     b68:	0a054463          	bltz	a0,c10 <unlinkread+0xf2>
  if(unlink("unlinkread") != 0){
     b6c:	00005517          	auipc	a0,0x5
     b70:	d7450513          	addi	a0,a0,-652 # 58e0 <malloc+0x632>
     b74:	28e040ef          	jal	4e02 <unlink>
     b78:	e555                	bnez	a0,c24 <unlinkread+0x106>
  fd1 = open("unlinkread", O_CREATE | O_RDWR);
     b7a:	20200593          	li	a1,514
     b7e:	00005517          	auipc	a0,0x5
     b82:	d6250513          	addi	a0,a0,-670 # 58e0 <malloc+0x632>
     b86:	26c040ef          	jal	4df2 <open>
     b8a:	892a                	mv	s2,a0
  write(fd1, "yyy", 3);
     b8c:	460d                	li	a2,3
     b8e:	00005597          	auipc	a1,0x5
     b92:	dca58593          	addi	a1,a1,-566 # 5958 <malloc+0x6aa>
     b96:	23c040ef          	jal	4dd2 <write>
  close(fd1);
     b9a:	854a                	mv	a0,s2
     b9c:	23e040ef          	jal	4dda <close>
  if(read(fd, buf, sizeof(buf)) != SZ){
     ba0:	660d                	lui	a2,0x3
     ba2:	0000b597          	auipc	a1,0xb
     ba6:	11658593          	addi	a1,a1,278 # bcb8 <buf>
     baa:	8526                	mv	a0,s1
     bac:	21e040ef          	jal	4dca <read>
     bb0:	4795                	li	a5,5
     bb2:	08f51363          	bne	a0,a5,c38 <unlinkread+0x11a>
  if(buf[0] != 'h'){
     bb6:	0000b717          	auipc	a4,0xb
     bba:	10274703          	lbu	a4,258(a4) # bcb8 <buf>
     bbe:	06800793          	li	a5,104
     bc2:	08f71563          	bne	a4,a5,c4c <unlinkread+0x12e>
  if(write(fd, buf, 10) != 10){
     bc6:	4629                	li	a2,10
     bc8:	0000b597          	auipc	a1,0xb
     bcc:	0f058593          	addi	a1,a1,240 # bcb8 <buf>
     bd0:	8526                	mv	a0,s1
     bd2:	200040ef          	jal	4dd2 <write>
     bd6:	47a9                	li	a5,10
     bd8:	08f51463          	bne	a0,a5,c60 <unlinkread+0x142>
  close(fd);
     bdc:	8526                	mv	a0,s1
     bde:	1fc040ef          	jal	4dda <close>
  unlink("unlinkread");
     be2:	00005517          	auipc	a0,0x5
     be6:	cfe50513          	addi	a0,a0,-770 # 58e0 <malloc+0x632>
     bea:	218040ef          	jal	4e02 <unlink>
}
     bee:	70a2                	ld	ra,40(sp)
     bf0:	7402                	ld	s0,32(sp)
     bf2:	64e2                	ld	s1,24(sp)
     bf4:	6942                	ld	s2,16(sp)
     bf6:	69a2                	ld	s3,8(sp)
     bf8:	6145                	addi	sp,sp,48
     bfa:	8082                	ret
    printf("%s: create unlinkread failed\n", s);
     bfc:	85ce                	mv	a1,s3
     bfe:	00005517          	auipc	a0,0x5
     c02:	cf250513          	addi	a0,a0,-782 # 58f0 <malloc+0x642>
     c06:	5f4040ef          	jal	51fa <printf>
    exit(1);
     c0a:	4505                	li	a0,1
     c0c:	1a6040ef          	jal	4db2 <exit>
    printf("%s: open unlinkread failed\n", s);
     c10:	85ce                	mv	a1,s3
     c12:	00005517          	auipc	a0,0x5
     c16:	d0650513          	addi	a0,a0,-762 # 5918 <malloc+0x66a>
     c1a:	5e0040ef          	jal	51fa <printf>
    exit(1);
     c1e:	4505                	li	a0,1
     c20:	192040ef          	jal	4db2 <exit>
    printf("%s: unlink unlinkread failed\n", s);
     c24:	85ce                	mv	a1,s3
     c26:	00005517          	auipc	a0,0x5
     c2a:	d1250513          	addi	a0,a0,-750 # 5938 <malloc+0x68a>
     c2e:	5cc040ef          	jal	51fa <printf>
    exit(1);
     c32:	4505                	li	a0,1
     c34:	17e040ef          	jal	4db2 <exit>
    printf("%s: unlinkread read failed", s);
     c38:	85ce                	mv	a1,s3
     c3a:	00005517          	auipc	a0,0x5
     c3e:	d2650513          	addi	a0,a0,-730 # 5960 <malloc+0x6b2>
     c42:	5b8040ef          	jal	51fa <printf>
    exit(1);
     c46:	4505                	li	a0,1
     c48:	16a040ef          	jal	4db2 <exit>
    printf("%s: unlinkread wrong data\n", s);
     c4c:	85ce                	mv	a1,s3
     c4e:	00005517          	auipc	a0,0x5
     c52:	d3250513          	addi	a0,a0,-718 # 5980 <malloc+0x6d2>
     c56:	5a4040ef          	jal	51fa <printf>
    exit(1);
     c5a:	4505                	li	a0,1
     c5c:	156040ef          	jal	4db2 <exit>
    printf("%s: unlinkread write failed\n", s);
     c60:	85ce                	mv	a1,s3
     c62:	00005517          	auipc	a0,0x5
     c66:	d3e50513          	addi	a0,a0,-706 # 59a0 <malloc+0x6f2>
     c6a:	590040ef          	jal	51fa <printf>
    exit(1);
     c6e:	4505                	li	a0,1
     c70:	142040ef          	jal	4db2 <exit>

0000000000000c74 <linktest>:
{
     c74:	1101                	addi	sp,sp,-32
     c76:	ec06                	sd	ra,24(sp)
     c78:	e822                	sd	s0,16(sp)
     c7a:	e426                	sd	s1,8(sp)
     c7c:	e04a                	sd	s2,0(sp)
     c7e:	1000                	addi	s0,sp,32
     c80:	892a                	mv	s2,a0
  unlink("lf1");
     c82:	00005517          	auipc	a0,0x5
     c86:	d3e50513          	addi	a0,a0,-706 # 59c0 <malloc+0x712>
     c8a:	178040ef          	jal	4e02 <unlink>
  unlink("lf2");
     c8e:	00005517          	auipc	a0,0x5
     c92:	d3a50513          	addi	a0,a0,-710 # 59c8 <malloc+0x71a>
     c96:	16c040ef          	jal	4e02 <unlink>
  fd = open("lf1", O_CREATE|O_RDWR);
     c9a:	20200593          	li	a1,514
     c9e:	00005517          	auipc	a0,0x5
     ca2:	d2250513          	addi	a0,a0,-734 # 59c0 <malloc+0x712>
     ca6:	14c040ef          	jal	4df2 <open>
  if(fd < 0){
     caa:	0c054f63          	bltz	a0,d88 <linktest+0x114>
     cae:	84aa                	mv	s1,a0
  if(write(fd, "hello", SZ) != SZ){
     cb0:	4615                	li	a2,5
     cb2:	00005597          	auipc	a1,0x5
     cb6:	c5e58593          	addi	a1,a1,-930 # 5910 <malloc+0x662>
     cba:	118040ef          	jal	4dd2 <write>
     cbe:	4795                	li	a5,5
     cc0:	0cf51e63          	bne	a0,a5,d9c <linktest+0x128>
  close(fd);
     cc4:	8526                	mv	a0,s1
     cc6:	114040ef          	jal	4dda <close>
  if(link("lf1", "lf2") < 0){
     cca:	00005597          	auipc	a1,0x5
     cce:	cfe58593          	addi	a1,a1,-770 # 59c8 <malloc+0x71a>
     cd2:	00005517          	auipc	a0,0x5
     cd6:	cee50513          	addi	a0,a0,-786 # 59c0 <malloc+0x712>
     cda:	138040ef          	jal	4e12 <link>
     cde:	0c054963          	bltz	a0,db0 <linktest+0x13c>
  unlink("lf1");
     ce2:	00005517          	auipc	a0,0x5
     ce6:	cde50513          	addi	a0,a0,-802 # 59c0 <malloc+0x712>
     cea:	118040ef          	jal	4e02 <unlink>
  if(open("lf1", 0) >= 0){
     cee:	4581                	li	a1,0
     cf0:	00005517          	auipc	a0,0x5
     cf4:	cd050513          	addi	a0,a0,-816 # 59c0 <malloc+0x712>
     cf8:	0fa040ef          	jal	4df2 <open>
     cfc:	0c055463          	bgez	a0,dc4 <linktest+0x150>
  fd = open("lf2", 0);
     d00:	4581                	li	a1,0
     d02:	00005517          	auipc	a0,0x5
     d06:	cc650513          	addi	a0,a0,-826 # 59c8 <malloc+0x71a>
     d0a:	0e8040ef          	jal	4df2 <open>
     d0e:	84aa                	mv	s1,a0
  if(fd < 0){
     d10:	0c054463          	bltz	a0,dd8 <linktest+0x164>
  if(read(fd, buf, sizeof(buf)) != SZ){
     d14:	660d                	lui	a2,0x3
     d16:	0000b597          	auipc	a1,0xb
     d1a:	fa258593          	addi	a1,a1,-94 # bcb8 <buf>
     d1e:	0ac040ef          	jal	4dca <read>
     d22:	4795                	li	a5,5
     d24:	0cf51463          	bne	a0,a5,dec <linktest+0x178>
  close(fd);
     d28:	8526                	mv	a0,s1
     d2a:	0b0040ef          	jal	4dda <close>
  if(link("lf2", "lf2") >= 0){
     d2e:	00005597          	auipc	a1,0x5
     d32:	c9a58593          	addi	a1,a1,-870 # 59c8 <malloc+0x71a>
     d36:	852e                	mv	a0,a1
     d38:	0da040ef          	jal	4e12 <link>
     d3c:	0c055263          	bgez	a0,e00 <linktest+0x18c>
  unlink("lf2");
     d40:	00005517          	auipc	a0,0x5
     d44:	c8850513          	addi	a0,a0,-888 # 59c8 <malloc+0x71a>
     d48:	0ba040ef          	jal	4e02 <unlink>
  if(link("lf2", "lf1") >= 0){
     d4c:	00005597          	auipc	a1,0x5
     d50:	c7458593          	addi	a1,a1,-908 # 59c0 <malloc+0x712>
     d54:	00005517          	auipc	a0,0x5
     d58:	c7450513          	addi	a0,a0,-908 # 59c8 <malloc+0x71a>
     d5c:	0b6040ef          	jal	4e12 <link>
     d60:	0a055a63          	bgez	a0,e14 <linktest+0x1a0>
  if(link(".", "lf1") >= 0){
     d64:	00005597          	auipc	a1,0x5
     d68:	c5c58593          	addi	a1,a1,-932 # 59c0 <malloc+0x712>
     d6c:	00005517          	auipc	a0,0x5
     d70:	d6450513          	addi	a0,a0,-668 # 5ad0 <malloc+0x822>
     d74:	09e040ef          	jal	4e12 <link>
     d78:	0a055863          	bgez	a0,e28 <linktest+0x1b4>
}
     d7c:	60e2                	ld	ra,24(sp)
     d7e:	6442                	ld	s0,16(sp)
     d80:	64a2                	ld	s1,8(sp)
     d82:	6902                	ld	s2,0(sp)
     d84:	6105                	addi	sp,sp,32
     d86:	8082                	ret
    printf("%s: create lf1 failed\n", s);
     d88:	85ca                	mv	a1,s2
     d8a:	00005517          	auipc	a0,0x5
     d8e:	c4650513          	addi	a0,a0,-954 # 59d0 <malloc+0x722>
     d92:	468040ef          	jal	51fa <printf>
    exit(1);
     d96:	4505                	li	a0,1
     d98:	01a040ef          	jal	4db2 <exit>
    printf("%s: write lf1 failed\n", s);
     d9c:	85ca                	mv	a1,s2
     d9e:	00005517          	auipc	a0,0x5
     da2:	c4a50513          	addi	a0,a0,-950 # 59e8 <malloc+0x73a>
     da6:	454040ef          	jal	51fa <printf>
    exit(1);
     daa:	4505                	li	a0,1
     dac:	006040ef          	jal	4db2 <exit>
    printf("%s: link lf1 lf2 failed\n", s);
     db0:	85ca                	mv	a1,s2
     db2:	00005517          	auipc	a0,0x5
     db6:	c4e50513          	addi	a0,a0,-946 # 5a00 <malloc+0x752>
     dba:	440040ef          	jal	51fa <printf>
    exit(1);
     dbe:	4505                	li	a0,1
     dc0:	7f3030ef          	jal	4db2 <exit>
    printf("%s: unlinked lf1 but it is still there!\n", s);
     dc4:	85ca                	mv	a1,s2
     dc6:	00005517          	auipc	a0,0x5
     dca:	c5a50513          	addi	a0,a0,-934 # 5a20 <malloc+0x772>
     dce:	42c040ef          	jal	51fa <printf>
    exit(1);
     dd2:	4505                	li	a0,1
     dd4:	7df030ef          	jal	4db2 <exit>
    printf("%s: open lf2 failed\n", s);
     dd8:	85ca                	mv	a1,s2
     dda:	00005517          	auipc	a0,0x5
     dde:	c7650513          	addi	a0,a0,-906 # 5a50 <malloc+0x7a2>
     de2:	418040ef          	jal	51fa <printf>
    exit(1);
     de6:	4505                	li	a0,1
     de8:	7cb030ef          	jal	4db2 <exit>
    printf("%s: read lf2 failed\n", s);
     dec:	85ca                	mv	a1,s2
     dee:	00005517          	auipc	a0,0x5
     df2:	c7a50513          	addi	a0,a0,-902 # 5a68 <malloc+0x7ba>
     df6:	404040ef          	jal	51fa <printf>
    exit(1);
     dfa:	4505                	li	a0,1
     dfc:	7b7030ef          	jal	4db2 <exit>
    printf("%s: link lf2 lf2 succeeded! oops\n", s);
     e00:	85ca                	mv	a1,s2
     e02:	00005517          	auipc	a0,0x5
     e06:	c7e50513          	addi	a0,a0,-898 # 5a80 <malloc+0x7d2>
     e0a:	3f0040ef          	jal	51fa <printf>
    exit(1);
     e0e:	4505                	li	a0,1
     e10:	7a3030ef          	jal	4db2 <exit>
    printf("%s: link non-existent succeeded! oops\n", s);
     e14:	85ca                	mv	a1,s2
     e16:	00005517          	auipc	a0,0x5
     e1a:	c9250513          	addi	a0,a0,-878 # 5aa8 <malloc+0x7fa>
     e1e:	3dc040ef          	jal	51fa <printf>
    exit(1);
     e22:	4505                	li	a0,1
     e24:	78f030ef          	jal	4db2 <exit>
    printf("%s: link . lf1 succeeded! oops\n", s);
     e28:	85ca                	mv	a1,s2
     e2a:	00005517          	auipc	a0,0x5
     e2e:	cae50513          	addi	a0,a0,-850 # 5ad8 <malloc+0x82a>
     e32:	3c8040ef          	jal	51fa <printf>
    exit(1);
     e36:	4505                	li	a0,1
     e38:	77b030ef          	jal	4db2 <exit>

0000000000000e3c <validatetest>:
{
     e3c:	7139                	addi	sp,sp,-64
     e3e:	fc06                	sd	ra,56(sp)
     e40:	f822                	sd	s0,48(sp)
     e42:	f426                	sd	s1,40(sp)
     e44:	f04a                	sd	s2,32(sp)
     e46:	ec4e                	sd	s3,24(sp)
     e48:	e852                	sd	s4,16(sp)
     e4a:	e456                	sd	s5,8(sp)
     e4c:	e05a                	sd	s6,0(sp)
     e4e:	0080                	addi	s0,sp,64
     e50:	8b2a                	mv	s6,a0
  for(p = 0; p <= (uint)hi; p += PGSIZE){
     e52:	4481                	li	s1,0
    if(link("nosuchfile", (char*)p) != -1){
     e54:	00005997          	auipc	s3,0x5
     e58:	ca498993          	addi	s3,s3,-860 # 5af8 <malloc+0x84a>
     e5c:	597d                	li	s2,-1
  for(p = 0; p <= (uint)hi; p += PGSIZE){
     e5e:	6a85                	lui	s5,0x1
     e60:	00114a37          	lui	s4,0x114
    if(link("nosuchfile", (char*)p) != -1){
     e64:	85a6                	mv	a1,s1
     e66:	854e                	mv	a0,s3
     e68:	7ab030ef          	jal	4e12 <link>
     e6c:	01251f63          	bne	a0,s2,e8a <validatetest+0x4e>
  for(p = 0; p <= (uint)hi; p += PGSIZE){
     e70:	94d6                	add	s1,s1,s5
     e72:	ff4499e3          	bne	s1,s4,e64 <validatetest+0x28>
}
     e76:	70e2                	ld	ra,56(sp)
     e78:	7442                	ld	s0,48(sp)
     e7a:	74a2                	ld	s1,40(sp)
     e7c:	7902                	ld	s2,32(sp)
     e7e:	69e2                	ld	s3,24(sp)
     e80:	6a42                	ld	s4,16(sp)
     e82:	6aa2                	ld	s5,8(sp)
     e84:	6b02                	ld	s6,0(sp)
     e86:	6121                	addi	sp,sp,64
     e88:	8082                	ret
      printf("%s: link should not succeed\n", s);
     e8a:	85da                	mv	a1,s6
     e8c:	00005517          	auipc	a0,0x5
     e90:	c7c50513          	addi	a0,a0,-900 # 5b08 <malloc+0x85a>
     e94:	366040ef          	jal	51fa <printf>
      exit(1);
     e98:	4505                	li	a0,1
     e9a:	719030ef          	jal	4db2 <exit>

0000000000000e9e <bigdir>:
{
     e9e:	715d                	addi	sp,sp,-80
     ea0:	e486                	sd	ra,72(sp)
     ea2:	e0a2                	sd	s0,64(sp)
     ea4:	fc26                	sd	s1,56(sp)
     ea6:	f84a                	sd	s2,48(sp)
     ea8:	f44e                	sd	s3,40(sp)
     eaa:	f052                	sd	s4,32(sp)
     eac:	ec56                	sd	s5,24(sp)
     eae:	e85a                	sd	s6,16(sp)
     eb0:	0880                	addi	s0,sp,80
     eb2:	89aa                	mv	s3,a0
  unlink("bd");
     eb4:	00005517          	auipc	a0,0x5
     eb8:	c7450513          	addi	a0,a0,-908 # 5b28 <malloc+0x87a>
     ebc:	747030ef          	jal	4e02 <unlink>
  fd = open("bd", O_CREATE);
     ec0:	20000593          	li	a1,512
     ec4:	00005517          	auipc	a0,0x5
     ec8:	c6450513          	addi	a0,a0,-924 # 5b28 <malloc+0x87a>
     ecc:	727030ef          	jal	4df2 <open>
  if(fd < 0){
     ed0:	0c054163          	bltz	a0,f92 <bigdir+0xf4>
  close(fd);
     ed4:	707030ef          	jal	4dda <close>
  for(i = 0; i < N; i++){
     ed8:	4901                	li	s2,0
    name[0] = 'x';
     eda:	07800a93          	li	s5,120
    if(link("bd", name) != 0){
     ede:	00005a17          	auipc	s4,0x5
     ee2:	c4aa0a13          	addi	s4,s4,-950 # 5b28 <malloc+0x87a>
  for(i = 0; i < N; i++){
     ee6:	1f400b13          	li	s6,500
    name[0] = 'x';
     eea:	fb540823          	sb	s5,-80(s0)
    name[1] = '0' + (i / 64);
     eee:	41f9571b          	sraiw	a4,s2,0x1f
     ef2:	01a7571b          	srliw	a4,a4,0x1a
     ef6:	012707bb          	addw	a5,a4,s2
     efa:	4067d69b          	sraiw	a3,a5,0x6
     efe:	0306869b          	addiw	a3,a3,48
     f02:	fad408a3          	sb	a3,-79(s0)
    name[2] = '0' + (i % 64);
     f06:	03f7f793          	andi	a5,a5,63
     f0a:	9f99                	subw	a5,a5,a4
     f0c:	0307879b          	addiw	a5,a5,48
     f10:	faf40923          	sb	a5,-78(s0)
    name[3] = '\0';
     f14:	fa0409a3          	sb	zero,-77(s0)
    if(link("bd", name) != 0){
     f18:	fb040593          	addi	a1,s0,-80
     f1c:	8552                	mv	a0,s4
     f1e:	6f5030ef          	jal	4e12 <link>
     f22:	84aa                	mv	s1,a0
     f24:	e149                	bnez	a0,fa6 <bigdir+0x108>
  for(i = 0; i < N; i++){
     f26:	2905                	addiw	s2,s2,1
     f28:	fd6911e3          	bne	s2,s6,eea <bigdir+0x4c>
  unlink("bd");
     f2c:	00005517          	auipc	a0,0x5
     f30:	bfc50513          	addi	a0,a0,-1028 # 5b28 <malloc+0x87a>
     f34:	6cf030ef          	jal	4e02 <unlink>
    name[0] = 'x';
     f38:	07800913          	li	s2,120
  for(i = 0; i < N; i++){
     f3c:	1f400a13          	li	s4,500
    name[0] = 'x';
     f40:	fb240823          	sb	s2,-80(s0)
    name[1] = '0' + (i / 64);
     f44:	41f4d71b          	sraiw	a4,s1,0x1f
     f48:	01a7571b          	srliw	a4,a4,0x1a
     f4c:	009707bb          	addw	a5,a4,s1
     f50:	4067d69b          	sraiw	a3,a5,0x6
     f54:	0306869b          	addiw	a3,a3,48
     f58:	fad408a3          	sb	a3,-79(s0)
    name[2] = '0' + (i % 64);
     f5c:	03f7f793          	andi	a5,a5,63
     f60:	9f99                	subw	a5,a5,a4
     f62:	0307879b          	addiw	a5,a5,48
     f66:	faf40923          	sb	a5,-78(s0)
    name[3] = '\0';
     f6a:	fa0409a3          	sb	zero,-77(s0)
    if(unlink(name) != 0){
     f6e:	fb040513          	addi	a0,s0,-80
     f72:	691030ef          	jal	4e02 <unlink>
     f76:	e529                	bnez	a0,fc0 <bigdir+0x122>
  for(i = 0; i < N; i++){
     f78:	2485                	addiw	s1,s1,1
     f7a:	fd4493e3          	bne	s1,s4,f40 <bigdir+0xa2>
}
     f7e:	60a6                	ld	ra,72(sp)
     f80:	6406                	ld	s0,64(sp)
     f82:	74e2                	ld	s1,56(sp)
     f84:	7942                	ld	s2,48(sp)
     f86:	79a2                	ld	s3,40(sp)
     f88:	7a02                	ld	s4,32(sp)
     f8a:	6ae2                	ld	s5,24(sp)
     f8c:	6b42                	ld	s6,16(sp)
     f8e:	6161                	addi	sp,sp,80
     f90:	8082                	ret
    printf("%s: bigdir create failed\n", s);
     f92:	85ce                	mv	a1,s3
     f94:	00005517          	auipc	a0,0x5
     f98:	b9c50513          	addi	a0,a0,-1124 # 5b30 <malloc+0x882>
     f9c:	25e040ef          	jal	51fa <printf>
    exit(1);
     fa0:	4505                	li	a0,1
     fa2:	611030ef          	jal	4db2 <exit>
      printf("%s: bigdir i=%d link(bd, %s) failed\n", s, i, name);
     fa6:	fb040693          	addi	a3,s0,-80
     faa:	864a                	mv	a2,s2
     fac:	85ce                	mv	a1,s3
     fae:	00005517          	auipc	a0,0x5
     fb2:	ba250513          	addi	a0,a0,-1118 # 5b50 <malloc+0x8a2>
     fb6:	244040ef          	jal	51fa <printf>
      exit(1);
     fba:	4505                	li	a0,1
     fbc:	5f7030ef          	jal	4db2 <exit>
      printf("%s: bigdir unlink failed", s);
     fc0:	85ce                	mv	a1,s3
     fc2:	00005517          	auipc	a0,0x5
     fc6:	bb650513          	addi	a0,a0,-1098 # 5b78 <malloc+0x8ca>
     fca:	230040ef          	jal	51fa <printf>
      exit(1);
     fce:	4505                	li	a0,1
     fd0:	5e3030ef          	jal	4db2 <exit>

0000000000000fd4 <pgbug>:
{
     fd4:	7179                	addi	sp,sp,-48
     fd6:	f406                	sd	ra,40(sp)
     fd8:	f022                	sd	s0,32(sp)
     fda:	ec26                	sd	s1,24(sp)
     fdc:	1800                	addi	s0,sp,48
  argv[0] = 0;
     fde:	fc043c23          	sd	zero,-40(s0)
  exec(big, argv);
     fe2:	00007497          	auipc	s1,0x7
     fe6:	01e48493          	addi	s1,s1,30 # 8000 <big>
     fea:	fd840593          	addi	a1,s0,-40
     fee:	6088                	ld	a0,0(s1)
     ff0:	5fb030ef          	jal	4dea <exec>
  pipe(big);
     ff4:	6088                	ld	a0,0(s1)
     ff6:	5cd030ef          	jal	4dc2 <pipe>
  exit(0);
     ffa:	4501                	li	a0,0
     ffc:	5b7030ef          	jal	4db2 <exit>

0000000000001000 <badarg>:
{
    1000:	7139                	addi	sp,sp,-64
    1002:	fc06                	sd	ra,56(sp)
    1004:	f822                	sd	s0,48(sp)
    1006:	f426                	sd	s1,40(sp)
    1008:	f04a                	sd	s2,32(sp)
    100a:	ec4e                	sd	s3,24(sp)
    100c:	0080                	addi	s0,sp,64
    100e:	64b1                	lui	s1,0xc
    1010:	35048493          	addi	s1,s1,848 # c350 <buf+0x698>
    argv[0] = (char*)0xffffffff;
    1014:	597d                	li	s2,-1
    1016:	02095913          	srli	s2,s2,0x20
    exec("echo", argv);
    101a:	00004997          	auipc	s3,0x4
    101e:	3ce98993          	addi	s3,s3,974 # 53e8 <malloc+0x13a>
    argv[0] = (char*)0xffffffff;
    1022:	fd243023          	sd	s2,-64(s0)
    argv[1] = 0;
    1026:	fc043423          	sd	zero,-56(s0)
    exec("echo", argv);
    102a:	fc040593          	addi	a1,s0,-64
    102e:	854e                	mv	a0,s3
    1030:	5bb030ef          	jal	4dea <exec>
  for(int i = 0; i < 50000; i++){
    1034:	34fd                	addiw	s1,s1,-1
    1036:	f4f5                	bnez	s1,1022 <badarg+0x22>
  exit(0);
    1038:	4501                	li	a0,0
    103a:	579030ef          	jal	4db2 <exit>

000000000000103e <copyinstr2>:
{
    103e:	7155                	addi	sp,sp,-208
    1040:	e586                	sd	ra,200(sp)
    1042:	e1a2                	sd	s0,192(sp)
    1044:	0980                	addi	s0,sp,208
  for(int i = 0; i < MAXPATH; i++)
    1046:	f6840793          	addi	a5,s0,-152
    104a:	fe840693          	addi	a3,s0,-24
    b[i] = 'x';
    104e:	07800713          	li	a4,120
    1052:	00e78023          	sb	a4,0(a5)
  for(int i = 0; i < MAXPATH; i++)
    1056:	0785                	addi	a5,a5,1
    1058:	fed79de3          	bne	a5,a3,1052 <copyinstr2+0x14>
  b[MAXPATH] = '\0';
    105c:	fe040423          	sb	zero,-24(s0)
  int ret = unlink(b);
    1060:	f6840513          	addi	a0,s0,-152
    1064:	59f030ef          	jal	4e02 <unlink>
  if(ret != -1){
    1068:	57fd                	li	a5,-1
    106a:	0cf51263          	bne	a0,a5,112e <copyinstr2+0xf0>
  int fd = open(b, O_CREATE | O_WRONLY);
    106e:	20100593          	li	a1,513
    1072:	f6840513          	addi	a0,s0,-152
    1076:	57d030ef          	jal	4df2 <open>
  if(fd != -1){
    107a:	57fd                	li	a5,-1
    107c:	0cf51563          	bne	a0,a5,1146 <copyinstr2+0x108>
  ret = link(b, b);
    1080:	f6840593          	addi	a1,s0,-152
    1084:	852e                	mv	a0,a1
    1086:	58d030ef          	jal	4e12 <link>
  if(ret != -1){
    108a:	57fd                	li	a5,-1
    108c:	0cf51963          	bne	a0,a5,115e <copyinstr2+0x120>
  char *args[] = { "xx", 0 };
    1090:	00006797          	auipc	a5,0x6
    1094:	c3878793          	addi	a5,a5,-968 # 6cc8 <malloc+0x1a1a>
    1098:	f4f43c23          	sd	a5,-168(s0)
    109c:	f6043023          	sd	zero,-160(s0)
  ret = exec(b, args);
    10a0:	f5840593          	addi	a1,s0,-168
    10a4:	f6840513          	addi	a0,s0,-152
    10a8:	543030ef          	jal	4dea <exec>
  if(ret != -1){
    10ac:	57fd                	li	a5,-1
    10ae:	0cf51563          	bne	a0,a5,1178 <copyinstr2+0x13a>
  int pid = fork();
    10b2:	4f9030ef          	jal	4daa <fork>
  if(pid < 0){
    10b6:	0c054d63          	bltz	a0,1190 <copyinstr2+0x152>
  if(pid == 0){
    10ba:	0e051863          	bnez	a0,11aa <copyinstr2+0x16c>
    10be:	00007797          	auipc	a5,0x7
    10c2:	4e278793          	addi	a5,a5,1250 # 85a0 <big.0>
    10c6:	00008697          	auipc	a3,0x8
    10ca:	4da68693          	addi	a3,a3,1242 # 95a0 <big.0+0x1000>
      big[i] = 'x';
    10ce:	07800713          	li	a4,120
    10d2:	00e78023          	sb	a4,0(a5)
    for(int i = 0; i < PGSIZE; i++)
    10d6:	0785                	addi	a5,a5,1
    10d8:	fed79de3          	bne	a5,a3,10d2 <copyinstr2+0x94>
    big[PGSIZE] = '\0';
    10dc:	00008797          	auipc	a5,0x8
    10e0:	4c078223          	sb	zero,1220(a5) # 95a0 <big.0+0x1000>
    char *args2[] = { big, big, big, 0 };
    10e4:	00007797          	auipc	a5,0x7
    10e8:	84c78793          	addi	a5,a5,-1972 # 7930 <malloc+0x2682>
    10ec:	6fb0                	ld	a2,88(a5)
    10ee:	73b4                	ld	a3,96(a5)
    10f0:	77b8                	ld	a4,104(a5)
    10f2:	7bbc                	ld	a5,112(a5)
    10f4:	f2c43823          	sd	a2,-208(s0)
    10f8:	f2d43c23          	sd	a3,-200(s0)
    10fc:	f4e43023          	sd	a4,-192(s0)
    1100:	f4f43423          	sd	a5,-184(s0)
    ret = exec("echo", args2);
    1104:	f3040593          	addi	a1,s0,-208
    1108:	00004517          	auipc	a0,0x4
    110c:	2e050513          	addi	a0,a0,736 # 53e8 <malloc+0x13a>
    1110:	4db030ef          	jal	4dea <exec>
    if(ret != -1){
    1114:	57fd                	li	a5,-1
    1116:	08f50663          	beq	a0,a5,11a2 <copyinstr2+0x164>
      printf("exec(echo, BIG) returned %d, not -1\n", fd);
    111a:	55fd                	li	a1,-1
    111c:	00005517          	auipc	a0,0x5
    1120:	b0450513          	addi	a0,a0,-1276 # 5c20 <malloc+0x972>
    1124:	0d6040ef          	jal	51fa <printf>
      exit(1);
    1128:	4505                	li	a0,1
    112a:	489030ef          	jal	4db2 <exit>
    printf("unlink(%s) returned %d, not -1\n", b, ret);
    112e:	862a                	mv	a2,a0
    1130:	f6840593          	addi	a1,s0,-152
    1134:	00005517          	auipc	a0,0x5
    1138:	a6450513          	addi	a0,a0,-1436 # 5b98 <malloc+0x8ea>
    113c:	0be040ef          	jal	51fa <printf>
    exit(1);
    1140:	4505                	li	a0,1
    1142:	471030ef          	jal	4db2 <exit>
    printf("open(%s) returned %d, not -1\n", b, fd);
    1146:	862a                	mv	a2,a0
    1148:	f6840593          	addi	a1,s0,-152
    114c:	00005517          	auipc	a0,0x5
    1150:	a6c50513          	addi	a0,a0,-1428 # 5bb8 <malloc+0x90a>
    1154:	0a6040ef          	jal	51fa <printf>
    exit(1);
    1158:	4505                	li	a0,1
    115a:	459030ef          	jal	4db2 <exit>
    printf("link(%s, %s) returned %d, not -1\n", b, b, ret);
    115e:	86aa                	mv	a3,a0
    1160:	f6840613          	addi	a2,s0,-152
    1164:	85b2                	mv	a1,a2
    1166:	00005517          	auipc	a0,0x5
    116a:	a7250513          	addi	a0,a0,-1422 # 5bd8 <malloc+0x92a>
    116e:	08c040ef          	jal	51fa <printf>
    exit(1);
    1172:	4505                	li	a0,1
    1174:	43f030ef          	jal	4db2 <exit>
    printf("exec(%s) returned %d, not -1\n", b, fd);
    1178:	567d                	li	a2,-1
    117a:	f6840593          	addi	a1,s0,-152
    117e:	00005517          	auipc	a0,0x5
    1182:	a8250513          	addi	a0,a0,-1406 # 5c00 <malloc+0x952>
    1186:	074040ef          	jal	51fa <printf>
    exit(1);
    118a:	4505                	li	a0,1
    118c:	427030ef          	jal	4db2 <exit>
    printf("fork failed\n");
    1190:	00006517          	auipc	a0,0x6
    1194:	09050513          	addi	a0,a0,144 # 7220 <malloc+0x1f72>
    1198:	062040ef          	jal	51fa <printf>
    exit(1);
    119c:	4505                	li	a0,1
    119e:	415030ef          	jal	4db2 <exit>
    exit(747); // OK
    11a2:	2eb00513          	li	a0,747
    11a6:	40d030ef          	jal	4db2 <exit>
  int st = 0;
    11aa:	f4042a23          	sw	zero,-172(s0)
  wait(&st);
    11ae:	f5440513          	addi	a0,s0,-172
    11b2:	409030ef          	jal	4dba <wait>
  if(st != 747){
    11b6:	f5442703          	lw	a4,-172(s0)
    11ba:	2eb00793          	li	a5,747
    11be:	00f71663          	bne	a4,a5,11ca <copyinstr2+0x18c>
}
    11c2:	60ae                	ld	ra,200(sp)
    11c4:	640e                	ld	s0,192(sp)
    11c6:	6169                	addi	sp,sp,208
    11c8:	8082                	ret
    printf("exec(echo, BIG) succeeded, should have failed\n");
    11ca:	00005517          	auipc	a0,0x5
    11ce:	a7e50513          	addi	a0,a0,-1410 # 5c48 <malloc+0x99a>
    11d2:	028040ef          	jal	51fa <printf>
    exit(1);
    11d6:	4505                	li	a0,1
    11d8:	3db030ef          	jal	4db2 <exit>

00000000000011dc <truncate3>:
{
    11dc:	7159                	addi	sp,sp,-112
    11de:	f486                	sd	ra,104(sp)
    11e0:	f0a2                	sd	s0,96(sp)
    11e2:	e8ca                	sd	s2,80(sp)
    11e4:	1880                	addi	s0,sp,112
    11e6:	892a                	mv	s2,a0
  close(open("truncfile", O_CREATE|O_TRUNC|O_WRONLY));
    11e8:	60100593          	li	a1,1537
    11ec:	00004517          	auipc	a0,0x4
    11f0:	25450513          	addi	a0,a0,596 # 5440 <malloc+0x192>
    11f4:	3ff030ef          	jal	4df2 <open>
    11f8:	3e3030ef          	jal	4dda <close>
  pid = fork();
    11fc:	3af030ef          	jal	4daa <fork>
  if(pid < 0){
    1200:	06054663          	bltz	a0,126c <truncate3+0x90>
  if(pid == 0){
    1204:	e55d                	bnez	a0,12b2 <truncate3+0xd6>
    1206:	eca6                	sd	s1,88(sp)
    1208:	e4ce                	sd	s3,72(sp)
    120a:	e0d2                	sd	s4,64(sp)
    120c:	fc56                	sd	s5,56(sp)
    120e:	06400993          	li	s3,100
      int fd = open("truncfile", O_WRONLY);
    1212:	00004a17          	auipc	s4,0x4
    1216:	22ea0a13          	addi	s4,s4,558 # 5440 <malloc+0x192>
      int n = write(fd, "1234567890", 10);
    121a:	00005a97          	auipc	s5,0x5
    121e:	a8ea8a93          	addi	s5,s5,-1394 # 5ca8 <malloc+0x9fa>
      int fd = open("truncfile", O_WRONLY);
    1222:	4585                	li	a1,1
    1224:	8552                	mv	a0,s4
    1226:	3cd030ef          	jal	4df2 <open>
    122a:	84aa                	mv	s1,a0
      if(fd < 0){
    122c:	04054e63          	bltz	a0,1288 <truncate3+0xac>
      int n = write(fd, "1234567890", 10);
    1230:	4629                	li	a2,10
    1232:	85d6                	mv	a1,s5
    1234:	39f030ef          	jal	4dd2 <write>
      if(n != 10){
    1238:	47a9                	li	a5,10
    123a:	06f51163          	bne	a0,a5,129c <truncate3+0xc0>
      close(fd);
    123e:	8526                	mv	a0,s1
    1240:	39b030ef          	jal	4dda <close>
      fd = open("truncfile", O_RDONLY);
    1244:	4581                	li	a1,0
    1246:	8552                	mv	a0,s4
    1248:	3ab030ef          	jal	4df2 <open>
    124c:	84aa                	mv	s1,a0
      read(fd, buf, sizeof(buf));
    124e:	02000613          	li	a2,32
    1252:	f9840593          	addi	a1,s0,-104
    1256:	375030ef          	jal	4dca <read>
      close(fd);
    125a:	8526                	mv	a0,s1
    125c:	37f030ef          	jal	4dda <close>
    for(int i = 0; i < 100; i++){
    1260:	39fd                	addiw	s3,s3,-1
    1262:	fc0990e3          	bnez	s3,1222 <truncate3+0x46>
    exit(0);
    1266:	4501                	li	a0,0
    1268:	34b030ef          	jal	4db2 <exit>
    126c:	eca6                	sd	s1,88(sp)
    126e:	e4ce                	sd	s3,72(sp)
    1270:	e0d2                	sd	s4,64(sp)
    1272:	fc56                	sd	s5,56(sp)
    printf("%s: fork failed\n", s);
    1274:	85ca                	mv	a1,s2
    1276:	00005517          	auipc	a0,0x5
    127a:	a0250513          	addi	a0,a0,-1534 # 5c78 <malloc+0x9ca>
    127e:	77d030ef          	jal	51fa <printf>
    exit(1);
    1282:	4505                	li	a0,1
    1284:	32f030ef          	jal	4db2 <exit>
        printf("%s: open failed\n", s);
    1288:	85ca                	mv	a1,s2
    128a:	00005517          	auipc	a0,0x5
    128e:	a0650513          	addi	a0,a0,-1530 # 5c90 <malloc+0x9e2>
    1292:	769030ef          	jal	51fa <printf>
        exit(1);
    1296:	4505                	li	a0,1
    1298:	31b030ef          	jal	4db2 <exit>
        printf("%s: write got %d, expected 10\n", s, n);
    129c:	862a                	mv	a2,a0
    129e:	85ca                	mv	a1,s2
    12a0:	00005517          	auipc	a0,0x5
    12a4:	a1850513          	addi	a0,a0,-1512 # 5cb8 <malloc+0xa0a>
    12a8:	753030ef          	jal	51fa <printf>
        exit(1);
    12ac:	4505                	li	a0,1
    12ae:	305030ef          	jal	4db2 <exit>
    12b2:	eca6                	sd	s1,88(sp)
    12b4:	e4ce                	sd	s3,72(sp)
    12b6:	e0d2                	sd	s4,64(sp)
    12b8:	fc56                	sd	s5,56(sp)
    12ba:	09600993          	li	s3,150
    int fd = open("truncfile", O_CREATE|O_WRONLY|O_TRUNC);
    12be:	00004a17          	auipc	s4,0x4
    12c2:	182a0a13          	addi	s4,s4,386 # 5440 <malloc+0x192>
    int n = write(fd, "xxx", 3);
    12c6:	00005a97          	auipc	s5,0x5
    12ca:	a12a8a93          	addi	s5,s5,-1518 # 5cd8 <malloc+0xa2a>
    int fd = open("truncfile", O_CREATE|O_WRONLY|O_TRUNC);
    12ce:	60100593          	li	a1,1537
    12d2:	8552                	mv	a0,s4
    12d4:	31f030ef          	jal	4df2 <open>
    12d8:	84aa                	mv	s1,a0
    if(fd < 0){
    12da:	02054d63          	bltz	a0,1314 <truncate3+0x138>
    int n = write(fd, "xxx", 3);
    12de:	460d                	li	a2,3
    12e0:	85d6                	mv	a1,s5
    12e2:	2f1030ef          	jal	4dd2 <write>
    if(n != 3){
    12e6:	478d                	li	a5,3
    12e8:	04f51063          	bne	a0,a5,1328 <truncate3+0x14c>
    close(fd);
    12ec:	8526                	mv	a0,s1
    12ee:	2ed030ef          	jal	4dda <close>
  for(int i = 0; i < 150; i++){
    12f2:	39fd                	addiw	s3,s3,-1
    12f4:	fc099de3          	bnez	s3,12ce <truncate3+0xf2>
  wait(&xstatus);
    12f8:	fbc40513          	addi	a0,s0,-68
    12fc:	2bf030ef          	jal	4dba <wait>
  unlink("truncfile");
    1300:	00004517          	auipc	a0,0x4
    1304:	14050513          	addi	a0,a0,320 # 5440 <malloc+0x192>
    1308:	2fb030ef          	jal	4e02 <unlink>
  exit(xstatus);
    130c:	fbc42503          	lw	a0,-68(s0)
    1310:	2a3030ef          	jal	4db2 <exit>
      printf("%s: open failed\n", s);
    1314:	85ca                	mv	a1,s2
    1316:	00005517          	auipc	a0,0x5
    131a:	97a50513          	addi	a0,a0,-1670 # 5c90 <malloc+0x9e2>
    131e:	6dd030ef          	jal	51fa <printf>
      exit(1);
    1322:	4505                	li	a0,1
    1324:	28f030ef          	jal	4db2 <exit>
      printf("%s: write got %d, expected 3\n", s, n);
    1328:	862a                	mv	a2,a0
    132a:	85ca                	mv	a1,s2
    132c:	00005517          	auipc	a0,0x5
    1330:	9b450513          	addi	a0,a0,-1612 # 5ce0 <malloc+0xa32>
    1334:	6c7030ef          	jal	51fa <printf>
      exit(1);
    1338:	4505                	li	a0,1
    133a:	279030ef          	jal	4db2 <exit>

000000000000133e <exectest>:
{
    133e:	715d                	addi	sp,sp,-80
    1340:	e486                	sd	ra,72(sp)
    1342:	e0a2                	sd	s0,64(sp)
    1344:	f84a                	sd	s2,48(sp)
    1346:	0880                	addi	s0,sp,80
    1348:	892a                	mv	s2,a0
  char *echoargv[] = { "echo", "OK", 0 };
    134a:	00004797          	auipc	a5,0x4
    134e:	09e78793          	addi	a5,a5,158 # 53e8 <malloc+0x13a>
    1352:	fcf43023          	sd	a5,-64(s0)
    1356:	00005797          	auipc	a5,0x5
    135a:	9aa78793          	addi	a5,a5,-1622 # 5d00 <malloc+0xa52>
    135e:	fcf43423          	sd	a5,-56(s0)
    1362:	fc043823          	sd	zero,-48(s0)
  unlink("echo-ok");
    1366:	00005517          	auipc	a0,0x5
    136a:	9a250513          	addi	a0,a0,-1630 # 5d08 <malloc+0xa5a>
    136e:	295030ef          	jal	4e02 <unlink>
  pid = fork();
    1372:	239030ef          	jal	4daa <fork>
  if(pid < 0) {
    1376:	02054f63          	bltz	a0,13b4 <exectest+0x76>
    137a:	fc26                	sd	s1,56(sp)
    137c:	84aa                	mv	s1,a0
  if(pid == 0) {
    137e:	e935                	bnez	a0,13f2 <exectest+0xb4>
    close(1);
    1380:	4505                	li	a0,1
    1382:	259030ef          	jal	4dda <close>
    fd = open("echo-ok", O_CREATE|O_WRONLY);
    1386:	20100593          	li	a1,513
    138a:	00005517          	auipc	a0,0x5
    138e:	97e50513          	addi	a0,a0,-1666 # 5d08 <malloc+0xa5a>
    1392:	261030ef          	jal	4df2 <open>
    if(fd < 0) {
    1396:	02054a63          	bltz	a0,13ca <exectest+0x8c>
    if(fd != 1) {
    139a:	4785                	li	a5,1
    139c:	04f50163          	beq	a0,a5,13de <exectest+0xa0>
      printf("%s: wrong fd\n", s);
    13a0:	85ca                	mv	a1,s2
    13a2:	00005517          	auipc	a0,0x5
    13a6:	98650513          	addi	a0,a0,-1658 # 5d28 <malloc+0xa7a>
    13aa:	651030ef          	jal	51fa <printf>
      exit(1);
    13ae:	4505                	li	a0,1
    13b0:	203030ef          	jal	4db2 <exit>
    13b4:	fc26                	sd	s1,56(sp)
     printf("%s: fork failed\n", s);
    13b6:	85ca                	mv	a1,s2
    13b8:	00005517          	auipc	a0,0x5
    13bc:	8c050513          	addi	a0,a0,-1856 # 5c78 <malloc+0x9ca>
    13c0:	63b030ef          	jal	51fa <printf>
     exit(1);
    13c4:	4505                	li	a0,1
    13c6:	1ed030ef          	jal	4db2 <exit>
      printf("%s: create failed\n", s);
    13ca:	85ca                	mv	a1,s2
    13cc:	00005517          	auipc	a0,0x5
    13d0:	94450513          	addi	a0,a0,-1724 # 5d10 <malloc+0xa62>
    13d4:	627030ef          	jal	51fa <printf>
      exit(1);
    13d8:	4505                	li	a0,1
    13da:	1d9030ef          	jal	4db2 <exit>
    if(exec("echo", echoargv) < 0){
    13de:	fc040593          	addi	a1,s0,-64
    13e2:	00004517          	auipc	a0,0x4
    13e6:	00650513          	addi	a0,a0,6 # 53e8 <malloc+0x13a>
    13ea:	201030ef          	jal	4dea <exec>
    13ee:	00054d63          	bltz	a0,1408 <exectest+0xca>
  if (wait(&xstatus) != pid) {
    13f2:	fdc40513          	addi	a0,s0,-36
    13f6:	1c5030ef          	jal	4dba <wait>
    13fa:	02951163          	bne	a0,s1,141c <exectest+0xde>
  if(xstatus != 0)
    13fe:	fdc42503          	lw	a0,-36(s0)
    1402:	c50d                	beqz	a0,142c <exectest+0xee>
    exit(xstatus);
    1404:	1af030ef          	jal	4db2 <exit>
      printf("%s: exec echo failed\n", s);
    1408:	85ca                	mv	a1,s2
    140a:	00005517          	auipc	a0,0x5
    140e:	92e50513          	addi	a0,a0,-1746 # 5d38 <malloc+0xa8a>
    1412:	5e9030ef          	jal	51fa <printf>
      exit(1);
    1416:	4505                	li	a0,1
    1418:	19b030ef          	jal	4db2 <exit>
    printf("%s: wait failed!\n", s);
    141c:	85ca                	mv	a1,s2
    141e:	00005517          	auipc	a0,0x5
    1422:	93250513          	addi	a0,a0,-1742 # 5d50 <malloc+0xaa2>
    1426:	5d5030ef          	jal	51fa <printf>
    142a:	bfd1                	j	13fe <exectest+0xc0>
  fd = open("echo-ok", O_RDONLY);
    142c:	4581                	li	a1,0
    142e:	00005517          	auipc	a0,0x5
    1432:	8da50513          	addi	a0,a0,-1830 # 5d08 <malloc+0xa5a>
    1436:	1bd030ef          	jal	4df2 <open>
  if(fd < 0) {
    143a:	02054463          	bltz	a0,1462 <exectest+0x124>
  if (read(fd, buf, 2) != 2) {
    143e:	4609                	li	a2,2
    1440:	fb840593          	addi	a1,s0,-72
    1444:	187030ef          	jal	4dca <read>
    1448:	4789                	li	a5,2
    144a:	02f50663          	beq	a0,a5,1476 <exectest+0x138>
    printf("%s: read failed\n", s);
    144e:	85ca                	mv	a1,s2
    1450:	00004517          	auipc	a0,0x4
    1454:	36850513          	addi	a0,a0,872 # 57b8 <malloc+0x50a>
    1458:	5a3030ef          	jal	51fa <printf>
    exit(1);
    145c:	4505                	li	a0,1
    145e:	155030ef          	jal	4db2 <exit>
    printf("%s: open failed\n", s);
    1462:	85ca                	mv	a1,s2
    1464:	00005517          	auipc	a0,0x5
    1468:	82c50513          	addi	a0,a0,-2004 # 5c90 <malloc+0x9e2>
    146c:	58f030ef          	jal	51fa <printf>
    exit(1);
    1470:	4505                	li	a0,1
    1472:	141030ef          	jal	4db2 <exit>
  unlink("echo-ok");
    1476:	00005517          	auipc	a0,0x5
    147a:	89250513          	addi	a0,a0,-1902 # 5d08 <malloc+0xa5a>
    147e:	185030ef          	jal	4e02 <unlink>
  if(buf[0] == 'O' && buf[1] == 'K')
    1482:	fb844703          	lbu	a4,-72(s0)
    1486:	04f00793          	li	a5,79
    148a:	00f71863          	bne	a4,a5,149a <exectest+0x15c>
    148e:	fb944703          	lbu	a4,-71(s0)
    1492:	04b00793          	li	a5,75
    1496:	00f70c63          	beq	a4,a5,14ae <exectest+0x170>
    printf("%s: wrong output\n", s);
    149a:	85ca                	mv	a1,s2
    149c:	00005517          	auipc	a0,0x5
    14a0:	8cc50513          	addi	a0,a0,-1844 # 5d68 <malloc+0xaba>
    14a4:	557030ef          	jal	51fa <printf>
    exit(1);
    14a8:	4505                	li	a0,1
    14aa:	109030ef          	jal	4db2 <exit>
    exit(0);
    14ae:	4501                	li	a0,0
    14b0:	103030ef          	jal	4db2 <exit>

00000000000014b4 <pipe1>:
{
    14b4:	711d                	addi	sp,sp,-96
    14b6:	ec86                	sd	ra,88(sp)
    14b8:	e8a2                	sd	s0,80(sp)
    14ba:	fc4e                	sd	s3,56(sp)
    14bc:	1080                	addi	s0,sp,96
    14be:	89aa                	mv	s3,a0
  if(pipe(fds) != 0){
    14c0:	fa840513          	addi	a0,s0,-88
    14c4:	0ff030ef          	jal	4dc2 <pipe>
    14c8:	e92d                	bnez	a0,153a <pipe1+0x86>
    14ca:	e4a6                	sd	s1,72(sp)
    14cc:	f852                	sd	s4,48(sp)
    14ce:	84aa                	mv	s1,a0
  pid = fork();
    14d0:	0db030ef          	jal	4daa <fork>
    14d4:	8a2a                	mv	s4,a0
  if(pid == 0){
    14d6:	c151                	beqz	a0,155a <pipe1+0xa6>
  } else if(pid > 0){
    14d8:	14a05e63          	blez	a0,1634 <pipe1+0x180>
    14dc:	e0ca                	sd	s2,64(sp)
    14de:	f456                	sd	s5,40(sp)
    close(fds[1]);
    14e0:	fac42503          	lw	a0,-84(s0)
    14e4:	0f7030ef          	jal	4dda <close>
    total = 0;
    14e8:	8a26                	mv	s4,s1
    cc = 1;
    14ea:	4905                	li	s2,1
    while((n = read(fds[0], buf, cc)) > 0){
    14ec:	0000aa97          	auipc	s5,0xa
    14f0:	7cca8a93          	addi	s5,s5,1996 # bcb8 <buf>
    14f4:	864a                	mv	a2,s2
    14f6:	85d6                	mv	a1,s5
    14f8:	fa842503          	lw	a0,-88(s0)
    14fc:	0cf030ef          	jal	4dca <read>
    1500:	0ea05a63          	blez	a0,15f4 <pipe1+0x140>
      for(i = 0; i < n; i++){
    1504:	0000a717          	auipc	a4,0xa
    1508:	7b470713          	addi	a4,a4,1972 # bcb8 <buf>
    150c:	00a4863b          	addw	a2,s1,a0
        if((buf[i] & 0xff) != (seq++ & 0xff)){
    1510:	00074683          	lbu	a3,0(a4)
    1514:	0ff4f793          	zext.b	a5,s1
    1518:	2485                	addiw	s1,s1,1
    151a:	0af69d63          	bne	a3,a5,15d4 <pipe1+0x120>
      for(i = 0; i < n; i++){
    151e:	0705                	addi	a4,a4,1
    1520:	fec498e3          	bne	s1,a2,1510 <pipe1+0x5c>
      total += n;
    1524:	00aa0a3b          	addw	s4,s4,a0
      cc = cc * 2;
    1528:	0019179b          	slliw	a5,s2,0x1
    152c:	0007891b          	sext.w	s2,a5
      if(cc > sizeof(buf))
    1530:	670d                	lui	a4,0x3
    1532:	fd2771e3          	bgeu	a4,s2,14f4 <pipe1+0x40>
        cc = sizeof(buf);
    1536:	690d                	lui	s2,0x3
    1538:	bf75                	j	14f4 <pipe1+0x40>
    153a:	e4a6                	sd	s1,72(sp)
    153c:	e0ca                	sd	s2,64(sp)
    153e:	f852                	sd	s4,48(sp)
    1540:	f456                	sd	s5,40(sp)
    1542:	f05a                	sd	s6,32(sp)
    1544:	ec5e                	sd	s7,24(sp)
    printf("%s: pipe() failed\n", s);
    1546:	85ce                	mv	a1,s3
    1548:	00005517          	auipc	a0,0x5
    154c:	83850513          	addi	a0,a0,-1992 # 5d80 <malloc+0xad2>
    1550:	4ab030ef          	jal	51fa <printf>
    exit(1);
    1554:	4505                	li	a0,1
    1556:	05d030ef          	jal	4db2 <exit>
    155a:	e0ca                	sd	s2,64(sp)
    155c:	f456                	sd	s5,40(sp)
    155e:	f05a                	sd	s6,32(sp)
    1560:	ec5e                	sd	s7,24(sp)
    close(fds[0]);
    1562:	fa842503          	lw	a0,-88(s0)
    1566:	075030ef          	jal	4dda <close>
    for(n = 0; n < N; n++){
    156a:	0000ab17          	auipc	s6,0xa
    156e:	74eb0b13          	addi	s6,s6,1870 # bcb8 <buf>
    1572:	416004bb          	negw	s1,s6
    1576:	0ff4f493          	zext.b	s1,s1
    157a:	409b0913          	addi	s2,s6,1033
      if(write(fds[1], buf, SZ) != SZ){
    157e:	8bda                	mv	s7,s6
    for(n = 0; n < N; n++){
    1580:	6a85                	lui	s5,0x1
    1582:	42da8a93          	addi	s5,s5,1069 # 142d <exectest+0xef>
{
    1586:	87da                	mv	a5,s6
        buf[i] = seq++;
    1588:	0097873b          	addw	a4,a5,s1
    158c:	00e78023          	sb	a4,0(a5)
      for(i = 0; i < SZ; i++)
    1590:	0785                	addi	a5,a5,1
    1592:	ff279be3          	bne	a5,s2,1588 <pipe1+0xd4>
    1596:	409a0a1b          	addiw	s4,s4,1033
      if(write(fds[1], buf, SZ) != SZ){
    159a:	40900613          	li	a2,1033
    159e:	85de                	mv	a1,s7
    15a0:	fac42503          	lw	a0,-84(s0)
    15a4:	02f030ef          	jal	4dd2 <write>
    15a8:	40900793          	li	a5,1033
    15ac:	00f51a63          	bne	a0,a5,15c0 <pipe1+0x10c>
    for(n = 0; n < N; n++){
    15b0:	24a5                	addiw	s1,s1,9
    15b2:	0ff4f493          	zext.b	s1,s1
    15b6:	fd5a18e3          	bne	s4,s5,1586 <pipe1+0xd2>
    exit(0);
    15ba:	4501                	li	a0,0
    15bc:	7f6030ef          	jal	4db2 <exit>
        printf("%s: pipe1 oops 1\n", s);
    15c0:	85ce                	mv	a1,s3
    15c2:	00004517          	auipc	a0,0x4
    15c6:	7d650513          	addi	a0,a0,2006 # 5d98 <malloc+0xaea>
    15ca:	431030ef          	jal	51fa <printf>
        exit(1);
    15ce:	4505                	li	a0,1
    15d0:	7e2030ef          	jal	4db2 <exit>
          printf("%s: pipe1 oops 2\n", s);
    15d4:	85ce                	mv	a1,s3
    15d6:	00004517          	auipc	a0,0x4
    15da:	7da50513          	addi	a0,a0,2010 # 5db0 <malloc+0xb02>
    15de:	41d030ef          	jal	51fa <printf>
          return;
    15e2:	64a6                	ld	s1,72(sp)
    15e4:	6906                	ld	s2,64(sp)
    15e6:	7a42                	ld	s4,48(sp)
    15e8:	7aa2                	ld	s5,40(sp)
}
    15ea:	60e6                	ld	ra,88(sp)
    15ec:	6446                	ld	s0,80(sp)
    15ee:	79e2                	ld	s3,56(sp)
    15f0:	6125                	addi	sp,sp,96
    15f2:	8082                	ret
    if(total != N * SZ){
    15f4:	6785                	lui	a5,0x1
    15f6:	42d78793          	addi	a5,a5,1069 # 142d <exectest+0xef>
    15fa:	00fa0f63          	beq	s4,a5,1618 <pipe1+0x164>
    15fe:	f05a                	sd	s6,32(sp)
    1600:	ec5e                	sd	s7,24(sp)
      printf("%s: pipe1 oops 3 total %d\n", s, total);
    1602:	8652                	mv	a2,s4
    1604:	85ce                	mv	a1,s3
    1606:	00004517          	auipc	a0,0x4
    160a:	7c250513          	addi	a0,a0,1986 # 5dc8 <malloc+0xb1a>
    160e:	3ed030ef          	jal	51fa <printf>
      exit(1);
    1612:	4505                	li	a0,1
    1614:	79e030ef          	jal	4db2 <exit>
    1618:	f05a                	sd	s6,32(sp)
    161a:	ec5e                	sd	s7,24(sp)
    close(fds[0]);
    161c:	fa842503          	lw	a0,-88(s0)
    1620:	7ba030ef          	jal	4dda <close>
    wait(&xstatus);
    1624:	fa440513          	addi	a0,s0,-92
    1628:	792030ef          	jal	4dba <wait>
    exit(xstatus);
    162c:	fa442503          	lw	a0,-92(s0)
    1630:	782030ef          	jal	4db2 <exit>
    1634:	e0ca                	sd	s2,64(sp)
    1636:	f456                	sd	s5,40(sp)
    1638:	f05a                	sd	s6,32(sp)
    163a:	ec5e                	sd	s7,24(sp)
    printf("%s: fork() failed\n", s);
    163c:	85ce                	mv	a1,s3
    163e:	00004517          	auipc	a0,0x4
    1642:	7aa50513          	addi	a0,a0,1962 # 5de8 <malloc+0xb3a>
    1646:	3b5030ef          	jal	51fa <printf>
    exit(1);
    164a:	4505                	li	a0,1
    164c:	766030ef          	jal	4db2 <exit>

0000000000001650 <exitwait>:
{
    1650:	7139                	addi	sp,sp,-64
    1652:	fc06                	sd	ra,56(sp)
    1654:	f822                	sd	s0,48(sp)
    1656:	f426                	sd	s1,40(sp)
    1658:	f04a                	sd	s2,32(sp)
    165a:	ec4e                	sd	s3,24(sp)
    165c:	e852                	sd	s4,16(sp)
    165e:	0080                	addi	s0,sp,64
    1660:	8a2a                	mv	s4,a0
  for(i = 0; i < 100; i++){
    1662:	4901                	li	s2,0
    1664:	06400993          	li	s3,100
    pid = fork();
    1668:	742030ef          	jal	4daa <fork>
    166c:	84aa                	mv	s1,a0
    if(pid < 0){
    166e:	02054863          	bltz	a0,169e <exitwait+0x4e>
    if(pid){
    1672:	c525                	beqz	a0,16da <exitwait+0x8a>
      if(wait(&xstate) != pid){
    1674:	fcc40513          	addi	a0,s0,-52
    1678:	742030ef          	jal	4dba <wait>
    167c:	02951b63          	bne	a0,s1,16b2 <exitwait+0x62>
      if(i != xstate) {
    1680:	fcc42783          	lw	a5,-52(s0)
    1684:	05279163          	bne	a5,s2,16c6 <exitwait+0x76>
  for(i = 0; i < 100; i++){
    1688:	2905                	addiw	s2,s2,1 # 3001 <subdir+0x43f>
    168a:	fd391fe3          	bne	s2,s3,1668 <exitwait+0x18>
}
    168e:	70e2                	ld	ra,56(sp)
    1690:	7442                	ld	s0,48(sp)
    1692:	74a2                	ld	s1,40(sp)
    1694:	7902                	ld	s2,32(sp)
    1696:	69e2                	ld	s3,24(sp)
    1698:	6a42                	ld	s4,16(sp)
    169a:	6121                	addi	sp,sp,64
    169c:	8082                	ret
      printf("%s: fork failed\n", s);
    169e:	85d2                	mv	a1,s4
    16a0:	00004517          	auipc	a0,0x4
    16a4:	5d850513          	addi	a0,a0,1496 # 5c78 <malloc+0x9ca>
    16a8:	353030ef          	jal	51fa <printf>
      exit(1);
    16ac:	4505                	li	a0,1
    16ae:	704030ef          	jal	4db2 <exit>
        printf("%s: wait wrong pid\n", s);
    16b2:	85d2                	mv	a1,s4
    16b4:	00004517          	auipc	a0,0x4
    16b8:	74c50513          	addi	a0,a0,1868 # 5e00 <malloc+0xb52>
    16bc:	33f030ef          	jal	51fa <printf>
        exit(1);
    16c0:	4505                	li	a0,1
    16c2:	6f0030ef          	jal	4db2 <exit>
        printf("%s: wait wrong exit status\n", s);
    16c6:	85d2                	mv	a1,s4
    16c8:	00004517          	auipc	a0,0x4
    16cc:	75050513          	addi	a0,a0,1872 # 5e18 <malloc+0xb6a>
    16d0:	32b030ef          	jal	51fa <printf>
        exit(1);
    16d4:	4505                	li	a0,1
    16d6:	6dc030ef          	jal	4db2 <exit>
      exit(i);
    16da:	854a                	mv	a0,s2
    16dc:	6d6030ef          	jal	4db2 <exit>

00000000000016e0 <twochildren>:
{
    16e0:	1101                	addi	sp,sp,-32
    16e2:	ec06                	sd	ra,24(sp)
    16e4:	e822                	sd	s0,16(sp)
    16e6:	e426                	sd	s1,8(sp)
    16e8:	e04a                	sd	s2,0(sp)
    16ea:	1000                	addi	s0,sp,32
    16ec:	892a                	mv	s2,a0
    16ee:	3e800493          	li	s1,1000
    int pid1 = fork();
    16f2:	6b8030ef          	jal	4daa <fork>
    if(pid1 < 0){
    16f6:	02054663          	bltz	a0,1722 <twochildren+0x42>
    if(pid1 == 0){
    16fa:	cd15                	beqz	a0,1736 <twochildren+0x56>
      int pid2 = fork();
    16fc:	6ae030ef          	jal	4daa <fork>
      if(pid2 < 0){
    1700:	02054d63          	bltz	a0,173a <twochildren+0x5a>
      if(pid2 == 0){
    1704:	c529                	beqz	a0,174e <twochildren+0x6e>
        wait(0);
    1706:	4501                	li	a0,0
    1708:	6b2030ef          	jal	4dba <wait>
        wait(0);
    170c:	4501                	li	a0,0
    170e:	6ac030ef          	jal	4dba <wait>
  for(int i = 0; i < 1000; i++){
    1712:	34fd                	addiw	s1,s1,-1
    1714:	fcf9                	bnez	s1,16f2 <twochildren+0x12>
}
    1716:	60e2                	ld	ra,24(sp)
    1718:	6442                	ld	s0,16(sp)
    171a:	64a2                	ld	s1,8(sp)
    171c:	6902                	ld	s2,0(sp)
    171e:	6105                	addi	sp,sp,32
    1720:	8082                	ret
      printf("%s: fork failed\n", s);
    1722:	85ca                	mv	a1,s2
    1724:	00004517          	auipc	a0,0x4
    1728:	55450513          	addi	a0,a0,1364 # 5c78 <malloc+0x9ca>
    172c:	2cf030ef          	jal	51fa <printf>
      exit(1);
    1730:	4505                	li	a0,1
    1732:	680030ef          	jal	4db2 <exit>
      exit(0);
    1736:	67c030ef          	jal	4db2 <exit>
        printf("%s: fork failed\n", s);
    173a:	85ca                	mv	a1,s2
    173c:	00004517          	auipc	a0,0x4
    1740:	53c50513          	addi	a0,a0,1340 # 5c78 <malloc+0x9ca>
    1744:	2b7030ef          	jal	51fa <printf>
        exit(1);
    1748:	4505                	li	a0,1
    174a:	668030ef          	jal	4db2 <exit>
        exit(0);
    174e:	664030ef          	jal	4db2 <exit>

0000000000001752 <forkfork>:
{
    1752:	7179                	addi	sp,sp,-48
    1754:	f406                	sd	ra,40(sp)
    1756:	f022                	sd	s0,32(sp)
    1758:	ec26                	sd	s1,24(sp)
    175a:	1800                	addi	s0,sp,48
    175c:	84aa                	mv	s1,a0
    int pid = fork();
    175e:	64c030ef          	jal	4daa <fork>
    if(pid < 0){
    1762:	02054b63          	bltz	a0,1798 <forkfork+0x46>
    if(pid == 0){
    1766:	c139                	beqz	a0,17ac <forkfork+0x5a>
    int pid = fork();
    1768:	642030ef          	jal	4daa <fork>
    if(pid < 0){
    176c:	02054663          	bltz	a0,1798 <forkfork+0x46>
    if(pid == 0){
    1770:	cd15                	beqz	a0,17ac <forkfork+0x5a>
    wait(&xstatus);
    1772:	fdc40513          	addi	a0,s0,-36
    1776:	644030ef          	jal	4dba <wait>
    if(xstatus != 0) {
    177a:	fdc42783          	lw	a5,-36(s0)
    177e:	ebb9                	bnez	a5,17d4 <forkfork+0x82>
    wait(&xstatus);
    1780:	fdc40513          	addi	a0,s0,-36
    1784:	636030ef          	jal	4dba <wait>
    if(xstatus != 0) {
    1788:	fdc42783          	lw	a5,-36(s0)
    178c:	e7a1                	bnez	a5,17d4 <forkfork+0x82>
}
    178e:	70a2                	ld	ra,40(sp)
    1790:	7402                	ld	s0,32(sp)
    1792:	64e2                	ld	s1,24(sp)
    1794:	6145                	addi	sp,sp,48
    1796:	8082                	ret
      printf("%s: fork failed", s);
    1798:	85a6                	mv	a1,s1
    179a:	00004517          	auipc	a0,0x4
    179e:	69e50513          	addi	a0,a0,1694 # 5e38 <malloc+0xb8a>
    17a2:	259030ef          	jal	51fa <printf>
      exit(1);
    17a6:	4505                	li	a0,1
    17a8:	60a030ef          	jal	4db2 <exit>
{
    17ac:	0c800493          	li	s1,200
        int pid1 = fork();
    17b0:	5fa030ef          	jal	4daa <fork>
        if(pid1 < 0){
    17b4:	00054b63          	bltz	a0,17ca <forkfork+0x78>
        if(pid1 == 0){
    17b8:	cd01                	beqz	a0,17d0 <forkfork+0x7e>
        wait(0);
    17ba:	4501                	li	a0,0
    17bc:	5fe030ef          	jal	4dba <wait>
      for(int j = 0; j < 200; j++){
    17c0:	34fd                	addiw	s1,s1,-1
    17c2:	f4fd                	bnez	s1,17b0 <forkfork+0x5e>
      exit(0);
    17c4:	4501                	li	a0,0
    17c6:	5ec030ef          	jal	4db2 <exit>
          exit(1);
    17ca:	4505                	li	a0,1
    17cc:	5e6030ef          	jal	4db2 <exit>
          exit(0);
    17d0:	5e2030ef          	jal	4db2 <exit>
      printf("%s: fork in child failed", s);
    17d4:	85a6                	mv	a1,s1
    17d6:	00004517          	auipc	a0,0x4
    17da:	67250513          	addi	a0,a0,1650 # 5e48 <malloc+0xb9a>
    17de:	21d030ef          	jal	51fa <printf>
      exit(1);
    17e2:	4505                	li	a0,1
    17e4:	5ce030ef          	jal	4db2 <exit>

00000000000017e8 <reparent2>:
{
    17e8:	1101                	addi	sp,sp,-32
    17ea:	ec06                	sd	ra,24(sp)
    17ec:	e822                	sd	s0,16(sp)
    17ee:	e426                	sd	s1,8(sp)
    17f0:	1000                	addi	s0,sp,32
    17f2:	32000493          	li	s1,800
    int pid1 = fork();
    17f6:	5b4030ef          	jal	4daa <fork>
    if(pid1 < 0){
    17fa:	00054b63          	bltz	a0,1810 <reparent2+0x28>
    if(pid1 == 0){
    17fe:	c115                	beqz	a0,1822 <reparent2+0x3a>
    wait(0);
    1800:	4501                	li	a0,0
    1802:	5b8030ef          	jal	4dba <wait>
  for(int i = 0; i < 800; i++){
    1806:	34fd                	addiw	s1,s1,-1
    1808:	f4fd                	bnez	s1,17f6 <reparent2+0xe>
  exit(0);
    180a:	4501                	li	a0,0
    180c:	5a6030ef          	jal	4db2 <exit>
      printf("fork failed\n");
    1810:	00006517          	auipc	a0,0x6
    1814:	a1050513          	addi	a0,a0,-1520 # 7220 <malloc+0x1f72>
    1818:	1e3030ef          	jal	51fa <printf>
      exit(1);
    181c:	4505                	li	a0,1
    181e:	594030ef          	jal	4db2 <exit>
      fork();
    1822:	588030ef          	jal	4daa <fork>
      fork();
    1826:	584030ef          	jal	4daa <fork>
      exit(0);
    182a:	4501                	li	a0,0
    182c:	586030ef          	jal	4db2 <exit>

0000000000001830 <createdelete>:
{
    1830:	7175                	addi	sp,sp,-144
    1832:	e506                	sd	ra,136(sp)
    1834:	e122                	sd	s0,128(sp)
    1836:	fca6                	sd	s1,120(sp)
    1838:	f8ca                	sd	s2,112(sp)
    183a:	f4ce                	sd	s3,104(sp)
    183c:	f0d2                	sd	s4,96(sp)
    183e:	ecd6                	sd	s5,88(sp)
    1840:	e8da                	sd	s6,80(sp)
    1842:	e4de                	sd	s7,72(sp)
    1844:	e0e2                	sd	s8,64(sp)
    1846:	fc66                	sd	s9,56(sp)
    1848:	0900                	addi	s0,sp,144
    184a:	8caa                	mv	s9,a0
  for(pi = 0; pi < NCHILD; pi++){
    184c:	4901                	li	s2,0
    184e:	4991                	li	s3,4
    pid = fork();
    1850:	55a030ef          	jal	4daa <fork>
    1854:	84aa                	mv	s1,a0
    if(pid < 0){
    1856:	02054d63          	bltz	a0,1890 <createdelete+0x60>
    if(pid == 0){
    185a:	c529                	beqz	a0,18a4 <createdelete+0x74>
  for(pi = 0; pi < NCHILD; pi++){
    185c:	2905                	addiw	s2,s2,1
    185e:	ff3919e3          	bne	s2,s3,1850 <createdelete+0x20>
    1862:	4491                	li	s1,4
    wait(&xstatus);
    1864:	f7c40513          	addi	a0,s0,-132
    1868:	552030ef          	jal	4dba <wait>
    if(xstatus != 0)
    186c:	f7c42903          	lw	s2,-132(s0)
    1870:	0a091e63          	bnez	s2,192c <createdelete+0xfc>
  for(pi = 0; pi < NCHILD; pi++){
    1874:	34fd                	addiw	s1,s1,-1
    1876:	f4fd                	bnez	s1,1864 <createdelete+0x34>
  name[0] = name[1] = name[2] = 0;
    1878:	f8040123          	sb	zero,-126(s0)
    187c:	03000993          	li	s3,48
    1880:	5a7d                	li	s4,-1
    1882:	07000c13          	li	s8,112
      if((i == 0 || i >= N/2) && fd < 0){
    1886:	4b25                	li	s6,9
      } else if((i >= 1 && i < N/2) && fd >= 0){
    1888:	4ba1                	li	s7,8
    for(pi = 0; pi < NCHILD; pi++){
    188a:	07400a93          	li	s5,116
    188e:	aa39                	j	19ac <createdelete+0x17c>
      printf("%s: fork failed\n", s);
    1890:	85e6                	mv	a1,s9
    1892:	00004517          	auipc	a0,0x4
    1896:	3e650513          	addi	a0,a0,998 # 5c78 <malloc+0x9ca>
    189a:	161030ef          	jal	51fa <printf>
      exit(1);
    189e:	4505                	li	a0,1
    18a0:	512030ef          	jal	4db2 <exit>
      name[0] = 'p' + pi;
    18a4:	0709091b          	addiw	s2,s2,112
    18a8:	f9240023          	sb	s2,-128(s0)
      name[2] = '\0';
    18ac:	f8040123          	sb	zero,-126(s0)
      for(i = 0; i < N; i++){
    18b0:	4951                	li	s2,20
    18b2:	a831                	j	18ce <createdelete+0x9e>
          printf("%s: create failed\n", s);
    18b4:	85e6                	mv	a1,s9
    18b6:	00004517          	auipc	a0,0x4
    18ba:	45a50513          	addi	a0,a0,1114 # 5d10 <malloc+0xa62>
    18be:	13d030ef          	jal	51fa <printf>
          exit(1);
    18c2:	4505                	li	a0,1
    18c4:	4ee030ef          	jal	4db2 <exit>
      for(i = 0; i < N; i++){
    18c8:	2485                	addiw	s1,s1,1
    18ca:	05248e63          	beq	s1,s2,1926 <createdelete+0xf6>
        name[1] = '0' + i;
    18ce:	0304879b          	addiw	a5,s1,48
    18d2:	f8f400a3          	sb	a5,-127(s0)
        fd = open(name, O_CREATE | O_RDWR);
    18d6:	20200593          	li	a1,514
    18da:	f8040513          	addi	a0,s0,-128
    18de:	514030ef          	jal	4df2 <open>
        if(fd < 0){
    18e2:	fc0549e3          	bltz	a0,18b4 <createdelete+0x84>
        close(fd);
    18e6:	4f4030ef          	jal	4dda <close>
        if(i > 0 && (i % 2 ) == 0){
    18ea:	10905063          	blez	s1,19ea <createdelete+0x1ba>
    18ee:	0014f793          	andi	a5,s1,1
    18f2:	fbf9                	bnez	a5,18c8 <createdelete+0x98>
          name[1] = '0' + (i / 2);
    18f4:	01f4d79b          	srliw	a5,s1,0x1f
    18f8:	9fa5                	addw	a5,a5,s1
    18fa:	4017d79b          	sraiw	a5,a5,0x1
    18fe:	0307879b          	addiw	a5,a5,48
    1902:	f8f400a3          	sb	a5,-127(s0)
          if(unlink(name) < 0){
    1906:	f8040513          	addi	a0,s0,-128
    190a:	4f8030ef          	jal	4e02 <unlink>
    190e:	fa055de3          	bgez	a0,18c8 <createdelete+0x98>
            printf("%s: unlink failed\n", s);
    1912:	85e6                	mv	a1,s9
    1914:	00004517          	auipc	a0,0x4
    1918:	55450513          	addi	a0,a0,1364 # 5e68 <malloc+0xbba>
    191c:	0df030ef          	jal	51fa <printf>
            exit(1);
    1920:	4505                	li	a0,1
    1922:	490030ef          	jal	4db2 <exit>
      exit(0);
    1926:	4501                	li	a0,0
    1928:	48a030ef          	jal	4db2 <exit>
      exit(1);
    192c:	4505                	li	a0,1
    192e:	484030ef          	jal	4db2 <exit>
        printf("%s: oops createdelete %s didn't exist\n", s, name);
    1932:	f8040613          	addi	a2,s0,-128
    1936:	85e6                	mv	a1,s9
    1938:	00004517          	auipc	a0,0x4
    193c:	54850513          	addi	a0,a0,1352 # 5e80 <malloc+0xbd2>
    1940:	0bb030ef          	jal	51fa <printf>
        exit(1);
    1944:	4505                	li	a0,1
    1946:	46c030ef          	jal	4db2 <exit>
      } else if((i >= 1 && i < N/2) && fd >= 0){
    194a:	034bfb63          	bgeu	s7,s4,1980 <createdelete+0x150>
      if(fd >= 0)
    194e:	02055663          	bgez	a0,197a <createdelete+0x14a>
    for(pi = 0; pi < NCHILD; pi++){
    1952:	2485                	addiw	s1,s1,1
    1954:	0ff4f493          	zext.b	s1,s1
    1958:	05548263          	beq	s1,s5,199c <createdelete+0x16c>
      name[0] = 'p' + pi;
    195c:	f8940023          	sb	s1,-128(s0)
      name[1] = '0' + i;
    1960:	f93400a3          	sb	s3,-127(s0)
      fd = open(name, 0);
    1964:	4581                	li	a1,0
    1966:	f8040513          	addi	a0,s0,-128
    196a:	488030ef          	jal	4df2 <open>
      if((i == 0 || i >= N/2) && fd < 0){
    196e:	00090463          	beqz	s2,1976 <createdelete+0x146>
    1972:	fd2b5ce3          	bge	s6,s2,194a <createdelete+0x11a>
    1976:	fa054ee3          	bltz	a0,1932 <createdelete+0x102>
        close(fd);
    197a:	460030ef          	jal	4dda <close>
    197e:	bfd1                	j	1952 <createdelete+0x122>
      } else if((i >= 1 && i < N/2) && fd >= 0){
    1980:	fc0549e3          	bltz	a0,1952 <createdelete+0x122>
        printf("%s: oops createdelete %s did exist\n", s, name);
    1984:	f8040613          	addi	a2,s0,-128
    1988:	85e6                	mv	a1,s9
    198a:	00004517          	auipc	a0,0x4
    198e:	51e50513          	addi	a0,a0,1310 # 5ea8 <malloc+0xbfa>
    1992:	069030ef          	jal	51fa <printf>
        exit(1);
    1996:	4505                	li	a0,1
    1998:	41a030ef          	jal	4db2 <exit>
  for(i = 0; i < N; i++){
    199c:	2905                	addiw	s2,s2,1
    199e:	2a05                	addiw	s4,s4,1
    19a0:	2985                	addiw	s3,s3,1
    19a2:	0ff9f993          	zext.b	s3,s3
    19a6:	47d1                	li	a5,20
    19a8:	02f90863          	beq	s2,a5,19d8 <createdelete+0x1a8>
    for(pi = 0; pi < NCHILD; pi++){
    19ac:	84e2                	mv	s1,s8
    19ae:	b77d                	j	195c <createdelete+0x12c>
  for(i = 0; i < N; i++){
    19b0:	2905                	addiw	s2,s2,1
    19b2:	0ff97913          	zext.b	s2,s2
    19b6:	03490c63          	beq	s2,s4,19ee <createdelete+0x1be>
  name[0] = name[1] = name[2] = 0;
    19ba:	84d6                	mv	s1,s5
      name[0] = 'p' + pi;
    19bc:	f8940023          	sb	s1,-128(s0)
      name[1] = '0' + i;
    19c0:	f92400a3          	sb	s2,-127(s0)
      unlink(name);
    19c4:	f8040513          	addi	a0,s0,-128
    19c8:	43a030ef          	jal	4e02 <unlink>
    for(pi = 0; pi < NCHILD; pi++){
    19cc:	2485                	addiw	s1,s1,1
    19ce:	0ff4f493          	zext.b	s1,s1
    19d2:	ff3495e3          	bne	s1,s3,19bc <createdelete+0x18c>
    19d6:	bfe9                	j	19b0 <createdelete+0x180>
    19d8:	03000913          	li	s2,48
  name[0] = name[1] = name[2] = 0;
    19dc:	07000a93          	li	s5,112
    for(pi = 0; pi < NCHILD; pi++){
    19e0:	07400993          	li	s3,116
  for(i = 0; i < N; i++){
    19e4:	04400a13          	li	s4,68
    19e8:	bfc9                	j	19ba <createdelete+0x18a>
      for(i = 0; i < N; i++){
    19ea:	2485                	addiw	s1,s1,1
    19ec:	b5cd                	j	18ce <createdelete+0x9e>
}
    19ee:	60aa                	ld	ra,136(sp)
    19f0:	640a                	ld	s0,128(sp)
    19f2:	74e6                	ld	s1,120(sp)
    19f4:	7946                	ld	s2,112(sp)
    19f6:	79a6                	ld	s3,104(sp)
    19f8:	7a06                	ld	s4,96(sp)
    19fa:	6ae6                	ld	s5,88(sp)
    19fc:	6b46                	ld	s6,80(sp)
    19fe:	6ba6                	ld	s7,72(sp)
    1a00:	6c06                	ld	s8,64(sp)
    1a02:	7ce2                	ld	s9,56(sp)
    1a04:	6149                	addi	sp,sp,144
    1a06:	8082                	ret

0000000000001a08 <linkunlink>:
{
    1a08:	711d                	addi	sp,sp,-96
    1a0a:	ec86                	sd	ra,88(sp)
    1a0c:	e8a2                	sd	s0,80(sp)
    1a0e:	e4a6                	sd	s1,72(sp)
    1a10:	e0ca                	sd	s2,64(sp)
    1a12:	fc4e                	sd	s3,56(sp)
    1a14:	f852                	sd	s4,48(sp)
    1a16:	f456                	sd	s5,40(sp)
    1a18:	f05a                	sd	s6,32(sp)
    1a1a:	ec5e                	sd	s7,24(sp)
    1a1c:	e862                	sd	s8,16(sp)
    1a1e:	e466                	sd	s9,8(sp)
    1a20:	1080                	addi	s0,sp,96
    1a22:	84aa                	mv	s1,a0
  unlink("x");
    1a24:	00004517          	auipc	a0,0x4
    1a28:	a3450513          	addi	a0,a0,-1484 # 5458 <malloc+0x1aa>
    1a2c:	3d6030ef          	jal	4e02 <unlink>
  pid = fork();
    1a30:	37a030ef          	jal	4daa <fork>
  if(pid < 0){
    1a34:	02054b63          	bltz	a0,1a6a <linkunlink+0x62>
    1a38:	8caa                	mv	s9,a0
  unsigned int x = (pid ? 1 : 97);
    1a3a:	06100913          	li	s2,97
    1a3e:	c111                	beqz	a0,1a42 <linkunlink+0x3a>
    1a40:	4905                	li	s2,1
    1a42:	06400493          	li	s1,100
    x = x * 1103515245 + 12345;
    1a46:	41c65a37          	lui	s4,0x41c65
    1a4a:	e6da0a1b          	addiw	s4,s4,-403 # 41c64e6d <base+0x41c561b5>
    1a4e:	698d                	lui	s3,0x3
    1a50:	0399899b          	addiw	s3,s3,57 # 3039 <subdir+0x477>
    if((x % 3) == 0){
    1a54:	4a8d                	li	s5,3
    } else if((x % 3) == 1){
    1a56:	4b85                	li	s7,1
      unlink("x");
    1a58:	00004b17          	auipc	s6,0x4
    1a5c:	a00b0b13          	addi	s6,s6,-1536 # 5458 <malloc+0x1aa>
      link("cat", "x");
    1a60:	00004c17          	auipc	s8,0x4
    1a64:	470c0c13          	addi	s8,s8,1136 # 5ed0 <malloc+0xc22>
    1a68:	a025                	j	1a90 <linkunlink+0x88>
    printf("%s: fork failed\n", s);
    1a6a:	85a6                	mv	a1,s1
    1a6c:	00004517          	auipc	a0,0x4
    1a70:	20c50513          	addi	a0,a0,524 # 5c78 <malloc+0x9ca>
    1a74:	786030ef          	jal	51fa <printf>
    exit(1);
    1a78:	4505                	li	a0,1
    1a7a:	338030ef          	jal	4db2 <exit>
      close(open("x", O_RDWR | O_CREATE));
    1a7e:	20200593          	li	a1,514
    1a82:	855a                	mv	a0,s6
    1a84:	36e030ef          	jal	4df2 <open>
    1a88:	352030ef          	jal	4dda <close>
  for(i = 0; i < 100; i++){
    1a8c:	34fd                	addiw	s1,s1,-1
    1a8e:	c495                	beqz	s1,1aba <linkunlink+0xb2>
    x = x * 1103515245 + 12345;
    1a90:	034907bb          	mulw	a5,s2,s4
    1a94:	013787bb          	addw	a5,a5,s3
    1a98:	0007891b          	sext.w	s2,a5
    if((x % 3) == 0){
    1a9c:	0357f7bb          	remuw	a5,a5,s5
    1aa0:	2781                	sext.w	a5,a5
    1aa2:	dff1                	beqz	a5,1a7e <linkunlink+0x76>
    } else if((x % 3) == 1){
    1aa4:	01778663          	beq	a5,s7,1ab0 <linkunlink+0xa8>
      unlink("x");
    1aa8:	855a                	mv	a0,s6
    1aaa:	358030ef          	jal	4e02 <unlink>
    1aae:	bff9                	j	1a8c <linkunlink+0x84>
      link("cat", "x");
    1ab0:	85da                	mv	a1,s6
    1ab2:	8562                	mv	a0,s8
    1ab4:	35e030ef          	jal	4e12 <link>
    1ab8:	bfd1                	j	1a8c <linkunlink+0x84>
  if(pid)
    1aba:	020c8263          	beqz	s9,1ade <linkunlink+0xd6>
    wait(0);
    1abe:	4501                	li	a0,0
    1ac0:	2fa030ef          	jal	4dba <wait>
}
    1ac4:	60e6                	ld	ra,88(sp)
    1ac6:	6446                	ld	s0,80(sp)
    1ac8:	64a6                	ld	s1,72(sp)
    1aca:	6906                	ld	s2,64(sp)
    1acc:	79e2                	ld	s3,56(sp)
    1ace:	7a42                	ld	s4,48(sp)
    1ad0:	7aa2                	ld	s5,40(sp)
    1ad2:	7b02                	ld	s6,32(sp)
    1ad4:	6be2                	ld	s7,24(sp)
    1ad6:	6c42                	ld	s8,16(sp)
    1ad8:	6ca2                	ld	s9,8(sp)
    1ada:	6125                	addi	sp,sp,96
    1adc:	8082                	ret
    exit(0);
    1ade:	4501                	li	a0,0
    1ae0:	2d2030ef          	jal	4db2 <exit>

0000000000001ae4 <forktest>:
{
    1ae4:	7179                	addi	sp,sp,-48
    1ae6:	f406                	sd	ra,40(sp)
    1ae8:	f022                	sd	s0,32(sp)
    1aea:	ec26                	sd	s1,24(sp)
    1aec:	e84a                	sd	s2,16(sp)
    1aee:	e44e                	sd	s3,8(sp)
    1af0:	1800                	addi	s0,sp,48
    1af2:	89aa                	mv	s3,a0
  for(n=0; n<N; n++){
    1af4:	4481                	li	s1,0
    1af6:	3e800913          	li	s2,1000
    pid = fork();
    1afa:	2b0030ef          	jal	4daa <fork>
    if(pid < 0)
    1afe:	06054063          	bltz	a0,1b5e <forktest+0x7a>
    if(pid == 0)
    1b02:	cd11                	beqz	a0,1b1e <forktest+0x3a>
  for(n=0; n<N; n++){
    1b04:	2485                	addiw	s1,s1,1
    1b06:	ff249ae3          	bne	s1,s2,1afa <forktest+0x16>
    printf("%s: fork claimed to work 1000 times!\n", s);
    1b0a:	85ce                	mv	a1,s3
    1b0c:	00004517          	auipc	a0,0x4
    1b10:	41450513          	addi	a0,a0,1044 # 5f20 <malloc+0xc72>
    1b14:	6e6030ef          	jal	51fa <printf>
    exit(1);
    1b18:	4505                	li	a0,1
    1b1a:	298030ef          	jal	4db2 <exit>
      exit(0);
    1b1e:	294030ef          	jal	4db2 <exit>
    printf("%s: no fork at all!\n", s);
    1b22:	85ce                	mv	a1,s3
    1b24:	00004517          	auipc	a0,0x4
    1b28:	3b450513          	addi	a0,a0,948 # 5ed8 <malloc+0xc2a>
    1b2c:	6ce030ef          	jal	51fa <printf>
    exit(1);
    1b30:	4505                	li	a0,1
    1b32:	280030ef          	jal	4db2 <exit>
      printf("%s: wait stopped early\n", s);
    1b36:	85ce                	mv	a1,s3
    1b38:	00004517          	auipc	a0,0x4
    1b3c:	3b850513          	addi	a0,a0,952 # 5ef0 <malloc+0xc42>
    1b40:	6ba030ef          	jal	51fa <printf>
      exit(1);
    1b44:	4505                	li	a0,1
    1b46:	26c030ef          	jal	4db2 <exit>
    printf("%s: wait got too many\n", s);
    1b4a:	85ce                	mv	a1,s3
    1b4c:	00004517          	auipc	a0,0x4
    1b50:	3bc50513          	addi	a0,a0,956 # 5f08 <malloc+0xc5a>
    1b54:	6a6030ef          	jal	51fa <printf>
    exit(1);
    1b58:	4505                	li	a0,1
    1b5a:	258030ef          	jal	4db2 <exit>
  if (n == 0) {
    1b5e:	d0f1                	beqz	s1,1b22 <forktest+0x3e>
  for(; n > 0; n--){
    1b60:	00905963          	blez	s1,1b72 <forktest+0x8e>
    if(wait(0) < 0){
    1b64:	4501                	li	a0,0
    1b66:	254030ef          	jal	4dba <wait>
    1b6a:	fc0546e3          	bltz	a0,1b36 <forktest+0x52>
  for(; n > 0; n--){
    1b6e:	34fd                	addiw	s1,s1,-1
    1b70:	f8f5                	bnez	s1,1b64 <forktest+0x80>
  if(wait(0) != -1){
    1b72:	4501                	li	a0,0
    1b74:	246030ef          	jal	4dba <wait>
    1b78:	57fd                	li	a5,-1
    1b7a:	fcf518e3          	bne	a0,a5,1b4a <forktest+0x66>
}
    1b7e:	70a2                	ld	ra,40(sp)
    1b80:	7402                	ld	s0,32(sp)
    1b82:	64e2                	ld	s1,24(sp)
    1b84:	6942                	ld	s2,16(sp)
    1b86:	69a2                	ld	s3,8(sp)
    1b88:	6145                	addi	sp,sp,48
    1b8a:	8082                	ret

0000000000001b8c <kernmem>:
{
    1b8c:	715d                	addi	sp,sp,-80
    1b8e:	e486                	sd	ra,72(sp)
    1b90:	e0a2                	sd	s0,64(sp)
    1b92:	fc26                	sd	s1,56(sp)
    1b94:	f84a                	sd	s2,48(sp)
    1b96:	f44e                	sd	s3,40(sp)
    1b98:	f052                	sd	s4,32(sp)
    1b9a:	ec56                	sd	s5,24(sp)
    1b9c:	0880                	addi	s0,sp,80
    1b9e:	8aaa                	mv	s5,a0
  for(a = (char*)(KERNBASE); a < (char*) (KERNBASE+2000000); a += 50000){
    1ba0:	4485                	li	s1,1
    1ba2:	04fe                	slli	s1,s1,0x1f
    if(xstatus != -1)  // did kernel kill child?
    1ba4:	5a7d                	li	s4,-1
  for(a = (char*)(KERNBASE); a < (char*) (KERNBASE+2000000); a += 50000){
    1ba6:	69b1                	lui	s3,0xc
    1ba8:	35098993          	addi	s3,s3,848 # c350 <buf+0x698>
    1bac:	1003d937          	lui	s2,0x1003d
    1bb0:	090e                	slli	s2,s2,0x3
    1bb2:	48090913          	addi	s2,s2,1152 # 1003d480 <base+0x1002e7c8>
    pid = fork();
    1bb6:	1f4030ef          	jal	4daa <fork>
    if(pid < 0){
    1bba:	02054763          	bltz	a0,1be8 <kernmem+0x5c>
    if(pid == 0){
    1bbe:	cd1d                	beqz	a0,1bfc <kernmem+0x70>
    wait(&xstatus);
    1bc0:	fbc40513          	addi	a0,s0,-68
    1bc4:	1f6030ef          	jal	4dba <wait>
    if(xstatus != -1)  // did kernel kill child?
    1bc8:	fbc42783          	lw	a5,-68(s0)
    1bcc:	05479563          	bne	a5,s4,1c16 <kernmem+0x8a>
  for(a = (char*)(KERNBASE); a < (char*) (KERNBASE+2000000); a += 50000){
    1bd0:	94ce                	add	s1,s1,s3
    1bd2:	ff2492e3          	bne	s1,s2,1bb6 <kernmem+0x2a>
}
    1bd6:	60a6                	ld	ra,72(sp)
    1bd8:	6406                	ld	s0,64(sp)
    1bda:	74e2                	ld	s1,56(sp)
    1bdc:	7942                	ld	s2,48(sp)
    1bde:	79a2                	ld	s3,40(sp)
    1be0:	7a02                	ld	s4,32(sp)
    1be2:	6ae2                	ld	s5,24(sp)
    1be4:	6161                	addi	sp,sp,80
    1be6:	8082                	ret
      printf("%s: fork failed\n", s);
    1be8:	85d6                	mv	a1,s5
    1bea:	00004517          	auipc	a0,0x4
    1bee:	08e50513          	addi	a0,a0,142 # 5c78 <malloc+0x9ca>
    1bf2:	608030ef          	jal	51fa <printf>
      exit(1);
    1bf6:	4505                	li	a0,1
    1bf8:	1ba030ef          	jal	4db2 <exit>
      printf("%s: oops could read %p = %x\n", s, a, *a);
    1bfc:	0004c683          	lbu	a3,0(s1)
    1c00:	8626                	mv	a2,s1
    1c02:	85d6                	mv	a1,s5
    1c04:	00004517          	auipc	a0,0x4
    1c08:	34450513          	addi	a0,a0,836 # 5f48 <malloc+0xc9a>
    1c0c:	5ee030ef          	jal	51fa <printf>
      exit(1);
    1c10:	4505                	li	a0,1
    1c12:	1a0030ef          	jal	4db2 <exit>
      exit(1);
    1c16:	4505                	li	a0,1
    1c18:	19a030ef          	jal	4db2 <exit>

0000000000001c1c <MAXVAplus>:
{
    1c1c:	7179                	addi	sp,sp,-48
    1c1e:	f406                	sd	ra,40(sp)
    1c20:	f022                	sd	s0,32(sp)
    1c22:	1800                	addi	s0,sp,48
  volatile uint64 a = MAXVA;
    1c24:	4785                	li	a5,1
    1c26:	179a                	slli	a5,a5,0x26
    1c28:	fcf43c23          	sd	a5,-40(s0)
  for( ; a != 0; a <<= 1){
    1c2c:	fd843783          	ld	a5,-40(s0)
    1c30:	cf85                	beqz	a5,1c68 <MAXVAplus+0x4c>
    1c32:	ec26                	sd	s1,24(sp)
    1c34:	e84a                	sd	s2,16(sp)
    1c36:	892a                	mv	s2,a0
    if(xstatus != -1)  // did kernel kill child?
    1c38:	54fd                	li	s1,-1
    pid = fork();
    1c3a:	170030ef          	jal	4daa <fork>
    if(pid < 0){
    1c3e:	02054963          	bltz	a0,1c70 <MAXVAplus+0x54>
    if(pid == 0){
    1c42:	c129                	beqz	a0,1c84 <MAXVAplus+0x68>
    wait(&xstatus);
    1c44:	fd440513          	addi	a0,s0,-44
    1c48:	172030ef          	jal	4dba <wait>
    if(xstatus != -1)  // did kernel kill child?
    1c4c:	fd442783          	lw	a5,-44(s0)
    1c50:	04979c63          	bne	a5,s1,1ca8 <MAXVAplus+0x8c>
  for( ; a != 0; a <<= 1){
    1c54:	fd843783          	ld	a5,-40(s0)
    1c58:	0786                	slli	a5,a5,0x1
    1c5a:	fcf43c23          	sd	a5,-40(s0)
    1c5e:	fd843783          	ld	a5,-40(s0)
    1c62:	ffe1                	bnez	a5,1c3a <MAXVAplus+0x1e>
    1c64:	64e2                	ld	s1,24(sp)
    1c66:	6942                	ld	s2,16(sp)
}
    1c68:	70a2                	ld	ra,40(sp)
    1c6a:	7402                	ld	s0,32(sp)
    1c6c:	6145                	addi	sp,sp,48
    1c6e:	8082                	ret
      printf("%s: fork failed\n", s);
    1c70:	85ca                	mv	a1,s2
    1c72:	00004517          	auipc	a0,0x4
    1c76:	00650513          	addi	a0,a0,6 # 5c78 <malloc+0x9ca>
    1c7a:	580030ef          	jal	51fa <printf>
      exit(1);
    1c7e:	4505                	li	a0,1
    1c80:	132030ef          	jal	4db2 <exit>
      *(char*)a = 99;
    1c84:	fd843783          	ld	a5,-40(s0)
    1c88:	06300713          	li	a4,99
    1c8c:	00e78023          	sb	a4,0(a5)
      printf("%s: oops wrote %p\n", s, (void*)a);
    1c90:	fd843603          	ld	a2,-40(s0)
    1c94:	85ca                	mv	a1,s2
    1c96:	00004517          	auipc	a0,0x4
    1c9a:	2d250513          	addi	a0,a0,722 # 5f68 <malloc+0xcba>
    1c9e:	55c030ef          	jal	51fa <printf>
      exit(1);
    1ca2:	4505                	li	a0,1
    1ca4:	10e030ef          	jal	4db2 <exit>
      exit(1);
    1ca8:	4505                	li	a0,1
    1caa:	108030ef          	jal	4db2 <exit>

0000000000001cae <stacktest>:
{
    1cae:	7179                	addi	sp,sp,-48
    1cb0:	f406                	sd	ra,40(sp)
    1cb2:	f022                	sd	s0,32(sp)
    1cb4:	ec26                	sd	s1,24(sp)
    1cb6:	1800                	addi	s0,sp,48
    1cb8:	84aa                	mv	s1,a0
  pid = fork();
    1cba:	0f0030ef          	jal	4daa <fork>
  if(pid == 0) {
    1cbe:	cd11                	beqz	a0,1cda <stacktest+0x2c>
  } else if(pid < 0){
    1cc0:	02054c63          	bltz	a0,1cf8 <stacktest+0x4a>
  wait(&xstatus);
    1cc4:	fdc40513          	addi	a0,s0,-36
    1cc8:	0f2030ef          	jal	4dba <wait>
  if(xstatus == -1)  // kernel killed child?
    1ccc:	fdc42503          	lw	a0,-36(s0)
    1cd0:	57fd                	li	a5,-1
    1cd2:	02f50d63          	beq	a0,a5,1d0c <stacktest+0x5e>
    exit(xstatus);
    1cd6:	0dc030ef          	jal	4db2 <exit>

static inline uint64
r_sp()
{
  uint64 x;
  asm volatile("mv %0, sp" : "=r" (x) );
    1cda:	870a                	mv	a4,sp
    printf("%s: stacktest: read below stack %d\n", s, *sp);
    1cdc:	77fd                	lui	a5,0xfffff
    1cde:	97ba                	add	a5,a5,a4
    1ce0:	0007c603          	lbu	a2,0(a5) # fffffffffffff000 <base+0xffffffffffff0348>
    1ce4:	85a6                	mv	a1,s1
    1ce6:	00004517          	auipc	a0,0x4
    1cea:	29a50513          	addi	a0,a0,666 # 5f80 <malloc+0xcd2>
    1cee:	50c030ef          	jal	51fa <printf>
    exit(1);
    1cf2:	4505                	li	a0,1
    1cf4:	0be030ef          	jal	4db2 <exit>
    printf("%s: fork failed\n", s);
    1cf8:	85a6                	mv	a1,s1
    1cfa:	00004517          	auipc	a0,0x4
    1cfe:	f7e50513          	addi	a0,a0,-130 # 5c78 <malloc+0x9ca>
    1d02:	4f8030ef          	jal	51fa <printf>
    exit(1);
    1d06:	4505                	li	a0,1
    1d08:	0aa030ef          	jal	4db2 <exit>
    exit(0);
    1d0c:	4501                	li	a0,0
    1d0e:	0a4030ef          	jal	4db2 <exit>

0000000000001d12 <nowrite>:
{
    1d12:	7159                	addi	sp,sp,-112
    1d14:	f486                	sd	ra,104(sp)
    1d16:	f0a2                	sd	s0,96(sp)
    1d18:	eca6                	sd	s1,88(sp)
    1d1a:	e8ca                	sd	s2,80(sp)
    1d1c:	e4ce                	sd	s3,72(sp)
    1d1e:	1880                	addi	s0,sp,112
    1d20:	89aa                	mv	s3,a0
  uint64 addrs[] = { 0, 0x80000000LL, 0x3fffffe000, 0x3ffffff000, 0x4000000000,
    1d22:	00006797          	auipc	a5,0x6
    1d26:	c0e78793          	addi	a5,a5,-1010 # 7930 <malloc+0x2682>
    1d2a:	7788                	ld	a0,40(a5)
    1d2c:	7b8c                	ld	a1,48(a5)
    1d2e:	7f90                	ld	a2,56(a5)
    1d30:	63b4                	ld	a3,64(a5)
    1d32:	67b8                	ld	a4,72(a5)
    1d34:	6bbc                	ld	a5,80(a5)
    1d36:	f8a43c23          	sd	a0,-104(s0)
    1d3a:	fab43023          	sd	a1,-96(s0)
    1d3e:	fac43423          	sd	a2,-88(s0)
    1d42:	fad43823          	sd	a3,-80(s0)
    1d46:	fae43c23          	sd	a4,-72(s0)
    1d4a:	fcf43023          	sd	a5,-64(s0)
  for(int ai = 0; ai < sizeof(addrs)/sizeof(addrs[0]); ai++){
    1d4e:	4481                	li	s1,0
    1d50:	4919                	li	s2,6
    pid = fork();
    1d52:	058030ef          	jal	4daa <fork>
    if(pid == 0) {
    1d56:	c105                	beqz	a0,1d76 <nowrite+0x64>
    } else if(pid < 0){
    1d58:	04054263          	bltz	a0,1d9c <nowrite+0x8a>
    wait(&xstatus);
    1d5c:	fcc40513          	addi	a0,s0,-52
    1d60:	05a030ef          	jal	4dba <wait>
    if(xstatus == 0){
    1d64:	fcc42783          	lw	a5,-52(s0)
    1d68:	c7a1                	beqz	a5,1db0 <nowrite+0x9e>
  for(int ai = 0; ai < sizeof(addrs)/sizeof(addrs[0]); ai++){
    1d6a:	2485                	addiw	s1,s1,1
    1d6c:	ff2493e3          	bne	s1,s2,1d52 <nowrite+0x40>
  exit(0);
    1d70:	4501                	li	a0,0
    1d72:	040030ef          	jal	4db2 <exit>
      volatile int *addr = (int *) addrs[ai];
    1d76:	048e                	slli	s1,s1,0x3
    1d78:	fd048793          	addi	a5,s1,-48
    1d7c:	008784b3          	add	s1,a5,s0
    1d80:	fc84b603          	ld	a2,-56(s1)
      *addr = 10;
    1d84:	47a9                	li	a5,10
    1d86:	c21c                	sw	a5,0(a2)
      printf("%s: write to %p did not fail!\n", s, addr);
    1d88:	85ce                	mv	a1,s3
    1d8a:	00004517          	auipc	a0,0x4
    1d8e:	21e50513          	addi	a0,a0,542 # 5fa8 <malloc+0xcfa>
    1d92:	468030ef          	jal	51fa <printf>
      exit(0);
    1d96:	4501                	li	a0,0
    1d98:	01a030ef          	jal	4db2 <exit>
      printf("%s: fork failed\n", s);
    1d9c:	85ce                	mv	a1,s3
    1d9e:	00004517          	auipc	a0,0x4
    1da2:	eda50513          	addi	a0,a0,-294 # 5c78 <malloc+0x9ca>
    1da6:	454030ef          	jal	51fa <printf>
      exit(1);
    1daa:	4505                	li	a0,1
    1dac:	006030ef          	jal	4db2 <exit>
      exit(1);
    1db0:	4505                	li	a0,1
    1db2:	000030ef          	jal	4db2 <exit>

0000000000001db6 <manywrites>:
{
    1db6:	711d                	addi	sp,sp,-96
    1db8:	ec86                	sd	ra,88(sp)
    1dba:	e8a2                	sd	s0,80(sp)
    1dbc:	e4a6                	sd	s1,72(sp)
    1dbe:	e0ca                	sd	s2,64(sp)
    1dc0:	fc4e                	sd	s3,56(sp)
    1dc2:	f456                	sd	s5,40(sp)
    1dc4:	1080                	addi	s0,sp,96
    1dc6:	8aaa                	mv	s5,a0
  for(int ci = 0; ci < nchildren; ci++){
    1dc8:	4981                	li	s3,0
    1dca:	4911                	li	s2,4
    int pid = fork();
    1dcc:	7df020ef          	jal	4daa <fork>
    1dd0:	84aa                	mv	s1,a0
    if(pid < 0){
    1dd2:	02054963          	bltz	a0,1e04 <manywrites+0x4e>
    if(pid == 0){
    1dd6:	c139                	beqz	a0,1e1c <manywrites+0x66>
  for(int ci = 0; ci < nchildren; ci++){
    1dd8:	2985                	addiw	s3,s3,1
    1dda:	ff2999e3          	bne	s3,s2,1dcc <manywrites+0x16>
    1dde:	f852                	sd	s4,48(sp)
    1de0:	f05a                	sd	s6,32(sp)
    1de2:	ec5e                	sd	s7,24(sp)
    1de4:	4491                	li	s1,4
    int st = 0;
    1de6:	fa042423          	sw	zero,-88(s0)
    wait(&st);
    1dea:	fa840513          	addi	a0,s0,-88
    1dee:	7cd020ef          	jal	4dba <wait>
    if(st != 0)
    1df2:	fa842503          	lw	a0,-88(s0)
    1df6:	0c051863          	bnez	a0,1ec6 <manywrites+0x110>
  for(int ci = 0; ci < nchildren; ci++){
    1dfa:	34fd                	addiw	s1,s1,-1
    1dfc:	f4ed                	bnez	s1,1de6 <manywrites+0x30>
  exit(0);
    1dfe:	4501                	li	a0,0
    1e00:	7b3020ef          	jal	4db2 <exit>
    1e04:	f852                	sd	s4,48(sp)
    1e06:	f05a                	sd	s6,32(sp)
    1e08:	ec5e                	sd	s7,24(sp)
      printf("fork failed\n");
    1e0a:	00005517          	auipc	a0,0x5
    1e0e:	41650513          	addi	a0,a0,1046 # 7220 <malloc+0x1f72>
    1e12:	3e8030ef          	jal	51fa <printf>
      exit(1);
    1e16:	4505                	li	a0,1
    1e18:	79b020ef          	jal	4db2 <exit>
    1e1c:	f852                	sd	s4,48(sp)
    1e1e:	f05a                	sd	s6,32(sp)
    1e20:	ec5e                	sd	s7,24(sp)
      name[0] = 'b';
    1e22:	06200793          	li	a5,98
    1e26:	faf40423          	sb	a5,-88(s0)
      name[1] = 'a' + ci;
    1e2a:	0619879b          	addiw	a5,s3,97
    1e2e:	faf404a3          	sb	a5,-87(s0)
      name[2] = '\0';
    1e32:	fa040523          	sb	zero,-86(s0)
      unlink(name);
    1e36:	fa840513          	addi	a0,s0,-88
    1e3a:	7c9020ef          	jal	4e02 <unlink>
    1e3e:	4bf9                	li	s7,30
          int cc = write(fd, buf, sz);
    1e40:	0000ab17          	auipc	s6,0xa
    1e44:	e78b0b13          	addi	s6,s6,-392 # bcb8 <buf>
        for(int i = 0; i < ci+1; i++){
    1e48:	8a26                	mv	s4,s1
    1e4a:	0209c863          	bltz	s3,1e7a <manywrites+0xc4>
          int fd = open(name, O_CREATE | O_RDWR);
    1e4e:	20200593          	li	a1,514
    1e52:	fa840513          	addi	a0,s0,-88
    1e56:	79d020ef          	jal	4df2 <open>
    1e5a:	892a                	mv	s2,a0
          if(fd < 0){
    1e5c:	02054d63          	bltz	a0,1e96 <manywrites+0xe0>
          int cc = write(fd, buf, sz);
    1e60:	660d                	lui	a2,0x3
    1e62:	85da                	mv	a1,s6
    1e64:	76f020ef          	jal	4dd2 <write>
          if(cc != sz){
    1e68:	678d                	lui	a5,0x3
    1e6a:	04f51263          	bne	a0,a5,1eae <manywrites+0xf8>
          close(fd);
    1e6e:	854a                	mv	a0,s2
    1e70:	76b020ef          	jal	4dda <close>
        for(int i = 0; i < ci+1; i++){
    1e74:	2a05                	addiw	s4,s4,1
    1e76:	fd49dce3          	bge	s3,s4,1e4e <manywrites+0x98>
        unlink(name);
    1e7a:	fa840513          	addi	a0,s0,-88
    1e7e:	785020ef          	jal	4e02 <unlink>
      for(int iters = 0; iters < howmany; iters++){
    1e82:	3bfd                	addiw	s7,s7,-1
    1e84:	fc0b92e3          	bnez	s7,1e48 <manywrites+0x92>
      unlink(name);
    1e88:	fa840513          	addi	a0,s0,-88
    1e8c:	777020ef          	jal	4e02 <unlink>
      exit(0);
    1e90:	4501                	li	a0,0
    1e92:	721020ef          	jal	4db2 <exit>
            printf("%s: cannot create %s\n", s, name);
    1e96:	fa840613          	addi	a2,s0,-88
    1e9a:	85d6                	mv	a1,s5
    1e9c:	00004517          	auipc	a0,0x4
    1ea0:	12c50513          	addi	a0,a0,300 # 5fc8 <malloc+0xd1a>
    1ea4:	356030ef          	jal	51fa <printf>
            exit(1);
    1ea8:	4505                	li	a0,1
    1eaa:	709020ef          	jal	4db2 <exit>
            printf("%s: write(%d) ret %d\n", s, sz, cc);
    1eae:	86aa                	mv	a3,a0
    1eb0:	660d                	lui	a2,0x3
    1eb2:	85d6                	mv	a1,s5
    1eb4:	00003517          	auipc	a0,0x3
    1eb8:	60450513          	addi	a0,a0,1540 # 54b8 <malloc+0x20a>
    1ebc:	33e030ef          	jal	51fa <printf>
            exit(1);
    1ec0:	4505                	li	a0,1
    1ec2:	6f1020ef          	jal	4db2 <exit>
      exit(st);
    1ec6:	6ed020ef          	jal	4db2 <exit>

0000000000001eca <copyinstr3>:
{
    1eca:	7179                	addi	sp,sp,-48
    1ecc:	f406                	sd	ra,40(sp)
    1ece:	f022                	sd	s0,32(sp)
    1ed0:	ec26                	sd	s1,24(sp)
    1ed2:	1800                	addi	s0,sp,48
  sbrk(8192);
    1ed4:	6509                	lui	a0,0x2
    1ed6:	66b020ef          	jal	4d40 <sbrk>
  uint64 top = (uint64) sbrk(0);
    1eda:	4501                	li	a0,0
    1edc:	665020ef          	jal	4d40 <sbrk>
  if((top % PGSIZE) != 0){
    1ee0:	03451793          	slli	a5,a0,0x34
    1ee4:	e7bd                	bnez	a5,1f52 <copyinstr3+0x88>
  top = (uint64) sbrk(0);
    1ee6:	4501                	li	a0,0
    1ee8:	659020ef          	jal	4d40 <sbrk>
  if(top % PGSIZE){
    1eec:	03451793          	slli	a5,a0,0x34
    1ef0:	ebad                	bnez	a5,1f62 <copyinstr3+0x98>
  char *b = (char *) (top - 1);
    1ef2:	fff50493          	addi	s1,a0,-1 # 1fff <rwsbrk+0x31>
  *b = 'x';
    1ef6:	07800793          	li	a5,120
    1efa:	fef50fa3          	sb	a5,-1(a0)
  int ret = unlink(b);
    1efe:	8526                	mv	a0,s1
    1f00:	703020ef          	jal	4e02 <unlink>
  if(ret != -1){
    1f04:	57fd                	li	a5,-1
    1f06:	06f51763          	bne	a0,a5,1f74 <copyinstr3+0xaa>
  int fd = open(b, O_CREATE | O_WRONLY);
    1f0a:	20100593          	li	a1,513
    1f0e:	8526                	mv	a0,s1
    1f10:	6e3020ef          	jal	4df2 <open>
  if(fd != -1){
    1f14:	57fd                	li	a5,-1
    1f16:	06f51a63          	bne	a0,a5,1f8a <copyinstr3+0xc0>
  ret = link(b, b);
    1f1a:	85a6                	mv	a1,s1
    1f1c:	8526                	mv	a0,s1
    1f1e:	6f5020ef          	jal	4e12 <link>
  if(ret != -1){
    1f22:	57fd                	li	a5,-1
    1f24:	06f51e63          	bne	a0,a5,1fa0 <copyinstr3+0xd6>
  char *args[] = { "xx", 0 };
    1f28:	00005797          	auipc	a5,0x5
    1f2c:	da078793          	addi	a5,a5,-608 # 6cc8 <malloc+0x1a1a>
    1f30:	fcf43823          	sd	a5,-48(s0)
    1f34:	fc043c23          	sd	zero,-40(s0)
  ret = exec(b, args);
    1f38:	fd040593          	addi	a1,s0,-48
    1f3c:	8526                	mv	a0,s1
    1f3e:	6ad020ef          	jal	4dea <exec>
  if(ret != -1){
    1f42:	57fd                	li	a5,-1
    1f44:	06f51a63          	bne	a0,a5,1fb8 <copyinstr3+0xee>
}
    1f48:	70a2                	ld	ra,40(sp)
    1f4a:	7402                	ld	s0,32(sp)
    1f4c:	64e2                	ld	s1,24(sp)
    1f4e:	6145                	addi	sp,sp,48
    1f50:	8082                	ret
    sbrk(PGSIZE - (top % PGSIZE));
    1f52:	0347d513          	srli	a0,a5,0x34
    1f56:	6785                	lui	a5,0x1
    1f58:	40a7853b          	subw	a0,a5,a0
    1f5c:	5e5020ef          	jal	4d40 <sbrk>
    1f60:	b759                	j	1ee6 <copyinstr3+0x1c>
    printf("oops\n");
    1f62:	00004517          	auipc	a0,0x4
    1f66:	07e50513          	addi	a0,a0,126 # 5fe0 <malloc+0xd32>
    1f6a:	290030ef          	jal	51fa <printf>
    exit(1);
    1f6e:	4505                	li	a0,1
    1f70:	643020ef          	jal	4db2 <exit>
    printf("unlink(%s) returned %d, not -1\n", b, ret);
    1f74:	862a                	mv	a2,a0
    1f76:	85a6                	mv	a1,s1
    1f78:	00004517          	auipc	a0,0x4
    1f7c:	c2050513          	addi	a0,a0,-992 # 5b98 <malloc+0x8ea>
    1f80:	27a030ef          	jal	51fa <printf>
    exit(1);
    1f84:	4505                	li	a0,1
    1f86:	62d020ef          	jal	4db2 <exit>
    printf("open(%s) returned %d, not -1\n", b, fd);
    1f8a:	862a                	mv	a2,a0
    1f8c:	85a6                	mv	a1,s1
    1f8e:	00004517          	auipc	a0,0x4
    1f92:	c2a50513          	addi	a0,a0,-982 # 5bb8 <malloc+0x90a>
    1f96:	264030ef          	jal	51fa <printf>
    exit(1);
    1f9a:	4505                	li	a0,1
    1f9c:	617020ef          	jal	4db2 <exit>
    printf("link(%s, %s) returned %d, not -1\n", b, b, ret);
    1fa0:	86aa                	mv	a3,a0
    1fa2:	8626                	mv	a2,s1
    1fa4:	85a6                	mv	a1,s1
    1fa6:	00004517          	auipc	a0,0x4
    1faa:	c3250513          	addi	a0,a0,-974 # 5bd8 <malloc+0x92a>
    1fae:	24c030ef          	jal	51fa <printf>
    exit(1);
    1fb2:	4505                	li	a0,1
    1fb4:	5ff020ef          	jal	4db2 <exit>
    printf("exec(%s) returned %d, not -1\n", b, fd);
    1fb8:	567d                	li	a2,-1
    1fba:	85a6                	mv	a1,s1
    1fbc:	00004517          	auipc	a0,0x4
    1fc0:	c4450513          	addi	a0,a0,-956 # 5c00 <malloc+0x952>
    1fc4:	236030ef          	jal	51fa <printf>
    exit(1);
    1fc8:	4505                	li	a0,1
    1fca:	5e9020ef          	jal	4db2 <exit>

0000000000001fce <rwsbrk>:
{
    1fce:	1101                	addi	sp,sp,-32
    1fd0:	ec06                	sd	ra,24(sp)
    1fd2:	e822                	sd	s0,16(sp)
    1fd4:	1000                	addi	s0,sp,32
  uint64 a = (uint64) sbrk(8192);
    1fd6:	6509                	lui	a0,0x2
    1fd8:	569020ef          	jal	4d40 <sbrk>
  if(a == (uint64) SBRK_ERROR) {
    1fdc:	57fd                	li	a5,-1
    1fde:	04f50a63          	beq	a0,a5,2032 <rwsbrk+0x64>
    1fe2:	e426                	sd	s1,8(sp)
    1fe4:	84aa                	mv	s1,a0
  if (sbrk(-8192) == SBRK_ERROR) {
    1fe6:	7579                	lui	a0,0xffffe
    1fe8:	559020ef          	jal	4d40 <sbrk>
    1fec:	57fd                	li	a5,-1
    1fee:	04f50d63          	beq	a0,a5,2048 <rwsbrk+0x7a>
    1ff2:	e04a                	sd	s2,0(sp)
  fd = open("rwsbrk", O_CREATE|O_WRONLY);
    1ff4:	20100593          	li	a1,513
    1ff8:	00004517          	auipc	a0,0x4
    1ffc:	02850513          	addi	a0,a0,40 # 6020 <malloc+0xd72>
    2000:	5f3020ef          	jal	4df2 <open>
    2004:	892a                	mv	s2,a0
  if(fd < 0){
    2006:	04054b63          	bltz	a0,205c <rwsbrk+0x8e>
  n = write(fd, (void*)(a+PGSIZE), 1024);
    200a:	6785                	lui	a5,0x1
    200c:	94be                	add	s1,s1,a5
    200e:	40000613          	li	a2,1024
    2012:	85a6                	mv	a1,s1
    2014:	5bf020ef          	jal	4dd2 <write>
    2018:	862a                	mv	a2,a0
  if(n >= 0){
    201a:	04054a63          	bltz	a0,206e <rwsbrk+0xa0>
    printf("write(fd, %p, 1024) returned %d, not -1\n", (void*)a+PGSIZE, n);
    201e:	85a6                	mv	a1,s1
    2020:	00004517          	auipc	a0,0x4
    2024:	02050513          	addi	a0,a0,32 # 6040 <malloc+0xd92>
    2028:	1d2030ef          	jal	51fa <printf>
    exit(1);
    202c:	4505                	li	a0,1
    202e:	585020ef          	jal	4db2 <exit>
    2032:	e426                	sd	s1,8(sp)
    2034:	e04a                	sd	s2,0(sp)
    printf("sbrk(rwsbrk) failed\n");
    2036:	00004517          	auipc	a0,0x4
    203a:	fb250513          	addi	a0,a0,-78 # 5fe8 <malloc+0xd3a>
    203e:	1bc030ef          	jal	51fa <printf>
    exit(1);
    2042:	4505                	li	a0,1
    2044:	56f020ef          	jal	4db2 <exit>
    2048:	e04a                	sd	s2,0(sp)
    printf("sbrk(rwsbrk) shrink failed\n");
    204a:	00004517          	auipc	a0,0x4
    204e:	fb650513          	addi	a0,a0,-74 # 6000 <malloc+0xd52>
    2052:	1a8030ef          	jal	51fa <printf>
    exit(1);
    2056:	4505                	li	a0,1
    2058:	55b020ef          	jal	4db2 <exit>
    printf("open(rwsbrk) failed\n");
    205c:	00004517          	auipc	a0,0x4
    2060:	fcc50513          	addi	a0,a0,-52 # 6028 <malloc+0xd7a>
    2064:	196030ef          	jal	51fa <printf>
    exit(1);
    2068:	4505                	li	a0,1
    206a:	549020ef          	jal	4db2 <exit>
  close(fd);
    206e:	854a                	mv	a0,s2
    2070:	56b020ef          	jal	4dda <close>
  unlink("rwsbrk");
    2074:	00004517          	auipc	a0,0x4
    2078:	fac50513          	addi	a0,a0,-84 # 6020 <malloc+0xd72>
    207c:	587020ef          	jal	4e02 <unlink>
  fd = open("README", O_RDONLY);
    2080:	4581                	li	a1,0
    2082:	00003517          	auipc	a0,0x3
    2086:	53e50513          	addi	a0,a0,1342 # 55c0 <malloc+0x312>
    208a:	569020ef          	jal	4df2 <open>
    208e:	892a                	mv	s2,a0
  if(fd < 0){
    2090:	02054363          	bltz	a0,20b6 <rwsbrk+0xe8>
  n = read(fd, (void*)(a+PGSIZE), 10);
    2094:	4629                	li	a2,10
    2096:	85a6                	mv	a1,s1
    2098:	533020ef          	jal	4dca <read>
    209c:	862a                	mv	a2,a0
  if(n >= 0){
    209e:	02054563          	bltz	a0,20c8 <rwsbrk+0xfa>
    printf("read(fd, %p, 10) returned %d, not -1\n", (void*)a+PGSIZE, n);
    20a2:	85a6                	mv	a1,s1
    20a4:	00004517          	auipc	a0,0x4
    20a8:	fcc50513          	addi	a0,a0,-52 # 6070 <malloc+0xdc2>
    20ac:	14e030ef          	jal	51fa <printf>
    exit(1);
    20b0:	4505                	li	a0,1
    20b2:	501020ef          	jal	4db2 <exit>
    printf("open(README) failed\n");
    20b6:	00003517          	auipc	a0,0x3
    20ba:	51250513          	addi	a0,a0,1298 # 55c8 <malloc+0x31a>
    20be:	13c030ef          	jal	51fa <printf>
    exit(1);
    20c2:	4505                	li	a0,1
    20c4:	4ef020ef          	jal	4db2 <exit>
  close(fd);
    20c8:	854a                	mv	a0,s2
    20ca:	511020ef          	jal	4dda <close>
  exit(0);
    20ce:	4501                	li	a0,0
    20d0:	4e3020ef          	jal	4db2 <exit>

00000000000020d4 <sbrkbasic>:
{
    20d4:	7139                	addi	sp,sp,-64
    20d6:	fc06                	sd	ra,56(sp)
    20d8:	f822                	sd	s0,48(sp)
    20da:	ec4e                	sd	s3,24(sp)
    20dc:	0080                	addi	s0,sp,64
    20de:	89aa                	mv	s3,a0
  pid = fork();
    20e0:	4cb020ef          	jal	4daa <fork>
  if(pid < 0){
    20e4:	02054b63          	bltz	a0,211a <sbrkbasic+0x46>
  if(pid == 0){
    20e8:	e939                	bnez	a0,213e <sbrkbasic+0x6a>
    a = sbrk(TOOMUCH);
    20ea:	40000537          	lui	a0,0x40000
    20ee:	453020ef          	jal	4d40 <sbrk>
    if(a == (char*)SBRK_ERROR){
    20f2:	57fd                	li	a5,-1
    20f4:	02f50f63          	beq	a0,a5,2132 <sbrkbasic+0x5e>
    20f8:	f426                	sd	s1,40(sp)
    20fa:	f04a                	sd	s2,32(sp)
    20fc:	e852                	sd	s4,16(sp)
    for(b = a; b < a+TOOMUCH; b += PGSIZE){
    20fe:	400007b7          	lui	a5,0x40000
    2102:	97aa                	add	a5,a5,a0
      *b = 99;
    2104:	06300693          	li	a3,99
    for(b = a; b < a+TOOMUCH; b += PGSIZE){
    2108:	6705                	lui	a4,0x1
      *b = 99;
    210a:	00d50023          	sb	a3,0(a0) # 40000000 <base+0x3fff1348>
    for(b = a; b < a+TOOMUCH; b += PGSIZE){
    210e:	953a                	add	a0,a0,a4
    2110:	fef51de3          	bne	a0,a5,210a <sbrkbasic+0x36>
    exit(1);
    2114:	4505                	li	a0,1
    2116:	49d020ef          	jal	4db2 <exit>
    211a:	f426                	sd	s1,40(sp)
    211c:	f04a                	sd	s2,32(sp)
    211e:	e852                	sd	s4,16(sp)
    printf("fork failed in sbrkbasic\n");
    2120:	00004517          	auipc	a0,0x4
    2124:	f7850513          	addi	a0,a0,-136 # 6098 <malloc+0xdea>
    2128:	0d2030ef          	jal	51fa <printf>
    exit(1);
    212c:	4505                	li	a0,1
    212e:	485020ef          	jal	4db2 <exit>
    2132:	f426                	sd	s1,40(sp)
    2134:	f04a                	sd	s2,32(sp)
    2136:	e852                	sd	s4,16(sp)
      exit(0);
    2138:	4501                	li	a0,0
    213a:	479020ef          	jal	4db2 <exit>
  wait(&xstatus);
    213e:	fcc40513          	addi	a0,s0,-52
    2142:	479020ef          	jal	4dba <wait>
  if(xstatus == 1){
    2146:	fcc42703          	lw	a4,-52(s0)
    214a:	4785                	li	a5,1
    214c:	00f70e63          	beq	a4,a5,2168 <sbrkbasic+0x94>
    2150:	f426                	sd	s1,40(sp)
    2152:	f04a                	sd	s2,32(sp)
    2154:	e852                	sd	s4,16(sp)
  a = sbrk(0);
    2156:	4501                	li	a0,0
    2158:	3e9020ef          	jal	4d40 <sbrk>
    215c:	84aa                	mv	s1,a0
  for(i = 0; i < 5000; i++){
    215e:	4901                	li	s2,0
    2160:	6a05                	lui	s4,0x1
    2162:	388a0a13          	addi	s4,s4,904 # 1388 <exectest+0x4a>
    2166:	a839                	j	2184 <sbrkbasic+0xb0>
    2168:	f426                	sd	s1,40(sp)
    216a:	f04a                	sd	s2,32(sp)
    216c:	e852                	sd	s4,16(sp)
    printf("%s: too much memory allocated!\n", s);
    216e:	85ce                	mv	a1,s3
    2170:	00004517          	auipc	a0,0x4
    2174:	f4850513          	addi	a0,a0,-184 # 60b8 <malloc+0xe0a>
    2178:	082030ef          	jal	51fa <printf>
    exit(1);
    217c:	4505                	li	a0,1
    217e:	435020ef          	jal	4db2 <exit>
    2182:	84be                	mv	s1,a5
    b = sbrk(1);
    2184:	4505                	li	a0,1
    2186:	3bb020ef          	jal	4d40 <sbrk>
    if(b != a){
    218a:	04951263          	bne	a0,s1,21ce <sbrkbasic+0xfa>
    *b = 1;
    218e:	4785                	li	a5,1
    2190:	00f48023          	sb	a5,0(s1)
    a = b + 1;
    2194:	00148793          	addi	a5,s1,1
  for(i = 0; i < 5000; i++){
    2198:	2905                	addiw	s2,s2,1
    219a:	ff4914e3          	bne	s2,s4,2182 <sbrkbasic+0xae>
  pid = fork();
    219e:	40d020ef          	jal	4daa <fork>
    21a2:	892a                	mv	s2,a0
  if(pid < 0){
    21a4:	04054263          	bltz	a0,21e8 <sbrkbasic+0x114>
  c = sbrk(1);
    21a8:	4505                	li	a0,1
    21aa:	397020ef          	jal	4d40 <sbrk>
  c = sbrk(1);
    21ae:	4505                	li	a0,1
    21b0:	391020ef          	jal	4d40 <sbrk>
  if(c != a + 1){
    21b4:	0489                	addi	s1,s1,2
    21b6:	04a48363          	beq	s1,a0,21fc <sbrkbasic+0x128>
    printf("%s: sbrk test failed post-fork\n", s);
    21ba:	85ce                	mv	a1,s3
    21bc:	00004517          	auipc	a0,0x4
    21c0:	f5c50513          	addi	a0,a0,-164 # 6118 <malloc+0xe6a>
    21c4:	036030ef          	jal	51fa <printf>
    exit(1);
    21c8:	4505                	li	a0,1
    21ca:	3e9020ef          	jal	4db2 <exit>
      printf("%s: sbrk test failed %d %p %p\n", s, i, a, b);
    21ce:	872a                	mv	a4,a0
    21d0:	86a6                	mv	a3,s1
    21d2:	864a                	mv	a2,s2
    21d4:	85ce                	mv	a1,s3
    21d6:	00004517          	auipc	a0,0x4
    21da:	f0250513          	addi	a0,a0,-254 # 60d8 <malloc+0xe2a>
    21de:	01c030ef          	jal	51fa <printf>
      exit(1);
    21e2:	4505                	li	a0,1
    21e4:	3cf020ef          	jal	4db2 <exit>
    printf("%s: sbrk test fork failed\n", s);
    21e8:	85ce                	mv	a1,s3
    21ea:	00004517          	auipc	a0,0x4
    21ee:	f0e50513          	addi	a0,a0,-242 # 60f8 <malloc+0xe4a>
    21f2:	008030ef          	jal	51fa <printf>
    exit(1);
    21f6:	4505                	li	a0,1
    21f8:	3bb020ef          	jal	4db2 <exit>
  if(pid == 0)
    21fc:	00091563          	bnez	s2,2206 <sbrkbasic+0x132>
    exit(0);
    2200:	4501                	li	a0,0
    2202:	3b1020ef          	jal	4db2 <exit>
  wait(&xstatus);
    2206:	fcc40513          	addi	a0,s0,-52
    220a:	3b1020ef          	jal	4dba <wait>
  exit(xstatus);
    220e:	fcc42503          	lw	a0,-52(s0)
    2212:	3a1020ef          	jal	4db2 <exit>

0000000000002216 <sbrkmuch>:
{
    2216:	7179                	addi	sp,sp,-48
    2218:	f406                	sd	ra,40(sp)
    221a:	f022                	sd	s0,32(sp)
    221c:	ec26                	sd	s1,24(sp)
    221e:	e84a                	sd	s2,16(sp)
    2220:	e44e                	sd	s3,8(sp)
    2222:	e052                	sd	s4,0(sp)
    2224:	1800                	addi	s0,sp,48
    2226:	89aa                	mv	s3,a0
  oldbrk = sbrk(0);
    2228:	4501                	li	a0,0
    222a:	317020ef          	jal	4d40 <sbrk>
    222e:	892a                	mv	s2,a0
  a = sbrk(0);
    2230:	4501                	li	a0,0
    2232:	30f020ef          	jal	4d40 <sbrk>
    2236:	84aa                	mv	s1,a0
  p = sbrk(amt);
    2238:	06400537          	lui	a0,0x6400
    223c:	9d05                	subw	a0,a0,s1
    223e:	303020ef          	jal	4d40 <sbrk>
  if (p != a) {
    2242:	08a49763          	bne	s1,a0,22d0 <sbrkmuch+0xba>
  *lastaddr = 99;
    2246:	064007b7          	lui	a5,0x6400
    224a:	06300713          	li	a4,99
    224e:	fee78fa3          	sb	a4,-1(a5) # 63fffff <base+0x63f1347>
  a = sbrk(0);
    2252:	4501                	li	a0,0
    2254:	2ed020ef          	jal	4d40 <sbrk>
    2258:	84aa                	mv	s1,a0
  c = sbrk(-PGSIZE);
    225a:	757d                	lui	a0,0xfffff
    225c:	2e5020ef          	jal	4d40 <sbrk>
  if(c == (char*)SBRK_ERROR){
    2260:	57fd                	li	a5,-1
    2262:	08f50163          	beq	a0,a5,22e4 <sbrkmuch+0xce>
  c = sbrk(0);
    2266:	4501                	li	a0,0
    2268:	2d9020ef          	jal	4d40 <sbrk>
  if(c != a - PGSIZE){
    226c:	77fd                	lui	a5,0xfffff
    226e:	97a6                	add	a5,a5,s1
    2270:	08f51463          	bne	a0,a5,22f8 <sbrkmuch+0xe2>
  a = sbrk(0);
    2274:	4501                	li	a0,0
    2276:	2cb020ef          	jal	4d40 <sbrk>
    227a:	84aa                	mv	s1,a0
  c = sbrk(PGSIZE);
    227c:	6505                	lui	a0,0x1
    227e:	2c3020ef          	jal	4d40 <sbrk>
    2282:	8a2a                	mv	s4,a0
  if(c != a || sbrk(0) != a + PGSIZE){
    2284:	08a49663          	bne	s1,a0,2310 <sbrkmuch+0xfa>
    2288:	4501                	li	a0,0
    228a:	2b7020ef          	jal	4d40 <sbrk>
    228e:	6785                	lui	a5,0x1
    2290:	97a6                	add	a5,a5,s1
    2292:	06f51f63          	bne	a0,a5,2310 <sbrkmuch+0xfa>
  if(*lastaddr == 99){
    2296:	064007b7          	lui	a5,0x6400
    229a:	fff7c703          	lbu	a4,-1(a5) # 63fffff <base+0x63f1347>
    229e:	06300793          	li	a5,99
    22a2:	08f70363          	beq	a4,a5,2328 <sbrkmuch+0x112>
  a = sbrk(0);
    22a6:	4501                	li	a0,0
    22a8:	299020ef          	jal	4d40 <sbrk>
    22ac:	84aa                	mv	s1,a0
  c = sbrk(-(sbrk(0) - oldbrk));
    22ae:	4501                	li	a0,0
    22b0:	291020ef          	jal	4d40 <sbrk>
    22b4:	40a9053b          	subw	a0,s2,a0
    22b8:	289020ef          	jal	4d40 <sbrk>
  if(c != a){
    22bc:	08a49063          	bne	s1,a0,233c <sbrkmuch+0x126>
}
    22c0:	70a2                	ld	ra,40(sp)
    22c2:	7402                	ld	s0,32(sp)
    22c4:	64e2                	ld	s1,24(sp)
    22c6:	6942                	ld	s2,16(sp)
    22c8:	69a2                	ld	s3,8(sp)
    22ca:	6a02                	ld	s4,0(sp)
    22cc:	6145                	addi	sp,sp,48
    22ce:	8082                	ret
    printf("%s: sbrk test failed to grow big address space; enough phys mem?\n", s);
    22d0:	85ce                	mv	a1,s3
    22d2:	00004517          	auipc	a0,0x4
    22d6:	e6650513          	addi	a0,a0,-410 # 6138 <malloc+0xe8a>
    22da:	721020ef          	jal	51fa <printf>
    exit(1);
    22de:	4505                	li	a0,1
    22e0:	2d3020ef          	jal	4db2 <exit>
    printf("%s: sbrk could not deallocate\n", s);
    22e4:	85ce                	mv	a1,s3
    22e6:	00004517          	auipc	a0,0x4
    22ea:	e9a50513          	addi	a0,a0,-358 # 6180 <malloc+0xed2>
    22ee:	70d020ef          	jal	51fa <printf>
    exit(1);
    22f2:	4505                	li	a0,1
    22f4:	2bf020ef          	jal	4db2 <exit>
    printf("%s: sbrk deallocation produced wrong address, a %p c %p\n", s, a, c);
    22f8:	86aa                	mv	a3,a0
    22fa:	8626                	mv	a2,s1
    22fc:	85ce                	mv	a1,s3
    22fe:	00004517          	auipc	a0,0x4
    2302:	ea250513          	addi	a0,a0,-350 # 61a0 <malloc+0xef2>
    2306:	6f5020ef          	jal	51fa <printf>
    exit(1);
    230a:	4505                	li	a0,1
    230c:	2a7020ef          	jal	4db2 <exit>
    printf("%s: sbrk re-allocation failed, a %p c %p\n", s, a, c);
    2310:	86d2                	mv	a3,s4
    2312:	8626                	mv	a2,s1
    2314:	85ce                	mv	a1,s3
    2316:	00004517          	auipc	a0,0x4
    231a:	eca50513          	addi	a0,a0,-310 # 61e0 <malloc+0xf32>
    231e:	6dd020ef          	jal	51fa <printf>
    exit(1);
    2322:	4505                	li	a0,1
    2324:	28f020ef          	jal	4db2 <exit>
    printf("%s: sbrk de-allocation didn't really deallocate\n", s);
    2328:	85ce                	mv	a1,s3
    232a:	00004517          	auipc	a0,0x4
    232e:	ee650513          	addi	a0,a0,-282 # 6210 <malloc+0xf62>
    2332:	6c9020ef          	jal	51fa <printf>
    exit(1);
    2336:	4505                	li	a0,1
    2338:	27b020ef          	jal	4db2 <exit>
    printf("%s: sbrk downsize failed, a %p c %p\n", s, a, c);
    233c:	86aa                	mv	a3,a0
    233e:	8626                	mv	a2,s1
    2340:	85ce                	mv	a1,s3
    2342:	00004517          	auipc	a0,0x4
    2346:	f0650513          	addi	a0,a0,-250 # 6248 <malloc+0xf9a>
    234a:	6b1020ef          	jal	51fa <printf>
    exit(1);
    234e:	4505                	li	a0,1
    2350:	263020ef          	jal	4db2 <exit>

0000000000002354 <sbrkarg>:
{
    2354:	7179                	addi	sp,sp,-48
    2356:	f406                	sd	ra,40(sp)
    2358:	f022                	sd	s0,32(sp)
    235a:	ec26                	sd	s1,24(sp)
    235c:	e84a                	sd	s2,16(sp)
    235e:	e44e                	sd	s3,8(sp)
    2360:	1800                	addi	s0,sp,48
    2362:	89aa                	mv	s3,a0
  a = sbrk(PGSIZE);
    2364:	6505                	lui	a0,0x1
    2366:	1db020ef          	jal	4d40 <sbrk>
    236a:	892a                	mv	s2,a0
  fd = open("sbrk", O_CREATE|O_WRONLY);
    236c:	20100593          	li	a1,513
    2370:	00004517          	auipc	a0,0x4
    2374:	f0050513          	addi	a0,a0,-256 # 6270 <malloc+0xfc2>
    2378:	27b020ef          	jal	4df2 <open>
    237c:	84aa                	mv	s1,a0
  unlink("sbrk");
    237e:	00004517          	auipc	a0,0x4
    2382:	ef250513          	addi	a0,a0,-270 # 6270 <malloc+0xfc2>
    2386:	27d020ef          	jal	4e02 <unlink>
  if(fd < 0)  {
    238a:	0204c963          	bltz	s1,23bc <sbrkarg+0x68>
  if ((n = write(fd, a, PGSIZE)) < 0) {
    238e:	6605                	lui	a2,0x1
    2390:	85ca                	mv	a1,s2
    2392:	8526                	mv	a0,s1
    2394:	23f020ef          	jal	4dd2 <write>
    2398:	02054c63          	bltz	a0,23d0 <sbrkarg+0x7c>
  close(fd);
    239c:	8526                	mv	a0,s1
    239e:	23d020ef          	jal	4dda <close>
  a = sbrk(PGSIZE);
    23a2:	6505                	lui	a0,0x1
    23a4:	19d020ef          	jal	4d40 <sbrk>
  if(pipe((int *) a) != 0){
    23a8:	21b020ef          	jal	4dc2 <pipe>
    23ac:	ed05                	bnez	a0,23e4 <sbrkarg+0x90>
}
    23ae:	70a2                	ld	ra,40(sp)
    23b0:	7402                	ld	s0,32(sp)
    23b2:	64e2                	ld	s1,24(sp)
    23b4:	6942                	ld	s2,16(sp)
    23b6:	69a2                	ld	s3,8(sp)
    23b8:	6145                	addi	sp,sp,48
    23ba:	8082                	ret
    printf("%s: open sbrk failed\n", s);
    23bc:	85ce                	mv	a1,s3
    23be:	00004517          	auipc	a0,0x4
    23c2:	eba50513          	addi	a0,a0,-326 # 6278 <malloc+0xfca>
    23c6:	635020ef          	jal	51fa <printf>
    exit(1);
    23ca:	4505                	li	a0,1
    23cc:	1e7020ef          	jal	4db2 <exit>
    printf("%s: write sbrk failed\n", s);
    23d0:	85ce                	mv	a1,s3
    23d2:	00004517          	auipc	a0,0x4
    23d6:	ebe50513          	addi	a0,a0,-322 # 6290 <malloc+0xfe2>
    23da:	621020ef          	jal	51fa <printf>
    exit(1);
    23de:	4505                	li	a0,1
    23e0:	1d3020ef          	jal	4db2 <exit>
    printf("%s: pipe() failed\n", s);
    23e4:	85ce                	mv	a1,s3
    23e6:	00004517          	auipc	a0,0x4
    23ea:	99a50513          	addi	a0,a0,-1638 # 5d80 <malloc+0xad2>
    23ee:	60d020ef          	jal	51fa <printf>
    exit(1);
    23f2:	4505                	li	a0,1
    23f4:	1bf020ef          	jal	4db2 <exit>

00000000000023f8 <argptest>:
{
    23f8:	1101                	addi	sp,sp,-32
    23fa:	ec06                	sd	ra,24(sp)
    23fc:	e822                	sd	s0,16(sp)
    23fe:	e426                	sd	s1,8(sp)
    2400:	e04a                	sd	s2,0(sp)
    2402:	1000                	addi	s0,sp,32
    2404:	892a                	mv	s2,a0
  fd = open("init", O_RDONLY);
    2406:	4581                	li	a1,0
    2408:	00004517          	auipc	a0,0x4
    240c:	ea050513          	addi	a0,a0,-352 # 62a8 <malloc+0xffa>
    2410:	1e3020ef          	jal	4df2 <open>
  if (fd < 0) {
    2414:	02054563          	bltz	a0,243e <argptest+0x46>
    2418:	84aa                	mv	s1,a0
  read(fd, sbrk(0) - 1, -1);
    241a:	4501                	li	a0,0
    241c:	125020ef          	jal	4d40 <sbrk>
    2420:	567d                	li	a2,-1
    2422:	fff50593          	addi	a1,a0,-1
    2426:	8526                	mv	a0,s1
    2428:	1a3020ef          	jal	4dca <read>
  close(fd);
    242c:	8526                	mv	a0,s1
    242e:	1ad020ef          	jal	4dda <close>
}
    2432:	60e2                	ld	ra,24(sp)
    2434:	6442                	ld	s0,16(sp)
    2436:	64a2                	ld	s1,8(sp)
    2438:	6902                	ld	s2,0(sp)
    243a:	6105                	addi	sp,sp,32
    243c:	8082                	ret
    printf("%s: open failed\n", s);
    243e:	85ca                	mv	a1,s2
    2440:	00004517          	auipc	a0,0x4
    2444:	85050513          	addi	a0,a0,-1968 # 5c90 <malloc+0x9e2>
    2448:	5b3020ef          	jal	51fa <printf>
    exit(1);
    244c:	4505                	li	a0,1
    244e:	165020ef          	jal	4db2 <exit>

0000000000002452 <sbrkbugs>:
{
    2452:	1141                	addi	sp,sp,-16
    2454:	e406                	sd	ra,8(sp)
    2456:	e022                	sd	s0,0(sp)
    2458:	0800                	addi	s0,sp,16
  int pid = fork();
    245a:	151020ef          	jal	4daa <fork>
  if(pid < 0){
    245e:	00054c63          	bltz	a0,2476 <sbrkbugs+0x24>
  if(pid == 0){
    2462:	e11d                	bnez	a0,2488 <sbrkbugs+0x36>
    int sz = (uint64) sbrk(0);
    2464:	0dd020ef          	jal	4d40 <sbrk>
    sbrk(-sz);
    2468:	40a0053b          	negw	a0,a0
    246c:	0d5020ef          	jal	4d40 <sbrk>
    exit(0);
    2470:	4501                	li	a0,0
    2472:	141020ef          	jal	4db2 <exit>
    printf("fork failed\n");
    2476:	00005517          	auipc	a0,0x5
    247a:	daa50513          	addi	a0,a0,-598 # 7220 <malloc+0x1f72>
    247e:	57d020ef          	jal	51fa <printf>
    exit(1);
    2482:	4505                	li	a0,1
    2484:	12f020ef          	jal	4db2 <exit>
  wait(0);
    2488:	4501                	li	a0,0
    248a:	131020ef          	jal	4dba <wait>
  pid = fork();
    248e:	11d020ef          	jal	4daa <fork>
  if(pid < 0){
    2492:	00054f63          	bltz	a0,24b0 <sbrkbugs+0x5e>
  if(pid == 0){
    2496:	e515                	bnez	a0,24c2 <sbrkbugs+0x70>
    int sz = (uint64) sbrk(0);
    2498:	0a9020ef          	jal	4d40 <sbrk>
    sbrk(-(sz - 3500));
    249c:	6785                	lui	a5,0x1
    249e:	dac7879b          	addiw	a5,a5,-596 # dac <linktest+0x138>
    24a2:	40a7853b          	subw	a0,a5,a0
    24a6:	09b020ef          	jal	4d40 <sbrk>
    exit(0);
    24aa:	4501                	li	a0,0
    24ac:	107020ef          	jal	4db2 <exit>
    printf("fork failed\n");
    24b0:	00005517          	auipc	a0,0x5
    24b4:	d7050513          	addi	a0,a0,-656 # 7220 <malloc+0x1f72>
    24b8:	543020ef          	jal	51fa <printf>
    exit(1);
    24bc:	4505                	li	a0,1
    24be:	0f5020ef          	jal	4db2 <exit>
  wait(0);
    24c2:	4501                	li	a0,0
    24c4:	0f7020ef          	jal	4dba <wait>
  pid = fork();
    24c8:	0e3020ef          	jal	4daa <fork>
  if(pid < 0){
    24cc:	02054263          	bltz	a0,24f0 <sbrkbugs+0x9e>
  if(pid == 0){
    24d0:	e90d                	bnez	a0,2502 <sbrkbugs+0xb0>
    sbrk((10*PGSIZE + 2048) - (uint64)sbrk(0));
    24d2:	06f020ef          	jal	4d40 <sbrk>
    24d6:	67ad                	lui	a5,0xb
    24d8:	8007879b          	addiw	a5,a5,-2048 # a800 <uninit+0x1258>
    24dc:	40a7853b          	subw	a0,a5,a0
    24e0:	061020ef          	jal	4d40 <sbrk>
    sbrk(-10);
    24e4:	5559                	li	a0,-10
    24e6:	05b020ef          	jal	4d40 <sbrk>
    exit(0);
    24ea:	4501                	li	a0,0
    24ec:	0c7020ef          	jal	4db2 <exit>
    printf("fork failed\n");
    24f0:	00005517          	auipc	a0,0x5
    24f4:	d3050513          	addi	a0,a0,-720 # 7220 <malloc+0x1f72>
    24f8:	503020ef          	jal	51fa <printf>
    exit(1);
    24fc:	4505                	li	a0,1
    24fe:	0b5020ef          	jal	4db2 <exit>
  wait(0);
    2502:	4501                	li	a0,0
    2504:	0b7020ef          	jal	4dba <wait>
  exit(0);
    2508:	4501                	li	a0,0
    250a:	0a9020ef          	jal	4db2 <exit>

000000000000250e <sbrklast>:
{
    250e:	7179                	addi	sp,sp,-48
    2510:	f406                	sd	ra,40(sp)
    2512:	f022                	sd	s0,32(sp)
    2514:	ec26                	sd	s1,24(sp)
    2516:	e84a                	sd	s2,16(sp)
    2518:	e44e                	sd	s3,8(sp)
    251a:	e052                	sd	s4,0(sp)
    251c:	1800                	addi	s0,sp,48
  uint64 top = (uint64) sbrk(0);
    251e:	4501                	li	a0,0
    2520:	021020ef          	jal	4d40 <sbrk>
  if((top % PGSIZE) != 0)
    2524:	03451793          	slli	a5,a0,0x34
    2528:	ebad                	bnez	a5,259a <sbrklast+0x8c>
  sbrk(PGSIZE);
    252a:	6505                	lui	a0,0x1
    252c:	015020ef          	jal	4d40 <sbrk>
  sbrk(10);
    2530:	4529                	li	a0,10
    2532:	00f020ef          	jal	4d40 <sbrk>
  sbrk(-20);
    2536:	5531                	li	a0,-20
    2538:	009020ef          	jal	4d40 <sbrk>
  top = (uint64) sbrk(0);
    253c:	4501                	li	a0,0
    253e:	003020ef          	jal	4d40 <sbrk>
    2542:	84aa                	mv	s1,a0
  char *p = (char *) (top - 64);
    2544:	fc050913          	addi	s2,a0,-64 # fc0 <bigdir+0x122>
  p[0] = 'x';
    2548:	07800a13          	li	s4,120
    254c:	fd450023          	sb	s4,-64(a0)
  p[1] = '\0';
    2550:	fc0500a3          	sb	zero,-63(a0)
  int fd = open(p, O_RDWR|O_CREATE);
    2554:	20200593          	li	a1,514
    2558:	854a                	mv	a0,s2
    255a:	099020ef          	jal	4df2 <open>
    255e:	89aa                	mv	s3,a0
  write(fd, p, 1);
    2560:	4605                	li	a2,1
    2562:	85ca                	mv	a1,s2
    2564:	06f020ef          	jal	4dd2 <write>
  close(fd);
    2568:	854e                	mv	a0,s3
    256a:	071020ef          	jal	4dda <close>
  fd = open(p, O_RDWR);
    256e:	4589                	li	a1,2
    2570:	854a                	mv	a0,s2
    2572:	081020ef          	jal	4df2 <open>
  p[0] = '\0';
    2576:	fc048023          	sb	zero,-64(s1)
  read(fd, p, 1);
    257a:	4605                	li	a2,1
    257c:	85ca                	mv	a1,s2
    257e:	04d020ef          	jal	4dca <read>
  if(p[0] != 'x')
    2582:	fc04c783          	lbu	a5,-64(s1)
    2586:	03479263          	bne	a5,s4,25aa <sbrklast+0x9c>
}
    258a:	70a2                	ld	ra,40(sp)
    258c:	7402                	ld	s0,32(sp)
    258e:	64e2                	ld	s1,24(sp)
    2590:	6942                	ld	s2,16(sp)
    2592:	69a2                	ld	s3,8(sp)
    2594:	6a02                	ld	s4,0(sp)
    2596:	6145                	addi	sp,sp,48
    2598:	8082                	ret
    sbrk(PGSIZE - (top % PGSIZE));
    259a:	0347d513          	srli	a0,a5,0x34
    259e:	6785                	lui	a5,0x1
    25a0:	40a7853b          	subw	a0,a5,a0
    25a4:	79c020ef          	jal	4d40 <sbrk>
    25a8:	b749                	j	252a <sbrklast+0x1c>
    exit(1);
    25aa:	4505                	li	a0,1
    25ac:	007020ef          	jal	4db2 <exit>

00000000000025b0 <sbrk8000>:
{
    25b0:	1141                	addi	sp,sp,-16
    25b2:	e406                	sd	ra,8(sp)
    25b4:	e022                	sd	s0,0(sp)
    25b6:	0800                	addi	s0,sp,16
  sbrk(0x80000004);
    25b8:	80000537          	lui	a0,0x80000
    25bc:	0511                	addi	a0,a0,4 # ffffffff80000004 <base+0xffffffff7fff134c>
    25be:	782020ef          	jal	4d40 <sbrk>
  volatile char *top = sbrk(0);
    25c2:	4501                	li	a0,0
    25c4:	77c020ef          	jal	4d40 <sbrk>
  *(top-1) = *(top-1) + 1;
    25c8:	fff54783          	lbu	a5,-1(a0)
    25cc:	2785                	addiw	a5,a5,1 # 1001 <badarg+0x1>
    25ce:	0ff7f793          	zext.b	a5,a5
    25d2:	fef50fa3          	sb	a5,-1(a0)
}
    25d6:	60a2                	ld	ra,8(sp)
    25d8:	6402                	ld	s0,0(sp)
    25da:	0141                	addi	sp,sp,16
    25dc:	8082                	ret

00000000000025de <execout>:
{
    25de:	715d                	addi	sp,sp,-80
    25e0:	e486                	sd	ra,72(sp)
    25e2:	e0a2                	sd	s0,64(sp)
    25e4:	fc26                	sd	s1,56(sp)
    25e6:	f84a                	sd	s2,48(sp)
    25e8:	f44e                	sd	s3,40(sp)
    25ea:	f052                	sd	s4,32(sp)
    25ec:	0880                	addi	s0,sp,80
  for(int avail = 0; avail < 15; avail++){
    25ee:	4901                	li	s2,0
    25f0:	49bd                	li	s3,15
    int pid = fork();
    25f2:	7b8020ef          	jal	4daa <fork>
    25f6:	84aa                	mv	s1,a0
    if(pid < 0){
    25f8:	00054c63          	bltz	a0,2610 <execout+0x32>
    } else if(pid == 0){
    25fc:	c11d                	beqz	a0,2622 <execout+0x44>
      wait((int*)0);
    25fe:	4501                	li	a0,0
    2600:	7ba020ef          	jal	4dba <wait>
  for(int avail = 0; avail < 15; avail++){
    2604:	2905                	addiw	s2,s2,1
    2606:	ff3916e3          	bne	s2,s3,25f2 <execout+0x14>
  exit(0);
    260a:	4501                	li	a0,0
    260c:	7a6020ef          	jal	4db2 <exit>
      printf("fork failed\n");
    2610:	00005517          	auipc	a0,0x5
    2614:	c1050513          	addi	a0,a0,-1008 # 7220 <malloc+0x1f72>
    2618:	3e3020ef          	jal	51fa <printf>
      exit(1);
    261c:	4505                	li	a0,1
    261e:	794020ef          	jal	4db2 <exit>
        if(a == SBRK_ERROR)
    2622:	59fd                	li	s3,-1
        *(a + PGSIZE - 1) = 1;
    2624:	4a05                	li	s4,1
        char *a = sbrk(PGSIZE);
    2626:	6505                	lui	a0,0x1
    2628:	718020ef          	jal	4d40 <sbrk>
        if(a == SBRK_ERROR)
    262c:	01350763          	beq	a0,s3,263a <execout+0x5c>
        *(a + PGSIZE - 1) = 1;
    2630:	6785                	lui	a5,0x1
    2632:	953e                	add	a0,a0,a5
    2634:	ff450fa3          	sb	s4,-1(a0) # fff <pgbug+0x2b>
      while(1){
    2638:	b7fd                	j	2626 <execout+0x48>
      for(int i = 0; i < avail; i++)
    263a:	01205863          	blez	s2,264a <execout+0x6c>
        sbrk(-PGSIZE);
    263e:	757d                	lui	a0,0xfffff
    2640:	700020ef          	jal	4d40 <sbrk>
      for(int i = 0; i < avail; i++)
    2644:	2485                	addiw	s1,s1,1
    2646:	ff249ce3          	bne	s1,s2,263e <execout+0x60>
      close(1);
    264a:	4505                	li	a0,1
    264c:	78e020ef          	jal	4dda <close>
      char *args[] = { "echo", "x", 0 };
    2650:	00003517          	auipc	a0,0x3
    2654:	d9850513          	addi	a0,a0,-616 # 53e8 <malloc+0x13a>
    2658:	faa43c23          	sd	a0,-72(s0)
    265c:	00003797          	auipc	a5,0x3
    2660:	dfc78793          	addi	a5,a5,-516 # 5458 <malloc+0x1aa>
    2664:	fcf43023          	sd	a5,-64(s0)
    2668:	fc043423          	sd	zero,-56(s0)
      exec("echo", args);
    266c:	fb840593          	addi	a1,s0,-72
    2670:	77a020ef          	jal	4dea <exec>
      exit(0);
    2674:	4501                	li	a0,0
    2676:	73c020ef          	jal	4db2 <exit>

000000000000267a <fourteen>:
{
    267a:	1101                	addi	sp,sp,-32
    267c:	ec06                	sd	ra,24(sp)
    267e:	e822                	sd	s0,16(sp)
    2680:	e426                	sd	s1,8(sp)
    2682:	1000                	addi	s0,sp,32
    2684:	84aa                	mv	s1,a0
  if(mkdir("12345678901234") != 0){
    2686:	00004517          	auipc	a0,0x4
    268a:	dfa50513          	addi	a0,a0,-518 # 6480 <malloc+0x11d2>
    268e:	78c020ef          	jal	4e1a <mkdir>
    2692:	e555                	bnez	a0,273e <fourteen+0xc4>
  if(mkdir("12345678901234/123456789012345") != 0){
    2694:	00004517          	auipc	a0,0x4
    2698:	c4450513          	addi	a0,a0,-956 # 62d8 <malloc+0x102a>
    269c:	77e020ef          	jal	4e1a <mkdir>
    26a0:	e94d                	bnez	a0,2752 <fourteen+0xd8>
  fd = open("123456789012345/123456789012345/123456789012345", O_CREATE);
    26a2:	20000593          	li	a1,512
    26a6:	00004517          	auipc	a0,0x4
    26aa:	c8a50513          	addi	a0,a0,-886 # 6330 <malloc+0x1082>
    26ae:	744020ef          	jal	4df2 <open>
  if(fd < 0){
    26b2:	0a054a63          	bltz	a0,2766 <fourteen+0xec>
  close(fd);
    26b6:	724020ef          	jal	4dda <close>
  fd = open("12345678901234/12345678901234/12345678901234", 0);
    26ba:	4581                	li	a1,0
    26bc:	00004517          	auipc	a0,0x4
    26c0:	cec50513          	addi	a0,a0,-788 # 63a8 <malloc+0x10fa>
    26c4:	72e020ef          	jal	4df2 <open>
  if(fd < 0){
    26c8:	0a054963          	bltz	a0,277a <fourteen+0x100>
  close(fd);
    26cc:	70e020ef          	jal	4dda <close>
  if(mkdir("12345678901234/12345678901234") == 0){
    26d0:	00004517          	auipc	a0,0x4
    26d4:	d4850513          	addi	a0,a0,-696 # 6418 <malloc+0x116a>
    26d8:	742020ef          	jal	4e1a <mkdir>
    26dc:	c94d                	beqz	a0,278e <fourteen+0x114>
  if(mkdir("123456789012345/12345678901234") == 0){
    26de:	00004517          	auipc	a0,0x4
    26e2:	d9250513          	addi	a0,a0,-622 # 6470 <malloc+0x11c2>
    26e6:	734020ef          	jal	4e1a <mkdir>
    26ea:	cd45                	beqz	a0,27a2 <fourteen+0x128>
  unlink("123456789012345/12345678901234");
    26ec:	00004517          	auipc	a0,0x4
    26f0:	d8450513          	addi	a0,a0,-636 # 6470 <malloc+0x11c2>
    26f4:	70e020ef          	jal	4e02 <unlink>
  unlink("12345678901234/12345678901234");
    26f8:	00004517          	auipc	a0,0x4
    26fc:	d2050513          	addi	a0,a0,-736 # 6418 <malloc+0x116a>
    2700:	702020ef          	jal	4e02 <unlink>
  unlink("12345678901234/12345678901234/12345678901234");
    2704:	00004517          	auipc	a0,0x4
    2708:	ca450513          	addi	a0,a0,-860 # 63a8 <malloc+0x10fa>
    270c:	6f6020ef          	jal	4e02 <unlink>
  unlink("123456789012345/123456789012345/123456789012345");
    2710:	00004517          	auipc	a0,0x4
    2714:	c2050513          	addi	a0,a0,-992 # 6330 <malloc+0x1082>
    2718:	6ea020ef          	jal	4e02 <unlink>
  unlink("12345678901234/123456789012345");
    271c:	00004517          	auipc	a0,0x4
    2720:	bbc50513          	addi	a0,a0,-1092 # 62d8 <malloc+0x102a>
    2724:	6de020ef          	jal	4e02 <unlink>
  unlink("12345678901234");
    2728:	00004517          	auipc	a0,0x4
    272c:	d5850513          	addi	a0,a0,-680 # 6480 <malloc+0x11d2>
    2730:	6d2020ef          	jal	4e02 <unlink>
}
    2734:	60e2                	ld	ra,24(sp)
    2736:	6442                	ld	s0,16(sp)
    2738:	64a2                	ld	s1,8(sp)
    273a:	6105                	addi	sp,sp,32
    273c:	8082                	ret
    printf("%s: mkdir 12345678901234 failed\n", s);
    273e:	85a6                	mv	a1,s1
    2740:	00004517          	auipc	a0,0x4
    2744:	b7050513          	addi	a0,a0,-1168 # 62b0 <malloc+0x1002>
    2748:	2b3020ef          	jal	51fa <printf>
    exit(1);
    274c:	4505                	li	a0,1
    274e:	664020ef          	jal	4db2 <exit>
    printf("%s: mkdir 12345678901234/123456789012345 failed\n", s);
    2752:	85a6                	mv	a1,s1
    2754:	00004517          	auipc	a0,0x4
    2758:	ba450513          	addi	a0,a0,-1116 # 62f8 <malloc+0x104a>
    275c:	29f020ef          	jal	51fa <printf>
    exit(1);
    2760:	4505                	li	a0,1
    2762:	650020ef          	jal	4db2 <exit>
    printf("%s: create 123456789012345/123456789012345/123456789012345 failed\n", s);
    2766:	85a6                	mv	a1,s1
    2768:	00004517          	auipc	a0,0x4
    276c:	bf850513          	addi	a0,a0,-1032 # 6360 <malloc+0x10b2>
    2770:	28b020ef          	jal	51fa <printf>
    exit(1);
    2774:	4505                	li	a0,1
    2776:	63c020ef          	jal	4db2 <exit>
    printf("%s: open 12345678901234/12345678901234/12345678901234 failed\n", s);
    277a:	85a6                	mv	a1,s1
    277c:	00004517          	auipc	a0,0x4
    2780:	c5c50513          	addi	a0,a0,-932 # 63d8 <malloc+0x112a>
    2784:	277020ef          	jal	51fa <printf>
    exit(1);
    2788:	4505                	li	a0,1
    278a:	628020ef          	jal	4db2 <exit>
    printf("%s: mkdir 12345678901234/12345678901234 succeeded!\n", s);
    278e:	85a6                	mv	a1,s1
    2790:	00004517          	auipc	a0,0x4
    2794:	ca850513          	addi	a0,a0,-856 # 6438 <malloc+0x118a>
    2798:	263020ef          	jal	51fa <printf>
    exit(1);
    279c:	4505                	li	a0,1
    279e:	614020ef          	jal	4db2 <exit>
    printf("%s: mkdir 12345678901234/123456789012345 succeeded!\n", s);
    27a2:	85a6                	mv	a1,s1
    27a4:	00004517          	auipc	a0,0x4
    27a8:	cec50513          	addi	a0,a0,-788 # 6490 <malloc+0x11e2>
    27ac:	24f020ef          	jal	51fa <printf>
    exit(1);
    27b0:	4505                	li	a0,1
    27b2:	600020ef          	jal	4db2 <exit>

00000000000027b6 <diskfull>:
{
    27b6:	b8010113          	addi	sp,sp,-1152
    27ba:	46113c23          	sd	ra,1144(sp)
    27be:	46813823          	sd	s0,1136(sp)
    27c2:	46913423          	sd	s1,1128(sp)
    27c6:	47213023          	sd	s2,1120(sp)
    27ca:	45313c23          	sd	s3,1112(sp)
    27ce:	45413823          	sd	s4,1104(sp)
    27d2:	45513423          	sd	s5,1096(sp)
    27d6:	45613023          	sd	s6,1088(sp)
    27da:	43713c23          	sd	s7,1080(sp)
    27de:	43813823          	sd	s8,1072(sp)
    27e2:	43913423          	sd	s9,1064(sp)
    27e6:	48010413          	addi	s0,sp,1152
    27ea:	8caa                	mv	s9,a0
  unlink("diskfulldir");
    27ec:	00004517          	auipc	a0,0x4
    27f0:	cdc50513          	addi	a0,a0,-804 # 64c8 <malloc+0x121a>
    27f4:	60e020ef          	jal	4e02 <unlink>
    27f8:	03000993          	li	s3,48
    name[0] = 'b';
    27fc:	06200b13          	li	s6,98
    name[1] = 'i';
    2800:	06900a93          	li	s5,105
    name[2] = 'g';
    2804:	06700a13          	li	s4,103
    2808:	10c00b93          	li	s7,268
  for(fi = 0; done == 0 && '0' + fi < 0177; fi++){
    280c:	07f00c13          	li	s8,127
    2810:	aab9                	j	296e <diskfull+0x1b8>
      printf("%s: could not create file %s\n", s, name);
    2812:	b8040613          	addi	a2,s0,-1152
    2816:	85e6                	mv	a1,s9
    2818:	00004517          	auipc	a0,0x4
    281c:	cc050513          	addi	a0,a0,-832 # 64d8 <malloc+0x122a>
    2820:	1db020ef          	jal	51fa <printf>
      break;
    2824:	a039                	j	2832 <diskfull+0x7c>
        close(fd);
    2826:	854a                	mv	a0,s2
    2828:	5b2020ef          	jal	4dda <close>
    close(fd);
    282c:	854a                	mv	a0,s2
    282e:	5ac020ef          	jal	4dda <close>
  for(int i = 0; i < nzz; i++){
    2832:	4481                	li	s1,0
    name[0] = 'z';
    2834:	07a00913          	li	s2,122
  for(int i = 0; i < nzz; i++){
    2838:	08000993          	li	s3,128
    name[0] = 'z';
    283c:	bb240023          	sb	s2,-1120(s0)
    name[1] = 'z';
    2840:	bb2400a3          	sb	s2,-1119(s0)
    name[2] = '0' + (i / 32);
    2844:	41f4d71b          	sraiw	a4,s1,0x1f
    2848:	01b7571b          	srliw	a4,a4,0x1b
    284c:	009707bb          	addw	a5,a4,s1
    2850:	4057d69b          	sraiw	a3,a5,0x5
    2854:	0306869b          	addiw	a3,a3,48
    2858:	bad40123          	sb	a3,-1118(s0)
    name[3] = '0' + (i % 32);
    285c:	8bfd                	andi	a5,a5,31
    285e:	9f99                	subw	a5,a5,a4
    2860:	0307879b          	addiw	a5,a5,48
    2864:	baf401a3          	sb	a5,-1117(s0)
    name[4] = '\0';
    2868:	ba040223          	sb	zero,-1116(s0)
    unlink(name);
    286c:	ba040513          	addi	a0,s0,-1120
    2870:	592020ef          	jal	4e02 <unlink>
    int fd = open(name, O_CREATE|O_RDWR|O_TRUNC);
    2874:	60200593          	li	a1,1538
    2878:	ba040513          	addi	a0,s0,-1120
    287c:	576020ef          	jal	4df2 <open>
    if(fd < 0)
    2880:	00054763          	bltz	a0,288e <diskfull+0xd8>
    close(fd);
    2884:	556020ef          	jal	4dda <close>
  for(int i = 0; i < nzz; i++){
    2888:	2485                	addiw	s1,s1,1
    288a:	fb3499e3          	bne	s1,s3,283c <diskfull+0x86>
  if(mkdir("diskfulldir") == 0)
    288e:	00004517          	auipc	a0,0x4
    2892:	c3a50513          	addi	a0,a0,-966 # 64c8 <malloc+0x121a>
    2896:	584020ef          	jal	4e1a <mkdir>
    289a:	12050063          	beqz	a0,29ba <diskfull+0x204>
  unlink("diskfulldir");
    289e:	00004517          	auipc	a0,0x4
    28a2:	c2a50513          	addi	a0,a0,-982 # 64c8 <malloc+0x121a>
    28a6:	55c020ef          	jal	4e02 <unlink>
  for(int i = 0; i < nzz; i++){
    28aa:	4481                	li	s1,0
    name[0] = 'z';
    28ac:	07a00913          	li	s2,122
  for(int i = 0; i < nzz; i++){
    28b0:	08000993          	li	s3,128
    name[0] = 'z';
    28b4:	bb240023          	sb	s2,-1120(s0)
    name[1] = 'z';
    28b8:	bb2400a3          	sb	s2,-1119(s0)
    name[2] = '0' + (i / 32);
    28bc:	41f4d71b          	sraiw	a4,s1,0x1f
    28c0:	01b7571b          	srliw	a4,a4,0x1b
    28c4:	009707bb          	addw	a5,a4,s1
    28c8:	4057d69b          	sraiw	a3,a5,0x5
    28cc:	0306869b          	addiw	a3,a3,48
    28d0:	bad40123          	sb	a3,-1118(s0)
    name[3] = '0' + (i % 32);
    28d4:	8bfd                	andi	a5,a5,31
    28d6:	9f99                	subw	a5,a5,a4
    28d8:	0307879b          	addiw	a5,a5,48
    28dc:	baf401a3          	sb	a5,-1117(s0)
    name[4] = '\0';
    28e0:	ba040223          	sb	zero,-1116(s0)
    unlink(name);
    28e4:	ba040513          	addi	a0,s0,-1120
    28e8:	51a020ef          	jal	4e02 <unlink>
  for(int i = 0; i < nzz; i++){
    28ec:	2485                	addiw	s1,s1,1
    28ee:	fd3493e3          	bne	s1,s3,28b4 <diskfull+0xfe>
    28f2:	03000493          	li	s1,48
    name[0] = 'b';
    28f6:	06200a93          	li	s5,98
    name[1] = 'i';
    28fa:	06900a13          	li	s4,105
    name[2] = 'g';
    28fe:	06700993          	li	s3,103
  for(int i = 0; '0' + i < 0177; i++){
    2902:	07f00913          	li	s2,127
    name[0] = 'b';
    2906:	bb540023          	sb	s5,-1120(s0)
    name[1] = 'i';
    290a:	bb4400a3          	sb	s4,-1119(s0)
    name[2] = 'g';
    290e:	bb340123          	sb	s3,-1118(s0)
    name[3] = '0' + i;
    2912:	ba9401a3          	sb	s1,-1117(s0)
    name[4] = '\0';
    2916:	ba040223          	sb	zero,-1116(s0)
    unlink(name);
    291a:	ba040513          	addi	a0,s0,-1120
    291e:	4e4020ef          	jal	4e02 <unlink>
  for(int i = 0; '0' + i < 0177; i++){
    2922:	2485                	addiw	s1,s1,1
    2924:	0ff4f493          	zext.b	s1,s1
    2928:	fd249fe3          	bne	s1,s2,2906 <diskfull+0x150>
}
    292c:	47813083          	ld	ra,1144(sp)
    2930:	47013403          	ld	s0,1136(sp)
    2934:	46813483          	ld	s1,1128(sp)
    2938:	46013903          	ld	s2,1120(sp)
    293c:	45813983          	ld	s3,1112(sp)
    2940:	45013a03          	ld	s4,1104(sp)
    2944:	44813a83          	ld	s5,1096(sp)
    2948:	44013b03          	ld	s6,1088(sp)
    294c:	43813b83          	ld	s7,1080(sp)
    2950:	43013c03          	ld	s8,1072(sp)
    2954:	42813c83          	ld	s9,1064(sp)
    2958:	48010113          	addi	sp,sp,1152
    295c:	8082                	ret
    close(fd);
    295e:	854a                	mv	a0,s2
    2960:	47a020ef          	jal	4dda <close>
  for(fi = 0; done == 0 && '0' + fi < 0177; fi++){
    2964:	2985                	addiw	s3,s3,1
    2966:	0ff9f993          	zext.b	s3,s3
    296a:	ed8984e3          	beq	s3,s8,2832 <diskfull+0x7c>
    name[0] = 'b';
    296e:	b9640023          	sb	s6,-1152(s0)
    name[1] = 'i';
    2972:	b95400a3          	sb	s5,-1151(s0)
    name[2] = 'g';
    2976:	b9440123          	sb	s4,-1150(s0)
    name[3] = '0' + fi;
    297a:	b93401a3          	sb	s3,-1149(s0)
    name[4] = '\0';
    297e:	b8040223          	sb	zero,-1148(s0)
    unlink(name);
    2982:	b8040513          	addi	a0,s0,-1152
    2986:	47c020ef          	jal	4e02 <unlink>
    int fd = open(name, O_CREATE|O_RDWR|O_TRUNC);
    298a:	60200593          	li	a1,1538
    298e:	b8040513          	addi	a0,s0,-1152
    2992:	460020ef          	jal	4df2 <open>
    2996:	892a                	mv	s2,a0
    if(fd < 0){
    2998:	e6054de3          	bltz	a0,2812 <diskfull+0x5c>
    299c:	84de                	mv	s1,s7
      if(write(fd, buf, BSIZE) != BSIZE){
    299e:	40000613          	li	a2,1024
    29a2:	ba040593          	addi	a1,s0,-1120
    29a6:	854a                	mv	a0,s2
    29a8:	42a020ef          	jal	4dd2 <write>
    29ac:	40000793          	li	a5,1024
    29b0:	e6f51be3          	bne	a0,a5,2826 <diskfull+0x70>
    for(int i = 0; i < MAXFILE; i++){
    29b4:	34fd                	addiw	s1,s1,-1
    29b6:	f4e5                	bnez	s1,299e <diskfull+0x1e8>
    29b8:	b75d                	j	295e <diskfull+0x1a8>
    printf("%s: mkdir(diskfulldir) unexpectedly succeeded!\n", s);
    29ba:	85e6                	mv	a1,s9
    29bc:	00004517          	auipc	a0,0x4
    29c0:	b3c50513          	addi	a0,a0,-1220 # 64f8 <malloc+0x124a>
    29c4:	037020ef          	jal	51fa <printf>
    29c8:	bdd9                	j	289e <diskfull+0xe8>

00000000000029ca <iputtest>:
{
    29ca:	1101                	addi	sp,sp,-32
    29cc:	ec06                	sd	ra,24(sp)
    29ce:	e822                	sd	s0,16(sp)
    29d0:	e426                	sd	s1,8(sp)
    29d2:	1000                	addi	s0,sp,32
    29d4:	84aa                	mv	s1,a0
  if(mkdir("iputdir") < 0){
    29d6:	00004517          	auipc	a0,0x4
    29da:	b5250513          	addi	a0,a0,-1198 # 6528 <malloc+0x127a>
    29de:	43c020ef          	jal	4e1a <mkdir>
    29e2:	02054f63          	bltz	a0,2a20 <iputtest+0x56>
  if(chdir("iputdir") < 0){
    29e6:	00004517          	auipc	a0,0x4
    29ea:	b4250513          	addi	a0,a0,-1214 # 6528 <malloc+0x127a>
    29ee:	434020ef          	jal	4e22 <chdir>
    29f2:	04054163          	bltz	a0,2a34 <iputtest+0x6a>
  if(unlink("../iputdir") < 0){
    29f6:	00004517          	auipc	a0,0x4
    29fa:	b7250513          	addi	a0,a0,-1166 # 6568 <malloc+0x12ba>
    29fe:	404020ef          	jal	4e02 <unlink>
    2a02:	04054363          	bltz	a0,2a48 <iputtest+0x7e>
  if(chdir("/") < 0){
    2a06:	00004517          	auipc	a0,0x4
    2a0a:	b9250513          	addi	a0,a0,-1134 # 6598 <malloc+0x12ea>
    2a0e:	414020ef          	jal	4e22 <chdir>
    2a12:	04054563          	bltz	a0,2a5c <iputtest+0x92>
}
    2a16:	60e2                	ld	ra,24(sp)
    2a18:	6442                	ld	s0,16(sp)
    2a1a:	64a2                	ld	s1,8(sp)
    2a1c:	6105                	addi	sp,sp,32
    2a1e:	8082                	ret
    printf("%s: mkdir failed\n", s);
    2a20:	85a6                	mv	a1,s1
    2a22:	00004517          	auipc	a0,0x4
    2a26:	b0e50513          	addi	a0,a0,-1266 # 6530 <malloc+0x1282>
    2a2a:	7d0020ef          	jal	51fa <printf>
    exit(1);
    2a2e:	4505                	li	a0,1
    2a30:	382020ef          	jal	4db2 <exit>
    printf("%s: chdir iputdir failed\n", s);
    2a34:	85a6                	mv	a1,s1
    2a36:	00004517          	auipc	a0,0x4
    2a3a:	b1250513          	addi	a0,a0,-1262 # 6548 <malloc+0x129a>
    2a3e:	7bc020ef          	jal	51fa <printf>
    exit(1);
    2a42:	4505                	li	a0,1
    2a44:	36e020ef          	jal	4db2 <exit>
    printf("%s: unlink ../iputdir failed\n", s);
    2a48:	85a6                	mv	a1,s1
    2a4a:	00004517          	auipc	a0,0x4
    2a4e:	b2e50513          	addi	a0,a0,-1234 # 6578 <malloc+0x12ca>
    2a52:	7a8020ef          	jal	51fa <printf>
    exit(1);
    2a56:	4505                	li	a0,1
    2a58:	35a020ef          	jal	4db2 <exit>
    printf("%s: chdir / failed\n", s);
    2a5c:	85a6                	mv	a1,s1
    2a5e:	00004517          	auipc	a0,0x4
    2a62:	b4250513          	addi	a0,a0,-1214 # 65a0 <malloc+0x12f2>
    2a66:	794020ef          	jal	51fa <printf>
    exit(1);
    2a6a:	4505                	li	a0,1
    2a6c:	346020ef          	jal	4db2 <exit>

0000000000002a70 <exitiputtest>:
{
    2a70:	7179                	addi	sp,sp,-48
    2a72:	f406                	sd	ra,40(sp)
    2a74:	f022                	sd	s0,32(sp)
    2a76:	ec26                	sd	s1,24(sp)
    2a78:	1800                	addi	s0,sp,48
    2a7a:	84aa                	mv	s1,a0
  pid = fork();
    2a7c:	32e020ef          	jal	4daa <fork>
  if(pid < 0){
    2a80:	02054e63          	bltz	a0,2abc <exitiputtest+0x4c>
  if(pid == 0){
    2a84:	e541                	bnez	a0,2b0c <exitiputtest+0x9c>
    if(mkdir("iputdir") < 0){
    2a86:	00004517          	auipc	a0,0x4
    2a8a:	aa250513          	addi	a0,a0,-1374 # 6528 <malloc+0x127a>
    2a8e:	38c020ef          	jal	4e1a <mkdir>
    2a92:	02054f63          	bltz	a0,2ad0 <exitiputtest+0x60>
    if(chdir("iputdir") < 0){
    2a96:	00004517          	auipc	a0,0x4
    2a9a:	a9250513          	addi	a0,a0,-1390 # 6528 <malloc+0x127a>
    2a9e:	384020ef          	jal	4e22 <chdir>
    2aa2:	04054163          	bltz	a0,2ae4 <exitiputtest+0x74>
    if(unlink("../iputdir") < 0){
    2aa6:	00004517          	auipc	a0,0x4
    2aaa:	ac250513          	addi	a0,a0,-1342 # 6568 <malloc+0x12ba>
    2aae:	354020ef          	jal	4e02 <unlink>
    2ab2:	04054363          	bltz	a0,2af8 <exitiputtest+0x88>
    exit(0);
    2ab6:	4501                	li	a0,0
    2ab8:	2fa020ef          	jal	4db2 <exit>
    printf("%s: fork failed\n", s);
    2abc:	85a6                	mv	a1,s1
    2abe:	00003517          	auipc	a0,0x3
    2ac2:	1ba50513          	addi	a0,a0,442 # 5c78 <malloc+0x9ca>
    2ac6:	734020ef          	jal	51fa <printf>
    exit(1);
    2aca:	4505                	li	a0,1
    2acc:	2e6020ef          	jal	4db2 <exit>
      printf("%s: mkdir failed\n", s);
    2ad0:	85a6                	mv	a1,s1
    2ad2:	00004517          	auipc	a0,0x4
    2ad6:	a5e50513          	addi	a0,a0,-1442 # 6530 <malloc+0x1282>
    2ada:	720020ef          	jal	51fa <printf>
      exit(1);
    2ade:	4505                	li	a0,1
    2ae0:	2d2020ef          	jal	4db2 <exit>
      printf("%s: child chdir failed\n", s);
    2ae4:	85a6                	mv	a1,s1
    2ae6:	00004517          	auipc	a0,0x4
    2aea:	ad250513          	addi	a0,a0,-1326 # 65b8 <malloc+0x130a>
    2aee:	70c020ef          	jal	51fa <printf>
      exit(1);
    2af2:	4505                	li	a0,1
    2af4:	2be020ef          	jal	4db2 <exit>
      printf("%s: unlink ../iputdir failed\n", s);
    2af8:	85a6                	mv	a1,s1
    2afa:	00004517          	auipc	a0,0x4
    2afe:	a7e50513          	addi	a0,a0,-1410 # 6578 <malloc+0x12ca>
    2b02:	6f8020ef          	jal	51fa <printf>
      exit(1);
    2b06:	4505                	li	a0,1
    2b08:	2aa020ef          	jal	4db2 <exit>
  wait(&xstatus);
    2b0c:	fdc40513          	addi	a0,s0,-36
    2b10:	2aa020ef          	jal	4dba <wait>
  exit(xstatus);
    2b14:	fdc42503          	lw	a0,-36(s0)
    2b18:	29a020ef          	jal	4db2 <exit>

0000000000002b1c <dirtest>:
{
    2b1c:	1101                	addi	sp,sp,-32
    2b1e:	ec06                	sd	ra,24(sp)
    2b20:	e822                	sd	s0,16(sp)
    2b22:	e426                	sd	s1,8(sp)
    2b24:	1000                	addi	s0,sp,32
    2b26:	84aa                	mv	s1,a0
  if(mkdir("dir0") < 0){
    2b28:	00004517          	auipc	a0,0x4
    2b2c:	aa850513          	addi	a0,a0,-1368 # 65d0 <malloc+0x1322>
    2b30:	2ea020ef          	jal	4e1a <mkdir>
    2b34:	02054f63          	bltz	a0,2b72 <dirtest+0x56>
  if(chdir("dir0") < 0){
    2b38:	00004517          	auipc	a0,0x4
    2b3c:	a9850513          	addi	a0,a0,-1384 # 65d0 <malloc+0x1322>
    2b40:	2e2020ef          	jal	4e22 <chdir>
    2b44:	04054163          	bltz	a0,2b86 <dirtest+0x6a>
  if(chdir("..") < 0){
    2b48:	00004517          	auipc	a0,0x4
    2b4c:	aa850513          	addi	a0,a0,-1368 # 65f0 <malloc+0x1342>
    2b50:	2d2020ef          	jal	4e22 <chdir>
    2b54:	04054363          	bltz	a0,2b9a <dirtest+0x7e>
  if(unlink("dir0") < 0){
    2b58:	00004517          	auipc	a0,0x4
    2b5c:	a7850513          	addi	a0,a0,-1416 # 65d0 <malloc+0x1322>
    2b60:	2a2020ef          	jal	4e02 <unlink>
    2b64:	04054563          	bltz	a0,2bae <dirtest+0x92>
}
    2b68:	60e2                	ld	ra,24(sp)
    2b6a:	6442                	ld	s0,16(sp)
    2b6c:	64a2                	ld	s1,8(sp)
    2b6e:	6105                	addi	sp,sp,32
    2b70:	8082                	ret
    printf("%s: mkdir failed\n", s);
    2b72:	85a6                	mv	a1,s1
    2b74:	00004517          	auipc	a0,0x4
    2b78:	9bc50513          	addi	a0,a0,-1604 # 6530 <malloc+0x1282>
    2b7c:	67e020ef          	jal	51fa <printf>
    exit(1);
    2b80:	4505                	li	a0,1
    2b82:	230020ef          	jal	4db2 <exit>
    printf("%s: chdir dir0 failed\n", s);
    2b86:	85a6                	mv	a1,s1
    2b88:	00004517          	auipc	a0,0x4
    2b8c:	a5050513          	addi	a0,a0,-1456 # 65d8 <malloc+0x132a>
    2b90:	66a020ef          	jal	51fa <printf>
    exit(1);
    2b94:	4505                	li	a0,1
    2b96:	21c020ef          	jal	4db2 <exit>
    printf("%s: chdir .. failed\n", s);
    2b9a:	85a6                	mv	a1,s1
    2b9c:	00004517          	auipc	a0,0x4
    2ba0:	a5c50513          	addi	a0,a0,-1444 # 65f8 <malloc+0x134a>
    2ba4:	656020ef          	jal	51fa <printf>
    exit(1);
    2ba8:	4505                	li	a0,1
    2baa:	208020ef          	jal	4db2 <exit>
    printf("%s: unlink dir0 failed\n", s);
    2bae:	85a6                	mv	a1,s1
    2bb0:	00004517          	auipc	a0,0x4
    2bb4:	a6050513          	addi	a0,a0,-1440 # 6610 <malloc+0x1362>
    2bb8:	642020ef          	jal	51fa <printf>
    exit(1);
    2bbc:	4505                	li	a0,1
    2bbe:	1f4020ef          	jal	4db2 <exit>

0000000000002bc2 <subdir>:
{
    2bc2:	1101                	addi	sp,sp,-32
    2bc4:	ec06                	sd	ra,24(sp)
    2bc6:	e822                	sd	s0,16(sp)
    2bc8:	e426                	sd	s1,8(sp)
    2bca:	e04a                	sd	s2,0(sp)
    2bcc:	1000                	addi	s0,sp,32
    2bce:	892a                	mv	s2,a0
  unlink("ff");
    2bd0:	00004517          	auipc	a0,0x4
    2bd4:	b8850513          	addi	a0,a0,-1144 # 6758 <malloc+0x14aa>
    2bd8:	22a020ef          	jal	4e02 <unlink>
  if(mkdir("dd") != 0){
    2bdc:	00004517          	auipc	a0,0x4
    2be0:	a4c50513          	addi	a0,a0,-1460 # 6628 <malloc+0x137a>
    2be4:	236020ef          	jal	4e1a <mkdir>
    2be8:	2e051263          	bnez	a0,2ecc <subdir+0x30a>
  fd = open("dd/ff", O_CREATE | O_RDWR);
    2bec:	20200593          	li	a1,514
    2bf0:	00004517          	auipc	a0,0x4
    2bf4:	a5850513          	addi	a0,a0,-1448 # 6648 <malloc+0x139a>
    2bf8:	1fa020ef          	jal	4df2 <open>
    2bfc:	84aa                	mv	s1,a0
  if(fd < 0){
    2bfe:	2e054163          	bltz	a0,2ee0 <subdir+0x31e>
  write(fd, "ff", 2);
    2c02:	4609                	li	a2,2
    2c04:	00004597          	auipc	a1,0x4
    2c08:	b5458593          	addi	a1,a1,-1196 # 6758 <malloc+0x14aa>
    2c0c:	1c6020ef          	jal	4dd2 <write>
  close(fd);
    2c10:	8526                	mv	a0,s1
    2c12:	1c8020ef          	jal	4dda <close>
  if(unlink("dd") >= 0){
    2c16:	00004517          	auipc	a0,0x4
    2c1a:	a1250513          	addi	a0,a0,-1518 # 6628 <malloc+0x137a>
    2c1e:	1e4020ef          	jal	4e02 <unlink>
    2c22:	2c055963          	bgez	a0,2ef4 <subdir+0x332>
  if(mkdir("/dd/dd") != 0){
    2c26:	00004517          	auipc	a0,0x4
    2c2a:	a7a50513          	addi	a0,a0,-1414 # 66a0 <malloc+0x13f2>
    2c2e:	1ec020ef          	jal	4e1a <mkdir>
    2c32:	2c051b63          	bnez	a0,2f08 <subdir+0x346>
  fd = open("dd/dd/ff", O_CREATE | O_RDWR);
    2c36:	20200593          	li	a1,514
    2c3a:	00004517          	auipc	a0,0x4
    2c3e:	a8e50513          	addi	a0,a0,-1394 # 66c8 <malloc+0x141a>
    2c42:	1b0020ef          	jal	4df2 <open>
    2c46:	84aa                	mv	s1,a0
  if(fd < 0){
    2c48:	2c054a63          	bltz	a0,2f1c <subdir+0x35a>
  write(fd, "FF", 2);
    2c4c:	4609                	li	a2,2
    2c4e:	00004597          	auipc	a1,0x4
    2c52:	aaa58593          	addi	a1,a1,-1366 # 66f8 <malloc+0x144a>
    2c56:	17c020ef          	jal	4dd2 <write>
  close(fd);
    2c5a:	8526                	mv	a0,s1
    2c5c:	17e020ef          	jal	4dda <close>
  fd = open("dd/dd/../ff", 0);
    2c60:	4581                	li	a1,0
    2c62:	00004517          	auipc	a0,0x4
    2c66:	a9e50513          	addi	a0,a0,-1378 # 6700 <malloc+0x1452>
    2c6a:	188020ef          	jal	4df2 <open>
    2c6e:	84aa                	mv	s1,a0
  if(fd < 0){
    2c70:	2c054063          	bltz	a0,2f30 <subdir+0x36e>
  cc = read(fd, buf, sizeof(buf));
    2c74:	660d                	lui	a2,0x3
    2c76:	00009597          	auipc	a1,0x9
    2c7a:	04258593          	addi	a1,a1,66 # bcb8 <buf>
    2c7e:	14c020ef          	jal	4dca <read>
  if(cc != 2 || buf[0] != 'f'){
    2c82:	4789                	li	a5,2
    2c84:	2cf51063          	bne	a0,a5,2f44 <subdir+0x382>
    2c88:	00009717          	auipc	a4,0x9
    2c8c:	03074703          	lbu	a4,48(a4) # bcb8 <buf>
    2c90:	06600793          	li	a5,102
    2c94:	2af71863          	bne	a4,a5,2f44 <subdir+0x382>
  close(fd);
    2c98:	8526                	mv	a0,s1
    2c9a:	140020ef          	jal	4dda <close>
  if(link("dd/dd/ff", "dd/dd/ffff") != 0){
    2c9e:	00004597          	auipc	a1,0x4
    2ca2:	ab258593          	addi	a1,a1,-1358 # 6750 <malloc+0x14a2>
    2ca6:	00004517          	auipc	a0,0x4
    2caa:	a2250513          	addi	a0,a0,-1502 # 66c8 <malloc+0x141a>
    2cae:	164020ef          	jal	4e12 <link>
    2cb2:	2a051363          	bnez	a0,2f58 <subdir+0x396>
  if(unlink("dd/dd/ff") != 0){
    2cb6:	00004517          	auipc	a0,0x4
    2cba:	a1250513          	addi	a0,a0,-1518 # 66c8 <malloc+0x141a>
    2cbe:	144020ef          	jal	4e02 <unlink>
    2cc2:	2a051563          	bnez	a0,2f6c <subdir+0x3aa>
  if(open("dd/dd/ff", O_RDONLY) >= 0){
    2cc6:	4581                	li	a1,0
    2cc8:	00004517          	auipc	a0,0x4
    2ccc:	a0050513          	addi	a0,a0,-1536 # 66c8 <malloc+0x141a>
    2cd0:	122020ef          	jal	4df2 <open>
    2cd4:	2a055663          	bgez	a0,2f80 <subdir+0x3be>
  if(chdir("dd") != 0){
    2cd8:	00004517          	auipc	a0,0x4
    2cdc:	95050513          	addi	a0,a0,-1712 # 6628 <malloc+0x137a>
    2ce0:	142020ef          	jal	4e22 <chdir>
    2ce4:	2a051863          	bnez	a0,2f94 <subdir+0x3d2>
  if(chdir("dd/../../dd") != 0){
    2ce8:	00004517          	auipc	a0,0x4
    2cec:	b0050513          	addi	a0,a0,-1280 # 67e8 <malloc+0x153a>
    2cf0:	132020ef          	jal	4e22 <chdir>
    2cf4:	2a051a63          	bnez	a0,2fa8 <subdir+0x3e6>
  if(chdir("dd/../../../dd") != 0){
    2cf8:	00004517          	auipc	a0,0x4
    2cfc:	b2050513          	addi	a0,a0,-1248 # 6818 <malloc+0x156a>
    2d00:	122020ef          	jal	4e22 <chdir>
    2d04:	2a051c63          	bnez	a0,2fbc <subdir+0x3fa>
  if(chdir("./..") != 0){
    2d08:	00004517          	auipc	a0,0x4
    2d0c:	b4850513          	addi	a0,a0,-1208 # 6850 <malloc+0x15a2>
    2d10:	112020ef          	jal	4e22 <chdir>
    2d14:	2a051e63          	bnez	a0,2fd0 <subdir+0x40e>
  fd = open("dd/dd/ffff", 0);
    2d18:	4581                	li	a1,0
    2d1a:	00004517          	auipc	a0,0x4
    2d1e:	a3650513          	addi	a0,a0,-1482 # 6750 <malloc+0x14a2>
    2d22:	0d0020ef          	jal	4df2 <open>
    2d26:	84aa                	mv	s1,a0
  if(fd < 0){
    2d28:	2a054e63          	bltz	a0,2fe4 <subdir+0x422>
  if(read(fd, buf, sizeof(buf)) != 2){
    2d2c:	660d                	lui	a2,0x3
    2d2e:	00009597          	auipc	a1,0x9
    2d32:	f8a58593          	addi	a1,a1,-118 # bcb8 <buf>
    2d36:	094020ef          	jal	4dca <read>
    2d3a:	4789                	li	a5,2
    2d3c:	2af51e63          	bne	a0,a5,2ff8 <subdir+0x436>
  close(fd);
    2d40:	8526                	mv	a0,s1
    2d42:	098020ef          	jal	4dda <close>
  if(open("dd/dd/ff", O_RDONLY) >= 0){
    2d46:	4581                	li	a1,0
    2d48:	00004517          	auipc	a0,0x4
    2d4c:	98050513          	addi	a0,a0,-1664 # 66c8 <malloc+0x141a>
    2d50:	0a2020ef          	jal	4df2 <open>
    2d54:	2a055c63          	bgez	a0,300c <subdir+0x44a>
  if(open("dd/ff/ff", O_CREATE|O_RDWR) >= 0){
    2d58:	20200593          	li	a1,514
    2d5c:	00004517          	auipc	a0,0x4
    2d60:	b8450513          	addi	a0,a0,-1148 # 68e0 <malloc+0x1632>
    2d64:	08e020ef          	jal	4df2 <open>
    2d68:	2a055c63          	bgez	a0,3020 <subdir+0x45e>
  if(open("dd/xx/ff", O_CREATE|O_RDWR) >= 0){
    2d6c:	20200593          	li	a1,514
    2d70:	00004517          	auipc	a0,0x4
    2d74:	ba050513          	addi	a0,a0,-1120 # 6910 <malloc+0x1662>
    2d78:	07a020ef          	jal	4df2 <open>
    2d7c:	2a055c63          	bgez	a0,3034 <subdir+0x472>
  if(open("dd", O_CREATE) >= 0){
    2d80:	20000593          	li	a1,512
    2d84:	00004517          	auipc	a0,0x4
    2d88:	8a450513          	addi	a0,a0,-1884 # 6628 <malloc+0x137a>
    2d8c:	066020ef          	jal	4df2 <open>
    2d90:	2a055c63          	bgez	a0,3048 <subdir+0x486>
  if(open("dd", O_RDWR) >= 0){
    2d94:	4589                	li	a1,2
    2d96:	00004517          	auipc	a0,0x4
    2d9a:	89250513          	addi	a0,a0,-1902 # 6628 <malloc+0x137a>
    2d9e:	054020ef          	jal	4df2 <open>
    2da2:	2a055d63          	bgez	a0,305c <subdir+0x49a>
  if(open("dd", O_WRONLY) >= 0){
    2da6:	4585                	li	a1,1
    2da8:	00004517          	auipc	a0,0x4
    2dac:	88050513          	addi	a0,a0,-1920 # 6628 <malloc+0x137a>
    2db0:	042020ef          	jal	4df2 <open>
    2db4:	2a055e63          	bgez	a0,3070 <subdir+0x4ae>
  if(link("dd/ff/ff", "dd/dd/xx") == 0){
    2db8:	00004597          	auipc	a1,0x4
    2dbc:	be858593          	addi	a1,a1,-1048 # 69a0 <malloc+0x16f2>
    2dc0:	00004517          	auipc	a0,0x4
    2dc4:	b2050513          	addi	a0,a0,-1248 # 68e0 <malloc+0x1632>
    2dc8:	04a020ef          	jal	4e12 <link>
    2dcc:	2a050c63          	beqz	a0,3084 <subdir+0x4c2>
  if(link("dd/xx/ff", "dd/dd/xx") == 0){
    2dd0:	00004597          	auipc	a1,0x4
    2dd4:	bd058593          	addi	a1,a1,-1072 # 69a0 <malloc+0x16f2>
    2dd8:	00004517          	auipc	a0,0x4
    2ddc:	b3850513          	addi	a0,a0,-1224 # 6910 <malloc+0x1662>
    2de0:	032020ef          	jal	4e12 <link>
    2de4:	2a050a63          	beqz	a0,3098 <subdir+0x4d6>
  if(link("dd/ff", "dd/dd/ffff") == 0){
    2de8:	00004597          	auipc	a1,0x4
    2dec:	96858593          	addi	a1,a1,-1688 # 6750 <malloc+0x14a2>
    2df0:	00004517          	auipc	a0,0x4
    2df4:	85850513          	addi	a0,a0,-1960 # 6648 <malloc+0x139a>
    2df8:	01a020ef          	jal	4e12 <link>
    2dfc:	2a050863          	beqz	a0,30ac <subdir+0x4ea>
  if(mkdir("dd/ff/ff") == 0){
    2e00:	00004517          	auipc	a0,0x4
    2e04:	ae050513          	addi	a0,a0,-1312 # 68e0 <malloc+0x1632>
    2e08:	012020ef          	jal	4e1a <mkdir>
    2e0c:	2a050a63          	beqz	a0,30c0 <subdir+0x4fe>
  if(mkdir("dd/xx/ff") == 0){
    2e10:	00004517          	auipc	a0,0x4
    2e14:	b0050513          	addi	a0,a0,-1280 # 6910 <malloc+0x1662>
    2e18:	002020ef          	jal	4e1a <mkdir>
    2e1c:	2a050c63          	beqz	a0,30d4 <subdir+0x512>
  if(mkdir("dd/dd/ffff") == 0){
    2e20:	00004517          	auipc	a0,0x4
    2e24:	93050513          	addi	a0,a0,-1744 # 6750 <malloc+0x14a2>
    2e28:	7f3010ef          	jal	4e1a <mkdir>
    2e2c:	2a050e63          	beqz	a0,30e8 <subdir+0x526>
  if(unlink("dd/xx/ff") == 0){
    2e30:	00004517          	auipc	a0,0x4
    2e34:	ae050513          	addi	a0,a0,-1312 # 6910 <malloc+0x1662>
    2e38:	7cb010ef          	jal	4e02 <unlink>
    2e3c:	2c050063          	beqz	a0,30fc <subdir+0x53a>
  if(unlink("dd/ff/ff") == 0){
    2e40:	00004517          	auipc	a0,0x4
    2e44:	aa050513          	addi	a0,a0,-1376 # 68e0 <malloc+0x1632>
    2e48:	7bb010ef          	jal	4e02 <unlink>
    2e4c:	2c050263          	beqz	a0,3110 <subdir+0x54e>
  if(chdir("dd/ff") == 0){
    2e50:	00003517          	auipc	a0,0x3
    2e54:	7f850513          	addi	a0,a0,2040 # 6648 <malloc+0x139a>
    2e58:	7cb010ef          	jal	4e22 <chdir>
    2e5c:	2c050463          	beqz	a0,3124 <subdir+0x562>
  if(chdir("dd/xx") == 0){
    2e60:	00004517          	auipc	a0,0x4
    2e64:	c9050513          	addi	a0,a0,-880 # 6af0 <malloc+0x1842>
    2e68:	7bb010ef          	jal	4e22 <chdir>
    2e6c:	2c050663          	beqz	a0,3138 <subdir+0x576>
  if(unlink("dd/dd/ffff") != 0){
    2e70:	00004517          	auipc	a0,0x4
    2e74:	8e050513          	addi	a0,a0,-1824 # 6750 <malloc+0x14a2>
    2e78:	78b010ef          	jal	4e02 <unlink>
    2e7c:	2c051863          	bnez	a0,314c <subdir+0x58a>
  if(unlink("dd/ff") != 0){
    2e80:	00003517          	auipc	a0,0x3
    2e84:	7c850513          	addi	a0,a0,1992 # 6648 <malloc+0x139a>
    2e88:	77b010ef          	jal	4e02 <unlink>
    2e8c:	2c051a63          	bnez	a0,3160 <subdir+0x59e>
  if(unlink("dd") == 0){
    2e90:	00003517          	auipc	a0,0x3
    2e94:	79850513          	addi	a0,a0,1944 # 6628 <malloc+0x137a>
    2e98:	76b010ef          	jal	4e02 <unlink>
    2e9c:	2c050c63          	beqz	a0,3174 <subdir+0x5b2>
  if(unlink("dd/dd") < 0){
    2ea0:	00004517          	auipc	a0,0x4
    2ea4:	cc050513          	addi	a0,a0,-832 # 6b60 <malloc+0x18b2>
    2ea8:	75b010ef          	jal	4e02 <unlink>
    2eac:	2c054e63          	bltz	a0,3188 <subdir+0x5c6>
  if(unlink("dd") < 0){
    2eb0:	00003517          	auipc	a0,0x3
    2eb4:	77850513          	addi	a0,a0,1912 # 6628 <malloc+0x137a>
    2eb8:	74b010ef          	jal	4e02 <unlink>
    2ebc:	2e054063          	bltz	a0,319c <subdir+0x5da>
}
    2ec0:	60e2                	ld	ra,24(sp)
    2ec2:	6442                	ld	s0,16(sp)
    2ec4:	64a2                	ld	s1,8(sp)
    2ec6:	6902                	ld	s2,0(sp)
    2ec8:	6105                	addi	sp,sp,32
    2eca:	8082                	ret
    printf("%s: mkdir dd failed\n", s);
    2ecc:	85ca                	mv	a1,s2
    2ece:	00003517          	auipc	a0,0x3
    2ed2:	76250513          	addi	a0,a0,1890 # 6630 <malloc+0x1382>
    2ed6:	324020ef          	jal	51fa <printf>
    exit(1);
    2eda:	4505                	li	a0,1
    2edc:	6d7010ef          	jal	4db2 <exit>
    printf("%s: create dd/ff failed\n", s);
    2ee0:	85ca                	mv	a1,s2
    2ee2:	00003517          	auipc	a0,0x3
    2ee6:	76e50513          	addi	a0,a0,1902 # 6650 <malloc+0x13a2>
    2eea:	310020ef          	jal	51fa <printf>
    exit(1);
    2eee:	4505                	li	a0,1
    2ef0:	6c3010ef          	jal	4db2 <exit>
    printf("%s: unlink dd (non-empty dir) succeeded!\n", s);
    2ef4:	85ca                	mv	a1,s2
    2ef6:	00003517          	auipc	a0,0x3
    2efa:	77a50513          	addi	a0,a0,1914 # 6670 <malloc+0x13c2>
    2efe:	2fc020ef          	jal	51fa <printf>
    exit(1);
    2f02:	4505                	li	a0,1
    2f04:	6af010ef          	jal	4db2 <exit>
    printf("%s: subdir mkdir dd/dd failed\n", s);
    2f08:	85ca                	mv	a1,s2
    2f0a:	00003517          	auipc	a0,0x3
    2f0e:	79e50513          	addi	a0,a0,1950 # 66a8 <malloc+0x13fa>
    2f12:	2e8020ef          	jal	51fa <printf>
    exit(1);
    2f16:	4505                	li	a0,1
    2f18:	69b010ef          	jal	4db2 <exit>
    printf("%s: create dd/dd/ff failed\n", s);
    2f1c:	85ca                	mv	a1,s2
    2f1e:	00003517          	auipc	a0,0x3
    2f22:	7ba50513          	addi	a0,a0,1978 # 66d8 <malloc+0x142a>
    2f26:	2d4020ef          	jal	51fa <printf>
    exit(1);
    2f2a:	4505                	li	a0,1
    2f2c:	687010ef          	jal	4db2 <exit>
    printf("%s: open dd/dd/../ff failed\n", s);
    2f30:	85ca                	mv	a1,s2
    2f32:	00003517          	auipc	a0,0x3
    2f36:	7de50513          	addi	a0,a0,2014 # 6710 <malloc+0x1462>
    2f3a:	2c0020ef          	jal	51fa <printf>
    exit(1);
    2f3e:	4505                	li	a0,1
    2f40:	673010ef          	jal	4db2 <exit>
    printf("%s: dd/dd/../ff wrong content\n", s);
    2f44:	85ca                	mv	a1,s2
    2f46:	00003517          	auipc	a0,0x3
    2f4a:	7ea50513          	addi	a0,a0,2026 # 6730 <malloc+0x1482>
    2f4e:	2ac020ef          	jal	51fa <printf>
    exit(1);
    2f52:	4505                	li	a0,1
    2f54:	65f010ef          	jal	4db2 <exit>
    printf("%s: link dd/dd/ff dd/dd/ffff failed\n", s);
    2f58:	85ca                	mv	a1,s2
    2f5a:	00004517          	auipc	a0,0x4
    2f5e:	80650513          	addi	a0,a0,-2042 # 6760 <malloc+0x14b2>
    2f62:	298020ef          	jal	51fa <printf>
    exit(1);
    2f66:	4505                	li	a0,1
    2f68:	64b010ef          	jal	4db2 <exit>
    printf("%s: unlink dd/dd/ff failed\n", s);
    2f6c:	85ca                	mv	a1,s2
    2f6e:	00004517          	auipc	a0,0x4
    2f72:	81a50513          	addi	a0,a0,-2022 # 6788 <malloc+0x14da>
    2f76:	284020ef          	jal	51fa <printf>
    exit(1);
    2f7a:	4505                	li	a0,1
    2f7c:	637010ef          	jal	4db2 <exit>
    printf("%s: open (unlinked) dd/dd/ff succeeded\n", s);
    2f80:	85ca                	mv	a1,s2
    2f82:	00004517          	auipc	a0,0x4
    2f86:	82650513          	addi	a0,a0,-2010 # 67a8 <malloc+0x14fa>
    2f8a:	270020ef          	jal	51fa <printf>
    exit(1);
    2f8e:	4505                	li	a0,1
    2f90:	623010ef          	jal	4db2 <exit>
    printf("%s: chdir dd failed\n", s);
    2f94:	85ca                	mv	a1,s2
    2f96:	00004517          	auipc	a0,0x4
    2f9a:	83a50513          	addi	a0,a0,-1990 # 67d0 <malloc+0x1522>
    2f9e:	25c020ef          	jal	51fa <printf>
    exit(1);
    2fa2:	4505                	li	a0,1
    2fa4:	60f010ef          	jal	4db2 <exit>
    printf("%s: chdir dd/../../dd failed\n", s);
    2fa8:	85ca                	mv	a1,s2
    2faa:	00004517          	auipc	a0,0x4
    2fae:	84e50513          	addi	a0,a0,-1970 # 67f8 <malloc+0x154a>
    2fb2:	248020ef          	jal	51fa <printf>
    exit(1);
    2fb6:	4505                	li	a0,1
    2fb8:	5fb010ef          	jal	4db2 <exit>
    printf("%s: chdir dd/../../../dd failed\n", s);
    2fbc:	85ca                	mv	a1,s2
    2fbe:	00004517          	auipc	a0,0x4
    2fc2:	86a50513          	addi	a0,a0,-1942 # 6828 <malloc+0x157a>
    2fc6:	234020ef          	jal	51fa <printf>
    exit(1);
    2fca:	4505                	li	a0,1
    2fcc:	5e7010ef          	jal	4db2 <exit>
    printf("%s: chdir ./.. failed\n", s);
    2fd0:	85ca                	mv	a1,s2
    2fd2:	00004517          	auipc	a0,0x4
    2fd6:	88650513          	addi	a0,a0,-1914 # 6858 <malloc+0x15aa>
    2fda:	220020ef          	jal	51fa <printf>
    exit(1);
    2fde:	4505                	li	a0,1
    2fe0:	5d3010ef          	jal	4db2 <exit>
    printf("%s: open dd/dd/ffff failed\n", s);
    2fe4:	85ca                	mv	a1,s2
    2fe6:	00004517          	auipc	a0,0x4
    2fea:	88a50513          	addi	a0,a0,-1910 # 6870 <malloc+0x15c2>
    2fee:	20c020ef          	jal	51fa <printf>
    exit(1);
    2ff2:	4505                	li	a0,1
    2ff4:	5bf010ef          	jal	4db2 <exit>
    printf("%s: read dd/dd/ffff wrong len\n", s);
    2ff8:	85ca                	mv	a1,s2
    2ffa:	00004517          	auipc	a0,0x4
    2ffe:	89650513          	addi	a0,a0,-1898 # 6890 <malloc+0x15e2>
    3002:	1f8020ef          	jal	51fa <printf>
    exit(1);
    3006:	4505                	li	a0,1
    3008:	5ab010ef          	jal	4db2 <exit>
    printf("%s: open (unlinked) dd/dd/ff succeeded!\n", s);
    300c:	85ca                	mv	a1,s2
    300e:	00004517          	auipc	a0,0x4
    3012:	8a250513          	addi	a0,a0,-1886 # 68b0 <malloc+0x1602>
    3016:	1e4020ef          	jal	51fa <printf>
    exit(1);
    301a:	4505                	li	a0,1
    301c:	597010ef          	jal	4db2 <exit>
    printf("%s: create dd/ff/ff succeeded!\n", s);
    3020:	85ca                	mv	a1,s2
    3022:	00004517          	auipc	a0,0x4
    3026:	8ce50513          	addi	a0,a0,-1842 # 68f0 <malloc+0x1642>
    302a:	1d0020ef          	jal	51fa <printf>
    exit(1);
    302e:	4505                	li	a0,1
    3030:	583010ef          	jal	4db2 <exit>
    printf("%s: create dd/xx/ff succeeded!\n", s);
    3034:	85ca                	mv	a1,s2
    3036:	00004517          	auipc	a0,0x4
    303a:	8ea50513          	addi	a0,a0,-1814 # 6920 <malloc+0x1672>
    303e:	1bc020ef          	jal	51fa <printf>
    exit(1);
    3042:	4505                	li	a0,1
    3044:	56f010ef          	jal	4db2 <exit>
    printf("%s: create dd succeeded!\n", s);
    3048:	85ca                	mv	a1,s2
    304a:	00004517          	auipc	a0,0x4
    304e:	8f650513          	addi	a0,a0,-1802 # 6940 <malloc+0x1692>
    3052:	1a8020ef          	jal	51fa <printf>
    exit(1);
    3056:	4505                	li	a0,1
    3058:	55b010ef          	jal	4db2 <exit>
    printf("%s: open dd rdwr succeeded!\n", s);
    305c:	85ca                	mv	a1,s2
    305e:	00004517          	auipc	a0,0x4
    3062:	90250513          	addi	a0,a0,-1790 # 6960 <malloc+0x16b2>
    3066:	194020ef          	jal	51fa <printf>
    exit(1);
    306a:	4505                	li	a0,1
    306c:	547010ef          	jal	4db2 <exit>
    printf("%s: open dd wronly succeeded!\n", s);
    3070:	85ca                	mv	a1,s2
    3072:	00004517          	auipc	a0,0x4
    3076:	90e50513          	addi	a0,a0,-1778 # 6980 <malloc+0x16d2>
    307a:	180020ef          	jal	51fa <printf>
    exit(1);
    307e:	4505                	li	a0,1
    3080:	533010ef          	jal	4db2 <exit>
    printf("%s: link dd/ff/ff dd/dd/xx succeeded!\n", s);
    3084:	85ca                	mv	a1,s2
    3086:	00004517          	auipc	a0,0x4
    308a:	92a50513          	addi	a0,a0,-1750 # 69b0 <malloc+0x1702>
    308e:	16c020ef          	jal	51fa <printf>
    exit(1);
    3092:	4505                	li	a0,1
    3094:	51f010ef          	jal	4db2 <exit>
    printf("%s: link dd/xx/ff dd/dd/xx succeeded!\n", s);
    3098:	85ca                	mv	a1,s2
    309a:	00004517          	auipc	a0,0x4
    309e:	93e50513          	addi	a0,a0,-1730 # 69d8 <malloc+0x172a>
    30a2:	158020ef          	jal	51fa <printf>
    exit(1);
    30a6:	4505                	li	a0,1
    30a8:	50b010ef          	jal	4db2 <exit>
    printf("%s: link dd/ff dd/dd/ffff succeeded!\n", s);
    30ac:	85ca                	mv	a1,s2
    30ae:	00004517          	auipc	a0,0x4
    30b2:	95250513          	addi	a0,a0,-1710 # 6a00 <malloc+0x1752>
    30b6:	144020ef          	jal	51fa <printf>
    exit(1);
    30ba:	4505                	li	a0,1
    30bc:	4f7010ef          	jal	4db2 <exit>
    printf("%s: mkdir dd/ff/ff succeeded!\n", s);
    30c0:	85ca                	mv	a1,s2
    30c2:	00004517          	auipc	a0,0x4
    30c6:	96650513          	addi	a0,a0,-1690 # 6a28 <malloc+0x177a>
    30ca:	130020ef          	jal	51fa <printf>
    exit(1);
    30ce:	4505                	li	a0,1
    30d0:	4e3010ef          	jal	4db2 <exit>
    printf("%s: mkdir dd/xx/ff succeeded!\n", s);
    30d4:	85ca                	mv	a1,s2
    30d6:	00004517          	auipc	a0,0x4
    30da:	97250513          	addi	a0,a0,-1678 # 6a48 <malloc+0x179a>
    30de:	11c020ef          	jal	51fa <printf>
    exit(1);
    30e2:	4505                	li	a0,1
    30e4:	4cf010ef          	jal	4db2 <exit>
    printf("%s: mkdir dd/dd/ffff succeeded!\n", s);
    30e8:	85ca                	mv	a1,s2
    30ea:	00004517          	auipc	a0,0x4
    30ee:	97e50513          	addi	a0,a0,-1666 # 6a68 <malloc+0x17ba>
    30f2:	108020ef          	jal	51fa <printf>
    exit(1);
    30f6:	4505                	li	a0,1
    30f8:	4bb010ef          	jal	4db2 <exit>
    printf("%s: unlink dd/xx/ff succeeded!\n", s);
    30fc:	85ca                	mv	a1,s2
    30fe:	00004517          	auipc	a0,0x4
    3102:	99250513          	addi	a0,a0,-1646 # 6a90 <malloc+0x17e2>
    3106:	0f4020ef          	jal	51fa <printf>
    exit(1);
    310a:	4505                	li	a0,1
    310c:	4a7010ef          	jal	4db2 <exit>
    printf("%s: unlink dd/ff/ff succeeded!\n", s);
    3110:	85ca                	mv	a1,s2
    3112:	00004517          	auipc	a0,0x4
    3116:	99e50513          	addi	a0,a0,-1634 # 6ab0 <malloc+0x1802>
    311a:	0e0020ef          	jal	51fa <printf>
    exit(1);
    311e:	4505                	li	a0,1
    3120:	493010ef          	jal	4db2 <exit>
    printf("%s: chdir dd/ff succeeded!\n", s);
    3124:	85ca                	mv	a1,s2
    3126:	00004517          	auipc	a0,0x4
    312a:	9aa50513          	addi	a0,a0,-1622 # 6ad0 <malloc+0x1822>
    312e:	0cc020ef          	jal	51fa <printf>
    exit(1);
    3132:	4505                	li	a0,1
    3134:	47f010ef          	jal	4db2 <exit>
    printf("%s: chdir dd/xx succeeded!\n", s);
    3138:	85ca                	mv	a1,s2
    313a:	00004517          	auipc	a0,0x4
    313e:	9be50513          	addi	a0,a0,-1602 # 6af8 <malloc+0x184a>
    3142:	0b8020ef          	jal	51fa <printf>
    exit(1);
    3146:	4505                	li	a0,1
    3148:	46b010ef          	jal	4db2 <exit>
    printf("%s: unlink dd/dd/ff failed\n", s);
    314c:	85ca                	mv	a1,s2
    314e:	00003517          	auipc	a0,0x3
    3152:	63a50513          	addi	a0,a0,1594 # 6788 <malloc+0x14da>
    3156:	0a4020ef          	jal	51fa <printf>
    exit(1);
    315a:	4505                	li	a0,1
    315c:	457010ef          	jal	4db2 <exit>
    printf("%s: unlink dd/ff failed\n", s);
    3160:	85ca                	mv	a1,s2
    3162:	00004517          	auipc	a0,0x4
    3166:	9b650513          	addi	a0,a0,-1610 # 6b18 <malloc+0x186a>
    316a:	090020ef          	jal	51fa <printf>
    exit(1);
    316e:	4505                	li	a0,1
    3170:	443010ef          	jal	4db2 <exit>
    printf("%s: unlink non-empty dd succeeded!\n", s);
    3174:	85ca                	mv	a1,s2
    3176:	00004517          	auipc	a0,0x4
    317a:	9c250513          	addi	a0,a0,-1598 # 6b38 <malloc+0x188a>
    317e:	07c020ef          	jal	51fa <printf>
    exit(1);
    3182:	4505                	li	a0,1
    3184:	42f010ef          	jal	4db2 <exit>
    printf("%s: unlink dd/dd failed\n", s);
    3188:	85ca                	mv	a1,s2
    318a:	00004517          	auipc	a0,0x4
    318e:	9de50513          	addi	a0,a0,-1570 # 6b68 <malloc+0x18ba>
    3192:	068020ef          	jal	51fa <printf>
    exit(1);
    3196:	4505                	li	a0,1
    3198:	41b010ef          	jal	4db2 <exit>
    printf("%s: unlink dd failed\n", s);
    319c:	85ca                	mv	a1,s2
    319e:	00004517          	auipc	a0,0x4
    31a2:	9ea50513          	addi	a0,a0,-1558 # 6b88 <malloc+0x18da>
    31a6:	054020ef          	jal	51fa <printf>
    exit(1);
    31aa:	4505                	li	a0,1
    31ac:	407010ef          	jal	4db2 <exit>

00000000000031b0 <rmdot>:
{
    31b0:	1101                	addi	sp,sp,-32
    31b2:	ec06                	sd	ra,24(sp)
    31b4:	e822                	sd	s0,16(sp)
    31b6:	e426                	sd	s1,8(sp)
    31b8:	1000                	addi	s0,sp,32
    31ba:	84aa                	mv	s1,a0
  if(mkdir("dots") != 0){
    31bc:	00004517          	auipc	a0,0x4
    31c0:	9e450513          	addi	a0,a0,-1564 # 6ba0 <malloc+0x18f2>
    31c4:	457010ef          	jal	4e1a <mkdir>
    31c8:	e53d                	bnez	a0,3236 <rmdot+0x86>
  if(chdir("dots") != 0){
    31ca:	00004517          	auipc	a0,0x4
    31ce:	9d650513          	addi	a0,a0,-1578 # 6ba0 <malloc+0x18f2>
    31d2:	451010ef          	jal	4e22 <chdir>
    31d6:	e935                	bnez	a0,324a <rmdot+0x9a>
  if(unlink(".") == 0){
    31d8:	00003517          	auipc	a0,0x3
    31dc:	8f850513          	addi	a0,a0,-1800 # 5ad0 <malloc+0x822>
    31e0:	423010ef          	jal	4e02 <unlink>
    31e4:	cd2d                	beqz	a0,325e <rmdot+0xae>
  if(unlink("..") == 0){
    31e6:	00003517          	auipc	a0,0x3
    31ea:	40a50513          	addi	a0,a0,1034 # 65f0 <malloc+0x1342>
    31ee:	415010ef          	jal	4e02 <unlink>
    31f2:	c141                	beqz	a0,3272 <rmdot+0xc2>
  if(chdir("/") != 0){
    31f4:	00003517          	auipc	a0,0x3
    31f8:	3a450513          	addi	a0,a0,932 # 6598 <malloc+0x12ea>
    31fc:	427010ef          	jal	4e22 <chdir>
    3200:	e159                	bnez	a0,3286 <rmdot+0xd6>
  if(unlink("dots/.") == 0){
    3202:	00004517          	auipc	a0,0x4
    3206:	a0650513          	addi	a0,a0,-1530 # 6c08 <malloc+0x195a>
    320a:	3f9010ef          	jal	4e02 <unlink>
    320e:	c551                	beqz	a0,329a <rmdot+0xea>
  if(unlink("dots/..") == 0){
    3210:	00004517          	auipc	a0,0x4
    3214:	a2050513          	addi	a0,a0,-1504 # 6c30 <malloc+0x1982>
    3218:	3eb010ef          	jal	4e02 <unlink>
    321c:	c949                	beqz	a0,32ae <rmdot+0xfe>
  if(unlink("dots") != 0){
    321e:	00004517          	auipc	a0,0x4
    3222:	98250513          	addi	a0,a0,-1662 # 6ba0 <malloc+0x18f2>
    3226:	3dd010ef          	jal	4e02 <unlink>
    322a:	ed41                	bnez	a0,32c2 <rmdot+0x112>
}
    322c:	60e2                	ld	ra,24(sp)
    322e:	6442                	ld	s0,16(sp)
    3230:	64a2                	ld	s1,8(sp)
    3232:	6105                	addi	sp,sp,32
    3234:	8082                	ret
    printf("%s: mkdir dots failed\n", s);
    3236:	85a6                	mv	a1,s1
    3238:	00004517          	auipc	a0,0x4
    323c:	97050513          	addi	a0,a0,-1680 # 6ba8 <malloc+0x18fa>
    3240:	7bb010ef          	jal	51fa <printf>
    exit(1);
    3244:	4505                	li	a0,1
    3246:	36d010ef          	jal	4db2 <exit>
    printf("%s: chdir dots failed\n", s);
    324a:	85a6                	mv	a1,s1
    324c:	00004517          	auipc	a0,0x4
    3250:	97450513          	addi	a0,a0,-1676 # 6bc0 <malloc+0x1912>
    3254:	7a7010ef          	jal	51fa <printf>
    exit(1);
    3258:	4505                	li	a0,1
    325a:	359010ef          	jal	4db2 <exit>
    printf("%s: rm . worked!\n", s);
    325e:	85a6                	mv	a1,s1
    3260:	00004517          	auipc	a0,0x4
    3264:	97850513          	addi	a0,a0,-1672 # 6bd8 <malloc+0x192a>
    3268:	793010ef          	jal	51fa <printf>
    exit(1);
    326c:	4505                	li	a0,1
    326e:	345010ef          	jal	4db2 <exit>
    printf("%s: rm .. worked!\n", s);
    3272:	85a6                	mv	a1,s1
    3274:	00004517          	auipc	a0,0x4
    3278:	97c50513          	addi	a0,a0,-1668 # 6bf0 <malloc+0x1942>
    327c:	77f010ef          	jal	51fa <printf>
    exit(1);
    3280:	4505                	li	a0,1
    3282:	331010ef          	jal	4db2 <exit>
    printf("%s: chdir / failed\n", s);
    3286:	85a6                	mv	a1,s1
    3288:	00003517          	auipc	a0,0x3
    328c:	31850513          	addi	a0,a0,792 # 65a0 <malloc+0x12f2>
    3290:	76b010ef          	jal	51fa <printf>
    exit(1);
    3294:	4505                	li	a0,1
    3296:	31d010ef          	jal	4db2 <exit>
    printf("%s: unlink dots/. worked!\n", s);
    329a:	85a6                	mv	a1,s1
    329c:	00004517          	auipc	a0,0x4
    32a0:	97450513          	addi	a0,a0,-1676 # 6c10 <malloc+0x1962>
    32a4:	757010ef          	jal	51fa <printf>
    exit(1);
    32a8:	4505                	li	a0,1
    32aa:	309010ef          	jal	4db2 <exit>
    printf("%s: unlink dots/.. worked!\n", s);
    32ae:	85a6                	mv	a1,s1
    32b0:	00004517          	auipc	a0,0x4
    32b4:	98850513          	addi	a0,a0,-1656 # 6c38 <malloc+0x198a>
    32b8:	743010ef          	jal	51fa <printf>
    exit(1);
    32bc:	4505                	li	a0,1
    32be:	2f5010ef          	jal	4db2 <exit>
    printf("%s: unlink dots failed!\n", s);
    32c2:	85a6                	mv	a1,s1
    32c4:	00004517          	auipc	a0,0x4
    32c8:	99450513          	addi	a0,a0,-1644 # 6c58 <malloc+0x19aa>
    32cc:	72f010ef          	jal	51fa <printf>
    exit(1);
    32d0:	4505                	li	a0,1
    32d2:	2e1010ef          	jal	4db2 <exit>

00000000000032d6 <dirfile>:
{
    32d6:	1101                	addi	sp,sp,-32
    32d8:	ec06                	sd	ra,24(sp)
    32da:	e822                	sd	s0,16(sp)
    32dc:	e426                	sd	s1,8(sp)
    32de:	e04a                	sd	s2,0(sp)
    32e0:	1000                	addi	s0,sp,32
    32e2:	892a                	mv	s2,a0
  fd = open("dirfile", O_CREATE);
    32e4:	20000593          	li	a1,512
    32e8:	00004517          	auipc	a0,0x4
    32ec:	99050513          	addi	a0,a0,-1648 # 6c78 <malloc+0x19ca>
    32f0:	303010ef          	jal	4df2 <open>
  if(fd < 0){
    32f4:	0c054563          	bltz	a0,33be <dirfile+0xe8>
  close(fd);
    32f8:	2e3010ef          	jal	4dda <close>
  if(chdir("dirfile") == 0){
    32fc:	00004517          	auipc	a0,0x4
    3300:	97c50513          	addi	a0,a0,-1668 # 6c78 <malloc+0x19ca>
    3304:	31f010ef          	jal	4e22 <chdir>
    3308:	c569                	beqz	a0,33d2 <dirfile+0xfc>
  fd = open("dirfile/xx", 0);
    330a:	4581                	li	a1,0
    330c:	00004517          	auipc	a0,0x4
    3310:	9b450513          	addi	a0,a0,-1612 # 6cc0 <malloc+0x1a12>
    3314:	2df010ef          	jal	4df2 <open>
  if(fd >= 0){
    3318:	0c055763          	bgez	a0,33e6 <dirfile+0x110>
  fd = open("dirfile/xx", O_CREATE);
    331c:	20000593          	li	a1,512
    3320:	00004517          	auipc	a0,0x4
    3324:	9a050513          	addi	a0,a0,-1632 # 6cc0 <malloc+0x1a12>
    3328:	2cb010ef          	jal	4df2 <open>
  if(fd >= 0){
    332c:	0c055763          	bgez	a0,33fa <dirfile+0x124>
  if(mkdir("dirfile/xx") == 0){
    3330:	00004517          	auipc	a0,0x4
    3334:	99050513          	addi	a0,a0,-1648 # 6cc0 <malloc+0x1a12>
    3338:	2e3010ef          	jal	4e1a <mkdir>
    333c:	0c050963          	beqz	a0,340e <dirfile+0x138>
  if(unlink("dirfile/xx") == 0){
    3340:	00004517          	auipc	a0,0x4
    3344:	98050513          	addi	a0,a0,-1664 # 6cc0 <malloc+0x1a12>
    3348:	2bb010ef          	jal	4e02 <unlink>
    334c:	0c050b63          	beqz	a0,3422 <dirfile+0x14c>
  if(link("README", "dirfile/xx") == 0){
    3350:	00004597          	auipc	a1,0x4
    3354:	97058593          	addi	a1,a1,-1680 # 6cc0 <malloc+0x1a12>
    3358:	00002517          	auipc	a0,0x2
    335c:	26850513          	addi	a0,a0,616 # 55c0 <malloc+0x312>
    3360:	2b3010ef          	jal	4e12 <link>
    3364:	0c050963          	beqz	a0,3436 <dirfile+0x160>
  if(unlink("dirfile") != 0){
    3368:	00004517          	auipc	a0,0x4
    336c:	91050513          	addi	a0,a0,-1776 # 6c78 <malloc+0x19ca>
    3370:	293010ef          	jal	4e02 <unlink>
    3374:	0c051b63          	bnez	a0,344a <dirfile+0x174>
  fd = open(".", O_RDWR);
    3378:	4589                	li	a1,2
    337a:	00002517          	auipc	a0,0x2
    337e:	75650513          	addi	a0,a0,1878 # 5ad0 <malloc+0x822>
    3382:	271010ef          	jal	4df2 <open>
  if(fd >= 0){
    3386:	0c055c63          	bgez	a0,345e <dirfile+0x188>
  fd = open(".", 0);
    338a:	4581                	li	a1,0
    338c:	00002517          	auipc	a0,0x2
    3390:	74450513          	addi	a0,a0,1860 # 5ad0 <malloc+0x822>
    3394:	25f010ef          	jal	4df2 <open>
    3398:	84aa                	mv	s1,a0
  if(write(fd, "x", 1) > 0){
    339a:	4605                	li	a2,1
    339c:	00002597          	auipc	a1,0x2
    33a0:	0bc58593          	addi	a1,a1,188 # 5458 <malloc+0x1aa>
    33a4:	22f010ef          	jal	4dd2 <write>
    33a8:	0ca04563          	bgtz	a0,3472 <dirfile+0x19c>
  close(fd);
    33ac:	8526                	mv	a0,s1
    33ae:	22d010ef          	jal	4dda <close>
}
    33b2:	60e2                	ld	ra,24(sp)
    33b4:	6442                	ld	s0,16(sp)
    33b6:	64a2                	ld	s1,8(sp)
    33b8:	6902                	ld	s2,0(sp)
    33ba:	6105                	addi	sp,sp,32
    33bc:	8082                	ret
    printf("%s: create dirfile failed\n", s);
    33be:	85ca                	mv	a1,s2
    33c0:	00004517          	auipc	a0,0x4
    33c4:	8c050513          	addi	a0,a0,-1856 # 6c80 <malloc+0x19d2>
    33c8:	633010ef          	jal	51fa <printf>
    exit(1);
    33cc:	4505                	li	a0,1
    33ce:	1e5010ef          	jal	4db2 <exit>
    printf("%s: chdir dirfile succeeded!\n", s);
    33d2:	85ca                	mv	a1,s2
    33d4:	00004517          	auipc	a0,0x4
    33d8:	8cc50513          	addi	a0,a0,-1844 # 6ca0 <malloc+0x19f2>
    33dc:	61f010ef          	jal	51fa <printf>
    exit(1);
    33e0:	4505                	li	a0,1
    33e2:	1d1010ef          	jal	4db2 <exit>
    printf("%s: create dirfile/xx succeeded!\n", s);
    33e6:	85ca                	mv	a1,s2
    33e8:	00004517          	auipc	a0,0x4
    33ec:	8e850513          	addi	a0,a0,-1816 # 6cd0 <malloc+0x1a22>
    33f0:	60b010ef          	jal	51fa <printf>
    exit(1);
    33f4:	4505                	li	a0,1
    33f6:	1bd010ef          	jal	4db2 <exit>
    printf("%s: create dirfile/xx succeeded!\n", s);
    33fa:	85ca                	mv	a1,s2
    33fc:	00004517          	auipc	a0,0x4
    3400:	8d450513          	addi	a0,a0,-1836 # 6cd0 <malloc+0x1a22>
    3404:	5f7010ef          	jal	51fa <printf>
    exit(1);
    3408:	4505                	li	a0,1
    340a:	1a9010ef          	jal	4db2 <exit>
    printf("%s: mkdir dirfile/xx succeeded!\n", s);
    340e:	85ca                	mv	a1,s2
    3410:	00004517          	auipc	a0,0x4
    3414:	8e850513          	addi	a0,a0,-1816 # 6cf8 <malloc+0x1a4a>
    3418:	5e3010ef          	jal	51fa <printf>
    exit(1);
    341c:	4505                	li	a0,1
    341e:	195010ef          	jal	4db2 <exit>
    printf("%s: unlink dirfile/xx succeeded!\n", s);
    3422:	85ca                	mv	a1,s2
    3424:	00004517          	auipc	a0,0x4
    3428:	8fc50513          	addi	a0,a0,-1796 # 6d20 <malloc+0x1a72>
    342c:	5cf010ef          	jal	51fa <printf>
    exit(1);
    3430:	4505                	li	a0,1
    3432:	181010ef          	jal	4db2 <exit>
    printf("%s: link to dirfile/xx succeeded!\n", s);
    3436:	85ca                	mv	a1,s2
    3438:	00004517          	auipc	a0,0x4
    343c:	91050513          	addi	a0,a0,-1776 # 6d48 <malloc+0x1a9a>
    3440:	5bb010ef          	jal	51fa <printf>
    exit(1);
    3444:	4505                	li	a0,1
    3446:	16d010ef          	jal	4db2 <exit>
    printf("%s: unlink dirfile failed!\n", s);
    344a:	85ca                	mv	a1,s2
    344c:	00004517          	auipc	a0,0x4
    3450:	92450513          	addi	a0,a0,-1756 # 6d70 <malloc+0x1ac2>
    3454:	5a7010ef          	jal	51fa <printf>
    exit(1);
    3458:	4505                	li	a0,1
    345a:	159010ef          	jal	4db2 <exit>
    printf("%s: open . for writing succeeded!\n", s);
    345e:	85ca                	mv	a1,s2
    3460:	00004517          	auipc	a0,0x4
    3464:	93050513          	addi	a0,a0,-1744 # 6d90 <malloc+0x1ae2>
    3468:	593010ef          	jal	51fa <printf>
    exit(1);
    346c:	4505                	li	a0,1
    346e:	145010ef          	jal	4db2 <exit>
    printf("%s: write . succeeded!\n", s);
    3472:	85ca                	mv	a1,s2
    3474:	00004517          	auipc	a0,0x4
    3478:	94450513          	addi	a0,a0,-1724 # 6db8 <malloc+0x1b0a>
    347c:	57f010ef          	jal	51fa <printf>
    exit(1);
    3480:	4505                	li	a0,1
    3482:	131010ef          	jal	4db2 <exit>

0000000000003486 <iref>:
{
    3486:	7139                	addi	sp,sp,-64
    3488:	fc06                	sd	ra,56(sp)
    348a:	f822                	sd	s0,48(sp)
    348c:	f426                	sd	s1,40(sp)
    348e:	f04a                	sd	s2,32(sp)
    3490:	ec4e                	sd	s3,24(sp)
    3492:	e852                	sd	s4,16(sp)
    3494:	e456                	sd	s5,8(sp)
    3496:	e05a                	sd	s6,0(sp)
    3498:	0080                	addi	s0,sp,64
    349a:	8b2a                	mv	s6,a0
    349c:	03300913          	li	s2,51
    if(mkdir("irefd") != 0){
    34a0:	00004a17          	auipc	s4,0x4
    34a4:	930a0a13          	addi	s4,s4,-1744 # 6dd0 <malloc+0x1b22>
    mkdir("");
    34a8:	00003497          	auipc	s1,0x3
    34ac:	43048493          	addi	s1,s1,1072 # 68d8 <malloc+0x162a>
    link("README", "");
    34b0:	00002a97          	auipc	s5,0x2
    34b4:	110a8a93          	addi	s5,s5,272 # 55c0 <malloc+0x312>
    fd = open("xx", O_CREATE);
    34b8:	00004997          	auipc	s3,0x4
    34bc:	81098993          	addi	s3,s3,-2032 # 6cc8 <malloc+0x1a1a>
    34c0:	a835                	j	34fc <iref+0x76>
      printf("%s: mkdir irefd failed\n", s);
    34c2:	85da                	mv	a1,s6
    34c4:	00004517          	auipc	a0,0x4
    34c8:	91450513          	addi	a0,a0,-1772 # 6dd8 <malloc+0x1b2a>
    34cc:	52f010ef          	jal	51fa <printf>
      exit(1);
    34d0:	4505                	li	a0,1
    34d2:	0e1010ef          	jal	4db2 <exit>
      printf("%s: chdir irefd failed\n", s);
    34d6:	85da                	mv	a1,s6
    34d8:	00004517          	auipc	a0,0x4
    34dc:	91850513          	addi	a0,a0,-1768 # 6df0 <malloc+0x1b42>
    34e0:	51b010ef          	jal	51fa <printf>
      exit(1);
    34e4:	4505                	li	a0,1
    34e6:	0cd010ef          	jal	4db2 <exit>
      close(fd);
    34ea:	0f1010ef          	jal	4dda <close>
    34ee:	a82d                	j	3528 <iref+0xa2>
    unlink("xx");
    34f0:	854e                	mv	a0,s3
    34f2:	111010ef          	jal	4e02 <unlink>
  for(i = 0; i < NINODE + 1; i++){
    34f6:	397d                	addiw	s2,s2,-1
    34f8:	04090263          	beqz	s2,353c <iref+0xb6>
    if(mkdir("irefd") != 0){
    34fc:	8552                	mv	a0,s4
    34fe:	11d010ef          	jal	4e1a <mkdir>
    3502:	f161                	bnez	a0,34c2 <iref+0x3c>
    if(chdir("irefd") != 0){
    3504:	8552                	mv	a0,s4
    3506:	11d010ef          	jal	4e22 <chdir>
    350a:	f571                	bnez	a0,34d6 <iref+0x50>
    mkdir("");
    350c:	8526                	mv	a0,s1
    350e:	10d010ef          	jal	4e1a <mkdir>
    link("README", "");
    3512:	85a6                	mv	a1,s1
    3514:	8556                	mv	a0,s5
    3516:	0fd010ef          	jal	4e12 <link>
    fd = open("", O_CREATE);
    351a:	20000593          	li	a1,512
    351e:	8526                	mv	a0,s1
    3520:	0d3010ef          	jal	4df2 <open>
    if(fd >= 0)
    3524:	fc0553e3          	bgez	a0,34ea <iref+0x64>
    fd = open("xx", O_CREATE);
    3528:	20000593          	li	a1,512
    352c:	854e                	mv	a0,s3
    352e:	0c5010ef          	jal	4df2 <open>
    if(fd >= 0)
    3532:	fa054fe3          	bltz	a0,34f0 <iref+0x6a>
      close(fd);
    3536:	0a5010ef          	jal	4dda <close>
    353a:	bf5d                	j	34f0 <iref+0x6a>
    353c:	03300493          	li	s1,51
    chdir("..");
    3540:	00003997          	auipc	s3,0x3
    3544:	0b098993          	addi	s3,s3,176 # 65f0 <malloc+0x1342>
    unlink("irefd");
    3548:	00004917          	auipc	s2,0x4
    354c:	88890913          	addi	s2,s2,-1912 # 6dd0 <malloc+0x1b22>
    chdir("..");
    3550:	854e                	mv	a0,s3
    3552:	0d1010ef          	jal	4e22 <chdir>
    unlink("irefd");
    3556:	854a                	mv	a0,s2
    3558:	0ab010ef          	jal	4e02 <unlink>
  for(i = 0; i < NINODE + 1; i++){
    355c:	34fd                	addiw	s1,s1,-1
    355e:	f8ed                	bnez	s1,3550 <iref+0xca>
  chdir("/");
    3560:	00003517          	auipc	a0,0x3
    3564:	03850513          	addi	a0,a0,56 # 6598 <malloc+0x12ea>
    3568:	0bb010ef          	jal	4e22 <chdir>
}
    356c:	70e2                	ld	ra,56(sp)
    356e:	7442                	ld	s0,48(sp)
    3570:	74a2                	ld	s1,40(sp)
    3572:	7902                	ld	s2,32(sp)
    3574:	69e2                	ld	s3,24(sp)
    3576:	6a42                	ld	s4,16(sp)
    3578:	6aa2                	ld	s5,8(sp)
    357a:	6b02                	ld	s6,0(sp)
    357c:	6121                	addi	sp,sp,64
    357e:	8082                	ret

0000000000003580 <openiputtest>:
{
    3580:	7179                	addi	sp,sp,-48
    3582:	f406                	sd	ra,40(sp)
    3584:	f022                	sd	s0,32(sp)
    3586:	ec26                	sd	s1,24(sp)
    3588:	1800                	addi	s0,sp,48
    358a:	84aa                	mv	s1,a0
  if(mkdir("oidir") < 0){
    358c:	00004517          	auipc	a0,0x4
    3590:	87c50513          	addi	a0,a0,-1924 # 6e08 <malloc+0x1b5a>
    3594:	087010ef          	jal	4e1a <mkdir>
    3598:	02054a63          	bltz	a0,35cc <openiputtest+0x4c>
  pid = fork();
    359c:	00f010ef          	jal	4daa <fork>
  if(pid < 0){
    35a0:	04054063          	bltz	a0,35e0 <openiputtest+0x60>
  if(pid == 0){
    35a4:	e939                	bnez	a0,35fa <openiputtest+0x7a>
    int fd = open("oidir", O_RDWR);
    35a6:	4589                	li	a1,2
    35a8:	00004517          	auipc	a0,0x4
    35ac:	86050513          	addi	a0,a0,-1952 # 6e08 <malloc+0x1b5a>
    35b0:	043010ef          	jal	4df2 <open>
    if(fd >= 0){
    35b4:	04054063          	bltz	a0,35f4 <openiputtest+0x74>
      printf("%s: open directory for write succeeded\n", s);
    35b8:	85a6                	mv	a1,s1
    35ba:	00004517          	auipc	a0,0x4
    35be:	86e50513          	addi	a0,a0,-1938 # 6e28 <malloc+0x1b7a>
    35c2:	439010ef          	jal	51fa <printf>
      exit(1);
    35c6:	4505                	li	a0,1
    35c8:	7ea010ef          	jal	4db2 <exit>
    printf("%s: mkdir oidir failed\n", s);
    35cc:	85a6                	mv	a1,s1
    35ce:	00004517          	auipc	a0,0x4
    35d2:	84250513          	addi	a0,a0,-1982 # 6e10 <malloc+0x1b62>
    35d6:	425010ef          	jal	51fa <printf>
    exit(1);
    35da:	4505                	li	a0,1
    35dc:	7d6010ef          	jal	4db2 <exit>
    printf("%s: fork failed\n", s);
    35e0:	85a6                	mv	a1,s1
    35e2:	00002517          	auipc	a0,0x2
    35e6:	69650513          	addi	a0,a0,1686 # 5c78 <malloc+0x9ca>
    35ea:	411010ef          	jal	51fa <printf>
    exit(1);
    35ee:	4505                	li	a0,1
    35f0:	7c2010ef          	jal	4db2 <exit>
    exit(0);
    35f4:	4501                	li	a0,0
    35f6:	7bc010ef          	jal	4db2 <exit>
  pause(1);
    35fa:	4505                	li	a0,1
    35fc:	047010ef          	jal	4e42 <pause>
  if(unlink("oidir") != 0){
    3600:	00004517          	auipc	a0,0x4
    3604:	80850513          	addi	a0,a0,-2040 # 6e08 <malloc+0x1b5a>
    3608:	7fa010ef          	jal	4e02 <unlink>
    360c:	c919                	beqz	a0,3622 <openiputtest+0xa2>
    printf("%s: unlink failed\n", s);
    360e:	85a6                	mv	a1,s1
    3610:	00003517          	auipc	a0,0x3
    3614:	85850513          	addi	a0,a0,-1960 # 5e68 <malloc+0xbba>
    3618:	3e3010ef          	jal	51fa <printf>
    exit(1);
    361c:	4505                	li	a0,1
    361e:	794010ef          	jal	4db2 <exit>
  wait(&xstatus);
    3622:	fdc40513          	addi	a0,s0,-36
    3626:	794010ef          	jal	4dba <wait>
  exit(xstatus);
    362a:	fdc42503          	lw	a0,-36(s0)
    362e:	784010ef          	jal	4db2 <exit>

0000000000003632 <forkforkfork>:
{
    3632:	1101                	addi	sp,sp,-32
    3634:	ec06                	sd	ra,24(sp)
    3636:	e822                	sd	s0,16(sp)
    3638:	e426                	sd	s1,8(sp)
    363a:	1000                	addi	s0,sp,32
    363c:	84aa                	mv	s1,a0
  unlink("stopforking");
    363e:	00004517          	auipc	a0,0x4
    3642:	81250513          	addi	a0,a0,-2030 # 6e50 <malloc+0x1ba2>
    3646:	7bc010ef          	jal	4e02 <unlink>
  int pid = fork();
    364a:	760010ef          	jal	4daa <fork>
  if(pid < 0){
    364e:	02054b63          	bltz	a0,3684 <forkforkfork+0x52>
  if(pid == 0){
    3652:	c139                	beqz	a0,3698 <forkforkfork+0x66>
  pause(20); // two seconds
    3654:	4551                	li	a0,20
    3656:	7ec010ef          	jal	4e42 <pause>
  close(open("stopforking", O_CREATE|O_RDWR));
    365a:	20200593          	li	a1,514
    365e:	00003517          	auipc	a0,0x3
    3662:	7f250513          	addi	a0,a0,2034 # 6e50 <malloc+0x1ba2>
    3666:	78c010ef          	jal	4df2 <open>
    366a:	770010ef          	jal	4dda <close>
  wait(0);
    366e:	4501                	li	a0,0
    3670:	74a010ef          	jal	4dba <wait>
  pause(10); // one second
    3674:	4529                	li	a0,10
    3676:	7cc010ef          	jal	4e42 <pause>
}
    367a:	60e2                	ld	ra,24(sp)
    367c:	6442                	ld	s0,16(sp)
    367e:	64a2                	ld	s1,8(sp)
    3680:	6105                	addi	sp,sp,32
    3682:	8082                	ret
    printf("%s: fork failed", s);
    3684:	85a6                	mv	a1,s1
    3686:	00002517          	auipc	a0,0x2
    368a:	7b250513          	addi	a0,a0,1970 # 5e38 <malloc+0xb8a>
    368e:	36d010ef          	jal	51fa <printf>
    exit(1);
    3692:	4505                	li	a0,1
    3694:	71e010ef          	jal	4db2 <exit>
      int fd = open("stopforking", 0);
    3698:	00003497          	auipc	s1,0x3
    369c:	7b848493          	addi	s1,s1,1976 # 6e50 <malloc+0x1ba2>
    36a0:	4581                	li	a1,0
    36a2:	8526                	mv	a0,s1
    36a4:	74e010ef          	jal	4df2 <open>
      if(fd >= 0){
    36a8:	02055163          	bgez	a0,36ca <forkforkfork+0x98>
      if(fork() < 0){
    36ac:	6fe010ef          	jal	4daa <fork>
    36b0:	fe0558e3          	bgez	a0,36a0 <forkforkfork+0x6e>
        close(open("stopforking", O_CREATE|O_RDWR));
    36b4:	20200593          	li	a1,514
    36b8:	00003517          	auipc	a0,0x3
    36bc:	79850513          	addi	a0,a0,1944 # 6e50 <malloc+0x1ba2>
    36c0:	732010ef          	jal	4df2 <open>
    36c4:	716010ef          	jal	4dda <close>
    36c8:	bfe1                	j	36a0 <forkforkfork+0x6e>
        exit(0);
    36ca:	4501                	li	a0,0
    36cc:	6e6010ef          	jal	4db2 <exit>

00000000000036d0 <killstatus>:
{
    36d0:	7139                	addi	sp,sp,-64
    36d2:	fc06                	sd	ra,56(sp)
    36d4:	f822                	sd	s0,48(sp)
    36d6:	f426                	sd	s1,40(sp)
    36d8:	f04a                	sd	s2,32(sp)
    36da:	ec4e                	sd	s3,24(sp)
    36dc:	e852                	sd	s4,16(sp)
    36de:	0080                	addi	s0,sp,64
    36e0:	8a2a                	mv	s4,a0
    36e2:	06400913          	li	s2,100
    if(xst != -1) {
    36e6:	59fd                	li	s3,-1
    int pid1 = fork();
    36e8:	6c2010ef          	jal	4daa <fork>
    36ec:	84aa                	mv	s1,a0
    if(pid1 < 0){
    36ee:	02054763          	bltz	a0,371c <killstatus+0x4c>
    if(pid1 == 0){
    36f2:	cd1d                	beqz	a0,3730 <killstatus+0x60>
    pause(1);
    36f4:	4505                	li	a0,1
    36f6:	74c010ef          	jal	4e42 <pause>
    kill(pid1);
    36fa:	8526                	mv	a0,s1
    36fc:	6e6010ef          	jal	4de2 <kill>
    wait(&xst);
    3700:	fcc40513          	addi	a0,s0,-52
    3704:	6b6010ef          	jal	4dba <wait>
    if(xst != -1) {
    3708:	fcc42783          	lw	a5,-52(s0)
    370c:	03379563          	bne	a5,s3,3736 <killstatus+0x66>
  for(int i = 0; i < 100; i++){
    3710:	397d                	addiw	s2,s2,-1
    3712:	fc091be3          	bnez	s2,36e8 <killstatus+0x18>
  exit(0);
    3716:	4501                	li	a0,0
    3718:	69a010ef          	jal	4db2 <exit>
      printf("%s: fork failed\n", s);
    371c:	85d2                	mv	a1,s4
    371e:	00002517          	auipc	a0,0x2
    3722:	55a50513          	addi	a0,a0,1370 # 5c78 <malloc+0x9ca>
    3726:	2d5010ef          	jal	51fa <printf>
      exit(1);
    372a:	4505                	li	a0,1
    372c:	686010ef          	jal	4db2 <exit>
        getpid();
    3730:	702010ef          	jal	4e32 <getpid>
      while(1) {
    3734:	bff5                	j	3730 <killstatus+0x60>
       printf("%s: status should be -1\n", s);
    3736:	85d2                	mv	a1,s4
    3738:	00003517          	auipc	a0,0x3
    373c:	72850513          	addi	a0,a0,1832 # 6e60 <malloc+0x1bb2>
    3740:	2bb010ef          	jal	51fa <printf>
       exit(1);
    3744:	4505                	li	a0,1
    3746:	66c010ef          	jal	4db2 <exit>

000000000000374a <preempt>:
{
    374a:	7139                	addi	sp,sp,-64
    374c:	fc06                	sd	ra,56(sp)
    374e:	f822                	sd	s0,48(sp)
    3750:	f426                	sd	s1,40(sp)
    3752:	f04a                	sd	s2,32(sp)
    3754:	ec4e                	sd	s3,24(sp)
    3756:	e852                	sd	s4,16(sp)
    3758:	0080                	addi	s0,sp,64
    375a:	892a                	mv	s2,a0
  pid1 = fork();
    375c:	64e010ef          	jal	4daa <fork>
  if(pid1 < 0) {
    3760:	00054563          	bltz	a0,376a <preempt+0x20>
    3764:	84aa                	mv	s1,a0
  if(pid1 == 0)
    3766:	ed01                	bnez	a0,377e <preempt+0x34>
    for(;;)
    3768:	a001                	j	3768 <preempt+0x1e>
    printf("%s: fork failed", s);
    376a:	85ca                	mv	a1,s2
    376c:	00002517          	auipc	a0,0x2
    3770:	6cc50513          	addi	a0,a0,1740 # 5e38 <malloc+0xb8a>
    3774:	287010ef          	jal	51fa <printf>
    exit(1);
    3778:	4505                	li	a0,1
    377a:	638010ef          	jal	4db2 <exit>
  pid2 = fork();
    377e:	62c010ef          	jal	4daa <fork>
    3782:	89aa                	mv	s3,a0
  if(pid2 < 0) {
    3784:	00054463          	bltz	a0,378c <preempt+0x42>
  if(pid2 == 0)
    3788:	ed01                	bnez	a0,37a0 <preempt+0x56>
    for(;;)
    378a:	a001                	j	378a <preempt+0x40>
    printf("%s: fork failed\n", s);
    378c:	85ca                	mv	a1,s2
    378e:	00002517          	auipc	a0,0x2
    3792:	4ea50513          	addi	a0,a0,1258 # 5c78 <malloc+0x9ca>
    3796:	265010ef          	jal	51fa <printf>
    exit(1);
    379a:	4505                	li	a0,1
    379c:	616010ef          	jal	4db2 <exit>
  pipe(pfds);
    37a0:	fc840513          	addi	a0,s0,-56
    37a4:	61e010ef          	jal	4dc2 <pipe>
  pid3 = fork();
    37a8:	602010ef          	jal	4daa <fork>
    37ac:	8a2a                	mv	s4,a0
  if(pid3 < 0) {
    37ae:	02054863          	bltz	a0,37de <preempt+0x94>
  if(pid3 == 0){
    37b2:	e921                	bnez	a0,3802 <preempt+0xb8>
    close(pfds[0]);
    37b4:	fc842503          	lw	a0,-56(s0)
    37b8:	622010ef          	jal	4dda <close>
    if(write(pfds[1], "x", 1) != 1)
    37bc:	4605                	li	a2,1
    37be:	00002597          	auipc	a1,0x2
    37c2:	c9a58593          	addi	a1,a1,-870 # 5458 <malloc+0x1aa>
    37c6:	fcc42503          	lw	a0,-52(s0)
    37ca:	608010ef          	jal	4dd2 <write>
    37ce:	4785                	li	a5,1
    37d0:	02f51163          	bne	a0,a5,37f2 <preempt+0xa8>
    close(pfds[1]);
    37d4:	fcc42503          	lw	a0,-52(s0)
    37d8:	602010ef          	jal	4dda <close>
    for(;;)
    37dc:	a001                	j	37dc <preempt+0x92>
     printf("%s: fork failed\n", s);
    37de:	85ca                	mv	a1,s2
    37e0:	00002517          	auipc	a0,0x2
    37e4:	49850513          	addi	a0,a0,1176 # 5c78 <malloc+0x9ca>
    37e8:	213010ef          	jal	51fa <printf>
     exit(1);
    37ec:	4505                	li	a0,1
    37ee:	5c4010ef          	jal	4db2 <exit>
      printf("%s: preempt write error", s);
    37f2:	85ca                	mv	a1,s2
    37f4:	00003517          	auipc	a0,0x3
    37f8:	68c50513          	addi	a0,a0,1676 # 6e80 <malloc+0x1bd2>
    37fc:	1ff010ef          	jal	51fa <printf>
    3800:	bfd1                	j	37d4 <preempt+0x8a>
  close(pfds[1]);
    3802:	fcc42503          	lw	a0,-52(s0)
    3806:	5d4010ef          	jal	4dda <close>
  if(read(pfds[0], buf, sizeof(buf)) != 1){
    380a:	660d                	lui	a2,0x3
    380c:	00008597          	auipc	a1,0x8
    3810:	4ac58593          	addi	a1,a1,1196 # bcb8 <buf>
    3814:	fc842503          	lw	a0,-56(s0)
    3818:	5b2010ef          	jal	4dca <read>
    381c:	4785                	li	a5,1
    381e:	02f50163          	beq	a0,a5,3840 <preempt+0xf6>
    printf("%s: preempt read error", s);
    3822:	85ca                	mv	a1,s2
    3824:	00003517          	auipc	a0,0x3
    3828:	67450513          	addi	a0,a0,1652 # 6e98 <malloc+0x1bea>
    382c:	1cf010ef          	jal	51fa <printf>
}
    3830:	70e2                	ld	ra,56(sp)
    3832:	7442                	ld	s0,48(sp)
    3834:	74a2                	ld	s1,40(sp)
    3836:	7902                	ld	s2,32(sp)
    3838:	69e2                	ld	s3,24(sp)
    383a:	6a42                	ld	s4,16(sp)
    383c:	6121                	addi	sp,sp,64
    383e:	8082                	ret
  close(pfds[0]);
    3840:	fc842503          	lw	a0,-56(s0)
    3844:	596010ef          	jal	4dda <close>
  printf("kill... ");
    3848:	00003517          	auipc	a0,0x3
    384c:	66850513          	addi	a0,a0,1640 # 6eb0 <malloc+0x1c02>
    3850:	1ab010ef          	jal	51fa <printf>
  kill(pid1);
    3854:	8526                	mv	a0,s1
    3856:	58c010ef          	jal	4de2 <kill>
  kill(pid2);
    385a:	854e                	mv	a0,s3
    385c:	586010ef          	jal	4de2 <kill>
  kill(pid3);
    3860:	8552                	mv	a0,s4
    3862:	580010ef          	jal	4de2 <kill>
  printf("wait... ");
    3866:	00003517          	auipc	a0,0x3
    386a:	65a50513          	addi	a0,a0,1626 # 6ec0 <malloc+0x1c12>
    386e:	18d010ef          	jal	51fa <printf>
  wait(0);
    3872:	4501                	li	a0,0
    3874:	546010ef          	jal	4dba <wait>
  wait(0);
    3878:	4501                	li	a0,0
    387a:	540010ef          	jal	4dba <wait>
  wait(0);
    387e:	4501                	li	a0,0
    3880:	53a010ef          	jal	4dba <wait>
    3884:	b775                	j	3830 <preempt+0xe6>

0000000000003886 <reparent>:
{
    3886:	7179                	addi	sp,sp,-48
    3888:	f406                	sd	ra,40(sp)
    388a:	f022                	sd	s0,32(sp)
    388c:	ec26                	sd	s1,24(sp)
    388e:	e84a                	sd	s2,16(sp)
    3890:	e44e                	sd	s3,8(sp)
    3892:	e052                	sd	s4,0(sp)
    3894:	1800                	addi	s0,sp,48
    3896:	89aa                	mv	s3,a0
  int master_pid = getpid();
    3898:	59a010ef          	jal	4e32 <getpid>
    389c:	8a2a                	mv	s4,a0
    389e:	0c800913          	li	s2,200
    int pid = fork();
    38a2:	508010ef          	jal	4daa <fork>
    38a6:	84aa                	mv	s1,a0
    if(pid < 0){
    38a8:	00054e63          	bltz	a0,38c4 <reparent+0x3e>
    if(pid){
    38ac:	c121                	beqz	a0,38ec <reparent+0x66>
      if(wait(0) != pid){
    38ae:	4501                	li	a0,0
    38b0:	50a010ef          	jal	4dba <wait>
    38b4:	02951263          	bne	a0,s1,38d8 <reparent+0x52>
  for(int i = 0; i < 200; i++){
    38b8:	397d                	addiw	s2,s2,-1
    38ba:	fe0914e3          	bnez	s2,38a2 <reparent+0x1c>
  exit(0);
    38be:	4501                	li	a0,0
    38c0:	4f2010ef          	jal	4db2 <exit>
      printf("%s: fork failed\n", s);
    38c4:	85ce                	mv	a1,s3
    38c6:	00002517          	auipc	a0,0x2
    38ca:	3b250513          	addi	a0,a0,946 # 5c78 <malloc+0x9ca>
    38ce:	12d010ef          	jal	51fa <printf>
      exit(1);
    38d2:	4505                	li	a0,1
    38d4:	4de010ef          	jal	4db2 <exit>
        printf("%s: wait wrong pid\n", s);
    38d8:	85ce                	mv	a1,s3
    38da:	00002517          	auipc	a0,0x2
    38de:	52650513          	addi	a0,a0,1318 # 5e00 <malloc+0xb52>
    38e2:	119010ef          	jal	51fa <printf>
        exit(1);
    38e6:	4505                	li	a0,1
    38e8:	4ca010ef          	jal	4db2 <exit>
      int pid2 = fork();
    38ec:	4be010ef          	jal	4daa <fork>
      if(pid2 < 0){
    38f0:	00054563          	bltz	a0,38fa <reparent+0x74>
      exit(0);
    38f4:	4501                	li	a0,0
    38f6:	4bc010ef          	jal	4db2 <exit>
        kill(master_pid);
    38fa:	8552                	mv	a0,s4
    38fc:	4e6010ef          	jal	4de2 <kill>
        exit(1);
    3900:	4505                	li	a0,1
    3902:	4b0010ef          	jal	4db2 <exit>

0000000000003906 <sbrkfail>:
{
    3906:	7175                	addi	sp,sp,-144
    3908:	e506                	sd	ra,136(sp)
    390a:	e122                	sd	s0,128(sp)
    390c:	fca6                	sd	s1,120(sp)
    390e:	f8ca                	sd	s2,112(sp)
    3910:	f4ce                	sd	s3,104(sp)
    3912:	f0d2                	sd	s4,96(sp)
    3914:	ecd6                	sd	s5,88(sp)
    3916:	e8da                	sd	s6,80(sp)
    3918:	e4de                	sd	s7,72(sp)
    391a:	0900                	addi	s0,sp,144
    391c:	8b2a                	mv	s6,a0
  if(pipe(fds) != 0){
    391e:	fa040513          	addi	a0,s0,-96
    3922:	4a0010ef          	jal	4dc2 <pipe>
    3926:	e919                	bnez	a0,393c <sbrkfail+0x36>
    3928:	8aaa                	mv	s5,a0
    392a:	f7040493          	addi	s1,s0,-144
    392e:	f9840993          	addi	s3,s0,-104
    3932:	8926                	mv	s2,s1
    if(pids[i] != -1) {
    3934:	5a7d                	li	s4,-1
      if(scratch == '0')
    3936:	03000b93          	li	s7,48
    393a:	a08d                	j	399c <sbrkfail+0x96>
    printf("%s: pipe() failed\n", s);
    393c:	85da                	mv	a1,s6
    393e:	00002517          	auipc	a0,0x2
    3942:	44250513          	addi	a0,a0,1090 # 5d80 <malloc+0xad2>
    3946:	0b5010ef          	jal	51fa <printf>
    exit(1);
    394a:	4505                	li	a0,1
    394c:	466010ef          	jal	4db2 <exit>
      if (sbrk(BIG - (uint64)sbrk(0)) ==  (char*)SBRK_ERROR)
    3950:	3f0010ef          	jal	4d40 <sbrk>
    3954:	064007b7          	lui	a5,0x6400
    3958:	40a7853b          	subw	a0,a5,a0
    395c:	3e4010ef          	jal	4d40 <sbrk>
    3960:	57fd                	li	a5,-1
    3962:	02f50063          	beq	a0,a5,3982 <sbrkfail+0x7c>
        write(fds[1], "1", 1);
    3966:	4605                	li	a2,1
    3968:	00004597          	auipc	a1,0x4
    396c:	ce058593          	addi	a1,a1,-800 # 7648 <malloc+0x239a>
    3970:	fa442503          	lw	a0,-92(s0)
    3974:	45e010ef          	jal	4dd2 <write>
      for(;;) pause(1000);
    3978:	3e800513          	li	a0,1000
    397c:	4c6010ef          	jal	4e42 <pause>
    3980:	bfe5                	j	3978 <sbrkfail+0x72>
        write(fds[1], "0", 1);
    3982:	4605                	li	a2,1
    3984:	00003597          	auipc	a1,0x3
    3988:	54c58593          	addi	a1,a1,1356 # 6ed0 <malloc+0x1c22>
    398c:	fa442503          	lw	a0,-92(s0)
    3990:	442010ef          	jal	4dd2 <write>
    3994:	b7d5                	j	3978 <sbrkfail+0x72>
  for(i = 0; i < sizeof(pids)/sizeof(pids[0]); i++){
    3996:	0911                	addi	s2,s2,4
    3998:	03390663          	beq	s2,s3,39c4 <sbrkfail+0xbe>
    if((pids[i] = fork()) == 0){
    399c:	40e010ef          	jal	4daa <fork>
    39a0:	00a92023          	sw	a0,0(s2)
    39a4:	d555                	beqz	a0,3950 <sbrkfail+0x4a>
    if(pids[i] != -1) {
    39a6:	ff4508e3          	beq	a0,s4,3996 <sbrkfail+0x90>
      read(fds[0], &scratch, 1);
    39aa:	4605                	li	a2,1
    39ac:	f9f40593          	addi	a1,s0,-97
    39b0:	fa042503          	lw	a0,-96(s0)
    39b4:	416010ef          	jal	4dca <read>
      if(scratch == '0')
    39b8:	f9f44783          	lbu	a5,-97(s0)
    39bc:	fd779de3          	bne	a5,s7,3996 <sbrkfail+0x90>
        failed = 1;
    39c0:	4a85                	li	s5,1
    39c2:	bfd1                	j	3996 <sbrkfail+0x90>
  if(!failed) {
    39c4:	000a8863          	beqz	s5,39d4 <sbrkfail+0xce>
  c = sbrk(PGSIZE);
    39c8:	6505                	lui	a0,0x1
    39ca:	376010ef          	jal	4d40 <sbrk>
    39ce:	8a2a                	mv	s4,a0
    if(pids[i] == -1)
    39d0:	597d                	li	s2,-1
    39d2:	a821                	j	39ea <sbrkfail+0xe4>
    printf("%s: no allocation failed; allocate more?\n", s);
    39d4:	85da                	mv	a1,s6
    39d6:	00003517          	auipc	a0,0x3
    39da:	50250513          	addi	a0,a0,1282 # 6ed8 <malloc+0x1c2a>
    39de:	01d010ef          	jal	51fa <printf>
    39e2:	b7dd                	j	39c8 <sbrkfail+0xc2>
  for(i = 0; i < sizeof(pids)/sizeof(pids[0]); i++){
    39e4:	0491                	addi	s1,s1,4
    39e6:	01348b63          	beq	s1,s3,39fc <sbrkfail+0xf6>
    if(pids[i] == -1)
    39ea:	4088                	lw	a0,0(s1)
    39ec:	ff250ce3          	beq	a0,s2,39e4 <sbrkfail+0xde>
    kill(pids[i]);
    39f0:	3f2010ef          	jal	4de2 <kill>
    wait(0);
    39f4:	4501                	li	a0,0
    39f6:	3c4010ef          	jal	4dba <wait>
    39fa:	b7ed                	j	39e4 <sbrkfail+0xde>
  if(c == (char*)SBRK_ERROR){
    39fc:	57fd                	li	a5,-1
    39fe:	02fa0a63          	beq	s4,a5,3a32 <sbrkfail+0x12c>
  pid = fork();
    3a02:	3a8010ef          	jal	4daa <fork>
  if(pid < 0){
    3a06:	04054063          	bltz	a0,3a46 <sbrkfail+0x140>
  if(pid == 0){
    3a0a:	e939                	bnez	a0,3a60 <sbrkfail+0x15a>
    a = sbrk(10*BIG);
    3a0c:	3e800537          	lui	a0,0x3e800
    3a10:	330010ef          	jal	4d40 <sbrk>
    if(a == (char*)SBRK_ERROR){
    3a14:	57fd                	li	a5,-1
    3a16:	04f50263          	beq	a0,a5,3a5a <sbrkfail+0x154>
    printf("%s: allocate a lot of memory succeeded %d\n", s, 10*BIG);
    3a1a:	3e800637          	lui	a2,0x3e800
    3a1e:	85da                	mv	a1,s6
    3a20:	00003517          	auipc	a0,0x3
    3a24:	50850513          	addi	a0,a0,1288 # 6f28 <malloc+0x1c7a>
    3a28:	7d2010ef          	jal	51fa <printf>
    exit(1);
    3a2c:	4505                	li	a0,1
    3a2e:	384010ef          	jal	4db2 <exit>
    printf("%s: failed sbrk leaked memory\n", s);
    3a32:	85da                	mv	a1,s6
    3a34:	00003517          	auipc	a0,0x3
    3a38:	4d450513          	addi	a0,a0,1236 # 6f08 <malloc+0x1c5a>
    3a3c:	7be010ef          	jal	51fa <printf>
    exit(1);
    3a40:	4505                	li	a0,1
    3a42:	370010ef          	jal	4db2 <exit>
    printf("%s: fork failed\n", s);
    3a46:	85da                	mv	a1,s6
    3a48:	00002517          	auipc	a0,0x2
    3a4c:	23050513          	addi	a0,a0,560 # 5c78 <malloc+0x9ca>
    3a50:	7aa010ef          	jal	51fa <printf>
    exit(1);
    3a54:	4505                	li	a0,1
    3a56:	35c010ef          	jal	4db2 <exit>
      exit(0);
    3a5a:	4501                	li	a0,0
    3a5c:	356010ef          	jal	4db2 <exit>
  wait(&xstatus);
    3a60:	fac40513          	addi	a0,s0,-84
    3a64:	356010ef          	jal	4dba <wait>
  if(xstatus != 0)
    3a68:	fac42783          	lw	a5,-84(s0)
    3a6c:	ef81                	bnez	a5,3a84 <sbrkfail+0x17e>
}
    3a6e:	60aa                	ld	ra,136(sp)
    3a70:	640a                	ld	s0,128(sp)
    3a72:	74e6                	ld	s1,120(sp)
    3a74:	7946                	ld	s2,112(sp)
    3a76:	79a6                	ld	s3,104(sp)
    3a78:	7a06                	ld	s4,96(sp)
    3a7a:	6ae6                	ld	s5,88(sp)
    3a7c:	6b46                	ld	s6,80(sp)
    3a7e:	6ba6                	ld	s7,72(sp)
    3a80:	6149                	addi	sp,sp,144
    3a82:	8082                	ret
    exit(1);
    3a84:	4505                	li	a0,1
    3a86:	32c010ef          	jal	4db2 <exit>

0000000000003a8a <mem>:
{
    3a8a:	7139                	addi	sp,sp,-64
    3a8c:	fc06                	sd	ra,56(sp)
    3a8e:	f822                	sd	s0,48(sp)
    3a90:	f426                	sd	s1,40(sp)
    3a92:	f04a                	sd	s2,32(sp)
    3a94:	ec4e                	sd	s3,24(sp)
    3a96:	0080                	addi	s0,sp,64
    3a98:	89aa                	mv	s3,a0
  if((pid = fork()) == 0){
    3a9a:	310010ef          	jal	4daa <fork>
    m1 = 0;
    3a9e:	4481                	li	s1,0
    while((m2 = malloc(10001)) != 0){
    3aa0:	6909                	lui	s2,0x2
    3aa2:	71190913          	addi	s2,s2,1809 # 2711 <fourteen+0x97>
  if((pid = fork()) == 0){
    3aa6:	cd11                	beqz	a0,3ac2 <mem+0x38>
    wait(&xstatus);
    3aa8:	fcc40513          	addi	a0,s0,-52
    3aac:	30e010ef          	jal	4dba <wait>
    if(xstatus == -1){
    3ab0:	fcc42503          	lw	a0,-52(s0)
    3ab4:	57fd                	li	a5,-1
    3ab6:	04f50363          	beq	a0,a5,3afc <mem+0x72>
    exit(xstatus);
    3aba:	2f8010ef          	jal	4db2 <exit>
      *(char**)m2 = m1;
    3abe:	e104                	sd	s1,0(a0)
      m1 = m2;
    3ac0:	84aa                	mv	s1,a0
    while((m2 = malloc(10001)) != 0){
    3ac2:	854a                	mv	a0,s2
    3ac4:	7ea010ef          	jal	52ae <malloc>
    3ac8:	f97d                	bnez	a0,3abe <mem+0x34>
    while(m1){
    3aca:	c491                	beqz	s1,3ad6 <mem+0x4c>
      m2 = *(char**)m1;
    3acc:	8526                	mv	a0,s1
    3ace:	6084                	ld	s1,0(s1)
      free(m1);
    3ad0:	75c010ef          	jal	522c <free>
    while(m1){
    3ad4:	fce5                	bnez	s1,3acc <mem+0x42>
    m1 = malloc(1024*20);
    3ad6:	6515                	lui	a0,0x5
    3ad8:	7d6010ef          	jal	52ae <malloc>
    if(m1 == 0){
    3adc:	c511                	beqz	a0,3ae8 <mem+0x5e>
    free(m1);
    3ade:	74e010ef          	jal	522c <free>
    exit(0);
    3ae2:	4501                	li	a0,0
    3ae4:	2ce010ef          	jal	4db2 <exit>
      printf("%s: couldn't allocate mem?!!\n", s);
    3ae8:	85ce                	mv	a1,s3
    3aea:	00003517          	auipc	a0,0x3
    3aee:	46e50513          	addi	a0,a0,1134 # 6f58 <malloc+0x1caa>
    3af2:	708010ef          	jal	51fa <printf>
      exit(1);
    3af6:	4505                	li	a0,1
    3af8:	2ba010ef          	jal	4db2 <exit>
      exit(0);
    3afc:	4501                	li	a0,0
    3afe:	2b4010ef          	jal	4db2 <exit>

0000000000003b02 <sharedfd>:
{
    3b02:	7159                	addi	sp,sp,-112
    3b04:	f486                	sd	ra,104(sp)
    3b06:	f0a2                	sd	s0,96(sp)
    3b08:	e0d2                	sd	s4,64(sp)
    3b0a:	1880                	addi	s0,sp,112
    3b0c:	8a2a                	mv	s4,a0
  unlink("sharedfd");
    3b0e:	00003517          	auipc	a0,0x3
    3b12:	46a50513          	addi	a0,a0,1130 # 6f78 <malloc+0x1cca>
    3b16:	2ec010ef          	jal	4e02 <unlink>
  fd = open("sharedfd", O_CREATE|O_RDWR);
    3b1a:	20200593          	li	a1,514
    3b1e:	00003517          	auipc	a0,0x3
    3b22:	45a50513          	addi	a0,a0,1114 # 6f78 <malloc+0x1cca>
    3b26:	2cc010ef          	jal	4df2 <open>
  if(fd < 0){
    3b2a:	04054863          	bltz	a0,3b7a <sharedfd+0x78>
    3b2e:	eca6                	sd	s1,88(sp)
    3b30:	e8ca                	sd	s2,80(sp)
    3b32:	e4ce                	sd	s3,72(sp)
    3b34:	fc56                	sd	s5,56(sp)
    3b36:	f85a                	sd	s6,48(sp)
    3b38:	f45e                	sd	s7,40(sp)
    3b3a:	892a                	mv	s2,a0
  pid = fork();
    3b3c:	26e010ef          	jal	4daa <fork>
    3b40:	89aa                	mv	s3,a0
  memset(buf, pid==0?'c':'p', sizeof(buf));
    3b42:	07000593          	li	a1,112
    3b46:	e119                	bnez	a0,3b4c <sharedfd+0x4a>
    3b48:	06300593          	li	a1,99
    3b4c:	4629                	li	a2,10
    3b4e:	fa040513          	addi	a0,s0,-96
    3b52:	010010ef          	jal	4b62 <memset>
    3b56:	3e800493          	li	s1,1000
    if(write(fd, buf, sizeof(buf)) != sizeof(buf)){
    3b5a:	4629                	li	a2,10
    3b5c:	fa040593          	addi	a1,s0,-96
    3b60:	854a                	mv	a0,s2
    3b62:	270010ef          	jal	4dd2 <write>
    3b66:	47a9                	li	a5,10
    3b68:	02f51963          	bne	a0,a5,3b9a <sharedfd+0x98>
  for(i = 0; i < N; i++){
    3b6c:	34fd                	addiw	s1,s1,-1
    3b6e:	f4f5                	bnez	s1,3b5a <sharedfd+0x58>
  if(pid == 0) {
    3b70:	02099f63          	bnez	s3,3bae <sharedfd+0xac>
    exit(0);
    3b74:	4501                	li	a0,0
    3b76:	23c010ef          	jal	4db2 <exit>
    3b7a:	eca6                	sd	s1,88(sp)
    3b7c:	e8ca                	sd	s2,80(sp)
    3b7e:	e4ce                	sd	s3,72(sp)
    3b80:	fc56                	sd	s5,56(sp)
    3b82:	f85a                	sd	s6,48(sp)
    3b84:	f45e                	sd	s7,40(sp)
    printf("%s: cannot open sharedfd for writing", s);
    3b86:	85d2                	mv	a1,s4
    3b88:	00003517          	auipc	a0,0x3
    3b8c:	40050513          	addi	a0,a0,1024 # 6f88 <malloc+0x1cda>
    3b90:	66a010ef          	jal	51fa <printf>
    exit(1);
    3b94:	4505                	li	a0,1
    3b96:	21c010ef          	jal	4db2 <exit>
      printf("%s: write sharedfd failed\n", s);
    3b9a:	85d2                	mv	a1,s4
    3b9c:	00003517          	auipc	a0,0x3
    3ba0:	41450513          	addi	a0,a0,1044 # 6fb0 <malloc+0x1d02>
    3ba4:	656010ef          	jal	51fa <printf>
      exit(1);
    3ba8:	4505                	li	a0,1
    3baa:	208010ef          	jal	4db2 <exit>
    wait(&xstatus);
    3bae:	f9c40513          	addi	a0,s0,-100
    3bb2:	208010ef          	jal	4dba <wait>
    if(xstatus != 0)
    3bb6:	f9c42983          	lw	s3,-100(s0)
    3bba:	00098563          	beqz	s3,3bc4 <sharedfd+0xc2>
      exit(xstatus);
    3bbe:	854e                	mv	a0,s3
    3bc0:	1f2010ef          	jal	4db2 <exit>
  close(fd);
    3bc4:	854a                	mv	a0,s2
    3bc6:	214010ef          	jal	4dda <close>
  fd = open("sharedfd", 0);
    3bca:	4581                	li	a1,0
    3bcc:	00003517          	auipc	a0,0x3
    3bd0:	3ac50513          	addi	a0,a0,940 # 6f78 <malloc+0x1cca>
    3bd4:	21e010ef          	jal	4df2 <open>
    3bd8:	8baa                	mv	s7,a0
  nc = np = 0;
    3bda:	8ace                	mv	s5,s3
  if(fd < 0){
    3bdc:	02054363          	bltz	a0,3c02 <sharedfd+0x100>
    3be0:	faa40913          	addi	s2,s0,-86
      if(buf[i] == 'c')
    3be4:	06300493          	li	s1,99
      if(buf[i] == 'p')
    3be8:	07000b13          	li	s6,112
  while((n = read(fd, buf, sizeof(buf))) > 0){
    3bec:	4629                	li	a2,10
    3bee:	fa040593          	addi	a1,s0,-96
    3bf2:	855e                	mv	a0,s7
    3bf4:	1d6010ef          	jal	4dca <read>
    3bf8:	02a05b63          	blez	a0,3c2e <sharedfd+0x12c>
    3bfc:	fa040793          	addi	a5,s0,-96
    3c00:	a839                	j	3c1e <sharedfd+0x11c>
    printf("%s: cannot open sharedfd for reading\n", s);
    3c02:	85d2                	mv	a1,s4
    3c04:	00003517          	auipc	a0,0x3
    3c08:	3cc50513          	addi	a0,a0,972 # 6fd0 <malloc+0x1d22>
    3c0c:	5ee010ef          	jal	51fa <printf>
    exit(1);
    3c10:	4505                	li	a0,1
    3c12:	1a0010ef          	jal	4db2 <exit>
        nc++;
    3c16:	2985                	addiw	s3,s3,1
    for(i = 0; i < sizeof(buf); i++){
    3c18:	0785                	addi	a5,a5,1 # 6400001 <base+0x63f1349>
    3c1a:	fd2789e3          	beq	a5,s2,3bec <sharedfd+0xea>
      if(buf[i] == 'c')
    3c1e:	0007c703          	lbu	a4,0(a5)
    3c22:	fe970ae3          	beq	a4,s1,3c16 <sharedfd+0x114>
      if(buf[i] == 'p')
    3c26:	ff6719e3          	bne	a4,s6,3c18 <sharedfd+0x116>
        np++;
    3c2a:	2a85                	addiw	s5,s5,1
    3c2c:	b7f5                	j	3c18 <sharedfd+0x116>
  close(fd);
    3c2e:	855e                	mv	a0,s7
    3c30:	1aa010ef          	jal	4dda <close>
  unlink("sharedfd");
    3c34:	00003517          	auipc	a0,0x3
    3c38:	34450513          	addi	a0,a0,836 # 6f78 <malloc+0x1cca>
    3c3c:	1c6010ef          	jal	4e02 <unlink>
  if(nc == N*SZ && np == N*SZ){
    3c40:	6789                	lui	a5,0x2
    3c42:	71078793          	addi	a5,a5,1808 # 2710 <fourteen+0x96>
    3c46:	00f99763          	bne	s3,a5,3c54 <sharedfd+0x152>
    3c4a:	6789                	lui	a5,0x2
    3c4c:	71078793          	addi	a5,a5,1808 # 2710 <fourteen+0x96>
    3c50:	00fa8c63          	beq	s5,a5,3c68 <sharedfd+0x166>
    printf("%s: nc/np test fails\n", s);
    3c54:	85d2                	mv	a1,s4
    3c56:	00003517          	auipc	a0,0x3
    3c5a:	3a250513          	addi	a0,a0,930 # 6ff8 <malloc+0x1d4a>
    3c5e:	59c010ef          	jal	51fa <printf>
    exit(1);
    3c62:	4505                	li	a0,1
    3c64:	14e010ef          	jal	4db2 <exit>
    exit(0);
    3c68:	4501                	li	a0,0
    3c6a:	148010ef          	jal	4db2 <exit>

0000000000003c6e <fourfiles>:
{
    3c6e:	7135                	addi	sp,sp,-160
    3c70:	ed06                	sd	ra,152(sp)
    3c72:	e922                	sd	s0,144(sp)
    3c74:	e526                	sd	s1,136(sp)
    3c76:	e14a                	sd	s2,128(sp)
    3c78:	fcce                	sd	s3,120(sp)
    3c7a:	f8d2                	sd	s4,112(sp)
    3c7c:	f4d6                	sd	s5,104(sp)
    3c7e:	f0da                	sd	s6,96(sp)
    3c80:	ecde                	sd	s7,88(sp)
    3c82:	e8e2                	sd	s8,80(sp)
    3c84:	e4e6                	sd	s9,72(sp)
    3c86:	e0ea                	sd	s10,64(sp)
    3c88:	fc6e                	sd	s11,56(sp)
    3c8a:	1100                	addi	s0,sp,160
    3c8c:	8caa                	mv	s9,a0
  char *names[] = { "f0", "f1", "f2", "f3" };
    3c8e:	00003797          	auipc	a5,0x3
    3c92:	38278793          	addi	a5,a5,898 # 7010 <malloc+0x1d62>
    3c96:	f6f43823          	sd	a5,-144(s0)
    3c9a:	00003797          	auipc	a5,0x3
    3c9e:	37e78793          	addi	a5,a5,894 # 7018 <malloc+0x1d6a>
    3ca2:	f6f43c23          	sd	a5,-136(s0)
    3ca6:	00003797          	auipc	a5,0x3
    3caa:	37a78793          	addi	a5,a5,890 # 7020 <malloc+0x1d72>
    3cae:	f8f43023          	sd	a5,-128(s0)
    3cb2:	00003797          	auipc	a5,0x3
    3cb6:	37678793          	addi	a5,a5,886 # 7028 <malloc+0x1d7a>
    3cba:	f8f43423          	sd	a5,-120(s0)
  for(pi = 0; pi < NCHILD; pi++){
    3cbe:	f7040b93          	addi	s7,s0,-144
  char *names[] = { "f0", "f1", "f2", "f3" };
    3cc2:	895e                	mv	s2,s7
  for(pi = 0; pi < NCHILD; pi++){
    3cc4:	4481                	li	s1,0
    3cc6:	4a11                	li	s4,4
    fname = names[pi];
    3cc8:	00093983          	ld	s3,0(s2)
    unlink(fname);
    3ccc:	854e                	mv	a0,s3
    3cce:	134010ef          	jal	4e02 <unlink>
    pid = fork();
    3cd2:	0d8010ef          	jal	4daa <fork>
    if(pid < 0){
    3cd6:	02054e63          	bltz	a0,3d12 <fourfiles+0xa4>
    if(pid == 0){
    3cda:	c531                	beqz	a0,3d26 <fourfiles+0xb8>
  for(pi = 0; pi < NCHILD; pi++){
    3cdc:	2485                	addiw	s1,s1,1
    3cde:	0921                	addi	s2,s2,8
    3ce0:	ff4494e3          	bne	s1,s4,3cc8 <fourfiles+0x5a>
    3ce4:	4491                	li	s1,4
    wait(&xstatus);
    3ce6:	f6c40513          	addi	a0,s0,-148
    3cea:	0d0010ef          	jal	4dba <wait>
    if(xstatus != 0)
    3cee:	f6c42a83          	lw	s5,-148(s0)
    3cf2:	0a0a9463          	bnez	s5,3d9a <fourfiles+0x12c>
  for(pi = 0; pi < NCHILD; pi++){
    3cf6:	34fd                	addiw	s1,s1,-1
    3cf8:	f4fd                	bnez	s1,3ce6 <fourfiles+0x78>
    3cfa:	03000b13          	li	s6,48
    while((n = read(fd, buf, sizeof(buf))) > 0){
    3cfe:	00008a17          	auipc	s4,0x8
    3d02:	fbaa0a13          	addi	s4,s4,-70 # bcb8 <buf>
    if(total != N*SZ){
    3d06:	6d05                	lui	s10,0x1
    3d08:	770d0d13          	addi	s10,s10,1904 # 1770 <forkfork+0x1e>
  for(i = 0; i < NCHILD; i++){
    3d0c:	03400d93          	li	s11,52
    3d10:	a0ed                	j	3dfa <fourfiles+0x18c>
      printf("%s: fork failed\n", s);
    3d12:	85e6                	mv	a1,s9
    3d14:	00002517          	auipc	a0,0x2
    3d18:	f6450513          	addi	a0,a0,-156 # 5c78 <malloc+0x9ca>
    3d1c:	4de010ef          	jal	51fa <printf>
      exit(1);
    3d20:	4505                	li	a0,1
    3d22:	090010ef          	jal	4db2 <exit>
      fd = open(fname, O_CREATE | O_RDWR);
    3d26:	20200593          	li	a1,514
    3d2a:	854e                	mv	a0,s3
    3d2c:	0c6010ef          	jal	4df2 <open>
    3d30:	892a                	mv	s2,a0
      if(fd < 0){
    3d32:	04054163          	bltz	a0,3d74 <fourfiles+0x106>
      memset(buf, '0'+pi, SZ);
    3d36:	1f400613          	li	a2,500
    3d3a:	0304859b          	addiw	a1,s1,48
    3d3e:	00008517          	auipc	a0,0x8
    3d42:	f7a50513          	addi	a0,a0,-134 # bcb8 <buf>
    3d46:	61d000ef          	jal	4b62 <memset>
    3d4a:	44b1                	li	s1,12
        if((n = write(fd, buf, SZ)) != SZ){
    3d4c:	00008997          	auipc	s3,0x8
    3d50:	f6c98993          	addi	s3,s3,-148 # bcb8 <buf>
    3d54:	1f400613          	li	a2,500
    3d58:	85ce                	mv	a1,s3
    3d5a:	854a                	mv	a0,s2
    3d5c:	076010ef          	jal	4dd2 <write>
    3d60:	85aa                	mv	a1,a0
    3d62:	1f400793          	li	a5,500
    3d66:	02f51163          	bne	a0,a5,3d88 <fourfiles+0x11a>
      for(i = 0; i < N; i++){
    3d6a:	34fd                	addiw	s1,s1,-1
    3d6c:	f4e5                	bnez	s1,3d54 <fourfiles+0xe6>
      exit(0);
    3d6e:	4501                	li	a0,0
    3d70:	042010ef          	jal	4db2 <exit>
        printf("%s: create failed\n", s);
    3d74:	85e6                	mv	a1,s9
    3d76:	00002517          	auipc	a0,0x2
    3d7a:	f9a50513          	addi	a0,a0,-102 # 5d10 <malloc+0xa62>
    3d7e:	47c010ef          	jal	51fa <printf>
        exit(1);
    3d82:	4505                	li	a0,1
    3d84:	02e010ef          	jal	4db2 <exit>
          printf("write failed %d\n", n);
    3d88:	00003517          	auipc	a0,0x3
    3d8c:	2a850513          	addi	a0,a0,680 # 7030 <malloc+0x1d82>
    3d90:	46a010ef          	jal	51fa <printf>
          exit(1);
    3d94:	4505                	li	a0,1
    3d96:	01c010ef          	jal	4db2 <exit>
      exit(xstatus);
    3d9a:	8556                	mv	a0,s5
    3d9c:	016010ef          	jal	4db2 <exit>
          printf("%s: wrong char\n", s);
    3da0:	85e6                	mv	a1,s9
    3da2:	00003517          	auipc	a0,0x3
    3da6:	2a650513          	addi	a0,a0,678 # 7048 <malloc+0x1d9a>
    3daa:	450010ef          	jal	51fa <printf>
          exit(1);
    3dae:	4505                	li	a0,1
    3db0:	002010ef          	jal	4db2 <exit>
      total += n;
    3db4:	00a9093b          	addw	s2,s2,a0
    while((n = read(fd, buf, sizeof(buf))) > 0){
    3db8:	660d                	lui	a2,0x3
    3dba:	85d2                	mv	a1,s4
    3dbc:	854e                	mv	a0,s3
    3dbe:	00c010ef          	jal	4dca <read>
    3dc2:	02a05063          	blez	a0,3de2 <fourfiles+0x174>
    3dc6:	00008797          	auipc	a5,0x8
    3dca:	ef278793          	addi	a5,a5,-270 # bcb8 <buf>
    3dce:	00f506b3          	add	a3,a0,a5
        if(buf[j] != '0'+i){
    3dd2:	0007c703          	lbu	a4,0(a5)
    3dd6:	fc9715e3          	bne	a4,s1,3da0 <fourfiles+0x132>
      for(j = 0; j < n; j++){
    3dda:	0785                	addi	a5,a5,1
    3ddc:	fed79be3          	bne	a5,a3,3dd2 <fourfiles+0x164>
    3de0:	bfd1                	j	3db4 <fourfiles+0x146>
    close(fd);
    3de2:	854e                	mv	a0,s3
    3de4:	7f7000ef          	jal	4dda <close>
    if(total != N*SZ){
    3de8:	03a91463          	bne	s2,s10,3e10 <fourfiles+0x1a2>
    unlink(fname);
    3dec:	8562                	mv	a0,s8
    3dee:	014010ef          	jal	4e02 <unlink>
  for(i = 0; i < NCHILD; i++){
    3df2:	0ba1                	addi	s7,s7,8
    3df4:	2b05                	addiw	s6,s6,1
    3df6:	03bb0763          	beq	s6,s11,3e24 <fourfiles+0x1b6>
    fname = names[i];
    3dfa:	000bbc03          	ld	s8,0(s7)
    fd = open(fname, 0);
    3dfe:	4581                	li	a1,0
    3e00:	8562                	mv	a0,s8
    3e02:	7f1000ef          	jal	4df2 <open>
    3e06:	89aa                	mv	s3,a0
    total = 0;
    3e08:	8956                	mv	s2,s5
        if(buf[j] != '0'+i){
    3e0a:	000b049b          	sext.w	s1,s6
    while((n = read(fd, buf, sizeof(buf))) > 0){
    3e0e:	b76d                	j	3db8 <fourfiles+0x14a>
      printf("wrong length %d\n", total);
    3e10:	85ca                	mv	a1,s2
    3e12:	00003517          	auipc	a0,0x3
    3e16:	24650513          	addi	a0,a0,582 # 7058 <malloc+0x1daa>
    3e1a:	3e0010ef          	jal	51fa <printf>
      exit(1);
    3e1e:	4505                	li	a0,1
    3e20:	793000ef          	jal	4db2 <exit>
}
    3e24:	60ea                	ld	ra,152(sp)
    3e26:	644a                	ld	s0,144(sp)
    3e28:	64aa                	ld	s1,136(sp)
    3e2a:	690a                	ld	s2,128(sp)
    3e2c:	79e6                	ld	s3,120(sp)
    3e2e:	7a46                	ld	s4,112(sp)
    3e30:	7aa6                	ld	s5,104(sp)
    3e32:	7b06                	ld	s6,96(sp)
    3e34:	6be6                	ld	s7,88(sp)
    3e36:	6c46                	ld	s8,80(sp)
    3e38:	6ca6                	ld	s9,72(sp)
    3e3a:	6d06                	ld	s10,64(sp)
    3e3c:	7de2                	ld	s11,56(sp)
    3e3e:	610d                	addi	sp,sp,160
    3e40:	8082                	ret

0000000000003e42 <concreate>:
{
    3e42:	7135                	addi	sp,sp,-160
    3e44:	ed06                	sd	ra,152(sp)
    3e46:	e922                	sd	s0,144(sp)
    3e48:	e526                	sd	s1,136(sp)
    3e4a:	e14a                	sd	s2,128(sp)
    3e4c:	fcce                	sd	s3,120(sp)
    3e4e:	f8d2                	sd	s4,112(sp)
    3e50:	f4d6                	sd	s5,104(sp)
    3e52:	f0da                	sd	s6,96(sp)
    3e54:	ecde                	sd	s7,88(sp)
    3e56:	1100                	addi	s0,sp,160
    3e58:	89aa                	mv	s3,a0
  file[0] = 'C';
    3e5a:	04300793          	li	a5,67
    3e5e:	faf40423          	sb	a5,-88(s0)
  file[2] = '\0';
    3e62:	fa040523          	sb	zero,-86(s0)
  for(i = 0; i < N; i++){
    3e66:	4901                	li	s2,0
    if(pid && (i % 3) == 1){
    3e68:	4b0d                	li	s6,3
    3e6a:	4a85                	li	s5,1
      link("C0", file);
    3e6c:	00003b97          	auipc	s7,0x3
    3e70:	204b8b93          	addi	s7,s7,516 # 7070 <malloc+0x1dc2>
  for(i = 0; i < N; i++){
    3e74:	02800a13          	li	s4,40
    3e78:	a41d                	j	409e <concreate+0x25c>
      link("C0", file);
    3e7a:	fa840593          	addi	a1,s0,-88
    3e7e:	855e                	mv	a0,s7
    3e80:	793000ef          	jal	4e12 <link>
    if(pid == 0) {
    3e84:	a411                	j	4088 <concreate+0x246>
    } else if(pid == 0 && (i % 5) == 1){
    3e86:	4795                	li	a5,5
    3e88:	02f9693b          	remw	s2,s2,a5
    3e8c:	4785                	li	a5,1
    3e8e:	02f90563          	beq	s2,a5,3eb8 <concreate+0x76>
      fd = open(file, O_CREATE | O_RDWR);
    3e92:	20200593          	li	a1,514
    3e96:	fa840513          	addi	a0,s0,-88
    3e9a:	759000ef          	jal	4df2 <open>
      if(fd < 0){
    3e9e:	1e055063          	bgez	a0,407e <concreate+0x23c>
        printf("concreate create %s failed\n", file);
    3ea2:	fa840593          	addi	a1,s0,-88
    3ea6:	00003517          	auipc	a0,0x3
    3eaa:	1d250513          	addi	a0,a0,466 # 7078 <malloc+0x1dca>
    3eae:	34c010ef          	jal	51fa <printf>
        exit(1);
    3eb2:	4505                	li	a0,1
    3eb4:	6ff000ef          	jal	4db2 <exit>
      link("C0", file);
    3eb8:	fa840593          	addi	a1,s0,-88
    3ebc:	00003517          	auipc	a0,0x3
    3ec0:	1b450513          	addi	a0,a0,436 # 7070 <malloc+0x1dc2>
    3ec4:	74f000ef          	jal	4e12 <link>
      exit(0);
    3ec8:	4501                	li	a0,0
    3eca:	6e9000ef          	jal	4db2 <exit>
        exit(1);
    3ece:	4505                	li	a0,1
    3ed0:	6e3000ef          	jal	4db2 <exit>
  memset(fa, 0, sizeof(fa));
    3ed4:	02800613          	li	a2,40
    3ed8:	4581                	li	a1,0
    3eda:	f8040513          	addi	a0,s0,-128
    3ede:	485000ef          	jal	4b62 <memset>
  fd = open(".", 0);
    3ee2:	4581                	li	a1,0
    3ee4:	00002517          	auipc	a0,0x2
    3ee8:	bec50513          	addi	a0,a0,-1044 # 5ad0 <malloc+0x822>
    3eec:	707000ef          	jal	4df2 <open>
    3ef0:	892a                	mv	s2,a0
  n = 0;
    3ef2:	8aa6                	mv	s5,s1
    if(de.name[0] == 'C' && de.name[2] == '\0'){
    3ef4:	04300a13          	li	s4,67
      if(i < 0 || i >= sizeof(fa)){
    3ef8:	02700b13          	li	s6,39
      fa[i] = 1;
    3efc:	4b85                	li	s7,1
  while(read(fd, &de, sizeof(de)) > 0){
    3efe:	4641                	li	a2,16
    3f00:	f7040593          	addi	a1,s0,-144
    3f04:	854a                	mv	a0,s2
    3f06:	6c5000ef          	jal	4dca <read>
    3f0a:	06a05a63          	blez	a0,3f7e <concreate+0x13c>
    if(de.inum == 0)
    3f0e:	f7045783          	lhu	a5,-144(s0)
    3f12:	d7f5                	beqz	a5,3efe <concreate+0xbc>
    if(de.name[0] == 'C' && de.name[2] == '\0'){
    3f14:	f7244783          	lbu	a5,-142(s0)
    3f18:	ff4793e3          	bne	a5,s4,3efe <concreate+0xbc>
    3f1c:	f7444783          	lbu	a5,-140(s0)
    3f20:	fff9                	bnez	a5,3efe <concreate+0xbc>
      i = de.name[1] - '0';
    3f22:	f7344783          	lbu	a5,-141(s0)
    3f26:	fd07879b          	addiw	a5,a5,-48
    3f2a:	0007871b          	sext.w	a4,a5
      if(i < 0 || i >= sizeof(fa)){
    3f2e:	02eb6063          	bltu	s6,a4,3f4e <concreate+0x10c>
      if(fa[i]){
    3f32:	fb070793          	addi	a5,a4,-80
    3f36:	97a2                	add	a5,a5,s0
    3f38:	fd07c783          	lbu	a5,-48(a5)
    3f3c:	e78d                	bnez	a5,3f66 <concreate+0x124>
      fa[i] = 1;
    3f3e:	fb070793          	addi	a5,a4,-80
    3f42:	00878733          	add	a4,a5,s0
    3f46:	fd770823          	sb	s7,-48(a4)
      n++;
    3f4a:	2a85                	addiw	s5,s5,1
    3f4c:	bf4d                	j	3efe <concreate+0xbc>
        printf("%s: concreate weird file %s\n", s, de.name);
    3f4e:	f7240613          	addi	a2,s0,-142
    3f52:	85ce                	mv	a1,s3
    3f54:	00003517          	auipc	a0,0x3
    3f58:	14450513          	addi	a0,a0,324 # 7098 <malloc+0x1dea>
    3f5c:	29e010ef          	jal	51fa <printf>
        exit(1);
    3f60:	4505                	li	a0,1
    3f62:	651000ef          	jal	4db2 <exit>
        printf("%s: concreate duplicate file %s\n", s, de.name);
    3f66:	f7240613          	addi	a2,s0,-142
    3f6a:	85ce                	mv	a1,s3
    3f6c:	00003517          	auipc	a0,0x3
    3f70:	14c50513          	addi	a0,a0,332 # 70b8 <malloc+0x1e0a>
    3f74:	286010ef          	jal	51fa <printf>
        exit(1);
    3f78:	4505                	li	a0,1
    3f7a:	639000ef          	jal	4db2 <exit>
  close(fd);
    3f7e:	854a                	mv	a0,s2
    3f80:	65b000ef          	jal	4dda <close>
  if(n != N){
    3f84:	02800793          	li	a5,40
    3f88:	00fa9763          	bne	s5,a5,3f96 <concreate+0x154>
    if(((i % 3) == 0 && pid == 0) ||
    3f8c:	4a8d                	li	s5,3
    3f8e:	4b05                	li	s6,1
  for(i = 0; i < N; i++){
    3f90:	02800a13          	li	s4,40
    3f94:	a079                	j	4022 <concreate+0x1e0>
    printf("%s: concreate not enough files in directory listing\n", s);
    3f96:	85ce                	mv	a1,s3
    3f98:	00003517          	auipc	a0,0x3
    3f9c:	14850513          	addi	a0,a0,328 # 70e0 <malloc+0x1e32>
    3fa0:	25a010ef          	jal	51fa <printf>
    exit(1);
    3fa4:	4505                	li	a0,1
    3fa6:	60d000ef          	jal	4db2 <exit>
      printf("%s: fork failed\n", s);
    3faa:	85ce                	mv	a1,s3
    3fac:	00002517          	auipc	a0,0x2
    3fb0:	ccc50513          	addi	a0,a0,-820 # 5c78 <malloc+0x9ca>
    3fb4:	246010ef          	jal	51fa <printf>
      exit(1);
    3fb8:	4505                	li	a0,1
    3fba:	5f9000ef          	jal	4db2 <exit>
      close(open(file, 0));
    3fbe:	4581                	li	a1,0
    3fc0:	fa840513          	addi	a0,s0,-88
    3fc4:	62f000ef          	jal	4df2 <open>
    3fc8:	613000ef          	jal	4dda <close>
      close(open(file, 0));
    3fcc:	4581                	li	a1,0
    3fce:	fa840513          	addi	a0,s0,-88
    3fd2:	621000ef          	jal	4df2 <open>
    3fd6:	605000ef          	jal	4dda <close>
      close(open(file, 0));
    3fda:	4581                	li	a1,0
    3fdc:	fa840513          	addi	a0,s0,-88
    3fe0:	613000ef          	jal	4df2 <open>
    3fe4:	5f7000ef          	jal	4dda <close>
      close(open(file, 0));
    3fe8:	4581                	li	a1,0
    3fea:	fa840513          	addi	a0,s0,-88
    3fee:	605000ef          	jal	4df2 <open>
    3ff2:	5e9000ef          	jal	4dda <close>
      close(open(file, 0));
    3ff6:	4581                	li	a1,0
    3ff8:	fa840513          	addi	a0,s0,-88
    3ffc:	5f7000ef          	jal	4df2 <open>
    4000:	5db000ef          	jal	4dda <close>
      close(open(file, 0));
    4004:	4581                	li	a1,0
    4006:	fa840513          	addi	a0,s0,-88
    400a:	5e9000ef          	jal	4df2 <open>
    400e:	5cd000ef          	jal	4dda <close>
    if(pid == 0)
    4012:	06090363          	beqz	s2,4078 <concreate+0x236>
      wait(0);
    4016:	4501                	li	a0,0
    4018:	5a3000ef          	jal	4dba <wait>
  for(i = 0; i < N; i++){
    401c:	2485                	addiw	s1,s1,1
    401e:	0b448963          	beq	s1,s4,40d0 <concreate+0x28e>
    file[1] = '0' + i;
    4022:	0304879b          	addiw	a5,s1,48
    4026:	faf404a3          	sb	a5,-87(s0)
    pid = fork();
    402a:	581000ef          	jal	4daa <fork>
    402e:	892a                	mv	s2,a0
    if(pid < 0){
    4030:	f6054de3          	bltz	a0,3faa <concreate+0x168>
    if(((i % 3) == 0 && pid == 0) ||
    4034:	0354e73b          	remw	a4,s1,s5
    4038:	00a767b3          	or	a5,a4,a0
    403c:	2781                	sext.w	a5,a5
    403e:	d3c1                	beqz	a5,3fbe <concreate+0x17c>
    4040:	01671363          	bne	a4,s6,4046 <concreate+0x204>
       ((i % 3) == 1 && pid != 0)){
    4044:	fd2d                	bnez	a0,3fbe <concreate+0x17c>
      unlink(file);
    4046:	fa840513          	addi	a0,s0,-88
    404a:	5b9000ef          	jal	4e02 <unlink>
      unlink(file);
    404e:	fa840513          	addi	a0,s0,-88
    4052:	5b1000ef          	jal	4e02 <unlink>
      unlink(file);
    4056:	fa840513          	addi	a0,s0,-88
    405a:	5a9000ef          	jal	4e02 <unlink>
      unlink(file);
    405e:	fa840513          	addi	a0,s0,-88
    4062:	5a1000ef          	jal	4e02 <unlink>
      unlink(file);
    4066:	fa840513          	addi	a0,s0,-88
    406a:	599000ef          	jal	4e02 <unlink>
      unlink(file);
    406e:	fa840513          	addi	a0,s0,-88
    4072:	591000ef          	jal	4e02 <unlink>
    4076:	bf71                	j	4012 <concreate+0x1d0>
      exit(0);
    4078:	4501                	li	a0,0
    407a:	539000ef          	jal	4db2 <exit>
      close(fd);
    407e:	55d000ef          	jal	4dda <close>
    if(pid == 0) {
    4082:	b599                	j	3ec8 <concreate+0x86>
      close(fd);
    4084:	557000ef          	jal	4dda <close>
      wait(&xstatus);
    4088:	f6c40513          	addi	a0,s0,-148
    408c:	52f000ef          	jal	4dba <wait>
      if(xstatus != 0)
    4090:	f6c42483          	lw	s1,-148(s0)
    4094:	e2049de3          	bnez	s1,3ece <concreate+0x8c>
  for(i = 0; i < N; i++){
    4098:	2905                	addiw	s2,s2,1
    409a:	e3490de3          	beq	s2,s4,3ed4 <concreate+0x92>
    file[1] = '0' + i;
    409e:	0309079b          	addiw	a5,s2,48
    40a2:	faf404a3          	sb	a5,-87(s0)
    unlink(file);
    40a6:	fa840513          	addi	a0,s0,-88
    40aa:	559000ef          	jal	4e02 <unlink>
    pid = fork();
    40ae:	4fd000ef          	jal	4daa <fork>
    if(pid && (i % 3) == 1){
    40b2:	dc050ae3          	beqz	a0,3e86 <concreate+0x44>
    40b6:	036967bb          	remw	a5,s2,s6
    40ba:	dd5780e3          	beq	a5,s5,3e7a <concreate+0x38>
      fd = open(file, O_CREATE | O_RDWR);
    40be:	20200593          	li	a1,514
    40c2:	fa840513          	addi	a0,s0,-88
    40c6:	52d000ef          	jal	4df2 <open>
      if(fd < 0){
    40ca:	fa055de3          	bgez	a0,4084 <concreate+0x242>
    40ce:	bbd1                	j	3ea2 <concreate+0x60>
}
    40d0:	60ea                	ld	ra,152(sp)
    40d2:	644a                	ld	s0,144(sp)
    40d4:	64aa                	ld	s1,136(sp)
    40d6:	690a                	ld	s2,128(sp)
    40d8:	79e6                	ld	s3,120(sp)
    40da:	7a46                	ld	s4,112(sp)
    40dc:	7aa6                	ld	s5,104(sp)
    40de:	7b06                	ld	s6,96(sp)
    40e0:	6be6                	ld	s7,88(sp)
    40e2:	610d                	addi	sp,sp,160
    40e4:	8082                	ret

00000000000040e6 <bigfile>:
{
    40e6:	7139                	addi	sp,sp,-64
    40e8:	fc06                	sd	ra,56(sp)
    40ea:	f822                	sd	s0,48(sp)
    40ec:	f426                	sd	s1,40(sp)
    40ee:	f04a                	sd	s2,32(sp)
    40f0:	ec4e                	sd	s3,24(sp)
    40f2:	e852                	sd	s4,16(sp)
    40f4:	e456                	sd	s5,8(sp)
    40f6:	0080                	addi	s0,sp,64
    40f8:	8aaa                	mv	s5,a0
  unlink("bigfile.dat");
    40fa:	00003517          	auipc	a0,0x3
    40fe:	01e50513          	addi	a0,a0,30 # 7118 <malloc+0x1e6a>
    4102:	501000ef          	jal	4e02 <unlink>
  fd = open("bigfile.dat", O_CREATE | O_RDWR);
    4106:	20200593          	li	a1,514
    410a:	00003517          	auipc	a0,0x3
    410e:	00e50513          	addi	a0,a0,14 # 7118 <malloc+0x1e6a>
    4112:	4e1000ef          	jal	4df2 <open>
    4116:	89aa                	mv	s3,a0
  for(i = 0; i < N; i++){
    4118:	4481                	li	s1,0
    memset(buf, i, SZ);
    411a:	00008917          	auipc	s2,0x8
    411e:	b9e90913          	addi	s2,s2,-1122 # bcb8 <buf>
  for(i = 0; i < N; i++){
    4122:	4a51                	li	s4,20
  if(fd < 0){
    4124:	08054663          	bltz	a0,41b0 <bigfile+0xca>
    memset(buf, i, SZ);
    4128:	25800613          	li	a2,600
    412c:	85a6                	mv	a1,s1
    412e:	854a                	mv	a0,s2
    4130:	233000ef          	jal	4b62 <memset>
    if(write(fd, buf, SZ) != SZ){
    4134:	25800613          	li	a2,600
    4138:	85ca                	mv	a1,s2
    413a:	854e                	mv	a0,s3
    413c:	497000ef          	jal	4dd2 <write>
    4140:	25800793          	li	a5,600
    4144:	08f51063          	bne	a0,a5,41c4 <bigfile+0xde>
  for(i = 0; i < N; i++){
    4148:	2485                	addiw	s1,s1,1
    414a:	fd449fe3          	bne	s1,s4,4128 <bigfile+0x42>
  close(fd);
    414e:	854e                	mv	a0,s3
    4150:	48b000ef          	jal	4dda <close>
  fd = open("bigfile.dat", 0);
    4154:	4581                	li	a1,0
    4156:	00003517          	auipc	a0,0x3
    415a:	fc250513          	addi	a0,a0,-62 # 7118 <malloc+0x1e6a>
    415e:	495000ef          	jal	4df2 <open>
    4162:	8a2a                	mv	s4,a0
  total = 0;
    4164:	4981                	li	s3,0
  for(i = 0; ; i++){
    4166:	4481                	li	s1,0
    cc = read(fd, buf, SZ/2);
    4168:	00008917          	auipc	s2,0x8
    416c:	b5090913          	addi	s2,s2,-1200 # bcb8 <buf>
  if(fd < 0){
    4170:	06054463          	bltz	a0,41d8 <bigfile+0xf2>
    cc = read(fd, buf, SZ/2);
    4174:	12c00613          	li	a2,300
    4178:	85ca                	mv	a1,s2
    417a:	8552                	mv	a0,s4
    417c:	44f000ef          	jal	4dca <read>
    if(cc < 0){
    4180:	06054663          	bltz	a0,41ec <bigfile+0x106>
    if(cc == 0)
    4184:	c155                	beqz	a0,4228 <bigfile+0x142>
    if(cc != SZ/2){
    4186:	12c00793          	li	a5,300
    418a:	06f51b63          	bne	a0,a5,4200 <bigfile+0x11a>
    if(buf[0] != i/2 || buf[SZ/2-1] != i/2){
    418e:	01f4d79b          	srliw	a5,s1,0x1f
    4192:	9fa5                	addw	a5,a5,s1
    4194:	4017d79b          	sraiw	a5,a5,0x1
    4198:	00094703          	lbu	a4,0(s2)
    419c:	06f71c63          	bne	a4,a5,4214 <bigfile+0x12e>
    41a0:	12b94703          	lbu	a4,299(s2)
    41a4:	06f71863          	bne	a4,a5,4214 <bigfile+0x12e>
    total += cc;
    41a8:	12c9899b          	addiw	s3,s3,300
  for(i = 0; ; i++){
    41ac:	2485                	addiw	s1,s1,1
    cc = read(fd, buf, SZ/2);
    41ae:	b7d9                	j	4174 <bigfile+0x8e>
    printf("%s: cannot create bigfile", s);
    41b0:	85d6                	mv	a1,s5
    41b2:	00003517          	auipc	a0,0x3
    41b6:	f7650513          	addi	a0,a0,-138 # 7128 <malloc+0x1e7a>
    41ba:	040010ef          	jal	51fa <printf>
    exit(1);
    41be:	4505                	li	a0,1
    41c0:	3f3000ef          	jal	4db2 <exit>
      printf("%s: write bigfile failed\n", s);
    41c4:	85d6                	mv	a1,s5
    41c6:	00003517          	auipc	a0,0x3
    41ca:	f8250513          	addi	a0,a0,-126 # 7148 <malloc+0x1e9a>
    41ce:	02c010ef          	jal	51fa <printf>
      exit(1);
    41d2:	4505                	li	a0,1
    41d4:	3df000ef          	jal	4db2 <exit>
    printf("%s: cannot open bigfile\n", s);
    41d8:	85d6                	mv	a1,s5
    41da:	00003517          	auipc	a0,0x3
    41de:	f8e50513          	addi	a0,a0,-114 # 7168 <malloc+0x1eba>
    41e2:	018010ef          	jal	51fa <printf>
    exit(1);
    41e6:	4505                	li	a0,1
    41e8:	3cb000ef          	jal	4db2 <exit>
      printf("%s: read bigfile failed\n", s);
    41ec:	85d6                	mv	a1,s5
    41ee:	00003517          	auipc	a0,0x3
    41f2:	f9a50513          	addi	a0,a0,-102 # 7188 <malloc+0x1eda>
    41f6:	004010ef          	jal	51fa <printf>
      exit(1);
    41fa:	4505                	li	a0,1
    41fc:	3b7000ef          	jal	4db2 <exit>
      printf("%s: short read bigfile\n", s);
    4200:	85d6                	mv	a1,s5
    4202:	00003517          	auipc	a0,0x3
    4206:	fa650513          	addi	a0,a0,-90 # 71a8 <malloc+0x1efa>
    420a:	7f1000ef          	jal	51fa <printf>
      exit(1);
    420e:	4505                	li	a0,1
    4210:	3a3000ef          	jal	4db2 <exit>
      printf("%s: read bigfile wrong data\n", s);
    4214:	85d6                	mv	a1,s5
    4216:	00003517          	auipc	a0,0x3
    421a:	faa50513          	addi	a0,a0,-86 # 71c0 <malloc+0x1f12>
    421e:	7dd000ef          	jal	51fa <printf>
      exit(1);
    4222:	4505                	li	a0,1
    4224:	38f000ef          	jal	4db2 <exit>
  close(fd);
    4228:	8552                	mv	a0,s4
    422a:	3b1000ef          	jal	4dda <close>
  if(total != N*SZ){
    422e:	678d                	lui	a5,0x3
    4230:	ee078793          	addi	a5,a5,-288 # 2ee0 <subdir+0x31e>
    4234:	02f99163          	bne	s3,a5,4256 <bigfile+0x170>
  unlink("bigfile.dat");
    4238:	00003517          	auipc	a0,0x3
    423c:	ee050513          	addi	a0,a0,-288 # 7118 <malloc+0x1e6a>
    4240:	3c3000ef          	jal	4e02 <unlink>
}
    4244:	70e2                	ld	ra,56(sp)
    4246:	7442                	ld	s0,48(sp)
    4248:	74a2                	ld	s1,40(sp)
    424a:	7902                	ld	s2,32(sp)
    424c:	69e2                	ld	s3,24(sp)
    424e:	6a42                	ld	s4,16(sp)
    4250:	6aa2                	ld	s5,8(sp)
    4252:	6121                	addi	sp,sp,64
    4254:	8082                	ret
    printf("%s: read bigfile wrong total\n", s);
    4256:	85d6                	mv	a1,s5
    4258:	00003517          	auipc	a0,0x3
    425c:	f8850513          	addi	a0,a0,-120 # 71e0 <malloc+0x1f32>
    4260:	79b000ef          	jal	51fa <printf>
    exit(1);
    4264:	4505                	li	a0,1
    4266:	34d000ef          	jal	4db2 <exit>

000000000000426a <bigargtest>:
{
    426a:	7121                	addi	sp,sp,-448
    426c:	ff06                	sd	ra,440(sp)
    426e:	fb22                	sd	s0,432(sp)
    4270:	f726                	sd	s1,424(sp)
    4272:	0380                	addi	s0,sp,448
    4274:	84aa                	mv	s1,a0
  unlink("bigarg-ok");
    4276:	00003517          	auipc	a0,0x3
    427a:	f8a50513          	addi	a0,a0,-118 # 7200 <malloc+0x1f52>
    427e:	385000ef          	jal	4e02 <unlink>
  pid = fork();
    4282:	329000ef          	jal	4daa <fork>
  if(pid == 0){
    4286:	c915                	beqz	a0,42ba <bigargtest+0x50>
  } else if(pid < 0){
    4288:	08054a63          	bltz	a0,431c <bigargtest+0xb2>
  wait(&xstatus);
    428c:	fdc40513          	addi	a0,s0,-36
    4290:	32b000ef          	jal	4dba <wait>
  if(xstatus != 0)
    4294:	fdc42503          	lw	a0,-36(s0)
    4298:	ed41                	bnez	a0,4330 <bigargtest+0xc6>
  fd = open("bigarg-ok", 0);
    429a:	4581                	li	a1,0
    429c:	00003517          	auipc	a0,0x3
    42a0:	f6450513          	addi	a0,a0,-156 # 7200 <malloc+0x1f52>
    42a4:	34f000ef          	jal	4df2 <open>
  if(fd < 0){
    42a8:	08054663          	bltz	a0,4334 <bigargtest+0xca>
  close(fd);
    42ac:	32f000ef          	jal	4dda <close>
}
    42b0:	70fa                	ld	ra,440(sp)
    42b2:	745a                	ld	s0,432(sp)
    42b4:	74ba                	ld	s1,424(sp)
    42b6:	6139                	addi	sp,sp,448
    42b8:	8082                	ret
    memset(big, ' ', sizeof(big));
    42ba:	19000613          	li	a2,400
    42be:	02000593          	li	a1,32
    42c2:	e4840513          	addi	a0,s0,-440
    42c6:	09d000ef          	jal	4b62 <memset>
    big[sizeof(big)-1] = '\0';
    42ca:	fc040ba3          	sb	zero,-41(s0)
    for(i = 0; i < MAXARG-1; i++)
    42ce:	00004797          	auipc	a5,0x4
    42d2:	1d278793          	addi	a5,a5,466 # 84a0 <args.1>
    42d6:	00004697          	auipc	a3,0x4
    42da:	2c268693          	addi	a3,a3,706 # 8598 <args.1+0xf8>
      args[i] = big;
    42de:	e4840713          	addi	a4,s0,-440
    42e2:	e398                	sd	a4,0(a5)
    for(i = 0; i < MAXARG-1; i++)
    42e4:	07a1                	addi	a5,a5,8
    42e6:	fed79ee3          	bne	a5,a3,42e2 <bigargtest+0x78>
    args[MAXARG-1] = 0;
    42ea:	00004597          	auipc	a1,0x4
    42ee:	1b658593          	addi	a1,a1,438 # 84a0 <args.1>
    42f2:	0e05bc23          	sd	zero,248(a1)
    exec("echo", args);
    42f6:	00001517          	auipc	a0,0x1
    42fa:	0f250513          	addi	a0,a0,242 # 53e8 <malloc+0x13a>
    42fe:	2ed000ef          	jal	4dea <exec>
    fd = open("bigarg-ok", O_CREATE);
    4302:	20000593          	li	a1,512
    4306:	00003517          	auipc	a0,0x3
    430a:	efa50513          	addi	a0,a0,-262 # 7200 <malloc+0x1f52>
    430e:	2e5000ef          	jal	4df2 <open>
    close(fd);
    4312:	2c9000ef          	jal	4dda <close>
    exit(0);
    4316:	4501                	li	a0,0
    4318:	29b000ef          	jal	4db2 <exit>
    printf("%s: bigargtest: fork failed\n", s);
    431c:	85a6                	mv	a1,s1
    431e:	00003517          	auipc	a0,0x3
    4322:	ef250513          	addi	a0,a0,-270 # 7210 <malloc+0x1f62>
    4326:	6d5000ef          	jal	51fa <printf>
    exit(1);
    432a:	4505                	li	a0,1
    432c:	287000ef          	jal	4db2 <exit>
    exit(xstatus);
    4330:	283000ef          	jal	4db2 <exit>
    printf("%s: bigarg test failed!\n", s);
    4334:	85a6                	mv	a1,s1
    4336:	00003517          	auipc	a0,0x3
    433a:	efa50513          	addi	a0,a0,-262 # 7230 <malloc+0x1f82>
    433e:	6bd000ef          	jal	51fa <printf>
    exit(1);
    4342:	4505                	li	a0,1
    4344:	26f000ef          	jal	4db2 <exit>

0000000000004348 <lazy_alloc>:
{
    4348:	1141                	addi	sp,sp,-16
    434a:	e406                	sd	ra,8(sp)
    434c:	e022                	sd	s0,0(sp)
    434e:	0800                	addi	s0,sp,16
  prev_end = sbrklazy(REGION_SZ);
    4350:	40000537          	lui	a0,0x40000
    4354:	203000ef          	jal	4d56 <sbrklazy>
  if (prev_end == (char *) SBRK_ERROR) {
    4358:	57fd                	li	a5,-1
    435a:	02f50a63          	beq	a0,a5,438e <lazy_alloc+0x46>
  for (i = prev_end + PGSIZE; i < new_end; i += 64 * PGSIZE)
    435e:	6605                	lui	a2,0x1
    4360:	962a                	add	a2,a2,a0
    4362:	400017b7          	lui	a5,0x40001
    4366:	00f50733          	add	a4,a0,a5
    436a:	87b2                	mv	a5,a2
    436c:	000406b7          	lui	a3,0x40
    *(char **)i = i;
    4370:	e39c                	sd	a5,0(a5)
  for (i = prev_end + PGSIZE; i < new_end; i += 64 * PGSIZE)
    4372:	97b6                	add	a5,a5,a3
    4374:	fee79ee3          	bne	a5,a4,4370 <lazy_alloc+0x28>
  for (i = prev_end + PGSIZE; i < new_end; i += 64 * PGSIZE) {
    4378:	000406b7          	lui	a3,0x40
    if (*(char **)i != i) {
    437c:	621c                	ld	a5,0(a2)
    437e:	02c79163          	bne	a5,a2,43a0 <lazy_alloc+0x58>
  for (i = prev_end + PGSIZE; i < new_end; i += 64 * PGSIZE) {
    4382:	9636                	add	a2,a2,a3
    4384:	fee61ce3          	bne	a2,a4,437c <lazy_alloc+0x34>
  exit(0);
    4388:	4501                	li	a0,0
    438a:	229000ef          	jal	4db2 <exit>
    printf("sbrklazy() failed\n");
    438e:	00003517          	auipc	a0,0x3
    4392:	ec250513          	addi	a0,a0,-318 # 7250 <malloc+0x1fa2>
    4396:	665000ef          	jal	51fa <printf>
    exit(1);
    439a:	4505                	li	a0,1
    439c:	217000ef          	jal	4db2 <exit>
      printf("failed to read value from memory\n");
    43a0:	00003517          	auipc	a0,0x3
    43a4:	ec850513          	addi	a0,a0,-312 # 7268 <malloc+0x1fba>
    43a8:	653000ef          	jal	51fa <printf>
      exit(1);
    43ac:	4505                	li	a0,1
    43ae:	205000ef          	jal	4db2 <exit>

00000000000043b2 <lazy_unmap>:
{
    43b2:	7139                	addi	sp,sp,-64
    43b4:	fc06                	sd	ra,56(sp)
    43b6:	f822                	sd	s0,48(sp)
    43b8:	0080                	addi	s0,sp,64
  prev_end = sbrklazy(REGION_SZ);
    43ba:	40000537          	lui	a0,0x40000
    43be:	199000ef          	jal	4d56 <sbrklazy>
  if (prev_end == (char*)SBRK_ERROR) {
    43c2:	57fd                	li	a5,-1
    43c4:	04f50663          	beq	a0,a5,4410 <lazy_unmap+0x5e>
    43c8:	f426                	sd	s1,40(sp)
    43ca:	f04a                	sd	s2,32(sp)
    43cc:	ec4e                	sd	s3,24(sp)
  for (i = prev_end + PGSIZE; i < new_end; i += PGSIZE * PGSIZE)
    43ce:	6905                	lui	s2,0x1
    43d0:	992a                	add	s2,s2,a0
    43d2:	400017b7          	lui	a5,0x40001
    43d6:	00f504b3          	add	s1,a0,a5
    43da:	87ca                	mv	a5,s2
    43dc:	01000737          	lui	a4,0x1000
    *(char **)i = i;
    43e0:	e39c                	sd	a5,0(a5)
  for (i = prev_end + PGSIZE; i < new_end; i += PGSIZE * PGSIZE)
    43e2:	97ba                	add	a5,a5,a4
    43e4:	fe979ee3          	bne	a5,s1,43e0 <lazy_unmap+0x2e>
  for (i = prev_end + PGSIZE; i < new_end; i += PGSIZE * PGSIZE) {
    43e8:	010009b7          	lui	s3,0x1000
    pid = fork();
    43ec:	1bf000ef          	jal	4daa <fork>
    if (pid < 0) {
    43f0:	02054c63          	bltz	a0,4428 <lazy_unmap+0x76>
    } else if (pid == 0) {
    43f4:	c139                	beqz	a0,443a <lazy_unmap+0x88>
      wait(&status);
    43f6:	fcc40513          	addi	a0,s0,-52
    43fa:	1c1000ef          	jal	4dba <wait>
      if (status == 0) {
    43fe:	fcc42783          	lw	a5,-52(s0)
    4402:	c7a9                	beqz	a5,444c <lazy_unmap+0x9a>
  for (i = prev_end + PGSIZE; i < new_end; i += PGSIZE * PGSIZE) {
    4404:	994e                	add	s2,s2,s3
    4406:	fe9913e3          	bne	s2,s1,43ec <lazy_unmap+0x3a>
  exit(0);
    440a:	4501                	li	a0,0
    440c:	1a7000ef          	jal	4db2 <exit>
    4410:	f426                	sd	s1,40(sp)
    4412:	f04a                	sd	s2,32(sp)
    4414:	ec4e                	sd	s3,24(sp)
    printf("sbrklazy() failed\n");
    4416:	00003517          	auipc	a0,0x3
    441a:	e3a50513          	addi	a0,a0,-454 # 7250 <malloc+0x1fa2>
    441e:	5dd000ef          	jal	51fa <printf>
    exit(1);
    4422:	4505                	li	a0,1
    4424:	18f000ef          	jal	4db2 <exit>
      printf("error forking\n");
    4428:	00003517          	auipc	a0,0x3
    442c:	e6850513          	addi	a0,a0,-408 # 7290 <malloc+0x1fe2>
    4430:	5cb000ef          	jal	51fa <printf>
      exit(1);
    4434:	4505                	li	a0,1
    4436:	17d000ef          	jal	4db2 <exit>
      sbrklazy(-1L * REGION_SZ);
    443a:	c0000537          	lui	a0,0xc0000
    443e:	119000ef          	jal	4d56 <sbrklazy>
      *(char **)i = i;
    4442:	01293023          	sd	s2,0(s2) # 1000 <badarg>
      exit(0);
    4446:	4501                	li	a0,0
    4448:	16b000ef          	jal	4db2 <exit>
        printf("memory not unmapped\n");
    444c:	00003517          	auipc	a0,0x3
    4450:	e5450513          	addi	a0,a0,-428 # 72a0 <malloc+0x1ff2>
    4454:	5a7000ef          	jal	51fa <printf>
        exit(1);
    4458:	4505                	li	a0,1
    445a:	159000ef          	jal	4db2 <exit>

000000000000445e <lazy_copy>:
{
    445e:	7159                	addi	sp,sp,-112
    4460:	f486                	sd	ra,104(sp)
    4462:	f0a2                	sd	s0,96(sp)
    4464:	eca6                	sd	s1,88(sp)
    4466:	e8ca                	sd	s2,80(sp)
    4468:	e4ce                	sd	s3,72(sp)
    446a:	e0d2                	sd	s4,64(sp)
    446c:	fc56                	sd	s5,56(sp)
    446e:	f85a                	sd	s6,48(sp)
    4470:	1880                	addi	s0,sp,112
    char *p = sbrk(0);
    4472:	4501                	li	a0,0
    4474:	0cd000ef          	jal	4d40 <sbrk>
    4478:	84aa                	mv	s1,a0
    sbrklazy(4*PGSIZE);
    447a:	6511                	lui	a0,0x4
    447c:	0db000ef          	jal	4d56 <sbrklazy>
    open(p + 8192, 0);
    4480:	4581                	li	a1,0
    4482:	6509                	lui	a0,0x2
    4484:	9526                	add	a0,a0,s1
    4486:	16d000ef          	jal	4df2 <open>
    void *xx = sbrk(0);
    448a:	4501                	li	a0,0
    448c:	0b5000ef          	jal	4d40 <sbrk>
    4490:	84aa                	mv	s1,a0
    void *ret = sbrk(-(((uint64) xx)+1));
    4492:	fff54513          	not	a0,a0
    4496:	2501                	sext.w	a0,a0
    4498:	0a9000ef          	jal	4d40 <sbrk>
    if(ret != xx){
    449c:	00a48c63          	beq	s1,a0,44b4 <lazy_copy+0x56>
    44a0:	85aa                	mv	a1,a0
      printf("sbrk(sbrk(0)+1) returned %p, not old sz\n", ret);
    44a2:	00003517          	auipc	a0,0x3
    44a6:	e1650513          	addi	a0,a0,-490 # 72b8 <malloc+0x200a>
    44aa:	551000ef          	jal	51fa <printf>
      exit(1);
    44ae:	4505                	li	a0,1
    44b0:	103000ef          	jal	4db2 <exit>
  unsigned long bad[] = {
    44b4:	00003797          	auipc	a5,0x3
    44b8:	47c78793          	addi	a5,a5,1148 # 7930 <malloc+0x2682>
    44bc:	7fa8                	ld	a0,120(a5)
    44be:	63cc                	ld	a1,128(a5)
    44c0:	67d0                	ld	a2,136(a5)
    44c2:	6bd4                	ld	a3,144(a5)
    44c4:	6fd8                	ld	a4,152(a5)
    44c6:	73dc                	ld	a5,160(a5)
    44c8:	f8a43823          	sd	a0,-112(s0)
    44cc:	f8b43c23          	sd	a1,-104(s0)
    44d0:	fac43023          	sd	a2,-96(s0)
    44d4:	fad43423          	sd	a3,-88(s0)
    44d8:	fae43823          	sd	a4,-80(s0)
    44dc:	faf43c23          	sd	a5,-72(s0)
  for(int i = 0; i < sizeof(bad)/sizeof(bad[0]); i++){
    44e0:	f9040913          	addi	s2,s0,-112
    44e4:	fc040b13          	addi	s6,s0,-64
    int fd = open("README", 0);
    44e8:	00001a17          	auipc	s4,0x1
    44ec:	0d8a0a13          	addi	s4,s4,216 # 55c0 <malloc+0x312>
    fd = open("junk", O_CREATE|O_RDWR|O_TRUNC);
    44f0:	00001a97          	auipc	s5,0x1
    44f4:	fe0a8a93          	addi	s5,s5,-32 # 54d0 <malloc+0x222>
    int fd = open("README", 0);
    44f8:	4581                	li	a1,0
    44fa:	8552                	mv	a0,s4
    44fc:	0f7000ef          	jal	4df2 <open>
    4500:	84aa                	mv	s1,a0
    if(fd < 0) { printf("cannot open README\n"); exit(1); }
    4502:	04054663          	bltz	a0,454e <lazy_copy+0xf0>
    if(read(fd, (char*)bad[i], 512) >= 0) { printf("read succeeded\n");  exit(1); }
    4506:	00093983          	ld	s3,0(s2)
    450a:	20000613          	li	a2,512
    450e:	85ce                	mv	a1,s3
    4510:	0bb000ef          	jal	4dca <read>
    4514:	04055663          	bgez	a0,4560 <lazy_copy+0x102>
    close(fd);
    4518:	8526                	mv	a0,s1
    451a:	0c1000ef          	jal	4dda <close>
    fd = open("junk", O_CREATE|O_RDWR|O_TRUNC);
    451e:	60200593          	li	a1,1538
    4522:	8556                	mv	a0,s5
    4524:	0cf000ef          	jal	4df2 <open>
    4528:	84aa                	mv	s1,a0
    if(fd < 0) { printf("cannot open junk\n"); exit(1); }
    452a:	04054463          	bltz	a0,4572 <lazy_copy+0x114>
    if(write(fd, (char*)bad[i], 512) >= 0) { printf("write succeeded\n"); exit(1); }
    452e:	20000613          	li	a2,512
    4532:	85ce                	mv	a1,s3
    4534:	09f000ef          	jal	4dd2 <write>
    4538:	04055663          	bgez	a0,4584 <lazy_copy+0x126>
    close(fd);
    453c:	8526                	mv	a0,s1
    453e:	09d000ef          	jal	4dda <close>
  for(int i = 0; i < sizeof(bad)/sizeof(bad[0]); i++){
    4542:	0921                	addi	s2,s2,8
    4544:	fb691ae3          	bne	s2,s6,44f8 <lazy_copy+0x9a>
  exit(0);
    4548:	4501                	li	a0,0
    454a:	069000ef          	jal	4db2 <exit>
    if(fd < 0) { printf("cannot open README\n"); exit(1); }
    454e:	00003517          	auipc	a0,0x3
    4552:	d9a50513          	addi	a0,a0,-614 # 72e8 <malloc+0x203a>
    4556:	4a5000ef          	jal	51fa <printf>
    455a:	4505                	li	a0,1
    455c:	057000ef          	jal	4db2 <exit>
    if(read(fd, (char*)bad[i], 512) >= 0) { printf("read succeeded\n");  exit(1); }
    4560:	00003517          	auipc	a0,0x3
    4564:	da050513          	addi	a0,a0,-608 # 7300 <malloc+0x2052>
    4568:	493000ef          	jal	51fa <printf>
    456c:	4505                	li	a0,1
    456e:	045000ef          	jal	4db2 <exit>
    if(fd < 0) { printf("cannot open junk\n"); exit(1); }
    4572:	00003517          	auipc	a0,0x3
    4576:	d9e50513          	addi	a0,a0,-610 # 7310 <malloc+0x2062>
    457a:	481000ef          	jal	51fa <printf>
    457e:	4505                	li	a0,1
    4580:	033000ef          	jal	4db2 <exit>
    if(write(fd, (char*)bad[i], 512) >= 0) { printf("write succeeded\n"); exit(1); }
    4584:	00003517          	auipc	a0,0x3
    4588:	da450513          	addi	a0,a0,-604 # 7328 <malloc+0x207a>
    458c:	46f000ef          	jal	51fa <printf>
    4590:	4505                	li	a0,1
    4592:	021000ef          	jal	4db2 <exit>

0000000000004596 <lazy_sbrk>:
{
    4596:	1101                	addi	sp,sp,-32
    4598:	ec06                	sd	ra,24(sp)
    459a:	e822                	sd	s0,16(sp)
    459c:	e426                	sd	s1,8(sp)
    459e:	e04a                	sd	s2,0(sp)
    45a0:	1000                	addi	s0,sp,32
  char *p = sbrk(0);
    45a2:	4501                	li	a0,0
    45a4:	79c000ef          	jal	4d40 <sbrk>
    45a8:	84aa                	mv	s1,a0
  while ((uint64)p < MAXVA-(1<<30)) {
    45aa:	0ff00793          	li	a5,255
    45ae:	07fa                	slli	a5,a5,0x1e
    45b0:	00f57d63          	bgeu	a0,a5,45ca <lazy_sbrk+0x34>
    45b4:	893e                	mv	s2,a5
    p = sbrklazy(1<<30);
    45b6:	40000537          	lui	a0,0x40000
    45ba:	79c000ef          	jal	4d56 <sbrklazy>
    p = sbrklazy(0);
    45be:	4501                	li	a0,0
    45c0:	796000ef          	jal	4d56 <sbrklazy>
    45c4:	84aa                	mv	s1,a0
  while ((uint64)p < MAXVA-(1<<30)) {
    45c6:	ff2568e3          	bltu	a0,s2,45b6 <lazy_sbrk+0x20>
  int n = TRAPFRAME-PGSIZE-(uint64)p;
    45ca:	7975                	lui	s2,0xffffd
    45cc:	4099093b          	subw	s2,s2,s1
  char *p1 = sbrklazy(n);
    45d0:	854a                	mv	a0,s2
    45d2:	784000ef          	jal	4d56 <sbrklazy>
    45d6:	862a                	mv	a2,a0
  if (p1 < 0 || p1 != p) {
    45d8:	00950d63          	beq	a0,s1,45f2 <lazy_sbrk+0x5c>
    printf("sbrklazy(%d) returned %p, not expected %p\n", n, p1, p);
    45dc:	86a6                	mv	a3,s1
    45de:	85ca                	mv	a1,s2
    45e0:	00003517          	auipc	a0,0x3
    45e4:	d6050513          	addi	a0,a0,-672 # 7340 <malloc+0x2092>
    45e8:	413000ef          	jal	51fa <printf>
    exit(1);
    45ec:	4505                	li	a0,1
    45ee:	7c4000ef          	jal	4db2 <exit>
  p = sbrk(PGSIZE);
    45f2:	6505                	lui	a0,0x1
    45f4:	74c000ef          	jal	4d40 <sbrk>
    45f8:	862a                	mv	a2,a0
  if (p < 0 || (uint64)p != TRAPFRAME-PGSIZE) {
    45fa:	040007b7          	lui	a5,0x4000
    45fe:	17f5                	addi	a5,a5,-3 # 3fffffd <base+0x3ff1345>
    4600:	07b2                	slli	a5,a5,0xc
    4602:	00f50c63          	beq	a0,a5,461a <lazy_sbrk+0x84>
    printf("sbrk(%d) returned %p, not expected TRAPFRAME-PGSIZE\n", PGSIZE, p);
    4606:	6585                	lui	a1,0x1
    4608:	00003517          	auipc	a0,0x3
    460c:	d6850513          	addi	a0,a0,-664 # 7370 <malloc+0x20c2>
    4610:	3eb000ef          	jal	51fa <printf>
    exit(1);
    4614:	4505                	li	a0,1
    4616:	79c000ef          	jal	4db2 <exit>
  p[0] = 1;
    461a:	040007b7          	lui	a5,0x4000
    461e:	17f5                	addi	a5,a5,-3 # 3fffffd <base+0x3ff1345>
    4620:	07b2                	slli	a5,a5,0xc
    4622:	4705                	li	a4,1
    4624:	00e78023          	sb	a4,0(a5)
  if (p[1] != 0) {
    4628:	0017c783          	lbu	a5,1(a5)
    462c:	cb91                	beqz	a5,4640 <lazy_sbrk+0xaa>
    printf("sbrk() returned non-zero-filled memory\n");
    462e:	00003517          	auipc	a0,0x3
    4632:	d7a50513          	addi	a0,a0,-646 # 73a8 <malloc+0x20fa>
    4636:	3c5000ef          	jal	51fa <printf>
    exit(1);
    463a:	4505                	li	a0,1
    463c:	776000ef          	jal	4db2 <exit>
  p = sbrk(1);
    4640:	4505                	li	a0,1
    4642:	6fe000ef          	jal	4d40 <sbrk>
    4646:	85aa                	mv	a1,a0
  if ((uint64)p != -1) {
    4648:	57fd                	li	a5,-1
    464a:	00f50b63          	beq	a0,a5,4660 <lazy_sbrk+0xca>
    printf("sbrk(1) returned %p, expected error\n", p);
    464e:	00003517          	auipc	a0,0x3
    4652:	d8250513          	addi	a0,a0,-638 # 73d0 <malloc+0x2122>
    4656:	3a5000ef          	jal	51fa <printf>
    exit(1);
    465a:	4505                	li	a0,1
    465c:	756000ef          	jal	4db2 <exit>
  p = sbrklazy(1);
    4660:	4505                	li	a0,1
    4662:	6f4000ef          	jal	4d56 <sbrklazy>
    4666:	85aa                	mv	a1,a0
  if ((uint64)p != -1) {
    4668:	57fd                	li	a5,-1
    466a:	00f50b63          	beq	a0,a5,4680 <lazy_sbrk+0xea>
    printf("sbrklazy(1) returned %p, expected error\n", p);
    466e:	00003517          	auipc	a0,0x3
    4672:	d8a50513          	addi	a0,a0,-630 # 73f8 <malloc+0x214a>
    4676:	385000ef          	jal	51fa <printf>
    exit(1);
    467a:	4505                	li	a0,1
    467c:	736000ef          	jal	4db2 <exit>
  exit(0);
    4680:	4501                	li	a0,0
    4682:	730000ef          	jal	4db2 <exit>

0000000000004686 <fsfull>:
{
    4686:	7135                	addi	sp,sp,-160
    4688:	ed06                	sd	ra,152(sp)
    468a:	e922                	sd	s0,144(sp)
    468c:	e526                	sd	s1,136(sp)
    468e:	e14a                	sd	s2,128(sp)
    4690:	fcce                	sd	s3,120(sp)
    4692:	f8d2                	sd	s4,112(sp)
    4694:	f4d6                	sd	s5,104(sp)
    4696:	f0da                	sd	s6,96(sp)
    4698:	ecde                	sd	s7,88(sp)
    469a:	e8e2                	sd	s8,80(sp)
    469c:	e4e6                	sd	s9,72(sp)
    469e:	e0ea                	sd	s10,64(sp)
    46a0:	1100                	addi	s0,sp,160
  printf("fsfull test\n");
    46a2:	00003517          	auipc	a0,0x3
    46a6:	d8650513          	addi	a0,a0,-634 # 7428 <malloc+0x217a>
    46aa:	351000ef          	jal	51fa <printf>
  for(nfiles = 0; ; nfiles++){
    46ae:	4481                	li	s1,0
    name[0] = 'f';
    46b0:	06600d13          	li	s10,102
    name[1] = '0' + nfiles / 1000;
    46b4:	3e800c13          	li	s8,1000
    name[2] = '0' + (nfiles % 1000) / 100;
    46b8:	06400b93          	li	s7,100
    name[3] = '0' + (nfiles % 100) / 10;
    46bc:	4b29                	li	s6,10
    printf("writing %s\n", name);
    46be:	00003c97          	auipc	s9,0x3
    46c2:	d7ac8c93          	addi	s9,s9,-646 # 7438 <malloc+0x218a>
    name[0] = 'f';
    46c6:	f7a40023          	sb	s10,-160(s0)
    name[1] = '0' + nfiles / 1000;
    46ca:	0384c7bb          	divw	a5,s1,s8
    46ce:	0307879b          	addiw	a5,a5,48
    46d2:	f6f400a3          	sb	a5,-159(s0)
    name[2] = '0' + (nfiles % 1000) / 100;
    46d6:	0384e7bb          	remw	a5,s1,s8
    46da:	0377c7bb          	divw	a5,a5,s7
    46de:	0307879b          	addiw	a5,a5,48
    46e2:	f6f40123          	sb	a5,-158(s0)
    name[3] = '0' + (nfiles % 100) / 10;
    46e6:	0374e7bb          	remw	a5,s1,s7
    46ea:	0367c7bb          	divw	a5,a5,s6
    46ee:	0307879b          	addiw	a5,a5,48
    46f2:	f6f401a3          	sb	a5,-157(s0)
    name[4] = '0' + (nfiles % 10);
    46f6:	0364e7bb          	remw	a5,s1,s6
    46fa:	0307879b          	addiw	a5,a5,48
    46fe:	f6f40223          	sb	a5,-156(s0)
    name[5] = '\0';
    4702:	f60402a3          	sb	zero,-155(s0)
    printf("writing %s\n", name);
    4706:	f6040593          	addi	a1,s0,-160
    470a:	8566                	mv	a0,s9
    470c:	2ef000ef          	jal	51fa <printf>
    int fd = open(name, O_CREATE|O_RDWR);
    4710:	20200593          	li	a1,514
    4714:	f6040513          	addi	a0,s0,-160
    4718:	6da000ef          	jal	4df2 <open>
    471c:	892a                	mv	s2,a0
    if(fd < 0){
    471e:	08055f63          	bgez	a0,47bc <fsfull+0x136>
      printf("open %s failed\n", name);
    4722:	f6040593          	addi	a1,s0,-160
    4726:	00003517          	auipc	a0,0x3
    472a:	d2250513          	addi	a0,a0,-734 # 7448 <malloc+0x219a>
    472e:	2cd000ef          	jal	51fa <printf>
  while(nfiles >= 0){
    4732:	0604c163          	bltz	s1,4794 <fsfull+0x10e>
    name[0] = 'f';
    4736:	06600b13          	li	s6,102
    name[1] = '0' + nfiles / 1000;
    473a:	3e800a13          	li	s4,1000
    name[2] = '0' + (nfiles % 1000) / 100;
    473e:	06400993          	li	s3,100
    name[3] = '0' + (nfiles % 100) / 10;
    4742:	4929                	li	s2,10
  while(nfiles >= 0){
    4744:	5afd                	li	s5,-1
    name[0] = 'f';
    4746:	f7640023          	sb	s6,-160(s0)
    name[1] = '0' + nfiles / 1000;
    474a:	0344c7bb          	divw	a5,s1,s4
    474e:	0307879b          	addiw	a5,a5,48
    4752:	f6f400a3          	sb	a5,-159(s0)
    name[2] = '0' + (nfiles % 1000) / 100;
    4756:	0344e7bb          	remw	a5,s1,s4
    475a:	0337c7bb          	divw	a5,a5,s3
    475e:	0307879b          	addiw	a5,a5,48
    4762:	f6f40123          	sb	a5,-158(s0)
    name[3] = '0' + (nfiles % 100) / 10;
    4766:	0334e7bb          	remw	a5,s1,s3
    476a:	0327c7bb          	divw	a5,a5,s2
    476e:	0307879b          	addiw	a5,a5,48
    4772:	f6f401a3          	sb	a5,-157(s0)
    name[4] = '0' + (nfiles % 10);
    4776:	0324e7bb          	remw	a5,s1,s2
    477a:	0307879b          	addiw	a5,a5,48
    477e:	f6f40223          	sb	a5,-156(s0)
    name[5] = '\0';
    4782:	f60402a3          	sb	zero,-155(s0)
    unlink(name);
    4786:	f6040513          	addi	a0,s0,-160
    478a:	678000ef          	jal	4e02 <unlink>
    nfiles--;
    478e:	34fd                	addiw	s1,s1,-1
  while(nfiles >= 0){
    4790:	fb549be3          	bne	s1,s5,4746 <fsfull+0xc0>
  printf("fsfull test finished\n");
    4794:	00003517          	auipc	a0,0x3
    4798:	cd450513          	addi	a0,a0,-812 # 7468 <malloc+0x21ba>
    479c:	25f000ef          	jal	51fa <printf>
}
    47a0:	60ea                	ld	ra,152(sp)
    47a2:	644a                	ld	s0,144(sp)
    47a4:	64aa                	ld	s1,136(sp)
    47a6:	690a                	ld	s2,128(sp)
    47a8:	79e6                	ld	s3,120(sp)
    47aa:	7a46                	ld	s4,112(sp)
    47ac:	7aa6                	ld	s5,104(sp)
    47ae:	7b06                	ld	s6,96(sp)
    47b0:	6be6                	ld	s7,88(sp)
    47b2:	6c46                	ld	s8,80(sp)
    47b4:	6ca6                	ld	s9,72(sp)
    47b6:	6d06                	ld	s10,64(sp)
    47b8:	610d                	addi	sp,sp,160
    47ba:	8082                	ret
    int total = 0;
    47bc:	4981                	li	s3,0
      int cc = write(fd, buf, BSIZE);
    47be:	00007a97          	auipc	s5,0x7
    47c2:	4faa8a93          	addi	s5,s5,1274 # bcb8 <buf>
      if(cc < BSIZE)
    47c6:	3ff00a13          	li	s4,1023
      int cc = write(fd, buf, BSIZE);
    47ca:	40000613          	li	a2,1024
    47ce:	85d6                	mv	a1,s5
    47d0:	854a                	mv	a0,s2
    47d2:	600000ef          	jal	4dd2 <write>
      if(cc < BSIZE)
    47d6:	00aa5563          	bge	s4,a0,47e0 <fsfull+0x15a>
      total += cc;
    47da:	00a989bb          	addw	s3,s3,a0
    while(1){
    47de:	b7f5                	j	47ca <fsfull+0x144>
    printf("wrote %d bytes\n", total);
    47e0:	85ce                	mv	a1,s3
    47e2:	00003517          	auipc	a0,0x3
    47e6:	c7650513          	addi	a0,a0,-906 # 7458 <malloc+0x21aa>
    47ea:	211000ef          	jal	51fa <printf>
    close(fd);
    47ee:	854a                	mv	a0,s2
    47f0:	5ea000ef          	jal	4dda <close>
    if(total == 0)
    47f4:	f2098fe3          	beqz	s3,4732 <fsfull+0xac>
  for(nfiles = 0; ; nfiles++){
    47f8:	2485                	addiw	s1,s1,1
    47fa:	b5f1                	j	46c6 <fsfull+0x40>

00000000000047fc <run>:
//

// run each test in its own process. run returns 1 if child's exit()
// indicates success.
int
run(void f(char *), char *s) {
    47fc:	7179                	addi	sp,sp,-48
    47fe:	f406                	sd	ra,40(sp)
    4800:	f022                	sd	s0,32(sp)
    4802:	ec26                	sd	s1,24(sp)
    4804:	e84a                	sd	s2,16(sp)
    4806:	1800                	addi	s0,sp,48
    4808:	84aa                	mv	s1,a0
    480a:	892e                	mv	s2,a1
  int pid;
  int xstatus;

  printf("test %s: ", s);
    480c:	00003517          	auipc	a0,0x3
    4810:	c7450513          	addi	a0,a0,-908 # 7480 <malloc+0x21d2>
    4814:	1e7000ef          	jal	51fa <printf>
  if((pid = fork()) < 0) {
    4818:	592000ef          	jal	4daa <fork>
    481c:	02054a63          	bltz	a0,4850 <run+0x54>
    printf("runtest: fork error\n");
    exit(1);
  }
  if(pid == 0) {
    4820:	c129                	beqz	a0,4862 <run+0x66>
    f(s);
    exit(0);
  } else {
    wait(&xstatus);
    4822:	fdc40513          	addi	a0,s0,-36
    4826:	594000ef          	jal	4dba <wait>
    if(xstatus != 0) 
    482a:	fdc42783          	lw	a5,-36(s0)
    482e:	cf9d                	beqz	a5,486c <run+0x70>
      printf("FAILED\n");
    4830:	00003517          	auipc	a0,0x3
    4834:	c7850513          	addi	a0,a0,-904 # 74a8 <malloc+0x21fa>
    4838:	1c3000ef          	jal	51fa <printf>
    else
      printf("OK\n");
    return xstatus == 0;
    483c:	fdc42503          	lw	a0,-36(s0)
  }
}
    4840:	00153513          	seqz	a0,a0
    4844:	70a2                	ld	ra,40(sp)
    4846:	7402                	ld	s0,32(sp)
    4848:	64e2                	ld	s1,24(sp)
    484a:	6942                	ld	s2,16(sp)
    484c:	6145                	addi	sp,sp,48
    484e:	8082                	ret
    printf("runtest: fork error\n");
    4850:	00003517          	auipc	a0,0x3
    4854:	c4050513          	addi	a0,a0,-960 # 7490 <malloc+0x21e2>
    4858:	1a3000ef          	jal	51fa <printf>
    exit(1);
    485c:	4505                	li	a0,1
    485e:	554000ef          	jal	4db2 <exit>
    f(s);
    4862:	854a                	mv	a0,s2
    4864:	9482                	jalr	s1
    exit(0);
    4866:	4501                	li	a0,0
    4868:	54a000ef          	jal	4db2 <exit>
      printf("OK\n");
    486c:	00003517          	auipc	a0,0x3
    4870:	c4450513          	addi	a0,a0,-956 # 74b0 <malloc+0x2202>
    4874:	187000ef          	jal	51fa <printf>
    4878:	b7d1                	j	483c <run+0x40>

000000000000487a <runtests>:

int
runtests(struct test *tests, char *justone, int continuous) {
    487a:	7139                	addi	sp,sp,-64
    487c:	fc06                	sd	ra,56(sp)
    487e:	f822                	sd	s0,48(sp)
    4880:	f426                	sd	s1,40(sp)
    4882:	ec4e                	sd	s3,24(sp)
    4884:	0080                	addi	s0,sp,64
    4886:	84aa                	mv	s1,a0
  int ntests = 0;
  for (struct test *t = tests; t->s != 0; t++) {
    4888:	6508                	ld	a0,8(a0)
    488a:	cd39                	beqz	a0,48e8 <runtests+0x6e>
    488c:	f04a                	sd	s2,32(sp)
    488e:	e852                	sd	s4,16(sp)
    4890:	e456                	sd	s5,8(sp)
    4892:	892e                	mv	s2,a1
    4894:	8a32                	mv	s4,a2
  int ntests = 0;
    4896:	4981                	li	s3,0
    if((justone == 0) || strcmp(t->s, justone) == 0) {
      ntests++;
      if(!run(t->f, t->s)){
        if(continuous != 2){
    4898:	4a89                	li	s5,2
    489a:	a021                	j	48a2 <runtests+0x28>
  for (struct test *t = tests; t->s != 0; t++) {
    489c:	04c1                	addi	s1,s1,16
    489e:	6488                	ld	a0,8(s1)
    48a0:	c915                	beqz	a0,48d4 <runtests+0x5a>
    if((justone == 0) || strcmp(t->s, justone) == 0) {
    48a2:	00090663          	beqz	s2,48ae <runtests+0x34>
    48a6:	85ca                	mv	a1,s2
    48a8:	264000ef          	jal	4b0c <strcmp>
    48ac:	f965                	bnez	a0,489c <runtests+0x22>
      ntests++;
    48ae:	2985                	addiw	s3,s3,1 # 1000001 <base+0xff1349>
      if(!run(t->f, t->s)){
    48b0:	648c                	ld	a1,8(s1)
    48b2:	6088                	ld	a0,0(s1)
    48b4:	f49ff0ef          	jal	47fc <run>
    48b8:	f175                	bnez	a0,489c <runtests+0x22>
        if(continuous != 2){
    48ba:	ff5a01e3          	beq	s4,s5,489c <runtests+0x22>
          printf("SOME TESTS FAILED\n");
    48be:	00003517          	auipc	a0,0x3
    48c2:	bfa50513          	addi	a0,a0,-1030 # 74b8 <malloc+0x220a>
    48c6:	135000ef          	jal	51fa <printf>
          return -1;
    48ca:	59fd                	li	s3,-1
    48cc:	7902                	ld	s2,32(sp)
    48ce:	6a42                	ld	s4,16(sp)
    48d0:	6aa2                	ld	s5,8(sp)
    48d2:	a021                	j	48da <runtests+0x60>
    48d4:	7902                	ld	s2,32(sp)
    48d6:	6a42                	ld	s4,16(sp)
    48d8:	6aa2                	ld	s5,8(sp)
        }
      }
    }
  }
  return ntests;
}
    48da:	854e                	mv	a0,s3
    48dc:	70e2                	ld	ra,56(sp)
    48de:	7442                	ld	s0,48(sp)
    48e0:	74a2                	ld	s1,40(sp)
    48e2:	69e2                	ld	s3,24(sp)
    48e4:	6121                	addi	sp,sp,64
    48e6:	8082                	ret
  return ntests;
    48e8:	4981                	li	s3,0
    48ea:	bfc5                	j	48da <runtests+0x60>

00000000000048ec <countfree>:


// use sbrk() to count how many free physical memory pages there are.
int
countfree()
{
    48ec:	7179                	addi	sp,sp,-48
    48ee:	f406                	sd	ra,40(sp)
    48f0:	f022                	sd	s0,32(sp)
    48f2:	ec26                	sd	s1,24(sp)
    48f4:	e84a                	sd	s2,16(sp)
    48f6:	e44e                	sd	s3,8(sp)
    48f8:	1800                	addi	s0,sp,48
  int n = 0;
  uint64 sz0 = (uint64)sbrk(0);
    48fa:	4501                	li	a0,0
    48fc:	444000ef          	jal	4d40 <sbrk>
    4900:	89aa                	mv	s3,a0
  int n = 0;
    4902:	4481                	li	s1,0
  while(1){
    char *a = sbrk(PGSIZE);
    if(a == SBRK_ERROR){
    4904:	597d                	li	s2,-1
    4906:	a011                	j	490a <countfree+0x1e>
      break;
    }
    n += 1;
    4908:	2485                	addiw	s1,s1,1
    char *a = sbrk(PGSIZE);
    490a:	6505                	lui	a0,0x1
    490c:	434000ef          	jal	4d40 <sbrk>
    if(a == SBRK_ERROR){
    4910:	ff251ce3          	bne	a0,s2,4908 <countfree+0x1c>
  }
  sbrk(-((uint64)sbrk(0) - sz0));  
    4914:	4501                	li	a0,0
    4916:	42a000ef          	jal	4d40 <sbrk>
    491a:	40a9853b          	subw	a0,s3,a0
    491e:	422000ef          	jal	4d40 <sbrk>
  return n;
}
    4922:	8526                	mv	a0,s1
    4924:	70a2                	ld	ra,40(sp)
    4926:	7402                	ld	s0,32(sp)
    4928:	64e2                	ld	s1,24(sp)
    492a:	6942                	ld	s2,16(sp)
    492c:	69a2                	ld	s3,8(sp)
    492e:	6145                	addi	sp,sp,48
    4930:	8082                	ret

0000000000004932 <drivetests>:

int
drivetests(int quick, int continuous, char *justone) {
    4932:	7159                	addi	sp,sp,-112
    4934:	f486                	sd	ra,104(sp)
    4936:	f0a2                	sd	s0,96(sp)
    4938:	eca6                	sd	s1,88(sp)
    493a:	e8ca                	sd	s2,80(sp)
    493c:	e4ce                	sd	s3,72(sp)
    493e:	e0d2                	sd	s4,64(sp)
    4940:	fc56                	sd	s5,56(sp)
    4942:	f85a                	sd	s6,48(sp)
    4944:	f45e                	sd	s7,40(sp)
    4946:	f062                	sd	s8,32(sp)
    4948:	ec66                	sd	s9,24(sp)
    494a:	e86a                	sd	s10,16(sp)
    494c:	e46e                	sd	s11,8(sp)
    494e:	1880                	addi	s0,sp,112
    4950:	8aaa                	mv	s5,a0
    4952:	89ae                	mv	s3,a1
    4954:	8a32                	mv	s4,a2
  do {
    printf("usertests starting\n");
    4956:	00003c17          	auipc	s8,0x3
    495a:	b7ac0c13          	addi	s8,s8,-1158 # 74d0 <malloc+0x2222>
    int free0 = countfree();
    int free1 = 0;
    int ntests = 0;
    int n;
    n = runtests(quicktests, justone, continuous);
    495e:	00003b97          	auipc	s7,0x3
    4962:	6b2b8b93          	addi	s7,s7,1714 # 8010 <quicktests>
    if (n < 0) {
      if(continuous != 2) {
    4966:	4b09                	li	s6,2
      ntests += n;
    }
    if(!quick) {
      if (justone == 0)
        printf("usertests slow tests starting\n");
      n = runtests(slowtests, justone, continuous);
    4968:	00004c97          	auipc	s9,0x4
    496c:	ab8c8c93          	addi	s9,s9,-1352 # 8420 <slowtests>
        printf("usertests slow tests starting\n");
    4970:	00003d97          	auipc	s11,0x3
    4974:	b78d8d93          	addi	s11,s11,-1160 # 74e8 <malloc+0x223a>
      } else {
        ntests += n;
      }
    }
    if((free1 = countfree()) < free0) {
      printf("FAILED -- lost some free pages %d (out of %d)\n", free1, free0);
    4978:	00003d17          	auipc	s10,0x3
    497c:	b90d0d13          	addi	s10,s10,-1136 # 7508 <malloc+0x225a>
    4980:	a025                	j	49a8 <drivetests+0x76>
      if(continuous != 2) {
    4982:	09699063          	bne	s3,s6,4a02 <drivetests+0xd0>
    int ntests = 0;
    4986:	4481                	li	s1,0
    4988:	a835                	j	49c4 <drivetests+0x92>
        printf("usertests slow tests starting\n");
    498a:	856e                	mv	a0,s11
    498c:	06f000ef          	jal	51fa <printf>
    4990:	a835                	j	49cc <drivetests+0x9a>
        if(continuous != 2) {
    4992:	07699a63          	bne	s3,s6,4a06 <drivetests+0xd4>
    if((free1 = countfree()) < free0) {
    4996:	f57ff0ef          	jal	48ec <countfree>
    499a:	05254263          	blt	a0,s2,49de <drivetests+0xac>
      if(continuous != 2) {
        return 1;
      }
    }
    if (justone != 0 && ntests == 0) {
    499e:	000a0363          	beqz	s4,49a4 <drivetests+0x72>
    49a2:	c8a1                	beqz	s1,49f2 <drivetests+0xc0>
      printf("NO TESTS EXECUTED\n");
      return 1;
    }
  } while(continuous);
    49a4:	06098563          	beqz	s3,4a0e <drivetests+0xdc>
    printf("usertests starting\n");
    49a8:	8562                	mv	a0,s8
    49aa:	051000ef          	jal	51fa <printf>
    int free0 = countfree();
    49ae:	f3fff0ef          	jal	48ec <countfree>
    49b2:	892a                	mv	s2,a0
    n = runtests(quicktests, justone, continuous);
    49b4:	864e                	mv	a2,s3
    49b6:	85d2                	mv	a1,s4
    49b8:	855e                	mv	a0,s7
    49ba:	ec1ff0ef          	jal	487a <runtests>
    49be:	84aa                	mv	s1,a0
    if (n < 0) {
    49c0:	fc0541e3          	bltz	a0,4982 <drivetests+0x50>
    if(!quick) {
    49c4:	fc0a99e3          	bnez	s5,4996 <drivetests+0x64>
      if (justone == 0)
    49c8:	fc0a01e3          	beqz	s4,498a <drivetests+0x58>
      n = runtests(slowtests, justone, continuous);
    49cc:	864e                	mv	a2,s3
    49ce:	85d2                	mv	a1,s4
    49d0:	8566                	mv	a0,s9
    49d2:	ea9ff0ef          	jal	487a <runtests>
      if (n < 0) {
    49d6:	fa054ee3          	bltz	a0,4992 <drivetests+0x60>
        ntests += n;
    49da:	9ca9                	addw	s1,s1,a0
    49dc:	bf6d                	j	4996 <drivetests+0x64>
      printf("FAILED -- lost some free pages %d (out of %d)\n", free1, free0);
    49de:	864a                	mv	a2,s2
    49e0:	85aa                	mv	a1,a0
    49e2:	856a                	mv	a0,s10
    49e4:	017000ef          	jal	51fa <printf>
      if(continuous != 2) {
    49e8:	03699163          	bne	s3,s6,4a0a <drivetests+0xd8>
    if (justone != 0 && ntests == 0) {
    49ec:	fa0a1be3          	bnez	s4,49a2 <drivetests+0x70>
    49f0:	bf65                	j	49a8 <drivetests+0x76>
      printf("NO TESTS EXECUTED\n");
    49f2:	00003517          	auipc	a0,0x3
    49f6:	b4650513          	addi	a0,a0,-1210 # 7538 <malloc+0x228a>
    49fa:	001000ef          	jal	51fa <printf>
      return 1;
    49fe:	4505                	li	a0,1
    4a00:	a801                	j	4a10 <drivetests+0xde>
        return 1;
    4a02:	4505                	li	a0,1
    4a04:	a031                	j	4a10 <drivetests+0xde>
          return 1;
    4a06:	4505                	li	a0,1
    4a08:	a021                	j	4a10 <drivetests+0xde>
        return 1;
    4a0a:	4505                	li	a0,1
    4a0c:	a011                	j	4a10 <drivetests+0xde>
  return 0;
    4a0e:	854e                	mv	a0,s3
}
    4a10:	70a6                	ld	ra,104(sp)
    4a12:	7406                	ld	s0,96(sp)
    4a14:	64e6                	ld	s1,88(sp)
    4a16:	6946                	ld	s2,80(sp)
    4a18:	69a6                	ld	s3,72(sp)
    4a1a:	6a06                	ld	s4,64(sp)
    4a1c:	7ae2                	ld	s5,56(sp)
    4a1e:	7b42                	ld	s6,48(sp)
    4a20:	7ba2                	ld	s7,40(sp)
    4a22:	7c02                	ld	s8,32(sp)
    4a24:	6ce2                	ld	s9,24(sp)
    4a26:	6d42                	ld	s10,16(sp)
    4a28:	6da2                	ld	s11,8(sp)
    4a2a:	6165                	addi	sp,sp,112
    4a2c:	8082                	ret

0000000000004a2e <main>:

int
main(int argc, char *argv[])
{
    4a2e:	1101                	addi	sp,sp,-32
    4a30:	ec06                	sd	ra,24(sp)
    4a32:	e822                	sd	s0,16(sp)
    4a34:	e426                	sd	s1,8(sp)
    4a36:	e04a                	sd	s2,0(sp)
    4a38:	1000                	addi	s0,sp,32
    4a3a:	84aa                	mv	s1,a0
  int continuous = 0;
  int quick = 0;
  char *justone = 0;

  if(argc == 2 && strcmp(argv[1], "-q") == 0){
    4a3c:	4789                	li	a5,2
    4a3e:	00f50e63          	beq	a0,a5,4a5a <main+0x2c>
    continuous = 1;
  } else if(argc == 2 && strcmp(argv[1], "-C") == 0){
    continuous = 2;
  } else if(argc == 2 && argv[1][0] != '-'){
    justone = argv[1];
  } else if(argc > 1){
    4a42:	4785                	li	a5,1
    4a44:	06a7c663          	blt	a5,a0,4ab0 <main+0x82>
  char *justone = 0;
    4a48:	4601                	li	a2,0
  int quick = 0;
    4a4a:	4501                	li	a0,0
  int continuous = 0;
    4a4c:	4581                	li	a1,0
    printf("Usage: usertests [-c] [-C] [-q] [testname]\n");
    exit(1);
  }
  if (drivetests(quick, continuous, justone)) {
    4a4e:	ee5ff0ef          	jal	4932 <drivetests>
    4a52:	cd35                	beqz	a0,4ace <main+0xa0>
    exit(1);
    4a54:	4505                	li	a0,1
    4a56:	35c000ef          	jal	4db2 <exit>
    4a5a:	892e                	mv	s2,a1
  if(argc == 2 && strcmp(argv[1], "-q") == 0){
    4a5c:	00003597          	auipc	a1,0x3
    4a60:	af458593          	addi	a1,a1,-1292 # 7550 <malloc+0x22a2>
    4a64:	00893503          	ld	a0,8(s2) # ffffffffffffd008 <base+0xfffffffffffee350>
    4a68:	0a4000ef          	jal	4b0c <strcmp>
    4a6c:	85aa                	mv	a1,a0
    4a6e:	e501                	bnez	a0,4a76 <main+0x48>
  char *justone = 0;
    4a70:	4601                	li	a2,0
    quick = 1;
    4a72:	4505                	li	a0,1
    4a74:	bfe9                	j	4a4e <main+0x20>
  } else if(argc == 2 && strcmp(argv[1], "-c") == 0){
    4a76:	00003597          	auipc	a1,0x3
    4a7a:	ae258593          	addi	a1,a1,-1310 # 7558 <malloc+0x22aa>
    4a7e:	00893503          	ld	a0,8(s2)
    4a82:	08a000ef          	jal	4b0c <strcmp>
    4a86:	cd15                	beqz	a0,4ac2 <main+0x94>
  } else if(argc == 2 && strcmp(argv[1], "-C") == 0){
    4a88:	00003597          	auipc	a1,0x3
    4a8c:	b2058593          	addi	a1,a1,-1248 # 75a8 <malloc+0x22fa>
    4a90:	00893503          	ld	a0,8(s2)
    4a94:	078000ef          	jal	4b0c <strcmp>
    4a98:	c905                	beqz	a0,4ac8 <main+0x9a>
  } else if(argc == 2 && argv[1][0] != '-'){
    4a9a:	00893603          	ld	a2,8(s2)
    4a9e:	00064703          	lbu	a4,0(a2) # 1000 <badarg>
    4aa2:	02d00793          	li	a5,45
    4aa6:	00f70563          	beq	a4,a5,4ab0 <main+0x82>
  int quick = 0;
    4aaa:	4501                	li	a0,0
  int continuous = 0;
    4aac:	4581                	li	a1,0
    4aae:	b745                	j	4a4e <main+0x20>
    printf("Usage: usertests [-c] [-C] [-q] [testname]\n");
    4ab0:	00003517          	auipc	a0,0x3
    4ab4:	ab050513          	addi	a0,a0,-1360 # 7560 <malloc+0x22b2>
    4ab8:	742000ef          	jal	51fa <printf>
    exit(1);
    4abc:	4505                	li	a0,1
    4abe:	2f4000ef          	jal	4db2 <exit>
  char *justone = 0;
    4ac2:	4601                	li	a2,0
    continuous = 1;
    4ac4:	4585                	li	a1,1
    4ac6:	b761                	j	4a4e <main+0x20>
    continuous = 2;
    4ac8:	85a6                	mv	a1,s1
  char *justone = 0;
    4aca:	4601                	li	a2,0
    4acc:	b749                	j	4a4e <main+0x20>
  }
  printf("ALL TESTS PASSED\n");
    4ace:	00003517          	auipc	a0,0x3
    4ad2:	ac250513          	addi	a0,a0,-1342 # 7590 <malloc+0x22e2>
    4ad6:	724000ef          	jal	51fa <printf>
  exit(0);
    4ada:	4501                	li	a0,0
    4adc:	2d6000ef          	jal	4db2 <exit>

0000000000004ae0 <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start(int argc, char **argv)
{
    4ae0:	1141                	addi	sp,sp,-16
    4ae2:	e406                	sd	ra,8(sp)
    4ae4:	e022                	sd	s0,0(sp)
    4ae6:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
    4ae8:	f47ff0ef          	jal	4a2e <main>
  exit(r);
    4aec:	2c6000ef          	jal	4db2 <exit>

0000000000004af0 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
    4af0:	1141                	addi	sp,sp,-16
    4af2:	e422                	sd	s0,8(sp)
    4af4:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
    4af6:	87aa                	mv	a5,a0
    4af8:	0585                	addi	a1,a1,1
    4afa:	0785                	addi	a5,a5,1
    4afc:	fff5c703          	lbu	a4,-1(a1)
    4b00:	fee78fa3          	sb	a4,-1(a5)
    4b04:	fb75                	bnez	a4,4af8 <strcpy+0x8>
    ;
  return os;
}
    4b06:	6422                	ld	s0,8(sp)
    4b08:	0141                	addi	sp,sp,16
    4b0a:	8082                	ret

0000000000004b0c <strcmp>:

int
strcmp(const char *p, const char *q)
{
    4b0c:	1141                	addi	sp,sp,-16
    4b0e:	e422                	sd	s0,8(sp)
    4b10:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
    4b12:	00054783          	lbu	a5,0(a0)
    4b16:	cb91                	beqz	a5,4b2a <strcmp+0x1e>
    4b18:	0005c703          	lbu	a4,0(a1)
    4b1c:	00f71763          	bne	a4,a5,4b2a <strcmp+0x1e>
    p++, q++;
    4b20:	0505                	addi	a0,a0,1
    4b22:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
    4b24:	00054783          	lbu	a5,0(a0)
    4b28:	fbe5                	bnez	a5,4b18 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
    4b2a:	0005c503          	lbu	a0,0(a1)
}
    4b2e:	40a7853b          	subw	a0,a5,a0
    4b32:	6422                	ld	s0,8(sp)
    4b34:	0141                	addi	sp,sp,16
    4b36:	8082                	ret

0000000000004b38 <strlen>:

uint
strlen(const char *s)
{
    4b38:	1141                	addi	sp,sp,-16
    4b3a:	e422                	sd	s0,8(sp)
    4b3c:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    4b3e:	00054783          	lbu	a5,0(a0)
    4b42:	cf91                	beqz	a5,4b5e <strlen+0x26>
    4b44:	0505                	addi	a0,a0,1
    4b46:	87aa                	mv	a5,a0
    4b48:	86be                	mv	a3,a5
    4b4a:	0785                	addi	a5,a5,1
    4b4c:	fff7c703          	lbu	a4,-1(a5)
    4b50:	ff65                	bnez	a4,4b48 <strlen+0x10>
    4b52:	40a6853b          	subw	a0,a3,a0
    4b56:	2505                	addiw	a0,a0,1
    ;
  return n;
}
    4b58:	6422                	ld	s0,8(sp)
    4b5a:	0141                	addi	sp,sp,16
    4b5c:	8082                	ret
  for(n = 0; s[n]; n++)
    4b5e:	4501                	li	a0,0
    4b60:	bfe5                	j	4b58 <strlen+0x20>

0000000000004b62 <memset>:

void*
memset(void *dst, int c, uint n)
{
    4b62:	1141                	addi	sp,sp,-16
    4b64:	e422                	sd	s0,8(sp)
    4b66:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    4b68:	ca19                	beqz	a2,4b7e <memset+0x1c>
    4b6a:	87aa                	mv	a5,a0
    4b6c:	1602                	slli	a2,a2,0x20
    4b6e:	9201                	srli	a2,a2,0x20
    4b70:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
    4b74:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    4b78:	0785                	addi	a5,a5,1
    4b7a:	fee79de3          	bne	a5,a4,4b74 <memset+0x12>
  }
  return dst;
}
    4b7e:	6422                	ld	s0,8(sp)
    4b80:	0141                	addi	sp,sp,16
    4b82:	8082                	ret

0000000000004b84 <strchr>:

char*
strchr(const char *s, char c)
{
    4b84:	1141                	addi	sp,sp,-16
    4b86:	e422                	sd	s0,8(sp)
    4b88:	0800                	addi	s0,sp,16
  for(; *s; s++)
    4b8a:	00054783          	lbu	a5,0(a0)
    4b8e:	cb99                	beqz	a5,4ba4 <strchr+0x20>
    if(*s == c)
    4b90:	00f58763          	beq	a1,a5,4b9e <strchr+0x1a>
  for(; *s; s++)
    4b94:	0505                	addi	a0,a0,1
    4b96:	00054783          	lbu	a5,0(a0)
    4b9a:	fbfd                	bnez	a5,4b90 <strchr+0xc>
      return (char*)s;
  return 0;
    4b9c:	4501                	li	a0,0
}
    4b9e:	6422                	ld	s0,8(sp)
    4ba0:	0141                	addi	sp,sp,16
    4ba2:	8082                	ret
  return 0;
    4ba4:	4501                	li	a0,0
    4ba6:	bfe5                	j	4b9e <strchr+0x1a>

0000000000004ba8 <gets>:

char*
gets(char *buf, int max)
{
    4ba8:	711d                	addi	sp,sp,-96
    4baa:	ec86                	sd	ra,88(sp)
    4bac:	e8a2                	sd	s0,80(sp)
    4bae:	e4a6                	sd	s1,72(sp)
    4bb0:	e0ca                	sd	s2,64(sp)
    4bb2:	fc4e                	sd	s3,56(sp)
    4bb4:	f852                	sd	s4,48(sp)
    4bb6:	f456                	sd	s5,40(sp)
    4bb8:	f05a                	sd	s6,32(sp)
    4bba:	ec5e                	sd	s7,24(sp)
    4bbc:	1080                	addi	s0,sp,96
    4bbe:	8baa                	mv	s7,a0
    4bc0:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
    4bc2:	892a                	mv	s2,a0
    4bc4:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
    4bc6:	4aa9                	li	s5,10
    4bc8:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
    4bca:	89a6                	mv	s3,s1
    4bcc:	2485                	addiw	s1,s1,1
    4bce:	0344d663          	bge	s1,s4,4bfa <gets+0x52>
    cc = read(0, &c, 1);
    4bd2:	4605                	li	a2,1
    4bd4:	faf40593          	addi	a1,s0,-81
    4bd8:	4501                	li	a0,0
    4bda:	1f0000ef          	jal	4dca <read>
    if(cc < 1)
    4bde:	00a05e63          	blez	a0,4bfa <gets+0x52>
    buf[i++] = c;
    4be2:	faf44783          	lbu	a5,-81(s0)
    4be6:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
    4bea:	01578763          	beq	a5,s5,4bf8 <gets+0x50>
    4bee:	0905                	addi	s2,s2,1
    4bf0:	fd679de3          	bne	a5,s6,4bca <gets+0x22>
    buf[i++] = c;
    4bf4:	89a6                	mv	s3,s1
    4bf6:	a011                	j	4bfa <gets+0x52>
    4bf8:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
    4bfa:	99de                	add	s3,s3,s7
    4bfc:	00098023          	sb	zero,0(s3)
  return buf;
}
    4c00:	855e                	mv	a0,s7
    4c02:	60e6                	ld	ra,88(sp)
    4c04:	6446                	ld	s0,80(sp)
    4c06:	64a6                	ld	s1,72(sp)
    4c08:	6906                	ld	s2,64(sp)
    4c0a:	79e2                	ld	s3,56(sp)
    4c0c:	7a42                	ld	s4,48(sp)
    4c0e:	7aa2                	ld	s5,40(sp)
    4c10:	7b02                	ld	s6,32(sp)
    4c12:	6be2                	ld	s7,24(sp)
    4c14:	6125                	addi	sp,sp,96
    4c16:	8082                	ret

0000000000004c18 <stat>:

int
stat(const char *n, struct stat *st)
{
    4c18:	1101                	addi	sp,sp,-32
    4c1a:	ec06                	sd	ra,24(sp)
    4c1c:	e822                	sd	s0,16(sp)
    4c1e:	e04a                	sd	s2,0(sp)
    4c20:	1000                	addi	s0,sp,32
    4c22:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
    4c24:	4581                	li	a1,0
    4c26:	1cc000ef          	jal	4df2 <open>
  if(fd < 0)
    4c2a:	02054263          	bltz	a0,4c4e <stat+0x36>
    4c2e:	e426                	sd	s1,8(sp)
    4c30:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
    4c32:	85ca                	mv	a1,s2
    4c34:	1d6000ef          	jal	4e0a <fstat>
    4c38:	892a                	mv	s2,a0
  close(fd);
    4c3a:	8526                	mv	a0,s1
    4c3c:	19e000ef          	jal	4dda <close>
  return r;
    4c40:	64a2                	ld	s1,8(sp)
}
    4c42:	854a                	mv	a0,s2
    4c44:	60e2                	ld	ra,24(sp)
    4c46:	6442                	ld	s0,16(sp)
    4c48:	6902                	ld	s2,0(sp)
    4c4a:	6105                	addi	sp,sp,32
    4c4c:	8082                	ret
    return -1;
    4c4e:	597d                	li	s2,-1
    4c50:	bfcd                	j	4c42 <stat+0x2a>

0000000000004c52 <atoi>:

int
atoi(const char *s)
{
    4c52:	1141                	addi	sp,sp,-16
    4c54:	e422                	sd	s0,8(sp)
    4c56:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
    4c58:	00054683          	lbu	a3,0(a0)
    4c5c:	fd06879b          	addiw	a5,a3,-48 # 3ffd0 <base+0x31318>
    4c60:	0ff7f793          	zext.b	a5,a5
    4c64:	4625                	li	a2,9
    4c66:	02f66863          	bltu	a2,a5,4c96 <atoi+0x44>
    4c6a:	872a                	mv	a4,a0
  n = 0;
    4c6c:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
    4c6e:	0705                	addi	a4,a4,1 # 1000001 <base+0xff1349>
    4c70:	0025179b          	slliw	a5,a0,0x2
    4c74:	9fa9                	addw	a5,a5,a0
    4c76:	0017979b          	slliw	a5,a5,0x1
    4c7a:	9fb5                	addw	a5,a5,a3
    4c7c:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
    4c80:	00074683          	lbu	a3,0(a4)
    4c84:	fd06879b          	addiw	a5,a3,-48
    4c88:	0ff7f793          	zext.b	a5,a5
    4c8c:	fef671e3          	bgeu	a2,a5,4c6e <atoi+0x1c>
  return n;
}
    4c90:	6422                	ld	s0,8(sp)
    4c92:	0141                	addi	sp,sp,16
    4c94:	8082                	ret
  n = 0;
    4c96:	4501                	li	a0,0
    4c98:	bfe5                	j	4c90 <atoi+0x3e>

0000000000004c9a <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
    4c9a:	1141                	addi	sp,sp,-16
    4c9c:	e422                	sd	s0,8(sp)
    4c9e:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
    4ca0:	02b57463          	bgeu	a0,a1,4cc8 <memmove+0x2e>
    while(n-- > 0)
    4ca4:	00c05f63          	blez	a2,4cc2 <memmove+0x28>
    4ca8:	1602                	slli	a2,a2,0x20
    4caa:	9201                	srli	a2,a2,0x20
    4cac:	00c507b3          	add	a5,a0,a2
  dst = vdst;
    4cb0:	872a                	mv	a4,a0
      *dst++ = *src++;
    4cb2:	0585                	addi	a1,a1,1
    4cb4:	0705                	addi	a4,a4,1
    4cb6:	fff5c683          	lbu	a3,-1(a1)
    4cba:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
    4cbe:	fef71ae3          	bne	a4,a5,4cb2 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
    4cc2:	6422                	ld	s0,8(sp)
    4cc4:	0141                	addi	sp,sp,16
    4cc6:	8082                	ret
    dst += n;
    4cc8:	00c50733          	add	a4,a0,a2
    src += n;
    4ccc:	95b2                	add	a1,a1,a2
    while(n-- > 0)
    4cce:	fec05ae3          	blez	a2,4cc2 <memmove+0x28>
    4cd2:	fff6079b          	addiw	a5,a2,-1
    4cd6:	1782                	slli	a5,a5,0x20
    4cd8:	9381                	srli	a5,a5,0x20
    4cda:	fff7c793          	not	a5,a5
    4cde:	97ba                	add	a5,a5,a4
      *--dst = *--src;
    4ce0:	15fd                	addi	a1,a1,-1
    4ce2:	177d                	addi	a4,a4,-1
    4ce4:	0005c683          	lbu	a3,0(a1)
    4ce8:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
    4cec:	fee79ae3          	bne	a5,a4,4ce0 <memmove+0x46>
    4cf0:	bfc9                	j	4cc2 <memmove+0x28>

0000000000004cf2 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
    4cf2:	1141                	addi	sp,sp,-16
    4cf4:	e422                	sd	s0,8(sp)
    4cf6:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
    4cf8:	ca05                	beqz	a2,4d28 <memcmp+0x36>
    4cfa:	fff6069b          	addiw	a3,a2,-1
    4cfe:	1682                	slli	a3,a3,0x20
    4d00:	9281                	srli	a3,a3,0x20
    4d02:	0685                	addi	a3,a3,1
    4d04:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
    4d06:	00054783          	lbu	a5,0(a0)
    4d0a:	0005c703          	lbu	a4,0(a1)
    4d0e:	00e79863          	bne	a5,a4,4d1e <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
    4d12:	0505                	addi	a0,a0,1
    p2++;
    4d14:	0585                	addi	a1,a1,1
  while (n-- > 0) {
    4d16:	fed518e3          	bne	a0,a3,4d06 <memcmp+0x14>
  }
  return 0;
    4d1a:	4501                	li	a0,0
    4d1c:	a019                	j	4d22 <memcmp+0x30>
      return *p1 - *p2;
    4d1e:	40e7853b          	subw	a0,a5,a4
}
    4d22:	6422                	ld	s0,8(sp)
    4d24:	0141                	addi	sp,sp,16
    4d26:	8082                	ret
  return 0;
    4d28:	4501                	li	a0,0
    4d2a:	bfe5                	j	4d22 <memcmp+0x30>

0000000000004d2c <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
    4d2c:	1141                	addi	sp,sp,-16
    4d2e:	e406                	sd	ra,8(sp)
    4d30:	e022                	sd	s0,0(sp)
    4d32:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    4d34:	f67ff0ef          	jal	4c9a <memmove>
}
    4d38:	60a2                	ld	ra,8(sp)
    4d3a:	6402                	ld	s0,0(sp)
    4d3c:	0141                	addi	sp,sp,16
    4d3e:	8082                	ret

0000000000004d40 <sbrk>:

char *
sbrk(int n) {
    4d40:	1141                	addi	sp,sp,-16
    4d42:	e406                	sd	ra,8(sp)
    4d44:	e022                	sd	s0,0(sp)
    4d46:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
    4d48:	4585                	li	a1,1
    4d4a:	0f0000ef          	jal	4e3a <sys_sbrk>
}
    4d4e:	60a2                	ld	ra,8(sp)
    4d50:	6402                	ld	s0,0(sp)
    4d52:	0141                	addi	sp,sp,16
    4d54:	8082                	ret

0000000000004d56 <sbrklazy>:

char *
sbrklazy(int n) {
    4d56:	1141                	addi	sp,sp,-16
    4d58:	e406                	sd	ra,8(sp)
    4d5a:	e022                	sd	s0,0(sp)
    4d5c:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
    4d5e:	4589                	li	a1,2
    4d60:	0da000ef          	jal	4e3a <sys_sbrk>
}
    4d64:	60a2                	ld	ra,8(sp)
    4d66:	6402                	ld	s0,0(sp)
    4d68:	0141                	addi	sp,sp,16
    4d6a:	8082                	ret

0000000000004d6c <getcpuinfo>:

int
getcpuinfo(struct cpu_info *cpus, int ncpu)
{
    4d6c:	1141                	addi	sp,sp,-16
    4d6e:	e406                	sd	ra,8(sp)
    4d70:	e022                	sd	s0,0(sp)
    4d72:	0800                	addi	s0,sp,16
  // Stub: return 0 CPUs for now
  // In a full implementation, this would fetch CPU state from kernel
  memset(cpus, 0, ncpu * sizeof(struct cpu_info));
    4d74:	0025961b          	slliw	a2,a1,0x2
    4d78:	9e2d                	addw	a2,a2,a1
    4d7a:	0036161b          	slliw	a2,a2,0x3
    4d7e:	4581                	li	a1,0
    4d80:	de3ff0ef          	jal	4b62 <memset>
  return 0;
}
    4d84:	4501                	li	a0,0
    4d86:	60a2                	ld	ra,8(sp)
    4d88:	6402                	ld	s0,0(sp)
    4d8a:	0141                	addi	sp,sp,16
    4d8c:	8082                	ret

0000000000004d8e <getprocstats>:

int
getprocstats(struct proc_stats *stats)
{
    4d8e:	1141                	addi	sp,sp,-16
    4d90:	e406                	sd	ra,8(sp)
    4d92:	e022                	sd	s0,0(sp)
    4d94:	0800                	addi	s0,sp,16
  // Stub: return zeros for now
  // In a full implementation, this would fetch process statistics from kernel
  memset(stats, 0, sizeof(struct proc_stats));
    4d96:	07000613          	li	a2,112
    4d9a:	4581                	li	a1,0
    4d9c:	dc7ff0ef          	jal	4b62 <memset>
  return 0;
}
    4da0:	4501                	li	a0,0
    4da2:	60a2                	ld	ra,8(sp)
    4da4:	6402                	ld	s0,0(sp)
    4da6:	0141                	addi	sp,sp,16
    4da8:	8082                	ret

0000000000004daa <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
    4daa:	4885                	li	a7,1
 ecall
    4dac:	00000073          	ecall
 ret
    4db0:	8082                	ret

0000000000004db2 <exit>:
.global exit
exit:
 li a7, SYS_exit
    4db2:	4889                	li	a7,2
 ecall
    4db4:	00000073          	ecall
 ret
    4db8:	8082                	ret

0000000000004dba <wait>:
.global wait
wait:
 li a7, SYS_wait
    4dba:	488d                	li	a7,3
 ecall
    4dbc:	00000073          	ecall
 ret
    4dc0:	8082                	ret

0000000000004dc2 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
    4dc2:	4891                	li	a7,4
 ecall
    4dc4:	00000073          	ecall
 ret
    4dc8:	8082                	ret

0000000000004dca <read>:
.global read
read:
 li a7, SYS_read
    4dca:	4895                	li	a7,5
 ecall
    4dcc:	00000073          	ecall
 ret
    4dd0:	8082                	ret

0000000000004dd2 <write>:
.global write
write:
 li a7, SYS_write
    4dd2:	48c1                	li	a7,16
 ecall
    4dd4:	00000073          	ecall
 ret
    4dd8:	8082                	ret

0000000000004dda <close>:
.global close
close:
 li a7, SYS_close
    4dda:	48d5                	li	a7,21
 ecall
    4ddc:	00000073          	ecall
 ret
    4de0:	8082                	ret

0000000000004de2 <kill>:
.global kill
kill:
 li a7, SYS_kill
    4de2:	4899                	li	a7,6
 ecall
    4de4:	00000073          	ecall
 ret
    4de8:	8082                	ret

0000000000004dea <exec>:
.global exec
exec:
 li a7, SYS_exec
    4dea:	489d                	li	a7,7
 ecall
    4dec:	00000073          	ecall
 ret
    4df0:	8082                	ret

0000000000004df2 <open>:
.global open
open:
 li a7, SYS_open
    4df2:	48bd                	li	a7,15
 ecall
    4df4:	00000073          	ecall
 ret
    4df8:	8082                	ret

0000000000004dfa <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
    4dfa:	48c5                	li	a7,17
 ecall
    4dfc:	00000073          	ecall
 ret
    4e00:	8082                	ret

0000000000004e02 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
    4e02:	48c9                	li	a7,18
 ecall
    4e04:	00000073          	ecall
 ret
    4e08:	8082                	ret

0000000000004e0a <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
    4e0a:	48a1                	li	a7,8
 ecall
    4e0c:	00000073          	ecall
 ret
    4e10:	8082                	ret

0000000000004e12 <link>:
.global link
link:
 li a7, SYS_link
    4e12:	48cd                	li	a7,19
 ecall
    4e14:	00000073          	ecall
 ret
    4e18:	8082                	ret

0000000000004e1a <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
    4e1a:	48d1                	li	a7,20
 ecall
    4e1c:	00000073          	ecall
 ret
    4e20:	8082                	ret

0000000000004e22 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
    4e22:	48a5                	li	a7,9
 ecall
    4e24:	00000073          	ecall
 ret
    4e28:	8082                	ret

0000000000004e2a <dup>:
.global dup
dup:
 li a7, SYS_dup
    4e2a:	48a9                	li	a7,10
 ecall
    4e2c:	00000073          	ecall
 ret
    4e30:	8082                	ret

0000000000004e32 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
    4e32:	48ad                	li	a7,11
 ecall
    4e34:	00000073          	ecall
 ret
    4e38:	8082                	ret

0000000000004e3a <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
    4e3a:	48b1                	li	a7,12
 ecall
    4e3c:	00000073          	ecall
 ret
    4e40:	8082                	ret

0000000000004e42 <pause>:
.global pause
pause:
 li a7, SYS_pause
    4e42:	48b5                	li	a7,13
 ecall
    4e44:	00000073          	ecall
 ret
    4e48:	8082                	ret

0000000000004e4a <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
    4e4a:	48b9                	li	a7,14
 ecall
    4e4c:	00000073          	ecall
 ret
    4e50:	8082                	ret

0000000000004e52 <csread>:
.global csread
csread:
 li a7, SYS_csread
    4e52:	48d9                	li	a7,22
 ecall
    4e54:	00000073          	ecall
 ret
    4e58:	8082                	ret

0000000000004e5a <fsread>:
.global fsread
fsread:
 li a7, SYS_fsread
    4e5a:	48dd                	li	a7,23
 ecall
    4e5c:	00000073          	ecall
 ret
    4e60:	8082                	ret

0000000000004e62 <schedread>:
.global schedread
schedread:
 li a7, SYS_schedread
    4e62:	48e1                	li	a7,24
 ecall
    4e64:	00000073          	ecall
 ret
    4e68:	8082                	ret

0000000000004e6a <memread>:
.global memread
memread:
 li a7, SYS_memread
    4e6a:	48e5                	li	a7,25
 ecall
    4e6c:	00000073          	ecall
 ret
    4e70:	8082                	ret

0000000000004e72 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
    4e72:	1101                	addi	sp,sp,-32
    4e74:	ec06                	sd	ra,24(sp)
    4e76:	e822                	sd	s0,16(sp)
    4e78:	1000                	addi	s0,sp,32
    4e7a:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
    4e7e:	4605                	li	a2,1
    4e80:	fef40593          	addi	a1,s0,-17
    4e84:	f4fff0ef          	jal	4dd2 <write>
}
    4e88:	60e2                	ld	ra,24(sp)
    4e8a:	6442                	ld	s0,16(sp)
    4e8c:	6105                	addi	sp,sp,32
    4e8e:	8082                	ret

0000000000004e90 <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
    4e90:	715d                	addi	sp,sp,-80
    4e92:	e486                	sd	ra,72(sp)
    4e94:	e0a2                	sd	s0,64(sp)
    4e96:	f84a                	sd	s2,48(sp)
    4e98:	0880                	addi	s0,sp,80
    4e9a:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
    4e9c:	c299                	beqz	a3,4ea2 <printint+0x12>
    4e9e:	0805c363          	bltz	a1,4f24 <printint+0x94>
  neg = 0;
    4ea2:	4881                	li	a7,0
    4ea4:	fb840693          	addi	a3,s0,-72
    x = -xx;
  } else {
    x = xx;
  }

  i = 0;
    4ea8:	4781                	li	a5,0
  do{
    buf[i++] = digits[x % base];
    4eaa:	00003517          	auipc	a0,0x3
    4eae:	b2e50513          	addi	a0,a0,-1234 # 79d8 <digits>
    4eb2:	883e                	mv	a6,a5
    4eb4:	2785                	addiw	a5,a5,1
    4eb6:	02c5f733          	remu	a4,a1,a2
    4eba:	972a                	add	a4,a4,a0
    4ebc:	00074703          	lbu	a4,0(a4)
    4ec0:	00e68023          	sb	a4,0(a3)
  }while((x /= base) != 0);
    4ec4:	872e                	mv	a4,a1
    4ec6:	02c5d5b3          	divu	a1,a1,a2
    4eca:	0685                	addi	a3,a3,1
    4ecc:	fec773e3          	bgeu	a4,a2,4eb2 <printint+0x22>
  if(neg)
    4ed0:	00088b63          	beqz	a7,4ee6 <printint+0x56>
    buf[i++] = '-';
    4ed4:	fd078793          	addi	a5,a5,-48
    4ed8:	97a2                	add	a5,a5,s0
    4eda:	02d00713          	li	a4,45
    4ede:	fee78423          	sb	a4,-24(a5)
    4ee2:	0028079b          	addiw	a5,a6,2

  while(--i >= 0)
    4ee6:	02f05a63          	blez	a5,4f1a <printint+0x8a>
    4eea:	fc26                	sd	s1,56(sp)
    4eec:	f44e                	sd	s3,40(sp)
    4eee:	fb840713          	addi	a4,s0,-72
    4ef2:	00f704b3          	add	s1,a4,a5
    4ef6:	fff70993          	addi	s3,a4,-1
    4efa:	99be                	add	s3,s3,a5
    4efc:	37fd                	addiw	a5,a5,-1
    4efe:	1782                	slli	a5,a5,0x20
    4f00:	9381                	srli	a5,a5,0x20
    4f02:	40f989b3          	sub	s3,s3,a5
    putc(fd, buf[i]);
    4f06:	fff4c583          	lbu	a1,-1(s1)
    4f0a:	854a                	mv	a0,s2
    4f0c:	f67ff0ef          	jal	4e72 <putc>
  while(--i >= 0)
    4f10:	14fd                	addi	s1,s1,-1
    4f12:	ff349ae3          	bne	s1,s3,4f06 <printint+0x76>
    4f16:	74e2                	ld	s1,56(sp)
    4f18:	79a2                	ld	s3,40(sp)
}
    4f1a:	60a6                	ld	ra,72(sp)
    4f1c:	6406                	ld	s0,64(sp)
    4f1e:	7942                	ld	s2,48(sp)
    4f20:	6161                	addi	sp,sp,80
    4f22:	8082                	ret
    x = -xx;
    4f24:	40b005b3          	neg	a1,a1
    neg = 1;
    4f28:	4885                	li	a7,1
    x = -xx;
    4f2a:	bfad                	j	4ea4 <printint+0x14>

0000000000004f2c <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
    4f2c:	711d                	addi	sp,sp,-96
    4f2e:	ec86                	sd	ra,88(sp)
    4f30:	e8a2                	sd	s0,80(sp)
    4f32:	e0ca                	sd	s2,64(sp)
    4f34:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
    4f36:	0005c903          	lbu	s2,0(a1)
    4f3a:	28090663          	beqz	s2,51c6 <vprintf+0x29a>
    4f3e:	e4a6                	sd	s1,72(sp)
    4f40:	fc4e                	sd	s3,56(sp)
    4f42:	f852                	sd	s4,48(sp)
    4f44:	f456                	sd	s5,40(sp)
    4f46:	f05a                	sd	s6,32(sp)
    4f48:	ec5e                	sd	s7,24(sp)
    4f4a:	e862                	sd	s8,16(sp)
    4f4c:	e466                	sd	s9,8(sp)
    4f4e:	8b2a                	mv	s6,a0
    4f50:	8a2e                	mv	s4,a1
    4f52:	8bb2                	mv	s7,a2
  state = 0;
    4f54:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
    4f56:	4481                	li	s1,0
    4f58:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
    4f5a:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
    4f5e:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
    4f62:	06c00c93          	li	s9,108
    4f66:	a005                	j	4f86 <vprintf+0x5a>
        putc(fd, c0);
    4f68:	85ca                	mv	a1,s2
    4f6a:	855a                	mv	a0,s6
    4f6c:	f07ff0ef          	jal	4e72 <putc>
    4f70:	a019                	j	4f76 <vprintf+0x4a>
    } else if(state == '%'){
    4f72:	03598263          	beq	s3,s5,4f96 <vprintf+0x6a>
  for(i = 0; fmt[i]; i++){
    4f76:	2485                	addiw	s1,s1,1
    4f78:	8726                	mv	a4,s1
    4f7a:	009a07b3          	add	a5,s4,s1
    4f7e:	0007c903          	lbu	s2,0(a5)
    4f82:	22090a63          	beqz	s2,51b6 <vprintf+0x28a>
    c0 = fmt[i] & 0xff;
    4f86:	0009079b          	sext.w	a5,s2
    if(state == 0){
    4f8a:	fe0994e3          	bnez	s3,4f72 <vprintf+0x46>
      if(c0 == '%'){
    4f8e:	fd579de3          	bne	a5,s5,4f68 <vprintf+0x3c>
        state = '%';
    4f92:	89be                	mv	s3,a5
    4f94:	b7cd                	j	4f76 <vprintf+0x4a>
      if(c0) c1 = fmt[i+1] & 0xff;
    4f96:	00ea06b3          	add	a3,s4,a4
    4f9a:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
    4f9e:	8636                	mv	a2,a3
      if(c1) c2 = fmt[i+2] & 0xff;
    4fa0:	c681                	beqz	a3,4fa8 <vprintf+0x7c>
    4fa2:	9752                	add	a4,a4,s4
    4fa4:	00274603          	lbu	a2,2(a4)
      if(c0 == 'd'){
    4fa8:	05878363          	beq	a5,s8,4fee <vprintf+0xc2>
      } else if(c0 == 'l' && c1 == 'd'){
    4fac:	05978d63          	beq	a5,s9,5006 <vprintf+0xda>
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if(c0 == 'u'){
    4fb0:	07500713          	li	a4,117
    4fb4:	0ee78763          	beq	a5,a4,50a2 <vprintf+0x176>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if(c0 == 'x'){
    4fb8:	07800713          	li	a4,120
    4fbc:	12e78963          	beq	a5,a4,50ee <vprintf+0x1c2>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if(c0 == 'p'){
    4fc0:	07000713          	li	a4,112
    4fc4:	14e78e63          	beq	a5,a4,5120 <vprintf+0x1f4>
        printptr(fd, va_arg(ap, uint64));
      } else if(c0 == 'c'){
    4fc8:	06300713          	li	a4,99
    4fcc:	18e78e63          	beq	a5,a4,5168 <vprintf+0x23c>
        putc(fd, va_arg(ap, uint32));
      } else if(c0 == 's'){
    4fd0:	07300713          	li	a4,115
    4fd4:	1ae78463          	beq	a5,a4,517c <vprintf+0x250>
        if((s = va_arg(ap, char*)) == 0)
          s = "(null)";
        for(; *s; s++)
          putc(fd, *s);
      } else if(c0 == '%'){
    4fd8:	02500713          	li	a4,37
    4fdc:	04e79563          	bne	a5,a4,5026 <vprintf+0xfa>
        putc(fd, '%');
    4fe0:	02500593          	li	a1,37
    4fe4:	855a                	mv	a0,s6
    4fe6:	e8dff0ef          	jal	4e72 <putc>
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
    4fea:	4981                	li	s3,0
    4fec:	b769                	j	4f76 <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 10, 1);
    4fee:	008b8913          	addi	s2,s7,8
    4ff2:	4685                	li	a3,1
    4ff4:	4629                	li	a2,10
    4ff6:	000ba583          	lw	a1,0(s7)
    4ffa:	855a                	mv	a0,s6
    4ffc:	e95ff0ef          	jal	4e90 <printint>
    5000:	8bca                	mv	s7,s2
      state = 0;
    5002:	4981                	li	s3,0
    5004:	bf8d                	j	4f76 <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'd'){
    5006:	06400793          	li	a5,100
    500a:	02f68963          	beq	a3,a5,503c <vprintf+0x110>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
    500e:	06c00793          	li	a5,108
    5012:	04f68263          	beq	a3,a5,5056 <vprintf+0x12a>
      } else if(c0 == 'l' && c1 == 'u'){
    5016:	07500793          	li	a5,117
    501a:	0af68063          	beq	a3,a5,50ba <vprintf+0x18e>
      } else if(c0 == 'l' && c1 == 'x'){
    501e:	07800793          	li	a5,120
    5022:	0ef68263          	beq	a3,a5,5106 <vprintf+0x1da>
        putc(fd, '%');
    5026:	02500593          	li	a1,37
    502a:	855a                	mv	a0,s6
    502c:	e47ff0ef          	jal	4e72 <putc>
        putc(fd, c0);
    5030:	85ca                	mv	a1,s2
    5032:	855a                	mv	a0,s6
    5034:	e3fff0ef          	jal	4e72 <putc>
      state = 0;
    5038:	4981                	li	s3,0
    503a:	bf35                	j	4f76 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
    503c:	008b8913          	addi	s2,s7,8
    5040:	4685                	li	a3,1
    5042:	4629                	li	a2,10
    5044:	000bb583          	ld	a1,0(s7)
    5048:	855a                	mv	a0,s6
    504a:	e47ff0ef          	jal	4e90 <printint>
        i += 1;
    504e:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 1);
    5050:	8bca                	mv	s7,s2
      state = 0;
    5052:	4981                	li	s3,0
        i += 1;
    5054:	b70d                	j	4f76 <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
    5056:	06400793          	li	a5,100
    505a:	02f60763          	beq	a2,a5,5088 <vprintf+0x15c>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
    505e:	07500793          	li	a5,117
    5062:	06f60963          	beq	a2,a5,50d4 <vprintf+0x1a8>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
    5066:	07800793          	li	a5,120
    506a:	faf61ee3          	bne	a2,a5,5026 <vprintf+0xfa>
        printint(fd, va_arg(ap, uint64), 16, 0);
    506e:	008b8913          	addi	s2,s7,8
    5072:	4681                	li	a3,0
    5074:	4641                	li	a2,16
    5076:	000bb583          	ld	a1,0(s7)
    507a:	855a                	mv	a0,s6
    507c:	e15ff0ef          	jal	4e90 <printint>
        i += 2;
    5080:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 16, 0);
    5082:	8bca                	mv	s7,s2
      state = 0;
    5084:	4981                	li	s3,0
        i += 2;
    5086:	bdc5                	j	4f76 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
    5088:	008b8913          	addi	s2,s7,8
    508c:	4685                	li	a3,1
    508e:	4629                	li	a2,10
    5090:	000bb583          	ld	a1,0(s7)
    5094:	855a                	mv	a0,s6
    5096:	dfbff0ef          	jal	4e90 <printint>
        i += 2;
    509a:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 1);
    509c:	8bca                	mv	s7,s2
      state = 0;
    509e:	4981                	li	s3,0
        i += 2;
    50a0:	bdd9                	j	4f76 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint32), 10, 0);
    50a2:	008b8913          	addi	s2,s7,8
    50a6:	4681                	li	a3,0
    50a8:	4629                	li	a2,10
    50aa:	000be583          	lwu	a1,0(s7)
    50ae:	855a                	mv	a0,s6
    50b0:	de1ff0ef          	jal	4e90 <printint>
    50b4:	8bca                	mv	s7,s2
      state = 0;
    50b6:	4981                	li	s3,0
    50b8:	bd7d                	j	4f76 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
    50ba:	008b8913          	addi	s2,s7,8
    50be:	4681                	li	a3,0
    50c0:	4629                	li	a2,10
    50c2:	000bb583          	ld	a1,0(s7)
    50c6:	855a                	mv	a0,s6
    50c8:	dc9ff0ef          	jal	4e90 <printint>
        i += 1;
    50cc:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 0);
    50ce:	8bca                	mv	s7,s2
      state = 0;
    50d0:	4981                	li	s3,0
        i += 1;
    50d2:	b555                	j	4f76 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
    50d4:	008b8913          	addi	s2,s7,8
    50d8:	4681                	li	a3,0
    50da:	4629                	li	a2,10
    50dc:	000bb583          	ld	a1,0(s7)
    50e0:	855a                	mv	a0,s6
    50e2:	dafff0ef          	jal	4e90 <printint>
        i += 2;
    50e6:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 0);
    50e8:	8bca                	mv	s7,s2
      state = 0;
    50ea:	4981                	li	s3,0
        i += 2;
    50ec:	b569                	j	4f76 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint32), 16, 0);
    50ee:	008b8913          	addi	s2,s7,8
    50f2:	4681                	li	a3,0
    50f4:	4641                	li	a2,16
    50f6:	000be583          	lwu	a1,0(s7)
    50fa:	855a                	mv	a0,s6
    50fc:	d95ff0ef          	jal	4e90 <printint>
    5100:	8bca                	mv	s7,s2
      state = 0;
    5102:	4981                	li	s3,0
    5104:	bd8d                	j	4f76 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 16, 0);
    5106:	008b8913          	addi	s2,s7,8
    510a:	4681                	li	a3,0
    510c:	4641                	li	a2,16
    510e:	000bb583          	ld	a1,0(s7)
    5112:	855a                	mv	a0,s6
    5114:	d7dff0ef          	jal	4e90 <printint>
        i += 1;
    5118:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 16, 0);
    511a:	8bca                	mv	s7,s2
      state = 0;
    511c:	4981                	li	s3,0
        i += 1;
    511e:	bda1                	j	4f76 <vprintf+0x4a>
    5120:	e06a                	sd	s10,0(sp)
        printptr(fd, va_arg(ap, uint64));
    5122:	008b8d13          	addi	s10,s7,8
    5126:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
    512a:	03000593          	li	a1,48
    512e:	855a                	mv	a0,s6
    5130:	d43ff0ef          	jal	4e72 <putc>
  putc(fd, 'x');
    5134:	07800593          	li	a1,120
    5138:	855a                	mv	a0,s6
    513a:	d39ff0ef          	jal	4e72 <putc>
    513e:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
    5140:	00003b97          	auipc	s7,0x3
    5144:	898b8b93          	addi	s7,s7,-1896 # 79d8 <digits>
    5148:	03c9d793          	srli	a5,s3,0x3c
    514c:	97de                	add	a5,a5,s7
    514e:	0007c583          	lbu	a1,0(a5)
    5152:	855a                	mv	a0,s6
    5154:	d1fff0ef          	jal	4e72 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    5158:	0992                	slli	s3,s3,0x4
    515a:	397d                	addiw	s2,s2,-1
    515c:	fe0916e3          	bnez	s2,5148 <vprintf+0x21c>
        printptr(fd, va_arg(ap, uint64));
    5160:	8bea                	mv	s7,s10
      state = 0;
    5162:	4981                	li	s3,0
    5164:	6d02                	ld	s10,0(sp)
    5166:	bd01                	j	4f76 <vprintf+0x4a>
        putc(fd, va_arg(ap, uint32));
    5168:	008b8913          	addi	s2,s7,8
    516c:	000bc583          	lbu	a1,0(s7)
    5170:	855a                	mv	a0,s6
    5172:	d01ff0ef          	jal	4e72 <putc>
    5176:	8bca                	mv	s7,s2
      state = 0;
    5178:	4981                	li	s3,0
    517a:	bbf5                	j	4f76 <vprintf+0x4a>
        if((s = va_arg(ap, char*)) == 0)
    517c:	008b8993          	addi	s3,s7,8
    5180:	000bb903          	ld	s2,0(s7)
    5184:	00090f63          	beqz	s2,51a2 <vprintf+0x276>
        for(; *s; s++)
    5188:	00094583          	lbu	a1,0(s2)
    518c:	c195                	beqz	a1,51b0 <vprintf+0x284>
          putc(fd, *s);
    518e:	855a                	mv	a0,s6
    5190:	ce3ff0ef          	jal	4e72 <putc>
        for(; *s; s++)
    5194:	0905                	addi	s2,s2,1
    5196:	00094583          	lbu	a1,0(s2)
    519a:	f9f5                	bnez	a1,518e <vprintf+0x262>
        if((s = va_arg(ap, char*)) == 0)
    519c:	8bce                	mv	s7,s3
      state = 0;
    519e:	4981                	li	s3,0
    51a0:	bbd9                	j	4f76 <vprintf+0x4a>
          s = "(null)";
    51a2:	00002917          	auipc	s2,0x2
    51a6:	78690913          	addi	s2,s2,1926 # 7928 <malloc+0x267a>
        for(; *s; s++)
    51aa:	02800593          	li	a1,40
    51ae:	b7c5                	j	518e <vprintf+0x262>
        if((s = va_arg(ap, char*)) == 0)
    51b0:	8bce                	mv	s7,s3
      state = 0;
    51b2:	4981                	li	s3,0
    51b4:	b3c9                	j	4f76 <vprintf+0x4a>
    51b6:	64a6                	ld	s1,72(sp)
    51b8:	79e2                	ld	s3,56(sp)
    51ba:	7a42                	ld	s4,48(sp)
    51bc:	7aa2                	ld	s5,40(sp)
    51be:	7b02                	ld	s6,32(sp)
    51c0:	6be2                	ld	s7,24(sp)
    51c2:	6c42                	ld	s8,16(sp)
    51c4:	6ca2                	ld	s9,8(sp)
    }
  }
}
    51c6:	60e6                	ld	ra,88(sp)
    51c8:	6446                	ld	s0,80(sp)
    51ca:	6906                	ld	s2,64(sp)
    51cc:	6125                	addi	sp,sp,96
    51ce:	8082                	ret

00000000000051d0 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
    51d0:	715d                	addi	sp,sp,-80
    51d2:	ec06                	sd	ra,24(sp)
    51d4:	e822                	sd	s0,16(sp)
    51d6:	1000                	addi	s0,sp,32
    51d8:	e010                	sd	a2,0(s0)
    51da:	e414                	sd	a3,8(s0)
    51dc:	e818                	sd	a4,16(s0)
    51de:	ec1c                	sd	a5,24(s0)
    51e0:	03043023          	sd	a6,32(s0)
    51e4:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
    51e8:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
    51ec:	8622                	mv	a2,s0
    51ee:	d3fff0ef          	jal	4f2c <vprintf>
}
    51f2:	60e2                	ld	ra,24(sp)
    51f4:	6442                	ld	s0,16(sp)
    51f6:	6161                	addi	sp,sp,80
    51f8:	8082                	ret

00000000000051fa <printf>:

void
printf(const char *fmt, ...)
{
    51fa:	711d                	addi	sp,sp,-96
    51fc:	ec06                	sd	ra,24(sp)
    51fe:	e822                	sd	s0,16(sp)
    5200:	1000                	addi	s0,sp,32
    5202:	e40c                	sd	a1,8(s0)
    5204:	e810                	sd	a2,16(s0)
    5206:	ec14                	sd	a3,24(s0)
    5208:	f018                	sd	a4,32(s0)
    520a:	f41c                	sd	a5,40(s0)
    520c:	03043823          	sd	a6,48(s0)
    5210:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
    5214:	00840613          	addi	a2,s0,8
    5218:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
    521c:	85aa                	mv	a1,a0
    521e:	4505                	li	a0,1
    5220:	d0dff0ef          	jal	4f2c <vprintf>
}
    5224:	60e2                	ld	ra,24(sp)
    5226:	6442                	ld	s0,16(sp)
    5228:	6125                	addi	sp,sp,96
    522a:	8082                	ret

000000000000522c <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
    522c:	1141                	addi	sp,sp,-16
    522e:	e422                	sd	s0,8(sp)
    5230:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
    5232:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    5236:	00003797          	auipc	a5,0x3
    523a:	25a7b783          	ld	a5,602(a5) # 8490 <freep>
    523e:	a02d                	j	5268 <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
    5240:	4618                	lw	a4,8(a2)
    5242:	9f2d                	addw	a4,a4,a1
    5244:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
    5248:	6398                	ld	a4,0(a5)
    524a:	6310                	ld	a2,0(a4)
    524c:	a83d                	j	528a <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
    524e:	ff852703          	lw	a4,-8(a0)
    5252:	9f31                	addw	a4,a4,a2
    5254:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
    5256:	ff053683          	ld	a3,-16(a0)
    525a:	a091                	j	529e <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    525c:	6398                	ld	a4,0(a5)
    525e:	00e7e463          	bltu	a5,a4,5266 <free+0x3a>
    5262:	00e6ea63          	bltu	a3,a4,5276 <free+0x4a>
{
    5266:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    5268:	fed7fae3          	bgeu	a5,a3,525c <free+0x30>
    526c:	6398                	ld	a4,0(a5)
    526e:	00e6e463          	bltu	a3,a4,5276 <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    5272:	fee7eae3          	bltu	a5,a4,5266 <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
    5276:	ff852583          	lw	a1,-8(a0)
    527a:	6390                	ld	a2,0(a5)
    527c:	02059813          	slli	a6,a1,0x20
    5280:	01c85713          	srli	a4,a6,0x1c
    5284:	9736                	add	a4,a4,a3
    5286:	fae60de3          	beq	a2,a4,5240 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
    528a:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
    528e:	4790                	lw	a2,8(a5)
    5290:	02061593          	slli	a1,a2,0x20
    5294:	01c5d713          	srli	a4,a1,0x1c
    5298:	973e                	add	a4,a4,a5
    529a:	fae68ae3          	beq	a3,a4,524e <free+0x22>
    p->s.ptr = bp->s.ptr;
    529e:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
    52a0:	00003717          	auipc	a4,0x3
    52a4:	1ef73823          	sd	a5,496(a4) # 8490 <freep>
}
    52a8:	6422                	ld	s0,8(sp)
    52aa:	0141                	addi	sp,sp,16
    52ac:	8082                	ret

00000000000052ae <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
    52ae:	7139                	addi	sp,sp,-64
    52b0:	fc06                	sd	ra,56(sp)
    52b2:	f822                	sd	s0,48(sp)
    52b4:	f426                	sd	s1,40(sp)
    52b6:	ec4e                	sd	s3,24(sp)
    52b8:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
    52ba:	02051493          	slli	s1,a0,0x20
    52be:	9081                	srli	s1,s1,0x20
    52c0:	04bd                	addi	s1,s1,15
    52c2:	8091                	srli	s1,s1,0x4
    52c4:	0014899b          	addiw	s3,s1,1
    52c8:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
    52ca:	00003517          	auipc	a0,0x3
    52ce:	1c653503          	ld	a0,454(a0) # 8490 <freep>
    52d2:	c915                	beqz	a0,5306 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    52d4:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
    52d6:	4798                	lw	a4,8(a5)
    52d8:	08977a63          	bgeu	a4,s1,536c <malloc+0xbe>
    52dc:	f04a                	sd	s2,32(sp)
    52de:	e852                	sd	s4,16(sp)
    52e0:	e456                	sd	s5,8(sp)
    52e2:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
    52e4:	8a4e                	mv	s4,s3
    52e6:	0009871b          	sext.w	a4,s3
    52ea:	6685                	lui	a3,0x1
    52ec:	00d77363          	bgeu	a4,a3,52f2 <malloc+0x44>
    52f0:	6a05                	lui	s4,0x1
    52f2:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
    52f6:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
    52fa:	00003917          	auipc	s2,0x3
    52fe:	19690913          	addi	s2,s2,406 # 8490 <freep>
  if(p == SBRK_ERROR)
    5302:	5afd                	li	s5,-1
    5304:	a081                	j	5344 <malloc+0x96>
    5306:	f04a                	sd	s2,32(sp)
    5308:	e852                	sd	s4,16(sp)
    530a:	e456                	sd	s5,8(sp)
    530c:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
    530e:	0000a797          	auipc	a5,0xa
    5312:	9aa78793          	addi	a5,a5,-1622 # ecb8 <base>
    5316:	00003717          	auipc	a4,0x3
    531a:	16f73d23          	sd	a5,378(a4) # 8490 <freep>
    531e:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
    5320:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
    5324:	b7c1                	j	52e4 <malloc+0x36>
        prevp->s.ptr = p->s.ptr;
    5326:	6398                	ld	a4,0(a5)
    5328:	e118                	sd	a4,0(a0)
    532a:	a8a9                	j	5384 <malloc+0xd6>
  hp->s.size = nu;
    532c:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
    5330:	0541                	addi	a0,a0,16
    5332:	efbff0ef          	jal	522c <free>
  return freep;
    5336:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
    533a:	c12d                	beqz	a0,539c <malloc+0xee>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    533c:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
    533e:	4798                	lw	a4,8(a5)
    5340:	02977263          	bgeu	a4,s1,5364 <malloc+0xb6>
    if(p == freep)
    5344:	00093703          	ld	a4,0(s2)
    5348:	853e                	mv	a0,a5
    534a:	fef719e3          	bne	a4,a5,533c <malloc+0x8e>
  p = sbrk(nu * sizeof(Header));
    534e:	8552                	mv	a0,s4
    5350:	9f1ff0ef          	jal	4d40 <sbrk>
  if(p == SBRK_ERROR)
    5354:	fd551ce3          	bne	a0,s5,532c <malloc+0x7e>
        return 0;
    5358:	4501                	li	a0,0
    535a:	7902                	ld	s2,32(sp)
    535c:	6a42                	ld	s4,16(sp)
    535e:	6aa2                	ld	s5,8(sp)
    5360:	6b02                	ld	s6,0(sp)
    5362:	a03d                	j	5390 <malloc+0xe2>
    5364:	7902                	ld	s2,32(sp)
    5366:	6a42                	ld	s4,16(sp)
    5368:	6aa2                	ld	s5,8(sp)
    536a:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
    536c:	fae48de3          	beq	s1,a4,5326 <malloc+0x78>
        p->s.size -= nunits;
    5370:	4137073b          	subw	a4,a4,s3
    5374:	c798                	sw	a4,8(a5)
        p += p->s.size;
    5376:	02071693          	slli	a3,a4,0x20
    537a:	01c6d713          	srli	a4,a3,0x1c
    537e:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
    5380:	0137a423          	sw	s3,8(a5)
      freep = prevp;
    5384:	00003717          	auipc	a4,0x3
    5388:	10a73623          	sd	a0,268(a4) # 8490 <freep>
      return (void*)(p + 1);
    538c:	01078513          	addi	a0,a5,16
  }
}
    5390:	70e2                	ld	ra,56(sp)
    5392:	7442                	ld	s0,48(sp)
    5394:	74a2                	ld	s1,40(sp)
    5396:	69e2                	ld	s3,24(sp)
    5398:	6121                	addi	sp,sp,64
    539a:	8082                	ret
    539c:	7902                	ld	s2,32(sp)
    539e:	6a42                	ld	s4,16(sp)
    53a0:	6aa2                	ld	s5,8(sp)
    53a2:	6b02                	ld	s6,0(sp)
    53a4:	b7f5                	j	5390 <malloc+0xe2>
