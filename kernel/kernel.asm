
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
_entry:
        # set up a stack for C.
        # stack0 is declared in start.c,
        # with a 4096-byte stack per CPU.
        # sp = stack0 + ((hartid + 1) * 4096)
        la sp, stack0
    80000000:	00009117          	auipc	sp,0x9
    80000004:	96010113          	addi	sp,sp,-1696 # 80008960 <stack0>
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
    80000072:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffb7aa7>
    80000076:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    80000078:	6705                	lui	a4,0x1
    8000007a:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    8000007e:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r" (x));
    80000080:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r" (x));
    80000084:	00001797          	auipc	a5,0x1
    80000088:	f1878793          	addi	a5,a5,-232 # 80000f9c <main>
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
    800000ea:	00011517          	auipc	a0,0x11
    800000ee:	87650513          	addi	a0,a0,-1930 # 80010960 <conswlock>
    800000f2:	3c8040ef          	jal	800044ba <acquiresleep>

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
    80000126:	6f0020ef          	jal	80002816 <either_copyin>
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
    8000016a:	00010517          	auipc	a0,0x10
    8000016e:	7f650513          	addi	a0,a0,2038 # 80010960 <conswlock>
    80000172:	38e040ef          	jal	80004500 <releasesleep>
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
    800001a6:	00010517          	auipc	a0,0x10
    800001aa:	7ea50513          	addi	a0,a0,2026 # 80010990 <cons>
    800001ae:	369000ef          	jal	80000d16 <acquire>

  while(n > 0){
    while(cons.r == cons.w){
    800001b2:	00010497          	auipc	s1,0x10
    800001b6:	7ae48493          	addi	s1,s1,1966 # 80010960 <conswlock>
      if(killed(myproc())){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    800001ba:	00010997          	auipc	s3,0x10
    800001be:	7d698993          	addi	s3,s3,2006 # 80010990 <cons>
    800001c2:	00011917          	auipc	s2,0x11
    800001c6:	86690913          	addi	s2,s2,-1946 # 80010a28 <cons+0x98>
  while(n > 0){
    800001ca:	0b405c63          	blez	s4,80000282 <consoleread+0xfa>
    while(cons.r == cons.w){
    800001ce:	0c84a783          	lw	a5,200(s1)
    800001d2:	0cc4a703          	lw	a4,204(s1)
    800001d6:	0af71163          	bne	a4,a5,80000278 <consoleread+0xf0>
      if(killed(myproc())){
    800001da:	24f010ef          	jal	80001c28 <myproc>
    800001de:	4d0020ef          	jal	800026ae <killed>
    800001e2:	e12d                	bnez	a0,80000244 <consoleread+0xbc>
      sleep(&cons.r, &cons.lock);
    800001e4:	85ce                	mv	a1,s3
    800001e6:	854a                	mv	a0,s2
    800001e8:	28a020ef          	jal	80002472 <sleep>
    while(cons.r == cons.w){
    800001ec:	0c84a783          	lw	a5,200(s1)
    800001f0:	0cc4a703          	lw	a4,204(s1)
    800001f4:	fef703e3          	beq	a4,a5,800001da <consoleread+0x52>
    800001f8:	f05a                	sd	s6,32(sp)
    }

    c = cons.buf[cons.r++ % INPUT_BUF_SIZE];
    800001fa:	00010717          	auipc	a4,0x10
    800001fe:	76670713          	addi	a4,a4,1894 # 80010960 <conswlock>
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
    8000022c:	5a0020ef          	jal	800027cc <either_copyout>
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
    80000244:	00010517          	auipc	a0,0x10
    80000248:	74c50513          	addi	a0,a0,1868 # 80010990 <cons>
    8000024c:	35f000ef          	jal	80000daa <release>
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
    8000026c:	00010717          	auipc	a4,0x10
    80000270:	7af72e23          	sw	a5,1980(a4) # 80010a28 <cons+0x98>
    80000274:	7b02                	ld	s6,32(sp)
    80000276:	a031                	j	80000282 <consoleread+0xfa>
    80000278:	f05a                	sd	s6,32(sp)
    8000027a:	b741                	j	800001fa <consoleread+0x72>
    8000027c:	7b02                	ld	s6,32(sp)
    8000027e:	a011                	j	80000282 <consoleread+0xfa>
    80000280:	7b02                	ld	s6,32(sp)
  release(&cons.lock);
    80000282:	00010517          	auipc	a0,0x10
    80000286:	70e50513          	addi	a0,a0,1806 # 80010990 <cons>
    8000028a:	321000ef          	jal	80000daa <release>
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
    800002d6:	00010517          	auipc	a0,0x10
    800002da:	6ba50513          	addi	a0,a0,1722 # 80010990 <cons>
    800002de:	239000ef          	jal	80000d16 <acquire>

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
    800002f8:	568020ef          	jal	80002860 <procdump>
      }
    }
    break;
  }

  release(&cons.lock);
    800002fc:	00010517          	auipc	a0,0x10
    80000300:	69450513          	addi	a0,a0,1684 # 80010990 <cons>
    80000304:	2a7000ef          	jal	80000daa <release>
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
    8000031a:	00010717          	auipc	a4,0x10
    8000031e:	64670713          	addi	a4,a4,1606 # 80010960 <conswlock>
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
    80000340:	00010717          	auipc	a4,0x10
    80000344:	62070713          	addi	a4,a4,1568 # 80010960 <conswlock>
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
    8000036a:	00010717          	auipc	a4,0x10
    8000036e:	6be72703          	lw	a4,1726(a4) # 80010a28 <cons+0x98>
    80000372:	9f99                	subw	a5,a5,a4
    80000374:	08000713          	li	a4,128
    80000378:	f8e792e3          	bne	a5,a4,800002fc <consoleintr+0x32>
    8000037c:	a075                	j	80000428 <consoleintr+0x15e>
    8000037e:	e04a                	sd	s2,0(sp)
    while(cons.e != cons.w &&
    80000380:	00010717          	auipc	a4,0x10
    80000384:	5e070713          	addi	a4,a4,1504 # 80010960 <conswlock>
    80000388:	0d072783          	lw	a5,208(a4)
    8000038c:	0cc72703          	lw	a4,204(a4)
          cons.buf[(cons.e - 1) % INPUT_BUF_SIZE] != '\n'){
    80000390:	00010497          	auipc	s1,0x10
    80000394:	5d048493          	addi	s1,s1,1488 # 80010960 <conswlock>
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
    800003d2:	00010717          	auipc	a4,0x10
    800003d6:	58e70713          	addi	a4,a4,1422 # 80010960 <conswlock>
    800003da:	0d072783          	lw	a5,208(a4)
    800003de:	0cc72703          	lw	a4,204(a4)
    800003e2:	f0f70de3          	beq	a4,a5,800002fc <consoleintr+0x32>
      cons.e--;
    800003e6:	37fd                	addiw	a5,a5,-1
    800003e8:	00010717          	auipc	a4,0x10
    800003ec:	64f72423          	sw	a5,1608(a4) # 80010a30 <cons+0xa0>
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
    80000406:	00010797          	auipc	a5,0x10
    8000040a:	55a78793          	addi	a5,a5,1370 # 80010960 <conswlock>
    8000040e:	0d07a703          	lw	a4,208(a5)
    80000412:	0017069b          	addiw	a3,a4,1
    80000416:	8636                	mv	a2,a3
    80000418:	0cd7a823          	sw	a3,208(a5)
    8000041c:	07f77713          	andi	a4,a4,127
    80000420:	97ba                	add	a5,a5,a4
    80000422:	4729                	li	a4,10
    80000424:	04e78423          	sb	a4,72(a5)
        cons.w = cons.e;
    80000428:	00010797          	auipc	a5,0x10
    8000042c:	60c7a223          	sw	a2,1540(a5) # 80010a2c <cons+0x9c>
        wakeup(&cons.r);
    80000430:	00010517          	auipc	a0,0x10
    80000434:	5f850513          	addi	a0,a0,1528 # 80010a28 <cons+0x98>
    80000438:	086020ef          	jal	800024be <wakeup>
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
    8000044e:	00010517          	auipc	a0,0x10
    80000452:	54250513          	addi	a0,a0,1346 # 80010990 <cons>
    80000456:	037000ef          	jal	80000c8c <initlock>
  initsleeplock(&conswlock, "consw");
    8000045a:	00008597          	auipc	a1,0x8
    8000045e:	bb658593          	addi	a1,a1,-1098 # 80008010 <etext+0x10>
    80000462:	00010517          	auipc	a0,0x10
    80000466:	4fe50513          	addi	a0,a0,1278 # 80010960 <conswlock>
    8000046a:	01a040ef          	jal	80004484 <initsleeplock>

  uartinit();
    8000046e:	448000ef          	jal	800008b6 <uartinit>

  devsw[CONSOLE].read = consoleread;
    80000472:	00020797          	auipc	a5,0x20
    80000476:	6a678793          	addi	a5,a5,1702 # 80020b18 <devsw>
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
    800004b4:	30880813          	addi	a6,a6,776 # 800087b8 <digits>
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
    8000054a:	00008797          	auipc	a5,0x8
    8000054e:	3ba7a783          	lw	a5,954(a5) # 80008904 <panicking>
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
    80000590:	00010517          	auipc	a0,0x10
    80000594:	4a850513          	addi	a0,a0,1192 # 80010a38 <pr>
    80000598:	77e000ef          	jal	80000d16 <acquire>
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
    80000708:	0b4c8c93          	addi	s9,s9,180 # 800087b8 <digits>
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
    8000078c:	00008797          	auipc	a5,0x8
    80000790:	1787a783          	lw	a5,376(a5) # 80008904 <panicking>
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
    800007b6:	00010517          	auipc	a0,0x10
    800007ba:	28250513          	addi	a0,a0,642 # 80010a38 <pr>
    800007be:	5ec000ef          	jal	80000daa <release>
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
    8000086a:	0897af23          	sw	s1,158(a5) # 80008904 <panicking>
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
    8000088c:	0697ac23          	sw	s1,120(a5) # 80008900 <panicked>
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
    800008a2:	00010517          	auipc	a0,0x10
    800008a6:	19650513          	addi	a0,a0,406 # 80010a38 <pr>
    800008aa:	3e2000ef          	jal	80000c8c <initlock>
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
    800008f8:	00010517          	auipc	a0,0x10
    800008fc:	15850513          	addi	a0,a0,344 # 80010a50 <tx_lock>
    80000900:	38c000ef          	jal	80000c8c <initlock>
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
    8000091c:	00010517          	auipc	a0,0x10
    80000920:	13450513          	addi	a0,a0,308 # 80010a50 <tx_lock>
    80000924:	3f2000ef          	jal	80000d16 <acquire>

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
    8000093e:	fd248493          	addi	s1,s1,-46 # 8000890c <tx_busy>
      // wait for a UART transmit-complete interrupt
      // to set tx_busy to 0.
      sleep(&tx_chan, &tx_lock);
    80000942:	00010997          	auipc	s3,0x10
    80000946:	10e98993          	addi	s3,s3,270 # 80010a50 <tx_lock>
    8000094a:	00008917          	auipc	s2,0x8
    8000094e:	fbe90913          	addi	s2,s2,-66 # 80008908 <tx_chan>
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
    8000095e:	315010ef          	jal	80002472 <sleep>
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
    80000988:	00010517          	auipc	a0,0x10
    8000098c:	0c850513          	addi	a0,a0,200 # 80010a50 <tx_lock>
    80000990:	41a000ef          	jal	80000daa <release>
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
    800009b0:	f587a783          	lw	a5,-168(a5) # 80008904 <panicking>
    800009b4:	cf95                	beqz	a5,800009f0 <uartputc_sync+0x50>
    push_off();

  if(panicked){
    800009b6:	00008797          	auipc	a5,0x8
    800009ba:	f4a7a783          	lw	a5,-182(a5) # 80008900 <panicked>
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
    800009e0:	f287a783          	lw	a5,-216(a5) # 80008904 <panicking>
    800009e4:	cb91                	beqz	a5,800009f8 <uartputc_sync+0x58>
    pop_off();
}
    800009e6:	60e2                	ld	ra,24(sp)
    800009e8:	6442                	ld	s0,16(sp)
    800009ea:	64a2                	ld	s1,8(sp)
    800009ec:	6105                	addi	sp,sp,32
    800009ee:	8082                	ret
    push_off();
    800009f0:	2e2000ef          	jal	80000cd2 <push_off>
    800009f4:	b7c9                	j	800009b6 <uartputc_sync+0x16>
    for(;;)
    800009f6:	a001                	j	800009f6 <uartputc_sync+0x56>
    pop_off();
    800009f8:	362000ef          	jal	80000d5a <pop_off>
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
    80000a38:	00010517          	auipc	a0,0x10
    80000a3c:	01850513          	addi	a0,a0,24 # 80010a50 <tx_lock>
    80000a40:	2d6000ef          	jal	80000d16 <acquire>
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
    80000a52:	00010517          	auipc	a0,0x10
    80000a56:	ffe50513          	addi	a0,a0,-2 # 80010a50 <tx_lock>
    80000a5a:	350000ef          	jal	80000daa <release>

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
    80000a72:	e807af23          	sw	zero,-354(a5) # 8000890c <tx_busy>
    wakeup(&tx_chan);
    80000a76:	00008517          	auipc	a0,0x8
    80000a7a:	e9250513          	addi	a0,a0,-366 # 80008908 <tx_chan>
    80000a7e:	241010ef          	jal	800024be <wakeup>
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
    80000a9a:	00046797          	auipc	a5,0x46
    80000a9e:	2be78793          	addi	a5,a5,702 # 80046d58 <end>
    80000aa2:	00f53733          	sltu	a4,a0,a5
    80000aa6:	47c5                	li	a5,17
    80000aa8:	07ee                	slli	a5,a5,0x1b
    80000aaa:	17fd                	addi	a5,a5,-1
    80000aac:	00a7b7b3          	sltu	a5,a5,a0
    80000ab0:	8fd9                	or	a5,a5,a4
    80000ab2:	efc9                	bnez	a5,80000b4c <kfree+0xbe>
    80000ab4:	84aa                	mv	s1,a0
    80000ab6:	03451793          	slli	a5,a0,0x34
    80000aba:	ebc9                	bnez	a5,80000b4c <kfree+0xbe>
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(pa, 1, PGSIZE);
    80000abc:	6605                	lui	a2,0x1
    80000abe:	4585                	li	a1,1
    80000ac0:	326000ef          	jal	80000de6 <memset>

  r = (struct run*)pa;

  acquire(&kmem.lock);
    80000ac4:	00010917          	auipc	s2,0x10
    80000ac8:	fa490913          	addi	s2,s2,-92 # 80010a68 <kmem>
    80000acc:	854a                	mv	a0,s2
    80000ace:	248000ef          	jal	80000d16 <acquire>
  r->next = kmem.freelist;
    80000ad2:	01893783          	ld	a5,24(s2)
    80000ad6:	e09c                	sd	a5,0(s1)
  kmem.freelist = r;
    80000ad8:	00993c23          	sd	s1,24(s2)
  release(&kmem.lock);
    80000adc:	854a                	mv	a0,s2
    80000ade:	2cc000ef          	jal	80000daa <release>

  struct mem_event e;
  memset(&e, 0, sizeof(e));
    80000ae2:	06800613          	li	a2,104
    80000ae6:	4581                	li	a1,0
    80000ae8:	f7840513          	addi	a0,s0,-136
    80000aec:	2fa000ef          	jal	80000de6 <memset>

  e.ticks  = ticks;
    80000af0:	00008797          	auipc	a5,0x8
    80000af4:	e407a783          	lw	a5,-448(a5) # 80008930 <ticks>
    80000af8:	f8f42023          	sw	a5,-128(s0)
  e.cpu    = cpuid();
    80000afc:	0f8010ef          	jal	80001bf4 <cpuid>
    80000b00:	f8a42223          	sw	a0,-124(s0)
  e.type   = MEM_FREE;
    80000b04:	479d                	li	a5,7
    80000b06:	f8f42423          	sw	a5,-120(s0)
  e.pa     = (uint64)pa;
    80000b0a:	fa943823          	sd	s1,-80(s0)
  e.source = SRC_KFREE;
    80000b0e:	4789                	li	a5,2
    80000b10:	fcf42a23          	sw	a5,-44(s0)
  e.kind   = PAGE_UNKNOWN;
    80000b14:	fc042c23          	sw	zero,-40(s0)

  struct proc *p = myproc();
    80000b18:	110010ef          	jal	80001c28 <myproc>
  if(p){
    80000b1c:	cd11                	beqz	a0,80000b38 <kfree+0xaa>
    e.pid = p->pid;
    80000b1e:	591c                	lw	a5,48(a0)
    80000b20:	f8f42623          	sw	a5,-116(s0)
    e.state = p->state;
    80000b24:	4d1c                	lw	a5,24(a0)
    80000b26:	f8f42823          	sw	a5,-112(s0)
    safestrcpy(e.name, p->name, MEM_NM);
    80000b2a:	4641                	li	a2,16
    80000b2c:	15850593          	addi	a1,a0,344
    80000b30:	f9440513          	addi	a0,s0,-108
    80000b34:	406000ef          	jal	80000f3a <safestrcpy>
  }

  memlog_push(&e);
    80000b38:	f7840513          	addi	a0,s0,-136
    80000b3c:	1c1050ef          	jal	800064fc <memlog_push>
}
    80000b40:	60aa                	ld	ra,136(sp)
    80000b42:	640a                	ld	s0,128(sp)
    80000b44:	74e6                	ld	s1,120(sp)
    80000b46:	7946                	ld	s2,112(sp)
    80000b48:	6149                	addi	sp,sp,144
    80000b4a:	8082                	ret
    panic("kfree");
    80000b4c:	00007517          	auipc	a0,0x7
    80000b50:	4f450513          	addi	a0,a0,1268 # 80008040 <etext+0x40>
    80000b54:	d03ff0ef          	jal	80000856 <panic>

0000000080000b58 <freerange>:
{
    80000b58:	7179                	addi	sp,sp,-48
    80000b5a:	f406                	sd	ra,40(sp)
    80000b5c:	f022                	sd	s0,32(sp)
    80000b5e:	ec26                	sd	s1,24(sp)
    80000b60:	1800                	addi	s0,sp,48
  p = (char*)PGROUNDUP((uint64)pa_start);
    80000b62:	6785                	lui	a5,0x1
    80000b64:	fff78713          	addi	a4,a5,-1 # fff <_entry-0x7ffff001>
    80000b68:	00e504b3          	add	s1,a0,a4
    80000b6c:	777d                	lui	a4,0xfffff
    80000b6e:	8cf9                	and	s1,s1,a4
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000b70:	94be                	add	s1,s1,a5
    80000b72:	0295e263          	bltu	a1,s1,80000b96 <freerange+0x3e>
    80000b76:	e84a                	sd	s2,16(sp)
    80000b78:	e44e                	sd	s3,8(sp)
    80000b7a:	e052                	sd	s4,0(sp)
    80000b7c:	892e                	mv	s2,a1
    kfree(p);
    80000b7e:	8a3a                	mv	s4,a4
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000b80:	89be                	mv	s3,a5
    kfree(p);
    80000b82:	01448533          	add	a0,s1,s4
    80000b86:	f09ff0ef          	jal	80000a8e <kfree>
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000b8a:	94ce                	add	s1,s1,s3
    80000b8c:	fe997be3          	bgeu	s2,s1,80000b82 <freerange+0x2a>
    80000b90:	6942                	ld	s2,16(sp)
    80000b92:	69a2                	ld	s3,8(sp)
    80000b94:	6a02                	ld	s4,0(sp)
}
    80000b96:	70a2                	ld	ra,40(sp)
    80000b98:	7402                	ld	s0,32(sp)
    80000b9a:	64e2                	ld	s1,24(sp)
    80000b9c:	6145                	addi	sp,sp,48
    80000b9e:	8082                	ret

0000000080000ba0 <kinit>:
{
    80000ba0:	1141                	addi	sp,sp,-16
    80000ba2:	e406                	sd	ra,8(sp)
    80000ba4:	e022                	sd	s0,0(sp)
    80000ba6:	0800                	addi	s0,sp,16
  initlock(&kmem.lock, "kmem");
    80000ba8:	00007597          	auipc	a1,0x7
    80000bac:	4a058593          	addi	a1,a1,1184 # 80008048 <etext+0x48>
    80000bb0:	00010517          	auipc	a0,0x10
    80000bb4:	eb850513          	addi	a0,a0,-328 # 80010a68 <kmem>
    80000bb8:	0d4000ef          	jal	80000c8c <initlock>
  freerange(end, (void*)PHYSTOP);
    80000bbc:	45c5                	li	a1,17
    80000bbe:	05ee                	slli	a1,a1,0x1b
    80000bc0:	00046517          	auipc	a0,0x46
    80000bc4:	19850513          	addi	a0,a0,408 # 80046d58 <end>
    80000bc8:	f91ff0ef          	jal	80000b58 <freerange>
}
    80000bcc:	60a2                	ld	ra,8(sp)
    80000bce:	6402                	ld	s0,0(sp)
    80000bd0:	0141                	addi	sp,sp,16
    80000bd2:	8082                	ret

0000000080000bd4 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
    80000bd4:	7175                	addi	sp,sp,-144
    80000bd6:	e506                	sd	ra,136(sp)
    80000bd8:	e122                	sd	s0,128(sp)
    80000bda:	fca6                	sd	s1,120(sp)
    80000bdc:	0900                	addi	s0,sp,144
  struct run *r;

  acquire(&kmem.lock);
    80000bde:	00010517          	auipc	a0,0x10
    80000be2:	e8a50513          	addi	a0,a0,-374 # 80010a68 <kmem>
    80000be6:	130000ef          	jal	80000d16 <acquire>
  r = kmem.freelist;
    80000bea:	00010497          	auipc	s1,0x10
    80000bee:	e964b483          	ld	s1,-362(s1) # 80010a80 <kmem+0x18>
  if(r)
    80000bf2:	c4d1                	beqz	s1,80000c7e <kalloc+0xaa>
    kmem.freelist = r->next;
    80000bf4:	609c                	ld	a5,0(s1)
    80000bf6:	00010717          	auipc	a4,0x10
    80000bfa:	e8f73523          	sd	a5,-374(a4) # 80010a80 <kmem+0x18>
  release(&kmem.lock);
    80000bfe:	00010517          	auipc	a0,0x10
    80000c02:	e6a50513          	addi	a0,a0,-406 # 80010a68 <kmem>
    80000c06:	1a4000ef          	jal	80000daa <release>

  if(r)
    memset((char*)r, 5, PGSIZE); // fill with junk
    80000c0a:	6605                	lui	a2,0x1
    80000c0c:	4595                	li	a1,5
    80000c0e:	8526                	mv	a0,s1
    80000c10:	1d6000ef          	jal	80000de6 <memset>

  if(r){
    struct mem_event e;
    memset(&e, 0, sizeof(e));
    80000c14:	06800613          	li	a2,104
    80000c18:	4581                	li	a1,0
    80000c1a:	f7840513          	addi	a0,s0,-136
    80000c1e:	1c8000ef          	jal	80000de6 <memset>

    e.ticks  = ticks;
    80000c22:	00008797          	auipc	a5,0x8
    80000c26:	d0e7a783          	lw	a5,-754(a5) # 80008930 <ticks>
    80000c2a:	f8f42023          	sw	a5,-128(s0)
    e.cpu    = cpuid();
    80000c2e:	7c7000ef          	jal	80001bf4 <cpuid>
    80000c32:	f8a42223          	sw	a0,-124(s0)
    e.type   = MEM_ALLOC;
    80000c36:	4799                	li	a5,6
    80000c38:	f8f42423          	sw	a5,-120(s0)
    e.pa     = (uint64)r;
    80000c3c:	fa943823          	sd	s1,-80(s0)
    e.source = SRC_KALLOC;
    80000c40:	4785                	li	a5,1
    80000c42:	fcf42a23          	sw	a5,-44(s0)
    e.kind   = PAGE_UNKNOWN;
    80000c46:	fc042c23          	sw	zero,-40(s0)

    struct proc *p = myproc();
    80000c4a:	7df000ef          	jal	80001c28 <myproc>
    if(p){
    80000c4e:	cd11                	beqz	a0,80000c6a <kalloc+0x96>
      e.pid = p->pid;
    80000c50:	591c                	lw	a5,48(a0)
    80000c52:	f8f42623          	sw	a5,-116(s0)
      e.state = p->state;
    80000c56:	4d1c                	lw	a5,24(a0)
    80000c58:	f8f42823          	sw	a5,-112(s0)
      safestrcpy(e.name, p->name, MEM_NM);
    80000c5c:	4641                	li	a2,16
    80000c5e:	15850593          	addi	a1,a0,344
    80000c62:	f9440513          	addi	a0,s0,-108
    80000c66:	2d4000ef          	jal	80000f3a <safestrcpy>
    }

    memlog_push(&e);
    80000c6a:	f7840513          	addi	a0,s0,-136
    80000c6e:	08f050ef          	jal	800064fc <memlog_push>
  }

  return (void*)r;
}
    80000c72:	8526                	mv	a0,s1
    80000c74:	60aa                	ld	ra,136(sp)
    80000c76:	640a                	ld	s0,128(sp)
    80000c78:	74e6                	ld	s1,120(sp)
    80000c7a:	6149                	addi	sp,sp,144
    80000c7c:	8082                	ret
  release(&kmem.lock);
    80000c7e:	00010517          	auipc	a0,0x10
    80000c82:	dea50513          	addi	a0,a0,-534 # 80010a68 <kmem>
    80000c86:	124000ef          	jal	80000daa <release>
  if(r)
    80000c8a:	b7e5                	j	80000c72 <kalloc+0x9e>

0000000080000c8c <initlock>:
#include "proc.h"
#include "defs.h"

void
initlock(struct spinlock *lk, char *name)
{
    80000c8c:	1141                	addi	sp,sp,-16
    80000c8e:	e406                	sd	ra,8(sp)
    80000c90:	e022                	sd	s0,0(sp)
    80000c92:	0800                	addi	s0,sp,16
  lk->name = name;
    80000c94:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    80000c96:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    80000c9a:	00053823          	sd	zero,16(a0)
}
    80000c9e:	60a2                	ld	ra,8(sp)
    80000ca0:	6402                	ld	s0,0(sp)
    80000ca2:	0141                	addi	sp,sp,16
    80000ca4:	8082                	ret

0000000080000ca6 <holding>:
// Interrupts must be off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    80000ca6:	411c                	lw	a5,0(a0)
    80000ca8:	e399                	bnez	a5,80000cae <holding+0x8>
    80000caa:	4501                	li	a0,0
  return r;
}
    80000cac:	8082                	ret
{
    80000cae:	1101                	addi	sp,sp,-32
    80000cb0:	ec06                	sd	ra,24(sp)
    80000cb2:	e822                	sd	s0,16(sp)
    80000cb4:	e426                	sd	s1,8(sp)
    80000cb6:	1000                	addi	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    80000cb8:	691c                	ld	a5,16(a0)
    80000cba:	84be                	mv	s1,a5
    80000cbc:	74d000ef          	jal	80001c08 <mycpu>
    80000cc0:	40a48533          	sub	a0,s1,a0
    80000cc4:	00153513          	seqz	a0,a0
}
    80000cc8:	60e2                	ld	ra,24(sp)
    80000cca:	6442                	ld	s0,16(sp)
    80000ccc:	64a2                	ld	s1,8(sp)
    80000cce:	6105                	addi	sp,sp,32
    80000cd0:	8082                	ret

0000000080000cd2 <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    80000cd2:	1101                	addi	sp,sp,-32
    80000cd4:	ec06                	sd	ra,24(sp)
    80000cd6:	e822                	sd	s0,16(sp)
    80000cd8:	e426                	sd	s1,8(sp)
    80000cda:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000cdc:	100027f3          	csrr	a5,sstatus
    80000ce0:	84be                	mv	s1,a5
    80000ce2:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80000ce6:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000ce8:	10079073          	csrw	sstatus,a5

  // disable interrupts to prevent an involuntary context
  // switch while using mycpu().
  intr_off();

  if(mycpu()->noff == 0)
    80000cec:	71d000ef          	jal	80001c08 <mycpu>
    80000cf0:	5d3c                	lw	a5,120(a0)
    80000cf2:	cb99                	beqz	a5,80000d08 <push_off+0x36>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000cf4:	715000ef          	jal	80001c08 <mycpu>
    80000cf8:	5d3c                	lw	a5,120(a0)
    80000cfa:	2785                	addiw	a5,a5,1
    80000cfc:	dd3c                	sw	a5,120(a0)
}
    80000cfe:	60e2                	ld	ra,24(sp)
    80000d00:	6442                	ld	s0,16(sp)
    80000d02:	64a2                	ld	s1,8(sp)
    80000d04:	6105                	addi	sp,sp,32
    80000d06:	8082                	ret
    mycpu()->intena = old;
    80000d08:	701000ef          	jal	80001c08 <mycpu>
  return (x & SSTATUS_SIE) != 0;
    80000d0c:	0014d793          	srli	a5,s1,0x1
    80000d10:	8b85                	andi	a5,a5,1
    80000d12:	dd7c                	sw	a5,124(a0)
    80000d14:	b7c5                	j	80000cf4 <push_off+0x22>

0000000080000d16 <acquire>:
{
    80000d16:	1101                	addi	sp,sp,-32
    80000d18:	ec06                	sd	ra,24(sp)
    80000d1a:	e822                	sd	s0,16(sp)
    80000d1c:	e426                	sd	s1,8(sp)
    80000d1e:	1000                	addi	s0,sp,32
    80000d20:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    80000d22:	fb1ff0ef          	jal	80000cd2 <push_off>
  if(holding(lk))
    80000d26:	8526                	mv	a0,s1
    80000d28:	f7fff0ef          	jal	80000ca6 <holding>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000d2c:	4705                	li	a4,1
  if(holding(lk))
    80000d2e:	e105                	bnez	a0,80000d4e <acquire+0x38>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000d30:	87ba                	mv	a5,a4
    80000d32:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80000d36:	2781                	sext.w	a5,a5
    80000d38:	ffe5                	bnez	a5,80000d30 <acquire+0x1a>
  __sync_synchronize();
    80000d3a:	0330000f          	fence	rw,rw
  lk->cpu = mycpu();
    80000d3e:	6cb000ef          	jal	80001c08 <mycpu>
    80000d42:	e888                	sd	a0,16(s1)
}
    80000d44:	60e2                	ld	ra,24(sp)
    80000d46:	6442                	ld	s0,16(sp)
    80000d48:	64a2                	ld	s1,8(sp)
    80000d4a:	6105                	addi	sp,sp,32
    80000d4c:	8082                	ret
    panic("acquire");
    80000d4e:	00007517          	auipc	a0,0x7
    80000d52:	30250513          	addi	a0,a0,770 # 80008050 <etext+0x50>
    80000d56:	b01ff0ef          	jal	80000856 <panic>

0000000080000d5a <pop_off>:

void
pop_off(void)
{
    80000d5a:	1141                	addi	sp,sp,-16
    80000d5c:	e406                	sd	ra,8(sp)
    80000d5e:	e022                	sd	s0,0(sp)
    80000d60:	0800                	addi	s0,sp,16
  struct cpu *c = mycpu();
    80000d62:	6a7000ef          	jal	80001c08 <mycpu>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000d66:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80000d6a:	8b89                	andi	a5,a5,2
  if(intr_get())
    80000d6c:	e39d                	bnez	a5,80000d92 <pop_off+0x38>
    panic("pop_off - interruptible");
  if(c->noff < 1)
    80000d6e:	5d3c                	lw	a5,120(a0)
    80000d70:	02f05763          	blez	a5,80000d9e <pop_off+0x44>
    panic("pop_off");
  c->noff -= 1;
    80000d74:	37fd                	addiw	a5,a5,-1
    80000d76:	dd3c                	sw	a5,120(a0)
  if(c->noff == 0 && c->intena)
    80000d78:	eb89                	bnez	a5,80000d8a <pop_off+0x30>
    80000d7a:	5d7c                	lw	a5,124(a0)
    80000d7c:	c799                	beqz	a5,80000d8a <pop_off+0x30>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000d7e:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80000d82:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000d86:	10079073          	csrw	sstatus,a5
    intr_on();
}
    80000d8a:	60a2                	ld	ra,8(sp)
    80000d8c:	6402                	ld	s0,0(sp)
    80000d8e:	0141                	addi	sp,sp,16
    80000d90:	8082                	ret
    panic("pop_off - interruptible");
    80000d92:	00007517          	auipc	a0,0x7
    80000d96:	2c650513          	addi	a0,a0,710 # 80008058 <etext+0x58>
    80000d9a:	abdff0ef          	jal	80000856 <panic>
    panic("pop_off");
    80000d9e:	00007517          	auipc	a0,0x7
    80000da2:	2d250513          	addi	a0,a0,722 # 80008070 <etext+0x70>
    80000da6:	ab1ff0ef          	jal	80000856 <panic>

0000000080000daa <release>:
{
    80000daa:	1101                	addi	sp,sp,-32
    80000dac:	ec06                	sd	ra,24(sp)
    80000dae:	e822                	sd	s0,16(sp)
    80000db0:	e426                	sd	s1,8(sp)
    80000db2:	1000                	addi	s0,sp,32
    80000db4:	84aa                	mv	s1,a0
  if(!holding(lk))
    80000db6:	ef1ff0ef          	jal	80000ca6 <holding>
    80000dba:	c105                	beqz	a0,80000dda <release+0x30>
  lk->cpu = 0;
    80000dbc:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    80000dc0:	0330000f          	fence	rw,rw
  __sync_lock_release(&lk->locked);
    80000dc4:	0310000f          	fence	rw,w
    80000dc8:	0004a023          	sw	zero,0(s1)
  pop_off();
    80000dcc:	f8fff0ef          	jal	80000d5a <pop_off>
}
    80000dd0:	60e2                	ld	ra,24(sp)
    80000dd2:	6442                	ld	s0,16(sp)
    80000dd4:	64a2                	ld	s1,8(sp)
    80000dd6:	6105                	addi	sp,sp,32
    80000dd8:	8082                	ret
    panic("release");
    80000dda:	00007517          	auipc	a0,0x7
    80000dde:	29e50513          	addi	a0,a0,670 # 80008078 <etext+0x78>
    80000de2:	a75ff0ef          	jal	80000856 <panic>

0000000080000de6 <memset>:
#include "types.h"

void*
memset(void *dst, int c, uint n)
{
    80000de6:	1141                	addi	sp,sp,-16
    80000de8:	e406                	sd	ra,8(sp)
    80000dea:	e022                	sd	s0,0(sp)
    80000dec:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    80000dee:	ca19                	beqz	a2,80000e04 <memset+0x1e>
    80000df0:	87aa                	mv	a5,a0
    80000df2:	1602                	slli	a2,a2,0x20
    80000df4:	9201                	srli	a2,a2,0x20
    80000df6:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
    80000dfa:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    80000dfe:	0785                	addi	a5,a5,1
    80000e00:	fee79de3          	bne	a5,a4,80000dfa <memset+0x14>
  }
  return dst;
}
    80000e04:	60a2                	ld	ra,8(sp)
    80000e06:	6402                	ld	s0,0(sp)
    80000e08:	0141                	addi	sp,sp,16
    80000e0a:	8082                	ret

0000000080000e0c <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    80000e0c:	1141                	addi	sp,sp,-16
    80000e0e:	e406                	sd	ra,8(sp)
    80000e10:	e022                	sd	s0,0(sp)
    80000e12:	0800                	addi	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    80000e14:	c61d                	beqz	a2,80000e42 <memcmp+0x36>
    80000e16:	1602                	slli	a2,a2,0x20
    80000e18:	9201                	srli	a2,a2,0x20
    80000e1a:	00c506b3          	add	a3,a0,a2
    if(*s1 != *s2)
    80000e1e:	00054783          	lbu	a5,0(a0)
    80000e22:	0005c703          	lbu	a4,0(a1)
    80000e26:	00e79863          	bne	a5,a4,80000e36 <memcmp+0x2a>
      return *s1 - *s2;
    s1++, s2++;
    80000e2a:	0505                	addi	a0,a0,1
    80000e2c:	0585                	addi	a1,a1,1
  while(n-- > 0){
    80000e2e:	fed518e3          	bne	a0,a3,80000e1e <memcmp+0x12>
  }

  return 0;
    80000e32:	4501                	li	a0,0
    80000e34:	a019                	j	80000e3a <memcmp+0x2e>
      return *s1 - *s2;
    80000e36:	40e7853b          	subw	a0,a5,a4
}
    80000e3a:	60a2                	ld	ra,8(sp)
    80000e3c:	6402                	ld	s0,0(sp)
    80000e3e:	0141                	addi	sp,sp,16
    80000e40:	8082                	ret
  return 0;
    80000e42:	4501                	li	a0,0
    80000e44:	bfdd                	j	80000e3a <memcmp+0x2e>

0000000080000e46 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
    80000e46:	1141                	addi	sp,sp,-16
    80000e48:	e406                	sd	ra,8(sp)
    80000e4a:	e022                	sd	s0,0(sp)
    80000e4c:	0800                	addi	s0,sp,16
  const char *s;
  char *d;

  if(n == 0)
    80000e4e:	c205                	beqz	a2,80000e6e <memmove+0x28>
    return dst;
  
  s = src;
  d = dst;
  if(s < d && s + n > d){
    80000e50:	02a5e363          	bltu	a1,a0,80000e76 <memmove+0x30>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
    80000e54:	1602                	slli	a2,a2,0x20
    80000e56:	9201                	srli	a2,a2,0x20
    80000e58:	00c587b3          	add	a5,a1,a2
{
    80000e5c:	872a                	mv	a4,a0
      *d++ = *s++;
    80000e5e:	0585                	addi	a1,a1,1
    80000e60:	0705                	addi	a4,a4,1
    80000e62:	fff5c683          	lbu	a3,-1(a1)
    80000e66:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
    80000e6a:	feb79ae3          	bne	a5,a1,80000e5e <memmove+0x18>

  return dst;
}
    80000e6e:	60a2                	ld	ra,8(sp)
    80000e70:	6402                	ld	s0,0(sp)
    80000e72:	0141                	addi	sp,sp,16
    80000e74:	8082                	ret
  if(s < d && s + n > d){
    80000e76:	02061693          	slli	a3,a2,0x20
    80000e7a:	9281                	srli	a3,a3,0x20
    80000e7c:	00d58733          	add	a4,a1,a3
    80000e80:	fce57ae3          	bgeu	a0,a4,80000e54 <memmove+0xe>
    d += n;
    80000e84:	96aa                	add	a3,a3,a0
    while(n-- > 0)
    80000e86:	fff6079b          	addiw	a5,a2,-1 # fff <_entry-0x7ffff001>
    80000e8a:	1782                	slli	a5,a5,0x20
    80000e8c:	9381                	srli	a5,a5,0x20
    80000e8e:	fff7c793          	not	a5,a5
    80000e92:	97ba                	add	a5,a5,a4
      *--d = *--s;
    80000e94:	177d                	addi	a4,a4,-1
    80000e96:	16fd                	addi	a3,a3,-1
    80000e98:	00074603          	lbu	a2,0(a4)
    80000e9c:	00c68023          	sb	a2,0(a3)
    while(n-- > 0)
    80000ea0:	fee79ae3          	bne	a5,a4,80000e94 <memmove+0x4e>
    80000ea4:	b7e9                	j	80000e6e <memmove+0x28>

0000000080000ea6 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
    80000ea6:	1141                	addi	sp,sp,-16
    80000ea8:	e406                	sd	ra,8(sp)
    80000eaa:	e022                	sd	s0,0(sp)
    80000eac:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    80000eae:	f99ff0ef          	jal	80000e46 <memmove>
}
    80000eb2:	60a2                	ld	ra,8(sp)
    80000eb4:	6402                	ld	s0,0(sp)
    80000eb6:	0141                	addi	sp,sp,16
    80000eb8:	8082                	ret

0000000080000eba <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    80000eba:	1141                	addi	sp,sp,-16
    80000ebc:	e406                	sd	ra,8(sp)
    80000ebe:	e022                	sd	s0,0(sp)
    80000ec0:	0800                	addi	s0,sp,16
  while(n > 0 && *p && *p == *q)
    80000ec2:	ce11                	beqz	a2,80000ede <strncmp+0x24>
    80000ec4:	00054783          	lbu	a5,0(a0)
    80000ec8:	cf89                	beqz	a5,80000ee2 <strncmp+0x28>
    80000eca:	0005c703          	lbu	a4,0(a1)
    80000ece:	00f71a63          	bne	a4,a5,80000ee2 <strncmp+0x28>
    n--, p++, q++;
    80000ed2:	367d                	addiw	a2,a2,-1
    80000ed4:	0505                	addi	a0,a0,1
    80000ed6:	0585                	addi	a1,a1,1
  while(n > 0 && *p && *p == *q)
    80000ed8:	f675                	bnez	a2,80000ec4 <strncmp+0xa>
  if(n == 0)
    return 0;
    80000eda:	4501                	li	a0,0
    80000edc:	a801                	j	80000eec <strncmp+0x32>
    80000ede:	4501                	li	a0,0
    80000ee0:	a031                	j	80000eec <strncmp+0x32>
  return (uchar)*p - (uchar)*q;
    80000ee2:	00054503          	lbu	a0,0(a0)
    80000ee6:	0005c783          	lbu	a5,0(a1)
    80000eea:	9d1d                	subw	a0,a0,a5
}
    80000eec:	60a2                	ld	ra,8(sp)
    80000eee:	6402                	ld	s0,0(sp)
    80000ef0:	0141                	addi	sp,sp,16
    80000ef2:	8082                	ret

0000000080000ef4 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    80000ef4:	1141                	addi	sp,sp,-16
    80000ef6:	e406                	sd	ra,8(sp)
    80000ef8:	e022                	sd	s0,0(sp)
    80000efa:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    80000efc:	87aa                	mv	a5,a0
    80000efe:	a011                	j	80000f02 <strncpy+0xe>
    80000f00:	8636                	mv	a2,a3
    80000f02:	02c05863          	blez	a2,80000f32 <strncpy+0x3e>
    80000f06:	fff6069b          	addiw	a3,a2,-1
    80000f0a:	8836                	mv	a6,a3
    80000f0c:	0785                	addi	a5,a5,1
    80000f0e:	0005c703          	lbu	a4,0(a1)
    80000f12:	fee78fa3          	sb	a4,-1(a5)
    80000f16:	0585                	addi	a1,a1,1
    80000f18:	f765                	bnez	a4,80000f00 <strncpy+0xc>
    ;
  while(n-- > 0)
    80000f1a:	873e                	mv	a4,a5
    80000f1c:	01005b63          	blez	a6,80000f32 <strncpy+0x3e>
    80000f20:	9fb1                	addw	a5,a5,a2
    80000f22:	37fd                	addiw	a5,a5,-1
    *s++ = 0;
    80000f24:	0705                	addi	a4,a4,1
    80000f26:	fe070fa3          	sb	zero,-1(a4)
  while(n-- > 0)
    80000f2a:	40e786bb          	subw	a3,a5,a4
    80000f2e:	fed04be3          	bgtz	a3,80000f24 <strncpy+0x30>
  return os;
}
    80000f32:	60a2                	ld	ra,8(sp)
    80000f34:	6402                	ld	s0,0(sp)
    80000f36:	0141                	addi	sp,sp,16
    80000f38:	8082                	ret

0000000080000f3a <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
    80000f3a:	1141                	addi	sp,sp,-16
    80000f3c:	e406                	sd	ra,8(sp)
    80000f3e:	e022                	sd	s0,0(sp)
    80000f40:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  if(n <= 0)
    80000f42:	02c05363          	blez	a2,80000f68 <safestrcpy+0x2e>
    80000f46:	fff6069b          	addiw	a3,a2,-1
    80000f4a:	1682                	slli	a3,a3,0x20
    80000f4c:	9281                	srli	a3,a3,0x20
    80000f4e:	96ae                	add	a3,a3,a1
    80000f50:	87aa                	mv	a5,a0
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
    80000f52:	00d58963          	beq	a1,a3,80000f64 <safestrcpy+0x2a>
    80000f56:	0585                	addi	a1,a1,1
    80000f58:	0785                	addi	a5,a5,1
    80000f5a:	fff5c703          	lbu	a4,-1(a1)
    80000f5e:	fee78fa3          	sb	a4,-1(a5)
    80000f62:	fb65                	bnez	a4,80000f52 <safestrcpy+0x18>
    ;
  *s = 0;
    80000f64:	00078023          	sb	zero,0(a5)
  return os;
}
    80000f68:	60a2                	ld	ra,8(sp)
    80000f6a:	6402                	ld	s0,0(sp)
    80000f6c:	0141                	addi	sp,sp,16
    80000f6e:	8082                	ret

0000000080000f70 <strlen>:

int
strlen(const char *s)
{
    80000f70:	1141                	addi	sp,sp,-16
    80000f72:	e406                	sd	ra,8(sp)
    80000f74:	e022                	sd	s0,0(sp)
    80000f76:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    80000f78:	00054783          	lbu	a5,0(a0)
    80000f7c:	cf91                	beqz	a5,80000f98 <strlen+0x28>
    80000f7e:	00150793          	addi	a5,a0,1
    80000f82:	86be                	mv	a3,a5
    80000f84:	0785                	addi	a5,a5,1
    80000f86:	fff7c703          	lbu	a4,-1(a5)
    80000f8a:	ff65                	bnez	a4,80000f82 <strlen+0x12>
    80000f8c:	40a6853b          	subw	a0,a3,a0
    ;
  return n;
}
    80000f90:	60a2                	ld	ra,8(sp)
    80000f92:	6402                	ld	s0,0(sp)
    80000f94:	0141                	addi	sp,sp,16
    80000f96:	8082                	ret
  for(n = 0; s[n]; n++)
    80000f98:	4501                	li	a0,0
    80000f9a:	bfdd                	j	80000f90 <strlen+0x20>

0000000080000f9c <main>:
volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    80000f9c:	1141                	addi	sp,sp,-16
    80000f9e:	e406                	sd	ra,8(sp)
    80000fa0:	e022                	sd	s0,0(sp)
    80000fa2:	0800                	addi	s0,sp,16
  if(cpuid() == 0){
    80000fa4:	451000ef          	jal	80001bf4 <cpuid>
    memlog_init();
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    80000fa8:	00008717          	auipc	a4,0x8
    80000fac:	96870713          	addi	a4,a4,-1688 # 80008910 <started>
  if(cpuid() == 0){
    80000fb0:	c51d                	beqz	a0,80000fde <main+0x42>
    while(started == 0)
    80000fb2:	431c                	lw	a5,0(a4)
    80000fb4:	2781                	sext.w	a5,a5
    80000fb6:	dff5                	beqz	a5,80000fb2 <main+0x16>
      ;
    __sync_synchronize();
    80000fb8:	0330000f          	fence	rw,rw
    printf("hart %d starting\n", cpuid());
    80000fbc:	439000ef          	jal	80001bf4 <cpuid>
    80000fc0:	85aa                	mv	a1,a0
    80000fc2:	00007517          	auipc	a0,0x7
    80000fc6:	0de50513          	addi	a0,a0,222 # 800080a0 <etext+0xa0>
    80000fca:	d62ff0ef          	jal	8000052c <printf>
    kvminithart();    // turn on paging
    80000fce:	08c000ef          	jal	8000105a <kvminithart>
    trapinithart();   // install kernel trap vector
    80000fd2:	1c1010ef          	jal	80002992 <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000fd6:	2e3040ef          	jal	80005ab8 <plicinithart>
  }

  scheduler();        
    80000fda:	14e010ef          	jal	80002128 <scheduler>
    consoleinit();
    80000fde:	c60ff0ef          	jal	8000043e <consoleinit>
    printfinit();
    80000fe2:	8b1ff0ef          	jal	80000892 <printfinit>
    printf("\n");
    80000fe6:	00007517          	auipc	a0,0x7
    80000fea:	09a50513          	addi	a0,a0,154 # 80008080 <etext+0x80>
    80000fee:	d3eff0ef          	jal	8000052c <printf>
    printf("xv6 kernel is booting\n");
    80000ff2:	00007517          	auipc	a0,0x7
    80000ff6:	09650513          	addi	a0,a0,150 # 80008088 <etext+0x88>
    80000ffa:	d32ff0ef          	jal	8000052c <printf>
    printf("\n");
    80000ffe:	00007517          	auipc	a0,0x7
    80001002:	08250513          	addi	a0,a0,130 # 80008080 <etext+0x80>
    80001006:	d26ff0ef          	jal	8000052c <printf>
    kinit();         // physical page allocator
    8000100a:	b97ff0ef          	jal	80000ba0 <kinit>
    kvminit();       // create kernel page table
    8000100e:	358000ef          	jal	80001366 <kvminit>
    kvminithart();   // turn on paging
    80001012:	048000ef          	jal	8000105a <kvminithart>
    procinit();      // process table
    80001016:	315000ef          	jal	80001b2a <procinit>
    schedlog_init();
    8000101a:	71c050ef          	jal	80006736 <schedlog_init>
    trapinit();      // trap vectors
    8000101e:	151010ef          	jal	8000296e <trapinit>
    trapinithart();  // install kernel trap vector
    80001022:	171010ef          	jal	80002992 <trapinithart>
    plicinit();      // set up interrupt controller
    80001026:	279040ef          	jal	80005a9e <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    8000102a:	28f040ef          	jal	80005ab8 <plicinithart>
    binit();         // buffer cache
    8000102e:	090020ef          	jal	800030be <binit>
    iinit();         // inode table
    80001032:	620020ef          	jal	80003652 <iinit>
    fileinit();      // file table
    80001036:	54c030ef          	jal	80004582 <fileinit>
    virtio_disk_init(); // emulated hard disk
    8000103a:	36f040ef          	jal	80005ba8 <virtio_disk_init>
    cslog_init();
    8000103e:	7f1040ef          	jal	8000602e <cslog_init>
    memlog_init();
    80001042:	476050ef          	jal	800064b8 <memlog_init>
    userinit();      // first user process
    80001046:	6ad000ef          	jal	80001ef2 <userinit>
    __sync_synchronize();
    8000104a:	0330000f          	fence	rw,rw
    started = 1;
    8000104e:	4785                	li	a5,1
    80001050:	00008717          	auipc	a4,0x8
    80001054:	8cf72023          	sw	a5,-1856(a4) # 80008910 <started>
    80001058:	b749                	j	80000fda <main+0x3e>

000000008000105a <kvminithart>:

// Switch the current CPU's h/w page table register to
// the kernel's page table, and enable paging.
void
kvminithart()
{
    8000105a:	1141                	addi	sp,sp,-16
    8000105c:	e406                	sd	ra,8(sp)
    8000105e:	e022                	sd	s0,0(sp)
    80001060:	0800                	addi	s0,sp,16
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero");
    80001062:	12000073          	sfence.vma
  // wait for any previous writes to the page table memory to finish.
  sfence_vma();

  w_satp(MAKE_SATP(kernel_pagetable));
    80001066:	00008797          	auipc	a5,0x8
    8000106a:	8b27b783          	ld	a5,-1870(a5) # 80008918 <kernel_pagetable>
    8000106e:	83b1                	srli	a5,a5,0xc
    80001070:	577d                	li	a4,-1
    80001072:	177e                	slli	a4,a4,0x3f
    80001074:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r" (x));
    80001076:	18079073          	csrw	satp,a5
  asm volatile("sfence.vma zero, zero");
    8000107a:	12000073          	sfence.vma

  // flush stale entries from the TLB.
  sfence_vma();
}
    8000107e:	60a2                	ld	ra,8(sp)
    80001080:	6402                	ld	s0,0(sp)
    80001082:	0141                	addi	sp,sp,16
    80001084:	8082                	ret

0000000080001086 <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    80001086:	7139                	addi	sp,sp,-64
    80001088:	fc06                	sd	ra,56(sp)
    8000108a:	f822                	sd	s0,48(sp)
    8000108c:	f426                	sd	s1,40(sp)
    8000108e:	f04a                	sd	s2,32(sp)
    80001090:	ec4e                	sd	s3,24(sp)
    80001092:	e852                	sd	s4,16(sp)
    80001094:	e456                	sd	s5,8(sp)
    80001096:	e05a                	sd	s6,0(sp)
    80001098:	0080                	addi	s0,sp,64
    8000109a:	84aa                	mv	s1,a0
    8000109c:	89ae                	mv	s3,a1
    8000109e:	8b32                	mv	s6,a2
  if(va >= MAXVA)
    800010a0:	57fd                	li	a5,-1
    800010a2:	83e9                	srli	a5,a5,0x1a
    800010a4:	4a79                	li	s4,30
    panic("walk");

  for(int level = 2; level > 0; level--) {
    800010a6:	4ab1                	li	s5,12
  if(va >= MAXVA)
    800010a8:	04b7e263          	bltu	a5,a1,800010ec <walk+0x66>
    pte_t *pte = &pagetable[PX(level, va)];
    800010ac:	0149d933          	srl	s2,s3,s4
    800010b0:	1ff97913          	andi	s2,s2,511
    800010b4:	090e                	slli	s2,s2,0x3
    800010b6:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) {
    800010b8:	00093483          	ld	s1,0(s2)
    800010bc:	0014f793          	andi	a5,s1,1
    800010c0:	cf85                	beqz	a5,800010f8 <walk+0x72>
      pagetable = (pagetable_t)PTE2PA(*pte);
    800010c2:	80a9                	srli	s1,s1,0xa
    800010c4:	04b2                	slli	s1,s1,0xc
  for(int level = 2; level > 0; level--) {
    800010c6:	3a5d                	addiw	s4,s4,-9
    800010c8:	ff5a12e3          	bne	s4,s5,800010ac <walk+0x26>
        return 0;
      memset(pagetable, 0, PGSIZE);
      *pte = PA2PTE(pagetable) | PTE_V;
    }
  }
  return &pagetable[PX(0, va)];
    800010cc:	00c9d513          	srli	a0,s3,0xc
    800010d0:	1ff57513          	andi	a0,a0,511
    800010d4:	050e                	slli	a0,a0,0x3
    800010d6:	9526                	add	a0,a0,s1
}
    800010d8:	70e2                	ld	ra,56(sp)
    800010da:	7442                	ld	s0,48(sp)
    800010dc:	74a2                	ld	s1,40(sp)
    800010de:	7902                	ld	s2,32(sp)
    800010e0:	69e2                	ld	s3,24(sp)
    800010e2:	6a42                	ld	s4,16(sp)
    800010e4:	6aa2                	ld	s5,8(sp)
    800010e6:	6b02                	ld	s6,0(sp)
    800010e8:	6121                	addi	sp,sp,64
    800010ea:	8082                	ret
    panic("walk");
    800010ec:	00007517          	auipc	a0,0x7
    800010f0:	fcc50513          	addi	a0,a0,-52 # 800080b8 <etext+0xb8>
    800010f4:	f62ff0ef          	jal	80000856 <panic>
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    800010f8:	020b0263          	beqz	s6,8000111c <walk+0x96>
    800010fc:	ad9ff0ef          	jal	80000bd4 <kalloc>
    80001100:	84aa                	mv	s1,a0
    80001102:	d979                	beqz	a0,800010d8 <walk+0x52>
      memset(pagetable, 0, PGSIZE);
    80001104:	6605                	lui	a2,0x1
    80001106:	4581                	li	a1,0
    80001108:	cdfff0ef          	jal	80000de6 <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    8000110c:	00c4d793          	srli	a5,s1,0xc
    80001110:	07aa                	slli	a5,a5,0xa
    80001112:	0017e793          	ori	a5,a5,1
    80001116:	00f93023          	sd	a5,0(s2)
    8000111a:	b775                	j	800010c6 <walk+0x40>
        return 0;
    8000111c:	4501                	li	a0,0
    8000111e:	bf6d                	j	800010d8 <walk+0x52>

0000000080001120 <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if(va >= MAXVA)
    80001120:	57fd                	li	a5,-1
    80001122:	83e9                	srli	a5,a5,0x1a
    80001124:	00b7f463          	bgeu	a5,a1,8000112c <walkaddr+0xc>
    return 0;
    80001128:	4501                	li	a0,0
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}
    8000112a:	8082                	ret
{
    8000112c:	1141                	addi	sp,sp,-16
    8000112e:	e406                	sd	ra,8(sp)
    80001130:	e022                	sd	s0,0(sp)
    80001132:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    80001134:	4601                	li	a2,0
    80001136:	f51ff0ef          	jal	80001086 <walk>
  if(pte == 0)
    8000113a:	c901                	beqz	a0,8000114a <walkaddr+0x2a>
  if((*pte & PTE_V) == 0)
    8000113c:	611c                	ld	a5,0(a0)
  if((*pte & PTE_U) == 0)
    8000113e:	0117f693          	andi	a3,a5,17
    80001142:	4745                	li	a4,17
    return 0;
    80001144:	4501                	li	a0,0
  if((*pte & PTE_U) == 0)
    80001146:	00e68663          	beq	a3,a4,80001152 <walkaddr+0x32>
}
    8000114a:	60a2                	ld	ra,8(sp)
    8000114c:	6402                	ld	s0,0(sp)
    8000114e:	0141                	addi	sp,sp,16
    80001150:	8082                	ret
  pa = PTE2PA(*pte);
    80001152:	83a9                	srli	a5,a5,0xa
    80001154:	00c79513          	slli	a0,a5,0xc
  return pa;
    80001158:	bfcd                	j	8000114a <walkaddr+0x2a>

000000008000115a <mappages>:
// va and size MUST be page-aligned.
// Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    8000115a:	7115                	addi	sp,sp,-224
    8000115c:	ed86                	sd	ra,216(sp)
    8000115e:	e9a2                	sd	s0,208(sp)
    80001160:	e5a6                	sd	s1,200(sp)
    80001162:	e1ca                	sd	s2,192(sp)
    80001164:	fd4e                	sd	s3,184(sp)
    80001166:	f952                	sd	s4,176(sp)
    80001168:	f556                	sd	s5,168(sp)
    8000116a:	f15a                	sd	s6,160(sp)
    8000116c:	ed5e                	sd	s7,152(sp)
    8000116e:	e962                	sd	s8,144(sp)
    80001170:	e566                	sd	s9,136(sp)
    80001172:	e16a                	sd	s10,128(sp)
    80001174:	fcee                	sd	s11,120(sp)
    80001176:	1180                	addi	s0,sp,224
  uint64 a, last;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    80001178:	03459793          	slli	a5,a1,0x34
    8000117c:	eb8d                	bnez	a5,800011ae <mappages+0x54>
    8000117e:	8c2a                	mv	s8,a0
    80001180:	8aba                	mv	s5,a4
    panic("mappages: va not aligned");

  if((size % PGSIZE) != 0)
    80001182:	03461793          	slli	a5,a2,0x34
    80001186:	eb95                	bnez	a5,800011ba <mappages+0x60>
    panic("mappages: size not aligned");

  if(size == 0)
    80001188:	ce1d                	beqz	a2,800011c6 <mappages+0x6c>
    panic("mappages: size");
  
  a = va;
  last = va + size - PGSIZE;
    8000118a:	80060613          	addi	a2,a2,-2048 # 800 <_entry-0x7ffff800>
    8000118e:	80060613          	addi	a2,a2,-2048
    80001192:	00b60a33          	add	s4,a2,a1
  a = va;
    80001196:	892e                	mv	s2,a1
  for(;;){
       if((pte = walk(pagetable, a, 1)) == 0)
    80001198:	4b05                	li	s6,1
    8000119a:	40b68bb3          	sub	s7,a3,a1
    *pte = PA2PTE(pa) | perm | PTE_V;

    struct proc *p = myproc();
    if(p){
      struct mem_event e;
      memset(&e, 0, sizeof(e));
    8000119e:	f2840c93          	addi	s9,s0,-216
      e.ticks  = ticks;
    800011a2:	00007d97          	auipc	s11,0x7
    800011a6:	78ed8d93          	addi	s11,s11,1934 # 80008930 <ticks>
      e.cpu    = cpuid();
      e.type   = MEM_MAP;
    800011aa:	4d11                	li	s10,4
    800011ac:	a82d                	j	800011e6 <mappages+0x8c>
    panic("mappages: va not aligned");
    800011ae:	00007517          	auipc	a0,0x7
    800011b2:	f1250513          	addi	a0,a0,-238 # 800080c0 <etext+0xc0>
    800011b6:	ea0ff0ef          	jal	80000856 <panic>
    panic("mappages: size not aligned");
    800011ba:	00007517          	auipc	a0,0x7
    800011be:	f2650513          	addi	a0,a0,-218 # 800080e0 <etext+0xe0>
    800011c2:	e94ff0ef          	jal	80000856 <panic>
    panic("mappages: size");
    800011c6:	00007517          	auipc	a0,0x7
    800011ca:	f3a50513          	addi	a0,a0,-198 # 80008100 <etext+0x100>
    800011ce:	e88ff0ef          	jal	80000856 <panic>
      panic("mappages: remap");
    800011d2:	00007517          	auipc	a0,0x7
    800011d6:	f3e50513          	addi	a0,a0,-194 # 80008110 <etext+0x110>
    800011da:	e7cff0ef          	jal	80000856 <panic>
      e.kind   = PAGE_USER;
      safestrcpy(e.name, p->name, MEM_NM);
      memlog_push(&e);
    }

    if(a == last)
    800011de:	0b490763          	beq	s2,s4,8000128c <mappages+0x132>
      break;
    a += PGSIZE;
    800011e2:	6785                	lui	a5,0x1
    800011e4:	993e                	add	s2,s2,a5
       if((pte = walk(pagetable, a, 1)) == 0)
    800011e6:	865a                	mv	a2,s6
    800011e8:	85ca                	mv	a1,s2
    800011ea:	8562                	mv	a0,s8
    800011ec:	e9bff0ef          	jal	80001086 <walk>
    800011f0:	cd35                	beqz	a0,8000126c <mappages+0x112>
    if(*pte & PTE_V)
    800011f2:	611c                	ld	a5,0(a0)
    800011f4:	8b85                	andi	a5,a5,1
    800011f6:	fff1                	bnez	a5,800011d2 <mappages+0x78>
    800011f8:	017909b3          	add	s3,s2,s7
    *pte = PA2PTE(pa) | perm | PTE_V;
    800011fc:	00c9d793          	srli	a5,s3,0xc
    80001200:	07aa                	slli	a5,a5,0xa
    80001202:	0157e7b3          	or	a5,a5,s5
    80001206:	0017e793          	ori	a5,a5,1
    8000120a:	e11c                	sd	a5,0(a0)
    struct proc *p = myproc();
    8000120c:	21d000ef          	jal	80001c28 <myproc>
    80001210:	84aa                	mv	s1,a0
    if(p){
    80001212:	d571                	beqz	a0,800011de <mappages+0x84>
      memset(&e, 0, sizeof(e));
    80001214:	06800613          	li	a2,104
    80001218:	4581                	li	a1,0
    8000121a:	8566                	mv	a0,s9
    8000121c:	bcbff0ef          	jal	80000de6 <memset>
      e.ticks  = ticks;
    80001220:	000da783          	lw	a5,0(s11)
    80001224:	f2f42823          	sw	a5,-208(s0)
      e.cpu    = cpuid();
    80001228:	1cd000ef          	jal	80001bf4 <cpuid>
    8000122c:	f2a42a23          	sw	a0,-204(s0)
      e.type   = MEM_MAP;
    80001230:	f3a42c23          	sw	s10,-200(s0)
      e.pid    = p->pid;
    80001234:	589c                	lw	a5,48(s1)
    80001236:	f2f42e23          	sw	a5,-196(s0)
      e.state  = p->state;
    8000123a:	4c9c                	lw	a5,24(s1)
    8000123c:	f4f42023          	sw	a5,-192(s0)
      e.va     = a;
    80001240:	f5243c23          	sd	s2,-168(s0)
      e.pa     = pa;
    80001244:	f7343023          	sd	s3,-160(s0)
      e.perm   = perm;
    80001248:	f9542023          	sw	s5,-128(s0)
      e.source = SRC_MAPPAGES;
    8000124c:	478d                	li	a5,3
    8000124e:	f8f42223          	sw	a5,-124(s0)
      e.kind   = PAGE_USER;
    80001252:	f9642423          	sw	s6,-120(s0)
      safestrcpy(e.name, p->name, MEM_NM);
    80001256:	4641                	li	a2,16
    80001258:	15848593          	addi	a1,s1,344
    8000125c:	f4440513          	addi	a0,s0,-188
    80001260:	cdbff0ef          	jal	80000f3a <safestrcpy>
      memlog_push(&e);
    80001264:	8566                	mv	a0,s9
    80001266:	296050ef          	jal	800064fc <memlog_push>
    8000126a:	bf95                	j	800011de <mappages+0x84>
      return -1;
    8000126c:	557d                	li	a0,-1
    pa += PGSIZE;
  }
  return 0;
}
    8000126e:	60ee                	ld	ra,216(sp)
    80001270:	644e                	ld	s0,208(sp)
    80001272:	64ae                	ld	s1,200(sp)
    80001274:	690e                	ld	s2,192(sp)
    80001276:	79ea                	ld	s3,184(sp)
    80001278:	7a4a                	ld	s4,176(sp)
    8000127a:	7aaa                	ld	s5,168(sp)
    8000127c:	7b0a                	ld	s6,160(sp)
    8000127e:	6bea                	ld	s7,152(sp)
    80001280:	6c4a                	ld	s8,144(sp)
    80001282:	6caa                	ld	s9,136(sp)
    80001284:	6d0a                	ld	s10,128(sp)
    80001286:	7de6                	ld	s11,120(sp)
    80001288:	612d                	addi	sp,sp,224
    8000128a:	8082                	ret
  return 0;
    8000128c:	4501                	li	a0,0
    8000128e:	b7c5                	j	8000126e <mappages+0x114>

0000000080001290 <kvmmap>:
{
    80001290:	1141                	addi	sp,sp,-16
    80001292:	e406                	sd	ra,8(sp)
    80001294:	e022                	sd	s0,0(sp)
    80001296:	0800                	addi	s0,sp,16
    80001298:	87b6                	mv	a5,a3
  if(mappages(kpgtbl, va, sz, pa, perm) != 0)
    8000129a:	86b2                	mv	a3,a2
    8000129c:	863e                	mv	a2,a5
    8000129e:	ebdff0ef          	jal	8000115a <mappages>
    800012a2:	e509                	bnez	a0,800012ac <kvmmap+0x1c>
}
    800012a4:	60a2                	ld	ra,8(sp)
    800012a6:	6402                	ld	s0,0(sp)
    800012a8:	0141                	addi	sp,sp,16
    800012aa:	8082                	ret
    panic("kvmmap");
    800012ac:	00007517          	auipc	a0,0x7
    800012b0:	e7450513          	addi	a0,a0,-396 # 80008120 <etext+0x120>
    800012b4:	da2ff0ef          	jal	80000856 <panic>

00000000800012b8 <kvmmake>:
{
    800012b8:	1101                	addi	sp,sp,-32
    800012ba:	ec06                	sd	ra,24(sp)
    800012bc:	e822                	sd	s0,16(sp)
    800012be:	e426                	sd	s1,8(sp)
    800012c0:	1000                	addi	s0,sp,32
  kpgtbl = (pagetable_t) kalloc();
    800012c2:	913ff0ef          	jal	80000bd4 <kalloc>
    800012c6:	84aa                	mv	s1,a0
  memset(kpgtbl, 0, PGSIZE);
    800012c8:	6605                	lui	a2,0x1
    800012ca:	4581                	li	a1,0
    800012cc:	b1bff0ef          	jal	80000de6 <memset>
  kvmmap(kpgtbl, UART0, UART0, PGSIZE, PTE_R | PTE_W);
    800012d0:	4719                	li	a4,6
    800012d2:	6685                	lui	a3,0x1
    800012d4:	10000637          	lui	a2,0x10000
    800012d8:	85b2                	mv	a1,a2
    800012da:	8526                	mv	a0,s1
    800012dc:	fb5ff0ef          	jal	80001290 <kvmmap>
  kvmmap(kpgtbl, VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    800012e0:	4719                	li	a4,6
    800012e2:	6685                	lui	a3,0x1
    800012e4:	10001637          	lui	a2,0x10001
    800012e8:	85b2                	mv	a1,a2
    800012ea:	8526                	mv	a0,s1
    800012ec:	fa5ff0ef          	jal	80001290 <kvmmap>
  kvmmap(kpgtbl, PLIC, PLIC, 0x4000000, PTE_R | PTE_W);
    800012f0:	4719                	li	a4,6
    800012f2:	040006b7          	lui	a3,0x4000
    800012f6:	0c000637          	lui	a2,0xc000
    800012fa:	85b2                	mv	a1,a2
    800012fc:	8526                	mv	a0,s1
    800012fe:	f93ff0ef          	jal	80001290 <kvmmap>
  kvmmap(kpgtbl, KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    80001302:	4729                	li	a4,10
    80001304:	80007697          	auipc	a3,0x80007
    80001308:	cfc68693          	addi	a3,a3,-772 # 8000 <_entry-0x7fff8000>
    8000130c:	4605                	li	a2,1
    8000130e:	067e                	slli	a2,a2,0x1f
    80001310:	85b2                	mv	a1,a2
    80001312:	8526                	mv	a0,s1
    80001314:	f7dff0ef          	jal	80001290 <kvmmap>
  kvmmap(kpgtbl, (uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    80001318:	4719                	li	a4,6
    8000131a:	00007697          	auipc	a3,0x7
    8000131e:	ce668693          	addi	a3,a3,-794 # 80008000 <etext>
    80001322:	47c5                	li	a5,17
    80001324:	07ee                	slli	a5,a5,0x1b
    80001326:	40d786b3          	sub	a3,a5,a3
    8000132a:	00007617          	auipc	a2,0x7
    8000132e:	cd660613          	addi	a2,a2,-810 # 80008000 <etext>
    80001332:	85b2                	mv	a1,a2
    80001334:	8526                	mv	a0,s1
    80001336:	f5bff0ef          	jal	80001290 <kvmmap>
  kvmmap(kpgtbl, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    8000133a:	4729                	li	a4,10
    8000133c:	6685                	lui	a3,0x1
    8000133e:	00006617          	auipc	a2,0x6
    80001342:	cc260613          	addi	a2,a2,-830 # 80007000 <_trampoline>
    80001346:	040005b7          	lui	a1,0x4000
    8000134a:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    8000134c:	05b2                	slli	a1,a1,0xc
    8000134e:	8526                	mv	a0,s1
    80001350:	f41ff0ef          	jal	80001290 <kvmmap>
  proc_mapstacks(kpgtbl);
    80001354:	8526                	mv	a0,s1
    80001356:	730000ef          	jal	80001a86 <proc_mapstacks>
}
    8000135a:	8526                	mv	a0,s1
    8000135c:	60e2                	ld	ra,24(sp)
    8000135e:	6442                	ld	s0,16(sp)
    80001360:	64a2                	ld	s1,8(sp)
    80001362:	6105                	addi	sp,sp,32
    80001364:	8082                	ret

0000000080001366 <kvminit>:
{
    80001366:	1141                	addi	sp,sp,-16
    80001368:	e406                	sd	ra,8(sp)
    8000136a:	e022                	sd	s0,0(sp)
    8000136c:	0800                	addi	s0,sp,16
  kernel_pagetable = kvmmake();
    8000136e:	f4bff0ef          	jal	800012b8 <kvmmake>
    80001372:	00007797          	auipc	a5,0x7
    80001376:	5aa7b323          	sd	a0,1446(a5) # 80008918 <kernel_pagetable>
}
    8000137a:	60a2                	ld	ra,8(sp)
    8000137c:	6402                	ld	s0,0(sp)
    8000137e:	0141                	addi	sp,sp,16
    80001380:	8082                	ret

0000000080001382 <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    80001382:	1101                	addi	sp,sp,-32
    80001384:	ec06                	sd	ra,24(sp)
    80001386:	e822                	sd	s0,16(sp)
    80001388:	e426                	sd	s1,8(sp)
    8000138a:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t) kalloc();
    8000138c:	849ff0ef          	jal	80000bd4 <kalloc>
    80001390:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001392:	c509                	beqz	a0,8000139c <uvmcreate+0x1a>
    return 0;
  memset(pagetable, 0, PGSIZE);
    80001394:	6605                	lui	a2,0x1
    80001396:	4581                	li	a1,0
    80001398:	a4fff0ef          	jal	80000de6 <memset>
  return pagetable;
}
    8000139c:	8526                	mv	a0,s1
    8000139e:	60e2                	ld	ra,24(sp)
    800013a0:	6442                	ld	s0,16(sp)
    800013a2:	64a2                	ld	s1,8(sp)
    800013a4:	6105                	addi	sp,sp,32
    800013a6:	8082                	ret

00000000800013a8 <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. It's OK if the mappings don't exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    800013a8:	7115                	addi	sp,sp,-224
    800013aa:	ed86                	sd	ra,216(sp)
    800013ac:	e9a2                	sd	s0,208(sp)
    800013ae:	1180                	addi	s0,sp,224
  uint64 a;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    800013b0:	03459793          	slli	a5,a1,0x34
    800013b4:	ef8d                	bnez	a5,800013ee <uvmunmap+0x46>
    800013b6:	e1ca                	sd	s2,192(sp)
    800013b8:	f556                	sd	s5,168(sp)
    800013ba:	f15a                	sd	s6,160(sp)
    800013bc:	e962                	sd	s8,144(sp)
    800013be:	8b2a                	mv	s6,a0
    800013c0:	892e                	mv	s2,a1
    800013c2:	8c36                	mv	s8,a3
    panic("uvmunmap: not aligned");

  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800013c4:	0632                	slli	a2,a2,0xc
    800013c6:	00b60ab3          	add	s5,a2,a1
    800013ca:	0f55f763          	bgeu	a1,s5,800014b8 <uvmunmap+0x110>
    800013ce:	e5a6                	sd	s1,200(sp)
    800013d0:	fd4e                	sd	s3,184(sp)
    800013d2:	f952                	sd	s4,176(sp)
    800013d4:	ed5e                	sd	s7,152(sp)
    800013d6:	e566                	sd	s9,136(sp)
    800013d8:	e16a                	sd	s10,128(sp)
    800013da:	fcee                	sd	s11,120(sp)
    uint64 pa = PTE2PA(*pte);

    struct proc *p = myproc();
    if(p){
      struct mem_event e;
      memset(&e, 0, sizeof(e));
    800013dc:	f2840c93          	addi	s9,s0,-216
      e.ticks  = ticks;
    800013e0:	00007d97          	auipc	s11,0x7
    800013e4:	550d8d93          	addi	s11,s11,1360 # 80008930 <ticks>
      e.cpu    = cpuid();
      e.type   = MEM_UNMAP;
    800013e8:	4d15                	li	s10,5
      e.pid    = p->pid;
      e.state  = p->state;
      e.va     = a;
      e.pa     = pa;
      e.len    = PGSIZE;
    800013ea:	6b85                	lui	s7,0x1
    800013ec:	a80d                	j	8000141e <uvmunmap+0x76>
    800013ee:	e5a6                	sd	s1,200(sp)
    800013f0:	e1ca                	sd	s2,192(sp)
    800013f2:	fd4e                	sd	s3,184(sp)
    800013f4:	f952                	sd	s4,176(sp)
    800013f6:	f556                	sd	s5,168(sp)
    800013f8:	f15a                	sd	s6,160(sp)
    800013fa:	ed5e                	sd	s7,152(sp)
    800013fc:	e962                	sd	s8,144(sp)
    800013fe:	e566                	sd	s9,136(sp)
    80001400:	e16a                	sd	s10,128(sp)
    80001402:	fcee                	sd	s11,120(sp)
    panic("uvmunmap: not aligned");
    80001404:	00007517          	auipc	a0,0x7
    80001408:	d2450513          	addi	a0,a0,-732 # 80008128 <etext+0x128>
    8000140c:	c4aff0ef          	jal	80000856 <panic>
      e.kind   = PAGE_USER;
      safestrcpy(e.name, p->name, MEM_NM);
      memlog_push(&e);
    }

    if(do_free){
    80001410:	080c1963          	bnez	s8,800014a2 <uvmunmap+0xfa>
      kfree((void*)pa);
    }
    *pte = 0;
    80001414:	0004b023          	sd	zero,0(s1)
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80001418:	995e                	add	s2,s2,s7
    8000141a:	09597863          	bgeu	s2,s5,800014aa <uvmunmap+0x102>
    if((pte = walk(pagetable, a, 0)) == 0)
    8000141e:	4601                	li	a2,0
    80001420:	85ca                	mv	a1,s2
    80001422:	855a                	mv	a0,s6
    80001424:	c63ff0ef          	jal	80001086 <walk>
    80001428:	84aa                	mv	s1,a0
    8000142a:	d57d                	beqz	a0,80001418 <uvmunmap+0x70>
    if((*pte & PTE_V) == 0)
    8000142c:	00053983          	ld	s3,0(a0)
    80001430:	0019f793          	andi	a5,s3,1
    80001434:	d3f5                	beqz	a5,80001418 <uvmunmap+0x70>
    uint64 pa = PTE2PA(*pte);
    80001436:	00a9d993          	srli	s3,s3,0xa
    8000143a:	09b2                	slli	s3,s3,0xc
    struct proc *p = myproc();
    8000143c:	7ec000ef          	jal	80001c28 <myproc>
    80001440:	8a2a                	mv	s4,a0
    if(p){
    80001442:	d579                	beqz	a0,80001410 <uvmunmap+0x68>
      memset(&e, 0, sizeof(e));
    80001444:	06800613          	li	a2,104
    80001448:	4581                	li	a1,0
    8000144a:	8566                	mv	a0,s9
    8000144c:	99bff0ef          	jal	80000de6 <memset>
      e.ticks  = ticks;
    80001450:	000da783          	lw	a5,0(s11)
    80001454:	f2f42823          	sw	a5,-208(s0)
      e.cpu    = cpuid();
    80001458:	79c000ef          	jal	80001bf4 <cpuid>
    8000145c:	f2a42a23          	sw	a0,-204(s0)
      e.type   = MEM_UNMAP;
    80001460:	f3a42c23          	sw	s10,-200(s0)
      e.pid    = p->pid;
    80001464:	030a2783          	lw	a5,48(s4)
    80001468:	f2f42e23          	sw	a5,-196(s0)
      e.state  = p->state;
    8000146c:	018a2783          	lw	a5,24(s4)
    80001470:	f4f42023          	sw	a5,-192(s0)
      e.va     = a;
    80001474:	f5243c23          	sd	s2,-168(s0)
      e.pa     = pa;
    80001478:	f7343023          	sd	s3,-160(s0)
      e.len    = PGSIZE;
    8000147c:	f7743c23          	sd	s7,-136(s0)
      e.source = SRC_UVMUNMAP;
    80001480:	4791                	li	a5,4
    80001482:	f8f42223          	sw	a5,-124(s0)
      e.kind   = PAGE_USER;
    80001486:	4785                	li	a5,1
    80001488:	f8f42423          	sw	a5,-120(s0)
      safestrcpy(e.name, p->name, MEM_NM);
    8000148c:	4641                	li	a2,16
    8000148e:	158a0593          	addi	a1,s4,344
    80001492:	f4440513          	addi	a0,s0,-188
    80001496:	aa5ff0ef          	jal	80000f3a <safestrcpy>
      memlog_push(&e);
    8000149a:	8566                	mv	a0,s9
    8000149c:	060050ef          	jal	800064fc <memlog_push>
    800014a0:	bf85                	j	80001410 <uvmunmap+0x68>
      kfree((void*)pa);
    800014a2:	854e                	mv	a0,s3
    800014a4:	deaff0ef          	jal	80000a8e <kfree>
    800014a8:	b7b5                	j	80001414 <uvmunmap+0x6c>
    800014aa:	64ae                	ld	s1,200(sp)
    800014ac:	79ea                	ld	s3,184(sp)
    800014ae:	7a4a                	ld	s4,176(sp)
    800014b0:	6bea                	ld	s7,152(sp)
    800014b2:	6caa                	ld	s9,136(sp)
    800014b4:	6d0a                	ld	s10,128(sp)
    800014b6:	7de6                	ld	s11,120(sp)
    800014b8:	690e                	ld	s2,192(sp)
    800014ba:	7aaa                	ld	s5,168(sp)
    800014bc:	7b0a                	ld	s6,160(sp)
    800014be:	6c4a                	ld	s8,144(sp)
  }
}
    800014c0:	60ee                	ld	ra,216(sp)
    800014c2:	644e                	ld	s0,208(sp)
    800014c4:	612d                	addi	sp,sp,224
    800014c6:	8082                	ret

00000000800014c8 <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    800014c8:	1101                	addi	sp,sp,-32
    800014ca:	ec06                	sd	ra,24(sp)
    800014cc:	e822                	sd	s0,16(sp)
    800014ce:	e426                	sd	s1,8(sp)
    800014d0:	1000                	addi	s0,sp,32
  if(newsz >= oldsz)
    return oldsz;
    800014d2:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    800014d4:	00b67d63          	bgeu	a2,a1,800014ee <uvmdealloc+0x26>
    800014d8:	84b2                	mv	s1,a2

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    800014da:	6785                	lui	a5,0x1
    800014dc:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    800014de:	00f60733          	add	a4,a2,a5
    800014e2:	76fd                	lui	a3,0xfffff
    800014e4:	8f75                	and	a4,a4,a3
    800014e6:	97ae                	add	a5,a5,a1
    800014e8:	8ff5                	and	a5,a5,a3
    800014ea:	00f76863          	bltu	a4,a5,800014fa <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    800014ee:	8526                	mv	a0,s1
    800014f0:	60e2                	ld	ra,24(sp)
    800014f2:	6442                	ld	s0,16(sp)
    800014f4:	64a2                	ld	s1,8(sp)
    800014f6:	6105                	addi	sp,sp,32
    800014f8:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    800014fa:	8f99                	sub	a5,a5,a4
    800014fc:	83b1                	srli	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    800014fe:	4685                	li	a3,1
    80001500:	0007861b          	sext.w	a2,a5
    80001504:	85ba                	mv	a1,a4
    80001506:	ea3ff0ef          	jal	800013a8 <uvmunmap>
    8000150a:	b7d5                	j	800014ee <uvmdealloc+0x26>

000000008000150c <uvmalloc>:
{
    8000150c:	7131                	addi	sp,sp,-192
    8000150e:	fd06                	sd	ra,184(sp)
    80001510:	f922                	sd	s0,176(sp)
    80001512:	f526                	sd	s1,168(sp)
    80001514:	0180                	addi	s0,sp,192
    80001516:	84ae                	mv	s1,a1
  if(newsz < oldsz)
    80001518:	00b67863          	bgeu	a2,a1,80001528 <uvmalloc+0x1c>
}
    8000151c:	8526                	mv	a0,s1
    8000151e:	70ea                	ld	ra,184(sp)
    80001520:	744a                	ld	s0,176(sp)
    80001522:	74aa                	ld	s1,168(sp)
    80001524:	6129                	addi	sp,sp,192
    80001526:	8082                	ret
    80001528:	f14a                	sd	s2,160(sp)
    8000152a:	ed4e                	sd	s3,152(sp)
    8000152c:	e952                	sd	s4,144(sp)
    8000152e:	e556                	sd	s5,136(sp)
    80001530:	e15a                	sd	s6,128(sp)
    80001532:	fcde                	sd	s7,120(sp)
    80001534:	8b2a                	mv	s6,a0
    80001536:	8a32                	mv	s4,a2
    80001538:	8ab6                	mv	s5,a3
      struct proc *p = myproc();
    8000153a:	6ee000ef          	jal	80001c28 <myproc>
    8000153e:	892a                	mv	s2,a0
  if(p){
    80001540:	c12d                	beqz	a0,800015a2 <uvmalloc+0x96>
    memset(&e, 0, sizeof(e));
    80001542:	f4840993          	addi	s3,s0,-184
    80001546:	06800613          	li	a2,104
    8000154a:	4581                	li	a1,0
    8000154c:	854e                	mv	a0,s3
    8000154e:	899ff0ef          	jal	80000de6 <memset>
    e.ticks  = ticks;
    80001552:	00007797          	auipc	a5,0x7
    80001556:	3de7a783          	lw	a5,990(a5) # 80008930 <ticks>
    8000155a:	f4f42823          	sw	a5,-176(s0)
    e.cpu    = cpuid();
    8000155e:	696000ef          	jal	80001bf4 <cpuid>
    80001562:	f4a42a23          	sw	a0,-172(s0)
    e.type   = MEM_GROW;
    80001566:	4785                	li	a5,1
    80001568:	f4f42c23          	sw	a5,-168(s0)
    e.pid    = p->pid;
    8000156c:	03092703          	lw	a4,48(s2)
    80001570:	f4e42e23          	sw	a4,-164(s0)
    e.state  = p->state;
    80001574:	01892703          	lw	a4,24(s2)
    80001578:	f6e42023          	sw	a4,-160(s0)
    e.oldsz  = oldsz;
    8000157c:	f8943423          	sd	s1,-120(s0)
    e.newsz  = newsz;
    80001580:	f9443823          	sd	s4,-112(s0)
    e.source = SRC_UVMALLOC;
    80001584:	4715                	li	a4,5
    80001586:	fae42223          	sw	a4,-92(s0)
    e.kind   = PAGE_USER;
    8000158a:	faf42423          	sw	a5,-88(s0)
    safestrcpy(e.name, p->name, MEM_NM);
    8000158e:	4641                	li	a2,16
    80001590:	15890593          	addi	a1,s2,344
    80001594:	f6440513          	addi	a0,s0,-156
    80001598:	9a3ff0ef          	jal	80000f3a <safestrcpy>
    memlog_push(&e);
    8000159c:	854e                	mv	a0,s3
    8000159e:	75f040ef          	jal	800064fc <memlog_push>
  oldsz = PGROUNDUP(oldsz);
    800015a2:	6785                	lui	a5,0x1
    800015a4:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    800015a6:	97a6                	add	a5,a5,s1
    800015a8:	777d                	lui	a4,0xfffff
    800015aa:	8ff9                	and	a5,a5,a4
    800015ac:	8bbe                	mv	s7,a5
  for(a = oldsz; a < newsz; a += PGSIZE){
    800015ae:	0747fd63          	bgeu	a5,s4,80001628 <uvmalloc+0x11c>
    800015b2:	893e                	mv	s2,a5
    memset(mem, 0, PGSIZE);
    800015b4:	6985                	lui	s3,0x1
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    800015b6:	012aea93          	ori	s5,s5,18
    mem = kalloc();
    800015ba:	e1aff0ef          	jal	80000bd4 <kalloc>
    800015be:	84aa                	mv	s1,a0
    if(mem == 0){
    800015c0:	c905                	beqz	a0,800015f0 <uvmalloc+0xe4>
    memset(mem, 0, PGSIZE);
    800015c2:	864e                	mv	a2,s3
    800015c4:	4581                	li	a1,0
    800015c6:	821ff0ef          	jal	80000de6 <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    800015ca:	8756                	mv	a4,s5
    800015cc:	86a6                	mv	a3,s1
    800015ce:	864e                	mv	a2,s3
    800015d0:	85ca                	mv	a1,s2
    800015d2:	855a                	mv	a0,s6
    800015d4:	b87ff0ef          	jal	8000115a <mappages>
    800015d8:	e905                	bnez	a0,80001608 <uvmalloc+0xfc>
  for(a = oldsz; a < newsz; a += PGSIZE){
    800015da:	994e                	add	s2,s2,s3
    800015dc:	fd496fe3          	bltu	s2,s4,800015ba <uvmalloc+0xae>
  return newsz;
    800015e0:	84d2                	mv	s1,s4
    800015e2:	790a                	ld	s2,160(sp)
    800015e4:	69ea                	ld	s3,152(sp)
    800015e6:	6a4a                	ld	s4,144(sp)
    800015e8:	6aaa                	ld	s5,136(sp)
    800015ea:	6b0a                	ld	s6,128(sp)
    800015ec:	7be6                	ld	s7,120(sp)
    800015ee:	b73d                	j	8000151c <uvmalloc+0x10>
      uvmdealloc(pagetable, a, oldsz);
    800015f0:	865e                	mv	a2,s7
    800015f2:	85ca                	mv	a1,s2
    800015f4:	855a                	mv	a0,s6
    800015f6:	ed3ff0ef          	jal	800014c8 <uvmdealloc>
      return 0;
    800015fa:	790a                	ld	s2,160(sp)
    800015fc:	69ea                	ld	s3,152(sp)
    800015fe:	6a4a                	ld	s4,144(sp)
    80001600:	6aaa                	ld	s5,136(sp)
    80001602:	6b0a                	ld	s6,128(sp)
    80001604:	7be6                	ld	s7,120(sp)
    80001606:	bf19                	j	8000151c <uvmalloc+0x10>
      kfree(mem);
    80001608:	8526                	mv	a0,s1
    8000160a:	c84ff0ef          	jal	80000a8e <kfree>
      uvmdealloc(pagetable, a, oldsz);
    8000160e:	865e                	mv	a2,s7
    80001610:	85ca                	mv	a1,s2
    80001612:	855a                	mv	a0,s6
    80001614:	eb5ff0ef          	jal	800014c8 <uvmdealloc>
      return 0;
    80001618:	4481                	li	s1,0
    8000161a:	790a                	ld	s2,160(sp)
    8000161c:	69ea                	ld	s3,152(sp)
    8000161e:	6a4a                	ld	s4,144(sp)
    80001620:	6aaa                	ld	s5,136(sp)
    80001622:	6b0a                	ld	s6,128(sp)
    80001624:	7be6                	ld	s7,120(sp)
    80001626:	bddd                	j	8000151c <uvmalloc+0x10>
  return newsz;
    80001628:	84d2                	mv	s1,s4
    8000162a:	790a                	ld	s2,160(sp)
    8000162c:	69ea                	ld	s3,152(sp)
    8000162e:	6a4a                	ld	s4,144(sp)
    80001630:	6aaa                	ld	s5,136(sp)
    80001632:	6b0a                	ld	s6,128(sp)
    80001634:	7be6                	ld	s7,120(sp)
    80001636:	b5dd                	j	8000151c <uvmalloc+0x10>

0000000080001638 <freewalk>:
// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    80001638:	7179                	addi	sp,sp,-48
    8000163a:	f406                	sd	ra,40(sp)
    8000163c:	f022                	sd	s0,32(sp)
    8000163e:	ec26                	sd	s1,24(sp)
    80001640:	e84a                	sd	s2,16(sp)
    80001642:	e44e                	sd	s3,8(sp)
    80001644:	1800                	addi	s0,sp,48
    80001646:	89aa                	mv	s3,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    80001648:	84aa                	mv	s1,a0
    8000164a:	6905                	lui	s2,0x1
    8000164c:	992a                	add	s2,s2,a0
    8000164e:	a811                	j	80001662 <freewalk+0x2a>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
      freewalk((pagetable_t)child);
      pagetable[i] = 0;
    } else if(pte & PTE_V){
      panic("freewalk: leaf");
    80001650:	00007517          	auipc	a0,0x7
    80001654:	af050513          	addi	a0,a0,-1296 # 80008140 <etext+0x140>
    80001658:	9feff0ef          	jal	80000856 <panic>
  for(int i = 0; i < 512; i++){
    8000165c:	04a1                	addi	s1,s1,8
    8000165e:	03248163          	beq	s1,s2,80001680 <freewalk+0x48>
    pte_t pte = pagetable[i];
    80001662:	609c                	ld	a5,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    80001664:	0017f713          	andi	a4,a5,1
    80001668:	db75                	beqz	a4,8000165c <freewalk+0x24>
    8000166a:	00e7f713          	andi	a4,a5,14
    8000166e:	f36d                	bnez	a4,80001650 <freewalk+0x18>
      uint64 child = PTE2PA(pte);
    80001670:	83a9                	srli	a5,a5,0xa
      freewalk((pagetable_t)child);
    80001672:	00c79513          	slli	a0,a5,0xc
    80001676:	fc3ff0ef          	jal	80001638 <freewalk>
      pagetable[i] = 0;
    8000167a:	0004b023          	sd	zero,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    8000167e:	bff9                	j	8000165c <freewalk+0x24>
    }
  }
  kfree((void*)pagetable);
    80001680:	854e                	mv	a0,s3
    80001682:	c0cff0ef          	jal	80000a8e <kfree>
}
    80001686:	70a2                	ld	ra,40(sp)
    80001688:	7402                	ld	s0,32(sp)
    8000168a:	64e2                	ld	s1,24(sp)
    8000168c:	6942                	ld	s2,16(sp)
    8000168e:	69a2                	ld	s3,8(sp)
    80001690:	6145                	addi	sp,sp,48
    80001692:	8082                	ret

0000000080001694 <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    80001694:	1101                	addi	sp,sp,-32
    80001696:	ec06                	sd	ra,24(sp)
    80001698:	e822                	sd	s0,16(sp)
    8000169a:	e426                	sd	s1,8(sp)
    8000169c:	1000                	addi	s0,sp,32
    8000169e:	84aa                	mv	s1,a0
  if(sz > 0)
    800016a0:	e989                	bnez	a1,800016b2 <uvmfree+0x1e>
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
  freewalk(pagetable);
    800016a2:	8526                	mv	a0,s1
    800016a4:	f95ff0ef          	jal	80001638 <freewalk>
}
    800016a8:	60e2                	ld	ra,24(sp)
    800016aa:	6442                	ld	s0,16(sp)
    800016ac:	64a2                	ld	s1,8(sp)
    800016ae:	6105                	addi	sp,sp,32
    800016b0:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
    800016b2:	6785                	lui	a5,0x1
    800016b4:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    800016b6:	95be                	add	a1,a1,a5
    800016b8:	4685                	li	a3,1
    800016ba:	00c5d613          	srli	a2,a1,0xc
    800016be:	4581                	li	a1,0
    800016c0:	ce9ff0ef          	jal	800013a8 <uvmunmap>
    800016c4:	bff9                	j	800016a2 <uvmfree+0xe>

00000000800016c6 <uvmcopy>:
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for(i = 0; i < sz; i += PGSIZE){
    800016c6:	ca59                	beqz	a2,8000175c <uvmcopy+0x96>
{
    800016c8:	715d                	addi	sp,sp,-80
    800016ca:	e486                	sd	ra,72(sp)
    800016cc:	e0a2                	sd	s0,64(sp)
    800016ce:	fc26                	sd	s1,56(sp)
    800016d0:	f84a                	sd	s2,48(sp)
    800016d2:	f44e                	sd	s3,40(sp)
    800016d4:	f052                	sd	s4,32(sp)
    800016d6:	ec56                	sd	s5,24(sp)
    800016d8:	e85a                	sd	s6,16(sp)
    800016da:	e45e                	sd	s7,8(sp)
    800016dc:	0880                	addi	s0,sp,80
    800016de:	8b2a                	mv	s6,a0
    800016e0:	8bae                	mv	s7,a1
    800016e2:	8ab2                	mv	s5,a2
  for(i = 0; i < sz; i += PGSIZE){
    800016e4:	4481                	li	s1,0
      continue;   // physical page hasn't been allocated
    pa = PTE2PA(*pte);
    flags = PTE_FLAGS(*pte);
    if((mem = kalloc()) == 0)
      goto err;
    memmove(mem, (char*)pa, PGSIZE);
    800016e6:	6a05                	lui	s4,0x1
    800016e8:	a021                	j	800016f0 <uvmcopy+0x2a>
  for(i = 0; i < sz; i += PGSIZE){
    800016ea:	94d2                	add	s1,s1,s4
    800016ec:	0554fc63          	bgeu	s1,s5,80001744 <uvmcopy+0x7e>
    if((pte = walk(old, i, 0)) == 0)
    800016f0:	4601                	li	a2,0
    800016f2:	85a6                	mv	a1,s1
    800016f4:	855a                	mv	a0,s6
    800016f6:	991ff0ef          	jal	80001086 <walk>
    800016fa:	d965                	beqz	a0,800016ea <uvmcopy+0x24>
    if((*pte & PTE_V) == 0)
    800016fc:	00053983          	ld	s3,0(a0)
    80001700:	0019f793          	andi	a5,s3,1
    80001704:	d3fd                	beqz	a5,800016ea <uvmcopy+0x24>
    if((mem = kalloc()) == 0)
    80001706:	cceff0ef          	jal	80000bd4 <kalloc>
    8000170a:	892a                	mv	s2,a0
    8000170c:	c11d                	beqz	a0,80001732 <uvmcopy+0x6c>
    pa = PTE2PA(*pte);
    8000170e:	00a9d593          	srli	a1,s3,0xa
    memmove(mem, (char*)pa, PGSIZE);
    80001712:	8652                	mv	a2,s4
    80001714:	05b2                	slli	a1,a1,0xc
    80001716:	f30ff0ef          	jal	80000e46 <memmove>
    if(mappages(new, i, PGSIZE, (uint64)mem, flags) != 0){
    8000171a:	3ff9f713          	andi	a4,s3,1023
    8000171e:	86ca                	mv	a3,s2
    80001720:	8652                	mv	a2,s4
    80001722:	85a6                	mv	a1,s1
    80001724:	855e                	mv	a0,s7
    80001726:	a35ff0ef          	jal	8000115a <mappages>
    8000172a:	d161                	beqz	a0,800016ea <uvmcopy+0x24>
      kfree(mem);
    8000172c:	854a                	mv	a0,s2
    8000172e:	b60ff0ef          	jal	80000a8e <kfree>
    }
  }
  return 0;

 err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    80001732:	4685                	li	a3,1
    80001734:	00c4d613          	srli	a2,s1,0xc
    80001738:	4581                	li	a1,0
    8000173a:	855e                	mv	a0,s7
    8000173c:	c6dff0ef          	jal	800013a8 <uvmunmap>
  return -1;
    80001740:	557d                	li	a0,-1
    80001742:	a011                	j	80001746 <uvmcopy+0x80>
  return 0;
    80001744:	4501                	li	a0,0
}
    80001746:	60a6                	ld	ra,72(sp)
    80001748:	6406                	ld	s0,64(sp)
    8000174a:	74e2                	ld	s1,56(sp)
    8000174c:	7942                	ld	s2,48(sp)
    8000174e:	79a2                	ld	s3,40(sp)
    80001750:	7a02                	ld	s4,32(sp)
    80001752:	6ae2                	ld	s5,24(sp)
    80001754:	6b42                	ld	s6,16(sp)
    80001756:	6ba2                	ld	s7,8(sp)
    80001758:	6161                	addi	sp,sp,80
    8000175a:	8082                	ret
  return 0;
    8000175c:	4501                	li	a0,0
}
    8000175e:	8082                	ret

0000000080001760 <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    80001760:	1141                	addi	sp,sp,-16
    80001762:	e406                	sd	ra,8(sp)
    80001764:	e022                	sd	s0,0(sp)
    80001766:	0800                	addi	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    80001768:	4601                	li	a2,0
    8000176a:	91dff0ef          	jal	80001086 <walk>
  if(pte == 0)
    8000176e:	c901                	beqz	a0,8000177e <uvmclear+0x1e>
    panic("uvmclear");
  *pte &= ~PTE_U;
    80001770:	611c                	ld	a5,0(a0)
    80001772:	9bbd                	andi	a5,a5,-17
    80001774:	e11c                	sd	a5,0(a0)
}
    80001776:	60a2                	ld	ra,8(sp)
    80001778:	6402                	ld	s0,0(sp)
    8000177a:	0141                	addi	sp,sp,16
    8000177c:	8082                	ret
    panic("uvmclear");
    8000177e:	00007517          	auipc	a0,0x7
    80001782:	9d250513          	addi	a0,a0,-1582 # 80008150 <etext+0x150>
    80001786:	8d0ff0ef          	jal	80000856 <panic>

000000008000178a <copyinstr>:
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    8000178a:	cac5                	beqz	a3,8000183a <copyinstr+0xb0>
{
    8000178c:	715d                	addi	sp,sp,-80
    8000178e:	e486                	sd	ra,72(sp)
    80001790:	e0a2                	sd	s0,64(sp)
    80001792:	fc26                	sd	s1,56(sp)
    80001794:	f84a                	sd	s2,48(sp)
    80001796:	f44e                	sd	s3,40(sp)
    80001798:	f052                	sd	s4,32(sp)
    8000179a:	ec56                	sd	s5,24(sp)
    8000179c:	e85a                	sd	s6,16(sp)
    8000179e:	e45e                	sd	s7,8(sp)
    800017a0:	0880                	addi	s0,sp,80
    800017a2:	8aaa                	mv	s5,a0
    800017a4:	84ae                	mv	s1,a1
    800017a6:	8bb2                	mv	s7,a2
    800017a8:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(srcva);
    800017aa:	7b7d                	lui	s6,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    800017ac:	6a05                	lui	s4,0x1
    800017ae:	a82d                	j	800017e8 <copyinstr+0x5e>
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
    800017b0:	00078023          	sb	zero,0(a5)
        got_null = 1;
    800017b4:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    800017b6:	0017c793          	xori	a5,a5,1
    800017ba:	40f0053b          	negw	a0,a5
    return 0;
  } else {
    return -1;
  }
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
    800017d0:	6161                	addi	sp,sp,80
    800017d2:	8082                	ret
    800017d4:	fff98713          	addi	a4,s3,-1 # fff <_entry-0x7ffff001>
    800017d8:	9726                	add	a4,a4,s1
      --max;
    800017da:	40b709b3          	sub	s3,a4,a1
    srcva = va0 + PGSIZE;
    800017de:	01490bb3          	add	s7,s2,s4
  while(got_null == 0 && max > 0){
    800017e2:	04e58463          	beq	a1,a4,8000182a <copyinstr+0xa0>
{
    800017e6:	84be                	mv	s1,a5
    va0 = PGROUNDDOWN(srcva);
    800017e8:	016bf933          	and	s2,s7,s6
    pa0 = walkaddr(pagetable, va0);
    800017ec:	85ca                	mv	a1,s2
    800017ee:	8556                	mv	a0,s5
    800017f0:	931ff0ef          	jal	80001120 <walkaddr>
    if(pa0 == 0)
    800017f4:	cd0d                	beqz	a0,8000182e <copyinstr+0xa4>
    n = PGSIZE - (srcva - va0);
    800017f6:	417906b3          	sub	a3,s2,s7
    800017fa:	96d2                	add	a3,a3,s4
    if(n > max)
    800017fc:	00d9f363          	bgeu	s3,a3,80001802 <copyinstr+0x78>
    80001800:	86ce                	mv	a3,s3
    while(n > 0){
    80001802:	ca85                	beqz	a3,80001832 <copyinstr+0xa8>
    char *p = (char *) (pa0 + (srcva - va0));
    80001804:	01750633          	add	a2,a0,s7
    80001808:	41260633          	sub	a2,a2,s2
    8000180c:	87a6                	mv	a5,s1
      if(*p == '\0'){
    8000180e:	8e05                	sub	a2,a2,s1
    while(n > 0){
    80001810:	96a6                	add	a3,a3,s1
    80001812:	85be                	mv	a1,a5
      if(*p == '\0'){
    80001814:	00f60733          	add	a4,a2,a5
    80001818:	00074703          	lbu	a4,0(a4) # fffffffffffff000 <end+0xffffffff7ffb82a8>
    8000181c:	db51                	beqz	a4,800017b0 <copyinstr+0x26>
        *dst = *p;
    8000181e:	00e78023          	sb	a4,0(a5)
      dst++;
    80001822:	0785                	addi	a5,a5,1
    while(n > 0){
    80001824:	fed797e3          	bne	a5,a3,80001812 <copyinstr+0x88>
    80001828:	b775                	j	800017d4 <copyinstr+0x4a>
    8000182a:	4781                	li	a5,0
    8000182c:	b769                	j	800017b6 <copyinstr+0x2c>
      return -1;
    8000182e:	557d                	li	a0,-1
    80001830:	b779                	j	800017be <copyinstr+0x34>
    srcva = va0 + PGSIZE;
    80001832:	6b85                	lui	s7,0x1
    80001834:	9bca                	add	s7,s7,s2
    80001836:	87a6                	mv	a5,s1
    80001838:	b77d                	j	800017e6 <copyinstr+0x5c>
  int got_null = 0;
    8000183a:	4781                	li	a5,0
  if(got_null){
    8000183c:	0017c793          	xori	a5,a5,1
    80001840:	40f0053b          	negw	a0,a5
}
    80001844:	8082                	ret

0000000080001846 <ismapped>:
  }
  return mem;
}
int
ismapped(pagetable_t pagetable, uint64 va)
{
    80001846:	1141                	addi	sp,sp,-16
    80001848:	e406                	sd	ra,8(sp)
    8000184a:	e022                	sd	s0,0(sp)
    8000184c:	0800                	addi	s0,sp,16
  pte_t *pte = walk(pagetable, va, 0);
    8000184e:	4601                	li	a2,0
    80001850:	837ff0ef          	jal	80001086 <walk>
  if (pte == 0) {
    80001854:	c119                	beqz	a0,8000185a <ismapped+0x14>
    return 0;
  }
  if (*pte & PTE_V){
    80001856:	6108                	ld	a0,0(a0)
    80001858:	8905                	andi	a0,a0,1
    return 1;
  }
  return 0;
}
    8000185a:	60a2                	ld	ra,8(sp)
    8000185c:	6402                	ld	s0,0(sp)
    8000185e:	0141                	addi	sp,sp,16
    80001860:	8082                	ret

0000000080001862 <vmfault>:
{
    80001862:	7135                	addi	sp,sp,-160
    80001864:	ed06                	sd	ra,152(sp)
    80001866:	e922                	sd	s0,144(sp)
    80001868:	e14a                	sd	s2,128(sp)
    8000186a:	fcce                	sd	s3,120(sp)
    8000186c:	f8d2                	sd	s4,112(sp)
    8000186e:	1100                	addi	s0,sp,160
    80001870:	89aa                	mv	s3,a0
    80001872:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80001874:	3b4000ef          	jal	80001c28 <myproc>
  if (va >= p->sz)
    80001878:	653c                	ld	a5,72(a0)
    return 0;
    8000187a:	4a01                	li	s4,0
  if (va >= p->sz)
    8000187c:	00f96a63          	bltu	s2,a5,80001890 <vmfault+0x2e>
}
    80001880:	8552                	mv	a0,s4
    80001882:	60ea                	ld	ra,152(sp)
    80001884:	644a                	ld	s0,144(sp)
    80001886:	690a                	ld	s2,128(sp)
    80001888:	79e6                	ld	s3,120(sp)
    8000188a:	7a46                	ld	s4,112(sp)
    8000188c:	610d                	addi	sp,sp,160
    8000188e:	8082                	ret
    80001890:	e526                	sd	s1,136(sp)
    80001892:	84aa                	mv	s1,a0
  va = PGROUNDDOWN(va);
    80001894:	77fd                	lui	a5,0xfffff
    80001896:	00f97933          	and	s2,s2,a5
  if(ismapped(pagetable, va)) {
    8000189a:	85ca                	mv	a1,s2
    8000189c:	854e                	mv	a0,s3
    8000189e:	fa9ff0ef          	jal	80001846 <ismapped>
    return 0;
    800018a2:	4a01                	li	s4,0
  if(ismapped(pagetable, va)) {
    800018a4:	c119                	beqz	a0,800018aa <vmfault+0x48>
    800018a6:	64aa                	ld	s1,136(sp)
    800018a8:	bfe1                	j	80001880 <vmfault+0x1e>
  memset(&e, 0, sizeof(e));
    800018aa:	06800613          	li	a2,104
    800018ae:	4581                	li	a1,0
    800018b0:	f6840513          	addi	a0,s0,-152
    800018b4:	d32ff0ef          	jal	80000de6 <memset>
  e.ticks  = ticks;
    800018b8:	00007797          	auipc	a5,0x7
    800018bc:	0787a783          	lw	a5,120(a5) # 80008930 <ticks>
    800018c0:	f6f42823          	sw	a5,-144(s0)
  e.cpu    = cpuid();
    800018c4:	330000ef          	jal	80001bf4 <cpuid>
    800018c8:	f6a42a23          	sw	a0,-140(s0)
  e.type   = MEM_FAULT;
    800018cc:	478d                	li	a5,3
    800018ce:	f6f42c23          	sw	a5,-136(s0)
  e.pid    = p->pid;
    800018d2:	589c                	lw	a5,48(s1)
    800018d4:	f6f42e23          	sw	a5,-132(s0)
  e.state  = p->state;
    800018d8:	4c9c                	lw	a5,24(s1)
    800018da:	f8f42023          	sw	a5,-128(s0)
  e.va     = va;
    800018de:	f9243c23          	sd	s2,-104(s0)
  e.source = SRC_VMFAULT;
    800018e2:	479d                	li	a5,7
    800018e4:	fcf42223          	sw	a5,-60(s0)
  e.kind   = PAGE_USER;
    800018e8:	4785                	li	a5,1
    800018ea:	fcf42423          	sw	a5,-56(s0)
  safestrcpy(e.name, p->name, MEM_NM);
    800018ee:	4641                	li	a2,16
    800018f0:	15848593          	addi	a1,s1,344
    800018f4:	f8440513          	addi	a0,s0,-124
    800018f8:	e42ff0ef          	jal	80000f3a <safestrcpy>
  memlog_push(&e);
    800018fc:	f6840513          	addi	a0,s0,-152
    80001900:	3fd040ef          	jal	800064fc <memlog_push>
  mem = (uint64) kalloc();
    80001904:	ad0ff0ef          	jal	80000bd4 <kalloc>
    80001908:	89aa                	mv	s3,a0
  if(mem == 0)
    8000190a:	c515                	beqz	a0,80001936 <vmfault+0xd4>
  mem = (uint64) kalloc();
    8000190c:	8a2a                	mv	s4,a0
  memset((void *) mem, 0, PGSIZE);
    8000190e:	6605                	lui	a2,0x1
    80001910:	4581                	li	a1,0
    80001912:	cd4ff0ef          	jal	80000de6 <memset>
  if (mappages(p->pagetable, va, PGSIZE, mem, PTE_W|PTE_U|PTE_R) != 0) {
    80001916:	4759                	li	a4,22
    80001918:	86ce                	mv	a3,s3
    8000191a:	6605                	lui	a2,0x1
    8000191c:	85ca                	mv	a1,s2
    8000191e:	68a8                	ld	a0,80(s1)
    80001920:	83bff0ef          	jal	8000115a <mappages>
    80001924:	e119                	bnez	a0,8000192a <vmfault+0xc8>
    80001926:	64aa                	ld	s1,136(sp)
    80001928:	bfa1                	j	80001880 <vmfault+0x1e>
    kfree((void *)mem);
    8000192a:	854e                	mv	a0,s3
    8000192c:	962ff0ef          	jal	80000a8e <kfree>
    return 0;
    80001930:	4a01                	li	s4,0
    80001932:	64aa                	ld	s1,136(sp)
    80001934:	b7b1                	j	80001880 <vmfault+0x1e>
    80001936:	64aa                	ld	s1,136(sp)
    80001938:	b7a1                	j	80001880 <vmfault+0x1e>

000000008000193a <copyout>:
  while(len > 0){
    8000193a:	cad1                	beqz	a3,800019ce <copyout+0x94>
{
    8000193c:	711d                	addi	sp,sp,-96
    8000193e:	ec86                	sd	ra,88(sp)
    80001940:	e8a2                	sd	s0,80(sp)
    80001942:	e4a6                	sd	s1,72(sp)
    80001944:	e0ca                	sd	s2,64(sp)
    80001946:	fc4e                	sd	s3,56(sp)
    80001948:	f852                	sd	s4,48(sp)
    8000194a:	f456                	sd	s5,40(sp)
    8000194c:	f05a                	sd	s6,32(sp)
    8000194e:	ec5e                	sd	s7,24(sp)
    80001950:	e862                	sd	s8,16(sp)
    80001952:	e466                	sd	s9,8(sp)
    80001954:	e06a                	sd	s10,0(sp)
    80001956:	1080                	addi	s0,sp,96
    80001958:	8baa                	mv	s7,a0
    8000195a:	8a2e                	mv	s4,a1
    8000195c:	8b32                	mv	s6,a2
    8000195e:	8ab6                	mv	s5,a3
    va0 = PGROUNDDOWN(dstva);
    80001960:	7d7d                	lui	s10,0xfffff
    if(va0 >= MAXVA)
    80001962:	5cfd                	li	s9,-1
    80001964:	01acdc93          	srli	s9,s9,0x1a
    n = PGSIZE - (dstva - va0);
    80001968:	6c05                	lui	s8,0x1
    8000196a:	a005                	j	8000198a <copyout+0x50>
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    8000196c:	409a0533          	sub	a0,s4,s1
    80001970:	0009061b          	sext.w	a2,s2
    80001974:	85da                	mv	a1,s6
    80001976:	954e                	add	a0,a0,s3
    80001978:	cceff0ef          	jal	80000e46 <memmove>
    len -= n;
    8000197c:	412a8ab3          	sub	s5,s5,s2
    src += n;
    80001980:	9b4a                	add	s6,s6,s2
    dstva = va0 + PGSIZE;
    80001982:	01848a33          	add	s4,s1,s8
  while(len > 0){
    80001986:	040a8263          	beqz	s5,800019ca <copyout+0x90>
    va0 = PGROUNDDOWN(dstva);
    8000198a:	01aa74b3          	and	s1,s4,s10
    if(va0 >= MAXVA)
    8000198e:	049ce263          	bltu	s9,s1,800019d2 <copyout+0x98>
    pa0 = walkaddr(pagetable, va0);
    80001992:	85a6                	mv	a1,s1
    80001994:	855e                	mv	a0,s7
    80001996:	f8aff0ef          	jal	80001120 <walkaddr>
    8000199a:	89aa                	mv	s3,a0
    if(pa0 == 0) {
    8000199c:	e901                	bnez	a0,800019ac <copyout+0x72>
      if((pa0 = vmfault(pagetable, va0, 0)) == 0) {
    8000199e:	4601                	li	a2,0
    800019a0:	85a6                	mv	a1,s1
    800019a2:	855e                	mv	a0,s7
    800019a4:	ebfff0ef          	jal	80001862 <vmfault>
    800019a8:	89aa                	mv	s3,a0
    800019aa:	c139                	beqz	a0,800019f0 <copyout+0xb6>
    pte = walk(pagetable, va0, 0);
    800019ac:	4601                	li	a2,0
    800019ae:	85a6                	mv	a1,s1
    800019b0:	855e                	mv	a0,s7
    800019b2:	ed4ff0ef          	jal	80001086 <walk>
    if((*pte & PTE_W) == 0)
    800019b6:	611c                	ld	a5,0(a0)
    800019b8:	8b91                	andi	a5,a5,4
    800019ba:	cf8d                	beqz	a5,800019f4 <copyout+0xba>
    n = PGSIZE - (dstva - va0);
    800019bc:	41448933          	sub	s2,s1,s4
    800019c0:	9962                	add	s2,s2,s8
    if(n > len)
    800019c2:	fb2af5e3          	bgeu	s5,s2,8000196c <copyout+0x32>
    800019c6:	8956                	mv	s2,s5
    800019c8:	b755                	j	8000196c <copyout+0x32>
  return 0;
    800019ca:	4501                	li	a0,0
    800019cc:	a021                	j	800019d4 <copyout+0x9a>
    800019ce:	4501                	li	a0,0
}
    800019d0:	8082                	ret
      return -1;
    800019d2:	557d                	li	a0,-1
}
    800019d4:	60e6                	ld	ra,88(sp)
    800019d6:	6446                	ld	s0,80(sp)
    800019d8:	64a6                	ld	s1,72(sp)
    800019da:	6906                	ld	s2,64(sp)
    800019dc:	79e2                	ld	s3,56(sp)
    800019de:	7a42                	ld	s4,48(sp)
    800019e0:	7aa2                	ld	s5,40(sp)
    800019e2:	7b02                	ld	s6,32(sp)
    800019e4:	6be2                	ld	s7,24(sp)
    800019e6:	6c42                	ld	s8,16(sp)
    800019e8:	6ca2                	ld	s9,8(sp)
    800019ea:	6d02                	ld	s10,0(sp)
    800019ec:	6125                	addi	sp,sp,96
    800019ee:	8082                	ret
        return -1;
    800019f0:	557d                	li	a0,-1
    800019f2:	b7cd                	j	800019d4 <copyout+0x9a>
      return -1;
    800019f4:	557d                	li	a0,-1
    800019f6:	bff9                	j	800019d4 <copyout+0x9a>

00000000800019f8 <copyin>:
  while(len > 0){
    800019f8:	c6c9                	beqz	a3,80001a82 <copyin+0x8a>
{
    800019fa:	715d                	addi	sp,sp,-80
    800019fc:	e486                	sd	ra,72(sp)
    800019fe:	e0a2                	sd	s0,64(sp)
    80001a00:	fc26                	sd	s1,56(sp)
    80001a02:	f84a                	sd	s2,48(sp)
    80001a04:	f44e                	sd	s3,40(sp)
    80001a06:	f052                	sd	s4,32(sp)
    80001a08:	ec56                	sd	s5,24(sp)
    80001a0a:	e85a                	sd	s6,16(sp)
    80001a0c:	e45e                	sd	s7,8(sp)
    80001a0e:	e062                	sd	s8,0(sp)
    80001a10:	0880                	addi	s0,sp,80
    80001a12:	8baa                	mv	s7,a0
    80001a14:	8aae                	mv	s5,a1
    80001a16:	8932                	mv	s2,a2
    80001a18:	8a36                	mv	s4,a3
    va0 = PGROUNDDOWN(srcva);
    80001a1a:	7c7d                	lui	s8,0xfffff
    n = PGSIZE - (srcva - va0);
    80001a1c:	6b05                	lui	s6,0x1
    80001a1e:	a035                	j	80001a4a <copyin+0x52>
    80001a20:	412984b3          	sub	s1,s3,s2
    80001a24:	94da                	add	s1,s1,s6
    if(n > len)
    80001a26:	009a7363          	bgeu	s4,s1,80001a2c <copyin+0x34>
    80001a2a:	84d2                	mv	s1,s4
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    80001a2c:	413905b3          	sub	a1,s2,s3
    80001a30:	0004861b          	sext.w	a2,s1
    80001a34:	95aa                	add	a1,a1,a0
    80001a36:	8556                	mv	a0,s5
    80001a38:	c0eff0ef          	jal	80000e46 <memmove>
    len -= n;
    80001a3c:	409a0a33          	sub	s4,s4,s1
    dst += n;
    80001a40:	9aa6                	add	s5,s5,s1
    srcva = va0 + PGSIZE;
    80001a42:	01698933          	add	s2,s3,s6
  while(len > 0){
    80001a46:	020a0163          	beqz	s4,80001a68 <copyin+0x70>
    va0 = PGROUNDDOWN(srcva);
    80001a4a:	018979b3          	and	s3,s2,s8
    pa0 = walkaddr(pagetable, va0);
    80001a4e:	85ce                	mv	a1,s3
    80001a50:	855e                	mv	a0,s7
    80001a52:	eceff0ef          	jal	80001120 <walkaddr>
    if(pa0 == 0) {
    80001a56:	f569                	bnez	a0,80001a20 <copyin+0x28>
      if((pa0 = vmfault(pagetable, va0, 0)) == 0) {
    80001a58:	4601                	li	a2,0
    80001a5a:	85ce                	mv	a1,s3
    80001a5c:	855e                	mv	a0,s7
    80001a5e:	e05ff0ef          	jal	80001862 <vmfault>
    80001a62:	fd5d                	bnez	a0,80001a20 <copyin+0x28>
        return -1;
    80001a64:	557d                	li	a0,-1
    80001a66:	a011                	j	80001a6a <copyin+0x72>
  return 0;
    80001a68:	4501                	li	a0,0
}
    80001a6a:	60a6                	ld	ra,72(sp)
    80001a6c:	6406                	ld	s0,64(sp)
    80001a6e:	74e2                	ld	s1,56(sp)
    80001a70:	7942                	ld	s2,48(sp)
    80001a72:	79a2                	ld	s3,40(sp)
    80001a74:	7a02                	ld	s4,32(sp)
    80001a76:	6ae2                	ld	s5,24(sp)
    80001a78:	6b42                	ld	s6,16(sp)
    80001a7a:	6ba2                	ld	s7,8(sp)
    80001a7c:	6c02                	ld	s8,0(sp)
    80001a7e:	6161                	addi	sp,sp,80
    80001a80:	8082                	ret
  return 0;
    80001a82:	4501                	li	a0,0
}
    80001a84:	8082                	ret

0000000080001a86 <proc_mapstacks>:
struct spinlock wait_lock;

// Allocate a page for each process's kernel stack.
// Map it high in memory, followed by an invalid
// guard page.
void proc_mapstacks(pagetable_t kpgtbl) {
    80001a86:	715d                	addi	sp,sp,-80
    80001a88:	e486                	sd	ra,72(sp)
    80001a8a:	e0a2                	sd	s0,64(sp)
    80001a8c:	fc26                	sd	s1,56(sp)
    80001a8e:	f84a                	sd	s2,48(sp)
    80001a90:	f44e                	sd	s3,40(sp)
    80001a92:	f052                	sd	s4,32(sp)
    80001a94:	ec56                	sd	s5,24(sp)
    80001a96:	e85a                	sd	s6,16(sp)
    80001a98:	e45e                	sd	s7,8(sp)
    80001a9a:	e062                	sd	s8,0(sp)
    80001a9c:	0880                	addi	s0,sp,80
    80001a9e:	8a2a                	mv	s4,a0
  struct proc *p;

  for (p = proc; p < &proc[NPROC]; p++) {
    80001aa0:	0000f497          	auipc	s1,0xf
    80001aa4:	43048493          	addi	s1,s1,1072 # 80010ed0 <proc>
    char *pa = kalloc();
    if (pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int)(p - proc));
    80001aa8:	8c26                	mv	s8,s1
    80001aaa:	000a57b7          	lui	a5,0xa5
    80001aae:	fa578793          	addi	a5,a5,-91 # a4fa5 <_entry-0x7ff5b05b>
    80001ab2:	07b2                	slli	a5,a5,0xc
    80001ab4:	fa578793          	addi	a5,a5,-91
    80001ab8:	4fa50937          	lui	s2,0x4fa50
    80001abc:	a4f90913          	addi	s2,s2,-1457 # 4fa4fa4f <_entry-0x305b05b1>
    80001ac0:	1902                	slli	s2,s2,0x20
    80001ac2:	993e                	add	s2,s2,a5
    80001ac4:	040009b7          	lui	s3,0x4000
    80001ac8:	19fd                	addi	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    80001aca:	09b2                	slli	s3,s3,0xc
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    80001acc:	4b99                	li	s7,6
    80001ace:	6b05                	lui	s6,0x1
  for (p = proc; p < &proc[NPROC]; p++) {
    80001ad0:	00015a97          	auipc	s5,0x15
    80001ad4:	e00a8a93          	addi	s5,s5,-512 # 800168d0 <tickslock>
    char *pa = kalloc();
    80001ad8:	8fcff0ef          	jal	80000bd4 <kalloc>
    80001adc:	862a                	mv	a2,a0
    if (pa == 0)
    80001ade:	c121                	beqz	a0,80001b1e <proc_mapstacks+0x98>
    uint64 va = KSTACK((int)(p - proc));
    80001ae0:	418485b3          	sub	a1,s1,s8
    80001ae4:	858d                	srai	a1,a1,0x3
    80001ae6:	032585b3          	mul	a1,a1,s2
    80001aea:	05b6                	slli	a1,a1,0xd
    80001aec:	6789                	lui	a5,0x2
    80001aee:	9dbd                	addw	a1,a1,a5
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    80001af0:	875e                	mv	a4,s7
    80001af2:	86da                	mv	a3,s6
    80001af4:	40b985b3          	sub	a1,s3,a1
    80001af8:	8552                	mv	a0,s4
    80001afa:	f96ff0ef          	jal	80001290 <kvmmap>
  for (p = proc; p < &proc[NPROC]; p++) {
    80001afe:	16848493          	addi	s1,s1,360
    80001b02:	fd549be3          	bne	s1,s5,80001ad8 <proc_mapstacks+0x52>
  }
}
    80001b06:	60a6                	ld	ra,72(sp)
    80001b08:	6406                	ld	s0,64(sp)
    80001b0a:	74e2                	ld	s1,56(sp)
    80001b0c:	7942                	ld	s2,48(sp)
    80001b0e:	79a2                	ld	s3,40(sp)
    80001b10:	7a02                	ld	s4,32(sp)
    80001b12:	6ae2                	ld	s5,24(sp)
    80001b14:	6b42                	ld	s6,16(sp)
    80001b16:	6ba2                	ld	s7,8(sp)
    80001b18:	6c02                	ld	s8,0(sp)
    80001b1a:	6161                	addi	sp,sp,80
    80001b1c:	8082                	ret
      panic("kalloc");
    80001b1e:	00006517          	auipc	a0,0x6
    80001b22:	64250513          	addi	a0,a0,1602 # 80008160 <etext+0x160>
    80001b26:	d31fe0ef          	jal	80000856 <panic>

0000000080001b2a <procinit>:

// initialize the proc table.
void procinit(void) {
    80001b2a:	7139                	addi	sp,sp,-64
    80001b2c:	fc06                	sd	ra,56(sp)
    80001b2e:	f822                	sd	s0,48(sp)
    80001b30:	f426                	sd	s1,40(sp)
    80001b32:	f04a                	sd	s2,32(sp)
    80001b34:	ec4e                	sd	s3,24(sp)
    80001b36:	e852                	sd	s4,16(sp)
    80001b38:	e456                	sd	s5,8(sp)
    80001b3a:	e05a                	sd	s6,0(sp)
    80001b3c:	0080                	addi	s0,sp,64
  struct proc *p;

  initlock(&pid_lock, "nextpid");
    80001b3e:	00006597          	auipc	a1,0x6
    80001b42:	62a58593          	addi	a1,a1,1578 # 80008168 <etext+0x168>
    80001b46:	0000f517          	auipc	a0,0xf
    80001b4a:	f4250513          	addi	a0,a0,-190 # 80010a88 <pid_lock>
    80001b4e:	93eff0ef          	jal	80000c8c <initlock>
  initlock(&wait_lock, "wait_lock");
    80001b52:	00006597          	auipc	a1,0x6
    80001b56:	61e58593          	addi	a1,a1,1566 # 80008170 <etext+0x170>
    80001b5a:	0000f517          	auipc	a0,0xf
    80001b5e:	f4650513          	addi	a0,a0,-186 # 80010aa0 <wait_lock>
    80001b62:	92aff0ef          	jal	80000c8c <initlock>
  initlock(&schedinfo_lock, "schedinfo");
    80001b66:	00006597          	auipc	a1,0x6
    80001b6a:	61a58593          	addi	a1,a1,1562 # 80008180 <etext+0x180>
    80001b6e:	0000f517          	auipc	a0,0xf
    80001b72:	f4a50513          	addi	a0,a0,-182 # 80010ab8 <schedinfo_lock>
    80001b76:	916ff0ef          	jal	80000c8c <initlock>
  for (p = proc; p < &proc[NPROC]; p++) {
    80001b7a:	0000f497          	auipc	s1,0xf
    80001b7e:	35648493          	addi	s1,s1,854 # 80010ed0 <proc>
    initlock(&p->lock, "proc");
    80001b82:	00006b17          	auipc	s6,0x6
    80001b86:	60eb0b13          	addi	s6,s6,1550 # 80008190 <etext+0x190>
    p->state = UNUSED;
    p->kstack = KSTACK((int)(p - proc));
    80001b8a:	8aa6                	mv	s5,s1
    80001b8c:	000a57b7          	lui	a5,0xa5
    80001b90:	fa578793          	addi	a5,a5,-91 # a4fa5 <_entry-0x7ff5b05b>
    80001b94:	07b2                	slli	a5,a5,0xc
    80001b96:	fa578793          	addi	a5,a5,-91
    80001b9a:	4fa50937          	lui	s2,0x4fa50
    80001b9e:	a4f90913          	addi	s2,s2,-1457 # 4fa4fa4f <_entry-0x305b05b1>
    80001ba2:	1902                	slli	s2,s2,0x20
    80001ba4:	993e                	add	s2,s2,a5
    80001ba6:	040009b7          	lui	s3,0x4000
    80001baa:	19fd                	addi	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    80001bac:	09b2                	slli	s3,s3,0xc
  for (p = proc; p < &proc[NPROC]; p++) {
    80001bae:	00015a17          	auipc	s4,0x15
    80001bb2:	d22a0a13          	addi	s4,s4,-734 # 800168d0 <tickslock>
    initlock(&p->lock, "proc");
    80001bb6:	85da                	mv	a1,s6
    80001bb8:	8526                	mv	a0,s1
    80001bba:	8d2ff0ef          	jal	80000c8c <initlock>
    p->state = UNUSED;
    80001bbe:	0004ac23          	sw	zero,24(s1)
    p->kstack = KSTACK((int)(p - proc));
    80001bc2:	415487b3          	sub	a5,s1,s5
    80001bc6:	878d                	srai	a5,a5,0x3
    80001bc8:	032787b3          	mul	a5,a5,s2
    80001bcc:	07b6                	slli	a5,a5,0xd
    80001bce:	6709                	lui	a4,0x2
    80001bd0:	9fb9                	addw	a5,a5,a4
    80001bd2:	40f987b3          	sub	a5,s3,a5
    80001bd6:	e0bc                	sd	a5,64(s1)
  for (p = proc; p < &proc[NPROC]; p++) {
    80001bd8:	16848493          	addi	s1,s1,360
    80001bdc:	fd449de3          	bne	s1,s4,80001bb6 <procinit+0x8c>
  }
}
    80001be0:	70e2                	ld	ra,56(sp)
    80001be2:	7442                	ld	s0,48(sp)
    80001be4:	74a2                	ld	s1,40(sp)
    80001be6:	7902                	ld	s2,32(sp)
    80001be8:	69e2                	ld	s3,24(sp)
    80001bea:	6a42                	ld	s4,16(sp)
    80001bec:	6aa2                	ld	s5,8(sp)
    80001bee:	6b02                	ld	s6,0(sp)
    80001bf0:	6121                	addi	sp,sp,64
    80001bf2:	8082                	ret

0000000080001bf4 <cpuid>:

// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int cpuid() {
    80001bf4:	1141                	addi	sp,sp,-16
    80001bf6:	e406                	sd	ra,8(sp)
    80001bf8:	e022                	sd	s0,0(sp)
    80001bfa:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    80001bfc:	8512                	mv	a0,tp
  int id = r_tp();
  return id;
}
    80001bfe:	2501                	sext.w	a0,a0
    80001c00:	60a2                	ld	ra,8(sp)
    80001c02:	6402                	ld	s0,0(sp)
    80001c04:	0141                	addi	sp,sp,16
    80001c06:	8082                	ret

0000000080001c08 <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu *mycpu(void) {
    80001c08:	1141                	addi	sp,sp,-16
    80001c0a:	e406                	sd	ra,8(sp)
    80001c0c:	e022                	sd	s0,0(sp)
    80001c0e:	0800                	addi	s0,sp,16
    80001c10:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    80001c12:	2781                	sext.w	a5,a5
    80001c14:	079e                	slli	a5,a5,0x7
  return c;
}
    80001c16:	0000f517          	auipc	a0,0xf
    80001c1a:	eba50513          	addi	a0,a0,-326 # 80010ad0 <cpus>
    80001c1e:	953e                	add	a0,a0,a5
    80001c20:	60a2                	ld	ra,8(sp)
    80001c22:	6402                	ld	s0,0(sp)
    80001c24:	0141                	addi	sp,sp,16
    80001c26:	8082                	ret

0000000080001c28 <myproc>:

// Return the current struct proc *, or zero if none.
struct proc *myproc(void) {
    80001c28:	1101                	addi	sp,sp,-32
    80001c2a:	ec06                	sd	ra,24(sp)
    80001c2c:	e822                	sd	s0,16(sp)
    80001c2e:	e426                	sd	s1,8(sp)
    80001c30:	1000                	addi	s0,sp,32
  push_off();
    80001c32:	8a0ff0ef          	jal	80000cd2 <push_off>
    80001c36:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    80001c38:	2781                	sext.w	a5,a5
    80001c3a:	079e                	slli	a5,a5,0x7
    80001c3c:	0000f717          	auipc	a4,0xf
    80001c40:	e4c70713          	addi	a4,a4,-436 # 80010a88 <pid_lock>
    80001c44:	97ba                	add	a5,a5,a4
    80001c46:	67bc                	ld	a5,72(a5)
    80001c48:	84be                	mv	s1,a5
  pop_off();
    80001c4a:	910ff0ef          	jal	80000d5a <pop_off>
  return p;
}
    80001c4e:	8526                	mv	a0,s1
    80001c50:	60e2                	ld	ra,24(sp)
    80001c52:	6442                	ld	s0,16(sp)
    80001c54:	64a2                	ld	s1,8(sp)
    80001c56:	6105                	addi	sp,sp,32
    80001c58:	8082                	ret

0000000080001c5a <forkret>:
  release(&p->lock);
}

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void forkret(void) {
    80001c5a:	7179                	addi	sp,sp,-48
    80001c5c:	f406                	sd	ra,40(sp)
    80001c5e:	f022                	sd	s0,32(sp)
    80001c60:	ec26                	sd	s1,24(sp)
    80001c62:	1800                	addi	s0,sp,48
  extern char userret[];
  static int first = 1;
  struct proc *p = myproc();
    80001c64:	fc5ff0ef          	jal	80001c28 <myproc>
    80001c68:	84aa                	mv	s1,a0

  // Still holding p->lock from scheduler.
  release(&p->lock);
    80001c6a:	940ff0ef          	jal	80000daa <release>

  if (first) {
    80001c6e:	00007797          	auipc	a5,0x7
    80001c72:	c827a783          	lw	a5,-894(a5) # 800088f0 <first.1>
    80001c76:	cf95                	beqz	a5,80001cb2 <forkret+0x58>
    // File system initialization must be run in the context of a
    // regular process (e.g., because it calls sleep), and thus cannot
    // be run from main().
    fsinit(ROOTDEV);
    80001c78:	4505                	li	a0,1
    80001c7a:	695010ef          	jal	80003b0e <fsinit>

    first = 0;
    80001c7e:	00007797          	auipc	a5,0x7
    80001c82:	c607a923          	sw	zero,-910(a5) # 800088f0 <first.1>
    // ensure other cores see first=0.
    __sync_synchronize();
    80001c86:	0330000f          	fence	rw,rw

    // We can invoke kexec() now that file system is initialized.
    // Put the return value (argc) of kexec into a0.
    p->trapframe->a0 = kexec("/init", (char *[]){"/init", 0});
    80001c8a:	00006797          	auipc	a5,0x6
    80001c8e:	50e78793          	addi	a5,a5,1294 # 80008198 <etext+0x198>
    80001c92:	fcf43823          	sd	a5,-48(s0)
    80001c96:	fc043c23          	sd	zero,-40(s0)
    80001c9a:	fd040593          	addi	a1,s0,-48
    80001c9e:	853e                	mv	a0,a5
    80001ca0:	7f7020ef          	jal	80004c96 <kexec>
    80001ca4:	6cbc                	ld	a5,88(s1)
    80001ca6:	fba8                	sd	a0,112(a5)
    if (p->trapframe->a0 == -1) {
    80001ca8:	6cbc                	ld	a5,88(s1)
    80001caa:	7bb8                	ld	a4,112(a5)
    80001cac:	57fd                	li	a5,-1
    80001cae:	02f70d63          	beq	a4,a5,80001ce8 <forkret+0x8e>
      panic("exec");
    }
  }

  // return to user space, mimicing usertrap()'s return.
  prepare_return();
    80001cb2:	4fd000ef          	jal	800029ae <prepare_return>
  uint64 satp = MAKE_SATP(p->pagetable);
    80001cb6:	68a8                	ld	a0,80(s1)
    80001cb8:	8131                	srli	a0,a0,0xc
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    80001cba:	04000737          	lui	a4,0x4000
    80001cbe:	177d                	addi	a4,a4,-1 # 3ffffff <_entry-0x7c000001>
    80001cc0:	0732                	slli	a4,a4,0xc
    80001cc2:	00005797          	auipc	a5,0x5
    80001cc6:	3da78793          	addi	a5,a5,986 # 8000709c <userret>
    80001cca:	00005697          	auipc	a3,0x5
    80001cce:	33668693          	addi	a3,a3,822 # 80007000 <_trampoline>
    80001cd2:	8f95                	sub	a5,a5,a3
    80001cd4:	97ba                	add	a5,a5,a4
  ((void (*)(uint64))trampoline_userret)(satp);
    80001cd6:	577d                	li	a4,-1
    80001cd8:	177e                	slli	a4,a4,0x3f
    80001cda:	8d59                	or	a0,a0,a4
    80001cdc:	9782                	jalr	a5
}
    80001cde:	70a2                	ld	ra,40(sp)
    80001ce0:	7402                	ld	s0,32(sp)
    80001ce2:	64e2                	ld	s1,24(sp)
    80001ce4:	6145                	addi	sp,sp,48
    80001ce6:	8082                	ret
      panic("exec");
    80001ce8:	00006517          	auipc	a0,0x6
    80001cec:	4b850513          	addi	a0,a0,1208 # 800081a0 <etext+0x1a0>
    80001cf0:	b67fe0ef          	jal	80000856 <panic>

0000000080001cf4 <allocpid>:
int allocpid() {
    80001cf4:	1101                	addi	sp,sp,-32
    80001cf6:	ec06                	sd	ra,24(sp)
    80001cf8:	e822                	sd	s0,16(sp)
    80001cfa:	e426                	sd	s1,8(sp)
    80001cfc:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80001cfe:	0000f517          	auipc	a0,0xf
    80001d02:	d8a50513          	addi	a0,a0,-630 # 80010a88 <pid_lock>
    80001d06:	810ff0ef          	jal	80000d16 <acquire>
  pid = nextpid;
    80001d0a:	00007797          	auipc	a5,0x7
    80001d0e:	bea78793          	addi	a5,a5,-1046 # 800088f4 <nextpid>
    80001d12:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80001d14:	0014871b          	addiw	a4,s1,1
    80001d18:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001d1a:	0000f517          	auipc	a0,0xf
    80001d1e:	d6e50513          	addi	a0,a0,-658 # 80010a88 <pid_lock>
    80001d22:	888ff0ef          	jal	80000daa <release>
}
    80001d26:	8526                	mv	a0,s1
    80001d28:	60e2                	ld	ra,24(sp)
    80001d2a:	6442                	ld	s0,16(sp)
    80001d2c:	64a2                	ld	s1,8(sp)
    80001d2e:	6105                	addi	sp,sp,32
    80001d30:	8082                	ret

0000000080001d32 <proc_pagetable>:
pagetable_t proc_pagetable(struct proc *p) {
    80001d32:	1101                	addi	sp,sp,-32
    80001d34:	ec06                	sd	ra,24(sp)
    80001d36:	e822                	sd	s0,16(sp)
    80001d38:	e426                	sd	s1,8(sp)
    80001d3a:	e04a                	sd	s2,0(sp)
    80001d3c:	1000                	addi	s0,sp,32
    80001d3e:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001d40:	e42ff0ef          	jal	80001382 <uvmcreate>
    80001d44:	84aa                	mv	s1,a0
  if (pagetable == 0)
    80001d46:	cd05                	beqz	a0,80001d7e <proc_pagetable+0x4c>
  if (mappages(pagetable, TRAMPOLINE, PGSIZE, (uint64)trampoline,
    80001d48:	4729                	li	a4,10
    80001d4a:	00005697          	auipc	a3,0x5
    80001d4e:	2b668693          	addi	a3,a3,694 # 80007000 <_trampoline>
    80001d52:	6605                	lui	a2,0x1
    80001d54:	040005b7          	lui	a1,0x4000
    80001d58:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001d5a:	05b2                	slli	a1,a1,0xc
    80001d5c:	bfeff0ef          	jal	8000115a <mappages>
    80001d60:	02054663          	bltz	a0,80001d8c <proc_pagetable+0x5a>
  if (mappages(pagetable, TRAPFRAME, PGSIZE, (uint64)(p->trapframe),
    80001d64:	4719                	li	a4,6
    80001d66:	05893683          	ld	a3,88(s2)
    80001d6a:	6605                	lui	a2,0x1
    80001d6c:	020005b7          	lui	a1,0x2000
    80001d70:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001d72:	05b6                	slli	a1,a1,0xd
    80001d74:	8526                	mv	a0,s1
    80001d76:	be4ff0ef          	jal	8000115a <mappages>
    80001d7a:	00054f63          	bltz	a0,80001d98 <proc_pagetable+0x66>
}
    80001d7e:	8526                	mv	a0,s1
    80001d80:	60e2                	ld	ra,24(sp)
    80001d82:	6442                	ld	s0,16(sp)
    80001d84:	64a2                	ld	s1,8(sp)
    80001d86:	6902                	ld	s2,0(sp)
    80001d88:	6105                	addi	sp,sp,32
    80001d8a:	8082                	ret
    uvmfree(pagetable, 0);
    80001d8c:	4581                	li	a1,0
    80001d8e:	8526                	mv	a0,s1
    80001d90:	905ff0ef          	jal	80001694 <uvmfree>
    return 0;
    80001d94:	4481                	li	s1,0
    80001d96:	b7e5                	j	80001d7e <proc_pagetable+0x4c>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001d98:	4681                	li	a3,0
    80001d9a:	4605                	li	a2,1
    80001d9c:	040005b7          	lui	a1,0x4000
    80001da0:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001da2:	05b2                	slli	a1,a1,0xc
    80001da4:	8526                	mv	a0,s1
    80001da6:	e02ff0ef          	jal	800013a8 <uvmunmap>
    uvmfree(pagetable, 0);
    80001daa:	4581                	li	a1,0
    80001dac:	8526                	mv	a0,s1
    80001dae:	8e7ff0ef          	jal	80001694 <uvmfree>
    return 0;
    80001db2:	4481                	li	s1,0
    80001db4:	b7e9                	j	80001d7e <proc_pagetable+0x4c>

0000000080001db6 <proc_freepagetable>:
void proc_freepagetable(pagetable_t pagetable, uint64 sz) {
    80001db6:	1101                	addi	sp,sp,-32
    80001db8:	ec06                	sd	ra,24(sp)
    80001dba:	e822                	sd	s0,16(sp)
    80001dbc:	e426                	sd	s1,8(sp)
    80001dbe:	e04a                	sd	s2,0(sp)
    80001dc0:	1000                	addi	s0,sp,32
    80001dc2:	84aa                	mv	s1,a0
    80001dc4:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001dc6:	4681                	li	a3,0
    80001dc8:	4605                	li	a2,1
    80001dca:	040005b7          	lui	a1,0x4000
    80001dce:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001dd0:	05b2                	slli	a1,a1,0xc
    80001dd2:	dd6ff0ef          	jal	800013a8 <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001dd6:	4681                	li	a3,0
    80001dd8:	4605                	li	a2,1
    80001dda:	020005b7          	lui	a1,0x2000
    80001dde:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001de0:	05b6                	slli	a1,a1,0xd
    80001de2:	8526                	mv	a0,s1
    80001de4:	dc4ff0ef          	jal	800013a8 <uvmunmap>
  uvmfree(pagetable, sz);
    80001de8:	85ca                	mv	a1,s2
    80001dea:	8526                	mv	a0,s1
    80001dec:	8a9ff0ef          	jal	80001694 <uvmfree>
}
    80001df0:	60e2                	ld	ra,24(sp)
    80001df2:	6442                	ld	s0,16(sp)
    80001df4:	64a2                	ld	s1,8(sp)
    80001df6:	6902                	ld	s2,0(sp)
    80001df8:	6105                	addi	sp,sp,32
    80001dfa:	8082                	ret

0000000080001dfc <freeproc>:
static void freeproc(struct proc *p) {
    80001dfc:	1101                	addi	sp,sp,-32
    80001dfe:	ec06                	sd	ra,24(sp)
    80001e00:	e822                	sd	s0,16(sp)
    80001e02:	e426                	sd	s1,8(sp)
    80001e04:	1000                	addi	s0,sp,32
    80001e06:	84aa                	mv	s1,a0
  if (p->trapframe)
    80001e08:	6d28                	ld	a0,88(a0)
    80001e0a:	c119                	beqz	a0,80001e10 <freeproc+0x14>
    kfree((void *)p->trapframe);
    80001e0c:	c83fe0ef          	jal	80000a8e <kfree>
  p->trapframe = 0;
    80001e10:	0404bc23          	sd	zero,88(s1)
  if (p->pagetable)
    80001e14:	68a8                	ld	a0,80(s1)
    80001e16:	c501                	beqz	a0,80001e1e <freeproc+0x22>
    proc_freepagetable(p->pagetable, p->sz);
    80001e18:	64ac                	ld	a1,72(s1)
    80001e1a:	f9dff0ef          	jal	80001db6 <proc_freepagetable>
  p->pagetable = 0;
    80001e1e:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    80001e22:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    80001e26:	0204a823          	sw	zero,48(s1)
  p->parent = 0;
    80001e2a:	0204bc23          	sd	zero,56(s1)
  p->name[0] = 0;
    80001e2e:	14048c23          	sb	zero,344(s1)
  p->chan = 0;
    80001e32:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    80001e36:	0204a423          	sw	zero,40(s1)
  p->xstate = 0;
    80001e3a:	0204a623          	sw	zero,44(s1)
  p->state = UNUSED;
    80001e3e:	0004ac23          	sw	zero,24(s1)
}
    80001e42:	60e2                	ld	ra,24(sp)
    80001e44:	6442                	ld	s0,16(sp)
    80001e46:	64a2                	ld	s1,8(sp)
    80001e48:	6105                	addi	sp,sp,32
    80001e4a:	8082                	ret

0000000080001e4c <allocproc>:
static struct proc *allocproc(void) {
    80001e4c:	1101                	addi	sp,sp,-32
    80001e4e:	ec06                	sd	ra,24(sp)
    80001e50:	e822                	sd	s0,16(sp)
    80001e52:	e426                	sd	s1,8(sp)
    80001e54:	e04a                	sd	s2,0(sp)
    80001e56:	1000                	addi	s0,sp,32
  for (p = proc; p < &proc[NPROC]; p++) {
    80001e58:	0000f497          	auipc	s1,0xf
    80001e5c:	07848493          	addi	s1,s1,120 # 80010ed0 <proc>
    80001e60:	00015917          	auipc	s2,0x15
    80001e64:	a7090913          	addi	s2,s2,-1424 # 800168d0 <tickslock>
    acquire(&p->lock);
    80001e68:	8526                	mv	a0,s1
    80001e6a:	eadfe0ef          	jal	80000d16 <acquire>
    if (p->state == UNUSED) {
    80001e6e:	4c9c                	lw	a5,24(s1)
    80001e70:	cb91                	beqz	a5,80001e84 <allocproc+0x38>
      release(&p->lock);
    80001e72:	8526                	mv	a0,s1
    80001e74:	f37fe0ef          	jal	80000daa <release>
  for (p = proc; p < &proc[NPROC]; p++) {
    80001e78:	16848493          	addi	s1,s1,360
    80001e7c:	ff2496e3          	bne	s1,s2,80001e68 <allocproc+0x1c>
  return 0;
    80001e80:	4481                	li	s1,0
    80001e82:	a089                	j	80001ec4 <allocproc+0x78>
  p->pid = allocpid();
    80001e84:	e71ff0ef          	jal	80001cf4 <allocpid>
    80001e88:	d888                	sw	a0,48(s1)
  p->state = USED;
    80001e8a:	4785                	li	a5,1
    80001e8c:	cc9c                	sw	a5,24(s1)
  if ((p->trapframe = (struct trapframe *)kalloc()) == 0) {
    80001e8e:	d47fe0ef          	jal	80000bd4 <kalloc>
    80001e92:	892a                	mv	s2,a0
    80001e94:	eca8                	sd	a0,88(s1)
    80001e96:	cd15                	beqz	a0,80001ed2 <allocproc+0x86>
  p->pagetable = proc_pagetable(p);
    80001e98:	8526                	mv	a0,s1
    80001e9a:	e99ff0ef          	jal	80001d32 <proc_pagetable>
    80001e9e:	892a                	mv	s2,a0
    80001ea0:	e8a8                	sd	a0,80(s1)
  if (p->pagetable == 0) {
    80001ea2:	c121                	beqz	a0,80001ee2 <allocproc+0x96>
  memset(&p->context, 0, sizeof(p->context));
    80001ea4:	07000613          	li	a2,112
    80001ea8:	4581                	li	a1,0
    80001eaa:	06048513          	addi	a0,s1,96
    80001eae:	f39fe0ef          	jal	80000de6 <memset>
  p->context.ra = (uint64)forkret;
    80001eb2:	00000797          	auipc	a5,0x0
    80001eb6:	da878793          	addi	a5,a5,-600 # 80001c5a <forkret>
    80001eba:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001ebc:	60bc                	ld	a5,64(s1)
    80001ebe:	6705                	lui	a4,0x1
    80001ec0:	97ba                	add	a5,a5,a4
    80001ec2:	f4bc                	sd	a5,104(s1)
}
    80001ec4:	8526                	mv	a0,s1
    80001ec6:	60e2                	ld	ra,24(sp)
    80001ec8:	6442                	ld	s0,16(sp)
    80001eca:	64a2                	ld	s1,8(sp)
    80001ecc:	6902                	ld	s2,0(sp)
    80001ece:	6105                	addi	sp,sp,32
    80001ed0:	8082                	ret
    freeproc(p);
    80001ed2:	8526                	mv	a0,s1
    80001ed4:	f29ff0ef          	jal	80001dfc <freeproc>
    release(&p->lock);
    80001ed8:	8526                	mv	a0,s1
    80001eda:	ed1fe0ef          	jal	80000daa <release>
    return 0;
    80001ede:	84ca                	mv	s1,s2
    80001ee0:	b7d5                	j	80001ec4 <allocproc+0x78>
    freeproc(p);
    80001ee2:	8526                	mv	a0,s1
    80001ee4:	f19ff0ef          	jal	80001dfc <freeproc>
    release(&p->lock);
    80001ee8:	8526                	mv	a0,s1
    80001eea:	ec1fe0ef          	jal	80000daa <release>
    return 0;
    80001eee:	84ca                	mv	s1,s2
    80001ef0:	bfd1                	j	80001ec4 <allocproc+0x78>

0000000080001ef2 <userinit>:
void userinit(void) {
    80001ef2:	1101                	addi	sp,sp,-32
    80001ef4:	ec06                	sd	ra,24(sp)
    80001ef6:	e822                	sd	s0,16(sp)
    80001ef8:	e426                	sd	s1,8(sp)
    80001efa:	1000                	addi	s0,sp,32
  p = allocproc();
    80001efc:	f51ff0ef          	jal	80001e4c <allocproc>
    80001f00:	84aa                	mv	s1,a0
  initproc = p;
    80001f02:	00007797          	auipc	a5,0x7
    80001f06:	a2a7b323          	sd	a0,-1498(a5) # 80008928 <initproc>
  p->cwd = namei("/");
    80001f0a:	00006517          	auipc	a0,0x6
    80001f0e:	29e50513          	addi	a0,a0,670 # 800081a8 <etext+0x1a8>
    80001f12:	136020ef          	jal	80004048 <namei>
    80001f16:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    80001f1a:	478d                	li	a5,3
    80001f1c:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001f1e:	8526                	mv	a0,s1
    80001f20:	e8bfe0ef          	jal	80000daa <release>
}
    80001f24:	60e2                	ld	ra,24(sp)
    80001f26:	6442                	ld	s0,16(sp)
    80001f28:	64a2                	ld	s1,8(sp)
    80001f2a:	6105                	addi	sp,sp,32
    80001f2c:	8082                	ret

0000000080001f2e <growproc>:
int growproc(int n) {
    80001f2e:	7135                	addi	sp,sp,-160
    80001f30:	ed06                	sd	ra,152(sp)
    80001f32:	e922                	sd	s0,144(sp)
    80001f34:	e526                	sd	s1,136(sp)
    80001f36:	e14a                	sd	s2,128(sp)
    80001f38:	fcce                	sd	s3,120(sp)
    80001f3a:	1100                	addi	s0,sp,160
    80001f3c:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80001f3e:	cebff0ef          	jal	80001c28 <myproc>
    80001f42:	89aa                	mv	s3,a0
  sz = p->sz;
    80001f44:	04853903          	ld	s2,72(a0)
  if (n > 0) {
    80001f48:	02905b63          	blez	s1,80001f7e <growproc+0x50>
    if (sz + n > TRAPFRAME) {
    80001f4c:	01248633          	add	a2,s1,s2
    80001f50:	020007b7          	lui	a5,0x2000
    80001f54:	17fd                	addi	a5,a5,-1 # 1ffffff <_entry-0x7e000001>
    80001f56:	07b6                	slli	a5,a5,0xd
    80001f58:	0ac7ed63          	bltu	a5,a2,80002012 <growproc+0xe4>
    if ((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0) {
    80001f5c:	4691                	li	a3,4
    80001f5e:	85ca                	mv	a1,s2
    80001f60:	6928                	ld	a0,80(a0)
    80001f62:	daaff0ef          	jal	8000150c <uvmalloc>
    80001f66:	892a                	mv	s2,a0
    80001f68:	c55d                	beqz	a0,80002016 <growproc+0xe8>
  p->sz = sz;
    80001f6a:	0529b423          	sd	s2,72(s3)
  return 0;
    80001f6e:	4501                	li	a0,0
}
    80001f70:	60ea                	ld	ra,152(sp)
    80001f72:	644a                	ld	s0,144(sp)
    80001f74:	64aa                	ld	s1,136(sp)
    80001f76:	690a                	ld	s2,128(sp)
    80001f78:	79e6                	ld	s3,120(sp)
    80001f7a:	610d                	addi	sp,sp,160
    80001f7c:	8082                	ret
  } else if (n < 0) {
    80001f7e:	fe04d6e3          	bgez	s1,80001f6a <growproc+0x3c>
    80001f82:	f8d2                	sd	s4,112(sp)
  memset(&e, 0, sizeof(e));
    80001f84:	06800613          	li	a2,104
    80001f88:	4581                	li	a1,0
    80001f8a:	f6840513          	addi	a0,s0,-152
    80001f8e:	e59fe0ef          	jal	80000de6 <memset>
  e.ticks  = ticks;
    80001f92:	00007797          	auipc	a5,0x7
    80001f96:	99e7a783          	lw	a5,-1634(a5) # 80008930 <ticks>
    80001f9a:	f6f42823          	sw	a5,-144(s0)
    80001f9e:	8792                	mv	a5,tp
  int id = r_tp();
    80001fa0:	f6f42a23          	sw	a5,-140(s0)
  e.type   = MEM_SHRINK;
    80001fa4:	4789                	li	a5,2
    80001fa6:	f6f42c23          	sw	a5,-136(s0)
  e.pid    = p->pid;
    80001faa:	0309a783          	lw	a5,48(s3)
    80001fae:	f6f42e23          	sw	a5,-132(s0)
  e.state  = p->state;
    80001fb2:	0189a783          	lw	a5,24(s3)
    80001fb6:	f8f42023          	sw	a5,-128(s0)
  e.oldsz  = sz;
    80001fba:	fb243423          	sd	s2,-88(s0)
  e.newsz  = sz + n;
    80001fbe:	94ca                	add	s1,s1,s2
    80001fc0:	fa943823          	sd	s1,-80(s0)
  e.source = SRC_UVMDEALLOC;
    80001fc4:	4799                	li	a5,6
    80001fc6:	fcf42223          	sw	a5,-60(s0)
  e.kind   = PAGE_USER;
    80001fca:	4785                	li	a5,1
    80001fcc:	fcf42423          	sw	a5,-56(s0)
  safestrcpy(e.name, p->name, MEM_NM);
    80001fd0:	15898793          	addi	a5,s3,344
    80001fd4:	4641                	li	a2,16
    80001fd6:	8a3e                	mv	s4,a5
    80001fd8:	85be                	mv	a1,a5
    80001fda:	f8440513          	addi	a0,s0,-124
    80001fde:	f5dfe0ef          	jal	80000f3a <safestrcpy>
  memlog_push(&e);
    80001fe2:	f6840513          	addi	a0,s0,-152
    80001fe6:	516040ef          	jal	800064fc <memlog_push>
  printf("DEBUG SHRINK pid=%d old=%p new=%p name=%s\n",
    80001fea:	8752                	mv	a4,s4
    80001fec:	86a6                	mv	a3,s1
    80001fee:	864a                	mv	a2,s2
    80001ff0:	0309a583          	lw	a1,48(s3)
    80001ff4:	00006517          	auipc	a0,0x6
    80001ff8:	1bc50513          	addi	a0,a0,444 # 800081b0 <etext+0x1b0>
    80001ffc:	d30fe0ef          	jal	8000052c <printf>
  sz = uvmdealloc(p->pagetable, sz, sz + n);
    80002000:	8626                	mv	a2,s1
    80002002:	85ca                	mv	a1,s2
    80002004:	0509b503          	ld	a0,80(s3)
    80002008:	cc0ff0ef          	jal	800014c8 <uvmdealloc>
    8000200c:	892a                	mv	s2,a0
    8000200e:	7a46                	ld	s4,112(sp)
    80002010:	bfa9                	j	80001f6a <growproc+0x3c>
      return -1;
    80002012:	557d                	li	a0,-1
    80002014:	bfb1                	j	80001f70 <growproc+0x42>
      return -1;
    80002016:	557d                	li	a0,-1
    80002018:	bfa1                	j	80001f70 <growproc+0x42>

000000008000201a <kfork>:
int kfork(void) {
    8000201a:	7139                	addi	sp,sp,-64
    8000201c:	fc06                	sd	ra,56(sp)
    8000201e:	f822                	sd	s0,48(sp)
    80002020:	f426                	sd	s1,40(sp)
    80002022:	e456                	sd	s5,8(sp)
    80002024:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    80002026:	c03ff0ef          	jal	80001c28 <myproc>
    8000202a:	8aaa                	mv	s5,a0
  if ((np = allocproc()) == 0) {
    8000202c:	e21ff0ef          	jal	80001e4c <allocproc>
    80002030:	0e050a63          	beqz	a0,80002124 <kfork+0x10a>
    80002034:	e852                	sd	s4,16(sp)
    80002036:	8a2a                	mv	s4,a0
  if (uvmcopy(p->pagetable, np->pagetable, p->sz) < 0) {
    80002038:	048ab603          	ld	a2,72(s5)
    8000203c:	692c                	ld	a1,80(a0)
    8000203e:	050ab503          	ld	a0,80(s5)
    80002042:	e84ff0ef          	jal	800016c6 <uvmcopy>
    80002046:	04054863          	bltz	a0,80002096 <kfork+0x7c>
    8000204a:	f04a                	sd	s2,32(sp)
    8000204c:	ec4e                	sd	s3,24(sp)
  np->sz = p->sz;
    8000204e:	048ab783          	ld	a5,72(s5)
    80002052:	04fa3423          	sd	a5,72(s4)
  *(np->trapframe) = *(p->trapframe);
    80002056:	058ab683          	ld	a3,88(s5)
    8000205a:	87b6                	mv	a5,a3
    8000205c:	058a3703          	ld	a4,88(s4)
    80002060:	12068693          	addi	a3,a3,288
    80002064:	6388                	ld	a0,0(a5)
    80002066:	678c                	ld	a1,8(a5)
    80002068:	6b90                	ld	a2,16(a5)
    8000206a:	e308                	sd	a0,0(a4)
    8000206c:	e70c                	sd	a1,8(a4)
    8000206e:	eb10                	sd	a2,16(a4)
    80002070:	6f90                	ld	a2,24(a5)
    80002072:	ef10                	sd	a2,24(a4)
    80002074:	02078793          	addi	a5,a5,32
    80002078:	02070713          	addi	a4,a4,32 # 1020 <_entry-0x7fffefe0>
    8000207c:	fed794e3          	bne	a5,a3,80002064 <kfork+0x4a>
  np->trapframe->a0 = 0;
    80002080:	058a3783          	ld	a5,88(s4)
    80002084:	0607b823          	sd	zero,112(a5)
  for (i = 0; i < NOFILE; i++)
    80002088:	0d0a8493          	addi	s1,s5,208
    8000208c:	0d0a0913          	addi	s2,s4,208
    80002090:	150a8993          	addi	s3,s5,336
    80002094:	a831                	j	800020b0 <kfork+0x96>
    freeproc(np);
    80002096:	8552                	mv	a0,s4
    80002098:	d65ff0ef          	jal	80001dfc <freeproc>
    release(&np->lock);
    8000209c:	8552                	mv	a0,s4
    8000209e:	d0dfe0ef          	jal	80000daa <release>
    return -1;
    800020a2:	54fd                	li	s1,-1
    800020a4:	6a42                	ld	s4,16(sp)
    800020a6:	a885                	j	80002116 <kfork+0xfc>
  for (i = 0; i < NOFILE; i++)
    800020a8:	04a1                	addi	s1,s1,8
    800020aa:	0921                	addi	s2,s2,8
    800020ac:	01348963          	beq	s1,s3,800020be <kfork+0xa4>
    if (p->ofile[i])
    800020b0:	6088                	ld	a0,0(s1)
    800020b2:	d97d                	beqz	a0,800020a8 <kfork+0x8e>
      np->ofile[i] = filedup(p->ofile[i]);
    800020b4:	550020ef          	jal	80004604 <filedup>
    800020b8:	00a93023          	sd	a0,0(s2)
    800020bc:	b7f5                	j	800020a8 <kfork+0x8e>
  np->cwd = idup(p->cwd);
    800020be:	150ab503          	ld	a0,336(s5)
    800020c2:	722010ef          	jal	800037e4 <idup>
    800020c6:	14aa3823          	sd	a0,336(s4)
  safestrcpy(np->name, p->name, sizeof(p->name));
    800020ca:	4641                	li	a2,16
    800020cc:	158a8593          	addi	a1,s5,344
    800020d0:	158a0513          	addi	a0,s4,344
    800020d4:	e67fe0ef          	jal	80000f3a <safestrcpy>
  pid = np->pid;
    800020d8:	030a2483          	lw	s1,48(s4)
  release(&np->lock);
    800020dc:	8552                	mv	a0,s4
    800020de:	ccdfe0ef          	jal	80000daa <release>
  acquire(&wait_lock);
    800020e2:	0000f517          	auipc	a0,0xf
    800020e6:	9be50513          	addi	a0,a0,-1602 # 80010aa0 <wait_lock>
    800020ea:	c2dfe0ef          	jal	80000d16 <acquire>
  np->parent = p;
    800020ee:	035a3c23          	sd	s5,56(s4)
  release(&wait_lock);
    800020f2:	0000f517          	auipc	a0,0xf
    800020f6:	9ae50513          	addi	a0,a0,-1618 # 80010aa0 <wait_lock>
    800020fa:	cb1fe0ef          	jal	80000daa <release>
  acquire(&np->lock);
    800020fe:	8552                	mv	a0,s4
    80002100:	c17fe0ef          	jal	80000d16 <acquire>
  np->state = RUNNABLE;
    80002104:	478d                	li	a5,3
    80002106:	00fa2c23          	sw	a5,24(s4)
  release(&np->lock);
    8000210a:	8552                	mv	a0,s4
    8000210c:	c9ffe0ef          	jal	80000daa <release>
  return pid;
    80002110:	7902                	ld	s2,32(sp)
    80002112:	69e2                	ld	s3,24(sp)
    80002114:	6a42                	ld	s4,16(sp)
}
    80002116:	8526                	mv	a0,s1
    80002118:	70e2                	ld	ra,56(sp)
    8000211a:	7442                	ld	s0,48(sp)
    8000211c:	74a2                	ld	s1,40(sp)
    8000211e:	6aa2                	ld	s5,8(sp)
    80002120:	6121                	addi	sp,sp,64
    80002122:	8082                	ret
    return -1;
    80002124:	54fd                	li	s1,-1
    80002126:	bfc5                	j	80002116 <kfork+0xfc>

0000000080002128 <scheduler>:
void scheduler(void) {
    80002128:	7171                	addi	sp,sp,-176
    8000212a:	f506                	sd	ra,168(sp)
    8000212c:	f122                	sd	s0,160(sp)
    8000212e:	ed26                	sd	s1,152(sp)
    80002130:	e94a                	sd	s2,144(sp)
    80002132:	e54e                	sd	s3,136(sp)
    80002134:	e152                	sd	s4,128(sp)
    80002136:	fcd6                	sd	s5,120(sp)
    80002138:	f8da                	sd	s6,112(sp)
    8000213a:	f4de                	sd	s7,104(sp)
    8000213c:	f0e2                	sd	s8,96(sp)
    8000213e:	ece6                	sd	s9,88(sp)
    80002140:	e8ea                	sd	s10,80(sp)
    80002142:	1900                	addi	s0,sp,176
    80002144:	8492                	mv	s1,tp
  int id = r_tp();
    80002146:	2481                	sext.w	s1,s1
    80002148:	8792                	mv	a5,tp
    if(cpuid() == 0){
    8000214a:	2781                	sext.w	a5,a5
    8000214c:	c79d                	beqz	a5,8000217a <scheduler+0x52>
  c->proc = 0;
    8000214e:	00749b93          	slli	s7,s1,0x7
    80002152:	0000f797          	auipc	a5,0xf
    80002156:	93678793          	addi	a5,a5,-1738 # 80010a88 <pid_lock>
    8000215a:	97de                	add	a5,a5,s7
    8000215c:	0407b423          	sd	zero,72(a5)
        swtch(&c->context, &p->context);
    80002160:	0000f797          	auipc	a5,0xf
    80002164:	97878793          	addi	a5,a5,-1672 # 80010ad8 <cpus+0x8>
    80002168:	9bbe                	add	s7,s7,a5
        p->state = RUNNING;
    8000216a:	4b11                	li	s6,4
        c->proc = p;
    8000216c:	049e                	slli	s1,s1,0x7
    8000216e:	0000fa97          	auipc	s5,0xf
    80002172:	91aa8a93          	addi	s5,s5,-1766 # 80010a88 <pid_lock>
    80002176:	9aa6                	add	s5,s5,s1
    80002178:	a2d5                	j	8000235c <scheduler+0x234>
      acquire(&schedinfo_lock);
    8000217a:	0000f517          	auipc	a0,0xf
    8000217e:	93e50513          	addi	a0,a0,-1730 # 80010ab8 <schedinfo_lock>
    80002182:	b95fe0ef          	jal	80000d16 <acquire>
      if(sched_info_logged == 0){
    80002186:	00006797          	auipc	a5,0x6
    8000218a:	79a7a783          	lw	a5,1946(a5) # 80008920 <sched_info_logged>
    8000218e:	cb81                	beqz	a5,8000219e <scheduler+0x76>
      release(&schedinfo_lock);
    80002190:	0000f517          	auipc	a0,0xf
    80002194:	92850513          	addi	a0,a0,-1752 # 80010ab8 <schedinfo_lock>
    80002198:	c13fe0ef          	jal	80000daa <release>
    8000219c:	bf4d                	j	8000214e <scheduler+0x26>
        sched_info_logged = 1;
    8000219e:	4905                	li	s2,1
    800021a0:	00006797          	auipc	a5,0x6
    800021a4:	7927a023          	sw	s2,1920(a5) # 80008920 <sched_info_logged>
        memset(&e, 0, sizeof(e));
    800021a8:	f5840993          	addi	s3,s0,-168
    800021ac:	04400613          	li	a2,68
    800021b0:	4581                	li	a1,0
    800021b2:	854e                	mv	a0,s3
    800021b4:	c33fe0ef          	jal	80000de6 <memset>
        e.ticks = ticks;
    800021b8:	00006797          	auipc	a5,0x6
    800021bc:	7787a783          	lw	a5,1912(a5) # 80008930 <ticks>
    800021c0:	f4f42e23          	sw	a5,-164(s0)
        e.event_type = SCHED_EV_INFO;
    800021c4:	f7242023          	sw	s2,-160(s0)
        safestrcpy(e.scheduler_name, "RR", sizeof(e.scheduler_name));
    800021c8:	4641                	li	a2,16
    800021ca:	00006597          	auipc	a1,0x6
    800021ce:	01658593          	addi	a1,a1,22 # 800081e0 <etext+0x1e0>
    800021d2:	f6440513          	addi	a0,s0,-156
    800021d6:	d65fe0ef          	jal	80000f3a <safestrcpy>
        e.num_cpus = 3;
    800021da:	478d                	li	a5,3
    800021dc:	f6f42a23          	sw	a5,-140(s0)
        e.time_slice = 1;
    800021e0:	f7242c23          	sw	s2,-136(s0)
        schedlog_emit(&e);
    800021e4:	854e                	mv	a0,s3
    800021e6:	578040ef          	jal	8000675e <schedlog_emit>
    800021ea:	b75d                	j	80002190 <scheduler+0x68>
        if(strncmp(p->name, "schedexport", 16) != 0){
    800021ec:	158c8c13          	addi	s8,s9,344
    800021f0:	864e                	mv	a2,s3
    800021f2:	85d2                	mv	a1,s4
    800021f4:	8562                	mv	a0,s8
    800021f6:	cc5fe0ef          	jal	80000eba <strncmp>
    800021fa:	e945                	bnez	a0,800022aa <scheduler+0x182>
        swtch(&c->context, &p->context);
    800021fc:	060c8593          	addi	a1,s9,96
    80002200:	855e                	mv	a0,s7
    80002202:	702000ef          	jal	80002904 <swtch>
        if(strncmp(p->name, "schedexport", 16) != 0){
    80002206:	864e                	mv	a2,s3
    80002208:	85d2                	mv	a1,s4
    8000220a:	8562                	mv	a0,s8
    8000220c:	caffe0ef          	jal	80000eba <strncmp>
    80002210:	0e051163          	bnez	a0,800022f2 <scheduler+0x1ca>
        c->proc = 0;
    80002214:	040ab423          	sd	zero,72(s5)
        found = 1;
    80002218:	4c05                	li	s8,1
      release(&p->lock);
    8000221a:	8526                	mv	a0,s1
    8000221c:	b8ffe0ef          	jal	80000daa <release>
    for (p = proc; p < &proc[NPROC]; p++) {
    80002220:	16848493          	addi	s1,s1,360
    80002224:	00014797          	auipc	a5,0x14
    80002228:	6ac78793          	addi	a5,a5,1708 # 800168d0 <tickslock>
    8000222c:	12f48463          	beq	s1,a5,80002354 <scheduler+0x22c>
      acquire(&p->lock);
    80002230:	8526                	mv	a0,s1
    80002232:	ae5fe0ef          	jal	80000d16 <acquire>
      if (p->state == RUNNABLE) {
    80002236:	4c9c                	lw	a5,24(s1)
    80002238:	ff2791e3          	bne	a5,s2,8000221a <scheduler+0xf2>
    8000223c:	8ca6                	mv	s9,s1
        p->state = RUNNING;
    8000223e:	0164ac23          	sw	s6,24(s1)
        c->proc = p;
    80002242:	049ab423          	sd	s1,72(s5)
        cslog_run_start(p);
    80002246:	8526                	mv	a0,s1
    80002248:	65d030ef          	jal	800060a4 <cslog_run_start>
    8000224c:	8792                	mv	a5,tp
        if (cpuid() == 0 && sched_info_logged == 0) {
    8000224e:	2781                	sext.w	a5,a5
    80002250:	ffd1                	bnez	a5,800021ec <scheduler+0xc4>
    80002252:	00006797          	auipc	a5,0x6
    80002256:	6ce7a783          	lw	a5,1742(a5) # 80008920 <sched_info_logged>
    8000225a:	fbc9                	bnez	a5,800021ec <scheduler+0xc4>
          sched_info_logged = 1;
    8000225c:	4c05                	li	s8,1
    8000225e:	00006797          	auipc	a5,0x6
    80002262:	6d87a123          	sw	s8,1730(a5) # 80008920 <sched_info_logged>
          memset(&e, 0, sizeof(e));
    80002266:	f5840d13          	addi	s10,s0,-168
    8000226a:	04400613          	li	a2,68
    8000226e:	4581                	li	a1,0
    80002270:	856a                	mv	a0,s10
    80002272:	b75fe0ef          	jal	80000de6 <memset>
          e.ticks = ticks;
    80002276:	00006797          	auipc	a5,0x6
    8000227a:	6ba7a783          	lw	a5,1722(a5) # 80008930 <ticks>
    8000227e:	f4f42e23          	sw	a5,-164(s0)
          e.event_type = SCHED_EV_INFO;
    80002282:	f7842023          	sw	s8,-160(s0)
          safestrcpy(e.scheduler_name, "RR", sizeof(e.scheduler_name));
    80002286:	864e                	mv	a2,s3
    80002288:	00006597          	auipc	a1,0x6
    8000228c:	f5858593          	addi	a1,a1,-168 # 800081e0 <etext+0x1e0>
    80002290:	f6440513          	addi	a0,s0,-156
    80002294:	ca7fe0ef          	jal	80000f3a <safestrcpy>
          e.num_cpus = NCPU;
    80002298:	47a1                	li	a5,8
    8000229a:	f6f42a23          	sw	a5,-140(s0)
          e.time_slice = 1;
    8000229e:	f7842c23          	sw	s8,-136(s0)
          schedlog_emit(&e);
    800022a2:	856a                	mv	a0,s10
    800022a4:	4ba040ef          	jal	8000675e <schedlog_emit>
    800022a8:	b791                	j	800021ec <scheduler+0xc4>
          memset(&e, 0, sizeof(e));
    800022aa:	f5840d13          	addi	s10,s0,-168
    800022ae:	04400613          	li	a2,68
    800022b2:	4581                	li	a1,0
    800022b4:	856a                	mv	a0,s10
    800022b6:	b31fe0ef          	jal	80000de6 <memset>
          e.ticks = ticks;
    800022ba:	00006797          	auipc	a5,0x6
    800022be:	6767a783          	lw	a5,1654(a5) # 80008930 <ticks>
    800022c2:	f4f42e23          	sw	a5,-164(s0)
          e.event_type = SCHED_EV_ON_CPU;
    800022c6:	4789                	li	a5,2
    800022c8:	f6f42023          	sw	a5,-160(s0)
    800022cc:	8792                	mv	a5,tp
  int id = r_tp();
    800022ce:	f6f42e23          	sw	a5,-132(s0)
          e.pid = p->pid;
    800022d2:	589c                	lw	a5,48(s1)
    800022d4:	f8f42023          	sw	a5,-128(s0)
          safestrcpy(e.name, p->name, sizeof(e.name));
    800022d8:	864e                	mv	a2,s3
    800022da:	85e2                	mv	a1,s8
    800022dc:	f8440513          	addi	a0,s0,-124
    800022e0:	c5bfe0ef          	jal	80000f3a <safestrcpy>
          e.state = p->state;
    800022e4:	4c9c                	lw	a5,24(s1)
    800022e6:	f8f42a23          	sw	a5,-108(s0)
          schedlog_emit(&e);
    800022ea:	856a                	mv	a0,s10
    800022ec:	472040ef          	jal	8000675e <schedlog_emit>
    800022f0:	b731                	j	800021fc <scheduler+0xd4>
          memset(&e2, 0, sizeof(e2));
    800022f2:	04400613          	li	a2,68
    800022f6:	4581                	li	a1,0
    800022f8:	f5840513          	addi	a0,s0,-168
    800022fc:	aebfe0ef          	jal	80000de6 <memset>
          e2.ticks = ticks;
    80002300:	00006797          	auipc	a5,0x6
    80002304:	6307a783          	lw	a5,1584(a5) # 80008930 <ticks>
    80002308:	f4f42e23          	sw	a5,-164(s0)
          e2.event_type = SCHED_EV_OFF_CPU;
    8000230c:	f7242023          	sw	s2,-160(s0)
    80002310:	8792                	mv	a5,tp
  int id = r_tp();
    80002312:	f6f42e23          	sw	a5,-132(s0)
          e2.pid = p->pid;
    80002316:	589c                	lw	a5,48(s1)
    80002318:	f8f42023          	sw	a5,-128(s0)
          safestrcpy(e2.name, p->name, sizeof(e2.name));
    8000231c:	864e                	mv	a2,s3
    8000231e:	85e2                	mv	a1,s8
    80002320:	f8440513          	addi	a0,s0,-124
    80002324:	c17fe0ef          	jal	80000f3a <safestrcpy>
          e2.state = p->state;
    80002328:	4c9c                	lw	a5,24(s1)
          if(p->state == SLEEPING)
    8000232a:	4689                	li	a3,2
    8000232c:	8736                	mv	a4,a3
    8000232e:	00d78a63          	beq	a5,a3,80002342 <scheduler+0x21a>
          else if(p->state == ZOMBIE)
    80002332:	4695                	li	a3,5
    80002334:	875a                	mv	a4,s6
    80002336:	00d78663          	beq	a5,a3,80002342 <scheduler+0x21a>
          else if(p->state == RUNNABLE)
    8000233a:	874a                	mv	a4,s2
    8000233c:	01278363          	beq	a5,s2,80002342 <scheduler+0x21a>
    80002340:	4701                	li	a4,0
          e2.state = p->state;
    80002342:	f8f42a23          	sw	a5,-108(s0)
            e2.reason = SCHED_OFF_SLEEP;
    80002346:	f8e42c23          	sw	a4,-104(s0)
          schedlog_emit(&e2);
    8000234a:	f5840513          	addi	a0,s0,-168
    8000234e:	410040ef          	jal	8000675e <schedlog_emit>
    80002352:	b5c9                	j	80002214 <scheduler+0xec>
    if (found == 0) {
    80002354:	000c1563          	bnez	s8,8000235e <scheduler+0x236>
      asm volatile("wfi");
    80002358:	10500073          	wfi
      if (p->state == RUNNABLE) {
    8000235c:	490d                	li	s2,3
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000235e:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002362:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002366:	10079073          	csrw	sstatus,a5
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000236a:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    8000236e:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002370:	10079073          	csrw	sstatus,a5
    int found = 0;
    80002374:	4c01                	li	s8,0
    for (p = proc; p < &proc[NPROC]; p++) {
    80002376:	0000f497          	auipc	s1,0xf
    8000237a:	b5a48493          	addi	s1,s1,-1190 # 80010ed0 <proc>
        if(strncmp(p->name, "schedexport", 16) != 0){
    8000237e:	49c1                	li	s3,16
    80002380:	00006a17          	auipc	s4,0x6
    80002384:	e68a0a13          	addi	s4,s4,-408 # 800081e8 <etext+0x1e8>
    80002388:	b565                	j	80002230 <scheduler+0x108>

000000008000238a <sched>:
void sched(void) {
    8000238a:	7179                	addi	sp,sp,-48
    8000238c:	f406                	sd	ra,40(sp)
    8000238e:	f022                	sd	s0,32(sp)
    80002390:	ec26                	sd	s1,24(sp)
    80002392:	e84a                	sd	s2,16(sp)
    80002394:	e44e                	sd	s3,8(sp)
    80002396:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80002398:	891ff0ef          	jal	80001c28 <myproc>
    8000239c:	84aa                	mv	s1,a0
  if (!holding(&p->lock))
    8000239e:	909fe0ef          	jal	80000ca6 <holding>
    800023a2:	c935                	beqz	a0,80002416 <sched+0x8c>
  asm volatile("mv %0, tp" : "=r" (x) );
    800023a4:	8792                	mv	a5,tp
  if (mycpu()->noff != 1)
    800023a6:	2781                	sext.w	a5,a5
    800023a8:	079e                	slli	a5,a5,0x7
    800023aa:	0000e717          	auipc	a4,0xe
    800023ae:	6de70713          	addi	a4,a4,1758 # 80010a88 <pid_lock>
    800023b2:	97ba                	add	a5,a5,a4
    800023b4:	0c07a703          	lw	a4,192(a5)
    800023b8:	4785                	li	a5,1
    800023ba:	06f71463          	bne	a4,a5,80002422 <sched+0x98>
  if (p->state == RUNNING)
    800023be:	4c98                	lw	a4,24(s1)
    800023c0:	4791                	li	a5,4
    800023c2:	06f70663          	beq	a4,a5,8000242e <sched+0xa4>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800023c6:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    800023ca:	8b89                	andi	a5,a5,2
  if (intr_get())
    800023cc:	e7bd                	bnez	a5,8000243a <sched+0xb0>
  asm volatile("mv %0, tp" : "=r" (x) );
    800023ce:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    800023d0:	0000e917          	auipc	s2,0xe
    800023d4:	6b890913          	addi	s2,s2,1720 # 80010a88 <pid_lock>
    800023d8:	2781                	sext.w	a5,a5
    800023da:	079e                	slli	a5,a5,0x7
    800023dc:	97ca                	add	a5,a5,s2
    800023de:	0c47a983          	lw	s3,196(a5)
    800023e2:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    800023e4:	2781                	sext.w	a5,a5
    800023e6:	079e                	slli	a5,a5,0x7
    800023e8:	07a1                	addi	a5,a5,8
    800023ea:	0000e597          	auipc	a1,0xe
    800023ee:	6e658593          	addi	a1,a1,1766 # 80010ad0 <cpus>
    800023f2:	95be                	add	a1,a1,a5
    800023f4:	06048513          	addi	a0,s1,96
    800023f8:	50c000ef          	jal	80002904 <swtch>
    800023fc:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    800023fe:	2781                	sext.w	a5,a5
    80002400:	079e                	slli	a5,a5,0x7
    80002402:	993e                	add	s2,s2,a5
    80002404:	0d392223          	sw	s3,196(s2)
}
    80002408:	70a2                	ld	ra,40(sp)
    8000240a:	7402                	ld	s0,32(sp)
    8000240c:	64e2                	ld	s1,24(sp)
    8000240e:	6942                	ld	s2,16(sp)
    80002410:	69a2                	ld	s3,8(sp)
    80002412:	6145                	addi	sp,sp,48
    80002414:	8082                	ret
    panic("sched p->lock");
    80002416:	00006517          	auipc	a0,0x6
    8000241a:	de250513          	addi	a0,a0,-542 # 800081f8 <etext+0x1f8>
    8000241e:	c38fe0ef          	jal	80000856 <panic>
    panic("sched locks");
    80002422:	00006517          	auipc	a0,0x6
    80002426:	de650513          	addi	a0,a0,-538 # 80008208 <etext+0x208>
    8000242a:	c2cfe0ef          	jal	80000856 <panic>
    panic("sched RUNNING");
    8000242e:	00006517          	auipc	a0,0x6
    80002432:	dea50513          	addi	a0,a0,-534 # 80008218 <etext+0x218>
    80002436:	c20fe0ef          	jal	80000856 <panic>
    panic("sched interruptible");
    8000243a:	00006517          	auipc	a0,0x6
    8000243e:	dee50513          	addi	a0,a0,-530 # 80008228 <etext+0x228>
    80002442:	c14fe0ef          	jal	80000856 <panic>

0000000080002446 <yield>:
void yield(void) {
    80002446:	1101                	addi	sp,sp,-32
    80002448:	ec06                	sd	ra,24(sp)
    8000244a:	e822                	sd	s0,16(sp)
    8000244c:	e426                	sd	s1,8(sp)
    8000244e:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80002450:	fd8ff0ef          	jal	80001c28 <myproc>
    80002454:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80002456:	8c1fe0ef          	jal	80000d16 <acquire>
  p->state = RUNNABLE;
    8000245a:	478d                	li	a5,3
    8000245c:	cc9c                	sw	a5,24(s1)
  sched();
    8000245e:	f2dff0ef          	jal	8000238a <sched>
  release(&p->lock);
    80002462:	8526                	mv	a0,s1
    80002464:	947fe0ef          	jal	80000daa <release>
}
    80002468:	60e2                	ld	ra,24(sp)
    8000246a:	6442                	ld	s0,16(sp)
    8000246c:	64a2                	ld	s1,8(sp)
    8000246e:	6105                	addi	sp,sp,32
    80002470:	8082                	ret

0000000080002472 <sleep>:

// Sleep on channel chan, releasing condition lock lk.
// Re-acquires lk when awakened.
void sleep(void *chan, struct spinlock *lk) {
    80002472:	7179                	addi	sp,sp,-48
    80002474:	f406                	sd	ra,40(sp)
    80002476:	f022                	sd	s0,32(sp)
    80002478:	ec26                	sd	s1,24(sp)
    8000247a:	e84a                	sd	s2,16(sp)
    8000247c:	e44e                	sd	s3,8(sp)
    8000247e:	1800                	addi	s0,sp,48
    80002480:	89aa                	mv	s3,a0
    80002482:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002484:	fa4ff0ef          	jal	80001c28 <myproc>
    80002488:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock); // DOC: sleeplock1
    8000248a:	88dfe0ef          	jal	80000d16 <acquire>
  release(lk);
    8000248e:	854a                	mv	a0,s2
    80002490:	91bfe0ef          	jal	80000daa <release>

  // Go to sleep.
  p->chan = chan;
    80002494:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    80002498:	4789                	li	a5,2
    8000249a:	cc9c                	sw	a5,24(s1)

  sched();
    8000249c:	eefff0ef          	jal	8000238a <sched>

  // Tidy up.
  p->chan = 0;
    800024a0:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    800024a4:	8526                	mv	a0,s1
    800024a6:	905fe0ef          	jal	80000daa <release>
  acquire(lk);
    800024aa:	854a                	mv	a0,s2
    800024ac:	86bfe0ef          	jal	80000d16 <acquire>
}
    800024b0:	70a2                	ld	ra,40(sp)
    800024b2:	7402                	ld	s0,32(sp)
    800024b4:	64e2                	ld	s1,24(sp)
    800024b6:	6942                	ld	s2,16(sp)
    800024b8:	69a2                	ld	s3,8(sp)
    800024ba:	6145                	addi	sp,sp,48
    800024bc:	8082                	ret

00000000800024be <wakeup>:

// Wake up all processes sleeping on channel chan.
// Caller should hold the condition lock.
void wakeup(void *chan) {
    800024be:	7139                	addi	sp,sp,-64
    800024c0:	fc06                	sd	ra,56(sp)
    800024c2:	f822                	sd	s0,48(sp)
    800024c4:	f426                	sd	s1,40(sp)
    800024c6:	f04a                	sd	s2,32(sp)
    800024c8:	ec4e                	sd	s3,24(sp)
    800024ca:	e852                	sd	s4,16(sp)
    800024cc:	e456                	sd	s5,8(sp)
    800024ce:	0080                	addi	s0,sp,64
    800024d0:	8a2a                	mv	s4,a0
  struct proc *p;

  for (p = proc; p < &proc[NPROC]; p++) {
    800024d2:	0000f497          	auipc	s1,0xf
    800024d6:	9fe48493          	addi	s1,s1,-1538 # 80010ed0 <proc>
    if (p != myproc()) {
      acquire(&p->lock);
      if (p->state == SLEEPING && p->chan == chan) {
    800024da:	4989                	li	s3,2
        p->state = RUNNABLE;
    800024dc:	4a8d                	li	s5,3
  for (p = proc; p < &proc[NPROC]; p++) {
    800024de:	00014917          	auipc	s2,0x14
    800024e2:	3f290913          	addi	s2,s2,1010 # 800168d0 <tickslock>
    800024e6:	a801                	j	800024f6 <wakeup+0x38>
      }
      release(&p->lock);
    800024e8:	8526                	mv	a0,s1
    800024ea:	8c1fe0ef          	jal	80000daa <release>
  for (p = proc; p < &proc[NPROC]; p++) {
    800024ee:	16848493          	addi	s1,s1,360
    800024f2:	03248263          	beq	s1,s2,80002516 <wakeup+0x58>
    if (p != myproc()) {
    800024f6:	f32ff0ef          	jal	80001c28 <myproc>
    800024fa:	fe950ae3          	beq	a0,s1,800024ee <wakeup+0x30>
      acquire(&p->lock);
    800024fe:	8526                	mv	a0,s1
    80002500:	817fe0ef          	jal	80000d16 <acquire>
      if (p->state == SLEEPING && p->chan == chan) {
    80002504:	4c9c                	lw	a5,24(s1)
    80002506:	ff3791e3          	bne	a5,s3,800024e8 <wakeup+0x2a>
    8000250a:	709c                	ld	a5,32(s1)
    8000250c:	fd479ee3          	bne	a5,s4,800024e8 <wakeup+0x2a>
        p->state = RUNNABLE;
    80002510:	0154ac23          	sw	s5,24(s1)
    80002514:	bfd1                	j	800024e8 <wakeup+0x2a>
    }
  }
}
    80002516:	70e2                	ld	ra,56(sp)
    80002518:	7442                	ld	s0,48(sp)
    8000251a:	74a2                	ld	s1,40(sp)
    8000251c:	7902                	ld	s2,32(sp)
    8000251e:	69e2                	ld	s3,24(sp)
    80002520:	6a42                	ld	s4,16(sp)
    80002522:	6aa2                	ld	s5,8(sp)
    80002524:	6121                	addi	sp,sp,64
    80002526:	8082                	ret

0000000080002528 <reparent>:
void reparent(struct proc *p) {
    80002528:	7179                	addi	sp,sp,-48
    8000252a:	f406                	sd	ra,40(sp)
    8000252c:	f022                	sd	s0,32(sp)
    8000252e:	ec26                	sd	s1,24(sp)
    80002530:	e84a                	sd	s2,16(sp)
    80002532:	e44e                	sd	s3,8(sp)
    80002534:	e052                	sd	s4,0(sp)
    80002536:	1800                	addi	s0,sp,48
    80002538:	892a                	mv	s2,a0
  for (pp = proc; pp < &proc[NPROC]; pp++) {
    8000253a:	0000f497          	auipc	s1,0xf
    8000253e:	99648493          	addi	s1,s1,-1642 # 80010ed0 <proc>
      pp->parent = initproc;
    80002542:	00006a17          	auipc	s4,0x6
    80002546:	3e6a0a13          	addi	s4,s4,998 # 80008928 <initproc>
  for (pp = proc; pp < &proc[NPROC]; pp++) {
    8000254a:	00014997          	auipc	s3,0x14
    8000254e:	38698993          	addi	s3,s3,902 # 800168d0 <tickslock>
    80002552:	a029                	j	8000255c <reparent+0x34>
    80002554:	16848493          	addi	s1,s1,360
    80002558:	01348b63          	beq	s1,s3,8000256e <reparent+0x46>
    if (pp->parent == p) {
    8000255c:	7c9c                	ld	a5,56(s1)
    8000255e:	ff279be3          	bne	a5,s2,80002554 <reparent+0x2c>
      pp->parent = initproc;
    80002562:	000a3503          	ld	a0,0(s4)
    80002566:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    80002568:	f57ff0ef          	jal	800024be <wakeup>
    8000256c:	b7e5                	j	80002554 <reparent+0x2c>
}
    8000256e:	70a2                	ld	ra,40(sp)
    80002570:	7402                	ld	s0,32(sp)
    80002572:	64e2                	ld	s1,24(sp)
    80002574:	6942                	ld	s2,16(sp)
    80002576:	69a2                	ld	s3,8(sp)
    80002578:	6a02                	ld	s4,0(sp)
    8000257a:	6145                	addi	sp,sp,48
    8000257c:	8082                	ret

000000008000257e <kexit>:
void kexit(int status) {
    8000257e:	7179                	addi	sp,sp,-48
    80002580:	f406                	sd	ra,40(sp)
    80002582:	f022                	sd	s0,32(sp)
    80002584:	ec26                	sd	s1,24(sp)
    80002586:	e84a                	sd	s2,16(sp)
    80002588:	e44e                	sd	s3,8(sp)
    8000258a:	e052                	sd	s4,0(sp)
    8000258c:	1800                	addi	s0,sp,48
    8000258e:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    80002590:	e98ff0ef          	jal	80001c28 <myproc>
    80002594:	89aa                	mv	s3,a0
  if (p == initproc)
    80002596:	00006797          	auipc	a5,0x6
    8000259a:	3927b783          	ld	a5,914(a5) # 80008928 <initproc>
    8000259e:	0d050493          	addi	s1,a0,208
    800025a2:	15050913          	addi	s2,a0,336
    800025a6:	00a79b63          	bne	a5,a0,800025bc <kexit+0x3e>
    panic("init exiting");
    800025aa:	00006517          	auipc	a0,0x6
    800025ae:	c9650513          	addi	a0,a0,-874 # 80008240 <etext+0x240>
    800025b2:	aa4fe0ef          	jal	80000856 <panic>
  for (int fd = 0; fd < NOFILE; fd++) {
    800025b6:	04a1                	addi	s1,s1,8
    800025b8:	01248963          	beq	s1,s2,800025ca <kexit+0x4c>
    if (p->ofile[fd]) {
    800025bc:	6088                	ld	a0,0(s1)
    800025be:	dd65                	beqz	a0,800025b6 <kexit+0x38>
      fileclose(f);
    800025c0:	08a020ef          	jal	8000464a <fileclose>
      p->ofile[fd] = 0;
    800025c4:	0004b023          	sd	zero,0(s1)
    800025c8:	b7fd                	j	800025b6 <kexit+0x38>
  begin_op();
    800025ca:	45d010ef          	jal	80004226 <begin_op>
  iput(p->cwd);
    800025ce:	1509b503          	ld	a0,336(s3)
    800025d2:	3ca010ef          	jal	8000399c <iput>
  end_op();
    800025d6:	4c1010ef          	jal	80004296 <end_op>
  p->cwd = 0;
    800025da:	1409b823          	sd	zero,336(s3)
  acquire(&wait_lock);
    800025de:	0000e517          	auipc	a0,0xe
    800025e2:	4c250513          	addi	a0,a0,1218 # 80010aa0 <wait_lock>
    800025e6:	f30fe0ef          	jal	80000d16 <acquire>
  reparent(p);
    800025ea:	854e                	mv	a0,s3
    800025ec:	f3dff0ef          	jal	80002528 <reparent>
  wakeup(p->parent);
    800025f0:	0389b503          	ld	a0,56(s3)
    800025f4:	ecbff0ef          	jal	800024be <wakeup>
  acquire(&p->lock);
    800025f8:	854e                	mv	a0,s3
    800025fa:	f1cfe0ef          	jal	80000d16 <acquire>
  p->xstate = status;
    800025fe:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    80002602:	4795                	li	a5,5
    80002604:	00f9ac23          	sw	a5,24(s3)
  release(&wait_lock);
    80002608:	0000e517          	auipc	a0,0xe
    8000260c:	49850513          	addi	a0,a0,1176 # 80010aa0 <wait_lock>
    80002610:	f9afe0ef          	jal	80000daa <release>
  sched();
    80002614:	d77ff0ef          	jal	8000238a <sched>
  panic("zombie exit");
    80002618:	00006517          	auipc	a0,0x6
    8000261c:	c3850513          	addi	a0,a0,-968 # 80008250 <etext+0x250>
    80002620:	a36fe0ef          	jal	80000856 <panic>

0000000080002624 <kkill>:

// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int kkill(int pid) {
    80002624:	7179                	addi	sp,sp,-48
    80002626:	f406                	sd	ra,40(sp)
    80002628:	f022                	sd	s0,32(sp)
    8000262a:	ec26                	sd	s1,24(sp)
    8000262c:	e84a                	sd	s2,16(sp)
    8000262e:	e44e                	sd	s3,8(sp)
    80002630:	1800                	addi	s0,sp,48
    80002632:	892a                	mv	s2,a0
  struct proc *p;

  for (p = proc; p < &proc[NPROC]; p++) {
    80002634:	0000f497          	auipc	s1,0xf
    80002638:	89c48493          	addi	s1,s1,-1892 # 80010ed0 <proc>
    8000263c:	00014997          	auipc	s3,0x14
    80002640:	29498993          	addi	s3,s3,660 # 800168d0 <tickslock>
    acquire(&p->lock);
    80002644:	8526                	mv	a0,s1
    80002646:	ed0fe0ef          	jal	80000d16 <acquire>
    if (p->pid == pid) {
    8000264a:	589c                	lw	a5,48(s1)
    8000264c:	01278b63          	beq	a5,s2,80002662 <kkill+0x3e>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    80002650:	8526                	mv	a0,s1
    80002652:	f58fe0ef          	jal	80000daa <release>
  for (p = proc; p < &proc[NPROC]; p++) {
    80002656:	16848493          	addi	s1,s1,360
    8000265a:	ff3495e3          	bne	s1,s3,80002644 <kkill+0x20>
  }
  return -1;
    8000265e:	557d                	li	a0,-1
    80002660:	a819                	j	80002676 <kkill+0x52>
      p->killed = 1;
    80002662:	4785                	li	a5,1
    80002664:	d49c                	sw	a5,40(s1)
      if (p->state == SLEEPING) {
    80002666:	4c98                	lw	a4,24(s1)
    80002668:	4789                	li	a5,2
    8000266a:	00f70d63          	beq	a4,a5,80002684 <kkill+0x60>
      release(&p->lock);
    8000266e:	8526                	mv	a0,s1
    80002670:	f3afe0ef          	jal	80000daa <release>
      return 0;
    80002674:	4501                	li	a0,0
}
    80002676:	70a2                	ld	ra,40(sp)
    80002678:	7402                	ld	s0,32(sp)
    8000267a:	64e2                	ld	s1,24(sp)
    8000267c:	6942                	ld	s2,16(sp)
    8000267e:	69a2                	ld	s3,8(sp)
    80002680:	6145                	addi	sp,sp,48
    80002682:	8082                	ret
        p->state = RUNNABLE;
    80002684:	478d                	li	a5,3
    80002686:	cc9c                	sw	a5,24(s1)
    80002688:	b7dd                	j	8000266e <kkill+0x4a>

000000008000268a <setkilled>:

void setkilled(struct proc *p) {
    8000268a:	1101                	addi	sp,sp,-32
    8000268c:	ec06                	sd	ra,24(sp)
    8000268e:	e822                	sd	s0,16(sp)
    80002690:	e426                	sd	s1,8(sp)
    80002692:	1000                	addi	s0,sp,32
    80002694:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80002696:	e80fe0ef          	jal	80000d16 <acquire>
  p->killed = 1;
    8000269a:	4785                	li	a5,1
    8000269c:	d49c                	sw	a5,40(s1)
  release(&p->lock);
    8000269e:	8526                	mv	a0,s1
    800026a0:	f0afe0ef          	jal	80000daa <release>
}
    800026a4:	60e2                	ld	ra,24(sp)
    800026a6:	6442                	ld	s0,16(sp)
    800026a8:	64a2                	ld	s1,8(sp)
    800026aa:	6105                	addi	sp,sp,32
    800026ac:	8082                	ret

00000000800026ae <killed>:

int killed(struct proc *p) {
    800026ae:	1101                	addi	sp,sp,-32
    800026b0:	ec06                	sd	ra,24(sp)
    800026b2:	e822                	sd	s0,16(sp)
    800026b4:	e426                	sd	s1,8(sp)
    800026b6:	e04a                	sd	s2,0(sp)
    800026b8:	1000                	addi	s0,sp,32
    800026ba:	84aa                	mv	s1,a0
  int k;

  acquire(&p->lock);
    800026bc:	e5afe0ef          	jal	80000d16 <acquire>
  k = p->killed;
    800026c0:	549c                	lw	a5,40(s1)
    800026c2:	893e                	mv	s2,a5
  release(&p->lock);
    800026c4:	8526                	mv	a0,s1
    800026c6:	ee4fe0ef          	jal	80000daa <release>
  return k;
}
    800026ca:	854a                	mv	a0,s2
    800026cc:	60e2                	ld	ra,24(sp)
    800026ce:	6442                	ld	s0,16(sp)
    800026d0:	64a2                	ld	s1,8(sp)
    800026d2:	6902                	ld	s2,0(sp)
    800026d4:	6105                	addi	sp,sp,32
    800026d6:	8082                	ret

00000000800026d8 <kwait>:
int kwait(uint64 addr) {
    800026d8:	715d                	addi	sp,sp,-80
    800026da:	e486                	sd	ra,72(sp)
    800026dc:	e0a2                	sd	s0,64(sp)
    800026de:	fc26                	sd	s1,56(sp)
    800026e0:	f84a                	sd	s2,48(sp)
    800026e2:	f44e                	sd	s3,40(sp)
    800026e4:	f052                	sd	s4,32(sp)
    800026e6:	ec56                	sd	s5,24(sp)
    800026e8:	e85a                	sd	s6,16(sp)
    800026ea:	e45e                	sd	s7,8(sp)
    800026ec:	0880                	addi	s0,sp,80
    800026ee:	8baa                	mv	s7,a0
  struct proc *p = myproc();
    800026f0:	d38ff0ef          	jal	80001c28 <myproc>
    800026f4:	892a                	mv	s2,a0
  acquire(&wait_lock);
    800026f6:	0000e517          	auipc	a0,0xe
    800026fa:	3aa50513          	addi	a0,a0,938 # 80010aa0 <wait_lock>
    800026fe:	e18fe0ef          	jal	80000d16 <acquire>
        if (pp->state == ZOMBIE) {
    80002702:	4a15                	li	s4,5
        havekids = 1;
    80002704:	4a85                	li	s5,1
    for (pp = proc; pp < &proc[NPROC]; pp++) {
    80002706:	00014997          	auipc	s3,0x14
    8000270a:	1ca98993          	addi	s3,s3,458 # 800168d0 <tickslock>
    sleep(p, &wait_lock); // DOC: wait-sleep
    8000270e:	0000eb17          	auipc	s6,0xe
    80002712:	392b0b13          	addi	s6,s6,914 # 80010aa0 <wait_lock>
    80002716:	a869                	j	800027b0 <kwait+0xd8>
          pid = pp->pid;
    80002718:	0304a983          	lw	s3,48(s1)
          if (addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    8000271c:	000b8c63          	beqz	s7,80002734 <kwait+0x5c>
    80002720:	4691                	li	a3,4
    80002722:	02c48613          	addi	a2,s1,44
    80002726:	85de                	mv	a1,s7
    80002728:	05093503          	ld	a0,80(s2)
    8000272c:	a0eff0ef          	jal	8000193a <copyout>
    80002730:	02054a63          	bltz	a0,80002764 <kwait+0x8c>
          freeproc(pp);
    80002734:	8526                	mv	a0,s1
    80002736:	ec6ff0ef          	jal	80001dfc <freeproc>
          release(&pp->lock);
    8000273a:	8526                	mv	a0,s1
    8000273c:	e6efe0ef          	jal	80000daa <release>
          release(&wait_lock);
    80002740:	0000e517          	auipc	a0,0xe
    80002744:	36050513          	addi	a0,a0,864 # 80010aa0 <wait_lock>
    80002748:	e62fe0ef          	jal	80000daa <release>
}
    8000274c:	854e                	mv	a0,s3
    8000274e:	60a6                	ld	ra,72(sp)
    80002750:	6406                	ld	s0,64(sp)
    80002752:	74e2                	ld	s1,56(sp)
    80002754:	7942                	ld	s2,48(sp)
    80002756:	79a2                	ld	s3,40(sp)
    80002758:	7a02                	ld	s4,32(sp)
    8000275a:	6ae2                	ld	s5,24(sp)
    8000275c:	6b42                	ld	s6,16(sp)
    8000275e:	6ba2                	ld	s7,8(sp)
    80002760:	6161                	addi	sp,sp,80
    80002762:	8082                	ret
            release(&pp->lock);
    80002764:	8526                	mv	a0,s1
    80002766:	e44fe0ef          	jal	80000daa <release>
            release(&wait_lock);
    8000276a:	0000e517          	auipc	a0,0xe
    8000276e:	33650513          	addi	a0,a0,822 # 80010aa0 <wait_lock>
    80002772:	e38fe0ef          	jal	80000daa <release>
            return -1;
    80002776:	59fd                	li	s3,-1
    80002778:	bfd1                	j	8000274c <kwait+0x74>
    for (pp = proc; pp < &proc[NPROC]; pp++) {
    8000277a:	16848493          	addi	s1,s1,360
    8000277e:	03348063          	beq	s1,s3,8000279e <kwait+0xc6>
      if (pp->parent == p) {
    80002782:	7c9c                	ld	a5,56(s1)
    80002784:	ff279be3          	bne	a5,s2,8000277a <kwait+0xa2>
        acquire(&pp->lock);
    80002788:	8526                	mv	a0,s1
    8000278a:	d8cfe0ef          	jal	80000d16 <acquire>
        if (pp->state == ZOMBIE) {
    8000278e:	4c9c                	lw	a5,24(s1)
    80002790:	f94784e3          	beq	a5,s4,80002718 <kwait+0x40>
        release(&pp->lock);
    80002794:	8526                	mv	a0,s1
    80002796:	e14fe0ef          	jal	80000daa <release>
        havekids = 1;
    8000279a:	8756                	mv	a4,s5
    8000279c:	bff9                	j	8000277a <kwait+0xa2>
    if (!havekids || killed(p)) {
    8000279e:	cf19                	beqz	a4,800027bc <kwait+0xe4>
    800027a0:	854a                	mv	a0,s2
    800027a2:	f0dff0ef          	jal	800026ae <killed>
    800027a6:	e919                	bnez	a0,800027bc <kwait+0xe4>
    sleep(p, &wait_lock); // DOC: wait-sleep
    800027a8:	85da                	mv	a1,s6
    800027aa:	854a                	mv	a0,s2
    800027ac:	cc7ff0ef          	jal	80002472 <sleep>
    havekids = 0;
    800027b0:	4701                	li	a4,0
    for (pp = proc; pp < &proc[NPROC]; pp++) {
    800027b2:	0000e497          	auipc	s1,0xe
    800027b6:	71e48493          	addi	s1,s1,1822 # 80010ed0 <proc>
    800027ba:	b7e1                	j	80002782 <kwait+0xaa>
      release(&wait_lock);
    800027bc:	0000e517          	auipc	a0,0xe
    800027c0:	2e450513          	addi	a0,a0,740 # 80010aa0 <wait_lock>
    800027c4:	de6fe0ef          	jal	80000daa <release>
      return -1;
    800027c8:	59fd                	li	s3,-1
    800027ca:	b749                	j	8000274c <kwait+0x74>

00000000800027cc <either_copyout>:

// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int either_copyout(int user_dst, uint64 dst, void *src, uint64 len) {
    800027cc:	7179                	addi	sp,sp,-48
    800027ce:	f406                	sd	ra,40(sp)
    800027d0:	f022                	sd	s0,32(sp)
    800027d2:	ec26                	sd	s1,24(sp)
    800027d4:	e84a                	sd	s2,16(sp)
    800027d6:	e44e                	sd	s3,8(sp)
    800027d8:	e052                	sd	s4,0(sp)
    800027da:	1800                	addi	s0,sp,48
    800027dc:	84aa                	mv	s1,a0
    800027de:	8a2e                	mv	s4,a1
    800027e0:	89b2                	mv	s3,a2
    800027e2:	8936                	mv	s2,a3
  struct proc *p = myproc();
    800027e4:	c44ff0ef          	jal	80001c28 <myproc>
  if (user_dst) {
    800027e8:	cc99                	beqz	s1,80002806 <either_copyout+0x3a>
    return copyout(p->pagetable, dst, src, len);
    800027ea:	86ca                	mv	a3,s2
    800027ec:	864e                	mv	a2,s3
    800027ee:	85d2                	mv	a1,s4
    800027f0:	6928                	ld	a0,80(a0)
    800027f2:	948ff0ef          	jal	8000193a <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    800027f6:	70a2                	ld	ra,40(sp)
    800027f8:	7402                	ld	s0,32(sp)
    800027fa:	64e2                	ld	s1,24(sp)
    800027fc:	6942                	ld	s2,16(sp)
    800027fe:	69a2                	ld	s3,8(sp)
    80002800:	6a02                	ld	s4,0(sp)
    80002802:	6145                	addi	sp,sp,48
    80002804:	8082                	ret
    memmove((char *)dst, src, len);
    80002806:	0009061b          	sext.w	a2,s2
    8000280a:	85ce                	mv	a1,s3
    8000280c:	8552                	mv	a0,s4
    8000280e:	e38fe0ef          	jal	80000e46 <memmove>
    return 0;
    80002812:	8526                	mv	a0,s1
    80002814:	b7cd                	j	800027f6 <either_copyout+0x2a>

0000000080002816 <either_copyin>:

// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int either_copyin(void *dst, int user_src, uint64 src, uint64 len) {
    80002816:	7179                	addi	sp,sp,-48
    80002818:	f406                	sd	ra,40(sp)
    8000281a:	f022                	sd	s0,32(sp)
    8000281c:	ec26                	sd	s1,24(sp)
    8000281e:	e84a                	sd	s2,16(sp)
    80002820:	e44e                	sd	s3,8(sp)
    80002822:	e052                	sd	s4,0(sp)
    80002824:	1800                	addi	s0,sp,48
    80002826:	8a2a                	mv	s4,a0
    80002828:	84ae                	mv	s1,a1
    8000282a:	89b2                	mv	s3,a2
    8000282c:	8936                	mv	s2,a3
  struct proc *p = myproc();
    8000282e:	bfaff0ef          	jal	80001c28 <myproc>
  if (user_src) {
    80002832:	cc99                	beqz	s1,80002850 <either_copyin+0x3a>
    return copyin(p->pagetable, dst, src, len);
    80002834:	86ca                	mv	a3,s2
    80002836:	864e                	mv	a2,s3
    80002838:	85d2                	mv	a1,s4
    8000283a:	6928                	ld	a0,80(a0)
    8000283c:	9bcff0ef          	jal	800019f8 <copyin>
  } else {
    memmove(dst, (char *)src, len);
    return 0;
  }
}
    80002840:	70a2                	ld	ra,40(sp)
    80002842:	7402                	ld	s0,32(sp)
    80002844:	64e2                	ld	s1,24(sp)
    80002846:	6942                	ld	s2,16(sp)
    80002848:	69a2                	ld	s3,8(sp)
    8000284a:	6a02                	ld	s4,0(sp)
    8000284c:	6145                	addi	sp,sp,48
    8000284e:	8082                	ret
    memmove(dst, (char *)src, len);
    80002850:	0009061b          	sext.w	a2,s2
    80002854:	85ce                	mv	a1,s3
    80002856:	8552                	mv	a0,s4
    80002858:	deefe0ef          	jal	80000e46 <memmove>
    return 0;
    8000285c:	8526                	mv	a0,s1
    8000285e:	b7cd                	j	80002840 <either_copyin+0x2a>

0000000080002860 <procdump>:

// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void procdump(void) {
    80002860:	715d                	addi	sp,sp,-80
    80002862:	e486                	sd	ra,72(sp)
    80002864:	e0a2                	sd	s0,64(sp)
    80002866:	fc26                	sd	s1,56(sp)
    80002868:	f84a                	sd	s2,48(sp)
    8000286a:	f44e                	sd	s3,40(sp)
    8000286c:	f052                	sd	s4,32(sp)
    8000286e:	ec56                	sd	s5,24(sp)
    80002870:	e85a                	sd	s6,16(sp)
    80002872:	e45e                	sd	s7,8(sp)
    80002874:	0880                	addi	s0,sp,80
      [UNUSED] "unused",   [USED] "used",      [SLEEPING] "sleep ",
      [RUNNABLE] "runble", [RUNNING] "run   ", [ZOMBIE] "zombie"};
  struct proc *p;
  char *state;

  printf("\n");
    80002876:	00006517          	auipc	a0,0x6
    8000287a:	80a50513          	addi	a0,a0,-2038 # 80008080 <etext+0x80>
    8000287e:	caffd0ef          	jal	8000052c <printf>
  for (p = proc; p < &proc[NPROC]; p++) {
    80002882:	0000e497          	auipc	s1,0xe
    80002886:	7a648493          	addi	s1,s1,1958 # 80011028 <proc+0x158>
    8000288a:	00014917          	auipc	s2,0x14
    8000288e:	19e90913          	addi	s2,s2,414 # 80016a28 <bcache+0x140>
    if (p->state == UNUSED)
      continue;
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002892:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    80002894:	00006997          	auipc	s3,0x6
    80002898:	9cc98993          	addi	s3,s3,-1588 # 80008260 <etext+0x260>
    printf("%d %s %s", p->pid, state, p->name);
    8000289c:	00006a97          	auipc	s5,0x6
    800028a0:	9cca8a93          	addi	s5,s5,-1588 # 80008268 <etext+0x268>
    printf("\n");
    800028a4:	00005a17          	auipc	s4,0x5
    800028a8:	7dca0a13          	addi	s4,s4,2012 # 80008080 <etext+0x80>
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800028ac:	00006b97          	auipc	s7,0x6
    800028b0:	f24b8b93          	addi	s7,s7,-220 # 800087d0 <states.0>
    800028b4:	a829                	j	800028ce <procdump+0x6e>
    printf("%d %s %s", p->pid, state, p->name);
    800028b6:	ed86a583          	lw	a1,-296(a3)
    800028ba:	8556                	mv	a0,s5
    800028bc:	c71fd0ef          	jal	8000052c <printf>
    printf("\n");
    800028c0:	8552                	mv	a0,s4
    800028c2:	c6bfd0ef          	jal	8000052c <printf>
  for (p = proc; p < &proc[NPROC]; p++) {
    800028c6:	16848493          	addi	s1,s1,360
    800028ca:	03248263          	beq	s1,s2,800028ee <procdump+0x8e>
    if (p->state == UNUSED)
    800028ce:	86a6                	mv	a3,s1
    800028d0:	ec04a783          	lw	a5,-320(s1)
    800028d4:	dbed                	beqz	a5,800028c6 <procdump+0x66>
      state = "???";
    800028d6:	864e                	mv	a2,s3
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800028d8:	fcfb6fe3          	bltu	s6,a5,800028b6 <procdump+0x56>
    800028dc:	02079713          	slli	a4,a5,0x20
    800028e0:	01d75793          	srli	a5,a4,0x1d
    800028e4:	97de                	add	a5,a5,s7
    800028e6:	6390                	ld	a2,0(a5)
    800028e8:	f679                	bnez	a2,800028b6 <procdump+0x56>
      state = "???";
    800028ea:	864e                	mv	a2,s3
    800028ec:	b7e9                	j	800028b6 <procdump+0x56>
  }
}
    800028ee:	60a6                	ld	ra,72(sp)
    800028f0:	6406                	ld	s0,64(sp)
    800028f2:	74e2                	ld	s1,56(sp)
    800028f4:	7942                	ld	s2,48(sp)
    800028f6:	79a2                	ld	s3,40(sp)
    800028f8:	7a02                	ld	s4,32(sp)
    800028fa:	6ae2                	ld	s5,24(sp)
    800028fc:	6b42                	ld	s6,16(sp)
    800028fe:	6ba2                	ld	s7,8(sp)
    80002900:	6161                	addi	sp,sp,80
    80002902:	8082                	ret

0000000080002904 <swtch>:
# Save current registers in old. Load from new.	


.globl swtch
swtch:
        sd ra, 0(a0)
    80002904:	00153023          	sd	ra,0(a0)
        sd sp, 8(a0)
    80002908:	00253423          	sd	sp,8(a0)
        sd s0, 16(a0)
    8000290c:	e900                	sd	s0,16(a0)
        sd s1, 24(a0)
    8000290e:	ed04                	sd	s1,24(a0)
        sd s2, 32(a0)
    80002910:	03253023          	sd	s2,32(a0)
        sd s3, 40(a0)
    80002914:	03353423          	sd	s3,40(a0)
        sd s4, 48(a0)
    80002918:	03453823          	sd	s4,48(a0)
        sd s5, 56(a0)
    8000291c:	03553c23          	sd	s5,56(a0)
        sd s6, 64(a0)
    80002920:	05653023          	sd	s6,64(a0)
        sd s7, 72(a0)
    80002924:	05753423          	sd	s7,72(a0)
        sd s8, 80(a0)
    80002928:	05853823          	sd	s8,80(a0)
        sd s9, 88(a0)
    8000292c:	05953c23          	sd	s9,88(a0)
        sd s10, 96(a0)
    80002930:	07a53023          	sd	s10,96(a0)
        sd s11, 104(a0)
    80002934:	07b53423          	sd	s11,104(a0)

        ld ra, 0(a1)
    80002938:	0005b083          	ld	ra,0(a1)
        ld sp, 8(a1)
    8000293c:	0085b103          	ld	sp,8(a1)
        ld s0, 16(a1)
    80002940:	6980                	ld	s0,16(a1)
        ld s1, 24(a1)
    80002942:	6d84                	ld	s1,24(a1)
        ld s2, 32(a1)
    80002944:	0205b903          	ld	s2,32(a1)
        ld s3, 40(a1)
    80002948:	0285b983          	ld	s3,40(a1)
        ld s4, 48(a1)
    8000294c:	0305ba03          	ld	s4,48(a1)
        ld s5, 56(a1)
    80002950:	0385ba83          	ld	s5,56(a1)
        ld s6, 64(a1)
    80002954:	0405bb03          	ld	s6,64(a1)
        ld s7, 72(a1)
    80002958:	0485bb83          	ld	s7,72(a1)
        ld s8, 80(a1)
    8000295c:	0505bc03          	ld	s8,80(a1)
        ld s9, 88(a1)
    80002960:	0585bc83          	ld	s9,88(a1)
        ld s10, 96(a1)
    80002964:	0605bd03          	ld	s10,96(a1)
        ld s11, 104(a1)
    80002968:	0685bd83          	ld	s11,104(a1)
        
        ret
    8000296c:	8082                	ret

000000008000296e <trapinit>:

extern int devintr();

void
trapinit(void)
{
    8000296e:	1141                	addi	sp,sp,-16
    80002970:	e406                	sd	ra,8(sp)
    80002972:	e022                	sd	s0,0(sp)
    80002974:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    80002976:	00006597          	auipc	a1,0x6
    8000297a:	93258593          	addi	a1,a1,-1742 # 800082a8 <etext+0x2a8>
    8000297e:	00014517          	auipc	a0,0x14
    80002982:	f5250513          	addi	a0,a0,-174 # 800168d0 <tickslock>
    80002986:	b06fe0ef          	jal	80000c8c <initlock>
}
    8000298a:	60a2                	ld	ra,8(sp)
    8000298c:	6402                	ld	s0,0(sp)
    8000298e:	0141                	addi	sp,sp,16
    80002990:	8082                	ret

0000000080002992 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    80002992:	1141                	addi	sp,sp,-16
    80002994:	e406                	sd	ra,8(sp)
    80002996:	e022                	sd	s0,0(sp)
    80002998:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    8000299a:	00003797          	auipc	a5,0x3
    8000299e:	0a678793          	addi	a5,a5,166 # 80005a40 <kernelvec>
    800029a2:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    800029a6:	60a2                	ld	ra,8(sp)
    800029a8:	6402                	ld	s0,0(sp)
    800029aa:	0141                	addi	sp,sp,16
    800029ac:	8082                	ret

00000000800029ae <prepare_return>:
//
// set up trapframe and control registers for a return to user space
//
void
prepare_return(void)
{
    800029ae:	1141                	addi	sp,sp,-16
    800029b0:	e406                	sd	ra,8(sp)
    800029b2:	e022                	sd	s0,0(sp)
    800029b4:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    800029b6:	a72ff0ef          	jal	80001c28 <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800029ba:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    800029be:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800029c0:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(). because a trap from kernel
  // code to usertrap would be a disaster, turn off interrupts.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    800029c4:	04000737          	lui	a4,0x4000
    800029c8:	177d                	addi	a4,a4,-1 # 3ffffff <_entry-0x7c000001>
    800029ca:	0732                	slli	a4,a4,0xc
    800029cc:	00004797          	auipc	a5,0x4
    800029d0:	63478793          	addi	a5,a5,1588 # 80007000 <_trampoline>
    800029d4:	00004697          	auipc	a3,0x4
    800029d8:	62c68693          	addi	a3,a3,1580 # 80007000 <_trampoline>
    800029dc:	8f95                	sub	a5,a5,a3
    800029de:	97ba                	add	a5,a5,a4
  asm volatile("csrw stvec, %0" : : "r" (x));
    800029e0:	10579073          	csrw	stvec,a5
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    800029e4:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    800029e6:	18002773          	csrr	a4,satp
    800029ea:	e398                	sd	a4,0(a5)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    800029ec:	6d38                	ld	a4,88(a0)
    800029ee:	613c                	ld	a5,64(a0)
    800029f0:	6685                	lui	a3,0x1
    800029f2:	97b6                	add	a5,a5,a3
    800029f4:	e71c                	sd	a5,8(a4)
  p->trapframe->kernel_trap = (uint64)usertrap;
    800029f6:	6d3c                	ld	a5,88(a0)
    800029f8:	00000717          	auipc	a4,0x0
    800029fc:	0fc70713          	addi	a4,a4,252 # 80002af4 <usertrap>
    80002a00:	eb98                	sd	a4,16(a5)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    80002a02:	6d3c                	ld	a5,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    80002a04:	8712                	mv	a4,tp
    80002a06:	f398                	sd	a4,32(a5)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002a08:	100027f3          	csrr	a5,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    80002a0c:	eff7f793          	andi	a5,a5,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    80002a10:	0207e793          	ori	a5,a5,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002a14:	10079073          	csrw	sstatus,a5
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    80002a18:	6d3c                	ld	a5,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002a1a:	6f9c                	ld	a5,24(a5)
    80002a1c:	14179073          	csrw	sepc,a5
}
    80002a20:	60a2                	ld	ra,8(sp)
    80002a22:	6402                	ld	s0,0(sp)
    80002a24:	0141                	addi	sp,sp,16
    80002a26:	8082                	ret

0000000080002a28 <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    80002a28:	1141                	addi	sp,sp,-16
    80002a2a:	e406                	sd	ra,8(sp)
    80002a2c:	e022                	sd	s0,0(sp)
    80002a2e:	0800                	addi	s0,sp,16
  if(cpuid() == 0){
    80002a30:	9c4ff0ef          	jal	80001bf4 <cpuid>
    80002a34:	cd11                	beqz	a0,80002a50 <clockintr+0x28>
  asm volatile("csrr %0, time" : "=r" (x) );
    80002a36:	c01027f3          	rdtime	a5
  }

  // ask for the next timer interrupt. this also clears
  // the interrupt request. 1000000 is about a tenth
  // of a second.
  w_stimecmp(r_time() + 1000000);
    80002a3a:	000f4737          	lui	a4,0xf4
    80002a3e:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    80002a42:	97ba                	add	a5,a5,a4
  asm volatile("csrw 0x14d, %0" : : "r" (x));
    80002a44:	14d79073          	csrw	stimecmp,a5
}
    80002a48:	60a2                	ld	ra,8(sp)
    80002a4a:	6402                	ld	s0,0(sp)
    80002a4c:	0141                	addi	sp,sp,16
    80002a4e:	8082                	ret
    acquire(&tickslock);
    80002a50:	00014517          	auipc	a0,0x14
    80002a54:	e8050513          	addi	a0,a0,-384 # 800168d0 <tickslock>
    80002a58:	abefe0ef          	jal	80000d16 <acquire>
    ticks++;
    80002a5c:	00006717          	auipc	a4,0x6
    80002a60:	ed470713          	addi	a4,a4,-300 # 80008930 <ticks>
    80002a64:	431c                	lw	a5,0(a4)
    80002a66:	2785                	addiw	a5,a5,1
    80002a68:	c31c                	sw	a5,0(a4)
    wakeup(&ticks);
    80002a6a:	853a                	mv	a0,a4
    80002a6c:	a53ff0ef          	jal	800024be <wakeup>
    release(&tickslock);
    80002a70:	00014517          	auipc	a0,0x14
    80002a74:	e6050513          	addi	a0,a0,-416 # 800168d0 <tickslock>
    80002a78:	b32fe0ef          	jal	80000daa <release>
    80002a7c:	bf6d                	j	80002a36 <clockintr+0xe>

0000000080002a7e <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    80002a7e:	1101                	addi	sp,sp,-32
    80002a80:	ec06                	sd	ra,24(sp)
    80002a82:	e822                	sd	s0,16(sp)
    80002a84:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002a86:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if(scause == 0x8000000000000009L){
    80002a8a:	57fd                	li	a5,-1
    80002a8c:	17fe                	slli	a5,a5,0x3f
    80002a8e:	07a5                	addi	a5,a5,9
    80002a90:	00f70c63          	beq	a4,a5,80002aa8 <devintr+0x2a>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000005L){
    80002a94:	57fd                	li	a5,-1
    80002a96:	17fe                	slli	a5,a5,0x3f
    80002a98:	0795                	addi	a5,a5,5
    // timer interrupt.
    clockintr();
    return 2;
  } else {
    return 0;
    80002a9a:	4501                	li	a0,0
  } else if(scause == 0x8000000000000005L){
    80002a9c:	04f70863          	beq	a4,a5,80002aec <devintr+0x6e>
  }
}
    80002aa0:	60e2                	ld	ra,24(sp)
    80002aa2:	6442                	ld	s0,16(sp)
    80002aa4:	6105                	addi	sp,sp,32
    80002aa6:	8082                	ret
    80002aa8:	e426                	sd	s1,8(sp)
    int irq = plic_claim();
    80002aaa:	042030ef          	jal	80005aec <plic_claim>
    80002aae:	872a                	mv	a4,a0
    80002ab0:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    80002ab2:	47a9                	li	a5,10
    80002ab4:	00f50963          	beq	a0,a5,80002ac6 <devintr+0x48>
    } else if(irq == VIRTIO0_IRQ){
    80002ab8:	4785                	li	a5,1
    80002aba:	00f50963          	beq	a0,a5,80002acc <devintr+0x4e>
    return 1;
    80002abe:	4505                	li	a0,1
    } else if(irq){
    80002ac0:	eb09                	bnez	a4,80002ad2 <devintr+0x54>
    80002ac2:	64a2                	ld	s1,8(sp)
    80002ac4:	bff1                	j	80002aa0 <devintr+0x22>
      uartintr();
    80002ac6:	f61fd0ef          	jal	80000a26 <uartintr>
    if(irq)
    80002aca:	a819                	j	80002ae0 <devintr+0x62>
      virtio_disk_intr();
    80002acc:	4b6030ef          	jal	80005f82 <virtio_disk_intr>
    if(irq)
    80002ad0:	a801                	j	80002ae0 <devintr+0x62>
      printf("unexpected interrupt irq=%d\n", irq);
    80002ad2:	85ba                	mv	a1,a4
    80002ad4:	00005517          	auipc	a0,0x5
    80002ad8:	7dc50513          	addi	a0,a0,2012 # 800082b0 <etext+0x2b0>
    80002adc:	a51fd0ef          	jal	8000052c <printf>
      plic_complete(irq);
    80002ae0:	8526                	mv	a0,s1
    80002ae2:	02a030ef          	jal	80005b0c <plic_complete>
    return 1;
    80002ae6:	4505                	li	a0,1
    80002ae8:	64a2                	ld	s1,8(sp)
    80002aea:	bf5d                	j	80002aa0 <devintr+0x22>
    clockintr();
    80002aec:	f3dff0ef          	jal	80002a28 <clockintr>
    return 2;
    80002af0:	4509                	li	a0,2
    80002af2:	b77d                	j	80002aa0 <devintr+0x22>

0000000080002af4 <usertrap>:
{
    80002af4:	1101                	addi	sp,sp,-32
    80002af6:	ec06                	sd	ra,24(sp)
    80002af8:	e822                	sd	s0,16(sp)
    80002afa:	e426                	sd	s1,8(sp)
    80002afc:	e04a                	sd	s2,0(sp)
    80002afe:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002b00:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    80002b04:	1007f793          	andi	a5,a5,256
    80002b08:	eba5                	bnez	a5,80002b78 <usertrap+0x84>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002b0a:	00003797          	auipc	a5,0x3
    80002b0e:	f3678793          	addi	a5,a5,-202 # 80005a40 <kernelvec>
    80002b12:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80002b16:	912ff0ef          	jal	80001c28 <myproc>
    80002b1a:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    80002b1c:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002b1e:	14102773          	csrr	a4,sepc
    80002b22:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002b24:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    80002b28:	47a1                	li	a5,8
    80002b2a:	04f70d63          	beq	a4,a5,80002b84 <usertrap+0x90>
  } else if((which_dev = devintr()) != 0){
    80002b2e:	f51ff0ef          	jal	80002a7e <devintr>
    80002b32:	892a                	mv	s2,a0
    80002b34:	e945                	bnez	a0,80002be4 <usertrap+0xf0>
    80002b36:	14202773          	csrr	a4,scause
  } else if((r_scause() == 15 || r_scause() == 13) &&
    80002b3a:	47bd                	li	a5,15
    80002b3c:	08f70863          	beq	a4,a5,80002bcc <usertrap+0xd8>
    80002b40:	14202773          	csrr	a4,scause
    80002b44:	47b5                	li	a5,13
    80002b46:	08f70363          	beq	a4,a5,80002bcc <usertrap+0xd8>
    80002b4a:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause 0x%lx pid=%d\n", r_scause(), p->pid);
    80002b4e:	5890                	lw	a2,48(s1)
    80002b50:	00005517          	auipc	a0,0x5
    80002b54:	7a050513          	addi	a0,a0,1952 # 800082f0 <etext+0x2f0>
    80002b58:	9d5fd0ef          	jal	8000052c <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002b5c:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002b60:	14302673          	csrr	a2,stval
    printf("            sepc=0x%lx stval=0x%lx\n", r_sepc(), r_stval());
    80002b64:	00005517          	auipc	a0,0x5
    80002b68:	7bc50513          	addi	a0,a0,1980 # 80008320 <etext+0x320>
    80002b6c:	9c1fd0ef          	jal	8000052c <printf>
    setkilled(p);
    80002b70:	8526                	mv	a0,s1
    80002b72:	b19ff0ef          	jal	8000268a <setkilled>
    80002b76:	a035                	j	80002ba2 <usertrap+0xae>
    panic("usertrap: not from user mode");
    80002b78:	00005517          	auipc	a0,0x5
    80002b7c:	75850513          	addi	a0,a0,1880 # 800082d0 <etext+0x2d0>
    80002b80:	cd7fd0ef          	jal	80000856 <panic>
    if(killed(p))
    80002b84:	b2bff0ef          	jal	800026ae <killed>
    80002b88:	ed15                	bnez	a0,80002bc4 <usertrap+0xd0>
    p->trapframe->epc += 4;
    80002b8a:	6cb8                	ld	a4,88(s1)
    80002b8c:	6f1c                	ld	a5,24(a4)
    80002b8e:	0791                	addi	a5,a5,4
    80002b90:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002b92:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002b96:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002b9a:	10079073          	csrw	sstatus,a5
    syscall();
    80002b9e:	240000ef          	jal	80002dde <syscall>
  if(killed(p))
    80002ba2:	8526                	mv	a0,s1
    80002ba4:	b0bff0ef          	jal	800026ae <killed>
    80002ba8:	e139                	bnez	a0,80002bee <usertrap+0xfa>
  prepare_return();
    80002baa:	e05ff0ef          	jal	800029ae <prepare_return>
  uint64 satp = MAKE_SATP(p->pagetable);
    80002bae:	68a8                	ld	a0,80(s1)
    80002bb0:	8131                	srli	a0,a0,0xc
    80002bb2:	57fd                	li	a5,-1
    80002bb4:	17fe                	slli	a5,a5,0x3f
    80002bb6:	8d5d                	or	a0,a0,a5
}
    80002bb8:	60e2                	ld	ra,24(sp)
    80002bba:	6442                	ld	s0,16(sp)
    80002bbc:	64a2                	ld	s1,8(sp)
    80002bbe:	6902                	ld	s2,0(sp)
    80002bc0:	6105                	addi	sp,sp,32
    80002bc2:	8082                	ret
      kexit(-1);
    80002bc4:	557d                	li	a0,-1
    80002bc6:	9b9ff0ef          	jal	8000257e <kexit>
    80002bca:	b7c1                	j	80002b8a <usertrap+0x96>
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002bcc:	143025f3          	csrr	a1,stval
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002bd0:	14202673          	csrr	a2,scause
            vmfault(p->pagetable, r_stval(), (r_scause() == 13)? 1 : 0) != 0) {
    80002bd4:	164d                	addi	a2,a2,-13 # ff3 <_entry-0x7ffff00d>
    80002bd6:	00163613          	seqz	a2,a2
    80002bda:	68a8                	ld	a0,80(s1)
    80002bdc:	c87fe0ef          	jal	80001862 <vmfault>
  } else if((r_scause() == 15 || r_scause() == 13) &&
    80002be0:	f169                	bnez	a0,80002ba2 <usertrap+0xae>
    80002be2:	b7a5                	j	80002b4a <usertrap+0x56>
  if(killed(p))
    80002be4:	8526                	mv	a0,s1
    80002be6:	ac9ff0ef          	jal	800026ae <killed>
    80002bea:	c511                	beqz	a0,80002bf6 <usertrap+0x102>
    80002bec:	a011                	j	80002bf0 <usertrap+0xfc>
    80002bee:	4901                	li	s2,0
    kexit(-1);
    80002bf0:	557d                	li	a0,-1
    80002bf2:	98dff0ef          	jal	8000257e <kexit>
  if(which_dev == 2)
    80002bf6:	4789                	li	a5,2
    80002bf8:	faf919e3          	bne	s2,a5,80002baa <usertrap+0xb6>
    yield();
    80002bfc:	84bff0ef          	jal	80002446 <yield>
    80002c00:	b76d                	j	80002baa <usertrap+0xb6>

0000000080002c02 <kerneltrap>:
{
    80002c02:	7179                	addi	sp,sp,-48
    80002c04:	f406                	sd	ra,40(sp)
    80002c06:	f022                	sd	s0,32(sp)
    80002c08:	ec26                	sd	s1,24(sp)
    80002c0a:	e84a                	sd	s2,16(sp)
    80002c0c:	e44e                	sd	s3,8(sp)
    80002c0e:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002c10:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002c14:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002c18:	142027f3          	csrr	a5,scause
    80002c1c:	89be                	mv	s3,a5
  if((sstatus & SSTATUS_SPP) == 0)
    80002c1e:	1004f793          	andi	a5,s1,256
    80002c22:	c795                	beqz	a5,80002c4e <kerneltrap+0x4c>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002c24:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002c28:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    80002c2a:	eb85                	bnez	a5,80002c5a <kerneltrap+0x58>
  if((which_dev = devintr()) == 0){
    80002c2c:	e53ff0ef          	jal	80002a7e <devintr>
    80002c30:	c91d                	beqz	a0,80002c66 <kerneltrap+0x64>
  if(which_dev == 2 && myproc() != 0)
    80002c32:	4789                	li	a5,2
    80002c34:	04f50a63          	beq	a0,a5,80002c88 <kerneltrap+0x86>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002c38:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002c3c:	10049073          	csrw	sstatus,s1
}
    80002c40:	70a2                	ld	ra,40(sp)
    80002c42:	7402                	ld	s0,32(sp)
    80002c44:	64e2                	ld	s1,24(sp)
    80002c46:	6942                	ld	s2,16(sp)
    80002c48:	69a2                	ld	s3,8(sp)
    80002c4a:	6145                	addi	sp,sp,48
    80002c4c:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80002c4e:	00005517          	auipc	a0,0x5
    80002c52:	6fa50513          	addi	a0,a0,1786 # 80008348 <etext+0x348>
    80002c56:	c01fd0ef          	jal	80000856 <panic>
    panic("kerneltrap: interrupts enabled");
    80002c5a:	00005517          	auipc	a0,0x5
    80002c5e:	71650513          	addi	a0,a0,1814 # 80008370 <etext+0x370>
    80002c62:	bf5fd0ef          	jal	80000856 <panic>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002c66:	14102673          	csrr	a2,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002c6a:	143026f3          	csrr	a3,stval
    printf("scause=0x%lx sepc=0x%lx stval=0x%lx\n", scause, r_sepc(), r_stval());
    80002c6e:	85ce                	mv	a1,s3
    80002c70:	00005517          	auipc	a0,0x5
    80002c74:	72050513          	addi	a0,a0,1824 # 80008390 <etext+0x390>
    80002c78:	8b5fd0ef          	jal	8000052c <printf>
    panic("kerneltrap");
    80002c7c:	00005517          	auipc	a0,0x5
    80002c80:	73c50513          	addi	a0,a0,1852 # 800083b8 <etext+0x3b8>
    80002c84:	bd3fd0ef          	jal	80000856 <panic>
  if(which_dev == 2 && myproc() != 0)
    80002c88:	fa1fe0ef          	jal	80001c28 <myproc>
    80002c8c:	d555                	beqz	a0,80002c38 <kerneltrap+0x36>
    yield();
    80002c8e:	fb8ff0ef          	jal	80002446 <yield>
    80002c92:	b75d                	j	80002c38 <kerneltrap+0x36>

0000000080002c94 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80002c94:	1101                	addi	sp,sp,-32
    80002c96:	ec06                	sd	ra,24(sp)
    80002c98:	e822                	sd	s0,16(sp)
    80002c9a:	e426                	sd	s1,8(sp)
    80002c9c:	1000                	addi	s0,sp,32
    80002c9e:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002ca0:	f89fe0ef          	jal	80001c28 <myproc>
  switch (n) {
    80002ca4:	4795                	li	a5,5
    80002ca6:	0497e163          	bltu	a5,s1,80002ce8 <argraw+0x54>
    80002caa:	048a                	slli	s1,s1,0x2
    80002cac:	00006717          	auipc	a4,0x6
    80002cb0:	b5470713          	addi	a4,a4,-1196 # 80008800 <states.0+0x30>
    80002cb4:	94ba                	add	s1,s1,a4
    80002cb6:	409c                	lw	a5,0(s1)
    80002cb8:	97ba                	add	a5,a5,a4
    80002cba:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    80002cbc:	6d3c                	ld	a5,88(a0)
    80002cbe:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80002cc0:	60e2                	ld	ra,24(sp)
    80002cc2:	6442                	ld	s0,16(sp)
    80002cc4:	64a2                	ld	s1,8(sp)
    80002cc6:	6105                	addi	sp,sp,32
    80002cc8:	8082                	ret
    return p->trapframe->a1;
    80002cca:	6d3c                	ld	a5,88(a0)
    80002ccc:	7fa8                	ld	a0,120(a5)
    80002cce:	bfcd                	j	80002cc0 <argraw+0x2c>
    return p->trapframe->a2;
    80002cd0:	6d3c                	ld	a5,88(a0)
    80002cd2:	63c8                	ld	a0,128(a5)
    80002cd4:	b7f5                	j	80002cc0 <argraw+0x2c>
    return p->trapframe->a3;
    80002cd6:	6d3c                	ld	a5,88(a0)
    80002cd8:	67c8                	ld	a0,136(a5)
    80002cda:	b7dd                	j	80002cc0 <argraw+0x2c>
    return p->trapframe->a4;
    80002cdc:	6d3c                	ld	a5,88(a0)
    80002cde:	6bc8                	ld	a0,144(a5)
    80002ce0:	b7c5                	j	80002cc0 <argraw+0x2c>
    return p->trapframe->a5;
    80002ce2:	6d3c                	ld	a5,88(a0)
    80002ce4:	6fc8                	ld	a0,152(a5)
    80002ce6:	bfe9                	j	80002cc0 <argraw+0x2c>
  panic("argraw");
    80002ce8:	00005517          	auipc	a0,0x5
    80002cec:	6e050513          	addi	a0,a0,1760 # 800083c8 <etext+0x3c8>
    80002cf0:	b67fd0ef          	jal	80000856 <panic>

0000000080002cf4 <fetchaddr>:
{
    80002cf4:	1101                	addi	sp,sp,-32
    80002cf6:	ec06                	sd	ra,24(sp)
    80002cf8:	e822                	sd	s0,16(sp)
    80002cfa:	e426                	sd	s1,8(sp)
    80002cfc:	e04a                	sd	s2,0(sp)
    80002cfe:	1000                	addi	s0,sp,32
    80002d00:	84aa                	mv	s1,a0
    80002d02:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002d04:	f25fe0ef          	jal	80001c28 <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    80002d08:	653c                	ld	a5,72(a0)
    80002d0a:	02f4f663          	bgeu	s1,a5,80002d36 <fetchaddr+0x42>
    80002d0e:	00848713          	addi	a4,s1,8
    80002d12:	02e7e463          	bltu	a5,a4,80002d3a <fetchaddr+0x46>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80002d16:	46a1                	li	a3,8
    80002d18:	8626                	mv	a2,s1
    80002d1a:	85ca                	mv	a1,s2
    80002d1c:	6928                	ld	a0,80(a0)
    80002d1e:	cdbfe0ef          	jal	800019f8 <copyin>
    80002d22:	00a03533          	snez	a0,a0
    80002d26:	40a0053b          	negw	a0,a0
}
    80002d2a:	60e2                	ld	ra,24(sp)
    80002d2c:	6442                	ld	s0,16(sp)
    80002d2e:	64a2                	ld	s1,8(sp)
    80002d30:	6902                	ld	s2,0(sp)
    80002d32:	6105                	addi	sp,sp,32
    80002d34:	8082                	ret
    return -1;
    80002d36:	557d                	li	a0,-1
    80002d38:	bfcd                	j	80002d2a <fetchaddr+0x36>
    80002d3a:	557d                	li	a0,-1
    80002d3c:	b7fd                	j	80002d2a <fetchaddr+0x36>

0000000080002d3e <fetchstr>:
{
    80002d3e:	7179                	addi	sp,sp,-48
    80002d40:	f406                	sd	ra,40(sp)
    80002d42:	f022                	sd	s0,32(sp)
    80002d44:	ec26                	sd	s1,24(sp)
    80002d46:	e84a                	sd	s2,16(sp)
    80002d48:	e44e                	sd	s3,8(sp)
    80002d4a:	1800                	addi	s0,sp,48
    80002d4c:	89aa                	mv	s3,a0
    80002d4e:	84ae                	mv	s1,a1
    80002d50:	8932                	mv	s2,a2
  struct proc *p = myproc();
    80002d52:	ed7fe0ef          	jal	80001c28 <myproc>
  if(copyinstr(p->pagetable, buf, addr, max) < 0)
    80002d56:	86ca                	mv	a3,s2
    80002d58:	864e                	mv	a2,s3
    80002d5a:	85a6                	mv	a1,s1
    80002d5c:	6928                	ld	a0,80(a0)
    80002d5e:	a2dfe0ef          	jal	8000178a <copyinstr>
    80002d62:	00054c63          	bltz	a0,80002d7a <fetchstr+0x3c>
  return strlen(buf);
    80002d66:	8526                	mv	a0,s1
    80002d68:	a08fe0ef          	jal	80000f70 <strlen>
}
    80002d6c:	70a2                	ld	ra,40(sp)
    80002d6e:	7402                	ld	s0,32(sp)
    80002d70:	64e2                	ld	s1,24(sp)
    80002d72:	6942                	ld	s2,16(sp)
    80002d74:	69a2                	ld	s3,8(sp)
    80002d76:	6145                	addi	sp,sp,48
    80002d78:	8082                	ret
    return -1;
    80002d7a:	557d                	li	a0,-1
    80002d7c:	bfc5                	j	80002d6c <fetchstr+0x2e>

0000000080002d7e <argint>:

// Fetch the nth 32-bit system call argument.
void
argint(int n, int *ip)
{
    80002d7e:	1101                	addi	sp,sp,-32
    80002d80:	ec06                	sd	ra,24(sp)
    80002d82:	e822                	sd	s0,16(sp)
    80002d84:	e426                	sd	s1,8(sp)
    80002d86:	1000                	addi	s0,sp,32
    80002d88:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002d8a:	f0bff0ef          	jal	80002c94 <argraw>
    80002d8e:	c088                	sw	a0,0(s1)
}
    80002d90:	60e2                	ld	ra,24(sp)
    80002d92:	6442                	ld	s0,16(sp)
    80002d94:	64a2                	ld	s1,8(sp)
    80002d96:	6105                	addi	sp,sp,32
    80002d98:	8082                	ret

0000000080002d9a <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void
argaddr(int n, uint64 *ip)
{
    80002d9a:	1101                	addi	sp,sp,-32
    80002d9c:	ec06                	sd	ra,24(sp)
    80002d9e:	e822                	sd	s0,16(sp)
    80002da0:	e426                	sd	s1,8(sp)
    80002da2:	1000                	addi	s0,sp,32
    80002da4:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002da6:	eefff0ef          	jal	80002c94 <argraw>
    80002daa:	e088                	sd	a0,0(s1)
}
    80002dac:	60e2                	ld	ra,24(sp)
    80002dae:	6442                	ld	s0,16(sp)
    80002db0:	64a2                	ld	s1,8(sp)
    80002db2:	6105                	addi	sp,sp,32
    80002db4:	8082                	ret

0000000080002db6 <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80002db6:	1101                	addi	sp,sp,-32
    80002db8:	ec06                	sd	ra,24(sp)
    80002dba:	e822                	sd	s0,16(sp)
    80002dbc:	e426                	sd	s1,8(sp)
    80002dbe:	e04a                	sd	s2,0(sp)
    80002dc0:	1000                	addi	s0,sp,32
    80002dc2:	892e                	mv	s2,a1
    80002dc4:	84b2                	mv	s1,a2
  *ip = argraw(n);
    80002dc6:	ecfff0ef          	jal	80002c94 <argraw>
  uint64 addr;
  argaddr(n, &addr);
  return fetchstr(addr, buf, max);
    80002dca:	8626                	mv	a2,s1
    80002dcc:	85ca                	mv	a1,s2
    80002dce:	f71ff0ef          	jal	80002d3e <fetchstr>
}
    80002dd2:	60e2                	ld	ra,24(sp)
    80002dd4:	6442                	ld	s0,16(sp)
    80002dd6:	64a2                	ld	s1,8(sp)
    80002dd8:	6902                	ld	s2,0(sp)
    80002dda:	6105                	addi	sp,sp,32
    80002ddc:	8082                	ret

0000000080002dde <syscall>:

};

void
syscall(void)
{
    80002dde:	1101                	addi	sp,sp,-32
    80002de0:	ec06                	sd	ra,24(sp)
    80002de2:	e822                	sd	s0,16(sp)
    80002de4:	e426                	sd	s1,8(sp)
    80002de6:	e04a                	sd	s2,0(sp)
    80002de8:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    80002dea:	e3ffe0ef          	jal	80001c28 <myproc>
    80002dee:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    80002df0:	05853903          	ld	s2,88(a0)
    80002df4:	0a893783          	ld	a5,168(s2)
    80002df8:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80002dfc:	37fd                	addiw	a5,a5,-1
    80002dfe:	4761                	li	a4,24
    80002e00:	00f76f63          	bltu	a4,a5,80002e1e <syscall+0x40>
    80002e04:	00369713          	slli	a4,a3,0x3
    80002e08:	00006797          	auipc	a5,0x6
    80002e0c:	a1078793          	addi	a5,a5,-1520 # 80008818 <syscalls>
    80002e10:	97ba                	add	a5,a5,a4
    80002e12:	639c                	ld	a5,0(a5)
    80002e14:	c789                	beqz	a5,80002e1e <syscall+0x40>
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    p->trapframe->a0 = syscalls[num]();
    80002e16:	9782                	jalr	a5
    80002e18:	06a93823          	sd	a0,112(s2)
    80002e1c:	a829                	j	80002e36 <syscall+0x58>
  } else {
    printf("%d %s: unknown sys call %d\n",
    80002e1e:	15848613          	addi	a2,s1,344
    80002e22:	588c                	lw	a1,48(s1)
    80002e24:	00005517          	auipc	a0,0x5
    80002e28:	5ac50513          	addi	a0,a0,1452 # 800083d0 <etext+0x3d0>
    80002e2c:	f00fd0ef          	jal	8000052c <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80002e30:	6cbc                	ld	a5,88(s1)
    80002e32:	577d                	li	a4,-1
    80002e34:	fbb8                	sd	a4,112(a5)
  }
}
    80002e36:	60e2                	ld	ra,24(sp)
    80002e38:	6442                	ld	s0,16(sp)
    80002e3a:	64a2                	ld	s1,8(sp)
    80002e3c:	6902                	ld	s2,0(sp)
    80002e3e:	6105                	addi	sp,sp,32
    80002e40:	8082                	ret

0000000080002e42 <sys_exit>:
#include "vm.h"
#include "schedlog.h"

uint64
sys_exit(void)
{
    80002e42:	1101                	addi	sp,sp,-32
    80002e44:	ec06                	sd	ra,24(sp)
    80002e46:	e822                	sd	s0,16(sp)
    80002e48:	1000                	addi	s0,sp,32
  int n;
  argint(0, &n);
    80002e4a:	fec40593          	addi	a1,s0,-20
    80002e4e:	4501                	li	a0,0
    80002e50:	f2fff0ef          	jal	80002d7e <argint>
  kexit(n);
    80002e54:	fec42503          	lw	a0,-20(s0)
    80002e58:	f26ff0ef          	jal	8000257e <kexit>
  return 0;  // not reached
}
    80002e5c:	4501                	li	a0,0
    80002e5e:	60e2                	ld	ra,24(sp)
    80002e60:	6442                	ld	s0,16(sp)
    80002e62:	6105                	addi	sp,sp,32
    80002e64:	8082                	ret

0000000080002e66 <sys_getpid>:

uint64
sys_getpid(void)
{
    80002e66:	1141                	addi	sp,sp,-16
    80002e68:	e406                	sd	ra,8(sp)
    80002e6a:	e022                	sd	s0,0(sp)
    80002e6c:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80002e6e:	dbbfe0ef          	jal	80001c28 <myproc>
}
    80002e72:	5908                	lw	a0,48(a0)
    80002e74:	60a2                	ld	ra,8(sp)
    80002e76:	6402                	ld	s0,0(sp)
    80002e78:	0141                	addi	sp,sp,16
    80002e7a:	8082                	ret

0000000080002e7c <sys_fork>:

uint64
sys_fork(void)
{
    80002e7c:	1141                	addi	sp,sp,-16
    80002e7e:	e406                	sd	ra,8(sp)
    80002e80:	e022                	sd	s0,0(sp)
    80002e82:	0800                	addi	s0,sp,16
  return kfork();
    80002e84:	996ff0ef          	jal	8000201a <kfork>
}
    80002e88:	60a2                	ld	ra,8(sp)
    80002e8a:	6402                	ld	s0,0(sp)
    80002e8c:	0141                	addi	sp,sp,16
    80002e8e:	8082                	ret

0000000080002e90 <sys_wait>:

uint64
sys_wait(void)
{
    80002e90:	1101                	addi	sp,sp,-32
    80002e92:	ec06                	sd	ra,24(sp)
    80002e94:	e822                	sd	s0,16(sp)
    80002e96:	1000                	addi	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    80002e98:	fe840593          	addi	a1,s0,-24
    80002e9c:	4501                	li	a0,0
    80002e9e:	efdff0ef          	jal	80002d9a <argaddr>
  return kwait(p);
    80002ea2:	fe843503          	ld	a0,-24(s0)
    80002ea6:	833ff0ef          	jal	800026d8 <kwait>
}
    80002eaa:	60e2                	ld	ra,24(sp)
    80002eac:	6442                	ld	s0,16(sp)
    80002eae:	6105                	addi	sp,sp,32
    80002eb0:	8082                	ret

0000000080002eb2 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80002eb2:	7179                	addi	sp,sp,-48
    80002eb4:	f406                	sd	ra,40(sp)
    80002eb6:	f022                	sd	s0,32(sp)
    80002eb8:	ec26                	sd	s1,24(sp)
    80002eba:	1800                	addi	s0,sp,48
  uint64 addr;
  int t;
  int n;

  argint(0, &n);
    80002ebc:	fd840593          	addi	a1,s0,-40
    80002ec0:	4501                	li	a0,0
    80002ec2:	ebdff0ef          	jal	80002d7e <argint>
  argint(1, &t);
    80002ec6:	fdc40593          	addi	a1,s0,-36
    80002eca:	4505                	li	a0,1
    80002ecc:	eb3ff0ef          	jal	80002d7e <argint>
  addr = myproc()->sz;
    80002ed0:	d59fe0ef          	jal	80001c28 <myproc>
    80002ed4:	6524                	ld	s1,72(a0)

  if(t == SBRK_EAGER || n < 0) {
    80002ed6:	fdc42703          	lw	a4,-36(s0)
    80002eda:	4785                	li	a5,1
    80002edc:	02f70763          	beq	a4,a5,80002f0a <sys_sbrk+0x58>
    80002ee0:	fd842783          	lw	a5,-40(s0)
    80002ee4:	0207c363          	bltz	a5,80002f0a <sys_sbrk+0x58>
    }
  } else {
    // Lazily allocate memory for this process: increase its memory
    // size but don't allocate memory. If the processes uses the
    // memory, vmfault() will allocate it.
    if(addr + n < addr)
    80002ee8:	97a6                	add	a5,a5,s1
      return -1;
    if(addr + n > TRAPFRAME)
    80002eea:	02000737          	lui	a4,0x2000
    80002eee:	177d                	addi	a4,a4,-1 # 1ffffff <_entry-0x7e000001>
    80002ef0:	0736                	slli	a4,a4,0xd
    80002ef2:	02f76a63          	bltu	a4,a5,80002f26 <sys_sbrk+0x74>
    80002ef6:	0297e863          	bltu	a5,s1,80002f26 <sys_sbrk+0x74>
      return -1;
    myproc()->sz += n;
    80002efa:	d2ffe0ef          	jal	80001c28 <myproc>
    80002efe:	fd842703          	lw	a4,-40(s0)
    80002f02:	653c                	ld	a5,72(a0)
    80002f04:	97ba                	add	a5,a5,a4
    80002f06:	e53c                	sd	a5,72(a0)
    80002f08:	a039                	j	80002f16 <sys_sbrk+0x64>
    if(growproc(n) < 0) {
    80002f0a:	fd842503          	lw	a0,-40(s0)
    80002f0e:	820ff0ef          	jal	80001f2e <growproc>
    80002f12:	00054863          	bltz	a0,80002f22 <sys_sbrk+0x70>
  }
  return addr;
}
    80002f16:	8526                	mv	a0,s1
    80002f18:	70a2                	ld	ra,40(sp)
    80002f1a:	7402                	ld	s0,32(sp)
    80002f1c:	64e2                	ld	s1,24(sp)
    80002f1e:	6145                	addi	sp,sp,48
    80002f20:	8082                	ret
      return -1;
    80002f22:	54fd                	li	s1,-1
    80002f24:	bfcd                	j	80002f16 <sys_sbrk+0x64>
      return -1;
    80002f26:	54fd                	li	s1,-1
    80002f28:	b7fd                	j	80002f16 <sys_sbrk+0x64>

0000000080002f2a <sys_pause>:

uint64
sys_pause(void)
{
    80002f2a:	7139                	addi	sp,sp,-64
    80002f2c:	fc06                	sd	ra,56(sp)
    80002f2e:	f822                	sd	s0,48(sp)
    80002f30:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    80002f32:	fcc40593          	addi	a1,s0,-52
    80002f36:	4501                	li	a0,0
    80002f38:	e47ff0ef          	jal	80002d7e <argint>
  if(n < 0)
    80002f3c:	fcc42783          	lw	a5,-52(s0)
    80002f40:	0607c863          	bltz	a5,80002fb0 <sys_pause+0x86>
    n = 0;
  acquire(&tickslock);
    80002f44:	00014517          	auipc	a0,0x14
    80002f48:	98c50513          	addi	a0,a0,-1652 # 800168d0 <tickslock>
    80002f4c:	dcbfd0ef          	jal	80000d16 <acquire>
  ticks0 = ticks;
  while(ticks - ticks0 < n){
    80002f50:	fcc42783          	lw	a5,-52(s0)
    80002f54:	c3b9                	beqz	a5,80002f9a <sys_pause+0x70>
    80002f56:	f426                	sd	s1,40(sp)
    80002f58:	f04a                	sd	s2,32(sp)
    80002f5a:	ec4e                	sd	s3,24(sp)
  ticks0 = ticks;
    80002f5c:	00006997          	auipc	s3,0x6
    80002f60:	9d49a983          	lw	s3,-1580(s3) # 80008930 <ticks>
    if(killed(myproc())){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80002f64:	00014917          	auipc	s2,0x14
    80002f68:	96c90913          	addi	s2,s2,-1684 # 800168d0 <tickslock>
    80002f6c:	00006497          	auipc	s1,0x6
    80002f70:	9c448493          	addi	s1,s1,-1596 # 80008930 <ticks>
    if(killed(myproc())){
    80002f74:	cb5fe0ef          	jal	80001c28 <myproc>
    80002f78:	f36ff0ef          	jal	800026ae <killed>
    80002f7c:	ed0d                	bnez	a0,80002fb6 <sys_pause+0x8c>
    sleep(&ticks, &tickslock);
    80002f7e:	85ca                	mv	a1,s2
    80002f80:	8526                	mv	a0,s1
    80002f82:	cf0ff0ef          	jal	80002472 <sleep>
  while(ticks - ticks0 < n){
    80002f86:	409c                	lw	a5,0(s1)
    80002f88:	413787bb          	subw	a5,a5,s3
    80002f8c:	fcc42703          	lw	a4,-52(s0)
    80002f90:	fee7e2e3          	bltu	a5,a4,80002f74 <sys_pause+0x4a>
    80002f94:	74a2                	ld	s1,40(sp)
    80002f96:	7902                	ld	s2,32(sp)
    80002f98:	69e2                	ld	s3,24(sp)
  }
  release(&tickslock);
    80002f9a:	00014517          	auipc	a0,0x14
    80002f9e:	93650513          	addi	a0,a0,-1738 # 800168d0 <tickslock>
    80002fa2:	e09fd0ef          	jal	80000daa <release>
  return 0;
    80002fa6:	4501                	li	a0,0
}
    80002fa8:	70e2                	ld	ra,56(sp)
    80002faa:	7442                	ld	s0,48(sp)
    80002fac:	6121                	addi	sp,sp,64
    80002fae:	8082                	ret
    n = 0;
    80002fb0:	fc042623          	sw	zero,-52(s0)
    80002fb4:	bf41                	j	80002f44 <sys_pause+0x1a>
      release(&tickslock);
    80002fb6:	00014517          	auipc	a0,0x14
    80002fba:	91a50513          	addi	a0,a0,-1766 # 800168d0 <tickslock>
    80002fbe:	dedfd0ef          	jal	80000daa <release>
      return -1;
    80002fc2:	557d                	li	a0,-1
    80002fc4:	74a2                	ld	s1,40(sp)
    80002fc6:	7902                	ld	s2,32(sp)
    80002fc8:	69e2                	ld	s3,24(sp)
    80002fca:	bff9                	j	80002fa8 <sys_pause+0x7e>

0000000080002fcc <sys_kill>:

uint64
sys_kill(void)
{
    80002fcc:	1101                	addi	sp,sp,-32
    80002fce:	ec06                	sd	ra,24(sp)
    80002fd0:	e822                	sd	s0,16(sp)
    80002fd2:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    80002fd4:	fec40593          	addi	a1,s0,-20
    80002fd8:	4501                	li	a0,0
    80002fda:	da5ff0ef          	jal	80002d7e <argint>
  return kkill(pid);
    80002fde:	fec42503          	lw	a0,-20(s0)
    80002fe2:	e42ff0ef          	jal	80002624 <kkill>
}
    80002fe6:	60e2                	ld	ra,24(sp)
    80002fe8:	6442                	ld	s0,16(sp)
    80002fea:	6105                	addi	sp,sp,32
    80002fec:	8082                	ret

0000000080002fee <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80002fee:	1101                	addi	sp,sp,-32
    80002ff0:	ec06                	sd	ra,24(sp)
    80002ff2:	e822                	sd	s0,16(sp)
    80002ff4:	e426                	sd	s1,8(sp)
    80002ff6:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80002ff8:	00014517          	auipc	a0,0x14
    80002ffc:	8d850513          	addi	a0,a0,-1832 # 800168d0 <tickslock>
    80003000:	d17fd0ef          	jal	80000d16 <acquire>
  xticks = ticks;
    80003004:	00006797          	auipc	a5,0x6
    80003008:	92c7a783          	lw	a5,-1748(a5) # 80008930 <ticks>
    8000300c:	84be                	mv	s1,a5
  release(&tickslock);
    8000300e:	00014517          	auipc	a0,0x14
    80003012:	8c250513          	addi	a0,a0,-1854 # 800168d0 <tickslock>
    80003016:	d95fd0ef          	jal	80000daa <release>
  return xticks;
}
    8000301a:	02049513          	slli	a0,s1,0x20
    8000301e:	9101                	srli	a0,a0,0x20
    80003020:	60e2                	ld	ra,24(sp)
    80003022:	6442                	ld	s0,16(sp)
    80003024:	64a2                	ld	s1,8(sp)
    80003026:	6105                	addi	sp,sp,32
    80003028:	8082                	ret

000000008000302a <sys_schedread>:

uint64
sys_schedread(void)
{
    8000302a:	7131                	addi	sp,sp,-192
    8000302c:	fd06                	sd	ra,184(sp)
    8000302e:	f922                	sd	s0,176(sp)
    80003030:	f526                	sd	s1,168(sp)
    80003032:	f14a                	sd	s2,160(sp)
    80003034:	0180                	addi	s0,sp,192
    80003036:	81010113          	addi	sp,sp,-2032
  uint64 dst;
  int max;

  argaddr(0, &dst);
    8000303a:	fd840593          	addi	a1,s0,-40
    8000303e:	4501                	li	a0,0
    80003040:	d5bff0ef          	jal	80002d9a <argaddr>
  argint(1, &max);
    80003044:	fd440593          	addi	a1,s0,-44
    80003048:	4505                	li	a0,1
    8000304a:	d35ff0ef          	jal	80002d7e <argint>

  if(max <= 0)
    8000304e:	fd442783          	lw	a5,-44(s0)
    return 0;
    80003052:	4901                	li	s2,0
  if(max <= 0)
    80003054:	04f05963          	blez	a5,800030a6 <sys_schedread+0x7c>

  struct sched_event buf[32];
  if(max > 32)
    80003058:	02000713          	li	a4,32
    8000305c:	00f75463          	bge	a4,a5,80003064 <sys_schedread+0x3a>
    max = 32;
    80003060:	fce42a23          	sw	a4,-44(s0)

  int n = schedread(buf, max);
    80003064:	fd442583          	lw	a1,-44(s0)
    80003068:	80040513          	addi	a0,s0,-2048
    8000306c:	1501                	addi	a0,a0,-32
    8000306e:	f7050513          	addi	a0,a0,-144
    80003072:	72c030ef          	jal	8000679e <schedread>
    80003076:	84aa                	mv	s1,a0
  if(n < 0)
    return -1;
    80003078:	57fd                	li	a5,-1
    8000307a:	893e                	mv	s2,a5
  if(n < 0)
    8000307c:	02054563          	bltz	a0,800030a6 <sys_schedread+0x7c>

  if(copyout(myproc()->pagetable, dst, (char *)buf, n * sizeof(struct sched_event)) < 0)
    80003080:	ba9fe0ef          	jal	80001c28 <myproc>
    80003084:	8926                	mv	s2,s1
    80003086:	00449693          	slli	a3,s1,0x4
    8000308a:	96a6                	add	a3,a3,s1
    8000308c:	068a                	slli	a3,a3,0x2
    8000308e:	80040613          	addi	a2,s0,-2048
    80003092:	1601                	addi	a2,a2,-32
    80003094:	f7060613          	addi	a2,a2,-144
    80003098:	fd843583          	ld	a1,-40(s0)
    8000309c:	6928                	ld	a0,80(a0)
    8000309e:	89dfe0ef          	jal	8000193a <copyout>
    800030a2:	00054b63          	bltz	a0,800030b8 <sys_schedread+0x8e>
    return -1;

  return n;
}
    800030a6:	854a                	mv	a0,s2
    800030a8:	7f010113          	addi	sp,sp,2032
    800030ac:	70ea                	ld	ra,184(sp)
    800030ae:	744a                	ld	s0,176(sp)
    800030b0:	74aa                	ld	s1,168(sp)
    800030b2:	790a                	ld	s2,160(sp)
    800030b4:	6129                	addi	sp,sp,192
    800030b6:	8082                	ret
    return -1;
    800030b8:	57fd                	li	a5,-1
    800030ba:	893e                	mv	s2,a5
    800030bc:	b7ed                	j	800030a6 <sys_schedread+0x7c>

00000000800030be <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    800030be:	7179                	addi	sp,sp,-48
    800030c0:	f406                	sd	ra,40(sp)
    800030c2:	f022                	sd	s0,32(sp)
    800030c4:	ec26                	sd	s1,24(sp)
    800030c6:	e84a                	sd	s2,16(sp)
    800030c8:	e44e                	sd	s3,8(sp)
    800030ca:	e052                	sd	s4,0(sp)
    800030cc:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    800030ce:	00005597          	auipc	a1,0x5
    800030d2:	32258593          	addi	a1,a1,802 # 800083f0 <etext+0x3f0>
    800030d6:	00014517          	auipc	a0,0x14
    800030da:	81250513          	addi	a0,a0,-2030 # 800168e8 <bcache>
    800030de:	baffd0ef          	jal	80000c8c <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    800030e2:	0001c797          	auipc	a5,0x1c
    800030e6:	80678793          	addi	a5,a5,-2042 # 8001e8e8 <bcache+0x8000>
    800030ea:	0001c717          	auipc	a4,0x1c
    800030ee:	a6670713          	addi	a4,a4,-1434 # 8001eb50 <bcache+0x8268>
    800030f2:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    800030f6:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    800030fa:	00014497          	auipc	s1,0x14
    800030fe:	80648493          	addi	s1,s1,-2042 # 80016900 <bcache+0x18>
    b->next = bcache.head.next;
    80003102:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80003104:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80003106:	00005a17          	auipc	s4,0x5
    8000310a:	2f2a0a13          	addi	s4,s4,754 # 800083f8 <etext+0x3f8>
    b->next = bcache.head.next;
    8000310e:	2b893783          	ld	a5,696(s2)
    80003112:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80003114:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80003118:	85d2                	mv	a1,s4
    8000311a:	01048513          	addi	a0,s1,16
    8000311e:	366010ef          	jal	80004484 <initsleeplock>
    bcache.head.next->prev = b;
    80003122:	2b893783          	ld	a5,696(s2)
    80003126:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80003128:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    8000312c:	45848493          	addi	s1,s1,1112
    80003130:	fd349fe3          	bne	s1,s3,8000310e <binit+0x50>
  }
}
    80003134:	70a2                	ld	ra,40(sp)
    80003136:	7402                	ld	s0,32(sp)
    80003138:	64e2                	ld	s1,24(sp)
    8000313a:	6942                	ld	s2,16(sp)
    8000313c:	69a2                	ld	s3,8(sp)
    8000313e:	6a02                	ld	s4,0(sp)
    80003140:	6145                	addi	sp,sp,48
    80003142:	8082                	ret

0000000080003144 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    80003144:	7179                	addi	sp,sp,-48
    80003146:	f406                	sd	ra,40(sp)
    80003148:	f022                	sd	s0,32(sp)
    8000314a:	ec26                	sd	s1,24(sp)
    8000314c:	e84a                	sd	s2,16(sp)
    8000314e:	e44e                	sd	s3,8(sp)
    80003150:	1800                	addi	s0,sp,48
    80003152:	892a                	mv	s2,a0
    80003154:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    80003156:	00013517          	auipc	a0,0x13
    8000315a:	79250513          	addi	a0,a0,1938 # 800168e8 <bcache>
    8000315e:	bb9fd0ef          	jal	80000d16 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    80003162:	0001c497          	auipc	s1,0x1c
    80003166:	a3e4b483          	ld	s1,-1474(s1) # 8001eba0 <bcache+0x82b8>
    8000316a:	0001c797          	auipc	a5,0x1c
    8000316e:	9e678793          	addi	a5,a5,-1562 # 8001eb50 <bcache+0x8268>
    80003172:	04f48563          	beq	s1,a5,800031bc <bread+0x78>
    80003176:	873e                	mv	a4,a5
    80003178:	a021                	j	80003180 <bread+0x3c>
    8000317a:	68a4                	ld	s1,80(s1)
    8000317c:	04e48063          	beq	s1,a4,800031bc <bread+0x78>
    if(b->dev == dev && b->blockno == blockno){
    80003180:	449c                	lw	a5,8(s1)
    80003182:	ff279ce3          	bne	a5,s2,8000317a <bread+0x36>
    80003186:	44dc                	lw	a5,12(s1)
    80003188:	ff3799e3          	bne	a5,s3,8000317a <bread+0x36>
      b->refcnt++;
    8000318c:	40bc                	lw	a5,64(s1)
    8000318e:	2785                	addiw	a5,a5,1
    80003190:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80003192:	00013517          	auipc	a0,0x13
    80003196:	75650513          	addi	a0,a0,1878 # 800168e8 <bcache>
    8000319a:	c11fd0ef          	jal	80000daa <release>
      acquiresleep(&b->lock);
    8000319e:	01048513          	addi	a0,s1,16
    800031a2:	318010ef          	jal	800044ba <acquiresleep>
      fslog_push(FS_BGET_HIT, 0, blockno, 0, "BCACHE");
    800031a6:	00005717          	auipc	a4,0x5
    800031aa:	25a70713          	addi	a4,a4,602 # 80008400 <etext+0x400>
    800031ae:	4681                	li	a3,0
    800031b0:	864e                	mv	a2,s3
    800031b2:	4581                	li	a1,0
    800031b4:	4519                	li	a0,6
    800031b6:	1da030ef          	jal	80006390 <fslog_push>
      return b;
    800031ba:	a09d                	j	80003220 <bread+0xdc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    800031bc:	0001c497          	auipc	s1,0x1c
    800031c0:	9dc4b483          	ld	s1,-1572(s1) # 8001eb98 <bcache+0x82b0>
    800031c4:	0001c797          	auipc	a5,0x1c
    800031c8:	98c78793          	addi	a5,a5,-1652 # 8001eb50 <bcache+0x8268>
    800031cc:	00f48863          	beq	s1,a5,800031dc <bread+0x98>
    800031d0:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    800031d2:	40bc                	lw	a5,64(s1)
    800031d4:	cb91                	beqz	a5,800031e8 <bread+0xa4>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    800031d6:	64a4                	ld	s1,72(s1)
    800031d8:	fee49de3          	bne	s1,a4,800031d2 <bread+0x8e>
  panic("bget: no buffers");
    800031dc:	00005517          	auipc	a0,0x5
    800031e0:	22c50513          	addi	a0,a0,556 # 80008408 <etext+0x408>
    800031e4:	e72fd0ef          	jal	80000856 <panic>
      b->dev = dev;
    800031e8:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    800031ec:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    800031f0:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    800031f4:	4785                	li	a5,1
    800031f6:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    800031f8:	00013517          	auipc	a0,0x13
    800031fc:	6f050513          	addi	a0,a0,1776 # 800168e8 <bcache>
    80003200:	babfd0ef          	jal	80000daa <release>
      acquiresleep(&b->lock);
    80003204:	01048513          	addi	a0,s1,16
    80003208:	2b2010ef          	jal	800044ba <acquiresleep>
      fslog_push(FS_BGET_MISS, 0, blockno, 0, "BCACHE");
    8000320c:	00005717          	auipc	a4,0x5
    80003210:	1f470713          	addi	a4,a4,500 # 80008400 <etext+0x400>
    80003214:	4681                	li	a3,0
    80003216:	864e                	mv	a2,s3
    80003218:	4581                	li	a1,0
    8000321a:	451d                	li	a0,7
    8000321c:	174030ef          	jal	80006390 <fslog_push>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    80003220:	409c                	lw	a5,0(s1)
    80003222:	cb89                	beqz	a5,80003234 <bread+0xf0>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80003224:	8526                	mv	a0,s1
    80003226:	70a2                	ld	ra,40(sp)
    80003228:	7402                	ld	s0,32(sp)
    8000322a:	64e2                	ld	s1,24(sp)
    8000322c:	6942                	ld	s2,16(sp)
    8000322e:	69a2                	ld	s3,8(sp)
    80003230:	6145                	addi	sp,sp,48
    80003232:	8082                	ret
    virtio_disk_rw(b, 0);
    80003234:	4581                	li	a1,0
    80003236:	8526                	mv	a0,s1
    80003238:	339020ef          	jal	80005d70 <virtio_disk_rw>
    b->valid = 1;
    8000323c:	4785                	li	a5,1
    8000323e:	c09c                	sw	a5,0(s1)
  return b;
    80003240:	b7d5                	j	80003224 <bread+0xe0>

0000000080003242 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    80003242:	1101                	addi	sp,sp,-32
    80003244:	ec06                	sd	ra,24(sp)
    80003246:	e822                	sd	s0,16(sp)
    80003248:	e426                	sd	s1,8(sp)
    8000324a:	1000                	addi	s0,sp,32
    8000324c:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    8000324e:	0541                	addi	a0,a0,16
    80003250:	2e8010ef          	jal	80004538 <holdingsleep>
    80003254:	c911                	beqz	a0,80003268 <bwrite+0x26>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    80003256:	4585                	li	a1,1
    80003258:	8526                	mv	a0,s1
    8000325a:	317020ef          	jal	80005d70 <virtio_disk_rw>
}
    8000325e:	60e2                	ld	ra,24(sp)
    80003260:	6442                	ld	s0,16(sp)
    80003262:	64a2                	ld	s1,8(sp)
    80003264:	6105                	addi	sp,sp,32
    80003266:	8082                	ret
    panic("bwrite");
    80003268:	00005517          	auipc	a0,0x5
    8000326c:	1b850513          	addi	a0,a0,440 # 80008420 <etext+0x420>
    80003270:	de6fd0ef          	jal	80000856 <panic>

0000000080003274 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    80003274:	1101                	addi	sp,sp,-32
    80003276:	ec06                	sd	ra,24(sp)
    80003278:	e822                	sd	s0,16(sp)
    8000327a:	e426                	sd	s1,8(sp)
    8000327c:	e04a                	sd	s2,0(sp)
    8000327e:	1000                	addi	s0,sp,32
    80003280:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80003282:	01050913          	addi	s2,a0,16
    80003286:	854a                	mv	a0,s2
    80003288:	2b0010ef          	jal	80004538 <holdingsleep>
    8000328c:	c915                	beqz	a0,800032c0 <brelse+0x4c>
    panic("brelse");

  releasesleep(&b->lock);
    8000328e:	854a                	mv	a0,s2
    80003290:	270010ef          	jal	80004500 <releasesleep>

  acquire(&bcache.lock);
    80003294:	00013517          	auipc	a0,0x13
    80003298:	65450513          	addi	a0,a0,1620 # 800168e8 <bcache>
    8000329c:	a7bfd0ef          	jal	80000d16 <acquire>
  b->refcnt--;
    800032a0:	40bc                	lw	a5,64(s1)
    800032a2:	37fd                	addiw	a5,a5,-1
    800032a4:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    800032a6:	c39d                	beqz	a5,800032cc <brelse+0x58>
    bcache.head.next->prev = b;
    bcache.head.next = b;
    fslog_push(FS_BRELEASE, 0, b->blockno, 0, "BCACHE");
  }
  
  release(&bcache.lock);
    800032a8:	00013517          	auipc	a0,0x13
    800032ac:	64050513          	addi	a0,a0,1600 # 800168e8 <bcache>
    800032b0:	afbfd0ef          	jal	80000daa <release>
}
    800032b4:	60e2                	ld	ra,24(sp)
    800032b6:	6442                	ld	s0,16(sp)
    800032b8:	64a2                	ld	s1,8(sp)
    800032ba:	6902                	ld	s2,0(sp)
    800032bc:	6105                	addi	sp,sp,32
    800032be:	8082                	ret
    panic("brelse");
    800032c0:	00005517          	auipc	a0,0x5
    800032c4:	16850513          	addi	a0,a0,360 # 80008428 <etext+0x428>
    800032c8:	d8efd0ef          	jal	80000856 <panic>
    b->next->prev = b->prev;
    800032cc:	68b8                	ld	a4,80(s1)
    800032ce:	64bc                	ld	a5,72(s1)
    800032d0:	e73c                	sd	a5,72(a4)
    b->prev->next = b->next;
    800032d2:	68b8                	ld	a4,80(s1)
    800032d4:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    800032d6:	0001b797          	auipc	a5,0x1b
    800032da:	61278793          	addi	a5,a5,1554 # 8001e8e8 <bcache+0x8000>
    800032de:	2b87b703          	ld	a4,696(a5)
    800032e2:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    800032e4:	0001c717          	auipc	a4,0x1c
    800032e8:	86c70713          	addi	a4,a4,-1940 # 8001eb50 <bcache+0x8268>
    800032ec:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    800032ee:	2b87b703          	ld	a4,696(a5)
    800032f2:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    800032f4:	2a97bc23          	sd	s1,696(a5)
    fslog_push(FS_BRELEASE, 0, b->blockno, 0, "BCACHE");
    800032f8:	00005717          	auipc	a4,0x5
    800032fc:	10870713          	addi	a4,a4,264 # 80008400 <etext+0x400>
    80003300:	4681                	li	a3,0
    80003302:	44d0                	lw	a2,12(s1)
    80003304:	4581                	li	a1,0
    80003306:	4521                	li	a0,8
    80003308:	088030ef          	jal	80006390 <fslog_push>
    8000330c:	bf71                	j	800032a8 <brelse+0x34>

000000008000330e <bpin>:

void
bpin(struct buf *b) {
    8000330e:	1101                	addi	sp,sp,-32
    80003310:	ec06                	sd	ra,24(sp)
    80003312:	e822                	sd	s0,16(sp)
    80003314:	e426                	sd	s1,8(sp)
    80003316:	1000                	addi	s0,sp,32
    80003318:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    8000331a:	00013517          	auipc	a0,0x13
    8000331e:	5ce50513          	addi	a0,a0,1486 # 800168e8 <bcache>
    80003322:	9f5fd0ef          	jal	80000d16 <acquire>
  b->refcnt++;
    80003326:	40bc                	lw	a5,64(s1)
    80003328:	2785                	addiw	a5,a5,1
    8000332a:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    8000332c:	00013517          	auipc	a0,0x13
    80003330:	5bc50513          	addi	a0,a0,1468 # 800168e8 <bcache>
    80003334:	a77fd0ef          	jal	80000daa <release>
}
    80003338:	60e2                	ld	ra,24(sp)
    8000333a:	6442                	ld	s0,16(sp)
    8000333c:	64a2                	ld	s1,8(sp)
    8000333e:	6105                	addi	sp,sp,32
    80003340:	8082                	ret

0000000080003342 <bunpin>:

void
bunpin(struct buf *b) {
    80003342:	1101                	addi	sp,sp,-32
    80003344:	ec06                	sd	ra,24(sp)
    80003346:	e822                	sd	s0,16(sp)
    80003348:	e426                	sd	s1,8(sp)
    8000334a:	1000                	addi	s0,sp,32
    8000334c:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    8000334e:	00013517          	auipc	a0,0x13
    80003352:	59a50513          	addi	a0,a0,1434 # 800168e8 <bcache>
    80003356:	9c1fd0ef          	jal	80000d16 <acquire>
  b->refcnt--;
    8000335a:	40bc                	lw	a5,64(s1)
    8000335c:	37fd                	addiw	a5,a5,-1
    8000335e:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80003360:	00013517          	auipc	a0,0x13
    80003364:	58850513          	addi	a0,a0,1416 # 800168e8 <bcache>
    80003368:	a43fd0ef          	jal	80000daa <release>
}
    8000336c:	60e2                	ld	ra,24(sp)
    8000336e:	6442                	ld	s0,16(sp)
    80003370:	64a2                	ld	s1,8(sp)
    80003372:	6105                	addi	sp,sp,32
    80003374:	8082                	ret

0000000080003376 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    80003376:	1101                	addi	sp,sp,-32
    80003378:	ec06                	sd	ra,24(sp)
    8000337a:	e822                	sd	s0,16(sp)
    8000337c:	e426                	sd	s1,8(sp)
    8000337e:	e04a                	sd	s2,0(sp)
    80003380:	1000                	addi	s0,sp,32
    80003382:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    80003384:	00d5d79b          	srliw	a5,a1,0xd
    80003388:	0001c597          	auipc	a1,0x1c
    8000338c:	c3c5a583          	lw	a1,-964(a1) # 8001efc4 <sb+0x1c>
    80003390:	9dbd                	addw	a1,a1,a5
    80003392:	db3ff0ef          	jal	80003144 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    80003396:	0074f713          	andi	a4,s1,7
    8000339a:	4785                	li	a5,1
    8000339c:	00e797bb          	sllw	a5,a5,a4
  bi = b % BPB;
    800033a0:	14ce                	slli	s1,s1,0x33
  if((bp->data[bi/8] & m) == 0)
    800033a2:	90d9                	srli	s1,s1,0x36
    800033a4:	00950733          	add	a4,a0,s1
    800033a8:	05874703          	lbu	a4,88(a4)
    800033ac:	00e7f6b3          	and	a3,a5,a4
    800033b0:	c29d                	beqz	a3,800033d6 <bfree+0x60>
    800033b2:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    800033b4:	94aa                	add	s1,s1,a0
    800033b6:	fff7c793          	not	a5,a5
    800033ba:	8f7d                	and	a4,a4,a5
    800033bc:	04e48c23          	sb	a4,88(s1)
  log_write(bp);
    800033c0:	000010ef          	jal	800043c0 <log_write>
  brelse(bp);
    800033c4:	854a                	mv	a0,s2
    800033c6:	eafff0ef          	jal	80003274 <brelse>
}
    800033ca:	60e2                	ld	ra,24(sp)
    800033cc:	6442                	ld	s0,16(sp)
    800033ce:	64a2                	ld	s1,8(sp)
    800033d0:	6902                	ld	s2,0(sp)
    800033d2:	6105                	addi	sp,sp,32
    800033d4:	8082                	ret
    panic("freeing free block");
    800033d6:	00005517          	auipc	a0,0x5
    800033da:	05a50513          	addi	a0,a0,90 # 80008430 <etext+0x430>
    800033de:	c78fd0ef          	jal	80000856 <panic>

00000000800033e2 <balloc>:
{
    800033e2:	715d                	addi	sp,sp,-80
    800033e4:	e486                	sd	ra,72(sp)
    800033e6:	e0a2                	sd	s0,64(sp)
    800033e8:	fc26                	sd	s1,56(sp)
    800033ea:	0880                	addi	s0,sp,80
  for(b = 0; b < sb.size; b += BPB){
    800033ec:	0001c797          	auipc	a5,0x1c
    800033f0:	bc07a783          	lw	a5,-1088(a5) # 8001efac <sb+0x4>
    800033f4:	0e078263          	beqz	a5,800034d8 <balloc+0xf6>
    800033f8:	f84a                	sd	s2,48(sp)
    800033fa:	f44e                	sd	s3,40(sp)
    800033fc:	f052                	sd	s4,32(sp)
    800033fe:	ec56                	sd	s5,24(sp)
    80003400:	e85a                	sd	s6,16(sp)
    80003402:	e45e                	sd	s7,8(sp)
    80003404:	e062                	sd	s8,0(sp)
    80003406:	8baa                	mv	s7,a0
    80003408:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    8000340a:	0001cb17          	auipc	s6,0x1c
    8000340e:	b9eb0b13          	addi	s6,s6,-1122 # 8001efa8 <sb>
      m = 1 << (bi % 8);
    80003412:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003414:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    80003416:	6c09                	lui	s8,0x2
    80003418:	a09d                	j	8000347e <balloc+0x9c>
        bp->data[bi/8] |= m;  // Mark block in use.
    8000341a:	97ca                	add	a5,a5,s2
    8000341c:	8e55                	or	a2,a2,a3
    8000341e:	04c78c23          	sb	a2,88(a5)
        log_write(bp);
    80003422:	854a                	mv	a0,s2
    80003424:	79d000ef          	jal	800043c0 <log_write>
        brelse(bp);
    80003428:	854a                	mv	a0,s2
    8000342a:	e4bff0ef          	jal	80003274 <brelse>
  bp = bread(dev, bno);
    8000342e:	85a6                	mv	a1,s1
    80003430:	855e                	mv	a0,s7
    80003432:	d13ff0ef          	jal	80003144 <bread>
    80003436:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    80003438:	40000613          	li	a2,1024
    8000343c:	4581                	li	a1,0
    8000343e:	05850513          	addi	a0,a0,88
    80003442:	9a5fd0ef          	jal	80000de6 <memset>
  log_write(bp);
    80003446:	854a                	mv	a0,s2
    80003448:	779000ef          	jal	800043c0 <log_write>
  brelse(bp);
    8000344c:	854a                	mv	a0,s2
    8000344e:	e27ff0ef          	jal	80003274 <brelse>
}
    80003452:	7942                	ld	s2,48(sp)
    80003454:	79a2                	ld	s3,40(sp)
    80003456:	7a02                	ld	s4,32(sp)
    80003458:	6ae2                	ld	s5,24(sp)
    8000345a:	6b42                	ld	s6,16(sp)
    8000345c:	6ba2                	ld	s7,8(sp)
    8000345e:	6c02                	ld	s8,0(sp)
}
    80003460:	8526                	mv	a0,s1
    80003462:	60a6                	ld	ra,72(sp)
    80003464:	6406                	ld	s0,64(sp)
    80003466:	74e2                	ld	s1,56(sp)
    80003468:	6161                	addi	sp,sp,80
    8000346a:	8082                	ret
    brelse(bp);
    8000346c:	854a                	mv	a0,s2
    8000346e:	e07ff0ef          	jal	80003274 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    80003472:	015c0abb          	addw	s5,s8,s5
    80003476:	004b2783          	lw	a5,4(s6)
    8000347a:	04faf863          	bgeu	s5,a5,800034ca <balloc+0xe8>
    bp = bread(dev, BBLOCK(b, sb));
    8000347e:	40dad59b          	sraiw	a1,s5,0xd
    80003482:	01cb2783          	lw	a5,28(s6)
    80003486:	9dbd                	addw	a1,a1,a5
    80003488:	855e                	mv	a0,s7
    8000348a:	cbbff0ef          	jal	80003144 <bread>
    8000348e:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003490:	004b2503          	lw	a0,4(s6)
    80003494:	84d6                	mv	s1,s5
    80003496:	4701                	li	a4,0
    80003498:	fca4fae3          	bgeu	s1,a0,8000346c <balloc+0x8a>
      m = 1 << (bi % 8);
    8000349c:	00777693          	andi	a3,a4,7
    800034a0:	00d996bb          	sllw	a3,s3,a3
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    800034a4:	41f7579b          	sraiw	a5,a4,0x1f
    800034a8:	01d7d79b          	srliw	a5,a5,0x1d
    800034ac:	9fb9                	addw	a5,a5,a4
    800034ae:	4037d79b          	sraiw	a5,a5,0x3
    800034b2:	00f90633          	add	a2,s2,a5
    800034b6:	05864603          	lbu	a2,88(a2)
    800034ba:	00c6f5b3          	and	a1,a3,a2
    800034be:	ddb1                	beqz	a1,8000341a <balloc+0x38>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800034c0:	2705                	addiw	a4,a4,1
    800034c2:	2485                	addiw	s1,s1,1
    800034c4:	fd471ae3          	bne	a4,s4,80003498 <balloc+0xb6>
    800034c8:	b755                	j	8000346c <balloc+0x8a>
    800034ca:	7942                	ld	s2,48(sp)
    800034cc:	79a2                	ld	s3,40(sp)
    800034ce:	7a02                	ld	s4,32(sp)
    800034d0:	6ae2                	ld	s5,24(sp)
    800034d2:	6b42                	ld	s6,16(sp)
    800034d4:	6ba2                	ld	s7,8(sp)
    800034d6:	6c02                	ld	s8,0(sp)
  printf("balloc: out of blocks\n");
    800034d8:	00005517          	auipc	a0,0x5
    800034dc:	f7050513          	addi	a0,a0,-144 # 80008448 <etext+0x448>
    800034e0:	84cfd0ef          	jal	8000052c <printf>
  return 0;
    800034e4:	4481                	li	s1,0
    800034e6:	bfad                	j	80003460 <balloc+0x7e>

00000000800034e8 <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    800034e8:	7179                	addi	sp,sp,-48
    800034ea:	f406                	sd	ra,40(sp)
    800034ec:	f022                	sd	s0,32(sp)
    800034ee:	ec26                	sd	s1,24(sp)
    800034f0:	e84a                	sd	s2,16(sp)
    800034f2:	e44e                	sd	s3,8(sp)
    800034f4:	1800                	addi	s0,sp,48
    800034f6:	892a                	mv	s2,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    800034f8:	47ad                	li	a5,11
    800034fa:	02b7e363          	bltu	a5,a1,80003520 <bmap+0x38>
    if((addr = ip->addrs[bn]) == 0){
    800034fe:	02059793          	slli	a5,a1,0x20
    80003502:	01e7d593          	srli	a1,a5,0x1e
    80003506:	00b509b3          	add	s3,a0,a1
    8000350a:	0509a483          	lw	s1,80(s3)
    8000350e:	e0b5                	bnez	s1,80003572 <bmap+0x8a>
      addr = balloc(ip->dev);
    80003510:	4108                	lw	a0,0(a0)
    80003512:	ed1ff0ef          	jal	800033e2 <balloc>
    80003516:	84aa                	mv	s1,a0
      if(addr == 0)
    80003518:	cd29                	beqz	a0,80003572 <bmap+0x8a>
        return 0;
      ip->addrs[bn] = addr;
    8000351a:	04a9a823          	sw	a0,80(s3)
    8000351e:	a891                	j	80003572 <bmap+0x8a>
    }
    return addr;
  }
  bn -= NDIRECT;
    80003520:	ff45879b          	addiw	a5,a1,-12
    80003524:	873e                	mv	a4,a5
    80003526:	89be                	mv	s3,a5

  if(bn < NINDIRECT){
    80003528:	0ff00793          	li	a5,255
    8000352c:	06e7e763          	bltu	a5,a4,8000359a <bmap+0xb2>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    80003530:	08052483          	lw	s1,128(a0)
    80003534:	e891                	bnez	s1,80003548 <bmap+0x60>
      addr = balloc(ip->dev);
    80003536:	4108                	lw	a0,0(a0)
    80003538:	eabff0ef          	jal	800033e2 <balloc>
    8000353c:	84aa                	mv	s1,a0
      if(addr == 0)
    8000353e:	c915                	beqz	a0,80003572 <bmap+0x8a>
    80003540:	e052                	sd	s4,0(sp)
        return 0;
      ip->addrs[NDIRECT] = addr;
    80003542:	08a92023          	sw	a0,128(s2)
    80003546:	a011                	j	8000354a <bmap+0x62>
    80003548:	e052                	sd	s4,0(sp)
    }
    bp = bread(ip->dev, addr);
    8000354a:	85a6                	mv	a1,s1
    8000354c:	00092503          	lw	a0,0(s2)
    80003550:	bf5ff0ef          	jal	80003144 <bread>
    80003554:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    80003556:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    8000355a:	02099713          	slli	a4,s3,0x20
    8000355e:	01e75593          	srli	a1,a4,0x1e
    80003562:	97ae                	add	a5,a5,a1
    80003564:	89be                	mv	s3,a5
    80003566:	4384                	lw	s1,0(a5)
    80003568:	cc89                	beqz	s1,80003582 <bmap+0x9a>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    8000356a:	8552                	mv	a0,s4
    8000356c:	d09ff0ef          	jal	80003274 <brelse>
    return addr;
    80003570:	6a02                	ld	s4,0(sp)
  }

  panic("bmap: out of range");
}
    80003572:	8526                	mv	a0,s1
    80003574:	70a2                	ld	ra,40(sp)
    80003576:	7402                	ld	s0,32(sp)
    80003578:	64e2                	ld	s1,24(sp)
    8000357a:	6942                	ld	s2,16(sp)
    8000357c:	69a2                	ld	s3,8(sp)
    8000357e:	6145                	addi	sp,sp,48
    80003580:	8082                	ret
      addr = balloc(ip->dev);
    80003582:	00092503          	lw	a0,0(s2)
    80003586:	e5dff0ef          	jal	800033e2 <balloc>
    8000358a:	84aa                	mv	s1,a0
      if(addr){
    8000358c:	dd79                	beqz	a0,8000356a <bmap+0x82>
        a[bn] = addr;
    8000358e:	00a9a023          	sw	a0,0(s3)
        log_write(bp);
    80003592:	8552                	mv	a0,s4
    80003594:	62d000ef          	jal	800043c0 <log_write>
    80003598:	bfc9                	j	8000356a <bmap+0x82>
    8000359a:	e052                	sd	s4,0(sp)
  panic("bmap: out of range");
    8000359c:	00005517          	auipc	a0,0x5
    800035a0:	ec450513          	addi	a0,a0,-316 # 80008460 <etext+0x460>
    800035a4:	ab2fd0ef          	jal	80000856 <panic>

00000000800035a8 <iget>:
{
    800035a8:	7179                	addi	sp,sp,-48
    800035aa:	f406                	sd	ra,40(sp)
    800035ac:	f022                	sd	s0,32(sp)
    800035ae:	ec26                	sd	s1,24(sp)
    800035b0:	e84a                	sd	s2,16(sp)
    800035b2:	e44e                	sd	s3,8(sp)
    800035b4:	e052                	sd	s4,0(sp)
    800035b6:	1800                	addi	s0,sp,48
    800035b8:	892a                	mv	s2,a0
    800035ba:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    800035bc:	0001c517          	auipc	a0,0x1c
    800035c0:	a0c50513          	addi	a0,a0,-1524 # 8001efc8 <itable>
    800035c4:	f52fd0ef          	jal	80000d16 <acquire>
  empty = 0;
    800035c8:	4981                	li	s3,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    800035ca:	0001c497          	auipc	s1,0x1c
    800035ce:	a1648493          	addi	s1,s1,-1514 # 8001efe0 <itable+0x18>
    800035d2:	0001d697          	auipc	a3,0x1d
    800035d6:	49e68693          	addi	a3,a3,1182 # 80020a70 <log>
    800035da:	a809                	j	800035ec <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    800035dc:	e781                	bnez	a5,800035e4 <iget+0x3c>
    800035de:	00099363          	bnez	s3,800035e4 <iget+0x3c>
      empty = ip;
    800035e2:	89a6                	mv	s3,s1
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    800035e4:	08848493          	addi	s1,s1,136
    800035e8:	02d48563          	beq	s1,a3,80003612 <iget+0x6a>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    800035ec:	449c                	lw	a5,8(s1)
    800035ee:	fef057e3          	blez	a5,800035dc <iget+0x34>
    800035f2:	4098                	lw	a4,0(s1)
    800035f4:	ff2718e3          	bne	a4,s2,800035e4 <iget+0x3c>
    800035f8:	40d8                	lw	a4,4(s1)
    800035fa:	ff4715e3          	bne	a4,s4,800035e4 <iget+0x3c>
      ip->ref++;
    800035fe:	2785                	addiw	a5,a5,1
    80003600:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    80003602:	0001c517          	auipc	a0,0x1c
    80003606:	9c650513          	addi	a0,a0,-1594 # 8001efc8 <itable>
    8000360a:	fa0fd0ef          	jal	80000daa <release>
      return ip;
    8000360e:	89a6                	mv	s3,s1
    80003610:	a015                	j	80003634 <iget+0x8c>
  if(empty == 0)
    80003612:	02098a63          	beqz	s3,80003646 <iget+0x9e>
  ip->dev = dev;
    80003616:	0129a023          	sw	s2,0(s3)
  ip->inum = inum;
    8000361a:	0149a223          	sw	s4,4(s3)
  ip->ref = 1;
    8000361e:	4785                	li	a5,1
    80003620:	00f9a423          	sw	a5,8(s3)
  ip->valid = 0;
    80003624:	0409a023          	sw	zero,64(s3)
  release(&itable.lock);
    80003628:	0001c517          	auipc	a0,0x1c
    8000362c:	9a050513          	addi	a0,a0,-1632 # 8001efc8 <itable>
    80003630:	f7afd0ef          	jal	80000daa <release>
}
    80003634:	854e                	mv	a0,s3
    80003636:	70a2                	ld	ra,40(sp)
    80003638:	7402                	ld	s0,32(sp)
    8000363a:	64e2                	ld	s1,24(sp)
    8000363c:	6942                	ld	s2,16(sp)
    8000363e:	69a2                	ld	s3,8(sp)
    80003640:	6a02                	ld	s4,0(sp)
    80003642:	6145                	addi	sp,sp,48
    80003644:	8082                	ret
    panic("iget: no inodes");
    80003646:	00005517          	auipc	a0,0x5
    8000364a:	e3250513          	addi	a0,a0,-462 # 80008478 <etext+0x478>
    8000364e:	a08fd0ef          	jal	80000856 <panic>

0000000080003652 <iinit>:
{
    80003652:	7179                	addi	sp,sp,-48
    80003654:	f406                	sd	ra,40(sp)
    80003656:	f022                	sd	s0,32(sp)
    80003658:	ec26                	sd	s1,24(sp)
    8000365a:	e84a                	sd	s2,16(sp)
    8000365c:	e44e                	sd	s3,8(sp)
    8000365e:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    80003660:	00005597          	auipc	a1,0x5
    80003664:	e2858593          	addi	a1,a1,-472 # 80008488 <etext+0x488>
    80003668:	0001c517          	auipc	a0,0x1c
    8000366c:	96050513          	addi	a0,a0,-1696 # 8001efc8 <itable>
    80003670:	e1cfd0ef          	jal	80000c8c <initlock>
  for(i = 0; i < NINODE; i++) {
    80003674:	0001c497          	auipc	s1,0x1c
    80003678:	97c48493          	addi	s1,s1,-1668 # 8001eff0 <itable+0x28>
    8000367c:	0001d997          	auipc	s3,0x1d
    80003680:	40498993          	addi	s3,s3,1028 # 80020a80 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    80003684:	00005917          	auipc	s2,0x5
    80003688:	e0c90913          	addi	s2,s2,-500 # 80008490 <etext+0x490>
    8000368c:	85ca                	mv	a1,s2
    8000368e:	8526                	mv	a0,s1
    80003690:	5f5000ef          	jal	80004484 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    80003694:	08848493          	addi	s1,s1,136
    80003698:	ff349ae3          	bne	s1,s3,8000368c <iinit+0x3a>
}
    8000369c:	70a2                	ld	ra,40(sp)
    8000369e:	7402                	ld	s0,32(sp)
    800036a0:	64e2                	ld	s1,24(sp)
    800036a2:	6942                	ld	s2,16(sp)
    800036a4:	69a2                	ld	s3,8(sp)
    800036a6:	6145                	addi	sp,sp,48
    800036a8:	8082                	ret

00000000800036aa <ialloc>:
{
    800036aa:	7139                	addi	sp,sp,-64
    800036ac:	fc06                	sd	ra,56(sp)
    800036ae:	f822                	sd	s0,48(sp)
    800036b0:	0080                	addi	s0,sp,64
  for(inum = 1; inum < sb.ninodes; inum++){
    800036b2:	0001c717          	auipc	a4,0x1c
    800036b6:	90272703          	lw	a4,-1790(a4) # 8001efb4 <sb+0xc>
    800036ba:	4785                	li	a5,1
    800036bc:	06e7f063          	bgeu	a5,a4,8000371c <ialloc+0x72>
    800036c0:	f426                	sd	s1,40(sp)
    800036c2:	f04a                	sd	s2,32(sp)
    800036c4:	ec4e                	sd	s3,24(sp)
    800036c6:	e852                	sd	s4,16(sp)
    800036c8:	e456                	sd	s5,8(sp)
    800036ca:	e05a                	sd	s6,0(sp)
    800036cc:	8aaa                	mv	s5,a0
    800036ce:	8b2e                	mv	s6,a1
    800036d0:	893e                	mv	s2,a5
    bp = bread(dev, IBLOCK(inum, sb));
    800036d2:	0001ca17          	auipc	s4,0x1c
    800036d6:	8d6a0a13          	addi	s4,s4,-1834 # 8001efa8 <sb>
    800036da:	00495593          	srli	a1,s2,0x4
    800036de:	018a2783          	lw	a5,24(s4)
    800036e2:	9dbd                	addw	a1,a1,a5
    800036e4:	8556                	mv	a0,s5
    800036e6:	a5fff0ef          	jal	80003144 <bread>
    800036ea:	84aa                	mv	s1,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    800036ec:	05850993          	addi	s3,a0,88
    800036f0:	00f97793          	andi	a5,s2,15
    800036f4:	079a                	slli	a5,a5,0x6
    800036f6:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    800036f8:	00099783          	lh	a5,0(s3)
    800036fc:	cb9d                	beqz	a5,80003732 <ialloc+0x88>
    brelse(bp);
    800036fe:	b77ff0ef          	jal	80003274 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    80003702:	0905                	addi	s2,s2,1
    80003704:	00ca2703          	lw	a4,12(s4)
    80003708:	0009079b          	sext.w	a5,s2
    8000370c:	fce7e7e3          	bltu	a5,a4,800036da <ialloc+0x30>
    80003710:	74a2                	ld	s1,40(sp)
    80003712:	7902                	ld	s2,32(sp)
    80003714:	69e2                	ld	s3,24(sp)
    80003716:	6a42                	ld	s4,16(sp)
    80003718:	6aa2                	ld	s5,8(sp)
    8000371a:	6b02                	ld	s6,0(sp)
  printf("ialloc: no inodes\n");
    8000371c:	00005517          	auipc	a0,0x5
    80003720:	d7c50513          	addi	a0,a0,-644 # 80008498 <etext+0x498>
    80003724:	e09fc0ef          	jal	8000052c <printf>
  return 0;
    80003728:	4501                	li	a0,0
}
    8000372a:	70e2                	ld	ra,56(sp)
    8000372c:	7442                	ld	s0,48(sp)
    8000372e:	6121                	addi	sp,sp,64
    80003730:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    80003732:	04000613          	li	a2,64
    80003736:	4581                	li	a1,0
    80003738:	854e                	mv	a0,s3
    8000373a:	eacfd0ef          	jal	80000de6 <memset>
      dip->type = type;
    8000373e:	01699023          	sh	s6,0(s3)
      log_write(bp);   // mark it allocated on the disk
    80003742:	8526                	mv	a0,s1
    80003744:	47d000ef          	jal	800043c0 <log_write>
      brelse(bp);
    80003748:	8526                	mv	a0,s1
    8000374a:	b2bff0ef          	jal	80003274 <brelse>
      return iget(dev, inum);
    8000374e:	0009059b          	sext.w	a1,s2
    80003752:	8556                	mv	a0,s5
    80003754:	e55ff0ef          	jal	800035a8 <iget>
    80003758:	74a2                	ld	s1,40(sp)
    8000375a:	7902                	ld	s2,32(sp)
    8000375c:	69e2                	ld	s3,24(sp)
    8000375e:	6a42                	ld	s4,16(sp)
    80003760:	6aa2                	ld	s5,8(sp)
    80003762:	6b02                	ld	s6,0(sp)
    80003764:	b7d9                	j	8000372a <ialloc+0x80>

0000000080003766 <iupdate>:
{
    80003766:	1101                	addi	sp,sp,-32
    80003768:	ec06                	sd	ra,24(sp)
    8000376a:	e822                	sd	s0,16(sp)
    8000376c:	e426                	sd	s1,8(sp)
    8000376e:	e04a                	sd	s2,0(sp)
    80003770:	1000                	addi	s0,sp,32
    80003772:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003774:	415c                	lw	a5,4(a0)
    80003776:	0047d79b          	srliw	a5,a5,0x4
    8000377a:	0001c597          	auipc	a1,0x1c
    8000377e:	8465a583          	lw	a1,-1978(a1) # 8001efc0 <sb+0x18>
    80003782:	9dbd                	addw	a1,a1,a5
    80003784:	4108                	lw	a0,0(a0)
    80003786:	9bfff0ef          	jal	80003144 <bread>
    8000378a:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    8000378c:	05850793          	addi	a5,a0,88
    80003790:	40d8                	lw	a4,4(s1)
    80003792:	8b3d                	andi	a4,a4,15
    80003794:	071a                	slli	a4,a4,0x6
    80003796:	97ba                	add	a5,a5,a4
  dip->type = ip->type;
    80003798:	04449703          	lh	a4,68(s1)
    8000379c:	00e79023          	sh	a4,0(a5)
  dip->major = ip->major;
    800037a0:	04649703          	lh	a4,70(s1)
    800037a4:	00e79123          	sh	a4,2(a5)
  dip->minor = ip->minor;
    800037a8:	04849703          	lh	a4,72(s1)
    800037ac:	00e79223          	sh	a4,4(a5)
  dip->nlink = ip->nlink;
    800037b0:	04a49703          	lh	a4,74(s1)
    800037b4:	00e79323          	sh	a4,6(a5)
  dip->size = ip->size;
    800037b8:	44f8                	lw	a4,76(s1)
    800037ba:	c798                	sw	a4,8(a5)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    800037bc:	03400613          	li	a2,52
    800037c0:	05048593          	addi	a1,s1,80
    800037c4:	00c78513          	addi	a0,a5,12
    800037c8:	e7efd0ef          	jal	80000e46 <memmove>
  log_write(bp);
    800037cc:	854a                	mv	a0,s2
    800037ce:	3f3000ef          	jal	800043c0 <log_write>
  brelse(bp);
    800037d2:	854a                	mv	a0,s2
    800037d4:	aa1ff0ef          	jal	80003274 <brelse>
}
    800037d8:	60e2                	ld	ra,24(sp)
    800037da:	6442                	ld	s0,16(sp)
    800037dc:	64a2                	ld	s1,8(sp)
    800037de:	6902                	ld	s2,0(sp)
    800037e0:	6105                	addi	sp,sp,32
    800037e2:	8082                	ret

00000000800037e4 <idup>:
{
    800037e4:	1101                	addi	sp,sp,-32
    800037e6:	ec06                	sd	ra,24(sp)
    800037e8:	e822                	sd	s0,16(sp)
    800037ea:	e426                	sd	s1,8(sp)
    800037ec:	1000                	addi	s0,sp,32
    800037ee:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    800037f0:	0001b517          	auipc	a0,0x1b
    800037f4:	7d850513          	addi	a0,a0,2008 # 8001efc8 <itable>
    800037f8:	d1efd0ef          	jal	80000d16 <acquire>
  ip->ref++;
    800037fc:	449c                	lw	a5,8(s1)
    800037fe:	2785                	addiw	a5,a5,1
    80003800:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003802:	0001b517          	auipc	a0,0x1b
    80003806:	7c650513          	addi	a0,a0,1990 # 8001efc8 <itable>
    8000380a:	da0fd0ef          	jal	80000daa <release>
}
    8000380e:	8526                	mv	a0,s1
    80003810:	60e2                	ld	ra,24(sp)
    80003812:	6442                	ld	s0,16(sp)
    80003814:	64a2                	ld	s1,8(sp)
    80003816:	6105                	addi	sp,sp,32
    80003818:	8082                	ret

000000008000381a <ilock>:
{
    8000381a:	1101                	addi	sp,sp,-32
    8000381c:	ec06                	sd	ra,24(sp)
    8000381e:	e822                	sd	s0,16(sp)
    80003820:	e426                	sd	s1,8(sp)
    80003822:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    80003824:	cd19                	beqz	a0,80003842 <ilock+0x28>
    80003826:	84aa                	mv	s1,a0
    80003828:	451c                	lw	a5,8(a0)
    8000382a:	00f05c63          	blez	a5,80003842 <ilock+0x28>
  acquiresleep(&ip->lock);
    8000382e:	0541                	addi	a0,a0,16
    80003830:	48b000ef          	jal	800044ba <acquiresleep>
  if(ip->valid == 0){
    80003834:	40bc                	lw	a5,64(s1)
    80003836:	cf89                	beqz	a5,80003850 <ilock+0x36>
}
    80003838:	60e2                	ld	ra,24(sp)
    8000383a:	6442                	ld	s0,16(sp)
    8000383c:	64a2                	ld	s1,8(sp)
    8000383e:	6105                	addi	sp,sp,32
    80003840:	8082                	ret
    80003842:	e04a                	sd	s2,0(sp)
    panic("ilock");
    80003844:	00005517          	auipc	a0,0x5
    80003848:	c6c50513          	addi	a0,a0,-916 # 800084b0 <etext+0x4b0>
    8000384c:	80afd0ef          	jal	80000856 <panic>
    80003850:	e04a                	sd	s2,0(sp)
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003852:	40dc                	lw	a5,4(s1)
    80003854:	0047d79b          	srliw	a5,a5,0x4
    80003858:	0001b597          	auipc	a1,0x1b
    8000385c:	7685a583          	lw	a1,1896(a1) # 8001efc0 <sb+0x18>
    80003860:	9dbd                	addw	a1,a1,a5
    80003862:	4088                	lw	a0,0(s1)
    80003864:	8e1ff0ef          	jal	80003144 <bread>
    80003868:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    8000386a:	05850593          	addi	a1,a0,88
    8000386e:	40dc                	lw	a5,4(s1)
    80003870:	8bbd                	andi	a5,a5,15
    80003872:	079a                	slli	a5,a5,0x6
    80003874:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    80003876:	00059783          	lh	a5,0(a1)
    8000387a:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    8000387e:	00259783          	lh	a5,2(a1)
    80003882:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    80003886:	00459783          	lh	a5,4(a1)
    8000388a:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    8000388e:	00659783          	lh	a5,6(a1)
    80003892:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    80003896:	459c                	lw	a5,8(a1)
    80003898:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    8000389a:	03400613          	li	a2,52
    8000389e:	05b1                	addi	a1,a1,12
    800038a0:	05048513          	addi	a0,s1,80
    800038a4:	da2fd0ef          	jal	80000e46 <memmove>
    brelse(bp);
    800038a8:	854a                	mv	a0,s2
    800038aa:	9cbff0ef          	jal	80003274 <brelse>
    ip->valid = 1;
    800038ae:	4785                	li	a5,1
    800038b0:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    800038b2:	04449783          	lh	a5,68(s1)
    800038b6:	c399                	beqz	a5,800038bc <ilock+0xa2>
    800038b8:	6902                	ld	s2,0(sp)
    800038ba:	bfbd                	j	80003838 <ilock+0x1e>
      panic("ilock: no type");
    800038bc:	00005517          	auipc	a0,0x5
    800038c0:	bfc50513          	addi	a0,a0,-1028 # 800084b8 <etext+0x4b8>
    800038c4:	f93fc0ef          	jal	80000856 <panic>

00000000800038c8 <iunlock>:
{
    800038c8:	1101                	addi	sp,sp,-32
    800038ca:	ec06                	sd	ra,24(sp)
    800038cc:	e822                	sd	s0,16(sp)
    800038ce:	e426                	sd	s1,8(sp)
    800038d0:	e04a                	sd	s2,0(sp)
    800038d2:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    800038d4:	c505                	beqz	a0,800038fc <iunlock+0x34>
    800038d6:	84aa                	mv	s1,a0
    800038d8:	01050913          	addi	s2,a0,16
    800038dc:	854a                	mv	a0,s2
    800038de:	45b000ef          	jal	80004538 <holdingsleep>
    800038e2:	cd09                	beqz	a0,800038fc <iunlock+0x34>
    800038e4:	449c                	lw	a5,8(s1)
    800038e6:	00f05b63          	blez	a5,800038fc <iunlock+0x34>
  releasesleep(&ip->lock);
    800038ea:	854a                	mv	a0,s2
    800038ec:	415000ef          	jal	80004500 <releasesleep>
}
    800038f0:	60e2                	ld	ra,24(sp)
    800038f2:	6442                	ld	s0,16(sp)
    800038f4:	64a2                	ld	s1,8(sp)
    800038f6:	6902                	ld	s2,0(sp)
    800038f8:	6105                	addi	sp,sp,32
    800038fa:	8082                	ret
    panic("iunlock");
    800038fc:	00005517          	auipc	a0,0x5
    80003900:	bcc50513          	addi	a0,a0,-1076 # 800084c8 <etext+0x4c8>
    80003904:	f53fc0ef          	jal	80000856 <panic>

0000000080003908 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    80003908:	7179                	addi	sp,sp,-48
    8000390a:	f406                	sd	ra,40(sp)
    8000390c:	f022                	sd	s0,32(sp)
    8000390e:	ec26                	sd	s1,24(sp)
    80003910:	e84a                	sd	s2,16(sp)
    80003912:	e44e                	sd	s3,8(sp)
    80003914:	1800                	addi	s0,sp,48
    80003916:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    80003918:	05050493          	addi	s1,a0,80
    8000391c:	08050913          	addi	s2,a0,128
    80003920:	a021                	j	80003928 <itrunc+0x20>
    80003922:	0491                	addi	s1,s1,4
    80003924:	01248b63          	beq	s1,s2,8000393a <itrunc+0x32>
    if(ip->addrs[i]){
    80003928:	408c                	lw	a1,0(s1)
    8000392a:	dde5                	beqz	a1,80003922 <itrunc+0x1a>
      bfree(ip->dev, ip->addrs[i]);
    8000392c:	0009a503          	lw	a0,0(s3)
    80003930:	a47ff0ef          	jal	80003376 <bfree>
      ip->addrs[i] = 0;
    80003934:	0004a023          	sw	zero,0(s1)
    80003938:	b7ed                	j	80003922 <itrunc+0x1a>
    }
  }

  if(ip->addrs[NDIRECT]){
    8000393a:	0809a583          	lw	a1,128(s3)
    8000393e:	ed89                	bnez	a1,80003958 <itrunc+0x50>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80003940:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    80003944:	854e                	mv	a0,s3
    80003946:	e21ff0ef          	jal	80003766 <iupdate>
}
    8000394a:	70a2                	ld	ra,40(sp)
    8000394c:	7402                	ld	s0,32(sp)
    8000394e:	64e2                	ld	s1,24(sp)
    80003950:	6942                	ld	s2,16(sp)
    80003952:	69a2                	ld	s3,8(sp)
    80003954:	6145                	addi	sp,sp,48
    80003956:	8082                	ret
    80003958:	e052                	sd	s4,0(sp)
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    8000395a:	0009a503          	lw	a0,0(s3)
    8000395e:	fe6ff0ef          	jal	80003144 <bread>
    80003962:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    80003964:	05850493          	addi	s1,a0,88
    80003968:	45850913          	addi	s2,a0,1112
    8000396c:	a021                	j	80003974 <itrunc+0x6c>
    8000396e:	0491                	addi	s1,s1,4
    80003970:	01248963          	beq	s1,s2,80003982 <itrunc+0x7a>
      if(a[j])
    80003974:	408c                	lw	a1,0(s1)
    80003976:	dde5                	beqz	a1,8000396e <itrunc+0x66>
        bfree(ip->dev, a[j]);
    80003978:	0009a503          	lw	a0,0(s3)
    8000397c:	9fbff0ef          	jal	80003376 <bfree>
    80003980:	b7fd                	j	8000396e <itrunc+0x66>
    brelse(bp);
    80003982:	8552                	mv	a0,s4
    80003984:	8f1ff0ef          	jal	80003274 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80003988:	0809a583          	lw	a1,128(s3)
    8000398c:	0009a503          	lw	a0,0(s3)
    80003990:	9e7ff0ef          	jal	80003376 <bfree>
    ip->addrs[NDIRECT] = 0;
    80003994:	0809a023          	sw	zero,128(s3)
    80003998:	6a02                	ld	s4,0(sp)
    8000399a:	b75d                	j	80003940 <itrunc+0x38>

000000008000399c <iput>:
{
    8000399c:	1101                	addi	sp,sp,-32
    8000399e:	ec06                	sd	ra,24(sp)
    800039a0:	e822                	sd	s0,16(sp)
    800039a2:	e426                	sd	s1,8(sp)
    800039a4:	1000                	addi	s0,sp,32
    800039a6:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    800039a8:	0001b517          	auipc	a0,0x1b
    800039ac:	62050513          	addi	a0,a0,1568 # 8001efc8 <itable>
    800039b0:	b66fd0ef          	jal	80000d16 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    800039b4:	4498                	lw	a4,8(s1)
    800039b6:	4785                	li	a5,1
    800039b8:	02f70063          	beq	a4,a5,800039d8 <iput+0x3c>
  ip->ref--;
    800039bc:	449c                	lw	a5,8(s1)
    800039be:	37fd                	addiw	a5,a5,-1
    800039c0:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    800039c2:	0001b517          	auipc	a0,0x1b
    800039c6:	60650513          	addi	a0,a0,1542 # 8001efc8 <itable>
    800039ca:	be0fd0ef          	jal	80000daa <release>
}
    800039ce:	60e2                	ld	ra,24(sp)
    800039d0:	6442                	ld	s0,16(sp)
    800039d2:	64a2                	ld	s1,8(sp)
    800039d4:	6105                	addi	sp,sp,32
    800039d6:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    800039d8:	40bc                	lw	a5,64(s1)
    800039da:	d3ed                	beqz	a5,800039bc <iput+0x20>
    800039dc:	04a49783          	lh	a5,74(s1)
    800039e0:	fff1                	bnez	a5,800039bc <iput+0x20>
    800039e2:	e04a                	sd	s2,0(sp)
    acquiresleep(&ip->lock);
    800039e4:	01048793          	addi	a5,s1,16
    800039e8:	893e                	mv	s2,a5
    800039ea:	853e                	mv	a0,a5
    800039ec:	2cf000ef          	jal	800044ba <acquiresleep>
    release(&itable.lock);
    800039f0:	0001b517          	auipc	a0,0x1b
    800039f4:	5d850513          	addi	a0,a0,1496 # 8001efc8 <itable>
    800039f8:	bb2fd0ef          	jal	80000daa <release>
    itrunc(ip);
    800039fc:	8526                	mv	a0,s1
    800039fe:	f0bff0ef          	jal	80003908 <itrunc>
    ip->type = 0;
    80003a02:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    80003a06:	8526                	mv	a0,s1
    80003a08:	d5fff0ef          	jal	80003766 <iupdate>
    ip->valid = 0;
    80003a0c:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80003a10:	854a                	mv	a0,s2
    80003a12:	2ef000ef          	jal	80004500 <releasesleep>
    acquire(&itable.lock);
    80003a16:	0001b517          	auipc	a0,0x1b
    80003a1a:	5b250513          	addi	a0,a0,1458 # 8001efc8 <itable>
    80003a1e:	af8fd0ef          	jal	80000d16 <acquire>
    80003a22:	6902                	ld	s2,0(sp)
    80003a24:	bf61                	j	800039bc <iput+0x20>

0000000080003a26 <iunlockput>:
{
    80003a26:	1101                	addi	sp,sp,-32
    80003a28:	ec06                	sd	ra,24(sp)
    80003a2a:	e822                	sd	s0,16(sp)
    80003a2c:	e426                	sd	s1,8(sp)
    80003a2e:	1000                	addi	s0,sp,32
    80003a30:	84aa                	mv	s1,a0
  iunlock(ip);
    80003a32:	e97ff0ef          	jal	800038c8 <iunlock>
  iput(ip);
    80003a36:	8526                	mv	a0,s1
    80003a38:	f65ff0ef          	jal	8000399c <iput>
}
    80003a3c:	60e2                	ld	ra,24(sp)
    80003a3e:	6442                	ld	s0,16(sp)
    80003a40:	64a2                	ld	s1,8(sp)
    80003a42:	6105                	addi	sp,sp,32
    80003a44:	8082                	ret

0000000080003a46 <ireclaim>:
  for (int inum = 1; inum < sb.ninodes; inum++) {
    80003a46:	0001b717          	auipc	a4,0x1b
    80003a4a:	56e72703          	lw	a4,1390(a4) # 8001efb4 <sb+0xc>
    80003a4e:	4785                	li	a5,1
    80003a50:	0ae7fe63          	bgeu	a5,a4,80003b0c <ireclaim+0xc6>
{
    80003a54:	7139                	addi	sp,sp,-64
    80003a56:	fc06                	sd	ra,56(sp)
    80003a58:	f822                	sd	s0,48(sp)
    80003a5a:	f426                	sd	s1,40(sp)
    80003a5c:	f04a                	sd	s2,32(sp)
    80003a5e:	ec4e                	sd	s3,24(sp)
    80003a60:	e852                	sd	s4,16(sp)
    80003a62:	e456                	sd	s5,8(sp)
    80003a64:	e05a                	sd	s6,0(sp)
    80003a66:	0080                	addi	s0,sp,64
    80003a68:	8aaa                	mv	s5,a0
  for (int inum = 1; inum < sb.ninodes; inum++) {
    80003a6a:	84be                	mv	s1,a5
    struct buf *bp = bread(dev, IBLOCK(inum, sb));
    80003a6c:	0001ba17          	auipc	s4,0x1b
    80003a70:	53ca0a13          	addi	s4,s4,1340 # 8001efa8 <sb>
      printf("ireclaim: orphaned inode %d\n", inum);
    80003a74:	00005b17          	auipc	s6,0x5
    80003a78:	a5cb0b13          	addi	s6,s6,-1444 # 800084d0 <etext+0x4d0>
    80003a7c:	a099                	j	80003ac2 <ireclaim+0x7c>
    80003a7e:	85ce                	mv	a1,s3
    80003a80:	855a                	mv	a0,s6
    80003a82:	aabfc0ef          	jal	8000052c <printf>
      ip = iget(dev, inum);
    80003a86:	85ce                	mv	a1,s3
    80003a88:	8556                	mv	a0,s5
    80003a8a:	b1fff0ef          	jal	800035a8 <iget>
    80003a8e:	89aa                	mv	s3,a0
    brelse(bp);
    80003a90:	854a                	mv	a0,s2
    80003a92:	fe2ff0ef          	jal	80003274 <brelse>
    if (ip) {
    80003a96:	00098f63          	beqz	s3,80003ab4 <ireclaim+0x6e>
      begin_op();
    80003a9a:	78c000ef          	jal	80004226 <begin_op>
      ilock(ip);
    80003a9e:	854e                	mv	a0,s3
    80003aa0:	d7bff0ef          	jal	8000381a <ilock>
      iunlock(ip);
    80003aa4:	854e                	mv	a0,s3
    80003aa6:	e23ff0ef          	jal	800038c8 <iunlock>
      iput(ip);
    80003aaa:	854e                	mv	a0,s3
    80003aac:	ef1ff0ef          	jal	8000399c <iput>
      end_op();
    80003ab0:	7e6000ef          	jal	80004296 <end_op>
  for (int inum = 1; inum < sb.ninodes; inum++) {
    80003ab4:	0485                	addi	s1,s1,1
    80003ab6:	00ca2703          	lw	a4,12(s4)
    80003aba:	0004879b          	sext.w	a5,s1
    80003abe:	02e7fd63          	bgeu	a5,a4,80003af8 <ireclaim+0xb2>
    80003ac2:	0004899b          	sext.w	s3,s1
    struct buf *bp = bread(dev, IBLOCK(inum, sb));
    80003ac6:	0044d593          	srli	a1,s1,0x4
    80003aca:	018a2783          	lw	a5,24(s4)
    80003ace:	9dbd                	addw	a1,a1,a5
    80003ad0:	8556                	mv	a0,s5
    80003ad2:	e72ff0ef          	jal	80003144 <bread>
    80003ad6:	892a                	mv	s2,a0
    struct dinode *dip = (struct dinode *)bp->data + inum % IPB;
    80003ad8:	05850793          	addi	a5,a0,88
    80003adc:	00f9f713          	andi	a4,s3,15
    80003ae0:	071a                	slli	a4,a4,0x6
    80003ae2:	97ba                	add	a5,a5,a4
    if (dip->type != 0 && dip->nlink == 0) {  // is an orphaned inode
    80003ae4:	00079703          	lh	a4,0(a5)
    80003ae8:	c701                	beqz	a4,80003af0 <ireclaim+0xaa>
    80003aea:	00679783          	lh	a5,6(a5)
    80003aee:	dbc1                	beqz	a5,80003a7e <ireclaim+0x38>
    brelse(bp);
    80003af0:	854a                	mv	a0,s2
    80003af2:	f82ff0ef          	jal	80003274 <brelse>
    if (ip) {
    80003af6:	bf7d                	j	80003ab4 <ireclaim+0x6e>
}
    80003af8:	70e2                	ld	ra,56(sp)
    80003afa:	7442                	ld	s0,48(sp)
    80003afc:	74a2                	ld	s1,40(sp)
    80003afe:	7902                	ld	s2,32(sp)
    80003b00:	69e2                	ld	s3,24(sp)
    80003b02:	6a42                	ld	s4,16(sp)
    80003b04:	6aa2                	ld	s5,8(sp)
    80003b06:	6b02                	ld	s6,0(sp)
    80003b08:	6121                	addi	sp,sp,64
    80003b0a:	8082                	ret
    80003b0c:	8082                	ret

0000000080003b0e <fsinit>:
fsinit(int dev) {
    80003b0e:	1101                	addi	sp,sp,-32
    80003b10:	ec06                	sd	ra,24(sp)
    80003b12:	e822                	sd	s0,16(sp)
    80003b14:	e426                	sd	s1,8(sp)
    80003b16:	e04a                	sd	s2,0(sp)
    80003b18:	1000                	addi	s0,sp,32
    80003b1a:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    80003b1c:	4585                	li	a1,1
    80003b1e:	e26ff0ef          	jal	80003144 <bread>
    80003b22:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    80003b24:	02000613          	li	a2,32
    80003b28:	05850593          	addi	a1,a0,88
    80003b2c:	0001b517          	auipc	a0,0x1b
    80003b30:	47c50513          	addi	a0,a0,1148 # 8001efa8 <sb>
    80003b34:	b12fd0ef          	jal	80000e46 <memmove>
  brelse(bp);
    80003b38:	8526                	mv	a0,s1
    80003b3a:	f3aff0ef          	jal	80003274 <brelse>
  if(sb.magic != FSMAGIC)
    80003b3e:	0001b717          	auipc	a4,0x1b
    80003b42:	46a72703          	lw	a4,1130(a4) # 8001efa8 <sb>
    80003b46:	102037b7          	lui	a5,0x10203
    80003b4a:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    80003b4e:	02f71263          	bne	a4,a5,80003b72 <fsinit+0x64>
  initlog(dev, &sb);
    80003b52:	0001b597          	auipc	a1,0x1b
    80003b56:	45658593          	addi	a1,a1,1110 # 8001efa8 <sb>
    80003b5a:	854a                	mv	a0,s2
    80003b5c:	648000ef          	jal	800041a4 <initlog>
  ireclaim(dev);
    80003b60:	854a                	mv	a0,s2
    80003b62:	ee5ff0ef          	jal	80003a46 <ireclaim>
}
    80003b66:	60e2                	ld	ra,24(sp)
    80003b68:	6442                	ld	s0,16(sp)
    80003b6a:	64a2                	ld	s1,8(sp)
    80003b6c:	6902                	ld	s2,0(sp)
    80003b6e:	6105                	addi	sp,sp,32
    80003b70:	8082                	ret
    panic("invalid file system");
    80003b72:	00005517          	auipc	a0,0x5
    80003b76:	97e50513          	addi	a0,a0,-1666 # 800084f0 <etext+0x4f0>
    80003b7a:	cddfc0ef          	jal	80000856 <panic>

0000000080003b7e <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80003b7e:	1141                	addi	sp,sp,-16
    80003b80:	e406                	sd	ra,8(sp)
    80003b82:	e022                	sd	s0,0(sp)
    80003b84:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80003b86:	411c                	lw	a5,0(a0)
    80003b88:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80003b8a:	415c                	lw	a5,4(a0)
    80003b8c:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80003b8e:	04451783          	lh	a5,68(a0)
    80003b92:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80003b96:	04a51783          	lh	a5,74(a0)
    80003b9a:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80003b9e:	04c56783          	lwu	a5,76(a0)
    80003ba2:	e99c                	sd	a5,16(a1)
}
    80003ba4:	60a2                	ld	ra,8(sp)
    80003ba6:	6402                	ld	s0,0(sp)
    80003ba8:	0141                	addi	sp,sp,16
    80003baa:	8082                	ret

0000000080003bac <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003bac:	457c                	lw	a5,76(a0)
    80003bae:	0ed7e663          	bltu	a5,a3,80003c9a <readi+0xee>
{
    80003bb2:	7159                	addi	sp,sp,-112
    80003bb4:	f486                	sd	ra,104(sp)
    80003bb6:	f0a2                	sd	s0,96(sp)
    80003bb8:	eca6                	sd	s1,88(sp)
    80003bba:	e0d2                	sd	s4,64(sp)
    80003bbc:	fc56                	sd	s5,56(sp)
    80003bbe:	f85a                	sd	s6,48(sp)
    80003bc0:	f45e                	sd	s7,40(sp)
    80003bc2:	1880                	addi	s0,sp,112
    80003bc4:	8b2a                	mv	s6,a0
    80003bc6:	8bae                	mv	s7,a1
    80003bc8:	8a32                	mv	s4,a2
    80003bca:	84b6                	mv	s1,a3
    80003bcc:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    80003bce:	9f35                	addw	a4,a4,a3
    return 0;
    80003bd0:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80003bd2:	0ad76b63          	bltu	a4,a3,80003c88 <readi+0xdc>
    80003bd6:	e4ce                	sd	s3,72(sp)
  if(off + n > ip->size)
    80003bd8:	00e7f463          	bgeu	a5,a4,80003be0 <readi+0x34>
    n = ip->size - off;
    80003bdc:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003be0:	080a8b63          	beqz	s5,80003c76 <readi+0xca>
    80003be4:	e8ca                	sd	s2,80(sp)
    80003be6:	f062                	sd	s8,32(sp)
    80003be8:	ec66                	sd	s9,24(sp)
    80003bea:	e86a                	sd	s10,16(sp)
    80003bec:	e46e                	sd	s11,8(sp)
    80003bee:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003bf0:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80003bf4:	5c7d                	li	s8,-1
    80003bf6:	a80d                	j	80003c28 <readi+0x7c>
    80003bf8:	020d1d93          	slli	s11,s10,0x20
    80003bfc:	020ddd93          	srli	s11,s11,0x20
    80003c00:	05890613          	addi	a2,s2,88
    80003c04:	86ee                	mv	a3,s11
    80003c06:	963e                	add	a2,a2,a5
    80003c08:	85d2                	mv	a1,s4
    80003c0a:	855e                	mv	a0,s7
    80003c0c:	bc1fe0ef          	jal	800027cc <either_copyout>
    80003c10:	05850363          	beq	a0,s8,80003c56 <readi+0xaa>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80003c14:	854a                	mv	a0,s2
    80003c16:	e5eff0ef          	jal	80003274 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003c1a:	013d09bb          	addw	s3,s10,s3
    80003c1e:	009d04bb          	addw	s1,s10,s1
    80003c22:	9a6e                	add	s4,s4,s11
    80003c24:	0559f363          	bgeu	s3,s5,80003c6a <readi+0xbe>
    uint addr = bmap(ip, off/BSIZE);
    80003c28:	00a4d59b          	srliw	a1,s1,0xa
    80003c2c:	855a                	mv	a0,s6
    80003c2e:	8bbff0ef          	jal	800034e8 <bmap>
    80003c32:	85aa                	mv	a1,a0
    if(addr == 0)
    80003c34:	c139                	beqz	a0,80003c7a <readi+0xce>
    bp = bread(ip->dev, addr);
    80003c36:	000b2503          	lw	a0,0(s6)
    80003c3a:	d0aff0ef          	jal	80003144 <bread>
    80003c3e:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003c40:	3ff4f793          	andi	a5,s1,1023
    80003c44:	40fc873b          	subw	a4,s9,a5
    80003c48:	413a86bb          	subw	a3,s5,s3
    80003c4c:	8d3a                	mv	s10,a4
    80003c4e:	fae6f5e3          	bgeu	a3,a4,80003bf8 <readi+0x4c>
    80003c52:	8d36                	mv	s10,a3
    80003c54:	b755                	j	80003bf8 <readi+0x4c>
      brelse(bp);
    80003c56:	854a                	mv	a0,s2
    80003c58:	e1cff0ef          	jal	80003274 <brelse>
      tot = -1;
    80003c5c:	59fd                	li	s3,-1
      break;
    80003c5e:	6946                	ld	s2,80(sp)
    80003c60:	7c02                	ld	s8,32(sp)
    80003c62:	6ce2                	ld	s9,24(sp)
    80003c64:	6d42                	ld	s10,16(sp)
    80003c66:	6da2                	ld	s11,8(sp)
    80003c68:	a831                	j	80003c84 <readi+0xd8>
    80003c6a:	6946                	ld	s2,80(sp)
    80003c6c:	7c02                	ld	s8,32(sp)
    80003c6e:	6ce2                	ld	s9,24(sp)
    80003c70:	6d42                	ld	s10,16(sp)
    80003c72:	6da2                	ld	s11,8(sp)
    80003c74:	a801                	j	80003c84 <readi+0xd8>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003c76:	89d6                	mv	s3,s5
    80003c78:	a031                	j	80003c84 <readi+0xd8>
    80003c7a:	6946                	ld	s2,80(sp)
    80003c7c:	7c02                	ld	s8,32(sp)
    80003c7e:	6ce2                	ld	s9,24(sp)
    80003c80:	6d42                	ld	s10,16(sp)
    80003c82:	6da2                	ld	s11,8(sp)
  }
  return tot;
    80003c84:	854e                	mv	a0,s3
    80003c86:	69a6                	ld	s3,72(sp)
}
    80003c88:	70a6                	ld	ra,104(sp)
    80003c8a:	7406                	ld	s0,96(sp)
    80003c8c:	64e6                	ld	s1,88(sp)
    80003c8e:	6a06                	ld	s4,64(sp)
    80003c90:	7ae2                	ld	s5,56(sp)
    80003c92:	7b42                	ld	s6,48(sp)
    80003c94:	7ba2                	ld	s7,40(sp)
    80003c96:	6165                	addi	sp,sp,112
    80003c98:	8082                	ret
    return 0;
    80003c9a:	4501                	li	a0,0
}
    80003c9c:	8082                	ret

0000000080003c9e <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003c9e:	457c                	lw	a5,76(a0)
    80003ca0:	0ed7eb63          	bltu	a5,a3,80003d96 <writei+0xf8>
{
    80003ca4:	7159                	addi	sp,sp,-112
    80003ca6:	f486                	sd	ra,104(sp)
    80003ca8:	f0a2                	sd	s0,96(sp)
    80003caa:	e8ca                	sd	s2,80(sp)
    80003cac:	e0d2                	sd	s4,64(sp)
    80003cae:	fc56                	sd	s5,56(sp)
    80003cb0:	f85a                	sd	s6,48(sp)
    80003cb2:	f45e                	sd	s7,40(sp)
    80003cb4:	1880                	addi	s0,sp,112
    80003cb6:	8aaa                	mv	s5,a0
    80003cb8:	8bae                	mv	s7,a1
    80003cba:	8a32                	mv	s4,a2
    80003cbc:	8936                	mv	s2,a3
    80003cbe:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003cc0:	00e687bb          	addw	a5,a3,a4
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80003cc4:	00043737          	lui	a4,0x43
    80003cc8:	0cf76963          	bltu	a4,a5,80003d9a <writei+0xfc>
    80003ccc:	0cd7e763          	bltu	a5,a3,80003d9a <writei+0xfc>
    80003cd0:	e4ce                	sd	s3,72(sp)
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003cd2:	0a0b0a63          	beqz	s6,80003d86 <writei+0xe8>
    80003cd6:	eca6                	sd	s1,88(sp)
    80003cd8:	f062                	sd	s8,32(sp)
    80003cda:	ec66                	sd	s9,24(sp)
    80003cdc:	e86a                	sd	s10,16(sp)
    80003cde:	e46e                	sd	s11,8(sp)
    80003ce0:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003ce2:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80003ce6:	5c7d                	li	s8,-1
    80003ce8:	a825                	j	80003d20 <writei+0x82>
    80003cea:	020d1d93          	slli	s11,s10,0x20
    80003cee:	020ddd93          	srli	s11,s11,0x20
    80003cf2:	05848513          	addi	a0,s1,88
    80003cf6:	86ee                	mv	a3,s11
    80003cf8:	8652                	mv	a2,s4
    80003cfa:	85de                	mv	a1,s7
    80003cfc:	953e                	add	a0,a0,a5
    80003cfe:	b19fe0ef          	jal	80002816 <either_copyin>
    80003d02:	05850663          	beq	a0,s8,80003d4e <writei+0xb0>
      brelse(bp);
      break;
    }
    log_write(bp);
    80003d06:	8526                	mv	a0,s1
    80003d08:	6b8000ef          	jal	800043c0 <log_write>
    brelse(bp);
    80003d0c:	8526                	mv	a0,s1
    80003d0e:	d66ff0ef          	jal	80003274 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003d12:	013d09bb          	addw	s3,s10,s3
    80003d16:	012d093b          	addw	s2,s10,s2
    80003d1a:	9a6e                	add	s4,s4,s11
    80003d1c:	0369fc63          	bgeu	s3,s6,80003d54 <writei+0xb6>
    uint addr = bmap(ip, off/BSIZE);
    80003d20:	00a9559b          	srliw	a1,s2,0xa
    80003d24:	8556                	mv	a0,s5
    80003d26:	fc2ff0ef          	jal	800034e8 <bmap>
    80003d2a:	85aa                	mv	a1,a0
    if(addr == 0)
    80003d2c:	c505                	beqz	a0,80003d54 <writei+0xb6>
    bp = bread(ip->dev, addr);
    80003d2e:	000aa503          	lw	a0,0(s5)
    80003d32:	c12ff0ef          	jal	80003144 <bread>
    80003d36:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003d38:	3ff97793          	andi	a5,s2,1023
    80003d3c:	40fc873b          	subw	a4,s9,a5
    80003d40:	413b06bb          	subw	a3,s6,s3
    80003d44:	8d3a                	mv	s10,a4
    80003d46:	fae6f2e3          	bgeu	a3,a4,80003cea <writei+0x4c>
    80003d4a:	8d36                	mv	s10,a3
    80003d4c:	bf79                	j	80003cea <writei+0x4c>
      brelse(bp);
    80003d4e:	8526                	mv	a0,s1
    80003d50:	d24ff0ef          	jal	80003274 <brelse>
  }

  if(off > ip->size)
    80003d54:	04caa783          	lw	a5,76(s5)
    80003d58:	0327f963          	bgeu	a5,s2,80003d8a <writei+0xec>
    ip->size = off;
    80003d5c:	052aa623          	sw	s2,76(s5)
    80003d60:	64e6                	ld	s1,88(sp)
    80003d62:	7c02                	ld	s8,32(sp)
    80003d64:	6ce2                	ld	s9,24(sp)
    80003d66:	6d42                	ld	s10,16(sp)
    80003d68:	6da2                	ld	s11,8(sp)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80003d6a:	8556                	mv	a0,s5
    80003d6c:	9fbff0ef          	jal	80003766 <iupdate>

  return tot;
    80003d70:	854e                	mv	a0,s3
    80003d72:	69a6                	ld	s3,72(sp)
}
    80003d74:	70a6                	ld	ra,104(sp)
    80003d76:	7406                	ld	s0,96(sp)
    80003d78:	6946                	ld	s2,80(sp)
    80003d7a:	6a06                	ld	s4,64(sp)
    80003d7c:	7ae2                	ld	s5,56(sp)
    80003d7e:	7b42                	ld	s6,48(sp)
    80003d80:	7ba2                	ld	s7,40(sp)
    80003d82:	6165                	addi	sp,sp,112
    80003d84:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003d86:	89da                	mv	s3,s6
    80003d88:	b7cd                	j	80003d6a <writei+0xcc>
    80003d8a:	64e6                	ld	s1,88(sp)
    80003d8c:	7c02                	ld	s8,32(sp)
    80003d8e:	6ce2                	ld	s9,24(sp)
    80003d90:	6d42                	ld	s10,16(sp)
    80003d92:	6da2                	ld	s11,8(sp)
    80003d94:	bfd9                	j	80003d6a <writei+0xcc>
    return -1;
    80003d96:	557d                	li	a0,-1
}
    80003d98:	8082                	ret
    return -1;
    80003d9a:	557d                	li	a0,-1
    80003d9c:	bfe1                	j	80003d74 <writei+0xd6>

0000000080003d9e <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80003d9e:	1141                	addi	sp,sp,-16
    80003da0:	e406                	sd	ra,8(sp)
    80003da2:	e022                	sd	s0,0(sp)
    80003da4:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80003da6:	4639                	li	a2,14
    80003da8:	912fd0ef          	jal	80000eba <strncmp>
}
    80003dac:	60a2                	ld	ra,8(sp)
    80003dae:	6402                	ld	s0,0(sp)
    80003db0:	0141                	addi	sp,sp,16
    80003db2:	8082                	ret

0000000080003db4 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80003db4:	711d                	addi	sp,sp,-96
    80003db6:	ec86                	sd	ra,88(sp)
    80003db8:	e8a2                	sd	s0,80(sp)
    80003dba:	e4a6                	sd	s1,72(sp)
    80003dbc:	e0ca                	sd	s2,64(sp)
    80003dbe:	fc4e                	sd	s3,56(sp)
    80003dc0:	f852                	sd	s4,48(sp)
    80003dc2:	f456                	sd	s5,40(sp)
    80003dc4:	f05a                	sd	s6,32(sp)
    80003dc6:	ec5e                	sd	s7,24(sp)
    80003dc8:	1080                	addi	s0,sp,96
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80003dca:	04451703          	lh	a4,68(a0)
    80003dce:	4785                	li	a5,1
    80003dd0:	00f71f63          	bne	a4,a5,80003dee <dirlookup+0x3a>
    80003dd4:	892a                	mv	s2,a0
    80003dd6:	8aae                	mv	s5,a1
    80003dd8:	8bb2                	mv	s7,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80003dda:	457c                	lw	a5,76(a0)
    80003ddc:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003dde:	fa040a13          	addi	s4,s0,-96
    80003de2:	49c1                	li	s3,16
      panic("dirlookup read");
    if(de.inum == 0)
      continue;
    if(namecmp(name, de.name) == 0){
    80003de4:	fa240b13          	addi	s6,s0,-94
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80003de8:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003dea:	e39d                	bnez	a5,80003e10 <dirlookup+0x5c>
    80003dec:	a8b9                	j	80003e4a <dirlookup+0x96>
    panic("dirlookup not DIR");
    80003dee:	00004517          	auipc	a0,0x4
    80003df2:	71a50513          	addi	a0,a0,1818 # 80008508 <etext+0x508>
    80003df6:	a61fc0ef          	jal	80000856 <panic>
      panic("dirlookup read");
    80003dfa:	00004517          	auipc	a0,0x4
    80003dfe:	72650513          	addi	a0,a0,1830 # 80008520 <etext+0x520>
    80003e02:	a55fc0ef          	jal	80000856 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003e06:	24c1                	addiw	s1,s1,16
    80003e08:	04c92783          	lw	a5,76(s2)
    80003e0c:	02f4fe63          	bgeu	s1,a5,80003e48 <dirlookup+0x94>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003e10:	874e                	mv	a4,s3
    80003e12:	86a6                	mv	a3,s1
    80003e14:	8652                	mv	a2,s4
    80003e16:	4581                	li	a1,0
    80003e18:	854a                	mv	a0,s2
    80003e1a:	d93ff0ef          	jal	80003bac <readi>
    80003e1e:	fd351ee3          	bne	a0,s3,80003dfa <dirlookup+0x46>
    if(de.inum == 0)
    80003e22:	fa045783          	lhu	a5,-96(s0)
    80003e26:	d3e5                	beqz	a5,80003e06 <dirlookup+0x52>
    if(namecmp(name, de.name) == 0){
    80003e28:	85da                	mv	a1,s6
    80003e2a:	8556                	mv	a0,s5
    80003e2c:	f73ff0ef          	jal	80003d9e <namecmp>
    80003e30:	f979                	bnez	a0,80003e06 <dirlookup+0x52>
      if(poff)
    80003e32:	000b8463          	beqz	s7,80003e3a <dirlookup+0x86>
        *poff = off;
    80003e36:	009ba023          	sw	s1,0(s7)
      return iget(dp->dev, inum);
    80003e3a:	fa045583          	lhu	a1,-96(s0)
    80003e3e:	00092503          	lw	a0,0(s2)
    80003e42:	f66ff0ef          	jal	800035a8 <iget>
    80003e46:	a011                	j	80003e4a <dirlookup+0x96>
  return 0;
    80003e48:	4501                	li	a0,0
}
    80003e4a:	60e6                	ld	ra,88(sp)
    80003e4c:	6446                	ld	s0,80(sp)
    80003e4e:	64a6                	ld	s1,72(sp)
    80003e50:	6906                	ld	s2,64(sp)
    80003e52:	79e2                	ld	s3,56(sp)
    80003e54:	7a42                	ld	s4,48(sp)
    80003e56:	7aa2                	ld	s5,40(sp)
    80003e58:	7b02                	ld	s6,32(sp)
    80003e5a:	6be2                	ld	s7,24(sp)
    80003e5c:	6125                	addi	sp,sp,96
    80003e5e:	8082                	ret

0000000080003e60 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80003e60:	711d                	addi	sp,sp,-96
    80003e62:	ec86                	sd	ra,88(sp)
    80003e64:	e8a2                	sd	s0,80(sp)
    80003e66:	e4a6                	sd	s1,72(sp)
    80003e68:	e0ca                	sd	s2,64(sp)
    80003e6a:	fc4e                	sd	s3,56(sp)
    80003e6c:	f852                	sd	s4,48(sp)
    80003e6e:	f456                	sd	s5,40(sp)
    80003e70:	f05a                	sd	s6,32(sp)
    80003e72:	ec5e                	sd	s7,24(sp)
    80003e74:	e862                	sd	s8,16(sp)
    80003e76:	e466                	sd	s9,8(sp)
    80003e78:	e06a                	sd	s10,0(sp)
    80003e7a:	1080                	addi	s0,sp,96
    80003e7c:	84aa                	mv	s1,a0
    80003e7e:	8b2e                	mv	s6,a1
    80003e80:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    80003e82:	00054703          	lbu	a4,0(a0)
    80003e86:	02f00793          	li	a5,47
    80003e8a:	00f70f63          	beq	a4,a5,80003ea8 <namex+0x48>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80003e8e:	d9bfd0ef          	jal	80001c28 <myproc>
    80003e92:	15053503          	ld	a0,336(a0)
    80003e96:	94fff0ef          	jal	800037e4 <idup>
    80003e9a:	8a2a                	mv	s4,a0
  while(*path == '/')
    80003e9c:	02f00993          	li	s3,47
  if(len >= DIRSIZ)
    80003ea0:	4c35                	li	s8,13
    memmove(name, s, DIRSIZ);
    80003ea2:	4cb9                	li	s9,14

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80003ea4:	4b85                	li	s7,1
    80003ea6:	a879                	j	80003f44 <namex+0xe4>
    ip = iget(ROOTDEV, ROOTINO);
    80003ea8:	4585                	li	a1,1
    80003eaa:	852e                	mv	a0,a1
    80003eac:	efcff0ef          	jal	800035a8 <iget>
    80003eb0:	8a2a                	mv	s4,a0
    80003eb2:	b7ed                	j	80003e9c <namex+0x3c>
      iunlockput(ip);
    80003eb4:	8552                	mv	a0,s4
    80003eb6:	b71ff0ef          	jal	80003a26 <iunlockput>
      return 0;
    80003eba:	4a01                	li	s4,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80003ebc:	8552                	mv	a0,s4
    80003ebe:	60e6                	ld	ra,88(sp)
    80003ec0:	6446                	ld	s0,80(sp)
    80003ec2:	64a6                	ld	s1,72(sp)
    80003ec4:	6906                	ld	s2,64(sp)
    80003ec6:	79e2                	ld	s3,56(sp)
    80003ec8:	7a42                	ld	s4,48(sp)
    80003eca:	7aa2                	ld	s5,40(sp)
    80003ecc:	7b02                	ld	s6,32(sp)
    80003ece:	6be2                	ld	s7,24(sp)
    80003ed0:	6c42                	ld	s8,16(sp)
    80003ed2:	6ca2                	ld	s9,8(sp)
    80003ed4:	6d02                	ld	s10,0(sp)
    80003ed6:	6125                	addi	sp,sp,96
    80003ed8:	8082                	ret
      iunlock(ip);
    80003eda:	8552                	mv	a0,s4
    80003edc:	9edff0ef          	jal	800038c8 <iunlock>
      return ip;
    80003ee0:	bff1                	j	80003ebc <namex+0x5c>
      iunlockput(ip);
    80003ee2:	8552                	mv	a0,s4
    80003ee4:	b43ff0ef          	jal	80003a26 <iunlockput>
      return 0;
    80003ee8:	8a4a                	mv	s4,s2
    80003eea:	bfc9                	j	80003ebc <namex+0x5c>
  len = path - s;
    80003eec:	40990633          	sub	a2,s2,s1
    80003ef0:	00060d1b          	sext.w	s10,a2
  if(len >= DIRSIZ)
    80003ef4:	09ac5463          	bge	s8,s10,80003f7c <namex+0x11c>
    memmove(name, s, DIRSIZ);
    80003ef8:	8666                	mv	a2,s9
    80003efa:	85a6                	mv	a1,s1
    80003efc:	8556                	mv	a0,s5
    80003efe:	f49fc0ef          	jal	80000e46 <memmove>
    80003f02:	84ca                	mv	s1,s2
  while(*path == '/')
    80003f04:	0004c783          	lbu	a5,0(s1)
    80003f08:	01379763          	bne	a5,s3,80003f16 <namex+0xb6>
    path++;
    80003f0c:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003f0e:	0004c783          	lbu	a5,0(s1)
    80003f12:	ff378de3          	beq	a5,s3,80003f0c <namex+0xac>
    ilock(ip);
    80003f16:	8552                	mv	a0,s4
    80003f18:	903ff0ef          	jal	8000381a <ilock>
    if(ip->type != T_DIR){
    80003f1c:	044a1783          	lh	a5,68(s4)
    80003f20:	f9779ae3          	bne	a5,s7,80003eb4 <namex+0x54>
    if(nameiparent && *path == '\0'){
    80003f24:	000b0563          	beqz	s6,80003f2e <namex+0xce>
    80003f28:	0004c783          	lbu	a5,0(s1)
    80003f2c:	d7dd                	beqz	a5,80003eda <namex+0x7a>
    if((next = dirlookup(ip, name, 0)) == 0){
    80003f2e:	4601                	li	a2,0
    80003f30:	85d6                	mv	a1,s5
    80003f32:	8552                	mv	a0,s4
    80003f34:	e81ff0ef          	jal	80003db4 <dirlookup>
    80003f38:	892a                	mv	s2,a0
    80003f3a:	d545                	beqz	a0,80003ee2 <namex+0x82>
    iunlockput(ip);
    80003f3c:	8552                	mv	a0,s4
    80003f3e:	ae9ff0ef          	jal	80003a26 <iunlockput>
    ip = next;
    80003f42:	8a4a                	mv	s4,s2
  while(*path == '/')
    80003f44:	0004c783          	lbu	a5,0(s1)
    80003f48:	01379763          	bne	a5,s3,80003f56 <namex+0xf6>
    path++;
    80003f4c:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003f4e:	0004c783          	lbu	a5,0(s1)
    80003f52:	ff378de3          	beq	a5,s3,80003f4c <namex+0xec>
  if(*path == 0)
    80003f56:	cf8d                	beqz	a5,80003f90 <namex+0x130>
  while(*path != '/' && *path != 0)
    80003f58:	0004c783          	lbu	a5,0(s1)
    80003f5c:	fd178713          	addi	a4,a5,-47
    80003f60:	cb19                	beqz	a4,80003f76 <namex+0x116>
    80003f62:	cb91                	beqz	a5,80003f76 <namex+0x116>
    80003f64:	8926                	mv	s2,s1
    path++;
    80003f66:	0905                	addi	s2,s2,1
  while(*path != '/' && *path != 0)
    80003f68:	00094783          	lbu	a5,0(s2)
    80003f6c:	fd178713          	addi	a4,a5,-47
    80003f70:	df35                	beqz	a4,80003eec <namex+0x8c>
    80003f72:	fbf5                	bnez	a5,80003f66 <namex+0x106>
    80003f74:	bfa5                	j	80003eec <namex+0x8c>
    80003f76:	8926                	mv	s2,s1
  len = path - s;
    80003f78:	4d01                	li	s10,0
    80003f7a:	4601                	li	a2,0
    memmove(name, s, len);
    80003f7c:	2601                	sext.w	a2,a2
    80003f7e:	85a6                	mv	a1,s1
    80003f80:	8556                	mv	a0,s5
    80003f82:	ec5fc0ef          	jal	80000e46 <memmove>
    name[len] = 0;
    80003f86:	9d56                	add	s10,s10,s5
    80003f88:	000d0023          	sb	zero,0(s10) # fffffffffffff000 <end+0xffffffff7ffb82a8>
    80003f8c:	84ca                	mv	s1,s2
    80003f8e:	bf9d                	j	80003f04 <namex+0xa4>
  if(nameiparent){
    80003f90:	f20b06e3          	beqz	s6,80003ebc <namex+0x5c>
    iput(ip);
    80003f94:	8552                	mv	a0,s4
    80003f96:	a07ff0ef          	jal	8000399c <iput>
    return 0;
    80003f9a:	4a01                	li	s4,0
    80003f9c:	b705                	j	80003ebc <namex+0x5c>

0000000080003f9e <dirlink>:
{
    80003f9e:	715d                	addi	sp,sp,-80
    80003fa0:	e486                	sd	ra,72(sp)
    80003fa2:	e0a2                	sd	s0,64(sp)
    80003fa4:	f84a                	sd	s2,48(sp)
    80003fa6:	ec56                	sd	s5,24(sp)
    80003fa8:	e85a                	sd	s6,16(sp)
    80003faa:	0880                	addi	s0,sp,80
    80003fac:	892a                	mv	s2,a0
    80003fae:	8aae                	mv	s5,a1
    80003fb0:	8b32                	mv	s6,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80003fb2:	4601                	li	a2,0
    80003fb4:	e01ff0ef          	jal	80003db4 <dirlookup>
    80003fb8:	ed1d                	bnez	a0,80003ff6 <dirlink+0x58>
    80003fba:	fc26                	sd	s1,56(sp)
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003fbc:	04c92483          	lw	s1,76(s2)
    80003fc0:	c4b9                	beqz	s1,8000400e <dirlink+0x70>
    80003fc2:	f44e                	sd	s3,40(sp)
    80003fc4:	f052                	sd	s4,32(sp)
    80003fc6:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003fc8:	fb040a13          	addi	s4,s0,-80
    80003fcc:	49c1                	li	s3,16
    80003fce:	874e                	mv	a4,s3
    80003fd0:	86a6                	mv	a3,s1
    80003fd2:	8652                	mv	a2,s4
    80003fd4:	4581                	li	a1,0
    80003fd6:	854a                	mv	a0,s2
    80003fd8:	bd5ff0ef          	jal	80003bac <readi>
    80003fdc:	03351163          	bne	a0,s3,80003ffe <dirlink+0x60>
    if(de.inum == 0)
    80003fe0:	fb045783          	lhu	a5,-80(s0)
    80003fe4:	c39d                	beqz	a5,8000400a <dirlink+0x6c>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003fe6:	24c1                	addiw	s1,s1,16
    80003fe8:	04c92783          	lw	a5,76(s2)
    80003fec:	fef4e1e3          	bltu	s1,a5,80003fce <dirlink+0x30>
    80003ff0:	79a2                	ld	s3,40(sp)
    80003ff2:	7a02                	ld	s4,32(sp)
    80003ff4:	a829                	j	8000400e <dirlink+0x70>
    iput(ip);
    80003ff6:	9a7ff0ef          	jal	8000399c <iput>
    return -1;
    80003ffa:	557d                	li	a0,-1
    80003ffc:	a83d                	j	8000403a <dirlink+0x9c>
      panic("dirlink read");
    80003ffe:	00004517          	auipc	a0,0x4
    80004002:	53250513          	addi	a0,a0,1330 # 80008530 <etext+0x530>
    80004006:	851fc0ef          	jal	80000856 <panic>
    8000400a:	79a2                	ld	s3,40(sp)
    8000400c:	7a02                	ld	s4,32(sp)
  strncpy(de.name, name, DIRSIZ);
    8000400e:	4639                	li	a2,14
    80004010:	85d6                	mv	a1,s5
    80004012:	fb240513          	addi	a0,s0,-78
    80004016:	edffc0ef          	jal	80000ef4 <strncpy>
  de.inum = inum;
    8000401a:	fb641823          	sh	s6,-80(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000401e:	4741                	li	a4,16
    80004020:	86a6                	mv	a3,s1
    80004022:	fb040613          	addi	a2,s0,-80
    80004026:	4581                	li	a1,0
    80004028:	854a                	mv	a0,s2
    8000402a:	c75ff0ef          	jal	80003c9e <writei>
    8000402e:	1541                	addi	a0,a0,-16
    80004030:	00a03533          	snez	a0,a0
    80004034:	40a0053b          	negw	a0,a0
    80004038:	74e2                	ld	s1,56(sp)
}
    8000403a:	60a6                	ld	ra,72(sp)
    8000403c:	6406                	ld	s0,64(sp)
    8000403e:	7942                	ld	s2,48(sp)
    80004040:	6ae2                	ld	s5,24(sp)
    80004042:	6b42                	ld	s6,16(sp)
    80004044:	6161                	addi	sp,sp,80
    80004046:	8082                	ret

0000000080004048 <namei>:

struct inode*
namei(char *path)
{
    80004048:	1101                	addi	sp,sp,-32
    8000404a:	ec06                	sd	ra,24(sp)
    8000404c:	e822                	sd	s0,16(sp)
    8000404e:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80004050:	fe040613          	addi	a2,s0,-32
    80004054:	4581                	li	a1,0
    80004056:	e0bff0ef          	jal	80003e60 <namex>
}
    8000405a:	60e2                	ld	ra,24(sp)
    8000405c:	6442                	ld	s0,16(sp)
    8000405e:	6105                	addi	sp,sp,32
    80004060:	8082                	ret

0000000080004062 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    80004062:	1141                	addi	sp,sp,-16
    80004064:	e406                	sd	ra,8(sp)
    80004066:	e022                	sd	s0,0(sp)
    80004068:	0800                	addi	s0,sp,16
    8000406a:	862e                	mv	a2,a1
  return namex(path, 1, name);
    8000406c:	4585                	li	a1,1
    8000406e:	df3ff0ef          	jal	80003e60 <namex>
}
    80004072:	60a2                	ld	ra,8(sp)
    80004074:	6402                	ld	s0,0(sp)
    80004076:	0141                	addi	sp,sp,16
    80004078:	8082                	ret

000000008000407a <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    8000407a:	1101                	addi	sp,sp,-32
    8000407c:	ec06                	sd	ra,24(sp)
    8000407e:	e822                	sd	s0,16(sp)
    80004080:	e426                	sd	s1,8(sp)
    80004082:	e04a                	sd	s2,0(sp)
    80004084:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80004086:	0001d917          	auipc	s2,0x1d
    8000408a:	9ea90913          	addi	s2,s2,-1558 # 80020a70 <log>
    8000408e:	01892583          	lw	a1,24(s2)
    80004092:	02492503          	lw	a0,36(s2)
    80004096:	8aeff0ef          	jal	80003144 <bread>
    8000409a:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    8000409c:	02892603          	lw	a2,40(s2)
    800040a0:	cd30                	sw	a2,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    800040a2:	00c05f63          	blez	a2,800040c0 <write_head+0x46>
    800040a6:	0001d717          	auipc	a4,0x1d
    800040aa:	9f670713          	addi	a4,a4,-1546 # 80020a9c <log+0x2c>
    800040ae:	87aa                	mv	a5,a0
    800040b0:	060a                	slli	a2,a2,0x2
    800040b2:	962a                	add	a2,a2,a0
    hb->block[i] = log.lh.block[i];
    800040b4:	4314                	lw	a3,0(a4)
    800040b6:	cff4                	sw	a3,92(a5)
  for (i = 0; i < log.lh.n; i++) {
    800040b8:	0711                	addi	a4,a4,4
    800040ba:	0791                	addi	a5,a5,4
    800040bc:	fec79ce3          	bne	a5,a2,800040b4 <write_head+0x3a>
  }
  bwrite(buf);
    800040c0:	8526                	mv	a0,s1
    800040c2:	980ff0ef          	jal	80003242 <bwrite>
  brelse(buf);
    800040c6:	8526                	mv	a0,s1
    800040c8:	9acff0ef          	jal	80003274 <brelse>
}
    800040cc:	60e2                	ld	ra,24(sp)
    800040ce:	6442                	ld	s0,16(sp)
    800040d0:	64a2                	ld	s1,8(sp)
    800040d2:	6902                	ld	s2,0(sp)
    800040d4:	6105                	addi	sp,sp,32
    800040d6:	8082                	ret

00000000800040d8 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    800040d8:	0001d797          	auipc	a5,0x1d
    800040dc:	9c07a783          	lw	a5,-1600(a5) # 80020a98 <log+0x28>
    800040e0:	0cf05163          	blez	a5,800041a2 <install_trans+0xca>
{
    800040e4:	715d                	addi	sp,sp,-80
    800040e6:	e486                	sd	ra,72(sp)
    800040e8:	e0a2                	sd	s0,64(sp)
    800040ea:	fc26                	sd	s1,56(sp)
    800040ec:	f84a                	sd	s2,48(sp)
    800040ee:	f44e                	sd	s3,40(sp)
    800040f0:	f052                	sd	s4,32(sp)
    800040f2:	ec56                	sd	s5,24(sp)
    800040f4:	e85a                	sd	s6,16(sp)
    800040f6:	e45e                	sd	s7,8(sp)
    800040f8:	e062                	sd	s8,0(sp)
    800040fa:	0880                	addi	s0,sp,80
    800040fc:	8b2a                	mv	s6,a0
    800040fe:	0001da97          	auipc	s5,0x1d
    80004102:	99ea8a93          	addi	s5,s5,-1634 # 80020a9c <log+0x2c>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004106:	4981                	li	s3,0
      printf("recovering tail %d dst %d\n", tail, log.lh.block[tail]);
    80004108:	00004c17          	auipc	s8,0x4
    8000410c:	438c0c13          	addi	s8,s8,1080 # 80008540 <etext+0x540>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80004110:	0001da17          	auipc	s4,0x1d
    80004114:	960a0a13          	addi	s4,s4,-1696 # 80020a70 <log>
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80004118:	40000b93          	li	s7,1024
    8000411c:	a025                	j	80004144 <install_trans+0x6c>
      printf("recovering tail %d dst %d\n", tail, log.lh.block[tail]);
    8000411e:	000aa603          	lw	a2,0(s5)
    80004122:	85ce                	mv	a1,s3
    80004124:	8562                	mv	a0,s8
    80004126:	c06fc0ef          	jal	8000052c <printf>
    8000412a:	a839                	j	80004148 <install_trans+0x70>
    brelse(lbuf);
    8000412c:	854a                	mv	a0,s2
    8000412e:	946ff0ef          	jal	80003274 <brelse>
    brelse(dbuf);
    80004132:	8526                	mv	a0,s1
    80004134:	940ff0ef          	jal	80003274 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004138:	2985                	addiw	s3,s3,1
    8000413a:	0a91                	addi	s5,s5,4
    8000413c:	028a2783          	lw	a5,40(s4)
    80004140:	04f9d563          	bge	s3,a5,8000418a <install_trans+0xb2>
    if(recovering) {
    80004144:	fc0b1de3          	bnez	s6,8000411e <install_trans+0x46>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80004148:	018a2583          	lw	a1,24(s4)
    8000414c:	013585bb          	addw	a1,a1,s3
    80004150:	2585                	addiw	a1,a1,1
    80004152:	024a2503          	lw	a0,36(s4)
    80004156:	feffe0ef          	jal	80003144 <bread>
    8000415a:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    8000415c:	000aa583          	lw	a1,0(s5)
    80004160:	024a2503          	lw	a0,36(s4)
    80004164:	fe1fe0ef          	jal	80003144 <bread>
    80004168:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    8000416a:	865e                	mv	a2,s7
    8000416c:	05890593          	addi	a1,s2,88
    80004170:	05850513          	addi	a0,a0,88
    80004174:	cd3fc0ef          	jal	80000e46 <memmove>
    bwrite(dbuf);  // write dst to disk
    80004178:	8526                	mv	a0,s1
    8000417a:	8c8ff0ef          	jal	80003242 <bwrite>
    if(recovering == 0)
    8000417e:	fa0b17e3          	bnez	s6,8000412c <install_trans+0x54>
      bunpin(dbuf);
    80004182:	8526                	mv	a0,s1
    80004184:	9beff0ef          	jal	80003342 <bunpin>
    80004188:	b755                	j	8000412c <install_trans+0x54>
}
    8000418a:	60a6                	ld	ra,72(sp)
    8000418c:	6406                	ld	s0,64(sp)
    8000418e:	74e2                	ld	s1,56(sp)
    80004190:	7942                	ld	s2,48(sp)
    80004192:	79a2                	ld	s3,40(sp)
    80004194:	7a02                	ld	s4,32(sp)
    80004196:	6ae2                	ld	s5,24(sp)
    80004198:	6b42                	ld	s6,16(sp)
    8000419a:	6ba2                	ld	s7,8(sp)
    8000419c:	6c02                	ld	s8,0(sp)
    8000419e:	6161                	addi	sp,sp,80
    800041a0:	8082                	ret
    800041a2:	8082                	ret

00000000800041a4 <initlog>:
{
    800041a4:	7179                	addi	sp,sp,-48
    800041a6:	f406                	sd	ra,40(sp)
    800041a8:	f022                	sd	s0,32(sp)
    800041aa:	ec26                	sd	s1,24(sp)
    800041ac:	e84a                	sd	s2,16(sp)
    800041ae:	e44e                	sd	s3,8(sp)
    800041b0:	1800                	addi	s0,sp,48
    800041b2:	84aa                	mv	s1,a0
    800041b4:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    800041b6:	0001d917          	auipc	s2,0x1d
    800041ba:	8ba90913          	addi	s2,s2,-1862 # 80020a70 <log>
    800041be:	00004597          	auipc	a1,0x4
    800041c2:	3a258593          	addi	a1,a1,930 # 80008560 <etext+0x560>
    800041c6:	854a                	mv	a0,s2
    800041c8:	ac5fc0ef          	jal	80000c8c <initlock>
  log.start = sb->logstart;
    800041cc:	0149a583          	lw	a1,20(s3)
    800041d0:	00b92c23          	sw	a1,24(s2)
  log.dev = dev;
    800041d4:	02992223          	sw	s1,36(s2)
  struct buf *buf = bread(log.dev, log.start);
    800041d8:	8526                	mv	a0,s1
    800041da:	f6bfe0ef          	jal	80003144 <bread>
  log.lh.n = lh->n;
    800041de:	4d30                	lw	a2,88(a0)
    800041e0:	02c92423          	sw	a2,40(s2)
  for (i = 0; i < log.lh.n; i++) {
    800041e4:	00c05f63          	blez	a2,80004202 <initlog+0x5e>
    800041e8:	87aa                	mv	a5,a0
    800041ea:	0001d717          	auipc	a4,0x1d
    800041ee:	8b270713          	addi	a4,a4,-1870 # 80020a9c <log+0x2c>
    800041f2:	060a                	slli	a2,a2,0x2
    800041f4:	962a                	add	a2,a2,a0
    log.lh.block[i] = lh->block[i];
    800041f6:	4ff4                	lw	a3,92(a5)
    800041f8:	c314                	sw	a3,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    800041fa:	0791                	addi	a5,a5,4
    800041fc:	0711                	addi	a4,a4,4
    800041fe:	fec79ce3          	bne	a5,a2,800041f6 <initlog+0x52>
  brelse(buf);
    80004202:	872ff0ef          	jal	80003274 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    80004206:	4505                	li	a0,1
    80004208:	ed1ff0ef          	jal	800040d8 <install_trans>
  log.lh.n = 0;
    8000420c:	0001d797          	auipc	a5,0x1d
    80004210:	8807a623          	sw	zero,-1908(a5) # 80020a98 <log+0x28>
  write_head(); // clear the log
    80004214:	e67ff0ef          	jal	8000407a <write_head>
}
    80004218:	70a2                	ld	ra,40(sp)
    8000421a:	7402                	ld	s0,32(sp)
    8000421c:	64e2                	ld	s1,24(sp)
    8000421e:	6942                	ld	s2,16(sp)
    80004220:	69a2                	ld	s3,8(sp)
    80004222:	6145                	addi	sp,sp,48
    80004224:	8082                	ret

0000000080004226 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    80004226:	1101                	addi	sp,sp,-32
    80004228:	ec06                	sd	ra,24(sp)
    8000422a:	e822                	sd	s0,16(sp)
    8000422c:	e426                	sd	s1,8(sp)
    8000422e:	e04a                	sd	s2,0(sp)
    80004230:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    80004232:	0001d517          	auipc	a0,0x1d
    80004236:	83e50513          	addi	a0,a0,-1986 # 80020a70 <log>
    8000423a:	addfc0ef          	jal	80000d16 <acquire>
  while(1){
    if(log.committing){
    8000423e:	0001d497          	auipc	s1,0x1d
    80004242:	83248493          	addi	s1,s1,-1998 # 80020a70 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGBLOCKS){
    80004246:	4979                	li	s2,30
    80004248:	a029                	j	80004252 <begin_op+0x2c>
      sleep(&log, &log.lock);
    8000424a:	85a6                	mv	a1,s1
    8000424c:	8526                	mv	a0,s1
    8000424e:	a24fe0ef          	jal	80002472 <sleep>
    if(log.committing){
    80004252:	509c                	lw	a5,32(s1)
    80004254:	fbfd                	bnez	a5,8000424a <begin_op+0x24>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGBLOCKS){
    80004256:	4cd8                	lw	a4,28(s1)
    80004258:	2705                	addiw	a4,a4,1
    8000425a:	0027179b          	slliw	a5,a4,0x2
    8000425e:	9fb9                	addw	a5,a5,a4
    80004260:	0017979b          	slliw	a5,a5,0x1
    80004264:	5494                	lw	a3,40(s1)
    80004266:	9fb5                	addw	a5,a5,a3
    80004268:	00f95763          	bge	s2,a5,80004276 <begin_op+0x50>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    8000426c:	85a6                	mv	a1,s1
    8000426e:	8526                	mv	a0,s1
    80004270:	a02fe0ef          	jal	80002472 <sleep>
    80004274:	bff9                	j	80004252 <begin_op+0x2c>
    } else {
      log.outstanding += 1;
    80004276:	0001d797          	auipc	a5,0x1d
    8000427a:	80e7ab23          	sw	a4,-2026(a5) # 80020a8c <log+0x1c>
      release(&log.lock);
    8000427e:	0001c517          	auipc	a0,0x1c
    80004282:	7f250513          	addi	a0,a0,2034 # 80020a70 <log>
    80004286:	b25fc0ef          	jal	80000daa <release>
      break;
    }
  }
}
    8000428a:	60e2                	ld	ra,24(sp)
    8000428c:	6442                	ld	s0,16(sp)
    8000428e:	64a2                	ld	s1,8(sp)
    80004290:	6902                	ld	s2,0(sp)
    80004292:	6105                	addi	sp,sp,32
    80004294:	8082                	ret

0000000080004296 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    80004296:	7139                	addi	sp,sp,-64
    80004298:	fc06                	sd	ra,56(sp)
    8000429a:	f822                	sd	s0,48(sp)
    8000429c:	f426                	sd	s1,40(sp)
    8000429e:	f04a                	sd	s2,32(sp)
    800042a0:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    800042a2:	0001c497          	auipc	s1,0x1c
    800042a6:	7ce48493          	addi	s1,s1,1998 # 80020a70 <log>
    800042aa:	8526                	mv	a0,s1
    800042ac:	a6bfc0ef          	jal	80000d16 <acquire>
  log.outstanding -= 1;
    800042b0:	4cdc                	lw	a5,28(s1)
    800042b2:	37fd                	addiw	a5,a5,-1
    800042b4:	893e                	mv	s2,a5
    800042b6:	ccdc                	sw	a5,28(s1)
  if(log.committing)
    800042b8:	509c                	lw	a5,32(s1)
    800042ba:	e7b1                	bnez	a5,80004306 <end_op+0x70>
    panic("log.committing");
  if(log.outstanding == 0){
    800042bc:	04091e63          	bnez	s2,80004318 <end_op+0x82>
    do_commit = 1;
    log.committing = 1;
    800042c0:	0001c497          	auipc	s1,0x1c
    800042c4:	7b048493          	addi	s1,s1,1968 # 80020a70 <log>
    800042c8:	4785                	li	a5,1
    800042ca:	d09c                	sw	a5,32(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    800042cc:	8526                	mv	a0,s1
    800042ce:	addfc0ef          	jal	80000daa <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    800042d2:	549c                	lw	a5,40(s1)
    800042d4:	06f04463          	bgtz	a5,8000433c <end_op+0xa6>
    acquire(&log.lock);
    800042d8:	0001c517          	auipc	a0,0x1c
    800042dc:	79850513          	addi	a0,a0,1944 # 80020a70 <log>
    800042e0:	a37fc0ef          	jal	80000d16 <acquire>
    log.committing = 0;
    800042e4:	0001c797          	auipc	a5,0x1c
    800042e8:	7a07a623          	sw	zero,1964(a5) # 80020a90 <log+0x20>
    wakeup(&log);
    800042ec:	0001c517          	auipc	a0,0x1c
    800042f0:	78450513          	addi	a0,a0,1924 # 80020a70 <log>
    800042f4:	9cafe0ef          	jal	800024be <wakeup>
    release(&log.lock);
    800042f8:	0001c517          	auipc	a0,0x1c
    800042fc:	77850513          	addi	a0,a0,1912 # 80020a70 <log>
    80004300:	aabfc0ef          	jal	80000daa <release>
}
    80004304:	a035                	j	80004330 <end_op+0x9a>
    80004306:	ec4e                	sd	s3,24(sp)
    80004308:	e852                	sd	s4,16(sp)
    8000430a:	e456                	sd	s5,8(sp)
    panic("log.committing");
    8000430c:	00004517          	auipc	a0,0x4
    80004310:	25c50513          	addi	a0,a0,604 # 80008568 <etext+0x568>
    80004314:	d42fc0ef          	jal	80000856 <panic>
    wakeup(&log);
    80004318:	0001c517          	auipc	a0,0x1c
    8000431c:	75850513          	addi	a0,a0,1880 # 80020a70 <log>
    80004320:	99efe0ef          	jal	800024be <wakeup>
  release(&log.lock);
    80004324:	0001c517          	auipc	a0,0x1c
    80004328:	74c50513          	addi	a0,a0,1868 # 80020a70 <log>
    8000432c:	a7ffc0ef          	jal	80000daa <release>
}
    80004330:	70e2                	ld	ra,56(sp)
    80004332:	7442                	ld	s0,48(sp)
    80004334:	74a2                	ld	s1,40(sp)
    80004336:	7902                	ld	s2,32(sp)
    80004338:	6121                	addi	sp,sp,64
    8000433a:	8082                	ret
    8000433c:	ec4e                	sd	s3,24(sp)
    8000433e:	e852                	sd	s4,16(sp)
    80004340:	e456                	sd	s5,8(sp)
  for (tail = 0; tail < log.lh.n; tail++) {
    80004342:	0001ca97          	auipc	s5,0x1c
    80004346:	75aa8a93          	addi	s5,s5,1882 # 80020a9c <log+0x2c>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    8000434a:	0001ca17          	auipc	s4,0x1c
    8000434e:	726a0a13          	addi	s4,s4,1830 # 80020a70 <log>
    80004352:	018a2583          	lw	a1,24(s4)
    80004356:	012585bb          	addw	a1,a1,s2
    8000435a:	2585                	addiw	a1,a1,1
    8000435c:	024a2503          	lw	a0,36(s4)
    80004360:	de5fe0ef          	jal	80003144 <bread>
    80004364:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    80004366:	000aa583          	lw	a1,0(s5)
    8000436a:	024a2503          	lw	a0,36(s4)
    8000436e:	dd7fe0ef          	jal	80003144 <bread>
    80004372:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    80004374:	40000613          	li	a2,1024
    80004378:	05850593          	addi	a1,a0,88
    8000437c:	05848513          	addi	a0,s1,88
    80004380:	ac7fc0ef          	jal	80000e46 <memmove>
    bwrite(to);  // write the log
    80004384:	8526                	mv	a0,s1
    80004386:	ebdfe0ef          	jal	80003242 <bwrite>
    brelse(from);
    8000438a:	854e                	mv	a0,s3
    8000438c:	ee9fe0ef          	jal	80003274 <brelse>
    brelse(to);
    80004390:	8526                	mv	a0,s1
    80004392:	ee3fe0ef          	jal	80003274 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004396:	2905                	addiw	s2,s2,1
    80004398:	0a91                	addi	s5,s5,4
    8000439a:	028a2783          	lw	a5,40(s4)
    8000439e:	faf94ae3          	blt	s2,a5,80004352 <end_op+0xbc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    800043a2:	cd9ff0ef          	jal	8000407a <write_head>
    install_trans(0); // Now install writes to home locations
    800043a6:	4501                	li	a0,0
    800043a8:	d31ff0ef          	jal	800040d8 <install_trans>
    log.lh.n = 0;
    800043ac:	0001c797          	auipc	a5,0x1c
    800043b0:	6e07a623          	sw	zero,1772(a5) # 80020a98 <log+0x28>
    write_head();    // Erase the transaction from the log
    800043b4:	cc7ff0ef          	jal	8000407a <write_head>
    800043b8:	69e2                	ld	s3,24(sp)
    800043ba:	6a42                	ld	s4,16(sp)
    800043bc:	6aa2                	ld	s5,8(sp)
    800043be:	bf29                	j	800042d8 <end_op+0x42>

00000000800043c0 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    800043c0:	1101                	addi	sp,sp,-32
    800043c2:	ec06                	sd	ra,24(sp)
    800043c4:	e822                	sd	s0,16(sp)
    800043c6:	e426                	sd	s1,8(sp)
    800043c8:	1000                	addi	s0,sp,32
    800043ca:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    800043cc:	0001c517          	auipc	a0,0x1c
    800043d0:	6a450513          	addi	a0,a0,1700 # 80020a70 <log>
    800043d4:	943fc0ef          	jal	80000d16 <acquire>
  if (log.lh.n >= LOGBLOCKS)
    800043d8:	0001c617          	auipc	a2,0x1c
    800043dc:	6c062603          	lw	a2,1728(a2) # 80020a98 <log+0x28>
    800043e0:	47f5                	li	a5,29
    800043e2:	04c7cd63          	blt	a5,a2,8000443c <log_write+0x7c>
    panic("too big a transaction");
  if (log.outstanding < 1)
    800043e6:	0001c797          	auipc	a5,0x1c
    800043ea:	6a67a783          	lw	a5,1702(a5) # 80020a8c <log+0x1c>
    800043ee:	04f05d63          	blez	a5,80004448 <log_write+0x88>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    800043f2:	4781                	li	a5,0
    800043f4:	06c05063          	blez	a2,80004454 <log_write+0x94>
    if (log.lh.block[i] == b->blockno)   // log absorption
    800043f8:	44cc                	lw	a1,12(s1)
    800043fa:	0001c717          	auipc	a4,0x1c
    800043fe:	6a270713          	addi	a4,a4,1698 # 80020a9c <log+0x2c>
  for (i = 0; i < log.lh.n; i++) {
    80004402:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    80004404:	4314                	lw	a3,0(a4)
    80004406:	04b68763          	beq	a3,a1,80004454 <log_write+0x94>
  for (i = 0; i < log.lh.n; i++) {
    8000440a:	2785                	addiw	a5,a5,1
    8000440c:	0711                	addi	a4,a4,4
    8000440e:	fef61be3          	bne	a2,a5,80004404 <log_write+0x44>
      break;
  }
  log.lh.block[i] = b->blockno;
    80004412:	060a                	slli	a2,a2,0x2
    80004414:	02060613          	addi	a2,a2,32
    80004418:	0001c797          	auipc	a5,0x1c
    8000441c:	65878793          	addi	a5,a5,1624 # 80020a70 <log>
    80004420:	97b2                	add	a5,a5,a2
    80004422:	44d8                	lw	a4,12(s1)
    80004424:	c7d8                	sw	a4,12(a5)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    80004426:	8526                	mv	a0,s1
    80004428:	ee7fe0ef          	jal	8000330e <bpin>
    log.lh.n++;
    8000442c:	0001c717          	auipc	a4,0x1c
    80004430:	64470713          	addi	a4,a4,1604 # 80020a70 <log>
    80004434:	571c                	lw	a5,40(a4)
    80004436:	2785                	addiw	a5,a5,1
    80004438:	d71c                	sw	a5,40(a4)
    8000443a:	a815                	j	8000446e <log_write+0xae>
    panic("too big a transaction");
    8000443c:	00004517          	auipc	a0,0x4
    80004440:	13c50513          	addi	a0,a0,316 # 80008578 <etext+0x578>
    80004444:	c12fc0ef          	jal	80000856 <panic>
    panic("log_write outside of trans");
    80004448:	00004517          	auipc	a0,0x4
    8000444c:	14850513          	addi	a0,a0,328 # 80008590 <etext+0x590>
    80004450:	c06fc0ef          	jal	80000856 <panic>
  log.lh.block[i] = b->blockno;
    80004454:	00279693          	slli	a3,a5,0x2
    80004458:	02068693          	addi	a3,a3,32
    8000445c:	0001c717          	auipc	a4,0x1c
    80004460:	61470713          	addi	a4,a4,1556 # 80020a70 <log>
    80004464:	9736                	add	a4,a4,a3
    80004466:	44d4                	lw	a3,12(s1)
    80004468:	c754                	sw	a3,12(a4)
  if (i == log.lh.n) {  // Add new block to log?
    8000446a:	faf60ee3          	beq	a2,a5,80004426 <log_write+0x66>
  }
  release(&log.lock);
    8000446e:	0001c517          	auipc	a0,0x1c
    80004472:	60250513          	addi	a0,a0,1538 # 80020a70 <log>
    80004476:	935fc0ef          	jal	80000daa <release>
}
    8000447a:	60e2                	ld	ra,24(sp)
    8000447c:	6442                	ld	s0,16(sp)
    8000447e:	64a2                	ld	s1,8(sp)
    80004480:	6105                	addi	sp,sp,32
    80004482:	8082                	ret

0000000080004484 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    80004484:	1101                	addi	sp,sp,-32
    80004486:	ec06                	sd	ra,24(sp)
    80004488:	e822                	sd	s0,16(sp)
    8000448a:	e426                	sd	s1,8(sp)
    8000448c:	e04a                	sd	s2,0(sp)
    8000448e:	1000                	addi	s0,sp,32
    80004490:	84aa                	mv	s1,a0
    80004492:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    80004494:	00004597          	auipc	a1,0x4
    80004498:	11c58593          	addi	a1,a1,284 # 800085b0 <etext+0x5b0>
    8000449c:	0521                	addi	a0,a0,8
    8000449e:	feefc0ef          	jal	80000c8c <initlock>
  lk->name = name;
    800044a2:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    800044a6:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    800044aa:	0204a423          	sw	zero,40(s1)
}
    800044ae:	60e2                	ld	ra,24(sp)
    800044b0:	6442                	ld	s0,16(sp)
    800044b2:	64a2                	ld	s1,8(sp)
    800044b4:	6902                	ld	s2,0(sp)
    800044b6:	6105                	addi	sp,sp,32
    800044b8:	8082                	ret

00000000800044ba <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    800044ba:	1101                	addi	sp,sp,-32
    800044bc:	ec06                	sd	ra,24(sp)
    800044be:	e822                	sd	s0,16(sp)
    800044c0:	e426                	sd	s1,8(sp)
    800044c2:	e04a                	sd	s2,0(sp)
    800044c4:	1000                	addi	s0,sp,32
    800044c6:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    800044c8:	00850913          	addi	s2,a0,8
    800044cc:	854a                	mv	a0,s2
    800044ce:	849fc0ef          	jal	80000d16 <acquire>
  while (lk->locked) {
    800044d2:	409c                	lw	a5,0(s1)
    800044d4:	c799                	beqz	a5,800044e2 <acquiresleep+0x28>
    sleep(lk, &lk->lk);
    800044d6:	85ca                	mv	a1,s2
    800044d8:	8526                	mv	a0,s1
    800044da:	f99fd0ef          	jal	80002472 <sleep>
  while (lk->locked) {
    800044de:	409c                	lw	a5,0(s1)
    800044e0:	fbfd                	bnez	a5,800044d6 <acquiresleep+0x1c>
  }
  lk->locked = 1;
    800044e2:	4785                	li	a5,1
    800044e4:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    800044e6:	f42fd0ef          	jal	80001c28 <myproc>
    800044ea:	591c                	lw	a5,48(a0)
    800044ec:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    800044ee:	854a                	mv	a0,s2
    800044f0:	8bbfc0ef          	jal	80000daa <release>
}
    800044f4:	60e2                	ld	ra,24(sp)
    800044f6:	6442                	ld	s0,16(sp)
    800044f8:	64a2                	ld	s1,8(sp)
    800044fa:	6902                	ld	s2,0(sp)
    800044fc:	6105                	addi	sp,sp,32
    800044fe:	8082                	ret

0000000080004500 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    80004500:	1101                	addi	sp,sp,-32
    80004502:	ec06                	sd	ra,24(sp)
    80004504:	e822                	sd	s0,16(sp)
    80004506:	e426                	sd	s1,8(sp)
    80004508:	e04a                	sd	s2,0(sp)
    8000450a:	1000                	addi	s0,sp,32
    8000450c:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    8000450e:	00850913          	addi	s2,a0,8
    80004512:	854a                	mv	a0,s2
    80004514:	803fc0ef          	jal	80000d16 <acquire>
  lk->locked = 0;
    80004518:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    8000451c:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    80004520:	8526                	mv	a0,s1
    80004522:	f9dfd0ef          	jal	800024be <wakeup>
  release(&lk->lk);
    80004526:	854a                	mv	a0,s2
    80004528:	883fc0ef          	jal	80000daa <release>
}
    8000452c:	60e2                	ld	ra,24(sp)
    8000452e:	6442                	ld	s0,16(sp)
    80004530:	64a2                	ld	s1,8(sp)
    80004532:	6902                	ld	s2,0(sp)
    80004534:	6105                	addi	sp,sp,32
    80004536:	8082                	ret

0000000080004538 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    80004538:	7179                	addi	sp,sp,-48
    8000453a:	f406                	sd	ra,40(sp)
    8000453c:	f022                	sd	s0,32(sp)
    8000453e:	ec26                	sd	s1,24(sp)
    80004540:	e84a                	sd	s2,16(sp)
    80004542:	1800                	addi	s0,sp,48
    80004544:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    80004546:	00850913          	addi	s2,a0,8
    8000454a:	854a                	mv	a0,s2
    8000454c:	fcafc0ef          	jal	80000d16 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    80004550:	409c                	lw	a5,0(s1)
    80004552:	ef81                	bnez	a5,8000456a <holdingsleep+0x32>
    80004554:	4481                	li	s1,0
  release(&lk->lk);
    80004556:	854a                	mv	a0,s2
    80004558:	853fc0ef          	jal	80000daa <release>
  return r;
}
    8000455c:	8526                	mv	a0,s1
    8000455e:	70a2                	ld	ra,40(sp)
    80004560:	7402                	ld	s0,32(sp)
    80004562:	64e2                	ld	s1,24(sp)
    80004564:	6942                	ld	s2,16(sp)
    80004566:	6145                	addi	sp,sp,48
    80004568:	8082                	ret
    8000456a:	e44e                	sd	s3,8(sp)
  r = lk->locked && (lk->pid == myproc()->pid);
    8000456c:	0284a983          	lw	s3,40(s1)
    80004570:	eb8fd0ef          	jal	80001c28 <myproc>
    80004574:	5904                	lw	s1,48(a0)
    80004576:	413484b3          	sub	s1,s1,s3
    8000457a:	0014b493          	seqz	s1,s1
    8000457e:	69a2                	ld	s3,8(sp)
    80004580:	bfd9                	j	80004556 <holdingsleep+0x1e>

0000000080004582 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    80004582:	1141                	addi	sp,sp,-16
    80004584:	e406                	sd	ra,8(sp)
    80004586:	e022                	sd	s0,0(sp)
    80004588:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    8000458a:	00004597          	auipc	a1,0x4
    8000458e:	03658593          	addi	a1,a1,54 # 800085c0 <etext+0x5c0>
    80004592:	0001c517          	auipc	a0,0x1c
    80004596:	62650513          	addi	a0,a0,1574 # 80020bb8 <ftable>
    8000459a:	ef2fc0ef          	jal	80000c8c <initlock>
}
    8000459e:	60a2                	ld	ra,8(sp)
    800045a0:	6402                	ld	s0,0(sp)
    800045a2:	0141                	addi	sp,sp,16
    800045a4:	8082                	ret

00000000800045a6 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    800045a6:	1101                	addi	sp,sp,-32
    800045a8:	ec06                	sd	ra,24(sp)
    800045aa:	e822                	sd	s0,16(sp)
    800045ac:	e426                	sd	s1,8(sp)
    800045ae:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    800045b0:	0001c517          	auipc	a0,0x1c
    800045b4:	60850513          	addi	a0,a0,1544 # 80020bb8 <ftable>
    800045b8:	f5efc0ef          	jal	80000d16 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    800045bc:	0001c497          	auipc	s1,0x1c
    800045c0:	61448493          	addi	s1,s1,1556 # 80020bd0 <ftable+0x18>
    800045c4:	0001d717          	auipc	a4,0x1d
    800045c8:	5ac70713          	addi	a4,a4,1452 # 80021b70 <disk>
    if(f->ref == 0){
    800045cc:	40dc                	lw	a5,4(s1)
    800045ce:	cf89                	beqz	a5,800045e8 <filealloc+0x42>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    800045d0:	02848493          	addi	s1,s1,40
    800045d4:	fee49ce3          	bne	s1,a4,800045cc <filealloc+0x26>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    800045d8:	0001c517          	auipc	a0,0x1c
    800045dc:	5e050513          	addi	a0,a0,1504 # 80020bb8 <ftable>
    800045e0:	fcafc0ef          	jal	80000daa <release>
  return 0;
    800045e4:	4481                	li	s1,0
    800045e6:	a809                	j	800045f8 <filealloc+0x52>
      f->ref = 1;
    800045e8:	4785                	li	a5,1
    800045ea:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    800045ec:	0001c517          	auipc	a0,0x1c
    800045f0:	5cc50513          	addi	a0,a0,1484 # 80020bb8 <ftable>
    800045f4:	fb6fc0ef          	jal	80000daa <release>
}
    800045f8:	8526                	mv	a0,s1
    800045fa:	60e2                	ld	ra,24(sp)
    800045fc:	6442                	ld	s0,16(sp)
    800045fe:	64a2                	ld	s1,8(sp)
    80004600:	6105                	addi	sp,sp,32
    80004602:	8082                	ret

0000000080004604 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    80004604:	1101                	addi	sp,sp,-32
    80004606:	ec06                	sd	ra,24(sp)
    80004608:	e822                	sd	s0,16(sp)
    8000460a:	e426                	sd	s1,8(sp)
    8000460c:	1000                	addi	s0,sp,32
    8000460e:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80004610:	0001c517          	auipc	a0,0x1c
    80004614:	5a850513          	addi	a0,a0,1448 # 80020bb8 <ftable>
    80004618:	efefc0ef          	jal	80000d16 <acquire>
  if(f->ref < 1)
    8000461c:	40dc                	lw	a5,4(s1)
    8000461e:	02f05063          	blez	a5,8000463e <filedup+0x3a>
    panic("filedup");
  f->ref++;
    80004622:	2785                	addiw	a5,a5,1
    80004624:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80004626:	0001c517          	auipc	a0,0x1c
    8000462a:	59250513          	addi	a0,a0,1426 # 80020bb8 <ftable>
    8000462e:	f7cfc0ef          	jal	80000daa <release>
  return f;
}
    80004632:	8526                	mv	a0,s1
    80004634:	60e2                	ld	ra,24(sp)
    80004636:	6442                	ld	s0,16(sp)
    80004638:	64a2                	ld	s1,8(sp)
    8000463a:	6105                	addi	sp,sp,32
    8000463c:	8082                	ret
    panic("filedup");
    8000463e:	00004517          	auipc	a0,0x4
    80004642:	f8a50513          	addi	a0,a0,-118 # 800085c8 <etext+0x5c8>
    80004646:	a10fc0ef          	jal	80000856 <panic>

000000008000464a <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    8000464a:	7139                	addi	sp,sp,-64
    8000464c:	fc06                	sd	ra,56(sp)
    8000464e:	f822                	sd	s0,48(sp)
    80004650:	f426                	sd	s1,40(sp)
    80004652:	0080                	addi	s0,sp,64
    80004654:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    80004656:	0001c517          	auipc	a0,0x1c
    8000465a:	56250513          	addi	a0,a0,1378 # 80020bb8 <ftable>
    8000465e:	eb8fc0ef          	jal	80000d16 <acquire>
  if(f->ref < 1)
    80004662:	40dc                	lw	a5,4(s1)
    80004664:	04f05a63          	blez	a5,800046b8 <fileclose+0x6e>
    panic("fileclose");
  if(--f->ref > 0){
    80004668:	37fd                	addiw	a5,a5,-1
    8000466a:	c0dc                	sw	a5,4(s1)
    8000466c:	06f04063          	bgtz	a5,800046cc <fileclose+0x82>
    80004670:	f04a                	sd	s2,32(sp)
    80004672:	ec4e                	sd	s3,24(sp)
    80004674:	e852                	sd	s4,16(sp)
    80004676:	e456                	sd	s5,8(sp)
    release(&ftable.lock);
    return;
  }
  ff = *f;
    80004678:	0004a903          	lw	s2,0(s1)
    8000467c:	0094c783          	lbu	a5,9(s1)
    80004680:	89be                	mv	s3,a5
    80004682:	689c                	ld	a5,16(s1)
    80004684:	8a3e                	mv	s4,a5
    80004686:	6c9c                	ld	a5,24(s1)
    80004688:	8abe                	mv	s5,a5
  f->ref = 0;
    8000468a:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    8000468e:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    80004692:	0001c517          	auipc	a0,0x1c
    80004696:	52650513          	addi	a0,a0,1318 # 80020bb8 <ftable>
    8000469a:	f10fc0ef          	jal	80000daa <release>

  if(ff.type == FD_PIPE){
    8000469e:	4785                	li	a5,1
    800046a0:	04f90163          	beq	s2,a5,800046e2 <fileclose+0x98>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    800046a4:	ffe9079b          	addiw	a5,s2,-2
    800046a8:	4705                	li	a4,1
    800046aa:	04f77563          	bgeu	a4,a5,800046f4 <fileclose+0xaa>
    800046ae:	7902                	ld	s2,32(sp)
    800046b0:	69e2                	ld	s3,24(sp)
    800046b2:	6a42                	ld	s4,16(sp)
    800046b4:	6aa2                	ld	s5,8(sp)
    800046b6:	a00d                	j	800046d8 <fileclose+0x8e>
    800046b8:	f04a                	sd	s2,32(sp)
    800046ba:	ec4e                	sd	s3,24(sp)
    800046bc:	e852                	sd	s4,16(sp)
    800046be:	e456                	sd	s5,8(sp)
    panic("fileclose");
    800046c0:	00004517          	auipc	a0,0x4
    800046c4:	f1050513          	addi	a0,a0,-240 # 800085d0 <etext+0x5d0>
    800046c8:	98efc0ef          	jal	80000856 <panic>
    release(&ftable.lock);
    800046cc:	0001c517          	auipc	a0,0x1c
    800046d0:	4ec50513          	addi	a0,a0,1260 # 80020bb8 <ftable>
    800046d4:	ed6fc0ef          	jal	80000daa <release>
    begin_op();
    iput(ff.ip);
    end_op();
  }
}
    800046d8:	70e2                	ld	ra,56(sp)
    800046da:	7442                	ld	s0,48(sp)
    800046dc:	74a2                	ld	s1,40(sp)
    800046de:	6121                	addi	sp,sp,64
    800046e0:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    800046e2:	85ce                	mv	a1,s3
    800046e4:	8552                	mv	a0,s4
    800046e6:	348000ef          	jal	80004a2e <pipeclose>
    800046ea:	7902                	ld	s2,32(sp)
    800046ec:	69e2                	ld	s3,24(sp)
    800046ee:	6a42                	ld	s4,16(sp)
    800046f0:	6aa2                	ld	s5,8(sp)
    800046f2:	b7dd                	j	800046d8 <fileclose+0x8e>
    begin_op();
    800046f4:	b33ff0ef          	jal	80004226 <begin_op>
    iput(ff.ip);
    800046f8:	8556                	mv	a0,s5
    800046fa:	aa2ff0ef          	jal	8000399c <iput>
    end_op();
    800046fe:	b99ff0ef          	jal	80004296 <end_op>
    80004702:	7902                	ld	s2,32(sp)
    80004704:	69e2                	ld	s3,24(sp)
    80004706:	6a42                	ld	s4,16(sp)
    80004708:	6aa2                	ld	s5,8(sp)
    8000470a:	b7f9                	j	800046d8 <fileclose+0x8e>

000000008000470c <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    8000470c:	715d                	addi	sp,sp,-80
    8000470e:	e486                	sd	ra,72(sp)
    80004710:	e0a2                	sd	s0,64(sp)
    80004712:	fc26                	sd	s1,56(sp)
    80004714:	f052                	sd	s4,32(sp)
    80004716:	0880                	addi	s0,sp,80
    80004718:	84aa                	mv	s1,a0
    8000471a:	8a2e                	mv	s4,a1
  struct proc *p = myproc();
    8000471c:	d0cfd0ef          	jal	80001c28 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    80004720:	409c                	lw	a5,0(s1)
    80004722:	37f9                	addiw	a5,a5,-2
    80004724:	4705                	li	a4,1
    80004726:	04f76263          	bltu	a4,a5,8000476a <filestat+0x5e>
    8000472a:	f84a                	sd	s2,48(sp)
    8000472c:	f44e                	sd	s3,40(sp)
    8000472e:	89aa                	mv	s3,a0
    ilock(f->ip);
    80004730:	6c88                	ld	a0,24(s1)
    80004732:	8e8ff0ef          	jal	8000381a <ilock>
    stati(f->ip, &st);
    80004736:	fb840913          	addi	s2,s0,-72
    8000473a:	85ca                	mv	a1,s2
    8000473c:	6c88                	ld	a0,24(s1)
    8000473e:	c40ff0ef          	jal	80003b7e <stati>
    iunlock(f->ip);
    80004742:	6c88                	ld	a0,24(s1)
    80004744:	984ff0ef          	jal	800038c8 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    80004748:	46e1                	li	a3,24
    8000474a:	864a                	mv	a2,s2
    8000474c:	85d2                	mv	a1,s4
    8000474e:	0509b503          	ld	a0,80(s3)
    80004752:	9e8fd0ef          	jal	8000193a <copyout>
    80004756:	41f5551b          	sraiw	a0,a0,0x1f
    8000475a:	7942                	ld	s2,48(sp)
    8000475c:	79a2                	ld	s3,40(sp)
      return -1;
    return 0;
  }
  return -1;
}
    8000475e:	60a6                	ld	ra,72(sp)
    80004760:	6406                	ld	s0,64(sp)
    80004762:	74e2                	ld	s1,56(sp)
    80004764:	7a02                	ld	s4,32(sp)
    80004766:	6161                	addi	sp,sp,80
    80004768:	8082                	ret
  return -1;
    8000476a:	557d                	li	a0,-1
    8000476c:	bfcd                	j	8000475e <filestat+0x52>

000000008000476e <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    8000476e:	7179                	addi	sp,sp,-48
    80004770:	f406                	sd	ra,40(sp)
    80004772:	f022                	sd	s0,32(sp)
    80004774:	e84a                	sd	s2,16(sp)
    80004776:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    80004778:	00854783          	lbu	a5,8(a0)
    8000477c:	cfd1                	beqz	a5,80004818 <fileread+0xaa>
    8000477e:	ec26                	sd	s1,24(sp)
    80004780:	e44e                	sd	s3,8(sp)
    80004782:	84aa                	mv	s1,a0
    80004784:	892e                	mv	s2,a1
    80004786:	89b2                	mv	s3,a2
    return -1;

  if(f->type == FD_PIPE){
    80004788:	411c                	lw	a5,0(a0)
    8000478a:	4705                	li	a4,1
    8000478c:	04e78363          	beq	a5,a4,800047d2 <fileread+0x64>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004790:	470d                	li	a4,3
    80004792:	04e78763          	beq	a5,a4,800047e0 <fileread+0x72>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    80004796:	4709                	li	a4,2
    80004798:	06e79a63          	bne	a5,a4,8000480c <fileread+0x9e>
    ilock(f->ip);
    8000479c:	6d08                	ld	a0,24(a0)
    8000479e:	87cff0ef          	jal	8000381a <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    800047a2:	874e                	mv	a4,s3
    800047a4:	5094                	lw	a3,32(s1)
    800047a6:	864a                	mv	a2,s2
    800047a8:	4585                	li	a1,1
    800047aa:	6c88                	ld	a0,24(s1)
    800047ac:	c00ff0ef          	jal	80003bac <readi>
    800047b0:	892a                	mv	s2,a0
    800047b2:	00a05563          	blez	a0,800047bc <fileread+0x4e>
      f->off += r;
    800047b6:	509c                	lw	a5,32(s1)
    800047b8:	9fa9                	addw	a5,a5,a0
    800047ba:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    800047bc:	6c88                	ld	a0,24(s1)
    800047be:	90aff0ef          	jal	800038c8 <iunlock>
    800047c2:	64e2                	ld	s1,24(sp)
    800047c4:	69a2                	ld	s3,8(sp)
  } else {
    panic("fileread");
  }

  return r;
}
    800047c6:	854a                	mv	a0,s2
    800047c8:	70a2                	ld	ra,40(sp)
    800047ca:	7402                	ld	s0,32(sp)
    800047cc:	6942                	ld	s2,16(sp)
    800047ce:	6145                	addi	sp,sp,48
    800047d0:	8082                	ret
    r = piperead(f->pipe, addr, n);
    800047d2:	6908                	ld	a0,16(a0)
    800047d4:	3b0000ef          	jal	80004b84 <piperead>
    800047d8:	892a                	mv	s2,a0
    800047da:	64e2                	ld	s1,24(sp)
    800047dc:	69a2                	ld	s3,8(sp)
    800047de:	b7e5                	j	800047c6 <fileread+0x58>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    800047e0:	02451783          	lh	a5,36(a0)
    800047e4:	03079693          	slli	a3,a5,0x30
    800047e8:	92c1                	srli	a3,a3,0x30
    800047ea:	4725                	li	a4,9
    800047ec:	02d76963          	bltu	a4,a3,8000481e <fileread+0xb0>
    800047f0:	0792                	slli	a5,a5,0x4
    800047f2:	0001c717          	auipc	a4,0x1c
    800047f6:	32670713          	addi	a4,a4,806 # 80020b18 <devsw>
    800047fa:	97ba                	add	a5,a5,a4
    800047fc:	639c                	ld	a5,0(a5)
    800047fe:	c78d                	beqz	a5,80004828 <fileread+0xba>
    r = devsw[f->major].read(1, addr, n);
    80004800:	4505                	li	a0,1
    80004802:	9782                	jalr	a5
    80004804:	892a                	mv	s2,a0
    80004806:	64e2                	ld	s1,24(sp)
    80004808:	69a2                	ld	s3,8(sp)
    8000480a:	bf75                	j	800047c6 <fileread+0x58>
    panic("fileread");
    8000480c:	00004517          	auipc	a0,0x4
    80004810:	dd450513          	addi	a0,a0,-556 # 800085e0 <etext+0x5e0>
    80004814:	842fc0ef          	jal	80000856 <panic>
    return -1;
    80004818:	57fd                	li	a5,-1
    8000481a:	893e                	mv	s2,a5
    8000481c:	b76d                	j	800047c6 <fileread+0x58>
      return -1;
    8000481e:	57fd                	li	a5,-1
    80004820:	893e                	mv	s2,a5
    80004822:	64e2                	ld	s1,24(sp)
    80004824:	69a2                	ld	s3,8(sp)
    80004826:	b745                	j	800047c6 <fileread+0x58>
    80004828:	57fd                	li	a5,-1
    8000482a:	893e                	mv	s2,a5
    8000482c:	64e2                	ld	s1,24(sp)
    8000482e:	69a2                	ld	s3,8(sp)
    80004830:	bf59                	j	800047c6 <fileread+0x58>

0000000080004832 <filewrite>:
int
filewrite(struct file *f, uint64 addr, int n)
{
  int r, ret = 0;

  if(f->writable == 0)
    80004832:	00954783          	lbu	a5,9(a0)
    80004836:	10078f63          	beqz	a5,80004954 <filewrite+0x122>
{
    8000483a:	711d                	addi	sp,sp,-96
    8000483c:	ec86                	sd	ra,88(sp)
    8000483e:	e8a2                	sd	s0,80(sp)
    80004840:	e0ca                	sd	s2,64(sp)
    80004842:	f456                	sd	s5,40(sp)
    80004844:	f05a                	sd	s6,32(sp)
    80004846:	1080                	addi	s0,sp,96
    80004848:	892a                	mv	s2,a0
    8000484a:	8b2e                	mv	s6,a1
    8000484c:	8ab2                	mv	s5,a2
    return -1;

  if(f->type == FD_PIPE){
    8000484e:	411c                	lw	a5,0(a0)
    80004850:	4705                	li	a4,1
    80004852:	02e78a63          	beq	a5,a4,80004886 <filewrite+0x54>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004856:	470d                	li	a4,3
    80004858:	02e78b63          	beq	a5,a4,8000488e <filewrite+0x5c>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    8000485c:	4709                	li	a4,2
    8000485e:	0ce79f63          	bne	a5,a4,8000493c <filewrite+0x10a>
    80004862:	f852                	sd	s4,48(sp)
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    80004864:	0ac05a63          	blez	a2,80004918 <filewrite+0xe6>
    80004868:	e4a6                	sd	s1,72(sp)
    8000486a:	fc4e                	sd	s3,56(sp)
    8000486c:	ec5e                	sd	s7,24(sp)
    8000486e:	e862                	sd	s8,16(sp)
    80004870:	e466                	sd	s9,8(sp)
    int i = 0;
    80004872:	4a01                	li	s4,0
      int n1 = n - i;
      if(n1 > max)
    80004874:	6b85                	lui	s7,0x1
    80004876:	c00b8b93          	addi	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    8000487a:	6785                	lui	a5,0x1
    8000487c:	c007879b          	addiw	a5,a5,-1024 # c00 <_entry-0x7ffff400>
    80004880:	8cbe                	mv	s9,a5
        n1 = max;

      begin_op();
      ilock(f->ip);
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80004882:	4c05                	li	s8,1
    80004884:	a8ad                	j	800048fe <filewrite+0xcc>
    ret = pipewrite(f->pipe, addr, n);
    80004886:	6908                	ld	a0,16(a0)
    80004888:	204000ef          	jal	80004a8c <pipewrite>
    8000488c:	a04d                	j	8000492e <filewrite+0xfc>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    8000488e:	02451783          	lh	a5,36(a0)
    80004892:	03079693          	slli	a3,a5,0x30
    80004896:	92c1                	srli	a3,a3,0x30
    80004898:	4725                	li	a4,9
    8000489a:	0ad76f63          	bltu	a4,a3,80004958 <filewrite+0x126>
    8000489e:	0792                	slli	a5,a5,0x4
    800048a0:	0001c717          	auipc	a4,0x1c
    800048a4:	27870713          	addi	a4,a4,632 # 80020b18 <devsw>
    800048a8:	97ba                	add	a5,a5,a4
    800048aa:	679c                	ld	a5,8(a5)
    800048ac:	cbc5                	beqz	a5,8000495c <filewrite+0x12a>
    ret = devsw[f->major].write(1, addr, n);
    800048ae:	4505                	li	a0,1
    800048b0:	9782                	jalr	a5
    800048b2:	a8b5                	j	8000492e <filewrite+0xfc>
      if(n1 > max)
    800048b4:	2981                	sext.w	s3,s3
      begin_op();
    800048b6:	971ff0ef          	jal	80004226 <begin_op>
      ilock(f->ip);
    800048ba:	01893503          	ld	a0,24(s2)
    800048be:	f5dfe0ef          	jal	8000381a <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    800048c2:	874e                	mv	a4,s3
    800048c4:	02092683          	lw	a3,32(s2)
    800048c8:	016a0633          	add	a2,s4,s6
    800048cc:	85e2                	mv	a1,s8
    800048ce:	01893503          	ld	a0,24(s2)
    800048d2:	bccff0ef          	jal	80003c9e <writei>
    800048d6:	84aa                	mv	s1,a0
    800048d8:	00a05763          	blez	a0,800048e6 <filewrite+0xb4>
        f->off += r;
    800048dc:	02092783          	lw	a5,32(s2)
    800048e0:	9fa9                	addw	a5,a5,a0
    800048e2:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    800048e6:	01893503          	ld	a0,24(s2)
    800048ea:	fdffe0ef          	jal	800038c8 <iunlock>
      end_op();
    800048ee:	9a9ff0ef          	jal	80004296 <end_op>

      if(r != n1){
    800048f2:	02999563          	bne	s3,s1,8000491c <filewrite+0xea>
        // error from writei
        break;
      }
      i += r;
    800048f6:	01448a3b          	addw	s4,s1,s4
    while(i < n){
    800048fa:	015a5963          	bge	s4,s5,8000490c <filewrite+0xda>
      int n1 = n - i;
    800048fe:	414a87bb          	subw	a5,s5,s4
    80004902:	89be                	mv	s3,a5
      if(n1 > max)
    80004904:	fafbd8e3          	bge	s7,a5,800048b4 <filewrite+0x82>
    80004908:	89e6                	mv	s3,s9
    8000490a:	b76d                	j	800048b4 <filewrite+0x82>
    8000490c:	64a6                	ld	s1,72(sp)
    8000490e:	79e2                	ld	s3,56(sp)
    80004910:	6be2                	ld	s7,24(sp)
    80004912:	6c42                	ld	s8,16(sp)
    80004914:	6ca2                	ld	s9,8(sp)
    80004916:	a801                	j	80004926 <filewrite+0xf4>
    int i = 0;
    80004918:	4a01                	li	s4,0
    8000491a:	a031                	j	80004926 <filewrite+0xf4>
    8000491c:	64a6                	ld	s1,72(sp)
    8000491e:	79e2                	ld	s3,56(sp)
    80004920:	6be2                	ld	s7,24(sp)
    80004922:	6c42                	ld	s8,16(sp)
    80004924:	6ca2                	ld	s9,8(sp)
    }
    ret = (i == n ? n : -1);
    80004926:	034a9d63          	bne	s5,s4,80004960 <filewrite+0x12e>
    8000492a:	8556                	mv	a0,s5
    8000492c:	7a42                	ld	s4,48(sp)
  } else {
    panic("filewrite");
  }

  return ret;
}
    8000492e:	60e6                	ld	ra,88(sp)
    80004930:	6446                	ld	s0,80(sp)
    80004932:	6906                	ld	s2,64(sp)
    80004934:	7aa2                	ld	s5,40(sp)
    80004936:	7b02                	ld	s6,32(sp)
    80004938:	6125                	addi	sp,sp,96
    8000493a:	8082                	ret
    8000493c:	e4a6                	sd	s1,72(sp)
    8000493e:	fc4e                	sd	s3,56(sp)
    80004940:	f852                	sd	s4,48(sp)
    80004942:	ec5e                	sd	s7,24(sp)
    80004944:	e862                	sd	s8,16(sp)
    80004946:	e466                	sd	s9,8(sp)
    panic("filewrite");
    80004948:	00004517          	auipc	a0,0x4
    8000494c:	ca850513          	addi	a0,a0,-856 # 800085f0 <etext+0x5f0>
    80004950:	f07fb0ef          	jal	80000856 <panic>
    return -1;
    80004954:	557d                	li	a0,-1
}
    80004956:	8082                	ret
      return -1;
    80004958:	557d                	li	a0,-1
    8000495a:	bfd1                	j	8000492e <filewrite+0xfc>
    8000495c:	557d                	li	a0,-1
    8000495e:	bfc1                	j	8000492e <filewrite+0xfc>
    ret = (i == n ? n : -1);
    80004960:	557d                	li	a0,-1
    80004962:	7a42                	ld	s4,48(sp)
    80004964:	b7e9                	j	8000492e <filewrite+0xfc>

0000000080004966 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80004966:	7179                	addi	sp,sp,-48
    80004968:	f406                	sd	ra,40(sp)
    8000496a:	f022                	sd	s0,32(sp)
    8000496c:	ec26                	sd	s1,24(sp)
    8000496e:	e052                	sd	s4,0(sp)
    80004970:	1800                	addi	s0,sp,48
    80004972:	84aa                	mv	s1,a0
    80004974:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80004976:	0005b023          	sd	zero,0(a1)
    8000497a:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    8000497e:	c29ff0ef          	jal	800045a6 <filealloc>
    80004982:	e088                	sd	a0,0(s1)
    80004984:	c549                	beqz	a0,80004a0e <pipealloc+0xa8>
    80004986:	c21ff0ef          	jal	800045a6 <filealloc>
    8000498a:	00aa3023          	sd	a0,0(s4)
    8000498e:	cd25                	beqz	a0,80004a06 <pipealloc+0xa0>
    80004990:	e84a                	sd	s2,16(sp)
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80004992:	a42fc0ef          	jal	80000bd4 <kalloc>
    80004996:	892a                	mv	s2,a0
    80004998:	c12d                	beqz	a0,800049fa <pipealloc+0x94>
    8000499a:	e44e                	sd	s3,8(sp)
    goto bad;
  pi->readopen = 1;
    8000499c:	4985                	li	s3,1
    8000499e:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    800049a2:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    800049a6:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    800049aa:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    800049ae:	00004597          	auipc	a1,0x4
    800049b2:	c5258593          	addi	a1,a1,-942 # 80008600 <etext+0x600>
    800049b6:	ad6fc0ef          	jal	80000c8c <initlock>
  (*f0)->type = FD_PIPE;
    800049ba:	609c                	ld	a5,0(s1)
    800049bc:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    800049c0:	609c                	ld	a5,0(s1)
    800049c2:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    800049c6:	609c                	ld	a5,0(s1)
    800049c8:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    800049cc:	609c                	ld	a5,0(s1)
    800049ce:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    800049d2:	000a3783          	ld	a5,0(s4)
    800049d6:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    800049da:	000a3783          	ld	a5,0(s4)
    800049de:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    800049e2:	000a3783          	ld	a5,0(s4)
    800049e6:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    800049ea:	000a3783          	ld	a5,0(s4)
    800049ee:	0127b823          	sd	s2,16(a5)
  return 0;
    800049f2:	4501                	li	a0,0
    800049f4:	6942                	ld	s2,16(sp)
    800049f6:	69a2                	ld	s3,8(sp)
    800049f8:	a01d                	j	80004a1e <pipealloc+0xb8>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    800049fa:	6088                	ld	a0,0(s1)
    800049fc:	c119                	beqz	a0,80004a02 <pipealloc+0x9c>
    800049fe:	6942                	ld	s2,16(sp)
    80004a00:	a029                	j	80004a0a <pipealloc+0xa4>
    80004a02:	6942                	ld	s2,16(sp)
    80004a04:	a029                	j	80004a0e <pipealloc+0xa8>
    80004a06:	6088                	ld	a0,0(s1)
    80004a08:	c10d                	beqz	a0,80004a2a <pipealloc+0xc4>
    fileclose(*f0);
    80004a0a:	c41ff0ef          	jal	8000464a <fileclose>
  if(*f1)
    80004a0e:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80004a12:	557d                	li	a0,-1
  if(*f1)
    80004a14:	c789                	beqz	a5,80004a1e <pipealloc+0xb8>
    fileclose(*f1);
    80004a16:	853e                	mv	a0,a5
    80004a18:	c33ff0ef          	jal	8000464a <fileclose>
  return -1;
    80004a1c:	557d                	li	a0,-1
}
    80004a1e:	70a2                	ld	ra,40(sp)
    80004a20:	7402                	ld	s0,32(sp)
    80004a22:	64e2                	ld	s1,24(sp)
    80004a24:	6a02                	ld	s4,0(sp)
    80004a26:	6145                	addi	sp,sp,48
    80004a28:	8082                	ret
  return -1;
    80004a2a:	557d                	li	a0,-1
    80004a2c:	bfcd                	j	80004a1e <pipealloc+0xb8>

0000000080004a2e <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80004a2e:	1101                	addi	sp,sp,-32
    80004a30:	ec06                	sd	ra,24(sp)
    80004a32:	e822                	sd	s0,16(sp)
    80004a34:	e426                	sd	s1,8(sp)
    80004a36:	e04a                	sd	s2,0(sp)
    80004a38:	1000                	addi	s0,sp,32
    80004a3a:	84aa                	mv	s1,a0
    80004a3c:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80004a3e:	ad8fc0ef          	jal	80000d16 <acquire>
  if(writable){
    80004a42:	02090763          	beqz	s2,80004a70 <pipeclose+0x42>
    pi->writeopen = 0;
    80004a46:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80004a4a:	21848513          	addi	a0,s1,536
    80004a4e:	a71fd0ef          	jal	800024be <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80004a52:	2204a783          	lw	a5,544(s1)
    80004a56:	e781                	bnez	a5,80004a5e <pipeclose+0x30>
    80004a58:	2244a783          	lw	a5,548(s1)
    80004a5c:	c38d                	beqz	a5,80004a7e <pipeclose+0x50>
    release(&pi->lock);
    kfree((char*)pi);
  } else
    release(&pi->lock);
    80004a5e:	8526                	mv	a0,s1
    80004a60:	b4afc0ef          	jal	80000daa <release>
}
    80004a64:	60e2                	ld	ra,24(sp)
    80004a66:	6442                	ld	s0,16(sp)
    80004a68:	64a2                	ld	s1,8(sp)
    80004a6a:	6902                	ld	s2,0(sp)
    80004a6c:	6105                	addi	sp,sp,32
    80004a6e:	8082                	ret
    pi->readopen = 0;
    80004a70:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80004a74:	21c48513          	addi	a0,s1,540
    80004a78:	a47fd0ef          	jal	800024be <wakeup>
    80004a7c:	bfd9                	j	80004a52 <pipeclose+0x24>
    release(&pi->lock);
    80004a7e:	8526                	mv	a0,s1
    80004a80:	b2afc0ef          	jal	80000daa <release>
    kfree((char*)pi);
    80004a84:	8526                	mv	a0,s1
    80004a86:	808fc0ef          	jal	80000a8e <kfree>
    80004a8a:	bfe9                	j	80004a64 <pipeclose+0x36>

0000000080004a8c <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80004a8c:	7159                	addi	sp,sp,-112
    80004a8e:	f486                	sd	ra,104(sp)
    80004a90:	f0a2                	sd	s0,96(sp)
    80004a92:	eca6                	sd	s1,88(sp)
    80004a94:	e8ca                	sd	s2,80(sp)
    80004a96:	e4ce                	sd	s3,72(sp)
    80004a98:	e0d2                	sd	s4,64(sp)
    80004a9a:	fc56                	sd	s5,56(sp)
    80004a9c:	1880                	addi	s0,sp,112
    80004a9e:	84aa                	mv	s1,a0
    80004aa0:	8aae                	mv	s5,a1
    80004aa2:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    80004aa4:	984fd0ef          	jal	80001c28 <myproc>
    80004aa8:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    80004aaa:	8526                	mv	a0,s1
    80004aac:	a6afc0ef          	jal	80000d16 <acquire>
  while(i < n){
    80004ab0:	0d405263          	blez	s4,80004b74 <pipewrite+0xe8>
    80004ab4:	f85a                	sd	s6,48(sp)
    80004ab6:	f45e                	sd	s7,40(sp)
    80004ab8:	f062                	sd	s8,32(sp)
    80004aba:	ec66                	sd	s9,24(sp)
    80004abc:	e86a                	sd	s10,16(sp)
  int i = 0;
    80004abe:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004ac0:	f9f40c13          	addi	s8,s0,-97
    80004ac4:	4b85                	li	s7,1
    80004ac6:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    80004ac8:	21848d13          	addi	s10,s1,536
      sleep(&pi->nwrite, &pi->lock);
    80004acc:	21c48c93          	addi	s9,s1,540
    80004ad0:	a82d                	j	80004b0a <pipewrite+0x7e>
      release(&pi->lock);
    80004ad2:	8526                	mv	a0,s1
    80004ad4:	ad6fc0ef          	jal	80000daa <release>
      return -1;
    80004ad8:	597d                	li	s2,-1
    80004ada:	7b42                	ld	s6,48(sp)
    80004adc:	7ba2                	ld	s7,40(sp)
    80004ade:	7c02                	ld	s8,32(sp)
    80004ae0:	6ce2                	ld	s9,24(sp)
    80004ae2:	6d42                	ld	s10,16(sp)
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    80004ae4:	854a                	mv	a0,s2
    80004ae6:	70a6                	ld	ra,104(sp)
    80004ae8:	7406                	ld	s0,96(sp)
    80004aea:	64e6                	ld	s1,88(sp)
    80004aec:	6946                	ld	s2,80(sp)
    80004aee:	69a6                	ld	s3,72(sp)
    80004af0:	6a06                	ld	s4,64(sp)
    80004af2:	7ae2                	ld	s5,56(sp)
    80004af4:	6165                	addi	sp,sp,112
    80004af6:	8082                	ret
      wakeup(&pi->nread);
    80004af8:	856a                	mv	a0,s10
    80004afa:	9c5fd0ef          	jal	800024be <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80004afe:	85a6                	mv	a1,s1
    80004b00:	8566                	mv	a0,s9
    80004b02:	971fd0ef          	jal	80002472 <sleep>
  while(i < n){
    80004b06:	05495a63          	bge	s2,s4,80004b5a <pipewrite+0xce>
    if(pi->readopen == 0 || killed(pr)){
    80004b0a:	2204a783          	lw	a5,544(s1)
    80004b0e:	d3f1                	beqz	a5,80004ad2 <pipewrite+0x46>
    80004b10:	854e                	mv	a0,s3
    80004b12:	b9dfd0ef          	jal	800026ae <killed>
    80004b16:	fd55                	bnez	a0,80004ad2 <pipewrite+0x46>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    80004b18:	2184a783          	lw	a5,536(s1)
    80004b1c:	21c4a703          	lw	a4,540(s1)
    80004b20:	2007879b          	addiw	a5,a5,512
    80004b24:	fcf70ae3          	beq	a4,a5,80004af8 <pipewrite+0x6c>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004b28:	86de                	mv	a3,s7
    80004b2a:	01590633          	add	a2,s2,s5
    80004b2e:	85e2                	mv	a1,s8
    80004b30:	0509b503          	ld	a0,80(s3)
    80004b34:	ec5fc0ef          	jal	800019f8 <copyin>
    80004b38:	05650063          	beq	a0,s6,80004b78 <pipewrite+0xec>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80004b3c:	21c4a783          	lw	a5,540(s1)
    80004b40:	0017871b          	addiw	a4,a5,1
    80004b44:	20e4ae23          	sw	a4,540(s1)
    80004b48:	1ff7f793          	andi	a5,a5,511
    80004b4c:	97a6                	add	a5,a5,s1
    80004b4e:	f9f44703          	lbu	a4,-97(s0)
    80004b52:	00e78c23          	sb	a4,24(a5)
      i++;
    80004b56:	2905                	addiw	s2,s2,1
    80004b58:	b77d                	j	80004b06 <pipewrite+0x7a>
    80004b5a:	7b42                	ld	s6,48(sp)
    80004b5c:	7ba2                	ld	s7,40(sp)
    80004b5e:	7c02                	ld	s8,32(sp)
    80004b60:	6ce2                	ld	s9,24(sp)
    80004b62:	6d42                	ld	s10,16(sp)
  wakeup(&pi->nread);
    80004b64:	21848513          	addi	a0,s1,536
    80004b68:	957fd0ef          	jal	800024be <wakeup>
  release(&pi->lock);
    80004b6c:	8526                	mv	a0,s1
    80004b6e:	a3cfc0ef          	jal	80000daa <release>
  return i;
    80004b72:	bf8d                	j	80004ae4 <pipewrite+0x58>
  int i = 0;
    80004b74:	4901                	li	s2,0
    80004b76:	b7fd                	j	80004b64 <pipewrite+0xd8>
    80004b78:	7b42                	ld	s6,48(sp)
    80004b7a:	7ba2                	ld	s7,40(sp)
    80004b7c:	7c02                	ld	s8,32(sp)
    80004b7e:	6ce2                	ld	s9,24(sp)
    80004b80:	6d42                	ld	s10,16(sp)
    80004b82:	b7cd                	j	80004b64 <pipewrite+0xd8>

0000000080004b84 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80004b84:	711d                	addi	sp,sp,-96
    80004b86:	ec86                	sd	ra,88(sp)
    80004b88:	e8a2                	sd	s0,80(sp)
    80004b8a:	e4a6                	sd	s1,72(sp)
    80004b8c:	e0ca                	sd	s2,64(sp)
    80004b8e:	fc4e                	sd	s3,56(sp)
    80004b90:	f852                	sd	s4,48(sp)
    80004b92:	f456                	sd	s5,40(sp)
    80004b94:	1080                	addi	s0,sp,96
    80004b96:	84aa                	mv	s1,a0
    80004b98:	892e                	mv	s2,a1
    80004b9a:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80004b9c:	88cfd0ef          	jal	80001c28 <myproc>
    80004ba0:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80004ba2:	8526                	mv	a0,s1
    80004ba4:	972fc0ef          	jal	80000d16 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004ba8:	2184a703          	lw	a4,536(s1)
    80004bac:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004bb0:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004bb4:	02f71763          	bne	a4,a5,80004be2 <piperead+0x5e>
    80004bb8:	2244a783          	lw	a5,548(s1)
    80004bbc:	cf85                	beqz	a5,80004bf4 <piperead+0x70>
    if(killed(pr)){
    80004bbe:	8552                	mv	a0,s4
    80004bc0:	aeffd0ef          	jal	800026ae <killed>
    80004bc4:	e11d                	bnez	a0,80004bea <piperead+0x66>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004bc6:	85a6                	mv	a1,s1
    80004bc8:	854e                	mv	a0,s3
    80004bca:	8a9fd0ef          	jal	80002472 <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004bce:	2184a703          	lw	a4,536(s1)
    80004bd2:	21c4a783          	lw	a5,540(s1)
    80004bd6:	fef701e3          	beq	a4,a5,80004bb8 <piperead+0x34>
    80004bda:	f05a                	sd	s6,32(sp)
    80004bdc:	ec5e                	sd	s7,24(sp)
    80004bde:	e862                	sd	s8,16(sp)
    80004be0:	a829                	j	80004bfa <piperead+0x76>
    80004be2:	f05a                	sd	s6,32(sp)
    80004be4:	ec5e                	sd	s7,24(sp)
    80004be6:	e862                	sd	s8,16(sp)
    80004be8:	a809                	j	80004bfa <piperead+0x76>
      release(&pi->lock);
    80004bea:	8526                	mv	a0,s1
    80004bec:	9befc0ef          	jal	80000daa <release>
      return -1;
    80004bf0:	59fd                	li	s3,-1
    80004bf2:	a0a5                	j	80004c5a <piperead+0xd6>
    80004bf4:	f05a                	sd	s6,32(sp)
    80004bf6:	ec5e                	sd	s7,24(sp)
    80004bf8:	e862                	sd	s8,16(sp)
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004bfa:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1) {
    80004bfc:	faf40c13          	addi	s8,s0,-81
    80004c00:	4b85                	li	s7,1
    80004c02:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004c04:	05505163          	blez	s5,80004c46 <piperead+0xc2>
    if(pi->nread == pi->nwrite)
    80004c08:	2184a783          	lw	a5,536(s1)
    80004c0c:	21c4a703          	lw	a4,540(s1)
    80004c10:	02f70b63          	beq	a4,a5,80004c46 <piperead+0xc2>
    ch = pi->data[pi->nread % PIPESIZE];
    80004c14:	1ff7f793          	andi	a5,a5,511
    80004c18:	97a6                	add	a5,a5,s1
    80004c1a:	0187c783          	lbu	a5,24(a5)
    80004c1e:	faf407a3          	sb	a5,-81(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1) {
    80004c22:	86de                	mv	a3,s7
    80004c24:	8662                	mv	a2,s8
    80004c26:	85ca                	mv	a1,s2
    80004c28:	050a3503          	ld	a0,80(s4)
    80004c2c:	d0ffc0ef          	jal	8000193a <copyout>
    80004c30:	03650f63          	beq	a0,s6,80004c6e <piperead+0xea>
      if(i == 0)
        i = -1;
      break;
    }
    pi->nread++;
    80004c34:	2184a783          	lw	a5,536(s1)
    80004c38:	2785                	addiw	a5,a5,1
    80004c3a:	20f4ac23          	sw	a5,536(s1)
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004c3e:	2985                	addiw	s3,s3,1
    80004c40:	0905                	addi	s2,s2,1
    80004c42:	fd3a93e3          	bne	s5,s3,80004c08 <piperead+0x84>
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80004c46:	21c48513          	addi	a0,s1,540
    80004c4a:	875fd0ef          	jal	800024be <wakeup>
  release(&pi->lock);
    80004c4e:	8526                	mv	a0,s1
    80004c50:	95afc0ef          	jal	80000daa <release>
    80004c54:	7b02                	ld	s6,32(sp)
    80004c56:	6be2                	ld	s7,24(sp)
    80004c58:	6c42                	ld	s8,16(sp)
  return i;
}
    80004c5a:	854e                	mv	a0,s3
    80004c5c:	60e6                	ld	ra,88(sp)
    80004c5e:	6446                	ld	s0,80(sp)
    80004c60:	64a6                	ld	s1,72(sp)
    80004c62:	6906                	ld	s2,64(sp)
    80004c64:	79e2                	ld	s3,56(sp)
    80004c66:	7a42                	ld	s4,48(sp)
    80004c68:	7aa2                	ld	s5,40(sp)
    80004c6a:	6125                	addi	sp,sp,96
    80004c6c:	8082                	ret
      if(i == 0)
    80004c6e:	fc099ce3          	bnez	s3,80004c46 <piperead+0xc2>
        i = -1;
    80004c72:	89aa                	mv	s3,a0
    80004c74:	bfc9                	j	80004c46 <piperead+0xc2>

0000000080004c76 <flags2perm>:

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

// map ELF permissions to PTE permission bits.
int flags2perm(int flags)
{
    80004c76:	1141                	addi	sp,sp,-16
    80004c78:	e406                	sd	ra,8(sp)
    80004c7a:	e022                	sd	s0,0(sp)
    80004c7c:	0800                	addi	s0,sp,16
    80004c7e:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    80004c80:	0035151b          	slliw	a0,a0,0x3
    80004c84:	8921                	andi	a0,a0,8
      perm = PTE_X;
    if(flags & 0x2)
    80004c86:	8b89                	andi	a5,a5,2
    80004c88:	c399                	beqz	a5,80004c8e <flags2perm+0x18>
      perm |= PTE_W;
    80004c8a:	00456513          	ori	a0,a0,4
    return perm;
}
    80004c8e:	60a2                	ld	ra,8(sp)
    80004c90:	6402                	ld	s0,0(sp)
    80004c92:	0141                	addi	sp,sp,16
    80004c94:	8082                	ret

0000000080004c96 <kexec>:
//
// the implementation of the exec() system call
//
int
kexec(char *path, char **argv)
{
    80004c96:	de010113          	addi	sp,sp,-544
    80004c9a:	20113c23          	sd	ra,536(sp)
    80004c9e:	20813823          	sd	s0,528(sp)
    80004ca2:	20913423          	sd	s1,520(sp)
    80004ca6:	21213023          	sd	s2,512(sp)
    80004caa:	1400                	addi	s0,sp,544
    80004cac:	892a                	mv	s2,a0
    80004cae:	dea43823          	sd	a0,-528(s0)
    80004cb2:	e0b43023          	sd	a1,-512(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80004cb6:	f73fc0ef          	jal	80001c28 <myproc>
    80004cba:	84aa                	mv	s1,a0

  begin_op();
    80004cbc:	d6aff0ef          	jal	80004226 <begin_op>

  // Open the executable file.
  if((ip = namei(path)) == 0){
    80004cc0:	854a                	mv	a0,s2
    80004cc2:	b86ff0ef          	jal	80004048 <namei>
    80004cc6:	cd21                	beqz	a0,80004d1e <kexec+0x88>
    80004cc8:	fbd2                	sd	s4,496(sp)
    80004cca:	8a2a                	mv	s4,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80004ccc:	b4ffe0ef          	jal	8000381a <ilock>

  // Read the ELF header.
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80004cd0:	04000713          	li	a4,64
    80004cd4:	4681                	li	a3,0
    80004cd6:	e5040613          	addi	a2,s0,-432
    80004cda:	4581                	li	a1,0
    80004cdc:	8552                	mv	a0,s4
    80004cde:	ecffe0ef          	jal	80003bac <readi>
    80004ce2:	04000793          	li	a5,64
    80004ce6:	00f51a63          	bne	a0,a5,80004cfa <kexec+0x64>
    goto bad;

  // Is this really an ELF file?
  if(elf.magic != ELF_MAGIC)
    80004cea:	e5042703          	lw	a4,-432(s0)
    80004cee:	464c47b7          	lui	a5,0x464c4
    80004cf2:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80004cf6:	02f70863          	beq	a4,a5,80004d26 <kexec+0x90>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    80004cfa:	8552                	mv	a0,s4
    80004cfc:	d2bfe0ef          	jal	80003a26 <iunlockput>
    end_op();
    80004d00:	d96ff0ef          	jal	80004296 <end_op>
  }
  return -1;
    80004d04:	557d                	li	a0,-1
    80004d06:	7a5e                	ld	s4,496(sp)
}
    80004d08:	21813083          	ld	ra,536(sp)
    80004d0c:	21013403          	ld	s0,528(sp)
    80004d10:	20813483          	ld	s1,520(sp)
    80004d14:	20013903          	ld	s2,512(sp)
    80004d18:	22010113          	addi	sp,sp,544
    80004d1c:	8082                	ret
    end_op();
    80004d1e:	d78ff0ef          	jal	80004296 <end_op>
    return -1;
    80004d22:	557d                	li	a0,-1
    80004d24:	b7d5                	j	80004d08 <kexec+0x72>
    80004d26:	f3da                	sd	s6,480(sp)
  if((pagetable = proc_pagetable(p)) == 0)
    80004d28:	8526                	mv	a0,s1
    80004d2a:	808fd0ef          	jal	80001d32 <proc_pagetable>
    80004d2e:	8b2a                	mv	s6,a0
    80004d30:	26050f63          	beqz	a0,80004fae <kexec+0x318>
    80004d34:	ffce                	sd	s3,504(sp)
    80004d36:	f7d6                	sd	s5,488(sp)
    80004d38:	efde                	sd	s7,472(sp)
    80004d3a:	ebe2                	sd	s8,464(sp)
    80004d3c:	e7e6                	sd	s9,456(sp)
    80004d3e:	e3ea                	sd	s10,448(sp)
    80004d40:	ff6e                	sd	s11,440(sp)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004d42:	e8845783          	lhu	a5,-376(s0)
    80004d46:	0e078963          	beqz	a5,80004e38 <kexec+0x1a2>
    80004d4a:	e7042683          	lw	a3,-400(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004d4e:	4901                	li	s2,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004d50:	4d01                	li	s10,0
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80004d52:	03800d93          	li	s11,56
    if(ph.vaddr % PGSIZE != 0)
    80004d56:	6c85                	lui	s9,0x1
    80004d58:	fffc8793          	addi	a5,s9,-1 # fff <_entry-0x7ffff001>
    80004d5c:	def43423          	sd	a5,-536(s0)

  for(i = 0; i < sz; i += PGSIZE){
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    if(sz - i < PGSIZE)
    80004d60:	6a85                	lui	s5,0x1
    80004d62:	a085                	j	80004dc2 <kexec+0x12c>
      panic("loadseg: address should exist");
    80004d64:	00004517          	auipc	a0,0x4
    80004d68:	8a450513          	addi	a0,a0,-1884 # 80008608 <etext+0x608>
    80004d6c:	aebfb0ef          	jal	80000856 <panic>
    if(sz - i < PGSIZE)
    80004d70:	2901                	sext.w	s2,s2
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80004d72:	874a                	mv	a4,s2
    80004d74:	009b86bb          	addw	a3,s7,s1
    80004d78:	4581                	li	a1,0
    80004d7a:	8552                	mv	a0,s4
    80004d7c:	e31fe0ef          	jal	80003bac <readi>
    80004d80:	22a91b63          	bne	s2,a0,80004fb6 <kexec+0x320>
  for(i = 0; i < sz; i += PGSIZE){
    80004d84:	009a84bb          	addw	s1,s5,s1
    80004d88:	0334f263          	bgeu	s1,s3,80004dac <kexec+0x116>
    pa = walkaddr(pagetable, va + i);
    80004d8c:	02049593          	slli	a1,s1,0x20
    80004d90:	9181                	srli	a1,a1,0x20
    80004d92:	95e2                	add	a1,a1,s8
    80004d94:	855a                	mv	a0,s6
    80004d96:	b8afc0ef          	jal	80001120 <walkaddr>
    80004d9a:	862a                	mv	a2,a0
    if(pa == 0)
    80004d9c:	d561                	beqz	a0,80004d64 <kexec+0xce>
    if(sz - i < PGSIZE)
    80004d9e:	409987bb          	subw	a5,s3,s1
    80004da2:	893e                	mv	s2,a5
    80004da4:	fcfcf6e3          	bgeu	s9,a5,80004d70 <kexec+0xda>
    80004da8:	8956                	mv	s2,s5
    80004daa:	b7d9                	j	80004d70 <kexec+0xda>
    sz = sz1;
    80004dac:	df843903          	ld	s2,-520(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004db0:	2d05                	addiw	s10,s10,1
    80004db2:	e0843783          	ld	a5,-504(s0)
    80004db6:	0387869b          	addiw	a3,a5,56
    80004dba:	e8845783          	lhu	a5,-376(s0)
    80004dbe:	06fd5e63          	bge	s10,a5,80004e3a <kexec+0x1a4>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80004dc2:	e0d43423          	sd	a3,-504(s0)
    80004dc6:	876e                	mv	a4,s11
    80004dc8:	e1840613          	addi	a2,s0,-488
    80004dcc:	4581                	li	a1,0
    80004dce:	8552                	mv	a0,s4
    80004dd0:	dddfe0ef          	jal	80003bac <readi>
    80004dd4:	1db51f63          	bne	a0,s11,80004fb2 <kexec+0x31c>
    if(ph.type != ELF_PROG_LOAD)
    80004dd8:	e1842783          	lw	a5,-488(s0)
    80004ddc:	4705                	li	a4,1
    80004dde:	fce799e3          	bne	a5,a4,80004db0 <kexec+0x11a>
    if(ph.memsz < ph.filesz)
    80004de2:	e4043483          	ld	s1,-448(s0)
    80004de6:	e3843783          	ld	a5,-456(s0)
    80004dea:	1ef4e463          	bltu	s1,a5,80004fd2 <kexec+0x33c>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    80004dee:	e2843783          	ld	a5,-472(s0)
    80004df2:	94be                	add	s1,s1,a5
    80004df4:	1ef4e263          	bltu	s1,a5,80004fd8 <kexec+0x342>
    if(ph.vaddr % PGSIZE != 0)
    80004df8:	de843703          	ld	a4,-536(s0)
    80004dfc:	8ff9                	and	a5,a5,a4
    80004dfe:	1e079063          	bnez	a5,80004fde <kexec+0x348>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80004e02:	e1c42503          	lw	a0,-484(s0)
    80004e06:	e71ff0ef          	jal	80004c76 <flags2perm>
    80004e0a:	86aa                	mv	a3,a0
    80004e0c:	8626                	mv	a2,s1
    80004e0e:	85ca                	mv	a1,s2
    80004e10:	855a                	mv	a0,s6
    80004e12:	efafc0ef          	jal	8000150c <uvmalloc>
    80004e16:	dea43c23          	sd	a0,-520(s0)
    80004e1a:	1c050563          	beqz	a0,80004fe4 <kexec+0x34e>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80004e1e:	e3842983          	lw	s3,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    80004e22:	00098863          	beqz	s3,80004e32 <kexec+0x19c>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80004e26:	e2843c03          	ld	s8,-472(s0)
    80004e2a:	e2042b83          	lw	s7,-480(s0)
  for(i = 0; i < sz; i += PGSIZE){
    80004e2e:	4481                	li	s1,0
    80004e30:	bfb1                	j	80004d8c <kexec+0xf6>
    sz = sz1;
    80004e32:	df843903          	ld	s2,-520(s0)
    80004e36:	bfad                	j	80004db0 <kexec+0x11a>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004e38:	4901                	li	s2,0
  iunlockput(ip);
    80004e3a:	8552                	mv	a0,s4
    80004e3c:	bebfe0ef          	jal	80003a26 <iunlockput>
  end_op();
    80004e40:	c56ff0ef          	jal	80004296 <end_op>
  p = myproc();
    80004e44:	de5fc0ef          	jal	80001c28 <myproc>
    80004e48:	8aaa                	mv	s5,a0
  uint64 oldsz = p->sz;
    80004e4a:	04853d03          	ld	s10,72(a0)
  sz = PGROUNDUP(sz);
    80004e4e:	6985                	lui	s3,0x1
    80004e50:	19fd                	addi	s3,s3,-1 # fff <_entry-0x7ffff001>
    80004e52:	99ca                	add	s3,s3,s2
    80004e54:	77fd                	lui	a5,0xfffff
    80004e56:	00f9f9b3          	and	s3,s3,a5
  if((sz1 = uvmalloc(pagetable, sz, sz + (USERSTACK+1)*PGSIZE, PTE_W)) == 0)
    80004e5a:	4691                	li	a3,4
    80004e5c:	6609                	lui	a2,0x2
    80004e5e:	964e                	add	a2,a2,s3
    80004e60:	85ce                	mv	a1,s3
    80004e62:	855a                	mv	a0,s6
    80004e64:	ea8fc0ef          	jal	8000150c <uvmalloc>
    80004e68:	8a2a                	mv	s4,a0
    80004e6a:	e105                	bnez	a0,80004e8a <kexec+0x1f4>
    proc_freepagetable(pagetable, sz);
    80004e6c:	85ce                	mv	a1,s3
    80004e6e:	855a                	mv	a0,s6
    80004e70:	f47fc0ef          	jal	80001db6 <proc_freepagetable>
  return -1;
    80004e74:	557d                	li	a0,-1
    80004e76:	79fe                	ld	s3,504(sp)
    80004e78:	7a5e                	ld	s4,496(sp)
    80004e7a:	7abe                	ld	s5,488(sp)
    80004e7c:	7b1e                	ld	s6,480(sp)
    80004e7e:	6bfe                	ld	s7,472(sp)
    80004e80:	6c5e                	ld	s8,464(sp)
    80004e82:	6cbe                	ld	s9,456(sp)
    80004e84:	6d1e                	ld	s10,448(sp)
    80004e86:	7dfa                	ld	s11,440(sp)
    80004e88:	b541                	j	80004d08 <kexec+0x72>
  uvmclear(pagetable, sz-(USERSTACK+1)*PGSIZE);
    80004e8a:	75f9                	lui	a1,0xffffe
    80004e8c:	95aa                	add	a1,a1,a0
    80004e8e:	855a                	mv	a0,s6
    80004e90:	8d1fc0ef          	jal	80001760 <uvmclear>
  stackbase = sp - USERSTACK*PGSIZE;
    80004e94:	800a0b93          	addi	s7,s4,-2048
    80004e98:	800b8b93          	addi	s7,s7,-2048
  for(argc = 0; argv[argc]; argc++) {
    80004e9c:	e0043783          	ld	a5,-512(s0)
    80004ea0:	6388                	ld	a0,0(a5)
  sp = sz;
    80004ea2:	8952                	mv	s2,s4
  for(argc = 0; argv[argc]; argc++) {
    80004ea4:	4481                	li	s1,0
    ustack[argc] = sp;
    80004ea6:	e9040c93          	addi	s9,s0,-368
    if(argc >= MAXARG)
    80004eaa:	02000c13          	li	s8,32
  for(argc = 0; argv[argc]; argc++) {
    80004eae:	cd21                	beqz	a0,80004f06 <kexec+0x270>
    sp -= strlen(argv[argc]) + 1;
    80004eb0:	8c0fc0ef          	jal	80000f70 <strlen>
    80004eb4:	0015079b          	addiw	a5,a0,1
    80004eb8:	40f907b3          	sub	a5,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80004ebc:	ff07f913          	andi	s2,a5,-16
    if(sp < stackbase)
    80004ec0:	13796563          	bltu	s2,s7,80004fea <kexec+0x354>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80004ec4:	e0043d83          	ld	s11,-512(s0)
    80004ec8:	000db983          	ld	s3,0(s11)
    80004ecc:	854e                	mv	a0,s3
    80004ece:	8a2fc0ef          	jal	80000f70 <strlen>
    80004ed2:	0015069b          	addiw	a3,a0,1
    80004ed6:	864e                	mv	a2,s3
    80004ed8:	85ca                	mv	a1,s2
    80004eda:	855a                	mv	a0,s6
    80004edc:	a5ffc0ef          	jal	8000193a <copyout>
    80004ee0:	10054763          	bltz	a0,80004fee <kexec+0x358>
    ustack[argc] = sp;
    80004ee4:	00349793          	slli	a5,s1,0x3
    80004ee8:	97e6                	add	a5,a5,s9
    80004eea:	0127b023          	sd	s2,0(a5) # fffffffffffff000 <end+0xffffffff7ffb82a8>
  for(argc = 0; argv[argc]; argc++) {
    80004eee:	0485                	addi	s1,s1,1
    80004ef0:	008d8793          	addi	a5,s11,8
    80004ef4:	e0f43023          	sd	a5,-512(s0)
    80004ef8:	008db503          	ld	a0,8(s11)
    80004efc:	c509                	beqz	a0,80004f06 <kexec+0x270>
    if(argc >= MAXARG)
    80004efe:	fb8499e3          	bne	s1,s8,80004eb0 <kexec+0x21a>
  sz = sz1;
    80004f02:	89d2                	mv	s3,s4
    80004f04:	b7a5                	j	80004e6c <kexec+0x1d6>
  ustack[argc] = 0;
    80004f06:	00349793          	slli	a5,s1,0x3
    80004f0a:	f9078793          	addi	a5,a5,-112
    80004f0e:	97a2                	add	a5,a5,s0
    80004f10:	f007b023          	sd	zero,-256(a5)
  sp -= (argc+1) * sizeof(uint64);
    80004f14:	00349693          	slli	a3,s1,0x3
    80004f18:	06a1                	addi	a3,a3,8
    80004f1a:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    80004f1e:	ff097913          	andi	s2,s2,-16
  sz = sz1;
    80004f22:	89d2                	mv	s3,s4
  if(sp < stackbase)
    80004f24:	f57964e3          	bltu	s2,s7,80004e6c <kexec+0x1d6>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    80004f28:	e9040613          	addi	a2,s0,-368
    80004f2c:	85ca                	mv	a1,s2
    80004f2e:	855a                	mv	a0,s6
    80004f30:	a0bfc0ef          	jal	8000193a <copyout>
    80004f34:	f2054ce3          	bltz	a0,80004e6c <kexec+0x1d6>
  p->trapframe->a1 = sp;
    80004f38:	058ab783          	ld	a5,88(s5) # 1058 <_entry-0x7fffefa8>
    80004f3c:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    80004f40:	df043783          	ld	a5,-528(s0)
    80004f44:	0007c703          	lbu	a4,0(a5)
    80004f48:	cf11                	beqz	a4,80004f64 <kexec+0x2ce>
    80004f4a:	0785                	addi	a5,a5,1
    if(*s == '/')
    80004f4c:	02f00693          	li	a3,47
    80004f50:	a029                	j	80004f5a <kexec+0x2c4>
  for(last=s=path; *s; s++)
    80004f52:	0785                	addi	a5,a5,1
    80004f54:	fff7c703          	lbu	a4,-1(a5)
    80004f58:	c711                	beqz	a4,80004f64 <kexec+0x2ce>
    if(*s == '/')
    80004f5a:	fed71ce3          	bne	a4,a3,80004f52 <kexec+0x2bc>
      last = s+1;
    80004f5e:	def43823          	sd	a5,-528(s0)
    80004f62:	bfc5                	j	80004f52 <kexec+0x2bc>
  safestrcpy(p->name, last, sizeof(p->name));
    80004f64:	4641                	li	a2,16
    80004f66:	df043583          	ld	a1,-528(s0)
    80004f6a:	158a8513          	addi	a0,s5,344
    80004f6e:	fcdfb0ef          	jal	80000f3a <safestrcpy>
  oldpagetable = p->pagetable;
    80004f72:	050ab503          	ld	a0,80(s5)
  p->pagetable = pagetable;
    80004f76:	056ab823          	sd	s6,80(s5)
  p->sz = sz;
    80004f7a:	054ab423          	sd	s4,72(s5)
  p->trapframe->epc = elf.entry;  // initial program counter = ulib.c:start()
    80004f7e:	058ab783          	ld	a5,88(s5)
    80004f82:	e6843703          	ld	a4,-408(s0)
    80004f86:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    80004f88:	058ab783          	ld	a5,88(s5)
    80004f8c:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    80004f90:	85ea                	mv	a1,s10
    80004f92:	e25fc0ef          	jal	80001db6 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80004f96:	0004851b          	sext.w	a0,s1
    80004f9a:	79fe                	ld	s3,504(sp)
    80004f9c:	7a5e                	ld	s4,496(sp)
    80004f9e:	7abe                	ld	s5,488(sp)
    80004fa0:	7b1e                	ld	s6,480(sp)
    80004fa2:	6bfe                	ld	s7,472(sp)
    80004fa4:	6c5e                	ld	s8,464(sp)
    80004fa6:	6cbe                	ld	s9,456(sp)
    80004fa8:	6d1e                	ld	s10,448(sp)
    80004faa:	7dfa                	ld	s11,440(sp)
    80004fac:	bbb1                	j	80004d08 <kexec+0x72>
    80004fae:	7b1e                	ld	s6,480(sp)
    80004fb0:	b3a9                	j	80004cfa <kexec+0x64>
    80004fb2:	df243c23          	sd	s2,-520(s0)
    proc_freepagetable(pagetable, sz);
    80004fb6:	df843583          	ld	a1,-520(s0)
    80004fba:	855a                	mv	a0,s6
    80004fbc:	dfbfc0ef          	jal	80001db6 <proc_freepagetable>
  if(ip){
    80004fc0:	79fe                	ld	s3,504(sp)
    80004fc2:	7abe                	ld	s5,488(sp)
    80004fc4:	7b1e                	ld	s6,480(sp)
    80004fc6:	6bfe                	ld	s7,472(sp)
    80004fc8:	6c5e                	ld	s8,464(sp)
    80004fca:	6cbe                	ld	s9,456(sp)
    80004fcc:	6d1e                	ld	s10,448(sp)
    80004fce:	7dfa                	ld	s11,440(sp)
    80004fd0:	b32d                	j	80004cfa <kexec+0x64>
    80004fd2:	df243c23          	sd	s2,-520(s0)
    80004fd6:	b7c5                	j	80004fb6 <kexec+0x320>
    80004fd8:	df243c23          	sd	s2,-520(s0)
    80004fdc:	bfe9                	j	80004fb6 <kexec+0x320>
    80004fde:	df243c23          	sd	s2,-520(s0)
    80004fe2:	bfd1                	j	80004fb6 <kexec+0x320>
    80004fe4:	df243c23          	sd	s2,-520(s0)
    80004fe8:	b7f9                	j	80004fb6 <kexec+0x320>
  sz = sz1;
    80004fea:	89d2                	mv	s3,s4
    80004fec:	b541                	j	80004e6c <kexec+0x1d6>
    80004fee:	89d2                	mv	s3,s4
    80004ff0:	bdb5                	j	80004e6c <kexec+0x1d6>

0000000080004ff2 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80004ff2:	7179                	addi	sp,sp,-48
    80004ff4:	f406                	sd	ra,40(sp)
    80004ff6:	f022                	sd	s0,32(sp)
    80004ff8:	ec26                	sd	s1,24(sp)
    80004ffa:	e84a                	sd	s2,16(sp)
    80004ffc:	1800                	addi	s0,sp,48
    80004ffe:	892e                	mv	s2,a1
    80005000:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    80005002:	fdc40593          	addi	a1,s0,-36
    80005006:	d79fd0ef          	jal	80002d7e <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    8000500a:	fdc42703          	lw	a4,-36(s0)
    8000500e:	47bd                	li	a5,15
    80005010:	02e7ea63          	bltu	a5,a4,80005044 <argfd+0x52>
    80005014:	c15fc0ef          	jal	80001c28 <myproc>
    80005018:	fdc42703          	lw	a4,-36(s0)
    8000501c:	00371793          	slli	a5,a4,0x3
    80005020:	0d078793          	addi	a5,a5,208
    80005024:	953e                	add	a0,a0,a5
    80005026:	611c                	ld	a5,0(a0)
    80005028:	c385                	beqz	a5,80005048 <argfd+0x56>
    return -1;
  if(pfd)
    8000502a:	00090463          	beqz	s2,80005032 <argfd+0x40>
    *pfd = fd;
    8000502e:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    80005032:	4501                	li	a0,0
  if(pf)
    80005034:	c091                	beqz	s1,80005038 <argfd+0x46>
    *pf = f;
    80005036:	e09c                	sd	a5,0(s1)
}
    80005038:	70a2                	ld	ra,40(sp)
    8000503a:	7402                	ld	s0,32(sp)
    8000503c:	64e2                	ld	s1,24(sp)
    8000503e:	6942                	ld	s2,16(sp)
    80005040:	6145                	addi	sp,sp,48
    80005042:	8082                	ret
    return -1;
    80005044:	557d                	li	a0,-1
    80005046:	bfcd                	j	80005038 <argfd+0x46>
    80005048:	557d                	li	a0,-1
    8000504a:	b7fd                	j	80005038 <argfd+0x46>

000000008000504c <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    8000504c:	1101                	addi	sp,sp,-32
    8000504e:	ec06                	sd	ra,24(sp)
    80005050:	e822                	sd	s0,16(sp)
    80005052:	e426                	sd	s1,8(sp)
    80005054:	1000                	addi	s0,sp,32
    80005056:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    80005058:	bd1fc0ef          	jal	80001c28 <myproc>
    8000505c:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    8000505e:	0d050793          	addi	a5,a0,208
    80005062:	4501                	li	a0,0
    80005064:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    80005066:	6398                	ld	a4,0(a5)
    80005068:	cb19                	beqz	a4,8000507e <fdalloc+0x32>
  for(fd = 0; fd < NOFILE; fd++){
    8000506a:	2505                	addiw	a0,a0,1
    8000506c:	07a1                	addi	a5,a5,8
    8000506e:	fed51ce3          	bne	a0,a3,80005066 <fdalloc+0x1a>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80005072:	557d                	li	a0,-1
}
    80005074:	60e2                	ld	ra,24(sp)
    80005076:	6442                	ld	s0,16(sp)
    80005078:	64a2                	ld	s1,8(sp)
    8000507a:	6105                	addi	sp,sp,32
    8000507c:	8082                	ret
      p->ofile[fd] = f;
    8000507e:	00351793          	slli	a5,a0,0x3
    80005082:	0d078793          	addi	a5,a5,208
    80005086:	963e                	add	a2,a2,a5
    80005088:	e204                	sd	s1,0(a2)
      return fd;
    8000508a:	b7ed                	j	80005074 <fdalloc+0x28>

000000008000508c <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    8000508c:	715d                	addi	sp,sp,-80
    8000508e:	e486                	sd	ra,72(sp)
    80005090:	e0a2                	sd	s0,64(sp)
    80005092:	fc26                	sd	s1,56(sp)
    80005094:	f84a                	sd	s2,48(sp)
    80005096:	f44e                	sd	s3,40(sp)
    80005098:	f052                	sd	s4,32(sp)
    8000509a:	ec56                	sd	s5,24(sp)
    8000509c:	e85a                	sd	s6,16(sp)
    8000509e:	0880                	addi	s0,sp,80
    800050a0:	892e                	mv	s2,a1
    800050a2:	8a2e                	mv	s4,a1
    800050a4:	8ab2                	mv	s5,a2
    800050a6:	8b36                	mv	s6,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    800050a8:	fb040593          	addi	a1,s0,-80
    800050ac:	fb7fe0ef          	jal	80004062 <nameiparent>
    800050b0:	84aa                	mv	s1,a0
    800050b2:	10050763          	beqz	a0,800051c0 <create+0x134>
    return 0;

  ilock(dp);
    800050b6:	f64fe0ef          	jal	8000381a <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    800050ba:	4601                	li	a2,0
    800050bc:	fb040593          	addi	a1,s0,-80
    800050c0:	8526                	mv	a0,s1
    800050c2:	cf3fe0ef          	jal	80003db4 <dirlookup>
    800050c6:	89aa                	mv	s3,a0
    800050c8:	c131                	beqz	a0,8000510c <create+0x80>
    iunlockput(dp);
    800050ca:	8526                	mv	a0,s1
    800050cc:	95bfe0ef          	jal	80003a26 <iunlockput>
    ilock(ip);
    800050d0:	854e                	mv	a0,s3
    800050d2:	f48fe0ef          	jal	8000381a <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    800050d6:	4789                	li	a5,2
    800050d8:	02f91563          	bne	s2,a5,80005102 <create+0x76>
    800050dc:	0449d783          	lhu	a5,68(s3)
    800050e0:	37f9                	addiw	a5,a5,-2
    800050e2:	17c2                	slli	a5,a5,0x30
    800050e4:	93c1                	srli	a5,a5,0x30
    800050e6:	4705                	li	a4,1
    800050e8:	00f76d63          	bltu	a4,a5,80005102 <create+0x76>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    800050ec:	854e                	mv	a0,s3
    800050ee:	60a6                	ld	ra,72(sp)
    800050f0:	6406                	ld	s0,64(sp)
    800050f2:	74e2                	ld	s1,56(sp)
    800050f4:	7942                	ld	s2,48(sp)
    800050f6:	79a2                	ld	s3,40(sp)
    800050f8:	7a02                	ld	s4,32(sp)
    800050fa:	6ae2                	ld	s5,24(sp)
    800050fc:	6b42                	ld	s6,16(sp)
    800050fe:	6161                	addi	sp,sp,80
    80005100:	8082                	ret
    iunlockput(ip);
    80005102:	854e                	mv	a0,s3
    80005104:	923fe0ef          	jal	80003a26 <iunlockput>
    return 0;
    80005108:	4981                	li	s3,0
    8000510a:	b7cd                	j	800050ec <create+0x60>
  if((ip = ialloc(dp->dev, type)) == 0){
    8000510c:	85ca                	mv	a1,s2
    8000510e:	4088                	lw	a0,0(s1)
    80005110:	d9afe0ef          	jal	800036aa <ialloc>
    80005114:	892a                	mv	s2,a0
    80005116:	cd15                	beqz	a0,80005152 <create+0xc6>
  ilock(ip);
    80005118:	f02fe0ef          	jal	8000381a <ilock>
  ip->major = major;
    8000511c:	05591323          	sh	s5,70(s2)
  ip->minor = minor;
    80005120:	05691423          	sh	s6,72(s2)
  ip->nlink = 1;
    80005124:	4785                	li	a5,1
    80005126:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    8000512a:	854a                	mv	a0,s2
    8000512c:	e3afe0ef          	jal	80003766 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    80005130:	4705                	li	a4,1
    80005132:	02ea0463          	beq	s4,a4,8000515a <create+0xce>
  if(dirlink(dp, name, ip->inum) < 0)
    80005136:	00492603          	lw	a2,4(s2)
    8000513a:	fb040593          	addi	a1,s0,-80
    8000513e:	8526                	mv	a0,s1
    80005140:	e5ffe0ef          	jal	80003f9e <dirlink>
    80005144:	06054263          	bltz	a0,800051a8 <create+0x11c>
  iunlockput(dp);
    80005148:	8526                	mv	a0,s1
    8000514a:	8ddfe0ef          	jal	80003a26 <iunlockput>
  return ip;
    8000514e:	89ca                	mv	s3,s2
    80005150:	bf71                	j	800050ec <create+0x60>
    iunlockput(dp);
    80005152:	8526                	mv	a0,s1
    80005154:	8d3fe0ef          	jal	80003a26 <iunlockput>
    return 0;
    80005158:	bf51                	j	800050ec <create+0x60>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    8000515a:	00492603          	lw	a2,4(s2)
    8000515e:	00003597          	auipc	a1,0x3
    80005162:	4ca58593          	addi	a1,a1,1226 # 80008628 <etext+0x628>
    80005166:	854a                	mv	a0,s2
    80005168:	e37fe0ef          	jal	80003f9e <dirlink>
    8000516c:	02054e63          	bltz	a0,800051a8 <create+0x11c>
    80005170:	40d0                	lw	a2,4(s1)
    80005172:	00003597          	auipc	a1,0x3
    80005176:	4be58593          	addi	a1,a1,1214 # 80008630 <etext+0x630>
    8000517a:	854a                	mv	a0,s2
    8000517c:	e23fe0ef          	jal	80003f9e <dirlink>
    80005180:	02054463          	bltz	a0,800051a8 <create+0x11c>
  if(dirlink(dp, name, ip->inum) < 0)
    80005184:	00492603          	lw	a2,4(s2)
    80005188:	fb040593          	addi	a1,s0,-80
    8000518c:	8526                	mv	a0,s1
    8000518e:	e11fe0ef          	jal	80003f9e <dirlink>
    80005192:	00054b63          	bltz	a0,800051a8 <create+0x11c>
    dp->nlink++;  // for ".."
    80005196:	04a4d783          	lhu	a5,74(s1)
    8000519a:	2785                	addiw	a5,a5,1
    8000519c:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    800051a0:	8526                	mv	a0,s1
    800051a2:	dc4fe0ef          	jal	80003766 <iupdate>
    800051a6:	b74d                	j	80005148 <create+0xbc>
  ip->nlink = 0;
    800051a8:	04091523          	sh	zero,74(s2)
  iupdate(ip);
    800051ac:	854a                	mv	a0,s2
    800051ae:	db8fe0ef          	jal	80003766 <iupdate>
  iunlockput(ip);
    800051b2:	854a                	mv	a0,s2
    800051b4:	873fe0ef          	jal	80003a26 <iunlockput>
  iunlockput(dp);
    800051b8:	8526                	mv	a0,s1
    800051ba:	86dfe0ef          	jal	80003a26 <iunlockput>
  return 0;
    800051be:	b73d                	j	800050ec <create+0x60>
    return 0;
    800051c0:	89aa                	mv	s3,a0
    800051c2:	b72d                	j	800050ec <create+0x60>

00000000800051c4 <sys_dup>:
{
    800051c4:	7179                	addi	sp,sp,-48
    800051c6:	f406                	sd	ra,40(sp)
    800051c8:	f022                	sd	s0,32(sp)
    800051ca:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    800051cc:	fd840613          	addi	a2,s0,-40
    800051d0:	4581                	li	a1,0
    800051d2:	4501                	li	a0,0
    800051d4:	e1fff0ef          	jal	80004ff2 <argfd>
    return -1;
    800051d8:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    800051da:	02054363          	bltz	a0,80005200 <sys_dup+0x3c>
    800051de:	ec26                	sd	s1,24(sp)
    800051e0:	e84a                	sd	s2,16(sp)
  if((fd=fdalloc(f)) < 0)
    800051e2:	fd843483          	ld	s1,-40(s0)
    800051e6:	8526                	mv	a0,s1
    800051e8:	e65ff0ef          	jal	8000504c <fdalloc>
    800051ec:	892a                	mv	s2,a0
    return -1;
    800051ee:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    800051f0:	00054d63          	bltz	a0,8000520a <sys_dup+0x46>
  filedup(f);
    800051f4:	8526                	mv	a0,s1
    800051f6:	c0eff0ef          	jal	80004604 <filedup>
  return fd;
    800051fa:	87ca                	mv	a5,s2
    800051fc:	64e2                	ld	s1,24(sp)
    800051fe:	6942                	ld	s2,16(sp)
}
    80005200:	853e                	mv	a0,a5
    80005202:	70a2                	ld	ra,40(sp)
    80005204:	7402                	ld	s0,32(sp)
    80005206:	6145                	addi	sp,sp,48
    80005208:	8082                	ret
    8000520a:	64e2                	ld	s1,24(sp)
    8000520c:	6942                	ld	s2,16(sp)
    8000520e:	bfcd                	j	80005200 <sys_dup+0x3c>

0000000080005210 <sys_read>:
{
    80005210:	7179                	addi	sp,sp,-48
    80005212:	f406                	sd	ra,40(sp)
    80005214:	f022                	sd	s0,32(sp)
    80005216:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80005218:	fd840593          	addi	a1,s0,-40
    8000521c:	4505                	li	a0,1
    8000521e:	b7dfd0ef          	jal	80002d9a <argaddr>
  argint(2, &n);
    80005222:	fe440593          	addi	a1,s0,-28
    80005226:	4509                	li	a0,2
    80005228:	b57fd0ef          	jal	80002d7e <argint>
  if(argfd(0, 0, &f) < 0)
    8000522c:	fe840613          	addi	a2,s0,-24
    80005230:	4581                	li	a1,0
    80005232:	4501                	li	a0,0
    80005234:	dbfff0ef          	jal	80004ff2 <argfd>
    80005238:	87aa                	mv	a5,a0
    return -1;
    8000523a:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    8000523c:	0007ca63          	bltz	a5,80005250 <sys_read+0x40>
  return fileread(f, p, n);
    80005240:	fe442603          	lw	a2,-28(s0)
    80005244:	fd843583          	ld	a1,-40(s0)
    80005248:	fe843503          	ld	a0,-24(s0)
    8000524c:	d22ff0ef          	jal	8000476e <fileread>
}
    80005250:	70a2                	ld	ra,40(sp)
    80005252:	7402                	ld	s0,32(sp)
    80005254:	6145                	addi	sp,sp,48
    80005256:	8082                	ret

0000000080005258 <sys_write>:
{
    80005258:	7179                	addi	sp,sp,-48
    8000525a:	f406                	sd	ra,40(sp)
    8000525c:	f022                	sd	s0,32(sp)
    8000525e:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80005260:	fd840593          	addi	a1,s0,-40
    80005264:	4505                	li	a0,1
    80005266:	b35fd0ef          	jal	80002d9a <argaddr>
  argint(2, &n);
    8000526a:	fe440593          	addi	a1,s0,-28
    8000526e:	4509                	li	a0,2
    80005270:	b0ffd0ef          	jal	80002d7e <argint>
  if(argfd(0, 0, &f) < 0)
    80005274:	fe840613          	addi	a2,s0,-24
    80005278:	4581                	li	a1,0
    8000527a:	4501                	li	a0,0
    8000527c:	d77ff0ef          	jal	80004ff2 <argfd>
    80005280:	87aa                	mv	a5,a0
    return -1;
    80005282:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80005284:	0007ca63          	bltz	a5,80005298 <sys_write+0x40>
  return filewrite(f, p, n);
    80005288:	fe442603          	lw	a2,-28(s0)
    8000528c:	fd843583          	ld	a1,-40(s0)
    80005290:	fe843503          	ld	a0,-24(s0)
    80005294:	d9eff0ef          	jal	80004832 <filewrite>
}
    80005298:	70a2                	ld	ra,40(sp)
    8000529a:	7402                	ld	s0,32(sp)
    8000529c:	6145                	addi	sp,sp,48
    8000529e:	8082                	ret

00000000800052a0 <sys_close>:
{
    800052a0:	1101                	addi	sp,sp,-32
    800052a2:	ec06                	sd	ra,24(sp)
    800052a4:	e822                	sd	s0,16(sp)
    800052a6:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    800052a8:	fe040613          	addi	a2,s0,-32
    800052ac:	fec40593          	addi	a1,s0,-20
    800052b0:	4501                	li	a0,0
    800052b2:	d41ff0ef          	jal	80004ff2 <argfd>
    return -1;
    800052b6:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    800052b8:	02054163          	bltz	a0,800052da <sys_close+0x3a>
  myproc()->ofile[fd] = 0;
    800052bc:	96dfc0ef          	jal	80001c28 <myproc>
    800052c0:	fec42783          	lw	a5,-20(s0)
    800052c4:	078e                	slli	a5,a5,0x3
    800052c6:	0d078793          	addi	a5,a5,208
    800052ca:	953e                	add	a0,a0,a5
    800052cc:	00053023          	sd	zero,0(a0)
  fileclose(f);
    800052d0:	fe043503          	ld	a0,-32(s0)
    800052d4:	b76ff0ef          	jal	8000464a <fileclose>
  return 0;
    800052d8:	4781                	li	a5,0
}
    800052da:	853e                	mv	a0,a5
    800052dc:	60e2                	ld	ra,24(sp)
    800052de:	6442                	ld	s0,16(sp)
    800052e0:	6105                	addi	sp,sp,32
    800052e2:	8082                	ret

00000000800052e4 <sys_fstat>:
{
    800052e4:	1101                	addi	sp,sp,-32
    800052e6:	ec06                	sd	ra,24(sp)
    800052e8:	e822                	sd	s0,16(sp)
    800052ea:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    800052ec:	fe040593          	addi	a1,s0,-32
    800052f0:	4505                	li	a0,1
    800052f2:	aa9fd0ef          	jal	80002d9a <argaddr>
  if(argfd(0, 0, &f) < 0)
    800052f6:	fe840613          	addi	a2,s0,-24
    800052fa:	4581                	li	a1,0
    800052fc:	4501                	li	a0,0
    800052fe:	cf5ff0ef          	jal	80004ff2 <argfd>
    80005302:	87aa                	mv	a5,a0
    return -1;
    80005304:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80005306:	0007c863          	bltz	a5,80005316 <sys_fstat+0x32>
  return filestat(f, st);
    8000530a:	fe043583          	ld	a1,-32(s0)
    8000530e:	fe843503          	ld	a0,-24(s0)
    80005312:	bfaff0ef          	jal	8000470c <filestat>
}
    80005316:	60e2                	ld	ra,24(sp)
    80005318:	6442                	ld	s0,16(sp)
    8000531a:	6105                	addi	sp,sp,32
    8000531c:	8082                	ret

000000008000531e <sys_link>:
{
    8000531e:	7169                	addi	sp,sp,-304
    80005320:	f606                	sd	ra,296(sp)
    80005322:	f222                	sd	s0,288(sp)
    80005324:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005326:	08000613          	li	a2,128
    8000532a:	ed040593          	addi	a1,s0,-304
    8000532e:	4501                	li	a0,0
    80005330:	a87fd0ef          	jal	80002db6 <argstr>
    return -1;
    80005334:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005336:	0c054e63          	bltz	a0,80005412 <sys_link+0xf4>
    8000533a:	08000613          	li	a2,128
    8000533e:	f5040593          	addi	a1,s0,-176
    80005342:	4505                	li	a0,1
    80005344:	a73fd0ef          	jal	80002db6 <argstr>
    return -1;
    80005348:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    8000534a:	0c054463          	bltz	a0,80005412 <sys_link+0xf4>
    8000534e:	ee26                	sd	s1,280(sp)
  begin_op();
    80005350:	ed7fe0ef          	jal	80004226 <begin_op>
  if((ip = namei(old)) == 0){
    80005354:	ed040513          	addi	a0,s0,-304
    80005358:	cf1fe0ef          	jal	80004048 <namei>
    8000535c:	84aa                	mv	s1,a0
    8000535e:	c53d                	beqz	a0,800053cc <sys_link+0xae>
  ilock(ip);
    80005360:	cbafe0ef          	jal	8000381a <ilock>
  if(ip->type == T_DIR){
    80005364:	04449703          	lh	a4,68(s1)
    80005368:	4785                	li	a5,1
    8000536a:	06f70663          	beq	a4,a5,800053d6 <sys_link+0xb8>
    8000536e:	ea4a                	sd	s2,272(sp)
  ip->nlink++;
    80005370:	04a4d783          	lhu	a5,74(s1)
    80005374:	2785                	addiw	a5,a5,1
    80005376:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    8000537a:	8526                	mv	a0,s1
    8000537c:	beafe0ef          	jal	80003766 <iupdate>
  iunlock(ip);
    80005380:	8526                	mv	a0,s1
    80005382:	d46fe0ef          	jal	800038c8 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    80005386:	fd040593          	addi	a1,s0,-48
    8000538a:	f5040513          	addi	a0,s0,-176
    8000538e:	cd5fe0ef          	jal	80004062 <nameiparent>
    80005392:	892a                	mv	s2,a0
    80005394:	cd21                	beqz	a0,800053ec <sys_link+0xce>
  ilock(dp);
    80005396:	c84fe0ef          	jal	8000381a <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    8000539a:	854a                	mv	a0,s2
    8000539c:	00092703          	lw	a4,0(s2)
    800053a0:	409c                	lw	a5,0(s1)
    800053a2:	04f71263          	bne	a4,a5,800053e6 <sys_link+0xc8>
    800053a6:	40d0                	lw	a2,4(s1)
    800053a8:	fd040593          	addi	a1,s0,-48
    800053ac:	bf3fe0ef          	jal	80003f9e <dirlink>
    800053b0:	02054b63          	bltz	a0,800053e6 <sys_link+0xc8>
  iunlockput(dp);
    800053b4:	854a                	mv	a0,s2
    800053b6:	e70fe0ef          	jal	80003a26 <iunlockput>
  iput(ip);
    800053ba:	8526                	mv	a0,s1
    800053bc:	de0fe0ef          	jal	8000399c <iput>
  end_op();
    800053c0:	ed7fe0ef          	jal	80004296 <end_op>
  return 0;
    800053c4:	4781                	li	a5,0
    800053c6:	64f2                	ld	s1,280(sp)
    800053c8:	6952                	ld	s2,272(sp)
    800053ca:	a0a1                	j	80005412 <sys_link+0xf4>
    end_op();
    800053cc:	ecbfe0ef          	jal	80004296 <end_op>
    return -1;
    800053d0:	57fd                	li	a5,-1
    800053d2:	64f2                	ld	s1,280(sp)
    800053d4:	a83d                	j	80005412 <sys_link+0xf4>
    iunlockput(ip);
    800053d6:	8526                	mv	a0,s1
    800053d8:	e4efe0ef          	jal	80003a26 <iunlockput>
    end_op();
    800053dc:	ebbfe0ef          	jal	80004296 <end_op>
    return -1;
    800053e0:	57fd                	li	a5,-1
    800053e2:	64f2                	ld	s1,280(sp)
    800053e4:	a03d                	j	80005412 <sys_link+0xf4>
    iunlockput(dp);
    800053e6:	854a                	mv	a0,s2
    800053e8:	e3efe0ef          	jal	80003a26 <iunlockput>
  ilock(ip);
    800053ec:	8526                	mv	a0,s1
    800053ee:	c2cfe0ef          	jal	8000381a <ilock>
  ip->nlink--;
    800053f2:	04a4d783          	lhu	a5,74(s1)
    800053f6:	37fd                	addiw	a5,a5,-1
    800053f8:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    800053fc:	8526                	mv	a0,s1
    800053fe:	b68fe0ef          	jal	80003766 <iupdate>
  iunlockput(ip);
    80005402:	8526                	mv	a0,s1
    80005404:	e22fe0ef          	jal	80003a26 <iunlockput>
  end_op();
    80005408:	e8ffe0ef          	jal	80004296 <end_op>
  return -1;
    8000540c:	57fd                	li	a5,-1
    8000540e:	64f2                	ld	s1,280(sp)
    80005410:	6952                	ld	s2,272(sp)
}
    80005412:	853e                	mv	a0,a5
    80005414:	70b2                	ld	ra,296(sp)
    80005416:	7412                	ld	s0,288(sp)
    80005418:	6155                	addi	sp,sp,304
    8000541a:	8082                	ret

000000008000541c <sys_unlink>:
{
    8000541c:	7151                	addi	sp,sp,-240
    8000541e:	f586                	sd	ra,232(sp)
    80005420:	f1a2                	sd	s0,224(sp)
    80005422:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    80005424:	08000613          	li	a2,128
    80005428:	f3040593          	addi	a1,s0,-208
    8000542c:	4501                	li	a0,0
    8000542e:	989fd0ef          	jal	80002db6 <argstr>
    80005432:	14054d63          	bltz	a0,8000558c <sys_unlink+0x170>
    80005436:	eda6                	sd	s1,216(sp)
  begin_op();
    80005438:	deffe0ef          	jal	80004226 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    8000543c:	fb040593          	addi	a1,s0,-80
    80005440:	f3040513          	addi	a0,s0,-208
    80005444:	c1ffe0ef          	jal	80004062 <nameiparent>
    80005448:	84aa                	mv	s1,a0
    8000544a:	c955                	beqz	a0,800054fe <sys_unlink+0xe2>
  ilock(dp);
    8000544c:	bcefe0ef          	jal	8000381a <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80005450:	00003597          	auipc	a1,0x3
    80005454:	1d858593          	addi	a1,a1,472 # 80008628 <etext+0x628>
    80005458:	fb040513          	addi	a0,s0,-80
    8000545c:	943fe0ef          	jal	80003d9e <namecmp>
    80005460:	10050b63          	beqz	a0,80005576 <sys_unlink+0x15a>
    80005464:	00003597          	auipc	a1,0x3
    80005468:	1cc58593          	addi	a1,a1,460 # 80008630 <etext+0x630>
    8000546c:	fb040513          	addi	a0,s0,-80
    80005470:	92ffe0ef          	jal	80003d9e <namecmp>
    80005474:	10050163          	beqz	a0,80005576 <sys_unlink+0x15a>
    80005478:	e9ca                	sd	s2,208(sp)
  if((ip = dirlookup(dp, name, &off)) == 0)
    8000547a:	f2c40613          	addi	a2,s0,-212
    8000547e:	fb040593          	addi	a1,s0,-80
    80005482:	8526                	mv	a0,s1
    80005484:	931fe0ef          	jal	80003db4 <dirlookup>
    80005488:	892a                	mv	s2,a0
    8000548a:	0e050563          	beqz	a0,80005574 <sys_unlink+0x158>
    8000548e:	e5ce                	sd	s3,200(sp)
  ilock(ip);
    80005490:	b8afe0ef          	jal	8000381a <ilock>
  if(ip->nlink < 1)
    80005494:	04a91783          	lh	a5,74(s2)
    80005498:	06f05863          	blez	a5,80005508 <sys_unlink+0xec>
  if(ip->type == T_DIR && !isdirempty(ip)){
    8000549c:	04491703          	lh	a4,68(s2)
    800054a0:	4785                	li	a5,1
    800054a2:	06f70963          	beq	a4,a5,80005514 <sys_unlink+0xf8>
  memset(&de, 0, sizeof(de));
    800054a6:	fc040993          	addi	s3,s0,-64
    800054aa:	4641                	li	a2,16
    800054ac:	4581                	li	a1,0
    800054ae:	854e                	mv	a0,s3
    800054b0:	937fb0ef          	jal	80000de6 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800054b4:	4741                	li	a4,16
    800054b6:	f2c42683          	lw	a3,-212(s0)
    800054ba:	864e                	mv	a2,s3
    800054bc:	4581                	li	a1,0
    800054be:	8526                	mv	a0,s1
    800054c0:	fdefe0ef          	jal	80003c9e <writei>
    800054c4:	47c1                	li	a5,16
    800054c6:	08f51863          	bne	a0,a5,80005556 <sys_unlink+0x13a>
  if(ip->type == T_DIR){
    800054ca:	04491703          	lh	a4,68(s2)
    800054ce:	4785                	li	a5,1
    800054d0:	08f70963          	beq	a4,a5,80005562 <sys_unlink+0x146>
  iunlockput(dp);
    800054d4:	8526                	mv	a0,s1
    800054d6:	d50fe0ef          	jal	80003a26 <iunlockput>
  ip->nlink--;
    800054da:	04a95783          	lhu	a5,74(s2)
    800054de:	37fd                	addiw	a5,a5,-1
    800054e0:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    800054e4:	854a                	mv	a0,s2
    800054e6:	a80fe0ef          	jal	80003766 <iupdate>
  iunlockput(ip);
    800054ea:	854a                	mv	a0,s2
    800054ec:	d3afe0ef          	jal	80003a26 <iunlockput>
  end_op();
    800054f0:	da7fe0ef          	jal	80004296 <end_op>
  return 0;
    800054f4:	4501                	li	a0,0
    800054f6:	64ee                	ld	s1,216(sp)
    800054f8:	694e                	ld	s2,208(sp)
    800054fa:	69ae                	ld	s3,200(sp)
    800054fc:	a061                	j	80005584 <sys_unlink+0x168>
    end_op();
    800054fe:	d99fe0ef          	jal	80004296 <end_op>
    return -1;
    80005502:	557d                	li	a0,-1
    80005504:	64ee                	ld	s1,216(sp)
    80005506:	a8bd                	j	80005584 <sys_unlink+0x168>
    panic("unlink: nlink < 1");
    80005508:	00003517          	auipc	a0,0x3
    8000550c:	13050513          	addi	a0,a0,304 # 80008638 <etext+0x638>
    80005510:	b46fb0ef          	jal	80000856 <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005514:	04c92703          	lw	a4,76(s2)
    80005518:	02000793          	li	a5,32
    8000551c:	f8e7f5e3          	bgeu	a5,a4,800054a6 <sys_unlink+0x8a>
    80005520:	89be                	mv	s3,a5
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005522:	4741                	li	a4,16
    80005524:	86ce                	mv	a3,s3
    80005526:	f1840613          	addi	a2,s0,-232
    8000552a:	4581                	li	a1,0
    8000552c:	854a                	mv	a0,s2
    8000552e:	e7efe0ef          	jal	80003bac <readi>
    80005532:	47c1                	li	a5,16
    80005534:	00f51b63          	bne	a0,a5,8000554a <sys_unlink+0x12e>
    if(de.inum != 0)
    80005538:	f1845783          	lhu	a5,-232(s0)
    8000553c:	ebb1                	bnez	a5,80005590 <sys_unlink+0x174>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    8000553e:	29c1                	addiw	s3,s3,16
    80005540:	04c92783          	lw	a5,76(s2)
    80005544:	fcf9efe3          	bltu	s3,a5,80005522 <sys_unlink+0x106>
    80005548:	bfb9                	j	800054a6 <sys_unlink+0x8a>
      panic("isdirempty: readi");
    8000554a:	00003517          	auipc	a0,0x3
    8000554e:	10650513          	addi	a0,a0,262 # 80008650 <etext+0x650>
    80005552:	b04fb0ef          	jal	80000856 <panic>
    panic("unlink: writei");
    80005556:	00003517          	auipc	a0,0x3
    8000555a:	11250513          	addi	a0,a0,274 # 80008668 <etext+0x668>
    8000555e:	af8fb0ef          	jal	80000856 <panic>
    dp->nlink--;
    80005562:	04a4d783          	lhu	a5,74(s1)
    80005566:	37fd                	addiw	a5,a5,-1
    80005568:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    8000556c:	8526                	mv	a0,s1
    8000556e:	9f8fe0ef          	jal	80003766 <iupdate>
    80005572:	b78d                	j	800054d4 <sys_unlink+0xb8>
    80005574:	694e                	ld	s2,208(sp)
  iunlockput(dp);
    80005576:	8526                	mv	a0,s1
    80005578:	caefe0ef          	jal	80003a26 <iunlockput>
  end_op();
    8000557c:	d1bfe0ef          	jal	80004296 <end_op>
  return -1;
    80005580:	557d                	li	a0,-1
    80005582:	64ee                	ld	s1,216(sp)
}
    80005584:	70ae                	ld	ra,232(sp)
    80005586:	740e                	ld	s0,224(sp)
    80005588:	616d                	addi	sp,sp,240
    8000558a:	8082                	ret
    return -1;
    8000558c:	557d                	li	a0,-1
    8000558e:	bfdd                	j	80005584 <sys_unlink+0x168>
    iunlockput(ip);
    80005590:	854a                	mv	a0,s2
    80005592:	c94fe0ef          	jal	80003a26 <iunlockput>
    goto bad;
    80005596:	694e                	ld	s2,208(sp)
    80005598:	69ae                	ld	s3,200(sp)
    8000559a:	bff1                	j	80005576 <sys_unlink+0x15a>

000000008000559c <sys_open>:

uint64
sys_open(void)
{
    8000559c:	7131                	addi	sp,sp,-192
    8000559e:	fd06                	sd	ra,184(sp)
    800055a0:	f922                	sd	s0,176(sp)
    800055a2:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    800055a4:	f4c40593          	addi	a1,s0,-180
    800055a8:	4505                	li	a0,1
    800055aa:	fd4fd0ef          	jal	80002d7e <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    800055ae:	08000613          	li	a2,128
    800055b2:	f5040593          	addi	a1,s0,-176
    800055b6:	4501                	li	a0,0
    800055b8:	ffefd0ef          	jal	80002db6 <argstr>
    800055bc:	87aa                	mv	a5,a0
    return -1;
    800055be:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    800055c0:	0a07c363          	bltz	a5,80005666 <sys_open+0xca>
    800055c4:	f526                	sd	s1,168(sp)

  begin_op();
    800055c6:	c61fe0ef          	jal	80004226 <begin_op>

  if(omode & O_CREATE){
    800055ca:	f4c42783          	lw	a5,-180(s0)
    800055ce:	2007f793          	andi	a5,a5,512
    800055d2:	c3dd                	beqz	a5,80005678 <sys_open+0xdc>
    ip = create(path, T_FILE, 0, 0);
    800055d4:	4681                	li	a3,0
    800055d6:	4601                	li	a2,0
    800055d8:	4589                	li	a1,2
    800055da:	f5040513          	addi	a0,s0,-176
    800055de:	aafff0ef          	jal	8000508c <create>
    800055e2:	84aa                	mv	s1,a0
    if(ip == 0){
    800055e4:	c549                	beqz	a0,8000566e <sys_open+0xd2>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    800055e6:	04449703          	lh	a4,68(s1)
    800055ea:	478d                	li	a5,3
    800055ec:	00f71763          	bne	a4,a5,800055fa <sys_open+0x5e>
    800055f0:	0464d703          	lhu	a4,70(s1)
    800055f4:	47a5                	li	a5,9
    800055f6:	0ae7ee63          	bltu	a5,a4,800056b2 <sys_open+0x116>
    800055fa:	f14a                	sd	s2,160(sp)
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    800055fc:	fabfe0ef          	jal	800045a6 <filealloc>
    80005600:	892a                	mv	s2,a0
    80005602:	c561                	beqz	a0,800056ca <sys_open+0x12e>
    80005604:	ed4e                	sd	s3,152(sp)
    80005606:	a47ff0ef          	jal	8000504c <fdalloc>
    8000560a:	89aa                	mv	s3,a0
    8000560c:	0a054b63          	bltz	a0,800056c2 <sys_open+0x126>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    80005610:	04449703          	lh	a4,68(s1)
    80005614:	478d                	li	a5,3
    80005616:	0cf70363          	beq	a4,a5,800056dc <sys_open+0x140>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    8000561a:	4789                	li	a5,2
    8000561c:	00f92023          	sw	a5,0(s2)
    f->off = 0;
    80005620:	02092023          	sw	zero,32(s2)
  }
  f->ip = ip;
    80005624:	00993c23          	sd	s1,24(s2)
  f->readable = !(omode & O_WRONLY);
    80005628:	f4c42783          	lw	a5,-180(s0)
    8000562c:	0017f713          	andi	a4,a5,1
    80005630:	00174713          	xori	a4,a4,1
    80005634:	00e90423          	sb	a4,8(s2)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80005638:	0037f713          	andi	a4,a5,3
    8000563c:	00e03733          	snez	a4,a4
    80005640:	00e904a3          	sb	a4,9(s2)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    80005644:	4007f793          	andi	a5,a5,1024
    80005648:	c791                	beqz	a5,80005654 <sys_open+0xb8>
    8000564a:	04449703          	lh	a4,68(s1)
    8000564e:	4789                	li	a5,2
    80005650:	08f70d63          	beq	a4,a5,800056ea <sys_open+0x14e>
    itrunc(ip);
  }

  iunlock(ip);
    80005654:	8526                	mv	a0,s1
    80005656:	a72fe0ef          	jal	800038c8 <iunlock>
  end_op();
    8000565a:	c3dfe0ef          	jal	80004296 <end_op>

  return fd;
    8000565e:	854e                	mv	a0,s3
    80005660:	74aa                	ld	s1,168(sp)
    80005662:	790a                	ld	s2,160(sp)
    80005664:	69ea                	ld	s3,152(sp)
}
    80005666:	70ea                	ld	ra,184(sp)
    80005668:	744a                	ld	s0,176(sp)
    8000566a:	6129                	addi	sp,sp,192
    8000566c:	8082                	ret
      end_op();
    8000566e:	c29fe0ef          	jal	80004296 <end_op>
      return -1;
    80005672:	557d                	li	a0,-1
    80005674:	74aa                	ld	s1,168(sp)
    80005676:	bfc5                	j	80005666 <sys_open+0xca>
    if((ip = namei(path)) == 0){
    80005678:	f5040513          	addi	a0,s0,-176
    8000567c:	9cdfe0ef          	jal	80004048 <namei>
    80005680:	84aa                	mv	s1,a0
    80005682:	c11d                	beqz	a0,800056a8 <sys_open+0x10c>
    ilock(ip);
    80005684:	996fe0ef          	jal	8000381a <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80005688:	04449703          	lh	a4,68(s1)
    8000568c:	4785                	li	a5,1
    8000568e:	f4f71ce3          	bne	a4,a5,800055e6 <sys_open+0x4a>
    80005692:	f4c42783          	lw	a5,-180(s0)
    80005696:	d3b5                	beqz	a5,800055fa <sys_open+0x5e>
      iunlockput(ip);
    80005698:	8526                	mv	a0,s1
    8000569a:	b8cfe0ef          	jal	80003a26 <iunlockput>
      end_op();
    8000569e:	bf9fe0ef          	jal	80004296 <end_op>
      return -1;
    800056a2:	557d                	li	a0,-1
    800056a4:	74aa                	ld	s1,168(sp)
    800056a6:	b7c1                	j	80005666 <sys_open+0xca>
      end_op();
    800056a8:	beffe0ef          	jal	80004296 <end_op>
      return -1;
    800056ac:	557d                	li	a0,-1
    800056ae:	74aa                	ld	s1,168(sp)
    800056b0:	bf5d                	j	80005666 <sys_open+0xca>
    iunlockput(ip);
    800056b2:	8526                	mv	a0,s1
    800056b4:	b72fe0ef          	jal	80003a26 <iunlockput>
    end_op();
    800056b8:	bdffe0ef          	jal	80004296 <end_op>
    return -1;
    800056bc:	557d                	li	a0,-1
    800056be:	74aa                	ld	s1,168(sp)
    800056c0:	b75d                	j	80005666 <sys_open+0xca>
      fileclose(f);
    800056c2:	854a                	mv	a0,s2
    800056c4:	f87fe0ef          	jal	8000464a <fileclose>
    800056c8:	69ea                	ld	s3,152(sp)
    iunlockput(ip);
    800056ca:	8526                	mv	a0,s1
    800056cc:	b5afe0ef          	jal	80003a26 <iunlockput>
    end_op();
    800056d0:	bc7fe0ef          	jal	80004296 <end_op>
    return -1;
    800056d4:	557d                	li	a0,-1
    800056d6:	74aa                	ld	s1,168(sp)
    800056d8:	790a                	ld	s2,160(sp)
    800056da:	b771                	j	80005666 <sys_open+0xca>
    f->type = FD_DEVICE;
    800056dc:	00e92023          	sw	a4,0(s2)
    f->major = ip->major;
    800056e0:	04649783          	lh	a5,70(s1)
    800056e4:	02f91223          	sh	a5,36(s2)
    800056e8:	bf35                	j	80005624 <sys_open+0x88>
    itrunc(ip);
    800056ea:	8526                	mv	a0,s1
    800056ec:	a1cfe0ef          	jal	80003908 <itrunc>
    800056f0:	b795                	j	80005654 <sys_open+0xb8>

00000000800056f2 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    800056f2:	7175                	addi	sp,sp,-144
    800056f4:	e506                	sd	ra,136(sp)
    800056f6:	e122                	sd	s0,128(sp)
    800056f8:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    800056fa:	b2dfe0ef          	jal	80004226 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    800056fe:	08000613          	li	a2,128
    80005702:	f7040593          	addi	a1,s0,-144
    80005706:	4501                	li	a0,0
    80005708:	eaefd0ef          	jal	80002db6 <argstr>
    8000570c:	02054363          	bltz	a0,80005732 <sys_mkdir+0x40>
    80005710:	4681                	li	a3,0
    80005712:	4601                	li	a2,0
    80005714:	4585                	li	a1,1
    80005716:	f7040513          	addi	a0,s0,-144
    8000571a:	973ff0ef          	jal	8000508c <create>
    8000571e:	c911                	beqz	a0,80005732 <sys_mkdir+0x40>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005720:	b06fe0ef          	jal	80003a26 <iunlockput>
  end_op();
    80005724:	b73fe0ef          	jal	80004296 <end_op>
  return 0;
    80005728:	4501                	li	a0,0
}
    8000572a:	60aa                	ld	ra,136(sp)
    8000572c:	640a                	ld	s0,128(sp)
    8000572e:	6149                	addi	sp,sp,144
    80005730:	8082                	ret
    end_op();
    80005732:	b65fe0ef          	jal	80004296 <end_op>
    return -1;
    80005736:	557d                	li	a0,-1
    80005738:	bfcd                	j	8000572a <sys_mkdir+0x38>

000000008000573a <sys_mknod>:

uint64
sys_mknod(void)
{
    8000573a:	7135                	addi	sp,sp,-160
    8000573c:	ed06                	sd	ra,152(sp)
    8000573e:	e922                	sd	s0,144(sp)
    80005740:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80005742:	ae5fe0ef          	jal	80004226 <begin_op>
  argint(1, &major);
    80005746:	f6c40593          	addi	a1,s0,-148
    8000574a:	4505                	li	a0,1
    8000574c:	e32fd0ef          	jal	80002d7e <argint>
  argint(2, &minor);
    80005750:	f6840593          	addi	a1,s0,-152
    80005754:	4509                	li	a0,2
    80005756:	e28fd0ef          	jal	80002d7e <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    8000575a:	08000613          	li	a2,128
    8000575e:	f7040593          	addi	a1,s0,-144
    80005762:	4501                	li	a0,0
    80005764:	e52fd0ef          	jal	80002db6 <argstr>
    80005768:	02054563          	bltz	a0,80005792 <sys_mknod+0x58>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    8000576c:	f6841683          	lh	a3,-152(s0)
    80005770:	f6c41603          	lh	a2,-148(s0)
    80005774:	458d                	li	a1,3
    80005776:	f7040513          	addi	a0,s0,-144
    8000577a:	913ff0ef          	jal	8000508c <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    8000577e:	c911                	beqz	a0,80005792 <sys_mknod+0x58>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005780:	aa6fe0ef          	jal	80003a26 <iunlockput>
  end_op();
    80005784:	b13fe0ef          	jal	80004296 <end_op>
  return 0;
    80005788:	4501                	li	a0,0
}
    8000578a:	60ea                	ld	ra,152(sp)
    8000578c:	644a                	ld	s0,144(sp)
    8000578e:	610d                	addi	sp,sp,160
    80005790:	8082                	ret
    end_op();
    80005792:	b05fe0ef          	jal	80004296 <end_op>
    return -1;
    80005796:	557d                	li	a0,-1
    80005798:	bfcd                	j	8000578a <sys_mknod+0x50>

000000008000579a <sys_chdir>:

uint64
sys_chdir(void)
{
    8000579a:	7135                	addi	sp,sp,-160
    8000579c:	ed06                	sd	ra,152(sp)
    8000579e:	e922                	sd	s0,144(sp)
    800057a0:	e14a                	sd	s2,128(sp)
    800057a2:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    800057a4:	c84fc0ef          	jal	80001c28 <myproc>
    800057a8:	892a                	mv	s2,a0
  
  begin_op();
    800057aa:	a7dfe0ef          	jal	80004226 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    800057ae:	08000613          	li	a2,128
    800057b2:	f6040593          	addi	a1,s0,-160
    800057b6:	4501                	li	a0,0
    800057b8:	dfefd0ef          	jal	80002db6 <argstr>
    800057bc:	04054363          	bltz	a0,80005802 <sys_chdir+0x68>
    800057c0:	e526                	sd	s1,136(sp)
    800057c2:	f6040513          	addi	a0,s0,-160
    800057c6:	883fe0ef          	jal	80004048 <namei>
    800057ca:	84aa                	mv	s1,a0
    800057cc:	c915                	beqz	a0,80005800 <sys_chdir+0x66>
    end_op();
    return -1;
  }
  ilock(ip);
    800057ce:	84cfe0ef          	jal	8000381a <ilock>
  if(ip->type != T_DIR){
    800057d2:	04449703          	lh	a4,68(s1)
    800057d6:	4785                	li	a5,1
    800057d8:	02f71963          	bne	a4,a5,8000580a <sys_chdir+0x70>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    800057dc:	8526                	mv	a0,s1
    800057de:	8eafe0ef          	jal	800038c8 <iunlock>
  iput(p->cwd);
    800057e2:	15093503          	ld	a0,336(s2)
    800057e6:	9b6fe0ef          	jal	8000399c <iput>
  end_op();
    800057ea:	aadfe0ef          	jal	80004296 <end_op>
  p->cwd = ip;
    800057ee:	14993823          	sd	s1,336(s2)
  return 0;
    800057f2:	4501                	li	a0,0
    800057f4:	64aa                	ld	s1,136(sp)
}
    800057f6:	60ea                	ld	ra,152(sp)
    800057f8:	644a                	ld	s0,144(sp)
    800057fa:	690a                	ld	s2,128(sp)
    800057fc:	610d                	addi	sp,sp,160
    800057fe:	8082                	ret
    80005800:	64aa                	ld	s1,136(sp)
    end_op();
    80005802:	a95fe0ef          	jal	80004296 <end_op>
    return -1;
    80005806:	557d                	li	a0,-1
    80005808:	b7fd                	j	800057f6 <sys_chdir+0x5c>
    iunlockput(ip);
    8000580a:	8526                	mv	a0,s1
    8000580c:	a1afe0ef          	jal	80003a26 <iunlockput>
    end_op();
    80005810:	a87fe0ef          	jal	80004296 <end_op>
    return -1;
    80005814:	557d                	li	a0,-1
    80005816:	64aa                	ld	s1,136(sp)
    80005818:	bff9                	j	800057f6 <sys_chdir+0x5c>

000000008000581a <sys_exec>:

uint64
sys_exec(void)
{
    8000581a:	7105                	addi	sp,sp,-480
    8000581c:	ef86                	sd	ra,472(sp)
    8000581e:	eba2                	sd	s0,464(sp)
    80005820:	1380                	addi	s0,sp,480
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    80005822:	e2840593          	addi	a1,s0,-472
    80005826:	4505                	li	a0,1
    80005828:	d72fd0ef          	jal	80002d9a <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    8000582c:	08000613          	li	a2,128
    80005830:	f3040593          	addi	a1,s0,-208
    80005834:	4501                	li	a0,0
    80005836:	d80fd0ef          	jal	80002db6 <argstr>
    8000583a:	87aa                	mv	a5,a0
    return -1;
    8000583c:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    8000583e:	0e07c063          	bltz	a5,8000591e <sys_exec+0x104>
    80005842:	e7a6                	sd	s1,456(sp)
    80005844:	e3ca                	sd	s2,448(sp)
    80005846:	ff4e                	sd	s3,440(sp)
    80005848:	fb52                	sd	s4,432(sp)
    8000584a:	f756                	sd	s5,424(sp)
    8000584c:	f35a                	sd	s6,416(sp)
    8000584e:	ef5e                	sd	s7,408(sp)
  }
  memset(argv, 0, sizeof(argv));
    80005850:	e3040a13          	addi	s4,s0,-464
    80005854:	10000613          	li	a2,256
    80005858:	4581                	li	a1,0
    8000585a:	8552                	mv	a0,s4
    8000585c:	d8afb0ef          	jal	80000de6 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80005860:	84d2                	mv	s1,s4
  memset(argv, 0, sizeof(argv));
    80005862:	89d2                	mv	s3,s4
    80005864:	4901                	li	s2,0
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80005866:	e2040a93          	addi	s5,s0,-480
      break;
    }
    argv[i] = kalloc();
    if(argv[i] == 0)
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    8000586a:	6b05                	lui	s6,0x1
    if(i >= NELEM(argv)){
    8000586c:	02000b93          	li	s7,32
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80005870:	00391513          	slli	a0,s2,0x3
    80005874:	85d6                	mv	a1,s5
    80005876:	e2843783          	ld	a5,-472(s0)
    8000587a:	953e                	add	a0,a0,a5
    8000587c:	c78fd0ef          	jal	80002cf4 <fetchaddr>
    80005880:	02054663          	bltz	a0,800058ac <sys_exec+0x92>
    if(uarg == 0){
    80005884:	e2043783          	ld	a5,-480(s0)
    80005888:	c7a1                	beqz	a5,800058d0 <sys_exec+0xb6>
    argv[i] = kalloc();
    8000588a:	b4afb0ef          	jal	80000bd4 <kalloc>
    8000588e:	85aa                	mv	a1,a0
    80005890:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80005894:	cd01                	beqz	a0,800058ac <sys_exec+0x92>
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80005896:	865a                	mv	a2,s6
    80005898:	e2043503          	ld	a0,-480(s0)
    8000589c:	ca2fd0ef          	jal	80002d3e <fetchstr>
    800058a0:	00054663          	bltz	a0,800058ac <sys_exec+0x92>
    if(i >= NELEM(argv)){
    800058a4:	0905                	addi	s2,s2,1
    800058a6:	09a1                	addi	s3,s3,8
    800058a8:	fd7914e3          	bne	s2,s7,80005870 <sys_exec+0x56>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800058ac:	100a0a13          	addi	s4,s4,256
    800058b0:	6088                	ld	a0,0(s1)
    800058b2:	cd31                	beqz	a0,8000590e <sys_exec+0xf4>
    kfree(argv[i]);
    800058b4:	9dafb0ef          	jal	80000a8e <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800058b8:	04a1                	addi	s1,s1,8
    800058ba:	ff449be3          	bne	s1,s4,800058b0 <sys_exec+0x96>
  return -1;
    800058be:	557d                	li	a0,-1
    800058c0:	64be                	ld	s1,456(sp)
    800058c2:	691e                	ld	s2,448(sp)
    800058c4:	79fa                	ld	s3,440(sp)
    800058c6:	7a5a                	ld	s4,432(sp)
    800058c8:	7aba                	ld	s5,424(sp)
    800058ca:	7b1a                	ld	s6,416(sp)
    800058cc:	6bfa                	ld	s7,408(sp)
    800058ce:	a881                	j	8000591e <sys_exec+0x104>
      argv[i] = 0;
    800058d0:	0009079b          	sext.w	a5,s2
    800058d4:	e3040593          	addi	a1,s0,-464
    800058d8:	078e                	slli	a5,a5,0x3
    800058da:	97ae                	add	a5,a5,a1
    800058dc:	0007b023          	sd	zero,0(a5)
  int ret = kexec(path, argv);
    800058e0:	f3040513          	addi	a0,s0,-208
    800058e4:	bb2ff0ef          	jal	80004c96 <kexec>
    800058e8:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800058ea:	100a0a13          	addi	s4,s4,256
    800058ee:	6088                	ld	a0,0(s1)
    800058f0:	c511                	beqz	a0,800058fc <sys_exec+0xe2>
    kfree(argv[i]);
    800058f2:	99cfb0ef          	jal	80000a8e <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800058f6:	04a1                	addi	s1,s1,8
    800058f8:	ff449be3          	bne	s1,s4,800058ee <sys_exec+0xd4>
  return ret;
    800058fc:	854a                	mv	a0,s2
    800058fe:	64be                	ld	s1,456(sp)
    80005900:	691e                	ld	s2,448(sp)
    80005902:	79fa                	ld	s3,440(sp)
    80005904:	7a5a                	ld	s4,432(sp)
    80005906:	7aba                	ld	s5,424(sp)
    80005908:	7b1a                	ld	s6,416(sp)
    8000590a:	6bfa                	ld	s7,408(sp)
    8000590c:	a809                	j	8000591e <sys_exec+0x104>
  return -1;
    8000590e:	557d                	li	a0,-1
    80005910:	64be                	ld	s1,456(sp)
    80005912:	691e                	ld	s2,448(sp)
    80005914:	79fa                	ld	s3,440(sp)
    80005916:	7a5a                	ld	s4,432(sp)
    80005918:	7aba                	ld	s5,424(sp)
    8000591a:	7b1a                	ld	s6,416(sp)
    8000591c:	6bfa                	ld	s7,408(sp)
}
    8000591e:	60fe                	ld	ra,472(sp)
    80005920:	645e                	ld	s0,464(sp)
    80005922:	613d                	addi	sp,sp,480
    80005924:	8082                	ret

0000000080005926 <sys_pipe>:

uint64
sys_pipe(void)
{
    80005926:	7139                	addi	sp,sp,-64
    80005928:	fc06                	sd	ra,56(sp)
    8000592a:	f822                	sd	s0,48(sp)
    8000592c:	f426                	sd	s1,40(sp)
    8000592e:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80005930:	af8fc0ef          	jal	80001c28 <myproc>
    80005934:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    80005936:	fd840593          	addi	a1,s0,-40
    8000593a:	4501                	li	a0,0
    8000593c:	c5efd0ef          	jal	80002d9a <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    80005940:	fc840593          	addi	a1,s0,-56
    80005944:	fd040513          	addi	a0,s0,-48
    80005948:	81eff0ef          	jal	80004966 <pipealloc>
    return -1;
    8000594c:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    8000594e:	0a054763          	bltz	a0,800059fc <sys_pipe+0xd6>
  fd0 = -1;
    80005952:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80005956:	fd043503          	ld	a0,-48(s0)
    8000595a:	ef2ff0ef          	jal	8000504c <fdalloc>
    8000595e:	fca42223          	sw	a0,-60(s0)
    80005962:	08054463          	bltz	a0,800059ea <sys_pipe+0xc4>
    80005966:	fc843503          	ld	a0,-56(s0)
    8000596a:	ee2ff0ef          	jal	8000504c <fdalloc>
    8000596e:	fca42023          	sw	a0,-64(s0)
    80005972:	06054263          	bltz	a0,800059d6 <sys_pipe+0xb0>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005976:	4691                	li	a3,4
    80005978:	fc440613          	addi	a2,s0,-60
    8000597c:	fd843583          	ld	a1,-40(s0)
    80005980:	68a8                	ld	a0,80(s1)
    80005982:	fb9fb0ef          	jal	8000193a <copyout>
    80005986:	00054e63          	bltz	a0,800059a2 <sys_pipe+0x7c>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    8000598a:	4691                	li	a3,4
    8000598c:	fc040613          	addi	a2,s0,-64
    80005990:	fd843583          	ld	a1,-40(s0)
    80005994:	95b6                	add	a1,a1,a3
    80005996:	68a8                	ld	a0,80(s1)
    80005998:	fa3fb0ef          	jal	8000193a <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    8000599c:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    8000599e:	04055f63          	bgez	a0,800059fc <sys_pipe+0xd6>
    p->ofile[fd0] = 0;
    800059a2:	fc442783          	lw	a5,-60(s0)
    800059a6:	078e                	slli	a5,a5,0x3
    800059a8:	0d078793          	addi	a5,a5,208
    800059ac:	97a6                	add	a5,a5,s1
    800059ae:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    800059b2:	fc042783          	lw	a5,-64(s0)
    800059b6:	078e                	slli	a5,a5,0x3
    800059b8:	0d078793          	addi	a5,a5,208
    800059bc:	97a6                	add	a5,a5,s1
    800059be:	0007b023          	sd	zero,0(a5)
    fileclose(rf);
    800059c2:	fd043503          	ld	a0,-48(s0)
    800059c6:	c85fe0ef          	jal	8000464a <fileclose>
    fileclose(wf);
    800059ca:	fc843503          	ld	a0,-56(s0)
    800059ce:	c7dfe0ef          	jal	8000464a <fileclose>
    return -1;
    800059d2:	57fd                	li	a5,-1
    800059d4:	a025                	j	800059fc <sys_pipe+0xd6>
    if(fd0 >= 0)
    800059d6:	fc442783          	lw	a5,-60(s0)
    800059da:	0007c863          	bltz	a5,800059ea <sys_pipe+0xc4>
      p->ofile[fd0] = 0;
    800059de:	078e                	slli	a5,a5,0x3
    800059e0:	0d078793          	addi	a5,a5,208
    800059e4:	97a6                	add	a5,a5,s1
    800059e6:	0007b023          	sd	zero,0(a5)
    fileclose(rf);
    800059ea:	fd043503          	ld	a0,-48(s0)
    800059ee:	c5dfe0ef          	jal	8000464a <fileclose>
    fileclose(wf);
    800059f2:	fc843503          	ld	a0,-56(s0)
    800059f6:	c55fe0ef          	jal	8000464a <fileclose>
    return -1;
    800059fa:	57fd                	li	a5,-1
}
    800059fc:	853e                	mv	a0,a5
    800059fe:	70e2                	ld	ra,56(sp)
    80005a00:	7442                	ld	s0,48(sp)
    80005a02:	74a2                	ld	s1,40(sp)
    80005a04:	6121                	addi	sp,sp,64
    80005a06:	8082                	ret

0000000080005a08 <sys_fsread>:
uint64
sys_fsread(void)
{
    80005a08:	1101                	addi	sp,sp,-32
    80005a0a:	ec06                	sd	ra,24(sp)
    80005a0c:	e822                	sd	s0,16(sp)
    80005a0e:	1000                	addi	s0,sp,32
  uint64 addr;
  int n;

  // استدعاء الدوال بدون مقارنتها بـ < 0 لأنها تعيد void
  argaddr(0, &addr); 
    80005a10:	fe840593          	addi	a1,s0,-24
    80005a14:	4501                	li	a0,0
    80005a16:	b84fd0ef          	jal	80002d9a <argaddr>
  argint(1, &n);
    80005a1a:	fe440593          	addi	a1,s0,-28
    80005a1e:	4505                	li	a0,1
    80005a20:	b5efd0ef          	jal	80002d7e <argint>

  // استدعاء الوظيفة الحقيقية وإعادة نتيجتها
  return fslog_read_many((struct fs_event *)addr, n);
    80005a24:	fe442583          	lw	a1,-28(s0)
    80005a28:	fe843503          	ld	a0,-24(s0)
    80005a2c:	201000ef          	jal	8000642c <fslog_read_many>
    80005a30:	60e2                	ld	ra,24(sp)
    80005a32:	6442                	ld	s0,16(sp)
    80005a34:	6105                	addi	sp,sp,32
    80005a36:	8082                	ret
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
    80005a66:	99cfd0ef          	jal	80002c02 <kerneltrap>

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
    80005ac0:	934fc0ef          	jal	80001bf4 <cpuid>
  
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
    80005af4:	900fc0ef          	jal	80001bf4 <cpuid>
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
    80005b18:	8dcfc0ef          	jal	80001bf4 <cpuid>
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
    80005b40:	0001c797          	auipc	a5,0x1c
    80005b44:	03078793          	addi	a5,a5,48 # 80021b70 <disk>
    80005b48:	97aa                	add	a5,a5,a0
    80005b4a:	0187c783          	lbu	a5,24(a5)
    80005b4e:	e7b9                	bnez	a5,80005b9c <free_desc+0x6a>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    80005b50:	00451693          	slli	a3,a0,0x4
    80005b54:	0001c797          	auipc	a5,0x1c
    80005b58:	01c78793          	addi	a5,a5,28 # 80021b70 <disk>
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
    80005b7c:	0001c517          	auipc	a0,0x1c
    80005b80:	00c50513          	addi	a0,a0,12 # 80021b88 <disk+0x18>
    80005b84:	93bfc0ef          	jal	800024be <wakeup>
}
    80005b88:	60a2                	ld	ra,8(sp)
    80005b8a:	6402                	ld	s0,0(sp)
    80005b8c:	0141                	addi	sp,sp,16
    80005b8e:	8082                	ret
    panic("free_desc 1");
    80005b90:	00003517          	auipc	a0,0x3
    80005b94:	ae850513          	addi	a0,a0,-1304 # 80008678 <etext+0x678>
    80005b98:	cbffa0ef          	jal	80000856 <panic>
    panic("free_desc 2");
    80005b9c:	00003517          	auipc	a0,0x3
    80005ba0:	aec50513          	addi	a0,a0,-1300 # 80008688 <etext+0x688>
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
    80005bb8:	ae458593          	addi	a1,a1,-1308 # 80008698 <etext+0x698>
    80005bbc:	0001c517          	auipc	a0,0x1c
    80005bc0:	0dc50513          	addi	a0,a0,220 # 80021c98 <disk+0x128>
    80005bc4:	8c8fb0ef          	jal	80000c8c <initlock>
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
    80005c24:	75f68693          	addi	a3,a3,1887 # ffffffffc7ffe75f <end+0xffffffff47fb7a07>
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
    80005c66:	f6ffa0ef          	jal	80000bd4 <kalloc>
    80005c6a:	0001c497          	auipc	s1,0x1c
    80005c6e:	f0648493          	addi	s1,s1,-250 # 80021b70 <disk>
    80005c72:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    80005c74:	f61fa0ef          	jal	80000bd4 <kalloc>
    80005c78:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    80005c7a:	f5bfa0ef          	jal	80000bd4 <kalloc>
    80005c7e:	87aa                	mv	a5,a0
    80005c80:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    80005c82:	6088                	ld	a0,0(s1)
    80005c84:	0e050063          	beqz	a0,80005d64 <virtio_disk_init+0x1bc>
    80005c88:	0001c717          	auipc	a4,0x1c
    80005c8c:	ef073703          	ld	a4,-272(a4) # 80021b78 <disk+0x8>
    80005c90:	cb71                	beqz	a4,80005d64 <virtio_disk_init+0x1bc>
    80005c92:	cbe9                	beqz	a5,80005d64 <virtio_disk_init+0x1bc>
  memset(disk.desc, 0, PGSIZE);
    80005c94:	6605                	lui	a2,0x1
    80005c96:	4581                	li	a1,0
    80005c98:	94efb0ef          	jal	80000de6 <memset>
  memset(disk.avail, 0, PGSIZE);
    80005c9c:	0001c497          	auipc	s1,0x1c
    80005ca0:	ed448493          	addi	s1,s1,-300 # 80021b70 <disk>
    80005ca4:	6605                	lui	a2,0x1
    80005ca6:	4581                	li	a1,0
    80005ca8:	6488                	ld	a0,8(s1)
    80005caa:	93cfb0ef          	jal	80000de6 <memset>
  memset(disk.used, 0, PGSIZE);
    80005cae:	6605                	lui	a2,0x1
    80005cb0:	4581                	li	a1,0
    80005cb2:	6888                	ld	a0,16(s1)
    80005cb4:	932fb0ef          	jal	80000de6 <memset>
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
    80005d2c:	98050513          	addi	a0,a0,-1664 # 800086a8 <etext+0x6a8>
    80005d30:	b27fa0ef          	jal	80000856 <panic>
    panic("virtio disk FEATURES_OK unset");
    80005d34:	00003517          	auipc	a0,0x3
    80005d38:	99450513          	addi	a0,a0,-1644 # 800086c8 <etext+0x6c8>
    80005d3c:	b1bfa0ef          	jal	80000856 <panic>
    panic("virtio disk should not be ready");
    80005d40:	00003517          	auipc	a0,0x3
    80005d44:	9a850513          	addi	a0,a0,-1624 # 800086e8 <etext+0x6e8>
    80005d48:	b0ffa0ef          	jal	80000856 <panic>
    panic("virtio disk has no queue 0");
    80005d4c:	00003517          	auipc	a0,0x3
    80005d50:	9bc50513          	addi	a0,a0,-1604 # 80008708 <etext+0x708>
    80005d54:	b03fa0ef          	jal	80000856 <panic>
    panic("virtio disk max queue too short");
    80005d58:	00003517          	auipc	a0,0x3
    80005d5c:	9d050513          	addi	a0,a0,-1584 # 80008728 <etext+0x728>
    80005d60:	af7fa0ef          	jal	80000856 <panic>
    panic("virtio disk kalloc");
    80005d64:	00003517          	auipc	a0,0x3
    80005d68:	9e450513          	addi	a0,a0,-1564 # 80008748 <etext+0x748>
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
    80005d9a:	0001c517          	auipc	a0,0x1c
    80005d9e:	efe50513          	addi	a0,a0,-258 # 80021c98 <disk+0x128>
    80005da2:	f75fa0ef          	jal	80000d16 <acquire>
  for(int i = 0; i < NUM; i++){
    80005da6:	44a1                	li	s1,8
      disk.free[i] = 0;
    80005da8:	0001ca97          	auipc	s5,0x1c
    80005dac:	dc8a8a93          	addi	s5,s5,-568 # 80021b70 <disk>
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
    80005dce:	0001c717          	auipc	a4,0x1c
    80005dd2:	da270713          	addi	a4,a4,-606 # 80021b70 <disk>
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
    80005e04:	0001c597          	auipc	a1,0x1c
    80005e08:	e9458593          	addi	a1,a1,-364 # 80021c98 <disk+0x128>
    80005e0c:	0001c517          	auipc	a0,0x1c
    80005e10:	d7c50513          	addi	a0,a0,-644 # 80021b88 <disk+0x18>
    80005e14:	e5efc0ef          	jal	80002472 <sleep>
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
    80005e28:	0001c797          	auipc	a5,0x1c
    80005e2c:	d4878793          	addi	a5,a5,-696 # 80021b70 <disk>
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
    80005f02:	0001c917          	auipc	s2,0x1c
    80005f06:	d9690913          	addi	s2,s2,-618 # 80021c98 <disk+0x128>
  while(b->disk == 1) {
    80005f0a:	84ae                	mv	s1,a1
    80005f0c:	00b79a63          	bne	a5,a1,80005f20 <virtio_disk_rw+0x1b0>
    sleep(b, &disk.vdisk_lock);
    80005f10:	85ca                	mv	a1,s2
    80005f12:	854e                	mv	a0,s3
    80005f14:	d5efc0ef          	jal	80002472 <sleep>
  while(b->disk == 1) {
    80005f18:	0049a783          	lw	a5,4(s3)
    80005f1c:	fe978ae3          	beq	a5,s1,80005f10 <virtio_disk_rw+0x1a0>
  }

  disk.info[idx[0]].b = 0;
    80005f20:	fa042903          	lw	s2,-96(s0)
    80005f24:	00491713          	slli	a4,s2,0x4
    80005f28:	02070713          	addi	a4,a4,32
    80005f2c:	0001c797          	auipc	a5,0x1c
    80005f30:	c4478793          	addi	a5,a5,-956 # 80021b70 <disk>
    80005f34:	97ba                	add	a5,a5,a4
    80005f36:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    80005f3a:	0001c997          	auipc	s3,0x1c
    80005f3e:	c3698993          	addi	s3,s3,-970 # 80021b70 <disk>
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
    80005f5e:	0001c517          	auipc	a0,0x1c
    80005f62:	d3a50513          	addi	a0,a0,-710 # 80021c98 <disk+0x128>
    80005f66:	e45fa0ef          	jal	80000daa <release>
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
    80005f8c:	0001c497          	auipc	s1,0x1c
    80005f90:	be448493          	addi	s1,s1,-1052 # 80021b70 <disk>
    80005f94:	0001c517          	auipc	a0,0x1c
    80005f98:	d0450513          	addi	a0,a0,-764 # 80021c98 <disk+0x128>
    80005f9c:	d7bfa0ef          	jal	80000d16 <acquire>
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
    80005ff0:	ccefc0ef          	jal	800024be <wakeup>

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
    8000600c:	0001c517          	auipc	a0,0x1c
    80006010:	c8c50513          	addi	a0,a0,-884 # 80021c98 <disk+0x128>
    80006014:	d97fa0ef          	jal	80000daa <release>
}
    80006018:	60e2                	ld	ra,24(sp)
    8000601a:	6442                	ld	s0,16(sp)
    8000601c:	64a2                	ld	s1,8(sp)
    8000601e:	6105                	addi	sp,sp,32
    80006020:	8082                	ret
      panic("virtio_disk_intr status");
    80006022:	00002517          	auipc	a0,0x2
    80006026:	73e50513          	addi	a0,a0,1854 # 80008760 <etext+0x760>
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
    8000603e:	73e58593          	addi	a1,a1,1854 # 80008778 <etext+0x778>
    80006042:	0001c517          	auipc	a0,0x1c
    80006046:	c6e50513          	addi	a0,a0,-914 # 80021cb0 <cs_rb>
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
    80006064:	8d870713          	addi	a4,a4,-1832 # 80008938 <cs_seq>
    80006068:	631c                	ld	a5,0(a4)
    8000606a:	0785                	addi	a5,a5,1
    8000606c:	e31c                	sd	a5,0(a4)
    8000606e:	e11c                	sd	a5,0(a0)
  ringbuf_push(&cs_rb, e);
    80006070:	0001c517          	auipc	a0,0x1c
    80006074:	c4050513          	addi	a0,a0,-960 # 80021cb0 <cs_rb>
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
    80006090:	0001c517          	auipc	a0,0x1c
    80006094:	c2050513          	addi	a0,a0,-992 # 80021cb0 <cs_rb>
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
    800060d4:	6b058593          	addi	a1,a1,1712 # 80008780 <etext+0x780>
    800060d8:	854a                	mv	a0,s2
    800060da:	de1fa0ef          	jal	80000eba <strncmp>
    800060de:	e119                	bnez	a0,800060e4 <cslog_run_start+0x40>
    800060e0:	7942                	ld	s2,48(sp)
    800060e2:	bff1                	j	800060be <cslog_run_start+0x1a>
  if(strncmp(p->name, "csexport", 8) == 0) return;
    800060e4:	4621                	li	a2,8
    800060e6:	00002597          	auipc	a1,0x2
    800060ea:	6a258593          	addi	a1,a1,1698 # 80008788 <etext+0x788>
    800060ee:	854a                	mv	a0,s2
    800060f0:	dcbfa0ef          	jal	80000eba <strncmp>
    800060f4:	e119                	bnez	a0,800060fa <cslog_run_start+0x56>
    800060f6:	7942                	ld	s2,48(sp)
    800060f8:	b7d9                	j	800060be <cslog_run_start+0x1a>
  memset(e, 0, sizeof(*e));
    800060fa:	03000613          	li	a2,48
    800060fe:	4581                	li	a1,0
    80006100:	fb040513          	addi	a0,s0,-80
    80006104:	ce3fa0ef          	jal	80000de6 <memset>
  e->ticks = ticks;
    80006108:	00003797          	auipc	a5,0x3
    8000610c:	8287a783          	lw	a5,-2008(a5) # 80008930 <ticks>
    80006110:	faf42c23          	sw	a5,-72(s0)
  e->cpu   = cpuid();
    80006114:	ae1fb0ef          	jal	80001bf4 <cpuid>
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
    80006130:	e0bfa0ef          	jal	80000f3a <safestrcpy>
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
    80006172:	c29fc0ef          	jal	80002d9a <argaddr>
  argint(1, &max);
    80006176:	fd440593          	addi	a1,s0,-44
    8000617a:	4505                	li	a0,1
    8000617c:	c03fc0ef          	jal	80002d7e <argint>

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
    800061ac:	a7dfb0ef          	jal	80001c28 <myproc>
  int bytes = n * (int)sizeof(struct cs_event);
    800061b0:	0019169b          	slliw	a3,s2,0x1
    800061b4:	012686bb          	addw	a3,a3,s2
  if(copyout(myproc()->pagetable, uaddr, (char*)tmp, bytes) < 0)
    800061b8:	0046969b          	slliw	a3,a3,0x4
    800061bc:	8626                	mv	a2,s1
    800061be:	fd843583          	ld	a1,-40(s0)
    800061c2:	6928                	ld	a0,80(a0)
    800061c4:	f76fb0ef          	jal	8000193a <copyout>
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
    800061fc:	a91fa0ef          	jal	80000c8c <initlock>
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
    80006230:	ae7fa0ef          	jal	80000d16 <acquire>

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
    80006252:	bf5fa0ef          	jal	80000e46 <memmove>
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
    80006268:	b43fa0ef          	jal	80000daa <release>
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
    800062a8:	a6ffa0ef          	jal	80000d16 <acquire>
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
    800062ce:	b79fa0ef          	jal	80000e46 <memmove>
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
    800062ea:	ac1fa0ef          	jal	80000daa <release>

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
    8000631a:	9fdfa0ef          	jal	80000d16 <acquire>
  
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
    80006336:	b11fa0ef          	jal	80000e46 <memmove>
  
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
    8000634c:	a5ffa0ef          	jal	80000daa <release>
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
    80006360:	a4bfa0ef          	jal	80000daa <release>
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
    80006378:	42458593          	addi	a1,a1,1060 # 80008798 <etext+0x798>
    8000637c:	00024517          	auipc	a0,0x24
    80006380:	96450513          	addi	a0,a0,-1692 # 80029ce0 <fs_rb>
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
    800063b6:	a31fa0ef          	jal	80000de6 <memset>
  e.seq = ++fs_seq;
    800063ba:	00002717          	auipc	a4,0x2
    800063be:	58670713          	addi	a4,a4,1414 # 80008940 <fs_seq>
    800063c2:	631c                	ld	a5,0(a4)
    800063c4:	0785                	addi	a5,a5,1
    800063c6:	e31c                	sd	a5,0(a4)
    800063c8:	f8f43823          	sd	a5,-112(s0)
  e.ticks = ticks;
    800063cc:	00002797          	auipc	a5,0x2
    800063d0:	5647a783          	lw	a5,1380(a5) # 80008930 <ticks>
    800063d4:	f8f42c23          	sw	a5,-104(s0)
  e.type = type;
    800063d8:	f8942e23          	sw	s1,-100(s0)
  e.pid = myproc() ? myproc()->pid : 0;
    800063dc:	84dfb0ef          	jal	80001c28 <myproc>
    800063e0:	4781                	li	a5,0
    800063e2:	c501                	beqz	a0,800063ea <fslog_push+0x5a>
    800063e4:	845fb0ef          	jal	80001c28 <myproc>
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
    80006406:	b35fa0ef          	jal	80000f3a <safestrcpy>
  ringbuf_push(&fs_rb, &e);
    8000640a:	f9040593          	addi	a1,s0,-112
    8000640e:	00024517          	auipc	a0,0x24
    80006412:	8d250513          	addi	a0,a0,-1838 # 80029ce0 <fs_rb>
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
    8000643e:	feafb0ef          	jal	80001c28 <myproc>

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
    80006456:	00024b17          	auipc	s6,0x24
    8000645a:	88ab0b13          	addi	s6,s6,-1910 # 80029ce0 <fs_rb>
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
    80006476:	cc4fb0ef          	jal	8000193a <copyout>
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
    800064c4:	2e058593          	addi	a1,a1,736 # 800087a0 <etext+0x7a0>
    800064c8:	0002c517          	auipc	a0,0x2c
    800064cc:	84850513          	addi	a0,a0,-1976 # 80031d10 <mem_lock>
    800064d0:	fbcfa0ef          	jal	80000c8c <initlock>
  mem_head = 0;
    800064d4:	00002797          	auipc	a5,0x2
    800064d8:	4807a223          	sw	zero,1156(a5) # 80008958 <mem_head>
  mem_tail = 0;
    800064dc:	00002797          	auipc	a5,0x2
    800064e0:	4607ac23          	sw	zero,1144(a5) # 80008954 <mem_tail>
  mem_count = 0;
    800064e4:	00002797          	auipc	a5,0x2
    800064e8:	4607a623          	sw	zero,1132(a5) # 80008950 <mem_count>
  mem_seq = 0;
    800064ec:	00002797          	auipc	a5,0x2
    800064f0:	4407be23          	sd	zero,1116(a5) # 80008948 <mem_seq>
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
    80006508:	0002c517          	auipc	a0,0x2c
    8000650c:	80850513          	addi	a0,a0,-2040 # 80031d10 <mem_lock>
    80006510:	807fa0ef          	jal	80000d16 <acquire>

  e->seq = ++mem_seq;
    80006514:	00002717          	auipc	a4,0x2
    80006518:	43470713          	addi	a4,a4,1076 # 80008948 <mem_seq>
    8000651c:	631c                	ld	a5,0(a4)
    8000651e:	0785                	addi	a5,a5,1
    80006520:	e31c                	sd	a5,0(a4)
    80006522:	e09c                	sd	a5,0(s1)

  if(mem_count == MEM_RB_CAP){
    80006524:	00002717          	auipc	a4,0x2
    80006528:	42c72703          	lw	a4,1068(a4) # 80008950 <mem_count>
    8000652c:	20000793          	li	a5,512
    80006530:	06f70e63          	beq	a4,a5,800065ac <memlog_push+0xb0>
    mem_tail = (mem_tail + 1) % MEM_RB_CAP;
    mem_count--;
  }

  mem_buf[mem_head] = *e;
    80006534:	00002617          	auipc	a2,0x2
    80006538:	42462603          	lw	a2,1060(a2) # 80008958 <mem_head>
    8000653c:	02061693          	slli	a3,a2,0x20
    80006540:	9281                	srli	a3,a3,0x20
    80006542:	06800793          	li	a5,104
    80006546:	02f686b3          	mul	a3,a3,a5
    8000654a:	8726                	mv	a4,s1
    8000654c:	0002b797          	auipc	a5,0x2b
    80006550:	7dc78793          	addi	a5,a5,2012 # 80031d28 <mem_buf>
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
    80006580:	00002797          	auipc	a5,0x2
    80006584:	3cc7ac23          	sw	a2,984(a5) # 80008958 <mem_head>
  mem_count++;
    80006588:	00002717          	auipc	a4,0x2
    8000658c:	3c870713          	addi	a4,a4,968 # 80008950 <mem_count>
    80006590:	431c                	lw	a5,0(a4)
    80006592:	2785                	addiw	a5,a5,1
    80006594:	c31c                	sw	a5,0(a4)

  release(&mem_lock);
    80006596:	0002b517          	auipc	a0,0x2b
    8000659a:	77a50513          	addi	a0,a0,1914 # 80031d10 <mem_lock>
    8000659e:	80dfa0ef          	jal	80000daa <release>
}
    800065a2:	60e2                	ld	ra,24(sp)
    800065a4:	6442                	ld	s0,16(sp)
    800065a6:	64a2                	ld	s1,8(sp)
    800065a8:	6105                	addi	sp,sp,32
    800065aa:	8082                	ret
    mem_tail = (mem_tail + 1) % MEM_RB_CAP;
    800065ac:	00002717          	auipc	a4,0x2
    800065b0:	3a870713          	addi	a4,a4,936 # 80008954 <mem_tail>
    800065b4:	431c                	lw	a5,0(a4)
    800065b6:	2785                	addiw	a5,a5,1
    800065b8:	1ff7f793          	andi	a5,a5,511
    800065bc:	c31c                	sw	a5,0(a4)
    mem_count--;
    800065be:	1ff00793          	li	a5,511
    800065c2:	00002717          	auipc	a4,0x2
    800065c6:	38f72723          	sw	a5,910(a4) # 80008950 <mem_count>
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
    800065e2:	0002b517          	auipc	a0,0x2b
    800065e6:	72e50513          	addi	a0,a0,1838 # 80031d10 <mem_lock>
    800065ea:	f2cfa0ef          	jal	80000d16 <acquire>
  while(n < max && mem_count > 0){
    800065ee:	00002697          	auipc	a3,0x2
    800065f2:	3666a683          	lw	a3,870(a3) # 80008954 <mem_tail>
    800065f6:	00002317          	auipc	t1,0x2
    800065fa:	35a32303          	lw	t1,858(t1) # 80008950 <mem_count>
    800065fe:	854a                	mv	a0,s2
  acquire(&mem_lock);
    80006600:	4701                	li	a4,0
  int n = 0;
    80006602:	4901                	li	s2,0
    out[n] = mem_buf[mem_tail];
    80006604:	0002be97          	auipc	t4,0x2b
    80006608:	724e8e93          	addi	t4,t4,1828 # 80031d28 <mem_buf>
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
    8000666c:	00002717          	auipc	a4,0x2
    80006670:	2ed72423          	sw	a3,744(a4) # 80008954 <mem_tail>
    80006674:	00002717          	auipc	a4,0x2
    80006678:	2cf72e23          	sw	a5,732(a4) # 80008950 <mem_count>
  }
  release(&mem_lock);
    8000667c:	0002b517          	auipc	a0,0x2b
    80006680:	69450513          	addi	a0,a0,1684 # 80031d10 <mem_lock>
    80006684:	f26fa0ef          	jal	80000daa <release>

  return n;
    80006688:	64a2                	ld	s1,8(sp)
    8000668a:	854a                	mv	a0,s2
    8000668c:	60e2                	ld	ra,24(sp)
    8000668e:	6442                	ld	s0,16(sp)
    80006690:	6902                	ld	s2,0(sp)
    80006692:	6105                	addi	sp,sp,32
    80006694:	8082                	ret
    80006696:	d37d                	beqz	a4,8000667c <memlog_read_many+0xb0>
    80006698:	00002797          	auipc	a5,0x2
    8000669c:	2ad7ae23          	sw	a3,700(a5) # 80008954 <mem_tail>
    800066a0:	00002797          	auipc	a5,0x2
    800066a4:	2a07a823          	sw	zero,688(a5) # 80008950 <mem_count>
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
    800066c8:	ed2fc0ef          	jal	80002d9a <argaddr>
  argint(1, &max);
    800066cc:	fd440593          	addi	a1,s0,-44
    800066d0:	4505                	li	a0,1
    800066d2:	eacfc0ef          	jal	80002d7e <argint>

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
    800066fc:	d2cfb0ef          	jal	80001c28 <myproc>
    80006700:	06800693          	li	a3,104
    80006704:	029686bb          	mulw	a3,a3,s1
    80006708:	95040613          	addi	a2,s0,-1712
    8000670c:	fd843583          	ld	a1,-40(s0)
    80006710:	6928                	ld	a0,80(a0)
    80006712:	a28fb0ef          	jal	8000193a <copyout>
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
    80006746:	06658593          	addi	a1,a1,102 # 800087a8 <etext+0x7a8>
    8000674a:	00038517          	auipc	a0,0x38
    8000674e:	5de50513          	addi	a0,a0,1502 # 8003ed28 <sched_rb>
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
    80006774:	ed2fa0ef          	jal	80000e46 <memmove>
  copy.seq = sched_rb.seq++;
    80006778:	00038717          	auipc	a4,0x38
    8000677c:	5b070713          	addi	a4,a4,1456 # 8003ed28 <sched_rb>
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
    800067aa:	00038517          	auipc	a0,0x38
    800067ae:	57e50513          	addi	a0,a0,1406 # 8003ed28 <sched_rb>
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
