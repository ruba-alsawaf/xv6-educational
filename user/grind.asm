
user/_grind:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <do_rand>:
#include "kernel/riscv.h"

// from FreeBSD.
int
do_rand(unsigned long *ctx)
{
       0:	1141                	addi	sp,sp,-16
       2:	e422                	sd	s0,8(sp)
       4:	0800                	addi	s0,sp,16
 * October 1988, p. 1195.
 */
    long hi, lo, x;

    /* Transform to [1, 0x7ffffffe] range. */
    x = (*ctx % 0x7ffffffe) + 1;
       6:	611c                	ld	a5,0(a0)
       8:	80000737          	lui	a4,0x80000
       c:	ffe74713          	xori	a4,a4,-2
      10:	02e7f7b3          	remu	a5,a5,a4
      14:	0785                	addi	a5,a5,1
    hi = x / 127773;
    lo = x % 127773;
      16:	66fd                	lui	a3,0x1f
      18:	31d68693          	addi	a3,a3,797 # 1f31d <base+0x1cf15>
      1c:	02d7e733          	rem	a4,a5,a3
    x = 16807 * lo - 2836 * hi;
      20:	6611                	lui	a2,0x4
      22:	1a760613          	addi	a2,a2,423 # 41a7 <base+0x1d9f>
      26:	02c70733          	mul	a4,a4,a2
    hi = x / 127773;
      2a:	02d7c7b3          	div	a5,a5,a3
    x = 16807 * lo - 2836 * hi;
      2e:	76fd                	lui	a3,0xfffff
      30:	4ec68693          	addi	a3,a3,1260 # fffffffffffff4ec <base+0xffffffffffffd0e4>
      34:	02d787b3          	mul	a5,a5,a3
      38:	97ba                	add	a5,a5,a4
    if (x < 0)
      3a:	0007c963          	bltz	a5,4c <do_rand+0x4c>
        x += 0x7fffffff;
    /* Transform to [0, 0x7ffffffd] range. */
    x--;
      3e:	17fd                	addi	a5,a5,-1
    *ctx = x;
      40:	e11c                	sd	a5,0(a0)
    return (x);
}
      42:	0007851b          	sext.w	a0,a5
      46:	6422                	ld	s0,8(sp)
      48:	0141                	addi	sp,sp,16
      4a:	8082                	ret
        x += 0x7fffffff;
      4c:	80000737          	lui	a4,0x80000
      50:	fff74713          	not	a4,a4
      54:	97ba                	add	a5,a5,a4
      56:	b7e5                	j	3e <do_rand+0x3e>

0000000000000058 <rand>:

unsigned long rand_next = 1;

int
rand(void)
{
      58:	1141                	addi	sp,sp,-16
      5a:	e406                	sd	ra,8(sp)
      5c:	e022                	sd	s0,0(sp)
      5e:	0800                	addi	s0,sp,16
    return (do_rand(&rand_next));
      60:	00002517          	auipc	a0,0x2
      64:	fa050513          	addi	a0,a0,-96 # 2000 <rand_next>
      68:	f99ff0ef          	jal	0 <do_rand>
}
      6c:	60a2                	ld	ra,8(sp)
      6e:	6402                	ld	s0,0(sp)
      70:	0141                	addi	sp,sp,16
      72:	8082                	ret

0000000000000074 <go>:

void
go(int which_child)
{
      74:	7159                	addi	sp,sp,-112
      76:	f486                	sd	ra,104(sp)
      78:	f0a2                	sd	s0,96(sp)
      7a:	eca6                	sd	s1,88(sp)
      7c:	fc56                	sd	s5,56(sp)
      7e:	1880                	addi	s0,sp,112
      80:	84aa                	mv	s1,a0
  int fd = -1;
  static char buf[999];
  char *break0 = sbrk(0);
      82:	4501                	li	a0,0
      84:	2bb000ef          	jal	b3e <sbrk>
      88:	8aaa                	mv	s5,a0
  uint64 iters = 0;

  mkdir("grindir");
      8a:	00001517          	auipc	a0,0x1
      8e:	12650513          	addi	a0,a0,294 # 11b0 <malloc+0x104>
      92:	387000ef          	jal	c18 <mkdir>
  if(chdir("grindir") != 0){
      96:	00001517          	auipc	a0,0x1
      9a:	11a50513          	addi	a0,a0,282 # 11b0 <malloc+0x104>
      9e:	383000ef          	jal	c20 <chdir>
      a2:	cd11                	beqz	a0,be <go+0x4a>
      a4:	e8ca                	sd	s2,80(sp)
      a6:	e4ce                	sd	s3,72(sp)
      a8:	e0d2                	sd	s4,64(sp)
      aa:	f85a                	sd	s6,48(sp)
    printf("grind: chdir grindir failed\n");
      ac:	00001517          	auipc	a0,0x1
      b0:	10c50513          	addi	a0,a0,268 # 11b8 <malloc+0x10c>
      b4:	745000ef          	jal	ff8 <printf>
    exit(1);
      b8:	4505                	li	a0,1
      ba:	2f7000ef          	jal	bb0 <exit>
      be:	e8ca                	sd	s2,80(sp)
      c0:	e4ce                	sd	s3,72(sp)
      c2:	e0d2                	sd	s4,64(sp)
      c4:	f85a                	sd	s6,48(sp)
  }
  chdir("/");
      c6:	00001517          	auipc	a0,0x1
      ca:	11a50513          	addi	a0,a0,282 # 11e0 <malloc+0x134>
      ce:	353000ef          	jal	c20 <chdir>
      d2:	00001997          	auipc	s3,0x1
      d6:	11e98993          	addi	s3,s3,286 # 11f0 <malloc+0x144>
      da:	c489                	beqz	s1,e4 <go+0x70>
      dc:	00001997          	auipc	s3,0x1
      e0:	10c98993          	addi	s3,s3,268 # 11e8 <malloc+0x13c>
  uint64 iters = 0;
      e4:	4481                	li	s1,0
  int fd = -1;
      e6:	5a7d                	li	s4,-1
      e8:	00001917          	auipc	s2,0x1
      ec:	3d890913          	addi	s2,s2,984 # 14c0 <malloc+0x414>
      f0:	a819                	j	106 <go+0x92>
    iters++;
    if((iters % 500) == 0)
      write(1, which_child?"B":"A", 1);
    int what = rand() % 23;
    if(what == 1){
      close(open("grindir/../a", O_CREATE|O_RDWR));
      f2:	20200593          	li	a1,514
      f6:	00001517          	auipc	a0,0x1
      fa:	10250513          	addi	a0,a0,258 # 11f8 <malloc+0x14c>
      fe:	2f3000ef          	jal	bf0 <open>
     102:	2d7000ef          	jal	bd8 <close>
    iters++;
     106:	0485                	addi	s1,s1,1
    if((iters % 500) == 0)
     108:	1f400793          	li	a5,500
     10c:	02f4f7b3          	remu	a5,s1,a5
     110:	e791                	bnez	a5,11c <go+0xa8>
      write(1, which_child?"B":"A", 1);
     112:	4605                	li	a2,1
     114:	85ce                	mv	a1,s3
     116:	4505                	li	a0,1
     118:	2b9000ef          	jal	bd0 <write>
    int what = rand() % 23;
     11c:	f3dff0ef          	jal	58 <rand>
     120:	47dd                	li	a5,23
     122:	02f5653b          	remw	a0,a0,a5
     126:	0005071b          	sext.w	a4,a0
     12a:	47d9                	li	a5,22
     12c:	fce7ede3          	bltu	a5,a4,106 <go+0x92>
     130:	02051793          	slli	a5,a0,0x20
     134:	01e7d513          	srli	a0,a5,0x1e
     138:	954a                	add	a0,a0,s2
     13a:	411c                	lw	a5,0(a0)
     13c:	97ca                	add	a5,a5,s2
     13e:	8782                	jr	a5
    } else if(what == 2){
      close(open("grindir/../grindir/../b", O_CREATE|O_RDWR));
     140:	20200593          	li	a1,514
     144:	00001517          	auipc	a0,0x1
     148:	0c450513          	addi	a0,a0,196 # 1208 <malloc+0x15c>
     14c:	2a5000ef          	jal	bf0 <open>
     150:	289000ef          	jal	bd8 <close>
     154:	bf4d                	j	106 <go+0x92>
    } else if(what == 3){
      unlink("grindir/../a");
     156:	00001517          	auipc	a0,0x1
     15a:	0a250513          	addi	a0,a0,162 # 11f8 <malloc+0x14c>
     15e:	2a3000ef          	jal	c00 <unlink>
     162:	b755                	j	106 <go+0x92>
    } else if(what == 4){
      if(chdir("grindir") != 0){
     164:	00001517          	auipc	a0,0x1
     168:	04c50513          	addi	a0,a0,76 # 11b0 <malloc+0x104>
     16c:	2b5000ef          	jal	c20 <chdir>
     170:	ed11                	bnez	a0,18c <go+0x118>
        printf("grind: chdir grindir failed\n");
        exit(1);
      }
      unlink("../b");
     172:	00001517          	auipc	a0,0x1
     176:	0ae50513          	addi	a0,a0,174 # 1220 <malloc+0x174>
     17a:	287000ef          	jal	c00 <unlink>
      chdir("/");
     17e:	00001517          	auipc	a0,0x1
     182:	06250513          	addi	a0,a0,98 # 11e0 <malloc+0x134>
     186:	29b000ef          	jal	c20 <chdir>
     18a:	bfb5                	j	106 <go+0x92>
        printf("grind: chdir grindir failed\n");
     18c:	00001517          	auipc	a0,0x1
     190:	02c50513          	addi	a0,a0,44 # 11b8 <malloc+0x10c>
     194:	665000ef          	jal	ff8 <printf>
        exit(1);
     198:	4505                	li	a0,1
     19a:	217000ef          	jal	bb0 <exit>
    } else if(what == 5){
      close(fd);
     19e:	8552                	mv	a0,s4
     1a0:	239000ef          	jal	bd8 <close>
      fd = open("/grindir/../a", O_CREATE|O_RDWR);
     1a4:	20200593          	li	a1,514
     1a8:	00001517          	auipc	a0,0x1
     1ac:	08050513          	addi	a0,a0,128 # 1228 <malloc+0x17c>
     1b0:	241000ef          	jal	bf0 <open>
     1b4:	8a2a                	mv	s4,a0
     1b6:	bf81                	j	106 <go+0x92>
    } else if(what == 6){
      close(fd);
     1b8:	8552                	mv	a0,s4
     1ba:	21f000ef          	jal	bd8 <close>
      fd = open("/./grindir/./../b", O_CREATE|O_RDWR);
     1be:	20200593          	li	a1,514
     1c2:	00001517          	auipc	a0,0x1
     1c6:	07650513          	addi	a0,a0,118 # 1238 <malloc+0x18c>
     1ca:	227000ef          	jal	bf0 <open>
     1ce:	8a2a                	mv	s4,a0
     1d0:	bf1d                	j	106 <go+0x92>
    } else if(what == 7){
      write(fd, buf, sizeof(buf));
     1d2:	3e700613          	li	a2,999
     1d6:	00002597          	auipc	a1,0x2
     1da:	e4a58593          	addi	a1,a1,-438 # 2020 <buf.0>
     1de:	8552                	mv	a0,s4
     1e0:	1f1000ef          	jal	bd0 <write>
     1e4:	b70d                	j	106 <go+0x92>
    } else if(what == 8){
      read(fd, buf, sizeof(buf));
     1e6:	3e700613          	li	a2,999
     1ea:	00002597          	auipc	a1,0x2
     1ee:	e3658593          	addi	a1,a1,-458 # 2020 <buf.0>
     1f2:	8552                	mv	a0,s4
     1f4:	1d5000ef          	jal	bc8 <read>
     1f8:	b739                	j	106 <go+0x92>
    } else if(what == 9){
      mkdir("grindir/../a");
     1fa:	00001517          	auipc	a0,0x1
     1fe:	ffe50513          	addi	a0,a0,-2 # 11f8 <malloc+0x14c>
     202:	217000ef          	jal	c18 <mkdir>
      close(open("a/../a/./a", O_CREATE|O_RDWR));
     206:	20200593          	li	a1,514
     20a:	00001517          	auipc	a0,0x1
     20e:	04650513          	addi	a0,a0,70 # 1250 <malloc+0x1a4>
     212:	1df000ef          	jal	bf0 <open>
     216:	1c3000ef          	jal	bd8 <close>
      unlink("a/a");
     21a:	00001517          	auipc	a0,0x1
     21e:	04650513          	addi	a0,a0,70 # 1260 <malloc+0x1b4>
     222:	1df000ef          	jal	c00 <unlink>
     226:	b5c5                	j	106 <go+0x92>
    } else if(what == 10){
      mkdir("/../b");
     228:	00001517          	auipc	a0,0x1
     22c:	04050513          	addi	a0,a0,64 # 1268 <malloc+0x1bc>
     230:	1e9000ef          	jal	c18 <mkdir>
      close(open("grindir/../b/b", O_CREATE|O_RDWR));
     234:	20200593          	li	a1,514
     238:	00001517          	auipc	a0,0x1
     23c:	03850513          	addi	a0,a0,56 # 1270 <malloc+0x1c4>
     240:	1b1000ef          	jal	bf0 <open>
     244:	195000ef          	jal	bd8 <close>
      unlink("b/b");
     248:	00001517          	auipc	a0,0x1
     24c:	03850513          	addi	a0,a0,56 # 1280 <malloc+0x1d4>
     250:	1b1000ef          	jal	c00 <unlink>
     254:	bd4d                	j	106 <go+0x92>
    } else if(what == 11){
      unlink("b");
     256:	00001517          	auipc	a0,0x1
     25a:	03250513          	addi	a0,a0,50 # 1288 <malloc+0x1dc>
     25e:	1a3000ef          	jal	c00 <unlink>
      link("../grindir/./../a", "../b");
     262:	00001597          	auipc	a1,0x1
     266:	fbe58593          	addi	a1,a1,-66 # 1220 <malloc+0x174>
     26a:	00001517          	auipc	a0,0x1
     26e:	02650513          	addi	a0,a0,38 # 1290 <malloc+0x1e4>
     272:	19f000ef          	jal	c10 <link>
     276:	bd41                	j	106 <go+0x92>
    } else if(what == 12){
      unlink("../grindir/../a");
     278:	00001517          	auipc	a0,0x1
     27c:	03050513          	addi	a0,a0,48 # 12a8 <malloc+0x1fc>
     280:	181000ef          	jal	c00 <unlink>
      link(".././b", "/grindir/../a");
     284:	00001597          	auipc	a1,0x1
     288:	fa458593          	addi	a1,a1,-92 # 1228 <malloc+0x17c>
     28c:	00001517          	auipc	a0,0x1
     290:	02c50513          	addi	a0,a0,44 # 12b8 <malloc+0x20c>
     294:	17d000ef          	jal	c10 <link>
     298:	b5bd                	j	106 <go+0x92>
    } else if(what == 13){
      int pid = fork();
     29a:	10f000ef          	jal	ba8 <fork>
      if(pid == 0){
     29e:	c519                	beqz	a0,2ac <go+0x238>
        exit(0);
      } else if(pid < 0){
     2a0:	00054863          	bltz	a0,2b0 <go+0x23c>
        printf("grind: fork failed\n");
        exit(1);
      }
      wait(0);
     2a4:	4501                	li	a0,0
     2a6:	113000ef          	jal	bb8 <wait>
     2aa:	bdb1                	j	106 <go+0x92>
        exit(0);
     2ac:	105000ef          	jal	bb0 <exit>
        printf("grind: fork failed\n");
     2b0:	00001517          	auipc	a0,0x1
     2b4:	01050513          	addi	a0,a0,16 # 12c0 <malloc+0x214>
     2b8:	541000ef          	jal	ff8 <printf>
        exit(1);
     2bc:	4505                	li	a0,1
     2be:	0f3000ef          	jal	bb0 <exit>
    } else if(what == 14){
      int pid = fork();
     2c2:	0e7000ef          	jal	ba8 <fork>
      if(pid == 0){
     2c6:	c519                	beqz	a0,2d4 <go+0x260>
        fork();
        fork();
        exit(0);
      } else if(pid < 0){
     2c8:	00054d63          	bltz	a0,2e2 <go+0x26e>
        printf("grind: fork failed\n");
        exit(1);
      }
      wait(0);
     2cc:	4501                	li	a0,0
     2ce:	0eb000ef          	jal	bb8 <wait>
     2d2:	bd15                	j	106 <go+0x92>
        fork();
     2d4:	0d5000ef          	jal	ba8 <fork>
        fork();
     2d8:	0d1000ef          	jal	ba8 <fork>
        exit(0);
     2dc:	4501                	li	a0,0
     2de:	0d3000ef          	jal	bb0 <exit>
        printf("grind: fork failed\n");
     2e2:	00001517          	auipc	a0,0x1
     2e6:	fde50513          	addi	a0,a0,-34 # 12c0 <malloc+0x214>
     2ea:	50f000ef          	jal	ff8 <printf>
        exit(1);
     2ee:	4505                	li	a0,1
     2f0:	0c1000ef          	jal	bb0 <exit>
    } else if(what == 15){
      sbrk(6011);
     2f4:	6505                	lui	a0,0x1
     2f6:	77b50513          	addi	a0,a0,1915 # 177b <digits+0x25b>
     2fa:	045000ef          	jal	b3e <sbrk>
     2fe:	b521                	j	106 <go+0x92>
    } else if(what == 16){
      if(sbrk(0) > break0)
     300:	4501                	li	a0,0
     302:	03d000ef          	jal	b3e <sbrk>
     306:	e0aaf0e3          	bgeu	s5,a0,106 <go+0x92>
        sbrk(-(sbrk(0) - break0));
     30a:	4501                	li	a0,0
     30c:	033000ef          	jal	b3e <sbrk>
     310:	40aa853b          	subw	a0,s5,a0
     314:	02b000ef          	jal	b3e <sbrk>
     318:	b3fd                	j	106 <go+0x92>
    } else if(what == 17){
      int pid = fork();
     31a:	08f000ef          	jal	ba8 <fork>
     31e:	8b2a                	mv	s6,a0
      if(pid == 0){
     320:	c10d                	beqz	a0,342 <go+0x2ce>
        close(open("a", O_CREATE|O_RDWR));
        exit(0);
      } else if(pid < 0){
     322:	02054d63          	bltz	a0,35c <go+0x2e8>
        printf("grind: fork failed\n");
        exit(1);
      }
      if(chdir("../grindir/..") != 0){
     326:	00001517          	auipc	a0,0x1
     32a:	fba50513          	addi	a0,a0,-70 # 12e0 <malloc+0x234>
     32e:	0f3000ef          	jal	c20 <chdir>
     332:	ed15                	bnez	a0,36e <go+0x2fa>
        printf("grind: chdir failed\n");
        exit(1);
      }
      kill(pid);
     334:	855a                	mv	a0,s6
     336:	0ab000ef          	jal	be0 <kill>
      wait(0);
     33a:	4501                	li	a0,0
     33c:	07d000ef          	jal	bb8 <wait>
     340:	b3d9                	j	106 <go+0x92>
        close(open("a", O_CREATE|O_RDWR));
     342:	20200593          	li	a1,514
     346:	00001517          	auipc	a0,0x1
     34a:	f9250513          	addi	a0,a0,-110 # 12d8 <malloc+0x22c>
     34e:	0a3000ef          	jal	bf0 <open>
     352:	087000ef          	jal	bd8 <close>
        exit(0);
     356:	4501                	li	a0,0
     358:	059000ef          	jal	bb0 <exit>
        printf("grind: fork failed\n");
     35c:	00001517          	auipc	a0,0x1
     360:	f6450513          	addi	a0,a0,-156 # 12c0 <malloc+0x214>
     364:	495000ef          	jal	ff8 <printf>
        exit(1);
     368:	4505                	li	a0,1
     36a:	047000ef          	jal	bb0 <exit>
        printf("grind: chdir failed\n");
     36e:	00001517          	auipc	a0,0x1
     372:	f8250513          	addi	a0,a0,-126 # 12f0 <malloc+0x244>
     376:	483000ef          	jal	ff8 <printf>
        exit(1);
     37a:	4505                	li	a0,1
     37c:	035000ef          	jal	bb0 <exit>
    } else if(what == 18){
      int pid = fork();
     380:	029000ef          	jal	ba8 <fork>
      if(pid == 0){
     384:	c519                	beqz	a0,392 <go+0x31e>
        kill(getpid());
        exit(0);
      } else if(pid < 0){
     386:	00054d63          	bltz	a0,3a0 <go+0x32c>
        printf("grind: fork failed\n");
        exit(1);
      }
      wait(0);
     38a:	4501                	li	a0,0
     38c:	02d000ef          	jal	bb8 <wait>
     390:	bb9d                	j	106 <go+0x92>
        kill(getpid());
     392:	09f000ef          	jal	c30 <getpid>
     396:	04b000ef          	jal	be0 <kill>
        exit(0);
     39a:	4501                	li	a0,0
     39c:	015000ef          	jal	bb0 <exit>
        printf("grind: fork failed\n");
     3a0:	00001517          	auipc	a0,0x1
     3a4:	f2050513          	addi	a0,a0,-224 # 12c0 <malloc+0x214>
     3a8:	451000ef          	jal	ff8 <printf>
        exit(1);
     3ac:	4505                	li	a0,1
     3ae:	003000ef          	jal	bb0 <exit>
    } else if(what == 19){
      int fds[2];
      if(pipe(fds) < 0){
     3b2:	fa840513          	addi	a0,s0,-88
     3b6:	00b000ef          	jal	bc0 <pipe>
     3ba:	02054363          	bltz	a0,3e0 <go+0x36c>
        printf("grind: pipe failed\n");
        exit(1);
      }
      int pid = fork();
     3be:	7ea000ef          	jal	ba8 <fork>
      if(pid == 0){
     3c2:	c905                	beqz	a0,3f2 <go+0x37e>
          printf("grind: pipe write failed\n");
        char c;
        if(read(fds[0], &c, 1) != 1)
          printf("grind: pipe read failed\n");
        exit(0);
      } else if(pid < 0){
     3c4:	08054263          	bltz	a0,448 <go+0x3d4>
        printf("grind: fork failed\n");
        exit(1);
      }
      close(fds[0]);
     3c8:	fa842503          	lw	a0,-88(s0)
     3cc:	00d000ef          	jal	bd8 <close>
      close(fds[1]);
     3d0:	fac42503          	lw	a0,-84(s0)
     3d4:	005000ef          	jal	bd8 <close>
      wait(0);
     3d8:	4501                	li	a0,0
     3da:	7de000ef          	jal	bb8 <wait>
     3de:	b325                	j	106 <go+0x92>
        printf("grind: pipe failed\n");
     3e0:	00001517          	auipc	a0,0x1
     3e4:	f2850513          	addi	a0,a0,-216 # 1308 <malloc+0x25c>
     3e8:	411000ef          	jal	ff8 <printf>
        exit(1);
     3ec:	4505                	li	a0,1
     3ee:	7c2000ef          	jal	bb0 <exit>
        fork();
     3f2:	7b6000ef          	jal	ba8 <fork>
        fork();
     3f6:	7b2000ef          	jal	ba8 <fork>
        if(write(fds[1], "x", 1) != 1)
     3fa:	4605                	li	a2,1
     3fc:	00001597          	auipc	a1,0x1
     400:	f2458593          	addi	a1,a1,-220 # 1320 <malloc+0x274>
     404:	fac42503          	lw	a0,-84(s0)
     408:	7c8000ef          	jal	bd0 <write>
     40c:	4785                	li	a5,1
     40e:	00f51f63          	bne	a0,a5,42c <go+0x3b8>
        if(read(fds[0], &c, 1) != 1)
     412:	4605                	li	a2,1
     414:	fa040593          	addi	a1,s0,-96
     418:	fa842503          	lw	a0,-88(s0)
     41c:	7ac000ef          	jal	bc8 <read>
     420:	4785                	li	a5,1
     422:	00f51c63          	bne	a0,a5,43a <go+0x3c6>
        exit(0);
     426:	4501                	li	a0,0
     428:	788000ef          	jal	bb0 <exit>
          printf("grind: pipe write failed\n");
     42c:	00001517          	auipc	a0,0x1
     430:	efc50513          	addi	a0,a0,-260 # 1328 <malloc+0x27c>
     434:	3c5000ef          	jal	ff8 <printf>
     438:	bfe9                	j	412 <go+0x39e>
          printf("grind: pipe read failed\n");
     43a:	00001517          	auipc	a0,0x1
     43e:	f0e50513          	addi	a0,a0,-242 # 1348 <malloc+0x29c>
     442:	3b7000ef          	jal	ff8 <printf>
     446:	b7c5                	j	426 <go+0x3b2>
        printf("grind: fork failed\n");
     448:	00001517          	auipc	a0,0x1
     44c:	e7850513          	addi	a0,a0,-392 # 12c0 <malloc+0x214>
     450:	3a9000ef          	jal	ff8 <printf>
        exit(1);
     454:	4505                	li	a0,1
     456:	75a000ef          	jal	bb0 <exit>
    } else if(what == 20){
      int pid = fork();
     45a:	74e000ef          	jal	ba8 <fork>
      if(pid == 0){
     45e:	c519                	beqz	a0,46c <go+0x3f8>
        chdir("a");
        unlink("../a");
        fd = open("x", O_CREATE|O_RDWR);
        unlink("x");
        exit(0);
      } else if(pid < 0){
     460:	04054f63          	bltz	a0,4be <go+0x44a>
        printf("grind: fork failed\n");
        exit(1);
      }
      wait(0);
     464:	4501                	li	a0,0
     466:	752000ef          	jal	bb8 <wait>
     46a:	b971                	j	106 <go+0x92>
        unlink("a");
     46c:	00001517          	auipc	a0,0x1
     470:	e6c50513          	addi	a0,a0,-404 # 12d8 <malloc+0x22c>
     474:	78c000ef          	jal	c00 <unlink>
        mkdir("a");
     478:	00001517          	auipc	a0,0x1
     47c:	e6050513          	addi	a0,a0,-416 # 12d8 <malloc+0x22c>
     480:	798000ef          	jal	c18 <mkdir>
        chdir("a");
     484:	00001517          	auipc	a0,0x1
     488:	e5450513          	addi	a0,a0,-428 # 12d8 <malloc+0x22c>
     48c:	794000ef          	jal	c20 <chdir>
        unlink("../a");
     490:	00001517          	auipc	a0,0x1
     494:	ed850513          	addi	a0,a0,-296 # 1368 <malloc+0x2bc>
     498:	768000ef          	jal	c00 <unlink>
        fd = open("x", O_CREATE|O_RDWR);
     49c:	20200593          	li	a1,514
     4a0:	00001517          	auipc	a0,0x1
     4a4:	e8050513          	addi	a0,a0,-384 # 1320 <malloc+0x274>
     4a8:	748000ef          	jal	bf0 <open>
        unlink("x");
     4ac:	00001517          	auipc	a0,0x1
     4b0:	e7450513          	addi	a0,a0,-396 # 1320 <malloc+0x274>
     4b4:	74c000ef          	jal	c00 <unlink>
        exit(0);
     4b8:	4501                	li	a0,0
     4ba:	6f6000ef          	jal	bb0 <exit>
        printf("grind: fork failed\n");
     4be:	00001517          	auipc	a0,0x1
     4c2:	e0250513          	addi	a0,a0,-510 # 12c0 <malloc+0x214>
     4c6:	333000ef          	jal	ff8 <printf>
        exit(1);
     4ca:	4505                	li	a0,1
     4cc:	6e4000ef          	jal	bb0 <exit>
    } else if(what == 21){
      unlink("c");
     4d0:	00001517          	auipc	a0,0x1
     4d4:	ea050513          	addi	a0,a0,-352 # 1370 <malloc+0x2c4>
     4d8:	728000ef          	jal	c00 <unlink>
      // should always succeed. check that there are free i-nodes,
      // file descriptors, blocks.
      int fd1 = open("c", O_CREATE|O_RDWR);
     4dc:	20200593          	li	a1,514
     4e0:	00001517          	auipc	a0,0x1
     4e4:	e9050513          	addi	a0,a0,-368 # 1370 <malloc+0x2c4>
     4e8:	708000ef          	jal	bf0 <open>
     4ec:	8b2a                	mv	s6,a0
      if(fd1 < 0){
     4ee:	04054763          	bltz	a0,53c <go+0x4c8>
        printf("grind: create c failed\n");
        exit(1);
      }
      if(write(fd1, "x", 1) != 1){
     4f2:	4605                	li	a2,1
     4f4:	00001597          	auipc	a1,0x1
     4f8:	e2c58593          	addi	a1,a1,-468 # 1320 <malloc+0x274>
     4fc:	6d4000ef          	jal	bd0 <write>
     500:	4785                	li	a5,1
     502:	04f51663          	bne	a0,a5,54e <go+0x4da>
        printf("grind: write c failed\n");
        exit(1);
      }
      struct stat st;
      if(fstat(fd1, &st) != 0){
     506:	fa840593          	addi	a1,s0,-88
     50a:	855a                	mv	a0,s6
     50c:	6fc000ef          	jal	c08 <fstat>
     510:	e921                	bnez	a0,560 <go+0x4ec>
        printf("grind: fstat failed\n");
        exit(1);
      }
      if(st.size != 1){
     512:	fb843583          	ld	a1,-72(s0)
     516:	4785                	li	a5,1
     518:	04f59d63          	bne	a1,a5,572 <go+0x4fe>
        printf("grind: fstat reports wrong size %d\n", (int)st.size);
        exit(1);
      }
      if(st.ino > 200){
     51c:	fac42583          	lw	a1,-84(s0)
     520:	0c800793          	li	a5,200
     524:	06b7e163          	bltu	a5,a1,586 <go+0x512>
        printf("grind: fstat reports crazy i-number %d\n", st.ino);
        exit(1);
      }
      close(fd1);
     528:	855a                	mv	a0,s6
     52a:	6ae000ef          	jal	bd8 <close>
      unlink("c");
     52e:	00001517          	auipc	a0,0x1
     532:	e4250513          	addi	a0,a0,-446 # 1370 <malloc+0x2c4>
     536:	6ca000ef          	jal	c00 <unlink>
     53a:	b6f1                	j	106 <go+0x92>
        printf("grind: create c failed\n");
     53c:	00001517          	auipc	a0,0x1
     540:	e3c50513          	addi	a0,a0,-452 # 1378 <malloc+0x2cc>
     544:	2b5000ef          	jal	ff8 <printf>
        exit(1);
     548:	4505                	li	a0,1
     54a:	666000ef          	jal	bb0 <exit>
        printf("grind: write c failed\n");
     54e:	00001517          	auipc	a0,0x1
     552:	e4250513          	addi	a0,a0,-446 # 1390 <malloc+0x2e4>
     556:	2a3000ef          	jal	ff8 <printf>
        exit(1);
     55a:	4505                	li	a0,1
     55c:	654000ef          	jal	bb0 <exit>
        printf("grind: fstat failed\n");
     560:	00001517          	auipc	a0,0x1
     564:	e4850513          	addi	a0,a0,-440 # 13a8 <malloc+0x2fc>
     568:	291000ef          	jal	ff8 <printf>
        exit(1);
     56c:	4505                	li	a0,1
     56e:	642000ef          	jal	bb0 <exit>
        printf("grind: fstat reports wrong size %d\n", (int)st.size);
     572:	2581                	sext.w	a1,a1
     574:	00001517          	auipc	a0,0x1
     578:	e4c50513          	addi	a0,a0,-436 # 13c0 <malloc+0x314>
     57c:	27d000ef          	jal	ff8 <printf>
        exit(1);
     580:	4505                	li	a0,1
     582:	62e000ef          	jal	bb0 <exit>
        printf("grind: fstat reports crazy i-number %d\n", st.ino);
     586:	00001517          	auipc	a0,0x1
     58a:	e6250513          	addi	a0,a0,-414 # 13e8 <malloc+0x33c>
     58e:	26b000ef          	jal	ff8 <printf>
        exit(1);
     592:	4505                	li	a0,1
     594:	61c000ef          	jal	bb0 <exit>
    } else if(what == 22){
      // echo hi | cat
      int aa[2], bb[2];
      if(pipe(aa) < 0){
     598:	f9840513          	addi	a0,s0,-104
     59c:	624000ef          	jal	bc0 <pipe>
     5a0:	0c054263          	bltz	a0,664 <go+0x5f0>
        fprintf(2, "grind: pipe failed\n");
        exit(1);
      }
      if(pipe(bb) < 0){
     5a4:	fa040513          	addi	a0,s0,-96
     5a8:	618000ef          	jal	bc0 <pipe>
     5ac:	0c054663          	bltz	a0,678 <go+0x604>
        fprintf(2, "grind: pipe failed\n");
        exit(1);
      }
      int pid1 = fork();
     5b0:	5f8000ef          	jal	ba8 <fork>
      if(pid1 == 0){
     5b4:	0c050c63          	beqz	a0,68c <go+0x618>
        close(aa[1]);
        char *args[3] = { "echo", "hi", 0 };
        exec("grindir/../echo", args);
        fprintf(2, "grind: echo: not found\n");
        exit(2);
      } else if(pid1 < 0){
     5b8:	14054e63          	bltz	a0,714 <go+0x6a0>
        fprintf(2, "grind: fork failed\n");
        exit(3);
      }
      int pid2 = fork();
     5bc:	5ec000ef          	jal	ba8 <fork>
      if(pid2 == 0){
     5c0:	16050463          	beqz	a0,728 <go+0x6b4>
        close(bb[1]);
        char *args[2] = { "cat", 0 };
        exec("/cat", args);
        fprintf(2, "grind: cat: not found\n");
        exit(6);
      } else if(pid2 < 0){
     5c4:	20054263          	bltz	a0,7c8 <go+0x754>
        fprintf(2, "grind: fork failed\n");
        exit(7);
      }
      close(aa[0]);
     5c8:	f9842503          	lw	a0,-104(s0)
     5cc:	60c000ef          	jal	bd8 <close>
      close(aa[1]);
     5d0:	f9c42503          	lw	a0,-100(s0)
     5d4:	604000ef          	jal	bd8 <close>
      close(bb[1]);
     5d8:	fa442503          	lw	a0,-92(s0)
     5dc:	5fc000ef          	jal	bd8 <close>
      char buf[4] = { 0, 0, 0, 0 };
     5e0:	f8042823          	sw	zero,-112(s0)
      read(bb[0], buf+0, 1);
     5e4:	4605                	li	a2,1
     5e6:	f9040593          	addi	a1,s0,-112
     5ea:	fa042503          	lw	a0,-96(s0)
     5ee:	5da000ef          	jal	bc8 <read>
      read(bb[0], buf+1, 1);
     5f2:	4605                	li	a2,1
     5f4:	f9140593          	addi	a1,s0,-111
     5f8:	fa042503          	lw	a0,-96(s0)
     5fc:	5cc000ef          	jal	bc8 <read>
      read(bb[0], buf+2, 1);
     600:	4605                	li	a2,1
     602:	f9240593          	addi	a1,s0,-110
     606:	fa042503          	lw	a0,-96(s0)
     60a:	5be000ef          	jal	bc8 <read>
      close(bb[0]);
     60e:	fa042503          	lw	a0,-96(s0)
     612:	5c6000ef          	jal	bd8 <close>
      int st1, st2;
      wait(&st1);
     616:	f9440513          	addi	a0,s0,-108
     61a:	59e000ef          	jal	bb8 <wait>
      wait(&st2);
     61e:	fa840513          	addi	a0,s0,-88
     622:	596000ef          	jal	bb8 <wait>
      if(st1 != 0 || st2 != 0 || strcmp(buf, "hi\n") != 0){
     626:	f9442783          	lw	a5,-108(s0)
     62a:	fa842703          	lw	a4,-88(s0)
     62e:	8fd9                	or	a5,a5,a4
     630:	eb99                	bnez	a5,646 <go+0x5d2>
     632:	00001597          	auipc	a1,0x1
     636:	e5658593          	addi	a1,a1,-426 # 1488 <malloc+0x3dc>
     63a:	f9040513          	addi	a0,s0,-112
     63e:	2cc000ef          	jal	90a <strcmp>
     642:	ac0502e3          	beqz	a0,106 <go+0x92>
        printf("grind: exec pipeline failed %d %d \"%s\"\n", st1, st2, buf);
     646:	f9040693          	addi	a3,s0,-112
     64a:	fa842603          	lw	a2,-88(s0)
     64e:	f9442583          	lw	a1,-108(s0)
     652:	00001517          	auipc	a0,0x1
     656:	e3e50513          	addi	a0,a0,-450 # 1490 <malloc+0x3e4>
     65a:	19f000ef          	jal	ff8 <printf>
        exit(1);
     65e:	4505                	li	a0,1
     660:	550000ef          	jal	bb0 <exit>
        fprintf(2, "grind: pipe failed\n");
     664:	00001597          	auipc	a1,0x1
     668:	ca458593          	addi	a1,a1,-860 # 1308 <malloc+0x25c>
     66c:	4509                	li	a0,2
     66e:	161000ef          	jal	fce <fprintf>
        exit(1);
     672:	4505                	li	a0,1
     674:	53c000ef          	jal	bb0 <exit>
        fprintf(2, "grind: pipe failed\n");
     678:	00001597          	auipc	a1,0x1
     67c:	c9058593          	addi	a1,a1,-880 # 1308 <malloc+0x25c>
     680:	4509                	li	a0,2
     682:	14d000ef          	jal	fce <fprintf>
        exit(1);
     686:	4505                	li	a0,1
     688:	528000ef          	jal	bb0 <exit>
        close(bb[0]);
     68c:	fa042503          	lw	a0,-96(s0)
     690:	548000ef          	jal	bd8 <close>
        close(bb[1]);
     694:	fa442503          	lw	a0,-92(s0)
     698:	540000ef          	jal	bd8 <close>
        close(aa[0]);
     69c:	f9842503          	lw	a0,-104(s0)
     6a0:	538000ef          	jal	bd8 <close>
        close(1);
     6a4:	4505                	li	a0,1
     6a6:	532000ef          	jal	bd8 <close>
        if(dup(aa[1]) != 1){
     6aa:	f9c42503          	lw	a0,-100(s0)
     6ae:	57a000ef          	jal	c28 <dup>
     6b2:	4785                	li	a5,1
     6b4:	00f50c63          	beq	a0,a5,6cc <go+0x658>
          fprintf(2, "grind: dup failed\n");
     6b8:	00001597          	auipc	a1,0x1
     6bc:	d5858593          	addi	a1,a1,-680 # 1410 <malloc+0x364>
     6c0:	4509                	li	a0,2
     6c2:	10d000ef          	jal	fce <fprintf>
          exit(1);
     6c6:	4505                	li	a0,1
     6c8:	4e8000ef          	jal	bb0 <exit>
        close(aa[1]);
     6cc:	f9c42503          	lw	a0,-100(s0)
     6d0:	508000ef          	jal	bd8 <close>
        char *args[3] = { "echo", "hi", 0 };
     6d4:	00001797          	auipc	a5,0x1
     6d8:	d5478793          	addi	a5,a5,-684 # 1428 <malloc+0x37c>
     6dc:	faf43423          	sd	a5,-88(s0)
     6e0:	00001797          	auipc	a5,0x1
     6e4:	d5078793          	addi	a5,a5,-688 # 1430 <malloc+0x384>
     6e8:	faf43823          	sd	a5,-80(s0)
     6ec:	fa043c23          	sd	zero,-72(s0)
        exec("grindir/../echo", args);
     6f0:	fa840593          	addi	a1,s0,-88
     6f4:	00001517          	auipc	a0,0x1
     6f8:	d4450513          	addi	a0,a0,-700 # 1438 <malloc+0x38c>
     6fc:	4ec000ef          	jal	be8 <exec>
        fprintf(2, "grind: echo: not found\n");
     700:	00001597          	auipc	a1,0x1
     704:	d4858593          	addi	a1,a1,-696 # 1448 <malloc+0x39c>
     708:	4509                	li	a0,2
     70a:	0c5000ef          	jal	fce <fprintf>
        exit(2);
     70e:	4509                	li	a0,2
     710:	4a0000ef          	jal	bb0 <exit>
        fprintf(2, "grind: fork failed\n");
     714:	00001597          	auipc	a1,0x1
     718:	bac58593          	addi	a1,a1,-1108 # 12c0 <malloc+0x214>
     71c:	4509                	li	a0,2
     71e:	0b1000ef          	jal	fce <fprintf>
        exit(3);
     722:	450d                	li	a0,3
     724:	48c000ef          	jal	bb0 <exit>
        close(aa[1]);
     728:	f9c42503          	lw	a0,-100(s0)
     72c:	4ac000ef          	jal	bd8 <close>
        close(bb[0]);
     730:	fa042503          	lw	a0,-96(s0)
     734:	4a4000ef          	jal	bd8 <close>
        close(0);
     738:	4501                	li	a0,0
     73a:	49e000ef          	jal	bd8 <close>
        if(dup(aa[0]) != 0){
     73e:	f9842503          	lw	a0,-104(s0)
     742:	4e6000ef          	jal	c28 <dup>
     746:	c919                	beqz	a0,75c <go+0x6e8>
          fprintf(2, "grind: dup failed\n");
     748:	00001597          	auipc	a1,0x1
     74c:	cc858593          	addi	a1,a1,-824 # 1410 <malloc+0x364>
     750:	4509                	li	a0,2
     752:	07d000ef          	jal	fce <fprintf>
          exit(4);
     756:	4511                	li	a0,4
     758:	458000ef          	jal	bb0 <exit>
        close(aa[0]);
     75c:	f9842503          	lw	a0,-104(s0)
     760:	478000ef          	jal	bd8 <close>
        close(1);
     764:	4505                	li	a0,1
     766:	472000ef          	jal	bd8 <close>
        if(dup(bb[1]) != 1){
     76a:	fa442503          	lw	a0,-92(s0)
     76e:	4ba000ef          	jal	c28 <dup>
     772:	4785                	li	a5,1
     774:	00f50c63          	beq	a0,a5,78c <go+0x718>
          fprintf(2, "grind: dup failed\n");
     778:	00001597          	auipc	a1,0x1
     77c:	c9858593          	addi	a1,a1,-872 # 1410 <malloc+0x364>
     780:	4509                	li	a0,2
     782:	04d000ef          	jal	fce <fprintf>
          exit(5);
     786:	4515                	li	a0,5
     788:	428000ef          	jal	bb0 <exit>
        close(bb[1]);
     78c:	fa442503          	lw	a0,-92(s0)
     790:	448000ef          	jal	bd8 <close>
        char *args[2] = { "cat", 0 };
     794:	00001797          	auipc	a5,0x1
     798:	ccc78793          	addi	a5,a5,-820 # 1460 <malloc+0x3b4>
     79c:	faf43423          	sd	a5,-88(s0)
     7a0:	fa043823          	sd	zero,-80(s0)
        exec("/cat", args);
     7a4:	fa840593          	addi	a1,s0,-88
     7a8:	00001517          	auipc	a0,0x1
     7ac:	cc050513          	addi	a0,a0,-832 # 1468 <malloc+0x3bc>
     7b0:	438000ef          	jal	be8 <exec>
        fprintf(2, "grind: cat: not found\n");
     7b4:	00001597          	auipc	a1,0x1
     7b8:	cbc58593          	addi	a1,a1,-836 # 1470 <malloc+0x3c4>
     7bc:	4509                	li	a0,2
     7be:	011000ef          	jal	fce <fprintf>
        exit(6);
     7c2:	4519                	li	a0,6
     7c4:	3ec000ef          	jal	bb0 <exit>
        fprintf(2, "grind: fork failed\n");
     7c8:	00001597          	auipc	a1,0x1
     7cc:	af858593          	addi	a1,a1,-1288 # 12c0 <malloc+0x214>
     7d0:	4509                	li	a0,2
     7d2:	7fc000ef          	jal	fce <fprintf>
        exit(7);
     7d6:	451d                	li	a0,7
     7d8:	3d8000ef          	jal	bb0 <exit>

00000000000007dc <iter>:
  }
}

void
iter()
{
     7dc:	7179                	addi	sp,sp,-48
     7de:	f406                	sd	ra,40(sp)
     7e0:	f022                	sd	s0,32(sp)
     7e2:	1800                	addi	s0,sp,48
  unlink("a");
     7e4:	00001517          	auipc	a0,0x1
     7e8:	af450513          	addi	a0,a0,-1292 # 12d8 <malloc+0x22c>
     7ec:	414000ef          	jal	c00 <unlink>
  unlink("b");
     7f0:	00001517          	auipc	a0,0x1
     7f4:	a9850513          	addi	a0,a0,-1384 # 1288 <malloc+0x1dc>
     7f8:	408000ef          	jal	c00 <unlink>
  
  int pid1 = fork();
     7fc:	3ac000ef          	jal	ba8 <fork>
  if(pid1 < 0){
     800:	02054163          	bltz	a0,822 <iter+0x46>
     804:	ec26                	sd	s1,24(sp)
     806:	84aa                	mv	s1,a0
    printf("grind: fork failed\n");
    exit(1);
  }
  if(pid1 == 0){
     808:	e905                	bnez	a0,838 <iter+0x5c>
     80a:	e84a                	sd	s2,16(sp)
    rand_next ^= 31;
     80c:	00001717          	auipc	a4,0x1
     810:	7f470713          	addi	a4,a4,2036 # 2000 <rand_next>
     814:	631c                	ld	a5,0(a4)
     816:	01f7c793          	xori	a5,a5,31
     81a:	e31c                	sd	a5,0(a4)
    go(0);
     81c:	4501                	li	a0,0
     81e:	857ff0ef          	jal	74 <go>
     822:	ec26                	sd	s1,24(sp)
     824:	e84a                	sd	s2,16(sp)
    printf("grind: fork failed\n");
     826:	00001517          	auipc	a0,0x1
     82a:	a9a50513          	addi	a0,a0,-1382 # 12c0 <malloc+0x214>
     82e:	7ca000ef          	jal	ff8 <printf>
    exit(1);
     832:	4505                	li	a0,1
     834:	37c000ef          	jal	bb0 <exit>
     838:	e84a                	sd	s2,16(sp)
    exit(0);
  }

  int pid2 = fork();
     83a:	36e000ef          	jal	ba8 <fork>
     83e:	892a                	mv	s2,a0
  if(pid2 < 0){
     840:	02054063          	bltz	a0,860 <iter+0x84>
    printf("grind: fork failed\n");
    exit(1);
  }
  if(pid2 == 0){
     844:	e51d                	bnez	a0,872 <iter+0x96>
    rand_next ^= 7177;
     846:	00001697          	auipc	a3,0x1
     84a:	7ba68693          	addi	a3,a3,1978 # 2000 <rand_next>
     84e:	629c                	ld	a5,0(a3)
     850:	6709                	lui	a4,0x2
     852:	c0970713          	addi	a4,a4,-1015 # 1c09 <digits+0x6e9>
     856:	8fb9                	xor	a5,a5,a4
     858:	e29c                	sd	a5,0(a3)
    go(1);
     85a:	4505                	li	a0,1
     85c:	819ff0ef          	jal	74 <go>
    printf("grind: fork failed\n");
     860:	00001517          	auipc	a0,0x1
     864:	a6050513          	addi	a0,a0,-1440 # 12c0 <malloc+0x214>
     868:	790000ef          	jal	ff8 <printf>
    exit(1);
     86c:	4505                	li	a0,1
     86e:	342000ef          	jal	bb0 <exit>
    exit(0);
  }

  int st1 = -1;
     872:	57fd                	li	a5,-1
     874:	fcf42e23          	sw	a5,-36(s0)
  wait(&st1);
     878:	fdc40513          	addi	a0,s0,-36
     87c:	33c000ef          	jal	bb8 <wait>
  if(st1 != 0){
     880:	fdc42783          	lw	a5,-36(s0)
     884:	eb99                	bnez	a5,89a <iter+0xbe>
    kill(pid1);
    kill(pid2);
  }
  int st2 = -1;
     886:	57fd                	li	a5,-1
     888:	fcf42c23          	sw	a5,-40(s0)
  wait(&st2);
     88c:	fd840513          	addi	a0,s0,-40
     890:	328000ef          	jal	bb8 <wait>

  exit(0);
     894:	4501                	li	a0,0
     896:	31a000ef          	jal	bb0 <exit>
    kill(pid1);
     89a:	8526                	mv	a0,s1
     89c:	344000ef          	jal	be0 <kill>
    kill(pid2);
     8a0:	854a                	mv	a0,s2
     8a2:	33e000ef          	jal	be0 <kill>
     8a6:	b7c5                	j	886 <iter+0xaa>

00000000000008a8 <main>:
}

int
main()
{
     8a8:	1101                	addi	sp,sp,-32
     8aa:	ec06                	sd	ra,24(sp)
     8ac:	e822                	sd	s0,16(sp)
     8ae:	e426                	sd	s1,8(sp)
     8b0:	1000                	addi	s0,sp,32
    }
    if(pid > 0){
      wait(0);
    }
    pause(20);
    rand_next += 1;
     8b2:	00001497          	auipc	s1,0x1
     8b6:	74e48493          	addi	s1,s1,1870 # 2000 <rand_next>
     8ba:	a809                	j	8cc <main+0x24>
      iter();
     8bc:	f21ff0ef          	jal	7dc <iter>
    pause(20);
     8c0:	4551                	li	a0,20
     8c2:	37e000ef          	jal	c40 <pause>
    rand_next += 1;
     8c6:	609c                	ld	a5,0(s1)
     8c8:	0785                	addi	a5,a5,1
     8ca:	e09c                	sd	a5,0(s1)
    int pid = fork();
     8cc:	2dc000ef          	jal	ba8 <fork>
    if(pid == 0){
     8d0:	d575                	beqz	a0,8bc <main+0x14>
    if(pid > 0){
     8d2:	fea057e3          	blez	a0,8c0 <main+0x18>
      wait(0);
     8d6:	4501                	li	a0,0
     8d8:	2e0000ef          	jal	bb8 <wait>
     8dc:	b7d5                	j	8c0 <main+0x18>

00000000000008de <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start(int argc, char **argv)
{
     8de:	1141                	addi	sp,sp,-16
     8e0:	e406                	sd	ra,8(sp)
     8e2:	e022                	sd	s0,0(sp)
     8e4:	0800                	addi	s0,sp,16
  int r;
  extern int main(int argc, char **argv);
  r = main(argc, argv);
     8e6:	fc3ff0ef          	jal	8a8 <main>
  exit(r);
     8ea:	2c6000ef          	jal	bb0 <exit>

00000000000008ee <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
     8ee:	1141                	addi	sp,sp,-16
     8f0:	e422                	sd	s0,8(sp)
     8f2:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
     8f4:	87aa                	mv	a5,a0
     8f6:	0585                	addi	a1,a1,1
     8f8:	0785                	addi	a5,a5,1
     8fa:	fff5c703          	lbu	a4,-1(a1)
     8fe:	fee78fa3          	sb	a4,-1(a5)
     902:	fb75                	bnez	a4,8f6 <strcpy+0x8>
    ;
  return os;
}
     904:	6422                	ld	s0,8(sp)
     906:	0141                	addi	sp,sp,16
     908:	8082                	ret

000000000000090a <strcmp>:

int
strcmp(const char *p, const char *q)
{
     90a:	1141                	addi	sp,sp,-16
     90c:	e422                	sd	s0,8(sp)
     90e:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
     910:	00054783          	lbu	a5,0(a0)
     914:	cb91                	beqz	a5,928 <strcmp+0x1e>
     916:	0005c703          	lbu	a4,0(a1)
     91a:	00f71763          	bne	a4,a5,928 <strcmp+0x1e>
    p++, q++;
     91e:	0505                	addi	a0,a0,1
     920:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
     922:	00054783          	lbu	a5,0(a0)
     926:	fbe5                	bnez	a5,916 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
     928:	0005c503          	lbu	a0,0(a1)
}
     92c:	40a7853b          	subw	a0,a5,a0
     930:	6422                	ld	s0,8(sp)
     932:	0141                	addi	sp,sp,16
     934:	8082                	ret

0000000000000936 <strlen>:

uint
strlen(const char *s)
{
     936:	1141                	addi	sp,sp,-16
     938:	e422                	sd	s0,8(sp)
     93a:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
     93c:	00054783          	lbu	a5,0(a0)
     940:	cf91                	beqz	a5,95c <strlen+0x26>
     942:	0505                	addi	a0,a0,1
     944:	87aa                	mv	a5,a0
     946:	86be                	mv	a3,a5
     948:	0785                	addi	a5,a5,1
     94a:	fff7c703          	lbu	a4,-1(a5)
     94e:	ff65                	bnez	a4,946 <strlen+0x10>
     950:	40a6853b          	subw	a0,a3,a0
     954:	2505                	addiw	a0,a0,1
    ;
  return n;
}
     956:	6422                	ld	s0,8(sp)
     958:	0141                	addi	sp,sp,16
     95a:	8082                	ret
  for(n = 0; s[n]; n++)
     95c:	4501                	li	a0,0
     95e:	bfe5                	j	956 <strlen+0x20>

0000000000000960 <memset>:

void*
memset(void *dst, int c, uint n)
{
     960:	1141                	addi	sp,sp,-16
     962:	e422                	sd	s0,8(sp)
     964:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
     966:	ca19                	beqz	a2,97c <memset+0x1c>
     968:	87aa                	mv	a5,a0
     96a:	1602                	slli	a2,a2,0x20
     96c:	9201                	srli	a2,a2,0x20
     96e:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
     972:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
     976:	0785                	addi	a5,a5,1
     978:	fee79de3          	bne	a5,a4,972 <memset+0x12>
  }
  return dst;
}
     97c:	6422                	ld	s0,8(sp)
     97e:	0141                	addi	sp,sp,16
     980:	8082                	ret

0000000000000982 <strchr>:

char*
strchr(const char *s, char c)
{
     982:	1141                	addi	sp,sp,-16
     984:	e422                	sd	s0,8(sp)
     986:	0800                	addi	s0,sp,16
  for(; *s; s++)
     988:	00054783          	lbu	a5,0(a0)
     98c:	cb99                	beqz	a5,9a2 <strchr+0x20>
    if(*s == c)
     98e:	00f58763          	beq	a1,a5,99c <strchr+0x1a>
  for(; *s; s++)
     992:	0505                	addi	a0,a0,1
     994:	00054783          	lbu	a5,0(a0)
     998:	fbfd                	bnez	a5,98e <strchr+0xc>
      return (char*)s;
  return 0;
     99a:	4501                	li	a0,0
}
     99c:	6422                	ld	s0,8(sp)
     99e:	0141                	addi	sp,sp,16
     9a0:	8082                	ret
  return 0;
     9a2:	4501                	li	a0,0
     9a4:	bfe5                	j	99c <strchr+0x1a>

00000000000009a6 <gets>:

char*
gets(char *buf, int max)
{
     9a6:	711d                	addi	sp,sp,-96
     9a8:	ec86                	sd	ra,88(sp)
     9aa:	e8a2                	sd	s0,80(sp)
     9ac:	e4a6                	sd	s1,72(sp)
     9ae:	e0ca                	sd	s2,64(sp)
     9b0:	fc4e                	sd	s3,56(sp)
     9b2:	f852                	sd	s4,48(sp)
     9b4:	f456                	sd	s5,40(sp)
     9b6:	f05a                	sd	s6,32(sp)
     9b8:	ec5e                	sd	s7,24(sp)
     9ba:	1080                	addi	s0,sp,96
     9bc:	8baa                	mv	s7,a0
     9be:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
     9c0:	892a                	mv	s2,a0
     9c2:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
     9c4:	4aa9                	li	s5,10
     9c6:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
     9c8:	89a6                	mv	s3,s1
     9ca:	2485                	addiw	s1,s1,1
     9cc:	0344d663          	bge	s1,s4,9f8 <gets+0x52>
    cc = read(0, &c, 1);
     9d0:	4605                	li	a2,1
     9d2:	faf40593          	addi	a1,s0,-81
     9d6:	4501                	li	a0,0
     9d8:	1f0000ef          	jal	bc8 <read>
    if(cc < 1)
     9dc:	00a05e63          	blez	a0,9f8 <gets+0x52>
    buf[i++] = c;
     9e0:	faf44783          	lbu	a5,-81(s0)
     9e4:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
     9e8:	01578763          	beq	a5,s5,9f6 <gets+0x50>
     9ec:	0905                	addi	s2,s2,1
     9ee:	fd679de3          	bne	a5,s6,9c8 <gets+0x22>
    buf[i++] = c;
     9f2:	89a6                	mv	s3,s1
     9f4:	a011                	j	9f8 <gets+0x52>
     9f6:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
     9f8:	99de                	add	s3,s3,s7
     9fa:	00098023          	sb	zero,0(s3)
  return buf;
}
     9fe:	855e                	mv	a0,s7
     a00:	60e6                	ld	ra,88(sp)
     a02:	6446                	ld	s0,80(sp)
     a04:	64a6                	ld	s1,72(sp)
     a06:	6906                	ld	s2,64(sp)
     a08:	79e2                	ld	s3,56(sp)
     a0a:	7a42                	ld	s4,48(sp)
     a0c:	7aa2                	ld	s5,40(sp)
     a0e:	7b02                	ld	s6,32(sp)
     a10:	6be2                	ld	s7,24(sp)
     a12:	6125                	addi	sp,sp,96
     a14:	8082                	ret

0000000000000a16 <stat>:

int
stat(const char *n, struct stat *st)
{
     a16:	1101                	addi	sp,sp,-32
     a18:	ec06                	sd	ra,24(sp)
     a1a:	e822                	sd	s0,16(sp)
     a1c:	e04a                	sd	s2,0(sp)
     a1e:	1000                	addi	s0,sp,32
     a20:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
     a22:	4581                	li	a1,0
     a24:	1cc000ef          	jal	bf0 <open>
  if(fd < 0)
     a28:	02054263          	bltz	a0,a4c <stat+0x36>
     a2c:	e426                	sd	s1,8(sp)
     a2e:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
     a30:	85ca                	mv	a1,s2
     a32:	1d6000ef          	jal	c08 <fstat>
     a36:	892a                	mv	s2,a0
  close(fd);
     a38:	8526                	mv	a0,s1
     a3a:	19e000ef          	jal	bd8 <close>
  return r;
     a3e:	64a2                	ld	s1,8(sp)
}
     a40:	854a                	mv	a0,s2
     a42:	60e2                	ld	ra,24(sp)
     a44:	6442                	ld	s0,16(sp)
     a46:	6902                	ld	s2,0(sp)
     a48:	6105                	addi	sp,sp,32
     a4a:	8082                	ret
    return -1;
     a4c:	597d                	li	s2,-1
     a4e:	bfcd                	j	a40 <stat+0x2a>

0000000000000a50 <atoi>:

int
atoi(const char *s)
{
     a50:	1141                	addi	sp,sp,-16
     a52:	e422                	sd	s0,8(sp)
     a54:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
     a56:	00054683          	lbu	a3,0(a0)
     a5a:	fd06879b          	addiw	a5,a3,-48
     a5e:	0ff7f793          	zext.b	a5,a5
     a62:	4625                	li	a2,9
     a64:	02f66863          	bltu	a2,a5,a94 <atoi+0x44>
     a68:	872a                	mv	a4,a0
  n = 0;
     a6a:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
     a6c:	0705                	addi	a4,a4,1
     a6e:	0025179b          	slliw	a5,a0,0x2
     a72:	9fa9                	addw	a5,a5,a0
     a74:	0017979b          	slliw	a5,a5,0x1
     a78:	9fb5                	addw	a5,a5,a3
     a7a:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
     a7e:	00074683          	lbu	a3,0(a4)
     a82:	fd06879b          	addiw	a5,a3,-48
     a86:	0ff7f793          	zext.b	a5,a5
     a8a:	fef671e3          	bgeu	a2,a5,a6c <atoi+0x1c>
  return n;
}
     a8e:	6422                	ld	s0,8(sp)
     a90:	0141                	addi	sp,sp,16
     a92:	8082                	ret
  n = 0;
     a94:	4501                	li	a0,0
     a96:	bfe5                	j	a8e <atoi+0x3e>

0000000000000a98 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
     a98:	1141                	addi	sp,sp,-16
     a9a:	e422                	sd	s0,8(sp)
     a9c:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
     a9e:	02b57463          	bgeu	a0,a1,ac6 <memmove+0x2e>
    while(n-- > 0)
     aa2:	00c05f63          	blez	a2,ac0 <memmove+0x28>
     aa6:	1602                	slli	a2,a2,0x20
     aa8:	9201                	srli	a2,a2,0x20
     aaa:	00c507b3          	add	a5,a0,a2
  dst = vdst;
     aae:	872a                	mv	a4,a0
      *dst++ = *src++;
     ab0:	0585                	addi	a1,a1,1
     ab2:	0705                	addi	a4,a4,1
     ab4:	fff5c683          	lbu	a3,-1(a1)
     ab8:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
     abc:	fef71ae3          	bne	a4,a5,ab0 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
     ac0:	6422                	ld	s0,8(sp)
     ac2:	0141                	addi	sp,sp,16
     ac4:	8082                	ret
    dst += n;
     ac6:	00c50733          	add	a4,a0,a2
    src += n;
     aca:	95b2                	add	a1,a1,a2
    while(n-- > 0)
     acc:	fec05ae3          	blez	a2,ac0 <memmove+0x28>
     ad0:	fff6079b          	addiw	a5,a2,-1
     ad4:	1782                	slli	a5,a5,0x20
     ad6:	9381                	srli	a5,a5,0x20
     ad8:	fff7c793          	not	a5,a5
     adc:	97ba                	add	a5,a5,a4
      *--dst = *--src;
     ade:	15fd                	addi	a1,a1,-1
     ae0:	177d                	addi	a4,a4,-1
     ae2:	0005c683          	lbu	a3,0(a1)
     ae6:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
     aea:	fee79ae3          	bne	a5,a4,ade <memmove+0x46>
     aee:	bfc9                	j	ac0 <memmove+0x28>

0000000000000af0 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
     af0:	1141                	addi	sp,sp,-16
     af2:	e422                	sd	s0,8(sp)
     af4:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
     af6:	ca05                	beqz	a2,b26 <memcmp+0x36>
     af8:	fff6069b          	addiw	a3,a2,-1
     afc:	1682                	slli	a3,a3,0x20
     afe:	9281                	srli	a3,a3,0x20
     b00:	0685                	addi	a3,a3,1
     b02:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
     b04:	00054783          	lbu	a5,0(a0)
     b08:	0005c703          	lbu	a4,0(a1)
     b0c:	00e79863          	bne	a5,a4,b1c <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
     b10:	0505                	addi	a0,a0,1
    p2++;
     b12:	0585                	addi	a1,a1,1
  while (n-- > 0) {
     b14:	fed518e3          	bne	a0,a3,b04 <memcmp+0x14>
  }
  return 0;
     b18:	4501                	li	a0,0
     b1a:	a019                	j	b20 <memcmp+0x30>
      return *p1 - *p2;
     b1c:	40e7853b          	subw	a0,a5,a4
}
     b20:	6422                	ld	s0,8(sp)
     b22:	0141                	addi	sp,sp,16
     b24:	8082                	ret
  return 0;
     b26:	4501                	li	a0,0
     b28:	bfe5                	j	b20 <memcmp+0x30>

0000000000000b2a <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
     b2a:	1141                	addi	sp,sp,-16
     b2c:	e406                	sd	ra,8(sp)
     b2e:	e022                	sd	s0,0(sp)
     b30:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
     b32:	f67ff0ef          	jal	a98 <memmove>
}
     b36:	60a2                	ld	ra,8(sp)
     b38:	6402                	ld	s0,0(sp)
     b3a:	0141                	addi	sp,sp,16
     b3c:	8082                	ret

0000000000000b3e <sbrk>:

char *
sbrk(int n) {
     b3e:	1141                	addi	sp,sp,-16
     b40:	e406                	sd	ra,8(sp)
     b42:	e022                	sd	s0,0(sp)
     b44:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_EAGER);
     b46:	4585                	li	a1,1
     b48:	0f0000ef          	jal	c38 <sys_sbrk>
}
     b4c:	60a2                	ld	ra,8(sp)
     b4e:	6402                	ld	s0,0(sp)
     b50:	0141                	addi	sp,sp,16
     b52:	8082                	ret

0000000000000b54 <sbrklazy>:

char *
sbrklazy(int n) {
     b54:	1141                	addi	sp,sp,-16
     b56:	e406                	sd	ra,8(sp)
     b58:	e022                	sd	s0,0(sp)
     b5a:	0800                	addi	s0,sp,16
  return sys_sbrk(n, SBRK_LAZY);
     b5c:	4589                	li	a1,2
     b5e:	0da000ef          	jal	c38 <sys_sbrk>
}
     b62:	60a2                	ld	ra,8(sp)
     b64:	6402                	ld	s0,0(sp)
     b66:	0141                	addi	sp,sp,16
     b68:	8082                	ret

0000000000000b6a <getcpuinfo>:

int
getcpuinfo(struct cpu_info *cpus, int ncpu)
{
     b6a:	1141                	addi	sp,sp,-16
     b6c:	e406                	sd	ra,8(sp)
     b6e:	e022                	sd	s0,0(sp)
     b70:	0800                	addi	s0,sp,16
  // Stub: return 0 CPUs for now
  // In a full implementation, this would fetch CPU state from kernel
  memset(cpus, 0, ncpu * sizeof(struct cpu_info));
     b72:	0025961b          	slliw	a2,a1,0x2
     b76:	9e2d                	addw	a2,a2,a1
     b78:	0036161b          	slliw	a2,a2,0x3
     b7c:	4581                	li	a1,0
     b7e:	de3ff0ef          	jal	960 <memset>
  return 0;
}
     b82:	4501                	li	a0,0
     b84:	60a2                	ld	ra,8(sp)
     b86:	6402                	ld	s0,0(sp)
     b88:	0141                	addi	sp,sp,16
     b8a:	8082                	ret

0000000000000b8c <getprocstats>:

int
getprocstats(struct proc_stats *stats)
{
     b8c:	1141                	addi	sp,sp,-16
     b8e:	e406                	sd	ra,8(sp)
     b90:	e022                	sd	s0,0(sp)
     b92:	0800                	addi	s0,sp,16
  // Stub: return zeros for now
  // In a full implementation, this would fetch process statistics from kernel
  memset(stats, 0, sizeof(struct proc_stats));
     b94:	07000613          	li	a2,112
     b98:	4581                	li	a1,0
     b9a:	dc7ff0ef          	jal	960 <memset>
  return 0;
}
     b9e:	4501                	li	a0,0
     ba0:	60a2                	ld	ra,8(sp)
     ba2:	6402                	ld	s0,0(sp)
     ba4:	0141                	addi	sp,sp,16
     ba6:	8082                	ret

0000000000000ba8 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
     ba8:	4885                	li	a7,1
 ecall
     baa:	00000073          	ecall
 ret
     bae:	8082                	ret

0000000000000bb0 <exit>:
.global exit
exit:
 li a7, SYS_exit
     bb0:	4889                	li	a7,2
 ecall
     bb2:	00000073          	ecall
 ret
     bb6:	8082                	ret

0000000000000bb8 <wait>:
.global wait
wait:
 li a7, SYS_wait
     bb8:	488d                	li	a7,3
 ecall
     bba:	00000073          	ecall
 ret
     bbe:	8082                	ret

0000000000000bc0 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
     bc0:	4891                	li	a7,4
 ecall
     bc2:	00000073          	ecall
 ret
     bc6:	8082                	ret

0000000000000bc8 <read>:
.global read
read:
 li a7, SYS_read
     bc8:	4895                	li	a7,5
 ecall
     bca:	00000073          	ecall
 ret
     bce:	8082                	ret

0000000000000bd0 <write>:
.global write
write:
 li a7, SYS_write
     bd0:	48c1                	li	a7,16
 ecall
     bd2:	00000073          	ecall
 ret
     bd6:	8082                	ret

0000000000000bd8 <close>:
.global close
close:
 li a7, SYS_close
     bd8:	48d5                	li	a7,21
 ecall
     bda:	00000073          	ecall
 ret
     bde:	8082                	ret

0000000000000be0 <kill>:
.global kill
kill:
 li a7, SYS_kill
     be0:	4899                	li	a7,6
 ecall
     be2:	00000073          	ecall
 ret
     be6:	8082                	ret

0000000000000be8 <exec>:
.global exec
exec:
 li a7, SYS_exec
     be8:	489d                	li	a7,7
 ecall
     bea:	00000073          	ecall
 ret
     bee:	8082                	ret

0000000000000bf0 <open>:
.global open
open:
 li a7, SYS_open
     bf0:	48bd                	li	a7,15
 ecall
     bf2:	00000073          	ecall
 ret
     bf6:	8082                	ret

0000000000000bf8 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
     bf8:	48c5                	li	a7,17
 ecall
     bfa:	00000073          	ecall
 ret
     bfe:	8082                	ret

0000000000000c00 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
     c00:	48c9                	li	a7,18
 ecall
     c02:	00000073          	ecall
 ret
     c06:	8082                	ret

0000000000000c08 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
     c08:	48a1                	li	a7,8
 ecall
     c0a:	00000073          	ecall
 ret
     c0e:	8082                	ret

0000000000000c10 <link>:
.global link
link:
 li a7, SYS_link
     c10:	48cd                	li	a7,19
 ecall
     c12:	00000073          	ecall
 ret
     c16:	8082                	ret

0000000000000c18 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
     c18:	48d1                	li	a7,20
 ecall
     c1a:	00000073          	ecall
 ret
     c1e:	8082                	ret

0000000000000c20 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
     c20:	48a5                	li	a7,9
 ecall
     c22:	00000073          	ecall
 ret
     c26:	8082                	ret

0000000000000c28 <dup>:
.global dup
dup:
 li a7, SYS_dup
     c28:	48a9                	li	a7,10
 ecall
     c2a:	00000073          	ecall
 ret
     c2e:	8082                	ret

0000000000000c30 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
     c30:	48ad                	li	a7,11
 ecall
     c32:	00000073          	ecall
 ret
     c36:	8082                	ret

0000000000000c38 <sys_sbrk>:
.global sys_sbrk
sys_sbrk:
 li a7, SYS_sbrk
     c38:	48b1                	li	a7,12
 ecall
     c3a:	00000073          	ecall
 ret
     c3e:	8082                	ret

0000000000000c40 <pause>:
.global pause
pause:
 li a7, SYS_pause
     c40:	48b5                	li	a7,13
 ecall
     c42:	00000073          	ecall
 ret
     c46:	8082                	ret

0000000000000c48 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
     c48:	48b9                	li	a7,14
 ecall
     c4a:	00000073          	ecall
 ret
     c4e:	8082                	ret

0000000000000c50 <csread>:
.global csread
csread:
 li a7, SYS_csread
     c50:	48d9                	li	a7,22
 ecall
     c52:	00000073          	ecall
 ret
     c56:	8082                	ret

0000000000000c58 <fsread>:
.global fsread
fsread:
 li a7, SYS_fsread
     c58:	48dd                	li	a7,23
 ecall
     c5a:	00000073          	ecall
 ret
     c5e:	8082                	ret

0000000000000c60 <schedread>:
.global schedread
schedread:
 li a7, SYS_schedread
     c60:	48e1                	li	a7,24
 ecall
     c62:	00000073          	ecall
 ret
     c66:	8082                	ret

0000000000000c68 <memread>:
.global memread
memread:
 li a7, SYS_memread
     c68:	48e5                	li	a7,25
 ecall
     c6a:	00000073          	ecall
 ret
     c6e:	8082                	ret

0000000000000c70 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
     c70:	1101                	addi	sp,sp,-32
     c72:	ec06                	sd	ra,24(sp)
     c74:	e822                	sd	s0,16(sp)
     c76:	1000                	addi	s0,sp,32
     c78:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
     c7c:	4605                	li	a2,1
     c7e:	fef40593          	addi	a1,s0,-17
     c82:	f4fff0ef          	jal	bd0 <write>
}
     c86:	60e2                	ld	ra,24(sp)
     c88:	6442                	ld	s0,16(sp)
     c8a:	6105                	addi	sp,sp,32
     c8c:	8082                	ret

0000000000000c8e <printint>:

static void
printint(int fd, long long xx, int base, int sgn)
{
     c8e:	715d                	addi	sp,sp,-80
     c90:	e486                	sd	ra,72(sp)
     c92:	e0a2                	sd	s0,64(sp)
     c94:	f84a                	sd	s2,48(sp)
     c96:	0880                	addi	s0,sp,80
     c98:	892a                	mv	s2,a0
  char buf[20];
  int i, neg;
  unsigned long long x;

  neg = 0;
  if(sgn && xx < 0){
     c9a:	c299                	beqz	a3,ca0 <printint+0x12>
     c9c:	0805c363          	bltz	a1,d22 <printint+0x94>
  neg = 0;
     ca0:	4881                	li	a7,0
     ca2:	fb840693          	addi	a3,s0,-72
    x = -xx;
  } else {
    x = xx;
  }

  i = 0;
     ca6:	4781                	li	a5,0
  do{
    buf[i++] = digits[x % base];
     ca8:	00001517          	auipc	a0,0x1
     cac:	87850513          	addi	a0,a0,-1928 # 1520 <digits>
     cb0:	883e                	mv	a6,a5
     cb2:	2785                	addiw	a5,a5,1
     cb4:	02c5f733          	remu	a4,a1,a2
     cb8:	972a                	add	a4,a4,a0
     cba:	00074703          	lbu	a4,0(a4)
     cbe:	00e68023          	sb	a4,0(a3)
  }while((x /= base) != 0);
     cc2:	872e                	mv	a4,a1
     cc4:	02c5d5b3          	divu	a1,a1,a2
     cc8:	0685                	addi	a3,a3,1
     cca:	fec773e3          	bgeu	a4,a2,cb0 <printint+0x22>
  if(neg)
     cce:	00088b63          	beqz	a7,ce4 <printint+0x56>
    buf[i++] = '-';
     cd2:	fd078793          	addi	a5,a5,-48
     cd6:	97a2                	add	a5,a5,s0
     cd8:	02d00713          	li	a4,45
     cdc:	fee78423          	sb	a4,-24(a5)
     ce0:	0028079b          	addiw	a5,a6,2

  while(--i >= 0)
     ce4:	02f05a63          	blez	a5,d18 <printint+0x8a>
     ce8:	fc26                	sd	s1,56(sp)
     cea:	f44e                	sd	s3,40(sp)
     cec:	fb840713          	addi	a4,s0,-72
     cf0:	00f704b3          	add	s1,a4,a5
     cf4:	fff70993          	addi	s3,a4,-1
     cf8:	99be                	add	s3,s3,a5
     cfa:	37fd                	addiw	a5,a5,-1
     cfc:	1782                	slli	a5,a5,0x20
     cfe:	9381                	srli	a5,a5,0x20
     d00:	40f989b3          	sub	s3,s3,a5
    putc(fd, buf[i]);
     d04:	fff4c583          	lbu	a1,-1(s1)
     d08:	854a                	mv	a0,s2
     d0a:	f67ff0ef          	jal	c70 <putc>
  while(--i >= 0)
     d0e:	14fd                	addi	s1,s1,-1
     d10:	ff349ae3          	bne	s1,s3,d04 <printint+0x76>
     d14:	74e2                	ld	s1,56(sp)
     d16:	79a2                	ld	s3,40(sp)
}
     d18:	60a6                	ld	ra,72(sp)
     d1a:	6406                	ld	s0,64(sp)
     d1c:	7942                	ld	s2,48(sp)
     d1e:	6161                	addi	sp,sp,80
     d20:	8082                	ret
    x = -xx;
     d22:	40b005b3          	neg	a1,a1
    neg = 1;
     d26:	4885                	li	a7,1
    x = -xx;
     d28:	bfad                	j	ca2 <printint+0x14>

0000000000000d2a <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %c, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
     d2a:	711d                	addi	sp,sp,-96
     d2c:	ec86                	sd	ra,88(sp)
     d2e:	e8a2                	sd	s0,80(sp)
     d30:	e0ca                	sd	s2,64(sp)
     d32:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
     d34:	0005c903          	lbu	s2,0(a1)
     d38:	28090663          	beqz	s2,fc4 <vprintf+0x29a>
     d3c:	e4a6                	sd	s1,72(sp)
     d3e:	fc4e                	sd	s3,56(sp)
     d40:	f852                	sd	s4,48(sp)
     d42:	f456                	sd	s5,40(sp)
     d44:	f05a                	sd	s6,32(sp)
     d46:	ec5e                	sd	s7,24(sp)
     d48:	e862                	sd	s8,16(sp)
     d4a:	e466                	sd	s9,8(sp)
     d4c:	8b2a                	mv	s6,a0
     d4e:	8a2e                	mv	s4,a1
     d50:	8bb2                	mv	s7,a2
  state = 0;
     d52:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
     d54:	4481                	li	s1,0
     d56:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
     d58:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
     d5c:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
     d60:	06c00c93          	li	s9,108
     d64:	a005                	j	d84 <vprintf+0x5a>
        putc(fd, c0);
     d66:	85ca                	mv	a1,s2
     d68:	855a                	mv	a0,s6
     d6a:	f07ff0ef          	jal	c70 <putc>
     d6e:	a019                	j	d74 <vprintf+0x4a>
    } else if(state == '%'){
     d70:	03598263          	beq	s3,s5,d94 <vprintf+0x6a>
  for(i = 0; fmt[i]; i++){
     d74:	2485                	addiw	s1,s1,1
     d76:	8726                	mv	a4,s1
     d78:	009a07b3          	add	a5,s4,s1
     d7c:	0007c903          	lbu	s2,0(a5)
     d80:	22090a63          	beqz	s2,fb4 <vprintf+0x28a>
    c0 = fmt[i] & 0xff;
     d84:	0009079b          	sext.w	a5,s2
    if(state == 0){
     d88:	fe0994e3          	bnez	s3,d70 <vprintf+0x46>
      if(c0 == '%'){
     d8c:	fd579de3          	bne	a5,s5,d66 <vprintf+0x3c>
        state = '%';
     d90:	89be                	mv	s3,a5
     d92:	b7cd                	j	d74 <vprintf+0x4a>
      if(c0) c1 = fmt[i+1] & 0xff;
     d94:	00ea06b3          	add	a3,s4,a4
     d98:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
     d9c:	8636                	mv	a2,a3
      if(c1) c2 = fmt[i+2] & 0xff;
     d9e:	c681                	beqz	a3,da6 <vprintf+0x7c>
     da0:	9752                	add	a4,a4,s4
     da2:	00274603          	lbu	a2,2(a4)
      if(c0 == 'd'){
     da6:	05878363          	beq	a5,s8,dec <vprintf+0xc2>
      } else if(c0 == 'l' && c1 == 'd'){
     daa:	05978d63          	beq	a5,s9,e04 <vprintf+0xda>
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if(c0 == 'u'){
     dae:	07500713          	li	a4,117
     db2:	0ee78763          	beq	a5,a4,ea0 <vprintf+0x176>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if(c0 == 'x'){
     db6:	07800713          	li	a4,120
     dba:	12e78963          	beq	a5,a4,eec <vprintf+0x1c2>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if(c0 == 'p'){
     dbe:	07000713          	li	a4,112
     dc2:	14e78e63          	beq	a5,a4,f1e <vprintf+0x1f4>
        printptr(fd, va_arg(ap, uint64));
      } else if(c0 == 'c'){
     dc6:	06300713          	li	a4,99
     dca:	18e78e63          	beq	a5,a4,f66 <vprintf+0x23c>
        putc(fd, va_arg(ap, uint32));
      } else if(c0 == 's'){
     dce:	07300713          	li	a4,115
     dd2:	1ae78463          	beq	a5,a4,f7a <vprintf+0x250>
        if((s = va_arg(ap, char*)) == 0)
          s = "(null)";
        for(; *s; s++)
          putc(fd, *s);
      } else if(c0 == '%'){
     dd6:	02500713          	li	a4,37
     dda:	04e79563          	bne	a5,a4,e24 <vprintf+0xfa>
        putc(fd, '%');
     dde:	02500593          	li	a1,37
     de2:	855a                	mv	a0,s6
     de4:	e8dff0ef          	jal	c70 <putc>
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c0);
      }

      state = 0;
     de8:	4981                	li	s3,0
     dea:	b769                	j	d74 <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 10, 1);
     dec:	008b8913          	addi	s2,s7,8
     df0:	4685                	li	a3,1
     df2:	4629                	li	a2,10
     df4:	000ba583          	lw	a1,0(s7)
     df8:	855a                	mv	a0,s6
     dfa:	e95ff0ef          	jal	c8e <printint>
     dfe:	8bca                	mv	s7,s2
      state = 0;
     e00:	4981                	li	s3,0
     e02:	bf8d                	j	d74 <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'd'){
     e04:	06400793          	li	a5,100
     e08:	02f68963          	beq	a3,a5,e3a <vprintf+0x110>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
     e0c:	06c00793          	li	a5,108
     e10:	04f68263          	beq	a3,a5,e54 <vprintf+0x12a>
      } else if(c0 == 'l' && c1 == 'u'){
     e14:	07500793          	li	a5,117
     e18:	0af68063          	beq	a3,a5,eb8 <vprintf+0x18e>
      } else if(c0 == 'l' && c1 == 'x'){
     e1c:	07800793          	li	a5,120
     e20:	0ef68263          	beq	a3,a5,f04 <vprintf+0x1da>
        putc(fd, '%');
     e24:	02500593          	li	a1,37
     e28:	855a                	mv	a0,s6
     e2a:	e47ff0ef          	jal	c70 <putc>
        putc(fd, c0);
     e2e:	85ca                	mv	a1,s2
     e30:	855a                	mv	a0,s6
     e32:	e3fff0ef          	jal	c70 <putc>
      state = 0;
     e36:	4981                	li	s3,0
     e38:	bf35                	j	d74 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
     e3a:	008b8913          	addi	s2,s7,8
     e3e:	4685                	li	a3,1
     e40:	4629                	li	a2,10
     e42:	000bb583          	ld	a1,0(s7)
     e46:	855a                	mv	a0,s6
     e48:	e47ff0ef          	jal	c8e <printint>
        i += 1;
     e4c:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 1);
     e4e:	8bca                	mv	s7,s2
      state = 0;
     e50:	4981                	li	s3,0
        i += 1;
     e52:	b70d                	j	d74 <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
     e54:	06400793          	li	a5,100
     e58:	02f60763          	beq	a2,a5,e86 <vprintf+0x15c>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
     e5c:	07500793          	li	a5,117
     e60:	06f60963          	beq	a2,a5,ed2 <vprintf+0x1a8>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
     e64:	07800793          	li	a5,120
     e68:	faf61ee3          	bne	a2,a5,e24 <vprintf+0xfa>
        printint(fd, va_arg(ap, uint64), 16, 0);
     e6c:	008b8913          	addi	s2,s7,8
     e70:	4681                	li	a3,0
     e72:	4641                	li	a2,16
     e74:	000bb583          	ld	a1,0(s7)
     e78:	855a                	mv	a0,s6
     e7a:	e15ff0ef          	jal	c8e <printint>
        i += 2;
     e7e:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 16, 0);
     e80:	8bca                	mv	s7,s2
      state = 0;
     e82:	4981                	li	s3,0
        i += 2;
     e84:	bdc5                	j	d74 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
     e86:	008b8913          	addi	s2,s7,8
     e8a:	4685                	li	a3,1
     e8c:	4629                	li	a2,10
     e8e:	000bb583          	ld	a1,0(s7)
     e92:	855a                	mv	a0,s6
     e94:	dfbff0ef          	jal	c8e <printint>
        i += 2;
     e98:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 1);
     e9a:	8bca                	mv	s7,s2
      state = 0;
     e9c:	4981                	li	s3,0
        i += 2;
     e9e:	bdd9                	j	d74 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint32), 10, 0);
     ea0:	008b8913          	addi	s2,s7,8
     ea4:	4681                	li	a3,0
     ea6:	4629                	li	a2,10
     ea8:	000be583          	lwu	a1,0(s7)
     eac:	855a                	mv	a0,s6
     eae:	de1ff0ef          	jal	c8e <printint>
     eb2:	8bca                	mv	s7,s2
      state = 0;
     eb4:	4981                	li	s3,0
     eb6:	bd7d                	j	d74 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
     eb8:	008b8913          	addi	s2,s7,8
     ebc:	4681                	li	a3,0
     ebe:	4629                	li	a2,10
     ec0:	000bb583          	ld	a1,0(s7)
     ec4:	855a                	mv	a0,s6
     ec6:	dc9ff0ef          	jal	c8e <printint>
        i += 1;
     eca:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 0);
     ecc:	8bca                	mv	s7,s2
      state = 0;
     ece:	4981                	li	s3,0
        i += 1;
     ed0:	b555                	j	d74 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
     ed2:	008b8913          	addi	s2,s7,8
     ed6:	4681                	li	a3,0
     ed8:	4629                	li	a2,10
     eda:	000bb583          	ld	a1,0(s7)
     ede:	855a                	mv	a0,s6
     ee0:	dafff0ef          	jal	c8e <printint>
        i += 2;
     ee4:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 0);
     ee6:	8bca                	mv	s7,s2
      state = 0;
     ee8:	4981                	li	s3,0
        i += 2;
     eea:	b569                	j	d74 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint32), 16, 0);
     eec:	008b8913          	addi	s2,s7,8
     ef0:	4681                	li	a3,0
     ef2:	4641                	li	a2,16
     ef4:	000be583          	lwu	a1,0(s7)
     ef8:	855a                	mv	a0,s6
     efa:	d95ff0ef          	jal	c8e <printint>
     efe:	8bca                	mv	s7,s2
      state = 0;
     f00:	4981                	li	s3,0
     f02:	bd8d                	j	d74 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 16, 0);
     f04:	008b8913          	addi	s2,s7,8
     f08:	4681                	li	a3,0
     f0a:	4641                	li	a2,16
     f0c:	000bb583          	ld	a1,0(s7)
     f10:	855a                	mv	a0,s6
     f12:	d7dff0ef          	jal	c8e <printint>
        i += 1;
     f16:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 16, 0);
     f18:	8bca                	mv	s7,s2
      state = 0;
     f1a:	4981                	li	s3,0
        i += 1;
     f1c:	bda1                	j	d74 <vprintf+0x4a>
     f1e:	e06a                	sd	s10,0(sp)
        printptr(fd, va_arg(ap, uint64));
     f20:	008b8d13          	addi	s10,s7,8
     f24:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
     f28:	03000593          	li	a1,48
     f2c:	855a                	mv	a0,s6
     f2e:	d43ff0ef          	jal	c70 <putc>
  putc(fd, 'x');
     f32:	07800593          	li	a1,120
     f36:	855a                	mv	a0,s6
     f38:	d39ff0ef          	jal	c70 <putc>
     f3c:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
     f3e:	00000b97          	auipc	s7,0x0
     f42:	5e2b8b93          	addi	s7,s7,1506 # 1520 <digits>
     f46:	03c9d793          	srli	a5,s3,0x3c
     f4a:	97de                	add	a5,a5,s7
     f4c:	0007c583          	lbu	a1,0(a5)
     f50:	855a                	mv	a0,s6
     f52:	d1fff0ef          	jal	c70 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
     f56:	0992                	slli	s3,s3,0x4
     f58:	397d                	addiw	s2,s2,-1
     f5a:	fe0916e3          	bnez	s2,f46 <vprintf+0x21c>
        printptr(fd, va_arg(ap, uint64));
     f5e:	8bea                	mv	s7,s10
      state = 0;
     f60:	4981                	li	s3,0
     f62:	6d02                	ld	s10,0(sp)
     f64:	bd01                	j	d74 <vprintf+0x4a>
        putc(fd, va_arg(ap, uint32));
     f66:	008b8913          	addi	s2,s7,8
     f6a:	000bc583          	lbu	a1,0(s7)
     f6e:	855a                	mv	a0,s6
     f70:	d01ff0ef          	jal	c70 <putc>
     f74:	8bca                	mv	s7,s2
      state = 0;
     f76:	4981                	li	s3,0
     f78:	bbf5                	j	d74 <vprintf+0x4a>
        if((s = va_arg(ap, char*)) == 0)
     f7a:	008b8993          	addi	s3,s7,8
     f7e:	000bb903          	ld	s2,0(s7)
     f82:	00090f63          	beqz	s2,fa0 <vprintf+0x276>
        for(; *s; s++)
     f86:	00094583          	lbu	a1,0(s2)
     f8a:	c195                	beqz	a1,fae <vprintf+0x284>
          putc(fd, *s);
     f8c:	855a                	mv	a0,s6
     f8e:	ce3ff0ef          	jal	c70 <putc>
        for(; *s; s++)
     f92:	0905                	addi	s2,s2,1
     f94:	00094583          	lbu	a1,0(s2)
     f98:	f9f5                	bnez	a1,f8c <vprintf+0x262>
        if((s = va_arg(ap, char*)) == 0)
     f9a:	8bce                	mv	s7,s3
      state = 0;
     f9c:	4981                	li	s3,0
     f9e:	bbd9                	j	d74 <vprintf+0x4a>
          s = "(null)";
     fa0:	00000917          	auipc	s2,0x0
     fa4:	51890913          	addi	s2,s2,1304 # 14b8 <malloc+0x40c>
        for(; *s; s++)
     fa8:	02800593          	li	a1,40
     fac:	b7c5                	j	f8c <vprintf+0x262>
        if((s = va_arg(ap, char*)) == 0)
     fae:	8bce                	mv	s7,s3
      state = 0;
     fb0:	4981                	li	s3,0
     fb2:	b3c9                	j	d74 <vprintf+0x4a>
     fb4:	64a6                	ld	s1,72(sp)
     fb6:	79e2                	ld	s3,56(sp)
     fb8:	7a42                	ld	s4,48(sp)
     fba:	7aa2                	ld	s5,40(sp)
     fbc:	7b02                	ld	s6,32(sp)
     fbe:	6be2                	ld	s7,24(sp)
     fc0:	6c42                	ld	s8,16(sp)
     fc2:	6ca2                	ld	s9,8(sp)
    }
  }
}
     fc4:	60e6                	ld	ra,88(sp)
     fc6:	6446                	ld	s0,80(sp)
     fc8:	6906                	ld	s2,64(sp)
     fca:	6125                	addi	sp,sp,96
     fcc:	8082                	ret

0000000000000fce <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
     fce:	715d                	addi	sp,sp,-80
     fd0:	ec06                	sd	ra,24(sp)
     fd2:	e822                	sd	s0,16(sp)
     fd4:	1000                	addi	s0,sp,32
     fd6:	e010                	sd	a2,0(s0)
     fd8:	e414                	sd	a3,8(s0)
     fda:	e818                	sd	a4,16(s0)
     fdc:	ec1c                	sd	a5,24(s0)
     fde:	03043023          	sd	a6,32(s0)
     fe2:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
     fe6:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
     fea:	8622                	mv	a2,s0
     fec:	d3fff0ef          	jal	d2a <vprintf>
}
     ff0:	60e2                	ld	ra,24(sp)
     ff2:	6442                	ld	s0,16(sp)
     ff4:	6161                	addi	sp,sp,80
     ff6:	8082                	ret

0000000000000ff8 <printf>:

void
printf(const char *fmt, ...)
{
     ff8:	711d                	addi	sp,sp,-96
     ffa:	ec06                	sd	ra,24(sp)
     ffc:	e822                	sd	s0,16(sp)
     ffe:	1000                	addi	s0,sp,32
    1000:	e40c                	sd	a1,8(s0)
    1002:	e810                	sd	a2,16(s0)
    1004:	ec14                	sd	a3,24(s0)
    1006:	f018                	sd	a4,32(s0)
    1008:	f41c                	sd	a5,40(s0)
    100a:	03043823          	sd	a6,48(s0)
    100e:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
    1012:	00840613          	addi	a2,s0,8
    1016:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
    101a:	85aa                	mv	a1,a0
    101c:	4505                	li	a0,1
    101e:	d0dff0ef          	jal	d2a <vprintf>
}
    1022:	60e2                	ld	ra,24(sp)
    1024:	6442                	ld	s0,16(sp)
    1026:	6125                	addi	sp,sp,96
    1028:	8082                	ret

000000000000102a <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
    102a:	1141                	addi	sp,sp,-16
    102c:	e422                	sd	s0,8(sp)
    102e:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
    1030:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    1034:	00001797          	auipc	a5,0x1
    1038:	fdc7b783          	ld	a5,-36(a5) # 2010 <freep>
    103c:	a02d                	j	1066 <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
    103e:	4618                	lw	a4,8(a2)
    1040:	9f2d                	addw	a4,a4,a1
    1042:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
    1046:	6398                	ld	a4,0(a5)
    1048:	6310                	ld	a2,0(a4)
    104a:	a83d                	j	1088 <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
    104c:	ff852703          	lw	a4,-8(a0)
    1050:	9f31                	addw	a4,a4,a2
    1052:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
    1054:	ff053683          	ld	a3,-16(a0)
    1058:	a091                	j	109c <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    105a:	6398                	ld	a4,0(a5)
    105c:	00e7e463          	bltu	a5,a4,1064 <free+0x3a>
    1060:	00e6ea63          	bltu	a3,a4,1074 <free+0x4a>
{
    1064:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    1066:	fed7fae3          	bgeu	a5,a3,105a <free+0x30>
    106a:	6398                	ld	a4,0(a5)
    106c:	00e6e463          	bltu	a3,a4,1074 <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    1070:	fee7eae3          	bltu	a5,a4,1064 <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
    1074:	ff852583          	lw	a1,-8(a0)
    1078:	6390                	ld	a2,0(a5)
    107a:	02059813          	slli	a6,a1,0x20
    107e:	01c85713          	srli	a4,a6,0x1c
    1082:	9736                	add	a4,a4,a3
    1084:	fae60de3          	beq	a2,a4,103e <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
    1088:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
    108c:	4790                	lw	a2,8(a5)
    108e:	02061593          	slli	a1,a2,0x20
    1092:	01c5d713          	srli	a4,a1,0x1c
    1096:	973e                	add	a4,a4,a5
    1098:	fae68ae3          	beq	a3,a4,104c <free+0x22>
    p->s.ptr = bp->s.ptr;
    109c:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
    109e:	00001717          	auipc	a4,0x1
    10a2:	f6f73923          	sd	a5,-142(a4) # 2010 <freep>
}
    10a6:	6422                	ld	s0,8(sp)
    10a8:	0141                	addi	sp,sp,16
    10aa:	8082                	ret

00000000000010ac <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
    10ac:	7139                	addi	sp,sp,-64
    10ae:	fc06                	sd	ra,56(sp)
    10b0:	f822                	sd	s0,48(sp)
    10b2:	f426                	sd	s1,40(sp)
    10b4:	ec4e                	sd	s3,24(sp)
    10b6:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
    10b8:	02051493          	slli	s1,a0,0x20
    10bc:	9081                	srli	s1,s1,0x20
    10be:	04bd                	addi	s1,s1,15
    10c0:	8091                	srli	s1,s1,0x4
    10c2:	0014899b          	addiw	s3,s1,1
    10c6:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
    10c8:	00001517          	auipc	a0,0x1
    10cc:	f4853503          	ld	a0,-184(a0) # 2010 <freep>
    10d0:	c915                	beqz	a0,1104 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    10d2:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
    10d4:	4798                	lw	a4,8(a5)
    10d6:	08977a63          	bgeu	a4,s1,116a <malloc+0xbe>
    10da:	f04a                	sd	s2,32(sp)
    10dc:	e852                	sd	s4,16(sp)
    10de:	e456                	sd	s5,8(sp)
    10e0:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
    10e2:	8a4e                	mv	s4,s3
    10e4:	0009871b          	sext.w	a4,s3
    10e8:	6685                	lui	a3,0x1
    10ea:	00d77363          	bgeu	a4,a3,10f0 <malloc+0x44>
    10ee:	6a05                	lui	s4,0x1
    10f0:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
    10f4:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
    10f8:	00001917          	auipc	s2,0x1
    10fc:	f1890913          	addi	s2,s2,-232 # 2010 <freep>
  if(p == SBRK_ERROR)
    1100:	5afd                	li	s5,-1
    1102:	a081                	j	1142 <malloc+0x96>
    1104:	f04a                	sd	s2,32(sp)
    1106:	e852                	sd	s4,16(sp)
    1108:	e456                	sd	s5,8(sp)
    110a:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
    110c:	00001797          	auipc	a5,0x1
    1110:	2fc78793          	addi	a5,a5,764 # 2408 <base>
    1114:	00001717          	auipc	a4,0x1
    1118:	eef73e23          	sd	a5,-260(a4) # 2010 <freep>
    111c:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
    111e:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
    1122:	b7c1                	j	10e2 <malloc+0x36>
        prevp->s.ptr = p->s.ptr;
    1124:	6398                	ld	a4,0(a5)
    1126:	e118                	sd	a4,0(a0)
    1128:	a8a9                	j	1182 <malloc+0xd6>
  hp->s.size = nu;
    112a:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
    112e:	0541                	addi	a0,a0,16
    1130:	efbff0ef          	jal	102a <free>
  return freep;
    1134:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
    1138:	c12d                	beqz	a0,119a <malloc+0xee>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    113a:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
    113c:	4798                	lw	a4,8(a5)
    113e:	02977263          	bgeu	a4,s1,1162 <malloc+0xb6>
    if(p == freep)
    1142:	00093703          	ld	a4,0(s2)
    1146:	853e                	mv	a0,a5
    1148:	fef719e3          	bne	a4,a5,113a <malloc+0x8e>
  p = sbrk(nu * sizeof(Header));
    114c:	8552                	mv	a0,s4
    114e:	9f1ff0ef          	jal	b3e <sbrk>
  if(p == SBRK_ERROR)
    1152:	fd551ce3          	bne	a0,s5,112a <malloc+0x7e>
        return 0;
    1156:	4501                	li	a0,0
    1158:	7902                	ld	s2,32(sp)
    115a:	6a42                	ld	s4,16(sp)
    115c:	6aa2                	ld	s5,8(sp)
    115e:	6b02                	ld	s6,0(sp)
    1160:	a03d                	j	118e <malloc+0xe2>
    1162:	7902                	ld	s2,32(sp)
    1164:	6a42                	ld	s4,16(sp)
    1166:	6aa2                	ld	s5,8(sp)
    1168:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
    116a:	fae48de3          	beq	s1,a4,1124 <malloc+0x78>
        p->s.size -= nunits;
    116e:	4137073b          	subw	a4,a4,s3
    1172:	c798                	sw	a4,8(a5)
        p += p->s.size;
    1174:	02071693          	slli	a3,a4,0x20
    1178:	01c6d713          	srli	a4,a3,0x1c
    117c:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
    117e:	0137a423          	sw	s3,8(a5)
      freep = prevp;
    1182:	00001717          	auipc	a4,0x1
    1186:	e8a73723          	sd	a0,-370(a4) # 2010 <freep>
      return (void*)(p + 1);
    118a:	01078513          	addi	a0,a5,16
  }
}
    118e:	70e2                	ld	ra,56(sp)
    1190:	7442                	ld	s0,48(sp)
    1192:	74a2                	ld	s1,40(sp)
    1194:	69e2                	ld	s3,24(sp)
    1196:	6121                	addi	sp,sp,64
    1198:	8082                	ret
    119a:	7902                	ld	s2,32(sp)
    119c:	6a42                	ld	s4,16(sp)
    119e:	6aa2                	ld	s5,8(sp)
    11a0:	6b02                	ld	s6,0(sp)
    11a2:	b7f5                	j	118e <malloc+0xe2>
