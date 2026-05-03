
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
    800000f2:	3c2040ef          	jal	800044b4 <acquiresleep>

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
    80000126:	6ea020ef          	jal	80002810 <either_copyin>
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
    80000172:	388040ef          	jal	800044fa <releasesleep>
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
    800001da:	267010ef          	jal	80001c40 <myproc>
    800001de:	4ca020ef          	jal	800026a8 <killed>
    800001e2:	e12d                	bnez	a0,80000244 <consoleread+0xbc>
      sleep(&cons.r, &cons.lock);
    800001e4:	85ce                	mv	a1,s3
    800001e6:	854a                	mv	a0,s2
    800001e8:	284020ef          	jal	8000246c <sleep>
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
    8000022c:	59a020ef          	jal	800027c6 <either_copyout>
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
    800002f8:	562020ef          	jal	8000285a <procdump>
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
    80000438:	080020ef          	jal	800024b8 <wakeup>
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
    8000044a:	bba58593          	addi	a1,a1,-1094 # 80008000 <etext>
    8000044e:	00012517          	auipc	a0,0x12
    80000452:	be250513          	addi	a0,a0,-1054 # 80012030 <cons>
    80000456:	043000ef          	jal	80000c98 <initlock>
  initsleeplock(&conswlock, "consw");
    8000045a:	00008597          	auipc	a1,0x8
    8000045e:	bb658593          	addi	a1,a1,-1098 # 80008010 <etext+0x10>
    80000462:	00012517          	auipc	a0,0x12
    80000466:	b9e50513          	addi	a0,a0,-1122 # 80012000 <conswlock>
    8000046a:	014040ef          	jal	8000447e <initsleeplock>

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
    800004b4:	2d880813          	addi	a6,a6,728 # 80008788 <digits>
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
    80000708:	084c8c93          	addi	s9,s9,132 # 80008788 <digits>
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
    80000768:	8b4a0a13          	addi	s4,s4,-1868 # 80008018 <etext+0x18>
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
    80000872:	7b250513          	addi	a0,a0,1970 # 80008020 <etext+0x20>
    80000876:	cb7ff0ef          	jal	8000052c <printf>
  printf("%s\n", s);
    8000087a:	85ca                	mv	a1,s2
    8000087c:	00007517          	auipc	a0,0x7
    80000880:	7ac50513          	addi	a0,a0,1964 # 80008028 <etext+0x28>
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
    8000089e:	79658593          	addi	a1,a1,1942 # 80008030 <etext+0x30>
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
    800008f4:	74858593          	addi	a1,a1,1864 # 80008038 <etext+0x38>
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
    8000095e:	30f010ef          	jal	8000246c <sleep>
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
    80000a7e:	23b010ef          	jal	800024b8 <wakeup>
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
    80000afc:	110010ef          	jal	80001c0c <cpuid>
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
    80000b1e:	122010ef          	jal	80001c40 <myproc>
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
    80000b42:	1bb050ef          	jal	800064fc <memlog_push>
}
    80000b46:	60aa                	ld	ra,136(sp)
    80000b48:	640a                	ld	s0,128(sp)
    80000b4a:	74e6                	ld	s1,120(sp)
    80000b4c:	7946                	ld	s2,112(sp)
    80000b4e:	6149                	addi	sp,sp,144
    80000b50:	8082                	ret
    panic("kfree");
    80000b52:	00007517          	auipc	a0,0x7
    80000b56:	4ee50513          	addi	a0,a0,1262 # 80008040 <etext+0x40>
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
    80000bb2:	49a58593          	addi	a1,a1,1178 # 80008048 <etext+0x48>
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
    80000c34:	7d9000ef          	jal	80001c0c <cpuid>
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
    80000c56:	7eb000ef          	jal	80001c40 <myproc>
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
    80000c7a:	083050ef          	jal	800064fc <memlog_push>
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
    80000cc8:	759000ef          	jal	80001c20 <mycpu>
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
    80000cf8:	729000ef          	jal	80001c20 <mycpu>
    80000cfc:	5d3c                	lw	a5,120(a0)
    80000cfe:	cb99                	beqz	a5,80000d14 <push_off+0x36>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000d00:	721000ef          	jal	80001c20 <mycpu>
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
    80000d14:	70d000ef          	jal	80001c20 <mycpu>
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
    80000d4a:	6d7000ef          	jal	80001c20 <mycpu>
    80000d4e:	e888                	sd	a0,16(s1)
}
    80000d50:	60e2                	ld	ra,24(sp)
    80000d52:	6442                	ld	s0,16(sp)
    80000d54:	64a2                	ld	s1,8(sp)
    80000d56:	6105                	addi	sp,sp,32
    80000d58:	8082                	ret
    panic("acquire");
    80000d5a:	00007517          	auipc	a0,0x7
    80000d5e:	2f650513          	addi	a0,a0,758 # 80008050 <etext+0x50>
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
    80000d6e:	6b3000ef          	jal	80001c20 <mycpu>
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
    80000da2:	2ba50513          	addi	a0,a0,698 # 80008058 <etext+0x58>
    80000da6:	ab1ff0ef          	jal	80000856 <panic>
    panic("pop_off");
    80000daa:	00007517          	auipc	a0,0x7
    80000dae:	2c650513          	addi	a0,a0,710 # 80008070 <etext+0x70>
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
    80000dea:	29250513          	addi	a0,a0,658 # 80008078 <etext+0x78>
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
    80000fb0:	45d000ef          	jal	80001c0c <cpuid>
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
    80000fc8:	445000ef          	jal	80001c0c <cpuid>
    80000fcc:	85aa                	mv	a1,a0
    80000fce:	00007517          	auipc	a0,0x7
    80000fd2:	0d250513          	addi	a0,a0,210 # 800080a0 <etext+0xa0>
    80000fd6:	d56ff0ef          	jal	8000052c <printf>
    kvminithart();    // turn on paging
    80000fda:	08c000ef          	jal	80001066 <kvminithart>
    trapinithart();   // install kernel trap vector
    80000fde:	1af010ef          	jal	8000298c <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000fe2:	2d7040ef          	jal	80005ab8 <plicinithart>
  }

  scheduler();        
    80000fe6:	13c010ef          	jal	80002122 <scheduler>
    consoleinit();
    80000fea:	c54ff0ef          	jal	8000043e <consoleinit>
    printfinit();
    80000fee:	8a5ff0ef          	jal	80000892 <printfinit>
    printf("\n");
    80000ff2:	00007517          	auipc	a0,0x7
    80000ff6:	08e50513          	addi	a0,a0,142 # 80008080 <etext+0x80>
    80000ffa:	d32ff0ef          	jal	8000052c <printf>
    printf("xv6 kernel is booting\n");
    80000ffe:	00007517          	auipc	a0,0x7
    80001002:	08a50513          	addi	a0,a0,138 # 80008088 <etext+0x88>
    80001006:	d26ff0ef          	jal	8000052c <printf>
    printf("\n");
    8000100a:	00007517          	auipc	a0,0x7
    8000100e:	07650513          	addi	a0,a0,118 # 80008080 <etext+0x80>
    80001012:	d1aff0ef          	jal	8000052c <printf>
    kinit();         // physical page allocator
    80001016:	b91ff0ef          	jal	80000ba6 <kinit>
    kvminit();       // create kernel page table
    8000101a:	364000ef          	jal	8000137e <kvminit>
    kvminithart();   // turn on paging
    8000101e:	048000ef          	jal	80001066 <kvminithart>
    procinit();      // process table
    80001022:	321000ef          	jal	80001b42 <procinit>
    schedlog_init();
    80001026:	710050ef          	jal	80006736 <schedlog_init>
    trapinit();      // trap vectors
    8000102a:	13f010ef          	jal	80002968 <trapinit>
    trapinithart();  // install kernel trap vector
    8000102e:	15f010ef          	jal	8000298c <trapinithart>
    plicinit();      // set up interrupt controller
    80001032:	26d040ef          	jal	80005a9e <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80001036:	283040ef          	jal	80005ab8 <plicinithart>
    binit();         // buffer cache
    8000103a:	07e020ef          	jal	800030b8 <binit>
    iinit();         // inode table
    8000103e:	60e020ef          	jal	8000364c <iinit>
    fileinit();      // file table
    80001042:	53a030ef          	jal	8000457c <fileinit>
    virtio_disk_init(); // emulated hard disk
    80001046:	363040ef          	jal	80005ba8 <virtio_disk_init>
    cslog_init();
    8000104a:	7e5040ef          	jal	8000602e <cslog_init>
    memlog_init();
    8000104e:	46a050ef          	jal	800064b8 <memlog_init>
    userinit();      // first user process
    80001052:	6b9000ef          	jal	80001f0a <userinit>
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
    80001066:	1141                	addi	sp,sp,-16
    80001068:	e406                	sd	ra,8(sp)
    8000106a:	e022                	sd	s0,0(sp)
    8000106c:	0800                	addi	s0,sp,16
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero");
    8000106e:	12000073          	sfence.vma
  // wait for any previous writes to the page table memory to finish.
  sfence_vma();

  w_satp(MAKE_SATP(V2P(kernel_pagetable)));
    80001072:	00008797          	auipc	a5,0x8
    80001076:	fa67b783          	ld	a5,-90(a5) # 80009018 <kernel_pagetable>
    8000107a:	80000737          	lui	a4,0x80000
    8000107e:	97ba                	add	a5,a5,a4
    80001080:	83b1                	srli	a5,a5,0xc
    80001082:	577d                	li	a4,-1
    80001084:	177e                	slli	a4,a4,0x3f
    80001086:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r" (x));
    80001088:	18079073          	csrw	satp,a5
  asm volatile("sfence.vma zero, zero");
    8000108c:	12000073          	sfence.vma

  // flush stale entries from the TLB.
  sfence_vma();
}
    80001090:	60a2                	ld	ra,8(sp)
    80001092:	6402                	ld	s0,0(sp)
    80001094:	0141                	addi	sp,sp,16
    80001096:	8082                	ret

0000000080001098 <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    80001098:	7139                	addi	sp,sp,-64
    8000109a:	fc06                	sd	ra,56(sp)
    8000109c:	f822                	sd	s0,48(sp)
    8000109e:	f426                	sd	s1,40(sp)
    800010a0:	f04a                	sd	s2,32(sp)
    800010a2:	ec4e                	sd	s3,24(sp)
    800010a4:	e852                	sd	s4,16(sp)
    800010a6:	e456                	sd	s5,8(sp)
    800010a8:	e05a                	sd	s6,0(sp)
    800010aa:	0080                	addi	s0,sp,64
    800010ac:	84aa                	mv	s1,a0
    800010ae:	89ae                	mv	s3,a1
    800010b0:	8b32                	mv	s6,a2
  if(va >= MAXVA)
    800010b2:	57fd                	li	a5,-1
    800010b4:	83e9                	srli	a5,a5,0x1a
    800010b6:	4a79                	li	s4,30
    panic("walk");

  for(int level = 2; level > 0; level--) {
    800010b8:	4ab1                	li	s5,12
  if(va >= MAXVA)
    800010ba:	04b7e263          	bltu	a5,a1,800010fe <walk+0x66>
    pte_t *pte = &pagetable[PX(level, va)];
    800010be:	0149d933          	srl	s2,s3,s4
    800010c2:	1ff97913          	andi	s2,s2,511
    800010c6:	090e                	slli	s2,s2,0x3
    800010c8:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) {
    800010ca:	00093483          	ld	s1,0(s2)
    800010ce:	0014f793          	andi	a5,s1,1
    800010d2:	cf85                	beqz	a5,8000110a <walk+0x72>
      pagetable = (pagetable_t)PTE2PA(*pte);
    800010d4:	80a9                	srli	s1,s1,0xa
    800010d6:	04b2                	slli	s1,s1,0xc
  for(int level = 2; level > 0; level--) {
    800010d8:	3a5d                	addiw	s4,s4,-9
    800010da:	ff5a12e3          	bne	s4,s5,800010be <walk+0x26>
        return 0;
      memset(pagetable, 0, PGSIZE);
      *pte = PA2PTE(pagetable) | PTE_V;
    }
  }
  return &pagetable[PX(0, va)];
    800010de:	00c9d513          	srli	a0,s3,0xc
    800010e2:	1ff57513          	andi	a0,a0,511
    800010e6:	050e                	slli	a0,a0,0x3
    800010e8:	9526                	add	a0,a0,s1
}
    800010ea:	70e2                	ld	ra,56(sp)
    800010ec:	7442                	ld	s0,48(sp)
    800010ee:	74a2                	ld	s1,40(sp)
    800010f0:	7902                	ld	s2,32(sp)
    800010f2:	69e2                	ld	s3,24(sp)
    800010f4:	6a42                	ld	s4,16(sp)
    800010f6:	6aa2                	ld	s5,8(sp)
    800010f8:	6b02                	ld	s6,0(sp)
    800010fa:	6121                	addi	sp,sp,64
    800010fc:	8082                	ret
    panic("walk");
    800010fe:	00007517          	auipc	a0,0x7
    80001102:	fba50513          	addi	a0,a0,-70 # 800080b8 <etext+0xb8>
    80001106:	f50ff0ef          	jal	80000856 <panic>
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    8000110a:	020b0263          	beqz	s6,8000112e <walk+0x96>
    8000110e:	acdff0ef          	jal	80000bda <kalloc>
    80001112:	84aa                	mv	s1,a0
    80001114:	d979                	beqz	a0,800010ea <walk+0x52>
      memset(pagetable, 0, PGSIZE);
    80001116:	6605                	lui	a2,0x1
    80001118:	4581                	li	a1,0
    8000111a:	cd9ff0ef          	jal	80000df2 <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    8000111e:	00c4d793          	srli	a5,s1,0xc
    80001122:	07aa                	slli	a5,a5,0xa
    80001124:	0017e793          	ori	a5,a5,1
    80001128:	00f93023          	sd	a5,0(s2)
    8000112c:	b775                	j	800010d8 <walk+0x40>
        return 0;
    8000112e:	4501                	li	a0,0
    80001130:	bf6d                	j	800010ea <walk+0x52>

0000000080001132 <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if(va >= MAXVA)
    80001132:	57fd                	li	a5,-1
    80001134:	83e9                	srli	a5,a5,0x1a
    80001136:	00b7f463          	bgeu	a5,a1,8000113e <walkaddr+0xc>
    return 0;
    8000113a:	4501                	li	a0,0
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}
    8000113c:	8082                	ret
{
    8000113e:	1141                	addi	sp,sp,-16
    80001140:	e406                	sd	ra,8(sp)
    80001142:	e022                	sd	s0,0(sp)
    80001144:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    80001146:	4601                	li	a2,0
    80001148:	f51ff0ef          	jal	80001098 <walk>
  if(pte == 0)
    8000114c:	c901                	beqz	a0,8000115c <walkaddr+0x2a>
  if((*pte & PTE_V) == 0)
    8000114e:	611c                	ld	a5,0(a0)
  if((*pte & PTE_U) == 0)
    80001150:	0117f693          	andi	a3,a5,17
    80001154:	4745                	li	a4,17
    return 0;
    80001156:	4501                	li	a0,0
  if((*pte & PTE_U) == 0)
    80001158:	00e68663          	beq	a3,a4,80001164 <walkaddr+0x32>
}
    8000115c:	60a2                	ld	ra,8(sp)
    8000115e:	6402                	ld	s0,0(sp)
    80001160:	0141                	addi	sp,sp,16
    80001162:	8082                	ret
  pa = PTE2PA(*pte);
    80001164:	83a9                	srli	a5,a5,0xa
    80001166:	00c79513          	slli	a0,a5,0xc
  return pa;
    8000116a:	bfcd                	j	8000115c <walkaddr+0x2a>

000000008000116c <mappages>:
// va and size MUST be page-aligned.
// Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    8000116c:	7115                	addi	sp,sp,-224
    8000116e:	ed86                	sd	ra,216(sp)
    80001170:	e9a2                	sd	s0,208(sp)
    80001172:	e5a6                	sd	s1,200(sp)
    80001174:	e1ca                	sd	s2,192(sp)
    80001176:	fd4e                	sd	s3,184(sp)
    80001178:	f952                	sd	s4,176(sp)
    8000117a:	f556                	sd	s5,168(sp)
    8000117c:	f15a                	sd	s6,160(sp)
    8000117e:	ed5e                	sd	s7,152(sp)
    80001180:	e962                	sd	s8,144(sp)
    80001182:	e566                	sd	s9,136(sp)
    80001184:	e16a                	sd	s10,128(sp)
    80001186:	fcee                	sd	s11,120(sp)
    80001188:	1180                	addi	s0,sp,224
  uint64 a, last;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    8000118a:	03459793          	slli	a5,a1,0x34
    8000118e:	eb8d                	bnez	a5,800011c0 <mappages+0x54>
    80001190:	8c2a                	mv	s8,a0
    80001192:	8aba                	mv	s5,a4
    panic("mappages: va not aligned");

  if((size % PGSIZE) != 0)
    80001194:	03461793          	slli	a5,a2,0x34
    80001198:	eb95                	bnez	a5,800011cc <mappages+0x60>
    panic("mappages: size not aligned");

  if(size == 0)
    8000119a:	ce1d                	beqz	a2,800011d8 <mappages+0x6c>
    panic("mappages: size");
  
  a = va;
  last = va + size - PGSIZE;
    8000119c:	80060613          	addi	a2,a2,-2048 # 800 <_entry-0x7ffff800>
    800011a0:	80060613          	addi	a2,a2,-2048
    800011a4:	00b60a33          	add	s4,a2,a1
  a = va;
    800011a8:	892e                	mv	s2,a1
  for(;;){
       if((pte = walk(pagetable, a, 1)) == 0)
    800011aa:	4b05                	li	s6,1
    800011ac:	40b68bb3          	sub	s7,a3,a1
    *pte = PA2PTE(pa) | perm | PTE_V;

    struct proc *p = myproc();
    if(p){
      struct mem_event e;
      memset(&e, 0, sizeof(e));
    800011b0:	f2840c93          	addi	s9,s0,-216
      e.ticks  = ticks;
    800011b4:	00008d97          	auipc	s11,0x8
    800011b8:	e7cd8d93          	addi	s11,s11,-388 # 80009030 <ticks>
      e.cpu    = cpuid();
      e.type   = MEM_MAP;
    800011bc:	4d11                	li	s10,4
    800011be:	a82d                	j	800011f8 <mappages+0x8c>
    panic("mappages: va not aligned");
    800011c0:	00007517          	auipc	a0,0x7
    800011c4:	f0050513          	addi	a0,a0,-256 # 800080c0 <etext+0xc0>
    800011c8:	e8eff0ef          	jal	80000856 <panic>
    panic("mappages: size not aligned");
    800011cc:	00007517          	auipc	a0,0x7
    800011d0:	f1450513          	addi	a0,a0,-236 # 800080e0 <etext+0xe0>
    800011d4:	e82ff0ef          	jal	80000856 <panic>
    panic("mappages: size");
    800011d8:	00007517          	auipc	a0,0x7
    800011dc:	f2850513          	addi	a0,a0,-216 # 80008100 <etext+0x100>
    800011e0:	e76ff0ef          	jal	80000856 <panic>
      panic("mappages: remap");
    800011e4:	00007517          	auipc	a0,0x7
    800011e8:	f2c50513          	addi	a0,a0,-212 # 80008110 <etext+0x110>
    800011ec:	e6aff0ef          	jal	80000856 <panic>
      e.kind   = PAGE_USER;
      safestrcpy(e.name, p->name, MEM_NM);
      memlog_push(&e);
    }

    if(a == last)
    800011f0:	0b490763          	beq	s2,s4,8000129e <mappages+0x132>
      break;
    a += PGSIZE;
    800011f4:	6785                	lui	a5,0x1
    800011f6:	993e                	add	s2,s2,a5
       if((pte = walk(pagetable, a, 1)) == 0)
    800011f8:	865a                	mv	a2,s6
    800011fa:	85ca                	mv	a1,s2
    800011fc:	8562                	mv	a0,s8
    800011fe:	e9bff0ef          	jal	80001098 <walk>
    80001202:	cd35                	beqz	a0,8000127e <mappages+0x112>
    if(*pte & PTE_V)
    80001204:	611c                	ld	a5,0(a0)
    80001206:	8b85                	andi	a5,a5,1
    80001208:	fff1                	bnez	a5,800011e4 <mappages+0x78>
    8000120a:	017909b3          	add	s3,s2,s7
    *pte = PA2PTE(pa) | perm | PTE_V;
    8000120e:	00c9d793          	srli	a5,s3,0xc
    80001212:	07aa                	slli	a5,a5,0xa
    80001214:	0157e7b3          	or	a5,a5,s5
    80001218:	0017e793          	ori	a5,a5,1
    8000121c:	e11c                	sd	a5,0(a0)
    struct proc *p = myproc();
    8000121e:	223000ef          	jal	80001c40 <myproc>
    80001222:	84aa                	mv	s1,a0
    if(p){
    80001224:	d571                	beqz	a0,800011f0 <mappages+0x84>
      memset(&e, 0, sizeof(e));
    80001226:	06800613          	li	a2,104
    8000122a:	4581                	li	a1,0
    8000122c:	8566                	mv	a0,s9
    8000122e:	bc5ff0ef          	jal	80000df2 <memset>
      e.ticks  = ticks;
    80001232:	000da783          	lw	a5,0(s11)
    80001236:	f2f42823          	sw	a5,-208(s0)
      e.cpu    = cpuid();
    8000123a:	1d3000ef          	jal	80001c0c <cpuid>
    8000123e:	f2a42a23          	sw	a0,-204(s0)
      e.type   = MEM_MAP;
    80001242:	f3a42c23          	sw	s10,-200(s0)
      e.pid    = p->pid;
    80001246:	589c                	lw	a5,48(s1)
    80001248:	f2f42e23          	sw	a5,-196(s0)
      e.state  = p->state;
    8000124c:	4c9c                	lw	a5,24(s1)
    8000124e:	f4f42023          	sw	a5,-192(s0)
      e.va     = a;
    80001252:	f5243c23          	sd	s2,-168(s0)
      e.pa     = pa;
    80001256:	f7343023          	sd	s3,-160(s0)
      e.perm   = perm;
    8000125a:	f9542023          	sw	s5,-128(s0)
      e.source = SRC_MAPPAGES;
    8000125e:	478d                	li	a5,3
    80001260:	f8f42223          	sw	a5,-124(s0)
      e.kind   = PAGE_USER;
    80001264:	f9642423          	sw	s6,-120(s0)
      safestrcpy(e.name, p->name, MEM_NM);
    80001268:	4641                	li	a2,16
    8000126a:	15848593          	addi	a1,s1,344
    8000126e:	f4440513          	addi	a0,s0,-188
    80001272:	cd5ff0ef          	jal	80000f46 <safestrcpy>
      memlog_push(&e);
    80001276:	8566                	mv	a0,s9
    80001278:	284050ef          	jal	800064fc <memlog_push>
    8000127c:	bf95                	j	800011f0 <mappages+0x84>
      return -1;
    8000127e:	557d                	li	a0,-1
    pa += PGSIZE;
  }
  return 0;
}
    80001280:	60ee                	ld	ra,216(sp)
    80001282:	644e                	ld	s0,208(sp)
    80001284:	64ae                	ld	s1,200(sp)
    80001286:	690e                	ld	s2,192(sp)
    80001288:	79ea                	ld	s3,184(sp)
    8000128a:	7a4a                	ld	s4,176(sp)
    8000128c:	7aaa                	ld	s5,168(sp)
    8000128e:	7b0a                	ld	s6,160(sp)
    80001290:	6bea                	ld	s7,152(sp)
    80001292:	6c4a                	ld	s8,144(sp)
    80001294:	6caa                	ld	s9,136(sp)
    80001296:	6d0a                	ld	s10,128(sp)
    80001298:	7de6                	ld	s11,120(sp)
    8000129a:	612d                	addi	sp,sp,224
    8000129c:	8082                	ret
  return 0;
    8000129e:	4501                	li	a0,0
    800012a0:	b7c5                	j	80001280 <mappages+0x114>

00000000800012a2 <kvmmap>:
{
    800012a2:	1141                	addi	sp,sp,-16
    800012a4:	e406                	sd	ra,8(sp)
    800012a6:	e022                	sd	s0,0(sp)
    800012a8:	0800                	addi	s0,sp,16
    800012aa:	87b6                	mv	a5,a3
  if(mappages(kpgtbl, va, sz, pa, perm) != 0)
    800012ac:	86b2                	mv	a3,a2
    800012ae:	863e                	mv	a2,a5
    800012b0:	ebdff0ef          	jal	8000116c <mappages>
    800012b4:	e509                	bnez	a0,800012be <kvmmap+0x1c>
}
    800012b6:	60a2                	ld	ra,8(sp)
    800012b8:	6402                	ld	s0,0(sp)
    800012ba:	0141                	addi	sp,sp,16
    800012bc:	8082                	ret
    panic("kvmmap");
    800012be:	00007517          	auipc	a0,0x7
    800012c2:	e6250513          	addi	a0,a0,-414 # 80008120 <etext+0x120>
    800012c6:	d90ff0ef          	jal	80000856 <panic>

00000000800012ca <kvmmake>:
{
    800012ca:	1101                	addi	sp,sp,-32
    800012cc:	ec06                	sd	ra,24(sp)
    800012ce:	e822                	sd	s0,16(sp)
    800012d0:	e426                	sd	s1,8(sp)
    800012d2:	1000                	addi	s0,sp,32
  kpgtbl = (pagetable_t) kalloc();
    800012d4:	907ff0ef          	jal	80000bda <kalloc>
    800012d8:	84aa                	mv	s1,a0
  memset(kpgtbl, 0, PGSIZE);
    800012da:	6605                	lui	a2,0x1
    800012dc:	4581                	li	a1,0
    800012de:	b15ff0ef          	jal	80000df2 <memset>
  kvmmap(kpgtbl, UART0, UART0, PGSIZE, PTE_R | PTE_W);
    800012e2:	4719                	li	a4,6
    800012e4:	6685                	lui	a3,0x1
    800012e6:	10000637          	lui	a2,0x10000
    800012ea:	85b2                	mv	a1,a2
    800012ec:	8526                	mv	a0,s1
    800012ee:	fb5ff0ef          	jal	800012a2 <kvmmap>
  kvmmap(kpgtbl, VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    800012f2:	4719                	li	a4,6
    800012f4:	6685                	lui	a3,0x1
    800012f6:	10001637          	lui	a2,0x10001
    800012fa:	85b2                	mv	a1,a2
    800012fc:	8526                	mv	a0,s1
    800012fe:	fa5ff0ef          	jal	800012a2 <kvmmap>
  kvmmap(kpgtbl, PLIC, PLIC, 0x4000000, PTE_R | PTE_W);
    80001302:	4719                	li	a4,6
    80001304:	040006b7          	lui	a3,0x4000
    80001308:	0c000637          	lui	a2,0xc000
    8000130c:	85b2                	mv	a1,a2
    8000130e:	8526                	mv	a0,s1
    80001310:	f93ff0ef          	jal	800012a2 <kvmmap>
  kvmmap(kpgtbl, KERNBASE, V2P(KERNBASE), (uint64)etext-KERNBASE, PTE_R | PTE_X);
    80001314:	4729                	li	a4,10
    80001316:	80007697          	auipc	a3,0x80007
    8000131a:	cea68693          	addi	a3,a3,-790 # 8000 <_entry-0x7fff8000>
    8000131e:	4601                	li	a2,0
    80001320:	4585                	li	a1,1
    80001322:	05fe                	slli	a1,a1,0x1f
    80001324:	8526                	mv	a0,s1
    80001326:	f7dff0ef          	jal	800012a2 <kvmmap>
  kvmmap(kpgtbl, (uint64)etext, V2P(etext), PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    8000132a:	4719                	li	a4,6
    8000132c:	00007697          	auipc	a3,0x7
    80001330:	cd468693          	addi	a3,a3,-812 # 80008000 <etext>
    80001334:	47c5                	li	a5,17
    80001336:	07ee                	slli	a5,a5,0x1b
    80001338:	40d786b3          	sub	a3,a5,a3
    8000133c:	80007617          	auipc	a2,0x80007
    80001340:	cc460613          	addi	a2,a2,-828 # 8000 <_entry-0x7fff8000>
    80001344:	00007597          	auipc	a1,0x7
    80001348:	cbc58593          	addi	a1,a1,-836 # 80008000 <etext>
    8000134c:	8526                	mv	a0,s1
    8000134e:	f55ff0ef          	jal	800012a2 <kvmmap>
  kvmmap(kpgtbl, TRAMPOLINE, V2P(trampoline), PGSIZE, PTE_R | PTE_X);
    80001352:	4729                	li	a4,10
    80001354:	6685                	lui	a3,0x1
    80001356:	80006617          	auipc	a2,0x80006
    8000135a:	caa60613          	addi	a2,a2,-854 # 7000 <_entry-0x7fff9000>
    8000135e:	040005b7          	lui	a1,0x4000
    80001362:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001364:	05b2                	slli	a1,a1,0xc
    80001366:	8526                	mv	a0,s1
    80001368:	f3bff0ef          	jal	800012a2 <kvmmap>
  proc_mapstacks(kpgtbl);
    8000136c:	8526                	mv	a0,s1
    8000136e:	730000ef          	jal	80001a9e <proc_mapstacks>
}
    80001372:	8526                	mv	a0,s1
    80001374:	60e2                	ld	ra,24(sp)
    80001376:	6442                	ld	s0,16(sp)
    80001378:	64a2                	ld	s1,8(sp)
    8000137a:	6105                	addi	sp,sp,32
    8000137c:	8082                	ret

000000008000137e <kvminit>:
{
    8000137e:	1141                	addi	sp,sp,-16
    80001380:	e406                	sd	ra,8(sp)
    80001382:	e022                	sd	s0,0(sp)
    80001384:	0800                	addi	s0,sp,16
  kernel_pagetable = kvmmake();
    80001386:	f45ff0ef          	jal	800012ca <kvmmake>
    8000138a:	00008797          	auipc	a5,0x8
    8000138e:	c8a7b723          	sd	a0,-882(a5) # 80009018 <kernel_pagetable>
}
    80001392:	60a2                	ld	ra,8(sp)
    80001394:	6402                	ld	s0,0(sp)
    80001396:	0141                	addi	sp,sp,16
    80001398:	8082                	ret

000000008000139a <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    8000139a:	1101                	addi	sp,sp,-32
    8000139c:	ec06                	sd	ra,24(sp)
    8000139e:	e822                	sd	s0,16(sp)
    800013a0:	e426                	sd	s1,8(sp)
    800013a2:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t) kalloc();
    800013a4:	837ff0ef          	jal	80000bda <kalloc>
    800013a8:	84aa                	mv	s1,a0
  if(pagetable == 0)
    800013aa:	c509                	beqz	a0,800013b4 <uvmcreate+0x1a>
    return 0;
  memset(pagetable, 0, PGSIZE);
    800013ac:	6605                	lui	a2,0x1
    800013ae:	4581                	li	a1,0
    800013b0:	a43ff0ef          	jal	80000df2 <memset>
  return pagetable;
}
    800013b4:	8526                	mv	a0,s1
    800013b6:	60e2                	ld	ra,24(sp)
    800013b8:	6442                	ld	s0,16(sp)
    800013ba:	64a2                	ld	s1,8(sp)
    800013bc:	6105                	addi	sp,sp,32
    800013be:	8082                	ret

00000000800013c0 <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. It's OK if the mappings don't exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    800013c0:	7115                	addi	sp,sp,-224
    800013c2:	ed86                	sd	ra,216(sp)
    800013c4:	e9a2                	sd	s0,208(sp)
    800013c6:	1180                	addi	s0,sp,224
  uint64 a;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    800013c8:	03459793          	slli	a5,a1,0x34
    800013cc:	ef8d                	bnez	a5,80001406 <uvmunmap+0x46>
    800013ce:	e1ca                	sd	s2,192(sp)
    800013d0:	f556                	sd	s5,168(sp)
    800013d2:	f15a                	sd	s6,160(sp)
    800013d4:	e962                	sd	s8,144(sp)
    800013d6:	8b2a                	mv	s6,a0
    800013d8:	892e                	mv	s2,a1
    800013da:	8c36                	mv	s8,a3
    panic("uvmunmap: not aligned");

  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800013dc:	0632                	slli	a2,a2,0xc
    800013de:	00b60ab3          	add	s5,a2,a1
    800013e2:	0f55f763          	bgeu	a1,s5,800014d0 <uvmunmap+0x110>
    800013e6:	e5a6                	sd	s1,200(sp)
    800013e8:	fd4e                	sd	s3,184(sp)
    800013ea:	f952                	sd	s4,176(sp)
    800013ec:	ed5e                	sd	s7,152(sp)
    800013ee:	e566                	sd	s9,136(sp)
    800013f0:	e16a                	sd	s10,128(sp)
    800013f2:	fcee                	sd	s11,120(sp)
    uint64 pa = PTE2PA(*pte);

    struct proc *p = myproc();
    if(p){
      struct mem_event e;
      memset(&e, 0, sizeof(e));
    800013f4:	f2840c93          	addi	s9,s0,-216
      e.ticks  = ticks;
    800013f8:	00008d97          	auipc	s11,0x8
    800013fc:	c38d8d93          	addi	s11,s11,-968 # 80009030 <ticks>
      e.cpu    = cpuid();
      e.type   = MEM_UNMAP;
    80001400:	4d15                	li	s10,5
      e.pid    = p->pid;
      e.state  = p->state;
      e.va     = a;
      e.pa     = pa;
      e.len    = PGSIZE;
    80001402:	6b85                	lui	s7,0x1
    80001404:	a80d                	j	80001436 <uvmunmap+0x76>
    80001406:	e5a6                	sd	s1,200(sp)
    80001408:	e1ca                	sd	s2,192(sp)
    8000140a:	fd4e                	sd	s3,184(sp)
    8000140c:	f952                	sd	s4,176(sp)
    8000140e:	f556                	sd	s5,168(sp)
    80001410:	f15a                	sd	s6,160(sp)
    80001412:	ed5e                	sd	s7,152(sp)
    80001414:	e962                	sd	s8,144(sp)
    80001416:	e566                	sd	s9,136(sp)
    80001418:	e16a                	sd	s10,128(sp)
    8000141a:	fcee                	sd	s11,120(sp)
    panic("uvmunmap: not aligned");
    8000141c:	00007517          	auipc	a0,0x7
    80001420:	d0c50513          	addi	a0,a0,-756 # 80008128 <etext+0x128>
    80001424:	c32ff0ef          	jal	80000856 <panic>
      e.kind   = PAGE_USER;
      safestrcpy(e.name, p->name, MEM_NM);
      memlog_push(&e);
    }

    if(do_free){
    80001428:	080c1963          	bnez	s8,800014ba <uvmunmap+0xfa>
      kfree((void*)pa);
    }
    *pte = 0;
    8000142c:	0004b023          	sd	zero,0(s1)
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80001430:	995e                	add	s2,s2,s7
    80001432:	09597863          	bgeu	s2,s5,800014c2 <uvmunmap+0x102>
    if((pte = walk(pagetable, a, 0)) == 0)
    80001436:	4601                	li	a2,0
    80001438:	85ca                	mv	a1,s2
    8000143a:	855a                	mv	a0,s6
    8000143c:	c5dff0ef          	jal	80001098 <walk>
    80001440:	84aa                	mv	s1,a0
    80001442:	d57d                	beqz	a0,80001430 <uvmunmap+0x70>
    if((*pte & PTE_V) == 0)
    80001444:	00053983          	ld	s3,0(a0)
    80001448:	0019f793          	andi	a5,s3,1
    8000144c:	d3f5                	beqz	a5,80001430 <uvmunmap+0x70>
    uint64 pa = PTE2PA(*pte);
    8000144e:	00a9d993          	srli	s3,s3,0xa
    80001452:	09b2                	slli	s3,s3,0xc
    struct proc *p = myproc();
    80001454:	7ec000ef          	jal	80001c40 <myproc>
    80001458:	8a2a                	mv	s4,a0
    if(p){
    8000145a:	d579                	beqz	a0,80001428 <uvmunmap+0x68>
      memset(&e, 0, sizeof(e));
    8000145c:	06800613          	li	a2,104
    80001460:	4581                	li	a1,0
    80001462:	8566                	mv	a0,s9
    80001464:	98fff0ef          	jal	80000df2 <memset>
      e.ticks  = ticks;
    80001468:	000da783          	lw	a5,0(s11)
    8000146c:	f2f42823          	sw	a5,-208(s0)
      e.cpu    = cpuid();
    80001470:	79c000ef          	jal	80001c0c <cpuid>
    80001474:	f2a42a23          	sw	a0,-204(s0)
      e.type   = MEM_UNMAP;
    80001478:	f3a42c23          	sw	s10,-200(s0)
      e.pid    = p->pid;
    8000147c:	030a2783          	lw	a5,48(s4)
    80001480:	f2f42e23          	sw	a5,-196(s0)
      e.state  = p->state;
    80001484:	018a2783          	lw	a5,24(s4)
    80001488:	f4f42023          	sw	a5,-192(s0)
      e.va     = a;
    8000148c:	f5243c23          	sd	s2,-168(s0)
      e.pa     = pa;
    80001490:	f7343023          	sd	s3,-160(s0)
      e.len    = PGSIZE;
    80001494:	f7743c23          	sd	s7,-136(s0)
      e.source = SRC_UVMUNMAP;
    80001498:	4791                	li	a5,4
    8000149a:	f8f42223          	sw	a5,-124(s0)
      e.kind   = PAGE_USER;
    8000149e:	4785                	li	a5,1
    800014a0:	f8f42423          	sw	a5,-120(s0)
      safestrcpy(e.name, p->name, MEM_NM);
    800014a4:	4641                	li	a2,16
    800014a6:	158a0593          	addi	a1,s4,344
    800014aa:	f4440513          	addi	a0,s0,-188
    800014ae:	a99ff0ef          	jal	80000f46 <safestrcpy>
      memlog_push(&e);
    800014b2:	8566                	mv	a0,s9
    800014b4:	048050ef          	jal	800064fc <memlog_push>
    800014b8:	bf85                	j	80001428 <uvmunmap+0x68>
      kfree((void*)pa);
    800014ba:	854e                	mv	a0,s3
    800014bc:	dd2ff0ef          	jal	80000a8e <kfree>
    800014c0:	b7b5                	j	8000142c <uvmunmap+0x6c>
    800014c2:	64ae                	ld	s1,200(sp)
    800014c4:	79ea                	ld	s3,184(sp)
    800014c6:	7a4a                	ld	s4,176(sp)
    800014c8:	6bea                	ld	s7,152(sp)
    800014ca:	6caa                	ld	s9,136(sp)
    800014cc:	6d0a                	ld	s10,128(sp)
    800014ce:	7de6                	ld	s11,120(sp)
    800014d0:	690e                	ld	s2,192(sp)
    800014d2:	7aaa                	ld	s5,168(sp)
    800014d4:	7b0a                	ld	s6,160(sp)
    800014d6:	6c4a                	ld	s8,144(sp)
  }
}
    800014d8:	60ee                	ld	ra,216(sp)
    800014da:	644e                	ld	s0,208(sp)
    800014dc:	612d                	addi	sp,sp,224
    800014de:	8082                	ret

00000000800014e0 <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    800014e0:	1101                	addi	sp,sp,-32
    800014e2:	ec06                	sd	ra,24(sp)
    800014e4:	e822                	sd	s0,16(sp)
    800014e6:	e426                	sd	s1,8(sp)
    800014e8:	1000                	addi	s0,sp,32
  if(newsz >= oldsz)
    return oldsz;
    800014ea:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    800014ec:	00b67d63          	bgeu	a2,a1,80001506 <uvmdealloc+0x26>
    800014f0:	84b2                	mv	s1,a2

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    800014f2:	6785                	lui	a5,0x1
    800014f4:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    800014f6:	00f60733          	add	a4,a2,a5
    800014fa:	76fd                	lui	a3,0xfffff
    800014fc:	8f75                	and	a4,a4,a3
    800014fe:	97ae                	add	a5,a5,a1
    80001500:	8ff5                	and	a5,a5,a3
    80001502:	00f76863          	bltu	a4,a5,80001512 <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    80001506:	8526                	mv	a0,s1
    80001508:	60e2                	ld	ra,24(sp)
    8000150a:	6442                	ld	s0,16(sp)
    8000150c:	64a2                	ld	s1,8(sp)
    8000150e:	6105                	addi	sp,sp,32
    80001510:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    80001512:	8f99                	sub	a5,a5,a4
    80001514:	83b1                	srli	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    80001516:	4685                	li	a3,1
    80001518:	0007861b          	sext.w	a2,a5
    8000151c:	85ba                	mv	a1,a4
    8000151e:	ea3ff0ef          	jal	800013c0 <uvmunmap>
    80001522:	b7d5                	j	80001506 <uvmdealloc+0x26>

0000000080001524 <uvmalloc>:
{
    80001524:	7131                	addi	sp,sp,-192
    80001526:	fd06                	sd	ra,184(sp)
    80001528:	f922                	sd	s0,176(sp)
    8000152a:	f526                	sd	s1,168(sp)
    8000152c:	0180                	addi	s0,sp,192
    8000152e:	84ae                	mv	s1,a1
  if(newsz < oldsz)
    80001530:	00b67863          	bgeu	a2,a1,80001540 <uvmalloc+0x1c>
}
    80001534:	8526                	mv	a0,s1
    80001536:	70ea                	ld	ra,184(sp)
    80001538:	744a                	ld	s0,176(sp)
    8000153a:	74aa                	ld	s1,168(sp)
    8000153c:	6129                	addi	sp,sp,192
    8000153e:	8082                	ret
    80001540:	f14a                	sd	s2,160(sp)
    80001542:	ed4e                	sd	s3,152(sp)
    80001544:	e952                	sd	s4,144(sp)
    80001546:	e556                	sd	s5,136(sp)
    80001548:	e15a                	sd	s6,128(sp)
    8000154a:	fcde                	sd	s7,120(sp)
    8000154c:	8b2a                	mv	s6,a0
    8000154e:	8a32                	mv	s4,a2
    80001550:	8ab6                	mv	s5,a3
      struct proc *p = myproc();
    80001552:	6ee000ef          	jal	80001c40 <myproc>
    80001556:	892a                	mv	s2,a0
  if(p){
    80001558:	c12d                	beqz	a0,800015ba <uvmalloc+0x96>
    memset(&e, 0, sizeof(e));
    8000155a:	f4840993          	addi	s3,s0,-184
    8000155e:	06800613          	li	a2,104
    80001562:	4581                	li	a1,0
    80001564:	854e                	mv	a0,s3
    80001566:	88dff0ef          	jal	80000df2 <memset>
    e.ticks  = ticks;
    8000156a:	00008797          	auipc	a5,0x8
    8000156e:	ac67a783          	lw	a5,-1338(a5) # 80009030 <ticks>
    80001572:	f4f42823          	sw	a5,-176(s0)
    e.cpu    = cpuid();
    80001576:	696000ef          	jal	80001c0c <cpuid>
    8000157a:	f4a42a23          	sw	a0,-172(s0)
    e.type   = MEM_GROW;
    8000157e:	4785                	li	a5,1
    80001580:	f4f42c23          	sw	a5,-168(s0)
    e.pid    = p->pid;
    80001584:	03092703          	lw	a4,48(s2)
    80001588:	f4e42e23          	sw	a4,-164(s0)
    e.state  = p->state;
    8000158c:	01892703          	lw	a4,24(s2)
    80001590:	f6e42023          	sw	a4,-160(s0)
    e.oldsz  = oldsz;
    80001594:	f8943423          	sd	s1,-120(s0)
    e.newsz  = newsz;
    80001598:	f9443823          	sd	s4,-112(s0)
    e.source = SRC_UVMALLOC;
    8000159c:	4715                	li	a4,5
    8000159e:	fae42223          	sw	a4,-92(s0)
    e.kind   = PAGE_USER;
    800015a2:	faf42423          	sw	a5,-88(s0)
    safestrcpy(e.name, p->name, MEM_NM);
    800015a6:	4641                	li	a2,16
    800015a8:	15890593          	addi	a1,s2,344
    800015ac:	f6440513          	addi	a0,s0,-156
    800015b0:	997ff0ef          	jal	80000f46 <safestrcpy>
    memlog_push(&e);
    800015b4:	854e                	mv	a0,s3
    800015b6:	747040ef          	jal	800064fc <memlog_push>
  oldsz = PGROUNDUP(oldsz);
    800015ba:	6785                	lui	a5,0x1
    800015bc:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    800015be:	97a6                	add	a5,a5,s1
    800015c0:	777d                	lui	a4,0xfffff
    800015c2:	8ff9                	and	a5,a5,a4
    800015c4:	8bbe                	mv	s7,a5
  for(a = oldsz; a < newsz; a += PGSIZE){
    800015c6:	0747fd63          	bgeu	a5,s4,80001640 <uvmalloc+0x11c>
    800015ca:	893e                	mv	s2,a5
    memset(mem, 0, PGSIZE);
    800015cc:	6985                	lui	s3,0x1
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    800015ce:	012aea93          	ori	s5,s5,18
    mem = kalloc();
    800015d2:	e08ff0ef          	jal	80000bda <kalloc>
    800015d6:	84aa                	mv	s1,a0
    if(mem == 0){
    800015d8:	c905                	beqz	a0,80001608 <uvmalloc+0xe4>
    memset(mem, 0, PGSIZE);
    800015da:	864e                	mv	a2,s3
    800015dc:	4581                	li	a1,0
    800015de:	815ff0ef          	jal	80000df2 <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    800015e2:	8756                	mv	a4,s5
    800015e4:	86a6                	mv	a3,s1
    800015e6:	864e                	mv	a2,s3
    800015e8:	85ca                	mv	a1,s2
    800015ea:	855a                	mv	a0,s6
    800015ec:	b81ff0ef          	jal	8000116c <mappages>
    800015f0:	e905                	bnez	a0,80001620 <uvmalloc+0xfc>
  for(a = oldsz; a < newsz; a += PGSIZE){
    800015f2:	994e                	add	s2,s2,s3
    800015f4:	fd496fe3          	bltu	s2,s4,800015d2 <uvmalloc+0xae>
  return newsz;
    800015f8:	84d2                	mv	s1,s4
    800015fa:	790a                	ld	s2,160(sp)
    800015fc:	69ea                	ld	s3,152(sp)
    800015fe:	6a4a                	ld	s4,144(sp)
    80001600:	6aaa                	ld	s5,136(sp)
    80001602:	6b0a                	ld	s6,128(sp)
    80001604:	7be6                	ld	s7,120(sp)
    80001606:	b73d                	j	80001534 <uvmalloc+0x10>
      uvmdealloc(pagetable, a, oldsz);
    80001608:	865e                	mv	a2,s7
    8000160a:	85ca                	mv	a1,s2
    8000160c:	855a                	mv	a0,s6
    8000160e:	ed3ff0ef          	jal	800014e0 <uvmdealloc>
      return 0;
    80001612:	790a                	ld	s2,160(sp)
    80001614:	69ea                	ld	s3,152(sp)
    80001616:	6a4a                	ld	s4,144(sp)
    80001618:	6aaa                	ld	s5,136(sp)
    8000161a:	6b0a                	ld	s6,128(sp)
    8000161c:	7be6                	ld	s7,120(sp)
    8000161e:	bf19                	j	80001534 <uvmalloc+0x10>
      kfree(mem);
    80001620:	8526                	mv	a0,s1
    80001622:	c6cff0ef          	jal	80000a8e <kfree>
      uvmdealloc(pagetable, a, oldsz);
    80001626:	865e                	mv	a2,s7
    80001628:	85ca                	mv	a1,s2
    8000162a:	855a                	mv	a0,s6
    8000162c:	eb5ff0ef          	jal	800014e0 <uvmdealloc>
      return 0;
    80001630:	4481                	li	s1,0
    80001632:	790a                	ld	s2,160(sp)
    80001634:	69ea                	ld	s3,152(sp)
    80001636:	6a4a                	ld	s4,144(sp)
    80001638:	6aaa                	ld	s5,136(sp)
    8000163a:	6b0a                	ld	s6,128(sp)
    8000163c:	7be6                	ld	s7,120(sp)
    8000163e:	bddd                	j	80001534 <uvmalloc+0x10>
  return newsz;
    80001640:	84d2                	mv	s1,s4
    80001642:	790a                	ld	s2,160(sp)
    80001644:	69ea                	ld	s3,152(sp)
    80001646:	6a4a                	ld	s4,144(sp)
    80001648:	6aaa                	ld	s5,136(sp)
    8000164a:	6b0a                	ld	s6,128(sp)
    8000164c:	7be6                	ld	s7,120(sp)
    8000164e:	b5dd                	j	80001534 <uvmalloc+0x10>

0000000080001650 <freewalk>:
// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    80001650:	7179                	addi	sp,sp,-48
    80001652:	f406                	sd	ra,40(sp)
    80001654:	f022                	sd	s0,32(sp)
    80001656:	ec26                	sd	s1,24(sp)
    80001658:	e84a                	sd	s2,16(sp)
    8000165a:	e44e                	sd	s3,8(sp)
    8000165c:	1800                	addi	s0,sp,48
    8000165e:	89aa                	mv	s3,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    80001660:	84aa                	mv	s1,a0
    80001662:	6905                	lui	s2,0x1
    80001664:	992a                	add	s2,s2,a0
    80001666:	a811                	j	8000167a <freewalk+0x2a>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
      freewalk((pagetable_t)child);
      pagetable[i] = 0;
    } else if(pte & PTE_V){
      panic("freewalk: leaf");
    80001668:	00007517          	auipc	a0,0x7
    8000166c:	ad850513          	addi	a0,a0,-1320 # 80008140 <etext+0x140>
    80001670:	9e6ff0ef          	jal	80000856 <panic>
  for(int i = 0; i < 512; i++){
    80001674:	04a1                	addi	s1,s1,8
    80001676:	03248163          	beq	s1,s2,80001698 <freewalk+0x48>
    pte_t pte = pagetable[i];
    8000167a:	609c                	ld	a5,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    8000167c:	0017f713          	andi	a4,a5,1
    80001680:	db75                	beqz	a4,80001674 <freewalk+0x24>
    80001682:	00e7f713          	andi	a4,a5,14
    80001686:	f36d                	bnez	a4,80001668 <freewalk+0x18>
      uint64 child = PTE2PA(pte);
    80001688:	83a9                	srli	a5,a5,0xa
      freewalk((pagetable_t)child);
    8000168a:	00c79513          	slli	a0,a5,0xc
    8000168e:	fc3ff0ef          	jal	80001650 <freewalk>
      pagetable[i] = 0;
    80001692:	0004b023          	sd	zero,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    80001696:	bff9                	j	80001674 <freewalk+0x24>
    }
  }
  kfree((void*)pagetable);
    80001698:	854e                	mv	a0,s3
    8000169a:	bf4ff0ef          	jal	80000a8e <kfree>
}
    8000169e:	70a2                	ld	ra,40(sp)
    800016a0:	7402                	ld	s0,32(sp)
    800016a2:	64e2                	ld	s1,24(sp)
    800016a4:	6942                	ld	s2,16(sp)
    800016a6:	69a2                	ld	s3,8(sp)
    800016a8:	6145                	addi	sp,sp,48
    800016aa:	8082                	ret

00000000800016ac <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    800016ac:	1101                	addi	sp,sp,-32
    800016ae:	ec06                	sd	ra,24(sp)
    800016b0:	e822                	sd	s0,16(sp)
    800016b2:	e426                	sd	s1,8(sp)
    800016b4:	1000                	addi	s0,sp,32
    800016b6:	84aa                	mv	s1,a0
  if(sz > 0)
    800016b8:	e989                	bnez	a1,800016ca <uvmfree+0x1e>
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
  freewalk(pagetable);
    800016ba:	8526                	mv	a0,s1
    800016bc:	f95ff0ef          	jal	80001650 <freewalk>
}
    800016c0:	60e2                	ld	ra,24(sp)
    800016c2:	6442                	ld	s0,16(sp)
    800016c4:	64a2                	ld	s1,8(sp)
    800016c6:	6105                	addi	sp,sp,32
    800016c8:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
    800016ca:	6785                	lui	a5,0x1
    800016cc:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    800016ce:	95be                	add	a1,a1,a5
    800016d0:	4685                	li	a3,1
    800016d2:	00c5d613          	srli	a2,a1,0xc
    800016d6:	4581                	li	a1,0
    800016d8:	ce9ff0ef          	jal	800013c0 <uvmunmap>
    800016dc:	bff9                	j	800016ba <uvmfree+0xe>

00000000800016de <uvmcopy>:
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for(i = 0; i < sz; i += PGSIZE){
    800016de:	ca59                	beqz	a2,80001774 <uvmcopy+0x96>
{
    800016e0:	715d                	addi	sp,sp,-80
    800016e2:	e486                	sd	ra,72(sp)
    800016e4:	e0a2                	sd	s0,64(sp)
    800016e6:	fc26                	sd	s1,56(sp)
    800016e8:	f84a                	sd	s2,48(sp)
    800016ea:	f44e                	sd	s3,40(sp)
    800016ec:	f052                	sd	s4,32(sp)
    800016ee:	ec56                	sd	s5,24(sp)
    800016f0:	e85a                	sd	s6,16(sp)
    800016f2:	e45e                	sd	s7,8(sp)
    800016f4:	0880                	addi	s0,sp,80
    800016f6:	8b2a                	mv	s6,a0
    800016f8:	8bae                	mv	s7,a1
    800016fa:	8ab2                	mv	s5,a2
  for(i = 0; i < sz; i += PGSIZE){
    800016fc:	4481                	li	s1,0
      continue;   // physical page hasn't been allocated
    pa = PTE2PA(*pte);
    flags = PTE_FLAGS(*pte);
    if((mem = kalloc()) == 0)
      goto err;
    memmove(mem, (char*)pa, PGSIZE);
    800016fe:	6a05                	lui	s4,0x1
    80001700:	a021                	j	80001708 <uvmcopy+0x2a>
  for(i = 0; i < sz; i += PGSIZE){
    80001702:	94d2                	add	s1,s1,s4
    80001704:	0554fc63          	bgeu	s1,s5,8000175c <uvmcopy+0x7e>
    if((pte = walk(old, i, 0)) == 0)
    80001708:	4601                	li	a2,0
    8000170a:	85a6                	mv	a1,s1
    8000170c:	855a                	mv	a0,s6
    8000170e:	98bff0ef          	jal	80001098 <walk>
    80001712:	d965                	beqz	a0,80001702 <uvmcopy+0x24>
    if((*pte & PTE_V) == 0)
    80001714:	00053983          	ld	s3,0(a0)
    80001718:	0019f793          	andi	a5,s3,1
    8000171c:	d3fd                	beqz	a5,80001702 <uvmcopy+0x24>
    if((mem = kalloc()) == 0)
    8000171e:	cbcff0ef          	jal	80000bda <kalloc>
    80001722:	892a                	mv	s2,a0
    80001724:	c11d                	beqz	a0,8000174a <uvmcopy+0x6c>
    pa = PTE2PA(*pte);
    80001726:	00a9d593          	srli	a1,s3,0xa
    memmove(mem, (char*)pa, PGSIZE);
    8000172a:	8652                	mv	a2,s4
    8000172c:	05b2                	slli	a1,a1,0xc
    8000172e:	f24ff0ef          	jal	80000e52 <memmove>
    if(mappages(new, i, PGSIZE, (uint64)mem, flags) != 0){
    80001732:	3ff9f713          	andi	a4,s3,1023
    80001736:	86ca                	mv	a3,s2
    80001738:	8652                	mv	a2,s4
    8000173a:	85a6                	mv	a1,s1
    8000173c:	855e                	mv	a0,s7
    8000173e:	a2fff0ef          	jal	8000116c <mappages>
    80001742:	d161                	beqz	a0,80001702 <uvmcopy+0x24>
      kfree(mem);
    80001744:	854a                	mv	a0,s2
    80001746:	b48ff0ef          	jal	80000a8e <kfree>
    }
  }
  return 0;

 err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    8000174a:	4685                	li	a3,1
    8000174c:	00c4d613          	srli	a2,s1,0xc
    80001750:	4581                	li	a1,0
    80001752:	855e                	mv	a0,s7
    80001754:	c6dff0ef          	jal	800013c0 <uvmunmap>
  return -1;
    80001758:	557d                	li	a0,-1
    8000175a:	a011                	j	8000175e <uvmcopy+0x80>
  return 0;
    8000175c:	4501                	li	a0,0
}
    8000175e:	60a6                	ld	ra,72(sp)
    80001760:	6406                	ld	s0,64(sp)
    80001762:	74e2                	ld	s1,56(sp)
    80001764:	7942                	ld	s2,48(sp)
    80001766:	79a2                	ld	s3,40(sp)
    80001768:	7a02                	ld	s4,32(sp)
    8000176a:	6ae2                	ld	s5,24(sp)
    8000176c:	6b42                	ld	s6,16(sp)
    8000176e:	6ba2                	ld	s7,8(sp)
    80001770:	6161                	addi	sp,sp,80
    80001772:	8082                	ret
  return 0;
    80001774:	4501                	li	a0,0
}
    80001776:	8082                	ret

0000000080001778 <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    80001778:	1141                	addi	sp,sp,-16
    8000177a:	e406                	sd	ra,8(sp)
    8000177c:	e022                	sd	s0,0(sp)
    8000177e:	0800                	addi	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    80001780:	4601                	li	a2,0
    80001782:	917ff0ef          	jal	80001098 <walk>
  if(pte == 0)
    80001786:	c901                	beqz	a0,80001796 <uvmclear+0x1e>
    panic("uvmclear");
  *pte &= ~PTE_U;
    80001788:	611c                	ld	a5,0(a0)
    8000178a:	9bbd                	andi	a5,a5,-17
    8000178c:	e11c                	sd	a5,0(a0)
}
    8000178e:	60a2                	ld	ra,8(sp)
    80001790:	6402                	ld	s0,0(sp)
    80001792:	0141                	addi	sp,sp,16
    80001794:	8082                	ret
    panic("uvmclear");
    80001796:	00007517          	auipc	a0,0x7
    8000179a:	9ba50513          	addi	a0,a0,-1606 # 80008150 <etext+0x150>
    8000179e:	8b8ff0ef          	jal	80000856 <panic>

00000000800017a2 <copyinstr>:
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    800017a2:	cac5                	beqz	a3,80001852 <copyinstr+0xb0>
{
    800017a4:	715d                	addi	sp,sp,-80
    800017a6:	e486                	sd	ra,72(sp)
    800017a8:	e0a2                	sd	s0,64(sp)
    800017aa:	fc26                	sd	s1,56(sp)
    800017ac:	f84a                	sd	s2,48(sp)
    800017ae:	f44e                	sd	s3,40(sp)
    800017b0:	f052                	sd	s4,32(sp)
    800017b2:	ec56                	sd	s5,24(sp)
    800017b4:	e85a                	sd	s6,16(sp)
    800017b6:	e45e                	sd	s7,8(sp)
    800017b8:	0880                	addi	s0,sp,80
    800017ba:	8aaa                	mv	s5,a0
    800017bc:	84ae                	mv	s1,a1
    800017be:	8bb2                	mv	s7,a2
    800017c0:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(srcva);
    800017c2:	7b7d                	lui	s6,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    800017c4:	6a05                	lui	s4,0x1
    800017c6:	a82d                	j	80001800 <copyinstr+0x5e>
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
    800017c8:	00078023          	sb	zero,0(a5)
        got_null = 1;
    800017cc:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    800017ce:	0017c793          	xori	a5,a5,1
    800017d2:	40f0053b          	negw	a0,a5
    return 0;
  } else {
    return -1;
  }
}
    800017d6:	60a6                	ld	ra,72(sp)
    800017d8:	6406                	ld	s0,64(sp)
    800017da:	74e2                	ld	s1,56(sp)
    800017dc:	7942                	ld	s2,48(sp)
    800017de:	79a2                	ld	s3,40(sp)
    800017e0:	7a02                	ld	s4,32(sp)
    800017e2:	6ae2                	ld	s5,24(sp)
    800017e4:	6b42                	ld	s6,16(sp)
    800017e6:	6ba2                	ld	s7,8(sp)
    800017e8:	6161                	addi	sp,sp,80
    800017ea:	8082                	ret
    800017ec:	fff98713          	addi	a4,s3,-1 # fff <_entry-0x7ffff001>
    800017f0:	9726                	add	a4,a4,s1
      --max;
    800017f2:	40b709b3          	sub	s3,a4,a1
    srcva = va0 + PGSIZE;
    800017f6:	01490bb3          	add	s7,s2,s4
  while(got_null == 0 && max > 0){
    800017fa:	04e58463          	beq	a1,a4,80001842 <copyinstr+0xa0>
{
    800017fe:	84be                	mv	s1,a5
    va0 = PGROUNDDOWN(srcva);
    80001800:	016bf933          	and	s2,s7,s6
    pa0 = walkaddr(pagetable, va0);
    80001804:	85ca                	mv	a1,s2
    80001806:	8556                	mv	a0,s5
    80001808:	92bff0ef          	jal	80001132 <walkaddr>
    if(pa0 == 0)
    8000180c:	cd0d                	beqz	a0,80001846 <copyinstr+0xa4>
    n = PGSIZE - (srcva - va0);
    8000180e:	417906b3          	sub	a3,s2,s7
    80001812:	96d2                	add	a3,a3,s4
    if(n > max)
    80001814:	00d9f363          	bgeu	s3,a3,8000181a <copyinstr+0x78>
    80001818:	86ce                	mv	a3,s3
    while(n > 0){
    8000181a:	ca85                	beqz	a3,8000184a <copyinstr+0xa8>
    char *p = (char *) (pa0 + (srcva - va0));
    8000181c:	01750633          	add	a2,a0,s7
    80001820:	41260633          	sub	a2,a2,s2
    80001824:	87a6                	mv	a5,s1
      if(*p == '\0'){
    80001826:	8e05                	sub	a2,a2,s1
    while(n > 0){
    80001828:	96a6                	add	a3,a3,s1
    8000182a:	85be                	mv	a1,a5
      if(*p == '\0'){
    8000182c:	00f60733          	add	a4,a2,a5
    80001830:	00074703          	lbu	a4,0(a4) # fffffffffffff000 <end+0xffffffff7ffb6c08>
    80001834:	db51                	beqz	a4,800017c8 <copyinstr+0x26>
        *dst = *p;
    80001836:	00e78023          	sb	a4,0(a5)
      dst++;
    8000183a:	0785                	addi	a5,a5,1
    while(n > 0){
    8000183c:	fed797e3          	bne	a5,a3,8000182a <copyinstr+0x88>
    80001840:	b775                	j	800017ec <copyinstr+0x4a>
    80001842:	4781                	li	a5,0
    80001844:	b769                	j	800017ce <copyinstr+0x2c>
      return -1;
    80001846:	557d                	li	a0,-1
    80001848:	b779                	j	800017d6 <copyinstr+0x34>
    srcva = va0 + PGSIZE;
    8000184a:	6b85                	lui	s7,0x1
    8000184c:	9bca                	add	s7,s7,s2
    8000184e:	87a6                	mv	a5,s1
    80001850:	b77d                	j	800017fe <copyinstr+0x5c>
  int got_null = 0;
    80001852:	4781                	li	a5,0
  if(got_null){
    80001854:	0017c793          	xori	a5,a5,1
    80001858:	40f0053b          	negw	a0,a5
}
    8000185c:	8082                	ret

000000008000185e <ismapped>:
  }
  return mem;
}
int
ismapped(pagetable_t pagetable, uint64 va)
{
    8000185e:	1141                	addi	sp,sp,-16
    80001860:	e406                	sd	ra,8(sp)
    80001862:	e022                	sd	s0,0(sp)
    80001864:	0800                	addi	s0,sp,16
  pte_t *pte = walk(pagetable, va, 0);
    80001866:	4601                	li	a2,0
    80001868:	831ff0ef          	jal	80001098 <walk>
  if (pte == 0) {
    8000186c:	c119                	beqz	a0,80001872 <ismapped+0x14>
    return 0;
  }
  if (*pte & PTE_V){
    8000186e:	6108                	ld	a0,0(a0)
    80001870:	8905                	andi	a0,a0,1
    return 1;
  }
  return 0;
}
    80001872:	60a2                	ld	ra,8(sp)
    80001874:	6402                	ld	s0,0(sp)
    80001876:	0141                	addi	sp,sp,16
    80001878:	8082                	ret

000000008000187a <vmfault>:
{
    8000187a:	7135                	addi	sp,sp,-160
    8000187c:	ed06                	sd	ra,152(sp)
    8000187e:	e922                	sd	s0,144(sp)
    80001880:	e14a                	sd	s2,128(sp)
    80001882:	fcce                	sd	s3,120(sp)
    80001884:	f8d2                	sd	s4,112(sp)
    80001886:	1100                	addi	s0,sp,160
    80001888:	89aa                	mv	s3,a0
    8000188a:	892e                	mv	s2,a1
  struct proc *p = myproc();
    8000188c:	3b4000ef          	jal	80001c40 <myproc>
  if (va >= p->sz)
    80001890:	653c                	ld	a5,72(a0)
    return 0;
    80001892:	4a01                	li	s4,0
  if (va >= p->sz)
    80001894:	00f96a63          	bltu	s2,a5,800018a8 <vmfault+0x2e>
}
    80001898:	8552                	mv	a0,s4
    8000189a:	60ea                	ld	ra,152(sp)
    8000189c:	644a                	ld	s0,144(sp)
    8000189e:	690a                	ld	s2,128(sp)
    800018a0:	79e6                	ld	s3,120(sp)
    800018a2:	7a46                	ld	s4,112(sp)
    800018a4:	610d                	addi	sp,sp,160
    800018a6:	8082                	ret
    800018a8:	e526                	sd	s1,136(sp)
    800018aa:	84aa                	mv	s1,a0
  va = PGROUNDDOWN(va);
    800018ac:	77fd                	lui	a5,0xfffff
    800018ae:	00f97933          	and	s2,s2,a5
  if(ismapped(pagetable, va)) {
    800018b2:	85ca                	mv	a1,s2
    800018b4:	854e                	mv	a0,s3
    800018b6:	fa9ff0ef          	jal	8000185e <ismapped>
    return 0;
    800018ba:	4a01                	li	s4,0
  if(ismapped(pagetable, va)) {
    800018bc:	c119                	beqz	a0,800018c2 <vmfault+0x48>
    800018be:	64aa                	ld	s1,136(sp)
    800018c0:	bfe1                	j	80001898 <vmfault+0x1e>
  memset(&e, 0, sizeof(e));
    800018c2:	06800613          	li	a2,104
    800018c6:	4581                	li	a1,0
    800018c8:	f6840513          	addi	a0,s0,-152
    800018cc:	d26ff0ef          	jal	80000df2 <memset>
  e.ticks  = ticks;
    800018d0:	00007797          	auipc	a5,0x7
    800018d4:	7607a783          	lw	a5,1888(a5) # 80009030 <ticks>
    800018d8:	f6f42823          	sw	a5,-144(s0)
  e.cpu    = cpuid();
    800018dc:	330000ef          	jal	80001c0c <cpuid>
    800018e0:	f6a42a23          	sw	a0,-140(s0)
  e.type   = MEM_FAULT;
    800018e4:	478d                	li	a5,3
    800018e6:	f6f42c23          	sw	a5,-136(s0)
  e.pid    = p->pid;
    800018ea:	589c                	lw	a5,48(s1)
    800018ec:	f6f42e23          	sw	a5,-132(s0)
  e.state  = p->state;
    800018f0:	4c9c                	lw	a5,24(s1)
    800018f2:	f8f42023          	sw	a5,-128(s0)
  e.va     = va;
    800018f6:	f9243c23          	sd	s2,-104(s0)
  e.source = SRC_VMFAULT;
    800018fa:	479d                	li	a5,7
    800018fc:	fcf42223          	sw	a5,-60(s0)
  e.kind   = PAGE_USER;
    80001900:	4785                	li	a5,1
    80001902:	fcf42423          	sw	a5,-56(s0)
  safestrcpy(e.name, p->name, MEM_NM);
    80001906:	4641                	li	a2,16
    80001908:	15848593          	addi	a1,s1,344
    8000190c:	f8440513          	addi	a0,s0,-124
    80001910:	e36ff0ef          	jal	80000f46 <safestrcpy>
  memlog_push(&e);
    80001914:	f6840513          	addi	a0,s0,-152
    80001918:	3e5040ef          	jal	800064fc <memlog_push>
  mem = (uint64) kalloc();
    8000191c:	abeff0ef          	jal	80000bda <kalloc>
    80001920:	89aa                	mv	s3,a0
  if(mem == 0)
    80001922:	c515                	beqz	a0,8000194e <vmfault+0xd4>
  mem = (uint64) kalloc();
    80001924:	8a2a                	mv	s4,a0
  memset((void *) mem, 0, PGSIZE);
    80001926:	6605                	lui	a2,0x1
    80001928:	4581                	li	a1,0
    8000192a:	cc8ff0ef          	jal	80000df2 <memset>
  if (mappages(p->pagetable, va, PGSIZE, mem, PTE_W|PTE_U|PTE_R) != 0) {
    8000192e:	4759                	li	a4,22
    80001930:	86ce                	mv	a3,s3
    80001932:	6605                	lui	a2,0x1
    80001934:	85ca                	mv	a1,s2
    80001936:	68a8                	ld	a0,80(s1)
    80001938:	835ff0ef          	jal	8000116c <mappages>
    8000193c:	e119                	bnez	a0,80001942 <vmfault+0xc8>
    8000193e:	64aa                	ld	s1,136(sp)
    80001940:	bfa1                	j	80001898 <vmfault+0x1e>
    kfree((void *)mem);
    80001942:	854e                	mv	a0,s3
    80001944:	94aff0ef          	jal	80000a8e <kfree>
    return 0;
    80001948:	4a01                	li	s4,0
    8000194a:	64aa                	ld	s1,136(sp)
    8000194c:	b7b1                	j	80001898 <vmfault+0x1e>
    8000194e:	64aa                	ld	s1,136(sp)
    80001950:	b7a1                	j	80001898 <vmfault+0x1e>

0000000080001952 <copyout>:
  while(len > 0){
    80001952:	cad1                	beqz	a3,800019e6 <copyout+0x94>
{
    80001954:	711d                	addi	sp,sp,-96
    80001956:	ec86                	sd	ra,88(sp)
    80001958:	e8a2                	sd	s0,80(sp)
    8000195a:	e4a6                	sd	s1,72(sp)
    8000195c:	e0ca                	sd	s2,64(sp)
    8000195e:	fc4e                	sd	s3,56(sp)
    80001960:	f852                	sd	s4,48(sp)
    80001962:	f456                	sd	s5,40(sp)
    80001964:	f05a                	sd	s6,32(sp)
    80001966:	ec5e                	sd	s7,24(sp)
    80001968:	e862                	sd	s8,16(sp)
    8000196a:	e466                	sd	s9,8(sp)
    8000196c:	e06a                	sd	s10,0(sp)
    8000196e:	1080                	addi	s0,sp,96
    80001970:	8baa                	mv	s7,a0
    80001972:	8a2e                	mv	s4,a1
    80001974:	8b32                	mv	s6,a2
    80001976:	8ab6                	mv	s5,a3
    va0 = PGROUNDDOWN(dstva);
    80001978:	7d7d                	lui	s10,0xfffff
    if(va0 >= MAXVA)
    8000197a:	5cfd                	li	s9,-1
    8000197c:	01acdc93          	srli	s9,s9,0x1a
    n = PGSIZE - (dstva - va0);
    80001980:	6c05                	lui	s8,0x1
    80001982:	a005                	j	800019a2 <copyout+0x50>
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    80001984:	409a0533          	sub	a0,s4,s1
    80001988:	0009061b          	sext.w	a2,s2
    8000198c:	85da                	mv	a1,s6
    8000198e:	954e                	add	a0,a0,s3
    80001990:	cc2ff0ef          	jal	80000e52 <memmove>
    len -= n;
    80001994:	412a8ab3          	sub	s5,s5,s2
    src += n;
    80001998:	9b4a                	add	s6,s6,s2
    dstva = va0 + PGSIZE;
    8000199a:	01848a33          	add	s4,s1,s8
  while(len > 0){
    8000199e:	040a8263          	beqz	s5,800019e2 <copyout+0x90>
    va0 = PGROUNDDOWN(dstva);
    800019a2:	01aa74b3          	and	s1,s4,s10
    if(va0 >= MAXVA)
    800019a6:	049ce263          	bltu	s9,s1,800019ea <copyout+0x98>
    pa0 = walkaddr(pagetable, va0);
    800019aa:	85a6                	mv	a1,s1
    800019ac:	855e                	mv	a0,s7
    800019ae:	f84ff0ef          	jal	80001132 <walkaddr>
    800019b2:	89aa                	mv	s3,a0
    if(pa0 == 0) {
    800019b4:	e901                	bnez	a0,800019c4 <copyout+0x72>
      if((pa0 = vmfault(pagetable, va0, 0)) == 0) {
    800019b6:	4601                	li	a2,0
    800019b8:	85a6                	mv	a1,s1
    800019ba:	855e                	mv	a0,s7
    800019bc:	ebfff0ef          	jal	8000187a <vmfault>
    800019c0:	89aa                	mv	s3,a0
    800019c2:	c139                	beqz	a0,80001a08 <copyout+0xb6>
    pte = walk(pagetable, va0, 0);
    800019c4:	4601                	li	a2,0
    800019c6:	85a6                	mv	a1,s1
    800019c8:	855e                	mv	a0,s7
    800019ca:	eceff0ef          	jal	80001098 <walk>
    if((*pte & PTE_W) == 0)
    800019ce:	611c                	ld	a5,0(a0)
    800019d0:	8b91                	andi	a5,a5,4
    800019d2:	cf8d                	beqz	a5,80001a0c <copyout+0xba>
    n = PGSIZE - (dstva - va0);
    800019d4:	41448933          	sub	s2,s1,s4
    800019d8:	9962                	add	s2,s2,s8
    if(n > len)
    800019da:	fb2af5e3          	bgeu	s5,s2,80001984 <copyout+0x32>
    800019de:	8956                	mv	s2,s5
    800019e0:	b755                	j	80001984 <copyout+0x32>
  return 0;
    800019e2:	4501                	li	a0,0
    800019e4:	a021                	j	800019ec <copyout+0x9a>
    800019e6:	4501                	li	a0,0
}
    800019e8:	8082                	ret
      return -1;
    800019ea:	557d                	li	a0,-1
}
    800019ec:	60e6                	ld	ra,88(sp)
    800019ee:	6446                	ld	s0,80(sp)
    800019f0:	64a6                	ld	s1,72(sp)
    800019f2:	6906                	ld	s2,64(sp)
    800019f4:	79e2                	ld	s3,56(sp)
    800019f6:	7a42                	ld	s4,48(sp)
    800019f8:	7aa2                	ld	s5,40(sp)
    800019fa:	7b02                	ld	s6,32(sp)
    800019fc:	6be2                	ld	s7,24(sp)
    800019fe:	6c42                	ld	s8,16(sp)
    80001a00:	6ca2                	ld	s9,8(sp)
    80001a02:	6d02                	ld	s10,0(sp)
    80001a04:	6125                	addi	sp,sp,96
    80001a06:	8082                	ret
        return -1;
    80001a08:	557d                	li	a0,-1
    80001a0a:	b7cd                	j	800019ec <copyout+0x9a>
      return -1;
    80001a0c:	557d                	li	a0,-1
    80001a0e:	bff9                	j	800019ec <copyout+0x9a>

0000000080001a10 <copyin>:
  while(len > 0){
    80001a10:	c6c9                	beqz	a3,80001a9a <copyin+0x8a>
{
    80001a12:	715d                	addi	sp,sp,-80
    80001a14:	e486                	sd	ra,72(sp)
    80001a16:	e0a2                	sd	s0,64(sp)
    80001a18:	fc26                	sd	s1,56(sp)
    80001a1a:	f84a                	sd	s2,48(sp)
    80001a1c:	f44e                	sd	s3,40(sp)
    80001a1e:	f052                	sd	s4,32(sp)
    80001a20:	ec56                	sd	s5,24(sp)
    80001a22:	e85a                	sd	s6,16(sp)
    80001a24:	e45e                	sd	s7,8(sp)
    80001a26:	e062                	sd	s8,0(sp)
    80001a28:	0880                	addi	s0,sp,80
    80001a2a:	8baa                	mv	s7,a0
    80001a2c:	8aae                	mv	s5,a1
    80001a2e:	8932                	mv	s2,a2
    80001a30:	8a36                	mv	s4,a3
    va0 = PGROUNDDOWN(srcva);
    80001a32:	7c7d                	lui	s8,0xfffff
    n = PGSIZE - (srcva - va0);
    80001a34:	6b05                	lui	s6,0x1
    80001a36:	a035                	j	80001a62 <copyin+0x52>
    80001a38:	412984b3          	sub	s1,s3,s2
    80001a3c:	94da                	add	s1,s1,s6
    if(n > len)
    80001a3e:	009a7363          	bgeu	s4,s1,80001a44 <copyin+0x34>
    80001a42:	84d2                	mv	s1,s4
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    80001a44:	413905b3          	sub	a1,s2,s3
    80001a48:	0004861b          	sext.w	a2,s1
    80001a4c:	95aa                	add	a1,a1,a0
    80001a4e:	8556                	mv	a0,s5
    80001a50:	c02ff0ef          	jal	80000e52 <memmove>
    len -= n;
    80001a54:	409a0a33          	sub	s4,s4,s1
    dst += n;
    80001a58:	9aa6                	add	s5,s5,s1
    srcva = va0 + PGSIZE;
    80001a5a:	01698933          	add	s2,s3,s6
  while(len > 0){
    80001a5e:	020a0163          	beqz	s4,80001a80 <copyin+0x70>
    va0 = PGROUNDDOWN(srcva);
    80001a62:	018979b3          	and	s3,s2,s8
    pa0 = walkaddr(pagetable, va0);
    80001a66:	85ce                	mv	a1,s3
    80001a68:	855e                	mv	a0,s7
    80001a6a:	ec8ff0ef          	jal	80001132 <walkaddr>
    if(pa0 == 0) {
    80001a6e:	f569                	bnez	a0,80001a38 <copyin+0x28>
      if((pa0 = vmfault(pagetable, va0, 0)) == 0) {
    80001a70:	4601                	li	a2,0
    80001a72:	85ce                	mv	a1,s3
    80001a74:	855e                	mv	a0,s7
    80001a76:	e05ff0ef          	jal	8000187a <vmfault>
    80001a7a:	fd5d                	bnez	a0,80001a38 <copyin+0x28>
        return -1;
    80001a7c:	557d                	li	a0,-1
    80001a7e:	a011                	j	80001a82 <copyin+0x72>
  return 0;
    80001a80:	4501                	li	a0,0
}
    80001a82:	60a6                	ld	ra,72(sp)
    80001a84:	6406                	ld	s0,64(sp)
    80001a86:	74e2                	ld	s1,56(sp)
    80001a88:	7942                	ld	s2,48(sp)
    80001a8a:	79a2                	ld	s3,40(sp)
    80001a8c:	7a02                	ld	s4,32(sp)
    80001a8e:	6ae2                	ld	s5,24(sp)
    80001a90:	6b42                	ld	s6,16(sp)
    80001a92:	6ba2                	ld	s7,8(sp)
    80001a94:	6c02                	ld	s8,0(sp)
    80001a96:	6161                	addi	sp,sp,80
    80001a98:	8082                	ret
  return 0;
    80001a9a:	4501                	li	a0,0
}
    80001a9c:	8082                	ret

0000000080001a9e <proc_mapstacks>:
struct spinlock wait_lock;

// Allocate a page for each process's kernel stack.
// Map it high in memory, followed by an invalid
// guard page.
void proc_mapstacks(pagetable_t kpgtbl) {
    80001a9e:	715d                	addi	sp,sp,-80
    80001aa0:	e486                	sd	ra,72(sp)
    80001aa2:	e0a2                	sd	s0,64(sp)
    80001aa4:	fc26                	sd	s1,56(sp)
    80001aa6:	f84a                	sd	s2,48(sp)
    80001aa8:	f44e                	sd	s3,40(sp)
    80001aaa:	f052                	sd	s4,32(sp)
    80001aac:	ec56                	sd	s5,24(sp)
    80001aae:	e85a                	sd	s6,16(sp)
    80001ab0:	e45e                	sd	s7,8(sp)
    80001ab2:	e062                	sd	s8,0(sp)
    80001ab4:	0880                	addi	s0,sp,80
    80001ab6:	8a2a                	mv	s4,a0
  struct proc *p;

  for (p = proc; p < &proc[NPROC]; p++) {
    80001ab8:	00011497          	auipc	s1,0x11
    80001abc:	ab848493          	addi	s1,s1,-1352 # 80012570 <proc>
    char *pa = kalloc();
    if (pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int)(p - proc));
    80001ac0:	8c26                	mv	s8,s1
    80001ac2:	000a57b7          	lui	a5,0xa5
    80001ac6:	fa578793          	addi	a5,a5,-91 # a4fa5 <_entry-0x7ff5b05b>
    80001aca:	07b2                	slli	a5,a5,0xc
    80001acc:	fa578793          	addi	a5,a5,-91
    80001ad0:	4fa50937          	lui	s2,0x4fa50
    80001ad4:	a4f90913          	addi	s2,s2,-1457 # 4fa4fa4f <_entry-0x305b05b1>
    80001ad8:	1902                	slli	s2,s2,0x20
    80001ada:	993e                	add	s2,s2,a5
    80001adc:	040009b7          	lui	s3,0x4000
    80001ae0:	19fd                	addi	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    80001ae2:	09b2                	slli	s3,s3,0xc
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    80001ae4:	4b99                	li	s7,6
    80001ae6:	6b05                	lui	s6,0x1
  for (p = proc; p < &proc[NPROC]; p++) {
    80001ae8:	00016a97          	auipc	s5,0x16
    80001aec:	488a8a93          	addi	s5,s5,1160 # 80017f70 <tickslock>
    char *pa = kalloc();
    80001af0:	8eaff0ef          	jal	80000bda <kalloc>
    80001af4:	862a                	mv	a2,a0
    if (pa == 0)
    80001af6:	c121                	beqz	a0,80001b36 <proc_mapstacks+0x98>
    uint64 va = KSTACK((int)(p - proc));
    80001af8:	418485b3          	sub	a1,s1,s8
    80001afc:	858d                	srai	a1,a1,0x3
    80001afe:	032585b3          	mul	a1,a1,s2
    80001b02:	05b6                	slli	a1,a1,0xd
    80001b04:	6789                	lui	a5,0x2
    80001b06:	9dbd                	addw	a1,a1,a5
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    80001b08:	875e                	mv	a4,s7
    80001b0a:	86da                	mv	a3,s6
    80001b0c:	40b985b3          	sub	a1,s3,a1
    80001b10:	8552                	mv	a0,s4
    80001b12:	f90ff0ef          	jal	800012a2 <kvmmap>
  for (p = proc; p < &proc[NPROC]; p++) {
    80001b16:	16848493          	addi	s1,s1,360
    80001b1a:	fd549be3          	bne	s1,s5,80001af0 <proc_mapstacks+0x52>
  }
}
    80001b1e:	60a6                	ld	ra,72(sp)
    80001b20:	6406                	ld	s0,64(sp)
    80001b22:	74e2                	ld	s1,56(sp)
    80001b24:	7942                	ld	s2,48(sp)
    80001b26:	79a2                	ld	s3,40(sp)
    80001b28:	7a02                	ld	s4,32(sp)
    80001b2a:	6ae2                	ld	s5,24(sp)
    80001b2c:	6b42                	ld	s6,16(sp)
    80001b2e:	6ba2                	ld	s7,8(sp)
    80001b30:	6c02                	ld	s8,0(sp)
    80001b32:	6161                	addi	sp,sp,80
    80001b34:	8082                	ret
      panic("kalloc");
    80001b36:	00006517          	auipc	a0,0x6
    80001b3a:	62a50513          	addi	a0,a0,1578 # 80008160 <etext+0x160>
    80001b3e:	d19fe0ef          	jal	80000856 <panic>

0000000080001b42 <procinit>:

// initialize the proc table.
void procinit(void) {
    80001b42:	7139                	addi	sp,sp,-64
    80001b44:	fc06                	sd	ra,56(sp)
    80001b46:	f822                	sd	s0,48(sp)
    80001b48:	f426                	sd	s1,40(sp)
    80001b4a:	f04a                	sd	s2,32(sp)
    80001b4c:	ec4e                	sd	s3,24(sp)
    80001b4e:	e852                	sd	s4,16(sp)
    80001b50:	e456                	sd	s5,8(sp)
    80001b52:	e05a                	sd	s6,0(sp)
    80001b54:	0080                	addi	s0,sp,64
  struct proc *p;

  initlock(&pid_lock, "nextpid");
    80001b56:	00006597          	auipc	a1,0x6
    80001b5a:	61258593          	addi	a1,a1,1554 # 80008168 <etext+0x168>
    80001b5e:	00010517          	auipc	a0,0x10
    80001b62:	5ca50513          	addi	a0,a0,1482 # 80012128 <pid_lock>
    80001b66:	932ff0ef          	jal	80000c98 <initlock>
  initlock(&wait_lock, "wait_lock");
    80001b6a:	00006597          	auipc	a1,0x6
    80001b6e:	60658593          	addi	a1,a1,1542 # 80008170 <etext+0x170>
    80001b72:	00010517          	auipc	a0,0x10
    80001b76:	5ce50513          	addi	a0,a0,1486 # 80012140 <wait_lock>
    80001b7a:	91eff0ef          	jal	80000c98 <initlock>
  initlock(&schedinfo_lock, "schedinfo");
    80001b7e:	00006597          	auipc	a1,0x6
    80001b82:	60258593          	addi	a1,a1,1538 # 80008180 <etext+0x180>
    80001b86:	00010517          	auipc	a0,0x10
    80001b8a:	5d250513          	addi	a0,a0,1490 # 80012158 <schedinfo_lock>
    80001b8e:	90aff0ef          	jal	80000c98 <initlock>
  for (p = proc; p < &proc[NPROC]; p++) {
    80001b92:	00011497          	auipc	s1,0x11
    80001b96:	9de48493          	addi	s1,s1,-1570 # 80012570 <proc>
    initlock(&p->lock, "proc");
    80001b9a:	00006b17          	auipc	s6,0x6
    80001b9e:	5f6b0b13          	addi	s6,s6,1526 # 80008190 <etext+0x190>
    p->state = UNUSED;
    p->kstack = KSTACK((int)(p - proc));
    80001ba2:	8aa6                	mv	s5,s1
    80001ba4:	000a57b7          	lui	a5,0xa5
    80001ba8:	fa578793          	addi	a5,a5,-91 # a4fa5 <_entry-0x7ff5b05b>
    80001bac:	07b2                	slli	a5,a5,0xc
    80001bae:	fa578793          	addi	a5,a5,-91
    80001bb2:	4fa50937          	lui	s2,0x4fa50
    80001bb6:	a4f90913          	addi	s2,s2,-1457 # 4fa4fa4f <_entry-0x305b05b1>
    80001bba:	1902                	slli	s2,s2,0x20
    80001bbc:	993e                	add	s2,s2,a5
    80001bbe:	040009b7          	lui	s3,0x4000
    80001bc2:	19fd                	addi	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    80001bc4:	09b2                	slli	s3,s3,0xc
  for (p = proc; p < &proc[NPROC]; p++) {
    80001bc6:	00016a17          	auipc	s4,0x16
    80001bca:	3aaa0a13          	addi	s4,s4,938 # 80017f70 <tickslock>
    initlock(&p->lock, "proc");
    80001bce:	85da                	mv	a1,s6
    80001bd0:	8526                	mv	a0,s1
    80001bd2:	8c6ff0ef          	jal	80000c98 <initlock>
    p->state = UNUSED;
    80001bd6:	0004ac23          	sw	zero,24(s1)
    p->kstack = KSTACK((int)(p - proc));
    80001bda:	415487b3          	sub	a5,s1,s5
    80001bde:	878d                	srai	a5,a5,0x3
    80001be0:	032787b3          	mul	a5,a5,s2
    80001be4:	07b6                	slli	a5,a5,0xd
    80001be6:	6709                	lui	a4,0x2
    80001be8:	9fb9                	addw	a5,a5,a4
    80001bea:	40f987b3          	sub	a5,s3,a5
    80001bee:	e0bc                	sd	a5,64(s1)
  for (p = proc; p < &proc[NPROC]; p++) {
    80001bf0:	16848493          	addi	s1,s1,360
    80001bf4:	fd449de3          	bne	s1,s4,80001bce <procinit+0x8c>
  }
}
    80001bf8:	70e2                	ld	ra,56(sp)
    80001bfa:	7442                	ld	s0,48(sp)
    80001bfc:	74a2                	ld	s1,40(sp)
    80001bfe:	7902                	ld	s2,32(sp)
    80001c00:	69e2                	ld	s3,24(sp)
    80001c02:	6a42                	ld	s4,16(sp)
    80001c04:	6aa2                	ld	s5,8(sp)
    80001c06:	6b02                	ld	s6,0(sp)
    80001c08:	6121                	addi	sp,sp,64
    80001c0a:	8082                	ret

0000000080001c0c <cpuid>:

// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int cpuid() {
    80001c0c:	1141                	addi	sp,sp,-16
    80001c0e:	e406                	sd	ra,8(sp)
    80001c10:	e022                	sd	s0,0(sp)
    80001c12:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    80001c14:	8512                	mv	a0,tp
  int id = r_tp();
  return id;
}
    80001c16:	2501                	sext.w	a0,a0
    80001c18:	60a2                	ld	ra,8(sp)
    80001c1a:	6402                	ld	s0,0(sp)
    80001c1c:	0141                	addi	sp,sp,16
    80001c1e:	8082                	ret

0000000080001c20 <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu *mycpu(void) {
    80001c20:	1141                	addi	sp,sp,-16
    80001c22:	e406                	sd	ra,8(sp)
    80001c24:	e022                	sd	s0,0(sp)
    80001c26:	0800                	addi	s0,sp,16
    80001c28:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    80001c2a:	2781                	sext.w	a5,a5
    80001c2c:	079e                	slli	a5,a5,0x7
  return c;
}
    80001c2e:	00010517          	auipc	a0,0x10
    80001c32:	54250513          	addi	a0,a0,1346 # 80012170 <cpus>
    80001c36:	953e                	add	a0,a0,a5
    80001c38:	60a2                	ld	ra,8(sp)
    80001c3a:	6402                	ld	s0,0(sp)
    80001c3c:	0141                	addi	sp,sp,16
    80001c3e:	8082                	ret

0000000080001c40 <myproc>:

// Return the current struct proc *, or zero if none.
struct proc *myproc(void) {
    80001c40:	1101                	addi	sp,sp,-32
    80001c42:	ec06                	sd	ra,24(sp)
    80001c44:	e822                	sd	s0,16(sp)
    80001c46:	e426                	sd	s1,8(sp)
    80001c48:	1000                	addi	s0,sp,32
  push_off();
    80001c4a:	894ff0ef          	jal	80000cde <push_off>
    80001c4e:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    80001c50:	2781                	sext.w	a5,a5
    80001c52:	079e                	slli	a5,a5,0x7
    80001c54:	00010717          	auipc	a4,0x10
    80001c58:	4d470713          	addi	a4,a4,1236 # 80012128 <pid_lock>
    80001c5c:	97ba                	add	a5,a5,a4
    80001c5e:	67bc                	ld	a5,72(a5)
    80001c60:	84be                	mv	s1,a5
  pop_off();
    80001c62:	904ff0ef          	jal	80000d66 <pop_off>
  return p;
}
    80001c66:	8526                	mv	a0,s1
    80001c68:	60e2                	ld	ra,24(sp)
    80001c6a:	6442                	ld	s0,16(sp)
    80001c6c:	64a2                	ld	s1,8(sp)
    80001c6e:	6105                	addi	sp,sp,32
    80001c70:	8082                	ret

0000000080001c72 <forkret>:
  release(&p->lock);
}

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void forkret(void) {
    80001c72:	7179                	addi	sp,sp,-48
    80001c74:	f406                	sd	ra,40(sp)
    80001c76:	f022                	sd	s0,32(sp)
    80001c78:	ec26                	sd	s1,24(sp)
    80001c7a:	1800                	addi	s0,sp,48
  extern char userret[];
  static int first = 1;
  struct proc *p = myproc();
    80001c7c:	fc5ff0ef          	jal	80001c40 <myproc>
    80001c80:	84aa                	mv	s1,a0

  // Still holding p->lock from scheduler.
  release(&p->lock);
    80001c82:	934ff0ef          	jal	80000db6 <release>

  if (first) {
    80001c86:	00007797          	auipc	a5,0x7
    80001c8a:	c3a7a783          	lw	a5,-966(a5) # 800088c0 <first.1>
    80001c8e:	cf95                	beqz	a5,80001cca <forkret+0x58>
    // File system initialization must be run in the context of a
    // regular process (e.g., because it calls sleep), and thus cannot
    // be run from main().
    fsinit(ROOTDEV);
    80001c90:	4505                	li	a0,1
    80001c92:	677010ef          	jal	80003b08 <fsinit>

    first = 0;
    80001c96:	00007797          	auipc	a5,0x7
    80001c9a:	c207a523          	sw	zero,-982(a5) # 800088c0 <first.1>
    // ensure other cores see first=0.
    __sync_synchronize();
    80001c9e:	0330000f          	fence	rw,rw

    // We can invoke kexec() now that file system is initialized.
    // Put the return value (argc) of kexec into a0.
    p->trapframe->a0 = kexec("/init", (char *[]){"/init", 0});
    80001ca2:	00006797          	auipc	a5,0x6
    80001ca6:	4f678793          	addi	a5,a5,1270 # 80008198 <etext+0x198>
    80001caa:	fcf43823          	sd	a5,-48(s0)
    80001cae:	fc043c23          	sd	zero,-40(s0)
    80001cb2:	fd040593          	addi	a1,s0,-48
    80001cb6:	853e                	mv	a0,a5
    80001cb8:	7d9020ef          	jal	80004c90 <kexec>
    80001cbc:	6cbc                	ld	a5,88(s1)
    80001cbe:	fba8                	sd	a0,112(a5)
    if (p->trapframe->a0 == -1) {
    80001cc0:	6cbc                	ld	a5,88(s1)
    80001cc2:	7bb8                	ld	a4,112(a5)
    80001cc4:	57fd                	li	a5,-1
    80001cc6:	02f70d63          	beq	a4,a5,80001d00 <forkret+0x8e>
      panic("exec");
    }
  }

  // return to user space, mimicing usertrap()'s return.
  prepare_return();
    80001cca:	4df000ef          	jal	800029a8 <prepare_return>
  uint64 satp = MAKE_SATP(p->pagetable);
    80001cce:	68a8                	ld	a0,80(s1)
    80001cd0:	8131                	srli	a0,a0,0xc
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    80001cd2:	04000737          	lui	a4,0x4000
    80001cd6:	177d                	addi	a4,a4,-1 # 3ffffff <_entry-0x7c000001>
    80001cd8:	0732                	slli	a4,a4,0xc
    80001cda:	00005797          	auipc	a5,0x5
    80001cde:	3c278793          	addi	a5,a5,962 # 8000709c <userret>
    80001ce2:	00005697          	auipc	a3,0x5
    80001ce6:	31e68693          	addi	a3,a3,798 # 80007000 <_trampoline>
    80001cea:	8f95                	sub	a5,a5,a3
    80001cec:	97ba                	add	a5,a5,a4
  ((void (*)(uint64))trampoline_userret)(satp);
    80001cee:	577d                	li	a4,-1
    80001cf0:	177e                	slli	a4,a4,0x3f
    80001cf2:	8d59                	or	a0,a0,a4
    80001cf4:	9782                	jalr	a5
}
    80001cf6:	70a2                	ld	ra,40(sp)
    80001cf8:	7402                	ld	s0,32(sp)
    80001cfa:	64e2                	ld	s1,24(sp)
    80001cfc:	6145                	addi	sp,sp,48
    80001cfe:	8082                	ret
      panic("exec");
    80001d00:	00006517          	auipc	a0,0x6
    80001d04:	4a050513          	addi	a0,a0,1184 # 800081a0 <etext+0x1a0>
    80001d08:	b4ffe0ef          	jal	80000856 <panic>

0000000080001d0c <allocpid>:
int allocpid() {
    80001d0c:	1101                	addi	sp,sp,-32
    80001d0e:	ec06                	sd	ra,24(sp)
    80001d10:	e822                	sd	s0,16(sp)
    80001d12:	e426                	sd	s1,8(sp)
    80001d14:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80001d16:	00010517          	auipc	a0,0x10
    80001d1a:	41250513          	addi	a0,a0,1042 # 80012128 <pid_lock>
    80001d1e:	804ff0ef          	jal	80000d22 <acquire>
  pid = nextpid;
    80001d22:	00007797          	auipc	a5,0x7
    80001d26:	ba278793          	addi	a5,a5,-1118 # 800088c4 <nextpid>
    80001d2a:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80001d2c:	0014871b          	addiw	a4,s1,1
    80001d30:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001d32:	00010517          	auipc	a0,0x10
    80001d36:	3f650513          	addi	a0,a0,1014 # 80012128 <pid_lock>
    80001d3a:	87cff0ef          	jal	80000db6 <release>
}
    80001d3e:	8526                	mv	a0,s1
    80001d40:	60e2                	ld	ra,24(sp)
    80001d42:	6442                	ld	s0,16(sp)
    80001d44:	64a2                	ld	s1,8(sp)
    80001d46:	6105                	addi	sp,sp,32
    80001d48:	8082                	ret

0000000080001d4a <proc_pagetable>:
pagetable_t proc_pagetable(struct proc *p) {
    80001d4a:	1101                	addi	sp,sp,-32
    80001d4c:	ec06                	sd	ra,24(sp)
    80001d4e:	e822                	sd	s0,16(sp)
    80001d50:	e426                	sd	s1,8(sp)
    80001d52:	e04a                	sd	s2,0(sp)
    80001d54:	1000                	addi	s0,sp,32
    80001d56:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001d58:	e42ff0ef          	jal	8000139a <uvmcreate>
    80001d5c:	84aa                	mv	s1,a0
  if (pagetable == 0)
    80001d5e:	cd05                	beqz	a0,80001d96 <proc_pagetable+0x4c>
  if (mappages(pagetable, TRAMPOLINE, PGSIZE, (uint64)trampoline,
    80001d60:	4729                	li	a4,10
    80001d62:	00005697          	auipc	a3,0x5
    80001d66:	29e68693          	addi	a3,a3,670 # 80007000 <_trampoline>
    80001d6a:	6605                	lui	a2,0x1
    80001d6c:	040005b7          	lui	a1,0x4000
    80001d70:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001d72:	05b2                	slli	a1,a1,0xc
    80001d74:	bf8ff0ef          	jal	8000116c <mappages>
    80001d78:	02054663          	bltz	a0,80001da4 <proc_pagetable+0x5a>
  if (mappages(pagetable, TRAPFRAME, PGSIZE, (uint64)(p->trapframe),
    80001d7c:	4719                	li	a4,6
    80001d7e:	05893683          	ld	a3,88(s2)
    80001d82:	6605                	lui	a2,0x1
    80001d84:	020005b7          	lui	a1,0x2000
    80001d88:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001d8a:	05b6                	slli	a1,a1,0xd
    80001d8c:	8526                	mv	a0,s1
    80001d8e:	bdeff0ef          	jal	8000116c <mappages>
    80001d92:	00054f63          	bltz	a0,80001db0 <proc_pagetable+0x66>
}
    80001d96:	8526                	mv	a0,s1
    80001d98:	60e2                	ld	ra,24(sp)
    80001d9a:	6442                	ld	s0,16(sp)
    80001d9c:	64a2                	ld	s1,8(sp)
    80001d9e:	6902                	ld	s2,0(sp)
    80001da0:	6105                	addi	sp,sp,32
    80001da2:	8082                	ret
    uvmfree(pagetable, 0);
    80001da4:	4581                	li	a1,0
    80001da6:	8526                	mv	a0,s1
    80001da8:	905ff0ef          	jal	800016ac <uvmfree>
    return 0;
    80001dac:	4481                	li	s1,0
    80001dae:	b7e5                	j	80001d96 <proc_pagetable+0x4c>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001db0:	4681                	li	a3,0
    80001db2:	4605                	li	a2,1
    80001db4:	040005b7          	lui	a1,0x4000
    80001db8:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001dba:	05b2                	slli	a1,a1,0xc
    80001dbc:	8526                	mv	a0,s1
    80001dbe:	e02ff0ef          	jal	800013c0 <uvmunmap>
    uvmfree(pagetable, 0);
    80001dc2:	4581                	li	a1,0
    80001dc4:	8526                	mv	a0,s1
    80001dc6:	8e7ff0ef          	jal	800016ac <uvmfree>
    return 0;
    80001dca:	4481                	li	s1,0
    80001dcc:	b7e9                	j	80001d96 <proc_pagetable+0x4c>

0000000080001dce <proc_freepagetable>:
void proc_freepagetable(pagetable_t pagetable, uint64 sz) {
    80001dce:	1101                	addi	sp,sp,-32
    80001dd0:	ec06                	sd	ra,24(sp)
    80001dd2:	e822                	sd	s0,16(sp)
    80001dd4:	e426                	sd	s1,8(sp)
    80001dd6:	e04a                	sd	s2,0(sp)
    80001dd8:	1000                	addi	s0,sp,32
    80001dda:	84aa                	mv	s1,a0
    80001ddc:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001dde:	4681                	li	a3,0
    80001de0:	4605                	li	a2,1
    80001de2:	040005b7          	lui	a1,0x4000
    80001de6:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001de8:	05b2                	slli	a1,a1,0xc
    80001dea:	dd6ff0ef          	jal	800013c0 <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001dee:	4681                	li	a3,0
    80001df0:	4605                	li	a2,1
    80001df2:	020005b7          	lui	a1,0x2000
    80001df6:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001df8:	05b6                	slli	a1,a1,0xd
    80001dfa:	8526                	mv	a0,s1
    80001dfc:	dc4ff0ef          	jal	800013c0 <uvmunmap>
  uvmfree(pagetable, sz);
    80001e00:	85ca                	mv	a1,s2
    80001e02:	8526                	mv	a0,s1
    80001e04:	8a9ff0ef          	jal	800016ac <uvmfree>
}
    80001e08:	60e2                	ld	ra,24(sp)
    80001e0a:	6442                	ld	s0,16(sp)
    80001e0c:	64a2                	ld	s1,8(sp)
    80001e0e:	6902                	ld	s2,0(sp)
    80001e10:	6105                	addi	sp,sp,32
    80001e12:	8082                	ret

0000000080001e14 <freeproc>:
static void freeproc(struct proc *p) {
    80001e14:	1101                	addi	sp,sp,-32
    80001e16:	ec06                	sd	ra,24(sp)
    80001e18:	e822                	sd	s0,16(sp)
    80001e1a:	e426                	sd	s1,8(sp)
    80001e1c:	1000                	addi	s0,sp,32
    80001e1e:	84aa                	mv	s1,a0
  if (p->trapframe)
    80001e20:	6d28                	ld	a0,88(a0)
    80001e22:	c119                	beqz	a0,80001e28 <freeproc+0x14>
    kfree((void *)p->trapframe);
    80001e24:	c6bfe0ef          	jal	80000a8e <kfree>
  p->trapframe = 0;
    80001e28:	0404bc23          	sd	zero,88(s1)
  if (p->pagetable)
    80001e2c:	68a8                	ld	a0,80(s1)
    80001e2e:	c501                	beqz	a0,80001e36 <freeproc+0x22>
    proc_freepagetable(p->pagetable, p->sz);
    80001e30:	64ac                	ld	a1,72(s1)
    80001e32:	f9dff0ef          	jal	80001dce <proc_freepagetable>
  p->pagetable = 0;
    80001e36:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    80001e3a:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    80001e3e:	0204a823          	sw	zero,48(s1)
  p->parent = 0;
    80001e42:	0204bc23          	sd	zero,56(s1)
  p->name[0] = 0;
    80001e46:	14048c23          	sb	zero,344(s1)
  p->chan = 0;
    80001e4a:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    80001e4e:	0204a423          	sw	zero,40(s1)
  p->xstate = 0;
    80001e52:	0204a623          	sw	zero,44(s1)
  p->state = UNUSED;
    80001e56:	0004ac23          	sw	zero,24(s1)
}
    80001e5a:	60e2                	ld	ra,24(sp)
    80001e5c:	6442                	ld	s0,16(sp)
    80001e5e:	64a2                	ld	s1,8(sp)
    80001e60:	6105                	addi	sp,sp,32
    80001e62:	8082                	ret

0000000080001e64 <allocproc>:
static struct proc *allocproc(void) {
    80001e64:	1101                	addi	sp,sp,-32
    80001e66:	ec06                	sd	ra,24(sp)
    80001e68:	e822                	sd	s0,16(sp)
    80001e6a:	e426                	sd	s1,8(sp)
    80001e6c:	e04a                	sd	s2,0(sp)
    80001e6e:	1000                	addi	s0,sp,32
  for (p = proc; p < &proc[NPROC]; p++) {
    80001e70:	00010497          	auipc	s1,0x10
    80001e74:	70048493          	addi	s1,s1,1792 # 80012570 <proc>
    80001e78:	00016917          	auipc	s2,0x16
    80001e7c:	0f890913          	addi	s2,s2,248 # 80017f70 <tickslock>
    acquire(&p->lock);
    80001e80:	8526                	mv	a0,s1
    80001e82:	ea1fe0ef          	jal	80000d22 <acquire>
    if (p->state == UNUSED) {
    80001e86:	4c9c                	lw	a5,24(s1)
    80001e88:	cb91                	beqz	a5,80001e9c <allocproc+0x38>
      release(&p->lock);
    80001e8a:	8526                	mv	a0,s1
    80001e8c:	f2bfe0ef          	jal	80000db6 <release>
  for (p = proc; p < &proc[NPROC]; p++) {
    80001e90:	16848493          	addi	s1,s1,360
    80001e94:	ff2496e3          	bne	s1,s2,80001e80 <allocproc+0x1c>
  return 0;
    80001e98:	4481                	li	s1,0
    80001e9a:	a089                	j	80001edc <allocproc+0x78>
  p->pid = allocpid();
    80001e9c:	e71ff0ef          	jal	80001d0c <allocpid>
    80001ea0:	d888                	sw	a0,48(s1)
  p->state = USED;
    80001ea2:	4785                	li	a5,1
    80001ea4:	cc9c                	sw	a5,24(s1)
  if ((p->trapframe = (struct trapframe *)kalloc()) == 0) {
    80001ea6:	d35fe0ef          	jal	80000bda <kalloc>
    80001eaa:	892a                	mv	s2,a0
    80001eac:	eca8                	sd	a0,88(s1)
    80001eae:	cd15                	beqz	a0,80001eea <allocproc+0x86>
  p->pagetable = proc_pagetable(p);
    80001eb0:	8526                	mv	a0,s1
    80001eb2:	e99ff0ef          	jal	80001d4a <proc_pagetable>
    80001eb6:	892a                	mv	s2,a0
    80001eb8:	e8a8                	sd	a0,80(s1)
  if (p->pagetable == 0) {
    80001eba:	c121                	beqz	a0,80001efa <allocproc+0x96>
  memset(&p->context, 0, sizeof(p->context));
    80001ebc:	07000613          	li	a2,112
    80001ec0:	4581                	li	a1,0
    80001ec2:	06048513          	addi	a0,s1,96
    80001ec6:	f2dfe0ef          	jal	80000df2 <memset>
  p->context.ra = (uint64)forkret;
    80001eca:	00000797          	auipc	a5,0x0
    80001ece:	da878793          	addi	a5,a5,-600 # 80001c72 <forkret>
    80001ed2:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001ed4:	60bc                	ld	a5,64(s1)
    80001ed6:	6705                	lui	a4,0x1
    80001ed8:	97ba                	add	a5,a5,a4
    80001eda:	f4bc                	sd	a5,104(s1)
}
    80001edc:	8526                	mv	a0,s1
    80001ede:	60e2                	ld	ra,24(sp)
    80001ee0:	6442                	ld	s0,16(sp)
    80001ee2:	64a2                	ld	s1,8(sp)
    80001ee4:	6902                	ld	s2,0(sp)
    80001ee6:	6105                	addi	sp,sp,32
    80001ee8:	8082                	ret
    freeproc(p);
    80001eea:	8526                	mv	a0,s1
    80001eec:	f29ff0ef          	jal	80001e14 <freeproc>
    release(&p->lock);
    80001ef0:	8526                	mv	a0,s1
    80001ef2:	ec5fe0ef          	jal	80000db6 <release>
    return 0;
    80001ef6:	84ca                	mv	s1,s2
    80001ef8:	b7d5                	j	80001edc <allocproc+0x78>
    freeproc(p);
    80001efa:	8526                	mv	a0,s1
    80001efc:	f19ff0ef          	jal	80001e14 <freeproc>
    release(&p->lock);
    80001f00:	8526                	mv	a0,s1
    80001f02:	eb5fe0ef          	jal	80000db6 <release>
    return 0;
    80001f06:	84ca                	mv	s1,s2
    80001f08:	bfd1                	j	80001edc <allocproc+0x78>

0000000080001f0a <userinit>:
void userinit(void) {
    80001f0a:	1101                	addi	sp,sp,-32
    80001f0c:	ec06                	sd	ra,24(sp)
    80001f0e:	e822                	sd	s0,16(sp)
    80001f10:	e426                	sd	s1,8(sp)
    80001f12:	1000                	addi	s0,sp,32
  p = allocproc();
    80001f14:	f51ff0ef          	jal	80001e64 <allocproc>
    80001f18:	84aa                	mv	s1,a0
  initproc = p;
    80001f1a:	00007797          	auipc	a5,0x7
    80001f1e:	10a7b723          	sd	a0,270(a5) # 80009028 <initproc>
  p->cwd = namei("/");
    80001f22:	00006517          	auipc	a0,0x6
    80001f26:	28650513          	addi	a0,a0,646 # 800081a8 <etext+0x1a8>
    80001f2a:	118020ef          	jal	80004042 <namei>
    80001f2e:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    80001f32:	478d                	li	a5,3
    80001f34:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001f36:	8526                	mv	a0,s1
    80001f38:	e7ffe0ef          	jal	80000db6 <release>
}
    80001f3c:	60e2                	ld	ra,24(sp)
    80001f3e:	6442                	ld	s0,16(sp)
    80001f40:	64a2                	ld	s1,8(sp)
    80001f42:	6105                	addi	sp,sp,32
    80001f44:	8082                	ret

0000000080001f46 <growproc>:
int growproc(int n) {
    80001f46:	7135                	addi	sp,sp,-160
    80001f48:	ed06                	sd	ra,152(sp)
    80001f4a:	e922                	sd	s0,144(sp)
    80001f4c:	e526                	sd	s1,136(sp)
    80001f4e:	e14a                	sd	s2,128(sp)
    80001f50:	fcce                	sd	s3,120(sp)
    80001f52:	1100                	addi	s0,sp,160
    80001f54:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80001f56:	cebff0ef          	jal	80001c40 <myproc>
    80001f5a:	89aa                	mv	s3,a0
  sz = p->sz;
    80001f5c:	04853903          	ld	s2,72(a0)
  if (n > 0) {
    80001f60:	02905b63          	blez	s1,80001f96 <growproc+0x50>
    if (sz + n > TRAPFRAME) {
    80001f64:	01248633          	add	a2,s1,s2
    80001f68:	020007b7          	lui	a5,0x2000
    80001f6c:	17fd                	addi	a5,a5,-1 # 1ffffff <_entry-0x7e000001>
    80001f6e:	07b6                	slli	a5,a5,0xd
    80001f70:	08c7ee63          	bltu	a5,a2,8000200c <growproc+0xc6>
    if ((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0) {
    80001f74:	4691                	li	a3,4
    80001f76:	85ca                	mv	a1,s2
    80001f78:	6928                	ld	a0,80(a0)
    80001f7a:	daaff0ef          	jal	80001524 <uvmalloc>
    80001f7e:	892a                	mv	s2,a0
    80001f80:	c941                	beqz	a0,80002010 <growproc+0xca>
  p->sz = sz;
    80001f82:	0529b423          	sd	s2,72(s3)
  return 0;
    80001f86:	4501                	li	a0,0
}
    80001f88:	60ea                	ld	ra,152(sp)
    80001f8a:	644a                	ld	s0,144(sp)
    80001f8c:	64aa                	ld	s1,136(sp)
    80001f8e:	690a                	ld	s2,128(sp)
    80001f90:	79e6                	ld	s3,120(sp)
    80001f92:	610d                	addi	sp,sp,160
    80001f94:	8082                	ret
  } else if (n < 0) {
    80001f96:	fe04d6e3          	bgez	s1,80001f82 <growproc+0x3c>
  memset(&e, 0, sizeof(e));
    80001f9a:	06800613          	li	a2,104
    80001f9e:	4581                	li	a1,0
    80001fa0:	f6840513          	addi	a0,s0,-152
    80001fa4:	e4ffe0ef          	jal	80000df2 <memset>
  e.ticks  = ticks;
    80001fa8:	00007797          	auipc	a5,0x7
    80001fac:	0887a783          	lw	a5,136(a5) # 80009030 <ticks>
    80001fb0:	f6f42823          	sw	a5,-144(s0)
    80001fb4:	8792                	mv	a5,tp
  int id = r_tp();
    80001fb6:	f6f42a23          	sw	a5,-140(s0)
  e.type   = MEM_SHRINK;
    80001fba:	4789                	li	a5,2
    80001fbc:	f6f42c23          	sw	a5,-136(s0)
  e.pid    = p->pid;
    80001fc0:	0309a783          	lw	a5,48(s3)
    80001fc4:	f6f42e23          	sw	a5,-132(s0)
  e.state  = p->state;
    80001fc8:	0189a783          	lw	a5,24(s3)
    80001fcc:	f8f42023          	sw	a5,-128(s0)
  e.oldsz  = sz;
    80001fd0:	fb243423          	sd	s2,-88(s0)
  e.newsz  = sz + n;
    80001fd4:	94ca                	add	s1,s1,s2
    80001fd6:	fa943823          	sd	s1,-80(s0)
  e.source = SRC_UVMDEALLOC;
    80001fda:	4799                	li	a5,6
    80001fdc:	fcf42223          	sw	a5,-60(s0)
  e.kind   = PAGE_USER;
    80001fe0:	4785                	li	a5,1
    80001fe2:	fcf42423          	sw	a5,-56(s0)
  safestrcpy(e.name, p->name, MEM_NM);
    80001fe6:	4641                	li	a2,16
    80001fe8:	15898593          	addi	a1,s3,344
    80001fec:	f8440513          	addi	a0,s0,-124
    80001ff0:	f57fe0ef          	jal	80000f46 <safestrcpy>
  memlog_push(&e);
    80001ff4:	f6840513          	addi	a0,s0,-152
    80001ff8:	504040ef          	jal	800064fc <memlog_push>
  sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001ffc:	8626                	mv	a2,s1
    80001ffe:	85ca                	mv	a1,s2
    80002000:	0509b503          	ld	a0,80(s3)
    80002004:	cdcff0ef          	jal	800014e0 <uvmdealloc>
    80002008:	892a                	mv	s2,a0
    8000200a:	bfa5                	j	80001f82 <growproc+0x3c>
      return -1;
    8000200c:	557d                	li	a0,-1
    8000200e:	bfad                	j	80001f88 <growproc+0x42>
      return -1;
    80002010:	557d                	li	a0,-1
    80002012:	bf9d                	j	80001f88 <growproc+0x42>

0000000080002014 <kfork>:
int kfork(void) {
    80002014:	7139                	addi	sp,sp,-64
    80002016:	fc06                	sd	ra,56(sp)
    80002018:	f822                	sd	s0,48(sp)
    8000201a:	f426                	sd	s1,40(sp)
    8000201c:	e456                	sd	s5,8(sp)
    8000201e:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    80002020:	c21ff0ef          	jal	80001c40 <myproc>
    80002024:	8aaa                	mv	s5,a0
  if ((np = allocproc()) == 0) {
    80002026:	e3fff0ef          	jal	80001e64 <allocproc>
    8000202a:	0e050a63          	beqz	a0,8000211e <kfork+0x10a>
    8000202e:	e852                	sd	s4,16(sp)
    80002030:	8a2a                	mv	s4,a0
  if (uvmcopy(p->pagetable, np->pagetable, p->sz) < 0) {
    80002032:	048ab603          	ld	a2,72(s5)
    80002036:	692c                	ld	a1,80(a0)
    80002038:	050ab503          	ld	a0,80(s5)
    8000203c:	ea2ff0ef          	jal	800016de <uvmcopy>
    80002040:	04054863          	bltz	a0,80002090 <kfork+0x7c>
    80002044:	f04a                	sd	s2,32(sp)
    80002046:	ec4e                	sd	s3,24(sp)
  np->sz = p->sz;
    80002048:	048ab783          	ld	a5,72(s5)
    8000204c:	04fa3423          	sd	a5,72(s4)
  *(np->trapframe) = *(p->trapframe);
    80002050:	058ab683          	ld	a3,88(s5)
    80002054:	87b6                	mv	a5,a3
    80002056:	058a3703          	ld	a4,88(s4)
    8000205a:	12068693          	addi	a3,a3,288
    8000205e:	6388                	ld	a0,0(a5)
    80002060:	678c                	ld	a1,8(a5)
    80002062:	6b90                	ld	a2,16(a5)
    80002064:	e308                	sd	a0,0(a4)
    80002066:	e70c                	sd	a1,8(a4)
    80002068:	eb10                	sd	a2,16(a4)
    8000206a:	6f90                	ld	a2,24(a5)
    8000206c:	ef10                	sd	a2,24(a4)
    8000206e:	02078793          	addi	a5,a5,32
    80002072:	02070713          	addi	a4,a4,32 # 1020 <_entry-0x7fffefe0>
    80002076:	fed794e3          	bne	a5,a3,8000205e <kfork+0x4a>
  np->trapframe->a0 = 0;
    8000207a:	058a3783          	ld	a5,88(s4)
    8000207e:	0607b823          	sd	zero,112(a5)
  for (i = 0; i < NOFILE; i++)
    80002082:	0d0a8493          	addi	s1,s5,208
    80002086:	0d0a0913          	addi	s2,s4,208
    8000208a:	150a8993          	addi	s3,s5,336
    8000208e:	a831                	j	800020aa <kfork+0x96>
    freeproc(np);
    80002090:	8552                	mv	a0,s4
    80002092:	d83ff0ef          	jal	80001e14 <freeproc>
    release(&np->lock);
    80002096:	8552                	mv	a0,s4
    80002098:	d1ffe0ef          	jal	80000db6 <release>
    return -1;
    8000209c:	54fd                	li	s1,-1
    8000209e:	6a42                	ld	s4,16(sp)
    800020a0:	a885                	j	80002110 <kfork+0xfc>
  for (i = 0; i < NOFILE; i++)
    800020a2:	04a1                	addi	s1,s1,8
    800020a4:	0921                	addi	s2,s2,8
    800020a6:	01348963          	beq	s1,s3,800020b8 <kfork+0xa4>
    if (p->ofile[i])
    800020aa:	6088                	ld	a0,0(s1)
    800020ac:	d97d                	beqz	a0,800020a2 <kfork+0x8e>
      np->ofile[i] = filedup(p->ofile[i]);
    800020ae:	550020ef          	jal	800045fe <filedup>
    800020b2:	00a93023          	sd	a0,0(s2)
    800020b6:	b7f5                	j	800020a2 <kfork+0x8e>
  np->cwd = idup(p->cwd);
    800020b8:	150ab503          	ld	a0,336(s5)
    800020bc:	722010ef          	jal	800037de <idup>
    800020c0:	14aa3823          	sd	a0,336(s4)
  safestrcpy(np->name, p->name, sizeof(p->name));
    800020c4:	4641                	li	a2,16
    800020c6:	158a8593          	addi	a1,s5,344
    800020ca:	158a0513          	addi	a0,s4,344
    800020ce:	e79fe0ef          	jal	80000f46 <safestrcpy>
  pid = np->pid;
    800020d2:	030a2483          	lw	s1,48(s4)
  release(&np->lock);
    800020d6:	8552                	mv	a0,s4
    800020d8:	cdffe0ef          	jal	80000db6 <release>
  acquire(&wait_lock);
    800020dc:	00010517          	auipc	a0,0x10
    800020e0:	06450513          	addi	a0,a0,100 # 80012140 <wait_lock>
    800020e4:	c3ffe0ef          	jal	80000d22 <acquire>
  np->parent = p;
    800020e8:	035a3c23          	sd	s5,56(s4)
  release(&wait_lock);
    800020ec:	00010517          	auipc	a0,0x10
    800020f0:	05450513          	addi	a0,a0,84 # 80012140 <wait_lock>
    800020f4:	cc3fe0ef          	jal	80000db6 <release>
  acquire(&np->lock);
    800020f8:	8552                	mv	a0,s4
    800020fa:	c29fe0ef          	jal	80000d22 <acquire>
  np->state = RUNNABLE;
    800020fe:	478d                	li	a5,3
    80002100:	00fa2c23          	sw	a5,24(s4)
  release(&np->lock);
    80002104:	8552                	mv	a0,s4
    80002106:	cb1fe0ef          	jal	80000db6 <release>
  return pid;
    8000210a:	7902                	ld	s2,32(sp)
    8000210c:	69e2                	ld	s3,24(sp)
    8000210e:	6a42                	ld	s4,16(sp)
}
    80002110:	8526                	mv	a0,s1
    80002112:	70e2                	ld	ra,56(sp)
    80002114:	7442                	ld	s0,48(sp)
    80002116:	74a2                	ld	s1,40(sp)
    80002118:	6aa2                	ld	s5,8(sp)
    8000211a:	6121                	addi	sp,sp,64
    8000211c:	8082                	ret
    return -1;
    8000211e:	54fd                	li	s1,-1
    80002120:	bfc5                	j	80002110 <kfork+0xfc>

0000000080002122 <scheduler>:
void scheduler(void) {
    80002122:	7171                	addi	sp,sp,-176
    80002124:	f506                	sd	ra,168(sp)
    80002126:	f122                	sd	s0,160(sp)
    80002128:	ed26                	sd	s1,152(sp)
    8000212a:	e94a                	sd	s2,144(sp)
    8000212c:	e54e                	sd	s3,136(sp)
    8000212e:	e152                	sd	s4,128(sp)
    80002130:	fcd6                	sd	s5,120(sp)
    80002132:	f8da                	sd	s6,112(sp)
    80002134:	f4de                	sd	s7,104(sp)
    80002136:	f0e2                	sd	s8,96(sp)
    80002138:	ece6                	sd	s9,88(sp)
    8000213a:	e8ea                	sd	s10,80(sp)
    8000213c:	1900                	addi	s0,sp,176
    8000213e:	8492                	mv	s1,tp
  int id = r_tp();
    80002140:	2481                	sext.w	s1,s1
    80002142:	8792                	mv	a5,tp
    if(cpuid() == 0){
    80002144:	2781                	sext.w	a5,a5
    80002146:	c79d                	beqz	a5,80002174 <scheduler+0x52>
  c->proc = 0;
    80002148:	00749b93          	slli	s7,s1,0x7
    8000214c:	00010797          	auipc	a5,0x10
    80002150:	fdc78793          	addi	a5,a5,-36 # 80012128 <pid_lock>
    80002154:	97de                	add	a5,a5,s7
    80002156:	0407b423          	sd	zero,72(a5)
        swtch(&c->context, &p->context);
    8000215a:	00010797          	auipc	a5,0x10
    8000215e:	01e78793          	addi	a5,a5,30 # 80012178 <cpus+0x8>
    80002162:	9bbe                	add	s7,s7,a5
        p->state = RUNNING;
    80002164:	4b11                	li	s6,4
        c->proc = p;
    80002166:	049e                	slli	s1,s1,0x7
    80002168:	00010a97          	auipc	s5,0x10
    8000216c:	fc0a8a93          	addi	s5,s5,-64 # 80012128 <pid_lock>
    80002170:	9aa6                	add	s5,s5,s1
    80002172:	a2d5                	j	80002356 <scheduler+0x234>
      acquire(&schedinfo_lock);
    80002174:	00010517          	auipc	a0,0x10
    80002178:	fe450513          	addi	a0,a0,-28 # 80012158 <schedinfo_lock>
    8000217c:	ba7fe0ef          	jal	80000d22 <acquire>
      if(sched_info_logged == 0){
    80002180:	00007797          	auipc	a5,0x7
    80002184:	ea07a783          	lw	a5,-352(a5) # 80009020 <sched_info_logged>
    80002188:	cb81                	beqz	a5,80002198 <scheduler+0x76>
      release(&schedinfo_lock);
    8000218a:	00010517          	auipc	a0,0x10
    8000218e:	fce50513          	addi	a0,a0,-50 # 80012158 <schedinfo_lock>
    80002192:	c25fe0ef          	jal	80000db6 <release>
    80002196:	bf4d                	j	80002148 <scheduler+0x26>
        sched_info_logged = 1;
    80002198:	4905                	li	s2,1
    8000219a:	00007797          	auipc	a5,0x7
    8000219e:	e927a323          	sw	s2,-378(a5) # 80009020 <sched_info_logged>
        memset(&e, 0, sizeof(e));
    800021a2:	f5840993          	addi	s3,s0,-168
    800021a6:	04400613          	li	a2,68
    800021aa:	4581                	li	a1,0
    800021ac:	854e                	mv	a0,s3
    800021ae:	c45fe0ef          	jal	80000df2 <memset>
        e.ticks = ticks;
    800021b2:	00007797          	auipc	a5,0x7
    800021b6:	e7e7a783          	lw	a5,-386(a5) # 80009030 <ticks>
    800021ba:	f4f42e23          	sw	a5,-164(s0)
        e.event_type = SCHED_EV_INFO;
    800021be:	f7242023          	sw	s2,-160(s0)
        safestrcpy(e.scheduler_name, "RR", sizeof(e.scheduler_name));
    800021c2:	4641                	li	a2,16
    800021c4:	00006597          	auipc	a1,0x6
    800021c8:	fec58593          	addi	a1,a1,-20 # 800081b0 <etext+0x1b0>
    800021cc:	f6440513          	addi	a0,s0,-156
    800021d0:	d77fe0ef          	jal	80000f46 <safestrcpy>
        e.num_cpus = 3;
    800021d4:	478d                	li	a5,3
    800021d6:	f6f42a23          	sw	a5,-140(s0)
        e.time_slice = 1;
    800021da:	f7242c23          	sw	s2,-136(s0)
        schedlog_emit(&e);
    800021de:	854e                	mv	a0,s3
    800021e0:	57e040ef          	jal	8000675e <schedlog_emit>
    800021e4:	b75d                	j	8000218a <scheduler+0x68>
        if(strncmp(p->name, "schedexport", 16) != 0){
    800021e6:	158c8c13          	addi	s8,s9,344
    800021ea:	864e                	mv	a2,s3
    800021ec:	85d2                	mv	a1,s4
    800021ee:	8562                	mv	a0,s8
    800021f0:	cd7fe0ef          	jal	80000ec6 <strncmp>
    800021f4:	e945                	bnez	a0,800022a4 <scheduler+0x182>
        swtch(&c->context, &p->context);
    800021f6:	060c8593          	addi	a1,s9,96
    800021fa:	855e                	mv	a0,s7
    800021fc:	702000ef          	jal	800028fe <swtch>
        if(strncmp(p->name, "schedexport", 16) != 0){
    80002200:	864e                	mv	a2,s3
    80002202:	85d2                	mv	a1,s4
    80002204:	8562                	mv	a0,s8
    80002206:	cc1fe0ef          	jal	80000ec6 <strncmp>
    8000220a:	0e051163          	bnez	a0,800022ec <scheduler+0x1ca>
        c->proc = 0;
    8000220e:	040ab423          	sd	zero,72(s5)
        found = 1;
    80002212:	4c05                	li	s8,1
      release(&p->lock);
    80002214:	8526                	mv	a0,s1
    80002216:	ba1fe0ef          	jal	80000db6 <release>
    for (p = proc; p < &proc[NPROC]; p++) {
    8000221a:	16848493          	addi	s1,s1,360
    8000221e:	00016797          	auipc	a5,0x16
    80002222:	d5278793          	addi	a5,a5,-686 # 80017f70 <tickslock>
    80002226:	12f48463          	beq	s1,a5,8000234e <scheduler+0x22c>
      acquire(&p->lock);
    8000222a:	8526                	mv	a0,s1
    8000222c:	af7fe0ef          	jal	80000d22 <acquire>
      if (p->state == RUNNABLE) {
    80002230:	4c9c                	lw	a5,24(s1)
    80002232:	ff2791e3          	bne	a5,s2,80002214 <scheduler+0xf2>
    80002236:	8ca6                	mv	s9,s1
        p->state = RUNNING;
    80002238:	0164ac23          	sw	s6,24(s1)
        c->proc = p;
    8000223c:	049ab423          	sd	s1,72(s5)
        cslog_run_start(p);
    80002240:	8526                	mv	a0,s1
    80002242:	663030ef          	jal	800060a4 <cslog_run_start>
    80002246:	8792                	mv	a5,tp
        if (cpuid() == 0 && sched_info_logged == 0) {
    80002248:	2781                	sext.w	a5,a5
    8000224a:	ffd1                	bnez	a5,800021e6 <scheduler+0xc4>
    8000224c:	00007797          	auipc	a5,0x7
    80002250:	dd47a783          	lw	a5,-556(a5) # 80009020 <sched_info_logged>
    80002254:	fbc9                	bnez	a5,800021e6 <scheduler+0xc4>
          sched_info_logged = 1;
    80002256:	4c05                	li	s8,1
    80002258:	00007797          	auipc	a5,0x7
    8000225c:	dd87a423          	sw	s8,-568(a5) # 80009020 <sched_info_logged>
          memset(&e, 0, sizeof(e));
    80002260:	f5840d13          	addi	s10,s0,-168
    80002264:	04400613          	li	a2,68
    80002268:	4581                	li	a1,0
    8000226a:	856a                	mv	a0,s10
    8000226c:	b87fe0ef          	jal	80000df2 <memset>
          e.ticks = ticks;
    80002270:	00007797          	auipc	a5,0x7
    80002274:	dc07a783          	lw	a5,-576(a5) # 80009030 <ticks>
    80002278:	f4f42e23          	sw	a5,-164(s0)
          e.event_type = SCHED_EV_INFO;
    8000227c:	f7842023          	sw	s8,-160(s0)
          safestrcpy(e.scheduler_name, "RR", sizeof(e.scheduler_name));
    80002280:	864e                	mv	a2,s3
    80002282:	00006597          	auipc	a1,0x6
    80002286:	f2e58593          	addi	a1,a1,-210 # 800081b0 <etext+0x1b0>
    8000228a:	f6440513          	addi	a0,s0,-156
    8000228e:	cb9fe0ef          	jal	80000f46 <safestrcpy>
          e.num_cpus = NCPU;
    80002292:	47a1                	li	a5,8
    80002294:	f6f42a23          	sw	a5,-140(s0)
          e.time_slice = 1;
    80002298:	f7842c23          	sw	s8,-136(s0)
          schedlog_emit(&e);
    8000229c:	856a                	mv	a0,s10
    8000229e:	4c0040ef          	jal	8000675e <schedlog_emit>
    800022a2:	b791                	j	800021e6 <scheduler+0xc4>
          memset(&e, 0, sizeof(e));
    800022a4:	f5840d13          	addi	s10,s0,-168
    800022a8:	04400613          	li	a2,68
    800022ac:	4581                	li	a1,0
    800022ae:	856a                	mv	a0,s10
    800022b0:	b43fe0ef          	jal	80000df2 <memset>
          e.ticks = ticks;
    800022b4:	00007797          	auipc	a5,0x7
    800022b8:	d7c7a783          	lw	a5,-644(a5) # 80009030 <ticks>
    800022bc:	f4f42e23          	sw	a5,-164(s0)
          e.event_type = SCHED_EV_ON_CPU;
    800022c0:	4789                	li	a5,2
    800022c2:	f6f42023          	sw	a5,-160(s0)
    800022c6:	8792                	mv	a5,tp
  int id = r_tp();
    800022c8:	f6f42e23          	sw	a5,-132(s0)
          e.pid = p->pid;
    800022cc:	589c                	lw	a5,48(s1)
    800022ce:	f8f42023          	sw	a5,-128(s0)
          safestrcpy(e.name, p->name, sizeof(e.name));
    800022d2:	864e                	mv	a2,s3
    800022d4:	85e2                	mv	a1,s8
    800022d6:	f8440513          	addi	a0,s0,-124
    800022da:	c6dfe0ef          	jal	80000f46 <safestrcpy>
          e.state = p->state;
    800022de:	4c9c                	lw	a5,24(s1)
    800022e0:	f8f42a23          	sw	a5,-108(s0)
          schedlog_emit(&e);
    800022e4:	856a                	mv	a0,s10
    800022e6:	478040ef          	jal	8000675e <schedlog_emit>
    800022ea:	b731                	j	800021f6 <scheduler+0xd4>
          memset(&e2, 0, sizeof(e2));
    800022ec:	04400613          	li	a2,68
    800022f0:	4581                	li	a1,0
    800022f2:	f5840513          	addi	a0,s0,-168
    800022f6:	afdfe0ef          	jal	80000df2 <memset>
          e2.ticks = ticks;
    800022fa:	00007797          	auipc	a5,0x7
    800022fe:	d367a783          	lw	a5,-714(a5) # 80009030 <ticks>
    80002302:	f4f42e23          	sw	a5,-164(s0)
          e2.event_type = SCHED_EV_OFF_CPU;
    80002306:	f7242023          	sw	s2,-160(s0)
    8000230a:	8792                	mv	a5,tp
  int id = r_tp();
    8000230c:	f6f42e23          	sw	a5,-132(s0)
          e2.pid = p->pid;
    80002310:	589c                	lw	a5,48(s1)
    80002312:	f8f42023          	sw	a5,-128(s0)
          safestrcpy(e2.name, p->name, sizeof(e2.name));
    80002316:	864e                	mv	a2,s3
    80002318:	85e2                	mv	a1,s8
    8000231a:	f8440513          	addi	a0,s0,-124
    8000231e:	c29fe0ef          	jal	80000f46 <safestrcpy>
          e2.state = p->state;
    80002322:	4c9c                	lw	a5,24(s1)
          if(p->state == SLEEPING)
    80002324:	4689                	li	a3,2
    80002326:	8736                	mv	a4,a3
    80002328:	00d78a63          	beq	a5,a3,8000233c <scheduler+0x21a>
          else if(p->state == ZOMBIE)
    8000232c:	4695                	li	a3,5
    8000232e:	875a                	mv	a4,s6
    80002330:	00d78663          	beq	a5,a3,8000233c <scheduler+0x21a>
          else if(p->state == RUNNABLE)
    80002334:	874a                	mv	a4,s2
    80002336:	01278363          	beq	a5,s2,8000233c <scheduler+0x21a>
    8000233a:	4701                	li	a4,0
          e2.state = p->state;
    8000233c:	f8f42a23          	sw	a5,-108(s0)
            e2.reason = SCHED_OFF_SLEEP;
    80002340:	f8e42c23          	sw	a4,-104(s0)
          schedlog_emit(&e2);
    80002344:	f5840513          	addi	a0,s0,-168
    80002348:	416040ef          	jal	8000675e <schedlog_emit>
    8000234c:	b5c9                	j	8000220e <scheduler+0xec>
    if (found == 0) {
    8000234e:	000c1563          	bnez	s8,80002358 <scheduler+0x236>
      asm volatile("wfi");
    80002352:	10500073          	wfi
      if (p->state == RUNNABLE) {
    80002356:	490d                	li	s2,3
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002358:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    8000235c:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002360:	10079073          	csrw	sstatus,a5
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002364:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80002368:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000236a:	10079073          	csrw	sstatus,a5
    int found = 0;
    8000236e:	4c01                	li	s8,0
    for (p = proc; p < &proc[NPROC]; p++) {
    80002370:	00010497          	auipc	s1,0x10
    80002374:	20048493          	addi	s1,s1,512 # 80012570 <proc>
        if(strncmp(p->name, "schedexport", 16) != 0){
    80002378:	49c1                	li	s3,16
    8000237a:	00006a17          	auipc	s4,0x6
    8000237e:	e3ea0a13          	addi	s4,s4,-450 # 800081b8 <etext+0x1b8>
    80002382:	b565                	j	8000222a <scheduler+0x108>

0000000080002384 <sched>:
void sched(void) {
    80002384:	7179                	addi	sp,sp,-48
    80002386:	f406                	sd	ra,40(sp)
    80002388:	f022                	sd	s0,32(sp)
    8000238a:	ec26                	sd	s1,24(sp)
    8000238c:	e84a                	sd	s2,16(sp)
    8000238e:	e44e                	sd	s3,8(sp)
    80002390:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80002392:	8afff0ef          	jal	80001c40 <myproc>
    80002396:	84aa                	mv	s1,a0
  if (!holding(&p->lock))
    80002398:	91bfe0ef          	jal	80000cb2 <holding>
    8000239c:	c935                	beqz	a0,80002410 <sched+0x8c>
  asm volatile("mv %0, tp" : "=r" (x) );
    8000239e:	8792                	mv	a5,tp
  if (mycpu()->noff != 1)
    800023a0:	2781                	sext.w	a5,a5
    800023a2:	079e                	slli	a5,a5,0x7
    800023a4:	00010717          	auipc	a4,0x10
    800023a8:	d8470713          	addi	a4,a4,-636 # 80012128 <pid_lock>
    800023ac:	97ba                	add	a5,a5,a4
    800023ae:	0c07a703          	lw	a4,192(a5)
    800023b2:	4785                	li	a5,1
    800023b4:	06f71463          	bne	a4,a5,8000241c <sched+0x98>
  if (p->state == RUNNING)
    800023b8:	4c98                	lw	a4,24(s1)
    800023ba:	4791                	li	a5,4
    800023bc:	06f70663          	beq	a4,a5,80002428 <sched+0xa4>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800023c0:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    800023c4:	8b89                	andi	a5,a5,2
  if (intr_get())
    800023c6:	e7bd                	bnez	a5,80002434 <sched+0xb0>
  asm volatile("mv %0, tp" : "=r" (x) );
    800023c8:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    800023ca:	00010917          	auipc	s2,0x10
    800023ce:	d5e90913          	addi	s2,s2,-674 # 80012128 <pid_lock>
    800023d2:	2781                	sext.w	a5,a5
    800023d4:	079e                	slli	a5,a5,0x7
    800023d6:	97ca                	add	a5,a5,s2
    800023d8:	0c47a983          	lw	s3,196(a5)
    800023dc:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    800023de:	2781                	sext.w	a5,a5
    800023e0:	079e                	slli	a5,a5,0x7
    800023e2:	07a1                	addi	a5,a5,8
    800023e4:	00010597          	auipc	a1,0x10
    800023e8:	d8c58593          	addi	a1,a1,-628 # 80012170 <cpus>
    800023ec:	95be                	add	a1,a1,a5
    800023ee:	06048513          	addi	a0,s1,96
    800023f2:	50c000ef          	jal	800028fe <swtch>
    800023f6:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    800023f8:	2781                	sext.w	a5,a5
    800023fa:	079e                	slli	a5,a5,0x7
    800023fc:	993e                	add	s2,s2,a5
    800023fe:	0d392223          	sw	s3,196(s2)
}
    80002402:	70a2                	ld	ra,40(sp)
    80002404:	7402                	ld	s0,32(sp)
    80002406:	64e2                	ld	s1,24(sp)
    80002408:	6942                	ld	s2,16(sp)
    8000240a:	69a2                	ld	s3,8(sp)
    8000240c:	6145                	addi	sp,sp,48
    8000240e:	8082                	ret
    panic("sched p->lock");
    80002410:	00006517          	auipc	a0,0x6
    80002414:	db850513          	addi	a0,a0,-584 # 800081c8 <etext+0x1c8>
    80002418:	c3efe0ef          	jal	80000856 <panic>
    panic("sched locks");
    8000241c:	00006517          	auipc	a0,0x6
    80002420:	dbc50513          	addi	a0,a0,-580 # 800081d8 <etext+0x1d8>
    80002424:	c32fe0ef          	jal	80000856 <panic>
    panic("sched RUNNING");
    80002428:	00006517          	auipc	a0,0x6
    8000242c:	dc050513          	addi	a0,a0,-576 # 800081e8 <etext+0x1e8>
    80002430:	c26fe0ef          	jal	80000856 <panic>
    panic("sched interruptible");
    80002434:	00006517          	auipc	a0,0x6
    80002438:	dc450513          	addi	a0,a0,-572 # 800081f8 <etext+0x1f8>
    8000243c:	c1afe0ef          	jal	80000856 <panic>

0000000080002440 <yield>:
void yield(void) {
    80002440:	1101                	addi	sp,sp,-32
    80002442:	ec06                	sd	ra,24(sp)
    80002444:	e822                	sd	s0,16(sp)
    80002446:	e426                	sd	s1,8(sp)
    80002448:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    8000244a:	ff6ff0ef          	jal	80001c40 <myproc>
    8000244e:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80002450:	8d3fe0ef          	jal	80000d22 <acquire>
  p->state = RUNNABLE;
    80002454:	478d                	li	a5,3
    80002456:	cc9c                	sw	a5,24(s1)
  sched();
    80002458:	f2dff0ef          	jal	80002384 <sched>
  release(&p->lock);
    8000245c:	8526                	mv	a0,s1
    8000245e:	959fe0ef          	jal	80000db6 <release>
}
    80002462:	60e2                	ld	ra,24(sp)
    80002464:	6442                	ld	s0,16(sp)
    80002466:	64a2                	ld	s1,8(sp)
    80002468:	6105                	addi	sp,sp,32
    8000246a:	8082                	ret

000000008000246c <sleep>:

// Sleep on channel chan, releasing condition lock lk.
// Re-acquires lk when awakened.
void sleep(void *chan, struct spinlock *lk) {
    8000246c:	7179                	addi	sp,sp,-48
    8000246e:	f406                	sd	ra,40(sp)
    80002470:	f022                	sd	s0,32(sp)
    80002472:	ec26                	sd	s1,24(sp)
    80002474:	e84a                	sd	s2,16(sp)
    80002476:	e44e                	sd	s3,8(sp)
    80002478:	1800                	addi	s0,sp,48
    8000247a:	89aa                	mv	s3,a0
    8000247c:	892e                	mv	s2,a1
  struct proc *p = myproc();
    8000247e:	fc2ff0ef          	jal	80001c40 <myproc>
    80002482:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock); // DOC: sleeplock1
    80002484:	89ffe0ef          	jal	80000d22 <acquire>
  release(lk);
    80002488:	854a                	mv	a0,s2
    8000248a:	92dfe0ef          	jal	80000db6 <release>

  // Go to sleep.
  p->chan = chan;
    8000248e:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    80002492:	4789                	li	a5,2
    80002494:	cc9c                	sw	a5,24(s1)

  sched();
    80002496:	eefff0ef          	jal	80002384 <sched>

  // Tidy up.
  p->chan = 0;
    8000249a:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    8000249e:	8526                	mv	a0,s1
    800024a0:	917fe0ef          	jal	80000db6 <release>
  acquire(lk);
    800024a4:	854a                	mv	a0,s2
    800024a6:	87dfe0ef          	jal	80000d22 <acquire>
}
    800024aa:	70a2                	ld	ra,40(sp)
    800024ac:	7402                	ld	s0,32(sp)
    800024ae:	64e2                	ld	s1,24(sp)
    800024b0:	6942                	ld	s2,16(sp)
    800024b2:	69a2                	ld	s3,8(sp)
    800024b4:	6145                	addi	sp,sp,48
    800024b6:	8082                	ret

00000000800024b8 <wakeup>:

// Wake up all processes sleeping on channel chan.
// Caller should hold the condition lock.
void wakeup(void *chan) {
    800024b8:	7139                	addi	sp,sp,-64
    800024ba:	fc06                	sd	ra,56(sp)
    800024bc:	f822                	sd	s0,48(sp)
    800024be:	f426                	sd	s1,40(sp)
    800024c0:	f04a                	sd	s2,32(sp)
    800024c2:	ec4e                	sd	s3,24(sp)
    800024c4:	e852                	sd	s4,16(sp)
    800024c6:	e456                	sd	s5,8(sp)
    800024c8:	0080                	addi	s0,sp,64
    800024ca:	8a2a                	mv	s4,a0
  struct proc *p;

  for (p = proc; p < &proc[NPROC]; p++) {
    800024cc:	00010497          	auipc	s1,0x10
    800024d0:	0a448493          	addi	s1,s1,164 # 80012570 <proc>
    if (p != myproc()) {
      acquire(&p->lock);
      if (p->state == SLEEPING && p->chan == chan) {
    800024d4:	4989                	li	s3,2
        p->state = RUNNABLE;
    800024d6:	4a8d                	li	s5,3
  for (p = proc; p < &proc[NPROC]; p++) {
    800024d8:	00016917          	auipc	s2,0x16
    800024dc:	a9890913          	addi	s2,s2,-1384 # 80017f70 <tickslock>
    800024e0:	a801                	j	800024f0 <wakeup+0x38>
      }
      release(&p->lock);
    800024e2:	8526                	mv	a0,s1
    800024e4:	8d3fe0ef          	jal	80000db6 <release>
  for (p = proc; p < &proc[NPROC]; p++) {
    800024e8:	16848493          	addi	s1,s1,360
    800024ec:	03248263          	beq	s1,s2,80002510 <wakeup+0x58>
    if (p != myproc()) {
    800024f0:	f50ff0ef          	jal	80001c40 <myproc>
    800024f4:	fe950ae3          	beq	a0,s1,800024e8 <wakeup+0x30>
      acquire(&p->lock);
    800024f8:	8526                	mv	a0,s1
    800024fa:	829fe0ef          	jal	80000d22 <acquire>
      if (p->state == SLEEPING && p->chan == chan) {
    800024fe:	4c9c                	lw	a5,24(s1)
    80002500:	ff3791e3          	bne	a5,s3,800024e2 <wakeup+0x2a>
    80002504:	709c                	ld	a5,32(s1)
    80002506:	fd479ee3          	bne	a5,s4,800024e2 <wakeup+0x2a>
        p->state = RUNNABLE;
    8000250a:	0154ac23          	sw	s5,24(s1)
    8000250e:	bfd1                	j	800024e2 <wakeup+0x2a>
    }
  }
}
    80002510:	70e2                	ld	ra,56(sp)
    80002512:	7442                	ld	s0,48(sp)
    80002514:	74a2                	ld	s1,40(sp)
    80002516:	7902                	ld	s2,32(sp)
    80002518:	69e2                	ld	s3,24(sp)
    8000251a:	6a42                	ld	s4,16(sp)
    8000251c:	6aa2                	ld	s5,8(sp)
    8000251e:	6121                	addi	sp,sp,64
    80002520:	8082                	ret

0000000080002522 <reparent>:
void reparent(struct proc *p) {
    80002522:	7179                	addi	sp,sp,-48
    80002524:	f406                	sd	ra,40(sp)
    80002526:	f022                	sd	s0,32(sp)
    80002528:	ec26                	sd	s1,24(sp)
    8000252a:	e84a                	sd	s2,16(sp)
    8000252c:	e44e                	sd	s3,8(sp)
    8000252e:	e052                	sd	s4,0(sp)
    80002530:	1800                	addi	s0,sp,48
    80002532:	892a                	mv	s2,a0
  for (pp = proc; pp < &proc[NPROC]; pp++) {
    80002534:	00010497          	auipc	s1,0x10
    80002538:	03c48493          	addi	s1,s1,60 # 80012570 <proc>
      pp->parent = initproc;
    8000253c:	00007a17          	auipc	s4,0x7
    80002540:	aeca0a13          	addi	s4,s4,-1300 # 80009028 <initproc>
  for (pp = proc; pp < &proc[NPROC]; pp++) {
    80002544:	00016997          	auipc	s3,0x16
    80002548:	a2c98993          	addi	s3,s3,-1492 # 80017f70 <tickslock>
    8000254c:	a029                	j	80002556 <reparent+0x34>
    8000254e:	16848493          	addi	s1,s1,360
    80002552:	01348b63          	beq	s1,s3,80002568 <reparent+0x46>
    if (pp->parent == p) {
    80002556:	7c9c                	ld	a5,56(s1)
    80002558:	ff279be3          	bne	a5,s2,8000254e <reparent+0x2c>
      pp->parent = initproc;
    8000255c:	000a3503          	ld	a0,0(s4)
    80002560:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    80002562:	f57ff0ef          	jal	800024b8 <wakeup>
    80002566:	b7e5                	j	8000254e <reparent+0x2c>
}
    80002568:	70a2                	ld	ra,40(sp)
    8000256a:	7402                	ld	s0,32(sp)
    8000256c:	64e2                	ld	s1,24(sp)
    8000256e:	6942                	ld	s2,16(sp)
    80002570:	69a2                	ld	s3,8(sp)
    80002572:	6a02                	ld	s4,0(sp)
    80002574:	6145                	addi	sp,sp,48
    80002576:	8082                	ret

0000000080002578 <kexit>:
void kexit(int status) {
    80002578:	7179                	addi	sp,sp,-48
    8000257a:	f406                	sd	ra,40(sp)
    8000257c:	f022                	sd	s0,32(sp)
    8000257e:	ec26                	sd	s1,24(sp)
    80002580:	e84a                	sd	s2,16(sp)
    80002582:	e44e                	sd	s3,8(sp)
    80002584:	e052                	sd	s4,0(sp)
    80002586:	1800                	addi	s0,sp,48
    80002588:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    8000258a:	eb6ff0ef          	jal	80001c40 <myproc>
    8000258e:	89aa                	mv	s3,a0
  if (p == initproc)
    80002590:	00007797          	auipc	a5,0x7
    80002594:	a987b783          	ld	a5,-1384(a5) # 80009028 <initproc>
    80002598:	0d050493          	addi	s1,a0,208
    8000259c:	15050913          	addi	s2,a0,336
    800025a0:	00a79b63          	bne	a5,a0,800025b6 <kexit+0x3e>
    panic("init exiting");
    800025a4:	00006517          	auipc	a0,0x6
    800025a8:	c6c50513          	addi	a0,a0,-916 # 80008210 <etext+0x210>
    800025ac:	aaafe0ef          	jal	80000856 <panic>
  for (int fd = 0; fd < NOFILE; fd++) {
    800025b0:	04a1                	addi	s1,s1,8
    800025b2:	01248963          	beq	s1,s2,800025c4 <kexit+0x4c>
    if (p->ofile[fd]) {
    800025b6:	6088                	ld	a0,0(s1)
    800025b8:	dd65                	beqz	a0,800025b0 <kexit+0x38>
      fileclose(f);
    800025ba:	08a020ef          	jal	80004644 <fileclose>
      p->ofile[fd] = 0;
    800025be:	0004b023          	sd	zero,0(s1)
    800025c2:	b7fd                	j	800025b0 <kexit+0x38>
  begin_op();
    800025c4:	45d010ef          	jal	80004220 <begin_op>
  iput(p->cwd);
    800025c8:	1509b503          	ld	a0,336(s3)
    800025cc:	3ca010ef          	jal	80003996 <iput>
  end_op();
    800025d0:	4c1010ef          	jal	80004290 <end_op>
  p->cwd = 0;
    800025d4:	1409b823          	sd	zero,336(s3)
  acquire(&wait_lock);
    800025d8:	00010517          	auipc	a0,0x10
    800025dc:	b6850513          	addi	a0,a0,-1176 # 80012140 <wait_lock>
    800025e0:	f42fe0ef          	jal	80000d22 <acquire>
  reparent(p);
    800025e4:	854e                	mv	a0,s3
    800025e6:	f3dff0ef          	jal	80002522 <reparent>
  wakeup(p->parent);
    800025ea:	0389b503          	ld	a0,56(s3)
    800025ee:	ecbff0ef          	jal	800024b8 <wakeup>
  acquire(&p->lock);
    800025f2:	854e                	mv	a0,s3
    800025f4:	f2efe0ef          	jal	80000d22 <acquire>
  p->xstate = status;
    800025f8:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    800025fc:	4795                	li	a5,5
    800025fe:	00f9ac23          	sw	a5,24(s3)
  release(&wait_lock);
    80002602:	00010517          	auipc	a0,0x10
    80002606:	b3e50513          	addi	a0,a0,-1218 # 80012140 <wait_lock>
    8000260a:	facfe0ef          	jal	80000db6 <release>
  sched();
    8000260e:	d77ff0ef          	jal	80002384 <sched>
  panic("zombie exit");
    80002612:	00006517          	auipc	a0,0x6
    80002616:	c0e50513          	addi	a0,a0,-1010 # 80008220 <etext+0x220>
    8000261a:	a3cfe0ef          	jal	80000856 <panic>

000000008000261e <kkill>:

// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int kkill(int pid) {
    8000261e:	7179                	addi	sp,sp,-48
    80002620:	f406                	sd	ra,40(sp)
    80002622:	f022                	sd	s0,32(sp)
    80002624:	ec26                	sd	s1,24(sp)
    80002626:	e84a                	sd	s2,16(sp)
    80002628:	e44e                	sd	s3,8(sp)
    8000262a:	1800                	addi	s0,sp,48
    8000262c:	892a                	mv	s2,a0
  struct proc *p;

  for (p = proc; p < &proc[NPROC]; p++) {
    8000262e:	00010497          	auipc	s1,0x10
    80002632:	f4248493          	addi	s1,s1,-190 # 80012570 <proc>
    80002636:	00016997          	auipc	s3,0x16
    8000263a:	93a98993          	addi	s3,s3,-1734 # 80017f70 <tickslock>
    acquire(&p->lock);
    8000263e:	8526                	mv	a0,s1
    80002640:	ee2fe0ef          	jal	80000d22 <acquire>
    if (p->pid == pid) {
    80002644:	589c                	lw	a5,48(s1)
    80002646:	01278b63          	beq	a5,s2,8000265c <kkill+0x3e>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    8000264a:	8526                	mv	a0,s1
    8000264c:	f6afe0ef          	jal	80000db6 <release>
  for (p = proc; p < &proc[NPROC]; p++) {
    80002650:	16848493          	addi	s1,s1,360
    80002654:	ff3495e3          	bne	s1,s3,8000263e <kkill+0x20>
  }
  return -1;
    80002658:	557d                	li	a0,-1
    8000265a:	a819                	j	80002670 <kkill+0x52>
      p->killed = 1;
    8000265c:	4785                	li	a5,1
    8000265e:	d49c                	sw	a5,40(s1)
      if (p->state == SLEEPING) {
    80002660:	4c98                	lw	a4,24(s1)
    80002662:	4789                	li	a5,2
    80002664:	00f70d63          	beq	a4,a5,8000267e <kkill+0x60>
      release(&p->lock);
    80002668:	8526                	mv	a0,s1
    8000266a:	f4cfe0ef          	jal	80000db6 <release>
      return 0;
    8000266e:	4501                	li	a0,0
}
    80002670:	70a2                	ld	ra,40(sp)
    80002672:	7402                	ld	s0,32(sp)
    80002674:	64e2                	ld	s1,24(sp)
    80002676:	6942                	ld	s2,16(sp)
    80002678:	69a2                	ld	s3,8(sp)
    8000267a:	6145                	addi	sp,sp,48
    8000267c:	8082                	ret
        p->state = RUNNABLE;
    8000267e:	478d                	li	a5,3
    80002680:	cc9c                	sw	a5,24(s1)
    80002682:	b7dd                	j	80002668 <kkill+0x4a>

0000000080002684 <setkilled>:

void setkilled(struct proc *p) {
    80002684:	1101                	addi	sp,sp,-32
    80002686:	ec06                	sd	ra,24(sp)
    80002688:	e822                	sd	s0,16(sp)
    8000268a:	e426                	sd	s1,8(sp)
    8000268c:	1000                	addi	s0,sp,32
    8000268e:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80002690:	e92fe0ef          	jal	80000d22 <acquire>
  p->killed = 1;
    80002694:	4785                	li	a5,1
    80002696:	d49c                	sw	a5,40(s1)
  release(&p->lock);
    80002698:	8526                	mv	a0,s1
    8000269a:	f1cfe0ef          	jal	80000db6 <release>
}
    8000269e:	60e2                	ld	ra,24(sp)
    800026a0:	6442                	ld	s0,16(sp)
    800026a2:	64a2                	ld	s1,8(sp)
    800026a4:	6105                	addi	sp,sp,32
    800026a6:	8082                	ret

00000000800026a8 <killed>:

int killed(struct proc *p) {
    800026a8:	1101                	addi	sp,sp,-32
    800026aa:	ec06                	sd	ra,24(sp)
    800026ac:	e822                	sd	s0,16(sp)
    800026ae:	e426                	sd	s1,8(sp)
    800026b0:	e04a                	sd	s2,0(sp)
    800026b2:	1000                	addi	s0,sp,32
    800026b4:	84aa                	mv	s1,a0
  int k;

  acquire(&p->lock);
    800026b6:	e6cfe0ef          	jal	80000d22 <acquire>
  k = p->killed;
    800026ba:	549c                	lw	a5,40(s1)
    800026bc:	893e                	mv	s2,a5
  release(&p->lock);
    800026be:	8526                	mv	a0,s1
    800026c0:	ef6fe0ef          	jal	80000db6 <release>
  return k;
}
    800026c4:	854a                	mv	a0,s2
    800026c6:	60e2                	ld	ra,24(sp)
    800026c8:	6442                	ld	s0,16(sp)
    800026ca:	64a2                	ld	s1,8(sp)
    800026cc:	6902                	ld	s2,0(sp)
    800026ce:	6105                	addi	sp,sp,32
    800026d0:	8082                	ret

00000000800026d2 <kwait>:
int kwait(uint64 addr) {
    800026d2:	715d                	addi	sp,sp,-80
    800026d4:	e486                	sd	ra,72(sp)
    800026d6:	e0a2                	sd	s0,64(sp)
    800026d8:	fc26                	sd	s1,56(sp)
    800026da:	f84a                	sd	s2,48(sp)
    800026dc:	f44e                	sd	s3,40(sp)
    800026de:	f052                	sd	s4,32(sp)
    800026e0:	ec56                	sd	s5,24(sp)
    800026e2:	e85a                	sd	s6,16(sp)
    800026e4:	e45e                	sd	s7,8(sp)
    800026e6:	0880                	addi	s0,sp,80
    800026e8:	8baa                	mv	s7,a0
  struct proc *p = myproc();
    800026ea:	d56ff0ef          	jal	80001c40 <myproc>
    800026ee:	892a                	mv	s2,a0
  acquire(&wait_lock);
    800026f0:	00010517          	auipc	a0,0x10
    800026f4:	a5050513          	addi	a0,a0,-1456 # 80012140 <wait_lock>
    800026f8:	e2afe0ef          	jal	80000d22 <acquire>
        if (pp->state == ZOMBIE) {
    800026fc:	4a15                	li	s4,5
        havekids = 1;
    800026fe:	4a85                	li	s5,1
    for (pp = proc; pp < &proc[NPROC]; pp++) {
    80002700:	00016997          	auipc	s3,0x16
    80002704:	87098993          	addi	s3,s3,-1936 # 80017f70 <tickslock>
    sleep(p, &wait_lock); // DOC: wait-sleep
    80002708:	00010b17          	auipc	s6,0x10
    8000270c:	a38b0b13          	addi	s6,s6,-1480 # 80012140 <wait_lock>
    80002710:	a869                	j	800027aa <kwait+0xd8>
          pid = pp->pid;
    80002712:	0304a983          	lw	s3,48(s1)
          if (addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    80002716:	000b8c63          	beqz	s7,8000272e <kwait+0x5c>
    8000271a:	4691                	li	a3,4
    8000271c:	02c48613          	addi	a2,s1,44
    80002720:	85de                	mv	a1,s7
    80002722:	05093503          	ld	a0,80(s2)
    80002726:	a2cff0ef          	jal	80001952 <copyout>
    8000272a:	02054a63          	bltz	a0,8000275e <kwait+0x8c>
          freeproc(pp);
    8000272e:	8526                	mv	a0,s1
    80002730:	ee4ff0ef          	jal	80001e14 <freeproc>
          release(&pp->lock);
    80002734:	8526                	mv	a0,s1
    80002736:	e80fe0ef          	jal	80000db6 <release>
          release(&wait_lock);
    8000273a:	00010517          	auipc	a0,0x10
    8000273e:	a0650513          	addi	a0,a0,-1530 # 80012140 <wait_lock>
    80002742:	e74fe0ef          	jal	80000db6 <release>
}
    80002746:	854e                	mv	a0,s3
    80002748:	60a6                	ld	ra,72(sp)
    8000274a:	6406                	ld	s0,64(sp)
    8000274c:	74e2                	ld	s1,56(sp)
    8000274e:	7942                	ld	s2,48(sp)
    80002750:	79a2                	ld	s3,40(sp)
    80002752:	7a02                	ld	s4,32(sp)
    80002754:	6ae2                	ld	s5,24(sp)
    80002756:	6b42                	ld	s6,16(sp)
    80002758:	6ba2                	ld	s7,8(sp)
    8000275a:	6161                	addi	sp,sp,80
    8000275c:	8082                	ret
            release(&pp->lock);
    8000275e:	8526                	mv	a0,s1
    80002760:	e56fe0ef          	jal	80000db6 <release>
            release(&wait_lock);
    80002764:	00010517          	auipc	a0,0x10
    80002768:	9dc50513          	addi	a0,a0,-1572 # 80012140 <wait_lock>
    8000276c:	e4afe0ef          	jal	80000db6 <release>
            return -1;
    80002770:	59fd                	li	s3,-1
    80002772:	bfd1                	j	80002746 <kwait+0x74>
    for (pp = proc; pp < &proc[NPROC]; pp++) {
    80002774:	16848493          	addi	s1,s1,360
    80002778:	03348063          	beq	s1,s3,80002798 <kwait+0xc6>
      if (pp->parent == p) {
    8000277c:	7c9c                	ld	a5,56(s1)
    8000277e:	ff279be3          	bne	a5,s2,80002774 <kwait+0xa2>
        acquire(&pp->lock);
    80002782:	8526                	mv	a0,s1
    80002784:	d9efe0ef          	jal	80000d22 <acquire>
        if (pp->state == ZOMBIE) {
    80002788:	4c9c                	lw	a5,24(s1)
    8000278a:	f94784e3          	beq	a5,s4,80002712 <kwait+0x40>
        release(&pp->lock);
    8000278e:	8526                	mv	a0,s1
    80002790:	e26fe0ef          	jal	80000db6 <release>
        havekids = 1;
    80002794:	8756                	mv	a4,s5
    80002796:	bff9                	j	80002774 <kwait+0xa2>
    if (!havekids || killed(p)) {
    80002798:	cf19                	beqz	a4,800027b6 <kwait+0xe4>
    8000279a:	854a                	mv	a0,s2
    8000279c:	f0dff0ef          	jal	800026a8 <killed>
    800027a0:	e919                	bnez	a0,800027b6 <kwait+0xe4>
    sleep(p, &wait_lock); // DOC: wait-sleep
    800027a2:	85da                	mv	a1,s6
    800027a4:	854a                	mv	a0,s2
    800027a6:	cc7ff0ef          	jal	8000246c <sleep>
    havekids = 0;
    800027aa:	4701                	li	a4,0
    for (pp = proc; pp < &proc[NPROC]; pp++) {
    800027ac:	00010497          	auipc	s1,0x10
    800027b0:	dc448493          	addi	s1,s1,-572 # 80012570 <proc>
    800027b4:	b7e1                	j	8000277c <kwait+0xaa>
      release(&wait_lock);
    800027b6:	00010517          	auipc	a0,0x10
    800027ba:	98a50513          	addi	a0,a0,-1654 # 80012140 <wait_lock>
    800027be:	df8fe0ef          	jal	80000db6 <release>
      return -1;
    800027c2:	59fd                	li	s3,-1
    800027c4:	b749                	j	80002746 <kwait+0x74>

00000000800027c6 <either_copyout>:

// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int either_copyout(int user_dst, uint64 dst, void *src, uint64 len) {
    800027c6:	7179                	addi	sp,sp,-48
    800027c8:	f406                	sd	ra,40(sp)
    800027ca:	f022                	sd	s0,32(sp)
    800027cc:	ec26                	sd	s1,24(sp)
    800027ce:	e84a                	sd	s2,16(sp)
    800027d0:	e44e                	sd	s3,8(sp)
    800027d2:	e052                	sd	s4,0(sp)
    800027d4:	1800                	addi	s0,sp,48
    800027d6:	84aa                	mv	s1,a0
    800027d8:	8a2e                	mv	s4,a1
    800027da:	89b2                	mv	s3,a2
    800027dc:	8936                	mv	s2,a3
  struct proc *p = myproc();
    800027de:	c62ff0ef          	jal	80001c40 <myproc>
  if (user_dst) {
    800027e2:	cc99                	beqz	s1,80002800 <either_copyout+0x3a>
    return copyout(p->pagetable, dst, src, len);
    800027e4:	86ca                	mv	a3,s2
    800027e6:	864e                	mv	a2,s3
    800027e8:	85d2                	mv	a1,s4
    800027ea:	6928                	ld	a0,80(a0)
    800027ec:	966ff0ef          	jal	80001952 <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    800027f0:	70a2                	ld	ra,40(sp)
    800027f2:	7402                	ld	s0,32(sp)
    800027f4:	64e2                	ld	s1,24(sp)
    800027f6:	6942                	ld	s2,16(sp)
    800027f8:	69a2                	ld	s3,8(sp)
    800027fa:	6a02                	ld	s4,0(sp)
    800027fc:	6145                	addi	sp,sp,48
    800027fe:	8082                	ret
    memmove((char *)dst, src, len);
    80002800:	0009061b          	sext.w	a2,s2
    80002804:	85ce                	mv	a1,s3
    80002806:	8552                	mv	a0,s4
    80002808:	e4afe0ef          	jal	80000e52 <memmove>
    return 0;
    8000280c:	8526                	mv	a0,s1
    8000280e:	b7cd                	j	800027f0 <either_copyout+0x2a>

0000000080002810 <either_copyin>:

// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int either_copyin(void *dst, int user_src, uint64 src, uint64 len) {
    80002810:	7179                	addi	sp,sp,-48
    80002812:	f406                	sd	ra,40(sp)
    80002814:	f022                	sd	s0,32(sp)
    80002816:	ec26                	sd	s1,24(sp)
    80002818:	e84a                	sd	s2,16(sp)
    8000281a:	e44e                	sd	s3,8(sp)
    8000281c:	e052                	sd	s4,0(sp)
    8000281e:	1800                	addi	s0,sp,48
    80002820:	8a2a                	mv	s4,a0
    80002822:	84ae                	mv	s1,a1
    80002824:	89b2                	mv	s3,a2
    80002826:	8936                	mv	s2,a3
  struct proc *p = myproc();
    80002828:	c18ff0ef          	jal	80001c40 <myproc>
  if (user_src) {
    8000282c:	cc99                	beqz	s1,8000284a <either_copyin+0x3a>
    return copyin(p->pagetable, dst, src, len);
    8000282e:	86ca                	mv	a3,s2
    80002830:	864e                	mv	a2,s3
    80002832:	85d2                	mv	a1,s4
    80002834:	6928                	ld	a0,80(a0)
    80002836:	9daff0ef          	jal	80001a10 <copyin>
  } else {
    memmove(dst, (char *)src, len);
    return 0;
  }
}
    8000283a:	70a2                	ld	ra,40(sp)
    8000283c:	7402                	ld	s0,32(sp)
    8000283e:	64e2                	ld	s1,24(sp)
    80002840:	6942                	ld	s2,16(sp)
    80002842:	69a2                	ld	s3,8(sp)
    80002844:	6a02                	ld	s4,0(sp)
    80002846:	6145                	addi	sp,sp,48
    80002848:	8082                	ret
    memmove(dst, (char *)src, len);
    8000284a:	0009061b          	sext.w	a2,s2
    8000284e:	85ce                	mv	a1,s3
    80002850:	8552                	mv	a0,s4
    80002852:	e00fe0ef          	jal	80000e52 <memmove>
    return 0;
    80002856:	8526                	mv	a0,s1
    80002858:	b7cd                	j	8000283a <either_copyin+0x2a>

000000008000285a <procdump>:

// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void procdump(void) {
    8000285a:	715d                	addi	sp,sp,-80
    8000285c:	e486                	sd	ra,72(sp)
    8000285e:	e0a2                	sd	s0,64(sp)
    80002860:	fc26                	sd	s1,56(sp)
    80002862:	f84a                	sd	s2,48(sp)
    80002864:	f44e                	sd	s3,40(sp)
    80002866:	f052                	sd	s4,32(sp)
    80002868:	ec56                	sd	s5,24(sp)
    8000286a:	e85a                	sd	s6,16(sp)
    8000286c:	e45e                	sd	s7,8(sp)
    8000286e:	0880                	addi	s0,sp,80
      [UNUSED] "unused",   [USED] "used",      [SLEEPING] "sleep ",
      [RUNNABLE] "runble", [RUNNING] "run   ", [ZOMBIE] "zombie"};
  struct proc *p;
  char *state;

  printf("\n");
    80002870:	00006517          	auipc	a0,0x6
    80002874:	81050513          	addi	a0,a0,-2032 # 80008080 <etext+0x80>
    80002878:	cb5fd0ef          	jal	8000052c <printf>
  for (p = proc; p < &proc[NPROC]; p++) {
    8000287c:	00010497          	auipc	s1,0x10
    80002880:	e4c48493          	addi	s1,s1,-436 # 800126c8 <proc+0x158>
    80002884:	00016917          	auipc	s2,0x16
    80002888:	84490913          	addi	s2,s2,-1980 # 800180c8 <bcache+0x140>
    if (p->state == UNUSED)
      continue;
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000288c:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    8000288e:	00006997          	auipc	s3,0x6
    80002892:	9a298993          	addi	s3,s3,-1630 # 80008230 <etext+0x230>
    printf("%d %s %s", p->pid, state, p->name);
    80002896:	00006a97          	auipc	s5,0x6
    8000289a:	9a2a8a93          	addi	s5,s5,-1630 # 80008238 <etext+0x238>
    printf("\n");
    8000289e:	00005a17          	auipc	s4,0x5
    800028a2:	7e2a0a13          	addi	s4,s4,2018 # 80008080 <etext+0x80>
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800028a6:	00006b97          	auipc	s7,0x6
    800028aa:	efab8b93          	addi	s7,s7,-262 # 800087a0 <states.0>
    800028ae:	a829                	j	800028c8 <procdump+0x6e>
    printf("%d %s %s", p->pid, state, p->name);
    800028b0:	ed86a583          	lw	a1,-296(a3)
    800028b4:	8556                	mv	a0,s5
    800028b6:	c77fd0ef          	jal	8000052c <printf>
    printf("\n");
    800028ba:	8552                	mv	a0,s4
    800028bc:	c71fd0ef          	jal	8000052c <printf>
  for (p = proc; p < &proc[NPROC]; p++) {
    800028c0:	16848493          	addi	s1,s1,360
    800028c4:	03248263          	beq	s1,s2,800028e8 <procdump+0x8e>
    if (p->state == UNUSED)
    800028c8:	86a6                	mv	a3,s1
    800028ca:	ec04a783          	lw	a5,-320(s1)
    800028ce:	dbed                	beqz	a5,800028c0 <procdump+0x66>
      state = "???";
    800028d0:	864e                	mv	a2,s3
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800028d2:	fcfb6fe3          	bltu	s6,a5,800028b0 <procdump+0x56>
    800028d6:	02079713          	slli	a4,a5,0x20
    800028da:	01d75793          	srli	a5,a4,0x1d
    800028de:	97de                	add	a5,a5,s7
    800028e0:	6390                	ld	a2,0(a5)
    800028e2:	f679                	bnez	a2,800028b0 <procdump+0x56>
      state = "???";
    800028e4:	864e                	mv	a2,s3
    800028e6:	b7e9                	j	800028b0 <procdump+0x56>
  }
}
    800028e8:	60a6                	ld	ra,72(sp)
    800028ea:	6406                	ld	s0,64(sp)
    800028ec:	74e2                	ld	s1,56(sp)
    800028ee:	7942                	ld	s2,48(sp)
    800028f0:	79a2                	ld	s3,40(sp)
    800028f2:	7a02                	ld	s4,32(sp)
    800028f4:	6ae2                	ld	s5,24(sp)
    800028f6:	6b42                	ld	s6,16(sp)
    800028f8:	6ba2                	ld	s7,8(sp)
    800028fa:	6161                	addi	sp,sp,80
    800028fc:	8082                	ret

00000000800028fe <swtch>:
# Save current registers in old. Load from new.	


.globl swtch
swtch:
        sd ra, 0(a0)
    800028fe:	00153023          	sd	ra,0(a0)
        sd sp, 8(a0)
    80002902:	00253423          	sd	sp,8(a0)
        sd s0, 16(a0)
    80002906:	e900                	sd	s0,16(a0)
        sd s1, 24(a0)
    80002908:	ed04                	sd	s1,24(a0)
        sd s2, 32(a0)
    8000290a:	03253023          	sd	s2,32(a0)
        sd s3, 40(a0)
    8000290e:	03353423          	sd	s3,40(a0)
        sd s4, 48(a0)
    80002912:	03453823          	sd	s4,48(a0)
        sd s5, 56(a0)
    80002916:	03553c23          	sd	s5,56(a0)
        sd s6, 64(a0)
    8000291a:	05653023          	sd	s6,64(a0)
        sd s7, 72(a0)
    8000291e:	05753423          	sd	s7,72(a0)
        sd s8, 80(a0)
    80002922:	05853823          	sd	s8,80(a0)
        sd s9, 88(a0)
    80002926:	05953c23          	sd	s9,88(a0)
        sd s10, 96(a0)
    8000292a:	07a53023          	sd	s10,96(a0)
        sd s11, 104(a0)
    8000292e:	07b53423          	sd	s11,104(a0)

        ld ra, 0(a1)
    80002932:	0005b083          	ld	ra,0(a1)
        ld sp, 8(a1)
    80002936:	0085b103          	ld	sp,8(a1)
        ld s0, 16(a1)
    8000293a:	6980                	ld	s0,16(a1)
        ld s1, 24(a1)
    8000293c:	6d84                	ld	s1,24(a1)
        ld s2, 32(a1)
    8000293e:	0205b903          	ld	s2,32(a1)
        ld s3, 40(a1)
    80002942:	0285b983          	ld	s3,40(a1)
        ld s4, 48(a1)
    80002946:	0305ba03          	ld	s4,48(a1)
        ld s5, 56(a1)
    8000294a:	0385ba83          	ld	s5,56(a1)
        ld s6, 64(a1)
    8000294e:	0405bb03          	ld	s6,64(a1)
        ld s7, 72(a1)
    80002952:	0485bb83          	ld	s7,72(a1)
        ld s8, 80(a1)
    80002956:	0505bc03          	ld	s8,80(a1)
        ld s9, 88(a1)
    8000295a:	0585bc83          	ld	s9,88(a1)
        ld s10, 96(a1)
    8000295e:	0605bd03          	ld	s10,96(a1)
        ld s11, 104(a1)
    80002962:	0685bd83          	ld	s11,104(a1)
        
        ret
    80002966:	8082                	ret

0000000080002968 <trapinit>:

extern int devintr();

void
trapinit(void)
{
    80002968:	1141                	addi	sp,sp,-16
    8000296a:	e406                	sd	ra,8(sp)
    8000296c:	e022                	sd	s0,0(sp)
    8000296e:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    80002970:	00006597          	auipc	a1,0x6
    80002974:	90858593          	addi	a1,a1,-1784 # 80008278 <etext+0x278>
    80002978:	00015517          	auipc	a0,0x15
    8000297c:	5f850513          	addi	a0,a0,1528 # 80017f70 <tickslock>
    80002980:	b18fe0ef          	jal	80000c98 <initlock>
}
    80002984:	60a2                	ld	ra,8(sp)
    80002986:	6402                	ld	s0,0(sp)
    80002988:	0141                	addi	sp,sp,16
    8000298a:	8082                	ret

000000008000298c <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    8000298c:	1141                	addi	sp,sp,-16
    8000298e:	e406                	sd	ra,8(sp)
    80002990:	e022                	sd	s0,0(sp)
    80002992:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002994:	00003797          	auipc	a5,0x3
    80002998:	0ac78793          	addi	a5,a5,172 # 80005a40 <kernelvec>
    8000299c:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    800029a0:	60a2                	ld	ra,8(sp)
    800029a2:	6402                	ld	s0,0(sp)
    800029a4:	0141                	addi	sp,sp,16
    800029a6:	8082                	ret

00000000800029a8 <prepare_return>:
//
// set up trapframe and control registers for a return to user space
//
void
prepare_return(void)
{
    800029a8:	1141                	addi	sp,sp,-16
    800029aa:	e406                	sd	ra,8(sp)
    800029ac:	e022                	sd	s0,0(sp)
    800029ae:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    800029b0:	a90ff0ef          	jal	80001c40 <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800029b4:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    800029b8:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800029ba:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(). because a trap from kernel
  // code to usertrap would be a disaster, turn off interrupts.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    800029be:	04000737          	lui	a4,0x4000
    800029c2:	177d                	addi	a4,a4,-1 # 3ffffff <_entry-0x7c000001>
    800029c4:	0732                	slli	a4,a4,0xc
    800029c6:	00004797          	auipc	a5,0x4
    800029ca:	63a78793          	addi	a5,a5,1594 # 80007000 <_trampoline>
    800029ce:	00004697          	auipc	a3,0x4
    800029d2:	63268693          	addi	a3,a3,1586 # 80007000 <_trampoline>
    800029d6:	8f95                	sub	a5,a5,a3
    800029d8:	97ba                	add	a5,a5,a4
  asm volatile("csrw stvec, %0" : : "r" (x));
    800029da:	10579073          	csrw	stvec,a5
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    800029de:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    800029e0:	18002773          	csrr	a4,satp
    800029e4:	e398                	sd	a4,0(a5)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    800029e6:	6d38                	ld	a4,88(a0)
    800029e8:	613c                	ld	a5,64(a0)
    800029ea:	6685                	lui	a3,0x1
    800029ec:	97b6                	add	a5,a5,a3
    800029ee:	e71c                	sd	a5,8(a4)
  p->trapframe->kernel_trap = (uint64)usertrap;
    800029f0:	6d3c                	ld	a5,88(a0)
    800029f2:	00000717          	auipc	a4,0x0
    800029f6:	0fc70713          	addi	a4,a4,252 # 80002aee <usertrap>
    800029fa:	eb98                	sd	a4,16(a5)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    800029fc:	6d3c                	ld	a5,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    800029fe:	8712                	mv	a4,tp
    80002a00:	f398                	sd	a4,32(a5)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002a02:	100027f3          	csrr	a5,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    80002a06:	eff7f793          	andi	a5,a5,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    80002a0a:	0207e793          	ori	a5,a5,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002a0e:	10079073          	csrw	sstatus,a5
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    80002a12:	6d3c                	ld	a5,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002a14:	6f9c                	ld	a5,24(a5)
    80002a16:	14179073          	csrw	sepc,a5
}
    80002a1a:	60a2                	ld	ra,8(sp)
    80002a1c:	6402                	ld	s0,0(sp)
    80002a1e:	0141                	addi	sp,sp,16
    80002a20:	8082                	ret

0000000080002a22 <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    80002a22:	1141                	addi	sp,sp,-16
    80002a24:	e406                	sd	ra,8(sp)
    80002a26:	e022                	sd	s0,0(sp)
    80002a28:	0800                	addi	s0,sp,16
  if(cpuid() == 0){
    80002a2a:	9e2ff0ef          	jal	80001c0c <cpuid>
    80002a2e:	cd11                	beqz	a0,80002a4a <clockintr+0x28>
  asm volatile("csrr %0, time" : "=r" (x) );
    80002a30:	c01027f3          	rdtime	a5
  }

  // ask for the next timer interrupt. this also clears
  // the interrupt request. 1000000 is about a tenth
  // of a second.
  w_stimecmp(r_time() + 1000000);
    80002a34:	000f4737          	lui	a4,0xf4
    80002a38:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    80002a3c:	97ba                	add	a5,a5,a4
  asm volatile("csrw 0x14d, %0" : : "r" (x));
    80002a3e:	14d79073          	csrw	stimecmp,a5
}
    80002a42:	60a2                	ld	ra,8(sp)
    80002a44:	6402                	ld	s0,0(sp)
    80002a46:	0141                	addi	sp,sp,16
    80002a48:	8082                	ret
    acquire(&tickslock);
    80002a4a:	00015517          	auipc	a0,0x15
    80002a4e:	52650513          	addi	a0,a0,1318 # 80017f70 <tickslock>
    80002a52:	ad0fe0ef          	jal	80000d22 <acquire>
    ticks++;
    80002a56:	00006717          	auipc	a4,0x6
    80002a5a:	5da70713          	addi	a4,a4,1498 # 80009030 <ticks>
    80002a5e:	431c                	lw	a5,0(a4)
    80002a60:	2785                	addiw	a5,a5,1
    80002a62:	c31c                	sw	a5,0(a4)
    wakeup(&ticks);
    80002a64:	853a                	mv	a0,a4
    80002a66:	a53ff0ef          	jal	800024b8 <wakeup>
    release(&tickslock);
    80002a6a:	00015517          	auipc	a0,0x15
    80002a6e:	50650513          	addi	a0,a0,1286 # 80017f70 <tickslock>
    80002a72:	b44fe0ef          	jal	80000db6 <release>
    80002a76:	bf6d                	j	80002a30 <clockintr+0xe>

0000000080002a78 <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    80002a78:	1101                	addi	sp,sp,-32
    80002a7a:	ec06                	sd	ra,24(sp)
    80002a7c:	e822                	sd	s0,16(sp)
    80002a7e:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002a80:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if(scause == 0x8000000000000009L){
    80002a84:	57fd                	li	a5,-1
    80002a86:	17fe                	slli	a5,a5,0x3f
    80002a88:	07a5                	addi	a5,a5,9
    80002a8a:	00f70c63          	beq	a4,a5,80002aa2 <devintr+0x2a>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000005L){
    80002a8e:	57fd                	li	a5,-1
    80002a90:	17fe                	slli	a5,a5,0x3f
    80002a92:	0795                	addi	a5,a5,5
    // timer interrupt.
    clockintr();
    return 2;
  } else {
    return 0;
    80002a94:	4501                	li	a0,0
  } else if(scause == 0x8000000000000005L){
    80002a96:	04f70863          	beq	a4,a5,80002ae6 <devintr+0x6e>
  }
}
    80002a9a:	60e2                	ld	ra,24(sp)
    80002a9c:	6442                	ld	s0,16(sp)
    80002a9e:	6105                	addi	sp,sp,32
    80002aa0:	8082                	ret
    80002aa2:	e426                	sd	s1,8(sp)
    int irq = plic_claim();
    80002aa4:	048030ef          	jal	80005aec <plic_claim>
    80002aa8:	872a                	mv	a4,a0
    80002aaa:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    80002aac:	47a9                	li	a5,10
    80002aae:	00f50963          	beq	a0,a5,80002ac0 <devintr+0x48>
    } else if(irq == VIRTIO0_IRQ){
    80002ab2:	4785                	li	a5,1
    80002ab4:	00f50963          	beq	a0,a5,80002ac6 <devintr+0x4e>
    return 1;
    80002ab8:	4505                	li	a0,1
    } else if(irq){
    80002aba:	eb09                	bnez	a4,80002acc <devintr+0x54>
    80002abc:	64a2                	ld	s1,8(sp)
    80002abe:	bff1                	j	80002a9a <devintr+0x22>
      uartintr();
    80002ac0:	f67fd0ef          	jal	80000a26 <uartintr>
    if(irq)
    80002ac4:	a819                	j	80002ada <devintr+0x62>
      virtio_disk_intr();
    80002ac6:	4bc030ef          	jal	80005f82 <virtio_disk_intr>
    if(irq)
    80002aca:	a801                	j	80002ada <devintr+0x62>
      printf("unexpected interrupt irq=%d\n", irq);
    80002acc:	85ba                	mv	a1,a4
    80002ace:	00005517          	auipc	a0,0x5
    80002ad2:	7b250513          	addi	a0,a0,1970 # 80008280 <etext+0x280>
    80002ad6:	a57fd0ef          	jal	8000052c <printf>
      plic_complete(irq);
    80002ada:	8526                	mv	a0,s1
    80002adc:	030030ef          	jal	80005b0c <plic_complete>
    return 1;
    80002ae0:	4505                	li	a0,1
    80002ae2:	64a2                	ld	s1,8(sp)
    80002ae4:	bf5d                	j	80002a9a <devintr+0x22>
    clockintr();
    80002ae6:	f3dff0ef          	jal	80002a22 <clockintr>
    return 2;
    80002aea:	4509                	li	a0,2
    80002aec:	b77d                	j	80002a9a <devintr+0x22>

0000000080002aee <usertrap>:
{
    80002aee:	1101                	addi	sp,sp,-32
    80002af0:	ec06                	sd	ra,24(sp)
    80002af2:	e822                	sd	s0,16(sp)
    80002af4:	e426                	sd	s1,8(sp)
    80002af6:	e04a                	sd	s2,0(sp)
    80002af8:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002afa:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    80002afe:	1007f793          	andi	a5,a5,256
    80002b02:	eba5                	bnez	a5,80002b72 <usertrap+0x84>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002b04:	00003797          	auipc	a5,0x3
    80002b08:	f3c78793          	addi	a5,a5,-196 # 80005a40 <kernelvec>
    80002b0c:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80002b10:	930ff0ef          	jal	80001c40 <myproc>
    80002b14:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    80002b16:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002b18:	14102773          	csrr	a4,sepc
    80002b1c:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002b1e:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    80002b22:	47a1                	li	a5,8
    80002b24:	04f70d63          	beq	a4,a5,80002b7e <usertrap+0x90>
  } else if((which_dev = devintr()) != 0){
    80002b28:	f51ff0ef          	jal	80002a78 <devintr>
    80002b2c:	892a                	mv	s2,a0
    80002b2e:	e945                	bnez	a0,80002bde <usertrap+0xf0>
    80002b30:	14202773          	csrr	a4,scause
  } else if((r_scause() == 15 || r_scause() == 13) &&
    80002b34:	47bd                	li	a5,15
    80002b36:	08f70863          	beq	a4,a5,80002bc6 <usertrap+0xd8>
    80002b3a:	14202773          	csrr	a4,scause
    80002b3e:	47b5                	li	a5,13
    80002b40:	08f70363          	beq	a4,a5,80002bc6 <usertrap+0xd8>
    80002b44:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause 0x%lx pid=%d\n", r_scause(), p->pid);
    80002b48:	5890                	lw	a2,48(s1)
    80002b4a:	00005517          	auipc	a0,0x5
    80002b4e:	77650513          	addi	a0,a0,1910 # 800082c0 <etext+0x2c0>
    80002b52:	9dbfd0ef          	jal	8000052c <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002b56:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002b5a:	14302673          	csrr	a2,stval
    printf("            sepc=0x%lx stval=0x%lx\n", r_sepc(), r_stval());
    80002b5e:	00005517          	auipc	a0,0x5
    80002b62:	79250513          	addi	a0,a0,1938 # 800082f0 <etext+0x2f0>
    80002b66:	9c7fd0ef          	jal	8000052c <printf>
    setkilled(p);
    80002b6a:	8526                	mv	a0,s1
    80002b6c:	b19ff0ef          	jal	80002684 <setkilled>
    80002b70:	a035                	j	80002b9c <usertrap+0xae>
    panic("usertrap: not from user mode");
    80002b72:	00005517          	auipc	a0,0x5
    80002b76:	72e50513          	addi	a0,a0,1838 # 800082a0 <etext+0x2a0>
    80002b7a:	cddfd0ef          	jal	80000856 <panic>
    if(killed(p))
    80002b7e:	b2bff0ef          	jal	800026a8 <killed>
    80002b82:	ed15                	bnez	a0,80002bbe <usertrap+0xd0>
    p->trapframe->epc += 4;
    80002b84:	6cb8                	ld	a4,88(s1)
    80002b86:	6f1c                	ld	a5,24(a4)
    80002b88:	0791                	addi	a5,a5,4
    80002b8a:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002b8c:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002b90:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002b94:	10079073          	csrw	sstatus,a5
    syscall();
    80002b98:	240000ef          	jal	80002dd8 <syscall>
  if(killed(p))
    80002b9c:	8526                	mv	a0,s1
    80002b9e:	b0bff0ef          	jal	800026a8 <killed>
    80002ba2:	e139                	bnez	a0,80002be8 <usertrap+0xfa>
  prepare_return();
    80002ba4:	e05ff0ef          	jal	800029a8 <prepare_return>
  uint64 satp = MAKE_SATP(p->pagetable);
    80002ba8:	68a8                	ld	a0,80(s1)
    80002baa:	8131                	srli	a0,a0,0xc
    80002bac:	57fd                	li	a5,-1
    80002bae:	17fe                	slli	a5,a5,0x3f
    80002bb0:	8d5d                	or	a0,a0,a5
}
    80002bb2:	60e2                	ld	ra,24(sp)
    80002bb4:	6442                	ld	s0,16(sp)
    80002bb6:	64a2                	ld	s1,8(sp)
    80002bb8:	6902                	ld	s2,0(sp)
    80002bba:	6105                	addi	sp,sp,32
    80002bbc:	8082                	ret
      kexit(-1);
    80002bbe:	557d                	li	a0,-1
    80002bc0:	9b9ff0ef          	jal	80002578 <kexit>
    80002bc4:	b7c1                	j	80002b84 <usertrap+0x96>
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002bc6:	143025f3          	csrr	a1,stval
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002bca:	14202673          	csrr	a2,scause
            vmfault(p->pagetable, r_stval(), (r_scause() == 13)? 1 : 0) != 0) {
    80002bce:	164d                	addi	a2,a2,-13 # ff3 <_entry-0x7ffff00d>
    80002bd0:	00163613          	seqz	a2,a2
    80002bd4:	68a8                	ld	a0,80(s1)
    80002bd6:	ca5fe0ef          	jal	8000187a <vmfault>
  } else if((r_scause() == 15 || r_scause() == 13) &&
    80002bda:	f169                	bnez	a0,80002b9c <usertrap+0xae>
    80002bdc:	b7a5                	j	80002b44 <usertrap+0x56>
  if(killed(p))
    80002bde:	8526                	mv	a0,s1
    80002be0:	ac9ff0ef          	jal	800026a8 <killed>
    80002be4:	c511                	beqz	a0,80002bf0 <usertrap+0x102>
    80002be6:	a011                	j	80002bea <usertrap+0xfc>
    80002be8:	4901                	li	s2,0
    kexit(-1);
    80002bea:	557d                	li	a0,-1
    80002bec:	98dff0ef          	jal	80002578 <kexit>
  if(which_dev == 2)
    80002bf0:	4789                	li	a5,2
    80002bf2:	faf919e3          	bne	s2,a5,80002ba4 <usertrap+0xb6>
    yield();
    80002bf6:	84bff0ef          	jal	80002440 <yield>
    80002bfa:	b76d                	j	80002ba4 <usertrap+0xb6>

0000000080002bfc <kerneltrap>:
{
    80002bfc:	7179                	addi	sp,sp,-48
    80002bfe:	f406                	sd	ra,40(sp)
    80002c00:	f022                	sd	s0,32(sp)
    80002c02:	ec26                	sd	s1,24(sp)
    80002c04:	e84a                	sd	s2,16(sp)
    80002c06:	e44e                	sd	s3,8(sp)
    80002c08:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002c0a:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002c0e:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002c12:	142027f3          	csrr	a5,scause
    80002c16:	89be                	mv	s3,a5
  if((sstatus & SSTATUS_SPP) == 0)
    80002c18:	1004f793          	andi	a5,s1,256
    80002c1c:	c795                	beqz	a5,80002c48 <kerneltrap+0x4c>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002c1e:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002c22:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    80002c24:	eb85                	bnez	a5,80002c54 <kerneltrap+0x58>
  if((which_dev = devintr()) == 0){
    80002c26:	e53ff0ef          	jal	80002a78 <devintr>
    80002c2a:	c91d                	beqz	a0,80002c60 <kerneltrap+0x64>
  if(which_dev == 2 && myproc() != 0)
    80002c2c:	4789                	li	a5,2
    80002c2e:	04f50a63          	beq	a0,a5,80002c82 <kerneltrap+0x86>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002c32:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002c36:	10049073          	csrw	sstatus,s1
}
    80002c3a:	70a2                	ld	ra,40(sp)
    80002c3c:	7402                	ld	s0,32(sp)
    80002c3e:	64e2                	ld	s1,24(sp)
    80002c40:	6942                	ld	s2,16(sp)
    80002c42:	69a2                	ld	s3,8(sp)
    80002c44:	6145                	addi	sp,sp,48
    80002c46:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80002c48:	00005517          	auipc	a0,0x5
    80002c4c:	6d050513          	addi	a0,a0,1744 # 80008318 <etext+0x318>
    80002c50:	c07fd0ef          	jal	80000856 <panic>
    panic("kerneltrap: interrupts enabled");
    80002c54:	00005517          	auipc	a0,0x5
    80002c58:	6ec50513          	addi	a0,a0,1772 # 80008340 <etext+0x340>
    80002c5c:	bfbfd0ef          	jal	80000856 <panic>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002c60:	14102673          	csrr	a2,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002c64:	143026f3          	csrr	a3,stval
    printf("scause=0x%lx sepc=0x%lx stval=0x%lx\n", scause, r_sepc(), r_stval());
    80002c68:	85ce                	mv	a1,s3
    80002c6a:	00005517          	auipc	a0,0x5
    80002c6e:	6f650513          	addi	a0,a0,1782 # 80008360 <etext+0x360>
    80002c72:	8bbfd0ef          	jal	8000052c <printf>
    panic("kerneltrap");
    80002c76:	00005517          	auipc	a0,0x5
    80002c7a:	71250513          	addi	a0,a0,1810 # 80008388 <etext+0x388>
    80002c7e:	bd9fd0ef          	jal	80000856 <panic>
  if(which_dev == 2 && myproc() != 0)
    80002c82:	fbffe0ef          	jal	80001c40 <myproc>
    80002c86:	d555                	beqz	a0,80002c32 <kerneltrap+0x36>
    yield();
    80002c88:	fb8ff0ef          	jal	80002440 <yield>
    80002c8c:	b75d                	j	80002c32 <kerneltrap+0x36>

0000000080002c8e <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80002c8e:	1101                	addi	sp,sp,-32
    80002c90:	ec06                	sd	ra,24(sp)
    80002c92:	e822                	sd	s0,16(sp)
    80002c94:	e426                	sd	s1,8(sp)
    80002c96:	1000                	addi	s0,sp,32
    80002c98:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002c9a:	fa7fe0ef          	jal	80001c40 <myproc>
  switch (n) {
    80002c9e:	4795                	li	a5,5
    80002ca0:	0497e163          	bltu	a5,s1,80002ce2 <argraw+0x54>
    80002ca4:	048a                	slli	s1,s1,0x2
    80002ca6:	00006717          	auipc	a4,0x6
    80002caa:	b2a70713          	addi	a4,a4,-1238 # 800087d0 <states.0+0x30>
    80002cae:	94ba                	add	s1,s1,a4
    80002cb0:	409c                	lw	a5,0(s1)
    80002cb2:	97ba                	add	a5,a5,a4
    80002cb4:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    80002cb6:	6d3c                	ld	a5,88(a0)
    80002cb8:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80002cba:	60e2                	ld	ra,24(sp)
    80002cbc:	6442                	ld	s0,16(sp)
    80002cbe:	64a2                	ld	s1,8(sp)
    80002cc0:	6105                	addi	sp,sp,32
    80002cc2:	8082                	ret
    return p->trapframe->a1;
    80002cc4:	6d3c                	ld	a5,88(a0)
    80002cc6:	7fa8                	ld	a0,120(a5)
    80002cc8:	bfcd                	j	80002cba <argraw+0x2c>
    return p->trapframe->a2;
    80002cca:	6d3c                	ld	a5,88(a0)
    80002ccc:	63c8                	ld	a0,128(a5)
    80002cce:	b7f5                	j	80002cba <argraw+0x2c>
    return p->trapframe->a3;
    80002cd0:	6d3c                	ld	a5,88(a0)
    80002cd2:	67c8                	ld	a0,136(a5)
    80002cd4:	b7dd                	j	80002cba <argraw+0x2c>
    return p->trapframe->a4;
    80002cd6:	6d3c                	ld	a5,88(a0)
    80002cd8:	6bc8                	ld	a0,144(a5)
    80002cda:	b7c5                	j	80002cba <argraw+0x2c>
    return p->trapframe->a5;
    80002cdc:	6d3c                	ld	a5,88(a0)
    80002cde:	6fc8                	ld	a0,152(a5)
    80002ce0:	bfe9                	j	80002cba <argraw+0x2c>
  panic("argraw");
    80002ce2:	00005517          	auipc	a0,0x5
    80002ce6:	6b650513          	addi	a0,a0,1718 # 80008398 <etext+0x398>
    80002cea:	b6dfd0ef          	jal	80000856 <panic>

0000000080002cee <fetchaddr>:
{
    80002cee:	1101                	addi	sp,sp,-32
    80002cf0:	ec06                	sd	ra,24(sp)
    80002cf2:	e822                	sd	s0,16(sp)
    80002cf4:	e426                	sd	s1,8(sp)
    80002cf6:	e04a                	sd	s2,0(sp)
    80002cf8:	1000                	addi	s0,sp,32
    80002cfa:	84aa                	mv	s1,a0
    80002cfc:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002cfe:	f43fe0ef          	jal	80001c40 <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    80002d02:	653c                	ld	a5,72(a0)
    80002d04:	02f4f663          	bgeu	s1,a5,80002d30 <fetchaddr+0x42>
    80002d08:	00848713          	addi	a4,s1,8
    80002d0c:	02e7e463          	bltu	a5,a4,80002d34 <fetchaddr+0x46>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80002d10:	46a1                	li	a3,8
    80002d12:	8626                	mv	a2,s1
    80002d14:	85ca                	mv	a1,s2
    80002d16:	6928                	ld	a0,80(a0)
    80002d18:	cf9fe0ef          	jal	80001a10 <copyin>
    80002d1c:	00a03533          	snez	a0,a0
    80002d20:	40a0053b          	negw	a0,a0
}
    80002d24:	60e2                	ld	ra,24(sp)
    80002d26:	6442                	ld	s0,16(sp)
    80002d28:	64a2                	ld	s1,8(sp)
    80002d2a:	6902                	ld	s2,0(sp)
    80002d2c:	6105                	addi	sp,sp,32
    80002d2e:	8082                	ret
    return -1;
    80002d30:	557d                	li	a0,-1
    80002d32:	bfcd                	j	80002d24 <fetchaddr+0x36>
    80002d34:	557d                	li	a0,-1
    80002d36:	b7fd                	j	80002d24 <fetchaddr+0x36>

0000000080002d38 <fetchstr>:
{
    80002d38:	7179                	addi	sp,sp,-48
    80002d3a:	f406                	sd	ra,40(sp)
    80002d3c:	f022                	sd	s0,32(sp)
    80002d3e:	ec26                	sd	s1,24(sp)
    80002d40:	e84a                	sd	s2,16(sp)
    80002d42:	e44e                	sd	s3,8(sp)
    80002d44:	1800                	addi	s0,sp,48
    80002d46:	89aa                	mv	s3,a0
    80002d48:	84ae                	mv	s1,a1
    80002d4a:	8932                	mv	s2,a2
  struct proc *p = myproc();
    80002d4c:	ef5fe0ef          	jal	80001c40 <myproc>
  if(copyinstr(p->pagetable, buf, addr, max) < 0)
    80002d50:	86ca                	mv	a3,s2
    80002d52:	864e                	mv	a2,s3
    80002d54:	85a6                	mv	a1,s1
    80002d56:	6928                	ld	a0,80(a0)
    80002d58:	a4bfe0ef          	jal	800017a2 <copyinstr>
    80002d5c:	00054c63          	bltz	a0,80002d74 <fetchstr+0x3c>
  return strlen(buf);
    80002d60:	8526                	mv	a0,s1
    80002d62:	a1afe0ef          	jal	80000f7c <strlen>
}
    80002d66:	70a2                	ld	ra,40(sp)
    80002d68:	7402                	ld	s0,32(sp)
    80002d6a:	64e2                	ld	s1,24(sp)
    80002d6c:	6942                	ld	s2,16(sp)
    80002d6e:	69a2                	ld	s3,8(sp)
    80002d70:	6145                	addi	sp,sp,48
    80002d72:	8082                	ret
    return -1;
    80002d74:	557d                	li	a0,-1
    80002d76:	bfc5                	j	80002d66 <fetchstr+0x2e>

0000000080002d78 <argint>:

// Fetch the nth 32-bit system call argument.
void
argint(int n, int *ip)
{
    80002d78:	1101                	addi	sp,sp,-32
    80002d7a:	ec06                	sd	ra,24(sp)
    80002d7c:	e822                	sd	s0,16(sp)
    80002d7e:	e426                	sd	s1,8(sp)
    80002d80:	1000                	addi	s0,sp,32
    80002d82:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002d84:	f0bff0ef          	jal	80002c8e <argraw>
    80002d88:	c088                	sw	a0,0(s1)
}
    80002d8a:	60e2                	ld	ra,24(sp)
    80002d8c:	6442                	ld	s0,16(sp)
    80002d8e:	64a2                	ld	s1,8(sp)
    80002d90:	6105                	addi	sp,sp,32
    80002d92:	8082                	ret

0000000080002d94 <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void
argaddr(int n, uint64 *ip)
{
    80002d94:	1101                	addi	sp,sp,-32
    80002d96:	ec06                	sd	ra,24(sp)
    80002d98:	e822                	sd	s0,16(sp)
    80002d9a:	e426                	sd	s1,8(sp)
    80002d9c:	1000                	addi	s0,sp,32
    80002d9e:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002da0:	eefff0ef          	jal	80002c8e <argraw>
    80002da4:	e088                	sd	a0,0(s1)
}
    80002da6:	60e2                	ld	ra,24(sp)
    80002da8:	6442                	ld	s0,16(sp)
    80002daa:	64a2                	ld	s1,8(sp)
    80002dac:	6105                	addi	sp,sp,32
    80002dae:	8082                	ret

0000000080002db0 <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80002db0:	1101                	addi	sp,sp,-32
    80002db2:	ec06                	sd	ra,24(sp)
    80002db4:	e822                	sd	s0,16(sp)
    80002db6:	e426                	sd	s1,8(sp)
    80002db8:	e04a                	sd	s2,0(sp)
    80002dba:	1000                	addi	s0,sp,32
    80002dbc:	892e                	mv	s2,a1
    80002dbe:	84b2                	mv	s1,a2
  *ip = argraw(n);
    80002dc0:	ecfff0ef          	jal	80002c8e <argraw>
  uint64 addr;
  argaddr(n, &addr);
  return fetchstr(addr, buf, max);
    80002dc4:	8626                	mv	a2,s1
    80002dc6:	85ca                	mv	a1,s2
    80002dc8:	f71ff0ef          	jal	80002d38 <fetchstr>
}
    80002dcc:	60e2                	ld	ra,24(sp)
    80002dce:	6442                	ld	s0,16(sp)
    80002dd0:	64a2                	ld	s1,8(sp)
    80002dd2:	6902                	ld	s2,0(sp)
    80002dd4:	6105                	addi	sp,sp,32
    80002dd6:	8082                	ret

0000000080002dd8 <syscall>:

};

void
syscall(void)
{
    80002dd8:	1101                	addi	sp,sp,-32
    80002dda:	ec06                	sd	ra,24(sp)
    80002ddc:	e822                	sd	s0,16(sp)
    80002dde:	e426                	sd	s1,8(sp)
    80002de0:	e04a                	sd	s2,0(sp)
    80002de2:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    80002de4:	e5dfe0ef          	jal	80001c40 <myproc>
    80002de8:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    80002dea:	05853903          	ld	s2,88(a0)
    80002dee:	0a893783          	ld	a5,168(s2)
    80002df2:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80002df6:	37fd                	addiw	a5,a5,-1
    80002df8:	4761                	li	a4,24
    80002dfa:	00f76f63          	bltu	a4,a5,80002e18 <syscall+0x40>
    80002dfe:	00369713          	slli	a4,a3,0x3
    80002e02:	00006797          	auipc	a5,0x6
    80002e06:	9e678793          	addi	a5,a5,-1562 # 800087e8 <syscalls>
    80002e0a:	97ba                	add	a5,a5,a4
    80002e0c:	639c                	ld	a5,0(a5)
    80002e0e:	c789                	beqz	a5,80002e18 <syscall+0x40>
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    p->trapframe->a0 = syscalls[num]();
    80002e10:	9782                	jalr	a5
    80002e12:	06a93823          	sd	a0,112(s2)
    80002e16:	a829                	j	80002e30 <syscall+0x58>
  } else {
    printf("%d %s: unknown sys call %d\n",
    80002e18:	15848613          	addi	a2,s1,344
    80002e1c:	588c                	lw	a1,48(s1)
    80002e1e:	00005517          	auipc	a0,0x5
    80002e22:	58250513          	addi	a0,a0,1410 # 800083a0 <etext+0x3a0>
    80002e26:	f06fd0ef          	jal	8000052c <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80002e2a:	6cbc                	ld	a5,88(s1)
    80002e2c:	577d                	li	a4,-1
    80002e2e:	fbb8                	sd	a4,112(a5)
  }
}
    80002e30:	60e2                	ld	ra,24(sp)
    80002e32:	6442                	ld	s0,16(sp)
    80002e34:	64a2                	ld	s1,8(sp)
    80002e36:	6902                	ld	s2,0(sp)
    80002e38:	6105                	addi	sp,sp,32
    80002e3a:	8082                	ret

0000000080002e3c <sys_exit>:
#include "vm.h"
#include "schedlog.h"

uint64
sys_exit(void)
{
    80002e3c:	1101                	addi	sp,sp,-32
    80002e3e:	ec06                	sd	ra,24(sp)
    80002e40:	e822                	sd	s0,16(sp)
    80002e42:	1000                	addi	s0,sp,32
  int n;
  argint(0, &n);
    80002e44:	fec40593          	addi	a1,s0,-20
    80002e48:	4501                	li	a0,0
    80002e4a:	f2fff0ef          	jal	80002d78 <argint>
  kexit(n);
    80002e4e:	fec42503          	lw	a0,-20(s0)
    80002e52:	f26ff0ef          	jal	80002578 <kexit>
  return 0;  // not reached
}
    80002e56:	4501                	li	a0,0
    80002e58:	60e2                	ld	ra,24(sp)
    80002e5a:	6442                	ld	s0,16(sp)
    80002e5c:	6105                	addi	sp,sp,32
    80002e5e:	8082                	ret

0000000080002e60 <sys_getpid>:

uint64
sys_getpid(void)
{
    80002e60:	1141                	addi	sp,sp,-16
    80002e62:	e406                	sd	ra,8(sp)
    80002e64:	e022                	sd	s0,0(sp)
    80002e66:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80002e68:	dd9fe0ef          	jal	80001c40 <myproc>
}
    80002e6c:	5908                	lw	a0,48(a0)
    80002e6e:	60a2                	ld	ra,8(sp)
    80002e70:	6402                	ld	s0,0(sp)
    80002e72:	0141                	addi	sp,sp,16
    80002e74:	8082                	ret

0000000080002e76 <sys_fork>:

uint64
sys_fork(void)
{
    80002e76:	1141                	addi	sp,sp,-16
    80002e78:	e406                	sd	ra,8(sp)
    80002e7a:	e022                	sd	s0,0(sp)
    80002e7c:	0800                	addi	s0,sp,16
  return kfork();
    80002e7e:	996ff0ef          	jal	80002014 <kfork>
}
    80002e82:	60a2                	ld	ra,8(sp)
    80002e84:	6402                	ld	s0,0(sp)
    80002e86:	0141                	addi	sp,sp,16
    80002e88:	8082                	ret

0000000080002e8a <sys_wait>:

uint64
sys_wait(void)
{
    80002e8a:	1101                	addi	sp,sp,-32
    80002e8c:	ec06                	sd	ra,24(sp)
    80002e8e:	e822                	sd	s0,16(sp)
    80002e90:	1000                	addi	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    80002e92:	fe840593          	addi	a1,s0,-24
    80002e96:	4501                	li	a0,0
    80002e98:	efdff0ef          	jal	80002d94 <argaddr>
  return kwait(p);
    80002e9c:	fe843503          	ld	a0,-24(s0)
    80002ea0:	833ff0ef          	jal	800026d2 <kwait>
}
    80002ea4:	60e2                	ld	ra,24(sp)
    80002ea6:	6442                	ld	s0,16(sp)
    80002ea8:	6105                	addi	sp,sp,32
    80002eaa:	8082                	ret

0000000080002eac <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80002eac:	7179                	addi	sp,sp,-48
    80002eae:	f406                	sd	ra,40(sp)
    80002eb0:	f022                	sd	s0,32(sp)
    80002eb2:	ec26                	sd	s1,24(sp)
    80002eb4:	1800                	addi	s0,sp,48
  uint64 addr;
  int t;
  int n;

  argint(0, &n);
    80002eb6:	fd840593          	addi	a1,s0,-40
    80002eba:	4501                	li	a0,0
    80002ebc:	ebdff0ef          	jal	80002d78 <argint>
  argint(1, &t);
    80002ec0:	fdc40593          	addi	a1,s0,-36
    80002ec4:	4505                	li	a0,1
    80002ec6:	eb3ff0ef          	jal	80002d78 <argint>
  addr = myproc()->sz;
    80002eca:	d77fe0ef          	jal	80001c40 <myproc>
    80002ece:	6524                	ld	s1,72(a0)

  if(t == SBRK_EAGER || n < 0) {
    80002ed0:	fdc42703          	lw	a4,-36(s0)
    80002ed4:	4785                	li	a5,1
    80002ed6:	02f70763          	beq	a4,a5,80002f04 <sys_sbrk+0x58>
    80002eda:	fd842783          	lw	a5,-40(s0)
    80002ede:	0207c363          	bltz	a5,80002f04 <sys_sbrk+0x58>
    }
  } else {
    // Lazily allocate memory for this process: increase its memory
    // size but don't allocate memory. If the processes uses the
    // memory, vmfault() will allocate it.
    if(addr + n < addr)
    80002ee2:	97a6                	add	a5,a5,s1
      return -1;
    if(addr + n > TRAPFRAME)
    80002ee4:	02000737          	lui	a4,0x2000
    80002ee8:	177d                	addi	a4,a4,-1 # 1ffffff <_entry-0x7e000001>
    80002eea:	0736                	slli	a4,a4,0xd
    80002eec:	02f76a63          	bltu	a4,a5,80002f20 <sys_sbrk+0x74>
    80002ef0:	0297e863          	bltu	a5,s1,80002f20 <sys_sbrk+0x74>
      return -1;
    myproc()->sz += n;
    80002ef4:	d4dfe0ef          	jal	80001c40 <myproc>
    80002ef8:	fd842703          	lw	a4,-40(s0)
    80002efc:	653c                	ld	a5,72(a0)
    80002efe:	97ba                	add	a5,a5,a4
    80002f00:	e53c                	sd	a5,72(a0)
    80002f02:	a039                	j	80002f10 <sys_sbrk+0x64>
    if(growproc(n) < 0) {
    80002f04:	fd842503          	lw	a0,-40(s0)
    80002f08:	83eff0ef          	jal	80001f46 <growproc>
    80002f0c:	00054863          	bltz	a0,80002f1c <sys_sbrk+0x70>
  }
  return addr;
}
    80002f10:	8526                	mv	a0,s1
    80002f12:	70a2                	ld	ra,40(sp)
    80002f14:	7402                	ld	s0,32(sp)
    80002f16:	64e2                	ld	s1,24(sp)
    80002f18:	6145                	addi	sp,sp,48
    80002f1a:	8082                	ret
      return -1;
    80002f1c:	54fd                	li	s1,-1
    80002f1e:	bfcd                	j	80002f10 <sys_sbrk+0x64>
      return -1;
    80002f20:	54fd                	li	s1,-1
    80002f22:	b7fd                	j	80002f10 <sys_sbrk+0x64>

0000000080002f24 <sys_pause>:

uint64
sys_pause(void)
{
    80002f24:	7139                	addi	sp,sp,-64
    80002f26:	fc06                	sd	ra,56(sp)
    80002f28:	f822                	sd	s0,48(sp)
    80002f2a:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    80002f2c:	fcc40593          	addi	a1,s0,-52
    80002f30:	4501                	li	a0,0
    80002f32:	e47ff0ef          	jal	80002d78 <argint>
  if(n < 0)
    80002f36:	fcc42783          	lw	a5,-52(s0)
    80002f3a:	0607c863          	bltz	a5,80002faa <sys_pause+0x86>
    n = 0;
  acquire(&tickslock);
    80002f3e:	00015517          	auipc	a0,0x15
    80002f42:	03250513          	addi	a0,a0,50 # 80017f70 <tickslock>
    80002f46:	dddfd0ef          	jal	80000d22 <acquire>
  ticks0 = ticks;
  while(ticks - ticks0 < n){
    80002f4a:	fcc42783          	lw	a5,-52(s0)
    80002f4e:	c3b9                	beqz	a5,80002f94 <sys_pause+0x70>
    80002f50:	f426                	sd	s1,40(sp)
    80002f52:	f04a                	sd	s2,32(sp)
    80002f54:	ec4e                	sd	s3,24(sp)
  ticks0 = ticks;
    80002f56:	00006997          	auipc	s3,0x6
    80002f5a:	0da9a983          	lw	s3,218(s3) # 80009030 <ticks>
    if(killed(myproc())){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80002f5e:	00015917          	auipc	s2,0x15
    80002f62:	01290913          	addi	s2,s2,18 # 80017f70 <tickslock>
    80002f66:	00006497          	auipc	s1,0x6
    80002f6a:	0ca48493          	addi	s1,s1,202 # 80009030 <ticks>
    if(killed(myproc())){
    80002f6e:	cd3fe0ef          	jal	80001c40 <myproc>
    80002f72:	f36ff0ef          	jal	800026a8 <killed>
    80002f76:	ed0d                	bnez	a0,80002fb0 <sys_pause+0x8c>
    sleep(&ticks, &tickslock);
    80002f78:	85ca                	mv	a1,s2
    80002f7a:	8526                	mv	a0,s1
    80002f7c:	cf0ff0ef          	jal	8000246c <sleep>
  while(ticks - ticks0 < n){
    80002f80:	409c                	lw	a5,0(s1)
    80002f82:	413787bb          	subw	a5,a5,s3
    80002f86:	fcc42703          	lw	a4,-52(s0)
    80002f8a:	fee7e2e3          	bltu	a5,a4,80002f6e <sys_pause+0x4a>
    80002f8e:	74a2                	ld	s1,40(sp)
    80002f90:	7902                	ld	s2,32(sp)
    80002f92:	69e2                	ld	s3,24(sp)
  }
  release(&tickslock);
    80002f94:	00015517          	auipc	a0,0x15
    80002f98:	fdc50513          	addi	a0,a0,-36 # 80017f70 <tickslock>
    80002f9c:	e1bfd0ef          	jal	80000db6 <release>
  return 0;
    80002fa0:	4501                	li	a0,0
}
    80002fa2:	70e2                	ld	ra,56(sp)
    80002fa4:	7442                	ld	s0,48(sp)
    80002fa6:	6121                	addi	sp,sp,64
    80002fa8:	8082                	ret
    n = 0;
    80002faa:	fc042623          	sw	zero,-52(s0)
    80002fae:	bf41                	j	80002f3e <sys_pause+0x1a>
      release(&tickslock);
    80002fb0:	00015517          	auipc	a0,0x15
    80002fb4:	fc050513          	addi	a0,a0,-64 # 80017f70 <tickslock>
    80002fb8:	dfffd0ef          	jal	80000db6 <release>
      return -1;
    80002fbc:	557d                	li	a0,-1
    80002fbe:	74a2                	ld	s1,40(sp)
    80002fc0:	7902                	ld	s2,32(sp)
    80002fc2:	69e2                	ld	s3,24(sp)
    80002fc4:	bff9                	j	80002fa2 <sys_pause+0x7e>

0000000080002fc6 <sys_kill>:

uint64
sys_kill(void)
{
    80002fc6:	1101                	addi	sp,sp,-32
    80002fc8:	ec06                	sd	ra,24(sp)
    80002fca:	e822                	sd	s0,16(sp)
    80002fcc:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    80002fce:	fec40593          	addi	a1,s0,-20
    80002fd2:	4501                	li	a0,0
    80002fd4:	da5ff0ef          	jal	80002d78 <argint>
  return kkill(pid);
    80002fd8:	fec42503          	lw	a0,-20(s0)
    80002fdc:	e42ff0ef          	jal	8000261e <kkill>
}
    80002fe0:	60e2                	ld	ra,24(sp)
    80002fe2:	6442                	ld	s0,16(sp)
    80002fe4:	6105                	addi	sp,sp,32
    80002fe6:	8082                	ret

0000000080002fe8 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80002fe8:	1101                	addi	sp,sp,-32
    80002fea:	ec06                	sd	ra,24(sp)
    80002fec:	e822                	sd	s0,16(sp)
    80002fee:	e426                	sd	s1,8(sp)
    80002ff0:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80002ff2:	00015517          	auipc	a0,0x15
    80002ff6:	f7e50513          	addi	a0,a0,-130 # 80017f70 <tickslock>
    80002ffa:	d29fd0ef          	jal	80000d22 <acquire>
  xticks = ticks;
    80002ffe:	00006797          	auipc	a5,0x6
    80003002:	0327a783          	lw	a5,50(a5) # 80009030 <ticks>
    80003006:	84be                	mv	s1,a5
  release(&tickslock);
    80003008:	00015517          	auipc	a0,0x15
    8000300c:	f6850513          	addi	a0,a0,-152 # 80017f70 <tickslock>
    80003010:	da7fd0ef          	jal	80000db6 <release>
  return xticks;
}
    80003014:	02049513          	slli	a0,s1,0x20
    80003018:	9101                	srli	a0,a0,0x20
    8000301a:	60e2                	ld	ra,24(sp)
    8000301c:	6442                	ld	s0,16(sp)
    8000301e:	64a2                	ld	s1,8(sp)
    80003020:	6105                	addi	sp,sp,32
    80003022:	8082                	ret

0000000080003024 <sys_schedread>:

uint64
sys_schedread(void)
{
    80003024:	7131                	addi	sp,sp,-192
    80003026:	fd06                	sd	ra,184(sp)
    80003028:	f922                	sd	s0,176(sp)
    8000302a:	f526                	sd	s1,168(sp)
    8000302c:	f14a                	sd	s2,160(sp)
    8000302e:	0180                	addi	s0,sp,192
    80003030:	81010113          	addi	sp,sp,-2032
  uint64 dst;
  int max;

  argaddr(0, &dst);
    80003034:	fd840593          	addi	a1,s0,-40
    80003038:	4501                	li	a0,0
    8000303a:	d5bff0ef          	jal	80002d94 <argaddr>
  argint(1, &max);
    8000303e:	fd440593          	addi	a1,s0,-44
    80003042:	4505                	li	a0,1
    80003044:	d35ff0ef          	jal	80002d78 <argint>

  if(max <= 0)
    80003048:	fd442783          	lw	a5,-44(s0)
    return 0;
    8000304c:	4901                	li	s2,0
  if(max <= 0)
    8000304e:	04f05963          	blez	a5,800030a0 <sys_schedread+0x7c>

  struct sched_event buf[32];
  if(max > 32)
    80003052:	02000713          	li	a4,32
    80003056:	00f75463          	bge	a4,a5,8000305e <sys_schedread+0x3a>
    max = 32;
    8000305a:	fce42a23          	sw	a4,-44(s0)

  int n = schedread(buf, max);
    8000305e:	fd442583          	lw	a1,-44(s0)
    80003062:	80040513          	addi	a0,s0,-2048
    80003066:	1501                	addi	a0,a0,-32
    80003068:	f7050513          	addi	a0,a0,-144
    8000306c:	732030ef          	jal	8000679e <schedread>
    80003070:	84aa                	mv	s1,a0
  if(n < 0)
    return -1;
    80003072:	57fd                	li	a5,-1
    80003074:	893e                	mv	s2,a5
  if(n < 0)
    80003076:	02054563          	bltz	a0,800030a0 <sys_schedread+0x7c>

  if(copyout(myproc()->pagetable, dst, (char *)buf, n * sizeof(struct sched_event)) < 0)
    8000307a:	bc7fe0ef          	jal	80001c40 <myproc>
    8000307e:	8926                	mv	s2,s1
    80003080:	00449693          	slli	a3,s1,0x4
    80003084:	96a6                	add	a3,a3,s1
    80003086:	068a                	slli	a3,a3,0x2
    80003088:	80040613          	addi	a2,s0,-2048
    8000308c:	1601                	addi	a2,a2,-32
    8000308e:	f7060613          	addi	a2,a2,-144
    80003092:	fd843583          	ld	a1,-40(s0)
    80003096:	6928                	ld	a0,80(a0)
    80003098:	8bbfe0ef          	jal	80001952 <copyout>
    8000309c:	00054b63          	bltz	a0,800030b2 <sys_schedread+0x8e>
    return -1;

  return n;
}
    800030a0:	854a                	mv	a0,s2
    800030a2:	7f010113          	addi	sp,sp,2032
    800030a6:	70ea                	ld	ra,184(sp)
    800030a8:	744a                	ld	s0,176(sp)
    800030aa:	74aa                	ld	s1,168(sp)
    800030ac:	790a                	ld	s2,160(sp)
    800030ae:	6129                	addi	sp,sp,192
    800030b0:	8082                	ret
    return -1;
    800030b2:	57fd                	li	a5,-1
    800030b4:	893e                	mv	s2,a5
    800030b6:	b7ed                	j	800030a0 <sys_schedread+0x7c>

00000000800030b8 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    800030b8:	7179                	addi	sp,sp,-48
    800030ba:	f406                	sd	ra,40(sp)
    800030bc:	f022                	sd	s0,32(sp)
    800030be:	ec26                	sd	s1,24(sp)
    800030c0:	e84a                	sd	s2,16(sp)
    800030c2:	e44e                	sd	s3,8(sp)
    800030c4:	e052                	sd	s4,0(sp)
    800030c6:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    800030c8:	00005597          	auipc	a1,0x5
    800030cc:	2f858593          	addi	a1,a1,760 # 800083c0 <etext+0x3c0>
    800030d0:	00015517          	auipc	a0,0x15
    800030d4:	eb850513          	addi	a0,a0,-328 # 80017f88 <bcache>
    800030d8:	bc1fd0ef          	jal	80000c98 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    800030dc:	0001d797          	auipc	a5,0x1d
    800030e0:	eac78793          	addi	a5,a5,-340 # 8001ff88 <bcache+0x8000>
    800030e4:	0001d717          	auipc	a4,0x1d
    800030e8:	10c70713          	addi	a4,a4,268 # 800201f0 <bcache+0x8268>
    800030ec:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    800030f0:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    800030f4:	00015497          	auipc	s1,0x15
    800030f8:	eac48493          	addi	s1,s1,-340 # 80017fa0 <bcache+0x18>
    b->next = bcache.head.next;
    800030fc:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    800030fe:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80003100:	00005a17          	auipc	s4,0x5
    80003104:	2c8a0a13          	addi	s4,s4,712 # 800083c8 <etext+0x3c8>
    b->next = bcache.head.next;
    80003108:	2b893783          	ld	a5,696(s2)
    8000310c:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    8000310e:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80003112:	85d2                	mv	a1,s4
    80003114:	01048513          	addi	a0,s1,16
    80003118:	366010ef          	jal	8000447e <initsleeplock>
    bcache.head.next->prev = b;
    8000311c:	2b893783          	ld	a5,696(s2)
    80003120:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80003122:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80003126:	45848493          	addi	s1,s1,1112
    8000312a:	fd349fe3          	bne	s1,s3,80003108 <binit+0x50>
  }
}
    8000312e:	70a2                	ld	ra,40(sp)
    80003130:	7402                	ld	s0,32(sp)
    80003132:	64e2                	ld	s1,24(sp)
    80003134:	6942                	ld	s2,16(sp)
    80003136:	69a2                	ld	s3,8(sp)
    80003138:	6a02                	ld	s4,0(sp)
    8000313a:	6145                	addi	sp,sp,48
    8000313c:	8082                	ret

000000008000313e <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    8000313e:	7179                	addi	sp,sp,-48
    80003140:	f406                	sd	ra,40(sp)
    80003142:	f022                	sd	s0,32(sp)
    80003144:	ec26                	sd	s1,24(sp)
    80003146:	e84a                	sd	s2,16(sp)
    80003148:	e44e                	sd	s3,8(sp)
    8000314a:	1800                	addi	s0,sp,48
    8000314c:	892a                	mv	s2,a0
    8000314e:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    80003150:	00015517          	auipc	a0,0x15
    80003154:	e3850513          	addi	a0,a0,-456 # 80017f88 <bcache>
    80003158:	bcbfd0ef          	jal	80000d22 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    8000315c:	0001d497          	auipc	s1,0x1d
    80003160:	0e44b483          	ld	s1,228(s1) # 80020240 <bcache+0x82b8>
    80003164:	0001d797          	auipc	a5,0x1d
    80003168:	08c78793          	addi	a5,a5,140 # 800201f0 <bcache+0x8268>
    8000316c:	04f48563          	beq	s1,a5,800031b6 <bread+0x78>
    80003170:	873e                	mv	a4,a5
    80003172:	a021                	j	8000317a <bread+0x3c>
    80003174:	68a4                	ld	s1,80(s1)
    80003176:	04e48063          	beq	s1,a4,800031b6 <bread+0x78>
    if(b->dev == dev && b->blockno == blockno){
    8000317a:	449c                	lw	a5,8(s1)
    8000317c:	ff279ce3          	bne	a5,s2,80003174 <bread+0x36>
    80003180:	44dc                	lw	a5,12(s1)
    80003182:	ff3799e3          	bne	a5,s3,80003174 <bread+0x36>
      b->refcnt++;
    80003186:	40bc                	lw	a5,64(s1)
    80003188:	2785                	addiw	a5,a5,1
    8000318a:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    8000318c:	00015517          	auipc	a0,0x15
    80003190:	dfc50513          	addi	a0,a0,-516 # 80017f88 <bcache>
    80003194:	c23fd0ef          	jal	80000db6 <release>
      acquiresleep(&b->lock);
    80003198:	01048513          	addi	a0,s1,16
    8000319c:	318010ef          	jal	800044b4 <acquiresleep>
      fslog_push(FS_BGET_HIT, 0, blockno, 0, "BCACHE");
    800031a0:	00005717          	auipc	a4,0x5
    800031a4:	23070713          	addi	a4,a4,560 # 800083d0 <etext+0x3d0>
    800031a8:	4681                	li	a3,0
    800031aa:	864e                	mv	a2,s3
    800031ac:	4581                	li	a1,0
    800031ae:	4519                	li	a0,6
    800031b0:	1e0030ef          	jal	80006390 <fslog_push>
      return b;
    800031b4:	a09d                	j	8000321a <bread+0xdc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    800031b6:	0001d497          	auipc	s1,0x1d
    800031ba:	0824b483          	ld	s1,130(s1) # 80020238 <bcache+0x82b0>
    800031be:	0001d797          	auipc	a5,0x1d
    800031c2:	03278793          	addi	a5,a5,50 # 800201f0 <bcache+0x8268>
    800031c6:	00f48863          	beq	s1,a5,800031d6 <bread+0x98>
    800031ca:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    800031cc:	40bc                	lw	a5,64(s1)
    800031ce:	cb91                	beqz	a5,800031e2 <bread+0xa4>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    800031d0:	64a4                	ld	s1,72(s1)
    800031d2:	fee49de3          	bne	s1,a4,800031cc <bread+0x8e>
  panic("bget: no buffers");
    800031d6:	00005517          	auipc	a0,0x5
    800031da:	20250513          	addi	a0,a0,514 # 800083d8 <etext+0x3d8>
    800031de:	e78fd0ef          	jal	80000856 <panic>
      b->dev = dev;
    800031e2:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    800031e6:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    800031ea:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    800031ee:	4785                	li	a5,1
    800031f0:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    800031f2:	00015517          	auipc	a0,0x15
    800031f6:	d9650513          	addi	a0,a0,-618 # 80017f88 <bcache>
    800031fa:	bbdfd0ef          	jal	80000db6 <release>
      acquiresleep(&b->lock);
    800031fe:	01048513          	addi	a0,s1,16
    80003202:	2b2010ef          	jal	800044b4 <acquiresleep>
      fslog_push(FS_BGET_MISS, 0, blockno, 0, "BCACHE");
    80003206:	00005717          	auipc	a4,0x5
    8000320a:	1ca70713          	addi	a4,a4,458 # 800083d0 <etext+0x3d0>
    8000320e:	4681                	li	a3,0
    80003210:	864e                	mv	a2,s3
    80003212:	4581                	li	a1,0
    80003214:	451d                	li	a0,7
    80003216:	17a030ef          	jal	80006390 <fslog_push>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    8000321a:	409c                	lw	a5,0(s1)
    8000321c:	cb89                	beqz	a5,8000322e <bread+0xf0>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    8000321e:	8526                	mv	a0,s1
    80003220:	70a2                	ld	ra,40(sp)
    80003222:	7402                	ld	s0,32(sp)
    80003224:	64e2                	ld	s1,24(sp)
    80003226:	6942                	ld	s2,16(sp)
    80003228:	69a2                	ld	s3,8(sp)
    8000322a:	6145                	addi	sp,sp,48
    8000322c:	8082                	ret
    virtio_disk_rw(b, 0);
    8000322e:	4581                	li	a1,0
    80003230:	8526                	mv	a0,s1
    80003232:	33f020ef          	jal	80005d70 <virtio_disk_rw>
    b->valid = 1;
    80003236:	4785                	li	a5,1
    80003238:	c09c                	sw	a5,0(s1)
  return b;
    8000323a:	b7d5                	j	8000321e <bread+0xe0>

000000008000323c <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    8000323c:	1101                	addi	sp,sp,-32
    8000323e:	ec06                	sd	ra,24(sp)
    80003240:	e822                	sd	s0,16(sp)
    80003242:	e426                	sd	s1,8(sp)
    80003244:	1000                	addi	s0,sp,32
    80003246:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80003248:	0541                	addi	a0,a0,16
    8000324a:	2e8010ef          	jal	80004532 <holdingsleep>
    8000324e:	c911                	beqz	a0,80003262 <bwrite+0x26>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    80003250:	4585                	li	a1,1
    80003252:	8526                	mv	a0,s1
    80003254:	31d020ef          	jal	80005d70 <virtio_disk_rw>
}
    80003258:	60e2                	ld	ra,24(sp)
    8000325a:	6442                	ld	s0,16(sp)
    8000325c:	64a2                	ld	s1,8(sp)
    8000325e:	6105                	addi	sp,sp,32
    80003260:	8082                	ret
    panic("bwrite");
    80003262:	00005517          	auipc	a0,0x5
    80003266:	18e50513          	addi	a0,a0,398 # 800083f0 <etext+0x3f0>
    8000326a:	decfd0ef          	jal	80000856 <panic>

000000008000326e <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    8000326e:	1101                	addi	sp,sp,-32
    80003270:	ec06                	sd	ra,24(sp)
    80003272:	e822                	sd	s0,16(sp)
    80003274:	e426                	sd	s1,8(sp)
    80003276:	e04a                	sd	s2,0(sp)
    80003278:	1000                	addi	s0,sp,32
    8000327a:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    8000327c:	01050913          	addi	s2,a0,16
    80003280:	854a                	mv	a0,s2
    80003282:	2b0010ef          	jal	80004532 <holdingsleep>
    80003286:	c915                	beqz	a0,800032ba <brelse+0x4c>
    panic("brelse");

  releasesleep(&b->lock);
    80003288:	854a                	mv	a0,s2
    8000328a:	270010ef          	jal	800044fa <releasesleep>

  acquire(&bcache.lock);
    8000328e:	00015517          	auipc	a0,0x15
    80003292:	cfa50513          	addi	a0,a0,-774 # 80017f88 <bcache>
    80003296:	a8dfd0ef          	jal	80000d22 <acquire>
  b->refcnt--;
    8000329a:	40bc                	lw	a5,64(s1)
    8000329c:	37fd                	addiw	a5,a5,-1
    8000329e:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    800032a0:	c39d                	beqz	a5,800032c6 <brelse+0x58>
    bcache.head.next->prev = b;
    bcache.head.next = b;
    fslog_push(FS_BRELEASE, 0, b->blockno, 0, "BCACHE");
  }
  
  release(&bcache.lock);
    800032a2:	00015517          	auipc	a0,0x15
    800032a6:	ce650513          	addi	a0,a0,-794 # 80017f88 <bcache>
    800032aa:	b0dfd0ef          	jal	80000db6 <release>
}
    800032ae:	60e2                	ld	ra,24(sp)
    800032b0:	6442                	ld	s0,16(sp)
    800032b2:	64a2                	ld	s1,8(sp)
    800032b4:	6902                	ld	s2,0(sp)
    800032b6:	6105                	addi	sp,sp,32
    800032b8:	8082                	ret
    panic("brelse");
    800032ba:	00005517          	auipc	a0,0x5
    800032be:	13e50513          	addi	a0,a0,318 # 800083f8 <etext+0x3f8>
    800032c2:	d94fd0ef          	jal	80000856 <panic>
    b->next->prev = b->prev;
    800032c6:	68b8                	ld	a4,80(s1)
    800032c8:	64bc                	ld	a5,72(s1)
    800032ca:	e73c                	sd	a5,72(a4)
    b->prev->next = b->next;
    800032cc:	68b8                	ld	a4,80(s1)
    800032ce:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    800032d0:	0001d797          	auipc	a5,0x1d
    800032d4:	cb878793          	addi	a5,a5,-840 # 8001ff88 <bcache+0x8000>
    800032d8:	2b87b703          	ld	a4,696(a5)
    800032dc:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    800032de:	0001d717          	auipc	a4,0x1d
    800032e2:	f1270713          	addi	a4,a4,-238 # 800201f0 <bcache+0x8268>
    800032e6:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    800032e8:	2b87b703          	ld	a4,696(a5)
    800032ec:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    800032ee:	2a97bc23          	sd	s1,696(a5)
    fslog_push(FS_BRELEASE, 0, b->blockno, 0, "BCACHE");
    800032f2:	00005717          	auipc	a4,0x5
    800032f6:	0de70713          	addi	a4,a4,222 # 800083d0 <etext+0x3d0>
    800032fa:	4681                	li	a3,0
    800032fc:	44d0                	lw	a2,12(s1)
    800032fe:	4581                	li	a1,0
    80003300:	4521                	li	a0,8
    80003302:	08e030ef          	jal	80006390 <fslog_push>
    80003306:	bf71                	j	800032a2 <brelse+0x34>

0000000080003308 <bpin>:

void
bpin(struct buf *b) {
    80003308:	1101                	addi	sp,sp,-32
    8000330a:	ec06                	sd	ra,24(sp)
    8000330c:	e822                	sd	s0,16(sp)
    8000330e:	e426                	sd	s1,8(sp)
    80003310:	1000                	addi	s0,sp,32
    80003312:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80003314:	00015517          	auipc	a0,0x15
    80003318:	c7450513          	addi	a0,a0,-908 # 80017f88 <bcache>
    8000331c:	a07fd0ef          	jal	80000d22 <acquire>
  b->refcnt++;
    80003320:	40bc                	lw	a5,64(s1)
    80003322:	2785                	addiw	a5,a5,1
    80003324:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80003326:	00015517          	auipc	a0,0x15
    8000332a:	c6250513          	addi	a0,a0,-926 # 80017f88 <bcache>
    8000332e:	a89fd0ef          	jal	80000db6 <release>
}
    80003332:	60e2                	ld	ra,24(sp)
    80003334:	6442                	ld	s0,16(sp)
    80003336:	64a2                	ld	s1,8(sp)
    80003338:	6105                	addi	sp,sp,32
    8000333a:	8082                	ret

000000008000333c <bunpin>:

void
bunpin(struct buf *b) {
    8000333c:	1101                	addi	sp,sp,-32
    8000333e:	ec06                	sd	ra,24(sp)
    80003340:	e822                	sd	s0,16(sp)
    80003342:	e426                	sd	s1,8(sp)
    80003344:	1000                	addi	s0,sp,32
    80003346:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80003348:	00015517          	auipc	a0,0x15
    8000334c:	c4050513          	addi	a0,a0,-960 # 80017f88 <bcache>
    80003350:	9d3fd0ef          	jal	80000d22 <acquire>
  b->refcnt--;
    80003354:	40bc                	lw	a5,64(s1)
    80003356:	37fd                	addiw	a5,a5,-1
    80003358:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    8000335a:	00015517          	auipc	a0,0x15
    8000335e:	c2e50513          	addi	a0,a0,-978 # 80017f88 <bcache>
    80003362:	a55fd0ef          	jal	80000db6 <release>
}
    80003366:	60e2                	ld	ra,24(sp)
    80003368:	6442                	ld	s0,16(sp)
    8000336a:	64a2                	ld	s1,8(sp)
    8000336c:	6105                	addi	sp,sp,32
    8000336e:	8082                	ret

0000000080003370 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    80003370:	1101                	addi	sp,sp,-32
    80003372:	ec06                	sd	ra,24(sp)
    80003374:	e822                	sd	s0,16(sp)
    80003376:	e426                	sd	s1,8(sp)
    80003378:	e04a                	sd	s2,0(sp)
    8000337a:	1000                	addi	s0,sp,32
    8000337c:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    8000337e:	00d5d79b          	srliw	a5,a1,0xd
    80003382:	0001d597          	auipc	a1,0x1d
    80003386:	2e25a583          	lw	a1,738(a1) # 80020664 <sb+0x1c>
    8000338a:	9dbd                	addw	a1,a1,a5
    8000338c:	db3ff0ef          	jal	8000313e <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    80003390:	0074f713          	andi	a4,s1,7
    80003394:	4785                	li	a5,1
    80003396:	00e797bb          	sllw	a5,a5,a4
  bi = b % BPB;
    8000339a:	14ce                	slli	s1,s1,0x33
  if((bp->data[bi/8] & m) == 0)
    8000339c:	90d9                	srli	s1,s1,0x36
    8000339e:	00950733          	add	a4,a0,s1
    800033a2:	05874703          	lbu	a4,88(a4)
    800033a6:	00e7f6b3          	and	a3,a5,a4
    800033aa:	c29d                	beqz	a3,800033d0 <bfree+0x60>
    800033ac:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    800033ae:	94aa                	add	s1,s1,a0
    800033b0:	fff7c793          	not	a5,a5
    800033b4:	8f7d                	and	a4,a4,a5
    800033b6:	04e48c23          	sb	a4,88(s1)
  log_write(bp);
    800033ba:	000010ef          	jal	800043ba <log_write>
  brelse(bp);
    800033be:	854a                	mv	a0,s2
    800033c0:	eafff0ef          	jal	8000326e <brelse>
}
    800033c4:	60e2                	ld	ra,24(sp)
    800033c6:	6442                	ld	s0,16(sp)
    800033c8:	64a2                	ld	s1,8(sp)
    800033ca:	6902                	ld	s2,0(sp)
    800033cc:	6105                	addi	sp,sp,32
    800033ce:	8082                	ret
    panic("freeing free block");
    800033d0:	00005517          	auipc	a0,0x5
    800033d4:	03050513          	addi	a0,a0,48 # 80008400 <etext+0x400>
    800033d8:	c7efd0ef          	jal	80000856 <panic>

00000000800033dc <balloc>:
{
    800033dc:	715d                	addi	sp,sp,-80
    800033de:	e486                	sd	ra,72(sp)
    800033e0:	e0a2                	sd	s0,64(sp)
    800033e2:	fc26                	sd	s1,56(sp)
    800033e4:	0880                	addi	s0,sp,80
  for(b = 0; b < sb.size; b += BPB){
    800033e6:	0001d797          	auipc	a5,0x1d
    800033ea:	2667a783          	lw	a5,614(a5) # 8002064c <sb+0x4>
    800033ee:	0e078263          	beqz	a5,800034d2 <balloc+0xf6>
    800033f2:	f84a                	sd	s2,48(sp)
    800033f4:	f44e                	sd	s3,40(sp)
    800033f6:	f052                	sd	s4,32(sp)
    800033f8:	ec56                	sd	s5,24(sp)
    800033fa:	e85a                	sd	s6,16(sp)
    800033fc:	e45e                	sd	s7,8(sp)
    800033fe:	e062                	sd	s8,0(sp)
    80003400:	8baa                	mv	s7,a0
    80003402:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    80003404:	0001db17          	auipc	s6,0x1d
    80003408:	244b0b13          	addi	s6,s6,580 # 80020648 <sb>
      m = 1 << (bi % 8);
    8000340c:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000340e:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    80003410:	6c09                	lui	s8,0x2
    80003412:	a09d                	j	80003478 <balloc+0x9c>
        bp->data[bi/8] |= m;  // Mark block in use.
    80003414:	97ca                	add	a5,a5,s2
    80003416:	8e55                	or	a2,a2,a3
    80003418:	04c78c23          	sb	a2,88(a5)
        log_write(bp);
    8000341c:	854a                	mv	a0,s2
    8000341e:	79d000ef          	jal	800043ba <log_write>
        brelse(bp);
    80003422:	854a                	mv	a0,s2
    80003424:	e4bff0ef          	jal	8000326e <brelse>
  bp = bread(dev, bno);
    80003428:	85a6                	mv	a1,s1
    8000342a:	855e                	mv	a0,s7
    8000342c:	d13ff0ef          	jal	8000313e <bread>
    80003430:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    80003432:	40000613          	li	a2,1024
    80003436:	4581                	li	a1,0
    80003438:	05850513          	addi	a0,a0,88
    8000343c:	9b7fd0ef          	jal	80000df2 <memset>
  log_write(bp);
    80003440:	854a                	mv	a0,s2
    80003442:	779000ef          	jal	800043ba <log_write>
  brelse(bp);
    80003446:	854a                	mv	a0,s2
    80003448:	e27ff0ef          	jal	8000326e <brelse>
}
    8000344c:	7942                	ld	s2,48(sp)
    8000344e:	79a2                	ld	s3,40(sp)
    80003450:	7a02                	ld	s4,32(sp)
    80003452:	6ae2                	ld	s5,24(sp)
    80003454:	6b42                	ld	s6,16(sp)
    80003456:	6ba2                	ld	s7,8(sp)
    80003458:	6c02                	ld	s8,0(sp)
}
    8000345a:	8526                	mv	a0,s1
    8000345c:	60a6                	ld	ra,72(sp)
    8000345e:	6406                	ld	s0,64(sp)
    80003460:	74e2                	ld	s1,56(sp)
    80003462:	6161                	addi	sp,sp,80
    80003464:	8082                	ret
    brelse(bp);
    80003466:	854a                	mv	a0,s2
    80003468:	e07ff0ef          	jal	8000326e <brelse>
  for(b = 0; b < sb.size; b += BPB){
    8000346c:	015c0abb          	addw	s5,s8,s5
    80003470:	004b2783          	lw	a5,4(s6)
    80003474:	04faf863          	bgeu	s5,a5,800034c4 <balloc+0xe8>
    bp = bread(dev, BBLOCK(b, sb));
    80003478:	40dad59b          	sraiw	a1,s5,0xd
    8000347c:	01cb2783          	lw	a5,28(s6)
    80003480:	9dbd                	addw	a1,a1,a5
    80003482:	855e                	mv	a0,s7
    80003484:	cbbff0ef          	jal	8000313e <bread>
    80003488:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000348a:	004b2503          	lw	a0,4(s6)
    8000348e:	84d6                	mv	s1,s5
    80003490:	4701                	li	a4,0
    80003492:	fca4fae3          	bgeu	s1,a0,80003466 <balloc+0x8a>
      m = 1 << (bi % 8);
    80003496:	00777693          	andi	a3,a4,7
    8000349a:	00d996bb          	sllw	a3,s3,a3
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    8000349e:	41f7579b          	sraiw	a5,a4,0x1f
    800034a2:	01d7d79b          	srliw	a5,a5,0x1d
    800034a6:	9fb9                	addw	a5,a5,a4
    800034a8:	4037d79b          	sraiw	a5,a5,0x3
    800034ac:	00f90633          	add	a2,s2,a5
    800034b0:	05864603          	lbu	a2,88(a2)
    800034b4:	00c6f5b3          	and	a1,a3,a2
    800034b8:	ddb1                	beqz	a1,80003414 <balloc+0x38>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800034ba:	2705                	addiw	a4,a4,1
    800034bc:	2485                	addiw	s1,s1,1
    800034be:	fd471ae3          	bne	a4,s4,80003492 <balloc+0xb6>
    800034c2:	b755                	j	80003466 <balloc+0x8a>
    800034c4:	7942                	ld	s2,48(sp)
    800034c6:	79a2                	ld	s3,40(sp)
    800034c8:	7a02                	ld	s4,32(sp)
    800034ca:	6ae2                	ld	s5,24(sp)
    800034cc:	6b42                	ld	s6,16(sp)
    800034ce:	6ba2                	ld	s7,8(sp)
    800034d0:	6c02                	ld	s8,0(sp)
  printf("balloc: out of blocks\n");
    800034d2:	00005517          	auipc	a0,0x5
    800034d6:	f4650513          	addi	a0,a0,-186 # 80008418 <etext+0x418>
    800034da:	852fd0ef          	jal	8000052c <printf>
  return 0;
    800034de:	4481                	li	s1,0
    800034e0:	bfad                	j	8000345a <balloc+0x7e>

00000000800034e2 <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    800034e2:	7179                	addi	sp,sp,-48
    800034e4:	f406                	sd	ra,40(sp)
    800034e6:	f022                	sd	s0,32(sp)
    800034e8:	ec26                	sd	s1,24(sp)
    800034ea:	e84a                	sd	s2,16(sp)
    800034ec:	e44e                	sd	s3,8(sp)
    800034ee:	1800                	addi	s0,sp,48
    800034f0:	892a                	mv	s2,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    800034f2:	47ad                	li	a5,11
    800034f4:	02b7e363          	bltu	a5,a1,8000351a <bmap+0x38>
    if((addr = ip->addrs[bn]) == 0){
    800034f8:	02059793          	slli	a5,a1,0x20
    800034fc:	01e7d593          	srli	a1,a5,0x1e
    80003500:	00b509b3          	add	s3,a0,a1
    80003504:	0509a483          	lw	s1,80(s3)
    80003508:	e0b5                	bnez	s1,8000356c <bmap+0x8a>
      addr = balloc(ip->dev);
    8000350a:	4108                	lw	a0,0(a0)
    8000350c:	ed1ff0ef          	jal	800033dc <balloc>
    80003510:	84aa                	mv	s1,a0
      if(addr == 0)
    80003512:	cd29                	beqz	a0,8000356c <bmap+0x8a>
        return 0;
      ip->addrs[bn] = addr;
    80003514:	04a9a823          	sw	a0,80(s3)
    80003518:	a891                	j	8000356c <bmap+0x8a>
    }
    return addr;
  }
  bn -= NDIRECT;
    8000351a:	ff45879b          	addiw	a5,a1,-12
    8000351e:	873e                	mv	a4,a5
    80003520:	89be                	mv	s3,a5

  if(bn < NINDIRECT){
    80003522:	0ff00793          	li	a5,255
    80003526:	06e7e763          	bltu	a5,a4,80003594 <bmap+0xb2>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    8000352a:	08052483          	lw	s1,128(a0)
    8000352e:	e891                	bnez	s1,80003542 <bmap+0x60>
      addr = balloc(ip->dev);
    80003530:	4108                	lw	a0,0(a0)
    80003532:	eabff0ef          	jal	800033dc <balloc>
    80003536:	84aa                	mv	s1,a0
      if(addr == 0)
    80003538:	c915                	beqz	a0,8000356c <bmap+0x8a>
    8000353a:	e052                	sd	s4,0(sp)
        return 0;
      ip->addrs[NDIRECT] = addr;
    8000353c:	08a92023          	sw	a0,128(s2)
    80003540:	a011                	j	80003544 <bmap+0x62>
    80003542:	e052                	sd	s4,0(sp)
    }
    bp = bread(ip->dev, addr);
    80003544:	85a6                	mv	a1,s1
    80003546:	00092503          	lw	a0,0(s2)
    8000354a:	bf5ff0ef          	jal	8000313e <bread>
    8000354e:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    80003550:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    80003554:	02099713          	slli	a4,s3,0x20
    80003558:	01e75593          	srli	a1,a4,0x1e
    8000355c:	97ae                	add	a5,a5,a1
    8000355e:	89be                	mv	s3,a5
    80003560:	4384                	lw	s1,0(a5)
    80003562:	cc89                	beqz	s1,8000357c <bmap+0x9a>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    80003564:	8552                	mv	a0,s4
    80003566:	d09ff0ef          	jal	8000326e <brelse>
    return addr;
    8000356a:	6a02                	ld	s4,0(sp)
  }

  panic("bmap: out of range");
}
    8000356c:	8526                	mv	a0,s1
    8000356e:	70a2                	ld	ra,40(sp)
    80003570:	7402                	ld	s0,32(sp)
    80003572:	64e2                	ld	s1,24(sp)
    80003574:	6942                	ld	s2,16(sp)
    80003576:	69a2                	ld	s3,8(sp)
    80003578:	6145                	addi	sp,sp,48
    8000357a:	8082                	ret
      addr = balloc(ip->dev);
    8000357c:	00092503          	lw	a0,0(s2)
    80003580:	e5dff0ef          	jal	800033dc <balloc>
    80003584:	84aa                	mv	s1,a0
      if(addr){
    80003586:	dd79                	beqz	a0,80003564 <bmap+0x82>
        a[bn] = addr;
    80003588:	00a9a023          	sw	a0,0(s3)
        log_write(bp);
    8000358c:	8552                	mv	a0,s4
    8000358e:	62d000ef          	jal	800043ba <log_write>
    80003592:	bfc9                	j	80003564 <bmap+0x82>
    80003594:	e052                	sd	s4,0(sp)
  panic("bmap: out of range");
    80003596:	00005517          	auipc	a0,0x5
    8000359a:	e9a50513          	addi	a0,a0,-358 # 80008430 <etext+0x430>
    8000359e:	ab8fd0ef          	jal	80000856 <panic>

00000000800035a2 <iget>:
{
    800035a2:	7179                	addi	sp,sp,-48
    800035a4:	f406                	sd	ra,40(sp)
    800035a6:	f022                	sd	s0,32(sp)
    800035a8:	ec26                	sd	s1,24(sp)
    800035aa:	e84a                	sd	s2,16(sp)
    800035ac:	e44e                	sd	s3,8(sp)
    800035ae:	e052                	sd	s4,0(sp)
    800035b0:	1800                	addi	s0,sp,48
    800035b2:	892a                	mv	s2,a0
    800035b4:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    800035b6:	0001d517          	auipc	a0,0x1d
    800035ba:	0b250513          	addi	a0,a0,178 # 80020668 <itable>
    800035be:	f64fd0ef          	jal	80000d22 <acquire>
  empty = 0;
    800035c2:	4981                	li	s3,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    800035c4:	0001d497          	auipc	s1,0x1d
    800035c8:	0bc48493          	addi	s1,s1,188 # 80020680 <itable+0x18>
    800035cc:	0001f697          	auipc	a3,0x1f
    800035d0:	b4468693          	addi	a3,a3,-1212 # 80022110 <log>
    800035d4:	a809                	j	800035e6 <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    800035d6:	e781                	bnez	a5,800035de <iget+0x3c>
    800035d8:	00099363          	bnez	s3,800035de <iget+0x3c>
      empty = ip;
    800035dc:	89a6                	mv	s3,s1
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    800035de:	08848493          	addi	s1,s1,136
    800035e2:	02d48563          	beq	s1,a3,8000360c <iget+0x6a>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    800035e6:	449c                	lw	a5,8(s1)
    800035e8:	fef057e3          	blez	a5,800035d6 <iget+0x34>
    800035ec:	4098                	lw	a4,0(s1)
    800035ee:	ff2718e3          	bne	a4,s2,800035de <iget+0x3c>
    800035f2:	40d8                	lw	a4,4(s1)
    800035f4:	ff4715e3          	bne	a4,s4,800035de <iget+0x3c>
      ip->ref++;
    800035f8:	2785                	addiw	a5,a5,1
    800035fa:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    800035fc:	0001d517          	auipc	a0,0x1d
    80003600:	06c50513          	addi	a0,a0,108 # 80020668 <itable>
    80003604:	fb2fd0ef          	jal	80000db6 <release>
      return ip;
    80003608:	89a6                	mv	s3,s1
    8000360a:	a015                	j	8000362e <iget+0x8c>
  if(empty == 0)
    8000360c:	02098a63          	beqz	s3,80003640 <iget+0x9e>
  ip->dev = dev;
    80003610:	0129a023          	sw	s2,0(s3)
  ip->inum = inum;
    80003614:	0149a223          	sw	s4,4(s3)
  ip->ref = 1;
    80003618:	4785                	li	a5,1
    8000361a:	00f9a423          	sw	a5,8(s3)
  ip->valid = 0;
    8000361e:	0409a023          	sw	zero,64(s3)
  release(&itable.lock);
    80003622:	0001d517          	auipc	a0,0x1d
    80003626:	04650513          	addi	a0,a0,70 # 80020668 <itable>
    8000362a:	f8cfd0ef          	jal	80000db6 <release>
}
    8000362e:	854e                	mv	a0,s3
    80003630:	70a2                	ld	ra,40(sp)
    80003632:	7402                	ld	s0,32(sp)
    80003634:	64e2                	ld	s1,24(sp)
    80003636:	6942                	ld	s2,16(sp)
    80003638:	69a2                	ld	s3,8(sp)
    8000363a:	6a02                	ld	s4,0(sp)
    8000363c:	6145                	addi	sp,sp,48
    8000363e:	8082                	ret
    panic("iget: no inodes");
    80003640:	00005517          	auipc	a0,0x5
    80003644:	e0850513          	addi	a0,a0,-504 # 80008448 <etext+0x448>
    80003648:	a0efd0ef          	jal	80000856 <panic>

000000008000364c <iinit>:
{
    8000364c:	7179                	addi	sp,sp,-48
    8000364e:	f406                	sd	ra,40(sp)
    80003650:	f022                	sd	s0,32(sp)
    80003652:	ec26                	sd	s1,24(sp)
    80003654:	e84a                	sd	s2,16(sp)
    80003656:	e44e                	sd	s3,8(sp)
    80003658:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    8000365a:	00005597          	auipc	a1,0x5
    8000365e:	dfe58593          	addi	a1,a1,-514 # 80008458 <etext+0x458>
    80003662:	0001d517          	auipc	a0,0x1d
    80003666:	00650513          	addi	a0,a0,6 # 80020668 <itable>
    8000366a:	e2efd0ef          	jal	80000c98 <initlock>
  for(i = 0; i < NINODE; i++) {
    8000366e:	0001d497          	auipc	s1,0x1d
    80003672:	02248493          	addi	s1,s1,34 # 80020690 <itable+0x28>
    80003676:	0001f997          	auipc	s3,0x1f
    8000367a:	aaa98993          	addi	s3,s3,-1366 # 80022120 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    8000367e:	00005917          	auipc	s2,0x5
    80003682:	de290913          	addi	s2,s2,-542 # 80008460 <etext+0x460>
    80003686:	85ca                	mv	a1,s2
    80003688:	8526                	mv	a0,s1
    8000368a:	5f5000ef          	jal	8000447e <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    8000368e:	08848493          	addi	s1,s1,136
    80003692:	ff349ae3          	bne	s1,s3,80003686 <iinit+0x3a>
}
    80003696:	70a2                	ld	ra,40(sp)
    80003698:	7402                	ld	s0,32(sp)
    8000369a:	64e2                	ld	s1,24(sp)
    8000369c:	6942                	ld	s2,16(sp)
    8000369e:	69a2                	ld	s3,8(sp)
    800036a0:	6145                	addi	sp,sp,48
    800036a2:	8082                	ret

00000000800036a4 <ialloc>:
{
    800036a4:	7139                	addi	sp,sp,-64
    800036a6:	fc06                	sd	ra,56(sp)
    800036a8:	f822                	sd	s0,48(sp)
    800036aa:	0080                	addi	s0,sp,64
  for(inum = 1; inum < sb.ninodes; inum++){
    800036ac:	0001d717          	auipc	a4,0x1d
    800036b0:	fa872703          	lw	a4,-88(a4) # 80020654 <sb+0xc>
    800036b4:	4785                	li	a5,1
    800036b6:	06e7f063          	bgeu	a5,a4,80003716 <ialloc+0x72>
    800036ba:	f426                	sd	s1,40(sp)
    800036bc:	f04a                	sd	s2,32(sp)
    800036be:	ec4e                	sd	s3,24(sp)
    800036c0:	e852                	sd	s4,16(sp)
    800036c2:	e456                	sd	s5,8(sp)
    800036c4:	e05a                	sd	s6,0(sp)
    800036c6:	8aaa                	mv	s5,a0
    800036c8:	8b2e                	mv	s6,a1
    800036ca:	893e                	mv	s2,a5
    bp = bread(dev, IBLOCK(inum, sb));
    800036cc:	0001da17          	auipc	s4,0x1d
    800036d0:	f7ca0a13          	addi	s4,s4,-132 # 80020648 <sb>
    800036d4:	00495593          	srli	a1,s2,0x4
    800036d8:	018a2783          	lw	a5,24(s4)
    800036dc:	9dbd                	addw	a1,a1,a5
    800036de:	8556                	mv	a0,s5
    800036e0:	a5fff0ef          	jal	8000313e <bread>
    800036e4:	84aa                	mv	s1,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    800036e6:	05850993          	addi	s3,a0,88
    800036ea:	00f97793          	andi	a5,s2,15
    800036ee:	079a                	slli	a5,a5,0x6
    800036f0:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    800036f2:	00099783          	lh	a5,0(s3)
    800036f6:	cb9d                	beqz	a5,8000372c <ialloc+0x88>
    brelse(bp);
    800036f8:	b77ff0ef          	jal	8000326e <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    800036fc:	0905                	addi	s2,s2,1
    800036fe:	00ca2703          	lw	a4,12(s4)
    80003702:	0009079b          	sext.w	a5,s2
    80003706:	fce7e7e3          	bltu	a5,a4,800036d4 <ialloc+0x30>
    8000370a:	74a2                	ld	s1,40(sp)
    8000370c:	7902                	ld	s2,32(sp)
    8000370e:	69e2                	ld	s3,24(sp)
    80003710:	6a42                	ld	s4,16(sp)
    80003712:	6aa2                	ld	s5,8(sp)
    80003714:	6b02                	ld	s6,0(sp)
  printf("ialloc: no inodes\n");
    80003716:	00005517          	auipc	a0,0x5
    8000371a:	d5250513          	addi	a0,a0,-686 # 80008468 <etext+0x468>
    8000371e:	e0ffc0ef          	jal	8000052c <printf>
  return 0;
    80003722:	4501                	li	a0,0
}
    80003724:	70e2                	ld	ra,56(sp)
    80003726:	7442                	ld	s0,48(sp)
    80003728:	6121                	addi	sp,sp,64
    8000372a:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    8000372c:	04000613          	li	a2,64
    80003730:	4581                	li	a1,0
    80003732:	854e                	mv	a0,s3
    80003734:	ebefd0ef          	jal	80000df2 <memset>
      dip->type = type;
    80003738:	01699023          	sh	s6,0(s3)
      log_write(bp);   // mark it allocated on the disk
    8000373c:	8526                	mv	a0,s1
    8000373e:	47d000ef          	jal	800043ba <log_write>
      brelse(bp);
    80003742:	8526                	mv	a0,s1
    80003744:	b2bff0ef          	jal	8000326e <brelse>
      return iget(dev, inum);
    80003748:	0009059b          	sext.w	a1,s2
    8000374c:	8556                	mv	a0,s5
    8000374e:	e55ff0ef          	jal	800035a2 <iget>
    80003752:	74a2                	ld	s1,40(sp)
    80003754:	7902                	ld	s2,32(sp)
    80003756:	69e2                	ld	s3,24(sp)
    80003758:	6a42                	ld	s4,16(sp)
    8000375a:	6aa2                	ld	s5,8(sp)
    8000375c:	6b02                	ld	s6,0(sp)
    8000375e:	b7d9                	j	80003724 <ialloc+0x80>

0000000080003760 <iupdate>:
{
    80003760:	1101                	addi	sp,sp,-32
    80003762:	ec06                	sd	ra,24(sp)
    80003764:	e822                	sd	s0,16(sp)
    80003766:	e426                	sd	s1,8(sp)
    80003768:	e04a                	sd	s2,0(sp)
    8000376a:	1000                	addi	s0,sp,32
    8000376c:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    8000376e:	415c                	lw	a5,4(a0)
    80003770:	0047d79b          	srliw	a5,a5,0x4
    80003774:	0001d597          	auipc	a1,0x1d
    80003778:	eec5a583          	lw	a1,-276(a1) # 80020660 <sb+0x18>
    8000377c:	9dbd                	addw	a1,a1,a5
    8000377e:	4108                	lw	a0,0(a0)
    80003780:	9bfff0ef          	jal	8000313e <bread>
    80003784:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003786:	05850793          	addi	a5,a0,88
    8000378a:	40d8                	lw	a4,4(s1)
    8000378c:	8b3d                	andi	a4,a4,15
    8000378e:	071a                	slli	a4,a4,0x6
    80003790:	97ba                	add	a5,a5,a4
  dip->type = ip->type;
    80003792:	04449703          	lh	a4,68(s1)
    80003796:	00e79023          	sh	a4,0(a5)
  dip->major = ip->major;
    8000379a:	04649703          	lh	a4,70(s1)
    8000379e:	00e79123          	sh	a4,2(a5)
  dip->minor = ip->minor;
    800037a2:	04849703          	lh	a4,72(s1)
    800037a6:	00e79223          	sh	a4,4(a5)
  dip->nlink = ip->nlink;
    800037aa:	04a49703          	lh	a4,74(s1)
    800037ae:	00e79323          	sh	a4,6(a5)
  dip->size = ip->size;
    800037b2:	44f8                	lw	a4,76(s1)
    800037b4:	c798                	sw	a4,8(a5)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    800037b6:	03400613          	li	a2,52
    800037ba:	05048593          	addi	a1,s1,80
    800037be:	00c78513          	addi	a0,a5,12
    800037c2:	e90fd0ef          	jal	80000e52 <memmove>
  log_write(bp);
    800037c6:	854a                	mv	a0,s2
    800037c8:	3f3000ef          	jal	800043ba <log_write>
  brelse(bp);
    800037cc:	854a                	mv	a0,s2
    800037ce:	aa1ff0ef          	jal	8000326e <brelse>
}
    800037d2:	60e2                	ld	ra,24(sp)
    800037d4:	6442                	ld	s0,16(sp)
    800037d6:	64a2                	ld	s1,8(sp)
    800037d8:	6902                	ld	s2,0(sp)
    800037da:	6105                	addi	sp,sp,32
    800037dc:	8082                	ret

00000000800037de <idup>:
{
    800037de:	1101                	addi	sp,sp,-32
    800037e0:	ec06                	sd	ra,24(sp)
    800037e2:	e822                	sd	s0,16(sp)
    800037e4:	e426                	sd	s1,8(sp)
    800037e6:	1000                	addi	s0,sp,32
    800037e8:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    800037ea:	0001d517          	auipc	a0,0x1d
    800037ee:	e7e50513          	addi	a0,a0,-386 # 80020668 <itable>
    800037f2:	d30fd0ef          	jal	80000d22 <acquire>
  ip->ref++;
    800037f6:	449c                	lw	a5,8(s1)
    800037f8:	2785                	addiw	a5,a5,1
    800037fa:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    800037fc:	0001d517          	auipc	a0,0x1d
    80003800:	e6c50513          	addi	a0,a0,-404 # 80020668 <itable>
    80003804:	db2fd0ef          	jal	80000db6 <release>
}
    80003808:	8526                	mv	a0,s1
    8000380a:	60e2                	ld	ra,24(sp)
    8000380c:	6442                	ld	s0,16(sp)
    8000380e:	64a2                	ld	s1,8(sp)
    80003810:	6105                	addi	sp,sp,32
    80003812:	8082                	ret

0000000080003814 <ilock>:
{
    80003814:	1101                	addi	sp,sp,-32
    80003816:	ec06                	sd	ra,24(sp)
    80003818:	e822                	sd	s0,16(sp)
    8000381a:	e426                	sd	s1,8(sp)
    8000381c:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    8000381e:	cd19                	beqz	a0,8000383c <ilock+0x28>
    80003820:	84aa                	mv	s1,a0
    80003822:	451c                	lw	a5,8(a0)
    80003824:	00f05c63          	blez	a5,8000383c <ilock+0x28>
  acquiresleep(&ip->lock);
    80003828:	0541                	addi	a0,a0,16
    8000382a:	48b000ef          	jal	800044b4 <acquiresleep>
  if(ip->valid == 0){
    8000382e:	40bc                	lw	a5,64(s1)
    80003830:	cf89                	beqz	a5,8000384a <ilock+0x36>
}
    80003832:	60e2                	ld	ra,24(sp)
    80003834:	6442                	ld	s0,16(sp)
    80003836:	64a2                	ld	s1,8(sp)
    80003838:	6105                	addi	sp,sp,32
    8000383a:	8082                	ret
    8000383c:	e04a                	sd	s2,0(sp)
    panic("ilock");
    8000383e:	00005517          	auipc	a0,0x5
    80003842:	c4250513          	addi	a0,a0,-958 # 80008480 <etext+0x480>
    80003846:	810fd0ef          	jal	80000856 <panic>
    8000384a:	e04a                	sd	s2,0(sp)
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    8000384c:	40dc                	lw	a5,4(s1)
    8000384e:	0047d79b          	srliw	a5,a5,0x4
    80003852:	0001d597          	auipc	a1,0x1d
    80003856:	e0e5a583          	lw	a1,-498(a1) # 80020660 <sb+0x18>
    8000385a:	9dbd                	addw	a1,a1,a5
    8000385c:	4088                	lw	a0,0(s1)
    8000385e:	8e1ff0ef          	jal	8000313e <bread>
    80003862:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003864:	05850593          	addi	a1,a0,88
    80003868:	40dc                	lw	a5,4(s1)
    8000386a:	8bbd                	andi	a5,a5,15
    8000386c:	079a                	slli	a5,a5,0x6
    8000386e:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    80003870:	00059783          	lh	a5,0(a1)
    80003874:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    80003878:	00259783          	lh	a5,2(a1)
    8000387c:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    80003880:	00459783          	lh	a5,4(a1)
    80003884:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80003888:	00659783          	lh	a5,6(a1)
    8000388c:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    80003890:	459c                	lw	a5,8(a1)
    80003892:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80003894:	03400613          	li	a2,52
    80003898:	05b1                	addi	a1,a1,12
    8000389a:	05048513          	addi	a0,s1,80
    8000389e:	db4fd0ef          	jal	80000e52 <memmove>
    brelse(bp);
    800038a2:	854a                	mv	a0,s2
    800038a4:	9cbff0ef          	jal	8000326e <brelse>
    ip->valid = 1;
    800038a8:	4785                	li	a5,1
    800038aa:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    800038ac:	04449783          	lh	a5,68(s1)
    800038b0:	c399                	beqz	a5,800038b6 <ilock+0xa2>
    800038b2:	6902                	ld	s2,0(sp)
    800038b4:	bfbd                	j	80003832 <ilock+0x1e>
      panic("ilock: no type");
    800038b6:	00005517          	auipc	a0,0x5
    800038ba:	bd250513          	addi	a0,a0,-1070 # 80008488 <etext+0x488>
    800038be:	f99fc0ef          	jal	80000856 <panic>

00000000800038c2 <iunlock>:
{
    800038c2:	1101                	addi	sp,sp,-32
    800038c4:	ec06                	sd	ra,24(sp)
    800038c6:	e822                	sd	s0,16(sp)
    800038c8:	e426                	sd	s1,8(sp)
    800038ca:	e04a                	sd	s2,0(sp)
    800038cc:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    800038ce:	c505                	beqz	a0,800038f6 <iunlock+0x34>
    800038d0:	84aa                	mv	s1,a0
    800038d2:	01050913          	addi	s2,a0,16
    800038d6:	854a                	mv	a0,s2
    800038d8:	45b000ef          	jal	80004532 <holdingsleep>
    800038dc:	cd09                	beqz	a0,800038f6 <iunlock+0x34>
    800038de:	449c                	lw	a5,8(s1)
    800038e0:	00f05b63          	blez	a5,800038f6 <iunlock+0x34>
  releasesleep(&ip->lock);
    800038e4:	854a                	mv	a0,s2
    800038e6:	415000ef          	jal	800044fa <releasesleep>
}
    800038ea:	60e2                	ld	ra,24(sp)
    800038ec:	6442                	ld	s0,16(sp)
    800038ee:	64a2                	ld	s1,8(sp)
    800038f0:	6902                	ld	s2,0(sp)
    800038f2:	6105                	addi	sp,sp,32
    800038f4:	8082                	ret
    panic("iunlock");
    800038f6:	00005517          	auipc	a0,0x5
    800038fa:	ba250513          	addi	a0,a0,-1118 # 80008498 <etext+0x498>
    800038fe:	f59fc0ef          	jal	80000856 <panic>

0000000080003902 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    80003902:	7179                	addi	sp,sp,-48
    80003904:	f406                	sd	ra,40(sp)
    80003906:	f022                	sd	s0,32(sp)
    80003908:	ec26                	sd	s1,24(sp)
    8000390a:	e84a                	sd	s2,16(sp)
    8000390c:	e44e                	sd	s3,8(sp)
    8000390e:	1800                	addi	s0,sp,48
    80003910:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    80003912:	05050493          	addi	s1,a0,80
    80003916:	08050913          	addi	s2,a0,128
    8000391a:	a021                	j	80003922 <itrunc+0x20>
    8000391c:	0491                	addi	s1,s1,4
    8000391e:	01248b63          	beq	s1,s2,80003934 <itrunc+0x32>
    if(ip->addrs[i]){
    80003922:	408c                	lw	a1,0(s1)
    80003924:	dde5                	beqz	a1,8000391c <itrunc+0x1a>
      bfree(ip->dev, ip->addrs[i]);
    80003926:	0009a503          	lw	a0,0(s3)
    8000392a:	a47ff0ef          	jal	80003370 <bfree>
      ip->addrs[i] = 0;
    8000392e:	0004a023          	sw	zero,0(s1)
    80003932:	b7ed                	j	8000391c <itrunc+0x1a>
    }
  }

  if(ip->addrs[NDIRECT]){
    80003934:	0809a583          	lw	a1,128(s3)
    80003938:	ed89                	bnez	a1,80003952 <itrunc+0x50>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    8000393a:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    8000393e:	854e                	mv	a0,s3
    80003940:	e21ff0ef          	jal	80003760 <iupdate>
}
    80003944:	70a2                	ld	ra,40(sp)
    80003946:	7402                	ld	s0,32(sp)
    80003948:	64e2                	ld	s1,24(sp)
    8000394a:	6942                	ld	s2,16(sp)
    8000394c:	69a2                	ld	s3,8(sp)
    8000394e:	6145                	addi	sp,sp,48
    80003950:	8082                	ret
    80003952:	e052                	sd	s4,0(sp)
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80003954:	0009a503          	lw	a0,0(s3)
    80003958:	fe6ff0ef          	jal	8000313e <bread>
    8000395c:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    8000395e:	05850493          	addi	s1,a0,88
    80003962:	45850913          	addi	s2,a0,1112
    80003966:	a021                	j	8000396e <itrunc+0x6c>
    80003968:	0491                	addi	s1,s1,4
    8000396a:	01248963          	beq	s1,s2,8000397c <itrunc+0x7a>
      if(a[j])
    8000396e:	408c                	lw	a1,0(s1)
    80003970:	dde5                	beqz	a1,80003968 <itrunc+0x66>
        bfree(ip->dev, a[j]);
    80003972:	0009a503          	lw	a0,0(s3)
    80003976:	9fbff0ef          	jal	80003370 <bfree>
    8000397a:	b7fd                	j	80003968 <itrunc+0x66>
    brelse(bp);
    8000397c:	8552                	mv	a0,s4
    8000397e:	8f1ff0ef          	jal	8000326e <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80003982:	0809a583          	lw	a1,128(s3)
    80003986:	0009a503          	lw	a0,0(s3)
    8000398a:	9e7ff0ef          	jal	80003370 <bfree>
    ip->addrs[NDIRECT] = 0;
    8000398e:	0809a023          	sw	zero,128(s3)
    80003992:	6a02                	ld	s4,0(sp)
    80003994:	b75d                	j	8000393a <itrunc+0x38>

0000000080003996 <iput>:
{
    80003996:	1101                	addi	sp,sp,-32
    80003998:	ec06                	sd	ra,24(sp)
    8000399a:	e822                	sd	s0,16(sp)
    8000399c:	e426                	sd	s1,8(sp)
    8000399e:	1000                	addi	s0,sp,32
    800039a0:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    800039a2:	0001d517          	auipc	a0,0x1d
    800039a6:	cc650513          	addi	a0,a0,-826 # 80020668 <itable>
    800039aa:	b78fd0ef          	jal	80000d22 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    800039ae:	4498                	lw	a4,8(s1)
    800039b0:	4785                	li	a5,1
    800039b2:	02f70063          	beq	a4,a5,800039d2 <iput+0x3c>
  ip->ref--;
    800039b6:	449c                	lw	a5,8(s1)
    800039b8:	37fd                	addiw	a5,a5,-1
    800039ba:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    800039bc:	0001d517          	auipc	a0,0x1d
    800039c0:	cac50513          	addi	a0,a0,-852 # 80020668 <itable>
    800039c4:	bf2fd0ef          	jal	80000db6 <release>
}
    800039c8:	60e2                	ld	ra,24(sp)
    800039ca:	6442                	ld	s0,16(sp)
    800039cc:	64a2                	ld	s1,8(sp)
    800039ce:	6105                	addi	sp,sp,32
    800039d0:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    800039d2:	40bc                	lw	a5,64(s1)
    800039d4:	d3ed                	beqz	a5,800039b6 <iput+0x20>
    800039d6:	04a49783          	lh	a5,74(s1)
    800039da:	fff1                	bnez	a5,800039b6 <iput+0x20>
    800039dc:	e04a                	sd	s2,0(sp)
    acquiresleep(&ip->lock);
    800039de:	01048793          	addi	a5,s1,16
    800039e2:	893e                	mv	s2,a5
    800039e4:	853e                	mv	a0,a5
    800039e6:	2cf000ef          	jal	800044b4 <acquiresleep>
    release(&itable.lock);
    800039ea:	0001d517          	auipc	a0,0x1d
    800039ee:	c7e50513          	addi	a0,a0,-898 # 80020668 <itable>
    800039f2:	bc4fd0ef          	jal	80000db6 <release>
    itrunc(ip);
    800039f6:	8526                	mv	a0,s1
    800039f8:	f0bff0ef          	jal	80003902 <itrunc>
    ip->type = 0;
    800039fc:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    80003a00:	8526                	mv	a0,s1
    80003a02:	d5fff0ef          	jal	80003760 <iupdate>
    ip->valid = 0;
    80003a06:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80003a0a:	854a                	mv	a0,s2
    80003a0c:	2ef000ef          	jal	800044fa <releasesleep>
    acquire(&itable.lock);
    80003a10:	0001d517          	auipc	a0,0x1d
    80003a14:	c5850513          	addi	a0,a0,-936 # 80020668 <itable>
    80003a18:	b0afd0ef          	jal	80000d22 <acquire>
    80003a1c:	6902                	ld	s2,0(sp)
    80003a1e:	bf61                	j	800039b6 <iput+0x20>

0000000080003a20 <iunlockput>:
{
    80003a20:	1101                	addi	sp,sp,-32
    80003a22:	ec06                	sd	ra,24(sp)
    80003a24:	e822                	sd	s0,16(sp)
    80003a26:	e426                	sd	s1,8(sp)
    80003a28:	1000                	addi	s0,sp,32
    80003a2a:	84aa                	mv	s1,a0
  iunlock(ip);
    80003a2c:	e97ff0ef          	jal	800038c2 <iunlock>
  iput(ip);
    80003a30:	8526                	mv	a0,s1
    80003a32:	f65ff0ef          	jal	80003996 <iput>
}
    80003a36:	60e2                	ld	ra,24(sp)
    80003a38:	6442                	ld	s0,16(sp)
    80003a3a:	64a2                	ld	s1,8(sp)
    80003a3c:	6105                	addi	sp,sp,32
    80003a3e:	8082                	ret

0000000080003a40 <ireclaim>:
  for (int inum = 1; inum < sb.ninodes; inum++) {
    80003a40:	0001d717          	auipc	a4,0x1d
    80003a44:	c1472703          	lw	a4,-1004(a4) # 80020654 <sb+0xc>
    80003a48:	4785                	li	a5,1
    80003a4a:	0ae7fe63          	bgeu	a5,a4,80003b06 <ireclaim+0xc6>
{
    80003a4e:	7139                	addi	sp,sp,-64
    80003a50:	fc06                	sd	ra,56(sp)
    80003a52:	f822                	sd	s0,48(sp)
    80003a54:	f426                	sd	s1,40(sp)
    80003a56:	f04a                	sd	s2,32(sp)
    80003a58:	ec4e                	sd	s3,24(sp)
    80003a5a:	e852                	sd	s4,16(sp)
    80003a5c:	e456                	sd	s5,8(sp)
    80003a5e:	e05a                	sd	s6,0(sp)
    80003a60:	0080                	addi	s0,sp,64
    80003a62:	8aaa                	mv	s5,a0
  for (int inum = 1; inum < sb.ninodes; inum++) {
    80003a64:	84be                	mv	s1,a5
    struct buf *bp = bread(dev, IBLOCK(inum, sb));
    80003a66:	0001da17          	auipc	s4,0x1d
    80003a6a:	be2a0a13          	addi	s4,s4,-1054 # 80020648 <sb>
      printf("ireclaim: orphaned inode %d\n", inum);
    80003a6e:	00005b17          	auipc	s6,0x5
    80003a72:	a32b0b13          	addi	s6,s6,-1486 # 800084a0 <etext+0x4a0>
    80003a76:	a099                	j	80003abc <ireclaim+0x7c>
    80003a78:	85ce                	mv	a1,s3
    80003a7a:	855a                	mv	a0,s6
    80003a7c:	ab1fc0ef          	jal	8000052c <printf>
      ip = iget(dev, inum);
    80003a80:	85ce                	mv	a1,s3
    80003a82:	8556                	mv	a0,s5
    80003a84:	b1fff0ef          	jal	800035a2 <iget>
    80003a88:	89aa                	mv	s3,a0
    brelse(bp);
    80003a8a:	854a                	mv	a0,s2
    80003a8c:	fe2ff0ef          	jal	8000326e <brelse>
    if (ip) {
    80003a90:	00098f63          	beqz	s3,80003aae <ireclaim+0x6e>
      begin_op();
    80003a94:	78c000ef          	jal	80004220 <begin_op>
      ilock(ip);
    80003a98:	854e                	mv	a0,s3
    80003a9a:	d7bff0ef          	jal	80003814 <ilock>
      iunlock(ip);
    80003a9e:	854e                	mv	a0,s3
    80003aa0:	e23ff0ef          	jal	800038c2 <iunlock>
      iput(ip);
    80003aa4:	854e                	mv	a0,s3
    80003aa6:	ef1ff0ef          	jal	80003996 <iput>
      end_op();
    80003aaa:	7e6000ef          	jal	80004290 <end_op>
  for (int inum = 1; inum < sb.ninodes; inum++) {
    80003aae:	0485                	addi	s1,s1,1
    80003ab0:	00ca2703          	lw	a4,12(s4)
    80003ab4:	0004879b          	sext.w	a5,s1
    80003ab8:	02e7fd63          	bgeu	a5,a4,80003af2 <ireclaim+0xb2>
    80003abc:	0004899b          	sext.w	s3,s1
    struct buf *bp = bread(dev, IBLOCK(inum, sb));
    80003ac0:	0044d593          	srli	a1,s1,0x4
    80003ac4:	018a2783          	lw	a5,24(s4)
    80003ac8:	9dbd                	addw	a1,a1,a5
    80003aca:	8556                	mv	a0,s5
    80003acc:	e72ff0ef          	jal	8000313e <bread>
    80003ad0:	892a                	mv	s2,a0
    struct dinode *dip = (struct dinode *)bp->data + inum % IPB;
    80003ad2:	05850793          	addi	a5,a0,88
    80003ad6:	00f9f713          	andi	a4,s3,15
    80003ada:	071a                	slli	a4,a4,0x6
    80003adc:	97ba                	add	a5,a5,a4
    if (dip->type != 0 && dip->nlink == 0) {  // is an orphaned inode
    80003ade:	00079703          	lh	a4,0(a5)
    80003ae2:	c701                	beqz	a4,80003aea <ireclaim+0xaa>
    80003ae4:	00679783          	lh	a5,6(a5)
    80003ae8:	dbc1                	beqz	a5,80003a78 <ireclaim+0x38>
    brelse(bp);
    80003aea:	854a                	mv	a0,s2
    80003aec:	f82ff0ef          	jal	8000326e <brelse>
    if (ip) {
    80003af0:	bf7d                	j	80003aae <ireclaim+0x6e>
}
    80003af2:	70e2                	ld	ra,56(sp)
    80003af4:	7442                	ld	s0,48(sp)
    80003af6:	74a2                	ld	s1,40(sp)
    80003af8:	7902                	ld	s2,32(sp)
    80003afa:	69e2                	ld	s3,24(sp)
    80003afc:	6a42                	ld	s4,16(sp)
    80003afe:	6aa2                	ld	s5,8(sp)
    80003b00:	6b02                	ld	s6,0(sp)
    80003b02:	6121                	addi	sp,sp,64
    80003b04:	8082                	ret
    80003b06:	8082                	ret

0000000080003b08 <fsinit>:
fsinit(int dev) {
    80003b08:	1101                	addi	sp,sp,-32
    80003b0a:	ec06                	sd	ra,24(sp)
    80003b0c:	e822                	sd	s0,16(sp)
    80003b0e:	e426                	sd	s1,8(sp)
    80003b10:	e04a                	sd	s2,0(sp)
    80003b12:	1000                	addi	s0,sp,32
    80003b14:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    80003b16:	4585                	li	a1,1
    80003b18:	e26ff0ef          	jal	8000313e <bread>
    80003b1c:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    80003b1e:	02000613          	li	a2,32
    80003b22:	05850593          	addi	a1,a0,88
    80003b26:	0001d517          	auipc	a0,0x1d
    80003b2a:	b2250513          	addi	a0,a0,-1246 # 80020648 <sb>
    80003b2e:	b24fd0ef          	jal	80000e52 <memmove>
  brelse(bp);
    80003b32:	8526                	mv	a0,s1
    80003b34:	f3aff0ef          	jal	8000326e <brelse>
  if(sb.magic != FSMAGIC)
    80003b38:	0001d717          	auipc	a4,0x1d
    80003b3c:	b1072703          	lw	a4,-1264(a4) # 80020648 <sb>
    80003b40:	102037b7          	lui	a5,0x10203
    80003b44:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    80003b48:	02f71263          	bne	a4,a5,80003b6c <fsinit+0x64>
  initlog(dev, &sb);
    80003b4c:	0001d597          	auipc	a1,0x1d
    80003b50:	afc58593          	addi	a1,a1,-1284 # 80020648 <sb>
    80003b54:	854a                	mv	a0,s2
    80003b56:	648000ef          	jal	8000419e <initlog>
  ireclaim(dev);
    80003b5a:	854a                	mv	a0,s2
    80003b5c:	ee5ff0ef          	jal	80003a40 <ireclaim>
}
    80003b60:	60e2                	ld	ra,24(sp)
    80003b62:	6442                	ld	s0,16(sp)
    80003b64:	64a2                	ld	s1,8(sp)
    80003b66:	6902                	ld	s2,0(sp)
    80003b68:	6105                	addi	sp,sp,32
    80003b6a:	8082                	ret
    panic("invalid file system");
    80003b6c:	00005517          	auipc	a0,0x5
    80003b70:	95450513          	addi	a0,a0,-1708 # 800084c0 <etext+0x4c0>
    80003b74:	ce3fc0ef          	jal	80000856 <panic>

0000000080003b78 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80003b78:	1141                	addi	sp,sp,-16
    80003b7a:	e406                	sd	ra,8(sp)
    80003b7c:	e022                	sd	s0,0(sp)
    80003b7e:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80003b80:	411c                	lw	a5,0(a0)
    80003b82:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80003b84:	415c                	lw	a5,4(a0)
    80003b86:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80003b88:	04451783          	lh	a5,68(a0)
    80003b8c:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80003b90:	04a51783          	lh	a5,74(a0)
    80003b94:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80003b98:	04c56783          	lwu	a5,76(a0)
    80003b9c:	e99c                	sd	a5,16(a1)
}
    80003b9e:	60a2                	ld	ra,8(sp)
    80003ba0:	6402                	ld	s0,0(sp)
    80003ba2:	0141                	addi	sp,sp,16
    80003ba4:	8082                	ret

0000000080003ba6 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003ba6:	457c                	lw	a5,76(a0)
    80003ba8:	0ed7e663          	bltu	a5,a3,80003c94 <readi+0xee>
{
    80003bac:	7159                	addi	sp,sp,-112
    80003bae:	f486                	sd	ra,104(sp)
    80003bb0:	f0a2                	sd	s0,96(sp)
    80003bb2:	eca6                	sd	s1,88(sp)
    80003bb4:	e0d2                	sd	s4,64(sp)
    80003bb6:	fc56                	sd	s5,56(sp)
    80003bb8:	f85a                	sd	s6,48(sp)
    80003bba:	f45e                	sd	s7,40(sp)
    80003bbc:	1880                	addi	s0,sp,112
    80003bbe:	8b2a                	mv	s6,a0
    80003bc0:	8bae                	mv	s7,a1
    80003bc2:	8a32                	mv	s4,a2
    80003bc4:	84b6                	mv	s1,a3
    80003bc6:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    80003bc8:	9f35                	addw	a4,a4,a3
    return 0;
    80003bca:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80003bcc:	0ad76b63          	bltu	a4,a3,80003c82 <readi+0xdc>
    80003bd0:	e4ce                	sd	s3,72(sp)
  if(off + n > ip->size)
    80003bd2:	00e7f463          	bgeu	a5,a4,80003bda <readi+0x34>
    n = ip->size - off;
    80003bd6:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003bda:	080a8b63          	beqz	s5,80003c70 <readi+0xca>
    80003bde:	e8ca                	sd	s2,80(sp)
    80003be0:	f062                	sd	s8,32(sp)
    80003be2:	ec66                	sd	s9,24(sp)
    80003be4:	e86a                	sd	s10,16(sp)
    80003be6:	e46e                	sd	s11,8(sp)
    80003be8:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003bea:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80003bee:	5c7d                	li	s8,-1
    80003bf0:	a80d                	j	80003c22 <readi+0x7c>
    80003bf2:	020d1d93          	slli	s11,s10,0x20
    80003bf6:	020ddd93          	srli	s11,s11,0x20
    80003bfa:	05890613          	addi	a2,s2,88
    80003bfe:	86ee                	mv	a3,s11
    80003c00:	963e                	add	a2,a2,a5
    80003c02:	85d2                	mv	a1,s4
    80003c04:	855e                	mv	a0,s7
    80003c06:	bc1fe0ef          	jal	800027c6 <either_copyout>
    80003c0a:	05850363          	beq	a0,s8,80003c50 <readi+0xaa>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80003c0e:	854a                	mv	a0,s2
    80003c10:	e5eff0ef          	jal	8000326e <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003c14:	013d09bb          	addw	s3,s10,s3
    80003c18:	009d04bb          	addw	s1,s10,s1
    80003c1c:	9a6e                	add	s4,s4,s11
    80003c1e:	0559f363          	bgeu	s3,s5,80003c64 <readi+0xbe>
    uint addr = bmap(ip, off/BSIZE);
    80003c22:	00a4d59b          	srliw	a1,s1,0xa
    80003c26:	855a                	mv	a0,s6
    80003c28:	8bbff0ef          	jal	800034e2 <bmap>
    80003c2c:	85aa                	mv	a1,a0
    if(addr == 0)
    80003c2e:	c139                	beqz	a0,80003c74 <readi+0xce>
    bp = bread(ip->dev, addr);
    80003c30:	000b2503          	lw	a0,0(s6)
    80003c34:	d0aff0ef          	jal	8000313e <bread>
    80003c38:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003c3a:	3ff4f793          	andi	a5,s1,1023
    80003c3e:	40fc873b          	subw	a4,s9,a5
    80003c42:	413a86bb          	subw	a3,s5,s3
    80003c46:	8d3a                	mv	s10,a4
    80003c48:	fae6f5e3          	bgeu	a3,a4,80003bf2 <readi+0x4c>
    80003c4c:	8d36                	mv	s10,a3
    80003c4e:	b755                	j	80003bf2 <readi+0x4c>
      brelse(bp);
    80003c50:	854a                	mv	a0,s2
    80003c52:	e1cff0ef          	jal	8000326e <brelse>
      tot = -1;
    80003c56:	59fd                	li	s3,-1
      break;
    80003c58:	6946                	ld	s2,80(sp)
    80003c5a:	7c02                	ld	s8,32(sp)
    80003c5c:	6ce2                	ld	s9,24(sp)
    80003c5e:	6d42                	ld	s10,16(sp)
    80003c60:	6da2                	ld	s11,8(sp)
    80003c62:	a831                	j	80003c7e <readi+0xd8>
    80003c64:	6946                	ld	s2,80(sp)
    80003c66:	7c02                	ld	s8,32(sp)
    80003c68:	6ce2                	ld	s9,24(sp)
    80003c6a:	6d42                	ld	s10,16(sp)
    80003c6c:	6da2                	ld	s11,8(sp)
    80003c6e:	a801                	j	80003c7e <readi+0xd8>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003c70:	89d6                	mv	s3,s5
    80003c72:	a031                	j	80003c7e <readi+0xd8>
    80003c74:	6946                	ld	s2,80(sp)
    80003c76:	7c02                	ld	s8,32(sp)
    80003c78:	6ce2                	ld	s9,24(sp)
    80003c7a:	6d42                	ld	s10,16(sp)
    80003c7c:	6da2                	ld	s11,8(sp)
  }
  return tot;
    80003c7e:	854e                	mv	a0,s3
    80003c80:	69a6                	ld	s3,72(sp)
}
    80003c82:	70a6                	ld	ra,104(sp)
    80003c84:	7406                	ld	s0,96(sp)
    80003c86:	64e6                	ld	s1,88(sp)
    80003c88:	6a06                	ld	s4,64(sp)
    80003c8a:	7ae2                	ld	s5,56(sp)
    80003c8c:	7b42                	ld	s6,48(sp)
    80003c8e:	7ba2                	ld	s7,40(sp)
    80003c90:	6165                	addi	sp,sp,112
    80003c92:	8082                	ret
    return 0;
    80003c94:	4501                	li	a0,0
}
    80003c96:	8082                	ret

0000000080003c98 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003c98:	457c                	lw	a5,76(a0)
    80003c9a:	0ed7eb63          	bltu	a5,a3,80003d90 <writei+0xf8>
{
    80003c9e:	7159                	addi	sp,sp,-112
    80003ca0:	f486                	sd	ra,104(sp)
    80003ca2:	f0a2                	sd	s0,96(sp)
    80003ca4:	e8ca                	sd	s2,80(sp)
    80003ca6:	e0d2                	sd	s4,64(sp)
    80003ca8:	fc56                	sd	s5,56(sp)
    80003caa:	f85a                	sd	s6,48(sp)
    80003cac:	f45e                	sd	s7,40(sp)
    80003cae:	1880                	addi	s0,sp,112
    80003cb0:	8aaa                	mv	s5,a0
    80003cb2:	8bae                	mv	s7,a1
    80003cb4:	8a32                	mv	s4,a2
    80003cb6:	8936                	mv	s2,a3
    80003cb8:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003cba:	00e687bb          	addw	a5,a3,a4
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80003cbe:	00043737          	lui	a4,0x43
    80003cc2:	0cf76963          	bltu	a4,a5,80003d94 <writei+0xfc>
    80003cc6:	0cd7e763          	bltu	a5,a3,80003d94 <writei+0xfc>
    80003cca:	e4ce                	sd	s3,72(sp)
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003ccc:	0a0b0a63          	beqz	s6,80003d80 <writei+0xe8>
    80003cd0:	eca6                	sd	s1,88(sp)
    80003cd2:	f062                	sd	s8,32(sp)
    80003cd4:	ec66                	sd	s9,24(sp)
    80003cd6:	e86a                	sd	s10,16(sp)
    80003cd8:	e46e                	sd	s11,8(sp)
    80003cda:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003cdc:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80003ce0:	5c7d                	li	s8,-1
    80003ce2:	a825                	j	80003d1a <writei+0x82>
    80003ce4:	020d1d93          	slli	s11,s10,0x20
    80003ce8:	020ddd93          	srli	s11,s11,0x20
    80003cec:	05848513          	addi	a0,s1,88
    80003cf0:	86ee                	mv	a3,s11
    80003cf2:	8652                	mv	a2,s4
    80003cf4:	85de                	mv	a1,s7
    80003cf6:	953e                	add	a0,a0,a5
    80003cf8:	b19fe0ef          	jal	80002810 <either_copyin>
    80003cfc:	05850663          	beq	a0,s8,80003d48 <writei+0xb0>
      brelse(bp);
      break;
    }
    log_write(bp);
    80003d00:	8526                	mv	a0,s1
    80003d02:	6b8000ef          	jal	800043ba <log_write>
    brelse(bp);
    80003d06:	8526                	mv	a0,s1
    80003d08:	d66ff0ef          	jal	8000326e <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003d0c:	013d09bb          	addw	s3,s10,s3
    80003d10:	012d093b          	addw	s2,s10,s2
    80003d14:	9a6e                	add	s4,s4,s11
    80003d16:	0369fc63          	bgeu	s3,s6,80003d4e <writei+0xb6>
    uint addr = bmap(ip, off/BSIZE);
    80003d1a:	00a9559b          	srliw	a1,s2,0xa
    80003d1e:	8556                	mv	a0,s5
    80003d20:	fc2ff0ef          	jal	800034e2 <bmap>
    80003d24:	85aa                	mv	a1,a0
    if(addr == 0)
    80003d26:	c505                	beqz	a0,80003d4e <writei+0xb6>
    bp = bread(ip->dev, addr);
    80003d28:	000aa503          	lw	a0,0(s5)
    80003d2c:	c12ff0ef          	jal	8000313e <bread>
    80003d30:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003d32:	3ff97793          	andi	a5,s2,1023
    80003d36:	40fc873b          	subw	a4,s9,a5
    80003d3a:	413b06bb          	subw	a3,s6,s3
    80003d3e:	8d3a                	mv	s10,a4
    80003d40:	fae6f2e3          	bgeu	a3,a4,80003ce4 <writei+0x4c>
    80003d44:	8d36                	mv	s10,a3
    80003d46:	bf79                	j	80003ce4 <writei+0x4c>
      brelse(bp);
    80003d48:	8526                	mv	a0,s1
    80003d4a:	d24ff0ef          	jal	8000326e <brelse>
  }

  if(off > ip->size)
    80003d4e:	04caa783          	lw	a5,76(s5)
    80003d52:	0327f963          	bgeu	a5,s2,80003d84 <writei+0xec>
    ip->size = off;
    80003d56:	052aa623          	sw	s2,76(s5)
    80003d5a:	64e6                	ld	s1,88(sp)
    80003d5c:	7c02                	ld	s8,32(sp)
    80003d5e:	6ce2                	ld	s9,24(sp)
    80003d60:	6d42                	ld	s10,16(sp)
    80003d62:	6da2                	ld	s11,8(sp)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80003d64:	8556                	mv	a0,s5
    80003d66:	9fbff0ef          	jal	80003760 <iupdate>

  return tot;
    80003d6a:	854e                	mv	a0,s3
    80003d6c:	69a6                	ld	s3,72(sp)
}
    80003d6e:	70a6                	ld	ra,104(sp)
    80003d70:	7406                	ld	s0,96(sp)
    80003d72:	6946                	ld	s2,80(sp)
    80003d74:	6a06                	ld	s4,64(sp)
    80003d76:	7ae2                	ld	s5,56(sp)
    80003d78:	7b42                	ld	s6,48(sp)
    80003d7a:	7ba2                	ld	s7,40(sp)
    80003d7c:	6165                	addi	sp,sp,112
    80003d7e:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003d80:	89da                	mv	s3,s6
    80003d82:	b7cd                	j	80003d64 <writei+0xcc>
    80003d84:	64e6                	ld	s1,88(sp)
    80003d86:	7c02                	ld	s8,32(sp)
    80003d88:	6ce2                	ld	s9,24(sp)
    80003d8a:	6d42                	ld	s10,16(sp)
    80003d8c:	6da2                	ld	s11,8(sp)
    80003d8e:	bfd9                	j	80003d64 <writei+0xcc>
    return -1;
    80003d90:	557d                	li	a0,-1
}
    80003d92:	8082                	ret
    return -1;
    80003d94:	557d                	li	a0,-1
    80003d96:	bfe1                	j	80003d6e <writei+0xd6>

0000000080003d98 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80003d98:	1141                	addi	sp,sp,-16
    80003d9a:	e406                	sd	ra,8(sp)
    80003d9c:	e022                	sd	s0,0(sp)
    80003d9e:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80003da0:	4639                	li	a2,14
    80003da2:	924fd0ef          	jal	80000ec6 <strncmp>
}
    80003da6:	60a2                	ld	ra,8(sp)
    80003da8:	6402                	ld	s0,0(sp)
    80003daa:	0141                	addi	sp,sp,16
    80003dac:	8082                	ret

0000000080003dae <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80003dae:	711d                	addi	sp,sp,-96
    80003db0:	ec86                	sd	ra,88(sp)
    80003db2:	e8a2                	sd	s0,80(sp)
    80003db4:	e4a6                	sd	s1,72(sp)
    80003db6:	e0ca                	sd	s2,64(sp)
    80003db8:	fc4e                	sd	s3,56(sp)
    80003dba:	f852                	sd	s4,48(sp)
    80003dbc:	f456                	sd	s5,40(sp)
    80003dbe:	f05a                	sd	s6,32(sp)
    80003dc0:	ec5e                	sd	s7,24(sp)
    80003dc2:	1080                	addi	s0,sp,96
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80003dc4:	04451703          	lh	a4,68(a0)
    80003dc8:	4785                	li	a5,1
    80003dca:	00f71f63          	bne	a4,a5,80003de8 <dirlookup+0x3a>
    80003dce:	892a                	mv	s2,a0
    80003dd0:	8aae                	mv	s5,a1
    80003dd2:	8bb2                	mv	s7,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80003dd4:	457c                	lw	a5,76(a0)
    80003dd6:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003dd8:	fa040a13          	addi	s4,s0,-96
    80003ddc:	49c1                	li	s3,16
      panic("dirlookup read");
    if(de.inum == 0)
      continue;
    if(namecmp(name, de.name) == 0){
    80003dde:	fa240b13          	addi	s6,s0,-94
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80003de2:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003de4:	e39d                	bnez	a5,80003e0a <dirlookup+0x5c>
    80003de6:	a8b9                	j	80003e44 <dirlookup+0x96>
    panic("dirlookup not DIR");
    80003de8:	00004517          	auipc	a0,0x4
    80003dec:	6f050513          	addi	a0,a0,1776 # 800084d8 <etext+0x4d8>
    80003df0:	a67fc0ef          	jal	80000856 <panic>
      panic("dirlookup read");
    80003df4:	00004517          	auipc	a0,0x4
    80003df8:	6fc50513          	addi	a0,a0,1788 # 800084f0 <etext+0x4f0>
    80003dfc:	a5bfc0ef          	jal	80000856 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003e00:	24c1                	addiw	s1,s1,16
    80003e02:	04c92783          	lw	a5,76(s2)
    80003e06:	02f4fe63          	bgeu	s1,a5,80003e42 <dirlookup+0x94>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003e0a:	874e                	mv	a4,s3
    80003e0c:	86a6                	mv	a3,s1
    80003e0e:	8652                	mv	a2,s4
    80003e10:	4581                	li	a1,0
    80003e12:	854a                	mv	a0,s2
    80003e14:	d93ff0ef          	jal	80003ba6 <readi>
    80003e18:	fd351ee3          	bne	a0,s3,80003df4 <dirlookup+0x46>
    if(de.inum == 0)
    80003e1c:	fa045783          	lhu	a5,-96(s0)
    80003e20:	d3e5                	beqz	a5,80003e00 <dirlookup+0x52>
    if(namecmp(name, de.name) == 0){
    80003e22:	85da                	mv	a1,s6
    80003e24:	8556                	mv	a0,s5
    80003e26:	f73ff0ef          	jal	80003d98 <namecmp>
    80003e2a:	f979                	bnez	a0,80003e00 <dirlookup+0x52>
      if(poff)
    80003e2c:	000b8463          	beqz	s7,80003e34 <dirlookup+0x86>
        *poff = off;
    80003e30:	009ba023          	sw	s1,0(s7)
      return iget(dp->dev, inum);
    80003e34:	fa045583          	lhu	a1,-96(s0)
    80003e38:	00092503          	lw	a0,0(s2)
    80003e3c:	f66ff0ef          	jal	800035a2 <iget>
    80003e40:	a011                	j	80003e44 <dirlookup+0x96>
  return 0;
    80003e42:	4501                	li	a0,0
}
    80003e44:	60e6                	ld	ra,88(sp)
    80003e46:	6446                	ld	s0,80(sp)
    80003e48:	64a6                	ld	s1,72(sp)
    80003e4a:	6906                	ld	s2,64(sp)
    80003e4c:	79e2                	ld	s3,56(sp)
    80003e4e:	7a42                	ld	s4,48(sp)
    80003e50:	7aa2                	ld	s5,40(sp)
    80003e52:	7b02                	ld	s6,32(sp)
    80003e54:	6be2                	ld	s7,24(sp)
    80003e56:	6125                	addi	sp,sp,96
    80003e58:	8082                	ret

0000000080003e5a <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80003e5a:	711d                	addi	sp,sp,-96
    80003e5c:	ec86                	sd	ra,88(sp)
    80003e5e:	e8a2                	sd	s0,80(sp)
    80003e60:	e4a6                	sd	s1,72(sp)
    80003e62:	e0ca                	sd	s2,64(sp)
    80003e64:	fc4e                	sd	s3,56(sp)
    80003e66:	f852                	sd	s4,48(sp)
    80003e68:	f456                	sd	s5,40(sp)
    80003e6a:	f05a                	sd	s6,32(sp)
    80003e6c:	ec5e                	sd	s7,24(sp)
    80003e6e:	e862                	sd	s8,16(sp)
    80003e70:	e466                	sd	s9,8(sp)
    80003e72:	e06a                	sd	s10,0(sp)
    80003e74:	1080                	addi	s0,sp,96
    80003e76:	84aa                	mv	s1,a0
    80003e78:	8b2e                	mv	s6,a1
    80003e7a:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    80003e7c:	00054703          	lbu	a4,0(a0)
    80003e80:	02f00793          	li	a5,47
    80003e84:	00f70f63          	beq	a4,a5,80003ea2 <namex+0x48>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80003e88:	db9fd0ef          	jal	80001c40 <myproc>
    80003e8c:	15053503          	ld	a0,336(a0)
    80003e90:	94fff0ef          	jal	800037de <idup>
    80003e94:	8a2a                	mv	s4,a0
  while(*path == '/')
    80003e96:	02f00993          	li	s3,47
  if(len >= DIRSIZ)
    80003e9a:	4c35                	li	s8,13
    memmove(name, s, DIRSIZ);
    80003e9c:	4cb9                	li	s9,14

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80003e9e:	4b85                	li	s7,1
    80003ea0:	a879                	j	80003f3e <namex+0xe4>
    ip = iget(ROOTDEV, ROOTINO);
    80003ea2:	4585                	li	a1,1
    80003ea4:	852e                	mv	a0,a1
    80003ea6:	efcff0ef          	jal	800035a2 <iget>
    80003eaa:	8a2a                	mv	s4,a0
    80003eac:	b7ed                	j	80003e96 <namex+0x3c>
      iunlockput(ip);
    80003eae:	8552                	mv	a0,s4
    80003eb0:	b71ff0ef          	jal	80003a20 <iunlockput>
      return 0;
    80003eb4:	4a01                	li	s4,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80003eb6:	8552                	mv	a0,s4
    80003eb8:	60e6                	ld	ra,88(sp)
    80003eba:	6446                	ld	s0,80(sp)
    80003ebc:	64a6                	ld	s1,72(sp)
    80003ebe:	6906                	ld	s2,64(sp)
    80003ec0:	79e2                	ld	s3,56(sp)
    80003ec2:	7a42                	ld	s4,48(sp)
    80003ec4:	7aa2                	ld	s5,40(sp)
    80003ec6:	7b02                	ld	s6,32(sp)
    80003ec8:	6be2                	ld	s7,24(sp)
    80003eca:	6c42                	ld	s8,16(sp)
    80003ecc:	6ca2                	ld	s9,8(sp)
    80003ece:	6d02                	ld	s10,0(sp)
    80003ed0:	6125                	addi	sp,sp,96
    80003ed2:	8082                	ret
      iunlock(ip);
    80003ed4:	8552                	mv	a0,s4
    80003ed6:	9edff0ef          	jal	800038c2 <iunlock>
      return ip;
    80003eda:	bff1                	j	80003eb6 <namex+0x5c>
      iunlockput(ip);
    80003edc:	8552                	mv	a0,s4
    80003ede:	b43ff0ef          	jal	80003a20 <iunlockput>
      return 0;
    80003ee2:	8a4a                	mv	s4,s2
    80003ee4:	bfc9                	j	80003eb6 <namex+0x5c>
  len = path - s;
    80003ee6:	40990633          	sub	a2,s2,s1
    80003eea:	00060d1b          	sext.w	s10,a2
  if(len >= DIRSIZ)
    80003eee:	09ac5463          	bge	s8,s10,80003f76 <namex+0x11c>
    memmove(name, s, DIRSIZ);
    80003ef2:	8666                	mv	a2,s9
    80003ef4:	85a6                	mv	a1,s1
    80003ef6:	8556                	mv	a0,s5
    80003ef8:	f5bfc0ef          	jal	80000e52 <memmove>
    80003efc:	84ca                	mv	s1,s2
  while(*path == '/')
    80003efe:	0004c783          	lbu	a5,0(s1)
    80003f02:	01379763          	bne	a5,s3,80003f10 <namex+0xb6>
    path++;
    80003f06:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003f08:	0004c783          	lbu	a5,0(s1)
    80003f0c:	ff378de3          	beq	a5,s3,80003f06 <namex+0xac>
    ilock(ip);
    80003f10:	8552                	mv	a0,s4
    80003f12:	903ff0ef          	jal	80003814 <ilock>
    if(ip->type != T_DIR){
    80003f16:	044a1783          	lh	a5,68(s4)
    80003f1a:	f9779ae3          	bne	a5,s7,80003eae <namex+0x54>
    if(nameiparent && *path == '\0'){
    80003f1e:	000b0563          	beqz	s6,80003f28 <namex+0xce>
    80003f22:	0004c783          	lbu	a5,0(s1)
    80003f26:	d7dd                	beqz	a5,80003ed4 <namex+0x7a>
    if((next = dirlookup(ip, name, 0)) == 0){
    80003f28:	4601                	li	a2,0
    80003f2a:	85d6                	mv	a1,s5
    80003f2c:	8552                	mv	a0,s4
    80003f2e:	e81ff0ef          	jal	80003dae <dirlookup>
    80003f32:	892a                	mv	s2,a0
    80003f34:	d545                	beqz	a0,80003edc <namex+0x82>
    iunlockput(ip);
    80003f36:	8552                	mv	a0,s4
    80003f38:	ae9ff0ef          	jal	80003a20 <iunlockput>
    ip = next;
    80003f3c:	8a4a                	mv	s4,s2
  while(*path == '/')
    80003f3e:	0004c783          	lbu	a5,0(s1)
    80003f42:	01379763          	bne	a5,s3,80003f50 <namex+0xf6>
    path++;
    80003f46:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003f48:	0004c783          	lbu	a5,0(s1)
    80003f4c:	ff378de3          	beq	a5,s3,80003f46 <namex+0xec>
  if(*path == 0)
    80003f50:	cf8d                	beqz	a5,80003f8a <namex+0x130>
  while(*path != '/' && *path != 0)
    80003f52:	0004c783          	lbu	a5,0(s1)
    80003f56:	fd178713          	addi	a4,a5,-47
    80003f5a:	cb19                	beqz	a4,80003f70 <namex+0x116>
    80003f5c:	cb91                	beqz	a5,80003f70 <namex+0x116>
    80003f5e:	8926                	mv	s2,s1
    path++;
    80003f60:	0905                	addi	s2,s2,1
  while(*path != '/' && *path != 0)
    80003f62:	00094783          	lbu	a5,0(s2)
    80003f66:	fd178713          	addi	a4,a5,-47
    80003f6a:	df35                	beqz	a4,80003ee6 <namex+0x8c>
    80003f6c:	fbf5                	bnez	a5,80003f60 <namex+0x106>
    80003f6e:	bfa5                	j	80003ee6 <namex+0x8c>
    80003f70:	8926                	mv	s2,s1
  len = path - s;
    80003f72:	4d01                	li	s10,0
    80003f74:	4601                	li	a2,0
    memmove(name, s, len);
    80003f76:	2601                	sext.w	a2,a2
    80003f78:	85a6                	mv	a1,s1
    80003f7a:	8556                	mv	a0,s5
    80003f7c:	ed7fc0ef          	jal	80000e52 <memmove>
    name[len] = 0;
    80003f80:	9d56                	add	s10,s10,s5
    80003f82:	000d0023          	sb	zero,0(s10) # fffffffffffff000 <end+0xffffffff7ffb6c08>
    80003f86:	84ca                	mv	s1,s2
    80003f88:	bf9d                	j	80003efe <namex+0xa4>
  if(nameiparent){
    80003f8a:	f20b06e3          	beqz	s6,80003eb6 <namex+0x5c>
    iput(ip);
    80003f8e:	8552                	mv	a0,s4
    80003f90:	a07ff0ef          	jal	80003996 <iput>
    return 0;
    80003f94:	4a01                	li	s4,0
    80003f96:	b705                	j	80003eb6 <namex+0x5c>

0000000080003f98 <dirlink>:
{
    80003f98:	715d                	addi	sp,sp,-80
    80003f9a:	e486                	sd	ra,72(sp)
    80003f9c:	e0a2                	sd	s0,64(sp)
    80003f9e:	f84a                	sd	s2,48(sp)
    80003fa0:	ec56                	sd	s5,24(sp)
    80003fa2:	e85a                	sd	s6,16(sp)
    80003fa4:	0880                	addi	s0,sp,80
    80003fa6:	892a                	mv	s2,a0
    80003fa8:	8aae                	mv	s5,a1
    80003faa:	8b32                	mv	s6,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80003fac:	4601                	li	a2,0
    80003fae:	e01ff0ef          	jal	80003dae <dirlookup>
    80003fb2:	ed1d                	bnez	a0,80003ff0 <dirlink+0x58>
    80003fb4:	fc26                	sd	s1,56(sp)
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003fb6:	04c92483          	lw	s1,76(s2)
    80003fba:	c4b9                	beqz	s1,80004008 <dirlink+0x70>
    80003fbc:	f44e                	sd	s3,40(sp)
    80003fbe:	f052                	sd	s4,32(sp)
    80003fc0:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003fc2:	fb040a13          	addi	s4,s0,-80
    80003fc6:	49c1                	li	s3,16
    80003fc8:	874e                	mv	a4,s3
    80003fca:	86a6                	mv	a3,s1
    80003fcc:	8652                	mv	a2,s4
    80003fce:	4581                	li	a1,0
    80003fd0:	854a                	mv	a0,s2
    80003fd2:	bd5ff0ef          	jal	80003ba6 <readi>
    80003fd6:	03351163          	bne	a0,s3,80003ff8 <dirlink+0x60>
    if(de.inum == 0)
    80003fda:	fb045783          	lhu	a5,-80(s0)
    80003fde:	c39d                	beqz	a5,80004004 <dirlink+0x6c>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003fe0:	24c1                	addiw	s1,s1,16
    80003fe2:	04c92783          	lw	a5,76(s2)
    80003fe6:	fef4e1e3          	bltu	s1,a5,80003fc8 <dirlink+0x30>
    80003fea:	79a2                	ld	s3,40(sp)
    80003fec:	7a02                	ld	s4,32(sp)
    80003fee:	a829                	j	80004008 <dirlink+0x70>
    iput(ip);
    80003ff0:	9a7ff0ef          	jal	80003996 <iput>
    return -1;
    80003ff4:	557d                	li	a0,-1
    80003ff6:	a83d                	j	80004034 <dirlink+0x9c>
      panic("dirlink read");
    80003ff8:	00004517          	auipc	a0,0x4
    80003ffc:	50850513          	addi	a0,a0,1288 # 80008500 <etext+0x500>
    80004000:	857fc0ef          	jal	80000856 <panic>
    80004004:	79a2                	ld	s3,40(sp)
    80004006:	7a02                	ld	s4,32(sp)
  strncpy(de.name, name, DIRSIZ);
    80004008:	4639                	li	a2,14
    8000400a:	85d6                	mv	a1,s5
    8000400c:	fb240513          	addi	a0,s0,-78
    80004010:	ef1fc0ef          	jal	80000f00 <strncpy>
  de.inum = inum;
    80004014:	fb641823          	sh	s6,-80(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004018:	4741                	li	a4,16
    8000401a:	86a6                	mv	a3,s1
    8000401c:	fb040613          	addi	a2,s0,-80
    80004020:	4581                	li	a1,0
    80004022:	854a                	mv	a0,s2
    80004024:	c75ff0ef          	jal	80003c98 <writei>
    80004028:	1541                	addi	a0,a0,-16
    8000402a:	00a03533          	snez	a0,a0
    8000402e:	40a0053b          	negw	a0,a0
    80004032:	74e2                	ld	s1,56(sp)
}
    80004034:	60a6                	ld	ra,72(sp)
    80004036:	6406                	ld	s0,64(sp)
    80004038:	7942                	ld	s2,48(sp)
    8000403a:	6ae2                	ld	s5,24(sp)
    8000403c:	6b42                	ld	s6,16(sp)
    8000403e:	6161                	addi	sp,sp,80
    80004040:	8082                	ret

0000000080004042 <namei>:

struct inode*
namei(char *path)
{
    80004042:	1101                	addi	sp,sp,-32
    80004044:	ec06                	sd	ra,24(sp)
    80004046:	e822                	sd	s0,16(sp)
    80004048:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    8000404a:	fe040613          	addi	a2,s0,-32
    8000404e:	4581                	li	a1,0
    80004050:	e0bff0ef          	jal	80003e5a <namex>
}
    80004054:	60e2                	ld	ra,24(sp)
    80004056:	6442                	ld	s0,16(sp)
    80004058:	6105                	addi	sp,sp,32
    8000405a:	8082                	ret

000000008000405c <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    8000405c:	1141                	addi	sp,sp,-16
    8000405e:	e406                	sd	ra,8(sp)
    80004060:	e022                	sd	s0,0(sp)
    80004062:	0800                	addi	s0,sp,16
    80004064:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80004066:	4585                	li	a1,1
    80004068:	df3ff0ef          	jal	80003e5a <namex>
}
    8000406c:	60a2                	ld	ra,8(sp)
    8000406e:	6402                	ld	s0,0(sp)
    80004070:	0141                	addi	sp,sp,16
    80004072:	8082                	ret

0000000080004074 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80004074:	1101                	addi	sp,sp,-32
    80004076:	ec06                	sd	ra,24(sp)
    80004078:	e822                	sd	s0,16(sp)
    8000407a:	e426                	sd	s1,8(sp)
    8000407c:	e04a                	sd	s2,0(sp)
    8000407e:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80004080:	0001e917          	auipc	s2,0x1e
    80004084:	09090913          	addi	s2,s2,144 # 80022110 <log>
    80004088:	01892583          	lw	a1,24(s2)
    8000408c:	02492503          	lw	a0,36(s2)
    80004090:	8aeff0ef          	jal	8000313e <bread>
    80004094:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    80004096:	02892603          	lw	a2,40(s2)
    8000409a:	cd30                	sw	a2,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    8000409c:	00c05f63          	blez	a2,800040ba <write_head+0x46>
    800040a0:	0001e717          	auipc	a4,0x1e
    800040a4:	09c70713          	addi	a4,a4,156 # 8002213c <log+0x2c>
    800040a8:	87aa                	mv	a5,a0
    800040aa:	060a                	slli	a2,a2,0x2
    800040ac:	962a                	add	a2,a2,a0
    hb->block[i] = log.lh.block[i];
    800040ae:	4314                	lw	a3,0(a4)
    800040b0:	cff4                	sw	a3,92(a5)
  for (i = 0; i < log.lh.n; i++) {
    800040b2:	0711                	addi	a4,a4,4
    800040b4:	0791                	addi	a5,a5,4
    800040b6:	fec79ce3          	bne	a5,a2,800040ae <write_head+0x3a>
  }
  bwrite(buf);
    800040ba:	8526                	mv	a0,s1
    800040bc:	980ff0ef          	jal	8000323c <bwrite>
  brelse(buf);
    800040c0:	8526                	mv	a0,s1
    800040c2:	9acff0ef          	jal	8000326e <brelse>
}
    800040c6:	60e2                	ld	ra,24(sp)
    800040c8:	6442                	ld	s0,16(sp)
    800040ca:	64a2                	ld	s1,8(sp)
    800040cc:	6902                	ld	s2,0(sp)
    800040ce:	6105                	addi	sp,sp,32
    800040d0:	8082                	ret

00000000800040d2 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    800040d2:	0001e797          	auipc	a5,0x1e
    800040d6:	0667a783          	lw	a5,102(a5) # 80022138 <log+0x28>
    800040da:	0cf05163          	blez	a5,8000419c <install_trans+0xca>
{
    800040de:	715d                	addi	sp,sp,-80
    800040e0:	e486                	sd	ra,72(sp)
    800040e2:	e0a2                	sd	s0,64(sp)
    800040e4:	fc26                	sd	s1,56(sp)
    800040e6:	f84a                	sd	s2,48(sp)
    800040e8:	f44e                	sd	s3,40(sp)
    800040ea:	f052                	sd	s4,32(sp)
    800040ec:	ec56                	sd	s5,24(sp)
    800040ee:	e85a                	sd	s6,16(sp)
    800040f0:	e45e                	sd	s7,8(sp)
    800040f2:	e062                	sd	s8,0(sp)
    800040f4:	0880                	addi	s0,sp,80
    800040f6:	8b2a                	mv	s6,a0
    800040f8:	0001ea97          	auipc	s5,0x1e
    800040fc:	044a8a93          	addi	s5,s5,68 # 8002213c <log+0x2c>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004100:	4981                	li	s3,0
      printf("recovering tail %d dst %d\n", tail, log.lh.block[tail]);
    80004102:	00004c17          	auipc	s8,0x4
    80004106:	40ec0c13          	addi	s8,s8,1038 # 80008510 <etext+0x510>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    8000410a:	0001ea17          	auipc	s4,0x1e
    8000410e:	006a0a13          	addi	s4,s4,6 # 80022110 <log>
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80004112:	40000b93          	li	s7,1024
    80004116:	a025                	j	8000413e <install_trans+0x6c>
      printf("recovering tail %d dst %d\n", tail, log.lh.block[tail]);
    80004118:	000aa603          	lw	a2,0(s5)
    8000411c:	85ce                	mv	a1,s3
    8000411e:	8562                	mv	a0,s8
    80004120:	c0cfc0ef          	jal	8000052c <printf>
    80004124:	a839                	j	80004142 <install_trans+0x70>
    brelse(lbuf);
    80004126:	854a                	mv	a0,s2
    80004128:	946ff0ef          	jal	8000326e <brelse>
    brelse(dbuf);
    8000412c:	8526                	mv	a0,s1
    8000412e:	940ff0ef          	jal	8000326e <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004132:	2985                	addiw	s3,s3,1
    80004134:	0a91                	addi	s5,s5,4
    80004136:	028a2783          	lw	a5,40(s4)
    8000413a:	04f9d563          	bge	s3,a5,80004184 <install_trans+0xb2>
    if(recovering) {
    8000413e:	fc0b1de3          	bnez	s6,80004118 <install_trans+0x46>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80004142:	018a2583          	lw	a1,24(s4)
    80004146:	013585bb          	addw	a1,a1,s3
    8000414a:	2585                	addiw	a1,a1,1
    8000414c:	024a2503          	lw	a0,36(s4)
    80004150:	feffe0ef          	jal	8000313e <bread>
    80004154:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    80004156:	000aa583          	lw	a1,0(s5)
    8000415a:	024a2503          	lw	a0,36(s4)
    8000415e:	fe1fe0ef          	jal	8000313e <bread>
    80004162:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80004164:	865e                	mv	a2,s7
    80004166:	05890593          	addi	a1,s2,88
    8000416a:	05850513          	addi	a0,a0,88
    8000416e:	ce5fc0ef          	jal	80000e52 <memmove>
    bwrite(dbuf);  // write dst to disk
    80004172:	8526                	mv	a0,s1
    80004174:	8c8ff0ef          	jal	8000323c <bwrite>
    if(recovering == 0)
    80004178:	fa0b17e3          	bnez	s6,80004126 <install_trans+0x54>
      bunpin(dbuf);
    8000417c:	8526                	mv	a0,s1
    8000417e:	9beff0ef          	jal	8000333c <bunpin>
    80004182:	b755                	j	80004126 <install_trans+0x54>
}
    80004184:	60a6                	ld	ra,72(sp)
    80004186:	6406                	ld	s0,64(sp)
    80004188:	74e2                	ld	s1,56(sp)
    8000418a:	7942                	ld	s2,48(sp)
    8000418c:	79a2                	ld	s3,40(sp)
    8000418e:	7a02                	ld	s4,32(sp)
    80004190:	6ae2                	ld	s5,24(sp)
    80004192:	6b42                	ld	s6,16(sp)
    80004194:	6ba2                	ld	s7,8(sp)
    80004196:	6c02                	ld	s8,0(sp)
    80004198:	6161                	addi	sp,sp,80
    8000419a:	8082                	ret
    8000419c:	8082                	ret

000000008000419e <initlog>:
{
    8000419e:	7179                	addi	sp,sp,-48
    800041a0:	f406                	sd	ra,40(sp)
    800041a2:	f022                	sd	s0,32(sp)
    800041a4:	ec26                	sd	s1,24(sp)
    800041a6:	e84a                	sd	s2,16(sp)
    800041a8:	e44e                	sd	s3,8(sp)
    800041aa:	1800                	addi	s0,sp,48
    800041ac:	84aa                	mv	s1,a0
    800041ae:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    800041b0:	0001e917          	auipc	s2,0x1e
    800041b4:	f6090913          	addi	s2,s2,-160 # 80022110 <log>
    800041b8:	00004597          	auipc	a1,0x4
    800041bc:	37858593          	addi	a1,a1,888 # 80008530 <etext+0x530>
    800041c0:	854a                	mv	a0,s2
    800041c2:	ad7fc0ef          	jal	80000c98 <initlock>
  log.start = sb->logstart;
    800041c6:	0149a583          	lw	a1,20(s3)
    800041ca:	00b92c23          	sw	a1,24(s2)
  log.dev = dev;
    800041ce:	02992223          	sw	s1,36(s2)
  struct buf *buf = bread(log.dev, log.start);
    800041d2:	8526                	mv	a0,s1
    800041d4:	f6bfe0ef          	jal	8000313e <bread>
  log.lh.n = lh->n;
    800041d8:	4d30                	lw	a2,88(a0)
    800041da:	02c92423          	sw	a2,40(s2)
  for (i = 0; i < log.lh.n; i++) {
    800041de:	00c05f63          	blez	a2,800041fc <initlog+0x5e>
    800041e2:	87aa                	mv	a5,a0
    800041e4:	0001e717          	auipc	a4,0x1e
    800041e8:	f5870713          	addi	a4,a4,-168 # 8002213c <log+0x2c>
    800041ec:	060a                	slli	a2,a2,0x2
    800041ee:	962a                	add	a2,a2,a0
    log.lh.block[i] = lh->block[i];
    800041f0:	4ff4                	lw	a3,92(a5)
    800041f2:	c314                	sw	a3,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    800041f4:	0791                	addi	a5,a5,4
    800041f6:	0711                	addi	a4,a4,4
    800041f8:	fec79ce3          	bne	a5,a2,800041f0 <initlog+0x52>
  brelse(buf);
    800041fc:	872ff0ef          	jal	8000326e <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    80004200:	4505                	li	a0,1
    80004202:	ed1ff0ef          	jal	800040d2 <install_trans>
  log.lh.n = 0;
    80004206:	0001e797          	auipc	a5,0x1e
    8000420a:	f207a923          	sw	zero,-206(a5) # 80022138 <log+0x28>
  write_head(); // clear the log
    8000420e:	e67ff0ef          	jal	80004074 <write_head>
}
    80004212:	70a2                	ld	ra,40(sp)
    80004214:	7402                	ld	s0,32(sp)
    80004216:	64e2                	ld	s1,24(sp)
    80004218:	6942                	ld	s2,16(sp)
    8000421a:	69a2                	ld	s3,8(sp)
    8000421c:	6145                	addi	sp,sp,48
    8000421e:	8082                	ret

0000000080004220 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    80004220:	1101                	addi	sp,sp,-32
    80004222:	ec06                	sd	ra,24(sp)
    80004224:	e822                	sd	s0,16(sp)
    80004226:	e426                	sd	s1,8(sp)
    80004228:	e04a                	sd	s2,0(sp)
    8000422a:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    8000422c:	0001e517          	auipc	a0,0x1e
    80004230:	ee450513          	addi	a0,a0,-284 # 80022110 <log>
    80004234:	aeffc0ef          	jal	80000d22 <acquire>
  while(1){
    if(log.committing){
    80004238:	0001e497          	auipc	s1,0x1e
    8000423c:	ed848493          	addi	s1,s1,-296 # 80022110 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGBLOCKS){
    80004240:	4979                	li	s2,30
    80004242:	a029                	j	8000424c <begin_op+0x2c>
      sleep(&log, &log.lock);
    80004244:	85a6                	mv	a1,s1
    80004246:	8526                	mv	a0,s1
    80004248:	a24fe0ef          	jal	8000246c <sleep>
    if(log.committing){
    8000424c:	509c                	lw	a5,32(s1)
    8000424e:	fbfd                	bnez	a5,80004244 <begin_op+0x24>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGBLOCKS){
    80004250:	4cd8                	lw	a4,28(s1)
    80004252:	2705                	addiw	a4,a4,1
    80004254:	0027179b          	slliw	a5,a4,0x2
    80004258:	9fb9                	addw	a5,a5,a4
    8000425a:	0017979b          	slliw	a5,a5,0x1
    8000425e:	5494                	lw	a3,40(s1)
    80004260:	9fb5                	addw	a5,a5,a3
    80004262:	00f95763          	bge	s2,a5,80004270 <begin_op+0x50>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    80004266:	85a6                	mv	a1,s1
    80004268:	8526                	mv	a0,s1
    8000426a:	a02fe0ef          	jal	8000246c <sleep>
    8000426e:	bff9                	j	8000424c <begin_op+0x2c>
    } else {
      log.outstanding += 1;
    80004270:	0001e797          	auipc	a5,0x1e
    80004274:	eae7ae23          	sw	a4,-324(a5) # 8002212c <log+0x1c>
      release(&log.lock);
    80004278:	0001e517          	auipc	a0,0x1e
    8000427c:	e9850513          	addi	a0,a0,-360 # 80022110 <log>
    80004280:	b37fc0ef          	jal	80000db6 <release>
      break;
    }
  }
}
    80004284:	60e2                	ld	ra,24(sp)
    80004286:	6442                	ld	s0,16(sp)
    80004288:	64a2                	ld	s1,8(sp)
    8000428a:	6902                	ld	s2,0(sp)
    8000428c:	6105                	addi	sp,sp,32
    8000428e:	8082                	ret

0000000080004290 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    80004290:	7139                	addi	sp,sp,-64
    80004292:	fc06                	sd	ra,56(sp)
    80004294:	f822                	sd	s0,48(sp)
    80004296:	f426                	sd	s1,40(sp)
    80004298:	f04a                	sd	s2,32(sp)
    8000429a:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    8000429c:	0001e497          	auipc	s1,0x1e
    800042a0:	e7448493          	addi	s1,s1,-396 # 80022110 <log>
    800042a4:	8526                	mv	a0,s1
    800042a6:	a7dfc0ef          	jal	80000d22 <acquire>
  log.outstanding -= 1;
    800042aa:	4cdc                	lw	a5,28(s1)
    800042ac:	37fd                	addiw	a5,a5,-1
    800042ae:	893e                	mv	s2,a5
    800042b0:	ccdc                	sw	a5,28(s1)
  if(log.committing)
    800042b2:	509c                	lw	a5,32(s1)
    800042b4:	e7b1                	bnez	a5,80004300 <end_op+0x70>
    panic("log.committing");
  if(log.outstanding == 0){
    800042b6:	04091e63          	bnez	s2,80004312 <end_op+0x82>
    do_commit = 1;
    log.committing = 1;
    800042ba:	0001e497          	auipc	s1,0x1e
    800042be:	e5648493          	addi	s1,s1,-426 # 80022110 <log>
    800042c2:	4785                	li	a5,1
    800042c4:	d09c                	sw	a5,32(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    800042c6:	8526                	mv	a0,s1
    800042c8:	aeffc0ef          	jal	80000db6 <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    800042cc:	549c                	lw	a5,40(s1)
    800042ce:	06f04463          	bgtz	a5,80004336 <end_op+0xa6>
    acquire(&log.lock);
    800042d2:	0001e517          	auipc	a0,0x1e
    800042d6:	e3e50513          	addi	a0,a0,-450 # 80022110 <log>
    800042da:	a49fc0ef          	jal	80000d22 <acquire>
    log.committing = 0;
    800042de:	0001e797          	auipc	a5,0x1e
    800042e2:	e407a923          	sw	zero,-430(a5) # 80022130 <log+0x20>
    wakeup(&log);
    800042e6:	0001e517          	auipc	a0,0x1e
    800042ea:	e2a50513          	addi	a0,a0,-470 # 80022110 <log>
    800042ee:	9cafe0ef          	jal	800024b8 <wakeup>
    release(&log.lock);
    800042f2:	0001e517          	auipc	a0,0x1e
    800042f6:	e1e50513          	addi	a0,a0,-482 # 80022110 <log>
    800042fa:	abdfc0ef          	jal	80000db6 <release>
}
    800042fe:	a035                	j	8000432a <end_op+0x9a>
    80004300:	ec4e                	sd	s3,24(sp)
    80004302:	e852                	sd	s4,16(sp)
    80004304:	e456                	sd	s5,8(sp)
    panic("log.committing");
    80004306:	00004517          	auipc	a0,0x4
    8000430a:	23250513          	addi	a0,a0,562 # 80008538 <etext+0x538>
    8000430e:	d48fc0ef          	jal	80000856 <panic>
    wakeup(&log);
    80004312:	0001e517          	auipc	a0,0x1e
    80004316:	dfe50513          	addi	a0,a0,-514 # 80022110 <log>
    8000431a:	99efe0ef          	jal	800024b8 <wakeup>
  release(&log.lock);
    8000431e:	0001e517          	auipc	a0,0x1e
    80004322:	df250513          	addi	a0,a0,-526 # 80022110 <log>
    80004326:	a91fc0ef          	jal	80000db6 <release>
}
    8000432a:	70e2                	ld	ra,56(sp)
    8000432c:	7442                	ld	s0,48(sp)
    8000432e:	74a2                	ld	s1,40(sp)
    80004330:	7902                	ld	s2,32(sp)
    80004332:	6121                	addi	sp,sp,64
    80004334:	8082                	ret
    80004336:	ec4e                	sd	s3,24(sp)
    80004338:	e852                	sd	s4,16(sp)
    8000433a:	e456                	sd	s5,8(sp)
  for (tail = 0; tail < log.lh.n; tail++) {
    8000433c:	0001ea97          	auipc	s5,0x1e
    80004340:	e00a8a93          	addi	s5,s5,-512 # 8002213c <log+0x2c>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    80004344:	0001ea17          	auipc	s4,0x1e
    80004348:	dcca0a13          	addi	s4,s4,-564 # 80022110 <log>
    8000434c:	018a2583          	lw	a1,24(s4)
    80004350:	012585bb          	addw	a1,a1,s2
    80004354:	2585                	addiw	a1,a1,1
    80004356:	024a2503          	lw	a0,36(s4)
    8000435a:	de5fe0ef          	jal	8000313e <bread>
    8000435e:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    80004360:	000aa583          	lw	a1,0(s5)
    80004364:	024a2503          	lw	a0,36(s4)
    80004368:	dd7fe0ef          	jal	8000313e <bread>
    8000436c:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    8000436e:	40000613          	li	a2,1024
    80004372:	05850593          	addi	a1,a0,88
    80004376:	05848513          	addi	a0,s1,88
    8000437a:	ad9fc0ef          	jal	80000e52 <memmove>
    bwrite(to);  // write the log
    8000437e:	8526                	mv	a0,s1
    80004380:	ebdfe0ef          	jal	8000323c <bwrite>
    brelse(from);
    80004384:	854e                	mv	a0,s3
    80004386:	ee9fe0ef          	jal	8000326e <brelse>
    brelse(to);
    8000438a:	8526                	mv	a0,s1
    8000438c:	ee3fe0ef          	jal	8000326e <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004390:	2905                	addiw	s2,s2,1
    80004392:	0a91                	addi	s5,s5,4
    80004394:	028a2783          	lw	a5,40(s4)
    80004398:	faf94ae3          	blt	s2,a5,8000434c <end_op+0xbc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    8000439c:	cd9ff0ef          	jal	80004074 <write_head>
    install_trans(0); // Now install writes to home locations
    800043a0:	4501                	li	a0,0
    800043a2:	d31ff0ef          	jal	800040d2 <install_trans>
    log.lh.n = 0;
    800043a6:	0001e797          	auipc	a5,0x1e
    800043aa:	d807a923          	sw	zero,-622(a5) # 80022138 <log+0x28>
    write_head();    // Erase the transaction from the log
    800043ae:	cc7ff0ef          	jal	80004074 <write_head>
    800043b2:	69e2                	ld	s3,24(sp)
    800043b4:	6a42                	ld	s4,16(sp)
    800043b6:	6aa2                	ld	s5,8(sp)
    800043b8:	bf29                	j	800042d2 <end_op+0x42>

00000000800043ba <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    800043ba:	1101                	addi	sp,sp,-32
    800043bc:	ec06                	sd	ra,24(sp)
    800043be:	e822                	sd	s0,16(sp)
    800043c0:	e426                	sd	s1,8(sp)
    800043c2:	1000                	addi	s0,sp,32
    800043c4:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    800043c6:	0001e517          	auipc	a0,0x1e
    800043ca:	d4a50513          	addi	a0,a0,-694 # 80022110 <log>
    800043ce:	955fc0ef          	jal	80000d22 <acquire>
  if (log.lh.n >= LOGBLOCKS)
    800043d2:	0001e617          	auipc	a2,0x1e
    800043d6:	d6662603          	lw	a2,-666(a2) # 80022138 <log+0x28>
    800043da:	47f5                	li	a5,29
    800043dc:	04c7cd63          	blt	a5,a2,80004436 <log_write+0x7c>
    panic("too big a transaction");
  if (log.outstanding < 1)
    800043e0:	0001e797          	auipc	a5,0x1e
    800043e4:	d4c7a783          	lw	a5,-692(a5) # 8002212c <log+0x1c>
    800043e8:	04f05d63          	blez	a5,80004442 <log_write+0x88>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    800043ec:	4781                	li	a5,0
    800043ee:	06c05063          	blez	a2,8000444e <log_write+0x94>
    if (log.lh.block[i] == b->blockno)   // log absorption
    800043f2:	44cc                	lw	a1,12(s1)
    800043f4:	0001e717          	auipc	a4,0x1e
    800043f8:	d4870713          	addi	a4,a4,-696 # 8002213c <log+0x2c>
  for (i = 0; i < log.lh.n; i++) {
    800043fc:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    800043fe:	4314                	lw	a3,0(a4)
    80004400:	04b68763          	beq	a3,a1,8000444e <log_write+0x94>
  for (i = 0; i < log.lh.n; i++) {
    80004404:	2785                	addiw	a5,a5,1
    80004406:	0711                	addi	a4,a4,4
    80004408:	fef61be3          	bne	a2,a5,800043fe <log_write+0x44>
      break;
  }
  log.lh.block[i] = b->blockno;
    8000440c:	060a                	slli	a2,a2,0x2
    8000440e:	02060613          	addi	a2,a2,32
    80004412:	0001e797          	auipc	a5,0x1e
    80004416:	cfe78793          	addi	a5,a5,-770 # 80022110 <log>
    8000441a:	97b2                	add	a5,a5,a2
    8000441c:	44d8                	lw	a4,12(s1)
    8000441e:	c7d8                	sw	a4,12(a5)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    80004420:	8526                	mv	a0,s1
    80004422:	ee7fe0ef          	jal	80003308 <bpin>
    log.lh.n++;
    80004426:	0001e717          	auipc	a4,0x1e
    8000442a:	cea70713          	addi	a4,a4,-790 # 80022110 <log>
    8000442e:	571c                	lw	a5,40(a4)
    80004430:	2785                	addiw	a5,a5,1
    80004432:	d71c                	sw	a5,40(a4)
    80004434:	a815                	j	80004468 <log_write+0xae>
    panic("too big a transaction");
    80004436:	00004517          	auipc	a0,0x4
    8000443a:	11250513          	addi	a0,a0,274 # 80008548 <etext+0x548>
    8000443e:	c18fc0ef          	jal	80000856 <panic>
    panic("log_write outside of trans");
    80004442:	00004517          	auipc	a0,0x4
    80004446:	11e50513          	addi	a0,a0,286 # 80008560 <etext+0x560>
    8000444a:	c0cfc0ef          	jal	80000856 <panic>
  log.lh.block[i] = b->blockno;
    8000444e:	00279693          	slli	a3,a5,0x2
    80004452:	02068693          	addi	a3,a3,32
    80004456:	0001e717          	auipc	a4,0x1e
    8000445a:	cba70713          	addi	a4,a4,-838 # 80022110 <log>
    8000445e:	9736                	add	a4,a4,a3
    80004460:	44d4                	lw	a3,12(s1)
    80004462:	c754                	sw	a3,12(a4)
  if (i == log.lh.n) {  // Add new block to log?
    80004464:	faf60ee3          	beq	a2,a5,80004420 <log_write+0x66>
  }
  release(&log.lock);
    80004468:	0001e517          	auipc	a0,0x1e
    8000446c:	ca850513          	addi	a0,a0,-856 # 80022110 <log>
    80004470:	947fc0ef          	jal	80000db6 <release>
}
    80004474:	60e2                	ld	ra,24(sp)
    80004476:	6442                	ld	s0,16(sp)
    80004478:	64a2                	ld	s1,8(sp)
    8000447a:	6105                	addi	sp,sp,32
    8000447c:	8082                	ret

000000008000447e <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    8000447e:	1101                	addi	sp,sp,-32
    80004480:	ec06                	sd	ra,24(sp)
    80004482:	e822                	sd	s0,16(sp)
    80004484:	e426                	sd	s1,8(sp)
    80004486:	e04a                	sd	s2,0(sp)
    80004488:	1000                	addi	s0,sp,32
    8000448a:	84aa                	mv	s1,a0
    8000448c:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    8000448e:	00004597          	auipc	a1,0x4
    80004492:	0f258593          	addi	a1,a1,242 # 80008580 <etext+0x580>
    80004496:	0521                	addi	a0,a0,8
    80004498:	801fc0ef          	jal	80000c98 <initlock>
  lk->name = name;
    8000449c:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    800044a0:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    800044a4:	0204a423          	sw	zero,40(s1)
}
    800044a8:	60e2                	ld	ra,24(sp)
    800044aa:	6442                	ld	s0,16(sp)
    800044ac:	64a2                	ld	s1,8(sp)
    800044ae:	6902                	ld	s2,0(sp)
    800044b0:	6105                	addi	sp,sp,32
    800044b2:	8082                	ret

00000000800044b4 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    800044b4:	1101                	addi	sp,sp,-32
    800044b6:	ec06                	sd	ra,24(sp)
    800044b8:	e822                	sd	s0,16(sp)
    800044ba:	e426                	sd	s1,8(sp)
    800044bc:	e04a                	sd	s2,0(sp)
    800044be:	1000                	addi	s0,sp,32
    800044c0:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    800044c2:	00850913          	addi	s2,a0,8
    800044c6:	854a                	mv	a0,s2
    800044c8:	85bfc0ef          	jal	80000d22 <acquire>
  while (lk->locked) {
    800044cc:	409c                	lw	a5,0(s1)
    800044ce:	c799                	beqz	a5,800044dc <acquiresleep+0x28>
    sleep(lk, &lk->lk);
    800044d0:	85ca                	mv	a1,s2
    800044d2:	8526                	mv	a0,s1
    800044d4:	f99fd0ef          	jal	8000246c <sleep>
  while (lk->locked) {
    800044d8:	409c                	lw	a5,0(s1)
    800044da:	fbfd                	bnez	a5,800044d0 <acquiresleep+0x1c>
  }
  lk->locked = 1;
    800044dc:	4785                	li	a5,1
    800044de:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    800044e0:	f60fd0ef          	jal	80001c40 <myproc>
    800044e4:	591c                	lw	a5,48(a0)
    800044e6:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    800044e8:	854a                	mv	a0,s2
    800044ea:	8cdfc0ef          	jal	80000db6 <release>
}
    800044ee:	60e2                	ld	ra,24(sp)
    800044f0:	6442                	ld	s0,16(sp)
    800044f2:	64a2                	ld	s1,8(sp)
    800044f4:	6902                	ld	s2,0(sp)
    800044f6:	6105                	addi	sp,sp,32
    800044f8:	8082                	ret

00000000800044fa <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    800044fa:	1101                	addi	sp,sp,-32
    800044fc:	ec06                	sd	ra,24(sp)
    800044fe:	e822                	sd	s0,16(sp)
    80004500:	e426                	sd	s1,8(sp)
    80004502:	e04a                	sd	s2,0(sp)
    80004504:	1000                	addi	s0,sp,32
    80004506:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004508:	00850913          	addi	s2,a0,8
    8000450c:	854a                	mv	a0,s2
    8000450e:	815fc0ef          	jal	80000d22 <acquire>
  lk->locked = 0;
    80004512:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004516:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    8000451a:	8526                	mv	a0,s1
    8000451c:	f9dfd0ef          	jal	800024b8 <wakeup>
  release(&lk->lk);
    80004520:	854a                	mv	a0,s2
    80004522:	895fc0ef          	jal	80000db6 <release>
}
    80004526:	60e2                	ld	ra,24(sp)
    80004528:	6442                	ld	s0,16(sp)
    8000452a:	64a2                	ld	s1,8(sp)
    8000452c:	6902                	ld	s2,0(sp)
    8000452e:	6105                	addi	sp,sp,32
    80004530:	8082                	ret

0000000080004532 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    80004532:	7179                	addi	sp,sp,-48
    80004534:	f406                	sd	ra,40(sp)
    80004536:	f022                	sd	s0,32(sp)
    80004538:	ec26                	sd	s1,24(sp)
    8000453a:	e84a                	sd	s2,16(sp)
    8000453c:	1800                	addi	s0,sp,48
    8000453e:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    80004540:	00850913          	addi	s2,a0,8
    80004544:	854a                	mv	a0,s2
    80004546:	fdcfc0ef          	jal	80000d22 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    8000454a:	409c                	lw	a5,0(s1)
    8000454c:	ef81                	bnez	a5,80004564 <holdingsleep+0x32>
    8000454e:	4481                	li	s1,0
  release(&lk->lk);
    80004550:	854a                	mv	a0,s2
    80004552:	865fc0ef          	jal	80000db6 <release>
  return r;
}
    80004556:	8526                	mv	a0,s1
    80004558:	70a2                	ld	ra,40(sp)
    8000455a:	7402                	ld	s0,32(sp)
    8000455c:	64e2                	ld	s1,24(sp)
    8000455e:	6942                	ld	s2,16(sp)
    80004560:	6145                	addi	sp,sp,48
    80004562:	8082                	ret
    80004564:	e44e                	sd	s3,8(sp)
  r = lk->locked && (lk->pid == myproc()->pid);
    80004566:	0284a983          	lw	s3,40(s1)
    8000456a:	ed6fd0ef          	jal	80001c40 <myproc>
    8000456e:	5904                	lw	s1,48(a0)
    80004570:	413484b3          	sub	s1,s1,s3
    80004574:	0014b493          	seqz	s1,s1
    80004578:	69a2                	ld	s3,8(sp)
    8000457a:	bfd9                	j	80004550 <holdingsleep+0x1e>

000000008000457c <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    8000457c:	1141                	addi	sp,sp,-16
    8000457e:	e406                	sd	ra,8(sp)
    80004580:	e022                	sd	s0,0(sp)
    80004582:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    80004584:	00004597          	auipc	a1,0x4
    80004588:	00c58593          	addi	a1,a1,12 # 80008590 <etext+0x590>
    8000458c:	0001e517          	auipc	a0,0x1e
    80004590:	ccc50513          	addi	a0,a0,-820 # 80022258 <ftable>
    80004594:	f04fc0ef          	jal	80000c98 <initlock>
}
    80004598:	60a2                	ld	ra,8(sp)
    8000459a:	6402                	ld	s0,0(sp)
    8000459c:	0141                	addi	sp,sp,16
    8000459e:	8082                	ret

00000000800045a0 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    800045a0:	1101                	addi	sp,sp,-32
    800045a2:	ec06                	sd	ra,24(sp)
    800045a4:	e822                	sd	s0,16(sp)
    800045a6:	e426                	sd	s1,8(sp)
    800045a8:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    800045aa:	0001e517          	auipc	a0,0x1e
    800045ae:	cae50513          	addi	a0,a0,-850 # 80022258 <ftable>
    800045b2:	f70fc0ef          	jal	80000d22 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    800045b6:	0001e497          	auipc	s1,0x1e
    800045ba:	cba48493          	addi	s1,s1,-838 # 80022270 <ftable+0x18>
    800045be:	0001f717          	auipc	a4,0x1f
    800045c2:	c5270713          	addi	a4,a4,-942 # 80023210 <disk>
    if(f->ref == 0){
    800045c6:	40dc                	lw	a5,4(s1)
    800045c8:	cf89                	beqz	a5,800045e2 <filealloc+0x42>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    800045ca:	02848493          	addi	s1,s1,40
    800045ce:	fee49ce3          	bne	s1,a4,800045c6 <filealloc+0x26>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    800045d2:	0001e517          	auipc	a0,0x1e
    800045d6:	c8650513          	addi	a0,a0,-890 # 80022258 <ftable>
    800045da:	fdcfc0ef          	jal	80000db6 <release>
  return 0;
    800045de:	4481                	li	s1,0
    800045e0:	a809                	j	800045f2 <filealloc+0x52>
      f->ref = 1;
    800045e2:	4785                	li	a5,1
    800045e4:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    800045e6:	0001e517          	auipc	a0,0x1e
    800045ea:	c7250513          	addi	a0,a0,-910 # 80022258 <ftable>
    800045ee:	fc8fc0ef          	jal	80000db6 <release>
}
    800045f2:	8526                	mv	a0,s1
    800045f4:	60e2                	ld	ra,24(sp)
    800045f6:	6442                	ld	s0,16(sp)
    800045f8:	64a2                	ld	s1,8(sp)
    800045fa:	6105                	addi	sp,sp,32
    800045fc:	8082                	ret

00000000800045fe <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    800045fe:	1101                	addi	sp,sp,-32
    80004600:	ec06                	sd	ra,24(sp)
    80004602:	e822                	sd	s0,16(sp)
    80004604:	e426                	sd	s1,8(sp)
    80004606:	1000                	addi	s0,sp,32
    80004608:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    8000460a:	0001e517          	auipc	a0,0x1e
    8000460e:	c4e50513          	addi	a0,a0,-946 # 80022258 <ftable>
    80004612:	f10fc0ef          	jal	80000d22 <acquire>
  if(f->ref < 1)
    80004616:	40dc                	lw	a5,4(s1)
    80004618:	02f05063          	blez	a5,80004638 <filedup+0x3a>
    panic("filedup");
  f->ref++;
    8000461c:	2785                	addiw	a5,a5,1
    8000461e:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80004620:	0001e517          	auipc	a0,0x1e
    80004624:	c3850513          	addi	a0,a0,-968 # 80022258 <ftable>
    80004628:	f8efc0ef          	jal	80000db6 <release>
  return f;
}
    8000462c:	8526                	mv	a0,s1
    8000462e:	60e2                	ld	ra,24(sp)
    80004630:	6442                	ld	s0,16(sp)
    80004632:	64a2                	ld	s1,8(sp)
    80004634:	6105                	addi	sp,sp,32
    80004636:	8082                	ret
    panic("filedup");
    80004638:	00004517          	auipc	a0,0x4
    8000463c:	f6050513          	addi	a0,a0,-160 # 80008598 <etext+0x598>
    80004640:	a16fc0ef          	jal	80000856 <panic>

0000000080004644 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    80004644:	7139                	addi	sp,sp,-64
    80004646:	fc06                	sd	ra,56(sp)
    80004648:	f822                	sd	s0,48(sp)
    8000464a:	f426                	sd	s1,40(sp)
    8000464c:	0080                	addi	s0,sp,64
    8000464e:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    80004650:	0001e517          	auipc	a0,0x1e
    80004654:	c0850513          	addi	a0,a0,-1016 # 80022258 <ftable>
    80004658:	ecafc0ef          	jal	80000d22 <acquire>
  if(f->ref < 1)
    8000465c:	40dc                	lw	a5,4(s1)
    8000465e:	04f05a63          	blez	a5,800046b2 <fileclose+0x6e>
    panic("fileclose");
  if(--f->ref > 0){
    80004662:	37fd                	addiw	a5,a5,-1
    80004664:	c0dc                	sw	a5,4(s1)
    80004666:	06f04063          	bgtz	a5,800046c6 <fileclose+0x82>
    8000466a:	f04a                	sd	s2,32(sp)
    8000466c:	ec4e                	sd	s3,24(sp)
    8000466e:	e852                	sd	s4,16(sp)
    80004670:	e456                	sd	s5,8(sp)
    release(&ftable.lock);
    return;
  }
  ff = *f;
    80004672:	0004a903          	lw	s2,0(s1)
    80004676:	0094c783          	lbu	a5,9(s1)
    8000467a:	89be                	mv	s3,a5
    8000467c:	689c                	ld	a5,16(s1)
    8000467e:	8a3e                	mv	s4,a5
    80004680:	6c9c                	ld	a5,24(s1)
    80004682:	8abe                	mv	s5,a5
  f->ref = 0;
    80004684:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    80004688:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    8000468c:	0001e517          	auipc	a0,0x1e
    80004690:	bcc50513          	addi	a0,a0,-1076 # 80022258 <ftable>
    80004694:	f22fc0ef          	jal	80000db6 <release>

  if(ff.type == FD_PIPE){
    80004698:	4785                	li	a5,1
    8000469a:	04f90163          	beq	s2,a5,800046dc <fileclose+0x98>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    8000469e:	ffe9079b          	addiw	a5,s2,-2
    800046a2:	4705                	li	a4,1
    800046a4:	04f77563          	bgeu	a4,a5,800046ee <fileclose+0xaa>
    800046a8:	7902                	ld	s2,32(sp)
    800046aa:	69e2                	ld	s3,24(sp)
    800046ac:	6a42                	ld	s4,16(sp)
    800046ae:	6aa2                	ld	s5,8(sp)
    800046b0:	a00d                	j	800046d2 <fileclose+0x8e>
    800046b2:	f04a                	sd	s2,32(sp)
    800046b4:	ec4e                	sd	s3,24(sp)
    800046b6:	e852                	sd	s4,16(sp)
    800046b8:	e456                	sd	s5,8(sp)
    panic("fileclose");
    800046ba:	00004517          	auipc	a0,0x4
    800046be:	ee650513          	addi	a0,a0,-282 # 800085a0 <etext+0x5a0>
    800046c2:	994fc0ef          	jal	80000856 <panic>
    release(&ftable.lock);
    800046c6:	0001e517          	auipc	a0,0x1e
    800046ca:	b9250513          	addi	a0,a0,-1134 # 80022258 <ftable>
    800046ce:	ee8fc0ef          	jal	80000db6 <release>
    begin_op();
    iput(ff.ip);
    end_op();
  }
}
    800046d2:	70e2                	ld	ra,56(sp)
    800046d4:	7442                	ld	s0,48(sp)
    800046d6:	74a2                	ld	s1,40(sp)
    800046d8:	6121                	addi	sp,sp,64
    800046da:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    800046dc:	85ce                	mv	a1,s3
    800046de:	8552                	mv	a0,s4
    800046e0:	348000ef          	jal	80004a28 <pipeclose>
    800046e4:	7902                	ld	s2,32(sp)
    800046e6:	69e2                	ld	s3,24(sp)
    800046e8:	6a42                	ld	s4,16(sp)
    800046ea:	6aa2                	ld	s5,8(sp)
    800046ec:	b7dd                	j	800046d2 <fileclose+0x8e>
    begin_op();
    800046ee:	b33ff0ef          	jal	80004220 <begin_op>
    iput(ff.ip);
    800046f2:	8556                	mv	a0,s5
    800046f4:	aa2ff0ef          	jal	80003996 <iput>
    end_op();
    800046f8:	b99ff0ef          	jal	80004290 <end_op>
    800046fc:	7902                	ld	s2,32(sp)
    800046fe:	69e2                	ld	s3,24(sp)
    80004700:	6a42                	ld	s4,16(sp)
    80004702:	6aa2                	ld	s5,8(sp)
    80004704:	b7f9                	j	800046d2 <fileclose+0x8e>

0000000080004706 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    80004706:	715d                	addi	sp,sp,-80
    80004708:	e486                	sd	ra,72(sp)
    8000470a:	e0a2                	sd	s0,64(sp)
    8000470c:	fc26                	sd	s1,56(sp)
    8000470e:	f052                	sd	s4,32(sp)
    80004710:	0880                	addi	s0,sp,80
    80004712:	84aa                	mv	s1,a0
    80004714:	8a2e                	mv	s4,a1
  struct proc *p = myproc();
    80004716:	d2afd0ef          	jal	80001c40 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    8000471a:	409c                	lw	a5,0(s1)
    8000471c:	37f9                	addiw	a5,a5,-2
    8000471e:	4705                	li	a4,1
    80004720:	04f76263          	bltu	a4,a5,80004764 <filestat+0x5e>
    80004724:	f84a                	sd	s2,48(sp)
    80004726:	f44e                	sd	s3,40(sp)
    80004728:	89aa                	mv	s3,a0
    ilock(f->ip);
    8000472a:	6c88                	ld	a0,24(s1)
    8000472c:	8e8ff0ef          	jal	80003814 <ilock>
    stati(f->ip, &st);
    80004730:	fb840913          	addi	s2,s0,-72
    80004734:	85ca                	mv	a1,s2
    80004736:	6c88                	ld	a0,24(s1)
    80004738:	c40ff0ef          	jal	80003b78 <stati>
    iunlock(f->ip);
    8000473c:	6c88                	ld	a0,24(s1)
    8000473e:	984ff0ef          	jal	800038c2 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    80004742:	46e1                	li	a3,24
    80004744:	864a                	mv	a2,s2
    80004746:	85d2                	mv	a1,s4
    80004748:	0509b503          	ld	a0,80(s3)
    8000474c:	a06fd0ef          	jal	80001952 <copyout>
    80004750:	41f5551b          	sraiw	a0,a0,0x1f
    80004754:	7942                	ld	s2,48(sp)
    80004756:	79a2                	ld	s3,40(sp)
      return -1;
    return 0;
  }
  return -1;
}
    80004758:	60a6                	ld	ra,72(sp)
    8000475a:	6406                	ld	s0,64(sp)
    8000475c:	74e2                	ld	s1,56(sp)
    8000475e:	7a02                	ld	s4,32(sp)
    80004760:	6161                	addi	sp,sp,80
    80004762:	8082                	ret
  return -1;
    80004764:	557d                	li	a0,-1
    80004766:	bfcd                	j	80004758 <filestat+0x52>

0000000080004768 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    80004768:	7179                	addi	sp,sp,-48
    8000476a:	f406                	sd	ra,40(sp)
    8000476c:	f022                	sd	s0,32(sp)
    8000476e:	e84a                	sd	s2,16(sp)
    80004770:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    80004772:	00854783          	lbu	a5,8(a0)
    80004776:	cfd1                	beqz	a5,80004812 <fileread+0xaa>
    80004778:	ec26                	sd	s1,24(sp)
    8000477a:	e44e                	sd	s3,8(sp)
    8000477c:	84aa                	mv	s1,a0
    8000477e:	892e                	mv	s2,a1
    80004780:	89b2                	mv	s3,a2
    return -1;

  if(f->type == FD_PIPE){
    80004782:	411c                	lw	a5,0(a0)
    80004784:	4705                	li	a4,1
    80004786:	04e78363          	beq	a5,a4,800047cc <fileread+0x64>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    8000478a:	470d                	li	a4,3
    8000478c:	04e78763          	beq	a5,a4,800047da <fileread+0x72>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    80004790:	4709                	li	a4,2
    80004792:	06e79a63          	bne	a5,a4,80004806 <fileread+0x9e>
    ilock(f->ip);
    80004796:	6d08                	ld	a0,24(a0)
    80004798:	87cff0ef          	jal	80003814 <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    8000479c:	874e                	mv	a4,s3
    8000479e:	5094                	lw	a3,32(s1)
    800047a0:	864a                	mv	a2,s2
    800047a2:	4585                	li	a1,1
    800047a4:	6c88                	ld	a0,24(s1)
    800047a6:	c00ff0ef          	jal	80003ba6 <readi>
    800047aa:	892a                	mv	s2,a0
    800047ac:	00a05563          	blez	a0,800047b6 <fileread+0x4e>
      f->off += r;
    800047b0:	509c                	lw	a5,32(s1)
    800047b2:	9fa9                	addw	a5,a5,a0
    800047b4:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    800047b6:	6c88                	ld	a0,24(s1)
    800047b8:	90aff0ef          	jal	800038c2 <iunlock>
    800047bc:	64e2                	ld	s1,24(sp)
    800047be:	69a2                	ld	s3,8(sp)
  } else {
    panic("fileread");
  }

  return r;
}
    800047c0:	854a                	mv	a0,s2
    800047c2:	70a2                	ld	ra,40(sp)
    800047c4:	7402                	ld	s0,32(sp)
    800047c6:	6942                	ld	s2,16(sp)
    800047c8:	6145                	addi	sp,sp,48
    800047ca:	8082                	ret
    r = piperead(f->pipe, addr, n);
    800047cc:	6908                	ld	a0,16(a0)
    800047ce:	3b0000ef          	jal	80004b7e <piperead>
    800047d2:	892a                	mv	s2,a0
    800047d4:	64e2                	ld	s1,24(sp)
    800047d6:	69a2                	ld	s3,8(sp)
    800047d8:	b7e5                	j	800047c0 <fileread+0x58>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    800047da:	02451783          	lh	a5,36(a0)
    800047de:	03079693          	slli	a3,a5,0x30
    800047e2:	92c1                	srli	a3,a3,0x30
    800047e4:	4725                	li	a4,9
    800047e6:	02d76963          	bltu	a4,a3,80004818 <fileread+0xb0>
    800047ea:	0792                	slli	a5,a5,0x4
    800047ec:	0001e717          	auipc	a4,0x1e
    800047f0:	9cc70713          	addi	a4,a4,-1588 # 800221b8 <devsw>
    800047f4:	97ba                	add	a5,a5,a4
    800047f6:	639c                	ld	a5,0(a5)
    800047f8:	c78d                	beqz	a5,80004822 <fileread+0xba>
    r = devsw[f->major].read(1, addr, n);
    800047fa:	4505                	li	a0,1
    800047fc:	9782                	jalr	a5
    800047fe:	892a                	mv	s2,a0
    80004800:	64e2                	ld	s1,24(sp)
    80004802:	69a2                	ld	s3,8(sp)
    80004804:	bf75                	j	800047c0 <fileread+0x58>
    panic("fileread");
    80004806:	00004517          	auipc	a0,0x4
    8000480a:	daa50513          	addi	a0,a0,-598 # 800085b0 <etext+0x5b0>
    8000480e:	848fc0ef          	jal	80000856 <panic>
    return -1;
    80004812:	57fd                	li	a5,-1
    80004814:	893e                	mv	s2,a5
    80004816:	b76d                	j	800047c0 <fileread+0x58>
      return -1;
    80004818:	57fd                	li	a5,-1
    8000481a:	893e                	mv	s2,a5
    8000481c:	64e2                	ld	s1,24(sp)
    8000481e:	69a2                	ld	s3,8(sp)
    80004820:	b745                	j	800047c0 <fileread+0x58>
    80004822:	57fd                	li	a5,-1
    80004824:	893e                	mv	s2,a5
    80004826:	64e2                	ld	s1,24(sp)
    80004828:	69a2                	ld	s3,8(sp)
    8000482a:	bf59                	j	800047c0 <fileread+0x58>

000000008000482c <filewrite>:
int
filewrite(struct file *f, uint64 addr, int n)
{
  int r, ret = 0;

  if(f->writable == 0)
    8000482c:	00954783          	lbu	a5,9(a0)
    80004830:	10078f63          	beqz	a5,8000494e <filewrite+0x122>
{
    80004834:	711d                	addi	sp,sp,-96
    80004836:	ec86                	sd	ra,88(sp)
    80004838:	e8a2                	sd	s0,80(sp)
    8000483a:	e0ca                	sd	s2,64(sp)
    8000483c:	f456                	sd	s5,40(sp)
    8000483e:	f05a                	sd	s6,32(sp)
    80004840:	1080                	addi	s0,sp,96
    80004842:	892a                	mv	s2,a0
    80004844:	8b2e                	mv	s6,a1
    80004846:	8ab2                	mv	s5,a2
    return -1;

  if(f->type == FD_PIPE){
    80004848:	411c                	lw	a5,0(a0)
    8000484a:	4705                	li	a4,1
    8000484c:	02e78a63          	beq	a5,a4,80004880 <filewrite+0x54>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004850:	470d                	li	a4,3
    80004852:	02e78b63          	beq	a5,a4,80004888 <filewrite+0x5c>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    80004856:	4709                	li	a4,2
    80004858:	0ce79f63          	bne	a5,a4,80004936 <filewrite+0x10a>
    8000485c:	f852                	sd	s4,48(sp)
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    8000485e:	0ac05a63          	blez	a2,80004912 <filewrite+0xe6>
    80004862:	e4a6                	sd	s1,72(sp)
    80004864:	fc4e                	sd	s3,56(sp)
    80004866:	ec5e                	sd	s7,24(sp)
    80004868:	e862                	sd	s8,16(sp)
    8000486a:	e466                	sd	s9,8(sp)
    int i = 0;
    8000486c:	4a01                	li	s4,0
      int n1 = n - i;
      if(n1 > max)
    8000486e:	6b85                	lui	s7,0x1
    80004870:	c00b8b93          	addi	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    80004874:	6785                	lui	a5,0x1
    80004876:	c007879b          	addiw	a5,a5,-1024 # c00 <_entry-0x7ffff400>
    8000487a:	8cbe                	mv	s9,a5
        n1 = max;

      begin_op();
      ilock(f->ip);
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    8000487c:	4c05                	li	s8,1
    8000487e:	a8ad                	j	800048f8 <filewrite+0xcc>
    ret = pipewrite(f->pipe, addr, n);
    80004880:	6908                	ld	a0,16(a0)
    80004882:	204000ef          	jal	80004a86 <pipewrite>
    80004886:	a04d                	j	80004928 <filewrite+0xfc>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80004888:	02451783          	lh	a5,36(a0)
    8000488c:	03079693          	slli	a3,a5,0x30
    80004890:	92c1                	srli	a3,a3,0x30
    80004892:	4725                	li	a4,9
    80004894:	0ad76f63          	bltu	a4,a3,80004952 <filewrite+0x126>
    80004898:	0792                	slli	a5,a5,0x4
    8000489a:	0001e717          	auipc	a4,0x1e
    8000489e:	91e70713          	addi	a4,a4,-1762 # 800221b8 <devsw>
    800048a2:	97ba                	add	a5,a5,a4
    800048a4:	679c                	ld	a5,8(a5)
    800048a6:	cbc5                	beqz	a5,80004956 <filewrite+0x12a>
    ret = devsw[f->major].write(1, addr, n);
    800048a8:	4505                	li	a0,1
    800048aa:	9782                	jalr	a5
    800048ac:	a8b5                	j	80004928 <filewrite+0xfc>
      if(n1 > max)
    800048ae:	2981                	sext.w	s3,s3
      begin_op();
    800048b0:	971ff0ef          	jal	80004220 <begin_op>
      ilock(f->ip);
    800048b4:	01893503          	ld	a0,24(s2)
    800048b8:	f5dfe0ef          	jal	80003814 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    800048bc:	874e                	mv	a4,s3
    800048be:	02092683          	lw	a3,32(s2)
    800048c2:	016a0633          	add	a2,s4,s6
    800048c6:	85e2                	mv	a1,s8
    800048c8:	01893503          	ld	a0,24(s2)
    800048cc:	bccff0ef          	jal	80003c98 <writei>
    800048d0:	84aa                	mv	s1,a0
    800048d2:	00a05763          	blez	a0,800048e0 <filewrite+0xb4>
        f->off += r;
    800048d6:	02092783          	lw	a5,32(s2)
    800048da:	9fa9                	addw	a5,a5,a0
    800048dc:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    800048e0:	01893503          	ld	a0,24(s2)
    800048e4:	fdffe0ef          	jal	800038c2 <iunlock>
      end_op();
    800048e8:	9a9ff0ef          	jal	80004290 <end_op>

      if(r != n1){
    800048ec:	02999563          	bne	s3,s1,80004916 <filewrite+0xea>
        // error from writei
        break;
      }
      i += r;
    800048f0:	01448a3b          	addw	s4,s1,s4
    while(i < n){
    800048f4:	015a5963          	bge	s4,s5,80004906 <filewrite+0xda>
      int n1 = n - i;
    800048f8:	414a87bb          	subw	a5,s5,s4
    800048fc:	89be                	mv	s3,a5
      if(n1 > max)
    800048fe:	fafbd8e3          	bge	s7,a5,800048ae <filewrite+0x82>
    80004902:	89e6                	mv	s3,s9
    80004904:	b76d                	j	800048ae <filewrite+0x82>
    80004906:	64a6                	ld	s1,72(sp)
    80004908:	79e2                	ld	s3,56(sp)
    8000490a:	6be2                	ld	s7,24(sp)
    8000490c:	6c42                	ld	s8,16(sp)
    8000490e:	6ca2                	ld	s9,8(sp)
    80004910:	a801                	j	80004920 <filewrite+0xf4>
    int i = 0;
    80004912:	4a01                	li	s4,0
    80004914:	a031                	j	80004920 <filewrite+0xf4>
    80004916:	64a6                	ld	s1,72(sp)
    80004918:	79e2                	ld	s3,56(sp)
    8000491a:	6be2                	ld	s7,24(sp)
    8000491c:	6c42                	ld	s8,16(sp)
    8000491e:	6ca2                	ld	s9,8(sp)
    }
    ret = (i == n ? n : -1);
    80004920:	034a9d63          	bne	s5,s4,8000495a <filewrite+0x12e>
    80004924:	8556                	mv	a0,s5
    80004926:	7a42                	ld	s4,48(sp)
  } else {
    panic("filewrite");
  }

  return ret;
}
    80004928:	60e6                	ld	ra,88(sp)
    8000492a:	6446                	ld	s0,80(sp)
    8000492c:	6906                	ld	s2,64(sp)
    8000492e:	7aa2                	ld	s5,40(sp)
    80004930:	7b02                	ld	s6,32(sp)
    80004932:	6125                	addi	sp,sp,96
    80004934:	8082                	ret
    80004936:	e4a6                	sd	s1,72(sp)
    80004938:	fc4e                	sd	s3,56(sp)
    8000493a:	f852                	sd	s4,48(sp)
    8000493c:	ec5e                	sd	s7,24(sp)
    8000493e:	e862                	sd	s8,16(sp)
    80004940:	e466                	sd	s9,8(sp)
    panic("filewrite");
    80004942:	00004517          	auipc	a0,0x4
    80004946:	c7e50513          	addi	a0,a0,-898 # 800085c0 <etext+0x5c0>
    8000494a:	f0dfb0ef          	jal	80000856 <panic>
    return -1;
    8000494e:	557d                	li	a0,-1
}
    80004950:	8082                	ret
      return -1;
    80004952:	557d                	li	a0,-1
    80004954:	bfd1                	j	80004928 <filewrite+0xfc>
    80004956:	557d                	li	a0,-1
    80004958:	bfc1                	j	80004928 <filewrite+0xfc>
    ret = (i == n ? n : -1);
    8000495a:	557d                	li	a0,-1
    8000495c:	7a42                	ld	s4,48(sp)
    8000495e:	b7e9                	j	80004928 <filewrite+0xfc>

0000000080004960 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80004960:	7179                	addi	sp,sp,-48
    80004962:	f406                	sd	ra,40(sp)
    80004964:	f022                	sd	s0,32(sp)
    80004966:	ec26                	sd	s1,24(sp)
    80004968:	e052                	sd	s4,0(sp)
    8000496a:	1800                	addi	s0,sp,48
    8000496c:	84aa                	mv	s1,a0
    8000496e:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80004970:	0005b023          	sd	zero,0(a1)
    80004974:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80004978:	c29ff0ef          	jal	800045a0 <filealloc>
    8000497c:	e088                	sd	a0,0(s1)
    8000497e:	c549                	beqz	a0,80004a08 <pipealloc+0xa8>
    80004980:	c21ff0ef          	jal	800045a0 <filealloc>
    80004984:	00aa3023          	sd	a0,0(s4)
    80004988:	cd25                	beqz	a0,80004a00 <pipealloc+0xa0>
    8000498a:	e84a                	sd	s2,16(sp)
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    8000498c:	a4efc0ef          	jal	80000bda <kalloc>
    80004990:	892a                	mv	s2,a0
    80004992:	c12d                	beqz	a0,800049f4 <pipealloc+0x94>
    80004994:	e44e                	sd	s3,8(sp)
    goto bad;
  pi->readopen = 1;
    80004996:	4985                	li	s3,1
    80004998:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    8000499c:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    800049a0:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    800049a4:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    800049a8:	00004597          	auipc	a1,0x4
    800049ac:	c2858593          	addi	a1,a1,-984 # 800085d0 <etext+0x5d0>
    800049b0:	ae8fc0ef          	jal	80000c98 <initlock>
  (*f0)->type = FD_PIPE;
    800049b4:	609c                	ld	a5,0(s1)
    800049b6:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    800049ba:	609c                	ld	a5,0(s1)
    800049bc:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    800049c0:	609c                	ld	a5,0(s1)
    800049c2:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    800049c6:	609c                	ld	a5,0(s1)
    800049c8:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    800049cc:	000a3783          	ld	a5,0(s4)
    800049d0:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    800049d4:	000a3783          	ld	a5,0(s4)
    800049d8:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    800049dc:	000a3783          	ld	a5,0(s4)
    800049e0:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    800049e4:	000a3783          	ld	a5,0(s4)
    800049e8:	0127b823          	sd	s2,16(a5)
  return 0;
    800049ec:	4501                	li	a0,0
    800049ee:	6942                	ld	s2,16(sp)
    800049f0:	69a2                	ld	s3,8(sp)
    800049f2:	a01d                	j	80004a18 <pipealloc+0xb8>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    800049f4:	6088                	ld	a0,0(s1)
    800049f6:	c119                	beqz	a0,800049fc <pipealloc+0x9c>
    800049f8:	6942                	ld	s2,16(sp)
    800049fa:	a029                	j	80004a04 <pipealloc+0xa4>
    800049fc:	6942                	ld	s2,16(sp)
    800049fe:	a029                	j	80004a08 <pipealloc+0xa8>
    80004a00:	6088                	ld	a0,0(s1)
    80004a02:	c10d                	beqz	a0,80004a24 <pipealloc+0xc4>
    fileclose(*f0);
    80004a04:	c41ff0ef          	jal	80004644 <fileclose>
  if(*f1)
    80004a08:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80004a0c:	557d                	li	a0,-1
  if(*f1)
    80004a0e:	c789                	beqz	a5,80004a18 <pipealloc+0xb8>
    fileclose(*f1);
    80004a10:	853e                	mv	a0,a5
    80004a12:	c33ff0ef          	jal	80004644 <fileclose>
  return -1;
    80004a16:	557d                	li	a0,-1
}
    80004a18:	70a2                	ld	ra,40(sp)
    80004a1a:	7402                	ld	s0,32(sp)
    80004a1c:	64e2                	ld	s1,24(sp)
    80004a1e:	6a02                	ld	s4,0(sp)
    80004a20:	6145                	addi	sp,sp,48
    80004a22:	8082                	ret
  return -1;
    80004a24:	557d                	li	a0,-1
    80004a26:	bfcd                	j	80004a18 <pipealloc+0xb8>

0000000080004a28 <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80004a28:	1101                	addi	sp,sp,-32
    80004a2a:	ec06                	sd	ra,24(sp)
    80004a2c:	e822                	sd	s0,16(sp)
    80004a2e:	e426                	sd	s1,8(sp)
    80004a30:	e04a                	sd	s2,0(sp)
    80004a32:	1000                	addi	s0,sp,32
    80004a34:	84aa                	mv	s1,a0
    80004a36:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80004a38:	aeafc0ef          	jal	80000d22 <acquire>
  if(writable){
    80004a3c:	02090763          	beqz	s2,80004a6a <pipeclose+0x42>
    pi->writeopen = 0;
    80004a40:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80004a44:	21848513          	addi	a0,s1,536
    80004a48:	a71fd0ef          	jal	800024b8 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80004a4c:	2204a783          	lw	a5,544(s1)
    80004a50:	e781                	bnez	a5,80004a58 <pipeclose+0x30>
    80004a52:	2244a783          	lw	a5,548(s1)
    80004a56:	c38d                	beqz	a5,80004a78 <pipeclose+0x50>
    release(&pi->lock);
    kfree((char*)pi);
  } else
    release(&pi->lock);
    80004a58:	8526                	mv	a0,s1
    80004a5a:	b5cfc0ef          	jal	80000db6 <release>
}
    80004a5e:	60e2                	ld	ra,24(sp)
    80004a60:	6442                	ld	s0,16(sp)
    80004a62:	64a2                	ld	s1,8(sp)
    80004a64:	6902                	ld	s2,0(sp)
    80004a66:	6105                	addi	sp,sp,32
    80004a68:	8082                	ret
    pi->readopen = 0;
    80004a6a:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80004a6e:	21c48513          	addi	a0,s1,540
    80004a72:	a47fd0ef          	jal	800024b8 <wakeup>
    80004a76:	bfd9                	j	80004a4c <pipeclose+0x24>
    release(&pi->lock);
    80004a78:	8526                	mv	a0,s1
    80004a7a:	b3cfc0ef          	jal	80000db6 <release>
    kfree((char*)pi);
    80004a7e:	8526                	mv	a0,s1
    80004a80:	80efc0ef          	jal	80000a8e <kfree>
    80004a84:	bfe9                	j	80004a5e <pipeclose+0x36>

0000000080004a86 <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80004a86:	7159                	addi	sp,sp,-112
    80004a88:	f486                	sd	ra,104(sp)
    80004a8a:	f0a2                	sd	s0,96(sp)
    80004a8c:	eca6                	sd	s1,88(sp)
    80004a8e:	e8ca                	sd	s2,80(sp)
    80004a90:	e4ce                	sd	s3,72(sp)
    80004a92:	e0d2                	sd	s4,64(sp)
    80004a94:	fc56                	sd	s5,56(sp)
    80004a96:	1880                	addi	s0,sp,112
    80004a98:	84aa                	mv	s1,a0
    80004a9a:	8aae                	mv	s5,a1
    80004a9c:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    80004a9e:	9a2fd0ef          	jal	80001c40 <myproc>
    80004aa2:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    80004aa4:	8526                	mv	a0,s1
    80004aa6:	a7cfc0ef          	jal	80000d22 <acquire>
  while(i < n){
    80004aaa:	0d405263          	blez	s4,80004b6e <pipewrite+0xe8>
    80004aae:	f85a                	sd	s6,48(sp)
    80004ab0:	f45e                	sd	s7,40(sp)
    80004ab2:	f062                	sd	s8,32(sp)
    80004ab4:	ec66                	sd	s9,24(sp)
    80004ab6:	e86a                	sd	s10,16(sp)
  int i = 0;
    80004ab8:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004aba:	f9f40c13          	addi	s8,s0,-97
    80004abe:	4b85                	li	s7,1
    80004ac0:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    80004ac2:	21848d13          	addi	s10,s1,536
      sleep(&pi->nwrite, &pi->lock);
    80004ac6:	21c48c93          	addi	s9,s1,540
    80004aca:	a82d                	j	80004b04 <pipewrite+0x7e>
      release(&pi->lock);
    80004acc:	8526                	mv	a0,s1
    80004ace:	ae8fc0ef          	jal	80000db6 <release>
      return -1;
    80004ad2:	597d                	li	s2,-1
    80004ad4:	7b42                	ld	s6,48(sp)
    80004ad6:	7ba2                	ld	s7,40(sp)
    80004ad8:	7c02                	ld	s8,32(sp)
    80004ada:	6ce2                	ld	s9,24(sp)
    80004adc:	6d42                	ld	s10,16(sp)
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    80004ade:	854a                	mv	a0,s2
    80004ae0:	70a6                	ld	ra,104(sp)
    80004ae2:	7406                	ld	s0,96(sp)
    80004ae4:	64e6                	ld	s1,88(sp)
    80004ae6:	6946                	ld	s2,80(sp)
    80004ae8:	69a6                	ld	s3,72(sp)
    80004aea:	6a06                	ld	s4,64(sp)
    80004aec:	7ae2                	ld	s5,56(sp)
    80004aee:	6165                	addi	sp,sp,112
    80004af0:	8082                	ret
      wakeup(&pi->nread);
    80004af2:	856a                	mv	a0,s10
    80004af4:	9c5fd0ef          	jal	800024b8 <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80004af8:	85a6                	mv	a1,s1
    80004afa:	8566                	mv	a0,s9
    80004afc:	971fd0ef          	jal	8000246c <sleep>
  while(i < n){
    80004b00:	05495a63          	bge	s2,s4,80004b54 <pipewrite+0xce>
    if(pi->readopen == 0 || killed(pr)){
    80004b04:	2204a783          	lw	a5,544(s1)
    80004b08:	d3f1                	beqz	a5,80004acc <pipewrite+0x46>
    80004b0a:	854e                	mv	a0,s3
    80004b0c:	b9dfd0ef          	jal	800026a8 <killed>
    80004b10:	fd55                	bnez	a0,80004acc <pipewrite+0x46>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    80004b12:	2184a783          	lw	a5,536(s1)
    80004b16:	21c4a703          	lw	a4,540(s1)
    80004b1a:	2007879b          	addiw	a5,a5,512
    80004b1e:	fcf70ae3          	beq	a4,a5,80004af2 <pipewrite+0x6c>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004b22:	86de                	mv	a3,s7
    80004b24:	01590633          	add	a2,s2,s5
    80004b28:	85e2                	mv	a1,s8
    80004b2a:	0509b503          	ld	a0,80(s3)
    80004b2e:	ee3fc0ef          	jal	80001a10 <copyin>
    80004b32:	05650063          	beq	a0,s6,80004b72 <pipewrite+0xec>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80004b36:	21c4a783          	lw	a5,540(s1)
    80004b3a:	0017871b          	addiw	a4,a5,1
    80004b3e:	20e4ae23          	sw	a4,540(s1)
    80004b42:	1ff7f793          	andi	a5,a5,511
    80004b46:	97a6                	add	a5,a5,s1
    80004b48:	f9f44703          	lbu	a4,-97(s0)
    80004b4c:	00e78c23          	sb	a4,24(a5)
      i++;
    80004b50:	2905                	addiw	s2,s2,1
    80004b52:	b77d                	j	80004b00 <pipewrite+0x7a>
    80004b54:	7b42                	ld	s6,48(sp)
    80004b56:	7ba2                	ld	s7,40(sp)
    80004b58:	7c02                	ld	s8,32(sp)
    80004b5a:	6ce2                	ld	s9,24(sp)
    80004b5c:	6d42                	ld	s10,16(sp)
  wakeup(&pi->nread);
    80004b5e:	21848513          	addi	a0,s1,536
    80004b62:	957fd0ef          	jal	800024b8 <wakeup>
  release(&pi->lock);
    80004b66:	8526                	mv	a0,s1
    80004b68:	a4efc0ef          	jal	80000db6 <release>
  return i;
    80004b6c:	bf8d                	j	80004ade <pipewrite+0x58>
  int i = 0;
    80004b6e:	4901                	li	s2,0
    80004b70:	b7fd                	j	80004b5e <pipewrite+0xd8>
    80004b72:	7b42                	ld	s6,48(sp)
    80004b74:	7ba2                	ld	s7,40(sp)
    80004b76:	7c02                	ld	s8,32(sp)
    80004b78:	6ce2                	ld	s9,24(sp)
    80004b7a:	6d42                	ld	s10,16(sp)
    80004b7c:	b7cd                	j	80004b5e <pipewrite+0xd8>

0000000080004b7e <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80004b7e:	711d                	addi	sp,sp,-96
    80004b80:	ec86                	sd	ra,88(sp)
    80004b82:	e8a2                	sd	s0,80(sp)
    80004b84:	e4a6                	sd	s1,72(sp)
    80004b86:	e0ca                	sd	s2,64(sp)
    80004b88:	fc4e                	sd	s3,56(sp)
    80004b8a:	f852                	sd	s4,48(sp)
    80004b8c:	f456                	sd	s5,40(sp)
    80004b8e:	1080                	addi	s0,sp,96
    80004b90:	84aa                	mv	s1,a0
    80004b92:	892e                	mv	s2,a1
    80004b94:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80004b96:	8aafd0ef          	jal	80001c40 <myproc>
    80004b9a:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80004b9c:	8526                	mv	a0,s1
    80004b9e:	984fc0ef          	jal	80000d22 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004ba2:	2184a703          	lw	a4,536(s1)
    80004ba6:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004baa:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004bae:	02f71763          	bne	a4,a5,80004bdc <piperead+0x5e>
    80004bb2:	2244a783          	lw	a5,548(s1)
    80004bb6:	cf85                	beqz	a5,80004bee <piperead+0x70>
    if(killed(pr)){
    80004bb8:	8552                	mv	a0,s4
    80004bba:	aeffd0ef          	jal	800026a8 <killed>
    80004bbe:	e11d                	bnez	a0,80004be4 <piperead+0x66>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004bc0:	85a6                	mv	a1,s1
    80004bc2:	854e                	mv	a0,s3
    80004bc4:	8a9fd0ef          	jal	8000246c <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004bc8:	2184a703          	lw	a4,536(s1)
    80004bcc:	21c4a783          	lw	a5,540(s1)
    80004bd0:	fef701e3          	beq	a4,a5,80004bb2 <piperead+0x34>
    80004bd4:	f05a                	sd	s6,32(sp)
    80004bd6:	ec5e                	sd	s7,24(sp)
    80004bd8:	e862                	sd	s8,16(sp)
    80004bda:	a829                	j	80004bf4 <piperead+0x76>
    80004bdc:	f05a                	sd	s6,32(sp)
    80004bde:	ec5e                	sd	s7,24(sp)
    80004be0:	e862                	sd	s8,16(sp)
    80004be2:	a809                	j	80004bf4 <piperead+0x76>
      release(&pi->lock);
    80004be4:	8526                	mv	a0,s1
    80004be6:	9d0fc0ef          	jal	80000db6 <release>
      return -1;
    80004bea:	59fd                	li	s3,-1
    80004bec:	a0a5                	j	80004c54 <piperead+0xd6>
    80004bee:	f05a                	sd	s6,32(sp)
    80004bf0:	ec5e                	sd	s7,24(sp)
    80004bf2:	e862                	sd	s8,16(sp)
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004bf4:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1) {
    80004bf6:	faf40c13          	addi	s8,s0,-81
    80004bfa:	4b85                	li	s7,1
    80004bfc:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004bfe:	05505163          	blez	s5,80004c40 <piperead+0xc2>
    if(pi->nread == pi->nwrite)
    80004c02:	2184a783          	lw	a5,536(s1)
    80004c06:	21c4a703          	lw	a4,540(s1)
    80004c0a:	02f70b63          	beq	a4,a5,80004c40 <piperead+0xc2>
    ch = pi->data[pi->nread % PIPESIZE];
    80004c0e:	1ff7f793          	andi	a5,a5,511
    80004c12:	97a6                	add	a5,a5,s1
    80004c14:	0187c783          	lbu	a5,24(a5)
    80004c18:	faf407a3          	sb	a5,-81(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1) {
    80004c1c:	86de                	mv	a3,s7
    80004c1e:	8662                	mv	a2,s8
    80004c20:	85ca                	mv	a1,s2
    80004c22:	050a3503          	ld	a0,80(s4)
    80004c26:	d2dfc0ef          	jal	80001952 <copyout>
    80004c2a:	03650f63          	beq	a0,s6,80004c68 <piperead+0xea>
      if(i == 0)
        i = -1;
      break;
    }
    pi->nread++;
    80004c2e:	2184a783          	lw	a5,536(s1)
    80004c32:	2785                	addiw	a5,a5,1
    80004c34:	20f4ac23          	sw	a5,536(s1)
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004c38:	2985                	addiw	s3,s3,1
    80004c3a:	0905                	addi	s2,s2,1
    80004c3c:	fd3a93e3          	bne	s5,s3,80004c02 <piperead+0x84>
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80004c40:	21c48513          	addi	a0,s1,540
    80004c44:	875fd0ef          	jal	800024b8 <wakeup>
  release(&pi->lock);
    80004c48:	8526                	mv	a0,s1
    80004c4a:	96cfc0ef          	jal	80000db6 <release>
    80004c4e:	7b02                	ld	s6,32(sp)
    80004c50:	6be2                	ld	s7,24(sp)
    80004c52:	6c42                	ld	s8,16(sp)
  return i;
}
    80004c54:	854e                	mv	a0,s3
    80004c56:	60e6                	ld	ra,88(sp)
    80004c58:	6446                	ld	s0,80(sp)
    80004c5a:	64a6                	ld	s1,72(sp)
    80004c5c:	6906                	ld	s2,64(sp)
    80004c5e:	79e2                	ld	s3,56(sp)
    80004c60:	7a42                	ld	s4,48(sp)
    80004c62:	7aa2                	ld	s5,40(sp)
    80004c64:	6125                	addi	sp,sp,96
    80004c66:	8082                	ret
      if(i == 0)
    80004c68:	fc099ce3          	bnez	s3,80004c40 <piperead+0xc2>
        i = -1;
    80004c6c:	89aa                	mv	s3,a0
    80004c6e:	bfc9                	j	80004c40 <piperead+0xc2>

0000000080004c70 <flags2perm>:

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

// map ELF permissions to PTE permission bits.
int flags2perm(int flags)
{
    80004c70:	1141                	addi	sp,sp,-16
    80004c72:	e406                	sd	ra,8(sp)
    80004c74:	e022                	sd	s0,0(sp)
    80004c76:	0800                	addi	s0,sp,16
    80004c78:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    80004c7a:	0035151b          	slliw	a0,a0,0x3
    80004c7e:	8921                	andi	a0,a0,8
      perm = PTE_X;
    if(flags & 0x2)
    80004c80:	8b89                	andi	a5,a5,2
    80004c82:	c399                	beqz	a5,80004c88 <flags2perm+0x18>
      perm |= PTE_W;
    80004c84:	00456513          	ori	a0,a0,4
    return perm;
}
    80004c88:	60a2                	ld	ra,8(sp)
    80004c8a:	6402                	ld	s0,0(sp)
    80004c8c:	0141                	addi	sp,sp,16
    80004c8e:	8082                	ret

0000000080004c90 <kexec>:
//
// the implementation of the exec() system call
//
int
kexec(char *path, char **argv)
{
    80004c90:	de010113          	addi	sp,sp,-544
    80004c94:	20113c23          	sd	ra,536(sp)
    80004c98:	20813823          	sd	s0,528(sp)
    80004c9c:	20913423          	sd	s1,520(sp)
    80004ca0:	21213023          	sd	s2,512(sp)
    80004ca4:	1400                	addi	s0,sp,544
    80004ca6:	892a                	mv	s2,a0
    80004ca8:	dea43823          	sd	a0,-528(s0)
    80004cac:	e0b43023          	sd	a1,-512(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80004cb0:	f91fc0ef          	jal	80001c40 <myproc>
    80004cb4:	84aa                	mv	s1,a0

  begin_op();
    80004cb6:	d6aff0ef          	jal	80004220 <begin_op>

  // Open the executable file.
  if((ip = namei(path)) == 0){
    80004cba:	854a                	mv	a0,s2
    80004cbc:	b86ff0ef          	jal	80004042 <namei>
    80004cc0:	cd21                	beqz	a0,80004d18 <kexec+0x88>
    80004cc2:	fbd2                	sd	s4,496(sp)
    80004cc4:	8a2a                	mv	s4,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80004cc6:	b4ffe0ef          	jal	80003814 <ilock>

  // Read the ELF header.
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80004cca:	04000713          	li	a4,64
    80004cce:	4681                	li	a3,0
    80004cd0:	e5040613          	addi	a2,s0,-432
    80004cd4:	4581                	li	a1,0
    80004cd6:	8552                	mv	a0,s4
    80004cd8:	ecffe0ef          	jal	80003ba6 <readi>
    80004cdc:	04000793          	li	a5,64
    80004ce0:	00f51a63          	bne	a0,a5,80004cf4 <kexec+0x64>
    goto bad;

  // Is this really an ELF file?
  if(elf.magic != ELF_MAGIC)
    80004ce4:	e5042703          	lw	a4,-432(s0)
    80004ce8:	464c47b7          	lui	a5,0x464c4
    80004cec:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80004cf0:	02f70863          	beq	a4,a5,80004d20 <kexec+0x90>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    80004cf4:	8552                	mv	a0,s4
    80004cf6:	d2bfe0ef          	jal	80003a20 <iunlockput>
    end_op();
    80004cfa:	d96ff0ef          	jal	80004290 <end_op>
  }
  return -1;
    80004cfe:	557d                	li	a0,-1
    80004d00:	7a5e                	ld	s4,496(sp)
}
    80004d02:	21813083          	ld	ra,536(sp)
    80004d06:	21013403          	ld	s0,528(sp)
    80004d0a:	20813483          	ld	s1,520(sp)
    80004d0e:	20013903          	ld	s2,512(sp)
    80004d12:	22010113          	addi	sp,sp,544
    80004d16:	8082                	ret
    end_op();
    80004d18:	d78ff0ef          	jal	80004290 <end_op>
    return -1;
    80004d1c:	557d                	li	a0,-1
    80004d1e:	b7d5                	j	80004d02 <kexec+0x72>
    80004d20:	f3da                	sd	s6,480(sp)
  if((pagetable = proc_pagetable(p)) == 0)
    80004d22:	8526                	mv	a0,s1
    80004d24:	826fd0ef          	jal	80001d4a <proc_pagetable>
    80004d28:	8b2a                	mv	s6,a0
    80004d2a:	26050f63          	beqz	a0,80004fa8 <kexec+0x318>
    80004d2e:	ffce                	sd	s3,504(sp)
    80004d30:	f7d6                	sd	s5,488(sp)
    80004d32:	efde                	sd	s7,472(sp)
    80004d34:	ebe2                	sd	s8,464(sp)
    80004d36:	e7e6                	sd	s9,456(sp)
    80004d38:	e3ea                	sd	s10,448(sp)
    80004d3a:	ff6e                	sd	s11,440(sp)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004d3c:	e8845783          	lhu	a5,-376(s0)
    80004d40:	0e078963          	beqz	a5,80004e32 <kexec+0x1a2>
    80004d44:	e7042683          	lw	a3,-400(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004d48:	4901                	li	s2,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004d4a:	4d01                	li	s10,0
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80004d4c:	03800d93          	li	s11,56
    if(ph.vaddr % PGSIZE != 0)
    80004d50:	6c85                	lui	s9,0x1
    80004d52:	fffc8793          	addi	a5,s9,-1 # fff <_entry-0x7ffff001>
    80004d56:	def43423          	sd	a5,-536(s0)

  for(i = 0; i < sz; i += PGSIZE){
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    if(sz - i < PGSIZE)
    80004d5a:	6a85                	lui	s5,0x1
    80004d5c:	a085                	j	80004dbc <kexec+0x12c>
      panic("loadseg: address should exist");
    80004d5e:	00004517          	auipc	a0,0x4
    80004d62:	87a50513          	addi	a0,a0,-1926 # 800085d8 <etext+0x5d8>
    80004d66:	af1fb0ef          	jal	80000856 <panic>
    if(sz - i < PGSIZE)
    80004d6a:	2901                	sext.w	s2,s2
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80004d6c:	874a                	mv	a4,s2
    80004d6e:	009b86bb          	addw	a3,s7,s1
    80004d72:	4581                	li	a1,0
    80004d74:	8552                	mv	a0,s4
    80004d76:	e31fe0ef          	jal	80003ba6 <readi>
    80004d7a:	22a91b63          	bne	s2,a0,80004fb0 <kexec+0x320>
  for(i = 0; i < sz; i += PGSIZE){
    80004d7e:	009a84bb          	addw	s1,s5,s1
    80004d82:	0334f263          	bgeu	s1,s3,80004da6 <kexec+0x116>
    pa = walkaddr(pagetable, va + i);
    80004d86:	02049593          	slli	a1,s1,0x20
    80004d8a:	9181                	srli	a1,a1,0x20
    80004d8c:	95e2                	add	a1,a1,s8
    80004d8e:	855a                	mv	a0,s6
    80004d90:	ba2fc0ef          	jal	80001132 <walkaddr>
    80004d94:	862a                	mv	a2,a0
    if(pa == 0)
    80004d96:	d561                	beqz	a0,80004d5e <kexec+0xce>
    if(sz - i < PGSIZE)
    80004d98:	409987bb          	subw	a5,s3,s1
    80004d9c:	893e                	mv	s2,a5
    80004d9e:	fcfcf6e3          	bgeu	s9,a5,80004d6a <kexec+0xda>
    80004da2:	8956                	mv	s2,s5
    80004da4:	b7d9                	j	80004d6a <kexec+0xda>
    sz = sz1;
    80004da6:	df843903          	ld	s2,-520(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004daa:	2d05                	addiw	s10,s10,1
    80004dac:	e0843783          	ld	a5,-504(s0)
    80004db0:	0387869b          	addiw	a3,a5,56
    80004db4:	e8845783          	lhu	a5,-376(s0)
    80004db8:	06fd5e63          	bge	s10,a5,80004e34 <kexec+0x1a4>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80004dbc:	e0d43423          	sd	a3,-504(s0)
    80004dc0:	876e                	mv	a4,s11
    80004dc2:	e1840613          	addi	a2,s0,-488
    80004dc6:	4581                	li	a1,0
    80004dc8:	8552                	mv	a0,s4
    80004dca:	dddfe0ef          	jal	80003ba6 <readi>
    80004dce:	1db51f63          	bne	a0,s11,80004fac <kexec+0x31c>
    if(ph.type != ELF_PROG_LOAD)
    80004dd2:	e1842783          	lw	a5,-488(s0)
    80004dd6:	4705                	li	a4,1
    80004dd8:	fce799e3          	bne	a5,a4,80004daa <kexec+0x11a>
    if(ph.memsz < ph.filesz)
    80004ddc:	e4043483          	ld	s1,-448(s0)
    80004de0:	e3843783          	ld	a5,-456(s0)
    80004de4:	1ef4e463          	bltu	s1,a5,80004fcc <kexec+0x33c>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    80004de8:	e2843783          	ld	a5,-472(s0)
    80004dec:	94be                	add	s1,s1,a5
    80004dee:	1ef4e263          	bltu	s1,a5,80004fd2 <kexec+0x342>
    if(ph.vaddr % PGSIZE != 0)
    80004df2:	de843703          	ld	a4,-536(s0)
    80004df6:	8ff9                	and	a5,a5,a4
    80004df8:	1e079063          	bnez	a5,80004fd8 <kexec+0x348>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80004dfc:	e1c42503          	lw	a0,-484(s0)
    80004e00:	e71ff0ef          	jal	80004c70 <flags2perm>
    80004e04:	86aa                	mv	a3,a0
    80004e06:	8626                	mv	a2,s1
    80004e08:	85ca                	mv	a1,s2
    80004e0a:	855a                	mv	a0,s6
    80004e0c:	f18fc0ef          	jal	80001524 <uvmalloc>
    80004e10:	dea43c23          	sd	a0,-520(s0)
    80004e14:	1c050563          	beqz	a0,80004fde <kexec+0x34e>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80004e18:	e3842983          	lw	s3,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    80004e1c:	00098863          	beqz	s3,80004e2c <kexec+0x19c>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80004e20:	e2843c03          	ld	s8,-472(s0)
    80004e24:	e2042b83          	lw	s7,-480(s0)
  for(i = 0; i < sz; i += PGSIZE){
    80004e28:	4481                	li	s1,0
    80004e2a:	bfb1                	j	80004d86 <kexec+0xf6>
    sz = sz1;
    80004e2c:	df843903          	ld	s2,-520(s0)
    80004e30:	bfad                	j	80004daa <kexec+0x11a>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004e32:	4901                	li	s2,0
  iunlockput(ip);
    80004e34:	8552                	mv	a0,s4
    80004e36:	bebfe0ef          	jal	80003a20 <iunlockput>
  end_op();
    80004e3a:	c56ff0ef          	jal	80004290 <end_op>
  p = myproc();
    80004e3e:	e03fc0ef          	jal	80001c40 <myproc>
    80004e42:	8aaa                	mv	s5,a0
  uint64 oldsz = p->sz;
    80004e44:	04853d03          	ld	s10,72(a0)
  sz = PGROUNDUP(sz);
    80004e48:	6985                	lui	s3,0x1
    80004e4a:	19fd                	addi	s3,s3,-1 # fff <_entry-0x7ffff001>
    80004e4c:	99ca                	add	s3,s3,s2
    80004e4e:	77fd                	lui	a5,0xfffff
    80004e50:	00f9f9b3          	and	s3,s3,a5
  if((sz1 = uvmalloc(pagetable, sz, sz + (USERSTACK+1)*PGSIZE, PTE_W)) == 0)
    80004e54:	4691                	li	a3,4
    80004e56:	6609                	lui	a2,0x2
    80004e58:	964e                	add	a2,a2,s3
    80004e5a:	85ce                	mv	a1,s3
    80004e5c:	855a                	mv	a0,s6
    80004e5e:	ec6fc0ef          	jal	80001524 <uvmalloc>
    80004e62:	8a2a                	mv	s4,a0
    80004e64:	e105                	bnez	a0,80004e84 <kexec+0x1f4>
    proc_freepagetable(pagetable, sz);
    80004e66:	85ce                	mv	a1,s3
    80004e68:	855a                	mv	a0,s6
    80004e6a:	f65fc0ef          	jal	80001dce <proc_freepagetable>
  return -1;
    80004e6e:	557d                	li	a0,-1
    80004e70:	79fe                	ld	s3,504(sp)
    80004e72:	7a5e                	ld	s4,496(sp)
    80004e74:	7abe                	ld	s5,488(sp)
    80004e76:	7b1e                	ld	s6,480(sp)
    80004e78:	6bfe                	ld	s7,472(sp)
    80004e7a:	6c5e                	ld	s8,464(sp)
    80004e7c:	6cbe                	ld	s9,456(sp)
    80004e7e:	6d1e                	ld	s10,448(sp)
    80004e80:	7dfa                	ld	s11,440(sp)
    80004e82:	b541                	j	80004d02 <kexec+0x72>
  uvmclear(pagetable, sz-(USERSTACK+1)*PGSIZE);
    80004e84:	75f9                	lui	a1,0xffffe
    80004e86:	95aa                	add	a1,a1,a0
    80004e88:	855a                	mv	a0,s6
    80004e8a:	8effc0ef          	jal	80001778 <uvmclear>
  stackbase = sp - USERSTACK*PGSIZE;
    80004e8e:	800a0b93          	addi	s7,s4,-2048
    80004e92:	800b8b93          	addi	s7,s7,-2048
  for(argc = 0; argv[argc]; argc++) {
    80004e96:	e0043783          	ld	a5,-512(s0)
    80004e9a:	6388                	ld	a0,0(a5)
  sp = sz;
    80004e9c:	8952                	mv	s2,s4
  for(argc = 0; argv[argc]; argc++) {
    80004e9e:	4481                	li	s1,0
    ustack[argc] = sp;
    80004ea0:	e9040c93          	addi	s9,s0,-368
    if(argc >= MAXARG)
    80004ea4:	02000c13          	li	s8,32
  for(argc = 0; argv[argc]; argc++) {
    80004ea8:	cd21                	beqz	a0,80004f00 <kexec+0x270>
    sp -= strlen(argv[argc]) + 1;
    80004eaa:	8d2fc0ef          	jal	80000f7c <strlen>
    80004eae:	0015079b          	addiw	a5,a0,1
    80004eb2:	40f907b3          	sub	a5,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80004eb6:	ff07f913          	andi	s2,a5,-16
    if(sp < stackbase)
    80004eba:	13796563          	bltu	s2,s7,80004fe4 <kexec+0x354>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80004ebe:	e0043d83          	ld	s11,-512(s0)
    80004ec2:	000db983          	ld	s3,0(s11)
    80004ec6:	854e                	mv	a0,s3
    80004ec8:	8b4fc0ef          	jal	80000f7c <strlen>
    80004ecc:	0015069b          	addiw	a3,a0,1
    80004ed0:	864e                	mv	a2,s3
    80004ed2:	85ca                	mv	a1,s2
    80004ed4:	855a                	mv	a0,s6
    80004ed6:	a7dfc0ef          	jal	80001952 <copyout>
    80004eda:	10054763          	bltz	a0,80004fe8 <kexec+0x358>
    ustack[argc] = sp;
    80004ede:	00349793          	slli	a5,s1,0x3
    80004ee2:	97e6                	add	a5,a5,s9
    80004ee4:	0127b023          	sd	s2,0(a5) # fffffffffffff000 <end+0xffffffff7ffb6c08>
  for(argc = 0; argv[argc]; argc++) {
    80004ee8:	0485                	addi	s1,s1,1
    80004eea:	008d8793          	addi	a5,s11,8
    80004eee:	e0f43023          	sd	a5,-512(s0)
    80004ef2:	008db503          	ld	a0,8(s11)
    80004ef6:	c509                	beqz	a0,80004f00 <kexec+0x270>
    if(argc >= MAXARG)
    80004ef8:	fb8499e3          	bne	s1,s8,80004eaa <kexec+0x21a>
  sz = sz1;
    80004efc:	89d2                	mv	s3,s4
    80004efe:	b7a5                	j	80004e66 <kexec+0x1d6>
  ustack[argc] = 0;
    80004f00:	00349793          	slli	a5,s1,0x3
    80004f04:	f9078793          	addi	a5,a5,-112
    80004f08:	97a2                	add	a5,a5,s0
    80004f0a:	f007b023          	sd	zero,-256(a5)
  sp -= (argc+1) * sizeof(uint64);
    80004f0e:	00349693          	slli	a3,s1,0x3
    80004f12:	06a1                	addi	a3,a3,8
    80004f14:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    80004f18:	ff097913          	andi	s2,s2,-16
  sz = sz1;
    80004f1c:	89d2                	mv	s3,s4
  if(sp < stackbase)
    80004f1e:	f57964e3          	bltu	s2,s7,80004e66 <kexec+0x1d6>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    80004f22:	e9040613          	addi	a2,s0,-368
    80004f26:	85ca                	mv	a1,s2
    80004f28:	855a                	mv	a0,s6
    80004f2a:	a29fc0ef          	jal	80001952 <copyout>
    80004f2e:	f2054ce3          	bltz	a0,80004e66 <kexec+0x1d6>
  p->trapframe->a1 = sp;
    80004f32:	058ab783          	ld	a5,88(s5) # 1058 <_entry-0x7fffefa8>
    80004f36:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    80004f3a:	df043783          	ld	a5,-528(s0)
    80004f3e:	0007c703          	lbu	a4,0(a5)
    80004f42:	cf11                	beqz	a4,80004f5e <kexec+0x2ce>
    80004f44:	0785                	addi	a5,a5,1
    if(*s == '/')
    80004f46:	02f00693          	li	a3,47
    80004f4a:	a029                	j	80004f54 <kexec+0x2c4>
  for(last=s=path; *s; s++)
    80004f4c:	0785                	addi	a5,a5,1
    80004f4e:	fff7c703          	lbu	a4,-1(a5)
    80004f52:	c711                	beqz	a4,80004f5e <kexec+0x2ce>
    if(*s == '/')
    80004f54:	fed71ce3          	bne	a4,a3,80004f4c <kexec+0x2bc>
      last = s+1;
    80004f58:	def43823          	sd	a5,-528(s0)
    80004f5c:	bfc5                	j	80004f4c <kexec+0x2bc>
  safestrcpy(p->name, last, sizeof(p->name));
    80004f5e:	4641                	li	a2,16
    80004f60:	df043583          	ld	a1,-528(s0)
    80004f64:	158a8513          	addi	a0,s5,344
    80004f68:	fdffb0ef          	jal	80000f46 <safestrcpy>
  oldpagetable = p->pagetable;
    80004f6c:	050ab503          	ld	a0,80(s5)
  p->pagetable = pagetable;
    80004f70:	056ab823          	sd	s6,80(s5)
  p->sz = sz;
    80004f74:	054ab423          	sd	s4,72(s5)
  p->trapframe->epc = elf.entry;  // initial program counter = ulib.c:start()
    80004f78:	058ab783          	ld	a5,88(s5)
    80004f7c:	e6843703          	ld	a4,-408(s0)
    80004f80:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    80004f82:	058ab783          	ld	a5,88(s5)
    80004f86:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    80004f8a:	85ea                	mv	a1,s10
    80004f8c:	e43fc0ef          	jal	80001dce <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80004f90:	0004851b          	sext.w	a0,s1
    80004f94:	79fe                	ld	s3,504(sp)
    80004f96:	7a5e                	ld	s4,496(sp)
    80004f98:	7abe                	ld	s5,488(sp)
    80004f9a:	7b1e                	ld	s6,480(sp)
    80004f9c:	6bfe                	ld	s7,472(sp)
    80004f9e:	6c5e                	ld	s8,464(sp)
    80004fa0:	6cbe                	ld	s9,456(sp)
    80004fa2:	6d1e                	ld	s10,448(sp)
    80004fa4:	7dfa                	ld	s11,440(sp)
    80004fa6:	bbb1                	j	80004d02 <kexec+0x72>
    80004fa8:	7b1e                	ld	s6,480(sp)
    80004faa:	b3a9                	j	80004cf4 <kexec+0x64>
    80004fac:	df243c23          	sd	s2,-520(s0)
    proc_freepagetable(pagetable, sz);
    80004fb0:	df843583          	ld	a1,-520(s0)
    80004fb4:	855a                	mv	a0,s6
    80004fb6:	e19fc0ef          	jal	80001dce <proc_freepagetable>
  if(ip){
    80004fba:	79fe                	ld	s3,504(sp)
    80004fbc:	7abe                	ld	s5,488(sp)
    80004fbe:	7b1e                	ld	s6,480(sp)
    80004fc0:	6bfe                	ld	s7,472(sp)
    80004fc2:	6c5e                	ld	s8,464(sp)
    80004fc4:	6cbe                	ld	s9,456(sp)
    80004fc6:	6d1e                	ld	s10,448(sp)
    80004fc8:	7dfa                	ld	s11,440(sp)
    80004fca:	b32d                	j	80004cf4 <kexec+0x64>
    80004fcc:	df243c23          	sd	s2,-520(s0)
    80004fd0:	b7c5                	j	80004fb0 <kexec+0x320>
    80004fd2:	df243c23          	sd	s2,-520(s0)
    80004fd6:	bfe9                	j	80004fb0 <kexec+0x320>
    80004fd8:	df243c23          	sd	s2,-520(s0)
    80004fdc:	bfd1                	j	80004fb0 <kexec+0x320>
    80004fde:	df243c23          	sd	s2,-520(s0)
    80004fe2:	b7f9                	j	80004fb0 <kexec+0x320>
  sz = sz1;
    80004fe4:	89d2                	mv	s3,s4
    80004fe6:	b541                	j	80004e66 <kexec+0x1d6>
    80004fe8:	89d2                	mv	s3,s4
    80004fea:	bdb5                	j	80004e66 <kexec+0x1d6>

0000000080004fec <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80004fec:	7179                	addi	sp,sp,-48
    80004fee:	f406                	sd	ra,40(sp)
    80004ff0:	f022                	sd	s0,32(sp)
    80004ff2:	ec26                	sd	s1,24(sp)
    80004ff4:	e84a                	sd	s2,16(sp)
    80004ff6:	1800                	addi	s0,sp,48
    80004ff8:	892e                	mv	s2,a1
    80004ffa:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    80004ffc:	fdc40593          	addi	a1,s0,-36
    80005000:	d79fd0ef          	jal	80002d78 <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    80005004:	fdc42703          	lw	a4,-36(s0)
    80005008:	47bd                	li	a5,15
    8000500a:	02e7ea63          	bltu	a5,a4,8000503e <argfd+0x52>
    8000500e:	c33fc0ef          	jal	80001c40 <myproc>
    80005012:	fdc42703          	lw	a4,-36(s0)
    80005016:	00371793          	slli	a5,a4,0x3
    8000501a:	0d078793          	addi	a5,a5,208
    8000501e:	953e                	add	a0,a0,a5
    80005020:	611c                	ld	a5,0(a0)
    80005022:	c385                	beqz	a5,80005042 <argfd+0x56>
    return -1;
  if(pfd)
    80005024:	00090463          	beqz	s2,8000502c <argfd+0x40>
    *pfd = fd;
    80005028:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    8000502c:	4501                	li	a0,0
  if(pf)
    8000502e:	c091                	beqz	s1,80005032 <argfd+0x46>
    *pf = f;
    80005030:	e09c                	sd	a5,0(s1)
}
    80005032:	70a2                	ld	ra,40(sp)
    80005034:	7402                	ld	s0,32(sp)
    80005036:	64e2                	ld	s1,24(sp)
    80005038:	6942                	ld	s2,16(sp)
    8000503a:	6145                	addi	sp,sp,48
    8000503c:	8082                	ret
    return -1;
    8000503e:	557d                	li	a0,-1
    80005040:	bfcd                	j	80005032 <argfd+0x46>
    80005042:	557d                	li	a0,-1
    80005044:	b7fd                	j	80005032 <argfd+0x46>

0000000080005046 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    80005046:	1101                	addi	sp,sp,-32
    80005048:	ec06                	sd	ra,24(sp)
    8000504a:	e822                	sd	s0,16(sp)
    8000504c:	e426                	sd	s1,8(sp)
    8000504e:	1000                	addi	s0,sp,32
    80005050:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    80005052:	beffc0ef          	jal	80001c40 <myproc>
    80005056:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    80005058:	0d050793          	addi	a5,a0,208
    8000505c:	4501                	li	a0,0
    8000505e:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    80005060:	6398                	ld	a4,0(a5)
    80005062:	cb19                	beqz	a4,80005078 <fdalloc+0x32>
  for(fd = 0; fd < NOFILE; fd++){
    80005064:	2505                	addiw	a0,a0,1
    80005066:	07a1                	addi	a5,a5,8
    80005068:	fed51ce3          	bne	a0,a3,80005060 <fdalloc+0x1a>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    8000506c:	557d                	li	a0,-1
}
    8000506e:	60e2                	ld	ra,24(sp)
    80005070:	6442                	ld	s0,16(sp)
    80005072:	64a2                	ld	s1,8(sp)
    80005074:	6105                	addi	sp,sp,32
    80005076:	8082                	ret
      p->ofile[fd] = f;
    80005078:	00351793          	slli	a5,a0,0x3
    8000507c:	0d078793          	addi	a5,a5,208
    80005080:	963e                	add	a2,a2,a5
    80005082:	e204                	sd	s1,0(a2)
      return fd;
    80005084:	b7ed                	j	8000506e <fdalloc+0x28>

0000000080005086 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    80005086:	715d                	addi	sp,sp,-80
    80005088:	e486                	sd	ra,72(sp)
    8000508a:	e0a2                	sd	s0,64(sp)
    8000508c:	fc26                	sd	s1,56(sp)
    8000508e:	f84a                	sd	s2,48(sp)
    80005090:	f44e                	sd	s3,40(sp)
    80005092:	f052                	sd	s4,32(sp)
    80005094:	ec56                	sd	s5,24(sp)
    80005096:	e85a                	sd	s6,16(sp)
    80005098:	0880                	addi	s0,sp,80
    8000509a:	892e                	mv	s2,a1
    8000509c:	8a2e                	mv	s4,a1
    8000509e:	8ab2                	mv	s5,a2
    800050a0:	8b36                	mv	s6,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    800050a2:	fb040593          	addi	a1,s0,-80
    800050a6:	fb7fe0ef          	jal	8000405c <nameiparent>
    800050aa:	84aa                	mv	s1,a0
    800050ac:	10050763          	beqz	a0,800051ba <create+0x134>
    return 0;

  ilock(dp);
    800050b0:	f64fe0ef          	jal	80003814 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    800050b4:	4601                	li	a2,0
    800050b6:	fb040593          	addi	a1,s0,-80
    800050ba:	8526                	mv	a0,s1
    800050bc:	cf3fe0ef          	jal	80003dae <dirlookup>
    800050c0:	89aa                	mv	s3,a0
    800050c2:	c131                	beqz	a0,80005106 <create+0x80>
    iunlockput(dp);
    800050c4:	8526                	mv	a0,s1
    800050c6:	95bfe0ef          	jal	80003a20 <iunlockput>
    ilock(ip);
    800050ca:	854e                	mv	a0,s3
    800050cc:	f48fe0ef          	jal	80003814 <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    800050d0:	4789                	li	a5,2
    800050d2:	02f91563          	bne	s2,a5,800050fc <create+0x76>
    800050d6:	0449d783          	lhu	a5,68(s3)
    800050da:	37f9                	addiw	a5,a5,-2
    800050dc:	17c2                	slli	a5,a5,0x30
    800050de:	93c1                	srli	a5,a5,0x30
    800050e0:	4705                	li	a4,1
    800050e2:	00f76d63          	bltu	a4,a5,800050fc <create+0x76>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    800050e6:	854e                	mv	a0,s3
    800050e8:	60a6                	ld	ra,72(sp)
    800050ea:	6406                	ld	s0,64(sp)
    800050ec:	74e2                	ld	s1,56(sp)
    800050ee:	7942                	ld	s2,48(sp)
    800050f0:	79a2                	ld	s3,40(sp)
    800050f2:	7a02                	ld	s4,32(sp)
    800050f4:	6ae2                	ld	s5,24(sp)
    800050f6:	6b42                	ld	s6,16(sp)
    800050f8:	6161                	addi	sp,sp,80
    800050fa:	8082                	ret
    iunlockput(ip);
    800050fc:	854e                	mv	a0,s3
    800050fe:	923fe0ef          	jal	80003a20 <iunlockput>
    return 0;
    80005102:	4981                	li	s3,0
    80005104:	b7cd                	j	800050e6 <create+0x60>
  if((ip = ialloc(dp->dev, type)) == 0){
    80005106:	85ca                	mv	a1,s2
    80005108:	4088                	lw	a0,0(s1)
    8000510a:	d9afe0ef          	jal	800036a4 <ialloc>
    8000510e:	892a                	mv	s2,a0
    80005110:	cd15                	beqz	a0,8000514c <create+0xc6>
  ilock(ip);
    80005112:	f02fe0ef          	jal	80003814 <ilock>
  ip->major = major;
    80005116:	05591323          	sh	s5,70(s2)
  ip->minor = minor;
    8000511a:	05691423          	sh	s6,72(s2)
  ip->nlink = 1;
    8000511e:	4785                	li	a5,1
    80005120:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80005124:	854a                	mv	a0,s2
    80005126:	e3afe0ef          	jal	80003760 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    8000512a:	4705                	li	a4,1
    8000512c:	02ea0463          	beq	s4,a4,80005154 <create+0xce>
  if(dirlink(dp, name, ip->inum) < 0)
    80005130:	00492603          	lw	a2,4(s2)
    80005134:	fb040593          	addi	a1,s0,-80
    80005138:	8526                	mv	a0,s1
    8000513a:	e5ffe0ef          	jal	80003f98 <dirlink>
    8000513e:	06054263          	bltz	a0,800051a2 <create+0x11c>
  iunlockput(dp);
    80005142:	8526                	mv	a0,s1
    80005144:	8ddfe0ef          	jal	80003a20 <iunlockput>
  return ip;
    80005148:	89ca                	mv	s3,s2
    8000514a:	bf71                	j	800050e6 <create+0x60>
    iunlockput(dp);
    8000514c:	8526                	mv	a0,s1
    8000514e:	8d3fe0ef          	jal	80003a20 <iunlockput>
    return 0;
    80005152:	bf51                	j	800050e6 <create+0x60>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    80005154:	00492603          	lw	a2,4(s2)
    80005158:	00003597          	auipc	a1,0x3
    8000515c:	4a058593          	addi	a1,a1,1184 # 800085f8 <etext+0x5f8>
    80005160:	854a                	mv	a0,s2
    80005162:	e37fe0ef          	jal	80003f98 <dirlink>
    80005166:	02054e63          	bltz	a0,800051a2 <create+0x11c>
    8000516a:	40d0                	lw	a2,4(s1)
    8000516c:	00003597          	auipc	a1,0x3
    80005170:	49458593          	addi	a1,a1,1172 # 80008600 <etext+0x600>
    80005174:	854a                	mv	a0,s2
    80005176:	e23fe0ef          	jal	80003f98 <dirlink>
    8000517a:	02054463          	bltz	a0,800051a2 <create+0x11c>
  if(dirlink(dp, name, ip->inum) < 0)
    8000517e:	00492603          	lw	a2,4(s2)
    80005182:	fb040593          	addi	a1,s0,-80
    80005186:	8526                	mv	a0,s1
    80005188:	e11fe0ef          	jal	80003f98 <dirlink>
    8000518c:	00054b63          	bltz	a0,800051a2 <create+0x11c>
    dp->nlink++;  // for ".."
    80005190:	04a4d783          	lhu	a5,74(s1)
    80005194:	2785                	addiw	a5,a5,1
    80005196:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    8000519a:	8526                	mv	a0,s1
    8000519c:	dc4fe0ef          	jal	80003760 <iupdate>
    800051a0:	b74d                	j	80005142 <create+0xbc>
  ip->nlink = 0;
    800051a2:	04091523          	sh	zero,74(s2)
  iupdate(ip);
    800051a6:	854a                	mv	a0,s2
    800051a8:	db8fe0ef          	jal	80003760 <iupdate>
  iunlockput(ip);
    800051ac:	854a                	mv	a0,s2
    800051ae:	873fe0ef          	jal	80003a20 <iunlockput>
  iunlockput(dp);
    800051b2:	8526                	mv	a0,s1
    800051b4:	86dfe0ef          	jal	80003a20 <iunlockput>
  return 0;
    800051b8:	b73d                	j	800050e6 <create+0x60>
    return 0;
    800051ba:	89aa                	mv	s3,a0
    800051bc:	b72d                	j	800050e6 <create+0x60>

00000000800051be <sys_dup>:
{
    800051be:	7179                	addi	sp,sp,-48
    800051c0:	f406                	sd	ra,40(sp)
    800051c2:	f022                	sd	s0,32(sp)
    800051c4:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    800051c6:	fd840613          	addi	a2,s0,-40
    800051ca:	4581                	li	a1,0
    800051cc:	4501                	li	a0,0
    800051ce:	e1fff0ef          	jal	80004fec <argfd>
    return -1;
    800051d2:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    800051d4:	02054363          	bltz	a0,800051fa <sys_dup+0x3c>
    800051d8:	ec26                	sd	s1,24(sp)
    800051da:	e84a                	sd	s2,16(sp)
  if((fd=fdalloc(f)) < 0)
    800051dc:	fd843483          	ld	s1,-40(s0)
    800051e0:	8526                	mv	a0,s1
    800051e2:	e65ff0ef          	jal	80005046 <fdalloc>
    800051e6:	892a                	mv	s2,a0
    return -1;
    800051e8:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    800051ea:	00054d63          	bltz	a0,80005204 <sys_dup+0x46>
  filedup(f);
    800051ee:	8526                	mv	a0,s1
    800051f0:	c0eff0ef          	jal	800045fe <filedup>
  return fd;
    800051f4:	87ca                	mv	a5,s2
    800051f6:	64e2                	ld	s1,24(sp)
    800051f8:	6942                	ld	s2,16(sp)
}
    800051fa:	853e                	mv	a0,a5
    800051fc:	70a2                	ld	ra,40(sp)
    800051fe:	7402                	ld	s0,32(sp)
    80005200:	6145                	addi	sp,sp,48
    80005202:	8082                	ret
    80005204:	64e2                	ld	s1,24(sp)
    80005206:	6942                	ld	s2,16(sp)
    80005208:	bfcd                	j	800051fa <sys_dup+0x3c>

000000008000520a <sys_read>:
{
    8000520a:	7179                	addi	sp,sp,-48
    8000520c:	f406                	sd	ra,40(sp)
    8000520e:	f022                	sd	s0,32(sp)
    80005210:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80005212:	fd840593          	addi	a1,s0,-40
    80005216:	4505                	li	a0,1
    80005218:	b7dfd0ef          	jal	80002d94 <argaddr>
  argint(2, &n);
    8000521c:	fe440593          	addi	a1,s0,-28
    80005220:	4509                	li	a0,2
    80005222:	b57fd0ef          	jal	80002d78 <argint>
  if(argfd(0, 0, &f) < 0)
    80005226:	fe840613          	addi	a2,s0,-24
    8000522a:	4581                	li	a1,0
    8000522c:	4501                	li	a0,0
    8000522e:	dbfff0ef          	jal	80004fec <argfd>
    80005232:	87aa                	mv	a5,a0
    return -1;
    80005234:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80005236:	0007ca63          	bltz	a5,8000524a <sys_read+0x40>
  return fileread(f, p, n);
    8000523a:	fe442603          	lw	a2,-28(s0)
    8000523e:	fd843583          	ld	a1,-40(s0)
    80005242:	fe843503          	ld	a0,-24(s0)
    80005246:	d22ff0ef          	jal	80004768 <fileread>
}
    8000524a:	70a2                	ld	ra,40(sp)
    8000524c:	7402                	ld	s0,32(sp)
    8000524e:	6145                	addi	sp,sp,48
    80005250:	8082                	ret

0000000080005252 <sys_write>:
{
    80005252:	7179                	addi	sp,sp,-48
    80005254:	f406                	sd	ra,40(sp)
    80005256:	f022                	sd	s0,32(sp)
    80005258:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    8000525a:	fd840593          	addi	a1,s0,-40
    8000525e:	4505                	li	a0,1
    80005260:	b35fd0ef          	jal	80002d94 <argaddr>
  argint(2, &n);
    80005264:	fe440593          	addi	a1,s0,-28
    80005268:	4509                	li	a0,2
    8000526a:	b0ffd0ef          	jal	80002d78 <argint>
  if(argfd(0, 0, &f) < 0)
    8000526e:	fe840613          	addi	a2,s0,-24
    80005272:	4581                	li	a1,0
    80005274:	4501                	li	a0,0
    80005276:	d77ff0ef          	jal	80004fec <argfd>
    8000527a:	87aa                	mv	a5,a0
    return -1;
    8000527c:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    8000527e:	0007ca63          	bltz	a5,80005292 <sys_write+0x40>
  return filewrite(f, p, n);
    80005282:	fe442603          	lw	a2,-28(s0)
    80005286:	fd843583          	ld	a1,-40(s0)
    8000528a:	fe843503          	ld	a0,-24(s0)
    8000528e:	d9eff0ef          	jal	8000482c <filewrite>
}
    80005292:	70a2                	ld	ra,40(sp)
    80005294:	7402                	ld	s0,32(sp)
    80005296:	6145                	addi	sp,sp,48
    80005298:	8082                	ret

000000008000529a <sys_close>:
{
    8000529a:	1101                	addi	sp,sp,-32
    8000529c:	ec06                	sd	ra,24(sp)
    8000529e:	e822                	sd	s0,16(sp)
    800052a0:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    800052a2:	fe040613          	addi	a2,s0,-32
    800052a6:	fec40593          	addi	a1,s0,-20
    800052aa:	4501                	li	a0,0
    800052ac:	d41ff0ef          	jal	80004fec <argfd>
    return -1;
    800052b0:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    800052b2:	02054163          	bltz	a0,800052d4 <sys_close+0x3a>
  myproc()->ofile[fd] = 0;
    800052b6:	98bfc0ef          	jal	80001c40 <myproc>
    800052ba:	fec42783          	lw	a5,-20(s0)
    800052be:	078e                	slli	a5,a5,0x3
    800052c0:	0d078793          	addi	a5,a5,208
    800052c4:	953e                	add	a0,a0,a5
    800052c6:	00053023          	sd	zero,0(a0)
  fileclose(f);
    800052ca:	fe043503          	ld	a0,-32(s0)
    800052ce:	b76ff0ef          	jal	80004644 <fileclose>
  return 0;
    800052d2:	4781                	li	a5,0
}
    800052d4:	853e                	mv	a0,a5
    800052d6:	60e2                	ld	ra,24(sp)
    800052d8:	6442                	ld	s0,16(sp)
    800052da:	6105                	addi	sp,sp,32
    800052dc:	8082                	ret

00000000800052de <sys_fstat>:
{
    800052de:	1101                	addi	sp,sp,-32
    800052e0:	ec06                	sd	ra,24(sp)
    800052e2:	e822                	sd	s0,16(sp)
    800052e4:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    800052e6:	fe040593          	addi	a1,s0,-32
    800052ea:	4505                	li	a0,1
    800052ec:	aa9fd0ef          	jal	80002d94 <argaddr>
  if(argfd(0, 0, &f) < 0)
    800052f0:	fe840613          	addi	a2,s0,-24
    800052f4:	4581                	li	a1,0
    800052f6:	4501                	li	a0,0
    800052f8:	cf5ff0ef          	jal	80004fec <argfd>
    800052fc:	87aa                	mv	a5,a0
    return -1;
    800052fe:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80005300:	0007c863          	bltz	a5,80005310 <sys_fstat+0x32>
  return filestat(f, st);
    80005304:	fe043583          	ld	a1,-32(s0)
    80005308:	fe843503          	ld	a0,-24(s0)
    8000530c:	bfaff0ef          	jal	80004706 <filestat>
}
    80005310:	60e2                	ld	ra,24(sp)
    80005312:	6442                	ld	s0,16(sp)
    80005314:	6105                	addi	sp,sp,32
    80005316:	8082                	ret

0000000080005318 <sys_link>:
{
    80005318:	7169                	addi	sp,sp,-304
    8000531a:	f606                	sd	ra,296(sp)
    8000531c:	f222                	sd	s0,288(sp)
    8000531e:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005320:	08000613          	li	a2,128
    80005324:	ed040593          	addi	a1,s0,-304
    80005328:	4501                	li	a0,0
    8000532a:	a87fd0ef          	jal	80002db0 <argstr>
    return -1;
    8000532e:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005330:	0c054e63          	bltz	a0,8000540c <sys_link+0xf4>
    80005334:	08000613          	li	a2,128
    80005338:	f5040593          	addi	a1,s0,-176
    8000533c:	4505                	li	a0,1
    8000533e:	a73fd0ef          	jal	80002db0 <argstr>
    return -1;
    80005342:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005344:	0c054463          	bltz	a0,8000540c <sys_link+0xf4>
    80005348:	ee26                	sd	s1,280(sp)
  begin_op();
    8000534a:	ed7fe0ef          	jal	80004220 <begin_op>
  if((ip = namei(old)) == 0){
    8000534e:	ed040513          	addi	a0,s0,-304
    80005352:	cf1fe0ef          	jal	80004042 <namei>
    80005356:	84aa                	mv	s1,a0
    80005358:	c53d                	beqz	a0,800053c6 <sys_link+0xae>
  ilock(ip);
    8000535a:	cbafe0ef          	jal	80003814 <ilock>
  if(ip->type == T_DIR){
    8000535e:	04449703          	lh	a4,68(s1)
    80005362:	4785                	li	a5,1
    80005364:	06f70663          	beq	a4,a5,800053d0 <sys_link+0xb8>
    80005368:	ea4a                	sd	s2,272(sp)
  ip->nlink++;
    8000536a:	04a4d783          	lhu	a5,74(s1)
    8000536e:	2785                	addiw	a5,a5,1
    80005370:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005374:	8526                	mv	a0,s1
    80005376:	beafe0ef          	jal	80003760 <iupdate>
  iunlock(ip);
    8000537a:	8526                	mv	a0,s1
    8000537c:	d46fe0ef          	jal	800038c2 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    80005380:	fd040593          	addi	a1,s0,-48
    80005384:	f5040513          	addi	a0,s0,-176
    80005388:	cd5fe0ef          	jal	8000405c <nameiparent>
    8000538c:	892a                	mv	s2,a0
    8000538e:	cd21                	beqz	a0,800053e6 <sys_link+0xce>
  ilock(dp);
    80005390:	c84fe0ef          	jal	80003814 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    80005394:	854a                	mv	a0,s2
    80005396:	00092703          	lw	a4,0(s2)
    8000539a:	409c                	lw	a5,0(s1)
    8000539c:	04f71263          	bne	a4,a5,800053e0 <sys_link+0xc8>
    800053a0:	40d0                	lw	a2,4(s1)
    800053a2:	fd040593          	addi	a1,s0,-48
    800053a6:	bf3fe0ef          	jal	80003f98 <dirlink>
    800053aa:	02054b63          	bltz	a0,800053e0 <sys_link+0xc8>
  iunlockput(dp);
    800053ae:	854a                	mv	a0,s2
    800053b0:	e70fe0ef          	jal	80003a20 <iunlockput>
  iput(ip);
    800053b4:	8526                	mv	a0,s1
    800053b6:	de0fe0ef          	jal	80003996 <iput>
  end_op();
    800053ba:	ed7fe0ef          	jal	80004290 <end_op>
  return 0;
    800053be:	4781                	li	a5,0
    800053c0:	64f2                	ld	s1,280(sp)
    800053c2:	6952                	ld	s2,272(sp)
    800053c4:	a0a1                	j	8000540c <sys_link+0xf4>
    end_op();
    800053c6:	ecbfe0ef          	jal	80004290 <end_op>
    return -1;
    800053ca:	57fd                	li	a5,-1
    800053cc:	64f2                	ld	s1,280(sp)
    800053ce:	a83d                	j	8000540c <sys_link+0xf4>
    iunlockput(ip);
    800053d0:	8526                	mv	a0,s1
    800053d2:	e4efe0ef          	jal	80003a20 <iunlockput>
    end_op();
    800053d6:	ebbfe0ef          	jal	80004290 <end_op>
    return -1;
    800053da:	57fd                	li	a5,-1
    800053dc:	64f2                	ld	s1,280(sp)
    800053de:	a03d                	j	8000540c <sys_link+0xf4>
    iunlockput(dp);
    800053e0:	854a                	mv	a0,s2
    800053e2:	e3efe0ef          	jal	80003a20 <iunlockput>
  ilock(ip);
    800053e6:	8526                	mv	a0,s1
    800053e8:	c2cfe0ef          	jal	80003814 <ilock>
  ip->nlink--;
    800053ec:	04a4d783          	lhu	a5,74(s1)
    800053f0:	37fd                	addiw	a5,a5,-1
    800053f2:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    800053f6:	8526                	mv	a0,s1
    800053f8:	b68fe0ef          	jal	80003760 <iupdate>
  iunlockput(ip);
    800053fc:	8526                	mv	a0,s1
    800053fe:	e22fe0ef          	jal	80003a20 <iunlockput>
  end_op();
    80005402:	e8ffe0ef          	jal	80004290 <end_op>
  return -1;
    80005406:	57fd                	li	a5,-1
    80005408:	64f2                	ld	s1,280(sp)
    8000540a:	6952                	ld	s2,272(sp)
}
    8000540c:	853e                	mv	a0,a5
    8000540e:	70b2                	ld	ra,296(sp)
    80005410:	7412                	ld	s0,288(sp)
    80005412:	6155                	addi	sp,sp,304
    80005414:	8082                	ret

0000000080005416 <sys_unlink>:
{
    80005416:	7151                	addi	sp,sp,-240
    80005418:	f586                	sd	ra,232(sp)
    8000541a:	f1a2                	sd	s0,224(sp)
    8000541c:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    8000541e:	08000613          	li	a2,128
    80005422:	f3040593          	addi	a1,s0,-208
    80005426:	4501                	li	a0,0
    80005428:	989fd0ef          	jal	80002db0 <argstr>
    8000542c:	14054d63          	bltz	a0,80005586 <sys_unlink+0x170>
    80005430:	eda6                	sd	s1,216(sp)
  begin_op();
    80005432:	deffe0ef          	jal	80004220 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    80005436:	fb040593          	addi	a1,s0,-80
    8000543a:	f3040513          	addi	a0,s0,-208
    8000543e:	c1ffe0ef          	jal	8000405c <nameiparent>
    80005442:	84aa                	mv	s1,a0
    80005444:	c955                	beqz	a0,800054f8 <sys_unlink+0xe2>
  ilock(dp);
    80005446:	bcefe0ef          	jal	80003814 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    8000544a:	00003597          	auipc	a1,0x3
    8000544e:	1ae58593          	addi	a1,a1,430 # 800085f8 <etext+0x5f8>
    80005452:	fb040513          	addi	a0,s0,-80
    80005456:	943fe0ef          	jal	80003d98 <namecmp>
    8000545a:	10050b63          	beqz	a0,80005570 <sys_unlink+0x15a>
    8000545e:	00003597          	auipc	a1,0x3
    80005462:	1a258593          	addi	a1,a1,418 # 80008600 <etext+0x600>
    80005466:	fb040513          	addi	a0,s0,-80
    8000546a:	92ffe0ef          	jal	80003d98 <namecmp>
    8000546e:	10050163          	beqz	a0,80005570 <sys_unlink+0x15a>
    80005472:	e9ca                	sd	s2,208(sp)
  if((ip = dirlookup(dp, name, &off)) == 0)
    80005474:	f2c40613          	addi	a2,s0,-212
    80005478:	fb040593          	addi	a1,s0,-80
    8000547c:	8526                	mv	a0,s1
    8000547e:	931fe0ef          	jal	80003dae <dirlookup>
    80005482:	892a                	mv	s2,a0
    80005484:	0e050563          	beqz	a0,8000556e <sys_unlink+0x158>
    80005488:	e5ce                	sd	s3,200(sp)
  ilock(ip);
    8000548a:	b8afe0ef          	jal	80003814 <ilock>
  if(ip->nlink < 1)
    8000548e:	04a91783          	lh	a5,74(s2)
    80005492:	06f05863          	blez	a5,80005502 <sys_unlink+0xec>
  if(ip->type == T_DIR && !isdirempty(ip)){
    80005496:	04491703          	lh	a4,68(s2)
    8000549a:	4785                	li	a5,1
    8000549c:	06f70963          	beq	a4,a5,8000550e <sys_unlink+0xf8>
  memset(&de, 0, sizeof(de));
    800054a0:	fc040993          	addi	s3,s0,-64
    800054a4:	4641                	li	a2,16
    800054a6:	4581                	li	a1,0
    800054a8:	854e                	mv	a0,s3
    800054aa:	949fb0ef          	jal	80000df2 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800054ae:	4741                	li	a4,16
    800054b0:	f2c42683          	lw	a3,-212(s0)
    800054b4:	864e                	mv	a2,s3
    800054b6:	4581                	li	a1,0
    800054b8:	8526                	mv	a0,s1
    800054ba:	fdefe0ef          	jal	80003c98 <writei>
    800054be:	47c1                	li	a5,16
    800054c0:	08f51863          	bne	a0,a5,80005550 <sys_unlink+0x13a>
  if(ip->type == T_DIR){
    800054c4:	04491703          	lh	a4,68(s2)
    800054c8:	4785                	li	a5,1
    800054ca:	08f70963          	beq	a4,a5,8000555c <sys_unlink+0x146>
  iunlockput(dp);
    800054ce:	8526                	mv	a0,s1
    800054d0:	d50fe0ef          	jal	80003a20 <iunlockput>
  ip->nlink--;
    800054d4:	04a95783          	lhu	a5,74(s2)
    800054d8:	37fd                	addiw	a5,a5,-1
    800054da:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    800054de:	854a                	mv	a0,s2
    800054e0:	a80fe0ef          	jal	80003760 <iupdate>
  iunlockput(ip);
    800054e4:	854a                	mv	a0,s2
    800054e6:	d3afe0ef          	jal	80003a20 <iunlockput>
  end_op();
    800054ea:	da7fe0ef          	jal	80004290 <end_op>
  return 0;
    800054ee:	4501                	li	a0,0
    800054f0:	64ee                	ld	s1,216(sp)
    800054f2:	694e                	ld	s2,208(sp)
    800054f4:	69ae                	ld	s3,200(sp)
    800054f6:	a061                	j	8000557e <sys_unlink+0x168>
    end_op();
    800054f8:	d99fe0ef          	jal	80004290 <end_op>
    return -1;
    800054fc:	557d                	li	a0,-1
    800054fe:	64ee                	ld	s1,216(sp)
    80005500:	a8bd                	j	8000557e <sys_unlink+0x168>
    panic("unlink: nlink < 1");
    80005502:	00003517          	auipc	a0,0x3
    80005506:	10650513          	addi	a0,a0,262 # 80008608 <etext+0x608>
    8000550a:	b4cfb0ef          	jal	80000856 <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    8000550e:	04c92703          	lw	a4,76(s2)
    80005512:	02000793          	li	a5,32
    80005516:	f8e7f5e3          	bgeu	a5,a4,800054a0 <sys_unlink+0x8a>
    8000551a:	89be                	mv	s3,a5
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000551c:	4741                	li	a4,16
    8000551e:	86ce                	mv	a3,s3
    80005520:	f1840613          	addi	a2,s0,-232
    80005524:	4581                	li	a1,0
    80005526:	854a                	mv	a0,s2
    80005528:	e7efe0ef          	jal	80003ba6 <readi>
    8000552c:	47c1                	li	a5,16
    8000552e:	00f51b63          	bne	a0,a5,80005544 <sys_unlink+0x12e>
    if(de.inum != 0)
    80005532:	f1845783          	lhu	a5,-232(s0)
    80005536:	ebb1                	bnez	a5,8000558a <sys_unlink+0x174>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005538:	29c1                	addiw	s3,s3,16
    8000553a:	04c92783          	lw	a5,76(s2)
    8000553e:	fcf9efe3          	bltu	s3,a5,8000551c <sys_unlink+0x106>
    80005542:	bfb9                	j	800054a0 <sys_unlink+0x8a>
      panic("isdirempty: readi");
    80005544:	00003517          	auipc	a0,0x3
    80005548:	0dc50513          	addi	a0,a0,220 # 80008620 <etext+0x620>
    8000554c:	b0afb0ef          	jal	80000856 <panic>
    panic("unlink: writei");
    80005550:	00003517          	auipc	a0,0x3
    80005554:	0e850513          	addi	a0,a0,232 # 80008638 <etext+0x638>
    80005558:	afefb0ef          	jal	80000856 <panic>
    dp->nlink--;
    8000555c:	04a4d783          	lhu	a5,74(s1)
    80005560:	37fd                	addiw	a5,a5,-1
    80005562:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80005566:	8526                	mv	a0,s1
    80005568:	9f8fe0ef          	jal	80003760 <iupdate>
    8000556c:	b78d                	j	800054ce <sys_unlink+0xb8>
    8000556e:	694e                	ld	s2,208(sp)
  iunlockput(dp);
    80005570:	8526                	mv	a0,s1
    80005572:	caefe0ef          	jal	80003a20 <iunlockput>
  end_op();
    80005576:	d1bfe0ef          	jal	80004290 <end_op>
  return -1;
    8000557a:	557d                	li	a0,-1
    8000557c:	64ee                	ld	s1,216(sp)
}
    8000557e:	70ae                	ld	ra,232(sp)
    80005580:	740e                	ld	s0,224(sp)
    80005582:	616d                	addi	sp,sp,240
    80005584:	8082                	ret
    return -1;
    80005586:	557d                	li	a0,-1
    80005588:	bfdd                	j	8000557e <sys_unlink+0x168>
    iunlockput(ip);
    8000558a:	854a                	mv	a0,s2
    8000558c:	c94fe0ef          	jal	80003a20 <iunlockput>
    goto bad;
    80005590:	694e                	ld	s2,208(sp)
    80005592:	69ae                	ld	s3,200(sp)
    80005594:	bff1                	j	80005570 <sys_unlink+0x15a>

0000000080005596 <sys_open>:

uint64
sys_open(void)
{
    80005596:	7131                	addi	sp,sp,-192
    80005598:	fd06                	sd	ra,184(sp)
    8000559a:	f922                	sd	s0,176(sp)
    8000559c:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    8000559e:	f4c40593          	addi	a1,s0,-180
    800055a2:	4505                	li	a0,1
    800055a4:	fd4fd0ef          	jal	80002d78 <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    800055a8:	08000613          	li	a2,128
    800055ac:	f5040593          	addi	a1,s0,-176
    800055b0:	4501                	li	a0,0
    800055b2:	ffefd0ef          	jal	80002db0 <argstr>
    800055b6:	87aa                	mv	a5,a0
    return -1;
    800055b8:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    800055ba:	0a07c363          	bltz	a5,80005660 <sys_open+0xca>
    800055be:	f526                	sd	s1,168(sp)

  begin_op();
    800055c0:	c61fe0ef          	jal	80004220 <begin_op>

  if(omode & O_CREATE){
    800055c4:	f4c42783          	lw	a5,-180(s0)
    800055c8:	2007f793          	andi	a5,a5,512
    800055cc:	c3dd                	beqz	a5,80005672 <sys_open+0xdc>
    ip = create(path, T_FILE, 0, 0);
    800055ce:	4681                	li	a3,0
    800055d0:	4601                	li	a2,0
    800055d2:	4589                	li	a1,2
    800055d4:	f5040513          	addi	a0,s0,-176
    800055d8:	aafff0ef          	jal	80005086 <create>
    800055dc:	84aa                	mv	s1,a0
    if(ip == 0){
    800055de:	c549                	beqz	a0,80005668 <sys_open+0xd2>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    800055e0:	04449703          	lh	a4,68(s1)
    800055e4:	478d                	li	a5,3
    800055e6:	00f71763          	bne	a4,a5,800055f4 <sys_open+0x5e>
    800055ea:	0464d703          	lhu	a4,70(s1)
    800055ee:	47a5                	li	a5,9
    800055f0:	0ae7ee63          	bltu	a5,a4,800056ac <sys_open+0x116>
    800055f4:	f14a                	sd	s2,160(sp)
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    800055f6:	fabfe0ef          	jal	800045a0 <filealloc>
    800055fa:	892a                	mv	s2,a0
    800055fc:	c561                	beqz	a0,800056c4 <sys_open+0x12e>
    800055fe:	ed4e                	sd	s3,152(sp)
    80005600:	a47ff0ef          	jal	80005046 <fdalloc>
    80005604:	89aa                	mv	s3,a0
    80005606:	0a054b63          	bltz	a0,800056bc <sys_open+0x126>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    8000560a:	04449703          	lh	a4,68(s1)
    8000560e:	478d                	li	a5,3
    80005610:	0cf70363          	beq	a4,a5,800056d6 <sys_open+0x140>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80005614:	4789                	li	a5,2
    80005616:	00f92023          	sw	a5,0(s2)
    f->off = 0;
    8000561a:	02092023          	sw	zero,32(s2)
  }
  f->ip = ip;
    8000561e:	00993c23          	sd	s1,24(s2)
  f->readable = !(omode & O_WRONLY);
    80005622:	f4c42783          	lw	a5,-180(s0)
    80005626:	0017f713          	andi	a4,a5,1
    8000562a:	00174713          	xori	a4,a4,1
    8000562e:	00e90423          	sb	a4,8(s2)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80005632:	0037f713          	andi	a4,a5,3
    80005636:	00e03733          	snez	a4,a4
    8000563a:	00e904a3          	sb	a4,9(s2)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    8000563e:	4007f793          	andi	a5,a5,1024
    80005642:	c791                	beqz	a5,8000564e <sys_open+0xb8>
    80005644:	04449703          	lh	a4,68(s1)
    80005648:	4789                	li	a5,2
    8000564a:	08f70d63          	beq	a4,a5,800056e4 <sys_open+0x14e>
    itrunc(ip);
  }

  iunlock(ip);
    8000564e:	8526                	mv	a0,s1
    80005650:	a72fe0ef          	jal	800038c2 <iunlock>
  end_op();
    80005654:	c3dfe0ef          	jal	80004290 <end_op>

  return fd;
    80005658:	854e                	mv	a0,s3
    8000565a:	74aa                	ld	s1,168(sp)
    8000565c:	790a                	ld	s2,160(sp)
    8000565e:	69ea                	ld	s3,152(sp)
}
    80005660:	70ea                	ld	ra,184(sp)
    80005662:	744a                	ld	s0,176(sp)
    80005664:	6129                	addi	sp,sp,192
    80005666:	8082                	ret
      end_op();
    80005668:	c29fe0ef          	jal	80004290 <end_op>
      return -1;
    8000566c:	557d                	li	a0,-1
    8000566e:	74aa                	ld	s1,168(sp)
    80005670:	bfc5                	j	80005660 <sys_open+0xca>
    if((ip = namei(path)) == 0){
    80005672:	f5040513          	addi	a0,s0,-176
    80005676:	9cdfe0ef          	jal	80004042 <namei>
    8000567a:	84aa                	mv	s1,a0
    8000567c:	c11d                	beqz	a0,800056a2 <sys_open+0x10c>
    ilock(ip);
    8000567e:	996fe0ef          	jal	80003814 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80005682:	04449703          	lh	a4,68(s1)
    80005686:	4785                	li	a5,1
    80005688:	f4f71ce3          	bne	a4,a5,800055e0 <sys_open+0x4a>
    8000568c:	f4c42783          	lw	a5,-180(s0)
    80005690:	d3b5                	beqz	a5,800055f4 <sys_open+0x5e>
      iunlockput(ip);
    80005692:	8526                	mv	a0,s1
    80005694:	b8cfe0ef          	jal	80003a20 <iunlockput>
      end_op();
    80005698:	bf9fe0ef          	jal	80004290 <end_op>
      return -1;
    8000569c:	557d                	li	a0,-1
    8000569e:	74aa                	ld	s1,168(sp)
    800056a0:	b7c1                	j	80005660 <sys_open+0xca>
      end_op();
    800056a2:	beffe0ef          	jal	80004290 <end_op>
      return -1;
    800056a6:	557d                	li	a0,-1
    800056a8:	74aa                	ld	s1,168(sp)
    800056aa:	bf5d                	j	80005660 <sys_open+0xca>
    iunlockput(ip);
    800056ac:	8526                	mv	a0,s1
    800056ae:	b72fe0ef          	jal	80003a20 <iunlockput>
    end_op();
    800056b2:	bdffe0ef          	jal	80004290 <end_op>
    return -1;
    800056b6:	557d                	li	a0,-1
    800056b8:	74aa                	ld	s1,168(sp)
    800056ba:	b75d                	j	80005660 <sys_open+0xca>
      fileclose(f);
    800056bc:	854a                	mv	a0,s2
    800056be:	f87fe0ef          	jal	80004644 <fileclose>
    800056c2:	69ea                	ld	s3,152(sp)
    iunlockput(ip);
    800056c4:	8526                	mv	a0,s1
    800056c6:	b5afe0ef          	jal	80003a20 <iunlockput>
    end_op();
    800056ca:	bc7fe0ef          	jal	80004290 <end_op>
    return -1;
    800056ce:	557d                	li	a0,-1
    800056d0:	74aa                	ld	s1,168(sp)
    800056d2:	790a                	ld	s2,160(sp)
    800056d4:	b771                	j	80005660 <sys_open+0xca>
    f->type = FD_DEVICE;
    800056d6:	00e92023          	sw	a4,0(s2)
    f->major = ip->major;
    800056da:	04649783          	lh	a5,70(s1)
    800056de:	02f91223          	sh	a5,36(s2)
    800056e2:	bf35                	j	8000561e <sys_open+0x88>
    itrunc(ip);
    800056e4:	8526                	mv	a0,s1
    800056e6:	a1cfe0ef          	jal	80003902 <itrunc>
    800056ea:	b795                	j	8000564e <sys_open+0xb8>

00000000800056ec <sys_mkdir>:

uint64
sys_mkdir(void)
{
    800056ec:	7175                	addi	sp,sp,-144
    800056ee:	e506                	sd	ra,136(sp)
    800056f0:	e122                	sd	s0,128(sp)
    800056f2:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    800056f4:	b2dfe0ef          	jal	80004220 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    800056f8:	08000613          	li	a2,128
    800056fc:	f7040593          	addi	a1,s0,-144
    80005700:	4501                	li	a0,0
    80005702:	eaefd0ef          	jal	80002db0 <argstr>
    80005706:	02054363          	bltz	a0,8000572c <sys_mkdir+0x40>
    8000570a:	4681                	li	a3,0
    8000570c:	4601                	li	a2,0
    8000570e:	4585                	li	a1,1
    80005710:	f7040513          	addi	a0,s0,-144
    80005714:	973ff0ef          	jal	80005086 <create>
    80005718:	c911                	beqz	a0,8000572c <sys_mkdir+0x40>
    end_op();
    return -1;
  }
  iunlockput(ip);
    8000571a:	b06fe0ef          	jal	80003a20 <iunlockput>
  end_op();
    8000571e:	b73fe0ef          	jal	80004290 <end_op>
  return 0;
    80005722:	4501                	li	a0,0
}
    80005724:	60aa                	ld	ra,136(sp)
    80005726:	640a                	ld	s0,128(sp)
    80005728:	6149                	addi	sp,sp,144
    8000572a:	8082                	ret
    end_op();
    8000572c:	b65fe0ef          	jal	80004290 <end_op>
    return -1;
    80005730:	557d                	li	a0,-1
    80005732:	bfcd                	j	80005724 <sys_mkdir+0x38>

0000000080005734 <sys_mknod>:

uint64
sys_mknod(void)
{
    80005734:	7135                	addi	sp,sp,-160
    80005736:	ed06                	sd	ra,152(sp)
    80005738:	e922                	sd	s0,144(sp)
    8000573a:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    8000573c:	ae5fe0ef          	jal	80004220 <begin_op>
  argint(1, &major);
    80005740:	f6c40593          	addi	a1,s0,-148
    80005744:	4505                	li	a0,1
    80005746:	e32fd0ef          	jal	80002d78 <argint>
  argint(2, &minor);
    8000574a:	f6840593          	addi	a1,s0,-152
    8000574e:	4509                	li	a0,2
    80005750:	e28fd0ef          	jal	80002d78 <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005754:	08000613          	li	a2,128
    80005758:	f7040593          	addi	a1,s0,-144
    8000575c:	4501                	li	a0,0
    8000575e:	e52fd0ef          	jal	80002db0 <argstr>
    80005762:	02054563          	bltz	a0,8000578c <sys_mknod+0x58>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80005766:	f6841683          	lh	a3,-152(s0)
    8000576a:	f6c41603          	lh	a2,-148(s0)
    8000576e:	458d                	li	a1,3
    80005770:	f7040513          	addi	a0,s0,-144
    80005774:	913ff0ef          	jal	80005086 <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005778:	c911                	beqz	a0,8000578c <sys_mknod+0x58>
    end_op();
    return -1;
  }
  iunlockput(ip);
    8000577a:	aa6fe0ef          	jal	80003a20 <iunlockput>
  end_op();
    8000577e:	b13fe0ef          	jal	80004290 <end_op>
  return 0;
    80005782:	4501                	li	a0,0
}
    80005784:	60ea                	ld	ra,152(sp)
    80005786:	644a                	ld	s0,144(sp)
    80005788:	610d                	addi	sp,sp,160
    8000578a:	8082                	ret
    end_op();
    8000578c:	b05fe0ef          	jal	80004290 <end_op>
    return -1;
    80005790:	557d                	li	a0,-1
    80005792:	bfcd                	j	80005784 <sys_mknod+0x50>

0000000080005794 <sys_chdir>:

uint64
sys_chdir(void)
{
    80005794:	7135                	addi	sp,sp,-160
    80005796:	ed06                	sd	ra,152(sp)
    80005798:	e922                	sd	s0,144(sp)
    8000579a:	e14a                	sd	s2,128(sp)
    8000579c:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    8000579e:	ca2fc0ef          	jal	80001c40 <myproc>
    800057a2:	892a                	mv	s2,a0
  
  begin_op();
    800057a4:	a7dfe0ef          	jal	80004220 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    800057a8:	08000613          	li	a2,128
    800057ac:	f6040593          	addi	a1,s0,-160
    800057b0:	4501                	li	a0,0
    800057b2:	dfefd0ef          	jal	80002db0 <argstr>
    800057b6:	04054363          	bltz	a0,800057fc <sys_chdir+0x68>
    800057ba:	e526                	sd	s1,136(sp)
    800057bc:	f6040513          	addi	a0,s0,-160
    800057c0:	883fe0ef          	jal	80004042 <namei>
    800057c4:	84aa                	mv	s1,a0
    800057c6:	c915                	beqz	a0,800057fa <sys_chdir+0x66>
    end_op();
    return -1;
  }
  ilock(ip);
    800057c8:	84cfe0ef          	jal	80003814 <ilock>
  if(ip->type != T_DIR){
    800057cc:	04449703          	lh	a4,68(s1)
    800057d0:	4785                	li	a5,1
    800057d2:	02f71963          	bne	a4,a5,80005804 <sys_chdir+0x70>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    800057d6:	8526                	mv	a0,s1
    800057d8:	8eafe0ef          	jal	800038c2 <iunlock>
  iput(p->cwd);
    800057dc:	15093503          	ld	a0,336(s2)
    800057e0:	9b6fe0ef          	jal	80003996 <iput>
  end_op();
    800057e4:	aadfe0ef          	jal	80004290 <end_op>
  p->cwd = ip;
    800057e8:	14993823          	sd	s1,336(s2)
  return 0;
    800057ec:	4501                	li	a0,0
    800057ee:	64aa                	ld	s1,136(sp)
}
    800057f0:	60ea                	ld	ra,152(sp)
    800057f2:	644a                	ld	s0,144(sp)
    800057f4:	690a                	ld	s2,128(sp)
    800057f6:	610d                	addi	sp,sp,160
    800057f8:	8082                	ret
    800057fa:	64aa                	ld	s1,136(sp)
    end_op();
    800057fc:	a95fe0ef          	jal	80004290 <end_op>
    return -1;
    80005800:	557d                	li	a0,-1
    80005802:	b7fd                	j	800057f0 <sys_chdir+0x5c>
    iunlockput(ip);
    80005804:	8526                	mv	a0,s1
    80005806:	a1afe0ef          	jal	80003a20 <iunlockput>
    end_op();
    8000580a:	a87fe0ef          	jal	80004290 <end_op>
    return -1;
    8000580e:	557d                	li	a0,-1
    80005810:	64aa                	ld	s1,136(sp)
    80005812:	bff9                	j	800057f0 <sys_chdir+0x5c>

0000000080005814 <sys_exec>:

uint64
sys_exec(void)
{
    80005814:	7105                	addi	sp,sp,-480
    80005816:	ef86                	sd	ra,472(sp)
    80005818:	eba2                	sd	s0,464(sp)
    8000581a:	1380                	addi	s0,sp,480
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    8000581c:	e2840593          	addi	a1,s0,-472
    80005820:	4505                	li	a0,1
    80005822:	d72fd0ef          	jal	80002d94 <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    80005826:	08000613          	li	a2,128
    8000582a:	f3040593          	addi	a1,s0,-208
    8000582e:	4501                	li	a0,0
    80005830:	d80fd0ef          	jal	80002db0 <argstr>
    80005834:	87aa                	mv	a5,a0
    return -1;
    80005836:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    80005838:	0e07c063          	bltz	a5,80005918 <sys_exec+0x104>
    8000583c:	e7a6                	sd	s1,456(sp)
    8000583e:	e3ca                	sd	s2,448(sp)
    80005840:	ff4e                	sd	s3,440(sp)
    80005842:	fb52                	sd	s4,432(sp)
    80005844:	f756                	sd	s5,424(sp)
    80005846:	f35a                	sd	s6,416(sp)
    80005848:	ef5e                	sd	s7,408(sp)
  }
  memset(argv, 0, sizeof(argv));
    8000584a:	e3040a13          	addi	s4,s0,-464
    8000584e:	10000613          	li	a2,256
    80005852:	4581                	li	a1,0
    80005854:	8552                	mv	a0,s4
    80005856:	d9cfb0ef          	jal	80000df2 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    8000585a:	84d2                	mv	s1,s4
  memset(argv, 0, sizeof(argv));
    8000585c:	89d2                	mv	s3,s4
    8000585e:	4901                	li	s2,0
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80005860:	e2040a93          	addi	s5,s0,-480
      break;
    }
    argv[i] = kalloc();
    if(argv[i] == 0)
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80005864:	6b05                	lui	s6,0x1
    if(i >= NELEM(argv)){
    80005866:	02000b93          	li	s7,32
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    8000586a:	00391513          	slli	a0,s2,0x3
    8000586e:	85d6                	mv	a1,s5
    80005870:	e2843783          	ld	a5,-472(s0)
    80005874:	953e                	add	a0,a0,a5
    80005876:	c78fd0ef          	jal	80002cee <fetchaddr>
    8000587a:	02054663          	bltz	a0,800058a6 <sys_exec+0x92>
    if(uarg == 0){
    8000587e:	e2043783          	ld	a5,-480(s0)
    80005882:	c7a1                	beqz	a5,800058ca <sys_exec+0xb6>
    argv[i] = kalloc();
    80005884:	b56fb0ef          	jal	80000bda <kalloc>
    80005888:	85aa                	mv	a1,a0
    8000588a:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    8000588e:	cd01                	beqz	a0,800058a6 <sys_exec+0x92>
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80005890:	865a                	mv	a2,s6
    80005892:	e2043503          	ld	a0,-480(s0)
    80005896:	ca2fd0ef          	jal	80002d38 <fetchstr>
    8000589a:	00054663          	bltz	a0,800058a6 <sys_exec+0x92>
    if(i >= NELEM(argv)){
    8000589e:	0905                	addi	s2,s2,1
    800058a0:	09a1                	addi	s3,s3,8
    800058a2:	fd7914e3          	bne	s2,s7,8000586a <sys_exec+0x56>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800058a6:	100a0a13          	addi	s4,s4,256
    800058aa:	6088                	ld	a0,0(s1)
    800058ac:	cd31                	beqz	a0,80005908 <sys_exec+0xf4>
    kfree(argv[i]);
    800058ae:	9e0fb0ef          	jal	80000a8e <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800058b2:	04a1                	addi	s1,s1,8
    800058b4:	ff449be3          	bne	s1,s4,800058aa <sys_exec+0x96>
  return -1;
    800058b8:	557d                	li	a0,-1
    800058ba:	64be                	ld	s1,456(sp)
    800058bc:	691e                	ld	s2,448(sp)
    800058be:	79fa                	ld	s3,440(sp)
    800058c0:	7a5a                	ld	s4,432(sp)
    800058c2:	7aba                	ld	s5,424(sp)
    800058c4:	7b1a                	ld	s6,416(sp)
    800058c6:	6bfa                	ld	s7,408(sp)
    800058c8:	a881                	j	80005918 <sys_exec+0x104>
      argv[i] = 0;
    800058ca:	0009079b          	sext.w	a5,s2
    800058ce:	e3040593          	addi	a1,s0,-464
    800058d2:	078e                	slli	a5,a5,0x3
    800058d4:	97ae                	add	a5,a5,a1
    800058d6:	0007b023          	sd	zero,0(a5)
  int ret = kexec(path, argv);
    800058da:	f3040513          	addi	a0,s0,-208
    800058de:	bb2ff0ef          	jal	80004c90 <kexec>
    800058e2:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800058e4:	100a0a13          	addi	s4,s4,256
    800058e8:	6088                	ld	a0,0(s1)
    800058ea:	c511                	beqz	a0,800058f6 <sys_exec+0xe2>
    kfree(argv[i]);
    800058ec:	9a2fb0ef          	jal	80000a8e <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800058f0:	04a1                	addi	s1,s1,8
    800058f2:	ff449be3          	bne	s1,s4,800058e8 <sys_exec+0xd4>
  return ret;
    800058f6:	854a                	mv	a0,s2
    800058f8:	64be                	ld	s1,456(sp)
    800058fa:	691e                	ld	s2,448(sp)
    800058fc:	79fa                	ld	s3,440(sp)
    800058fe:	7a5a                	ld	s4,432(sp)
    80005900:	7aba                	ld	s5,424(sp)
    80005902:	7b1a                	ld	s6,416(sp)
    80005904:	6bfa                	ld	s7,408(sp)
    80005906:	a809                	j	80005918 <sys_exec+0x104>
  return -1;
    80005908:	557d                	li	a0,-1
    8000590a:	64be                	ld	s1,456(sp)
    8000590c:	691e                	ld	s2,448(sp)
    8000590e:	79fa                	ld	s3,440(sp)
    80005910:	7a5a                	ld	s4,432(sp)
    80005912:	7aba                	ld	s5,424(sp)
    80005914:	7b1a                	ld	s6,416(sp)
    80005916:	6bfa                	ld	s7,408(sp)
}
    80005918:	60fe                	ld	ra,472(sp)
    8000591a:	645e                	ld	s0,464(sp)
    8000591c:	613d                	addi	sp,sp,480
    8000591e:	8082                	ret

0000000080005920 <sys_pipe>:

uint64
sys_pipe(void)
{
    80005920:	7139                	addi	sp,sp,-64
    80005922:	fc06                	sd	ra,56(sp)
    80005924:	f822                	sd	s0,48(sp)
    80005926:	f426                	sd	s1,40(sp)
    80005928:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    8000592a:	b16fc0ef          	jal	80001c40 <myproc>
    8000592e:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    80005930:	fd840593          	addi	a1,s0,-40
    80005934:	4501                	li	a0,0
    80005936:	c5efd0ef          	jal	80002d94 <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    8000593a:	fc840593          	addi	a1,s0,-56
    8000593e:	fd040513          	addi	a0,s0,-48
    80005942:	81eff0ef          	jal	80004960 <pipealloc>
    return -1;
    80005946:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80005948:	0a054763          	bltz	a0,800059f6 <sys_pipe+0xd6>
  fd0 = -1;
    8000594c:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80005950:	fd043503          	ld	a0,-48(s0)
    80005954:	ef2ff0ef          	jal	80005046 <fdalloc>
    80005958:	fca42223          	sw	a0,-60(s0)
    8000595c:	08054463          	bltz	a0,800059e4 <sys_pipe+0xc4>
    80005960:	fc843503          	ld	a0,-56(s0)
    80005964:	ee2ff0ef          	jal	80005046 <fdalloc>
    80005968:	fca42023          	sw	a0,-64(s0)
    8000596c:	06054263          	bltz	a0,800059d0 <sys_pipe+0xb0>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005970:	4691                	li	a3,4
    80005972:	fc440613          	addi	a2,s0,-60
    80005976:	fd843583          	ld	a1,-40(s0)
    8000597a:	68a8                	ld	a0,80(s1)
    8000597c:	fd7fb0ef          	jal	80001952 <copyout>
    80005980:	00054e63          	bltz	a0,8000599c <sys_pipe+0x7c>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80005984:	4691                	li	a3,4
    80005986:	fc040613          	addi	a2,s0,-64
    8000598a:	fd843583          	ld	a1,-40(s0)
    8000598e:	95b6                	add	a1,a1,a3
    80005990:	68a8                	ld	a0,80(s1)
    80005992:	fc1fb0ef          	jal	80001952 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80005996:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005998:	04055f63          	bgez	a0,800059f6 <sys_pipe+0xd6>
    p->ofile[fd0] = 0;
    8000599c:	fc442783          	lw	a5,-60(s0)
    800059a0:	078e                	slli	a5,a5,0x3
    800059a2:	0d078793          	addi	a5,a5,208
    800059a6:	97a6                	add	a5,a5,s1
    800059a8:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    800059ac:	fc042783          	lw	a5,-64(s0)
    800059b0:	078e                	slli	a5,a5,0x3
    800059b2:	0d078793          	addi	a5,a5,208
    800059b6:	97a6                	add	a5,a5,s1
    800059b8:	0007b023          	sd	zero,0(a5)
    fileclose(rf);
    800059bc:	fd043503          	ld	a0,-48(s0)
    800059c0:	c85fe0ef          	jal	80004644 <fileclose>
    fileclose(wf);
    800059c4:	fc843503          	ld	a0,-56(s0)
    800059c8:	c7dfe0ef          	jal	80004644 <fileclose>
    return -1;
    800059cc:	57fd                	li	a5,-1
    800059ce:	a025                	j	800059f6 <sys_pipe+0xd6>
    if(fd0 >= 0)
    800059d0:	fc442783          	lw	a5,-60(s0)
    800059d4:	0007c863          	bltz	a5,800059e4 <sys_pipe+0xc4>
      p->ofile[fd0] = 0;
    800059d8:	078e                	slli	a5,a5,0x3
    800059da:	0d078793          	addi	a5,a5,208
    800059de:	97a6                	add	a5,a5,s1
    800059e0:	0007b023          	sd	zero,0(a5)
    fileclose(rf);
    800059e4:	fd043503          	ld	a0,-48(s0)
    800059e8:	c5dfe0ef          	jal	80004644 <fileclose>
    fileclose(wf);
    800059ec:	fc843503          	ld	a0,-56(s0)
    800059f0:	c55fe0ef          	jal	80004644 <fileclose>
    return -1;
    800059f4:	57fd                	li	a5,-1
}
    800059f6:	853e                	mv	a0,a5
    800059f8:	70e2                	ld	ra,56(sp)
    800059fa:	7442                	ld	s0,48(sp)
    800059fc:	74a2                	ld	s1,40(sp)
    800059fe:	6121                	addi	sp,sp,64
    80005a00:	8082                	ret

0000000080005a02 <sys_fsread>:
uint64
sys_fsread(void)
{
    80005a02:	1101                	addi	sp,sp,-32
    80005a04:	ec06                	sd	ra,24(sp)
    80005a06:	e822                	sd	s0,16(sp)
    80005a08:	1000                	addi	s0,sp,32
  uint64 addr;
  int n;

  // استدعاء الدوال بدون مقارنتها بـ < 0 لأنها تعيد void
  argaddr(0, &addr); 
    80005a0a:	fe840593          	addi	a1,s0,-24
    80005a0e:	4501                	li	a0,0
    80005a10:	b84fd0ef          	jal	80002d94 <argaddr>
  argint(1, &n);
    80005a14:	fe440593          	addi	a1,s0,-28
    80005a18:	4505                	li	a0,1
    80005a1a:	b5efd0ef          	jal	80002d78 <argint>

  // استدعاء الوظيفة الحقيقية وإعادة نتيجتها
  return fslog_read_many((struct fs_event *)addr, n);
    80005a1e:	fe442583          	lw	a1,-28(s0)
    80005a22:	fe843503          	ld	a0,-24(s0)
    80005a26:	207000ef          	jal	8000642c <fslog_read_many>
    80005a2a:	60e2                	ld	ra,24(sp)
    80005a2c:	6442                	ld	s0,16(sp)
    80005a2e:	6105                	addi	sp,sp,32
    80005a30:	8082                	ret
	...

0000000080005a40 <kernelvec>:
.globl kerneltrap
.globl kernelvec
.align 4
kernelvec:
        # make room to save registers.
        addi sp, sp, -256
    80005a40:	7111                	addi	sp,sp,-256

        # save caller-saved registers.
        sd ra, 0(sp)
    80005a42:	e006                	sd	ra,0(sp)
        # sd sp, 8(sp)
        sd gp, 16(sp)
    80005a44:	e80e                	sd	gp,16(sp)
        sd tp, 24(sp)
    80005a46:	ec12                	sd	tp,24(sp)
        sd t0, 32(sp)
    80005a48:	f016                	sd	t0,32(sp)
        sd t1, 40(sp)
    80005a4a:	f41a                	sd	t1,40(sp)
        sd t2, 48(sp)
    80005a4c:	f81e                	sd	t2,48(sp)
        sd a0, 72(sp)
    80005a4e:	e4aa                	sd	a0,72(sp)
        sd a1, 80(sp)
    80005a50:	e8ae                	sd	a1,80(sp)
        sd a2, 88(sp)
    80005a52:	ecb2                	sd	a2,88(sp)
        sd a3, 96(sp)
    80005a54:	f0b6                	sd	a3,96(sp)
        sd a4, 104(sp)
    80005a56:	f4ba                	sd	a4,104(sp)
        sd a5, 112(sp)
    80005a58:	f8be                	sd	a5,112(sp)
        sd a6, 120(sp)
    80005a5a:	fcc2                	sd	a6,120(sp)
        sd a7, 128(sp)
    80005a5c:	e146                	sd	a7,128(sp)
        sd t3, 216(sp)
    80005a5e:	edf2                	sd	t3,216(sp)
        sd t4, 224(sp)
    80005a60:	f1f6                	sd	t4,224(sp)
        sd t5, 232(sp)
    80005a62:	f5fa                	sd	t5,232(sp)
        sd t6, 240(sp)
    80005a64:	f9fe                	sd	t6,240(sp)

        # call the C trap handler in trap.c
        call kerneltrap
    80005a66:	996fd0ef          	jal	80002bfc <kerneltrap>

        # restore registers.
        ld ra, 0(sp)
    80005a6a:	6082                	ld	ra,0(sp)
        # ld sp, 8(sp)
        ld gp, 16(sp)
    80005a6c:	61c2                	ld	gp,16(sp)
        # not tp (contains hartid), in case we moved CPUs
        ld t0, 32(sp)
    80005a6e:	7282                	ld	t0,32(sp)
        ld t1, 40(sp)
    80005a70:	7322                	ld	t1,40(sp)
        ld t2, 48(sp)
    80005a72:	73c2                	ld	t2,48(sp)
        ld a0, 72(sp)
    80005a74:	6526                	ld	a0,72(sp)
        ld a1, 80(sp)
    80005a76:	65c6                	ld	a1,80(sp)
        ld a2, 88(sp)
    80005a78:	6666                	ld	a2,88(sp)
        ld a3, 96(sp)
    80005a7a:	7686                	ld	a3,96(sp)
        ld a4, 104(sp)
    80005a7c:	7726                	ld	a4,104(sp)
        ld a5, 112(sp)
    80005a7e:	77c6                	ld	a5,112(sp)
        ld a6, 120(sp)
    80005a80:	7866                	ld	a6,120(sp)
        ld a7, 128(sp)
    80005a82:	688a                	ld	a7,128(sp)
        ld t3, 216(sp)
    80005a84:	6e6e                	ld	t3,216(sp)
        ld t4, 224(sp)
    80005a86:	7e8e                	ld	t4,224(sp)
        ld t5, 232(sp)
    80005a88:	7f2e                	ld	t5,232(sp)
        ld t6, 240(sp)
    80005a8a:	7fce                	ld	t6,240(sp)

        addi sp, sp, 256
    80005a8c:	6111                	addi	sp,sp,256

        # return to whatever we were doing in the kernel.
        sret
    80005a8e:	10200073          	sret
    80005a92:	00000013          	nop
    80005a96:	00000013          	nop
    80005a9a:	00000013          	nop

0000000080005a9e <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    80005a9e:	1141                	addi	sp,sp,-16
    80005aa0:	e406                	sd	ra,8(sp)
    80005aa2:	e022                	sd	s0,0(sp)
    80005aa4:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80005aa6:	0c000737          	lui	a4,0xc000
    80005aaa:	4785                	li	a5,1
    80005aac:	d71c                	sw	a5,40(a4)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    80005aae:	c35c                	sw	a5,4(a4)
}
    80005ab0:	60a2                	ld	ra,8(sp)
    80005ab2:	6402                	ld	s0,0(sp)
    80005ab4:	0141                	addi	sp,sp,16
    80005ab6:	8082                	ret

0000000080005ab8 <plicinithart>:

void
plicinithart(void)
{
    80005ab8:	1141                	addi	sp,sp,-16
    80005aba:	e406                	sd	ra,8(sp)
    80005abc:	e022                	sd	s0,0(sp)
    80005abe:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005ac0:	94cfc0ef          	jal	80001c0c <cpuid>
  
  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80005ac4:	0085171b          	slliw	a4,a0,0x8
    80005ac8:	0c0027b7          	lui	a5,0xc002
    80005acc:	97ba                	add	a5,a5,a4
    80005ace:	40200713          	li	a4,1026
    80005ad2:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80005ad6:	00d5151b          	slliw	a0,a0,0xd
    80005ada:	0c2017b7          	lui	a5,0xc201
    80005ade:	97aa                	add	a5,a5,a0
    80005ae0:	0007a023          	sw	zero,0(a5) # c201000 <_entry-0x73dff000>
}
    80005ae4:	60a2                	ld	ra,8(sp)
    80005ae6:	6402                	ld	s0,0(sp)
    80005ae8:	0141                	addi	sp,sp,16
    80005aea:	8082                	ret

0000000080005aec <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    80005aec:	1141                	addi	sp,sp,-16
    80005aee:	e406                	sd	ra,8(sp)
    80005af0:	e022                	sd	s0,0(sp)
    80005af2:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005af4:	918fc0ef          	jal	80001c0c <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80005af8:	00d5151b          	slliw	a0,a0,0xd
    80005afc:	0c2017b7          	lui	a5,0xc201
    80005b00:	97aa                	add	a5,a5,a0
  return irq;
}
    80005b02:	43c8                	lw	a0,4(a5)
    80005b04:	60a2                	ld	ra,8(sp)
    80005b06:	6402                	ld	s0,0(sp)
    80005b08:	0141                	addi	sp,sp,16
    80005b0a:	8082                	ret

0000000080005b0c <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    80005b0c:	1101                	addi	sp,sp,-32
    80005b0e:	ec06                	sd	ra,24(sp)
    80005b10:	e822                	sd	s0,16(sp)
    80005b12:	e426                	sd	s1,8(sp)
    80005b14:	1000                	addi	s0,sp,32
    80005b16:	84aa                	mv	s1,a0
  int hart = cpuid();
    80005b18:	8f4fc0ef          	jal	80001c0c <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    80005b1c:	00d5179b          	slliw	a5,a0,0xd
    80005b20:	0c201737          	lui	a4,0xc201
    80005b24:	97ba                	add	a5,a5,a4
    80005b26:	c3c4                	sw	s1,4(a5)
}
    80005b28:	60e2                	ld	ra,24(sp)
    80005b2a:	6442                	ld	s0,16(sp)
    80005b2c:	64a2                	ld	s1,8(sp)
    80005b2e:	6105                	addi	sp,sp,32
    80005b30:	8082                	ret

0000000080005b32 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80005b32:	1141                	addi	sp,sp,-16
    80005b34:	e406                	sd	ra,8(sp)
    80005b36:	e022                	sd	s0,0(sp)
    80005b38:	0800                	addi	s0,sp,16
  if(i >= NUM)
    80005b3a:	479d                	li	a5,7
    80005b3c:	04a7ca63          	blt	a5,a0,80005b90 <free_desc+0x5e>
    panic("free_desc 1");
  if(disk.free[i])
    80005b40:	0001d797          	auipc	a5,0x1d
    80005b44:	6d078793          	addi	a5,a5,1744 # 80023210 <disk>
    80005b48:	97aa                	add	a5,a5,a0
    80005b4a:	0187c783          	lbu	a5,24(a5)
    80005b4e:	e7b9                	bnez	a5,80005b9c <free_desc+0x6a>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    80005b50:	00451693          	slli	a3,a0,0x4
    80005b54:	0001d797          	auipc	a5,0x1d
    80005b58:	6bc78793          	addi	a5,a5,1724 # 80023210 <disk>
    80005b5c:	6398                	ld	a4,0(a5)
    80005b5e:	9736                	add	a4,a4,a3
    80005b60:	00073023          	sd	zero,0(a4) # c201000 <_entry-0x73dff000>
  disk.desc[i].len = 0;
    80005b64:	6398                	ld	a4,0(a5)
    80005b66:	9736                	add	a4,a4,a3
    80005b68:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    80005b6c:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    80005b70:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    80005b74:	97aa                	add	a5,a5,a0
    80005b76:	4705                	li	a4,1
    80005b78:	00e78c23          	sb	a4,24(a5)
  wakeup(&disk.free[0]);
    80005b7c:	0001d517          	auipc	a0,0x1d
    80005b80:	6ac50513          	addi	a0,a0,1708 # 80023228 <disk+0x18>
    80005b84:	935fc0ef          	jal	800024b8 <wakeup>
}
    80005b88:	60a2                	ld	ra,8(sp)
    80005b8a:	6402                	ld	s0,0(sp)
    80005b8c:	0141                	addi	sp,sp,16
    80005b8e:	8082                	ret
    panic("free_desc 1");
    80005b90:	00003517          	auipc	a0,0x3
    80005b94:	ab850513          	addi	a0,a0,-1352 # 80008648 <etext+0x648>
    80005b98:	cbffa0ef          	jal	80000856 <panic>
    panic("free_desc 2");
    80005b9c:	00003517          	auipc	a0,0x3
    80005ba0:	abc50513          	addi	a0,a0,-1348 # 80008658 <etext+0x658>
    80005ba4:	cb3fa0ef          	jal	80000856 <panic>

0000000080005ba8 <virtio_disk_init>:
{
    80005ba8:	1101                	addi	sp,sp,-32
    80005baa:	ec06                	sd	ra,24(sp)
    80005bac:	e822                	sd	s0,16(sp)
    80005bae:	e426                	sd	s1,8(sp)
    80005bb0:	e04a                	sd	s2,0(sp)
    80005bb2:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80005bb4:	00003597          	auipc	a1,0x3
    80005bb8:	ab458593          	addi	a1,a1,-1356 # 80008668 <etext+0x668>
    80005bbc:	0001d517          	auipc	a0,0x1d
    80005bc0:	77c50513          	addi	a0,a0,1916 # 80023338 <disk+0x128>
    80005bc4:	8d4fb0ef          	jal	80000c98 <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005bc8:	100017b7          	lui	a5,0x10001
    80005bcc:	4398                	lw	a4,0(a5)
    80005bce:	2701                	sext.w	a4,a4
    80005bd0:	747277b7          	lui	a5,0x74727
    80005bd4:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    80005bd8:	14f71863          	bne	a4,a5,80005d28 <virtio_disk_init+0x180>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80005bdc:	100017b7          	lui	a5,0x10001
    80005be0:	43dc                	lw	a5,4(a5)
    80005be2:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005be4:	4709                	li	a4,2
    80005be6:	14e79163          	bne	a5,a4,80005d28 <virtio_disk_init+0x180>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005bea:	100017b7          	lui	a5,0x10001
    80005bee:	479c                	lw	a5,8(a5)
    80005bf0:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80005bf2:	12e79b63          	bne	a5,a4,80005d28 <virtio_disk_init+0x180>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    80005bf6:	100017b7          	lui	a5,0x10001
    80005bfa:	47d8                	lw	a4,12(a5)
    80005bfc:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005bfe:	554d47b7          	lui	a5,0x554d4
    80005c02:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    80005c06:	12f71163          	bne	a4,a5,80005d28 <virtio_disk_init+0x180>
  *R(VIRTIO_MMIO_STATUS) = status;
    80005c0a:	100017b7          	lui	a5,0x10001
    80005c0e:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    80005c12:	4705                	li	a4,1
    80005c14:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005c16:	470d                	li	a4,3
    80005c18:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    80005c1a:	10001737          	lui	a4,0x10001
    80005c1e:	4b18                	lw	a4,16(a4)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    80005c20:	c7ffe6b7          	lui	a3,0xc7ffe
    80005c24:	75f68693          	addi	a3,a3,1887 # ffffffffc7ffe75f <end+0xffffffff47fb6367>
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80005c28:	8f75                	and	a4,a4,a3
    80005c2a:	100016b7          	lui	a3,0x10001
    80005c2e:	d298                	sw	a4,32(a3)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005c30:	472d                	li	a4,11
    80005c32:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005c34:	07078793          	addi	a5,a5,112
  status = *R(VIRTIO_MMIO_STATUS);
    80005c38:	439c                	lw	a5,0(a5)
    80005c3a:	0007891b          	sext.w	s2,a5
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    80005c3e:	8ba1                	andi	a5,a5,8
    80005c40:	0e078a63          	beqz	a5,80005d34 <virtio_disk_init+0x18c>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80005c44:	100017b7          	lui	a5,0x10001
    80005c48:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    80005c4c:	43fc                	lw	a5,68(a5)
    80005c4e:	2781                	sext.w	a5,a5
    80005c50:	0e079863          	bnez	a5,80005d40 <virtio_disk_init+0x198>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    80005c54:	100017b7          	lui	a5,0x10001
    80005c58:	5bdc                	lw	a5,52(a5)
    80005c5a:	2781                	sext.w	a5,a5
  if(max == 0)
    80005c5c:	0e078863          	beqz	a5,80005d4c <virtio_disk_init+0x1a4>
  if(max < NUM)
    80005c60:	471d                	li	a4,7
    80005c62:	0ef77b63          	bgeu	a4,a5,80005d58 <virtio_disk_init+0x1b0>
  disk.desc = kalloc();
    80005c66:	f75fa0ef          	jal	80000bda <kalloc>
    80005c6a:	0001d497          	auipc	s1,0x1d
    80005c6e:	5a648493          	addi	s1,s1,1446 # 80023210 <disk>
    80005c72:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    80005c74:	f67fa0ef          	jal	80000bda <kalloc>
    80005c78:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    80005c7a:	f61fa0ef          	jal	80000bda <kalloc>
    80005c7e:	87aa                	mv	a5,a0
    80005c80:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    80005c82:	6088                	ld	a0,0(s1)
    80005c84:	0e050063          	beqz	a0,80005d64 <virtio_disk_init+0x1bc>
    80005c88:	0001d717          	auipc	a4,0x1d
    80005c8c:	59073703          	ld	a4,1424(a4) # 80023218 <disk+0x8>
    80005c90:	cb71                	beqz	a4,80005d64 <virtio_disk_init+0x1bc>
    80005c92:	cbe9                	beqz	a5,80005d64 <virtio_disk_init+0x1bc>
  memset(disk.desc, 0, PGSIZE);
    80005c94:	6605                	lui	a2,0x1
    80005c96:	4581                	li	a1,0
    80005c98:	95afb0ef          	jal	80000df2 <memset>
  memset(disk.avail, 0, PGSIZE);
    80005c9c:	0001d497          	auipc	s1,0x1d
    80005ca0:	57448493          	addi	s1,s1,1396 # 80023210 <disk>
    80005ca4:	6605                	lui	a2,0x1
    80005ca6:	4581                	li	a1,0
    80005ca8:	6488                	ld	a0,8(s1)
    80005caa:	948fb0ef          	jal	80000df2 <memset>
  memset(disk.used, 0, PGSIZE);
    80005cae:	6605                	lui	a2,0x1
    80005cb0:	4581                	li	a1,0
    80005cb2:	6888                	ld	a0,16(s1)
    80005cb4:	93efb0ef          	jal	80000df2 <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    80005cb8:	100017b7          	lui	a5,0x10001
    80005cbc:	4721                	li	a4,8
    80005cbe:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    80005cc0:	4098                	lw	a4,0(s1)
    80005cc2:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    80005cc6:	40d8                	lw	a4,4(s1)
    80005cc8:	08e7a223          	sw	a4,132(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    80005ccc:	649c                	ld	a5,8(s1)
    80005cce:	0007869b          	sext.w	a3,a5
    80005cd2:	10001737          	lui	a4,0x10001
    80005cd6:	08d72823          	sw	a3,144(a4) # 10001090 <_entry-0x6fffef70>
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    80005cda:	9781                	srai	a5,a5,0x20
    80005cdc:	08f72a23          	sw	a5,148(a4)
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    80005ce0:	689c                	ld	a5,16(s1)
    80005ce2:	0007869b          	sext.w	a3,a5
    80005ce6:	0ad72023          	sw	a3,160(a4)
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    80005cea:	9781                	srai	a5,a5,0x20
    80005cec:	0af72223          	sw	a5,164(a4)
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    80005cf0:	4785                	li	a5,1
    80005cf2:	c37c                	sw	a5,68(a4)
    disk.free[i] = 1;
    80005cf4:	00f48c23          	sb	a5,24(s1)
    80005cf8:	00f48ca3          	sb	a5,25(s1)
    80005cfc:	00f48d23          	sb	a5,26(s1)
    80005d00:	00f48da3          	sb	a5,27(s1)
    80005d04:	00f48e23          	sb	a5,28(s1)
    80005d08:	00f48ea3          	sb	a5,29(s1)
    80005d0c:	00f48f23          	sb	a5,30(s1)
    80005d10:	00f48fa3          	sb	a5,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    80005d14:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    80005d18:	07272823          	sw	s2,112(a4)
}
    80005d1c:	60e2                	ld	ra,24(sp)
    80005d1e:	6442                	ld	s0,16(sp)
    80005d20:	64a2                	ld	s1,8(sp)
    80005d22:	6902                	ld	s2,0(sp)
    80005d24:	6105                	addi	sp,sp,32
    80005d26:	8082                	ret
    panic("could not find virtio disk");
    80005d28:	00003517          	auipc	a0,0x3
    80005d2c:	95050513          	addi	a0,a0,-1712 # 80008678 <etext+0x678>
    80005d30:	b27fa0ef          	jal	80000856 <panic>
    panic("virtio disk FEATURES_OK unset");
    80005d34:	00003517          	auipc	a0,0x3
    80005d38:	96450513          	addi	a0,a0,-1692 # 80008698 <etext+0x698>
    80005d3c:	b1bfa0ef          	jal	80000856 <panic>
    panic("virtio disk should not be ready");
    80005d40:	00003517          	auipc	a0,0x3
    80005d44:	97850513          	addi	a0,a0,-1672 # 800086b8 <etext+0x6b8>
    80005d48:	b0ffa0ef          	jal	80000856 <panic>
    panic("virtio disk has no queue 0");
    80005d4c:	00003517          	auipc	a0,0x3
    80005d50:	98c50513          	addi	a0,a0,-1652 # 800086d8 <etext+0x6d8>
    80005d54:	b03fa0ef          	jal	80000856 <panic>
    panic("virtio disk max queue too short");
    80005d58:	00003517          	auipc	a0,0x3
    80005d5c:	9a050513          	addi	a0,a0,-1632 # 800086f8 <etext+0x6f8>
    80005d60:	af7fa0ef          	jal	80000856 <panic>
    panic("virtio disk kalloc");
    80005d64:	00003517          	auipc	a0,0x3
    80005d68:	9b450513          	addi	a0,a0,-1612 # 80008718 <etext+0x718>
    80005d6c:	aebfa0ef          	jal	80000856 <panic>

0000000080005d70 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80005d70:	711d                	addi	sp,sp,-96
    80005d72:	ec86                	sd	ra,88(sp)
    80005d74:	e8a2                	sd	s0,80(sp)
    80005d76:	e4a6                	sd	s1,72(sp)
    80005d78:	e0ca                	sd	s2,64(sp)
    80005d7a:	fc4e                	sd	s3,56(sp)
    80005d7c:	f852                	sd	s4,48(sp)
    80005d7e:	f456                	sd	s5,40(sp)
    80005d80:	f05a                	sd	s6,32(sp)
    80005d82:	ec5e                	sd	s7,24(sp)
    80005d84:	e862                	sd	s8,16(sp)
    80005d86:	1080                	addi	s0,sp,96
    80005d88:	89aa                	mv	s3,a0
    80005d8a:	8b2e                	mv	s6,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    80005d8c:	00c52b83          	lw	s7,12(a0)
    80005d90:	001b9b9b          	slliw	s7,s7,0x1
    80005d94:	1b82                	slli	s7,s7,0x20
    80005d96:	020bdb93          	srli	s7,s7,0x20

  acquire(&disk.vdisk_lock);
    80005d9a:	0001d517          	auipc	a0,0x1d
    80005d9e:	59e50513          	addi	a0,a0,1438 # 80023338 <disk+0x128>
    80005da2:	f81fa0ef          	jal	80000d22 <acquire>
  for(int i = 0; i < NUM; i++){
    80005da6:	44a1                	li	s1,8
      disk.free[i] = 0;
    80005da8:	0001da97          	auipc	s5,0x1d
    80005dac:	468a8a93          	addi	s5,s5,1128 # 80023210 <disk>
  for(int i = 0; i < 3; i++){
    80005db0:	4a0d                	li	s4,3
    idx[i] = alloc_desc();
    80005db2:	5c7d                	li	s8,-1
    80005db4:	a095                	j	80005e18 <virtio_disk_rw+0xa8>
      disk.free[i] = 0;
    80005db6:	00fa8733          	add	a4,s5,a5
    80005dba:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    80005dbe:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    80005dc0:	0207c563          	bltz	a5,80005dea <virtio_disk_rw+0x7a>
  for(int i = 0; i < 3; i++){
    80005dc4:	2905                	addiw	s2,s2,1
    80005dc6:	0611                	addi	a2,a2,4 # 1004 <_entry-0x7fffeffc>
    80005dc8:	05490c63          	beq	s2,s4,80005e20 <virtio_disk_rw+0xb0>
    idx[i] = alloc_desc();
    80005dcc:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    80005dce:	0001d717          	auipc	a4,0x1d
    80005dd2:	44270713          	addi	a4,a4,1090 # 80023210 <disk>
    80005dd6:	4781                	li	a5,0
    if(disk.free[i]){
    80005dd8:	01874683          	lbu	a3,24(a4)
    80005ddc:	fee9                	bnez	a3,80005db6 <virtio_disk_rw+0x46>
  for(int i = 0; i < NUM; i++){
    80005dde:	2785                	addiw	a5,a5,1
    80005de0:	0705                	addi	a4,a4,1
    80005de2:	fe979be3          	bne	a5,s1,80005dd8 <virtio_disk_rw+0x68>
    idx[i] = alloc_desc();
    80005de6:	0185a023          	sw	s8,0(a1)
      for(int j = 0; j < i; j++)
    80005dea:	01205d63          	blez	s2,80005e04 <virtio_disk_rw+0x94>
        free_desc(idx[j]);
    80005dee:	fa042503          	lw	a0,-96(s0)
    80005df2:	d41ff0ef          	jal	80005b32 <free_desc>
      for(int j = 0; j < i; j++)
    80005df6:	4785                	li	a5,1
    80005df8:	0127d663          	bge	a5,s2,80005e04 <virtio_disk_rw+0x94>
        free_desc(idx[j]);
    80005dfc:	fa442503          	lw	a0,-92(s0)
    80005e00:	d33ff0ef          	jal	80005b32 <free_desc>
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80005e04:	0001d597          	auipc	a1,0x1d
    80005e08:	53458593          	addi	a1,a1,1332 # 80023338 <disk+0x128>
    80005e0c:	0001d517          	auipc	a0,0x1d
    80005e10:	41c50513          	addi	a0,a0,1052 # 80023228 <disk+0x18>
    80005e14:	e58fc0ef          	jal	8000246c <sleep>
  for(int i = 0; i < 3; i++){
    80005e18:	fa040613          	addi	a2,s0,-96
    80005e1c:	4901                	li	s2,0
    80005e1e:	b77d                	j	80005dcc <virtio_disk_rw+0x5c>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80005e20:	fa042503          	lw	a0,-96(s0)
    80005e24:	00451693          	slli	a3,a0,0x4

  if(write)
    80005e28:	0001d797          	auipc	a5,0x1d
    80005e2c:	3e878793          	addi	a5,a5,1000 # 80023210 <disk>
    80005e30:	00451713          	slli	a4,a0,0x4
    80005e34:	0a070713          	addi	a4,a4,160
    80005e38:	973e                	add	a4,a4,a5
    80005e3a:	01603633          	snez	a2,s6
    80005e3e:	c710                	sw	a2,8(a4)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    80005e40:	00072623          	sw	zero,12(a4)
  buf0->sector = sector;
    80005e44:	01773823          	sd	s7,16(a4)

  disk.desc[idx[0]].addr = (uint64) buf0;
    80005e48:	6398                	ld	a4,0(a5)
    80005e4a:	9736                	add	a4,a4,a3
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80005e4c:	0a868613          	addi	a2,a3,168 # 100010a8 <_entry-0x6fffef58>
    80005e50:	963e                	add	a2,a2,a5
  disk.desc[idx[0]].addr = (uint64) buf0;
    80005e52:	e310                	sd	a2,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    80005e54:	6390                	ld	a2,0(a5)
    80005e56:	00d60833          	add	a6,a2,a3
    80005e5a:	4741                	li	a4,16
    80005e5c:	00e82423          	sw	a4,8(a6)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    80005e60:	4585                	li	a1,1
    80005e62:	00b81623          	sh	a1,12(a6)
  disk.desc[idx[0]].next = idx[1];
    80005e66:	fa442703          	lw	a4,-92(s0)
    80005e6a:	00e81723          	sh	a4,14(a6)

  disk.desc[idx[1]].addr = (uint64) b->data;
    80005e6e:	0712                	slli	a4,a4,0x4
    80005e70:	963a                	add	a2,a2,a4
    80005e72:	05898813          	addi	a6,s3,88
    80005e76:	01063023          	sd	a6,0(a2)
  disk.desc[idx[1]].len = BSIZE;
    80005e7a:	0007b883          	ld	a7,0(a5)
    80005e7e:	9746                	add	a4,a4,a7
    80005e80:	40000613          	li	a2,1024
    80005e84:	c710                	sw	a2,8(a4)
  if(write)
    80005e86:	001b3613          	seqz	a2,s6
    80005e8a:	0016161b          	slliw	a2,a2,0x1
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    80005e8e:	8e4d                	or	a2,a2,a1
    80005e90:	00c71623          	sh	a2,12(a4)
  disk.desc[idx[1]].next = idx[2];
    80005e94:	fa842603          	lw	a2,-88(s0)
    80005e98:	00c71723          	sh	a2,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    80005e9c:	00451813          	slli	a6,a0,0x4
    80005ea0:	02080813          	addi	a6,a6,32
    80005ea4:	983e                	add	a6,a6,a5
    80005ea6:	577d                	li	a4,-1
    80005ea8:	00e80823          	sb	a4,16(a6)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    80005eac:	0612                	slli	a2,a2,0x4
    80005eae:	98b2                	add	a7,a7,a2
    80005eb0:	03068713          	addi	a4,a3,48
    80005eb4:	973e                	add	a4,a4,a5
    80005eb6:	00e8b023          	sd	a4,0(a7)
  disk.desc[idx[2]].len = 1;
    80005eba:	6398                	ld	a4,0(a5)
    80005ebc:	9732                	add	a4,a4,a2
    80005ebe:	c70c                	sw	a1,8(a4)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    80005ec0:	4689                	li	a3,2
    80005ec2:	00d71623          	sh	a3,12(a4)
  disk.desc[idx[2]].next = 0;
    80005ec6:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    80005eca:	00b9a223          	sw	a1,4(s3)
  disk.info[idx[0]].b = b;
    80005ece:	01383423          	sd	s3,8(a6)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    80005ed2:	6794                	ld	a3,8(a5)
    80005ed4:	0026d703          	lhu	a4,2(a3)
    80005ed8:	8b1d                	andi	a4,a4,7
    80005eda:	0706                	slli	a4,a4,0x1
    80005edc:	96ba                	add	a3,a3,a4
    80005ede:	00a69223          	sh	a0,4(a3)

  __sync_synchronize();
    80005ee2:	0330000f          	fence	rw,rw

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    80005ee6:	6798                	ld	a4,8(a5)
    80005ee8:	00275783          	lhu	a5,2(a4)
    80005eec:	2785                	addiw	a5,a5,1
    80005eee:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    80005ef2:	0330000f          	fence	rw,rw

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80005ef6:	100017b7          	lui	a5,0x10001
    80005efa:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    80005efe:	0049a783          	lw	a5,4(s3)
    sleep(b, &disk.vdisk_lock);
    80005f02:	0001d917          	auipc	s2,0x1d
    80005f06:	43690913          	addi	s2,s2,1078 # 80023338 <disk+0x128>
  while(b->disk == 1) {
    80005f0a:	84ae                	mv	s1,a1
    80005f0c:	00b79a63          	bne	a5,a1,80005f20 <virtio_disk_rw+0x1b0>
    sleep(b, &disk.vdisk_lock);
    80005f10:	85ca                	mv	a1,s2
    80005f12:	854e                	mv	a0,s3
    80005f14:	d58fc0ef          	jal	8000246c <sleep>
  while(b->disk == 1) {
    80005f18:	0049a783          	lw	a5,4(s3)
    80005f1c:	fe978ae3          	beq	a5,s1,80005f10 <virtio_disk_rw+0x1a0>
  }

  disk.info[idx[0]].b = 0;
    80005f20:	fa042903          	lw	s2,-96(s0)
    80005f24:	00491713          	slli	a4,s2,0x4
    80005f28:	02070713          	addi	a4,a4,32
    80005f2c:	0001d797          	auipc	a5,0x1d
    80005f30:	2e478793          	addi	a5,a5,740 # 80023210 <disk>
    80005f34:	97ba                	add	a5,a5,a4
    80005f36:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    80005f3a:	0001d997          	auipc	s3,0x1d
    80005f3e:	2d698993          	addi	s3,s3,726 # 80023210 <disk>
    80005f42:	00491713          	slli	a4,s2,0x4
    80005f46:	0009b783          	ld	a5,0(s3)
    80005f4a:	97ba                	add	a5,a5,a4
    80005f4c:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    80005f50:	854a                	mv	a0,s2
    80005f52:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    80005f56:	bddff0ef          	jal	80005b32 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    80005f5a:	8885                	andi	s1,s1,1
    80005f5c:	f0fd                	bnez	s1,80005f42 <virtio_disk_rw+0x1d2>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    80005f5e:	0001d517          	auipc	a0,0x1d
    80005f62:	3da50513          	addi	a0,a0,986 # 80023338 <disk+0x128>
    80005f66:	e51fa0ef          	jal	80000db6 <release>
}
    80005f6a:	60e6                	ld	ra,88(sp)
    80005f6c:	6446                	ld	s0,80(sp)
    80005f6e:	64a6                	ld	s1,72(sp)
    80005f70:	6906                	ld	s2,64(sp)
    80005f72:	79e2                	ld	s3,56(sp)
    80005f74:	7a42                	ld	s4,48(sp)
    80005f76:	7aa2                	ld	s5,40(sp)
    80005f78:	7b02                	ld	s6,32(sp)
    80005f7a:	6be2                	ld	s7,24(sp)
    80005f7c:	6c42                	ld	s8,16(sp)
    80005f7e:	6125                	addi	sp,sp,96
    80005f80:	8082                	ret

0000000080005f82 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    80005f82:	1101                	addi	sp,sp,-32
    80005f84:	ec06                	sd	ra,24(sp)
    80005f86:	e822                	sd	s0,16(sp)
    80005f88:	e426                	sd	s1,8(sp)
    80005f8a:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    80005f8c:	0001d497          	auipc	s1,0x1d
    80005f90:	28448493          	addi	s1,s1,644 # 80023210 <disk>
    80005f94:	0001d517          	auipc	a0,0x1d
    80005f98:	3a450513          	addi	a0,a0,932 # 80023338 <disk+0x128>
    80005f9c:	d87fa0ef          	jal	80000d22 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    80005fa0:	100017b7          	lui	a5,0x10001
    80005fa4:	53bc                	lw	a5,96(a5)
    80005fa6:	8b8d                	andi	a5,a5,3
    80005fa8:	10001737          	lui	a4,0x10001
    80005fac:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    80005fae:	0330000f          	fence	rw,rw

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    80005fb2:	689c                	ld	a5,16(s1)
    80005fb4:	0204d703          	lhu	a4,32(s1)
    80005fb8:	0027d783          	lhu	a5,2(a5) # 10001002 <_entry-0x6fffeffe>
    80005fbc:	04f70863          	beq	a4,a5,8000600c <virtio_disk_intr+0x8a>
    __sync_synchronize();
    80005fc0:	0330000f          	fence	rw,rw
    int id = disk.used->ring[disk.used_idx % NUM].id;
    80005fc4:	6898                	ld	a4,16(s1)
    80005fc6:	0204d783          	lhu	a5,32(s1)
    80005fca:	8b9d                	andi	a5,a5,7
    80005fcc:	078e                	slli	a5,a5,0x3
    80005fce:	97ba                	add	a5,a5,a4
    80005fd0:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    80005fd2:	00479713          	slli	a4,a5,0x4
    80005fd6:	02070713          	addi	a4,a4,32 # 10001020 <_entry-0x6fffefe0>
    80005fda:	9726                	add	a4,a4,s1
    80005fdc:	01074703          	lbu	a4,16(a4)
    80005fe0:	e329                	bnez	a4,80006022 <virtio_disk_intr+0xa0>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    80005fe2:	0792                	slli	a5,a5,0x4
    80005fe4:	02078793          	addi	a5,a5,32
    80005fe8:	97a6                	add	a5,a5,s1
    80005fea:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    80005fec:	00052223          	sw	zero,4(a0)
    wakeup(b);
    80005ff0:	cc8fc0ef          	jal	800024b8 <wakeup>

    disk.used_idx += 1;
    80005ff4:	0204d783          	lhu	a5,32(s1)
    80005ff8:	2785                	addiw	a5,a5,1
    80005ffa:	17c2                	slli	a5,a5,0x30
    80005ffc:	93c1                	srli	a5,a5,0x30
    80005ffe:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    80006002:	6898                	ld	a4,16(s1)
    80006004:	00275703          	lhu	a4,2(a4)
    80006008:	faf71ce3          	bne	a4,a5,80005fc0 <virtio_disk_intr+0x3e>
  }

  release(&disk.vdisk_lock);
    8000600c:	0001d517          	auipc	a0,0x1d
    80006010:	32c50513          	addi	a0,a0,812 # 80023338 <disk+0x128>
    80006014:	da3fa0ef          	jal	80000db6 <release>
}
    80006018:	60e2                	ld	ra,24(sp)
    8000601a:	6442                	ld	s0,16(sp)
    8000601c:	64a2                	ld	s1,8(sp)
    8000601e:	6105                	addi	sp,sp,32
    80006020:	8082                	ret
      panic("virtio_disk_intr status");
    80006022:	00002517          	auipc	a0,0x2
    80006026:	70e50513          	addi	a0,a0,1806 # 80008730 <etext+0x730>
    8000602a:	82dfa0ef          	jal	80000856 <panic>

000000008000602e <cslog_init>:
  safestrcpy(e->name, p->name, CS_NM);
}

void
cslog_init(void)
{
    8000602e:	1141                	addi	sp,sp,-16
    80006030:	e406                	sd	ra,8(sp)
    80006032:	e022                	sd	s0,0(sp)
    80006034:	0800                	addi	s0,sp,16
  ringbuf_init(&cs_rb, "cslog", sizeof(struct cs_event));
    80006036:	03000613          	li	a2,48
    8000603a:	00002597          	auipc	a1,0x2
    8000603e:	70e58593          	addi	a1,a1,1806 # 80008748 <etext+0x748>
    80006042:	0001d517          	auipc	a0,0x1d
    80006046:	30e50513          	addi	a0,a0,782 # 80023350 <cs_rb>
    8000604a:	1a2000ef          	jal	800061ec <ringbuf_init>
}
    8000604e:	60a2                	ld	ra,8(sp)
    80006050:	6402                	ld	s0,0(sp)
    80006052:	0141                	addi	sp,sp,16
    80006054:	8082                	ret

0000000080006056 <cslog_push>:

void
cslog_push(struct cs_event *e)
{
    80006056:	1141                	addi	sp,sp,-16
    80006058:	e406                	sd	ra,8(sp)
    8000605a:	e022                	sd	s0,0(sp)
    8000605c:	0800                	addi	s0,sp,16
    8000605e:	85aa                	mv	a1,a0
  e->seq = ++cs_seq;
    80006060:	00003717          	auipc	a4,0x3
    80006064:	fd870713          	addi	a4,a4,-40 # 80009038 <cs_seq>
    80006068:	631c                	ld	a5,0(a4)
    8000606a:	0785                	addi	a5,a5,1
    8000606c:	e31c                	sd	a5,0(a4)
    8000606e:	e11c                	sd	a5,0(a0)
  ringbuf_push(&cs_rb, e);
    80006070:	0001d517          	auipc	a0,0x1d
    80006074:	2e050513          	addi	a0,a0,736 # 80023350 <cs_rb>
    80006078:	1a8000ef          	jal	80006220 <ringbuf_push>
}
    8000607c:	60a2                	ld	ra,8(sp)
    8000607e:	6402                	ld	s0,0(sp)
    80006080:	0141                	addi	sp,sp,16
    80006082:	8082                	ret

0000000080006084 <cslog_read_many>:

int
cslog_read_many(struct cs_event *out, int max)
{
    80006084:	1141                	addi	sp,sp,-16
    80006086:	e406                	sd	ra,8(sp)
    80006088:	e022                	sd	s0,0(sp)
    8000608a:	0800                	addi	s0,sp,16
    8000608c:	862e                	mv	a2,a1
  return ringbuf_read_many(&cs_rb, out, max);
    8000608e:	85aa                	mv	a1,a0
    80006090:	0001d517          	auipc	a0,0x1d
    80006094:	2c050513          	addi	a0,a0,704 # 80023350 <cs_rb>
    80006098:	1f4000ef          	jal	8000628c <ringbuf_read_many>
}
    8000609c:	60a2                	ld	ra,8(sp)
    8000609e:	6402                	ld	s0,0(sp)
    800060a0:	0141                	addi	sp,sp,16
    800060a2:	8082                	ret

00000000800060a4 <cslog_run_start>:

void
cslog_run_start(struct proc *p)
{
  if(p == 0) return;
    800060a4:	c14d                	beqz	a0,80006146 <cslog_run_start+0xa2>
{
    800060a6:	715d                	addi	sp,sp,-80
    800060a8:	e486                	sd	ra,72(sp)
    800060aa:	e0a2                	sd	s0,64(sp)
    800060ac:	fc26                	sd	s1,56(sp)
    800060ae:	0880                	addi	s0,sp,80
    800060b0:	84aa                	mv	s1,a0
  if(p->pid <= 0) return;
    800060b2:	591c                	lw	a5,48(a0)
    800060b4:	00f05563          	blez	a5,800060be <cslog_run_start+0x1a>
  if(p->name[0] == 0) return;
    800060b8:	15854783          	lbu	a5,344(a0)
    800060bc:	e791                	bnez	a5,800060c8 <cslog_run_start+0x24>

  struct cs_event e;
  fill_from_proc(&e, p);
  e.type = CS_RUN_START;
  cslog_push(&e);
    800060be:	60a6                	ld	ra,72(sp)
    800060c0:	6406                	ld	s0,64(sp)
    800060c2:	74e2                	ld	s1,56(sp)
    800060c4:	6161                	addi	sp,sp,80
    800060c6:	8082                	ret
    800060c8:	f84a                	sd	s2,48(sp)
  if(strncmp(p->name, "cscat", 5) == 0) return;
    800060ca:	15850913          	addi	s2,a0,344
    800060ce:	4615                	li	a2,5
    800060d0:	00002597          	auipc	a1,0x2
    800060d4:	68058593          	addi	a1,a1,1664 # 80008750 <etext+0x750>
    800060d8:	854a                	mv	a0,s2
    800060da:	dedfa0ef          	jal	80000ec6 <strncmp>
    800060de:	e119                	bnez	a0,800060e4 <cslog_run_start+0x40>
    800060e0:	7942                	ld	s2,48(sp)
    800060e2:	bff1                	j	800060be <cslog_run_start+0x1a>
  if(strncmp(p->name, "csexport", 8) == 0) return;
    800060e4:	4621                	li	a2,8
    800060e6:	00002597          	auipc	a1,0x2
    800060ea:	67258593          	addi	a1,a1,1650 # 80008758 <etext+0x758>
    800060ee:	854a                	mv	a0,s2
    800060f0:	dd7fa0ef          	jal	80000ec6 <strncmp>
    800060f4:	e119                	bnez	a0,800060fa <cslog_run_start+0x56>
    800060f6:	7942                	ld	s2,48(sp)
    800060f8:	b7d9                	j	800060be <cslog_run_start+0x1a>
  memset(e, 0, sizeof(*e));
    800060fa:	03000613          	li	a2,48
    800060fe:	4581                	li	a1,0
    80006100:	fb040513          	addi	a0,s0,-80
    80006104:	ceffa0ef          	jal	80000df2 <memset>
  e->ticks = ticks;
    80006108:	00003797          	auipc	a5,0x3
    8000610c:	f287a783          	lw	a5,-216(a5) # 80009030 <ticks>
    80006110:	faf42c23          	sw	a5,-72(s0)
  e->cpu   = cpuid();
    80006114:	af9fb0ef          	jal	80001c0c <cpuid>
    80006118:	faa42e23          	sw	a0,-68(s0)
  e->pid   = p->pid;
    8000611c:	589c                	lw	a5,48(s1)
    8000611e:	fcf42223          	sw	a5,-60(s0)
  e->state = p->state;
    80006122:	4c9c                	lw	a5,24(s1)
    80006124:	fcf42423          	sw	a5,-56(s0)
  safestrcpy(e->name, p->name, CS_NM);
    80006128:	4641                	li	a2,16
    8000612a:	85ca                	mv	a1,s2
    8000612c:	fcc40513          	addi	a0,s0,-52
    80006130:	e17fa0ef          	jal	80000f46 <safestrcpy>
  e.type = CS_RUN_START;
    80006134:	4785                	li	a5,1
    80006136:	fcf42023          	sw	a5,-64(s0)
  cslog_push(&e);
    8000613a:	fb040513          	addi	a0,s0,-80
    8000613e:	f19ff0ef          	jal	80006056 <cslog_push>
    80006142:	7942                	ld	s2,48(sp)
    80006144:	bfad                	j	800060be <cslog_run_start+0x1a>
    80006146:	8082                	ret

0000000080006148 <sys_csread>:
#include "cslog.h"


uint64
sys_csread(void)
{
    80006148:	81010113          	addi	sp,sp,-2032
    8000614c:	7e113423          	sd	ra,2024(sp)
    80006150:	7e813023          	sd	s0,2016(sp)
    80006154:	7c913c23          	sd	s1,2008(sp)
    80006158:	7d213823          	sd	s2,2000(sp)
    8000615c:	7f010413          	addi	s0,sp,2032
    80006160:	bc010113          	addi	sp,sp,-1088
  uint64 uaddr = 0;
    80006164:	fc043c23          	sd	zero,-40(s0)
  int max = 0;
    80006168:	fc042a23          	sw	zero,-44(s0)

  // ✅ عندك argaddr/argint void، فبنستدعيهم بدون if
  argaddr(0, &uaddr);
    8000616c:	fd840593          	addi	a1,s0,-40
    80006170:	4501                	li	a0,0
    80006172:	c23fc0ef          	jal	80002d94 <argaddr>
  argint(1, &max);
    80006176:	fd440593          	addi	a1,s0,-44
    8000617a:	4505                	li	a0,1
    8000617c:	bfdfc0ef          	jal	80002d78 <argint>

  if(max <= 0) return 0;
    80006180:	fd442783          	lw	a5,-44(s0)
    80006184:	4501                	li	a0,0
    80006186:	04f05463          	blez	a5,800061ce <sys_csread+0x86>
  if(max > 64) max = 64;
    8000618a:	04000713          	li	a4,64
    8000618e:	00f75463          	bge	a4,a5,80006196 <sys_csread+0x4e>
    80006192:	fce42a23          	sw	a4,-44(s0)

  struct cs_event tmp[64];
  int n = cslog_read_many(tmp, max);
    80006196:	80040493          	addi	s1,s0,-2048
    8000619a:	1481                	addi	s1,s1,-32
    8000619c:	bf048493          	addi	s1,s1,-1040
    800061a0:	fd442583          	lw	a1,-44(s0)
    800061a4:	8526                	mv	a0,s1
    800061a6:	edfff0ef          	jal	80006084 <cslog_read_many>
    800061aa:	892a                	mv	s2,a0

  int bytes = n * (int)sizeof(struct cs_event);
  if(copyout(myproc()->pagetable, uaddr, (char*)tmp, bytes) < 0)
    800061ac:	a95fb0ef          	jal	80001c40 <myproc>
  int bytes = n * (int)sizeof(struct cs_event);
    800061b0:	0019169b          	slliw	a3,s2,0x1
    800061b4:	012686bb          	addw	a3,a3,s2
  if(copyout(myproc()->pagetable, uaddr, (char*)tmp, bytes) < 0)
    800061b8:	0046969b          	slliw	a3,a3,0x4
    800061bc:	8626                	mv	a2,s1
    800061be:	fd843583          	ld	a1,-40(s0)
    800061c2:	6928                	ld	a0,80(a0)
    800061c4:	f8efb0ef          	jal	80001952 <copyout>
    800061c8:	02054063          	bltz	a0,800061e8 <sys_csread+0xa0>
    return -1;

  return n;
    800061cc:	854a                	mv	a0,s2
}
    800061ce:	44010113          	addi	sp,sp,1088
    800061d2:	7e813083          	ld	ra,2024(sp)
    800061d6:	7e013403          	ld	s0,2016(sp)
    800061da:	7d813483          	ld	s1,2008(sp)
    800061de:	7d013903          	ld	s2,2000(sp)
    800061e2:	7f010113          	addi	sp,sp,2032
    800061e6:	8082                	ret
    return -1;
    800061e8:	557d                	li	a0,-1
    800061ea:	b7d5                	j	800061ce <sys_csread+0x86>

00000000800061ec <ringbuf_init>:
  return (void *)(rb->buf + idx * rb->elem_size);
}

void
ringbuf_init(struct ringbuf *rb, char *name, uint elem_size)
{
    800061ec:	1101                	addi	sp,sp,-32
    800061ee:	ec06                	sd	ra,24(sp)
    800061f0:	e822                	sd	s0,16(sp)
    800061f2:	e426                	sd	s1,8(sp)
    800061f4:	e04a                	sd	s2,0(sp)
    800061f6:	1000                	addi	s0,sp,32
    800061f8:	84aa                	mv	s1,a0
    800061fa:	8932                	mv	s2,a2
  initlock(&rb->lock, name);
    800061fc:	a9dfa0ef          	jal	80000c98 <initlock>
  rb->head = 0;
    80006200:	0004ac23          	sw	zero,24(s1)
  rb->tail = 0;
    80006204:	0004ae23          	sw	zero,28(s1)
  rb->count = 0;
    80006208:	0204a023          	sw	zero,32(s1)
  rb->seq = 0;
    8000620c:	0204b423          	sd	zero,40(s1)
  rb->elem_size = elem_size;
    80006210:	0324a223          	sw	s2,36(s1)
}
    80006214:	60e2                	ld	ra,24(sp)
    80006216:	6442                	ld	s0,16(sp)
    80006218:	64a2                	ld	s1,8(sp)
    8000621a:	6902                	ld	s2,0(sp)
    8000621c:	6105                	addi	sp,sp,32
    8000621e:	8082                	ret

0000000080006220 <ringbuf_push>:

int
ringbuf_push(struct ringbuf *rb, void *elem)
{
    80006220:	1101                	addi	sp,sp,-32
    80006222:	ec06                	sd	ra,24(sp)
    80006224:	e822                	sd	s0,16(sp)
    80006226:	e426                	sd	s1,8(sp)
    80006228:	e04a                	sd	s2,0(sp)
    8000622a:	1000                	addi	s0,sp,32
    8000622c:	84aa                	mv	s1,a0
    8000622e:	892e                	mv	s2,a1
  acquire(&rb->lock);
    80006230:	af3fa0ef          	jal	80000d22 <acquire>

  if(rb->count == RB_CAP){
    80006234:	5098                	lw	a4,32(s1)
    80006236:	20000793          	li	a5,512
    8000623a:	04f70063          	beq	a4,a5,8000627a <ringbuf_push+0x5a>
  return (void *)(rb->buf + idx * rb->elem_size);
    8000623e:	50d0                	lw	a2,36(s1)
    80006240:	03048513          	addi	a0,s1,48
    80006244:	4c9c                	lw	a5,24(s1)
    80006246:	02c787bb          	mulw	a5,a5,a2
    8000624a:	1782                	slli	a5,a5,0x20
    8000624c:	9381                	srli	a5,a5,0x20
    rb->tail = (rb->tail + 1) % RB_CAP;
    rb->count--;
  }

  memmove(slot_ptr(rb, rb->head), elem, rb->elem_size);
    8000624e:	85ca                	mv	a1,s2
    80006250:	953e                	add	a0,a0,a5
    80006252:	c01fa0ef          	jal	80000e52 <memmove>
  rb->head = (rb->head + 1) % RB_CAP;
    80006256:	4c9c                	lw	a5,24(s1)
    80006258:	2785                	addiw	a5,a5,1
    8000625a:	1ff7f793          	andi	a5,a5,511
    8000625e:	cc9c                	sw	a5,24(s1)
  rb->count++;
    80006260:	509c                	lw	a5,32(s1)
    80006262:	2785                	addiw	a5,a5,1
    80006264:	d09c                	sw	a5,32(s1)

  release(&rb->lock);
    80006266:	8526                	mv	a0,s1
    80006268:	b4ffa0ef          	jal	80000db6 <release>
  return 0;
}
    8000626c:	4501                	li	a0,0
    8000626e:	60e2                	ld	ra,24(sp)
    80006270:	6442                	ld	s0,16(sp)
    80006272:	64a2                	ld	s1,8(sp)
    80006274:	6902                	ld	s2,0(sp)
    80006276:	6105                	addi	sp,sp,32
    80006278:	8082                	ret
    rb->tail = (rb->tail + 1) % RB_CAP;
    8000627a:	4cdc                	lw	a5,28(s1)
    8000627c:	2785                	addiw	a5,a5,1
    8000627e:	1ff7f793          	andi	a5,a5,511
    80006282:	ccdc                	sw	a5,28(s1)
    rb->count--;
    80006284:	1ff00793          	li	a5,511
    80006288:	d09c                	sw	a5,32(s1)
    8000628a:	bf55                	j	8000623e <ringbuf_push+0x1e>

000000008000628c <ringbuf_read_many>:
ringbuf_read_many(struct ringbuf *rb, void *out, int max)
{
  int n = 0;
  char *dst = (char *)out;

  if(max <= 0)
    8000628c:	06c05d63          	blez	a2,80006306 <ringbuf_read_many+0x7a>
{
    80006290:	7139                	addi	sp,sp,-64
    80006292:	fc06                	sd	ra,56(sp)
    80006294:	f822                	sd	s0,48(sp)
    80006296:	f426                	sd	s1,40(sp)
    80006298:	f04a                	sd	s2,32(sp)
    8000629a:	ec4e                	sd	s3,24(sp)
    8000629c:	e852                	sd	s4,16(sp)
    8000629e:	e456                	sd	s5,8(sp)
    800062a0:	0080                	addi	s0,sp,64
    800062a2:	84aa                	mv	s1,a0
    800062a4:	8a2e                	mv	s4,a1
    800062a6:	89b2                	mv	s3,a2
    return 0;

  acquire(&rb->lock);
    800062a8:	a7bfa0ef          	jal	80000d22 <acquire>
  int n = 0;
    800062ac:	4901                	li	s2,0
  return (void *)(rb->buf + idx * rb->elem_size);
    800062ae:	03048a93          	addi	s5,s1,48
  while(n < max && rb->count > 0){
    800062b2:	509c                	lw	a5,32(s1)
    800062b4:	c7b9                	beqz	a5,80006302 <ringbuf_read_many+0x76>
    memmove(dst + n * rb->elem_size, slot_ptr(rb, rb->tail), rb->elem_size);
    800062b6:	50d0                	lw	a2,36(s1)
  return (void *)(rb->buf + idx * rb->elem_size);
    800062b8:	4ccc                	lw	a1,28(s1)
    800062ba:	02c585bb          	mulw	a1,a1,a2
    800062be:	1582                	slli	a1,a1,0x20
    800062c0:	9181                	srli	a1,a1,0x20
    memmove(dst + n * rb->elem_size, slot_ptr(rb, rb->tail), rb->elem_size);
    800062c2:	02c9053b          	mulw	a0,s2,a2
    800062c6:	1502                	slli	a0,a0,0x20
    800062c8:	9101                	srli	a0,a0,0x20
    800062ca:	95d6                	add	a1,a1,s5
    800062cc:	9552                	add	a0,a0,s4
    800062ce:	b85fa0ef          	jal	80000e52 <memmove>
    rb->tail = (rb->tail + 1) % RB_CAP;
    800062d2:	4cdc                	lw	a5,28(s1)
    800062d4:	2785                	addiw	a5,a5,1
    800062d6:	1ff7f793          	andi	a5,a5,511
    800062da:	ccdc                	sw	a5,28(s1)
    rb->count--;
    800062dc:	509c                	lw	a5,32(s1)
    800062de:	37fd                	addiw	a5,a5,-1
    800062e0:	d09c                	sw	a5,32(s1)
    n++;
    800062e2:	2905                	addiw	s2,s2,1
  while(n < max && rb->count > 0){
    800062e4:	fd2997e3          	bne	s3,s2,800062b2 <ringbuf_read_many+0x26>
  }
  release(&rb->lock);
    800062e8:	8526                	mv	a0,s1
    800062ea:	acdfa0ef          	jal	80000db6 <release>

  return n;
    800062ee:	854e                	mv	a0,s3
}
    800062f0:	70e2                	ld	ra,56(sp)
    800062f2:	7442                	ld	s0,48(sp)
    800062f4:	74a2                	ld	s1,40(sp)
    800062f6:	7902                	ld	s2,32(sp)
    800062f8:	69e2                	ld	s3,24(sp)
    800062fa:	6a42                	ld	s4,16(sp)
    800062fc:	6aa2                	ld	s5,8(sp)
    800062fe:	6121                	addi	sp,sp,64
    80006300:	8082                	ret
    80006302:	89ca                	mv	s3,s2
    80006304:	b7d5                	j	800062e8 <ringbuf_read_many+0x5c>
    return 0;
    80006306:	4501                	li	a0,0
}
    80006308:	8082                	ret

000000008000630a <ringbuf_pop>:
int
ringbuf_pop(struct ringbuf *rb, void *dst)
{
    8000630a:	1101                	addi	sp,sp,-32
    8000630c:	ec06                	sd	ra,24(sp)
    8000630e:	e822                	sd	s0,16(sp)
    80006310:	e426                	sd	s1,8(sp)
    80006312:	e04a                	sd	s2,0(sp)
    80006314:	1000                	addi	s0,sp,32
    80006316:	84aa                	mv	s1,a0
    80006318:	892e                	mv	s2,a1
  acquire(&rb->lock);
    8000631a:	a09fa0ef          	jal	80000d22 <acquire>
  
  if(rb->count == 0){ // البفر فارغ تماماً
    8000631e:	509c                	lw	a5,32(s1)
    80006320:	cf9d                	beqz	a5,8000635e <ringbuf_pop+0x54>
  return (void *)(rb->buf + idx * rb->elem_size);
    80006322:	50d0                	lw	a2,36(s1)
    80006324:	03048593          	addi	a1,s1,48
    80006328:	4cdc                	lw	a5,28(s1)
    8000632a:	02c787bb          	mulw	a5,a5,a2
    8000632e:	1782                	slli	a5,a5,0x20
    80006330:	9381                	srli	a5,a5,0x20
    return -1;
  }

  // استخدام الدالة المساعدة slot_ptr الموجودة عندك أصلاً
  void *src = slot_ptr(rb, rb->tail);
  memmove(dst, src, rb->elem_size);
    80006332:	95be                	add	a1,a1,a5
    80006334:	854a                	mv	a0,s2
    80006336:	b1dfa0ef          	jal	80000e52 <memmove>
  
  // تحديث المؤشرات بنفس منطق المشروع
  rb->tail = (rb->tail + 1) % RB_CAP;
    8000633a:	4cdc                	lw	a5,28(s1)
    8000633c:	2785                	addiw	a5,a5,1
    8000633e:	1ff7f793          	andi	a5,a5,511
    80006342:	ccdc                	sw	a5,28(s1)
  rb->count--;
    80006344:	509c                	lw	a5,32(s1)
    80006346:	37fd                	addiw	a5,a5,-1
    80006348:	d09c                	sw	a5,32(s1)
  
  release(&rb->lock);
    8000634a:	8526                	mv	a0,s1
    8000634c:	a6bfa0ef          	jal	80000db6 <release>
  return 0;
    80006350:	4501                	li	a0,0
} 
    80006352:	60e2                	ld	ra,24(sp)
    80006354:	6442                	ld	s0,16(sp)
    80006356:	64a2                	ld	s1,8(sp)
    80006358:	6902                	ld	s2,0(sp)
    8000635a:	6105                	addi	sp,sp,32
    8000635c:	8082                	ret
    release(&rb->lock);
    8000635e:	8526                	mv	a0,s1
    80006360:	a57fa0ef          	jal	80000db6 <release>
    return -1;
    80006364:	557d                	li	a0,-1
    80006366:	b7f5                	j	80006352 <ringbuf_pop+0x48>

0000000080006368 <fslog_init>:
#include "defs.h"

static struct ringbuf fs_rb;
static uint64 fs_seq = 0;

void fslog_init(void) {
    80006368:	1141                	addi	sp,sp,-16
    8000636a:	e406                	sd	ra,8(sp)
    8000636c:	e022                	sd	s0,0(sp)
    8000636e:	0800                	addi	s0,sp,16
  ringbuf_init(&fs_rb, "fslog", sizeof(struct fs_event));
    80006370:	03000613          	li	a2,48
    80006374:	00002597          	auipc	a1,0x2
    80006378:	3f458593          	addi	a1,a1,1012 # 80008768 <etext+0x768>
    8000637c:	00025517          	auipc	a0,0x25
    80006380:	00450513          	addi	a0,a0,4 # 8002b380 <fs_rb>
    80006384:	e69ff0ef          	jal	800061ec <ringbuf_init>
}
    80006388:	60a2                	ld	ra,8(sp)
    8000638a:	6402                	ld	s0,0(sp)
    8000638c:	0141                	addi	sp,sp,16
    8000638e:	8082                	ret

0000000080006390 <fslog_push>:

void fslog_push(int type, int inum, int bno, uint size, char* name) {
    80006390:	7159                	addi	sp,sp,-112
    80006392:	f486                	sd	ra,104(sp)
    80006394:	f0a2                	sd	s0,96(sp)
    80006396:	eca6                	sd	s1,88(sp)
    80006398:	e8ca                	sd	s2,80(sp)
    8000639a:	e4ce                	sd	s3,72(sp)
    8000639c:	e0d2                	sd	s4,64(sp)
    8000639e:	fc56                	sd	s5,56(sp)
    800063a0:	1880                	addi	s0,sp,112
    800063a2:	84aa                	mv	s1,a0
    800063a4:	892e                	mv	s2,a1
    800063a6:	89b2                	mv	s3,a2
    800063a8:	8a36                	mv	s4,a3
    800063aa:	8aba                	mv	s5,a4
  struct fs_event e;
  memset(&e, 0, sizeof(e));
    800063ac:	03000613          	li	a2,48
    800063b0:	4581                	li	a1,0
    800063b2:	f9040513          	addi	a0,s0,-112
    800063b6:	a3dfa0ef          	jal	80000df2 <memset>
  e.seq = ++fs_seq;
    800063ba:	00003717          	auipc	a4,0x3
    800063be:	c8670713          	addi	a4,a4,-890 # 80009040 <fs_seq>
    800063c2:	631c                	ld	a5,0(a4)
    800063c4:	0785                	addi	a5,a5,1
    800063c6:	e31c                	sd	a5,0(a4)
    800063c8:	f8f43823          	sd	a5,-112(s0)
  e.ticks = ticks;
    800063cc:	00003797          	auipc	a5,0x3
    800063d0:	c647a783          	lw	a5,-924(a5) # 80009030 <ticks>
    800063d4:	f8f42c23          	sw	a5,-104(s0)
  e.type = type;
    800063d8:	f8942e23          	sw	s1,-100(s0)
  e.pid = myproc() ? myproc()->pid : 0;
    800063dc:	865fb0ef          	jal	80001c40 <myproc>
    800063e0:	4781                	li	a5,0
    800063e2:	c501                	beqz	a0,800063ea <fslog_push+0x5a>
    800063e4:	85dfb0ef          	jal	80001c40 <myproc>
    800063e8:	591c                	lw	a5,48(a0)
    800063ea:	faf42023          	sw	a5,-96(s0)
  e.inum = inum;
    800063ee:	fb242223          	sw	s2,-92(s0)
  e.blockno = bno;
    800063f2:	fb342423          	sw	s3,-88(s0)
  e.size = size;
    800063f6:	fb442623          	sw	s4,-84(s0)
  if(name) safestrcpy(e.name, name, FS_NM);
    800063fa:	000a8863          	beqz	s5,8000640a <fslog_push+0x7a>
    800063fe:	4641                	li	a2,16
    80006400:	85d6                	mv	a1,s5
    80006402:	fb040513          	addi	a0,s0,-80
    80006406:	b41fa0ef          	jal	80000f46 <safestrcpy>
  ringbuf_push(&fs_rb, &e);
    8000640a:	f9040593          	addi	a1,s0,-112
    8000640e:	00025517          	auipc	a0,0x25
    80006412:	f7250513          	addi	a0,a0,-142 # 8002b380 <fs_rb>
    80006416:	e0bff0ef          	jal	80006220 <ringbuf_push>
}
    8000641a:	70a6                	ld	ra,104(sp)
    8000641c:	7406                	ld	s0,96(sp)
    8000641e:	64e6                	ld	s1,88(sp)
    80006420:	6946                	ld	s2,80(sp)
    80006422:	69a6                	ld	s3,72(sp)
    80006424:	6a06                	ld	s4,64(sp)
    80006426:	7ae2                	ld	s5,56(sp)
    80006428:	6165                	addi	sp,sp,112
    8000642a:	8082                	ret

000000008000642c <fslog_read_many>:
// لا تنسي إضافة fslog_read_many أيضاً هنا

int
fslog_read_many(struct fs_event *out, int max)
{
    8000642c:	7119                	addi	sp,sp,-128
    8000642e:	fc86                	sd	ra,120(sp)
    80006430:	f8a2                	sd	s0,112(sp)
    80006432:	f4a6                	sd	s1,104(sp)
    80006434:	f0ca                	sd	s2,96(sp)
    80006436:	e8d2                	sd	s4,80(sp)
    80006438:	0100                	addi	s0,sp,128
    8000643a:	84aa                	mv	s1,a0
    8000643c:	8a2e                	mv	s4,a1
  struct fs_event e;
  int count = 0;
  struct proc *p = myproc();
    8000643e:	803fb0ef          	jal	80001c40 <myproc>

  while(count < max){
    80006442:	05405863          	blez	s4,80006492 <fslog_read_many+0x66>
    80006446:	ecce                	sd	s3,88(sp)
    80006448:	e4d6                	sd	s5,72(sp)
    8000644a:	e0da                	sd	s6,64(sp)
    8000644c:	fc5e                	sd	s7,56(sp)
    8000644e:	8aaa                	mv	s5,a0
  int count = 0;
    80006450:	4901                	li	s2,0
    // سحب حدث واحد من الرينغ بفر (موجود في ذاكرة الكيرنل)
    if(ringbuf_pop(&fs_rb, &e) != 0)
    80006452:	f8040993          	addi	s3,s0,-128
    80006456:	00025b17          	auipc	s6,0x25
    8000645a:	f2ab0b13          	addi	s6,s6,-214 # 8002b380 <fs_rb>
      break;

    // 🔥 النسخ الآمن لذاكرة المستخدم باستخدام copyout
    // العنوان الهدف: out + (count * حجم الـ struct)
    uint64 dst_addr = (uint64)out + (count * sizeof(struct fs_event));
    if(copyout(p->pagetable, dst_addr, (char *)&e, sizeof(struct fs_event)) < 0)
    8000645e:	03000b93          	li	s7,48
    if(ringbuf_pop(&fs_rb, &e) != 0)
    80006462:	85ce                	mv	a1,s3
    80006464:	855a                	mv	a0,s6
    80006466:	ea5ff0ef          	jal	8000630a <ringbuf_pop>
    8000646a:	e515                	bnez	a0,80006496 <fslog_read_many+0x6a>
    if(copyout(p->pagetable, dst_addr, (char *)&e, sizeof(struct fs_event)) < 0)
    8000646c:	86de                	mv	a3,s7
    8000646e:	864e                	mv	a2,s3
    80006470:	85a6                	mv	a1,s1
    80006472:	050ab503          	ld	a0,80(s5)
    80006476:	cdcfb0ef          	jal	80001952 <copyout>
    8000647a:	02054a63          	bltz	a0,800064ae <fslog_read_many+0x82>
      break;

    count++;
    8000647e:	2905                	addiw	s2,s2,1
  while(count < max){
    80006480:	03048493          	addi	s1,s1,48
    80006484:	fd2a1fe3          	bne	s4,s2,80006462 <fslog_read_many+0x36>
    80006488:	69e6                	ld	s3,88(sp)
    8000648a:	6aa6                	ld	s5,72(sp)
    8000648c:	6b06                	ld	s6,64(sp)
    8000648e:	7be2                	ld	s7,56(sp)
    80006490:	a039                	j	8000649e <fslog_read_many+0x72>
  int count = 0;
    80006492:	4901                	li	s2,0
    80006494:	a029                	j	8000649e <fslog_read_many+0x72>
    80006496:	69e6                	ld	s3,88(sp)
    80006498:	6aa6                	ld	s5,72(sp)
    8000649a:	6b06                	ld	s6,64(sp)
    8000649c:	7be2                	ld	s7,56(sp)
  }
  return count;
    8000649e:	854a                	mv	a0,s2
    800064a0:	70e6                	ld	ra,120(sp)
    800064a2:	7446                	ld	s0,112(sp)
    800064a4:	74a6                	ld	s1,104(sp)
    800064a6:	7906                	ld	s2,96(sp)
    800064a8:	6a46                	ld	s4,80(sp)
    800064aa:	6109                	addi	sp,sp,128
    800064ac:	8082                	ret
    800064ae:	69e6                	ld	s3,88(sp)
    800064b0:	6aa6                	ld	s5,72(sp)
    800064b2:	6b06                	ld	s6,64(sp)
    800064b4:	7be2                	ld	s7,56(sp)
    800064b6:	b7e5                	j	8000649e <fslog_read_many+0x72>

00000000800064b8 <memlog_init>:
static uint mem_count = 0;
static uint64 mem_seq = 0;

void
memlog_init(void)
{
    800064b8:	1141                	addi	sp,sp,-16
    800064ba:	e406                	sd	ra,8(sp)
    800064bc:	e022                	sd	s0,0(sp)
    800064be:	0800                	addi	s0,sp,16
  initlock(&mem_lock, "memlog");
    800064c0:	00002597          	auipc	a1,0x2
    800064c4:	2b058593          	addi	a1,a1,688 # 80008770 <etext+0x770>
    800064c8:	0002d517          	auipc	a0,0x2d
    800064cc:	ee850513          	addi	a0,a0,-280 # 800333b0 <mem_lock>
    800064d0:	fc8fa0ef          	jal	80000c98 <initlock>
  mem_head = 0;
    800064d4:	00003797          	auipc	a5,0x3
    800064d8:	b807a223          	sw	zero,-1148(a5) # 80009058 <mem_head>
  mem_tail = 0;
    800064dc:	00003797          	auipc	a5,0x3
    800064e0:	b607ac23          	sw	zero,-1160(a5) # 80009054 <mem_tail>
  mem_count = 0;
    800064e4:	00003797          	auipc	a5,0x3
    800064e8:	b607a623          	sw	zero,-1172(a5) # 80009050 <mem_count>
  mem_seq = 0;
    800064ec:	00003797          	auipc	a5,0x3
    800064f0:	b407be23          	sd	zero,-1188(a5) # 80009048 <mem_seq>
}
    800064f4:	60a2                	ld	ra,8(sp)
    800064f6:	6402                	ld	s0,0(sp)
    800064f8:	0141                	addi	sp,sp,16
    800064fa:	8082                	ret

00000000800064fc <memlog_push>:

void
memlog_push(struct mem_event *e)
{
    800064fc:	1101                	addi	sp,sp,-32
    800064fe:	ec06                	sd	ra,24(sp)
    80006500:	e822                	sd	s0,16(sp)
    80006502:	e426                	sd	s1,8(sp)
    80006504:	1000                	addi	s0,sp,32
    80006506:	84aa                	mv	s1,a0
  acquire(&mem_lock);
    80006508:	0002d517          	auipc	a0,0x2d
    8000650c:	ea850513          	addi	a0,a0,-344 # 800333b0 <mem_lock>
    80006510:	813fa0ef          	jal	80000d22 <acquire>

  e->seq = ++mem_seq;
    80006514:	00003717          	auipc	a4,0x3
    80006518:	b3470713          	addi	a4,a4,-1228 # 80009048 <mem_seq>
    8000651c:	631c                	ld	a5,0(a4)
    8000651e:	0785                	addi	a5,a5,1
    80006520:	e31c                	sd	a5,0(a4)
    80006522:	e09c                	sd	a5,0(s1)

  if(mem_count == MEM_RB_CAP){
    80006524:	00003717          	auipc	a4,0x3
    80006528:	b2c72703          	lw	a4,-1236(a4) # 80009050 <mem_count>
    8000652c:	20000793          	li	a5,512
    80006530:	06f70e63          	beq	a4,a5,800065ac <memlog_push+0xb0>
    mem_tail = (mem_tail + 1) % MEM_RB_CAP;
    mem_count--;
  }

  mem_buf[mem_head] = *e;
    80006534:	00003617          	auipc	a2,0x3
    80006538:	b2462603          	lw	a2,-1244(a2) # 80009058 <mem_head>
    8000653c:	02061693          	slli	a3,a2,0x20
    80006540:	9281                	srli	a3,a3,0x20
    80006542:	06800793          	li	a5,104
    80006546:	02f686b3          	mul	a3,a3,a5
    8000654a:	8726                	mv	a4,s1
    8000654c:	0002d797          	auipc	a5,0x2d
    80006550:	e7c78793          	addi	a5,a5,-388 # 800333c8 <mem_buf>
    80006554:	97b6                	add	a5,a5,a3
    80006556:	06048493          	addi	s1,s1,96
    8000655a:	6308                	ld	a0,0(a4)
    8000655c:	670c                	ld	a1,8(a4)
    8000655e:	6b14                	ld	a3,16(a4)
    80006560:	e388                	sd	a0,0(a5)
    80006562:	e78c                	sd	a1,8(a5)
    80006564:	eb94                	sd	a3,16(a5)
    80006566:	6f14                	ld	a3,24(a4)
    80006568:	ef94                	sd	a3,24(a5)
    8000656a:	02070713          	addi	a4,a4,32
    8000656e:	02078793          	addi	a5,a5,32
    80006572:	fe9714e3          	bne	a4,s1,8000655a <memlog_push+0x5e>
    80006576:	6318                	ld	a4,0(a4)
    80006578:	e398                	sd	a4,0(a5)
  mem_head = (mem_head + 1) % MEM_RB_CAP;
    8000657a:	2605                	addiw	a2,a2,1
    8000657c:	1ff67613          	andi	a2,a2,511
    80006580:	00003797          	auipc	a5,0x3
    80006584:	acc7ac23          	sw	a2,-1320(a5) # 80009058 <mem_head>
  mem_count++;
    80006588:	00003717          	auipc	a4,0x3
    8000658c:	ac870713          	addi	a4,a4,-1336 # 80009050 <mem_count>
    80006590:	431c                	lw	a5,0(a4)
    80006592:	2785                	addiw	a5,a5,1
    80006594:	c31c                	sw	a5,0(a4)

  release(&mem_lock);
    80006596:	0002d517          	auipc	a0,0x2d
    8000659a:	e1a50513          	addi	a0,a0,-486 # 800333b0 <mem_lock>
    8000659e:	819fa0ef          	jal	80000db6 <release>
}
    800065a2:	60e2                	ld	ra,24(sp)
    800065a4:	6442                	ld	s0,16(sp)
    800065a6:	64a2                	ld	s1,8(sp)
    800065a8:	6105                	addi	sp,sp,32
    800065aa:	8082                	ret
    mem_tail = (mem_tail + 1) % MEM_RB_CAP;
    800065ac:	00003717          	auipc	a4,0x3
    800065b0:	aa870713          	addi	a4,a4,-1368 # 80009054 <mem_tail>
    800065b4:	431c                	lw	a5,0(a4)
    800065b6:	2785                	addiw	a5,a5,1
    800065b8:	1ff7f793          	andi	a5,a5,511
    800065bc:	c31c                	sw	a5,0(a4)
    mem_count--;
    800065be:	1ff00793          	li	a5,511
    800065c2:	00003717          	auipc	a4,0x3
    800065c6:	a8f72723          	sw	a5,-1394(a4) # 80009050 <mem_count>
    800065ca:	b7ad                	j	80006534 <memlog_push+0x38>

00000000800065cc <memlog_read_many>:

int
memlog_read_many(struct mem_event *out, int max)
{
    800065cc:	1101                	addi	sp,sp,-32
    800065ce:	ec06                	sd	ra,24(sp)
    800065d0:	e822                	sd	s0,16(sp)
    800065d2:	e04a                	sd	s2,0(sp)
    800065d4:	1000                	addi	s0,sp,32
  int n = 0;

  if(max <= 0)
    return 0;
    800065d6:	4901                	li	s2,0
  if(max <= 0)
    800065d8:	0ab05963          	blez	a1,8000668a <memlog_read_many+0xbe>
    800065dc:	e426                	sd	s1,8(sp)
    800065de:	892a                	mv	s2,a0
    800065e0:	84ae                	mv	s1,a1

  acquire(&mem_lock);
    800065e2:	0002d517          	auipc	a0,0x2d
    800065e6:	dce50513          	addi	a0,a0,-562 # 800333b0 <mem_lock>
    800065ea:	f38fa0ef          	jal	80000d22 <acquire>
  while(n < max && mem_count > 0){
    800065ee:	00003697          	auipc	a3,0x3
    800065f2:	a666a683          	lw	a3,-1434(a3) # 80009054 <mem_tail>
    800065f6:	00003317          	auipc	t1,0x3
    800065fa:	a5a32303          	lw	t1,-1446(t1) # 80009050 <mem_count>
    800065fe:	854a                	mv	a0,s2
  acquire(&mem_lock);
    80006600:	4701                	li	a4,0
  int n = 0;
    80006602:	4901                	li	s2,0
    out[n] = mem_buf[mem_tail];
    80006604:	0002de97          	auipc	t4,0x2d
    80006608:	dc4e8e93          	addi	t4,t4,-572 # 800333c8 <mem_buf>
    8000660c:	06800e13          	li	t3,104
    80006610:	4f05                	li	t5,1
  while(n < max && mem_count > 0){
    80006612:	08030263          	beqz	t1,80006696 <memlog_read_many+0xca>
    out[n] = mem_buf[mem_tail];
    80006616:	02069793          	slli	a5,a3,0x20
    8000661a:	9381                	srli	a5,a5,0x20
    8000661c:	03c787b3          	mul	a5,a5,t3
    80006620:	97f6                	add	a5,a5,t4
    80006622:	872a                	mv	a4,a0
    80006624:	06078613          	addi	a2,a5,96
    80006628:	0007b883          	ld	a7,0(a5)
    8000662c:	0087b803          	ld	a6,8(a5)
    80006630:	6b8c                	ld	a1,16(a5)
    80006632:	01173023          	sd	a7,0(a4)
    80006636:	01073423          	sd	a6,8(a4)
    8000663a:	eb0c                	sd	a1,16(a4)
    8000663c:	0187b803          	ld	a6,24(a5)
    80006640:	01073c23          	sd	a6,24(a4)
    80006644:	02078793          	addi	a5,a5,32
    80006648:	02070713          	addi	a4,a4,32
    8000664c:	fcc79ee3          	bne	a5,a2,80006628 <memlog_read_many+0x5c>
    80006650:	639c                	ld	a5,0(a5)
    80006652:	e31c                	sd	a5,0(a4)
    mem_tail = (mem_tail + 1) % MEM_RB_CAP;
    80006654:	2685                	addiw	a3,a3,1
    80006656:	1ff6f693          	andi	a3,a3,511
    mem_count--;
    8000665a:	fff3079b          	addiw	a5,t1,-1
    8000665e:	833e                	mv	t1,a5
    n++;
    80006660:	2905                	addiw	s2,s2,1
  while(n < max && mem_count > 0){
    80006662:	06850513          	addi	a0,a0,104
    80006666:	877a                	mv	a4,t5
    80006668:	fb2495e3          	bne	s1,s2,80006612 <memlog_read_many+0x46>
    8000666c:	00003717          	auipc	a4,0x3
    80006670:	9ed72423          	sw	a3,-1560(a4) # 80009054 <mem_tail>
    80006674:	00003717          	auipc	a4,0x3
    80006678:	9cf72e23          	sw	a5,-1572(a4) # 80009050 <mem_count>
  }
  release(&mem_lock);
    8000667c:	0002d517          	auipc	a0,0x2d
    80006680:	d3450513          	addi	a0,a0,-716 # 800333b0 <mem_lock>
    80006684:	f32fa0ef          	jal	80000db6 <release>

  return n;
    80006688:	64a2                	ld	s1,8(sp)
    8000668a:	854a                	mv	a0,s2
    8000668c:	60e2                	ld	ra,24(sp)
    8000668e:	6442                	ld	s0,16(sp)
    80006690:	6902                	ld	s2,0(sp)
    80006692:	6105                	addi	sp,sp,32
    80006694:	8082                	ret
    80006696:	d37d                	beqz	a4,8000667c <memlog_read_many+0xb0>
    80006698:	00003797          	auipc	a5,0x3
    8000669c:	9ad7ae23          	sw	a3,-1604(a5) # 80009054 <mem_tail>
    800066a0:	00003797          	auipc	a5,0x3
    800066a4:	9a07a823          	sw	zero,-1616(a5) # 80009050 <mem_count>
    800066a8:	bfd1                	j	8000667c <memlog_read_many+0xb0>

00000000800066aa <sys_memread>:
#include "memevent.h"
#include "memlog.h"

uint64
sys_memread(void)
{
    800066aa:	95010113          	addi	sp,sp,-1712
    800066ae:	6a113423          	sd	ra,1704(sp)
    800066b2:	6a813023          	sd	s0,1696(sp)
    800066b6:	6b010413          	addi	s0,sp,1712
  uint64 uaddr = 0;
    800066ba:	fc043c23          	sd	zero,-40(s0)
  int max = 0;
    800066be:	fc042a23          	sw	zero,-44(s0)

  argaddr(0, &uaddr);
    800066c2:	fd840593          	addi	a1,s0,-40
    800066c6:	4501                	li	a0,0
    800066c8:	eccfc0ef          	jal	80002d94 <argaddr>
  argint(1, &max);
    800066cc:	fd440593          	addi	a1,s0,-44
    800066d0:	4505                	li	a0,1
    800066d2:	ea6fc0ef          	jal	80002d78 <argint>

  if(max <= 0)
    800066d6:	fd442783          	lw	a5,-44(s0)
    return 0;
    800066da:	4501                	li	a0,0
  if(max <= 0)
    800066dc:	04f05263          	blez	a5,80006720 <sys_memread+0x76>
    800066e0:	68913c23          	sd	s1,1688(sp)
  if(max > 16)
    800066e4:	4741                	li	a4,16
    800066e6:	00f75463          	bge	a4,a5,800066ee <sys_memread+0x44>
    max = 16;
    800066ea:	fce42a23          	sw	a4,-44(s0)

  struct mem_event tmp[16];
  int n = memlog_read_many(tmp, max);
    800066ee:	fd442583          	lw	a1,-44(s0)
    800066f2:	95040513          	addi	a0,s0,-1712
    800066f6:	ed7ff0ef          	jal	800065cc <memlog_read_many>
    800066fa:	84aa                	mv	s1,a0

  int bytes = n * (int)sizeof(struct mem_event);
  if(copyout(myproc()->pagetable, uaddr, (char *)tmp, bytes) < 0)
    800066fc:	d44fb0ef          	jal	80001c40 <myproc>
    80006700:	06800693          	li	a3,104
    80006704:	029686bb          	mulw	a3,a3,s1
    80006708:	95040613          	addi	a2,s0,-1712
    8000670c:	fd843583          	ld	a1,-40(s0)
    80006710:	6928                	ld	a0,80(a0)
    80006712:	a40fb0ef          	jal	80001952 <copyout>
    80006716:	00054c63          	bltz	a0,8000672e <sys_memread+0x84>
    return -1;

  return n;
    8000671a:	8526                	mv	a0,s1
    8000671c:	69813483          	ld	s1,1688(sp)
    80006720:	6a813083          	ld	ra,1704(sp)
    80006724:	6a013403          	ld	s0,1696(sp)
    80006728:	6b010113          	addi	sp,sp,1712
    8000672c:	8082                	ret
    return -1;
    8000672e:	557d                	li	a0,-1
    80006730:	69813483          	ld	s1,1688(sp)
    80006734:	b7f5                	j	80006720 <sys_memread+0x76>

0000000080006736 <schedlog_init>:

static struct ringbuf sched_rb;

void
schedlog_init(void)
{
    80006736:	1141                	addi	sp,sp,-16
    80006738:	e406                	sd	ra,8(sp)
    8000673a:	e022                	sd	s0,0(sp)
    8000673c:	0800                	addi	s0,sp,16
  ringbuf_init(&sched_rb, "schedlog", sizeof(struct sched_event));
    8000673e:	04400613          	li	a2,68
    80006742:	00002597          	auipc	a1,0x2
    80006746:	03658593          	addi	a1,a1,54 # 80008778 <etext+0x778>
    8000674a:	0003a517          	auipc	a0,0x3a
    8000674e:	c7e50513          	addi	a0,a0,-898 # 800403c8 <sched_rb>
    80006752:	a9bff0ef          	jal	800061ec <ringbuf_init>
}
    80006756:	60a2                	ld	ra,8(sp)
    80006758:	6402                	ld	s0,0(sp)
    8000675a:	0141                	addi	sp,sp,16
    8000675c:	8082                	ret

000000008000675e <schedlog_emit>:

void
schedlog_emit(struct sched_event *e)
{
    8000675e:	7159                	addi	sp,sp,-112
    80006760:	f486                	sd	ra,104(sp)
    80006762:	f0a2                	sd	s0,96(sp)
    80006764:	eca6                	sd	s1,88(sp)
    80006766:	1880                	addi	s0,sp,112
    80006768:	85aa                	mv	a1,a0
  struct sched_event copy;

  memmove(&copy, e, sizeof(copy));
    8000676a:	f9840493          	addi	s1,s0,-104
    8000676e:	04400613          	li	a2,68
    80006772:	8526                	mv	a0,s1
    80006774:	edefa0ef          	jal	80000e52 <memmove>
  copy.seq = sched_rb.seq++;
    80006778:	0003a717          	auipc	a4,0x3a
    8000677c:	c5070713          	addi	a4,a4,-944 # 800403c8 <sched_rb>
    80006780:	771c                	ld	a5,40(a4)
    80006782:	00178693          	addi	a3,a5,1
    80006786:	f714                	sd	a3,40(a4)
    80006788:	f8f42c23          	sw	a5,-104(s0)
  ringbuf_push(&sched_rb, &copy);
    8000678c:	85a6                	mv	a1,s1
    8000678e:	853a                	mv	a0,a4
    80006790:	a91ff0ef          	jal	80006220 <ringbuf_push>
}
    80006794:	70a6                	ld	ra,104(sp)
    80006796:	7406                	ld	s0,96(sp)
    80006798:	64e6                	ld	s1,88(sp)
    8000679a:	6165                	addi	sp,sp,112
    8000679c:	8082                	ret

000000008000679e <schedread>:

int
schedread(struct sched_event *dst, int max)
{
    8000679e:	1141                	addi	sp,sp,-16
    800067a0:	e406                	sd	ra,8(sp)
    800067a2:	e022                	sd	s0,0(sp)
    800067a4:	0800                	addi	s0,sp,16
    800067a6:	862e                	mv	a2,a1
  return ringbuf_read_many(&sched_rb, dst, max);
    800067a8:	85aa                	mv	a1,a0
    800067aa:	0003a517          	auipc	a0,0x3a
    800067ae:	c1e50513          	addi	a0,a0,-994 # 800403c8 <sched_rb>
    800067b2:	adbff0ef          	jal	8000628c <ringbuf_read_many>
    800067b6:	60a2                	ld	ra,8(sp)
    800067b8:	6402                	ld	s0,0(sp)
    800067ba:	0141                	addi	sp,sp,16
    800067bc:	8082                	ret
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
