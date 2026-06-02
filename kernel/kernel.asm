
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
_entry:
        # set up a stack for C.
        # stack0 is declared in start.c,
        # with a 4096-byte stack per CPU.
        # sp = stack0 + ((hartid + 1) * 4096)
        la sp, stack0
    80000000:	0000a117          	auipc	sp,0xa
    80000004:	08010113          	addi	sp,sp,128 # 8000a080 <stack0>
        li a0, 1024*4
    80000008:	6505                	lui	a0,0x1
        csrr a1, mhartid
    8000000a:	f14025f3          	csrr	a1,mhartid
        addi a1, a1, 1
    8000000e:	0585                	addi	a1,a1,1
        mul a0, a0, a1
    80000010:	02b50533          	mul	a0,a0,a1
        add sp, sp, a0
    80000014:	912a                	add	sp,sp,a0
        # jump to start() in start.c
        call start
    80000016:	04e000ef          	jal	80000064 <start>

000000008000001a <spin>:
spin:
        j spin
    8000001a:	a001                	j	8000001a <spin>

000000008000001c <timerinit>:
}

// ask each hart to generate timer interrupts.
void
timerinit()
{
    8000001c:	1141                	addi	sp,sp,-16
    8000001e:	e406                	sd	ra,8(sp)
    80000020:	e022                	sd	s0,0(sp)
    80000022:	0800                	addi	s0,sp,16
#define MIE_STIE (1L << 5)  // supervisor timer
static inline uint64
r_mie()
{
  uint64 x;
  asm volatile("csrr %0, mie" : "=r" (x) );
    80000024:	304027f3          	csrr	a5,mie
  // enable supervisor-mode timer interrupts.
  w_mie(r_mie() | MIE_STIE);
    80000028:	0207e793          	ori	a5,a5,32
}

static inline void 
w_mie(uint64 x)
{
  asm volatile("csrw mie, %0" : : "r" (x));
    8000002c:	30479073          	csrw	mie,a5
static inline uint64
r_menvcfg()
{
  uint64 x;
  // asm volatile("csrr %0, menvcfg" : "=r" (x) );
  asm volatile("csrr %0, 0x30a" : "=r" (x) );
    80000030:	30a027f3          	csrr	a5,0x30a
  
  // enable the sstc extension (i.e. stimecmp).
  w_menvcfg(r_menvcfg() | (1L << 63)); 
    80000034:	577d                	li	a4,-1
    80000036:	177e                	slli	a4,a4,0x3f
    80000038:	8fd9                	or	a5,a5,a4

static inline void 
w_menvcfg(uint64 x)
{
  // asm volatile("csrw menvcfg, %0" : : "r" (x));
  asm volatile("csrw 0x30a, %0" : : "r" (x));
    8000003a:	30a79073          	csrw	0x30a,a5

static inline uint64
r_mcounteren()
{
  uint64 x;
  asm volatile("csrr %0, mcounteren" : "=r" (x) );
    8000003e:	306027f3          	csrr	a5,mcounteren
  
  // allow supervisor to use stimecmp and time.
  w_mcounteren(r_mcounteren() | 2);
    80000042:	0027e793          	ori	a5,a5,2
  asm volatile("csrw mcounteren, %0" : : "r" (x));
    80000046:	30679073          	csrw	mcounteren,a5
// machine-mode cycle counter
static inline uint64
r_time()
{
  uint64 x;
  asm volatile("csrr %0, time" : "=r" (x) );
    8000004a:	c01027f3          	rdtime	a5
  
  // ask for the very first timer interrupt.
  w_stimecmp(r_time() + 1000000);
    8000004e:	000f4737          	lui	a4,0xf4
    80000052:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    80000056:	97ba                	add	a5,a5,a4
  asm volatile("csrw 0x14d, %0" : : "r" (x));
    80000058:	14d79073          	csrw	stimecmp,a5
}
    8000005c:	60a2                	ld	ra,8(sp)
    8000005e:	6402                	ld	s0,0(sp)
    80000060:	0141                	addi	sp,sp,16
    80000062:	8082                	ret

0000000080000064 <start>:
{
    80000064:	1141                	addi	sp,sp,-16
    80000066:	e406                	sd	ra,8(sp)
    80000068:	e022                	sd	s0,0(sp)
    8000006a:	0800                	addi	s0,sp,16
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    8000006c:	300027f3          	csrr	a5,mstatus
  x &= ~MSTATUS_MPP_MASK;
    80000070:	7779                	lui	a4,0xffffe
    80000072:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ff6e39f>
    80000076:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    80000078:	6705                	lui	a4,0x1
    8000007a:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    8000007e:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r" (x));
    80000080:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r" (x));
    80000084:	00001797          	auipc	a5,0x1
    80000088:	e5c78793          	addi	a5,a5,-420 # 80000ee0 <main>
    8000008c:	34179073          	csrw	mepc,a5
  asm volatile("csrw satp, %0" : : "r" (x));
    80000090:	4781                	li	a5,0
    80000092:	18079073          	csrw	satp,a5
  asm volatile("csrw medeleg, %0" : : "r" (x));
    80000096:	67c1                	lui	a5,0x10
    80000098:	17fd                	addi	a5,a5,-1 # ffff <_entry-0x7fff0001>
    8000009a:	30279073          	csrw	medeleg,a5
  asm volatile("csrw mideleg, %0" : : "r" (x));
    8000009e:	30379073          	csrw	mideleg,a5
  asm volatile("csrr %0, sie" : "=r" (x) );
    800000a2:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE);
    800000a6:	2207e793          	ori	a5,a5,544
  asm volatile("csrw sie, %0" : : "r" (x));
    800000aa:	10479073          	csrw	sie,a5
  asm volatile("csrw pmpaddr0, %0" : : "r" (x));
    800000ae:	57fd                	li	a5,-1
    800000b0:	83a9                	srli	a5,a5,0xa
    800000b2:	3b079073          	csrw	pmpaddr0,a5
  asm volatile("csrw pmpcfg0, %0" : : "r" (x));
    800000b6:	47bd                	li	a5,15
    800000b8:	3a079073          	csrw	pmpcfg0,a5
  timerinit();
    800000bc:	f61ff0ef          	jal	8000001c <timerinit>
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    800000c0:	f14027f3          	csrr	a5,mhartid
  w_tp(id);
    800000c4:	2781                	sext.w	a5,a5
}

static inline void 
w_tp(uint64 x)
{
  asm volatile("mv tp, %0" : : "r" (x));
    800000c6:	823e                	mv	tp,a5
  asm volatile("mret");
    800000c8:	30200073          	mret
}
    800000cc:	60a2                	ld	ra,8(sp)
    800000ce:	6402                	ld	s0,0(sp)
    800000d0:	0141                	addi	sp,sp,16
    800000d2:	8082                	ret

00000000800000d4 <consolewrite>:

static struct sleeplock conswlock;

int
consolewrite(int user_src, uint64 src, int n)
{
    800000d4:	7115                	addi	sp,sp,-224
    800000d6:	ed86                	sd	ra,216(sp)
    800000d8:	e9a2                	sd	s0,208(sp)
    800000da:	e5a6                	sd	s1,200(sp)
    800000dc:	f952                	sd	s4,176(sp)
    800000de:	f15a                	sd	s6,160(sp)
    800000e0:	ed5e                	sd	s7,152(sp)
    800000e2:	1180                	addi	s0,sp,224
    800000e4:	8b2a                	mv	s6,a0
    800000e6:	8bae                	mv	s7,a1
    800000e8:	8a32                	mv	s4,a2
  char buf[128];
  int i = 0;

  acquiresleep(&conswlock);
    800000ea:	00012517          	auipc	a0,0x12
    800000ee:	f9650513          	addi	a0,a0,-106 # 80012080 <conswlock>
    800000f2:	3bf040ef          	jal	80004cb0 <acquiresleep>

  while(i < n){
    800000f6:	07405263          	blez	s4,8000015a <consolewrite+0x86>
    800000fa:	e1ca                	sd	s2,192(sp)
    800000fc:	fd4e                	sd	s3,184(sp)
    800000fe:	f556                	sd	s5,168(sp)
    80000100:	e962                	sd	s8,144(sp)
    80000102:	e566                	sd	s9,136(sp)
    80000104:	e16a                	sd	s10,128(sp)
  int i = 0;
    80000106:	4481                	li	s1,0
    int nn = sizeof(buf);
    if(nn > n - i)
    80000108:	08000c93          	li	s9,128
    8000010c:	08000d13          	li	s10,128
      nn = n - i;

    if(either_copyin(buf, user_src, src + i, nn) == -1)
    80000110:	f2040a93          	addi	s5,s0,-224
    80000114:	5c7d                	li	s8,-1
    80000116:	a025                	j	8000013e <consolewrite+0x6a>
    if(nn > n - i)
    80000118:	0009099b          	sext.w	s3,s2
    if(either_copyin(buf, user_src, src + i, nn) == -1)
    8000011c:	86ce                	mv	a3,s3
    8000011e:	01748633          	add	a2,s1,s7
    80000122:	85da                	mv	a1,s6
    80000124:	8556                	mv	a0,s5
    80000126:	1fc020ef          	jal	80002322 <either_copyin>
    8000012a:	03850a63          	beq	a0,s8,8000015e <consolewrite+0x8a>
      break;

    uartwrite(buf, nn);
    8000012e:	85ce                	mv	a1,s3
    80000130:	8556                	mv	a0,s5
    80000132:	7da000ef          	jal	8000090c <uartwrite>
    i += nn;
    80000136:	009904bb          	addw	s1,s2,s1
  while(i < n){
    8000013a:	0144d963          	bge	s1,s4,8000014c <consolewrite+0x78>
    if(nn > n - i)
    8000013e:	409a07bb          	subw	a5,s4,s1
    80000142:	893e                	mv	s2,a5
    80000144:	fcfcdae3          	bge	s9,a5,80000118 <consolewrite+0x44>
    80000148:	896a                	mv	s2,s10
    8000014a:	b7f9                	j	80000118 <consolewrite+0x44>
    8000014c:	690e                	ld	s2,192(sp)
    8000014e:	79ea                	ld	s3,184(sp)
    80000150:	7aaa                	ld	s5,168(sp)
    80000152:	6c4a                	ld	s8,144(sp)
    80000154:	6caa                	ld	s9,136(sp)
    80000156:	6d0a                	ld	s10,128(sp)
    80000158:	a809                	j	8000016a <consolewrite+0x96>
  int i = 0;
    8000015a:	4481                	li	s1,0
    8000015c:	a039                	j	8000016a <consolewrite+0x96>
    8000015e:	690e                	ld	s2,192(sp)
    80000160:	79ea                	ld	s3,184(sp)
    80000162:	7aaa                	ld	s5,168(sp)
    80000164:	6c4a                	ld	s8,144(sp)
    80000166:	6caa                	ld	s9,136(sp)
    80000168:	6d0a                	ld	s10,128(sp)
  }

  releasesleep(&conswlock);
    8000016a:	00012517          	auipc	a0,0x12
    8000016e:	f1650513          	addi	a0,a0,-234 # 80012080 <conswlock>
    80000172:	385040ef          	jal	80004cf6 <releasesleep>
  return i;
}
    80000176:	8526                	mv	a0,s1
    80000178:	60ee                	ld	ra,216(sp)
    8000017a:	644e                	ld	s0,208(sp)
    8000017c:	64ae                	ld	s1,200(sp)
    8000017e:	7a4a                	ld	s4,176(sp)
    80000180:	7b0a                	ld	s6,160(sp)
    80000182:	6bea                	ld	s7,152(sp)
    80000184:	612d                	addi	sp,sp,224
    80000186:	8082                	ret

0000000080000188 <consoleread>:

int
consoleread(int user_dst, uint64 dst, int n)
{
    80000188:	711d                	addi	sp,sp,-96
    8000018a:	ec86                	sd	ra,88(sp)
    8000018c:	e8a2                	sd	s0,80(sp)
    8000018e:	e4a6                	sd	s1,72(sp)
    80000190:	e0ca                	sd	s2,64(sp)
    80000192:	fc4e                	sd	s3,56(sp)
    80000194:	f852                	sd	s4,48(sp)
    80000196:	f456                	sd	s5,40(sp)
    80000198:	ec5e                	sd	s7,24(sp)
    8000019a:	e862                	sd	s8,16(sp)
    8000019c:	1080                	addi	s0,sp,96
    8000019e:	8baa                	mv	s7,a0
    800001a0:	8aae                	mv	s5,a1
    800001a2:	8a32                	mv	s4,a2
  uint target;
  int c;
  char cbuf;

  target = n;
    800001a4:	8c32                	mv	s8,a2
  acquire(&cons.lock);
    800001a6:	00012517          	auipc	a0,0x12
    800001aa:	f0a50513          	addi	a0,a0,-246 # 800120b0 <cons>
    800001ae:	2ad000ef          	jal	80000c5a <acquire>

  while(n > 0){
    while(cons.r == cons.w){
    800001b2:	00012497          	auipc	s1,0x12
    800001b6:	ece48493          	addi	s1,s1,-306 # 80012080 <conswlock>
      if(killed(myproc())){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    800001ba:	00012997          	auipc	s3,0x12
    800001be:	ef698993          	addi	s3,s3,-266 # 800120b0 <cons>
    800001c2:	00012917          	auipc	s2,0x12
    800001c6:	f8690913          	addi	s2,s2,-122 # 80012148 <cons+0x98>
  while(n > 0){
    800001ca:	0b405c63          	blez	s4,80000282 <consoleread+0xfa>
    while(cons.r == cons.w){
    800001ce:	0c84a783          	lw	a5,200(s1)
    800001d2:	0cc4a703          	lw	a4,204(s1)
    800001d6:	0af71163          	bne	a4,a5,80000278 <consoleread+0xf0>
      if(killed(myproc())){
    800001da:	78e010ef          	jal	80001968 <myproc>
    800001de:	7dd010ef          	jal	800021ba <killed>
    800001e2:	e12d                	bnez	a0,80000244 <consoleread+0xbc>
      sleep(&cons.r, &cons.lock);
    800001e4:	85ce                	mv	a1,s3
    800001e6:	854a                	mv	a0,s2
    800001e8:	597010ef          	jal	80001f7e <sleep>
    while(cons.r == cons.w){
    800001ec:	0c84a783          	lw	a5,200(s1)
    800001f0:	0cc4a703          	lw	a4,204(s1)
    800001f4:	fef703e3          	beq	a4,a5,800001da <consoleread+0x52>
    800001f8:	f05a                	sd	s6,32(sp)
    }

    c = cons.buf[cons.r++ % INPUT_BUF_SIZE];
    800001fa:	00012717          	auipc	a4,0x12
    800001fe:	e8670713          	addi	a4,a4,-378 # 80012080 <conswlock>
    80000202:	0017869b          	addiw	a3,a5,1
    80000206:	0cd72423          	sw	a3,200(a4)
    8000020a:	07f7f693          	andi	a3,a5,127
    8000020e:	9736                	add	a4,a4,a3
    80000210:	04874703          	lbu	a4,72(a4)
    80000214:	00070b1b          	sext.w	s6,a4

    if(c == C('D')){
    80000218:	4691                	li	a3,4
    8000021a:	04db0763          	beq	s6,a3,80000268 <consoleread+0xe0>
        cons.r--;
      }
      break;
    }

    cbuf = c;
    8000021e:	fae407a3          	sb	a4,-81(s0)
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    80000222:	4685                	li	a3,1
    80000224:	faf40613          	addi	a2,s0,-81
    80000228:	85d6                	mv	a1,s5
    8000022a:	855e                	mv	a0,s7
    8000022c:	0ac020ef          	jal	800022d8 <either_copyout>
    80000230:	57fd                	li	a5,-1
    80000232:	04f50763          	beq	a0,a5,80000280 <consoleread+0xf8>
      break;

    dst++;
    80000236:	0a85                	addi	s5,s5,1
    --n;
    80000238:	3a7d                	addiw	s4,s4,-1

    if(c == '\n'){
    8000023a:	47a9                	li	a5,10
    8000023c:	04fb0c63          	beq	s6,a5,80000294 <consoleread+0x10c>
    80000240:	7b02                	ld	s6,32(sp)
    80000242:	b761                	j	800001ca <consoleread+0x42>
        release(&cons.lock);
    80000244:	00012517          	auipc	a0,0x12
    80000248:	e6c50513          	addi	a0,a0,-404 # 800120b0 <cons>
    8000024c:	2a3000ef          	jal	80000cee <release>
        return -1;
    80000250:	557d                	li	a0,-1
    }
  }

  release(&cons.lock);
  return target - n;
}
    80000252:	60e6                	ld	ra,88(sp)
    80000254:	6446                	ld	s0,80(sp)
    80000256:	64a6                	ld	s1,72(sp)
    80000258:	6906                	ld	s2,64(sp)
    8000025a:	79e2                	ld	s3,56(sp)
    8000025c:	7a42                	ld	s4,48(sp)
    8000025e:	7aa2                	ld	s5,40(sp)
    80000260:	6be2                	ld	s7,24(sp)
    80000262:	6c42                	ld	s8,16(sp)
    80000264:	6125                	addi	sp,sp,96
    80000266:	8082                	ret
      if(n < target){
    80000268:	018a7a63          	bgeu	s4,s8,8000027c <consoleread+0xf4>
        cons.r--;
    8000026c:	00012717          	auipc	a4,0x12
    80000270:	ecf72e23          	sw	a5,-292(a4) # 80012148 <cons+0x98>
    80000274:	7b02                	ld	s6,32(sp)
    80000276:	a031                	j	80000282 <consoleread+0xfa>
    80000278:	f05a                	sd	s6,32(sp)
    8000027a:	b741                	j	800001fa <consoleread+0x72>
    8000027c:	7b02                	ld	s6,32(sp)
    8000027e:	a011                	j	80000282 <consoleread+0xfa>
    80000280:	7b02                	ld	s6,32(sp)
  release(&cons.lock);
    80000282:	00012517          	auipc	a0,0x12
    80000286:	e2e50513          	addi	a0,a0,-466 # 800120b0 <cons>
    8000028a:	265000ef          	jal	80000cee <release>
  return target - n;
    8000028e:	414c053b          	subw	a0,s8,s4
    80000292:	b7c1                	j	80000252 <consoleread+0xca>
    80000294:	7b02                	ld	s6,32(sp)
    80000296:	b7f5                	j	80000282 <consoleread+0xfa>

0000000080000298 <consputc>:
{
    80000298:	1141                	addi	sp,sp,-16
    8000029a:	e406                	sd	ra,8(sp)
    8000029c:	e022                	sd	s0,0(sp)
    8000029e:	0800                	addi	s0,sp,16
  if(c == BACKSPACE){
    800002a0:	10000793          	li	a5,256
    800002a4:	00f50863          	beq	a0,a5,800002b4 <consputc+0x1c>
    uartputc_sync(c);
    800002a8:	6f8000ef          	jal	800009a0 <uartputc_sync>
}
    800002ac:	60a2                	ld	ra,8(sp)
    800002ae:	6402                	ld	s0,0(sp)
    800002b0:	0141                	addi	sp,sp,16
    800002b2:	8082                	ret
    uartputc_sync('\b');
    800002b4:	4521                	li	a0,8
    800002b6:	6ea000ef          	jal	800009a0 <uartputc_sync>
    uartputc_sync(' ');
    800002ba:	02000513          	li	a0,32
    800002be:	6e2000ef          	jal	800009a0 <uartputc_sync>
    uartputc_sync('\b');
    800002c2:	4521                	li	a0,8
    800002c4:	6dc000ef          	jal	800009a0 <uartputc_sync>
    800002c8:	b7d5                	j	800002ac <consputc+0x14>

00000000800002ca <consoleintr>:

void
consoleintr(int c)
{
    800002ca:	1101                	addi	sp,sp,-32
    800002cc:	ec06                	sd	ra,24(sp)
    800002ce:	e822                	sd	s0,16(sp)
    800002d0:	e426                	sd	s1,8(sp)
    800002d2:	1000                	addi	s0,sp,32
    800002d4:	84aa                	mv	s1,a0
  acquire(&cons.lock);
    800002d6:	00012517          	auipc	a0,0x12
    800002da:	dda50513          	addi	a0,a0,-550 # 800120b0 <cons>
    800002de:	17d000ef          	jal	80000c5a <acquire>

  switch(c){
    800002e2:	47d5                	li	a5,21
    800002e4:	08f48d63          	beq	s1,a5,8000037e <consoleintr+0xb4>
    800002e8:	0297c563          	blt	a5,s1,80000312 <consoleintr+0x48>
    800002ec:	47a1                	li	a5,8
    800002ee:	0ef48263          	beq	s1,a5,800003d2 <consoleintr+0x108>
    800002f2:	47c1                	li	a5,16
    800002f4:	10f49363          	bne	s1,a5,800003fa <consoleintr+0x130>
  case C('P'):
    procdump();
    800002f8:	074020ef          	jal	8000236c <procdump>
      }
    }
    break;
  }

  release(&cons.lock);
    800002fc:	00012517          	auipc	a0,0x12
    80000300:	db450513          	addi	a0,a0,-588 # 800120b0 <cons>
    80000304:	1eb000ef          	jal	80000cee <release>
}
    80000308:	60e2                	ld	ra,24(sp)
    8000030a:	6442                	ld	s0,16(sp)
    8000030c:	64a2                	ld	s1,8(sp)
    8000030e:	6105                	addi	sp,sp,32
    80000310:	8082                	ret
  switch(c){
    80000312:	07f00793          	li	a5,127
    80000316:	0af48e63          	beq	s1,a5,800003d2 <consoleintr+0x108>
    if(c != 0 && cons.e - cons.r < INPUT_BUF_SIZE){
    8000031a:	00012717          	auipc	a4,0x12
    8000031e:	d6670713          	addi	a4,a4,-666 # 80012080 <conswlock>
    80000322:	0d072783          	lw	a5,208(a4)
    80000326:	0c872703          	lw	a4,200(a4)
    8000032a:	9f99                	subw	a5,a5,a4
    8000032c:	07f00713          	li	a4,127
    80000330:	fcf766e3          	bltu	a4,a5,800002fc <consoleintr+0x32>
      c = (c == '\r') ? '\n' : c;
    80000334:	47b5                	li	a5,13
    80000336:	0cf48563          	beq	s1,a5,80000400 <consoleintr+0x136>
      consputc(c);
    8000033a:	8526                	mv	a0,s1
    8000033c:	f5dff0ef          	jal	80000298 <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    80000340:	00012717          	auipc	a4,0x12
    80000344:	d4070713          	addi	a4,a4,-704 # 80012080 <conswlock>
    80000348:	0d072683          	lw	a3,208(a4)
    8000034c:	0016879b          	addiw	a5,a3,1
    80000350:	863e                	mv	a2,a5
    80000352:	0cf72823          	sw	a5,208(a4)
    80000356:	07f6f693          	andi	a3,a3,127
    8000035a:	9736                	add	a4,a4,a3
    8000035c:	04970423          	sb	s1,72(a4)
      if(c == '\n' || c == C('D') || cons.e - cons.r == INPUT_BUF_SIZE){
    80000360:	ff648713          	addi	a4,s1,-10
    80000364:	c371                	beqz	a4,80000428 <consoleintr+0x15e>
    80000366:	14f1                	addi	s1,s1,-4
    80000368:	c0e1                	beqz	s1,80000428 <consoleintr+0x15e>
    8000036a:	00012717          	auipc	a4,0x12
    8000036e:	dde72703          	lw	a4,-546(a4) # 80012148 <cons+0x98>
    80000372:	9f99                	subw	a5,a5,a4
    80000374:	08000713          	li	a4,128
    80000378:	f8e792e3          	bne	a5,a4,800002fc <consoleintr+0x32>
    8000037c:	a075                	j	80000428 <consoleintr+0x15e>
    8000037e:	e04a                	sd	s2,0(sp)
    while(cons.e != cons.w &&
    80000380:	00012717          	auipc	a4,0x12
    80000384:	d0070713          	addi	a4,a4,-768 # 80012080 <conswlock>
    80000388:	0d072783          	lw	a5,208(a4)
    8000038c:	0cc72703          	lw	a4,204(a4)
          cons.buf[(cons.e - 1) % INPUT_BUF_SIZE] != '\n'){
    80000390:	00012497          	auipc	s1,0x12
    80000394:	cf048493          	addi	s1,s1,-784 # 80012080 <conswlock>
    while(cons.e != cons.w &&
    80000398:	4929                	li	s2,10
    8000039a:	02f70863          	beq	a4,a5,800003ca <consoleintr+0x100>
          cons.buf[(cons.e - 1) % INPUT_BUF_SIZE] != '\n'){
    8000039e:	37fd                	addiw	a5,a5,-1
    800003a0:	07f7f713          	andi	a4,a5,127
    800003a4:	9726                	add	a4,a4,s1
    while(cons.e != cons.w &&
    800003a6:	04874703          	lbu	a4,72(a4)
    800003aa:	03270263          	beq	a4,s2,800003ce <consoleintr+0x104>
      cons.e--;
    800003ae:	0cf4a823          	sw	a5,208(s1)
      consputc(BACKSPACE);
    800003b2:	10000513          	li	a0,256
    800003b6:	ee3ff0ef          	jal	80000298 <consputc>
    while(cons.e != cons.w &&
    800003ba:	0d04a783          	lw	a5,208(s1)
    800003be:	0cc4a703          	lw	a4,204(s1)
    800003c2:	fcf71ee3          	bne	a4,a5,8000039e <consoleintr+0xd4>
    800003c6:	6902                	ld	s2,0(sp)
    800003c8:	bf15                	j	800002fc <consoleintr+0x32>
    800003ca:	6902                	ld	s2,0(sp)
    800003cc:	bf05                	j	800002fc <consoleintr+0x32>
    800003ce:	6902                	ld	s2,0(sp)
    800003d0:	b735                	j	800002fc <consoleintr+0x32>
    if(cons.e != cons.w){
    800003d2:	00012717          	auipc	a4,0x12
    800003d6:	cae70713          	addi	a4,a4,-850 # 80012080 <conswlock>
    800003da:	0d072783          	lw	a5,208(a4)
    800003de:	0cc72703          	lw	a4,204(a4)
    800003e2:	f0f70de3          	beq	a4,a5,800002fc <consoleintr+0x32>
      cons.e--;
    800003e6:	37fd                	addiw	a5,a5,-1
    800003e8:	00012717          	auipc	a4,0x12
    800003ec:	d6f72423          	sw	a5,-664(a4) # 80012150 <cons+0xa0>
      consputc(BACKSPACE);
    800003f0:	10000513          	li	a0,256
    800003f4:	ea5ff0ef          	jal	80000298 <consputc>
    800003f8:	b711                	j	800002fc <consoleintr+0x32>
    if(c != 0 && cons.e - cons.r < INPUT_BUF_SIZE){
    800003fa:	f00481e3          	beqz	s1,800002fc <consoleintr+0x32>
    800003fe:	bf31                	j	8000031a <consoleintr+0x50>
      consputc(c);
    80000400:	4529                	li	a0,10
    80000402:	e97ff0ef          	jal	80000298 <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    80000406:	00012797          	auipc	a5,0x12
    8000040a:	c7a78793          	addi	a5,a5,-902 # 80012080 <conswlock>
    8000040e:	0d07a703          	lw	a4,208(a5)
    80000412:	0017069b          	addiw	a3,a4,1
    80000416:	8636                	mv	a2,a3
    80000418:	0cd7a823          	sw	a3,208(a5)
    8000041c:	07f77713          	andi	a4,a4,127
    80000420:	97ba                	add	a5,a5,a4
    80000422:	4729                	li	a4,10
    80000424:	04e78423          	sb	a4,72(a5)
        cons.w = cons.e;
    80000428:	00012797          	auipc	a5,0x12
    8000042c:	d2c7a223          	sw	a2,-732(a5) # 8001214c <cons+0x9c>
        wakeup(&cons.r);
    80000430:	00012517          	auipc	a0,0x12
    80000434:	d1850513          	addi	a0,a0,-744 # 80012148 <cons+0x98>
    80000438:	393010ef          	jal	80001fca <wakeup>
    8000043c:	b5c1                	j	800002fc <consoleintr+0x32>

000000008000043e <consoleinit>:

void
consoleinit(void)
{
    8000043e:	1141                	addi	sp,sp,-16
    80000440:	e406                	sd	ra,8(sp)
    80000442:	e022                	sd	s0,0(sp)
    80000444:	0800                	addi	s0,sp,16
  initlock(&cons.lock, "cons");
    80000446:	00009597          	auipc	a1,0x9
    8000044a:	bba58593          	addi	a1,a1,-1094 # 80009000 <etext>
    8000044e:	00012517          	auipc	a0,0x12
    80000452:	c6250513          	addi	a0,a0,-926 # 800120b0 <cons>
    80000456:	77a000ef          	jal	80000bd0 <initlock>
  initsleeplock(&conswlock, "consw");
    8000045a:	00009597          	auipc	a1,0x9
    8000045e:	bae58593          	addi	a1,a1,-1106 # 80009008 <etext+0x8>
    80000462:	00012517          	auipc	a0,0x12
    80000466:	c1e50513          	addi	a0,a0,-994 # 80012080 <conswlock>
    8000046a:	011040ef          	jal	80004c7a <initsleeplock>

  uartinit();
    8000046e:	448000ef          	jal	800008b6 <uartinit>

  devsw[CONSOLE].read = consoleread;
    80000472:	00022797          	auipc	a5,0x22
    80000476:	dae78793          	addi	a5,a5,-594 # 80022220 <devsw>
    8000047a:	00000717          	auipc	a4,0x0
    8000047e:	d0e70713          	addi	a4,a4,-754 # 80000188 <consoleread>
    80000482:	eb98                	sd	a4,16(a5)
  devsw[CONSOLE].write = consolewrite;
    80000484:	00000717          	auipc	a4,0x0
    80000488:	c5070713          	addi	a4,a4,-944 # 800000d4 <consolewrite>
    8000048c:	ef98                	sd	a4,24(a5)
    8000048e:	60a2                	ld	ra,8(sp)
    80000490:	6402                	ld	s0,0(sp)
    80000492:	0141                	addi	sp,sp,16
    80000494:	8082                	ret

0000000080000496 <printint>:

static char digits[] = "0123456789abcdef";

static void
printint(long long xx, int base, int sign)
{
    80000496:	7139                	addi	sp,sp,-64
    80000498:	fc06                	sd	ra,56(sp)
    8000049a:	f822                	sd	s0,48(sp)
    8000049c:	f04a                	sd	s2,32(sp)
    8000049e:	0080                	addi	s0,sp,64
  char buf[20];
  int i;
  unsigned long long x;

  if(sign && (sign = (xx < 0)))
    800004a0:	c219                	beqz	a2,800004a6 <printint+0x10>
    800004a2:	08054163          	bltz	a0,80000524 <printint+0x8e>
    x = -xx;
  else
    x = xx;
    800004a6:	4301                	li	t1,0

  i = 0;
    800004a8:	fc840913          	addi	s2,s0,-56
    x = xx;
    800004ac:	86ca                	mv	a3,s2
  i = 0;
    800004ae:	4701                	li	a4,0
  do {
    buf[i++] = digits[x % base];
    800004b0:	0000a817          	auipc	a6,0xa
    800004b4:	a2080813          	addi	a6,a6,-1504 # 80009ed0 <digits>
    800004b8:	88ba                	mv	a7,a4
    800004ba:	0017061b          	addiw	a2,a4,1
    800004be:	8732                	mv	a4,a2
    800004c0:	02b577b3          	remu	a5,a0,a1
    800004c4:	97c2                	add	a5,a5,a6
    800004c6:	0007c783          	lbu	a5,0(a5)
    800004ca:	00f68023          	sb	a5,0(a3)
  } while((x /= base) != 0);
    800004ce:	87aa                	mv	a5,a0
    800004d0:	02b55533          	divu	a0,a0,a1
    800004d4:	0685                	addi	a3,a3,1
    800004d6:	feb7f1e3          	bgeu	a5,a1,800004b8 <printint+0x22>

  if(sign)
    800004da:	00030c63          	beqz	t1,800004f2 <printint+0x5c>
    buf[i++] = '-';
    800004de:	fe060793          	addi	a5,a2,-32
    800004e2:	00878633          	add	a2,a5,s0
    800004e6:	02d00793          	li	a5,45
    800004ea:	fef60423          	sb	a5,-24(a2)
    800004ee:	0028871b          	addiw	a4,a7,2

  while(--i >= 0)
    800004f2:	02e05463          	blez	a4,8000051a <printint+0x84>
    800004f6:	f426                	sd	s1,40(sp)
    800004f8:	377d                	addiw	a4,a4,-1
    800004fa:	00e904b3          	add	s1,s2,a4
    800004fe:	197d                	addi	s2,s2,-1
    80000500:	993a                	add	s2,s2,a4
    80000502:	1702                	slli	a4,a4,0x20
    80000504:	9301                	srli	a4,a4,0x20
    80000506:	40e90933          	sub	s2,s2,a4
    consputc(buf[i]);
    8000050a:	0004c503          	lbu	a0,0(s1)
    8000050e:	d8bff0ef          	jal	80000298 <consputc>
  while(--i >= 0)
    80000512:	14fd                	addi	s1,s1,-1
    80000514:	ff249be3          	bne	s1,s2,8000050a <printint+0x74>
    80000518:	74a2                	ld	s1,40(sp)
}
    8000051a:	70e2                	ld	ra,56(sp)
    8000051c:	7442                	ld	s0,48(sp)
    8000051e:	7902                	ld	s2,32(sp)
    80000520:	6121                	addi	sp,sp,64
    80000522:	8082                	ret
    x = -xx;
    80000524:	40a00533          	neg	a0,a0
  if(sign && (sign = (xx < 0)))
    80000528:	4305                	li	t1,1
    x = -xx;
    8000052a:	bfbd                	j	800004a8 <printint+0x12>

000000008000052c <printf>:
}

// Print to the console.
int
printf(char *fmt, ...)
{
    8000052c:	7131                	addi	sp,sp,-192
    8000052e:	fc86                	sd	ra,120(sp)
    80000530:	f8a2                	sd	s0,112(sp)
    80000532:	f0ca                	sd	s2,96(sp)
    80000534:	0100                	addi	s0,sp,128
    80000536:	892a                	mv	s2,a0
    80000538:	e40c                	sd	a1,8(s0)
    8000053a:	e810                	sd	a2,16(s0)
    8000053c:	ec14                	sd	a3,24(s0)
    8000053e:	f018                	sd	a4,32(s0)
    80000540:	f41c                	sd	a5,40(s0)
    80000542:	03043823          	sd	a6,48(s0)
    80000546:	03143c23          	sd	a7,56(s0)
  va_list ap;
  int i, cx, c0, c1, c2;
  char *s;

  if(panicking == 0)
    8000054a:	0000a797          	auipc	a5,0xa
    8000054e:	ada7a783          	lw	a5,-1318(a5) # 8000a024 <panicking>
    80000552:	cf9d                	beqz	a5,80000590 <printf+0x64>
    acquire(&pr.lock);

  va_start(ap, fmt);
    80000554:	00840793          	addi	a5,s0,8
    80000558:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; (cx = fmt[i] & 0xff) != 0; i++){
    8000055c:	00094503          	lbu	a0,0(s2)
    80000560:	22050663          	beqz	a0,8000078c <printf+0x260>
    80000564:	f4a6                	sd	s1,104(sp)
    80000566:	ecce                	sd	s3,88(sp)
    80000568:	e8d2                	sd	s4,80(sp)
    8000056a:	e4d6                	sd	s5,72(sp)
    8000056c:	e0da                	sd	s6,64(sp)
    8000056e:	fc5e                	sd	s7,56(sp)
    80000570:	f862                	sd	s8,48(sp)
    80000572:	f06a                	sd	s10,32(sp)
    80000574:	ec6e                	sd	s11,24(sp)
    80000576:	4a01                	li	s4,0
    if(cx != '%'){
    80000578:	02500993          	li	s3,37
      printint(va_arg(ap, uint64), 10, 1);
      i += 1;
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
      printint(va_arg(ap, uint64), 10, 1);
      i += 2;
    } else if(c0 == 'u'){
    8000057c:	07500c13          	li	s8,117
      printint(va_arg(ap, uint64), 10, 0);
      i += 1;
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
      printint(va_arg(ap, uint64), 10, 0);
      i += 2;
    } else if(c0 == 'x'){
    80000580:	07800d13          	li	s10,120
      printint(va_arg(ap, uint64), 16, 0);
      i += 1;
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
      printint(va_arg(ap, uint64), 16, 0);
      i += 2;
    } else if(c0 == 'p'){
    80000584:	07000d93          	li	s11,112
      printint(va_arg(ap, uint64), 10, 0);
    80000588:	4b29                	li	s6,10
    if(c0 == 'd'){
    8000058a:	06400b93          	li	s7,100
    8000058e:	a015                	j	800005b2 <printf+0x86>
    acquire(&pr.lock);
    80000590:	00012517          	auipc	a0,0x12
    80000594:	bc850513          	addi	a0,a0,-1080 # 80012158 <pr>
    80000598:	6c2000ef          	jal	80000c5a <acquire>
    8000059c:	bf65                	j	80000554 <printf+0x28>
      consputc(cx);
    8000059e:	cfbff0ef          	jal	80000298 <consputc>
      continue;
    800005a2:	84d2                	mv	s1,s4
  for(i = 0; (cx = fmt[i] & 0xff) != 0; i++){
    800005a4:	2485                	addiw	s1,s1,1
    800005a6:	8a26                	mv	s4,s1
    800005a8:	94ca                	add	s1,s1,s2
    800005aa:	0004c503          	lbu	a0,0(s1)
    800005ae:	1c050663          	beqz	a0,8000077a <printf+0x24e>
    if(cx != '%'){
    800005b2:	ff3516e3          	bne	a0,s3,8000059e <printf+0x72>
    i++;
    800005b6:	001a079b          	addiw	a5,s4,1
    800005ba:	84be                	mv	s1,a5
    c0 = fmt[i+0] & 0xff;
    800005bc:	00f90733          	add	a4,s2,a5
    800005c0:	00074a83          	lbu	s5,0(a4)
    if(c0) c1 = fmt[i+1] & 0xff;
    800005c4:	200a8963          	beqz	s5,800007d6 <printf+0x2aa>
    800005c8:	00174683          	lbu	a3,1(a4)
    if(c1) c2 = fmt[i+2] & 0xff;
    800005cc:	1e068c63          	beqz	a3,800007c4 <printf+0x298>
    if(c0 == 'd'){
    800005d0:	037a8863          	beq	s5,s7,80000600 <printf+0xd4>
    } else if(c0 == 'l' && c1 == 'd'){
    800005d4:	f94a8713          	addi	a4,s5,-108
    800005d8:	00173713          	seqz	a4,a4
    800005dc:	f9c68613          	addi	a2,a3,-100
    800005e0:	ee05                	bnez	a2,80000618 <printf+0xec>
    800005e2:	cb1d                	beqz	a4,80000618 <printf+0xec>
      printint(va_arg(ap, uint64), 10, 1);
    800005e4:	f8843783          	ld	a5,-120(s0)
    800005e8:	00878713          	addi	a4,a5,8
    800005ec:	f8e43423          	sd	a4,-120(s0)
    800005f0:	4605                	li	a2,1
    800005f2:	85da                	mv	a1,s6
    800005f4:	6388                	ld	a0,0(a5)
    800005f6:	ea1ff0ef          	jal	80000496 <printint>
      i += 1;
    800005fa:	002a049b          	addiw	s1,s4,2
    800005fe:	b75d                	j	800005a4 <printf+0x78>
      printint(va_arg(ap, int), 10, 1);
    80000600:	f8843783          	ld	a5,-120(s0)
    80000604:	00878713          	addi	a4,a5,8
    80000608:	f8e43423          	sd	a4,-120(s0)
    8000060c:	4605                	li	a2,1
    8000060e:	85da                	mv	a1,s6
    80000610:	4388                	lw	a0,0(a5)
    80000612:	e85ff0ef          	jal	80000496 <printint>
    80000616:	b779                	j	800005a4 <printf+0x78>
    if(c1) c2 = fmt[i+2] & 0xff;
    80000618:	97ca                	add	a5,a5,s2
    8000061a:	8636                	mv	a2,a3
    8000061c:	0027c683          	lbu	a3,2(a5)
    80000620:	a2c9                	j	800007e2 <printf+0x2b6>
      printint(va_arg(ap, uint64), 10, 1);
    80000622:	f8843783          	ld	a5,-120(s0)
    80000626:	00878713          	addi	a4,a5,8
    8000062a:	f8e43423          	sd	a4,-120(s0)
    8000062e:	4605                	li	a2,1
    80000630:	45a9                	li	a1,10
    80000632:	6388                	ld	a0,0(a5)
    80000634:	e63ff0ef          	jal	80000496 <printint>
      i += 2;
    80000638:	003a049b          	addiw	s1,s4,3
    8000063c:	b7a5                	j	800005a4 <printf+0x78>
      printint(va_arg(ap, uint32), 10, 0);
    8000063e:	f8843783          	ld	a5,-120(s0)
    80000642:	00878713          	addi	a4,a5,8
    80000646:	f8e43423          	sd	a4,-120(s0)
    8000064a:	4601                	li	a2,0
    8000064c:	85da                	mv	a1,s6
    8000064e:	0007e503          	lwu	a0,0(a5)
    80000652:	e45ff0ef          	jal	80000496 <printint>
    80000656:	b7b9                	j	800005a4 <printf+0x78>
      printint(va_arg(ap, uint64), 10, 0);
    80000658:	f8843783          	ld	a5,-120(s0)
    8000065c:	00878713          	addi	a4,a5,8
    80000660:	f8e43423          	sd	a4,-120(s0)
    80000664:	4601                	li	a2,0
    80000666:	85da                	mv	a1,s6
    80000668:	6388                	ld	a0,0(a5)
    8000066a:	e2dff0ef          	jal	80000496 <printint>
      i += 1;
    8000066e:	002a049b          	addiw	s1,s4,2
    80000672:	bf0d                	j	800005a4 <printf+0x78>
      printint(va_arg(ap, uint64), 10, 0);
    80000674:	f8843783          	ld	a5,-120(s0)
    80000678:	00878713          	addi	a4,a5,8
    8000067c:	f8e43423          	sd	a4,-120(s0)
    80000680:	4601                	li	a2,0
    80000682:	45a9                	li	a1,10
    80000684:	6388                	ld	a0,0(a5)
    80000686:	e11ff0ef          	jal	80000496 <printint>
      i += 2;
    8000068a:	003a049b          	addiw	s1,s4,3
    8000068e:	bf19                	j	800005a4 <printf+0x78>
      printint(va_arg(ap, uint32), 16, 0);
    80000690:	f8843783          	ld	a5,-120(s0)
    80000694:	00878713          	addi	a4,a5,8
    80000698:	f8e43423          	sd	a4,-120(s0)
    8000069c:	4601                	li	a2,0
    8000069e:	45c1                	li	a1,16
    800006a0:	0007e503          	lwu	a0,0(a5)
    800006a4:	df3ff0ef          	jal	80000496 <printint>
    800006a8:	bdf5                	j	800005a4 <printf+0x78>
      printint(va_arg(ap, uint64), 16, 0);
    800006aa:	f8843783          	ld	a5,-120(s0)
    800006ae:	00878713          	addi	a4,a5,8
    800006b2:	f8e43423          	sd	a4,-120(s0)
    800006b6:	45c1                	li	a1,16
    800006b8:	6388                	ld	a0,0(a5)
    800006ba:	dddff0ef          	jal	80000496 <printint>
      i += 1;
    800006be:	002a049b          	addiw	s1,s4,2
    800006c2:	b5cd                	j	800005a4 <printf+0x78>
      printint(va_arg(ap, uint64), 16, 0);
    800006c4:	f8843783          	ld	a5,-120(s0)
    800006c8:	00878713          	addi	a4,a5,8
    800006cc:	f8e43423          	sd	a4,-120(s0)
    800006d0:	4601                	li	a2,0
    800006d2:	45c1                	li	a1,16
    800006d4:	6388                	ld	a0,0(a5)
    800006d6:	dc1ff0ef          	jal	80000496 <printint>
      i += 2;
    800006da:	003a049b          	addiw	s1,s4,3
    800006de:	b5d9                	j	800005a4 <printf+0x78>
    800006e0:	f466                	sd	s9,40(sp)
      printptr(va_arg(ap, uint64));
    800006e2:	f8843783          	ld	a5,-120(s0)
    800006e6:	00878713          	addi	a4,a5,8
    800006ea:	f8e43423          	sd	a4,-120(s0)
    800006ee:	0007ba83          	ld	s5,0(a5)
  consputc('0');
    800006f2:	03000513          	li	a0,48
    800006f6:	ba3ff0ef          	jal	80000298 <consputc>
  consputc('x');
    800006fa:	07800513          	li	a0,120
    800006fe:	b9bff0ef          	jal	80000298 <consputc>
    80000702:	4a41                	li	s4,16
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    80000704:	00009c97          	auipc	s9,0x9
    80000708:	7ccc8c93          	addi	s9,s9,1996 # 80009ed0 <digits>
    8000070c:	03cad793          	srli	a5,s5,0x3c
    80000710:	97e6                	add	a5,a5,s9
    80000712:	0007c503          	lbu	a0,0(a5)
    80000716:	b83ff0ef          	jal	80000298 <consputc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    8000071a:	0a92                	slli	s5,s5,0x4
    8000071c:	3a7d                	addiw	s4,s4,-1
    8000071e:	fe0a17e3          	bnez	s4,8000070c <printf+0x1e0>
    80000722:	7ca2                	ld	s9,40(sp)
    80000724:	b541                	j	800005a4 <printf+0x78>
    } else if(c0 == 'c'){
      consputc(va_arg(ap, uint));
    80000726:	f8843783          	ld	a5,-120(s0)
    8000072a:	00878713          	addi	a4,a5,8
    8000072e:	f8e43423          	sd	a4,-120(s0)
    80000732:	4388                	lw	a0,0(a5)
    80000734:	b65ff0ef          	jal	80000298 <consputc>
    80000738:	b5b5                	j	800005a4 <printf+0x78>
    } else if(c0 == 's'){
      if((s = va_arg(ap, char*)) == 0)
    8000073a:	f8843783          	ld	a5,-120(s0)
    8000073e:	00878713          	addi	a4,a5,8
    80000742:	f8e43423          	sd	a4,-120(s0)
    80000746:	0007ba03          	ld	s4,0(a5)
    8000074a:	000a0d63          	beqz	s4,80000764 <printf+0x238>
        s = "(null)";
      for(; *s; s++)
    8000074e:	000a4503          	lbu	a0,0(s4)
    80000752:	e40509e3          	beqz	a0,800005a4 <printf+0x78>
        consputc(*s);
    80000756:	b43ff0ef          	jal	80000298 <consputc>
      for(; *s; s++)
    8000075a:	0a05                	addi	s4,s4,1
    8000075c:	000a4503          	lbu	a0,0(s4)
    80000760:	f97d                	bnez	a0,80000756 <printf+0x22a>
    80000762:	b589                	j	800005a4 <printf+0x78>
        s = "(null)";
    80000764:	00009a17          	auipc	s4,0x9
    80000768:	8aca0a13          	addi	s4,s4,-1876 # 80009010 <etext+0x10>
      for(; *s; s++)
    8000076c:	02800513          	li	a0,40
    80000770:	b7dd                	j	80000756 <printf+0x22a>
    } else if(c0 == '%'){
      consputc('%');
    80000772:	8556                	mv	a0,s5
    80000774:	b25ff0ef          	jal	80000298 <consputc>
    80000778:	b535                	j	800005a4 <printf+0x78>
    8000077a:	74a6                	ld	s1,104(sp)
    8000077c:	69e6                	ld	s3,88(sp)
    8000077e:	6a46                	ld	s4,80(sp)
    80000780:	6aa6                	ld	s5,72(sp)
    80000782:	6b06                	ld	s6,64(sp)
    80000784:	7be2                	ld	s7,56(sp)
    80000786:	7c42                	ld	s8,48(sp)
    80000788:	7d02                	ld	s10,32(sp)
    8000078a:	6de2                	ld	s11,24(sp)
    }

  }
  va_end(ap);

  if(panicking == 0)
    8000078c:	0000a797          	auipc	a5,0xa
    80000790:	8987a783          	lw	a5,-1896(a5) # 8000a024 <panicking>
    80000794:	c38d                	beqz	a5,800007b6 <printf+0x28a>
    release(&pr.lock);

  return 0;
}
    80000796:	4501                	li	a0,0
    80000798:	70e6                	ld	ra,120(sp)
    8000079a:	7446                	ld	s0,112(sp)
    8000079c:	7906                	ld	s2,96(sp)
    8000079e:	6129                	addi	sp,sp,192
    800007a0:	8082                	ret
    800007a2:	74a6                	ld	s1,104(sp)
    800007a4:	69e6                	ld	s3,88(sp)
    800007a6:	6a46                	ld	s4,80(sp)
    800007a8:	6aa6                	ld	s5,72(sp)
    800007aa:	6b06                	ld	s6,64(sp)
    800007ac:	7be2                	ld	s7,56(sp)
    800007ae:	7c42                	ld	s8,48(sp)
    800007b0:	7d02                	ld	s10,32(sp)
    800007b2:	6de2                	ld	s11,24(sp)
    800007b4:	bfe1                	j	8000078c <printf+0x260>
    release(&pr.lock);
    800007b6:	00012517          	auipc	a0,0x12
    800007ba:	9a250513          	addi	a0,a0,-1630 # 80012158 <pr>
    800007be:	530000ef          	jal	80000cee <release>
  return 0;
    800007c2:	bfd1                	j	80000796 <printf+0x26a>
    if(c0 == 'd'){
    800007c4:	e37a8ee3          	beq	s5,s7,80000600 <printf+0xd4>
    } else if(c0 == 'l' && c1 == 'd'){
    800007c8:	f94a8713          	addi	a4,s5,-108
    800007cc:	00173713          	seqz	a4,a4
    800007d0:	8636                	mv	a2,a3
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
    800007d2:	4781                	li	a5,0
    800007d4:	a00d                	j	800007f6 <printf+0x2ca>
    } else if(c0 == 'l' && c1 == 'd'){
    800007d6:	f94a8713          	addi	a4,s5,-108
    800007da:	00173713          	seqz	a4,a4
    c1 = c2 = 0;
    800007de:	8656                	mv	a2,s5
    800007e0:	86d6                	mv	a3,s5
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
    800007e2:	f9460793          	addi	a5,a2,-108
    800007e6:	0017b793          	seqz	a5,a5
    800007ea:	8ff9                	and	a5,a5,a4
    800007ec:	f9c68593          	addi	a1,a3,-100
    800007f0:	e199                	bnez	a1,800007f6 <printf+0x2ca>
    800007f2:	e20798e3          	bnez	a5,80000622 <printf+0xf6>
    } else if(c0 == 'u'){
    800007f6:	e58a84e3          	beq	s5,s8,8000063e <printf+0x112>
    } else if(c0 == 'l' && c1 == 'u'){
    800007fa:	f8b60593          	addi	a1,a2,-117
    800007fe:	e199                	bnez	a1,80000804 <printf+0x2d8>
    80000800:	e4071ce3          	bnez	a4,80000658 <printf+0x12c>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
    80000804:	f8b68593          	addi	a1,a3,-117
    80000808:	e199                	bnez	a1,8000080e <printf+0x2e2>
    8000080a:	e60795e3          	bnez	a5,80000674 <printf+0x148>
    } else if(c0 == 'x'){
    8000080e:	e9aa81e3          	beq	s5,s10,80000690 <printf+0x164>
    } else if(c0 == 'l' && c1 == 'x'){
    80000812:	f8860613          	addi	a2,a2,-120
    80000816:	e219                	bnez	a2,8000081c <printf+0x2f0>
    80000818:	e80719e3          	bnez	a4,800006aa <printf+0x17e>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
    8000081c:	f8868693          	addi	a3,a3,-120
    80000820:	e299                	bnez	a3,80000826 <printf+0x2fa>
    80000822:	ea0791e3          	bnez	a5,800006c4 <printf+0x198>
    } else if(c0 == 'p'){
    80000826:	ebba8de3          	beq	s5,s11,800006e0 <printf+0x1b4>
    } else if(c0 == 'c'){
    8000082a:	06300793          	li	a5,99
    8000082e:	eefa8ce3          	beq	s5,a5,80000726 <printf+0x1fa>
    } else if(c0 == 's'){
    80000832:	07300793          	li	a5,115
    80000836:	f0fa82e3          	beq	s5,a5,8000073a <printf+0x20e>
    } else if(c0 == '%'){
    8000083a:	02500793          	li	a5,37
    8000083e:	f2fa8ae3          	beq	s5,a5,80000772 <printf+0x246>
    } else if(c0 == 0){
    80000842:	f60a80e3          	beqz	s5,800007a2 <printf+0x276>
      consputc('%');
    80000846:	02500513          	li	a0,37
    8000084a:	a4fff0ef          	jal	80000298 <consputc>
      consputc(c0);
    8000084e:	8556                	mv	a0,s5
    80000850:	a49ff0ef          	jal	80000298 <consputc>
    80000854:	bb81                	j	800005a4 <printf+0x78>

0000000080000856 <panic>:

void
panic(char *s)
{
    80000856:	1101                	addi	sp,sp,-32
    80000858:	ec06                	sd	ra,24(sp)
    8000085a:	e822                	sd	s0,16(sp)
    8000085c:	e426                	sd	s1,8(sp)
    8000085e:	e04a                	sd	s2,0(sp)
    80000860:	1000                	addi	s0,sp,32
    80000862:	892a                	mv	s2,a0
  panicking = 1;
    80000864:	4485                	li	s1,1
    80000866:	00009797          	auipc	a5,0x9
    8000086a:	7a97af23          	sw	s1,1982(a5) # 8000a024 <panicking>
  printf("panic: ");
    8000086e:	00008517          	auipc	a0,0x8
    80000872:	7aa50513          	addi	a0,a0,1962 # 80009018 <etext+0x18>
    80000876:	cb7ff0ef          	jal	8000052c <printf>
  printf("%s\n", s);
    8000087a:	85ca                	mv	a1,s2
    8000087c:	00008517          	auipc	a0,0x8
    80000880:	7a450513          	addi	a0,a0,1956 # 80009020 <etext+0x20>
    80000884:	ca9ff0ef          	jal	8000052c <printf>
  panicked = 1; // freeze uart output from other CPUs
    80000888:	00009797          	auipc	a5,0x9
    8000088c:	7897ac23          	sw	s1,1944(a5) # 8000a020 <panicked>
  for(;;)
    80000890:	a001                	j	80000890 <panic+0x3a>

0000000080000892 <printfinit>:
    ;
}

void
printfinit(void)
{
    80000892:	1141                	addi	sp,sp,-16
    80000894:	e406                	sd	ra,8(sp)
    80000896:	e022                	sd	s0,0(sp)
    80000898:	0800                	addi	s0,sp,16
  initlock(&pr.lock, "pr");
    8000089a:	00008597          	auipc	a1,0x8
    8000089e:	78e58593          	addi	a1,a1,1934 # 80009028 <etext+0x28>
    800008a2:	00012517          	auipc	a0,0x12
    800008a6:	8b650513          	addi	a0,a0,-1866 # 80012158 <pr>
    800008aa:	326000ef          	jal	80000bd0 <initlock>
}
    800008ae:	60a2                	ld	ra,8(sp)
    800008b0:	6402                	ld	s0,0(sp)
    800008b2:	0141                	addi	sp,sp,16
    800008b4:	8082                	ret

00000000800008b6 <uartinit>:
extern volatile int panicking; // from printf.c
extern volatile int panicked; // from printf.c

void
uartinit(void)
{
    800008b6:	1141                	addi	sp,sp,-16
    800008b8:	e406                	sd	ra,8(sp)
    800008ba:	e022                	sd	s0,0(sp)
    800008bc:	0800                	addi	s0,sp,16
  // disable interrupts.
  WriteReg(IER, 0x00);
    800008be:	100007b7          	lui	a5,0x10000
    800008c2:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>

  // special mode to set baud rate.
  WriteReg(LCR, LCR_BAUD_LATCH);
    800008c6:	10000737          	lui	a4,0x10000
    800008ca:	f8000693          	li	a3,-128
    800008ce:	00d701a3          	sb	a3,3(a4) # 10000003 <_entry-0x6ffffffd>

  // LSB for baud rate of 38.4K.
  WriteReg(0, 0x03);
    800008d2:	468d                	li	a3,3
    800008d4:	10000637          	lui	a2,0x10000
    800008d8:	00d60023          	sb	a3,0(a2) # 10000000 <_entry-0x70000000>

  // MSB for baud rate of 38.4K.
  WriteReg(1, 0x00);
    800008dc:	000780a3          	sb	zero,1(a5)

  // leave set-baud mode,
  // and set word length to 8 bits, no parity.
  WriteReg(LCR, LCR_EIGHT_BITS);
    800008e0:	00d701a3          	sb	a3,3(a4)

  // reset and enable FIFOs.
  WriteReg(FCR, FCR_FIFO_ENABLE | FCR_FIFO_CLEAR);
    800008e4:	8732                	mv	a4,a2
    800008e6:	461d                	li	a2,7
    800008e8:	00c70123          	sb	a2,2(a4)

  // enable transmit and receive interrupts.
  WriteReg(IER, IER_TX_ENABLE | IER_RX_ENABLE);
    800008ec:	00d780a3          	sb	a3,1(a5)

  initlock(&tx_lock, "uart");
    800008f0:	00008597          	auipc	a1,0x8
    800008f4:	74058593          	addi	a1,a1,1856 # 80009030 <etext+0x30>
    800008f8:	00012517          	auipc	a0,0x12
    800008fc:	87850513          	addi	a0,a0,-1928 # 80012170 <tx_lock>
    80000900:	2d0000ef          	jal	80000bd0 <initlock>
}
    80000904:	60a2                	ld	ra,8(sp)
    80000906:	6402                	ld	s0,0(sp)
    80000908:	0141                	addi	sp,sp,16
    8000090a:	8082                	ret

000000008000090c <uartwrite>:
// transmit buf[] to the uart. it blocks if the
// uart is busy, so it cannot be called from
// interrupts, only from write() system calls.
void
uartwrite(char buf[], int n)
{
    8000090c:	715d                	addi	sp,sp,-80
    8000090e:	e486                	sd	ra,72(sp)
    80000910:	e0a2                	sd	s0,64(sp)
    80000912:	fc26                	sd	s1,56(sp)
    80000914:	ec56                	sd	s5,24(sp)
    80000916:	0880                	addi	s0,sp,80
    80000918:	8aaa                	mv	s5,a0
    8000091a:	84ae                	mv	s1,a1
  acquire(&tx_lock);
    8000091c:	00012517          	auipc	a0,0x12
    80000920:	85450513          	addi	a0,a0,-1964 # 80012170 <tx_lock>
    80000924:	336000ef          	jal	80000c5a <acquire>

  int i = 0;
  while(i < n){ 
    80000928:	06905063          	blez	s1,80000988 <uartwrite+0x7c>
    8000092c:	f84a                	sd	s2,48(sp)
    8000092e:	f44e                	sd	s3,40(sp)
    80000930:	f052                	sd	s4,32(sp)
    80000932:	e85a                	sd	s6,16(sp)
    80000934:	e45e                	sd	s7,8(sp)
    80000936:	8a56                	mv	s4,s5
    80000938:	9aa6                	add	s5,s5,s1
    while(tx_busy != 0){
    8000093a:	00009497          	auipc	s1,0x9
    8000093e:	6f248493          	addi	s1,s1,1778 # 8000a02c <tx_busy>
      // wait for a UART transmit-complete interrupt
      // to set tx_busy to 0.
      sleep(&tx_chan, &tx_lock);
    80000942:	00012997          	auipc	s3,0x12
    80000946:	82e98993          	addi	s3,s3,-2002 # 80012170 <tx_lock>
    8000094a:	00009917          	auipc	s2,0x9
    8000094e:	6de90913          	addi	s2,s2,1758 # 8000a028 <tx_chan>
    }   
      
    WriteReg(THR, buf[i]);
    80000952:	10000bb7          	lui	s7,0x10000
    i += 1;
    tx_busy = 1;
    80000956:	4b05                	li	s6,1
    80000958:	a005                	j	80000978 <uartwrite+0x6c>
      sleep(&tx_chan, &tx_lock);
    8000095a:	85ce                	mv	a1,s3
    8000095c:	854a                	mv	a0,s2
    8000095e:	620010ef          	jal	80001f7e <sleep>
    while(tx_busy != 0){
    80000962:	409c                	lw	a5,0(s1)
    80000964:	fbfd                	bnez	a5,8000095a <uartwrite+0x4e>
    WriteReg(THR, buf[i]);
    80000966:	000a4783          	lbu	a5,0(s4)
    8000096a:	00fb8023          	sb	a5,0(s7) # 10000000 <_entry-0x70000000>
    tx_busy = 1;
    8000096e:	0164a023          	sw	s6,0(s1)
  while(i < n){ 
    80000972:	0a05                	addi	s4,s4,1
    80000974:	015a0563          	beq	s4,s5,8000097e <uartwrite+0x72>
    while(tx_busy != 0){
    80000978:	409c                	lw	a5,0(s1)
    8000097a:	f3e5                	bnez	a5,8000095a <uartwrite+0x4e>
    8000097c:	b7ed                	j	80000966 <uartwrite+0x5a>
    8000097e:	7942                	ld	s2,48(sp)
    80000980:	79a2                	ld	s3,40(sp)
    80000982:	7a02                	ld	s4,32(sp)
    80000984:	6b42                	ld	s6,16(sp)
    80000986:	6ba2                	ld	s7,8(sp)
  }

  release(&tx_lock);
    80000988:	00011517          	auipc	a0,0x11
    8000098c:	7e850513          	addi	a0,a0,2024 # 80012170 <tx_lock>
    80000990:	35e000ef          	jal	80000cee <release>
}
    80000994:	60a6                	ld	ra,72(sp)
    80000996:	6406                	ld	s0,64(sp)
    80000998:	74e2                	ld	s1,56(sp)
    8000099a:	6ae2                	ld	s5,24(sp)
    8000099c:	6161                	addi	sp,sp,80
    8000099e:	8082                	ret

00000000800009a0 <uartputc_sync>:
// interrupts, for use by kernel printf() and
// to echo characters. it spins waiting for the uart's
// output register to be empty.
void
uartputc_sync(int c)
{
    800009a0:	1101                	addi	sp,sp,-32
    800009a2:	ec06                	sd	ra,24(sp)
    800009a4:	e822                	sd	s0,16(sp)
    800009a6:	e426                	sd	s1,8(sp)
    800009a8:	1000                	addi	s0,sp,32
    800009aa:	84aa                	mv	s1,a0
  if(panicking == 0)
    800009ac:	00009797          	auipc	a5,0x9
    800009b0:	6787a783          	lw	a5,1656(a5) # 8000a024 <panicking>
    800009b4:	cf95                	beqz	a5,800009f0 <uartputc_sync+0x50>
    push_off();

  if(panicked){
    800009b6:	00009797          	auipc	a5,0x9
    800009ba:	66a7a783          	lw	a5,1642(a5) # 8000a020 <panicked>
    800009be:	ef85                	bnez	a5,800009f6 <uartputc_sync+0x56>
    for(;;)
      ;
  }

  // wait for UART to set Transmit Holding Empty in LSR.
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    800009c0:	10000737          	lui	a4,0x10000
    800009c4:	0715                	addi	a4,a4,5 # 10000005 <_entry-0x6ffffffb>
    800009c6:	00074783          	lbu	a5,0(a4)
    800009ca:	0207f793          	andi	a5,a5,32
    800009ce:	dfe5                	beqz	a5,800009c6 <uartputc_sync+0x26>
    ;
  WriteReg(THR, c);
    800009d0:	0ff4f513          	zext.b	a0,s1
    800009d4:	100007b7          	lui	a5,0x10000
    800009d8:	00a78023          	sb	a0,0(a5) # 10000000 <_entry-0x70000000>

  if(panicking == 0)
    800009dc:	00009797          	auipc	a5,0x9
    800009e0:	6487a783          	lw	a5,1608(a5) # 8000a024 <panicking>
    800009e4:	cb91                	beqz	a5,800009f8 <uartputc_sync+0x58>
    pop_off();
}
    800009e6:	60e2                	ld	ra,24(sp)
    800009e8:	6442                	ld	s0,16(sp)
    800009ea:	64a2                	ld	s1,8(sp)
    800009ec:	6105                	addi	sp,sp,32
    800009ee:	8082                	ret
    push_off();
    800009f0:	226000ef          	jal	80000c16 <push_off>
    800009f4:	b7c9                	j	800009b6 <uartputc_sync+0x16>
    for(;;)
    800009f6:	a001                	j	800009f6 <uartputc_sync+0x56>
    pop_off();
    800009f8:	2a6000ef          	jal	80000c9e <pop_off>
}
    800009fc:	b7ed                	j	800009e6 <uartputc_sync+0x46>

00000000800009fe <uartgetc>:

// try to read one input character from the UART.
// return -1 if none is waiting.
int
uartgetc(void)
{
    800009fe:	1141                	addi	sp,sp,-16
    80000a00:	e406                	sd	ra,8(sp)
    80000a02:	e022                	sd	s0,0(sp)
    80000a04:	0800                	addi	s0,sp,16
  if(ReadReg(LSR) & LSR_RX_READY){
    80000a06:	100007b7          	lui	a5,0x10000
    80000a0a:	0057c783          	lbu	a5,5(a5) # 10000005 <_entry-0x6ffffffb>
    80000a0e:	8b85                	andi	a5,a5,1
    80000a10:	cb89                	beqz	a5,80000a22 <uartgetc+0x24>
    // input data is ready.
    return ReadReg(RHR);
    80000a12:	100007b7          	lui	a5,0x10000
    80000a16:	0007c503          	lbu	a0,0(a5) # 10000000 <_entry-0x70000000>
  } else {
    return -1;
  }
}
    80000a1a:	60a2                	ld	ra,8(sp)
    80000a1c:	6402                	ld	s0,0(sp)
    80000a1e:	0141                	addi	sp,sp,16
    80000a20:	8082                	ret
    return -1;
    80000a22:	557d                	li	a0,-1
    80000a24:	bfdd                	j	80000a1a <uartgetc+0x1c>

0000000080000a26 <uartintr>:
// handle a uart interrupt, raised because input has
// arrived, or the uart is ready for more output, or
// both. called from devintr().
void
uartintr(void)
{
    80000a26:	1101                	addi	sp,sp,-32
    80000a28:	ec06                	sd	ra,24(sp)
    80000a2a:	e822                	sd	s0,16(sp)
    80000a2c:	e426                	sd	s1,8(sp)
    80000a2e:	1000                	addi	s0,sp,32
  ReadReg(ISR); // acknowledge the interrupt
    80000a30:	100007b7          	lui	a5,0x10000
    80000a34:	0027c783          	lbu	a5,2(a5) # 10000002 <_entry-0x6ffffffe>

  acquire(&tx_lock);
    80000a38:	00011517          	auipc	a0,0x11
    80000a3c:	73850513          	addi	a0,a0,1848 # 80012170 <tx_lock>
    80000a40:	21a000ef          	jal	80000c5a <acquire>
  if(ReadReg(LSR) & LSR_TX_IDLE){
    80000a44:	100007b7          	lui	a5,0x10000
    80000a48:	0057c783          	lbu	a5,5(a5) # 10000005 <_entry-0x6ffffffb>
    80000a4c:	0207f793          	andi	a5,a5,32
    80000a50:	ef99                	bnez	a5,80000a6e <uartintr+0x48>
    // UART finished transmitting; wake up sending thread.
    tx_busy = 0;
    wakeup(&tx_chan);
  }
  release(&tx_lock);
    80000a52:	00011517          	auipc	a0,0x11
    80000a56:	71e50513          	addi	a0,a0,1822 # 80012170 <tx_lock>
    80000a5a:	294000ef          	jal	80000cee <release>

  // read and process incoming characters, if any.
  while(1){
    int c = uartgetc();
    if(c == -1)
    80000a5e:	54fd                	li	s1,-1
    int c = uartgetc();
    80000a60:	f9fff0ef          	jal	800009fe <uartgetc>
    if(c == -1)
    80000a64:	02950063          	beq	a0,s1,80000a84 <uartintr+0x5e>
      break;
    consoleintr(c);
    80000a68:	863ff0ef          	jal	800002ca <consoleintr>
  while(1){
    80000a6c:	bfd5                	j	80000a60 <uartintr+0x3a>
    tx_busy = 0;
    80000a6e:	00009797          	auipc	a5,0x9
    80000a72:	5a07af23          	sw	zero,1470(a5) # 8000a02c <tx_busy>
    wakeup(&tx_chan);
    80000a76:	00009517          	auipc	a0,0x9
    80000a7a:	5b250513          	addi	a0,a0,1458 # 8000a028 <tx_chan>
    80000a7e:	54c010ef          	jal	80001fca <wakeup>
    80000a82:	bfc1                	j	80000a52 <uartintr+0x2c>
  }
}
    80000a84:	60e2                	ld	ra,24(sp)
    80000a86:	6442                	ld	s0,16(sp)
    80000a88:	64a2                	ld	s1,8(sp)
    80000a8a:	6105                	addi	sp,sp,32
    80000a8c:	8082                	ret

0000000080000a8e <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(void *pa)
{
    80000a8e:	1101                	addi	sp,sp,-32
    80000a90:	ec06                	sd	ra,24(sp)
    80000a92:	e822                	sd	s0,16(sp)
    80000a94:	e426                	sd	s1,8(sp)
    80000a96:	e04a                	sd	s2,0(sp)
    80000a98:	1000                	addi	s0,sp,32
  struct run *r;

  if(((uint64)pa % PGSIZE) != 0 || (char*)pa < end || (uint64)pa >= PHYSTOP)
    80000a9a:	00090797          	auipc	a5,0x90
    80000a9e:	9c678793          	addi	a5,a5,-1594 # 80090460 <end>
    80000aa2:	00f53733          	sltu	a4,a0,a5
    80000aa6:	47c5                	li	a5,17
    80000aa8:	07ee                	slli	a5,a5,0x1b
    80000aaa:	17fd                	addi	a5,a5,-1
    80000aac:	00a7b7b3          	sltu	a5,a5,a0
    80000ab0:	8fd9                	or	a5,a5,a4
    80000ab2:	ef95                	bnez	a5,80000aee <kfree+0x60>
    80000ab4:	84aa                	mv	s1,a0
    80000ab6:	03451793          	slli	a5,a0,0x34
    80000aba:	eb95                	bnez	a5,80000aee <kfree+0x60>
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(pa, 1, PGSIZE);
    80000abc:	6605                	lui	a2,0x1
    80000abe:	4585                	li	a1,1
    80000ac0:	26a000ef          	jal	80000d2a <memset>

  r = (struct run*)pa;

  acquire(&kmem.lock);
    80000ac4:	00011917          	auipc	s2,0x11
    80000ac8:	6c490913          	addi	s2,s2,1732 # 80012188 <kmem>
    80000acc:	854a                	mv	a0,s2
    80000ace:	18c000ef          	jal	80000c5a <acquire>
  r->next = kmem.freelist;
    80000ad2:	01893783          	ld	a5,24(s2)
    80000ad6:	e09c                	sd	a5,0(s1)
  kmem.freelist = r;
    80000ad8:	00993c23          	sd	s1,24(s2)
  release(&kmem.lock);
    80000adc:	854a                	mv	a0,s2
    80000ade:	210000ef          	jal	80000cee <release>
}
    80000ae2:	60e2                	ld	ra,24(sp)
    80000ae4:	6442                	ld	s0,16(sp)
    80000ae6:	64a2                	ld	s1,8(sp)
    80000ae8:	6902                	ld	s2,0(sp)
    80000aea:	6105                	addi	sp,sp,32
    80000aec:	8082                	ret
    panic("kfree");
    80000aee:	00008517          	auipc	a0,0x8
    80000af2:	54a50513          	addi	a0,a0,1354 # 80009038 <etext+0x38>
    80000af6:	d61ff0ef          	jal	80000856 <panic>

0000000080000afa <freerange>:
{
    80000afa:	7179                	addi	sp,sp,-48
    80000afc:	f406                	sd	ra,40(sp)
    80000afe:	f022                	sd	s0,32(sp)
    80000b00:	ec26                	sd	s1,24(sp)
    80000b02:	1800                	addi	s0,sp,48
  p = (char*)PGROUNDUP((uint64)pa_start);
    80000b04:	6785                	lui	a5,0x1
    80000b06:	fff78713          	addi	a4,a5,-1 # fff <_entry-0x7ffff001>
    80000b0a:	00e504b3          	add	s1,a0,a4
    80000b0e:	777d                	lui	a4,0xfffff
    80000b10:	8cf9                	and	s1,s1,a4
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000b12:	94be                	add	s1,s1,a5
    80000b14:	0295e263          	bltu	a1,s1,80000b38 <freerange+0x3e>
    80000b18:	e84a                	sd	s2,16(sp)
    80000b1a:	e44e                	sd	s3,8(sp)
    80000b1c:	e052                	sd	s4,0(sp)
    80000b1e:	892e                	mv	s2,a1
    kfree(p);
    80000b20:	8a3a                	mv	s4,a4
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000b22:	89be                	mv	s3,a5
    kfree(p);
    80000b24:	01448533          	add	a0,s1,s4
    80000b28:	f67ff0ef          	jal	80000a8e <kfree>
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000b2c:	94ce                	add	s1,s1,s3
    80000b2e:	fe997be3          	bgeu	s2,s1,80000b24 <freerange+0x2a>
    80000b32:	6942                	ld	s2,16(sp)
    80000b34:	69a2                	ld	s3,8(sp)
    80000b36:	6a02                	ld	s4,0(sp)
}
    80000b38:	70a2                	ld	ra,40(sp)
    80000b3a:	7402                	ld	s0,32(sp)
    80000b3c:	64e2                	ld	s1,24(sp)
    80000b3e:	6145                	addi	sp,sp,48
    80000b40:	8082                	ret

0000000080000b42 <kinit>:
{
    80000b42:	1141                	addi	sp,sp,-16
    80000b44:	e406                	sd	ra,8(sp)
    80000b46:	e022                	sd	s0,0(sp)
    80000b48:	0800                	addi	s0,sp,16
  initlock(&kmem.lock, "kmem");
    80000b4a:	00008597          	auipc	a1,0x8
    80000b4e:	4f658593          	addi	a1,a1,1270 # 80009040 <etext+0x40>
    80000b52:	00011517          	auipc	a0,0x11
    80000b56:	63650513          	addi	a0,a0,1590 # 80012188 <kmem>
    80000b5a:	076000ef          	jal	80000bd0 <initlock>
  freerange(end, (void*)PHYSTOP);
    80000b5e:	45c5                	li	a1,17
    80000b60:	05ee                	slli	a1,a1,0x1b
    80000b62:	00090517          	auipc	a0,0x90
    80000b66:	8fe50513          	addi	a0,a0,-1794 # 80090460 <end>
    80000b6a:	f91ff0ef          	jal	80000afa <freerange>
}
    80000b6e:	60a2                	ld	ra,8(sp)
    80000b70:	6402                	ld	s0,0(sp)
    80000b72:	0141                	addi	sp,sp,16
    80000b74:	8082                	ret

0000000080000b76 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
    80000b76:	1101                	addi	sp,sp,-32
    80000b78:	ec06                	sd	ra,24(sp)
    80000b7a:	e822                	sd	s0,16(sp)
    80000b7c:	e426                	sd	s1,8(sp)
    80000b7e:	1000                	addi	s0,sp,32
  struct run *r;

  acquire(&kmem.lock);
    80000b80:	00011517          	auipc	a0,0x11
    80000b84:	60850513          	addi	a0,a0,1544 # 80012188 <kmem>
    80000b88:	0d2000ef          	jal	80000c5a <acquire>
  r = kmem.freelist;
    80000b8c:	00011497          	auipc	s1,0x11
    80000b90:	6144b483          	ld	s1,1556(s1) # 800121a0 <kmem+0x18>
  if(r)
    80000b94:	c49d                	beqz	s1,80000bc2 <kalloc+0x4c>
    kmem.freelist = r->next;
    80000b96:	609c                	ld	a5,0(s1)
    80000b98:	00011717          	auipc	a4,0x11
    80000b9c:	60f73423          	sd	a5,1544(a4) # 800121a0 <kmem+0x18>
  release(&kmem.lock);
    80000ba0:	00011517          	auipc	a0,0x11
    80000ba4:	5e850513          	addi	a0,a0,1512 # 80012188 <kmem>
    80000ba8:	146000ef          	jal	80000cee <release>

  if(r)
    memset((char*)r, 5, PGSIZE); // fill with junk
    80000bac:	6605                	lui	a2,0x1
    80000bae:	4595                	li	a1,5
    80000bb0:	8526                	mv	a0,s1
    80000bb2:	178000ef          	jal	80000d2a <memset>
  return (void*)r;
}
    80000bb6:	8526                	mv	a0,s1
    80000bb8:	60e2                	ld	ra,24(sp)
    80000bba:	6442                	ld	s0,16(sp)
    80000bbc:	64a2                	ld	s1,8(sp)
    80000bbe:	6105                	addi	sp,sp,32
    80000bc0:	8082                	ret
  release(&kmem.lock);
    80000bc2:	00011517          	auipc	a0,0x11
    80000bc6:	5c650513          	addi	a0,a0,1478 # 80012188 <kmem>
    80000bca:	124000ef          	jal	80000cee <release>
  if(r)
    80000bce:	b7e5                	j	80000bb6 <kalloc+0x40>

0000000080000bd0 <initlock>:
#include "proc.h"
#include "defs.h"

void
initlock(struct spinlock *lk, char *name)
{
    80000bd0:	1141                	addi	sp,sp,-16
    80000bd2:	e406                	sd	ra,8(sp)
    80000bd4:	e022                	sd	s0,0(sp)
    80000bd6:	0800                	addi	s0,sp,16
  lk->name = name;
    80000bd8:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    80000bda:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    80000bde:	00053823          	sd	zero,16(a0)
}
    80000be2:	60a2                	ld	ra,8(sp)
    80000be4:	6402                	ld	s0,0(sp)
    80000be6:	0141                	addi	sp,sp,16
    80000be8:	8082                	ret

0000000080000bea <holding>:
// Interrupts must be off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    80000bea:	411c                	lw	a5,0(a0)
    80000bec:	e399                	bnez	a5,80000bf2 <holding+0x8>
    80000bee:	4501                	li	a0,0
  return r;
}
    80000bf0:	8082                	ret
{
    80000bf2:	1101                	addi	sp,sp,-32
    80000bf4:	ec06                	sd	ra,24(sp)
    80000bf6:	e822                	sd	s0,16(sp)
    80000bf8:	e426                	sd	s1,8(sp)
    80000bfa:	1000                	addi	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    80000bfc:	691c                	ld	a5,16(a0)
    80000bfe:	84be                	mv	s1,a5
    80000c00:	549000ef          	jal	80001948 <mycpu>
    80000c04:	40a48533          	sub	a0,s1,a0
    80000c08:	00153513          	seqz	a0,a0
}
    80000c0c:	60e2                	ld	ra,24(sp)
    80000c0e:	6442                	ld	s0,16(sp)
    80000c10:	64a2                	ld	s1,8(sp)
    80000c12:	6105                	addi	sp,sp,32
    80000c14:	8082                	ret

0000000080000c16 <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    80000c16:	1101                	addi	sp,sp,-32
    80000c18:	ec06                	sd	ra,24(sp)
    80000c1a:	e822                	sd	s0,16(sp)
    80000c1c:	e426                	sd	s1,8(sp)
    80000c1e:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c20:	100027f3          	csrr	a5,sstatus
    80000c24:	84be                	mv	s1,a5
    80000c26:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80000c2a:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000c2c:	10079073          	csrw	sstatus,a5

  // disable interrupts to prevent an involuntary context
  // switch while using mycpu().
  intr_off();

  if(mycpu()->noff == 0)
    80000c30:	519000ef          	jal	80001948 <mycpu>
    80000c34:	5d3c                	lw	a5,120(a0)
    80000c36:	cb99                	beqz	a5,80000c4c <push_off+0x36>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000c38:	511000ef          	jal	80001948 <mycpu>
    80000c3c:	5d3c                	lw	a5,120(a0)
    80000c3e:	2785                	addiw	a5,a5,1
    80000c40:	dd3c                	sw	a5,120(a0)
}
    80000c42:	60e2                	ld	ra,24(sp)
    80000c44:	6442                	ld	s0,16(sp)
    80000c46:	64a2                	ld	s1,8(sp)
    80000c48:	6105                	addi	sp,sp,32
    80000c4a:	8082                	ret
    mycpu()->intena = old;
    80000c4c:	4fd000ef          	jal	80001948 <mycpu>
  return (x & SSTATUS_SIE) != 0;
    80000c50:	0014d793          	srli	a5,s1,0x1
    80000c54:	8b85                	andi	a5,a5,1
    80000c56:	dd7c                	sw	a5,124(a0)
    80000c58:	b7c5                	j	80000c38 <push_off+0x22>

0000000080000c5a <acquire>:
{
    80000c5a:	1101                	addi	sp,sp,-32
    80000c5c:	ec06                	sd	ra,24(sp)
    80000c5e:	e822                	sd	s0,16(sp)
    80000c60:	e426                	sd	s1,8(sp)
    80000c62:	1000                	addi	s0,sp,32
    80000c64:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    80000c66:	fb1ff0ef          	jal	80000c16 <push_off>
  if(holding(lk))
    80000c6a:	8526                	mv	a0,s1
    80000c6c:	f7fff0ef          	jal	80000bea <holding>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000c70:	4705                	li	a4,1
  if(holding(lk))
    80000c72:	e105                	bnez	a0,80000c92 <acquire+0x38>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000c74:	87ba                	mv	a5,a4
    80000c76:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80000c7a:	2781                	sext.w	a5,a5
    80000c7c:	ffe5                	bnez	a5,80000c74 <acquire+0x1a>
  __sync_synchronize();
    80000c7e:	0330000f          	fence	rw,rw
  lk->cpu = mycpu();
    80000c82:	4c7000ef          	jal	80001948 <mycpu>
    80000c86:	e888                	sd	a0,16(s1)
}
    80000c88:	60e2                	ld	ra,24(sp)
    80000c8a:	6442                	ld	s0,16(sp)
    80000c8c:	64a2                	ld	s1,8(sp)
    80000c8e:	6105                	addi	sp,sp,32
    80000c90:	8082                	ret
    panic("acquire");
    80000c92:	00008517          	auipc	a0,0x8
    80000c96:	3b650513          	addi	a0,a0,950 # 80009048 <etext+0x48>
    80000c9a:	bbdff0ef          	jal	80000856 <panic>

0000000080000c9e <pop_off>:

void
pop_off(void)
{
    80000c9e:	1141                	addi	sp,sp,-16
    80000ca0:	e406                	sd	ra,8(sp)
    80000ca2:	e022                	sd	s0,0(sp)
    80000ca4:	0800                	addi	s0,sp,16
  struct cpu *c = mycpu();
    80000ca6:	4a3000ef          	jal	80001948 <mycpu>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000caa:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80000cae:	8b89                	andi	a5,a5,2
  if(intr_get())
    80000cb0:	e39d                	bnez	a5,80000cd6 <pop_off+0x38>
    panic("pop_off - interruptible");
  if(c->noff < 1)
    80000cb2:	5d3c                	lw	a5,120(a0)
    80000cb4:	02f05763          	blez	a5,80000ce2 <pop_off+0x44>
    panic("pop_off");
  c->noff -= 1;
    80000cb8:	37fd                	addiw	a5,a5,-1
    80000cba:	dd3c                	sw	a5,120(a0)
  if(c->noff == 0 && c->intena)
    80000cbc:	eb89                	bnez	a5,80000cce <pop_off+0x30>
    80000cbe:	5d7c                	lw	a5,124(a0)
    80000cc0:	c799                	beqz	a5,80000cce <pop_off+0x30>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000cc2:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80000cc6:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000cca:	10079073          	csrw	sstatus,a5
    intr_on();
}
    80000cce:	60a2                	ld	ra,8(sp)
    80000cd0:	6402                	ld	s0,0(sp)
    80000cd2:	0141                	addi	sp,sp,16
    80000cd4:	8082                	ret
    panic("pop_off - interruptible");
    80000cd6:	00008517          	auipc	a0,0x8
    80000cda:	37a50513          	addi	a0,a0,890 # 80009050 <etext+0x50>
    80000cde:	b79ff0ef          	jal	80000856 <panic>
    panic("pop_off");
    80000ce2:	00008517          	auipc	a0,0x8
    80000ce6:	38650513          	addi	a0,a0,902 # 80009068 <etext+0x68>
    80000cea:	b6dff0ef          	jal	80000856 <panic>

0000000080000cee <release>:
{
    80000cee:	1101                	addi	sp,sp,-32
    80000cf0:	ec06                	sd	ra,24(sp)
    80000cf2:	e822                	sd	s0,16(sp)
    80000cf4:	e426                	sd	s1,8(sp)
    80000cf6:	1000                	addi	s0,sp,32
    80000cf8:	84aa                	mv	s1,a0
  if(!holding(lk))
    80000cfa:	ef1ff0ef          	jal	80000bea <holding>
    80000cfe:	c105                	beqz	a0,80000d1e <release+0x30>
  lk->cpu = 0;
    80000d00:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    80000d04:	0330000f          	fence	rw,rw
  __sync_lock_release(&lk->locked);
    80000d08:	0310000f          	fence	rw,w
    80000d0c:	0004a023          	sw	zero,0(s1)
  pop_off();
    80000d10:	f8fff0ef          	jal	80000c9e <pop_off>
}
    80000d14:	60e2                	ld	ra,24(sp)
    80000d16:	6442                	ld	s0,16(sp)
    80000d18:	64a2                	ld	s1,8(sp)
    80000d1a:	6105                	addi	sp,sp,32
    80000d1c:	8082                	ret
    panic("release");
    80000d1e:	00008517          	auipc	a0,0x8
    80000d22:	35250513          	addi	a0,a0,850 # 80009070 <etext+0x70>
    80000d26:	b31ff0ef          	jal	80000856 <panic>

0000000080000d2a <memset>:
#include "types.h"

void*
memset(void *dst, int c, uint n)
{
    80000d2a:	1141                	addi	sp,sp,-16
    80000d2c:	e406                	sd	ra,8(sp)
    80000d2e:	e022                	sd	s0,0(sp)
    80000d30:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    80000d32:	ca19                	beqz	a2,80000d48 <memset+0x1e>
    80000d34:	87aa                	mv	a5,a0
    80000d36:	1602                	slli	a2,a2,0x20
    80000d38:	9201                	srli	a2,a2,0x20
    80000d3a:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
    80000d3e:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    80000d42:	0785                	addi	a5,a5,1
    80000d44:	fee79de3          	bne	a5,a4,80000d3e <memset+0x14>
  }
  return dst;
}
    80000d48:	60a2                	ld	ra,8(sp)
    80000d4a:	6402                	ld	s0,0(sp)
    80000d4c:	0141                	addi	sp,sp,16
    80000d4e:	8082                	ret

0000000080000d50 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    80000d50:	1141                	addi	sp,sp,-16
    80000d52:	e406                	sd	ra,8(sp)
    80000d54:	e022                	sd	s0,0(sp)
    80000d56:	0800                	addi	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    80000d58:	c61d                	beqz	a2,80000d86 <memcmp+0x36>
    80000d5a:	1602                	slli	a2,a2,0x20
    80000d5c:	9201                	srli	a2,a2,0x20
    80000d5e:	00c506b3          	add	a3,a0,a2
    if(*s1 != *s2)
    80000d62:	00054783          	lbu	a5,0(a0)
    80000d66:	0005c703          	lbu	a4,0(a1)
    80000d6a:	00e79863          	bne	a5,a4,80000d7a <memcmp+0x2a>
      return *s1 - *s2;
    s1++, s2++;
    80000d6e:	0505                	addi	a0,a0,1
    80000d70:	0585                	addi	a1,a1,1
  while(n-- > 0){
    80000d72:	fed518e3          	bne	a0,a3,80000d62 <memcmp+0x12>
  }

  return 0;
    80000d76:	4501                	li	a0,0
    80000d78:	a019                	j	80000d7e <memcmp+0x2e>
      return *s1 - *s2;
    80000d7a:	40e7853b          	subw	a0,a5,a4
}
    80000d7e:	60a2                	ld	ra,8(sp)
    80000d80:	6402                	ld	s0,0(sp)
    80000d82:	0141                	addi	sp,sp,16
    80000d84:	8082                	ret
  return 0;
    80000d86:	4501                	li	a0,0
    80000d88:	bfdd                	j	80000d7e <memcmp+0x2e>

0000000080000d8a <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
    80000d8a:	1141                	addi	sp,sp,-16
    80000d8c:	e406                	sd	ra,8(sp)
    80000d8e:	e022                	sd	s0,0(sp)
    80000d90:	0800                	addi	s0,sp,16
  const char *s;
  char *d;

  if(n == 0)
    80000d92:	c205                	beqz	a2,80000db2 <memmove+0x28>
    return dst;
  
  s = src;
  d = dst;
  if(s < d && s + n > d){
    80000d94:	02a5e363          	bltu	a1,a0,80000dba <memmove+0x30>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
    80000d98:	1602                	slli	a2,a2,0x20
    80000d9a:	9201                	srli	a2,a2,0x20
    80000d9c:	00c587b3          	add	a5,a1,a2
{
    80000da0:	872a                	mv	a4,a0
      *d++ = *s++;
    80000da2:	0585                	addi	a1,a1,1
    80000da4:	0705                	addi	a4,a4,1
    80000da6:	fff5c683          	lbu	a3,-1(a1)
    80000daa:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
    80000dae:	feb79ae3          	bne	a5,a1,80000da2 <memmove+0x18>

  return dst;
}
    80000db2:	60a2                	ld	ra,8(sp)
    80000db4:	6402                	ld	s0,0(sp)
    80000db6:	0141                	addi	sp,sp,16
    80000db8:	8082                	ret
  if(s < d && s + n > d){
    80000dba:	02061693          	slli	a3,a2,0x20
    80000dbe:	9281                	srli	a3,a3,0x20
    80000dc0:	00d58733          	add	a4,a1,a3
    80000dc4:	fce57ae3          	bgeu	a0,a4,80000d98 <memmove+0xe>
    d += n;
    80000dc8:	96aa                	add	a3,a3,a0
    while(n-- > 0)
    80000dca:	fff6079b          	addiw	a5,a2,-1 # fff <_entry-0x7ffff001>
    80000dce:	1782                	slli	a5,a5,0x20
    80000dd0:	9381                	srli	a5,a5,0x20
    80000dd2:	fff7c793          	not	a5,a5
    80000dd6:	97ba                	add	a5,a5,a4
      *--d = *--s;
    80000dd8:	177d                	addi	a4,a4,-1
    80000dda:	16fd                	addi	a3,a3,-1
    80000ddc:	00074603          	lbu	a2,0(a4)
    80000de0:	00c68023          	sb	a2,0(a3)
    while(n-- > 0)
    80000de4:	fee79ae3          	bne	a5,a4,80000dd8 <memmove+0x4e>
    80000de8:	b7e9                	j	80000db2 <memmove+0x28>

0000000080000dea <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
    80000dea:	1141                	addi	sp,sp,-16
    80000dec:	e406                	sd	ra,8(sp)
    80000dee:	e022                	sd	s0,0(sp)
    80000df0:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    80000df2:	f99ff0ef          	jal	80000d8a <memmove>
}
    80000df6:	60a2                	ld	ra,8(sp)
    80000df8:	6402                	ld	s0,0(sp)
    80000dfa:	0141                	addi	sp,sp,16
    80000dfc:	8082                	ret

0000000080000dfe <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    80000dfe:	1141                	addi	sp,sp,-16
    80000e00:	e406                	sd	ra,8(sp)
    80000e02:	e022                	sd	s0,0(sp)
    80000e04:	0800                	addi	s0,sp,16
  while(n > 0 && *p && *p == *q)
    80000e06:	ce11                	beqz	a2,80000e22 <strncmp+0x24>
    80000e08:	00054783          	lbu	a5,0(a0)
    80000e0c:	cf89                	beqz	a5,80000e26 <strncmp+0x28>
    80000e0e:	0005c703          	lbu	a4,0(a1)
    80000e12:	00f71a63          	bne	a4,a5,80000e26 <strncmp+0x28>
    n--, p++, q++;
    80000e16:	367d                	addiw	a2,a2,-1
    80000e18:	0505                	addi	a0,a0,1
    80000e1a:	0585                	addi	a1,a1,1
  while(n > 0 && *p && *p == *q)
    80000e1c:	f675                	bnez	a2,80000e08 <strncmp+0xa>
  if(n == 0)
    return 0;
    80000e1e:	4501                	li	a0,0
    80000e20:	a801                	j	80000e30 <strncmp+0x32>
    80000e22:	4501                	li	a0,0
    80000e24:	a031                	j	80000e30 <strncmp+0x32>
  return (uchar)*p - (uchar)*q;
    80000e26:	00054503          	lbu	a0,0(a0)
    80000e2a:	0005c783          	lbu	a5,0(a1)
    80000e2e:	9d1d                	subw	a0,a0,a5
}
    80000e30:	60a2                	ld	ra,8(sp)
    80000e32:	6402                	ld	s0,0(sp)
    80000e34:	0141                	addi	sp,sp,16
    80000e36:	8082                	ret

0000000080000e38 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    80000e38:	1141                	addi	sp,sp,-16
    80000e3a:	e406                	sd	ra,8(sp)
    80000e3c:	e022                	sd	s0,0(sp)
    80000e3e:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    80000e40:	87aa                	mv	a5,a0
    80000e42:	a011                	j	80000e46 <strncpy+0xe>
    80000e44:	8636                	mv	a2,a3
    80000e46:	02c05863          	blez	a2,80000e76 <strncpy+0x3e>
    80000e4a:	fff6069b          	addiw	a3,a2,-1
    80000e4e:	8836                	mv	a6,a3
    80000e50:	0785                	addi	a5,a5,1
    80000e52:	0005c703          	lbu	a4,0(a1)
    80000e56:	fee78fa3          	sb	a4,-1(a5)
    80000e5a:	0585                	addi	a1,a1,1
    80000e5c:	f765                	bnez	a4,80000e44 <strncpy+0xc>
    ;
  while(n-- > 0)
    80000e5e:	873e                	mv	a4,a5
    80000e60:	01005b63          	blez	a6,80000e76 <strncpy+0x3e>
    80000e64:	9fb1                	addw	a5,a5,a2
    80000e66:	37fd                	addiw	a5,a5,-1
    *s++ = 0;
    80000e68:	0705                	addi	a4,a4,1
    80000e6a:	fe070fa3          	sb	zero,-1(a4)
  while(n-- > 0)
    80000e6e:	40e786bb          	subw	a3,a5,a4
    80000e72:	fed04be3          	bgtz	a3,80000e68 <strncpy+0x30>
  return os;
}
    80000e76:	60a2                	ld	ra,8(sp)
    80000e78:	6402                	ld	s0,0(sp)
    80000e7a:	0141                	addi	sp,sp,16
    80000e7c:	8082                	ret

0000000080000e7e <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
    80000e7e:	1141                	addi	sp,sp,-16
    80000e80:	e406                	sd	ra,8(sp)
    80000e82:	e022                	sd	s0,0(sp)
    80000e84:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  if(n <= 0)
    80000e86:	02c05363          	blez	a2,80000eac <safestrcpy+0x2e>
    80000e8a:	fff6069b          	addiw	a3,a2,-1
    80000e8e:	1682                	slli	a3,a3,0x20
    80000e90:	9281                	srli	a3,a3,0x20
    80000e92:	96ae                	add	a3,a3,a1
    80000e94:	87aa                	mv	a5,a0
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
    80000e96:	00d58963          	beq	a1,a3,80000ea8 <safestrcpy+0x2a>
    80000e9a:	0585                	addi	a1,a1,1
    80000e9c:	0785                	addi	a5,a5,1
    80000e9e:	fff5c703          	lbu	a4,-1(a1)
    80000ea2:	fee78fa3          	sb	a4,-1(a5)
    80000ea6:	fb65                	bnez	a4,80000e96 <safestrcpy+0x18>
    ;
  *s = 0;
    80000ea8:	00078023          	sb	zero,0(a5)
  return os;
}
    80000eac:	60a2                	ld	ra,8(sp)
    80000eae:	6402                	ld	s0,0(sp)
    80000eb0:	0141                	addi	sp,sp,16
    80000eb2:	8082                	ret

0000000080000eb4 <strlen>:

int
strlen(const char *s)
{
    80000eb4:	1141                	addi	sp,sp,-16
    80000eb6:	e406                	sd	ra,8(sp)
    80000eb8:	e022                	sd	s0,0(sp)
    80000eba:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    80000ebc:	00054783          	lbu	a5,0(a0)
    80000ec0:	cf91                	beqz	a5,80000edc <strlen+0x28>
    80000ec2:	00150793          	addi	a5,a0,1
    80000ec6:	86be                	mv	a3,a5
    80000ec8:	0785                	addi	a5,a5,1
    80000eca:	fff7c703          	lbu	a4,-1(a5)
    80000ece:	ff65                	bnez	a4,80000ec6 <strlen+0x12>
    80000ed0:	40a6853b          	subw	a0,a3,a0
    ;
  return n;
}
    80000ed4:	60a2                	ld	ra,8(sp)
    80000ed6:	6402                	ld	s0,0(sp)
    80000ed8:	0141                	addi	sp,sp,16
    80000eda:	8082                	ret
  for(n = 0; s[n]; n++)
    80000edc:	4501                	li	a0,0
    80000ede:	bfdd                	j	80000ed4 <strlen+0x20>

0000000080000ee0 <main>:
volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    80000ee0:	1141                	addi	sp,sp,-16
    80000ee2:	e406                	sd	ra,8(sp)
    80000ee4:	e022                	sd	s0,0(sp)
    80000ee6:	0800                	addi	s0,sp,16
  if(cpuid() == 0){
    80000ee8:	24d000ef          	jal	80001934 <cpuid>
    fslog_init();
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    80000eec:	00009717          	auipc	a4,0x9
    80000ef0:	14470713          	addi	a4,a4,324 # 8000a030 <started>
  if(cpuid() == 0){
    80000ef4:	c51d                	beqz	a0,80000f22 <main+0x42>
    while(started == 0)
    80000ef6:	431c                	lw	a5,0(a4)
    80000ef8:	2781                	sext.w	a5,a5
    80000efa:	dff5                	beqz	a5,80000ef6 <main+0x16>
      ;
    __sync_synchronize();
    80000efc:	0330000f          	fence	rw,rw
    printf("hart %d starting\n", cpuid());
    80000f00:	235000ef          	jal	80001934 <cpuid>
    80000f04:	85aa                	mv	a1,a0
    80000f06:	00008517          	auipc	a0,0x8
    80000f0a:	18a50513          	addi	a0,a0,394 # 80009090 <etext+0x90>
    80000f0e:	e1eff0ef          	jal	8000052c <printf>
    kvminithart();    // turn on paging
    80000f12:	088000ef          	jal	80000f9a <kvminithart>
    trapinithart();   // install kernel trap vector
    80000f16:	588010ef          	jal	8000249e <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000f1a:	6de050ef          	jal	800065f8 <plicinithart>
  }

  scheduler();        
    80000f1e:	6c1000ef          	jal	80001dde <scheduler>
    consoleinit();
    80000f22:	d1cff0ef          	jal	8000043e <consoleinit>
    printfinit();
    80000f26:	96dff0ef          	jal	80000892 <printfinit>
    printf("\n");
    80000f2a:	00008517          	auipc	a0,0x8
    80000f2e:	17650513          	addi	a0,a0,374 # 800090a0 <etext+0xa0>
    80000f32:	dfaff0ef          	jal	8000052c <printf>
    printf("xv6 kernel is booting\n");
    80000f36:	00008517          	auipc	a0,0x8
    80000f3a:	14250513          	addi	a0,a0,322 # 80009078 <etext+0x78>
    80000f3e:	deeff0ef          	jal	8000052c <printf>
    printf("\n");
    80000f42:	00008517          	auipc	a0,0x8
    80000f46:	15e50513          	addi	a0,a0,350 # 800090a0 <etext+0xa0>
    80000f4a:	de2ff0ef          	jal	8000052c <printf>
    kinit();         // physical page allocator
    80000f4e:	bf5ff0ef          	jal	80000b42 <kinit>
    kvminit();       // create kernel page table
    80000f52:	2d4000ef          	jal	80001226 <kvminit>
    kvminithart();   // turn on paging
    80000f56:	044000ef          	jal	80000f9a <kvminithart>
    procinit();      // process table
    80000f5a:	125000ef          	jal	8000187e <procinit>
    trapinit();      // trap vectors
    80000f5e:	51c010ef          	jal	8000247a <trapinit>
    trapinithart();  // install kernel trap vector
    80000f62:	53c010ef          	jal	8000249e <trapinithart>
    plicinit();      // set up interrupt controller
    80000f66:	678050ef          	jal	800065de <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000f6a:	68e050ef          	jal	800065f8 <plicinithart>
    binit();         // buffer cache
    80000f6e:	403010ef          	jal	80002b70 <binit>
    iinit();         // inode table
    80000f72:	79c020ef          	jal	8000370e <iinit>
    fileinit();      // file table
    80000f76:	6cf030ef          	jal	80004e44 <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000f7a:	76e050ef          	jal	800066e8 <virtio_disk_init>
    cslog_init();
    80000f7e:	3f1050ef          	jal	80006b6e <cslog_init>
    fslog_init();
    80000f82:	000060ef          	jal	80006f82 <fslog_init>
    userinit();      // first user process
    80000f86:	4ad000ef          	jal	80001c32 <userinit>
    __sync_synchronize();
    80000f8a:	0330000f          	fence	rw,rw
    started = 1;
    80000f8e:	4785                	li	a5,1
    80000f90:	00009717          	auipc	a4,0x9
    80000f94:	0af72023          	sw	a5,160(a4) # 8000a030 <started>
    80000f98:	b759                	j	80000f1e <main+0x3e>

0000000080000f9a <kvminithart>:

// Switch the current CPU's h/w page table register to
// the kernel's page table, and enable paging.
void
kvminithart()
{
    80000f9a:	1141                	addi	sp,sp,-16
    80000f9c:	e406                	sd	ra,8(sp)
    80000f9e:	e022                	sd	s0,0(sp)
    80000fa0:	0800                	addi	s0,sp,16
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero");
    80000fa2:	12000073          	sfence.vma
  // wait for any previous writes to the page table memory to finish.
  sfence_vma();

  w_satp(MAKE_SATP(kernel_pagetable));
    80000fa6:	00009797          	auipc	a5,0x9
    80000faa:	0927b783          	ld	a5,146(a5) # 8000a038 <kernel_pagetable>
    80000fae:	83b1                	srli	a5,a5,0xc
    80000fb0:	577d                	li	a4,-1
    80000fb2:	177e                	slli	a4,a4,0x3f
    80000fb4:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r" (x));
    80000fb6:	18079073          	csrw	satp,a5
  asm volatile("sfence.vma zero, zero");
    80000fba:	12000073          	sfence.vma

  // flush stale entries from the TLB.
  sfence_vma();
}
    80000fbe:	60a2                	ld	ra,8(sp)
    80000fc0:	6402                	ld	s0,0(sp)
    80000fc2:	0141                	addi	sp,sp,16
    80000fc4:	8082                	ret

0000000080000fc6 <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    80000fc6:	7139                	addi	sp,sp,-64
    80000fc8:	fc06                	sd	ra,56(sp)
    80000fca:	f822                	sd	s0,48(sp)
    80000fcc:	f426                	sd	s1,40(sp)
    80000fce:	f04a                	sd	s2,32(sp)
    80000fd0:	ec4e                	sd	s3,24(sp)
    80000fd2:	e852                	sd	s4,16(sp)
    80000fd4:	e456                	sd	s5,8(sp)
    80000fd6:	e05a                	sd	s6,0(sp)
    80000fd8:	0080                	addi	s0,sp,64
    80000fda:	84aa                	mv	s1,a0
    80000fdc:	89ae                	mv	s3,a1
    80000fde:	8b32                	mv	s6,a2
  if(va >= MAXVA)
    80000fe0:	57fd                	li	a5,-1
    80000fe2:	83e9                	srli	a5,a5,0x1a
    80000fe4:	4a79                	li	s4,30
    panic("walk");

  for(int level = 2; level > 0; level--) {
    80000fe6:	4ab1                	li	s5,12
  if(va >= MAXVA)
    80000fe8:	04b7e263          	bltu	a5,a1,8000102c <walk+0x66>
    pte_t *pte = &pagetable[PX(level, va)];
    80000fec:	0149d933          	srl	s2,s3,s4
    80000ff0:	1ff97913          	andi	s2,s2,511
    80000ff4:	090e                	slli	s2,s2,0x3
    80000ff6:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) {
    80000ff8:	00093483          	ld	s1,0(s2)
    80000ffc:	0014f793          	andi	a5,s1,1
    80001000:	cf85                	beqz	a5,80001038 <walk+0x72>
      pagetable = (pagetable_t)PTE2PA(*pte);
    80001002:	80a9                	srli	s1,s1,0xa
    80001004:	04b2                	slli	s1,s1,0xc
  for(int level = 2; level > 0; level--) {
    80001006:	3a5d                	addiw	s4,s4,-9
    80001008:	ff5a12e3          	bne	s4,s5,80000fec <walk+0x26>
        return 0;
      memset(pagetable, 0, PGSIZE);
      *pte = PA2PTE(pagetable) | PTE_V;
    }
  }
  return &pagetable[PX(0, va)];
    8000100c:	00c9d513          	srli	a0,s3,0xc
    80001010:	1ff57513          	andi	a0,a0,511
    80001014:	050e                	slli	a0,a0,0x3
    80001016:	9526                	add	a0,a0,s1
}
    80001018:	70e2                	ld	ra,56(sp)
    8000101a:	7442                	ld	s0,48(sp)
    8000101c:	74a2                	ld	s1,40(sp)
    8000101e:	7902                	ld	s2,32(sp)
    80001020:	69e2                	ld	s3,24(sp)
    80001022:	6a42                	ld	s4,16(sp)
    80001024:	6aa2                	ld	s5,8(sp)
    80001026:	6b02                	ld	s6,0(sp)
    80001028:	6121                	addi	sp,sp,64
    8000102a:	8082                	ret
    panic("walk");
    8000102c:	00008517          	auipc	a0,0x8
    80001030:	07c50513          	addi	a0,a0,124 # 800090a8 <etext+0xa8>
    80001034:	823ff0ef          	jal	80000856 <panic>
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    80001038:	020b0263          	beqz	s6,8000105c <walk+0x96>
    8000103c:	b3bff0ef          	jal	80000b76 <kalloc>
    80001040:	84aa                	mv	s1,a0
    80001042:	d979                	beqz	a0,80001018 <walk+0x52>
      memset(pagetable, 0, PGSIZE);
    80001044:	6605                	lui	a2,0x1
    80001046:	4581                	li	a1,0
    80001048:	ce3ff0ef          	jal	80000d2a <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    8000104c:	00c4d793          	srli	a5,s1,0xc
    80001050:	07aa                	slli	a5,a5,0xa
    80001052:	0017e793          	ori	a5,a5,1
    80001056:	00f93023          	sd	a5,0(s2)
    8000105a:	b775                	j	80001006 <walk+0x40>
        return 0;
    8000105c:	4501                	li	a0,0
    8000105e:	bf6d                	j	80001018 <walk+0x52>

0000000080001060 <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if(va >= MAXVA)
    80001060:	57fd                	li	a5,-1
    80001062:	83e9                	srli	a5,a5,0x1a
    80001064:	00b7f463          	bgeu	a5,a1,8000106c <walkaddr+0xc>
    return 0;
    80001068:	4501                	li	a0,0
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}
    8000106a:	8082                	ret
{
    8000106c:	1141                	addi	sp,sp,-16
    8000106e:	e406                	sd	ra,8(sp)
    80001070:	e022                	sd	s0,0(sp)
    80001072:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    80001074:	4601                	li	a2,0
    80001076:	f51ff0ef          	jal	80000fc6 <walk>
  if(pte == 0)
    8000107a:	c901                	beqz	a0,8000108a <walkaddr+0x2a>
  if((*pte & PTE_V) == 0)
    8000107c:	611c                	ld	a5,0(a0)
  if((*pte & PTE_U) == 0)
    8000107e:	0117f693          	andi	a3,a5,17
    80001082:	4745                	li	a4,17
    return 0;
    80001084:	4501                	li	a0,0
  if((*pte & PTE_U) == 0)
    80001086:	00e68663          	beq	a3,a4,80001092 <walkaddr+0x32>
}
    8000108a:	60a2                	ld	ra,8(sp)
    8000108c:	6402                	ld	s0,0(sp)
    8000108e:	0141                	addi	sp,sp,16
    80001090:	8082                	ret
  pa = PTE2PA(*pte);
    80001092:	83a9                	srli	a5,a5,0xa
    80001094:	00c79513          	slli	a0,a5,0xc
  return pa;
    80001098:	bfcd                	j	8000108a <walkaddr+0x2a>

000000008000109a <mappages>:
// va and size MUST be page-aligned.
// Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    8000109a:	715d                	addi	sp,sp,-80
    8000109c:	e486                	sd	ra,72(sp)
    8000109e:	e0a2                	sd	s0,64(sp)
    800010a0:	fc26                	sd	s1,56(sp)
    800010a2:	f84a                	sd	s2,48(sp)
    800010a4:	f44e                	sd	s3,40(sp)
    800010a6:	f052                	sd	s4,32(sp)
    800010a8:	ec56                	sd	s5,24(sp)
    800010aa:	e85a                	sd	s6,16(sp)
    800010ac:	e45e                	sd	s7,8(sp)
    800010ae:	0880                	addi	s0,sp,80
  uint64 a, last;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    800010b0:	03459793          	slli	a5,a1,0x34
    800010b4:	eba1                	bnez	a5,80001104 <mappages+0x6a>
    800010b6:	8a2a                	mv	s4,a0
    800010b8:	8aba                	mv	s5,a4
    panic("mappages: va not aligned");

  if((size % PGSIZE) != 0)
    800010ba:	03461793          	slli	a5,a2,0x34
    800010be:	eba9                	bnez	a5,80001110 <mappages+0x76>
    panic("mappages: size not aligned");

  if(size == 0)
    800010c0:	ce31                	beqz	a2,8000111c <mappages+0x82>
    panic("mappages: size");
  
  a = va;
  last = va + size - PGSIZE;
    800010c2:	80060613          	addi	a2,a2,-2048 # 800 <_entry-0x7ffff800>
    800010c6:	80060613          	addi	a2,a2,-2048
    800010ca:	00b60933          	add	s2,a2,a1
  a = va;
    800010ce:	84ae                	mv	s1,a1
  for(;;){
    if((pte = walk(pagetable, a, 1)) == 0)
    800010d0:	4b05                	li	s6,1
    800010d2:	40b689b3          	sub	s3,a3,a1
    if(*pte & PTE_V)
      panic("mappages: remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if(a == last)
      break;
    a += PGSIZE;
    800010d6:	6b85                	lui	s7,0x1
    if((pte = walk(pagetable, a, 1)) == 0)
    800010d8:	865a                	mv	a2,s6
    800010da:	85a6                	mv	a1,s1
    800010dc:	8552                	mv	a0,s4
    800010de:	ee9ff0ef          	jal	80000fc6 <walk>
    800010e2:	c929                	beqz	a0,80001134 <mappages+0x9a>
    if(*pte & PTE_V)
    800010e4:	611c                	ld	a5,0(a0)
    800010e6:	8b85                	andi	a5,a5,1
    800010e8:	e3a1                	bnez	a5,80001128 <mappages+0x8e>
    *pte = PA2PTE(pa) | perm | PTE_V;
    800010ea:	013487b3          	add	a5,s1,s3
    800010ee:	83b1                	srli	a5,a5,0xc
    800010f0:	07aa                	slli	a5,a5,0xa
    800010f2:	0157e7b3          	or	a5,a5,s5
    800010f6:	0017e793          	ori	a5,a5,1
    800010fa:	e11c                	sd	a5,0(a0)
    if(a == last)
    800010fc:	05248863          	beq	s1,s2,8000114c <mappages+0xb2>
    a += PGSIZE;
    80001100:	94de                	add	s1,s1,s7
    if((pte = walk(pagetable, a, 1)) == 0)
    80001102:	bfd9                	j	800010d8 <mappages+0x3e>
    panic("mappages: va not aligned");
    80001104:	00008517          	auipc	a0,0x8
    80001108:	fac50513          	addi	a0,a0,-84 # 800090b0 <etext+0xb0>
    8000110c:	f4aff0ef          	jal	80000856 <panic>
    panic("mappages: size not aligned");
    80001110:	00008517          	auipc	a0,0x8
    80001114:	fc050513          	addi	a0,a0,-64 # 800090d0 <etext+0xd0>
    80001118:	f3eff0ef          	jal	80000856 <panic>
    panic("mappages: size");
    8000111c:	00008517          	auipc	a0,0x8
    80001120:	fd450513          	addi	a0,a0,-44 # 800090f0 <etext+0xf0>
    80001124:	f32ff0ef          	jal	80000856 <panic>
      panic("mappages: remap");
    80001128:	00008517          	auipc	a0,0x8
    8000112c:	fd850513          	addi	a0,a0,-40 # 80009100 <etext+0x100>
    80001130:	f26ff0ef          	jal	80000856 <panic>
      return -1;
    80001134:	557d                	li	a0,-1
    pa += PGSIZE;
  }
  return 0;
}
    80001136:	60a6                	ld	ra,72(sp)
    80001138:	6406                	ld	s0,64(sp)
    8000113a:	74e2                	ld	s1,56(sp)
    8000113c:	7942                	ld	s2,48(sp)
    8000113e:	79a2                	ld	s3,40(sp)
    80001140:	7a02                	ld	s4,32(sp)
    80001142:	6ae2                	ld	s5,24(sp)
    80001144:	6b42                	ld	s6,16(sp)
    80001146:	6ba2                	ld	s7,8(sp)
    80001148:	6161                	addi	sp,sp,80
    8000114a:	8082                	ret
  return 0;
    8000114c:	4501                	li	a0,0
    8000114e:	b7e5                	j	80001136 <mappages+0x9c>

0000000080001150 <kvmmap>:
{
    80001150:	1141                	addi	sp,sp,-16
    80001152:	e406                	sd	ra,8(sp)
    80001154:	e022                	sd	s0,0(sp)
    80001156:	0800                	addi	s0,sp,16
    80001158:	87b6                	mv	a5,a3
  if(mappages(kpgtbl, va, sz, pa, perm) != 0)
    8000115a:	86b2                	mv	a3,a2
    8000115c:	863e                	mv	a2,a5
    8000115e:	f3dff0ef          	jal	8000109a <mappages>
    80001162:	e509                	bnez	a0,8000116c <kvmmap+0x1c>
}
    80001164:	60a2                	ld	ra,8(sp)
    80001166:	6402                	ld	s0,0(sp)
    80001168:	0141                	addi	sp,sp,16
    8000116a:	8082                	ret
    panic("kvmmap");
    8000116c:	00008517          	auipc	a0,0x8
    80001170:	fa450513          	addi	a0,a0,-92 # 80009110 <etext+0x110>
    80001174:	ee2ff0ef          	jal	80000856 <panic>

0000000080001178 <kvmmake>:
{
    80001178:	1101                	addi	sp,sp,-32
    8000117a:	ec06                	sd	ra,24(sp)
    8000117c:	e822                	sd	s0,16(sp)
    8000117e:	e426                	sd	s1,8(sp)
    80001180:	1000                	addi	s0,sp,32
  kpgtbl = (pagetable_t) kalloc();
    80001182:	9f5ff0ef          	jal	80000b76 <kalloc>
    80001186:	84aa                	mv	s1,a0
  memset(kpgtbl, 0, PGSIZE);
    80001188:	6605                	lui	a2,0x1
    8000118a:	4581                	li	a1,0
    8000118c:	b9fff0ef          	jal	80000d2a <memset>
  kvmmap(kpgtbl, UART0, UART0, PGSIZE, PTE_R | PTE_W);
    80001190:	4719                	li	a4,6
    80001192:	6685                	lui	a3,0x1
    80001194:	10000637          	lui	a2,0x10000
    80001198:	85b2                	mv	a1,a2
    8000119a:	8526                	mv	a0,s1
    8000119c:	fb5ff0ef          	jal	80001150 <kvmmap>
  kvmmap(kpgtbl, VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    800011a0:	4719                	li	a4,6
    800011a2:	6685                	lui	a3,0x1
    800011a4:	10001637          	lui	a2,0x10001
    800011a8:	85b2                	mv	a1,a2
    800011aa:	8526                	mv	a0,s1
    800011ac:	fa5ff0ef          	jal	80001150 <kvmmap>
  kvmmap(kpgtbl, PLIC, PLIC, 0x4000000, PTE_R | PTE_W);
    800011b0:	4719                	li	a4,6
    800011b2:	040006b7          	lui	a3,0x4000
    800011b6:	0c000637          	lui	a2,0xc000
    800011ba:	85b2                	mv	a1,a2
    800011bc:	8526                	mv	a0,s1
    800011be:	f93ff0ef          	jal	80001150 <kvmmap>
  kvmmap(kpgtbl, KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    800011c2:	4729                	li	a4,10
    800011c4:	80008697          	auipc	a3,0x80008
    800011c8:	e3c68693          	addi	a3,a3,-452 # 9000 <_entry-0x7fff7000>
    800011cc:	4605                	li	a2,1
    800011ce:	067e                	slli	a2,a2,0x1f
    800011d0:	85b2                	mv	a1,a2
    800011d2:	8526                	mv	a0,s1
    800011d4:	f7dff0ef          	jal	80001150 <kvmmap>
  kvmmap(kpgtbl, (uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    800011d8:	4719                	li	a4,6
    800011da:	00008697          	auipc	a3,0x8
    800011de:	e2668693          	addi	a3,a3,-474 # 80009000 <etext>
    800011e2:	47c5                	li	a5,17
    800011e4:	07ee                	slli	a5,a5,0x1b
    800011e6:	40d786b3          	sub	a3,a5,a3
    800011ea:	00008617          	auipc	a2,0x8
    800011ee:	e1660613          	addi	a2,a2,-490 # 80009000 <etext>
    800011f2:	85b2                	mv	a1,a2
    800011f4:	8526                	mv	a0,s1
    800011f6:	f5bff0ef          	jal	80001150 <kvmmap>
  kvmmap(kpgtbl, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    800011fa:	4729                	li	a4,10
    800011fc:	6685                	lui	a3,0x1
    800011fe:	00007617          	auipc	a2,0x7
    80001202:	e0260613          	addi	a2,a2,-510 # 80008000 <_trampoline>
    80001206:	040005b7          	lui	a1,0x4000
    8000120a:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    8000120c:	05b2                	slli	a1,a1,0xc
    8000120e:	8526                	mv	a0,s1
    80001210:	f41ff0ef          	jal	80001150 <kvmmap>
  proc_mapstacks(kpgtbl);
    80001214:	8526                	mv	a0,s1
    80001216:	5c4000ef          	jal	800017da <proc_mapstacks>
}
    8000121a:	8526                	mv	a0,s1
    8000121c:	60e2                	ld	ra,24(sp)
    8000121e:	6442                	ld	s0,16(sp)
    80001220:	64a2                	ld	s1,8(sp)
    80001222:	6105                	addi	sp,sp,32
    80001224:	8082                	ret

0000000080001226 <kvminit>:
{
    80001226:	1141                	addi	sp,sp,-16
    80001228:	e406                	sd	ra,8(sp)
    8000122a:	e022                	sd	s0,0(sp)
    8000122c:	0800                	addi	s0,sp,16
  kernel_pagetable = kvmmake();
    8000122e:	f4bff0ef          	jal	80001178 <kvmmake>
    80001232:	00009797          	auipc	a5,0x9
    80001236:	e0a7b323          	sd	a0,-506(a5) # 8000a038 <kernel_pagetable>
}
    8000123a:	60a2                	ld	ra,8(sp)
    8000123c:	6402                	ld	s0,0(sp)
    8000123e:	0141                	addi	sp,sp,16
    80001240:	8082                	ret

0000000080001242 <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    80001242:	1101                	addi	sp,sp,-32
    80001244:	ec06                	sd	ra,24(sp)
    80001246:	e822                	sd	s0,16(sp)
    80001248:	e426                	sd	s1,8(sp)
    8000124a:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t) kalloc();
    8000124c:	92bff0ef          	jal	80000b76 <kalloc>
    80001250:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001252:	c509                	beqz	a0,8000125c <uvmcreate+0x1a>
    return 0;
  memset(pagetable, 0, PGSIZE);
    80001254:	6605                	lui	a2,0x1
    80001256:	4581                	li	a1,0
    80001258:	ad3ff0ef          	jal	80000d2a <memset>
  return pagetable;
}
    8000125c:	8526                	mv	a0,s1
    8000125e:	60e2                	ld	ra,24(sp)
    80001260:	6442                	ld	s0,16(sp)
    80001262:	64a2                	ld	s1,8(sp)
    80001264:	6105                	addi	sp,sp,32
    80001266:	8082                	ret

0000000080001268 <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. It's OK if the mappings don't exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    80001268:	7139                	addi	sp,sp,-64
    8000126a:	fc06                	sd	ra,56(sp)
    8000126c:	f822                	sd	s0,48(sp)
    8000126e:	0080                	addi	s0,sp,64
  uint64 a;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    80001270:	03459793          	slli	a5,a1,0x34
    80001274:	e38d                	bnez	a5,80001296 <uvmunmap+0x2e>
    80001276:	f04a                	sd	s2,32(sp)
    80001278:	ec4e                	sd	s3,24(sp)
    8000127a:	e852                	sd	s4,16(sp)
    8000127c:	e456                	sd	s5,8(sp)
    8000127e:	e05a                	sd	s6,0(sp)
    80001280:	8a2a                	mv	s4,a0
    80001282:	892e                	mv	s2,a1
    80001284:	8ab6                	mv	s5,a3
    panic("uvmunmap: not aligned");

  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80001286:	0632                	slli	a2,a2,0xc
    80001288:	00b609b3          	add	s3,a2,a1
    8000128c:	6b05                	lui	s6,0x1
    8000128e:	0535f963          	bgeu	a1,s3,800012e0 <uvmunmap+0x78>
    80001292:	f426                	sd	s1,40(sp)
    80001294:	a015                	j	800012b8 <uvmunmap+0x50>
    80001296:	f426                	sd	s1,40(sp)
    80001298:	f04a                	sd	s2,32(sp)
    8000129a:	ec4e                	sd	s3,24(sp)
    8000129c:	e852                	sd	s4,16(sp)
    8000129e:	e456                	sd	s5,8(sp)
    800012a0:	e05a                	sd	s6,0(sp)
    panic("uvmunmap: not aligned");
    800012a2:	00008517          	auipc	a0,0x8
    800012a6:	e7650513          	addi	a0,a0,-394 # 80009118 <etext+0x118>
    800012aa:	dacff0ef          	jal	80000856 <panic>
      continue;
    if(do_free){
      uint64 pa = PTE2PA(*pte);
      kfree((void*)pa);
    }
    *pte = 0;
    800012ae:	0004b023          	sd	zero,0(s1)
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800012b2:	995a                	add	s2,s2,s6
    800012b4:	03397563          	bgeu	s2,s3,800012de <uvmunmap+0x76>
    if((pte = walk(pagetable, a, 0)) == 0) // leaf page table entry allocated?
    800012b8:	4601                	li	a2,0
    800012ba:	85ca                	mv	a1,s2
    800012bc:	8552                	mv	a0,s4
    800012be:	d09ff0ef          	jal	80000fc6 <walk>
    800012c2:	84aa                	mv	s1,a0
    800012c4:	d57d                	beqz	a0,800012b2 <uvmunmap+0x4a>
    if((*pte & PTE_V) == 0)  // has physical page been allocated?
    800012c6:	611c                	ld	a5,0(a0)
    800012c8:	0017f713          	andi	a4,a5,1
    800012cc:	d37d                	beqz	a4,800012b2 <uvmunmap+0x4a>
    if(do_free){
    800012ce:	fe0a80e3          	beqz	s5,800012ae <uvmunmap+0x46>
      uint64 pa = PTE2PA(*pte);
    800012d2:	83a9                	srli	a5,a5,0xa
      kfree((void*)pa);
    800012d4:	00c79513          	slli	a0,a5,0xc
    800012d8:	fb6ff0ef          	jal	80000a8e <kfree>
    800012dc:	bfc9                	j	800012ae <uvmunmap+0x46>
    800012de:	74a2                	ld	s1,40(sp)
    800012e0:	7902                	ld	s2,32(sp)
    800012e2:	69e2                	ld	s3,24(sp)
    800012e4:	6a42                	ld	s4,16(sp)
    800012e6:	6aa2                	ld	s5,8(sp)
    800012e8:	6b02                	ld	s6,0(sp)
  }
}
    800012ea:	70e2                	ld	ra,56(sp)
    800012ec:	7442                	ld	s0,48(sp)
    800012ee:	6121                	addi	sp,sp,64
    800012f0:	8082                	ret

00000000800012f2 <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    800012f2:	1101                	addi	sp,sp,-32
    800012f4:	ec06                	sd	ra,24(sp)
    800012f6:	e822                	sd	s0,16(sp)
    800012f8:	e426                	sd	s1,8(sp)
    800012fa:	1000                	addi	s0,sp,32
  if(newsz >= oldsz)
    return oldsz;
    800012fc:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    800012fe:	00b67d63          	bgeu	a2,a1,80001318 <uvmdealloc+0x26>
    80001302:	84b2                	mv	s1,a2

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    80001304:	6785                	lui	a5,0x1
    80001306:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80001308:	00f60733          	add	a4,a2,a5
    8000130c:	76fd                	lui	a3,0xfffff
    8000130e:	8f75                	and	a4,a4,a3
    80001310:	97ae                	add	a5,a5,a1
    80001312:	8ff5                	and	a5,a5,a3
    80001314:	00f76863          	bltu	a4,a5,80001324 <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    80001318:	8526                	mv	a0,s1
    8000131a:	60e2                	ld	ra,24(sp)
    8000131c:	6442                	ld	s0,16(sp)
    8000131e:	64a2                	ld	s1,8(sp)
    80001320:	6105                	addi	sp,sp,32
    80001322:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    80001324:	8f99                	sub	a5,a5,a4
    80001326:	83b1                	srli	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    80001328:	4685                	li	a3,1
    8000132a:	0007861b          	sext.w	a2,a5
    8000132e:	85ba                	mv	a1,a4
    80001330:	f39ff0ef          	jal	80001268 <uvmunmap>
    80001334:	b7d5                	j	80001318 <uvmdealloc+0x26>

0000000080001336 <uvmalloc>:
  if(newsz < oldsz)
    80001336:	0ab66163          	bltu	a2,a1,800013d8 <uvmalloc+0xa2>
{
    8000133a:	715d                	addi	sp,sp,-80
    8000133c:	e486                	sd	ra,72(sp)
    8000133e:	e0a2                	sd	s0,64(sp)
    80001340:	f84a                	sd	s2,48(sp)
    80001342:	f052                	sd	s4,32(sp)
    80001344:	ec56                	sd	s5,24(sp)
    80001346:	e45e                	sd	s7,8(sp)
    80001348:	0880                	addi	s0,sp,80
    8000134a:	8aaa                	mv	s5,a0
    8000134c:	8a32                	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    8000134e:	6785                	lui	a5,0x1
    80001350:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80001352:	95be                	add	a1,a1,a5
    80001354:	77fd                	lui	a5,0xfffff
    80001356:	00f5f933          	and	s2,a1,a5
    8000135a:	8bca                	mv	s7,s2
  for(a = oldsz; a < newsz; a += PGSIZE){
    8000135c:	08c97063          	bgeu	s2,a2,800013dc <uvmalloc+0xa6>
    80001360:	fc26                	sd	s1,56(sp)
    80001362:	f44e                	sd	s3,40(sp)
    80001364:	e85a                	sd	s6,16(sp)
    memset(mem, 0, PGSIZE);
    80001366:	6985                	lui	s3,0x1
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    80001368:	0126eb13          	ori	s6,a3,18
    mem = kalloc();
    8000136c:	80bff0ef          	jal	80000b76 <kalloc>
    80001370:	84aa                	mv	s1,a0
    if(mem == 0){
    80001372:	c50d                	beqz	a0,8000139c <uvmalloc+0x66>
    memset(mem, 0, PGSIZE);
    80001374:	864e                	mv	a2,s3
    80001376:	4581                	li	a1,0
    80001378:	9b3ff0ef          	jal	80000d2a <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    8000137c:	875a                	mv	a4,s6
    8000137e:	86a6                	mv	a3,s1
    80001380:	864e                	mv	a2,s3
    80001382:	85ca                	mv	a1,s2
    80001384:	8556                	mv	a0,s5
    80001386:	d15ff0ef          	jal	8000109a <mappages>
    8000138a:	e915                	bnez	a0,800013be <uvmalloc+0x88>
  for(a = oldsz; a < newsz; a += PGSIZE){
    8000138c:	994e                	add	s2,s2,s3
    8000138e:	fd496fe3          	bltu	s2,s4,8000136c <uvmalloc+0x36>
  return newsz;
    80001392:	8552                	mv	a0,s4
    80001394:	74e2                	ld	s1,56(sp)
    80001396:	79a2                	ld	s3,40(sp)
    80001398:	6b42                	ld	s6,16(sp)
    8000139a:	a811                	j	800013ae <uvmalloc+0x78>
      uvmdealloc(pagetable, a, oldsz);
    8000139c:	865e                	mv	a2,s7
    8000139e:	85ca                	mv	a1,s2
    800013a0:	8556                	mv	a0,s5
    800013a2:	f51ff0ef          	jal	800012f2 <uvmdealloc>
      return 0;
    800013a6:	4501                	li	a0,0
    800013a8:	74e2                	ld	s1,56(sp)
    800013aa:	79a2                	ld	s3,40(sp)
    800013ac:	6b42                	ld	s6,16(sp)
}
    800013ae:	60a6                	ld	ra,72(sp)
    800013b0:	6406                	ld	s0,64(sp)
    800013b2:	7942                	ld	s2,48(sp)
    800013b4:	7a02                	ld	s4,32(sp)
    800013b6:	6ae2                	ld	s5,24(sp)
    800013b8:	6ba2                	ld	s7,8(sp)
    800013ba:	6161                	addi	sp,sp,80
    800013bc:	8082                	ret
      kfree(mem);
    800013be:	8526                	mv	a0,s1
    800013c0:	eceff0ef          	jal	80000a8e <kfree>
      uvmdealloc(pagetable, a, oldsz);
    800013c4:	865e                	mv	a2,s7
    800013c6:	85ca                	mv	a1,s2
    800013c8:	8556                	mv	a0,s5
    800013ca:	f29ff0ef          	jal	800012f2 <uvmdealloc>
      return 0;
    800013ce:	4501                	li	a0,0
    800013d0:	74e2                	ld	s1,56(sp)
    800013d2:	79a2                	ld	s3,40(sp)
    800013d4:	6b42                	ld	s6,16(sp)
    800013d6:	bfe1                	j	800013ae <uvmalloc+0x78>
    return oldsz;
    800013d8:	852e                	mv	a0,a1
}
    800013da:	8082                	ret
  return newsz;
    800013dc:	8532                	mv	a0,a2
    800013de:	bfc1                	j	800013ae <uvmalloc+0x78>

00000000800013e0 <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    800013e0:	7179                	addi	sp,sp,-48
    800013e2:	f406                	sd	ra,40(sp)
    800013e4:	f022                	sd	s0,32(sp)
    800013e6:	ec26                	sd	s1,24(sp)
    800013e8:	e84a                	sd	s2,16(sp)
    800013ea:	e44e                	sd	s3,8(sp)
    800013ec:	1800                	addi	s0,sp,48
    800013ee:	89aa                	mv	s3,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    800013f0:	84aa                	mv	s1,a0
    800013f2:	6905                	lui	s2,0x1
    800013f4:	992a                	add	s2,s2,a0
    800013f6:	a811                	j	8000140a <freewalk+0x2a>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
      freewalk((pagetable_t)child);
      pagetable[i] = 0;
    } else if(pte & PTE_V){
      panic("freewalk: leaf");
    800013f8:	00008517          	auipc	a0,0x8
    800013fc:	d3850513          	addi	a0,a0,-712 # 80009130 <etext+0x130>
    80001400:	c56ff0ef          	jal	80000856 <panic>
  for(int i = 0; i < 512; i++){
    80001404:	04a1                	addi	s1,s1,8
    80001406:	03248163          	beq	s1,s2,80001428 <freewalk+0x48>
    pte_t pte = pagetable[i];
    8000140a:	609c                	ld	a5,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    8000140c:	0017f713          	andi	a4,a5,1
    80001410:	db75                	beqz	a4,80001404 <freewalk+0x24>
    80001412:	00e7f713          	andi	a4,a5,14
    80001416:	f36d                	bnez	a4,800013f8 <freewalk+0x18>
      uint64 child = PTE2PA(pte);
    80001418:	83a9                	srli	a5,a5,0xa
      freewalk((pagetable_t)child);
    8000141a:	00c79513          	slli	a0,a5,0xc
    8000141e:	fc3ff0ef          	jal	800013e0 <freewalk>
      pagetable[i] = 0;
    80001422:	0004b023          	sd	zero,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    80001426:	bff9                	j	80001404 <freewalk+0x24>
    }
  }
  kfree((void*)pagetable);
    80001428:	854e                	mv	a0,s3
    8000142a:	e64ff0ef          	jal	80000a8e <kfree>
}
    8000142e:	70a2                	ld	ra,40(sp)
    80001430:	7402                	ld	s0,32(sp)
    80001432:	64e2                	ld	s1,24(sp)
    80001434:	6942                	ld	s2,16(sp)
    80001436:	69a2                	ld	s3,8(sp)
    80001438:	6145                	addi	sp,sp,48
    8000143a:	8082                	ret

000000008000143c <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    8000143c:	1101                	addi	sp,sp,-32
    8000143e:	ec06                	sd	ra,24(sp)
    80001440:	e822                	sd	s0,16(sp)
    80001442:	e426                	sd	s1,8(sp)
    80001444:	1000                	addi	s0,sp,32
    80001446:	84aa                	mv	s1,a0
  if(sz > 0)
    80001448:	e989                	bnez	a1,8000145a <uvmfree+0x1e>
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
  freewalk(pagetable);
    8000144a:	8526                	mv	a0,s1
    8000144c:	f95ff0ef          	jal	800013e0 <freewalk>
}
    80001450:	60e2                	ld	ra,24(sp)
    80001452:	6442                	ld	s0,16(sp)
    80001454:	64a2                	ld	s1,8(sp)
    80001456:	6105                	addi	sp,sp,32
    80001458:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
    8000145a:	6785                	lui	a5,0x1
    8000145c:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    8000145e:	95be                	add	a1,a1,a5
    80001460:	4685                	li	a3,1
    80001462:	00c5d613          	srli	a2,a1,0xc
    80001466:	4581                	li	a1,0
    80001468:	e01ff0ef          	jal	80001268 <uvmunmap>
    8000146c:	bff9                	j	8000144a <uvmfree+0xe>

000000008000146e <uvmcopy>:
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for(i = 0; i < sz; i += PGSIZE){
    8000146e:	ca59                	beqz	a2,80001504 <uvmcopy+0x96>
{
    80001470:	715d                	addi	sp,sp,-80
    80001472:	e486                	sd	ra,72(sp)
    80001474:	e0a2                	sd	s0,64(sp)
    80001476:	fc26                	sd	s1,56(sp)
    80001478:	f84a                	sd	s2,48(sp)
    8000147a:	f44e                	sd	s3,40(sp)
    8000147c:	f052                	sd	s4,32(sp)
    8000147e:	ec56                	sd	s5,24(sp)
    80001480:	e85a                	sd	s6,16(sp)
    80001482:	e45e                	sd	s7,8(sp)
    80001484:	0880                	addi	s0,sp,80
    80001486:	8b2a                	mv	s6,a0
    80001488:	8bae                	mv	s7,a1
    8000148a:	8ab2                	mv	s5,a2
  for(i = 0; i < sz; i += PGSIZE){
    8000148c:	4481                	li	s1,0
      continue;   // physical page hasn't been allocated
    pa = PTE2PA(*pte);
    flags = PTE_FLAGS(*pte);
    if((mem = kalloc()) == 0)
      goto err;
    memmove(mem, (char*)pa, PGSIZE);
    8000148e:	6a05                	lui	s4,0x1
    80001490:	a021                	j	80001498 <uvmcopy+0x2a>
  for(i = 0; i < sz; i += PGSIZE){
    80001492:	94d2                	add	s1,s1,s4
    80001494:	0554fc63          	bgeu	s1,s5,800014ec <uvmcopy+0x7e>
    if((pte = walk(old, i, 0)) == 0)
    80001498:	4601                	li	a2,0
    8000149a:	85a6                	mv	a1,s1
    8000149c:	855a                	mv	a0,s6
    8000149e:	b29ff0ef          	jal	80000fc6 <walk>
    800014a2:	d965                	beqz	a0,80001492 <uvmcopy+0x24>
    if((*pte & PTE_V) == 0)
    800014a4:	00053983          	ld	s3,0(a0)
    800014a8:	0019f793          	andi	a5,s3,1
    800014ac:	d3fd                	beqz	a5,80001492 <uvmcopy+0x24>
    if((mem = kalloc()) == 0)
    800014ae:	ec8ff0ef          	jal	80000b76 <kalloc>
    800014b2:	892a                	mv	s2,a0
    800014b4:	c11d                	beqz	a0,800014da <uvmcopy+0x6c>
    pa = PTE2PA(*pte);
    800014b6:	00a9d593          	srli	a1,s3,0xa
    memmove(mem, (char*)pa, PGSIZE);
    800014ba:	8652                	mv	a2,s4
    800014bc:	05b2                	slli	a1,a1,0xc
    800014be:	8cdff0ef          	jal	80000d8a <memmove>
    if(mappages(new, i, PGSIZE, (uint64)mem, flags) != 0){
    800014c2:	3ff9f713          	andi	a4,s3,1023
    800014c6:	86ca                	mv	a3,s2
    800014c8:	8652                	mv	a2,s4
    800014ca:	85a6                	mv	a1,s1
    800014cc:	855e                	mv	a0,s7
    800014ce:	bcdff0ef          	jal	8000109a <mappages>
    800014d2:	d161                	beqz	a0,80001492 <uvmcopy+0x24>
      kfree(mem);
    800014d4:	854a                	mv	a0,s2
    800014d6:	db8ff0ef          	jal	80000a8e <kfree>
    }
  }
  return 0;

 err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    800014da:	4685                	li	a3,1
    800014dc:	00c4d613          	srli	a2,s1,0xc
    800014e0:	4581                	li	a1,0
    800014e2:	855e                	mv	a0,s7
    800014e4:	d85ff0ef          	jal	80001268 <uvmunmap>
  return -1;
    800014e8:	557d                	li	a0,-1
    800014ea:	a011                	j	800014ee <uvmcopy+0x80>
  return 0;
    800014ec:	4501                	li	a0,0
}
    800014ee:	60a6                	ld	ra,72(sp)
    800014f0:	6406                	ld	s0,64(sp)
    800014f2:	74e2                	ld	s1,56(sp)
    800014f4:	7942                	ld	s2,48(sp)
    800014f6:	79a2                	ld	s3,40(sp)
    800014f8:	7a02                	ld	s4,32(sp)
    800014fa:	6ae2                	ld	s5,24(sp)
    800014fc:	6b42                	ld	s6,16(sp)
    800014fe:	6ba2                	ld	s7,8(sp)
    80001500:	6161                	addi	sp,sp,80
    80001502:	8082                	ret
  return 0;
    80001504:	4501                	li	a0,0
}
    80001506:	8082                	ret

0000000080001508 <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    80001508:	1141                	addi	sp,sp,-16
    8000150a:	e406                	sd	ra,8(sp)
    8000150c:	e022                	sd	s0,0(sp)
    8000150e:	0800                	addi	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    80001510:	4601                	li	a2,0
    80001512:	ab5ff0ef          	jal	80000fc6 <walk>
  if(pte == 0)
    80001516:	c901                	beqz	a0,80001526 <uvmclear+0x1e>
    panic("uvmclear");
  *pte &= ~PTE_U;
    80001518:	611c                	ld	a5,0(a0)
    8000151a:	9bbd                	andi	a5,a5,-17
    8000151c:	e11c                	sd	a5,0(a0)
}
    8000151e:	60a2                	ld	ra,8(sp)
    80001520:	6402                	ld	s0,0(sp)
    80001522:	0141                	addi	sp,sp,16
    80001524:	8082                	ret
    panic("uvmclear");
    80001526:	00008517          	auipc	a0,0x8
    8000152a:	c1a50513          	addi	a0,a0,-998 # 80009140 <etext+0x140>
    8000152e:	b28ff0ef          	jal	80000856 <panic>

0000000080001532 <copyinstr>:
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    80001532:	cac5                	beqz	a3,800015e2 <copyinstr+0xb0>
{
    80001534:	715d                	addi	sp,sp,-80
    80001536:	e486                	sd	ra,72(sp)
    80001538:	e0a2                	sd	s0,64(sp)
    8000153a:	fc26                	sd	s1,56(sp)
    8000153c:	f84a                	sd	s2,48(sp)
    8000153e:	f44e                	sd	s3,40(sp)
    80001540:	f052                	sd	s4,32(sp)
    80001542:	ec56                	sd	s5,24(sp)
    80001544:	e85a                	sd	s6,16(sp)
    80001546:	e45e                	sd	s7,8(sp)
    80001548:	0880                	addi	s0,sp,80
    8000154a:	8aaa                	mv	s5,a0
    8000154c:	84ae                	mv	s1,a1
    8000154e:	8bb2                	mv	s7,a2
    80001550:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(srcva);
    80001552:	7b7d                	lui	s6,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    80001554:	6a05                	lui	s4,0x1
    80001556:	a82d                	j	80001590 <copyinstr+0x5e>
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
    80001558:	00078023          	sb	zero,0(a5)
        got_null = 1;
    8000155c:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    8000155e:	0017c793          	xori	a5,a5,1
    80001562:	40f0053b          	negw	a0,a5
    return 0;
  } else {
    return -1;
  }
}
    80001566:	60a6                	ld	ra,72(sp)
    80001568:	6406                	ld	s0,64(sp)
    8000156a:	74e2                	ld	s1,56(sp)
    8000156c:	7942                	ld	s2,48(sp)
    8000156e:	79a2                	ld	s3,40(sp)
    80001570:	7a02                	ld	s4,32(sp)
    80001572:	6ae2                	ld	s5,24(sp)
    80001574:	6b42                	ld	s6,16(sp)
    80001576:	6ba2                	ld	s7,8(sp)
    80001578:	6161                	addi	sp,sp,80
    8000157a:	8082                	ret
    8000157c:	fff98713          	addi	a4,s3,-1 # fff <_entry-0x7ffff001>
    80001580:	9726                	add	a4,a4,s1
      --max;
    80001582:	40b709b3          	sub	s3,a4,a1
    srcva = va0 + PGSIZE;
    80001586:	01490bb3          	add	s7,s2,s4
  while(got_null == 0 && max > 0){
    8000158a:	04e58463          	beq	a1,a4,800015d2 <copyinstr+0xa0>
{
    8000158e:	84be                	mv	s1,a5
    va0 = PGROUNDDOWN(srcva);
    80001590:	016bf933          	and	s2,s7,s6
    pa0 = walkaddr(pagetable, va0);
    80001594:	85ca                	mv	a1,s2
    80001596:	8556                	mv	a0,s5
    80001598:	ac9ff0ef          	jal	80001060 <walkaddr>
    if(pa0 == 0)
    8000159c:	cd0d                	beqz	a0,800015d6 <copyinstr+0xa4>
    n = PGSIZE - (srcva - va0);
    8000159e:	417906b3          	sub	a3,s2,s7
    800015a2:	96d2                	add	a3,a3,s4
    if(n > max)
    800015a4:	00d9f363          	bgeu	s3,a3,800015aa <copyinstr+0x78>
    800015a8:	86ce                	mv	a3,s3
    while(n > 0){
    800015aa:	ca85                	beqz	a3,800015da <copyinstr+0xa8>
    char *p = (char *) (pa0 + (srcva - va0));
    800015ac:	01750633          	add	a2,a0,s7
    800015b0:	41260633          	sub	a2,a2,s2
    800015b4:	87a6                	mv	a5,s1
      if(*p == '\0'){
    800015b6:	8e05                	sub	a2,a2,s1
    while(n > 0){
    800015b8:	96a6                	add	a3,a3,s1
    800015ba:	85be                	mv	a1,a5
      if(*p == '\0'){
    800015bc:	00f60733          	add	a4,a2,a5
    800015c0:	00074703          	lbu	a4,0(a4)
    800015c4:	db51                	beqz	a4,80001558 <copyinstr+0x26>
        *dst = *p;
    800015c6:	00e78023          	sb	a4,0(a5)
      dst++;
    800015ca:	0785                	addi	a5,a5,1
    while(n > 0){
    800015cc:	fed797e3          	bne	a5,a3,800015ba <copyinstr+0x88>
    800015d0:	b775                	j	8000157c <copyinstr+0x4a>
    800015d2:	4781                	li	a5,0
    800015d4:	b769                	j	8000155e <copyinstr+0x2c>
      return -1;
    800015d6:	557d                	li	a0,-1
    800015d8:	b779                	j	80001566 <copyinstr+0x34>
    srcva = va0 + PGSIZE;
    800015da:	6b85                	lui	s7,0x1
    800015dc:	9bca                	add	s7,s7,s2
    800015de:	87a6                	mv	a5,s1
    800015e0:	b77d                	j	8000158e <copyinstr+0x5c>
  int got_null = 0;
    800015e2:	4781                	li	a5,0
  if(got_null){
    800015e4:	0017c793          	xori	a5,a5,1
    800015e8:	40f0053b          	negw	a0,a5
}
    800015ec:	8082                	ret

00000000800015ee <ismapped>:
  return mem;
}

int
ismapped(pagetable_t pagetable, uint64 va)
{
    800015ee:	1141                	addi	sp,sp,-16
    800015f0:	e406                	sd	ra,8(sp)
    800015f2:	e022                	sd	s0,0(sp)
    800015f4:	0800                	addi	s0,sp,16
  pte_t *pte = walk(pagetable, va, 0);
    800015f6:	4601                	li	a2,0
    800015f8:	9cfff0ef          	jal	80000fc6 <walk>
  if (pte == 0) {
    800015fc:	c119                	beqz	a0,80001602 <ismapped+0x14>
    return 0;
  }
  if (*pte & PTE_V){
    800015fe:	6108                	ld	a0,0(a0)
    80001600:	8905                	andi	a0,a0,1
    return 1;
  }
  return 0;
}
    80001602:	60a2                	ld	ra,8(sp)
    80001604:	6402                	ld	s0,0(sp)
    80001606:	0141                	addi	sp,sp,16
    80001608:	8082                	ret

000000008000160a <vmfault>:
{
    8000160a:	7179                	addi	sp,sp,-48
    8000160c:	f406                	sd	ra,40(sp)
    8000160e:	f022                	sd	s0,32(sp)
    80001610:	e84a                	sd	s2,16(sp)
    80001612:	e44e                	sd	s3,8(sp)
    80001614:	1800                	addi	s0,sp,48
    80001616:	89aa                	mv	s3,a0
    80001618:	892e                	mv	s2,a1
  struct proc *p = myproc();
    8000161a:	34e000ef          	jal	80001968 <myproc>
  if (va >= p->sz)
    8000161e:	653c                	ld	a5,72(a0)
    80001620:	00f96a63          	bltu	s2,a5,80001634 <vmfault+0x2a>
    return 0;
    80001624:	4981                	li	s3,0
}
    80001626:	854e                	mv	a0,s3
    80001628:	70a2                	ld	ra,40(sp)
    8000162a:	7402                	ld	s0,32(sp)
    8000162c:	6942                	ld	s2,16(sp)
    8000162e:	69a2                	ld	s3,8(sp)
    80001630:	6145                	addi	sp,sp,48
    80001632:	8082                	ret
    80001634:	ec26                	sd	s1,24(sp)
    80001636:	e052                	sd	s4,0(sp)
    80001638:	84aa                	mv	s1,a0
  va = PGROUNDDOWN(va);
    8000163a:	77fd                	lui	a5,0xfffff
    8000163c:	00f97a33          	and	s4,s2,a5
  if(ismapped(pagetable, va)) {
    80001640:	85d2                	mv	a1,s4
    80001642:	854e                	mv	a0,s3
    80001644:	fabff0ef          	jal	800015ee <ismapped>
    return 0;
    80001648:	4981                	li	s3,0
  if(ismapped(pagetable, va)) {
    8000164a:	c501                	beqz	a0,80001652 <vmfault+0x48>
    8000164c:	64e2                	ld	s1,24(sp)
    8000164e:	6a02                	ld	s4,0(sp)
    80001650:	bfd9                	j	80001626 <vmfault+0x1c>
  mem = (uint64) kalloc();
    80001652:	d24ff0ef          	jal	80000b76 <kalloc>
    80001656:	892a                	mv	s2,a0
  if(mem == 0)
    80001658:	c905                	beqz	a0,80001688 <vmfault+0x7e>
  mem = (uint64) kalloc();
    8000165a:	89aa                	mv	s3,a0
  memset((void *) mem, 0, PGSIZE);
    8000165c:	6605                	lui	a2,0x1
    8000165e:	4581                	li	a1,0
    80001660:	ecaff0ef          	jal	80000d2a <memset>
  if (mappages(p->pagetable, va, PGSIZE, mem, PTE_W|PTE_U|PTE_R) != 0) {
    80001664:	4759                	li	a4,22
    80001666:	86ca                	mv	a3,s2
    80001668:	6605                	lui	a2,0x1
    8000166a:	85d2                	mv	a1,s4
    8000166c:	68a8                	ld	a0,80(s1)
    8000166e:	a2dff0ef          	jal	8000109a <mappages>
    80001672:	e501                	bnez	a0,8000167a <vmfault+0x70>
    80001674:	64e2                	ld	s1,24(sp)
    80001676:	6a02                	ld	s4,0(sp)
    80001678:	b77d                	j	80001626 <vmfault+0x1c>
    kfree((void *)mem);
    8000167a:	854a                	mv	a0,s2
    8000167c:	c12ff0ef          	jal	80000a8e <kfree>
    return 0;
    80001680:	4981                	li	s3,0
    80001682:	64e2                	ld	s1,24(sp)
    80001684:	6a02                	ld	s4,0(sp)
    80001686:	b745                	j	80001626 <vmfault+0x1c>
    80001688:	64e2                	ld	s1,24(sp)
    8000168a:	6a02                	ld	s4,0(sp)
    8000168c:	bf69                	j	80001626 <vmfault+0x1c>

000000008000168e <copyout>:
  while(len > 0){
    8000168e:	cad1                	beqz	a3,80001722 <copyout+0x94>
{
    80001690:	711d                	addi	sp,sp,-96
    80001692:	ec86                	sd	ra,88(sp)
    80001694:	e8a2                	sd	s0,80(sp)
    80001696:	e4a6                	sd	s1,72(sp)
    80001698:	e0ca                	sd	s2,64(sp)
    8000169a:	fc4e                	sd	s3,56(sp)
    8000169c:	f852                	sd	s4,48(sp)
    8000169e:	f456                	sd	s5,40(sp)
    800016a0:	f05a                	sd	s6,32(sp)
    800016a2:	ec5e                	sd	s7,24(sp)
    800016a4:	e862                	sd	s8,16(sp)
    800016a6:	e466                	sd	s9,8(sp)
    800016a8:	e06a                	sd	s10,0(sp)
    800016aa:	1080                	addi	s0,sp,96
    800016ac:	8baa                	mv	s7,a0
    800016ae:	8a2e                	mv	s4,a1
    800016b0:	8b32                	mv	s6,a2
    800016b2:	8ab6                	mv	s5,a3
    va0 = PGROUNDDOWN(dstva);
    800016b4:	7d7d                	lui	s10,0xfffff
    if(va0 >= MAXVA)
    800016b6:	5cfd                	li	s9,-1
    800016b8:	01acdc93          	srli	s9,s9,0x1a
    n = PGSIZE - (dstva - va0);
    800016bc:	6c05                	lui	s8,0x1
    800016be:	a005                	j	800016de <copyout+0x50>
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    800016c0:	409a0533          	sub	a0,s4,s1
    800016c4:	0009061b          	sext.w	a2,s2
    800016c8:	85da                	mv	a1,s6
    800016ca:	954e                	add	a0,a0,s3
    800016cc:	ebeff0ef          	jal	80000d8a <memmove>
    len -= n;
    800016d0:	412a8ab3          	sub	s5,s5,s2
    src += n;
    800016d4:	9b4a                	add	s6,s6,s2
    dstva = va0 + PGSIZE;
    800016d6:	01848a33          	add	s4,s1,s8
  while(len > 0){
    800016da:	040a8263          	beqz	s5,8000171e <copyout+0x90>
    va0 = PGROUNDDOWN(dstva);
    800016de:	01aa74b3          	and	s1,s4,s10
    if(va0 >= MAXVA)
    800016e2:	049ce263          	bltu	s9,s1,80001726 <copyout+0x98>
    pa0 = walkaddr(pagetable, va0);
    800016e6:	85a6                	mv	a1,s1
    800016e8:	855e                	mv	a0,s7
    800016ea:	977ff0ef          	jal	80001060 <walkaddr>
    800016ee:	89aa                	mv	s3,a0
    if(pa0 == 0) {
    800016f0:	e901                	bnez	a0,80001700 <copyout+0x72>
      if((pa0 = vmfault(pagetable, va0, 0)) == 0) {
    800016f2:	4601                	li	a2,0
    800016f4:	85a6                	mv	a1,s1
    800016f6:	855e                	mv	a0,s7
    800016f8:	f13ff0ef          	jal	8000160a <vmfault>
    800016fc:	89aa                	mv	s3,a0
    800016fe:	c139                	beqz	a0,80001744 <copyout+0xb6>
    pte = walk(pagetable, va0, 0);
    80001700:	4601                	li	a2,0
    80001702:	85a6                	mv	a1,s1
    80001704:	855e                	mv	a0,s7
    80001706:	8c1ff0ef          	jal	80000fc6 <walk>
    if((*pte & PTE_W) == 0)
    8000170a:	611c                	ld	a5,0(a0)
    8000170c:	8b91                	andi	a5,a5,4
    8000170e:	cf8d                	beqz	a5,80001748 <copyout+0xba>
    n = PGSIZE - (dstva - va0);
    80001710:	41448933          	sub	s2,s1,s4
    80001714:	9962                	add	s2,s2,s8
    if(n > len)
    80001716:	fb2af5e3          	bgeu	s5,s2,800016c0 <copyout+0x32>
    8000171a:	8956                	mv	s2,s5
    8000171c:	b755                	j	800016c0 <copyout+0x32>
  return 0;
    8000171e:	4501                	li	a0,0
    80001720:	a021                	j	80001728 <copyout+0x9a>
    80001722:	4501                	li	a0,0
}
    80001724:	8082                	ret
      return -1;
    80001726:	557d                	li	a0,-1
}
    80001728:	60e6                	ld	ra,88(sp)
    8000172a:	6446                	ld	s0,80(sp)
    8000172c:	64a6                	ld	s1,72(sp)
    8000172e:	6906                	ld	s2,64(sp)
    80001730:	79e2                	ld	s3,56(sp)
    80001732:	7a42                	ld	s4,48(sp)
    80001734:	7aa2                	ld	s5,40(sp)
    80001736:	7b02                	ld	s6,32(sp)
    80001738:	6be2                	ld	s7,24(sp)
    8000173a:	6c42                	ld	s8,16(sp)
    8000173c:	6ca2                	ld	s9,8(sp)
    8000173e:	6d02                	ld	s10,0(sp)
    80001740:	6125                	addi	sp,sp,96
    80001742:	8082                	ret
        return -1;
    80001744:	557d                	li	a0,-1
    80001746:	b7cd                	j	80001728 <copyout+0x9a>
      return -1;
    80001748:	557d                	li	a0,-1
    8000174a:	bff9                	j	80001728 <copyout+0x9a>

000000008000174c <copyin>:
  while(len > 0){
    8000174c:	c6c9                	beqz	a3,800017d6 <copyin+0x8a>
{
    8000174e:	715d                	addi	sp,sp,-80
    80001750:	e486                	sd	ra,72(sp)
    80001752:	e0a2                	sd	s0,64(sp)
    80001754:	fc26                	sd	s1,56(sp)
    80001756:	f84a                	sd	s2,48(sp)
    80001758:	f44e                	sd	s3,40(sp)
    8000175a:	f052                	sd	s4,32(sp)
    8000175c:	ec56                	sd	s5,24(sp)
    8000175e:	e85a                	sd	s6,16(sp)
    80001760:	e45e                	sd	s7,8(sp)
    80001762:	e062                	sd	s8,0(sp)
    80001764:	0880                	addi	s0,sp,80
    80001766:	8baa                	mv	s7,a0
    80001768:	8aae                	mv	s5,a1
    8000176a:	8932                	mv	s2,a2
    8000176c:	8a36                	mv	s4,a3
    va0 = PGROUNDDOWN(srcva);
    8000176e:	7c7d                	lui	s8,0xfffff
    n = PGSIZE - (srcva - va0);
    80001770:	6b05                	lui	s6,0x1
    80001772:	a035                	j	8000179e <copyin+0x52>
    80001774:	412984b3          	sub	s1,s3,s2
    80001778:	94da                	add	s1,s1,s6
    if(n > len)
    8000177a:	009a7363          	bgeu	s4,s1,80001780 <copyin+0x34>
    8000177e:	84d2                	mv	s1,s4
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    80001780:	413905b3          	sub	a1,s2,s3
    80001784:	0004861b          	sext.w	a2,s1
    80001788:	95aa                	add	a1,a1,a0
    8000178a:	8556                	mv	a0,s5
    8000178c:	dfeff0ef          	jal	80000d8a <memmove>
    len -= n;
    80001790:	409a0a33          	sub	s4,s4,s1
    dst += n;
    80001794:	9aa6                	add	s5,s5,s1
    srcva = va0 + PGSIZE;
    80001796:	01698933          	add	s2,s3,s6
  while(len > 0){
    8000179a:	020a0163          	beqz	s4,800017bc <copyin+0x70>
    va0 = PGROUNDDOWN(srcva);
    8000179e:	018979b3          	and	s3,s2,s8
    pa0 = walkaddr(pagetable, va0);
    800017a2:	85ce                	mv	a1,s3
    800017a4:	855e                	mv	a0,s7
    800017a6:	8bbff0ef          	jal	80001060 <walkaddr>
    if(pa0 == 0) {
    800017aa:	f569                	bnez	a0,80001774 <copyin+0x28>
      if((pa0 = vmfault(pagetable, va0, 0)) == 0) {
    800017ac:	4601                	li	a2,0
    800017ae:	85ce                	mv	a1,s3
    800017b0:	855e                	mv	a0,s7
    800017b2:	e59ff0ef          	jal	8000160a <vmfault>
    800017b6:	fd5d                	bnez	a0,80001774 <copyin+0x28>
        return -1;
    800017b8:	557d                	li	a0,-1
    800017ba:	a011                	j	800017be <copyin+0x72>
  return 0;
    800017bc:	4501                	li	a0,0
}
    800017be:	60a6                	ld	ra,72(sp)
    800017c0:	6406                	ld	s0,64(sp)
    800017c2:	74e2                	ld	s1,56(sp)
    800017c4:	7942                	ld	s2,48(sp)
    800017c6:	79a2                	ld	s3,40(sp)
    800017c8:	7a02                	ld	s4,32(sp)
    800017ca:	6ae2                	ld	s5,24(sp)
    800017cc:	6b42                	ld	s6,16(sp)
    800017ce:	6ba2                	ld	s7,8(sp)
    800017d0:	6c02                	ld	s8,0(sp)
    800017d2:	6161                	addi	sp,sp,80
    800017d4:	8082                	ret
  return 0;
    800017d6:	4501                	li	a0,0
}
    800017d8:	8082                	ret

00000000800017da <proc_mapstacks>:
struct spinlock wait_lock;

// Allocate a page for each process's kernel stack.
// Map it high in memory, followed by an invalid
// guard page.
void proc_mapstacks(pagetable_t kpgtbl) {
    800017da:	715d                	addi	sp,sp,-80
    800017dc:	e486                	sd	ra,72(sp)
    800017de:	e0a2                	sd	s0,64(sp)
    800017e0:	fc26                	sd	s1,56(sp)
    800017e2:	f84a                	sd	s2,48(sp)
    800017e4:	f44e                	sd	s3,40(sp)
    800017e6:	f052                	sd	s4,32(sp)
    800017e8:	ec56                	sd	s5,24(sp)
    800017ea:	e85a                	sd	s6,16(sp)
    800017ec:	e45e                	sd	s7,8(sp)
    800017ee:	e062                	sd	s8,0(sp)
    800017f0:	0880                	addi	s0,sp,80
    800017f2:	8a2a                	mv	s4,a0
  struct proc *p;

  for (p = proc; p < &proc[NPROC]; p++) {
    800017f4:	00011497          	auipc	s1,0x11
    800017f8:	de448493          	addi	s1,s1,-540 # 800125d8 <proc>
    char *pa = kalloc();
    if (pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int)(p - proc));
    800017fc:	8c26                	mv	s8,s1
    800017fe:	000a57b7          	lui	a5,0xa5
    80001802:	fa578793          	addi	a5,a5,-91 # a4fa5 <_entry-0x7ff5b05b>
    80001806:	07b2                	slli	a5,a5,0xc
    80001808:	fa578793          	addi	a5,a5,-91
    8000180c:	4fa50937          	lui	s2,0x4fa50
    80001810:	a4f90913          	addi	s2,s2,-1457 # 4fa4fa4f <_entry-0x305b05b1>
    80001814:	1902                	slli	s2,s2,0x20
    80001816:	993e                	add	s2,s2,a5
    80001818:	040009b7          	lui	s3,0x4000
    8000181c:	19fd                	addi	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    8000181e:	09b2                	slli	s3,s3,0xc
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    80001820:	4b99                	li	s7,6
    80001822:	6b05                	lui	s6,0x1
  for (p = proc; p < &proc[NPROC]; p++) {
    80001824:	00016a97          	auipc	s5,0x16
    80001828:	7b4a8a93          	addi	s5,s5,1972 # 80017fd8 <tickslock>
    char *pa = kalloc();
    8000182c:	b4aff0ef          	jal	80000b76 <kalloc>
    80001830:	862a                	mv	a2,a0
    if (pa == 0)
    80001832:	c121                	beqz	a0,80001872 <proc_mapstacks+0x98>
    uint64 va = KSTACK((int)(p - proc));
    80001834:	418485b3          	sub	a1,s1,s8
    80001838:	858d                	srai	a1,a1,0x3
    8000183a:	032585b3          	mul	a1,a1,s2
    8000183e:	05b6                	slli	a1,a1,0xd
    80001840:	6789                	lui	a5,0x2
    80001842:	9dbd                	addw	a1,a1,a5
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    80001844:	875e                	mv	a4,s7
    80001846:	86da                	mv	a3,s6
    80001848:	40b985b3          	sub	a1,s3,a1
    8000184c:	8552                	mv	a0,s4
    8000184e:	903ff0ef          	jal	80001150 <kvmmap>
  for (p = proc; p < &proc[NPROC]; p++) {
    80001852:	16848493          	addi	s1,s1,360
    80001856:	fd549be3          	bne	s1,s5,8000182c <proc_mapstacks+0x52>
  }
}
    8000185a:	60a6                	ld	ra,72(sp)
    8000185c:	6406                	ld	s0,64(sp)
    8000185e:	74e2                	ld	s1,56(sp)
    80001860:	7942                	ld	s2,48(sp)
    80001862:	79a2                	ld	s3,40(sp)
    80001864:	7a02                	ld	s4,32(sp)
    80001866:	6ae2                	ld	s5,24(sp)
    80001868:	6b42                	ld	s6,16(sp)
    8000186a:	6ba2                	ld	s7,8(sp)
    8000186c:	6c02                	ld	s8,0(sp)
    8000186e:	6161                	addi	sp,sp,80
    80001870:	8082                	ret
      panic("kalloc");
    80001872:	00008517          	auipc	a0,0x8
    80001876:	8de50513          	addi	a0,a0,-1826 # 80009150 <etext+0x150>
    8000187a:	fddfe0ef          	jal	80000856 <panic>

000000008000187e <procinit>:

// initialize the proc table.
void procinit(void) {
    8000187e:	7139                	addi	sp,sp,-64
    80001880:	fc06                	sd	ra,56(sp)
    80001882:	f822                	sd	s0,48(sp)
    80001884:	f426                	sd	s1,40(sp)
    80001886:	f04a                	sd	s2,32(sp)
    80001888:	ec4e                	sd	s3,24(sp)
    8000188a:	e852                	sd	s4,16(sp)
    8000188c:	e456                	sd	s5,8(sp)
    8000188e:	e05a                	sd	s6,0(sp)
    80001890:	0080                	addi	s0,sp,64
  struct proc *p;

  initlock(&pid_lock, "nextpid");
    80001892:	00008597          	auipc	a1,0x8
    80001896:	8c658593          	addi	a1,a1,-1850 # 80009158 <etext+0x158>
    8000189a:	00011517          	auipc	a0,0x11
    8000189e:	90e50513          	addi	a0,a0,-1778 # 800121a8 <pid_lock>
    800018a2:	b2eff0ef          	jal	80000bd0 <initlock>
  initlock(&wait_lock, "wait_lock");
    800018a6:	00008597          	auipc	a1,0x8
    800018aa:	8ba58593          	addi	a1,a1,-1862 # 80009160 <etext+0x160>
    800018ae:	00011517          	auipc	a0,0x11
    800018b2:	91250513          	addi	a0,a0,-1774 # 800121c0 <wait_lock>
    800018b6:	b1aff0ef          	jal	80000bd0 <initlock>
  for (p = proc; p < &proc[NPROC]; p++) {
    800018ba:	00011497          	auipc	s1,0x11
    800018be:	d1e48493          	addi	s1,s1,-738 # 800125d8 <proc>
    initlock(&p->lock, "proc");
    800018c2:	00008b17          	auipc	s6,0x8
    800018c6:	8aeb0b13          	addi	s6,s6,-1874 # 80009170 <etext+0x170>
    p->state = UNUSED;
    p->kstack = KSTACK((int)(p - proc));
    800018ca:	8aa6                	mv	s5,s1
    800018cc:	000a57b7          	lui	a5,0xa5
    800018d0:	fa578793          	addi	a5,a5,-91 # a4fa5 <_entry-0x7ff5b05b>
    800018d4:	07b2                	slli	a5,a5,0xc
    800018d6:	fa578793          	addi	a5,a5,-91
    800018da:	4fa50937          	lui	s2,0x4fa50
    800018de:	a4f90913          	addi	s2,s2,-1457 # 4fa4fa4f <_entry-0x305b05b1>
    800018e2:	1902                	slli	s2,s2,0x20
    800018e4:	993e                	add	s2,s2,a5
    800018e6:	040009b7          	lui	s3,0x4000
    800018ea:	19fd                	addi	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    800018ec:	09b2                	slli	s3,s3,0xc
  for (p = proc; p < &proc[NPROC]; p++) {
    800018ee:	00016a17          	auipc	s4,0x16
    800018f2:	6eaa0a13          	addi	s4,s4,1770 # 80017fd8 <tickslock>
    initlock(&p->lock, "proc");
    800018f6:	85da                	mv	a1,s6
    800018f8:	8526                	mv	a0,s1
    800018fa:	ad6ff0ef          	jal	80000bd0 <initlock>
    p->state = UNUSED;
    800018fe:	0004ac23          	sw	zero,24(s1)
    p->kstack = KSTACK((int)(p - proc));
    80001902:	415487b3          	sub	a5,s1,s5
    80001906:	878d                	srai	a5,a5,0x3
    80001908:	032787b3          	mul	a5,a5,s2
    8000190c:	07b6                	slli	a5,a5,0xd
    8000190e:	6709                	lui	a4,0x2
    80001910:	9fb9                	addw	a5,a5,a4
    80001912:	40f987b3          	sub	a5,s3,a5
    80001916:	e0bc                	sd	a5,64(s1)
  for (p = proc; p < &proc[NPROC]; p++) {
    80001918:	16848493          	addi	s1,s1,360
    8000191c:	fd449de3          	bne	s1,s4,800018f6 <procinit+0x78>
  }
}
    80001920:	70e2                	ld	ra,56(sp)
    80001922:	7442                	ld	s0,48(sp)
    80001924:	74a2                	ld	s1,40(sp)
    80001926:	7902                	ld	s2,32(sp)
    80001928:	69e2                	ld	s3,24(sp)
    8000192a:	6a42                	ld	s4,16(sp)
    8000192c:	6aa2                	ld	s5,8(sp)
    8000192e:	6b02                	ld	s6,0(sp)
    80001930:	6121                	addi	sp,sp,64
    80001932:	8082                	ret

0000000080001934 <cpuid>:

// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int cpuid() {
    80001934:	1141                	addi	sp,sp,-16
    80001936:	e406                	sd	ra,8(sp)
    80001938:	e022                	sd	s0,0(sp)
    8000193a:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    8000193c:	8512                	mv	a0,tp
  int id = r_tp();
  return id;
}
    8000193e:	2501                	sext.w	a0,a0
    80001940:	60a2                	ld	ra,8(sp)
    80001942:	6402                	ld	s0,0(sp)
    80001944:	0141                	addi	sp,sp,16
    80001946:	8082                	ret

0000000080001948 <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu *mycpu(void) {
    80001948:	1141                	addi	sp,sp,-16
    8000194a:	e406                	sd	ra,8(sp)
    8000194c:	e022                	sd	s0,0(sp)
    8000194e:	0800                	addi	s0,sp,16
    80001950:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    80001952:	2781                	sext.w	a5,a5
    80001954:	079e                	slli	a5,a5,0x7
  return c;
}
    80001956:	00011517          	auipc	a0,0x11
    8000195a:	88250513          	addi	a0,a0,-1918 # 800121d8 <cpus>
    8000195e:	953e                	add	a0,a0,a5
    80001960:	60a2                	ld	ra,8(sp)
    80001962:	6402                	ld	s0,0(sp)
    80001964:	0141                	addi	sp,sp,16
    80001966:	8082                	ret

0000000080001968 <myproc>:

// Return the current struct proc *, or zero if none.
struct proc *myproc(void) {
    80001968:	1101                	addi	sp,sp,-32
    8000196a:	ec06                	sd	ra,24(sp)
    8000196c:	e822                	sd	s0,16(sp)
    8000196e:	e426                	sd	s1,8(sp)
    80001970:	1000                	addi	s0,sp,32
  push_off();
    80001972:	aa4ff0ef          	jal	80000c16 <push_off>
    80001976:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    80001978:	2781                	sext.w	a5,a5
    8000197a:	079e                	slli	a5,a5,0x7
    8000197c:	00011717          	auipc	a4,0x11
    80001980:	82c70713          	addi	a4,a4,-2004 # 800121a8 <pid_lock>
    80001984:	97ba                	add	a5,a5,a4
    80001986:	7b9c                	ld	a5,48(a5)
    80001988:	84be                	mv	s1,a5
  pop_off();
    8000198a:	b14ff0ef          	jal	80000c9e <pop_off>
  return p;
}
    8000198e:	8526                	mv	a0,s1
    80001990:	60e2                	ld	ra,24(sp)
    80001992:	6442                	ld	s0,16(sp)
    80001994:	64a2                	ld	s1,8(sp)
    80001996:	6105                	addi	sp,sp,32
    80001998:	8082                	ret

000000008000199a <forkret>:
  release(&p->lock);
}

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void forkret(void) {
    8000199a:	7179                	addi	sp,sp,-48
    8000199c:	f406                	sd	ra,40(sp)
    8000199e:	f022                	sd	s0,32(sp)
    800019a0:	ec26                	sd	s1,24(sp)
    800019a2:	1800                	addi	s0,sp,48
  extern char userret[];
  static int first = 1;
  struct proc *p = myproc();
    800019a4:	fc5ff0ef          	jal	80001968 <myproc>
    800019a8:	84aa                	mv	s1,a0

  // Still holding p->lock from scheduler.
  release(&p->lock);
    800019aa:	b44ff0ef          	jal	80000cee <release>

  if (first) {
    800019ae:	00008797          	auipc	a5,0x8
    800019b2:	6627a783          	lw	a5,1634(a5) # 8000a010 <first.1>
    800019b6:	cf95                	beqz	a5,800019f2 <forkret+0x58>
    // File system initialization must be run in the context of a
    // regular process (e.g., because it calls sleep), and thus cannot
    // be run from main().
    fsinit(ROOTDEV);
    800019b8:	4505                	li	a0,1
    800019ba:	348020ef          	jal	80003d02 <fsinit>

    first = 0;
    800019be:	00008797          	auipc	a5,0x8
    800019c2:	6407a923          	sw	zero,1618(a5) # 8000a010 <first.1>
    // ensure other cores see first=0.
    __sync_synchronize();
    800019c6:	0330000f          	fence	rw,rw

    // We can invoke kexec() now that file system is initialized.
    // Put the return value (argc) of kexec into a0.
    p->trapframe->a0 = kexec("/init", (char *[]){"/init", 0});
    800019ca:	00007797          	auipc	a5,0x7
    800019ce:	7ae78793          	addi	a5,a5,1966 # 80009178 <etext+0x178>
    800019d2:	fcf43823          	sd	a5,-48(s0)
    800019d6:	fc043c23          	sd	zero,-40(s0)
    800019da:	fd040593          	addi	a1,s0,-48
    800019de:	853e                	mv	a0,a5
    800019e0:	413030ef          	jal	800055f2 <kexec>
    800019e4:	6cbc                	ld	a5,88(s1)
    800019e6:	fba8                	sd	a0,112(a5)
    if (p->trapframe->a0 == -1) {
    800019e8:	6cbc                	ld	a5,88(s1)
    800019ea:	7bb8                	ld	a4,112(a5)
    800019ec:	57fd                	li	a5,-1
    800019ee:	02f70d63          	beq	a4,a5,80001a28 <forkret+0x8e>
      panic("exec");
    }
  }

  // return to user space, mimicing usertrap()'s return.
  prepare_return();
    800019f2:	2c9000ef          	jal	800024ba <prepare_return>
  uint64 satp = MAKE_SATP(p->pagetable);
    800019f6:	68a8                	ld	a0,80(s1)
    800019f8:	8131                	srli	a0,a0,0xc
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    800019fa:	04000737          	lui	a4,0x4000
    800019fe:	177d                	addi	a4,a4,-1 # 3ffffff <_entry-0x7c000001>
    80001a00:	0732                	slli	a4,a4,0xc
    80001a02:	00006797          	auipc	a5,0x6
    80001a06:	69a78793          	addi	a5,a5,1690 # 8000809c <userret>
    80001a0a:	00006697          	auipc	a3,0x6
    80001a0e:	5f668693          	addi	a3,a3,1526 # 80008000 <_trampoline>
    80001a12:	8f95                	sub	a5,a5,a3
    80001a14:	97ba                	add	a5,a5,a4
  ((void (*)(uint64))trampoline_userret)(satp);
    80001a16:	577d                	li	a4,-1
    80001a18:	177e                	slli	a4,a4,0x3f
    80001a1a:	8d59                	or	a0,a0,a4
    80001a1c:	9782                	jalr	a5
}
    80001a1e:	70a2                	ld	ra,40(sp)
    80001a20:	7402                	ld	s0,32(sp)
    80001a22:	64e2                	ld	s1,24(sp)
    80001a24:	6145                	addi	sp,sp,48
    80001a26:	8082                	ret
      panic("exec");
    80001a28:	00007517          	auipc	a0,0x7
    80001a2c:	75850513          	addi	a0,a0,1880 # 80009180 <etext+0x180>
    80001a30:	e27fe0ef          	jal	80000856 <panic>

0000000080001a34 <allocpid>:
int allocpid() {
    80001a34:	1101                	addi	sp,sp,-32
    80001a36:	ec06                	sd	ra,24(sp)
    80001a38:	e822                	sd	s0,16(sp)
    80001a3a:	e426                	sd	s1,8(sp)
    80001a3c:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80001a3e:	00010517          	auipc	a0,0x10
    80001a42:	76a50513          	addi	a0,a0,1898 # 800121a8 <pid_lock>
    80001a46:	a14ff0ef          	jal	80000c5a <acquire>
  pid = nextpid;
    80001a4a:	00008797          	auipc	a5,0x8
    80001a4e:	5ca78793          	addi	a5,a5,1482 # 8000a014 <nextpid>
    80001a52:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80001a54:	0014871b          	addiw	a4,s1,1
    80001a58:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001a5a:	00010517          	auipc	a0,0x10
    80001a5e:	74e50513          	addi	a0,a0,1870 # 800121a8 <pid_lock>
    80001a62:	a8cff0ef          	jal	80000cee <release>
}
    80001a66:	8526                	mv	a0,s1
    80001a68:	60e2                	ld	ra,24(sp)
    80001a6a:	6442                	ld	s0,16(sp)
    80001a6c:	64a2                	ld	s1,8(sp)
    80001a6e:	6105                	addi	sp,sp,32
    80001a70:	8082                	ret

0000000080001a72 <proc_pagetable>:
pagetable_t proc_pagetable(struct proc *p) {
    80001a72:	1101                	addi	sp,sp,-32
    80001a74:	ec06                	sd	ra,24(sp)
    80001a76:	e822                	sd	s0,16(sp)
    80001a78:	e426                	sd	s1,8(sp)
    80001a7a:	e04a                	sd	s2,0(sp)
    80001a7c:	1000                	addi	s0,sp,32
    80001a7e:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001a80:	fc2ff0ef          	jal	80001242 <uvmcreate>
    80001a84:	84aa                	mv	s1,a0
  if (pagetable == 0)
    80001a86:	cd05                	beqz	a0,80001abe <proc_pagetable+0x4c>
  if (mappages(pagetable, TRAMPOLINE, PGSIZE, (uint64)trampoline,
    80001a88:	4729                	li	a4,10
    80001a8a:	00006697          	auipc	a3,0x6
    80001a8e:	57668693          	addi	a3,a3,1398 # 80008000 <_trampoline>
    80001a92:	6605                	lui	a2,0x1
    80001a94:	040005b7          	lui	a1,0x4000
    80001a98:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001a9a:	05b2                	slli	a1,a1,0xc
    80001a9c:	dfeff0ef          	jal	8000109a <mappages>
    80001aa0:	02054663          	bltz	a0,80001acc <proc_pagetable+0x5a>
  if (mappages(pagetable, TRAPFRAME, PGSIZE, (uint64)(p->trapframe),
    80001aa4:	4719                	li	a4,6
    80001aa6:	05893683          	ld	a3,88(s2)
    80001aaa:	6605                	lui	a2,0x1
    80001aac:	020005b7          	lui	a1,0x2000
    80001ab0:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001ab2:	05b6                	slli	a1,a1,0xd
    80001ab4:	8526                	mv	a0,s1
    80001ab6:	de4ff0ef          	jal	8000109a <mappages>
    80001aba:	00054f63          	bltz	a0,80001ad8 <proc_pagetable+0x66>
}
    80001abe:	8526                	mv	a0,s1
    80001ac0:	60e2                	ld	ra,24(sp)
    80001ac2:	6442                	ld	s0,16(sp)
    80001ac4:	64a2                	ld	s1,8(sp)
    80001ac6:	6902                	ld	s2,0(sp)
    80001ac8:	6105                	addi	sp,sp,32
    80001aca:	8082                	ret
    uvmfree(pagetable, 0);
    80001acc:	4581                	li	a1,0
    80001ace:	8526                	mv	a0,s1
    80001ad0:	96dff0ef          	jal	8000143c <uvmfree>
    return 0;
    80001ad4:	4481                	li	s1,0
    80001ad6:	b7e5                	j	80001abe <proc_pagetable+0x4c>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001ad8:	4681                	li	a3,0
    80001ada:	4605                	li	a2,1
    80001adc:	040005b7          	lui	a1,0x4000
    80001ae0:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001ae2:	05b2                	slli	a1,a1,0xc
    80001ae4:	8526                	mv	a0,s1
    80001ae6:	f82ff0ef          	jal	80001268 <uvmunmap>
    uvmfree(pagetable, 0);
    80001aea:	4581                	li	a1,0
    80001aec:	8526                	mv	a0,s1
    80001aee:	94fff0ef          	jal	8000143c <uvmfree>
    return 0;
    80001af2:	4481                	li	s1,0
    80001af4:	b7e9                	j	80001abe <proc_pagetable+0x4c>

0000000080001af6 <proc_freepagetable>:
void proc_freepagetable(pagetable_t pagetable, uint64 sz) {
    80001af6:	1101                	addi	sp,sp,-32
    80001af8:	ec06                	sd	ra,24(sp)
    80001afa:	e822                	sd	s0,16(sp)
    80001afc:	e426                	sd	s1,8(sp)
    80001afe:	e04a                	sd	s2,0(sp)
    80001b00:	1000                	addi	s0,sp,32
    80001b02:	84aa                	mv	s1,a0
    80001b04:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001b06:	4681                	li	a3,0
    80001b08:	4605                	li	a2,1
    80001b0a:	040005b7          	lui	a1,0x4000
    80001b0e:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001b10:	05b2                	slli	a1,a1,0xc
    80001b12:	f56ff0ef          	jal	80001268 <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001b16:	4681                	li	a3,0
    80001b18:	4605                	li	a2,1
    80001b1a:	020005b7          	lui	a1,0x2000
    80001b1e:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001b20:	05b6                	slli	a1,a1,0xd
    80001b22:	8526                	mv	a0,s1
    80001b24:	f44ff0ef          	jal	80001268 <uvmunmap>
  uvmfree(pagetable, sz);
    80001b28:	85ca                	mv	a1,s2
    80001b2a:	8526                	mv	a0,s1
    80001b2c:	911ff0ef          	jal	8000143c <uvmfree>
}
    80001b30:	60e2                	ld	ra,24(sp)
    80001b32:	6442                	ld	s0,16(sp)
    80001b34:	64a2                	ld	s1,8(sp)
    80001b36:	6902                	ld	s2,0(sp)
    80001b38:	6105                	addi	sp,sp,32
    80001b3a:	8082                	ret

0000000080001b3c <freeproc>:
static void freeproc(struct proc *p) {
    80001b3c:	1101                	addi	sp,sp,-32
    80001b3e:	ec06                	sd	ra,24(sp)
    80001b40:	e822                	sd	s0,16(sp)
    80001b42:	e426                	sd	s1,8(sp)
    80001b44:	1000                	addi	s0,sp,32
    80001b46:	84aa                	mv	s1,a0
  if (p->trapframe)
    80001b48:	6d28                	ld	a0,88(a0)
    80001b4a:	c119                	beqz	a0,80001b50 <freeproc+0x14>
    kfree((void *)p->trapframe);
    80001b4c:	f43fe0ef          	jal	80000a8e <kfree>
  p->trapframe = 0;
    80001b50:	0404bc23          	sd	zero,88(s1)
  if (p->pagetable)
    80001b54:	68a8                	ld	a0,80(s1)
    80001b56:	c501                	beqz	a0,80001b5e <freeproc+0x22>
    proc_freepagetable(p->pagetable, p->sz);
    80001b58:	64ac                	ld	a1,72(s1)
    80001b5a:	f9dff0ef          	jal	80001af6 <proc_freepagetable>
  p->pagetable = 0;
    80001b5e:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    80001b62:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    80001b66:	0204a823          	sw	zero,48(s1)
  p->parent = 0;
    80001b6a:	0204bc23          	sd	zero,56(s1)
  p->name[0] = 0;
    80001b6e:	14048c23          	sb	zero,344(s1)
  p->chan = 0;
    80001b72:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    80001b76:	0204a423          	sw	zero,40(s1)
  p->xstate = 0;
    80001b7a:	0204a623          	sw	zero,44(s1)
  p->state = UNUSED;
    80001b7e:	0004ac23          	sw	zero,24(s1)
}
    80001b82:	60e2                	ld	ra,24(sp)
    80001b84:	6442                	ld	s0,16(sp)
    80001b86:	64a2                	ld	s1,8(sp)
    80001b88:	6105                	addi	sp,sp,32
    80001b8a:	8082                	ret

0000000080001b8c <allocproc>:
static struct proc *allocproc(void) {
    80001b8c:	1101                	addi	sp,sp,-32
    80001b8e:	ec06                	sd	ra,24(sp)
    80001b90:	e822                	sd	s0,16(sp)
    80001b92:	e426                	sd	s1,8(sp)
    80001b94:	e04a                	sd	s2,0(sp)
    80001b96:	1000                	addi	s0,sp,32
  for (p = proc; p < &proc[NPROC]; p++) {
    80001b98:	00011497          	auipc	s1,0x11
    80001b9c:	a4048493          	addi	s1,s1,-1472 # 800125d8 <proc>
    80001ba0:	00016917          	auipc	s2,0x16
    80001ba4:	43890913          	addi	s2,s2,1080 # 80017fd8 <tickslock>
    acquire(&p->lock);
    80001ba8:	8526                	mv	a0,s1
    80001baa:	8b0ff0ef          	jal	80000c5a <acquire>
    if (p->state == UNUSED) {
    80001bae:	4c9c                	lw	a5,24(s1)
    80001bb0:	cb91                	beqz	a5,80001bc4 <allocproc+0x38>
      release(&p->lock);
    80001bb2:	8526                	mv	a0,s1
    80001bb4:	93aff0ef          	jal	80000cee <release>
  for (p = proc; p < &proc[NPROC]; p++) {
    80001bb8:	16848493          	addi	s1,s1,360
    80001bbc:	ff2496e3          	bne	s1,s2,80001ba8 <allocproc+0x1c>
  return 0;
    80001bc0:	4481                	li	s1,0
    80001bc2:	a089                	j	80001c04 <allocproc+0x78>
  p->pid = allocpid();
    80001bc4:	e71ff0ef          	jal	80001a34 <allocpid>
    80001bc8:	d888                	sw	a0,48(s1)
  p->state = USED;
    80001bca:	4785                	li	a5,1
    80001bcc:	cc9c                	sw	a5,24(s1)
  if ((p->trapframe = (struct trapframe *)kalloc()) == 0) {
    80001bce:	fa9fe0ef          	jal	80000b76 <kalloc>
    80001bd2:	892a                	mv	s2,a0
    80001bd4:	eca8                	sd	a0,88(s1)
    80001bd6:	cd15                	beqz	a0,80001c12 <allocproc+0x86>
  p->pagetable = proc_pagetable(p);
    80001bd8:	8526                	mv	a0,s1
    80001bda:	e99ff0ef          	jal	80001a72 <proc_pagetable>
    80001bde:	892a                	mv	s2,a0
    80001be0:	e8a8                	sd	a0,80(s1)
  if (p->pagetable == 0) {
    80001be2:	c121                	beqz	a0,80001c22 <allocproc+0x96>
  memset(&p->context, 0, sizeof(p->context));
    80001be4:	07000613          	li	a2,112
    80001be8:	4581                	li	a1,0
    80001bea:	06048513          	addi	a0,s1,96
    80001bee:	93cff0ef          	jal	80000d2a <memset>
  p->context.ra = (uint64)forkret;
    80001bf2:	00000797          	auipc	a5,0x0
    80001bf6:	da878793          	addi	a5,a5,-600 # 8000199a <forkret>
    80001bfa:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001bfc:	60bc                	ld	a5,64(s1)
    80001bfe:	6705                	lui	a4,0x1
    80001c00:	97ba                	add	a5,a5,a4
    80001c02:	f4bc                	sd	a5,104(s1)
}
    80001c04:	8526                	mv	a0,s1
    80001c06:	60e2                	ld	ra,24(sp)
    80001c08:	6442                	ld	s0,16(sp)
    80001c0a:	64a2                	ld	s1,8(sp)
    80001c0c:	6902                	ld	s2,0(sp)
    80001c0e:	6105                	addi	sp,sp,32
    80001c10:	8082                	ret
    freeproc(p);
    80001c12:	8526                	mv	a0,s1
    80001c14:	f29ff0ef          	jal	80001b3c <freeproc>
    release(&p->lock);
    80001c18:	8526                	mv	a0,s1
    80001c1a:	8d4ff0ef          	jal	80000cee <release>
    return 0;
    80001c1e:	84ca                	mv	s1,s2
    80001c20:	b7d5                	j	80001c04 <allocproc+0x78>
    freeproc(p);
    80001c22:	8526                	mv	a0,s1
    80001c24:	f19ff0ef          	jal	80001b3c <freeproc>
    release(&p->lock);
    80001c28:	8526                	mv	a0,s1
    80001c2a:	8c4ff0ef          	jal	80000cee <release>
    return 0;
    80001c2e:	84ca                	mv	s1,s2
    80001c30:	bfd1                	j	80001c04 <allocproc+0x78>

0000000080001c32 <userinit>:
void userinit(void) {
    80001c32:	1101                	addi	sp,sp,-32
    80001c34:	ec06                	sd	ra,24(sp)
    80001c36:	e822                	sd	s0,16(sp)
    80001c38:	e426                	sd	s1,8(sp)
    80001c3a:	1000                	addi	s0,sp,32
  p = allocproc();
    80001c3c:	f51ff0ef          	jal	80001b8c <allocproc>
    80001c40:	84aa                	mv	s1,a0
  initproc = p;
    80001c42:	00008797          	auipc	a5,0x8
    80001c46:	3ea7bf23          	sd	a0,1022(a5) # 8000a040 <initproc>
  p->cwd = namei("/");
    80001c4a:	00007517          	auipc	a0,0x7
    80001c4e:	53e50513          	addi	a0,a0,1342 # 80009188 <etext+0x188>
    80001c52:	778020ef          	jal	800043ca <namei>
    80001c56:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    80001c5a:	478d                	li	a5,3
    80001c5c:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001c5e:	8526                	mv	a0,s1
    80001c60:	88eff0ef          	jal	80000cee <release>
}
    80001c64:	60e2                	ld	ra,24(sp)
    80001c66:	6442                	ld	s0,16(sp)
    80001c68:	64a2                	ld	s1,8(sp)
    80001c6a:	6105                	addi	sp,sp,32
    80001c6c:	8082                	ret

0000000080001c6e <growproc>:
int growproc(int n) {
    80001c6e:	1101                	addi	sp,sp,-32
    80001c70:	ec06                	sd	ra,24(sp)
    80001c72:	e822                	sd	s0,16(sp)
    80001c74:	e426                	sd	s1,8(sp)
    80001c76:	e04a                	sd	s2,0(sp)
    80001c78:	1000                	addi	s0,sp,32
    80001c7a:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80001c7c:	cedff0ef          	jal	80001968 <myproc>
    80001c80:	892a                	mv	s2,a0
  sz = p->sz;
    80001c82:	652c                	ld	a1,72(a0)
  if (n > 0) {
    80001c84:	02905963          	blez	s1,80001cb6 <growproc+0x48>
    if (sz + n > TRAPFRAME) {
    80001c88:	00b48633          	add	a2,s1,a1
    80001c8c:	020007b7          	lui	a5,0x2000
    80001c90:	17fd                	addi	a5,a5,-1 # 1ffffff <_entry-0x7e000001>
    80001c92:	07b6                	slli	a5,a5,0xd
    80001c94:	02c7ea63          	bltu	a5,a2,80001cc8 <growproc+0x5a>
    if ((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0) {
    80001c98:	4691                	li	a3,4
    80001c9a:	6928                	ld	a0,80(a0)
    80001c9c:	e9aff0ef          	jal	80001336 <uvmalloc>
    80001ca0:	85aa                	mv	a1,a0
    80001ca2:	c50d                	beqz	a0,80001ccc <growproc+0x5e>
  p->sz = sz;
    80001ca4:	04b93423          	sd	a1,72(s2)
  return 0;
    80001ca8:	4501                	li	a0,0
}
    80001caa:	60e2                	ld	ra,24(sp)
    80001cac:	6442                	ld	s0,16(sp)
    80001cae:	64a2                	ld	s1,8(sp)
    80001cb0:	6902                	ld	s2,0(sp)
    80001cb2:	6105                	addi	sp,sp,32
    80001cb4:	8082                	ret
  } else if (n < 0) {
    80001cb6:	fe04d7e3          	bgez	s1,80001ca4 <growproc+0x36>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001cba:	00b48633          	add	a2,s1,a1
    80001cbe:	6928                	ld	a0,80(a0)
    80001cc0:	e32ff0ef          	jal	800012f2 <uvmdealloc>
    80001cc4:	85aa                	mv	a1,a0
    80001cc6:	bff9                	j	80001ca4 <growproc+0x36>
      return -1;
    80001cc8:	557d                	li	a0,-1
    80001cca:	b7c5                	j	80001caa <growproc+0x3c>
      return -1;
    80001ccc:	557d                	li	a0,-1
    80001cce:	bff1                	j	80001caa <growproc+0x3c>

0000000080001cd0 <kfork>:
int kfork(void) {
    80001cd0:	7139                	addi	sp,sp,-64
    80001cd2:	fc06                	sd	ra,56(sp)
    80001cd4:	f822                	sd	s0,48(sp)
    80001cd6:	f426                	sd	s1,40(sp)
    80001cd8:	e456                	sd	s5,8(sp)
    80001cda:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    80001cdc:	c8dff0ef          	jal	80001968 <myproc>
    80001ce0:	8aaa                	mv	s5,a0
  if ((np = allocproc()) == 0) {
    80001ce2:	eabff0ef          	jal	80001b8c <allocproc>
    80001ce6:	0e050a63          	beqz	a0,80001dda <kfork+0x10a>
    80001cea:	e852                	sd	s4,16(sp)
    80001cec:	8a2a                	mv	s4,a0
  if (uvmcopy(p->pagetable, np->pagetable, p->sz) < 0) {
    80001cee:	048ab603          	ld	a2,72(s5)
    80001cf2:	692c                	ld	a1,80(a0)
    80001cf4:	050ab503          	ld	a0,80(s5)
    80001cf8:	f76ff0ef          	jal	8000146e <uvmcopy>
    80001cfc:	04054863          	bltz	a0,80001d4c <kfork+0x7c>
    80001d00:	f04a                	sd	s2,32(sp)
    80001d02:	ec4e                	sd	s3,24(sp)
  np->sz = p->sz;
    80001d04:	048ab783          	ld	a5,72(s5)
    80001d08:	04fa3423          	sd	a5,72(s4)
  *(np->trapframe) = *(p->trapframe);
    80001d0c:	058ab683          	ld	a3,88(s5)
    80001d10:	87b6                	mv	a5,a3
    80001d12:	058a3703          	ld	a4,88(s4)
    80001d16:	12068693          	addi	a3,a3,288
    80001d1a:	6388                	ld	a0,0(a5)
    80001d1c:	678c                	ld	a1,8(a5)
    80001d1e:	6b90                	ld	a2,16(a5)
    80001d20:	e308                	sd	a0,0(a4)
    80001d22:	e70c                	sd	a1,8(a4)
    80001d24:	eb10                	sd	a2,16(a4)
    80001d26:	6f90                	ld	a2,24(a5)
    80001d28:	ef10                	sd	a2,24(a4)
    80001d2a:	02078793          	addi	a5,a5,32
    80001d2e:	02070713          	addi	a4,a4,32 # 1020 <_entry-0x7fffefe0>
    80001d32:	fed794e3          	bne	a5,a3,80001d1a <kfork+0x4a>
  np->trapframe->a0 = 0;
    80001d36:	058a3783          	ld	a5,88(s4)
    80001d3a:	0607b823          	sd	zero,112(a5)
  for (i = 0; i < NOFILE; i++)
    80001d3e:	0d0a8493          	addi	s1,s5,208
    80001d42:	0d0a0913          	addi	s2,s4,208
    80001d46:	150a8993          	addi	s3,s5,336
    80001d4a:	a831                	j	80001d66 <kfork+0x96>
    freeproc(np);
    80001d4c:	8552                	mv	a0,s4
    80001d4e:	defff0ef          	jal	80001b3c <freeproc>
    release(&np->lock);
    80001d52:	8552                	mv	a0,s4
    80001d54:	f9bfe0ef          	jal	80000cee <release>
    return -1;
    80001d58:	54fd                	li	s1,-1
    80001d5a:	6a42                	ld	s4,16(sp)
    80001d5c:	a885                	j	80001dcc <kfork+0xfc>
  for (i = 0; i < NOFILE; i++)
    80001d5e:	04a1                	addi	s1,s1,8
    80001d60:	0921                	addi	s2,s2,8
    80001d62:	01348963          	beq	s1,s3,80001d74 <kfork+0xa4>
    if (p->ofile[i])
    80001d66:	6088                	ld	a0,0(s1)
    80001d68:	d97d                	beqz	a0,80001d5e <kfork+0x8e>
      np->ofile[i] = filedup(p->ofile[i]);
    80001d6a:	176030ef          	jal	80004ee0 <filedup>
    80001d6e:	00a93023          	sd	a0,0(s2)
    80001d72:	b7f5                	j	80001d5e <kfork+0x8e>
  np->cwd = idup(p->cwd);
    80001d74:	150ab503          	ld	a0,336(s5)
    80001d78:	36d010ef          	jal	800038e4 <idup>
    80001d7c:	14aa3823          	sd	a0,336(s4)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001d80:	4641                	li	a2,16
    80001d82:	158a8593          	addi	a1,s5,344
    80001d86:	158a0513          	addi	a0,s4,344
    80001d8a:	8f4ff0ef          	jal	80000e7e <safestrcpy>
  pid = np->pid;
    80001d8e:	030a2483          	lw	s1,48(s4)
  release(&np->lock);
    80001d92:	8552                	mv	a0,s4
    80001d94:	f5bfe0ef          	jal	80000cee <release>
  acquire(&wait_lock);
    80001d98:	00010517          	auipc	a0,0x10
    80001d9c:	42850513          	addi	a0,a0,1064 # 800121c0 <wait_lock>
    80001da0:	ebbfe0ef          	jal	80000c5a <acquire>
  np->parent = p;
    80001da4:	035a3c23          	sd	s5,56(s4)
  release(&wait_lock);
    80001da8:	00010517          	auipc	a0,0x10
    80001dac:	41850513          	addi	a0,a0,1048 # 800121c0 <wait_lock>
    80001db0:	f3ffe0ef          	jal	80000cee <release>
  acquire(&np->lock);
    80001db4:	8552                	mv	a0,s4
    80001db6:	ea5fe0ef          	jal	80000c5a <acquire>
  np->state = RUNNABLE;
    80001dba:	478d                	li	a5,3
    80001dbc:	00fa2c23          	sw	a5,24(s4)
  release(&np->lock);
    80001dc0:	8552                	mv	a0,s4
    80001dc2:	f2dfe0ef          	jal	80000cee <release>
  return pid;
    80001dc6:	7902                	ld	s2,32(sp)
    80001dc8:	69e2                	ld	s3,24(sp)
    80001dca:	6a42                	ld	s4,16(sp)
}
    80001dcc:	8526                	mv	a0,s1
    80001dce:	70e2                	ld	ra,56(sp)
    80001dd0:	7442                	ld	s0,48(sp)
    80001dd2:	74a2                	ld	s1,40(sp)
    80001dd4:	6aa2                	ld	s5,8(sp)
    80001dd6:	6121                	addi	sp,sp,64
    80001dd8:	8082                	ret
    return -1;
    80001dda:	54fd                	li	s1,-1
    80001ddc:	bfc5                	j	80001dcc <kfork+0xfc>

0000000080001dde <scheduler>:
void scheduler(void) {
    80001dde:	715d                	addi	sp,sp,-80
    80001de0:	e486                	sd	ra,72(sp)
    80001de2:	e0a2                	sd	s0,64(sp)
    80001de4:	fc26                	sd	s1,56(sp)
    80001de6:	f84a                	sd	s2,48(sp)
    80001de8:	f44e                	sd	s3,40(sp)
    80001dea:	f052                	sd	s4,32(sp)
    80001dec:	ec56                	sd	s5,24(sp)
    80001dee:	e85a                	sd	s6,16(sp)
    80001df0:	e45e                	sd	s7,8(sp)
    80001df2:	e062                	sd	s8,0(sp)
    80001df4:	0880                	addi	s0,sp,80
    80001df6:	8792                	mv	a5,tp
  int id = r_tp();
    80001df8:	2781                	sext.w	a5,a5
  c->proc = 0;
    80001dfa:	00779b13          	slli	s6,a5,0x7
    80001dfe:	00010717          	auipc	a4,0x10
    80001e02:	3aa70713          	addi	a4,a4,938 # 800121a8 <pid_lock>
    80001e06:	975a                	add	a4,a4,s6
    80001e08:	02073823          	sd	zero,48(a4)
        swtch(&c->context, &p->context);
    80001e0c:	00010717          	auipc	a4,0x10
    80001e10:	3d470713          	addi	a4,a4,980 # 800121e0 <cpus+0x8>
    80001e14:	9b3a                	add	s6,s6,a4
        p->state = RUNNING;
    80001e16:	4c11                	li	s8,4
        c->proc = p;
    80001e18:	079e                	slli	a5,a5,0x7
    80001e1a:	00010a17          	auipc	s4,0x10
    80001e1e:	38ea0a13          	addi	s4,s4,910 # 800121a8 <pid_lock>
    80001e22:	9a3e                	add	s4,s4,a5
        found = 1;
    80001e24:	4b85                	li	s7,1
    80001e26:	a091                	j	80001e6a <scheduler+0x8c>
      release(&p->lock);
    80001e28:	8526                	mv	a0,s1
    80001e2a:	ec5fe0ef          	jal	80000cee <release>
    for (p = proc; p < &proc[NPROC]; p++) {
    80001e2e:	16848493          	addi	s1,s1,360
    80001e32:	03248863          	beq	s1,s2,80001e62 <scheduler+0x84>
      acquire(&p->lock);
    80001e36:	8526                	mv	a0,s1
    80001e38:	e23fe0ef          	jal	80000c5a <acquire>
      if (p->state == RUNNABLE) {
    80001e3c:	4c9c                	lw	a5,24(s1)
    80001e3e:	ff3795e3          	bne	a5,s3,80001e28 <scheduler+0x4a>
        p->state = RUNNING;
    80001e42:	0184ac23          	sw	s8,24(s1)
        c->proc = p;
    80001e46:	029a3823          	sd	s1,48(s4)
        cslog_run_start(p);
    80001e4a:	8526                	mv	a0,s1
    80001e4c:	5ad040ef          	jal	80006bf8 <cslog_run_start>
        swtch(&c->context, &p->context);
    80001e50:	06048593          	addi	a1,s1,96
    80001e54:	855a                	mv	a0,s6
    80001e56:	5ba000ef          	jal	80002410 <swtch>
        c->proc = 0;
    80001e5a:	020a3823          	sd	zero,48(s4)
        found = 1;
    80001e5e:	8ade                	mv	s5,s7
    80001e60:	b7e1                	j	80001e28 <scheduler+0x4a>
    if (found == 0) {
    80001e62:	000a9463          	bnez	s5,80001e6a <scheduler+0x8c>
      asm volatile("wfi");
    80001e66:	10500073          	wfi
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001e6a:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001e6e:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001e72:	10079073          	csrw	sstatus,a5
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001e76:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80001e7a:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001e7c:	10079073          	csrw	sstatus,a5
    int found = 0;
    80001e80:	4a81                	li	s5,0
    for (p = proc; p < &proc[NPROC]; p++) {
    80001e82:	00010497          	auipc	s1,0x10
    80001e86:	75648493          	addi	s1,s1,1878 # 800125d8 <proc>
      if (p->state == RUNNABLE) {
    80001e8a:	498d                	li	s3,3
    for (p = proc; p < &proc[NPROC]; p++) {
    80001e8c:	00016917          	auipc	s2,0x16
    80001e90:	14c90913          	addi	s2,s2,332 # 80017fd8 <tickslock>
    80001e94:	b74d                	j	80001e36 <scheduler+0x58>

0000000080001e96 <sched>:
void sched(void) {
    80001e96:	7179                	addi	sp,sp,-48
    80001e98:	f406                	sd	ra,40(sp)
    80001e9a:	f022                	sd	s0,32(sp)
    80001e9c:	ec26                	sd	s1,24(sp)
    80001e9e:	e84a                	sd	s2,16(sp)
    80001ea0:	e44e                	sd	s3,8(sp)
    80001ea2:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80001ea4:	ac5ff0ef          	jal	80001968 <myproc>
    80001ea8:	84aa                	mv	s1,a0
  if (!holding(&p->lock))
    80001eaa:	d41fe0ef          	jal	80000bea <holding>
    80001eae:	c935                	beqz	a0,80001f22 <sched+0x8c>
  asm volatile("mv %0, tp" : "=r" (x) );
    80001eb0:	8792                	mv	a5,tp
  if (mycpu()->noff != 1)
    80001eb2:	2781                	sext.w	a5,a5
    80001eb4:	079e                	slli	a5,a5,0x7
    80001eb6:	00010717          	auipc	a4,0x10
    80001eba:	2f270713          	addi	a4,a4,754 # 800121a8 <pid_lock>
    80001ebe:	97ba                	add	a5,a5,a4
    80001ec0:	0a87a703          	lw	a4,168(a5)
    80001ec4:	4785                	li	a5,1
    80001ec6:	06f71463          	bne	a4,a5,80001f2e <sched+0x98>
  if (p->state == RUNNING)
    80001eca:	4c98                	lw	a4,24(s1)
    80001ecc:	4791                	li	a5,4
    80001ece:	06f70663          	beq	a4,a5,80001f3a <sched+0xa4>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001ed2:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80001ed6:	8b89                	andi	a5,a5,2
  if (intr_get())
    80001ed8:	e7bd                	bnez	a5,80001f46 <sched+0xb0>
  asm volatile("mv %0, tp" : "=r" (x) );
    80001eda:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    80001edc:	00010917          	auipc	s2,0x10
    80001ee0:	2cc90913          	addi	s2,s2,716 # 800121a8 <pid_lock>
    80001ee4:	2781                	sext.w	a5,a5
    80001ee6:	079e                	slli	a5,a5,0x7
    80001ee8:	97ca                	add	a5,a5,s2
    80001eea:	0ac7a983          	lw	s3,172(a5)
    80001eee:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    80001ef0:	2781                	sext.w	a5,a5
    80001ef2:	079e                	slli	a5,a5,0x7
    80001ef4:	07a1                	addi	a5,a5,8
    80001ef6:	00010597          	auipc	a1,0x10
    80001efa:	2e258593          	addi	a1,a1,738 # 800121d8 <cpus>
    80001efe:	95be                	add	a1,a1,a5
    80001f00:	06048513          	addi	a0,s1,96
    80001f04:	50c000ef          	jal	80002410 <swtch>
    80001f08:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    80001f0a:	2781                	sext.w	a5,a5
    80001f0c:	079e                	slli	a5,a5,0x7
    80001f0e:	993e                	add	s2,s2,a5
    80001f10:	0b392623          	sw	s3,172(s2)
}
    80001f14:	70a2                	ld	ra,40(sp)
    80001f16:	7402                	ld	s0,32(sp)
    80001f18:	64e2                	ld	s1,24(sp)
    80001f1a:	6942                	ld	s2,16(sp)
    80001f1c:	69a2                	ld	s3,8(sp)
    80001f1e:	6145                	addi	sp,sp,48
    80001f20:	8082                	ret
    panic("sched p->lock");
    80001f22:	00007517          	auipc	a0,0x7
    80001f26:	26e50513          	addi	a0,a0,622 # 80009190 <etext+0x190>
    80001f2a:	92dfe0ef          	jal	80000856 <panic>
    panic("sched locks");
    80001f2e:	00007517          	auipc	a0,0x7
    80001f32:	27250513          	addi	a0,a0,626 # 800091a0 <etext+0x1a0>
    80001f36:	921fe0ef          	jal	80000856 <panic>
    panic("sched RUNNING");
    80001f3a:	00007517          	auipc	a0,0x7
    80001f3e:	27650513          	addi	a0,a0,630 # 800091b0 <etext+0x1b0>
    80001f42:	915fe0ef          	jal	80000856 <panic>
    panic("sched interruptible");
    80001f46:	00007517          	auipc	a0,0x7
    80001f4a:	27a50513          	addi	a0,a0,634 # 800091c0 <etext+0x1c0>
    80001f4e:	909fe0ef          	jal	80000856 <panic>

0000000080001f52 <yield>:
void yield(void) {
    80001f52:	1101                	addi	sp,sp,-32
    80001f54:	ec06                	sd	ra,24(sp)
    80001f56:	e822                	sd	s0,16(sp)
    80001f58:	e426                	sd	s1,8(sp)
    80001f5a:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80001f5c:	a0dff0ef          	jal	80001968 <myproc>
    80001f60:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80001f62:	cf9fe0ef          	jal	80000c5a <acquire>
  p->state = RUNNABLE;
    80001f66:	478d                	li	a5,3
    80001f68:	cc9c                	sw	a5,24(s1)
  sched();
    80001f6a:	f2dff0ef          	jal	80001e96 <sched>
  release(&p->lock);
    80001f6e:	8526                	mv	a0,s1
    80001f70:	d7ffe0ef          	jal	80000cee <release>
}
    80001f74:	60e2                	ld	ra,24(sp)
    80001f76:	6442                	ld	s0,16(sp)
    80001f78:	64a2                	ld	s1,8(sp)
    80001f7a:	6105                	addi	sp,sp,32
    80001f7c:	8082                	ret

0000000080001f7e <sleep>:

// Sleep on channel chan, releasing condition lock lk.
// Re-acquires lk when awakened.
void sleep(void *chan, struct spinlock *lk) {
    80001f7e:	7179                	addi	sp,sp,-48
    80001f80:	f406                	sd	ra,40(sp)
    80001f82:	f022                	sd	s0,32(sp)
    80001f84:	ec26                	sd	s1,24(sp)
    80001f86:	e84a                	sd	s2,16(sp)
    80001f88:	e44e                	sd	s3,8(sp)
    80001f8a:	1800                	addi	s0,sp,48
    80001f8c:	89aa                	mv	s3,a0
    80001f8e:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80001f90:	9d9ff0ef          	jal	80001968 <myproc>
    80001f94:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock); // DOC: sleeplock1
    80001f96:	cc5fe0ef          	jal	80000c5a <acquire>
  release(lk);
    80001f9a:	854a                	mv	a0,s2
    80001f9c:	d53fe0ef          	jal	80000cee <release>

  // Go to sleep.
  p->chan = chan;
    80001fa0:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    80001fa4:	4789                	li	a5,2
    80001fa6:	cc9c                	sw	a5,24(s1)

  sched();
    80001fa8:	eefff0ef          	jal	80001e96 <sched>

  // Tidy up.
  p->chan = 0;
    80001fac:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    80001fb0:	8526                	mv	a0,s1
    80001fb2:	d3dfe0ef          	jal	80000cee <release>
  acquire(lk);
    80001fb6:	854a                	mv	a0,s2
    80001fb8:	ca3fe0ef          	jal	80000c5a <acquire>
}
    80001fbc:	70a2                	ld	ra,40(sp)
    80001fbe:	7402                	ld	s0,32(sp)
    80001fc0:	64e2                	ld	s1,24(sp)
    80001fc2:	6942                	ld	s2,16(sp)
    80001fc4:	69a2                	ld	s3,8(sp)
    80001fc6:	6145                	addi	sp,sp,48
    80001fc8:	8082                	ret

0000000080001fca <wakeup>:

// Wake up all processes sleeping on channel chan.
// Caller should hold the condition lock.
void wakeup(void *chan) {
    80001fca:	7139                	addi	sp,sp,-64
    80001fcc:	fc06                	sd	ra,56(sp)
    80001fce:	f822                	sd	s0,48(sp)
    80001fd0:	f426                	sd	s1,40(sp)
    80001fd2:	f04a                	sd	s2,32(sp)
    80001fd4:	ec4e                	sd	s3,24(sp)
    80001fd6:	e852                	sd	s4,16(sp)
    80001fd8:	e456                	sd	s5,8(sp)
    80001fda:	0080                	addi	s0,sp,64
    80001fdc:	8a2a                	mv	s4,a0
  struct proc *p;

  for (p = proc; p < &proc[NPROC]; p++) {
    80001fde:	00010497          	auipc	s1,0x10
    80001fe2:	5fa48493          	addi	s1,s1,1530 # 800125d8 <proc>
    if (p != myproc()) {
      acquire(&p->lock);
      if (p->state == SLEEPING && p->chan == chan) {
    80001fe6:	4989                	li	s3,2
        p->state = RUNNABLE;
    80001fe8:	4a8d                	li	s5,3
  for (p = proc; p < &proc[NPROC]; p++) {
    80001fea:	00016917          	auipc	s2,0x16
    80001fee:	fee90913          	addi	s2,s2,-18 # 80017fd8 <tickslock>
    80001ff2:	a801                	j	80002002 <wakeup+0x38>
      }
      release(&p->lock);
    80001ff4:	8526                	mv	a0,s1
    80001ff6:	cf9fe0ef          	jal	80000cee <release>
  for (p = proc; p < &proc[NPROC]; p++) {
    80001ffa:	16848493          	addi	s1,s1,360
    80001ffe:	03248263          	beq	s1,s2,80002022 <wakeup+0x58>
    if (p != myproc()) {
    80002002:	967ff0ef          	jal	80001968 <myproc>
    80002006:	fe950ae3          	beq	a0,s1,80001ffa <wakeup+0x30>
      acquire(&p->lock);
    8000200a:	8526                	mv	a0,s1
    8000200c:	c4ffe0ef          	jal	80000c5a <acquire>
      if (p->state == SLEEPING && p->chan == chan) {
    80002010:	4c9c                	lw	a5,24(s1)
    80002012:	ff3791e3          	bne	a5,s3,80001ff4 <wakeup+0x2a>
    80002016:	709c                	ld	a5,32(s1)
    80002018:	fd479ee3          	bne	a5,s4,80001ff4 <wakeup+0x2a>
        p->state = RUNNABLE;
    8000201c:	0154ac23          	sw	s5,24(s1)
    80002020:	bfd1                	j	80001ff4 <wakeup+0x2a>
    }
  }
}
    80002022:	70e2                	ld	ra,56(sp)
    80002024:	7442                	ld	s0,48(sp)
    80002026:	74a2                	ld	s1,40(sp)
    80002028:	7902                	ld	s2,32(sp)
    8000202a:	69e2                	ld	s3,24(sp)
    8000202c:	6a42                	ld	s4,16(sp)
    8000202e:	6aa2                	ld	s5,8(sp)
    80002030:	6121                	addi	sp,sp,64
    80002032:	8082                	ret

0000000080002034 <reparent>:
void reparent(struct proc *p) {
    80002034:	7179                	addi	sp,sp,-48
    80002036:	f406                	sd	ra,40(sp)
    80002038:	f022                	sd	s0,32(sp)
    8000203a:	ec26                	sd	s1,24(sp)
    8000203c:	e84a                	sd	s2,16(sp)
    8000203e:	e44e                	sd	s3,8(sp)
    80002040:	e052                	sd	s4,0(sp)
    80002042:	1800                	addi	s0,sp,48
    80002044:	892a                	mv	s2,a0
  for (pp = proc; pp < &proc[NPROC]; pp++) {
    80002046:	00010497          	auipc	s1,0x10
    8000204a:	59248493          	addi	s1,s1,1426 # 800125d8 <proc>
      pp->parent = initproc;
    8000204e:	00008a17          	auipc	s4,0x8
    80002052:	ff2a0a13          	addi	s4,s4,-14 # 8000a040 <initproc>
  for (pp = proc; pp < &proc[NPROC]; pp++) {
    80002056:	00016997          	auipc	s3,0x16
    8000205a:	f8298993          	addi	s3,s3,-126 # 80017fd8 <tickslock>
    8000205e:	a029                	j	80002068 <reparent+0x34>
    80002060:	16848493          	addi	s1,s1,360
    80002064:	01348b63          	beq	s1,s3,8000207a <reparent+0x46>
    if (pp->parent == p) {
    80002068:	7c9c                	ld	a5,56(s1)
    8000206a:	ff279be3          	bne	a5,s2,80002060 <reparent+0x2c>
      pp->parent = initproc;
    8000206e:	000a3503          	ld	a0,0(s4)
    80002072:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    80002074:	f57ff0ef          	jal	80001fca <wakeup>
    80002078:	b7e5                	j	80002060 <reparent+0x2c>
}
    8000207a:	70a2                	ld	ra,40(sp)
    8000207c:	7402                	ld	s0,32(sp)
    8000207e:	64e2                	ld	s1,24(sp)
    80002080:	6942                	ld	s2,16(sp)
    80002082:	69a2                	ld	s3,8(sp)
    80002084:	6a02                	ld	s4,0(sp)
    80002086:	6145                	addi	sp,sp,48
    80002088:	8082                	ret

000000008000208a <kexit>:
void kexit(int status) {
    8000208a:	7179                	addi	sp,sp,-48
    8000208c:	f406                	sd	ra,40(sp)
    8000208e:	f022                	sd	s0,32(sp)
    80002090:	ec26                	sd	s1,24(sp)
    80002092:	e84a                	sd	s2,16(sp)
    80002094:	e44e                	sd	s3,8(sp)
    80002096:	e052                	sd	s4,0(sp)
    80002098:	1800                	addi	s0,sp,48
    8000209a:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    8000209c:	8cdff0ef          	jal	80001968 <myproc>
    800020a0:	89aa                	mv	s3,a0
  if (p == initproc)
    800020a2:	00008797          	auipc	a5,0x8
    800020a6:	f9e7b783          	ld	a5,-98(a5) # 8000a040 <initproc>
    800020aa:	0d050493          	addi	s1,a0,208
    800020ae:	15050913          	addi	s2,a0,336
    800020b2:	00a79b63          	bne	a5,a0,800020c8 <kexit+0x3e>
    panic("init exiting");
    800020b6:	00007517          	auipc	a0,0x7
    800020ba:	12250513          	addi	a0,a0,290 # 800091d8 <etext+0x1d8>
    800020be:	f98fe0ef          	jal	80000856 <panic>
  for (int fd = 0; fd < NOFILE; fd++) {
    800020c2:	04a1                	addi	s1,s1,8
    800020c4:	01248963          	beq	s1,s2,800020d6 <kexit+0x4c>
    if (p->ofile[fd]) {
    800020c8:	6088                	ld	a0,0(s1)
    800020ca:	dd65                	beqz	a0,800020c2 <kexit+0x38>
      fileclose(f);
    800020cc:	675020ef          	jal	80004f40 <fileclose>
      p->ofile[fd] = 0;
    800020d0:	0004b023          	sd	zero,0(s1)
    800020d4:	b7fd                	j	800020c2 <kexit+0x38>
  begin_op();
    800020d6:	742020ef          	jal	80004818 <begin_op>
  iput(p->cwd);
    800020da:	1509b503          	ld	a0,336(s3)
    800020de:	26f010ef          	jal	80003b4c <iput>
  end_op();
    800020e2:	057020ef          	jal	80004938 <end_op>
  p->cwd = 0;
    800020e6:	1409b823          	sd	zero,336(s3)
  acquire(&wait_lock);
    800020ea:	00010517          	auipc	a0,0x10
    800020ee:	0d650513          	addi	a0,a0,214 # 800121c0 <wait_lock>
    800020f2:	b69fe0ef          	jal	80000c5a <acquire>
  reparent(p);
    800020f6:	854e                	mv	a0,s3
    800020f8:	f3dff0ef          	jal	80002034 <reparent>
  wakeup(p->parent);
    800020fc:	0389b503          	ld	a0,56(s3)
    80002100:	ecbff0ef          	jal	80001fca <wakeup>
  acquire(&p->lock);
    80002104:	854e                	mv	a0,s3
    80002106:	b55fe0ef          	jal	80000c5a <acquire>
  p->xstate = status;
    8000210a:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    8000210e:	4795                	li	a5,5
    80002110:	00f9ac23          	sw	a5,24(s3)
  release(&wait_lock);
    80002114:	00010517          	auipc	a0,0x10
    80002118:	0ac50513          	addi	a0,a0,172 # 800121c0 <wait_lock>
    8000211c:	bd3fe0ef          	jal	80000cee <release>
  sched();
    80002120:	d77ff0ef          	jal	80001e96 <sched>
  panic("zombie exit");
    80002124:	00007517          	auipc	a0,0x7
    80002128:	0c450513          	addi	a0,a0,196 # 800091e8 <etext+0x1e8>
    8000212c:	f2afe0ef          	jal	80000856 <panic>

0000000080002130 <kkill>:

// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int kkill(int pid) {
    80002130:	7179                	addi	sp,sp,-48
    80002132:	f406                	sd	ra,40(sp)
    80002134:	f022                	sd	s0,32(sp)
    80002136:	ec26                	sd	s1,24(sp)
    80002138:	e84a                	sd	s2,16(sp)
    8000213a:	e44e                	sd	s3,8(sp)
    8000213c:	1800                	addi	s0,sp,48
    8000213e:	892a                	mv	s2,a0
  struct proc *p;

  for (p = proc; p < &proc[NPROC]; p++) {
    80002140:	00010497          	auipc	s1,0x10
    80002144:	49848493          	addi	s1,s1,1176 # 800125d8 <proc>
    80002148:	00016997          	auipc	s3,0x16
    8000214c:	e9098993          	addi	s3,s3,-368 # 80017fd8 <tickslock>
    acquire(&p->lock);
    80002150:	8526                	mv	a0,s1
    80002152:	b09fe0ef          	jal	80000c5a <acquire>
    if (p->pid == pid) {
    80002156:	589c                	lw	a5,48(s1)
    80002158:	01278b63          	beq	a5,s2,8000216e <kkill+0x3e>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    8000215c:	8526                	mv	a0,s1
    8000215e:	b91fe0ef          	jal	80000cee <release>
  for (p = proc; p < &proc[NPROC]; p++) {
    80002162:	16848493          	addi	s1,s1,360
    80002166:	ff3495e3          	bne	s1,s3,80002150 <kkill+0x20>
  }
  return -1;
    8000216a:	557d                	li	a0,-1
    8000216c:	a819                	j	80002182 <kkill+0x52>
      p->killed = 1;
    8000216e:	4785                	li	a5,1
    80002170:	d49c                	sw	a5,40(s1)
      if (p->state == SLEEPING) {
    80002172:	4c98                	lw	a4,24(s1)
    80002174:	4789                	li	a5,2
    80002176:	00f70d63          	beq	a4,a5,80002190 <kkill+0x60>
      release(&p->lock);
    8000217a:	8526                	mv	a0,s1
    8000217c:	b73fe0ef          	jal	80000cee <release>
      return 0;
    80002180:	4501                	li	a0,0
}
    80002182:	70a2                	ld	ra,40(sp)
    80002184:	7402                	ld	s0,32(sp)
    80002186:	64e2                	ld	s1,24(sp)
    80002188:	6942                	ld	s2,16(sp)
    8000218a:	69a2                	ld	s3,8(sp)
    8000218c:	6145                	addi	sp,sp,48
    8000218e:	8082                	ret
        p->state = RUNNABLE;
    80002190:	478d                	li	a5,3
    80002192:	cc9c                	sw	a5,24(s1)
    80002194:	b7dd                	j	8000217a <kkill+0x4a>

0000000080002196 <setkilled>:

void setkilled(struct proc *p) {
    80002196:	1101                	addi	sp,sp,-32
    80002198:	ec06                	sd	ra,24(sp)
    8000219a:	e822                	sd	s0,16(sp)
    8000219c:	e426                	sd	s1,8(sp)
    8000219e:	1000                	addi	s0,sp,32
    800021a0:	84aa                	mv	s1,a0
  acquire(&p->lock);
    800021a2:	ab9fe0ef          	jal	80000c5a <acquire>
  p->killed = 1;
    800021a6:	4785                	li	a5,1
    800021a8:	d49c                	sw	a5,40(s1)
  release(&p->lock);
    800021aa:	8526                	mv	a0,s1
    800021ac:	b43fe0ef          	jal	80000cee <release>
}
    800021b0:	60e2                	ld	ra,24(sp)
    800021b2:	6442                	ld	s0,16(sp)
    800021b4:	64a2                	ld	s1,8(sp)
    800021b6:	6105                	addi	sp,sp,32
    800021b8:	8082                	ret

00000000800021ba <killed>:

int killed(struct proc *p) {
    800021ba:	1101                	addi	sp,sp,-32
    800021bc:	ec06                	sd	ra,24(sp)
    800021be:	e822                	sd	s0,16(sp)
    800021c0:	e426                	sd	s1,8(sp)
    800021c2:	e04a                	sd	s2,0(sp)
    800021c4:	1000                	addi	s0,sp,32
    800021c6:	84aa                	mv	s1,a0
  int k;

  acquire(&p->lock);
    800021c8:	a93fe0ef          	jal	80000c5a <acquire>
  k = p->killed;
    800021cc:	549c                	lw	a5,40(s1)
    800021ce:	893e                	mv	s2,a5
  release(&p->lock);
    800021d0:	8526                	mv	a0,s1
    800021d2:	b1dfe0ef          	jal	80000cee <release>
  return k;
}
    800021d6:	854a                	mv	a0,s2
    800021d8:	60e2                	ld	ra,24(sp)
    800021da:	6442                	ld	s0,16(sp)
    800021dc:	64a2                	ld	s1,8(sp)
    800021de:	6902                	ld	s2,0(sp)
    800021e0:	6105                	addi	sp,sp,32
    800021e2:	8082                	ret

00000000800021e4 <kwait>:
int kwait(uint64 addr) {
    800021e4:	715d                	addi	sp,sp,-80
    800021e6:	e486                	sd	ra,72(sp)
    800021e8:	e0a2                	sd	s0,64(sp)
    800021ea:	fc26                	sd	s1,56(sp)
    800021ec:	f84a                	sd	s2,48(sp)
    800021ee:	f44e                	sd	s3,40(sp)
    800021f0:	f052                	sd	s4,32(sp)
    800021f2:	ec56                	sd	s5,24(sp)
    800021f4:	e85a                	sd	s6,16(sp)
    800021f6:	e45e                	sd	s7,8(sp)
    800021f8:	0880                	addi	s0,sp,80
    800021fa:	8baa                	mv	s7,a0
  struct proc *p = myproc();
    800021fc:	f6cff0ef          	jal	80001968 <myproc>
    80002200:	892a                	mv	s2,a0
  acquire(&wait_lock);
    80002202:	00010517          	auipc	a0,0x10
    80002206:	fbe50513          	addi	a0,a0,-66 # 800121c0 <wait_lock>
    8000220a:	a51fe0ef          	jal	80000c5a <acquire>
        if (pp->state == ZOMBIE) {
    8000220e:	4a15                	li	s4,5
        havekids = 1;
    80002210:	4a85                	li	s5,1
    for (pp = proc; pp < &proc[NPROC]; pp++) {
    80002212:	00016997          	auipc	s3,0x16
    80002216:	dc698993          	addi	s3,s3,-570 # 80017fd8 <tickslock>
    sleep(p, &wait_lock); // DOC: wait-sleep
    8000221a:	00010b17          	auipc	s6,0x10
    8000221e:	fa6b0b13          	addi	s6,s6,-90 # 800121c0 <wait_lock>
    80002222:	a869                	j	800022bc <kwait+0xd8>
          pid = pp->pid;
    80002224:	0304a983          	lw	s3,48(s1)
          if (addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    80002228:	000b8c63          	beqz	s7,80002240 <kwait+0x5c>
    8000222c:	4691                	li	a3,4
    8000222e:	02c48613          	addi	a2,s1,44
    80002232:	85de                	mv	a1,s7
    80002234:	05093503          	ld	a0,80(s2)
    80002238:	c56ff0ef          	jal	8000168e <copyout>
    8000223c:	02054a63          	bltz	a0,80002270 <kwait+0x8c>
          freeproc(pp);
    80002240:	8526                	mv	a0,s1
    80002242:	8fbff0ef          	jal	80001b3c <freeproc>
          release(&pp->lock);
    80002246:	8526                	mv	a0,s1
    80002248:	aa7fe0ef          	jal	80000cee <release>
          release(&wait_lock);
    8000224c:	00010517          	auipc	a0,0x10
    80002250:	f7450513          	addi	a0,a0,-140 # 800121c0 <wait_lock>
    80002254:	a9bfe0ef          	jal	80000cee <release>
}
    80002258:	854e                	mv	a0,s3
    8000225a:	60a6                	ld	ra,72(sp)
    8000225c:	6406                	ld	s0,64(sp)
    8000225e:	74e2                	ld	s1,56(sp)
    80002260:	7942                	ld	s2,48(sp)
    80002262:	79a2                	ld	s3,40(sp)
    80002264:	7a02                	ld	s4,32(sp)
    80002266:	6ae2                	ld	s5,24(sp)
    80002268:	6b42                	ld	s6,16(sp)
    8000226a:	6ba2                	ld	s7,8(sp)
    8000226c:	6161                	addi	sp,sp,80
    8000226e:	8082                	ret
            release(&pp->lock);
    80002270:	8526                	mv	a0,s1
    80002272:	a7dfe0ef          	jal	80000cee <release>
            release(&wait_lock);
    80002276:	00010517          	auipc	a0,0x10
    8000227a:	f4a50513          	addi	a0,a0,-182 # 800121c0 <wait_lock>
    8000227e:	a71fe0ef          	jal	80000cee <release>
            return -1;
    80002282:	59fd                	li	s3,-1
    80002284:	bfd1                	j	80002258 <kwait+0x74>
    for (pp = proc; pp < &proc[NPROC]; pp++) {
    80002286:	16848493          	addi	s1,s1,360
    8000228a:	03348063          	beq	s1,s3,800022aa <kwait+0xc6>
      if (pp->parent == p) {
    8000228e:	7c9c                	ld	a5,56(s1)
    80002290:	ff279be3          	bne	a5,s2,80002286 <kwait+0xa2>
        acquire(&pp->lock);
    80002294:	8526                	mv	a0,s1
    80002296:	9c5fe0ef          	jal	80000c5a <acquire>
        if (pp->state == ZOMBIE) {
    8000229a:	4c9c                	lw	a5,24(s1)
    8000229c:	f94784e3          	beq	a5,s4,80002224 <kwait+0x40>
        release(&pp->lock);
    800022a0:	8526                	mv	a0,s1
    800022a2:	a4dfe0ef          	jal	80000cee <release>
        havekids = 1;
    800022a6:	8756                	mv	a4,s5
    800022a8:	bff9                	j	80002286 <kwait+0xa2>
    if (!havekids || killed(p)) {
    800022aa:	cf19                	beqz	a4,800022c8 <kwait+0xe4>
    800022ac:	854a                	mv	a0,s2
    800022ae:	f0dff0ef          	jal	800021ba <killed>
    800022b2:	e919                	bnez	a0,800022c8 <kwait+0xe4>
    sleep(p, &wait_lock); // DOC: wait-sleep
    800022b4:	85da                	mv	a1,s6
    800022b6:	854a                	mv	a0,s2
    800022b8:	cc7ff0ef          	jal	80001f7e <sleep>
    havekids = 0;
    800022bc:	4701                	li	a4,0
    for (pp = proc; pp < &proc[NPROC]; pp++) {
    800022be:	00010497          	auipc	s1,0x10
    800022c2:	31a48493          	addi	s1,s1,794 # 800125d8 <proc>
    800022c6:	b7e1                	j	8000228e <kwait+0xaa>
      release(&wait_lock);
    800022c8:	00010517          	auipc	a0,0x10
    800022cc:	ef850513          	addi	a0,a0,-264 # 800121c0 <wait_lock>
    800022d0:	a1ffe0ef          	jal	80000cee <release>
      return -1;
    800022d4:	59fd                	li	s3,-1
    800022d6:	b749                	j	80002258 <kwait+0x74>

00000000800022d8 <either_copyout>:

// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int either_copyout(int user_dst, uint64 dst, void *src, uint64 len) {
    800022d8:	7179                	addi	sp,sp,-48
    800022da:	f406                	sd	ra,40(sp)
    800022dc:	f022                	sd	s0,32(sp)
    800022de:	ec26                	sd	s1,24(sp)
    800022e0:	e84a                	sd	s2,16(sp)
    800022e2:	e44e                	sd	s3,8(sp)
    800022e4:	e052                	sd	s4,0(sp)
    800022e6:	1800                	addi	s0,sp,48
    800022e8:	84aa                	mv	s1,a0
    800022ea:	8a2e                	mv	s4,a1
    800022ec:	89b2                	mv	s3,a2
    800022ee:	8936                	mv	s2,a3
  struct proc *p = myproc();
    800022f0:	e78ff0ef          	jal	80001968 <myproc>
  if (user_dst) {
    800022f4:	cc99                	beqz	s1,80002312 <either_copyout+0x3a>
    return copyout(p->pagetable, dst, src, len);
    800022f6:	86ca                	mv	a3,s2
    800022f8:	864e                	mv	a2,s3
    800022fa:	85d2                	mv	a1,s4
    800022fc:	6928                	ld	a0,80(a0)
    800022fe:	b90ff0ef          	jal	8000168e <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    80002302:	70a2                	ld	ra,40(sp)
    80002304:	7402                	ld	s0,32(sp)
    80002306:	64e2                	ld	s1,24(sp)
    80002308:	6942                	ld	s2,16(sp)
    8000230a:	69a2                	ld	s3,8(sp)
    8000230c:	6a02                	ld	s4,0(sp)
    8000230e:	6145                	addi	sp,sp,48
    80002310:	8082                	ret
    memmove((char *)dst, src, len);
    80002312:	0009061b          	sext.w	a2,s2
    80002316:	85ce                	mv	a1,s3
    80002318:	8552                	mv	a0,s4
    8000231a:	a71fe0ef          	jal	80000d8a <memmove>
    return 0;
    8000231e:	8526                	mv	a0,s1
    80002320:	b7cd                	j	80002302 <either_copyout+0x2a>

0000000080002322 <either_copyin>:

// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int either_copyin(void *dst, int user_src, uint64 src, uint64 len) {
    80002322:	7179                	addi	sp,sp,-48
    80002324:	f406                	sd	ra,40(sp)
    80002326:	f022                	sd	s0,32(sp)
    80002328:	ec26                	sd	s1,24(sp)
    8000232a:	e84a                	sd	s2,16(sp)
    8000232c:	e44e                	sd	s3,8(sp)
    8000232e:	e052                	sd	s4,0(sp)
    80002330:	1800                	addi	s0,sp,48
    80002332:	8a2a                	mv	s4,a0
    80002334:	84ae                	mv	s1,a1
    80002336:	89b2                	mv	s3,a2
    80002338:	8936                	mv	s2,a3
  struct proc *p = myproc();
    8000233a:	e2eff0ef          	jal	80001968 <myproc>
  if (user_src) {
    8000233e:	cc99                	beqz	s1,8000235c <either_copyin+0x3a>
    return copyin(p->pagetable, dst, src, len);
    80002340:	86ca                	mv	a3,s2
    80002342:	864e                	mv	a2,s3
    80002344:	85d2                	mv	a1,s4
    80002346:	6928                	ld	a0,80(a0)
    80002348:	c04ff0ef          	jal	8000174c <copyin>
  } else {
    memmove(dst, (char *)src, len);
    return 0;
  }
}
    8000234c:	70a2                	ld	ra,40(sp)
    8000234e:	7402                	ld	s0,32(sp)
    80002350:	64e2                	ld	s1,24(sp)
    80002352:	6942                	ld	s2,16(sp)
    80002354:	69a2                	ld	s3,8(sp)
    80002356:	6a02                	ld	s4,0(sp)
    80002358:	6145                	addi	sp,sp,48
    8000235a:	8082                	ret
    memmove(dst, (char *)src, len);
    8000235c:	0009061b          	sext.w	a2,s2
    80002360:	85ce                	mv	a1,s3
    80002362:	8552                	mv	a0,s4
    80002364:	a27fe0ef          	jal	80000d8a <memmove>
    return 0;
    80002368:	8526                	mv	a0,s1
    8000236a:	b7cd                	j	8000234c <either_copyin+0x2a>

000000008000236c <procdump>:

// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void procdump(void) {
    8000236c:	715d                	addi	sp,sp,-80
    8000236e:	e486                	sd	ra,72(sp)
    80002370:	e0a2                	sd	s0,64(sp)
    80002372:	fc26                	sd	s1,56(sp)
    80002374:	f84a                	sd	s2,48(sp)
    80002376:	f44e                	sd	s3,40(sp)
    80002378:	f052                	sd	s4,32(sp)
    8000237a:	ec56                	sd	s5,24(sp)
    8000237c:	e85a                	sd	s6,16(sp)
    8000237e:	e45e                	sd	s7,8(sp)
    80002380:	0880                	addi	s0,sp,80
      [UNUSED] "unused",   [USED] "used",      [SLEEPING] "sleep ",
      [RUNNABLE] "runble", [RUNNING] "run   ", [ZOMBIE] "zombie"};
  struct proc *p;
  char *state;

  printf("\n");
    80002382:	00007517          	auipc	a0,0x7
    80002386:	d1e50513          	addi	a0,a0,-738 # 800090a0 <etext+0xa0>
    8000238a:	9a2fe0ef          	jal	8000052c <printf>
  for (p = proc; p < &proc[NPROC]; p++) {
    8000238e:	00010497          	auipc	s1,0x10
    80002392:	3a248493          	addi	s1,s1,930 # 80012730 <proc+0x158>
    80002396:	00016917          	auipc	s2,0x16
    8000239a:	d9a90913          	addi	s2,s2,-614 # 80018130 <bcache+0x140>
    if (p->state == UNUSED)
      continue;
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000239e:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    800023a0:	00007997          	auipc	s3,0x7
    800023a4:	e5898993          	addi	s3,s3,-424 # 800091f8 <etext+0x1f8>
    printf("%d %s %s", p->pid, state, p->name);
    800023a8:	00007a97          	auipc	s5,0x7
    800023ac:	e58a8a93          	addi	s5,s5,-424 # 80009200 <etext+0x200>
    printf("\n");
    800023b0:	00007a17          	auipc	s4,0x7
    800023b4:	cf0a0a13          	addi	s4,s4,-784 # 800090a0 <etext+0xa0>
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800023b8:	00008b97          	auipc	s7,0x8
    800023bc:	b30b8b93          	addi	s7,s7,-1232 # 80009ee8 <states.0>
    800023c0:	a829                	j	800023da <procdump+0x6e>
    printf("%d %s %s", p->pid, state, p->name);
    800023c2:	ed86a583          	lw	a1,-296(a3)
    800023c6:	8556                	mv	a0,s5
    800023c8:	964fe0ef          	jal	8000052c <printf>
    printf("\n");
    800023cc:	8552                	mv	a0,s4
    800023ce:	95efe0ef          	jal	8000052c <printf>
  for (p = proc; p < &proc[NPROC]; p++) {
    800023d2:	16848493          	addi	s1,s1,360
    800023d6:	03248263          	beq	s1,s2,800023fa <procdump+0x8e>
    if (p->state == UNUSED)
    800023da:	86a6                	mv	a3,s1
    800023dc:	ec04a783          	lw	a5,-320(s1)
    800023e0:	dbed                	beqz	a5,800023d2 <procdump+0x66>
      state = "???";
    800023e2:	864e                	mv	a2,s3
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800023e4:	fcfb6fe3          	bltu	s6,a5,800023c2 <procdump+0x56>
    800023e8:	02079713          	slli	a4,a5,0x20
    800023ec:	01d75793          	srli	a5,a4,0x1d
    800023f0:	97de                	add	a5,a5,s7
    800023f2:	6390                	ld	a2,0(a5)
    800023f4:	f679                	bnez	a2,800023c2 <procdump+0x56>
      state = "???";
    800023f6:	864e                	mv	a2,s3
    800023f8:	b7e9                	j	800023c2 <procdump+0x56>
  }
}
    800023fa:	60a6                	ld	ra,72(sp)
    800023fc:	6406                	ld	s0,64(sp)
    800023fe:	74e2                	ld	s1,56(sp)
    80002400:	7942                	ld	s2,48(sp)
    80002402:	79a2                	ld	s3,40(sp)
    80002404:	7a02                	ld	s4,32(sp)
    80002406:	6ae2                	ld	s5,24(sp)
    80002408:	6b42                	ld	s6,16(sp)
    8000240a:	6ba2                	ld	s7,8(sp)
    8000240c:	6161                	addi	sp,sp,80
    8000240e:	8082                	ret

0000000080002410 <swtch>:
# Save current registers in old. Load from new.	


.globl swtch
swtch:
        sd ra, 0(a0)
    80002410:	00153023          	sd	ra,0(a0)
        sd sp, 8(a0)
    80002414:	00253423          	sd	sp,8(a0)
        sd s0, 16(a0)
    80002418:	e900                	sd	s0,16(a0)
        sd s1, 24(a0)
    8000241a:	ed04                	sd	s1,24(a0)
        sd s2, 32(a0)
    8000241c:	03253023          	sd	s2,32(a0)
        sd s3, 40(a0)
    80002420:	03353423          	sd	s3,40(a0)
        sd s4, 48(a0)
    80002424:	03453823          	sd	s4,48(a0)
        sd s5, 56(a0)
    80002428:	03553c23          	sd	s5,56(a0)
        sd s6, 64(a0)
    8000242c:	05653023          	sd	s6,64(a0)
        sd s7, 72(a0)
    80002430:	05753423          	sd	s7,72(a0)
        sd s8, 80(a0)
    80002434:	05853823          	sd	s8,80(a0)
        sd s9, 88(a0)
    80002438:	05953c23          	sd	s9,88(a0)
        sd s10, 96(a0)
    8000243c:	07a53023          	sd	s10,96(a0)
        sd s11, 104(a0)
    80002440:	07b53423          	sd	s11,104(a0)

        ld ra, 0(a1)
    80002444:	0005b083          	ld	ra,0(a1)
        ld sp, 8(a1)
    80002448:	0085b103          	ld	sp,8(a1)
        ld s0, 16(a1)
    8000244c:	6980                	ld	s0,16(a1)
        ld s1, 24(a1)
    8000244e:	6d84                	ld	s1,24(a1)
        ld s2, 32(a1)
    80002450:	0205b903          	ld	s2,32(a1)
        ld s3, 40(a1)
    80002454:	0285b983          	ld	s3,40(a1)
        ld s4, 48(a1)
    80002458:	0305ba03          	ld	s4,48(a1)
        ld s5, 56(a1)
    8000245c:	0385ba83          	ld	s5,56(a1)
        ld s6, 64(a1)
    80002460:	0405bb03          	ld	s6,64(a1)
        ld s7, 72(a1)
    80002464:	0485bb83          	ld	s7,72(a1)
        ld s8, 80(a1)
    80002468:	0505bc03          	ld	s8,80(a1)
        ld s9, 88(a1)
    8000246c:	0585bc83          	ld	s9,88(a1)
        ld s10, 96(a1)
    80002470:	0605bd03          	ld	s10,96(a1)
        ld s11, 104(a1)
    80002474:	0685bd83          	ld	s11,104(a1)
        
        ret
    80002478:	8082                	ret

000000008000247a <trapinit>:

extern int devintr();

void
trapinit(void)
{
    8000247a:	1141                	addi	sp,sp,-16
    8000247c:	e406                	sd	ra,8(sp)
    8000247e:	e022                	sd	s0,0(sp)
    80002480:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    80002482:	00007597          	auipc	a1,0x7
    80002486:	dbe58593          	addi	a1,a1,-578 # 80009240 <etext+0x240>
    8000248a:	00016517          	auipc	a0,0x16
    8000248e:	b4e50513          	addi	a0,a0,-1202 # 80017fd8 <tickslock>
    80002492:	f3efe0ef          	jal	80000bd0 <initlock>
}
    80002496:	60a2                	ld	ra,8(sp)
    80002498:	6402                	ld	s0,0(sp)
    8000249a:	0141                	addi	sp,sp,16
    8000249c:	8082                	ret

000000008000249e <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    8000249e:	1141                	addi	sp,sp,-16
    800024a0:	e406                	sd	ra,8(sp)
    800024a2:	e022                	sd	s0,0(sp)
    800024a4:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    800024a6:	00004797          	auipc	a5,0x4
    800024aa:	0da78793          	addi	a5,a5,218 # 80006580 <kernelvec>
    800024ae:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    800024b2:	60a2                	ld	ra,8(sp)
    800024b4:	6402                	ld	s0,0(sp)
    800024b6:	0141                	addi	sp,sp,16
    800024b8:	8082                	ret

00000000800024ba <prepare_return>:
//
// set up trapframe and control registers for a return to user space
//
void
prepare_return(void)
{
    800024ba:	1141                	addi	sp,sp,-16
    800024bc:	e406                	sd	ra,8(sp)
    800024be:	e022                	sd	s0,0(sp)
    800024c0:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    800024c2:	ca6ff0ef          	jal	80001968 <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800024c6:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    800024ca:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800024cc:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(). because a trap from kernel
  // code to usertrap would be a disaster, turn off interrupts.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    800024d0:	04000737          	lui	a4,0x4000
    800024d4:	177d                	addi	a4,a4,-1 # 3ffffff <_entry-0x7c000001>
    800024d6:	0732                	slli	a4,a4,0xc
    800024d8:	00006797          	auipc	a5,0x6
    800024dc:	b2878793          	addi	a5,a5,-1240 # 80008000 <_trampoline>
    800024e0:	00006697          	auipc	a3,0x6
    800024e4:	b2068693          	addi	a3,a3,-1248 # 80008000 <_trampoline>
    800024e8:	8f95                	sub	a5,a5,a3
    800024ea:	97ba                	add	a5,a5,a4
  asm volatile("csrw stvec, %0" : : "r" (x));
    800024ec:	10579073          	csrw	stvec,a5
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    800024f0:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    800024f2:	18002773          	csrr	a4,satp
    800024f6:	e398                	sd	a4,0(a5)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    800024f8:	6d38                	ld	a4,88(a0)
    800024fa:	613c                	ld	a5,64(a0)
    800024fc:	6685                	lui	a3,0x1
    800024fe:	97b6                	add	a5,a5,a3
    80002500:	e71c                	sd	a5,8(a4)
  p->trapframe->kernel_trap = (uint64)usertrap;
    80002502:	6d3c                	ld	a5,88(a0)
    80002504:	00000717          	auipc	a4,0x0
    80002508:	0fc70713          	addi	a4,a4,252 # 80002600 <usertrap>
    8000250c:	eb98                	sd	a4,16(a5)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    8000250e:	6d3c                	ld	a5,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    80002510:	8712                	mv	a4,tp
    80002512:	f398                	sd	a4,32(a5)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002514:	100027f3          	csrr	a5,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    80002518:	eff7f793          	andi	a5,a5,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    8000251c:	0207e793          	ori	a5,a5,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002520:	10079073          	csrw	sstatus,a5
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    80002524:	6d3c                	ld	a5,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002526:	6f9c                	ld	a5,24(a5)
    80002528:	14179073          	csrw	sepc,a5
}
    8000252c:	60a2                	ld	ra,8(sp)
    8000252e:	6402                	ld	s0,0(sp)
    80002530:	0141                	addi	sp,sp,16
    80002532:	8082                	ret

0000000080002534 <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    80002534:	1141                	addi	sp,sp,-16
    80002536:	e406                	sd	ra,8(sp)
    80002538:	e022                	sd	s0,0(sp)
    8000253a:	0800                	addi	s0,sp,16
  if(cpuid() == 0){
    8000253c:	bf8ff0ef          	jal	80001934 <cpuid>
    80002540:	cd11                	beqz	a0,8000255c <clockintr+0x28>
  asm volatile("csrr %0, time" : "=r" (x) );
    80002542:	c01027f3          	rdtime	a5
  }

  // ask for the next timer interrupt. this also clears
  // the interrupt request. 1000000 is about a tenth
  // of a second.
  w_stimecmp(r_time() + 1000000);
    80002546:	000f4737          	lui	a4,0xf4
    8000254a:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    8000254e:	97ba                	add	a5,a5,a4
  asm volatile("csrw 0x14d, %0" : : "r" (x));
    80002550:	14d79073          	csrw	stimecmp,a5
}
    80002554:	60a2                	ld	ra,8(sp)
    80002556:	6402                	ld	s0,0(sp)
    80002558:	0141                	addi	sp,sp,16
    8000255a:	8082                	ret
    acquire(&tickslock);
    8000255c:	00016517          	auipc	a0,0x16
    80002560:	a7c50513          	addi	a0,a0,-1412 # 80017fd8 <tickslock>
    80002564:	ef6fe0ef          	jal	80000c5a <acquire>
    ticks++;
    80002568:	00008717          	auipc	a4,0x8
    8000256c:	ae070713          	addi	a4,a4,-1312 # 8000a048 <ticks>
    80002570:	431c                	lw	a5,0(a4)
    80002572:	2785                	addiw	a5,a5,1
    80002574:	c31c                	sw	a5,0(a4)
    wakeup(&ticks);
    80002576:	853a                	mv	a0,a4
    80002578:	a53ff0ef          	jal	80001fca <wakeup>
    release(&tickslock);
    8000257c:	00016517          	auipc	a0,0x16
    80002580:	a5c50513          	addi	a0,a0,-1444 # 80017fd8 <tickslock>
    80002584:	f6afe0ef          	jal	80000cee <release>
    80002588:	bf6d                	j	80002542 <clockintr+0xe>

000000008000258a <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    8000258a:	1101                	addi	sp,sp,-32
    8000258c:	ec06                	sd	ra,24(sp)
    8000258e:	e822                	sd	s0,16(sp)
    80002590:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002592:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if(scause == 0x8000000000000009L){
    80002596:	57fd                	li	a5,-1
    80002598:	17fe                	slli	a5,a5,0x3f
    8000259a:	07a5                	addi	a5,a5,9
    8000259c:	00f70c63          	beq	a4,a5,800025b4 <devintr+0x2a>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000005L){
    800025a0:	57fd                	li	a5,-1
    800025a2:	17fe                	slli	a5,a5,0x3f
    800025a4:	0795                	addi	a5,a5,5
    // timer interrupt.
    clockintr();
    return 2;
  } else {
    return 0;
    800025a6:	4501                	li	a0,0
  } else if(scause == 0x8000000000000005L){
    800025a8:	04f70863          	beq	a4,a5,800025f8 <devintr+0x6e>
  }
}
    800025ac:	60e2                	ld	ra,24(sp)
    800025ae:	6442                	ld	s0,16(sp)
    800025b0:	6105                	addi	sp,sp,32
    800025b2:	8082                	ret
    800025b4:	e426                	sd	s1,8(sp)
    int irq = plic_claim();
    800025b6:	076040ef          	jal	8000662c <plic_claim>
    800025ba:	872a                	mv	a4,a0
    800025bc:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    800025be:	47a9                	li	a5,10
    800025c0:	00f50963          	beq	a0,a5,800025d2 <devintr+0x48>
    } else if(irq == VIRTIO0_IRQ){
    800025c4:	4785                	li	a5,1
    800025c6:	00f50963          	beq	a0,a5,800025d8 <devintr+0x4e>
    return 1;
    800025ca:	4505                	li	a0,1
    } else if(irq){
    800025cc:	eb09                	bnez	a4,800025de <devintr+0x54>
    800025ce:	64a2                	ld	s1,8(sp)
    800025d0:	bff1                	j	800025ac <devintr+0x22>
      uartintr();
    800025d2:	c54fe0ef          	jal	80000a26 <uartintr>
    if(irq)
    800025d6:	a819                	j	800025ec <devintr+0x62>
      virtio_disk_intr();
    800025d8:	4ea040ef          	jal	80006ac2 <virtio_disk_intr>
    if(irq)
    800025dc:	a801                	j	800025ec <devintr+0x62>
      printf("unexpected interrupt irq=%d\n", irq);
    800025de:	85ba                	mv	a1,a4
    800025e0:	00007517          	auipc	a0,0x7
    800025e4:	c6850513          	addi	a0,a0,-920 # 80009248 <etext+0x248>
    800025e8:	f45fd0ef          	jal	8000052c <printf>
      plic_complete(irq);
    800025ec:	8526                	mv	a0,s1
    800025ee:	05e040ef          	jal	8000664c <plic_complete>
    return 1;
    800025f2:	4505                	li	a0,1
    800025f4:	64a2                	ld	s1,8(sp)
    800025f6:	bf5d                	j	800025ac <devintr+0x22>
    clockintr();
    800025f8:	f3dff0ef          	jal	80002534 <clockintr>
    return 2;
    800025fc:	4509                	li	a0,2
    800025fe:	b77d                	j	800025ac <devintr+0x22>

0000000080002600 <usertrap>:
{
    80002600:	1101                	addi	sp,sp,-32
    80002602:	ec06                	sd	ra,24(sp)
    80002604:	e822                	sd	s0,16(sp)
    80002606:	e426                	sd	s1,8(sp)
    80002608:	e04a                	sd	s2,0(sp)
    8000260a:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000260c:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    80002610:	1007f793          	andi	a5,a5,256
    80002614:	eba5                	bnez	a5,80002684 <usertrap+0x84>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002616:	00004797          	auipc	a5,0x4
    8000261a:	f6a78793          	addi	a5,a5,-150 # 80006580 <kernelvec>
    8000261e:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80002622:	b46ff0ef          	jal	80001968 <myproc>
    80002626:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    80002628:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    8000262a:	14102773          	csrr	a4,sepc
    8000262e:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002630:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    80002634:	47a1                	li	a5,8
    80002636:	04f70d63          	beq	a4,a5,80002690 <usertrap+0x90>
  } else if((which_dev = devintr()) != 0){
    8000263a:	f51ff0ef          	jal	8000258a <devintr>
    8000263e:	892a                	mv	s2,a0
    80002640:	e945                	bnez	a0,800026f0 <usertrap+0xf0>
    80002642:	14202773          	csrr	a4,scause
  } else if((r_scause() == 15 || r_scause() == 13) &&
    80002646:	47bd                	li	a5,15
    80002648:	08f70863          	beq	a4,a5,800026d8 <usertrap+0xd8>
    8000264c:	14202773          	csrr	a4,scause
    80002650:	47b5                	li	a5,13
    80002652:	08f70363          	beq	a4,a5,800026d8 <usertrap+0xd8>
    80002656:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause 0x%lx pid=%d\n", r_scause(), p->pid);
    8000265a:	5890                	lw	a2,48(s1)
    8000265c:	00007517          	auipc	a0,0x7
    80002660:	c2c50513          	addi	a0,a0,-980 # 80009288 <etext+0x288>
    80002664:	ec9fd0ef          	jal	8000052c <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002668:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    8000266c:	14302673          	csrr	a2,stval
    printf("            sepc=0x%lx stval=0x%lx\n", r_sepc(), r_stval());
    80002670:	00007517          	auipc	a0,0x7
    80002674:	c4850513          	addi	a0,a0,-952 # 800092b8 <etext+0x2b8>
    80002678:	eb5fd0ef          	jal	8000052c <printf>
    setkilled(p);
    8000267c:	8526                	mv	a0,s1
    8000267e:	b19ff0ef          	jal	80002196 <setkilled>
    80002682:	a035                	j	800026ae <usertrap+0xae>
    panic("usertrap: not from user mode");
    80002684:	00007517          	auipc	a0,0x7
    80002688:	be450513          	addi	a0,a0,-1052 # 80009268 <etext+0x268>
    8000268c:	9cafe0ef          	jal	80000856 <panic>
    if(killed(p))
    80002690:	b2bff0ef          	jal	800021ba <killed>
    80002694:	ed15                	bnez	a0,800026d0 <usertrap+0xd0>
    p->trapframe->epc += 4;
    80002696:	6cb8                	ld	a4,88(s1)
    80002698:	6f1c                	ld	a5,24(a4)
    8000269a:	0791                	addi	a5,a5,4
    8000269c:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000269e:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    800026a2:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800026a6:	10079073          	csrw	sstatus,a5
    syscall();
    800026aa:	240000ef          	jal	800028ea <syscall>
  if(killed(p))
    800026ae:	8526                	mv	a0,s1
    800026b0:	b0bff0ef          	jal	800021ba <killed>
    800026b4:	e139                	bnez	a0,800026fa <usertrap+0xfa>
  prepare_return();
    800026b6:	e05ff0ef          	jal	800024ba <prepare_return>
  uint64 satp = MAKE_SATP(p->pagetable);
    800026ba:	68a8                	ld	a0,80(s1)
    800026bc:	8131                	srli	a0,a0,0xc
    800026be:	57fd                	li	a5,-1
    800026c0:	17fe                	slli	a5,a5,0x3f
    800026c2:	8d5d                	or	a0,a0,a5
}
    800026c4:	60e2                	ld	ra,24(sp)
    800026c6:	6442                	ld	s0,16(sp)
    800026c8:	64a2                	ld	s1,8(sp)
    800026ca:	6902                	ld	s2,0(sp)
    800026cc:	6105                	addi	sp,sp,32
    800026ce:	8082                	ret
      kexit(-1);
    800026d0:	557d                	li	a0,-1
    800026d2:	9b9ff0ef          	jal	8000208a <kexit>
    800026d6:	b7c1                	j	80002696 <usertrap+0x96>
  asm volatile("csrr %0, stval" : "=r" (x) );
    800026d8:	143025f3          	csrr	a1,stval
  asm volatile("csrr %0, scause" : "=r" (x) );
    800026dc:	14202673          	csrr	a2,scause
            vmfault(p->pagetable, r_stval(), (r_scause() == 13)? 1 : 0) != 0) {
    800026e0:	164d                	addi	a2,a2,-13 # ff3 <_entry-0x7ffff00d>
    800026e2:	00163613          	seqz	a2,a2
    800026e6:	68a8                	ld	a0,80(s1)
    800026e8:	f23fe0ef          	jal	8000160a <vmfault>
  } else if((r_scause() == 15 || r_scause() == 13) &&
    800026ec:	f169                	bnez	a0,800026ae <usertrap+0xae>
    800026ee:	b7a5                	j	80002656 <usertrap+0x56>
  if(killed(p))
    800026f0:	8526                	mv	a0,s1
    800026f2:	ac9ff0ef          	jal	800021ba <killed>
    800026f6:	c511                	beqz	a0,80002702 <usertrap+0x102>
    800026f8:	a011                	j	800026fc <usertrap+0xfc>
    800026fa:	4901                	li	s2,0
    kexit(-1);
    800026fc:	557d                	li	a0,-1
    800026fe:	98dff0ef          	jal	8000208a <kexit>
  if(which_dev == 2)
    80002702:	4789                	li	a5,2
    80002704:	faf919e3          	bne	s2,a5,800026b6 <usertrap+0xb6>
    yield();
    80002708:	84bff0ef          	jal	80001f52 <yield>
    8000270c:	b76d                	j	800026b6 <usertrap+0xb6>

000000008000270e <kerneltrap>:
{
    8000270e:	7179                	addi	sp,sp,-48
    80002710:	f406                	sd	ra,40(sp)
    80002712:	f022                	sd	s0,32(sp)
    80002714:	ec26                	sd	s1,24(sp)
    80002716:	e84a                	sd	s2,16(sp)
    80002718:	e44e                	sd	s3,8(sp)
    8000271a:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    8000271c:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002720:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002724:	142027f3          	csrr	a5,scause
    80002728:	89be                	mv	s3,a5
  if((sstatus & SSTATUS_SPP) == 0)
    8000272a:	1004f793          	andi	a5,s1,256
    8000272e:	c795                	beqz	a5,8000275a <kerneltrap+0x4c>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002730:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002734:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    80002736:	eb85                	bnez	a5,80002766 <kerneltrap+0x58>
  if((which_dev = devintr()) == 0){
    80002738:	e53ff0ef          	jal	8000258a <devintr>
    8000273c:	c91d                	beqz	a0,80002772 <kerneltrap+0x64>
  if(which_dev == 2 && myproc() != 0)
    8000273e:	4789                	li	a5,2
    80002740:	04f50a63          	beq	a0,a5,80002794 <kerneltrap+0x86>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002744:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002748:	10049073          	csrw	sstatus,s1
}
    8000274c:	70a2                	ld	ra,40(sp)
    8000274e:	7402                	ld	s0,32(sp)
    80002750:	64e2                	ld	s1,24(sp)
    80002752:	6942                	ld	s2,16(sp)
    80002754:	69a2                	ld	s3,8(sp)
    80002756:	6145                	addi	sp,sp,48
    80002758:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    8000275a:	00007517          	auipc	a0,0x7
    8000275e:	b8650513          	addi	a0,a0,-1146 # 800092e0 <etext+0x2e0>
    80002762:	8f4fe0ef          	jal	80000856 <panic>
    panic("kerneltrap: interrupts enabled");
    80002766:	00007517          	auipc	a0,0x7
    8000276a:	ba250513          	addi	a0,a0,-1118 # 80009308 <etext+0x308>
    8000276e:	8e8fe0ef          	jal	80000856 <panic>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002772:	14102673          	csrr	a2,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002776:	143026f3          	csrr	a3,stval
    printf("scause=0x%lx sepc=0x%lx stval=0x%lx\n", scause, r_sepc(), r_stval());
    8000277a:	85ce                	mv	a1,s3
    8000277c:	00007517          	auipc	a0,0x7
    80002780:	bac50513          	addi	a0,a0,-1108 # 80009328 <etext+0x328>
    80002784:	da9fd0ef          	jal	8000052c <printf>
    panic("kerneltrap");
    80002788:	00007517          	auipc	a0,0x7
    8000278c:	bc850513          	addi	a0,a0,-1080 # 80009350 <etext+0x350>
    80002790:	8c6fe0ef          	jal	80000856 <panic>
  if(which_dev == 2 && myproc() != 0)
    80002794:	9d4ff0ef          	jal	80001968 <myproc>
    80002798:	d555                	beqz	a0,80002744 <kerneltrap+0x36>
    yield();
    8000279a:	fb8ff0ef          	jal	80001f52 <yield>
    8000279e:	b75d                	j	80002744 <kerneltrap+0x36>

00000000800027a0 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    800027a0:	1101                	addi	sp,sp,-32
    800027a2:	ec06                	sd	ra,24(sp)
    800027a4:	e822                	sd	s0,16(sp)
    800027a6:	e426                	sd	s1,8(sp)
    800027a8:	1000                	addi	s0,sp,32
    800027aa:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    800027ac:	9bcff0ef          	jal	80001968 <myproc>
  switch (n) {
    800027b0:	4795                	li	a5,5
    800027b2:	0497e163          	bltu	a5,s1,800027f4 <argraw+0x54>
    800027b6:	048a                	slli	s1,s1,0x2
    800027b8:	00007717          	auipc	a4,0x7
    800027bc:	76070713          	addi	a4,a4,1888 # 80009f18 <states.0+0x30>
    800027c0:	94ba                	add	s1,s1,a4
    800027c2:	409c                	lw	a5,0(s1)
    800027c4:	97ba                	add	a5,a5,a4
    800027c6:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    800027c8:	6d3c                	ld	a5,88(a0)
    800027ca:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    800027cc:	60e2                	ld	ra,24(sp)
    800027ce:	6442                	ld	s0,16(sp)
    800027d0:	64a2                	ld	s1,8(sp)
    800027d2:	6105                	addi	sp,sp,32
    800027d4:	8082                	ret
    return p->trapframe->a1;
    800027d6:	6d3c                	ld	a5,88(a0)
    800027d8:	7fa8                	ld	a0,120(a5)
    800027da:	bfcd                	j	800027cc <argraw+0x2c>
    return p->trapframe->a2;
    800027dc:	6d3c                	ld	a5,88(a0)
    800027de:	63c8                	ld	a0,128(a5)
    800027e0:	b7f5                	j	800027cc <argraw+0x2c>
    return p->trapframe->a3;
    800027e2:	6d3c                	ld	a5,88(a0)
    800027e4:	67c8                	ld	a0,136(a5)
    800027e6:	b7dd                	j	800027cc <argraw+0x2c>
    return p->trapframe->a4;
    800027e8:	6d3c                	ld	a5,88(a0)
    800027ea:	6bc8                	ld	a0,144(a5)
    800027ec:	b7c5                	j	800027cc <argraw+0x2c>
    return p->trapframe->a5;
    800027ee:	6d3c                	ld	a5,88(a0)
    800027f0:	6fc8                	ld	a0,152(a5)
    800027f2:	bfe9                	j	800027cc <argraw+0x2c>
  panic("argraw");
    800027f4:	00007517          	auipc	a0,0x7
    800027f8:	b6c50513          	addi	a0,a0,-1172 # 80009360 <etext+0x360>
    800027fc:	85afe0ef          	jal	80000856 <panic>

0000000080002800 <fetchaddr>:
{
    80002800:	1101                	addi	sp,sp,-32
    80002802:	ec06                	sd	ra,24(sp)
    80002804:	e822                	sd	s0,16(sp)
    80002806:	e426                	sd	s1,8(sp)
    80002808:	e04a                	sd	s2,0(sp)
    8000280a:	1000                	addi	s0,sp,32
    8000280c:	84aa                	mv	s1,a0
    8000280e:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002810:	958ff0ef          	jal	80001968 <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    80002814:	653c                	ld	a5,72(a0)
    80002816:	02f4f663          	bgeu	s1,a5,80002842 <fetchaddr+0x42>
    8000281a:	00848713          	addi	a4,s1,8
    8000281e:	02e7e463          	bltu	a5,a4,80002846 <fetchaddr+0x46>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80002822:	46a1                	li	a3,8
    80002824:	8626                	mv	a2,s1
    80002826:	85ca                	mv	a1,s2
    80002828:	6928                	ld	a0,80(a0)
    8000282a:	f23fe0ef          	jal	8000174c <copyin>
    8000282e:	00a03533          	snez	a0,a0
    80002832:	40a0053b          	negw	a0,a0
}
    80002836:	60e2                	ld	ra,24(sp)
    80002838:	6442                	ld	s0,16(sp)
    8000283a:	64a2                	ld	s1,8(sp)
    8000283c:	6902                	ld	s2,0(sp)
    8000283e:	6105                	addi	sp,sp,32
    80002840:	8082                	ret
    return -1;
    80002842:	557d                	li	a0,-1
    80002844:	bfcd                	j	80002836 <fetchaddr+0x36>
    80002846:	557d                	li	a0,-1
    80002848:	b7fd                	j	80002836 <fetchaddr+0x36>

000000008000284a <fetchstr>:
{
    8000284a:	7179                	addi	sp,sp,-48
    8000284c:	f406                	sd	ra,40(sp)
    8000284e:	f022                	sd	s0,32(sp)
    80002850:	ec26                	sd	s1,24(sp)
    80002852:	e84a                	sd	s2,16(sp)
    80002854:	e44e                	sd	s3,8(sp)
    80002856:	1800                	addi	s0,sp,48
    80002858:	89aa                	mv	s3,a0
    8000285a:	84ae                	mv	s1,a1
    8000285c:	8932                	mv	s2,a2
  struct proc *p = myproc();
    8000285e:	90aff0ef          	jal	80001968 <myproc>
  if(copyinstr(p->pagetable, buf, addr, max) < 0)
    80002862:	86ca                	mv	a3,s2
    80002864:	864e                	mv	a2,s3
    80002866:	85a6                	mv	a1,s1
    80002868:	6928                	ld	a0,80(a0)
    8000286a:	cc9fe0ef          	jal	80001532 <copyinstr>
    8000286e:	00054c63          	bltz	a0,80002886 <fetchstr+0x3c>
  return strlen(buf);
    80002872:	8526                	mv	a0,s1
    80002874:	e40fe0ef          	jal	80000eb4 <strlen>
}
    80002878:	70a2                	ld	ra,40(sp)
    8000287a:	7402                	ld	s0,32(sp)
    8000287c:	64e2                	ld	s1,24(sp)
    8000287e:	6942                	ld	s2,16(sp)
    80002880:	69a2                	ld	s3,8(sp)
    80002882:	6145                	addi	sp,sp,48
    80002884:	8082                	ret
    return -1;
    80002886:	557d                	li	a0,-1
    80002888:	bfc5                	j	80002878 <fetchstr+0x2e>

000000008000288a <argint>:

// Fetch the nth 32-bit system call argument.
void
argint(int n, int *ip)
{
    8000288a:	1101                	addi	sp,sp,-32
    8000288c:	ec06                	sd	ra,24(sp)
    8000288e:	e822                	sd	s0,16(sp)
    80002890:	e426                	sd	s1,8(sp)
    80002892:	1000                	addi	s0,sp,32
    80002894:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002896:	f0bff0ef          	jal	800027a0 <argraw>
    8000289a:	c088                	sw	a0,0(s1)
}
    8000289c:	60e2                	ld	ra,24(sp)
    8000289e:	6442                	ld	s0,16(sp)
    800028a0:	64a2                	ld	s1,8(sp)
    800028a2:	6105                	addi	sp,sp,32
    800028a4:	8082                	ret

00000000800028a6 <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void
argaddr(int n, uint64 *ip)
{
    800028a6:	1101                	addi	sp,sp,-32
    800028a8:	ec06                	sd	ra,24(sp)
    800028aa:	e822                	sd	s0,16(sp)
    800028ac:	e426                	sd	s1,8(sp)
    800028ae:	1000                	addi	s0,sp,32
    800028b0:	84ae                	mv	s1,a1
  *ip = argraw(n);
    800028b2:	eefff0ef          	jal	800027a0 <argraw>
    800028b6:	e088                	sd	a0,0(s1)
}
    800028b8:	60e2                	ld	ra,24(sp)
    800028ba:	6442                	ld	s0,16(sp)
    800028bc:	64a2                	ld	s1,8(sp)
    800028be:	6105                	addi	sp,sp,32
    800028c0:	8082                	ret

00000000800028c2 <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    800028c2:	1101                	addi	sp,sp,-32
    800028c4:	ec06                	sd	ra,24(sp)
    800028c6:	e822                	sd	s0,16(sp)
    800028c8:	e426                	sd	s1,8(sp)
    800028ca:	e04a                	sd	s2,0(sp)
    800028cc:	1000                	addi	s0,sp,32
    800028ce:	892e                	mv	s2,a1
    800028d0:	84b2                	mv	s1,a2
  *ip = argraw(n);
    800028d2:	ecfff0ef          	jal	800027a0 <argraw>
  uint64 addr;
  argaddr(n, &addr);
  return fetchstr(addr, buf, max);
    800028d6:	8626                	mv	a2,s1
    800028d8:	85ca                	mv	a1,s2
    800028da:	f71ff0ef          	jal	8000284a <fetchstr>
}
    800028de:	60e2                	ld	ra,24(sp)
    800028e0:	6442                	ld	s0,16(sp)
    800028e2:	64a2                	ld	s1,8(sp)
    800028e4:	6902                	ld	s2,0(sp)
    800028e6:	6105                	addi	sp,sp,32
    800028e8:	8082                	ret

00000000800028ea <syscall>:

};

void
syscall(void)
{
    800028ea:	1101                	addi	sp,sp,-32
    800028ec:	ec06                	sd	ra,24(sp)
    800028ee:	e822                	sd	s0,16(sp)
    800028f0:	e426                	sd	s1,8(sp)
    800028f2:	e04a                	sd	s2,0(sp)
    800028f4:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    800028f6:	872ff0ef          	jal	80001968 <myproc>
    800028fa:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    800028fc:	05853903          	ld	s2,88(a0)
    80002900:	0a893783          	ld	a5,168(s2)
    80002904:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80002908:	37fd                	addiw	a5,a5,-1
    8000290a:	4769                	li	a4,26
    8000290c:	00f76f63          	bltu	a4,a5,8000292a <syscall+0x40>
    80002910:	00369713          	slli	a4,a3,0x3
    80002914:	00007797          	auipc	a5,0x7
    80002918:	61c78793          	addi	a5,a5,1564 # 80009f30 <syscalls>
    8000291c:	97ba                	add	a5,a5,a4
    8000291e:	639c                	ld	a5,0(a5)
    80002920:	c789                	beqz	a5,8000292a <syscall+0x40>
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    p->trapframe->a0 = syscalls[num]();
    80002922:	9782                	jalr	a5
    80002924:	06a93823          	sd	a0,112(s2)
    80002928:	a829                	j	80002942 <syscall+0x58>
  } else {
    printf("%d %s: unknown sys call %d\n",
    8000292a:	15848613          	addi	a2,s1,344
    8000292e:	588c                	lw	a1,48(s1)
    80002930:	00007517          	auipc	a0,0x7
    80002934:	a3850513          	addi	a0,a0,-1480 # 80009368 <etext+0x368>
    80002938:	bf5fd0ef          	jal	8000052c <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    8000293c:	6cbc                	ld	a5,88(s1)
    8000293e:	577d                	li	a4,-1
    80002940:	fbb8                	sd	a4,112(a5)
  }
}
    80002942:	60e2                	ld	ra,24(sp)
    80002944:	6442                	ld	s0,16(sp)
    80002946:	64a2                	ld	s1,8(sp)
    80002948:	6902                	ld	s2,0(sp)
    8000294a:	6105                	addi	sp,sp,32
    8000294c:	8082                	ret

000000008000294e <sys_exit>:
#include "proc.h"
#include "vm.h"

uint64
sys_exit(void)
{
    8000294e:	1101                	addi	sp,sp,-32
    80002950:	ec06                	sd	ra,24(sp)
    80002952:	e822                	sd	s0,16(sp)
    80002954:	1000                	addi	s0,sp,32
  int n;
  argint(0, &n);
    80002956:	fec40593          	addi	a1,s0,-20
    8000295a:	4501                	li	a0,0
    8000295c:	f2fff0ef          	jal	8000288a <argint>
  kexit(n);
    80002960:	fec42503          	lw	a0,-20(s0)
    80002964:	f26ff0ef          	jal	8000208a <kexit>
  return 0;  // not reached
}
    80002968:	4501                	li	a0,0
    8000296a:	60e2                	ld	ra,24(sp)
    8000296c:	6442                	ld	s0,16(sp)
    8000296e:	6105                	addi	sp,sp,32
    80002970:	8082                	ret

0000000080002972 <sys_getpid>:

uint64
sys_getpid(void)
{
    80002972:	1141                	addi	sp,sp,-16
    80002974:	e406                	sd	ra,8(sp)
    80002976:	e022                	sd	s0,0(sp)
    80002978:	0800                	addi	s0,sp,16
  return myproc()->pid;
    8000297a:	feffe0ef          	jal	80001968 <myproc>
}
    8000297e:	5908                	lw	a0,48(a0)
    80002980:	60a2                	ld	ra,8(sp)
    80002982:	6402                	ld	s0,0(sp)
    80002984:	0141                	addi	sp,sp,16
    80002986:	8082                	ret

0000000080002988 <sys_fork>:

uint64
sys_fork(void)
{
    80002988:	1141                	addi	sp,sp,-16
    8000298a:	e406                	sd	ra,8(sp)
    8000298c:	e022                	sd	s0,0(sp)
    8000298e:	0800                	addi	s0,sp,16
  return kfork();
    80002990:	b40ff0ef          	jal	80001cd0 <kfork>
}
    80002994:	60a2                	ld	ra,8(sp)
    80002996:	6402                	ld	s0,0(sp)
    80002998:	0141                	addi	sp,sp,16
    8000299a:	8082                	ret

000000008000299c <sys_wait>:

uint64
sys_wait(void)
{
    8000299c:	1101                	addi	sp,sp,-32
    8000299e:	ec06                	sd	ra,24(sp)
    800029a0:	e822                	sd	s0,16(sp)
    800029a2:	1000                	addi	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    800029a4:	fe840593          	addi	a1,s0,-24
    800029a8:	4501                	li	a0,0
    800029aa:	efdff0ef          	jal	800028a6 <argaddr>
  return kwait(p);
    800029ae:	fe843503          	ld	a0,-24(s0)
    800029b2:	833ff0ef          	jal	800021e4 <kwait>
}
    800029b6:	60e2                	ld	ra,24(sp)
    800029b8:	6442                	ld	s0,16(sp)
    800029ba:	6105                	addi	sp,sp,32
    800029bc:	8082                	ret

00000000800029be <sys_sbrk>:

uint64
sys_sbrk(void)
{
    800029be:	7179                	addi	sp,sp,-48
    800029c0:	f406                	sd	ra,40(sp)
    800029c2:	f022                	sd	s0,32(sp)
    800029c4:	ec26                	sd	s1,24(sp)
    800029c6:	1800                	addi	s0,sp,48
  uint64 addr;
  int t;
  int n;

  argint(0, &n);
    800029c8:	fd840593          	addi	a1,s0,-40
    800029cc:	4501                	li	a0,0
    800029ce:	ebdff0ef          	jal	8000288a <argint>
  argint(1, &t);
    800029d2:	fdc40593          	addi	a1,s0,-36
    800029d6:	4505                	li	a0,1
    800029d8:	eb3ff0ef          	jal	8000288a <argint>
  addr = myproc()->sz;
    800029dc:	f8dfe0ef          	jal	80001968 <myproc>
    800029e0:	6524                	ld	s1,72(a0)

  if(t == SBRK_EAGER || n < 0) {
    800029e2:	fdc42703          	lw	a4,-36(s0)
    800029e6:	4785                	li	a5,1
    800029e8:	02f70763          	beq	a4,a5,80002a16 <sys_sbrk+0x58>
    800029ec:	fd842783          	lw	a5,-40(s0)
    800029f0:	0207c363          	bltz	a5,80002a16 <sys_sbrk+0x58>
    }
  } else {
    // Lazily allocate memory for this process: increase its memory
    // size but don't allocate memory. If the processes uses the
    // memory, vmfault() will allocate it.
    if(addr + n < addr)
    800029f4:	97a6                	add	a5,a5,s1
      return -1;
    if(addr + n > TRAPFRAME)
    800029f6:	02000737          	lui	a4,0x2000
    800029fa:	177d                	addi	a4,a4,-1 # 1ffffff <_entry-0x7e000001>
    800029fc:	0736                	slli	a4,a4,0xd
    800029fe:	02f76a63          	bltu	a4,a5,80002a32 <sys_sbrk+0x74>
    80002a02:	0297e863          	bltu	a5,s1,80002a32 <sys_sbrk+0x74>
      return -1;
    myproc()->sz += n;
    80002a06:	f63fe0ef          	jal	80001968 <myproc>
    80002a0a:	fd842703          	lw	a4,-40(s0)
    80002a0e:	653c                	ld	a5,72(a0)
    80002a10:	97ba                	add	a5,a5,a4
    80002a12:	e53c                	sd	a5,72(a0)
    80002a14:	a039                	j	80002a22 <sys_sbrk+0x64>
    if(growproc(n) < 0) {
    80002a16:	fd842503          	lw	a0,-40(s0)
    80002a1a:	a54ff0ef          	jal	80001c6e <growproc>
    80002a1e:	00054863          	bltz	a0,80002a2e <sys_sbrk+0x70>
  }
  return addr;
}
    80002a22:	8526                	mv	a0,s1
    80002a24:	70a2                	ld	ra,40(sp)
    80002a26:	7402                	ld	s0,32(sp)
    80002a28:	64e2                	ld	s1,24(sp)
    80002a2a:	6145                	addi	sp,sp,48
    80002a2c:	8082                	ret
      return -1;
    80002a2e:	54fd                	li	s1,-1
    80002a30:	bfcd                	j	80002a22 <sys_sbrk+0x64>
      return -1;
    80002a32:	54fd                	li	s1,-1
    80002a34:	b7fd                	j	80002a22 <sys_sbrk+0x64>

0000000080002a36 <sys_pause>:

uint64
sys_pause(void)
{
    80002a36:	7139                	addi	sp,sp,-64
    80002a38:	fc06                	sd	ra,56(sp)
    80002a3a:	f822                	sd	s0,48(sp)
    80002a3c:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    80002a3e:	fcc40593          	addi	a1,s0,-52
    80002a42:	4501                	li	a0,0
    80002a44:	e47ff0ef          	jal	8000288a <argint>
  if(n < 0)
    80002a48:	fcc42783          	lw	a5,-52(s0)
    80002a4c:	0607c863          	bltz	a5,80002abc <sys_pause+0x86>
    n = 0;
  acquire(&tickslock);
    80002a50:	00015517          	auipc	a0,0x15
    80002a54:	58850513          	addi	a0,a0,1416 # 80017fd8 <tickslock>
    80002a58:	a02fe0ef          	jal	80000c5a <acquire>
  ticks0 = ticks;
  while(ticks - ticks0 < n){
    80002a5c:	fcc42783          	lw	a5,-52(s0)
    80002a60:	c3b9                	beqz	a5,80002aa6 <sys_pause+0x70>
    80002a62:	f426                	sd	s1,40(sp)
    80002a64:	f04a                	sd	s2,32(sp)
    80002a66:	ec4e                	sd	s3,24(sp)
  ticks0 = ticks;
    80002a68:	00007997          	auipc	s3,0x7
    80002a6c:	5e09a983          	lw	s3,1504(s3) # 8000a048 <ticks>
    if(killed(myproc())){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80002a70:	00015917          	auipc	s2,0x15
    80002a74:	56890913          	addi	s2,s2,1384 # 80017fd8 <tickslock>
    80002a78:	00007497          	auipc	s1,0x7
    80002a7c:	5d048493          	addi	s1,s1,1488 # 8000a048 <ticks>
    if(killed(myproc())){
    80002a80:	ee9fe0ef          	jal	80001968 <myproc>
    80002a84:	f36ff0ef          	jal	800021ba <killed>
    80002a88:	ed0d                	bnez	a0,80002ac2 <sys_pause+0x8c>
    sleep(&ticks, &tickslock);
    80002a8a:	85ca                	mv	a1,s2
    80002a8c:	8526                	mv	a0,s1
    80002a8e:	cf0ff0ef          	jal	80001f7e <sleep>
  while(ticks - ticks0 < n){
    80002a92:	409c                	lw	a5,0(s1)
    80002a94:	413787bb          	subw	a5,a5,s3
    80002a98:	fcc42703          	lw	a4,-52(s0)
    80002a9c:	fee7e2e3          	bltu	a5,a4,80002a80 <sys_pause+0x4a>
    80002aa0:	74a2                	ld	s1,40(sp)
    80002aa2:	7902                	ld	s2,32(sp)
    80002aa4:	69e2                	ld	s3,24(sp)
  }
  release(&tickslock);
    80002aa6:	00015517          	auipc	a0,0x15
    80002aaa:	53250513          	addi	a0,a0,1330 # 80017fd8 <tickslock>
    80002aae:	a40fe0ef          	jal	80000cee <release>
  return 0;
    80002ab2:	4501                	li	a0,0
}
    80002ab4:	70e2                	ld	ra,56(sp)
    80002ab6:	7442                	ld	s0,48(sp)
    80002ab8:	6121                	addi	sp,sp,64
    80002aba:	8082                	ret
    n = 0;
    80002abc:	fc042623          	sw	zero,-52(s0)
    80002ac0:	bf41                	j	80002a50 <sys_pause+0x1a>
      release(&tickslock);
    80002ac2:	00015517          	auipc	a0,0x15
    80002ac6:	51650513          	addi	a0,a0,1302 # 80017fd8 <tickslock>
    80002aca:	a24fe0ef          	jal	80000cee <release>
      return -1;
    80002ace:	557d                	li	a0,-1
    80002ad0:	74a2                	ld	s1,40(sp)
    80002ad2:	7902                	ld	s2,32(sp)
    80002ad4:	69e2                	ld	s3,24(sp)
    80002ad6:	bff9                	j	80002ab4 <sys_pause+0x7e>

0000000080002ad8 <sys_kill>:

uint64
sys_kill(void)
{
    80002ad8:	1101                	addi	sp,sp,-32
    80002ada:	ec06                	sd	ra,24(sp)
    80002adc:	e822                	sd	s0,16(sp)
    80002ade:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    80002ae0:	fec40593          	addi	a1,s0,-20
    80002ae4:	4501                	li	a0,0
    80002ae6:	da5ff0ef          	jal	8000288a <argint>
  return kkill(pid);
    80002aea:	fec42503          	lw	a0,-20(s0)
    80002aee:	e42ff0ef          	jal	80002130 <kkill>
}
    80002af2:	60e2                	ld	ra,24(sp)
    80002af4:	6442                	ld	s0,16(sp)
    80002af6:	6105                	addi	sp,sp,32
    80002af8:	8082                	ret

0000000080002afa <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80002afa:	1101                	addi	sp,sp,-32
    80002afc:	ec06                	sd	ra,24(sp)
    80002afe:	e822                	sd	s0,16(sp)
    80002b00:	e426                	sd	s1,8(sp)
    80002b02:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80002b04:	00015517          	auipc	a0,0x15
    80002b08:	4d450513          	addi	a0,a0,1236 # 80017fd8 <tickslock>
    80002b0c:	94efe0ef          	jal	80000c5a <acquire>
  xticks = ticks;
    80002b10:	00007797          	auipc	a5,0x7
    80002b14:	5387a783          	lw	a5,1336(a5) # 8000a048 <ticks>
    80002b18:	84be                	mv	s1,a5
  release(&tickslock);
    80002b1a:	00015517          	auipc	a0,0x15
    80002b1e:	4be50513          	addi	a0,a0,1214 # 80017fd8 <tickslock>
    80002b22:	9ccfe0ef          	jal	80000cee <release>
  return xticks;
}
    80002b26:	02049513          	slli	a0,s1,0x20
    80002b2a:	9101                	srli	a0,a0,0x20
    80002b2c:	60e2                	ld	ra,24(sp)
    80002b2e:	6442                	ld	s0,16(sp)
    80002b30:	64a2                	ld	s1,8(sp)
    80002b32:	6105                	addi	sp,sp,32
    80002b34:	8082                	ret

0000000080002b36 <buf_lru_pos>:
  return (int)(b - bcache.buf);
}

static int
buf_lru_pos(struct buf *target)
{
    80002b36:	1141                	addi	sp,sp,-16
    80002b38:	e406                	sd	ra,8(sp)
    80002b3a:	e022                	sd	s0,0(sp)
    80002b3c:	0800                	addi	s0,sp,16
  int pos = 0;
  struct buf *b;

  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    80002b3e:	0001d797          	auipc	a5,0x1d
    80002b42:	76a7b783          	ld	a5,1898(a5) # 800202a8 <bcache+0x82b8>
    80002b46:	0001d697          	auipc	a3,0x1d
    80002b4a:	71268693          	addi	a3,a3,1810 # 80020258 <bcache+0x8268>
    80002b4e:	00d78f63          	beq	a5,a3,80002b6c <buf_lru_pos+0x36>
    80002b52:	872a                	mv	a4,a0
  int pos = 0;
    80002b54:	4501                	li	a0,0
    if(b == target)
    80002b56:	00f70763          	beq	a4,a5,80002b64 <buf_lru_pos+0x2e>
      return pos;
    pos++;
    80002b5a:	2505                	addiw	a0,a0,1
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    80002b5c:	6bbc                	ld	a5,80(a5)
    80002b5e:	fed79ce3          	bne	a5,a3,80002b56 <buf_lru_pos+0x20>
  }
  return -1;
    80002b62:	557d                	li	a0,-1
}
    80002b64:	60a2                	ld	ra,8(sp)
    80002b66:	6402                	ld	s0,0(sp)
    80002b68:	0141                	addi	sp,sp,16
    80002b6a:	8082                	ret
  return -1;
    80002b6c:	557d                	li	a0,-1
    80002b6e:	bfdd                	j	80002b64 <buf_lru_pos+0x2e>

0000000080002b70 <binit>:
{
    80002b70:	7179                	addi	sp,sp,-48
    80002b72:	f406                	sd	ra,40(sp)
    80002b74:	f022                	sd	s0,32(sp)
    80002b76:	ec26                	sd	s1,24(sp)
    80002b78:	e84a                	sd	s2,16(sp)
    80002b7a:	e44e                	sd	s3,8(sp)
    80002b7c:	e052                	sd	s4,0(sp)
    80002b7e:	1800                	addi	s0,sp,48
  initlock(&bcache.lock, "bcache");
    80002b80:	00007597          	auipc	a1,0x7
    80002b84:	80858593          	addi	a1,a1,-2040 # 80009388 <etext+0x388>
    80002b88:	00015517          	auipc	a0,0x15
    80002b8c:	46850513          	addi	a0,a0,1128 # 80017ff0 <bcache>
    80002b90:	840fe0ef          	jal	80000bd0 <initlock>
  bcache.head.prev = &bcache.head;
    80002b94:	0001d797          	auipc	a5,0x1d
    80002b98:	45c78793          	addi	a5,a5,1116 # 8001fff0 <bcache+0x8000>
    80002b9c:	0001d717          	auipc	a4,0x1d
    80002ba0:	6bc70713          	addi	a4,a4,1724 # 80020258 <bcache+0x8268>
    80002ba4:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80002ba8:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002bac:	00015497          	auipc	s1,0x15
    80002bb0:	45c48493          	addi	s1,s1,1116 # 80018008 <bcache+0x18>
    b->next = bcache.head.next;
    80002bb4:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80002bb6:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80002bb8:	00006a17          	auipc	s4,0x6
    80002bbc:	7d8a0a13          	addi	s4,s4,2008 # 80009390 <etext+0x390>
    b->next = bcache.head.next;
    80002bc0:	2b893783          	ld	a5,696(s2)
    80002bc4:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80002bc6:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80002bca:	85d2                	mv	a1,s4
    80002bcc:	01048513          	addi	a0,s1,16
    80002bd0:	0aa020ef          	jal	80004c7a <initsleeplock>
    bcache.head.next->prev = b;
    80002bd4:	2b893783          	ld	a5,696(s2)
    80002bd8:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80002bda:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002bde:	45848493          	addi	s1,s1,1112
    80002be2:	fd349fe3          	bne	s1,s3,80002bc0 <binit+0x50>
}
    80002be6:	70a2                	ld	ra,40(sp)
    80002be8:	7402                	ld	s0,32(sp)
    80002bea:	64e2                	ld	s1,24(sp)
    80002bec:	6942                	ld	s2,16(sp)
    80002bee:	69a2                	ld	s3,8(sp)
    80002bf0:	6a02                	ld	s4,0(sp)
    80002bf2:	6145                	addi	sp,sp,48
    80002bf4:	8082                	ret

0000000080002bf6 <bread>:
{
    80002bf6:	7119                	addi	sp,sp,-128
    80002bf8:	fc86                	sd	ra,120(sp)
    80002bfa:	f8a2                	sd	s0,112(sp)
    80002bfc:	f4a6                	sd	s1,104(sp)
    80002bfe:	f0ca                	sd	s2,96(sp)
    80002c00:	ecce                	sd	s3,88(sp)
    80002c02:	e8d2                	sd	s4,80(sp)
    80002c04:	e4d6                	sd	s5,72(sp)
    80002c06:	e0da                	sd	s6,64(sp)
    80002c08:	fc5e                	sd	s7,56(sp)
    80002c0a:	f862                	sd	s8,48(sp)
    80002c0c:	f466                	sd	s9,40(sp)
    80002c0e:	f06a                	sd	s10,32(sp)
    80002c10:	ec6e                	sd	s11,24(sp)
    80002c12:	0100                	addi	s0,sp,128
    80002c14:	89aa                	mv	s3,a0
    80002c16:	8a2e                	mv	s4,a1
  fslog_bread_req(dev, blockno);
    80002c18:	498040ef          	jal	800070b0 <fslog_bread_req>
  acquire(&bcache.lock);
    80002c1c:	00015517          	auipc	a0,0x15
    80002c20:	3d450513          	addi	a0,a0,980 # 80017ff0 <bcache>
    80002c24:	836fe0ef          	jal	80000c5a <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    80002c28:	0001d497          	auipc	s1,0x1d
    80002c2c:	6804b483          	ld	s1,1664(s1) # 800202a8 <bcache+0x82b8>
    80002c30:	0001d797          	auipc	a5,0x1d
    80002c34:	62878793          	addi	a5,a5,1576 # 80020258 <bcache+0x8268>
    80002c38:	0cf48063          	beq	s1,a5,80002cf8 <bread+0x102>
  int step = 0;
    80002c3c:	4a81                	li	s5,0
  return (int)(b - bcache.buf);
    80002c3e:	00015d17          	auipc	s10,0x15
    80002c42:	3cad0d13          	addi	s10,s10,970 # 80018008 <bcache+0x18>
    80002c46:	705867b7          	lui	a5,0x70586
    80002c4a:	72378793          	addi	a5,a5,1827 # 70586723 <_entry-0xfa798dd>
    80002c4e:	3aef7c37          	lui	s8,0x3aef7
    80002c52:	ca9c0c13          	addi	s8,s8,-855 # 3aef6ca9 <_entry-0x45109357>
    80002c56:	1c02                	slli	s8,s8,0x20
    80002c58:	9c3e                	add	s8,s8,a5
    fslog_bget_scan(dev, blockno, buf_id(b),
    80002c5a:	4c85                	li	s9,1
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    80002c5c:	0001dd97          	auipc	s11,0x1d
    80002c60:	5fcd8d93          	addi	s11,s11,1532 # 80020258 <bcache+0x8268>
    80002c64:	a03d                	j	80002c92 <bread+0x9c>
    fslog_bget_scan(dev, blockno, buf_id(b),
    80002c66:	44d8                	lw	a4,12(s1)
    80002c68:	41470733          	sub	a4,a4,s4
    80002c6c:	00173713          	seqz	a4,a4
    80002c70:	e03a                	sd	a4,0(sp)
    80002c72:	88d6                	mv	a7,s5
    80002c74:	8866                	mv	a6,s9
    80002c76:	875e                	mv	a4,s7
    80002c78:	86da                	mv	a3,s6
    80002c7a:	864a                	mv	a2,s2
    80002c7c:	85d2                	mv	a1,s4
    80002c7e:	854e                	mv	a0,s3
    80002c80:	49a040ef          	jal	8000711a <fslog_bget_scan>
    if(b->dev == dev && b->blockno == blockno){
    80002c84:	449c                	lw	a5,8(s1)
    80002c86:	03378963          	beq	a5,s3,80002cb8 <bread+0xc2>
    step++;
    80002c8a:	2a85                	addiw	s5,s5,1
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    80002c8c:	68a4                	ld	s1,80(s1)
    80002c8e:	07b48563          	beq	s1,s11,80002cf8 <bread+0x102>
  return (int)(b - bcache.buf);
    80002c92:	41a48933          	sub	s2,s1,s10
    80002c96:	40395913          	srai	s2,s2,0x3
    80002c9a:	0389093b          	mulw	s2,s2,s8
    fslog_bget_scan(dev, blockno, buf_id(b),
    80002c9e:	0404ab03          	lw	s6,64(s1)
    80002ca2:	0004ab83          	lw	s7,0(s1)
    80002ca6:	8526                	mv	a0,s1
    80002ca8:	e8fff0ef          	jal	80002b36 <buf_lru_pos>
    80002cac:	87aa                	mv	a5,a0
    80002cae:	4494                	lw	a3,8(s1)
    80002cb0:	4701                	li	a4,0
    80002cb2:	fb369fe3          	bne	a3,s3,80002c70 <bread+0x7a>
    80002cb6:	bf45                	j	80002c66 <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    80002cb8:	44dc                	lw	a5,12(s1)
    80002cba:	fd4798e3          	bne	a5,s4,80002c8a <bread+0x94>
      int old_ref = b->refcnt;
    80002cbe:	0404ab03          	lw	s6,64(s1)
      int lru = buf_lru_pos(b);
    80002cc2:	8526                	mv	a0,s1
    80002cc4:	e73ff0ef          	jal	80002b36 <buf_lru_pos>
    80002cc8:	8aaa                	mv	s5,a0
      b->refcnt++;
    80002cca:	001b079b          	addiw	a5,s6,1
    80002cce:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002cd0:	00015517          	auipc	a0,0x15
    80002cd4:	32050513          	addi	a0,a0,800 # 80017ff0 <bcache>
    80002cd8:	816fe0ef          	jal	80000cee <release>
      acquiresleep(&b->lock);
    80002cdc:	01048513          	addi	a0,s1,16
    80002ce0:	7d1010ef          	jal	80004cb0 <acquiresleep>
      fslog_bget_hit(dev, blockno, buf_id(b),
    80002ce4:	8856                	mv	a6,s5
    80002ce6:	409c                	lw	a5,0(s1)
    80002ce8:	40b8                	lw	a4,64(s1)
    80002cea:	86da                	mv	a3,s6
    80002cec:	864a                	mv	a2,s2
    80002cee:	85d2                	mv	a1,s4
    80002cf0:	854e                	mv	a0,s3
    80002cf2:	4f8040ef          	jal	800071ea <fslog_bget_hit>
      return b;
    80002cf6:	a0f9                	j	80002dc4 <bread+0x1ce>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002cf8:	0001d497          	auipc	s1,0x1d
    80002cfc:	5a84b483          	ld	s1,1448(s1) # 800202a0 <bcache+0x82b0>
    80002d00:	0001d797          	auipc	a5,0x1d
    80002d04:	55878793          	addi	a5,a5,1368 # 80020258 <bcache+0x8268>
    80002d08:	06f48663          	beq	s1,a5,80002d74 <bread+0x17e>
  step = 0;
    80002d0c:	4a81                	li	s5,0
  return (int)(b - bcache.buf);
    80002d0e:	00015c17          	auipc	s8,0x15
    80002d12:	2fac0c13          	addi	s8,s8,762 # 80018008 <bcache+0x18>
    80002d16:	705867b7          	lui	a5,0x70586
    80002d1a:	72378793          	addi	a5,a5,1827 # 70586723 <_entry-0xfa798dd>
    80002d1e:	3aef7b37          	lui	s6,0x3aef7
    80002d22:	ca9b0b13          	addi	s6,s6,-855 # 3aef6ca9 <_entry-0x45109357>
    80002d26:	1b02                	slli	s6,s6,0x20
    80002d28:	9b3e                	add	s6,s6,a5
    fslog_bget_scan(dev, blockno, buf_id(b),
    80002d2a:	5bfd                	li	s7,-1
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002d2c:	0001dc97          	auipc	s9,0x1d
    80002d30:	52cc8c93          	addi	s9,s9,1324 # 80020258 <bcache+0x8268>
  return (int)(b - bcache.buf);
    80002d34:	41848933          	sub	s2,s1,s8
    80002d38:	40395913          	srai	s2,s2,0x3
    80002d3c:	0369093b          	mulw	s2,s2,s6
                    b->refcnt, b->valid, buf_lru_pos(b),
    80002d40:	0404ad03          	lw	s10,64(s1)
    fslog_bget_scan(dev, blockno, buf_id(b),
    80002d44:	0004ad83          	lw	s11,0(s1)
    80002d48:	8526                	mv	a0,s1
    80002d4a:	dedff0ef          	jal	80002b36 <buf_lru_pos>
    80002d4e:	87aa                	mv	a5,a0
    80002d50:	001d3713          	seqz	a4,s10
    80002d54:	e03a                	sd	a4,0(sp)
    80002d56:	88d6                	mv	a7,s5
    80002d58:	885e                	mv	a6,s7
    80002d5a:	876e                	mv	a4,s11
    80002d5c:	86ea                	mv	a3,s10
    80002d5e:	864a                	mv	a2,s2
    80002d60:	85d2                	mv	a1,s4
    80002d62:	854e                	mv	a0,s3
    80002d64:	3b6040ef          	jal	8000711a <fslog_bget_scan>
    if(b->refcnt == 0) {
    80002d68:	40bc                	lw	a5,64(s1)
    80002d6a:	cb99                	beqz	a5,80002d80 <bread+0x18a>
    step++;
    80002d6c:	2a85                	addiw	s5,s5,1
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002d6e:	64a4                	ld	s1,72(s1)
    80002d70:	fd9492e3          	bne	s1,s9,80002d34 <bread+0x13e>
  panic("bget: no buffers");
    80002d74:	00006517          	auipc	a0,0x6
    80002d78:	62450513          	addi	a0,a0,1572 # 80009398 <etext+0x398>
    80002d7c:	adbfd0ef          	jal	80000856 <panic>
      int old_block = b->blockno;
    80002d80:	00c4ab03          	lw	s6,12(s1)
      int old_valid = b->valid;
    80002d84:	0004ab83          	lw	s7,0(s1)
      int lru = buf_lru_pos(b);
    80002d88:	8526                	mv	a0,s1
    80002d8a:	dadff0ef          	jal	80002b36 <buf_lru_pos>
    80002d8e:	8aaa                	mv	s5,a0
      b->dev = dev;
    80002d90:	0134a423          	sw	s3,8(s1)
      b->blockno = blockno;
    80002d94:	0144a623          	sw	s4,12(s1)
      b->valid = 0;
    80002d98:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80002d9c:	4785                	li	a5,1
    80002d9e:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002da0:	00015517          	auipc	a0,0x15
    80002da4:	25050513          	addi	a0,a0,592 # 80017ff0 <bcache>
    80002da8:	f47fd0ef          	jal	80000cee <release>
      acquiresleep(&b->lock);
    80002dac:	01048513          	addi	a0,s1,16
    80002db0:	701010ef          	jal	80004cb0 <acquiresleep>
      fslog_bget_miss(dev, blockno, old_block, buf_id(b),
    80002db4:	87d6                	mv	a5,s5
    80002db6:	875e                	mv	a4,s7
    80002db8:	86ca                	mv	a3,s2
    80002dba:	865a                	mv	a2,s6
    80002dbc:	85d2                	mv	a1,s4
    80002dbe:	854e                	mv	a0,s3
    80002dc0:	4f0040ef          	jal	800072b0 <fslog_bget_miss>
  if(!b->valid) {
    80002dc4:	409c                	lw	a5,0(s1)
    80002dc6:	c38d                	beqz	a5,80002de8 <bread+0x1f2>
}
    80002dc8:	8526                	mv	a0,s1
    80002dca:	70e6                	ld	ra,120(sp)
    80002dcc:	7446                	ld	s0,112(sp)
    80002dce:	74a6                	ld	s1,104(sp)
    80002dd0:	7906                	ld	s2,96(sp)
    80002dd2:	69e6                	ld	s3,88(sp)
    80002dd4:	6a46                	ld	s4,80(sp)
    80002dd6:	6aa6                	ld	s5,72(sp)
    80002dd8:	6b06                	ld	s6,64(sp)
    80002dda:	7be2                	ld	s7,56(sp)
    80002ddc:	7c42                	ld	s8,48(sp)
    80002dde:	7ca2                	ld	s9,40(sp)
    80002de0:	7d02                	ld	s10,32(sp)
    80002de2:	6de2                	ld	s11,24(sp)
    80002de4:	6109                	addi	sp,sp,128
    80002de6:	8082                	ret
    virtio_disk_rw(b, 0);
    80002de8:	4581                	li	a1,0
    80002dea:	8526                	mv	a0,s1
    80002dec:	2c5030ef          	jal	800068b0 <virtio_disk_rw>
    b->valid = 1;
    80002df0:	4785                	li	a5,1
    80002df2:	c09c                	sw	a5,0(s1)
    fslog_bread_fill(b->dev, b->blockno, buf_id(b), b->refcnt, buf_lru_pos(b));
    80002df4:	8526                	mv	a0,s1
    80002df6:	d41ff0ef          	jal	80002b36 <buf_lru_pos>
    80002dfa:	872a                	mv	a4,a0
  return (int)(b - bcache.buf);
    80002dfc:	00015617          	auipc	a2,0x15
    80002e00:	20c60613          	addi	a2,a2,524 # 80018008 <bcache+0x18>
    80002e04:	40c48633          	sub	a2,s1,a2
    80002e08:	860d                	srai	a2,a2,0x3
    80002e0a:	705866b7          	lui	a3,0x70586
    80002e0e:	72368693          	addi	a3,a3,1827 # 70586723 <_entry-0xfa798dd>
    80002e12:	3aef77b7          	lui	a5,0x3aef7
    80002e16:	ca978793          	addi	a5,a5,-855 # 3aef6ca9 <_entry-0x45109357>
    80002e1a:	1782                	slli	a5,a5,0x20
    80002e1c:	97b6                	add	a5,a5,a3
    fslog_bread_fill(b->dev, b->blockno, buf_id(b), b->refcnt, buf_lru_pos(b));
    80002e1e:	40b4                	lw	a3,64(s1)
    80002e20:	02f6063b          	mulw	a2,a2,a5
    80002e24:	44cc                	lw	a1,12(s1)
    80002e26:	4488                	lw	a0,8(s1)
    80002e28:	548040ef          	jal	80007370 <fslog_bread_fill>
  return b;
    80002e2c:	bf71                	j	80002dc8 <bread+0x1d2>

0000000080002e2e <bwrite>:
{
    80002e2e:	1101                	addi	sp,sp,-32
    80002e30:	ec06                	sd	ra,24(sp)
    80002e32:	e822                	sd	s0,16(sp)
    80002e34:	e426                	sd	s1,8(sp)
    80002e36:	e04a                	sd	s2,0(sp)
    80002e38:	1000                	addi	s0,sp,32
    80002e3a:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80002e3c:	0541                	addi	a0,a0,16
    80002e3e:	6f1010ef          	jal	80004d2e <holdingsleep>
    80002e42:	c931                	beqz	a0,80002e96 <bwrite+0x68>
  virtio_disk_rw(b, 1);
    80002e44:	4585                	li	a1,1
    80002e46:	8526                	mv	a0,s1
    80002e48:	269030ef          	jal	800068b0 <virtio_disk_rw>
  fslog_bwrite_ev(b->dev, b->blockno, buf_id(b),
    80002e4c:	0004a903          	lw	s2,0(s1)
    80002e50:	8526                	mv	a0,s1
    80002e52:	ce5ff0ef          	jal	80002b36 <buf_lru_pos>
    80002e56:	87aa                	mv	a5,a0
  return (int)(b - bcache.buf);
    80002e58:	00015597          	auipc	a1,0x15
    80002e5c:	1b058593          	addi	a1,a1,432 # 80018008 <bcache+0x18>
    80002e60:	40b485b3          	sub	a1,s1,a1
    80002e64:	858d                	srai	a1,a1,0x3
    80002e66:	70586737          	lui	a4,0x70586
    80002e6a:	72370713          	addi	a4,a4,1827 # 70586723 <_entry-0xfa798dd>
    80002e6e:	3aef7637          	lui	a2,0x3aef7
    80002e72:	ca960613          	addi	a2,a2,-855 # 3aef6ca9 <_entry-0x45109357>
    80002e76:	1602                	slli	a2,a2,0x20
    80002e78:	963a                	add	a2,a2,a4
  fslog_bwrite_ev(b->dev, b->blockno, buf_id(b),
    80002e7a:	874a                	mv	a4,s2
    80002e7c:	40b4                	lw	a3,64(s1)
    80002e7e:	02c5863b          	mulw	a2,a1,a2
    80002e82:	44cc                	lw	a1,12(s1)
    80002e84:	4488                	lw	a0,8(s1)
    80002e86:	598040ef          	jal	8000741e <fslog_bwrite_ev>
}
    80002e8a:	60e2                	ld	ra,24(sp)
    80002e8c:	6442                	ld	s0,16(sp)
    80002e8e:	64a2                	ld	s1,8(sp)
    80002e90:	6902                	ld	s2,0(sp)
    80002e92:	6105                	addi	sp,sp,32
    80002e94:	8082                	ret
    panic("bwrite");
    80002e96:	00006517          	auipc	a0,0x6
    80002e9a:	51a50513          	addi	a0,a0,1306 # 800093b0 <etext+0x3b0>
    80002e9e:	9b9fd0ef          	jal	80000856 <panic>

0000000080002ea2 <brelse>:
{
    80002ea2:	715d                	addi	sp,sp,-80
    80002ea4:	e486                	sd	ra,72(sp)
    80002ea6:	e0a2                	sd	s0,64(sp)
    80002ea8:	fc26                	sd	s1,56(sp)
    80002eaa:	f84a                	sd	s2,48(sp)
    80002eac:	f44e                	sd	s3,40(sp)
    80002eae:	f052                	sd	s4,32(sp)
    80002eb0:	ec56                	sd	s5,24(sp)
    80002eb2:	e85a                	sd	s6,16(sp)
    80002eb4:	e45e                	sd	s7,8(sp)
    80002eb6:	e062                	sd	s8,0(sp)
    80002eb8:	0880                	addi	s0,sp,80
    80002eba:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80002ebc:	01050913          	addi	s2,a0,16
    80002ec0:	854a                	mv	a0,s2
    80002ec2:	66d010ef          	jal	80004d2e <holdingsleep>
    80002ec6:	c179                	beqz	a0,80002f8c <brelse+0xea>
  old_ref = b->refcnt;
    80002ec8:	40bc                	lw	a5,64(s1)
    80002eca:	8bbe                	mv	s7,a5
  old_lru = buf_lru_pos(b);
    80002ecc:	8526                	mv	a0,s1
    80002ece:	c69ff0ef          	jal	80002b36 <buf_lru_pos>
    80002ed2:	8c2a                	mv	s8,a0
  releasesleep(&b->lock);
    80002ed4:	854a                	mv	a0,s2
    80002ed6:	621010ef          	jal	80004cf6 <releasesleep>
  acquire(&bcache.lock);
    80002eda:	00015517          	auipc	a0,0x15
    80002ede:	11650513          	addi	a0,a0,278 # 80017ff0 <bcache>
    80002ee2:	d79fd0ef          	jal	80000c5a <acquire>
  b->refcnt--;
    80002ee6:	40bc                	lw	a5,64(s1)
    80002ee8:	37fd                	addiw	a5,a5,-1
    80002eea:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    80002eec:	e79d                	bnez	a5,80002f1a <brelse+0x78>
    b->next->prev = b->prev;
    80002eee:	68b8                	ld	a4,80(s1)
    80002ef0:	64bc                	ld	a5,72(s1)
    80002ef2:	e73c                	sd	a5,72(a4)
    b->prev->next = b->next;
    80002ef4:	68b8                	ld	a4,80(s1)
    80002ef6:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    80002ef8:	0001d797          	auipc	a5,0x1d
    80002efc:	0f878793          	addi	a5,a5,248 # 8001fff0 <bcache+0x8000>
    80002f00:	2b87b703          	ld	a4,696(a5)
    80002f04:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    80002f06:	0001d717          	auipc	a4,0x1d
    80002f0a:	35270713          	addi	a4,a4,850 # 80020258 <bcache+0x8268>
    80002f0e:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    80002f10:	2b87b703          	ld	a4,696(a5)
    80002f14:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80002f16:	2a97bc23          	sd	s1,696(a5)
  new_ref = b->refcnt;
    80002f1a:	0404a983          	lw	s3,64(s1)
  new_lru = buf_lru_pos(b);
    80002f1e:	8526                	mv	a0,s1
    80002f20:	c17ff0ef          	jal	80002b36 <buf_lru_pos>
    80002f24:	8b2a                	mv	s6,a0
  dev_now = b->dev;
    80002f26:	0084a903          	lw	s2,8(s1)
  blockno_now = b->blockno;
    80002f2a:	00c4aa03          	lw	s4,12(s1)
  valid_now = b->valid;
    80002f2e:	0004aa83          	lw	s5,0(s1)
  release(&bcache.lock);
    80002f32:	00015517          	auipc	a0,0x15
    80002f36:	0be50513          	addi	a0,a0,190 # 80017ff0 <bcache>
    80002f3a:	db5fd0ef          	jal	80000cee <release>
  return (int)(b - bcache.buf);
    80002f3e:	00015797          	auipc	a5,0x15
    80002f42:	0ca78793          	addi	a5,a5,202 # 80018008 <bcache+0x18>
    80002f46:	8c9d                	sub	s1,s1,a5
    80002f48:	848d                	srai	s1,s1,0x3
    80002f4a:	705867b7          	lui	a5,0x70586
    80002f4e:	72378793          	addi	a5,a5,1827 # 70586723 <_entry-0xfa798dd>
    80002f52:	3aef7637          	lui	a2,0x3aef7
    80002f56:	ca960613          	addi	a2,a2,-855 # 3aef6ca9 <_entry-0x45109357>
    80002f5a:	1602                	slli	a2,a2,0x20
    80002f5c:	963e                	add	a2,a2,a5
  fslog_brelease_ev(dev_now, blockno_now, bufid_now,
    80002f5e:	88da                	mv	a7,s6
    80002f60:	8862                	mv	a6,s8
    80002f62:	87d6                	mv	a5,s5
    80002f64:	874e                	mv	a4,s3
    80002f66:	86de                	mv	a3,s7
    80002f68:	02c4863b          	mulw	a2,s1,a2
    80002f6c:	85d2                	mv	a1,s4
    80002f6e:	854a                	mv	a0,s2
    80002f70:	566040ef          	jal	800074d6 <fslog_brelease_ev>
}
    80002f74:	60a6                	ld	ra,72(sp)
    80002f76:	6406                	ld	s0,64(sp)
    80002f78:	74e2                	ld	s1,56(sp)
    80002f7a:	7942                	ld	s2,48(sp)
    80002f7c:	79a2                	ld	s3,40(sp)
    80002f7e:	7a02                	ld	s4,32(sp)
    80002f80:	6ae2                	ld	s5,24(sp)
    80002f82:	6b42                	ld	s6,16(sp)
    80002f84:	6ba2                	ld	s7,8(sp)
    80002f86:	6c02                	ld	s8,0(sp)
    80002f88:	6161                	addi	sp,sp,80
    80002f8a:	8082                	ret
    panic("brelse");
    80002f8c:	00006517          	auipc	a0,0x6
    80002f90:	42c50513          	addi	a0,a0,1068 # 800093b8 <etext+0x3b8>
    80002f94:	8c3fd0ef          	jal	80000856 <panic>

0000000080002f98 <bpin>:
bpin(struct buf *b) {
    80002f98:	1101                	addi	sp,sp,-32
    80002f9a:	ec06                	sd	ra,24(sp)
    80002f9c:	e822                	sd	s0,16(sp)
    80002f9e:	e426                	sd	s1,8(sp)
    80002fa0:	1000                	addi	s0,sp,32
    80002fa2:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80002fa4:	00015517          	auipc	a0,0x15
    80002fa8:	04c50513          	addi	a0,a0,76 # 80017ff0 <bcache>
    80002fac:	caffd0ef          	jal	80000c5a <acquire>
  b->refcnt++;
    80002fb0:	40bc                	lw	a5,64(s1)
    80002fb2:	2785                	addiw	a5,a5,1
    80002fb4:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80002fb6:	00015517          	auipc	a0,0x15
    80002fba:	03a50513          	addi	a0,a0,58 # 80017ff0 <bcache>
    80002fbe:	d31fd0ef          	jal	80000cee <release>
}
    80002fc2:	60e2                	ld	ra,24(sp)
    80002fc4:	6442                	ld	s0,16(sp)
    80002fc6:	64a2                	ld	s1,8(sp)
    80002fc8:	6105                	addi	sp,sp,32
    80002fca:	8082                	ret

0000000080002fcc <bunpin>:
bunpin(struct buf *b) {
    80002fcc:	1101                	addi	sp,sp,-32
    80002fce:	ec06                	sd	ra,24(sp)
    80002fd0:	e822                	sd	s0,16(sp)
    80002fd2:	e426                	sd	s1,8(sp)
    80002fd4:	1000                	addi	s0,sp,32
    80002fd6:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80002fd8:	00015517          	auipc	a0,0x15
    80002fdc:	01850513          	addi	a0,a0,24 # 80017ff0 <bcache>
    80002fe0:	c7bfd0ef          	jal	80000c5a <acquire>
  b->refcnt--;
    80002fe4:	40bc                	lw	a5,64(s1)
    80002fe6:	37fd                	addiw	a5,a5,-1
    80002fe8:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80002fea:	00015517          	auipc	a0,0x15
    80002fee:	00650513          	addi	a0,a0,6 # 80017ff0 <bcache>
    80002ff2:	cfdfd0ef          	jal	80000cee <release>
}
    80002ff6:	60e2                	ld	ra,24(sp)
    80002ff8:	6442                	ld	s0,16(sp)
    80002ffa:	64a2                	ld	s1,8(sp)
    80002ffc:	6105                	addi	sp,sp,32
    80002ffe:	8082                	ret

0000000080003000 <dir_report>:
    struct inode *dp,
    char *name,
    uint target,
    uint off,
    char *details
){
    80003000:	dc010113          	addi	sp,sp,-576
    80003004:	22113c23          	sd	ra,568(sp)
    80003008:	22813823          	sd	s0,560(sp)
    8000300c:	22913423          	sd	s1,552(sp)
    80003010:	23213023          	sd	s2,544(sp)
    80003014:	21313c23          	sd	s3,536(sp)
    80003018:	21413823          	sd	s4,528(sp)
    8000301c:	21513423          	sd	s5,520(sp)
    80003020:	21613023          	sd	s6,512(sp)
    80003024:	0480                	addi	s0,sp,576
    80003026:	892a                	mv	s2,a0
    80003028:	84ae                	mv	s1,a1
    8000302a:	89b2                	mv	s3,a2
    8000302c:	8a36                	mv	s4,a3
    8000302e:	8aba                	mv	s5,a4
    80003030:	8b3e                	mv	s6,a5
    struct fs_event e;

    memset(&e, 0, sizeof(e));
    80003032:	20000613          	li	a2,512
    80003036:	4581                	li	a1,0
    80003038:	dc040513          	addi	a0,s0,-576
    8000303c:	ceffd0ef          	jal	80000d2a <memset>

    e.ticks = ticks;
    80003040:	00007797          	auipc	a5,0x7
    80003044:	0087a783          	lw	a5,8(a5) # 8000a048 <ticks>
    80003048:	dcf42423          	sw	a5,-568(s0)
    e.pid = myproc() ? myproc()->pid : 0;
    8000304c:	91dfe0ef          	jal	80001968 <myproc>
    80003050:	4781                	li	a5,0
    80003052:	c501                	beqz	a0,8000305a <dir_report+0x5a>
    80003054:	915fe0ef          	jal	80001968 <myproc>
    80003058:	591c                	lw	a5,48(a0)
    8000305a:	dcf42623          	sw	a5,-564(s0)

    e.type = LAYER_DIR;
    8000305e:	4795                	li	a5,5
    80003060:	dcf42823          	sw	a5,-560(s0)

    safestrcpy(e.op_name, op, sizeof(e.op_name));
    80003064:	4641                	li	a2,16
    80003066:	85ca                	mv	a1,s2
    80003068:	dd440513          	addi	a0,s0,-556
    8000306c:	e13fd0ef          	jal	80000e7e <safestrcpy>

    if(name)
    80003070:	00098863          	beqz	s3,80003080 <dir_report+0x80>
        safestrcpy(e.dir.name, name, sizeof(e.dir.name));
    80003074:	4651                	li	a2,20
    80003076:	85ce                	mv	a1,s3
    80003078:	fa040513          	addi	a0,s0,-96
    8000307c:	e03fd0ef          	jal	80000e7e <safestrcpy>

    e.dir.parent_inum = dp ? dp->inum : -1;
    80003080:	57fd                	li	a5,-1
    80003082:	c091                	beqz	s1,80003086 <dir_report+0x86>
    80003084:	40dc                	lw	a5,4(s1)
    80003086:	faf42a23          	sw	a5,-76(s0)
    e.dir.target_inum = target;
    8000308a:	fb442c23          	sw	s4,-72(s0)
    e.dir.offset = off;
    8000308e:	fb542e23          	sw	s5,-68(s0)

    safestrcpy(e.details, details, sizeof(e.details));
    80003092:	08000613          	li	a2,128
    80003096:	85da                	mv	a1,s6
    80003098:	de440513          	addi	a0,s0,-540
    8000309c:	de3fd0ef          	jal	80000e7e <safestrcpy>

    fslog_push(&e);
    800030a0:	dc040513          	addi	a0,s0,-576
    800030a4:	71b030ef          	jal	80006fbe <fslog_push>
}
    800030a8:	23813083          	ld	ra,568(sp)
    800030ac:	23013403          	ld	s0,560(sp)
    800030b0:	22813483          	ld	s1,552(sp)
    800030b4:	22013903          	ld	s2,544(sp)
    800030b8:	21813983          	ld	s3,536(sp)
    800030bc:	21013a03          	ld	s4,528(sp)
    800030c0:	20813a83          	ld	s5,520(sp)
    800030c4:	20013b03          	ld	s6,512(sp)
    800030c8:	24010113          	addi	sp,sp,576
    800030cc:	8082                	ret

00000000800030ce <path_report>:
    char *op,
    char *path,
    char *elem,
    struct inode *ip,
    char *details
){
    800030ce:	dc010113          	addi	sp,sp,-576
    800030d2:	22113c23          	sd	ra,568(sp)
    800030d6:	22813823          	sd	s0,560(sp)
    800030da:	22913423          	sd	s1,552(sp)
    800030de:	23213023          	sd	s2,544(sp)
    800030e2:	21313c23          	sd	s3,536(sp)
    800030e6:	21413823          	sd	s4,528(sp)
    800030ea:	21513423          	sd	s5,520(sp)
    800030ee:	0480                	addi	s0,sp,576
    800030f0:	892a                	mv	s2,a0
    800030f2:	89ae                	mv	s3,a1
    800030f4:	8a32                	mv	s4,a2
    800030f6:	84b6                	mv	s1,a3
    800030f8:	8aba                	mv	s5,a4
    struct fs_event e;

    memset(&e, 0, sizeof(e));
    800030fa:	20000613          	li	a2,512
    800030fe:	4581                	li	a1,0
    80003100:	dc040513          	addi	a0,s0,-576
    80003104:	c27fd0ef          	jal	80000d2a <memset>

    e.ticks = ticks;
    80003108:	00007797          	auipc	a5,0x7
    8000310c:	f407a783          	lw	a5,-192(a5) # 8000a048 <ticks>
    80003110:	dcf42423          	sw	a5,-568(s0)
    e.pid = myproc() ? myproc()->pid : 0;
    80003114:	855fe0ef          	jal	80001968 <myproc>
    80003118:	4781                	li	a5,0
    8000311a:	c501                	beqz	a0,80003122 <path_report+0x54>
    8000311c:	84dfe0ef          	jal	80001968 <myproc>
    80003120:	591c                	lw	a5,48(a0)
    80003122:	dcf42623          	sw	a5,-564(s0)

    e.type = LAYER_PATH;
    80003126:	4799                	li	a5,6
    80003128:	dcf42823          	sw	a5,-560(s0)

    safestrcpy(e.op_name, op, sizeof(e.op_name));
    8000312c:	4641                	li	a2,16
    8000312e:	85ca                	mv	a1,s2
    80003130:	dd440513          	addi	a0,s0,-556
    80003134:	d4bfd0ef          	jal	80000e7e <safestrcpy>

    if(path)
    80003138:	00098963          	beqz	s3,8000314a <path_report+0x7c>
        safestrcpy(e.dir.path, path, sizeof(e.dir.path));
    8000313c:	08000613          	li	a2,128
    80003140:	85ce                	mv	a1,s3
    80003142:	f2040513          	addi	a0,s0,-224
    80003146:	d39fd0ef          	jal	80000e7e <safestrcpy>

    if(elem)
    8000314a:	000a0863          	beqz	s4,8000315a <path_report+0x8c>
        safestrcpy(e.dir.name, elem, sizeof(e.dir.name));
    8000314e:	4651                	li	a2,20
    80003150:	85d2                	mv	a1,s4
    80003152:	fa040513          	addi	a0,s0,-96
    80003156:	d29fd0ef          	jal	80000e7e <safestrcpy>

    e.dir.parent_inum = ip ? ip->inum : -1;
    8000315a:	57fd                	li	a5,-1
    8000315c:	c091                	beqz	s1,80003160 <path_report+0x92>
    8000315e:	40dc                	lw	a5,4(s1)
    80003160:	faf42a23          	sw	a5,-76(s0)

    safestrcpy(e.details, details, sizeof(e.details));
    80003164:	08000613          	li	a2,128
    80003168:	85d6                	mv	a1,s5
    8000316a:	de440513          	addi	a0,s0,-540
    8000316e:	d11fd0ef          	jal	80000e7e <safestrcpy>

    fslog_push(&e);
    80003172:	dc040513          	addi	a0,s0,-576
    80003176:	649030ef          	jal	80006fbe <fslog_push>
}
    8000317a:	23813083          	ld	ra,568(sp)
    8000317e:	23013403          	ld	s0,560(sp)
    80003182:	22813483          	ld	s1,552(sp)
    80003186:	22013903          	ld	s2,544(sp)
    8000318a:	21813983          	ld	s3,536(sp)
    8000318e:	21013a03          	ld	s4,528(sp)
    80003192:	20813a83          	ld	s5,520(sp)
    80003196:	24010113          	addi	sp,sp,576
    8000319a:	8082                	ret

000000008000319c <balloc_report>:
void balloc_report(char* op, int blockno, int old_bit, int new_bit, char* det) {
    8000319c:	dc010113          	addi	sp,sp,-576
    800031a0:	22113c23          	sd	ra,568(sp)
    800031a4:	22813823          	sd	s0,560(sp)
    800031a8:	22913423          	sd	s1,552(sp)
    800031ac:	23213023          	sd	s2,544(sp)
    800031b0:	21313c23          	sd	s3,536(sp)
    800031b4:	21413823          	sd	s4,528(sp)
    800031b8:	21513423          	sd	s5,520(sp)
    800031bc:	0480                	addi	s0,sp,576
    800031be:	84aa                	mv	s1,a0
    800031c0:	892e                	mv	s2,a1
    800031c2:	89b2                	mv	s3,a2
    800031c4:	8a36                	mv	s4,a3
    800031c6:	8aba                	mv	s5,a4
    memset(&e, 0, sizeof(e));
    800031c8:	20000613          	li	a2,512
    800031cc:	4581                	li	a1,0
    800031ce:	dc040513          	addi	a0,s0,-576
    800031d2:	b59fd0ef          	jal	80000d2a <memset>
    e.ticks = ticks;
    800031d6:	00007797          	auipc	a5,0x7
    800031da:	e727a783          	lw	a5,-398(a5) # 8000a048 <ticks>
    800031de:	dcf42423          	sw	a5,-568(s0)
    e.pid = myproc() ? myproc()->pid : 0;
    800031e2:	f86fe0ef          	jal	80001968 <myproc>
    800031e6:	4781                	li	a5,0
    800031e8:	c501                	beqz	a0,800031f0 <balloc_report+0x54>
    800031ea:	f7efe0ef          	jal	80001968 <myproc>
    800031ee:	591c                	lw	a5,48(a0)
    800031f0:	dcf42623          	sw	a5,-564(s0)
    e.type = LAYER_BALLOC;
    800031f4:	478d                	li	a5,3
    800031f6:	dcf42823          	sw	a5,-560(s0)
    safestrcpy(e.op_name, op, 16);
    800031fa:	4641                	li	a2,16
    800031fc:	85a6                	mv	a1,s1
    800031fe:	dd440513          	addi	a0,s0,-556
    80003202:	c7dfd0ef          	jal	80000e7e <safestrcpy>
    e.balloc.blockno = blockno;
    80003206:	f3242023          	sw	s2,-224(s0)
    e.balloc.old_bit = old_bit;
    8000320a:	f3342423          	sw	s3,-216(s0)
    e.balloc.bit = new_bit;
    8000320e:	f3442223          	sw	s4,-220(s0)
    safestrcpy(e.details, det, 128);
    80003212:	08000613          	li	a2,128
    80003216:	85d6                	mv	a1,s5
    80003218:	de440513          	addi	a0,s0,-540
    8000321c:	c63fd0ef          	jal	80000e7e <safestrcpy>
    fslog_push(&e);
    80003220:	dc040513          	addi	a0,s0,-576
    80003224:	59b030ef          	jal	80006fbe <fslog_push>
}
    80003228:	23813083          	ld	ra,568(sp)
    8000322c:	23013403          	ld	s0,560(sp)
    80003230:	22813483          	ld	s1,552(sp)
    80003234:	22013903          	ld	s2,544(sp)
    80003238:	21813983          	ld	s3,536(sp)
    8000323c:	21013a03          	ld	s4,528(sp)
    80003240:	20813a83          	ld	s5,520(sp)
    80003244:	24010113          	addi	sp,sp,576
    80003248:	8082                	ret

000000008000324a <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    8000324a:	1101                	addi	sp,sp,-32
    8000324c:	ec06                	sd	ra,24(sp)
    8000324e:	e822                	sd	s0,16(sp)
    80003250:	e426                	sd	s1,8(sp)
    80003252:	e04a                	sd	s2,0(sp)
    80003254:	1000                	addi	s0,sp,32
    80003256:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    80003258:	00d5d79b          	srliw	a5,a1,0xd
    8000325c:	0001d597          	auipc	a1,0x1d
    80003260:	4705a583          	lw	a1,1136(a1) # 800206cc <sb+0x1c>
    80003264:	9dbd                	addw	a1,a1,a5
    80003266:	991ff0ef          	jal	80002bf6 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    8000326a:	0074f793          	andi	a5,s1,7
    8000326e:	4705                	li	a4,1
    80003270:	00f7173b          	sllw	a4,a4,a5
  bi = b % BPB;
    80003274:	03349793          	slli	a5,s1,0x33
  if((bp->data[bi/8] & m) == 0)
    80003278:	93d9                	srli	a5,a5,0x36
    8000327a:	00f506b3          	add	a3,a0,a5
    8000327e:	0586c683          	lbu	a3,88(a3)
    80003282:	00d77633          	and	a2,a4,a3
    80003286:	c229                	beqz	a2,800032c8 <bfree+0x7e>
    80003288:	892a                	mv	s2,a0
    panic("freeing free block");
  int old_bit = 1;
  bp->data[bi/8] &= ~m;
    8000328a:	97aa                	add	a5,a5,a0
    8000328c:	fff74713          	not	a4,a4
    80003290:	8ef9                	and	a3,a3,a4
    80003292:	04d78c23          	sb	a3,88(a5)
  balloc_report("BFREE", b, old_bit, 0, "Freed block");
    80003296:	00006717          	auipc	a4,0x6
    8000329a:	14270713          	addi	a4,a4,322 # 800093d8 <etext+0x3d8>
    8000329e:	4681                	li	a3,0
    800032a0:	4605                	li	a2,1
    800032a2:	85a6                	mv	a1,s1
    800032a4:	00006517          	auipc	a0,0x6
    800032a8:	14450513          	addi	a0,a0,324 # 800093e8 <etext+0x3e8>
    800032ac:	ef1ff0ef          	jal	8000319c <balloc_report>
  log_write(bp);
    800032b0:	854a                	mv	a0,s2
    800032b2:	0df010ef          	jal	80004b90 <log_write>
  brelse(bp);
    800032b6:	854a                	mv	a0,s2
    800032b8:	bebff0ef          	jal	80002ea2 <brelse>
}
    800032bc:	60e2                	ld	ra,24(sp)
    800032be:	6442                	ld	s0,16(sp)
    800032c0:	64a2                	ld	s1,8(sp)
    800032c2:	6902                	ld	s2,0(sp)
    800032c4:	6105                	addi	sp,sp,32
    800032c6:	8082                	ret
    panic("freeing free block");
    800032c8:	00006517          	auipc	a0,0x6
    800032cc:	0f850513          	addi	a0,a0,248 # 800093c0 <etext+0x3c0>
    800032d0:	d86fd0ef          	jal	80000856 <panic>

00000000800032d4 <balloc>:
{
    800032d4:	715d                	addi	sp,sp,-80
    800032d6:	e486                	sd	ra,72(sp)
    800032d8:	e0a2                	sd	s0,64(sp)
    800032da:	fc26                	sd	s1,56(sp)
    800032dc:	0880                	addi	s0,sp,80
  for(b = 0; b < sb.size; b += BPB){
    800032de:	0001d797          	auipc	a5,0x1d
    800032e2:	3d67a783          	lw	a5,982(a5) # 800206b4 <sb+0x4>
    800032e6:	0e078f63          	beqz	a5,800033e4 <balloc+0x110>
    800032ea:	f84a                	sd	s2,48(sp)
    800032ec:	f44e                	sd	s3,40(sp)
    800032ee:	f052                	sd	s4,32(sp)
    800032f0:	ec56                	sd	s5,24(sp)
    800032f2:	e85a                	sd	s6,16(sp)
    800032f4:	e45e                	sd	s7,8(sp)
    800032f6:	e062                	sd	s8,0(sp)
    800032f8:	8baa                	mv	s7,a0
    800032fa:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    800032fc:	0001db17          	auipc	s6,0x1d
    80003300:	3b4b0b13          	addi	s6,s6,948 # 800206b0 <sb>
      m = 1 << (bi % 8);
    80003304:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003306:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    80003308:	6c09                	lui	s8,0x2
    8000330a:	a041                	j	8000338a <balloc+0xb6>
        bp->data[bi/8] |= m;  // Mark block in use.
    8000330c:	97ca                	add	a5,a5,s2
    8000330e:	8e55                	or	a2,a2,a3
    80003310:	04c78c23          	sb	a2,88(a5)
        balloc_report("BALLOC", b + bi, old_bit, 1, "Allocated block");
    80003314:	00006717          	auipc	a4,0x6
    80003318:	0dc70713          	addi	a4,a4,220 # 800093f0 <etext+0x3f0>
    8000331c:	4685                	li	a3,1
    8000331e:	4601                	li	a2,0
    80003320:	85a6                	mv	a1,s1
    80003322:	00006517          	auipc	a0,0x6
    80003326:	0de50513          	addi	a0,a0,222 # 80009400 <etext+0x400>
    8000332a:	e73ff0ef          	jal	8000319c <balloc_report>
        log_write(bp);
    8000332e:	854a                	mv	a0,s2
    80003330:	061010ef          	jal	80004b90 <log_write>
        brelse(bp);
    80003334:	854a                	mv	a0,s2
    80003336:	b6dff0ef          	jal	80002ea2 <brelse>
  bp = bread(dev, bno);
    8000333a:	85a6                	mv	a1,s1
    8000333c:	855e                	mv	a0,s7
    8000333e:	8b9ff0ef          	jal	80002bf6 <bread>
    80003342:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    80003344:	40000613          	li	a2,1024
    80003348:	4581                	li	a1,0
    8000334a:	05850513          	addi	a0,a0,88
    8000334e:	9ddfd0ef          	jal	80000d2a <memset>
  log_write(bp);
    80003352:	854a                	mv	a0,s2
    80003354:	03d010ef          	jal	80004b90 <log_write>
  brelse(bp);
    80003358:	854a                	mv	a0,s2
    8000335a:	b49ff0ef          	jal	80002ea2 <brelse>
}
    8000335e:	7942                	ld	s2,48(sp)
    80003360:	79a2                	ld	s3,40(sp)
    80003362:	7a02                	ld	s4,32(sp)
    80003364:	6ae2                	ld	s5,24(sp)
    80003366:	6b42                	ld	s6,16(sp)
    80003368:	6ba2                	ld	s7,8(sp)
    8000336a:	6c02                	ld	s8,0(sp)
}
    8000336c:	8526                	mv	a0,s1
    8000336e:	60a6                	ld	ra,72(sp)
    80003370:	6406                	ld	s0,64(sp)
    80003372:	74e2                	ld	s1,56(sp)
    80003374:	6161                	addi	sp,sp,80
    80003376:	8082                	ret
    brelse(bp);
    80003378:	854a                	mv	a0,s2
    8000337a:	b29ff0ef          	jal	80002ea2 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    8000337e:	015c0abb          	addw	s5,s8,s5
    80003382:	004b2783          	lw	a5,4(s6)
    80003386:	04faf863          	bgeu	s5,a5,800033d6 <balloc+0x102>
    bp = bread(dev, BBLOCK(b, sb));
    8000338a:	40dad59b          	sraiw	a1,s5,0xd
    8000338e:	01cb2783          	lw	a5,28(s6)
    80003392:	9dbd                	addw	a1,a1,a5
    80003394:	855e                	mv	a0,s7
    80003396:	861ff0ef          	jal	80002bf6 <bread>
    8000339a:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000339c:	004b2503          	lw	a0,4(s6)
    800033a0:	84d6                	mv	s1,s5
    800033a2:	4701                	li	a4,0
    800033a4:	fca4fae3          	bgeu	s1,a0,80003378 <balloc+0xa4>
      m = 1 << (bi % 8);
    800033a8:	00777693          	andi	a3,a4,7
    800033ac:	00d996bb          	sllw	a3,s3,a3
      if((bp->data[bi/8] & m) == 0){
    800033b0:	41f7579b          	sraiw	a5,a4,0x1f
    800033b4:	01d7d79b          	srliw	a5,a5,0x1d
    800033b8:	9fb9                	addw	a5,a5,a4
    800033ba:	4037d79b          	sraiw	a5,a5,0x3
    800033be:	00f90633          	add	a2,s2,a5
    800033c2:	05864603          	lbu	a2,88(a2)
    800033c6:	00c6f5b3          	and	a1,a3,a2
    800033ca:	d1a9                	beqz	a1,8000330c <balloc+0x38>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800033cc:	2705                	addiw	a4,a4,1
    800033ce:	2485                	addiw	s1,s1,1
    800033d0:	fd471ae3          	bne	a4,s4,800033a4 <balloc+0xd0>
    800033d4:	b755                	j	80003378 <balloc+0xa4>
    800033d6:	7942                	ld	s2,48(sp)
    800033d8:	79a2                	ld	s3,40(sp)
    800033da:	7a02                	ld	s4,32(sp)
    800033dc:	6ae2                	ld	s5,24(sp)
    800033de:	6b42                	ld	s6,16(sp)
    800033e0:	6ba2                	ld	s7,8(sp)
    800033e2:	6c02                	ld	s8,0(sp)
  printf("balloc: out of blocks\n");
    800033e4:	00006517          	auipc	a0,0x6
    800033e8:	02450513          	addi	a0,a0,36 # 80009408 <etext+0x408>
    800033ec:	940fd0ef          	jal	8000052c <printf>
  return 0;
    800033f0:	4481                	li	s1,0
    800033f2:	bfad                	j	8000336c <balloc+0x98>

00000000800033f4 <inode_report>:
{
    800033f4:	db010113          	addi	sp,sp,-592
    800033f8:	24113423          	sd	ra,584(sp)
    800033fc:	24813023          	sd	s0,576(sp)
    80003400:	22913c23          	sd	s1,568(sp)
    80003404:	23213823          	sd	s2,560(sp)
    80003408:	23313423          	sd	s3,552(sp)
    8000340c:	23413023          	sd	s4,544(sp)
    80003410:	21513c23          	sd	s5,536(sp)
    80003414:	21613823          	sd	s6,528(sp)
    80003418:	21713423          	sd	s7,520(sp)
    8000341c:	21813023          	sd	s8,512(sp)
    80003420:	0c80                	addi	s0,sp,592
    80003422:	892a                	mv	s2,a0
    80003424:	84ae                	mv	s1,a1
    80003426:	89b2                	mv	s3,a2
    80003428:	8a36                	mv	s4,a3
    8000342a:	8aba                	mv	s5,a4
    8000342c:	8b3e                	mv	s6,a5
    8000342e:	8bc2                	mv	s7,a6
    80003430:	8c46                	mv	s8,a7
  memset(&e, 0, sizeof(e));
    80003432:	20000613          	li	a2,512
    80003436:	4581                	li	a1,0
    80003438:	db040513          	addi	a0,s0,-592
    8000343c:	8effd0ef          	jal	80000d2a <memset>
  e.ticks = ticks;
    80003440:	00007797          	auipc	a5,0x7
    80003444:	c087a783          	lw	a5,-1016(a5) # 8000a048 <ticks>
    80003448:	daf42c23          	sw	a5,-584(s0)
  e.pid = myproc() ? myproc()->pid : 0;
    8000344c:	d1cfe0ef          	jal	80001968 <myproc>
    80003450:	4781                	li	a5,0
    80003452:	c501                	beqz	a0,8000345a <inode_report+0x66>
    80003454:	d14fe0ef          	jal	80001968 <myproc>
    80003458:	591c                	lw	a5,48(a0)
    8000345a:	daf42e23          	sw	a5,-580(s0)
  e.type = LAYER_INODE;
    8000345e:	4791                	li	a5,4
    80003460:	dcf42023          	sw	a5,-576(s0)
  safestrcpy(e.op_name, op, 16);
    80003464:	4641                	li	a2,16
    80003466:	85ca                	mv	a1,s2
    80003468:	dc440513          	addi	a0,s0,-572
    8000346c:	a13fd0ef          	jal	80000e7e <safestrcpy>
  e.inode.inum = ip->inum;
    80003470:	40dc                	lw	a5,4(s1)
    80003472:	f0f42823          	sw	a5,-240(s0)
  e.inode.ref = ip->ref;
    80003476:	449c                	lw	a5,8(s1)
    80003478:	f0f42a23          	sw	a5,-236(s0)
  e.inode.old_ref = old_ref;
    8000347c:	f1342c23          	sw	s3,-232(s0)
  e.inode.valid_inode = ip->valid;
    80003480:	40bc                	lw	a5,64(s1)
    80003482:	f0f42e23          	sw	a5,-228(s0)
  e.inode.old_valid_inode = old_valid;
    80003486:	f3442023          	sw	s4,-224(s0)
  e.inode.type_inode = ip->type;
    8000348a:	04449783          	lh	a5,68(s1)
    8000348e:	f2f42223          	sw	a5,-220(s0)
  e.inode.old_type_inode = old_type;
    80003492:	f3542423          	sw	s5,-216(s0)
  e.inode.size = ip->size;
    80003496:	44fc                	lw	a5,76(s1)
    80003498:	f2f42623          	sw	a5,-212(s0)
  e.inode.old_size = old_size;
    8000349c:	f3642823          	sw	s6,-208(s0)
  e.inode.locked = holdingsleep(&ip->lock);
    800034a0:	01048513          	addi	a0,s1,16
    800034a4:	08b010ef          	jal	80004d2e <holdingsleep>
    800034a8:	f2a42a23          	sw	a0,-204(s0)
  e.inode.old_locked = old_locked;
    800034ac:	f3742c23          	sw	s7,-200(s0)
  safestrcpy(e.details, det, 128);
    800034b0:	08000613          	li	a2,128
    800034b4:	85e2                	mv	a1,s8
    800034b6:	dd440513          	addi	a0,s0,-556
    800034ba:	9c5fd0ef          	jal	80000e7e <safestrcpy>
  fslog_push(&e);
    800034be:	db040513          	addi	a0,s0,-592
    800034c2:	2fd030ef          	jal	80006fbe <fslog_push>
}
    800034c6:	24813083          	ld	ra,584(sp)
    800034ca:	24013403          	ld	s0,576(sp)
    800034ce:	23813483          	ld	s1,568(sp)
    800034d2:	23013903          	ld	s2,560(sp)
    800034d6:	22813983          	ld	s3,552(sp)
    800034da:	22013a03          	ld	s4,544(sp)
    800034de:	21813a83          	ld	s5,536(sp)
    800034e2:	21013b03          	ld	s6,528(sp)
    800034e6:	20813b83          	ld	s7,520(sp)
    800034ea:	20013c03          	ld	s8,512(sp)
    800034ee:	25010113          	addi	sp,sp,592
    800034f2:	8082                	ret

00000000800034f4 <iget>:

// Find the inode with number inum on device dev
// and return the in-memory copy.
static struct inode*
iget(uint dev, uint inum)
{
    800034f4:	7179                	addi	sp,sp,-48
    800034f6:	f406                	sd	ra,40(sp)
    800034f8:	f022                	sd	s0,32(sp)
    800034fa:	ec26                	sd	s1,24(sp)
    800034fc:	e84a                	sd	s2,16(sp)
    800034fe:	e44e                	sd	s3,8(sp)
    80003500:	e052                	sd	s4,0(sp)
    80003502:	1800                	addi	s0,sp,48
    80003504:	892a                	mv	s2,a0
    80003506:	8a2e                	mv	s4,a1
  struct inode *ip, *empty;

  acquire(&itable.lock);
    80003508:	0001d517          	auipc	a0,0x1d
    8000350c:	1c850513          	addi	a0,a0,456 # 800206d0 <itable>
    80003510:	f4afd0ef          	jal	80000c5a <acquire>

  // Is the inode already in the table?
  empty = 0;
    80003514:	4981                	li	s3,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003516:	0001d497          	auipc	s1,0x1d
    8000351a:	1d248493          	addi	s1,s1,466 # 800206e8 <itable+0x18>
    8000351e:	0001f717          	auipc	a4,0x1f
    80003522:	c5a70713          	addi	a4,a4,-934 # 80022178 <log>
    80003526:	a809                	j	80003538 <iget+0x44>
      0,
      "Inode found in cache");
      release(&itable.lock);
      return ip;
    }
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003528:	e601                	bnez	a2,80003530 <iget+0x3c>
    8000352a:	00099363          	bnez	s3,80003530 <iget+0x3c>
      empty = ip;
    8000352e:	89a6                	mv	s3,s1
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003530:	08848493          	addi	s1,s1,136
    80003534:	04e48663          	beq	s1,a4,80003580 <iget+0x8c>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    80003538:	4490                	lw	a2,8(s1)
    8000353a:	fec057e3          	blez	a2,80003528 <iget+0x34>
    8000353e:	409c                	lw	a5,0(s1)
    80003540:	ff2798e3          	bne	a5,s2,80003530 <iget+0x3c>
    80003544:	40dc                	lw	a5,4(s1)
    80003546:	ff4795e3          	bne	a5,s4,80003530 <iget+0x3c>
      ip->ref++;
    8000354a:	0016079b          	addiw	a5,a2,1
    8000354e:	c49c                	sw	a5,8(s1)
       inode_report("IGET_HIT", ip,
    80003550:	00006897          	auipc	a7,0x6
    80003554:	ed088893          	addi	a7,a7,-304 # 80009420 <etext+0x420>
    80003558:	4801                	li	a6,0
    8000355a:	44fc                	lw	a5,76(s1)
    8000355c:	04449703          	lh	a4,68(s1)
    80003560:	40b4                	lw	a3,64(s1)
    80003562:	85a6                	mv	a1,s1
    80003564:	00006517          	auipc	a0,0x6
    80003568:	ed450513          	addi	a0,a0,-300 # 80009438 <etext+0x438>
    8000356c:	e89ff0ef          	jal	800033f4 <inode_report>
      release(&itable.lock);
    80003570:	0001d517          	auipc	a0,0x1d
    80003574:	16050513          	addi	a0,a0,352 # 800206d0 <itable>
    80003578:	f76fd0ef          	jal	80000cee <release>
      return ip;
    8000357c:	89a6                	mv	s3,s1
    8000357e:	a091                	j	800035c2 <iget+0xce>
  }

  // Recycle an inode entry.
  if(empty == 0)
    80003580:	04098a63          	beqz	s3,800035d4 <iget+0xe0>
    panic("iget: no inodes");

  ip = empty;
  ip->dev = dev;
    80003584:	0129a023          	sw	s2,0(s3)
  ip->inum = inum;
    80003588:	0149a223          	sw	s4,4(s3)
  ip->ref = 1;
    8000358c:	4785                	li	a5,1
    8000358e:	00f9a423          	sw	a5,8(s3)
  ip->valid = 0;
    80003592:	0409a023          	sw	zero,64(s3)
  inode_report("IGET_NEW", ip,
    80003596:	00006897          	auipc	a7,0x6
    8000359a:	ec288893          	addi	a7,a7,-318 # 80009458 <etext+0x458>
    8000359e:	4801                	li	a6,0
    800035a0:	4781                	li	a5,0
    800035a2:	4701                	li	a4,0
    800035a4:	4681                	li	a3,0
    800035a6:	4601                	li	a2,0
    800035a8:	85ce                	mv	a1,s3
    800035aa:	00006517          	auipc	a0,0x6
    800035ae:	ece50513          	addi	a0,a0,-306 # 80009478 <etext+0x478>
    800035b2:	e43ff0ef          	jal	800033f4 <inode_report>
    0, 0,
    0, 0,
    0,
    "Allocated new inode in table");
  release(&itable.lock);
    800035b6:	0001d517          	auipc	a0,0x1d
    800035ba:	11a50513          	addi	a0,a0,282 # 800206d0 <itable>
    800035be:	f30fd0ef          	jal	80000cee <release>

  return ip;
}
    800035c2:	854e                	mv	a0,s3
    800035c4:	70a2                	ld	ra,40(sp)
    800035c6:	7402                	ld	s0,32(sp)
    800035c8:	64e2                	ld	s1,24(sp)
    800035ca:	6942                	ld	s2,16(sp)
    800035cc:	69a2                	ld	s3,8(sp)
    800035ce:	6a02                	ld	s4,0(sp)
    800035d0:	6145                	addi	sp,sp,48
    800035d2:	8082                	ret
    panic("iget: no inodes");
    800035d4:	00006517          	auipc	a0,0x6
    800035d8:	e7450513          	addi	a0,a0,-396 # 80009448 <etext+0x448>
    800035dc:	a7afd0ef          	jal	80000856 <panic>

00000000800035e0 <bmap>:
// Inode content

// Return the disk block address of the nth block in inode ip.
static uint
bmap(struct inode *ip, uint bn)
{
    800035e0:	7179                	addi	sp,sp,-48
    800035e2:	f406                	sd	ra,40(sp)
    800035e4:	f022                	sd	s0,32(sp)
    800035e6:	ec26                	sd	s1,24(sp)
    800035e8:	e84a                	sd	s2,16(sp)
    800035ea:	e44e                	sd	s3,8(sp)
    800035ec:	1800                	addi	s0,sp,48
    800035ee:	84aa                	mv	s1,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    800035f0:	47ad                	li	a5,11
    800035f2:	04b7e663          	bltu	a5,a1,8000363e <bmap+0x5e>
    if((addr = ip->addrs[bn]) == 0){
    800035f6:	02059793          	slli	a5,a1,0x20
    800035fa:	01e7d593          	srli	a1,a5,0x1e
    800035fe:	00b509b3          	add	s3,a0,a1
    80003602:	0509a903          	lw	s2,80(s3)
    80003606:	0a091963          	bnez	s2,800036b8 <bmap+0xd8>
      addr = balloc(ip->dev);
    8000360a:	4108                	lw	a0,0(a0)
    8000360c:	cc9ff0ef          	jal	800032d4 <balloc>
    80003610:	892a                	mv	s2,a0

inode_report("BMAP_ALLOC_DIRECT", ip,
    80003612:	00006897          	auipc	a7,0x6
    80003616:	e7688893          	addi	a7,a7,-394 # 80009488 <etext+0x488>
    8000361a:	4805                	li	a6,1
    8000361c:	44fc                	lw	a5,76(s1)
    8000361e:	04449703          	lh	a4,68(s1)
    80003622:	40b4                	lw	a3,64(s1)
    80003624:	4490                	lw	a2,8(s1)
    80003626:	85a6                	mv	a1,s1
    80003628:	00006517          	auipc	a0,0x6
    8000362c:	e7850513          	addi	a0,a0,-392 # 800094a0 <etext+0x4a0>
    80003630:	dc5ff0ef          	jal	800033f4 <inode_report>
    ip->valid,
    ip->type,
    ip->size,
    1,
    "Allocated direct block");
      if(addr == 0)
    80003634:	08090263          	beqz	s2,800036b8 <bmap+0xd8>
        return 0;
      ip->addrs[bn] = addr;
    80003638:	0529a823          	sw	s2,80(s3)
    8000363c:	a8b5                	j	800036b8 <bmap+0xd8>
    }
    return addr;
  }
  bn -= NDIRECT;
    8000363e:	ff45879b          	addiw	a5,a1,-12
    80003642:	873e                	mv	a4,a5
    80003644:	89be                	mv	s3,a5

  if(bn < NINDIRECT){
    80003646:	0ff00793          	li	a5,255
    8000364a:	0ae7eb63          	bltu	a5,a4,80003700 <bmap+0x120>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    8000364e:	08052903          	lw	s2,128(a0)
    80003652:	02091d63          	bnez	s2,8000368c <bmap+0xac>
      addr = balloc(ip->dev);
    80003656:	4108                	lw	a0,0(a0)
    80003658:	c7dff0ef          	jal	800032d4 <balloc>
    8000365c:	892a                	mv	s2,a0
      inode_report("BMAP_ALLOC_INDIRECT", ip,
    8000365e:	00006897          	auipc	a7,0x6
    80003662:	e5a88893          	addi	a7,a7,-422 # 800094b8 <etext+0x4b8>
    80003666:	4805                	li	a6,1
    80003668:	44fc                	lw	a5,76(s1)
    8000366a:	04449703          	lh	a4,68(s1)
    8000366e:	40b4                	lw	a3,64(s1)
    80003670:	4490                	lw	a2,8(s1)
    80003672:	85a6                	mv	a1,s1
    80003674:	00006517          	auipc	a0,0x6
    80003678:	e6450513          	addi	a0,a0,-412 # 800094d8 <etext+0x4d8>
    8000367c:	d79ff0ef          	jal	800033f4 <inode_report>
    ip->valid,
    ip->type,
    ip->size,
    1,
    "Allocated indirect block table");
      if(addr == 0)
    80003680:	02090c63          	beqz	s2,800036b8 <bmap+0xd8>
    80003684:	e052                	sd	s4,0(sp)
        return 0;
      ip->addrs[NDIRECT] = addr;
    80003686:	0924a023          	sw	s2,128(s1)
    8000368a:	a011                	j	8000368e <bmap+0xae>
    8000368c:	e052                	sd	s4,0(sp)
    }
    bp = bread(ip->dev, addr);
    8000368e:	85ca                	mv	a1,s2
    80003690:	4088                	lw	a0,0(s1)
    80003692:	d64ff0ef          	jal	80002bf6 <bread>
    80003696:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    80003698:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    8000369c:	02099713          	slli	a4,s3,0x20
    800036a0:	01e75593          	srli	a1,a4,0x1e
    800036a4:	97ae                	add	a5,a5,a1
    800036a6:	89be                	mv	s3,a5
    800036a8:	0007a903          	lw	s2,0(a5)
    800036ac:	00090e63          	beqz	s2,800036c8 <bmap+0xe8>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    800036b0:	8552                	mv	a0,s4
    800036b2:	ff0ff0ef          	jal	80002ea2 <brelse>
    return addr;
    800036b6:	6a02                	ld	s4,0(sp)
  }

  panic("bmap: out of range");
}
    800036b8:	854a                	mv	a0,s2
    800036ba:	70a2                	ld	ra,40(sp)
    800036bc:	7402                	ld	s0,32(sp)
    800036be:	64e2                	ld	s1,24(sp)
    800036c0:	6942                	ld	s2,16(sp)
    800036c2:	69a2                	ld	s3,8(sp)
    800036c4:	6145                	addi	sp,sp,48
    800036c6:	8082                	ret
      inode_report("BMAP_ALLOC_DATA", ip,
    800036c8:	00006897          	auipc	a7,0x6
    800036cc:	e2888893          	addi	a7,a7,-472 # 800094f0 <etext+0x4f0>
    800036d0:	4805                	li	a6,1
    800036d2:	44fc                	lw	a5,76(s1)
    800036d4:	04449703          	lh	a4,68(s1)
    800036d8:	40b4                	lw	a3,64(s1)
    800036da:	4490                	lw	a2,8(s1)
    800036dc:	85a6                	mv	a1,s1
    800036de:	00006517          	auipc	a0,0x6
    800036e2:	e3250513          	addi	a0,a0,-462 # 80009510 <etext+0x510>
    800036e6:	d0fff0ef          	jal	800033f4 <inode_report>
      addr = balloc(ip->dev);
    800036ea:	4088                	lw	a0,0(s1)
    800036ec:	be9ff0ef          	jal	800032d4 <balloc>
    800036f0:	892a                	mv	s2,a0
      if(addr){
    800036f2:	dd5d                	beqz	a0,800036b0 <bmap+0xd0>
        a[bn] = addr;
    800036f4:	00a9a023          	sw	a0,0(s3)
        log_write(bp);
    800036f8:	8552                	mv	a0,s4
    800036fa:	496010ef          	jal	80004b90 <log_write>
    800036fe:	bf4d                	j	800036b0 <bmap+0xd0>
    80003700:	e052                	sd	s4,0(sp)
  panic("bmap: out of range");
    80003702:	00006517          	auipc	a0,0x6
    80003706:	e1e50513          	addi	a0,a0,-482 # 80009520 <etext+0x520>
    8000370a:	94cfd0ef          	jal	80000856 <panic>

000000008000370e <iinit>:
{
    8000370e:	7179                	addi	sp,sp,-48
    80003710:	f406                	sd	ra,40(sp)
    80003712:	f022                	sd	s0,32(sp)
    80003714:	ec26                	sd	s1,24(sp)
    80003716:	e84a                	sd	s2,16(sp)
    80003718:	e44e                	sd	s3,8(sp)
    8000371a:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    8000371c:	00006597          	auipc	a1,0x6
    80003720:	e1c58593          	addi	a1,a1,-484 # 80009538 <etext+0x538>
    80003724:	0001d517          	auipc	a0,0x1d
    80003728:	fac50513          	addi	a0,a0,-84 # 800206d0 <itable>
    8000372c:	ca4fd0ef          	jal	80000bd0 <initlock>
  for(i = 0; i < NINODE; i++) {
    80003730:	0001d497          	auipc	s1,0x1d
    80003734:	fc848493          	addi	s1,s1,-56 # 800206f8 <itable+0x28>
    80003738:	0001f997          	auipc	s3,0x1f
    8000373c:	a5098993          	addi	s3,s3,-1456 # 80022188 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    80003740:	00006917          	auipc	s2,0x6
    80003744:	e8890913          	addi	s2,s2,-376 # 800095c8 <etext+0x5c8>
    80003748:	85ca                	mv	a1,s2
    8000374a:	8526                	mv	a0,s1
    8000374c:	52e010ef          	jal	80004c7a <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    80003750:	08848493          	addi	s1,s1,136
    80003754:	ff349ae3          	bne	s1,s3,80003748 <iinit+0x3a>
}
    80003758:	70a2                	ld	ra,40(sp)
    8000375a:	7402                	ld	s0,32(sp)
    8000375c:	64e2                	ld	s1,24(sp)
    8000375e:	6942                	ld	s2,16(sp)
    80003760:	69a2                	ld	s3,8(sp)
    80003762:	6145                	addi	sp,sp,48
    80003764:	8082                	ret

0000000080003766 <ialloc>:
{
    80003766:	7139                	addi	sp,sp,-64
    80003768:	fc06                	sd	ra,56(sp)
    8000376a:	f822                	sd	s0,48(sp)
    8000376c:	f04a                	sd	s2,32(sp)
    8000376e:	0080                	addi	s0,sp,64
  for(inum = 1; inum < sb.ninodes; inum++){
    80003770:	0001d717          	auipc	a4,0x1d
    80003774:	f4c72703          	lw	a4,-180(a4) # 800206bc <sb+0xc>
    80003778:	4785                	li	a5,1
    8000377a:	04e7fe63          	bgeu	a5,a4,800037d6 <ialloc+0x70>
    8000377e:	f426                	sd	s1,40(sp)
    80003780:	ec4e                	sd	s3,24(sp)
    80003782:	e852                	sd	s4,16(sp)
    80003784:	e456                	sd	s5,8(sp)
    80003786:	e05a                	sd	s6,0(sp)
    80003788:	8aaa                	mv	s5,a0
    8000378a:	8b2e                	mv	s6,a1
    8000378c:	893e                	mv	s2,a5
    bp = bread(dev, IBLOCK(inum, sb));
    8000378e:	0001da17          	auipc	s4,0x1d
    80003792:	f22a0a13          	addi	s4,s4,-222 # 800206b0 <sb>
    80003796:	00495593          	srli	a1,s2,0x4
    8000379a:	018a2783          	lw	a5,24(s4)
    8000379e:	9dbd                	addw	a1,a1,a5
    800037a0:	8556                	mv	a0,s5
    800037a2:	c54ff0ef          	jal	80002bf6 <bread>
    800037a6:	84aa                	mv	s1,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    800037a8:	05850993          	addi	s3,a0,88
    800037ac:	00f97793          	andi	a5,s2,15
    800037b0:	079a                	slli	a5,a5,0x6
    800037b2:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    800037b4:	00099783          	lh	a5,0(s3)
    800037b8:	cf85                	beqz	a5,800037f0 <ialloc+0x8a>
    brelse(bp);
    800037ba:	ee8ff0ef          	jal	80002ea2 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    800037be:	0905                	addi	s2,s2,1
    800037c0:	00ca2703          	lw	a4,12(s4)
    800037c4:	0009079b          	sext.w	a5,s2
    800037c8:	fce7e7e3          	bltu	a5,a4,80003796 <ialloc+0x30>
    800037cc:	74a2                	ld	s1,40(sp)
    800037ce:	69e2                	ld	s3,24(sp)
    800037d0:	6a42                	ld	s4,16(sp)
    800037d2:	6aa2                	ld	s5,8(sp)
    800037d4:	6b02                	ld	s6,0(sp)
  printf("ialloc: no inodes\n");
    800037d6:	00006517          	auipc	a0,0x6
    800037da:	d8a50513          	addi	a0,a0,-630 # 80009560 <etext+0x560>
    800037de:	d4ffc0ef          	jal	8000052c <printf>
  return 0;
    800037e2:	4901                	li	s2,0
}
    800037e4:	854a                	mv	a0,s2
    800037e6:	70e2                	ld	ra,56(sp)
    800037e8:	7442                	ld	s0,48(sp)
    800037ea:	7902                	ld	s2,32(sp)
    800037ec:	6121                	addi	sp,sp,64
    800037ee:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    800037f0:	04000613          	li	a2,64
    800037f4:	4581                	li	a1,0
    800037f6:	854e                	mv	a0,s3
    800037f8:	d32fd0ef          	jal	80000d2a <memset>
      dip->type = type;
    800037fc:	01699023          	sh	s6,0(s3)
      log_write(bp);   // mark it allocated on the disk
    80003800:	8526                	mv	a0,s1
    80003802:	38e010ef          	jal	80004b90 <log_write>
      struct inode *ip = iget(dev, inum);
    80003806:	0009059b          	sext.w	a1,s2
    8000380a:	8556                	mv	a0,s5
    8000380c:	ce9ff0ef          	jal	800034f4 <iget>
    80003810:	892a                	mv	s2,a0
      inode_report("IALLOC", ip,
    80003812:	00006897          	auipc	a7,0x6
    80003816:	d2e88893          	addi	a7,a7,-722 # 80009540 <etext+0x540>
    8000381a:	4801                	li	a6,0
    8000381c:	4781                	li	a5,0
    8000381e:	4701                	li	a4,0
    80003820:	4681                	li	a3,0
    80003822:	4601                	li	a2,0
    80003824:	85aa                	mv	a1,a0
    80003826:	00006517          	auipc	a0,0x6
    8000382a:	d3250513          	addi	a0,a0,-718 # 80009558 <etext+0x558>
    8000382e:	bc7ff0ef          	jal	800033f4 <inode_report>
      brelse(bp);
    80003832:	8526                	mv	a0,s1
    80003834:	e6eff0ef          	jal	80002ea2 <brelse>
      return ip;
    80003838:	74a2                	ld	s1,40(sp)
    8000383a:	69e2                	ld	s3,24(sp)
    8000383c:	6a42                	ld	s4,16(sp)
    8000383e:	6aa2                	ld	s5,8(sp)
    80003840:	6b02                	ld	s6,0(sp)
    80003842:	b74d                	j	800037e4 <ialloc+0x7e>

0000000080003844 <iupdate>:
{
    80003844:	1101                	addi	sp,sp,-32
    80003846:	ec06                	sd	ra,24(sp)
    80003848:	e822                	sd	s0,16(sp)
    8000384a:	e426                	sd	s1,8(sp)
    8000384c:	e04a                	sd	s2,0(sp)
    8000384e:	1000                	addi	s0,sp,32
    80003850:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003852:	415c                	lw	a5,4(a0)
    80003854:	0047d79b          	srliw	a5,a5,0x4
    80003858:	0001d597          	auipc	a1,0x1d
    8000385c:	e705a583          	lw	a1,-400(a1) # 800206c8 <sb+0x18>
    80003860:	9dbd                	addw	a1,a1,a5
    80003862:	4108                	lw	a0,0(a0)
    80003864:	b92ff0ef          	jal	80002bf6 <bread>
    80003868:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    8000386a:	05850793          	addi	a5,a0,88
    8000386e:	40d8                	lw	a4,4(s1)
    80003870:	8b3d                	andi	a4,a4,15
    80003872:	071a                	slli	a4,a4,0x6
    80003874:	97ba                	add	a5,a5,a4
  dip->type = ip->type;
    80003876:	04449703          	lh	a4,68(s1)
    8000387a:	00e79023          	sh	a4,0(a5)
  dip->major = ip->major;
    8000387e:	04649703          	lh	a4,70(s1)
    80003882:	00e79123          	sh	a4,2(a5)
  dip->minor = ip->minor;
    80003886:	04849703          	lh	a4,72(s1)
    8000388a:	00e79223          	sh	a4,4(a5)
  dip->nlink = ip->nlink;
    8000388e:	04a49703          	lh	a4,74(s1)
    80003892:	00e79323          	sh	a4,6(a5)
  dip->size = ip->size;
    80003896:	44f8                	lw	a4,76(s1)
    80003898:	c798                	sw	a4,8(a5)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    8000389a:	03400613          	li	a2,52
    8000389e:	05048593          	addi	a1,s1,80
    800038a2:	00c78513          	addi	a0,a5,12
    800038a6:	ce4fd0ef          	jal	80000d8a <memmove>
  inode_report("IUPDATE", ip,
    800038aa:	00006897          	auipc	a7,0x6
    800038ae:	cce88893          	addi	a7,a7,-818 # 80009578 <etext+0x578>
    800038b2:	4805                	li	a6,1
    800038b4:	44fc                	lw	a5,76(s1)
    800038b6:	04449703          	lh	a4,68(s1)
    800038ba:	40b4                	lw	a3,64(s1)
    800038bc:	4490                	lw	a2,8(s1)
    800038be:	85a6                	mv	a1,s1
    800038c0:	00006517          	auipc	a0,0x6
    800038c4:	cd050513          	addi	a0,a0,-816 # 80009590 <etext+0x590>
    800038c8:	b2dff0ef          	jal	800033f4 <inode_report>
  log_write(bp);
    800038cc:	854a                	mv	a0,s2
    800038ce:	2c2010ef          	jal	80004b90 <log_write>
  brelse(bp);
    800038d2:	854a                	mv	a0,s2
    800038d4:	dceff0ef          	jal	80002ea2 <brelse>
}
    800038d8:	60e2                	ld	ra,24(sp)
    800038da:	6442                	ld	s0,16(sp)
    800038dc:	64a2                	ld	s1,8(sp)
    800038de:	6902                	ld	s2,0(sp)
    800038e0:	6105                	addi	sp,sp,32
    800038e2:	8082                	ret

00000000800038e4 <idup>:
{
    800038e4:	1101                	addi	sp,sp,-32
    800038e6:	ec06                	sd	ra,24(sp)
    800038e8:	e822                	sd	s0,16(sp)
    800038ea:	e426                	sd	s1,8(sp)
    800038ec:	1000                	addi	s0,sp,32
    800038ee:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    800038f0:	0001d517          	auipc	a0,0x1d
    800038f4:	de050513          	addi	a0,a0,-544 # 800206d0 <itable>
    800038f8:	b62fd0ef          	jal	80000c5a <acquire>
  int old_ref = ip->ref;
    800038fc:	4490                	lw	a2,8(s1)
  ip->ref++;
    800038fe:	0016079b          	addiw	a5,a2,1
    80003902:	c49c                	sw	a5,8(s1)
  inode_report("IDUP", ip,
    80003904:	00006897          	auipc	a7,0x6
    80003908:	c9488893          	addi	a7,a7,-876 # 80009598 <etext+0x598>
    8000390c:	4801                	li	a6,0
    8000390e:	44fc                	lw	a5,76(s1)
    80003910:	04449703          	lh	a4,68(s1)
    80003914:	40b4                	lw	a3,64(s1)
    80003916:	85a6                	mv	a1,s1
    80003918:	00006517          	auipc	a0,0x6
    8000391c:	c9850513          	addi	a0,a0,-872 # 800095b0 <etext+0x5b0>
    80003920:	ad5ff0ef          	jal	800033f4 <inode_report>
  release(&itable.lock);
    80003924:	0001d517          	auipc	a0,0x1d
    80003928:	dac50513          	addi	a0,a0,-596 # 800206d0 <itable>
    8000392c:	bc2fd0ef          	jal	80000cee <release>
}
    80003930:	8526                	mv	a0,s1
    80003932:	60e2                	ld	ra,24(sp)
    80003934:	6442                	ld	s0,16(sp)
    80003936:	64a2                	ld	s1,8(sp)
    80003938:	6105                	addi	sp,sp,32
    8000393a:	8082                	ret

000000008000393c <ilock>:
{
    8000393c:	1101                	addi	sp,sp,-32
    8000393e:	ec06                	sd	ra,24(sp)
    80003940:	e822                	sd	s0,16(sp)
    80003942:	e426                	sd	s1,8(sp)
    80003944:	e04a                	sd	s2,0(sp)
    80003946:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    80003948:	c139                	beqz	a0,8000398e <ilock+0x52>
    8000394a:	84aa                	mv	s1,a0
    8000394c:	451c                	lw	a5,8(a0)
    8000394e:	04f05063          	blez	a5,8000398e <ilock+0x52>
   int old_valid = ip->valid;
    80003952:	413c                	lw	a5,64(a0)
    80003954:	893e                	mv	s2,a5
  acquiresleep(&ip->lock);
    80003956:	0541                	addi	a0,a0,16
    80003958:	358010ef          	jal	80004cb0 <acquiresleep>
  inode_report("ILOCK_ACQUIRE", ip,
    8000395c:	00006897          	auipc	a7,0x6
    80003960:	c6488893          	addi	a7,a7,-924 # 800095c0 <etext+0x5c0>
    80003964:	4801                	li	a6,0
    80003966:	44fc                	lw	a5,76(s1)
    80003968:	04449703          	lh	a4,68(s1)
    8000396c:	86ca                	mv	a3,s2
    8000396e:	4490                	lw	a2,8(s1)
    80003970:	85a6                	mv	a1,s1
    80003972:	00006517          	auipc	a0,0x6
    80003976:	c5e50513          	addi	a0,a0,-930 # 800095d0 <etext+0x5d0>
    8000397a:	a7bff0ef          	jal	800033f4 <inode_report>
  if(ip->valid == 0){
    8000397e:	40bc                	lw	a5,64(s1)
    80003980:	cf89                	beqz	a5,8000399a <ilock+0x5e>
}
    80003982:	60e2                	ld	ra,24(sp)
    80003984:	6442                	ld	s0,16(sp)
    80003986:	64a2                	ld	s1,8(sp)
    80003988:	6902                	ld	s2,0(sp)
    8000398a:	6105                	addi	sp,sp,32
    8000398c:	8082                	ret
    panic("ilock");
    8000398e:	00006517          	auipc	a0,0x6
    80003992:	c2a50513          	addi	a0,a0,-982 # 800095b8 <etext+0x5b8>
    80003996:	ec1fc0ef          	jal	80000856 <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    8000399a:	40dc                	lw	a5,4(s1)
    8000399c:	0047d79b          	srliw	a5,a5,0x4
    800039a0:	0001d597          	auipc	a1,0x1d
    800039a4:	d285a583          	lw	a1,-728(a1) # 800206c8 <sb+0x18>
    800039a8:	9dbd                	addw	a1,a1,a5
    800039aa:	4088                	lw	a0,0(s1)
    800039ac:	a4aff0ef          	jal	80002bf6 <bread>
    800039b0:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    800039b2:	05850593          	addi	a1,a0,88
    800039b6:	40dc                	lw	a5,4(s1)
    800039b8:	8bbd                	andi	a5,a5,15
    800039ba:	079a                	slli	a5,a5,0x6
    800039bc:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    800039be:	00059783          	lh	a5,0(a1)
    800039c2:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    800039c6:	00259783          	lh	a5,2(a1)
    800039ca:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    800039ce:	00459783          	lh	a5,4(a1)
    800039d2:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    800039d6:	00659783          	lh	a5,6(a1)
    800039da:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    800039de:	459c                	lw	a5,8(a1)
    800039e0:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    800039e2:	03400613          	li	a2,52
    800039e6:	05b1                	addi	a1,a1,12
    800039e8:	05048513          	addi	a0,s1,80
    800039ec:	b9efd0ef          	jal	80000d8a <memmove>
    brelse(bp);
    800039f0:	854a                	mv	a0,s2
    800039f2:	cb0ff0ef          	jal	80002ea2 <brelse>
    ip->valid = 1;
    800039f6:	4785                	li	a5,1
    800039f8:	c0bc                	sw	a5,64(s1)
    inode_report("ILOCK_LOAD", ip,
    800039fa:	00006897          	auipc	a7,0x6
    800039fe:	be688893          	addi	a7,a7,-1050 # 800095e0 <etext+0x5e0>
    80003a02:	883e                	mv	a6,a5
    80003a04:	44fc                	lw	a5,76(s1)
    80003a06:	04449703          	lh	a4,68(s1)
    80003a0a:	4681                	li	a3,0
    80003a0c:	4490                	lw	a2,8(s1)
    80003a0e:	85a6                	mv	a1,s1
    80003a10:	00006517          	auipc	a0,0x6
    80003a14:	be850513          	addi	a0,a0,-1048 # 800095f8 <etext+0x5f8>
    80003a18:	9ddff0ef          	jal	800033f4 <inode_report>
    if(ip->type == 0)
    80003a1c:	04449783          	lh	a5,68(s1)
    80003a20:	f3ad                	bnez	a5,80003982 <ilock+0x46>
      panic("ilock: no type");
    80003a22:	00006517          	auipc	a0,0x6
    80003a26:	be650513          	addi	a0,a0,-1050 # 80009608 <etext+0x608>
    80003a2a:	e2dfc0ef          	jal	80000856 <panic>

0000000080003a2e <iunlock>:
{
    80003a2e:	1101                	addi	sp,sp,-32
    80003a30:	ec06                	sd	ra,24(sp)
    80003a32:	e822                	sd	s0,16(sp)
    80003a34:	e426                	sd	s1,8(sp)
    80003a36:	e04a                	sd	s2,0(sp)
    80003a38:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80003a3a:	c529                	beqz	a0,80003a84 <iunlock+0x56>
    80003a3c:	84aa                	mv	s1,a0
    80003a3e:	01050913          	addi	s2,a0,16
    80003a42:	854a                	mv	a0,s2
    80003a44:	2ea010ef          	jal	80004d2e <holdingsleep>
    80003a48:	cd15                	beqz	a0,80003a84 <iunlock+0x56>
    80003a4a:	449c                	lw	a5,8(s1)
    80003a4c:	02f05c63          	blez	a5,80003a84 <iunlock+0x56>
  releasesleep(&ip->lock);
    80003a50:	854a                	mv	a0,s2
    80003a52:	2a4010ef          	jal	80004cf6 <releasesleep>
  inode_report("IUNLOCK", ip,
    80003a56:	00006897          	auipc	a7,0x6
    80003a5a:	bca88893          	addi	a7,a7,-1078 # 80009620 <etext+0x620>
    80003a5e:	4805                	li	a6,1
    80003a60:	44fc                	lw	a5,76(s1)
    80003a62:	04449703          	lh	a4,68(s1)
    80003a66:	40b4                	lw	a3,64(s1)
    80003a68:	4490                	lw	a2,8(s1)
    80003a6a:	85a6                	mv	a1,s1
    80003a6c:	00006517          	auipc	a0,0x6
    80003a70:	bc450513          	addi	a0,a0,-1084 # 80009630 <etext+0x630>
    80003a74:	981ff0ef          	jal	800033f4 <inode_report>
}
    80003a78:	60e2                	ld	ra,24(sp)
    80003a7a:	6442                	ld	s0,16(sp)
    80003a7c:	64a2                	ld	s1,8(sp)
    80003a7e:	6902                	ld	s2,0(sp)
    80003a80:	6105                	addi	sp,sp,32
    80003a82:	8082                	ret
    panic("iunlock");
    80003a84:	00006517          	auipc	a0,0x6
    80003a88:	b9450513          	addi	a0,a0,-1132 # 80009618 <etext+0x618>
    80003a8c:	dcbfc0ef          	jal	80000856 <panic>

0000000080003a90 <itrunc>:

// Truncate inode (discard contents).
void
itrunc(struct inode *ip)
{
    80003a90:	7179                	addi	sp,sp,-48
    80003a92:	f406                	sd	ra,40(sp)
    80003a94:	f022                	sd	s0,32(sp)
    80003a96:	ec26                	sd	s1,24(sp)
    80003a98:	e84a                	sd	s2,16(sp)
    80003a9a:	e44e                	sd	s3,8(sp)
    80003a9c:	1800                	addi	s0,sp,48
    80003a9e:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    80003aa0:	05050493          	addi	s1,a0,80
    80003aa4:	08050913          	addi	s2,a0,128
    80003aa8:	a021                	j	80003ab0 <itrunc+0x20>
    80003aaa:	0491                	addi	s1,s1,4
    80003aac:	01248b63          	beq	s1,s2,80003ac2 <itrunc+0x32>
    if(ip->addrs[i]){
    80003ab0:	408c                	lw	a1,0(s1)
    80003ab2:	dde5                	beqz	a1,80003aaa <itrunc+0x1a>
      bfree(ip->dev, ip->addrs[i]);
    80003ab4:	0009a503          	lw	a0,0(s3)
    80003ab8:	f92ff0ef          	jal	8000324a <bfree>
      ip->addrs[i] = 0;
    80003abc:	0004a023          	sw	zero,0(s1)
    80003ac0:	b7ed                	j	80003aaa <itrunc+0x1a>
    }
  }

  if(ip->addrs[NDIRECT]){
    80003ac2:	0809a583          	lw	a1,128(s3)
    80003ac6:	e1a9                	bnez	a1,80003b08 <itrunc+0x78>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  int old_size = ip->size;
    80003ac8:	04c9a783          	lw	a5,76(s3)

ip->size = 0;
    80003acc:	0409a623          	sw	zero,76(s3)

inode_report("ITRUNC", ip,
    80003ad0:	00006897          	auipc	a7,0x6
    80003ad4:	b6888893          	addi	a7,a7,-1176 # 80009638 <etext+0x638>
    80003ad8:	4805                	li	a6,1
    80003ada:	04499703          	lh	a4,68(s3)
    80003ade:	0409a683          	lw	a3,64(s3)
    80003ae2:	0089a603          	lw	a2,8(s3)
    80003ae6:	85ce                	mv	a1,s3
    80003ae8:	00006517          	auipc	a0,0x6
    80003aec:	b6850513          	addi	a0,a0,-1176 # 80009650 <etext+0x650>
    80003af0:	905ff0ef          	jal	800033f4 <inode_report>
    ip->ref, ip->valid,
    ip->type, old_size,
    1,
    "Truncating inode data");
  iupdate(ip);
    80003af4:	854e                	mv	a0,s3
    80003af6:	d4fff0ef          	jal	80003844 <iupdate>
}
    80003afa:	70a2                	ld	ra,40(sp)
    80003afc:	7402                	ld	s0,32(sp)
    80003afe:	64e2                	ld	s1,24(sp)
    80003b00:	6942                	ld	s2,16(sp)
    80003b02:	69a2                	ld	s3,8(sp)
    80003b04:	6145                	addi	sp,sp,48
    80003b06:	8082                	ret
    80003b08:	e052                	sd	s4,0(sp)
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80003b0a:	0009a503          	lw	a0,0(s3)
    80003b0e:	8e8ff0ef          	jal	80002bf6 <bread>
    80003b12:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    80003b14:	05850493          	addi	s1,a0,88
    80003b18:	45850913          	addi	s2,a0,1112
    80003b1c:	a021                	j	80003b24 <itrunc+0x94>
    80003b1e:	0491                	addi	s1,s1,4
    80003b20:	01248963          	beq	s1,s2,80003b32 <itrunc+0xa2>
      if(a[j])
    80003b24:	408c                	lw	a1,0(s1)
    80003b26:	dde5                	beqz	a1,80003b1e <itrunc+0x8e>
        bfree(ip->dev, a[j]);
    80003b28:	0009a503          	lw	a0,0(s3)
    80003b2c:	f1eff0ef          	jal	8000324a <bfree>
    80003b30:	b7fd                	j	80003b1e <itrunc+0x8e>
    brelse(bp);
    80003b32:	8552                	mv	a0,s4
    80003b34:	b6eff0ef          	jal	80002ea2 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80003b38:	0809a583          	lw	a1,128(s3)
    80003b3c:	0009a503          	lw	a0,0(s3)
    80003b40:	f0aff0ef          	jal	8000324a <bfree>
    ip->addrs[NDIRECT] = 0;
    80003b44:	0809a023          	sw	zero,128(s3)
    80003b48:	6a02                	ld	s4,0(sp)
    80003b4a:	bfbd                	j	80003ac8 <itrunc+0x38>

0000000080003b4c <iput>:
{
    80003b4c:	1101                	addi	sp,sp,-32
    80003b4e:	ec06                	sd	ra,24(sp)
    80003b50:	e822                	sd	s0,16(sp)
    80003b52:	e426                	sd	s1,8(sp)
    80003b54:	1000                	addi	s0,sp,32
    80003b56:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003b58:	0001d517          	auipc	a0,0x1d
    80003b5c:	b7850513          	addi	a0,a0,-1160 # 800206d0 <itable>
    80003b60:	8fafd0ef          	jal	80000c5a <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003b64:	4498                	lw	a4,8(s1)
    80003b66:	4785                	li	a5,1
    80003b68:	04f70163          	beq	a4,a5,80003baa <iput+0x5e>
  int old_ref = ip->ref;
    80003b6c:	4490                	lw	a2,8(s1)
ip->ref--;
    80003b6e:	fff6079b          	addiw	a5,a2,-1
    80003b72:	c49c                	sw	a5,8(s1)
inode_report("IPUT", ip,
    80003b74:	00006897          	auipc	a7,0x6
    80003b78:	b0c88893          	addi	a7,a7,-1268 # 80009680 <etext+0x680>
    80003b7c:	4801                	li	a6,0
    80003b7e:	44fc                	lw	a5,76(s1)
    80003b80:	04449703          	lh	a4,68(s1)
    80003b84:	40b4                	lw	a3,64(s1)
    80003b86:	85a6                	mv	a1,s1
    80003b88:	00006517          	auipc	a0,0x6
    80003b8c:	b0850513          	addi	a0,a0,-1272 # 80009690 <etext+0x690>
    80003b90:	865ff0ef          	jal	800033f4 <inode_report>
  release(&itable.lock);
    80003b94:	0001d517          	auipc	a0,0x1d
    80003b98:	b3c50513          	addi	a0,a0,-1220 # 800206d0 <itable>
    80003b9c:	952fd0ef          	jal	80000cee <release>
}
    80003ba0:	60e2                	ld	ra,24(sp)
    80003ba2:	6442                	ld	s0,16(sp)
    80003ba4:	64a2                	ld	s1,8(sp)
    80003ba6:	6105                	addi	sp,sp,32
    80003ba8:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003baa:	40bc                	lw	a5,64(s1)
    80003bac:	d3e1                	beqz	a5,80003b6c <iput+0x20>
    80003bae:	04a49783          	lh	a5,74(s1)
    80003bb2:	ffcd                	bnez	a5,80003b6c <iput+0x20>
    80003bb4:	e04a                	sd	s2,0(sp)
    acquiresleep(&ip->lock);
    80003bb6:	01048793          	addi	a5,s1,16
    80003bba:	893e                	mv	s2,a5
    80003bbc:	853e                	mv	a0,a5
    80003bbe:	0f2010ef          	jal	80004cb0 <acquiresleep>
    release(&itable.lock);
    80003bc2:	0001d517          	auipc	a0,0x1d
    80003bc6:	b0e50513          	addi	a0,a0,-1266 # 800206d0 <itable>
    80003bca:	924fd0ef          	jal	80000cee <release>
    itrunc(ip);
    80003bce:	8526                	mv	a0,s1
    80003bd0:	ec1ff0ef          	jal	80003a90 <itrunc>
    ip->type = 0;
    80003bd4:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    80003bd8:	8526                	mv	a0,s1
    80003bda:	c6bff0ef          	jal	80003844 <iupdate>
    ip->valid = 0;
    80003bde:	0404a023          	sw	zero,64(s1)
    inode_report("IPUT_FREE", ip,
    80003be2:	00006897          	auipc	a7,0x6
    80003be6:	a7688893          	addi	a7,a7,-1418 # 80009658 <etext+0x658>
    80003bea:	4805                	li	a6,1
    80003bec:	44fc                	lw	a5,76(s1)
    80003bee:	04449703          	lh	a4,68(s1)
    80003bf2:	4681                	li	a3,0
    80003bf4:	4490                	lw	a2,8(s1)
    80003bf6:	85a6                	mv	a1,s1
    80003bf8:	00006517          	auipc	a0,0x6
    80003bfc:	a7850513          	addi	a0,a0,-1416 # 80009670 <etext+0x670>
    80003c00:	ff4ff0ef          	jal	800033f4 <inode_report>
    releasesleep(&ip->lock);
    80003c04:	854a                	mv	a0,s2
    80003c06:	0f0010ef          	jal	80004cf6 <releasesleep>
    acquire(&itable.lock);
    80003c0a:	0001d517          	auipc	a0,0x1d
    80003c0e:	ac650513          	addi	a0,a0,-1338 # 800206d0 <itable>
    80003c12:	848fd0ef          	jal	80000c5a <acquire>
    80003c16:	6902                	ld	s2,0(sp)
    80003c18:	bf91                	j	80003b6c <iput+0x20>

0000000080003c1a <iunlockput>:
{
    80003c1a:	1101                	addi	sp,sp,-32
    80003c1c:	ec06                	sd	ra,24(sp)
    80003c1e:	e822                	sd	s0,16(sp)
    80003c20:	e426                	sd	s1,8(sp)
    80003c22:	1000                	addi	s0,sp,32
    80003c24:	84aa                	mv	s1,a0
  iunlock(ip);
    80003c26:	e09ff0ef          	jal	80003a2e <iunlock>
  iput(ip);
    80003c2a:	8526                	mv	a0,s1
    80003c2c:	f21ff0ef          	jal	80003b4c <iput>
}
    80003c30:	60e2                	ld	ra,24(sp)
    80003c32:	6442                	ld	s0,16(sp)
    80003c34:	64a2                	ld	s1,8(sp)
    80003c36:	6105                	addi	sp,sp,32
    80003c38:	8082                	ret

0000000080003c3a <ireclaim>:
  for (int inum = 1; inum < sb.ninodes; inum++) {
    80003c3a:	0001d717          	auipc	a4,0x1d
    80003c3e:	a8272703          	lw	a4,-1406(a4) # 800206bc <sb+0xc>
    80003c42:	4785                	li	a5,1
    80003c44:	0ae7fe63          	bgeu	a5,a4,80003d00 <ireclaim+0xc6>
{
    80003c48:	7139                	addi	sp,sp,-64
    80003c4a:	fc06                	sd	ra,56(sp)
    80003c4c:	f822                	sd	s0,48(sp)
    80003c4e:	f426                	sd	s1,40(sp)
    80003c50:	f04a                	sd	s2,32(sp)
    80003c52:	ec4e                	sd	s3,24(sp)
    80003c54:	e852                	sd	s4,16(sp)
    80003c56:	e456                	sd	s5,8(sp)
    80003c58:	e05a                	sd	s6,0(sp)
    80003c5a:	0080                	addi	s0,sp,64
    80003c5c:	8aaa                	mv	s5,a0
  for (int inum = 1; inum < sb.ninodes; inum++) {
    80003c5e:	84be                	mv	s1,a5
    struct buf *bp = bread(dev, IBLOCK(inum, sb));
    80003c60:	0001da17          	auipc	s4,0x1d
    80003c64:	a50a0a13          	addi	s4,s4,-1456 # 800206b0 <sb>
      printf("ireclaim: orphaned inode %d\n", inum);
    80003c68:	00006b17          	auipc	s6,0x6
    80003c6c:	a30b0b13          	addi	s6,s6,-1488 # 80009698 <etext+0x698>
    80003c70:	a099                	j	80003cb6 <ireclaim+0x7c>
    80003c72:	85ce                	mv	a1,s3
    80003c74:	855a                	mv	a0,s6
    80003c76:	8b7fc0ef          	jal	8000052c <printf>
      ip = iget(dev, inum);
    80003c7a:	85ce                	mv	a1,s3
    80003c7c:	8556                	mv	a0,s5
    80003c7e:	877ff0ef          	jal	800034f4 <iget>
    80003c82:	89aa                	mv	s3,a0
    brelse(bp);
    80003c84:	854a                	mv	a0,s2
    80003c86:	a1cff0ef          	jal	80002ea2 <brelse>
    if (ip) {
    80003c8a:	00098f63          	beqz	s3,80003ca8 <ireclaim+0x6e>
      begin_op();
    80003c8e:	38b000ef          	jal	80004818 <begin_op>
      ilock(ip);
    80003c92:	854e                	mv	a0,s3
    80003c94:	ca9ff0ef          	jal	8000393c <ilock>
      iunlock(ip);
    80003c98:	854e                	mv	a0,s3
    80003c9a:	d95ff0ef          	jal	80003a2e <iunlock>
      iput(ip);
    80003c9e:	854e                	mv	a0,s3
    80003ca0:	eadff0ef          	jal	80003b4c <iput>
      end_op();
    80003ca4:	495000ef          	jal	80004938 <end_op>
  for (int inum = 1; inum < sb.ninodes; inum++) {
    80003ca8:	0485                	addi	s1,s1,1
    80003caa:	00ca2703          	lw	a4,12(s4)
    80003cae:	0004879b          	sext.w	a5,s1
    80003cb2:	02e7fd63          	bgeu	a5,a4,80003cec <ireclaim+0xb2>
    80003cb6:	0004899b          	sext.w	s3,s1
    struct buf *bp = bread(dev, IBLOCK(inum, sb));
    80003cba:	0044d593          	srli	a1,s1,0x4
    80003cbe:	018a2783          	lw	a5,24(s4)
    80003cc2:	9dbd                	addw	a1,a1,a5
    80003cc4:	8556                	mv	a0,s5
    80003cc6:	f31fe0ef          	jal	80002bf6 <bread>
    80003cca:	892a                	mv	s2,a0
    struct dinode *dip = (struct dinode *)bp->data + inum % IPB;
    80003ccc:	05850793          	addi	a5,a0,88
    80003cd0:	00f9f713          	andi	a4,s3,15
    80003cd4:	071a                	slli	a4,a4,0x6
    80003cd6:	97ba                	add	a5,a5,a4
    if (dip->type != 0 && dip->nlink == 0) {  // is an orphaned inode
    80003cd8:	00079703          	lh	a4,0(a5)
    80003cdc:	c701                	beqz	a4,80003ce4 <ireclaim+0xaa>
    80003cde:	00679783          	lh	a5,6(a5)
    80003ce2:	dbc1                	beqz	a5,80003c72 <ireclaim+0x38>
    brelse(bp);
    80003ce4:	854a                	mv	a0,s2
    80003ce6:	9bcff0ef          	jal	80002ea2 <brelse>
    if (ip) {
    80003cea:	bf7d                	j	80003ca8 <ireclaim+0x6e>
}
    80003cec:	70e2                	ld	ra,56(sp)
    80003cee:	7442                	ld	s0,48(sp)
    80003cf0:	74a2                	ld	s1,40(sp)
    80003cf2:	7902                	ld	s2,32(sp)
    80003cf4:	69e2                	ld	s3,24(sp)
    80003cf6:	6a42                	ld	s4,16(sp)
    80003cf8:	6aa2                	ld	s5,8(sp)
    80003cfa:	6b02                	ld	s6,0(sp)
    80003cfc:	6121                	addi	sp,sp,64
    80003cfe:	8082                	ret
    80003d00:	8082                	ret

0000000080003d02 <fsinit>:
fsinit(int dev) {
    80003d02:	1101                	addi	sp,sp,-32
    80003d04:	ec06                	sd	ra,24(sp)
    80003d06:	e822                	sd	s0,16(sp)
    80003d08:	e426                	sd	s1,8(sp)
    80003d0a:	e04a                	sd	s2,0(sp)
    80003d0c:	1000                	addi	s0,sp,32
    80003d0e:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    80003d10:	4585                	li	a1,1
    80003d12:	ee5fe0ef          	jal	80002bf6 <bread>
    80003d16:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    80003d18:	02000613          	li	a2,32
    80003d1c:	05850593          	addi	a1,a0,88
    80003d20:	0001d517          	auipc	a0,0x1d
    80003d24:	99050513          	addi	a0,a0,-1648 # 800206b0 <sb>
    80003d28:	862fd0ef          	jal	80000d8a <memmove>
  brelse(bp);
    80003d2c:	8526                	mv	a0,s1
    80003d2e:	974ff0ef          	jal	80002ea2 <brelse>
  if(sb.magic != FSMAGIC)
    80003d32:	0001d717          	auipc	a4,0x1d
    80003d36:	97e72703          	lw	a4,-1666(a4) # 800206b0 <sb>
    80003d3a:	102037b7          	lui	a5,0x10203
    80003d3e:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    80003d42:	02f71263          	bne	a4,a5,80003d66 <fsinit+0x64>
  initlog(dev, &sb);
    80003d46:	0001d597          	auipc	a1,0x1d
    80003d4a:	96a58593          	addi	a1,a1,-1686 # 800206b0 <sb>
    80003d4e:	854a                	mv	a0,s2
    80003d50:	16d000ef          	jal	800046bc <initlog>
  ireclaim(dev);
    80003d54:	854a                	mv	a0,s2
    80003d56:	ee5ff0ef          	jal	80003c3a <ireclaim>
}
    80003d5a:	60e2                	ld	ra,24(sp)
    80003d5c:	6442                	ld	s0,16(sp)
    80003d5e:	64a2                	ld	s1,8(sp)
    80003d60:	6902                	ld	s2,0(sp)
    80003d62:	6105                	addi	sp,sp,32
    80003d64:	8082                	ret
    panic("invalid file system");
    80003d66:	00006517          	auipc	a0,0x6
    80003d6a:	95250513          	addi	a0,a0,-1710 # 800096b8 <etext+0x6b8>
    80003d6e:	ae9fc0ef          	jal	80000856 <panic>

0000000080003d72 <stati>:

// Copy stat information from inode.
void
stati(struct inode *ip, struct stat *st)
{
    80003d72:	1141                	addi	sp,sp,-16
    80003d74:	e406                	sd	ra,8(sp)
    80003d76:	e022                	sd	s0,0(sp)
    80003d78:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80003d7a:	411c                	lw	a5,0(a0)
    80003d7c:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80003d7e:	415c                	lw	a5,4(a0)
    80003d80:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80003d82:	04451783          	lh	a5,68(a0)
    80003d86:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80003d8a:	04a51783          	lh	a5,74(a0)
    80003d8e:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80003d92:	04c56783          	lwu	a5,76(a0)
    80003d96:	e99c                	sd	a5,16(a1)
}
    80003d98:	60a2                	ld	ra,8(sp)
    80003d9a:	6402                	ld	s0,0(sp)
    80003d9c:	0141                	addi	sp,sp,16
    80003d9e:	8082                	ret

0000000080003da0 <readi>:

// Read data from inode.
int
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
    80003da0:	7119                	addi	sp,sp,-128
    80003da2:	fc86                	sd	ra,120(sp)
    80003da4:	f8a2                	sd	s0,112(sp)
    80003da6:	0100                	addi	s0,sp,128
    80003da8:	f8b43423          	sd	a1,-120(s0)
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003dac:	457c                	lw	a5,76(a0)
    80003dae:	10d7e563          	bltu	a5,a3,80003eb8 <readi+0x118>
    80003db2:	f4a6                	sd	s1,104(sp)
    80003db4:	f0ca                	sd	s2,96(sp)
    80003db6:	e0da                	sd	s6,64(sp)
    80003db8:	fc5e                	sd	s7,56(sp)
    80003dba:	84aa                	mv	s1,a0
    80003dbc:	8b32                	mv	s6,a2
    80003dbe:	8936                	mv	s2,a3
    80003dc0:	8bba                	mv	s7,a4
    80003dc2:	9f35                	addw	a4,a4,a3
    return 0;
    80003dc4:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80003dc6:	0ed76b63          	bltu	a4,a3,80003ebc <readi+0x11c>
    80003dca:	e8d2                	sd	s4,80(sp)
  if(off + n > ip->size)
    80003dcc:	00e7f463          	bgeu	a5,a4,80003dd4 <readi+0x34>
    n = ip->size - off;
    80003dd0:	40d78bbb          	subw	s7,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003dd4:	0c0b8063          	beqz	s7,80003e94 <readi+0xf4>
    80003dd8:	ecce                	sd	s3,88(sp)
    80003dda:	e4d6                	sd	s5,72(sp)
    80003ddc:	f862                	sd	s8,48(sp)
    80003dde:	f466                	sd	s9,40(sp)
    80003de0:	f06a                	sd	s10,32(sp)
    80003de2:	ec6e                	sd	s11,24(sp)
    80003de4:	4a01                	li	s4,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003de6:	40000d13          	li	s10,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80003dea:	5cfd                	li	s9,-1
      brelse(bp);
      tot = -1;
      break;
    }
    inode_report("READI", ip,
    80003dec:	00006d97          	auipc	s11,0x6
    80003df0:	8e4d8d93          	addi	s11,s11,-1820 # 800096d0 <etext+0x6d0>
    80003df4:	a881                	j	80003e44 <readi+0xa4>
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80003df6:	020a9c13          	slli	s8,s5,0x20
    80003dfa:	020c5c13          	srli	s8,s8,0x20
    80003dfe:	05898613          	addi	a2,s3,88
    80003e02:	86e2                	mv	a3,s8
    80003e04:	963e                	add	a2,a2,a5
    80003e06:	85da                	mv	a1,s6
    80003e08:	f8843503          	ld	a0,-120(s0)
    80003e0c:	cccfe0ef          	jal	800022d8 <either_copyout>
    80003e10:	07950063          	beq	a0,s9,80003e70 <readi+0xd0>
    inode_report("READI", ip,
    80003e14:	88ee                	mv	a7,s11
    80003e16:	4805                	li	a6,1
    80003e18:	44fc                	lw	a5,76(s1)
    80003e1a:	04449703          	lh	a4,68(s1)
    80003e1e:	40b4                	lw	a3,64(s1)
    80003e20:	4490                	lw	a2,8(s1)
    80003e22:	85a6                	mv	a1,s1
    80003e24:	00006517          	auipc	a0,0x6
    80003e28:	8c450513          	addi	a0,a0,-1852 # 800096e8 <etext+0x6e8>
    80003e2c:	dc8ff0ef          	jal	800033f4 <inode_report>
    ip->ref, ip->valid,
    ip->type, ip->size,
    1,
    "Reading from inode");
    brelse(bp);
    80003e30:	854e                	mv	a0,s3
    80003e32:	870ff0ef          	jal	80002ea2 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003e36:	014a8a3b          	addw	s4,s5,s4
    80003e3a:	012a893b          	addw	s2,s5,s2
    80003e3e:	9b62                	add	s6,s6,s8
    80003e40:	057a7363          	bgeu	s4,s7,80003e86 <readi+0xe6>
    uint addr = bmap(ip, off/BSIZE);
    80003e44:	00a9559b          	srliw	a1,s2,0xa
    80003e48:	8526                	mv	a0,s1
    80003e4a:	f96ff0ef          	jal	800035e0 <bmap>
    80003e4e:	85aa                	mv	a1,a0
    if(addr == 0)
    80003e50:	c521                	beqz	a0,80003e98 <readi+0xf8>
    bp = bread(ip->dev, addr);
    80003e52:	4088                	lw	a0,0(s1)
    80003e54:	da3fe0ef          	jal	80002bf6 <bread>
    80003e58:	89aa                	mv	s3,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003e5a:	3ff97793          	andi	a5,s2,1023
    80003e5e:	40fd073b          	subw	a4,s10,a5
    80003e62:	414b86bb          	subw	a3,s7,s4
    80003e66:	8aba                	mv	s5,a4
    80003e68:	f8e6f7e3          	bgeu	a3,a4,80003df6 <readi+0x56>
    80003e6c:	8ab6                	mv	s5,a3
    80003e6e:	b761                	j	80003df6 <readi+0x56>
      brelse(bp);
    80003e70:	854e                	mv	a0,s3
    80003e72:	830ff0ef          	jal	80002ea2 <brelse>
      tot = -1;
    80003e76:	5a7d                	li	s4,-1
      break;
    80003e78:	69e6                	ld	s3,88(sp)
    80003e7a:	6aa6                	ld	s5,72(sp)
    80003e7c:	7c42                	ld	s8,48(sp)
    80003e7e:	7ca2                	ld	s9,40(sp)
    80003e80:	7d02                	ld	s10,32(sp)
    80003e82:	6de2                	ld	s11,24(sp)
    80003e84:	a005                	j	80003ea4 <readi+0x104>
    80003e86:	69e6                	ld	s3,88(sp)
    80003e88:	6aa6                	ld	s5,72(sp)
    80003e8a:	7c42                	ld	s8,48(sp)
    80003e8c:	7ca2                	ld	s9,40(sp)
    80003e8e:	7d02                	ld	s10,32(sp)
    80003e90:	6de2                	ld	s11,24(sp)
    80003e92:	a809                	j	80003ea4 <readi+0x104>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003e94:	8a5e                	mv	s4,s7
    80003e96:	a039                	j	80003ea4 <readi+0x104>
    80003e98:	69e6                	ld	s3,88(sp)
    80003e9a:	6aa6                	ld	s5,72(sp)
    80003e9c:	7c42                	ld	s8,48(sp)
    80003e9e:	7ca2                	ld	s9,40(sp)
    80003ea0:	7d02                	ld	s10,32(sp)
    80003ea2:	6de2                	ld	s11,24(sp)
  }
  return tot;
    80003ea4:	8552                	mv	a0,s4
    80003ea6:	74a6                	ld	s1,104(sp)
    80003ea8:	7906                	ld	s2,96(sp)
    80003eaa:	6a46                	ld	s4,80(sp)
    80003eac:	6b06                	ld	s6,64(sp)
    80003eae:	7be2                	ld	s7,56(sp)
}
    80003eb0:	70e6                	ld	ra,120(sp)
    80003eb2:	7446                	ld	s0,112(sp)
    80003eb4:	6109                	addi	sp,sp,128
    80003eb6:	8082                	ret
    return 0;
    80003eb8:	4501                	li	a0,0
    80003eba:	bfdd                	j	80003eb0 <readi+0x110>
    80003ebc:	74a6                	ld	s1,104(sp)
    80003ebe:	7906                	ld	s2,96(sp)
    80003ec0:	6b06                	ld	s6,64(sp)
    80003ec2:	7be2                	ld	s7,56(sp)
    80003ec4:	b7f5                	j	80003eb0 <readi+0x110>

0000000080003ec6 <writei>:

// Write data to inode.
int
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
    80003ec6:	7119                	addi	sp,sp,-128
    80003ec8:	fc86                	sd	ra,120(sp)
    80003eca:	f8a2                	sd	s0,112(sp)
    80003ecc:	0100                	addi	s0,sp,128
  uint tot, m;
  struct buf *bp;
  int old_size = ip->size;
    80003ece:	457c                	lw	a5,76(a0)
    80003ed0:	f8f43423          	sd	a5,-120(s0)
  if(off > ip->size || off + n < off)
    80003ed4:	10d7eb63          	bltu	a5,a3,80003fea <writei+0x124>
    80003ed8:	f0ca                	sd	s2,96(sp)
    80003eda:	e4d6                	sd	s5,72(sp)
    80003edc:	e0da                	sd	s6,64(sp)
    80003ede:	f862                	sd	s8,48(sp)
    80003ee0:	f466                	sd	s9,40(sp)
    80003ee2:	8b2a                	mv	s6,a0
    80003ee4:	8cae                	mv	s9,a1
    80003ee6:	8ab2                	mv	s5,a2
    80003ee8:	8936                	mv	s2,a3
    80003eea:	8c3a                	mv	s8,a4
    80003eec:	00e687bb          	addw	a5,a3,a4
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80003ef0:	00043737          	lui	a4,0x43
    80003ef4:	0ef76d63          	bltu	a4,a5,80003fee <writei+0x128>
    80003ef8:	0ed7eb63          	bltu	a5,a3,80003fee <writei+0x128>
    80003efc:	e8d2                	sd	s4,80(sp)
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003efe:	0c0c0e63          	beqz	s8,80003fda <writei+0x114>
    80003f02:	f4a6                	sd	s1,104(sp)
    80003f04:	ecce                	sd	s3,88(sp)
    80003f06:	fc5e                	sd	s7,56(sp)
    80003f08:	f06a                	sd	s10,32(sp)
    80003f0a:	ec6e                	sd	s11,24(sp)
    80003f0c:	4a01                	li	s4,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003f0e:	40000d93          	li	s11,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80003f12:	5d7d                	li	s10,-1
    80003f14:	a825                	j	80003f4c <writei+0x86>
    80003f16:	02099b93          	slli	s7,s3,0x20
    80003f1a:	020bdb93          	srli	s7,s7,0x20
    80003f1e:	05848513          	addi	a0,s1,88
    80003f22:	86de                	mv	a3,s7
    80003f24:	8656                	mv	a2,s5
    80003f26:	85e6                	mv	a1,s9
    80003f28:	953e                	add	a0,a0,a5
    80003f2a:	bf8fe0ef          	jal	80002322 <either_copyin>
    80003f2e:	05a50663          	beq	a0,s10,80003f7a <writei+0xb4>
      brelse(bp);
      break;
    }
    log_write(bp);
    80003f32:	8526                	mv	a0,s1
    80003f34:	45d000ef          	jal	80004b90 <log_write>
    brelse(bp);
    80003f38:	8526                	mv	a0,s1
    80003f3a:	f69fe0ef          	jal	80002ea2 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003f3e:	01498a3b          	addw	s4,s3,s4
    80003f42:	0129893b          	addw	s2,s3,s2
    80003f46:	9ade                	add	s5,s5,s7
    80003f48:	038a7c63          	bgeu	s4,s8,80003f80 <writei+0xba>
    uint addr = bmap(ip, off/BSIZE);
    80003f4c:	00a9559b          	srliw	a1,s2,0xa
    80003f50:	855a                	mv	a0,s6
    80003f52:	e8eff0ef          	jal	800035e0 <bmap>
    80003f56:	85aa                	mv	a1,a0
    if(addr == 0)
    80003f58:	c505                	beqz	a0,80003f80 <writei+0xba>
    bp = bread(ip->dev, addr);
    80003f5a:	000b2503          	lw	a0,0(s6)
    80003f5e:	c99fe0ef          	jal	80002bf6 <bread>
    80003f62:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003f64:	3ff97793          	andi	a5,s2,1023
    80003f68:	40fd873b          	subw	a4,s11,a5
    80003f6c:	414c06bb          	subw	a3,s8,s4
    80003f70:	89ba                	mv	s3,a4
    80003f72:	fae6f2e3          	bgeu	a3,a4,80003f16 <writei+0x50>
    80003f76:	89b6                	mv	s3,a3
    80003f78:	bf79                	j	80003f16 <writei+0x50>
      brelse(bp);
    80003f7a:	8526                	mv	a0,s1
    80003f7c:	f27fe0ef          	jal	80002ea2 <brelse>
  }

  if(off > ip->size)
    80003f80:	04cb2783          	lw	a5,76(s6)
    80003f84:	0527fd63          	bgeu	a5,s2,80003fde <writei+0x118>
    ip->size = off;
    80003f88:	052b2623          	sw	s2,76(s6)
    80003f8c:	74a6                	ld	s1,104(sp)
    80003f8e:	69e6                	ld	s3,88(sp)
    80003f90:	7be2                	ld	s7,56(sp)
    80003f92:	7d02                	ld	s10,32(sp)
    80003f94:	6de2                	ld	s11,24(sp)
  inode_report("WRITEI", ip,
    80003f96:	00005897          	auipc	a7,0x5
    80003f9a:	75a88893          	addi	a7,a7,1882 # 800096f0 <etext+0x6f0>
    80003f9e:	4805                	li	a6,1
    80003fa0:	f8843783          	ld	a5,-120(s0)
    80003fa4:	044b1703          	lh	a4,68(s6)
    80003fa8:	040b2683          	lw	a3,64(s6)
    80003fac:	008b2603          	lw	a2,8(s6)
    80003fb0:	85da                	mv	a1,s6
    80003fb2:	00005517          	auipc	a0,0x5
    80003fb6:	75650513          	addi	a0,a0,1878 # 80009708 <etext+0x708>
    80003fba:	c3aff0ef          	jal	800033f4 <inode_report>
    ip->ref, ip->valid,
    ip->type, old_size,
    1,
    "Writing to inode");

  iupdate(ip);
    80003fbe:	855a                	mv	a0,s6
    80003fc0:	885ff0ef          	jal	80003844 <iupdate>

  return tot;
    80003fc4:	8552                	mv	a0,s4
    80003fc6:	7906                	ld	s2,96(sp)
    80003fc8:	6a46                	ld	s4,80(sp)
    80003fca:	6aa6                	ld	s5,72(sp)
    80003fcc:	6b06                	ld	s6,64(sp)
    80003fce:	7c42                	ld	s8,48(sp)
    80003fd0:	7ca2                	ld	s9,40(sp)
}
    80003fd2:	70e6                	ld	ra,120(sp)
    80003fd4:	7446                	ld	s0,112(sp)
    80003fd6:	6109                	addi	sp,sp,128
    80003fd8:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003fda:	8a62                	mv	s4,s8
    80003fdc:	bf6d                	j	80003f96 <writei+0xd0>
    80003fde:	74a6                	ld	s1,104(sp)
    80003fe0:	69e6                	ld	s3,88(sp)
    80003fe2:	7be2                	ld	s7,56(sp)
    80003fe4:	7d02                	ld	s10,32(sp)
    80003fe6:	6de2                	ld	s11,24(sp)
    80003fe8:	b77d                	j	80003f96 <writei+0xd0>
    return -1;
    80003fea:	557d                	li	a0,-1
    80003fec:	b7dd                	j	80003fd2 <writei+0x10c>
    return -1;
    80003fee:	557d                	li	a0,-1
    80003ff0:	7906                	ld	s2,96(sp)
    80003ff2:	6aa6                	ld	s5,72(sp)
    80003ff4:	6b06                	ld	s6,64(sp)
    80003ff6:	7c42                	ld	s8,48(sp)
    80003ff8:	7ca2                	ld	s9,40(sp)
    80003ffa:	bfe1                	j	80003fd2 <writei+0x10c>

0000000080003ffc <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80003ffc:	1141                	addi	sp,sp,-16
    80003ffe:	e406                	sd	ra,8(sp)
    80004000:	e022                	sd	s0,0(sp)
    80004002:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80004004:	4639                	li	a2,14
    80004006:	df9fc0ef          	jal	80000dfe <strncmp>
}
    8000400a:	60a2                	ld	ra,8(sp)
    8000400c:	6402                	ld	s0,0(sp)
    8000400e:	0141                	addi	sp,sp,16
    80004010:	8082                	ret

0000000080004012 <dirlookup>:

// Look for a directory entry in a directory.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80004012:	711d                	addi	sp,sp,-96
    80004014:	ec86                	sd	ra,88(sp)
    80004016:	e8a2                	sd	s0,80(sp)
    80004018:	e4a6                	sd	s1,72(sp)
    8000401a:	e0ca                	sd	s2,64(sp)
    8000401c:	fc4e                	sd	s3,56(sp)
    8000401e:	f852                	sd	s4,48(sp)
    80004020:	f456                	sd	s5,40(sp)
    80004022:	f05a                	sd	s6,32(sp)
    80004024:	ec5e                	sd	s7,24(sp)
    80004026:	1080                	addi	s0,sp,96
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80004028:	04451703          	lh	a4,68(a0)
    8000402c:	4785                	li	a5,1
    8000402e:	04f71763          	bne	a4,a5,8000407c <dirlookup+0x6a>
    80004032:	892a                	mv	s2,a0
    80004034:	8aae                	mv	s5,a1
    80004036:	8bb2                	mv	s7,a2
    name,
    -1,
    -1,
    "Starting directory lookup"
);}
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004038:	457c                	lw	a5,76(a0)
    8000403a:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000403c:	fa040a13          	addi	s4,s0,-96
    80004040:	49c1                	li	s3,16
      panic("dirlookup read");
    if(de.inum == 0)
      continue;
    if(namecmp(name, de.name) == 0){
    80004042:	fa240b13          	addi	s6,s0,-94
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004046:	efa1                	bnez	a5,8000409e <dirlookup+0x8c>
    "Directory entry found"
);
      return iget(dp->dev, inum);
    }
  }
  dir_report(
    80004048:	00005797          	auipc	a5,0x5
    8000404c:	71878793          	addi	a5,a5,1816 # 80009760 <etext+0x760>
    80004050:	577d                	li	a4,-1
    80004052:	86ba                	mv	a3,a4
    80004054:	8656                	mv	a2,s5
    80004056:	85ca                	mv	a1,s2
    80004058:	00005517          	auipc	a0,0x5
    8000405c:	72850513          	addi	a0,a0,1832 # 80009780 <etext+0x780>
    80004060:	fa1fe0ef          	jal	80003000 <dir_report>
    name,
    -1,
    -1,
    "Directory entry not found"
);
  return 0;
    80004064:	4501                	li	a0,0
}
    80004066:	60e6                	ld	ra,88(sp)
    80004068:	6446                	ld	s0,80(sp)
    8000406a:	64a6                	ld	s1,72(sp)
    8000406c:	6906                	ld	s2,64(sp)
    8000406e:	79e2                	ld	s3,56(sp)
    80004070:	7a42                	ld	s4,48(sp)
    80004072:	7aa2                	ld	s5,40(sp)
    80004074:	7b02                	ld	s6,32(sp)
    80004076:	6be2                	ld	s7,24(sp)
    80004078:	6125                	addi	sp,sp,96
    8000407a:	8082                	ret
   { panic("dirlookup not DIR");
    8000407c:	00005517          	auipc	a0,0x5
    80004080:	69450513          	addi	a0,a0,1684 # 80009710 <etext+0x710>
    80004084:	fd2fc0ef          	jal	80000856 <panic>
      panic("dirlookup read");
    80004088:	00005517          	auipc	a0,0x5
    8000408c:	6a050513          	addi	a0,a0,1696 # 80009728 <etext+0x728>
    80004090:	fc6fc0ef          	jal	80000856 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004094:	24c1                	addiw	s1,s1,16
    80004096:	04c92783          	lw	a5,76(s2)
    8000409a:	faf4f7e3          	bgeu	s1,a5,80004048 <dirlookup+0x36>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000409e:	874e                	mv	a4,s3
    800040a0:	86a6                	mv	a3,s1
    800040a2:	8652                	mv	a2,s4
    800040a4:	4581                	li	a1,0
    800040a6:	854a                	mv	a0,s2
    800040a8:	cf9ff0ef          	jal	80003da0 <readi>
    800040ac:	fd351ee3          	bne	a0,s3,80004088 <dirlookup+0x76>
    if(de.inum == 0)
    800040b0:	fa045783          	lhu	a5,-96(s0)
    800040b4:	d3e5                	beqz	a5,80004094 <dirlookup+0x82>
    if(namecmp(name, de.name) == 0){
    800040b6:	85da                	mv	a1,s6
    800040b8:	8556                	mv	a0,s5
    800040ba:	f43ff0ef          	jal	80003ffc <namecmp>
    800040be:	f979                	bnez	a0,80004094 <dirlookup+0x82>
      if(poff)
    800040c0:	000b8463          	beqz	s7,800040c8 <dirlookup+0xb6>
        *poff = off;
    800040c4:	009ba023          	sw	s1,0(s7)
      inum = de.inum;
    800040c8:	fa045983          	lhu	s3,-96(s0)
      dir_report(
    800040cc:	00005797          	auipc	a5,0x5
    800040d0:	66c78793          	addi	a5,a5,1644 # 80009738 <etext+0x738>
    800040d4:	8726                	mv	a4,s1
    800040d6:	86ce                	mv	a3,s3
    800040d8:	8656                	mv	a2,s5
    800040da:	85ca                	mv	a1,s2
    800040dc:	00005517          	auipc	a0,0x5
    800040e0:	67450513          	addi	a0,a0,1652 # 80009750 <etext+0x750>
    800040e4:	f1dfe0ef          	jal	80003000 <dir_report>
      return iget(dp->dev, inum);
    800040e8:	85ce                	mv	a1,s3
    800040ea:	00092503          	lw	a0,0(s2)
    800040ee:	c06ff0ef          	jal	800034f4 <iget>
    800040f2:	bf95                	j	80004066 <dirlookup+0x54>

00000000800040f4 <namex>:
}

// Look up and return the inode for a path name.
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    800040f4:	7159                	addi	sp,sp,-112
    800040f6:	f486                	sd	ra,104(sp)
    800040f8:	f0a2                	sd	s0,96(sp)
    800040fa:	eca6                	sd	s1,88(sp)
    800040fc:	e8ca                	sd	s2,80(sp)
    800040fe:	e4ce                	sd	s3,72(sp)
    80004100:	e0d2                	sd	s4,64(sp)
    80004102:	fc56                	sd	s5,56(sp)
    80004104:	f85a                	sd	s6,48(sp)
    80004106:	f45e                	sd	s7,40(sp)
    80004108:	f062                	sd	s8,32(sp)
    8000410a:	ec66                	sd	s9,24(sp)
    8000410c:	e86a                	sd	s10,16(sp)
    8000410e:	e46e                	sd	s11,8(sp)
    80004110:	1880                	addi	s0,sp,112
    80004112:	84aa                	mv	s1,a0
    80004114:	8bae                	mv	s7,a1
    80004116:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    80004118:	00054703          	lbu	a4,0(a0)
    8000411c:	02f00793          	li	a5,47
    80004120:	04f70963          	beq	a4,a5,80004172 <namex+0x7e>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80004124:	845fd0ef          	jal	80001968 <myproc>
    80004128:	15053503          	ld	a0,336(a0)
    8000412c:	fb8ff0ef          	jal	800038e4 <idup>
    80004130:	8a2a                	mv	s4,a0
  path_report(
    80004132:	00005717          	auipc	a4,0x5
    80004136:	65e70713          	addi	a4,a4,1630 # 80009790 <etext+0x790>
    8000413a:	86d2                	mv	a3,s4
    8000413c:	00006617          	auipc	a2,0x6
    80004140:	9b460613          	addi	a2,a2,-1612 # 80009af0 <etext+0xaf0>
    80004144:	85a6                	mv	a1,s1
    80004146:	00005517          	auipc	a0,0x5
    8000414a:	66a50513          	addi	a0,a0,1642 # 800097b0 <etext+0x7b0>
    8000414e:	f81fe0ef          	jal	800030ce <path_report>
  while(*path == '/')
    80004152:	02f00993          	li	s3,47
    path_report(
    80004156:	00005d97          	auipc	s11,0x5
    8000415a:	692d8d93          	addi	s11,s11,1682 # 800097e8 <etext+0x7e8>
  if(len >= DIRSIZ)
    8000415e:	4d35                	li	s10,13
    "",
    ip,
    "Starting pathname resolution"
);
  while((path = skipelem(path, name)) != 0){
    path_report(
    80004160:	00005c97          	auipc	s9,0x5
    80004164:	660c8c93          	addi	s9,s9,1632 # 800097c0 <etext+0x7c0>
    80004168:	00005c17          	auipc	s8,0x5
    8000416c:	670c0c13          	addi	s8,s8,1648 # 800097d8 <etext+0x7d8>
  while((path = skipelem(path, name)) != 0){
    80004170:	a845                	j	80004220 <namex+0x12c>
    ip = iget(ROOTDEV, ROOTINO);
    80004172:	4585                	li	a1,1
    80004174:	852e                	mv	a0,a1
    80004176:	b7eff0ef          	jal	800034f4 <iget>
    8000417a:	8a2a                	mv	s4,a0
    8000417c:	bf5d                	j	80004132 <namex+0x3e>
    ip,
    "Traversing pathname"
);
    ilock(ip);
    if(ip->type != T_DIR){
      iunlockput(ip);
    8000417e:	8552                	mv	a0,s4
    80004180:	a9bff0ef          	jal	80003c1a <iunlockput>
      
      return 0;
    80004184:	4a01                	li	s4,0
    name,
    ip,
    "Path resolved successfully"
);
  return ip;
}
    80004186:	8552                	mv	a0,s4
    80004188:	70a6                	ld	ra,104(sp)
    8000418a:	7406                	ld	s0,96(sp)
    8000418c:	64e6                	ld	s1,88(sp)
    8000418e:	6946                	ld	s2,80(sp)
    80004190:	69a6                	ld	s3,72(sp)
    80004192:	6a06                	ld	s4,64(sp)
    80004194:	7ae2                	ld	s5,56(sp)
    80004196:	7b42                	ld	s6,48(sp)
    80004198:	7ba2                	ld	s7,40(sp)
    8000419a:	7c02                	ld	s8,32(sp)
    8000419c:	6ce2                	ld	s9,24(sp)
    8000419e:	6d42                	ld	s10,16(sp)
    800041a0:	6da2                	ld	s11,8(sp)
    800041a2:	6165                	addi	sp,sp,112
    800041a4:	8082                	ret
      iunlock(ip);
    800041a6:	8552                	mv	a0,s4
    800041a8:	887ff0ef          	jal	80003a2e <iunlock>
      return ip;
    800041ac:	bfe9                	j	80004186 <namex+0x92>
      iunlockput(ip);
    800041ae:	8552                	mv	a0,s4
    800041b0:	a6bff0ef          	jal	80003c1a <iunlockput>
      return 0;
    800041b4:	8a4a                	mv	s4,s2
    800041b6:	bfc1                	j	80004186 <namex+0x92>
  len = path - s;
    800041b8:	40990633          	sub	a2,s2,s1
    800041bc:	00060b1b          	sext.w	s6,a2
  if(len >= DIRSIZ)
    800041c0:	096d5c63          	bge	s10,s6,80004258 <namex+0x164>
    memmove(name, s, DIRSIZ);
    800041c4:	4639                	li	a2,14
    800041c6:	85a6                	mv	a1,s1
    800041c8:	8556                	mv	a0,s5
    800041ca:	bc1fc0ef          	jal	80000d8a <memmove>
    800041ce:	84ca                	mv	s1,s2
  while(*path == '/')
    800041d0:	0004c783          	lbu	a5,0(s1)
    800041d4:	01379763          	bne	a5,s3,800041e2 <namex+0xee>
    path++;
    800041d8:	0485                	addi	s1,s1,1
  while(*path == '/')
    800041da:	0004c783          	lbu	a5,0(s1)
    800041de:	ff378de3          	beq	a5,s3,800041d8 <namex+0xe4>
    path_report(
    800041e2:	8766                	mv	a4,s9
    800041e4:	86d2                	mv	a3,s4
    800041e6:	8656                	mv	a2,s5
    800041e8:	85a6                	mv	a1,s1
    800041ea:	8562                	mv	a0,s8
    800041ec:	ee3fe0ef          	jal	800030ce <path_report>
    ilock(ip);
    800041f0:	8552                	mv	a0,s4
    800041f2:	f4aff0ef          	jal	8000393c <ilock>
    if(ip->type != T_DIR){
    800041f6:	044a1703          	lh	a4,68(s4)
    800041fa:	4785                	li	a5,1
    800041fc:	f8f711e3          	bne	a4,a5,8000417e <namex+0x8a>
    if(nameiparent && *path == '\0'){
    80004200:	000b8563          	beqz	s7,8000420a <namex+0x116>
    80004204:	0004c783          	lbu	a5,0(s1)
    80004208:	dfd9                	beqz	a5,800041a6 <namex+0xb2>
    if((next = dirlookup(ip, name, 0)) == 0){
    8000420a:	4601                	li	a2,0
    8000420c:	85d6                	mv	a1,s5
    8000420e:	8552                	mv	a0,s4
    80004210:	e03ff0ef          	jal	80004012 <dirlookup>
    80004214:	892a                	mv	s2,a0
    80004216:	dd41                	beqz	a0,800041ae <namex+0xba>
    iunlockput(ip);
    80004218:	8552                	mv	a0,s4
    8000421a:	a01ff0ef          	jal	80003c1a <iunlockput>
    ip = next;
    8000421e:	8a4a                	mv	s4,s2
  while(*path == '/')
    80004220:	0004c783          	lbu	a5,0(s1)
    80004224:	01379763          	bne	a5,s3,80004232 <namex+0x13e>
    path++;
    80004228:	0485                	addi	s1,s1,1
  while(*path == '/')
    8000422a:	0004c783          	lbu	a5,0(s1)
    8000422e:	ff378de3          	beq	a5,s3,80004228 <namex+0x134>
  if(*path == 0)
    80004232:	cbad                	beqz	a5,800042a4 <namex+0x1b0>
  while(*path != '/' && *path != 0)
    80004234:	0004c783          	lbu	a5,0(s1)
    80004238:	fd178713          	addi	a4,a5,-47
    8000423c:	cb19                	beqz	a4,80004252 <namex+0x15e>
    8000423e:	cb91                	beqz	a5,80004252 <namex+0x15e>
    80004240:	8926                	mv	s2,s1
    path++;
    80004242:	0905                	addi	s2,s2,1
  while(*path != '/' && *path != 0)
    80004244:	00094783          	lbu	a5,0(s2)
    80004248:	fd178713          	addi	a4,a5,-47
    8000424c:	d735                	beqz	a4,800041b8 <namex+0xc4>
    8000424e:	fbf5                	bnez	a5,80004242 <namex+0x14e>
    80004250:	b7a5                	j	800041b8 <namex+0xc4>
    80004252:	8926                	mv	s2,s1
  len = path - s;
    80004254:	4b01                	li	s6,0
    80004256:	4601                	li	a2,0
    memmove(name, s, len);
    80004258:	2601                	sext.w	a2,a2
    8000425a:	85a6                	mv	a1,s1
    8000425c:	8556                	mv	a0,s5
    8000425e:	b2dfc0ef          	jal	80000d8a <memmove>
    name[len] = 0;
    80004262:	9b56                	add	s6,s6,s5
    80004264:	000b0023          	sb	zero,0(s6)
    path_report(
    80004268:	876e                	mv	a4,s11
    8000426a:	4681                	li	a3,0
    8000426c:	8656                	mv	a2,s5
    8000426e:	85a6                	mv	a1,s1
    80004270:	00005517          	auipc	a0,0x5
    80004274:	59050513          	addi	a0,a0,1424 # 80009800 <etext+0x800>
    80004278:	e57fe0ef          	jal	800030ce <path_report>
    8000427c:	84ca                	mv	s1,s2
    8000427e:	bf89                	j	800041d0 <namex+0xdc>
    iput(ip);
    80004280:	8552                	mv	a0,s4
    80004282:	8cbff0ef          	jal	80003b4c <iput>
    path_report(
    80004286:	00005717          	auipc	a4,0x5
    8000428a:	58a70713          	addi	a4,a4,1418 # 80009810 <etext+0x810>
    8000428e:	86d2                	mv	a3,s4
    80004290:	8656                	mv	a2,s5
    80004292:	4581                	li	a1,0
    80004294:	00005517          	auipc	a0,0x5
    80004298:	59450513          	addi	a0,a0,1428 # 80009828 <etext+0x828>
    8000429c:	e33fe0ef          	jal	800030ce <path_report>
    return 0;
    800042a0:	4a01                	li	s4,0
    800042a2:	b5d5                	j	80004186 <namex+0x92>
  if(nameiparent){
    800042a4:	fc0b9ee3          	bnez	s7,80004280 <namex+0x18c>
  path_report(
    800042a8:	00005717          	auipc	a4,0x5
    800042ac:	59070713          	addi	a4,a4,1424 # 80009838 <etext+0x838>
    800042b0:	86d2                	mv	a3,s4
    800042b2:	8656                	mv	a2,s5
    800042b4:	4581                	li	a1,0
    800042b6:	00005517          	auipc	a0,0x5
    800042ba:	5a250513          	addi	a0,a0,1442 # 80009858 <etext+0x858>
    800042be:	e11fe0ef          	jal	800030ce <path_report>
  return ip;
    800042c2:	b5d1                	j	80004186 <namex+0x92>

00000000800042c4 <dirlink>:
{
    800042c4:	715d                	addi	sp,sp,-80
    800042c6:	e486                	sd	ra,72(sp)
    800042c8:	e0a2                	sd	s0,64(sp)
    800042ca:	f84a                	sd	s2,48(sp)
    800042cc:	ec56                	sd	s5,24(sp)
    800042ce:	e85a                	sd	s6,16(sp)
    800042d0:	0880                	addi	s0,sp,80
    800042d2:	892a                	mv	s2,a0
    800042d4:	8aae                	mv	s5,a1
    800042d6:	8b32                	mv	s6,a2
  dir_report(
    800042d8:	00005797          	auipc	a5,0x5
    800042dc:	59078793          	addi	a5,a5,1424 # 80009868 <etext+0x868>
    800042e0:	577d                	li	a4,-1
    800042e2:	86b2                	mv	a3,a2
    800042e4:	862e                	mv	a2,a1
    800042e6:	85aa                	mv	a1,a0
    800042e8:	00005517          	auipc	a0,0x5
    800042ec:	5a050513          	addi	a0,a0,1440 # 80009888 <etext+0x888>
    800042f0:	d11fe0ef          	jal	80003000 <dir_report>
  if((ip = dirlookup(dp, name, 0)) != 0){
    800042f4:	4601                	li	a2,0
    800042f6:	85d6                	mv	a1,s5
    800042f8:	854a                	mv	a0,s2
    800042fa:	d19ff0ef          	jal	80004012 <dirlookup>
    800042fe:	ed1d                	bnez	a0,8000433c <dirlink+0x78>
    80004300:	fc26                	sd	s1,56(sp)
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004302:	04c92483          	lw	s1,76(s2)
    80004306:	c4ad                	beqz	s1,80004370 <dirlink+0xac>
    80004308:	f44e                	sd	s3,40(sp)
    8000430a:	f052                	sd	s4,32(sp)
    8000430c:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000430e:	fb040a13          	addi	s4,s0,-80
    80004312:	49c1                	li	s3,16
    80004314:	874e                	mv	a4,s3
    80004316:	86a6                	mv	a3,s1
    80004318:	8652                	mv	a2,s4
    8000431a:	4581                	li	a1,0
    8000431c:	854a                	mv	a0,s2
    8000431e:	a83ff0ef          	jal	80003da0 <readi>
    80004322:	03351f63          	bne	a0,s3,80004360 <dirlink+0x9c>
    if(de.inum == 0)
    80004326:	fb045783          	lhu	a5,-80(s0)
    8000432a:	c3a9                	beqz	a5,8000436c <dirlink+0xa8>
  for(off = 0; off < dp->size; off += sizeof(de)){
    8000432c:	24c1                	addiw	s1,s1,16
    8000432e:	04c92783          	lw	a5,76(s2)
    80004332:	fef4e1e3          	bltu	s1,a5,80004314 <dirlink+0x50>
    80004336:	79a2                	ld	s3,40(sp)
    80004338:	7a02                	ld	s4,32(sp)
    8000433a:	a81d                	j	80004370 <dirlink+0xac>
    iput(ip);
    8000433c:	811ff0ef          	jal	80003b4c <iput>
    dir_report(
    80004340:	00005797          	auipc	a5,0x5
    80004344:	55878793          	addi	a5,a5,1368 # 80009898 <etext+0x898>
    80004348:	577d                	li	a4,-1
    8000434a:	86da                	mv	a3,s6
    8000434c:	8656                	mv	a2,s5
    8000434e:	85ca                	mv	a1,s2
    80004350:	00005517          	auipc	a0,0x5
    80004354:	56050513          	addi	a0,a0,1376 # 800098b0 <etext+0x8b0>
    80004358:	ca9fe0ef          	jal	80003000 <dir_report>
    return -1;
    8000435c:	557d                	li	a0,-1
    8000435e:	a8a1                	j	800043b6 <dirlink+0xf2>
      panic("dirlink read");
    80004360:	00005517          	auipc	a0,0x5
    80004364:	56050513          	addi	a0,a0,1376 # 800098c0 <etext+0x8c0>
    80004368:	ceefc0ef          	jal	80000856 <panic>
    8000436c:	79a2                	ld	s3,40(sp)
    8000436e:	7a02                	ld	s4,32(sp)
  strncpy(de.name, name, DIRSIZ);
    80004370:	4639                	li	a2,14
    80004372:	85d6                	mv	a1,s5
    80004374:	fb240513          	addi	a0,s0,-78
    80004378:	ac1fc0ef          	jal	80000e38 <strncpy>
  de.inum = inum;
    8000437c:	fb641823          	sh	s6,-80(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004380:	4741                	li	a4,16
    80004382:	86a6                	mv	a3,s1
    80004384:	fb040613          	addi	a2,s0,-80
    80004388:	4581                	li	a1,0
    8000438a:	854a                	mv	a0,s2
    8000438c:	b3bff0ef          	jal	80003ec6 <writei>
    80004390:	47c1                	li	a5,16
    80004392:	02f51963          	bne	a0,a5,800043c4 <dirlink+0x100>
  dir_report(
    80004396:	00005797          	auipc	a5,0x5
    8000439a:	53a78793          	addi	a5,a5,1338 # 800098d0 <etext+0x8d0>
    8000439e:	8726                	mv	a4,s1
    800043a0:	86da                	mv	a3,s6
    800043a2:	8656                	mv	a2,s5
    800043a4:	85ca                	mv	a1,s2
    800043a6:	00005517          	auipc	a0,0x5
    800043aa:	54250513          	addi	a0,a0,1346 # 800098e8 <etext+0x8e8>
    800043ae:	c53fe0ef          	jal	80003000 <dir_report>
  return 0;
    800043b2:	4501                	li	a0,0
    800043b4:	74e2                	ld	s1,56(sp)
}
    800043b6:	60a6                	ld	ra,72(sp)
    800043b8:	6406                	ld	s0,64(sp)
    800043ba:	7942                	ld	s2,48(sp)
    800043bc:	6ae2                	ld	s5,24(sp)
    800043be:	6b42                	ld	s6,16(sp)
    800043c0:	6161                	addi	sp,sp,80
    800043c2:	8082                	ret
    return -1;
    800043c4:	557d                	li	a0,-1
    800043c6:	74e2                	ld	s1,56(sp)
    800043c8:	b7fd                	j	800043b6 <dirlink+0xf2>

00000000800043ca <namei>:

struct inode*
namei(char *path)
{
    800043ca:	1101                	addi	sp,sp,-32
    800043cc:	ec06                	sd	ra,24(sp)
    800043ce:	e822                	sd	s0,16(sp)
    800043d0:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    800043d2:	fe040613          	addi	a2,s0,-32
    800043d6:	4581                	li	a1,0
    800043d8:	d1dff0ef          	jal	800040f4 <namex>
}
    800043dc:	60e2                	ld	ra,24(sp)
    800043de:	6442                	ld	s0,16(sp)
    800043e0:	6105                	addi	sp,sp,32
    800043e2:	8082                	ret

00000000800043e4 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    800043e4:	1141                	addi	sp,sp,-16
    800043e6:	e406                	sd	ra,8(sp)
    800043e8:	e022                	sd	s0,0(sp)
    800043ea:	0800                	addi	s0,sp,16
    800043ec:	862e                	mv	a2,a1
  return namex(path, 1, name);
    800043ee:	4585                	li	a1,1
    800043f0:	d05ff0ef          	jal	800040f4 <namex>
}
    800043f4:	60a2                	ld	ra,8(sp)
    800043f6:	6402                	ld	s0,0(sp)
    800043f8:	0141                	addi	sp,sp,16
    800043fa:	8082                	ret

00000000800043fc <log_get_state>:
  int committing;
};

static struct log_state
log_get_state(void)
{
    800043fc:	1101                	addi	sp,sp,-32
    800043fe:	ec06                	sd	ra,24(sp)
    80004400:	e822                	sd	s0,16(sp)
    80004402:	1000                	addi	s0,sp,32
  struct log_state s;
  s.n = log.lh.n;
  s.out = log.outstanding;
    80004404:	0001e797          	auipc	a5,0x1e
    80004408:	d7478793          	addi	a5,a5,-652 # 80022178 <log>
  s.committing = log.committing;
  return s;
    8000440c:	01c7e703          	lwu	a4,28(a5)
    80004410:	1702                	slli	a4,a4,0x20
    80004412:	0287e503          	lwu	a0,40(a5)
}
    80004416:	8d59                	or	a0,a0,a4
    80004418:	0207e583          	lwu	a1,32(a5)
    8000441c:	60e2                	ld	ra,24(sp)
    8000441e:	6442                	ld	s0,16(sp)
    80004420:	6105                	addi	sp,sp,32
    80004422:	8082                	ret

0000000080004424 <log_report>:

//
// 🔥 report (نفس نمط bio.c)
//
void log_report(char *op, int bno, struct log_state old, char *desc)
{
    80004424:	db010113          	addi	sp,sp,-592
    80004428:	24113423          	sd	ra,584(sp)
    8000442c:	24813023          	sd	s0,576(sp)
    80004430:	22913c23          	sd	s1,568(sp)
    80004434:	23213823          	sd	s2,560(sp)
    80004438:	23313423          	sd	s3,552(sp)
    8000443c:	0c80                	addi	s0,sp,592
    8000443e:	84aa                	mv	s1,a0
    80004440:	892e                	mv	s2,a1
    80004442:	dac43823          	sd	a2,-592(s0)
    80004446:	dad43c23          	sd	a3,-584(s0)
    8000444a:	89ba                	mv	s3,a4
  struct fs_event e;
  memset(&e, 0, sizeof(e));
    8000444c:	20000613          	li	a2,512
    80004450:	4581                	li	a1,0
    80004452:	dd040513          	addi	a0,s0,-560
    80004456:	8d5fc0ef          	jal	80000d2a <memset>

  struct log_state now = log_get_state();
    8000445a:	fa3ff0ef          	jal	800043fc <log_get_state>
    8000445e:	dca42023          	sw	a0,-576(s0)
    80004462:	02055793          	srli	a5,a0,0x20
    80004466:	dcf42223          	sw	a5,-572(s0)
    8000446a:	dcb42423          	sw	a1,-568(s0)

  e.ticks = ticks;
    8000446e:	00006797          	auipc	a5,0x6
    80004472:	bda7a783          	lw	a5,-1062(a5) # 8000a048 <ticks>
    80004476:	dcf42c23          	sw	a5,-552(s0)
  e.pid = myproc() ? myproc()->pid : 0;
    8000447a:	ceefd0ef          	jal	80001968 <myproc>
    8000447e:	4781                	li	a5,0
    80004480:	c501                	beqz	a0,80004488 <log_report+0x64>
    80004482:	ce6fd0ef          	jal	80001968 <myproc>
    80004486:	591c                	lw	a5,48(a0)
    80004488:	dcf42e23          	sw	a5,-548(s0)
  e.type = LAYER_LOG;
    8000448c:	4789                	li	a5,2
    8000448e:	def42023          	sw	a5,-544(s0)
  e.blockno = bno;
    80004492:	e9242a23          	sw	s2,-364(s0)

  // before
  e.old_log_n = old.n;
    80004496:	db042783          	lw	a5,-592(s0)
    8000449a:	eef42223          	sw	a5,-284(s0)
  e.old_outstanding = old.out;
    8000449e:	db442783          	lw	a5,-588(s0)
    800044a2:	eef42423          	sw	a5,-280(s0)
  e.old_committing = old.committing;
    800044a6:	db842783          	lw	a5,-584(s0)
    800044aa:	eef42623          	sw	a5,-276(s0)

  // after
  e.log_n = now.n;
    800044ae:	dc042783          	lw	a5,-576(s0)
    800044b2:	eef42823          	sw	a5,-272(s0)
  e.outstanding = now.out;
    800044b6:	dc442783          	lw	a5,-572(s0)
    800044ba:	eef42a23          	sw	a5,-268(s0)
  e.committing = now.committing;
    800044be:	dc842783          	lw	a5,-568(s0)
    800044c2:	eef42c23          	sw	a5,-264(s0)

  safestrcpy(e.op_name, op, 16);
    800044c6:	4641                	li	a2,16
    800044c8:	85a6                	mv	a1,s1
    800044ca:	de440513          	addi	a0,s0,-540
    800044ce:	9b1fc0ef          	jal	80000e7e <safestrcpy>
  safestrcpy(e.details, desc, 128);
    800044d2:	08000613          	li	a2,128
    800044d6:	85ce                	mv	a1,s3
    800044d8:	df440513          	addi	a0,s0,-524
    800044dc:	9a3fc0ef          	jal	80000e7e <safestrcpy>

  fslog_push(&e);
    800044e0:	dd040513          	addi	a0,s0,-560
    800044e4:	2db020ef          	jal	80006fbe <fslog_push>
}
    800044e8:	24813083          	ld	ra,584(sp)
    800044ec:	24013403          	ld	s0,576(sp)
    800044f0:	23813483          	ld	s1,568(sp)
    800044f4:	23013903          	ld	s2,560(sp)
    800044f8:	22813983          	ld	s3,552(sp)
    800044fc:	25010113          	addi	sp,sp,592
    80004500:	8082                	ret

0000000080004502 <install_trans>:
}

static void
install_trans(int recovering)
{
  for (int tail = 0; tail < log.lh.n; tail++) {
    80004502:	0001e797          	auipc	a5,0x1e
    80004506:	c9e7a783          	lw	a5,-866(a5) # 800221a0 <log+0x28>
    8000450a:	12f05163          	blez	a5,8000462c <install_trans+0x12a>
{
    8000450e:	7119                	addi	sp,sp,-128
    80004510:	fc86                	sd	ra,120(sp)
    80004512:	f8a2                	sd	s0,112(sp)
    80004514:	f4a6                	sd	s1,104(sp)
    80004516:	f0ca                	sd	s2,96(sp)
    80004518:	ecce                	sd	s3,88(sp)
    8000451a:	e8d2                	sd	s4,80(sp)
    8000451c:	e4d6                	sd	s5,72(sp)
    8000451e:	e0da                	sd	s6,64(sp)
    80004520:	fc5e                	sd	s7,56(sp)
    80004522:	f862                	sd	s8,48(sp)
    80004524:	f466                	sd	s9,40(sp)
    80004526:	f06a                	sd	s10,32(sp)
    80004528:	ec6e                	sd	s11,24(sp)
    8000452a:	0100                	addi	s0,sp,128
    8000452c:	8b2a                	mv	s6,a0
    8000452e:	0001ea97          	auipc	s5,0x1e
    80004532:	c76a8a93          	addi	s5,s5,-906 # 800221a4 <log+0x2c>
  for (int tail = 0; tail < log.lh.n; tail++) {
    80004536:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1);
    80004538:	0001e997          	auipc	s3,0x1e
    8000453c:	c4098993          	addi	s3,s3,-960 # 80022178 <log>
    struct log_state old = log_get_state();

    if (recovering)
      log_report("RECOVER_BLK", log.lh.block[tail], old, "Recover block");
    else
      log_report("INSTALL_BLK", log.lh.block[tail], old, "Install block");
    80004540:	00005d97          	auipc	s11,0x5
    80004544:	3d8d8d93          	addi	s11,s11,984 # 80009918 <etext+0x918>
    80004548:	00005d17          	auipc	s10,0x5
    8000454c:	3e0d0d13          	addi	s10,s10,992 # 80009928 <etext+0x928>

    memmove(dbuf->data, lbuf->data, BSIZE);
    80004550:	40000b93          	li	s7,1024
      log_report("RECOVER_BLK", log.lh.block[tail], old, "Recover block");
    80004554:	00005c97          	auipc	s9,0x5
    80004558:	3a4c8c93          	addi	s9,s9,932 # 800098f8 <etext+0x8f8>
    8000455c:	00005c17          	auipc	s8,0x5
    80004560:	3acc0c13          	addi	s8,s8,940 # 80009908 <etext+0x908>
    80004564:	a0a1                	j	800045ac <install_trans+0xaa>
      log_report("INSTALL_BLK", log.lh.block[tail], old, "Install block");
    80004566:	876e                	mv	a4,s11
    80004568:	f8043603          	ld	a2,-128(s0)
    8000456c:	f8843683          	ld	a3,-120(s0)
    80004570:	000aa583          	lw	a1,0(s5)
    80004574:	856a                	mv	a0,s10
    80004576:	eafff0ef          	jal	80004424 <log_report>
    memmove(dbuf->data, lbuf->data, BSIZE);
    8000457a:	865e                	mv	a2,s7
    8000457c:	05890593          	addi	a1,s2,88
    80004580:	05848513          	addi	a0,s1,88
    80004584:	807fc0ef          	jal	80000d8a <memmove>
    bwrite(dbuf);
    80004588:	8526                	mv	a0,s1
    8000458a:	8a5fe0ef          	jal	80002e2e <bwrite>

    if (!recovering)
      bunpin(dbuf);
    8000458e:	8526                	mv	a0,s1
    80004590:	a3dfe0ef          	jal	80002fcc <bunpin>

    brelse(lbuf);
    80004594:	854a                	mv	a0,s2
    80004596:	90dfe0ef          	jal	80002ea2 <brelse>
    brelse(dbuf);
    8000459a:	8526                	mv	a0,s1
    8000459c:	907fe0ef          	jal	80002ea2 <brelse>
  for (int tail = 0; tail < log.lh.n; tail++) {
    800045a0:	2a05                	addiw	s4,s4,1
    800045a2:	0a91                	addi	s5,s5,4
    800045a4:	0289a783          	lw	a5,40(s3)
    800045a8:	06fa5363          	bge	s4,a5,8000460e <install_trans+0x10c>
    struct buf *lbuf = bread(log.dev, log.start+tail+1);
    800045ac:	0189a583          	lw	a1,24(s3)
    800045b0:	014585bb          	addw	a1,a1,s4
    800045b4:	2585                	addiw	a1,a1,1
    800045b6:	0249a503          	lw	a0,36(s3)
    800045ba:	e3cfe0ef          	jal	80002bf6 <bread>
    800045be:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]);
    800045c0:	000aa583          	lw	a1,0(s5)
    800045c4:	0249a503          	lw	a0,36(s3)
    800045c8:	e2efe0ef          	jal	80002bf6 <bread>
    800045cc:	84aa                	mv	s1,a0
    struct log_state old = log_get_state();
    800045ce:	e2fff0ef          	jal	800043fc <log_get_state>
    800045d2:	f8a42023          	sw	a0,-128(s0)
    800045d6:	9101                	srli	a0,a0,0x20
    800045d8:	f8a42223          	sw	a0,-124(s0)
    800045dc:	f8b42423          	sw	a1,-120(s0)
    if (recovering)
    800045e0:	f80b03e3          	beqz	s6,80004566 <install_trans+0x64>
      log_report("RECOVER_BLK", log.lh.block[tail], old, "Recover block");
    800045e4:	8766                	mv	a4,s9
    800045e6:	f8043603          	ld	a2,-128(s0)
    800045ea:	f8843683          	ld	a3,-120(s0)
    800045ee:	000aa583          	lw	a1,0(s5)
    800045f2:	8562                	mv	a0,s8
    800045f4:	e31ff0ef          	jal	80004424 <log_report>
    memmove(dbuf->data, lbuf->data, BSIZE);
    800045f8:	865e                	mv	a2,s7
    800045fa:	05890593          	addi	a1,s2,88
    800045fe:	05848513          	addi	a0,s1,88
    80004602:	f88fc0ef          	jal	80000d8a <memmove>
    bwrite(dbuf);
    80004606:	8526                	mv	a0,s1
    80004608:	827fe0ef          	jal	80002e2e <bwrite>
    if (!recovering)
    8000460c:	b761                	j	80004594 <install_trans+0x92>
  }
}
    8000460e:	70e6                	ld	ra,120(sp)
    80004610:	7446                	ld	s0,112(sp)
    80004612:	74a6                	ld	s1,104(sp)
    80004614:	7906                	ld	s2,96(sp)
    80004616:	69e6                	ld	s3,88(sp)
    80004618:	6a46                	ld	s4,80(sp)
    8000461a:	6aa6                	ld	s5,72(sp)
    8000461c:	6b06                	ld	s6,64(sp)
    8000461e:	7be2                	ld	s7,56(sp)
    80004620:	7c42                	ld	s8,48(sp)
    80004622:	7ca2                	ld	s9,40(sp)
    80004624:	7d02                	ld	s10,32(sp)
    80004626:	6de2                	ld	s11,24(sp)
    80004628:	6109                	addi	sp,sp,128
    8000462a:	8082                	ret
    8000462c:	8082                	ret

000000008000462e <write_head>:
{
    8000462e:	7179                	addi	sp,sp,-48
    80004630:	f406                	sd	ra,40(sp)
    80004632:	f022                	sd	s0,32(sp)
    80004634:	ec26                	sd	s1,24(sp)
    80004636:	e84a                	sd	s2,16(sp)
    80004638:	1800                	addi	s0,sp,48
  struct buf *buf = bread(log.dev, log.start);
    8000463a:	0001e917          	auipc	s2,0x1e
    8000463e:	b3e90913          	addi	s2,s2,-1218 # 80022178 <log>
    80004642:	01892583          	lw	a1,24(s2)
    80004646:	02492503          	lw	a0,36(s2)
    8000464a:	dacfe0ef          	jal	80002bf6 <bread>
    8000464e:	84aa                	mv	s1,a0
  struct log_state old = log_get_state();
    80004650:	dadff0ef          	jal	800043fc <log_get_state>
    80004654:	fca42823          	sw	a0,-48(s0)
    80004658:	9101                	srli	a0,a0,0x20
    8000465a:	fca42a23          	sw	a0,-44(s0)
    8000465e:	fcb42c23          	sw	a1,-40(s0)
  hb->n = log.lh.n;
    80004662:	02892603          	lw	a2,40(s2)
    80004666:	ccb0                	sw	a2,88(s1)
  for (int i = 0; i < log.lh.n; i++)
    80004668:	00c05f63          	blez	a2,80004686 <write_head+0x58>
    8000466c:	0001e717          	auipc	a4,0x1e
    80004670:	b3870713          	addi	a4,a4,-1224 # 800221a4 <log+0x2c>
    80004674:	87a6                	mv	a5,s1
    80004676:	060a                	slli	a2,a2,0x2
    80004678:	9626                	add	a2,a2,s1
    hb->block[i] = log.lh.block[i];
    8000467a:	4314                	lw	a3,0(a4)
    8000467c:	cff4                	sw	a3,92(a5)
  for (int i = 0; i < log.lh.n; i++)
    8000467e:	0711                	addi	a4,a4,4
    80004680:	0791                	addi	a5,a5,4
    80004682:	fec79ce3          	bne	a5,a2,8000467a <write_head+0x4c>
  bwrite(buf);
    80004686:	8526                	mv	a0,s1
    80004688:	fa6fe0ef          	jal	80002e2e <bwrite>
  log_report("WRITE_HEAD", 0, old, "Write log header to disk");
    8000468c:	00005717          	auipc	a4,0x5
    80004690:	2ac70713          	addi	a4,a4,684 # 80009938 <etext+0x938>
    80004694:	fd043603          	ld	a2,-48(s0)
    80004698:	fd843683          	ld	a3,-40(s0)
    8000469c:	4581                	li	a1,0
    8000469e:	00005517          	auipc	a0,0x5
    800046a2:	2ba50513          	addi	a0,a0,698 # 80009958 <etext+0x958>
    800046a6:	d7fff0ef          	jal	80004424 <log_report>
  brelse(buf);
    800046aa:	8526                	mv	a0,s1
    800046ac:	ff6fe0ef          	jal	80002ea2 <brelse>
}
    800046b0:	70a2                	ld	ra,40(sp)
    800046b2:	7402                	ld	s0,32(sp)
    800046b4:	64e2                	ld	s1,24(sp)
    800046b6:	6942                	ld	s2,16(sp)
    800046b8:	6145                	addi	sp,sp,48
    800046ba:	8082                	ret

00000000800046bc <initlog>:
{
    800046bc:	715d                	addi	sp,sp,-80
    800046be:	e486                	sd	ra,72(sp)
    800046c0:	e0a2                	sd	s0,64(sp)
    800046c2:	fc26                	sd	s1,56(sp)
    800046c4:	f84a                	sd	s2,48(sp)
    800046c6:	f44e                	sd	s3,40(sp)
    800046c8:	0880                	addi	s0,sp,80
    800046ca:	84aa                	mv	s1,a0
    800046cc:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    800046ce:	0001e917          	auipc	s2,0x1e
    800046d2:	aaa90913          	addi	s2,s2,-1366 # 80022178 <log>
    800046d6:	00005597          	auipc	a1,0x5
    800046da:	29258593          	addi	a1,a1,658 # 80009968 <etext+0x968>
    800046de:	854a                	mv	a0,s2
    800046e0:	cf0fc0ef          	jal	80000bd0 <initlock>
  log.start = sb->logstart;
    800046e4:	0149a783          	lw	a5,20(s3)
    800046e8:	00f92c23          	sw	a5,24(s2)
  log.dev = dev;
    800046ec:	02992223          	sw	s1,36(s2)
  struct log_state old = log_get_state();
    800046f0:	d0dff0ef          	jal	800043fc <log_get_state>
    800046f4:	fca42023          	sw	a0,-64(s0)
    800046f8:	9101                	srli	a0,a0,0x20
    800046fa:	fca42223          	sw	a0,-60(s0)
    800046fe:	fcb42423          	sw	a1,-56(s0)
  log_report("INIT_LOG", 0, old, "Initialize log system");
    80004702:	00005717          	auipc	a4,0x5
    80004706:	26e70713          	addi	a4,a4,622 # 80009970 <etext+0x970>
    8000470a:	fc043603          	ld	a2,-64(s0)
    8000470e:	fc843683          	ld	a3,-56(s0)
    80004712:	4581                	li	a1,0
    80004714:	00005517          	auipc	a0,0x5
    80004718:	27450513          	addi	a0,a0,628 # 80009988 <etext+0x988>
    8000471c:	d09ff0ef          	jal	80004424 <log_report>
  struct buf *buf = bread(log.dev, log.start);
    80004720:	01892583          	lw	a1,24(s2)
    80004724:	02492503          	lw	a0,36(s2)
    80004728:	ccefe0ef          	jal	80002bf6 <bread>
    8000472c:	84aa                	mv	s1,a0
  struct log_state old = log_get_state();
    8000472e:	ccfff0ef          	jal	800043fc <log_get_state>
    80004732:	faa42823          	sw	a0,-80(s0)
    80004736:	02055793          	srli	a5,a0,0x20
    8000473a:	faf42a23          	sw	a5,-76(s0)
    8000473e:	fab42c23          	sw	a1,-72(s0)
  log.lh.n = lh->n;
    80004742:	4cb0                	lw	a2,88(s1)
    80004744:	02c92423          	sw	a2,40(s2)
  for (int i = 0; i < log.lh.n; i++)
    80004748:	00c05f63          	blez	a2,80004766 <initlog+0xaa>
    8000474c:	87a6                	mv	a5,s1
    8000474e:	0001e717          	auipc	a4,0x1e
    80004752:	a5670713          	addi	a4,a4,-1450 # 800221a4 <log+0x2c>
    80004756:	060a                	slli	a2,a2,0x2
    80004758:	9626                	add	a2,a2,s1
    log.lh.block[i] = lh->block[i];
    8000475a:	4ff4                	lw	a3,92(a5)
    8000475c:	c314                	sw	a3,0(a4)
  for (int i = 0; i < log.lh.n; i++)
    8000475e:	0791                	addi	a5,a5,4
    80004760:	0711                	addi	a4,a4,4
    80004762:	fec79ce3          	bne	a5,a2,8000475a <initlog+0x9e>
  log_report("READ_HEAD", 0, old, "Read log header from disk");
    80004766:	00005717          	auipc	a4,0x5
    8000476a:	23270713          	addi	a4,a4,562 # 80009998 <etext+0x998>
    8000476e:	fb043603          	ld	a2,-80(s0)
    80004772:	fb843683          	ld	a3,-72(s0)
    80004776:	4581                	li	a1,0
    80004778:	00005517          	auipc	a0,0x5
    8000477c:	24050513          	addi	a0,a0,576 # 800099b8 <etext+0x9b8>
    80004780:	ca5ff0ef          	jal	80004424 <log_report>
  brelse(buf);
    80004784:	8526                	mv	a0,s1
    80004786:	f1cfe0ef          	jal	80002ea2 <brelse>
static void
recover_from_log(void)
{
  read_head();

  if (log.lh.n > 0) {
    8000478a:	0001e797          	auipc	a5,0x1e
    8000478e:	a167a783          	lw	a5,-1514(a5) # 800221a0 <log+0x28>
    80004792:	00f04963          	bgtz	a5,800047a4 <initlog+0xe8>
}
    80004796:	60a6                	ld	ra,72(sp)
    80004798:	6406                	ld	s0,64(sp)
    8000479a:	74e2                	ld	s1,56(sp)
    8000479c:	7942                	ld	s2,48(sp)
    8000479e:	79a2                	ld	s3,40(sp)
    800047a0:	6161                	addi	sp,sp,80
    800047a2:	8082                	ret
    struct log_state old = log_get_state();
    800047a4:	c59ff0ef          	jal	800043fc <log_get_state>
    800047a8:	faa42823          	sw	a0,-80(s0)
    800047ac:	9101                	srli	a0,a0,0x20
    800047ae:	faa42a23          	sw	a0,-76(s0)
    800047b2:	fab42c23          	sw	a1,-72(s0)

    log_report("RECOVER_START", 0, old, "Start recovery");
    800047b6:	00005717          	auipc	a4,0x5
    800047ba:	21270713          	addi	a4,a4,530 # 800099c8 <etext+0x9c8>
    800047be:	fb043603          	ld	a2,-80(s0)
    800047c2:	fb843683          	ld	a3,-72(s0)
    800047c6:	4581                	li	a1,0
    800047c8:	00005517          	auipc	a0,0x5
    800047cc:	21050513          	addi	a0,a0,528 # 800099d8 <etext+0x9d8>
    800047d0:	c55ff0ef          	jal	80004424 <log_report>

    install_trans(1);
    800047d4:	4505                	li	a0,1
    800047d6:	d2dff0ef          	jal	80004502 <install_trans>

    old = log_get_state();
    800047da:	c23ff0ef          	jal	800043fc <log_get_state>
    800047de:	faa42823          	sw	a0,-80(s0)
    800047e2:	9101                	srli	a0,a0,0x20
    800047e4:	faa42a23          	sw	a0,-76(s0)
    800047e8:	fab42c23          	sw	a1,-72(s0)
    log.lh.n = 0;
    800047ec:	0001e797          	auipc	a5,0x1e
    800047f0:	9a07aa23          	sw	zero,-1612(a5) # 800221a0 <log+0x28>
    write_head();
    800047f4:	e3bff0ef          	jal	8000462e <write_head>

    log_report("RECOVER_DONE", 0, old, "Recovery done");
    800047f8:	00005717          	auipc	a4,0x5
    800047fc:	1f070713          	addi	a4,a4,496 # 800099e8 <etext+0x9e8>
    80004800:	fb043603          	ld	a2,-80(s0)
    80004804:	fb843683          	ld	a3,-72(s0)
    80004808:	4581                	li	a1,0
    8000480a:	00005517          	auipc	a0,0x5
    8000480e:	1ee50513          	addi	a0,a0,494 # 800099f8 <etext+0x9f8>
    80004812:	c13ff0ef          	jal	80004424 <log_report>
}
    80004816:	b741                	j	80004796 <initlog+0xda>

0000000080004818 <begin_op>:
  }
}

void
begin_op(void)
{
    80004818:	711d                	addi	sp,sp,-96
    8000481a:	ec86                	sd	ra,88(sp)
    8000481c:	e8a2                	sd	s0,80(sp)
    8000481e:	e4a6                	sd	s1,72(sp)
    80004820:	e0ca                	sd	s2,64(sp)
    80004822:	fc4e                	sd	s3,56(sp)
    80004824:	f852                	sd	s4,48(sp)
    80004826:	f456                	sd	s5,40(sp)
    80004828:	f05a                	sd	s6,32(sp)
    8000482a:	ec5e                	sd	s7,24(sp)
    8000482c:	1080                	addi	s0,sp,96
  acquire(&log.lock);
    8000482e:	0001e517          	auipc	a0,0x1e
    80004832:	94a50513          	addi	a0,a0,-1718 # 80022178 <log>
    80004836:	c24fc0ef          	jal	80000c5a <acquire>

  while (1) {
    if (log.committing) {
    8000483a:	0001e497          	auipc	s1,0x1e
    8000483e:	93e48493          	addi	s1,s1,-1730 # 80022178 <log>
      struct log_state old = log_get_state();
      log_report("WAIT_COMMIT", 0, old, "Waiting for commit");
      sleep(&log, &log.lock);

    } else if (log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGBLOCKS) {
    80004842:	4979                	li	s2,30
      struct log_state old = log_get_state();
      log_report("WAIT_SPACE", 0, old, "Waiting for log space");
    80004844:	00005a17          	auipc	s4,0x5
    80004848:	1eca0a13          	addi	s4,s4,492 # 80009a30 <etext+0xa30>
    8000484c:	00005997          	auipc	s3,0x5
    80004850:	1fc98993          	addi	s3,s3,508 # 80009a48 <etext+0xa48>
      log_report("WAIT_COMMIT", 0, old, "Waiting for commit");
    80004854:	00005b17          	auipc	s6,0x5
    80004858:	1b4b0b13          	addi	s6,s6,436 # 80009a08 <etext+0xa08>
    8000485c:	00005a97          	auipc	s5,0x5
    80004860:	1c4a8a93          	addi	s5,s5,452 # 80009a20 <etext+0xa20>
    80004864:	a03d                	j	80004892 <begin_op+0x7a>
      struct log_state old = log_get_state();
    80004866:	b97ff0ef          	jal	800043fc <log_get_state>
    8000486a:	faa42023          	sw	a0,-96(s0)
    8000486e:	9101                	srli	a0,a0,0x20
    80004870:	faa42223          	sw	a0,-92(s0)
    80004874:	fab42423          	sw	a1,-88(s0)
      log_report("WAIT_COMMIT", 0, old, "Waiting for commit");
    80004878:	875a                	mv	a4,s6
    8000487a:	fa043603          	ld	a2,-96(s0)
    8000487e:	fa843683          	ld	a3,-88(s0)
    80004882:	4581                	li	a1,0
    80004884:	8556                	mv	a0,s5
    80004886:	b9fff0ef          	jal	80004424 <log_report>
      sleep(&log, &log.lock);
    8000488a:	85a6                	mv	a1,s1
    8000488c:	8526                	mv	a0,s1
    8000488e:	ef0fd0ef          	jal	80001f7e <sleep>
    if (log.committing) {
    80004892:	509c                	lw	a5,32(s1)
    80004894:	fbe9                	bnez	a5,80004866 <begin_op+0x4e>
    } else if (log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGBLOCKS) {
    80004896:	01c4ab83          	lw	s7,28(s1)
    8000489a:	2b85                	addiw	s7,s7,1
    8000489c:	002b979b          	slliw	a5,s7,0x2
    800048a0:	017787bb          	addw	a5,a5,s7
    800048a4:	0017979b          	slliw	a5,a5,0x1
    800048a8:	5498                	lw	a4,40(s1)
    800048aa:	9fb9                	addw	a5,a5,a4
    800048ac:	02f95963          	bge	s2,a5,800048de <begin_op+0xc6>
      struct log_state old = log_get_state();
    800048b0:	b4dff0ef          	jal	800043fc <log_get_state>
    800048b4:	faa42023          	sw	a0,-96(s0)
    800048b8:	9101                	srli	a0,a0,0x20
    800048ba:	faa42223          	sw	a0,-92(s0)
    800048be:	fab42423          	sw	a1,-88(s0)
      log_report("WAIT_SPACE", 0, old, "Waiting for log space");
    800048c2:	8752                	mv	a4,s4
    800048c4:	fa043603          	ld	a2,-96(s0)
    800048c8:	fa843683          	ld	a3,-88(s0)
    800048cc:	4581                	li	a1,0
    800048ce:	854e                	mv	a0,s3
    800048d0:	b55ff0ef          	jal	80004424 <log_report>
      sleep(&log, &log.lock);
    800048d4:	85a6                	mv	a1,s1
    800048d6:	8526                	mv	a0,s1
    800048d8:	ea6fd0ef          	jal	80001f7e <sleep>
    800048dc:	bf5d                	j	80004892 <begin_op+0x7a>

    } else {
      struct log_state old = log_get_state();
    800048de:	b1fff0ef          	jal	800043fc <log_get_state>
    800048e2:	faa42023          	sw	a0,-96(s0)
    800048e6:	9101                	srli	a0,a0,0x20
    800048e8:	faa42223          	sw	a0,-92(s0)
    800048ec:	fab42423          	sw	a1,-88(s0)

      log.outstanding++;
    800048f0:	0001e797          	auipc	a5,0x1e
    800048f4:	8b77a223          	sw	s7,-1884(a5) # 80022194 <log+0x1c>

      log_report("BEGIN_OP", 0, old, "Begin operation");
    800048f8:	00005717          	auipc	a4,0x5
    800048fc:	16070713          	addi	a4,a4,352 # 80009a58 <etext+0xa58>
    80004900:	fa043603          	ld	a2,-96(s0)
    80004904:	fa843683          	ld	a3,-88(s0)
    80004908:	4581                	li	a1,0
    8000490a:	00005517          	auipc	a0,0x5
    8000490e:	15e50513          	addi	a0,a0,350 # 80009a68 <etext+0xa68>
    80004912:	b13ff0ef          	jal	80004424 <log_report>

      release(&log.lock);
    80004916:	0001e517          	auipc	a0,0x1e
    8000491a:	86250513          	addi	a0,a0,-1950 # 80022178 <log>
    8000491e:	bd0fc0ef          	jal	80000cee <release>
      break;
    }
  }
}
    80004922:	60e6                	ld	ra,88(sp)
    80004924:	6446                	ld	s0,80(sp)
    80004926:	64a6                	ld	s1,72(sp)
    80004928:	6906                	ld	s2,64(sp)
    8000492a:	79e2                	ld	s3,56(sp)
    8000492c:	7a42                	ld	s4,48(sp)
    8000492e:	7aa2                	ld	s5,40(sp)
    80004930:	7b02                	ld	s6,32(sp)
    80004932:	6be2                	ld	s7,24(sp)
    80004934:	6125                	addi	sp,sp,96
    80004936:	8082                	ret

0000000080004938 <end_op>:

void
end_op(void)
{
    80004938:	7159                	addi	sp,sp,-112
    8000493a:	f486                	sd	ra,104(sp)
    8000493c:	f0a2                	sd	s0,96(sp)
    8000493e:	eca6                	sd	s1,88(sp)
    80004940:	1880                	addi	s0,sp,112
  int do_commit = 0;

  acquire(&log.lock);
    80004942:	0001e497          	auipc	s1,0x1e
    80004946:	83648493          	addi	s1,s1,-1994 # 80022178 <log>
    8000494a:	8526                	mv	a0,s1
    8000494c:	b0efc0ef          	jal	80000c5a <acquire>

  struct log_state old = log_get_state();
    80004950:	aadff0ef          	jal	800043fc <log_get_state>
    80004954:	faa42823          	sw	a0,-80(s0)
    80004958:	9101                	srli	a0,a0,0x20
    8000495a:	faa42a23          	sw	a0,-76(s0)
    8000495e:	fab42c23          	sw	a1,-72(s0)

  log.outstanding--;
    80004962:	4cdc                	lw	a5,28(s1)
    80004964:	37fd                	addiw	a5,a5,-1
    80004966:	ccdc                	sw	a5,28(s1)

  if (log.outstanding == 0) {
    80004968:	ebd1                	bnez	a5,800049fc <end_op+0xc4>
    8000496a:	e8ca                	sd	s2,80(sp)
    8000496c:	893e                	mv	s2,a5
    do_commit = 1;
    log.committing = 1;
    8000496e:	4785                	li	a5,1
    80004970:	d09c                	sw	a5,32(s1)

    log_report("PRE_COMMIT", 0, old, "Start committing");
    80004972:	00005717          	auipc	a4,0x5
    80004976:	10670713          	addi	a4,a4,262 # 80009a78 <etext+0xa78>
    8000497a:	fb043603          	ld	a2,-80(s0)
    8000497e:	fb843683          	ld	a3,-72(s0)
    80004982:	4581                	li	a1,0
    80004984:	00005517          	auipc	a0,0x5
    80004988:	10c50513          	addi	a0,a0,268 # 80009a90 <etext+0xa90>
    8000498c:	a99ff0ef          	jal	80004424 <log_report>
  } else {
    log_report("END_OP", 0, old, "End operation");
    wakeup(&log);
  }

  release(&log.lock);
    80004990:	8526                	mv	a0,s1
    80004992:	b5cfc0ef          	jal	80000cee <release>
}

static void
commit(void)
{
  if (log.lh.n > 0) {
    80004996:	549c                	lw	a5,40(s1)
    80004998:	0af04263          	bgtz	a5,80004a3c <end_op+0x104>
    acquire(&log.lock);
    8000499c:	0001d517          	auipc	a0,0x1d
    800049a0:	7dc50513          	addi	a0,a0,2012 # 80022178 <log>
    800049a4:	ab6fc0ef          	jal	80000c5a <acquire>
    old = log_get_state();
    800049a8:	a55ff0ef          	jal	800043fc <log_get_state>
    800049ac:	faa42823          	sw	a0,-80(s0)
    800049b0:	9101                	srli	a0,a0,0x20
    800049b2:	faa42a23          	sw	a0,-76(s0)
    800049b6:	fab42c23          	sw	a1,-72(s0)
    log.committing = 0;
    800049ba:	0001d797          	auipc	a5,0x1d
    800049be:	7c07af23          	sw	zero,2014(a5) # 80022198 <log+0x20>
    log_report("FINAL_RELEASE", 0, old, "Commit finished");
    800049c2:	00005717          	auipc	a4,0x5
    800049c6:	16e70713          	addi	a4,a4,366 # 80009b30 <etext+0xb30>
    800049ca:	fb043603          	ld	a2,-80(s0)
    800049ce:	fb843683          	ld	a3,-72(s0)
    800049d2:	4581                	li	a1,0
    800049d4:	00005517          	auipc	a0,0x5
    800049d8:	16c50513          	addi	a0,a0,364 # 80009b40 <etext+0xb40>
    800049dc:	a49ff0ef          	jal	80004424 <log_report>
    wakeup(&log);
    800049e0:	0001d517          	auipc	a0,0x1d
    800049e4:	79850513          	addi	a0,a0,1944 # 80022178 <log>
    800049e8:	de2fd0ef          	jal	80001fca <wakeup>
    release(&log.lock);
    800049ec:	0001d517          	auipc	a0,0x1d
    800049f0:	78c50513          	addi	a0,a0,1932 # 80022178 <log>
    800049f4:	afafc0ef          	jal	80000cee <release>
    800049f8:	6946                	ld	s2,80(sp)
}
    800049fa:	a825                	j	80004a32 <end_op+0xfa>
    log_report("END_OP", 0, old, "End operation");
    800049fc:	00005717          	auipc	a4,0x5
    80004a00:	0a470713          	addi	a4,a4,164 # 80009aa0 <etext+0xaa0>
    80004a04:	fb043603          	ld	a2,-80(s0)
    80004a08:	fb843683          	ld	a3,-72(s0)
    80004a0c:	4581                	li	a1,0
    80004a0e:	00005517          	auipc	a0,0x5
    80004a12:	0a250513          	addi	a0,a0,162 # 80009ab0 <etext+0xab0>
    80004a16:	a0fff0ef          	jal	80004424 <log_report>
    wakeup(&log);
    80004a1a:	0001d517          	auipc	a0,0x1d
    80004a1e:	75e50513          	addi	a0,a0,1886 # 80022178 <log>
    80004a22:	da8fd0ef          	jal	80001fca <wakeup>
  release(&log.lock);
    80004a26:	0001d517          	auipc	a0,0x1d
    80004a2a:	75250513          	addi	a0,a0,1874 # 80022178 <log>
    80004a2e:	ac0fc0ef          	jal	80000cee <release>
}
    80004a32:	70a6                	ld	ra,104(sp)
    80004a34:	7406                	ld	s0,96(sp)
    80004a36:	64e6                	ld	s1,88(sp)
    80004a38:	6165                	addi	sp,sp,112
    80004a3a:	8082                	ret
    struct log_state old = log_get_state();
    80004a3c:	9c1ff0ef          	jal	800043fc <log_get_state>
    80004a40:	f8a42823          	sw	a0,-112(s0)
    80004a44:	9101                	srli	a0,a0,0x20
    80004a46:	f8a42a23          	sw	a0,-108(s0)
    80004a4a:	f8b42c23          	sw	a1,-104(s0)

    log_report("COMMIT_START", 0, old, "Commit start");
    80004a4e:	00005717          	auipc	a4,0x5
    80004a52:	06a70713          	addi	a4,a4,106 # 80009ab8 <etext+0xab8>
    80004a56:	f9043603          	ld	a2,-112(s0)
    80004a5a:	f9843683          	ld	a3,-104(s0)
    80004a5e:	4581                	li	a1,0
    80004a60:	00005517          	auipc	a0,0x5
    80004a64:	06850513          	addi	a0,a0,104 # 80009ac8 <etext+0xac8>
    80004a68:	9bdff0ef          	jal	80004424 <log_report>
  for (int tail = 0; tail < log.lh.n; tail++) {
    80004a6c:	0001d797          	auipc	a5,0x1d
    80004a70:	7347a783          	lw	a5,1844(a5) # 800221a0 <log+0x28>
    80004a74:	0af05263          	blez	a5,80004b18 <end_op+0x1e0>
    80004a78:	e4ce                	sd	s3,72(sp)
    80004a7a:	e0d2                	sd	s4,64(sp)
    80004a7c:	fc56                	sd	s5,56(sp)
    80004a7e:	0001da97          	auipc	s5,0x1d
    80004a82:	726a8a93          	addi	s5,s5,1830 # 800221a4 <log+0x2c>
    struct buf *to = bread(log.dev, log.start+tail+1);
    80004a86:	0001da17          	auipc	s4,0x1d
    80004a8a:	6f2a0a13          	addi	s4,s4,1778 # 80022178 <log>
    80004a8e:	018a2583          	lw	a1,24(s4)
    80004a92:	012585bb          	addw	a1,a1,s2
    80004a96:	2585                	addiw	a1,a1,1
    80004a98:	024a2503          	lw	a0,36(s4)
    80004a9c:	95afe0ef          	jal	80002bf6 <bread>
    80004aa0:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]);
    80004aa2:	000aa583          	lw	a1,0(s5)
    80004aa6:	024a2503          	lw	a0,36(s4)
    80004aaa:	94cfe0ef          	jal	80002bf6 <bread>
    80004aae:	89aa                	mv	s3,a0
    struct log_state old = log_get_state();
    80004ab0:	94dff0ef          	jal	800043fc <log_get_state>
    80004ab4:	faa42023          	sw	a0,-96(s0)
    80004ab8:	02055793          	srli	a5,a0,0x20
    80004abc:	faf42223          	sw	a5,-92(s0)
    80004ac0:	fab42423          	sw	a1,-88(s0)
    log_report("LOG_SYNC", log.lh.block[tail], old, "Write to log");
    80004ac4:	00005717          	auipc	a4,0x5
    80004ac8:	01470713          	addi	a4,a4,20 # 80009ad8 <etext+0xad8>
    80004acc:	fa043603          	ld	a2,-96(s0)
    80004ad0:	fa843683          	ld	a3,-88(s0)
    80004ad4:	000aa583          	lw	a1,0(s5)
    80004ad8:	00005517          	auipc	a0,0x5
    80004adc:	01050513          	addi	a0,a0,16 # 80009ae8 <etext+0xae8>
    80004ae0:	945ff0ef          	jal	80004424 <log_report>
    memmove(to->data, from->data, BSIZE);
    80004ae4:	40000613          	li	a2,1024
    80004ae8:	05898593          	addi	a1,s3,88
    80004aec:	05848513          	addi	a0,s1,88
    80004af0:	a9afc0ef          	jal	80000d8a <memmove>
    bwrite(to);
    80004af4:	8526                	mv	a0,s1
    80004af6:	b38fe0ef          	jal	80002e2e <bwrite>
    brelse(from);
    80004afa:	854e                	mv	a0,s3
    80004afc:	ba6fe0ef          	jal	80002ea2 <brelse>
    brelse(to);
    80004b00:	8526                	mv	a0,s1
    80004b02:	ba0fe0ef          	jal	80002ea2 <brelse>
  for (int tail = 0; tail < log.lh.n; tail++) {
    80004b06:	2905                	addiw	s2,s2,1
    80004b08:	0a91                	addi	s5,s5,4
    80004b0a:	028a2783          	lw	a5,40(s4)
    80004b0e:	f8f940e3          	blt	s2,a5,80004a8e <end_op+0x156>
    80004b12:	69a6                	ld	s3,72(sp)
    80004b14:	6a06                	ld	s4,64(sp)
    80004b16:	7ae2                	ld	s5,56(sp)

    write_log();
    write_head();
    80004b18:	b17ff0ef          	jal	8000462e <write_head>

    old = log_get_state();
    80004b1c:	8e1ff0ef          	jal	800043fc <log_get_state>
    80004b20:	f8a42823          	sw	a0,-112(s0)
    80004b24:	9101                	srli	a0,a0,0x20
    80004b26:	f8a42a23          	sw	a0,-108(s0)
    80004b2a:	f8b42c23          	sw	a1,-104(s0)
    log_report("WRITE_HEAD", 0, old, "Header committed");
    80004b2e:	00005717          	auipc	a4,0x5
    80004b32:	fca70713          	addi	a4,a4,-54 # 80009af8 <etext+0xaf8>
    80004b36:	f9043603          	ld	a2,-112(s0)
    80004b3a:	f9843683          	ld	a3,-104(s0)
    80004b3e:	4581                	li	a1,0
    80004b40:	00005517          	auipc	a0,0x5
    80004b44:	e1850513          	addi	a0,a0,-488 # 80009958 <etext+0x958>
    80004b48:	8ddff0ef          	jal	80004424 <log_report>

    install_trans(0);
    80004b4c:	4501                	li	a0,0
    80004b4e:	9b5ff0ef          	jal	80004502 <install_trans>

    old = log_get_state();
    80004b52:	8abff0ef          	jal	800043fc <log_get_state>
    80004b56:	f8a42823          	sw	a0,-112(s0)
    80004b5a:	9101                	srli	a0,a0,0x20
    80004b5c:	f8a42a23          	sw	a0,-108(s0)
    80004b60:	f8b42c23          	sw	a1,-104(s0)
    log.lh.n = 0;
    80004b64:	0001d797          	auipc	a5,0x1d
    80004b68:	6207ae23          	sw	zero,1596(a5) # 800221a0 <log+0x28>
    write_head();
    80004b6c:	ac3ff0ef          	jal	8000462e <write_head>

    log_report("COMMIT_DONE", 0, old, "Commit done");
    80004b70:	00005717          	auipc	a4,0x5
    80004b74:	fa070713          	addi	a4,a4,-96 # 80009b10 <etext+0xb10>
    80004b78:	f9043603          	ld	a2,-112(s0)
    80004b7c:	f9843683          	ld	a3,-104(s0)
    80004b80:	4581                	li	a1,0
    80004b82:	00005517          	auipc	a0,0x5
    80004b86:	f9e50513          	addi	a0,a0,-98 # 80009b20 <etext+0xb20>
    80004b8a:	89bff0ef          	jal	80004424 <log_report>
    80004b8e:	b539                	j	8000499c <end_op+0x64>

0000000080004b90 <log_write>:
  }
}

void
log_write(struct buf *b)
{
    80004b90:	7179                	addi	sp,sp,-48
    80004b92:	f406                	sd	ra,40(sp)
    80004b94:	f022                	sd	s0,32(sp)
    80004b96:	ec26                	sd	s1,24(sp)
    80004b98:	1800                	addi	s0,sp,48
    80004b9a:	84aa                	mv	s1,a0
  acquire(&log.lock);
    80004b9c:	0001d517          	auipc	a0,0x1d
    80004ba0:	5dc50513          	addi	a0,a0,1500 # 80022178 <log>
    80004ba4:	8b6fc0ef          	jal	80000c5a <acquire>

  struct log_state old = log_get_state();
    80004ba8:	855ff0ef          	jal	800043fc <log_get_state>
    80004bac:	fca42823          	sw	a0,-48(s0)
    80004bb0:	02055793          	srli	a5,a0,0x20
    80004bb4:	fcf42a23          	sw	a5,-44(s0)
    80004bb8:	fcb42c23          	sw	a1,-40(s0)

  int i;
  for (i = 0; i < log.lh.n; i++) {
    80004bbc:	0001d617          	auipc	a2,0x1d
    80004bc0:	5e462603          	lw	a2,1508(a2) # 800221a0 <log+0x28>
    80004bc4:	06c05363          	blez	a2,80004c2a <log_write+0x9a>
    if (log.lh.block[i] == b->blockno)
    80004bc8:	44cc                	lw	a1,12(s1)
    80004bca:	0001d717          	auipc	a4,0x1d
    80004bce:	5da70713          	addi	a4,a4,1498 # 800221a4 <log+0x2c>
  for (i = 0; i < log.lh.n; i++) {
    80004bd2:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)
    80004bd4:	4314                	lw	a3,0(a4)
    80004bd6:	04b68b63          	beq	a3,a1,80004c2c <log_write+0x9c>
  for (i = 0; i < log.lh.n; i++) {
    80004bda:	2785                	addiw	a5,a5,1
    80004bdc:	0711                	addi	a4,a4,4
    80004bde:	fec79be3          	bne	a5,a2,80004bd4 <log_write+0x44>
      break;
  }

  log.lh.block[i] = b->blockno;
    80004be2:	060a                	slli	a2,a2,0x2
    80004be4:	02060613          	addi	a2,a2,32
    80004be8:	0001d797          	auipc	a5,0x1d
    80004bec:	59078793          	addi	a5,a5,1424 # 80022178 <log>
    80004bf0:	97b2                	add	a5,a5,a2
    80004bf2:	44d8                	lw	a4,12(s1)
    80004bf4:	c7d8                	sw	a4,12(a5)

  if (i == log.lh.n) {
    bpin(b);
    80004bf6:	8526                	mv	a0,s1
    80004bf8:	ba0fe0ef          	jal	80002f98 <bpin>
    log.lh.n++;
    80004bfc:	0001d717          	auipc	a4,0x1d
    80004c00:	57c70713          	addi	a4,a4,1404 # 80022178 <log>
    80004c04:	571c                	lw	a5,40(a4)
    80004c06:	2785                	addiw	a5,a5,1
    80004c08:	d71c                	sw	a5,40(a4)

    log_report("LOG_WRITE", b->blockno, old, "Add block to log");
    80004c0a:	00005717          	auipc	a4,0x5
    80004c0e:	f4670713          	addi	a4,a4,-186 # 80009b50 <etext+0xb50>
    80004c12:	fd043603          	ld	a2,-48(s0)
    80004c16:	fd843683          	ld	a3,-40(s0)
    80004c1a:	44cc                	lw	a1,12(s1)
    80004c1c:	00005517          	auipc	a0,0x5
    80004c20:	f4c50513          	addi	a0,a0,-180 # 80009b68 <etext+0xb68>
    80004c24:	801ff0ef          	jal	80004424 <log_report>
    80004c28:	a835                	j	80004c64 <log_write+0xd4>
  for (i = 0; i < log.lh.n; i++) {
    80004c2a:	4781                	li	a5,0
  log.lh.block[i] = b->blockno;
    80004c2c:	00279693          	slli	a3,a5,0x2
    80004c30:	02068693          	addi	a3,a3,32
    80004c34:	0001d717          	auipc	a4,0x1d
    80004c38:	54470713          	addi	a4,a4,1348 # 80022178 <log>
    80004c3c:	9736                	add	a4,a4,a3
    80004c3e:	44d4                	lw	a3,12(s1)
    80004c40:	c754                	sw	a3,12(a4)
  if (i == log.lh.n) {
    80004c42:	faf60ae3          	beq	a2,a5,80004bf6 <log_write+0x66>
  } else {
    log_report("LOG_MERGE", b->blockno, old, "Merge block");
    80004c46:	00005717          	auipc	a4,0x5
    80004c4a:	f3270713          	addi	a4,a4,-206 # 80009b78 <etext+0xb78>
    80004c4e:	fd043603          	ld	a2,-48(s0)
    80004c52:	fd843683          	ld	a3,-40(s0)
    80004c56:	44cc                	lw	a1,12(s1)
    80004c58:	00005517          	auipc	a0,0x5
    80004c5c:	f3050513          	addi	a0,a0,-208 # 80009b88 <etext+0xb88>
    80004c60:	fc4ff0ef          	jal	80004424 <log_report>
  }

  release(&log.lock);
    80004c64:	0001d517          	auipc	a0,0x1d
    80004c68:	51450513          	addi	a0,a0,1300 # 80022178 <log>
    80004c6c:	882fc0ef          	jal	80000cee <release>
    80004c70:	70a2                	ld	ra,40(sp)
    80004c72:	7402                	ld	s0,32(sp)
    80004c74:	64e2                	ld	s1,24(sp)
    80004c76:	6145                	addi	sp,sp,48
    80004c78:	8082                	ret

0000000080004c7a <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    80004c7a:	1101                	addi	sp,sp,-32
    80004c7c:	ec06                	sd	ra,24(sp)
    80004c7e:	e822                	sd	s0,16(sp)
    80004c80:	e426                	sd	s1,8(sp)
    80004c82:	e04a                	sd	s2,0(sp)
    80004c84:	1000                	addi	s0,sp,32
    80004c86:	84aa                	mv	s1,a0
    80004c88:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    80004c8a:	00005597          	auipc	a1,0x5
    80004c8e:	f0e58593          	addi	a1,a1,-242 # 80009b98 <etext+0xb98>
    80004c92:	0521                	addi	a0,a0,8
    80004c94:	f3dfb0ef          	jal	80000bd0 <initlock>
  lk->name = name;
    80004c98:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    80004c9c:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004ca0:	0204a423          	sw	zero,40(s1)
}
    80004ca4:	60e2                	ld	ra,24(sp)
    80004ca6:	6442                	ld	s0,16(sp)
    80004ca8:	64a2                	ld	s1,8(sp)
    80004caa:	6902                	ld	s2,0(sp)
    80004cac:	6105                	addi	sp,sp,32
    80004cae:	8082                	ret

0000000080004cb0 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    80004cb0:	1101                	addi	sp,sp,-32
    80004cb2:	ec06                	sd	ra,24(sp)
    80004cb4:	e822                	sd	s0,16(sp)
    80004cb6:	e426                	sd	s1,8(sp)
    80004cb8:	e04a                	sd	s2,0(sp)
    80004cba:	1000                	addi	s0,sp,32
    80004cbc:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004cbe:	00850913          	addi	s2,a0,8
    80004cc2:	854a                	mv	a0,s2
    80004cc4:	f97fb0ef          	jal	80000c5a <acquire>
  while (lk->locked) {
    80004cc8:	409c                	lw	a5,0(s1)
    80004cca:	c799                	beqz	a5,80004cd8 <acquiresleep+0x28>
    sleep(lk, &lk->lk);
    80004ccc:	85ca                	mv	a1,s2
    80004cce:	8526                	mv	a0,s1
    80004cd0:	aaefd0ef          	jal	80001f7e <sleep>
  while (lk->locked) {
    80004cd4:	409c                	lw	a5,0(s1)
    80004cd6:	fbfd                	bnez	a5,80004ccc <acquiresleep+0x1c>
  }
  lk->locked = 1;
    80004cd8:	4785                	li	a5,1
    80004cda:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    80004cdc:	c8dfc0ef          	jal	80001968 <myproc>
    80004ce0:	591c                	lw	a5,48(a0)
    80004ce2:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    80004ce4:	854a                	mv	a0,s2
    80004ce6:	808fc0ef          	jal	80000cee <release>
}
    80004cea:	60e2                	ld	ra,24(sp)
    80004cec:	6442                	ld	s0,16(sp)
    80004cee:	64a2                	ld	s1,8(sp)
    80004cf0:	6902                	ld	s2,0(sp)
    80004cf2:	6105                	addi	sp,sp,32
    80004cf4:	8082                	ret

0000000080004cf6 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    80004cf6:	1101                	addi	sp,sp,-32
    80004cf8:	ec06                	sd	ra,24(sp)
    80004cfa:	e822                	sd	s0,16(sp)
    80004cfc:	e426                	sd	s1,8(sp)
    80004cfe:	e04a                	sd	s2,0(sp)
    80004d00:	1000                	addi	s0,sp,32
    80004d02:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004d04:	00850913          	addi	s2,a0,8
    80004d08:	854a                	mv	a0,s2
    80004d0a:	f51fb0ef          	jal	80000c5a <acquire>
  lk->locked = 0;
    80004d0e:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004d12:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    80004d16:	8526                	mv	a0,s1
    80004d18:	ab2fd0ef          	jal	80001fca <wakeup>
  release(&lk->lk);
    80004d1c:	854a                	mv	a0,s2
    80004d1e:	fd1fb0ef          	jal	80000cee <release>
}
    80004d22:	60e2                	ld	ra,24(sp)
    80004d24:	6442                	ld	s0,16(sp)
    80004d26:	64a2                	ld	s1,8(sp)
    80004d28:	6902                	ld	s2,0(sp)
    80004d2a:	6105                	addi	sp,sp,32
    80004d2c:	8082                	ret

0000000080004d2e <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    80004d2e:	7179                	addi	sp,sp,-48
    80004d30:	f406                	sd	ra,40(sp)
    80004d32:	f022                	sd	s0,32(sp)
    80004d34:	ec26                	sd	s1,24(sp)
    80004d36:	e84a                	sd	s2,16(sp)
    80004d38:	1800                	addi	s0,sp,48
    80004d3a:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    80004d3c:	00850913          	addi	s2,a0,8
    80004d40:	854a                	mv	a0,s2
    80004d42:	f19fb0ef          	jal	80000c5a <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    80004d46:	409c                	lw	a5,0(s1)
    80004d48:	ef81                	bnez	a5,80004d60 <holdingsleep+0x32>
    80004d4a:	4481                	li	s1,0
  release(&lk->lk);
    80004d4c:	854a                	mv	a0,s2
    80004d4e:	fa1fb0ef          	jal	80000cee <release>
  return r;
}
    80004d52:	8526                	mv	a0,s1
    80004d54:	70a2                	ld	ra,40(sp)
    80004d56:	7402                	ld	s0,32(sp)
    80004d58:	64e2                	ld	s1,24(sp)
    80004d5a:	6942                	ld	s2,16(sp)
    80004d5c:	6145                	addi	sp,sp,48
    80004d5e:	8082                	ret
    80004d60:	e44e                	sd	s3,8(sp)
  r = lk->locked && (lk->pid == myproc()->pid);
    80004d62:	0284a983          	lw	s3,40(s1)
    80004d66:	c03fc0ef          	jal	80001968 <myproc>
    80004d6a:	5904                	lw	s1,48(a0)
    80004d6c:	413484b3          	sub	s1,s1,s3
    80004d70:	0014b493          	seqz	s1,s1
    80004d74:	69a2                	ld	s3,8(sp)
    80004d76:	bfd9                	j	80004d4c <holdingsleep+0x1e>

0000000080004d78 <file_report>:
    char *op,
    struct file *f,
    int old_ref,
    int old_off,
    char *details
){
    80004d78:	dc010113          	addi	sp,sp,-576
    80004d7c:	22113c23          	sd	ra,568(sp)
    80004d80:	22813823          	sd	s0,560(sp)
    80004d84:	22913423          	sd	s1,552(sp)
    80004d88:	23213023          	sd	s2,544(sp)
    80004d8c:	21313c23          	sd	s3,536(sp)
    80004d90:	21413823          	sd	s4,528(sp)
    80004d94:	21513423          	sd	s5,520(sp)
    80004d98:	0480                	addi	s0,sp,576
    80004d9a:	892a                	mv	s2,a0
    80004d9c:	84ae                	mv	s1,a1
    80004d9e:	89b2                	mv	s3,a2
    80004da0:	8a36                	mv	s4,a3
    80004da2:	8aba                	mv	s5,a4
    struct fs_event e;

    memset(&e, 0, sizeof(e));
    80004da4:	20000613          	li	a2,512
    80004da8:	4581                	li	a1,0
    80004daa:	dc040513          	addi	a0,s0,-576
    80004dae:	f7dfb0ef          	jal	80000d2a <memset>

    e.ticks = ticks;
    80004db2:	00005797          	auipc	a5,0x5
    80004db6:	2967a783          	lw	a5,662(a5) # 8000a048 <ticks>
    80004dba:	dcf42423          	sw	a5,-568(s0)
    e.pid = myproc() ? myproc()->pid : 0;
    80004dbe:	babfc0ef          	jal	80001968 <myproc>
    80004dc2:	4781                	li	a5,0
    80004dc4:	c501                	beqz	a0,80004dcc <file_report+0x54>
    80004dc6:	ba3fc0ef          	jal	80001968 <myproc>
    80004dca:	591c                	lw	a5,48(a0)
    80004dcc:	dcf42623          	sw	a5,-564(s0)

    e.type = LAYER_FILE;
    80004dd0:	479d                	li	a5,7
    80004dd2:	dcf42823          	sw	a5,-560(s0)

    safestrcpy(e.op_name, op, sizeof(e.op_name));
    80004dd6:	4641                	li	a2,16
    80004dd8:	85ca                	mv	a1,s2
    80004dda:	dd440513          	addi	a0,s0,-556
    80004dde:	8a0fc0ef          	jal	80000e7e <safestrcpy>

    // تم التعديل هنا: استخدام قسم file من الـ union
    e.file.file_type = f->type;
    80004de2:	409c                	lw	a5,0(s1)
    80004de4:	f2f42223          	sw	a5,-220(s0)

    e.file.readable = f->readable;
    80004de8:	0084c783          	lbu	a5,8(s1)
    80004dec:	f2f42423          	sw	a5,-216(s0)
    e.file.writable = f->writable;
    80004df0:	0094c783          	lbu	a5,9(s1)
    80004df4:	f2f42623          	sw	a5,-212(s0)

    e.file.file_ref = f->ref;
    80004df8:	40dc                	lw	a5,4(s1)
    80004dfa:	f2f42823          	sw	a5,-208(s0)
    e.file.old_file_ref = old_ref;
    80004dfe:	f3342a23          	sw	s3,-204(s0)

    e.file.file_off = f->off;
    80004e02:	509c                	lw	a5,32(s1)
    80004e04:	f2f42c23          	sw	a5,-200(s0)
    e.file.old_file_off = old_off;
    80004e08:	f3442e23          	sw	s4,-196(s0)

    safestrcpy(e.details, details, sizeof(e.details));
    80004e0c:	08000613          	li	a2,128
    80004e10:	85d6                	mv	a1,s5
    80004e12:	de440513          	addi	a0,s0,-540
    80004e16:	868fc0ef          	jal	80000e7e <safestrcpy>

    fslog_push(&e);
    80004e1a:	dc040513          	addi	a0,s0,-576
    80004e1e:	1a0020ef          	jal	80006fbe <fslog_push>
}
    80004e22:	23813083          	ld	ra,568(sp)
    80004e26:	23013403          	ld	s0,560(sp)
    80004e2a:	22813483          	ld	s1,552(sp)
    80004e2e:	22013903          	ld	s2,544(sp)
    80004e32:	21813983          	ld	s3,536(sp)
    80004e36:	21013a03          	ld	s4,528(sp)
    80004e3a:	20813a83          	ld	s5,520(sp)
    80004e3e:	24010113          	addi	sp,sp,576
    80004e42:	8082                	ret

0000000080004e44 <fileinit>:

void
fileinit(void)
{
    80004e44:	1141                	addi	sp,sp,-16
    80004e46:	e406                	sd	ra,8(sp)
    80004e48:	e022                	sd	s0,0(sp)
    80004e4a:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    80004e4c:	00005597          	auipc	a1,0x5
    80004e50:	d5c58593          	addi	a1,a1,-676 # 80009ba8 <etext+0xba8>
    80004e54:	0001d517          	auipc	a0,0x1d
    80004e58:	46c50513          	addi	a0,a0,1132 # 800222c0 <ftable>
    80004e5c:	d75fb0ef          	jal	80000bd0 <initlock>
}
    80004e60:	60a2                	ld	ra,8(sp)
    80004e62:	6402                	ld	s0,0(sp)
    80004e64:	0141                	addi	sp,sp,16
    80004e66:	8082                	ret

0000000080004e68 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    80004e68:	1101                	addi	sp,sp,-32
    80004e6a:	ec06                	sd	ra,24(sp)
    80004e6c:	e822                	sd	s0,16(sp)
    80004e6e:	e426                	sd	s1,8(sp)
    80004e70:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    80004e72:	0001d517          	auipc	a0,0x1d
    80004e76:	44e50513          	addi	a0,a0,1102 # 800222c0 <ftable>
    80004e7a:	de1fb0ef          	jal	80000c5a <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004e7e:	0001d497          	auipc	s1,0x1d
    80004e82:	45a48493          	addi	s1,s1,1114 # 800222d8 <ftable+0x18>
    80004e86:	0001e717          	auipc	a4,0x1e
    80004e8a:	3f270713          	addi	a4,a4,1010 # 80023278 <disk>
    if(f->ref == 0){
    80004e8e:	40dc                	lw	a5,4(s1)
    80004e90:	cf89                	beqz	a5,80004eaa <filealloc+0x42>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004e92:	02848493          	addi	s1,s1,40
    80004e96:	fee49ce3          	bne	s1,a4,80004e8e <filealloc+0x26>
);
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    80004e9a:	0001d517          	auipc	a0,0x1d
    80004e9e:	42650513          	addi	a0,a0,1062 # 800222c0 <ftable>
    80004ea2:	e4dfb0ef          	jal	80000cee <release>
  return 0;
    80004ea6:	4481                	li	s1,0
    80004ea8:	a035                	j	80004ed4 <filealloc+0x6c>
      f->ref = 1;
    80004eaa:	4785                	li	a5,1
    80004eac:	c0dc                	sw	a5,4(s1)
      file_report(
    80004eae:	00005717          	auipc	a4,0x5
    80004eb2:	d0270713          	addi	a4,a4,-766 # 80009bb0 <etext+0xbb0>
    80004eb6:	4681                	li	a3,0
    80004eb8:	4601                	li	a2,0
    80004eba:	85a6                	mv	a1,s1
    80004ebc:	00005517          	auipc	a0,0x5
    80004ec0:	d1450513          	addi	a0,a0,-748 # 80009bd0 <etext+0xbd0>
    80004ec4:	eb5ff0ef          	jal	80004d78 <file_report>
      release(&ftable.lock);
    80004ec8:	0001d517          	auipc	a0,0x1d
    80004ecc:	3f850513          	addi	a0,a0,1016 # 800222c0 <ftable>
    80004ed0:	e1ffb0ef          	jal	80000cee <release>
}
    80004ed4:	8526                	mv	a0,s1
    80004ed6:	60e2                	ld	ra,24(sp)
    80004ed8:	6442                	ld	s0,16(sp)
    80004eda:	64a2                	ld	s1,8(sp)
    80004edc:	6105                	addi	sp,sp,32
    80004ede:	8082                	ret

0000000080004ee0 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    80004ee0:	1101                	addi	sp,sp,-32
    80004ee2:	ec06                	sd	ra,24(sp)
    80004ee4:	e822                	sd	s0,16(sp)
    80004ee6:	e426                	sd	s1,8(sp)
    80004ee8:	1000                	addi	s0,sp,32
    80004eea:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80004eec:	0001d517          	auipc	a0,0x1d
    80004ef0:	3d450513          	addi	a0,a0,980 # 800222c0 <ftable>
    80004ef4:	d67fb0ef          	jal	80000c5a <acquire>
  if(f->ref < 1)
    80004ef8:	40d0                	lw	a2,4(s1)
    80004efa:	02c05d63          	blez	a2,80004f34 <filedup+0x54>
    panic("filedup");
  int old_ref = f->ref;
  f->ref++;
    80004efe:	0016079b          	addiw	a5,a2,1
    80004f02:	c0dc                	sw	a5,4(s1)
  file_report(
    80004f04:	00005717          	auipc	a4,0x5
    80004f08:	ce470713          	addi	a4,a4,-796 # 80009be8 <etext+0xbe8>
    80004f0c:	5094                	lw	a3,32(s1)
    80004f0e:	85a6                	mv	a1,s1
    80004f10:	00005517          	auipc	a0,0x5
    80004f14:	cf850513          	addi	a0,a0,-776 # 80009c08 <etext+0xc08>
    80004f18:	e61ff0ef          	jal	80004d78 <file_report>
    f,
    old_ref,
    f->off,
    "Duplicated file descriptor"
);
  release(&ftable.lock);
    80004f1c:	0001d517          	auipc	a0,0x1d
    80004f20:	3a450513          	addi	a0,a0,932 # 800222c0 <ftable>
    80004f24:	dcbfb0ef          	jal	80000cee <release>
  return f;
}
    80004f28:	8526                	mv	a0,s1
    80004f2a:	60e2                	ld	ra,24(sp)
    80004f2c:	6442                	ld	s0,16(sp)
    80004f2e:	64a2                	ld	s1,8(sp)
    80004f30:	6105                	addi	sp,sp,32
    80004f32:	8082                	ret
    panic("filedup");
    80004f34:	00005517          	auipc	a0,0x5
    80004f38:	cac50513          	addi	a0,a0,-852 # 80009be0 <etext+0xbe0>
    80004f3c:	91bfb0ef          	jal	80000856 <panic>

0000000080004f40 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    80004f40:	7139                	addi	sp,sp,-64
    80004f42:	fc06                	sd	ra,56(sp)
    80004f44:	f822                	sd	s0,48(sp)
    80004f46:	f426                	sd	s1,40(sp)
    80004f48:	0080                	addi	s0,sp,64
    80004f4a:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    80004f4c:	0001d517          	auipc	a0,0x1d
    80004f50:	37450513          	addi	a0,a0,884 # 800222c0 <ftable>
    80004f54:	d07fb0ef          	jal	80000c5a <acquire>
  if(f->ref < 1)
    80004f58:	40d0                	lw	a2,4(s1)
    80004f5a:	04c05b63          	blez	a2,80004fb0 <fileclose+0x70>
    panic("fileclose");
  int old_ref = f->ref;
  if(--f->ref > 0){
    80004f5e:	fff6079b          	addiw	a5,a2,-1
    80004f62:	c0dc                	sw	a5,4(s1)
    80004f64:	06f04063          	bgtz	a5,80004fc4 <fileclose+0x84>
    80004f68:	f04a                	sd	s2,32(sp)
    80004f6a:	ec4e                	sd	s3,24(sp)
    80004f6c:	e852                	sd	s4,16(sp)
    80004f6e:	e456                	sd	s5,8(sp)
    "Closing file"
);
    release(&ftable.lock);
    return;
  }
  ff = *f;
    80004f70:	0004a903          	lw	s2,0(s1)
    80004f74:	0094c783          	lbu	a5,9(s1)
    80004f78:	89be                	mv	s3,a5
    80004f7a:	689c                	ld	a5,16(s1)
    80004f7c:	8a3e                	mv	s4,a5
    80004f7e:	6c9c                	ld	a5,24(s1)
    80004f80:	8abe                	mv	s5,a5
  f->ref = 0;
    80004f82:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    80004f86:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    80004f8a:	0001d517          	auipc	a0,0x1d
    80004f8e:	33650513          	addi	a0,a0,822 # 800222c0 <ftable>
    80004f92:	d5dfb0ef          	jal	80000cee <release>

  if(ff.type == FD_PIPE){
    80004f96:	4785                	li	a5,1
    80004f98:	04f90d63          	beq	s2,a5,80004ff2 <fileclose+0xb2>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    80004f9c:	ffe9079b          	addiw	a5,s2,-2
    80004fa0:	4705                	li	a4,1
    80004fa2:	06f77163          	bgeu	a4,a5,80005004 <fileclose+0xc4>
    80004fa6:	7902                	ld	s2,32(sp)
    80004fa8:	69e2                	ld	s3,24(sp)
    80004faa:	6a42                	ld	s4,16(sp)
    80004fac:	6aa2                	ld	s5,8(sp)
    80004fae:	a82d                	j	80004fe8 <fileclose+0xa8>
    80004fb0:	f04a                	sd	s2,32(sp)
    80004fb2:	ec4e                	sd	s3,24(sp)
    80004fb4:	e852                	sd	s4,16(sp)
    80004fb6:	e456                	sd	s5,8(sp)
    panic("fileclose");
    80004fb8:	00005517          	auipc	a0,0x5
    80004fbc:	c6050513          	addi	a0,a0,-928 # 80009c18 <etext+0xc18>
    80004fc0:	897fb0ef          	jal	80000856 <panic>
    file_report(
    80004fc4:	00005717          	auipc	a4,0x5
    80004fc8:	c6470713          	addi	a4,a4,-924 # 80009c28 <etext+0xc28>
    80004fcc:	5094                	lw	a3,32(s1)
    80004fce:	85a6                	mv	a1,s1
    80004fd0:	00005517          	auipc	a0,0x5
    80004fd4:	c6850513          	addi	a0,a0,-920 # 80009c38 <etext+0xc38>
    80004fd8:	da1ff0ef          	jal	80004d78 <file_report>
    release(&ftable.lock);
    80004fdc:	0001d517          	auipc	a0,0x1d
    80004fe0:	2e450513          	addi	a0,a0,740 # 800222c0 <ftable>
    80004fe4:	d0bfb0ef          	jal	80000cee <release>
    begin_op();
    iput(ff.ip);
    end_op();
  }
}
    80004fe8:	70e2                	ld	ra,56(sp)
    80004fea:	7442                	ld	s0,48(sp)
    80004fec:	74a2                	ld	s1,40(sp)
    80004fee:	6121                	addi	sp,sp,64
    80004ff0:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80004ff2:	85ce                	mv	a1,s3
    80004ff4:	8552                	mv	a0,s4
    80004ff6:	394000ef          	jal	8000538a <pipeclose>
    80004ffa:	7902                	ld	s2,32(sp)
    80004ffc:	69e2                	ld	s3,24(sp)
    80004ffe:	6a42                	ld	s4,16(sp)
    80005000:	6aa2                	ld	s5,8(sp)
    80005002:	b7dd                	j	80004fe8 <fileclose+0xa8>
    begin_op();
    80005004:	815ff0ef          	jal	80004818 <begin_op>
    iput(ff.ip);
    80005008:	8556                	mv	a0,s5
    8000500a:	b43fe0ef          	jal	80003b4c <iput>
    end_op();
    8000500e:	92bff0ef          	jal	80004938 <end_op>
    80005012:	7902                	ld	s2,32(sp)
    80005014:	69e2                	ld	s3,24(sp)
    80005016:	6a42                	ld	s4,16(sp)
    80005018:	6aa2                	ld	s5,8(sp)
    8000501a:	b7f9                	j	80004fe8 <fileclose+0xa8>

000000008000501c <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    8000501c:	715d                	addi	sp,sp,-80
    8000501e:	e486                	sd	ra,72(sp)
    80005020:	e0a2                	sd	s0,64(sp)
    80005022:	fc26                	sd	s1,56(sp)
    80005024:	f052                	sd	s4,32(sp)
    80005026:	0880                	addi	s0,sp,80
    80005028:	84aa                	mv	s1,a0
    8000502a:	8a2e                	mv	s4,a1
  struct proc *p = myproc();
    8000502c:	93dfc0ef          	jal	80001968 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    80005030:	409c                	lw	a5,0(s1)
    80005032:	37f9                	addiw	a5,a5,-2
    80005034:	4705                	li	a4,1
    80005036:	04f76263          	bltu	a4,a5,8000507a <filestat+0x5e>
    8000503a:	f84a                	sd	s2,48(sp)
    8000503c:	f44e                	sd	s3,40(sp)
    8000503e:	89aa                	mv	s3,a0
    ilock(f->ip);
    80005040:	6c88                	ld	a0,24(s1)
    80005042:	8fbfe0ef          	jal	8000393c <ilock>
    stati(f->ip, &st);
    80005046:	fb840913          	addi	s2,s0,-72
    8000504a:	85ca                	mv	a1,s2
    8000504c:	6c88                	ld	a0,24(s1)
    8000504e:	d25fe0ef          	jal	80003d72 <stati>
    iunlock(f->ip);
    80005052:	6c88                	ld	a0,24(s1)
    80005054:	9dbfe0ef          	jal	80003a2e <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    80005058:	46e1                	li	a3,24
    8000505a:	864a                	mv	a2,s2
    8000505c:	85d2                	mv	a1,s4
    8000505e:	0509b503          	ld	a0,80(s3)
    80005062:	e2cfc0ef          	jal	8000168e <copyout>
    80005066:	41f5551b          	sraiw	a0,a0,0x1f
    8000506a:	7942                	ld	s2,48(sp)
    8000506c:	79a2                	ld	s3,40(sp)
      return -1;
    return 0;
  }
  return -1;
}
    8000506e:	60a6                	ld	ra,72(sp)
    80005070:	6406                	ld	s0,64(sp)
    80005072:	74e2                	ld	s1,56(sp)
    80005074:	7a02                	ld	s4,32(sp)
    80005076:	6161                	addi	sp,sp,80
    80005078:	8082                	ret
  return -1;
    8000507a:	557d                	li	a0,-1
    8000507c:	bfcd                	j	8000506e <filestat+0x52>

000000008000507e <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    8000507e:	7179                	addi	sp,sp,-48
    80005080:	f406                	sd	ra,40(sp)
    80005082:	f022                	sd	s0,32(sp)
    80005084:	e84a                	sd	s2,16(sp)
    80005086:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    80005088:	00854783          	lbu	a5,8(a0)
    8000508c:	cfdd                	beqz	a5,8000514a <fileread+0xcc>
    8000508e:	ec26                	sd	s1,24(sp)
    80005090:	e44e                	sd	s3,8(sp)
    80005092:	84aa                	mv	s1,a0
    80005094:	892e                	mv	s2,a1
    80005096:	89b2                	mv	s3,a2
    return -1;

  if(f->type == FD_PIPE){
    80005098:	411c                	lw	a5,0(a0)
    8000509a:	4705                	li	a4,1
    8000509c:	06e78463          	beq	a5,a4,80005104 <fileread+0x86>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    800050a0:	470d                	li	a4,3
    800050a2:	06e78863          	beq	a5,a4,80005112 <fileread+0x94>
    800050a6:	e052                	sd	s4,0(sp)
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    800050a8:	4709                	li	a4,2
    800050aa:	08e79a63          	bne	a5,a4,8000513e <fileread+0xc0>
    ilock(f->ip);
    800050ae:	6d08                	ld	a0,24(a0)
    800050b0:	88dfe0ef          	jal	8000393c <ilock>
    int old_off = f->off;
    800050b4:	509c                	lw	a5,32(s1)
    800050b6:	8a3e                	mv	s4,a5

    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    800050b8:	874e                	mv	a4,s3
    800050ba:	86be                	mv	a3,a5
    800050bc:	864a                	mv	a2,s2
    800050be:	4585                	li	a1,1
    800050c0:	6c88                	ld	a0,24(s1)
    800050c2:	cdffe0ef          	jal	80003da0 <readi>
    800050c6:	892a                	mv	s2,a0
    800050c8:	00a05563          	blez	a0,800050d2 <fileread+0x54>
   
    f->off += r;
    800050cc:	509c                	lw	a5,32(s1)
    800050ce:	9fa9                	addw	a5,a5,a0
    800050d0:	d09c                	sw	a5,32(s1)
    file_report(
    800050d2:	00005717          	auipc	a4,0x5
    800050d6:	b7670713          	addi	a4,a4,-1162 # 80009c48 <etext+0xc48>
    800050da:	86d2                	mv	a3,s4
    800050dc:	40d0                	lw	a2,4(s1)
    800050de:	85a6                	mv	a1,s1
    800050e0:	00005517          	auipc	a0,0x5
    800050e4:	b7850513          	addi	a0,a0,-1160 # 80009c58 <etext+0xc58>
    800050e8:	c91ff0ef          	jal	80004d78 <file_report>
    f,
    f->ref,
    old_off,
    "Read from file"
);
    iunlock(f->ip);
    800050ec:	6c88                	ld	a0,24(s1)
    800050ee:	941fe0ef          	jal	80003a2e <iunlock>
    800050f2:	64e2                	ld	s1,24(sp)
    800050f4:	69a2                	ld	s3,8(sp)
    800050f6:	6a02                	ld	s4,0(sp)
  } else {
    panic("fileread");
  }

  return r;
}
    800050f8:	854a                	mv	a0,s2
    800050fa:	70a2                	ld	ra,40(sp)
    800050fc:	7402                	ld	s0,32(sp)
    800050fe:	6942                	ld	s2,16(sp)
    80005100:	6145                	addi	sp,sp,48
    80005102:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80005104:	6908                	ld	a0,16(a0)
    80005106:	3da000ef          	jal	800054e0 <piperead>
    8000510a:	892a                	mv	s2,a0
    8000510c:	64e2                	ld	s1,24(sp)
    8000510e:	69a2                	ld	s3,8(sp)
    80005110:	b7e5                	j	800050f8 <fileread+0x7a>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80005112:	02451783          	lh	a5,36(a0)
    80005116:	03079693          	slli	a3,a5,0x30
    8000511a:	92c1                	srli	a3,a3,0x30
    8000511c:	4725                	li	a4,9
    8000511e:	02d76963          	bltu	a4,a3,80005150 <fileread+0xd2>
    80005122:	0792                	slli	a5,a5,0x4
    80005124:	0001d717          	auipc	a4,0x1d
    80005128:	0fc70713          	addi	a4,a4,252 # 80022220 <devsw>
    8000512c:	97ba                	add	a5,a5,a4
    8000512e:	639c                	ld	a5,0(a5)
    80005130:	c78d                	beqz	a5,8000515a <fileread+0xdc>
    r = devsw[f->major].read(1, addr, n);
    80005132:	4505                	li	a0,1
    80005134:	9782                	jalr	a5
    80005136:	892a                	mv	s2,a0
    80005138:	64e2                	ld	s1,24(sp)
    8000513a:	69a2                	ld	s3,8(sp)
    8000513c:	bf75                	j	800050f8 <fileread+0x7a>
    panic("fileread");
    8000513e:	00005517          	auipc	a0,0x5
    80005142:	b2a50513          	addi	a0,a0,-1238 # 80009c68 <etext+0xc68>
    80005146:	f10fb0ef          	jal	80000856 <panic>
    return -1;
    8000514a:	57fd                	li	a5,-1
    8000514c:	893e                	mv	s2,a5
    8000514e:	b76d                	j	800050f8 <fileread+0x7a>
      return -1;
    80005150:	57fd                	li	a5,-1
    80005152:	893e                	mv	s2,a5
    80005154:	64e2                	ld	s1,24(sp)
    80005156:	69a2                	ld	s3,8(sp)
    80005158:	b745                	j	800050f8 <fileread+0x7a>
    8000515a:	57fd                	li	a5,-1
    8000515c:	893e                	mv	s2,a5
    8000515e:	64e2                	ld	s1,24(sp)
    80005160:	69a2                	ld	s3,8(sp)
    80005162:	bf59                	j	800050f8 <fileread+0x7a>

0000000080005164 <filewrite>:
int
filewrite(struct file *f, uint64 addr, int n)
{
  int r, ret = 0;

  if(f->writable == 0)
    80005164:	00954783          	lbu	a5,9(a0)
    80005168:	14078463          	beqz	a5,800052b0 <filewrite+0x14c>
{
    8000516c:	7119                	addi	sp,sp,-128
    8000516e:	fc86                	sd	ra,120(sp)
    80005170:	f8a2                	sd	s0,112(sp)
    80005172:	f4a6                	sd	s1,104(sp)
    80005174:	e4d6                	sd	s5,72(sp)
    80005176:	fc5e                	sd	s7,56(sp)
    80005178:	0100                	addi	s0,sp,128
    8000517a:	84aa                	mv	s1,a0
    8000517c:	8bae                	mv	s7,a1
    8000517e:	8ab2                	mv	s5,a2
    return -1;

  if(f->type == FD_PIPE){
    80005180:	411c                	lw	a5,0(a0)
    80005182:	4705                	li	a4,1
    80005184:	04e78563          	beq	a5,a4,800051ce <filewrite+0x6a>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80005188:	470d                	li	a4,3
    8000518a:	04e78663          	beq	a5,a4,800051d6 <filewrite+0x72>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    8000518e:	4709                	li	a4,2
    80005190:	10e79263          	bne	a5,a4,80005294 <filewrite+0x130>
    80005194:	e8d2                	sd	s4,80(sp)
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    int old_off;
    while(i < n){
    80005196:	0cc05b63          	blez	a2,8000526c <filewrite+0x108>
    8000519a:	f0ca                	sd	s2,96(sp)
    8000519c:	ecce                	sd	s3,88(sp)
    8000519e:	e0da                	sd	s6,64(sp)
    800051a0:	f862                	sd	s8,48(sp)
    800051a2:	f466                	sd	s9,40(sp)
    800051a4:	f06a                	sd	s10,32(sp)
    800051a6:	ec6e                	sd	s11,24(sp)
    int i = 0;
    800051a8:	4a01                	li	s4,0
      int n1 = n - i;
      if(n1 > max)
    800051aa:	6c05                	lui	s8,0x1
    800051ac:	c00c0c13          	addi	s8,s8,-1024 # c00 <_entry-0x7ffff400>
    800051b0:	6785                	lui	a5,0x1
    800051b2:	c007879b          	addiw	a5,a5,-1024 # c00 <_entry-0x7ffff400>
    800051b6:	f8f42623          	sw	a5,-116(s0)
        n1 = max;

      begin_op();
      ilock(f->ip);
      old_off = f->off;
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    800051ba:	4d85                	li	s11,1
        f->off += r;
      file_report(
    800051bc:	00005d17          	auipc	s10,0x5
    800051c0:	abcd0d13          	addi	s10,s10,-1348 # 80009c78 <etext+0xc78>
    800051c4:	00005c97          	auipc	s9,0x5
    800051c8:	ac4c8c93          	addi	s9,s9,-1340 # 80009c88 <etext+0xc88>
    800051cc:	a041                	j	8000524c <filewrite+0xe8>
    ret = pipewrite(f->pipe, addr, n);
    800051ce:	6908                	ld	a0,16(a0)
    800051d0:	218000ef          	jal	800053e8 <pipewrite>
    800051d4:	a84d                	j	80005286 <filewrite+0x122>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    800051d6:	02451783          	lh	a5,36(a0)
    800051da:	03079693          	slli	a3,a5,0x30
    800051de:	92c1                	srli	a3,a3,0x30
    800051e0:	4725                	li	a4,9
    800051e2:	0cd76963          	bltu	a4,a3,800052b4 <filewrite+0x150>
    800051e6:	0792                	slli	a5,a5,0x4
    800051e8:	0001d717          	auipc	a4,0x1d
    800051ec:	03870713          	addi	a4,a4,56 # 80022220 <devsw>
    800051f0:	97ba                	add	a5,a5,a4
    800051f2:	679c                	ld	a5,8(a5)
    800051f4:	c3f1                	beqz	a5,800052b8 <filewrite+0x154>
    ret = devsw[f->major].write(1, addr, n);
    800051f6:	4505                	li	a0,1
    800051f8:	9782                	jalr	a5
    800051fa:	a071                	j	80005286 <filewrite+0x122>
      if(n1 > max)
    800051fc:	2981                	sext.w	s3,s3
      begin_op();
    800051fe:	e1aff0ef          	jal	80004818 <begin_op>
      ilock(f->ip);
    80005202:	6c88                	ld	a0,24(s1)
    80005204:	f38fe0ef          	jal	8000393c <ilock>
      old_off = f->off;
    80005208:	0204ab03          	lw	s6,32(s1)
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    8000520c:	874e                	mv	a4,s3
    8000520e:	86da                	mv	a3,s6
    80005210:	017a0633          	add	a2,s4,s7
    80005214:	85ee                	mv	a1,s11
    80005216:	6c88                	ld	a0,24(s1)
    80005218:	caffe0ef          	jal	80003ec6 <writei>
    8000521c:	892a                	mv	s2,a0
    8000521e:	00a05563          	blez	a0,80005228 <filewrite+0xc4>
        f->off += r;
    80005222:	509c                	lw	a5,32(s1)
    80005224:	9fa9                	addw	a5,a5,a0
    80005226:	d09c                	sw	a5,32(s1)
      file_report(
    80005228:	876a                	mv	a4,s10
    8000522a:	86da                	mv	a3,s6
    8000522c:	40d0                	lw	a2,4(s1)
    8000522e:	85a6                	mv	a1,s1
    80005230:	8566                	mv	a0,s9
    80005232:	b47ff0ef          	jal	80004d78 <file_report>
    f,
    f->ref,
    old_off,
    "Write to file"
);
      iunlock(f->ip);
    80005236:	6c88                	ld	a0,24(s1)
    80005238:	ff6fe0ef          	jal	80003a2e <iunlock>
      end_op();
    8000523c:	efcff0ef          	jal	80004938 <end_op>

      if(r != n1){
    80005240:	03299863          	bne	s3,s2,80005270 <filewrite+0x10c>
        // error from writei
        break;
      }
      i += r;
    80005244:	01490a3b          	addw	s4,s2,s4
    while(i < n){
    80005248:	015a5a63          	bge	s4,s5,8000525c <filewrite+0xf8>
      int n1 = n - i;
    8000524c:	414a87bb          	subw	a5,s5,s4
    80005250:	89be                	mv	s3,a5
      if(n1 > max)
    80005252:	fafc55e3          	bge	s8,a5,800051fc <filewrite+0x98>
    80005256:	f8c42983          	lw	s3,-116(s0)
    8000525a:	b74d                	j	800051fc <filewrite+0x98>
    8000525c:	7906                	ld	s2,96(sp)
    8000525e:	69e6                	ld	s3,88(sp)
    80005260:	6b06                	ld	s6,64(sp)
    80005262:	7c42                	ld	s8,48(sp)
    80005264:	7ca2                	ld	s9,40(sp)
    80005266:	7d02                	ld	s10,32(sp)
    80005268:	6de2                	ld	s11,24(sp)
    8000526a:	a811                	j	8000527e <filewrite+0x11a>
    int i = 0;
    8000526c:	4a01                	li	s4,0
    8000526e:	a801                	j	8000527e <filewrite+0x11a>
    80005270:	7906                	ld	s2,96(sp)
    80005272:	69e6                	ld	s3,88(sp)
    80005274:	6b06                	ld	s6,64(sp)
    80005276:	7c42                	ld	s8,48(sp)
    80005278:	7ca2                	ld	s9,40(sp)
    8000527a:	7d02                	ld	s10,32(sp)
    8000527c:	6de2                	ld	s11,24(sp)
    }
    ret = (i == n ? n : -1);
    8000527e:	034a9f63          	bne	s5,s4,800052bc <filewrite+0x158>
    80005282:	8556                	mv	a0,s5
    80005284:	6a46                	ld	s4,80(sp)
  } else {
    panic("filewrite");
  }

  return ret;
}
    80005286:	70e6                	ld	ra,120(sp)
    80005288:	7446                	ld	s0,112(sp)
    8000528a:	74a6                	ld	s1,104(sp)
    8000528c:	6aa6                	ld	s5,72(sp)
    8000528e:	7be2                	ld	s7,56(sp)
    80005290:	6109                	addi	sp,sp,128
    80005292:	8082                	ret
    80005294:	f0ca                	sd	s2,96(sp)
    80005296:	ecce                	sd	s3,88(sp)
    80005298:	e8d2                	sd	s4,80(sp)
    8000529a:	e0da                	sd	s6,64(sp)
    8000529c:	f862                	sd	s8,48(sp)
    8000529e:	f466                	sd	s9,40(sp)
    800052a0:	f06a                	sd	s10,32(sp)
    800052a2:	ec6e                	sd	s11,24(sp)
    panic("filewrite");
    800052a4:	00005517          	auipc	a0,0x5
    800052a8:	9f450513          	addi	a0,a0,-1548 # 80009c98 <etext+0xc98>
    800052ac:	daafb0ef          	jal	80000856 <panic>
    return -1;
    800052b0:	557d                	li	a0,-1
}
    800052b2:	8082                	ret
      return -1;
    800052b4:	557d                	li	a0,-1
    800052b6:	bfc1                	j	80005286 <filewrite+0x122>
    800052b8:	557d                	li	a0,-1
    800052ba:	b7f1                	j	80005286 <filewrite+0x122>
    ret = (i == n ? n : -1);
    800052bc:	557d                	li	a0,-1
    800052be:	6a46                	ld	s4,80(sp)
    800052c0:	b7d9                	j	80005286 <filewrite+0x122>

00000000800052c2 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    800052c2:	7179                	addi	sp,sp,-48
    800052c4:	f406                	sd	ra,40(sp)
    800052c6:	f022                	sd	s0,32(sp)
    800052c8:	ec26                	sd	s1,24(sp)
    800052ca:	e052                	sd	s4,0(sp)
    800052cc:	1800                	addi	s0,sp,48
    800052ce:	84aa                	mv	s1,a0
    800052d0:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    800052d2:	0005b023          	sd	zero,0(a1)
    800052d6:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    800052da:	b8fff0ef          	jal	80004e68 <filealloc>
    800052de:	e088                	sd	a0,0(s1)
    800052e0:	c549                	beqz	a0,8000536a <pipealloc+0xa8>
    800052e2:	b87ff0ef          	jal	80004e68 <filealloc>
    800052e6:	00aa3023          	sd	a0,0(s4)
    800052ea:	cd25                	beqz	a0,80005362 <pipealloc+0xa0>
    800052ec:	e84a                	sd	s2,16(sp)
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    800052ee:	889fb0ef          	jal	80000b76 <kalloc>
    800052f2:	892a                	mv	s2,a0
    800052f4:	c12d                	beqz	a0,80005356 <pipealloc+0x94>
    800052f6:	e44e                	sd	s3,8(sp)
    goto bad;
  pi->readopen = 1;
    800052f8:	4985                	li	s3,1
    800052fa:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    800052fe:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    80005302:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80005306:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    8000530a:	00005597          	auipc	a1,0x5
    8000530e:	99e58593          	addi	a1,a1,-1634 # 80009ca8 <etext+0xca8>
    80005312:	8bffb0ef          	jal	80000bd0 <initlock>
  (*f0)->type = FD_PIPE;
    80005316:	609c                	ld	a5,0(s1)
    80005318:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    8000531c:	609c                	ld	a5,0(s1)
    8000531e:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80005322:	609c                	ld	a5,0(s1)
    80005324:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80005328:	609c                	ld	a5,0(s1)
    8000532a:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    8000532e:	000a3783          	ld	a5,0(s4)
    80005332:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80005336:	000a3783          	ld	a5,0(s4)
    8000533a:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    8000533e:	000a3783          	ld	a5,0(s4)
    80005342:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80005346:	000a3783          	ld	a5,0(s4)
    8000534a:	0127b823          	sd	s2,16(a5)
  return 0;
    8000534e:	4501                	li	a0,0
    80005350:	6942                	ld	s2,16(sp)
    80005352:	69a2                	ld	s3,8(sp)
    80005354:	a01d                	j	8000537a <pipealloc+0xb8>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80005356:	6088                	ld	a0,0(s1)
    80005358:	c119                	beqz	a0,8000535e <pipealloc+0x9c>
    8000535a:	6942                	ld	s2,16(sp)
    8000535c:	a029                	j	80005366 <pipealloc+0xa4>
    8000535e:	6942                	ld	s2,16(sp)
    80005360:	a029                	j	8000536a <pipealloc+0xa8>
    80005362:	6088                	ld	a0,0(s1)
    80005364:	c10d                	beqz	a0,80005386 <pipealloc+0xc4>
    fileclose(*f0);
    80005366:	bdbff0ef          	jal	80004f40 <fileclose>
  if(*f1)
    8000536a:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    8000536e:	557d                	li	a0,-1
  if(*f1)
    80005370:	c789                	beqz	a5,8000537a <pipealloc+0xb8>
    fileclose(*f1);
    80005372:	853e                	mv	a0,a5
    80005374:	bcdff0ef          	jal	80004f40 <fileclose>
  return -1;
    80005378:	557d                	li	a0,-1
}
    8000537a:	70a2                	ld	ra,40(sp)
    8000537c:	7402                	ld	s0,32(sp)
    8000537e:	64e2                	ld	s1,24(sp)
    80005380:	6a02                	ld	s4,0(sp)
    80005382:	6145                	addi	sp,sp,48
    80005384:	8082                	ret
  return -1;
    80005386:	557d                	li	a0,-1
    80005388:	bfcd                	j	8000537a <pipealloc+0xb8>

000000008000538a <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    8000538a:	1101                	addi	sp,sp,-32
    8000538c:	ec06                	sd	ra,24(sp)
    8000538e:	e822                	sd	s0,16(sp)
    80005390:	e426                	sd	s1,8(sp)
    80005392:	e04a                	sd	s2,0(sp)
    80005394:	1000                	addi	s0,sp,32
    80005396:	84aa                	mv	s1,a0
    80005398:	892e                	mv	s2,a1
  acquire(&pi->lock);
    8000539a:	8c1fb0ef          	jal	80000c5a <acquire>
  if(writable){
    8000539e:	02090763          	beqz	s2,800053cc <pipeclose+0x42>
    pi->writeopen = 0;
    800053a2:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    800053a6:	21848513          	addi	a0,s1,536
    800053aa:	c21fc0ef          	jal	80001fca <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    800053ae:	2204a783          	lw	a5,544(s1)
    800053b2:	e781                	bnez	a5,800053ba <pipeclose+0x30>
    800053b4:	2244a783          	lw	a5,548(s1)
    800053b8:	c38d                	beqz	a5,800053da <pipeclose+0x50>
    release(&pi->lock);
    kfree((char*)pi);
  } else
    release(&pi->lock);
    800053ba:	8526                	mv	a0,s1
    800053bc:	933fb0ef          	jal	80000cee <release>
}
    800053c0:	60e2                	ld	ra,24(sp)
    800053c2:	6442                	ld	s0,16(sp)
    800053c4:	64a2                	ld	s1,8(sp)
    800053c6:	6902                	ld	s2,0(sp)
    800053c8:	6105                	addi	sp,sp,32
    800053ca:	8082                	ret
    pi->readopen = 0;
    800053cc:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    800053d0:	21c48513          	addi	a0,s1,540
    800053d4:	bf7fc0ef          	jal	80001fca <wakeup>
    800053d8:	bfd9                	j	800053ae <pipeclose+0x24>
    release(&pi->lock);
    800053da:	8526                	mv	a0,s1
    800053dc:	913fb0ef          	jal	80000cee <release>
    kfree((char*)pi);
    800053e0:	8526                	mv	a0,s1
    800053e2:	eacfb0ef          	jal	80000a8e <kfree>
    800053e6:	bfe9                	j	800053c0 <pipeclose+0x36>

00000000800053e8 <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    800053e8:	7159                	addi	sp,sp,-112
    800053ea:	f486                	sd	ra,104(sp)
    800053ec:	f0a2                	sd	s0,96(sp)
    800053ee:	eca6                	sd	s1,88(sp)
    800053f0:	e8ca                	sd	s2,80(sp)
    800053f2:	e4ce                	sd	s3,72(sp)
    800053f4:	e0d2                	sd	s4,64(sp)
    800053f6:	fc56                	sd	s5,56(sp)
    800053f8:	1880                	addi	s0,sp,112
    800053fa:	84aa                	mv	s1,a0
    800053fc:	8aae                	mv	s5,a1
    800053fe:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    80005400:	d68fc0ef          	jal	80001968 <myproc>
    80005404:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    80005406:	8526                	mv	a0,s1
    80005408:	853fb0ef          	jal	80000c5a <acquire>
  while(i < n){
    8000540c:	0d405263          	blez	s4,800054d0 <pipewrite+0xe8>
    80005410:	f85a                	sd	s6,48(sp)
    80005412:	f45e                	sd	s7,40(sp)
    80005414:	f062                	sd	s8,32(sp)
    80005416:	ec66                	sd	s9,24(sp)
    80005418:	e86a                	sd	s10,16(sp)
  int i = 0;
    8000541a:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    8000541c:	f9f40c13          	addi	s8,s0,-97
    80005420:	4b85                	li	s7,1
    80005422:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    80005424:	21848d13          	addi	s10,s1,536
      sleep(&pi->nwrite, &pi->lock);
    80005428:	21c48c93          	addi	s9,s1,540
    8000542c:	a82d                	j	80005466 <pipewrite+0x7e>
      release(&pi->lock);
    8000542e:	8526                	mv	a0,s1
    80005430:	8bffb0ef          	jal	80000cee <release>
      return -1;
    80005434:	597d                	li	s2,-1
    80005436:	7b42                	ld	s6,48(sp)
    80005438:	7ba2                	ld	s7,40(sp)
    8000543a:	7c02                	ld	s8,32(sp)
    8000543c:	6ce2                	ld	s9,24(sp)
    8000543e:	6d42                	ld	s10,16(sp)
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    80005440:	854a                	mv	a0,s2
    80005442:	70a6                	ld	ra,104(sp)
    80005444:	7406                	ld	s0,96(sp)
    80005446:	64e6                	ld	s1,88(sp)
    80005448:	6946                	ld	s2,80(sp)
    8000544a:	69a6                	ld	s3,72(sp)
    8000544c:	6a06                	ld	s4,64(sp)
    8000544e:	7ae2                	ld	s5,56(sp)
    80005450:	6165                	addi	sp,sp,112
    80005452:	8082                	ret
      wakeup(&pi->nread);
    80005454:	856a                	mv	a0,s10
    80005456:	b75fc0ef          	jal	80001fca <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    8000545a:	85a6                	mv	a1,s1
    8000545c:	8566                	mv	a0,s9
    8000545e:	b21fc0ef          	jal	80001f7e <sleep>
  while(i < n){
    80005462:	05495a63          	bge	s2,s4,800054b6 <pipewrite+0xce>
    if(pi->readopen == 0 || killed(pr)){
    80005466:	2204a783          	lw	a5,544(s1)
    8000546a:	d3f1                	beqz	a5,8000542e <pipewrite+0x46>
    8000546c:	854e                	mv	a0,s3
    8000546e:	d4dfc0ef          	jal	800021ba <killed>
    80005472:	fd55                	bnez	a0,8000542e <pipewrite+0x46>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    80005474:	2184a783          	lw	a5,536(s1)
    80005478:	21c4a703          	lw	a4,540(s1)
    8000547c:	2007879b          	addiw	a5,a5,512
    80005480:	fcf70ae3          	beq	a4,a5,80005454 <pipewrite+0x6c>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80005484:	86de                	mv	a3,s7
    80005486:	01590633          	add	a2,s2,s5
    8000548a:	85e2                	mv	a1,s8
    8000548c:	0509b503          	ld	a0,80(s3)
    80005490:	abcfc0ef          	jal	8000174c <copyin>
    80005494:	05650063          	beq	a0,s6,800054d4 <pipewrite+0xec>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80005498:	21c4a783          	lw	a5,540(s1)
    8000549c:	0017871b          	addiw	a4,a5,1
    800054a0:	20e4ae23          	sw	a4,540(s1)
    800054a4:	1ff7f793          	andi	a5,a5,511
    800054a8:	97a6                	add	a5,a5,s1
    800054aa:	f9f44703          	lbu	a4,-97(s0)
    800054ae:	00e78c23          	sb	a4,24(a5)
      i++;
    800054b2:	2905                	addiw	s2,s2,1
    800054b4:	b77d                	j	80005462 <pipewrite+0x7a>
    800054b6:	7b42                	ld	s6,48(sp)
    800054b8:	7ba2                	ld	s7,40(sp)
    800054ba:	7c02                	ld	s8,32(sp)
    800054bc:	6ce2                	ld	s9,24(sp)
    800054be:	6d42                	ld	s10,16(sp)
  wakeup(&pi->nread);
    800054c0:	21848513          	addi	a0,s1,536
    800054c4:	b07fc0ef          	jal	80001fca <wakeup>
  release(&pi->lock);
    800054c8:	8526                	mv	a0,s1
    800054ca:	825fb0ef          	jal	80000cee <release>
  return i;
    800054ce:	bf8d                	j	80005440 <pipewrite+0x58>
  int i = 0;
    800054d0:	4901                	li	s2,0
    800054d2:	b7fd                	j	800054c0 <pipewrite+0xd8>
    800054d4:	7b42                	ld	s6,48(sp)
    800054d6:	7ba2                	ld	s7,40(sp)
    800054d8:	7c02                	ld	s8,32(sp)
    800054da:	6ce2                	ld	s9,24(sp)
    800054dc:	6d42                	ld	s10,16(sp)
    800054de:	b7cd                	j	800054c0 <pipewrite+0xd8>

00000000800054e0 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    800054e0:	711d                	addi	sp,sp,-96
    800054e2:	ec86                	sd	ra,88(sp)
    800054e4:	e8a2                	sd	s0,80(sp)
    800054e6:	e4a6                	sd	s1,72(sp)
    800054e8:	e0ca                	sd	s2,64(sp)
    800054ea:	fc4e                	sd	s3,56(sp)
    800054ec:	f852                	sd	s4,48(sp)
    800054ee:	f456                	sd	s5,40(sp)
    800054f0:	1080                	addi	s0,sp,96
    800054f2:	84aa                	mv	s1,a0
    800054f4:	892e                	mv	s2,a1
    800054f6:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    800054f8:	c70fc0ef          	jal	80001968 <myproc>
    800054fc:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    800054fe:	8526                	mv	a0,s1
    80005500:	f5afb0ef          	jal	80000c5a <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80005504:	2184a703          	lw	a4,536(s1)
    80005508:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    8000550c:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80005510:	02f71763          	bne	a4,a5,8000553e <piperead+0x5e>
    80005514:	2244a783          	lw	a5,548(s1)
    80005518:	cf85                	beqz	a5,80005550 <piperead+0x70>
    if(killed(pr)){
    8000551a:	8552                	mv	a0,s4
    8000551c:	c9ffc0ef          	jal	800021ba <killed>
    80005520:	e11d                	bnez	a0,80005546 <piperead+0x66>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80005522:	85a6                	mv	a1,s1
    80005524:	854e                	mv	a0,s3
    80005526:	a59fc0ef          	jal	80001f7e <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    8000552a:	2184a703          	lw	a4,536(s1)
    8000552e:	21c4a783          	lw	a5,540(s1)
    80005532:	fef701e3          	beq	a4,a5,80005514 <piperead+0x34>
    80005536:	f05a                	sd	s6,32(sp)
    80005538:	ec5e                	sd	s7,24(sp)
    8000553a:	e862                	sd	s8,16(sp)
    8000553c:	a829                	j	80005556 <piperead+0x76>
    8000553e:	f05a                	sd	s6,32(sp)
    80005540:	ec5e                	sd	s7,24(sp)
    80005542:	e862                	sd	s8,16(sp)
    80005544:	a809                	j	80005556 <piperead+0x76>
      release(&pi->lock);
    80005546:	8526                	mv	a0,s1
    80005548:	fa6fb0ef          	jal	80000cee <release>
      return -1;
    8000554c:	59fd                	li	s3,-1
    8000554e:	a0a5                	j	800055b6 <piperead+0xd6>
    80005550:	f05a                	sd	s6,32(sp)
    80005552:	ec5e                	sd	s7,24(sp)
    80005554:	e862                	sd	s8,16(sp)
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80005556:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1) {
    80005558:	faf40c13          	addi	s8,s0,-81
    8000555c:	4b85                	li	s7,1
    8000555e:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80005560:	05505163          	blez	s5,800055a2 <piperead+0xc2>
    if(pi->nread == pi->nwrite)
    80005564:	2184a783          	lw	a5,536(s1)
    80005568:	21c4a703          	lw	a4,540(s1)
    8000556c:	02f70b63          	beq	a4,a5,800055a2 <piperead+0xc2>
    ch = pi->data[pi->nread % PIPESIZE];
    80005570:	1ff7f793          	andi	a5,a5,511
    80005574:	97a6                	add	a5,a5,s1
    80005576:	0187c783          	lbu	a5,24(a5)
    8000557a:	faf407a3          	sb	a5,-81(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1) {
    8000557e:	86de                	mv	a3,s7
    80005580:	8662                	mv	a2,s8
    80005582:	85ca                	mv	a1,s2
    80005584:	050a3503          	ld	a0,80(s4)
    80005588:	906fc0ef          	jal	8000168e <copyout>
    8000558c:	03650f63          	beq	a0,s6,800055ca <piperead+0xea>
      if(i == 0)
        i = -1;
      break;
    }
    pi->nread++;
    80005590:	2184a783          	lw	a5,536(s1)
    80005594:	2785                	addiw	a5,a5,1
    80005596:	20f4ac23          	sw	a5,536(s1)
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    8000559a:	2985                	addiw	s3,s3,1
    8000559c:	0905                	addi	s2,s2,1
    8000559e:	fd3a93e3          	bne	s5,s3,80005564 <piperead+0x84>
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    800055a2:	21c48513          	addi	a0,s1,540
    800055a6:	a25fc0ef          	jal	80001fca <wakeup>
  release(&pi->lock);
    800055aa:	8526                	mv	a0,s1
    800055ac:	f42fb0ef          	jal	80000cee <release>
    800055b0:	7b02                	ld	s6,32(sp)
    800055b2:	6be2                	ld	s7,24(sp)
    800055b4:	6c42                	ld	s8,16(sp)
  return i;
}
    800055b6:	854e                	mv	a0,s3
    800055b8:	60e6                	ld	ra,88(sp)
    800055ba:	6446                	ld	s0,80(sp)
    800055bc:	64a6                	ld	s1,72(sp)
    800055be:	6906                	ld	s2,64(sp)
    800055c0:	79e2                	ld	s3,56(sp)
    800055c2:	7a42                	ld	s4,48(sp)
    800055c4:	7aa2                	ld	s5,40(sp)
    800055c6:	6125                	addi	sp,sp,96
    800055c8:	8082                	ret
      if(i == 0)
    800055ca:	fc099ce3          	bnez	s3,800055a2 <piperead+0xc2>
        i = -1;
    800055ce:	89aa                	mv	s3,a0
    800055d0:	bfc9                	j	800055a2 <piperead+0xc2>

00000000800055d2 <flags2perm>:

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

// map ELF permissions to PTE permission bits.
int flags2perm(int flags)
{
    800055d2:	1141                	addi	sp,sp,-16
    800055d4:	e406                	sd	ra,8(sp)
    800055d6:	e022                	sd	s0,0(sp)
    800055d8:	0800                	addi	s0,sp,16
    800055da:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    800055dc:	0035151b          	slliw	a0,a0,0x3
    800055e0:	8921                	andi	a0,a0,8
      perm = PTE_X;
    if(flags & 0x2)
    800055e2:	8b89                	andi	a5,a5,2
    800055e4:	c399                	beqz	a5,800055ea <flags2perm+0x18>
      perm |= PTE_W;
    800055e6:	00456513          	ori	a0,a0,4
    return perm;
}
    800055ea:	60a2                	ld	ra,8(sp)
    800055ec:	6402                	ld	s0,0(sp)
    800055ee:	0141                	addi	sp,sp,16
    800055f0:	8082                	ret

00000000800055f2 <kexec>:
//
// the implementation of the exec() system call
//
int
kexec(char *path, char **argv)
{
    800055f2:	de010113          	addi	sp,sp,-544
    800055f6:	20113c23          	sd	ra,536(sp)
    800055fa:	20813823          	sd	s0,528(sp)
    800055fe:	20913423          	sd	s1,520(sp)
    80005602:	21213023          	sd	s2,512(sp)
    80005606:	1400                	addi	s0,sp,544
    80005608:	892a                	mv	s2,a0
    8000560a:	dea43823          	sd	a0,-528(s0)
    8000560e:	e0b43023          	sd	a1,-512(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80005612:	b56fc0ef          	jal	80001968 <myproc>
    80005616:	84aa                	mv	s1,a0

  begin_op();
    80005618:	a00ff0ef          	jal	80004818 <begin_op>

  // Open the executable file.
  if((ip = namei(path)) == 0){
    8000561c:	854a                	mv	a0,s2
    8000561e:	dadfe0ef          	jal	800043ca <namei>
    80005622:	cd21                	beqz	a0,8000567a <kexec+0x88>
    80005624:	fbd2                	sd	s4,496(sp)
    80005626:	8a2a                	mv	s4,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80005628:	b14fe0ef          	jal	8000393c <ilock>

  // Read the ELF header.
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    8000562c:	04000713          	li	a4,64
    80005630:	4681                	li	a3,0
    80005632:	e5040613          	addi	a2,s0,-432
    80005636:	4581                	li	a1,0
    80005638:	8552                	mv	a0,s4
    8000563a:	f66fe0ef          	jal	80003da0 <readi>
    8000563e:	04000793          	li	a5,64
    80005642:	00f51a63          	bne	a0,a5,80005656 <kexec+0x64>
    goto bad;

  // Is this really an ELF file?
  if(elf.magic != ELF_MAGIC)
    80005646:	e5042703          	lw	a4,-432(s0)
    8000564a:	464c47b7          	lui	a5,0x464c4
    8000564e:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80005652:	02f70863          	beq	a4,a5,80005682 <kexec+0x90>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    80005656:	8552                	mv	a0,s4
    80005658:	dc2fe0ef          	jal	80003c1a <iunlockput>
    end_op();
    8000565c:	adcff0ef          	jal	80004938 <end_op>
  }
  return -1;
    80005660:	557d                	li	a0,-1
    80005662:	7a5e                	ld	s4,496(sp)
}
    80005664:	21813083          	ld	ra,536(sp)
    80005668:	21013403          	ld	s0,528(sp)
    8000566c:	20813483          	ld	s1,520(sp)
    80005670:	20013903          	ld	s2,512(sp)
    80005674:	22010113          	addi	sp,sp,544
    80005678:	8082                	ret
    end_op();
    8000567a:	abeff0ef          	jal	80004938 <end_op>
    return -1;
    8000567e:	557d                	li	a0,-1
    80005680:	b7d5                	j	80005664 <kexec+0x72>
    80005682:	f3da                	sd	s6,480(sp)
  if((pagetable = proc_pagetable(p)) == 0)
    80005684:	8526                	mv	a0,s1
    80005686:	becfc0ef          	jal	80001a72 <proc_pagetable>
    8000568a:	8b2a                	mv	s6,a0
    8000568c:	26050f63          	beqz	a0,8000590a <kexec+0x318>
    80005690:	ffce                	sd	s3,504(sp)
    80005692:	f7d6                	sd	s5,488(sp)
    80005694:	efde                	sd	s7,472(sp)
    80005696:	ebe2                	sd	s8,464(sp)
    80005698:	e7e6                	sd	s9,456(sp)
    8000569a:	e3ea                	sd	s10,448(sp)
    8000569c:	ff6e                	sd	s11,440(sp)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    8000569e:	e8845783          	lhu	a5,-376(s0)
    800056a2:	0e078963          	beqz	a5,80005794 <kexec+0x1a2>
    800056a6:	e7042683          	lw	a3,-400(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    800056aa:	4901                	li	s2,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800056ac:	4d01                	li	s10,0
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    800056ae:	03800d93          	li	s11,56
    if(ph.vaddr % PGSIZE != 0)
    800056b2:	6c85                	lui	s9,0x1
    800056b4:	fffc8793          	addi	a5,s9,-1 # fff <_entry-0x7ffff001>
    800056b8:	def43423          	sd	a5,-536(s0)

  for(i = 0; i < sz; i += PGSIZE){
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    if(sz - i < PGSIZE)
    800056bc:	6a85                	lui	s5,0x1
    800056be:	a085                	j	8000571e <kexec+0x12c>
      panic("loadseg: address should exist");
    800056c0:	00004517          	auipc	a0,0x4
    800056c4:	5f050513          	addi	a0,a0,1520 # 80009cb0 <etext+0xcb0>
    800056c8:	98efb0ef          	jal	80000856 <panic>
    if(sz - i < PGSIZE)
    800056cc:	2901                	sext.w	s2,s2
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    800056ce:	874a                	mv	a4,s2
    800056d0:	009b86bb          	addw	a3,s7,s1
    800056d4:	4581                	li	a1,0
    800056d6:	8552                	mv	a0,s4
    800056d8:	ec8fe0ef          	jal	80003da0 <readi>
    800056dc:	22a91b63          	bne	s2,a0,80005912 <kexec+0x320>
  for(i = 0; i < sz; i += PGSIZE){
    800056e0:	009a84bb          	addw	s1,s5,s1
    800056e4:	0334f263          	bgeu	s1,s3,80005708 <kexec+0x116>
    pa = walkaddr(pagetable, va + i);
    800056e8:	02049593          	slli	a1,s1,0x20
    800056ec:	9181                	srli	a1,a1,0x20
    800056ee:	95e2                	add	a1,a1,s8
    800056f0:	855a                	mv	a0,s6
    800056f2:	96ffb0ef          	jal	80001060 <walkaddr>
    800056f6:	862a                	mv	a2,a0
    if(pa == 0)
    800056f8:	d561                	beqz	a0,800056c0 <kexec+0xce>
    if(sz - i < PGSIZE)
    800056fa:	409987bb          	subw	a5,s3,s1
    800056fe:	893e                	mv	s2,a5
    80005700:	fcfcf6e3          	bgeu	s9,a5,800056cc <kexec+0xda>
    80005704:	8956                	mv	s2,s5
    80005706:	b7d9                	j	800056cc <kexec+0xda>
    sz = sz1;
    80005708:	df843903          	ld	s2,-520(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    8000570c:	2d05                	addiw	s10,s10,1
    8000570e:	e0843783          	ld	a5,-504(s0)
    80005712:	0387869b          	addiw	a3,a5,56
    80005716:	e8845783          	lhu	a5,-376(s0)
    8000571a:	06fd5e63          	bge	s10,a5,80005796 <kexec+0x1a4>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    8000571e:	e0d43423          	sd	a3,-504(s0)
    80005722:	876e                	mv	a4,s11
    80005724:	e1840613          	addi	a2,s0,-488
    80005728:	4581                	li	a1,0
    8000572a:	8552                	mv	a0,s4
    8000572c:	e74fe0ef          	jal	80003da0 <readi>
    80005730:	1db51f63          	bne	a0,s11,8000590e <kexec+0x31c>
    if(ph.type != ELF_PROG_LOAD)
    80005734:	e1842783          	lw	a5,-488(s0)
    80005738:	4705                	li	a4,1
    8000573a:	fce799e3          	bne	a5,a4,8000570c <kexec+0x11a>
    if(ph.memsz < ph.filesz)
    8000573e:	e4043483          	ld	s1,-448(s0)
    80005742:	e3843783          	ld	a5,-456(s0)
    80005746:	1ef4e463          	bltu	s1,a5,8000592e <kexec+0x33c>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    8000574a:	e2843783          	ld	a5,-472(s0)
    8000574e:	94be                	add	s1,s1,a5
    80005750:	1ef4e263          	bltu	s1,a5,80005934 <kexec+0x342>
    if(ph.vaddr % PGSIZE != 0)
    80005754:	de843703          	ld	a4,-536(s0)
    80005758:	8ff9                	and	a5,a5,a4
    8000575a:	1e079063          	bnez	a5,8000593a <kexec+0x348>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    8000575e:	e1c42503          	lw	a0,-484(s0)
    80005762:	e71ff0ef          	jal	800055d2 <flags2perm>
    80005766:	86aa                	mv	a3,a0
    80005768:	8626                	mv	a2,s1
    8000576a:	85ca                	mv	a1,s2
    8000576c:	855a                	mv	a0,s6
    8000576e:	bc9fb0ef          	jal	80001336 <uvmalloc>
    80005772:	dea43c23          	sd	a0,-520(s0)
    80005776:	1c050563          	beqz	a0,80005940 <kexec+0x34e>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    8000577a:	e3842983          	lw	s3,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    8000577e:	00098863          	beqz	s3,8000578e <kexec+0x19c>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80005782:	e2843c03          	ld	s8,-472(s0)
    80005786:	e2042b83          	lw	s7,-480(s0)
  for(i = 0; i < sz; i += PGSIZE){
    8000578a:	4481                	li	s1,0
    8000578c:	bfb1                	j	800056e8 <kexec+0xf6>
    sz = sz1;
    8000578e:	df843903          	ld	s2,-520(s0)
    80005792:	bfad                	j	8000570c <kexec+0x11a>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80005794:	4901                	li	s2,0
  iunlockput(ip);
    80005796:	8552                	mv	a0,s4
    80005798:	c82fe0ef          	jal	80003c1a <iunlockput>
  end_op();
    8000579c:	99cff0ef          	jal	80004938 <end_op>
  p = myproc();
    800057a0:	9c8fc0ef          	jal	80001968 <myproc>
    800057a4:	8aaa                	mv	s5,a0
  uint64 oldsz = p->sz;
    800057a6:	04853d03          	ld	s10,72(a0)
  sz = PGROUNDUP(sz);
    800057aa:	6985                	lui	s3,0x1
    800057ac:	19fd                	addi	s3,s3,-1 # fff <_entry-0x7ffff001>
    800057ae:	99ca                	add	s3,s3,s2
    800057b0:	77fd                	lui	a5,0xfffff
    800057b2:	00f9f9b3          	and	s3,s3,a5
  if((sz1 = uvmalloc(pagetable, sz, sz + (USERSTACK+1)*PGSIZE, PTE_W)) == 0)
    800057b6:	4691                	li	a3,4
    800057b8:	6609                	lui	a2,0x2
    800057ba:	964e                	add	a2,a2,s3
    800057bc:	85ce                	mv	a1,s3
    800057be:	855a                	mv	a0,s6
    800057c0:	b77fb0ef          	jal	80001336 <uvmalloc>
    800057c4:	8a2a                	mv	s4,a0
    800057c6:	e105                	bnez	a0,800057e6 <kexec+0x1f4>
    proc_freepagetable(pagetable, sz);
    800057c8:	85ce                	mv	a1,s3
    800057ca:	855a                	mv	a0,s6
    800057cc:	b2afc0ef          	jal	80001af6 <proc_freepagetable>
  return -1;
    800057d0:	557d                	li	a0,-1
    800057d2:	79fe                	ld	s3,504(sp)
    800057d4:	7a5e                	ld	s4,496(sp)
    800057d6:	7abe                	ld	s5,488(sp)
    800057d8:	7b1e                	ld	s6,480(sp)
    800057da:	6bfe                	ld	s7,472(sp)
    800057dc:	6c5e                	ld	s8,464(sp)
    800057de:	6cbe                	ld	s9,456(sp)
    800057e0:	6d1e                	ld	s10,448(sp)
    800057e2:	7dfa                	ld	s11,440(sp)
    800057e4:	b541                	j	80005664 <kexec+0x72>
  uvmclear(pagetable, sz-(USERSTACK+1)*PGSIZE);
    800057e6:	75f9                	lui	a1,0xffffe
    800057e8:	95aa                	add	a1,a1,a0
    800057ea:	855a                	mv	a0,s6
    800057ec:	d1dfb0ef          	jal	80001508 <uvmclear>
  stackbase = sp - USERSTACK*PGSIZE;
    800057f0:	800a0b93          	addi	s7,s4,-2048
    800057f4:	800b8b93          	addi	s7,s7,-2048
  for(argc = 0; argv[argc]; argc++) {
    800057f8:	e0043783          	ld	a5,-512(s0)
    800057fc:	6388                	ld	a0,0(a5)
  sp = sz;
    800057fe:	8952                	mv	s2,s4
  for(argc = 0; argv[argc]; argc++) {
    80005800:	4481                	li	s1,0
    ustack[argc] = sp;
    80005802:	e9040c93          	addi	s9,s0,-368
    if(argc >= MAXARG)
    80005806:	02000c13          	li	s8,32
  for(argc = 0; argv[argc]; argc++) {
    8000580a:	cd21                	beqz	a0,80005862 <kexec+0x270>
    sp -= strlen(argv[argc]) + 1;
    8000580c:	ea8fb0ef          	jal	80000eb4 <strlen>
    80005810:	0015079b          	addiw	a5,a0,1
    80005814:	40f907b3          	sub	a5,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80005818:	ff07f913          	andi	s2,a5,-16
    if(sp < stackbase)
    8000581c:	13796563          	bltu	s2,s7,80005946 <kexec+0x354>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80005820:	e0043d83          	ld	s11,-512(s0)
    80005824:	000db983          	ld	s3,0(s11)
    80005828:	854e                	mv	a0,s3
    8000582a:	e8afb0ef          	jal	80000eb4 <strlen>
    8000582e:	0015069b          	addiw	a3,a0,1
    80005832:	864e                	mv	a2,s3
    80005834:	85ca                	mv	a1,s2
    80005836:	855a                	mv	a0,s6
    80005838:	e57fb0ef          	jal	8000168e <copyout>
    8000583c:	10054763          	bltz	a0,8000594a <kexec+0x358>
    ustack[argc] = sp;
    80005840:	00349793          	slli	a5,s1,0x3
    80005844:	97e6                	add	a5,a5,s9
    80005846:	0127b023          	sd	s2,0(a5) # fffffffffffff000 <end+0xffffffff7ff6eba0>
  for(argc = 0; argv[argc]; argc++) {
    8000584a:	0485                	addi	s1,s1,1
    8000584c:	008d8793          	addi	a5,s11,8
    80005850:	e0f43023          	sd	a5,-512(s0)
    80005854:	008db503          	ld	a0,8(s11)
    80005858:	c509                	beqz	a0,80005862 <kexec+0x270>
    if(argc >= MAXARG)
    8000585a:	fb8499e3          	bne	s1,s8,8000580c <kexec+0x21a>
  sz = sz1;
    8000585e:	89d2                	mv	s3,s4
    80005860:	b7a5                	j	800057c8 <kexec+0x1d6>
  ustack[argc] = 0;
    80005862:	00349793          	slli	a5,s1,0x3
    80005866:	f9078793          	addi	a5,a5,-112
    8000586a:	97a2                	add	a5,a5,s0
    8000586c:	f007b023          	sd	zero,-256(a5)
  sp -= (argc+1) * sizeof(uint64);
    80005870:	00349693          	slli	a3,s1,0x3
    80005874:	06a1                	addi	a3,a3,8
    80005876:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    8000587a:	ff097913          	andi	s2,s2,-16
  sz = sz1;
    8000587e:	89d2                	mv	s3,s4
  if(sp < stackbase)
    80005880:	f57964e3          	bltu	s2,s7,800057c8 <kexec+0x1d6>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    80005884:	e9040613          	addi	a2,s0,-368
    80005888:	85ca                	mv	a1,s2
    8000588a:	855a                	mv	a0,s6
    8000588c:	e03fb0ef          	jal	8000168e <copyout>
    80005890:	f2054ce3          	bltz	a0,800057c8 <kexec+0x1d6>
  p->trapframe->a1 = sp;
    80005894:	058ab783          	ld	a5,88(s5) # 1058 <_entry-0x7fffefa8>
    80005898:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    8000589c:	df043783          	ld	a5,-528(s0)
    800058a0:	0007c703          	lbu	a4,0(a5)
    800058a4:	cf11                	beqz	a4,800058c0 <kexec+0x2ce>
    800058a6:	0785                	addi	a5,a5,1
    if(*s == '/')
    800058a8:	02f00693          	li	a3,47
    800058ac:	a029                	j	800058b6 <kexec+0x2c4>
  for(last=s=path; *s; s++)
    800058ae:	0785                	addi	a5,a5,1
    800058b0:	fff7c703          	lbu	a4,-1(a5)
    800058b4:	c711                	beqz	a4,800058c0 <kexec+0x2ce>
    if(*s == '/')
    800058b6:	fed71ce3          	bne	a4,a3,800058ae <kexec+0x2bc>
      last = s+1;
    800058ba:	def43823          	sd	a5,-528(s0)
    800058be:	bfc5                	j	800058ae <kexec+0x2bc>
  safestrcpy(p->name, last, sizeof(p->name));
    800058c0:	4641                	li	a2,16
    800058c2:	df043583          	ld	a1,-528(s0)
    800058c6:	158a8513          	addi	a0,s5,344
    800058ca:	db4fb0ef          	jal	80000e7e <safestrcpy>
  oldpagetable = p->pagetable;
    800058ce:	050ab503          	ld	a0,80(s5)
  p->pagetable = pagetable;
    800058d2:	056ab823          	sd	s6,80(s5)
  p->sz = sz;
    800058d6:	054ab423          	sd	s4,72(s5)
  p->trapframe->epc = elf.entry;  // initial program counter = ulib.c:start()
    800058da:	058ab783          	ld	a5,88(s5)
    800058de:	e6843703          	ld	a4,-408(s0)
    800058e2:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    800058e4:	058ab783          	ld	a5,88(s5)
    800058e8:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    800058ec:	85ea                	mv	a1,s10
    800058ee:	a08fc0ef          	jal	80001af6 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    800058f2:	0004851b          	sext.w	a0,s1
    800058f6:	79fe                	ld	s3,504(sp)
    800058f8:	7a5e                	ld	s4,496(sp)
    800058fa:	7abe                	ld	s5,488(sp)
    800058fc:	7b1e                	ld	s6,480(sp)
    800058fe:	6bfe                	ld	s7,472(sp)
    80005900:	6c5e                	ld	s8,464(sp)
    80005902:	6cbe                	ld	s9,456(sp)
    80005904:	6d1e                	ld	s10,448(sp)
    80005906:	7dfa                	ld	s11,440(sp)
    80005908:	bbb1                	j	80005664 <kexec+0x72>
    8000590a:	7b1e                	ld	s6,480(sp)
    8000590c:	b3a9                	j	80005656 <kexec+0x64>
    8000590e:	df243c23          	sd	s2,-520(s0)
    proc_freepagetable(pagetable, sz);
    80005912:	df843583          	ld	a1,-520(s0)
    80005916:	855a                	mv	a0,s6
    80005918:	9defc0ef          	jal	80001af6 <proc_freepagetable>
  if(ip){
    8000591c:	79fe                	ld	s3,504(sp)
    8000591e:	7abe                	ld	s5,488(sp)
    80005920:	7b1e                	ld	s6,480(sp)
    80005922:	6bfe                	ld	s7,472(sp)
    80005924:	6c5e                	ld	s8,464(sp)
    80005926:	6cbe                	ld	s9,456(sp)
    80005928:	6d1e                	ld	s10,448(sp)
    8000592a:	7dfa                	ld	s11,440(sp)
    8000592c:	b32d                	j	80005656 <kexec+0x64>
    8000592e:	df243c23          	sd	s2,-520(s0)
    80005932:	b7c5                	j	80005912 <kexec+0x320>
    80005934:	df243c23          	sd	s2,-520(s0)
    80005938:	bfe9                	j	80005912 <kexec+0x320>
    8000593a:	df243c23          	sd	s2,-520(s0)
    8000593e:	bfd1                	j	80005912 <kexec+0x320>
    80005940:	df243c23          	sd	s2,-520(s0)
    80005944:	b7f9                	j	80005912 <kexec+0x320>
  sz = sz1;
    80005946:	89d2                	mv	s3,s4
    80005948:	b541                	j	800057c8 <kexec+0x1d6>
    8000594a:	89d2                	mv	s3,s4
    8000594c:	bdb5                	j	800057c8 <kexec+0x1d6>

000000008000594e <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    8000594e:	7179                	addi	sp,sp,-48
    80005950:	f406                	sd	ra,40(sp)
    80005952:	f022                	sd	s0,32(sp)
    80005954:	ec26                	sd	s1,24(sp)
    80005956:	e84a                	sd	s2,16(sp)
    80005958:	1800                	addi	s0,sp,48
    8000595a:	892e                	mv	s2,a1
    8000595c:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    8000595e:	fdc40593          	addi	a1,s0,-36
    80005962:	f29fc0ef          	jal	8000288a <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    80005966:	fdc42703          	lw	a4,-36(s0)
    8000596a:	47bd                	li	a5,15
    8000596c:	02e7ea63          	bltu	a5,a4,800059a0 <argfd+0x52>
    80005970:	ff9fb0ef          	jal	80001968 <myproc>
    80005974:	fdc42703          	lw	a4,-36(s0)
    80005978:	00371793          	slli	a5,a4,0x3
    8000597c:	0d078793          	addi	a5,a5,208
    80005980:	953e                	add	a0,a0,a5
    80005982:	611c                	ld	a5,0(a0)
    80005984:	c385                	beqz	a5,800059a4 <argfd+0x56>
    return -1;
  if(pfd)
    80005986:	00090463          	beqz	s2,8000598e <argfd+0x40>
    *pfd = fd;
    8000598a:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    8000598e:	4501                	li	a0,0
  if(pf)
    80005990:	c091                	beqz	s1,80005994 <argfd+0x46>
    *pf = f;
    80005992:	e09c                	sd	a5,0(s1)
}
    80005994:	70a2                	ld	ra,40(sp)
    80005996:	7402                	ld	s0,32(sp)
    80005998:	64e2                	ld	s1,24(sp)
    8000599a:	6942                	ld	s2,16(sp)
    8000599c:	6145                	addi	sp,sp,48
    8000599e:	8082                	ret
    return -1;
    800059a0:	557d                	li	a0,-1
    800059a2:	bfcd                	j	80005994 <argfd+0x46>
    800059a4:	557d                	li	a0,-1
    800059a6:	b7fd                	j	80005994 <argfd+0x46>

00000000800059a8 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    800059a8:	1101                	addi	sp,sp,-32
    800059aa:	ec06                	sd	ra,24(sp)
    800059ac:	e822                	sd	s0,16(sp)
    800059ae:	e426                	sd	s1,8(sp)
    800059b0:	1000                	addi	s0,sp,32
    800059b2:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    800059b4:	fb5fb0ef          	jal	80001968 <myproc>
    800059b8:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    800059ba:	0d050793          	addi	a5,a0,208
    800059be:	4501                	li	a0,0
    800059c0:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    800059c2:	6398                	ld	a4,0(a5)
    800059c4:	cb19                	beqz	a4,800059da <fdalloc+0x32>
  for(fd = 0; fd < NOFILE; fd++){
    800059c6:	2505                	addiw	a0,a0,1
    800059c8:	07a1                	addi	a5,a5,8
    800059ca:	fed51ce3          	bne	a0,a3,800059c2 <fdalloc+0x1a>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    800059ce:	557d                	li	a0,-1
}
    800059d0:	60e2                	ld	ra,24(sp)
    800059d2:	6442                	ld	s0,16(sp)
    800059d4:	64a2                	ld	s1,8(sp)
    800059d6:	6105                	addi	sp,sp,32
    800059d8:	8082                	ret
      p->ofile[fd] = f;
    800059da:	00351793          	slli	a5,a0,0x3
    800059de:	0d078793          	addi	a5,a5,208
    800059e2:	963e                	add	a2,a2,a5
    800059e4:	e204                	sd	s1,0(a2)
      return fd;
    800059e6:	b7ed                	j	800059d0 <fdalloc+0x28>

00000000800059e8 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    800059e8:	715d                	addi	sp,sp,-80
    800059ea:	e486                	sd	ra,72(sp)
    800059ec:	e0a2                	sd	s0,64(sp)
    800059ee:	fc26                	sd	s1,56(sp)
    800059f0:	f84a                	sd	s2,48(sp)
    800059f2:	f44e                	sd	s3,40(sp)
    800059f4:	f052                	sd	s4,32(sp)
    800059f6:	ec56                	sd	s5,24(sp)
    800059f8:	e85a                	sd	s6,16(sp)
    800059fa:	0880                	addi	s0,sp,80
    800059fc:	892e                	mv	s2,a1
    800059fe:	8a2e                	mv	s4,a1
    80005a00:	8ab2                	mv	s5,a2
    80005a02:	8b36                	mv	s6,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    80005a04:	fb040593          	addi	a1,s0,-80
    80005a08:	9ddfe0ef          	jal	800043e4 <nameiparent>
    80005a0c:	84aa                	mv	s1,a0
    80005a0e:	10050763          	beqz	a0,80005b1c <create+0x134>
    return 0;

  ilock(dp);
    80005a12:	f2bfd0ef          	jal	8000393c <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    80005a16:	4601                	li	a2,0
    80005a18:	fb040593          	addi	a1,s0,-80
    80005a1c:	8526                	mv	a0,s1
    80005a1e:	df4fe0ef          	jal	80004012 <dirlookup>
    80005a22:	89aa                	mv	s3,a0
    80005a24:	c131                	beqz	a0,80005a68 <create+0x80>
    iunlockput(dp);
    80005a26:	8526                	mv	a0,s1
    80005a28:	9f2fe0ef          	jal	80003c1a <iunlockput>
    ilock(ip);
    80005a2c:	854e                	mv	a0,s3
    80005a2e:	f0ffd0ef          	jal	8000393c <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80005a32:	4789                	li	a5,2
    80005a34:	02f91563          	bne	s2,a5,80005a5e <create+0x76>
    80005a38:	0449d783          	lhu	a5,68(s3)
    80005a3c:	37f9                	addiw	a5,a5,-2
    80005a3e:	17c2                	slli	a5,a5,0x30
    80005a40:	93c1                	srli	a5,a5,0x30
    80005a42:	4705                	li	a4,1
    80005a44:	00f76d63          	bltu	a4,a5,80005a5e <create+0x76>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    80005a48:	854e                	mv	a0,s3
    80005a4a:	60a6                	ld	ra,72(sp)
    80005a4c:	6406                	ld	s0,64(sp)
    80005a4e:	74e2                	ld	s1,56(sp)
    80005a50:	7942                	ld	s2,48(sp)
    80005a52:	79a2                	ld	s3,40(sp)
    80005a54:	7a02                	ld	s4,32(sp)
    80005a56:	6ae2                	ld	s5,24(sp)
    80005a58:	6b42                	ld	s6,16(sp)
    80005a5a:	6161                	addi	sp,sp,80
    80005a5c:	8082                	ret
    iunlockput(ip);
    80005a5e:	854e                	mv	a0,s3
    80005a60:	9bafe0ef          	jal	80003c1a <iunlockput>
    return 0;
    80005a64:	4981                	li	s3,0
    80005a66:	b7cd                	j	80005a48 <create+0x60>
  if((ip = ialloc(dp->dev, type)) == 0){
    80005a68:	85ca                	mv	a1,s2
    80005a6a:	4088                	lw	a0,0(s1)
    80005a6c:	cfbfd0ef          	jal	80003766 <ialloc>
    80005a70:	892a                	mv	s2,a0
    80005a72:	cd15                	beqz	a0,80005aae <create+0xc6>
  ilock(ip);
    80005a74:	ec9fd0ef          	jal	8000393c <ilock>
  ip->major = major;
    80005a78:	05591323          	sh	s5,70(s2)
  ip->minor = minor;
    80005a7c:	05691423          	sh	s6,72(s2)
  ip->nlink = 1;
    80005a80:	4785                	li	a5,1
    80005a82:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80005a86:	854a                	mv	a0,s2
    80005a88:	dbdfd0ef          	jal	80003844 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    80005a8c:	4705                	li	a4,1
    80005a8e:	02ea0463          	beq	s4,a4,80005ab6 <create+0xce>
  if(dirlink(dp, name, ip->inum) < 0)
    80005a92:	00492603          	lw	a2,4(s2)
    80005a96:	fb040593          	addi	a1,s0,-80
    80005a9a:	8526                	mv	a0,s1
    80005a9c:	829fe0ef          	jal	800042c4 <dirlink>
    80005aa0:	06054263          	bltz	a0,80005b04 <create+0x11c>
  iunlockput(dp);
    80005aa4:	8526                	mv	a0,s1
    80005aa6:	974fe0ef          	jal	80003c1a <iunlockput>
  return ip;
    80005aaa:	89ca                	mv	s3,s2
    80005aac:	bf71                	j	80005a48 <create+0x60>
    iunlockput(dp);
    80005aae:	8526                	mv	a0,s1
    80005ab0:	96afe0ef          	jal	80003c1a <iunlockput>
    return 0;
    80005ab4:	bf51                	j	80005a48 <create+0x60>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    80005ab6:	00492603          	lw	a2,4(s2)
    80005aba:	00004597          	auipc	a1,0x4
    80005abe:	21658593          	addi	a1,a1,534 # 80009cd0 <etext+0xcd0>
    80005ac2:	854a                	mv	a0,s2
    80005ac4:	801fe0ef          	jal	800042c4 <dirlink>
    80005ac8:	02054e63          	bltz	a0,80005b04 <create+0x11c>
    80005acc:	40d0                	lw	a2,4(s1)
    80005ace:	00004597          	auipc	a1,0x4
    80005ad2:	20a58593          	addi	a1,a1,522 # 80009cd8 <etext+0xcd8>
    80005ad6:	854a                	mv	a0,s2
    80005ad8:	fecfe0ef          	jal	800042c4 <dirlink>
    80005adc:	02054463          	bltz	a0,80005b04 <create+0x11c>
  if(dirlink(dp, name, ip->inum) < 0)
    80005ae0:	00492603          	lw	a2,4(s2)
    80005ae4:	fb040593          	addi	a1,s0,-80
    80005ae8:	8526                	mv	a0,s1
    80005aea:	fdafe0ef          	jal	800042c4 <dirlink>
    80005aee:	00054b63          	bltz	a0,80005b04 <create+0x11c>
    dp->nlink++;  // for ".."
    80005af2:	04a4d783          	lhu	a5,74(s1)
    80005af6:	2785                	addiw	a5,a5,1
    80005af8:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80005afc:	8526                	mv	a0,s1
    80005afe:	d47fd0ef          	jal	80003844 <iupdate>
    80005b02:	b74d                	j	80005aa4 <create+0xbc>
  ip->nlink = 0;
    80005b04:	04091523          	sh	zero,74(s2)
  iupdate(ip);
    80005b08:	854a                	mv	a0,s2
    80005b0a:	d3bfd0ef          	jal	80003844 <iupdate>
  iunlockput(ip);
    80005b0e:	854a                	mv	a0,s2
    80005b10:	90afe0ef          	jal	80003c1a <iunlockput>
  iunlockput(dp);
    80005b14:	8526                	mv	a0,s1
    80005b16:	904fe0ef          	jal	80003c1a <iunlockput>
  return 0;
    80005b1a:	b73d                	j	80005a48 <create+0x60>
    return 0;
    80005b1c:	89aa                	mv	s3,a0
    80005b1e:	b72d                	j	80005a48 <create+0x60>

0000000080005b20 <sys_dup>:
{
    80005b20:	7179                	addi	sp,sp,-48
    80005b22:	f406                	sd	ra,40(sp)
    80005b24:	f022                	sd	s0,32(sp)
    80005b26:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    80005b28:	fd840613          	addi	a2,s0,-40
    80005b2c:	4581                	li	a1,0
    80005b2e:	4501                	li	a0,0
    80005b30:	e1fff0ef          	jal	8000594e <argfd>
    return -1;
    80005b34:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    80005b36:	02054363          	bltz	a0,80005b5c <sys_dup+0x3c>
    80005b3a:	ec26                	sd	s1,24(sp)
    80005b3c:	e84a                	sd	s2,16(sp)
  if((fd=fdalloc(f)) < 0)
    80005b3e:	fd843483          	ld	s1,-40(s0)
    80005b42:	8526                	mv	a0,s1
    80005b44:	e65ff0ef          	jal	800059a8 <fdalloc>
    80005b48:	892a                	mv	s2,a0
    return -1;
    80005b4a:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    80005b4c:	00054d63          	bltz	a0,80005b66 <sys_dup+0x46>
  filedup(f);
    80005b50:	8526                	mv	a0,s1
    80005b52:	b8eff0ef          	jal	80004ee0 <filedup>
  return fd;
    80005b56:	87ca                	mv	a5,s2
    80005b58:	64e2                	ld	s1,24(sp)
    80005b5a:	6942                	ld	s2,16(sp)
}
    80005b5c:	853e                	mv	a0,a5
    80005b5e:	70a2                	ld	ra,40(sp)
    80005b60:	7402                	ld	s0,32(sp)
    80005b62:	6145                	addi	sp,sp,48
    80005b64:	8082                	ret
    80005b66:	64e2                	ld	s1,24(sp)
    80005b68:	6942                	ld	s2,16(sp)
    80005b6a:	bfcd                	j	80005b5c <sys_dup+0x3c>

0000000080005b6c <sys_read>:
{
    80005b6c:	7179                	addi	sp,sp,-48
    80005b6e:	f406                	sd	ra,40(sp)
    80005b70:	f022                	sd	s0,32(sp)
    80005b72:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80005b74:	fd840593          	addi	a1,s0,-40
    80005b78:	4505                	li	a0,1
    80005b7a:	d2dfc0ef          	jal	800028a6 <argaddr>
  argint(2, &n);
    80005b7e:	fe440593          	addi	a1,s0,-28
    80005b82:	4509                	li	a0,2
    80005b84:	d07fc0ef          	jal	8000288a <argint>
  if(argfd(0, 0, &f) < 0)
    80005b88:	fe840613          	addi	a2,s0,-24
    80005b8c:	4581                	li	a1,0
    80005b8e:	4501                	li	a0,0
    80005b90:	dbfff0ef          	jal	8000594e <argfd>
    80005b94:	87aa                	mv	a5,a0
    return -1;
    80005b96:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80005b98:	0007ca63          	bltz	a5,80005bac <sys_read+0x40>
  return fileread(f, p, n);
    80005b9c:	fe442603          	lw	a2,-28(s0)
    80005ba0:	fd843583          	ld	a1,-40(s0)
    80005ba4:	fe843503          	ld	a0,-24(s0)
    80005ba8:	cd6ff0ef          	jal	8000507e <fileread>
}
    80005bac:	70a2                	ld	ra,40(sp)
    80005bae:	7402                	ld	s0,32(sp)
    80005bb0:	6145                	addi	sp,sp,48
    80005bb2:	8082                	ret

0000000080005bb4 <sys_write>:
{
    80005bb4:	7179                	addi	sp,sp,-48
    80005bb6:	f406                	sd	ra,40(sp)
    80005bb8:	f022                	sd	s0,32(sp)
    80005bba:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80005bbc:	fd840593          	addi	a1,s0,-40
    80005bc0:	4505                	li	a0,1
    80005bc2:	ce5fc0ef          	jal	800028a6 <argaddr>
  argint(2, &n);
    80005bc6:	fe440593          	addi	a1,s0,-28
    80005bca:	4509                	li	a0,2
    80005bcc:	cbffc0ef          	jal	8000288a <argint>
  if(argfd(0, 0, &f) < 0)
    80005bd0:	fe840613          	addi	a2,s0,-24
    80005bd4:	4581                	li	a1,0
    80005bd6:	4501                	li	a0,0
    80005bd8:	d77ff0ef          	jal	8000594e <argfd>
    80005bdc:	87aa                	mv	a5,a0
    return -1;
    80005bde:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80005be0:	0007ca63          	bltz	a5,80005bf4 <sys_write+0x40>
  return filewrite(f, p, n);
    80005be4:	fe442603          	lw	a2,-28(s0)
    80005be8:	fd843583          	ld	a1,-40(s0)
    80005bec:	fe843503          	ld	a0,-24(s0)
    80005bf0:	d74ff0ef          	jal	80005164 <filewrite>
}
    80005bf4:	70a2                	ld	ra,40(sp)
    80005bf6:	7402                	ld	s0,32(sp)
    80005bf8:	6145                	addi	sp,sp,48
    80005bfa:	8082                	ret

0000000080005bfc <sys_close>:
{
    80005bfc:	1101                	addi	sp,sp,-32
    80005bfe:	ec06                	sd	ra,24(sp)
    80005c00:	e822                	sd	s0,16(sp)
    80005c02:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    80005c04:	fe040613          	addi	a2,s0,-32
    80005c08:	fec40593          	addi	a1,s0,-20
    80005c0c:	4501                	li	a0,0
    80005c0e:	d41ff0ef          	jal	8000594e <argfd>
    return -1;
    80005c12:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    80005c14:	02054163          	bltz	a0,80005c36 <sys_close+0x3a>
  myproc()->ofile[fd] = 0;
    80005c18:	d51fb0ef          	jal	80001968 <myproc>
    80005c1c:	fec42783          	lw	a5,-20(s0)
    80005c20:	078e                	slli	a5,a5,0x3
    80005c22:	0d078793          	addi	a5,a5,208
    80005c26:	953e                	add	a0,a0,a5
    80005c28:	00053023          	sd	zero,0(a0)
  fileclose(f);
    80005c2c:	fe043503          	ld	a0,-32(s0)
    80005c30:	b10ff0ef          	jal	80004f40 <fileclose>
  return 0;
    80005c34:	4781                	li	a5,0
}
    80005c36:	853e                	mv	a0,a5
    80005c38:	60e2                	ld	ra,24(sp)
    80005c3a:	6442                	ld	s0,16(sp)
    80005c3c:	6105                	addi	sp,sp,32
    80005c3e:	8082                	ret

0000000080005c40 <sys_fstat>:
{
    80005c40:	1101                	addi	sp,sp,-32
    80005c42:	ec06                	sd	ra,24(sp)
    80005c44:	e822                	sd	s0,16(sp)
    80005c46:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    80005c48:	fe040593          	addi	a1,s0,-32
    80005c4c:	4505                	li	a0,1
    80005c4e:	c59fc0ef          	jal	800028a6 <argaddr>
  if(argfd(0, 0, &f) < 0)
    80005c52:	fe840613          	addi	a2,s0,-24
    80005c56:	4581                	li	a1,0
    80005c58:	4501                	li	a0,0
    80005c5a:	cf5ff0ef          	jal	8000594e <argfd>
    80005c5e:	87aa                	mv	a5,a0
    return -1;
    80005c60:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80005c62:	0007c863          	bltz	a5,80005c72 <sys_fstat+0x32>
  return filestat(f, st);
    80005c66:	fe043583          	ld	a1,-32(s0)
    80005c6a:	fe843503          	ld	a0,-24(s0)
    80005c6e:	baeff0ef          	jal	8000501c <filestat>
}
    80005c72:	60e2                	ld	ra,24(sp)
    80005c74:	6442                	ld	s0,16(sp)
    80005c76:	6105                	addi	sp,sp,32
    80005c78:	8082                	ret

0000000080005c7a <sys_link>:
{
    80005c7a:	7169                	addi	sp,sp,-304
    80005c7c:	f606                	sd	ra,296(sp)
    80005c7e:	f222                	sd	s0,288(sp)
    80005c80:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005c82:	08000613          	li	a2,128
    80005c86:	ed040593          	addi	a1,s0,-304
    80005c8a:	4501                	li	a0,0
    80005c8c:	c37fc0ef          	jal	800028c2 <argstr>
    return -1;
    80005c90:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005c92:	0c054e63          	bltz	a0,80005d6e <sys_link+0xf4>
    80005c96:	08000613          	li	a2,128
    80005c9a:	f5040593          	addi	a1,s0,-176
    80005c9e:	4505                	li	a0,1
    80005ca0:	c23fc0ef          	jal	800028c2 <argstr>
    return -1;
    80005ca4:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005ca6:	0c054463          	bltz	a0,80005d6e <sys_link+0xf4>
    80005caa:	ee26                	sd	s1,280(sp)
  begin_op();
    80005cac:	b6dfe0ef          	jal	80004818 <begin_op>
  if((ip = namei(old)) == 0){
    80005cb0:	ed040513          	addi	a0,s0,-304
    80005cb4:	f16fe0ef          	jal	800043ca <namei>
    80005cb8:	84aa                	mv	s1,a0
    80005cba:	c53d                	beqz	a0,80005d28 <sys_link+0xae>
  ilock(ip);
    80005cbc:	c81fd0ef          	jal	8000393c <ilock>
  if(ip->type == T_DIR){
    80005cc0:	04449703          	lh	a4,68(s1)
    80005cc4:	4785                	li	a5,1
    80005cc6:	06f70663          	beq	a4,a5,80005d32 <sys_link+0xb8>
    80005cca:	ea4a                	sd	s2,272(sp)
  ip->nlink++;
    80005ccc:	04a4d783          	lhu	a5,74(s1)
    80005cd0:	2785                	addiw	a5,a5,1
    80005cd2:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005cd6:	8526                	mv	a0,s1
    80005cd8:	b6dfd0ef          	jal	80003844 <iupdate>
  iunlock(ip);
    80005cdc:	8526                	mv	a0,s1
    80005cde:	d51fd0ef          	jal	80003a2e <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    80005ce2:	fd040593          	addi	a1,s0,-48
    80005ce6:	f5040513          	addi	a0,s0,-176
    80005cea:	efafe0ef          	jal	800043e4 <nameiparent>
    80005cee:	892a                	mv	s2,a0
    80005cf0:	cd21                	beqz	a0,80005d48 <sys_link+0xce>
  ilock(dp);
    80005cf2:	c4bfd0ef          	jal	8000393c <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    80005cf6:	854a                	mv	a0,s2
    80005cf8:	00092703          	lw	a4,0(s2)
    80005cfc:	409c                	lw	a5,0(s1)
    80005cfe:	04f71263          	bne	a4,a5,80005d42 <sys_link+0xc8>
    80005d02:	40d0                	lw	a2,4(s1)
    80005d04:	fd040593          	addi	a1,s0,-48
    80005d08:	dbcfe0ef          	jal	800042c4 <dirlink>
    80005d0c:	02054b63          	bltz	a0,80005d42 <sys_link+0xc8>
  iunlockput(dp);
    80005d10:	854a                	mv	a0,s2
    80005d12:	f09fd0ef          	jal	80003c1a <iunlockput>
  iput(ip);
    80005d16:	8526                	mv	a0,s1
    80005d18:	e35fd0ef          	jal	80003b4c <iput>
  end_op();
    80005d1c:	c1dfe0ef          	jal	80004938 <end_op>
  return 0;
    80005d20:	4781                	li	a5,0
    80005d22:	64f2                	ld	s1,280(sp)
    80005d24:	6952                	ld	s2,272(sp)
    80005d26:	a0a1                	j	80005d6e <sys_link+0xf4>
    end_op();
    80005d28:	c11fe0ef          	jal	80004938 <end_op>
    return -1;
    80005d2c:	57fd                	li	a5,-1
    80005d2e:	64f2                	ld	s1,280(sp)
    80005d30:	a83d                	j	80005d6e <sys_link+0xf4>
    iunlockput(ip);
    80005d32:	8526                	mv	a0,s1
    80005d34:	ee7fd0ef          	jal	80003c1a <iunlockput>
    end_op();
    80005d38:	c01fe0ef          	jal	80004938 <end_op>
    return -1;
    80005d3c:	57fd                	li	a5,-1
    80005d3e:	64f2                	ld	s1,280(sp)
    80005d40:	a03d                	j	80005d6e <sys_link+0xf4>
    iunlockput(dp);
    80005d42:	854a                	mv	a0,s2
    80005d44:	ed7fd0ef          	jal	80003c1a <iunlockput>
  ilock(ip);
    80005d48:	8526                	mv	a0,s1
    80005d4a:	bf3fd0ef          	jal	8000393c <ilock>
  ip->nlink--;
    80005d4e:	04a4d783          	lhu	a5,74(s1)
    80005d52:	37fd                	addiw	a5,a5,-1
    80005d54:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005d58:	8526                	mv	a0,s1
    80005d5a:	aebfd0ef          	jal	80003844 <iupdate>
  iunlockput(ip);
    80005d5e:	8526                	mv	a0,s1
    80005d60:	ebbfd0ef          	jal	80003c1a <iunlockput>
  end_op();
    80005d64:	bd5fe0ef          	jal	80004938 <end_op>
  return -1;
    80005d68:	57fd                	li	a5,-1
    80005d6a:	64f2                	ld	s1,280(sp)
    80005d6c:	6952                	ld	s2,272(sp)
}
    80005d6e:	853e                	mv	a0,a5
    80005d70:	70b2                	ld	ra,296(sp)
    80005d72:	7412                	ld	s0,288(sp)
    80005d74:	6155                	addi	sp,sp,304
    80005d76:	8082                	ret

0000000080005d78 <sys_unlink>:
{
    80005d78:	7151                	addi	sp,sp,-240
    80005d7a:	f586                	sd	ra,232(sp)
    80005d7c:	f1a2                	sd	s0,224(sp)
    80005d7e:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    80005d80:	08000613          	li	a2,128
    80005d84:	f3040593          	addi	a1,s0,-208
    80005d88:	4501                	li	a0,0
    80005d8a:	b39fc0ef          	jal	800028c2 <argstr>
    80005d8e:	14054d63          	bltz	a0,80005ee8 <sys_unlink+0x170>
    80005d92:	eda6                	sd	s1,216(sp)
  begin_op();
    80005d94:	a85fe0ef          	jal	80004818 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    80005d98:	fb040593          	addi	a1,s0,-80
    80005d9c:	f3040513          	addi	a0,s0,-208
    80005da0:	e44fe0ef          	jal	800043e4 <nameiparent>
    80005da4:	84aa                	mv	s1,a0
    80005da6:	c955                	beqz	a0,80005e5a <sys_unlink+0xe2>
  ilock(dp);
    80005da8:	b95fd0ef          	jal	8000393c <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80005dac:	00004597          	auipc	a1,0x4
    80005db0:	f2458593          	addi	a1,a1,-220 # 80009cd0 <etext+0xcd0>
    80005db4:	fb040513          	addi	a0,s0,-80
    80005db8:	a44fe0ef          	jal	80003ffc <namecmp>
    80005dbc:	10050b63          	beqz	a0,80005ed2 <sys_unlink+0x15a>
    80005dc0:	00004597          	auipc	a1,0x4
    80005dc4:	f1858593          	addi	a1,a1,-232 # 80009cd8 <etext+0xcd8>
    80005dc8:	fb040513          	addi	a0,s0,-80
    80005dcc:	a30fe0ef          	jal	80003ffc <namecmp>
    80005dd0:	10050163          	beqz	a0,80005ed2 <sys_unlink+0x15a>
    80005dd4:	e9ca                	sd	s2,208(sp)
  if((ip = dirlookup(dp, name, &off)) == 0)
    80005dd6:	f2c40613          	addi	a2,s0,-212
    80005dda:	fb040593          	addi	a1,s0,-80
    80005dde:	8526                	mv	a0,s1
    80005de0:	a32fe0ef          	jal	80004012 <dirlookup>
    80005de4:	892a                	mv	s2,a0
    80005de6:	0e050563          	beqz	a0,80005ed0 <sys_unlink+0x158>
    80005dea:	e5ce                	sd	s3,200(sp)
  ilock(ip);
    80005dec:	b51fd0ef          	jal	8000393c <ilock>
  if(ip->nlink < 1)
    80005df0:	04a91783          	lh	a5,74(s2)
    80005df4:	06f05863          	blez	a5,80005e64 <sys_unlink+0xec>
  if(ip->type == T_DIR && !isdirempty(ip)){
    80005df8:	04491703          	lh	a4,68(s2)
    80005dfc:	4785                	li	a5,1
    80005dfe:	06f70963          	beq	a4,a5,80005e70 <sys_unlink+0xf8>
  memset(&de, 0, sizeof(de));
    80005e02:	fc040993          	addi	s3,s0,-64
    80005e06:	4641                	li	a2,16
    80005e08:	4581                	li	a1,0
    80005e0a:	854e                	mv	a0,s3
    80005e0c:	f1ffa0ef          	jal	80000d2a <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005e10:	4741                	li	a4,16
    80005e12:	f2c42683          	lw	a3,-212(s0)
    80005e16:	864e                	mv	a2,s3
    80005e18:	4581                	li	a1,0
    80005e1a:	8526                	mv	a0,s1
    80005e1c:	8aafe0ef          	jal	80003ec6 <writei>
    80005e20:	47c1                	li	a5,16
    80005e22:	08f51863          	bne	a0,a5,80005eb2 <sys_unlink+0x13a>
  if(ip->type == T_DIR){
    80005e26:	04491703          	lh	a4,68(s2)
    80005e2a:	4785                	li	a5,1
    80005e2c:	08f70963          	beq	a4,a5,80005ebe <sys_unlink+0x146>
  iunlockput(dp);
    80005e30:	8526                	mv	a0,s1
    80005e32:	de9fd0ef          	jal	80003c1a <iunlockput>
  ip->nlink--;
    80005e36:	04a95783          	lhu	a5,74(s2)
    80005e3a:	37fd                	addiw	a5,a5,-1
    80005e3c:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80005e40:	854a                	mv	a0,s2
    80005e42:	a03fd0ef          	jal	80003844 <iupdate>
  iunlockput(ip);
    80005e46:	854a                	mv	a0,s2
    80005e48:	dd3fd0ef          	jal	80003c1a <iunlockput>
  end_op();
    80005e4c:	aedfe0ef          	jal	80004938 <end_op>
  return 0;
    80005e50:	4501                	li	a0,0
    80005e52:	64ee                	ld	s1,216(sp)
    80005e54:	694e                	ld	s2,208(sp)
    80005e56:	69ae                	ld	s3,200(sp)
    80005e58:	a061                	j	80005ee0 <sys_unlink+0x168>
    end_op();
    80005e5a:	adffe0ef          	jal	80004938 <end_op>
    return -1;
    80005e5e:	557d                	li	a0,-1
    80005e60:	64ee                	ld	s1,216(sp)
    80005e62:	a8bd                	j	80005ee0 <sys_unlink+0x168>
    panic("unlink: nlink < 1");
    80005e64:	00004517          	auipc	a0,0x4
    80005e68:	e7c50513          	addi	a0,a0,-388 # 80009ce0 <etext+0xce0>
    80005e6c:	9ebfa0ef          	jal	80000856 <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005e70:	04c92703          	lw	a4,76(s2)
    80005e74:	02000793          	li	a5,32
    80005e78:	f8e7f5e3          	bgeu	a5,a4,80005e02 <sys_unlink+0x8a>
    80005e7c:	89be                	mv	s3,a5
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005e7e:	4741                	li	a4,16
    80005e80:	86ce                	mv	a3,s3
    80005e82:	f1840613          	addi	a2,s0,-232
    80005e86:	4581                	li	a1,0
    80005e88:	854a                	mv	a0,s2
    80005e8a:	f17fd0ef          	jal	80003da0 <readi>
    80005e8e:	47c1                	li	a5,16
    80005e90:	00f51b63          	bne	a0,a5,80005ea6 <sys_unlink+0x12e>
    if(de.inum != 0)
    80005e94:	f1845783          	lhu	a5,-232(s0)
    80005e98:	ebb1                	bnez	a5,80005eec <sys_unlink+0x174>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005e9a:	29c1                	addiw	s3,s3,16
    80005e9c:	04c92783          	lw	a5,76(s2)
    80005ea0:	fcf9efe3          	bltu	s3,a5,80005e7e <sys_unlink+0x106>
    80005ea4:	bfb9                	j	80005e02 <sys_unlink+0x8a>
      panic("isdirempty: readi");
    80005ea6:	00004517          	auipc	a0,0x4
    80005eaa:	e5250513          	addi	a0,a0,-430 # 80009cf8 <etext+0xcf8>
    80005eae:	9a9fa0ef          	jal	80000856 <panic>
    panic("unlink: writei");
    80005eb2:	00004517          	auipc	a0,0x4
    80005eb6:	e5e50513          	addi	a0,a0,-418 # 80009d10 <etext+0xd10>
    80005eba:	99dfa0ef          	jal	80000856 <panic>
    dp->nlink--;
    80005ebe:	04a4d783          	lhu	a5,74(s1)
    80005ec2:	37fd                	addiw	a5,a5,-1
    80005ec4:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80005ec8:	8526                	mv	a0,s1
    80005eca:	97bfd0ef          	jal	80003844 <iupdate>
    80005ece:	b78d                	j	80005e30 <sys_unlink+0xb8>
    80005ed0:	694e                	ld	s2,208(sp)
  iunlockput(dp);
    80005ed2:	8526                	mv	a0,s1
    80005ed4:	d47fd0ef          	jal	80003c1a <iunlockput>
  end_op();
    80005ed8:	a61fe0ef          	jal	80004938 <end_op>
  return -1;
    80005edc:	557d                	li	a0,-1
    80005ede:	64ee                	ld	s1,216(sp)
}
    80005ee0:	70ae                	ld	ra,232(sp)
    80005ee2:	740e                	ld	s0,224(sp)
    80005ee4:	616d                	addi	sp,sp,240
    80005ee6:	8082                	ret
    return -1;
    80005ee8:	557d                	li	a0,-1
    80005eea:	bfdd                	j	80005ee0 <sys_unlink+0x168>
    iunlockput(ip);
    80005eec:	854a                	mv	a0,s2
    80005eee:	d2dfd0ef          	jal	80003c1a <iunlockput>
    goto bad;
    80005ef2:	694e                	ld	s2,208(sp)
    80005ef4:	69ae                	ld	s3,200(sp)
    80005ef6:	bff1                	j	80005ed2 <sys_unlink+0x15a>

0000000080005ef8 <sys_open>:

uint64
sys_open(void)
{
    80005ef8:	7131                	addi	sp,sp,-192
    80005efa:	fd06                	sd	ra,184(sp)
    80005efc:	f922                	sd	s0,176(sp)
    80005efe:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    80005f00:	f4c40593          	addi	a1,s0,-180
    80005f04:	4505                	li	a0,1
    80005f06:	985fc0ef          	jal	8000288a <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    80005f0a:	08000613          	li	a2,128
    80005f0e:	f5040593          	addi	a1,s0,-176
    80005f12:	4501                	li	a0,0
    80005f14:	9affc0ef          	jal	800028c2 <argstr>
    80005f18:	87aa                	mv	a5,a0
    return -1;
    80005f1a:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    80005f1c:	0a07c363          	bltz	a5,80005fc2 <sys_open+0xca>
    80005f20:	f526                	sd	s1,168(sp)

  begin_op();
    80005f22:	8f7fe0ef          	jal	80004818 <begin_op>

  if(omode & O_CREATE){
    80005f26:	f4c42783          	lw	a5,-180(s0)
    80005f2a:	2007f793          	andi	a5,a5,512
    80005f2e:	c3dd                	beqz	a5,80005fd4 <sys_open+0xdc>
    ip = create(path, T_FILE, 0, 0);
    80005f30:	4681                	li	a3,0
    80005f32:	4601                	li	a2,0
    80005f34:	4589                	li	a1,2
    80005f36:	f5040513          	addi	a0,s0,-176
    80005f3a:	aafff0ef          	jal	800059e8 <create>
    80005f3e:	84aa                	mv	s1,a0
    if(ip == 0){
    80005f40:	c549                	beqz	a0,80005fca <sys_open+0xd2>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    80005f42:	04449703          	lh	a4,68(s1)
    80005f46:	478d                	li	a5,3
    80005f48:	00f71763          	bne	a4,a5,80005f56 <sys_open+0x5e>
    80005f4c:	0464d703          	lhu	a4,70(s1)
    80005f50:	47a5                	li	a5,9
    80005f52:	0ae7ee63          	bltu	a5,a4,8000600e <sys_open+0x116>
    80005f56:	f14a                	sd	s2,160(sp)
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    80005f58:	f11fe0ef          	jal	80004e68 <filealloc>
    80005f5c:	892a                	mv	s2,a0
    80005f5e:	c561                	beqz	a0,80006026 <sys_open+0x12e>
    80005f60:	ed4e                	sd	s3,152(sp)
    80005f62:	a47ff0ef          	jal	800059a8 <fdalloc>
    80005f66:	89aa                	mv	s3,a0
    80005f68:	0a054b63          	bltz	a0,8000601e <sys_open+0x126>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    80005f6c:	04449703          	lh	a4,68(s1)
    80005f70:	478d                	li	a5,3
    80005f72:	0cf70363          	beq	a4,a5,80006038 <sys_open+0x140>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80005f76:	4789                	li	a5,2
    80005f78:	00f92023          	sw	a5,0(s2)
    f->off = 0;
    80005f7c:	02092023          	sw	zero,32(s2)
  }
  f->ip = ip;
    80005f80:	00993c23          	sd	s1,24(s2)
  f->readable = !(omode & O_WRONLY);
    80005f84:	f4c42783          	lw	a5,-180(s0)
    80005f88:	0017f713          	andi	a4,a5,1
    80005f8c:	00174713          	xori	a4,a4,1
    80005f90:	00e90423          	sb	a4,8(s2)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80005f94:	0037f713          	andi	a4,a5,3
    80005f98:	00e03733          	snez	a4,a4
    80005f9c:	00e904a3          	sb	a4,9(s2)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    80005fa0:	4007f793          	andi	a5,a5,1024
    80005fa4:	c791                	beqz	a5,80005fb0 <sys_open+0xb8>
    80005fa6:	04449703          	lh	a4,68(s1)
    80005faa:	4789                	li	a5,2
    80005fac:	08f70d63          	beq	a4,a5,80006046 <sys_open+0x14e>
    itrunc(ip);
  }

  iunlock(ip);
    80005fb0:	8526                	mv	a0,s1
    80005fb2:	a7dfd0ef          	jal	80003a2e <iunlock>
  end_op();
    80005fb6:	983fe0ef          	jal	80004938 <end_op>

  return fd;
    80005fba:	854e                	mv	a0,s3
    80005fbc:	74aa                	ld	s1,168(sp)
    80005fbe:	790a                	ld	s2,160(sp)
    80005fc0:	69ea                	ld	s3,152(sp)
}
    80005fc2:	70ea                	ld	ra,184(sp)
    80005fc4:	744a                	ld	s0,176(sp)
    80005fc6:	6129                	addi	sp,sp,192
    80005fc8:	8082                	ret
      end_op();
    80005fca:	96ffe0ef          	jal	80004938 <end_op>
      return -1;
    80005fce:	557d                	li	a0,-1
    80005fd0:	74aa                	ld	s1,168(sp)
    80005fd2:	bfc5                	j	80005fc2 <sys_open+0xca>
    if((ip = namei(path)) == 0){
    80005fd4:	f5040513          	addi	a0,s0,-176
    80005fd8:	bf2fe0ef          	jal	800043ca <namei>
    80005fdc:	84aa                	mv	s1,a0
    80005fde:	c11d                	beqz	a0,80006004 <sys_open+0x10c>
    ilock(ip);
    80005fe0:	95dfd0ef          	jal	8000393c <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80005fe4:	04449703          	lh	a4,68(s1)
    80005fe8:	4785                	li	a5,1
    80005fea:	f4f71ce3          	bne	a4,a5,80005f42 <sys_open+0x4a>
    80005fee:	f4c42783          	lw	a5,-180(s0)
    80005ff2:	d3b5                	beqz	a5,80005f56 <sys_open+0x5e>
      iunlockput(ip);
    80005ff4:	8526                	mv	a0,s1
    80005ff6:	c25fd0ef          	jal	80003c1a <iunlockput>
      end_op();
    80005ffa:	93ffe0ef          	jal	80004938 <end_op>
      return -1;
    80005ffe:	557d                	li	a0,-1
    80006000:	74aa                	ld	s1,168(sp)
    80006002:	b7c1                	j	80005fc2 <sys_open+0xca>
      end_op();
    80006004:	935fe0ef          	jal	80004938 <end_op>
      return -1;
    80006008:	557d                	li	a0,-1
    8000600a:	74aa                	ld	s1,168(sp)
    8000600c:	bf5d                	j	80005fc2 <sys_open+0xca>
    iunlockput(ip);
    8000600e:	8526                	mv	a0,s1
    80006010:	c0bfd0ef          	jal	80003c1a <iunlockput>
    end_op();
    80006014:	925fe0ef          	jal	80004938 <end_op>
    return -1;
    80006018:	557d                	li	a0,-1
    8000601a:	74aa                	ld	s1,168(sp)
    8000601c:	b75d                	j	80005fc2 <sys_open+0xca>
      fileclose(f);
    8000601e:	854a                	mv	a0,s2
    80006020:	f21fe0ef          	jal	80004f40 <fileclose>
    80006024:	69ea                	ld	s3,152(sp)
    iunlockput(ip);
    80006026:	8526                	mv	a0,s1
    80006028:	bf3fd0ef          	jal	80003c1a <iunlockput>
    end_op();
    8000602c:	90dfe0ef          	jal	80004938 <end_op>
    return -1;
    80006030:	557d                	li	a0,-1
    80006032:	74aa                	ld	s1,168(sp)
    80006034:	790a                	ld	s2,160(sp)
    80006036:	b771                	j	80005fc2 <sys_open+0xca>
    f->type = FD_DEVICE;
    80006038:	00e92023          	sw	a4,0(s2)
    f->major = ip->major;
    8000603c:	04649783          	lh	a5,70(s1)
    80006040:	02f91223          	sh	a5,36(s2)
    80006044:	bf35                	j	80005f80 <sys_open+0x88>
    itrunc(ip);
    80006046:	8526                	mv	a0,s1
    80006048:	a49fd0ef          	jal	80003a90 <itrunc>
    8000604c:	b795                	j	80005fb0 <sys_open+0xb8>

000000008000604e <sys_mkdir>:

uint64
sys_mkdir(void)
{
    8000604e:	7175                	addi	sp,sp,-144
    80006050:	e506                	sd	ra,136(sp)
    80006052:	e122                	sd	s0,128(sp)
    80006054:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80006056:	fc2fe0ef          	jal	80004818 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    8000605a:	08000613          	li	a2,128
    8000605e:	f7040593          	addi	a1,s0,-144
    80006062:	4501                	li	a0,0
    80006064:	85ffc0ef          	jal	800028c2 <argstr>
    80006068:	02054363          	bltz	a0,8000608e <sys_mkdir+0x40>
    8000606c:	4681                	li	a3,0
    8000606e:	4601                	li	a2,0
    80006070:	4585                	li	a1,1
    80006072:	f7040513          	addi	a0,s0,-144
    80006076:	973ff0ef          	jal	800059e8 <create>
    8000607a:	c911                	beqz	a0,8000608e <sys_mkdir+0x40>
    end_op();
    return -1;
  }
  iunlockput(ip);
    8000607c:	b9ffd0ef          	jal	80003c1a <iunlockput>
  end_op();
    80006080:	8b9fe0ef          	jal	80004938 <end_op>
  return 0;
    80006084:	4501                	li	a0,0
}
    80006086:	60aa                	ld	ra,136(sp)
    80006088:	640a                	ld	s0,128(sp)
    8000608a:	6149                	addi	sp,sp,144
    8000608c:	8082                	ret
    end_op();
    8000608e:	8abfe0ef          	jal	80004938 <end_op>
    return -1;
    80006092:	557d                	li	a0,-1
    80006094:	bfcd                	j	80006086 <sys_mkdir+0x38>

0000000080006096 <sys_mknod>:

uint64
sys_mknod(void)
{
    80006096:	7135                	addi	sp,sp,-160
    80006098:	ed06                	sd	ra,152(sp)
    8000609a:	e922                	sd	s0,144(sp)
    8000609c:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    8000609e:	f7afe0ef          	jal	80004818 <begin_op>
  argint(1, &major);
    800060a2:	f6c40593          	addi	a1,s0,-148
    800060a6:	4505                	li	a0,1
    800060a8:	fe2fc0ef          	jal	8000288a <argint>
  argint(2, &minor);
    800060ac:	f6840593          	addi	a1,s0,-152
    800060b0:	4509                	li	a0,2
    800060b2:	fd8fc0ef          	jal	8000288a <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    800060b6:	08000613          	li	a2,128
    800060ba:	f7040593          	addi	a1,s0,-144
    800060be:	4501                	li	a0,0
    800060c0:	803fc0ef          	jal	800028c2 <argstr>
    800060c4:	02054563          	bltz	a0,800060ee <sys_mknod+0x58>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    800060c8:	f6841683          	lh	a3,-152(s0)
    800060cc:	f6c41603          	lh	a2,-148(s0)
    800060d0:	458d                	li	a1,3
    800060d2:	f7040513          	addi	a0,s0,-144
    800060d6:	913ff0ef          	jal	800059e8 <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    800060da:	c911                	beqz	a0,800060ee <sys_mknod+0x58>
    end_op();
    return -1;
  }
  iunlockput(ip);
    800060dc:	b3ffd0ef          	jal	80003c1a <iunlockput>
  end_op();
    800060e0:	859fe0ef          	jal	80004938 <end_op>
  return 0;
    800060e4:	4501                	li	a0,0
}
    800060e6:	60ea                	ld	ra,152(sp)
    800060e8:	644a                	ld	s0,144(sp)
    800060ea:	610d                	addi	sp,sp,160
    800060ec:	8082                	ret
    end_op();
    800060ee:	84bfe0ef          	jal	80004938 <end_op>
    return -1;
    800060f2:	557d                	li	a0,-1
    800060f4:	bfcd                	j	800060e6 <sys_mknod+0x50>

00000000800060f6 <sys_chdir>:

uint64
sys_chdir(void)
{
    800060f6:	7135                	addi	sp,sp,-160
    800060f8:	ed06                	sd	ra,152(sp)
    800060fa:	e922                	sd	s0,144(sp)
    800060fc:	e14a                	sd	s2,128(sp)
    800060fe:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80006100:	869fb0ef          	jal	80001968 <myproc>
    80006104:	892a                	mv	s2,a0
  
  begin_op();
    80006106:	f12fe0ef          	jal	80004818 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    8000610a:	08000613          	li	a2,128
    8000610e:	f6040593          	addi	a1,s0,-160
    80006112:	4501                	li	a0,0
    80006114:	faefc0ef          	jal	800028c2 <argstr>
    80006118:	04054363          	bltz	a0,8000615e <sys_chdir+0x68>
    8000611c:	e526                	sd	s1,136(sp)
    8000611e:	f6040513          	addi	a0,s0,-160
    80006122:	aa8fe0ef          	jal	800043ca <namei>
    80006126:	84aa                	mv	s1,a0
    80006128:	c915                	beqz	a0,8000615c <sys_chdir+0x66>
    end_op();
    return -1;
  }
  ilock(ip);
    8000612a:	813fd0ef          	jal	8000393c <ilock>
  if(ip->type != T_DIR){
    8000612e:	04449703          	lh	a4,68(s1)
    80006132:	4785                	li	a5,1
    80006134:	02f71963          	bne	a4,a5,80006166 <sys_chdir+0x70>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80006138:	8526                	mv	a0,s1
    8000613a:	8f5fd0ef          	jal	80003a2e <iunlock>
  iput(p->cwd);
    8000613e:	15093503          	ld	a0,336(s2)
    80006142:	a0bfd0ef          	jal	80003b4c <iput>
  end_op();
    80006146:	ff2fe0ef          	jal	80004938 <end_op>
  p->cwd = ip;
    8000614a:	14993823          	sd	s1,336(s2)
  return 0;
    8000614e:	4501                	li	a0,0
    80006150:	64aa                	ld	s1,136(sp)
}
    80006152:	60ea                	ld	ra,152(sp)
    80006154:	644a                	ld	s0,144(sp)
    80006156:	690a                	ld	s2,128(sp)
    80006158:	610d                	addi	sp,sp,160
    8000615a:	8082                	ret
    8000615c:	64aa                	ld	s1,136(sp)
    end_op();
    8000615e:	fdafe0ef          	jal	80004938 <end_op>
    return -1;
    80006162:	557d                	li	a0,-1
    80006164:	b7fd                	j	80006152 <sys_chdir+0x5c>
    iunlockput(ip);
    80006166:	8526                	mv	a0,s1
    80006168:	ab3fd0ef          	jal	80003c1a <iunlockput>
    end_op();
    8000616c:	fccfe0ef          	jal	80004938 <end_op>
    return -1;
    80006170:	557d                	li	a0,-1
    80006172:	64aa                	ld	s1,136(sp)
    80006174:	bff9                	j	80006152 <sys_chdir+0x5c>

0000000080006176 <sys_exec>:

uint64
sys_exec(void)
{
    80006176:	7105                	addi	sp,sp,-480
    80006178:	ef86                	sd	ra,472(sp)
    8000617a:	eba2                	sd	s0,464(sp)
    8000617c:	1380                	addi	s0,sp,480
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    8000617e:	e2840593          	addi	a1,s0,-472
    80006182:	4505                	li	a0,1
    80006184:	f22fc0ef          	jal	800028a6 <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    80006188:	08000613          	li	a2,128
    8000618c:	f3040593          	addi	a1,s0,-208
    80006190:	4501                	li	a0,0
    80006192:	f30fc0ef          	jal	800028c2 <argstr>
    80006196:	87aa                	mv	a5,a0
    return -1;
    80006198:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    8000619a:	0e07c063          	bltz	a5,8000627a <sys_exec+0x104>
    8000619e:	e7a6                	sd	s1,456(sp)
    800061a0:	e3ca                	sd	s2,448(sp)
    800061a2:	ff4e                	sd	s3,440(sp)
    800061a4:	fb52                	sd	s4,432(sp)
    800061a6:	f756                	sd	s5,424(sp)
    800061a8:	f35a                	sd	s6,416(sp)
    800061aa:	ef5e                	sd	s7,408(sp)
  }
  memset(argv, 0, sizeof(argv));
    800061ac:	e3040a13          	addi	s4,s0,-464
    800061b0:	10000613          	li	a2,256
    800061b4:	4581                	li	a1,0
    800061b6:	8552                	mv	a0,s4
    800061b8:	b73fa0ef          	jal	80000d2a <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    800061bc:	84d2                	mv	s1,s4
  memset(argv, 0, sizeof(argv));
    800061be:	89d2                	mv	s3,s4
    800061c0:	4901                	li	s2,0
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    800061c2:	e2040a93          	addi	s5,s0,-480
      break;
    }
    argv[i] = kalloc();
    if(argv[i] == 0)
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    800061c6:	6b05                	lui	s6,0x1
    if(i >= NELEM(argv)){
    800061c8:	02000b93          	li	s7,32
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    800061cc:	00391513          	slli	a0,s2,0x3
    800061d0:	85d6                	mv	a1,s5
    800061d2:	e2843783          	ld	a5,-472(s0)
    800061d6:	953e                	add	a0,a0,a5
    800061d8:	e28fc0ef          	jal	80002800 <fetchaddr>
    800061dc:	02054663          	bltz	a0,80006208 <sys_exec+0x92>
    if(uarg == 0){
    800061e0:	e2043783          	ld	a5,-480(s0)
    800061e4:	c7a1                	beqz	a5,8000622c <sys_exec+0xb6>
    argv[i] = kalloc();
    800061e6:	991fa0ef          	jal	80000b76 <kalloc>
    800061ea:	85aa                	mv	a1,a0
    800061ec:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    800061f0:	cd01                	beqz	a0,80006208 <sys_exec+0x92>
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    800061f2:	865a                	mv	a2,s6
    800061f4:	e2043503          	ld	a0,-480(s0)
    800061f8:	e52fc0ef          	jal	8000284a <fetchstr>
    800061fc:	00054663          	bltz	a0,80006208 <sys_exec+0x92>
    if(i >= NELEM(argv)){
    80006200:	0905                	addi	s2,s2,1
    80006202:	09a1                	addi	s3,s3,8
    80006204:	fd7914e3          	bne	s2,s7,800061cc <sys_exec+0x56>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80006208:	100a0a13          	addi	s4,s4,256
    8000620c:	6088                	ld	a0,0(s1)
    8000620e:	cd31                	beqz	a0,8000626a <sys_exec+0xf4>
    kfree(argv[i]);
    80006210:	87ffa0ef          	jal	80000a8e <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80006214:	04a1                	addi	s1,s1,8
    80006216:	ff449be3          	bne	s1,s4,8000620c <sys_exec+0x96>
  return -1;
    8000621a:	557d                	li	a0,-1
    8000621c:	64be                	ld	s1,456(sp)
    8000621e:	691e                	ld	s2,448(sp)
    80006220:	79fa                	ld	s3,440(sp)
    80006222:	7a5a                	ld	s4,432(sp)
    80006224:	7aba                	ld	s5,424(sp)
    80006226:	7b1a                	ld	s6,416(sp)
    80006228:	6bfa                	ld	s7,408(sp)
    8000622a:	a881                	j	8000627a <sys_exec+0x104>
      argv[i] = 0;
    8000622c:	0009079b          	sext.w	a5,s2
    80006230:	e3040593          	addi	a1,s0,-464
    80006234:	078e                	slli	a5,a5,0x3
    80006236:	97ae                	add	a5,a5,a1
    80006238:	0007b023          	sd	zero,0(a5)
  int ret = kexec(path, argv);
    8000623c:	f3040513          	addi	a0,s0,-208
    80006240:	bb2ff0ef          	jal	800055f2 <kexec>
    80006244:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80006246:	100a0a13          	addi	s4,s4,256
    8000624a:	6088                	ld	a0,0(s1)
    8000624c:	c511                	beqz	a0,80006258 <sys_exec+0xe2>
    kfree(argv[i]);
    8000624e:	841fa0ef          	jal	80000a8e <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80006252:	04a1                	addi	s1,s1,8
    80006254:	ff449be3          	bne	s1,s4,8000624a <sys_exec+0xd4>
  return ret;
    80006258:	854a                	mv	a0,s2
    8000625a:	64be                	ld	s1,456(sp)
    8000625c:	691e                	ld	s2,448(sp)
    8000625e:	79fa                	ld	s3,440(sp)
    80006260:	7a5a                	ld	s4,432(sp)
    80006262:	7aba                	ld	s5,424(sp)
    80006264:	7b1a                	ld	s6,416(sp)
    80006266:	6bfa                	ld	s7,408(sp)
    80006268:	a809                	j	8000627a <sys_exec+0x104>
  return -1;
    8000626a:	557d                	li	a0,-1
    8000626c:	64be                	ld	s1,456(sp)
    8000626e:	691e                	ld	s2,448(sp)
    80006270:	79fa                	ld	s3,440(sp)
    80006272:	7a5a                	ld	s4,432(sp)
    80006274:	7aba                	ld	s5,424(sp)
    80006276:	7b1a                	ld	s6,416(sp)
    80006278:	6bfa                	ld	s7,408(sp)
}
    8000627a:	60fe                	ld	ra,472(sp)
    8000627c:	645e                	ld	s0,464(sp)
    8000627e:	613d                	addi	sp,sp,480
    80006280:	8082                	ret

0000000080006282 <sys_pipe>:

uint64
sys_pipe(void)
{
    80006282:	7139                	addi	sp,sp,-64
    80006284:	fc06                	sd	ra,56(sp)
    80006286:	f822                	sd	s0,48(sp)
    80006288:	f426                	sd	s1,40(sp)
    8000628a:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    8000628c:	edcfb0ef          	jal	80001968 <myproc>
    80006290:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    80006292:	fd840593          	addi	a1,s0,-40
    80006296:	4501                	li	a0,0
    80006298:	e0efc0ef          	jal	800028a6 <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    8000629c:	fc840593          	addi	a1,s0,-56
    800062a0:	fd040513          	addi	a0,s0,-48
    800062a4:	81eff0ef          	jal	800052c2 <pipealloc>
    return -1;
    800062a8:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    800062aa:	0a054763          	bltz	a0,80006358 <sys_pipe+0xd6>
  fd0 = -1;
    800062ae:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    800062b2:	fd043503          	ld	a0,-48(s0)
    800062b6:	ef2ff0ef          	jal	800059a8 <fdalloc>
    800062ba:	fca42223          	sw	a0,-60(s0)
    800062be:	08054463          	bltz	a0,80006346 <sys_pipe+0xc4>
    800062c2:	fc843503          	ld	a0,-56(s0)
    800062c6:	ee2ff0ef          	jal	800059a8 <fdalloc>
    800062ca:	fca42023          	sw	a0,-64(s0)
    800062ce:	06054263          	bltz	a0,80006332 <sys_pipe+0xb0>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    800062d2:	4691                	li	a3,4
    800062d4:	fc440613          	addi	a2,s0,-60
    800062d8:	fd843583          	ld	a1,-40(s0)
    800062dc:	68a8                	ld	a0,80(s1)
    800062de:	bb0fb0ef          	jal	8000168e <copyout>
    800062e2:	00054e63          	bltz	a0,800062fe <sys_pipe+0x7c>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    800062e6:	4691                	li	a3,4
    800062e8:	fc040613          	addi	a2,s0,-64
    800062ec:	fd843583          	ld	a1,-40(s0)
    800062f0:	95b6                	add	a1,a1,a3
    800062f2:	68a8                	ld	a0,80(s1)
    800062f4:	b9afb0ef          	jal	8000168e <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    800062f8:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    800062fa:	04055f63          	bgez	a0,80006358 <sys_pipe+0xd6>
    p->ofile[fd0] = 0;
    800062fe:	fc442783          	lw	a5,-60(s0)
    80006302:	078e                	slli	a5,a5,0x3
    80006304:	0d078793          	addi	a5,a5,208
    80006308:	97a6                	add	a5,a5,s1
    8000630a:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    8000630e:	fc042783          	lw	a5,-64(s0)
    80006312:	078e                	slli	a5,a5,0x3
    80006314:	0d078793          	addi	a5,a5,208
    80006318:	97a6                	add	a5,a5,s1
    8000631a:	0007b023          	sd	zero,0(a5)
    fileclose(rf);
    8000631e:	fd043503          	ld	a0,-48(s0)
    80006322:	c1ffe0ef          	jal	80004f40 <fileclose>
    fileclose(wf);
    80006326:	fc843503          	ld	a0,-56(s0)
    8000632a:	c17fe0ef          	jal	80004f40 <fileclose>
    return -1;
    8000632e:	57fd                	li	a5,-1
    80006330:	a025                	j	80006358 <sys_pipe+0xd6>
    if(fd0 >= 0)
    80006332:	fc442783          	lw	a5,-60(s0)
    80006336:	0007c863          	bltz	a5,80006346 <sys_pipe+0xc4>
      p->ofile[fd0] = 0;
    8000633a:	078e                	slli	a5,a5,0x3
    8000633c:	0d078793          	addi	a5,a5,208
    80006340:	97a6                	add	a5,a5,s1
    80006342:	0007b023          	sd	zero,0(a5)
    fileclose(rf);
    80006346:	fd043503          	ld	a0,-48(s0)
    8000634a:	bf7fe0ef          	jal	80004f40 <fileclose>
    fileclose(wf);
    8000634e:	fc843503          	ld	a0,-56(s0)
    80006352:	beffe0ef          	jal	80004f40 <fileclose>
    return -1;
    80006356:	57fd                	li	a5,-1
}
    80006358:	853e                	mv	a0,a5
    8000635a:	70e2                	ld	ra,56(sp)
    8000635c:	7442                	ld	s0,48(sp)
    8000635e:	74a2                	ld	s1,40(sp)
    80006360:	6121                	addi	sp,sp,64
    80006362:	8082                	ret

0000000080006364 <sys_fsread>:
uint64
sys_fsread(void)
{
    80006364:	1101                	addi	sp,sp,-32
    80006366:	ec06                	sd	ra,24(sp)
    80006368:	e822                	sd	s0,16(sp)
    8000636a:	1000                	addi	s0,sp,32
  uint64 addr;
  int n;

  // استدعاء الدوال مباشرة لأنها void في نسختك
  argaddr(0, &addr); 
    8000636c:	fe840593          	addi	a1,s0,-24
    80006370:	4501                	li	a0,0
    80006372:	d34fc0ef          	jal	800028a6 <argaddr>
  argint(1, &n);
    80006376:	fe440593          	addi	a1,s0,-28
    8000637a:	4505                	li	a0,1
    8000637c:	d0efc0ef          	jal	8000288a <argint>

  // شرط حماية صارم داخل الكيرنل: 
  // إذا كانت n سالبة، أو صفر، أو أكبر من الحد الأقصى للبفر (32)، قم بتصحيحها فوراً
  if(n <= 0)
    80006380:	fe442783          	lw	a5,-28(s0)
    return 0;
    80006384:	4501                	li	a0,0
  if(n <= 0)
    80006386:	00f05e63          	blez	a5,800063a2 <sys_fsread+0x3e>
  if(n > 32)
    8000638a:	02000713          	li	a4,32
    8000638e:	00f75463          	bge	a4,a5,80006396 <sys_fsread+0x32>
    n = 32;
    80006392:	fee42223          	sw	a4,-28(s0)

  // استدعاء الوظيفة الحقيقية وإعادة نتيجتها
  return fslog_read_many((struct fs_event *)addr, n);
    80006396:	fe442583          	lw	a1,-28(s0)
    8000639a:	fe843503          	ld	a0,-24(s0)
    8000639e:	44f000ef          	jal	80006fec <fslog_read_many>
}
    800063a2:	60e2                	ld	ra,24(sp)
    800063a4:	6442                	ld	s0,16(sp)
    800063a6:	6105                	addi	sp,sp,32
    800063a8:	8082                	ret

00000000800063aa <sys_schedread>:

uint64
sys_schedread(void)
{
    800063aa:	1101                	addi	sp,sp,-32
    800063ac:	ec06                	sd	ra,24(sp)
    800063ae:	e822                	sd	s0,16(sp)
    800063b0:	1000                	addi	s0,sp,32
  uint64 addr;
  int n;

  argaddr(0, &addr);
    800063b2:	fe840593          	addi	a1,s0,-24
    800063b6:	4501                	li	a0,0
    800063b8:	ceefc0ef          	jal	800028a6 <argaddr>
  argint(1, &n);
    800063bc:	fe440593          	addi	a1,s0,-28
    800063c0:	4505                	li	a0,1
    800063c2:	cc8fc0ef          	jal	8000288a <argint>

  if(n <= 0)
    800063c6:	fe442783          	lw	a5,-28(s0)
    return 0;
    800063ca:	4501                	li	a0,0
  if(n <= 0)
    800063cc:	00f05e63          	blez	a5,800063e8 <sys_schedread+0x3e>
  if(n > 32)
    800063d0:	02000713          	li	a4,32
    800063d4:	00f75463          	bge	a4,a5,800063dc <sys_schedread+0x32>
    n = 32;
    800063d8:	fee42223          	sw	a4,-28(s0)

  return schedread((struct sched_event *)addr, n);
    800063dc:	fe442583          	lw	a1,-28(s0)
    800063e0:	fe843503          	ld	a0,-24(s0)
    800063e4:	7bc010ef          	jal	80007ba0 <schedread>
}
    800063e8:	60e2                	ld	ra,24(sp)
    800063ea:	6442                	ld	s0,16(sp)
    800063ec:	6105                	addi	sp,sp,32
    800063ee:	8082                	ret

00000000800063f0 <sys_getcpuinfo>:

uint64
sys_getcpuinfo(void)
{
    800063f0:	7131                	addi	sp,sp,-192
    800063f2:	fd06                	sd	ra,184(sp)
    800063f4:	f922                	sd	s0,176(sp)
    800063f6:	f526                	sd	s1,168(sp)
    800063f8:	f14a                	sd	s2,160(sp)
    800063fa:	ed4e                	sd	s3,152(sp)
    800063fc:	e952                	sd	s4,144(sp)
    800063fe:	e556                	sd	s5,136(sp)
    80006400:	e15a                	sd	s6,128(sp)
    80006402:	fcde                	sd	s7,120(sp)
    80006404:	f8e2                	sd	s8,112(sp)
    80006406:	f4e6                	sd	s9,104(sp)
    80006408:	0180                	addi	s0,sp,192
  int ncpu;
  struct cpu_info info;
  int i;
  extern struct cpu cpus[NCPU];

  argaddr(0, &addr);
    8000640a:	f9840593          	addi	a1,s0,-104
    8000640e:	4501                	li	a0,0
    80006410:	c96fc0ef          	jal	800028a6 <argaddr>
  argint(1, &ncpu);
    80006414:	f9440593          	addi	a1,s0,-108
    80006418:	4505                	li	a0,1
    8000641a:	c70fc0ef          	jal	8000288a <argint>

  if(ncpu <= 0 || ncpu > NCPU)
    8000641e:	f9442783          	lw	a5,-108(s0)
    80006422:	37fd                	addiw	a5,a5,-1
    80006424:	471d                	li	a4,7
    80006426:	00f77563          	bgeu	a4,a5,80006430 <sys_getcpuinfo+0x40>
    ncpu = NCPU;
    8000642a:	47a1                	li	a5,8
    8000642c:	f8f42a23          	sw	a5,-108(s0)

  // Fill in CPU info for each CPU
  for(i = 0; i < ncpu; i++) {
    80006430:	0000ca17          	auipc	s4,0xc
    80006434:	da8a0a13          	addi	s4,s4,-600 # 800121d8 <cpus>
{
    80006438:	4981                	li	s3,0
    8000643a:	4901                	li	s2,0
    memset(&info, 0, sizeof(info));
    8000643c:	f4840b13          	addi	s6,s0,-184
    80006440:	04800a93          	li	s5,72
    
    info.cpu = i;
    if(cpus[i].proc != 0) {
      struct proc *p = cpus[i].proc;
      info.active = 1;
    80006444:	4c85                	li	s9,1
      info.current_pid = p->pid;
      info.current_state = p->state;
      
      // Copy process name
      safestrcpy(info.proc_name, p->name, PROC_NAME_LEN);
    80006446:	f5440c13          	addi	s8,s0,-172
    8000644a:	4bc1                	li	s7,16
    8000644c:	a805                	j	8000647c <sys_getcpuinfo+0x8c>
      if(p->trapframe) {
        info.context_eip = p->trapframe->epc;  // instruction pointer
        info.context_esp = p->trapframe->sp;   // stack pointer
      }
    }
    info.busy_percent = 0;  // Simplified
    8000644e:	f8042423          	sw	zero,-120(s0)
    
    if(copyout(myproc()->pagetable, addr + i * sizeof(struct cpu_info), 
    80006452:	d16fb0ef          	jal	80001968 <myproc>
    80006456:	86d6                	mv	a3,s5
    80006458:	865a                	mv	a2,s6
    8000645a:	f9843583          	ld	a1,-104(s0)
    8000645e:	95ce                	add	a1,a1,s3
    80006460:	6928                	ld	a0,80(a0)
    80006462:	a2cfb0ef          	jal	8000168e <copyout>
    80006466:	04054c63          	bltz	a0,800064be <sys_getcpuinfo+0xce>
  for(i = 0; i < ncpu; i++) {
    8000646a:	2905                	addiw	s2,s2,1
    8000646c:	f9442503          	lw	a0,-108(s0)
    80006470:	080a0a13          	addi	s4,s4,128
    80006474:	04898993          	addi	s3,s3,72
    80006478:	04a95463          	bge	s2,a0,800064c0 <sys_getcpuinfo+0xd0>
    memset(&info, 0, sizeof(info));
    8000647c:	8656                	mv	a2,s5
    8000647e:	4581                	li	a1,0
    80006480:	855a                	mv	a0,s6
    80006482:	8a9fa0ef          	jal	80000d2a <memset>
    info.cpu = i;
    80006486:	f5242423          	sw	s2,-184(s0)
    if(cpus[i].proc != 0) {
    8000648a:	000a3483          	ld	s1,0(s4)
    8000648e:	d0e1                	beqz	s1,8000644e <sys_getcpuinfo+0x5e>
      info.active = 1;
    80006490:	f5942623          	sw	s9,-180(s0)
      info.current_pid = p->pid;
    80006494:	589c                	lw	a5,48(s1)
    80006496:	f4f42823          	sw	a5,-176(s0)
      info.current_state = p->state;
    8000649a:	4c9c                	lw	a5,24(s1)
    8000649c:	f6f42223          	sw	a5,-156(s0)
      safestrcpy(info.proc_name, p->name, PROC_NAME_LEN);
    800064a0:	865e                	mv	a2,s7
    800064a2:	15848593          	addi	a1,s1,344
    800064a6:	8562                	mv	a0,s8
    800064a8:	9d7fa0ef          	jal	80000e7e <safestrcpy>
      if(p->trapframe) {
    800064ac:	6cbc                	ld	a5,88(s1)
    800064ae:	d3c5                	beqz	a5,8000644e <sys_getcpuinfo+0x5e>
        info.context_eip = p->trapframe->epc;  // instruction pointer
    800064b0:	6f98                	ld	a4,24(a5)
    800064b2:	f6e43c23          	sd	a4,-136(s0)
        info.context_esp = p->trapframe->sp;   // stack pointer
    800064b6:	7b9c                	ld	a5,48(a5)
    800064b8:	f8f43023          	sd	a5,-128(s0)
    800064bc:	bf49                	j	8000644e <sys_getcpuinfo+0x5e>
               (char *)&info, sizeof(info)) < 0)
      return -1;
    800064be:	557d                	li	a0,-1
  }

  return ncpu;
}
    800064c0:	70ea                	ld	ra,184(sp)
    800064c2:	744a                	ld	s0,176(sp)
    800064c4:	74aa                	ld	s1,168(sp)
    800064c6:	790a                	ld	s2,160(sp)
    800064c8:	69ea                	ld	s3,152(sp)
    800064ca:	6a4a                	ld	s4,144(sp)
    800064cc:	6aaa                	ld	s5,136(sp)
    800064ce:	6b0a                	ld	s6,128(sp)
    800064d0:	7be6                	ld	s7,120(sp)
    800064d2:	7c46                	ld	s8,112(sp)
    800064d4:	7ca6                	ld	s9,104(sp)
    800064d6:	6129                	addi	sp,sp,192
    800064d8:	8082                	ret

00000000800064da <sys_getprocstats>:

uint64
sys_getprocstats(void)
{
    800064da:	7175                	addi	sp,sp,-144
    800064dc:	e506                	sd	ra,136(sp)
    800064de:	e122                	sd	s0,128(sp)
    800064e0:	0900                	addi	s0,sp,144
  uint64 addr;
  struct proc_stats stats;
  struct proc *p;
  extern struct proc proc[];

  argaddr(0, &addr);
    800064e2:	fe840593          	addi	a1,s0,-24
    800064e6:	4501                	li	a0,0
    800064e8:	bbefc0ef          	jal	800028a6 <argaddr>

  memset(&stats, 0, sizeof(stats));
    800064ec:	07000613          	li	a2,112
    800064f0:	4581                	li	a1,0
    800064f2:	f7840513          	addi	a0,s0,-136
    800064f6:	835fa0ef          	jal	80000d2a <memset>
  stats.total_created = 0;
    800064fa:	fc043c23          	sd	zero,-40(s0)
  stats.total_exited = 0;
    800064fe:	fe043023          	sd	zero,-32(s0)
    80006502:	4e01                	li	t3,0
    80006504:	4301                	li	t1,0

  // Walk through all processes
  for(p = proc; p < &proc[NPROC]; p++) {
    80006506:	0000c797          	auipc	a5,0xc
    8000650a:	0d278793          	addi	a5,a5,210 # 800125d8 <proc>
    if(p->state != UNUSED) {
      stats.current_count[p->state]++;
    8000650e:	f7840813          	addi	a6,s0,-136
      stats.unique_count[p->state]++;
      if(p->state == RUNNING) {
    80006512:	4891                	li	a7,4
        stats.total_created++;
    80006514:	4e85                	li	t4,1
  for(p = proc; p < &proc[NPROC]; p++) {
    80006516:	00012517          	auipc	a0,0x12
    8000651a:	ac250513          	addi	a0,a0,-1342 # 80017fd8 <tickslock>
    8000651e:	a029                	j	80006528 <sys_getprocstats+0x4e>
    80006520:	16878793          	addi	a5,a5,360
    80006524:	02a78963          	beq	a5,a0,80006556 <sys_getprocstats+0x7c>
    if(p->state != UNUSED) {
    80006528:	4f94                	lw	a3,24(a5)
    8000652a:	dafd                	beqz	a3,80006520 <sys_getprocstats+0x46>
      stats.current_count[p->state]++;
    8000652c:	02069713          	slli	a4,a3,0x20
    80006530:	9301                	srli	a4,a4,0x20
    80006532:	00371613          	slli	a2,a4,0x3
    80006536:	9642                	add	a2,a2,a6
    80006538:	620c                	ld	a1,0(a2)
    8000653a:	0585                	addi	a1,a1,1
    8000653c:	e20c                	sd	a1,0(a2)
      stats.unique_count[p->state]++;
    8000653e:	070e                	slli	a4,a4,0x3
    80006540:	03070713          	addi	a4,a4,48
    80006544:	9742                	add	a4,a4,a6
    80006546:	6310                	ld	a2,0(a4)
    80006548:	0605                	addi	a2,a2,1 # 2001 <_entry-0x7fffdfff>
    8000654a:	e310                	sd	a2,0(a4)
      if(p->state == RUNNING) {
    8000654c:	fd169ae3          	bne	a3,a7,80006520 <sys_getprocstats+0x46>
        stats.total_created++;
    80006550:	0305                	addi	t1,t1,1
    80006552:	8e76                	mv	t3,t4
    80006554:	b7f1                	j	80006520 <sys_getprocstats+0x46>
    80006556:	000e0463          	beqz	t3,8000655e <sys_getprocstats+0x84>
    8000655a:	fc643c23          	sd	t1,-40(s0)
      }
    }
  }

  if(copyout(myproc()->pagetable, addr, (char *)&stats, sizeof(stats)) < 0)
    8000655e:	c0afb0ef          	jal	80001968 <myproc>
    80006562:	07000693          	li	a3,112
    80006566:	f7840613          	addi	a2,s0,-136
    8000656a:	fe843583          	ld	a1,-24(s0)
    8000656e:	6928                	ld	a0,80(a0)
    80006570:	91efb0ef          	jal	8000168e <copyout>
    return -1;

  return 0;
}
    80006574:	957d                	srai	a0,a0,0x3f
    80006576:	60aa                	ld	ra,136(sp)
    80006578:	640a                	ld	s0,128(sp)
    8000657a:	6149                	addi	sp,sp,144
    8000657c:	8082                	ret
	...

0000000080006580 <kernelvec>:
.globl kerneltrap
.globl kernelvec
.align 4
kernelvec:
        # make room to save registers.
        addi sp, sp, -256
    80006580:	7111                	addi	sp,sp,-256

        # save caller-saved registers.
        sd ra, 0(sp)
    80006582:	e006                	sd	ra,0(sp)
        # sd sp, 8(sp)
        sd gp, 16(sp)
    80006584:	e80e                	sd	gp,16(sp)
        sd tp, 24(sp)
    80006586:	ec12                	sd	tp,24(sp)
        sd t0, 32(sp)
    80006588:	f016                	sd	t0,32(sp)
        sd t1, 40(sp)
    8000658a:	f41a                	sd	t1,40(sp)
        sd t2, 48(sp)
    8000658c:	f81e                	sd	t2,48(sp)
        sd a0, 72(sp)
    8000658e:	e4aa                	sd	a0,72(sp)
        sd a1, 80(sp)
    80006590:	e8ae                	sd	a1,80(sp)
        sd a2, 88(sp)
    80006592:	ecb2                	sd	a2,88(sp)
        sd a3, 96(sp)
    80006594:	f0b6                	sd	a3,96(sp)
        sd a4, 104(sp)
    80006596:	f4ba                	sd	a4,104(sp)
        sd a5, 112(sp)
    80006598:	f8be                	sd	a5,112(sp)
        sd a6, 120(sp)
    8000659a:	fcc2                	sd	a6,120(sp)
        sd a7, 128(sp)
    8000659c:	e146                	sd	a7,128(sp)
        sd t3, 216(sp)
    8000659e:	edf2                	sd	t3,216(sp)
        sd t4, 224(sp)
    800065a0:	f1f6                	sd	t4,224(sp)
        sd t5, 232(sp)
    800065a2:	f5fa                	sd	t5,232(sp)
        sd t6, 240(sp)
    800065a4:	f9fe                	sd	t6,240(sp)

        # call the C trap handler in trap.c
        call kerneltrap
    800065a6:	968fc0ef          	jal	8000270e <kerneltrap>

        # restore registers.
        ld ra, 0(sp)
    800065aa:	6082                	ld	ra,0(sp)
        # ld sp, 8(sp)
        ld gp, 16(sp)
    800065ac:	61c2                	ld	gp,16(sp)
        # not tp (contains hartid), in case we moved CPUs
        ld t0, 32(sp)
    800065ae:	7282                	ld	t0,32(sp)
        ld t1, 40(sp)
    800065b0:	7322                	ld	t1,40(sp)
        ld t2, 48(sp)
    800065b2:	73c2                	ld	t2,48(sp)
        ld a0, 72(sp)
    800065b4:	6526                	ld	a0,72(sp)
        ld a1, 80(sp)
    800065b6:	65c6                	ld	a1,80(sp)
        ld a2, 88(sp)
    800065b8:	6666                	ld	a2,88(sp)
        ld a3, 96(sp)
    800065ba:	7686                	ld	a3,96(sp)
        ld a4, 104(sp)
    800065bc:	7726                	ld	a4,104(sp)
        ld a5, 112(sp)
    800065be:	77c6                	ld	a5,112(sp)
        ld a6, 120(sp)
    800065c0:	7866                	ld	a6,120(sp)
        ld a7, 128(sp)
    800065c2:	688a                	ld	a7,128(sp)
        ld t3, 216(sp)
    800065c4:	6e6e                	ld	t3,216(sp)
        ld t4, 224(sp)
    800065c6:	7e8e                	ld	t4,224(sp)
        ld t5, 232(sp)
    800065c8:	7f2e                	ld	t5,232(sp)
        ld t6, 240(sp)
    800065ca:	7fce                	ld	t6,240(sp)

        addi sp, sp, 256
    800065cc:	6111                	addi	sp,sp,256

        # return to whatever we were doing in the kernel.
        sret
    800065ce:	10200073          	sret
    800065d2:	00000013          	nop
    800065d6:	00000013          	nop
    800065da:	00000013          	nop

00000000800065de <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    800065de:	1141                	addi	sp,sp,-16
    800065e0:	e406                	sd	ra,8(sp)
    800065e2:	e022                	sd	s0,0(sp)
    800065e4:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    800065e6:	0c000737          	lui	a4,0xc000
    800065ea:	4785                	li	a5,1
    800065ec:	d71c                	sw	a5,40(a4)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    800065ee:	c35c                	sw	a5,4(a4)
}
    800065f0:	60a2                	ld	ra,8(sp)
    800065f2:	6402                	ld	s0,0(sp)
    800065f4:	0141                	addi	sp,sp,16
    800065f6:	8082                	ret

00000000800065f8 <plicinithart>:

void
plicinithart(void)
{
    800065f8:	1141                	addi	sp,sp,-16
    800065fa:	e406                	sd	ra,8(sp)
    800065fc:	e022                	sd	s0,0(sp)
    800065fe:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80006600:	b34fb0ef          	jal	80001934 <cpuid>
  
  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80006604:	0085171b          	slliw	a4,a0,0x8
    80006608:	0c0027b7          	lui	a5,0xc002
    8000660c:	97ba                	add	a5,a5,a4
    8000660e:	40200713          	li	a4,1026
    80006612:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80006616:	00d5151b          	slliw	a0,a0,0xd
    8000661a:	0c2017b7          	lui	a5,0xc201
    8000661e:	97aa                	add	a5,a5,a0
    80006620:	0007a023          	sw	zero,0(a5) # c201000 <_entry-0x73dff000>
}
    80006624:	60a2                	ld	ra,8(sp)
    80006626:	6402                	ld	s0,0(sp)
    80006628:	0141                	addi	sp,sp,16
    8000662a:	8082                	ret

000000008000662c <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    8000662c:	1141                	addi	sp,sp,-16
    8000662e:	e406                	sd	ra,8(sp)
    80006630:	e022                	sd	s0,0(sp)
    80006632:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80006634:	b00fb0ef          	jal	80001934 <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80006638:	00d5151b          	slliw	a0,a0,0xd
    8000663c:	0c2017b7          	lui	a5,0xc201
    80006640:	97aa                	add	a5,a5,a0
  return irq;
}
    80006642:	43c8                	lw	a0,4(a5)
    80006644:	60a2                	ld	ra,8(sp)
    80006646:	6402                	ld	s0,0(sp)
    80006648:	0141                	addi	sp,sp,16
    8000664a:	8082                	ret

000000008000664c <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    8000664c:	1101                	addi	sp,sp,-32
    8000664e:	ec06                	sd	ra,24(sp)
    80006650:	e822                	sd	s0,16(sp)
    80006652:	e426                	sd	s1,8(sp)
    80006654:	1000                	addi	s0,sp,32
    80006656:	84aa                	mv	s1,a0
  int hart = cpuid();
    80006658:	adcfb0ef          	jal	80001934 <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    8000665c:	00d5179b          	slliw	a5,a0,0xd
    80006660:	0c201737          	lui	a4,0xc201
    80006664:	97ba                	add	a5,a5,a4
    80006666:	c3c4                	sw	s1,4(a5)
}
    80006668:	60e2                	ld	ra,24(sp)
    8000666a:	6442                	ld	s0,16(sp)
    8000666c:	64a2                	ld	s1,8(sp)
    8000666e:	6105                	addi	sp,sp,32
    80006670:	8082                	ret

0000000080006672 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80006672:	1141                	addi	sp,sp,-16
    80006674:	e406                	sd	ra,8(sp)
    80006676:	e022                	sd	s0,0(sp)
    80006678:	0800                	addi	s0,sp,16
  if(i >= NUM)
    8000667a:	479d                	li	a5,7
    8000667c:	04a7ca63          	blt	a5,a0,800066d0 <free_desc+0x5e>
    panic("free_desc 1");
  if(disk.free[i])
    80006680:	0001d797          	auipc	a5,0x1d
    80006684:	bf878793          	addi	a5,a5,-1032 # 80023278 <disk>
    80006688:	97aa                	add	a5,a5,a0
    8000668a:	0187c783          	lbu	a5,24(a5)
    8000668e:	e7b9                	bnez	a5,800066dc <free_desc+0x6a>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    80006690:	00451693          	slli	a3,a0,0x4
    80006694:	0001d797          	auipc	a5,0x1d
    80006698:	be478793          	addi	a5,a5,-1052 # 80023278 <disk>
    8000669c:	6398                	ld	a4,0(a5)
    8000669e:	9736                	add	a4,a4,a3
    800066a0:	00073023          	sd	zero,0(a4) # c201000 <_entry-0x73dff000>
  disk.desc[i].len = 0;
    800066a4:	6398                	ld	a4,0(a5)
    800066a6:	9736                	add	a4,a4,a3
    800066a8:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    800066ac:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    800066b0:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    800066b4:	97aa                	add	a5,a5,a0
    800066b6:	4705                	li	a4,1
    800066b8:	00e78c23          	sb	a4,24(a5)
  wakeup(&disk.free[0]);
    800066bc:	0001d517          	auipc	a0,0x1d
    800066c0:	bd450513          	addi	a0,a0,-1068 # 80023290 <disk+0x18>
    800066c4:	907fb0ef          	jal	80001fca <wakeup>
}
    800066c8:	60a2                	ld	ra,8(sp)
    800066ca:	6402                	ld	s0,0(sp)
    800066cc:	0141                	addi	sp,sp,16
    800066ce:	8082                	ret
    panic("free_desc 1");
    800066d0:	00003517          	auipc	a0,0x3
    800066d4:	65050513          	addi	a0,a0,1616 # 80009d20 <etext+0xd20>
    800066d8:	97efa0ef          	jal	80000856 <panic>
    panic("free_desc 2");
    800066dc:	00003517          	auipc	a0,0x3
    800066e0:	65450513          	addi	a0,a0,1620 # 80009d30 <etext+0xd30>
    800066e4:	972fa0ef          	jal	80000856 <panic>

00000000800066e8 <virtio_disk_init>:
{
    800066e8:	1101                	addi	sp,sp,-32
    800066ea:	ec06                	sd	ra,24(sp)
    800066ec:	e822                	sd	s0,16(sp)
    800066ee:	e426                	sd	s1,8(sp)
    800066f0:	e04a                	sd	s2,0(sp)
    800066f2:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    800066f4:	00003597          	auipc	a1,0x3
    800066f8:	64c58593          	addi	a1,a1,1612 # 80009d40 <etext+0xd40>
    800066fc:	0001d517          	auipc	a0,0x1d
    80006700:	ca450513          	addi	a0,a0,-860 # 800233a0 <disk+0x128>
    80006704:	cccfa0ef          	jal	80000bd0 <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80006708:	100017b7          	lui	a5,0x10001
    8000670c:	4398                	lw	a4,0(a5)
    8000670e:	2701                	sext.w	a4,a4
    80006710:	747277b7          	lui	a5,0x74727
    80006714:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    80006718:	14f71863          	bne	a4,a5,80006868 <virtio_disk_init+0x180>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    8000671c:	100017b7          	lui	a5,0x10001
    80006720:	43dc                	lw	a5,4(a5)
    80006722:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80006724:	4709                	li	a4,2
    80006726:	14e79163          	bne	a5,a4,80006868 <virtio_disk_init+0x180>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    8000672a:	100017b7          	lui	a5,0x10001
    8000672e:	479c                	lw	a5,8(a5)
    80006730:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80006732:	12e79b63          	bne	a5,a4,80006868 <virtio_disk_init+0x180>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    80006736:	100017b7          	lui	a5,0x10001
    8000673a:	47d8                	lw	a4,12(a5)
    8000673c:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    8000673e:	554d47b7          	lui	a5,0x554d4
    80006742:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    80006746:	12f71163          	bne	a4,a5,80006868 <virtio_disk_init+0x180>
  *R(VIRTIO_MMIO_STATUS) = status;
    8000674a:	100017b7          	lui	a5,0x10001
    8000674e:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    80006752:	4705                	li	a4,1
    80006754:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80006756:	470d                	li	a4,3
    80006758:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    8000675a:	10001737          	lui	a4,0x10001
    8000675e:	4b18                	lw	a4,16(a4)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    80006760:	c7ffe6b7          	lui	a3,0xc7ffe
    80006764:	75f68693          	addi	a3,a3,1887 # ffffffffc7ffe75f <end+0xffffffff47f6e2ff>
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80006768:	8f75                	and	a4,a4,a3
    8000676a:	100016b7          	lui	a3,0x10001
    8000676e:	d298                	sw	a4,32(a3)
  *R(VIRTIO_MMIO_STATUS) = status;
    80006770:	472d                	li	a4,11
    80006772:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80006774:	07078793          	addi	a5,a5,112
  status = *R(VIRTIO_MMIO_STATUS);
    80006778:	439c                	lw	a5,0(a5)
    8000677a:	0007891b          	sext.w	s2,a5
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    8000677e:	8ba1                	andi	a5,a5,8
    80006780:	0e078a63          	beqz	a5,80006874 <virtio_disk_init+0x18c>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80006784:	100017b7          	lui	a5,0x10001
    80006788:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    8000678c:	43fc                	lw	a5,68(a5)
    8000678e:	2781                	sext.w	a5,a5
    80006790:	0e079863          	bnez	a5,80006880 <virtio_disk_init+0x198>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    80006794:	100017b7          	lui	a5,0x10001
    80006798:	5bdc                	lw	a5,52(a5)
    8000679a:	2781                	sext.w	a5,a5
  if(max == 0)
    8000679c:	0e078863          	beqz	a5,8000688c <virtio_disk_init+0x1a4>
  if(max < NUM)
    800067a0:	471d                	li	a4,7
    800067a2:	0ef77b63          	bgeu	a4,a5,80006898 <virtio_disk_init+0x1b0>
  disk.desc = kalloc();
    800067a6:	bd0fa0ef          	jal	80000b76 <kalloc>
    800067aa:	0001d497          	auipc	s1,0x1d
    800067ae:	ace48493          	addi	s1,s1,-1330 # 80023278 <disk>
    800067b2:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    800067b4:	bc2fa0ef          	jal	80000b76 <kalloc>
    800067b8:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    800067ba:	bbcfa0ef          	jal	80000b76 <kalloc>
    800067be:	87aa                	mv	a5,a0
    800067c0:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    800067c2:	6088                	ld	a0,0(s1)
    800067c4:	0e050063          	beqz	a0,800068a4 <virtio_disk_init+0x1bc>
    800067c8:	0001d717          	auipc	a4,0x1d
    800067cc:	ab873703          	ld	a4,-1352(a4) # 80023280 <disk+0x8>
    800067d0:	cb71                	beqz	a4,800068a4 <virtio_disk_init+0x1bc>
    800067d2:	cbe9                	beqz	a5,800068a4 <virtio_disk_init+0x1bc>
  memset(disk.desc, 0, PGSIZE);
    800067d4:	6605                	lui	a2,0x1
    800067d6:	4581                	li	a1,0
    800067d8:	d52fa0ef          	jal	80000d2a <memset>
  memset(disk.avail, 0, PGSIZE);
    800067dc:	0001d497          	auipc	s1,0x1d
    800067e0:	a9c48493          	addi	s1,s1,-1380 # 80023278 <disk>
    800067e4:	6605                	lui	a2,0x1
    800067e6:	4581                	li	a1,0
    800067e8:	6488                	ld	a0,8(s1)
    800067ea:	d40fa0ef          	jal	80000d2a <memset>
  memset(disk.used, 0, PGSIZE);
    800067ee:	6605                	lui	a2,0x1
    800067f0:	4581                	li	a1,0
    800067f2:	6888                	ld	a0,16(s1)
    800067f4:	d36fa0ef          	jal	80000d2a <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    800067f8:	100017b7          	lui	a5,0x10001
    800067fc:	4721                	li	a4,8
    800067fe:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    80006800:	4098                	lw	a4,0(s1)
    80006802:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    80006806:	40d8                	lw	a4,4(s1)
    80006808:	08e7a223          	sw	a4,132(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    8000680c:	649c                	ld	a5,8(s1)
    8000680e:	0007869b          	sext.w	a3,a5
    80006812:	10001737          	lui	a4,0x10001
    80006816:	08d72823          	sw	a3,144(a4) # 10001090 <_entry-0x6fffef70>
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    8000681a:	9781                	srai	a5,a5,0x20
    8000681c:	08f72a23          	sw	a5,148(a4)
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    80006820:	689c                	ld	a5,16(s1)
    80006822:	0007869b          	sext.w	a3,a5
    80006826:	0ad72023          	sw	a3,160(a4)
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    8000682a:	9781                	srai	a5,a5,0x20
    8000682c:	0af72223          	sw	a5,164(a4)
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    80006830:	4785                	li	a5,1
    80006832:	c37c                	sw	a5,68(a4)
    disk.free[i] = 1;
    80006834:	00f48c23          	sb	a5,24(s1)
    80006838:	00f48ca3          	sb	a5,25(s1)
    8000683c:	00f48d23          	sb	a5,26(s1)
    80006840:	00f48da3          	sb	a5,27(s1)
    80006844:	00f48e23          	sb	a5,28(s1)
    80006848:	00f48ea3          	sb	a5,29(s1)
    8000684c:	00f48f23          	sb	a5,30(s1)
    80006850:	00f48fa3          	sb	a5,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    80006854:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    80006858:	07272823          	sw	s2,112(a4)
}
    8000685c:	60e2                	ld	ra,24(sp)
    8000685e:	6442                	ld	s0,16(sp)
    80006860:	64a2                	ld	s1,8(sp)
    80006862:	6902                	ld	s2,0(sp)
    80006864:	6105                	addi	sp,sp,32
    80006866:	8082                	ret
    panic("could not find virtio disk");
    80006868:	00003517          	auipc	a0,0x3
    8000686c:	4e850513          	addi	a0,a0,1256 # 80009d50 <etext+0xd50>
    80006870:	fe7f90ef          	jal	80000856 <panic>
    panic("virtio disk FEATURES_OK unset");
    80006874:	00003517          	auipc	a0,0x3
    80006878:	4fc50513          	addi	a0,a0,1276 # 80009d70 <etext+0xd70>
    8000687c:	fdbf90ef          	jal	80000856 <panic>
    panic("virtio disk should not be ready");
    80006880:	00003517          	auipc	a0,0x3
    80006884:	51050513          	addi	a0,a0,1296 # 80009d90 <etext+0xd90>
    80006888:	fcff90ef          	jal	80000856 <panic>
    panic("virtio disk has no queue 0");
    8000688c:	00003517          	auipc	a0,0x3
    80006890:	52450513          	addi	a0,a0,1316 # 80009db0 <etext+0xdb0>
    80006894:	fc3f90ef          	jal	80000856 <panic>
    panic("virtio disk max queue too short");
    80006898:	00003517          	auipc	a0,0x3
    8000689c:	53850513          	addi	a0,a0,1336 # 80009dd0 <etext+0xdd0>
    800068a0:	fb7f90ef          	jal	80000856 <panic>
    panic("virtio disk kalloc");
    800068a4:	00003517          	auipc	a0,0x3
    800068a8:	54c50513          	addi	a0,a0,1356 # 80009df0 <etext+0xdf0>
    800068ac:	fabf90ef          	jal	80000856 <panic>

00000000800068b0 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    800068b0:	711d                	addi	sp,sp,-96
    800068b2:	ec86                	sd	ra,88(sp)
    800068b4:	e8a2                	sd	s0,80(sp)
    800068b6:	e4a6                	sd	s1,72(sp)
    800068b8:	e0ca                	sd	s2,64(sp)
    800068ba:	fc4e                	sd	s3,56(sp)
    800068bc:	f852                	sd	s4,48(sp)
    800068be:	f456                	sd	s5,40(sp)
    800068c0:	f05a                	sd	s6,32(sp)
    800068c2:	ec5e                	sd	s7,24(sp)
    800068c4:	e862                	sd	s8,16(sp)
    800068c6:	1080                	addi	s0,sp,96
    800068c8:	89aa                	mv	s3,a0
    800068ca:	8b2e                	mv	s6,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    800068cc:	00c52b83          	lw	s7,12(a0)
    800068d0:	001b9b9b          	slliw	s7,s7,0x1
    800068d4:	1b82                	slli	s7,s7,0x20
    800068d6:	020bdb93          	srli	s7,s7,0x20

  acquire(&disk.vdisk_lock);
    800068da:	0001d517          	auipc	a0,0x1d
    800068de:	ac650513          	addi	a0,a0,-1338 # 800233a0 <disk+0x128>
    800068e2:	b78fa0ef          	jal	80000c5a <acquire>
  for(int i = 0; i < NUM; i++){
    800068e6:	44a1                	li	s1,8
      disk.free[i] = 0;
    800068e8:	0001da97          	auipc	s5,0x1d
    800068ec:	990a8a93          	addi	s5,s5,-1648 # 80023278 <disk>
  for(int i = 0; i < 3; i++){
    800068f0:	4a0d                	li	s4,3
    idx[i] = alloc_desc();
    800068f2:	5c7d                	li	s8,-1
    800068f4:	a095                	j	80006958 <virtio_disk_rw+0xa8>
      disk.free[i] = 0;
    800068f6:	00fa8733          	add	a4,s5,a5
    800068fa:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    800068fe:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    80006900:	0207c563          	bltz	a5,8000692a <virtio_disk_rw+0x7a>
  for(int i = 0; i < 3; i++){
    80006904:	2905                	addiw	s2,s2,1
    80006906:	0611                	addi	a2,a2,4 # 1004 <_entry-0x7fffeffc>
    80006908:	05490c63          	beq	s2,s4,80006960 <virtio_disk_rw+0xb0>
    idx[i] = alloc_desc();
    8000690c:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    8000690e:	0001d717          	auipc	a4,0x1d
    80006912:	96a70713          	addi	a4,a4,-1686 # 80023278 <disk>
    80006916:	4781                	li	a5,0
    if(disk.free[i]){
    80006918:	01874683          	lbu	a3,24(a4)
    8000691c:	fee9                	bnez	a3,800068f6 <virtio_disk_rw+0x46>
  for(int i = 0; i < NUM; i++){
    8000691e:	2785                	addiw	a5,a5,1
    80006920:	0705                	addi	a4,a4,1
    80006922:	fe979be3          	bne	a5,s1,80006918 <virtio_disk_rw+0x68>
    idx[i] = alloc_desc();
    80006926:	0185a023          	sw	s8,0(a1)
      for(int j = 0; j < i; j++)
    8000692a:	01205d63          	blez	s2,80006944 <virtio_disk_rw+0x94>
        free_desc(idx[j]);
    8000692e:	fa042503          	lw	a0,-96(s0)
    80006932:	d41ff0ef          	jal	80006672 <free_desc>
      for(int j = 0; j < i; j++)
    80006936:	4785                	li	a5,1
    80006938:	0127d663          	bge	a5,s2,80006944 <virtio_disk_rw+0x94>
        free_desc(idx[j]);
    8000693c:	fa442503          	lw	a0,-92(s0)
    80006940:	d33ff0ef          	jal	80006672 <free_desc>
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80006944:	0001d597          	auipc	a1,0x1d
    80006948:	a5c58593          	addi	a1,a1,-1444 # 800233a0 <disk+0x128>
    8000694c:	0001d517          	auipc	a0,0x1d
    80006950:	94450513          	addi	a0,a0,-1724 # 80023290 <disk+0x18>
    80006954:	e2afb0ef          	jal	80001f7e <sleep>
  for(int i = 0; i < 3; i++){
    80006958:	fa040613          	addi	a2,s0,-96
    8000695c:	4901                	li	s2,0
    8000695e:	b77d                	j	8000690c <virtio_disk_rw+0x5c>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80006960:	fa042503          	lw	a0,-96(s0)
    80006964:	00451693          	slli	a3,a0,0x4

  if(write)
    80006968:	0001d797          	auipc	a5,0x1d
    8000696c:	91078793          	addi	a5,a5,-1776 # 80023278 <disk>
    80006970:	00451713          	slli	a4,a0,0x4
    80006974:	0a070713          	addi	a4,a4,160
    80006978:	973e                	add	a4,a4,a5
    8000697a:	01603633          	snez	a2,s6
    8000697e:	c710                	sw	a2,8(a4)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    80006980:	00072623          	sw	zero,12(a4)
  buf0->sector = sector;
    80006984:	01773823          	sd	s7,16(a4)

  disk.desc[idx[0]].addr = (uint64) buf0;
    80006988:	6398                	ld	a4,0(a5)
    8000698a:	9736                	add	a4,a4,a3
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    8000698c:	0a868613          	addi	a2,a3,168 # 100010a8 <_entry-0x6fffef58>
    80006990:	963e                	add	a2,a2,a5
  disk.desc[idx[0]].addr = (uint64) buf0;
    80006992:	e310                	sd	a2,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    80006994:	6390                	ld	a2,0(a5)
    80006996:	00d60833          	add	a6,a2,a3
    8000699a:	4741                	li	a4,16
    8000699c:	00e82423          	sw	a4,8(a6)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    800069a0:	4585                	li	a1,1
    800069a2:	00b81623          	sh	a1,12(a6)
  disk.desc[idx[0]].next = idx[1];
    800069a6:	fa442703          	lw	a4,-92(s0)
    800069aa:	00e81723          	sh	a4,14(a6)

  disk.desc[idx[1]].addr = (uint64) b->data;
    800069ae:	0712                	slli	a4,a4,0x4
    800069b0:	963a                	add	a2,a2,a4
    800069b2:	05898813          	addi	a6,s3,88
    800069b6:	01063023          	sd	a6,0(a2)
  disk.desc[idx[1]].len = BSIZE;
    800069ba:	0007b883          	ld	a7,0(a5)
    800069be:	9746                	add	a4,a4,a7
    800069c0:	40000613          	li	a2,1024
    800069c4:	c710                	sw	a2,8(a4)
  if(write)
    800069c6:	001b3613          	seqz	a2,s6
    800069ca:	0016161b          	slliw	a2,a2,0x1
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    800069ce:	8e4d                	or	a2,a2,a1
    800069d0:	00c71623          	sh	a2,12(a4)
  disk.desc[idx[1]].next = idx[2];
    800069d4:	fa842603          	lw	a2,-88(s0)
    800069d8:	00c71723          	sh	a2,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    800069dc:	00451813          	slli	a6,a0,0x4
    800069e0:	02080813          	addi	a6,a6,32
    800069e4:	983e                	add	a6,a6,a5
    800069e6:	577d                	li	a4,-1
    800069e8:	00e80823          	sb	a4,16(a6)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    800069ec:	0612                	slli	a2,a2,0x4
    800069ee:	98b2                	add	a7,a7,a2
    800069f0:	03068713          	addi	a4,a3,48
    800069f4:	973e                	add	a4,a4,a5
    800069f6:	00e8b023          	sd	a4,0(a7)
  disk.desc[idx[2]].len = 1;
    800069fa:	6398                	ld	a4,0(a5)
    800069fc:	9732                	add	a4,a4,a2
    800069fe:	c70c                	sw	a1,8(a4)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    80006a00:	4689                	li	a3,2
    80006a02:	00d71623          	sh	a3,12(a4)
  disk.desc[idx[2]].next = 0;
    80006a06:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    80006a0a:	00b9a223          	sw	a1,4(s3)
  disk.info[idx[0]].b = b;
    80006a0e:	01383423          	sd	s3,8(a6)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    80006a12:	6794                	ld	a3,8(a5)
    80006a14:	0026d703          	lhu	a4,2(a3)
    80006a18:	8b1d                	andi	a4,a4,7
    80006a1a:	0706                	slli	a4,a4,0x1
    80006a1c:	96ba                	add	a3,a3,a4
    80006a1e:	00a69223          	sh	a0,4(a3)

  __sync_synchronize();
    80006a22:	0330000f          	fence	rw,rw

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    80006a26:	6798                	ld	a4,8(a5)
    80006a28:	00275783          	lhu	a5,2(a4)
    80006a2c:	2785                	addiw	a5,a5,1
    80006a2e:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    80006a32:	0330000f          	fence	rw,rw

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80006a36:	100017b7          	lui	a5,0x10001
    80006a3a:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    80006a3e:	0049a783          	lw	a5,4(s3)
    sleep(b, &disk.vdisk_lock);
    80006a42:	0001d917          	auipc	s2,0x1d
    80006a46:	95e90913          	addi	s2,s2,-1698 # 800233a0 <disk+0x128>
  while(b->disk == 1) {
    80006a4a:	84ae                	mv	s1,a1
    80006a4c:	00b79a63          	bne	a5,a1,80006a60 <virtio_disk_rw+0x1b0>
    sleep(b, &disk.vdisk_lock);
    80006a50:	85ca                	mv	a1,s2
    80006a52:	854e                	mv	a0,s3
    80006a54:	d2afb0ef          	jal	80001f7e <sleep>
  while(b->disk == 1) {
    80006a58:	0049a783          	lw	a5,4(s3)
    80006a5c:	fe978ae3          	beq	a5,s1,80006a50 <virtio_disk_rw+0x1a0>
  }

  disk.info[idx[0]].b = 0;
    80006a60:	fa042903          	lw	s2,-96(s0)
    80006a64:	00491713          	slli	a4,s2,0x4
    80006a68:	02070713          	addi	a4,a4,32
    80006a6c:	0001d797          	auipc	a5,0x1d
    80006a70:	80c78793          	addi	a5,a5,-2036 # 80023278 <disk>
    80006a74:	97ba                	add	a5,a5,a4
    80006a76:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    80006a7a:	0001c997          	auipc	s3,0x1c
    80006a7e:	7fe98993          	addi	s3,s3,2046 # 80023278 <disk>
    80006a82:	00491713          	slli	a4,s2,0x4
    80006a86:	0009b783          	ld	a5,0(s3)
    80006a8a:	97ba                	add	a5,a5,a4
    80006a8c:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    80006a90:	854a                	mv	a0,s2
    80006a92:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    80006a96:	bddff0ef          	jal	80006672 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    80006a9a:	8885                	andi	s1,s1,1
    80006a9c:	f0fd                	bnez	s1,80006a82 <virtio_disk_rw+0x1d2>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    80006a9e:	0001d517          	auipc	a0,0x1d
    80006aa2:	90250513          	addi	a0,a0,-1790 # 800233a0 <disk+0x128>
    80006aa6:	a48fa0ef          	jal	80000cee <release>
}
    80006aaa:	60e6                	ld	ra,88(sp)
    80006aac:	6446                	ld	s0,80(sp)
    80006aae:	64a6                	ld	s1,72(sp)
    80006ab0:	6906                	ld	s2,64(sp)
    80006ab2:	79e2                	ld	s3,56(sp)
    80006ab4:	7a42                	ld	s4,48(sp)
    80006ab6:	7aa2                	ld	s5,40(sp)
    80006ab8:	7b02                	ld	s6,32(sp)
    80006aba:	6be2                	ld	s7,24(sp)
    80006abc:	6c42                	ld	s8,16(sp)
    80006abe:	6125                	addi	sp,sp,96
    80006ac0:	8082                	ret

0000000080006ac2 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    80006ac2:	1101                	addi	sp,sp,-32
    80006ac4:	ec06                	sd	ra,24(sp)
    80006ac6:	e822                	sd	s0,16(sp)
    80006ac8:	e426                	sd	s1,8(sp)
    80006aca:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    80006acc:	0001c497          	auipc	s1,0x1c
    80006ad0:	7ac48493          	addi	s1,s1,1964 # 80023278 <disk>
    80006ad4:	0001d517          	auipc	a0,0x1d
    80006ad8:	8cc50513          	addi	a0,a0,-1844 # 800233a0 <disk+0x128>
    80006adc:	97efa0ef          	jal	80000c5a <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    80006ae0:	100017b7          	lui	a5,0x10001
    80006ae4:	53bc                	lw	a5,96(a5)
    80006ae6:	8b8d                	andi	a5,a5,3
    80006ae8:	10001737          	lui	a4,0x10001
    80006aec:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    80006aee:	0330000f          	fence	rw,rw

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    80006af2:	689c                	ld	a5,16(s1)
    80006af4:	0204d703          	lhu	a4,32(s1)
    80006af8:	0027d783          	lhu	a5,2(a5) # 10001002 <_entry-0x6fffeffe>
    80006afc:	04f70863          	beq	a4,a5,80006b4c <virtio_disk_intr+0x8a>
    __sync_synchronize();
    80006b00:	0330000f          	fence	rw,rw
    int id = disk.used->ring[disk.used_idx % NUM].id;
    80006b04:	6898                	ld	a4,16(s1)
    80006b06:	0204d783          	lhu	a5,32(s1)
    80006b0a:	8b9d                	andi	a5,a5,7
    80006b0c:	078e                	slli	a5,a5,0x3
    80006b0e:	97ba                	add	a5,a5,a4
    80006b10:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    80006b12:	00479713          	slli	a4,a5,0x4
    80006b16:	02070713          	addi	a4,a4,32 # 10001020 <_entry-0x6fffefe0>
    80006b1a:	9726                	add	a4,a4,s1
    80006b1c:	01074703          	lbu	a4,16(a4)
    80006b20:	e329                	bnez	a4,80006b62 <virtio_disk_intr+0xa0>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    80006b22:	0792                	slli	a5,a5,0x4
    80006b24:	02078793          	addi	a5,a5,32
    80006b28:	97a6                	add	a5,a5,s1
    80006b2a:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    80006b2c:	00052223          	sw	zero,4(a0)
    wakeup(b);
    80006b30:	c9afb0ef          	jal	80001fca <wakeup>

    disk.used_idx += 1;
    80006b34:	0204d783          	lhu	a5,32(s1)
    80006b38:	2785                	addiw	a5,a5,1
    80006b3a:	17c2                	slli	a5,a5,0x30
    80006b3c:	93c1                	srli	a5,a5,0x30
    80006b3e:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    80006b42:	6898                	ld	a4,16(s1)
    80006b44:	00275703          	lhu	a4,2(a4)
    80006b48:	faf71ce3          	bne	a4,a5,80006b00 <virtio_disk_intr+0x3e>
  }

  release(&disk.vdisk_lock);
    80006b4c:	0001d517          	auipc	a0,0x1d
    80006b50:	85450513          	addi	a0,a0,-1964 # 800233a0 <disk+0x128>
    80006b54:	99afa0ef          	jal	80000cee <release>
}
    80006b58:	60e2                	ld	ra,24(sp)
    80006b5a:	6442                	ld	s0,16(sp)
    80006b5c:	64a2                	ld	s1,8(sp)
    80006b5e:	6105                	addi	sp,sp,32
    80006b60:	8082                	ret
      panic("virtio_disk_intr status");
    80006b62:	00003517          	auipc	a0,0x3
    80006b66:	2a650513          	addi	a0,a0,678 # 80009e08 <etext+0xe08>
    80006b6a:	cedf90ef          	jal	80000856 <panic>

0000000080006b6e <cslog_init>:
  safestrcpy(e->name, p->name, CS_NM);
}

void
cslog_init(void)
{
    80006b6e:	1141                	addi	sp,sp,-16
    80006b70:	e406                	sd	ra,8(sp)
    80006b72:	e022                	sd	s0,0(sp)
    80006b74:	0800                	addi	s0,sp,16
  ringbuf_init(&cs_rb, "cslog", sizeof(struct cs_event));
    80006b76:	03000613          	li	a2,48
    80006b7a:	00003597          	auipc	a1,0x3
    80006b7e:	2a658593          	addi	a1,a1,678 # 80009e20 <etext+0xe20>
    80006b82:	0001d517          	auipc	a0,0x1d
    80006b86:	83650513          	addi	a0,a0,-1994 # 800233b8 <cs_rb>
    80006b8a:	242000ef          	jal	80006dcc <ringbuf_init>
  printf("CS sizeof(cs_event)=%ld RB_MAX_ELEM=%d\n", sizeof(struct cs_event), RB_MAX_ELEM);
    80006b8e:	10000613          	li	a2,256
    80006b92:	03000593          	li	a1,48
    80006b96:	00003517          	auipc	a0,0x3
    80006b9a:	29250513          	addi	a0,a0,658 # 80009e28 <etext+0xe28>
    80006b9e:	98ff90ef          	jal	8000052c <printf>
}
    80006ba2:	60a2                	ld	ra,8(sp)
    80006ba4:	6402                	ld	s0,0(sp)
    80006ba6:	0141                	addi	sp,sp,16
    80006ba8:	8082                	ret

0000000080006baa <cslog_push>:

void
cslog_push(struct cs_event *e)
{
    80006baa:	1141                	addi	sp,sp,-16
    80006bac:	e406                	sd	ra,8(sp)
    80006bae:	e022                	sd	s0,0(sp)
    80006bb0:	0800                	addi	s0,sp,16
    80006bb2:	85aa                	mv	a1,a0
  e->seq = ++cs_seq;
    80006bb4:	00003717          	auipc	a4,0x3
    80006bb8:	49c70713          	addi	a4,a4,1180 # 8000a050 <cs_seq>
    80006bbc:	631c                	ld	a5,0(a4)
    80006bbe:	0785                	addi	a5,a5,1
    80006bc0:	e31c                	sd	a5,0(a4)
    80006bc2:	e11c                	sd	a5,0(a0)
  ringbuf_push(&cs_rb, e);
    80006bc4:	0001c517          	auipc	a0,0x1c
    80006bc8:	7f450513          	addi	a0,a0,2036 # 800233b8 <cs_rb>
    80006bcc:	234000ef          	jal	80006e00 <ringbuf_push>
}
    80006bd0:	60a2                	ld	ra,8(sp)
    80006bd2:	6402                	ld	s0,0(sp)
    80006bd4:	0141                	addi	sp,sp,16
    80006bd6:	8082                	ret

0000000080006bd8 <cslog_read_many>:

int
cslog_read_many(struct cs_event *out, int max)
{
    80006bd8:	1141                	addi	sp,sp,-16
    80006bda:	e406                	sd	ra,8(sp)
    80006bdc:	e022                	sd	s0,0(sp)
    80006bde:	0800                	addi	s0,sp,16
    80006be0:	862e                	mv	a2,a1
  return ringbuf_read_many(&cs_rb, out, max);
    80006be2:	85aa                	mv	a1,a0
    80006be4:	0001c517          	auipc	a0,0x1c
    80006be8:	7d450513          	addi	a0,a0,2004 # 800233b8 <cs_rb>
    80006bec:	280000ef          	jal	80006e6c <ringbuf_read_many>
}
    80006bf0:	60a2                	ld	ra,8(sp)
    80006bf2:	6402                	ld	s0,0(sp)
    80006bf4:	0141                	addi	sp,sp,16
    80006bf6:	8082                	ret

0000000080006bf8 <cslog_run_start>:

void
cslog_run_start(struct proc *p)
{
  if(p == 0) return;
    80006bf8:	c14d                	beqz	a0,80006c9a <cslog_run_start+0xa2>
{
    80006bfa:	715d                	addi	sp,sp,-80
    80006bfc:	e486                	sd	ra,72(sp)
    80006bfe:	e0a2                	sd	s0,64(sp)
    80006c00:	fc26                	sd	s1,56(sp)
    80006c02:	0880                	addi	s0,sp,80
    80006c04:	84aa                	mv	s1,a0
  if(p->pid <= 0) return;
    80006c06:	591c                	lw	a5,48(a0)
    80006c08:	00f05563          	blez	a5,80006c12 <cslog_run_start+0x1a>
  if(p->name[0] == 0) return;
    80006c0c:	15854783          	lbu	a5,344(a0)
    80006c10:	e791                	bnez	a5,80006c1c <cslog_run_start+0x24>

  struct cs_event e;
  fill_from_proc(&e, p);
  e.type = CS_RUN_START;
  cslog_push(&e);
    80006c12:	60a6                	ld	ra,72(sp)
    80006c14:	6406                	ld	s0,64(sp)
    80006c16:	74e2                	ld	s1,56(sp)
    80006c18:	6161                	addi	sp,sp,80
    80006c1a:	8082                	ret
    80006c1c:	f84a                	sd	s2,48(sp)
  if(strncmp(p->name, "cscat", 5) == 0) return;
    80006c1e:	15850913          	addi	s2,a0,344
    80006c22:	4615                	li	a2,5
    80006c24:	00003597          	auipc	a1,0x3
    80006c28:	22c58593          	addi	a1,a1,556 # 80009e50 <etext+0xe50>
    80006c2c:	854a                	mv	a0,s2
    80006c2e:	9d0fa0ef          	jal	80000dfe <strncmp>
    80006c32:	e119                	bnez	a0,80006c38 <cslog_run_start+0x40>
    80006c34:	7942                	ld	s2,48(sp)
    80006c36:	bff1                	j	80006c12 <cslog_run_start+0x1a>
  if(strncmp(p->name, "csexport", 8) == 0) return;
    80006c38:	4621                	li	a2,8
    80006c3a:	00003597          	auipc	a1,0x3
    80006c3e:	21e58593          	addi	a1,a1,542 # 80009e58 <etext+0xe58>
    80006c42:	854a                	mv	a0,s2
    80006c44:	9bafa0ef          	jal	80000dfe <strncmp>
    80006c48:	e119                	bnez	a0,80006c4e <cslog_run_start+0x56>
    80006c4a:	7942                	ld	s2,48(sp)
    80006c4c:	b7d9                	j	80006c12 <cslog_run_start+0x1a>
  memset(e, 0, sizeof(*e));
    80006c4e:	03000613          	li	a2,48
    80006c52:	4581                	li	a1,0
    80006c54:	fb040513          	addi	a0,s0,-80
    80006c58:	8d2fa0ef          	jal	80000d2a <memset>
  e->ticks = ticks;
    80006c5c:	00003797          	auipc	a5,0x3
    80006c60:	3ec7a783          	lw	a5,1004(a5) # 8000a048 <ticks>
    80006c64:	faf42c23          	sw	a5,-72(s0)
  e->cpu   = cpuid();
    80006c68:	ccdfa0ef          	jal	80001934 <cpuid>
    80006c6c:	faa42e23          	sw	a0,-68(s0)
  e->pid   = p->pid;
    80006c70:	589c                	lw	a5,48(s1)
    80006c72:	fcf42223          	sw	a5,-60(s0)
  e->state = p->state;
    80006c76:	4c9c                	lw	a5,24(s1)
    80006c78:	fcf42423          	sw	a5,-56(s0)
  safestrcpy(e->name, p->name, CS_NM);
    80006c7c:	4641                	li	a2,16
    80006c7e:	85ca                	mv	a1,s2
    80006c80:	fcc40513          	addi	a0,s0,-52
    80006c84:	9fafa0ef          	jal	80000e7e <safestrcpy>
  e.type = CS_RUN_START;
    80006c88:	4785                	li	a5,1
    80006c8a:	fcf42023          	sw	a5,-64(s0)
  cslog_push(&e);
    80006c8e:	fb040513          	addi	a0,s0,-80
    80006c92:	f19ff0ef          	jal	80006baa <cslog_push>
    80006c96:	7942                	ld	s2,48(sp)
    80006c98:	bfad                	j	80006c12 <cslog_run_start+0x1a>
    80006c9a:	8082                	ret

0000000080006c9c <sys_csread>:
#include "cslog.h"


uint64
sys_csread(void)
{
    80006c9c:	81010113          	addi	sp,sp,-2032
    80006ca0:	7e113423          	sd	ra,2024(sp)
    80006ca4:	7e813023          	sd	s0,2016(sp)
    80006ca8:	7c913c23          	sd	s1,2008(sp)
    80006cac:	7d213823          	sd	s2,2000(sp)
    80006cb0:	7f010413          	addi	s0,sp,2032
    80006cb4:	bc010113          	addi	sp,sp,-1088
  uint64 uaddr = 0;
    80006cb8:	fc043c23          	sd	zero,-40(s0)
  int max = 0;
    80006cbc:	fc042a23          	sw	zero,-44(s0)

  // ✅ عندك argaddr/argint void، فبنستدعيهم بدون if
  argaddr(0, &uaddr);
    80006cc0:	fd840593          	addi	a1,s0,-40
    80006cc4:	4501                	li	a0,0
    80006cc6:	be1fb0ef          	jal	800028a6 <argaddr>
  argint(1, &max);
    80006cca:	fd440593          	addi	a1,s0,-44
    80006cce:	4505                	li	a0,1
    80006cd0:	bbbfb0ef          	jal	8000288a <argint>

  if(max <= 0) return 0;
    80006cd4:	fd442783          	lw	a5,-44(s0)
    80006cd8:	4501                	li	a0,0
    80006cda:	04f05463          	blez	a5,80006d22 <sys_csread+0x86>
  if(max > 64) max = 64;
    80006cde:	04000713          	li	a4,64
    80006ce2:	00f75463          	bge	a4,a5,80006cea <sys_csread+0x4e>
    80006ce6:	fce42a23          	sw	a4,-44(s0)

  struct cs_event tmp[64];
  int n = cslog_read_many(tmp, max);
    80006cea:	80040493          	addi	s1,s0,-2048
    80006cee:	1481                	addi	s1,s1,-32
    80006cf0:	bf048493          	addi	s1,s1,-1040
    80006cf4:	fd442583          	lw	a1,-44(s0)
    80006cf8:	8526                	mv	a0,s1
    80006cfa:	edfff0ef          	jal	80006bd8 <cslog_read_many>
    80006cfe:	892a                	mv	s2,a0

  int bytes = n * (int)sizeof(struct cs_event);
  if(copyout(myproc()->pagetable, uaddr, (char*)tmp, bytes) < 0)
    80006d00:	c69fa0ef          	jal	80001968 <myproc>
  int bytes = n * (int)sizeof(struct cs_event);
    80006d04:	0019169b          	slliw	a3,s2,0x1
    80006d08:	012686bb          	addw	a3,a3,s2
  if(copyout(myproc()->pagetable, uaddr, (char*)tmp, bytes) < 0)
    80006d0c:	0046969b          	slliw	a3,a3,0x4
    80006d10:	8626                	mv	a2,s1
    80006d12:	fd843583          	ld	a1,-40(s0)
    80006d16:	6928                	ld	a0,80(a0)
    80006d18:	977fa0ef          	jal	8000168e <copyout>
    80006d1c:	02054063          	bltz	a0,80006d3c <sys_csread+0xa0>
    return -1;

  return n;
    80006d20:	854a                	mv	a0,s2
}
    80006d22:	44010113          	addi	sp,sp,1088
    80006d26:	7e813083          	ld	ra,2024(sp)
    80006d2a:	7e013403          	ld	s0,2016(sp)
    80006d2e:	7d813483          	ld	s1,2008(sp)
    80006d32:	7d013903          	ld	s2,2000(sp)
    80006d36:	7f010113          	addi	sp,sp,2032
    80006d3a:	8082                	ret
    return -1;
    80006d3c:	557d                	li	a0,-1
    80006d3e:	b7d5                	j	80006d22 <sys_csread+0x86>

0000000080006d40 <sys_memread>:
#include "memevent.h"
#include "memlog.h"

uint64
sys_memread(void)
{
    80006d40:	95010113          	addi	sp,sp,-1712
    80006d44:	6a113423          	sd	ra,1704(sp)
    80006d48:	6a813023          	sd	s0,1696(sp)
    80006d4c:	6b010413          	addi	s0,sp,1712
  uint64 uaddr = 0;
    80006d50:	fc043c23          	sd	zero,-40(s0)
  int max = 0;
    80006d54:	fc042a23          	sw	zero,-44(s0)

  argaddr(0, &uaddr);
    80006d58:	fd840593          	addi	a1,s0,-40
    80006d5c:	4501                	li	a0,0
    80006d5e:	b49fb0ef          	jal	800028a6 <argaddr>
  argint(1, &max);
    80006d62:	fd440593          	addi	a1,s0,-44
    80006d66:	4505                	li	a0,1
    80006d68:	b23fb0ef          	jal	8000288a <argint>

  if(max <= 0)
    80006d6c:	fd442783          	lw	a5,-44(s0)
    return 0;
    80006d70:	4501                	li	a0,0
  if(max <= 0)
    80006d72:	04f05263          	blez	a5,80006db6 <sys_memread+0x76>
    80006d76:	68913c23          	sd	s1,1688(sp)
  if(max > 16)
    80006d7a:	4741                	li	a4,16
    80006d7c:	00f75463          	bge	a4,a5,80006d84 <sys_memread+0x44>
    max = 16;
    80006d80:	fce42a23          	sw	a4,-44(s0)

  struct mem_event tmp[16];
  int n = memlog_read_many(tmp, max);
    80006d84:	fd442583          	lw	a1,-44(s0)
    80006d88:	95040513          	addi	a0,s0,-1712
    80006d8c:	749000ef          	jal	80007cd4 <memlog_read_many>
    80006d90:	84aa                	mv	s1,a0

  int bytes = n * (int)sizeof(struct mem_event);
  if(copyout(myproc()->pagetable, uaddr, (char *)tmp, bytes) < 0)
    80006d92:	bd7fa0ef          	jal	80001968 <myproc>
    80006d96:	06800693          	li	a3,104
    80006d9a:	029686bb          	mulw	a3,a3,s1
    80006d9e:	95040613          	addi	a2,s0,-1712
    80006da2:	fd843583          	ld	a1,-40(s0)
    80006da6:	6928                	ld	a0,80(a0)
    80006da8:	8e7fa0ef          	jal	8000168e <copyout>
    80006dac:	00054c63          	bltz	a0,80006dc4 <sys_memread+0x84>
    return -1;

  return n;
    80006db0:	8526                	mv	a0,s1
    80006db2:	69813483          	ld	s1,1688(sp)
    80006db6:	6a813083          	ld	ra,1704(sp)
    80006dba:	6a013403          	ld	s0,1696(sp)
    80006dbe:	6b010113          	addi	sp,sp,1712
    80006dc2:	8082                	ret
    return -1;
    80006dc4:	557d                	li	a0,-1
    80006dc6:	69813483          	ld	s1,1688(sp)
    80006dca:	b7f5                	j	80006db6 <sys_memread+0x76>

0000000080006dcc <ringbuf_init>:
  return (void *)(rb->buf + idx * rb->elem_size);
}

void
ringbuf_init(struct ringbuf *rb, char *name, uint elem_size)
{
    80006dcc:	1101                	addi	sp,sp,-32
    80006dce:	ec06                	sd	ra,24(sp)
    80006dd0:	e822                	sd	s0,16(sp)
    80006dd2:	e426                	sd	s1,8(sp)
    80006dd4:	e04a                	sd	s2,0(sp)
    80006dd6:	1000                	addi	s0,sp,32
    80006dd8:	84aa                	mv	s1,a0
    80006dda:	8932                	mv	s2,a2
  initlock(&rb->lock, name);
    80006ddc:	df5f90ef          	jal	80000bd0 <initlock>
  rb->head = 0;
    80006de0:	0004ac23          	sw	zero,24(s1)
  rb->tail = 0;
    80006de4:	0004ae23          	sw	zero,28(s1)
  rb->count = 0;
    80006de8:	0204a023          	sw	zero,32(s1)
  rb->seq = 0;
    80006dec:	0204b423          	sd	zero,40(s1)
  rb->elem_size = elem_size;
    80006df0:	0324a223          	sw	s2,36(s1)
}
    80006df4:	60e2                	ld	ra,24(sp)
    80006df6:	6442                	ld	s0,16(sp)
    80006df8:	64a2                	ld	s1,8(sp)
    80006dfa:	6902                	ld	s2,0(sp)
    80006dfc:	6105                	addi	sp,sp,32
    80006dfe:	8082                	ret

0000000080006e00 <ringbuf_push>:

int
ringbuf_push(struct ringbuf *rb, void *elem)
{
    80006e00:	1101                	addi	sp,sp,-32
    80006e02:	ec06                	sd	ra,24(sp)
    80006e04:	e822                	sd	s0,16(sp)
    80006e06:	e426                	sd	s1,8(sp)
    80006e08:	e04a                	sd	s2,0(sp)
    80006e0a:	1000                	addi	s0,sp,32
    80006e0c:	84aa                	mv	s1,a0
    80006e0e:	892e                	mv	s2,a1
  acquire(&rb->lock);
    80006e10:	e4bf90ef          	jal	80000c5a <acquire>

  if(rb->count == RB_CAP){
    80006e14:	5098                	lw	a4,32(s1)
    80006e16:	20000793          	li	a5,512
    80006e1a:	04f70063          	beq	a4,a5,80006e5a <ringbuf_push+0x5a>
  return (void *)(rb->buf + idx * rb->elem_size);
    80006e1e:	50d0                	lw	a2,36(s1)
    80006e20:	03048513          	addi	a0,s1,48
    80006e24:	4c9c                	lw	a5,24(s1)
    80006e26:	02c787bb          	mulw	a5,a5,a2
    80006e2a:	1782                	slli	a5,a5,0x20
    80006e2c:	9381                	srli	a5,a5,0x20
    rb->tail = (rb->tail + 1) % RB_CAP;
    rb->count--;
  }

  memmove(slot_ptr(rb, rb->head), elem, rb->elem_size);
    80006e2e:	85ca                	mv	a1,s2
    80006e30:	953e                	add	a0,a0,a5
    80006e32:	f59f90ef          	jal	80000d8a <memmove>
  rb->head = (rb->head + 1) % RB_CAP;
    80006e36:	4c9c                	lw	a5,24(s1)
    80006e38:	2785                	addiw	a5,a5,1
    80006e3a:	1ff7f793          	andi	a5,a5,511
    80006e3e:	cc9c                	sw	a5,24(s1)
  rb->count++;
    80006e40:	509c                	lw	a5,32(s1)
    80006e42:	2785                	addiw	a5,a5,1
    80006e44:	d09c                	sw	a5,32(s1)

  release(&rb->lock);
    80006e46:	8526                	mv	a0,s1
    80006e48:	ea7f90ef          	jal	80000cee <release>
  return 0;
}
    80006e4c:	4501                	li	a0,0
    80006e4e:	60e2                	ld	ra,24(sp)
    80006e50:	6442                	ld	s0,16(sp)
    80006e52:	64a2                	ld	s1,8(sp)
    80006e54:	6902                	ld	s2,0(sp)
    80006e56:	6105                	addi	sp,sp,32
    80006e58:	8082                	ret
    rb->tail = (rb->tail + 1) % RB_CAP;
    80006e5a:	4cdc                	lw	a5,28(s1)
    80006e5c:	2785                	addiw	a5,a5,1
    80006e5e:	1ff7f793          	andi	a5,a5,511
    80006e62:	ccdc                	sw	a5,28(s1)
    rb->count--;
    80006e64:	1ff00793          	li	a5,511
    80006e68:	d09c                	sw	a5,32(s1)
    80006e6a:	bf55                	j	80006e1e <ringbuf_push+0x1e>

0000000080006e6c <ringbuf_read_many>:
ringbuf_read_many(struct ringbuf *rb, void *out, int max)
{
  int n = 0;
  char *dst = (char *)out;

  if(max <= 0)
    80006e6c:	06c05d63          	blez	a2,80006ee6 <ringbuf_read_many+0x7a>
{
    80006e70:	7139                	addi	sp,sp,-64
    80006e72:	fc06                	sd	ra,56(sp)
    80006e74:	f822                	sd	s0,48(sp)
    80006e76:	f426                	sd	s1,40(sp)
    80006e78:	f04a                	sd	s2,32(sp)
    80006e7a:	ec4e                	sd	s3,24(sp)
    80006e7c:	e852                	sd	s4,16(sp)
    80006e7e:	e456                	sd	s5,8(sp)
    80006e80:	0080                	addi	s0,sp,64
    80006e82:	84aa                	mv	s1,a0
    80006e84:	8a2e                	mv	s4,a1
    80006e86:	89b2                	mv	s3,a2
    return 0;

  acquire(&rb->lock);
    80006e88:	dd3f90ef          	jal	80000c5a <acquire>
  int n = 0;
    80006e8c:	4901                	li	s2,0
  return (void *)(rb->buf + idx * rb->elem_size);
    80006e8e:	03048a93          	addi	s5,s1,48
  while(n < max && rb->count > 0){
    80006e92:	509c                	lw	a5,32(s1)
    80006e94:	c7b9                	beqz	a5,80006ee2 <ringbuf_read_many+0x76>
    memmove(dst + n * rb->elem_size, slot_ptr(rb, rb->tail), rb->elem_size);
    80006e96:	50d0                	lw	a2,36(s1)
  return (void *)(rb->buf + idx * rb->elem_size);
    80006e98:	4ccc                	lw	a1,28(s1)
    80006e9a:	02c585bb          	mulw	a1,a1,a2
    80006e9e:	1582                	slli	a1,a1,0x20
    80006ea0:	9181                	srli	a1,a1,0x20
    memmove(dst + n * rb->elem_size, slot_ptr(rb, rb->tail), rb->elem_size);
    80006ea2:	02c9053b          	mulw	a0,s2,a2
    80006ea6:	1502                	slli	a0,a0,0x20
    80006ea8:	9101                	srli	a0,a0,0x20
    80006eaa:	95d6                	add	a1,a1,s5
    80006eac:	9552                	add	a0,a0,s4
    80006eae:	eddf90ef          	jal	80000d8a <memmove>
    rb->tail = (rb->tail + 1) % RB_CAP;
    80006eb2:	4cdc                	lw	a5,28(s1)
    80006eb4:	2785                	addiw	a5,a5,1
    80006eb6:	1ff7f793          	andi	a5,a5,511
    80006eba:	ccdc                	sw	a5,28(s1)
    rb->count--;
    80006ebc:	509c                	lw	a5,32(s1)
    80006ebe:	37fd                	addiw	a5,a5,-1
    80006ec0:	d09c                	sw	a5,32(s1)
    n++;
    80006ec2:	2905                	addiw	s2,s2,1
  while(n < max && rb->count > 0){
    80006ec4:	fd2997e3          	bne	s3,s2,80006e92 <ringbuf_read_many+0x26>
  }
  release(&rb->lock);
    80006ec8:	8526                	mv	a0,s1
    80006eca:	e25f90ef          	jal	80000cee <release>

  return n;
    80006ece:	854e                	mv	a0,s3
}
    80006ed0:	70e2                	ld	ra,56(sp)
    80006ed2:	7442                	ld	s0,48(sp)
    80006ed4:	74a2                	ld	s1,40(sp)
    80006ed6:	7902                	ld	s2,32(sp)
    80006ed8:	69e2                	ld	s3,24(sp)
    80006eda:	6a42                	ld	s4,16(sp)
    80006edc:	6aa2                	ld	s5,8(sp)
    80006ede:	6121                	addi	sp,sp,64
    80006ee0:	8082                	ret
    80006ee2:	89ca                	mv	s3,s2
    80006ee4:	b7d5                	j	80006ec8 <ringbuf_read_many+0x5c>
    return 0;
    80006ee6:	4501                	li	a0,0
}
    80006ee8:	8082                	ret

0000000080006eea <ringbuf_pop>:

int
ringbuf_pop(struct ringbuf *rb, void *dst)
{
    80006eea:	1101                	addi	sp,sp,-32
    80006eec:	ec06                	sd	ra,24(sp)
    80006eee:	e822                	sd	s0,16(sp)
    80006ef0:	e426                	sd	s1,8(sp)
    80006ef2:	e04a                	sd	s2,0(sp)
    80006ef4:	1000                	addi	s0,sp,32
    80006ef6:	84aa                	mv	s1,a0
    80006ef8:	892e                	mv	s2,a1
  acquire(&rb->lock);
    80006efa:	d61f90ef          	jal	80000c5a <acquire>

  if(rb->count == 0){
    80006efe:	509c                	lw	a5,32(s1)
    80006f00:	cf9d                	beqz	a5,80006f3e <ringbuf_pop+0x54>
  return (void *)(rb->buf + idx * rb->elem_size);
    80006f02:	50d0                	lw	a2,36(s1)
    80006f04:	03048593          	addi	a1,s1,48
    80006f08:	4cdc                	lw	a5,28(s1)
    80006f0a:	02c787bb          	mulw	a5,a5,a2
    80006f0e:	1782                	slli	a5,a5,0x20
    80006f10:	9381                	srli	a5,a5,0x20
    release(&rb->lock);
    return -1;
  }

  memmove(dst, slot_ptr(rb, rb->tail), rb->elem_size);
    80006f12:	95be                	add	a1,a1,a5
    80006f14:	854a                	mv	a0,s2
    80006f16:	e75f90ef          	jal	80000d8a <memmove>
  rb->tail = (rb->tail + 1) % RB_CAP;
    80006f1a:	4cdc                	lw	a5,28(s1)
    80006f1c:	2785                	addiw	a5,a5,1
    80006f1e:	1ff7f793          	andi	a5,a5,511
    80006f22:	ccdc                	sw	a5,28(s1)
  rb->count--;
    80006f24:	509c                	lw	a5,32(s1)
    80006f26:	37fd                	addiw	a5,a5,-1
    80006f28:	d09c                	sw	a5,32(s1)

  release(&rb->lock);
    80006f2a:	8526                	mv	a0,s1
    80006f2c:	dc3f90ef          	jal	80000cee <release>
  return 0;
    80006f30:	4501                	li	a0,0
    80006f32:	60e2                	ld	ra,24(sp)
    80006f34:	6442                	ld	s0,16(sp)
    80006f36:	64a2                	ld	s1,8(sp)
    80006f38:	6902                	ld	s2,0(sp)
    80006f3a:	6105                	addi	sp,sp,32
    80006f3c:	8082                	ret
    release(&rb->lock);
    80006f3e:	8526                	mv	a0,s1
    80006f40:	daff90ef          	jal	80000cee <release>
    return -1;
    80006f44:	557d                	li	a0,-1
    80006f46:	b7f5                	j	80006f32 <ringbuf_pop+0x48>

0000000080006f48 <fill_fs_common>:
#include "fslog.h"
static struct ringbuf fs_rb;
static uint64 fs_seq = 0;
static void
fill_fs_common(struct fs_event *e)
{
    80006f48:	1101                	addi	sp,sp,-32
    80006f4a:	ec06                	sd	ra,24(sp)
    80006f4c:	e822                	sd	s0,16(sp)
    80006f4e:	e426                	sd	s1,8(sp)
    80006f50:	1000                	addi	s0,sp,32
    80006f52:	84aa                	mv	s1,a0
  memset(e, 0, sizeof(*e));
    80006f54:	20000613          	li	a2,512
    80006f58:	4581                	li	a1,0
    80006f5a:	dd1f90ef          	jal	80000d2a <memset>
  e->ticks = ticks;
    80006f5e:	00003797          	auipc	a5,0x3
    80006f62:	0ea7a783          	lw	a5,234(a5) # 8000a048 <ticks>
    80006f66:	c49c                	sw	a5,8(s1)
  e->pid = myproc() ? myproc()->pid : 0;
    80006f68:	a01fa0ef          	jal	80001968 <myproc>
    80006f6c:	4781                	li	a5,0
    80006f6e:	c501                	beqz	a0,80006f76 <fill_fs_common+0x2e>
    80006f70:	9f9fa0ef          	jal	80001968 <myproc>
    80006f74:	591c                	lw	a5,48(a0)
    80006f76:	c4dc                	sw	a5,12(s1)
}
    80006f78:	60e2                	ld	ra,24(sp)
    80006f7a:	6442                	ld	s0,16(sp)
    80006f7c:	64a2                	ld	s1,8(sp)
    80006f7e:	6105                	addi	sp,sp,32
    80006f80:	8082                	ret

0000000080006f82 <fslog_init>:

void
fslog_init(void)
{
    80006f82:	1141                	addi	sp,sp,-16
    80006f84:	e406                	sd	ra,8(sp)
    80006f86:	e022                	sd	s0,0(sp)
    80006f88:	0800                	addi	s0,sp,16
  ringbuf_init(&fs_rb, "fslog", sizeof(struct fs_event));
    80006f8a:	20000613          	li	a2,512
    80006f8e:	00003597          	auipc	a1,0x3
    80006f92:	eda58593          	addi	a1,a1,-294 # 80009e68 <etext+0xe68>
    80006f96:	0003c517          	auipc	a0,0x3c
    80006f9a:	45250513          	addi	a0,a0,1106 # 800433e8 <fs_rb>
    80006f9e:	e2fff0ef          	jal	80006dcc <ringbuf_init>
  printf("FS sizeof(fs_event)=%ld RB_MAX_ELEM=%d\n", sizeof(struct fs_event), RB_MAX_ELEM);
    80006fa2:	10000613          	li	a2,256
    80006fa6:	20000593          	li	a1,512
    80006faa:	00003517          	auipc	a0,0x3
    80006fae:	ec650513          	addi	a0,a0,-314 # 80009e70 <etext+0xe70>
    80006fb2:	d7af90ef          	jal	8000052c <printf>
}
    80006fb6:	60a2                	ld	ra,8(sp)
    80006fb8:	6402                	ld	s0,0(sp)
    80006fba:	0141                	addi	sp,sp,16
    80006fbc:	8082                	ret

0000000080006fbe <fslog_push>:

void
fslog_push(struct fs_event *e)
{ e->seq = ++fs_seq;
    80006fbe:	1141                	addi	sp,sp,-16
    80006fc0:	e406                	sd	ra,8(sp)
    80006fc2:	e022                	sd	s0,0(sp)
    80006fc4:	0800                	addi	s0,sp,16
    80006fc6:	85aa                	mv	a1,a0
    80006fc8:	00003717          	auipc	a4,0x3
    80006fcc:	09070713          	addi	a4,a4,144 # 8000a058 <fs_seq>
    80006fd0:	631c                	ld	a5,0(a4)
    80006fd2:	0785                	addi	a5,a5,1
    80006fd4:	e31c                	sd	a5,0(a4)
    80006fd6:	e11c                	sd	a5,0(a0)
  ringbuf_push(&fs_rb, e);
    80006fd8:	0003c517          	auipc	a0,0x3c
    80006fdc:	41050513          	addi	a0,a0,1040 # 800433e8 <fs_rb>
    80006fe0:	e21ff0ef          	jal	80006e00 <ringbuf_push>
}
    80006fe4:	60a2                	ld	ra,8(sp)
    80006fe6:	6402                	ld	s0,0(sp)
    80006fe8:	0141                	addi	sp,sp,16
    80006fea:	8082                	ret

0000000080006fec <fslog_read_many>:
int
fslog_read_many(struct fs_event *out, int max)
{
    80006fec:	db010113          	addi	sp,sp,-592
    80006ff0:	24113423          	sd	ra,584(sp)
    80006ff4:	24813023          	sd	s0,576(sp)
    80006ff8:	22913c23          	sd	s1,568(sp)
    80006ffc:	23213823          	sd	s2,560(sp)
    80007000:	23413023          	sd	s4,544(sp)
    80007004:	0c80                	addi	s0,sp,592
    80007006:	84aa                	mv	s1,a0
    80007008:	8a2e                	mv	s4,a1
  struct fs_event e;
  int count = 0;
  struct proc *p = myproc();
    8000700a:	95ffa0ef          	jal	80001968 <myproc>
  while(count < max){
    8000700e:	07405063          	blez	s4,8000706e <fslog_read_many+0x82>
    80007012:	23313423          	sd	s3,552(sp)
    80007016:	21513c23          	sd	s5,536(sp)
    8000701a:	21613823          	sd	s6,528(sp)
    8000701e:	21713423          	sd	s7,520(sp)
    80007022:	8aaa                	mv	s5,a0
  int count = 0;
    80007024:	4901                	li	s2,0
    if(ringbuf_pop(&fs_rb, &e) != 0)
    80007026:	db040993          	addi	s3,s0,-592
    8000702a:	0003cb17          	auipc	s6,0x3c
    8000702e:	3beb0b13          	addi	s6,s6,958 # 800433e8 <fs_rb>
      break;

    uint64 dst = (uint64)out + count * sizeof(struct fs_event);

    if(copyout(p->pagetable, dst, (char *)&e, sizeof(struct fs_event)) < 0)
    80007032:	20000b93          	li	s7,512
    if(ringbuf_pop(&fs_rb, &e) != 0)
    80007036:	85ce                	mv	a1,s3
    80007038:	855a                	mv	a0,s6
    8000703a:	eb1ff0ef          	jal	80006eea <ringbuf_pop>
    8000703e:	e915                	bnez	a0,80007072 <fslog_read_many+0x86>
    if(copyout(p->pagetable, dst, (char *)&e, sizeof(struct fs_event)) < 0)
    80007040:	86de                	mv	a3,s7
    80007042:	864e                	mv	a2,s3
    80007044:	85a6                	mv	a1,s1
    80007046:	050ab503          	ld	a0,80(s5)
    8000704a:	e44fa0ef          	jal	8000168e <copyout>
    8000704e:	04054863          	bltz	a0,8000709e <fslog_read_many+0xb2>
      break;

    count++;
    80007052:	2905                	addiw	s2,s2,1
  while(count < max){
    80007054:	20048493          	addi	s1,s1,512
    80007058:	fd2a1fe3          	bne	s4,s2,80007036 <fslog_read_many+0x4a>
    8000705c:	22813983          	ld	s3,552(sp)
    80007060:	21813a83          	ld	s5,536(sp)
    80007064:	21013b03          	ld	s6,528(sp)
    80007068:	20813b83          	ld	s7,520(sp)
    8000706c:	a819                	j	80007082 <fslog_read_many+0x96>
  int count = 0;
    8000706e:	4901                	li	s2,0
    80007070:	a809                	j	80007082 <fslog_read_many+0x96>
    80007072:	22813983          	ld	s3,552(sp)
    80007076:	21813a83          	ld	s5,536(sp)
    8000707a:	21013b03          	ld	s6,528(sp)
    8000707e:	20813b83          	ld	s7,520(sp)
  }

  return count;
}
    80007082:	854a                	mv	a0,s2
    80007084:	24813083          	ld	ra,584(sp)
    80007088:	24013403          	ld	s0,576(sp)
    8000708c:	23813483          	ld	s1,568(sp)
    80007090:	23013903          	ld	s2,560(sp)
    80007094:	22013a03          	ld	s4,544(sp)
    80007098:	25010113          	addi	sp,sp,592
    8000709c:	8082                	ret
    8000709e:	22813983          	ld	s3,552(sp)
    800070a2:	21813a83          	ld	s5,536(sp)
    800070a6:	21013b03          	ld	s6,528(sp)
    800070aa:	20813b83          	ld	s7,520(sp)
    800070ae:	bfd1                	j	80007082 <fslog_read_many+0x96>

00000000800070b0 <fslog_bread_req>:
void
fslog_bread_req(int dev, int blockno)
{
    800070b0:	dd010113          	addi	sp,sp,-560
    800070b4:	22113423          	sd	ra,552(sp)
    800070b8:	22813023          	sd	s0,544(sp)
    800070bc:	20913c23          	sd	s1,536(sp)
    800070c0:	21213823          	sd	s2,528(sp)
    800070c4:	21313423          	sd	s3,520(sp)
    800070c8:	1c00                	addi	s0,sp,560
    800070ca:	892a                	mv	s2,a0
    800070cc:	89ae                	mv	s3,a1
  struct fs_event e;
  fill_fs_common(&e);
    800070ce:	dd040493          	addi	s1,s0,-560
    800070d2:	8526                	mv	a0,s1
    800070d4:	e75ff0ef          	jal	80006f48 <fill_fs_common>
  e.type = FS_BREAD_REQ;
    800070d8:	47a9                	li	a5,10
    800070da:	def42023          	sw	a5,-544(s0)
  e.dev = dev;
    800070de:	eb242023          	sw	s2,-352(s0)
  e.blockno = blockno;
    800070e2:	e9342a23          	sw	s3,-364(s0)
  safestrcpy(e.name, "BCACHE", FS_NM);
    800070e6:	02000613          	li	a2,32
    800070ea:	00003597          	auipc	a1,0x3
    800070ee:	dae58593          	addi	a1,a1,-594 # 80009e98 <etext+0xe98>
    800070f2:	e7440513          	addi	a0,s0,-396
    800070f6:	d89f90ef          	jal	80000e7e <safestrcpy>
  fslog_push(&e);
    800070fa:	8526                	mv	a0,s1
    800070fc:	ec3ff0ef          	jal	80006fbe <fslog_push>
}
    80007100:	22813083          	ld	ra,552(sp)
    80007104:	22013403          	ld	s0,544(sp)
    80007108:	21813483          	ld	s1,536(sp)
    8000710c:	21013903          	ld	s2,528(sp)
    80007110:	20813983          	ld	s3,520(sp)
    80007114:	23010113          	addi	sp,sp,560
    80007118:	8082                	ret

000000008000711a <fslog_bget_scan>:
void
fslog_bget_scan(int dev, int blockno, int buf_id,
                int refcnt, int valid, int lru_pos,
                int scan_dir, int scan_step, int found)
{
    8000711a:	da010113          	addi	sp,sp,-608
    8000711e:	24113c23          	sd	ra,600(sp)
    80007122:	24813823          	sd	s0,592(sp)
    80007126:	24913423          	sd	s1,584(sp)
    8000712a:	25213023          	sd	s2,576(sp)
    8000712e:	23313c23          	sd	s3,568(sp)
    80007132:	23413823          	sd	s4,560(sp)
    80007136:	23513423          	sd	s5,552(sp)
    8000713a:	23613023          	sd	s6,544(sp)
    8000713e:	21713c23          	sd	s7,536(sp)
    80007142:	21813823          	sd	s8,528(sp)
    80007146:	21913423          	sd	s9,520(sp)
    8000714a:	1480                	addi	s0,sp,608
    8000714c:	8aaa                	mv	s5,a0
    8000714e:	8b2e                	mv	s6,a1
    80007150:	8bb2                	mv	s7,a2
    80007152:	89b6                	mv	s3,a3
    80007154:	893a                	mv	s2,a4
    80007156:	84be                	mv	s1,a5
    80007158:	8c42                	mv	s8,a6
    8000715a:	8cc6                	mv	s9,a7
  struct fs_event e;
  fill_fs_common(&e);
    8000715c:	da040a13          	addi	s4,s0,-608
    80007160:	8552                	mv	a0,s4
    80007162:	de7ff0ef          	jal	80006f48 <fill_fs_common>
  e.type = FS_BGET_SCAN;
    80007166:	47ad                	li	a5,11
    80007168:	daf42823          	sw	a5,-592(s0)
  e.dev = dev;
    8000716c:	e7542823          	sw	s5,-400(s0)
  e.blockno = blockno;
    80007170:	e7642223          	sw	s6,-412(s0)
  e.buf_id = buf_id;
    80007174:	e7742a23          	sw	s7,-396(s0)
  e.ref_before = refcnt;
    80007178:	e9342423          	sw	s3,-376(s0)
  e.ref_after = refcnt;
    8000717c:	e9342623          	sw	s3,-372(s0)
  e.valid_before = valid;
    80007180:	e9242823          	sw	s2,-368(s0)
  e.valid_after = valid;
    80007184:	e9242a23          	sw	s2,-364(s0)
  e.lru_before = lru_pos;
    80007188:	ea942023          	sw	s1,-352(s0)
  e.lru_after = lru_pos;
    8000718c:	ea942223          	sw	s1,-348(s0)
  e.scan_dir = scan_dir;
    80007190:	eb842423          	sw	s8,-344(s0)
  e.scan_step = scan_step;
    80007194:	eb942623          	sw	s9,-340(s0)
  e.found = found;
    80007198:	401c                	lw	a5,0(s0)
    8000719a:	eaf42823          	sw	a5,-336(s0)
  safestrcpy(e.name, "BCACHE", FS_NM);
    8000719e:	02000613          	li	a2,32
    800071a2:	00003597          	auipc	a1,0x3
    800071a6:	cf658593          	addi	a1,a1,-778 # 80009e98 <etext+0xe98>
    800071aa:	e4440513          	addi	a0,s0,-444
    800071ae:	cd1f90ef          	jal	80000e7e <safestrcpy>
  fslog_push(&e);
    800071b2:	8552                	mv	a0,s4
    800071b4:	e0bff0ef          	jal	80006fbe <fslog_push>
}
    800071b8:	25813083          	ld	ra,600(sp)
    800071bc:	25013403          	ld	s0,592(sp)
    800071c0:	24813483          	ld	s1,584(sp)
    800071c4:	24013903          	ld	s2,576(sp)
    800071c8:	23813983          	ld	s3,568(sp)
    800071cc:	23013a03          	ld	s4,560(sp)
    800071d0:	22813a83          	ld	s5,552(sp)
    800071d4:	22013b03          	ld	s6,544(sp)
    800071d8:	21813b83          	ld	s7,536(sp)
    800071dc:	21013c03          	ld	s8,528(sp)
    800071e0:	20813c83          	ld	s9,520(sp)
    800071e4:	26010113          	addi	sp,sp,608
    800071e8:	8082                	ret

00000000800071ea <fslog_bget_hit>:
void
fslog_bget_hit(int dev, int blockno, int buf_id,
               int ref_before, int ref_after,
               int valid,
               int lru_pos)
{
    800071ea:	db010113          	addi	sp,sp,-592
    800071ee:	24113423          	sd	ra,584(sp)
    800071f2:	24813023          	sd	s0,576(sp)
    800071f6:	22913c23          	sd	s1,568(sp)
    800071fa:	23213823          	sd	s2,560(sp)
    800071fe:	23313423          	sd	s3,552(sp)
    80007202:	23413023          	sd	s4,544(sp)
    80007206:	21513c23          	sd	s5,536(sp)
    8000720a:	21613823          	sd	s6,528(sp)
    8000720e:	21713423          	sd	s7,520(sp)
    80007212:	21813023          	sd	s8,512(sp)
    80007216:	0c80                	addi	s0,sp,592
    80007218:	8a2a                	mv	s4,a0
    8000721a:	8aae                	mv	s5,a1
    8000721c:	8b32                	mv	s6,a2
    8000721e:	8bb6                	mv	s7,a3
    80007220:	8c3a                	mv	s8,a4
    80007222:	893e                	mv	s2,a5
    80007224:	84c2                	mv	s1,a6
  struct fs_event e;
  fill_fs_common(&e);
    80007226:	db040993          	addi	s3,s0,-592
    8000722a:	854e                	mv	a0,s3
    8000722c:	d1dff0ef          	jal	80006f48 <fill_fs_common>
  e.type = FS_BGET_HIT;
    80007230:	4799                	li	a5,6
    80007232:	dcf42023          	sw	a5,-576(s0)
  e.dev = dev;
    80007236:	e9442023          	sw	s4,-384(s0)
  e.blockno = blockno;
    8000723a:	e7542a23          	sw	s5,-396(s0)
  e.buf_id = buf_id;
    8000723e:	e9642223          	sw	s6,-380(s0)
  e.ref_before = ref_before;
    80007242:	e9742c23          	sw	s7,-360(s0)
  e.ref_after = ref_after;
    80007246:	e9842e23          	sw	s8,-356(s0)
  e.valid_before = valid;
    8000724a:	eb242023          	sw	s2,-352(s0)
  e.valid_after = valid;
    8000724e:	eb242223          	sw	s2,-348(s0)
  e.locked_before = 0;
    80007252:	ea042423          	sw	zero,-344(s0)
  e.locked_after = 1;
    80007256:	4785                	li	a5,1
    80007258:	eaf42623          	sw	a5,-340(s0)
  e.lru_before = lru_pos;
    8000725c:	ea942823          	sw	s1,-336(s0)
  e.lru_after = lru_pos;
    80007260:	ea942a23          	sw	s1,-332(s0)
  e.found = 1;
    80007264:	ecf42023          	sw	a5,-320(s0)
  safestrcpy(e.name, "BCACHE", FS_NM);
    80007268:	02000613          	li	a2,32
    8000726c:	00003597          	auipc	a1,0x3
    80007270:	c2c58593          	addi	a1,a1,-980 # 80009e98 <etext+0xe98>
    80007274:	e5440513          	addi	a0,s0,-428
    80007278:	c07f90ef          	jal	80000e7e <safestrcpy>
  fslog_push(&e);
    8000727c:	854e                	mv	a0,s3
    8000727e:	d41ff0ef          	jal	80006fbe <fslog_push>
}
    80007282:	24813083          	ld	ra,584(sp)
    80007286:	24013403          	ld	s0,576(sp)
    8000728a:	23813483          	ld	s1,568(sp)
    8000728e:	23013903          	ld	s2,560(sp)
    80007292:	22813983          	ld	s3,552(sp)
    80007296:	22013a03          	ld	s4,544(sp)
    8000729a:	21813a83          	ld	s5,536(sp)
    8000729e:	21013b03          	ld	s6,528(sp)
    800072a2:	20813b83          	ld	s7,520(sp)
    800072a6:	20013c03          	ld	s8,512(sp)
    800072aa:	25010113          	addi	sp,sp,592
    800072ae:	8082                	ret

00000000800072b0 <fslog_bget_miss>:
void
fslog_bget_miss(int dev, int blockno, int old_blockno, int buf_id,
                int old_valid,
                int lru_pos)
{
    800072b0:	db010113          	addi	sp,sp,-592
    800072b4:	24113423          	sd	ra,584(sp)
    800072b8:	24813023          	sd	s0,576(sp)
    800072bc:	22913c23          	sd	s1,568(sp)
    800072c0:	23213823          	sd	s2,560(sp)
    800072c4:	23313423          	sd	s3,552(sp)
    800072c8:	23413023          	sd	s4,544(sp)
    800072cc:	21513c23          	sd	s5,536(sp)
    800072d0:	21613823          	sd	s6,528(sp)
    800072d4:	21713423          	sd	s7,520(sp)
    800072d8:	0c80                	addi	s0,sp,592
    800072da:	89aa                	mv	s3,a0
    800072dc:	8a2e                	mv	s4,a1
    800072de:	8ab2                	mv	s5,a2
    800072e0:	8b36                	mv	s6,a3
    800072e2:	8bba                	mv	s7,a4
    800072e4:	84be                	mv	s1,a5
  struct fs_event e;
  fill_fs_common(&e);
    800072e6:	db040913          	addi	s2,s0,-592
    800072ea:	854a                	mv	a0,s2
    800072ec:	c5dff0ef          	jal	80006f48 <fill_fs_common>
  e.type = FS_BGET_MISS;
    800072f0:	479d                	li	a5,7
    800072f2:	dcf42023          	sw	a5,-576(s0)
  e.dev = dev;
    800072f6:	e9342023          	sw	s3,-384(s0)
  e.blockno = blockno;
    800072fa:	e7442a23          	sw	s4,-396(s0)
  e.old_blockno = old_blockno;
    800072fe:	e7542c23          	sw	s5,-392(s0)
  e.buf_id = buf_id;
    80007302:	e9642223          	sw	s6,-380(s0)
  e.ref_before = 0;
    80007306:	e8042c23          	sw	zero,-360(s0)
  e.ref_after = 1;
    8000730a:	4785                	li	a5,1
    8000730c:	e8f42e23          	sw	a5,-356(s0)
  e.valid_before = old_valid;
    80007310:	eb742023          	sw	s7,-352(s0)
  e.valid_after = 0;
    80007314:	ea042223          	sw	zero,-348(s0)
  e.locked_before = 0;
    80007318:	ea042423          	sw	zero,-344(s0)
  e.locked_after = 1;
    8000731c:	eaf42623          	sw	a5,-340(s0)
  e.lru_before = lru_pos;
    80007320:	ea942823          	sw	s1,-336(s0)
  e.lru_after = lru_pos;
    80007324:	ea942a23          	sw	s1,-332(s0)
  e.found = 1;
    80007328:	ecf42023          	sw	a5,-320(s0)
  safestrcpy(e.name, "BCACHE", FS_NM);
    8000732c:	02000613          	li	a2,32
    80007330:	00003597          	auipc	a1,0x3
    80007334:	b6858593          	addi	a1,a1,-1176 # 80009e98 <etext+0xe98>
    80007338:	e5440513          	addi	a0,s0,-428
    8000733c:	b43f90ef          	jal	80000e7e <safestrcpy>
  fslog_push(&e);
    80007340:	854a                	mv	a0,s2
    80007342:	c7dff0ef          	jal	80006fbe <fslog_push>
}
    80007346:	24813083          	ld	ra,584(sp)
    8000734a:	24013403          	ld	s0,576(sp)
    8000734e:	23813483          	ld	s1,568(sp)
    80007352:	23013903          	ld	s2,560(sp)
    80007356:	22813983          	ld	s3,552(sp)
    8000735a:	22013a03          	ld	s4,544(sp)
    8000735e:	21813a83          	ld	s5,536(sp)
    80007362:	21013b03          	ld	s6,528(sp)
    80007366:	20813b83          	ld	s7,520(sp)
    8000736a:	25010113          	addi	sp,sp,592
    8000736e:	8082                	ret

0000000080007370 <fslog_bread_fill>:
void
fslog_bread_fill(int dev, int blockno, int buf_id,
                 int refcnt, int lru_pos)
{
    80007370:	dc010113          	addi	sp,sp,-576
    80007374:	22113c23          	sd	ra,568(sp)
    80007378:	22813823          	sd	s0,560(sp)
    8000737c:	22913423          	sd	s1,552(sp)
    80007380:	23213023          	sd	s2,544(sp)
    80007384:	21313c23          	sd	s3,536(sp)
    80007388:	21413823          	sd	s4,528(sp)
    8000738c:	21513423          	sd	s5,520(sp)
    80007390:	21613023          	sd	s6,512(sp)
    80007394:	0480                	addi	s0,sp,576
    80007396:	8a2a                	mv	s4,a0
    80007398:	8aae                	mv	s5,a1
    8000739a:	8b32                	mv	s6,a2
    8000739c:	8936                	mv	s2,a3
    8000739e:	84ba                	mv	s1,a4
  struct fs_event e;
  fill_fs_common(&e);
    800073a0:	dc040993          	addi	s3,s0,-576
    800073a4:	854e                	mv	a0,s3
    800073a6:	ba3ff0ef          	jal	80006f48 <fill_fs_common>
  e.type = FS_BREAD_FILL;
    800073aa:	47b1                	li	a5,12
    800073ac:	dcf42823          	sw	a5,-560(s0)
  e.dev = dev;
    800073b0:	e9442823          	sw	s4,-368(s0)
  e.blockno = blockno;
    800073b4:	e9542223          	sw	s5,-380(s0)
  e.buf_id = buf_id;
    800073b8:	e9642a23          	sw	s6,-364(s0)
  e.ref_before = refcnt;
    800073bc:	eb242423          	sw	s2,-344(s0)
  e.ref_after = refcnt;
    800073c0:	eb242623          	sw	s2,-340(s0)
  e.valid_before = 0;
    800073c4:	ea042823          	sw	zero,-336(s0)
  e.valid_after = 1;
    800073c8:	4785                	li	a5,1
    800073ca:	eaf42a23          	sw	a5,-332(s0)
  e.locked_before = 1;
    800073ce:	eaf42c23          	sw	a5,-328(s0)
  e.locked_after = 1;
    800073d2:	eaf42e23          	sw	a5,-324(s0)
  e.lru_before = lru_pos;
    800073d6:	ec942023          	sw	s1,-320(s0)
  e.lru_after = lru_pos;
    800073da:	ec942223          	sw	s1,-316(s0)
  safestrcpy(e.name, "BCACHE", FS_NM);
    800073de:	02000613          	li	a2,32
    800073e2:	00003597          	auipc	a1,0x3
    800073e6:	ab658593          	addi	a1,a1,-1354 # 80009e98 <etext+0xe98>
    800073ea:	e6440513          	addi	a0,s0,-412
    800073ee:	a91f90ef          	jal	80000e7e <safestrcpy>
  fslog_push(&e);
    800073f2:	854e                	mv	a0,s3
    800073f4:	bcbff0ef          	jal	80006fbe <fslog_push>
}
    800073f8:	23813083          	ld	ra,568(sp)
    800073fc:	23013403          	ld	s0,560(sp)
    80007400:	22813483          	ld	s1,552(sp)
    80007404:	22013903          	ld	s2,544(sp)
    80007408:	21813983          	ld	s3,536(sp)
    8000740c:	21013a03          	ld	s4,528(sp)
    80007410:	20813a83          	ld	s5,520(sp)
    80007414:	20013b03          	ld	s6,512(sp)
    80007418:	24010113          	addi	sp,sp,576
    8000741c:	8082                	ret

000000008000741e <fslog_bwrite_ev>:
void
fslog_bwrite_ev(int dev, int blockno, int buf_id,
                int refcnt, int valid, int lru_pos)
{
    8000741e:	db010113          	addi	sp,sp,-592
    80007422:	24113423          	sd	ra,584(sp)
    80007426:	24813023          	sd	s0,576(sp)
    8000742a:	22913c23          	sd	s1,568(sp)
    8000742e:	23213823          	sd	s2,560(sp)
    80007432:	23313423          	sd	s3,552(sp)
    80007436:	23413023          	sd	s4,544(sp)
    8000743a:	21513c23          	sd	s5,536(sp)
    8000743e:	21613823          	sd	s6,528(sp)
    80007442:	21713423          	sd	s7,520(sp)
    80007446:	0c80                	addi	s0,sp,592
    80007448:	8aaa                	mv	s5,a0
    8000744a:	8b2e                	mv	s6,a1
    8000744c:	8bb2                	mv	s7,a2
    8000744e:	89b6                	mv	s3,a3
    80007450:	893a                	mv	s2,a4
    80007452:	84be                	mv	s1,a5
  struct fs_event e;
  fill_fs_common(&e);
    80007454:	db040a13          	addi	s4,s0,-592
    80007458:	8552                	mv	a0,s4
    8000745a:	aefff0ef          	jal	80006f48 <fill_fs_common>
  e.type = FS_BWRITE;
    8000745e:	47b5                	li	a5,13
    80007460:	dcf42023          	sw	a5,-576(s0)
  e.dev = dev;
    80007464:	e9542023          	sw	s5,-384(s0)
  e.blockno = blockno;
    80007468:	e7642a23          	sw	s6,-396(s0)
  e.buf_id = buf_id;
    8000746c:	e9742223          	sw	s7,-380(s0)
  e.ref_before = refcnt;
    80007470:	e9342c23          	sw	s3,-360(s0)
  e.ref_after = refcnt;
    80007474:	e9342e23          	sw	s3,-356(s0)
  e.valid_before = valid;
    80007478:	eb242023          	sw	s2,-352(s0)
  e.valid_after = valid;
    8000747c:	eb242223          	sw	s2,-348(s0)
  e.locked_before = 1;
    80007480:	4785                	li	a5,1
    80007482:	eaf42423          	sw	a5,-344(s0)
  e.locked_after = 1;
    80007486:	eaf42623          	sw	a5,-340(s0)
  e.lru_before = lru_pos;
    8000748a:	ea942823          	sw	s1,-336(s0)
  e.lru_after = lru_pos;
    8000748e:	ea942a23          	sw	s1,-332(s0)
  safestrcpy(e.name, "BCACHE", FS_NM);
    80007492:	02000613          	li	a2,32
    80007496:	00003597          	auipc	a1,0x3
    8000749a:	a0258593          	addi	a1,a1,-1534 # 80009e98 <etext+0xe98>
    8000749e:	e5440513          	addi	a0,s0,-428
    800074a2:	9ddf90ef          	jal	80000e7e <safestrcpy>
  fslog_push(&e);
    800074a6:	8552                	mv	a0,s4
    800074a8:	b17ff0ef          	jal	80006fbe <fslog_push>
}
    800074ac:	24813083          	ld	ra,584(sp)
    800074b0:	24013403          	ld	s0,576(sp)
    800074b4:	23813483          	ld	s1,568(sp)
    800074b8:	23013903          	ld	s2,560(sp)
    800074bc:	22813983          	ld	s3,552(sp)
    800074c0:	22013a03          	ld	s4,544(sp)
    800074c4:	21813a83          	ld	s5,536(sp)
    800074c8:	21013b03          	ld	s6,528(sp)
    800074cc:	20813b83          	ld	s7,520(sp)
    800074d0:	25010113          	addi	sp,sp,592
    800074d4:	8082                	ret

00000000800074d6 <fslog_brelease_ev>:
void
fslog_brelease_ev(int dev, int blockno, int buf_id,
                  int ref_before, int ref_after,
                  int valid,
                  int lru_before, int lru_after)
{
    800074d6:	da010113          	addi	sp,sp,-608
    800074da:	24113c23          	sd	ra,600(sp)
    800074de:	24813823          	sd	s0,592(sp)
    800074e2:	24913423          	sd	s1,584(sp)
    800074e6:	25213023          	sd	s2,576(sp)
    800074ea:	23313c23          	sd	s3,568(sp)
    800074ee:	23413823          	sd	s4,560(sp)
    800074f2:	23513423          	sd	s5,552(sp)
    800074f6:	23613023          	sd	s6,544(sp)
    800074fa:	21713c23          	sd	s7,536(sp)
    800074fe:	21813823          	sd	s8,528(sp)
    80007502:	21913423          	sd	s9,520(sp)
    80007506:	1480                	addi	s0,sp,608
    80007508:	89aa                	mv	s3,a0
    8000750a:	8a2e                	mv	s4,a1
    8000750c:	8ab2                	mv	s5,a2
    8000750e:	8b36                	mv	s6,a3
    80007510:	8bba                	mv	s7,a4
    80007512:	84be                	mv	s1,a5
    80007514:	8c42                	mv	s8,a6
    80007516:	8cc6                	mv	s9,a7
  struct fs_event e;
  fill_fs_common(&e);
    80007518:	da040913          	addi	s2,s0,-608
    8000751c:	854a                	mv	a0,s2
    8000751e:	a2bff0ef          	jal	80006f48 <fill_fs_common>
  e.type = FS_BRELEASE;
    80007522:	47a1                	li	a5,8
    80007524:	daf42823          	sw	a5,-592(s0)
  e.dev = dev;
    80007528:	e7342823          	sw	s3,-400(s0)
  e.blockno = blockno;
    8000752c:	e7442223          	sw	s4,-412(s0)
  e.buf_id = buf_id;
    80007530:	e7542a23          	sw	s5,-396(s0)
  e.ref_before = ref_before;
    80007534:	e9642423          	sw	s6,-376(s0)
  e.ref_after = ref_after;
    80007538:	e9742623          	sw	s7,-372(s0)
  e.valid_before = valid;
    8000753c:	e8942823          	sw	s1,-368(s0)
  e.valid_after = valid;
    80007540:	e8942a23          	sw	s1,-364(s0)
  e.locked_before = 1;
    80007544:	4785                	li	a5,1
    80007546:	e8f42c23          	sw	a5,-360(s0)
  e.locked_after = 0;
    8000754a:	e8042e23          	sw	zero,-356(s0)
  e.lru_before = lru_before;
    8000754e:	eb842023          	sw	s8,-352(s0)
  e.lru_after = lru_after;
    80007552:	eb942223          	sw	s9,-348(s0)
  safestrcpy(e.name, "BCACHE", FS_NM);
    80007556:	02000613          	li	a2,32
    8000755a:	00003597          	auipc	a1,0x3
    8000755e:	93e58593          	addi	a1,a1,-1730 # 80009e98 <etext+0xe98>
    80007562:	e4440513          	addi	a0,s0,-444
    80007566:	919f90ef          	jal	80000e7e <safestrcpy>
  fslog_push(&e);
    8000756a:	854a                	mv	a0,s2
    8000756c:	a53ff0ef          	jal	80006fbe <fslog_push>
}
    80007570:	25813083          	ld	ra,600(sp)
    80007574:	25013403          	ld	s0,592(sp)
    80007578:	24813483          	ld	s1,584(sp)
    8000757c:	24013903          	ld	s2,576(sp)
    80007580:	23813983          	ld	s3,568(sp)
    80007584:	23013a03          	ld	s4,560(sp)
    80007588:	22813a83          	ld	s5,552(sp)
    8000758c:	22013b03          	ld	s6,544(sp)
    80007590:	21813b83          	ld	s7,536(sp)
    80007594:	21013c03          	ld	s8,528(sp)
    80007598:	20813c83          	ld	s9,520(sp)
    8000759c:	26010113          	addi	sp,sp,608
    800075a0:	8082                	ret

00000000800075a2 <fslog_begin>:
void fslog_begin(int before, int after){
    800075a2:	dd010113          	addi	sp,sp,-560
    800075a6:	22113423          	sd	ra,552(sp)
    800075aa:	22813023          	sd	s0,544(sp)
    800075ae:	20913c23          	sd	s1,536(sp)
    800075b2:	21213823          	sd	s2,528(sp)
    800075b6:	21313423          	sd	s3,520(sp)
    800075ba:	1c00                	addi	s0,sp,560
    800075bc:	892a                	mv	s2,a0
    800075be:	89ae                	mv	s3,a1
  struct fs_event e;
  fill_fs_common(&e);
    800075c0:	dd040493          	addi	s1,s0,-560
    800075c4:	8526                	mv	a0,s1
    800075c6:	983ff0ef          	jal	80006f48 <fill_fs_common>

  e.type = FS_LOG_BEGIN;
    800075ca:	47b9                	li	a5,14
    800075cc:	def42023          	sw	a5,-544(s0)
  e.ref_before = before;
    800075d0:	eb242c23          	sw	s2,-328(s0)
  e.ref_after = after;
    800075d4:	eb342e23          	sw	s3,-324(s0)

  safestrcpy(e.name, "LOG", FS_NM);
    800075d8:	02000613          	li	a2,32
    800075dc:	00003597          	auipc	a1,0x3
    800075e0:	8c458593          	addi	a1,a1,-1852 # 80009ea0 <etext+0xea0>
    800075e4:	e7440513          	addi	a0,s0,-396
    800075e8:	897f90ef          	jal	80000e7e <safestrcpy>
  fslog_push(&e);
    800075ec:	8526                	mv	a0,s1
    800075ee:	9d1ff0ef          	jal	80006fbe <fslog_push>
}
    800075f2:	22813083          	ld	ra,552(sp)
    800075f6:	22013403          	ld	s0,544(sp)
    800075fa:	21813483          	ld	s1,536(sp)
    800075fe:	21013903          	ld	s2,528(sp)
    80007602:	20813983          	ld	s3,520(sp)
    80007606:	23010113          	addi	sp,sp,560
    8000760a:	8082                	ret

000000008000760c <fslog_write>:
void fslog_write(int blockno, int existed, int n_before, int n_after){
    8000760c:	dc010113          	addi	sp,sp,-576
    80007610:	22113c23          	sd	ra,568(sp)
    80007614:	22813823          	sd	s0,560(sp)
    80007618:	22913423          	sd	s1,552(sp)
    8000761c:	23213023          	sd	s2,544(sp)
    80007620:	21313c23          	sd	s3,536(sp)
    80007624:	21413823          	sd	s4,528(sp)
    80007628:	21513423          	sd	s5,520(sp)
    8000762c:	0480                	addi	s0,sp,576
    8000762e:	892a                	mv	s2,a0
    80007630:	8aae                	mv	s5,a1
    80007632:	89b2                	mv	s3,a2
    80007634:	8a36                	mv	s4,a3
  struct fs_event e;
  fill_fs_common(&e);
    80007636:	dc040493          	addi	s1,s0,-576
    8000763a:	8526                	mv	a0,s1
    8000763c:	90dff0ef          	jal	80006f48 <fill_fs_common>

  e.type = FS_LOG_WRITE;
    80007640:	47bd                	li	a5,15
    80007642:	dcf42823          	sw	a5,-560(s0)
  e.blockno = blockno;
    80007646:	e9242223          	sw	s2,-380(s0)
  e.ref_before = n_before;
    8000764a:	eb342423          	sw	s3,-344(s0)
  e.ref_after = n_after;
    8000764e:	eb442623          	sw	s4,-340(s0)
  e.found = existed;
    80007652:	ed542823          	sw	s5,-304(s0)

  safestrcpy(e.name, "LOG", FS_NM);
    80007656:	02000613          	li	a2,32
    8000765a:	00003597          	auipc	a1,0x3
    8000765e:	84658593          	addi	a1,a1,-1978 # 80009ea0 <etext+0xea0>
    80007662:	e6440513          	addi	a0,s0,-412
    80007666:	819f90ef          	jal	80000e7e <safestrcpy>
  fslog_push(&e);
    8000766a:	8526                	mv	a0,s1
    8000766c:	953ff0ef          	jal	80006fbe <fslog_push>
}
    80007670:	23813083          	ld	ra,568(sp)
    80007674:	23013403          	ld	s0,560(sp)
    80007678:	22813483          	ld	s1,552(sp)
    8000767c:	22013903          	ld	s2,544(sp)
    80007680:	21813983          	ld	s3,536(sp)
    80007684:	21013a03          	ld	s4,528(sp)
    80007688:	20813a83          	ld	s5,520(sp)
    8000768c:	24010113          	addi	sp,sp,576
    80007690:	8082                	ret

0000000080007692 <fslog_end>:

void fslog_end(int before, int after, int will_commit){
    80007692:	dd010113          	addi	sp,sp,-560
    80007696:	22113423          	sd	ra,552(sp)
    8000769a:	22813023          	sd	s0,544(sp)
    8000769e:	20913c23          	sd	s1,536(sp)
    800076a2:	21213823          	sd	s2,528(sp)
    800076a6:	21313423          	sd	s3,520(sp)
    800076aa:	21413023          	sd	s4,512(sp)
    800076ae:	1c00                	addi	s0,sp,560
    800076b0:	892a                	mv	s2,a0
    800076b2:	89ae                	mv	s3,a1
    800076b4:	8a32                	mv	s4,a2
  struct fs_event e;
  fill_fs_common(&e);
    800076b6:	dd040493          	addi	s1,s0,-560
    800076ba:	8526                	mv	a0,s1
    800076bc:	88dff0ef          	jal	80006f48 <fill_fs_common>
  e.type = FS_LOG_END;
    800076c0:	47c1                	li	a5,16
    800076c2:	def42023          	sw	a5,-544(s0)
  e.ref_before = before;
    800076c6:	eb242c23          	sw	s2,-328(s0)
  e.ref_after = after;
    800076ca:	eb342e23          	sw	s3,-324(s0)
  e.found = will_commit;
    800076ce:	ef442023          	sw	s4,-288(s0)
  safestrcpy(e.name, "LOG", FS_NM);
    800076d2:	02000613          	li	a2,32
    800076d6:	00002597          	auipc	a1,0x2
    800076da:	7ca58593          	addi	a1,a1,1994 # 80009ea0 <etext+0xea0>
    800076de:	e7440513          	addi	a0,s0,-396
    800076e2:	f9cf90ef          	jal	80000e7e <safestrcpy>
  fslog_push(&e);
    800076e6:	8526                	mv	a0,s1
    800076e8:	8d7ff0ef          	jal	80006fbe <fslog_push>
}
    800076ec:	22813083          	ld	ra,552(sp)
    800076f0:	22013403          	ld	s0,544(sp)
    800076f4:	21813483          	ld	s1,536(sp)
    800076f8:	21013903          	ld	s2,528(sp)
    800076fc:	20813983          	ld	s3,520(sp)
    80007700:	20013a03          	ld	s4,512(sp)
    80007704:	23010113          	addi	sp,sp,560
    80007708:	8082                	ret

000000008000770a <fslog_writelog>:
void fslog_writelog(int blockno, int idx){
    8000770a:	dd010113          	addi	sp,sp,-560
    8000770e:	22113423          	sd	ra,552(sp)
    80007712:	22813023          	sd	s0,544(sp)
    80007716:	20913c23          	sd	s1,536(sp)
    8000771a:	21213823          	sd	s2,528(sp)
    8000771e:	21313423          	sd	s3,520(sp)
    80007722:	1c00                	addi	s0,sp,560
    80007724:	892a                	mv	s2,a0
    80007726:	89ae                	mv	s3,a1
  struct fs_event e;
  fill_fs_common(&e);
    80007728:	dd040493          	addi	s1,s0,-560
    8000772c:	8526                	mv	a0,s1
    8000772e:	81bff0ef          	jal	80006f48 <fill_fs_common>
  e.type = FS_LOG_WLOG;
    80007732:	47c5                	li	a5,17
    80007734:	def42023          	sw	a5,-544(s0)
  e.blockno = blockno;
    80007738:	e9242a23          	sw	s2,-364(s0)
  e.lru_after = idx;
    8000773c:	ed342a23          	sw	s3,-300(s0)
  safestrcpy(e.name, "LOG", FS_NM);
    80007740:	02000613          	li	a2,32
    80007744:	00002597          	auipc	a1,0x2
    80007748:	75c58593          	addi	a1,a1,1884 # 80009ea0 <etext+0xea0>
    8000774c:	e7440513          	addi	a0,s0,-396
    80007750:	f2ef90ef          	jal	80000e7e <safestrcpy>
  fslog_push(&e);
    80007754:	8526                	mv	a0,s1
    80007756:	869ff0ef          	jal	80006fbe <fslog_push>
}
    8000775a:	22813083          	ld	ra,552(sp)
    8000775e:	22013403          	ld	s0,544(sp)
    80007762:	21813483          	ld	s1,536(sp)
    80007766:	21013903          	ld	s2,528(sp)
    8000776a:	20813983          	ld	s3,520(sp)
    8000776e:	23010113          	addi	sp,sp,560
    80007772:	8082                	ret

0000000080007774 <fslog_writehead>:

void fslog_writehead(int n){
    80007774:	de010113          	addi	sp,sp,-544
    80007778:	20113c23          	sd	ra,536(sp)
    8000777c:	20813823          	sd	s0,528(sp)
    80007780:	20913423          	sd	s1,520(sp)
    80007784:	21213023          	sd	s2,512(sp)
    80007788:	1400                	addi	s0,sp,544
    8000778a:	892a                	mv	s2,a0
  struct fs_event e;
  fill_fs_common(&e);
    8000778c:	de040493          	addi	s1,s0,-544
    80007790:	8526                	mv	a0,s1
    80007792:	fb6ff0ef          	jal	80006f48 <fill_fs_common>
  e.type = FS_LOG_WHEAD;
    80007796:	47c9                	li	a5,18
    80007798:	def42823          	sw	a5,-528(s0)
  e.ref_after = n;
    8000779c:	ed242623          	sw	s2,-308(s0)
  safestrcpy(e.name, "LOG", FS_NM);
    800077a0:	02000613          	li	a2,32
    800077a4:	00002597          	auipc	a1,0x2
    800077a8:	6fc58593          	addi	a1,a1,1788 # 80009ea0 <etext+0xea0>
    800077ac:	e8440513          	addi	a0,s0,-380
    800077b0:	ecef90ef          	jal	80000e7e <safestrcpy>
  fslog_push(&e);
    800077b4:	8526                	mv	a0,s1
    800077b6:	809ff0ef          	jal	80006fbe <fslog_push>
}
    800077ba:	21813083          	ld	ra,536(sp)
    800077be:	21013403          	ld	s0,528(sp)
    800077c2:	20813483          	ld	s1,520(sp)
    800077c6:	20013903          	ld	s2,512(sp)
    800077ca:	22010113          	addi	sp,sp,544
    800077ce:	8082                	ret

00000000800077d0 <fslog_install>:

void fslog_install(int blockno){
    800077d0:	de010113          	addi	sp,sp,-544
    800077d4:	20113c23          	sd	ra,536(sp)
    800077d8:	20813823          	sd	s0,528(sp)
    800077dc:	20913423          	sd	s1,520(sp)
    800077e0:	21213023          	sd	s2,512(sp)
    800077e4:	1400                	addi	s0,sp,544
    800077e6:	892a                	mv	s2,a0
  struct fs_event e;
  fill_fs_common(&e);
    800077e8:	de040493          	addi	s1,s0,-544
    800077ec:	8526                	mv	a0,s1
    800077ee:	f5aff0ef          	jal	80006f48 <fill_fs_common>
  e.type = FS_LOG_INSTALL;
    800077f2:	47cd                	li	a5,19
    800077f4:	def42823          	sw	a5,-528(s0)
  e.blockno = blockno;
    800077f8:	eb242223          	sw	s2,-348(s0)
  safestrcpy(e.name, "LOG", FS_NM);
    800077fc:	02000613          	li	a2,32
    80007800:	00002597          	auipc	a1,0x2
    80007804:	6a058593          	addi	a1,a1,1696 # 80009ea0 <etext+0xea0>
    80007808:	e8440513          	addi	a0,s0,-380
    8000780c:	e72f90ef          	jal	80000e7e <safestrcpy>
  fslog_push(&e);
    80007810:	8526                	mv	a0,s1
    80007812:	facff0ef          	jal	80006fbe <fslog_push>
}
    80007816:	21813083          	ld	ra,536(sp)
    8000781a:	21013403          	ld	s0,528(sp)
    8000781e:	20813483          	ld	s1,520(sp)
    80007822:	20013903          	ld	s2,512(sp)
    80007826:	22010113          	addi	sp,sp,544
    8000782a:	8082                	ret

000000008000782c <fslog_balloc>:
void fslog_balloc(int block_allocated) {
    8000782c:	de010113          	addi	sp,sp,-544
    80007830:	20113c23          	sd	ra,536(sp)
    80007834:	20813823          	sd	s0,528(sp)
    80007838:	20913423          	sd	s1,520(sp)
    8000783c:	21213023          	sd	s2,512(sp)
    80007840:	1400                	addi	s0,sp,544
    80007842:	892a                	mv	s2,a0
    struct fs_event e;
    fill_fs_common(&e);
    80007844:	de040493          	addi	s1,s0,-544
    80007848:	8526                	mv	a0,s1
    8000784a:	efeff0ef          	jal	80006f48 <fill_fs_common>
    e.type = FS_BLOCK_ALLOC;
    8000784e:	47d1                	li	a5,20
    80007850:	def42823          	sw	a5,-528(s0)
    e.blockno = block_allocated; // البلوك الذي تم حجزه فعلياً
    80007854:	eb242223          	sw	s2,-348(s0)
    safestrcpy(e.name, "BALLOC", FS_NM);
    80007858:	02000613          	li	a2,32
    8000785c:	00002597          	auipc	a1,0x2
    80007860:	ba458593          	addi	a1,a1,-1116 # 80009400 <etext+0x400>
    80007864:	e8440513          	addi	a0,s0,-380
    80007868:	e16f90ef          	jal	80000e7e <safestrcpy>
    fslog_push(&e);
    8000786c:	8526                	mv	a0,s1
    8000786e:	f50ff0ef          	jal	80006fbe <fslog_push>
}
    80007872:	21813083          	ld	ra,536(sp)
    80007876:	21013403          	ld	s0,528(sp)
    8000787a:	20813483          	ld	s1,520(sp)
    8000787e:	20013903          	ld	s2,512(sp)
    80007882:	22010113          	addi	sp,sp,544
    80007886:	8082                	ret

0000000080007888 <fslog_bfree>:
void fslog_bfree(int block_freed) {
    80007888:	de010113          	addi	sp,sp,-544
    8000788c:	20113c23          	sd	ra,536(sp)
    80007890:	20813823          	sd	s0,528(sp)
    80007894:	20913423          	sd	s1,520(sp)
    80007898:	21213023          	sd	s2,512(sp)
    8000789c:	1400                	addi	s0,sp,544
    8000789e:	892a                	mv	s2,a0
    struct fs_event e;
    fill_fs_common(&e);
    800078a0:	de040493          	addi	s1,s0,-544
    800078a4:	8526                	mv	a0,s1
    800078a6:	ea2ff0ef          	jal	80006f48 <fill_fs_common>
    e.type = FS_BLOCK_FREE;
    800078aa:	47d5                	li	a5,21
    800078ac:	def42823          	sw	a5,-528(s0)
    e.blockno = block_freed; // البلوك الذي تم تحريره
    800078b0:	eb242223          	sw	s2,-348(s0)
    safestrcpy(e.name, "BFREE", FS_NM);
    800078b4:	02000613          	li	a2,32
    800078b8:	00002597          	auipc	a1,0x2
    800078bc:	b3058593          	addi	a1,a1,-1232 # 800093e8 <etext+0x3e8>
    800078c0:	e8440513          	addi	a0,s0,-380
    800078c4:	dbaf90ef          	jal	80000e7e <safestrcpy>
    fslog_push(&e);
    800078c8:	8526                	mv	a0,s1
    800078ca:	ef4ff0ef          	jal	80006fbe <fslog_push>
}
    800078ce:	21813083          	ld	ra,536(sp)
    800078d2:	21013403          	ld	s0,528(sp)
    800078d6:	20813483          	ld	s1,520(sp)
    800078da:	20013903          	ld	s2,512(sp)
    800078de:	22010113          	addi	sp,sp,544
    800078e2:	8082                	ret

00000000800078e4 <fslog_ialloc>:
void fslog_ialloc(int inum, short type) {
    800078e4:	dd010113          	addi	sp,sp,-560
    800078e8:	22113423          	sd	ra,552(sp)
    800078ec:	22813023          	sd	s0,544(sp)
    800078f0:	20913c23          	sd	s1,536(sp)
    800078f4:	21213823          	sd	s2,528(sp)
    800078f8:	21313423          	sd	s3,520(sp)
    800078fc:	1c00                	addi	s0,sp,560
    800078fe:	892a                	mv	s2,a0
    80007900:	89ae                	mv	s3,a1
    struct fs_event e;
    fill_fs_common(&e);
    80007902:	dd040493          	addi	s1,s0,-560
    80007906:	8526                	mv	a0,s1
    80007908:	e40ff0ef          	jal	80006f48 <fill_fs_common>
    e.type = FS_INODE_ALLOC;
    8000790c:	47d9                	li	a5,22
    8000790e:	def42023          	sw	a5,-544(s0)
    e.inum = inum;
    80007912:	e9242e23          	sw	s2,-356(s0)
    e.i_type = type;
    80007916:	eb342623          	sw	s3,-340(s0)
    safestrcpy(e.name, "IALLOC", FS_NM);
    8000791a:	02000613          	li	a2,32
    8000791e:	00002597          	auipc	a1,0x2
    80007922:	c3a58593          	addi	a1,a1,-966 # 80009558 <etext+0x558>
    80007926:	e7440513          	addi	a0,s0,-396
    8000792a:	d54f90ef          	jal	80000e7e <safestrcpy>
    fslog_push(&e);
    8000792e:	8526                	mv	a0,s1
    80007930:	e8eff0ef          	jal	80006fbe <fslog_push>
}
    80007934:	22813083          	ld	ra,552(sp)
    80007938:	22013403          	ld	s0,544(sp)
    8000793c:	21813483          	ld	s1,536(sp)
    80007940:	21013903          	ld	s2,528(sp)
    80007944:	20813983          	ld	s3,520(sp)
    80007948:	23010113          	addi	sp,sp,560
    8000794c:	8082                	ret

000000008000794e <fslog_iget>:

void fslog_iget(int inum, int ref_before, int ref_after) {
    8000794e:	dd010113          	addi	sp,sp,-560
    80007952:	22113423          	sd	ra,552(sp)
    80007956:	22813023          	sd	s0,544(sp)
    8000795a:	20913c23          	sd	s1,536(sp)
    8000795e:	21213823          	sd	s2,528(sp)
    80007962:	21313423          	sd	s3,520(sp)
    80007966:	21413023          	sd	s4,512(sp)
    8000796a:	1c00                	addi	s0,sp,560
    8000796c:	892a                	mv	s2,a0
    8000796e:	89ae                	mv	s3,a1
    80007970:	8a32                	mv	s4,a2
    struct fs_event e;
    fill_fs_common(&e);
    80007972:	dd040493          	addi	s1,s0,-560
    80007976:	8526                	mv	a0,s1
    80007978:	dd0ff0ef          	jal	80006f48 <fill_fs_common>
    e.type = FS_INODE_GET;
    8000797c:	47dd                	li	a5,23
    8000797e:	def42023          	sw	a5,-544(s0)
    e.inum = inum;
    80007982:	e9242e23          	sw	s2,-356(s0)
    e.ref_before = ref_before;
    80007986:	eb342c23          	sw	s3,-328(s0)
    e.ref_after = ref_after;
    8000798a:	eb442e23          	sw	s4,-324(s0)
    safestrcpy(e.name, "IGET", FS_NM);
    8000798e:	02000613          	li	a2,32
    80007992:	00002597          	auipc	a1,0x2
    80007996:	51658593          	addi	a1,a1,1302 # 80009ea8 <etext+0xea8>
    8000799a:	e7440513          	addi	a0,s0,-396
    8000799e:	ce0f90ef          	jal	80000e7e <safestrcpy>
    fslog_push(&e);
    800079a2:	8526                	mv	a0,s1
    800079a4:	e1aff0ef          	jal	80006fbe <fslog_push>
}
    800079a8:	22813083          	ld	ra,552(sp)
    800079ac:	22013403          	ld	s0,544(sp)
    800079b0:	21813483          	ld	s1,536(sp)
    800079b4:	21013903          	ld	s2,528(sp)
    800079b8:	20813983          	ld	s3,520(sp)
    800079bc:	20013a03          	ld	s4,512(sp)
    800079c0:	23010113          	addi	sp,sp,560
    800079c4:	8082                	ret

00000000800079c6 <fslog_ilock>:
// في ملف kernel/fslog.c

void fslog_ilock(int inum, int locked) {
    800079c6:	dd010113          	addi	sp,sp,-560
    800079ca:	22113423          	sd	ra,552(sp)
    800079ce:	22813023          	sd	s0,544(sp)
    800079d2:	20913c23          	sd	s1,536(sp)
    800079d6:	21213823          	sd	s2,528(sp)
    800079da:	21313423          	sd	s3,520(sp)
    800079de:	1c00                	addi	s0,sp,560
    800079e0:	892a                	mv	s2,a0
    800079e2:	89ae                	mv	s3,a1
    struct fs_event e;
    fill_fs_common(&e);
    800079e4:	dd040493          	addi	s1,s0,-560
    800079e8:	8526                	mv	a0,s1
    800079ea:	d5eff0ef          	jal	80006f48 <fill_fs_common>
    e.type = FS_INODE_LOCK;
    800079ee:	47e1                	li	a5,24
    800079f0:	def42023          	sw	a5,-544(s0)
    e.inum = inum;
    800079f4:	e9242e23          	sw	s2,-356(s0)
    e.locked_after = locked; // 1 للـ Lock و 0 للـ Unlock
    800079f8:	ed342623          	sw	s3,-308(s0)
    e.ref_after = 1; // لضمان بقاء السطر في الواجهة
    800079fc:	4785                	li	a5,1
    800079fe:	eaf42e23          	sw	a5,-324(s0)
    safestrcpy(e.name, "ILOCK", FS_NM);
    80007a02:	02000613          	li	a2,32
    80007a06:	00002597          	auipc	a1,0x2
    80007a0a:	4aa58593          	addi	a1,a1,1194 # 80009eb0 <etext+0xeb0>
    80007a0e:	e7440513          	addi	a0,s0,-396
    80007a12:	c6cf90ef          	jal	80000e7e <safestrcpy>
    fslog_push(&e);
    80007a16:	8526                	mv	a0,s1
    80007a18:	da6ff0ef          	jal	80006fbe <fslog_push>
}
    80007a1c:	22813083          	ld	ra,552(sp)
    80007a20:	22013403          	ld	s0,544(sp)
    80007a24:	21813483          	ld	s1,536(sp)
    80007a28:	21013903          	ld	s2,528(sp)
    80007a2c:	20813983          	ld	s3,520(sp)
    80007a30:	23010113          	addi	sp,sp,560
    80007a34:	8082                	ret

0000000080007a36 <fslog_iupdate>:

void fslog_iupdate(struct inode *ip) {
    80007a36:	de010113          	addi	sp,sp,-544
    80007a3a:	20113c23          	sd	ra,536(sp)
    80007a3e:	20813823          	sd	s0,528(sp)
    80007a42:	20913423          	sd	s1,520(sp)
    80007a46:	1400                	addi	s0,sp,544
    80007a48:	84aa                	mv	s1,a0
    struct fs_event e;
    fill_fs_common(&e);
    80007a4a:	de040513          	addi	a0,s0,-544
    80007a4e:	cfaff0ef          	jal	80006f48 <fill_fs_common>
    e.type = FS_INODE_UPDATE;
    80007a52:	47e5                	li	a5,25
    80007a54:	def42823          	sw	a5,-528(s0)
    e.inum = ip->inum;
    80007a58:	40dc                	lw	a5,4(s1)
    80007a5a:	eaf42623          	sw	a5,-340(s0)
    e.i_type = ip->type;
    80007a5e:	04449783          	lh	a5,68(s1)
    80007a62:	eaf42e23          	sw	a5,-324(s0)
    e.i_size = ip->size;
    80007a66:	44fc                	lw	a5,76(s1)
    80007a68:	ecf42023          	sw	a5,-320(s0)
    e.nlink = ip->nlink;
    80007a6c:	04a49783          	lh	a5,74(s1)
    80007a70:	ecf42223          	sw	a5,-316(s0)
    e.ref_after = ip->ref; // مهم جداً للواجهة
    80007a74:	449c                	lw	a5,8(s1)
    80007a76:	ecf42623          	sw	a5,-308(s0)
    for(int i=0; i<13; i++) e.addrs[i] = ip->addrs[i];
    80007a7a:	05048513          	addi	a0,s1,80
    80007a7e:	f0c40793          	addi	a5,s0,-244
    80007a82:	f4040693          	addi	a3,s0,-192
    80007a86:	4118                	lw	a4,0(a0)
    80007a88:	c398                	sw	a4,0(a5)
    80007a8a:	0511                	addi	a0,a0,4
    80007a8c:	0791                	addi	a5,a5,4
    80007a8e:	fed79ce3          	bne	a5,a3,80007a86 <fslog_iupdate+0x50>
    safestrcpy(e.name, "IUPDATE", FS_NM);
    80007a92:	02000613          	li	a2,32
    80007a96:	00002597          	auipc	a1,0x2
    80007a9a:	afa58593          	addi	a1,a1,-1286 # 80009590 <etext+0x590>
    80007a9e:	e8440513          	addi	a0,s0,-380
    80007aa2:	bdcf90ef          	jal	80000e7e <safestrcpy>
    fslog_push(&e);
    80007aa6:	de040513          	addi	a0,s0,-544
    80007aaa:	d14ff0ef          	jal	80006fbe <fslog_push>
}
    80007aae:	21813083          	ld	ra,536(sp)
    80007ab2:	21013403          	ld	s0,528(sp)
    80007ab6:	20813483          	ld	s1,520(sp)
    80007aba:	22010113          	addi	sp,sp,544
    80007abe:	8082                	ret

0000000080007ac0 <fslog_iput>:
// داخل ملف kernel/fslog.c

void
fslog_iput(int inum, int old_ref, int new_ref)
{
    80007ac0:	dd010113          	addi	sp,sp,-560
    80007ac4:	22113423          	sd	ra,552(sp)
    80007ac8:	22813023          	sd	s0,544(sp)
    80007acc:	20913c23          	sd	s1,536(sp)
    80007ad0:	21213823          	sd	s2,528(sp)
    80007ad4:	21313423          	sd	s3,520(sp)
    80007ad8:	21413023          	sd	s4,512(sp)
    80007adc:	1c00                	addi	s0,sp,560
    80007ade:	892a                	mv	s2,a0
    80007ae0:	89ae                	mv	s3,a1
    80007ae2:	8a32                	mv	s4,a2
  struct fs_event e;
  fill_fs_common(&e);
    80007ae4:	dd040493          	addi	s1,s0,-560
    80007ae8:	8526                	mv	a0,s1
    80007aea:	c5eff0ef          	jal	80006f48 <fill_fs_common>
  e.type = FS_INODE_PUT; // تأكدي أن هذا الرقم (مثلاً 42) معرف في الـ Header
    80007aee:	47a5                	li	a5,9
    80007af0:	def42023          	sw	a5,-544(s0)
  e.inum = inum;
    80007af4:	e9242e23          	sw	s2,-356(s0)
  e.ref_before = old_ref;
    80007af8:	eb342c23          	sw	s3,-328(s0)
  e.ref_after = new_ref;
    80007afc:	eb442e23          	sw	s4,-324(s0)
  safestrcpy(e.name, "IPUT", FS_NM);
    80007b00:	02000613          	li	a2,32
    80007b04:	00002597          	auipc	a1,0x2
    80007b08:	b8c58593          	addi	a1,a1,-1140 # 80009690 <etext+0x690>
    80007b0c:	e7440513          	addi	a0,s0,-396
    80007b10:	b6ef90ef          	jal	80000e7e <safestrcpy>
  fslog_push(&e);
    80007b14:	8526                	mv	a0,s1
    80007b16:	ca8ff0ef          	jal	80006fbe <fslog_push>
    80007b1a:	22813083          	ld	ra,552(sp)
    80007b1e:	22013403          	ld	s0,544(sp)
    80007b22:	21813483          	ld	s1,536(sp)
    80007b26:	21013903          	ld	s2,528(sp)
    80007b2a:	20813983          	ld	s3,520(sp)
    80007b2e:	20013a03          	ld	s4,512(sp)
    80007b32:	23010113          	addi	sp,sp,560
    80007b36:	8082                	ret

0000000080007b38 <schedlog_init>:

static struct ringbuf sched_rb;

void
schedlog_init(void)
{
    80007b38:	1141                	addi	sp,sp,-16
    80007b3a:	e406                	sd	ra,8(sp)
    80007b3c:	e022                	sd	s0,0(sp)
    80007b3e:	0800                	addi	s0,sp,16
  ringbuf_init(&sched_rb, "schedlog", sizeof(struct sched_event));
    80007b40:	04400613          	li	a2,68
    80007b44:	00002597          	auipc	a1,0x2
    80007b48:	37458593          	addi	a1,a1,884 # 80009eb8 <etext+0xeb8>
    80007b4c:	0005c517          	auipc	a0,0x5c
    80007b50:	8cc50513          	addi	a0,a0,-1844 # 80063418 <sched_rb>
    80007b54:	a78ff0ef          	jal	80006dcc <ringbuf_init>
}
    80007b58:	60a2                	ld	ra,8(sp)
    80007b5a:	6402                	ld	s0,0(sp)
    80007b5c:	0141                	addi	sp,sp,16
    80007b5e:	8082                	ret

0000000080007b60 <schedlog_emit>:

void
schedlog_emit(struct sched_event *e)
{
    80007b60:	7159                	addi	sp,sp,-112
    80007b62:	f486                	sd	ra,104(sp)
    80007b64:	f0a2                	sd	s0,96(sp)
    80007b66:	eca6                	sd	s1,88(sp)
    80007b68:	1880                	addi	s0,sp,112
    80007b6a:	85aa                	mv	a1,a0
  struct sched_event copy;

  memmove(&copy, e, sizeof(copy));
    80007b6c:	f9840493          	addi	s1,s0,-104
    80007b70:	04400613          	li	a2,68
    80007b74:	8526                	mv	a0,s1
    80007b76:	a14f90ef          	jal	80000d8a <memmove>
  copy.seq = sched_rb.seq++;
    80007b7a:	0005c717          	auipc	a4,0x5c
    80007b7e:	89e70713          	addi	a4,a4,-1890 # 80063418 <sched_rb>
    80007b82:	771c                	ld	a5,40(a4)
    80007b84:	00178693          	addi	a3,a5,1
    80007b88:	f714                	sd	a3,40(a4)
    80007b8a:	f8f42c23          	sw	a5,-104(s0)
  ringbuf_push(&sched_rb, &copy);
    80007b8e:	85a6                	mv	a1,s1
    80007b90:	853a                	mv	a0,a4
    80007b92:	a6eff0ef          	jal	80006e00 <ringbuf_push>
}
    80007b96:	70a6                	ld	ra,104(sp)
    80007b98:	7406                	ld	s0,96(sp)
    80007b9a:	64e6                	ld	s1,88(sp)
    80007b9c:	6165                	addi	sp,sp,112
    80007b9e:	8082                	ret

0000000080007ba0 <schedread>:

int
schedread(struct sched_event *dst, int max)
{
    80007ba0:	1141                	addi	sp,sp,-16
    80007ba2:	e406                	sd	ra,8(sp)
    80007ba4:	e022                	sd	s0,0(sp)
    80007ba6:	0800                	addi	s0,sp,16
    80007ba8:	862e                	mv	a2,a1
  return ringbuf_read_many(&sched_rb, dst, max);
    80007baa:	85aa                	mv	a1,a0
    80007bac:	0005c517          	auipc	a0,0x5c
    80007bb0:	86c50513          	addi	a0,a0,-1940 # 80063418 <sched_rb>
    80007bb4:	ab8ff0ef          	jal	80006e6c <ringbuf_read_many>
    80007bb8:	60a2                	ld	ra,8(sp)
    80007bba:	6402                	ld	s0,0(sp)
    80007bbc:	0141                	addi	sp,sp,16
    80007bbe:	8082                	ret

0000000080007bc0 <memlog_init>:
static uint mem_count = 0;
static uint64 mem_seq = 0;

void
memlog_init(void)
{
    80007bc0:	1141                	addi	sp,sp,-16
    80007bc2:	e406                	sd	ra,8(sp)
    80007bc4:	e022                	sd	s0,0(sp)
    80007bc6:	0800                	addi	s0,sp,16
  initlock(&mem_lock, "memlog");
    80007bc8:	00002597          	auipc	a1,0x2
    80007bcc:	30058593          	addi	a1,a1,768 # 80009ec8 <etext+0xec8>
    80007bd0:	0007c517          	auipc	a0,0x7c
    80007bd4:	87850513          	addi	a0,a0,-1928 # 80083448 <mem_lock>
    80007bd8:	ff9f80ef          	jal	80000bd0 <initlock>
  mem_head = 0;
    80007bdc:	00002797          	auipc	a5,0x2
    80007be0:	4807aa23          	sw	zero,1172(a5) # 8000a070 <mem_head>
  mem_tail = 0;
    80007be4:	00002797          	auipc	a5,0x2
    80007be8:	4807a423          	sw	zero,1160(a5) # 8000a06c <mem_tail>
  mem_count = 0;
    80007bec:	00002797          	auipc	a5,0x2
    80007bf0:	4607ae23          	sw	zero,1148(a5) # 8000a068 <mem_count>
  mem_seq = 0;
    80007bf4:	00002797          	auipc	a5,0x2
    80007bf8:	4607b623          	sd	zero,1132(a5) # 8000a060 <mem_seq>
}
    80007bfc:	60a2                	ld	ra,8(sp)
    80007bfe:	6402                	ld	s0,0(sp)
    80007c00:	0141                	addi	sp,sp,16
    80007c02:	8082                	ret

0000000080007c04 <memlog_push>:

void
memlog_push(struct mem_event *e)
{
    80007c04:	1101                	addi	sp,sp,-32
    80007c06:	ec06                	sd	ra,24(sp)
    80007c08:	e822                	sd	s0,16(sp)
    80007c0a:	e426                	sd	s1,8(sp)
    80007c0c:	1000                	addi	s0,sp,32
    80007c0e:	84aa                	mv	s1,a0
  acquire(&mem_lock);
    80007c10:	0007c517          	auipc	a0,0x7c
    80007c14:	83850513          	addi	a0,a0,-1992 # 80083448 <mem_lock>
    80007c18:	842f90ef          	jal	80000c5a <acquire>

  e->seq = ++mem_seq;
    80007c1c:	00002717          	auipc	a4,0x2
    80007c20:	44470713          	addi	a4,a4,1092 # 8000a060 <mem_seq>
    80007c24:	631c                	ld	a5,0(a4)
    80007c26:	0785                	addi	a5,a5,1
    80007c28:	e31c                	sd	a5,0(a4)
    80007c2a:	e09c                	sd	a5,0(s1)

  if(mem_count == MEM_RB_CAP){
    80007c2c:	00002717          	auipc	a4,0x2
    80007c30:	43c72703          	lw	a4,1084(a4) # 8000a068 <mem_count>
    80007c34:	20000793          	li	a5,512
    80007c38:	06f70e63          	beq	a4,a5,80007cb4 <memlog_push+0xb0>
    mem_tail = (mem_tail + 1) % MEM_RB_CAP;
    mem_count--;
  }

  mem_buf[mem_head] = *e;
    80007c3c:	00002617          	auipc	a2,0x2
    80007c40:	43462603          	lw	a2,1076(a2) # 8000a070 <mem_head>
    80007c44:	02061693          	slli	a3,a2,0x20
    80007c48:	9281                	srli	a3,a3,0x20
    80007c4a:	06800793          	li	a5,104
    80007c4e:	02f686b3          	mul	a3,a3,a5
    80007c52:	8726                	mv	a4,s1
    80007c54:	0007c797          	auipc	a5,0x7c
    80007c58:	80c78793          	addi	a5,a5,-2036 # 80083460 <mem_buf>
    80007c5c:	97b6                	add	a5,a5,a3
    80007c5e:	06048493          	addi	s1,s1,96
    80007c62:	6308                	ld	a0,0(a4)
    80007c64:	670c                	ld	a1,8(a4)
    80007c66:	6b14                	ld	a3,16(a4)
    80007c68:	e388                	sd	a0,0(a5)
    80007c6a:	e78c                	sd	a1,8(a5)
    80007c6c:	eb94                	sd	a3,16(a5)
    80007c6e:	6f14                	ld	a3,24(a4)
    80007c70:	ef94                	sd	a3,24(a5)
    80007c72:	02070713          	addi	a4,a4,32
    80007c76:	02078793          	addi	a5,a5,32
    80007c7a:	fe9714e3          	bne	a4,s1,80007c62 <memlog_push+0x5e>
    80007c7e:	6318                	ld	a4,0(a4)
    80007c80:	e398                	sd	a4,0(a5)
  mem_head = (mem_head + 1) % MEM_RB_CAP;
    80007c82:	2605                	addiw	a2,a2,1
    80007c84:	1ff67613          	andi	a2,a2,511
    80007c88:	00002797          	auipc	a5,0x2
    80007c8c:	3ec7a423          	sw	a2,1000(a5) # 8000a070 <mem_head>
  mem_count++;
    80007c90:	00002717          	auipc	a4,0x2
    80007c94:	3d870713          	addi	a4,a4,984 # 8000a068 <mem_count>
    80007c98:	431c                	lw	a5,0(a4)
    80007c9a:	2785                	addiw	a5,a5,1
    80007c9c:	c31c                	sw	a5,0(a4)

  release(&mem_lock);
    80007c9e:	0007b517          	auipc	a0,0x7b
    80007ca2:	7aa50513          	addi	a0,a0,1962 # 80083448 <mem_lock>
    80007ca6:	848f90ef          	jal	80000cee <release>
}
    80007caa:	60e2                	ld	ra,24(sp)
    80007cac:	6442                	ld	s0,16(sp)
    80007cae:	64a2                	ld	s1,8(sp)
    80007cb0:	6105                	addi	sp,sp,32
    80007cb2:	8082                	ret
    mem_tail = (mem_tail + 1) % MEM_RB_CAP;
    80007cb4:	00002717          	auipc	a4,0x2
    80007cb8:	3b870713          	addi	a4,a4,952 # 8000a06c <mem_tail>
    80007cbc:	431c                	lw	a5,0(a4)
    80007cbe:	2785                	addiw	a5,a5,1
    80007cc0:	1ff7f793          	andi	a5,a5,511
    80007cc4:	c31c                	sw	a5,0(a4)
    mem_count--;
    80007cc6:	1ff00793          	li	a5,511
    80007cca:	00002717          	auipc	a4,0x2
    80007cce:	38f72f23          	sw	a5,926(a4) # 8000a068 <mem_count>
    80007cd2:	b7ad                	j	80007c3c <memlog_push+0x38>

0000000080007cd4 <memlog_read_many>:

int
memlog_read_many(struct mem_event *out, int max)
{
    80007cd4:	1101                	addi	sp,sp,-32
    80007cd6:	ec06                	sd	ra,24(sp)
    80007cd8:	e822                	sd	s0,16(sp)
    80007cda:	e04a                	sd	s2,0(sp)
    80007cdc:	1000                	addi	s0,sp,32
  int n = 0;

  if(max <= 0)
    return 0;
    80007cde:	4901                	li	s2,0
  if(max <= 0)
    80007ce0:	0ab05963          	blez	a1,80007d92 <memlog_read_many+0xbe>
    80007ce4:	e426                	sd	s1,8(sp)
    80007ce6:	892a                	mv	s2,a0
    80007ce8:	84ae                	mv	s1,a1

  acquire(&mem_lock);
    80007cea:	0007b517          	auipc	a0,0x7b
    80007cee:	75e50513          	addi	a0,a0,1886 # 80083448 <mem_lock>
    80007cf2:	f69f80ef          	jal	80000c5a <acquire>
  while(n < max && mem_count > 0){
    80007cf6:	00002697          	auipc	a3,0x2
    80007cfa:	3766a683          	lw	a3,886(a3) # 8000a06c <mem_tail>
    80007cfe:	00002317          	auipc	t1,0x2
    80007d02:	36a32303          	lw	t1,874(t1) # 8000a068 <mem_count>
    80007d06:	854a                	mv	a0,s2
  acquire(&mem_lock);
    80007d08:	4701                	li	a4,0
  int n = 0;
    80007d0a:	4901                	li	s2,0
    out[n] = mem_buf[mem_tail];
    80007d0c:	0007be97          	auipc	t4,0x7b
    80007d10:	754e8e93          	addi	t4,t4,1876 # 80083460 <mem_buf>
    80007d14:	06800e13          	li	t3,104
    80007d18:	4f05                	li	t5,1
  while(n < max && mem_count > 0){
    80007d1a:	08030263          	beqz	t1,80007d9e <memlog_read_many+0xca>
    out[n] = mem_buf[mem_tail];
    80007d1e:	02069793          	slli	a5,a3,0x20
    80007d22:	9381                	srli	a5,a5,0x20
    80007d24:	03c787b3          	mul	a5,a5,t3
    80007d28:	97f6                	add	a5,a5,t4
    80007d2a:	872a                	mv	a4,a0
    80007d2c:	06078613          	addi	a2,a5,96
    80007d30:	0007b883          	ld	a7,0(a5)
    80007d34:	0087b803          	ld	a6,8(a5)
    80007d38:	6b8c                	ld	a1,16(a5)
    80007d3a:	01173023          	sd	a7,0(a4)
    80007d3e:	01073423          	sd	a6,8(a4)
    80007d42:	eb0c                	sd	a1,16(a4)
    80007d44:	0187b803          	ld	a6,24(a5)
    80007d48:	01073c23          	sd	a6,24(a4)
    80007d4c:	02078793          	addi	a5,a5,32
    80007d50:	02070713          	addi	a4,a4,32
    80007d54:	fcc79ee3          	bne	a5,a2,80007d30 <memlog_read_many+0x5c>
    80007d58:	639c                	ld	a5,0(a5)
    80007d5a:	e31c                	sd	a5,0(a4)
    mem_tail = (mem_tail + 1) % MEM_RB_CAP;
    80007d5c:	2685                	addiw	a3,a3,1
    80007d5e:	1ff6f693          	andi	a3,a3,511
    mem_count--;
    80007d62:	fff3079b          	addiw	a5,t1,-1
    80007d66:	833e                	mv	t1,a5
    n++;
    80007d68:	2905                	addiw	s2,s2,1
  while(n < max && mem_count > 0){
    80007d6a:	06850513          	addi	a0,a0,104
    80007d6e:	877a                	mv	a4,t5
    80007d70:	fb2495e3          	bne	s1,s2,80007d1a <memlog_read_many+0x46>
    80007d74:	00002717          	auipc	a4,0x2
    80007d78:	2ed72c23          	sw	a3,760(a4) # 8000a06c <mem_tail>
    80007d7c:	00002717          	auipc	a4,0x2
    80007d80:	2ef72623          	sw	a5,748(a4) # 8000a068 <mem_count>
  }
  release(&mem_lock);
    80007d84:	0007b517          	auipc	a0,0x7b
    80007d88:	6c450513          	addi	a0,a0,1732 # 80083448 <mem_lock>
    80007d8c:	f63f80ef          	jal	80000cee <release>

  return n;
    80007d90:	64a2                	ld	s1,8(sp)
    80007d92:	854a                	mv	a0,s2
    80007d94:	60e2                	ld	ra,24(sp)
    80007d96:	6442                	ld	s0,16(sp)
    80007d98:	6902                	ld	s2,0(sp)
    80007d9a:	6105                	addi	sp,sp,32
    80007d9c:	8082                	ret
    80007d9e:	d37d                	beqz	a4,80007d84 <memlog_read_many+0xb0>
    80007da0:	00002797          	auipc	a5,0x2
    80007da4:	2cd7a623          	sw	a3,716(a5) # 8000a06c <mem_tail>
    80007da8:	00002797          	auipc	a5,0x2
    80007dac:	2c07a023          	sw	zero,704(a5) # 8000a068 <mem_count>
    80007db0:	bfd1                	j	80007d84 <memlog_read_many+0xb0>
	...

0000000080008000 <_trampoline>:
    80008000:	14051073          	csrw	sscratch,a0
    80008004:	02000537          	lui	a0,0x2000
    80008008:	357d                	addiw	a0,a0,-1 # 1ffffff <_entry-0x7e000001>
    8000800a:	0536                	slli	a0,a0,0xd
    8000800c:	02153423          	sd	ra,40(a0)
    80008010:	02253823          	sd	sp,48(a0)
    80008014:	02353c23          	sd	gp,56(a0)
    80008018:	04453023          	sd	tp,64(a0)
    8000801c:	04553423          	sd	t0,72(a0)
    80008020:	04653823          	sd	t1,80(a0)
    80008024:	04753c23          	sd	t2,88(a0)
    80008028:	f120                	sd	s0,96(a0)
    8000802a:	f524                	sd	s1,104(a0)
    8000802c:	fd2c                	sd	a1,120(a0)
    8000802e:	e150                	sd	a2,128(a0)
    80008030:	e554                	sd	a3,136(a0)
    80008032:	e958                	sd	a4,144(a0)
    80008034:	ed5c                	sd	a5,152(a0)
    80008036:	0b053023          	sd	a6,160(a0)
    8000803a:	0b153423          	sd	a7,168(a0)
    8000803e:	0b253823          	sd	s2,176(a0)
    80008042:	0b353c23          	sd	s3,184(a0)
    80008046:	0d453023          	sd	s4,192(a0)
    8000804a:	0d553423          	sd	s5,200(a0)
    8000804e:	0d653823          	sd	s6,208(a0)
    80008052:	0d753c23          	sd	s7,216(a0)
    80008056:	0f853023          	sd	s8,224(a0)
    8000805a:	0f953423          	sd	s9,232(a0)
    8000805e:	0fa53823          	sd	s10,240(a0)
    80008062:	0fb53c23          	sd	s11,248(a0)
    80008066:	11c53023          	sd	t3,256(a0)
    8000806a:	11d53423          	sd	t4,264(a0)
    8000806e:	11e53823          	sd	t5,272(a0)
    80008072:	11f53c23          	sd	t6,280(a0)
    80008076:	140022f3          	csrr	t0,sscratch
    8000807a:	06553823          	sd	t0,112(a0)
    8000807e:	00853103          	ld	sp,8(a0)
    80008082:	02053203          	ld	tp,32(a0)
    80008086:	01053283          	ld	t0,16(a0)
    8000808a:	00053303          	ld	t1,0(a0)
    8000808e:	12000073          	sfence.vma
    80008092:	18031073          	csrw	satp,t1
    80008096:	12000073          	sfence.vma
    8000809a:	9282                	jalr	t0

000000008000809c <userret>:
    8000809c:	12000073          	sfence.vma
    800080a0:	18051073          	csrw	satp,a0
    800080a4:	12000073          	sfence.vma
    800080a8:	02000537          	lui	a0,0x2000
    800080ac:	357d                	addiw	a0,a0,-1 # 1ffffff <_entry-0x7e000001>
    800080ae:	0536                	slli	a0,a0,0xd
    800080b0:	02853083          	ld	ra,40(a0)
    800080b4:	03053103          	ld	sp,48(a0)
    800080b8:	03853183          	ld	gp,56(a0)
    800080bc:	04053203          	ld	tp,64(a0)
    800080c0:	04853283          	ld	t0,72(a0)
    800080c4:	05053303          	ld	t1,80(a0)
    800080c8:	05853383          	ld	t2,88(a0)
    800080cc:	7120                	ld	s0,96(a0)
    800080ce:	7524                	ld	s1,104(a0)
    800080d0:	7d2c                	ld	a1,120(a0)
    800080d2:	6150                	ld	a2,128(a0)
    800080d4:	6554                	ld	a3,136(a0)
    800080d6:	6958                	ld	a4,144(a0)
    800080d8:	6d5c                	ld	a5,152(a0)
    800080da:	0a053803          	ld	a6,160(a0)
    800080de:	0a853883          	ld	a7,168(a0)
    800080e2:	0b053903          	ld	s2,176(a0)
    800080e6:	0b853983          	ld	s3,184(a0)
    800080ea:	0c053a03          	ld	s4,192(a0)
    800080ee:	0c853a83          	ld	s5,200(a0)
    800080f2:	0d053b03          	ld	s6,208(a0)
    800080f6:	0d853b83          	ld	s7,216(a0)
    800080fa:	0e053c03          	ld	s8,224(a0)
    800080fe:	0e853c83          	ld	s9,232(a0)
    80008102:	0f053d03          	ld	s10,240(a0)
    80008106:	0f853d83          	ld	s11,248(a0)
    8000810a:	10053e03          	ld	t3,256(a0)
    8000810e:	10853e83          	ld	t4,264(a0)
    80008112:	11053f03          	ld	t5,272(a0)
    80008116:	11853f83          	ld	t6,280(a0)
    8000811a:	7928                	ld	a0,112(a0)
    8000811c:	10200073          	sret
	...
