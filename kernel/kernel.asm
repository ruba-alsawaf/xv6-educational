
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
    80000004:	00010113          	mv	sp,sp
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
    8000001c:	1141                	addi	sp,sp,-16 # 80009ff0 <mem_head+0xf98>
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
    80000072:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffb6407>
    80000076:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    80000078:	6705                	lui	a4,0x1
    8000007a:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    8000007e:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r" (x));
    80000080:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r" (x));
    80000084:	00001797          	auipc	a5,0x1
    80000088:	f2478793          	addi	a5,a5,-220 # 80000fa8 <main>
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
    800000ee:	f1650513          	addi	a0,a0,-234 # 80012000 <conswlock>
    800000f2:	414040ef          	jal	80004506 <acquiresleep>

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
    80000126:	73c020ef          	jal	80002862 <either_copyin>
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
    8000016e:	e9650513          	addi	a0,a0,-362 # 80012000 <conswlock>
    80000172:	3da040ef          	jal	8000454c <releasesleep>
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
    800001aa:	e8a50513          	addi	a0,a0,-374 # 80012030 <cons>
    800001ae:	375000ef          	jal	80000d22 <acquire>

  while(n > 0){
    while(cons.r == cons.w){
    800001b2:	00012497          	auipc	s1,0x12
    800001b6:	e4e48493          	addi	s1,s1,-434 # 80012000 <conswlock>
      if(killed(myproc())){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    800001ba:	00012997          	auipc	s3,0x12
    800001be:	e7698993          	addi	s3,s3,-394 # 80012030 <cons>
    800001c2:	00012917          	auipc	s2,0x12
    800001c6:	f0690913          	addi	s2,s2,-250 # 800120c8 <cons+0x98>
  while(n > 0){
    800001ca:	0b405c63          	blez	s4,80000282 <consoleread+0xfa>
    while(cons.r == cons.w){
    800001ce:	0c84a783          	lw	a5,200(s1)
    800001d2:	0cc4a703          	lw	a4,204(s1)
    800001d6:	0af71163          	bne	a4,a5,80000278 <consoleread+0xf0>
      if(killed(myproc())){
    800001da:	2b9010ef          	jal	80001c92 <myproc>
    800001de:	51c020ef          	jal	800026fa <killed>
    800001e2:	e12d                	bnez	a0,80000244 <consoleread+0xbc>
      sleep(&cons.r, &cons.lock);
    800001e4:	85ce                	mv	a1,s3
    800001e6:	854a                	mv	a0,s2
    800001e8:	2d6020ef          	jal	800024be <sleep>
    while(cons.r == cons.w){
    800001ec:	0c84a783          	lw	a5,200(s1)
    800001f0:	0cc4a703          	lw	a4,204(s1)
    800001f4:	fef703e3          	beq	a4,a5,800001da <consoleread+0x52>
    800001f8:	f05a                	sd	s6,32(sp)
    }

    c = cons.buf[cons.r++ % INPUT_BUF_SIZE];
    800001fa:	00012717          	auipc	a4,0x12
    800001fe:	e0670713          	addi	a4,a4,-506 # 80012000 <conswlock>
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
    8000022c:	5ec020ef          	jal	80002818 <either_copyout>
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
    80000248:	dec50513          	addi	a0,a0,-532 # 80012030 <cons>
    8000024c:	36b000ef          	jal	80000db6 <release>
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
    80000270:	e4f72e23          	sw	a5,-420(a4) # 800120c8 <cons+0x98>
    80000274:	7b02                	ld	s6,32(sp)
    80000276:	a031                	j	80000282 <consoleread+0xfa>
    80000278:	f05a                	sd	s6,32(sp)
    8000027a:	b741                	j	800001fa <consoleread+0x72>
    8000027c:	7b02                	ld	s6,32(sp)
    8000027e:	a011                	j	80000282 <consoleread+0xfa>
    80000280:	7b02                	ld	s6,32(sp)
  release(&cons.lock);
    80000282:	00012517          	auipc	a0,0x12
    80000286:	dae50513          	addi	a0,a0,-594 # 80012030 <cons>
    8000028a:	32d000ef          	jal	80000db6 <release>
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
    800002da:	d5a50513          	addi	a0,a0,-678 # 80012030 <cons>
    800002de:	245000ef          	jal	80000d22 <acquire>

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
    800002f8:	5b4020ef          	jal	800028ac <procdump>
      }
    }
    break;
  }

  release(&cons.lock);
    800002fc:	00012517          	auipc	a0,0x12
    80000300:	d3450513          	addi	a0,a0,-716 # 80012030 <cons>
    80000304:	2b3000ef          	jal	80000db6 <release>
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
    8000031e:	ce670713          	addi	a4,a4,-794 # 80012000 <conswlock>
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
    80000344:	cc070713          	addi	a4,a4,-832 # 80012000 <conswlock>
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
    8000036e:	d5e72703          	lw	a4,-674(a4) # 800120c8 <cons+0x98>
    80000372:	9f99                	subw	a5,a5,a4
    80000374:	08000713          	li	a4,128
    80000378:	f8e792e3          	bne	a5,a4,800002fc <consoleintr+0x32>
    8000037c:	a075                	j	80000428 <consoleintr+0x15e>
    8000037e:	e04a                	sd	s2,0(sp)
    while(cons.e != cons.w &&
    80000380:	00012717          	auipc	a4,0x12
    80000384:	c8070713          	addi	a4,a4,-896 # 80012000 <conswlock>
    80000388:	0d072783          	lw	a5,208(a4)
    8000038c:	0cc72703          	lw	a4,204(a4)
          cons.buf[(cons.e - 1) % INPUT_BUF_SIZE] != '\n'){
    80000390:	00012497          	auipc	s1,0x12
    80000394:	c7048493          	addi	s1,s1,-912 # 80012000 <conswlock>
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
    800003d6:	c2e70713          	addi	a4,a4,-978 # 80012000 <conswlock>
    800003da:	0d072783          	lw	a5,208(a4)
    800003de:	0cc72703          	lw	a4,204(a4)
    800003e2:	f0f70de3          	beq	a4,a5,800002fc <consoleintr+0x32>
      cons.e--;
    800003e6:	37fd                	addiw	a5,a5,-1
    800003e8:	00012717          	auipc	a4,0x12
    800003ec:	cef72423          	sw	a5,-792(a4) # 800120d0 <cons+0xa0>
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
    8000040a:	bfa78793          	addi	a5,a5,-1030 # 80012000 <conswlock>
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
    8000042c:	cac7a223          	sw	a2,-860(a5) # 800120cc <cons+0x9c>
        wakeup(&cons.r);
    80000430:	00012517          	auipc	a0,0x12
    80000434:	c9850513          	addi	a0,a0,-872 # 800120c8 <cons+0x98>
    80000438:	0d2020ef          	jal	8000250a <wakeup>
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
    80000446:	00008597          	auipc	a1,0x8
    8000044a:	bba58593          	addi	a1,a1,-1094 # 80008000 <userret+0xf64>
    8000044e:	00012517          	auipc	a0,0x12
    80000452:	be250513          	addi	a0,a0,-1054 # 80012030 <cons>
    80000456:	043000ef          	jal	80000c98 <initlock>
  initsleeplock(&conswlock, "consw");
    8000045a:	00008597          	auipc	a1,0x8
    8000045e:	bb658593          	addi	a1,a1,-1098 # 80008010 <userret+0xf74>
    80000462:	00012517          	auipc	a0,0x12
    80000466:	b9e50513          	addi	a0,a0,-1122 # 80012000 <conswlock>
    8000046a:	066040ef          	jal	800044d0 <initsleeplock>

  uartinit();
    8000046e:	448000ef          	jal	800008b6 <uartinit>

  devsw[CONSOLE].read = consoleread;
    80000472:	00022797          	auipc	a5,0x22
    80000476:	d4678793          	addi	a5,a5,-698 # 800221b8 <devsw>
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
    800004b0:	00008817          	auipc	a6,0x8
    800004b4:	3b080813          	addi	a6,a6,944 # 80008860 <digits>
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
    8000054a:	00009797          	auipc	a5,0x9
    8000054e:	aba7a783          	lw	a5,-1350(a5) # 80009004 <panicking>
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
    80000594:	b4850513          	addi	a0,a0,-1208 # 800120d8 <pr>
    80000598:	78a000ef          	jal	80000d22 <acquire>
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
    80000704:	00008c97          	auipc	s9,0x8
    80000708:	15cc8c93          	addi	s9,s9,348 # 80008860 <digits>
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
    80000764:	00008a17          	auipc	s4,0x8
    80000768:	8b4a0a13          	addi	s4,s4,-1868 # 80008018 <userret+0xf7c>
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
    8000078c:	00009797          	auipc	a5,0x9
    80000790:	8787a783          	lw	a5,-1928(a5) # 80009004 <panicking>
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
    800007ba:	92250513          	addi	a0,a0,-1758 # 800120d8 <pr>
    800007be:	5f8000ef          	jal	80000db6 <release>
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
    80000866:	00008797          	auipc	a5,0x8
    8000086a:	7897af23          	sw	s1,1950(a5) # 80009004 <panicking>
  printf("panic: ");
    8000086e:	00007517          	auipc	a0,0x7
    80000872:	7b250513          	addi	a0,a0,1970 # 80008020 <userret+0xf84>
    80000876:	cb7ff0ef          	jal	8000052c <printf>
  printf("%s\n", s);
    8000087a:	85ca                	mv	a1,s2
    8000087c:	00007517          	auipc	a0,0x7
    80000880:	7ac50513          	addi	a0,a0,1964 # 80008028 <userret+0xf8c>
    80000884:	ca9ff0ef          	jal	8000052c <printf>
  panicked = 1; // freeze uart output from other CPUs
    80000888:	00008797          	auipc	a5,0x8
    8000088c:	7697ac23          	sw	s1,1912(a5) # 80009000 <panicked>
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
    8000089a:	00007597          	auipc	a1,0x7
    8000089e:	79658593          	addi	a1,a1,1942 # 80008030 <userret+0xf94>
    800008a2:	00012517          	auipc	a0,0x12
    800008a6:	83650513          	addi	a0,a0,-1994 # 800120d8 <pr>
    800008aa:	3ee000ef          	jal	80000c98 <initlock>
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
    800008f0:	00007597          	auipc	a1,0x7
    800008f4:	74858593          	addi	a1,a1,1864 # 80008038 <userret+0xf9c>
    800008f8:	00011517          	auipc	a0,0x11
    800008fc:	7f850513          	addi	a0,a0,2040 # 800120f0 <tx_lock>
    80000900:	398000ef          	jal	80000c98 <initlock>
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
    8000091c:	00011517          	auipc	a0,0x11
    80000920:	7d450513          	addi	a0,a0,2004 # 800120f0 <tx_lock>
    80000924:	3fe000ef          	jal	80000d22 <acquire>

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
    8000093a:	00008497          	auipc	s1,0x8
    8000093e:	6d248493          	addi	s1,s1,1746 # 8000900c <tx_busy>
      // wait for a UART transmit-complete interrupt
      // to set tx_busy to 0.
      sleep(&tx_chan, &tx_lock);
    80000942:	00011997          	auipc	s3,0x11
    80000946:	7ae98993          	addi	s3,s3,1966 # 800120f0 <tx_lock>
    8000094a:	00008917          	auipc	s2,0x8
    8000094e:	6be90913          	addi	s2,s2,1726 # 80009008 <tx_chan>
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
    8000095e:	361010ef          	jal	800024be <sleep>
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
    8000098c:	76850513          	addi	a0,a0,1896 # 800120f0 <tx_lock>
    80000990:	426000ef          	jal	80000db6 <release>
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
    800009ac:	00008797          	auipc	a5,0x8
    800009b0:	6587a783          	lw	a5,1624(a5) # 80009004 <panicking>
    800009b4:	cf95                	beqz	a5,800009f0 <uartputc_sync+0x50>
    push_off();

  if(panicked){
    800009b6:	00008797          	auipc	a5,0x8
    800009ba:	64a7a783          	lw	a5,1610(a5) # 80009000 <panicked>
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
    800009dc:	00008797          	auipc	a5,0x8
    800009e0:	6287a783          	lw	a5,1576(a5) # 80009004 <panicking>
    800009e4:	cb91                	beqz	a5,800009f8 <uartputc_sync+0x58>
    pop_off();
}
    800009e6:	60e2                	ld	ra,24(sp)
    800009e8:	6442                	ld	s0,16(sp)
    800009ea:	64a2                	ld	s1,8(sp)
    800009ec:	6105                	addi	sp,sp,32
    800009ee:	8082                	ret
    push_off();
    800009f0:	2ee000ef          	jal	80000cde <push_off>
    800009f4:	b7c9                	j	800009b6 <uartputc_sync+0x16>
    for(;;)
    800009f6:	a001                	j	800009f6 <uartputc_sync+0x56>
    pop_off();
    800009f8:	36e000ef          	jal	80000d66 <pop_off>
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
    80000a3c:	6b850513          	addi	a0,a0,1720 # 800120f0 <tx_lock>
    80000a40:	2e2000ef          	jal	80000d22 <acquire>
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
    80000a56:	69e50513          	addi	a0,a0,1694 # 800120f0 <tx_lock>
    80000a5a:	35c000ef          	jal	80000db6 <release>

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
    80000a6e:	00008797          	auipc	a5,0x8
    80000a72:	5807af23          	sw	zero,1438(a5) # 8000900c <tx_busy>
    wakeup(&tx_chan);
    80000a76:	00008517          	auipc	a0,0x8
    80000a7a:	59250513          	addi	a0,a0,1426 # 80009008 <tx_chan>
    80000a7e:	28d010ef          	jal	8000250a <wakeup>
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
    80000a8e:	7175                	addi	sp,sp,-144
    80000a90:	e506                	sd	ra,136(sp)
    80000a92:	e122                	sd	s0,128(sp)
    80000a94:	fca6                	sd	s1,120(sp)
    80000a96:	f8ca                	sd	s2,112(sp)
    80000a98:	0900                	addi	s0,sp,144
  struct run *r;

  if(((uint64)pa % PGSIZE) != 0 || (char*)pa < end || (uint64)pa >= PHYSTOP)
    80000a9a:	00048797          	auipc	a5,0x48
    80000a9e:	95e78793          	addi	a5,a5,-1698 # 800483f8 <end>
    80000aa2:	00f53733          	sltu	a4,a0,a5
    80000aa6:	47c5                	li	a5,17
    80000aa8:	07ee                	slli	a5,a5,0x1b
    80000aaa:	17fd                	addi	a5,a5,-1
    80000aac:	00a7b7b3          	sltu	a5,a5,a0
    80000ab0:	8fd9                	or	a5,a5,a4
    80000ab2:	e3c5                	bnez	a5,80000b52 <kfree+0xc4>
    80000ab4:	84aa                	mv	s1,a0
    80000ab6:	03451793          	slli	a5,a0,0x34
    80000aba:	efc1                	bnez	a5,80000b52 <kfree+0xc4>
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(pa, 1, PGSIZE);
    80000abc:	6605                	lui	a2,0x1
    80000abe:	4585                	li	a1,1
    80000ac0:	332000ef          	jal	80000df2 <memset>

  r = (struct run*)pa;

  acquire(&kmem.lock);
    80000ac4:	00011917          	auipc	s2,0x11
    80000ac8:	64490913          	addi	s2,s2,1604 # 80012108 <kmem>
    80000acc:	854a                	mv	a0,s2
    80000ace:	254000ef          	jal	80000d22 <acquire>
  r->next = kmem.freelist;
    80000ad2:	01893783          	ld	a5,24(s2)
    80000ad6:	e09c                	sd	a5,0(s1)
  kmem.freelist = r;
    80000ad8:	00993c23          	sd	s1,24(s2)
  release(&kmem.lock);
    80000adc:	854a                	mv	a0,s2
    80000ade:	2d8000ef          	jal	80000db6 <release>

  struct mem_event e;
  memset(&e, 0, sizeof(e));
    80000ae2:	06800613          	li	a2,104
    80000ae6:	4581                	li	a1,0
    80000ae8:	f7840513          	addi	a0,s0,-136
    80000aec:	306000ef          	jal	80000df2 <memset>

  e.ticks  = ticks;
    80000af0:	00008797          	auipc	a5,0x8
    80000af4:	5407a783          	lw	a5,1344(a5) # 80009030 <ticks>
    80000af8:	f8f42023          	sw	a5,-128(s0)
  e.cpu    = cpuid();
    80000afc:	162010ef          	jal	80001c5e <cpuid>
    80000b00:	f8a42223          	sw	a0,-124(s0)
  e.type   = MEM_FREE;
    80000b04:	479d                	li	a5,7
    80000b06:	f8f42423          	sw	a5,-120(s0)
  e.pa     = V2P(pa);
    80000b0a:	800007b7          	lui	a5,0x80000
    80000b0e:	94be                	add	s1,s1,a5
    80000b10:	fa943823          	sd	s1,-80(s0)
  e.source = SRC_KFREE;
    80000b14:	4789                	li	a5,2
    80000b16:	fcf42a23          	sw	a5,-44(s0)
  e.kind   = PAGE_UNKNOWN;
    80000b1a:	fc042c23          	sw	zero,-40(s0)

  struct proc *p = myproc();
    80000b1e:	174010ef          	jal	80001c92 <myproc>
  if(p){
    80000b22:	cd11                	beqz	a0,80000b3e <kfree+0xb0>
    e.pid = p->pid;
    80000b24:	591c                	lw	a5,48(a0)
    80000b26:	f8f42623          	sw	a5,-116(s0)
    e.state = p->state;
    80000b2a:	4d1c                	lw	a5,24(a0)
    80000b2c:	f8f42823          	sw	a5,-112(s0)
    safestrcpy(e.name, p->name, MEM_NM);
    80000b30:	4641                	li	a2,16
    80000b32:	15850593          	addi	a1,a0,344
    80000b36:	f9440513          	addi	a0,s0,-108
    80000b3a:	40c000ef          	jal	80000f46 <safestrcpy>
  }

  memlog_push(&e);
    80000b3e:	f7840513          	addi	a0,s0,-136
    80000b42:	20b050ef          	jal	8000654c <memlog_push>
}
    80000b46:	60aa                	ld	ra,136(sp)
    80000b48:	640a                	ld	s0,128(sp)
    80000b4a:	74e6                	ld	s1,120(sp)
    80000b4c:	7946                	ld	s2,112(sp)
    80000b4e:	6149                	addi	sp,sp,144
    80000b50:	8082                	ret
    panic("kfree");
    80000b52:	00007517          	auipc	a0,0x7
    80000b56:	4ee50513          	addi	a0,a0,1262 # 80008040 <userret+0xfa4>
    80000b5a:	cfdff0ef          	jal	80000856 <panic>

0000000080000b5e <freerange>:
{
    80000b5e:	7179                	addi	sp,sp,-48
    80000b60:	f406                	sd	ra,40(sp)
    80000b62:	f022                	sd	s0,32(sp)
    80000b64:	ec26                	sd	s1,24(sp)
    80000b66:	1800                	addi	s0,sp,48
  p = (char*)PGROUNDUP((uint64)pa_start);
    80000b68:	6785                	lui	a5,0x1
    80000b6a:	fff78713          	addi	a4,a5,-1 # fff <_entry-0x7ffff001>
    80000b6e:	00e504b3          	add	s1,a0,a4
    80000b72:	777d                	lui	a4,0xfffff
    80000b74:	8cf9                	and	s1,s1,a4
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000b76:	94be                	add	s1,s1,a5
    80000b78:	0295e263          	bltu	a1,s1,80000b9c <freerange+0x3e>
    80000b7c:	e84a                	sd	s2,16(sp)
    80000b7e:	e44e                	sd	s3,8(sp)
    80000b80:	e052                	sd	s4,0(sp)
    80000b82:	892e                	mv	s2,a1
    kfree(p);
    80000b84:	8a3a                	mv	s4,a4
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000b86:	89be                	mv	s3,a5
    kfree(p);
    80000b88:	01448533          	add	a0,s1,s4
    80000b8c:	f03ff0ef          	jal	80000a8e <kfree>
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000b90:	94ce                	add	s1,s1,s3
    80000b92:	fe997be3          	bgeu	s2,s1,80000b88 <freerange+0x2a>
    80000b96:	6942                	ld	s2,16(sp)
    80000b98:	69a2                	ld	s3,8(sp)
    80000b9a:	6a02                	ld	s4,0(sp)
}
    80000b9c:	70a2                	ld	ra,40(sp)
    80000b9e:	7402                	ld	s0,32(sp)
    80000ba0:	64e2                	ld	s1,24(sp)
    80000ba2:	6145                	addi	sp,sp,48
    80000ba4:	8082                	ret

0000000080000ba6 <kinit>:
{
    80000ba6:	1141                	addi	sp,sp,-16
    80000ba8:	e406                	sd	ra,8(sp)
    80000baa:	e022                	sd	s0,0(sp)
    80000bac:	0800                	addi	s0,sp,16
  initlock(&kmem.lock, "kmem");
    80000bae:	00007597          	auipc	a1,0x7
    80000bb2:	49a58593          	addi	a1,a1,1178 # 80008048 <userret+0xfac>
    80000bb6:	00011517          	auipc	a0,0x11
    80000bba:	55250513          	addi	a0,a0,1362 # 80012108 <kmem>
    80000bbe:	0da000ef          	jal	80000c98 <initlock>
  freerange(end, (void*)PHYSTOP);
    80000bc2:	45c5                	li	a1,17
    80000bc4:	05ee                	slli	a1,a1,0x1b
    80000bc6:	00048517          	auipc	a0,0x48
    80000bca:	83250513          	addi	a0,a0,-1998 # 800483f8 <end>
    80000bce:	f91ff0ef          	jal	80000b5e <freerange>
}
    80000bd2:	60a2                	ld	ra,8(sp)
    80000bd4:	6402                	ld	s0,0(sp)
    80000bd6:	0141                	addi	sp,sp,16
    80000bd8:	8082                	ret

0000000080000bda <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
    80000bda:	7175                	addi	sp,sp,-144
    80000bdc:	e506                	sd	ra,136(sp)
    80000bde:	e122                	sd	s0,128(sp)
    80000be0:	fca6                	sd	s1,120(sp)
    80000be2:	0900                	addi	s0,sp,144
  struct run *r;

  acquire(&kmem.lock);
    80000be4:	00011517          	auipc	a0,0x11
    80000be8:	52450513          	addi	a0,a0,1316 # 80012108 <kmem>
    80000bec:	136000ef          	jal	80000d22 <acquire>
  r = kmem.freelist;
    80000bf0:	00011497          	auipc	s1,0x11
    80000bf4:	5304b483          	ld	s1,1328(s1) # 80012120 <kmem+0x18>
  if(r)
    80000bf8:	c8c9                	beqz	s1,80000c8a <kalloc+0xb0>
    kmem.freelist = r->next;
    80000bfa:	609c                	ld	a5,0(s1)
    80000bfc:	00011717          	auipc	a4,0x11
    80000c00:	52f73223          	sd	a5,1316(a4) # 80012120 <kmem+0x18>
  release(&kmem.lock);
    80000c04:	00011517          	auipc	a0,0x11
    80000c08:	50450513          	addi	a0,a0,1284 # 80012108 <kmem>
    80000c0c:	1aa000ef          	jal	80000db6 <release>

  if(r)
    memset((char*)r, 5, PGSIZE); // fill with junk
    80000c10:	6605                	lui	a2,0x1
    80000c12:	4595                	li	a1,5
    80000c14:	8526                	mv	a0,s1
    80000c16:	1dc000ef          	jal	80000df2 <memset>

  if(r){
    struct mem_event e;
    memset(&e, 0, sizeof(e));
    80000c1a:	06800613          	li	a2,104
    80000c1e:	4581                	li	a1,0
    80000c20:	f7840513          	addi	a0,s0,-136
    80000c24:	1ce000ef          	jal	80000df2 <memset>

    e.ticks  = ticks;
    80000c28:	00008797          	auipc	a5,0x8
    80000c2c:	4087a783          	lw	a5,1032(a5) # 80009030 <ticks>
    80000c30:	f8f42023          	sw	a5,-128(s0)
    e.cpu    = cpuid();
    80000c34:	02a010ef          	jal	80001c5e <cpuid>
    80000c38:	f8a42223          	sw	a0,-124(s0)
    e.type   = MEM_ALLOC;
    80000c3c:	4799                	li	a5,6
    80000c3e:	f8f42423          	sw	a5,-120(s0)
    e.pa     = V2P(r);
    80000c42:	800007b7          	lui	a5,0x80000
    80000c46:	97a6                	add	a5,a5,s1
    80000c48:	faf43823          	sd	a5,-80(s0)
    e.source = SRC_KALLOC;
    80000c4c:	4785                	li	a5,1
    80000c4e:	fcf42a23          	sw	a5,-44(s0)
    e.kind   = PAGE_UNKNOWN;
    80000c52:	fc042c23          	sw	zero,-40(s0)

    struct proc *p = myproc();
    80000c56:	03c010ef          	jal	80001c92 <myproc>
    if(p){
    80000c5a:	cd11                	beqz	a0,80000c76 <kalloc+0x9c>
      e.pid = p->pid;
    80000c5c:	591c                	lw	a5,48(a0)
    80000c5e:	f8f42623          	sw	a5,-116(s0)
      e.state = p->state;
    80000c62:	4d1c                	lw	a5,24(a0)
    80000c64:	f8f42823          	sw	a5,-112(s0)
      safestrcpy(e.name, p->name, MEM_NM);
    80000c68:	4641                	li	a2,16
    80000c6a:	15850593          	addi	a1,a0,344
    80000c6e:	f9440513          	addi	a0,s0,-108
    80000c72:	2d4000ef          	jal	80000f46 <safestrcpy>
    }

    memlog_push(&e);
    80000c76:	f7840513          	addi	a0,s0,-136
    80000c7a:	0d3050ef          	jal	8000654c <memlog_push>
  }

  return (void*)r;
}
    80000c7e:	8526                	mv	a0,s1
    80000c80:	60aa                	ld	ra,136(sp)
    80000c82:	640a                	ld	s0,128(sp)
    80000c84:	74e6                	ld	s1,120(sp)
    80000c86:	6149                	addi	sp,sp,144
    80000c88:	8082                	ret
  release(&kmem.lock);
    80000c8a:	00011517          	auipc	a0,0x11
    80000c8e:	47e50513          	addi	a0,a0,1150 # 80012108 <kmem>
    80000c92:	124000ef          	jal	80000db6 <release>
  if(r)
    80000c96:	b7e5                	j	80000c7e <kalloc+0xa4>

0000000080000c98 <initlock>:
#include "proc.h"
#include "defs.h"

void
initlock(struct spinlock *lk, char *name)
{
    80000c98:	1141                	addi	sp,sp,-16
    80000c9a:	e406                	sd	ra,8(sp)
    80000c9c:	e022                	sd	s0,0(sp)
    80000c9e:	0800                	addi	s0,sp,16
  lk->name = name;
    80000ca0:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    80000ca2:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    80000ca6:	00053823          	sd	zero,16(a0)
}
    80000caa:	60a2                	ld	ra,8(sp)
    80000cac:	6402                	ld	s0,0(sp)
    80000cae:	0141                	addi	sp,sp,16
    80000cb0:	8082                	ret

0000000080000cb2 <holding>:
// Interrupts must be off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    80000cb2:	411c                	lw	a5,0(a0)
    80000cb4:	e399                	bnez	a5,80000cba <holding+0x8>
    80000cb6:	4501                	li	a0,0
  return r;
}
    80000cb8:	8082                	ret
{
    80000cba:	1101                	addi	sp,sp,-32
    80000cbc:	ec06                	sd	ra,24(sp)
    80000cbe:	e822                	sd	s0,16(sp)
    80000cc0:	e426                	sd	s1,8(sp)
    80000cc2:	1000                	addi	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    80000cc4:	691c                	ld	a5,16(a0)
    80000cc6:	84be                	mv	s1,a5
    80000cc8:	7ab000ef          	jal	80001c72 <mycpu>
    80000ccc:	40a48533          	sub	a0,s1,a0
    80000cd0:	00153513          	seqz	a0,a0
}
    80000cd4:	60e2                	ld	ra,24(sp)
    80000cd6:	6442                	ld	s0,16(sp)
    80000cd8:	64a2                	ld	s1,8(sp)
    80000cda:	6105                	addi	sp,sp,32
    80000cdc:	8082                	ret

0000000080000cde <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    80000cde:	1101                	addi	sp,sp,-32
    80000ce0:	ec06                	sd	ra,24(sp)
    80000ce2:	e822                	sd	s0,16(sp)
    80000ce4:	e426                	sd	s1,8(sp)
    80000ce6:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000ce8:	100027f3          	csrr	a5,sstatus
    80000cec:	84be                	mv	s1,a5
    80000cee:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80000cf2:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000cf4:	10079073          	csrw	sstatus,a5

  // disable interrupts to prevent an involuntary context
  // switch while using mycpu().
  intr_off();

  if(mycpu()->noff == 0)
    80000cf8:	77b000ef          	jal	80001c72 <mycpu>
    80000cfc:	5d3c                	lw	a5,120(a0)
    80000cfe:	cb99                	beqz	a5,80000d14 <push_off+0x36>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000d00:	773000ef          	jal	80001c72 <mycpu>
    80000d04:	5d3c                	lw	a5,120(a0)
    80000d06:	2785                	addiw	a5,a5,1 # ffffffff80000001 <end+0xfffffffefffb7c09>
    80000d08:	dd3c                	sw	a5,120(a0)
}
    80000d0a:	60e2                	ld	ra,24(sp)
    80000d0c:	6442                	ld	s0,16(sp)
    80000d0e:	64a2                	ld	s1,8(sp)
    80000d10:	6105                	addi	sp,sp,32
    80000d12:	8082                	ret
    mycpu()->intena = old;
    80000d14:	75f000ef          	jal	80001c72 <mycpu>
  return (x & SSTATUS_SIE) != 0;
    80000d18:	0014d793          	srli	a5,s1,0x1
    80000d1c:	8b85                	andi	a5,a5,1
    80000d1e:	dd7c                	sw	a5,124(a0)
    80000d20:	b7c5                	j	80000d00 <push_off+0x22>

0000000080000d22 <acquire>:
{
    80000d22:	1101                	addi	sp,sp,-32
    80000d24:	ec06                	sd	ra,24(sp)
    80000d26:	e822                	sd	s0,16(sp)
    80000d28:	e426                	sd	s1,8(sp)
    80000d2a:	1000                	addi	s0,sp,32
    80000d2c:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    80000d2e:	fb1ff0ef          	jal	80000cde <push_off>
  if(holding(lk))
    80000d32:	8526                	mv	a0,s1
    80000d34:	f7fff0ef          	jal	80000cb2 <holding>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000d38:	4705                	li	a4,1
  if(holding(lk))
    80000d3a:	e105                	bnez	a0,80000d5a <acquire+0x38>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000d3c:	87ba                	mv	a5,a4
    80000d3e:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80000d42:	2781                	sext.w	a5,a5
    80000d44:	ffe5                	bnez	a5,80000d3c <acquire+0x1a>
  __sync_synchronize();
    80000d46:	0330000f          	fence	rw,rw
  lk->cpu = mycpu();
    80000d4a:	729000ef          	jal	80001c72 <mycpu>
    80000d4e:	e888                	sd	a0,16(s1)
}
    80000d50:	60e2                	ld	ra,24(sp)
    80000d52:	6442                	ld	s0,16(sp)
    80000d54:	64a2                	ld	s1,8(sp)
    80000d56:	6105                	addi	sp,sp,32
    80000d58:	8082                	ret
    panic("acquire");
    80000d5a:	00007517          	auipc	a0,0x7
    80000d5e:	2f650513          	addi	a0,a0,758 # 80008050 <userret+0xfb4>
    80000d62:	af5ff0ef          	jal	80000856 <panic>

0000000080000d66 <pop_off>:

void
pop_off(void)
{
    80000d66:	1141                	addi	sp,sp,-16
    80000d68:	e406                	sd	ra,8(sp)
    80000d6a:	e022                	sd	s0,0(sp)
    80000d6c:	0800                	addi	s0,sp,16
  struct cpu *c = mycpu();
    80000d6e:	705000ef          	jal	80001c72 <mycpu>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000d72:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80000d76:	8b89                	andi	a5,a5,2
  if(intr_get())
    80000d78:	e39d                	bnez	a5,80000d9e <pop_off+0x38>
    panic("pop_off - interruptible");
  if(c->noff < 1)
    80000d7a:	5d3c                	lw	a5,120(a0)
    80000d7c:	02f05763          	blez	a5,80000daa <pop_off+0x44>
    panic("pop_off");
  c->noff -= 1;
    80000d80:	37fd                	addiw	a5,a5,-1
    80000d82:	dd3c                	sw	a5,120(a0)
  if(c->noff == 0 && c->intena)
    80000d84:	eb89                	bnez	a5,80000d96 <pop_off+0x30>
    80000d86:	5d7c                	lw	a5,124(a0)
    80000d88:	c799                	beqz	a5,80000d96 <pop_off+0x30>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000d8a:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80000d8e:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000d92:	10079073          	csrw	sstatus,a5
    intr_on();
}
    80000d96:	60a2                	ld	ra,8(sp)
    80000d98:	6402                	ld	s0,0(sp)
    80000d9a:	0141                	addi	sp,sp,16
    80000d9c:	8082                	ret
    panic("pop_off - interruptible");
    80000d9e:	00007517          	auipc	a0,0x7
    80000da2:	2ba50513          	addi	a0,a0,698 # 80008058 <userret+0xfbc>
    80000da6:	ab1ff0ef          	jal	80000856 <panic>
    panic("pop_off");
    80000daa:	00007517          	auipc	a0,0x7
    80000dae:	2c650513          	addi	a0,a0,710 # 80008070 <userret+0xfd4>
    80000db2:	aa5ff0ef          	jal	80000856 <panic>

0000000080000db6 <release>:
{
    80000db6:	1101                	addi	sp,sp,-32
    80000db8:	ec06                	sd	ra,24(sp)
    80000dba:	e822                	sd	s0,16(sp)
    80000dbc:	e426                	sd	s1,8(sp)
    80000dbe:	1000                	addi	s0,sp,32
    80000dc0:	84aa                	mv	s1,a0
  if(!holding(lk))
    80000dc2:	ef1ff0ef          	jal	80000cb2 <holding>
    80000dc6:	c105                	beqz	a0,80000de6 <release+0x30>
  lk->cpu = 0;
    80000dc8:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    80000dcc:	0330000f          	fence	rw,rw
  __sync_lock_release(&lk->locked);
    80000dd0:	0310000f          	fence	rw,w
    80000dd4:	0004a023          	sw	zero,0(s1)
  pop_off();
    80000dd8:	f8fff0ef          	jal	80000d66 <pop_off>
}
    80000ddc:	60e2                	ld	ra,24(sp)
    80000dde:	6442                	ld	s0,16(sp)
    80000de0:	64a2                	ld	s1,8(sp)
    80000de2:	6105                	addi	sp,sp,32
    80000de4:	8082                	ret
    panic("release");
    80000de6:	00007517          	auipc	a0,0x7
    80000dea:	29250513          	addi	a0,a0,658 # 80008078 <userret+0xfdc>
    80000dee:	a69ff0ef          	jal	80000856 <panic>

0000000080000df2 <memset>:
#include "types.h"

void*
memset(void *dst, int c, uint n)
{
    80000df2:	1141                	addi	sp,sp,-16
    80000df4:	e406                	sd	ra,8(sp)
    80000df6:	e022                	sd	s0,0(sp)
    80000df8:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    80000dfa:	ca19                	beqz	a2,80000e10 <memset+0x1e>
    80000dfc:	87aa                	mv	a5,a0
    80000dfe:	1602                	slli	a2,a2,0x20
    80000e00:	9201                	srli	a2,a2,0x20
    80000e02:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
    80000e06:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    80000e0a:	0785                	addi	a5,a5,1
    80000e0c:	fee79de3          	bne	a5,a4,80000e06 <memset+0x14>
  }
  return dst;
}
    80000e10:	60a2                	ld	ra,8(sp)
    80000e12:	6402                	ld	s0,0(sp)
    80000e14:	0141                	addi	sp,sp,16
    80000e16:	8082                	ret

0000000080000e18 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    80000e18:	1141                	addi	sp,sp,-16
    80000e1a:	e406                	sd	ra,8(sp)
    80000e1c:	e022                	sd	s0,0(sp)
    80000e1e:	0800                	addi	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    80000e20:	c61d                	beqz	a2,80000e4e <memcmp+0x36>
    80000e22:	1602                	slli	a2,a2,0x20
    80000e24:	9201                	srli	a2,a2,0x20
    80000e26:	00c506b3          	add	a3,a0,a2
    if(*s1 != *s2)
    80000e2a:	00054783          	lbu	a5,0(a0)
    80000e2e:	0005c703          	lbu	a4,0(a1)
    80000e32:	00e79863          	bne	a5,a4,80000e42 <memcmp+0x2a>
      return *s1 - *s2;
    s1++, s2++;
    80000e36:	0505                	addi	a0,a0,1
    80000e38:	0585                	addi	a1,a1,1
  while(n-- > 0){
    80000e3a:	fed518e3          	bne	a0,a3,80000e2a <memcmp+0x12>
  }

  return 0;
    80000e3e:	4501                	li	a0,0
    80000e40:	a019                	j	80000e46 <memcmp+0x2e>
      return *s1 - *s2;
    80000e42:	40e7853b          	subw	a0,a5,a4
}
    80000e46:	60a2                	ld	ra,8(sp)
    80000e48:	6402                	ld	s0,0(sp)
    80000e4a:	0141                	addi	sp,sp,16
    80000e4c:	8082                	ret
  return 0;
    80000e4e:	4501                	li	a0,0
    80000e50:	bfdd                	j	80000e46 <memcmp+0x2e>

0000000080000e52 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
    80000e52:	1141                	addi	sp,sp,-16
    80000e54:	e406                	sd	ra,8(sp)
    80000e56:	e022                	sd	s0,0(sp)
    80000e58:	0800                	addi	s0,sp,16
  const char *s;
  char *d;

  if(n == 0)
    80000e5a:	c205                	beqz	a2,80000e7a <memmove+0x28>
    return dst;
  
  s = src;
  d = dst;
  if(s < d && s + n > d){
    80000e5c:	02a5e363          	bltu	a1,a0,80000e82 <memmove+0x30>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
    80000e60:	1602                	slli	a2,a2,0x20
    80000e62:	9201                	srli	a2,a2,0x20
    80000e64:	00c587b3          	add	a5,a1,a2
{
    80000e68:	872a                	mv	a4,a0
      *d++ = *s++;
    80000e6a:	0585                	addi	a1,a1,1
    80000e6c:	0705                	addi	a4,a4,1
    80000e6e:	fff5c683          	lbu	a3,-1(a1)
    80000e72:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
    80000e76:	feb79ae3          	bne	a5,a1,80000e6a <memmove+0x18>

  return dst;
}
    80000e7a:	60a2                	ld	ra,8(sp)
    80000e7c:	6402                	ld	s0,0(sp)
    80000e7e:	0141                	addi	sp,sp,16
    80000e80:	8082                	ret
  if(s < d && s + n > d){
    80000e82:	02061693          	slli	a3,a2,0x20
    80000e86:	9281                	srli	a3,a3,0x20
    80000e88:	00d58733          	add	a4,a1,a3
    80000e8c:	fce57ae3          	bgeu	a0,a4,80000e60 <memmove+0xe>
    d += n;
    80000e90:	96aa                	add	a3,a3,a0
    while(n-- > 0)
    80000e92:	fff6079b          	addiw	a5,a2,-1 # fff <_entry-0x7ffff001>
    80000e96:	1782                	slli	a5,a5,0x20
    80000e98:	9381                	srli	a5,a5,0x20
    80000e9a:	fff7c793          	not	a5,a5
    80000e9e:	97ba                	add	a5,a5,a4
      *--d = *--s;
    80000ea0:	177d                	addi	a4,a4,-1
    80000ea2:	16fd                	addi	a3,a3,-1
    80000ea4:	00074603          	lbu	a2,0(a4)
    80000ea8:	00c68023          	sb	a2,0(a3)
    while(n-- > 0)
    80000eac:	fee79ae3          	bne	a5,a4,80000ea0 <memmove+0x4e>
    80000eb0:	b7e9                	j	80000e7a <memmove+0x28>

0000000080000eb2 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
    80000eb2:	1141                	addi	sp,sp,-16
    80000eb4:	e406                	sd	ra,8(sp)
    80000eb6:	e022                	sd	s0,0(sp)
    80000eb8:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    80000eba:	f99ff0ef          	jal	80000e52 <memmove>
}
    80000ebe:	60a2                	ld	ra,8(sp)
    80000ec0:	6402                	ld	s0,0(sp)
    80000ec2:	0141                	addi	sp,sp,16
    80000ec4:	8082                	ret

0000000080000ec6 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    80000ec6:	1141                	addi	sp,sp,-16
    80000ec8:	e406                	sd	ra,8(sp)
    80000eca:	e022                	sd	s0,0(sp)
    80000ecc:	0800                	addi	s0,sp,16
  while(n > 0 && *p && *p == *q)
    80000ece:	ce11                	beqz	a2,80000eea <strncmp+0x24>
    80000ed0:	00054783          	lbu	a5,0(a0)
    80000ed4:	cf89                	beqz	a5,80000eee <strncmp+0x28>
    80000ed6:	0005c703          	lbu	a4,0(a1)
    80000eda:	00f71a63          	bne	a4,a5,80000eee <strncmp+0x28>
    n--, p++, q++;
    80000ede:	367d                	addiw	a2,a2,-1
    80000ee0:	0505                	addi	a0,a0,1
    80000ee2:	0585                	addi	a1,a1,1
  while(n > 0 && *p && *p == *q)
    80000ee4:	f675                	bnez	a2,80000ed0 <strncmp+0xa>
  if(n == 0)
    return 0;
    80000ee6:	4501                	li	a0,0
    80000ee8:	a801                	j	80000ef8 <strncmp+0x32>
    80000eea:	4501                	li	a0,0
    80000eec:	a031                	j	80000ef8 <strncmp+0x32>
  return (uchar)*p - (uchar)*q;
    80000eee:	00054503          	lbu	a0,0(a0)
    80000ef2:	0005c783          	lbu	a5,0(a1)
    80000ef6:	9d1d                	subw	a0,a0,a5
}
    80000ef8:	60a2                	ld	ra,8(sp)
    80000efa:	6402                	ld	s0,0(sp)
    80000efc:	0141                	addi	sp,sp,16
    80000efe:	8082                	ret

0000000080000f00 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    80000f00:	1141                	addi	sp,sp,-16
    80000f02:	e406                	sd	ra,8(sp)
    80000f04:	e022                	sd	s0,0(sp)
    80000f06:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    80000f08:	87aa                	mv	a5,a0
    80000f0a:	a011                	j	80000f0e <strncpy+0xe>
    80000f0c:	8636                	mv	a2,a3
    80000f0e:	02c05863          	blez	a2,80000f3e <strncpy+0x3e>
    80000f12:	fff6069b          	addiw	a3,a2,-1
    80000f16:	8836                	mv	a6,a3
    80000f18:	0785                	addi	a5,a5,1
    80000f1a:	0005c703          	lbu	a4,0(a1)
    80000f1e:	fee78fa3          	sb	a4,-1(a5)
    80000f22:	0585                	addi	a1,a1,1
    80000f24:	f765                	bnez	a4,80000f0c <strncpy+0xc>
    ;
  while(n-- > 0)
    80000f26:	873e                	mv	a4,a5
    80000f28:	01005b63          	blez	a6,80000f3e <strncpy+0x3e>
    80000f2c:	9fb1                	addw	a5,a5,a2
    80000f2e:	37fd                	addiw	a5,a5,-1
    *s++ = 0;
    80000f30:	0705                	addi	a4,a4,1
    80000f32:	fe070fa3          	sb	zero,-1(a4)
  while(n-- > 0)
    80000f36:	40e786bb          	subw	a3,a5,a4
    80000f3a:	fed04be3          	bgtz	a3,80000f30 <strncpy+0x30>
  return os;
}
    80000f3e:	60a2                	ld	ra,8(sp)
    80000f40:	6402                	ld	s0,0(sp)
    80000f42:	0141                	addi	sp,sp,16
    80000f44:	8082                	ret

0000000080000f46 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
    80000f46:	1141                	addi	sp,sp,-16
    80000f48:	e406                	sd	ra,8(sp)
    80000f4a:	e022                	sd	s0,0(sp)
    80000f4c:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  if(n <= 0)
    80000f4e:	02c05363          	blez	a2,80000f74 <safestrcpy+0x2e>
    80000f52:	fff6069b          	addiw	a3,a2,-1
    80000f56:	1682                	slli	a3,a3,0x20
    80000f58:	9281                	srli	a3,a3,0x20
    80000f5a:	96ae                	add	a3,a3,a1
    80000f5c:	87aa                	mv	a5,a0
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
    80000f5e:	00d58963          	beq	a1,a3,80000f70 <safestrcpy+0x2a>
    80000f62:	0585                	addi	a1,a1,1
    80000f64:	0785                	addi	a5,a5,1
    80000f66:	fff5c703          	lbu	a4,-1(a1)
    80000f6a:	fee78fa3          	sb	a4,-1(a5)
    80000f6e:	fb65                	bnez	a4,80000f5e <safestrcpy+0x18>
    ;
  *s = 0;
    80000f70:	00078023          	sb	zero,0(a5)
  return os;
}
    80000f74:	60a2                	ld	ra,8(sp)
    80000f76:	6402                	ld	s0,0(sp)
    80000f78:	0141                	addi	sp,sp,16
    80000f7a:	8082                	ret

0000000080000f7c <strlen>:

int
strlen(const char *s)
{
    80000f7c:	1141                	addi	sp,sp,-16
    80000f7e:	e406                	sd	ra,8(sp)
    80000f80:	e022                	sd	s0,0(sp)
    80000f82:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    80000f84:	00054783          	lbu	a5,0(a0)
    80000f88:	cf91                	beqz	a5,80000fa4 <strlen+0x28>
    80000f8a:	00150793          	addi	a5,a0,1
    80000f8e:	86be                	mv	a3,a5
    80000f90:	0785                	addi	a5,a5,1
    80000f92:	fff7c703          	lbu	a4,-1(a5)
    80000f96:	ff65                	bnez	a4,80000f8e <strlen+0x12>
    80000f98:	40a6853b          	subw	a0,a3,a0
    ;
  return n;
}
    80000f9c:	60a2                	ld	ra,8(sp)
    80000f9e:	6402                	ld	s0,0(sp)
    80000fa0:	0141                	addi	sp,sp,16
    80000fa2:	8082                	ret
  for(n = 0; s[n]; n++)
    80000fa4:	4501                	li	a0,0
    80000fa6:	bfdd                	j	80000f9c <strlen+0x20>

0000000080000fa8 <main>:
volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    80000fa8:	1141                	addi	sp,sp,-16
    80000faa:	e406                	sd	ra,8(sp)
    80000fac:	e022                	sd	s0,0(sp)
    80000fae:	0800                	addi	s0,sp,16
  if(cpuid() == 0){
    80000fb0:	4af000ef          	jal	80001c5e <cpuid>
    memlog_init();
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    80000fb4:	00008717          	auipc	a4,0x8
    80000fb8:	05c70713          	addi	a4,a4,92 # 80009010 <started>
  if(cpuid() == 0){
    80000fbc:	c51d                	beqz	a0,80000fea <main+0x42>
    while(started == 0)
    80000fbe:	431c                	lw	a5,0(a4)
    80000fc0:	2781                	sext.w	a5,a5
    80000fc2:	dff5                	beqz	a5,80000fbe <main+0x16>
      ;
    __sync_synchronize();
    80000fc4:	0330000f          	fence	rw,rw
    printf("hart %d starting\n", cpuid());
    80000fc8:	497000ef          	jal	80001c5e <cpuid>
    80000fcc:	85aa                	mv	a1,a0
    80000fce:	00007517          	auipc	a0,0x7
    80000fd2:	0d250513          	addi	a0,a0,210 # 800080a0 <userret+0x1004>
    80000fd6:	d56ff0ef          	jal	8000052c <printf>
    kvminithart();    // turn on paging
    80000fda:	08c000ef          	jal	80001066 <kvminithart>
    trapinithart();   // install kernel trap vector
    80000fde:	201010ef          	jal	800029de <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000fe2:	327040ef          	jal	80005b08 <plicinithart>
  }

  scheduler();        
    80000fe6:	18e010ef          	jal	80002174 <scheduler>
    consoleinit();
    80000fea:	c54ff0ef          	jal	8000043e <consoleinit>
    printfinit();
    80000fee:	8a5ff0ef          	jal	80000892 <printfinit>
    printf("\n");
    80000ff2:	00007517          	auipc	a0,0x7
    80000ff6:	08e50513          	addi	a0,a0,142 # 80008080 <userret+0xfe4>
    80000ffa:	d32ff0ef          	jal	8000052c <printf>
    printf("xv6 kernel is booting\n");
    80000ffe:	00007517          	auipc	a0,0x7
    80001002:	08a50513          	addi	a0,a0,138 # 80008088 <userret+0xfec>
    80001006:	d26ff0ef          	jal	8000052c <printf>
    printf("\n");
    8000100a:	00007517          	auipc	a0,0x7
    8000100e:	07650513          	addi	a0,a0,118 # 80008080 <userret+0xfe4>
    80001012:	d1aff0ef          	jal	8000052c <printf>
    kinit();         // physical page allocator
    80001016:	b91ff0ef          	jal	80000ba6 <kinit>
    kvminit();       // create kernel page table
    8000101a:	3b6000ef          	jal	800013d0 <kvminit>
    kvminithart();   // turn on paging
    8000101e:	048000ef          	jal	80001066 <kvminithart>
    procinit();      // process table
    80001022:	373000ef          	jal	80001b94 <procinit>
    schedlog_init();
    80001026:	760050ef          	jal	80006786 <schedlog_init>
    trapinit();      // trap vectors
    8000102a:	191010ef          	jal	800029ba <trapinit>
    trapinithart();  // install kernel trap vector
    8000102e:	1b1010ef          	jal	800029de <trapinithart>
    plicinit();      // set up interrupt controller
    80001032:	2bd040ef          	jal	80005aee <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80001036:	2d3040ef          	jal	80005b08 <plicinithart>
    binit();         // buffer cache
    8000103a:	0d0020ef          	jal	8000310a <binit>
    iinit();         // inode table
    8000103e:	660020ef          	jal	8000369e <iinit>
    fileinit();      // file table
    80001042:	58c030ef          	jal	800045ce <fileinit>
    virtio_disk_init(); // emulated hard disk
    80001046:	3b3040ef          	jal	80005bf8 <virtio_disk_init>
    cslog_init();
    8000104a:	034050ef          	jal	8000607e <cslog_init>
    memlog_init();
    8000104e:	4ba050ef          	jal	80006508 <memlog_init>
    userinit();      // first user process
    80001052:	70b000ef          	jal	80001f5c <userinit>
    __sync_synchronize();
    80001056:	0330000f          	fence	rw,rw
    started = 1;
    8000105a:	4785                	li	a5,1
    8000105c:	00008717          	auipc	a4,0x8
    80001060:	faf72a23          	sw	a5,-76(a4) # 80009010 <started>
    80001064:	b749                	j	80000fe6 <main+0x3e>

0000000080001066 <kvminithart>:

// Switch the current CPU's h/w page table register to
// the kernel's page table, and enable paging.
void
kvminithart()
{
    80001066:	1101                	addi	sp,sp,-32
    80001068:	ec06                	sd	ra,24(sp)
    8000106a:	e822                	sd	s0,16(sp)
    8000106c:	e426                	sd	s1,8(sp)
    8000106e:	1000                	addi	s0,sp,32
  printf("kvminithart: starting extra-safe paging transition\n");
    80001070:	00007517          	auipc	a0,0x7
    80001074:	04850513          	addi	a0,a0,72 # 800080b8 <userret+0x101c>
    80001078:	cb4ff0ef          	jal	8000052c <printf>
  
  // Test that we can execute basic instructions before paging
  printf("kvminithart: pre-paging test passed\n");
    8000107c:	00007517          	auipc	a0,0x7
    80001080:	07450513          	addi	a0,a0,116 # 800080f0 <userret+0x1054>
    80001084:	ca8ff0ef          	jal	8000052c <printf>
  
  // Extra-safe assembly barrier sequence for perfect pipeline synchronization
  // This prevents CPU pre-fetching and ensures atomic paging transition
  uint64 satp_value = MAKE_SATP(V2P(kernel_pagetable));
    80001088:	00008497          	auipc	s1,0x8
    8000108c:	f904b483          	ld	s1,-112(s1) # 80009018 <kernel_pagetable>
    80001090:	800007b7          	lui	a5,0x80000
    80001094:	94be                	add	s1,s1,a5
    80001096:	80b1                	srli	s1,s1,0xc
    80001098:	57fd                	li	a5,-1
    8000109a:	17fe                	slli	a5,a5,0x3f
    8000109c:	8cdd                	or	s1,s1,a5
  
  printf("kvminithart: about to execute assembly sequence\n");
    8000109e:	00007517          	auipc	a0,0x7
    800010a2:	07a50513          	addi	a0,a0,122 # 80008118 <userret+0x107c>
    800010a6:	c86ff0ef          	jal	8000052c <printf>
  
  asm volatile(
    800010aa:	12000073          	sfence.vma
    800010ae:	18049073          	csrw	satp,s1
    800010b2:	12000073          	sfence.vma
    800010b6:	00000297          	auipc	t0,0x0
    800010ba:	02b1                	addi	t0,t0,12 # 800010c2 <kvminithart+0x5c>
    800010bc:	8282                	jr	t0
    800010be:	0001                	nop
    800010c0:	0001                	nop
    800010c2:	0001                	nop
    : 
    : "r"(satp_value)
    : "memory", "t0"
  );
  
  printf("kvminithart: successfully passed w_satp - paging enabled!\n");
    800010c4:	00007517          	auipc	a0,0x7
    800010c8:	08c50513          	addi	a0,a0,140 # 80008150 <userret+0x10b4>
    800010cc:	c60ff0ef          	jal	8000052c <printf>
}
    800010d0:	60e2                	ld	ra,24(sp)
    800010d2:	6442                	ld	s0,16(sp)
    800010d4:	64a2                	ld	s1,8(sp)
    800010d6:	6105                	addi	sp,sp,32
    800010d8:	8082                	ret

00000000800010da <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    800010da:	7139                	addi	sp,sp,-64
    800010dc:	fc06                	sd	ra,56(sp)
    800010de:	f822                	sd	s0,48(sp)
    800010e0:	f426                	sd	s1,40(sp)
    800010e2:	f04a                	sd	s2,32(sp)
    800010e4:	ec4e                	sd	s3,24(sp)
    800010e6:	e852                	sd	s4,16(sp)
    800010e8:	e456                	sd	s5,8(sp)
    800010ea:	e05a                	sd	s6,0(sp)
    800010ec:	0080                	addi	s0,sp,64
    800010ee:	84aa                	mv	s1,a0
    800010f0:	89ae                	mv	s3,a1
    800010f2:	8b32                	mv	s6,a2
  if(va >= MAXVA)
    800010f4:	57fd                	li	a5,-1
    800010f6:	83e9                	srli	a5,a5,0x1a
    800010f8:	4a79                	li	s4,30
    panic("walk");

  for(int level = 2; level > 0; level--) {
    800010fa:	4ab1                	li	s5,12
  if(va >= MAXVA)
    800010fc:	04b7e263          	bltu	a5,a1,80001140 <walk+0x66>
    pte_t *pte = &pagetable[PX(level, va)];
    80001100:	0149d933          	srl	s2,s3,s4
    80001104:	1ff97913          	andi	s2,s2,511
    80001108:	090e                	slli	s2,s2,0x3
    8000110a:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) {
    8000110c:	00093483          	ld	s1,0(s2)
    80001110:	0014f793          	andi	a5,s1,1
    80001114:	cf85                	beqz	a5,8000114c <walk+0x72>
      pagetable = (pagetable_t)PTE2PA(*pte);
    80001116:	80a9                	srli	s1,s1,0xa
    80001118:	04b2                	slli	s1,s1,0xc
  for(int level = 2; level > 0; level--) {
    8000111a:	3a5d                	addiw	s4,s4,-9
    8000111c:	ff5a12e3          	bne	s4,s5,80001100 <walk+0x26>
        return 0;
      memset(pagetable, 0, PGSIZE);
      *pte = PA2PTE(pagetable) | PTE_V;
    }
  }
  return &pagetable[PX(0, va)];
    80001120:	00c9d513          	srli	a0,s3,0xc
    80001124:	1ff57513          	andi	a0,a0,511
    80001128:	050e                	slli	a0,a0,0x3
    8000112a:	9526                	add	a0,a0,s1
}
    8000112c:	70e2                	ld	ra,56(sp)
    8000112e:	7442                	ld	s0,48(sp)
    80001130:	74a2                	ld	s1,40(sp)
    80001132:	7902                	ld	s2,32(sp)
    80001134:	69e2                	ld	s3,24(sp)
    80001136:	6a42                	ld	s4,16(sp)
    80001138:	6aa2                	ld	s5,8(sp)
    8000113a:	6b02                	ld	s6,0(sp)
    8000113c:	6121                	addi	sp,sp,64
    8000113e:	8082                	ret
    panic("walk");
    80001140:	00007517          	auipc	a0,0x7
    80001144:	05050513          	addi	a0,a0,80 # 80008190 <userret+0x10f4>
    80001148:	f0eff0ef          	jal	80000856 <panic>
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    8000114c:	020b0263          	beqz	s6,80001170 <walk+0x96>
    80001150:	a8bff0ef          	jal	80000bda <kalloc>
    80001154:	84aa                	mv	s1,a0
    80001156:	d979                	beqz	a0,8000112c <walk+0x52>
      memset(pagetable, 0, PGSIZE);
    80001158:	6605                	lui	a2,0x1
    8000115a:	4581                	li	a1,0
    8000115c:	c97ff0ef          	jal	80000df2 <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    80001160:	00c4d793          	srli	a5,s1,0xc
    80001164:	07aa                	slli	a5,a5,0xa
    80001166:	0017e793          	ori	a5,a5,1
    8000116a:	00f93023          	sd	a5,0(s2)
    8000116e:	b775                	j	8000111a <walk+0x40>
        return 0;
    80001170:	4501                	li	a0,0
    80001172:	bf6d                	j	8000112c <walk+0x52>

0000000080001174 <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if(va >= MAXVA)
    80001174:	57fd                	li	a5,-1
    80001176:	83e9                	srli	a5,a5,0x1a
    80001178:	00b7f463          	bgeu	a5,a1,80001180 <walkaddr+0xc>
    return 0;
    8000117c:	4501                	li	a0,0
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}
    8000117e:	8082                	ret
{
    80001180:	1141                	addi	sp,sp,-16
    80001182:	e406                	sd	ra,8(sp)
    80001184:	e022                	sd	s0,0(sp)
    80001186:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    80001188:	4601                	li	a2,0
    8000118a:	f51ff0ef          	jal	800010da <walk>
  if(pte == 0)
    8000118e:	c901                	beqz	a0,8000119e <walkaddr+0x2a>
  if((*pte & PTE_V) == 0)
    80001190:	611c                	ld	a5,0(a0)
  if((*pte & PTE_U) == 0)
    80001192:	0117f693          	andi	a3,a5,17
    80001196:	4745                	li	a4,17
    return 0;
    80001198:	4501                	li	a0,0
  if((*pte & PTE_U) == 0)
    8000119a:	00e68663          	beq	a3,a4,800011a6 <walkaddr+0x32>
}
    8000119e:	60a2                	ld	ra,8(sp)
    800011a0:	6402                	ld	s0,0(sp)
    800011a2:	0141                	addi	sp,sp,16
    800011a4:	8082                	ret
  pa = PTE2PA(*pte);
    800011a6:	83a9                	srli	a5,a5,0xa
    800011a8:	00c79513          	slli	a0,a5,0xc
  return pa;
    800011ac:	bfcd                	j	8000119e <walkaddr+0x2a>

00000000800011ae <mappages>:
// va and size MUST be page-aligned.
// Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    800011ae:	7115                	addi	sp,sp,-224
    800011b0:	ed86                	sd	ra,216(sp)
    800011b2:	e9a2                	sd	s0,208(sp)
    800011b4:	e5a6                	sd	s1,200(sp)
    800011b6:	e1ca                	sd	s2,192(sp)
    800011b8:	fd4e                	sd	s3,184(sp)
    800011ba:	f952                	sd	s4,176(sp)
    800011bc:	f556                	sd	s5,168(sp)
    800011be:	f15a                	sd	s6,160(sp)
    800011c0:	ed5e                	sd	s7,152(sp)
    800011c2:	e962                	sd	s8,144(sp)
    800011c4:	e566                	sd	s9,136(sp)
    800011c6:	e16a                	sd	s10,128(sp)
    800011c8:	fcee                	sd	s11,120(sp)
    800011ca:	1180                	addi	s0,sp,224
  uint64 a, last;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    800011cc:	03459793          	slli	a5,a1,0x34
    800011d0:	eb8d                	bnez	a5,80001202 <mappages+0x54>
    800011d2:	8c2a                	mv	s8,a0
    800011d4:	8aba                	mv	s5,a4
    panic("mappages: va not aligned");

  if((size % PGSIZE) != 0)
    800011d6:	03461793          	slli	a5,a2,0x34
    800011da:	eb95                	bnez	a5,8000120e <mappages+0x60>
    panic("mappages: size not aligned");

  if(size == 0)
    800011dc:	ce1d                	beqz	a2,8000121a <mappages+0x6c>
    panic("mappages: size");
  
  a = va;
  last = va + size - PGSIZE;
    800011de:	80060613          	addi	a2,a2,-2048 # 800 <_entry-0x7ffff800>
    800011e2:	80060613          	addi	a2,a2,-2048
    800011e6:	00b60a33          	add	s4,a2,a1
  a = va;
    800011ea:	892e                	mv	s2,a1
  for(;;){
       if((pte = walk(pagetable, a, 1)) == 0)
    800011ec:	4b05                	li	s6,1
    800011ee:	40b68bb3          	sub	s7,a3,a1
    *pte = PA2PTE(pa) | perm | PTE_V;

    struct proc *p = myproc();
    if(p){
      struct mem_event e;
      memset(&e, 0, sizeof(e));
    800011f2:	f2840c93          	addi	s9,s0,-216
      e.ticks  = ticks;
    800011f6:	00008d97          	auipc	s11,0x8
    800011fa:	e3ad8d93          	addi	s11,s11,-454 # 80009030 <ticks>
      e.cpu    = cpuid();
      e.type   = MEM_MAP;
    800011fe:	4d11                	li	s10,4
    80001200:	a82d                	j	8000123a <mappages+0x8c>
    panic("mappages: va not aligned");
    80001202:	00007517          	auipc	a0,0x7
    80001206:	f9650513          	addi	a0,a0,-106 # 80008198 <userret+0x10fc>
    8000120a:	e4cff0ef          	jal	80000856 <panic>
    panic("mappages: size not aligned");
    8000120e:	00007517          	auipc	a0,0x7
    80001212:	faa50513          	addi	a0,a0,-86 # 800081b8 <userret+0x111c>
    80001216:	e40ff0ef          	jal	80000856 <panic>
    panic("mappages: size");
    8000121a:	00007517          	auipc	a0,0x7
    8000121e:	fbe50513          	addi	a0,a0,-66 # 800081d8 <userret+0x113c>
    80001222:	e34ff0ef          	jal	80000856 <panic>
      panic("mappages: remap");
    80001226:	00007517          	auipc	a0,0x7
    8000122a:	fc250513          	addi	a0,a0,-62 # 800081e8 <userret+0x114c>
    8000122e:	e28ff0ef          	jal	80000856 <panic>
      e.kind   = PAGE_USER;
      safestrcpy(e.name, p->name, MEM_NM);
      memlog_push(&e);
    }

    if(a == last)
    80001232:	0b490763          	beq	s2,s4,800012e0 <mappages+0x132>
      break;
    a += PGSIZE;
    80001236:	6785                	lui	a5,0x1
    80001238:	993e                	add	s2,s2,a5
       if((pte = walk(pagetable, a, 1)) == 0)
    8000123a:	865a                	mv	a2,s6
    8000123c:	85ca                	mv	a1,s2
    8000123e:	8562                	mv	a0,s8
    80001240:	e9bff0ef          	jal	800010da <walk>
    80001244:	cd35                	beqz	a0,800012c0 <mappages+0x112>
    if(*pte & PTE_V)
    80001246:	611c                	ld	a5,0(a0)
    80001248:	8b85                	andi	a5,a5,1
    8000124a:	fff1                	bnez	a5,80001226 <mappages+0x78>
    8000124c:	017909b3          	add	s3,s2,s7
    *pte = PA2PTE(pa) | perm | PTE_V;
    80001250:	00c9d793          	srli	a5,s3,0xc
    80001254:	07aa                	slli	a5,a5,0xa
    80001256:	0157e7b3          	or	a5,a5,s5
    8000125a:	0017e793          	ori	a5,a5,1
    8000125e:	e11c                	sd	a5,0(a0)
    struct proc *p = myproc();
    80001260:	233000ef          	jal	80001c92 <myproc>
    80001264:	84aa                	mv	s1,a0
    if(p){
    80001266:	d571                	beqz	a0,80001232 <mappages+0x84>
      memset(&e, 0, sizeof(e));
    80001268:	06800613          	li	a2,104
    8000126c:	4581                	li	a1,0
    8000126e:	8566                	mv	a0,s9
    80001270:	b83ff0ef          	jal	80000df2 <memset>
      e.ticks  = ticks;
    80001274:	000da783          	lw	a5,0(s11)
    80001278:	f2f42823          	sw	a5,-208(s0)
      e.cpu    = cpuid();
    8000127c:	1e3000ef          	jal	80001c5e <cpuid>
    80001280:	f2a42a23          	sw	a0,-204(s0)
      e.type   = MEM_MAP;
    80001284:	f3a42c23          	sw	s10,-200(s0)
      e.pid    = p->pid;
    80001288:	589c                	lw	a5,48(s1)
    8000128a:	f2f42e23          	sw	a5,-196(s0)
      e.state  = p->state;
    8000128e:	4c9c                	lw	a5,24(s1)
    80001290:	f4f42023          	sw	a5,-192(s0)
      e.va     = a;
    80001294:	f5243c23          	sd	s2,-168(s0)
      e.pa     = pa;
    80001298:	f7343023          	sd	s3,-160(s0)
      e.perm   = perm;
    8000129c:	f9542023          	sw	s5,-128(s0)
      e.source = SRC_MAPPAGES;
    800012a0:	478d                	li	a5,3
    800012a2:	f8f42223          	sw	a5,-124(s0)
      e.kind   = PAGE_USER;
    800012a6:	f9642423          	sw	s6,-120(s0)
      safestrcpy(e.name, p->name, MEM_NM);
    800012aa:	4641                	li	a2,16
    800012ac:	15848593          	addi	a1,s1,344
    800012b0:	f4440513          	addi	a0,s0,-188
    800012b4:	c93ff0ef          	jal	80000f46 <safestrcpy>
      memlog_push(&e);
    800012b8:	8566                	mv	a0,s9
    800012ba:	292050ef          	jal	8000654c <memlog_push>
    800012be:	bf95                	j	80001232 <mappages+0x84>
      return -1;
    800012c0:	557d                	li	a0,-1
    pa += PGSIZE;
  }
  return 0;
}
    800012c2:	60ee                	ld	ra,216(sp)
    800012c4:	644e                	ld	s0,208(sp)
    800012c6:	64ae                	ld	s1,200(sp)
    800012c8:	690e                	ld	s2,192(sp)
    800012ca:	79ea                	ld	s3,184(sp)
    800012cc:	7a4a                	ld	s4,176(sp)
    800012ce:	7aaa                	ld	s5,168(sp)
    800012d0:	7b0a                	ld	s6,160(sp)
    800012d2:	6bea                	ld	s7,152(sp)
    800012d4:	6c4a                	ld	s8,144(sp)
    800012d6:	6caa                	ld	s9,136(sp)
    800012d8:	6d0a                	ld	s10,128(sp)
    800012da:	7de6                	ld	s11,120(sp)
    800012dc:	612d                	addi	sp,sp,224
    800012de:	8082                	ret
  return 0;
    800012e0:	4501                	li	a0,0
    800012e2:	b7c5                	j	800012c2 <mappages+0x114>

00000000800012e4 <kvmmap>:
{
    800012e4:	1141                	addi	sp,sp,-16
    800012e6:	e406                	sd	ra,8(sp)
    800012e8:	e022                	sd	s0,0(sp)
    800012ea:	0800                	addi	s0,sp,16
    800012ec:	87b6                	mv	a5,a3
  if(mappages(kpgtbl, va, sz, pa, perm) != 0)
    800012ee:	86b2                	mv	a3,a2
    800012f0:	863e                	mv	a2,a5
    800012f2:	ebdff0ef          	jal	800011ae <mappages>
    800012f6:	e509                	bnez	a0,80001300 <kvmmap+0x1c>
}
    800012f8:	60a2                	ld	ra,8(sp)
    800012fa:	6402                	ld	s0,0(sp)
    800012fc:	0141                	addi	sp,sp,16
    800012fe:	8082                	ret
    panic("kvmmap");
    80001300:	00007517          	auipc	a0,0x7
    80001304:	ef850513          	addi	a0,a0,-264 # 800081f8 <userret+0x115c>
    80001308:	d4eff0ef          	jal	80000856 <panic>

000000008000130c <kvmmake>:
{
    8000130c:	1101                	addi	sp,sp,-32
    8000130e:	ec06                	sd	ra,24(sp)
    80001310:	e822                	sd	s0,16(sp)
    80001312:	e426                	sd	s1,8(sp)
    80001314:	1000                	addi	s0,sp,32
  kpgtbl = (pagetable_t) kalloc();
    80001316:	8c5ff0ef          	jal	80000bda <kalloc>
    8000131a:	84aa                	mv	s1,a0
  memset(kpgtbl, 0, PGSIZE);
    8000131c:	6605                	lui	a2,0x1
    8000131e:	4581                	li	a1,0
    80001320:	ad3ff0ef          	jal	80000df2 <memset>
  kvmmap(kpgtbl, UART0, UART0, PGSIZE, PTE_R | PTE_W);
    80001324:	4719                	li	a4,6
    80001326:	6685                	lui	a3,0x1
    80001328:	10000637          	lui	a2,0x10000
    8000132c:	85b2                	mv	a1,a2
    8000132e:	8526                	mv	a0,s1
    80001330:	fb5ff0ef          	jal	800012e4 <kvmmap>
  kvmmap(kpgtbl, VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    80001334:	4719                	li	a4,6
    80001336:	6685                	lui	a3,0x1
    80001338:	10001637          	lui	a2,0x10001
    8000133c:	85b2                	mv	a1,a2
    8000133e:	8526                	mv	a0,s1
    80001340:	fa5ff0ef          	jal	800012e4 <kvmmap>
  kvmmap(kpgtbl, PLIC, PLIC, 0x4000000, PTE_R | PTE_W);
    80001344:	4719                	li	a4,6
    80001346:	040006b7          	lui	a3,0x4000
    8000134a:	0c000637          	lui	a2,0xc000
    8000134e:	85b2                	mv	a1,a2
    80001350:	8526                	mv	a0,s1
    80001352:	f93ff0ef          	jal	800012e4 <kvmmap>
  kvmmap(kpgtbl, KERNBASE, KERNBASE, (uint64)stack0 - KERNBASE, PTE_R | PTE_W | PTE_X);
    80001356:	4739                	li	a4,14
    80001358:	80009697          	auipc	a3,0x80009
    8000135c:	ca868693          	addi	a3,a3,-856 # a000 <_entry-0x7fff6000>
    80001360:	4605                	li	a2,1
    80001362:	067e                	slli	a2,a2,0x1f
    80001364:	85b2                	mv	a1,a2
    80001366:	8526                	mv	a0,s1
    80001368:	f7dff0ef          	jal	800012e4 <kvmmap>
  kvmmap(kpgtbl, (uint64)stack0 + 4096 * NCPU, (uint64)stack0 + 4096 * NCPU, 
    8000136c:	4739                	li	a4,14
    8000136e:	00009697          	auipc	a3,0x9
    80001372:	c9268693          	addi	a3,a3,-878 # 8000a000 <stack0>
    80001376:	10fff7b7          	lui	a5,0x10fff
    8000137a:	078e                	slli	a5,a5,0x3
    8000137c:	40d786b3          	sub	a3,a5,a3
    80001380:	00011617          	auipc	a2,0x11
    80001384:	c8060613          	addi	a2,a2,-896 # 80012000 <conswlock>
    80001388:	85b2                	mv	a1,a2
    8000138a:	8526                	mv	a0,s1
    8000138c:	f59ff0ef          	jal	800012e4 <kvmmap>
  kvmmap(kpgtbl, TRAMPOLINE, V2P(trampoline), PGSIZE, PTE_R | PTE_X);
    80001390:	4729                	li	a4,10
    80001392:	6685                	lui	a3,0x1
    80001394:	80006617          	auipc	a2,0x80006
    80001398:	c6c60613          	addi	a2,a2,-916 # 7000 <_entry-0x7fff9000>
    8000139c:	040005b7          	lui	a1,0x4000
    800013a0:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    800013a2:	05b2                	slli	a1,a1,0xc
    800013a4:	8526                	mv	a0,s1
    800013a6:	f3fff0ef          	jal	800012e4 <kvmmap>
  kvmmap(kpgtbl, (uint64)stack0, (uint64)stack0, 4096 * NCPU, PTE_R | PTE_W | PTE_X);
    800013aa:	4739                	li	a4,14
    800013ac:	66a1                	lui	a3,0x8
    800013ae:	00009617          	auipc	a2,0x9
    800013b2:	c5260613          	addi	a2,a2,-942 # 8000a000 <stack0>
    800013b6:	85b2                	mv	a1,a2
    800013b8:	8526                	mv	a0,s1
    800013ba:	f2bff0ef          	jal	800012e4 <kvmmap>
  proc_mapstacks(kpgtbl);
    800013be:	8526                	mv	a0,s1
    800013c0:	730000ef          	jal	80001af0 <proc_mapstacks>
}
    800013c4:	8526                	mv	a0,s1
    800013c6:	60e2                	ld	ra,24(sp)
    800013c8:	6442                	ld	s0,16(sp)
    800013ca:	64a2                	ld	s1,8(sp)
    800013cc:	6105                	addi	sp,sp,32
    800013ce:	8082                	ret

00000000800013d0 <kvminit>:
{
    800013d0:	1141                	addi	sp,sp,-16
    800013d2:	e406                	sd	ra,8(sp)
    800013d4:	e022                	sd	s0,0(sp)
    800013d6:	0800                	addi	s0,sp,16
  kernel_pagetable = kvmmake();
    800013d8:	f35ff0ef          	jal	8000130c <kvmmake>
    800013dc:	00008797          	auipc	a5,0x8
    800013e0:	c2a7be23          	sd	a0,-964(a5) # 80009018 <kernel_pagetable>
}
    800013e4:	60a2                	ld	ra,8(sp)
    800013e6:	6402                	ld	s0,0(sp)
    800013e8:	0141                	addi	sp,sp,16
    800013ea:	8082                	ret

00000000800013ec <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    800013ec:	1101                	addi	sp,sp,-32
    800013ee:	ec06                	sd	ra,24(sp)
    800013f0:	e822                	sd	s0,16(sp)
    800013f2:	e426                	sd	s1,8(sp)
    800013f4:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t) kalloc();
    800013f6:	fe4ff0ef          	jal	80000bda <kalloc>
    800013fa:	84aa                	mv	s1,a0
  if(pagetable == 0)
    800013fc:	c509                	beqz	a0,80001406 <uvmcreate+0x1a>
    return 0;
  memset(pagetable, 0, PGSIZE);
    800013fe:	6605                	lui	a2,0x1
    80001400:	4581                	li	a1,0
    80001402:	9f1ff0ef          	jal	80000df2 <memset>
  return pagetable;
}
    80001406:	8526                	mv	a0,s1
    80001408:	60e2                	ld	ra,24(sp)
    8000140a:	6442                	ld	s0,16(sp)
    8000140c:	64a2                	ld	s1,8(sp)
    8000140e:	6105                	addi	sp,sp,32
    80001410:	8082                	ret

0000000080001412 <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. It's OK if the mappings don't exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    80001412:	7115                	addi	sp,sp,-224
    80001414:	ed86                	sd	ra,216(sp)
    80001416:	e9a2                	sd	s0,208(sp)
    80001418:	1180                	addi	s0,sp,224
  uint64 a;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    8000141a:	03459793          	slli	a5,a1,0x34
    8000141e:	ef8d                	bnez	a5,80001458 <uvmunmap+0x46>
    80001420:	e1ca                	sd	s2,192(sp)
    80001422:	f556                	sd	s5,168(sp)
    80001424:	f15a                	sd	s6,160(sp)
    80001426:	e962                	sd	s8,144(sp)
    80001428:	8b2a                	mv	s6,a0
    8000142a:	892e                	mv	s2,a1
    8000142c:	8c36                	mv	s8,a3
    panic("uvmunmap: not aligned");

  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    8000142e:	0632                	slli	a2,a2,0xc
    80001430:	00b60ab3          	add	s5,a2,a1
    80001434:	0f55f763          	bgeu	a1,s5,80001522 <uvmunmap+0x110>
    80001438:	e5a6                	sd	s1,200(sp)
    8000143a:	fd4e                	sd	s3,184(sp)
    8000143c:	f952                	sd	s4,176(sp)
    8000143e:	ed5e                	sd	s7,152(sp)
    80001440:	e566                	sd	s9,136(sp)
    80001442:	e16a                	sd	s10,128(sp)
    80001444:	fcee                	sd	s11,120(sp)
    uint64 pa = PTE2PA(*pte);

    struct proc *p = myproc();
    if(p){
      struct mem_event e;
      memset(&e, 0, sizeof(e));
    80001446:	f2840c93          	addi	s9,s0,-216
      e.ticks  = ticks;
    8000144a:	00008d97          	auipc	s11,0x8
    8000144e:	be6d8d93          	addi	s11,s11,-1050 # 80009030 <ticks>
      e.cpu    = cpuid();
      e.type   = MEM_UNMAP;
    80001452:	4d15                	li	s10,5
      e.pid    = p->pid;
      e.state  = p->state;
      e.va     = a;
      e.pa     = pa;
      e.len    = PGSIZE;
    80001454:	6b85                	lui	s7,0x1
    80001456:	a80d                	j	80001488 <uvmunmap+0x76>
    80001458:	e5a6                	sd	s1,200(sp)
    8000145a:	e1ca                	sd	s2,192(sp)
    8000145c:	fd4e                	sd	s3,184(sp)
    8000145e:	f952                	sd	s4,176(sp)
    80001460:	f556                	sd	s5,168(sp)
    80001462:	f15a                	sd	s6,160(sp)
    80001464:	ed5e                	sd	s7,152(sp)
    80001466:	e962                	sd	s8,144(sp)
    80001468:	e566                	sd	s9,136(sp)
    8000146a:	e16a                	sd	s10,128(sp)
    8000146c:	fcee                	sd	s11,120(sp)
    panic("uvmunmap: not aligned");
    8000146e:	00007517          	auipc	a0,0x7
    80001472:	d9250513          	addi	a0,a0,-622 # 80008200 <userret+0x1164>
    80001476:	be0ff0ef          	jal	80000856 <panic>
      e.kind   = PAGE_USER;
      safestrcpy(e.name, p->name, MEM_NM);
      memlog_push(&e);
    }

    if(do_free){
    8000147a:	080c1963          	bnez	s8,8000150c <uvmunmap+0xfa>
      kfree((void*)pa);
    }
    *pte = 0;
    8000147e:	0004b023          	sd	zero,0(s1)
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80001482:	995e                	add	s2,s2,s7
    80001484:	09597863          	bgeu	s2,s5,80001514 <uvmunmap+0x102>
    if((pte = walk(pagetable, a, 0)) == 0)
    80001488:	4601                	li	a2,0
    8000148a:	85ca                	mv	a1,s2
    8000148c:	855a                	mv	a0,s6
    8000148e:	c4dff0ef          	jal	800010da <walk>
    80001492:	84aa                	mv	s1,a0
    80001494:	d57d                	beqz	a0,80001482 <uvmunmap+0x70>
    if((*pte & PTE_V) == 0)
    80001496:	00053983          	ld	s3,0(a0)
    8000149a:	0019f793          	andi	a5,s3,1
    8000149e:	d3f5                	beqz	a5,80001482 <uvmunmap+0x70>
    uint64 pa = PTE2PA(*pte);
    800014a0:	00a9d993          	srli	s3,s3,0xa
    800014a4:	09b2                	slli	s3,s3,0xc
    struct proc *p = myproc();
    800014a6:	7ec000ef          	jal	80001c92 <myproc>
    800014aa:	8a2a                	mv	s4,a0
    if(p){
    800014ac:	d579                	beqz	a0,8000147a <uvmunmap+0x68>
      memset(&e, 0, sizeof(e));
    800014ae:	06800613          	li	a2,104
    800014b2:	4581                	li	a1,0
    800014b4:	8566                	mv	a0,s9
    800014b6:	93dff0ef          	jal	80000df2 <memset>
      e.ticks  = ticks;
    800014ba:	000da783          	lw	a5,0(s11)
    800014be:	f2f42823          	sw	a5,-208(s0)
      e.cpu    = cpuid();
    800014c2:	79c000ef          	jal	80001c5e <cpuid>
    800014c6:	f2a42a23          	sw	a0,-204(s0)
      e.type   = MEM_UNMAP;
    800014ca:	f3a42c23          	sw	s10,-200(s0)
      e.pid    = p->pid;
    800014ce:	030a2783          	lw	a5,48(s4)
    800014d2:	f2f42e23          	sw	a5,-196(s0)
      e.state  = p->state;
    800014d6:	018a2783          	lw	a5,24(s4)
    800014da:	f4f42023          	sw	a5,-192(s0)
      e.va     = a;
    800014de:	f5243c23          	sd	s2,-168(s0)
      e.pa     = pa;
    800014e2:	f7343023          	sd	s3,-160(s0)
      e.len    = PGSIZE;
    800014e6:	f7743c23          	sd	s7,-136(s0)
      e.source = SRC_UVMUNMAP;
    800014ea:	4791                	li	a5,4
    800014ec:	f8f42223          	sw	a5,-124(s0)
      e.kind   = PAGE_USER;
    800014f0:	4785                	li	a5,1
    800014f2:	f8f42423          	sw	a5,-120(s0)
      safestrcpy(e.name, p->name, MEM_NM);
    800014f6:	4641                	li	a2,16
    800014f8:	158a0593          	addi	a1,s4,344
    800014fc:	f4440513          	addi	a0,s0,-188
    80001500:	a47ff0ef          	jal	80000f46 <safestrcpy>
      memlog_push(&e);
    80001504:	8566                	mv	a0,s9
    80001506:	046050ef          	jal	8000654c <memlog_push>
    8000150a:	bf85                	j	8000147a <uvmunmap+0x68>
      kfree((void*)pa);
    8000150c:	854e                	mv	a0,s3
    8000150e:	d80ff0ef          	jal	80000a8e <kfree>
    80001512:	b7b5                	j	8000147e <uvmunmap+0x6c>
    80001514:	64ae                	ld	s1,200(sp)
    80001516:	79ea                	ld	s3,184(sp)
    80001518:	7a4a                	ld	s4,176(sp)
    8000151a:	6bea                	ld	s7,152(sp)
    8000151c:	6caa                	ld	s9,136(sp)
    8000151e:	6d0a                	ld	s10,128(sp)
    80001520:	7de6                	ld	s11,120(sp)
    80001522:	690e                	ld	s2,192(sp)
    80001524:	7aaa                	ld	s5,168(sp)
    80001526:	7b0a                	ld	s6,160(sp)
    80001528:	6c4a                	ld	s8,144(sp)
  }
}
    8000152a:	60ee                	ld	ra,216(sp)
    8000152c:	644e                	ld	s0,208(sp)
    8000152e:	612d                	addi	sp,sp,224
    80001530:	8082                	ret

0000000080001532 <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    80001532:	1101                	addi	sp,sp,-32
    80001534:	ec06                	sd	ra,24(sp)
    80001536:	e822                	sd	s0,16(sp)
    80001538:	e426                	sd	s1,8(sp)
    8000153a:	1000                	addi	s0,sp,32
  if(newsz >= oldsz)
    return oldsz;
    8000153c:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    8000153e:	00b67d63          	bgeu	a2,a1,80001558 <uvmdealloc+0x26>
    80001542:	84b2                	mv	s1,a2

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    80001544:	6785                	lui	a5,0x1
    80001546:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80001548:	00f60733          	add	a4,a2,a5
    8000154c:	76fd                	lui	a3,0xfffff
    8000154e:	8f75                	and	a4,a4,a3
    80001550:	97ae                	add	a5,a5,a1
    80001552:	8ff5                	and	a5,a5,a3
    80001554:	00f76863          	bltu	a4,a5,80001564 <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    80001558:	8526                	mv	a0,s1
    8000155a:	60e2                	ld	ra,24(sp)
    8000155c:	6442                	ld	s0,16(sp)
    8000155e:	64a2                	ld	s1,8(sp)
    80001560:	6105                	addi	sp,sp,32
    80001562:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    80001564:	8f99                	sub	a5,a5,a4
    80001566:	83b1                	srli	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    80001568:	4685                	li	a3,1
    8000156a:	0007861b          	sext.w	a2,a5
    8000156e:	85ba                	mv	a1,a4
    80001570:	ea3ff0ef          	jal	80001412 <uvmunmap>
    80001574:	b7d5                	j	80001558 <uvmdealloc+0x26>

0000000080001576 <uvmalloc>:
{
    80001576:	7131                	addi	sp,sp,-192
    80001578:	fd06                	sd	ra,184(sp)
    8000157a:	f922                	sd	s0,176(sp)
    8000157c:	f526                	sd	s1,168(sp)
    8000157e:	0180                	addi	s0,sp,192
    80001580:	84ae                	mv	s1,a1
  if(newsz < oldsz)
    80001582:	00b67863          	bgeu	a2,a1,80001592 <uvmalloc+0x1c>
}
    80001586:	8526                	mv	a0,s1
    80001588:	70ea                	ld	ra,184(sp)
    8000158a:	744a                	ld	s0,176(sp)
    8000158c:	74aa                	ld	s1,168(sp)
    8000158e:	6129                	addi	sp,sp,192
    80001590:	8082                	ret
    80001592:	f14a                	sd	s2,160(sp)
    80001594:	ed4e                	sd	s3,152(sp)
    80001596:	e952                	sd	s4,144(sp)
    80001598:	e556                	sd	s5,136(sp)
    8000159a:	e15a                	sd	s6,128(sp)
    8000159c:	fcde                	sd	s7,120(sp)
    8000159e:	8b2a                	mv	s6,a0
    800015a0:	8a32                	mv	s4,a2
    800015a2:	8ab6                	mv	s5,a3
      struct proc *p = myproc();
    800015a4:	6ee000ef          	jal	80001c92 <myproc>
    800015a8:	892a                	mv	s2,a0
  if(p){
    800015aa:	c12d                	beqz	a0,8000160c <uvmalloc+0x96>
    memset(&e, 0, sizeof(e));
    800015ac:	f4840993          	addi	s3,s0,-184
    800015b0:	06800613          	li	a2,104
    800015b4:	4581                	li	a1,0
    800015b6:	854e                	mv	a0,s3
    800015b8:	83bff0ef          	jal	80000df2 <memset>
    e.ticks  = ticks;
    800015bc:	00008797          	auipc	a5,0x8
    800015c0:	a747a783          	lw	a5,-1420(a5) # 80009030 <ticks>
    800015c4:	f4f42823          	sw	a5,-176(s0)
    e.cpu    = cpuid();
    800015c8:	696000ef          	jal	80001c5e <cpuid>
    800015cc:	f4a42a23          	sw	a0,-172(s0)
    e.type   = MEM_GROW;
    800015d0:	4785                	li	a5,1
    800015d2:	f4f42c23          	sw	a5,-168(s0)
    e.pid    = p->pid;
    800015d6:	03092703          	lw	a4,48(s2)
    800015da:	f4e42e23          	sw	a4,-164(s0)
    e.state  = p->state;
    800015de:	01892703          	lw	a4,24(s2)
    800015e2:	f6e42023          	sw	a4,-160(s0)
    e.oldsz  = oldsz;
    800015e6:	f8943423          	sd	s1,-120(s0)
    e.newsz  = newsz;
    800015ea:	f9443823          	sd	s4,-112(s0)
    e.source = SRC_UVMALLOC;
    800015ee:	4715                	li	a4,5
    800015f0:	fae42223          	sw	a4,-92(s0)
    e.kind   = PAGE_USER;
    800015f4:	faf42423          	sw	a5,-88(s0)
    safestrcpy(e.name, p->name, MEM_NM);
    800015f8:	4641                	li	a2,16
    800015fa:	15890593          	addi	a1,s2,344
    800015fe:	f6440513          	addi	a0,s0,-156
    80001602:	945ff0ef          	jal	80000f46 <safestrcpy>
    memlog_push(&e);
    80001606:	854e                	mv	a0,s3
    80001608:	745040ef          	jal	8000654c <memlog_push>
  oldsz = PGROUNDUP(oldsz);
    8000160c:	6785                	lui	a5,0x1
    8000160e:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80001610:	97a6                	add	a5,a5,s1
    80001612:	777d                	lui	a4,0xfffff
    80001614:	8ff9                	and	a5,a5,a4
    80001616:	8bbe                	mv	s7,a5
  for(a = oldsz; a < newsz; a += PGSIZE){
    80001618:	0747fd63          	bgeu	a5,s4,80001692 <uvmalloc+0x11c>
    8000161c:	893e                	mv	s2,a5
    memset(mem, 0, PGSIZE);
    8000161e:	6985                	lui	s3,0x1
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    80001620:	012aea93          	ori	s5,s5,18
    mem = kalloc();
    80001624:	db6ff0ef          	jal	80000bda <kalloc>
    80001628:	84aa                	mv	s1,a0
    if(mem == 0){
    8000162a:	c905                	beqz	a0,8000165a <uvmalloc+0xe4>
    memset(mem, 0, PGSIZE);
    8000162c:	864e                	mv	a2,s3
    8000162e:	4581                	li	a1,0
    80001630:	fc2ff0ef          	jal	80000df2 <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    80001634:	8756                	mv	a4,s5
    80001636:	86a6                	mv	a3,s1
    80001638:	864e                	mv	a2,s3
    8000163a:	85ca                	mv	a1,s2
    8000163c:	855a                	mv	a0,s6
    8000163e:	b71ff0ef          	jal	800011ae <mappages>
    80001642:	e905                	bnez	a0,80001672 <uvmalloc+0xfc>
  for(a = oldsz; a < newsz; a += PGSIZE){
    80001644:	994e                	add	s2,s2,s3
    80001646:	fd496fe3          	bltu	s2,s4,80001624 <uvmalloc+0xae>
  return newsz;
    8000164a:	84d2                	mv	s1,s4
    8000164c:	790a                	ld	s2,160(sp)
    8000164e:	69ea                	ld	s3,152(sp)
    80001650:	6a4a                	ld	s4,144(sp)
    80001652:	6aaa                	ld	s5,136(sp)
    80001654:	6b0a                	ld	s6,128(sp)
    80001656:	7be6                	ld	s7,120(sp)
    80001658:	b73d                	j	80001586 <uvmalloc+0x10>
      uvmdealloc(pagetable, a, oldsz);
    8000165a:	865e                	mv	a2,s7
    8000165c:	85ca                	mv	a1,s2
    8000165e:	855a                	mv	a0,s6
    80001660:	ed3ff0ef          	jal	80001532 <uvmdealloc>
      return 0;
    80001664:	790a                	ld	s2,160(sp)
    80001666:	69ea                	ld	s3,152(sp)
    80001668:	6a4a                	ld	s4,144(sp)
    8000166a:	6aaa                	ld	s5,136(sp)
    8000166c:	6b0a                	ld	s6,128(sp)
    8000166e:	7be6                	ld	s7,120(sp)
    80001670:	bf19                	j	80001586 <uvmalloc+0x10>
      kfree(mem);
    80001672:	8526                	mv	a0,s1
    80001674:	c1aff0ef          	jal	80000a8e <kfree>
      uvmdealloc(pagetable, a, oldsz);
    80001678:	865e                	mv	a2,s7
    8000167a:	85ca                	mv	a1,s2
    8000167c:	855a                	mv	a0,s6
    8000167e:	eb5ff0ef          	jal	80001532 <uvmdealloc>
      return 0;
    80001682:	4481                	li	s1,0
    80001684:	790a                	ld	s2,160(sp)
    80001686:	69ea                	ld	s3,152(sp)
    80001688:	6a4a                	ld	s4,144(sp)
    8000168a:	6aaa                	ld	s5,136(sp)
    8000168c:	6b0a                	ld	s6,128(sp)
    8000168e:	7be6                	ld	s7,120(sp)
    80001690:	bddd                	j	80001586 <uvmalloc+0x10>
  return newsz;
    80001692:	84d2                	mv	s1,s4
    80001694:	790a                	ld	s2,160(sp)
    80001696:	69ea                	ld	s3,152(sp)
    80001698:	6a4a                	ld	s4,144(sp)
    8000169a:	6aaa                	ld	s5,136(sp)
    8000169c:	6b0a                	ld	s6,128(sp)
    8000169e:	7be6                	ld	s7,120(sp)
    800016a0:	b5dd                	j	80001586 <uvmalloc+0x10>

00000000800016a2 <freewalk>:
// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    800016a2:	7179                	addi	sp,sp,-48
    800016a4:	f406                	sd	ra,40(sp)
    800016a6:	f022                	sd	s0,32(sp)
    800016a8:	ec26                	sd	s1,24(sp)
    800016aa:	e84a                	sd	s2,16(sp)
    800016ac:	e44e                	sd	s3,8(sp)
    800016ae:	1800                	addi	s0,sp,48
    800016b0:	89aa                	mv	s3,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    800016b2:	84aa                	mv	s1,a0
    800016b4:	6905                	lui	s2,0x1
    800016b6:	992a                	add	s2,s2,a0
    800016b8:	a811                	j	800016cc <freewalk+0x2a>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
      freewalk((pagetable_t)child);
      pagetable[i] = 0;
    } else if(pte & PTE_V){
      panic("freewalk: leaf");
    800016ba:	00007517          	auipc	a0,0x7
    800016be:	b5e50513          	addi	a0,a0,-1186 # 80008218 <userret+0x117c>
    800016c2:	994ff0ef          	jal	80000856 <panic>
  for(int i = 0; i < 512; i++){
    800016c6:	04a1                	addi	s1,s1,8
    800016c8:	03248163          	beq	s1,s2,800016ea <freewalk+0x48>
    pte_t pte = pagetable[i];
    800016cc:	609c                	ld	a5,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800016ce:	0017f713          	andi	a4,a5,1
    800016d2:	db75                	beqz	a4,800016c6 <freewalk+0x24>
    800016d4:	00e7f713          	andi	a4,a5,14
    800016d8:	f36d                	bnez	a4,800016ba <freewalk+0x18>
      uint64 child = PTE2PA(pte);
    800016da:	83a9                	srli	a5,a5,0xa
      freewalk((pagetable_t)child);
    800016dc:	00c79513          	slli	a0,a5,0xc
    800016e0:	fc3ff0ef          	jal	800016a2 <freewalk>
      pagetable[i] = 0;
    800016e4:	0004b023          	sd	zero,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800016e8:	bff9                	j	800016c6 <freewalk+0x24>
    }
  }
  kfree((void*)pagetable);
    800016ea:	854e                	mv	a0,s3
    800016ec:	ba2ff0ef          	jal	80000a8e <kfree>
}
    800016f0:	70a2                	ld	ra,40(sp)
    800016f2:	7402                	ld	s0,32(sp)
    800016f4:	64e2                	ld	s1,24(sp)
    800016f6:	6942                	ld	s2,16(sp)
    800016f8:	69a2                	ld	s3,8(sp)
    800016fa:	6145                	addi	sp,sp,48
    800016fc:	8082                	ret

00000000800016fe <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    800016fe:	1101                	addi	sp,sp,-32
    80001700:	ec06                	sd	ra,24(sp)
    80001702:	e822                	sd	s0,16(sp)
    80001704:	e426                	sd	s1,8(sp)
    80001706:	1000                	addi	s0,sp,32
    80001708:	84aa                	mv	s1,a0
  if(sz > 0)
    8000170a:	e989                	bnez	a1,8000171c <uvmfree+0x1e>
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
  freewalk(pagetable);
    8000170c:	8526                	mv	a0,s1
    8000170e:	f95ff0ef          	jal	800016a2 <freewalk>
}
    80001712:	60e2                	ld	ra,24(sp)
    80001714:	6442                	ld	s0,16(sp)
    80001716:	64a2                	ld	s1,8(sp)
    80001718:	6105                	addi	sp,sp,32
    8000171a:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
    8000171c:	6785                	lui	a5,0x1
    8000171e:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80001720:	95be                	add	a1,a1,a5
    80001722:	4685                	li	a3,1
    80001724:	00c5d613          	srli	a2,a1,0xc
    80001728:	4581                	li	a1,0
    8000172a:	ce9ff0ef          	jal	80001412 <uvmunmap>
    8000172e:	bff9                	j	8000170c <uvmfree+0xe>

0000000080001730 <uvmcopy>:
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for(i = 0; i < sz; i += PGSIZE){
    80001730:	ca59                	beqz	a2,800017c6 <uvmcopy+0x96>
{
    80001732:	715d                	addi	sp,sp,-80
    80001734:	e486                	sd	ra,72(sp)
    80001736:	e0a2                	sd	s0,64(sp)
    80001738:	fc26                	sd	s1,56(sp)
    8000173a:	f84a                	sd	s2,48(sp)
    8000173c:	f44e                	sd	s3,40(sp)
    8000173e:	f052                	sd	s4,32(sp)
    80001740:	ec56                	sd	s5,24(sp)
    80001742:	e85a                	sd	s6,16(sp)
    80001744:	e45e                	sd	s7,8(sp)
    80001746:	0880                	addi	s0,sp,80
    80001748:	8b2a                	mv	s6,a0
    8000174a:	8bae                	mv	s7,a1
    8000174c:	8ab2                	mv	s5,a2
  for(i = 0; i < sz; i += PGSIZE){
    8000174e:	4481                	li	s1,0
      continue;   // physical page hasn't been allocated
    pa = PTE2PA(*pte);
    flags = PTE_FLAGS(*pte);
    if((mem = kalloc()) == 0)
      goto err;
    memmove(mem, (char*)pa, PGSIZE);
    80001750:	6a05                	lui	s4,0x1
    80001752:	a021                	j	8000175a <uvmcopy+0x2a>
  for(i = 0; i < sz; i += PGSIZE){
    80001754:	94d2                	add	s1,s1,s4
    80001756:	0554fc63          	bgeu	s1,s5,800017ae <uvmcopy+0x7e>
    if((pte = walk(old, i, 0)) == 0)
    8000175a:	4601                	li	a2,0
    8000175c:	85a6                	mv	a1,s1
    8000175e:	855a                	mv	a0,s6
    80001760:	97bff0ef          	jal	800010da <walk>
    80001764:	d965                	beqz	a0,80001754 <uvmcopy+0x24>
    if((*pte & PTE_V) == 0)
    80001766:	00053983          	ld	s3,0(a0)
    8000176a:	0019f793          	andi	a5,s3,1
    8000176e:	d3fd                	beqz	a5,80001754 <uvmcopy+0x24>
    if((mem = kalloc()) == 0)
    80001770:	c6aff0ef          	jal	80000bda <kalloc>
    80001774:	892a                	mv	s2,a0
    80001776:	c11d                	beqz	a0,8000179c <uvmcopy+0x6c>
    pa = PTE2PA(*pte);
    80001778:	00a9d593          	srli	a1,s3,0xa
    memmove(mem, (char*)pa, PGSIZE);
    8000177c:	8652                	mv	a2,s4
    8000177e:	05b2                	slli	a1,a1,0xc
    80001780:	ed2ff0ef          	jal	80000e52 <memmove>
    if(mappages(new, i, PGSIZE, (uint64)mem, flags) != 0){
    80001784:	3ff9f713          	andi	a4,s3,1023
    80001788:	86ca                	mv	a3,s2
    8000178a:	8652                	mv	a2,s4
    8000178c:	85a6                	mv	a1,s1
    8000178e:	855e                	mv	a0,s7
    80001790:	a1fff0ef          	jal	800011ae <mappages>
    80001794:	d161                	beqz	a0,80001754 <uvmcopy+0x24>
      kfree(mem);
    80001796:	854a                	mv	a0,s2
    80001798:	af6ff0ef          	jal	80000a8e <kfree>
    }
  }
  return 0;

 err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    8000179c:	4685                	li	a3,1
    8000179e:	00c4d613          	srli	a2,s1,0xc
    800017a2:	4581                	li	a1,0
    800017a4:	855e                	mv	a0,s7
    800017a6:	c6dff0ef          	jal	80001412 <uvmunmap>
  return -1;
    800017aa:	557d                	li	a0,-1
    800017ac:	a011                	j	800017b0 <uvmcopy+0x80>
  return 0;
    800017ae:	4501                	li	a0,0
}
    800017b0:	60a6                	ld	ra,72(sp)
    800017b2:	6406                	ld	s0,64(sp)
    800017b4:	74e2                	ld	s1,56(sp)
    800017b6:	7942                	ld	s2,48(sp)
    800017b8:	79a2                	ld	s3,40(sp)
    800017ba:	7a02                	ld	s4,32(sp)
    800017bc:	6ae2                	ld	s5,24(sp)
    800017be:	6b42                	ld	s6,16(sp)
    800017c0:	6ba2                	ld	s7,8(sp)
    800017c2:	6161                	addi	sp,sp,80
    800017c4:	8082                	ret
  return 0;
    800017c6:	4501                	li	a0,0
}
    800017c8:	8082                	ret

00000000800017ca <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    800017ca:	1141                	addi	sp,sp,-16
    800017cc:	e406                	sd	ra,8(sp)
    800017ce:	e022                	sd	s0,0(sp)
    800017d0:	0800                	addi	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    800017d2:	4601                	li	a2,0
    800017d4:	907ff0ef          	jal	800010da <walk>
  if(pte == 0)
    800017d8:	c901                	beqz	a0,800017e8 <uvmclear+0x1e>
    panic("uvmclear");
  *pte &= ~PTE_U;
    800017da:	611c                	ld	a5,0(a0)
    800017dc:	9bbd                	andi	a5,a5,-17
    800017de:	e11c                	sd	a5,0(a0)
}
    800017e0:	60a2                	ld	ra,8(sp)
    800017e2:	6402                	ld	s0,0(sp)
    800017e4:	0141                	addi	sp,sp,16
    800017e6:	8082                	ret
    panic("uvmclear");
    800017e8:	00007517          	auipc	a0,0x7
    800017ec:	a4050513          	addi	a0,a0,-1472 # 80008228 <userret+0x118c>
    800017f0:	866ff0ef          	jal	80000856 <panic>

00000000800017f4 <copyinstr>:
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    800017f4:	cac5                	beqz	a3,800018a4 <copyinstr+0xb0>
{
    800017f6:	715d                	addi	sp,sp,-80
    800017f8:	e486                	sd	ra,72(sp)
    800017fa:	e0a2                	sd	s0,64(sp)
    800017fc:	fc26                	sd	s1,56(sp)
    800017fe:	f84a                	sd	s2,48(sp)
    80001800:	f44e                	sd	s3,40(sp)
    80001802:	f052                	sd	s4,32(sp)
    80001804:	ec56                	sd	s5,24(sp)
    80001806:	e85a                	sd	s6,16(sp)
    80001808:	e45e                	sd	s7,8(sp)
    8000180a:	0880                	addi	s0,sp,80
    8000180c:	8aaa                	mv	s5,a0
    8000180e:	84ae                	mv	s1,a1
    80001810:	8bb2                	mv	s7,a2
    80001812:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(srcva);
    80001814:	7b7d                	lui	s6,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    80001816:	6a05                	lui	s4,0x1
    80001818:	a82d                	j	80001852 <copyinstr+0x5e>
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
    8000181a:	00078023          	sb	zero,0(a5)
        got_null = 1;
    8000181e:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    80001820:	0017c793          	xori	a5,a5,1
    80001824:	40f0053b          	negw	a0,a5
    return 0;
  } else {
    return -1;
  }
}
    80001828:	60a6                	ld	ra,72(sp)
    8000182a:	6406                	ld	s0,64(sp)
    8000182c:	74e2                	ld	s1,56(sp)
    8000182e:	7942                	ld	s2,48(sp)
    80001830:	79a2                	ld	s3,40(sp)
    80001832:	7a02                	ld	s4,32(sp)
    80001834:	6ae2                	ld	s5,24(sp)
    80001836:	6b42                	ld	s6,16(sp)
    80001838:	6ba2                	ld	s7,8(sp)
    8000183a:	6161                	addi	sp,sp,80
    8000183c:	8082                	ret
    8000183e:	fff98713          	addi	a4,s3,-1 # fff <_entry-0x7ffff001>
    80001842:	9726                	add	a4,a4,s1
      --max;
    80001844:	40b709b3          	sub	s3,a4,a1
    srcva = va0 + PGSIZE;
    80001848:	01490bb3          	add	s7,s2,s4
  while(got_null == 0 && max > 0){
    8000184c:	04e58463          	beq	a1,a4,80001894 <copyinstr+0xa0>
{
    80001850:	84be                	mv	s1,a5
    va0 = PGROUNDDOWN(srcva);
    80001852:	016bf933          	and	s2,s7,s6
    pa0 = walkaddr(pagetable, va0);
    80001856:	85ca                	mv	a1,s2
    80001858:	8556                	mv	a0,s5
    8000185a:	91bff0ef          	jal	80001174 <walkaddr>
    if(pa0 == 0)
    8000185e:	cd0d                	beqz	a0,80001898 <copyinstr+0xa4>
    n = PGSIZE - (srcva - va0);
    80001860:	417906b3          	sub	a3,s2,s7
    80001864:	96d2                	add	a3,a3,s4
    if(n > max)
    80001866:	00d9f363          	bgeu	s3,a3,8000186c <copyinstr+0x78>
    8000186a:	86ce                	mv	a3,s3
    while(n > 0){
    8000186c:	ca85                	beqz	a3,8000189c <copyinstr+0xa8>
    char *p = (char *) (pa0 + (srcva - va0));
    8000186e:	01750633          	add	a2,a0,s7
    80001872:	41260633          	sub	a2,a2,s2
    80001876:	87a6                	mv	a5,s1
      if(*p == '\0'){
    80001878:	8e05                	sub	a2,a2,s1
    while(n > 0){
    8000187a:	96a6                	add	a3,a3,s1
    8000187c:	85be                	mv	a1,a5
      if(*p == '\0'){
    8000187e:	00f60733          	add	a4,a2,a5
    80001882:	00074703          	lbu	a4,0(a4) # fffffffffffff000 <end+0xffffffff7ffb6c08>
    80001886:	db51                	beqz	a4,8000181a <copyinstr+0x26>
        *dst = *p;
    80001888:	00e78023          	sb	a4,0(a5)
      dst++;
    8000188c:	0785                	addi	a5,a5,1
    while(n > 0){
    8000188e:	fed797e3          	bne	a5,a3,8000187c <copyinstr+0x88>
    80001892:	b775                	j	8000183e <copyinstr+0x4a>
    80001894:	4781                	li	a5,0
    80001896:	b769                	j	80001820 <copyinstr+0x2c>
      return -1;
    80001898:	557d                	li	a0,-1
    8000189a:	b779                	j	80001828 <copyinstr+0x34>
    srcva = va0 + PGSIZE;
    8000189c:	6b85                	lui	s7,0x1
    8000189e:	9bca                	add	s7,s7,s2
    800018a0:	87a6                	mv	a5,s1
    800018a2:	b77d                	j	80001850 <copyinstr+0x5c>
  int got_null = 0;
    800018a4:	4781                	li	a5,0
  if(got_null){
    800018a6:	0017c793          	xori	a5,a5,1
    800018aa:	40f0053b          	negw	a0,a5
}
    800018ae:	8082                	ret

00000000800018b0 <ismapped>:
  }
  return mem;
}
int
ismapped(pagetable_t pagetable, uint64 va)
{
    800018b0:	1141                	addi	sp,sp,-16
    800018b2:	e406                	sd	ra,8(sp)
    800018b4:	e022                	sd	s0,0(sp)
    800018b6:	0800                	addi	s0,sp,16
  pte_t *pte = walk(pagetable, va, 0);
    800018b8:	4601                	li	a2,0
    800018ba:	821ff0ef          	jal	800010da <walk>
  if (pte == 0) {
    800018be:	c119                	beqz	a0,800018c4 <ismapped+0x14>
    return 0;
  }
  if (*pte & PTE_V){
    800018c0:	6108                	ld	a0,0(a0)
    800018c2:	8905                	andi	a0,a0,1
    return 1;
  }
  return 0;
}
    800018c4:	60a2                	ld	ra,8(sp)
    800018c6:	6402                	ld	s0,0(sp)
    800018c8:	0141                	addi	sp,sp,16
    800018ca:	8082                	ret

00000000800018cc <vmfault>:
{
    800018cc:	7135                	addi	sp,sp,-160
    800018ce:	ed06                	sd	ra,152(sp)
    800018d0:	e922                	sd	s0,144(sp)
    800018d2:	e14a                	sd	s2,128(sp)
    800018d4:	fcce                	sd	s3,120(sp)
    800018d6:	f8d2                	sd	s4,112(sp)
    800018d8:	1100                	addi	s0,sp,160
    800018da:	89aa                	mv	s3,a0
    800018dc:	892e                	mv	s2,a1
  struct proc *p = myproc();
    800018de:	3b4000ef          	jal	80001c92 <myproc>
  if (va >= p->sz)
    800018e2:	653c                	ld	a5,72(a0)
    return 0;
    800018e4:	4a01                	li	s4,0
  if (va >= p->sz)
    800018e6:	00f96a63          	bltu	s2,a5,800018fa <vmfault+0x2e>
}
    800018ea:	8552                	mv	a0,s4
    800018ec:	60ea                	ld	ra,152(sp)
    800018ee:	644a                	ld	s0,144(sp)
    800018f0:	690a                	ld	s2,128(sp)
    800018f2:	79e6                	ld	s3,120(sp)
    800018f4:	7a46                	ld	s4,112(sp)
    800018f6:	610d                	addi	sp,sp,160
    800018f8:	8082                	ret
    800018fa:	e526                	sd	s1,136(sp)
    800018fc:	84aa                	mv	s1,a0
  va = PGROUNDDOWN(va);
    800018fe:	77fd                	lui	a5,0xfffff
    80001900:	00f97933          	and	s2,s2,a5
  if(ismapped(pagetable, va)) {
    80001904:	85ca                	mv	a1,s2
    80001906:	854e                	mv	a0,s3
    80001908:	fa9ff0ef          	jal	800018b0 <ismapped>
    return 0;
    8000190c:	4a01                	li	s4,0
  if(ismapped(pagetable, va)) {
    8000190e:	c119                	beqz	a0,80001914 <vmfault+0x48>
    80001910:	64aa                	ld	s1,136(sp)
    80001912:	bfe1                	j	800018ea <vmfault+0x1e>
  memset(&e, 0, sizeof(e));
    80001914:	06800613          	li	a2,104
    80001918:	4581                	li	a1,0
    8000191a:	f6840513          	addi	a0,s0,-152
    8000191e:	cd4ff0ef          	jal	80000df2 <memset>
  e.ticks  = ticks;
    80001922:	00007797          	auipc	a5,0x7
    80001926:	70e7a783          	lw	a5,1806(a5) # 80009030 <ticks>
    8000192a:	f6f42823          	sw	a5,-144(s0)
  e.cpu    = cpuid();
    8000192e:	330000ef          	jal	80001c5e <cpuid>
    80001932:	f6a42a23          	sw	a0,-140(s0)
  e.type   = MEM_FAULT;
    80001936:	478d                	li	a5,3
    80001938:	f6f42c23          	sw	a5,-136(s0)
  e.pid    = p->pid;
    8000193c:	589c                	lw	a5,48(s1)
    8000193e:	f6f42e23          	sw	a5,-132(s0)
  e.state  = p->state;
    80001942:	4c9c                	lw	a5,24(s1)
    80001944:	f8f42023          	sw	a5,-128(s0)
  e.va     = va;
    80001948:	f9243c23          	sd	s2,-104(s0)
  e.source = SRC_VMFAULT;
    8000194c:	479d                	li	a5,7
    8000194e:	fcf42223          	sw	a5,-60(s0)
  e.kind   = PAGE_USER;
    80001952:	4785                	li	a5,1
    80001954:	fcf42423          	sw	a5,-56(s0)
  safestrcpy(e.name, p->name, MEM_NM);
    80001958:	4641                	li	a2,16
    8000195a:	15848593          	addi	a1,s1,344
    8000195e:	f8440513          	addi	a0,s0,-124
    80001962:	de4ff0ef          	jal	80000f46 <safestrcpy>
  memlog_push(&e);
    80001966:	f6840513          	addi	a0,s0,-152
    8000196a:	3e3040ef          	jal	8000654c <memlog_push>
  mem = (uint64) kalloc();
    8000196e:	a6cff0ef          	jal	80000bda <kalloc>
    80001972:	89aa                	mv	s3,a0
  if(mem == 0)
    80001974:	c515                	beqz	a0,800019a0 <vmfault+0xd4>
  mem = (uint64) kalloc();
    80001976:	8a2a                	mv	s4,a0
  memset((void *) mem, 0, PGSIZE);
    80001978:	6605                	lui	a2,0x1
    8000197a:	4581                	li	a1,0
    8000197c:	c76ff0ef          	jal	80000df2 <memset>
  if (mappages(p->pagetable, va, PGSIZE, mem, PTE_W|PTE_U|PTE_R) != 0) {
    80001980:	4759                	li	a4,22
    80001982:	86ce                	mv	a3,s3
    80001984:	6605                	lui	a2,0x1
    80001986:	85ca                	mv	a1,s2
    80001988:	68a8                	ld	a0,80(s1)
    8000198a:	825ff0ef          	jal	800011ae <mappages>
    8000198e:	e119                	bnez	a0,80001994 <vmfault+0xc8>
    80001990:	64aa                	ld	s1,136(sp)
    80001992:	bfa1                	j	800018ea <vmfault+0x1e>
    kfree((void *)mem);
    80001994:	854e                	mv	a0,s3
    80001996:	8f8ff0ef          	jal	80000a8e <kfree>
    return 0;
    8000199a:	4a01                	li	s4,0
    8000199c:	64aa                	ld	s1,136(sp)
    8000199e:	b7b1                	j	800018ea <vmfault+0x1e>
    800019a0:	64aa                	ld	s1,136(sp)
    800019a2:	b7a1                	j	800018ea <vmfault+0x1e>

00000000800019a4 <copyout>:
  while(len > 0){
    800019a4:	cad1                	beqz	a3,80001a38 <copyout+0x94>
{
    800019a6:	711d                	addi	sp,sp,-96
    800019a8:	ec86                	sd	ra,88(sp)
    800019aa:	e8a2                	sd	s0,80(sp)
    800019ac:	e4a6                	sd	s1,72(sp)
    800019ae:	e0ca                	sd	s2,64(sp)
    800019b0:	fc4e                	sd	s3,56(sp)
    800019b2:	f852                	sd	s4,48(sp)
    800019b4:	f456                	sd	s5,40(sp)
    800019b6:	f05a                	sd	s6,32(sp)
    800019b8:	ec5e                	sd	s7,24(sp)
    800019ba:	e862                	sd	s8,16(sp)
    800019bc:	e466                	sd	s9,8(sp)
    800019be:	e06a                	sd	s10,0(sp)
    800019c0:	1080                	addi	s0,sp,96
    800019c2:	8baa                	mv	s7,a0
    800019c4:	8a2e                	mv	s4,a1
    800019c6:	8b32                	mv	s6,a2
    800019c8:	8ab6                	mv	s5,a3
    va0 = PGROUNDDOWN(dstva);
    800019ca:	7d7d                	lui	s10,0xfffff
    if(va0 >= MAXVA)
    800019cc:	5cfd                	li	s9,-1
    800019ce:	01acdc93          	srli	s9,s9,0x1a
    n = PGSIZE - (dstva - va0);
    800019d2:	6c05                	lui	s8,0x1
    800019d4:	a005                	j	800019f4 <copyout+0x50>
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    800019d6:	409a0533          	sub	a0,s4,s1
    800019da:	0009061b          	sext.w	a2,s2
    800019de:	85da                	mv	a1,s6
    800019e0:	954e                	add	a0,a0,s3
    800019e2:	c70ff0ef          	jal	80000e52 <memmove>
    len -= n;
    800019e6:	412a8ab3          	sub	s5,s5,s2
    src += n;
    800019ea:	9b4a                	add	s6,s6,s2
    dstva = va0 + PGSIZE;
    800019ec:	01848a33          	add	s4,s1,s8
  while(len > 0){
    800019f0:	040a8263          	beqz	s5,80001a34 <copyout+0x90>
    va0 = PGROUNDDOWN(dstva);
    800019f4:	01aa74b3          	and	s1,s4,s10
    if(va0 >= MAXVA)
    800019f8:	049ce263          	bltu	s9,s1,80001a3c <copyout+0x98>
    pa0 = walkaddr(pagetable, va0);
    800019fc:	85a6                	mv	a1,s1
    800019fe:	855e                	mv	a0,s7
    80001a00:	f74ff0ef          	jal	80001174 <walkaddr>
    80001a04:	89aa                	mv	s3,a0
    if(pa0 == 0) {
    80001a06:	e901                	bnez	a0,80001a16 <copyout+0x72>
      if((pa0 = vmfault(pagetable, va0, 0)) == 0) {
    80001a08:	4601                	li	a2,0
    80001a0a:	85a6                	mv	a1,s1
    80001a0c:	855e                	mv	a0,s7
    80001a0e:	ebfff0ef          	jal	800018cc <vmfault>
    80001a12:	89aa                	mv	s3,a0
    80001a14:	c139                	beqz	a0,80001a5a <copyout+0xb6>
    pte = walk(pagetable, va0, 0);
    80001a16:	4601                	li	a2,0
    80001a18:	85a6                	mv	a1,s1
    80001a1a:	855e                	mv	a0,s7
    80001a1c:	ebeff0ef          	jal	800010da <walk>
    if((*pte & PTE_W) == 0)
    80001a20:	611c                	ld	a5,0(a0)
    80001a22:	8b91                	andi	a5,a5,4
    80001a24:	cf8d                	beqz	a5,80001a5e <copyout+0xba>
    n = PGSIZE - (dstva - va0);
    80001a26:	41448933          	sub	s2,s1,s4
    80001a2a:	9962                	add	s2,s2,s8
    if(n > len)
    80001a2c:	fb2af5e3          	bgeu	s5,s2,800019d6 <copyout+0x32>
    80001a30:	8956                	mv	s2,s5
    80001a32:	b755                	j	800019d6 <copyout+0x32>
  return 0;
    80001a34:	4501                	li	a0,0
    80001a36:	a021                	j	80001a3e <copyout+0x9a>
    80001a38:	4501                	li	a0,0
}
    80001a3a:	8082                	ret
      return -1;
    80001a3c:	557d                	li	a0,-1
}
    80001a3e:	60e6                	ld	ra,88(sp)
    80001a40:	6446                	ld	s0,80(sp)
    80001a42:	64a6                	ld	s1,72(sp)
    80001a44:	6906                	ld	s2,64(sp)
    80001a46:	79e2                	ld	s3,56(sp)
    80001a48:	7a42                	ld	s4,48(sp)
    80001a4a:	7aa2                	ld	s5,40(sp)
    80001a4c:	7b02                	ld	s6,32(sp)
    80001a4e:	6be2                	ld	s7,24(sp)
    80001a50:	6c42                	ld	s8,16(sp)
    80001a52:	6ca2                	ld	s9,8(sp)
    80001a54:	6d02                	ld	s10,0(sp)
    80001a56:	6125                	addi	sp,sp,96
    80001a58:	8082                	ret
        return -1;
    80001a5a:	557d                	li	a0,-1
    80001a5c:	b7cd                	j	80001a3e <copyout+0x9a>
      return -1;
    80001a5e:	557d                	li	a0,-1
    80001a60:	bff9                	j	80001a3e <copyout+0x9a>

0000000080001a62 <copyin>:
  while(len > 0){
    80001a62:	c6c9                	beqz	a3,80001aec <copyin+0x8a>
{
    80001a64:	715d                	addi	sp,sp,-80
    80001a66:	e486                	sd	ra,72(sp)
    80001a68:	e0a2                	sd	s0,64(sp)
    80001a6a:	fc26                	sd	s1,56(sp)
    80001a6c:	f84a                	sd	s2,48(sp)
    80001a6e:	f44e                	sd	s3,40(sp)
    80001a70:	f052                	sd	s4,32(sp)
    80001a72:	ec56                	sd	s5,24(sp)
    80001a74:	e85a                	sd	s6,16(sp)
    80001a76:	e45e                	sd	s7,8(sp)
    80001a78:	e062                	sd	s8,0(sp)
    80001a7a:	0880                	addi	s0,sp,80
    80001a7c:	8baa                	mv	s7,a0
    80001a7e:	8aae                	mv	s5,a1
    80001a80:	8932                	mv	s2,a2
    80001a82:	8a36                	mv	s4,a3
    va0 = PGROUNDDOWN(srcva);
    80001a84:	7c7d                	lui	s8,0xfffff
    n = PGSIZE - (srcva - va0);
    80001a86:	6b05                	lui	s6,0x1
    80001a88:	a035                	j	80001ab4 <copyin+0x52>
    80001a8a:	412984b3          	sub	s1,s3,s2
    80001a8e:	94da                	add	s1,s1,s6
    if(n > len)
    80001a90:	009a7363          	bgeu	s4,s1,80001a96 <copyin+0x34>
    80001a94:	84d2                	mv	s1,s4
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    80001a96:	413905b3          	sub	a1,s2,s3
    80001a9a:	0004861b          	sext.w	a2,s1
    80001a9e:	95aa                	add	a1,a1,a0
    80001aa0:	8556                	mv	a0,s5
    80001aa2:	bb0ff0ef          	jal	80000e52 <memmove>
    len -= n;
    80001aa6:	409a0a33          	sub	s4,s4,s1
    dst += n;
    80001aaa:	9aa6                	add	s5,s5,s1
    srcva = va0 + PGSIZE;
    80001aac:	01698933          	add	s2,s3,s6
  while(len > 0){
    80001ab0:	020a0163          	beqz	s4,80001ad2 <copyin+0x70>
    va0 = PGROUNDDOWN(srcva);
    80001ab4:	018979b3          	and	s3,s2,s8
    pa0 = walkaddr(pagetable, va0);
    80001ab8:	85ce                	mv	a1,s3
    80001aba:	855e                	mv	a0,s7
    80001abc:	eb8ff0ef          	jal	80001174 <walkaddr>
    if(pa0 == 0) {
    80001ac0:	f569                	bnez	a0,80001a8a <copyin+0x28>
      if((pa0 = vmfault(pagetable, va0, 0)) == 0) {
    80001ac2:	4601                	li	a2,0
    80001ac4:	85ce                	mv	a1,s3
    80001ac6:	855e                	mv	a0,s7
    80001ac8:	e05ff0ef          	jal	800018cc <vmfault>
    80001acc:	fd5d                	bnez	a0,80001a8a <copyin+0x28>
        return -1;
    80001ace:	557d                	li	a0,-1
    80001ad0:	a011                	j	80001ad4 <copyin+0x72>
  return 0;
    80001ad2:	4501                	li	a0,0
}
    80001ad4:	60a6                	ld	ra,72(sp)
    80001ad6:	6406                	ld	s0,64(sp)
    80001ad8:	74e2                	ld	s1,56(sp)
    80001ada:	7942                	ld	s2,48(sp)
    80001adc:	79a2                	ld	s3,40(sp)
    80001ade:	7a02                	ld	s4,32(sp)
    80001ae0:	6ae2                	ld	s5,24(sp)
    80001ae2:	6b42                	ld	s6,16(sp)
    80001ae4:	6ba2                	ld	s7,8(sp)
    80001ae6:	6c02                	ld	s8,0(sp)
    80001ae8:	6161                	addi	sp,sp,80
    80001aea:	8082                	ret
  return 0;
    80001aec:	4501                	li	a0,0
}
    80001aee:	8082                	ret

0000000080001af0 <proc_mapstacks>:
struct spinlock wait_lock;

// Allocate a page for each process's kernel stack.
// Map it high in memory, followed by an invalid
// guard page.
void proc_mapstacks(pagetable_t kpgtbl) {
    80001af0:	715d                	addi	sp,sp,-80
    80001af2:	e486                	sd	ra,72(sp)
    80001af4:	e0a2                	sd	s0,64(sp)
    80001af6:	fc26                	sd	s1,56(sp)
    80001af8:	f84a                	sd	s2,48(sp)
    80001afa:	f44e                	sd	s3,40(sp)
    80001afc:	f052                	sd	s4,32(sp)
    80001afe:	ec56                	sd	s5,24(sp)
    80001b00:	e85a                	sd	s6,16(sp)
    80001b02:	e45e                	sd	s7,8(sp)
    80001b04:	e062                	sd	s8,0(sp)
    80001b06:	0880                	addi	s0,sp,80
    80001b08:	8a2a                	mv	s4,a0
  struct proc *p;

  for (p = proc; p < &proc[NPROC]; p++) {
    80001b0a:	00011497          	auipc	s1,0x11
    80001b0e:	a6648493          	addi	s1,s1,-1434 # 80012570 <proc>
    char *pa = kalloc();
    if (pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int)(p - proc));
    80001b12:	8c26                	mv	s8,s1
    80001b14:	000a57b7          	lui	a5,0xa5
    80001b18:	fa578793          	addi	a5,a5,-91 # a4fa5 <_entry-0x7ff5b05b>
    80001b1c:	07b2                	slli	a5,a5,0xc
    80001b1e:	fa578793          	addi	a5,a5,-91
    80001b22:	4fa50937          	lui	s2,0x4fa50
    80001b26:	a4f90913          	addi	s2,s2,-1457 # 4fa4fa4f <_entry-0x305b05b1>
    80001b2a:	1902                	slli	s2,s2,0x20
    80001b2c:	993e                	add	s2,s2,a5
    80001b2e:	040009b7          	lui	s3,0x4000
    80001b32:	19fd                	addi	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    80001b34:	09b2                	slli	s3,s3,0xc
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    80001b36:	4b99                	li	s7,6
    80001b38:	6b05                	lui	s6,0x1
  for (p = proc; p < &proc[NPROC]; p++) {
    80001b3a:	00016a97          	auipc	s5,0x16
    80001b3e:	436a8a93          	addi	s5,s5,1078 # 80017f70 <tickslock>
    char *pa = kalloc();
    80001b42:	898ff0ef          	jal	80000bda <kalloc>
    80001b46:	862a                	mv	a2,a0
    if (pa == 0)
    80001b48:	c121                	beqz	a0,80001b88 <proc_mapstacks+0x98>
    uint64 va = KSTACK((int)(p - proc));
    80001b4a:	418485b3          	sub	a1,s1,s8
    80001b4e:	858d                	srai	a1,a1,0x3
    80001b50:	032585b3          	mul	a1,a1,s2
    80001b54:	05b6                	slli	a1,a1,0xd
    80001b56:	6789                	lui	a5,0x2
    80001b58:	9dbd                	addw	a1,a1,a5
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    80001b5a:	875e                	mv	a4,s7
    80001b5c:	86da                	mv	a3,s6
    80001b5e:	40b985b3          	sub	a1,s3,a1
    80001b62:	8552                	mv	a0,s4
    80001b64:	f80ff0ef          	jal	800012e4 <kvmmap>
  for (p = proc; p < &proc[NPROC]; p++) {
    80001b68:	16848493          	addi	s1,s1,360
    80001b6c:	fd549be3          	bne	s1,s5,80001b42 <proc_mapstacks+0x52>
  }
}
    80001b70:	60a6                	ld	ra,72(sp)
    80001b72:	6406                	ld	s0,64(sp)
    80001b74:	74e2                	ld	s1,56(sp)
    80001b76:	7942                	ld	s2,48(sp)
    80001b78:	79a2                	ld	s3,40(sp)
    80001b7a:	7a02                	ld	s4,32(sp)
    80001b7c:	6ae2                	ld	s5,24(sp)
    80001b7e:	6b42                	ld	s6,16(sp)
    80001b80:	6ba2                	ld	s7,8(sp)
    80001b82:	6c02                	ld	s8,0(sp)
    80001b84:	6161                	addi	sp,sp,80
    80001b86:	8082                	ret
      panic("kalloc");
    80001b88:	00006517          	auipc	a0,0x6
    80001b8c:	6b050513          	addi	a0,a0,1712 # 80008238 <userret+0x119c>
    80001b90:	cc7fe0ef          	jal	80000856 <panic>

0000000080001b94 <procinit>:

// initialize the proc table.
void procinit(void) {
    80001b94:	7139                	addi	sp,sp,-64
    80001b96:	fc06                	sd	ra,56(sp)
    80001b98:	f822                	sd	s0,48(sp)
    80001b9a:	f426                	sd	s1,40(sp)
    80001b9c:	f04a                	sd	s2,32(sp)
    80001b9e:	ec4e                	sd	s3,24(sp)
    80001ba0:	e852                	sd	s4,16(sp)
    80001ba2:	e456                	sd	s5,8(sp)
    80001ba4:	e05a                	sd	s6,0(sp)
    80001ba6:	0080                	addi	s0,sp,64
  struct proc *p;

  initlock(&pid_lock, "nextpid");
    80001ba8:	00006597          	auipc	a1,0x6
    80001bac:	69858593          	addi	a1,a1,1688 # 80008240 <userret+0x11a4>
    80001bb0:	00010517          	auipc	a0,0x10
    80001bb4:	57850513          	addi	a0,a0,1400 # 80012128 <pid_lock>
    80001bb8:	8e0ff0ef          	jal	80000c98 <initlock>
  initlock(&wait_lock, "wait_lock");
    80001bbc:	00006597          	auipc	a1,0x6
    80001bc0:	68c58593          	addi	a1,a1,1676 # 80008248 <userret+0x11ac>
    80001bc4:	00010517          	auipc	a0,0x10
    80001bc8:	57c50513          	addi	a0,a0,1404 # 80012140 <wait_lock>
    80001bcc:	8ccff0ef          	jal	80000c98 <initlock>
  initlock(&schedinfo_lock, "schedinfo");
    80001bd0:	00006597          	auipc	a1,0x6
    80001bd4:	68858593          	addi	a1,a1,1672 # 80008258 <userret+0x11bc>
    80001bd8:	00010517          	auipc	a0,0x10
    80001bdc:	58050513          	addi	a0,a0,1408 # 80012158 <schedinfo_lock>
    80001be0:	8b8ff0ef          	jal	80000c98 <initlock>
  for (p = proc; p < &proc[NPROC]; p++) {
    80001be4:	00011497          	auipc	s1,0x11
    80001be8:	98c48493          	addi	s1,s1,-1652 # 80012570 <proc>
    initlock(&p->lock, "proc");
    80001bec:	00006b17          	auipc	s6,0x6
    80001bf0:	67cb0b13          	addi	s6,s6,1660 # 80008268 <userret+0x11cc>
    p->state = UNUSED;
    p->kstack = KSTACK((int)(p - proc));
    80001bf4:	8aa6                	mv	s5,s1
    80001bf6:	000a57b7          	lui	a5,0xa5
    80001bfa:	fa578793          	addi	a5,a5,-91 # a4fa5 <_entry-0x7ff5b05b>
    80001bfe:	07b2                	slli	a5,a5,0xc
    80001c00:	fa578793          	addi	a5,a5,-91
    80001c04:	4fa50937          	lui	s2,0x4fa50
    80001c08:	a4f90913          	addi	s2,s2,-1457 # 4fa4fa4f <_entry-0x305b05b1>
    80001c0c:	1902                	slli	s2,s2,0x20
    80001c0e:	993e                	add	s2,s2,a5
    80001c10:	040009b7          	lui	s3,0x4000
    80001c14:	19fd                	addi	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    80001c16:	09b2                	slli	s3,s3,0xc
  for (p = proc; p < &proc[NPROC]; p++) {
    80001c18:	00016a17          	auipc	s4,0x16
    80001c1c:	358a0a13          	addi	s4,s4,856 # 80017f70 <tickslock>
    initlock(&p->lock, "proc");
    80001c20:	85da                	mv	a1,s6
    80001c22:	8526                	mv	a0,s1
    80001c24:	874ff0ef          	jal	80000c98 <initlock>
    p->state = UNUSED;
    80001c28:	0004ac23          	sw	zero,24(s1)
    p->kstack = KSTACK((int)(p - proc));
    80001c2c:	415487b3          	sub	a5,s1,s5
    80001c30:	878d                	srai	a5,a5,0x3
    80001c32:	032787b3          	mul	a5,a5,s2
    80001c36:	07b6                	slli	a5,a5,0xd
    80001c38:	6709                	lui	a4,0x2
    80001c3a:	9fb9                	addw	a5,a5,a4
    80001c3c:	40f987b3          	sub	a5,s3,a5
    80001c40:	e0bc                	sd	a5,64(s1)
  for (p = proc; p < &proc[NPROC]; p++) {
    80001c42:	16848493          	addi	s1,s1,360
    80001c46:	fd449de3          	bne	s1,s4,80001c20 <procinit+0x8c>
  }
}
    80001c4a:	70e2                	ld	ra,56(sp)
    80001c4c:	7442                	ld	s0,48(sp)
    80001c4e:	74a2                	ld	s1,40(sp)
    80001c50:	7902                	ld	s2,32(sp)
    80001c52:	69e2                	ld	s3,24(sp)
    80001c54:	6a42                	ld	s4,16(sp)
    80001c56:	6aa2                	ld	s5,8(sp)
    80001c58:	6b02                	ld	s6,0(sp)
    80001c5a:	6121                	addi	sp,sp,64
    80001c5c:	8082                	ret

0000000080001c5e <cpuid>:

// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int cpuid() {
    80001c5e:	1141                	addi	sp,sp,-16
    80001c60:	e406                	sd	ra,8(sp)
    80001c62:	e022                	sd	s0,0(sp)
    80001c64:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    80001c66:	8512                	mv	a0,tp
  int id = r_tp();
  return id;
}
    80001c68:	2501                	sext.w	a0,a0
    80001c6a:	60a2                	ld	ra,8(sp)
    80001c6c:	6402                	ld	s0,0(sp)
    80001c6e:	0141                	addi	sp,sp,16
    80001c70:	8082                	ret

0000000080001c72 <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu *mycpu(void) {
    80001c72:	1141                	addi	sp,sp,-16
    80001c74:	e406                	sd	ra,8(sp)
    80001c76:	e022                	sd	s0,0(sp)
    80001c78:	0800                	addi	s0,sp,16
    80001c7a:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    80001c7c:	2781                	sext.w	a5,a5
    80001c7e:	079e                	slli	a5,a5,0x7
  return c;
}
    80001c80:	00010517          	auipc	a0,0x10
    80001c84:	4f050513          	addi	a0,a0,1264 # 80012170 <cpus>
    80001c88:	953e                	add	a0,a0,a5
    80001c8a:	60a2                	ld	ra,8(sp)
    80001c8c:	6402                	ld	s0,0(sp)
    80001c8e:	0141                	addi	sp,sp,16
    80001c90:	8082                	ret

0000000080001c92 <myproc>:

// Return the current struct proc *, or zero if none.
struct proc *myproc(void) {
    80001c92:	1101                	addi	sp,sp,-32
    80001c94:	ec06                	sd	ra,24(sp)
    80001c96:	e822                	sd	s0,16(sp)
    80001c98:	e426                	sd	s1,8(sp)
    80001c9a:	1000                	addi	s0,sp,32
  push_off();
    80001c9c:	842ff0ef          	jal	80000cde <push_off>
    80001ca0:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    80001ca2:	2781                	sext.w	a5,a5
    80001ca4:	079e                	slli	a5,a5,0x7
    80001ca6:	00010717          	auipc	a4,0x10
    80001caa:	48270713          	addi	a4,a4,1154 # 80012128 <pid_lock>
    80001cae:	97ba                	add	a5,a5,a4
    80001cb0:	67bc                	ld	a5,72(a5)
    80001cb2:	84be                	mv	s1,a5
  pop_off();
    80001cb4:	8b2ff0ef          	jal	80000d66 <pop_off>
  return p;
}
    80001cb8:	8526                	mv	a0,s1
    80001cba:	60e2                	ld	ra,24(sp)
    80001cbc:	6442                	ld	s0,16(sp)
    80001cbe:	64a2                	ld	s1,8(sp)
    80001cc0:	6105                	addi	sp,sp,32
    80001cc2:	8082                	ret

0000000080001cc4 <forkret>:
  release(&p->lock);
}

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void forkret(void) {
    80001cc4:	7179                	addi	sp,sp,-48
    80001cc6:	f406                	sd	ra,40(sp)
    80001cc8:	f022                	sd	s0,32(sp)
    80001cca:	ec26                	sd	s1,24(sp)
    80001ccc:	1800                	addi	s0,sp,48
  extern char userret[];
  static int first = 1;
  struct proc *p = myproc();
    80001cce:	fc5ff0ef          	jal	80001c92 <myproc>
    80001cd2:	84aa                	mv	s1,a0

  // Still holding p->lock from scheduler.
  release(&p->lock);
    80001cd4:	8e2ff0ef          	jal	80000db6 <release>

  if (first) {
    80001cd8:	00007797          	auipc	a5,0x7
    80001cdc:	cb87a783          	lw	a5,-840(a5) # 80008990 <first.1>
    80001ce0:	cf95                	beqz	a5,80001d1c <forkret+0x58>
    // File system initialization must be run in the context of a
    // regular process (e.g., because it calls sleep), and thus cannot
    // be run from main().
    fsinit(ROOTDEV);
    80001ce2:	4505                	li	a0,1
    80001ce4:	677010ef          	jal	80003b5a <fsinit>

    first = 0;
    80001ce8:	00007797          	auipc	a5,0x7
    80001cec:	ca07a423          	sw	zero,-856(a5) # 80008990 <first.1>
    // ensure other cores see first=0.
    __sync_synchronize();
    80001cf0:	0330000f          	fence	rw,rw

    // We can invoke kexec() now that file system is initialized.
    // Put the return value (argc) of kexec into a0.
    p->trapframe->a0 = kexec("/init", (char *[]){"/init", 0});
    80001cf4:	00006797          	auipc	a5,0x6
    80001cf8:	57c78793          	addi	a5,a5,1404 # 80008270 <userret+0x11d4>
    80001cfc:	fcf43823          	sd	a5,-48(s0)
    80001d00:	fc043c23          	sd	zero,-40(s0)
    80001d04:	fd040593          	addi	a1,s0,-48
    80001d08:	853e                	mv	a0,a5
    80001d0a:	7d9020ef          	jal	80004ce2 <kexec>
    80001d0e:	6cbc                	ld	a5,88(s1)
    80001d10:	fba8                	sd	a0,112(a5)
    if (p->trapframe->a0 == -1) {
    80001d12:	6cbc                	ld	a5,88(s1)
    80001d14:	7bb8                	ld	a4,112(a5)
    80001d16:	57fd                	li	a5,-1
    80001d18:	02f70d63          	beq	a4,a5,80001d52 <forkret+0x8e>
      panic("exec");
    }
  }

  // return to user space, mimicing usertrap()'s return.
  prepare_return();
    80001d1c:	4df000ef          	jal	800029fa <prepare_return>
  uint64 satp = MAKE_SATP(p->pagetable);
    80001d20:	68a8                	ld	a0,80(s1)
    80001d22:	8131                	srli	a0,a0,0xc
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    80001d24:	04000737          	lui	a4,0x4000
    80001d28:	177d                	addi	a4,a4,-1 # 3ffffff <_entry-0x7c000001>
    80001d2a:	0732                	slli	a4,a4,0xc
    80001d2c:	00005797          	auipc	a5,0x5
    80001d30:	37078793          	addi	a5,a5,880 # 8000709c <userret>
    80001d34:	00005697          	auipc	a3,0x5
    80001d38:	2cc68693          	addi	a3,a3,716 # 80007000 <_trampoline>
    80001d3c:	8f95                	sub	a5,a5,a3
    80001d3e:	97ba                	add	a5,a5,a4
  ((void (*)(uint64))trampoline_userret)(satp);
    80001d40:	577d                	li	a4,-1
    80001d42:	177e                	slli	a4,a4,0x3f
    80001d44:	8d59                	or	a0,a0,a4
    80001d46:	9782                	jalr	a5
}
    80001d48:	70a2                	ld	ra,40(sp)
    80001d4a:	7402                	ld	s0,32(sp)
    80001d4c:	64e2                	ld	s1,24(sp)
    80001d4e:	6145                	addi	sp,sp,48
    80001d50:	8082                	ret
      panic("exec");
    80001d52:	00006517          	auipc	a0,0x6
    80001d56:	52650513          	addi	a0,a0,1318 # 80008278 <userret+0x11dc>
    80001d5a:	afdfe0ef          	jal	80000856 <panic>

0000000080001d5e <allocpid>:
int allocpid() {
    80001d5e:	1101                	addi	sp,sp,-32
    80001d60:	ec06                	sd	ra,24(sp)
    80001d62:	e822                	sd	s0,16(sp)
    80001d64:	e426                	sd	s1,8(sp)
    80001d66:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80001d68:	00010517          	auipc	a0,0x10
    80001d6c:	3c050513          	addi	a0,a0,960 # 80012128 <pid_lock>
    80001d70:	fb3fe0ef          	jal	80000d22 <acquire>
  pid = nextpid;
    80001d74:	00007797          	auipc	a5,0x7
    80001d78:	c2078793          	addi	a5,a5,-992 # 80008994 <nextpid>
    80001d7c:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80001d7e:	0014871b          	addiw	a4,s1,1
    80001d82:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001d84:	00010517          	auipc	a0,0x10
    80001d88:	3a450513          	addi	a0,a0,932 # 80012128 <pid_lock>
    80001d8c:	82aff0ef          	jal	80000db6 <release>
}
    80001d90:	8526                	mv	a0,s1
    80001d92:	60e2                	ld	ra,24(sp)
    80001d94:	6442                	ld	s0,16(sp)
    80001d96:	64a2                	ld	s1,8(sp)
    80001d98:	6105                	addi	sp,sp,32
    80001d9a:	8082                	ret

0000000080001d9c <proc_pagetable>:
pagetable_t proc_pagetable(struct proc *p) {
    80001d9c:	1101                	addi	sp,sp,-32
    80001d9e:	ec06                	sd	ra,24(sp)
    80001da0:	e822                	sd	s0,16(sp)
    80001da2:	e426                	sd	s1,8(sp)
    80001da4:	e04a                	sd	s2,0(sp)
    80001da6:	1000                	addi	s0,sp,32
    80001da8:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001daa:	e42ff0ef          	jal	800013ec <uvmcreate>
    80001dae:	84aa                	mv	s1,a0
  if (pagetable == 0)
    80001db0:	cd05                	beqz	a0,80001de8 <proc_pagetable+0x4c>
  if (mappages(pagetable, TRAMPOLINE, PGSIZE, (uint64)trampoline,
    80001db2:	4729                	li	a4,10
    80001db4:	00005697          	auipc	a3,0x5
    80001db8:	24c68693          	addi	a3,a3,588 # 80007000 <_trampoline>
    80001dbc:	6605                	lui	a2,0x1
    80001dbe:	040005b7          	lui	a1,0x4000
    80001dc2:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001dc4:	05b2                	slli	a1,a1,0xc
    80001dc6:	be8ff0ef          	jal	800011ae <mappages>
    80001dca:	02054663          	bltz	a0,80001df6 <proc_pagetable+0x5a>
  if (mappages(pagetable, TRAPFRAME, PGSIZE, (uint64)(p->trapframe),
    80001dce:	4719                	li	a4,6
    80001dd0:	05893683          	ld	a3,88(s2)
    80001dd4:	6605                	lui	a2,0x1
    80001dd6:	020005b7          	lui	a1,0x2000
    80001dda:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001ddc:	05b6                	slli	a1,a1,0xd
    80001dde:	8526                	mv	a0,s1
    80001de0:	bceff0ef          	jal	800011ae <mappages>
    80001de4:	00054f63          	bltz	a0,80001e02 <proc_pagetable+0x66>
}
    80001de8:	8526                	mv	a0,s1
    80001dea:	60e2                	ld	ra,24(sp)
    80001dec:	6442                	ld	s0,16(sp)
    80001dee:	64a2                	ld	s1,8(sp)
    80001df0:	6902                	ld	s2,0(sp)
    80001df2:	6105                	addi	sp,sp,32
    80001df4:	8082                	ret
    uvmfree(pagetable, 0);
    80001df6:	4581                	li	a1,0
    80001df8:	8526                	mv	a0,s1
    80001dfa:	905ff0ef          	jal	800016fe <uvmfree>
    return 0;
    80001dfe:	4481                	li	s1,0
    80001e00:	b7e5                	j	80001de8 <proc_pagetable+0x4c>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001e02:	4681                	li	a3,0
    80001e04:	4605                	li	a2,1
    80001e06:	040005b7          	lui	a1,0x4000
    80001e0a:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001e0c:	05b2                	slli	a1,a1,0xc
    80001e0e:	8526                	mv	a0,s1
    80001e10:	e02ff0ef          	jal	80001412 <uvmunmap>
    uvmfree(pagetable, 0);
    80001e14:	4581                	li	a1,0
    80001e16:	8526                	mv	a0,s1
    80001e18:	8e7ff0ef          	jal	800016fe <uvmfree>
    return 0;
    80001e1c:	4481                	li	s1,0
    80001e1e:	b7e9                	j	80001de8 <proc_pagetable+0x4c>

0000000080001e20 <proc_freepagetable>:
void proc_freepagetable(pagetable_t pagetable, uint64 sz) {
    80001e20:	1101                	addi	sp,sp,-32
    80001e22:	ec06                	sd	ra,24(sp)
    80001e24:	e822                	sd	s0,16(sp)
    80001e26:	e426                	sd	s1,8(sp)
    80001e28:	e04a                	sd	s2,0(sp)
    80001e2a:	1000                	addi	s0,sp,32
    80001e2c:	84aa                	mv	s1,a0
    80001e2e:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001e30:	4681                	li	a3,0
    80001e32:	4605                	li	a2,1
    80001e34:	040005b7          	lui	a1,0x4000
    80001e38:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001e3a:	05b2                	slli	a1,a1,0xc
    80001e3c:	dd6ff0ef          	jal	80001412 <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001e40:	4681                	li	a3,0
    80001e42:	4605                	li	a2,1
    80001e44:	020005b7          	lui	a1,0x2000
    80001e48:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001e4a:	05b6                	slli	a1,a1,0xd
    80001e4c:	8526                	mv	a0,s1
    80001e4e:	dc4ff0ef          	jal	80001412 <uvmunmap>
  uvmfree(pagetable, sz);
    80001e52:	85ca                	mv	a1,s2
    80001e54:	8526                	mv	a0,s1
    80001e56:	8a9ff0ef          	jal	800016fe <uvmfree>
}
    80001e5a:	60e2                	ld	ra,24(sp)
    80001e5c:	6442                	ld	s0,16(sp)
    80001e5e:	64a2                	ld	s1,8(sp)
    80001e60:	6902                	ld	s2,0(sp)
    80001e62:	6105                	addi	sp,sp,32
    80001e64:	8082                	ret

0000000080001e66 <freeproc>:
static void freeproc(struct proc *p) {
    80001e66:	1101                	addi	sp,sp,-32
    80001e68:	ec06                	sd	ra,24(sp)
    80001e6a:	e822                	sd	s0,16(sp)
    80001e6c:	e426                	sd	s1,8(sp)
    80001e6e:	1000                	addi	s0,sp,32
    80001e70:	84aa                	mv	s1,a0
  if (p->trapframe)
    80001e72:	6d28                	ld	a0,88(a0)
    80001e74:	c119                	beqz	a0,80001e7a <freeproc+0x14>
    kfree((void *)p->trapframe);
    80001e76:	c19fe0ef          	jal	80000a8e <kfree>
  p->trapframe = 0;
    80001e7a:	0404bc23          	sd	zero,88(s1)
  if (p->pagetable)
    80001e7e:	68a8                	ld	a0,80(s1)
    80001e80:	c501                	beqz	a0,80001e88 <freeproc+0x22>
    proc_freepagetable(p->pagetable, p->sz);
    80001e82:	64ac                	ld	a1,72(s1)
    80001e84:	f9dff0ef          	jal	80001e20 <proc_freepagetable>
  p->pagetable = 0;
    80001e88:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    80001e8c:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    80001e90:	0204a823          	sw	zero,48(s1)
  p->parent = 0;
    80001e94:	0204bc23          	sd	zero,56(s1)
  p->name[0] = 0;
    80001e98:	14048c23          	sb	zero,344(s1)
  p->chan = 0;
    80001e9c:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    80001ea0:	0204a423          	sw	zero,40(s1)
  p->xstate = 0;
    80001ea4:	0204a623          	sw	zero,44(s1)
  p->state = UNUSED;
    80001ea8:	0004ac23          	sw	zero,24(s1)
}
    80001eac:	60e2                	ld	ra,24(sp)
    80001eae:	6442                	ld	s0,16(sp)
    80001eb0:	64a2                	ld	s1,8(sp)
    80001eb2:	6105                	addi	sp,sp,32
    80001eb4:	8082                	ret

0000000080001eb6 <allocproc>:
static struct proc *allocproc(void) {
    80001eb6:	1101                	addi	sp,sp,-32
    80001eb8:	ec06                	sd	ra,24(sp)
    80001eba:	e822                	sd	s0,16(sp)
    80001ebc:	e426                	sd	s1,8(sp)
    80001ebe:	e04a                	sd	s2,0(sp)
    80001ec0:	1000                	addi	s0,sp,32
  for (p = proc; p < &proc[NPROC]; p++) {
    80001ec2:	00010497          	auipc	s1,0x10
    80001ec6:	6ae48493          	addi	s1,s1,1710 # 80012570 <proc>
    80001eca:	00016917          	auipc	s2,0x16
    80001ece:	0a690913          	addi	s2,s2,166 # 80017f70 <tickslock>
    acquire(&p->lock);
    80001ed2:	8526                	mv	a0,s1
    80001ed4:	e4ffe0ef          	jal	80000d22 <acquire>
    if (p->state == UNUSED) {
    80001ed8:	4c9c                	lw	a5,24(s1)
    80001eda:	cb91                	beqz	a5,80001eee <allocproc+0x38>
      release(&p->lock);
    80001edc:	8526                	mv	a0,s1
    80001ede:	ed9fe0ef          	jal	80000db6 <release>
  for (p = proc; p < &proc[NPROC]; p++) {
    80001ee2:	16848493          	addi	s1,s1,360
    80001ee6:	ff2496e3          	bne	s1,s2,80001ed2 <allocproc+0x1c>
  return 0;
    80001eea:	4481                	li	s1,0
    80001eec:	a089                	j	80001f2e <allocproc+0x78>
  p->pid = allocpid();
    80001eee:	e71ff0ef          	jal	80001d5e <allocpid>
    80001ef2:	d888                	sw	a0,48(s1)
  p->state = USED;
    80001ef4:	4785                	li	a5,1
    80001ef6:	cc9c                	sw	a5,24(s1)
  if ((p->trapframe = (struct trapframe *)kalloc()) == 0) {
    80001ef8:	ce3fe0ef          	jal	80000bda <kalloc>
    80001efc:	892a                	mv	s2,a0
    80001efe:	eca8                	sd	a0,88(s1)
    80001f00:	cd15                	beqz	a0,80001f3c <allocproc+0x86>
  p->pagetable = proc_pagetable(p);
    80001f02:	8526                	mv	a0,s1
    80001f04:	e99ff0ef          	jal	80001d9c <proc_pagetable>
    80001f08:	892a                	mv	s2,a0
    80001f0a:	e8a8                	sd	a0,80(s1)
  if (p->pagetable == 0) {
    80001f0c:	c121                	beqz	a0,80001f4c <allocproc+0x96>
  memset(&p->context, 0, sizeof(p->context));
    80001f0e:	07000613          	li	a2,112
    80001f12:	4581                	li	a1,0
    80001f14:	06048513          	addi	a0,s1,96
    80001f18:	edbfe0ef          	jal	80000df2 <memset>
  p->context.ra = (uint64)forkret;
    80001f1c:	00000797          	auipc	a5,0x0
    80001f20:	da878793          	addi	a5,a5,-600 # 80001cc4 <forkret>
    80001f24:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001f26:	60bc                	ld	a5,64(s1)
    80001f28:	6705                	lui	a4,0x1
    80001f2a:	97ba                	add	a5,a5,a4
    80001f2c:	f4bc                	sd	a5,104(s1)
}
    80001f2e:	8526                	mv	a0,s1
    80001f30:	60e2                	ld	ra,24(sp)
    80001f32:	6442                	ld	s0,16(sp)
    80001f34:	64a2                	ld	s1,8(sp)
    80001f36:	6902                	ld	s2,0(sp)
    80001f38:	6105                	addi	sp,sp,32
    80001f3a:	8082                	ret
    freeproc(p);
    80001f3c:	8526                	mv	a0,s1
    80001f3e:	f29ff0ef          	jal	80001e66 <freeproc>
    release(&p->lock);
    80001f42:	8526                	mv	a0,s1
    80001f44:	e73fe0ef          	jal	80000db6 <release>
    return 0;
    80001f48:	84ca                	mv	s1,s2
    80001f4a:	b7d5                	j	80001f2e <allocproc+0x78>
    freeproc(p);
    80001f4c:	8526                	mv	a0,s1
    80001f4e:	f19ff0ef          	jal	80001e66 <freeproc>
    release(&p->lock);
    80001f52:	8526                	mv	a0,s1
    80001f54:	e63fe0ef          	jal	80000db6 <release>
    return 0;
    80001f58:	84ca                	mv	s1,s2
    80001f5a:	bfd1                	j	80001f2e <allocproc+0x78>

0000000080001f5c <userinit>:
void userinit(void) {
    80001f5c:	1101                	addi	sp,sp,-32
    80001f5e:	ec06                	sd	ra,24(sp)
    80001f60:	e822                	sd	s0,16(sp)
    80001f62:	e426                	sd	s1,8(sp)
    80001f64:	1000                	addi	s0,sp,32
  p = allocproc();
    80001f66:	f51ff0ef          	jal	80001eb6 <allocproc>
    80001f6a:	84aa                	mv	s1,a0
  initproc = p;
    80001f6c:	00007797          	auipc	a5,0x7
    80001f70:	0aa7be23          	sd	a0,188(a5) # 80009028 <initproc>
  p->cwd = namei("/");
    80001f74:	00006517          	auipc	a0,0x6
    80001f78:	30c50513          	addi	a0,a0,780 # 80008280 <userret+0x11e4>
    80001f7c:	118020ef          	jal	80004094 <namei>
    80001f80:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    80001f84:	478d                	li	a5,3
    80001f86:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001f88:	8526                	mv	a0,s1
    80001f8a:	e2dfe0ef          	jal	80000db6 <release>
}
    80001f8e:	60e2                	ld	ra,24(sp)
    80001f90:	6442                	ld	s0,16(sp)
    80001f92:	64a2                	ld	s1,8(sp)
    80001f94:	6105                	addi	sp,sp,32
    80001f96:	8082                	ret

0000000080001f98 <growproc>:
int growproc(int n) {
    80001f98:	7135                	addi	sp,sp,-160
    80001f9a:	ed06                	sd	ra,152(sp)
    80001f9c:	e922                	sd	s0,144(sp)
    80001f9e:	e526                	sd	s1,136(sp)
    80001fa0:	e14a                	sd	s2,128(sp)
    80001fa2:	fcce                	sd	s3,120(sp)
    80001fa4:	1100                	addi	s0,sp,160
    80001fa6:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80001fa8:	cebff0ef          	jal	80001c92 <myproc>
    80001fac:	89aa                	mv	s3,a0
  sz = p->sz;
    80001fae:	04853903          	ld	s2,72(a0)
  if (n > 0) {
    80001fb2:	02905b63          	blez	s1,80001fe8 <growproc+0x50>
    if (sz + n > TRAPFRAME) {
    80001fb6:	01248633          	add	a2,s1,s2
    80001fba:	020007b7          	lui	a5,0x2000
    80001fbe:	17fd                	addi	a5,a5,-1 # 1ffffff <_entry-0x7e000001>
    80001fc0:	07b6                	slli	a5,a5,0xd
    80001fc2:	08c7ee63          	bltu	a5,a2,8000205e <growproc+0xc6>
    if ((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0) {
    80001fc6:	4691                	li	a3,4
    80001fc8:	85ca                	mv	a1,s2
    80001fca:	6928                	ld	a0,80(a0)
    80001fcc:	daaff0ef          	jal	80001576 <uvmalloc>
    80001fd0:	892a                	mv	s2,a0
    80001fd2:	c941                	beqz	a0,80002062 <growproc+0xca>
  p->sz = sz;
    80001fd4:	0529b423          	sd	s2,72(s3)
  return 0;
    80001fd8:	4501                	li	a0,0
}
    80001fda:	60ea                	ld	ra,152(sp)
    80001fdc:	644a                	ld	s0,144(sp)
    80001fde:	64aa                	ld	s1,136(sp)
    80001fe0:	690a                	ld	s2,128(sp)
    80001fe2:	79e6                	ld	s3,120(sp)
    80001fe4:	610d                	addi	sp,sp,160
    80001fe6:	8082                	ret
  } else if (n < 0) {
    80001fe8:	fe04d6e3          	bgez	s1,80001fd4 <growproc+0x3c>
  memset(&e, 0, sizeof(e));
    80001fec:	06800613          	li	a2,104
    80001ff0:	4581                	li	a1,0
    80001ff2:	f6840513          	addi	a0,s0,-152
    80001ff6:	dfdfe0ef          	jal	80000df2 <memset>
  e.ticks  = ticks;
    80001ffa:	00007797          	auipc	a5,0x7
    80001ffe:	0367a783          	lw	a5,54(a5) # 80009030 <ticks>
    80002002:	f6f42823          	sw	a5,-144(s0)
    80002006:	8792                	mv	a5,tp
  int id = r_tp();
    80002008:	f6f42a23          	sw	a5,-140(s0)
  e.type   = MEM_SHRINK;
    8000200c:	4789                	li	a5,2
    8000200e:	f6f42c23          	sw	a5,-136(s0)
  e.pid    = p->pid;
    80002012:	0309a783          	lw	a5,48(s3)
    80002016:	f6f42e23          	sw	a5,-132(s0)
  e.state  = p->state;
    8000201a:	0189a783          	lw	a5,24(s3)
    8000201e:	f8f42023          	sw	a5,-128(s0)
  e.oldsz  = sz;
    80002022:	fb243423          	sd	s2,-88(s0)
  e.newsz  = sz + n;
    80002026:	94ca                	add	s1,s1,s2
    80002028:	fa943823          	sd	s1,-80(s0)
  e.source = SRC_UVMDEALLOC;
    8000202c:	4799                	li	a5,6
    8000202e:	fcf42223          	sw	a5,-60(s0)
  e.kind   = PAGE_USER;
    80002032:	4785                	li	a5,1
    80002034:	fcf42423          	sw	a5,-56(s0)
  safestrcpy(e.name, p->name, MEM_NM);
    80002038:	4641                	li	a2,16
    8000203a:	15898593          	addi	a1,s3,344
    8000203e:	f8440513          	addi	a0,s0,-124
    80002042:	f05fe0ef          	jal	80000f46 <safestrcpy>
  memlog_push(&e);
    80002046:	f6840513          	addi	a0,s0,-152
    8000204a:	502040ef          	jal	8000654c <memlog_push>
  sz = uvmdealloc(p->pagetable, sz, sz + n);
    8000204e:	8626                	mv	a2,s1
    80002050:	85ca                	mv	a1,s2
    80002052:	0509b503          	ld	a0,80(s3)
    80002056:	cdcff0ef          	jal	80001532 <uvmdealloc>
    8000205a:	892a                	mv	s2,a0
    8000205c:	bfa5                	j	80001fd4 <growproc+0x3c>
      return -1;
    8000205e:	557d                	li	a0,-1
    80002060:	bfad                	j	80001fda <growproc+0x42>
      return -1;
    80002062:	557d                	li	a0,-1
    80002064:	bf9d                	j	80001fda <growproc+0x42>

0000000080002066 <kfork>:
int kfork(void) {
    80002066:	7139                	addi	sp,sp,-64
    80002068:	fc06                	sd	ra,56(sp)
    8000206a:	f822                	sd	s0,48(sp)
    8000206c:	f426                	sd	s1,40(sp)
    8000206e:	e456                	sd	s5,8(sp)
    80002070:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    80002072:	c21ff0ef          	jal	80001c92 <myproc>
    80002076:	8aaa                	mv	s5,a0
  if ((np = allocproc()) == 0) {
    80002078:	e3fff0ef          	jal	80001eb6 <allocproc>
    8000207c:	0e050a63          	beqz	a0,80002170 <kfork+0x10a>
    80002080:	e852                	sd	s4,16(sp)
    80002082:	8a2a                	mv	s4,a0
  if (uvmcopy(p->pagetable, np->pagetable, p->sz) < 0) {
    80002084:	048ab603          	ld	a2,72(s5)
    80002088:	692c                	ld	a1,80(a0)
    8000208a:	050ab503          	ld	a0,80(s5)
    8000208e:	ea2ff0ef          	jal	80001730 <uvmcopy>
    80002092:	04054863          	bltz	a0,800020e2 <kfork+0x7c>
    80002096:	f04a                	sd	s2,32(sp)
    80002098:	ec4e                	sd	s3,24(sp)
  np->sz = p->sz;
    8000209a:	048ab783          	ld	a5,72(s5)
    8000209e:	04fa3423          	sd	a5,72(s4)
  *(np->trapframe) = *(p->trapframe);
    800020a2:	058ab683          	ld	a3,88(s5)
    800020a6:	87b6                	mv	a5,a3
    800020a8:	058a3703          	ld	a4,88(s4)
    800020ac:	12068693          	addi	a3,a3,288
    800020b0:	6388                	ld	a0,0(a5)
    800020b2:	678c                	ld	a1,8(a5)
    800020b4:	6b90                	ld	a2,16(a5)
    800020b6:	e308                	sd	a0,0(a4)
    800020b8:	e70c                	sd	a1,8(a4)
    800020ba:	eb10                	sd	a2,16(a4)
    800020bc:	6f90                	ld	a2,24(a5)
    800020be:	ef10                	sd	a2,24(a4)
    800020c0:	02078793          	addi	a5,a5,32
    800020c4:	02070713          	addi	a4,a4,32 # 1020 <_entry-0x7fffefe0>
    800020c8:	fed794e3          	bne	a5,a3,800020b0 <kfork+0x4a>
  np->trapframe->a0 = 0;
    800020cc:	058a3783          	ld	a5,88(s4)
    800020d0:	0607b823          	sd	zero,112(a5)
  for (i = 0; i < NOFILE; i++)
    800020d4:	0d0a8493          	addi	s1,s5,208
    800020d8:	0d0a0913          	addi	s2,s4,208
    800020dc:	150a8993          	addi	s3,s5,336
    800020e0:	a831                	j	800020fc <kfork+0x96>
    freeproc(np);
    800020e2:	8552                	mv	a0,s4
    800020e4:	d83ff0ef          	jal	80001e66 <freeproc>
    release(&np->lock);
    800020e8:	8552                	mv	a0,s4
    800020ea:	ccdfe0ef          	jal	80000db6 <release>
    return -1;
    800020ee:	54fd                	li	s1,-1
    800020f0:	6a42                	ld	s4,16(sp)
    800020f2:	a885                	j	80002162 <kfork+0xfc>
  for (i = 0; i < NOFILE; i++)
    800020f4:	04a1                	addi	s1,s1,8
    800020f6:	0921                	addi	s2,s2,8
    800020f8:	01348963          	beq	s1,s3,8000210a <kfork+0xa4>
    if (p->ofile[i])
    800020fc:	6088                	ld	a0,0(s1)
    800020fe:	d97d                	beqz	a0,800020f4 <kfork+0x8e>
      np->ofile[i] = filedup(p->ofile[i]);
    80002100:	550020ef          	jal	80004650 <filedup>
    80002104:	00a93023          	sd	a0,0(s2)
    80002108:	b7f5                	j	800020f4 <kfork+0x8e>
  np->cwd = idup(p->cwd);
    8000210a:	150ab503          	ld	a0,336(s5)
    8000210e:	722010ef          	jal	80003830 <idup>
    80002112:	14aa3823          	sd	a0,336(s4)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80002116:	4641                	li	a2,16
    80002118:	158a8593          	addi	a1,s5,344
    8000211c:	158a0513          	addi	a0,s4,344
    80002120:	e27fe0ef          	jal	80000f46 <safestrcpy>
  pid = np->pid;
    80002124:	030a2483          	lw	s1,48(s4)
  release(&np->lock);
    80002128:	8552                	mv	a0,s4
    8000212a:	c8dfe0ef          	jal	80000db6 <release>
  acquire(&wait_lock);
    8000212e:	00010517          	auipc	a0,0x10
    80002132:	01250513          	addi	a0,a0,18 # 80012140 <wait_lock>
    80002136:	bedfe0ef          	jal	80000d22 <acquire>
  np->parent = p;
    8000213a:	035a3c23          	sd	s5,56(s4)
  release(&wait_lock);
    8000213e:	00010517          	auipc	a0,0x10
    80002142:	00250513          	addi	a0,a0,2 # 80012140 <wait_lock>
    80002146:	c71fe0ef          	jal	80000db6 <release>
  acquire(&np->lock);
    8000214a:	8552                	mv	a0,s4
    8000214c:	bd7fe0ef          	jal	80000d22 <acquire>
  np->state = RUNNABLE;
    80002150:	478d                	li	a5,3
    80002152:	00fa2c23          	sw	a5,24(s4)
  release(&np->lock);
    80002156:	8552                	mv	a0,s4
    80002158:	c5ffe0ef          	jal	80000db6 <release>
  return pid;
    8000215c:	7902                	ld	s2,32(sp)
    8000215e:	69e2                	ld	s3,24(sp)
    80002160:	6a42                	ld	s4,16(sp)
}
    80002162:	8526                	mv	a0,s1
    80002164:	70e2                	ld	ra,56(sp)
    80002166:	7442                	ld	s0,48(sp)
    80002168:	74a2                	ld	s1,40(sp)
    8000216a:	6aa2                	ld	s5,8(sp)
    8000216c:	6121                	addi	sp,sp,64
    8000216e:	8082                	ret
    return -1;
    80002170:	54fd                	li	s1,-1
    80002172:	bfc5                	j	80002162 <kfork+0xfc>

0000000080002174 <scheduler>:
void scheduler(void) {
    80002174:	7171                	addi	sp,sp,-176
    80002176:	f506                	sd	ra,168(sp)
    80002178:	f122                	sd	s0,160(sp)
    8000217a:	ed26                	sd	s1,152(sp)
    8000217c:	e94a                	sd	s2,144(sp)
    8000217e:	e54e                	sd	s3,136(sp)
    80002180:	e152                	sd	s4,128(sp)
    80002182:	fcd6                	sd	s5,120(sp)
    80002184:	f8da                	sd	s6,112(sp)
    80002186:	f4de                	sd	s7,104(sp)
    80002188:	f0e2                	sd	s8,96(sp)
    8000218a:	ece6                	sd	s9,88(sp)
    8000218c:	e8ea                	sd	s10,80(sp)
    8000218e:	1900                	addi	s0,sp,176
    80002190:	8492                	mv	s1,tp
  int id = r_tp();
    80002192:	2481                	sext.w	s1,s1
    80002194:	8792                	mv	a5,tp
    if(cpuid() == 0){
    80002196:	2781                	sext.w	a5,a5
    80002198:	c79d                	beqz	a5,800021c6 <scheduler+0x52>
  c->proc = 0;
    8000219a:	00749b93          	slli	s7,s1,0x7
    8000219e:	00010797          	auipc	a5,0x10
    800021a2:	f8a78793          	addi	a5,a5,-118 # 80012128 <pid_lock>
    800021a6:	97de                	add	a5,a5,s7
    800021a8:	0407b423          	sd	zero,72(a5)
        swtch(&c->context, &p->context);
    800021ac:	00010797          	auipc	a5,0x10
    800021b0:	fcc78793          	addi	a5,a5,-52 # 80012178 <cpus+0x8>
    800021b4:	9bbe                	add	s7,s7,a5
        p->state = RUNNING;
    800021b6:	4b11                	li	s6,4
        c->proc = p;
    800021b8:	049e                	slli	s1,s1,0x7
    800021ba:	00010a97          	auipc	s5,0x10
    800021be:	f6ea8a93          	addi	s5,s5,-146 # 80012128 <pid_lock>
    800021c2:	9aa6                	add	s5,s5,s1
    800021c4:	a2d5                	j	800023a8 <scheduler+0x234>
      acquire(&schedinfo_lock);
    800021c6:	00010517          	auipc	a0,0x10
    800021ca:	f9250513          	addi	a0,a0,-110 # 80012158 <schedinfo_lock>
    800021ce:	b55fe0ef          	jal	80000d22 <acquire>
      if(sched_info_logged == 0){
    800021d2:	00007797          	auipc	a5,0x7
    800021d6:	e4e7a783          	lw	a5,-434(a5) # 80009020 <sched_info_logged>
    800021da:	cb81                	beqz	a5,800021ea <scheduler+0x76>
      release(&schedinfo_lock);
    800021dc:	00010517          	auipc	a0,0x10
    800021e0:	f7c50513          	addi	a0,a0,-132 # 80012158 <schedinfo_lock>
    800021e4:	bd3fe0ef          	jal	80000db6 <release>
    800021e8:	bf4d                	j	8000219a <scheduler+0x26>
        sched_info_logged = 1;
    800021ea:	4905                	li	s2,1
    800021ec:	00007797          	auipc	a5,0x7
    800021f0:	e327aa23          	sw	s2,-460(a5) # 80009020 <sched_info_logged>
        memset(&e, 0, sizeof(e));
    800021f4:	f5840993          	addi	s3,s0,-168
    800021f8:	04400613          	li	a2,68
    800021fc:	4581                	li	a1,0
    800021fe:	854e                	mv	a0,s3
    80002200:	bf3fe0ef          	jal	80000df2 <memset>
        e.ticks = ticks;
    80002204:	00007797          	auipc	a5,0x7
    80002208:	e2c7a783          	lw	a5,-468(a5) # 80009030 <ticks>
    8000220c:	f4f42e23          	sw	a5,-164(s0)
        e.event_type = SCHED_EV_INFO;
    80002210:	f7242023          	sw	s2,-160(s0)
        safestrcpy(e.scheduler_name, "RR", sizeof(e.scheduler_name));
    80002214:	4641                	li	a2,16
    80002216:	00006597          	auipc	a1,0x6
    8000221a:	07258593          	addi	a1,a1,114 # 80008288 <userret+0x11ec>
    8000221e:	f6440513          	addi	a0,s0,-156
    80002222:	d25fe0ef          	jal	80000f46 <safestrcpy>
        e.num_cpus = 3;
    80002226:	478d                	li	a5,3
    80002228:	f6f42a23          	sw	a5,-140(s0)
        e.time_slice = 1;
    8000222c:	f7242c23          	sw	s2,-136(s0)
        schedlog_emit(&e);
    80002230:	854e                	mv	a0,s3
    80002232:	57c040ef          	jal	800067ae <schedlog_emit>
    80002236:	b75d                	j	800021dc <scheduler+0x68>
        if(strncmp(p->name, "schedexport", 16) != 0){
    80002238:	158c8c13          	addi	s8,s9,344
    8000223c:	864e                	mv	a2,s3
    8000223e:	85d2                	mv	a1,s4
    80002240:	8562                	mv	a0,s8
    80002242:	c85fe0ef          	jal	80000ec6 <strncmp>
    80002246:	e945                	bnez	a0,800022f6 <scheduler+0x182>
        swtch(&c->context, &p->context);
    80002248:	060c8593          	addi	a1,s9,96
    8000224c:	855e                	mv	a0,s7
    8000224e:	702000ef          	jal	80002950 <swtch>
        if(strncmp(p->name, "schedexport", 16) != 0){
    80002252:	864e                	mv	a2,s3
    80002254:	85d2                	mv	a1,s4
    80002256:	8562                	mv	a0,s8
    80002258:	c6ffe0ef          	jal	80000ec6 <strncmp>
    8000225c:	0e051163          	bnez	a0,8000233e <scheduler+0x1ca>
        c->proc = 0;
    80002260:	040ab423          	sd	zero,72(s5)
        found = 1;
    80002264:	4c05                	li	s8,1
      release(&p->lock);
    80002266:	8526                	mv	a0,s1
    80002268:	b4ffe0ef          	jal	80000db6 <release>
    for (p = proc; p < &proc[NPROC]; p++) {
    8000226c:	16848493          	addi	s1,s1,360
    80002270:	00016797          	auipc	a5,0x16
    80002274:	d0078793          	addi	a5,a5,-768 # 80017f70 <tickslock>
    80002278:	12f48463          	beq	s1,a5,800023a0 <scheduler+0x22c>
      acquire(&p->lock);
    8000227c:	8526                	mv	a0,s1
    8000227e:	aa5fe0ef          	jal	80000d22 <acquire>
      if (p->state == RUNNABLE) {
    80002282:	4c9c                	lw	a5,24(s1)
    80002284:	ff2791e3          	bne	a5,s2,80002266 <scheduler+0xf2>
    80002288:	8ca6                	mv	s9,s1
        p->state = RUNNING;
    8000228a:	0164ac23          	sw	s6,24(s1)
        c->proc = p;
    8000228e:	049ab423          	sd	s1,72(s5)
        cslog_run_start(p);
    80002292:	8526                	mv	a0,s1
    80002294:	661030ef          	jal	800060f4 <cslog_run_start>
    80002298:	8792                	mv	a5,tp
        if (cpuid() == 0 && sched_info_logged == 0) {
    8000229a:	2781                	sext.w	a5,a5
    8000229c:	ffd1                	bnez	a5,80002238 <scheduler+0xc4>
    8000229e:	00007797          	auipc	a5,0x7
    800022a2:	d827a783          	lw	a5,-638(a5) # 80009020 <sched_info_logged>
    800022a6:	fbc9                	bnez	a5,80002238 <scheduler+0xc4>
          sched_info_logged = 1;
    800022a8:	4c05                	li	s8,1
    800022aa:	00007797          	auipc	a5,0x7
    800022ae:	d787ab23          	sw	s8,-650(a5) # 80009020 <sched_info_logged>
          memset(&e, 0, sizeof(e));
    800022b2:	f5840d13          	addi	s10,s0,-168
    800022b6:	04400613          	li	a2,68
    800022ba:	4581                	li	a1,0
    800022bc:	856a                	mv	a0,s10
    800022be:	b35fe0ef          	jal	80000df2 <memset>
          e.ticks = ticks;
    800022c2:	00007797          	auipc	a5,0x7
    800022c6:	d6e7a783          	lw	a5,-658(a5) # 80009030 <ticks>
    800022ca:	f4f42e23          	sw	a5,-164(s0)
          e.event_type = SCHED_EV_INFO;
    800022ce:	f7842023          	sw	s8,-160(s0)
          safestrcpy(e.scheduler_name, "RR", sizeof(e.scheduler_name));
    800022d2:	864e                	mv	a2,s3
    800022d4:	00006597          	auipc	a1,0x6
    800022d8:	fb458593          	addi	a1,a1,-76 # 80008288 <userret+0x11ec>
    800022dc:	f6440513          	addi	a0,s0,-156
    800022e0:	c67fe0ef          	jal	80000f46 <safestrcpy>
          e.num_cpus = NCPU;
    800022e4:	47a1                	li	a5,8
    800022e6:	f6f42a23          	sw	a5,-140(s0)
          e.time_slice = 1;
    800022ea:	f7842c23          	sw	s8,-136(s0)
          schedlog_emit(&e);
    800022ee:	856a                	mv	a0,s10
    800022f0:	4be040ef          	jal	800067ae <schedlog_emit>
    800022f4:	b791                	j	80002238 <scheduler+0xc4>
          memset(&e, 0, sizeof(e));
    800022f6:	f5840d13          	addi	s10,s0,-168
    800022fa:	04400613          	li	a2,68
    800022fe:	4581                	li	a1,0
    80002300:	856a                	mv	a0,s10
    80002302:	af1fe0ef          	jal	80000df2 <memset>
          e.ticks = ticks;
    80002306:	00007797          	auipc	a5,0x7
    8000230a:	d2a7a783          	lw	a5,-726(a5) # 80009030 <ticks>
    8000230e:	f4f42e23          	sw	a5,-164(s0)
          e.event_type = SCHED_EV_ON_CPU;
    80002312:	4789                	li	a5,2
    80002314:	f6f42023          	sw	a5,-160(s0)
    80002318:	8792                	mv	a5,tp
  int id = r_tp();
    8000231a:	f6f42e23          	sw	a5,-132(s0)
          e.pid = p->pid;
    8000231e:	589c                	lw	a5,48(s1)
    80002320:	f8f42023          	sw	a5,-128(s0)
          safestrcpy(e.name, p->name, sizeof(e.name));
    80002324:	864e                	mv	a2,s3
    80002326:	85e2                	mv	a1,s8
    80002328:	f8440513          	addi	a0,s0,-124
    8000232c:	c1bfe0ef          	jal	80000f46 <safestrcpy>
          e.state = p->state;
    80002330:	4c9c                	lw	a5,24(s1)
    80002332:	f8f42a23          	sw	a5,-108(s0)
          schedlog_emit(&e);
    80002336:	856a                	mv	a0,s10
    80002338:	476040ef          	jal	800067ae <schedlog_emit>
    8000233c:	b731                	j	80002248 <scheduler+0xd4>
          memset(&e2, 0, sizeof(e2));
    8000233e:	04400613          	li	a2,68
    80002342:	4581                	li	a1,0
    80002344:	f5840513          	addi	a0,s0,-168
    80002348:	aabfe0ef          	jal	80000df2 <memset>
          e2.ticks = ticks;
    8000234c:	00007797          	auipc	a5,0x7
    80002350:	ce47a783          	lw	a5,-796(a5) # 80009030 <ticks>
    80002354:	f4f42e23          	sw	a5,-164(s0)
          e2.event_type = SCHED_EV_OFF_CPU;
    80002358:	f7242023          	sw	s2,-160(s0)
    8000235c:	8792                	mv	a5,tp
  int id = r_tp();
    8000235e:	f6f42e23          	sw	a5,-132(s0)
          e2.pid = p->pid;
    80002362:	589c                	lw	a5,48(s1)
    80002364:	f8f42023          	sw	a5,-128(s0)
          safestrcpy(e2.name, p->name, sizeof(e2.name));
    80002368:	864e                	mv	a2,s3
    8000236a:	85e2                	mv	a1,s8
    8000236c:	f8440513          	addi	a0,s0,-124
    80002370:	bd7fe0ef          	jal	80000f46 <safestrcpy>
          e2.state = p->state;
    80002374:	4c9c                	lw	a5,24(s1)
          if(p->state == SLEEPING)
    80002376:	4689                	li	a3,2
    80002378:	8736                	mv	a4,a3
    8000237a:	00d78a63          	beq	a5,a3,8000238e <scheduler+0x21a>
          else if(p->state == ZOMBIE)
    8000237e:	4695                	li	a3,5
    80002380:	875a                	mv	a4,s6
    80002382:	00d78663          	beq	a5,a3,8000238e <scheduler+0x21a>
          else if(p->state == RUNNABLE)
    80002386:	874a                	mv	a4,s2
    80002388:	01278363          	beq	a5,s2,8000238e <scheduler+0x21a>
    8000238c:	4701                	li	a4,0
          e2.state = p->state;
    8000238e:	f8f42a23          	sw	a5,-108(s0)
            e2.reason = SCHED_OFF_SLEEP;
    80002392:	f8e42c23          	sw	a4,-104(s0)
          schedlog_emit(&e2);
    80002396:	f5840513          	addi	a0,s0,-168
    8000239a:	414040ef          	jal	800067ae <schedlog_emit>
    8000239e:	b5c9                	j	80002260 <scheduler+0xec>
    if (found == 0) {
    800023a0:	000c1563          	bnez	s8,800023aa <scheduler+0x236>
      asm volatile("wfi");
    800023a4:	10500073          	wfi
      if (p->state == RUNNABLE) {
    800023a8:	490d                	li	s2,3
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800023aa:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    800023ae:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800023b2:	10079073          	csrw	sstatus,a5
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800023b6:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    800023ba:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800023bc:	10079073          	csrw	sstatus,a5
    int found = 0;
    800023c0:	4c01                	li	s8,0
    for (p = proc; p < &proc[NPROC]; p++) {
    800023c2:	00010497          	auipc	s1,0x10
    800023c6:	1ae48493          	addi	s1,s1,430 # 80012570 <proc>
        if(strncmp(p->name, "schedexport", 16) != 0){
    800023ca:	49c1                	li	s3,16
    800023cc:	00006a17          	auipc	s4,0x6
    800023d0:	ec4a0a13          	addi	s4,s4,-316 # 80008290 <userret+0x11f4>
    800023d4:	b565                	j	8000227c <scheduler+0x108>

00000000800023d6 <sched>:
void sched(void) {
    800023d6:	7179                	addi	sp,sp,-48
    800023d8:	f406                	sd	ra,40(sp)
    800023da:	f022                	sd	s0,32(sp)
    800023dc:	ec26                	sd	s1,24(sp)
    800023de:	e84a                	sd	s2,16(sp)
    800023e0:	e44e                	sd	s3,8(sp)
    800023e2:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    800023e4:	8afff0ef          	jal	80001c92 <myproc>
    800023e8:	84aa                	mv	s1,a0
  if (!holding(&p->lock))
    800023ea:	8c9fe0ef          	jal	80000cb2 <holding>
    800023ee:	c935                	beqz	a0,80002462 <sched+0x8c>
  asm volatile("mv %0, tp" : "=r" (x) );
    800023f0:	8792                	mv	a5,tp
  if (mycpu()->noff != 1)
    800023f2:	2781                	sext.w	a5,a5
    800023f4:	079e                	slli	a5,a5,0x7
    800023f6:	00010717          	auipc	a4,0x10
    800023fa:	d3270713          	addi	a4,a4,-718 # 80012128 <pid_lock>
    800023fe:	97ba                	add	a5,a5,a4
    80002400:	0c07a703          	lw	a4,192(a5)
    80002404:	4785                	li	a5,1
    80002406:	06f71463          	bne	a4,a5,8000246e <sched+0x98>
  if (p->state == RUNNING)
    8000240a:	4c98                	lw	a4,24(s1)
    8000240c:	4791                	li	a5,4
    8000240e:	06f70663          	beq	a4,a5,8000247a <sched+0xa4>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002412:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002416:	8b89                	andi	a5,a5,2
  if (intr_get())
    80002418:	e7bd                	bnez	a5,80002486 <sched+0xb0>
  asm volatile("mv %0, tp" : "=r" (x) );
    8000241a:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    8000241c:	00010917          	auipc	s2,0x10
    80002420:	d0c90913          	addi	s2,s2,-756 # 80012128 <pid_lock>
    80002424:	2781                	sext.w	a5,a5
    80002426:	079e                	slli	a5,a5,0x7
    80002428:	97ca                	add	a5,a5,s2
    8000242a:	0c47a983          	lw	s3,196(a5)
    8000242e:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    80002430:	2781                	sext.w	a5,a5
    80002432:	079e                	slli	a5,a5,0x7
    80002434:	07a1                	addi	a5,a5,8
    80002436:	00010597          	auipc	a1,0x10
    8000243a:	d3a58593          	addi	a1,a1,-710 # 80012170 <cpus>
    8000243e:	95be                	add	a1,a1,a5
    80002440:	06048513          	addi	a0,s1,96
    80002444:	50c000ef          	jal	80002950 <swtch>
    80002448:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    8000244a:	2781                	sext.w	a5,a5
    8000244c:	079e                	slli	a5,a5,0x7
    8000244e:	993e                	add	s2,s2,a5
    80002450:	0d392223          	sw	s3,196(s2)
}
    80002454:	70a2                	ld	ra,40(sp)
    80002456:	7402                	ld	s0,32(sp)
    80002458:	64e2                	ld	s1,24(sp)
    8000245a:	6942                	ld	s2,16(sp)
    8000245c:	69a2                	ld	s3,8(sp)
    8000245e:	6145                	addi	sp,sp,48
    80002460:	8082                	ret
    panic("sched p->lock");
    80002462:	00006517          	auipc	a0,0x6
    80002466:	e3e50513          	addi	a0,a0,-450 # 800082a0 <userret+0x1204>
    8000246a:	becfe0ef          	jal	80000856 <panic>
    panic("sched locks");
    8000246e:	00006517          	auipc	a0,0x6
    80002472:	e4250513          	addi	a0,a0,-446 # 800082b0 <userret+0x1214>
    80002476:	be0fe0ef          	jal	80000856 <panic>
    panic("sched RUNNING");
    8000247a:	00006517          	auipc	a0,0x6
    8000247e:	e4650513          	addi	a0,a0,-442 # 800082c0 <userret+0x1224>
    80002482:	bd4fe0ef          	jal	80000856 <panic>
    panic("sched interruptible");
    80002486:	00006517          	auipc	a0,0x6
    8000248a:	e4a50513          	addi	a0,a0,-438 # 800082d0 <userret+0x1234>
    8000248e:	bc8fe0ef          	jal	80000856 <panic>

0000000080002492 <yield>:
void yield(void) {
    80002492:	1101                	addi	sp,sp,-32
    80002494:	ec06                	sd	ra,24(sp)
    80002496:	e822                	sd	s0,16(sp)
    80002498:	e426                	sd	s1,8(sp)
    8000249a:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    8000249c:	ff6ff0ef          	jal	80001c92 <myproc>
    800024a0:	84aa                	mv	s1,a0
  acquire(&p->lock);
    800024a2:	881fe0ef          	jal	80000d22 <acquire>
  p->state = RUNNABLE;
    800024a6:	478d                	li	a5,3
    800024a8:	cc9c                	sw	a5,24(s1)
  sched();
    800024aa:	f2dff0ef          	jal	800023d6 <sched>
  release(&p->lock);
    800024ae:	8526                	mv	a0,s1
    800024b0:	907fe0ef          	jal	80000db6 <release>
}
    800024b4:	60e2                	ld	ra,24(sp)
    800024b6:	6442                	ld	s0,16(sp)
    800024b8:	64a2                	ld	s1,8(sp)
    800024ba:	6105                	addi	sp,sp,32
    800024bc:	8082                	ret

00000000800024be <sleep>:

// Sleep on channel chan, releasing condition lock lk.
// Re-acquires lk when awakened.
void sleep(void *chan, struct spinlock *lk) {
    800024be:	7179                	addi	sp,sp,-48
    800024c0:	f406                	sd	ra,40(sp)
    800024c2:	f022                	sd	s0,32(sp)
    800024c4:	ec26                	sd	s1,24(sp)
    800024c6:	e84a                	sd	s2,16(sp)
    800024c8:	e44e                	sd	s3,8(sp)
    800024ca:	1800                	addi	s0,sp,48
    800024cc:	89aa                	mv	s3,a0
    800024ce:	892e                	mv	s2,a1
  struct proc *p = myproc();
    800024d0:	fc2ff0ef          	jal	80001c92 <myproc>
    800024d4:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock); // DOC: sleeplock1
    800024d6:	84dfe0ef          	jal	80000d22 <acquire>
  release(lk);
    800024da:	854a                	mv	a0,s2
    800024dc:	8dbfe0ef          	jal	80000db6 <release>

  // Go to sleep.
  p->chan = chan;
    800024e0:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    800024e4:	4789                	li	a5,2
    800024e6:	cc9c                	sw	a5,24(s1)

  sched();
    800024e8:	eefff0ef          	jal	800023d6 <sched>

  // Tidy up.
  p->chan = 0;
    800024ec:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    800024f0:	8526                	mv	a0,s1
    800024f2:	8c5fe0ef          	jal	80000db6 <release>
  acquire(lk);
    800024f6:	854a                	mv	a0,s2
    800024f8:	82bfe0ef          	jal	80000d22 <acquire>
}
    800024fc:	70a2                	ld	ra,40(sp)
    800024fe:	7402                	ld	s0,32(sp)
    80002500:	64e2                	ld	s1,24(sp)
    80002502:	6942                	ld	s2,16(sp)
    80002504:	69a2                	ld	s3,8(sp)
    80002506:	6145                	addi	sp,sp,48
    80002508:	8082                	ret

000000008000250a <wakeup>:

// Wake up all processes sleeping on channel chan.
// Caller should hold the condition lock.
void wakeup(void *chan) {
    8000250a:	7139                	addi	sp,sp,-64
    8000250c:	fc06                	sd	ra,56(sp)
    8000250e:	f822                	sd	s0,48(sp)
    80002510:	f426                	sd	s1,40(sp)
    80002512:	f04a                	sd	s2,32(sp)
    80002514:	ec4e                	sd	s3,24(sp)
    80002516:	e852                	sd	s4,16(sp)
    80002518:	e456                	sd	s5,8(sp)
    8000251a:	0080                	addi	s0,sp,64
    8000251c:	8a2a                	mv	s4,a0
  struct proc *p;

  for (p = proc; p < &proc[NPROC]; p++) {
    8000251e:	00010497          	auipc	s1,0x10
    80002522:	05248493          	addi	s1,s1,82 # 80012570 <proc>
    if (p != myproc()) {
      acquire(&p->lock);
      if (p->state == SLEEPING && p->chan == chan) {
    80002526:	4989                	li	s3,2
        p->state = RUNNABLE;
    80002528:	4a8d                	li	s5,3
  for (p = proc; p < &proc[NPROC]; p++) {
    8000252a:	00016917          	auipc	s2,0x16
    8000252e:	a4690913          	addi	s2,s2,-1466 # 80017f70 <tickslock>
    80002532:	a801                	j	80002542 <wakeup+0x38>
      }
      release(&p->lock);
    80002534:	8526                	mv	a0,s1
    80002536:	881fe0ef          	jal	80000db6 <release>
  for (p = proc; p < &proc[NPROC]; p++) {
    8000253a:	16848493          	addi	s1,s1,360
    8000253e:	03248263          	beq	s1,s2,80002562 <wakeup+0x58>
    if (p != myproc()) {
    80002542:	f50ff0ef          	jal	80001c92 <myproc>
    80002546:	fe950ae3          	beq	a0,s1,8000253a <wakeup+0x30>
      acquire(&p->lock);
    8000254a:	8526                	mv	a0,s1
    8000254c:	fd6fe0ef          	jal	80000d22 <acquire>
      if (p->state == SLEEPING && p->chan == chan) {
    80002550:	4c9c                	lw	a5,24(s1)
    80002552:	ff3791e3          	bne	a5,s3,80002534 <wakeup+0x2a>
    80002556:	709c                	ld	a5,32(s1)
    80002558:	fd479ee3          	bne	a5,s4,80002534 <wakeup+0x2a>
        p->state = RUNNABLE;
    8000255c:	0154ac23          	sw	s5,24(s1)
    80002560:	bfd1                	j	80002534 <wakeup+0x2a>
    }
  }
}
    80002562:	70e2                	ld	ra,56(sp)
    80002564:	7442                	ld	s0,48(sp)
    80002566:	74a2                	ld	s1,40(sp)
    80002568:	7902                	ld	s2,32(sp)
    8000256a:	69e2                	ld	s3,24(sp)
    8000256c:	6a42                	ld	s4,16(sp)
    8000256e:	6aa2                	ld	s5,8(sp)
    80002570:	6121                	addi	sp,sp,64
    80002572:	8082                	ret

0000000080002574 <reparent>:
void reparent(struct proc *p) {
    80002574:	7179                	addi	sp,sp,-48
    80002576:	f406                	sd	ra,40(sp)
    80002578:	f022                	sd	s0,32(sp)
    8000257a:	ec26                	sd	s1,24(sp)
    8000257c:	e84a                	sd	s2,16(sp)
    8000257e:	e44e                	sd	s3,8(sp)
    80002580:	e052                	sd	s4,0(sp)
    80002582:	1800                	addi	s0,sp,48
    80002584:	892a                	mv	s2,a0
  for (pp = proc; pp < &proc[NPROC]; pp++) {
    80002586:	00010497          	auipc	s1,0x10
    8000258a:	fea48493          	addi	s1,s1,-22 # 80012570 <proc>
      pp->parent = initproc;
    8000258e:	00007a17          	auipc	s4,0x7
    80002592:	a9aa0a13          	addi	s4,s4,-1382 # 80009028 <initproc>
  for (pp = proc; pp < &proc[NPROC]; pp++) {
    80002596:	00016997          	auipc	s3,0x16
    8000259a:	9da98993          	addi	s3,s3,-1574 # 80017f70 <tickslock>
    8000259e:	a029                	j	800025a8 <reparent+0x34>
    800025a0:	16848493          	addi	s1,s1,360
    800025a4:	01348b63          	beq	s1,s3,800025ba <reparent+0x46>
    if (pp->parent == p) {
    800025a8:	7c9c                	ld	a5,56(s1)
    800025aa:	ff279be3          	bne	a5,s2,800025a0 <reparent+0x2c>
      pp->parent = initproc;
    800025ae:	000a3503          	ld	a0,0(s4)
    800025b2:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    800025b4:	f57ff0ef          	jal	8000250a <wakeup>
    800025b8:	b7e5                	j	800025a0 <reparent+0x2c>
}
    800025ba:	70a2                	ld	ra,40(sp)
    800025bc:	7402                	ld	s0,32(sp)
    800025be:	64e2                	ld	s1,24(sp)
    800025c0:	6942                	ld	s2,16(sp)
    800025c2:	69a2                	ld	s3,8(sp)
    800025c4:	6a02                	ld	s4,0(sp)
    800025c6:	6145                	addi	sp,sp,48
    800025c8:	8082                	ret

00000000800025ca <kexit>:
void kexit(int status) {
    800025ca:	7179                	addi	sp,sp,-48
    800025cc:	f406                	sd	ra,40(sp)
    800025ce:	f022                	sd	s0,32(sp)
    800025d0:	ec26                	sd	s1,24(sp)
    800025d2:	e84a                	sd	s2,16(sp)
    800025d4:	e44e                	sd	s3,8(sp)
    800025d6:	e052                	sd	s4,0(sp)
    800025d8:	1800                	addi	s0,sp,48
    800025da:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    800025dc:	eb6ff0ef          	jal	80001c92 <myproc>
    800025e0:	89aa                	mv	s3,a0
  if (p == initproc)
    800025e2:	00007797          	auipc	a5,0x7
    800025e6:	a467b783          	ld	a5,-1466(a5) # 80009028 <initproc>
    800025ea:	0d050493          	addi	s1,a0,208
    800025ee:	15050913          	addi	s2,a0,336
    800025f2:	00a79b63          	bne	a5,a0,80002608 <kexit+0x3e>
    panic("init exiting");
    800025f6:	00006517          	auipc	a0,0x6
    800025fa:	cf250513          	addi	a0,a0,-782 # 800082e8 <userret+0x124c>
    800025fe:	a58fe0ef          	jal	80000856 <panic>
  for (int fd = 0; fd < NOFILE; fd++) {
    80002602:	04a1                	addi	s1,s1,8
    80002604:	01248963          	beq	s1,s2,80002616 <kexit+0x4c>
    if (p->ofile[fd]) {
    80002608:	6088                	ld	a0,0(s1)
    8000260a:	dd65                	beqz	a0,80002602 <kexit+0x38>
      fileclose(f);
    8000260c:	08a020ef          	jal	80004696 <fileclose>
      p->ofile[fd] = 0;
    80002610:	0004b023          	sd	zero,0(s1)
    80002614:	b7fd                	j	80002602 <kexit+0x38>
  begin_op();
    80002616:	45d010ef          	jal	80004272 <begin_op>
  iput(p->cwd);
    8000261a:	1509b503          	ld	a0,336(s3)
    8000261e:	3ca010ef          	jal	800039e8 <iput>
  end_op();
    80002622:	4c1010ef          	jal	800042e2 <end_op>
  p->cwd = 0;
    80002626:	1409b823          	sd	zero,336(s3)
  acquire(&wait_lock);
    8000262a:	00010517          	auipc	a0,0x10
    8000262e:	b1650513          	addi	a0,a0,-1258 # 80012140 <wait_lock>
    80002632:	ef0fe0ef          	jal	80000d22 <acquire>
  reparent(p);
    80002636:	854e                	mv	a0,s3
    80002638:	f3dff0ef          	jal	80002574 <reparent>
  wakeup(p->parent);
    8000263c:	0389b503          	ld	a0,56(s3)
    80002640:	ecbff0ef          	jal	8000250a <wakeup>
  acquire(&p->lock);
    80002644:	854e                	mv	a0,s3
    80002646:	edcfe0ef          	jal	80000d22 <acquire>
  p->xstate = status;
    8000264a:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    8000264e:	4795                	li	a5,5
    80002650:	00f9ac23          	sw	a5,24(s3)
  release(&wait_lock);
    80002654:	00010517          	auipc	a0,0x10
    80002658:	aec50513          	addi	a0,a0,-1300 # 80012140 <wait_lock>
    8000265c:	f5afe0ef          	jal	80000db6 <release>
  sched();
    80002660:	d77ff0ef          	jal	800023d6 <sched>
  panic("zombie exit");
    80002664:	00006517          	auipc	a0,0x6
    80002668:	c9450513          	addi	a0,a0,-876 # 800082f8 <userret+0x125c>
    8000266c:	9eafe0ef          	jal	80000856 <panic>

0000000080002670 <kkill>:

// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int kkill(int pid) {
    80002670:	7179                	addi	sp,sp,-48
    80002672:	f406                	sd	ra,40(sp)
    80002674:	f022                	sd	s0,32(sp)
    80002676:	ec26                	sd	s1,24(sp)
    80002678:	e84a                	sd	s2,16(sp)
    8000267a:	e44e                	sd	s3,8(sp)
    8000267c:	1800                	addi	s0,sp,48
    8000267e:	892a                	mv	s2,a0
  struct proc *p;

  for (p = proc; p < &proc[NPROC]; p++) {
    80002680:	00010497          	auipc	s1,0x10
    80002684:	ef048493          	addi	s1,s1,-272 # 80012570 <proc>
    80002688:	00016997          	auipc	s3,0x16
    8000268c:	8e898993          	addi	s3,s3,-1816 # 80017f70 <tickslock>
    acquire(&p->lock);
    80002690:	8526                	mv	a0,s1
    80002692:	e90fe0ef          	jal	80000d22 <acquire>
    if (p->pid == pid) {
    80002696:	589c                	lw	a5,48(s1)
    80002698:	01278b63          	beq	a5,s2,800026ae <kkill+0x3e>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    8000269c:	8526                	mv	a0,s1
    8000269e:	f18fe0ef          	jal	80000db6 <release>
  for (p = proc; p < &proc[NPROC]; p++) {
    800026a2:	16848493          	addi	s1,s1,360
    800026a6:	ff3495e3          	bne	s1,s3,80002690 <kkill+0x20>
  }
  return -1;
    800026aa:	557d                	li	a0,-1
    800026ac:	a819                	j	800026c2 <kkill+0x52>
      p->killed = 1;
    800026ae:	4785                	li	a5,1
    800026b0:	d49c                	sw	a5,40(s1)
      if (p->state == SLEEPING) {
    800026b2:	4c98                	lw	a4,24(s1)
    800026b4:	4789                	li	a5,2
    800026b6:	00f70d63          	beq	a4,a5,800026d0 <kkill+0x60>
      release(&p->lock);
    800026ba:	8526                	mv	a0,s1
    800026bc:	efafe0ef          	jal	80000db6 <release>
      return 0;
    800026c0:	4501                	li	a0,0
}
    800026c2:	70a2                	ld	ra,40(sp)
    800026c4:	7402                	ld	s0,32(sp)
    800026c6:	64e2                	ld	s1,24(sp)
    800026c8:	6942                	ld	s2,16(sp)
    800026ca:	69a2                	ld	s3,8(sp)
    800026cc:	6145                	addi	sp,sp,48
    800026ce:	8082                	ret
        p->state = RUNNABLE;
    800026d0:	478d                	li	a5,3
    800026d2:	cc9c                	sw	a5,24(s1)
    800026d4:	b7dd                	j	800026ba <kkill+0x4a>

00000000800026d6 <setkilled>:

void setkilled(struct proc *p) {
    800026d6:	1101                	addi	sp,sp,-32
    800026d8:	ec06                	sd	ra,24(sp)
    800026da:	e822                	sd	s0,16(sp)
    800026dc:	e426                	sd	s1,8(sp)
    800026de:	1000                	addi	s0,sp,32
    800026e0:	84aa                	mv	s1,a0
  acquire(&p->lock);
    800026e2:	e40fe0ef          	jal	80000d22 <acquire>
  p->killed = 1;
    800026e6:	4785                	li	a5,1
    800026e8:	d49c                	sw	a5,40(s1)
  release(&p->lock);
    800026ea:	8526                	mv	a0,s1
    800026ec:	ecafe0ef          	jal	80000db6 <release>
}
    800026f0:	60e2                	ld	ra,24(sp)
    800026f2:	6442                	ld	s0,16(sp)
    800026f4:	64a2                	ld	s1,8(sp)
    800026f6:	6105                	addi	sp,sp,32
    800026f8:	8082                	ret

00000000800026fa <killed>:

int killed(struct proc *p) {
    800026fa:	1101                	addi	sp,sp,-32
    800026fc:	ec06                	sd	ra,24(sp)
    800026fe:	e822                	sd	s0,16(sp)
    80002700:	e426                	sd	s1,8(sp)
    80002702:	e04a                	sd	s2,0(sp)
    80002704:	1000                	addi	s0,sp,32
    80002706:	84aa                	mv	s1,a0
  int k;

  acquire(&p->lock);
    80002708:	e1afe0ef          	jal	80000d22 <acquire>
  k = p->killed;
    8000270c:	549c                	lw	a5,40(s1)
    8000270e:	893e                	mv	s2,a5
  release(&p->lock);
    80002710:	8526                	mv	a0,s1
    80002712:	ea4fe0ef          	jal	80000db6 <release>
  return k;
}
    80002716:	854a                	mv	a0,s2
    80002718:	60e2                	ld	ra,24(sp)
    8000271a:	6442                	ld	s0,16(sp)
    8000271c:	64a2                	ld	s1,8(sp)
    8000271e:	6902                	ld	s2,0(sp)
    80002720:	6105                	addi	sp,sp,32
    80002722:	8082                	ret

0000000080002724 <kwait>:
int kwait(uint64 addr) {
    80002724:	715d                	addi	sp,sp,-80
    80002726:	e486                	sd	ra,72(sp)
    80002728:	e0a2                	sd	s0,64(sp)
    8000272a:	fc26                	sd	s1,56(sp)
    8000272c:	f84a                	sd	s2,48(sp)
    8000272e:	f44e                	sd	s3,40(sp)
    80002730:	f052                	sd	s4,32(sp)
    80002732:	ec56                	sd	s5,24(sp)
    80002734:	e85a                	sd	s6,16(sp)
    80002736:	e45e                	sd	s7,8(sp)
    80002738:	0880                	addi	s0,sp,80
    8000273a:	8baa                	mv	s7,a0
  struct proc *p = myproc();
    8000273c:	d56ff0ef          	jal	80001c92 <myproc>
    80002740:	892a                	mv	s2,a0
  acquire(&wait_lock);
    80002742:	00010517          	auipc	a0,0x10
    80002746:	9fe50513          	addi	a0,a0,-1538 # 80012140 <wait_lock>
    8000274a:	dd8fe0ef          	jal	80000d22 <acquire>
        if (pp->state == ZOMBIE) {
    8000274e:	4a15                	li	s4,5
        havekids = 1;
    80002750:	4a85                	li	s5,1
    for (pp = proc; pp < &proc[NPROC]; pp++) {
    80002752:	00016997          	auipc	s3,0x16
    80002756:	81e98993          	addi	s3,s3,-2018 # 80017f70 <tickslock>
    sleep(p, &wait_lock); // DOC: wait-sleep
    8000275a:	00010b17          	auipc	s6,0x10
    8000275e:	9e6b0b13          	addi	s6,s6,-1562 # 80012140 <wait_lock>
    80002762:	a869                	j	800027fc <kwait+0xd8>
          pid = pp->pid;
    80002764:	0304a983          	lw	s3,48(s1)
          if (addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    80002768:	000b8c63          	beqz	s7,80002780 <kwait+0x5c>
    8000276c:	4691                	li	a3,4
    8000276e:	02c48613          	addi	a2,s1,44
    80002772:	85de                	mv	a1,s7
    80002774:	05093503          	ld	a0,80(s2)
    80002778:	a2cff0ef          	jal	800019a4 <copyout>
    8000277c:	02054a63          	bltz	a0,800027b0 <kwait+0x8c>
          freeproc(pp);
    80002780:	8526                	mv	a0,s1
    80002782:	ee4ff0ef          	jal	80001e66 <freeproc>
          release(&pp->lock);
    80002786:	8526                	mv	a0,s1
    80002788:	e2efe0ef          	jal	80000db6 <release>
          release(&wait_lock);
    8000278c:	00010517          	auipc	a0,0x10
    80002790:	9b450513          	addi	a0,a0,-1612 # 80012140 <wait_lock>
    80002794:	e22fe0ef          	jal	80000db6 <release>
}
    80002798:	854e                	mv	a0,s3
    8000279a:	60a6                	ld	ra,72(sp)
    8000279c:	6406                	ld	s0,64(sp)
    8000279e:	74e2                	ld	s1,56(sp)
    800027a0:	7942                	ld	s2,48(sp)
    800027a2:	79a2                	ld	s3,40(sp)
    800027a4:	7a02                	ld	s4,32(sp)
    800027a6:	6ae2                	ld	s5,24(sp)
    800027a8:	6b42                	ld	s6,16(sp)
    800027aa:	6ba2                	ld	s7,8(sp)
    800027ac:	6161                	addi	sp,sp,80
    800027ae:	8082                	ret
            release(&pp->lock);
    800027b0:	8526                	mv	a0,s1
    800027b2:	e04fe0ef          	jal	80000db6 <release>
            release(&wait_lock);
    800027b6:	00010517          	auipc	a0,0x10
    800027ba:	98a50513          	addi	a0,a0,-1654 # 80012140 <wait_lock>
    800027be:	df8fe0ef          	jal	80000db6 <release>
            return -1;
    800027c2:	59fd                	li	s3,-1
    800027c4:	bfd1                	j	80002798 <kwait+0x74>
    for (pp = proc; pp < &proc[NPROC]; pp++) {
    800027c6:	16848493          	addi	s1,s1,360
    800027ca:	03348063          	beq	s1,s3,800027ea <kwait+0xc6>
      if (pp->parent == p) {
    800027ce:	7c9c                	ld	a5,56(s1)
    800027d0:	ff279be3          	bne	a5,s2,800027c6 <kwait+0xa2>
        acquire(&pp->lock);
    800027d4:	8526                	mv	a0,s1
    800027d6:	d4cfe0ef          	jal	80000d22 <acquire>
        if (pp->state == ZOMBIE) {
    800027da:	4c9c                	lw	a5,24(s1)
    800027dc:	f94784e3          	beq	a5,s4,80002764 <kwait+0x40>
        release(&pp->lock);
    800027e0:	8526                	mv	a0,s1
    800027e2:	dd4fe0ef          	jal	80000db6 <release>
        havekids = 1;
    800027e6:	8756                	mv	a4,s5
    800027e8:	bff9                	j	800027c6 <kwait+0xa2>
    if (!havekids || killed(p)) {
    800027ea:	cf19                	beqz	a4,80002808 <kwait+0xe4>
    800027ec:	854a                	mv	a0,s2
    800027ee:	f0dff0ef          	jal	800026fa <killed>
    800027f2:	e919                	bnez	a0,80002808 <kwait+0xe4>
    sleep(p, &wait_lock); // DOC: wait-sleep
    800027f4:	85da                	mv	a1,s6
    800027f6:	854a                	mv	a0,s2
    800027f8:	cc7ff0ef          	jal	800024be <sleep>
    havekids = 0;
    800027fc:	4701                	li	a4,0
    for (pp = proc; pp < &proc[NPROC]; pp++) {
    800027fe:	00010497          	auipc	s1,0x10
    80002802:	d7248493          	addi	s1,s1,-654 # 80012570 <proc>
    80002806:	b7e1                	j	800027ce <kwait+0xaa>
      release(&wait_lock);
    80002808:	00010517          	auipc	a0,0x10
    8000280c:	93850513          	addi	a0,a0,-1736 # 80012140 <wait_lock>
    80002810:	da6fe0ef          	jal	80000db6 <release>
      return -1;
    80002814:	59fd                	li	s3,-1
    80002816:	b749                	j	80002798 <kwait+0x74>

0000000080002818 <either_copyout>:

// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int either_copyout(int user_dst, uint64 dst, void *src, uint64 len) {
    80002818:	7179                	addi	sp,sp,-48
    8000281a:	f406                	sd	ra,40(sp)
    8000281c:	f022                	sd	s0,32(sp)
    8000281e:	ec26                	sd	s1,24(sp)
    80002820:	e84a                	sd	s2,16(sp)
    80002822:	e44e                	sd	s3,8(sp)
    80002824:	e052                	sd	s4,0(sp)
    80002826:	1800                	addi	s0,sp,48
    80002828:	84aa                	mv	s1,a0
    8000282a:	8a2e                	mv	s4,a1
    8000282c:	89b2                	mv	s3,a2
    8000282e:	8936                	mv	s2,a3
  struct proc *p = myproc();
    80002830:	c62ff0ef          	jal	80001c92 <myproc>
  if (user_dst) {
    80002834:	cc99                	beqz	s1,80002852 <either_copyout+0x3a>
    return copyout(p->pagetable, dst, src, len);
    80002836:	86ca                	mv	a3,s2
    80002838:	864e                	mv	a2,s3
    8000283a:	85d2                	mv	a1,s4
    8000283c:	6928                	ld	a0,80(a0)
    8000283e:	966ff0ef          	jal	800019a4 <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    80002842:	70a2                	ld	ra,40(sp)
    80002844:	7402                	ld	s0,32(sp)
    80002846:	64e2                	ld	s1,24(sp)
    80002848:	6942                	ld	s2,16(sp)
    8000284a:	69a2                	ld	s3,8(sp)
    8000284c:	6a02                	ld	s4,0(sp)
    8000284e:	6145                	addi	sp,sp,48
    80002850:	8082                	ret
    memmove((char *)dst, src, len);
    80002852:	0009061b          	sext.w	a2,s2
    80002856:	85ce                	mv	a1,s3
    80002858:	8552                	mv	a0,s4
    8000285a:	df8fe0ef          	jal	80000e52 <memmove>
    return 0;
    8000285e:	8526                	mv	a0,s1
    80002860:	b7cd                	j	80002842 <either_copyout+0x2a>

0000000080002862 <either_copyin>:

// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int either_copyin(void *dst, int user_src, uint64 src, uint64 len) {
    80002862:	7179                	addi	sp,sp,-48
    80002864:	f406                	sd	ra,40(sp)
    80002866:	f022                	sd	s0,32(sp)
    80002868:	ec26                	sd	s1,24(sp)
    8000286a:	e84a                	sd	s2,16(sp)
    8000286c:	e44e                	sd	s3,8(sp)
    8000286e:	e052                	sd	s4,0(sp)
    80002870:	1800                	addi	s0,sp,48
    80002872:	8a2a                	mv	s4,a0
    80002874:	84ae                	mv	s1,a1
    80002876:	89b2                	mv	s3,a2
    80002878:	8936                	mv	s2,a3
  struct proc *p = myproc();
    8000287a:	c18ff0ef          	jal	80001c92 <myproc>
  if (user_src) {
    8000287e:	cc99                	beqz	s1,8000289c <either_copyin+0x3a>
    return copyin(p->pagetable, dst, src, len);
    80002880:	86ca                	mv	a3,s2
    80002882:	864e                	mv	a2,s3
    80002884:	85d2                	mv	a1,s4
    80002886:	6928                	ld	a0,80(a0)
    80002888:	9daff0ef          	jal	80001a62 <copyin>
  } else {
    memmove(dst, (char *)src, len);
    return 0;
  }
}
    8000288c:	70a2                	ld	ra,40(sp)
    8000288e:	7402                	ld	s0,32(sp)
    80002890:	64e2                	ld	s1,24(sp)
    80002892:	6942                	ld	s2,16(sp)
    80002894:	69a2                	ld	s3,8(sp)
    80002896:	6a02                	ld	s4,0(sp)
    80002898:	6145                	addi	sp,sp,48
    8000289a:	8082                	ret
    memmove(dst, (char *)src, len);
    8000289c:	0009061b          	sext.w	a2,s2
    800028a0:	85ce                	mv	a1,s3
    800028a2:	8552                	mv	a0,s4
    800028a4:	daefe0ef          	jal	80000e52 <memmove>
    return 0;
    800028a8:	8526                	mv	a0,s1
    800028aa:	b7cd                	j	8000288c <either_copyin+0x2a>

00000000800028ac <procdump>:

// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void procdump(void) {
    800028ac:	715d                	addi	sp,sp,-80
    800028ae:	e486                	sd	ra,72(sp)
    800028b0:	e0a2                	sd	s0,64(sp)
    800028b2:	fc26                	sd	s1,56(sp)
    800028b4:	f84a                	sd	s2,48(sp)
    800028b6:	f44e                	sd	s3,40(sp)
    800028b8:	f052                	sd	s4,32(sp)
    800028ba:	ec56                	sd	s5,24(sp)
    800028bc:	e85a                	sd	s6,16(sp)
    800028be:	e45e                	sd	s7,8(sp)
    800028c0:	0880                	addi	s0,sp,80
      [UNUSED] "unused",   [USED] "used",      [SLEEPING] "sleep ",
      [RUNNABLE] "runble", [RUNNING] "run   ", [ZOMBIE] "zombie"};
  struct proc *p;
  char *state;

  printf("\n");
    800028c2:	00005517          	auipc	a0,0x5
    800028c6:	7be50513          	addi	a0,a0,1982 # 80008080 <userret+0xfe4>
    800028ca:	c63fd0ef          	jal	8000052c <printf>
  for (p = proc; p < &proc[NPROC]; p++) {
    800028ce:	00010497          	auipc	s1,0x10
    800028d2:	dfa48493          	addi	s1,s1,-518 # 800126c8 <proc+0x158>
    800028d6:	00015917          	auipc	s2,0x15
    800028da:	7f290913          	addi	s2,s2,2034 # 800180c8 <bcache+0x140>
    if (p->state == UNUSED)
      continue;
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800028de:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    800028e0:	00006997          	auipc	s3,0x6
    800028e4:	a2898993          	addi	s3,s3,-1496 # 80008308 <userret+0x126c>
    printf("%d %s %s", p->pid, state, p->name);
    800028e8:	00006a97          	auipc	s5,0x6
    800028ec:	a28a8a93          	addi	s5,s5,-1496 # 80008310 <userret+0x1274>
    printf("\n");
    800028f0:	00005a17          	auipc	s4,0x5
    800028f4:	790a0a13          	addi	s4,s4,1936 # 80008080 <userret+0xfe4>
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800028f8:	00006b97          	auipc	s7,0x6
    800028fc:	f80b8b93          	addi	s7,s7,-128 # 80008878 <states.0>
    80002900:	a829                	j	8000291a <procdump+0x6e>
    printf("%d %s %s", p->pid, state, p->name);
    80002902:	ed86a583          	lw	a1,-296(a3)
    80002906:	8556                	mv	a0,s5
    80002908:	c25fd0ef          	jal	8000052c <printf>
    printf("\n");
    8000290c:	8552                	mv	a0,s4
    8000290e:	c1ffd0ef          	jal	8000052c <printf>
  for (p = proc; p < &proc[NPROC]; p++) {
    80002912:	16848493          	addi	s1,s1,360
    80002916:	03248263          	beq	s1,s2,8000293a <procdump+0x8e>
    if (p->state == UNUSED)
    8000291a:	86a6                	mv	a3,s1
    8000291c:	ec04a783          	lw	a5,-320(s1)
    80002920:	dbed                	beqz	a5,80002912 <procdump+0x66>
      state = "???";
    80002922:	864e                	mv	a2,s3
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002924:	fcfb6fe3          	bltu	s6,a5,80002902 <procdump+0x56>
    80002928:	02079713          	slli	a4,a5,0x20
    8000292c:	01d75793          	srli	a5,a4,0x1d
    80002930:	97de                	add	a5,a5,s7
    80002932:	6390                	ld	a2,0(a5)
    80002934:	f679                	bnez	a2,80002902 <procdump+0x56>
      state = "???";
    80002936:	864e                	mv	a2,s3
    80002938:	b7e9                	j	80002902 <procdump+0x56>
  }
}
    8000293a:	60a6                	ld	ra,72(sp)
    8000293c:	6406                	ld	s0,64(sp)
    8000293e:	74e2                	ld	s1,56(sp)
    80002940:	7942                	ld	s2,48(sp)
    80002942:	79a2                	ld	s3,40(sp)
    80002944:	7a02                	ld	s4,32(sp)
    80002946:	6ae2                	ld	s5,24(sp)
    80002948:	6b42                	ld	s6,16(sp)
    8000294a:	6ba2                	ld	s7,8(sp)
    8000294c:	6161                	addi	sp,sp,80
    8000294e:	8082                	ret

0000000080002950 <swtch>:
# Save current registers in old. Load from new.	


.globl swtch
swtch:
        sd ra, 0(a0)
    80002950:	00153023          	sd	ra,0(a0)
        sd sp, 8(a0)
    80002954:	00253423          	sd	sp,8(a0)
        sd s0, 16(a0)
    80002958:	e900                	sd	s0,16(a0)
        sd s1, 24(a0)
    8000295a:	ed04                	sd	s1,24(a0)
        sd s2, 32(a0)
    8000295c:	03253023          	sd	s2,32(a0)
        sd s3, 40(a0)
    80002960:	03353423          	sd	s3,40(a0)
        sd s4, 48(a0)
    80002964:	03453823          	sd	s4,48(a0)
        sd s5, 56(a0)
    80002968:	03553c23          	sd	s5,56(a0)
        sd s6, 64(a0)
    8000296c:	05653023          	sd	s6,64(a0)
        sd s7, 72(a0)
    80002970:	05753423          	sd	s7,72(a0)
        sd s8, 80(a0)
    80002974:	05853823          	sd	s8,80(a0)
        sd s9, 88(a0)
    80002978:	05953c23          	sd	s9,88(a0)
        sd s10, 96(a0)
    8000297c:	07a53023          	sd	s10,96(a0)
        sd s11, 104(a0)
    80002980:	07b53423          	sd	s11,104(a0)

        ld ra, 0(a1)
    80002984:	0005b083          	ld	ra,0(a1)
        ld sp, 8(a1)
    80002988:	0085b103          	ld	sp,8(a1)
        ld s0, 16(a1)
    8000298c:	6980                	ld	s0,16(a1)
        ld s1, 24(a1)
    8000298e:	6d84                	ld	s1,24(a1)
        ld s2, 32(a1)
    80002990:	0205b903          	ld	s2,32(a1)
        ld s3, 40(a1)
    80002994:	0285b983          	ld	s3,40(a1)
        ld s4, 48(a1)
    80002998:	0305ba03          	ld	s4,48(a1)
        ld s5, 56(a1)
    8000299c:	0385ba83          	ld	s5,56(a1)
        ld s6, 64(a1)
    800029a0:	0405bb03          	ld	s6,64(a1)
        ld s7, 72(a1)
    800029a4:	0485bb83          	ld	s7,72(a1)
        ld s8, 80(a1)
    800029a8:	0505bc03          	ld	s8,80(a1)
        ld s9, 88(a1)
    800029ac:	0585bc83          	ld	s9,88(a1)
        ld s10, 96(a1)
    800029b0:	0605bd03          	ld	s10,96(a1)
        ld s11, 104(a1)
    800029b4:	0685bd83          	ld	s11,104(a1)
        
        ret
    800029b8:	8082                	ret

00000000800029ba <trapinit>:

extern int devintr();

void
trapinit(void)
{
    800029ba:	1141                	addi	sp,sp,-16
    800029bc:	e406                	sd	ra,8(sp)
    800029be:	e022                	sd	s0,0(sp)
    800029c0:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    800029c2:	00006597          	auipc	a1,0x6
    800029c6:	98e58593          	addi	a1,a1,-1650 # 80008350 <userret+0x12b4>
    800029ca:	00015517          	auipc	a0,0x15
    800029ce:	5a650513          	addi	a0,a0,1446 # 80017f70 <tickslock>
    800029d2:	ac6fe0ef          	jal	80000c98 <initlock>
}
    800029d6:	60a2                	ld	ra,8(sp)
    800029d8:	6402                	ld	s0,0(sp)
    800029da:	0141                	addi	sp,sp,16
    800029dc:	8082                	ret

00000000800029de <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    800029de:	1141                	addi	sp,sp,-16
    800029e0:	e406                	sd	ra,8(sp)
    800029e2:	e022                	sd	s0,0(sp)
    800029e4:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    800029e6:	00003797          	auipc	a5,0x3
    800029ea:	0aa78793          	addi	a5,a5,170 # 80005a90 <kernelvec>
    800029ee:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    800029f2:	60a2                	ld	ra,8(sp)
    800029f4:	6402                	ld	s0,0(sp)
    800029f6:	0141                	addi	sp,sp,16
    800029f8:	8082                	ret

00000000800029fa <prepare_return>:
//
// set up trapframe and control registers for a return to user space
//
void
prepare_return(void)
{
    800029fa:	1141                	addi	sp,sp,-16
    800029fc:	e406                	sd	ra,8(sp)
    800029fe:	e022                	sd	s0,0(sp)
    80002a00:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    80002a02:	a90ff0ef          	jal	80001c92 <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002a06:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80002a0a:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002a0c:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(). because a trap from kernel
  // code to usertrap would be a disaster, turn off interrupts.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    80002a10:	04000737          	lui	a4,0x4000
    80002a14:	177d                	addi	a4,a4,-1 # 3ffffff <_entry-0x7c000001>
    80002a16:	0732                	slli	a4,a4,0xc
    80002a18:	00004797          	auipc	a5,0x4
    80002a1c:	5e878793          	addi	a5,a5,1512 # 80007000 <_trampoline>
    80002a20:	00004697          	auipc	a3,0x4
    80002a24:	5e068693          	addi	a3,a3,1504 # 80007000 <_trampoline>
    80002a28:	8f95                	sub	a5,a5,a3
    80002a2a:	97ba                	add	a5,a5,a4
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002a2c:	10579073          	csrw	stvec,a5
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    80002a30:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    80002a32:	18002773          	csrr	a4,satp
    80002a36:	e398                	sd	a4,0(a5)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    80002a38:	6d38                	ld	a4,88(a0)
    80002a3a:	613c                	ld	a5,64(a0)
    80002a3c:	6685                	lui	a3,0x1
    80002a3e:	97b6                	add	a5,a5,a3
    80002a40:	e71c                	sd	a5,8(a4)
  p->trapframe->kernel_trap = (uint64)usertrap;
    80002a42:	6d3c                	ld	a5,88(a0)
    80002a44:	00000717          	auipc	a4,0x0
    80002a48:	0fc70713          	addi	a4,a4,252 # 80002b40 <usertrap>
    80002a4c:	eb98                	sd	a4,16(a5)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    80002a4e:	6d3c                	ld	a5,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    80002a50:	8712                	mv	a4,tp
    80002a52:	f398                	sd	a4,32(a5)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002a54:	100027f3          	csrr	a5,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    80002a58:	eff7f793          	andi	a5,a5,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    80002a5c:	0207e793          	ori	a5,a5,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002a60:	10079073          	csrw	sstatus,a5
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    80002a64:	6d3c                	ld	a5,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002a66:	6f9c                	ld	a5,24(a5)
    80002a68:	14179073          	csrw	sepc,a5
}
    80002a6c:	60a2                	ld	ra,8(sp)
    80002a6e:	6402                	ld	s0,0(sp)
    80002a70:	0141                	addi	sp,sp,16
    80002a72:	8082                	ret

0000000080002a74 <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    80002a74:	1141                	addi	sp,sp,-16
    80002a76:	e406                	sd	ra,8(sp)
    80002a78:	e022                	sd	s0,0(sp)
    80002a7a:	0800                	addi	s0,sp,16
  if(cpuid() == 0){
    80002a7c:	9e2ff0ef          	jal	80001c5e <cpuid>
    80002a80:	cd11                	beqz	a0,80002a9c <clockintr+0x28>
  asm volatile("csrr %0, time" : "=r" (x) );
    80002a82:	c01027f3          	rdtime	a5
  }

  // ask for the next timer interrupt. this also clears
  // the interrupt request. 1000000 is about a tenth
  // of a second.
  w_stimecmp(r_time() + 1000000);
    80002a86:	000f4737          	lui	a4,0xf4
    80002a8a:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    80002a8e:	97ba                	add	a5,a5,a4
  asm volatile("csrw 0x14d, %0" : : "r" (x));
    80002a90:	14d79073          	csrw	stimecmp,a5
}
    80002a94:	60a2                	ld	ra,8(sp)
    80002a96:	6402                	ld	s0,0(sp)
    80002a98:	0141                	addi	sp,sp,16
    80002a9a:	8082                	ret
    acquire(&tickslock);
    80002a9c:	00015517          	auipc	a0,0x15
    80002aa0:	4d450513          	addi	a0,a0,1236 # 80017f70 <tickslock>
    80002aa4:	a7efe0ef          	jal	80000d22 <acquire>
    ticks++;
    80002aa8:	00006717          	auipc	a4,0x6
    80002aac:	58870713          	addi	a4,a4,1416 # 80009030 <ticks>
    80002ab0:	431c                	lw	a5,0(a4)
    80002ab2:	2785                	addiw	a5,a5,1
    80002ab4:	c31c                	sw	a5,0(a4)
    wakeup(&ticks);
    80002ab6:	853a                	mv	a0,a4
    80002ab8:	a53ff0ef          	jal	8000250a <wakeup>
    release(&tickslock);
    80002abc:	00015517          	auipc	a0,0x15
    80002ac0:	4b450513          	addi	a0,a0,1204 # 80017f70 <tickslock>
    80002ac4:	af2fe0ef          	jal	80000db6 <release>
    80002ac8:	bf6d                	j	80002a82 <clockintr+0xe>

0000000080002aca <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    80002aca:	1101                	addi	sp,sp,-32
    80002acc:	ec06                	sd	ra,24(sp)
    80002ace:	e822                	sd	s0,16(sp)
    80002ad0:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002ad2:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if(scause == 0x8000000000000009L){
    80002ad6:	57fd                	li	a5,-1
    80002ad8:	17fe                	slli	a5,a5,0x3f
    80002ada:	07a5                	addi	a5,a5,9
    80002adc:	00f70c63          	beq	a4,a5,80002af4 <devintr+0x2a>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000005L){
    80002ae0:	57fd                	li	a5,-1
    80002ae2:	17fe                	slli	a5,a5,0x3f
    80002ae4:	0795                	addi	a5,a5,5
    // timer interrupt.
    clockintr();
    return 2;
  } else {
    return 0;
    80002ae6:	4501                	li	a0,0
  } else if(scause == 0x8000000000000005L){
    80002ae8:	04f70863          	beq	a4,a5,80002b38 <devintr+0x6e>
  }
}
    80002aec:	60e2                	ld	ra,24(sp)
    80002aee:	6442                	ld	s0,16(sp)
    80002af0:	6105                	addi	sp,sp,32
    80002af2:	8082                	ret
    80002af4:	e426                	sd	s1,8(sp)
    int irq = plic_claim();
    80002af6:	046030ef          	jal	80005b3c <plic_claim>
    80002afa:	872a                	mv	a4,a0
    80002afc:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    80002afe:	47a9                	li	a5,10
    80002b00:	00f50963          	beq	a0,a5,80002b12 <devintr+0x48>
    } else if(irq == VIRTIO0_IRQ){
    80002b04:	4785                	li	a5,1
    80002b06:	00f50963          	beq	a0,a5,80002b18 <devintr+0x4e>
    return 1;
    80002b0a:	4505                	li	a0,1
    } else if(irq){
    80002b0c:	eb09                	bnez	a4,80002b1e <devintr+0x54>
    80002b0e:	64a2                	ld	s1,8(sp)
    80002b10:	bff1                	j	80002aec <devintr+0x22>
      uartintr();
    80002b12:	f15fd0ef          	jal	80000a26 <uartintr>
    if(irq)
    80002b16:	a819                	j	80002b2c <devintr+0x62>
      virtio_disk_intr();
    80002b18:	4ba030ef          	jal	80005fd2 <virtio_disk_intr>
    if(irq)
    80002b1c:	a801                	j	80002b2c <devintr+0x62>
      printf("unexpected interrupt irq=%d\n", irq);
    80002b1e:	85ba                	mv	a1,a4
    80002b20:	00006517          	auipc	a0,0x6
    80002b24:	83850513          	addi	a0,a0,-1992 # 80008358 <userret+0x12bc>
    80002b28:	a05fd0ef          	jal	8000052c <printf>
      plic_complete(irq);
    80002b2c:	8526                	mv	a0,s1
    80002b2e:	02e030ef          	jal	80005b5c <plic_complete>
    return 1;
    80002b32:	4505                	li	a0,1
    80002b34:	64a2                	ld	s1,8(sp)
    80002b36:	bf5d                	j	80002aec <devintr+0x22>
    clockintr();
    80002b38:	f3dff0ef          	jal	80002a74 <clockintr>
    return 2;
    80002b3c:	4509                	li	a0,2
    80002b3e:	b77d                	j	80002aec <devintr+0x22>

0000000080002b40 <usertrap>:
{
    80002b40:	1101                	addi	sp,sp,-32
    80002b42:	ec06                	sd	ra,24(sp)
    80002b44:	e822                	sd	s0,16(sp)
    80002b46:	e426                	sd	s1,8(sp)
    80002b48:	e04a                	sd	s2,0(sp)
    80002b4a:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002b4c:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    80002b50:	1007f793          	andi	a5,a5,256
    80002b54:	eba5                	bnez	a5,80002bc4 <usertrap+0x84>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002b56:	00003797          	auipc	a5,0x3
    80002b5a:	f3a78793          	addi	a5,a5,-198 # 80005a90 <kernelvec>
    80002b5e:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80002b62:	930ff0ef          	jal	80001c92 <myproc>
    80002b66:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    80002b68:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002b6a:	14102773          	csrr	a4,sepc
    80002b6e:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002b70:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    80002b74:	47a1                	li	a5,8
    80002b76:	04f70d63          	beq	a4,a5,80002bd0 <usertrap+0x90>
  } else if((which_dev = devintr()) != 0){
    80002b7a:	f51ff0ef          	jal	80002aca <devintr>
    80002b7e:	892a                	mv	s2,a0
    80002b80:	e945                	bnez	a0,80002c30 <usertrap+0xf0>
    80002b82:	14202773          	csrr	a4,scause
  } else if((r_scause() == 15 || r_scause() == 13) &&
    80002b86:	47bd                	li	a5,15
    80002b88:	08f70863          	beq	a4,a5,80002c18 <usertrap+0xd8>
    80002b8c:	14202773          	csrr	a4,scause
    80002b90:	47b5                	li	a5,13
    80002b92:	08f70363          	beq	a4,a5,80002c18 <usertrap+0xd8>
    80002b96:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause 0x%lx pid=%d\n", r_scause(), p->pid);
    80002b9a:	5890                	lw	a2,48(s1)
    80002b9c:	00005517          	auipc	a0,0x5
    80002ba0:	7fc50513          	addi	a0,a0,2044 # 80008398 <userret+0x12fc>
    80002ba4:	989fd0ef          	jal	8000052c <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002ba8:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002bac:	14302673          	csrr	a2,stval
    printf("            sepc=0x%lx stval=0x%lx\n", r_sepc(), r_stval());
    80002bb0:	00006517          	auipc	a0,0x6
    80002bb4:	81850513          	addi	a0,a0,-2024 # 800083c8 <userret+0x132c>
    80002bb8:	975fd0ef          	jal	8000052c <printf>
    setkilled(p);
    80002bbc:	8526                	mv	a0,s1
    80002bbe:	b19ff0ef          	jal	800026d6 <setkilled>
    80002bc2:	a035                	j	80002bee <usertrap+0xae>
    panic("usertrap: not from user mode");
    80002bc4:	00005517          	auipc	a0,0x5
    80002bc8:	7b450513          	addi	a0,a0,1972 # 80008378 <userret+0x12dc>
    80002bcc:	c8bfd0ef          	jal	80000856 <panic>
    if(killed(p))
    80002bd0:	b2bff0ef          	jal	800026fa <killed>
    80002bd4:	ed15                	bnez	a0,80002c10 <usertrap+0xd0>
    p->trapframe->epc += 4;
    80002bd6:	6cb8                	ld	a4,88(s1)
    80002bd8:	6f1c                	ld	a5,24(a4)
    80002bda:	0791                	addi	a5,a5,4
    80002bdc:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002bde:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002be2:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002be6:	10079073          	csrw	sstatus,a5
    syscall();
    80002bea:	240000ef          	jal	80002e2a <syscall>
  if(killed(p))
    80002bee:	8526                	mv	a0,s1
    80002bf0:	b0bff0ef          	jal	800026fa <killed>
    80002bf4:	e139                	bnez	a0,80002c3a <usertrap+0xfa>
  prepare_return();
    80002bf6:	e05ff0ef          	jal	800029fa <prepare_return>
  uint64 satp = MAKE_SATP(p->pagetable);
    80002bfa:	68a8                	ld	a0,80(s1)
    80002bfc:	8131                	srli	a0,a0,0xc
    80002bfe:	57fd                	li	a5,-1
    80002c00:	17fe                	slli	a5,a5,0x3f
    80002c02:	8d5d                	or	a0,a0,a5
}
    80002c04:	60e2                	ld	ra,24(sp)
    80002c06:	6442                	ld	s0,16(sp)
    80002c08:	64a2                	ld	s1,8(sp)
    80002c0a:	6902                	ld	s2,0(sp)
    80002c0c:	6105                	addi	sp,sp,32
    80002c0e:	8082                	ret
      kexit(-1);
    80002c10:	557d                	li	a0,-1
    80002c12:	9b9ff0ef          	jal	800025ca <kexit>
    80002c16:	b7c1                	j	80002bd6 <usertrap+0x96>
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002c18:	143025f3          	csrr	a1,stval
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002c1c:	14202673          	csrr	a2,scause
            vmfault(p->pagetable, r_stval(), (r_scause() == 13)? 1 : 0) != 0) {
    80002c20:	164d                	addi	a2,a2,-13 # ff3 <_entry-0x7ffff00d>
    80002c22:	00163613          	seqz	a2,a2
    80002c26:	68a8                	ld	a0,80(s1)
    80002c28:	ca5fe0ef          	jal	800018cc <vmfault>
  } else if((r_scause() == 15 || r_scause() == 13) &&
    80002c2c:	f169                	bnez	a0,80002bee <usertrap+0xae>
    80002c2e:	b7a5                	j	80002b96 <usertrap+0x56>
  if(killed(p))
    80002c30:	8526                	mv	a0,s1
    80002c32:	ac9ff0ef          	jal	800026fa <killed>
    80002c36:	c511                	beqz	a0,80002c42 <usertrap+0x102>
    80002c38:	a011                	j	80002c3c <usertrap+0xfc>
    80002c3a:	4901                	li	s2,0
    kexit(-1);
    80002c3c:	557d                	li	a0,-1
    80002c3e:	98dff0ef          	jal	800025ca <kexit>
  if(which_dev == 2)
    80002c42:	4789                	li	a5,2
    80002c44:	faf919e3          	bne	s2,a5,80002bf6 <usertrap+0xb6>
    yield();
    80002c48:	84bff0ef          	jal	80002492 <yield>
    80002c4c:	b76d                	j	80002bf6 <usertrap+0xb6>

0000000080002c4e <kerneltrap>:
{
    80002c4e:	7179                	addi	sp,sp,-48
    80002c50:	f406                	sd	ra,40(sp)
    80002c52:	f022                	sd	s0,32(sp)
    80002c54:	ec26                	sd	s1,24(sp)
    80002c56:	e84a                	sd	s2,16(sp)
    80002c58:	e44e                	sd	s3,8(sp)
    80002c5a:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002c5c:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002c60:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002c64:	142027f3          	csrr	a5,scause
    80002c68:	89be                	mv	s3,a5
  if((sstatus & SSTATUS_SPP) == 0)
    80002c6a:	1004f793          	andi	a5,s1,256
    80002c6e:	c795                	beqz	a5,80002c9a <kerneltrap+0x4c>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002c70:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002c74:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    80002c76:	eb85                	bnez	a5,80002ca6 <kerneltrap+0x58>
  if((which_dev = devintr()) == 0){
    80002c78:	e53ff0ef          	jal	80002aca <devintr>
    80002c7c:	c91d                	beqz	a0,80002cb2 <kerneltrap+0x64>
  if(which_dev == 2 && myproc() != 0)
    80002c7e:	4789                	li	a5,2
    80002c80:	04f50a63          	beq	a0,a5,80002cd4 <kerneltrap+0x86>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002c84:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002c88:	10049073          	csrw	sstatus,s1
}
    80002c8c:	70a2                	ld	ra,40(sp)
    80002c8e:	7402                	ld	s0,32(sp)
    80002c90:	64e2                	ld	s1,24(sp)
    80002c92:	6942                	ld	s2,16(sp)
    80002c94:	69a2                	ld	s3,8(sp)
    80002c96:	6145                	addi	sp,sp,48
    80002c98:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80002c9a:	00005517          	auipc	a0,0x5
    80002c9e:	75650513          	addi	a0,a0,1878 # 800083f0 <userret+0x1354>
    80002ca2:	bb5fd0ef          	jal	80000856 <panic>
    panic("kerneltrap: interrupts enabled");
    80002ca6:	00005517          	auipc	a0,0x5
    80002caa:	77250513          	addi	a0,a0,1906 # 80008418 <userret+0x137c>
    80002cae:	ba9fd0ef          	jal	80000856 <panic>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002cb2:	14102673          	csrr	a2,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002cb6:	143026f3          	csrr	a3,stval
    printf("scause=0x%lx sepc=0x%lx stval=0x%lx\n", scause, r_sepc(), r_stval());
    80002cba:	85ce                	mv	a1,s3
    80002cbc:	00005517          	auipc	a0,0x5
    80002cc0:	77c50513          	addi	a0,a0,1916 # 80008438 <userret+0x139c>
    80002cc4:	869fd0ef          	jal	8000052c <printf>
    panic("kerneltrap");
    80002cc8:	00005517          	auipc	a0,0x5
    80002ccc:	79850513          	addi	a0,a0,1944 # 80008460 <userret+0x13c4>
    80002cd0:	b87fd0ef          	jal	80000856 <panic>
  if(which_dev == 2 && myproc() != 0)
    80002cd4:	fbffe0ef          	jal	80001c92 <myproc>
    80002cd8:	d555                	beqz	a0,80002c84 <kerneltrap+0x36>
    yield();
    80002cda:	fb8ff0ef          	jal	80002492 <yield>
    80002cde:	b75d                	j	80002c84 <kerneltrap+0x36>

0000000080002ce0 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80002ce0:	1101                	addi	sp,sp,-32
    80002ce2:	ec06                	sd	ra,24(sp)
    80002ce4:	e822                	sd	s0,16(sp)
    80002ce6:	e426                	sd	s1,8(sp)
    80002ce8:	1000                	addi	s0,sp,32
    80002cea:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002cec:	fa7fe0ef          	jal	80001c92 <myproc>
  switch (n) {
    80002cf0:	4795                	li	a5,5
    80002cf2:	0497e163          	bltu	a5,s1,80002d34 <argraw+0x54>
    80002cf6:	048a                	slli	s1,s1,0x2
    80002cf8:	00006717          	auipc	a4,0x6
    80002cfc:	bb070713          	addi	a4,a4,-1104 # 800088a8 <states.0+0x30>
    80002d00:	94ba                	add	s1,s1,a4
    80002d02:	409c                	lw	a5,0(s1)
    80002d04:	97ba                	add	a5,a5,a4
    80002d06:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    80002d08:	6d3c                	ld	a5,88(a0)
    80002d0a:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80002d0c:	60e2                	ld	ra,24(sp)
    80002d0e:	6442                	ld	s0,16(sp)
    80002d10:	64a2                	ld	s1,8(sp)
    80002d12:	6105                	addi	sp,sp,32
    80002d14:	8082                	ret
    return p->trapframe->a1;
    80002d16:	6d3c                	ld	a5,88(a0)
    80002d18:	7fa8                	ld	a0,120(a5)
    80002d1a:	bfcd                	j	80002d0c <argraw+0x2c>
    return p->trapframe->a2;
    80002d1c:	6d3c                	ld	a5,88(a0)
    80002d1e:	63c8                	ld	a0,128(a5)
    80002d20:	b7f5                	j	80002d0c <argraw+0x2c>
    return p->trapframe->a3;
    80002d22:	6d3c                	ld	a5,88(a0)
    80002d24:	67c8                	ld	a0,136(a5)
    80002d26:	b7dd                	j	80002d0c <argraw+0x2c>
    return p->trapframe->a4;
    80002d28:	6d3c                	ld	a5,88(a0)
    80002d2a:	6bc8                	ld	a0,144(a5)
    80002d2c:	b7c5                	j	80002d0c <argraw+0x2c>
    return p->trapframe->a5;
    80002d2e:	6d3c                	ld	a5,88(a0)
    80002d30:	6fc8                	ld	a0,152(a5)
    80002d32:	bfe9                	j	80002d0c <argraw+0x2c>
  panic("argraw");
    80002d34:	00005517          	auipc	a0,0x5
    80002d38:	73c50513          	addi	a0,a0,1852 # 80008470 <userret+0x13d4>
    80002d3c:	b1bfd0ef          	jal	80000856 <panic>

0000000080002d40 <fetchaddr>:
{
    80002d40:	1101                	addi	sp,sp,-32
    80002d42:	ec06                	sd	ra,24(sp)
    80002d44:	e822                	sd	s0,16(sp)
    80002d46:	e426                	sd	s1,8(sp)
    80002d48:	e04a                	sd	s2,0(sp)
    80002d4a:	1000                	addi	s0,sp,32
    80002d4c:	84aa                	mv	s1,a0
    80002d4e:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002d50:	f43fe0ef          	jal	80001c92 <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    80002d54:	653c                	ld	a5,72(a0)
    80002d56:	02f4f663          	bgeu	s1,a5,80002d82 <fetchaddr+0x42>
    80002d5a:	00848713          	addi	a4,s1,8
    80002d5e:	02e7e463          	bltu	a5,a4,80002d86 <fetchaddr+0x46>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80002d62:	46a1                	li	a3,8
    80002d64:	8626                	mv	a2,s1
    80002d66:	85ca                	mv	a1,s2
    80002d68:	6928                	ld	a0,80(a0)
    80002d6a:	cf9fe0ef          	jal	80001a62 <copyin>
    80002d6e:	00a03533          	snez	a0,a0
    80002d72:	40a0053b          	negw	a0,a0
}
    80002d76:	60e2                	ld	ra,24(sp)
    80002d78:	6442                	ld	s0,16(sp)
    80002d7a:	64a2                	ld	s1,8(sp)
    80002d7c:	6902                	ld	s2,0(sp)
    80002d7e:	6105                	addi	sp,sp,32
    80002d80:	8082                	ret
    return -1;
    80002d82:	557d                	li	a0,-1
    80002d84:	bfcd                	j	80002d76 <fetchaddr+0x36>
    80002d86:	557d                	li	a0,-1
    80002d88:	b7fd                	j	80002d76 <fetchaddr+0x36>

0000000080002d8a <fetchstr>:
{
    80002d8a:	7179                	addi	sp,sp,-48
    80002d8c:	f406                	sd	ra,40(sp)
    80002d8e:	f022                	sd	s0,32(sp)
    80002d90:	ec26                	sd	s1,24(sp)
    80002d92:	e84a                	sd	s2,16(sp)
    80002d94:	e44e                	sd	s3,8(sp)
    80002d96:	1800                	addi	s0,sp,48
    80002d98:	89aa                	mv	s3,a0
    80002d9a:	84ae                	mv	s1,a1
    80002d9c:	8932                	mv	s2,a2
  struct proc *p = myproc();
    80002d9e:	ef5fe0ef          	jal	80001c92 <myproc>
  if(copyinstr(p->pagetable, buf, addr, max) < 0)
    80002da2:	86ca                	mv	a3,s2
    80002da4:	864e                	mv	a2,s3
    80002da6:	85a6                	mv	a1,s1
    80002da8:	6928                	ld	a0,80(a0)
    80002daa:	a4bfe0ef          	jal	800017f4 <copyinstr>
    80002dae:	00054c63          	bltz	a0,80002dc6 <fetchstr+0x3c>
  return strlen(buf);
    80002db2:	8526                	mv	a0,s1
    80002db4:	9c8fe0ef          	jal	80000f7c <strlen>
}
    80002db8:	70a2                	ld	ra,40(sp)
    80002dba:	7402                	ld	s0,32(sp)
    80002dbc:	64e2                	ld	s1,24(sp)
    80002dbe:	6942                	ld	s2,16(sp)
    80002dc0:	69a2                	ld	s3,8(sp)
    80002dc2:	6145                	addi	sp,sp,48
    80002dc4:	8082                	ret
    return -1;
    80002dc6:	557d                	li	a0,-1
    80002dc8:	bfc5                	j	80002db8 <fetchstr+0x2e>

0000000080002dca <argint>:

// Fetch the nth 32-bit system call argument.
void
argint(int n, int *ip)
{
    80002dca:	1101                	addi	sp,sp,-32
    80002dcc:	ec06                	sd	ra,24(sp)
    80002dce:	e822                	sd	s0,16(sp)
    80002dd0:	e426                	sd	s1,8(sp)
    80002dd2:	1000                	addi	s0,sp,32
    80002dd4:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002dd6:	f0bff0ef          	jal	80002ce0 <argraw>
    80002dda:	c088                	sw	a0,0(s1)
}
    80002ddc:	60e2                	ld	ra,24(sp)
    80002dde:	6442                	ld	s0,16(sp)
    80002de0:	64a2                	ld	s1,8(sp)
    80002de2:	6105                	addi	sp,sp,32
    80002de4:	8082                	ret

0000000080002de6 <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void
argaddr(int n, uint64 *ip)
{
    80002de6:	1101                	addi	sp,sp,-32
    80002de8:	ec06                	sd	ra,24(sp)
    80002dea:	e822                	sd	s0,16(sp)
    80002dec:	e426                	sd	s1,8(sp)
    80002dee:	1000                	addi	s0,sp,32
    80002df0:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002df2:	eefff0ef          	jal	80002ce0 <argraw>
    80002df6:	e088                	sd	a0,0(s1)
}
    80002df8:	60e2                	ld	ra,24(sp)
    80002dfa:	6442                	ld	s0,16(sp)
    80002dfc:	64a2                	ld	s1,8(sp)
    80002dfe:	6105                	addi	sp,sp,32
    80002e00:	8082                	ret

0000000080002e02 <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80002e02:	1101                	addi	sp,sp,-32
    80002e04:	ec06                	sd	ra,24(sp)
    80002e06:	e822                	sd	s0,16(sp)
    80002e08:	e426                	sd	s1,8(sp)
    80002e0a:	e04a                	sd	s2,0(sp)
    80002e0c:	1000                	addi	s0,sp,32
    80002e0e:	892e                	mv	s2,a1
    80002e10:	84b2                	mv	s1,a2
  *ip = argraw(n);
    80002e12:	ecfff0ef          	jal	80002ce0 <argraw>
  uint64 addr;
  argaddr(n, &addr);
  return fetchstr(addr, buf, max);
    80002e16:	8626                	mv	a2,s1
    80002e18:	85ca                	mv	a1,s2
    80002e1a:	f71ff0ef          	jal	80002d8a <fetchstr>
}
    80002e1e:	60e2                	ld	ra,24(sp)
    80002e20:	6442                	ld	s0,16(sp)
    80002e22:	64a2                	ld	s1,8(sp)
    80002e24:	6902                	ld	s2,0(sp)
    80002e26:	6105                	addi	sp,sp,32
    80002e28:	8082                	ret

0000000080002e2a <syscall>:

};

void
syscall(void)
{
    80002e2a:	1101                	addi	sp,sp,-32
    80002e2c:	ec06                	sd	ra,24(sp)
    80002e2e:	e822                	sd	s0,16(sp)
    80002e30:	e426                	sd	s1,8(sp)
    80002e32:	e04a                	sd	s2,0(sp)
    80002e34:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    80002e36:	e5dfe0ef          	jal	80001c92 <myproc>
    80002e3a:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    80002e3c:	05853903          	ld	s2,88(a0)
    80002e40:	0a893783          	ld	a5,168(s2)
    80002e44:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80002e48:	37fd                	addiw	a5,a5,-1
    80002e4a:	4761                	li	a4,24
    80002e4c:	00f76f63          	bltu	a4,a5,80002e6a <syscall+0x40>
    80002e50:	00369713          	slli	a4,a3,0x3
    80002e54:	00006797          	auipc	a5,0x6
    80002e58:	a6c78793          	addi	a5,a5,-1428 # 800088c0 <syscalls>
    80002e5c:	97ba                	add	a5,a5,a4
    80002e5e:	639c                	ld	a5,0(a5)
    80002e60:	c789                	beqz	a5,80002e6a <syscall+0x40>
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    p->trapframe->a0 = syscalls[num]();
    80002e62:	9782                	jalr	a5
    80002e64:	06a93823          	sd	a0,112(s2)
    80002e68:	a829                	j	80002e82 <syscall+0x58>
  } else {
    printf("%d %s: unknown sys call %d\n",
    80002e6a:	15848613          	addi	a2,s1,344
    80002e6e:	588c                	lw	a1,48(s1)
    80002e70:	00005517          	auipc	a0,0x5
    80002e74:	60850513          	addi	a0,a0,1544 # 80008478 <userret+0x13dc>
    80002e78:	eb4fd0ef          	jal	8000052c <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80002e7c:	6cbc                	ld	a5,88(s1)
    80002e7e:	577d                	li	a4,-1
    80002e80:	fbb8                	sd	a4,112(a5)
  }
}
    80002e82:	60e2                	ld	ra,24(sp)
    80002e84:	6442                	ld	s0,16(sp)
    80002e86:	64a2                	ld	s1,8(sp)
    80002e88:	6902                	ld	s2,0(sp)
    80002e8a:	6105                	addi	sp,sp,32
    80002e8c:	8082                	ret

0000000080002e8e <sys_exit>:
#include "vm.h"
#include "schedlog.h"

uint64
sys_exit(void)
{
    80002e8e:	1101                	addi	sp,sp,-32
    80002e90:	ec06                	sd	ra,24(sp)
    80002e92:	e822                	sd	s0,16(sp)
    80002e94:	1000                	addi	s0,sp,32
  int n;
  argint(0, &n);
    80002e96:	fec40593          	addi	a1,s0,-20
    80002e9a:	4501                	li	a0,0
    80002e9c:	f2fff0ef          	jal	80002dca <argint>
  kexit(n);
    80002ea0:	fec42503          	lw	a0,-20(s0)
    80002ea4:	f26ff0ef          	jal	800025ca <kexit>
  return 0;  // not reached
}
    80002ea8:	4501                	li	a0,0
    80002eaa:	60e2                	ld	ra,24(sp)
    80002eac:	6442                	ld	s0,16(sp)
    80002eae:	6105                	addi	sp,sp,32
    80002eb0:	8082                	ret

0000000080002eb2 <sys_getpid>:

uint64
sys_getpid(void)
{
    80002eb2:	1141                	addi	sp,sp,-16
    80002eb4:	e406                	sd	ra,8(sp)
    80002eb6:	e022                	sd	s0,0(sp)
    80002eb8:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80002eba:	dd9fe0ef          	jal	80001c92 <myproc>
}
    80002ebe:	5908                	lw	a0,48(a0)
    80002ec0:	60a2                	ld	ra,8(sp)
    80002ec2:	6402                	ld	s0,0(sp)
    80002ec4:	0141                	addi	sp,sp,16
    80002ec6:	8082                	ret

0000000080002ec8 <sys_fork>:

uint64
sys_fork(void)
{
    80002ec8:	1141                	addi	sp,sp,-16
    80002eca:	e406                	sd	ra,8(sp)
    80002ecc:	e022                	sd	s0,0(sp)
    80002ece:	0800                	addi	s0,sp,16
  return kfork();
    80002ed0:	996ff0ef          	jal	80002066 <kfork>
}
    80002ed4:	60a2                	ld	ra,8(sp)
    80002ed6:	6402                	ld	s0,0(sp)
    80002ed8:	0141                	addi	sp,sp,16
    80002eda:	8082                	ret

0000000080002edc <sys_wait>:

uint64
sys_wait(void)
{
    80002edc:	1101                	addi	sp,sp,-32
    80002ede:	ec06                	sd	ra,24(sp)
    80002ee0:	e822                	sd	s0,16(sp)
    80002ee2:	1000                	addi	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    80002ee4:	fe840593          	addi	a1,s0,-24
    80002ee8:	4501                	li	a0,0
    80002eea:	efdff0ef          	jal	80002de6 <argaddr>
  return kwait(p);
    80002eee:	fe843503          	ld	a0,-24(s0)
    80002ef2:	833ff0ef          	jal	80002724 <kwait>
}
    80002ef6:	60e2                	ld	ra,24(sp)
    80002ef8:	6442                	ld	s0,16(sp)
    80002efa:	6105                	addi	sp,sp,32
    80002efc:	8082                	ret

0000000080002efe <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80002efe:	7179                	addi	sp,sp,-48
    80002f00:	f406                	sd	ra,40(sp)
    80002f02:	f022                	sd	s0,32(sp)
    80002f04:	ec26                	sd	s1,24(sp)
    80002f06:	1800                	addi	s0,sp,48
  uint64 addr;
  int t;
  int n;

  argint(0, &n);
    80002f08:	fd840593          	addi	a1,s0,-40
    80002f0c:	4501                	li	a0,0
    80002f0e:	ebdff0ef          	jal	80002dca <argint>
  argint(1, &t);
    80002f12:	fdc40593          	addi	a1,s0,-36
    80002f16:	4505                	li	a0,1
    80002f18:	eb3ff0ef          	jal	80002dca <argint>
  addr = myproc()->sz;
    80002f1c:	d77fe0ef          	jal	80001c92 <myproc>
    80002f20:	6524                	ld	s1,72(a0)

  if(t == SBRK_EAGER || n < 0) {
    80002f22:	fdc42703          	lw	a4,-36(s0)
    80002f26:	4785                	li	a5,1
    80002f28:	02f70763          	beq	a4,a5,80002f56 <sys_sbrk+0x58>
    80002f2c:	fd842783          	lw	a5,-40(s0)
    80002f30:	0207c363          	bltz	a5,80002f56 <sys_sbrk+0x58>
    }
  } else {
    // Lazily allocate memory for this process: increase its memory
    // size but don't allocate memory. If the processes uses the
    // memory, vmfault() will allocate it.
    if(addr + n < addr)
    80002f34:	97a6                	add	a5,a5,s1
      return -1;
    if(addr + n > TRAPFRAME)
    80002f36:	02000737          	lui	a4,0x2000
    80002f3a:	177d                	addi	a4,a4,-1 # 1ffffff <_entry-0x7e000001>
    80002f3c:	0736                	slli	a4,a4,0xd
    80002f3e:	02f76a63          	bltu	a4,a5,80002f72 <sys_sbrk+0x74>
    80002f42:	0297e863          	bltu	a5,s1,80002f72 <sys_sbrk+0x74>
      return -1;
    myproc()->sz += n;
    80002f46:	d4dfe0ef          	jal	80001c92 <myproc>
    80002f4a:	fd842703          	lw	a4,-40(s0)
    80002f4e:	653c                	ld	a5,72(a0)
    80002f50:	97ba                	add	a5,a5,a4
    80002f52:	e53c                	sd	a5,72(a0)
    80002f54:	a039                	j	80002f62 <sys_sbrk+0x64>
    if(growproc(n) < 0) {
    80002f56:	fd842503          	lw	a0,-40(s0)
    80002f5a:	83eff0ef          	jal	80001f98 <growproc>
    80002f5e:	00054863          	bltz	a0,80002f6e <sys_sbrk+0x70>
  }
  return addr;
}
    80002f62:	8526                	mv	a0,s1
    80002f64:	70a2                	ld	ra,40(sp)
    80002f66:	7402                	ld	s0,32(sp)
    80002f68:	64e2                	ld	s1,24(sp)
    80002f6a:	6145                	addi	sp,sp,48
    80002f6c:	8082                	ret
      return -1;
    80002f6e:	54fd                	li	s1,-1
    80002f70:	bfcd                	j	80002f62 <sys_sbrk+0x64>
      return -1;
    80002f72:	54fd                	li	s1,-1
    80002f74:	b7fd                	j	80002f62 <sys_sbrk+0x64>

0000000080002f76 <sys_pause>:

uint64
sys_pause(void)
{
    80002f76:	7139                	addi	sp,sp,-64
    80002f78:	fc06                	sd	ra,56(sp)
    80002f7a:	f822                	sd	s0,48(sp)
    80002f7c:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    80002f7e:	fcc40593          	addi	a1,s0,-52
    80002f82:	4501                	li	a0,0
    80002f84:	e47ff0ef          	jal	80002dca <argint>
  if(n < 0)
    80002f88:	fcc42783          	lw	a5,-52(s0)
    80002f8c:	0607c863          	bltz	a5,80002ffc <sys_pause+0x86>
    n = 0;
  acquire(&tickslock);
    80002f90:	00015517          	auipc	a0,0x15
    80002f94:	fe050513          	addi	a0,a0,-32 # 80017f70 <tickslock>
    80002f98:	d8bfd0ef          	jal	80000d22 <acquire>
  ticks0 = ticks;
  while(ticks - ticks0 < n){
    80002f9c:	fcc42783          	lw	a5,-52(s0)
    80002fa0:	c3b9                	beqz	a5,80002fe6 <sys_pause+0x70>
    80002fa2:	f426                	sd	s1,40(sp)
    80002fa4:	f04a                	sd	s2,32(sp)
    80002fa6:	ec4e                	sd	s3,24(sp)
  ticks0 = ticks;
    80002fa8:	00006997          	auipc	s3,0x6
    80002fac:	0889a983          	lw	s3,136(s3) # 80009030 <ticks>
    if(killed(myproc())){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80002fb0:	00015917          	auipc	s2,0x15
    80002fb4:	fc090913          	addi	s2,s2,-64 # 80017f70 <tickslock>
    80002fb8:	00006497          	auipc	s1,0x6
    80002fbc:	07848493          	addi	s1,s1,120 # 80009030 <ticks>
    if(killed(myproc())){
    80002fc0:	cd3fe0ef          	jal	80001c92 <myproc>
    80002fc4:	f36ff0ef          	jal	800026fa <killed>
    80002fc8:	ed0d                	bnez	a0,80003002 <sys_pause+0x8c>
    sleep(&ticks, &tickslock);
    80002fca:	85ca                	mv	a1,s2
    80002fcc:	8526                	mv	a0,s1
    80002fce:	cf0ff0ef          	jal	800024be <sleep>
  while(ticks - ticks0 < n){
    80002fd2:	409c                	lw	a5,0(s1)
    80002fd4:	413787bb          	subw	a5,a5,s3
    80002fd8:	fcc42703          	lw	a4,-52(s0)
    80002fdc:	fee7e2e3          	bltu	a5,a4,80002fc0 <sys_pause+0x4a>
    80002fe0:	74a2                	ld	s1,40(sp)
    80002fe2:	7902                	ld	s2,32(sp)
    80002fe4:	69e2                	ld	s3,24(sp)
  }
  release(&tickslock);
    80002fe6:	00015517          	auipc	a0,0x15
    80002fea:	f8a50513          	addi	a0,a0,-118 # 80017f70 <tickslock>
    80002fee:	dc9fd0ef          	jal	80000db6 <release>
  return 0;
    80002ff2:	4501                	li	a0,0
}
    80002ff4:	70e2                	ld	ra,56(sp)
    80002ff6:	7442                	ld	s0,48(sp)
    80002ff8:	6121                	addi	sp,sp,64
    80002ffa:	8082                	ret
    n = 0;
    80002ffc:	fc042623          	sw	zero,-52(s0)
    80003000:	bf41                	j	80002f90 <sys_pause+0x1a>
      release(&tickslock);
    80003002:	00015517          	auipc	a0,0x15
    80003006:	f6e50513          	addi	a0,a0,-146 # 80017f70 <tickslock>
    8000300a:	dadfd0ef          	jal	80000db6 <release>
      return -1;
    8000300e:	557d                	li	a0,-1
    80003010:	74a2                	ld	s1,40(sp)
    80003012:	7902                	ld	s2,32(sp)
    80003014:	69e2                	ld	s3,24(sp)
    80003016:	bff9                	j	80002ff4 <sys_pause+0x7e>

0000000080003018 <sys_kill>:

uint64
sys_kill(void)
{
    80003018:	1101                	addi	sp,sp,-32
    8000301a:	ec06                	sd	ra,24(sp)
    8000301c:	e822                	sd	s0,16(sp)
    8000301e:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    80003020:	fec40593          	addi	a1,s0,-20
    80003024:	4501                	li	a0,0
    80003026:	da5ff0ef          	jal	80002dca <argint>
  return kkill(pid);
    8000302a:	fec42503          	lw	a0,-20(s0)
    8000302e:	e42ff0ef          	jal	80002670 <kkill>
}
    80003032:	60e2                	ld	ra,24(sp)
    80003034:	6442                	ld	s0,16(sp)
    80003036:	6105                	addi	sp,sp,32
    80003038:	8082                	ret

000000008000303a <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    8000303a:	1101                	addi	sp,sp,-32
    8000303c:	ec06                	sd	ra,24(sp)
    8000303e:	e822                	sd	s0,16(sp)
    80003040:	e426                	sd	s1,8(sp)
    80003042:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80003044:	00015517          	auipc	a0,0x15
    80003048:	f2c50513          	addi	a0,a0,-212 # 80017f70 <tickslock>
    8000304c:	cd7fd0ef          	jal	80000d22 <acquire>
  xticks = ticks;
    80003050:	00006797          	auipc	a5,0x6
    80003054:	fe07a783          	lw	a5,-32(a5) # 80009030 <ticks>
    80003058:	84be                	mv	s1,a5
  release(&tickslock);
    8000305a:	00015517          	auipc	a0,0x15
    8000305e:	f1650513          	addi	a0,a0,-234 # 80017f70 <tickslock>
    80003062:	d55fd0ef          	jal	80000db6 <release>
  return xticks;
}
    80003066:	02049513          	slli	a0,s1,0x20
    8000306a:	9101                	srli	a0,a0,0x20
    8000306c:	60e2                	ld	ra,24(sp)
    8000306e:	6442                	ld	s0,16(sp)
    80003070:	64a2                	ld	s1,8(sp)
    80003072:	6105                	addi	sp,sp,32
    80003074:	8082                	ret

0000000080003076 <sys_schedread>:

uint64
sys_schedread(void)
{
    80003076:	7131                	addi	sp,sp,-192
    80003078:	fd06                	sd	ra,184(sp)
    8000307a:	f922                	sd	s0,176(sp)
    8000307c:	f526                	sd	s1,168(sp)
    8000307e:	f14a                	sd	s2,160(sp)
    80003080:	0180                	addi	s0,sp,192
    80003082:	81010113          	addi	sp,sp,-2032
  uint64 dst;
  int max;

  argaddr(0, &dst);
    80003086:	fd840593          	addi	a1,s0,-40
    8000308a:	4501                	li	a0,0
    8000308c:	d5bff0ef          	jal	80002de6 <argaddr>
  argint(1, &max);
    80003090:	fd440593          	addi	a1,s0,-44
    80003094:	4505                	li	a0,1
    80003096:	d35ff0ef          	jal	80002dca <argint>

  if(max <= 0)
    8000309a:	fd442783          	lw	a5,-44(s0)
    return 0;
    8000309e:	4901                	li	s2,0
  if(max <= 0)
    800030a0:	04f05963          	blez	a5,800030f2 <sys_schedread+0x7c>

  struct sched_event buf[32];
  if(max > 32)
    800030a4:	02000713          	li	a4,32
    800030a8:	00f75463          	bge	a4,a5,800030b0 <sys_schedread+0x3a>
    max = 32;
    800030ac:	fce42a23          	sw	a4,-44(s0)

  int n = schedread(buf, max);
    800030b0:	fd442583          	lw	a1,-44(s0)
    800030b4:	80040513          	addi	a0,s0,-2048
    800030b8:	1501                	addi	a0,a0,-32
    800030ba:	f7050513          	addi	a0,a0,-144
    800030be:	730030ef          	jal	800067ee <schedread>
    800030c2:	84aa                	mv	s1,a0
  if(n < 0)
    return -1;
    800030c4:	57fd                	li	a5,-1
    800030c6:	893e                	mv	s2,a5
  if(n < 0)
    800030c8:	02054563          	bltz	a0,800030f2 <sys_schedread+0x7c>

  if(copyout(myproc()->pagetable, dst, (char *)buf, n * sizeof(struct sched_event)) < 0)
    800030cc:	bc7fe0ef          	jal	80001c92 <myproc>
    800030d0:	8926                	mv	s2,s1
    800030d2:	00449693          	slli	a3,s1,0x4
    800030d6:	96a6                	add	a3,a3,s1
    800030d8:	068a                	slli	a3,a3,0x2
    800030da:	80040613          	addi	a2,s0,-2048
    800030de:	1601                	addi	a2,a2,-32
    800030e0:	f7060613          	addi	a2,a2,-144
    800030e4:	fd843583          	ld	a1,-40(s0)
    800030e8:	6928                	ld	a0,80(a0)
    800030ea:	8bbfe0ef          	jal	800019a4 <copyout>
    800030ee:	00054b63          	bltz	a0,80003104 <sys_schedread+0x8e>
    return -1;

  return n;
}
    800030f2:	854a                	mv	a0,s2
    800030f4:	7f010113          	addi	sp,sp,2032
    800030f8:	70ea                	ld	ra,184(sp)
    800030fa:	744a                	ld	s0,176(sp)
    800030fc:	74aa                	ld	s1,168(sp)
    800030fe:	790a                	ld	s2,160(sp)
    80003100:	6129                	addi	sp,sp,192
    80003102:	8082                	ret
    return -1;
    80003104:	57fd                	li	a5,-1
    80003106:	893e                	mv	s2,a5
    80003108:	b7ed                	j	800030f2 <sys_schedread+0x7c>

000000008000310a <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    8000310a:	7179                	addi	sp,sp,-48
    8000310c:	f406                	sd	ra,40(sp)
    8000310e:	f022                	sd	s0,32(sp)
    80003110:	ec26                	sd	s1,24(sp)
    80003112:	e84a                	sd	s2,16(sp)
    80003114:	e44e                	sd	s3,8(sp)
    80003116:	e052                	sd	s4,0(sp)
    80003118:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    8000311a:	00005597          	auipc	a1,0x5
    8000311e:	37e58593          	addi	a1,a1,894 # 80008498 <userret+0x13fc>
    80003122:	00015517          	auipc	a0,0x15
    80003126:	e6650513          	addi	a0,a0,-410 # 80017f88 <bcache>
    8000312a:	b6ffd0ef          	jal	80000c98 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    8000312e:	0001d797          	auipc	a5,0x1d
    80003132:	e5a78793          	addi	a5,a5,-422 # 8001ff88 <bcache+0x8000>
    80003136:	0001d717          	auipc	a4,0x1d
    8000313a:	0ba70713          	addi	a4,a4,186 # 800201f0 <bcache+0x8268>
    8000313e:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80003142:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80003146:	00015497          	auipc	s1,0x15
    8000314a:	e5a48493          	addi	s1,s1,-422 # 80017fa0 <bcache+0x18>
    b->next = bcache.head.next;
    8000314e:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80003150:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80003152:	00005a17          	auipc	s4,0x5
    80003156:	34ea0a13          	addi	s4,s4,846 # 800084a0 <userret+0x1404>
    b->next = bcache.head.next;
    8000315a:	2b893783          	ld	a5,696(s2)
    8000315e:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80003160:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80003164:	85d2                	mv	a1,s4
    80003166:	01048513          	addi	a0,s1,16
    8000316a:	366010ef          	jal	800044d0 <initsleeplock>
    bcache.head.next->prev = b;
    8000316e:	2b893783          	ld	a5,696(s2)
    80003172:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80003174:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80003178:	45848493          	addi	s1,s1,1112
    8000317c:	fd349fe3          	bne	s1,s3,8000315a <binit+0x50>
  }
}
    80003180:	70a2                	ld	ra,40(sp)
    80003182:	7402                	ld	s0,32(sp)
    80003184:	64e2                	ld	s1,24(sp)
    80003186:	6942                	ld	s2,16(sp)
    80003188:	69a2                	ld	s3,8(sp)
    8000318a:	6a02                	ld	s4,0(sp)
    8000318c:	6145                	addi	sp,sp,48
    8000318e:	8082                	ret

0000000080003190 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    80003190:	7179                	addi	sp,sp,-48
    80003192:	f406                	sd	ra,40(sp)
    80003194:	f022                	sd	s0,32(sp)
    80003196:	ec26                	sd	s1,24(sp)
    80003198:	e84a                	sd	s2,16(sp)
    8000319a:	e44e                	sd	s3,8(sp)
    8000319c:	1800                	addi	s0,sp,48
    8000319e:	892a                	mv	s2,a0
    800031a0:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    800031a2:	00015517          	auipc	a0,0x15
    800031a6:	de650513          	addi	a0,a0,-538 # 80017f88 <bcache>
    800031aa:	b79fd0ef          	jal	80000d22 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    800031ae:	0001d497          	auipc	s1,0x1d
    800031b2:	0924b483          	ld	s1,146(s1) # 80020240 <bcache+0x82b8>
    800031b6:	0001d797          	auipc	a5,0x1d
    800031ba:	03a78793          	addi	a5,a5,58 # 800201f0 <bcache+0x8268>
    800031be:	04f48563          	beq	s1,a5,80003208 <bread+0x78>
    800031c2:	873e                	mv	a4,a5
    800031c4:	a021                	j	800031cc <bread+0x3c>
    800031c6:	68a4                	ld	s1,80(s1)
    800031c8:	04e48063          	beq	s1,a4,80003208 <bread+0x78>
    if(b->dev == dev && b->blockno == blockno){
    800031cc:	449c                	lw	a5,8(s1)
    800031ce:	ff279ce3          	bne	a5,s2,800031c6 <bread+0x36>
    800031d2:	44dc                	lw	a5,12(s1)
    800031d4:	ff3799e3          	bne	a5,s3,800031c6 <bread+0x36>
      b->refcnt++;
    800031d8:	40bc                	lw	a5,64(s1)
    800031da:	2785                	addiw	a5,a5,1
    800031dc:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    800031de:	00015517          	auipc	a0,0x15
    800031e2:	daa50513          	addi	a0,a0,-598 # 80017f88 <bcache>
    800031e6:	bd1fd0ef          	jal	80000db6 <release>
      acquiresleep(&b->lock);
    800031ea:	01048513          	addi	a0,s1,16
    800031ee:	318010ef          	jal	80004506 <acquiresleep>
      fslog_push(FS_BGET_HIT, 0, blockno, 0, "BCACHE");
    800031f2:	00005717          	auipc	a4,0x5
    800031f6:	2b670713          	addi	a4,a4,694 # 800084a8 <userret+0x140c>
    800031fa:	4681                	li	a3,0
    800031fc:	864e                	mv	a2,s3
    800031fe:	4581                	li	a1,0
    80003200:	4519                	li	a0,6
    80003202:	1de030ef          	jal	800063e0 <fslog_push>
      return b;
    80003206:	a09d                	j	8000326c <bread+0xdc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80003208:	0001d497          	auipc	s1,0x1d
    8000320c:	0304b483          	ld	s1,48(s1) # 80020238 <bcache+0x82b0>
    80003210:	0001d797          	auipc	a5,0x1d
    80003214:	fe078793          	addi	a5,a5,-32 # 800201f0 <bcache+0x8268>
    80003218:	00f48863          	beq	s1,a5,80003228 <bread+0x98>
    8000321c:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    8000321e:	40bc                	lw	a5,64(s1)
    80003220:	cb91                	beqz	a5,80003234 <bread+0xa4>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80003222:	64a4                	ld	s1,72(s1)
    80003224:	fee49de3          	bne	s1,a4,8000321e <bread+0x8e>
  panic("bget: no buffers");
    80003228:	00005517          	auipc	a0,0x5
    8000322c:	28850513          	addi	a0,a0,648 # 800084b0 <userret+0x1414>
    80003230:	e26fd0ef          	jal	80000856 <panic>
      b->dev = dev;
    80003234:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    80003238:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    8000323c:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80003240:	4785                	li	a5,1
    80003242:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80003244:	00015517          	auipc	a0,0x15
    80003248:	d4450513          	addi	a0,a0,-700 # 80017f88 <bcache>
    8000324c:	b6bfd0ef          	jal	80000db6 <release>
      acquiresleep(&b->lock);
    80003250:	01048513          	addi	a0,s1,16
    80003254:	2b2010ef          	jal	80004506 <acquiresleep>
      fslog_push(FS_BGET_MISS, 0, blockno, 0, "BCACHE");
    80003258:	00005717          	auipc	a4,0x5
    8000325c:	25070713          	addi	a4,a4,592 # 800084a8 <userret+0x140c>
    80003260:	4681                	li	a3,0
    80003262:	864e                	mv	a2,s3
    80003264:	4581                	li	a1,0
    80003266:	451d                	li	a0,7
    80003268:	178030ef          	jal	800063e0 <fslog_push>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    8000326c:	409c                	lw	a5,0(s1)
    8000326e:	cb89                	beqz	a5,80003280 <bread+0xf0>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80003270:	8526                	mv	a0,s1
    80003272:	70a2                	ld	ra,40(sp)
    80003274:	7402                	ld	s0,32(sp)
    80003276:	64e2                	ld	s1,24(sp)
    80003278:	6942                	ld	s2,16(sp)
    8000327a:	69a2                	ld	s3,8(sp)
    8000327c:	6145                	addi	sp,sp,48
    8000327e:	8082                	ret
    virtio_disk_rw(b, 0);
    80003280:	4581                	li	a1,0
    80003282:	8526                	mv	a0,s1
    80003284:	33d020ef          	jal	80005dc0 <virtio_disk_rw>
    b->valid = 1;
    80003288:	4785                	li	a5,1
    8000328a:	c09c                	sw	a5,0(s1)
  return b;
    8000328c:	b7d5                	j	80003270 <bread+0xe0>

000000008000328e <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    8000328e:	1101                	addi	sp,sp,-32
    80003290:	ec06                	sd	ra,24(sp)
    80003292:	e822                	sd	s0,16(sp)
    80003294:	e426                	sd	s1,8(sp)
    80003296:	1000                	addi	s0,sp,32
    80003298:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    8000329a:	0541                	addi	a0,a0,16
    8000329c:	2e8010ef          	jal	80004584 <holdingsleep>
    800032a0:	c911                	beqz	a0,800032b4 <bwrite+0x26>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    800032a2:	4585                	li	a1,1
    800032a4:	8526                	mv	a0,s1
    800032a6:	31b020ef          	jal	80005dc0 <virtio_disk_rw>
}
    800032aa:	60e2                	ld	ra,24(sp)
    800032ac:	6442                	ld	s0,16(sp)
    800032ae:	64a2                	ld	s1,8(sp)
    800032b0:	6105                	addi	sp,sp,32
    800032b2:	8082                	ret
    panic("bwrite");
    800032b4:	00005517          	auipc	a0,0x5
    800032b8:	21450513          	addi	a0,a0,532 # 800084c8 <userret+0x142c>
    800032bc:	d9afd0ef          	jal	80000856 <panic>

00000000800032c0 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    800032c0:	1101                	addi	sp,sp,-32
    800032c2:	ec06                	sd	ra,24(sp)
    800032c4:	e822                	sd	s0,16(sp)
    800032c6:	e426                	sd	s1,8(sp)
    800032c8:	e04a                	sd	s2,0(sp)
    800032ca:	1000                	addi	s0,sp,32
    800032cc:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    800032ce:	01050913          	addi	s2,a0,16
    800032d2:	854a                	mv	a0,s2
    800032d4:	2b0010ef          	jal	80004584 <holdingsleep>
    800032d8:	c915                	beqz	a0,8000330c <brelse+0x4c>
    panic("brelse");

  releasesleep(&b->lock);
    800032da:	854a                	mv	a0,s2
    800032dc:	270010ef          	jal	8000454c <releasesleep>

  acquire(&bcache.lock);
    800032e0:	00015517          	auipc	a0,0x15
    800032e4:	ca850513          	addi	a0,a0,-856 # 80017f88 <bcache>
    800032e8:	a3bfd0ef          	jal	80000d22 <acquire>
  b->refcnt--;
    800032ec:	40bc                	lw	a5,64(s1)
    800032ee:	37fd                	addiw	a5,a5,-1
    800032f0:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    800032f2:	c39d                	beqz	a5,80003318 <brelse+0x58>
    bcache.head.next->prev = b;
    bcache.head.next = b;
    fslog_push(FS_BRELEASE, 0, b->blockno, 0, "BCACHE");
  }
  
  release(&bcache.lock);
    800032f4:	00015517          	auipc	a0,0x15
    800032f8:	c9450513          	addi	a0,a0,-876 # 80017f88 <bcache>
    800032fc:	abbfd0ef          	jal	80000db6 <release>
}
    80003300:	60e2                	ld	ra,24(sp)
    80003302:	6442                	ld	s0,16(sp)
    80003304:	64a2                	ld	s1,8(sp)
    80003306:	6902                	ld	s2,0(sp)
    80003308:	6105                	addi	sp,sp,32
    8000330a:	8082                	ret
    panic("brelse");
    8000330c:	00005517          	auipc	a0,0x5
    80003310:	1c450513          	addi	a0,a0,452 # 800084d0 <userret+0x1434>
    80003314:	d42fd0ef          	jal	80000856 <panic>
    b->next->prev = b->prev;
    80003318:	68b8                	ld	a4,80(s1)
    8000331a:	64bc                	ld	a5,72(s1)
    8000331c:	e73c                	sd	a5,72(a4)
    b->prev->next = b->next;
    8000331e:	68b8                	ld	a4,80(s1)
    80003320:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    80003322:	0001d797          	auipc	a5,0x1d
    80003326:	c6678793          	addi	a5,a5,-922 # 8001ff88 <bcache+0x8000>
    8000332a:	2b87b703          	ld	a4,696(a5)
    8000332e:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    80003330:	0001d717          	auipc	a4,0x1d
    80003334:	ec070713          	addi	a4,a4,-320 # 800201f0 <bcache+0x8268>
    80003338:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    8000333a:	2b87b703          	ld	a4,696(a5)
    8000333e:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80003340:	2a97bc23          	sd	s1,696(a5)
    fslog_push(FS_BRELEASE, 0, b->blockno, 0, "BCACHE");
    80003344:	00005717          	auipc	a4,0x5
    80003348:	16470713          	addi	a4,a4,356 # 800084a8 <userret+0x140c>
    8000334c:	4681                	li	a3,0
    8000334e:	44d0                	lw	a2,12(s1)
    80003350:	4581                	li	a1,0
    80003352:	4521                	li	a0,8
    80003354:	08c030ef          	jal	800063e0 <fslog_push>
    80003358:	bf71                	j	800032f4 <brelse+0x34>

000000008000335a <bpin>:

void
bpin(struct buf *b) {
    8000335a:	1101                	addi	sp,sp,-32
    8000335c:	ec06                	sd	ra,24(sp)
    8000335e:	e822                	sd	s0,16(sp)
    80003360:	e426                	sd	s1,8(sp)
    80003362:	1000                	addi	s0,sp,32
    80003364:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80003366:	00015517          	auipc	a0,0x15
    8000336a:	c2250513          	addi	a0,a0,-990 # 80017f88 <bcache>
    8000336e:	9b5fd0ef          	jal	80000d22 <acquire>
  b->refcnt++;
    80003372:	40bc                	lw	a5,64(s1)
    80003374:	2785                	addiw	a5,a5,1
    80003376:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80003378:	00015517          	auipc	a0,0x15
    8000337c:	c1050513          	addi	a0,a0,-1008 # 80017f88 <bcache>
    80003380:	a37fd0ef          	jal	80000db6 <release>
}
    80003384:	60e2                	ld	ra,24(sp)
    80003386:	6442                	ld	s0,16(sp)
    80003388:	64a2                	ld	s1,8(sp)
    8000338a:	6105                	addi	sp,sp,32
    8000338c:	8082                	ret

000000008000338e <bunpin>:

void
bunpin(struct buf *b) {
    8000338e:	1101                	addi	sp,sp,-32
    80003390:	ec06                	sd	ra,24(sp)
    80003392:	e822                	sd	s0,16(sp)
    80003394:	e426                	sd	s1,8(sp)
    80003396:	1000                	addi	s0,sp,32
    80003398:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    8000339a:	00015517          	auipc	a0,0x15
    8000339e:	bee50513          	addi	a0,a0,-1042 # 80017f88 <bcache>
    800033a2:	981fd0ef          	jal	80000d22 <acquire>
  b->refcnt--;
    800033a6:	40bc                	lw	a5,64(s1)
    800033a8:	37fd                	addiw	a5,a5,-1
    800033aa:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    800033ac:	00015517          	auipc	a0,0x15
    800033b0:	bdc50513          	addi	a0,a0,-1060 # 80017f88 <bcache>
    800033b4:	a03fd0ef          	jal	80000db6 <release>
}
    800033b8:	60e2                	ld	ra,24(sp)
    800033ba:	6442                	ld	s0,16(sp)
    800033bc:	64a2                	ld	s1,8(sp)
    800033be:	6105                	addi	sp,sp,32
    800033c0:	8082                	ret

00000000800033c2 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    800033c2:	1101                	addi	sp,sp,-32
    800033c4:	ec06                	sd	ra,24(sp)
    800033c6:	e822                	sd	s0,16(sp)
    800033c8:	e426                	sd	s1,8(sp)
    800033ca:	e04a                	sd	s2,0(sp)
    800033cc:	1000                	addi	s0,sp,32
    800033ce:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    800033d0:	00d5d79b          	srliw	a5,a1,0xd
    800033d4:	0001d597          	auipc	a1,0x1d
    800033d8:	2905a583          	lw	a1,656(a1) # 80020664 <sb+0x1c>
    800033dc:	9dbd                	addw	a1,a1,a5
    800033de:	db3ff0ef          	jal	80003190 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    800033e2:	0074f713          	andi	a4,s1,7
    800033e6:	4785                	li	a5,1
    800033e8:	00e797bb          	sllw	a5,a5,a4
  bi = b % BPB;
    800033ec:	14ce                	slli	s1,s1,0x33
  if((bp->data[bi/8] & m) == 0)
    800033ee:	90d9                	srli	s1,s1,0x36
    800033f0:	00950733          	add	a4,a0,s1
    800033f4:	05874703          	lbu	a4,88(a4)
    800033f8:	00e7f6b3          	and	a3,a5,a4
    800033fc:	c29d                	beqz	a3,80003422 <bfree+0x60>
    800033fe:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    80003400:	94aa                	add	s1,s1,a0
    80003402:	fff7c793          	not	a5,a5
    80003406:	8f7d                	and	a4,a4,a5
    80003408:	04e48c23          	sb	a4,88(s1)
  log_write(bp);
    8000340c:	000010ef          	jal	8000440c <log_write>
  brelse(bp);
    80003410:	854a                	mv	a0,s2
    80003412:	eafff0ef          	jal	800032c0 <brelse>
}
    80003416:	60e2                	ld	ra,24(sp)
    80003418:	6442                	ld	s0,16(sp)
    8000341a:	64a2                	ld	s1,8(sp)
    8000341c:	6902                	ld	s2,0(sp)
    8000341e:	6105                	addi	sp,sp,32
    80003420:	8082                	ret
    panic("freeing free block");
    80003422:	00005517          	auipc	a0,0x5
    80003426:	0b650513          	addi	a0,a0,182 # 800084d8 <userret+0x143c>
    8000342a:	c2cfd0ef          	jal	80000856 <panic>

000000008000342e <balloc>:
{
    8000342e:	715d                	addi	sp,sp,-80
    80003430:	e486                	sd	ra,72(sp)
    80003432:	e0a2                	sd	s0,64(sp)
    80003434:	fc26                	sd	s1,56(sp)
    80003436:	0880                	addi	s0,sp,80
  for(b = 0; b < sb.size; b += BPB){
    80003438:	0001d797          	auipc	a5,0x1d
    8000343c:	2147a783          	lw	a5,532(a5) # 8002064c <sb+0x4>
    80003440:	0e078263          	beqz	a5,80003524 <balloc+0xf6>
    80003444:	f84a                	sd	s2,48(sp)
    80003446:	f44e                	sd	s3,40(sp)
    80003448:	f052                	sd	s4,32(sp)
    8000344a:	ec56                	sd	s5,24(sp)
    8000344c:	e85a                	sd	s6,16(sp)
    8000344e:	e45e                	sd	s7,8(sp)
    80003450:	e062                	sd	s8,0(sp)
    80003452:	8baa                	mv	s7,a0
    80003454:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    80003456:	0001db17          	auipc	s6,0x1d
    8000345a:	1f2b0b13          	addi	s6,s6,498 # 80020648 <sb>
      m = 1 << (bi % 8);
    8000345e:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003460:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    80003462:	6c09                	lui	s8,0x2
    80003464:	a09d                	j	800034ca <balloc+0x9c>
        bp->data[bi/8] |= m;  // Mark block in use.
    80003466:	97ca                	add	a5,a5,s2
    80003468:	8e55                	or	a2,a2,a3
    8000346a:	04c78c23          	sb	a2,88(a5)
        log_write(bp);
    8000346e:	854a                	mv	a0,s2
    80003470:	79d000ef          	jal	8000440c <log_write>
        brelse(bp);
    80003474:	854a                	mv	a0,s2
    80003476:	e4bff0ef          	jal	800032c0 <brelse>
  bp = bread(dev, bno);
    8000347a:	85a6                	mv	a1,s1
    8000347c:	855e                	mv	a0,s7
    8000347e:	d13ff0ef          	jal	80003190 <bread>
    80003482:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    80003484:	40000613          	li	a2,1024
    80003488:	4581                	li	a1,0
    8000348a:	05850513          	addi	a0,a0,88
    8000348e:	965fd0ef          	jal	80000df2 <memset>
  log_write(bp);
    80003492:	854a                	mv	a0,s2
    80003494:	779000ef          	jal	8000440c <log_write>
  brelse(bp);
    80003498:	854a                	mv	a0,s2
    8000349a:	e27ff0ef          	jal	800032c0 <brelse>
}
    8000349e:	7942                	ld	s2,48(sp)
    800034a0:	79a2                	ld	s3,40(sp)
    800034a2:	7a02                	ld	s4,32(sp)
    800034a4:	6ae2                	ld	s5,24(sp)
    800034a6:	6b42                	ld	s6,16(sp)
    800034a8:	6ba2                	ld	s7,8(sp)
    800034aa:	6c02                	ld	s8,0(sp)
}
    800034ac:	8526                	mv	a0,s1
    800034ae:	60a6                	ld	ra,72(sp)
    800034b0:	6406                	ld	s0,64(sp)
    800034b2:	74e2                	ld	s1,56(sp)
    800034b4:	6161                	addi	sp,sp,80
    800034b6:	8082                	ret
    brelse(bp);
    800034b8:	854a                	mv	a0,s2
    800034ba:	e07ff0ef          	jal	800032c0 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    800034be:	015c0abb          	addw	s5,s8,s5
    800034c2:	004b2783          	lw	a5,4(s6)
    800034c6:	04faf863          	bgeu	s5,a5,80003516 <balloc+0xe8>
    bp = bread(dev, BBLOCK(b, sb));
    800034ca:	40dad59b          	sraiw	a1,s5,0xd
    800034ce:	01cb2783          	lw	a5,28(s6)
    800034d2:	9dbd                	addw	a1,a1,a5
    800034d4:	855e                	mv	a0,s7
    800034d6:	cbbff0ef          	jal	80003190 <bread>
    800034da:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800034dc:	004b2503          	lw	a0,4(s6)
    800034e0:	84d6                	mv	s1,s5
    800034e2:	4701                	li	a4,0
    800034e4:	fca4fae3          	bgeu	s1,a0,800034b8 <balloc+0x8a>
      m = 1 << (bi % 8);
    800034e8:	00777693          	andi	a3,a4,7
    800034ec:	00d996bb          	sllw	a3,s3,a3
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    800034f0:	41f7579b          	sraiw	a5,a4,0x1f
    800034f4:	01d7d79b          	srliw	a5,a5,0x1d
    800034f8:	9fb9                	addw	a5,a5,a4
    800034fa:	4037d79b          	sraiw	a5,a5,0x3
    800034fe:	00f90633          	add	a2,s2,a5
    80003502:	05864603          	lbu	a2,88(a2)
    80003506:	00c6f5b3          	and	a1,a3,a2
    8000350a:	ddb1                	beqz	a1,80003466 <balloc+0x38>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000350c:	2705                	addiw	a4,a4,1
    8000350e:	2485                	addiw	s1,s1,1
    80003510:	fd471ae3          	bne	a4,s4,800034e4 <balloc+0xb6>
    80003514:	b755                	j	800034b8 <balloc+0x8a>
    80003516:	7942                	ld	s2,48(sp)
    80003518:	79a2                	ld	s3,40(sp)
    8000351a:	7a02                	ld	s4,32(sp)
    8000351c:	6ae2                	ld	s5,24(sp)
    8000351e:	6b42                	ld	s6,16(sp)
    80003520:	6ba2                	ld	s7,8(sp)
    80003522:	6c02                	ld	s8,0(sp)
  printf("balloc: out of blocks\n");
    80003524:	00005517          	auipc	a0,0x5
    80003528:	fcc50513          	addi	a0,a0,-52 # 800084f0 <userret+0x1454>
    8000352c:	800fd0ef          	jal	8000052c <printf>
  return 0;
    80003530:	4481                	li	s1,0
    80003532:	bfad                	j	800034ac <balloc+0x7e>

0000000080003534 <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    80003534:	7179                	addi	sp,sp,-48
    80003536:	f406                	sd	ra,40(sp)
    80003538:	f022                	sd	s0,32(sp)
    8000353a:	ec26                	sd	s1,24(sp)
    8000353c:	e84a                	sd	s2,16(sp)
    8000353e:	e44e                	sd	s3,8(sp)
    80003540:	1800                	addi	s0,sp,48
    80003542:	892a                	mv	s2,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    80003544:	47ad                	li	a5,11
    80003546:	02b7e363          	bltu	a5,a1,8000356c <bmap+0x38>
    if((addr = ip->addrs[bn]) == 0){
    8000354a:	02059793          	slli	a5,a1,0x20
    8000354e:	01e7d593          	srli	a1,a5,0x1e
    80003552:	00b509b3          	add	s3,a0,a1
    80003556:	0509a483          	lw	s1,80(s3)
    8000355a:	e0b5                	bnez	s1,800035be <bmap+0x8a>
      addr = balloc(ip->dev);
    8000355c:	4108                	lw	a0,0(a0)
    8000355e:	ed1ff0ef          	jal	8000342e <balloc>
    80003562:	84aa                	mv	s1,a0
      if(addr == 0)
    80003564:	cd29                	beqz	a0,800035be <bmap+0x8a>
        return 0;
      ip->addrs[bn] = addr;
    80003566:	04a9a823          	sw	a0,80(s3)
    8000356a:	a891                	j	800035be <bmap+0x8a>
    }
    return addr;
  }
  bn -= NDIRECT;
    8000356c:	ff45879b          	addiw	a5,a1,-12
    80003570:	873e                	mv	a4,a5
    80003572:	89be                	mv	s3,a5

  if(bn < NINDIRECT){
    80003574:	0ff00793          	li	a5,255
    80003578:	06e7e763          	bltu	a5,a4,800035e6 <bmap+0xb2>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    8000357c:	08052483          	lw	s1,128(a0)
    80003580:	e891                	bnez	s1,80003594 <bmap+0x60>
      addr = balloc(ip->dev);
    80003582:	4108                	lw	a0,0(a0)
    80003584:	eabff0ef          	jal	8000342e <balloc>
    80003588:	84aa                	mv	s1,a0
      if(addr == 0)
    8000358a:	c915                	beqz	a0,800035be <bmap+0x8a>
    8000358c:	e052                	sd	s4,0(sp)
        return 0;
      ip->addrs[NDIRECT] = addr;
    8000358e:	08a92023          	sw	a0,128(s2)
    80003592:	a011                	j	80003596 <bmap+0x62>
    80003594:	e052                	sd	s4,0(sp)
    }
    bp = bread(ip->dev, addr);
    80003596:	85a6                	mv	a1,s1
    80003598:	00092503          	lw	a0,0(s2)
    8000359c:	bf5ff0ef          	jal	80003190 <bread>
    800035a0:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    800035a2:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    800035a6:	02099713          	slli	a4,s3,0x20
    800035aa:	01e75593          	srli	a1,a4,0x1e
    800035ae:	97ae                	add	a5,a5,a1
    800035b0:	89be                	mv	s3,a5
    800035b2:	4384                	lw	s1,0(a5)
    800035b4:	cc89                	beqz	s1,800035ce <bmap+0x9a>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    800035b6:	8552                	mv	a0,s4
    800035b8:	d09ff0ef          	jal	800032c0 <brelse>
    return addr;
    800035bc:	6a02                	ld	s4,0(sp)
  }

  panic("bmap: out of range");
}
    800035be:	8526                	mv	a0,s1
    800035c0:	70a2                	ld	ra,40(sp)
    800035c2:	7402                	ld	s0,32(sp)
    800035c4:	64e2                	ld	s1,24(sp)
    800035c6:	6942                	ld	s2,16(sp)
    800035c8:	69a2                	ld	s3,8(sp)
    800035ca:	6145                	addi	sp,sp,48
    800035cc:	8082                	ret
      addr = balloc(ip->dev);
    800035ce:	00092503          	lw	a0,0(s2)
    800035d2:	e5dff0ef          	jal	8000342e <balloc>
    800035d6:	84aa                	mv	s1,a0
      if(addr){
    800035d8:	dd79                	beqz	a0,800035b6 <bmap+0x82>
        a[bn] = addr;
    800035da:	00a9a023          	sw	a0,0(s3)
        log_write(bp);
    800035de:	8552                	mv	a0,s4
    800035e0:	62d000ef          	jal	8000440c <log_write>
    800035e4:	bfc9                	j	800035b6 <bmap+0x82>
    800035e6:	e052                	sd	s4,0(sp)
  panic("bmap: out of range");
    800035e8:	00005517          	auipc	a0,0x5
    800035ec:	f2050513          	addi	a0,a0,-224 # 80008508 <userret+0x146c>
    800035f0:	a66fd0ef          	jal	80000856 <panic>

00000000800035f4 <iget>:
{
    800035f4:	7179                	addi	sp,sp,-48
    800035f6:	f406                	sd	ra,40(sp)
    800035f8:	f022                	sd	s0,32(sp)
    800035fa:	ec26                	sd	s1,24(sp)
    800035fc:	e84a                	sd	s2,16(sp)
    800035fe:	e44e                	sd	s3,8(sp)
    80003600:	e052                	sd	s4,0(sp)
    80003602:	1800                	addi	s0,sp,48
    80003604:	892a                	mv	s2,a0
    80003606:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    80003608:	0001d517          	auipc	a0,0x1d
    8000360c:	06050513          	addi	a0,a0,96 # 80020668 <itable>
    80003610:	f12fd0ef          	jal	80000d22 <acquire>
  empty = 0;
    80003614:	4981                	li	s3,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003616:	0001d497          	auipc	s1,0x1d
    8000361a:	06a48493          	addi	s1,s1,106 # 80020680 <itable+0x18>
    8000361e:	0001f697          	auipc	a3,0x1f
    80003622:	af268693          	addi	a3,a3,-1294 # 80022110 <log>
    80003626:	a809                	j	80003638 <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003628:	e781                	bnez	a5,80003630 <iget+0x3c>
    8000362a:	00099363          	bnez	s3,80003630 <iget+0x3c>
      empty = ip;
    8000362e:	89a6                	mv	s3,s1
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003630:	08848493          	addi	s1,s1,136
    80003634:	02d48563          	beq	s1,a3,8000365e <iget+0x6a>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    80003638:	449c                	lw	a5,8(s1)
    8000363a:	fef057e3          	blez	a5,80003628 <iget+0x34>
    8000363e:	4098                	lw	a4,0(s1)
    80003640:	ff2718e3          	bne	a4,s2,80003630 <iget+0x3c>
    80003644:	40d8                	lw	a4,4(s1)
    80003646:	ff4715e3          	bne	a4,s4,80003630 <iget+0x3c>
      ip->ref++;
    8000364a:	2785                	addiw	a5,a5,1
    8000364c:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    8000364e:	0001d517          	auipc	a0,0x1d
    80003652:	01a50513          	addi	a0,a0,26 # 80020668 <itable>
    80003656:	f60fd0ef          	jal	80000db6 <release>
      return ip;
    8000365a:	89a6                	mv	s3,s1
    8000365c:	a015                	j	80003680 <iget+0x8c>
  if(empty == 0)
    8000365e:	02098a63          	beqz	s3,80003692 <iget+0x9e>
  ip->dev = dev;
    80003662:	0129a023          	sw	s2,0(s3)
  ip->inum = inum;
    80003666:	0149a223          	sw	s4,4(s3)
  ip->ref = 1;
    8000366a:	4785                	li	a5,1
    8000366c:	00f9a423          	sw	a5,8(s3)
  ip->valid = 0;
    80003670:	0409a023          	sw	zero,64(s3)
  release(&itable.lock);
    80003674:	0001d517          	auipc	a0,0x1d
    80003678:	ff450513          	addi	a0,a0,-12 # 80020668 <itable>
    8000367c:	f3afd0ef          	jal	80000db6 <release>
}
    80003680:	854e                	mv	a0,s3
    80003682:	70a2                	ld	ra,40(sp)
    80003684:	7402                	ld	s0,32(sp)
    80003686:	64e2                	ld	s1,24(sp)
    80003688:	6942                	ld	s2,16(sp)
    8000368a:	69a2                	ld	s3,8(sp)
    8000368c:	6a02                	ld	s4,0(sp)
    8000368e:	6145                	addi	sp,sp,48
    80003690:	8082                	ret
    panic("iget: no inodes");
    80003692:	00005517          	auipc	a0,0x5
    80003696:	e8e50513          	addi	a0,a0,-370 # 80008520 <userret+0x1484>
    8000369a:	9bcfd0ef          	jal	80000856 <panic>

000000008000369e <iinit>:
{
    8000369e:	7179                	addi	sp,sp,-48
    800036a0:	f406                	sd	ra,40(sp)
    800036a2:	f022                	sd	s0,32(sp)
    800036a4:	ec26                	sd	s1,24(sp)
    800036a6:	e84a                	sd	s2,16(sp)
    800036a8:	e44e                	sd	s3,8(sp)
    800036aa:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    800036ac:	00005597          	auipc	a1,0x5
    800036b0:	e8458593          	addi	a1,a1,-380 # 80008530 <userret+0x1494>
    800036b4:	0001d517          	auipc	a0,0x1d
    800036b8:	fb450513          	addi	a0,a0,-76 # 80020668 <itable>
    800036bc:	ddcfd0ef          	jal	80000c98 <initlock>
  for(i = 0; i < NINODE; i++) {
    800036c0:	0001d497          	auipc	s1,0x1d
    800036c4:	fd048493          	addi	s1,s1,-48 # 80020690 <itable+0x28>
    800036c8:	0001f997          	auipc	s3,0x1f
    800036cc:	a5898993          	addi	s3,s3,-1448 # 80022120 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    800036d0:	00005917          	auipc	s2,0x5
    800036d4:	e6890913          	addi	s2,s2,-408 # 80008538 <userret+0x149c>
    800036d8:	85ca                	mv	a1,s2
    800036da:	8526                	mv	a0,s1
    800036dc:	5f5000ef          	jal	800044d0 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    800036e0:	08848493          	addi	s1,s1,136
    800036e4:	ff349ae3          	bne	s1,s3,800036d8 <iinit+0x3a>
}
    800036e8:	70a2                	ld	ra,40(sp)
    800036ea:	7402                	ld	s0,32(sp)
    800036ec:	64e2                	ld	s1,24(sp)
    800036ee:	6942                	ld	s2,16(sp)
    800036f0:	69a2                	ld	s3,8(sp)
    800036f2:	6145                	addi	sp,sp,48
    800036f4:	8082                	ret

00000000800036f6 <ialloc>:
{
    800036f6:	7139                	addi	sp,sp,-64
    800036f8:	fc06                	sd	ra,56(sp)
    800036fa:	f822                	sd	s0,48(sp)
    800036fc:	0080                	addi	s0,sp,64
  for(inum = 1; inum < sb.ninodes; inum++){
    800036fe:	0001d717          	auipc	a4,0x1d
    80003702:	f5672703          	lw	a4,-170(a4) # 80020654 <sb+0xc>
    80003706:	4785                	li	a5,1
    80003708:	06e7f063          	bgeu	a5,a4,80003768 <ialloc+0x72>
    8000370c:	f426                	sd	s1,40(sp)
    8000370e:	f04a                	sd	s2,32(sp)
    80003710:	ec4e                	sd	s3,24(sp)
    80003712:	e852                	sd	s4,16(sp)
    80003714:	e456                	sd	s5,8(sp)
    80003716:	e05a                	sd	s6,0(sp)
    80003718:	8aaa                	mv	s5,a0
    8000371a:	8b2e                	mv	s6,a1
    8000371c:	893e                	mv	s2,a5
    bp = bread(dev, IBLOCK(inum, sb));
    8000371e:	0001da17          	auipc	s4,0x1d
    80003722:	f2aa0a13          	addi	s4,s4,-214 # 80020648 <sb>
    80003726:	00495593          	srli	a1,s2,0x4
    8000372a:	018a2783          	lw	a5,24(s4)
    8000372e:	9dbd                	addw	a1,a1,a5
    80003730:	8556                	mv	a0,s5
    80003732:	a5fff0ef          	jal	80003190 <bread>
    80003736:	84aa                	mv	s1,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    80003738:	05850993          	addi	s3,a0,88
    8000373c:	00f97793          	andi	a5,s2,15
    80003740:	079a                	slli	a5,a5,0x6
    80003742:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    80003744:	00099783          	lh	a5,0(s3)
    80003748:	cb9d                	beqz	a5,8000377e <ialloc+0x88>
    brelse(bp);
    8000374a:	b77ff0ef          	jal	800032c0 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    8000374e:	0905                	addi	s2,s2,1
    80003750:	00ca2703          	lw	a4,12(s4)
    80003754:	0009079b          	sext.w	a5,s2
    80003758:	fce7e7e3          	bltu	a5,a4,80003726 <ialloc+0x30>
    8000375c:	74a2                	ld	s1,40(sp)
    8000375e:	7902                	ld	s2,32(sp)
    80003760:	69e2                	ld	s3,24(sp)
    80003762:	6a42                	ld	s4,16(sp)
    80003764:	6aa2                	ld	s5,8(sp)
    80003766:	6b02                	ld	s6,0(sp)
  printf("ialloc: no inodes\n");
    80003768:	00005517          	auipc	a0,0x5
    8000376c:	dd850513          	addi	a0,a0,-552 # 80008540 <userret+0x14a4>
    80003770:	dbdfc0ef          	jal	8000052c <printf>
  return 0;
    80003774:	4501                	li	a0,0
}
    80003776:	70e2                	ld	ra,56(sp)
    80003778:	7442                	ld	s0,48(sp)
    8000377a:	6121                	addi	sp,sp,64
    8000377c:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    8000377e:	04000613          	li	a2,64
    80003782:	4581                	li	a1,0
    80003784:	854e                	mv	a0,s3
    80003786:	e6cfd0ef          	jal	80000df2 <memset>
      dip->type = type;
    8000378a:	01699023          	sh	s6,0(s3)
      log_write(bp);   // mark it allocated on the disk
    8000378e:	8526                	mv	a0,s1
    80003790:	47d000ef          	jal	8000440c <log_write>
      brelse(bp);
    80003794:	8526                	mv	a0,s1
    80003796:	b2bff0ef          	jal	800032c0 <brelse>
      return iget(dev, inum);
    8000379a:	0009059b          	sext.w	a1,s2
    8000379e:	8556                	mv	a0,s5
    800037a0:	e55ff0ef          	jal	800035f4 <iget>
    800037a4:	74a2                	ld	s1,40(sp)
    800037a6:	7902                	ld	s2,32(sp)
    800037a8:	69e2                	ld	s3,24(sp)
    800037aa:	6a42                	ld	s4,16(sp)
    800037ac:	6aa2                	ld	s5,8(sp)
    800037ae:	6b02                	ld	s6,0(sp)
    800037b0:	b7d9                	j	80003776 <ialloc+0x80>

00000000800037b2 <iupdate>:
{
    800037b2:	1101                	addi	sp,sp,-32
    800037b4:	ec06                	sd	ra,24(sp)
    800037b6:	e822                	sd	s0,16(sp)
    800037b8:	e426                	sd	s1,8(sp)
    800037ba:	e04a                	sd	s2,0(sp)
    800037bc:	1000                	addi	s0,sp,32
    800037be:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    800037c0:	415c                	lw	a5,4(a0)
    800037c2:	0047d79b          	srliw	a5,a5,0x4
    800037c6:	0001d597          	auipc	a1,0x1d
    800037ca:	e9a5a583          	lw	a1,-358(a1) # 80020660 <sb+0x18>
    800037ce:	9dbd                	addw	a1,a1,a5
    800037d0:	4108                	lw	a0,0(a0)
    800037d2:	9bfff0ef          	jal	80003190 <bread>
    800037d6:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    800037d8:	05850793          	addi	a5,a0,88
    800037dc:	40d8                	lw	a4,4(s1)
    800037de:	8b3d                	andi	a4,a4,15
    800037e0:	071a                	slli	a4,a4,0x6
    800037e2:	97ba                	add	a5,a5,a4
  dip->type = ip->type;
    800037e4:	04449703          	lh	a4,68(s1)
    800037e8:	00e79023          	sh	a4,0(a5)
  dip->major = ip->major;
    800037ec:	04649703          	lh	a4,70(s1)
    800037f0:	00e79123          	sh	a4,2(a5)
  dip->minor = ip->minor;
    800037f4:	04849703          	lh	a4,72(s1)
    800037f8:	00e79223          	sh	a4,4(a5)
  dip->nlink = ip->nlink;
    800037fc:	04a49703          	lh	a4,74(s1)
    80003800:	00e79323          	sh	a4,6(a5)
  dip->size = ip->size;
    80003804:	44f8                	lw	a4,76(s1)
    80003806:	c798                	sw	a4,8(a5)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80003808:	03400613          	li	a2,52
    8000380c:	05048593          	addi	a1,s1,80
    80003810:	00c78513          	addi	a0,a5,12
    80003814:	e3efd0ef          	jal	80000e52 <memmove>
  log_write(bp);
    80003818:	854a                	mv	a0,s2
    8000381a:	3f3000ef          	jal	8000440c <log_write>
  brelse(bp);
    8000381e:	854a                	mv	a0,s2
    80003820:	aa1ff0ef          	jal	800032c0 <brelse>
}
    80003824:	60e2                	ld	ra,24(sp)
    80003826:	6442                	ld	s0,16(sp)
    80003828:	64a2                	ld	s1,8(sp)
    8000382a:	6902                	ld	s2,0(sp)
    8000382c:	6105                	addi	sp,sp,32
    8000382e:	8082                	ret

0000000080003830 <idup>:
{
    80003830:	1101                	addi	sp,sp,-32
    80003832:	ec06                	sd	ra,24(sp)
    80003834:	e822                	sd	s0,16(sp)
    80003836:	e426                	sd	s1,8(sp)
    80003838:	1000                	addi	s0,sp,32
    8000383a:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    8000383c:	0001d517          	auipc	a0,0x1d
    80003840:	e2c50513          	addi	a0,a0,-468 # 80020668 <itable>
    80003844:	cdefd0ef          	jal	80000d22 <acquire>
  ip->ref++;
    80003848:	449c                	lw	a5,8(s1)
    8000384a:	2785                	addiw	a5,a5,1
    8000384c:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    8000384e:	0001d517          	auipc	a0,0x1d
    80003852:	e1a50513          	addi	a0,a0,-486 # 80020668 <itable>
    80003856:	d60fd0ef          	jal	80000db6 <release>
}
    8000385a:	8526                	mv	a0,s1
    8000385c:	60e2                	ld	ra,24(sp)
    8000385e:	6442                	ld	s0,16(sp)
    80003860:	64a2                	ld	s1,8(sp)
    80003862:	6105                	addi	sp,sp,32
    80003864:	8082                	ret

0000000080003866 <ilock>:
{
    80003866:	1101                	addi	sp,sp,-32
    80003868:	ec06                	sd	ra,24(sp)
    8000386a:	e822                	sd	s0,16(sp)
    8000386c:	e426                	sd	s1,8(sp)
    8000386e:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    80003870:	cd19                	beqz	a0,8000388e <ilock+0x28>
    80003872:	84aa                	mv	s1,a0
    80003874:	451c                	lw	a5,8(a0)
    80003876:	00f05c63          	blez	a5,8000388e <ilock+0x28>
  acquiresleep(&ip->lock);
    8000387a:	0541                	addi	a0,a0,16
    8000387c:	48b000ef          	jal	80004506 <acquiresleep>
  if(ip->valid == 0){
    80003880:	40bc                	lw	a5,64(s1)
    80003882:	cf89                	beqz	a5,8000389c <ilock+0x36>
}
    80003884:	60e2                	ld	ra,24(sp)
    80003886:	6442                	ld	s0,16(sp)
    80003888:	64a2                	ld	s1,8(sp)
    8000388a:	6105                	addi	sp,sp,32
    8000388c:	8082                	ret
    8000388e:	e04a                	sd	s2,0(sp)
    panic("ilock");
    80003890:	00005517          	auipc	a0,0x5
    80003894:	cc850513          	addi	a0,a0,-824 # 80008558 <userret+0x14bc>
    80003898:	fbffc0ef          	jal	80000856 <panic>
    8000389c:	e04a                	sd	s2,0(sp)
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    8000389e:	40dc                	lw	a5,4(s1)
    800038a0:	0047d79b          	srliw	a5,a5,0x4
    800038a4:	0001d597          	auipc	a1,0x1d
    800038a8:	dbc5a583          	lw	a1,-580(a1) # 80020660 <sb+0x18>
    800038ac:	9dbd                	addw	a1,a1,a5
    800038ae:	4088                	lw	a0,0(s1)
    800038b0:	8e1ff0ef          	jal	80003190 <bread>
    800038b4:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    800038b6:	05850593          	addi	a1,a0,88
    800038ba:	40dc                	lw	a5,4(s1)
    800038bc:	8bbd                	andi	a5,a5,15
    800038be:	079a                	slli	a5,a5,0x6
    800038c0:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    800038c2:	00059783          	lh	a5,0(a1)
    800038c6:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    800038ca:	00259783          	lh	a5,2(a1)
    800038ce:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    800038d2:	00459783          	lh	a5,4(a1)
    800038d6:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    800038da:	00659783          	lh	a5,6(a1)
    800038de:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    800038e2:	459c                	lw	a5,8(a1)
    800038e4:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    800038e6:	03400613          	li	a2,52
    800038ea:	05b1                	addi	a1,a1,12
    800038ec:	05048513          	addi	a0,s1,80
    800038f0:	d62fd0ef          	jal	80000e52 <memmove>
    brelse(bp);
    800038f4:	854a                	mv	a0,s2
    800038f6:	9cbff0ef          	jal	800032c0 <brelse>
    ip->valid = 1;
    800038fa:	4785                	li	a5,1
    800038fc:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    800038fe:	04449783          	lh	a5,68(s1)
    80003902:	c399                	beqz	a5,80003908 <ilock+0xa2>
    80003904:	6902                	ld	s2,0(sp)
    80003906:	bfbd                	j	80003884 <ilock+0x1e>
      panic("ilock: no type");
    80003908:	00005517          	auipc	a0,0x5
    8000390c:	c5850513          	addi	a0,a0,-936 # 80008560 <userret+0x14c4>
    80003910:	f47fc0ef          	jal	80000856 <panic>

0000000080003914 <iunlock>:
{
    80003914:	1101                	addi	sp,sp,-32
    80003916:	ec06                	sd	ra,24(sp)
    80003918:	e822                	sd	s0,16(sp)
    8000391a:	e426                	sd	s1,8(sp)
    8000391c:	e04a                	sd	s2,0(sp)
    8000391e:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80003920:	c505                	beqz	a0,80003948 <iunlock+0x34>
    80003922:	84aa                	mv	s1,a0
    80003924:	01050913          	addi	s2,a0,16
    80003928:	854a                	mv	a0,s2
    8000392a:	45b000ef          	jal	80004584 <holdingsleep>
    8000392e:	cd09                	beqz	a0,80003948 <iunlock+0x34>
    80003930:	449c                	lw	a5,8(s1)
    80003932:	00f05b63          	blez	a5,80003948 <iunlock+0x34>
  releasesleep(&ip->lock);
    80003936:	854a                	mv	a0,s2
    80003938:	415000ef          	jal	8000454c <releasesleep>
}
    8000393c:	60e2                	ld	ra,24(sp)
    8000393e:	6442                	ld	s0,16(sp)
    80003940:	64a2                	ld	s1,8(sp)
    80003942:	6902                	ld	s2,0(sp)
    80003944:	6105                	addi	sp,sp,32
    80003946:	8082                	ret
    panic("iunlock");
    80003948:	00005517          	auipc	a0,0x5
    8000394c:	c2850513          	addi	a0,a0,-984 # 80008570 <userret+0x14d4>
    80003950:	f07fc0ef          	jal	80000856 <panic>

0000000080003954 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    80003954:	7179                	addi	sp,sp,-48
    80003956:	f406                	sd	ra,40(sp)
    80003958:	f022                	sd	s0,32(sp)
    8000395a:	ec26                	sd	s1,24(sp)
    8000395c:	e84a                	sd	s2,16(sp)
    8000395e:	e44e                	sd	s3,8(sp)
    80003960:	1800                	addi	s0,sp,48
    80003962:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    80003964:	05050493          	addi	s1,a0,80
    80003968:	08050913          	addi	s2,a0,128
    8000396c:	a021                	j	80003974 <itrunc+0x20>
    8000396e:	0491                	addi	s1,s1,4
    80003970:	01248b63          	beq	s1,s2,80003986 <itrunc+0x32>
    if(ip->addrs[i]){
    80003974:	408c                	lw	a1,0(s1)
    80003976:	dde5                	beqz	a1,8000396e <itrunc+0x1a>
      bfree(ip->dev, ip->addrs[i]);
    80003978:	0009a503          	lw	a0,0(s3)
    8000397c:	a47ff0ef          	jal	800033c2 <bfree>
      ip->addrs[i] = 0;
    80003980:	0004a023          	sw	zero,0(s1)
    80003984:	b7ed                	j	8000396e <itrunc+0x1a>
    }
  }

  if(ip->addrs[NDIRECT]){
    80003986:	0809a583          	lw	a1,128(s3)
    8000398a:	ed89                	bnez	a1,800039a4 <itrunc+0x50>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    8000398c:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    80003990:	854e                	mv	a0,s3
    80003992:	e21ff0ef          	jal	800037b2 <iupdate>
}
    80003996:	70a2                	ld	ra,40(sp)
    80003998:	7402                	ld	s0,32(sp)
    8000399a:	64e2                	ld	s1,24(sp)
    8000399c:	6942                	ld	s2,16(sp)
    8000399e:	69a2                	ld	s3,8(sp)
    800039a0:	6145                	addi	sp,sp,48
    800039a2:	8082                	ret
    800039a4:	e052                	sd	s4,0(sp)
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    800039a6:	0009a503          	lw	a0,0(s3)
    800039aa:	fe6ff0ef          	jal	80003190 <bread>
    800039ae:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    800039b0:	05850493          	addi	s1,a0,88
    800039b4:	45850913          	addi	s2,a0,1112
    800039b8:	a021                	j	800039c0 <itrunc+0x6c>
    800039ba:	0491                	addi	s1,s1,4
    800039bc:	01248963          	beq	s1,s2,800039ce <itrunc+0x7a>
      if(a[j])
    800039c0:	408c                	lw	a1,0(s1)
    800039c2:	dde5                	beqz	a1,800039ba <itrunc+0x66>
        bfree(ip->dev, a[j]);
    800039c4:	0009a503          	lw	a0,0(s3)
    800039c8:	9fbff0ef          	jal	800033c2 <bfree>
    800039cc:	b7fd                	j	800039ba <itrunc+0x66>
    brelse(bp);
    800039ce:	8552                	mv	a0,s4
    800039d0:	8f1ff0ef          	jal	800032c0 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    800039d4:	0809a583          	lw	a1,128(s3)
    800039d8:	0009a503          	lw	a0,0(s3)
    800039dc:	9e7ff0ef          	jal	800033c2 <bfree>
    ip->addrs[NDIRECT] = 0;
    800039e0:	0809a023          	sw	zero,128(s3)
    800039e4:	6a02                	ld	s4,0(sp)
    800039e6:	b75d                	j	8000398c <itrunc+0x38>

00000000800039e8 <iput>:
{
    800039e8:	1101                	addi	sp,sp,-32
    800039ea:	ec06                	sd	ra,24(sp)
    800039ec:	e822                	sd	s0,16(sp)
    800039ee:	e426                	sd	s1,8(sp)
    800039f0:	1000                	addi	s0,sp,32
    800039f2:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    800039f4:	0001d517          	auipc	a0,0x1d
    800039f8:	c7450513          	addi	a0,a0,-908 # 80020668 <itable>
    800039fc:	b26fd0ef          	jal	80000d22 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003a00:	4498                	lw	a4,8(s1)
    80003a02:	4785                	li	a5,1
    80003a04:	02f70063          	beq	a4,a5,80003a24 <iput+0x3c>
  ip->ref--;
    80003a08:	449c                	lw	a5,8(s1)
    80003a0a:	37fd                	addiw	a5,a5,-1
    80003a0c:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003a0e:	0001d517          	auipc	a0,0x1d
    80003a12:	c5a50513          	addi	a0,a0,-934 # 80020668 <itable>
    80003a16:	ba0fd0ef          	jal	80000db6 <release>
}
    80003a1a:	60e2                	ld	ra,24(sp)
    80003a1c:	6442                	ld	s0,16(sp)
    80003a1e:	64a2                	ld	s1,8(sp)
    80003a20:	6105                	addi	sp,sp,32
    80003a22:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003a24:	40bc                	lw	a5,64(s1)
    80003a26:	d3ed                	beqz	a5,80003a08 <iput+0x20>
    80003a28:	04a49783          	lh	a5,74(s1)
    80003a2c:	fff1                	bnez	a5,80003a08 <iput+0x20>
    80003a2e:	e04a                	sd	s2,0(sp)
    acquiresleep(&ip->lock);
    80003a30:	01048793          	addi	a5,s1,16
    80003a34:	893e                	mv	s2,a5
    80003a36:	853e                	mv	a0,a5
    80003a38:	2cf000ef          	jal	80004506 <acquiresleep>
    release(&itable.lock);
    80003a3c:	0001d517          	auipc	a0,0x1d
    80003a40:	c2c50513          	addi	a0,a0,-980 # 80020668 <itable>
    80003a44:	b72fd0ef          	jal	80000db6 <release>
    itrunc(ip);
    80003a48:	8526                	mv	a0,s1
    80003a4a:	f0bff0ef          	jal	80003954 <itrunc>
    ip->type = 0;
    80003a4e:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    80003a52:	8526                	mv	a0,s1
    80003a54:	d5fff0ef          	jal	800037b2 <iupdate>
    ip->valid = 0;
    80003a58:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80003a5c:	854a                	mv	a0,s2
    80003a5e:	2ef000ef          	jal	8000454c <releasesleep>
    acquire(&itable.lock);
    80003a62:	0001d517          	auipc	a0,0x1d
    80003a66:	c0650513          	addi	a0,a0,-1018 # 80020668 <itable>
    80003a6a:	ab8fd0ef          	jal	80000d22 <acquire>
    80003a6e:	6902                	ld	s2,0(sp)
    80003a70:	bf61                	j	80003a08 <iput+0x20>

0000000080003a72 <iunlockput>:
{
    80003a72:	1101                	addi	sp,sp,-32
    80003a74:	ec06                	sd	ra,24(sp)
    80003a76:	e822                	sd	s0,16(sp)
    80003a78:	e426                	sd	s1,8(sp)
    80003a7a:	1000                	addi	s0,sp,32
    80003a7c:	84aa                	mv	s1,a0
  iunlock(ip);
    80003a7e:	e97ff0ef          	jal	80003914 <iunlock>
  iput(ip);
    80003a82:	8526                	mv	a0,s1
    80003a84:	f65ff0ef          	jal	800039e8 <iput>
}
    80003a88:	60e2                	ld	ra,24(sp)
    80003a8a:	6442                	ld	s0,16(sp)
    80003a8c:	64a2                	ld	s1,8(sp)
    80003a8e:	6105                	addi	sp,sp,32
    80003a90:	8082                	ret

0000000080003a92 <ireclaim>:
  for (int inum = 1; inum < sb.ninodes; inum++) {
    80003a92:	0001d717          	auipc	a4,0x1d
    80003a96:	bc272703          	lw	a4,-1086(a4) # 80020654 <sb+0xc>
    80003a9a:	4785                	li	a5,1
    80003a9c:	0ae7fe63          	bgeu	a5,a4,80003b58 <ireclaim+0xc6>
{
    80003aa0:	7139                	addi	sp,sp,-64
    80003aa2:	fc06                	sd	ra,56(sp)
    80003aa4:	f822                	sd	s0,48(sp)
    80003aa6:	f426                	sd	s1,40(sp)
    80003aa8:	f04a                	sd	s2,32(sp)
    80003aaa:	ec4e                	sd	s3,24(sp)
    80003aac:	e852                	sd	s4,16(sp)
    80003aae:	e456                	sd	s5,8(sp)
    80003ab0:	e05a                	sd	s6,0(sp)
    80003ab2:	0080                	addi	s0,sp,64
    80003ab4:	8aaa                	mv	s5,a0
  for (int inum = 1; inum < sb.ninodes; inum++) {
    80003ab6:	84be                	mv	s1,a5
    struct buf *bp = bread(dev, IBLOCK(inum, sb));
    80003ab8:	0001da17          	auipc	s4,0x1d
    80003abc:	b90a0a13          	addi	s4,s4,-1136 # 80020648 <sb>
      printf("ireclaim: orphaned inode %d\n", inum);
    80003ac0:	00005b17          	auipc	s6,0x5
    80003ac4:	ab8b0b13          	addi	s6,s6,-1352 # 80008578 <userret+0x14dc>
    80003ac8:	a099                	j	80003b0e <ireclaim+0x7c>
    80003aca:	85ce                	mv	a1,s3
    80003acc:	855a                	mv	a0,s6
    80003ace:	a5ffc0ef          	jal	8000052c <printf>
      ip = iget(dev, inum);
    80003ad2:	85ce                	mv	a1,s3
    80003ad4:	8556                	mv	a0,s5
    80003ad6:	b1fff0ef          	jal	800035f4 <iget>
    80003ada:	89aa                	mv	s3,a0
    brelse(bp);
    80003adc:	854a                	mv	a0,s2
    80003ade:	fe2ff0ef          	jal	800032c0 <brelse>
    if (ip) {
    80003ae2:	00098f63          	beqz	s3,80003b00 <ireclaim+0x6e>
      begin_op();
    80003ae6:	78c000ef          	jal	80004272 <begin_op>
      ilock(ip);
    80003aea:	854e                	mv	a0,s3
    80003aec:	d7bff0ef          	jal	80003866 <ilock>
      iunlock(ip);
    80003af0:	854e                	mv	a0,s3
    80003af2:	e23ff0ef          	jal	80003914 <iunlock>
      iput(ip);
    80003af6:	854e                	mv	a0,s3
    80003af8:	ef1ff0ef          	jal	800039e8 <iput>
      end_op();
    80003afc:	7e6000ef          	jal	800042e2 <end_op>
  for (int inum = 1; inum < sb.ninodes; inum++) {
    80003b00:	0485                	addi	s1,s1,1
    80003b02:	00ca2703          	lw	a4,12(s4)
    80003b06:	0004879b          	sext.w	a5,s1
    80003b0a:	02e7fd63          	bgeu	a5,a4,80003b44 <ireclaim+0xb2>
    80003b0e:	0004899b          	sext.w	s3,s1
    struct buf *bp = bread(dev, IBLOCK(inum, sb));
    80003b12:	0044d593          	srli	a1,s1,0x4
    80003b16:	018a2783          	lw	a5,24(s4)
    80003b1a:	9dbd                	addw	a1,a1,a5
    80003b1c:	8556                	mv	a0,s5
    80003b1e:	e72ff0ef          	jal	80003190 <bread>
    80003b22:	892a                	mv	s2,a0
    struct dinode *dip = (struct dinode *)bp->data + inum % IPB;
    80003b24:	05850793          	addi	a5,a0,88
    80003b28:	00f9f713          	andi	a4,s3,15
    80003b2c:	071a                	slli	a4,a4,0x6
    80003b2e:	97ba                	add	a5,a5,a4
    if (dip->type != 0 && dip->nlink == 0) {  // is an orphaned inode
    80003b30:	00079703          	lh	a4,0(a5)
    80003b34:	c701                	beqz	a4,80003b3c <ireclaim+0xaa>
    80003b36:	00679783          	lh	a5,6(a5)
    80003b3a:	dbc1                	beqz	a5,80003aca <ireclaim+0x38>
    brelse(bp);
    80003b3c:	854a                	mv	a0,s2
    80003b3e:	f82ff0ef          	jal	800032c0 <brelse>
    if (ip) {
    80003b42:	bf7d                	j	80003b00 <ireclaim+0x6e>
}
    80003b44:	70e2                	ld	ra,56(sp)
    80003b46:	7442                	ld	s0,48(sp)
    80003b48:	74a2                	ld	s1,40(sp)
    80003b4a:	7902                	ld	s2,32(sp)
    80003b4c:	69e2                	ld	s3,24(sp)
    80003b4e:	6a42                	ld	s4,16(sp)
    80003b50:	6aa2                	ld	s5,8(sp)
    80003b52:	6b02                	ld	s6,0(sp)
    80003b54:	6121                	addi	sp,sp,64
    80003b56:	8082                	ret
    80003b58:	8082                	ret

0000000080003b5a <fsinit>:
fsinit(int dev) {
    80003b5a:	1101                	addi	sp,sp,-32
    80003b5c:	ec06                	sd	ra,24(sp)
    80003b5e:	e822                	sd	s0,16(sp)
    80003b60:	e426                	sd	s1,8(sp)
    80003b62:	e04a                	sd	s2,0(sp)
    80003b64:	1000                	addi	s0,sp,32
    80003b66:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    80003b68:	4585                	li	a1,1
    80003b6a:	e26ff0ef          	jal	80003190 <bread>
    80003b6e:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    80003b70:	02000613          	li	a2,32
    80003b74:	05850593          	addi	a1,a0,88
    80003b78:	0001d517          	auipc	a0,0x1d
    80003b7c:	ad050513          	addi	a0,a0,-1328 # 80020648 <sb>
    80003b80:	ad2fd0ef          	jal	80000e52 <memmove>
  brelse(bp);
    80003b84:	8526                	mv	a0,s1
    80003b86:	f3aff0ef          	jal	800032c0 <brelse>
  if(sb.magic != FSMAGIC)
    80003b8a:	0001d717          	auipc	a4,0x1d
    80003b8e:	abe72703          	lw	a4,-1346(a4) # 80020648 <sb>
    80003b92:	102037b7          	lui	a5,0x10203
    80003b96:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    80003b9a:	02f71263          	bne	a4,a5,80003bbe <fsinit+0x64>
  initlog(dev, &sb);
    80003b9e:	0001d597          	auipc	a1,0x1d
    80003ba2:	aaa58593          	addi	a1,a1,-1366 # 80020648 <sb>
    80003ba6:	854a                	mv	a0,s2
    80003ba8:	648000ef          	jal	800041f0 <initlog>
  ireclaim(dev);
    80003bac:	854a                	mv	a0,s2
    80003bae:	ee5ff0ef          	jal	80003a92 <ireclaim>
}
    80003bb2:	60e2                	ld	ra,24(sp)
    80003bb4:	6442                	ld	s0,16(sp)
    80003bb6:	64a2                	ld	s1,8(sp)
    80003bb8:	6902                	ld	s2,0(sp)
    80003bba:	6105                	addi	sp,sp,32
    80003bbc:	8082                	ret
    panic("invalid file system");
    80003bbe:	00005517          	auipc	a0,0x5
    80003bc2:	9da50513          	addi	a0,a0,-1574 # 80008598 <userret+0x14fc>
    80003bc6:	c91fc0ef          	jal	80000856 <panic>

0000000080003bca <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80003bca:	1141                	addi	sp,sp,-16
    80003bcc:	e406                	sd	ra,8(sp)
    80003bce:	e022                	sd	s0,0(sp)
    80003bd0:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80003bd2:	411c                	lw	a5,0(a0)
    80003bd4:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80003bd6:	415c                	lw	a5,4(a0)
    80003bd8:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80003bda:	04451783          	lh	a5,68(a0)
    80003bde:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80003be2:	04a51783          	lh	a5,74(a0)
    80003be6:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80003bea:	04c56783          	lwu	a5,76(a0)
    80003bee:	e99c                	sd	a5,16(a1)
}
    80003bf0:	60a2                	ld	ra,8(sp)
    80003bf2:	6402                	ld	s0,0(sp)
    80003bf4:	0141                	addi	sp,sp,16
    80003bf6:	8082                	ret

0000000080003bf8 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003bf8:	457c                	lw	a5,76(a0)
    80003bfa:	0ed7e663          	bltu	a5,a3,80003ce6 <readi+0xee>
{
    80003bfe:	7159                	addi	sp,sp,-112
    80003c00:	f486                	sd	ra,104(sp)
    80003c02:	f0a2                	sd	s0,96(sp)
    80003c04:	eca6                	sd	s1,88(sp)
    80003c06:	e0d2                	sd	s4,64(sp)
    80003c08:	fc56                	sd	s5,56(sp)
    80003c0a:	f85a                	sd	s6,48(sp)
    80003c0c:	f45e                	sd	s7,40(sp)
    80003c0e:	1880                	addi	s0,sp,112
    80003c10:	8b2a                	mv	s6,a0
    80003c12:	8bae                	mv	s7,a1
    80003c14:	8a32                	mv	s4,a2
    80003c16:	84b6                	mv	s1,a3
    80003c18:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    80003c1a:	9f35                	addw	a4,a4,a3
    return 0;
    80003c1c:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80003c1e:	0ad76b63          	bltu	a4,a3,80003cd4 <readi+0xdc>
    80003c22:	e4ce                	sd	s3,72(sp)
  if(off + n > ip->size)
    80003c24:	00e7f463          	bgeu	a5,a4,80003c2c <readi+0x34>
    n = ip->size - off;
    80003c28:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003c2c:	080a8b63          	beqz	s5,80003cc2 <readi+0xca>
    80003c30:	e8ca                	sd	s2,80(sp)
    80003c32:	f062                	sd	s8,32(sp)
    80003c34:	ec66                	sd	s9,24(sp)
    80003c36:	e86a                	sd	s10,16(sp)
    80003c38:	e46e                	sd	s11,8(sp)
    80003c3a:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003c3c:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80003c40:	5c7d                	li	s8,-1
    80003c42:	a80d                	j	80003c74 <readi+0x7c>
    80003c44:	020d1d93          	slli	s11,s10,0x20
    80003c48:	020ddd93          	srli	s11,s11,0x20
    80003c4c:	05890613          	addi	a2,s2,88
    80003c50:	86ee                	mv	a3,s11
    80003c52:	963e                	add	a2,a2,a5
    80003c54:	85d2                	mv	a1,s4
    80003c56:	855e                	mv	a0,s7
    80003c58:	bc1fe0ef          	jal	80002818 <either_copyout>
    80003c5c:	05850363          	beq	a0,s8,80003ca2 <readi+0xaa>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80003c60:	854a                	mv	a0,s2
    80003c62:	e5eff0ef          	jal	800032c0 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003c66:	013d09bb          	addw	s3,s10,s3
    80003c6a:	009d04bb          	addw	s1,s10,s1
    80003c6e:	9a6e                	add	s4,s4,s11
    80003c70:	0559f363          	bgeu	s3,s5,80003cb6 <readi+0xbe>
    uint addr = bmap(ip, off/BSIZE);
    80003c74:	00a4d59b          	srliw	a1,s1,0xa
    80003c78:	855a                	mv	a0,s6
    80003c7a:	8bbff0ef          	jal	80003534 <bmap>
    80003c7e:	85aa                	mv	a1,a0
    if(addr == 0)
    80003c80:	c139                	beqz	a0,80003cc6 <readi+0xce>
    bp = bread(ip->dev, addr);
    80003c82:	000b2503          	lw	a0,0(s6)
    80003c86:	d0aff0ef          	jal	80003190 <bread>
    80003c8a:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003c8c:	3ff4f793          	andi	a5,s1,1023
    80003c90:	40fc873b          	subw	a4,s9,a5
    80003c94:	413a86bb          	subw	a3,s5,s3
    80003c98:	8d3a                	mv	s10,a4
    80003c9a:	fae6f5e3          	bgeu	a3,a4,80003c44 <readi+0x4c>
    80003c9e:	8d36                	mv	s10,a3
    80003ca0:	b755                	j	80003c44 <readi+0x4c>
      brelse(bp);
    80003ca2:	854a                	mv	a0,s2
    80003ca4:	e1cff0ef          	jal	800032c0 <brelse>
      tot = -1;
    80003ca8:	59fd                	li	s3,-1
      break;
    80003caa:	6946                	ld	s2,80(sp)
    80003cac:	7c02                	ld	s8,32(sp)
    80003cae:	6ce2                	ld	s9,24(sp)
    80003cb0:	6d42                	ld	s10,16(sp)
    80003cb2:	6da2                	ld	s11,8(sp)
    80003cb4:	a831                	j	80003cd0 <readi+0xd8>
    80003cb6:	6946                	ld	s2,80(sp)
    80003cb8:	7c02                	ld	s8,32(sp)
    80003cba:	6ce2                	ld	s9,24(sp)
    80003cbc:	6d42                	ld	s10,16(sp)
    80003cbe:	6da2                	ld	s11,8(sp)
    80003cc0:	a801                	j	80003cd0 <readi+0xd8>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003cc2:	89d6                	mv	s3,s5
    80003cc4:	a031                	j	80003cd0 <readi+0xd8>
    80003cc6:	6946                	ld	s2,80(sp)
    80003cc8:	7c02                	ld	s8,32(sp)
    80003cca:	6ce2                	ld	s9,24(sp)
    80003ccc:	6d42                	ld	s10,16(sp)
    80003cce:	6da2                	ld	s11,8(sp)
  }
  return tot;
    80003cd0:	854e                	mv	a0,s3
    80003cd2:	69a6                	ld	s3,72(sp)
}
    80003cd4:	70a6                	ld	ra,104(sp)
    80003cd6:	7406                	ld	s0,96(sp)
    80003cd8:	64e6                	ld	s1,88(sp)
    80003cda:	6a06                	ld	s4,64(sp)
    80003cdc:	7ae2                	ld	s5,56(sp)
    80003cde:	7b42                	ld	s6,48(sp)
    80003ce0:	7ba2                	ld	s7,40(sp)
    80003ce2:	6165                	addi	sp,sp,112
    80003ce4:	8082                	ret
    return 0;
    80003ce6:	4501                	li	a0,0
}
    80003ce8:	8082                	ret

0000000080003cea <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003cea:	457c                	lw	a5,76(a0)
    80003cec:	0ed7eb63          	bltu	a5,a3,80003de2 <writei+0xf8>
{
    80003cf0:	7159                	addi	sp,sp,-112
    80003cf2:	f486                	sd	ra,104(sp)
    80003cf4:	f0a2                	sd	s0,96(sp)
    80003cf6:	e8ca                	sd	s2,80(sp)
    80003cf8:	e0d2                	sd	s4,64(sp)
    80003cfa:	fc56                	sd	s5,56(sp)
    80003cfc:	f85a                	sd	s6,48(sp)
    80003cfe:	f45e                	sd	s7,40(sp)
    80003d00:	1880                	addi	s0,sp,112
    80003d02:	8aaa                	mv	s5,a0
    80003d04:	8bae                	mv	s7,a1
    80003d06:	8a32                	mv	s4,a2
    80003d08:	8936                	mv	s2,a3
    80003d0a:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003d0c:	00e687bb          	addw	a5,a3,a4
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80003d10:	00043737          	lui	a4,0x43
    80003d14:	0cf76963          	bltu	a4,a5,80003de6 <writei+0xfc>
    80003d18:	0cd7e763          	bltu	a5,a3,80003de6 <writei+0xfc>
    80003d1c:	e4ce                	sd	s3,72(sp)
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003d1e:	0a0b0a63          	beqz	s6,80003dd2 <writei+0xe8>
    80003d22:	eca6                	sd	s1,88(sp)
    80003d24:	f062                	sd	s8,32(sp)
    80003d26:	ec66                	sd	s9,24(sp)
    80003d28:	e86a                	sd	s10,16(sp)
    80003d2a:	e46e                	sd	s11,8(sp)
    80003d2c:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003d2e:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80003d32:	5c7d                	li	s8,-1
    80003d34:	a825                	j	80003d6c <writei+0x82>
    80003d36:	020d1d93          	slli	s11,s10,0x20
    80003d3a:	020ddd93          	srli	s11,s11,0x20
    80003d3e:	05848513          	addi	a0,s1,88
    80003d42:	86ee                	mv	a3,s11
    80003d44:	8652                	mv	a2,s4
    80003d46:	85de                	mv	a1,s7
    80003d48:	953e                	add	a0,a0,a5
    80003d4a:	b19fe0ef          	jal	80002862 <either_copyin>
    80003d4e:	05850663          	beq	a0,s8,80003d9a <writei+0xb0>
      brelse(bp);
      break;
    }
    log_write(bp);
    80003d52:	8526                	mv	a0,s1
    80003d54:	6b8000ef          	jal	8000440c <log_write>
    brelse(bp);
    80003d58:	8526                	mv	a0,s1
    80003d5a:	d66ff0ef          	jal	800032c0 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003d5e:	013d09bb          	addw	s3,s10,s3
    80003d62:	012d093b          	addw	s2,s10,s2
    80003d66:	9a6e                	add	s4,s4,s11
    80003d68:	0369fc63          	bgeu	s3,s6,80003da0 <writei+0xb6>
    uint addr = bmap(ip, off/BSIZE);
    80003d6c:	00a9559b          	srliw	a1,s2,0xa
    80003d70:	8556                	mv	a0,s5
    80003d72:	fc2ff0ef          	jal	80003534 <bmap>
    80003d76:	85aa                	mv	a1,a0
    if(addr == 0)
    80003d78:	c505                	beqz	a0,80003da0 <writei+0xb6>
    bp = bread(ip->dev, addr);
    80003d7a:	000aa503          	lw	a0,0(s5)
    80003d7e:	c12ff0ef          	jal	80003190 <bread>
    80003d82:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003d84:	3ff97793          	andi	a5,s2,1023
    80003d88:	40fc873b          	subw	a4,s9,a5
    80003d8c:	413b06bb          	subw	a3,s6,s3
    80003d90:	8d3a                	mv	s10,a4
    80003d92:	fae6f2e3          	bgeu	a3,a4,80003d36 <writei+0x4c>
    80003d96:	8d36                	mv	s10,a3
    80003d98:	bf79                	j	80003d36 <writei+0x4c>
      brelse(bp);
    80003d9a:	8526                	mv	a0,s1
    80003d9c:	d24ff0ef          	jal	800032c0 <brelse>
  }

  if(off > ip->size)
    80003da0:	04caa783          	lw	a5,76(s5)
    80003da4:	0327f963          	bgeu	a5,s2,80003dd6 <writei+0xec>
    ip->size = off;
    80003da8:	052aa623          	sw	s2,76(s5)
    80003dac:	64e6                	ld	s1,88(sp)
    80003dae:	7c02                	ld	s8,32(sp)
    80003db0:	6ce2                	ld	s9,24(sp)
    80003db2:	6d42                	ld	s10,16(sp)
    80003db4:	6da2                	ld	s11,8(sp)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80003db6:	8556                	mv	a0,s5
    80003db8:	9fbff0ef          	jal	800037b2 <iupdate>

  return tot;
    80003dbc:	854e                	mv	a0,s3
    80003dbe:	69a6                	ld	s3,72(sp)
}
    80003dc0:	70a6                	ld	ra,104(sp)
    80003dc2:	7406                	ld	s0,96(sp)
    80003dc4:	6946                	ld	s2,80(sp)
    80003dc6:	6a06                	ld	s4,64(sp)
    80003dc8:	7ae2                	ld	s5,56(sp)
    80003dca:	7b42                	ld	s6,48(sp)
    80003dcc:	7ba2                	ld	s7,40(sp)
    80003dce:	6165                	addi	sp,sp,112
    80003dd0:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003dd2:	89da                	mv	s3,s6
    80003dd4:	b7cd                	j	80003db6 <writei+0xcc>
    80003dd6:	64e6                	ld	s1,88(sp)
    80003dd8:	7c02                	ld	s8,32(sp)
    80003dda:	6ce2                	ld	s9,24(sp)
    80003ddc:	6d42                	ld	s10,16(sp)
    80003dde:	6da2                	ld	s11,8(sp)
    80003de0:	bfd9                	j	80003db6 <writei+0xcc>
    return -1;
    80003de2:	557d                	li	a0,-1
}
    80003de4:	8082                	ret
    return -1;
    80003de6:	557d                	li	a0,-1
    80003de8:	bfe1                	j	80003dc0 <writei+0xd6>

0000000080003dea <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80003dea:	1141                	addi	sp,sp,-16
    80003dec:	e406                	sd	ra,8(sp)
    80003dee:	e022                	sd	s0,0(sp)
    80003df0:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80003df2:	4639                	li	a2,14
    80003df4:	8d2fd0ef          	jal	80000ec6 <strncmp>
}
    80003df8:	60a2                	ld	ra,8(sp)
    80003dfa:	6402                	ld	s0,0(sp)
    80003dfc:	0141                	addi	sp,sp,16
    80003dfe:	8082                	ret

0000000080003e00 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80003e00:	711d                	addi	sp,sp,-96
    80003e02:	ec86                	sd	ra,88(sp)
    80003e04:	e8a2                	sd	s0,80(sp)
    80003e06:	e4a6                	sd	s1,72(sp)
    80003e08:	e0ca                	sd	s2,64(sp)
    80003e0a:	fc4e                	sd	s3,56(sp)
    80003e0c:	f852                	sd	s4,48(sp)
    80003e0e:	f456                	sd	s5,40(sp)
    80003e10:	f05a                	sd	s6,32(sp)
    80003e12:	ec5e                	sd	s7,24(sp)
    80003e14:	1080                	addi	s0,sp,96
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80003e16:	04451703          	lh	a4,68(a0)
    80003e1a:	4785                	li	a5,1
    80003e1c:	00f71f63          	bne	a4,a5,80003e3a <dirlookup+0x3a>
    80003e20:	892a                	mv	s2,a0
    80003e22:	8aae                	mv	s5,a1
    80003e24:	8bb2                	mv	s7,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80003e26:	457c                	lw	a5,76(a0)
    80003e28:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003e2a:	fa040a13          	addi	s4,s0,-96
    80003e2e:	49c1                	li	s3,16
      panic("dirlookup read");
    if(de.inum == 0)
      continue;
    if(namecmp(name, de.name) == 0){
    80003e30:	fa240b13          	addi	s6,s0,-94
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80003e34:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003e36:	e39d                	bnez	a5,80003e5c <dirlookup+0x5c>
    80003e38:	a8b9                	j	80003e96 <dirlookup+0x96>
    panic("dirlookup not DIR");
    80003e3a:	00004517          	auipc	a0,0x4
    80003e3e:	77650513          	addi	a0,a0,1910 # 800085b0 <userret+0x1514>
    80003e42:	a15fc0ef          	jal	80000856 <panic>
      panic("dirlookup read");
    80003e46:	00004517          	auipc	a0,0x4
    80003e4a:	78250513          	addi	a0,a0,1922 # 800085c8 <userret+0x152c>
    80003e4e:	a09fc0ef          	jal	80000856 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003e52:	24c1                	addiw	s1,s1,16
    80003e54:	04c92783          	lw	a5,76(s2)
    80003e58:	02f4fe63          	bgeu	s1,a5,80003e94 <dirlookup+0x94>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003e5c:	874e                	mv	a4,s3
    80003e5e:	86a6                	mv	a3,s1
    80003e60:	8652                	mv	a2,s4
    80003e62:	4581                	li	a1,0
    80003e64:	854a                	mv	a0,s2
    80003e66:	d93ff0ef          	jal	80003bf8 <readi>
    80003e6a:	fd351ee3          	bne	a0,s3,80003e46 <dirlookup+0x46>
    if(de.inum == 0)
    80003e6e:	fa045783          	lhu	a5,-96(s0)
    80003e72:	d3e5                	beqz	a5,80003e52 <dirlookup+0x52>
    if(namecmp(name, de.name) == 0){
    80003e74:	85da                	mv	a1,s6
    80003e76:	8556                	mv	a0,s5
    80003e78:	f73ff0ef          	jal	80003dea <namecmp>
    80003e7c:	f979                	bnez	a0,80003e52 <dirlookup+0x52>
      if(poff)
    80003e7e:	000b8463          	beqz	s7,80003e86 <dirlookup+0x86>
        *poff = off;
    80003e82:	009ba023          	sw	s1,0(s7)
      return iget(dp->dev, inum);
    80003e86:	fa045583          	lhu	a1,-96(s0)
    80003e8a:	00092503          	lw	a0,0(s2)
    80003e8e:	f66ff0ef          	jal	800035f4 <iget>
    80003e92:	a011                	j	80003e96 <dirlookup+0x96>
  return 0;
    80003e94:	4501                	li	a0,0
}
    80003e96:	60e6                	ld	ra,88(sp)
    80003e98:	6446                	ld	s0,80(sp)
    80003e9a:	64a6                	ld	s1,72(sp)
    80003e9c:	6906                	ld	s2,64(sp)
    80003e9e:	79e2                	ld	s3,56(sp)
    80003ea0:	7a42                	ld	s4,48(sp)
    80003ea2:	7aa2                	ld	s5,40(sp)
    80003ea4:	7b02                	ld	s6,32(sp)
    80003ea6:	6be2                	ld	s7,24(sp)
    80003ea8:	6125                	addi	sp,sp,96
    80003eaa:	8082                	ret

0000000080003eac <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80003eac:	711d                	addi	sp,sp,-96
    80003eae:	ec86                	sd	ra,88(sp)
    80003eb0:	e8a2                	sd	s0,80(sp)
    80003eb2:	e4a6                	sd	s1,72(sp)
    80003eb4:	e0ca                	sd	s2,64(sp)
    80003eb6:	fc4e                	sd	s3,56(sp)
    80003eb8:	f852                	sd	s4,48(sp)
    80003eba:	f456                	sd	s5,40(sp)
    80003ebc:	f05a                	sd	s6,32(sp)
    80003ebe:	ec5e                	sd	s7,24(sp)
    80003ec0:	e862                	sd	s8,16(sp)
    80003ec2:	e466                	sd	s9,8(sp)
    80003ec4:	e06a                	sd	s10,0(sp)
    80003ec6:	1080                	addi	s0,sp,96
    80003ec8:	84aa                	mv	s1,a0
    80003eca:	8b2e                	mv	s6,a1
    80003ecc:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    80003ece:	00054703          	lbu	a4,0(a0)
    80003ed2:	02f00793          	li	a5,47
    80003ed6:	00f70f63          	beq	a4,a5,80003ef4 <namex+0x48>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80003eda:	db9fd0ef          	jal	80001c92 <myproc>
    80003ede:	15053503          	ld	a0,336(a0)
    80003ee2:	94fff0ef          	jal	80003830 <idup>
    80003ee6:	8a2a                	mv	s4,a0
  while(*path == '/')
    80003ee8:	02f00993          	li	s3,47
  if(len >= DIRSIZ)
    80003eec:	4c35                	li	s8,13
    memmove(name, s, DIRSIZ);
    80003eee:	4cb9                	li	s9,14

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80003ef0:	4b85                	li	s7,1
    80003ef2:	a879                	j	80003f90 <namex+0xe4>
    ip = iget(ROOTDEV, ROOTINO);
    80003ef4:	4585                	li	a1,1
    80003ef6:	852e                	mv	a0,a1
    80003ef8:	efcff0ef          	jal	800035f4 <iget>
    80003efc:	8a2a                	mv	s4,a0
    80003efe:	b7ed                	j	80003ee8 <namex+0x3c>
      iunlockput(ip);
    80003f00:	8552                	mv	a0,s4
    80003f02:	b71ff0ef          	jal	80003a72 <iunlockput>
      return 0;
    80003f06:	4a01                	li	s4,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80003f08:	8552                	mv	a0,s4
    80003f0a:	60e6                	ld	ra,88(sp)
    80003f0c:	6446                	ld	s0,80(sp)
    80003f0e:	64a6                	ld	s1,72(sp)
    80003f10:	6906                	ld	s2,64(sp)
    80003f12:	79e2                	ld	s3,56(sp)
    80003f14:	7a42                	ld	s4,48(sp)
    80003f16:	7aa2                	ld	s5,40(sp)
    80003f18:	7b02                	ld	s6,32(sp)
    80003f1a:	6be2                	ld	s7,24(sp)
    80003f1c:	6c42                	ld	s8,16(sp)
    80003f1e:	6ca2                	ld	s9,8(sp)
    80003f20:	6d02                	ld	s10,0(sp)
    80003f22:	6125                	addi	sp,sp,96
    80003f24:	8082                	ret
      iunlock(ip);
    80003f26:	8552                	mv	a0,s4
    80003f28:	9edff0ef          	jal	80003914 <iunlock>
      return ip;
    80003f2c:	bff1                	j	80003f08 <namex+0x5c>
      iunlockput(ip);
    80003f2e:	8552                	mv	a0,s4
    80003f30:	b43ff0ef          	jal	80003a72 <iunlockput>
      return 0;
    80003f34:	8a4a                	mv	s4,s2
    80003f36:	bfc9                	j	80003f08 <namex+0x5c>
  len = path - s;
    80003f38:	40990633          	sub	a2,s2,s1
    80003f3c:	00060d1b          	sext.w	s10,a2
  if(len >= DIRSIZ)
    80003f40:	09ac5463          	bge	s8,s10,80003fc8 <namex+0x11c>
    memmove(name, s, DIRSIZ);
    80003f44:	8666                	mv	a2,s9
    80003f46:	85a6                	mv	a1,s1
    80003f48:	8556                	mv	a0,s5
    80003f4a:	f09fc0ef          	jal	80000e52 <memmove>
    80003f4e:	84ca                	mv	s1,s2
  while(*path == '/')
    80003f50:	0004c783          	lbu	a5,0(s1)
    80003f54:	01379763          	bne	a5,s3,80003f62 <namex+0xb6>
    path++;
    80003f58:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003f5a:	0004c783          	lbu	a5,0(s1)
    80003f5e:	ff378de3          	beq	a5,s3,80003f58 <namex+0xac>
    ilock(ip);
    80003f62:	8552                	mv	a0,s4
    80003f64:	903ff0ef          	jal	80003866 <ilock>
    if(ip->type != T_DIR){
    80003f68:	044a1783          	lh	a5,68(s4)
    80003f6c:	f9779ae3          	bne	a5,s7,80003f00 <namex+0x54>
    if(nameiparent && *path == '\0'){
    80003f70:	000b0563          	beqz	s6,80003f7a <namex+0xce>
    80003f74:	0004c783          	lbu	a5,0(s1)
    80003f78:	d7dd                	beqz	a5,80003f26 <namex+0x7a>
    if((next = dirlookup(ip, name, 0)) == 0){
    80003f7a:	4601                	li	a2,0
    80003f7c:	85d6                	mv	a1,s5
    80003f7e:	8552                	mv	a0,s4
    80003f80:	e81ff0ef          	jal	80003e00 <dirlookup>
    80003f84:	892a                	mv	s2,a0
    80003f86:	d545                	beqz	a0,80003f2e <namex+0x82>
    iunlockput(ip);
    80003f88:	8552                	mv	a0,s4
    80003f8a:	ae9ff0ef          	jal	80003a72 <iunlockput>
    ip = next;
    80003f8e:	8a4a                	mv	s4,s2
  while(*path == '/')
    80003f90:	0004c783          	lbu	a5,0(s1)
    80003f94:	01379763          	bne	a5,s3,80003fa2 <namex+0xf6>
    path++;
    80003f98:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003f9a:	0004c783          	lbu	a5,0(s1)
    80003f9e:	ff378de3          	beq	a5,s3,80003f98 <namex+0xec>
  if(*path == 0)
    80003fa2:	cf8d                	beqz	a5,80003fdc <namex+0x130>
  while(*path != '/' && *path != 0)
    80003fa4:	0004c783          	lbu	a5,0(s1)
    80003fa8:	fd178713          	addi	a4,a5,-47
    80003fac:	cb19                	beqz	a4,80003fc2 <namex+0x116>
    80003fae:	cb91                	beqz	a5,80003fc2 <namex+0x116>
    80003fb0:	8926                	mv	s2,s1
    path++;
    80003fb2:	0905                	addi	s2,s2,1
  while(*path != '/' && *path != 0)
    80003fb4:	00094783          	lbu	a5,0(s2)
    80003fb8:	fd178713          	addi	a4,a5,-47
    80003fbc:	df35                	beqz	a4,80003f38 <namex+0x8c>
    80003fbe:	fbf5                	bnez	a5,80003fb2 <namex+0x106>
    80003fc0:	bfa5                	j	80003f38 <namex+0x8c>
    80003fc2:	8926                	mv	s2,s1
  len = path - s;
    80003fc4:	4d01                	li	s10,0
    80003fc6:	4601                	li	a2,0
    memmove(name, s, len);
    80003fc8:	2601                	sext.w	a2,a2
    80003fca:	85a6                	mv	a1,s1
    80003fcc:	8556                	mv	a0,s5
    80003fce:	e85fc0ef          	jal	80000e52 <memmove>
    name[len] = 0;
    80003fd2:	9d56                	add	s10,s10,s5
    80003fd4:	000d0023          	sb	zero,0(s10) # fffffffffffff000 <end+0xffffffff7ffb6c08>
    80003fd8:	84ca                	mv	s1,s2
    80003fda:	bf9d                	j	80003f50 <namex+0xa4>
  if(nameiparent){
    80003fdc:	f20b06e3          	beqz	s6,80003f08 <namex+0x5c>
    iput(ip);
    80003fe0:	8552                	mv	a0,s4
    80003fe2:	a07ff0ef          	jal	800039e8 <iput>
    return 0;
    80003fe6:	4a01                	li	s4,0
    80003fe8:	b705                	j	80003f08 <namex+0x5c>

0000000080003fea <dirlink>:
{
    80003fea:	715d                	addi	sp,sp,-80
    80003fec:	e486                	sd	ra,72(sp)
    80003fee:	e0a2                	sd	s0,64(sp)
    80003ff0:	f84a                	sd	s2,48(sp)
    80003ff2:	ec56                	sd	s5,24(sp)
    80003ff4:	e85a                	sd	s6,16(sp)
    80003ff6:	0880                	addi	s0,sp,80
    80003ff8:	892a                	mv	s2,a0
    80003ffa:	8aae                	mv	s5,a1
    80003ffc:	8b32                	mv	s6,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80003ffe:	4601                	li	a2,0
    80004000:	e01ff0ef          	jal	80003e00 <dirlookup>
    80004004:	ed1d                	bnez	a0,80004042 <dirlink+0x58>
    80004006:	fc26                	sd	s1,56(sp)
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004008:	04c92483          	lw	s1,76(s2)
    8000400c:	c4b9                	beqz	s1,8000405a <dirlink+0x70>
    8000400e:	f44e                	sd	s3,40(sp)
    80004010:	f052                	sd	s4,32(sp)
    80004012:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004014:	fb040a13          	addi	s4,s0,-80
    80004018:	49c1                	li	s3,16
    8000401a:	874e                	mv	a4,s3
    8000401c:	86a6                	mv	a3,s1
    8000401e:	8652                	mv	a2,s4
    80004020:	4581                	li	a1,0
    80004022:	854a                	mv	a0,s2
    80004024:	bd5ff0ef          	jal	80003bf8 <readi>
    80004028:	03351163          	bne	a0,s3,8000404a <dirlink+0x60>
    if(de.inum == 0)
    8000402c:	fb045783          	lhu	a5,-80(s0)
    80004030:	c39d                	beqz	a5,80004056 <dirlink+0x6c>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004032:	24c1                	addiw	s1,s1,16
    80004034:	04c92783          	lw	a5,76(s2)
    80004038:	fef4e1e3          	bltu	s1,a5,8000401a <dirlink+0x30>
    8000403c:	79a2                	ld	s3,40(sp)
    8000403e:	7a02                	ld	s4,32(sp)
    80004040:	a829                	j	8000405a <dirlink+0x70>
    iput(ip);
    80004042:	9a7ff0ef          	jal	800039e8 <iput>
    return -1;
    80004046:	557d                	li	a0,-1
    80004048:	a83d                	j	80004086 <dirlink+0x9c>
      panic("dirlink read");
    8000404a:	00004517          	auipc	a0,0x4
    8000404e:	58e50513          	addi	a0,a0,1422 # 800085d8 <userret+0x153c>
    80004052:	805fc0ef          	jal	80000856 <panic>
    80004056:	79a2                	ld	s3,40(sp)
    80004058:	7a02                	ld	s4,32(sp)
  strncpy(de.name, name, DIRSIZ);
    8000405a:	4639                	li	a2,14
    8000405c:	85d6                	mv	a1,s5
    8000405e:	fb240513          	addi	a0,s0,-78
    80004062:	e9ffc0ef          	jal	80000f00 <strncpy>
  de.inum = inum;
    80004066:	fb641823          	sh	s6,-80(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000406a:	4741                	li	a4,16
    8000406c:	86a6                	mv	a3,s1
    8000406e:	fb040613          	addi	a2,s0,-80
    80004072:	4581                	li	a1,0
    80004074:	854a                	mv	a0,s2
    80004076:	c75ff0ef          	jal	80003cea <writei>
    8000407a:	1541                	addi	a0,a0,-16
    8000407c:	00a03533          	snez	a0,a0
    80004080:	40a0053b          	negw	a0,a0
    80004084:	74e2                	ld	s1,56(sp)
}
    80004086:	60a6                	ld	ra,72(sp)
    80004088:	6406                	ld	s0,64(sp)
    8000408a:	7942                	ld	s2,48(sp)
    8000408c:	6ae2                	ld	s5,24(sp)
    8000408e:	6b42                	ld	s6,16(sp)
    80004090:	6161                	addi	sp,sp,80
    80004092:	8082                	ret

0000000080004094 <namei>:

struct inode*
namei(char *path)
{
    80004094:	1101                	addi	sp,sp,-32
    80004096:	ec06                	sd	ra,24(sp)
    80004098:	e822                	sd	s0,16(sp)
    8000409a:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    8000409c:	fe040613          	addi	a2,s0,-32
    800040a0:	4581                	li	a1,0
    800040a2:	e0bff0ef          	jal	80003eac <namex>
}
    800040a6:	60e2                	ld	ra,24(sp)
    800040a8:	6442                	ld	s0,16(sp)
    800040aa:	6105                	addi	sp,sp,32
    800040ac:	8082                	ret

00000000800040ae <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    800040ae:	1141                	addi	sp,sp,-16
    800040b0:	e406                	sd	ra,8(sp)
    800040b2:	e022                	sd	s0,0(sp)
    800040b4:	0800                	addi	s0,sp,16
    800040b6:	862e                	mv	a2,a1
  return namex(path, 1, name);
    800040b8:	4585                	li	a1,1
    800040ba:	df3ff0ef          	jal	80003eac <namex>
}
    800040be:	60a2                	ld	ra,8(sp)
    800040c0:	6402                	ld	s0,0(sp)
    800040c2:	0141                	addi	sp,sp,16
    800040c4:	8082                	ret

00000000800040c6 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    800040c6:	1101                	addi	sp,sp,-32
    800040c8:	ec06                	sd	ra,24(sp)
    800040ca:	e822                	sd	s0,16(sp)
    800040cc:	e426                	sd	s1,8(sp)
    800040ce:	e04a                	sd	s2,0(sp)
    800040d0:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    800040d2:	0001e917          	auipc	s2,0x1e
    800040d6:	03e90913          	addi	s2,s2,62 # 80022110 <log>
    800040da:	01892583          	lw	a1,24(s2)
    800040de:	02492503          	lw	a0,36(s2)
    800040e2:	8aeff0ef          	jal	80003190 <bread>
    800040e6:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    800040e8:	02892603          	lw	a2,40(s2)
    800040ec:	cd30                	sw	a2,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    800040ee:	00c05f63          	blez	a2,8000410c <write_head+0x46>
    800040f2:	0001e717          	auipc	a4,0x1e
    800040f6:	04a70713          	addi	a4,a4,74 # 8002213c <log+0x2c>
    800040fa:	87aa                	mv	a5,a0
    800040fc:	060a                	slli	a2,a2,0x2
    800040fe:	962a                	add	a2,a2,a0
    hb->block[i] = log.lh.block[i];
    80004100:	4314                	lw	a3,0(a4)
    80004102:	cff4                	sw	a3,92(a5)
  for (i = 0; i < log.lh.n; i++) {
    80004104:	0711                	addi	a4,a4,4
    80004106:	0791                	addi	a5,a5,4
    80004108:	fec79ce3          	bne	a5,a2,80004100 <write_head+0x3a>
  }
  bwrite(buf);
    8000410c:	8526                	mv	a0,s1
    8000410e:	980ff0ef          	jal	8000328e <bwrite>
  brelse(buf);
    80004112:	8526                	mv	a0,s1
    80004114:	9acff0ef          	jal	800032c0 <brelse>
}
    80004118:	60e2                	ld	ra,24(sp)
    8000411a:	6442                	ld	s0,16(sp)
    8000411c:	64a2                	ld	s1,8(sp)
    8000411e:	6902                	ld	s2,0(sp)
    80004120:	6105                	addi	sp,sp,32
    80004122:	8082                	ret

0000000080004124 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80004124:	0001e797          	auipc	a5,0x1e
    80004128:	0147a783          	lw	a5,20(a5) # 80022138 <log+0x28>
    8000412c:	0cf05163          	blez	a5,800041ee <install_trans+0xca>
{
    80004130:	715d                	addi	sp,sp,-80
    80004132:	e486                	sd	ra,72(sp)
    80004134:	e0a2                	sd	s0,64(sp)
    80004136:	fc26                	sd	s1,56(sp)
    80004138:	f84a                	sd	s2,48(sp)
    8000413a:	f44e                	sd	s3,40(sp)
    8000413c:	f052                	sd	s4,32(sp)
    8000413e:	ec56                	sd	s5,24(sp)
    80004140:	e85a                	sd	s6,16(sp)
    80004142:	e45e                	sd	s7,8(sp)
    80004144:	e062                	sd	s8,0(sp)
    80004146:	0880                	addi	s0,sp,80
    80004148:	8b2a                	mv	s6,a0
    8000414a:	0001ea97          	auipc	s5,0x1e
    8000414e:	ff2a8a93          	addi	s5,s5,-14 # 8002213c <log+0x2c>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004152:	4981                	li	s3,0
      printf("recovering tail %d dst %d\n", tail, log.lh.block[tail]);
    80004154:	00004c17          	auipc	s8,0x4
    80004158:	494c0c13          	addi	s8,s8,1172 # 800085e8 <userret+0x154c>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    8000415c:	0001ea17          	auipc	s4,0x1e
    80004160:	fb4a0a13          	addi	s4,s4,-76 # 80022110 <log>
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80004164:	40000b93          	li	s7,1024
    80004168:	a025                	j	80004190 <install_trans+0x6c>
      printf("recovering tail %d dst %d\n", tail, log.lh.block[tail]);
    8000416a:	000aa603          	lw	a2,0(s5)
    8000416e:	85ce                	mv	a1,s3
    80004170:	8562                	mv	a0,s8
    80004172:	bbafc0ef          	jal	8000052c <printf>
    80004176:	a839                	j	80004194 <install_trans+0x70>
    brelse(lbuf);
    80004178:	854a                	mv	a0,s2
    8000417a:	946ff0ef          	jal	800032c0 <brelse>
    brelse(dbuf);
    8000417e:	8526                	mv	a0,s1
    80004180:	940ff0ef          	jal	800032c0 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004184:	2985                	addiw	s3,s3,1
    80004186:	0a91                	addi	s5,s5,4
    80004188:	028a2783          	lw	a5,40(s4)
    8000418c:	04f9d563          	bge	s3,a5,800041d6 <install_trans+0xb2>
    if(recovering) {
    80004190:	fc0b1de3          	bnez	s6,8000416a <install_trans+0x46>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80004194:	018a2583          	lw	a1,24(s4)
    80004198:	013585bb          	addw	a1,a1,s3
    8000419c:	2585                	addiw	a1,a1,1
    8000419e:	024a2503          	lw	a0,36(s4)
    800041a2:	feffe0ef          	jal	80003190 <bread>
    800041a6:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    800041a8:	000aa583          	lw	a1,0(s5)
    800041ac:	024a2503          	lw	a0,36(s4)
    800041b0:	fe1fe0ef          	jal	80003190 <bread>
    800041b4:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    800041b6:	865e                	mv	a2,s7
    800041b8:	05890593          	addi	a1,s2,88
    800041bc:	05850513          	addi	a0,a0,88
    800041c0:	c93fc0ef          	jal	80000e52 <memmove>
    bwrite(dbuf);  // write dst to disk
    800041c4:	8526                	mv	a0,s1
    800041c6:	8c8ff0ef          	jal	8000328e <bwrite>
    if(recovering == 0)
    800041ca:	fa0b17e3          	bnez	s6,80004178 <install_trans+0x54>
      bunpin(dbuf);
    800041ce:	8526                	mv	a0,s1
    800041d0:	9beff0ef          	jal	8000338e <bunpin>
    800041d4:	b755                	j	80004178 <install_trans+0x54>
}
    800041d6:	60a6                	ld	ra,72(sp)
    800041d8:	6406                	ld	s0,64(sp)
    800041da:	74e2                	ld	s1,56(sp)
    800041dc:	7942                	ld	s2,48(sp)
    800041de:	79a2                	ld	s3,40(sp)
    800041e0:	7a02                	ld	s4,32(sp)
    800041e2:	6ae2                	ld	s5,24(sp)
    800041e4:	6b42                	ld	s6,16(sp)
    800041e6:	6ba2                	ld	s7,8(sp)
    800041e8:	6c02                	ld	s8,0(sp)
    800041ea:	6161                	addi	sp,sp,80
    800041ec:	8082                	ret
    800041ee:	8082                	ret

00000000800041f0 <initlog>:
{
    800041f0:	7179                	addi	sp,sp,-48
    800041f2:	f406                	sd	ra,40(sp)
    800041f4:	f022                	sd	s0,32(sp)
    800041f6:	ec26                	sd	s1,24(sp)
    800041f8:	e84a                	sd	s2,16(sp)
    800041fa:	e44e                	sd	s3,8(sp)
    800041fc:	1800                	addi	s0,sp,48
    800041fe:	84aa                	mv	s1,a0
    80004200:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    80004202:	0001e917          	auipc	s2,0x1e
    80004206:	f0e90913          	addi	s2,s2,-242 # 80022110 <log>
    8000420a:	00004597          	auipc	a1,0x4
    8000420e:	3fe58593          	addi	a1,a1,1022 # 80008608 <userret+0x156c>
    80004212:	854a                	mv	a0,s2
    80004214:	a85fc0ef          	jal	80000c98 <initlock>
  log.start = sb->logstart;
    80004218:	0149a583          	lw	a1,20(s3)
    8000421c:	00b92c23          	sw	a1,24(s2)
  log.dev = dev;
    80004220:	02992223          	sw	s1,36(s2)
  struct buf *buf = bread(log.dev, log.start);
    80004224:	8526                	mv	a0,s1
    80004226:	f6bfe0ef          	jal	80003190 <bread>
  log.lh.n = lh->n;
    8000422a:	4d30                	lw	a2,88(a0)
    8000422c:	02c92423          	sw	a2,40(s2)
  for (i = 0; i < log.lh.n; i++) {
    80004230:	00c05f63          	blez	a2,8000424e <initlog+0x5e>
    80004234:	87aa                	mv	a5,a0
    80004236:	0001e717          	auipc	a4,0x1e
    8000423a:	f0670713          	addi	a4,a4,-250 # 8002213c <log+0x2c>
    8000423e:	060a                	slli	a2,a2,0x2
    80004240:	962a                	add	a2,a2,a0
    log.lh.block[i] = lh->block[i];
    80004242:	4ff4                	lw	a3,92(a5)
    80004244:	c314                	sw	a3,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80004246:	0791                	addi	a5,a5,4
    80004248:	0711                	addi	a4,a4,4
    8000424a:	fec79ce3          	bne	a5,a2,80004242 <initlog+0x52>
  brelse(buf);
    8000424e:	872ff0ef          	jal	800032c0 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    80004252:	4505                	li	a0,1
    80004254:	ed1ff0ef          	jal	80004124 <install_trans>
  log.lh.n = 0;
    80004258:	0001e797          	auipc	a5,0x1e
    8000425c:	ee07a023          	sw	zero,-288(a5) # 80022138 <log+0x28>
  write_head(); // clear the log
    80004260:	e67ff0ef          	jal	800040c6 <write_head>
}
    80004264:	70a2                	ld	ra,40(sp)
    80004266:	7402                	ld	s0,32(sp)
    80004268:	64e2                	ld	s1,24(sp)
    8000426a:	6942                	ld	s2,16(sp)
    8000426c:	69a2                	ld	s3,8(sp)
    8000426e:	6145                	addi	sp,sp,48
    80004270:	8082                	ret

0000000080004272 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    80004272:	1101                	addi	sp,sp,-32
    80004274:	ec06                	sd	ra,24(sp)
    80004276:	e822                	sd	s0,16(sp)
    80004278:	e426                	sd	s1,8(sp)
    8000427a:	e04a                	sd	s2,0(sp)
    8000427c:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    8000427e:	0001e517          	auipc	a0,0x1e
    80004282:	e9250513          	addi	a0,a0,-366 # 80022110 <log>
    80004286:	a9dfc0ef          	jal	80000d22 <acquire>
  while(1){
    if(log.committing){
    8000428a:	0001e497          	auipc	s1,0x1e
    8000428e:	e8648493          	addi	s1,s1,-378 # 80022110 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGBLOCKS){
    80004292:	4979                	li	s2,30
    80004294:	a029                	j	8000429e <begin_op+0x2c>
      sleep(&log, &log.lock);
    80004296:	85a6                	mv	a1,s1
    80004298:	8526                	mv	a0,s1
    8000429a:	a24fe0ef          	jal	800024be <sleep>
    if(log.committing){
    8000429e:	509c                	lw	a5,32(s1)
    800042a0:	fbfd                	bnez	a5,80004296 <begin_op+0x24>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGBLOCKS){
    800042a2:	4cd8                	lw	a4,28(s1)
    800042a4:	2705                	addiw	a4,a4,1
    800042a6:	0027179b          	slliw	a5,a4,0x2
    800042aa:	9fb9                	addw	a5,a5,a4
    800042ac:	0017979b          	slliw	a5,a5,0x1
    800042b0:	5494                	lw	a3,40(s1)
    800042b2:	9fb5                	addw	a5,a5,a3
    800042b4:	00f95763          	bge	s2,a5,800042c2 <begin_op+0x50>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    800042b8:	85a6                	mv	a1,s1
    800042ba:	8526                	mv	a0,s1
    800042bc:	a02fe0ef          	jal	800024be <sleep>
    800042c0:	bff9                	j	8000429e <begin_op+0x2c>
    } else {
      log.outstanding += 1;
    800042c2:	0001e797          	auipc	a5,0x1e
    800042c6:	e6e7a523          	sw	a4,-406(a5) # 8002212c <log+0x1c>
      release(&log.lock);
    800042ca:	0001e517          	auipc	a0,0x1e
    800042ce:	e4650513          	addi	a0,a0,-442 # 80022110 <log>
    800042d2:	ae5fc0ef          	jal	80000db6 <release>
      break;
    }
  }
}
    800042d6:	60e2                	ld	ra,24(sp)
    800042d8:	6442                	ld	s0,16(sp)
    800042da:	64a2                	ld	s1,8(sp)
    800042dc:	6902                	ld	s2,0(sp)
    800042de:	6105                	addi	sp,sp,32
    800042e0:	8082                	ret

00000000800042e2 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    800042e2:	7139                	addi	sp,sp,-64
    800042e4:	fc06                	sd	ra,56(sp)
    800042e6:	f822                	sd	s0,48(sp)
    800042e8:	f426                	sd	s1,40(sp)
    800042ea:	f04a                	sd	s2,32(sp)
    800042ec:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    800042ee:	0001e497          	auipc	s1,0x1e
    800042f2:	e2248493          	addi	s1,s1,-478 # 80022110 <log>
    800042f6:	8526                	mv	a0,s1
    800042f8:	a2bfc0ef          	jal	80000d22 <acquire>
  log.outstanding -= 1;
    800042fc:	4cdc                	lw	a5,28(s1)
    800042fe:	37fd                	addiw	a5,a5,-1
    80004300:	893e                	mv	s2,a5
    80004302:	ccdc                	sw	a5,28(s1)
  if(log.committing)
    80004304:	509c                	lw	a5,32(s1)
    80004306:	e7b1                	bnez	a5,80004352 <end_op+0x70>
    panic("log.committing");
  if(log.outstanding == 0){
    80004308:	04091e63          	bnez	s2,80004364 <end_op+0x82>
    do_commit = 1;
    log.committing = 1;
    8000430c:	0001e497          	auipc	s1,0x1e
    80004310:	e0448493          	addi	s1,s1,-508 # 80022110 <log>
    80004314:	4785                	li	a5,1
    80004316:	d09c                	sw	a5,32(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    80004318:	8526                	mv	a0,s1
    8000431a:	a9dfc0ef          	jal	80000db6 <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    8000431e:	549c                	lw	a5,40(s1)
    80004320:	06f04463          	bgtz	a5,80004388 <end_op+0xa6>
    acquire(&log.lock);
    80004324:	0001e517          	auipc	a0,0x1e
    80004328:	dec50513          	addi	a0,a0,-532 # 80022110 <log>
    8000432c:	9f7fc0ef          	jal	80000d22 <acquire>
    log.committing = 0;
    80004330:	0001e797          	auipc	a5,0x1e
    80004334:	e007a023          	sw	zero,-512(a5) # 80022130 <log+0x20>
    wakeup(&log);
    80004338:	0001e517          	auipc	a0,0x1e
    8000433c:	dd850513          	addi	a0,a0,-552 # 80022110 <log>
    80004340:	9cafe0ef          	jal	8000250a <wakeup>
    release(&log.lock);
    80004344:	0001e517          	auipc	a0,0x1e
    80004348:	dcc50513          	addi	a0,a0,-564 # 80022110 <log>
    8000434c:	a6bfc0ef          	jal	80000db6 <release>
}
    80004350:	a035                	j	8000437c <end_op+0x9a>
    80004352:	ec4e                	sd	s3,24(sp)
    80004354:	e852                	sd	s4,16(sp)
    80004356:	e456                	sd	s5,8(sp)
    panic("log.committing");
    80004358:	00004517          	auipc	a0,0x4
    8000435c:	2b850513          	addi	a0,a0,696 # 80008610 <userret+0x1574>
    80004360:	cf6fc0ef          	jal	80000856 <panic>
    wakeup(&log);
    80004364:	0001e517          	auipc	a0,0x1e
    80004368:	dac50513          	addi	a0,a0,-596 # 80022110 <log>
    8000436c:	99efe0ef          	jal	8000250a <wakeup>
  release(&log.lock);
    80004370:	0001e517          	auipc	a0,0x1e
    80004374:	da050513          	addi	a0,a0,-608 # 80022110 <log>
    80004378:	a3ffc0ef          	jal	80000db6 <release>
}
    8000437c:	70e2                	ld	ra,56(sp)
    8000437e:	7442                	ld	s0,48(sp)
    80004380:	74a2                	ld	s1,40(sp)
    80004382:	7902                	ld	s2,32(sp)
    80004384:	6121                	addi	sp,sp,64
    80004386:	8082                	ret
    80004388:	ec4e                	sd	s3,24(sp)
    8000438a:	e852                	sd	s4,16(sp)
    8000438c:	e456                	sd	s5,8(sp)
  for (tail = 0; tail < log.lh.n; tail++) {
    8000438e:	0001ea97          	auipc	s5,0x1e
    80004392:	daea8a93          	addi	s5,s5,-594 # 8002213c <log+0x2c>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    80004396:	0001ea17          	auipc	s4,0x1e
    8000439a:	d7aa0a13          	addi	s4,s4,-646 # 80022110 <log>
    8000439e:	018a2583          	lw	a1,24(s4)
    800043a2:	012585bb          	addw	a1,a1,s2
    800043a6:	2585                	addiw	a1,a1,1
    800043a8:	024a2503          	lw	a0,36(s4)
    800043ac:	de5fe0ef          	jal	80003190 <bread>
    800043b0:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    800043b2:	000aa583          	lw	a1,0(s5)
    800043b6:	024a2503          	lw	a0,36(s4)
    800043ba:	dd7fe0ef          	jal	80003190 <bread>
    800043be:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    800043c0:	40000613          	li	a2,1024
    800043c4:	05850593          	addi	a1,a0,88
    800043c8:	05848513          	addi	a0,s1,88
    800043cc:	a87fc0ef          	jal	80000e52 <memmove>
    bwrite(to);  // write the log
    800043d0:	8526                	mv	a0,s1
    800043d2:	ebdfe0ef          	jal	8000328e <bwrite>
    brelse(from);
    800043d6:	854e                	mv	a0,s3
    800043d8:	ee9fe0ef          	jal	800032c0 <brelse>
    brelse(to);
    800043dc:	8526                	mv	a0,s1
    800043de:	ee3fe0ef          	jal	800032c0 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    800043e2:	2905                	addiw	s2,s2,1
    800043e4:	0a91                	addi	s5,s5,4
    800043e6:	028a2783          	lw	a5,40(s4)
    800043ea:	faf94ae3          	blt	s2,a5,8000439e <end_op+0xbc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    800043ee:	cd9ff0ef          	jal	800040c6 <write_head>
    install_trans(0); // Now install writes to home locations
    800043f2:	4501                	li	a0,0
    800043f4:	d31ff0ef          	jal	80004124 <install_trans>
    log.lh.n = 0;
    800043f8:	0001e797          	auipc	a5,0x1e
    800043fc:	d407a023          	sw	zero,-704(a5) # 80022138 <log+0x28>
    write_head();    // Erase the transaction from the log
    80004400:	cc7ff0ef          	jal	800040c6 <write_head>
    80004404:	69e2                	ld	s3,24(sp)
    80004406:	6a42                	ld	s4,16(sp)
    80004408:	6aa2                	ld	s5,8(sp)
    8000440a:	bf29                	j	80004324 <end_op+0x42>

000000008000440c <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    8000440c:	1101                	addi	sp,sp,-32
    8000440e:	ec06                	sd	ra,24(sp)
    80004410:	e822                	sd	s0,16(sp)
    80004412:	e426                	sd	s1,8(sp)
    80004414:	1000                	addi	s0,sp,32
    80004416:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    80004418:	0001e517          	auipc	a0,0x1e
    8000441c:	cf850513          	addi	a0,a0,-776 # 80022110 <log>
    80004420:	903fc0ef          	jal	80000d22 <acquire>
  if (log.lh.n >= LOGBLOCKS)
    80004424:	0001e617          	auipc	a2,0x1e
    80004428:	d1462603          	lw	a2,-748(a2) # 80022138 <log+0x28>
    8000442c:	47f5                	li	a5,29
    8000442e:	04c7cd63          	blt	a5,a2,80004488 <log_write+0x7c>
    panic("too big a transaction");
  if (log.outstanding < 1)
    80004432:	0001e797          	auipc	a5,0x1e
    80004436:	cfa7a783          	lw	a5,-774(a5) # 8002212c <log+0x1c>
    8000443a:	04f05d63          	blez	a5,80004494 <log_write+0x88>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    8000443e:	4781                	li	a5,0
    80004440:	06c05063          	blez	a2,800044a0 <log_write+0x94>
    if (log.lh.block[i] == b->blockno)   // log absorption
    80004444:	44cc                	lw	a1,12(s1)
    80004446:	0001e717          	auipc	a4,0x1e
    8000444a:	cf670713          	addi	a4,a4,-778 # 8002213c <log+0x2c>
  for (i = 0; i < log.lh.n; i++) {
    8000444e:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    80004450:	4314                	lw	a3,0(a4)
    80004452:	04b68763          	beq	a3,a1,800044a0 <log_write+0x94>
  for (i = 0; i < log.lh.n; i++) {
    80004456:	2785                	addiw	a5,a5,1
    80004458:	0711                	addi	a4,a4,4
    8000445a:	fef61be3          	bne	a2,a5,80004450 <log_write+0x44>
      break;
  }
  log.lh.block[i] = b->blockno;
    8000445e:	060a                	slli	a2,a2,0x2
    80004460:	02060613          	addi	a2,a2,32
    80004464:	0001e797          	auipc	a5,0x1e
    80004468:	cac78793          	addi	a5,a5,-852 # 80022110 <log>
    8000446c:	97b2                	add	a5,a5,a2
    8000446e:	44d8                	lw	a4,12(s1)
    80004470:	c7d8                	sw	a4,12(a5)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    80004472:	8526                	mv	a0,s1
    80004474:	ee7fe0ef          	jal	8000335a <bpin>
    log.lh.n++;
    80004478:	0001e717          	auipc	a4,0x1e
    8000447c:	c9870713          	addi	a4,a4,-872 # 80022110 <log>
    80004480:	571c                	lw	a5,40(a4)
    80004482:	2785                	addiw	a5,a5,1
    80004484:	d71c                	sw	a5,40(a4)
    80004486:	a815                	j	800044ba <log_write+0xae>
    panic("too big a transaction");
    80004488:	00004517          	auipc	a0,0x4
    8000448c:	19850513          	addi	a0,a0,408 # 80008620 <userret+0x1584>
    80004490:	bc6fc0ef          	jal	80000856 <panic>
    panic("log_write outside of trans");
    80004494:	00004517          	auipc	a0,0x4
    80004498:	1a450513          	addi	a0,a0,420 # 80008638 <userret+0x159c>
    8000449c:	bbafc0ef          	jal	80000856 <panic>
  log.lh.block[i] = b->blockno;
    800044a0:	00279693          	slli	a3,a5,0x2
    800044a4:	02068693          	addi	a3,a3,32
    800044a8:	0001e717          	auipc	a4,0x1e
    800044ac:	c6870713          	addi	a4,a4,-920 # 80022110 <log>
    800044b0:	9736                	add	a4,a4,a3
    800044b2:	44d4                	lw	a3,12(s1)
    800044b4:	c754                	sw	a3,12(a4)
  if (i == log.lh.n) {  // Add new block to log?
    800044b6:	faf60ee3          	beq	a2,a5,80004472 <log_write+0x66>
  }
  release(&log.lock);
    800044ba:	0001e517          	auipc	a0,0x1e
    800044be:	c5650513          	addi	a0,a0,-938 # 80022110 <log>
    800044c2:	8f5fc0ef          	jal	80000db6 <release>
}
    800044c6:	60e2                	ld	ra,24(sp)
    800044c8:	6442                	ld	s0,16(sp)
    800044ca:	64a2                	ld	s1,8(sp)
    800044cc:	6105                	addi	sp,sp,32
    800044ce:	8082                	ret

00000000800044d0 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    800044d0:	1101                	addi	sp,sp,-32
    800044d2:	ec06                	sd	ra,24(sp)
    800044d4:	e822                	sd	s0,16(sp)
    800044d6:	e426                	sd	s1,8(sp)
    800044d8:	e04a                	sd	s2,0(sp)
    800044da:	1000                	addi	s0,sp,32
    800044dc:	84aa                	mv	s1,a0
    800044de:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    800044e0:	00004597          	auipc	a1,0x4
    800044e4:	17858593          	addi	a1,a1,376 # 80008658 <userret+0x15bc>
    800044e8:	0521                	addi	a0,a0,8
    800044ea:	faefc0ef          	jal	80000c98 <initlock>
  lk->name = name;
    800044ee:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    800044f2:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    800044f6:	0204a423          	sw	zero,40(s1)
}
    800044fa:	60e2                	ld	ra,24(sp)
    800044fc:	6442                	ld	s0,16(sp)
    800044fe:	64a2                	ld	s1,8(sp)
    80004500:	6902                	ld	s2,0(sp)
    80004502:	6105                	addi	sp,sp,32
    80004504:	8082                	ret

0000000080004506 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    80004506:	1101                	addi	sp,sp,-32
    80004508:	ec06                	sd	ra,24(sp)
    8000450a:	e822                	sd	s0,16(sp)
    8000450c:	e426                	sd	s1,8(sp)
    8000450e:	e04a                	sd	s2,0(sp)
    80004510:	1000                	addi	s0,sp,32
    80004512:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004514:	00850913          	addi	s2,a0,8
    80004518:	854a                	mv	a0,s2
    8000451a:	809fc0ef          	jal	80000d22 <acquire>
  while (lk->locked) {
    8000451e:	409c                	lw	a5,0(s1)
    80004520:	c799                	beqz	a5,8000452e <acquiresleep+0x28>
    sleep(lk, &lk->lk);
    80004522:	85ca                	mv	a1,s2
    80004524:	8526                	mv	a0,s1
    80004526:	f99fd0ef          	jal	800024be <sleep>
  while (lk->locked) {
    8000452a:	409c                	lw	a5,0(s1)
    8000452c:	fbfd                	bnez	a5,80004522 <acquiresleep+0x1c>
  }
  lk->locked = 1;
    8000452e:	4785                	li	a5,1
    80004530:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    80004532:	f60fd0ef          	jal	80001c92 <myproc>
    80004536:	591c                	lw	a5,48(a0)
    80004538:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    8000453a:	854a                	mv	a0,s2
    8000453c:	87bfc0ef          	jal	80000db6 <release>
}
    80004540:	60e2                	ld	ra,24(sp)
    80004542:	6442                	ld	s0,16(sp)
    80004544:	64a2                	ld	s1,8(sp)
    80004546:	6902                	ld	s2,0(sp)
    80004548:	6105                	addi	sp,sp,32
    8000454a:	8082                	ret

000000008000454c <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    8000454c:	1101                	addi	sp,sp,-32
    8000454e:	ec06                	sd	ra,24(sp)
    80004550:	e822                	sd	s0,16(sp)
    80004552:	e426                	sd	s1,8(sp)
    80004554:	e04a                	sd	s2,0(sp)
    80004556:	1000                	addi	s0,sp,32
    80004558:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    8000455a:	00850913          	addi	s2,a0,8
    8000455e:	854a                	mv	a0,s2
    80004560:	fc2fc0ef          	jal	80000d22 <acquire>
  lk->locked = 0;
    80004564:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004568:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    8000456c:	8526                	mv	a0,s1
    8000456e:	f9dfd0ef          	jal	8000250a <wakeup>
  release(&lk->lk);
    80004572:	854a                	mv	a0,s2
    80004574:	843fc0ef          	jal	80000db6 <release>
}
    80004578:	60e2                	ld	ra,24(sp)
    8000457a:	6442                	ld	s0,16(sp)
    8000457c:	64a2                	ld	s1,8(sp)
    8000457e:	6902                	ld	s2,0(sp)
    80004580:	6105                	addi	sp,sp,32
    80004582:	8082                	ret

0000000080004584 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    80004584:	7179                	addi	sp,sp,-48
    80004586:	f406                	sd	ra,40(sp)
    80004588:	f022                	sd	s0,32(sp)
    8000458a:	ec26                	sd	s1,24(sp)
    8000458c:	e84a                	sd	s2,16(sp)
    8000458e:	1800                	addi	s0,sp,48
    80004590:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    80004592:	00850913          	addi	s2,a0,8
    80004596:	854a                	mv	a0,s2
    80004598:	f8afc0ef          	jal	80000d22 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    8000459c:	409c                	lw	a5,0(s1)
    8000459e:	ef81                	bnez	a5,800045b6 <holdingsleep+0x32>
    800045a0:	4481                	li	s1,0
  release(&lk->lk);
    800045a2:	854a                	mv	a0,s2
    800045a4:	813fc0ef          	jal	80000db6 <release>
  return r;
}
    800045a8:	8526                	mv	a0,s1
    800045aa:	70a2                	ld	ra,40(sp)
    800045ac:	7402                	ld	s0,32(sp)
    800045ae:	64e2                	ld	s1,24(sp)
    800045b0:	6942                	ld	s2,16(sp)
    800045b2:	6145                	addi	sp,sp,48
    800045b4:	8082                	ret
    800045b6:	e44e                	sd	s3,8(sp)
  r = lk->locked && (lk->pid == myproc()->pid);
    800045b8:	0284a983          	lw	s3,40(s1)
    800045bc:	ed6fd0ef          	jal	80001c92 <myproc>
    800045c0:	5904                	lw	s1,48(a0)
    800045c2:	413484b3          	sub	s1,s1,s3
    800045c6:	0014b493          	seqz	s1,s1
    800045ca:	69a2                	ld	s3,8(sp)
    800045cc:	bfd9                	j	800045a2 <holdingsleep+0x1e>

00000000800045ce <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    800045ce:	1141                	addi	sp,sp,-16
    800045d0:	e406                	sd	ra,8(sp)
    800045d2:	e022                	sd	s0,0(sp)
    800045d4:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    800045d6:	00004597          	auipc	a1,0x4
    800045da:	09258593          	addi	a1,a1,146 # 80008668 <userret+0x15cc>
    800045de:	0001e517          	auipc	a0,0x1e
    800045e2:	c7a50513          	addi	a0,a0,-902 # 80022258 <ftable>
    800045e6:	eb2fc0ef          	jal	80000c98 <initlock>
}
    800045ea:	60a2                	ld	ra,8(sp)
    800045ec:	6402                	ld	s0,0(sp)
    800045ee:	0141                	addi	sp,sp,16
    800045f0:	8082                	ret

00000000800045f2 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    800045f2:	1101                	addi	sp,sp,-32
    800045f4:	ec06                	sd	ra,24(sp)
    800045f6:	e822                	sd	s0,16(sp)
    800045f8:	e426                	sd	s1,8(sp)
    800045fa:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    800045fc:	0001e517          	auipc	a0,0x1e
    80004600:	c5c50513          	addi	a0,a0,-932 # 80022258 <ftable>
    80004604:	f1efc0ef          	jal	80000d22 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004608:	0001e497          	auipc	s1,0x1e
    8000460c:	c6848493          	addi	s1,s1,-920 # 80022270 <ftable+0x18>
    80004610:	0001f717          	auipc	a4,0x1f
    80004614:	c0070713          	addi	a4,a4,-1024 # 80023210 <disk>
    if(f->ref == 0){
    80004618:	40dc                	lw	a5,4(s1)
    8000461a:	cf89                	beqz	a5,80004634 <filealloc+0x42>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    8000461c:	02848493          	addi	s1,s1,40
    80004620:	fee49ce3          	bne	s1,a4,80004618 <filealloc+0x26>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    80004624:	0001e517          	auipc	a0,0x1e
    80004628:	c3450513          	addi	a0,a0,-972 # 80022258 <ftable>
    8000462c:	f8afc0ef          	jal	80000db6 <release>
  return 0;
    80004630:	4481                	li	s1,0
    80004632:	a809                	j	80004644 <filealloc+0x52>
      f->ref = 1;
    80004634:	4785                	li	a5,1
    80004636:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    80004638:	0001e517          	auipc	a0,0x1e
    8000463c:	c2050513          	addi	a0,a0,-992 # 80022258 <ftable>
    80004640:	f76fc0ef          	jal	80000db6 <release>
}
    80004644:	8526                	mv	a0,s1
    80004646:	60e2                	ld	ra,24(sp)
    80004648:	6442                	ld	s0,16(sp)
    8000464a:	64a2                	ld	s1,8(sp)
    8000464c:	6105                	addi	sp,sp,32
    8000464e:	8082                	ret

0000000080004650 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    80004650:	1101                	addi	sp,sp,-32
    80004652:	ec06                	sd	ra,24(sp)
    80004654:	e822                	sd	s0,16(sp)
    80004656:	e426                	sd	s1,8(sp)
    80004658:	1000                	addi	s0,sp,32
    8000465a:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    8000465c:	0001e517          	auipc	a0,0x1e
    80004660:	bfc50513          	addi	a0,a0,-1028 # 80022258 <ftable>
    80004664:	ebefc0ef          	jal	80000d22 <acquire>
  if(f->ref < 1)
    80004668:	40dc                	lw	a5,4(s1)
    8000466a:	02f05063          	blez	a5,8000468a <filedup+0x3a>
    panic("filedup");
  f->ref++;
    8000466e:	2785                	addiw	a5,a5,1
    80004670:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80004672:	0001e517          	auipc	a0,0x1e
    80004676:	be650513          	addi	a0,a0,-1050 # 80022258 <ftable>
    8000467a:	f3cfc0ef          	jal	80000db6 <release>
  return f;
}
    8000467e:	8526                	mv	a0,s1
    80004680:	60e2                	ld	ra,24(sp)
    80004682:	6442                	ld	s0,16(sp)
    80004684:	64a2                	ld	s1,8(sp)
    80004686:	6105                	addi	sp,sp,32
    80004688:	8082                	ret
    panic("filedup");
    8000468a:	00004517          	auipc	a0,0x4
    8000468e:	fe650513          	addi	a0,a0,-26 # 80008670 <userret+0x15d4>
    80004692:	9c4fc0ef          	jal	80000856 <panic>

0000000080004696 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    80004696:	7139                	addi	sp,sp,-64
    80004698:	fc06                	sd	ra,56(sp)
    8000469a:	f822                	sd	s0,48(sp)
    8000469c:	f426                	sd	s1,40(sp)
    8000469e:	0080                	addi	s0,sp,64
    800046a0:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    800046a2:	0001e517          	auipc	a0,0x1e
    800046a6:	bb650513          	addi	a0,a0,-1098 # 80022258 <ftable>
    800046aa:	e78fc0ef          	jal	80000d22 <acquire>
  if(f->ref < 1)
    800046ae:	40dc                	lw	a5,4(s1)
    800046b0:	04f05a63          	blez	a5,80004704 <fileclose+0x6e>
    panic("fileclose");
  if(--f->ref > 0){
    800046b4:	37fd                	addiw	a5,a5,-1
    800046b6:	c0dc                	sw	a5,4(s1)
    800046b8:	06f04063          	bgtz	a5,80004718 <fileclose+0x82>
    800046bc:	f04a                	sd	s2,32(sp)
    800046be:	ec4e                	sd	s3,24(sp)
    800046c0:	e852                	sd	s4,16(sp)
    800046c2:	e456                	sd	s5,8(sp)
    release(&ftable.lock);
    return;
  }
  ff = *f;
    800046c4:	0004a903          	lw	s2,0(s1)
    800046c8:	0094c783          	lbu	a5,9(s1)
    800046cc:	89be                	mv	s3,a5
    800046ce:	689c                	ld	a5,16(s1)
    800046d0:	8a3e                	mv	s4,a5
    800046d2:	6c9c                	ld	a5,24(s1)
    800046d4:	8abe                	mv	s5,a5
  f->ref = 0;
    800046d6:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    800046da:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    800046de:	0001e517          	auipc	a0,0x1e
    800046e2:	b7a50513          	addi	a0,a0,-1158 # 80022258 <ftable>
    800046e6:	ed0fc0ef          	jal	80000db6 <release>

  if(ff.type == FD_PIPE){
    800046ea:	4785                	li	a5,1
    800046ec:	04f90163          	beq	s2,a5,8000472e <fileclose+0x98>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    800046f0:	ffe9079b          	addiw	a5,s2,-2
    800046f4:	4705                	li	a4,1
    800046f6:	04f77563          	bgeu	a4,a5,80004740 <fileclose+0xaa>
    800046fa:	7902                	ld	s2,32(sp)
    800046fc:	69e2                	ld	s3,24(sp)
    800046fe:	6a42                	ld	s4,16(sp)
    80004700:	6aa2                	ld	s5,8(sp)
    80004702:	a00d                	j	80004724 <fileclose+0x8e>
    80004704:	f04a                	sd	s2,32(sp)
    80004706:	ec4e                	sd	s3,24(sp)
    80004708:	e852                	sd	s4,16(sp)
    8000470a:	e456                	sd	s5,8(sp)
    panic("fileclose");
    8000470c:	00004517          	auipc	a0,0x4
    80004710:	f6c50513          	addi	a0,a0,-148 # 80008678 <userret+0x15dc>
    80004714:	942fc0ef          	jal	80000856 <panic>
    release(&ftable.lock);
    80004718:	0001e517          	auipc	a0,0x1e
    8000471c:	b4050513          	addi	a0,a0,-1216 # 80022258 <ftable>
    80004720:	e96fc0ef          	jal	80000db6 <release>
    begin_op();
    iput(ff.ip);
    end_op();
  }
}
    80004724:	70e2                	ld	ra,56(sp)
    80004726:	7442                	ld	s0,48(sp)
    80004728:	74a2                	ld	s1,40(sp)
    8000472a:	6121                	addi	sp,sp,64
    8000472c:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    8000472e:	85ce                	mv	a1,s3
    80004730:	8552                	mv	a0,s4
    80004732:	348000ef          	jal	80004a7a <pipeclose>
    80004736:	7902                	ld	s2,32(sp)
    80004738:	69e2                	ld	s3,24(sp)
    8000473a:	6a42                	ld	s4,16(sp)
    8000473c:	6aa2                	ld	s5,8(sp)
    8000473e:	b7dd                	j	80004724 <fileclose+0x8e>
    begin_op();
    80004740:	b33ff0ef          	jal	80004272 <begin_op>
    iput(ff.ip);
    80004744:	8556                	mv	a0,s5
    80004746:	aa2ff0ef          	jal	800039e8 <iput>
    end_op();
    8000474a:	b99ff0ef          	jal	800042e2 <end_op>
    8000474e:	7902                	ld	s2,32(sp)
    80004750:	69e2                	ld	s3,24(sp)
    80004752:	6a42                	ld	s4,16(sp)
    80004754:	6aa2                	ld	s5,8(sp)
    80004756:	b7f9                	j	80004724 <fileclose+0x8e>

0000000080004758 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    80004758:	715d                	addi	sp,sp,-80
    8000475a:	e486                	sd	ra,72(sp)
    8000475c:	e0a2                	sd	s0,64(sp)
    8000475e:	fc26                	sd	s1,56(sp)
    80004760:	f052                	sd	s4,32(sp)
    80004762:	0880                	addi	s0,sp,80
    80004764:	84aa                	mv	s1,a0
    80004766:	8a2e                	mv	s4,a1
  struct proc *p = myproc();
    80004768:	d2afd0ef          	jal	80001c92 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    8000476c:	409c                	lw	a5,0(s1)
    8000476e:	37f9                	addiw	a5,a5,-2
    80004770:	4705                	li	a4,1
    80004772:	04f76263          	bltu	a4,a5,800047b6 <filestat+0x5e>
    80004776:	f84a                	sd	s2,48(sp)
    80004778:	f44e                	sd	s3,40(sp)
    8000477a:	89aa                	mv	s3,a0
    ilock(f->ip);
    8000477c:	6c88                	ld	a0,24(s1)
    8000477e:	8e8ff0ef          	jal	80003866 <ilock>
    stati(f->ip, &st);
    80004782:	fb840913          	addi	s2,s0,-72
    80004786:	85ca                	mv	a1,s2
    80004788:	6c88                	ld	a0,24(s1)
    8000478a:	c40ff0ef          	jal	80003bca <stati>
    iunlock(f->ip);
    8000478e:	6c88                	ld	a0,24(s1)
    80004790:	984ff0ef          	jal	80003914 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    80004794:	46e1                	li	a3,24
    80004796:	864a                	mv	a2,s2
    80004798:	85d2                	mv	a1,s4
    8000479a:	0509b503          	ld	a0,80(s3)
    8000479e:	a06fd0ef          	jal	800019a4 <copyout>
    800047a2:	41f5551b          	sraiw	a0,a0,0x1f
    800047a6:	7942                	ld	s2,48(sp)
    800047a8:	79a2                	ld	s3,40(sp)
      return -1;
    return 0;
  }
  return -1;
}
    800047aa:	60a6                	ld	ra,72(sp)
    800047ac:	6406                	ld	s0,64(sp)
    800047ae:	74e2                	ld	s1,56(sp)
    800047b0:	7a02                	ld	s4,32(sp)
    800047b2:	6161                	addi	sp,sp,80
    800047b4:	8082                	ret
  return -1;
    800047b6:	557d                	li	a0,-1
    800047b8:	bfcd                	j	800047aa <filestat+0x52>

00000000800047ba <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    800047ba:	7179                	addi	sp,sp,-48
    800047bc:	f406                	sd	ra,40(sp)
    800047be:	f022                	sd	s0,32(sp)
    800047c0:	e84a                	sd	s2,16(sp)
    800047c2:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    800047c4:	00854783          	lbu	a5,8(a0)
    800047c8:	cfd1                	beqz	a5,80004864 <fileread+0xaa>
    800047ca:	ec26                	sd	s1,24(sp)
    800047cc:	e44e                	sd	s3,8(sp)
    800047ce:	84aa                	mv	s1,a0
    800047d0:	892e                	mv	s2,a1
    800047d2:	89b2                	mv	s3,a2
    return -1;

  if(f->type == FD_PIPE){
    800047d4:	411c                	lw	a5,0(a0)
    800047d6:	4705                	li	a4,1
    800047d8:	04e78363          	beq	a5,a4,8000481e <fileread+0x64>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    800047dc:	470d                	li	a4,3
    800047de:	04e78763          	beq	a5,a4,8000482c <fileread+0x72>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    800047e2:	4709                	li	a4,2
    800047e4:	06e79a63          	bne	a5,a4,80004858 <fileread+0x9e>
    ilock(f->ip);
    800047e8:	6d08                	ld	a0,24(a0)
    800047ea:	87cff0ef          	jal	80003866 <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    800047ee:	874e                	mv	a4,s3
    800047f0:	5094                	lw	a3,32(s1)
    800047f2:	864a                	mv	a2,s2
    800047f4:	4585                	li	a1,1
    800047f6:	6c88                	ld	a0,24(s1)
    800047f8:	c00ff0ef          	jal	80003bf8 <readi>
    800047fc:	892a                	mv	s2,a0
    800047fe:	00a05563          	blez	a0,80004808 <fileread+0x4e>
      f->off += r;
    80004802:	509c                	lw	a5,32(s1)
    80004804:	9fa9                	addw	a5,a5,a0
    80004806:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80004808:	6c88                	ld	a0,24(s1)
    8000480a:	90aff0ef          	jal	80003914 <iunlock>
    8000480e:	64e2                	ld	s1,24(sp)
    80004810:	69a2                	ld	s3,8(sp)
  } else {
    panic("fileread");
  }

  return r;
}
    80004812:	854a                	mv	a0,s2
    80004814:	70a2                	ld	ra,40(sp)
    80004816:	7402                	ld	s0,32(sp)
    80004818:	6942                	ld	s2,16(sp)
    8000481a:	6145                	addi	sp,sp,48
    8000481c:	8082                	ret
    r = piperead(f->pipe, addr, n);
    8000481e:	6908                	ld	a0,16(a0)
    80004820:	3b0000ef          	jal	80004bd0 <piperead>
    80004824:	892a                	mv	s2,a0
    80004826:	64e2                	ld	s1,24(sp)
    80004828:	69a2                	ld	s3,8(sp)
    8000482a:	b7e5                	j	80004812 <fileread+0x58>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    8000482c:	02451783          	lh	a5,36(a0)
    80004830:	03079693          	slli	a3,a5,0x30
    80004834:	92c1                	srli	a3,a3,0x30
    80004836:	4725                	li	a4,9
    80004838:	02d76963          	bltu	a4,a3,8000486a <fileread+0xb0>
    8000483c:	0792                	slli	a5,a5,0x4
    8000483e:	0001e717          	auipc	a4,0x1e
    80004842:	97a70713          	addi	a4,a4,-1670 # 800221b8 <devsw>
    80004846:	97ba                	add	a5,a5,a4
    80004848:	639c                	ld	a5,0(a5)
    8000484a:	c78d                	beqz	a5,80004874 <fileread+0xba>
    r = devsw[f->major].read(1, addr, n);
    8000484c:	4505                	li	a0,1
    8000484e:	9782                	jalr	a5
    80004850:	892a                	mv	s2,a0
    80004852:	64e2                	ld	s1,24(sp)
    80004854:	69a2                	ld	s3,8(sp)
    80004856:	bf75                	j	80004812 <fileread+0x58>
    panic("fileread");
    80004858:	00004517          	auipc	a0,0x4
    8000485c:	e3050513          	addi	a0,a0,-464 # 80008688 <userret+0x15ec>
    80004860:	ff7fb0ef          	jal	80000856 <panic>
    return -1;
    80004864:	57fd                	li	a5,-1
    80004866:	893e                	mv	s2,a5
    80004868:	b76d                	j	80004812 <fileread+0x58>
      return -1;
    8000486a:	57fd                	li	a5,-1
    8000486c:	893e                	mv	s2,a5
    8000486e:	64e2                	ld	s1,24(sp)
    80004870:	69a2                	ld	s3,8(sp)
    80004872:	b745                	j	80004812 <fileread+0x58>
    80004874:	57fd                	li	a5,-1
    80004876:	893e                	mv	s2,a5
    80004878:	64e2                	ld	s1,24(sp)
    8000487a:	69a2                	ld	s3,8(sp)
    8000487c:	bf59                	j	80004812 <fileread+0x58>

000000008000487e <filewrite>:
int
filewrite(struct file *f, uint64 addr, int n)
{
  int r, ret = 0;

  if(f->writable == 0)
    8000487e:	00954783          	lbu	a5,9(a0)
    80004882:	10078f63          	beqz	a5,800049a0 <filewrite+0x122>
{
    80004886:	711d                	addi	sp,sp,-96
    80004888:	ec86                	sd	ra,88(sp)
    8000488a:	e8a2                	sd	s0,80(sp)
    8000488c:	e0ca                	sd	s2,64(sp)
    8000488e:	f456                	sd	s5,40(sp)
    80004890:	f05a                	sd	s6,32(sp)
    80004892:	1080                	addi	s0,sp,96
    80004894:	892a                	mv	s2,a0
    80004896:	8b2e                	mv	s6,a1
    80004898:	8ab2                	mv	s5,a2
    return -1;

  if(f->type == FD_PIPE){
    8000489a:	411c                	lw	a5,0(a0)
    8000489c:	4705                	li	a4,1
    8000489e:	02e78a63          	beq	a5,a4,800048d2 <filewrite+0x54>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    800048a2:	470d                	li	a4,3
    800048a4:	02e78b63          	beq	a5,a4,800048da <filewrite+0x5c>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    800048a8:	4709                	li	a4,2
    800048aa:	0ce79f63          	bne	a5,a4,80004988 <filewrite+0x10a>
    800048ae:	f852                	sd	s4,48(sp)
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    800048b0:	0ac05a63          	blez	a2,80004964 <filewrite+0xe6>
    800048b4:	e4a6                	sd	s1,72(sp)
    800048b6:	fc4e                	sd	s3,56(sp)
    800048b8:	ec5e                	sd	s7,24(sp)
    800048ba:	e862                	sd	s8,16(sp)
    800048bc:	e466                	sd	s9,8(sp)
    int i = 0;
    800048be:	4a01                	li	s4,0
      int n1 = n - i;
      if(n1 > max)
    800048c0:	6b85                	lui	s7,0x1
    800048c2:	c00b8b93          	addi	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    800048c6:	6785                	lui	a5,0x1
    800048c8:	c007879b          	addiw	a5,a5,-1024 # c00 <_entry-0x7ffff400>
    800048cc:	8cbe                	mv	s9,a5
        n1 = max;

      begin_op();
      ilock(f->ip);
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    800048ce:	4c05                	li	s8,1
    800048d0:	a8ad                	j	8000494a <filewrite+0xcc>
    ret = pipewrite(f->pipe, addr, n);
    800048d2:	6908                	ld	a0,16(a0)
    800048d4:	204000ef          	jal	80004ad8 <pipewrite>
    800048d8:	a04d                	j	8000497a <filewrite+0xfc>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    800048da:	02451783          	lh	a5,36(a0)
    800048de:	03079693          	slli	a3,a5,0x30
    800048e2:	92c1                	srli	a3,a3,0x30
    800048e4:	4725                	li	a4,9
    800048e6:	0ad76f63          	bltu	a4,a3,800049a4 <filewrite+0x126>
    800048ea:	0792                	slli	a5,a5,0x4
    800048ec:	0001e717          	auipc	a4,0x1e
    800048f0:	8cc70713          	addi	a4,a4,-1844 # 800221b8 <devsw>
    800048f4:	97ba                	add	a5,a5,a4
    800048f6:	679c                	ld	a5,8(a5)
    800048f8:	cbc5                	beqz	a5,800049a8 <filewrite+0x12a>
    ret = devsw[f->major].write(1, addr, n);
    800048fa:	4505                	li	a0,1
    800048fc:	9782                	jalr	a5
    800048fe:	a8b5                	j	8000497a <filewrite+0xfc>
      if(n1 > max)
    80004900:	2981                	sext.w	s3,s3
      begin_op();
    80004902:	971ff0ef          	jal	80004272 <begin_op>
      ilock(f->ip);
    80004906:	01893503          	ld	a0,24(s2)
    8000490a:	f5dfe0ef          	jal	80003866 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    8000490e:	874e                	mv	a4,s3
    80004910:	02092683          	lw	a3,32(s2)
    80004914:	016a0633          	add	a2,s4,s6
    80004918:	85e2                	mv	a1,s8
    8000491a:	01893503          	ld	a0,24(s2)
    8000491e:	bccff0ef          	jal	80003cea <writei>
    80004922:	84aa                	mv	s1,a0
    80004924:	00a05763          	blez	a0,80004932 <filewrite+0xb4>
        f->off += r;
    80004928:	02092783          	lw	a5,32(s2)
    8000492c:	9fa9                	addw	a5,a5,a0
    8000492e:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80004932:	01893503          	ld	a0,24(s2)
    80004936:	fdffe0ef          	jal	80003914 <iunlock>
      end_op();
    8000493a:	9a9ff0ef          	jal	800042e2 <end_op>

      if(r != n1){
    8000493e:	02999563          	bne	s3,s1,80004968 <filewrite+0xea>
        // error from writei
        break;
      }
      i += r;
    80004942:	01448a3b          	addw	s4,s1,s4
    while(i < n){
    80004946:	015a5963          	bge	s4,s5,80004958 <filewrite+0xda>
      int n1 = n - i;
    8000494a:	414a87bb          	subw	a5,s5,s4
    8000494e:	89be                	mv	s3,a5
      if(n1 > max)
    80004950:	fafbd8e3          	bge	s7,a5,80004900 <filewrite+0x82>
    80004954:	89e6                	mv	s3,s9
    80004956:	b76d                	j	80004900 <filewrite+0x82>
    80004958:	64a6                	ld	s1,72(sp)
    8000495a:	79e2                	ld	s3,56(sp)
    8000495c:	6be2                	ld	s7,24(sp)
    8000495e:	6c42                	ld	s8,16(sp)
    80004960:	6ca2                	ld	s9,8(sp)
    80004962:	a801                	j	80004972 <filewrite+0xf4>
    int i = 0;
    80004964:	4a01                	li	s4,0
    80004966:	a031                	j	80004972 <filewrite+0xf4>
    80004968:	64a6                	ld	s1,72(sp)
    8000496a:	79e2                	ld	s3,56(sp)
    8000496c:	6be2                	ld	s7,24(sp)
    8000496e:	6c42                	ld	s8,16(sp)
    80004970:	6ca2                	ld	s9,8(sp)
    }
    ret = (i == n ? n : -1);
    80004972:	034a9d63          	bne	s5,s4,800049ac <filewrite+0x12e>
    80004976:	8556                	mv	a0,s5
    80004978:	7a42                	ld	s4,48(sp)
  } else {
    panic("filewrite");
  }

  return ret;
}
    8000497a:	60e6                	ld	ra,88(sp)
    8000497c:	6446                	ld	s0,80(sp)
    8000497e:	6906                	ld	s2,64(sp)
    80004980:	7aa2                	ld	s5,40(sp)
    80004982:	7b02                	ld	s6,32(sp)
    80004984:	6125                	addi	sp,sp,96
    80004986:	8082                	ret
    80004988:	e4a6                	sd	s1,72(sp)
    8000498a:	fc4e                	sd	s3,56(sp)
    8000498c:	f852                	sd	s4,48(sp)
    8000498e:	ec5e                	sd	s7,24(sp)
    80004990:	e862                	sd	s8,16(sp)
    80004992:	e466                	sd	s9,8(sp)
    panic("filewrite");
    80004994:	00004517          	auipc	a0,0x4
    80004998:	d0450513          	addi	a0,a0,-764 # 80008698 <userret+0x15fc>
    8000499c:	ebbfb0ef          	jal	80000856 <panic>
    return -1;
    800049a0:	557d                	li	a0,-1
}
    800049a2:	8082                	ret
      return -1;
    800049a4:	557d                	li	a0,-1
    800049a6:	bfd1                	j	8000497a <filewrite+0xfc>
    800049a8:	557d                	li	a0,-1
    800049aa:	bfc1                	j	8000497a <filewrite+0xfc>
    ret = (i == n ? n : -1);
    800049ac:	557d                	li	a0,-1
    800049ae:	7a42                	ld	s4,48(sp)
    800049b0:	b7e9                	j	8000497a <filewrite+0xfc>

00000000800049b2 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    800049b2:	7179                	addi	sp,sp,-48
    800049b4:	f406                	sd	ra,40(sp)
    800049b6:	f022                	sd	s0,32(sp)
    800049b8:	ec26                	sd	s1,24(sp)
    800049ba:	e052                	sd	s4,0(sp)
    800049bc:	1800                	addi	s0,sp,48
    800049be:	84aa                	mv	s1,a0
    800049c0:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    800049c2:	0005b023          	sd	zero,0(a1)
    800049c6:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    800049ca:	c29ff0ef          	jal	800045f2 <filealloc>
    800049ce:	e088                	sd	a0,0(s1)
    800049d0:	c549                	beqz	a0,80004a5a <pipealloc+0xa8>
    800049d2:	c21ff0ef          	jal	800045f2 <filealloc>
    800049d6:	00aa3023          	sd	a0,0(s4)
    800049da:	cd25                	beqz	a0,80004a52 <pipealloc+0xa0>
    800049dc:	e84a                	sd	s2,16(sp)
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    800049de:	9fcfc0ef          	jal	80000bda <kalloc>
    800049e2:	892a                	mv	s2,a0
    800049e4:	c12d                	beqz	a0,80004a46 <pipealloc+0x94>
    800049e6:	e44e                	sd	s3,8(sp)
    goto bad;
  pi->readopen = 1;
    800049e8:	4985                	li	s3,1
    800049ea:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    800049ee:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    800049f2:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    800049f6:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    800049fa:	00004597          	auipc	a1,0x4
    800049fe:	cae58593          	addi	a1,a1,-850 # 800086a8 <userret+0x160c>
    80004a02:	a96fc0ef          	jal	80000c98 <initlock>
  (*f0)->type = FD_PIPE;
    80004a06:	609c                	ld	a5,0(s1)
    80004a08:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80004a0c:	609c                	ld	a5,0(s1)
    80004a0e:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80004a12:	609c                	ld	a5,0(s1)
    80004a14:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80004a18:	609c                	ld	a5,0(s1)
    80004a1a:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80004a1e:	000a3783          	ld	a5,0(s4)
    80004a22:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80004a26:	000a3783          	ld	a5,0(s4)
    80004a2a:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80004a2e:	000a3783          	ld	a5,0(s4)
    80004a32:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80004a36:	000a3783          	ld	a5,0(s4)
    80004a3a:	0127b823          	sd	s2,16(a5)
  return 0;
    80004a3e:	4501                	li	a0,0
    80004a40:	6942                	ld	s2,16(sp)
    80004a42:	69a2                	ld	s3,8(sp)
    80004a44:	a01d                	j	80004a6a <pipealloc+0xb8>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80004a46:	6088                	ld	a0,0(s1)
    80004a48:	c119                	beqz	a0,80004a4e <pipealloc+0x9c>
    80004a4a:	6942                	ld	s2,16(sp)
    80004a4c:	a029                	j	80004a56 <pipealloc+0xa4>
    80004a4e:	6942                	ld	s2,16(sp)
    80004a50:	a029                	j	80004a5a <pipealloc+0xa8>
    80004a52:	6088                	ld	a0,0(s1)
    80004a54:	c10d                	beqz	a0,80004a76 <pipealloc+0xc4>
    fileclose(*f0);
    80004a56:	c41ff0ef          	jal	80004696 <fileclose>
  if(*f1)
    80004a5a:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80004a5e:	557d                	li	a0,-1
  if(*f1)
    80004a60:	c789                	beqz	a5,80004a6a <pipealloc+0xb8>
    fileclose(*f1);
    80004a62:	853e                	mv	a0,a5
    80004a64:	c33ff0ef          	jal	80004696 <fileclose>
  return -1;
    80004a68:	557d                	li	a0,-1
}
    80004a6a:	70a2                	ld	ra,40(sp)
    80004a6c:	7402                	ld	s0,32(sp)
    80004a6e:	64e2                	ld	s1,24(sp)
    80004a70:	6a02                	ld	s4,0(sp)
    80004a72:	6145                	addi	sp,sp,48
    80004a74:	8082                	ret
  return -1;
    80004a76:	557d                	li	a0,-1
    80004a78:	bfcd                	j	80004a6a <pipealloc+0xb8>

0000000080004a7a <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80004a7a:	1101                	addi	sp,sp,-32
    80004a7c:	ec06                	sd	ra,24(sp)
    80004a7e:	e822                	sd	s0,16(sp)
    80004a80:	e426                	sd	s1,8(sp)
    80004a82:	e04a                	sd	s2,0(sp)
    80004a84:	1000                	addi	s0,sp,32
    80004a86:	84aa                	mv	s1,a0
    80004a88:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80004a8a:	a98fc0ef          	jal	80000d22 <acquire>
  if(writable){
    80004a8e:	02090763          	beqz	s2,80004abc <pipeclose+0x42>
    pi->writeopen = 0;
    80004a92:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80004a96:	21848513          	addi	a0,s1,536
    80004a9a:	a71fd0ef          	jal	8000250a <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80004a9e:	2204a783          	lw	a5,544(s1)
    80004aa2:	e781                	bnez	a5,80004aaa <pipeclose+0x30>
    80004aa4:	2244a783          	lw	a5,548(s1)
    80004aa8:	c38d                	beqz	a5,80004aca <pipeclose+0x50>
    release(&pi->lock);
    kfree((char*)pi);
  } else
    release(&pi->lock);
    80004aaa:	8526                	mv	a0,s1
    80004aac:	b0afc0ef          	jal	80000db6 <release>
}
    80004ab0:	60e2                	ld	ra,24(sp)
    80004ab2:	6442                	ld	s0,16(sp)
    80004ab4:	64a2                	ld	s1,8(sp)
    80004ab6:	6902                	ld	s2,0(sp)
    80004ab8:	6105                	addi	sp,sp,32
    80004aba:	8082                	ret
    pi->readopen = 0;
    80004abc:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80004ac0:	21c48513          	addi	a0,s1,540
    80004ac4:	a47fd0ef          	jal	8000250a <wakeup>
    80004ac8:	bfd9                	j	80004a9e <pipeclose+0x24>
    release(&pi->lock);
    80004aca:	8526                	mv	a0,s1
    80004acc:	aeafc0ef          	jal	80000db6 <release>
    kfree((char*)pi);
    80004ad0:	8526                	mv	a0,s1
    80004ad2:	fbdfb0ef          	jal	80000a8e <kfree>
    80004ad6:	bfe9                	j	80004ab0 <pipeclose+0x36>

0000000080004ad8 <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80004ad8:	7159                	addi	sp,sp,-112
    80004ada:	f486                	sd	ra,104(sp)
    80004adc:	f0a2                	sd	s0,96(sp)
    80004ade:	eca6                	sd	s1,88(sp)
    80004ae0:	e8ca                	sd	s2,80(sp)
    80004ae2:	e4ce                	sd	s3,72(sp)
    80004ae4:	e0d2                	sd	s4,64(sp)
    80004ae6:	fc56                	sd	s5,56(sp)
    80004ae8:	1880                	addi	s0,sp,112
    80004aea:	84aa                	mv	s1,a0
    80004aec:	8aae                	mv	s5,a1
    80004aee:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    80004af0:	9a2fd0ef          	jal	80001c92 <myproc>
    80004af4:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    80004af6:	8526                	mv	a0,s1
    80004af8:	a2afc0ef          	jal	80000d22 <acquire>
  while(i < n){
    80004afc:	0d405263          	blez	s4,80004bc0 <pipewrite+0xe8>
    80004b00:	f85a                	sd	s6,48(sp)
    80004b02:	f45e                	sd	s7,40(sp)
    80004b04:	f062                	sd	s8,32(sp)
    80004b06:	ec66                	sd	s9,24(sp)
    80004b08:	e86a                	sd	s10,16(sp)
  int i = 0;
    80004b0a:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004b0c:	f9f40c13          	addi	s8,s0,-97
    80004b10:	4b85                	li	s7,1
    80004b12:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    80004b14:	21848d13          	addi	s10,s1,536
      sleep(&pi->nwrite, &pi->lock);
    80004b18:	21c48c93          	addi	s9,s1,540
    80004b1c:	a82d                	j	80004b56 <pipewrite+0x7e>
      release(&pi->lock);
    80004b1e:	8526                	mv	a0,s1
    80004b20:	a96fc0ef          	jal	80000db6 <release>
      return -1;
    80004b24:	597d                	li	s2,-1
    80004b26:	7b42                	ld	s6,48(sp)
    80004b28:	7ba2                	ld	s7,40(sp)
    80004b2a:	7c02                	ld	s8,32(sp)
    80004b2c:	6ce2                	ld	s9,24(sp)
    80004b2e:	6d42                	ld	s10,16(sp)
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    80004b30:	854a                	mv	a0,s2
    80004b32:	70a6                	ld	ra,104(sp)
    80004b34:	7406                	ld	s0,96(sp)
    80004b36:	64e6                	ld	s1,88(sp)
    80004b38:	6946                	ld	s2,80(sp)
    80004b3a:	69a6                	ld	s3,72(sp)
    80004b3c:	6a06                	ld	s4,64(sp)
    80004b3e:	7ae2                	ld	s5,56(sp)
    80004b40:	6165                	addi	sp,sp,112
    80004b42:	8082                	ret
      wakeup(&pi->nread);
    80004b44:	856a                	mv	a0,s10
    80004b46:	9c5fd0ef          	jal	8000250a <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80004b4a:	85a6                	mv	a1,s1
    80004b4c:	8566                	mv	a0,s9
    80004b4e:	971fd0ef          	jal	800024be <sleep>
  while(i < n){
    80004b52:	05495a63          	bge	s2,s4,80004ba6 <pipewrite+0xce>
    if(pi->readopen == 0 || killed(pr)){
    80004b56:	2204a783          	lw	a5,544(s1)
    80004b5a:	d3f1                	beqz	a5,80004b1e <pipewrite+0x46>
    80004b5c:	854e                	mv	a0,s3
    80004b5e:	b9dfd0ef          	jal	800026fa <killed>
    80004b62:	fd55                	bnez	a0,80004b1e <pipewrite+0x46>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    80004b64:	2184a783          	lw	a5,536(s1)
    80004b68:	21c4a703          	lw	a4,540(s1)
    80004b6c:	2007879b          	addiw	a5,a5,512
    80004b70:	fcf70ae3          	beq	a4,a5,80004b44 <pipewrite+0x6c>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004b74:	86de                	mv	a3,s7
    80004b76:	01590633          	add	a2,s2,s5
    80004b7a:	85e2                	mv	a1,s8
    80004b7c:	0509b503          	ld	a0,80(s3)
    80004b80:	ee3fc0ef          	jal	80001a62 <copyin>
    80004b84:	05650063          	beq	a0,s6,80004bc4 <pipewrite+0xec>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80004b88:	21c4a783          	lw	a5,540(s1)
    80004b8c:	0017871b          	addiw	a4,a5,1
    80004b90:	20e4ae23          	sw	a4,540(s1)
    80004b94:	1ff7f793          	andi	a5,a5,511
    80004b98:	97a6                	add	a5,a5,s1
    80004b9a:	f9f44703          	lbu	a4,-97(s0)
    80004b9e:	00e78c23          	sb	a4,24(a5)
      i++;
    80004ba2:	2905                	addiw	s2,s2,1
    80004ba4:	b77d                	j	80004b52 <pipewrite+0x7a>
    80004ba6:	7b42                	ld	s6,48(sp)
    80004ba8:	7ba2                	ld	s7,40(sp)
    80004baa:	7c02                	ld	s8,32(sp)
    80004bac:	6ce2                	ld	s9,24(sp)
    80004bae:	6d42                	ld	s10,16(sp)
  wakeup(&pi->nread);
    80004bb0:	21848513          	addi	a0,s1,536
    80004bb4:	957fd0ef          	jal	8000250a <wakeup>
  release(&pi->lock);
    80004bb8:	8526                	mv	a0,s1
    80004bba:	9fcfc0ef          	jal	80000db6 <release>
  return i;
    80004bbe:	bf8d                	j	80004b30 <pipewrite+0x58>
  int i = 0;
    80004bc0:	4901                	li	s2,0
    80004bc2:	b7fd                	j	80004bb0 <pipewrite+0xd8>
    80004bc4:	7b42                	ld	s6,48(sp)
    80004bc6:	7ba2                	ld	s7,40(sp)
    80004bc8:	7c02                	ld	s8,32(sp)
    80004bca:	6ce2                	ld	s9,24(sp)
    80004bcc:	6d42                	ld	s10,16(sp)
    80004bce:	b7cd                	j	80004bb0 <pipewrite+0xd8>

0000000080004bd0 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80004bd0:	711d                	addi	sp,sp,-96
    80004bd2:	ec86                	sd	ra,88(sp)
    80004bd4:	e8a2                	sd	s0,80(sp)
    80004bd6:	e4a6                	sd	s1,72(sp)
    80004bd8:	e0ca                	sd	s2,64(sp)
    80004bda:	fc4e                	sd	s3,56(sp)
    80004bdc:	f852                	sd	s4,48(sp)
    80004bde:	f456                	sd	s5,40(sp)
    80004be0:	1080                	addi	s0,sp,96
    80004be2:	84aa                	mv	s1,a0
    80004be4:	892e                	mv	s2,a1
    80004be6:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80004be8:	8aafd0ef          	jal	80001c92 <myproc>
    80004bec:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80004bee:	8526                	mv	a0,s1
    80004bf0:	932fc0ef          	jal	80000d22 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004bf4:	2184a703          	lw	a4,536(s1)
    80004bf8:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004bfc:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004c00:	02f71763          	bne	a4,a5,80004c2e <piperead+0x5e>
    80004c04:	2244a783          	lw	a5,548(s1)
    80004c08:	cf85                	beqz	a5,80004c40 <piperead+0x70>
    if(killed(pr)){
    80004c0a:	8552                	mv	a0,s4
    80004c0c:	aeffd0ef          	jal	800026fa <killed>
    80004c10:	e11d                	bnez	a0,80004c36 <piperead+0x66>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004c12:	85a6                	mv	a1,s1
    80004c14:	854e                	mv	a0,s3
    80004c16:	8a9fd0ef          	jal	800024be <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004c1a:	2184a703          	lw	a4,536(s1)
    80004c1e:	21c4a783          	lw	a5,540(s1)
    80004c22:	fef701e3          	beq	a4,a5,80004c04 <piperead+0x34>
    80004c26:	f05a                	sd	s6,32(sp)
    80004c28:	ec5e                	sd	s7,24(sp)
    80004c2a:	e862                	sd	s8,16(sp)
    80004c2c:	a829                	j	80004c46 <piperead+0x76>
    80004c2e:	f05a                	sd	s6,32(sp)
    80004c30:	ec5e                	sd	s7,24(sp)
    80004c32:	e862                	sd	s8,16(sp)
    80004c34:	a809                	j	80004c46 <piperead+0x76>
      release(&pi->lock);
    80004c36:	8526                	mv	a0,s1
    80004c38:	97efc0ef          	jal	80000db6 <release>
      return -1;
    80004c3c:	59fd                	li	s3,-1
    80004c3e:	a0a5                	j	80004ca6 <piperead+0xd6>
    80004c40:	f05a                	sd	s6,32(sp)
    80004c42:	ec5e                	sd	s7,24(sp)
    80004c44:	e862                	sd	s8,16(sp)
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004c46:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1) {
    80004c48:	faf40c13          	addi	s8,s0,-81
    80004c4c:	4b85                	li	s7,1
    80004c4e:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004c50:	05505163          	blez	s5,80004c92 <piperead+0xc2>
    if(pi->nread == pi->nwrite)
    80004c54:	2184a783          	lw	a5,536(s1)
    80004c58:	21c4a703          	lw	a4,540(s1)
    80004c5c:	02f70b63          	beq	a4,a5,80004c92 <piperead+0xc2>
    ch = pi->data[pi->nread % PIPESIZE];
    80004c60:	1ff7f793          	andi	a5,a5,511
    80004c64:	97a6                	add	a5,a5,s1
    80004c66:	0187c783          	lbu	a5,24(a5)
    80004c6a:	faf407a3          	sb	a5,-81(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1) {
    80004c6e:	86de                	mv	a3,s7
    80004c70:	8662                	mv	a2,s8
    80004c72:	85ca                	mv	a1,s2
    80004c74:	050a3503          	ld	a0,80(s4)
    80004c78:	d2dfc0ef          	jal	800019a4 <copyout>
    80004c7c:	03650f63          	beq	a0,s6,80004cba <piperead+0xea>
      if(i == 0)
        i = -1;
      break;
    }
    pi->nread++;
    80004c80:	2184a783          	lw	a5,536(s1)
    80004c84:	2785                	addiw	a5,a5,1
    80004c86:	20f4ac23          	sw	a5,536(s1)
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004c8a:	2985                	addiw	s3,s3,1
    80004c8c:	0905                	addi	s2,s2,1
    80004c8e:	fd3a93e3          	bne	s5,s3,80004c54 <piperead+0x84>
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80004c92:	21c48513          	addi	a0,s1,540
    80004c96:	875fd0ef          	jal	8000250a <wakeup>
  release(&pi->lock);
    80004c9a:	8526                	mv	a0,s1
    80004c9c:	91afc0ef          	jal	80000db6 <release>
    80004ca0:	7b02                	ld	s6,32(sp)
    80004ca2:	6be2                	ld	s7,24(sp)
    80004ca4:	6c42                	ld	s8,16(sp)
  return i;
}
    80004ca6:	854e                	mv	a0,s3
    80004ca8:	60e6                	ld	ra,88(sp)
    80004caa:	6446                	ld	s0,80(sp)
    80004cac:	64a6                	ld	s1,72(sp)
    80004cae:	6906                	ld	s2,64(sp)
    80004cb0:	79e2                	ld	s3,56(sp)
    80004cb2:	7a42                	ld	s4,48(sp)
    80004cb4:	7aa2                	ld	s5,40(sp)
    80004cb6:	6125                	addi	sp,sp,96
    80004cb8:	8082                	ret
      if(i == 0)
    80004cba:	fc099ce3          	bnez	s3,80004c92 <piperead+0xc2>
        i = -1;
    80004cbe:	89aa                	mv	s3,a0
    80004cc0:	bfc9                	j	80004c92 <piperead+0xc2>

0000000080004cc2 <flags2perm>:

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

// map ELF permissions to PTE permission bits.
int flags2perm(int flags)
{
    80004cc2:	1141                	addi	sp,sp,-16
    80004cc4:	e406                	sd	ra,8(sp)
    80004cc6:	e022                	sd	s0,0(sp)
    80004cc8:	0800                	addi	s0,sp,16
    80004cca:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    80004ccc:	0035151b          	slliw	a0,a0,0x3
    80004cd0:	8921                	andi	a0,a0,8
      perm = PTE_X;
    if(flags & 0x2)
    80004cd2:	8b89                	andi	a5,a5,2
    80004cd4:	c399                	beqz	a5,80004cda <flags2perm+0x18>
      perm |= PTE_W;
    80004cd6:	00456513          	ori	a0,a0,4
    return perm;
}
    80004cda:	60a2                	ld	ra,8(sp)
    80004cdc:	6402                	ld	s0,0(sp)
    80004cde:	0141                	addi	sp,sp,16
    80004ce0:	8082                	ret

0000000080004ce2 <kexec>:
//
// the implementation of the exec() system call
//
int
kexec(char *path, char **argv)
{
    80004ce2:	de010113          	addi	sp,sp,-544
    80004ce6:	20113c23          	sd	ra,536(sp)
    80004cea:	20813823          	sd	s0,528(sp)
    80004cee:	20913423          	sd	s1,520(sp)
    80004cf2:	21213023          	sd	s2,512(sp)
    80004cf6:	1400                	addi	s0,sp,544
    80004cf8:	892a                	mv	s2,a0
    80004cfa:	dea43823          	sd	a0,-528(s0)
    80004cfe:	e0b43023          	sd	a1,-512(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80004d02:	f91fc0ef          	jal	80001c92 <myproc>
    80004d06:	84aa                	mv	s1,a0

  begin_op();
    80004d08:	d6aff0ef          	jal	80004272 <begin_op>

  // Open the executable file.
  if((ip = namei(path)) == 0){
    80004d0c:	854a                	mv	a0,s2
    80004d0e:	b86ff0ef          	jal	80004094 <namei>
    80004d12:	cd21                	beqz	a0,80004d6a <kexec+0x88>
    80004d14:	fbd2                	sd	s4,496(sp)
    80004d16:	8a2a                	mv	s4,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80004d18:	b4ffe0ef          	jal	80003866 <ilock>

  // Read the ELF header.
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80004d1c:	04000713          	li	a4,64
    80004d20:	4681                	li	a3,0
    80004d22:	e5040613          	addi	a2,s0,-432
    80004d26:	4581                	li	a1,0
    80004d28:	8552                	mv	a0,s4
    80004d2a:	ecffe0ef          	jal	80003bf8 <readi>
    80004d2e:	04000793          	li	a5,64
    80004d32:	00f51a63          	bne	a0,a5,80004d46 <kexec+0x64>
    goto bad;

  // Is this really an ELF file?
  if(elf.magic != ELF_MAGIC)
    80004d36:	e5042703          	lw	a4,-432(s0)
    80004d3a:	464c47b7          	lui	a5,0x464c4
    80004d3e:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80004d42:	02f70863          	beq	a4,a5,80004d72 <kexec+0x90>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    80004d46:	8552                	mv	a0,s4
    80004d48:	d2bfe0ef          	jal	80003a72 <iunlockput>
    end_op();
    80004d4c:	d96ff0ef          	jal	800042e2 <end_op>
  }
  return -1;
    80004d50:	557d                	li	a0,-1
    80004d52:	7a5e                	ld	s4,496(sp)
}
    80004d54:	21813083          	ld	ra,536(sp)
    80004d58:	21013403          	ld	s0,528(sp)
    80004d5c:	20813483          	ld	s1,520(sp)
    80004d60:	20013903          	ld	s2,512(sp)
    80004d64:	22010113          	addi	sp,sp,544
    80004d68:	8082                	ret
    end_op();
    80004d6a:	d78ff0ef          	jal	800042e2 <end_op>
    return -1;
    80004d6e:	557d                	li	a0,-1
    80004d70:	b7d5                	j	80004d54 <kexec+0x72>
    80004d72:	f3da                	sd	s6,480(sp)
  if((pagetable = proc_pagetable(p)) == 0)
    80004d74:	8526                	mv	a0,s1
    80004d76:	826fd0ef          	jal	80001d9c <proc_pagetable>
    80004d7a:	8b2a                	mv	s6,a0
    80004d7c:	26050f63          	beqz	a0,80004ffa <kexec+0x318>
    80004d80:	ffce                	sd	s3,504(sp)
    80004d82:	f7d6                	sd	s5,488(sp)
    80004d84:	efde                	sd	s7,472(sp)
    80004d86:	ebe2                	sd	s8,464(sp)
    80004d88:	e7e6                	sd	s9,456(sp)
    80004d8a:	e3ea                	sd	s10,448(sp)
    80004d8c:	ff6e                	sd	s11,440(sp)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004d8e:	e8845783          	lhu	a5,-376(s0)
    80004d92:	0e078963          	beqz	a5,80004e84 <kexec+0x1a2>
    80004d96:	e7042683          	lw	a3,-400(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004d9a:	4901                	li	s2,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004d9c:	4d01                	li	s10,0
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80004d9e:	03800d93          	li	s11,56
    if(ph.vaddr % PGSIZE != 0)
    80004da2:	6c85                	lui	s9,0x1
    80004da4:	fffc8793          	addi	a5,s9,-1 # fff <_entry-0x7ffff001>
    80004da8:	def43423          	sd	a5,-536(s0)

  for(i = 0; i < sz; i += PGSIZE){
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    if(sz - i < PGSIZE)
    80004dac:	6a85                	lui	s5,0x1
    80004dae:	a085                	j	80004e0e <kexec+0x12c>
      panic("loadseg: address should exist");
    80004db0:	00004517          	auipc	a0,0x4
    80004db4:	90050513          	addi	a0,a0,-1792 # 800086b0 <userret+0x1614>
    80004db8:	a9ffb0ef          	jal	80000856 <panic>
    if(sz - i < PGSIZE)
    80004dbc:	2901                	sext.w	s2,s2
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80004dbe:	874a                	mv	a4,s2
    80004dc0:	009b86bb          	addw	a3,s7,s1
    80004dc4:	4581                	li	a1,0
    80004dc6:	8552                	mv	a0,s4
    80004dc8:	e31fe0ef          	jal	80003bf8 <readi>
    80004dcc:	22a91b63          	bne	s2,a0,80005002 <kexec+0x320>
  for(i = 0; i < sz; i += PGSIZE){
    80004dd0:	009a84bb          	addw	s1,s5,s1
    80004dd4:	0334f263          	bgeu	s1,s3,80004df8 <kexec+0x116>
    pa = walkaddr(pagetable, va + i);
    80004dd8:	02049593          	slli	a1,s1,0x20
    80004ddc:	9181                	srli	a1,a1,0x20
    80004dde:	95e2                	add	a1,a1,s8
    80004de0:	855a                	mv	a0,s6
    80004de2:	b92fc0ef          	jal	80001174 <walkaddr>
    80004de6:	862a                	mv	a2,a0
    if(pa == 0)
    80004de8:	d561                	beqz	a0,80004db0 <kexec+0xce>
    if(sz - i < PGSIZE)
    80004dea:	409987bb          	subw	a5,s3,s1
    80004dee:	893e                	mv	s2,a5
    80004df0:	fcfcf6e3          	bgeu	s9,a5,80004dbc <kexec+0xda>
    80004df4:	8956                	mv	s2,s5
    80004df6:	b7d9                	j	80004dbc <kexec+0xda>
    sz = sz1;
    80004df8:	df843903          	ld	s2,-520(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004dfc:	2d05                	addiw	s10,s10,1
    80004dfe:	e0843783          	ld	a5,-504(s0)
    80004e02:	0387869b          	addiw	a3,a5,56
    80004e06:	e8845783          	lhu	a5,-376(s0)
    80004e0a:	06fd5e63          	bge	s10,a5,80004e86 <kexec+0x1a4>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80004e0e:	e0d43423          	sd	a3,-504(s0)
    80004e12:	876e                	mv	a4,s11
    80004e14:	e1840613          	addi	a2,s0,-488
    80004e18:	4581                	li	a1,0
    80004e1a:	8552                	mv	a0,s4
    80004e1c:	dddfe0ef          	jal	80003bf8 <readi>
    80004e20:	1db51f63          	bne	a0,s11,80004ffe <kexec+0x31c>
    if(ph.type != ELF_PROG_LOAD)
    80004e24:	e1842783          	lw	a5,-488(s0)
    80004e28:	4705                	li	a4,1
    80004e2a:	fce799e3          	bne	a5,a4,80004dfc <kexec+0x11a>
    if(ph.memsz < ph.filesz)
    80004e2e:	e4043483          	ld	s1,-448(s0)
    80004e32:	e3843783          	ld	a5,-456(s0)
    80004e36:	1ef4e463          	bltu	s1,a5,8000501e <kexec+0x33c>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    80004e3a:	e2843783          	ld	a5,-472(s0)
    80004e3e:	94be                	add	s1,s1,a5
    80004e40:	1ef4e263          	bltu	s1,a5,80005024 <kexec+0x342>
    if(ph.vaddr % PGSIZE != 0)
    80004e44:	de843703          	ld	a4,-536(s0)
    80004e48:	8ff9                	and	a5,a5,a4
    80004e4a:	1e079063          	bnez	a5,8000502a <kexec+0x348>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80004e4e:	e1c42503          	lw	a0,-484(s0)
    80004e52:	e71ff0ef          	jal	80004cc2 <flags2perm>
    80004e56:	86aa                	mv	a3,a0
    80004e58:	8626                	mv	a2,s1
    80004e5a:	85ca                	mv	a1,s2
    80004e5c:	855a                	mv	a0,s6
    80004e5e:	f18fc0ef          	jal	80001576 <uvmalloc>
    80004e62:	dea43c23          	sd	a0,-520(s0)
    80004e66:	1c050563          	beqz	a0,80005030 <kexec+0x34e>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80004e6a:	e3842983          	lw	s3,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    80004e6e:	00098863          	beqz	s3,80004e7e <kexec+0x19c>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80004e72:	e2843c03          	ld	s8,-472(s0)
    80004e76:	e2042b83          	lw	s7,-480(s0)
  for(i = 0; i < sz; i += PGSIZE){
    80004e7a:	4481                	li	s1,0
    80004e7c:	bfb1                	j	80004dd8 <kexec+0xf6>
    sz = sz1;
    80004e7e:	df843903          	ld	s2,-520(s0)
    80004e82:	bfad                	j	80004dfc <kexec+0x11a>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004e84:	4901                	li	s2,0
  iunlockput(ip);
    80004e86:	8552                	mv	a0,s4
    80004e88:	bebfe0ef          	jal	80003a72 <iunlockput>
  end_op();
    80004e8c:	c56ff0ef          	jal	800042e2 <end_op>
  p = myproc();
    80004e90:	e03fc0ef          	jal	80001c92 <myproc>
    80004e94:	8aaa                	mv	s5,a0
  uint64 oldsz = p->sz;
    80004e96:	04853d03          	ld	s10,72(a0)
  sz = PGROUNDUP(sz);
    80004e9a:	6985                	lui	s3,0x1
    80004e9c:	19fd                	addi	s3,s3,-1 # fff <_entry-0x7ffff001>
    80004e9e:	99ca                	add	s3,s3,s2
    80004ea0:	77fd                	lui	a5,0xfffff
    80004ea2:	00f9f9b3          	and	s3,s3,a5
  if((sz1 = uvmalloc(pagetable, sz, sz + (USERSTACK+1)*PGSIZE, PTE_W)) == 0)
    80004ea6:	4691                	li	a3,4
    80004ea8:	6609                	lui	a2,0x2
    80004eaa:	964e                	add	a2,a2,s3
    80004eac:	85ce                	mv	a1,s3
    80004eae:	855a                	mv	a0,s6
    80004eb0:	ec6fc0ef          	jal	80001576 <uvmalloc>
    80004eb4:	8a2a                	mv	s4,a0
    80004eb6:	e105                	bnez	a0,80004ed6 <kexec+0x1f4>
    proc_freepagetable(pagetable, sz);
    80004eb8:	85ce                	mv	a1,s3
    80004eba:	855a                	mv	a0,s6
    80004ebc:	f65fc0ef          	jal	80001e20 <proc_freepagetable>
  return -1;
    80004ec0:	557d                	li	a0,-1
    80004ec2:	79fe                	ld	s3,504(sp)
    80004ec4:	7a5e                	ld	s4,496(sp)
    80004ec6:	7abe                	ld	s5,488(sp)
    80004ec8:	7b1e                	ld	s6,480(sp)
    80004eca:	6bfe                	ld	s7,472(sp)
    80004ecc:	6c5e                	ld	s8,464(sp)
    80004ece:	6cbe                	ld	s9,456(sp)
    80004ed0:	6d1e                	ld	s10,448(sp)
    80004ed2:	7dfa                	ld	s11,440(sp)
    80004ed4:	b541                	j	80004d54 <kexec+0x72>
  uvmclear(pagetable, sz-(USERSTACK+1)*PGSIZE);
    80004ed6:	75f9                	lui	a1,0xffffe
    80004ed8:	95aa                	add	a1,a1,a0
    80004eda:	855a                	mv	a0,s6
    80004edc:	8effc0ef          	jal	800017ca <uvmclear>
  stackbase = sp - USERSTACK*PGSIZE;
    80004ee0:	800a0b93          	addi	s7,s4,-2048
    80004ee4:	800b8b93          	addi	s7,s7,-2048
  for(argc = 0; argv[argc]; argc++) {
    80004ee8:	e0043783          	ld	a5,-512(s0)
    80004eec:	6388                	ld	a0,0(a5)
  sp = sz;
    80004eee:	8952                	mv	s2,s4
  for(argc = 0; argv[argc]; argc++) {
    80004ef0:	4481                	li	s1,0
    ustack[argc] = sp;
    80004ef2:	e9040c93          	addi	s9,s0,-368
    if(argc >= MAXARG)
    80004ef6:	02000c13          	li	s8,32
  for(argc = 0; argv[argc]; argc++) {
    80004efa:	cd21                	beqz	a0,80004f52 <kexec+0x270>
    sp -= strlen(argv[argc]) + 1;
    80004efc:	880fc0ef          	jal	80000f7c <strlen>
    80004f00:	0015079b          	addiw	a5,a0,1
    80004f04:	40f907b3          	sub	a5,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80004f08:	ff07f913          	andi	s2,a5,-16
    if(sp < stackbase)
    80004f0c:	13796563          	bltu	s2,s7,80005036 <kexec+0x354>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80004f10:	e0043d83          	ld	s11,-512(s0)
    80004f14:	000db983          	ld	s3,0(s11)
    80004f18:	854e                	mv	a0,s3
    80004f1a:	862fc0ef          	jal	80000f7c <strlen>
    80004f1e:	0015069b          	addiw	a3,a0,1
    80004f22:	864e                	mv	a2,s3
    80004f24:	85ca                	mv	a1,s2
    80004f26:	855a                	mv	a0,s6
    80004f28:	a7dfc0ef          	jal	800019a4 <copyout>
    80004f2c:	10054763          	bltz	a0,8000503a <kexec+0x358>
    ustack[argc] = sp;
    80004f30:	00349793          	slli	a5,s1,0x3
    80004f34:	97e6                	add	a5,a5,s9
    80004f36:	0127b023          	sd	s2,0(a5) # fffffffffffff000 <end+0xffffffff7ffb6c08>
  for(argc = 0; argv[argc]; argc++) {
    80004f3a:	0485                	addi	s1,s1,1
    80004f3c:	008d8793          	addi	a5,s11,8
    80004f40:	e0f43023          	sd	a5,-512(s0)
    80004f44:	008db503          	ld	a0,8(s11)
    80004f48:	c509                	beqz	a0,80004f52 <kexec+0x270>
    if(argc >= MAXARG)
    80004f4a:	fb8499e3          	bne	s1,s8,80004efc <kexec+0x21a>
  sz = sz1;
    80004f4e:	89d2                	mv	s3,s4
    80004f50:	b7a5                	j	80004eb8 <kexec+0x1d6>
  ustack[argc] = 0;
    80004f52:	00349793          	slli	a5,s1,0x3
    80004f56:	f9078793          	addi	a5,a5,-112
    80004f5a:	97a2                	add	a5,a5,s0
    80004f5c:	f007b023          	sd	zero,-256(a5)
  sp -= (argc+1) * sizeof(uint64);
    80004f60:	00349693          	slli	a3,s1,0x3
    80004f64:	06a1                	addi	a3,a3,8
    80004f66:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    80004f6a:	ff097913          	andi	s2,s2,-16
  sz = sz1;
    80004f6e:	89d2                	mv	s3,s4
  if(sp < stackbase)
    80004f70:	f57964e3          	bltu	s2,s7,80004eb8 <kexec+0x1d6>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    80004f74:	e9040613          	addi	a2,s0,-368
    80004f78:	85ca                	mv	a1,s2
    80004f7a:	855a                	mv	a0,s6
    80004f7c:	a29fc0ef          	jal	800019a4 <copyout>
    80004f80:	f2054ce3          	bltz	a0,80004eb8 <kexec+0x1d6>
  p->trapframe->a1 = sp;
    80004f84:	058ab783          	ld	a5,88(s5) # 1058 <_entry-0x7fffefa8>
    80004f88:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    80004f8c:	df043783          	ld	a5,-528(s0)
    80004f90:	0007c703          	lbu	a4,0(a5)
    80004f94:	cf11                	beqz	a4,80004fb0 <kexec+0x2ce>
    80004f96:	0785                	addi	a5,a5,1
    if(*s == '/')
    80004f98:	02f00693          	li	a3,47
    80004f9c:	a029                	j	80004fa6 <kexec+0x2c4>
  for(last=s=path; *s; s++)
    80004f9e:	0785                	addi	a5,a5,1
    80004fa0:	fff7c703          	lbu	a4,-1(a5)
    80004fa4:	c711                	beqz	a4,80004fb0 <kexec+0x2ce>
    if(*s == '/')
    80004fa6:	fed71ce3          	bne	a4,a3,80004f9e <kexec+0x2bc>
      last = s+1;
    80004faa:	def43823          	sd	a5,-528(s0)
    80004fae:	bfc5                	j	80004f9e <kexec+0x2bc>
  safestrcpy(p->name, last, sizeof(p->name));
    80004fb0:	4641                	li	a2,16
    80004fb2:	df043583          	ld	a1,-528(s0)
    80004fb6:	158a8513          	addi	a0,s5,344
    80004fba:	f8dfb0ef          	jal	80000f46 <safestrcpy>
  oldpagetable = p->pagetable;
    80004fbe:	050ab503          	ld	a0,80(s5)
  p->pagetable = pagetable;
    80004fc2:	056ab823          	sd	s6,80(s5)
  p->sz = sz;
    80004fc6:	054ab423          	sd	s4,72(s5)
  p->trapframe->epc = elf.entry;  // initial program counter = ulib.c:start()
    80004fca:	058ab783          	ld	a5,88(s5)
    80004fce:	e6843703          	ld	a4,-408(s0)
    80004fd2:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    80004fd4:	058ab783          	ld	a5,88(s5)
    80004fd8:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    80004fdc:	85ea                	mv	a1,s10
    80004fde:	e43fc0ef          	jal	80001e20 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80004fe2:	0004851b          	sext.w	a0,s1
    80004fe6:	79fe                	ld	s3,504(sp)
    80004fe8:	7a5e                	ld	s4,496(sp)
    80004fea:	7abe                	ld	s5,488(sp)
    80004fec:	7b1e                	ld	s6,480(sp)
    80004fee:	6bfe                	ld	s7,472(sp)
    80004ff0:	6c5e                	ld	s8,464(sp)
    80004ff2:	6cbe                	ld	s9,456(sp)
    80004ff4:	6d1e                	ld	s10,448(sp)
    80004ff6:	7dfa                	ld	s11,440(sp)
    80004ff8:	bbb1                	j	80004d54 <kexec+0x72>
    80004ffa:	7b1e                	ld	s6,480(sp)
    80004ffc:	b3a9                	j	80004d46 <kexec+0x64>
    80004ffe:	df243c23          	sd	s2,-520(s0)
    proc_freepagetable(pagetable, sz);
    80005002:	df843583          	ld	a1,-520(s0)
    80005006:	855a                	mv	a0,s6
    80005008:	e19fc0ef          	jal	80001e20 <proc_freepagetable>
  if(ip){
    8000500c:	79fe                	ld	s3,504(sp)
    8000500e:	7abe                	ld	s5,488(sp)
    80005010:	7b1e                	ld	s6,480(sp)
    80005012:	6bfe                	ld	s7,472(sp)
    80005014:	6c5e                	ld	s8,464(sp)
    80005016:	6cbe                	ld	s9,456(sp)
    80005018:	6d1e                	ld	s10,448(sp)
    8000501a:	7dfa                	ld	s11,440(sp)
    8000501c:	b32d                	j	80004d46 <kexec+0x64>
    8000501e:	df243c23          	sd	s2,-520(s0)
    80005022:	b7c5                	j	80005002 <kexec+0x320>
    80005024:	df243c23          	sd	s2,-520(s0)
    80005028:	bfe9                	j	80005002 <kexec+0x320>
    8000502a:	df243c23          	sd	s2,-520(s0)
    8000502e:	bfd1                	j	80005002 <kexec+0x320>
    80005030:	df243c23          	sd	s2,-520(s0)
    80005034:	b7f9                	j	80005002 <kexec+0x320>
  sz = sz1;
    80005036:	89d2                	mv	s3,s4
    80005038:	b541                	j	80004eb8 <kexec+0x1d6>
    8000503a:	89d2                	mv	s3,s4
    8000503c:	bdb5                	j	80004eb8 <kexec+0x1d6>

000000008000503e <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    8000503e:	7179                	addi	sp,sp,-48
    80005040:	f406                	sd	ra,40(sp)
    80005042:	f022                	sd	s0,32(sp)
    80005044:	ec26                	sd	s1,24(sp)
    80005046:	e84a                	sd	s2,16(sp)
    80005048:	1800                	addi	s0,sp,48
    8000504a:	892e                	mv	s2,a1
    8000504c:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    8000504e:	fdc40593          	addi	a1,s0,-36
    80005052:	d79fd0ef          	jal	80002dca <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    80005056:	fdc42703          	lw	a4,-36(s0)
    8000505a:	47bd                	li	a5,15
    8000505c:	02e7ea63          	bltu	a5,a4,80005090 <argfd+0x52>
    80005060:	c33fc0ef          	jal	80001c92 <myproc>
    80005064:	fdc42703          	lw	a4,-36(s0)
    80005068:	00371793          	slli	a5,a4,0x3
    8000506c:	0d078793          	addi	a5,a5,208
    80005070:	953e                	add	a0,a0,a5
    80005072:	611c                	ld	a5,0(a0)
    80005074:	c385                	beqz	a5,80005094 <argfd+0x56>
    return -1;
  if(pfd)
    80005076:	00090463          	beqz	s2,8000507e <argfd+0x40>
    *pfd = fd;
    8000507a:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    8000507e:	4501                	li	a0,0
  if(pf)
    80005080:	c091                	beqz	s1,80005084 <argfd+0x46>
    *pf = f;
    80005082:	e09c                	sd	a5,0(s1)
}
    80005084:	70a2                	ld	ra,40(sp)
    80005086:	7402                	ld	s0,32(sp)
    80005088:	64e2                	ld	s1,24(sp)
    8000508a:	6942                	ld	s2,16(sp)
    8000508c:	6145                	addi	sp,sp,48
    8000508e:	8082                	ret
    return -1;
    80005090:	557d                	li	a0,-1
    80005092:	bfcd                	j	80005084 <argfd+0x46>
    80005094:	557d                	li	a0,-1
    80005096:	b7fd                	j	80005084 <argfd+0x46>

0000000080005098 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    80005098:	1101                	addi	sp,sp,-32
    8000509a:	ec06                	sd	ra,24(sp)
    8000509c:	e822                	sd	s0,16(sp)
    8000509e:	e426                	sd	s1,8(sp)
    800050a0:	1000                	addi	s0,sp,32
    800050a2:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    800050a4:	beffc0ef          	jal	80001c92 <myproc>
    800050a8:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    800050aa:	0d050793          	addi	a5,a0,208
    800050ae:	4501                	li	a0,0
    800050b0:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    800050b2:	6398                	ld	a4,0(a5)
    800050b4:	cb19                	beqz	a4,800050ca <fdalloc+0x32>
  for(fd = 0; fd < NOFILE; fd++){
    800050b6:	2505                	addiw	a0,a0,1
    800050b8:	07a1                	addi	a5,a5,8
    800050ba:	fed51ce3          	bne	a0,a3,800050b2 <fdalloc+0x1a>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    800050be:	557d                	li	a0,-1
}
    800050c0:	60e2                	ld	ra,24(sp)
    800050c2:	6442                	ld	s0,16(sp)
    800050c4:	64a2                	ld	s1,8(sp)
    800050c6:	6105                	addi	sp,sp,32
    800050c8:	8082                	ret
      p->ofile[fd] = f;
    800050ca:	00351793          	slli	a5,a0,0x3
    800050ce:	0d078793          	addi	a5,a5,208
    800050d2:	963e                	add	a2,a2,a5
    800050d4:	e204                	sd	s1,0(a2)
      return fd;
    800050d6:	b7ed                	j	800050c0 <fdalloc+0x28>

00000000800050d8 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    800050d8:	715d                	addi	sp,sp,-80
    800050da:	e486                	sd	ra,72(sp)
    800050dc:	e0a2                	sd	s0,64(sp)
    800050de:	fc26                	sd	s1,56(sp)
    800050e0:	f84a                	sd	s2,48(sp)
    800050e2:	f44e                	sd	s3,40(sp)
    800050e4:	f052                	sd	s4,32(sp)
    800050e6:	ec56                	sd	s5,24(sp)
    800050e8:	e85a                	sd	s6,16(sp)
    800050ea:	0880                	addi	s0,sp,80
    800050ec:	892e                	mv	s2,a1
    800050ee:	8a2e                	mv	s4,a1
    800050f0:	8ab2                	mv	s5,a2
    800050f2:	8b36                	mv	s6,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    800050f4:	fb040593          	addi	a1,s0,-80
    800050f8:	fb7fe0ef          	jal	800040ae <nameiparent>
    800050fc:	84aa                	mv	s1,a0
    800050fe:	10050763          	beqz	a0,8000520c <create+0x134>
    return 0;

  ilock(dp);
    80005102:	f64fe0ef          	jal	80003866 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    80005106:	4601                	li	a2,0
    80005108:	fb040593          	addi	a1,s0,-80
    8000510c:	8526                	mv	a0,s1
    8000510e:	cf3fe0ef          	jal	80003e00 <dirlookup>
    80005112:	89aa                	mv	s3,a0
    80005114:	c131                	beqz	a0,80005158 <create+0x80>
    iunlockput(dp);
    80005116:	8526                	mv	a0,s1
    80005118:	95bfe0ef          	jal	80003a72 <iunlockput>
    ilock(ip);
    8000511c:	854e                	mv	a0,s3
    8000511e:	f48fe0ef          	jal	80003866 <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80005122:	4789                	li	a5,2
    80005124:	02f91563          	bne	s2,a5,8000514e <create+0x76>
    80005128:	0449d783          	lhu	a5,68(s3)
    8000512c:	37f9                	addiw	a5,a5,-2
    8000512e:	17c2                	slli	a5,a5,0x30
    80005130:	93c1                	srli	a5,a5,0x30
    80005132:	4705                	li	a4,1
    80005134:	00f76d63          	bltu	a4,a5,8000514e <create+0x76>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    80005138:	854e                	mv	a0,s3
    8000513a:	60a6                	ld	ra,72(sp)
    8000513c:	6406                	ld	s0,64(sp)
    8000513e:	74e2                	ld	s1,56(sp)
    80005140:	7942                	ld	s2,48(sp)
    80005142:	79a2                	ld	s3,40(sp)
    80005144:	7a02                	ld	s4,32(sp)
    80005146:	6ae2                	ld	s5,24(sp)
    80005148:	6b42                	ld	s6,16(sp)
    8000514a:	6161                	addi	sp,sp,80
    8000514c:	8082                	ret
    iunlockput(ip);
    8000514e:	854e                	mv	a0,s3
    80005150:	923fe0ef          	jal	80003a72 <iunlockput>
    return 0;
    80005154:	4981                	li	s3,0
    80005156:	b7cd                	j	80005138 <create+0x60>
  if((ip = ialloc(dp->dev, type)) == 0){
    80005158:	85ca                	mv	a1,s2
    8000515a:	4088                	lw	a0,0(s1)
    8000515c:	d9afe0ef          	jal	800036f6 <ialloc>
    80005160:	892a                	mv	s2,a0
    80005162:	cd15                	beqz	a0,8000519e <create+0xc6>
  ilock(ip);
    80005164:	f02fe0ef          	jal	80003866 <ilock>
  ip->major = major;
    80005168:	05591323          	sh	s5,70(s2)
  ip->minor = minor;
    8000516c:	05691423          	sh	s6,72(s2)
  ip->nlink = 1;
    80005170:	4785                	li	a5,1
    80005172:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80005176:	854a                	mv	a0,s2
    80005178:	e3afe0ef          	jal	800037b2 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    8000517c:	4705                	li	a4,1
    8000517e:	02ea0463          	beq	s4,a4,800051a6 <create+0xce>
  if(dirlink(dp, name, ip->inum) < 0)
    80005182:	00492603          	lw	a2,4(s2)
    80005186:	fb040593          	addi	a1,s0,-80
    8000518a:	8526                	mv	a0,s1
    8000518c:	e5ffe0ef          	jal	80003fea <dirlink>
    80005190:	06054263          	bltz	a0,800051f4 <create+0x11c>
  iunlockput(dp);
    80005194:	8526                	mv	a0,s1
    80005196:	8ddfe0ef          	jal	80003a72 <iunlockput>
  return ip;
    8000519a:	89ca                	mv	s3,s2
    8000519c:	bf71                	j	80005138 <create+0x60>
    iunlockput(dp);
    8000519e:	8526                	mv	a0,s1
    800051a0:	8d3fe0ef          	jal	80003a72 <iunlockput>
    return 0;
    800051a4:	bf51                	j	80005138 <create+0x60>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    800051a6:	00492603          	lw	a2,4(s2)
    800051aa:	00003597          	auipc	a1,0x3
    800051ae:	52658593          	addi	a1,a1,1318 # 800086d0 <userret+0x1634>
    800051b2:	854a                	mv	a0,s2
    800051b4:	e37fe0ef          	jal	80003fea <dirlink>
    800051b8:	02054e63          	bltz	a0,800051f4 <create+0x11c>
    800051bc:	40d0                	lw	a2,4(s1)
    800051be:	00003597          	auipc	a1,0x3
    800051c2:	51a58593          	addi	a1,a1,1306 # 800086d8 <userret+0x163c>
    800051c6:	854a                	mv	a0,s2
    800051c8:	e23fe0ef          	jal	80003fea <dirlink>
    800051cc:	02054463          	bltz	a0,800051f4 <create+0x11c>
  if(dirlink(dp, name, ip->inum) < 0)
    800051d0:	00492603          	lw	a2,4(s2)
    800051d4:	fb040593          	addi	a1,s0,-80
    800051d8:	8526                	mv	a0,s1
    800051da:	e11fe0ef          	jal	80003fea <dirlink>
    800051de:	00054b63          	bltz	a0,800051f4 <create+0x11c>
    dp->nlink++;  // for ".."
    800051e2:	04a4d783          	lhu	a5,74(s1)
    800051e6:	2785                	addiw	a5,a5,1
    800051e8:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    800051ec:	8526                	mv	a0,s1
    800051ee:	dc4fe0ef          	jal	800037b2 <iupdate>
    800051f2:	b74d                	j	80005194 <create+0xbc>
  ip->nlink = 0;
    800051f4:	04091523          	sh	zero,74(s2)
  iupdate(ip);
    800051f8:	854a                	mv	a0,s2
    800051fa:	db8fe0ef          	jal	800037b2 <iupdate>
  iunlockput(ip);
    800051fe:	854a                	mv	a0,s2
    80005200:	873fe0ef          	jal	80003a72 <iunlockput>
  iunlockput(dp);
    80005204:	8526                	mv	a0,s1
    80005206:	86dfe0ef          	jal	80003a72 <iunlockput>
  return 0;
    8000520a:	b73d                	j	80005138 <create+0x60>
    return 0;
    8000520c:	89aa                	mv	s3,a0
    8000520e:	b72d                	j	80005138 <create+0x60>

0000000080005210 <sys_dup>:
{
    80005210:	7179                	addi	sp,sp,-48
    80005212:	f406                	sd	ra,40(sp)
    80005214:	f022                	sd	s0,32(sp)
    80005216:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    80005218:	fd840613          	addi	a2,s0,-40
    8000521c:	4581                	li	a1,0
    8000521e:	4501                	li	a0,0
    80005220:	e1fff0ef          	jal	8000503e <argfd>
    return -1;
    80005224:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    80005226:	02054363          	bltz	a0,8000524c <sys_dup+0x3c>
    8000522a:	ec26                	sd	s1,24(sp)
    8000522c:	e84a                	sd	s2,16(sp)
  if((fd=fdalloc(f)) < 0)
    8000522e:	fd843483          	ld	s1,-40(s0)
    80005232:	8526                	mv	a0,s1
    80005234:	e65ff0ef          	jal	80005098 <fdalloc>
    80005238:	892a                	mv	s2,a0
    return -1;
    8000523a:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    8000523c:	00054d63          	bltz	a0,80005256 <sys_dup+0x46>
  filedup(f);
    80005240:	8526                	mv	a0,s1
    80005242:	c0eff0ef          	jal	80004650 <filedup>
  return fd;
    80005246:	87ca                	mv	a5,s2
    80005248:	64e2                	ld	s1,24(sp)
    8000524a:	6942                	ld	s2,16(sp)
}
    8000524c:	853e                	mv	a0,a5
    8000524e:	70a2                	ld	ra,40(sp)
    80005250:	7402                	ld	s0,32(sp)
    80005252:	6145                	addi	sp,sp,48
    80005254:	8082                	ret
    80005256:	64e2                	ld	s1,24(sp)
    80005258:	6942                	ld	s2,16(sp)
    8000525a:	bfcd                	j	8000524c <sys_dup+0x3c>

000000008000525c <sys_read>:
{
    8000525c:	7179                	addi	sp,sp,-48
    8000525e:	f406                	sd	ra,40(sp)
    80005260:	f022                	sd	s0,32(sp)
    80005262:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80005264:	fd840593          	addi	a1,s0,-40
    80005268:	4505                	li	a0,1
    8000526a:	b7dfd0ef          	jal	80002de6 <argaddr>
  argint(2, &n);
    8000526e:	fe440593          	addi	a1,s0,-28
    80005272:	4509                	li	a0,2
    80005274:	b57fd0ef          	jal	80002dca <argint>
  if(argfd(0, 0, &f) < 0)
    80005278:	fe840613          	addi	a2,s0,-24
    8000527c:	4581                	li	a1,0
    8000527e:	4501                	li	a0,0
    80005280:	dbfff0ef          	jal	8000503e <argfd>
    80005284:	87aa                	mv	a5,a0
    return -1;
    80005286:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80005288:	0007ca63          	bltz	a5,8000529c <sys_read+0x40>
  return fileread(f, p, n);
    8000528c:	fe442603          	lw	a2,-28(s0)
    80005290:	fd843583          	ld	a1,-40(s0)
    80005294:	fe843503          	ld	a0,-24(s0)
    80005298:	d22ff0ef          	jal	800047ba <fileread>
}
    8000529c:	70a2                	ld	ra,40(sp)
    8000529e:	7402                	ld	s0,32(sp)
    800052a0:	6145                	addi	sp,sp,48
    800052a2:	8082                	ret

00000000800052a4 <sys_write>:
{
    800052a4:	7179                	addi	sp,sp,-48
    800052a6:	f406                	sd	ra,40(sp)
    800052a8:	f022                	sd	s0,32(sp)
    800052aa:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    800052ac:	fd840593          	addi	a1,s0,-40
    800052b0:	4505                	li	a0,1
    800052b2:	b35fd0ef          	jal	80002de6 <argaddr>
  argint(2, &n);
    800052b6:	fe440593          	addi	a1,s0,-28
    800052ba:	4509                	li	a0,2
    800052bc:	b0ffd0ef          	jal	80002dca <argint>
  if(argfd(0, 0, &f) < 0)
    800052c0:	fe840613          	addi	a2,s0,-24
    800052c4:	4581                	li	a1,0
    800052c6:	4501                	li	a0,0
    800052c8:	d77ff0ef          	jal	8000503e <argfd>
    800052cc:	87aa                	mv	a5,a0
    return -1;
    800052ce:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    800052d0:	0007ca63          	bltz	a5,800052e4 <sys_write+0x40>
  return filewrite(f, p, n);
    800052d4:	fe442603          	lw	a2,-28(s0)
    800052d8:	fd843583          	ld	a1,-40(s0)
    800052dc:	fe843503          	ld	a0,-24(s0)
    800052e0:	d9eff0ef          	jal	8000487e <filewrite>
}
    800052e4:	70a2                	ld	ra,40(sp)
    800052e6:	7402                	ld	s0,32(sp)
    800052e8:	6145                	addi	sp,sp,48
    800052ea:	8082                	ret

00000000800052ec <sys_close>:
{
    800052ec:	1101                	addi	sp,sp,-32
    800052ee:	ec06                	sd	ra,24(sp)
    800052f0:	e822                	sd	s0,16(sp)
    800052f2:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    800052f4:	fe040613          	addi	a2,s0,-32
    800052f8:	fec40593          	addi	a1,s0,-20
    800052fc:	4501                	li	a0,0
    800052fe:	d41ff0ef          	jal	8000503e <argfd>
    return -1;
    80005302:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    80005304:	02054163          	bltz	a0,80005326 <sys_close+0x3a>
  myproc()->ofile[fd] = 0;
    80005308:	98bfc0ef          	jal	80001c92 <myproc>
    8000530c:	fec42783          	lw	a5,-20(s0)
    80005310:	078e                	slli	a5,a5,0x3
    80005312:	0d078793          	addi	a5,a5,208
    80005316:	953e                	add	a0,a0,a5
    80005318:	00053023          	sd	zero,0(a0)
  fileclose(f);
    8000531c:	fe043503          	ld	a0,-32(s0)
    80005320:	b76ff0ef          	jal	80004696 <fileclose>
  return 0;
    80005324:	4781                	li	a5,0
}
    80005326:	853e                	mv	a0,a5
    80005328:	60e2                	ld	ra,24(sp)
    8000532a:	6442                	ld	s0,16(sp)
    8000532c:	6105                	addi	sp,sp,32
    8000532e:	8082                	ret

0000000080005330 <sys_fstat>:
{
    80005330:	1101                	addi	sp,sp,-32
    80005332:	ec06                	sd	ra,24(sp)
    80005334:	e822                	sd	s0,16(sp)
    80005336:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    80005338:	fe040593          	addi	a1,s0,-32
    8000533c:	4505                	li	a0,1
    8000533e:	aa9fd0ef          	jal	80002de6 <argaddr>
  if(argfd(0, 0, &f) < 0)
    80005342:	fe840613          	addi	a2,s0,-24
    80005346:	4581                	li	a1,0
    80005348:	4501                	li	a0,0
    8000534a:	cf5ff0ef          	jal	8000503e <argfd>
    8000534e:	87aa                	mv	a5,a0
    return -1;
    80005350:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80005352:	0007c863          	bltz	a5,80005362 <sys_fstat+0x32>
  return filestat(f, st);
    80005356:	fe043583          	ld	a1,-32(s0)
    8000535a:	fe843503          	ld	a0,-24(s0)
    8000535e:	bfaff0ef          	jal	80004758 <filestat>
}
    80005362:	60e2                	ld	ra,24(sp)
    80005364:	6442                	ld	s0,16(sp)
    80005366:	6105                	addi	sp,sp,32
    80005368:	8082                	ret

000000008000536a <sys_link>:
{
    8000536a:	7169                	addi	sp,sp,-304
    8000536c:	f606                	sd	ra,296(sp)
    8000536e:	f222                	sd	s0,288(sp)
    80005370:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005372:	08000613          	li	a2,128
    80005376:	ed040593          	addi	a1,s0,-304
    8000537a:	4501                	li	a0,0
    8000537c:	a87fd0ef          	jal	80002e02 <argstr>
    return -1;
    80005380:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005382:	0c054e63          	bltz	a0,8000545e <sys_link+0xf4>
    80005386:	08000613          	li	a2,128
    8000538a:	f5040593          	addi	a1,s0,-176
    8000538e:	4505                	li	a0,1
    80005390:	a73fd0ef          	jal	80002e02 <argstr>
    return -1;
    80005394:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005396:	0c054463          	bltz	a0,8000545e <sys_link+0xf4>
    8000539a:	ee26                	sd	s1,280(sp)
  begin_op();
    8000539c:	ed7fe0ef          	jal	80004272 <begin_op>
  if((ip = namei(old)) == 0){
    800053a0:	ed040513          	addi	a0,s0,-304
    800053a4:	cf1fe0ef          	jal	80004094 <namei>
    800053a8:	84aa                	mv	s1,a0
    800053aa:	c53d                	beqz	a0,80005418 <sys_link+0xae>
  ilock(ip);
    800053ac:	cbafe0ef          	jal	80003866 <ilock>
  if(ip->type == T_DIR){
    800053b0:	04449703          	lh	a4,68(s1)
    800053b4:	4785                	li	a5,1
    800053b6:	06f70663          	beq	a4,a5,80005422 <sys_link+0xb8>
    800053ba:	ea4a                	sd	s2,272(sp)
  ip->nlink++;
    800053bc:	04a4d783          	lhu	a5,74(s1)
    800053c0:	2785                	addiw	a5,a5,1
    800053c2:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    800053c6:	8526                	mv	a0,s1
    800053c8:	beafe0ef          	jal	800037b2 <iupdate>
  iunlock(ip);
    800053cc:	8526                	mv	a0,s1
    800053ce:	d46fe0ef          	jal	80003914 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    800053d2:	fd040593          	addi	a1,s0,-48
    800053d6:	f5040513          	addi	a0,s0,-176
    800053da:	cd5fe0ef          	jal	800040ae <nameiparent>
    800053de:	892a                	mv	s2,a0
    800053e0:	cd21                	beqz	a0,80005438 <sys_link+0xce>
  ilock(dp);
    800053e2:	c84fe0ef          	jal	80003866 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    800053e6:	854a                	mv	a0,s2
    800053e8:	00092703          	lw	a4,0(s2)
    800053ec:	409c                	lw	a5,0(s1)
    800053ee:	04f71263          	bne	a4,a5,80005432 <sys_link+0xc8>
    800053f2:	40d0                	lw	a2,4(s1)
    800053f4:	fd040593          	addi	a1,s0,-48
    800053f8:	bf3fe0ef          	jal	80003fea <dirlink>
    800053fc:	02054b63          	bltz	a0,80005432 <sys_link+0xc8>
  iunlockput(dp);
    80005400:	854a                	mv	a0,s2
    80005402:	e70fe0ef          	jal	80003a72 <iunlockput>
  iput(ip);
    80005406:	8526                	mv	a0,s1
    80005408:	de0fe0ef          	jal	800039e8 <iput>
  end_op();
    8000540c:	ed7fe0ef          	jal	800042e2 <end_op>
  return 0;
    80005410:	4781                	li	a5,0
    80005412:	64f2                	ld	s1,280(sp)
    80005414:	6952                	ld	s2,272(sp)
    80005416:	a0a1                	j	8000545e <sys_link+0xf4>
    end_op();
    80005418:	ecbfe0ef          	jal	800042e2 <end_op>
    return -1;
    8000541c:	57fd                	li	a5,-1
    8000541e:	64f2                	ld	s1,280(sp)
    80005420:	a83d                	j	8000545e <sys_link+0xf4>
    iunlockput(ip);
    80005422:	8526                	mv	a0,s1
    80005424:	e4efe0ef          	jal	80003a72 <iunlockput>
    end_op();
    80005428:	ebbfe0ef          	jal	800042e2 <end_op>
    return -1;
    8000542c:	57fd                	li	a5,-1
    8000542e:	64f2                	ld	s1,280(sp)
    80005430:	a03d                	j	8000545e <sys_link+0xf4>
    iunlockput(dp);
    80005432:	854a                	mv	a0,s2
    80005434:	e3efe0ef          	jal	80003a72 <iunlockput>
  ilock(ip);
    80005438:	8526                	mv	a0,s1
    8000543a:	c2cfe0ef          	jal	80003866 <ilock>
  ip->nlink--;
    8000543e:	04a4d783          	lhu	a5,74(s1)
    80005442:	37fd                	addiw	a5,a5,-1
    80005444:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005448:	8526                	mv	a0,s1
    8000544a:	b68fe0ef          	jal	800037b2 <iupdate>
  iunlockput(ip);
    8000544e:	8526                	mv	a0,s1
    80005450:	e22fe0ef          	jal	80003a72 <iunlockput>
  end_op();
    80005454:	e8ffe0ef          	jal	800042e2 <end_op>
  return -1;
    80005458:	57fd                	li	a5,-1
    8000545a:	64f2                	ld	s1,280(sp)
    8000545c:	6952                	ld	s2,272(sp)
}
    8000545e:	853e                	mv	a0,a5
    80005460:	70b2                	ld	ra,296(sp)
    80005462:	7412                	ld	s0,288(sp)
    80005464:	6155                	addi	sp,sp,304
    80005466:	8082                	ret

0000000080005468 <sys_unlink>:
{
    80005468:	7151                	addi	sp,sp,-240
    8000546a:	f586                	sd	ra,232(sp)
    8000546c:	f1a2                	sd	s0,224(sp)
    8000546e:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    80005470:	08000613          	li	a2,128
    80005474:	f3040593          	addi	a1,s0,-208
    80005478:	4501                	li	a0,0
    8000547a:	989fd0ef          	jal	80002e02 <argstr>
    8000547e:	14054d63          	bltz	a0,800055d8 <sys_unlink+0x170>
    80005482:	eda6                	sd	s1,216(sp)
  begin_op();
    80005484:	deffe0ef          	jal	80004272 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    80005488:	fb040593          	addi	a1,s0,-80
    8000548c:	f3040513          	addi	a0,s0,-208
    80005490:	c1ffe0ef          	jal	800040ae <nameiparent>
    80005494:	84aa                	mv	s1,a0
    80005496:	c955                	beqz	a0,8000554a <sys_unlink+0xe2>
  ilock(dp);
    80005498:	bcefe0ef          	jal	80003866 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    8000549c:	00003597          	auipc	a1,0x3
    800054a0:	23458593          	addi	a1,a1,564 # 800086d0 <userret+0x1634>
    800054a4:	fb040513          	addi	a0,s0,-80
    800054a8:	943fe0ef          	jal	80003dea <namecmp>
    800054ac:	10050b63          	beqz	a0,800055c2 <sys_unlink+0x15a>
    800054b0:	00003597          	auipc	a1,0x3
    800054b4:	22858593          	addi	a1,a1,552 # 800086d8 <userret+0x163c>
    800054b8:	fb040513          	addi	a0,s0,-80
    800054bc:	92ffe0ef          	jal	80003dea <namecmp>
    800054c0:	10050163          	beqz	a0,800055c2 <sys_unlink+0x15a>
    800054c4:	e9ca                	sd	s2,208(sp)
  if((ip = dirlookup(dp, name, &off)) == 0)
    800054c6:	f2c40613          	addi	a2,s0,-212
    800054ca:	fb040593          	addi	a1,s0,-80
    800054ce:	8526                	mv	a0,s1
    800054d0:	931fe0ef          	jal	80003e00 <dirlookup>
    800054d4:	892a                	mv	s2,a0
    800054d6:	0e050563          	beqz	a0,800055c0 <sys_unlink+0x158>
    800054da:	e5ce                	sd	s3,200(sp)
  ilock(ip);
    800054dc:	b8afe0ef          	jal	80003866 <ilock>
  if(ip->nlink < 1)
    800054e0:	04a91783          	lh	a5,74(s2)
    800054e4:	06f05863          	blez	a5,80005554 <sys_unlink+0xec>
  if(ip->type == T_DIR && !isdirempty(ip)){
    800054e8:	04491703          	lh	a4,68(s2)
    800054ec:	4785                	li	a5,1
    800054ee:	06f70963          	beq	a4,a5,80005560 <sys_unlink+0xf8>
  memset(&de, 0, sizeof(de));
    800054f2:	fc040993          	addi	s3,s0,-64
    800054f6:	4641                	li	a2,16
    800054f8:	4581                	li	a1,0
    800054fa:	854e                	mv	a0,s3
    800054fc:	8f7fb0ef          	jal	80000df2 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005500:	4741                	li	a4,16
    80005502:	f2c42683          	lw	a3,-212(s0)
    80005506:	864e                	mv	a2,s3
    80005508:	4581                	li	a1,0
    8000550a:	8526                	mv	a0,s1
    8000550c:	fdefe0ef          	jal	80003cea <writei>
    80005510:	47c1                	li	a5,16
    80005512:	08f51863          	bne	a0,a5,800055a2 <sys_unlink+0x13a>
  if(ip->type == T_DIR){
    80005516:	04491703          	lh	a4,68(s2)
    8000551a:	4785                	li	a5,1
    8000551c:	08f70963          	beq	a4,a5,800055ae <sys_unlink+0x146>
  iunlockput(dp);
    80005520:	8526                	mv	a0,s1
    80005522:	d50fe0ef          	jal	80003a72 <iunlockput>
  ip->nlink--;
    80005526:	04a95783          	lhu	a5,74(s2)
    8000552a:	37fd                	addiw	a5,a5,-1
    8000552c:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80005530:	854a                	mv	a0,s2
    80005532:	a80fe0ef          	jal	800037b2 <iupdate>
  iunlockput(ip);
    80005536:	854a                	mv	a0,s2
    80005538:	d3afe0ef          	jal	80003a72 <iunlockput>
  end_op();
    8000553c:	da7fe0ef          	jal	800042e2 <end_op>
  return 0;
    80005540:	4501                	li	a0,0
    80005542:	64ee                	ld	s1,216(sp)
    80005544:	694e                	ld	s2,208(sp)
    80005546:	69ae                	ld	s3,200(sp)
    80005548:	a061                	j	800055d0 <sys_unlink+0x168>
    end_op();
    8000554a:	d99fe0ef          	jal	800042e2 <end_op>
    return -1;
    8000554e:	557d                	li	a0,-1
    80005550:	64ee                	ld	s1,216(sp)
    80005552:	a8bd                	j	800055d0 <sys_unlink+0x168>
    panic("unlink: nlink < 1");
    80005554:	00003517          	auipc	a0,0x3
    80005558:	18c50513          	addi	a0,a0,396 # 800086e0 <userret+0x1644>
    8000555c:	afafb0ef          	jal	80000856 <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005560:	04c92703          	lw	a4,76(s2)
    80005564:	02000793          	li	a5,32
    80005568:	f8e7f5e3          	bgeu	a5,a4,800054f2 <sys_unlink+0x8a>
    8000556c:	89be                	mv	s3,a5
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000556e:	4741                	li	a4,16
    80005570:	86ce                	mv	a3,s3
    80005572:	f1840613          	addi	a2,s0,-232
    80005576:	4581                	li	a1,0
    80005578:	854a                	mv	a0,s2
    8000557a:	e7efe0ef          	jal	80003bf8 <readi>
    8000557e:	47c1                	li	a5,16
    80005580:	00f51b63          	bne	a0,a5,80005596 <sys_unlink+0x12e>
    if(de.inum != 0)
    80005584:	f1845783          	lhu	a5,-232(s0)
    80005588:	ebb1                	bnez	a5,800055dc <sys_unlink+0x174>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    8000558a:	29c1                	addiw	s3,s3,16
    8000558c:	04c92783          	lw	a5,76(s2)
    80005590:	fcf9efe3          	bltu	s3,a5,8000556e <sys_unlink+0x106>
    80005594:	bfb9                	j	800054f2 <sys_unlink+0x8a>
      panic("isdirempty: readi");
    80005596:	00003517          	auipc	a0,0x3
    8000559a:	16250513          	addi	a0,a0,354 # 800086f8 <userret+0x165c>
    8000559e:	ab8fb0ef          	jal	80000856 <panic>
    panic("unlink: writei");
    800055a2:	00003517          	auipc	a0,0x3
    800055a6:	16e50513          	addi	a0,a0,366 # 80008710 <userret+0x1674>
    800055aa:	aacfb0ef          	jal	80000856 <panic>
    dp->nlink--;
    800055ae:	04a4d783          	lhu	a5,74(s1)
    800055b2:	37fd                	addiw	a5,a5,-1
    800055b4:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    800055b8:	8526                	mv	a0,s1
    800055ba:	9f8fe0ef          	jal	800037b2 <iupdate>
    800055be:	b78d                	j	80005520 <sys_unlink+0xb8>
    800055c0:	694e                	ld	s2,208(sp)
  iunlockput(dp);
    800055c2:	8526                	mv	a0,s1
    800055c4:	caefe0ef          	jal	80003a72 <iunlockput>
  end_op();
    800055c8:	d1bfe0ef          	jal	800042e2 <end_op>
  return -1;
    800055cc:	557d                	li	a0,-1
    800055ce:	64ee                	ld	s1,216(sp)
}
    800055d0:	70ae                	ld	ra,232(sp)
    800055d2:	740e                	ld	s0,224(sp)
    800055d4:	616d                	addi	sp,sp,240
    800055d6:	8082                	ret
    return -1;
    800055d8:	557d                	li	a0,-1
    800055da:	bfdd                	j	800055d0 <sys_unlink+0x168>
    iunlockput(ip);
    800055dc:	854a                	mv	a0,s2
    800055de:	c94fe0ef          	jal	80003a72 <iunlockput>
    goto bad;
    800055e2:	694e                	ld	s2,208(sp)
    800055e4:	69ae                	ld	s3,200(sp)
    800055e6:	bff1                	j	800055c2 <sys_unlink+0x15a>

00000000800055e8 <sys_open>:

uint64
sys_open(void)
{
    800055e8:	7131                	addi	sp,sp,-192
    800055ea:	fd06                	sd	ra,184(sp)
    800055ec:	f922                	sd	s0,176(sp)
    800055ee:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    800055f0:	f4c40593          	addi	a1,s0,-180
    800055f4:	4505                	li	a0,1
    800055f6:	fd4fd0ef          	jal	80002dca <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    800055fa:	08000613          	li	a2,128
    800055fe:	f5040593          	addi	a1,s0,-176
    80005602:	4501                	li	a0,0
    80005604:	ffefd0ef          	jal	80002e02 <argstr>
    80005608:	87aa                	mv	a5,a0
    return -1;
    8000560a:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    8000560c:	0a07c363          	bltz	a5,800056b2 <sys_open+0xca>
    80005610:	f526                	sd	s1,168(sp)

  begin_op();
    80005612:	c61fe0ef          	jal	80004272 <begin_op>

  if(omode & O_CREATE){
    80005616:	f4c42783          	lw	a5,-180(s0)
    8000561a:	2007f793          	andi	a5,a5,512
    8000561e:	c3dd                	beqz	a5,800056c4 <sys_open+0xdc>
    ip = create(path, T_FILE, 0, 0);
    80005620:	4681                	li	a3,0
    80005622:	4601                	li	a2,0
    80005624:	4589                	li	a1,2
    80005626:	f5040513          	addi	a0,s0,-176
    8000562a:	aafff0ef          	jal	800050d8 <create>
    8000562e:	84aa                	mv	s1,a0
    if(ip == 0){
    80005630:	c549                	beqz	a0,800056ba <sys_open+0xd2>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    80005632:	04449703          	lh	a4,68(s1)
    80005636:	478d                	li	a5,3
    80005638:	00f71763          	bne	a4,a5,80005646 <sys_open+0x5e>
    8000563c:	0464d703          	lhu	a4,70(s1)
    80005640:	47a5                	li	a5,9
    80005642:	0ae7ee63          	bltu	a5,a4,800056fe <sys_open+0x116>
    80005646:	f14a                	sd	s2,160(sp)
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    80005648:	fabfe0ef          	jal	800045f2 <filealloc>
    8000564c:	892a                	mv	s2,a0
    8000564e:	c561                	beqz	a0,80005716 <sys_open+0x12e>
    80005650:	ed4e                	sd	s3,152(sp)
    80005652:	a47ff0ef          	jal	80005098 <fdalloc>
    80005656:	89aa                	mv	s3,a0
    80005658:	0a054b63          	bltz	a0,8000570e <sys_open+0x126>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    8000565c:	04449703          	lh	a4,68(s1)
    80005660:	478d                	li	a5,3
    80005662:	0cf70363          	beq	a4,a5,80005728 <sys_open+0x140>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80005666:	4789                	li	a5,2
    80005668:	00f92023          	sw	a5,0(s2)
    f->off = 0;
    8000566c:	02092023          	sw	zero,32(s2)
  }
  f->ip = ip;
    80005670:	00993c23          	sd	s1,24(s2)
  f->readable = !(omode & O_WRONLY);
    80005674:	f4c42783          	lw	a5,-180(s0)
    80005678:	0017f713          	andi	a4,a5,1
    8000567c:	00174713          	xori	a4,a4,1
    80005680:	00e90423          	sb	a4,8(s2)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80005684:	0037f713          	andi	a4,a5,3
    80005688:	00e03733          	snez	a4,a4
    8000568c:	00e904a3          	sb	a4,9(s2)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    80005690:	4007f793          	andi	a5,a5,1024
    80005694:	c791                	beqz	a5,800056a0 <sys_open+0xb8>
    80005696:	04449703          	lh	a4,68(s1)
    8000569a:	4789                	li	a5,2
    8000569c:	08f70d63          	beq	a4,a5,80005736 <sys_open+0x14e>
    itrunc(ip);
  }

  iunlock(ip);
    800056a0:	8526                	mv	a0,s1
    800056a2:	a72fe0ef          	jal	80003914 <iunlock>
  end_op();
    800056a6:	c3dfe0ef          	jal	800042e2 <end_op>

  return fd;
    800056aa:	854e                	mv	a0,s3
    800056ac:	74aa                	ld	s1,168(sp)
    800056ae:	790a                	ld	s2,160(sp)
    800056b0:	69ea                	ld	s3,152(sp)
}
    800056b2:	70ea                	ld	ra,184(sp)
    800056b4:	744a                	ld	s0,176(sp)
    800056b6:	6129                	addi	sp,sp,192
    800056b8:	8082                	ret
      end_op();
    800056ba:	c29fe0ef          	jal	800042e2 <end_op>
      return -1;
    800056be:	557d                	li	a0,-1
    800056c0:	74aa                	ld	s1,168(sp)
    800056c2:	bfc5                	j	800056b2 <sys_open+0xca>
    if((ip = namei(path)) == 0){
    800056c4:	f5040513          	addi	a0,s0,-176
    800056c8:	9cdfe0ef          	jal	80004094 <namei>
    800056cc:	84aa                	mv	s1,a0
    800056ce:	c11d                	beqz	a0,800056f4 <sys_open+0x10c>
    ilock(ip);
    800056d0:	996fe0ef          	jal	80003866 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    800056d4:	04449703          	lh	a4,68(s1)
    800056d8:	4785                	li	a5,1
    800056da:	f4f71ce3          	bne	a4,a5,80005632 <sys_open+0x4a>
    800056de:	f4c42783          	lw	a5,-180(s0)
    800056e2:	d3b5                	beqz	a5,80005646 <sys_open+0x5e>
      iunlockput(ip);
    800056e4:	8526                	mv	a0,s1
    800056e6:	b8cfe0ef          	jal	80003a72 <iunlockput>
      end_op();
    800056ea:	bf9fe0ef          	jal	800042e2 <end_op>
      return -1;
    800056ee:	557d                	li	a0,-1
    800056f0:	74aa                	ld	s1,168(sp)
    800056f2:	b7c1                	j	800056b2 <sys_open+0xca>
      end_op();
    800056f4:	beffe0ef          	jal	800042e2 <end_op>
      return -1;
    800056f8:	557d                	li	a0,-1
    800056fa:	74aa                	ld	s1,168(sp)
    800056fc:	bf5d                	j	800056b2 <sys_open+0xca>
    iunlockput(ip);
    800056fe:	8526                	mv	a0,s1
    80005700:	b72fe0ef          	jal	80003a72 <iunlockput>
    end_op();
    80005704:	bdffe0ef          	jal	800042e2 <end_op>
    return -1;
    80005708:	557d                	li	a0,-1
    8000570a:	74aa                	ld	s1,168(sp)
    8000570c:	b75d                	j	800056b2 <sys_open+0xca>
      fileclose(f);
    8000570e:	854a                	mv	a0,s2
    80005710:	f87fe0ef          	jal	80004696 <fileclose>
    80005714:	69ea                	ld	s3,152(sp)
    iunlockput(ip);
    80005716:	8526                	mv	a0,s1
    80005718:	b5afe0ef          	jal	80003a72 <iunlockput>
    end_op();
    8000571c:	bc7fe0ef          	jal	800042e2 <end_op>
    return -1;
    80005720:	557d                	li	a0,-1
    80005722:	74aa                	ld	s1,168(sp)
    80005724:	790a                	ld	s2,160(sp)
    80005726:	b771                	j	800056b2 <sys_open+0xca>
    f->type = FD_DEVICE;
    80005728:	00e92023          	sw	a4,0(s2)
    f->major = ip->major;
    8000572c:	04649783          	lh	a5,70(s1)
    80005730:	02f91223          	sh	a5,36(s2)
    80005734:	bf35                	j	80005670 <sys_open+0x88>
    itrunc(ip);
    80005736:	8526                	mv	a0,s1
    80005738:	a1cfe0ef          	jal	80003954 <itrunc>
    8000573c:	b795                	j	800056a0 <sys_open+0xb8>

000000008000573e <sys_mkdir>:

uint64
sys_mkdir(void)
{
    8000573e:	7175                	addi	sp,sp,-144
    80005740:	e506                	sd	ra,136(sp)
    80005742:	e122                	sd	s0,128(sp)
    80005744:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80005746:	b2dfe0ef          	jal	80004272 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    8000574a:	08000613          	li	a2,128
    8000574e:	f7040593          	addi	a1,s0,-144
    80005752:	4501                	li	a0,0
    80005754:	eaefd0ef          	jal	80002e02 <argstr>
    80005758:	02054363          	bltz	a0,8000577e <sys_mkdir+0x40>
    8000575c:	4681                	li	a3,0
    8000575e:	4601                	li	a2,0
    80005760:	4585                	li	a1,1
    80005762:	f7040513          	addi	a0,s0,-144
    80005766:	973ff0ef          	jal	800050d8 <create>
    8000576a:	c911                	beqz	a0,8000577e <sys_mkdir+0x40>
    end_op();
    return -1;
  }
  iunlockput(ip);
    8000576c:	b06fe0ef          	jal	80003a72 <iunlockput>
  end_op();
    80005770:	b73fe0ef          	jal	800042e2 <end_op>
  return 0;
    80005774:	4501                	li	a0,0
}
    80005776:	60aa                	ld	ra,136(sp)
    80005778:	640a                	ld	s0,128(sp)
    8000577a:	6149                	addi	sp,sp,144
    8000577c:	8082                	ret
    end_op();
    8000577e:	b65fe0ef          	jal	800042e2 <end_op>
    return -1;
    80005782:	557d                	li	a0,-1
    80005784:	bfcd                	j	80005776 <sys_mkdir+0x38>

0000000080005786 <sys_mknod>:

uint64
sys_mknod(void)
{
    80005786:	7135                	addi	sp,sp,-160
    80005788:	ed06                	sd	ra,152(sp)
    8000578a:	e922                	sd	s0,144(sp)
    8000578c:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    8000578e:	ae5fe0ef          	jal	80004272 <begin_op>
  argint(1, &major);
    80005792:	f6c40593          	addi	a1,s0,-148
    80005796:	4505                	li	a0,1
    80005798:	e32fd0ef          	jal	80002dca <argint>
  argint(2, &minor);
    8000579c:	f6840593          	addi	a1,s0,-152
    800057a0:	4509                	li	a0,2
    800057a2:	e28fd0ef          	jal	80002dca <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    800057a6:	08000613          	li	a2,128
    800057aa:	f7040593          	addi	a1,s0,-144
    800057ae:	4501                	li	a0,0
    800057b0:	e52fd0ef          	jal	80002e02 <argstr>
    800057b4:	02054563          	bltz	a0,800057de <sys_mknod+0x58>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    800057b8:	f6841683          	lh	a3,-152(s0)
    800057bc:	f6c41603          	lh	a2,-148(s0)
    800057c0:	458d                	li	a1,3
    800057c2:	f7040513          	addi	a0,s0,-144
    800057c6:	913ff0ef          	jal	800050d8 <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    800057ca:	c911                	beqz	a0,800057de <sys_mknod+0x58>
    end_op();
    return -1;
  }
  iunlockput(ip);
    800057cc:	aa6fe0ef          	jal	80003a72 <iunlockput>
  end_op();
    800057d0:	b13fe0ef          	jal	800042e2 <end_op>
  return 0;
    800057d4:	4501                	li	a0,0
}
    800057d6:	60ea                	ld	ra,152(sp)
    800057d8:	644a                	ld	s0,144(sp)
    800057da:	610d                	addi	sp,sp,160
    800057dc:	8082                	ret
    end_op();
    800057de:	b05fe0ef          	jal	800042e2 <end_op>
    return -1;
    800057e2:	557d                	li	a0,-1
    800057e4:	bfcd                	j	800057d6 <sys_mknod+0x50>

00000000800057e6 <sys_chdir>:

uint64
sys_chdir(void)
{
    800057e6:	7135                	addi	sp,sp,-160
    800057e8:	ed06                	sd	ra,152(sp)
    800057ea:	e922                	sd	s0,144(sp)
    800057ec:	e14a                	sd	s2,128(sp)
    800057ee:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    800057f0:	ca2fc0ef          	jal	80001c92 <myproc>
    800057f4:	892a                	mv	s2,a0
  
  begin_op();
    800057f6:	a7dfe0ef          	jal	80004272 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    800057fa:	08000613          	li	a2,128
    800057fe:	f6040593          	addi	a1,s0,-160
    80005802:	4501                	li	a0,0
    80005804:	dfefd0ef          	jal	80002e02 <argstr>
    80005808:	04054363          	bltz	a0,8000584e <sys_chdir+0x68>
    8000580c:	e526                	sd	s1,136(sp)
    8000580e:	f6040513          	addi	a0,s0,-160
    80005812:	883fe0ef          	jal	80004094 <namei>
    80005816:	84aa                	mv	s1,a0
    80005818:	c915                	beqz	a0,8000584c <sys_chdir+0x66>
    end_op();
    return -1;
  }
  ilock(ip);
    8000581a:	84cfe0ef          	jal	80003866 <ilock>
  if(ip->type != T_DIR){
    8000581e:	04449703          	lh	a4,68(s1)
    80005822:	4785                	li	a5,1
    80005824:	02f71963          	bne	a4,a5,80005856 <sys_chdir+0x70>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80005828:	8526                	mv	a0,s1
    8000582a:	8eafe0ef          	jal	80003914 <iunlock>
  iput(p->cwd);
    8000582e:	15093503          	ld	a0,336(s2)
    80005832:	9b6fe0ef          	jal	800039e8 <iput>
  end_op();
    80005836:	aadfe0ef          	jal	800042e2 <end_op>
  p->cwd = ip;
    8000583a:	14993823          	sd	s1,336(s2)
  return 0;
    8000583e:	4501                	li	a0,0
    80005840:	64aa                	ld	s1,136(sp)
}
    80005842:	60ea                	ld	ra,152(sp)
    80005844:	644a                	ld	s0,144(sp)
    80005846:	690a                	ld	s2,128(sp)
    80005848:	610d                	addi	sp,sp,160
    8000584a:	8082                	ret
    8000584c:	64aa                	ld	s1,136(sp)
    end_op();
    8000584e:	a95fe0ef          	jal	800042e2 <end_op>
    return -1;
    80005852:	557d                	li	a0,-1
    80005854:	b7fd                	j	80005842 <sys_chdir+0x5c>
    iunlockput(ip);
    80005856:	8526                	mv	a0,s1
    80005858:	a1afe0ef          	jal	80003a72 <iunlockput>
    end_op();
    8000585c:	a87fe0ef          	jal	800042e2 <end_op>
    return -1;
    80005860:	557d                	li	a0,-1
    80005862:	64aa                	ld	s1,136(sp)
    80005864:	bff9                	j	80005842 <sys_chdir+0x5c>

0000000080005866 <sys_exec>:

uint64
sys_exec(void)
{
    80005866:	7105                	addi	sp,sp,-480
    80005868:	ef86                	sd	ra,472(sp)
    8000586a:	eba2                	sd	s0,464(sp)
    8000586c:	1380                	addi	s0,sp,480
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    8000586e:	e2840593          	addi	a1,s0,-472
    80005872:	4505                	li	a0,1
    80005874:	d72fd0ef          	jal	80002de6 <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    80005878:	08000613          	li	a2,128
    8000587c:	f3040593          	addi	a1,s0,-208
    80005880:	4501                	li	a0,0
    80005882:	d80fd0ef          	jal	80002e02 <argstr>
    80005886:	87aa                	mv	a5,a0
    return -1;
    80005888:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    8000588a:	0e07c063          	bltz	a5,8000596a <sys_exec+0x104>
    8000588e:	e7a6                	sd	s1,456(sp)
    80005890:	e3ca                	sd	s2,448(sp)
    80005892:	ff4e                	sd	s3,440(sp)
    80005894:	fb52                	sd	s4,432(sp)
    80005896:	f756                	sd	s5,424(sp)
    80005898:	f35a                	sd	s6,416(sp)
    8000589a:	ef5e                	sd	s7,408(sp)
  }
  memset(argv, 0, sizeof(argv));
    8000589c:	e3040a13          	addi	s4,s0,-464
    800058a0:	10000613          	li	a2,256
    800058a4:	4581                	li	a1,0
    800058a6:	8552                	mv	a0,s4
    800058a8:	d4afb0ef          	jal	80000df2 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    800058ac:	84d2                	mv	s1,s4
  memset(argv, 0, sizeof(argv));
    800058ae:	89d2                	mv	s3,s4
    800058b0:	4901                	li	s2,0
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    800058b2:	e2040a93          	addi	s5,s0,-480
      break;
    }
    argv[i] = kalloc();
    if(argv[i] == 0)
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    800058b6:	6b05                	lui	s6,0x1
    if(i >= NELEM(argv)){
    800058b8:	02000b93          	li	s7,32
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    800058bc:	00391513          	slli	a0,s2,0x3
    800058c0:	85d6                	mv	a1,s5
    800058c2:	e2843783          	ld	a5,-472(s0)
    800058c6:	953e                	add	a0,a0,a5
    800058c8:	c78fd0ef          	jal	80002d40 <fetchaddr>
    800058cc:	02054663          	bltz	a0,800058f8 <sys_exec+0x92>
    if(uarg == 0){
    800058d0:	e2043783          	ld	a5,-480(s0)
    800058d4:	c7a1                	beqz	a5,8000591c <sys_exec+0xb6>
    argv[i] = kalloc();
    800058d6:	b04fb0ef          	jal	80000bda <kalloc>
    800058da:	85aa                	mv	a1,a0
    800058dc:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    800058e0:	cd01                	beqz	a0,800058f8 <sys_exec+0x92>
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    800058e2:	865a                	mv	a2,s6
    800058e4:	e2043503          	ld	a0,-480(s0)
    800058e8:	ca2fd0ef          	jal	80002d8a <fetchstr>
    800058ec:	00054663          	bltz	a0,800058f8 <sys_exec+0x92>
    if(i >= NELEM(argv)){
    800058f0:	0905                	addi	s2,s2,1
    800058f2:	09a1                	addi	s3,s3,8
    800058f4:	fd7914e3          	bne	s2,s7,800058bc <sys_exec+0x56>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800058f8:	100a0a13          	addi	s4,s4,256
    800058fc:	6088                	ld	a0,0(s1)
    800058fe:	cd31                	beqz	a0,8000595a <sys_exec+0xf4>
    kfree(argv[i]);
    80005900:	98efb0ef          	jal	80000a8e <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005904:	04a1                	addi	s1,s1,8
    80005906:	ff449be3          	bne	s1,s4,800058fc <sys_exec+0x96>
  return -1;
    8000590a:	557d                	li	a0,-1
    8000590c:	64be                	ld	s1,456(sp)
    8000590e:	691e                	ld	s2,448(sp)
    80005910:	79fa                	ld	s3,440(sp)
    80005912:	7a5a                	ld	s4,432(sp)
    80005914:	7aba                	ld	s5,424(sp)
    80005916:	7b1a                	ld	s6,416(sp)
    80005918:	6bfa                	ld	s7,408(sp)
    8000591a:	a881                	j	8000596a <sys_exec+0x104>
      argv[i] = 0;
    8000591c:	0009079b          	sext.w	a5,s2
    80005920:	e3040593          	addi	a1,s0,-464
    80005924:	078e                	slli	a5,a5,0x3
    80005926:	97ae                	add	a5,a5,a1
    80005928:	0007b023          	sd	zero,0(a5)
  int ret = kexec(path, argv);
    8000592c:	f3040513          	addi	a0,s0,-208
    80005930:	bb2ff0ef          	jal	80004ce2 <kexec>
    80005934:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005936:	100a0a13          	addi	s4,s4,256
    8000593a:	6088                	ld	a0,0(s1)
    8000593c:	c511                	beqz	a0,80005948 <sys_exec+0xe2>
    kfree(argv[i]);
    8000593e:	950fb0ef          	jal	80000a8e <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005942:	04a1                	addi	s1,s1,8
    80005944:	ff449be3          	bne	s1,s4,8000593a <sys_exec+0xd4>
  return ret;
    80005948:	854a                	mv	a0,s2
    8000594a:	64be                	ld	s1,456(sp)
    8000594c:	691e                	ld	s2,448(sp)
    8000594e:	79fa                	ld	s3,440(sp)
    80005950:	7a5a                	ld	s4,432(sp)
    80005952:	7aba                	ld	s5,424(sp)
    80005954:	7b1a                	ld	s6,416(sp)
    80005956:	6bfa                	ld	s7,408(sp)
    80005958:	a809                	j	8000596a <sys_exec+0x104>
  return -1;
    8000595a:	557d                	li	a0,-1
    8000595c:	64be                	ld	s1,456(sp)
    8000595e:	691e                	ld	s2,448(sp)
    80005960:	79fa                	ld	s3,440(sp)
    80005962:	7a5a                	ld	s4,432(sp)
    80005964:	7aba                	ld	s5,424(sp)
    80005966:	7b1a                	ld	s6,416(sp)
    80005968:	6bfa                	ld	s7,408(sp)
}
    8000596a:	60fe                	ld	ra,472(sp)
    8000596c:	645e                	ld	s0,464(sp)
    8000596e:	613d                	addi	sp,sp,480
    80005970:	8082                	ret

0000000080005972 <sys_pipe>:

uint64
sys_pipe(void)
{
    80005972:	7139                	addi	sp,sp,-64
    80005974:	fc06                	sd	ra,56(sp)
    80005976:	f822                	sd	s0,48(sp)
    80005978:	f426                	sd	s1,40(sp)
    8000597a:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    8000597c:	b16fc0ef          	jal	80001c92 <myproc>
    80005980:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    80005982:	fd840593          	addi	a1,s0,-40
    80005986:	4501                	li	a0,0
    80005988:	c5efd0ef          	jal	80002de6 <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    8000598c:	fc840593          	addi	a1,s0,-56
    80005990:	fd040513          	addi	a0,s0,-48
    80005994:	81eff0ef          	jal	800049b2 <pipealloc>
    return -1;
    80005998:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    8000599a:	0a054763          	bltz	a0,80005a48 <sys_pipe+0xd6>
  fd0 = -1;
    8000599e:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    800059a2:	fd043503          	ld	a0,-48(s0)
    800059a6:	ef2ff0ef          	jal	80005098 <fdalloc>
    800059aa:	fca42223          	sw	a0,-60(s0)
    800059ae:	08054463          	bltz	a0,80005a36 <sys_pipe+0xc4>
    800059b2:	fc843503          	ld	a0,-56(s0)
    800059b6:	ee2ff0ef          	jal	80005098 <fdalloc>
    800059ba:	fca42023          	sw	a0,-64(s0)
    800059be:	06054263          	bltz	a0,80005a22 <sys_pipe+0xb0>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    800059c2:	4691                	li	a3,4
    800059c4:	fc440613          	addi	a2,s0,-60
    800059c8:	fd843583          	ld	a1,-40(s0)
    800059cc:	68a8                	ld	a0,80(s1)
    800059ce:	fd7fb0ef          	jal	800019a4 <copyout>
    800059d2:	00054e63          	bltz	a0,800059ee <sys_pipe+0x7c>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    800059d6:	4691                	li	a3,4
    800059d8:	fc040613          	addi	a2,s0,-64
    800059dc:	fd843583          	ld	a1,-40(s0)
    800059e0:	95b6                	add	a1,a1,a3
    800059e2:	68a8                	ld	a0,80(s1)
    800059e4:	fc1fb0ef          	jal	800019a4 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    800059e8:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    800059ea:	04055f63          	bgez	a0,80005a48 <sys_pipe+0xd6>
    p->ofile[fd0] = 0;
    800059ee:	fc442783          	lw	a5,-60(s0)
    800059f2:	078e                	slli	a5,a5,0x3
    800059f4:	0d078793          	addi	a5,a5,208
    800059f8:	97a6                	add	a5,a5,s1
    800059fa:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    800059fe:	fc042783          	lw	a5,-64(s0)
    80005a02:	078e                	slli	a5,a5,0x3
    80005a04:	0d078793          	addi	a5,a5,208
    80005a08:	97a6                	add	a5,a5,s1
    80005a0a:	0007b023          	sd	zero,0(a5)
    fileclose(rf);
    80005a0e:	fd043503          	ld	a0,-48(s0)
    80005a12:	c85fe0ef          	jal	80004696 <fileclose>
    fileclose(wf);
    80005a16:	fc843503          	ld	a0,-56(s0)
    80005a1a:	c7dfe0ef          	jal	80004696 <fileclose>
    return -1;
    80005a1e:	57fd                	li	a5,-1
    80005a20:	a025                	j	80005a48 <sys_pipe+0xd6>
    if(fd0 >= 0)
    80005a22:	fc442783          	lw	a5,-60(s0)
    80005a26:	0007c863          	bltz	a5,80005a36 <sys_pipe+0xc4>
      p->ofile[fd0] = 0;
    80005a2a:	078e                	slli	a5,a5,0x3
    80005a2c:	0d078793          	addi	a5,a5,208
    80005a30:	97a6                	add	a5,a5,s1
    80005a32:	0007b023          	sd	zero,0(a5)
    fileclose(rf);
    80005a36:	fd043503          	ld	a0,-48(s0)
    80005a3a:	c5dfe0ef          	jal	80004696 <fileclose>
    fileclose(wf);
    80005a3e:	fc843503          	ld	a0,-56(s0)
    80005a42:	c55fe0ef          	jal	80004696 <fileclose>
    return -1;
    80005a46:	57fd                	li	a5,-1
}
    80005a48:	853e                	mv	a0,a5
    80005a4a:	70e2                	ld	ra,56(sp)
    80005a4c:	7442                	ld	s0,48(sp)
    80005a4e:	74a2                	ld	s1,40(sp)
    80005a50:	6121                	addi	sp,sp,64
    80005a52:	8082                	ret

0000000080005a54 <sys_fsread>:
uint64
sys_fsread(void)
{
    80005a54:	1101                	addi	sp,sp,-32
    80005a56:	ec06                	sd	ra,24(sp)
    80005a58:	e822                	sd	s0,16(sp)
    80005a5a:	1000                	addi	s0,sp,32
  uint64 addr;
  int n;

  // استدعاء الدوال بدون مقارنتها بـ < 0 لأنها تعيد void
  argaddr(0, &addr); 
    80005a5c:	fe840593          	addi	a1,s0,-24
    80005a60:	4501                	li	a0,0
    80005a62:	b84fd0ef          	jal	80002de6 <argaddr>
  argint(1, &n);
    80005a66:	fe440593          	addi	a1,s0,-28
    80005a6a:	4505                	li	a0,1
    80005a6c:	b5efd0ef          	jal	80002dca <argint>

  // استدعاء الوظيفة الحقيقية وإعادة نتيجتها
  return fslog_read_many((struct fs_event *)addr, n);
    80005a70:	fe442583          	lw	a1,-28(s0)
    80005a74:	fe843503          	ld	a0,-24(s0)
    80005a78:	205000ef          	jal	8000647c <fslog_read_many>
    80005a7c:	60e2                	ld	ra,24(sp)
    80005a7e:	6442                	ld	s0,16(sp)
    80005a80:	6105                	addi	sp,sp,32
    80005a82:	8082                	ret
	...

0000000080005a90 <kernelvec>:
.globl kerneltrap
.globl kernelvec
.align 4
kernelvec:
        # make room to save registers.
        addi sp, sp, -256
    80005a90:	7111                	addi	sp,sp,-256

        # save caller-saved registers.
        sd ra, 0(sp)
    80005a92:	e006                	sd	ra,0(sp)
        # sd sp, 8(sp)
        sd gp, 16(sp)
    80005a94:	e80e                	sd	gp,16(sp)
        sd tp, 24(sp)
    80005a96:	ec12                	sd	tp,24(sp)
        sd t0, 32(sp)
    80005a98:	f016                	sd	t0,32(sp)
        sd t1, 40(sp)
    80005a9a:	f41a                	sd	t1,40(sp)
        sd t2, 48(sp)
    80005a9c:	f81e                	sd	t2,48(sp)
        sd a0, 72(sp)
    80005a9e:	e4aa                	sd	a0,72(sp)
        sd a1, 80(sp)
    80005aa0:	e8ae                	sd	a1,80(sp)
        sd a2, 88(sp)
    80005aa2:	ecb2                	sd	a2,88(sp)
        sd a3, 96(sp)
    80005aa4:	f0b6                	sd	a3,96(sp)
        sd a4, 104(sp)
    80005aa6:	f4ba                	sd	a4,104(sp)
        sd a5, 112(sp)
    80005aa8:	f8be                	sd	a5,112(sp)
        sd a6, 120(sp)
    80005aaa:	fcc2                	sd	a6,120(sp)
        sd a7, 128(sp)
    80005aac:	e146                	sd	a7,128(sp)
        sd t3, 216(sp)
    80005aae:	edf2                	sd	t3,216(sp)
        sd t4, 224(sp)
    80005ab0:	f1f6                	sd	t4,224(sp)
        sd t5, 232(sp)
    80005ab2:	f5fa                	sd	t5,232(sp)
        sd t6, 240(sp)
    80005ab4:	f9fe                	sd	t6,240(sp)

        # call the C trap handler in trap.c
        call kerneltrap
    80005ab6:	998fd0ef          	jal	80002c4e <kerneltrap>

        # restore registers.
        ld ra, 0(sp)
    80005aba:	6082                	ld	ra,0(sp)
        # ld sp, 8(sp)
        ld gp, 16(sp)
    80005abc:	61c2                	ld	gp,16(sp)
        # not tp (contains hartid), in case we moved CPUs
        ld t0, 32(sp)
    80005abe:	7282                	ld	t0,32(sp)
        ld t1, 40(sp)
    80005ac0:	7322                	ld	t1,40(sp)
        ld t2, 48(sp)
    80005ac2:	73c2                	ld	t2,48(sp)
        ld a0, 72(sp)
    80005ac4:	6526                	ld	a0,72(sp)
        ld a1, 80(sp)
    80005ac6:	65c6                	ld	a1,80(sp)
        ld a2, 88(sp)
    80005ac8:	6666                	ld	a2,88(sp)
        ld a3, 96(sp)
    80005aca:	7686                	ld	a3,96(sp)
        ld a4, 104(sp)
    80005acc:	7726                	ld	a4,104(sp)
        ld a5, 112(sp)
    80005ace:	77c6                	ld	a5,112(sp)
        ld a6, 120(sp)
    80005ad0:	7866                	ld	a6,120(sp)
        ld a7, 128(sp)
    80005ad2:	688a                	ld	a7,128(sp)
        ld t3, 216(sp)
    80005ad4:	6e6e                	ld	t3,216(sp)
        ld t4, 224(sp)
    80005ad6:	7e8e                	ld	t4,224(sp)
        ld t5, 232(sp)
    80005ad8:	7f2e                	ld	t5,232(sp)
        ld t6, 240(sp)
    80005ada:	7fce                	ld	t6,240(sp)

        addi sp, sp, 256
    80005adc:	6111                	addi	sp,sp,256

        # return to whatever we were doing in the kernel.
        sret
    80005ade:	10200073          	sret
    80005ae2:	00000013          	nop
    80005ae6:	00000013          	nop
    80005aea:	00000013          	nop

0000000080005aee <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    80005aee:	1141                	addi	sp,sp,-16
    80005af0:	e406                	sd	ra,8(sp)
    80005af2:	e022                	sd	s0,0(sp)
    80005af4:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80005af6:	0c000737          	lui	a4,0xc000
    80005afa:	4785                	li	a5,1
    80005afc:	d71c                	sw	a5,40(a4)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    80005afe:	c35c                	sw	a5,4(a4)
}
    80005b00:	60a2                	ld	ra,8(sp)
    80005b02:	6402                	ld	s0,0(sp)
    80005b04:	0141                	addi	sp,sp,16
    80005b06:	8082                	ret

0000000080005b08 <plicinithart>:

void
plicinithart(void)
{
    80005b08:	1141                	addi	sp,sp,-16
    80005b0a:	e406                	sd	ra,8(sp)
    80005b0c:	e022                	sd	s0,0(sp)
    80005b0e:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005b10:	94efc0ef          	jal	80001c5e <cpuid>
  
  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80005b14:	0085171b          	slliw	a4,a0,0x8
    80005b18:	0c0027b7          	lui	a5,0xc002
    80005b1c:	97ba                	add	a5,a5,a4
    80005b1e:	40200713          	li	a4,1026
    80005b22:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80005b26:	00d5151b          	slliw	a0,a0,0xd
    80005b2a:	0c2017b7          	lui	a5,0xc201
    80005b2e:	97aa                	add	a5,a5,a0
    80005b30:	0007a023          	sw	zero,0(a5) # c201000 <_entry-0x73dff000>
}
    80005b34:	60a2                	ld	ra,8(sp)
    80005b36:	6402                	ld	s0,0(sp)
    80005b38:	0141                	addi	sp,sp,16
    80005b3a:	8082                	ret

0000000080005b3c <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    80005b3c:	1141                	addi	sp,sp,-16
    80005b3e:	e406                	sd	ra,8(sp)
    80005b40:	e022                	sd	s0,0(sp)
    80005b42:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005b44:	91afc0ef          	jal	80001c5e <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80005b48:	00d5151b          	slliw	a0,a0,0xd
    80005b4c:	0c2017b7          	lui	a5,0xc201
    80005b50:	97aa                	add	a5,a5,a0
  return irq;
}
    80005b52:	43c8                	lw	a0,4(a5)
    80005b54:	60a2                	ld	ra,8(sp)
    80005b56:	6402                	ld	s0,0(sp)
    80005b58:	0141                	addi	sp,sp,16
    80005b5a:	8082                	ret

0000000080005b5c <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    80005b5c:	1101                	addi	sp,sp,-32
    80005b5e:	ec06                	sd	ra,24(sp)
    80005b60:	e822                	sd	s0,16(sp)
    80005b62:	e426                	sd	s1,8(sp)
    80005b64:	1000                	addi	s0,sp,32
    80005b66:	84aa                	mv	s1,a0
  int hart = cpuid();
    80005b68:	8f6fc0ef          	jal	80001c5e <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    80005b6c:	00d5179b          	slliw	a5,a0,0xd
    80005b70:	0c201737          	lui	a4,0xc201
    80005b74:	97ba                	add	a5,a5,a4
    80005b76:	c3c4                	sw	s1,4(a5)
}
    80005b78:	60e2                	ld	ra,24(sp)
    80005b7a:	6442                	ld	s0,16(sp)
    80005b7c:	64a2                	ld	s1,8(sp)
    80005b7e:	6105                	addi	sp,sp,32
    80005b80:	8082                	ret

0000000080005b82 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80005b82:	1141                	addi	sp,sp,-16
    80005b84:	e406                	sd	ra,8(sp)
    80005b86:	e022                	sd	s0,0(sp)
    80005b88:	0800                	addi	s0,sp,16
  if(i >= NUM)
    80005b8a:	479d                	li	a5,7
    80005b8c:	04a7ca63          	blt	a5,a0,80005be0 <free_desc+0x5e>
    panic("free_desc 1");
  if(disk.free[i])
    80005b90:	0001d797          	auipc	a5,0x1d
    80005b94:	68078793          	addi	a5,a5,1664 # 80023210 <disk>
    80005b98:	97aa                	add	a5,a5,a0
    80005b9a:	0187c783          	lbu	a5,24(a5)
    80005b9e:	e7b9                	bnez	a5,80005bec <free_desc+0x6a>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    80005ba0:	00451693          	slli	a3,a0,0x4
    80005ba4:	0001d797          	auipc	a5,0x1d
    80005ba8:	66c78793          	addi	a5,a5,1644 # 80023210 <disk>
    80005bac:	6398                	ld	a4,0(a5)
    80005bae:	9736                	add	a4,a4,a3
    80005bb0:	00073023          	sd	zero,0(a4) # c201000 <_entry-0x73dff000>
  disk.desc[i].len = 0;
    80005bb4:	6398                	ld	a4,0(a5)
    80005bb6:	9736                	add	a4,a4,a3
    80005bb8:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    80005bbc:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    80005bc0:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    80005bc4:	97aa                	add	a5,a5,a0
    80005bc6:	4705                	li	a4,1
    80005bc8:	00e78c23          	sb	a4,24(a5)
  wakeup(&disk.free[0]);
    80005bcc:	0001d517          	auipc	a0,0x1d
    80005bd0:	65c50513          	addi	a0,a0,1628 # 80023228 <disk+0x18>
    80005bd4:	937fc0ef          	jal	8000250a <wakeup>
}
    80005bd8:	60a2                	ld	ra,8(sp)
    80005bda:	6402                	ld	s0,0(sp)
    80005bdc:	0141                	addi	sp,sp,16
    80005bde:	8082                	ret
    panic("free_desc 1");
    80005be0:	00003517          	auipc	a0,0x3
    80005be4:	b4050513          	addi	a0,a0,-1216 # 80008720 <userret+0x1684>
    80005be8:	c6ffa0ef          	jal	80000856 <panic>
    panic("free_desc 2");
    80005bec:	00003517          	auipc	a0,0x3
    80005bf0:	b4450513          	addi	a0,a0,-1212 # 80008730 <userret+0x1694>
    80005bf4:	c63fa0ef          	jal	80000856 <panic>

0000000080005bf8 <virtio_disk_init>:
{
    80005bf8:	1101                	addi	sp,sp,-32
    80005bfa:	ec06                	sd	ra,24(sp)
    80005bfc:	e822                	sd	s0,16(sp)
    80005bfe:	e426                	sd	s1,8(sp)
    80005c00:	e04a                	sd	s2,0(sp)
    80005c02:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80005c04:	00003597          	auipc	a1,0x3
    80005c08:	b3c58593          	addi	a1,a1,-1220 # 80008740 <userret+0x16a4>
    80005c0c:	0001d517          	auipc	a0,0x1d
    80005c10:	72c50513          	addi	a0,a0,1836 # 80023338 <disk+0x128>
    80005c14:	884fb0ef          	jal	80000c98 <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005c18:	100017b7          	lui	a5,0x10001
    80005c1c:	4398                	lw	a4,0(a5)
    80005c1e:	2701                	sext.w	a4,a4
    80005c20:	747277b7          	lui	a5,0x74727
    80005c24:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    80005c28:	14f71863          	bne	a4,a5,80005d78 <virtio_disk_init+0x180>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80005c2c:	100017b7          	lui	a5,0x10001
    80005c30:	43dc                	lw	a5,4(a5)
    80005c32:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005c34:	4709                	li	a4,2
    80005c36:	14e79163          	bne	a5,a4,80005d78 <virtio_disk_init+0x180>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005c3a:	100017b7          	lui	a5,0x10001
    80005c3e:	479c                	lw	a5,8(a5)
    80005c40:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80005c42:	12e79b63          	bne	a5,a4,80005d78 <virtio_disk_init+0x180>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    80005c46:	100017b7          	lui	a5,0x10001
    80005c4a:	47d8                	lw	a4,12(a5)
    80005c4c:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005c4e:	554d47b7          	lui	a5,0x554d4
    80005c52:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    80005c56:	12f71163          	bne	a4,a5,80005d78 <virtio_disk_init+0x180>
  *R(VIRTIO_MMIO_STATUS) = status;
    80005c5a:	100017b7          	lui	a5,0x10001
    80005c5e:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    80005c62:	4705                	li	a4,1
    80005c64:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005c66:	470d                	li	a4,3
    80005c68:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    80005c6a:	10001737          	lui	a4,0x10001
    80005c6e:	4b18                	lw	a4,16(a4)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    80005c70:	c7ffe6b7          	lui	a3,0xc7ffe
    80005c74:	75f68693          	addi	a3,a3,1887 # ffffffffc7ffe75f <end+0xffffffff47fb6367>
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80005c78:	8f75                	and	a4,a4,a3
    80005c7a:	100016b7          	lui	a3,0x10001
    80005c7e:	d298                	sw	a4,32(a3)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005c80:	472d                	li	a4,11
    80005c82:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005c84:	07078793          	addi	a5,a5,112
  status = *R(VIRTIO_MMIO_STATUS);
    80005c88:	439c                	lw	a5,0(a5)
    80005c8a:	0007891b          	sext.w	s2,a5
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    80005c8e:	8ba1                	andi	a5,a5,8
    80005c90:	0e078a63          	beqz	a5,80005d84 <virtio_disk_init+0x18c>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80005c94:	100017b7          	lui	a5,0x10001
    80005c98:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    80005c9c:	43fc                	lw	a5,68(a5)
    80005c9e:	2781                	sext.w	a5,a5
    80005ca0:	0e079863          	bnez	a5,80005d90 <virtio_disk_init+0x198>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    80005ca4:	100017b7          	lui	a5,0x10001
    80005ca8:	5bdc                	lw	a5,52(a5)
    80005caa:	2781                	sext.w	a5,a5
  if(max == 0)
    80005cac:	0e078863          	beqz	a5,80005d9c <virtio_disk_init+0x1a4>
  if(max < NUM)
    80005cb0:	471d                	li	a4,7
    80005cb2:	0ef77b63          	bgeu	a4,a5,80005da8 <virtio_disk_init+0x1b0>
  disk.desc = kalloc();
    80005cb6:	f25fa0ef          	jal	80000bda <kalloc>
    80005cba:	0001d497          	auipc	s1,0x1d
    80005cbe:	55648493          	addi	s1,s1,1366 # 80023210 <disk>
    80005cc2:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    80005cc4:	f17fa0ef          	jal	80000bda <kalloc>
    80005cc8:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    80005cca:	f11fa0ef          	jal	80000bda <kalloc>
    80005cce:	87aa                	mv	a5,a0
    80005cd0:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    80005cd2:	6088                	ld	a0,0(s1)
    80005cd4:	0e050063          	beqz	a0,80005db4 <virtio_disk_init+0x1bc>
    80005cd8:	0001d717          	auipc	a4,0x1d
    80005cdc:	54073703          	ld	a4,1344(a4) # 80023218 <disk+0x8>
    80005ce0:	cb71                	beqz	a4,80005db4 <virtio_disk_init+0x1bc>
    80005ce2:	cbe9                	beqz	a5,80005db4 <virtio_disk_init+0x1bc>
  memset(disk.desc, 0, PGSIZE);
    80005ce4:	6605                	lui	a2,0x1
    80005ce6:	4581                	li	a1,0
    80005ce8:	90afb0ef          	jal	80000df2 <memset>
  memset(disk.avail, 0, PGSIZE);
    80005cec:	0001d497          	auipc	s1,0x1d
    80005cf0:	52448493          	addi	s1,s1,1316 # 80023210 <disk>
    80005cf4:	6605                	lui	a2,0x1
    80005cf6:	4581                	li	a1,0
    80005cf8:	6488                	ld	a0,8(s1)
    80005cfa:	8f8fb0ef          	jal	80000df2 <memset>
  memset(disk.used, 0, PGSIZE);
    80005cfe:	6605                	lui	a2,0x1
    80005d00:	4581                	li	a1,0
    80005d02:	6888                	ld	a0,16(s1)
    80005d04:	8eefb0ef          	jal	80000df2 <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    80005d08:	100017b7          	lui	a5,0x10001
    80005d0c:	4721                	li	a4,8
    80005d0e:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    80005d10:	4098                	lw	a4,0(s1)
    80005d12:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    80005d16:	40d8                	lw	a4,4(s1)
    80005d18:	08e7a223          	sw	a4,132(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    80005d1c:	649c                	ld	a5,8(s1)
    80005d1e:	0007869b          	sext.w	a3,a5
    80005d22:	10001737          	lui	a4,0x10001
    80005d26:	08d72823          	sw	a3,144(a4) # 10001090 <_entry-0x6fffef70>
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    80005d2a:	9781                	srai	a5,a5,0x20
    80005d2c:	08f72a23          	sw	a5,148(a4)
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    80005d30:	689c                	ld	a5,16(s1)
    80005d32:	0007869b          	sext.w	a3,a5
    80005d36:	0ad72023          	sw	a3,160(a4)
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    80005d3a:	9781                	srai	a5,a5,0x20
    80005d3c:	0af72223          	sw	a5,164(a4)
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    80005d40:	4785                	li	a5,1
    80005d42:	c37c                	sw	a5,68(a4)
    disk.free[i] = 1;
    80005d44:	00f48c23          	sb	a5,24(s1)
    80005d48:	00f48ca3          	sb	a5,25(s1)
    80005d4c:	00f48d23          	sb	a5,26(s1)
    80005d50:	00f48da3          	sb	a5,27(s1)
    80005d54:	00f48e23          	sb	a5,28(s1)
    80005d58:	00f48ea3          	sb	a5,29(s1)
    80005d5c:	00f48f23          	sb	a5,30(s1)
    80005d60:	00f48fa3          	sb	a5,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    80005d64:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    80005d68:	07272823          	sw	s2,112(a4)
}
    80005d6c:	60e2                	ld	ra,24(sp)
    80005d6e:	6442                	ld	s0,16(sp)
    80005d70:	64a2                	ld	s1,8(sp)
    80005d72:	6902                	ld	s2,0(sp)
    80005d74:	6105                	addi	sp,sp,32
    80005d76:	8082                	ret
    panic("could not find virtio disk");
    80005d78:	00003517          	auipc	a0,0x3
    80005d7c:	9d850513          	addi	a0,a0,-1576 # 80008750 <userret+0x16b4>
    80005d80:	ad7fa0ef          	jal	80000856 <panic>
    panic("virtio disk FEATURES_OK unset");
    80005d84:	00003517          	auipc	a0,0x3
    80005d88:	9ec50513          	addi	a0,a0,-1556 # 80008770 <userret+0x16d4>
    80005d8c:	acbfa0ef          	jal	80000856 <panic>
    panic("virtio disk should not be ready");
    80005d90:	00003517          	auipc	a0,0x3
    80005d94:	a0050513          	addi	a0,a0,-1536 # 80008790 <userret+0x16f4>
    80005d98:	abffa0ef          	jal	80000856 <panic>
    panic("virtio disk has no queue 0");
    80005d9c:	00003517          	auipc	a0,0x3
    80005da0:	a1450513          	addi	a0,a0,-1516 # 800087b0 <userret+0x1714>
    80005da4:	ab3fa0ef          	jal	80000856 <panic>
    panic("virtio disk max queue too short");
    80005da8:	00003517          	auipc	a0,0x3
    80005dac:	a2850513          	addi	a0,a0,-1496 # 800087d0 <userret+0x1734>
    80005db0:	aa7fa0ef          	jal	80000856 <panic>
    panic("virtio disk kalloc");
    80005db4:	00003517          	auipc	a0,0x3
    80005db8:	a3c50513          	addi	a0,a0,-1476 # 800087f0 <userret+0x1754>
    80005dbc:	a9bfa0ef          	jal	80000856 <panic>

0000000080005dc0 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80005dc0:	711d                	addi	sp,sp,-96
    80005dc2:	ec86                	sd	ra,88(sp)
    80005dc4:	e8a2                	sd	s0,80(sp)
    80005dc6:	e4a6                	sd	s1,72(sp)
    80005dc8:	e0ca                	sd	s2,64(sp)
    80005dca:	fc4e                	sd	s3,56(sp)
    80005dcc:	f852                	sd	s4,48(sp)
    80005dce:	f456                	sd	s5,40(sp)
    80005dd0:	f05a                	sd	s6,32(sp)
    80005dd2:	ec5e                	sd	s7,24(sp)
    80005dd4:	e862                	sd	s8,16(sp)
    80005dd6:	1080                	addi	s0,sp,96
    80005dd8:	89aa                	mv	s3,a0
    80005dda:	8b2e                	mv	s6,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    80005ddc:	00c52b83          	lw	s7,12(a0)
    80005de0:	001b9b9b          	slliw	s7,s7,0x1
    80005de4:	1b82                	slli	s7,s7,0x20
    80005de6:	020bdb93          	srli	s7,s7,0x20

  acquire(&disk.vdisk_lock);
    80005dea:	0001d517          	auipc	a0,0x1d
    80005dee:	54e50513          	addi	a0,a0,1358 # 80023338 <disk+0x128>
    80005df2:	f31fa0ef          	jal	80000d22 <acquire>
  for(int i = 0; i < NUM; i++){
    80005df6:	44a1                	li	s1,8
      disk.free[i] = 0;
    80005df8:	0001da97          	auipc	s5,0x1d
    80005dfc:	418a8a93          	addi	s5,s5,1048 # 80023210 <disk>
  for(int i = 0; i < 3; i++){
    80005e00:	4a0d                	li	s4,3
    idx[i] = alloc_desc();
    80005e02:	5c7d                	li	s8,-1
    80005e04:	a095                	j	80005e68 <virtio_disk_rw+0xa8>
      disk.free[i] = 0;
    80005e06:	00fa8733          	add	a4,s5,a5
    80005e0a:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    80005e0e:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    80005e10:	0207c563          	bltz	a5,80005e3a <virtio_disk_rw+0x7a>
  for(int i = 0; i < 3; i++){
    80005e14:	2905                	addiw	s2,s2,1
    80005e16:	0611                	addi	a2,a2,4 # 1004 <_entry-0x7fffeffc>
    80005e18:	05490c63          	beq	s2,s4,80005e70 <virtio_disk_rw+0xb0>
    idx[i] = alloc_desc();
    80005e1c:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    80005e1e:	0001d717          	auipc	a4,0x1d
    80005e22:	3f270713          	addi	a4,a4,1010 # 80023210 <disk>
    80005e26:	4781                	li	a5,0
    if(disk.free[i]){
    80005e28:	01874683          	lbu	a3,24(a4)
    80005e2c:	fee9                	bnez	a3,80005e06 <virtio_disk_rw+0x46>
  for(int i = 0; i < NUM; i++){
    80005e2e:	2785                	addiw	a5,a5,1
    80005e30:	0705                	addi	a4,a4,1
    80005e32:	fe979be3          	bne	a5,s1,80005e28 <virtio_disk_rw+0x68>
    idx[i] = alloc_desc();
    80005e36:	0185a023          	sw	s8,0(a1)
      for(int j = 0; j < i; j++)
    80005e3a:	01205d63          	blez	s2,80005e54 <virtio_disk_rw+0x94>
        free_desc(idx[j]);
    80005e3e:	fa042503          	lw	a0,-96(s0)
    80005e42:	d41ff0ef          	jal	80005b82 <free_desc>
      for(int j = 0; j < i; j++)
    80005e46:	4785                	li	a5,1
    80005e48:	0127d663          	bge	a5,s2,80005e54 <virtio_disk_rw+0x94>
        free_desc(idx[j]);
    80005e4c:	fa442503          	lw	a0,-92(s0)
    80005e50:	d33ff0ef          	jal	80005b82 <free_desc>
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80005e54:	0001d597          	auipc	a1,0x1d
    80005e58:	4e458593          	addi	a1,a1,1252 # 80023338 <disk+0x128>
    80005e5c:	0001d517          	auipc	a0,0x1d
    80005e60:	3cc50513          	addi	a0,a0,972 # 80023228 <disk+0x18>
    80005e64:	e5afc0ef          	jal	800024be <sleep>
  for(int i = 0; i < 3; i++){
    80005e68:	fa040613          	addi	a2,s0,-96
    80005e6c:	4901                	li	s2,0
    80005e6e:	b77d                	j	80005e1c <virtio_disk_rw+0x5c>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80005e70:	fa042503          	lw	a0,-96(s0)
    80005e74:	00451693          	slli	a3,a0,0x4

  if(write)
    80005e78:	0001d797          	auipc	a5,0x1d
    80005e7c:	39878793          	addi	a5,a5,920 # 80023210 <disk>
    80005e80:	00451713          	slli	a4,a0,0x4
    80005e84:	0a070713          	addi	a4,a4,160
    80005e88:	973e                	add	a4,a4,a5
    80005e8a:	01603633          	snez	a2,s6
    80005e8e:	c710                	sw	a2,8(a4)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    80005e90:	00072623          	sw	zero,12(a4)
  buf0->sector = sector;
    80005e94:	01773823          	sd	s7,16(a4)

  disk.desc[idx[0]].addr = (uint64) buf0;
    80005e98:	6398                	ld	a4,0(a5)
    80005e9a:	9736                	add	a4,a4,a3
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80005e9c:	0a868613          	addi	a2,a3,168 # 100010a8 <_entry-0x6fffef58>
    80005ea0:	963e                	add	a2,a2,a5
  disk.desc[idx[0]].addr = (uint64) buf0;
    80005ea2:	e310                	sd	a2,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    80005ea4:	6390                	ld	a2,0(a5)
    80005ea6:	00d60833          	add	a6,a2,a3
    80005eaa:	4741                	li	a4,16
    80005eac:	00e82423          	sw	a4,8(a6)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    80005eb0:	4585                	li	a1,1
    80005eb2:	00b81623          	sh	a1,12(a6)
  disk.desc[idx[0]].next = idx[1];
    80005eb6:	fa442703          	lw	a4,-92(s0)
    80005eba:	00e81723          	sh	a4,14(a6)

  disk.desc[idx[1]].addr = (uint64) b->data;
    80005ebe:	0712                	slli	a4,a4,0x4
    80005ec0:	963a                	add	a2,a2,a4
    80005ec2:	05898813          	addi	a6,s3,88
    80005ec6:	01063023          	sd	a6,0(a2)
  disk.desc[idx[1]].len = BSIZE;
    80005eca:	0007b883          	ld	a7,0(a5)
    80005ece:	9746                	add	a4,a4,a7
    80005ed0:	40000613          	li	a2,1024
    80005ed4:	c710                	sw	a2,8(a4)
  if(write)
    80005ed6:	001b3613          	seqz	a2,s6
    80005eda:	0016161b          	slliw	a2,a2,0x1
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    80005ede:	8e4d                	or	a2,a2,a1
    80005ee0:	00c71623          	sh	a2,12(a4)
  disk.desc[idx[1]].next = idx[2];
    80005ee4:	fa842603          	lw	a2,-88(s0)
    80005ee8:	00c71723          	sh	a2,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    80005eec:	00451813          	slli	a6,a0,0x4
    80005ef0:	02080813          	addi	a6,a6,32
    80005ef4:	983e                	add	a6,a6,a5
    80005ef6:	577d                	li	a4,-1
    80005ef8:	00e80823          	sb	a4,16(a6)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    80005efc:	0612                	slli	a2,a2,0x4
    80005efe:	98b2                	add	a7,a7,a2
    80005f00:	03068713          	addi	a4,a3,48
    80005f04:	973e                	add	a4,a4,a5
    80005f06:	00e8b023          	sd	a4,0(a7)
  disk.desc[idx[2]].len = 1;
    80005f0a:	6398                	ld	a4,0(a5)
    80005f0c:	9732                	add	a4,a4,a2
    80005f0e:	c70c                	sw	a1,8(a4)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    80005f10:	4689                	li	a3,2
    80005f12:	00d71623          	sh	a3,12(a4)
  disk.desc[idx[2]].next = 0;
    80005f16:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    80005f1a:	00b9a223          	sw	a1,4(s3)
  disk.info[idx[0]].b = b;
    80005f1e:	01383423          	sd	s3,8(a6)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    80005f22:	6794                	ld	a3,8(a5)
    80005f24:	0026d703          	lhu	a4,2(a3)
    80005f28:	8b1d                	andi	a4,a4,7
    80005f2a:	0706                	slli	a4,a4,0x1
    80005f2c:	96ba                	add	a3,a3,a4
    80005f2e:	00a69223          	sh	a0,4(a3)

  __sync_synchronize();
    80005f32:	0330000f          	fence	rw,rw

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    80005f36:	6798                	ld	a4,8(a5)
    80005f38:	00275783          	lhu	a5,2(a4)
    80005f3c:	2785                	addiw	a5,a5,1
    80005f3e:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    80005f42:	0330000f          	fence	rw,rw

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80005f46:	100017b7          	lui	a5,0x10001
    80005f4a:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    80005f4e:	0049a783          	lw	a5,4(s3)
    sleep(b, &disk.vdisk_lock);
    80005f52:	0001d917          	auipc	s2,0x1d
    80005f56:	3e690913          	addi	s2,s2,998 # 80023338 <disk+0x128>
  while(b->disk == 1) {
    80005f5a:	84ae                	mv	s1,a1
    80005f5c:	00b79a63          	bne	a5,a1,80005f70 <virtio_disk_rw+0x1b0>
    sleep(b, &disk.vdisk_lock);
    80005f60:	85ca                	mv	a1,s2
    80005f62:	854e                	mv	a0,s3
    80005f64:	d5afc0ef          	jal	800024be <sleep>
  while(b->disk == 1) {
    80005f68:	0049a783          	lw	a5,4(s3)
    80005f6c:	fe978ae3          	beq	a5,s1,80005f60 <virtio_disk_rw+0x1a0>
  }

  disk.info[idx[0]].b = 0;
    80005f70:	fa042903          	lw	s2,-96(s0)
    80005f74:	00491713          	slli	a4,s2,0x4
    80005f78:	02070713          	addi	a4,a4,32
    80005f7c:	0001d797          	auipc	a5,0x1d
    80005f80:	29478793          	addi	a5,a5,660 # 80023210 <disk>
    80005f84:	97ba                	add	a5,a5,a4
    80005f86:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    80005f8a:	0001d997          	auipc	s3,0x1d
    80005f8e:	28698993          	addi	s3,s3,646 # 80023210 <disk>
    80005f92:	00491713          	slli	a4,s2,0x4
    80005f96:	0009b783          	ld	a5,0(s3)
    80005f9a:	97ba                	add	a5,a5,a4
    80005f9c:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    80005fa0:	854a                	mv	a0,s2
    80005fa2:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    80005fa6:	bddff0ef          	jal	80005b82 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    80005faa:	8885                	andi	s1,s1,1
    80005fac:	f0fd                	bnez	s1,80005f92 <virtio_disk_rw+0x1d2>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    80005fae:	0001d517          	auipc	a0,0x1d
    80005fb2:	38a50513          	addi	a0,a0,906 # 80023338 <disk+0x128>
    80005fb6:	e01fa0ef          	jal	80000db6 <release>
}
    80005fba:	60e6                	ld	ra,88(sp)
    80005fbc:	6446                	ld	s0,80(sp)
    80005fbe:	64a6                	ld	s1,72(sp)
    80005fc0:	6906                	ld	s2,64(sp)
    80005fc2:	79e2                	ld	s3,56(sp)
    80005fc4:	7a42                	ld	s4,48(sp)
    80005fc6:	7aa2                	ld	s5,40(sp)
    80005fc8:	7b02                	ld	s6,32(sp)
    80005fca:	6be2                	ld	s7,24(sp)
    80005fcc:	6c42                	ld	s8,16(sp)
    80005fce:	6125                	addi	sp,sp,96
    80005fd0:	8082                	ret

0000000080005fd2 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    80005fd2:	1101                	addi	sp,sp,-32
    80005fd4:	ec06                	sd	ra,24(sp)
    80005fd6:	e822                	sd	s0,16(sp)
    80005fd8:	e426                	sd	s1,8(sp)
    80005fda:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    80005fdc:	0001d497          	auipc	s1,0x1d
    80005fe0:	23448493          	addi	s1,s1,564 # 80023210 <disk>
    80005fe4:	0001d517          	auipc	a0,0x1d
    80005fe8:	35450513          	addi	a0,a0,852 # 80023338 <disk+0x128>
    80005fec:	d37fa0ef          	jal	80000d22 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    80005ff0:	100017b7          	lui	a5,0x10001
    80005ff4:	53bc                	lw	a5,96(a5)
    80005ff6:	8b8d                	andi	a5,a5,3
    80005ff8:	10001737          	lui	a4,0x10001
    80005ffc:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    80005ffe:	0330000f          	fence	rw,rw

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    80006002:	689c                	ld	a5,16(s1)
    80006004:	0204d703          	lhu	a4,32(s1)
    80006008:	0027d783          	lhu	a5,2(a5) # 10001002 <_entry-0x6fffeffe>
    8000600c:	04f70863          	beq	a4,a5,8000605c <virtio_disk_intr+0x8a>
    __sync_synchronize();
    80006010:	0330000f          	fence	rw,rw
    int id = disk.used->ring[disk.used_idx % NUM].id;
    80006014:	6898                	ld	a4,16(s1)
    80006016:	0204d783          	lhu	a5,32(s1)
    8000601a:	8b9d                	andi	a5,a5,7
    8000601c:	078e                	slli	a5,a5,0x3
    8000601e:	97ba                	add	a5,a5,a4
    80006020:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    80006022:	00479713          	slli	a4,a5,0x4
    80006026:	02070713          	addi	a4,a4,32 # 10001020 <_entry-0x6fffefe0>
    8000602a:	9726                	add	a4,a4,s1
    8000602c:	01074703          	lbu	a4,16(a4)
    80006030:	e329                	bnez	a4,80006072 <virtio_disk_intr+0xa0>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    80006032:	0792                	slli	a5,a5,0x4
    80006034:	02078793          	addi	a5,a5,32
    80006038:	97a6                	add	a5,a5,s1
    8000603a:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    8000603c:	00052223          	sw	zero,4(a0)
    wakeup(b);
    80006040:	ccafc0ef          	jal	8000250a <wakeup>

    disk.used_idx += 1;
    80006044:	0204d783          	lhu	a5,32(s1)
    80006048:	2785                	addiw	a5,a5,1
    8000604a:	17c2                	slli	a5,a5,0x30
    8000604c:	93c1                	srli	a5,a5,0x30
    8000604e:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    80006052:	6898                	ld	a4,16(s1)
    80006054:	00275703          	lhu	a4,2(a4)
    80006058:	faf71ce3          	bne	a4,a5,80006010 <virtio_disk_intr+0x3e>
  }

  release(&disk.vdisk_lock);
    8000605c:	0001d517          	auipc	a0,0x1d
    80006060:	2dc50513          	addi	a0,a0,732 # 80023338 <disk+0x128>
    80006064:	d53fa0ef          	jal	80000db6 <release>
}
    80006068:	60e2                	ld	ra,24(sp)
    8000606a:	6442                	ld	s0,16(sp)
    8000606c:	64a2                	ld	s1,8(sp)
    8000606e:	6105                	addi	sp,sp,32
    80006070:	8082                	ret
      panic("virtio_disk_intr status");
    80006072:	00002517          	auipc	a0,0x2
    80006076:	79650513          	addi	a0,a0,1942 # 80008808 <userret+0x176c>
    8000607a:	fdcfa0ef          	jal	80000856 <panic>

000000008000607e <cslog_init>:
  safestrcpy(e->name, p->name, CS_NM);
}

void
cslog_init(void)
{
    8000607e:	1141                	addi	sp,sp,-16
    80006080:	e406                	sd	ra,8(sp)
    80006082:	e022                	sd	s0,0(sp)
    80006084:	0800                	addi	s0,sp,16
  ringbuf_init(&cs_rb, "cslog", sizeof(struct cs_event));
    80006086:	03000613          	li	a2,48
    8000608a:	00002597          	auipc	a1,0x2
    8000608e:	79658593          	addi	a1,a1,1942 # 80008820 <userret+0x1784>
    80006092:	0001d517          	auipc	a0,0x1d
    80006096:	2be50513          	addi	a0,a0,702 # 80023350 <cs_rb>
    8000609a:	1a2000ef          	jal	8000623c <ringbuf_init>
}
    8000609e:	60a2                	ld	ra,8(sp)
    800060a0:	6402                	ld	s0,0(sp)
    800060a2:	0141                	addi	sp,sp,16
    800060a4:	8082                	ret

00000000800060a6 <cslog_push>:

void
cslog_push(struct cs_event *e)
{
    800060a6:	1141                	addi	sp,sp,-16
    800060a8:	e406                	sd	ra,8(sp)
    800060aa:	e022                	sd	s0,0(sp)
    800060ac:	0800                	addi	s0,sp,16
    800060ae:	85aa                	mv	a1,a0
  e->seq = ++cs_seq;
    800060b0:	00003717          	auipc	a4,0x3
    800060b4:	f8870713          	addi	a4,a4,-120 # 80009038 <cs_seq>
    800060b8:	631c                	ld	a5,0(a4)
    800060ba:	0785                	addi	a5,a5,1
    800060bc:	e31c                	sd	a5,0(a4)
    800060be:	e11c                	sd	a5,0(a0)
  ringbuf_push(&cs_rb, e);
    800060c0:	0001d517          	auipc	a0,0x1d
    800060c4:	29050513          	addi	a0,a0,656 # 80023350 <cs_rb>
    800060c8:	1a8000ef          	jal	80006270 <ringbuf_push>
}
    800060cc:	60a2                	ld	ra,8(sp)
    800060ce:	6402                	ld	s0,0(sp)
    800060d0:	0141                	addi	sp,sp,16
    800060d2:	8082                	ret

00000000800060d4 <cslog_read_many>:

int
cslog_read_many(struct cs_event *out, int max)
{
    800060d4:	1141                	addi	sp,sp,-16
    800060d6:	e406                	sd	ra,8(sp)
    800060d8:	e022                	sd	s0,0(sp)
    800060da:	0800                	addi	s0,sp,16
    800060dc:	862e                	mv	a2,a1
  return ringbuf_read_many(&cs_rb, out, max);
    800060de:	85aa                	mv	a1,a0
    800060e0:	0001d517          	auipc	a0,0x1d
    800060e4:	27050513          	addi	a0,a0,624 # 80023350 <cs_rb>
    800060e8:	1f4000ef          	jal	800062dc <ringbuf_read_many>
}
    800060ec:	60a2                	ld	ra,8(sp)
    800060ee:	6402                	ld	s0,0(sp)
    800060f0:	0141                	addi	sp,sp,16
    800060f2:	8082                	ret

00000000800060f4 <cslog_run_start>:

void
cslog_run_start(struct proc *p)
{
  if(p == 0) return;
    800060f4:	c14d                	beqz	a0,80006196 <cslog_run_start+0xa2>
{
    800060f6:	715d                	addi	sp,sp,-80
    800060f8:	e486                	sd	ra,72(sp)
    800060fa:	e0a2                	sd	s0,64(sp)
    800060fc:	fc26                	sd	s1,56(sp)
    800060fe:	0880                	addi	s0,sp,80
    80006100:	84aa                	mv	s1,a0
  if(p->pid <= 0) return;
    80006102:	591c                	lw	a5,48(a0)
    80006104:	00f05563          	blez	a5,8000610e <cslog_run_start+0x1a>
  if(p->name[0] == 0) return;
    80006108:	15854783          	lbu	a5,344(a0)
    8000610c:	e791                	bnez	a5,80006118 <cslog_run_start+0x24>

  struct cs_event e;
  fill_from_proc(&e, p);
  e.type = CS_RUN_START;
  cslog_push(&e);
    8000610e:	60a6                	ld	ra,72(sp)
    80006110:	6406                	ld	s0,64(sp)
    80006112:	74e2                	ld	s1,56(sp)
    80006114:	6161                	addi	sp,sp,80
    80006116:	8082                	ret
    80006118:	f84a                	sd	s2,48(sp)
  if(strncmp(p->name, "cscat", 5) == 0) return;
    8000611a:	15850913          	addi	s2,a0,344
    8000611e:	4615                	li	a2,5
    80006120:	00002597          	auipc	a1,0x2
    80006124:	70858593          	addi	a1,a1,1800 # 80008828 <userret+0x178c>
    80006128:	854a                	mv	a0,s2
    8000612a:	d9dfa0ef          	jal	80000ec6 <strncmp>
    8000612e:	e119                	bnez	a0,80006134 <cslog_run_start+0x40>
    80006130:	7942                	ld	s2,48(sp)
    80006132:	bff1                	j	8000610e <cslog_run_start+0x1a>
  if(strncmp(p->name, "csexport", 8) == 0) return;
    80006134:	4621                	li	a2,8
    80006136:	00002597          	auipc	a1,0x2
    8000613a:	6fa58593          	addi	a1,a1,1786 # 80008830 <userret+0x1794>
    8000613e:	854a                	mv	a0,s2
    80006140:	d87fa0ef          	jal	80000ec6 <strncmp>
    80006144:	e119                	bnez	a0,8000614a <cslog_run_start+0x56>
    80006146:	7942                	ld	s2,48(sp)
    80006148:	b7d9                	j	8000610e <cslog_run_start+0x1a>
  memset(e, 0, sizeof(*e));
    8000614a:	03000613          	li	a2,48
    8000614e:	4581                	li	a1,0
    80006150:	fb040513          	addi	a0,s0,-80
    80006154:	c9ffa0ef          	jal	80000df2 <memset>
  e->ticks = ticks;
    80006158:	00003797          	auipc	a5,0x3
    8000615c:	ed87a783          	lw	a5,-296(a5) # 80009030 <ticks>
    80006160:	faf42c23          	sw	a5,-72(s0)
  e->cpu   = cpuid();
    80006164:	afbfb0ef          	jal	80001c5e <cpuid>
    80006168:	faa42e23          	sw	a0,-68(s0)
  e->pid   = p->pid;
    8000616c:	589c                	lw	a5,48(s1)
    8000616e:	fcf42223          	sw	a5,-60(s0)
  e->state = p->state;
    80006172:	4c9c                	lw	a5,24(s1)
    80006174:	fcf42423          	sw	a5,-56(s0)
  safestrcpy(e->name, p->name, CS_NM);
    80006178:	4641                	li	a2,16
    8000617a:	85ca                	mv	a1,s2
    8000617c:	fcc40513          	addi	a0,s0,-52
    80006180:	dc7fa0ef          	jal	80000f46 <safestrcpy>
  e.type = CS_RUN_START;
    80006184:	4785                	li	a5,1
    80006186:	fcf42023          	sw	a5,-64(s0)
  cslog_push(&e);
    8000618a:	fb040513          	addi	a0,s0,-80
    8000618e:	f19ff0ef          	jal	800060a6 <cslog_push>
    80006192:	7942                	ld	s2,48(sp)
    80006194:	bfad                	j	8000610e <cslog_run_start+0x1a>
    80006196:	8082                	ret

0000000080006198 <sys_csread>:
#include "cslog.h"


uint64
sys_csread(void)
{
    80006198:	81010113          	addi	sp,sp,-2032
    8000619c:	7e113423          	sd	ra,2024(sp)
    800061a0:	7e813023          	sd	s0,2016(sp)
    800061a4:	7c913c23          	sd	s1,2008(sp)
    800061a8:	7d213823          	sd	s2,2000(sp)
    800061ac:	7f010413          	addi	s0,sp,2032
    800061b0:	bc010113          	addi	sp,sp,-1088
  uint64 uaddr = 0;
    800061b4:	fc043c23          	sd	zero,-40(s0)
  int max = 0;
    800061b8:	fc042a23          	sw	zero,-44(s0)

  // ✅ عندك argaddr/argint void، فبنستدعيهم بدون if
  argaddr(0, &uaddr);
    800061bc:	fd840593          	addi	a1,s0,-40
    800061c0:	4501                	li	a0,0
    800061c2:	c25fc0ef          	jal	80002de6 <argaddr>
  argint(1, &max);
    800061c6:	fd440593          	addi	a1,s0,-44
    800061ca:	4505                	li	a0,1
    800061cc:	bfffc0ef          	jal	80002dca <argint>

  if(max <= 0) return 0;
    800061d0:	fd442783          	lw	a5,-44(s0)
    800061d4:	4501                	li	a0,0
    800061d6:	04f05463          	blez	a5,8000621e <sys_csread+0x86>
  if(max > 64) max = 64;
    800061da:	04000713          	li	a4,64
    800061de:	00f75463          	bge	a4,a5,800061e6 <sys_csread+0x4e>
    800061e2:	fce42a23          	sw	a4,-44(s0)

  struct cs_event tmp[64];
  int n = cslog_read_many(tmp, max);
    800061e6:	80040493          	addi	s1,s0,-2048
    800061ea:	1481                	addi	s1,s1,-32
    800061ec:	bf048493          	addi	s1,s1,-1040
    800061f0:	fd442583          	lw	a1,-44(s0)
    800061f4:	8526                	mv	a0,s1
    800061f6:	edfff0ef          	jal	800060d4 <cslog_read_many>
    800061fa:	892a                	mv	s2,a0

  int bytes = n * (int)sizeof(struct cs_event);
  if(copyout(myproc()->pagetable, uaddr, (char*)tmp, bytes) < 0)
    800061fc:	a97fb0ef          	jal	80001c92 <myproc>
  int bytes = n * (int)sizeof(struct cs_event);
    80006200:	0019169b          	slliw	a3,s2,0x1
    80006204:	012686bb          	addw	a3,a3,s2
  if(copyout(myproc()->pagetable, uaddr, (char*)tmp, bytes) < 0)
    80006208:	0046969b          	slliw	a3,a3,0x4
    8000620c:	8626                	mv	a2,s1
    8000620e:	fd843583          	ld	a1,-40(s0)
    80006212:	6928                	ld	a0,80(a0)
    80006214:	f90fb0ef          	jal	800019a4 <copyout>
    80006218:	02054063          	bltz	a0,80006238 <sys_csread+0xa0>
    return -1;

  return n;
    8000621c:	854a                	mv	a0,s2
}
    8000621e:	44010113          	addi	sp,sp,1088
    80006222:	7e813083          	ld	ra,2024(sp)
    80006226:	7e013403          	ld	s0,2016(sp)
    8000622a:	7d813483          	ld	s1,2008(sp)
    8000622e:	7d013903          	ld	s2,2000(sp)
    80006232:	7f010113          	addi	sp,sp,2032
    80006236:	8082                	ret
    return -1;
    80006238:	557d                	li	a0,-1
    8000623a:	b7d5                	j	8000621e <sys_csread+0x86>

000000008000623c <ringbuf_init>:
  return (void *)(rb->buf + idx * rb->elem_size);
}

void
ringbuf_init(struct ringbuf *rb, char *name, uint elem_size)
{
    8000623c:	1101                	addi	sp,sp,-32
    8000623e:	ec06                	sd	ra,24(sp)
    80006240:	e822                	sd	s0,16(sp)
    80006242:	e426                	sd	s1,8(sp)
    80006244:	e04a                	sd	s2,0(sp)
    80006246:	1000                	addi	s0,sp,32
    80006248:	84aa                	mv	s1,a0
    8000624a:	8932                	mv	s2,a2
  initlock(&rb->lock, name);
    8000624c:	a4dfa0ef          	jal	80000c98 <initlock>
  rb->head = 0;
    80006250:	0004ac23          	sw	zero,24(s1)
  rb->tail = 0;
    80006254:	0004ae23          	sw	zero,28(s1)
  rb->count = 0;
    80006258:	0204a023          	sw	zero,32(s1)
  rb->seq = 0;
    8000625c:	0204b423          	sd	zero,40(s1)
  rb->elem_size = elem_size;
    80006260:	0324a223          	sw	s2,36(s1)
}
    80006264:	60e2                	ld	ra,24(sp)
    80006266:	6442                	ld	s0,16(sp)
    80006268:	64a2                	ld	s1,8(sp)
    8000626a:	6902                	ld	s2,0(sp)
    8000626c:	6105                	addi	sp,sp,32
    8000626e:	8082                	ret

0000000080006270 <ringbuf_push>:

int
ringbuf_push(struct ringbuf *rb, void *elem)
{
    80006270:	1101                	addi	sp,sp,-32
    80006272:	ec06                	sd	ra,24(sp)
    80006274:	e822                	sd	s0,16(sp)
    80006276:	e426                	sd	s1,8(sp)
    80006278:	e04a                	sd	s2,0(sp)
    8000627a:	1000                	addi	s0,sp,32
    8000627c:	84aa                	mv	s1,a0
    8000627e:	892e                	mv	s2,a1
  acquire(&rb->lock);
    80006280:	aa3fa0ef          	jal	80000d22 <acquire>

  if(rb->count == RB_CAP){
    80006284:	5098                	lw	a4,32(s1)
    80006286:	20000793          	li	a5,512
    8000628a:	04f70063          	beq	a4,a5,800062ca <ringbuf_push+0x5a>
  return (void *)(rb->buf + idx * rb->elem_size);
    8000628e:	50d0                	lw	a2,36(s1)
    80006290:	03048513          	addi	a0,s1,48
    80006294:	4c9c                	lw	a5,24(s1)
    80006296:	02c787bb          	mulw	a5,a5,a2
    8000629a:	1782                	slli	a5,a5,0x20
    8000629c:	9381                	srli	a5,a5,0x20
    rb->tail = (rb->tail + 1) % RB_CAP;
    rb->count--;
  }

  memmove(slot_ptr(rb, rb->head), elem, rb->elem_size);
    8000629e:	85ca                	mv	a1,s2
    800062a0:	953e                	add	a0,a0,a5
    800062a2:	bb1fa0ef          	jal	80000e52 <memmove>
  rb->head = (rb->head + 1) % RB_CAP;
    800062a6:	4c9c                	lw	a5,24(s1)
    800062a8:	2785                	addiw	a5,a5,1
    800062aa:	1ff7f793          	andi	a5,a5,511
    800062ae:	cc9c                	sw	a5,24(s1)
  rb->count++;
    800062b0:	509c                	lw	a5,32(s1)
    800062b2:	2785                	addiw	a5,a5,1
    800062b4:	d09c                	sw	a5,32(s1)

  release(&rb->lock);
    800062b6:	8526                	mv	a0,s1
    800062b8:	afffa0ef          	jal	80000db6 <release>
  return 0;
}
    800062bc:	4501                	li	a0,0
    800062be:	60e2                	ld	ra,24(sp)
    800062c0:	6442                	ld	s0,16(sp)
    800062c2:	64a2                	ld	s1,8(sp)
    800062c4:	6902                	ld	s2,0(sp)
    800062c6:	6105                	addi	sp,sp,32
    800062c8:	8082                	ret
    rb->tail = (rb->tail + 1) % RB_CAP;
    800062ca:	4cdc                	lw	a5,28(s1)
    800062cc:	2785                	addiw	a5,a5,1
    800062ce:	1ff7f793          	andi	a5,a5,511
    800062d2:	ccdc                	sw	a5,28(s1)
    rb->count--;
    800062d4:	1ff00793          	li	a5,511
    800062d8:	d09c                	sw	a5,32(s1)
    800062da:	bf55                	j	8000628e <ringbuf_push+0x1e>

00000000800062dc <ringbuf_read_many>:
ringbuf_read_many(struct ringbuf *rb, void *out, int max)
{
  int n = 0;
  char *dst = (char *)out;

  if(max <= 0)
    800062dc:	06c05d63          	blez	a2,80006356 <ringbuf_read_many+0x7a>
{
    800062e0:	7139                	addi	sp,sp,-64
    800062e2:	fc06                	sd	ra,56(sp)
    800062e4:	f822                	sd	s0,48(sp)
    800062e6:	f426                	sd	s1,40(sp)
    800062e8:	f04a                	sd	s2,32(sp)
    800062ea:	ec4e                	sd	s3,24(sp)
    800062ec:	e852                	sd	s4,16(sp)
    800062ee:	e456                	sd	s5,8(sp)
    800062f0:	0080                	addi	s0,sp,64
    800062f2:	84aa                	mv	s1,a0
    800062f4:	8a2e                	mv	s4,a1
    800062f6:	89b2                	mv	s3,a2
    return 0;

  acquire(&rb->lock);
    800062f8:	a2bfa0ef          	jal	80000d22 <acquire>
  int n = 0;
    800062fc:	4901                	li	s2,0
  return (void *)(rb->buf + idx * rb->elem_size);
    800062fe:	03048a93          	addi	s5,s1,48
  while(n < max && rb->count > 0){
    80006302:	509c                	lw	a5,32(s1)
    80006304:	c7b9                	beqz	a5,80006352 <ringbuf_read_many+0x76>
    memmove(dst + n * rb->elem_size, slot_ptr(rb, rb->tail), rb->elem_size);
    80006306:	50d0                	lw	a2,36(s1)
  return (void *)(rb->buf + idx * rb->elem_size);
    80006308:	4ccc                	lw	a1,28(s1)
    8000630a:	02c585bb          	mulw	a1,a1,a2
    8000630e:	1582                	slli	a1,a1,0x20
    80006310:	9181                	srli	a1,a1,0x20
    memmove(dst + n * rb->elem_size, slot_ptr(rb, rb->tail), rb->elem_size);
    80006312:	02c9053b          	mulw	a0,s2,a2
    80006316:	1502                	slli	a0,a0,0x20
    80006318:	9101                	srli	a0,a0,0x20
    8000631a:	95d6                	add	a1,a1,s5
    8000631c:	9552                	add	a0,a0,s4
    8000631e:	b35fa0ef          	jal	80000e52 <memmove>
    rb->tail = (rb->tail + 1) % RB_CAP;
    80006322:	4cdc                	lw	a5,28(s1)
    80006324:	2785                	addiw	a5,a5,1
    80006326:	1ff7f793          	andi	a5,a5,511
    8000632a:	ccdc                	sw	a5,28(s1)
    rb->count--;
    8000632c:	509c                	lw	a5,32(s1)
    8000632e:	37fd                	addiw	a5,a5,-1
    80006330:	d09c                	sw	a5,32(s1)
    n++;
    80006332:	2905                	addiw	s2,s2,1
  while(n < max && rb->count > 0){
    80006334:	fd2997e3          	bne	s3,s2,80006302 <ringbuf_read_many+0x26>
  }
  release(&rb->lock);
    80006338:	8526                	mv	a0,s1
    8000633a:	a7dfa0ef          	jal	80000db6 <release>

  return n;
    8000633e:	854e                	mv	a0,s3
}
    80006340:	70e2                	ld	ra,56(sp)
    80006342:	7442                	ld	s0,48(sp)
    80006344:	74a2                	ld	s1,40(sp)
    80006346:	7902                	ld	s2,32(sp)
    80006348:	69e2                	ld	s3,24(sp)
    8000634a:	6a42                	ld	s4,16(sp)
    8000634c:	6aa2                	ld	s5,8(sp)
    8000634e:	6121                	addi	sp,sp,64
    80006350:	8082                	ret
    80006352:	89ca                	mv	s3,s2
    80006354:	b7d5                	j	80006338 <ringbuf_read_many+0x5c>
    return 0;
    80006356:	4501                	li	a0,0
}
    80006358:	8082                	ret

000000008000635a <ringbuf_pop>:
int
ringbuf_pop(struct ringbuf *rb, void *dst)
{
    8000635a:	1101                	addi	sp,sp,-32
    8000635c:	ec06                	sd	ra,24(sp)
    8000635e:	e822                	sd	s0,16(sp)
    80006360:	e426                	sd	s1,8(sp)
    80006362:	e04a                	sd	s2,0(sp)
    80006364:	1000                	addi	s0,sp,32
    80006366:	84aa                	mv	s1,a0
    80006368:	892e                	mv	s2,a1
  acquire(&rb->lock);
    8000636a:	9b9fa0ef          	jal	80000d22 <acquire>
  
  if(rb->count == 0){ // البفر فارغ تماماً
    8000636e:	509c                	lw	a5,32(s1)
    80006370:	cf9d                	beqz	a5,800063ae <ringbuf_pop+0x54>
  return (void *)(rb->buf + idx * rb->elem_size);
    80006372:	50d0                	lw	a2,36(s1)
    80006374:	03048593          	addi	a1,s1,48
    80006378:	4cdc                	lw	a5,28(s1)
    8000637a:	02c787bb          	mulw	a5,a5,a2
    8000637e:	1782                	slli	a5,a5,0x20
    80006380:	9381                	srli	a5,a5,0x20
    return -1;
  }

  // استخدام الدالة المساعدة slot_ptr الموجودة عندك أصلاً
  void *src = slot_ptr(rb, rb->tail);
  memmove(dst, src, rb->elem_size);
    80006382:	95be                	add	a1,a1,a5
    80006384:	854a                	mv	a0,s2
    80006386:	acdfa0ef          	jal	80000e52 <memmove>
  
  // تحديث المؤشرات بنفس منطق المشروع
  rb->tail = (rb->tail + 1) % RB_CAP;
    8000638a:	4cdc                	lw	a5,28(s1)
    8000638c:	2785                	addiw	a5,a5,1
    8000638e:	1ff7f793          	andi	a5,a5,511
    80006392:	ccdc                	sw	a5,28(s1)
  rb->count--;
    80006394:	509c                	lw	a5,32(s1)
    80006396:	37fd                	addiw	a5,a5,-1
    80006398:	d09c                	sw	a5,32(s1)
  
  release(&rb->lock);
    8000639a:	8526                	mv	a0,s1
    8000639c:	a1bfa0ef          	jal	80000db6 <release>
  return 0;
    800063a0:	4501                	li	a0,0
} 
    800063a2:	60e2                	ld	ra,24(sp)
    800063a4:	6442                	ld	s0,16(sp)
    800063a6:	64a2                	ld	s1,8(sp)
    800063a8:	6902                	ld	s2,0(sp)
    800063aa:	6105                	addi	sp,sp,32
    800063ac:	8082                	ret
    release(&rb->lock);
    800063ae:	8526                	mv	a0,s1
    800063b0:	a07fa0ef          	jal	80000db6 <release>
    return -1;
    800063b4:	557d                	li	a0,-1
    800063b6:	b7f5                	j	800063a2 <ringbuf_pop+0x48>

00000000800063b8 <fslog_init>:
#include "defs.h"

static struct ringbuf fs_rb;
static uint64 fs_seq = 0;

void fslog_init(void) {
    800063b8:	1141                	addi	sp,sp,-16
    800063ba:	e406                	sd	ra,8(sp)
    800063bc:	e022                	sd	s0,0(sp)
    800063be:	0800                	addi	s0,sp,16
  ringbuf_init(&fs_rb, "fslog", sizeof(struct fs_event));
    800063c0:	03000613          	li	a2,48
    800063c4:	00002597          	auipc	a1,0x2
    800063c8:	47c58593          	addi	a1,a1,1148 # 80008840 <userret+0x17a4>
    800063cc:	00025517          	auipc	a0,0x25
    800063d0:	fb450513          	addi	a0,a0,-76 # 8002b380 <fs_rb>
    800063d4:	e69ff0ef          	jal	8000623c <ringbuf_init>
}
    800063d8:	60a2                	ld	ra,8(sp)
    800063da:	6402                	ld	s0,0(sp)
    800063dc:	0141                	addi	sp,sp,16
    800063de:	8082                	ret

00000000800063e0 <fslog_push>:

void fslog_push(int type, int inum, int bno, uint size, char* name) {
    800063e0:	7159                	addi	sp,sp,-112
    800063e2:	f486                	sd	ra,104(sp)
    800063e4:	f0a2                	sd	s0,96(sp)
    800063e6:	eca6                	sd	s1,88(sp)
    800063e8:	e8ca                	sd	s2,80(sp)
    800063ea:	e4ce                	sd	s3,72(sp)
    800063ec:	e0d2                	sd	s4,64(sp)
    800063ee:	fc56                	sd	s5,56(sp)
    800063f0:	1880                	addi	s0,sp,112
    800063f2:	84aa                	mv	s1,a0
    800063f4:	892e                	mv	s2,a1
    800063f6:	89b2                	mv	s3,a2
    800063f8:	8a36                	mv	s4,a3
    800063fa:	8aba                	mv	s5,a4
  struct fs_event e;
  memset(&e, 0, sizeof(e));
    800063fc:	03000613          	li	a2,48
    80006400:	4581                	li	a1,0
    80006402:	f9040513          	addi	a0,s0,-112
    80006406:	9edfa0ef          	jal	80000df2 <memset>
  e.seq = ++fs_seq;
    8000640a:	00003717          	auipc	a4,0x3
    8000640e:	c3670713          	addi	a4,a4,-970 # 80009040 <fs_seq>
    80006412:	631c                	ld	a5,0(a4)
    80006414:	0785                	addi	a5,a5,1
    80006416:	e31c                	sd	a5,0(a4)
    80006418:	f8f43823          	sd	a5,-112(s0)
  e.ticks = ticks;
    8000641c:	00003797          	auipc	a5,0x3
    80006420:	c147a783          	lw	a5,-1004(a5) # 80009030 <ticks>
    80006424:	f8f42c23          	sw	a5,-104(s0)
  e.type = type;
    80006428:	f8942e23          	sw	s1,-100(s0)
  e.pid = myproc() ? myproc()->pid : 0;
    8000642c:	867fb0ef          	jal	80001c92 <myproc>
    80006430:	4781                	li	a5,0
    80006432:	c501                	beqz	a0,8000643a <fslog_push+0x5a>
    80006434:	85ffb0ef          	jal	80001c92 <myproc>
    80006438:	591c                	lw	a5,48(a0)
    8000643a:	faf42023          	sw	a5,-96(s0)
  e.inum = inum;
    8000643e:	fb242223          	sw	s2,-92(s0)
  e.blockno = bno;
    80006442:	fb342423          	sw	s3,-88(s0)
  e.size = size;
    80006446:	fb442623          	sw	s4,-84(s0)
  if(name) safestrcpy(e.name, name, FS_NM);
    8000644a:	000a8863          	beqz	s5,8000645a <fslog_push+0x7a>
    8000644e:	4641                	li	a2,16
    80006450:	85d6                	mv	a1,s5
    80006452:	fb040513          	addi	a0,s0,-80
    80006456:	af1fa0ef          	jal	80000f46 <safestrcpy>
  ringbuf_push(&fs_rb, &e);
    8000645a:	f9040593          	addi	a1,s0,-112
    8000645e:	00025517          	auipc	a0,0x25
    80006462:	f2250513          	addi	a0,a0,-222 # 8002b380 <fs_rb>
    80006466:	e0bff0ef          	jal	80006270 <ringbuf_push>
}
    8000646a:	70a6                	ld	ra,104(sp)
    8000646c:	7406                	ld	s0,96(sp)
    8000646e:	64e6                	ld	s1,88(sp)
    80006470:	6946                	ld	s2,80(sp)
    80006472:	69a6                	ld	s3,72(sp)
    80006474:	6a06                	ld	s4,64(sp)
    80006476:	7ae2                	ld	s5,56(sp)
    80006478:	6165                	addi	sp,sp,112
    8000647a:	8082                	ret

000000008000647c <fslog_read_many>:
// لا تنسي إضافة fslog_read_many أيضاً هنا

int
fslog_read_many(struct fs_event *out, int max)
{
    8000647c:	7119                	addi	sp,sp,-128
    8000647e:	fc86                	sd	ra,120(sp)
    80006480:	f8a2                	sd	s0,112(sp)
    80006482:	f4a6                	sd	s1,104(sp)
    80006484:	f0ca                	sd	s2,96(sp)
    80006486:	e8d2                	sd	s4,80(sp)
    80006488:	0100                	addi	s0,sp,128
    8000648a:	84aa                	mv	s1,a0
    8000648c:	8a2e                	mv	s4,a1
  struct fs_event e;
  int count = 0;
  struct proc *p = myproc();
    8000648e:	805fb0ef          	jal	80001c92 <myproc>

  while(count < max){
    80006492:	05405863          	blez	s4,800064e2 <fslog_read_many+0x66>
    80006496:	ecce                	sd	s3,88(sp)
    80006498:	e4d6                	sd	s5,72(sp)
    8000649a:	e0da                	sd	s6,64(sp)
    8000649c:	fc5e                	sd	s7,56(sp)
    8000649e:	8aaa                	mv	s5,a0
  int count = 0;
    800064a0:	4901                	li	s2,0
    // سحب حدث واحد من الرينغ بفر (موجود في ذاكرة الكيرنل)
    if(ringbuf_pop(&fs_rb, &e) != 0)
    800064a2:	f8040993          	addi	s3,s0,-128
    800064a6:	00025b17          	auipc	s6,0x25
    800064aa:	edab0b13          	addi	s6,s6,-294 # 8002b380 <fs_rb>
      break;

    // 🔥 النسخ الآمن لذاكرة المستخدم باستخدام copyout
    // العنوان الهدف: out + (count * حجم الـ struct)
    uint64 dst_addr = (uint64)out + (count * sizeof(struct fs_event));
    if(copyout(p->pagetable, dst_addr, (char *)&e, sizeof(struct fs_event)) < 0)
    800064ae:	03000b93          	li	s7,48
    if(ringbuf_pop(&fs_rb, &e) != 0)
    800064b2:	85ce                	mv	a1,s3
    800064b4:	855a                	mv	a0,s6
    800064b6:	ea5ff0ef          	jal	8000635a <ringbuf_pop>
    800064ba:	e515                	bnez	a0,800064e6 <fslog_read_many+0x6a>
    if(copyout(p->pagetable, dst_addr, (char *)&e, sizeof(struct fs_event)) < 0)
    800064bc:	86de                	mv	a3,s7
    800064be:	864e                	mv	a2,s3
    800064c0:	85a6                	mv	a1,s1
    800064c2:	050ab503          	ld	a0,80(s5)
    800064c6:	cdefb0ef          	jal	800019a4 <copyout>
    800064ca:	02054a63          	bltz	a0,800064fe <fslog_read_many+0x82>
      break;

    count++;
    800064ce:	2905                	addiw	s2,s2,1
  while(count < max){
    800064d0:	03048493          	addi	s1,s1,48
    800064d4:	fd2a1fe3          	bne	s4,s2,800064b2 <fslog_read_many+0x36>
    800064d8:	69e6                	ld	s3,88(sp)
    800064da:	6aa6                	ld	s5,72(sp)
    800064dc:	6b06                	ld	s6,64(sp)
    800064de:	7be2                	ld	s7,56(sp)
    800064e0:	a039                	j	800064ee <fslog_read_many+0x72>
  int count = 0;
    800064e2:	4901                	li	s2,0
    800064e4:	a029                	j	800064ee <fslog_read_many+0x72>
    800064e6:	69e6                	ld	s3,88(sp)
    800064e8:	6aa6                	ld	s5,72(sp)
    800064ea:	6b06                	ld	s6,64(sp)
    800064ec:	7be2                	ld	s7,56(sp)
  }
  return count;
    800064ee:	854a                	mv	a0,s2
    800064f0:	70e6                	ld	ra,120(sp)
    800064f2:	7446                	ld	s0,112(sp)
    800064f4:	74a6                	ld	s1,104(sp)
    800064f6:	7906                	ld	s2,96(sp)
    800064f8:	6a46                	ld	s4,80(sp)
    800064fa:	6109                	addi	sp,sp,128
    800064fc:	8082                	ret
    800064fe:	69e6                	ld	s3,88(sp)
    80006500:	6aa6                	ld	s5,72(sp)
    80006502:	6b06                	ld	s6,64(sp)
    80006504:	7be2                	ld	s7,56(sp)
    80006506:	b7e5                	j	800064ee <fslog_read_many+0x72>

0000000080006508 <memlog_init>:
static uint mem_count = 0;
static uint64 mem_seq = 0;

void
memlog_init(void)
{
    80006508:	1141                	addi	sp,sp,-16
    8000650a:	e406                	sd	ra,8(sp)
    8000650c:	e022                	sd	s0,0(sp)
    8000650e:	0800                	addi	s0,sp,16
  initlock(&mem_lock, "memlog");
    80006510:	00002597          	auipc	a1,0x2
    80006514:	33858593          	addi	a1,a1,824 # 80008848 <userret+0x17ac>
    80006518:	0002d517          	auipc	a0,0x2d
    8000651c:	e9850513          	addi	a0,a0,-360 # 800333b0 <mem_lock>
    80006520:	f78fa0ef          	jal	80000c98 <initlock>
  mem_head = 0;
    80006524:	00003797          	auipc	a5,0x3
    80006528:	b207aa23          	sw	zero,-1228(a5) # 80009058 <mem_head>
  mem_tail = 0;
    8000652c:	00003797          	auipc	a5,0x3
    80006530:	b207a423          	sw	zero,-1240(a5) # 80009054 <mem_tail>
  mem_count = 0;
    80006534:	00003797          	auipc	a5,0x3
    80006538:	b007ae23          	sw	zero,-1252(a5) # 80009050 <mem_count>
  mem_seq = 0;
    8000653c:	00003797          	auipc	a5,0x3
    80006540:	b007b623          	sd	zero,-1268(a5) # 80009048 <mem_seq>
}
    80006544:	60a2                	ld	ra,8(sp)
    80006546:	6402                	ld	s0,0(sp)
    80006548:	0141                	addi	sp,sp,16
    8000654a:	8082                	ret

000000008000654c <memlog_push>:

void
memlog_push(struct mem_event *e)
{
    8000654c:	1101                	addi	sp,sp,-32
    8000654e:	ec06                	sd	ra,24(sp)
    80006550:	e822                	sd	s0,16(sp)
    80006552:	e426                	sd	s1,8(sp)
    80006554:	1000                	addi	s0,sp,32
    80006556:	84aa                	mv	s1,a0
  acquire(&mem_lock);
    80006558:	0002d517          	auipc	a0,0x2d
    8000655c:	e5850513          	addi	a0,a0,-424 # 800333b0 <mem_lock>
    80006560:	fc2fa0ef          	jal	80000d22 <acquire>

  e->seq = ++mem_seq;
    80006564:	00003717          	auipc	a4,0x3
    80006568:	ae470713          	addi	a4,a4,-1308 # 80009048 <mem_seq>
    8000656c:	631c                	ld	a5,0(a4)
    8000656e:	0785                	addi	a5,a5,1
    80006570:	e31c                	sd	a5,0(a4)
    80006572:	e09c                	sd	a5,0(s1)

  if(mem_count == MEM_RB_CAP){
    80006574:	00003717          	auipc	a4,0x3
    80006578:	adc72703          	lw	a4,-1316(a4) # 80009050 <mem_count>
    8000657c:	20000793          	li	a5,512
    80006580:	06f70e63          	beq	a4,a5,800065fc <memlog_push+0xb0>
    mem_tail = (mem_tail + 1) % MEM_RB_CAP;
    mem_count--;
  }

  mem_buf[mem_head] = *e;
    80006584:	00003617          	auipc	a2,0x3
    80006588:	ad462603          	lw	a2,-1324(a2) # 80009058 <mem_head>
    8000658c:	02061693          	slli	a3,a2,0x20
    80006590:	9281                	srli	a3,a3,0x20
    80006592:	06800793          	li	a5,104
    80006596:	02f686b3          	mul	a3,a3,a5
    8000659a:	8726                	mv	a4,s1
    8000659c:	0002d797          	auipc	a5,0x2d
    800065a0:	e2c78793          	addi	a5,a5,-468 # 800333c8 <mem_buf>
    800065a4:	97b6                	add	a5,a5,a3
    800065a6:	06048493          	addi	s1,s1,96
    800065aa:	6308                	ld	a0,0(a4)
    800065ac:	670c                	ld	a1,8(a4)
    800065ae:	6b14                	ld	a3,16(a4)
    800065b0:	e388                	sd	a0,0(a5)
    800065b2:	e78c                	sd	a1,8(a5)
    800065b4:	eb94                	sd	a3,16(a5)
    800065b6:	6f14                	ld	a3,24(a4)
    800065b8:	ef94                	sd	a3,24(a5)
    800065ba:	02070713          	addi	a4,a4,32
    800065be:	02078793          	addi	a5,a5,32
    800065c2:	fe9714e3          	bne	a4,s1,800065aa <memlog_push+0x5e>
    800065c6:	6318                	ld	a4,0(a4)
    800065c8:	e398                	sd	a4,0(a5)
  mem_head = (mem_head + 1) % MEM_RB_CAP;
    800065ca:	2605                	addiw	a2,a2,1
    800065cc:	1ff67613          	andi	a2,a2,511
    800065d0:	00003797          	auipc	a5,0x3
    800065d4:	a8c7a423          	sw	a2,-1400(a5) # 80009058 <mem_head>
  mem_count++;
    800065d8:	00003717          	auipc	a4,0x3
    800065dc:	a7870713          	addi	a4,a4,-1416 # 80009050 <mem_count>
    800065e0:	431c                	lw	a5,0(a4)
    800065e2:	2785                	addiw	a5,a5,1
    800065e4:	c31c                	sw	a5,0(a4)

  release(&mem_lock);
    800065e6:	0002d517          	auipc	a0,0x2d
    800065ea:	dca50513          	addi	a0,a0,-566 # 800333b0 <mem_lock>
    800065ee:	fc8fa0ef          	jal	80000db6 <release>
}
    800065f2:	60e2                	ld	ra,24(sp)
    800065f4:	6442                	ld	s0,16(sp)
    800065f6:	64a2                	ld	s1,8(sp)
    800065f8:	6105                	addi	sp,sp,32
    800065fa:	8082                	ret
    mem_tail = (mem_tail + 1) % MEM_RB_CAP;
    800065fc:	00003717          	auipc	a4,0x3
    80006600:	a5870713          	addi	a4,a4,-1448 # 80009054 <mem_tail>
    80006604:	431c                	lw	a5,0(a4)
    80006606:	2785                	addiw	a5,a5,1
    80006608:	1ff7f793          	andi	a5,a5,511
    8000660c:	c31c                	sw	a5,0(a4)
    mem_count--;
    8000660e:	1ff00793          	li	a5,511
    80006612:	00003717          	auipc	a4,0x3
    80006616:	a2f72f23          	sw	a5,-1474(a4) # 80009050 <mem_count>
    8000661a:	b7ad                	j	80006584 <memlog_push+0x38>

000000008000661c <memlog_read_many>:

int
memlog_read_many(struct mem_event *out, int max)
{
    8000661c:	1101                	addi	sp,sp,-32
    8000661e:	ec06                	sd	ra,24(sp)
    80006620:	e822                	sd	s0,16(sp)
    80006622:	e04a                	sd	s2,0(sp)
    80006624:	1000                	addi	s0,sp,32
  int n = 0;

  if(max <= 0)
    return 0;
    80006626:	4901                	li	s2,0
  if(max <= 0)
    80006628:	0ab05963          	blez	a1,800066da <memlog_read_many+0xbe>
    8000662c:	e426                	sd	s1,8(sp)
    8000662e:	892a                	mv	s2,a0
    80006630:	84ae                	mv	s1,a1

  acquire(&mem_lock);
    80006632:	0002d517          	auipc	a0,0x2d
    80006636:	d7e50513          	addi	a0,a0,-642 # 800333b0 <mem_lock>
    8000663a:	ee8fa0ef          	jal	80000d22 <acquire>
  while(n < max && mem_count > 0){
    8000663e:	00003697          	auipc	a3,0x3
    80006642:	a166a683          	lw	a3,-1514(a3) # 80009054 <mem_tail>
    80006646:	00003317          	auipc	t1,0x3
    8000664a:	a0a32303          	lw	t1,-1526(t1) # 80009050 <mem_count>
    8000664e:	854a                	mv	a0,s2
  acquire(&mem_lock);
    80006650:	4701                	li	a4,0
  int n = 0;
    80006652:	4901                	li	s2,0
    out[n] = mem_buf[mem_tail];
    80006654:	0002de97          	auipc	t4,0x2d
    80006658:	d74e8e93          	addi	t4,t4,-652 # 800333c8 <mem_buf>
    8000665c:	06800e13          	li	t3,104
    80006660:	4f05                	li	t5,1
  while(n < max && mem_count > 0){
    80006662:	08030263          	beqz	t1,800066e6 <memlog_read_many+0xca>
    out[n] = mem_buf[mem_tail];
    80006666:	02069793          	slli	a5,a3,0x20
    8000666a:	9381                	srli	a5,a5,0x20
    8000666c:	03c787b3          	mul	a5,a5,t3
    80006670:	97f6                	add	a5,a5,t4
    80006672:	872a                	mv	a4,a0
    80006674:	06078613          	addi	a2,a5,96
    80006678:	0007b883          	ld	a7,0(a5)
    8000667c:	0087b803          	ld	a6,8(a5)
    80006680:	6b8c                	ld	a1,16(a5)
    80006682:	01173023          	sd	a7,0(a4)
    80006686:	01073423          	sd	a6,8(a4)
    8000668a:	eb0c                	sd	a1,16(a4)
    8000668c:	0187b803          	ld	a6,24(a5)
    80006690:	01073c23          	sd	a6,24(a4)
    80006694:	02078793          	addi	a5,a5,32
    80006698:	02070713          	addi	a4,a4,32
    8000669c:	fcc79ee3          	bne	a5,a2,80006678 <memlog_read_many+0x5c>
    800066a0:	639c                	ld	a5,0(a5)
    800066a2:	e31c                	sd	a5,0(a4)
    mem_tail = (mem_tail + 1) % MEM_RB_CAP;
    800066a4:	2685                	addiw	a3,a3,1
    800066a6:	1ff6f693          	andi	a3,a3,511
    mem_count--;
    800066aa:	fff3079b          	addiw	a5,t1,-1
    800066ae:	833e                	mv	t1,a5
    n++;
    800066b0:	2905                	addiw	s2,s2,1
  while(n < max && mem_count > 0){
    800066b2:	06850513          	addi	a0,a0,104
    800066b6:	877a                	mv	a4,t5
    800066b8:	fb2495e3          	bne	s1,s2,80006662 <memlog_read_many+0x46>
    800066bc:	00003717          	auipc	a4,0x3
    800066c0:	98d72c23          	sw	a3,-1640(a4) # 80009054 <mem_tail>
    800066c4:	00003717          	auipc	a4,0x3
    800066c8:	98f72623          	sw	a5,-1652(a4) # 80009050 <mem_count>
  }
  release(&mem_lock);
    800066cc:	0002d517          	auipc	a0,0x2d
    800066d0:	ce450513          	addi	a0,a0,-796 # 800333b0 <mem_lock>
    800066d4:	ee2fa0ef          	jal	80000db6 <release>

  return n;
    800066d8:	64a2                	ld	s1,8(sp)
    800066da:	854a                	mv	a0,s2
    800066dc:	60e2                	ld	ra,24(sp)
    800066de:	6442                	ld	s0,16(sp)
    800066e0:	6902                	ld	s2,0(sp)
    800066e2:	6105                	addi	sp,sp,32
    800066e4:	8082                	ret
    800066e6:	d37d                	beqz	a4,800066cc <memlog_read_many+0xb0>
    800066e8:	00003797          	auipc	a5,0x3
    800066ec:	96d7a623          	sw	a3,-1684(a5) # 80009054 <mem_tail>
    800066f0:	00003797          	auipc	a5,0x3
    800066f4:	9607a023          	sw	zero,-1696(a5) # 80009050 <mem_count>
    800066f8:	bfd1                	j	800066cc <memlog_read_many+0xb0>

00000000800066fa <sys_memread>:
#include "memevent.h"
#include "memlog.h"

uint64
sys_memread(void)
{
    800066fa:	95010113          	addi	sp,sp,-1712
    800066fe:	6a113423          	sd	ra,1704(sp)
    80006702:	6a813023          	sd	s0,1696(sp)
    80006706:	6b010413          	addi	s0,sp,1712
  uint64 uaddr = 0;
    8000670a:	fc043c23          	sd	zero,-40(s0)
  int max = 0;
    8000670e:	fc042a23          	sw	zero,-44(s0)

  argaddr(0, &uaddr);
    80006712:	fd840593          	addi	a1,s0,-40
    80006716:	4501                	li	a0,0
    80006718:	ecefc0ef          	jal	80002de6 <argaddr>
  argint(1, &max);
    8000671c:	fd440593          	addi	a1,s0,-44
    80006720:	4505                	li	a0,1
    80006722:	ea8fc0ef          	jal	80002dca <argint>

  if(max <= 0)
    80006726:	fd442783          	lw	a5,-44(s0)
    return 0;
    8000672a:	4501                	li	a0,0
  if(max <= 0)
    8000672c:	04f05263          	blez	a5,80006770 <sys_memread+0x76>
    80006730:	68913c23          	sd	s1,1688(sp)
  if(max > 16)
    80006734:	4741                	li	a4,16
    80006736:	00f75463          	bge	a4,a5,8000673e <sys_memread+0x44>
    max = 16;
    8000673a:	fce42a23          	sw	a4,-44(s0)

  struct mem_event tmp[16];
  int n = memlog_read_many(tmp, max);
    8000673e:	fd442583          	lw	a1,-44(s0)
    80006742:	95040513          	addi	a0,s0,-1712
    80006746:	ed7ff0ef          	jal	8000661c <memlog_read_many>
    8000674a:	84aa                	mv	s1,a0

  int bytes = n * (int)sizeof(struct mem_event);
  if(copyout(myproc()->pagetable, uaddr, (char *)tmp, bytes) < 0)
    8000674c:	d46fb0ef          	jal	80001c92 <myproc>
    80006750:	06800693          	li	a3,104
    80006754:	029686bb          	mulw	a3,a3,s1
    80006758:	95040613          	addi	a2,s0,-1712
    8000675c:	fd843583          	ld	a1,-40(s0)
    80006760:	6928                	ld	a0,80(a0)
    80006762:	a42fb0ef          	jal	800019a4 <copyout>
    80006766:	00054c63          	bltz	a0,8000677e <sys_memread+0x84>
    return -1;

  return n;
    8000676a:	8526                	mv	a0,s1
    8000676c:	69813483          	ld	s1,1688(sp)
    80006770:	6a813083          	ld	ra,1704(sp)
    80006774:	6a013403          	ld	s0,1696(sp)
    80006778:	6b010113          	addi	sp,sp,1712
    8000677c:	8082                	ret
    return -1;
    8000677e:	557d                	li	a0,-1
    80006780:	69813483          	ld	s1,1688(sp)
    80006784:	b7f5                	j	80006770 <sys_memread+0x76>

0000000080006786 <schedlog_init>:

static struct ringbuf sched_rb;

void
schedlog_init(void)
{
    80006786:	1141                	addi	sp,sp,-16
    80006788:	e406                	sd	ra,8(sp)
    8000678a:	e022                	sd	s0,0(sp)
    8000678c:	0800                	addi	s0,sp,16
  ringbuf_init(&sched_rb, "schedlog", sizeof(struct sched_event));
    8000678e:	04400613          	li	a2,68
    80006792:	00002597          	auipc	a1,0x2
    80006796:	0be58593          	addi	a1,a1,190 # 80008850 <userret+0x17b4>
    8000679a:	0003a517          	auipc	a0,0x3a
    8000679e:	c2e50513          	addi	a0,a0,-978 # 800403c8 <sched_rb>
    800067a2:	a9bff0ef          	jal	8000623c <ringbuf_init>
}
    800067a6:	60a2                	ld	ra,8(sp)
    800067a8:	6402                	ld	s0,0(sp)
    800067aa:	0141                	addi	sp,sp,16
    800067ac:	8082                	ret

00000000800067ae <schedlog_emit>:

void
schedlog_emit(struct sched_event *e)
{
    800067ae:	7159                	addi	sp,sp,-112
    800067b0:	f486                	sd	ra,104(sp)
    800067b2:	f0a2                	sd	s0,96(sp)
    800067b4:	eca6                	sd	s1,88(sp)
    800067b6:	1880                	addi	s0,sp,112
    800067b8:	85aa                	mv	a1,a0
  struct sched_event copy;

  memmove(&copy, e, sizeof(copy));
    800067ba:	f9840493          	addi	s1,s0,-104
    800067be:	04400613          	li	a2,68
    800067c2:	8526                	mv	a0,s1
    800067c4:	e8efa0ef          	jal	80000e52 <memmove>
  copy.seq = sched_rb.seq++;
    800067c8:	0003a717          	auipc	a4,0x3a
    800067cc:	c0070713          	addi	a4,a4,-1024 # 800403c8 <sched_rb>
    800067d0:	771c                	ld	a5,40(a4)
    800067d2:	00178693          	addi	a3,a5,1
    800067d6:	f714                	sd	a3,40(a4)
    800067d8:	f8f42c23          	sw	a5,-104(s0)
  ringbuf_push(&sched_rb, &copy);
    800067dc:	85a6                	mv	a1,s1
    800067de:	853a                	mv	a0,a4
    800067e0:	a91ff0ef          	jal	80006270 <ringbuf_push>
}
    800067e4:	70a6                	ld	ra,104(sp)
    800067e6:	7406                	ld	s0,96(sp)
    800067e8:	64e6                	ld	s1,88(sp)
    800067ea:	6165                	addi	sp,sp,112
    800067ec:	8082                	ret

00000000800067ee <schedread>:

int
schedread(struct sched_event *dst, int max)
{
    800067ee:	1141                	addi	sp,sp,-16
    800067f0:	e406                	sd	ra,8(sp)
    800067f2:	e022                	sd	s0,0(sp)
    800067f4:	0800                	addi	s0,sp,16
    800067f6:	862e                	mv	a2,a1
  return ringbuf_read_many(&sched_rb, dst, max);
    800067f8:	85aa                	mv	a1,a0
    800067fa:	0003a517          	auipc	a0,0x3a
    800067fe:	bce50513          	addi	a0,a0,-1074 # 800403c8 <sched_rb>
    80006802:	adbff0ef          	jal	800062dc <ringbuf_read_many>
    80006806:	60a2                	ld	ra,8(sp)
    80006808:	6402                	ld	s0,0(sp)
    8000680a:	0141                	addi	sp,sp,16
    8000680c:	8082                	ret
	...

0000000080007000 <_trampoline>:
    80007000:	14051073          	csrw	sscratch,a0
    80007004:	02000537          	lui	a0,0x2000
    80007008:	357d                	addiw	a0,a0,-1 # 1ffffff <_entry-0x7e000001>
    8000700a:	0536                	slli	a0,a0,0xd
    8000700c:	02153423          	sd	ra,40(a0)
    80007010:	02253823          	sd	sp,48(a0)
    80007014:	02353c23          	sd	gp,56(a0)
    80007018:	04453023          	sd	tp,64(a0)
    8000701c:	04553423          	sd	t0,72(a0)
    80007020:	04653823          	sd	t1,80(a0)
    80007024:	04753c23          	sd	t2,88(a0)
    80007028:	f120                	sd	s0,96(a0)
    8000702a:	f524                	sd	s1,104(a0)
    8000702c:	fd2c                	sd	a1,120(a0)
    8000702e:	e150                	sd	a2,128(a0)
    80007030:	e554                	sd	a3,136(a0)
    80007032:	e958                	sd	a4,144(a0)
    80007034:	ed5c                	sd	a5,152(a0)
    80007036:	0b053023          	sd	a6,160(a0)
    8000703a:	0b153423          	sd	a7,168(a0)
    8000703e:	0b253823          	sd	s2,176(a0)
    80007042:	0b353c23          	sd	s3,184(a0)
    80007046:	0d453023          	sd	s4,192(a0)
    8000704a:	0d553423          	sd	s5,200(a0)
    8000704e:	0d653823          	sd	s6,208(a0)
    80007052:	0d753c23          	sd	s7,216(a0)
    80007056:	0f853023          	sd	s8,224(a0)
    8000705a:	0f953423          	sd	s9,232(a0)
    8000705e:	0fa53823          	sd	s10,240(a0)
    80007062:	0fb53c23          	sd	s11,248(a0)
    80007066:	11c53023          	sd	t3,256(a0)
    8000706a:	11d53423          	sd	t4,264(a0)
    8000706e:	11e53823          	sd	t5,272(a0)
    80007072:	11f53c23          	sd	t6,280(a0)
    80007076:	140022f3          	csrr	t0,sscratch
    8000707a:	06553823          	sd	t0,112(a0)
    8000707e:	00853103          	ld	sp,8(a0)
    80007082:	02053203          	ld	tp,32(a0)
    80007086:	01053283          	ld	t0,16(a0)
    8000708a:	00053303          	ld	t1,0(a0)
    8000708e:	12000073          	sfence.vma
    80007092:	18031073          	csrw	satp,t1
    80007096:	12000073          	sfence.vma
    8000709a:	9282                	jalr	t0

000000008000709c <userret>:
    8000709c:	12000073          	sfence.vma
    800070a0:	18051073          	csrw	satp,a0
    800070a4:	12000073          	sfence.vma
    800070a8:	02000537          	lui	a0,0x2000
    800070ac:	357d                	addiw	a0,a0,-1 # 1ffffff <_entry-0x7e000001>
    800070ae:	0536                	slli	a0,a0,0xd
    800070b0:	02853083          	ld	ra,40(a0)
    800070b4:	03053103          	ld	sp,48(a0)
    800070b8:	03853183          	ld	gp,56(a0)
    800070bc:	04053203          	ld	tp,64(a0)
    800070c0:	04853283          	ld	t0,72(a0)
    800070c4:	05053303          	ld	t1,80(a0)
    800070c8:	05853383          	ld	t2,88(a0)
    800070cc:	7120                	ld	s0,96(a0)
    800070ce:	7524                	ld	s1,104(a0)
    800070d0:	7d2c                	ld	a1,120(a0)
    800070d2:	6150                	ld	a2,128(a0)
    800070d4:	6554                	ld	a3,136(a0)
    800070d6:	6958                	ld	a4,144(a0)
    800070d8:	6d5c                	ld	a5,152(a0)
    800070da:	0a053803          	ld	a6,160(a0)
    800070de:	0a853883          	ld	a7,168(a0)
    800070e2:	0b053903          	ld	s2,176(a0)
    800070e6:	0b853983          	ld	s3,184(a0)
    800070ea:	0c053a03          	ld	s4,192(a0)
    800070ee:	0c853a83          	ld	s5,200(a0)
    800070f2:	0d053b03          	ld	s6,208(a0)
    800070f6:	0d853b83          	ld	s7,216(a0)
    800070fa:	0e053c03          	ld	s8,224(a0)
    800070fe:	0e853c83          	ld	s9,232(a0)
    80007102:	0f053d03          	ld	s10,240(a0)
    80007106:	0f853d83          	ld	s11,248(a0)
    8000710a:	10053e03          	ld	t3,256(a0)
    8000710e:	10853e83          	ld	t4,264(a0)
    80007112:	11053f03          	ld	t5,272(a0)
    80007116:	11853f83          	ld	t6,280(a0)
    8000711a:	7928                	ld	a0,112(a0)
    8000711c:	10200073          	sret
	...
