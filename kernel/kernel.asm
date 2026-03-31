
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
    80000004:	52813103          	ld	sp,1320(sp) # 8000a528 <_GLOBAL_OFFSET_TABLE_+0x8>
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
    80000072:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffcaee7>
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
    800000ee:	49650513          	addi	a0,a0,1174 # 80012580 <conswlock>
    800000f2:	63d030ef          	jal	80003f2e <acquiresleep>

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
    80000126:	1f8020ef          	jal	8000231e <either_copyin>
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
    8000016e:	41650513          	addi	a0,a0,1046 # 80012580 <conswlock>
    80000172:	603030ef          	jal	80003f74 <releasesleep>
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
    800001aa:	40a50513          	addi	a0,a0,1034 # 800125b0 <cons>
    800001ae:	2ad000ef          	jal	80000c5a <acquire>

  while(n > 0){
    while(cons.r == cons.w){
    800001b2:	00012497          	auipc	s1,0x12
    800001b6:	3ce48493          	addi	s1,s1,974 # 80012580 <conswlock>
      if(killed(myproc())){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    800001ba:	00012997          	auipc	s3,0x12
    800001be:	3f698993          	addi	s3,s3,1014 # 800125b0 <cons>
    800001c2:	00012917          	auipc	s2,0x12
    800001c6:	48690913          	addi	s2,s2,1158 # 80012648 <cons+0x98>
  while(n > 0){
    800001ca:	0b405c63          	blez	s4,80000282 <consoleread+0xfa>
    while(cons.r == cons.w){
    800001ce:	0c84a783          	lw	a5,200(s1)
    800001d2:	0cc4a703          	lw	a4,204(s1)
    800001d6:	0af71163          	bne	a4,a5,80000278 <consoleread+0xf0>
      if(killed(myproc())){
    800001da:	78a010ef          	jal	80001964 <myproc>
    800001de:	7d9010ef          	jal	800021b6 <killed>
    800001e2:	e12d                	bnez	a0,80000244 <consoleread+0xbc>
      sleep(&cons.r, &cons.lock);
    800001e4:	85ce                	mv	a1,s3
    800001e6:	854a                	mv	a0,s2
    800001e8:	593010ef          	jal	80001f7a <sleep>
    while(cons.r == cons.w){
    800001ec:	0c84a783          	lw	a5,200(s1)
    800001f0:	0cc4a703          	lw	a4,204(s1)
    800001f4:	fef703e3          	beq	a4,a5,800001da <consoleread+0x52>
    800001f8:	f05a                	sd	s6,32(sp)
    }

    c = cons.buf[cons.r++ % INPUT_BUF_SIZE];
    800001fa:	00012717          	auipc	a4,0x12
    800001fe:	38670713          	addi	a4,a4,902 # 80012580 <conswlock>
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
    8000022c:	0a8020ef          	jal	800022d4 <either_copyout>
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
    80000248:	36c50513          	addi	a0,a0,876 # 800125b0 <cons>
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
    80000270:	3cf72e23          	sw	a5,988(a4) # 80012648 <cons+0x98>
    80000274:	7b02                	ld	s6,32(sp)
    80000276:	a031                	j	80000282 <consoleread+0xfa>
    80000278:	f05a                	sd	s6,32(sp)
    8000027a:	b741                	j	800001fa <consoleread+0x72>
    8000027c:	7b02                	ld	s6,32(sp)
    8000027e:	a011                	j	80000282 <consoleread+0xfa>
    80000280:	7b02                	ld	s6,32(sp)
  release(&cons.lock);
    80000282:	00012517          	auipc	a0,0x12
    80000286:	32e50513          	addi	a0,a0,814 # 800125b0 <cons>
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
    800002da:	2da50513          	addi	a0,a0,730 # 800125b0 <cons>
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
    800002f8:	070020ef          	jal	80002368 <procdump>
      }
    }
    break;
  }

  release(&cons.lock);
    800002fc:	00012517          	auipc	a0,0x12
    80000300:	2b450513          	addi	a0,a0,692 # 800125b0 <cons>
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
    8000031e:	26670713          	addi	a4,a4,614 # 80012580 <conswlock>
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
    80000344:	24070713          	addi	a4,a4,576 # 80012580 <conswlock>
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
    8000036e:	2de72703          	lw	a4,734(a4) # 80012648 <cons+0x98>
    80000372:	9f99                	subw	a5,a5,a4
    80000374:	08000713          	li	a4,128
    80000378:	f8e792e3          	bne	a5,a4,800002fc <consoleintr+0x32>
    8000037c:	a075                	j	80000428 <consoleintr+0x15e>
    8000037e:	e04a                	sd	s2,0(sp)
    while(cons.e != cons.w &&
    80000380:	00012717          	auipc	a4,0x12
    80000384:	20070713          	addi	a4,a4,512 # 80012580 <conswlock>
    80000388:	0d072783          	lw	a5,208(a4)
    8000038c:	0cc72703          	lw	a4,204(a4)
          cons.buf[(cons.e - 1) % INPUT_BUF_SIZE] != '\n'){
    80000390:	00012497          	auipc	s1,0x12
    80000394:	1f048493          	addi	s1,s1,496 # 80012580 <conswlock>
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
    800003d6:	1ae70713          	addi	a4,a4,430 # 80012580 <conswlock>
    800003da:	0d072783          	lw	a5,208(a4)
    800003de:	0cc72703          	lw	a4,204(a4)
    800003e2:	f0f70de3          	beq	a4,a5,800002fc <consoleintr+0x32>
      cons.e--;
    800003e6:	37fd                	addiw	a5,a5,-1
    800003e8:	00012717          	auipc	a4,0x12
    800003ec:	26f72423          	sw	a5,616(a4) # 80012650 <cons+0xa0>
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
    8000040a:	17a78793          	addi	a5,a5,378 # 80012580 <conswlock>
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
    8000042c:	22c7a223          	sw	a2,548(a5) # 8001264c <cons+0x9c>
        wakeup(&cons.r);
    80000430:	00012517          	auipc	a0,0x12
    80000434:	21850513          	addi	a0,a0,536 # 80012648 <cons+0x98>
    80000438:	38f010ef          	jal	80001fc6 <wakeup>
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
    80000446:	00007597          	auipc	a1,0x7
    8000044a:	bba58593          	addi	a1,a1,-1094 # 80007000 <etext>
    8000044e:	00012517          	auipc	a0,0x12
    80000452:	16250513          	addi	a0,a0,354 # 800125b0 <cons>
    80000456:	77a000ef          	jal	80000bd0 <initlock>
  initsleeplock(&conswlock, "consw");
    8000045a:	00007597          	auipc	a1,0x7
    8000045e:	bb658593          	addi	a1,a1,-1098 # 80007010 <etext+0x10>
    80000462:	00012517          	auipc	a0,0x12
    80000466:	11e50513          	addi	a0,a0,286 # 80012580 <conswlock>
    8000046a:	28f030ef          	jal	80003ef8 <initsleeplock>

  uartinit();
    8000046e:	448000ef          	jal	800008b6 <uartinit>

  devsw[CONSOLE].read = consoleread;
    80000472:	00022797          	auipc	a5,0x22
    80000476:	2ae78793          	addi	a5,a5,686 # 80022720 <devsw>
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
    800004b0:	00007817          	auipc	a6,0x7
    800004b4:	29880813          	addi	a6,a6,664 # 80007748 <digits>
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
    8000054e:	ffa7a783          	lw	a5,-6(a5) # 8000a544 <panicking>
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
    80000594:	0c850513          	addi	a0,a0,200 # 80012658 <pr>
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
    80000704:	00007c97          	auipc	s9,0x7
    80000708:	044c8c93          	addi	s9,s9,68 # 80007748 <digits>
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
    80000764:	00007a17          	auipc	s4,0x7
    80000768:	8b4a0a13          	addi	s4,s4,-1868 # 80007018 <etext+0x18>
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
    80000790:	db87a783          	lw	a5,-584(a5) # 8000a544 <panicking>
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
    800007ba:	ea250513          	addi	a0,a0,-350 # 80012658 <pr>
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
    80000866:	0000a797          	auipc	a5,0xa
    8000086a:	cc97af23          	sw	s1,-802(a5) # 8000a544 <panicking>
  printf("panic: ");
    8000086e:	00006517          	auipc	a0,0x6
    80000872:	7b250513          	addi	a0,a0,1970 # 80007020 <etext+0x20>
    80000876:	cb7ff0ef          	jal	8000052c <printf>
  printf("%s\n", s);
    8000087a:	85ca                	mv	a1,s2
    8000087c:	00006517          	auipc	a0,0x6
    80000880:	7ac50513          	addi	a0,a0,1964 # 80007028 <etext+0x28>
    80000884:	ca9ff0ef          	jal	8000052c <printf>
  panicked = 1; // freeze uart output from other CPUs
    80000888:	0000a797          	auipc	a5,0xa
    8000088c:	ca97ac23          	sw	s1,-840(a5) # 8000a540 <panicked>
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
    8000089a:	00006597          	auipc	a1,0x6
    8000089e:	79658593          	addi	a1,a1,1942 # 80007030 <etext+0x30>
    800008a2:	00012517          	auipc	a0,0x12
    800008a6:	db650513          	addi	a0,a0,-586 # 80012658 <pr>
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
    800008f0:	00006597          	auipc	a1,0x6
    800008f4:	74858593          	addi	a1,a1,1864 # 80007038 <etext+0x38>
    800008f8:	00012517          	auipc	a0,0x12
    800008fc:	d7850513          	addi	a0,a0,-648 # 80012670 <tx_lock>
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
    80000920:	d5450513          	addi	a0,a0,-684 # 80012670 <tx_lock>
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
    8000093a:	0000a497          	auipc	s1,0xa
    8000093e:	c1248493          	addi	s1,s1,-1006 # 8000a54c <tx_busy>
      // wait for a UART transmit-complete interrupt
      // to set tx_busy to 0.
      sleep(&tx_chan, &tx_lock);
    80000942:	00012997          	auipc	s3,0x12
    80000946:	d2e98993          	addi	s3,s3,-722 # 80012670 <tx_lock>
    8000094a:	0000a917          	auipc	s2,0xa
    8000094e:	bfe90913          	addi	s2,s2,-1026 # 8000a548 <tx_chan>
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
    8000095e:	61c010ef          	jal	80001f7a <sleep>
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
    80000988:	00012517          	auipc	a0,0x12
    8000098c:	ce850513          	addi	a0,a0,-792 # 80012670 <tx_lock>
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
    800009ac:	0000a797          	auipc	a5,0xa
    800009b0:	b987a783          	lw	a5,-1128(a5) # 8000a544 <panicking>
    800009b4:	cf95                	beqz	a5,800009f0 <uartputc_sync+0x50>
    push_off();

  if(panicked){
    800009b6:	0000a797          	auipc	a5,0xa
    800009ba:	b8a7a783          	lw	a5,-1142(a5) # 8000a540 <panicked>
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
    800009dc:	0000a797          	auipc	a5,0xa
    800009e0:	b687a783          	lw	a5,-1176(a5) # 8000a544 <panicking>
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
    80000a38:	00012517          	auipc	a0,0x12
    80000a3c:	c3850513          	addi	a0,a0,-968 # 80012670 <tx_lock>
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
    80000a52:	00012517          	auipc	a0,0x12
    80000a56:	c1e50513          	addi	a0,a0,-994 # 80012670 <tx_lock>
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
    80000a6e:	0000a797          	auipc	a5,0xa
    80000a72:	ac07af23          	sw	zero,-1314(a5) # 8000a54c <tx_busy>
    wakeup(&tx_chan);
    80000a76:	0000a517          	auipc	a0,0xa
    80000a7a:	ad250513          	addi	a0,a0,-1326 # 8000a548 <tx_chan>
    80000a7e:	548010ef          	jal	80001fc6 <wakeup>
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
    80000a9a:	00033797          	auipc	a5,0x33
    80000a9e:	e7e78793          	addi	a5,a5,-386 # 80033918 <end>
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
    80000ac4:	00012917          	auipc	s2,0x12
    80000ac8:	bc490913          	addi	s2,s2,-1084 # 80012688 <kmem>
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
    80000aee:	00006517          	auipc	a0,0x6
    80000af2:	55250513          	addi	a0,a0,1362 # 80007040 <etext+0x40>
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
    80000b4a:	00006597          	auipc	a1,0x6
    80000b4e:	4fe58593          	addi	a1,a1,1278 # 80007048 <etext+0x48>
    80000b52:	00012517          	auipc	a0,0x12
    80000b56:	b3650513          	addi	a0,a0,-1226 # 80012688 <kmem>
    80000b5a:	076000ef          	jal	80000bd0 <initlock>
  freerange(end, (void*)PHYSTOP);
    80000b5e:	45c5                	li	a1,17
    80000b60:	05ee                	slli	a1,a1,0x1b
    80000b62:	00033517          	auipc	a0,0x33
    80000b66:	db650513          	addi	a0,a0,-586 # 80033918 <end>
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
    80000b80:	00012517          	auipc	a0,0x12
    80000b84:	b0850513          	addi	a0,a0,-1272 # 80012688 <kmem>
    80000b88:	0d2000ef          	jal	80000c5a <acquire>
  r = kmem.freelist;
    80000b8c:	00012497          	auipc	s1,0x12
    80000b90:	b144b483          	ld	s1,-1260(s1) # 800126a0 <kmem+0x18>
  if(r)
    80000b94:	c49d                	beqz	s1,80000bc2 <kalloc+0x4c>
    kmem.freelist = r->next;
    80000b96:	609c                	ld	a5,0(s1)
    80000b98:	00012717          	auipc	a4,0x12
    80000b9c:	b0f73423          	sd	a5,-1272(a4) # 800126a0 <kmem+0x18>
  release(&kmem.lock);
    80000ba0:	00012517          	auipc	a0,0x12
    80000ba4:	ae850513          	addi	a0,a0,-1304 # 80012688 <kmem>
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
    80000bc2:	00012517          	auipc	a0,0x12
    80000bc6:	ac650513          	addi	a0,a0,-1338 # 80012688 <kmem>
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
    80000c00:	545000ef          	jal	80001944 <mycpu>
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
    80000c30:	515000ef          	jal	80001944 <mycpu>
    80000c34:	5d3c                	lw	a5,120(a0)
    80000c36:	cb99                	beqz	a5,80000c4c <push_off+0x36>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000c38:	50d000ef          	jal	80001944 <mycpu>
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
    80000c4c:	4f9000ef          	jal	80001944 <mycpu>
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
    80000c82:	4c3000ef          	jal	80001944 <mycpu>
    80000c86:	e888                	sd	a0,16(s1)
}
    80000c88:	60e2                	ld	ra,24(sp)
    80000c8a:	6442                	ld	s0,16(sp)
    80000c8c:	64a2                	ld	s1,8(sp)
    80000c8e:	6105                	addi	sp,sp,32
    80000c90:	8082                	ret
    panic("acquire");
    80000c92:	00006517          	auipc	a0,0x6
    80000c96:	3be50513          	addi	a0,a0,958 # 80007050 <etext+0x50>
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
    80000ca6:	49f000ef          	jal	80001944 <mycpu>
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
    80000cd6:	00006517          	auipc	a0,0x6
    80000cda:	38250513          	addi	a0,a0,898 # 80007058 <etext+0x58>
    80000cde:	b79ff0ef          	jal	80000856 <panic>
    panic("pop_off");
    80000ce2:	00006517          	auipc	a0,0x6
    80000ce6:	38e50513          	addi	a0,a0,910 # 80007070 <etext+0x70>
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
    80000d1e:	00006517          	auipc	a0,0x6
    80000d22:	35a50513          	addi	a0,a0,858 # 80007078 <etext+0x78>
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
    80000ee8:	249000ef          	jal	80001930 <cpuid>
    cslog_init();
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    80000eec:	00009717          	auipc	a4,0x9
    80000ef0:	66470713          	addi	a4,a4,1636 # 8000a550 <started>
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
    80000f00:	231000ef          	jal	80001930 <cpuid>
    80000f04:	85aa                	mv	a1,a0
    80000f06:	00006517          	auipc	a0,0x6
    80000f0a:	19a50513          	addi	a0,a0,410 # 800070a0 <etext+0xa0>
    80000f0e:	e1eff0ef          	jal	8000052c <printf>
    kvminithart();    // turn on paging
    80000f12:	084000ef          	jal	80000f96 <kvminithart>
    trapinithart();   // install kernel trap vector
    80000f16:	584010ef          	jal	8000249a <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000f1a:	60e040ef          	jal	80005528 <plicinithart>
  }

  scheduler();        
    80000f1e:	6bd000ef          	jal	80001dda <scheduler>
    consoleinit();
    80000f22:	d1cff0ef          	jal	8000043e <consoleinit>
    printfinit();
    80000f26:	96dff0ef          	jal	80000892 <printfinit>
    printf("\n");
    80000f2a:	00006517          	auipc	a0,0x6
    80000f2e:	15650513          	addi	a0,a0,342 # 80007080 <etext+0x80>
    80000f32:	dfaff0ef          	jal	8000052c <printf>
    printf("xv6 kernel is booting\n");
    80000f36:	00006517          	auipc	a0,0x6
    80000f3a:	15250513          	addi	a0,a0,338 # 80007088 <etext+0x88>
    80000f3e:	deeff0ef          	jal	8000052c <printf>
    printf("\n");
    80000f42:	00006517          	auipc	a0,0x6
    80000f46:	13e50513          	addi	a0,a0,318 # 80007080 <etext+0x80>
    80000f4a:	de2ff0ef          	jal	8000052c <printf>
    kinit();         // physical page allocator
    80000f4e:	bf5ff0ef          	jal	80000b42 <kinit>
    kvminit();       // create kernel page table
    80000f52:	2d0000ef          	jal	80001222 <kvminit>
    kvminithart();   // turn on paging
    80000f56:	040000ef          	jal	80000f96 <kvminithart>
    procinit();      // process table
    80000f5a:	121000ef          	jal	8000187a <procinit>
    trapinit();      // trap vectors
    80000f5e:	518010ef          	jal	80002476 <trapinit>
    trapinithart();  // install kernel trap vector
    80000f62:	538010ef          	jal	8000249a <trapinithart>
    plicinit();      // set up interrupt controller
    80000f66:	5a8040ef          	jal	8000550e <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000f6a:	5be040ef          	jal	80005528 <plicinithart>
    binit();         // buffer cache
    80000f6e:	3c5010ef          	jal	80002b32 <binit>
    iinit();         // inode table
    80000f72:	154020ef          	jal	800030c6 <iinit>
    fileinit();      // file table
    80000f76:	080030ef          	jal	80003ff6 <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000f7a:	69e040ef          	jal	80005618 <virtio_disk_init>
    cslog_init();
    80000f7e:	321040ef          	jal	80005a9e <cslog_init>
    userinit();      // first user process
    80000f82:	4ad000ef          	jal	80001c2e <userinit>
    __sync_synchronize();
    80000f86:	0330000f          	fence	rw,rw
    started = 1;
    80000f8a:	4785                	li	a5,1
    80000f8c:	00009717          	auipc	a4,0x9
    80000f90:	5cf72223          	sw	a5,1476(a4) # 8000a550 <started>
    80000f94:	b769                	j	80000f1e <main+0x3e>

0000000080000f96 <kvminithart>:

// Switch the current CPU's h/w page table register to
// the kernel's page table, and enable paging.
void
kvminithart()
{
    80000f96:	1141                	addi	sp,sp,-16
    80000f98:	e406                	sd	ra,8(sp)
    80000f9a:	e022                	sd	s0,0(sp)
    80000f9c:	0800                	addi	s0,sp,16
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero");
    80000f9e:	12000073          	sfence.vma
  // wait for any previous writes to the page table memory to finish.
  sfence_vma();

  w_satp(MAKE_SATP(kernel_pagetable));
    80000fa2:	00009797          	auipc	a5,0x9
    80000fa6:	5b67b783          	ld	a5,1462(a5) # 8000a558 <kernel_pagetable>
    80000faa:	83b1                	srli	a5,a5,0xc
    80000fac:	577d                	li	a4,-1
    80000fae:	177e                	slli	a4,a4,0x3f
    80000fb0:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r" (x));
    80000fb2:	18079073          	csrw	satp,a5
  asm volatile("sfence.vma zero, zero");
    80000fb6:	12000073          	sfence.vma

  // flush stale entries from the TLB.
  sfence_vma();
}
    80000fba:	60a2                	ld	ra,8(sp)
    80000fbc:	6402                	ld	s0,0(sp)
    80000fbe:	0141                	addi	sp,sp,16
    80000fc0:	8082                	ret

0000000080000fc2 <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    80000fc2:	7139                	addi	sp,sp,-64
    80000fc4:	fc06                	sd	ra,56(sp)
    80000fc6:	f822                	sd	s0,48(sp)
    80000fc8:	f426                	sd	s1,40(sp)
    80000fca:	f04a                	sd	s2,32(sp)
    80000fcc:	ec4e                	sd	s3,24(sp)
    80000fce:	e852                	sd	s4,16(sp)
    80000fd0:	e456                	sd	s5,8(sp)
    80000fd2:	e05a                	sd	s6,0(sp)
    80000fd4:	0080                	addi	s0,sp,64
    80000fd6:	84aa                	mv	s1,a0
    80000fd8:	89ae                	mv	s3,a1
    80000fda:	8b32                	mv	s6,a2
  if(va >= MAXVA)
    80000fdc:	57fd                	li	a5,-1
    80000fde:	83e9                	srli	a5,a5,0x1a
    80000fe0:	4a79                	li	s4,30
    panic("walk");

  for(int level = 2; level > 0; level--) {
    80000fe2:	4ab1                	li	s5,12
  if(va >= MAXVA)
    80000fe4:	04b7e263          	bltu	a5,a1,80001028 <walk+0x66>
    pte_t *pte = &pagetable[PX(level, va)];
    80000fe8:	0149d933          	srl	s2,s3,s4
    80000fec:	1ff97913          	andi	s2,s2,511
    80000ff0:	090e                	slli	s2,s2,0x3
    80000ff2:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) {
    80000ff4:	00093483          	ld	s1,0(s2)
    80000ff8:	0014f793          	andi	a5,s1,1
    80000ffc:	cf85                	beqz	a5,80001034 <walk+0x72>
      pagetable = (pagetable_t)PTE2PA(*pte);
    80000ffe:	80a9                	srli	s1,s1,0xa
    80001000:	04b2                	slli	s1,s1,0xc
  for(int level = 2; level > 0; level--) {
    80001002:	3a5d                	addiw	s4,s4,-9
    80001004:	ff5a12e3          	bne	s4,s5,80000fe8 <walk+0x26>
        return 0;
      memset(pagetable, 0, PGSIZE);
      *pte = PA2PTE(pagetable) | PTE_V;
    }
  }
  return &pagetable[PX(0, va)];
    80001008:	00c9d513          	srli	a0,s3,0xc
    8000100c:	1ff57513          	andi	a0,a0,511
    80001010:	050e                	slli	a0,a0,0x3
    80001012:	9526                	add	a0,a0,s1
}
    80001014:	70e2                	ld	ra,56(sp)
    80001016:	7442                	ld	s0,48(sp)
    80001018:	74a2                	ld	s1,40(sp)
    8000101a:	7902                	ld	s2,32(sp)
    8000101c:	69e2                	ld	s3,24(sp)
    8000101e:	6a42                	ld	s4,16(sp)
    80001020:	6aa2                	ld	s5,8(sp)
    80001022:	6b02                	ld	s6,0(sp)
    80001024:	6121                	addi	sp,sp,64
    80001026:	8082                	ret
    panic("walk");
    80001028:	00006517          	auipc	a0,0x6
    8000102c:	09050513          	addi	a0,a0,144 # 800070b8 <etext+0xb8>
    80001030:	827ff0ef          	jal	80000856 <panic>
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    80001034:	020b0263          	beqz	s6,80001058 <walk+0x96>
    80001038:	b3fff0ef          	jal	80000b76 <kalloc>
    8000103c:	84aa                	mv	s1,a0
    8000103e:	d979                	beqz	a0,80001014 <walk+0x52>
      memset(pagetable, 0, PGSIZE);
    80001040:	6605                	lui	a2,0x1
    80001042:	4581                	li	a1,0
    80001044:	ce7ff0ef          	jal	80000d2a <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    80001048:	00c4d793          	srli	a5,s1,0xc
    8000104c:	07aa                	slli	a5,a5,0xa
    8000104e:	0017e793          	ori	a5,a5,1
    80001052:	00f93023          	sd	a5,0(s2)
    80001056:	b775                	j	80001002 <walk+0x40>
        return 0;
    80001058:	4501                	li	a0,0
    8000105a:	bf6d                	j	80001014 <walk+0x52>

000000008000105c <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if(va >= MAXVA)
    8000105c:	57fd                	li	a5,-1
    8000105e:	83e9                	srli	a5,a5,0x1a
    80001060:	00b7f463          	bgeu	a5,a1,80001068 <walkaddr+0xc>
    return 0;
    80001064:	4501                	li	a0,0
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}
    80001066:	8082                	ret
{
    80001068:	1141                	addi	sp,sp,-16
    8000106a:	e406                	sd	ra,8(sp)
    8000106c:	e022                	sd	s0,0(sp)
    8000106e:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    80001070:	4601                	li	a2,0
    80001072:	f51ff0ef          	jal	80000fc2 <walk>
  if(pte == 0)
    80001076:	c901                	beqz	a0,80001086 <walkaddr+0x2a>
  if((*pte & PTE_V) == 0)
    80001078:	611c                	ld	a5,0(a0)
  if((*pte & PTE_U) == 0)
    8000107a:	0117f693          	andi	a3,a5,17
    8000107e:	4745                	li	a4,17
    return 0;
    80001080:	4501                	li	a0,0
  if((*pte & PTE_U) == 0)
    80001082:	00e68663          	beq	a3,a4,8000108e <walkaddr+0x32>
}
    80001086:	60a2                	ld	ra,8(sp)
    80001088:	6402                	ld	s0,0(sp)
    8000108a:	0141                	addi	sp,sp,16
    8000108c:	8082                	ret
  pa = PTE2PA(*pte);
    8000108e:	83a9                	srli	a5,a5,0xa
    80001090:	00c79513          	slli	a0,a5,0xc
  return pa;
    80001094:	bfcd                	j	80001086 <walkaddr+0x2a>

0000000080001096 <mappages>:
// va and size MUST be page-aligned.
// Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    80001096:	715d                	addi	sp,sp,-80
    80001098:	e486                	sd	ra,72(sp)
    8000109a:	e0a2                	sd	s0,64(sp)
    8000109c:	fc26                	sd	s1,56(sp)
    8000109e:	f84a                	sd	s2,48(sp)
    800010a0:	f44e                	sd	s3,40(sp)
    800010a2:	f052                	sd	s4,32(sp)
    800010a4:	ec56                	sd	s5,24(sp)
    800010a6:	e85a                	sd	s6,16(sp)
    800010a8:	e45e                	sd	s7,8(sp)
    800010aa:	0880                	addi	s0,sp,80
  uint64 a, last;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    800010ac:	03459793          	slli	a5,a1,0x34
    800010b0:	eba1                	bnez	a5,80001100 <mappages+0x6a>
    800010b2:	8a2a                	mv	s4,a0
    800010b4:	8aba                	mv	s5,a4
    panic("mappages: va not aligned");

  if((size % PGSIZE) != 0)
    800010b6:	03461793          	slli	a5,a2,0x34
    800010ba:	eba9                	bnez	a5,8000110c <mappages+0x76>
    panic("mappages: size not aligned");

  if(size == 0)
    800010bc:	ce31                	beqz	a2,80001118 <mappages+0x82>
    panic("mappages: size");
  
  a = va;
  last = va + size - PGSIZE;
    800010be:	80060613          	addi	a2,a2,-2048 # 800 <_entry-0x7ffff800>
    800010c2:	80060613          	addi	a2,a2,-2048
    800010c6:	00b60933          	add	s2,a2,a1
  a = va;
    800010ca:	84ae                	mv	s1,a1
  for(;;){
    if((pte = walk(pagetable, a, 1)) == 0)
    800010cc:	4b05                	li	s6,1
    800010ce:	40b689b3          	sub	s3,a3,a1
    if(*pte & PTE_V)
      panic("mappages: remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if(a == last)
      break;
    a += PGSIZE;
    800010d2:	6b85                	lui	s7,0x1
    if((pte = walk(pagetable, a, 1)) == 0)
    800010d4:	865a                	mv	a2,s6
    800010d6:	85a6                	mv	a1,s1
    800010d8:	8552                	mv	a0,s4
    800010da:	ee9ff0ef          	jal	80000fc2 <walk>
    800010de:	c929                	beqz	a0,80001130 <mappages+0x9a>
    if(*pte & PTE_V)
    800010e0:	611c                	ld	a5,0(a0)
    800010e2:	8b85                	andi	a5,a5,1
    800010e4:	e3a1                	bnez	a5,80001124 <mappages+0x8e>
    *pte = PA2PTE(pa) | perm | PTE_V;
    800010e6:	013487b3          	add	a5,s1,s3
    800010ea:	83b1                	srli	a5,a5,0xc
    800010ec:	07aa                	slli	a5,a5,0xa
    800010ee:	0157e7b3          	or	a5,a5,s5
    800010f2:	0017e793          	ori	a5,a5,1
    800010f6:	e11c                	sd	a5,0(a0)
    if(a == last)
    800010f8:	05248863          	beq	s1,s2,80001148 <mappages+0xb2>
    a += PGSIZE;
    800010fc:	94de                	add	s1,s1,s7
    if((pte = walk(pagetable, a, 1)) == 0)
    800010fe:	bfd9                	j	800010d4 <mappages+0x3e>
    panic("mappages: va not aligned");
    80001100:	00006517          	auipc	a0,0x6
    80001104:	fc050513          	addi	a0,a0,-64 # 800070c0 <etext+0xc0>
    80001108:	f4eff0ef          	jal	80000856 <panic>
    panic("mappages: size not aligned");
    8000110c:	00006517          	auipc	a0,0x6
    80001110:	fd450513          	addi	a0,a0,-44 # 800070e0 <etext+0xe0>
    80001114:	f42ff0ef          	jal	80000856 <panic>
    panic("mappages: size");
    80001118:	00006517          	auipc	a0,0x6
    8000111c:	fe850513          	addi	a0,a0,-24 # 80007100 <etext+0x100>
    80001120:	f36ff0ef          	jal	80000856 <panic>
      panic("mappages: remap");
    80001124:	00006517          	auipc	a0,0x6
    80001128:	fec50513          	addi	a0,a0,-20 # 80007110 <etext+0x110>
    8000112c:	f2aff0ef          	jal	80000856 <panic>
      return -1;
    80001130:	557d                	li	a0,-1
    pa += PGSIZE;
  }
  return 0;
}
    80001132:	60a6                	ld	ra,72(sp)
    80001134:	6406                	ld	s0,64(sp)
    80001136:	74e2                	ld	s1,56(sp)
    80001138:	7942                	ld	s2,48(sp)
    8000113a:	79a2                	ld	s3,40(sp)
    8000113c:	7a02                	ld	s4,32(sp)
    8000113e:	6ae2                	ld	s5,24(sp)
    80001140:	6b42                	ld	s6,16(sp)
    80001142:	6ba2                	ld	s7,8(sp)
    80001144:	6161                	addi	sp,sp,80
    80001146:	8082                	ret
  return 0;
    80001148:	4501                	li	a0,0
    8000114a:	b7e5                	j	80001132 <mappages+0x9c>

000000008000114c <kvmmap>:
{
    8000114c:	1141                	addi	sp,sp,-16
    8000114e:	e406                	sd	ra,8(sp)
    80001150:	e022                	sd	s0,0(sp)
    80001152:	0800                	addi	s0,sp,16
    80001154:	87b6                	mv	a5,a3
  if(mappages(kpgtbl, va, sz, pa, perm) != 0)
    80001156:	86b2                	mv	a3,a2
    80001158:	863e                	mv	a2,a5
    8000115a:	f3dff0ef          	jal	80001096 <mappages>
    8000115e:	e509                	bnez	a0,80001168 <kvmmap+0x1c>
}
    80001160:	60a2                	ld	ra,8(sp)
    80001162:	6402                	ld	s0,0(sp)
    80001164:	0141                	addi	sp,sp,16
    80001166:	8082                	ret
    panic("kvmmap");
    80001168:	00006517          	auipc	a0,0x6
    8000116c:	fb850513          	addi	a0,a0,-72 # 80007120 <etext+0x120>
    80001170:	ee6ff0ef          	jal	80000856 <panic>

0000000080001174 <kvmmake>:
{
    80001174:	1101                	addi	sp,sp,-32
    80001176:	ec06                	sd	ra,24(sp)
    80001178:	e822                	sd	s0,16(sp)
    8000117a:	e426                	sd	s1,8(sp)
    8000117c:	1000                	addi	s0,sp,32
  kpgtbl = (pagetable_t) kalloc();
    8000117e:	9f9ff0ef          	jal	80000b76 <kalloc>
    80001182:	84aa                	mv	s1,a0
  memset(kpgtbl, 0, PGSIZE);
    80001184:	6605                	lui	a2,0x1
    80001186:	4581                	li	a1,0
    80001188:	ba3ff0ef          	jal	80000d2a <memset>
  kvmmap(kpgtbl, UART0, UART0, PGSIZE, PTE_R | PTE_W);
    8000118c:	4719                	li	a4,6
    8000118e:	6685                	lui	a3,0x1
    80001190:	10000637          	lui	a2,0x10000
    80001194:	85b2                	mv	a1,a2
    80001196:	8526                	mv	a0,s1
    80001198:	fb5ff0ef          	jal	8000114c <kvmmap>
  kvmmap(kpgtbl, VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    8000119c:	4719                	li	a4,6
    8000119e:	6685                	lui	a3,0x1
    800011a0:	10001637          	lui	a2,0x10001
    800011a4:	85b2                	mv	a1,a2
    800011a6:	8526                	mv	a0,s1
    800011a8:	fa5ff0ef          	jal	8000114c <kvmmap>
  kvmmap(kpgtbl, PLIC, PLIC, 0x4000000, PTE_R | PTE_W);
    800011ac:	4719                	li	a4,6
    800011ae:	040006b7          	lui	a3,0x4000
    800011b2:	0c000637          	lui	a2,0xc000
    800011b6:	85b2                	mv	a1,a2
    800011b8:	8526                	mv	a0,s1
    800011ba:	f93ff0ef          	jal	8000114c <kvmmap>
  kvmmap(kpgtbl, KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    800011be:	4729                	li	a4,10
    800011c0:	80006697          	auipc	a3,0x80006
    800011c4:	e4068693          	addi	a3,a3,-448 # 7000 <_entry-0x7fff9000>
    800011c8:	4605                	li	a2,1
    800011ca:	067e                	slli	a2,a2,0x1f
    800011cc:	85b2                	mv	a1,a2
    800011ce:	8526                	mv	a0,s1
    800011d0:	f7dff0ef          	jal	8000114c <kvmmap>
  kvmmap(kpgtbl, (uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    800011d4:	4719                	li	a4,6
    800011d6:	00006697          	auipc	a3,0x6
    800011da:	e2a68693          	addi	a3,a3,-470 # 80007000 <etext>
    800011de:	47c5                	li	a5,17
    800011e0:	07ee                	slli	a5,a5,0x1b
    800011e2:	40d786b3          	sub	a3,a5,a3
    800011e6:	00006617          	auipc	a2,0x6
    800011ea:	e1a60613          	addi	a2,a2,-486 # 80007000 <etext>
    800011ee:	85b2                	mv	a1,a2
    800011f0:	8526                	mv	a0,s1
    800011f2:	f5bff0ef          	jal	8000114c <kvmmap>
  kvmmap(kpgtbl, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    800011f6:	4729                	li	a4,10
    800011f8:	6685                	lui	a3,0x1
    800011fa:	00005617          	auipc	a2,0x5
    800011fe:	e0660613          	addi	a2,a2,-506 # 80006000 <_trampoline>
    80001202:	040005b7          	lui	a1,0x4000
    80001206:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001208:	05b2                	slli	a1,a1,0xc
    8000120a:	8526                	mv	a0,s1
    8000120c:	f41ff0ef          	jal	8000114c <kvmmap>
  proc_mapstacks(kpgtbl);
    80001210:	8526                	mv	a0,s1
    80001212:	5c4000ef          	jal	800017d6 <proc_mapstacks>
}
    80001216:	8526                	mv	a0,s1
    80001218:	60e2                	ld	ra,24(sp)
    8000121a:	6442                	ld	s0,16(sp)
    8000121c:	64a2                	ld	s1,8(sp)
    8000121e:	6105                	addi	sp,sp,32
    80001220:	8082                	ret

0000000080001222 <kvminit>:
{
    80001222:	1141                	addi	sp,sp,-16
    80001224:	e406                	sd	ra,8(sp)
    80001226:	e022                	sd	s0,0(sp)
    80001228:	0800                	addi	s0,sp,16
  kernel_pagetable = kvmmake();
    8000122a:	f4bff0ef          	jal	80001174 <kvmmake>
    8000122e:	00009797          	auipc	a5,0x9
    80001232:	32a7b523          	sd	a0,810(a5) # 8000a558 <kernel_pagetable>
}
    80001236:	60a2                	ld	ra,8(sp)
    80001238:	6402                	ld	s0,0(sp)
    8000123a:	0141                	addi	sp,sp,16
    8000123c:	8082                	ret

000000008000123e <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    8000123e:	1101                	addi	sp,sp,-32
    80001240:	ec06                	sd	ra,24(sp)
    80001242:	e822                	sd	s0,16(sp)
    80001244:	e426                	sd	s1,8(sp)
    80001246:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t) kalloc();
    80001248:	92fff0ef          	jal	80000b76 <kalloc>
    8000124c:	84aa                	mv	s1,a0
  if(pagetable == 0)
    8000124e:	c509                	beqz	a0,80001258 <uvmcreate+0x1a>
    return 0;
  memset(pagetable, 0, PGSIZE);
    80001250:	6605                	lui	a2,0x1
    80001252:	4581                	li	a1,0
    80001254:	ad7ff0ef          	jal	80000d2a <memset>
  return pagetable;
}
    80001258:	8526                	mv	a0,s1
    8000125a:	60e2                	ld	ra,24(sp)
    8000125c:	6442                	ld	s0,16(sp)
    8000125e:	64a2                	ld	s1,8(sp)
    80001260:	6105                	addi	sp,sp,32
    80001262:	8082                	ret

0000000080001264 <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. It's OK if the mappings don't exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    80001264:	7139                	addi	sp,sp,-64
    80001266:	fc06                	sd	ra,56(sp)
    80001268:	f822                	sd	s0,48(sp)
    8000126a:	0080                	addi	s0,sp,64
  uint64 a;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    8000126c:	03459793          	slli	a5,a1,0x34
    80001270:	e38d                	bnez	a5,80001292 <uvmunmap+0x2e>
    80001272:	f04a                	sd	s2,32(sp)
    80001274:	ec4e                	sd	s3,24(sp)
    80001276:	e852                	sd	s4,16(sp)
    80001278:	e456                	sd	s5,8(sp)
    8000127a:	e05a                	sd	s6,0(sp)
    8000127c:	8a2a                	mv	s4,a0
    8000127e:	892e                	mv	s2,a1
    80001280:	8ab6                	mv	s5,a3
    panic("uvmunmap: not aligned");

  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80001282:	0632                	slli	a2,a2,0xc
    80001284:	00b609b3          	add	s3,a2,a1
    80001288:	6b05                	lui	s6,0x1
    8000128a:	0535f963          	bgeu	a1,s3,800012dc <uvmunmap+0x78>
    8000128e:	f426                	sd	s1,40(sp)
    80001290:	a015                	j	800012b4 <uvmunmap+0x50>
    80001292:	f426                	sd	s1,40(sp)
    80001294:	f04a                	sd	s2,32(sp)
    80001296:	ec4e                	sd	s3,24(sp)
    80001298:	e852                	sd	s4,16(sp)
    8000129a:	e456                	sd	s5,8(sp)
    8000129c:	e05a                	sd	s6,0(sp)
    panic("uvmunmap: not aligned");
    8000129e:	00006517          	auipc	a0,0x6
    800012a2:	e8a50513          	addi	a0,a0,-374 # 80007128 <etext+0x128>
    800012a6:	db0ff0ef          	jal	80000856 <panic>
      continue;
    if(do_free){
      uint64 pa = PTE2PA(*pte);
      kfree((void*)pa);
    }
    *pte = 0;
    800012aa:	0004b023          	sd	zero,0(s1)
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800012ae:	995a                	add	s2,s2,s6
    800012b0:	03397563          	bgeu	s2,s3,800012da <uvmunmap+0x76>
    if((pte = walk(pagetable, a, 0)) == 0) // leaf page table entry allocated?
    800012b4:	4601                	li	a2,0
    800012b6:	85ca                	mv	a1,s2
    800012b8:	8552                	mv	a0,s4
    800012ba:	d09ff0ef          	jal	80000fc2 <walk>
    800012be:	84aa                	mv	s1,a0
    800012c0:	d57d                	beqz	a0,800012ae <uvmunmap+0x4a>
    if((*pte & PTE_V) == 0)  // has physical page been allocated?
    800012c2:	611c                	ld	a5,0(a0)
    800012c4:	0017f713          	andi	a4,a5,1
    800012c8:	d37d                	beqz	a4,800012ae <uvmunmap+0x4a>
    if(do_free){
    800012ca:	fe0a80e3          	beqz	s5,800012aa <uvmunmap+0x46>
      uint64 pa = PTE2PA(*pte);
    800012ce:	83a9                	srli	a5,a5,0xa
      kfree((void*)pa);
    800012d0:	00c79513          	slli	a0,a5,0xc
    800012d4:	fbaff0ef          	jal	80000a8e <kfree>
    800012d8:	bfc9                	j	800012aa <uvmunmap+0x46>
    800012da:	74a2                	ld	s1,40(sp)
    800012dc:	7902                	ld	s2,32(sp)
    800012de:	69e2                	ld	s3,24(sp)
    800012e0:	6a42                	ld	s4,16(sp)
    800012e2:	6aa2                	ld	s5,8(sp)
    800012e4:	6b02                	ld	s6,0(sp)
  }
}
    800012e6:	70e2                	ld	ra,56(sp)
    800012e8:	7442                	ld	s0,48(sp)
    800012ea:	6121                	addi	sp,sp,64
    800012ec:	8082                	ret

00000000800012ee <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    800012ee:	1101                	addi	sp,sp,-32
    800012f0:	ec06                	sd	ra,24(sp)
    800012f2:	e822                	sd	s0,16(sp)
    800012f4:	e426                	sd	s1,8(sp)
    800012f6:	1000                	addi	s0,sp,32
  if(newsz >= oldsz)
    return oldsz;
    800012f8:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    800012fa:	00b67d63          	bgeu	a2,a1,80001314 <uvmdealloc+0x26>
    800012fe:	84b2                	mv	s1,a2

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    80001300:	6785                	lui	a5,0x1
    80001302:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80001304:	00f60733          	add	a4,a2,a5
    80001308:	76fd                	lui	a3,0xfffff
    8000130a:	8f75                	and	a4,a4,a3
    8000130c:	97ae                	add	a5,a5,a1
    8000130e:	8ff5                	and	a5,a5,a3
    80001310:	00f76863          	bltu	a4,a5,80001320 <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    80001314:	8526                	mv	a0,s1
    80001316:	60e2                	ld	ra,24(sp)
    80001318:	6442                	ld	s0,16(sp)
    8000131a:	64a2                	ld	s1,8(sp)
    8000131c:	6105                	addi	sp,sp,32
    8000131e:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    80001320:	8f99                	sub	a5,a5,a4
    80001322:	83b1                	srli	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    80001324:	4685                	li	a3,1
    80001326:	0007861b          	sext.w	a2,a5
    8000132a:	85ba                	mv	a1,a4
    8000132c:	f39ff0ef          	jal	80001264 <uvmunmap>
    80001330:	b7d5                	j	80001314 <uvmdealloc+0x26>

0000000080001332 <uvmalloc>:
  if(newsz < oldsz)
    80001332:	0ab66163          	bltu	a2,a1,800013d4 <uvmalloc+0xa2>
{
    80001336:	715d                	addi	sp,sp,-80
    80001338:	e486                	sd	ra,72(sp)
    8000133a:	e0a2                	sd	s0,64(sp)
    8000133c:	f84a                	sd	s2,48(sp)
    8000133e:	f052                	sd	s4,32(sp)
    80001340:	ec56                	sd	s5,24(sp)
    80001342:	e45e                	sd	s7,8(sp)
    80001344:	0880                	addi	s0,sp,80
    80001346:	8aaa                	mv	s5,a0
    80001348:	8a32                	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    8000134a:	6785                	lui	a5,0x1
    8000134c:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    8000134e:	95be                	add	a1,a1,a5
    80001350:	77fd                	lui	a5,0xfffff
    80001352:	00f5f933          	and	s2,a1,a5
    80001356:	8bca                	mv	s7,s2
  for(a = oldsz; a < newsz; a += PGSIZE){
    80001358:	08c97063          	bgeu	s2,a2,800013d8 <uvmalloc+0xa6>
    8000135c:	fc26                	sd	s1,56(sp)
    8000135e:	f44e                	sd	s3,40(sp)
    80001360:	e85a                	sd	s6,16(sp)
    memset(mem, 0, PGSIZE);
    80001362:	6985                	lui	s3,0x1
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    80001364:	0126eb13          	ori	s6,a3,18
    mem = kalloc();
    80001368:	80fff0ef          	jal	80000b76 <kalloc>
    8000136c:	84aa                	mv	s1,a0
    if(mem == 0){
    8000136e:	c50d                	beqz	a0,80001398 <uvmalloc+0x66>
    memset(mem, 0, PGSIZE);
    80001370:	864e                	mv	a2,s3
    80001372:	4581                	li	a1,0
    80001374:	9b7ff0ef          	jal	80000d2a <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    80001378:	875a                	mv	a4,s6
    8000137a:	86a6                	mv	a3,s1
    8000137c:	864e                	mv	a2,s3
    8000137e:	85ca                	mv	a1,s2
    80001380:	8556                	mv	a0,s5
    80001382:	d15ff0ef          	jal	80001096 <mappages>
    80001386:	e915                	bnez	a0,800013ba <uvmalloc+0x88>
  for(a = oldsz; a < newsz; a += PGSIZE){
    80001388:	994e                	add	s2,s2,s3
    8000138a:	fd496fe3          	bltu	s2,s4,80001368 <uvmalloc+0x36>
  return newsz;
    8000138e:	8552                	mv	a0,s4
    80001390:	74e2                	ld	s1,56(sp)
    80001392:	79a2                	ld	s3,40(sp)
    80001394:	6b42                	ld	s6,16(sp)
    80001396:	a811                	j	800013aa <uvmalloc+0x78>
      uvmdealloc(pagetable, a, oldsz);
    80001398:	865e                	mv	a2,s7
    8000139a:	85ca                	mv	a1,s2
    8000139c:	8556                	mv	a0,s5
    8000139e:	f51ff0ef          	jal	800012ee <uvmdealloc>
      return 0;
    800013a2:	4501                	li	a0,0
    800013a4:	74e2                	ld	s1,56(sp)
    800013a6:	79a2                	ld	s3,40(sp)
    800013a8:	6b42                	ld	s6,16(sp)
}
    800013aa:	60a6                	ld	ra,72(sp)
    800013ac:	6406                	ld	s0,64(sp)
    800013ae:	7942                	ld	s2,48(sp)
    800013b0:	7a02                	ld	s4,32(sp)
    800013b2:	6ae2                	ld	s5,24(sp)
    800013b4:	6ba2                	ld	s7,8(sp)
    800013b6:	6161                	addi	sp,sp,80
    800013b8:	8082                	ret
      kfree(mem);
    800013ba:	8526                	mv	a0,s1
    800013bc:	ed2ff0ef          	jal	80000a8e <kfree>
      uvmdealloc(pagetable, a, oldsz);
    800013c0:	865e                	mv	a2,s7
    800013c2:	85ca                	mv	a1,s2
    800013c4:	8556                	mv	a0,s5
    800013c6:	f29ff0ef          	jal	800012ee <uvmdealloc>
      return 0;
    800013ca:	4501                	li	a0,0
    800013cc:	74e2                	ld	s1,56(sp)
    800013ce:	79a2                	ld	s3,40(sp)
    800013d0:	6b42                	ld	s6,16(sp)
    800013d2:	bfe1                	j	800013aa <uvmalloc+0x78>
    return oldsz;
    800013d4:	852e                	mv	a0,a1
}
    800013d6:	8082                	ret
  return newsz;
    800013d8:	8532                	mv	a0,a2
    800013da:	bfc1                	j	800013aa <uvmalloc+0x78>

00000000800013dc <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    800013dc:	7179                	addi	sp,sp,-48
    800013de:	f406                	sd	ra,40(sp)
    800013e0:	f022                	sd	s0,32(sp)
    800013e2:	ec26                	sd	s1,24(sp)
    800013e4:	e84a                	sd	s2,16(sp)
    800013e6:	e44e                	sd	s3,8(sp)
    800013e8:	1800                	addi	s0,sp,48
    800013ea:	89aa                	mv	s3,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    800013ec:	84aa                	mv	s1,a0
    800013ee:	6905                	lui	s2,0x1
    800013f0:	992a                	add	s2,s2,a0
    800013f2:	a811                	j	80001406 <freewalk+0x2a>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
      freewalk((pagetable_t)child);
      pagetable[i] = 0;
    } else if(pte & PTE_V){
      panic("freewalk: leaf");
    800013f4:	00006517          	auipc	a0,0x6
    800013f8:	d4c50513          	addi	a0,a0,-692 # 80007140 <etext+0x140>
    800013fc:	c5aff0ef          	jal	80000856 <panic>
  for(int i = 0; i < 512; i++){
    80001400:	04a1                	addi	s1,s1,8
    80001402:	03248163          	beq	s1,s2,80001424 <freewalk+0x48>
    pte_t pte = pagetable[i];
    80001406:	609c                	ld	a5,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    80001408:	0017f713          	andi	a4,a5,1
    8000140c:	db75                	beqz	a4,80001400 <freewalk+0x24>
    8000140e:	00e7f713          	andi	a4,a5,14
    80001412:	f36d                	bnez	a4,800013f4 <freewalk+0x18>
      uint64 child = PTE2PA(pte);
    80001414:	83a9                	srli	a5,a5,0xa
      freewalk((pagetable_t)child);
    80001416:	00c79513          	slli	a0,a5,0xc
    8000141a:	fc3ff0ef          	jal	800013dc <freewalk>
      pagetable[i] = 0;
    8000141e:	0004b023          	sd	zero,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    80001422:	bff9                	j	80001400 <freewalk+0x24>
    }
  }
  kfree((void*)pagetable);
    80001424:	854e                	mv	a0,s3
    80001426:	e68ff0ef          	jal	80000a8e <kfree>
}
    8000142a:	70a2                	ld	ra,40(sp)
    8000142c:	7402                	ld	s0,32(sp)
    8000142e:	64e2                	ld	s1,24(sp)
    80001430:	6942                	ld	s2,16(sp)
    80001432:	69a2                	ld	s3,8(sp)
    80001434:	6145                	addi	sp,sp,48
    80001436:	8082                	ret

0000000080001438 <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    80001438:	1101                	addi	sp,sp,-32
    8000143a:	ec06                	sd	ra,24(sp)
    8000143c:	e822                	sd	s0,16(sp)
    8000143e:	e426                	sd	s1,8(sp)
    80001440:	1000                	addi	s0,sp,32
    80001442:	84aa                	mv	s1,a0
  if(sz > 0)
    80001444:	e989                	bnez	a1,80001456 <uvmfree+0x1e>
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
  freewalk(pagetable);
    80001446:	8526                	mv	a0,s1
    80001448:	f95ff0ef          	jal	800013dc <freewalk>
}
    8000144c:	60e2                	ld	ra,24(sp)
    8000144e:	6442                	ld	s0,16(sp)
    80001450:	64a2                	ld	s1,8(sp)
    80001452:	6105                	addi	sp,sp,32
    80001454:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
    80001456:	6785                	lui	a5,0x1
    80001458:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    8000145a:	95be                	add	a1,a1,a5
    8000145c:	4685                	li	a3,1
    8000145e:	00c5d613          	srli	a2,a1,0xc
    80001462:	4581                	li	a1,0
    80001464:	e01ff0ef          	jal	80001264 <uvmunmap>
    80001468:	bff9                	j	80001446 <uvmfree+0xe>

000000008000146a <uvmcopy>:
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for(i = 0; i < sz; i += PGSIZE){
    8000146a:	ca59                	beqz	a2,80001500 <uvmcopy+0x96>
{
    8000146c:	715d                	addi	sp,sp,-80
    8000146e:	e486                	sd	ra,72(sp)
    80001470:	e0a2                	sd	s0,64(sp)
    80001472:	fc26                	sd	s1,56(sp)
    80001474:	f84a                	sd	s2,48(sp)
    80001476:	f44e                	sd	s3,40(sp)
    80001478:	f052                	sd	s4,32(sp)
    8000147a:	ec56                	sd	s5,24(sp)
    8000147c:	e85a                	sd	s6,16(sp)
    8000147e:	e45e                	sd	s7,8(sp)
    80001480:	0880                	addi	s0,sp,80
    80001482:	8b2a                	mv	s6,a0
    80001484:	8bae                	mv	s7,a1
    80001486:	8ab2                	mv	s5,a2
  for(i = 0; i < sz; i += PGSIZE){
    80001488:	4481                	li	s1,0
      continue;   // physical page hasn't been allocated
    pa = PTE2PA(*pte);
    flags = PTE_FLAGS(*pte);
    if((mem = kalloc()) == 0)
      goto err;
    memmove(mem, (char*)pa, PGSIZE);
    8000148a:	6a05                	lui	s4,0x1
    8000148c:	a021                	j	80001494 <uvmcopy+0x2a>
  for(i = 0; i < sz; i += PGSIZE){
    8000148e:	94d2                	add	s1,s1,s4
    80001490:	0554fc63          	bgeu	s1,s5,800014e8 <uvmcopy+0x7e>
    if((pte = walk(old, i, 0)) == 0)
    80001494:	4601                	li	a2,0
    80001496:	85a6                	mv	a1,s1
    80001498:	855a                	mv	a0,s6
    8000149a:	b29ff0ef          	jal	80000fc2 <walk>
    8000149e:	d965                	beqz	a0,8000148e <uvmcopy+0x24>
    if((*pte & PTE_V) == 0)
    800014a0:	00053983          	ld	s3,0(a0)
    800014a4:	0019f793          	andi	a5,s3,1
    800014a8:	d3fd                	beqz	a5,8000148e <uvmcopy+0x24>
    if((mem = kalloc()) == 0)
    800014aa:	eccff0ef          	jal	80000b76 <kalloc>
    800014ae:	892a                	mv	s2,a0
    800014b0:	c11d                	beqz	a0,800014d6 <uvmcopy+0x6c>
    pa = PTE2PA(*pte);
    800014b2:	00a9d593          	srli	a1,s3,0xa
    memmove(mem, (char*)pa, PGSIZE);
    800014b6:	8652                	mv	a2,s4
    800014b8:	05b2                	slli	a1,a1,0xc
    800014ba:	8d1ff0ef          	jal	80000d8a <memmove>
    if(mappages(new, i, PGSIZE, (uint64)mem, flags) != 0){
    800014be:	3ff9f713          	andi	a4,s3,1023
    800014c2:	86ca                	mv	a3,s2
    800014c4:	8652                	mv	a2,s4
    800014c6:	85a6                	mv	a1,s1
    800014c8:	855e                	mv	a0,s7
    800014ca:	bcdff0ef          	jal	80001096 <mappages>
    800014ce:	d161                	beqz	a0,8000148e <uvmcopy+0x24>
      kfree(mem);
    800014d0:	854a                	mv	a0,s2
    800014d2:	dbcff0ef          	jal	80000a8e <kfree>
    }
  }
  return 0;

 err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    800014d6:	4685                	li	a3,1
    800014d8:	00c4d613          	srli	a2,s1,0xc
    800014dc:	4581                	li	a1,0
    800014de:	855e                	mv	a0,s7
    800014e0:	d85ff0ef          	jal	80001264 <uvmunmap>
  return -1;
    800014e4:	557d                	li	a0,-1
    800014e6:	a011                	j	800014ea <uvmcopy+0x80>
  return 0;
    800014e8:	4501                	li	a0,0
}
    800014ea:	60a6                	ld	ra,72(sp)
    800014ec:	6406                	ld	s0,64(sp)
    800014ee:	74e2                	ld	s1,56(sp)
    800014f0:	7942                	ld	s2,48(sp)
    800014f2:	79a2                	ld	s3,40(sp)
    800014f4:	7a02                	ld	s4,32(sp)
    800014f6:	6ae2                	ld	s5,24(sp)
    800014f8:	6b42                	ld	s6,16(sp)
    800014fa:	6ba2                	ld	s7,8(sp)
    800014fc:	6161                	addi	sp,sp,80
    800014fe:	8082                	ret
  return 0;
    80001500:	4501                	li	a0,0
}
    80001502:	8082                	ret

0000000080001504 <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    80001504:	1141                	addi	sp,sp,-16
    80001506:	e406                	sd	ra,8(sp)
    80001508:	e022                	sd	s0,0(sp)
    8000150a:	0800                	addi	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    8000150c:	4601                	li	a2,0
    8000150e:	ab5ff0ef          	jal	80000fc2 <walk>
  if(pte == 0)
    80001512:	c901                	beqz	a0,80001522 <uvmclear+0x1e>
    panic("uvmclear");
  *pte &= ~PTE_U;
    80001514:	611c                	ld	a5,0(a0)
    80001516:	9bbd                	andi	a5,a5,-17
    80001518:	e11c                	sd	a5,0(a0)
}
    8000151a:	60a2                	ld	ra,8(sp)
    8000151c:	6402                	ld	s0,0(sp)
    8000151e:	0141                	addi	sp,sp,16
    80001520:	8082                	ret
    panic("uvmclear");
    80001522:	00006517          	auipc	a0,0x6
    80001526:	c2e50513          	addi	a0,a0,-978 # 80007150 <etext+0x150>
    8000152a:	b2cff0ef          	jal	80000856 <panic>

000000008000152e <copyinstr>:
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    8000152e:	cac5                	beqz	a3,800015de <copyinstr+0xb0>
{
    80001530:	715d                	addi	sp,sp,-80
    80001532:	e486                	sd	ra,72(sp)
    80001534:	e0a2                	sd	s0,64(sp)
    80001536:	fc26                	sd	s1,56(sp)
    80001538:	f84a                	sd	s2,48(sp)
    8000153a:	f44e                	sd	s3,40(sp)
    8000153c:	f052                	sd	s4,32(sp)
    8000153e:	ec56                	sd	s5,24(sp)
    80001540:	e85a                	sd	s6,16(sp)
    80001542:	e45e                	sd	s7,8(sp)
    80001544:	0880                	addi	s0,sp,80
    80001546:	8aaa                	mv	s5,a0
    80001548:	84ae                	mv	s1,a1
    8000154a:	8bb2                	mv	s7,a2
    8000154c:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(srcva);
    8000154e:	7b7d                	lui	s6,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    80001550:	6a05                	lui	s4,0x1
    80001552:	a82d                	j	8000158c <copyinstr+0x5e>
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
    80001554:	00078023          	sb	zero,0(a5)
        got_null = 1;
    80001558:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    8000155a:	0017c793          	xori	a5,a5,1
    8000155e:	40f0053b          	negw	a0,a5
    return 0;
  } else {
    return -1;
  }
}
    80001562:	60a6                	ld	ra,72(sp)
    80001564:	6406                	ld	s0,64(sp)
    80001566:	74e2                	ld	s1,56(sp)
    80001568:	7942                	ld	s2,48(sp)
    8000156a:	79a2                	ld	s3,40(sp)
    8000156c:	7a02                	ld	s4,32(sp)
    8000156e:	6ae2                	ld	s5,24(sp)
    80001570:	6b42                	ld	s6,16(sp)
    80001572:	6ba2                	ld	s7,8(sp)
    80001574:	6161                	addi	sp,sp,80
    80001576:	8082                	ret
    80001578:	fff98713          	addi	a4,s3,-1 # fff <_entry-0x7ffff001>
    8000157c:	9726                	add	a4,a4,s1
      --max;
    8000157e:	40b709b3          	sub	s3,a4,a1
    srcva = va0 + PGSIZE;
    80001582:	01490bb3          	add	s7,s2,s4
  while(got_null == 0 && max > 0){
    80001586:	04e58463          	beq	a1,a4,800015ce <copyinstr+0xa0>
{
    8000158a:	84be                	mv	s1,a5
    va0 = PGROUNDDOWN(srcva);
    8000158c:	016bf933          	and	s2,s7,s6
    pa0 = walkaddr(pagetable, va0);
    80001590:	85ca                	mv	a1,s2
    80001592:	8556                	mv	a0,s5
    80001594:	ac9ff0ef          	jal	8000105c <walkaddr>
    if(pa0 == 0)
    80001598:	cd0d                	beqz	a0,800015d2 <copyinstr+0xa4>
    n = PGSIZE - (srcva - va0);
    8000159a:	417906b3          	sub	a3,s2,s7
    8000159e:	96d2                	add	a3,a3,s4
    if(n > max)
    800015a0:	00d9f363          	bgeu	s3,a3,800015a6 <copyinstr+0x78>
    800015a4:	86ce                	mv	a3,s3
    while(n > 0){
    800015a6:	ca85                	beqz	a3,800015d6 <copyinstr+0xa8>
    char *p = (char *) (pa0 + (srcva - va0));
    800015a8:	01750633          	add	a2,a0,s7
    800015ac:	41260633          	sub	a2,a2,s2
    800015b0:	87a6                	mv	a5,s1
      if(*p == '\0'){
    800015b2:	8e05                	sub	a2,a2,s1
    while(n > 0){
    800015b4:	96a6                	add	a3,a3,s1
    800015b6:	85be                	mv	a1,a5
      if(*p == '\0'){
    800015b8:	00f60733          	add	a4,a2,a5
    800015bc:	00074703          	lbu	a4,0(a4)
    800015c0:	db51                	beqz	a4,80001554 <copyinstr+0x26>
        *dst = *p;
    800015c2:	00e78023          	sb	a4,0(a5)
      dst++;
    800015c6:	0785                	addi	a5,a5,1
    while(n > 0){
    800015c8:	fed797e3          	bne	a5,a3,800015b6 <copyinstr+0x88>
    800015cc:	b775                	j	80001578 <copyinstr+0x4a>
    800015ce:	4781                	li	a5,0
    800015d0:	b769                	j	8000155a <copyinstr+0x2c>
      return -1;
    800015d2:	557d                	li	a0,-1
    800015d4:	b779                	j	80001562 <copyinstr+0x34>
    srcva = va0 + PGSIZE;
    800015d6:	6b85                	lui	s7,0x1
    800015d8:	9bca                	add	s7,s7,s2
    800015da:	87a6                	mv	a5,s1
    800015dc:	b77d                	j	8000158a <copyinstr+0x5c>
  int got_null = 0;
    800015de:	4781                	li	a5,0
  if(got_null){
    800015e0:	0017c793          	xori	a5,a5,1
    800015e4:	40f0053b          	negw	a0,a5
}
    800015e8:	8082                	ret

00000000800015ea <ismapped>:
  return mem;
}

int
ismapped(pagetable_t pagetable, uint64 va)
{
    800015ea:	1141                	addi	sp,sp,-16
    800015ec:	e406                	sd	ra,8(sp)
    800015ee:	e022                	sd	s0,0(sp)
    800015f0:	0800                	addi	s0,sp,16
  pte_t *pte = walk(pagetable, va, 0);
    800015f2:	4601                	li	a2,0
    800015f4:	9cfff0ef          	jal	80000fc2 <walk>
  if (pte == 0) {
    800015f8:	c119                	beqz	a0,800015fe <ismapped+0x14>
    return 0;
  }
  if (*pte & PTE_V){
    800015fa:	6108                	ld	a0,0(a0)
    800015fc:	8905                	andi	a0,a0,1
    return 1;
  }
  return 0;
}
    800015fe:	60a2                	ld	ra,8(sp)
    80001600:	6402                	ld	s0,0(sp)
    80001602:	0141                	addi	sp,sp,16
    80001604:	8082                	ret

0000000080001606 <vmfault>:
{
    80001606:	7179                	addi	sp,sp,-48
    80001608:	f406                	sd	ra,40(sp)
    8000160a:	f022                	sd	s0,32(sp)
    8000160c:	e84a                	sd	s2,16(sp)
    8000160e:	e44e                	sd	s3,8(sp)
    80001610:	1800                	addi	s0,sp,48
    80001612:	89aa                	mv	s3,a0
    80001614:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80001616:	34e000ef          	jal	80001964 <myproc>
  if (va >= p->sz)
    8000161a:	653c                	ld	a5,72(a0)
    8000161c:	00f96a63          	bltu	s2,a5,80001630 <vmfault+0x2a>
    return 0;
    80001620:	4981                	li	s3,0
}
    80001622:	854e                	mv	a0,s3
    80001624:	70a2                	ld	ra,40(sp)
    80001626:	7402                	ld	s0,32(sp)
    80001628:	6942                	ld	s2,16(sp)
    8000162a:	69a2                	ld	s3,8(sp)
    8000162c:	6145                	addi	sp,sp,48
    8000162e:	8082                	ret
    80001630:	ec26                	sd	s1,24(sp)
    80001632:	e052                	sd	s4,0(sp)
    80001634:	84aa                	mv	s1,a0
  va = PGROUNDDOWN(va);
    80001636:	77fd                	lui	a5,0xfffff
    80001638:	00f97a33          	and	s4,s2,a5
  if(ismapped(pagetable, va)) {
    8000163c:	85d2                	mv	a1,s4
    8000163e:	854e                	mv	a0,s3
    80001640:	fabff0ef          	jal	800015ea <ismapped>
    return 0;
    80001644:	4981                	li	s3,0
  if(ismapped(pagetable, va)) {
    80001646:	c501                	beqz	a0,8000164e <vmfault+0x48>
    80001648:	64e2                	ld	s1,24(sp)
    8000164a:	6a02                	ld	s4,0(sp)
    8000164c:	bfd9                	j	80001622 <vmfault+0x1c>
  mem = (uint64) kalloc();
    8000164e:	d28ff0ef          	jal	80000b76 <kalloc>
    80001652:	892a                	mv	s2,a0
  if(mem == 0)
    80001654:	c905                	beqz	a0,80001684 <vmfault+0x7e>
  mem = (uint64) kalloc();
    80001656:	89aa                	mv	s3,a0
  memset((void *) mem, 0, PGSIZE);
    80001658:	6605                	lui	a2,0x1
    8000165a:	4581                	li	a1,0
    8000165c:	eceff0ef          	jal	80000d2a <memset>
  if (mappages(p->pagetable, va, PGSIZE, mem, PTE_W|PTE_U|PTE_R) != 0) {
    80001660:	4759                	li	a4,22
    80001662:	86ca                	mv	a3,s2
    80001664:	6605                	lui	a2,0x1
    80001666:	85d2                	mv	a1,s4
    80001668:	68a8                	ld	a0,80(s1)
    8000166a:	a2dff0ef          	jal	80001096 <mappages>
    8000166e:	e501                	bnez	a0,80001676 <vmfault+0x70>
    80001670:	64e2                	ld	s1,24(sp)
    80001672:	6a02                	ld	s4,0(sp)
    80001674:	b77d                	j	80001622 <vmfault+0x1c>
    kfree((void *)mem);
    80001676:	854a                	mv	a0,s2
    80001678:	c16ff0ef          	jal	80000a8e <kfree>
    return 0;
    8000167c:	4981                	li	s3,0
    8000167e:	64e2                	ld	s1,24(sp)
    80001680:	6a02                	ld	s4,0(sp)
    80001682:	b745                	j	80001622 <vmfault+0x1c>
    80001684:	64e2                	ld	s1,24(sp)
    80001686:	6a02                	ld	s4,0(sp)
    80001688:	bf69                	j	80001622 <vmfault+0x1c>

000000008000168a <copyout>:
  while(len > 0){
    8000168a:	cad1                	beqz	a3,8000171e <copyout+0x94>
{
    8000168c:	711d                	addi	sp,sp,-96
    8000168e:	ec86                	sd	ra,88(sp)
    80001690:	e8a2                	sd	s0,80(sp)
    80001692:	e4a6                	sd	s1,72(sp)
    80001694:	e0ca                	sd	s2,64(sp)
    80001696:	fc4e                	sd	s3,56(sp)
    80001698:	f852                	sd	s4,48(sp)
    8000169a:	f456                	sd	s5,40(sp)
    8000169c:	f05a                	sd	s6,32(sp)
    8000169e:	ec5e                	sd	s7,24(sp)
    800016a0:	e862                	sd	s8,16(sp)
    800016a2:	e466                	sd	s9,8(sp)
    800016a4:	e06a                	sd	s10,0(sp)
    800016a6:	1080                	addi	s0,sp,96
    800016a8:	8baa                	mv	s7,a0
    800016aa:	8a2e                	mv	s4,a1
    800016ac:	8b32                	mv	s6,a2
    800016ae:	8ab6                	mv	s5,a3
    va0 = PGROUNDDOWN(dstva);
    800016b0:	7d7d                	lui	s10,0xfffff
    if(va0 >= MAXVA)
    800016b2:	5cfd                	li	s9,-1
    800016b4:	01acdc93          	srli	s9,s9,0x1a
    n = PGSIZE - (dstva - va0);
    800016b8:	6c05                	lui	s8,0x1
    800016ba:	a005                	j	800016da <copyout+0x50>
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    800016bc:	409a0533          	sub	a0,s4,s1
    800016c0:	0009061b          	sext.w	a2,s2
    800016c4:	85da                	mv	a1,s6
    800016c6:	954e                	add	a0,a0,s3
    800016c8:	ec2ff0ef          	jal	80000d8a <memmove>
    len -= n;
    800016cc:	412a8ab3          	sub	s5,s5,s2
    src += n;
    800016d0:	9b4a                	add	s6,s6,s2
    dstva = va0 + PGSIZE;
    800016d2:	01848a33          	add	s4,s1,s8
  while(len > 0){
    800016d6:	040a8263          	beqz	s5,8000171a <copyout+0x90>
    va0 = PGROUNDDOWN(dstva);
    800016da:	01aa74b3          	and	s1,s4,s10
    if(va0 >= MAXVA)
    800016de:	049ce263          	bltu	s9,s1,80001722 <copyout+0x98>
    pa0 = walkaddr(pagetable, va0);
    800016e2:	85a6                	mv	a1,s1
    800016e4:	855e                	mv	a0,s7
    800016e6:	977ff0ef          	jal	8000105c <walkaddr>
    800016ea:	89aa                	mv	s3,a0
    if(pa0 == 0) {
    800016ec:	e901                	bnez	a0,800016fc <copyout+0x72>
      if((pa0 = vmfault(pagetable, va0, 0)) == 0) {
    800016ee:	4601                	li	a2,0
    800016f0:	85a6                	mv	a1,s1
    800016f2:	855e                	mv	a0,s7
    800016f4:	f13ff0ef          	jal	80001606 <vmfault>
    800016f8:	89aa                	mv	s3,a0
    800016fa:	c139                	beqz	a0,80001740 <copyout+0xb6>
    pte = walk(pagetable, va0, 0);
    800016fc:	4601                	li	a2,0
    800016fe:	85a6                	mv	a1,s1
    80001700:	855e                	mv	a0,s7
    80001702:	8c1ff0ef          	jal	80000fc2 <walk>
    if((*pte & PTE_W) == 0)
    80001706:	611c                	ld	a5,0(a0)
    80001708:	8b91                	andi	a5,a5,4
    8000170a:	cf8d                	beqz	a5,80001744 <copyout+0xba>
    n = PGSIZE - (dstva - va0);
    8000170c:	41448933          	sub	s2,s1,s4
    80001710:	9962                	add	s2,s2,s8
    if(n > len)
    80001712:	fb2af5e3          	bgeu	s5,s2,800016bc <copyout+0x32>
    80001716:	8956                	mv	s2,s5
    80001718:	b755                	j	800016bc <copyout+0x32>
  return 0;
    8000171a:	4501                	li	a0,0
    8000171c:	a021                	j	80001724 <copyout+0x9a>
    8000171e:	4501                	li	a0,0
}
    80001720:	8082                	ret
      return -1;
    80001722:	557d                	li	a0,-1
}
    80001724:	60e6                	ld	ra,88(sp)
    80001726:	6446                	ld	s0,80(sp)
    80001728:	64a6                	ld	s1,72(sp)
    8000172a:	6906                	ld	s2,64(sp)
    8000172c:	79e2                	ld	s3,56(sp)
    8000172e:	7a42                	ld	s4,48(sp)
    80001730:	7aa2                	ld	s5,40(sp)
    80001732:	7b02                	ld	s6,32(sp)
    80001734:	6be2                	ld	s7,24(sp)
    80001736:	6c42                	ld	s8,16(sp)
    80001738:	6ca2                	ld	s9,8(sp)
    8000173a:	6d02                	ld	s10,0(sp)
    8000173c:	6125                	addi	sp,sp,96
    8000173e:	8082                	ret
        return -1;
    80001740:	557d                	li	a0,-1
    80001742:	b7cd                	j	80001724 <copyout+0x9a>
      return -1;
    80001744:	557d                	li	a0,-1
    80001746:	bff9                	j	80001724 <copyout+0x9a>

0000000080001748 <copyin>:
  while(len > 0){
    80001748:	c6c9                	beqz	a3,800017d2 <copyin+0x8a>
{
    8000174a:	715d                	addi	sp,sp,-80
    8000174c:	e486                	sd	ra,72(sp)
    8000174e:	e0a2                	sd	s0,64(sp)
    80001750:	fc26                	sd	s1,56(sp)
    80001752:	f84a                	sd	s2,48(sp)
    80001754:	f44e                	sd	s3,40(sp)
    80001756:	f052                	sd	s4,32(sp)
    80001758:	ec56                	sd	s5,24(sp)
    8000175a:	e85a                	sd	s6,16(sp)
    8000175c:	e45e                	sd	s7,8(sp)
    8000175e:	e062                	sd	s8,0(sp)
    80001760:	0880                	addi	s0,sp,80
    80001762:	8baa                	mv	s7,a0
    80001764:	8aae                	mv	s5,a1
    80001766:	8932                	mv	s2,a2
    80001768:	8a36                	mv	s4,a3
    va0 = PGROUNDDOWN(srcva);
    8000176a:	7c7d                	lui	s8,0xfffff
    n = PGSIZE - (srcva - va0);
    8000176c:	6b05                	lui	s6,0x1
    8000176e:	a035                	j	8000179a <copyin+0x52>
    80001770:	412984b3          	sub	s1,s3,s2
    80001774:	94da                	add	s1,s1,s6
    if(n > len)
    80001776:	009a7363          	bgeu	s4,s1,8000177c <copyin+0x34>
    8000177a:	84d2                	mv	s1,s4
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    8000177c:	413905b3          	sub	a1,s2,s3
    80001780:	0004861b          	sext.w	a2,s1
    80001784:	95aa                	add	a1,a1,a0
    80001786:	8556                	mv	a0,s5
    80001788:	e02ff0ef          	jal	80000d8a <memmove>
    len -= n;
    8000178c:	409a0a33          	sub	s4,s4,s1
    dst += n;
    80001790:	9aa6                	add	s5,s5,s1
    srcva = va0 + PGSIZE;
    80001792:	01698933          	add	s2,s3,s6
  while(len > 0){
    80001796:	020a0163          	beqz	s4,800017b8 <copyin+0x70>
    va0 = PGROUNDDOWN(srcva);
    8000179a:	018979b3          	and	s3,s2,s8
    pa0 = walkaddr(pagetable, va0);
    8000179e:	85ce                	mv	a1,s3
    800017a0:	855e                	mv	a0,s7
    800017a2:	8bbff0ef          	jal	8000105c <walkaddr>
    if(pa0 == 0) {
    800017a6:	f569                	bnez	a0,80001770 <copyin+0x28>
      if((pa0 = vmfault(pagetable, va0, 0)) == 0) {
    800017a8:	4601                	li	a2,0
    800017aa:	85ce                	mv	a1,s3
    800017ac:	855e                	mv	a0,s7
    800017ae:	e59ff0ef          	jal	80001606 <vmfault>
    800017b2:	fd5d                	bnez	a0,80001770 <copyin+0x28>
        return -1;
    800017b4:	557d                	li	a0,-1
    800017b6:	a011                	j	800017ba <copyin+0x72>
  return 0;
    800017b8:	4501                	li	a0,0
}
    800017ba:	60a6                	ld	ra,72(sp)
    800017bc:	6406                	ld	s0,64(sp)
    800017be:	74e2                	ld	s1,56(sp)
    800017c0:	7942                	ld	s2,48(sp)
    800017c2:	79a2                	ld	s3,40(sp)
    800017c4:	7a02                	ld	s4,32(sp)
    800017c6:	6ae2                	ld	s5,24(sp)
    800017c8:	6b42                	ld	s6,16(sp)
    800017ca:	6ba2                	ld	s7,8(sp)
    800017cc:	6c02                	ld	s8,0(sp)
    800017ce:	6161                	addi	sp,sp,80
    800017d0:	8082                	ret
  return 0;
    800017d2:	4501                	li	a0,0
}
    800017d4:	8082                	ret

00000000800017d6 <proc_mapstacks>:
struct spinlock wait_lock;

// Allocate a page for each process's kernel stack.
// Map it high in memory, followed by an invalid
// guard page.
void proc_mapstacks(pagetable_t kpgtbl) {
    800017d6:	715d                	addi	sp,sp,-80
    800017d8:	e486                	sd	ra,72(sp)
    800017da:	e0a2                	sd	s0,64(sp)
    800017dc:	fc26                	sd	s1,56(sp)
    800017de:	f84a                	sd	s2,48(sp)
    800017e0:	f44e                	sd	s3,40(sp)
    800017e2:	f052                	sd	s4,32(sp)
    800017e4:	ec56                	sd	s5,24(sp)
    800017e6:	e85a                	sd	s6,16(sp)
    800017e8:	e45e                	sd	s7,8(sp)
    800017ea:	e062                	sd	s8,0(sp)
    800017ec:	0880                	addi	s0,sp,80
    800017ee:	8a2a                	mv	s4,a0
  struct proc *p;

  for (p = proc; p < &proc[NPROC]; p++) {
    800017f0:	00011497          	auipc	s1,0x11
    800017f4:	2e848493          	addi	s1,s1,744 # 80012ad8 <proc>
    char *pa = kalloc();
    if (pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int)(p - proc));
    800017f8:	8c26                	mv	s8,s1
    800017fa:	000a57b7          	lui	a5,0xa5
    800017fe:	fa578793          	addi	a5,a5,-91 # a4fa5 <_entry-0x7ff5b05b>
    80001802:	07b2                	slli	a5,a5,0xc
    80001804:	fa578793          	addi	a5,a5,-91
    80001808:	4fa50937          	lui	s2,0x4fa50
    8000180c:	a4f90913          	addi	s2,s2,-1457 # 4fa4fa4f <_entry-0x305b05b1>
    80001810:	1902                	slli	s2,s2,0x20
    80001812:	993e                	add	s2,s2,a5
    80001814:	040009b7          	lui	s3,0x4000
    80001818:	19fd                	addi	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    8000181a:	09b2                	slli	s3,s3,0xc
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    8000181c:	4b99                	li	s7,6
    8000181e:	6b05                	lui	s6,0x1
  for (p = proc; p < &proc[NPROC]; p++) {
    80001820:	00017a97          	auipc	s5,0x17
    80001824:	cb8a8a93          	addi	s5,s5,-840 # 800184d8 <tickslock>
    char *pa = kalloc();
    80001828:	b4eff0ef          	jal	80000b76 <kalloc>
    8000182c:	862a                	mv	a2,a0
    if (pa == 0)
    8000182e:	c121                	beqz	a0,8000186e <proc_mapstacks+0x98>
    uint64 va = KSTACK((int)(p - proc));
    80001830:	418485b3          	sub	a1,s1,s8
    80001834:	858d                	srai	a1,a1,0x3
    80001836:	032585b3          	mul	a1,a1,s2
    8000183a:	05b6                	slli	a1,a1,0xd
    8000183c:	6789                	lui	a5,0x2
    8000183e:	9dbd                	addw	a1,a1,a5
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    80001840:	875e                	mv	a4,s7
    80001842:	86da                	mv	a3,s6
    80001844:	40b985b3          	sub	a1,s3,a1
    80001848:	8552                	mv	a0,s4
    8000184a:	903ff0ef          	jal	8000114c <kvmmap>
  for (p = proc; p < &proc[NPROC]; p++) {
    8000184e:	16848493          	addi	s1,s1,360
    80001852:	fd549be3          	bne	s1,s5,80001828 <proc_mapstacks+0x52>
  }
}
    80001856:	60a6                	ld	ra,72(sp)
    80001858:	6406                	ld	s0,64(sp)
    8000185a:	74e2                	ld	s1,56(sp)
    8000185c:	7942                	ld	s2,48(sp)
    8000185e:	79a2                	ld	s3,40(sp)
    80001860:	7a02                	ld	s4,32(sp)
    80001862:	6ae2                	ld	s5,24(sp)
    80001864:	6b42                	ld	s6,16(sp)
    80001866:	6ba2                	ld	s7,8(sp)
    80001868:	6c02                	ld	s8,0(sp)
    8000186a:	6161                	addi	sp,sp,80
    8000186c:	8082                	ret
      panic("kalloc");
    8000186e:	00006517          	auipc	a0,0x6
    80001872:	8f250513          	addi	a0,a0,-1806 # 80007160 <etext+0x160>
    80001876:	fe1fe0ef          	jal	80000856 <panic>

000000008000187a <procinit>:

// initialize the proc table.
void procinit(void) {
    8000187a:	7139                	addi	sp,sp,-64
    8000187c:	fc06                	sd	ra,56(sp)
    8000187e:	f822                	sd	s0,48(sp)
    80001880:	f426                	sd	s1,40(sp)
    80001882:	f04a                	sd	s2,32(sp)
    80001884:	ec4e                	sd	s3,24(sp)
    80001886:	e852                	sd	s4,16(sp)
    80001888:	e456                	sd	s5,8(sp)
    8000188a:	e05a                	sd	s6,0(sp)
    8000188c:	0080                	addi	s0,sp,64
  struct proc *p;

  initlock(&pid_lock, "nextpid");
    8000188e:	00006597          	auipc	a1,0x6
    80001892:	8da58593          	addi	a1,a1,-1830 # 80007168 <etext+0x168>
    80001896:	00011517          	auipc	a0,0x11
    8000189a:	e1250513          	addi	a0,a0,-494 # 800126a8 <pid_lock>
    8000189e:	b32ff0ef          	jal	80000bd0 <initlock>
  initlock(&wait_lock, "wait_lock");
    800018a2:	00006597          	auipc	a1,0x6
    800018a6:	8ce58593          	addi	a1,a1,-1842 # 80007170 <etext+0x170>
    800018aa:	00011517          	auipc	a0,0x11
    800018ae:	e1650513          	addi	a0,a0,-490 # 800126c0 <wait_lock>
    800018b2:	b1eff0ef          	jal	80000bd0 <initlock>
  for (p = proc; p < &proc[NPROC]; p++) {
    800018b6:	00011497          	auipc	s1,0x11
    800018ba:	22248493          	addi	s1,s1,546 # 80012ad8 <proc>
    initlock(&p->lock, "proc");
    800018be:	00006b17          	auipc	s6,0x6
    800018c2:	8c2b0b13          	addi	s6,s6,-1854 # 80007180 <etext+0x180>
    p->state = UNUSED;
    p->kstack = KSTACK((int)(p - proc));
    800018c6:	8aa6                	mv	s5,s1
    800018c8:	000a57b7          	lui	a5,0xa5
    800018cc:	fa578793          	addi	a5,a5,-91 # a4fa5 <_entry-0x7ff5b05b>
    800018d0:	07b2                	slli	a5,a5,0xc
    800018d2:	fa578793          	addi	a5,a5,-91
    800018d6:	4fa50937          	lui	s2,0x4fa50
    800018da:	a4f90913          	addi	s2,s2,-1457 # 4fa4fa4f <_entry-0x305b05b1>
    800018de:	1902                	slli	s2,s2,0x20
    800018e0:	993e                	add	s2,s2,a5
    800018e2:	040009b7          	lui	s3,0x4000
    800018e6:	19fd                	addi	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    800018e8:	09b2                	slli	s3,s3,0xc
  for (p = proc; p < &proc[NPROC]; p++) {
    800018ea:	00017a17          	auipc	s4,0x17
    800018ee:	beea0a13          	addi	s4,s4,-1042 # 800184d8 <tickslock>
    initlock(&p->lock, "proc");
    800018f2:	85da                	mv	a1,s6
    800018f4:	8526                	mv	a0,s1
    800018f6:	adaff0ef          	jal	80000bd0 <initlock>
    p->state = UNUSED;
    800018fa:	0004ac23          	sw	zero,24(s1)
    p->kstack = KSTACK((int)(p - proc));
    800018fe:	415487b3          	sub	a5,s1,s5
    80001902:	878d                	srai	a5,a5,0x3
    80001904:	032787b3          	mul	a5,a5,s2
    80001908:	07b6                	slli	a5,a5,0xd
    8000190a:	6709                	lui	a4,0x2
    8000190c:	9fb9                	addw	a5,a5,a4
    8000190e:	40f987b3          	sub	a5,s3,a5
    80001912:	e0bc                	sd	a5,64(s1)
  for (p = proc; p < &proc[NPROC]; p++) {
    80001914:	16848493          	addi	s1,s1,360
    80001918:	fd449de3          	bne	s1,s4,800018f2 <procinit+0x78>
  }
}
    8000191c:	70e2                	ld	ra,56(sp)
    8000191e:	7442                	ld	s0,48(sp)
    80001920:	74a2                	ld	s1,40(sp)
    80001922:	7902                	ld	s2,32(sp)
    80001924:	69e2                	ld	s3,24(sp)
    80001926:	6a42                	ld	s4,16(sp)
    80001928:	6aa2                	ld	s5,8(sp)
    8000192a:	6b02                	ld	s6,0(sp)
    8000192c:	6121                	addi	sp,sp,64
    8000192e:	8082                	ret

0000000080001930 <cpuid>:

// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int cpuid() {
    80001930:	1141                	addi	sp,sp,-16
    80001932:	e406                	sd	ra,8(sp)
    80001934:	e022                	sd	s0,0(sp)
    80001936:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    80001938:	8512                	mv	a0,tp
  int id = r_tp();
  return id;
}
    8000193a:	2501                	sext.w	a0,a0
    8000193c:	60a2                	ld	ra,8(sp)
    8000193e:	6402                	ld	s0,0(sp)
    80001940:	0141                	addi	sp,sp,16
    80001942:	8082                	ret

0000000080001944 <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu *mycpu(void) {
    80001944:	1141                	addi	sp,sp,-16
    80001946:	e406                	sd	ra,8(sp)
    80001948:	e022                	sd	s0,0(sp)
    8000194a:	0800                	addi	s0,sp,16
    8000194c:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    8000194e:	2781                	sext.w	a5,a5
    80001950:	079e                	slli	a5,a5,0x7
  return c;
}
    80001952:	00011517          	auipc	a0,0x11
    80001956:	d8650513          	addi	a0,a0,-634 # 800126d8 <cpus>
    8000195a:	953e                	add	a0,a0,a5
    8000195c:	60a2                	ld	ra,8(sp)
    8000195e:	6402                	ld	s0,0(sp)
    80001960:	0141                	addi	sp,sp,16
    80001962:	8082                	ret

0000000080001964 <myproc>:

// Return the current struct proc *, or zero if none.
struct proc *myproc(void) {
    80001964:	1101                	addi	sp,sp,-32
    80001966:	ec06                	sd	ra,24(sp)
    80001968:	e822                	sd	s0,16(sp)
    8000196a:	e426                	sd	s1,8(sp)
    8000196c:	1000                	addi	s0,sp,32
  push_off();
    8000196e:	aa8ff0ef          	jal	80000c16 <push_off>
    80001972:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    80001974:	2781                	sext.w	a5,a5
    80001976:	079e                	slli	a5,a5,0x7
    80001978:	00011717          	auipc	a4,0x11
    8000197c:	d3070713          	addi	a4,a4,-720 # 800126a8 <pid_lock>
    80001980:	97ba                	add	a5,a5,a4
    80001982:	7b9c                	ld	a5,48(a5)
    80001984:	84be                	mv	s1,a5
  pop_off();
    80001986:	b18ff0ef          	jal	80000c9e <pop_off>
  return p;
}
    8000198a:	8526                	mv	a0,s1
    8000198c:	60e2                	ld	ra,24(sp)
    8000198e:	6442                	ld	s0,16(sp)
    80001990:	64a2                	ld	s1,8(sp)
    80001992:	6105                	addi	sp,sp,32
    80001994:	8082                	ret

0000000080001996 <forkret>:
  release(&p->lock);
}

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void forkret(void) {
    80001996:	7179                	addi	sp,sp,-48
    80001998:	f406                	sd	ra,40(sp)
    8000199a:	f022                	sd	s0,32(sp)
    8000199c:	ec26                	sd	s1,24(sp)
    8000199e:	1800                	addi	s0,sp,48
  extern char userret[];
  static int first = 1;
  struct proc *p = myproc();
    800019a0:	fc5ff0ef          	jal	80001964 <myproc>
    800019a4:	84aa                	mv	s1,a0

  // Still holding p->lock from scheduler.
  release(&p->lock);
    800019a6:	b48ff0ef          	jal	80000cee <release>

  if (first) {
    800019aa:	00009797          	auipc	a5,0x9
    800019ae:	b667a783          	lw	a5,-1178(a5) # 8000a510 <first.1>
    800019b2:	cf95                	beqz	a5,800019ee <forkret+0x58>
    // File system initialization must be run in the context of a
    // regular process (e.g., because it calls sleep), and thus cannot
    // be run from main().
    fsinit(ROOTDEV);
    800019b4:	4505                	li	a0,1
    800019b6:	3cd010ef          	jal	80003582 <fsinit>

    first = 0;
    800019ba:	00009797          	auipc	a5,0x9
    800019be:	b407ab23          	sw	zero,-1194(a5) # 8000a510 <first.1>
    // ensure other cores see first=0.
    __sync_synchronize();
    800019c2:	0330000f          	fence	rw,rw

    // We can invoke kexec() now that file system is initialized.
    // Put the return value (argc) of kexec into a0.
    p->trapframe->a0 = kexec("/init", (char *[]){"/init", 0});
    800019c6:	00005797          	auipc	a5,0x5
    800019ca:	7c278793          	addi	a5,a5,1986 # 80007188 <etext+0x188>
    800019ce:	fcf43823          	sd	a5,-48(s0)
    800019d2:	fc043c23          	sd	zero,-40(s0)
    800019d6:	fd040593          	addi	a1,s0,-48
    800019da:	853e                	mv	a0,a5
    800019dc:	52f020ef          	jal	8000470a <kexec>
    800019e0:	6cbc                	ld	a5,88(s1)
    800019e2:	fba8                	sd	a0,112(a5)
    if (p->trapframe->a0 == -1) {
    800019e4:	6cbc                	ld	a5,88(s1)
    800019e6:	7bb8                	ld	a4,112(a5)
    800019e8:	57fd                	li	a5,-1
    800019ea:	02f70d63          	beq	a4,a5,80001a24 <forkret+0x8e>
      panic("exec");
    }
  }

  // return to user space, mimicing usertrap()'s return.
  prepare_return();
    800019ee:	2c9000ef          	jal	800024b6 <prepare_return>
  uint64 satp = MAKE_SATP(p->pagetable);
    800019f2:	68a8                	ld	a0,80(s1)
    800019f4:	8131                	srli	a0,a0,0xc
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    800019f6:	04000737          	lui	a4,0x4000
    800019fa:	177d                	addi	a4,a4,-1 # 3ffffff <_entry-0x7c000001>
    800019fc:	0732                	slli	a4,a4,0xc
    800019fe:	00004797          	auipc	a5,0x4
    80001a02:	69e78793          	addi	a5,a5,1694 # 8000609c <userret>
    80001a06:	00004697          	auipc	a3,0x4
    80001a0a:	5fa68693          	addi	a3,a3,1530 # 80006000 <_trampoline>
    80001a0e:	8f95                	sub	a5,a5,a3
    80001a10:	97ba                	add	a5,a5,a4
  ((void (*)(uint64))trampoline_userret)(satp);
    80001a12:	577d                	li	a4,-1
    80001a14:	177e                	slli	a4,a4,0x3f
    80001a16:	8d59                	or	a0,a0,a4
    80001a18:	9782                	jalr	a5
}
    80001a1a:	70a2                	ld	ra,40(sp)
    80001a1c:	7402                	ld	s0,32(sp)
    80001a1e:	64e2                	ld	s1,24(sp)
    80001a20:	6145                	addi	sp,sp,48
    80001a22:	8082                	ret
      panic("exec");
    80001a24:	00005517          	auipc	a0,0x5
    80001a28:	76c50513          	addi	a0,a0,1900 # 80007190 <etext+0x190>
    80001a2c:	e2bfe0ef          	jal	80000856 <panic>

0000000080001a30 <allocpid>:
int allocpid() {
    80001a30:	1101                	addi	sp,sp,-32
    80001a32:	ec06                	sd	ra,24(sp)
    80001a34:	e822                	sd	s0,16(sp)
    80001a36:	e426                	sd	s1,8(sp)
    80001a38:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80001a3a:	00011517          	auipc	a0,0x11
    80001a3e:	c6e50513          	addi	a0,a0,-914 # 800126a8 <pid_lock>
    80001a42:	a18ff0ef          	jal	80000c5a <acquire>
  pid = nextpid;
    80001a46:	00009797          	auipc	a5,0x9
    80001a4a:	ace78793          	addi	a5,a5,-1330 # 8000a514 <nextpid>
    80001a4e:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80001a50:	0014871b          	addiw	a4,s1,1
    80001a54:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001a56:	00011517          	auipc	a0,0x11
    80001a5a:	c5250513          	addi	a0,a0,-942 # 800126a8 <pid_lock>
    80001a5e:	a90ff0ef          	jal	80000cee <release>
}
    80001a62:	8526                	mv	a0,s1
    80001a64:	60e2                	ld	ra,24(sp)
    80001a66:	6442                	ld	s0,16(sp)
    80001a68:	64a2                	ld	s1,8(sp)
    80001a6a:	6105                	addi	sp,sp,32
    80001a6c:	8082                	ret

0000000080001a6e <proc_pagetable>:
pagetable_t proc_pagetable(struct proc *p) {
    80001a6e:	1101                	addi	sp,sp,-32
    80001a70:	ec06                	sd	ra,24(sp)
    80001a72:	e822                	sd	s0,16(sp)
    80001a74:	e426                	sd	s1,8(sp)
    80001a76:	e04a                	sd	s2,0(sp)
    80001a78:	1000                	addi	s0,sp,32
    80001a7a:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001a7c:	fc2ff0ef          	jal	8000123e <uvmcreate>
    80001a80:	84aa                	mv	s1,a0
  if (pagetable == 0)
    80001a82:	cd05                	beqz	a0,80001aba <proc_pagetable+0x4c>
  if (mappages(pagetable, TRAMPOLINE, PGSIZE, (uint64)trampoline,
    80001a84:	4729                	li	a4,10
    80001a86:	00004697          	auipc	a3,0x4
    80001a8a:	57a68693          	addi	a3,a3,1402 # 80006000 <_trampoline>
    80001a8e:	6605                	lui	a2,0x1
    80001a90:	040005b7          	lui	a1,0x4000
    80001a94:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001a96:	05b2                	slli	a1,a1,0xc
    80001a98:	dfeff0ef          	jal	80001096 <mappages>
    80001a9c:	02054663          	bltz	a0,80001ac8 <proc_pagetable+0x5a>
  if (mappages(pagetable, TRAPFRAME, PGSIZE, (uint64)(p->trapframe),
    80001aa0:	4719                	li	a4,6
    80001aa2:	05893683          	ld	a3,88(s2)
    80001aa6:	6605                	lui	a2,0x1
    80001aa8:	020005b7          	lui	a1,0x2000
    80001aac:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001aae:	05b6                	slli	a1,a1,0xd
    80001ab0:	8526                	mv	a0,s1
    80001ab2:	de4ff0ef          	jal	80001096 <mappages>
    80001ab6:	00054f63          	bltz	a0,80001ad4 <proc_pagetable+0x66>
}
    80001aba:	8526                	mv	a0,s1
    80001abc:	60e2                	ld	ra,24(sp)
    80001abe:	6442                	ld	s0,16(sp)
    80001ac0:	64a2                	ld	s1,8(sp)
    80001ac2:	6902                	ld	s2,0(sp)
    80001ac4:	6105                	addi	sp,sp,32
    80001ac6:	8082                	ret
    uvmfree(pagetable, 0);
    80001ac8:	4581                	li	a1,0
    80001aca:	8526                	mv	a0,s1
    80001acc:	96dff0ef          	jal	80001438 <uvmfree>
    return 0;
    80001ad0:	4481                	li	s1,0
    80001ad2:	b7e5                	j	80001aba <proc_pagetable+0x4c>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001ad4:	4681                	li	a3,0
    80001ad6:	4605                	li	a2,1
    80001ad8:	040005b7          	lui	a1,0x4000
    80001adc:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001ade:	05b2                	slli	a1,a1,0xc
    80001ae0:	8526                	mv	a0,s1
    80001ae2:	f82ff0ef          	jal	80001264 <uvmunmap>
    uvmfree(pagetable, 0);
    80001ae6:	4581                	li	a1,0
    80001ae8:	8526                	mv	a0,s1
    80001aea:	94fff0ef          	jal	80001438 <uvmfree>
    return 0;
    80001aee:	4481                	li	s1,0
    80001af0:	b7e9                	j	80001aba <proc_pagetable+0x4c>

0000000080001af2 <proc_freepagetable>:
void proc_freepagetable(pagetable_t pagetable, uint64 sz) {
    80001af2:	1101                	addi	sp,sp,-32
    80001af4:	ec06                	sd	ra,24(sp)
    80001af6:	e822                	sd	s0,16(sp)
    80001af8:	e426                	sd	s1,8(sp)
    80001afa:	e04a                	sd	s2,0(sp)
    80001afc:	1000                	addi	s0,sp,32
    80001afe:	84aa                	mv	s1,a0
    80001b00:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001b02:	4681                	li	a3,0
    80001b04:	4605                	li	a2,1
    80001b06:	040005b7          	lui	a1,0x4000
    80001b0a:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001b0c:	05b2                	slli	a1,a1,0xc
    80001b0e:	f56ff0ef          	jal	80001264 <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001b12:	4681                	li	a3,0
    80001b14:	4605                	li	a2,1
    80001b16:	020005b7          	lui	a1,0x2000
    80001b1a:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001b1c:	05b6                	slli	a1,a1,0xd
    80001b1e:	8526                	mv	a0,s1
    80001b20:	f44ff0ef          	jal	80001264 <uvmunmap>
  uvmfree(pagetable, sz);
    80001b24:	85ca                	mv	a1,s2
    80001b26:	8526                	mv	a0,s1
    80001b28:	911ff0ef          	jal	80001438 <uvmfree>
}
    80001b2c:	60e2                	ld	ra,24(sp)
    80001b2e:	6442                	ld	s0,16(sp)
    80001b30:	64a2                	ld	s1,8(sp)
    80001b32:	6902                	ld	s2,0(sp)
    80001b34:	6105                	addi	sp,sp,32
    80001b36:	8082                	ret

0000000080001b38 <freeproc>:
static void freeproc(struct proc *p) {
    80001b38:	1101                	addi	sp,sp,-32
    80001b3a:	ec06                	sd	ra,24(sp)
    80001b3c:	e822                	sd	s0,16(sp)
    80001b3e:	e426                	sd	s1,8(sp)
    80001b40:	1000                	addi	s0,sp,32
    80001b42:	84aa                	mv	s1,a0
  if (p->trapframe)
    80001b44:	6d28                	ld	a0,88(a0)
    80001b46:	c119                	beqz	a0,80001b4c <freeproc+0x14>
    kfree((void *)p->trapframe);
    80001b48:	f47fe0ef          	jal	80000a8e <kfree>
  p->trapframe = 0;
    80001b4c:	0404bc23          	sd	zero,88(s1)
  if (p->pagetable)
    80001b50:	68a8                	ld	a0,80(s1)
    80001b52:	c501                	beqz	a0,80001b5a <freeproc+0x22>
    proc_freepagetable(p->pagetable, p->sz);
    80001b54:	64ac                	ld	a1,72(s1)
    80001b56:	f9dff0ef          	jal	80001af2 <proc_freepagetable>
  p->pagetable = 0;
    80001b5a:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    80001b5e:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    80001b62:	0204a823          	sw	zero,48(s1)
  p->parent = 0;
    80001b66:	0204bc23          	sd	zero,56(s1)
  p->name[0] = 0;
    80001b6a:	14048c23          	sb	zero,344(s1)
  p->chan = 0;
    80001b6e:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    80001b72:	0204a423          	sw	zero,40(s1)
  p->xstate = 0;
    80001b76:	0204a623          	sw	zero,44(s1)
  p->state = UNUSED;
    80001b7a:	0004ac23          	sw	zero,24(s1)
}
    80001b7e:	60e2                	ld	ra,24(sp)
    80001b80:	6442                	ld	s0,16(sp)
    80001b82:	64a2                	ld	s1,8(sp)
    80001b84:	6105                	addi	sp,sp,32
    80001b86:	8082                	ret

0000000080001b88 <allocproc>:
static struct proc *allocproc(void) {
    80001b88:	1101                	addi	sp,sp,-32
    80001b8a:	ec06                	sd	ra,24(sp)
    80001b8c:	e822                	sd	s0,16(sp)
    80001b8e:	e426                	sd	s1,8(sp)
    80001b90:	e04a                	sd	s2,0(sp)
    80001b92:	1000                	addi	s0,sp,32
  for (p = proc; p < &proc[NPROC]; p++) {
    80001b94:	00011497          	auipc	s1,0x11
    80001b98:	f4448493          	addi	s1,s1,-188 # 80012ad8 <proc>
    80001b9c:	00017917          	auipc	s2,0x17
    80001ba0:	93c90913          	addi	s2,s2,-1732 # 800184d8 <tickslock>
    acquire(&p->lock);
    80001ba4:	8526                	mv	a0,s1
    80001ba6:	8b4ff0ef          	jal	80000c5a <acquire>
    if (p->state == UNUSED) {
    80001baa:	4c9c                	lw	a5,24(s1)
    80001bac:	cb91                	beqz	a5,80001bc0 <allocproc+0x38>
      release(&p->lock);
    80001bae:	8526                	mv	a0,s1
    80001bb0:	93eff0ef          	jal	80000cee <release>
  for (p = proc; p < &proc[NPROC]; p++) {
    80001bb4:	16848493          	addi	s1,s1,360
    80001bb8:	ff2496e3          	bne	s1,s2,80001ba4 <allocproc+0x1c>
  return 0;
    80001bbc:	4481                	li	s1,0
    80001bbe:	a089                	j	80001c00 <allocproc+0x78>
  p->pid = allocpid();
    80001bc0:	e71ff0ef          	jal	80001a30 <allocpid>
    80001bc4:	d888                	sw	a0,48(s1)
  p->state = USED;
    80001bc6:	4785                	li	a5,1
    80001bc8:	cc9c                	sw	a5,24(s1)
  if ((p->trapframe = (struct trapframe *)kalloc()) == 0) {
    80001bca:	fadfe0ef          	jal	80000b76 <kalloc>
    80001bce:	892a                	mv	s2,a0
    80001bd0:	eca8                	sd	a0,88(s1)
    80001bd2:	cd15                	beqz	a0,80001c0e <allocproc+0x86>
  p->pagetable = proc_pagetable(p);
    80001bd4:	8526                	mv	a0,s1
    80001bd6:	e99ff0ef          	jal	80001a6e <proc_pagetable>
    80001bda:	892a                	mv	s2,a0
    80001bdc:	e8a8                	sd	a0,80(s1)
  if (p->pagetable == 0) {
    80001bde:	c121                	beqz	a0,80001c1e <allocproc+0x96>
  memset(&p->context, 0, sizeof(p->context));
    80001be0:	07000613          	li	a2,112
    80001be4:	4581                	li	a1,0
    80001be6:	06048513          	addi	a0,s1,96
    80001bea:	940ff0ef          	jal	80000d2a <memset>
  p->context.ra = (uint64)forkret;
    80001bee:	00000797          	auipc	a5,0x0
    80001bf2:	da878793          	addi	a5,a5,-600 # 80001996 <forkret>
    80001bf6:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001bf8:	60bc                	ld	a5,64(s1)
    80001bfa:	6705                	lui	a4,0x1
    80001bfc:	97ba                	add	a5,a5,a4
    80001bfe:	f4bc                	sd	a5,104(s1)
}
    80001c00:	8526                	mv	a0,s1
    80001c02:	60e2                	ld	ra,24(sp)
    80001c04:	6442                	ld	s0,16(sp)
    80001c06:	64a2                	ld	s1,8(sp)
    80001c08:	6902                	ld	s2,0(sp)
    80001c0a:	6105                	addi	sp,sp,32
    80001c0c:	8082                	ret
    freeproc(p);
    80001c0e:	8526                	mv	a0,s1
    80001c10:	f29ff0ef          	jal	80001b38 <freeproc>
    release(&p->lock);
    80001c14:	8526                	mv	a0,s1
    80001c16:	8d8ff0ef          	jal	80000cee <release>
    return 0;
    80001c1a:	84ca                	mv	s1,s2
    80001c1c:	b7d5                	j	80001c00 <allocproc+0x78>
    freeproc(p);
    80001c1e:	8526                	mv	a0,s1
    80001c20:	f19ff0ef          	jal	80001b38 <freeproc>
    release(&p->lock);
    80001c24:	8526                	mv	a0,s1
    80001c26:	8c8ff0ef          	jal	80000cee <release>
    return 0;
    80001c2a:	84ca                	mv	s1,s2
    80001c2c:	bfd1                	j	80001c00 <allocproc+0x78>

0000000080001c2e <userinit>:
void userinit(void) {
    80001c2e:	1101                	addi	sp,sp,-32
    80001c30:	ec06                	sd	ra,24(sp)
    80001c32:	e822                	sd	s0,16(sp)
    80001c34:	e426                	sd	s1,8(sp)
    80001c36:	1000                	addi	s0,sp,32
  p = allocproc();
    80001c38:	f51ff0ef          	jal	80001b88 <allocproc>
    80001c3c:	84aa                	mv	s1,a0
  initproc = p;
    80001c3e:	00009797          	auipc	a5,0x9
    80001c42:	92a7b123          	sd	a0,-1758(a5) # 8000a560 <initproc>
  p->cwd = namei("/");
    80001c46:	00005517          	auipc	a0,0x5
    80001c4a:	55250513          	addi	a0,a0,1362 # 80007198 <etext+0x198>
    80001c4e:	66f010ef          	jal	80003abc <namei>
    80001c52:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    80001c56:	478d                	li	a5,3
    80001c58:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001c5a:	8526                	mv	a0,s1
    80001c5c:	892ff0ef          	jal	80000cee <release>
}
    80001c60:	60e2                	ld	ra,24(sp)
    80001c62:	6442                	ld	s0,16(sp)
    80001c64:	64a2                	ld	s1,8(sp)
    80001c66:	6105                	addi	sp,sp,32
    80001c68:	8082                	ret

0000000080001c6a <growproc>:
int growproc(int n) {
    80001c6a:	1101                	addi	sp,sp,-32
    80001c6c:	ec06                	sd	ra,24(sp)
    80001c6e:	e822                	sd	s0,16(sp)
    80001c70:	e426                	sd	s1,8(sp)
    80001c72:	e04a                	sd	s2,0(sp)
    80001c74:	1000                	addi	s0,sp,32
    80001c76:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80001c78:	cedff0ef          	jal	80001964 <myproc>
    80001c7c:	892a                	mv	s2,a0
  sz = p->sz;
    80001c7e:	652c                	ld	a1,72(a0)
  if (n > 0) {
    80001c80:	02905963          	blez	s1,80001cb2 <growproc+0x48>
    if (sz + n > TRAPFRAME) {
    80001c84:	00b48633          	add	a2,s1,a1
    80001c88:	020007b7          	lui	a5,0x2000
    80001c8c:	17fd                	addi	a5,a5,-1 # 1ffffff <_entry-0x7e000001>
    80001c8e:	07b6                	slli	a5,a5,0xd
    80001c90:	02c7ea63          	bltu	a5,a2,80001cc4 <growproc+0x5a>
    if ((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0) {
    80001c94:	4691                	li	a3,4
    80001c96:	6928                	ld	a0,80(a0)
    80001c98:	e9aff0ef          	jal	80001332 <uvmalloc>
    80001c9c:	85aa                	mv	a1,a0
    80001c9e:	c50d                	beqz	a0,80001cc8 <growproc+0x5e>
  p->sz = sz;
    80001ca0:	04b93423          	sd	a1,72(s2)
  return 0;
    80001ca4:	4501                	li	a0,0
}
    80001ca6:	60e2                	ld	ra,24(sp)
    80001ca8:	6442                	ld	s0,16(sp)
    80001caa:	64a2                	ld	s1,8(sp)
    80001cac:	6902                	ld	s2,0(sp)
    80001cae:	6105                	addi	sp,sp,32
    80001cb0:	8082                	ret
  } else if (n < 0) {
    80001cb2:	fe04d7e3          	bgez	s1,80001ca0 <growproc+0x36>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001cb6:	00b48633          	add	a2,s1,a1
    80001cba:	6928                	ld	a0,80(a0)
    80001cbc:	e32ff0ef          	jal	800012ee <uvmdealloc>
    80001cc0:	85aa                	mv	a1,a0
    80001cc2:	bff9                	j	80001ca0 <growproc+0x36>
      return -1;
    80001cc4:	557d                	li	a0,-1
    80001cc6:	b7c5                	j	80001ca6 <growproc+0x3c>
      return -1;
    80001cc8:	557d                	li	a0,-1
    80001cca:	bff1                	j	80001ca6 <growproc+0x3c>

0000000080001ccc <kfork>:
int kfork(void) {
    80001ccc:	7139                	addi	sp,sp,-64
    80001cce:	fc06                	sd	ra,56(sp)
    80001cd0:	f822                	sd	s0,48(sp)
    80001cd2:	f426                	sd	s1,40(sp)
    80001cd4:	e456                	sd	s5,8(sp)
    80001cd6:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    80001cd8:	c8dff0ef          	jal	80001964 <myproc>
    80001cdc:	8aaa                	mv	s5,a0
  if ((np = allocproc()) == 0) {
    80001cde:	eabff0ef          	jal	80001b88 <allocproc>
    80001ce2:	0e050a63          	beqz	a0,80001dd6 <kfork+0x10a>
    80001ce6:	e852                	sd	s4,16(sp)
    80001ce8:	8a2a                	mv	s4,a0
  if (uvmcopy(p->pagetable, np->pagetable, p->sz) < 0) {
    80001cea:	048ab603          	ld	a2,72(s5)
    80001cee:	692c                	ld	a1,80(a0)
    80001cf0:	050ab503          	ld	a0,80(s5)
    80001cf4:	f76ff0ef          	jal	8000146a <uvmcopy>
    80001cf8:	04054863          	bltz	a0,80001d48 <kfork+0x7c>
    80001cfc:	f04a                	sd	s2,32(sp)
    80001cfe:	ec4e                	sd	s3,24(sp)
  np->sz = p->sz;
    80001d00:	048ab783          	ld	a5,72(s5)
    80001d04:	04fa3423          	sd	a5,72(s4)
  *(np->trapframe) = *(p->trapframe);
    80001d08:	058ab683          	ld	a3,88(s5)
    80001d0c:	87b6                	mv	a5,a3
    80001d0e:	058a3703          	ld	a4,88(s4)
    80001d12:	12068693          	addi	a3,a3,288
    80001d16:	6388                	ld	a0,0(a5)
    80001d18:	678c                	ld	a1,8(a5)
    80001d1a:	6b90                	ld	a2,16(a5)
    80001d1c:	e308                	sd	a0,0(a4)
    80001d1e:	e70c                	sd	a1,8(a4)
    80001d20:	eb10                	sd	a2,16(a4)
    80001d22:	6f90                	ld	a2,24(a5)
    80001d24:	ef10                	sd	a2,24(a4)
    80001d26:	02078793          	addi	a5,a5,32
    80001d2a:	02070713          	addi	a4,a4,32 # 1020 <_entry-0x7fffefe0>
    80001d2e:	fed794e3          	bne	a5,a3,80001d16 <kfork+0x4a>
  np->trapframe->a0 = 0;
    80001d32:	058a3783          	ld	a5,88(s4)
    80001d36:	0607b823          	sd	zero,112(a5)
  for (i = 0; i < NOFILE; i++)
    80001d3a:	0d0a8493          	addi	s1,s5,208
    80001d3e:	0d0a0913          	addi	s2,s4,208
    80001d42:	150a8993          	addi	s3,s5,336
    80001d46:	a831                	j	80001d62 <kfork+0x96>
    freeproc(np);
    80001d48:	8552                	mv	a0,s4
    80001d4a:	defff0ef          	jal	80001b38 <freeproc>
    release(&np->lock);
    80001d4e:	8552                	mv	a0,s4
    80001d50:	f9ffe0ef          	jal	80000cee <release>
    return -1;
    80001d54:	54fd                	li	s1,-1
    80001d56:	6a42                	ld	s4,16(sp)
    80001d58:	a885                	j	80001dc8 <kfork+0xfc>
  for (i = 0; i < NOFILE; i++)
    80001d5a:	04a1                	addi	s1,s1,8
    80001d5c:	0921                	addi	s2,s2,8
    80001d5e:	01348963          	beq	s1,s3,80001d70 <kfork+0xa4>
    if (p->ofile[i])
    80001d62:	6088                	ld	a0,0(s1)
    80001d64:	d97d                	beqz	a0,80001d5a <kfork+0x8e>
      np->ofile[i] = filedup(p->ofile[i]);
    80001d66:	312020ef          	jal	80004078 <filedup>
    80001d6a:	00a93023          	sd	a0,0(s2)
    80001d6e:	b7f5                	j	80001d5a <kfork+0x8e>
  np->cwd = idup(p->cwd);
    80001d70:	150ab503          	ld	a0,336(s5)
    80001d74:	4e4010ef          	jal	80003258 <idup>
    80001d78:	14aa3823          	sd	a0,336(s4)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001d7c:	4641                	li	a2,16
    80001d7e:	158a8593          	addi	a1,s5,344
    80001d82:	158a0513          	addi	a0,s4,344
    80001d86:	8f8ff0ef          	jal	80000e7e <safestrcpy>
  pid = np->pid;
    80001d8a:	030a2483          	lw	s1,48(s4)
  release(&np->lock);
    80001d8e:	8552                	mv	a0,s4
    80001d90:	f5ffe0ef          	jal	80000cee <release>
  acquire(&wait_lock);
    80001d94:	00011517          	auipc	a0,0x11
    80001d98:	92c50513          	addi	a0,a0,-1748 # 800126c0 <wait_lock>
    80001d9c:	ebffe0ef          	jal	80000c5a <acquire>
  np->parent = p;
    80001da0:	035a3c23          	sd	s5,56(s4)
  release(&wait_lock);
    80001da4:	00011517          	auipc	a0,0x11
    80001da8:	91c50513          	addi	a0,a0,-1764 # 800126c0 <wait_lock>
    80001dac:	f43fe0ef          	jal	80000cee <release>
  acquire(&np->lock);
    80001db0:	8552                	mv	a0,s4
    80001db2:	ea9fe0ef          	jal	80000c5a <acquire>
  np->state = RUNNABLE;
    80001db6:	478d                	li	a5,3
    80001db8:	00fa2c23          	sw	a5,24(s4)
  release(&np->lock);
    80001dbc:	8552                	mv	a0,s4
    80001dbe:	f31fe0ef          	jal	80000cee <release>
  return pid;
    80001dc2:	7902                	ld	s2,32(sp)
    80001dc4:	69e2                	ld	s3,24(sp)
    80001dc6:	6a42                	ld	s4,16(sp)
}
    80001dc8:	8526                	mv	a0,s1
    80001dca:	70e2                	ld	ra,56(sp)
    80001dcc:	7442                	ld	s0,48(sp)
    80001dce:	74a2                	ld	s1,40(sp)
    80001dd0:	6aa2                	ld	s5,8(sp)
    80001dd2:	6121                	addi	sp,sp,64
    80001dd4:	8082                	ret
    return -1;
    80001dd6:	54fd                	li	s1,-1
    80001dd8:	bfc5                	j	80001dc8 <kfork+0xfc>

0000000080001dda <scheduler>:
void scheduler(void) {
    80001dda:	715d                	addi	sp,sp,-80
    80001ddc:	e486                	sd	ra,72(sp)
    80001dde:	e0a2                	sd	s0,64(sp)
    80001de0:	fc26                	sd	s1,56(sp)
    80001de2:	f84a                	sd	s2,48(sp)
    80001de4:	f44e                	sd	s3,40(sp)
    80001de6:	f052                	sd	s4,32(sp)
    80001de8:	ec56                	sd	s5,24(sp)
    80001dea:	e85a                	sd	s6,16(sp)
    80001dec:	e45e                	sd	s7,8(sp)
    80001dee:	e062                	sd	s8,0(sp)
    80001df0:	0880                	addi	s0,sp,80
    80001df2:	8792                	mv	a5,tp
  int id = r_tp();
    80001df4:	2781                	sext.w	a5,a5
  c->proc = 0;
    80001df6:	00779b13          	slli	s6,a5,0x7
    80001dfa:	00011717          	auipc	a4,0x11
    80001dfe:	8ae70713          	addi	a4,a4,-1874 # 800126a8 <pid_lock>
    80001e02:	975a                	add	a4,a4,s6
    80001e04:	02073823          	sd	zero,48(a4)
        swtch(&c->context, &p->context);
    80001e08:	00011717          	auipc	a4,0x11
    80001e0c:	8d870713          	addi	a4,a4,-1832 # 800126e0 <cpus+0x8>
    80001e10:	9b3a                	add	s6,s6,a4
        p->state = RUNNING;
    80001e12:	4c11                	li	s8,4
        c->proc = p;
    80001e14:	079e                	slli	a5,a5,0x7
    80001e16:	00011a17          	auipc	s4,0x11
    80001e1a:	892a0a13          	addi	s4,s4,-1902 # 800126a8 <pid_lock>
    80001e1e:	9a3e                	add	s4,s4,a5
        found = 1;
    80001e20:	4b85                	li	s7,1
    80001e22:	a091                	j	80001e66 <scheduler+0x8c>
      release(&p->lock);
    80001e24:	8526                	mv	a0,s1
    80001e26:	ec9fe0ef          	jal	80000cee <release>
    for (p = proc; p < &proc[NPROC]; p++) {
    80001e2a:	16848493          	addi	s1,s1,360
    80001e2e:	03248863          	beq	s1,s2,80001e5e <scheduler+0x84>
      acquire(&p->lock);
    80001e32:	8526                	mv	a0,s1
    80001e34:	e27fe0ef          	jal	80000c5a <acquire>
      if (p->state == RUNNABLE) {
    80001e38:	4c9c                	lw	a5,24(s1)
    80001e3a:	ff3795e3          	bne	a5,s3,80001e24 <scheduler+0x4a>
        p->state = RUNNING;
    80001e3e:	0184ac23          	sw	s8,24(s1)
        c->proc = p;
    80001e42:	029a3823          	sd	s1,48(s4)
        cslog_run_start(p);
    80001e46:	8526                	mv	a0,s1
    80001e48:	4cd030ef          	jal	80005b14 <cslog_run_start>
        swtch(&c->context, &p->context);
    80001e4c:	06048593          	addi	a1,s1,96
    80001e50:	855a                	mv	a0,s6
    80001e52:	5ba000ef          	jal	8000240c <swtch>
        c->proc = 0;
    80001e56:	020a3823          	sd	zero,48(s4)
        found = 1;
    80001e5a:	8ade                	mv	s5,s7
    80001e5c:	b7e1                	j	80001e24 <scheduler+0x4a>
    if (found == 0) {
    80001e5e:	000a9463          	bnez	s5,80001e66 <scheduler+0x8c>
      asm volatile("wfi");
    80001e62:	10500073          	wfi
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001e66:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001e6a:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001e6e:	10079073          	csrw	sstatus,a5
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001e72:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80001e76:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001e78:	10079073          	csrw	sstatus,a5
    int found = 0;
    80001e7c:	4a81                	li	s5,0
    for (p = proc; p < &proc[NPROC]; p++) {
    80001e7e:	00011497          	auipc	s1,0x11
    80001e82:	c5a48493          	addi	s1,s1,-934 # 80012ad8 <proc>
      if (p->state == RUNNABLE) {
    80001e86:	498d                	li	s3,3
    for (p = proc; p < &proc[NPROC]; p++) {
    80001e88:	00016917          	auipc	s2,0x16
    80001e8c:	65090913          	addi	s2,s2,1616 # 800184d8 <tickslock>
    80001e90:	b74d                	j	80001e32 <scheduler+0x58>

0000000080001e92 <sched>:
void sched(void) {
    80001e92:	7179                	addi	sp,sp,-48
    80001e94:	f406                	sd	ra,40(sp)
    80001e96:	f022                	sd	s0,32(sp)
    80001e98:	ec26                	sd	s1,24(sp)
    80001e9a:	e84a                	sd	s2,16(sp)
    80001e9c:	e44e                	sd	s3,8(sp)
    80001e9e:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80001ea0:	ac5ff0ef          	jal	80001964 <myproc>
    80001ea4:	84aa                	mv	s1,a0
  if (!holding(&p->lock))
    80001ea6:	d45fe0ef          	jal	80000bea <holding>
    80001eaa:	c935                	beqz	a0,80001f1e <sched+0x8c>
  asm volatile("mv %0, tp" : "=r" (x) );
    80001eac:	8792                	mv	a5,tp
  if (mycpu()->noff != 1)
    80001eae:	2781                	sext.w	a5,a5
    80001eb0:	079e                	slli	a5,a5,0x7
    80001eb2:	00010717          	auipc	a4,0x10
    80001eb6:	7f670713          	addi	a4,a4,2038 # 800126a8 <pid_lock>
    80001eba:	97ba                	add	a5,a5,a4
    80001ebc:	0a87a703          	lw	a4,168(a5)
    80001ec0:	4785                	li	a5,1
    80001ec2:	06f71463          	bne	a4,a5,80001f2a <sched+0x98>
  if (p->state == RUNNING)
    80001ec6:	4c98                	lw	a4,24(s1)
    80001ec8:	4791                	li	a5,4
    80001eca:	06f70663          	beq	a4,a5,80001f36 <sched+0xa4>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001ece:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80001ed2:	8b89                	andi	a5,a5,2
  if (intr_get())
    80001ed4:	e7bd                	bnez	a5,80001f42 <sched+0xb0>
  asm volatile("mv %0, tp" : "=r" (x) );
    80001ed6:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    80001ed8:	00010917          	auipc	s2,0x10
    80001edc:	7d090913          	addi	s2,s2,2000 # 800126a8 <pid_lock>
    80001ee0:	2781                	sext.w	a5,a5
    80001ee2:	079e                	slli	a5,a5,0x7
    80001ee4:	97ca                	add	a5,a5,s2
    80001ee6:	0ac7a983          	lw	s3,172(a5)
    80001eea:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    80001eec:	2781                	sext.w	a5,a5
    80001eee:	079e                	slli	a5,a5,0x7
    80001ef0:	07a1                	addi	a5,a5,8
    80001ef2:	00010597          	auipc	a1,0x10
    80001ef6:	7e658593          	addi	a1,a1,2022 # 800126d8 <cpus>
    80001efa:	95be                	add	a1,a1,a5
    80001efc:	06048513          	addi	a0,s1,96
    80001f00:	50c000ef          	jal	8000240c <swtch>
    80001f04:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    80001f06:	2781                	sext.w	a5,a5
    80001f08:	079e                	slli	a5,a5,0x7
    80001f0a:	993e                	add	s2,s2,a5
    80001f0c:	0b392623          	sw	s3,172(s2)
}
    80001f10:	70a2                	ld	ra,40(sp)
    80001f12:	7402                	ld	s0,32(sp)
    80001f14:	64e2                	ld	s1,24(sp)
    80001f16:	6942                	ld	s2,16(sp)
    80001f18:	69a2                	ld	s3,8(sp)
    80001f1a:	6145                	addi	sp,sp,48
    80001f1c:	8082                	ret
    panic("sched p->lock");
    80001f1e:	00005517          	auipc	a0,0x5
    80001f22:	28250513          	addi	a0,a0,642 # 800071a0 <etext+0x1a0>
    80001f26:	931fe0ef          	jal	80000856 <panic>
    panic("sched locks");
    80001f2a:	00005517          	auipc	a0,0x5
    80001f2e:	28650513          	addi	a0,a0,646 # 800071b0 <etext+0x1b0>
    80001f32:	925fe0ef          	jal	80000856 <panic>
    panic("sched RUNNING");
    80001f36:	00005517          	auipc	a0,0x5
    80001f3a:	28a50513          	addi	a0,a0,650 # 800071c0 <etext+0x1c0>
    80001f3e:	919fe0ef          	jal	80000856 <panic>
    panic("sched interruptible");
    80001f42:	00005517          	auipc	a0,0x5
    80001f46:	28e50513          	addi	a0,a0,654 # 800071d0 <etext+0x1d0>
    80001f4a:	90dfe0ef          	jal	80000856 <panic>

0000000080001f4e <yield>:
void yield(void) {
    80001f4e:	1101                	addi	sp,sp,-32
    80001f50:	ec06                	sd	ra,24(sp)
    80001f52:	e822                	sd	s0,16(sp)
    80001f54:	e426                	sd	s1,8(sp)
    80001f56:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80001f58:	a0dff0ef          	jal	80001964 <myproc>
    80001f5c:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80001f5e:	cfdfe0ef          	jal	80000c5a <acquire>
  p->state = RUNNABLE;
    80001f62:	478d                	li	a5,3
    80001f64:	cc9c                	sw	a5,24(s1)
  sched();
    80001f66:	f2dff0ef          	jal	80001e92 <sched>
  release(&p->lock);
    80001f6a:	8526                	mv	a0,s1
    80001f6c:	d83fe0ef          	jal	80000cee <release>
}
    80001f70:	60e2                	ld	ra,24(sp)
    80001f72:	6442                	ld	s0,16(sp)
    80001f74:	64a2                	ld	s1,8(sp)
    80001f76:	6105                	addi	sp,sp,32
    80001f78:	8082                	ret

0000000080001f7a <sleep>:

// Sleep on channel chan, releasing condition lock lk.
// Re-acquires lk when awakened.
void sleep(void *chan, struct spinlock *lk) {
    80001f7a:	7179                	addi	sp,sp,-48
    80001f7c:	f406                	sd	ra,40(sp)
    80001f7e:	f022                	sd	s0,32(sp)
    80001f80:	ec26                	sd	s1,24(sp)
    80001f82:	e84a                	sd	s2,16(sp)
    80001f84:	e44e                	sd	s3,8(sp)
    80001f86:	1800                	addi	s0,sp,48
    80001f88:	89aa                	mv	s3,a0
    80001f8a:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80001f8c:	9d9ff0ef          	jal	80001964 <myproc>
    80001f90:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock); // DOC: sleeplock1
    80001f92:	cc9fe0ef          	jal	80000c5a <acquire>
  release(lk);
    80001f96:	854a                	mv	a0,s2
    80001f98:	d57fe0ef          	jal	80000cee <release>

  // Go to sleep.
  p->chan = chan;
    80001f9c:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    80001fa0:	4789                	li	a5,2
    80001fa2:	cc9c                	sw	a5,24(s1)

  sched();
    80001fa4:	eefff0ef          	jal	80001e92 <sched>

  // Tidy up.
  p->chan = 0;
    80001fa8:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    80001fac:	8526                	mv	a0,s1
    80001fae:	d41fe0ef          	jal	80000cee <release>
  acquire(lk);
    80001fb2:	854a                	mv	a0,s2
    80001fb4:	ca7fe0ef          	jal	80000c5a <acquire>
}
    80001fb8:	70a2                	ld	ra,40(sp)
    80001fba:	7402                	ld	s0,32(sp)
    80001fbc:	64e2                	ld	s1,24(sp)
    80001fbe:	6942                	ld	s2,16(sp)
    80001fc0:	69a2                	ld	s3,8(sp)
    80001fc2:	6145                	addi	sp,sp,48
    80001fc4:	8082                	ret

0000000080001fc6 <wakeup>:

// Wake up all processes sleeping on channel chan.
// Caller should hold the condition lock.
void wakeup(void *chan) {
    80001fc6:	7139                	addi	sp,sp,-64
    80001fc8:	fc06                	sd	ra,56(sp)
    80001fca:	f822                	sd	s0,48(sp)
    80001fcc:	f426                	sd	s1,40(sp)
    80001fce:	f04a                	sd	s2,32(sp)
    80001fd0:	ec4e                	sd	s3,24(sp)
    80001fd2:	e852                	sd	s4,16(sp)
    80001fd4:	e456                	sd	s5,8(sp)
    80001fd6:	0080                	addi	s0,sp,64
    80001fd8:	8a2a                	mv	s4,a0
  struct proc *p;

  for (p = proc; p < &proc[NPROC]; p++) {
    80001fda:	00011497          	auipc	s1,0x11
    80001fde:	afe48493          	addi	s1,s1,-1282 # 80012ad8 <proc>
    if (p != myproc()) {
      acquire(&p->lock);
      if (p->state == SLEEPING && p->chan == chan) {
    80001fe2:	4989                	li	s3,2
        p->state = RUNNABLE;
    80001fe4:	4a8d                	li	s5,3
  for (p = proc; p < &proc[NPROC]; p++) {
    80001fe6:	00016917          	auipc	s2,0x16
    80001fea:	4f290913          	addi	s2,s2,1266 # 800184d8 <tickslock>
    80001fee:	a801                	j	80001ffe <wakeup+0x38>
      }
      release(&p->lock);
    80001ff0:	8526                	mv	a0,s1
    80001ff2:	cfdfe0ef          	jal	80000cee <release>
  for (p = proc; p < &proc[NPROC]; p++) {
    80001ff6:	16848493          	addi	s1,s1,360
    80001ffa:	03248263          	beq	s1,s2,8000201e <wakeup+0x58>
    if (p != myproc()) {
    80001ffe:	967ff0ef          	jal	80001964 <myproc>
    80002002:	fe950ae3          	beq	a0,s1,80001ff6 <wakeup+0x30>
      acquire(&p->lock);
    80002006:	8526                	mv	a0,s1
    80002008:	c53fe0ef          	jal	80000c5a <acquire>
      if (p->state == SLEEPING && p->chan == chan) {
    8000200c:	4c9c                	lw	a5,24(s1)
    8000200e:	ff3791e3          	bne	a5,s3,80001ff0 <wakeup+0x2a>
    80002012:	709c                	ld	a5,32(s1)
    80002014:	fd479ee3          	bne	a5,s4,80001ff0 <wakeup+0x2a>
        p->state = RUNNABLE;
    80002018:	0154ac23          	sw	s5,24(s1)
    8000201c:	bfd1                	j	80001ff0 <wakeup+0x2a>
    }
  }
}
    8000201e:	70e2                	ld	ra,56(sp)
    80002020:	7442                	ld	s0,48(sp)
    80002022:	74a2                	ld	s1,40(sp)
    80002024:	7902                	ld	s2,32(sp)
    80002026:	69e2                	ld	s3,24(sp)
    80002028:	6a42                	ld	s4,16(sp)
    8000202a:	6aa2                	ld	s5,8(sp)
    8000202c:	6121                	addi	sp,sp,64
    8000202e:	8082                	ret

0000000080002030 <reparent>:
void reparent(struct proc *p) {
    80002030:	7179                	addi	sp,sp,-48
    80002032:	f406                	sd	ra,40(sp)
    80002034:	f022                	sd	s0,32(sp)
    80002036:	ec26                	sd	s1,24(sp)
    80002038:	e84a                	sd	s2,16(sp)
    8000203a:	e44e                	sd	s3,8(sp)
    8000203c:	e052                	sd	s4,0(sp)
    8000203e:	1800                	addi	s0,sp,48
    80002040:	892a                	mv	s2,a0
  for (pp = proc; pp < &proc[NPROC]; pp++) {
    80002042:	00011497          	auipc	s1,0x11
    80002046:	a9648493          	addi	s1,s1,-1386 # 80012ad8 <proc>
      pp->parent = initproc;
    8000204a:	00008a17          	auipc	s4,0x8
    8000204e:	516a0a13          	addi	s4,s4,1302 # 8000a560 <initproc>
  for (pp = proc; pp < &proc[NPROC]; pp++) {
    80002052:	00016997          	auipc	s3,0x16
    80002056:	48698993          	addi	s3,s3,1158 # 800184d8 <tickslock>
    8000205a:	a029                	j	80002064 <reparent+0x34>
    8000205c:	16848493          	addi	s1,s1,360
    80002060:	01348b63          	beq	s1,s3,80002076 <reparent+0x46>
    if (pp->parent == p) {
    80002064:	7c9c                	ld	a5,56(s1)
    80002066:	ff279be3          	bne	a5,s2,8000205c <reparent+0x2c>
      pp->parent = initproc;
    8000206a:	000a3503          	ld	a0,0(s4)
    8000206e:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    80002070:	f57ff0ef          	jal	80001fc6 <wakeup>
    80002074:	b7e5                	j	8000205c <reparent+0x2c>
}
    80002076:	70a2                	ld	ra,40(sp)
    80002078:	7402                	ld	s0,32(sp)
    8000207a:	64e2                	ld	s1,24(sp)
    8000207c:	6942                	ld	s2,16(sp)
    8000207e:	69a2                	ld	s3,8(sp)
    80002080:	6a02                	ld	s4,0(sp)
    80002082:	6145                	addi	sp,sp,48
    80002084:	8082                	ret

0000000080002086 <kexit>:
void kexit(int status) {
    80002086:	7179                	addi	sp,sp,-48
    80002088:	f406                	sd	ra,40(sp)
    8000208a:	f022                	sd	s0,32(sp)
    8000208c:	ec26                	sd	s1,24(sp)
    8000208e:	e84a                	sd	s2,16(sp)
    80002090:	e44e                	sd	s3,8(sp)
    80002092:	e052                	sd	s4,0(sp)
    80002094:	1800                	addi	s0,sp,48
    80002096:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    80002098:	8cdff0ef          	jal	80001964 <myproc>
    8000209c:	89aa                	mv	s3,a0
  if (p == initproc)
    8000209e:	00008797          	auipc	a5,0x8
    800020a2:	4c27b783          	ld	a5,1218(a5) # 8000a560 <initproc>
    800020a6:	0d050493          	addi	s1,a0,208
    800020aa:	15050913          	addi	s2,a0,336
    800020ae:	00a79b63          	bne	a5,a0,800020c4 <kexit+0x3e>
    panic("init exiting");
    800020b2:	00005517          	auipc	a0,0x5
    800020b6:	13650513          	addi	a0,a0,310 # 800071e8 <etext+0x1e8>
    800020ba:	f9cfe0ef          	jal	80000856 <panic>
  for (int fd = 0; fd < NOFILE; fd++) {
    800020be:	04a1                	addi	s1,s1,8
    800020c0:	01248963          	beq	s1,s2,800020d2 <kexit+0x4c>
    if (p->ofile[fd]) {
    800020c4:	6088                	ld	a0,0(s1)
    800020c6:	dd65                	beqz	a0,800020be <kexit+0x38>
      fileclose(f);
    800020c8:	7f7010ef          	jal	800040be <fileclose>
      p->ofile[fd] = 0;
    800020cc:	0004b023          	sd	zero,0(s1)
    800020d0:	b7fd                	j	800020be <kexit+0x38>
  begin_op();
    800020d2:	3c9010ef          	jal	80003c9a <begin_op>
  iput(p->cwd);
    800020d6:	1509b503          	ld	a0,336(s3)
    800020da:	336010ef          	jal	80003410 <iput>
  end_op();
    800020de:	42d010ef          	jal	80003d0a <end_op>
  p->cwd = 0;
    800020e2:	1409b823          	sd	zero,336(s3)
  acquire(&wait_lock);
    800020e6:	00010517          	auipc	a0,0x10
    800020ea:	5da50513          	addi	a0,a0,1498 # 800126c0 <wait_lock>
    800020ee:	b6dfe0ef          	jal	80000c5a <acquire>
  reparent(p);
    800020f2:	854e                	mv	a0,s3
    800020f4:	f3dff0ef          	jal	80002030 <reparent>
  wakeup(p->parent);
    800020f8:	0389b503          	ld	a0,56(s3)
    800020fc:	ecbff0ef          	jal	80001fc6 <wakeup>
  acquire(&p->lock);
    80002100:	854e                	mv	a0,s3
    80002102:	b59fe0ef          	jal	80000c5a <acquire>
  p->xstate = status;
    80002106:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    8000210a:	4795                	li	a5,5
    8000210c:	00f9ac23          	sw	a5,24(s3)
  release(&wait_lock);
    80002110:	00010517          	auipc	a0,0x10
    80002114:	5b050513          	addi	a0,a0,1456 # 800126c0 <wait_lock>
    80002118:	bd7fe0ef          	jal	80000cee <release>
  sched();
    8000211c:	d77ff0ef          	jal	80001e92 <sched>
  panic("zombie exit");
    80002120:	00005517          	auipc	a0,0x5
    80002124:	0d850513          	addi	a0,a0,216 # 800071f8 <etext+0x1f8>
    80002128:	f2efe0ef          	jal	80000856 <panic>

000000008000212c <kkill>:

// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int kkill(int pid) {
    8000212c:	7179                	addi	sp,sp,-48
    8000212e:	f406                	sd	ra,40(sp)
    80002130:	f022                	sd	s0,32(sp)
    80002132:	ec26                	sd	s1,24(sp)
    80002134:	e84a                	sd	s2,16(sp)
    80002136:	e44e                	sd	s3,8(sp)
    80002138:	1800                	addi	s0,sp,48
    8000213a:	892a                	mv	s2,a0
  struct proc *p;

  for (p = proc; p < &proc[NPROC]; p++) {
    8000213c:	00011497          	auipc	s1,0x11
    80002140:	99c48493          	addi	s1,s1,-1636 # 80012ad8 <proc>
    80002144:	00016997          	auipc	s3,0x16
    80002148:	39498993          	addi	s3,s3,916 # 800184d8 <tickslock>
    acquire(&p->lock);
    8000214c:	8526                	mv	a0,s1
    8000214e:	b0dfe0ef          	jal	80000c5a <acquire>
    if (p->pid == pid) {
    80002152:	589c                	lw	a5,48(s1)
    80002154:	01278b63          	beq	a5,s2,8000216a <kkill+0x3e>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    80002158:	8526                	mv	a0,s1
    8000215a:	b95fe0ef          	jal	80000cee <release>
  for (p = proc; p < &proc[NPROC]; p++) {
    8000215e:	16848493          	addi	s1,s1,360
    80002162:	ff3495e3          	bne	s1,s3,8000214c <kkill+0x20>
  }
  return -1;
    80002166:	557d                	li	a0,-1
    80002168:	a819                	j	8000217e <kkill+0x52>
      p->killed = 1;
    8000216a:	4785                	li	a5,1
    8000216c:	d49c                	sw	a5,40(s1)
      if (p->state == SLEEPING) {
    8000216e:	4c98                	lw	a4,24(s1)
    80002170:	4789                	li	a5,2
    80002172:	00f70d63          	beq	a4,a5,8000218c <kkill+0x60>
      release(&p->lock);
    80002176:	8526                	mv	a0,s1
    80002178:	b77fe0ef          	jal	80000cee <release>
      return 0;
    8000217c:	4501                	li	a0,0
}
    8000217e:	70a2                	ld	ra,40(sp)
    80002180:	7402                	ld	s0,32(sp)
    80002182:	64e2                	ld	s1,24(sp)
    80002184:	6942                	ld	s2,16(sp)
    80002186:	69a2                	ld	s3,8(sp)
    80002188:	6145                	addi	sp,sp,48
    8000218a:	8082                	ret
        p->state = RUNNABLE;
    8000218c:	478d                	li	a5,3
    8000218e:	cc9c                	sw	a5,24(s1)
    80002190:	b7dd                	j	80002176 <kkill+0x4a>

0000000080002192 <setkilled>:

void setkilled(struct proc *p) {
    80002192:	1101                	addi	sp,sp,-32
    80002194:	ec06                	sd	ra,24(sp)
    80002196:	e822                	sd	s0,16(sp)
    80002198:	e426                	sd	s1,8(sp)
    8000219a:	1000                	addi	s0,sp,32
    8000219c:	84aa                	mv	s1,a0
  acquire(&p->lock);
    8000219e:	abdfe0ef          	jal	80000c5a <acquire>
  p->killed = 1;
    800021a2:	4785                	li	a5,1
    800021a4:	d49c                	sw	a5,40(s1)
  release(&p->lock);
    800021a6:	8526                	mv	a0,s1
    800021a8:	b47fe0ef          	jal	80000cee <release>
}
    800021ac:	60e2                	ld	ra,24(sp)
    800021ae:	6442                	ld	s0,16(sp)
    800021b0:	64a2                	ld	s1,8(sp)
    800021b2:	6105                	addi	sp,sp,32
    800021b4:	8082                	ret

00000000800021b6 <killed>:

int killed(struct proc *p) {
    800021b6:	1101                	addi	sp,sp,-32
    800021b8:	ec06                	sd	ra,24(sp)
    800021ba:	e822                	sd	s0,16(sp)
    800021bc:	e426                	sd	s1,8(sp)
    800021be:	e04a                	sd	s2,0(sp)
    800021c0:	1000                	addi	s0,sp,32
    800021c2:	84aa                	mv	s1,a0
  int k;

  acquire(&p->lock);
    800021c4:	a97fe0ef          	jal	80000c5a <acquire>
  k = p->killed;
    800021c8:	549c                	lw	a5,40(s1)
    800021ca:	893e                	mv	s2,a5
  release(&p->lock);
    800021cc:	8526                	mv	a0,s1
    800021ce:	b21fe0ef          	jal	80000cee <release>
  return k;
}
    800021d2:	854a                	mv	a0,s2
    800021d4:	60e2                	ld	ra,24(sp)
    800021d6:	6442                	ld	s0,16(sp)
    800021d8:	64a2                	ld	s1,8(sp)
    800021da:	6902                	ld	s2,0(sp)
    800021dc:	6105                	addi	sp,sp,32
    800021de:	8082                	ret

00000000800021e0 <kwait>:
int kwait(uint64 addr) {
    800021e0:	715d                	addi	sp,sp,-80
    800021e2:	e486                	sd	ra,72(sp)
    800021e4:	e0a2                	sd	s0,64(sp)
    800021e6:	fc26                	sd	s1,56(sp)
    800021e8:	f84a                	sd	s2,48(sp)
    800021ea:	f44e                	sd	s3,40(sp)
    800021ec:	f052                	sd	s4,32(sp)
    800021ee:	ec56                	sd	s5,24(sp)
    800021f0:	e85a                	sd	s6,16(sp)
    800021f2:	e45e                	sd	s7,8(sp)
    800021f4:	0880                	addi	s0,sp,80
    800021f6:	8baa                	mv	s7,a0
  struct proc *p = myproc();
    800021f8:	f6cff0ef          	jal	80001964 <myproc>
    800021fc:	892a                	mv	s2,a0
  acquire(&wait_lock);
    800021fe:	00010517          	auipc	a0,0x10
    80002202:	4c250513          	addi	a0,a0,1218 # 800126c0 <wait_lock>
    80002206:	a55fe0ef          	jal	80000c5a <acquire>
        if (pp->state == ZOMBIE) {
    8000220a:	4a15                	li	s4,5
        havekids = 1;
    8000220c:	4a85                	li	s5,1
    for (pp = proc; pp < &proc[NPROC]; pp++) {
    8000220e:	00016997          	auipc	s3,0x16
    80002212:	2ca98993          	addi	s3,s3,714 # 800184d8 <tickslock>
    sleep(p, &wait_lock); // DOC: wait-sleep
    80002216:	00010b17          	auipc	s6,0x10
    8000221a:	4aab0b13          	addi	s6,s6,1194 # 800126c0 <wait_lock>
    8000221e:	a869                	j	800022b8 <kwait+0xd8>
          pid = pp->pid;
    80002220:	0304a983          	lw	s3,48(s1)
          if (addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    80002224:	000b8c63          	beqz	s7,8000223c <kwait+0x5c>
    80002228:	4691                	li	a3,4
    8000222a:	02c48613          	addi	a2,s1,44
    8000222e:	85de                	mv	a1,s7
    80002230:	05093503          	ld	a0,80(s2)
    80002234:	c56ff0ef          	jal	8000168a <copyout>
    80002238:	02054a63          	bltz	a0,8000226c <kwait+0x8c>
          freeproc(pp);
    8000223c:	8526                	mv	a0,s1
    8000223e:	8fbff0ef          	jal	80001b38 <freeproc>
          release(&pp->lock);
    80002242:	8526                	mv	a0,s1
    80002244:	aabfe0ef          	jal	80000cee <release>
          release(&wait_lock);
    80002248:	00010517          	auipc	a0,0x10
    8000224c:	47850513          	addi	a0,a0,1144 # 800126c0 <wait_lock>
    80002250:	a9ffe0ef          	jal	80000cee <release>
}
    80002254:	854e                	mv	a0,s3
    80002256:	60a6                	ld	ra,72(sp)
    80002258:	6406                	ld	s0,64(sp)
    8000225a:	74e2                	ld	s1,56(sp)
    8000225c:	7942                	ld	s2,48(sp)
    8000225e:	79a2                	ld	s3,40(sp)
    80002260:	7a02                	ld	s4,32(sp)
    80002262:	6ae2                	ld	s5,24(sp)
    80002264:	6b42                	ld	s6,16(sp)
    80002266:	6ba2                	ld	s7,8(sp)
    80002268:	6161                	addi	sp,sp,80
    8000226a:	8082                	ret
            release(&pp->lock);
    8000226c:	8526                	mv	a0,s1
    8000226e:	a81fe0ef          	jal	80000cee <release>
            release(&wait_lock);
    80002272:	00010517          	auipc	a0,0x10
    80002276:	44e50513          	addi	a0,a0,1102 # 800126c0 <wait_lock>
    8000227a:	a75fe0ef          	jal	80000cee <release>
            return -1;
    8000227e:	59fd                	li	s3,-1
    80002280:	bfd1                	j	80002254 <kwait+0x74>
    for (pp = proc; pp < &proc[NPROC]; pp++) {
    80002282:	16848493          	addi	s1,s1,360
    80002286:	03348063          	beq	s1,s3,800022a6 <kwait+0xc6>
      if (pp->parent == p) {
    8000228a:	7c9c                	ld	a5,56(s1)
    8000228c:	ff279be3          	bne	a5,s2,80002282 <kwait+0xa2>
        acquire(&pp->lock);
    80002290:	8526                	mv	a0,s1
    80002292:	9c9fe0ef          	jal	80000c5a <acquire>
        if (pp->state == ZOMBIE) {
    80002296:	4c9c                	lw	a5,24(s1)
    80002298:	f94784e3          	beq	a5,s4,80002220 <kwait+0x40>
        release(&pp->lock);
    8000229c:	8526                	mv	a0,s1
    8000229e:	a51fe0ef          	jal	80000cee <release>
        havekids = 1;
    800022a2:	8756                	mv	a4,s5
    800022a4:	bff9                	j	80002282 <kwait+0xa2>
    if (!havekids || killed(p)) {
    800022a6:	cf19                	beqz	a4,800022c4 <kwait+0xe4>
    800022a8:	854a                	mv	a0,s2
    800022aa:	f0dff0ef          	jal	800021b6 <killed>
    800022ae:	e919                	bnez	a0,800022c4 <kwait+0xe4>
    sleep(p, &wait_lock); // DOC: wait-sleep
    800022b0:	85da                	mv	a1,s6
    800022b2:	854a                	mv	a0,s2
    800022b4:	cc7ff0ef          	jal	80001f7a <sleep>
    havekids = 0;
    800022b8:	4701                	li	a4,0
    for (pp = proc; pp < &proc[NPROC]; pp++) {
    800022ba:	00011497          	auipc	s1,0x11
    800022be:	81e48493          	addi	s1,s1,-2018 # 80012ad8 <proc>
    800022c2:	b7e1                	j	8000228a <kwait+0xaa>
      release(&wait_lock);
    800022c4:	00010517          	auipc	a0,0x10
    800022c8:	3fc50513          	addi	a0,a0,1020 # 800126c0 <wait_lock>
    800022cc:	a23fe0ef          	jal	80000cee <release>
      return -1;
    800022d0:	59fd                	li	s3,-1
    800022d2:	b749                	j	80002254 <kwait+0x74>

00000000800022d4 <either_copyout>:

// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int either_copyout(int user_dst, uint64 dst, void *src, uint64 len) {
    800022d4:	7179                	addi	sp,sp,-48
    800022d6:	f406                	sd	ra,40(sp)
    800022d8:	f022                	sd	s0,32(sp)
    800022da:	ec26                	sd	s1,24(sp)
    800022dc:	e84a                	sd	s2,16(sp)
    800022de:	e44e                	sd	s3,8(sp)
    800022e0:	e052                	sd	s4,0(sp)
    800022e2:	1800                	addi	s0,sp,48
    800022e4:	84aa                	mv	s1,a0
    800022e6:	8a2e                	mv	s4,a1
    800022e8:	89b2                	mv	s3,a2
    800022ea:	8936                	mv	s2,a3
  struct proc *p = myproc();
    800022ec:	e78ff0ef          	jal	80001964 <myproc>
  if (user_dst) {
    800022f0:	cc99                	beqz	s1,8000230e <either_copyout+0x3a>
    return copyout(p->pagetable, dst, src, len);
    800022f2:	86ca                	mv	a3,s2
    800022f4:	864e                	mv	a2,s3
    800022f6:	85d2                	mv	a1,s4
    800022f8:	6928                	ld	a0,80(a0)
    800022fa:	b90ff0ef          	jal	8000168a <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    800022fe:	70a2                	ld	ra,40(sp)
    80002300:	7402                	ld	s0,32(sp)
    80002302:	64e2                	ld	s1,24(sp)
    80002304:	6942                	ld	s2,16(sp)
    80002306:	69a2                	ld	s3,8(sp)
    80002308:	6a02                	ld	s4,0(sp)
    8000230a:	6145                	addi	sp,sp,48
    8000230c:	8082                	ret
    memmove((char *)dst, src, len);
    8000230e:	0009061b          	sext.w	a2,s2
    80002312:	85ce                	mv	a1,s3
    80002314:	8552                	mv	a0,s4
    80002316:	a75fe0ef          	jal	80000d8a <memmove>
    return 0;
    8000231a:	8526                	mv	a0,s1
    8000231c:	b7cd                	j	800022fe <either_copyout+0x2a>

000000008000231e <either_copyin>:

// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int either_copyin(void *dst, int user_src, uint64 src, uint64 len) {
    8000231e:	7179                	addi	sp,sp,-48
    80002320:	f406                	sd	ra,40(sp)
    80002322:	f022                	sd	s0,32(sp)
    80002324:	ec26                	sd	s1,24(sp)
    80002326:	e84a                	sd	s2,16(sp)
    80002328:	e44e                	sd	s3,8(sp)
    8000232a:	e052                	sd	s4,0(sp)
    8000232c:	1800                	addi	s0,sp,48
    8000232e:	8a2a                	mv	s4,a0
    80002330:	84ae                	mv	s1,a1
    80002332:	89b2                	mv	s3,a2
    80002334:	8936                	mv	s2,a3
  struct proc *p = myproc();
    80002336:	e2eff0ef          	jal	80001964 <myproc>
  if (user_src) {
    8000233a:	cc99                	beqz	s1,80002358 <either_copyin+0x3a>
    return copyin(p->pagetable, dst, src, len);
    8000233c:	86ca                	mv	a3,s2
    8000233e:	864e                	mv	a2,s3
    80002340:	85d2                	mv	a1,s4
    80002342:	6928                	ld	a0,80(a0)
    80002344:	c04ff0ef          	jal	80001748 <copyin>
  } else {
    memmove(dst, (char *)src, len);
    return 0;
  }
}
    80002348:	70a2                	ld	ra,40(sp)
    8000234a:	7402                	ld	s0,32(sp)
    8000234c:	64e2                	ld	s1,24(sp)
    8000234e:	6942                	ld	s2,16(sp)
    80002350:	69a2                	ld	s3,8(sp)
    80002352:	6a02                	ld	s4,0(sp)
    80002354:	6145                	addi	sp,sp,48
    80002356:	8082                	ret
    memmove(dst, (char *)src, len);
    80002358:	0009061b          	sext.w	a2,s2
    8000235c:	85ce                	mv	a1,s3
    8000235e:	8552                	mv	a0,s4
    80002360:	a2bfe0ef          	jal	80000d8a <memmove>
    return 0;
    80002364:	8526                	mv	a0,s1
    80002366:	b7cd                	j	80002348 <either_copyin+0x2a>

0000000080002368 <procdump>:

// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void procdump(void) {
    80002368:	715d                	addi	sp,sp,-80
    8000236a:	e486                	sd	ra,72(sp)
    8000236c:	e0a2                	sd	s0,64(sp)
    8000236e:	fc26                	sd	s1,56(sp)
    80002370:	f84a                	sd	s2,48(sp)
    80002372:	f44e                	sd	s3,40(sp)
    80002374:	f052                	sd	s4,32(sp)
    80002376:	ec56                	sd	s5,24(sp)
    80002378:	e85a                	sd	s6,16(sp)
    8000237a:	e45e                	sd	s7,8(sp)
    8000237c:	0880                	addi	s0,sp,80
      [UNUSED] "unused",   [USED] "used",      [SLEEPING] "sleep ",
      [RUNNABLE] "runble", [RUNNING] "run   ", [ZOMBIE] "zombie"};
  struct proc *p;
  char *state;

  printf("\n");
    8000237e:	00005517          	auipc	a0,0x5
    80002382:	d0250513          	addi	a0,a0,-766 # 80007080 <etext+0x80>
    80002386:	9a6fe0ef          	jal	8000052c <printf>
  for (p = proc; p < &proc[NPROC]; p++) {
    8000238a:	00011497          	auipc	s1,0x11
    8000238e:	8a648493          	addi	s1,s1,-1882 # 80012c30 <proc+0x158>
    80002392:	00016917          	auipc	s2,0x16
    80002396:	29e90913          	addi	s2,s2,670 # 80018630 <bcache+0x140>
    if (p->state == UNUSED)
      continue;
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000239a:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    8000239c:	00005997          	auipc	s3,0x5
    800023a0:	e6c98993          	addi	s3,s3,-404 # 80007208 <etext+0x208>
    printf("%d %s %s", p->pid, state, p->name);
    800023a4:	00005a97          	auipc	s5,0x5
    800023a8:	e6ca8a93          	addi	s5,s5,-404 # 80007210 <etext+0x210>
    printf("\n");
    800023ac:	00005a17          	auipc	s4,0x5
    800023b0:	cd4a0a13          	addi	s4,s4,-812 # 80007080 <etext+0x80>
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800023b4:	00005b97          	auipc	s7,0x5
    800023b8:	3acb8b93          	addi	s7,s7,940 # 80007760 <states.0>
    800023bc:	a829                	j	800023d6 <procdump+0x6e>
    printf("%d %s %s", p->pid, state, p->name);
    800023be:	ed86a583          	lw	a1,-296(a3)
    800023c2:	8556                	mv	a0,s5
    800023c4:	968fe0ef          	jal	8000052c <printf>
    printf("\n");
    800023c8:	8552                	mv	a0,s4
    800023ca:	962fe0ef          	jal	8000052c <printf>
  for (p = proc; p < &proc[NPROC]; p++) {
    800023ce:	16848493          	addi	s1,s1,360
    800023d2:	03248263          	beq	s1,s2,800023f6 <procdump+0x8e>
    if (p->state == UNUSED)
    800023d6:	86a6                	mv	a3,s1
    800023d8:	ec04a783          	lw	a5,-320(s1)
    800023dc:	dbed                	beqz	a5,800023ce <procdump+0x66>
      state = "???";
    800023de:	864e                	mv	a2,s3
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800023e0:	fcfb6fe3          	bltu	s6,a5,800023be <procdump+0x56>
    800023e4:	02079713          	slli	a4,a5,0x20
    800023e8:	01d75793          	srli	a5,a4,0x1d
    800023ec:	97de                	add	a5,a5,s7
    800023ee:	6390                	ld	a2,0(a5)
    800023f0:	f679                	bnez	a2,800023be <procdump+0x56>
      state = "???";
    800023f2:	864e                	mv	a2,s3
    800023f4:	b7e9                	j	800023be <procdump+0x56>
  }
}
    800023f6:	60a6                	ld	ra,72(sp)
    800023f8:	6406                	ld	s0,64(sp)
    800023fa:	74e2                	ld	s1,56(sp)
    800023fc:	7942                	ld	s2,48(sp)
    800023fe:	79a2                	ld	s3,40(sp)
    80002400:	7a02                	ld	s4,32(sp)
    80002402:	6ae2                	ld	s5,24(sp)
    80002404:	6b42                	ld	s6,16(sp)
    80002406:	6ba2                	ld	s7,8(sp)
    80002408:	6161                	addi	sp,sp,80
    8000240a:	8082                	ret

000000008000240c <swtch>:
# Save current registers in old. Load from new.	


.globl swtch
swtch:
        sd ra, 0(a0)
    8000240c:	00153023          	sd	ra,0(a0)
        sd sp, 8(a0)
    80002410:	00253423          	sd	sp,8(a0)
        sd s0, 16(a0)
    80002414:	e900                	sd	s0,16(a0)
        sd s1, 24(a0)
    80002416:	ed04                	sd	s1,24(a0)
        sd s2, 32(a0)
    80002418:	03253023          	sd	s2,32(a0)
        sd s3, 40(a0)
    8000241c:	03353423          	sd	s3,40(a0)
        sd s4, 48(a0)
    80002420:	03453823          	sd	s4,48(a0)
        sd s5, 56(a0)
    80002424:	03553c23          	sd	s5,56(a0)
        sd s6, 64(a0)
    80002428:	05653023          	sd	s6,64(a0)
        sd s7, 72(a0)
    8000242c:	05753423          	sd	s7,72(a0)
        sd s8, 80(a0)
    80002430:	05853823          	sd	s8,80(a0)
        sd s9, 88(a0)
    80002434:	05953c23          	sd	s9,88(a0)
        sd s10, 96(a0)
    80002438:	07a53023          	sd	s10,96(a0)
        sd s11, 104(a0)
    8000243c:	07b53423          	sd	s11,104(a0)

        ld ra, 0(a1)
    80002440:	0005b083          	ld	ra,0(a1)
        ld sp, 8(a1)
    80002444:	0085b103          	ld	sp,8(a1)
        ld s0, 16(a1)
    80002448:	6980                	ld	s0,16(a1)
        ld s1, 24(a1)
    8000244a:	6d84                	ld	s1,24(a1)
        ld s2, 32(a1)
    8000244c:	0205b903          	ld	s2,32(a1)
        ld s3, 40(a1)
    80002450:	0285b983          	ld	s3,40(a1)
        ld s4, 48(a1)
    80002454:	0305ba03          	ld	s4,48(a1)
        ld s5, 56(a1)
    80002458:	0385ba83          	ld	s5,56(a1)
        ld s6, 64(a1)
    8000245c:	0405bb03          	ld	s6,64(a1)
        ld s7, 72(a1)
    80002460:	0485bb83          	ld	s7,72(a1)
        ld s8, 80(a1)
    80002464:	0505bc03          	ld	s8,80(a1)
        ld s9, 88(a1)
    80002468:	0585bc83          	ld	s9,88(a1)
        ld s10, 96(a1)
    8000246c:	0605bd03          	ld	s10,96(a1)
        ld s11, 104(a1)
    80002470:	0685bd83          	ld	s11,104(a1)
        
        ret
    80002474:	8082                	ret

0000000080002476 <trapinit>:

extern int devintr();

void
trapinit(void)
{
    80002476:	1141                	addi	sp,sp,-16
    80002478:	e406                	sd	ra,8(sp)
    8000247a:	e022                	sd	s0,0(sp)
    8000247c:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    8000247e:	00005597          	auipc	a1,0x5
    80002482:	dd258593          	addi	a1,a1,-558 # 80007250 <etext+0x250>
    80002486:	00016517          	auipc	a0,0x16
    8000248a:	05250513          	addi	a0,a0,82 # 800184d8 <tickslock>
    8000248e:	f42fe0ef          	jal	80000bd0 <initlock>
}
    80002492:	60a2                	ld	ra,8(sp)
    80002494:	6402                	ld	s0,0(sp)
    80002496:	0141                	addi	sp,sp,16
    80002498:	8082                	ret

000000008000249a <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    8000249a:	1141                	addi	sp,sp,-16
    8000249c:	e406                	sd	ra,8(sp)
    8000249e:	e022                	sd	s0,0(sp)
    800024a0:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    800024a2:	00003797          	auipc	a5,0x3
    800024a6:	00e78793          	addi	a5,a5,14 # 800054b0 <kernelvec>
    800024aa:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    800024ae:	60a2                	ld	ra,8(sp)
    800024b0:	6402                	ld	s0,0(sp)
    800024b2:	0141                	addi	sp,sp,16
    800024b4:	8082                	ret

00000000800024b6 <prepare_return>:
//
// set up trapframe and control registers for a return to user space
//
void
prepare_return(void)
{
    800024b6:	1141                	addi	sp,sp,-16
    800024b8:	e406                	sd	ra,8(sp)
    800024ba:	e022                	sd	s0,0(sp)
    800024bc:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    800024be:	ca6ff0ef          	jal	80001964 <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800024c2:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    800024c6:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800024c8:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(). because a trap from kernel
  // code to usertrap would be a disaster, turn off interrupts.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    800024cc:	04000737          	lui	a4,0x4000
    800024d0:	177d                	addi	a4,a4,-1 # 3ffffff <_entry-0x7c000001>
    800024d2:	0732                	slli	a4,a4,0xc
    800024d4:	00004797          	auipc	a5,0x4
    800024d8:	b2c78793          	addi	a5,a5,-1236 # 80006000 <_trampoline>
    800024dc:	00004697          	auipc	a3,0x4
    800024e0:	b2468693          	addi	a3,a3,-1244 # 80006000 <_trampoline>
    800024e4:	8f95                	sub	a5,a5,a3
    800024e6:	97ba                	add	a5,a5,a4
  asm volatile("csrw stvec, %0" : : "r" (x));
    800024e8:	10579073          	csrw	stvec,a5
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    800024ec:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    800024ee:	18002773          	csrr	a4,satp
    800024f2:	e398                	sd	a4,0(a5)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    800024f4:	6d38                	ld	a4,88(a0)
    800024f6:	613c                	ld	a5,64(a0)
    800024f8:	6685                	lui	a3,0x1
    800024fa:	97b6                	add	a5,a5,a3
    800024fc:	e71c                	sd	a5,8(a4)
  p->trapframe->kernel_trap = (uint64)usertrap;
    800024fe:	6d3c                	ld	a5,88(a0)
    80002500:	00000717          	auipc	a4,0x0
    80002504:	0fc70713          	addi	a4,a4,252 # 800025fc <usertrap>
    80002508:	eb98                	sd	a4,16(a5)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    8000250a:	6d3c                	ld	a5,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    8000250c:	8712                	mv	a4,tp
    8000250e:	f398                	sd	a4,32(a5)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002510:	100027f3          	csrr	a5,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    80002514:	eff7f793          	andi	a5,a5,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    80002518:	0207e793          	ori	a5,a5,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000251c:	10079073          	csrw	sstatus,a5
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    80002520:	6d3c                	ld	a5,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002522:	6f9c                	ld	a5,24(a5)
    80002524:	14179073          	csrw	sepc,a5
}
    80002528:	60a2                	ld	ra,8(sp)
    8000252a:	6402                	ld	s0,0(sp)
    8000252c:	0141                	addi	sp,sp,16
    8000252e:	8082                	ret

0000000080002530 <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    80002530:	1141                	addi	sp,sp,-16
    80002532:	e406                	sd	ra,8(sp)
    80002534:	e022                	sd	s0,0(sp)
    80002536:	0800                	addi	s0,sp,16
  if(cpuid() == 0){
    80002538:	bf8ff0ef          	jal	80001930 <cpuid>
    8000253c:	cd11                	beqz	a0,80002558 <clockintr+0x28>
  asm volatile("csrr %0, time" : "=r" (x) );
    8000253e:	c01027f3          	rdtime	a5
  }

  // ask for the next timer interrupt. this also clears
  // the interrupt request. 1000000 is about a tenth
  // of a second.
  w_stimecmp(r_time() + 1000000);
    80002542:	000f4737          	lui	a4,0xf4
    80002546:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    8000254a:	97ba                	add	a5,a5,a4
  asm volatile("csrw 0x14d, %0" : : "r" (x));
    8000254c:	14d79073          	csrw	stimecmp,a5
}
    80002550:	60a2                	ld	ra,8(sp)
    80002552:	6402                	ld	s0,0(sp)
    80002554:	0141                	addi	sp,sp,16
    80002556:	8082                	ret
    acquire(&tickslock);
    80002558:	00016517          	auipc	a0,0x16
    8000255c:	f8050513          	addi	a0,a0,-128 # 800184d8 <tickslock>
    80002560:	efafe0ef          	jal	80000c5a <acquire>
    ticks++;
    80002564:	00008717          	auipc	a4,0x8
    80002568:	00470713          	addi	a4,a4,4 # 8000a568 <ticks>
    8000256c:	431c                	lw	a5,0(a4)
    8000256e:	2785                	addiw	a5,a5,1
    80002570:	c31c                	sw	a5,0(a4)
    wakeup(&ticks);
    80002572:	853a                	mv	a0,a4
    80002574:	a53ff0ef          	jal	80001fc6 <wakeup>
    release(&tickslock);
    80002578:	00016517          	auipc	a0,0x16
    8000257c:	f6050513          	addi	a0,a0,-160 # 800184d8 <tickslock>
    80002580:	f6efe0ef          	jal	80000cee <release>
    80002584:	bf6d                	j	8000253e <clockintr+0xe>

0000000080002586 <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    80002586:	1101                	addi	sp,sp,-32
    80002588:	ec06                	sd	ra,24(sp)
    8000258a:	e822                	sd	s0,16(sp)
    8000258c:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    8000258e:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if(scause == 0x8000000000000009L){
    80002592:	57fd                	li	a5,-1
    80002594:	17fe                	slli	a5,a5,0x3f
    80002596:	07a5                	addi	a5,a5,9
    80002598:	00f70c63          	beq	a4,a5,800025b0 <devintr+0x2a>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000005L){
    8000259c:	57fd                	li	a5,-1
    8000259e:	17fe                	slli	a5,a5,0x3f
    800025a0:	0795                	addi	a5,a5,5
    // timer interrupt.
    clockintr();
    return 2;
  } else {
    return 0;
    800025a2:	4501                	li	a0,0
  } else if(scause == 0x8000000000000005L){
    800025a4:	04f70863          	beq	a4,a5,800025f4 <devintr+0x6e>
  }
}
    800025a8:	60e2                	ld	ra,24(sp)
    800025aa:	6442                	ld	s0,16(sp)
    800025ac:	6105                	addi	sp,sp,32
    800025ae:	8082                	ret
    800025b0:	e426                	sd	s1,8(sp)
    int irq = plic_claim();
    800025b2:	7ab020ef          	jal	8000555c <plic_claim>
    800025b6:	872a                	mv	a4,a0
    800025b8:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    800025ba:	47a9                	li	a5,10
    800025bc:	00f50963          	beq	a0,a5,800025ce <devintr+0x48>
    } else if(irq == VIRTIO0_IRQ){
    800025c0:	4785                	li	a5,1
    800025c2:	00f50963          	beq	a0,a5,800025d4 <devintr+0x4e>
    return 1;
    800025c6:	4505                	li	a0,1
    } else if(irq){
    800025c8:	eb09                	bnez	a4,800025da <devintr+0x54>
    800025ca:	64a2                	ld	s1,8(sp)
    800025cc:	bff1                	j	800025a8 <devintr+0x22>
      uartintr();
    800025ce:	c58fe0ef          	jal	80000a26 <uartintr>
    if(irq)
    800025d2:	a819                	j	800025e8 <devintr+0x62>
      virtio_disk_intr();
    800025d4:	41e030ef          	jal	800059f2 <virtio_disk_intr>
    if(irq)
    800025d8:	a801                	j	800025e8 <devintr+0x62>
      printf("unexpected interrupt irq=%d\n", irq);
    800025da:	85ba                	mv	a1,a4
    800025dc:	00005517          	auipc	a0,0x5
    800025e0:	c7c50513          	addi	a0,a0,-900 # 80007258 <etext+0x258>
    800025e4:	f49fd0ef          	jal	8000052c <printf>
      plic_complete(irq);
    800025e8:	8526                	mv	a0,s1
    800025ea:	793020ef          	jal	8000557c <plic_complete>
    return 1;
    800025ee:	4505                	li	a0,1
    800025f0:	64a2                	ld	s1,8(sp)
    800025f2:	bf5d                	j	800025a8 <devintr+0x22>
    clockintr();
    800025f4:	f3dff0ef          	jal	80002530 <clockintr>
    return 2;
    800025f8:	4509                	li	a0,2
    800025fa:	b77d                	j	800025a8 <devintr+0x22>

00000000800025fc <usertrap>:
{
    800025fc:	1101                	addi	sp,sp,-32
    800025fe:	ec06                	sd	ra,24(sp)
    80002600:	e822                	sd	s0,16(sp)
    80002602:	e426                	sd	s1,8(sp)
    80002604:	e04a                	sd	s2,0(sp)
    80002606:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002608:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    8000260c:	1007f793          	andi	a5,a5,256
    80002610:	eba5                	bnez	a5,80002680 <usertrap+0x84>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002612:	00003797          	auipc	a5,0x3
    80002616:	e9e78793          	addi	a5,a5,-354 # 800054b0 <kernelvec>
    8000261a:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    8000261e:	b46ff0ef          	jal	80001964 <myproc>
    80002622:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    80002624:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002626:	14102773          	csrr	a4,sepc
    8000262a:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    8000262c:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    80002630:	47a1                	li	a5,8
    80002632:	04f70d63          	beq	a4,a5,8000268c <usertrap+0x90>
  } else if((which_dev = devintr()) != 0){
    80002636:	f51ff0ef          	jal	80002586 <devintr>
    8000263a:	892a                	mv	s2,a0
    8000263c:	e945                	bnez	a0,800026ec <usertrap+0xf0>
    8000263e:	14202773          	csrr	a4,scause
  } else if((r_scause() == 15 || r_scause() == 13) &&
    80002642:	47bd                	li	a5,15
    80002644:	08f70863          	beq	a4,a5,800026d4 <usertrap+0xd8>
    80002648:	14202773          	csrr	a4,scause
    8000264c:	47b5                	li	a5,13
    8000264e:	08f70363          	beq	a4,a5,800026d4 <usertrap+0xd8>
    80002652:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause 0x%lx pid=%d\n", r_scause(), p->pid);
    80002656:	5890                	lw	a2,48(s1)
    80002658:	00005517          	auipc	a0,0x5
    8000265c:	c4050513          	addi	a0,a0,-960 # 80007298 <etext+0x298>
    80002660:	ecdfd0ef          	jal	8000052c <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002664:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002668:	14302673          	csrr	a2,stval
    printf("            sepc=0x%lx stval=0x%lx\n", r_sepc(), r_stval());
    8000266c:	00005517          	auipc	a0,0x5
    80002670:	c5c50513          	addi	a0,a0,-932 # 800072c8 <etext+0x2c8>
    80002674:	eb9fd0ef          	jal	8000052c <printf>
    setkilled(p);
    80002678:	8526                	mv	a0,s1
    8000267a:	b19ff0ef          	jal	80002192 <setkilled>
    8000267e:	a035                	j	800026aa <usertrap+0xae>
    panic("usertrap: not from user mode");
    80002680:	00005517          	auipc	a0,0x5
    80002684:	bf850513          	addi	a0,a0,-1032 # 80007278 <etext+0x278>
    80002688:	9cefe0ef          	jal	80000856 <panic>
    if(killed(p))
    8000268c:	b2bff0ef          	jal	800021b6 <killed>
    80002690:	ed15                	bnez	a0,800026cc <usertrap+0xd0>
    p->trapframe->epc += 4;
    80002692:	6cb8                	ld	a4,88(s1)
    80002694:	6f1c                	ld	a5,24(a4)
    80002696:	0791                	addi	a5,a5,4
    80002698:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000269a:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    8000269e:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800026a2:	10079073          	csrw	sstatus,a5
    syscall();
    800026a6:	240000ef          	jal	800028e6 <syscall>
  if(killed(p))
    800026aa:	8526                	mv	a0,s1
    800026ac:	b0bff0ef          	jal	800021b6 <killed>
    800026b0:	e139                	bnez	a0,800026f6 <usertrap+0xfa>
  prepare_return();
    800026b2:	e05ff0ef          	jal	800024b6 <prepare_return>
  uint64 satp = MAKE_SATP(p->pagetable);
    800026b6:	68a8                	ld	a0,80(s1)
    800026b8:	8131                	srli	a0,a0,0xc
    800026ba:	57fd                	li	a5,-1
    800026bc:	17fe                	slli	a5,a5,0x3f
    800026be:	8d5d                	or	a0,a0,a5
}
    800026c0:	60e2                	ld	ra,24(sp)
    800026c2:	6442                	ld	s0,16(sp)
    800026c4:	64a2                	ld	s1,8(sp)
    800026c6:	6902                	ld	s2,0(sp)
    800026c8:	6105                	addi	sp,sp,32
    800026ca:	8082                	ret
      kexit(-1);
    800026cc:	557d                	li	a0,-1
    800026ce:	9b9ff0ef          	jal	80002086 <kexit>
    800026d2:	b7c1                	j	80002692 <usertrap+0x96>
  asm volatile("csrr %0, stval" : "=r" (x) );
    800026d4:	143025f3          	csrr	a1,stval
  asm volatile("csrr %0, scause" : "=r" (x) );
    800026d8:	14202673          	csrr	a2,scause
            vmfault(p->pagetable, r_stval(), (r_scause() == 13)? 1 : 0) != 0) {
    800026dc:	164d                	addi	a2,a2,-13 # ff3 <_entry-0x7ffff00d>
    800026de:	00163613          	seqz	a2,a2
    800026e2:	68a8                	ld	a0,80(s1)
    800026e4:	f23fe0ef          	jal	80001606 <vmfault>
  } else if((r_scause() == 15 || r_scause() == 13) &&
    800026e8:	f169                	bnez	a0,800026aa <usertrap+0xae>
    800026ea:	b7a5                	j	80002652 <usertrap+0x56>
  if(killed(p))
    800026ec:	8526                	mv	a0,s1
    800026ee:	ac9ff0ef          	jal	800021b6 <killed>
    800026f2:	c511                	beqz	a0,800026fe <usertrap+0x102>
    800026f4:	a011                	j	800026f8 <usertrap+0xfc>
    800026f6:	4901                	li	s2,0
    kexit(-1);
    800026f8:	557d                	li	a0,-1
    800026fa:	98dff0ef          	jal	80002086 <kexit>
  if(which_dev == 2)
    800026fe:	4789                	li	a5,2
    80002700:	faf919e3          	bne	s2,a5,800026b2 <usertrap+0xb6>
    yield();
    80002704:	84bff0ef          	jal	80001f4e <yield>
    80002708:	b76d                	j	800026b2 <usertrap+0xb6>

000000008000270a <kerneltrap>:
{
    8000270a:	7179                	addi	sp,sp,-48
    8000270c:	f406                	sd	ra,40(sp)
    8000270e:	f022                	sd	s0,32(sp)
    80002710:	ec26                	sd	s1,24(sp)
    80002712:	e84a                	sd	s2,16(sp)
    80002714:	e44e                	sd	s3,8(sp)
    80002716:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002718:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000271c:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002720:	142027f3          	csrr	a5,scause
    80002724:	89be                	mv	s3,a5
  if((sstatus & SSTATUS_SPP) == 0)
    80002726:	1004f793          	andi	a5,s1,256
    8000272a:	c795                	beqz	a5,80002756 <kerneltrap+0x4c>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000272c:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002730:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    80002732:	eb85                	bnez	a5,80002762 <kerneltrap+0x58>
  if((which_dev = devintr()) == 0){
    80002734:	e53ff0ef          	jal	80002586 <devintr>
    80002738:	c91d                	beqz	a0,8000276e <kerneltrap+0x64>
  if(which_dev == 2 && myproc() != 0)
    8000273a:	4789                	li	a5,2
    8000273c:	04f50a63          	beq	a0,a5,80002790 <kerneltrap+0x86>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002740:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002744:	10049073          	csrw	sstatus,s1
}
    80002748:	70a2                	ld	ra,40(sp)
    8000274a:	7402                	ld	s0,32(sp)
    8000274c:	64e2                	ld	s1,24(sp)
    8000274e:	6942                	ld	s2,16(sp)
    80002750:	69a2                	ld	s3,8(sp)
    80002752:	6145                	addi	sp,sp,48
    80002754:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80002756:	00005517          	auipc	a0,0x5
    8000275a:	b9a50513          	addi	a0,a0,-1126 # 800072f0 <etext+0x2f0>
    8000275e:	8f8fe0ef          	jal	80000856 <panic>
    panic("kerneltrap: interrupts enabled");
    80002762:	00005517          	auipc	a0,0x5
    80002766:	bb650513          	addi	a0,a0,-1098 # 80007318 <etext+0x318>
    8000276a:	8ecfe0ef          	jal	80000856 <panic>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    8000276e:	14102673          	csrr	a2,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002772:	143026f3          	csrr	a3,stval
    printf("scause=0x%lx sepc=0x%lx stval=0x%lx\n", scause, r_sepc(), r_stval());
    80002776:	85ce                	mv	a1,s3
    80002778:	00005517          	auipc	a0,0x5
    8000277c:	bc050513          	addi	a0,a0,-1088 # 80007338 <etext+0x338>
    80002780:	dadfd0ef          	jal	8000052c <printf>
    panic("kerneltrap");
    80002784:	00005517          	auipc	a0,0x5
    80002788:	bdc50513          	addi	a0,a0,-1060 # 80007360 <etext+0x360>
    8000278c:	8cafe0ef          	jal	80000856 <panic>
  if(which_dev == 2 && myproc() != 0)
    80002790:	9d4ff0ef          	jal	80001964 <myproc>
    80002794:	d555                	beqz	a0,80002740 <kerneltrap+0x36>
    yield();
    80002796:	fb8ff0ef          	jal	80001f4e <yield>
    8000279a:	b75d                	j	80002740 <kerneltrap+0x36>

000000008000279c <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    8000279c:	1101                	addi	sp,sp,-32
    8000279e:	ec06                	sd	ra,24(sp)
    800027a0:	e822                	sd	s0,16(sp)
    800027a2:	e426                	sd	s1,8(sp)
    800027a4:	1000                	addi	s0,sp,32
    800027a6:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    800027a8:	9bcff0ef          	jal	80001964 <myproc>
  switch (n) {
    800027ac:	4795                	li	a5,5
    800027ae:	0497e163          	bltu	a5,s1,800027f0 <argraw+0x54>
    800027b2:	048a                	slli	s1,s1,0x2
    800027b4:	00005717          	auipc	a4,0x5
    800027b8:	fdc70713          	addi	a4,a4,-36 # 80007790 <states.0+0x30>
    800027bc:	94ba                	add	s1,s1,a4
    800027be:	409c                	lw	a5,0(s1)
    800027c0:	97ba                	add	a5,a5,a4
    800027c2:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    800027c4:	6d3c                	ld	a5,88(a0)
    800027c6:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    800027c8:	60e2                	ld	ra,24(sp)
    800027ca:	6442                	ld	s0,16(sp)
    800027cc:	64a2                	ld	s1,8(sp)
    800027ce:	6105                	addi	sp,sp,32
    800027d0:	8082                	ret
    return p->trapframe->a1;
    800027d2:	6d3c                	ld	a5,88(a0)
    800027d4:	7fa8                	ld	a0,120(a5)
    800027d6:	bfcd                	j	800027c8 <argraw+0x2c>
    return p->trapframe->a2;
    800027d8:	6d3c                	ld	a5,88(a0)
    800027da:	63c8                	ld	a0,128(a5)
    800027dc:	b7f5                	j	800027c8 <argraw+0x2c>
    return p->trapframe->a3;
    800027de:	6d3c                	ld	a5,88(a0)
    800027e0:	67c8                	ld	a0,136(a5)
    800027e2:	b7dd                	j	800027c8 <argraw+0x2c>
    return p->trapframe->a4;
    800027e4:	6d3c                	ld	a5,88(a0)
    800027e6:	6bc8                	ld	a0,144(a5)
    800027e8:	b7c5                	j	800027c8 <argraw+0x2c>
    return p->trapframe->a5;
    800027ea:	6d3c                	ld	a5,88(a0)
    800027ec:	6fc8                	ld	a0,152(a5)
    800027ee:	bfe9                	j	800027c8 <argraw+0x2c>
  panic("argraw");
    800027f0:	00005517          	auipc	a0,0x5
    800027f4:	b8050513          	addi	a0,a0,-1152 # 80007370 <etext+0x370>
    800027f8:	85efe0ef          	jal	80000856 <panic>

00000000800027fc <fetchaddr>:
{
    800027fc:	1101                	addi	sp,sp,-32
    800027fe:	ec06                	sd	ra,24(sp)
    80002800:	e822                	sd	s0,16(sp)
    80002802:	e426                	sd	s1,8(sp)
    80002804:	e04a                	sd	s2,0(sp)
    80002806:	1000                	addi	s0,sp,32
    80002808:	84aa                	mv	s1,a0
    8000280a:	892e                	mv	s2,a1
  struct proc *p = myproc();
    8000280c:	958ff0ef          	jal	80001964 <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    80002810:	653c                	ld	a5,72(a0)
    80002812:	02f4f663          	bgeu	s1,a5,8000283e <fetchaddr+0x42>
    80002816:	00848713          	addi	a4,s1,8
    8000281a:	02e7e463          	bltu	a5,a4,80002842 <fetchaddr+0x46>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    8000281e:	46a1                	li	a3,8
    80002820:	8626                	mv	a2,s1
    80002822:	85ca                	mv	a1,s2
    80002824:	6928                	ld	a0,80(a0)
    80002826:	f23fe0ef          	jal	80001748 <copyin>
    8000282a:	00a03533          	snez	a0,a0
    8000282e:	40a0053b          	negw	a0,a0
}
    80002832:	60e2                	ld	ra,24(sp)
    80002834:	6442                	ld	s0,16(sp)
    80002836:	64a2                	ld	s1,8(sp)
    80002838:	6902                	ld	s2,0(sp)
    8000283a:	6105                	addi	sp,sp,32
    8000283c:	8082                	ret
    return -1;
    8000283e:	557d                	li	a0,-1
    80002840:	bfcd                	j	80002832 <fetchaddr+0x36>
    80002842:	557d                	li	a0,-1
    80002844:	b7fd                	j	80002832 <fetchaddr+0x36>

0000000080002846 <fetchstr>:
{
    80002846:	7179                	addi	sp,sp,-48
    80002848:	f406                	sd	ra,40(sp)
    8000284a:	f022                	sd	s0,32(sp)
    8000284c:	ec26                	sd	s1,24(sp)
    8000284e:	e84a                	sd	s2,16(sp)
    80002850:	e44e                	sd	s3,8(sp)
    80002852:	1800                	addi	s0,sp,48
    80002854:	89aa                	mv	s3,a0
    80002856:	84ae                	mv	s1,a1
    80002858:	8932                	mv	s2,a2
  struct proc *p = myproc();
    8000285a:	90aff0ef          	jal	80001964 <myproc>
  if(copyinstr(p->pagetable, buf, addr, max) < 0)
    8000285e:	86ca                	mv	a3,s2
    80002860:	864e                	mv	a2,s3
    80002862:	85a6                	mv	a1,s1
    80002864:	6928                	ld	a0,80(a0)
    80002866:	cc9fe0ef          	jal	8000152e <copyinstr>
    8000286a:	00054c63          	bltz	a0,80002882 <fetchstr+0x3c>
  return strlen(buf);
    8000286e:	8526                	mv	a0,s1
    80002870:	e44fe0ef          	jal	80000eb4 <strlen>
}
    80002874:	70a2                	ld	ra,40(sp)
    80002876:	7402                	ld	s0,32(sp)
    80002878:	64e2                	ld	s1,24(sp)
    8000287a:	6942                	ld	s2,16(sp)
    8000287c:	69a2                	ld	s3,8(sp)
    8000287e:	6145                	addi	sp,sp,48
    80002880:	8082                	ret
    return -1;
    80002882:	557d                	li	a0,-1
    80002884:	bfc5                	j	80002874 <fetchstr+0x2e>

0000000080002886 <argint>:

// Fetch the nth 32-bit system call argument.
void
argint(int n, int *ip)
{
    80002886:	1101                	addi	sp,sp,-32
    80002888:	ec06                	sd	ra,24(sp)
    8000288a:	e822                	sd	s0,16(sp)
    8000288c:	e426                	sd	s1,8(sp)
    8000288e:	1000                	addi	s0,sp,32
    80002890:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002892:	f0bff0ef          	jal	8000279c <argraw>
    80002896:	c088                	sw	a0,0(s1)
}
    80002898:	60e2                	ld	ra,24(sp)
    8000289a:	6442                	ld	s0,16(sp)
    8000289c:	64a2                	ld	s1,8(sp)
    8000289e:	6105                	addi	sp,sp,32
    800028a0:	8082                	ret

00000000800028a2 <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void
argaddr(int n, uint64 *ip)
{
    800028a2:	1101                	addi	sp,sp,-32
    800028a4:	ec06                	sd	ra,24(sp)
    800028a6:	e822                	sd	s0,16(sp)
    800028a8:	e426                	sd	s1,8(sp)
    800028aa:	1000                	addi	s0,sp,32
    800028ac:	84ae                	mv	s1,a1
  *ip = argraw(n);
    800028ae:	eefff0ef          	jal	8000279c <argraw>
    800028b2:	e088                	sd	a0,0(s1)
}
    800028b4:	60e2                	ld	ra,24(sp)
    800028b6:	6442                	ld	s0,16(sp)
    800028b8:	64a2                	ld	s1,8(sp)
    800028ba:	6105                	addi	sp,sp,32
    800028bc:	8082                	ret

00000000800028be <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    800028be:	1101                	addi	sp,sp,-32
    800028c0:	ec06                	sd	ra,24(sp)
    800028c2:	e822                	sd	s0,16(sp)
    800028c4:	e426                	sd	s1,8(sp)
    800028c6:	e04a                	sd	s2,0(sp)
    800028c8:	1000                	addi	s0,sp,32
    800028ca:	892e                	mv	s2,a1
    800028cc:	84b2                	mv	s1,a2
  *ip = argraw(n);
    800028ce:	ecfff0ef          	jal	8000279c <argraw>
  uint64 addr;
  argaddr(n, &addr);
  return fetchstr(addr, buf, max);
    800028d2:	8626                	mv	a2,s1
    800028d4:	85ca                	mv	a1,s2
    800028d6:	f71ff0ef          	jal	80002846 <fetchstr>
}
    800028da:	60e2                	ld	ra,24(sp)
    800028dc:	6442                	ld	s0,16(sp)
    800028de:	64a2                	ld	s1,8(sp)
    800028e0:	6902                	ld	s2,0(sp)
    800028e2:	6105                	addi	sp,sp,32
    800028e4:	8082                	ret

00000000800028e6 <syscall>:

};

void
syscall(void)
{
    800028e6:	1101                	addi	sp,sp,-32
    800028e8:	ec06                	sd	ra,24(sp)
    800028ea:	e822                	sd	s0,16(sp)
    800028ec:	e426                	sd	s1,8(sp)
    800028ee:	e04a                	sd	s2,0(sp)
    800028f0:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    800028f2:	872ff0ef          	jal	80001964 <myproc>
    800028f6:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    800028f8:	05853903          	ld	s2,88(a0)
    800028fc:	0a893783          	ld	a5,168(s2)
    80002900:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80002904:	37fd                	addiw	a5,a5,-1
    80002906:	4759                	li	a4,22
    80002908:	00f76f63          	bltu	a4,a5,80002926 <syscall+0x40>
    8000290c:	00369713          	slli	a4,a3,0x3
    80002910:	00005797          	auipc	a5,0x5
    80002914:	e9878793          	addi	a5,a5,-360 # 800077a8 <syscalls>
    80002918:	97ba                	add	a5,a5,a4
    8000291a:	639c                	ld	a5,0(a5)
    8000291c:	c789                	beqz	a5,80002926 <syscall+0x40>
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    p->trapframe->a0 = syscalls[num]();
    8000291e:	9782                	jalr	a5
    80002920:	06a93823          	sd	a0,112(s2)
    80002924:	a829                	j	8000293e <syscall+0x58>
  } else {
    printf("%d %s: unknown sys call %d\n",
    80002926:	15848613          	addi	a2,s1,344
    8000292a:	588c                	lw	a1,48(s1)
    8000292c:	00005517          	auipc	a0,0x5
    80002930:	a4c50513          	addi	a0,a0,-1460 # 80007378 <etext+0x378>
    80002934:	bf9fd0ef          	jal	8000052c <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80002938:	6cbc                	ld	a5,88(s1)
    8000293a:	577d                	li	a4,-1
    8000293c:	fbb8                	sd	a4,112(a5)
  }
}
    8000293e:	60e2                	ld	ra,24(sp)
    80002940:	6442                	ld	s0,16(sp)
    80002942:	64a2                	ld	s1,8(sp)
    80002944:	6902                	ld	s2,0(sp)
    80002946:	6105                	addi	sp,sp,32
    80002948:	8082                	ret

000000008000294a <sys_exit>:
#include "proc.h"
#include "vm.h"

uint64
sys_exit(void)
{
    8000294a:	1101                	addi	sp,sp,-32
    8000294c:	ec06                	sd	ra,24(sp)
    8000294e:	e822                	sd	s0,16(sp)
    80002950:	1000                	addi	s0,sp,32
  int n;
  argint(0, &n);
    80002952:	fec40593          	addi	a1,s0,-20
    80002956:	4501                	li	a0,0
    80002958:	f2fff0ef          	jal	80002886 <argint>
  kexit(n);
    8000295c:	fec42503          	lw	a0,-20(s0)
    80002960:	f26ff0ef          	jal	80002086 <kexit>
  return 0;  // not reached
}
    80002964:	4501                	li	a0,0
    80002966:	60e2                	ld	ra,24(sp)
    80002968:	6442                	ld	s0,16(sp)
    8000296a:	6105                	addi	sp,sp,32
    8000296c:	8082                	ret

000000008000296e <sys_getpid>:

uint64
sys_getpid(void)
{
    8000296e:	1141                	addi	sp,sp,-16
    80002970:	e406                	sd	ra,8(sp)
    80002972:	e022                	sd	s0,0(sp)
    80002974:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80002976:	feffe0ef          	jal	80001964 <myproc>
}
    8000297a:	5908                	lw	a0,48(a0)
    8000297c:	60a2                	ld	ra,8(sp)
    8000297e:	6402                	ld	s0,0(sp)
    80002980:	0141                	addi	sp,sp,16
    80002982:	8082                	ret

0000000080002984 <sys_fork>:

uint64
sys_fork(void)
{
    80002984:	1141                	addi	sp,sp,-16
    80002986:	e406                	sd	ra,8(sp)
    80002988:	e022                	sd	s0,0(sp)
    8000298a:	0800                	addi	s0,sp,16
  return kfork();
    8000298c:	b40ff0ef          	jal	80001ccc <kfork>
}
    80002990:	60a2                	ld	ra,8(sp)
    80002992:	6402                	ld	s0,0(sp)
    80002994:	0141                	addi	sp,sp,16
    80002996:	8082                	ret

0000000080002998 <sys_wait>:

uint64
sys_wait(void)
{
    80002998:	1101                	addi	sp,sp,-32
    8000299a:	ec06                	sd	ra,24(sp)
    8000299c:	e822                	sd	s0,16(sp)
    8000299e:	1000                	addi	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    800029a0:	fe840593          	addi	a1,s0,-24
    800029a4:	4501                	li	a0,0
    800029a6:	efdff0ef          	jal	800028a2 <argaddr>
  return kwait(p);
    800029aa:	fe843503          	ld	a0,-24(s0)
    800029ae:	833ff0ef          	jal	800021e0 <kwait>
}
    800029b2:	60e2                	ld	ra,24(sp)
    800029b4:	6442                	ld	s0,16(sp)
    800029b6:	6105                	addi	sp,sp,32
    800029b8:	8082                	ret

00000000800029ba <sys_sbrk>:

uint64
sys_sbrk(void)
{
    800029ba:	7179                	addi	sp,sp,-48
    800029bc:	f406                	sd	ra,40(sp)
    800029be:	f022                	sd	s0,32(sp)
    800029c0:	ec26                	sd	s1,24(sp)
    800029c2:	1800                	addi	s0,sp,48
  uint64 addr;
  int t;
  int n;

  argint(0, &n);
    800029c4:	fd840593          	addi	a1,s0,-40
    800029c8:	4501                	li	a0,0
    800029ca:	ebdff0ef          	jal	80002886 <argint>
  argint(1, &t);
    800029ce:	fdc40593          	addi	a1,s0,-36
    800029d2:	4505                	li	a0,1
    800029d4:	eb3ff0ef          	jal	80002886 <argint>
  addr = myproc()->sz;
    800029d8:	f8dfe0ef          	jal	80001964 <myproc>
    800029dc:	6524                	ld	s1,72(a0)

  if(t == SBRK_EAGER || n < 0) {
    800029de:	fdc42703          	lw	a4,-36(s0)
    800029e2:	4785                	li	a5,1
    800029e4:	02f70763          	beq	a4,a5,80002a12 <sys_sbrk+0x58>
    800029e8:	fd842783          	lw	a5,-40(s0)
    800029ec:	0207c363          	bltz	a5,80002a12 <sys_sbrk+0x58>
    }
  } else {
    // Lazily allocate memory for this process: increase its memory
    // size but don't allocate memory. If the processes uses the
    // memory, vmfault() will allocate it.
    if(addr + n < addr)
    800029f0:	97a6                	add	a5,a5,s1
      return -1;
    if(addr + n > TRAPFRAME)
    800029f2:	02000737          	lui	a4,0x2000
    800029f6:	177d                	addi	a4,a4,-1 # 1ffffff <_entry-0x7e000001>
    800029f8:	0736                	slli	a4,a4,0xd
    800029fa:	02f76a63          	bltu	a4,a5,80002a2e <sys_sbrk+0x74>
    800029fe:	0297e863          	bltu	a5,s1,80002a2e <sys_sbrk+0x74>
      return -1;
    myproc()->sz += n;
    80002a02:	f63fe0ef          	jal	80001964 <myproc>
    80002a06:	fd842703          	lw	a4,-40(s0)
    80002a0a:	653c                	ld	a5,72(a0)
    80002a0c:	97ba                	add	a5,a5,a4
    80002a0e:	e53c                	sd	a5,72(a0)
    80002a10:	a039                	j	80002a1e <sys_sbrk+0x64>
    if(growproc(n) < 0) {
    80002a12:	fd842503          	lw	a0,-40(s0)
    80002a16:	a54ff0ef          	jal	80001c6a <growproc>
    80002a1a:	00054863          	bltz	a0,80002a2a <sys_sbrk+0x70>
  }
  return addr;
}
    80002a1e:	8526                	mv	a0,s1
    80002a20:	70a2                	ld	ra,40(sp)
    80002a22:	7402                	ld	s0,32(sp)
    80002a24:	64e2                	ld	s1,24(sp)
    80002a26:	6145                	addi	sp,sp,48
    80002a28:	8082                	ret
      return -1;
    80002a2a:	54fd                	li	s1,-1
    80002a2c:	bfcd                	j	80002a1e <sys_sbrk+0x64>
      return -1;
    80002a2e:	54fd                	li	s1,-1
    80002a30:	b7fd                	j	80002a1e <sys_sbrk+0x64>

0000000080002a32 <sys_pause>:

uint64
sys_pause(void)
{
    80002a32:	7139                	addi	sp,sp,-64
    80002a34:	fc06                	sd	ra,56(sp)
    80002a36:	f822                	sd	s0,48(sp)
    80002a38:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    80002a3a:	fcc40593          	addi	a1,s0,-52
    80002a3e:	4501                	li	a0,0
    80002a40:	e47ff0ef          	jal	80002886 <argint>
  if(n < 0)
    80002a44:	fcc42783          	lw	a5,-52(s0)
    80002a48:	0607c863          	bltz	a5,80002ab8 <sys_pause+0x86>
    n = 0;
  acquire(&tickslock);
    80002a4c:	00016517          	auipc	a0,0x16
    80002a50:	a8c50513          	addi	a0,a0,-1396 # 800184d8 <tickslock>
    80002a54:	a06fe0ef          	jal	80000c5a <acquire>
  ticks0 = ticks;
  while(ticks - ticks0 < n){
    80002a58:	fcc42783          	lw	a5,-52(s0)
    80002a5c:	c3b9                	beqz	a5,80002aa2 <sys_pause+0x70>
    80002a5e:	f426                	sd	s1,40(sp)
    80002a60:	f04a                	sd	s2,32(sp)
    80002a62:	ec4e                	sd	s3,24(sp)
  ticks0 = ticks;
    80002a64:	00008997          	auipc	s3,0x8
    80002a68:	b049a983          	lw	s3,-1276(s3) # 8000a568 <ticks>
    if(killed(myproc())){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80002a6c:	00016917          	auipc	s2,0x16
    80002a70:	a6c90913          	addi	s2,s2,-1428 # 800184d8 <tickslock>
    80002a74:	00008497          	auipc	s1,0x8
    80002a78:	af448493          	addi	s1,s1,-1292 # 8000a568 <ticks>
    if(killed(myproc())){
    80002a7c:	ee9fe0ef          	jal	80001964 <myproc>
    80002a80:	f36ff0ef          	jal	800021b6 <killed>
    80002a84:	ed0d                	bnez	a0,80002abe <sys_pause+0x8c>
    sleep(&ticks, &tickslock);
    80002a86:	85ca                	mv	a1,s2
    80002a88:	8526                	mv	a0,s1
    80002a8a:	cf0ff0ef          	jal	80001f7a <sleep>
  while(ticks - ticks0 < n){
    80002a8e:	409c                	lw	a5,0(s1)
    80002a90:	413787bb          	subw	a5,a5,s3
    80002a94:	fcc42703          	lw	a4,-52(s0)
    80002a98:	fee7e2e3          	bltu	a5,a4,80002a7c <sys_pause+0x4a>
    80002a9c:	74a2                	ld	s1,40(sp)
    80002a9e:	7902                	ld	s2,32(sp)
    80002aa0:	69e2                	ld	s3,24(sp)
  }
  release(&tickslock);
    80002aa2:	00016517          	auipc	a0,0x16
    80002aa6:	a3650513          	addi	a0,a0,-1482 # 800184d8 <tickslock>
    80002aaa:	a44fe0ef          	jal	80000cee <release>
  return 0;
    80002aae:	4501                	li	a0,0
}
    80002ab0:	70e2                	ld	ra,56(sp)
    80002ab2:	7442                	ld	s0,48(sp)
    80002ab4:	6121                	addi	sp,sp,64
    80002ab6:	8082                	ret
    n = 0;
    80002ab8:	fc042623          	sw	zero,-52(s0)
    80002abc:	bf41                	j	80002a4c <sys_pause+0x1a>
      release(&tickslock);
    80002abe:	00016517          	auipc	a0,0x16
    80002ac2:	a1a50513          	addi	a0,a0,-1510 # 800184d8 <tickslock>
    80002ac6:	a28fe0ef          	jal	80000cee <release>
      return -1;
    80002aca:	557d                	li	a0,-1
    80002acc:	74a2                	ld	s1,40(sp)
    80002ace:	7902                	ld	s2,32(sp)
    80002ad0:	69e2                	ld	s3,24(sp)
    80002ad2:	bff9                	j	80002ab0 <sys_pause+0x7e>

0000000080002ad4 <sys_kill>:

uint64
sys_kill(void)
{
    80002ad4:	1101                	addi	sp,sp,-32
    80002ad6:	ec06                	sd	ra,24(sp)
    80002ad8:	e822                	sd	s0,16(sp)
    80002ada:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    80002adc:	fec40593          	addi	a1,s0,-20
    80002ae0:	4501                	li	a0,0
    80002ae2:	da5ff0ef          	jal	80002886 <argint>
  return kkill(pid);
    80002ae6:	fec42503          	lw	a0,-20(s0)
    80002aea:	e42ff0ef          	jal	8000212c <kkill>
}
    80002aee:	60e2                	ld	ra,24(sp)
    80002af0:	6442                	ld	s0,16(sp)
    80002af2:	6105                	addi	sp,sp,32
    80002af4:	8082                	ret

0000000080002af6 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80002af6:	1101                	addi	sp,sp,-32
    80002af8:	ec06                	sd	ra,24(sp)
    80002afa:	e822                	sd	s0,16(sp)
    80002afc:	e426                	sd	s1,8(sp)
    80002afe:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80002b00:	00016517          	auipc	a0,0x16
    80002b04:	9d850513          	addi	a0,a0,-1576 # 800184d8 <tickslock>
    80002b08:	952fe0ef          	jal	80000c5a <acquire>
  xticks = ticks;
    80002b0c:	00008797          	auipc	a5,0x8
    80002b10:	a5c7a783          	lw	a5,-1444(a5) # 8000a568 <ticks>
    80002b14:	84be                	mv	s1,a5
  release(&tickslock);
    80002b16:	00016517          	auipc	a0,0x16
    80002b1a:	9c250513          	addi	a0,a0,-1598 # 800184d8 <tickslock>
    80002b1e:	9d0fe0ef          	jal	80000cee <release>
  return xticks;
}
    80002b22:	02049513          	slli	a0,s1,0x20
    80002b26:	9101                	srli	a0,a0,0x20
    80002b28:	60e2                	ld	ra,24(sp)
    80002b2a:	6442                	ld	s0,16(sp)
    80002b2c:	64a2                	ld	s1,8(sp)
    80002b2e:	6105                	addi	sp,sp,32
    80002b30:	8082                	ret

0000000080002b32 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80002b32:	7179                	addi	sp,sp,-48
    80002b34:	f406                	sd	ra,40(sp)
    80002b36:	f022                	sd	s0,32(sp)
    80002b38:	ec26                	sd	s1,24(sp)
    80002b3a:	e84a                	sd	s2,16(sp)
    80002b3c:	e44e                	sd	s3,8(sp)
    80002b3e:	e052                	sd	s4,0(sp)
    80002b40:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80002b42:	00005597          	auipc	a1,0x5
    80002b46:	85658593          	addi	a1,a1,-1962 # 80007398 <etext+0x398>
    80002b4a:	00016517          	auipc	a0,0x16
    80002b4e:	9a650513          	addi	a0,a0,-1626 # 800184f0 <bcache>
    80002b52:	87efe0ef          	jal	80000bd0 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80002b56:	0001e797          	auipc	a5,0x1e
    80002b5a:	99a78793          	addi	a5,a5,-1638 # 800204f0 <bcache+0x8000>
    80002b5e:	0001e717          	auipc	a4,0x1e
    80002b62:	bfa70713          	addi	a4,a4,-1030 # 80020758 <bcache+0x8268>
    80002b66:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80002b6a:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002b6e:	00016497          	auipc	s1,0x16
    80002b72:	99a48493          	addi	s1,s1,-1638 # 80018508 <bcache+0x18>
    b->next = bcache.head.next;
    80002b76:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80002b78:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80002b7a:	00005a17          	auipc	s4,0x5
    80002b7e:	826a0a13          	addi	s4,s4,-2010 # 800073a0 <etext+0x3a0>
    b->next = bcache.head.next;
    80002b82:	2b893783          	ld	a5,696(s2)
    80002b86:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80002b88:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80002b8c:	85d2                	mv	a1,s4
    80002b8e:	01048513          	addi	a0,s1,16
    80002b92:	366010ef          	jal	80003ef8 <initsleeplock>
    bcache.head.next->prev = b;
    80002b96:	2b893783          	ld	a5,696(s2)
    80002b9a:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80002b9c:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002ba0:	45848493          	addi	s1,s1,1112
    80002ba4:	fd349fe3          	bne	s1,s3,80002b82 <binit+0x50>
  }
}
    80002ba8:	70a2                	ld	ra,40(sp)
    80002baa:	7402                	ld	s0,32(sp)
    80002bac:	64e2                	ld	s1,24(sp)
    80002bae:	6942                	ld	s2,16(sp)
    80002bb0:	69a2                	ld	s3,8(sp)
    80002bb2:	6a02                	ld	s4,0(sp)
    80002bb4:	6145                	addi	sp,sp,48
    80002bb6:	8082                	ret

0000000080002bb8 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    80002bb8:	7179                	addi	sp,sp,-48
    80002bba:	f406                	sd	ra,40(sp)
    80002bbc:	f022                	sd	s0,32(sp)
    80002bbe:	ec26                	sd	s1,24(sp)
    80002bc0:	e84a                	sd	s2,16(sp)
    80002bc2:	e44e                	sd	s3,8(sp)
    80002bc4:	1800                	addi	s0,sp,48
    80002bc6:	892a                	mv	s2,a0
    80002bc8:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    80002bca:	00016517          	auipc	a0,0x16
    80002bce:	92650513          	addi	a0,a0,-1754 # 800184f0 <bcache>
    80002bd2:	888fe0ef          	jal	80000c5a <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    80002bd6:	0001e497          	auipc	s1,0x1e
    80002bda:	bd24b483          	ld	s1,-1070(s1) # 800207a8 <bcache+0x82b8>
    80002bde:	0001e797          	auipc	a5,0x1e
    80002be2:	b7a78793          	addi	a5,a5,-1158 # 80020758 <bcache+0x8268>
    80002be6:	04f48563          	beq	s1,a5,80002c30 <bread+0x78>
    80002bea:	873e                	mv	a4,a5
    80002bec:	a021                	j	80002bf4 <bread+0x3c>
    80002bee:	68a4                	ld	s1,80(s1)
    80002bf0:	04e48063          	beq	s1,a4,80002c30 <bread+0x78>
    if(b->dev == dev && b->blockno == blockno){
    80002bf4:	449c                	lw	a5,8(s1)
    80002bf6:	ff279ce3          	bne	a5,s2,80002bee <bread+0x36>
    80002bfa:	44dc                	lw	a5,12(s1)
    80002bfc:	ff3799e3          	bne	a5,s3,80002bee <bread+0x36>
      b->refcnt++;
    80002c00:	40bc                	lw	a5,64(s1)
    80002c02:	2785                	addiw	a5,a5,1
    80002c04:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002c06:	00016517          	auipc	a0,0x16
    80002c0a:	8ea50513          	addi	a0,a0,-1814 # 800184f0 <bcache>
    80002c0e:	8e0fe0ef          	jal	80000cee <release>
      acquiresleep(&b->lock);
    80002c12:	01048513          	addi	a0,s1,16
    80002c16:	318010ef          	jal	80003f2e <acquiresleep>
      fslog_push(FS_BGET_HIT, 0, blockno, 0, "BCACHE");
    80002c1a:	00004717          	auipc	a4,0x4
    80002c1e:	78e70713          	addi	a4,a4,1934 # 800073a8 <etext+0x3a8>
    80002c22:	4681                	li	a3,0
    80002c24:	864e                	mv	a2,s3
    80002c26:	4581                	li	a1,0
    80002c28:	4519                	li	a0,6
    80002c2a:	1d6030ef          	jal	80005e00 <fslog_push>
      return b;
    80002c2e:	a09d                	j	80002c94 <bread+0xdc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002c30:	0001e497          	auipc	s1,0x1e
    80002c34:	b704b483          	ld	s1,-1168(s1) # 800207a0 <bcache+0x82b0>
    80002c38:	0001e797          	auipc	a5,0x1e
    80002c3c:	b2078793          	addi	a5,a5,-1248 # 80020758 <bcache+0x8268>
    80002c40:	00f48863          	beq	s1,a5,80002c50 <bread+0x98>
    80002c44:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    80002c46:	40bc                	lw	a5,64(s1)
    80002c48:	cb91                	beqz	a5,80002c5c <bread+0xa4>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002c4a:	64a4                	ld	s1,72(s1)
    80002c4c:	fee49de3          	bne	s1,a4,80002c46 <bread+0x8e>
  panic("bget: no buffers");
    80002c50:	00004517          	auipc	a0,0x4
    80002c54:	76050513          	addi	a0,a0,1888 # 800073b0 <etext+0x3b0>
    80002c58:	bfffd0ef          	jal	80000856 <panic>
      b->dev = dev;
    80002c5c:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    80002c60:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    80002c64:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80002c68:	4785                	li	a5,1
    80002c6a:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002c6c:	00016517          	auipc	a0,0x16
    80002c70:	88450513          	addi	a0,a0,-1916 # 800184f0 <bcache>
    80002c74:	87afe0ef          	jal	80000cee <release>
      acquiresleep(&b->lock);
    80002c78:	01048513          	addi	a0,s1,16
    80002c7c:	2b2010ef          	jal	80003f2e <acquiresleep>
      fslog_push(FS_BGET_MISS, 0, blockno, 0, "BCACHE");
    80002c80:	00004717          	auipc	a4,0x4
    80002c84:	72870713          	addi	a4,a4,1832 # 800073a8 <etext+0x3a8>
    80002c88:	4681                	li	a3,0
    80002c8a:	864e                	mv	a2,s3
    80002c8c:	4581                	li	a1,0
    80002c8e:	451d                	li	a0,7
    80002c90:	170030ef          	jal	80005e00 <fslog_push>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    80002c94:	409c                	lw	a5,0(s1)
    80002c96:	cb89                	beqz	a5,80002ca8 <bread+0xf0>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80002c98:	8526                	mv	a0,s1
    80002c9a:	70a2                	ld	ra,40(sp)
    80002c9c:	7402                	ld	s0,32(sp)
    80002c9e:	64e2                	ld	s1,24(sp)
    80002ca0:	6942                	ld	s2,16(sp)
    80002ca2:	69a2                	ld	s3,8(sp)
    80002ca4:	6145                	addi	sp,sp,48
    80002ca6:	8082                	ret
    virtio_disk_rw(b, 0);
    80002ca8:	4581                	li	a1,0
    80002caa:	8526                	mv	a0,s1
    80002cac:	335020ef          	jal	800057e0 <virtio_disk_rw>
    b->valid = 1;
    80002cb0:	4785                	li	a5,1
    80002cb2:	c09c                	sw	a5,0(s1)
  return b;
    80002cb4:	b7d5                	j	80002c98 <bread+0xe0>

0000000080002cb6 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    80002cb6:	1101                	addi	sp,sp,-32
    80002cb8:	ec06                	sd	ra,24(sp)
    80002cba:	e822                	sd	s0,16(sp)
    80002cbc:	e426                	sd	s1,8(sp)
    80002cbe:	1000                	addi	s0,sp,32
    80002cc0:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80002cc2:	0541                	addi	a0,a0,16
    80002cc4:	2e8010ef          	jal	80003fac <holdingsleep>
    80002cc8:	c911                	beqz	a0,80002cdc <bwrite+0x26>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    80002cca:	4585                	li	a1,1
    80002ccc:	8526                	mv	a0,s1
    80002cce:	313020ef          	jal	800057e0 <virtio_disk_rw>
}
    80002cd2:	60e2                	ld	ra,24(sp)
    80002cd4:	6442                	ld	s0,16(sp)
    80002cd6:	64a2                	ld	s1,8(sp)
    80002cd8:	6105                	addi	sp,sp,32
    80002cda:	8082                	ret
    panic("bwrite");
    80002cdc:	00004517          	auipc	a0,0x4
    80002ce0:	6ec50513          	addi	a0,a0,1772 # 800073c8 <etext+0x3c8>
    80002ce4:	b73fd0ef          	jal	80000856 <panic>

0000000080002ce8 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    80002ce8:	1101                	addi	sp,sp,-32
    80002cea:	ec06                	sd	ra,24(sp)
    80002cec:	e822                	sd	s0,16(sp)
    80002cee:	e426                	sd	s1,8(sp)
    80002cf0:	e04a                	sd	s2,0(sp)
    80002cf2:	1000                	addi	s0,sp,32
    80002cf4:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80002cf6:	01050913          	addi	s2,a0,16
    80002cfa:	854a                	mv	a0,s2
    80002cfc:	2b0010ef          	jal	80003fac <holdingsleep>
    80002d00:	c915                	beqz	a0,80002d34 <brelse+0x4c>
    panic("brelse");

  releasesleep(&b->lock);
    80002d02:	854a                	mv	a0,s2
    80002d04:	270010ef          	jal	80003f74 <releasesleep>

  acquire(&bcache.lock);
    80002d08:	00015517          	auipc	a0,0x15
    80002d0c:	7e850513          	addi	a0,a0,2024 # 800184f0 <bcache>
    80002d10:	f4bfd0ef          	jal	80000c5a <acquire>
  b->refcnt--;
    80002d14:	40bc                	lw	a5,64(s1)
    80002d16:	37fd                	addiw	a5,a5,-1
    80002d18:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    80002d1a:	c39d                	beqz	a5,80002d40 <brelse+0x58>
    bcache.head.next->prev = b;
    bcache.head.next = b;
    fslog_push(FS_BRELEASE, 0, b->blockno, 0, "BCACHE");
  }
  
  release(&bcache.lock);
    80002d1c:	00015517          	auipc	a0,0x15
    80002d20:	7d450513          	addi	a0,a0,2004 # 800184f0 <bcache>
    80002d24:	fcbfd0ef          	jal	80000cee <release>
}
    80002d28:	60e2                	ld	ra,24(sp)
    80002d2a:	6442                	ld	s0,16(sp)
    80002d2c:	64a2                	ld	s1,8(sp)
    80002d2e:	6902                	ld	s2,0(sp)
    80002d30:	6105                	addi	sp,sp,32
    80002d32:	8082                	ret
    panic("brelse");
    80002d34:	00004517          	auipc	a0,0x4
    80002d38:	69c50513          	addi	a0,a0,1692 # 800073d0 <etext+0x3d0>
    80002d3c:	b1bfd0ef          	jal	80000856 <panic>
    b->next->prev = b->prev;
    80002d40:	68b8                	ld	a4,80(s1)
    80002d42:	64bc                	ld	a5,72(s1)
    80002d44:	e73c                	sd	a5,72(a4)
    b->prev->next = b->next;
    80002d46:	68b8                	ld	a4,80(s1)
    80002d48:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    80002d4a:	0001d797          	auipc	a5,0x1d
    80002d4e:	7a678793          	addi	a5,a5,1958 # 800204f0 <bcache+0x8000>
    80002d52:	2b87b703          	ld	a4,696(a5)
    80002d56:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    80002d58:	0001e717          	auipc	a4,0x1e
    80002d5c:	a0070713          	addi	a4,a4,-1536 # 80020758 <bcache+0x8268>
    80002d60:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    80002d62:	2b87b703          	ld	a4,696(a5)
    80002d66:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80002d68:	2a97bc23          	sd	s1,696(a5)
    fslog_push(FS_BRELEASE, 0, b->blockno, 0, "BCACHE");
    80002d6c:	00004717          	auipc	a4,0x4
    80002d70:	63c70713          	addi	a4,a4,1596 # 800073a8 <etext+0x3a8>
    80002d74:	4681                	li	a3,0
    80002d76:	44d0                	lw	a2,12(s1)
    80002d78:	4581                	li	a1,0
    80002d7a:	4521                	li	a0,8
    80002d7c:	084030ef          	jal	80005e00 <fslog_push>
    80002d80:	bf71                	j	80002d1c <brelse+0x34>

0000000080002d82 <bpin>:

void
bpin(struct buf *b) {
    80002d82:	1101                	addi	sp,sp,-32
    80002d84:	ec06                	sd	ra,24(sp)
    80002d86:	e822                	sd	s0,16(sp)
    80002d88:	e426                	sd	s1,8(sp)
    80002d8a:	1000                	addi	s0,sp,32
    80002d8c:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80002d8e:	00015517          	auipc	a0,0x15
    80002d92:	76250513          	addi	a0,a0,1890 # 800184f0 <bcache>
    80002d96:	ec5fd0ef          	jal	80000c5a <acquire>
  b->refcnt++;
    80002d9a:	40bc                	lw	a5,64(s1)
    80002d9c:	2785                	addiw	a5,a5,1
    80002d9e:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80002da0:	00015517          	auipc	a0,0x15
    80002da4:	75050513          	addi	a0,a0,1872 # 800184f0 <bcache>
    80002da8:	f47fd0ef          	jal	80000cee <release>
}
    80002dac:	60e2                	ld	ra,24(sp)
    80002dae:	6442                	ld	s0,16(sp)
    80002db0:	64a2                	ld	s1,8(sp)
    80002db2:	6105                	addi	sp,sp,32
    80002db4:	8082                	ret

0000000080002db6 <bunpin>:

void
bunpin(struct buf *b) {
    80002db6:	1101                	addi	sp,sp,-32
    80002db8:	ec06                	sd	ra,24(sp)
    80002dba:	e822                	sd	s0,16(sp)
    80002dbc:	e426                	sd	s1,8(sp)
    80002dbe:	1000                	addi	s0,sp,32
    80002dc0:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80002dc2:	00015517          	auipc	a0,0x15
    80002dc6:	72e50513          	addi	a0,a0,1838 # 800184f0 <bcache>
    80002dca:	e91fd0ef          	jal	80000c5a <acquire>
  b->refcnt--;
    80002dce:	40bc                	lw	a5,64(s1)
    80002dd0:	37fd                	addiw	a5,a5,-1
    80002dd2:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80002dd4:	00015517          	auipc	a0,0x15
    80002dd8:	71c50513          	addi	a0,a0,1820 # 800184f0 <bcache>
    80002ddc:	f13fd0ef          	jal	80000cee <release>
}
    80002de0:	60e2                	ld	ra,24(sp)
    80002de2:	6442                	ld	s0,16(sp)
    80002de4:	64a2                	ld	s1,8(sp)
    80002de6:	6105                	addi	sp,sp,32
    80002de8:	8082                	ret

0000000080002dea <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    80002dea:	1101                	addi	sp,sp,-32
    80002dec:	ec06                	sd	ra,24(sp)
    80002dee:	e822                	sd	s0,16(sp)
    80002df0:	e426                	sd	s1,8(sp)
    80002df2:	e04a                	sd	s2,0(sp)
    80002df4:	1000                	addi	s0,sp,32
    80002df6:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    80002df8:	00d5d79b          	srliw	a5,a1,0xd
    80002dfc:	0001e597          	auipc	a1,0x1e
    80002e00:	dd05a583          	lw	a1,-560(a1) # 80020bcc <sb+0x1c>
    80002e04:	9dbd                	addw	a1,a1,a5
    80002e06:	db3ff0ef          	jal	80002bb8 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    80002e0a:	0074f713          	andi	a4,s1,7
    80002e0e:	4785                	li	a5,1
    80002e10:	00e797bb          	sllw	a5,a5,a4
  bi = b % BPB;
    80002e14:	14ce                	slli	s1,s1,0x33
  if((bp->data[bi/8] & m) == 0)
    80002e16:	90d9                	srli	s1,s1,0x36
    80002e18:	00950733          	add	a4,a0,s1
    80002e1c:	05874703          	lbu	a4,88(a4)
    80002e20:	00e7f6b3          	and	a3,a5,a4
    80002e24:	c29d                	beqz	a3,80002e4a <bfree+0x60>
    80002e26:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    80002e28:	94aa                	add	s1,s1,a0
    80002e2a:	fff7c793          	not	a5,a5
    80002e2e:	8f7d                	and	a4,a4,a5
    80002e30:	04e48c23          	sb	a4,88(s1)
  log_write(bp);
    80002e34:	000010ef          	jal	80003e34 <log_write>
  brelse(bp);
    80002e38:	854a                	mv	a0,s2
    80002e3a:	eafff0ef          	jal	80002ce8 <brelse>
}
    80002e3e:	60e2                	ld	ra,24(sp)
    80002e40:	6442                	ld	s0,16(sp)
    80002e42:	64a2                	ld	s1,8(sp)
    80002e44:	6902                	ld	s2,0(sp)
    80002e46:	6105                	addi	sp,sp,32
    80002e48:	8082                	ret
    panic("freeing free block");
    80002e4a:	00004517          	auipc	a0,0x4
    80002e4e:	58e50513          	addi	a0,a0,1422 # 800073d8 <etext+0x3d8>
    80002e52:	a05fd0ef          	jal	80000856 <panic>

0000000080002e56 <balloc>:
{
    80002e56:	715d                	addi	sp,sp,-80
    80002e58:	e486                	sd	ra,72(sp)
    80002e5a:	e0a2                	sd	s0,64(sp)
    80002e5c:	fc26                	sd	s1,56(sp)
    80002e5e:	0880                	addi	s0,sp,80
  for(b = 0; b < sb.size; b += BPB){
    80002e60:	0001e797          	auipc	a5,0x1e
    80002e64:	d547a783          	lw	a5,-684(a5) # 80020bb4 <sb+0x4>
    80002e68:	0e078263          	beqz	a5,80002f4c <balloc+0xf6>
    80002e6c:	f84a                	sd	s2,48(sp)
    80002e6e:	f44e                	sd	s3,40(sp)
    80002e70:	f052                	sd	s4,32(sp)
    80002e72:	ec56                	sd	s5,24(sp)
    80002e74:	e85a                	sd	s6,16(sp)
    80002e76:	e45e                	sd	s7,8(sp)
    80002e78:	e062                	sd	s8,0(sp)
    80002e7a:	8baa                	mv	s7,a0
    80002e7c:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    80002e7e:	0001eb17          	auipc	s6,0x1e
    80002e82:	d32b0b13          	addi	s6,s6,-718 # 80020bb0 <sb>
      m = 1 << (bi % 8);
    80002e86:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80002e88:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    80002e8a:	6c09                	lui	s8,0x2
    80002e8c:	a09d                	j	80002ef2 <balloc+0x9c>
        bp->data[bi/8] |= m;  // Mark block in use.
    80002e8e:	97ca                	add	a5,a5,s2
    80002e90:	8e55                	or	a2,a2,a3
    80002e92:	04c78c23          	sb	a2,88(a5)
        log_write(bp);
    80002e96:	854a                	mv	a0,s2
    80002e98:	79d000ef          	jal	80003e34 <log_write>
        brelse(bp);
    80002e9c:	854a                	mv	a0,s2
    80002e9e:	e4bff0ef          	jal	80002ce8 <brelse>
  bp = bread(dev, bno);
    80002ea2:	85a6                	mv	a1,s1
    80002ea4:	855e                	mv	a0,s7
    80002ea6:	d13ff0ef          	jal	80002bb8 <bread>
    80002eaa:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    80002eac:	40000613          	li	a2,1024
    80002eb0:	4581                	li	a1,0
    80002eb2:	05850513          	addi	a0,a0,88
    80002eb6:	e75fd0ef          	jal	80000d2a <memset>
  log_write(bp);
    80002eba:	854a                	mv	a0,s2
    80002ebc:	779000ef          	jal	80003e34 <log_write>
  brelse(bp);
    80002ec0:	854a                	mv	a0,s2
    80002ec2:	e27ff0ef          	jal	80002ce8 <brelse>
}
    80002ec6:	7942                	ld	s2,48(sp)
    80002ec8:	79a2                	ld	s3,40(sp)
    80002eca:	7a02                	ld	s4,32(sp)
    80002ecc:	6ae2                	ld	s5,24(sp)
    80002ece:	6b42                	ld	s6,16(sp)
    80002ed0:	6ba2                	ld	s7,8(sp)
    80002ed2:	6c02                	ld	s8,0(sp)
}
    80002ed4:	8526                	mv	a0,s1
    80002ed6:	60a6                	ld	ra,72(sp)
    80002ed8:	6406                	ld	s0,64(sp)
    80002eda:	74e2                	ld	s1,56(sp)
    80002edc:	6161                	addi	sp,sp,80
    80002ede:	8082                	ret
    brelse(bp);
    80002ee0:	854a                	mv	a0,s2
    80002ee2:	e07ff0ef          	jal	80002ce8 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    80002ee6:	015c0abb          	addw	s5,s8,s5
    80002eea:	004b2783          	lw	a5,4(s6)
    80002eee:	04faf863          	bgeu	s5,a5,80002f3e <balloc+0xe8>
    bp = bread(dev, BBLOCK(b, sb));
    80002ef2:	40dad59b          	sraiw	a1,s5,0xd
    80002ef6:	01cb2783          	lw	a5,28(s6)
    80002efa:	9dbd                	addw	a1,a1,a5
    80002efc:	855e                	mv	a0,s7
    80002efe:	cbbff0ef          	jal	80002bb8 <bread>
    80002f02:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80002f04:	004b2503          	lw	a0,4(s6)
    80002f08:	84d6                	mv	s1,s5
    80002f0a:	4701                	li	a4,0
    80002f0c:	fca4fae3          	bgeu	s1,a0,80002ee0 <balloc+0x8a>
      m = 1 << (bi % 8);
    80002f10:	00777693          	andi	a3,a4,7
    80002f14:	00d996bb          	sllw	a3,s3,a3
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    80002f18:	41f7579b          	sraiw	a5,a4,0x1f
    80002f1c:	01d7d79b          	srliw	a5,a5,0x1d
    80002f20:	9fb9                	addw	a5,a5,a4
    80002f22:	4037d79b          	sraiw	a5,a5,0x3
    80002f26:	00f90633          	add	a2,s2,a5
    80002f2a:	05864603          	lbu	a2,88(a2)
    80002f2e:	00c6f5b3          	and	a1,a3,a2
    80002f32:	ddb1                	beqz	a1,80002e8e <balloc+0x38>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80002f34:	2705                	addiw	a4,a4,1
    80002f36:	2485                	addiw	s1,s1,1
    80002f38:	fd471ae3          	bne	a4,s4,80002f0c <balloc+0xb6>
    80002f3c:	b755                	j	80002ee0 <balloc+0x8a>
    80002f3e:	7942                	ld	s2,48(sp)
    80002f40:	79a2                	ld	s3,40(sp)
    80002f42:	7a02                	ld	s4,32(sp)
    80002f44:	6ae2                	ld	s5,24(sp)
    80002f46:	6b42                	ld	s6,16(sp)
    80002f48:	6ba2                	ld	s7,8(sp)
    80002f4a:	6c02                	ld	s8,0(sp)
  printf("balloc: out of blocks\n");
    80002f4c:	00004517          	auipc	a0,0x4
    80002f50:	4a450513          	addi	a0,a0,1188 # 800073f0 <etext+0x3f0>
    80002f54:	dd8fd0ef          	jal	8000052c <printf>
  return 0;
    80002f58:	4481                	li	s1,0
    80002f5a:	bfad                	j	80002ed4 <balloc+0x7e>

0000000080002f5c <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    80002f5c:	7179                	addi	sp,sp,-48
    80002f5e:	f406                	sd	ra,40(sp)
    80002f60:	f022                	sd	s0,32(sp)
    80002f62:	ec26                	sd	s1,24(sp)
    80002f64:	e84a                	sd	s2,16(sp)
    80002f66:	e44e                	sd	s3,8(sp)
    80002f68:	1800                	addi	s0,sp,48
    80002f6a:	892a                	mv	s2,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    80002f6c:	47ad                	li	a5,11
    80002f6e:	02b7e363          	bltu	a5,a1,80002f94 <bmap+0x38>
    if((addr = ip->addrs[bn]) == 0){
    80002f72:	02059793          	slli	a5,a1,0x20
    80002f76:	01e7d593          	srli	a1,a5,0x1e
    80002f7a:	00b509b3          	add	s3,a0,a1
    80002f7e:	0509a483          	lw	s1,80(s3)
    80002f82:	e0b5                	bnez	s1,80002fe6 <bmap+0x8a>
      addr = balloc(ip->dev);
    80002f84:	4108                	lw	a0,0(a0)
    80002f86:	ed1ff0ef          	jal	80002e56 <balloc>
    80002f8a:	84aa                	mv	s1,a0
      if(addr == 0)
    80002f8c:	cd29                	beqz	a0,80002fe6 <bmap+0x8a>
        return 0;
      ip->addrs[bn] = addr;
    80002f8e:	04a9a823          	sw	a0,80(s3)
    80002f92:	a891                	j	80002fe6 <bmap+0x8a>
    }
    return addr;
  }
  bn -= NDIRECT;
    80002f94:	ff45879b          	addiw	a5,a1,-12
    80002f98:	873e                	mv	a4,a5
    80002f9a:	89be                	mv	s3,a5

  if(bn < NINDIRECT){
    80002f9c:	0ff00793          	li	a5,255
    80002fa0:	06e7e763          	bltu	a5,a4,8000300e <bmap+0xb2>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    80002fa4:	08052483          	lw	s1,128(a0)
    80002fa8:	e891                	bnez	s1,80002fbc <bmap+0x60>
      addr = balloc(ip->dev);
    80002faa:	4108                	lw	a0,0(a0)
    80002fac:	eabff0ef          	jal	80002e56 <balloc>
    80002fb0:	84aa                	mv	s1,a0
      if(addr == 0)
    80002fb2:	c915                	beqz	a0,80002fe6 <bmap+0x8a>
    80002fb4:	e052                	sd	s4,0(sp)
        return 0;
      ip->addrs[NDIRECT] = addr;
    80002fb6:	08a92023          	sw	a0,128(s2)
    80002fba:	a011                	j	80002fbe <bmap+0x62>
    80002fbc:	e052                	sd	s4,0(sp)
    }
    bp = bread(ip->dev, addr);
    80002fbe:	85a6                	mv	a1,s1
    80002fc0:	00092503          	lw	a0,0(s2)
    80002fc4:	bf5ff0ef          	jal	80002bb8 <bread>
    80002fc8:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    80002fca:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    80002fce:	02099713          	slli	a4,s3,0x20
    80002fd2:	01e75593          	srli	a1,a4,0x1e
    80002fd6:	97ae                	add	a5,a5,a1
    80002fd8:	89be                	mv	s3,a5
    80002fda:	4384                	lw	s1,0(a5)
    80002fdc:	cc89                	beqz	s1,80002ff6 <bmap+0x9a>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    80002fde:	8552                	mv	a0,s4
    80002fe0:	d09ff0ef          	jal	80002ce8 <brelse>
    return addr;
    80002fe4:	6a02                	ld	s4,0(sp)
  }

  panic("bmap: out of range");
}
    80002fe6:	8526                	mv	a0,s1
    80002fe8:	70a2                	ld	ra,40(sp)
    80002fea:	7402                	ld	s0,32(sp)
    80002fec:	64e2                	ld	s1,24(sp)
    80002fee:	6942                	ld	s2,16(sp)
    80002ff0:	69a2                	ld	s3,8(sp)
    80002ff2:	6145                	addi	sp,sp,48
    80002ff4:	8082                	ret
      addr = balloc(ip->dev);
    80002ff6:	00092503          	lw	a0,0(s2)
    80002ffa:	e5dff0ef          	jal	80002e56 <balloc>
    80002ffe:	84aa                	mv	s1,a0
      if(addr){
    80003000:	dd79                	beqz	a0,80002fde <bmap+0x82>
        a[bn] = addr;
    80003002:	00a9a023          	sw	a0,0(s3)
        log_write(bp);
    80003006:	8552                	mv	a0,s4
    80003008:	62d000ef          	jal	80003e34 <log_write>
    8000300c:	bfc9                	j	80002fde <bmap+0x82>
    8000300e:	e052                	sd	s4,0(sp)
  panic("bmap: out of range");
    80003010:	00004517          	auipc	a0,0x4
    80003014:	3f850513          	addi	a0,a0,1016 # 80007408 <etext+0x408>
    80003018:	83ffd0ef          	jal	80000856 <panic>

000000008000301c <iget>:
{
    8000301c:	7179                	addi	sp,sp,-48
    8000301e:	f406                	sd	ra,40(sp)
    80003020:	f022                	sd	s0,32(sp)
    80003022:	ec26                	sd	s1,24(sp)
    80003024:	e84a                	sd	s2,16(sp)
    80003026:	e44e                	sd	s3,8(sp)
    80003028:	e052                	sd	s4,0(sp)
    8000302a:	1800                	addi	s0,sp,48
    8000302c:	892a                	mv	s2,a0
    8000302e:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    80003030:	0001e517          	auipc	a0,0x1e
    80003034:	ba050513          	addi	a0,a0,-1120 # 80020bd0 <itable>
    80003038:	c23fd0ef          	jal	80000c5a <acquire>
  empty = 0;
    8000303c:	4981                	li	s3,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    8000303e:	0001e497          	auipc	s1,0x1e
    80003042:	baa48493          	addi	s1,s1,-1110 # 80020be8 <itable+0x18>
    80003046:	0001f697          	auipc	a3,0x1f
    8000304a:	63268693          	addi	a3,a3,1586 # 80022678 <log>
    8000304e:	a809                	j	80003060 <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003050:	e781                	bnez	a5,80003058 <iget+0x3c>
    80003052:	00099363          	bnez	s3,80003058 <iget+0x3c>
      empty = ip;
    80003056:	89a6                	mv	s3,s1
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003058:	08848493          	addi	s1,s1,136
    8000305c:	02d48563          	beq	s1,a3,80003086 <iget+0x6a>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    80003060:	449c                	lw	a5,8(s1)
    80003062:	fef057e3          	blez	a5,80003050 <iget+0x34>
    80003066:	4098                	lw	a4,0(s1)
    80003068:	ff2718e3          	bne	a4,s2,80003058 <iget+0x3c>
    8000306c:	40d8                	lw	a4,4(s1)
    8000306e:	ff4715e3          	bne	a4,s4,80003058 <iget+0x3c>
      ip->ref++;
    80003072:	2785                	addiw	a5,a5,1
    80003074:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    80003076:	0001e517          	auipc	a0,0x1e
    8000307a:	b5a50513          	addi	a0,a0,-1190 # 80020bd0 <itable>
    8000307e:	c71fd0ef          	jal	80000cee <release>
      return ip;
    80003082:	89a6                	mv	s3,s1
    80003084:	a015                	j	800030a8 <iget+0x8c>
  if(empty == 0)
    80003086:	02098a63          	beqz	s3,800030ba <iget+0x9e>
  ip->dev = dev;
    8000308a:	0129a023          	sw	s2,0(s3)
  ip->inum = inum;
    8000308e:	0149a223          	sw	s4,4(s3)
  ip->ref = 1;
    80003092:	4785                	li	a5,1
    80003094:	00f9a423          	sw	a5,8(s3)
  ip->valid = 0;
    80003098:	0409a023          	sw	zero,64(s3)
  release(&itable.lock);
    8000309c:	0001e517          	auipc	a0,0x1e
    800030a0:	b3450513          	addi	a0,a0,-1228 # 80020bd0 <itable>
    800030a4:	c4bfd0ef          	jal	80000cee <release>
}
    800030a8:	854e                	mv	a0,s3
    800030aa:	70a2                	ld	ra,40(sp)
    800030ac:	7402                	ld	s0,32(sp)
    800030ae:	64e2                	ld	s1,24(sp)
    800030b0:	6942                	ld	s2,16(sp)
    800030b2:	69a2                	ld	s3,8(sp)
    800030b4:	6a02                	ld	s4,0(sp)
    800030b6:	6145                	addi	sp,sp,48
    800030b8:	8082                	ret
    panic("iget: no inodes");
    800030ba:	00004517          	auipc	a0,0x4
    800030be:	36650513          	addi	a0,a0,870 # 80007420 <etext+0x420>
    800030c2:	f94fd0ef          	jal	80000856 <panic>

00000000800030c6 <iinit>:
{
    800030c6:	7179                	addi	sp,sp,-48
    800030c8:	f406                	sd	ra,40(sp)
    800030ca:	f022                	sd	s0,32(sp)
    800030cc:	ec26                	sd	s1,24(sp)
    800030ce:	e84a                	sd	s2,16(sp)
    800030d0:	e44e                	sd	s3,8(sp)
    800030d2:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    800030d4:	00004597          	auipc	a1,0x4
    800030d8:	35c58593          	addi	a1,a1,860 # 80007430 <etext+0x430>
    800030dc:	0001e517          	auipc	a0,0x1e
    800030e0:	af450513          	addi	a0,a0,-1292 # 80020bd0 <itable>
    800030e4:	aedfd0ef          	jal	80000bd0 <initlock>
  for(i = 0; i < NINODE; i++) {
    800030e8:	0001e497          	auipc	s1,0x1e
    800030ec:	b1048493          	addi	s1,s1,-1264 # 80020bf8 <itable+0x28>
    800030f0:	0001f997          	auipc	s3,0x1f
    800030f4:	59898993          	addi	s3,s3,1432 # 80022688 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    800030f8:	00004917          	auipc	s2,0x4
    800030fc:	34090913          	addi	s2,s2,832 # 80007438 <etext+0x438>
    80003100:	85ca                	mv	a1,s2
    80003102:	8526                	mv	a0,s1
    80003104:	5f5000ef          	jal	80003ef8 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    80003108:	08848493          	addi	s1,s1,136
    8000310c:	ff349ae3          	bne	s1,s3,80003100 <iinit+0x3a>
}
    80003110:	70a2                	ld	ra,40(sp)
    80003112:	7402                	ld	s0,32(sp)
    80003114:	64e2                	ld	s1,24(sp)
    80003116:	6942                	ld	s2,16(sp)
    80003118:	69a2                	ld	s3,8(sp)
    8000311a:	6145                	addi	sp,sp,48
    8000311c:	8082                	ret

000000008000311e <ialloc>:
{
    8000311e:	7139                	addi	sp,sp,-64
    80003120:	fc06                	sd	ra,56(sp)
    80003122:	f822                	sd	s0,48(sp)
    80003124:	0080                	addi	s0,sp,64
  for(inum = 1; inum < sb.ninodes; inum++){
    80003126:	0001e717          	auipc	a4,0x1e
    8000312a:	a9672703          	lw	a4,-1386(a4) # 80020bbc <sb+0xc>
    8000312e:	4785                	li	a5,1
    80003130:	06e7f063          	bgeu	a5,a4,80003190 <ialloc+0x72>
    80003134:	f426                	sd	s1,40(sp)
    80003136:	f04a                	sd	s2,32(sp)
    80003138:	ec4e                	sd	s3,24(sp)
    8000313a:	e852                	sd	s4,16(sp)
    8000313c:	e456                	sd	s5,8(sp)
    8000313e:	e05a                	sd	s6,0(sp)
    80003140:	8aaa                	mv	s5,a0
    80003142:	8b2e                	mv	s6,a1
    80003144:	893e                	mv	s2,a5
    bp = bread(dev, IBLOCK(inum, sb));
    80003146:	0001ea17          	auipc	s4,0x1e
    8000314a:	a6aa0a13          	addi	s4,s4,-1430 # 80020bb0 <sb>
    8000314e:	00495593          	srli	a1,s2,0x4
    80003152:	018a2783          	lw	a5,24(s4)
    80003156:	9dbd                	addw	a1,a1,a5
    80003158:	8556                	mv	a0,s5
    8000315a:	a5fff0ef          	jal	80002bb8 <bread>
    8000315e:	84aa                	mv	s1,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    80003160:	05850993          	addi	s3,a0,88
    80003164:	00f97793          	andi	a5,s2,15
    80003168:	079a                	slli	a5,a5,0x6
    8000316a:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    8000316c:	00099783          	lh	a5,0(s3)
    80003170:	cb9d                	beqz	a5,800031a6 <ialloc+0x88>
    brelse(bp);
    80003172:	b77ff0ef          	jal	80002ce8 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    80003176:	0905                	addi	s2,s2,1
    80003178:	00ca2703          	lw	a4,12(s4)
    8000317c:	0009079b          	sext.w	a5,s2
    80003180:	fce7e7e3          	bltu	a5,a4,8000314e <ialloc+0x30>
    80003184:	74a2                	ld	s1,40(sp)
    80003186:	7902                	ld	s2,32(sp)
    80003188:	69e2                	ld	s3,24(sp)
    8000318a:	6a42                	ld	s4,16(sp)
    8000318c:	6aa2                	ld	s5,8(sp)
    8000318e:	6b02                	ld	s6,0(sp)
  printf("ialloc: no inodes\n");
    80003190:	00004517          	auipc	a0,0x4
    80003194:	2b050513          	addi	a0,a0,688 # 80007440 <etext+0x440>
    80003198:	b94fd0ef          	jal	8000052c <printf>
  return 0;
    8000319c:	4501                	li	a0,0
}
    8000319e:	70e2                	ld	ra,56(sp)
    800031a0:	7442                	ld	s0,48(sp)
    800031a2:	6121                	addi	sp,sp,64
    800031a4:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    800031a6:	04000613          	li	a2,64
    800031aa:	4581                	li	a1,0
    800031ac:	854e                	mv	a0,s3
    800031ae:	b7dfd0ef          	jal	80000d2a <memset>
      dip->type = type;
    800031b2:	01699023          	sh	s6,0(s3)
      log_write(bp);   // mark it allocated on the disk
    800031b6:	8526                	mv	a0,s1
    800031b8:	47d000ef          	jal	80003e34 <log_write>
      brelse(bp);
    800031bc:	8526                	mv	a0,s1
    800031be:	b2bff0ef          	jal	80002ce8 <brelse>
      return iget(dev, inum);
    800031c2:	0009059b          	sext.w	a1,s2
    800031c6:	8556                	mv	a0,s5
    800031c8:	e55ff0ef          	jal	8000301c <iget>
    800031cc:	74a2                	ld	s1,40(sp)
    800031ce:	7902                	ld	s2,32(sp)
    800031d0:	69e2                	ld	s3,24(sp)
    800031d2:	6a42                	ld	s4,16(sp)
    800031d4:	6aa2                	ld	s5,8(sp)
    800031d6:	6b02                	ld	s6,0(sp)
    800031d8:	b7d9                	j	8000319e <ialloc+0x80>

00000000800031da <iupdate>:
{
    800031da:	1101                	addi	sp,sp,-32
    800031dc:	ec06                	sd	ra,24(sp)
    800031de:	e822                	sd	s0,16(sp)
    800031e0:	e426                	sd	s1,8(sp)
    800031e2:	e04a                	sd	s2,0(sp)
    800031e4:	1000                	addi	s0,sp,32
    800031e6:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    800031e8:	415c                	lw	a5,4(a0)
    800031ea:	0047d79b          	srliw	a5,a5,0x4
    800031ee:	0001e597          	auipc	a1,0x1e
    800031f2:	9da5a583          	lw	a1,-1574(a1) # 80020bc8 <sb+0x18>
    800031f6:	9dbd                	addw	a1,a1,a5
    800031f8:	4108                	lw	a0,0(a0)
    800031fa:	9bfff0ef          	jal	80002bb8 <bread>
    800031fe:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003200:	05850793          	addi	a5,a0,88
    80003204:	40d8                	lw	a4,4(s1)
    80003206:	8b3d                	andi	a4,a4,15
    80003208:	071a                	slli	a4,a4,0x6
    8000320a:	97ba                	add	a5,a5,a4
  dip->type = ip->type;
    8000320c:	04449703          	lh	a4,68(s1)
    80003210:	00e79023          	sh	a4,0(a5)
  dip->major = ip->major;
    80003214:	04649703          	lh	a4,70(s1)
    80003218:	00e79123          	sh	a4,2(a5)
  dip->minor = ip->minor;
    8000321c:	04849703          	lh	a4,72(s1)
    80003220:	00e79223          	sh	a4,4(a5)
  dip->nlink = ip->nlink;
    80003224:	04a49703          	lh	a4,74(s1)
    80003228:	00e79323          	sh	a4,6(a5)
  dip->size = ip->size;
    8000322c:	44f8                	lw	a4,76(s1)
    8000322e:	c798                	sw	a4,8(a5)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80003230:	03400613          	li	a2,52
    80003234:	05048593          	addi	a1,s1,80
    80003238:	00c78513          	addi	a0,a5,12
    8000323c:	b4ffd0ef          	jal	80000d8a <memmove>
  log_write(bp);
    80003240:	854a                	mv	a0,s2
    80003242:	3f3000ef          	jal	80003e34 <log_write>
  brelse(bp);
    80003246:	854a                	mv	a0,s2
    80003248:	aa1ff0ef          	jal	80002ce8 <brelse>
}
    8000324c:	60e2                	ld	ra,24(sp)
    8000324e:	6442                	ld	s0,16(sp)
    80003250:	64a2                	ld	s1,8(sp)
    80003252:	6902                	ld	s2,0(sp)
    80003254:	6105                	addi	sp,sp,32
    80003256:	8082                	ret

0000000080003258 <idup>:
{
    80003258:	1101                	addi	sp,sp,-32
    8000325a:	ec06                	sd	ra,24(sp)
    8000325c:	e822                	sd	s0,16(sp)
    8000325e:	e426                	sd	s1,8(sp)
    80003260:	1000                	addi	s0,sp,32
    80003262:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003264:	0001e517          	auipc	a0,0x1e
    80003268:	96c50513          	addi	a0,a0,-1684 # 80020bd0 <itable>
    8000326c:	9effd0ef          	jal	80000c5a <acquire>
  ip->ref++;
    80003270:	449c                	lw	a5,8(s1)
    80003272:	2785                	addiw	a5,a5,1
    80003274:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003276:	0001e517          	auipc	a0,0x1e
    8000327a:	95a50513          	addi	a0,a0,-1702 # 80020bd0 <itable>
    8000327e:	a71fd0ef          	jal	80000cee <release>
}
    80003282:	8526                	mv	a0,s1
    80003284:	60e2                	ld	ra,24(sp)
    80003286:	6442                	ld	s0,16(sp)
    80003288:	64a2                	ld	s1,8(sp)
    8000328a:	6105                	addi	sp,sp,32
    8000328c:	8082                	ret

000000008000328e <ilock>:
{
    8000328e:	1101                	addi	sp,sp,-32
    80003290:	ec06                	sd	ra,24(sp)
    80003292:	e822                	sd	s0,16(sp)
    80003294:	e426                	sd	s1,8(sp)
    80003296:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    80003298:	cd19                	beqz	a0,800032b6 <ilock+0x28>
    8000329a:	84aa                	mv	s1,a0
    8000329c:	451c                	lw	a5,8(a0)
    8000329e:	00f05c63          	blez	a5,800032b6 <ilock+0x28>
  acquiresleep(&ip->lock);
    800032a2:	0541                	addi	a0,a0,16
    800032a4:	48b000ef          	jal	80003f2e <acquiresleep>
  if(ip->valid == 0){
    800032a8:	40bc                	lw	a5,64(s1)
    800032aa:	cf89                	beqz	a5,800032c4 <ilock+0x36>
}
    800032ac:	60e2                	ld	ra,24(sp)
    800032ae:	6442                	ld	s0,16(sp)
    800032b0:	64a2                	ld	s1,8(sp)
    800032b2:	6105                	addi	sp,sp,32
    800032b4:	8082                	ret
    800032b6:	e04a                	sd	s2,0(sp)
    panic("ilock");
    800032b8:	00004517          	auipc	a0,0x4
    800032bc:	1a050513          	addi	a0,a0,416 # 80007458 <etext+0x458>
    800032c0:	d96fd0ef          	jal	80000856 <panic>
    800032c4:	e04a                	sd	s2,0(sp)
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    800032c6:	40dc                	lw	a5,4(s1)
    800032c8:	0047d79b          	srliw	a5,a5,0x4
    800032cc:	0001e597          	auipc	a1,0x1e
    800032d0:	8fc5a583          	lw	a1,-1796(a1) # 80020bc8 <sb+0x18>
    800032d4:	9dbd                	addw	a1,a1,a5
    800032d6:	4088                	lw	a0,0(s1)
    800032d8:	8e1ff0ef          	jal	80002bb8 <bread>
    800032dc:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    800032de:	05850593          	addi	a1,a0,88
    800032e2:	40dc                	lw	a5,4(s1)
    800032e4:	8bbd                	andi	a5,a5,15
    800032e6:	079a                	slli	a5,a5,0x6
    800032e8:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    800032ea:	00059783          	lh	a5,0(a1)
    800032ee:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    800032f2:	00259783          	lh	a5,2(a1)
    800032f6:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    800032fa:	00459783          	lh	a5,4(a1)
    800032fe:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80003302:	00659783          	lh	a5,6(a1)
    80003306:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    8000330a:	459c                	lw	a5,8(a1)
    8000330c:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    8000330e:	03400613          	li	a2,52
    80003312:	05b1                	addi	a1,a1,12
    80003314:	05048513          	addi	a0,s1,80
    80003318:	a73fd0ef          	jal	80000d8a <memmove>
    brelse(bp);
    8000331c:	854a                	mv	a0,s2
    8000331e:	9cbff0ef          	jal	80002ce8 <brelse>
    ip->valid = 1;
    80003322:	4785                	li	a5,1
    80003324:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    80003326:	04449783          	lh	a5,68(s1)
    8000332a:	c399                	beqz	a5,80003330 <ilock+0xa2>
    8000332c:	6902                	ld	s2,0(sp)
    8000332e:	bfbd                	j	800032ac <ilock+0x1e>
      panic("ilock: no type");
    80003330:	00004517          	auipc	a0,0x4
    80003334:	13050513          	addi	a0,a0,304 # 80007460 <etext+0x460>
    80003338:	d1efd0ef          	jal	80000856 <panic>

000000008000333c <iunlock>:
{
    8000333c:	1101                	addi	sp,sp,-32
    8000333e:	ec06                	sd	ra,24(sp)
    80003340:	e822                	sd	s0,16(sp)
    80003342:	e426                	sd	s1,8(sp)
    80003344:	e04a                	sd	s2,0(sp)
    80003346:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80003348:	c505                	beqz	a0,80003370 <iunlock+0x34>
    8000334a:	84aa                	mv	s1,a0
    8000334c:	01050913          	addi	s2,a0,16
    80003350:	854a                	mv	a0,s2
    80003352:	45b000ef          	jal	80003fac <holdingsleep>
    80003356:	cd09                	beqz	a0,80003370 <iunlock+0x34>
    80003358:	449c                	lw	a5,8(s1)
    8000335a:	00f05b63          	blez	a5,80003370 <iunlock+0x34>
  releasesleep(&ip->lock);
    8000335e:	854a                	mv	a0,s2
    80003360:	415000ef          	jal	80003f74 <releasesleep>
}
    80003364:	60e2                	ld	ra,24(sp)
    80003366:	6442                	ld	s0,16(sp)
    80003368:	64a2                	ld	s1,8(sp)
    8000336a:	6902                	ld	s2,0(sp)
    8000336c:	6105                	addi	sp,sp,32
    8000336e:	8082                	ret
    panic("iunlock");
    80003370:	00004517          	auipc	a0,0x4
    80003374:	10050513          	addi	a0,a0,256 # 80007470 <etext+0x470>
    80003378:	cdefd0ef          	jal	80000856 <panic>

000000008000337c <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    8000337c:	7179                	addi	sp,sp,-48
    8000337e:	f406                	sd	ra,40(sp)
    80003380:	f022                	sd	s0,32(sp)
    80003382:	ec26                	sd	s1,24(sp)
    80003384:	e84a                	sd	s2,16(sp)
    80003386:	e44e                	sd	s3,8(sp)
    80003388:	1800                	addi	s0,sp,48
    8000338a:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    8000338c:	05050493          	addi	s1,a0,80
    80003390:	08050913          	addi	s2,a0,128
    80003394:	a021                	j	8000339c <itrunc+0x20>
    80003396:	0491                	addi	s1,s1,4
    80003398:	01248b63          	beq	s1,s2,800033ae <itrunc+0x32>
    if(ip->addrs[i]){
    8000339c:	408c                	lw	a1,0(s1)
    8000339e:	dde5                	beqz	a1,80003396 <itrunc+0x1a>
      bfree(ip->dev, ip->addrs[i]);
    800033a0:	0009a503          	lw	a0,0(s3)
    800033a4:	a47ff0ef          	jal	80002dea <bfree>
      ip->addrs[i] = 0;
    800033a8:	0004a023          	sw	zero,0(s1)
    800033ac:	b7ed                	j	80003396 <itrunc+0x1a>
    }
  }

  if(ip->addrs[NDIRECT]){
    800033ae:	0809a583          	lw	a1,128(s3)
    800033b2:	ed89                	bnez	a1,800033cc <itrunc+0x50>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    800033b4:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    800033b8:	854e                	mv	a0,s3
    800033ba:	e21ff0ef          	jal	800031da <iupdate>
}
    800033be:	70a2                	ld	ra,40(sp)
    800033c0:	7402                	ld	s0,32(sp)
    800033c2:	64e2                	ld	s1,24(sp)
    800033c4:	6942                	ld	s2,16(sp)
    800033c6:	69a2                	ld	s3,8(sp)
    800033c8:	6145                	addi	sp,sp,48
    800033ca:	8082                	ret
    800033cc:	e052                	sd	s4,0(sp)
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    800033ce:	0009a503          	lw	a0,0(s3)
    800033d2:	fe6ff0ef          	jal	80002bb8 <bread>
    800033d6:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    800033d8:	05850493          	addi	s1,a0,88
    800033dc:	45850913          	addi	s2,a0,1112
    800033e0:	a021                	j	800033e8 <itrunc+0x6c>
    800033e2:	0491                	addi	s1,s1,4
    800033e4:	01248963          	beq	s1,s2,800033f6 <itrunc+0x7a>
      if(a[j])
    800033e8:	408c                	lw	a1,0(s1)
    800033ea:	dde5                	beqz	a1,800033e2 <itrunc+0x66>
        bfree(ip->dev, a[j]);
    800033ec:	0009a503          	lw	a0,0(s3)
    800033f0:	9fbff0ef          	jal	80002dea <bfree>
    800033f4:	b7fd                	j	800033e2 <itrunc+0x66>
    brelse(bp);
    800033f6:	8552                	mv	a0,s4
    800033f8:	8f1ff0ef          	jal	80002ce8 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    800033fc:	0809a583          	lw	a1,128(s3)
    80003400:	0009a503          	lw	a0,0(s3)
    80003404:	9e7ff0ef          	jal	80002dea <bfree>
    ip->addrs[NDIRECT] = 0;
    80003408:	0809a023          	sw	zero,128(s3)
    8000340c:	6a02                	ld	s4,0(sp)
    8000340e:	b75d                	j	800033b4 <itrunc+0x38>

0000000080003410 <iput>:
{
    80003410:	1101                	addi	sp,sp,-32
    80003412:	ec06                	sd	ra,24(sp)
    80003414:	e822                	sd	s0,16(sp)
    80003416:	e426                	sd	s1,8(sp)
    80003418:	1000                	addi	s0,sp,32
    8000341a:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    8000341c:	0001d517          	auipc	a0,0x1d
    80003420:	7b450513          	addi	a0,a0,1972 # 80020bd0 <itable>
    80003424:	837fd0ef          	jal	80000c5a <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003428:	4498                	lw	a4,8(s1)
    8000342a:	4785                	li	a5,1
    8000342c:	02f70063          	beq	a4,a5,8000344c <iput+0x3c>
  ip->ref--;
    80003430:	449c                	lw	a5,8(s1)
    80003432:	37fd                	addiw	a5,a5,-1
    80003434:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003436:	0001d517          	auipc	a0,0x1d
    8000343a:	79a50513          	addi	a0,a0,1946 # 80020bd0 <itable>
    8000343e:	8b1fd0ef          	jal	80000cee <release>
}
    80003442:	60e2                	ld	ra,24(sp)
    80003444:	6442                	ld	s0,16(sp)
    80003446:	64a2                	ld	s1,8(sp)
    80003448:	6105                	addi	sp,sp,32
    8000344a:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    8000344c:	40bc                	lw	a5,64(s1)
    8000344e:	d3ed                	beqz	a5,80003430 <iput+0x20>
    80003450:	04a49783          	lh	a5,74(s1)
    80003454:	fff1                	bnez	a5,80003430 <iput+0x20>
    80003456:	e04a                	sd	s2,0(sp)
    acquiresleep(&ip->lock);
    80003458:	01048793          	addi	a5,s1,16
    8000345c:	893e                	mv	s2,a5
    8000345e:	853e                	mv	a0,a5
    80003460:	2cf000ef          	jal	80003f2e <acquiresleep>
    release(&itable.lock);
    80003464:	0001d517          	auipc	a0,0x1d
    80003468:	76c50513          	addi	a0,a0,1900 # 80020bd0 <itable>
    8000346c:	883fd0ef          	jal	80000cee <release>
    itrunc(ip);
    80003470:	8526                	mv	a0,s1
    80003472:	f0bff0ef          	jal	8000337c <itrunc>
    ip->type = 0;
    80003476:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    8000347a:	8526                	mv	a0,s1
    8000347c:	d5fff0ef          	jal	800031da <iupdate>
    ip->valid = 0;
    80003480:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80003484:	854a                	mv	a0,s2
    80003486:	2ef000ef          	jal	80003f74 <releasesleep>
    acquire(&itable.lock);
    8000348a:	0001d517          	auipc	a0,0x1d
    8000348e:	74650513          	addi	a0,a0,1862 # 80020bd0 <itable>
    80003492:	fc8fd0ef          	jal	80000c5a <acquire>
    80003496:	6902                	ld	s2,0(sp)
    80003498:	bf61                	j	80003430 <iput+0x20>

000000008000349a <iunlockput>:
{
    8000349a:	1101                	addi	sp,sp,-32
    8000349c:	ec06                	sd	ra,24(sp)
    8000349e:	e822                	sd	s0,16(sp)
    800034a0:	e426                	sd	s1,8(sp)
    800034a2:	1000                	addi	s0,sp,32
    800034a4:	84aa                	mv	s1,a0
  iunlock(ip);
    800034a6:	e97ff0ef          	jal	8000333c <iunlock>
  iput(ip);
    800034aa:	8526                	mv	a0,s1
    800034ac:	f65ff0ef          	jal	80003410 <iput>
}
    800034b0:	60e2                	ld	ra,24(sp)
    800034b2:	6442                	ld	s0,16(sp)
    800034b4:	64a2                	ld	s1,8(sp)
    800034b6:	6105                	addi	sp,sp,32
    800034b8:	8082                	ret

00000000800034ba <ireclaim>:
  for (int inum = 1; inum < sb.ninodes; inum++) {
    800034ba:	0001d717          	auipc	a4,0x1d
    800034be:	70272703          	lw	a4,1794(a4) # 80020bbc <sb+0xc>
    800034c2:	4785                	li	a5,1
    800034c4:	0ae7fe63          	bgeu	a5,a4,80003580 <ireclaim+0xc6>
{
    800034c8:	7139                	addi	sp,sp,-64
    800034ca:	fc06                	sd	ra,56(sp)
    800034cc:	f822                	sd	s0,48(sp)
    800034ce:	f426                	sd	s1,40(sp)
    800034d0:	f04a                	sd	s2,32(sp)
    800034d2:	ec4e                	sd	s3,24(sp)
    800034d4:	e852                	sd	s4,16(sp)
    800034d6:	e456                	sd	s5,8(sp)
    800034d8:	e05a                	sd	s6,0(sp)
    800034da:	0080                	addi	s0,sp,64
    800034dc:	8aaa                	mv	s5,a0
  for (int inum = 1; inum < sb.ninodes; inum++) {
    800034de:	84be                	mv	s1,a5
    struct buf *bp = bread(dev, IBLOCK(inum, sb));
    800034e0:	0001da17          	auipc	s4,0x1d
    800034e4:	6d0a0a13          	addi	s4,s4,1744 # 80020bb0 <sb>
      printf("ireclaim: orphaned inode %d\n", inum);
    800034e8:	00004b17          	auipc	s6,0x4
    800034ec:	f90b0b13          	addi	s6,s6,-112 # 80007478 <etext+0x478>
    800034f0:	a099                	j	80003536 <ireclaim+0x7c>
    800034f2:	85ce                	mv	a1,s3
    800034f4:	855a                	mv	a0,s6
    800034f6:	836fd0ef          	jal	8000052c <printf>
      ip = iget(dev, inum);
    800034fa:	85ce                	mv	a1,s3
    800034fc:	8556                	mv	a0,s5
    800034fe:	b1fff0ef          	jal	8000301c <iget>
    80003502:	89aa                	mv	s3,a0
    brelse(bp);
    80003504:	854a                	mv	a0,s2
    80003506:	fe2ff0ef          	jal	80002ce8 <brelse>
    if (ip) {
    8000350a:	00098f63          	beqz	s3,80003528 <ireclaim+0x6e>
      begin_op();
    8000350e:	78c000ef          	jal	80003c9a <begin_op>
      ilock(ip);
    80003512:	854e                	mv	a0,s3
    80003514:	d7bff0ef          	jal	8000328e <ilock>
      iunlock(ip);
    80003518:	854e                	mv	a0,s3
    8000351a:	e23ff0ef          	jal	8000333c <iunlock>
      iput(ip);
    8000351e:	854e                	mv	a0,s3
    80003520:	ef1ff0ef          	jal	80003410 <iput>
      end_op();
    80003524:	7e6000ef          	jal	80003d0a <end_op>
  for (int inum = 1; inum < sb.ninodes; inum++) {
    80003528:	0485                	addi	s1,s1,1
    8000352a:	00ca2703          	lw	a4,12(s4)
    8000352e:	0004879b          	sext.w	a5,s1
    80003532:	02e7fd63          	bgeu	a5,a4,8000356c <ireclaim+0xb2>
    80003536:	0004899b          	sext.w	s3,s1
    struct buf *bp = bread(dev, IBLOCK(inum, sb));
    8000353a:	0044d593          	srli	a1,s1,0x4
    8000353e:	018a2783          	lw	a5,24(s4)
    80003542:	9dbd                	addw	a1,a1,a5
    80003544:	8556                	mv	a0,s5
    80003546:	e72ff0ef          	jal	80002bb8 <bread>
    8000354a:	892a                	mv	s2,a0
    struct dinode *dip = (struct dinode *)bp->data + inum % IPB;
    8000354c:	05850793          	addi	a5,a0,88
    80003550:	00f9f713          	andi	a4,s3,15
    80003554:	071a                	slli	a4,a4,0x6
    80003556:	97ba                	add	a5,a5,a4
    if (dip->type != 0 && dip->nlink == 0) {  // is an orphaned inode
    80003558:	00079703          	lh	a4,0(a5)
    8000355c:	c701                	beqz	a4,80003564 <ireclaim+0xaa>
    8000355e:	00679783          	lh	a5,6(a5)
    80003562:	dbc1                	beqz	a5,800034f2 <ireclaim+0x38>
    brelse(bp);
    80003564:	854a                	mv	a0,s2
    80003566:	f82ff0ef          	jal	80002ce8 <brelse>
    if (ip) {
    8000356a:	bf7d                	j	80003528 <ireclaim+0x6e>
}
    8000356c:	70e2                	ld	ra,56(sp)
    8000356e:	7442                	ld	s0,48(sp)
    80003570:	74a2                	ld	s1,40(sp)
    80003572:	7902                	ld	s2,32(sp)
    80003574:	69e2                	ld	s3,24(sp)
    80003576:	6a42                	ld	s4,16(sp)
    80003578:	6aa2                	ld	s5,8(sp)
    8000357a:	6b02                	ld	s6,0(sp)
    8000357c:	6121                	addi	sp,sp,64
    8000357e:	8082                	ret
    80003580:	8082                	ret

0000000080003582 <fsinit>:
fsinit(int dev) {
    80003582:	1101                	addi	sp,sp,-32
    80003584:	ec06                	sd	ra,24(sp)
    80003586:	e822                	sd	s0,16(sp)
    80003588:	e426                	sd	s1,8(sp)
    8000358a:	e04a                	sd	s2,0(sp)
    8000358c:	1000                	addi	s0,sp,32
    8000358e:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    80003590:	4585                	li	a1,1
    80003592:	e26ff0ef          	jal	80002bb8 <bread>
    80003596:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    80003598:	02000613          	li	a2,32
    8000359c:	05850593          	addi	a1,a0,88
    800035a0:	0001d517          	auipc	a0,0x1d
    800035a4:	61050513          	addi	a0,a0,1552 # 80020bb0 <sb>
    800035a8:	fe2fd0ef          	jal	80000d8a <memmove>
  brelse(bp);
    800035ac:	8526                	mv	a0,s1
    800035ae:	f3aff0ef          	jal	80002ce8 <brelse>
  if(sb.magic != FSMAGIC)
    800035b2:	0001d717          	auipc	a4,0x1d
    800035b6:	5fe72703          	lw	a4,1534(a4) # 80020bb0 <sb>
    800035ba:	102037b7          	lui	a5,0x10203
    800035be:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    800035c2:	02f71263          	bne	a4,a5,800035e6 <fsinit+0x64>
  initlog(dev, &sb);
    800035c6:	0001d597          	auipc	a1,0x1d
    800035ca:	5ea58593          	addi	a1,a1,1514 # 80020bb0 <sb>
    800035ce:	854a                	mv	a0,s2
    800035d0:	648000ef          	jal	80003c18 <initlog>
  ireclaim(dev);
    800035d4:	854a                	mv	a0,s2
    800035d6:	ee5ff0ef          	jal	800034ba <ireclaim>
}
    800035da:	60e2                	ld	ra,24(sp)
    800035dc:	6442                	ld	s0,16(sp)
    800035de:	64a2                	ld	s1,8(sp)
    800035e0:	6902                	ld	s2,0(sp)
    800035e2:	6105                	addi	sp,sp,32
    800035e4:	8082                	ret
    panic("invalid file system");
    800035e6:	00004517          	auipc	a0,0x4
    800035ea:	eb250513          	addi	a0,a0,-334 # 80007498 <etext+0x498>
    800035ee:	a68fd0ef          	jal	80000856 <panic>

00000000800035f2 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    800035f2:	1141                	addi	sp,sp,-16
    800035f4:	e406                	sd	ra,8(sp)
    800035f6:	e022                	sd	s0,0(sp)
    800035f8:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    800035fa:	411c                	lw	a5,0(a0)
    800035fc:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    800035fe:	415c                	lw	a5,4(a0)
    80003600:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80003602:	04451783          	lh	a5,68(a0)
    80003606:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    8000360a:	04a51783          	lh	a5,74(a0)
    8000360e:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80003612:	04c56783          	lwu	a5,76(a0)
    80003616:	e99c                	sd	a5,16(a1)
}
    80003618:	60a2                	ld	ra,8(sp)
    8000361a:	6402                	ld	s0,0(sp)
    8000361c:	0141                	addi	sp,sp,16
    8000361e:	8082                	ret

0000000080003620 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003620:	457c                	lw	a5,76(a0)
    80003622:	0ed7e663          	bltu	a5,a3,8000370e <readi+0xee>
{
    80003626:	7159                	addi	sp,sp,-112
    80003628:	f486                	sd	ra,104(sp)
    8000362a:	f0a2                	sd	s0,96(sp)
    8000362c:	eca6                	sd	s1,88(sp)
    8000362e:	e0d2                	sd	s4,64(sp)
    80003630:	fc56                	sd	s5,56(sp)
    80003632:	f85a                	sd	s6,48(sp)
    80003634:	f45e                	sd	s7,40(sp)
    80003636:	1880                	addi	s0,sp,112
    80003638:	8b2a                	mv	s6,a0
    8000363a:	8bae                	mv	s7,a1
    8000363c:	8a32                	mv	s4,a2
    8000363e:	84b6                	mv	s1,a3
    80003640:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    80003642:	9f35                	addw	a4,a4,a3
    return 0;
    80003644:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80003646:	0ad76b63          	bltu	a4,a3,800036fc <readi+0xdc>
    8000364a:	e4ce                	sd	s3,72(sp)
  if(off + n > ip->size)
    8000364c:	00e7f463          	bgeu	a5,a4,80003654 <readi+0x34>
    n = ip->size - off;
    80003650:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003654:	080a8b63          	beqz	s5,800036ea <readi+0xca>
    80003658:	e8ca                	sd	s2,80(sp)
    8000365a:	f062                	sd	s8,32(sp)
    8000365c:	ec66                	sd	s9,24(sp)
    8000365e:	e86a                	sd	s10,16(sp)
    80003660:	e46e                	sd	s11,8(sp)
    80003662:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003664:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80003668:	5c7d                	li	s8,-1
    8000366a:	a80d                	j	8000369c <readi+0x7c>
    8000366c:	020d1d93          	slli	s11,s10,0x20
    80003670:	020ddd93          	srli	s11,s11,0x20
    80003674:	05890613          	addi	a2,s2,88
    80003678:	86ee                	mv	a3,s11
    8000367a:	963e                	add	a2,a2,a5
    8000367c:	85d2                	mv	a1,s4
    8000367e:	855e                	mv	a0,s7
    80003680:	c55fe0ef          	jal	800022d4 <either_copyout>
    80003684:	05850363          	beq	a0,s8,800036ca <readi+0xaa>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80003688:	854a                	mv	a0,s2
    8000368a:	e5eff0ef          	jal	80002ce8 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    8000368e:	013d09bb          	addw	s3,s10,s3
    80003692:	009d04bb          	addw	s1,s10,s1
    80003696:	9a6e                	add	s4,s4,s11
    80003698:	0559f363          	bgeu	s3,s5,800036de <readi+0xbe>
    uint addr = bmap(ip, off/BSIZE);
    8000369c:	00a4d59b          	srliw	a1,s1,0xa
    800036a0:	855a                	mv	a0,s6
    800036a2:	8bbff0ef          	jal	80002f5c <bmap>
    800036a6:	85aa                	mv	a1,a0
    if(addr == 0)
    800036a8:	c139                	beqz	a0,800036ee <readi+0xce>
    bp = bread(ip->dev, addr);
    800036aa:	000b2503          	lw	a0,0(s6)
    800036ae:	d0aff0ef          	jal	80002bb8 <bread>
    800036b2:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    800036b4:	3ff4f793          	andi	a5,s1,1023
    800036b8:	40fc873b          	subw	a4,s9,a5
    800036bc:	413a86bb          	subw	a3,s5,s3
    800036c0:	8d3a                	mv	s10,a4
    800036c2:	fae6f5e3          	bgeu	a3,a4,8000366c <readi+0x4c>
    800036c6:	8d36                	mv	s10,a3
    800036c8:	b755                	j	8000366c <readi+0x4c>
      brelse(bp);
    800036ca:	854a                	mv	a0,s2
    800036cc:	e1cff0ef          	jal	80002ce8 <brelse>
      tot = -1;
    800036d0:	59fd                	li	s3,-1
      break;
    800036d2:	6946                	ld	s2,80(sp)
    800036d4:	7c02                	ld	s8,32(sp)
    800036d6:	6ce2                	ld	s9,24(sp)
    800036d8:	6d42                	ld	s10,16(sp)
    800036da:	6da2                	ld	s11,8(sp)
    800036dc:	a831                	j	800036f8 <readi+0xd8>
    800036de:	6946                	ld	s2,80(sp)
    800036e0:	7c02                	ld	s8,32(sp)
    800036e2:	6ce2                	ld	s9,24(sp)
    800036e4:	6d42                	ld	s10,16(sp)
    800036e6:	6da2                	ld	s11,8(sp)
    800036e8:	a801                	j	800036f8 <readi+0xd8>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    800036ea:	89d6                	mv	s3,s5
    800036ec:	a031                	j	800036f8 <readi+0xd8>
    800036ee:	6946                	ld	s2,80(sp)
    800036f0:	7c02                	ld	s8,32(sp)
    800036f2:	6ce2                	ld	s9,24(sp)
    800036f4:	6d42                	ld	s10,16(sp)
    800036f6:	6da2                	ld	s11,8(sp)
  }
  return tot;
    800036f8:	854e                	mv	a0,s3
    800036fa:	69a6                	ld	s3,72(sp)
}
    800036fc:	70a6                	ld	ra,104(sp)
    800036fe:	7406                	ld	s0,96(sp)
    80003700:	64e6                	ld	s1,88(sp)
    80003702:	6a06                	ld	s4,64(sp)
    80003704:	7ae2                	ld	s5,56(sp)
    80003706:	7b42                	ld	s6,48(sp)
    80003708:	7ba2                	ld	s7,40(sp)
    8000370a:	6165                	addi	sp,sp,112
    8000370c:	8082                	ret
    return 0;
    8000370e:	4501                	li	a0,0
}
    80003710:	8082                	ret

0000000080003712 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003712:	457c                	lw	a5,76(a0)
    80003714:	0ed7eb63          	bltu	a5,a3,8000380a <writei+0xf8>
{
    80003718:	7159                	addi	sp,sp,-112
    8000371a:	f486                	sd	ra,104(sp)
    8000371c:	f0a2                	sd	s0,96(sp)
    8000371e:	e8ca                	sd	s2,80(sp)
    80003720:	e0d2                	sd	s4,64(sp)
    80003722:	fc56                	sd	s5,56(sp)
    80003724:	f85a                	sd	s6,48(sp)
    80003726:	f45e                	sd	s7,40(sp)
    80003728:	1880                	addi	s0,sp,112
    8000372a:	8aaa                	mv	s5,a0
    8000372c:	8bae                	mv	s7,a1
    8000372e:	8a32                	mv	s4,a2
    80003730:	8936                	mv	s2,a3
    80003732:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003734:	00e687bb          	addw	a5,a3,a4
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80003738:	00043737          	lui	a4,0x43
    8000373c:	0cf76963          	bltu	a4,a5,8000380e <writei+0xfc>
    80003740:	0cd7e763          	bltu	a5,a3,8000380e <writei+0xfc>
    80003744:	e4ce                	sd	s3,72(sp)
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003746:	0a0b0a63          	beqz	s6,800037fa <writei+0xe8>
    8000374a:	eca6                	sd	s1,88(sp)
    8000374c:	f062                	sd	s8,32(sp)
    8000374e:	ec66                	sd	s9,24(sp)
    80003750:	e86a                	sd	s10,16(sp)
    80003752:	e46e                	sd	s11,8(sp)
    80003754:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003756:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    8000375a:	5c7d                	li	s8,-1
    8000375c:	a825                	j	80003794 <writei+0x82>
    8000375e:	020d1d93          	slli	s11,s10,0x20
    80003762:	020ddd93          	srli	s11,s11,0x20
    80003766:	05848513          	addi	a0,s1,88
    8000376a:	86ee                	mv	a3,s11
    8000376c:	8652                	mv	a2,s4
    8000376e:	85de                	mv	a1,s7
    80003770:	953e                	add	a0,a0,a5
    80003772:	badfe0ef          	jal	8000231e <either_copyin>
    80003776:	05850663          	beq	a0,s8,800037c2 <writei+0xb0>
      brelse(bp);
      break;
    }
    log_write(bp);
    8000377a:	8526                	mv	a0,s1
    8000377c:	6b8000ef          	jal	80003e34 <log_write>
    brelse(bp);
    80003780:	8526                	mv	a0,s1
    80003782:	d66ff0ef          	jal	80002ce8 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003786:	013d09bb          	addw	s3,s10,s3
    8000378a:	012d093b          	addw	s2,s10,s2
    8000378e:	9a6e                	add	s4,s4,s11
    80003790:	0369fc63          	bgeu	s3,s6,800037c8 <writei+0xb6>
    uint addr = bmap(ip, off/BSIZE);
    80003794:	00a9559b          	srliw	a1,s2,0xa
    80003798:	8556                	mv	a0,s5
    8000379a:	fc2ff0ef          	jal	80002f5c <bmap>
    8000379e:	85aa                	mv	a1,a0
    if(addr == 0)
    800037a0:	c505                	beqz	a0,800037c8 <writei+0xb6>
    bp = bread(ip->dev, addr);
    800037a2:	000aa503          	lw	a0,0(s5)
    800037a6:	c12ff0ef          	jal	80002bb8 <bread>
    800037aa:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    800037ac:	3ff97793          	andi	a5,s2,1023
    800037b0:	40fc873b          	subw	a4,s9,a5
    800037b4:	413b06bb          	subw	a3,s6,s3
    800037b8:	8d3a                	mv	s10,a4
    800037ba:	fae6f2e3          	bgeu	a3,a4,8000375e <writei+0x4c>
    800037be:	8d36                	mv	s10,a3
    800037c0:	bf79                	j	8000375e <writei+0x4c>
      brelse(bp);
    800037c2:	8526                	mv	a0,s1
    800037c4:	d24ff0ef          	jal	80002ce8 <brelse>
  }

  if(off > ip->size)
    800037c8:	04caa783          	lw	a5,76(s5)
    800037cc:	0327f963          	bgeu	a5,s2,800037fe <writei+0xec>
    ip->size = off;
    800037d0:	052aa623          	sw	s2,76(s5)
    800037d4:	64e6                	ld	s1,88(sp)
    800037d6:	7c02                	ld	s8,32(sp)
    800037d8:	6ce2                	ld	s9,24(sp)
    800037da:	6d42                	ld	s10,16(sp)
    800037dc:	6da2                	ld	s11,8(sp)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    800037de:	8556                	mv	a0,s5
    800037e0:	9fbff0ef          	jal	800031da <iupdate>

  return tot;
    800037e4:	854e                	mv	a0,s3
    800037e6:	69a6                	ld	s3,72(sp)
}
    800037e8:	70a6                	ld	ra,104(sp)
    800037ea:	7406                	ld	s0,96(sp)
    800037ec:	6946                	ld	s2,80(sp)
    800037ee:	6a06                	ld	s4,64(sp)
    800037f0:	7ae2                	ld	s5,56(sp)
    800037f2:	7b42                	ld	s6,48(sp)
    800037f4:	7ba2                	ld	s7,40(sp)
    800037f6:	6165                	addi	sp,sp,112
    800037f8:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    800037fa:	89da                	mv	s3,s6
    800037fc:	b7cd                	j	800037de <writei+0xcc>
    800037fe:	64e6                	ld	s1,88(sp)
    80003800:	7c02                	ld	s8,32(sp)
    80003802:	6ce2                	ld	s9,24(sp)
    80003804:	6d42                	ld	s10,16(sp)
    80003806:	6da2                	ld	s11,8(sp)
    80003808:	bfd9                	j	800037de <writei+0xcc>
    return -1;
    8000380a:	557d                	li	a0,-1
}
    8000380c:	8082                	ret
    return -1;
    8000380e:	557d                	li	a0,-1
    80003810:	bfe1                	j	800037e8 <writei+0xd6>

0000000080003812 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80003812:	1141                	addi	sp,sp,-16
    80003814:	e406                	sd	ra,8(sp)
    80003816:	e022                	sd	s0,0(sp)
    80003818:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    8000381a:	4639                	li	a2,14
    8000381c:	de2fd0ef          	jal	80000dfe <strncmp>
}
    80003820:	60a2                	ld	ra,8(sp)
    80003822:	6402                	ld	s0,0(sp)
    80003824:	0141                	addi	sp,sp,16
    80003826:	8082                	ret

0000000080003828 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80003828:	711d                	addi	sp,sp,-96
    8000382a:	ec86                	sd	ra,88(sp)
    8000382c:	e8a2                	sd	s0,80(sp)
    8000382e:	e4a6                	sd	s1,72(sp)
    80003830:	e0ca                	sd	s2,64(sp)
    80003832:	fc4e                	sd	s3,56(sp)
    80003834:	f852                	sd	s4,48(sp)
    80003836:	f456                	sd	s5,40(sp)
    80003838:	f05a                	sd	s6,32(sp)
    8000383a:	ec5e                	sd	s7,24(sp)
    8000383c:	1080                	addi	s0,sp,96
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    8000383e:	04451703          	lh	a4,68(a0)
    80003842:	4785                	li	a5,1
    80003844:	00f71f63          	bne	a4,a5,80003862 <dirlookup+0x3a>
    80003848:	892a                	mv	s2,a0
    8000384a:	8aae                	mv	s5,a1
    8000384c:	8bb2                	mv	s7,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    8000384e:	457c                	lw	a5,76(a0)
    80003850:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003852:	fa040a13          	addi	s4,s0,-96
    80003856:	49c1                	li	s3,16
      panic("dirlookup read");
    if(de.inum == 0)
      continue;
    if(namecmp(name, de.name) == 0){
    80003858:	fa240b13          	addi	s6,s0,-94
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    8000385c:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    8000385e:	e39d                	bnez	a5,80003884 <dirlookup+0x5c>
    80003860:	a8b9                	j	800038be <dirlookup+0x96>
    panic("dirlookup not DIR");
    80003862:	00004517          	auipc	a0,0x4
    80003866:	c4e50513          	addi	a0,a0,-946 # 800074b0 <etext+0x4b0>
    8000386a:	fedfc0ef          	jal	80000856 <panic>
      panic("dirlookup read");
    8000386e:	00004517          	auipc	a0,0x4
    80003872:	c5a50513          	addi	a0,a0,-934 # 800074c8 <etext+0x4c8>
    80003876:	fe1fc0ef          	jal	80000856 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    8000387a:	24c1                	addiw	s1,s1,16
    8000387c:	04c92783          	lw	a5,76(s2)
    80003880:	02f4fe63          	bgeu	s1,a5,800038bc <dirlookup+0x94>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003884:	874e                	mv	a4,s3
    80003886:	86a6                	mv	a3,s1
    80003888:	8652                	mv	a2,s4
    8000388a:	4581                	li	a1,0
    8000388c:	854a                	mv	a0,s2
    8000388e:	d93ff0ef          	jal	80003620 <readi>
    80003892:	fd351ee3          	bne	a0,s3,8000386e <dirlookup+0x46>
    if(de.inum == 0)
    80003896:	fa045783          	lhu	a5,-96(s0)
    8000389a:	d3e5                	beqz	a5,8000387a <dirlookup+0x52>
    if(namecmp(name, de.name) == 0){
    8000389c:	85da                	mv	a1,s6
    8000389e:	8556                	mv	a0,s5
    800038a0:	f73ff0ef          	jal	80003812 <namecmp>
    800038a4:	f979                	bnez	a0,8000387a <dirlookup+0x52>
      if(poff)
    800038a6:	000b8463          	beqz	s7,800038ae <dirlookup+0x86>
        *poff = off;
    800038aa:	009ba023          	sw	s1,0(s7)
      return iget(dp->dev, inum);
    800038ae:	fa045583          	lhu	a1,-96(s0)
    800038b2:	00092503          	lw	a0,0(s2)
    800038b6:	f66ff0ef          	jal	8000301c <iget>
    800038ba:	a011                	j	800038be <dirlookup+0x96>
  return 0;
    800038bc:	4501                	li	a0,0
}
    800038be:	60e6                	ld	ra,88(sp)
    800038c0:	6446                	ld	s0,80(sp)
    800038c2:	64a6                	ld	s1,72(sp)
    800038c4:	6906                	ld	s2,64(sp)
    800038c6:	79e2                	ld	s3,56(sp)
    800038c8:	7a42                	ld	s4,48(sp)
    800038ca:	7aa2                	ld	s5,40(sp)
    800038cc:	7b02                	ld	s6,32(sp)
    800038ce:	6be2                	ld	s7,24(sp)
    800038d0:	6125                	addi	sp,sp,96
    800038d2:	8082                	ret

00000000800038d4 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    800038d4:	711d                	addi	sp,sp,-96
    800038d6:	ec86                	sd	ra,88(sp)
    800038d8:	e8a2                	sd	s0,80(sp)
    800038da:	e4a6                	sd	s1,72(sp)
    800038dc:	e0ca                	sd	s2,64(sp)
    800038de:	fc4e                	sd	s3,56(sp)
    800038e0:	f852                	sd	s4,48(sp)
    800038e2:	f456                	sd	s5,40(sp)
    800038e4:	f05a                	sd	s6,32(sp)
    800038e6:	ec5e                	sd	s7,24(sp)
    800038e8:	e862                	sd	s8,16(sp)
    800038ea:	e466                	sd	s9,8(sp)
    800038ec:	e06a                	sd	s10,0(sp)
    800038ee:	1080                	addi	s0,sp,96
    800038f0:	84aa                	mv	s1,a0
    800038f2:	8b2e                	mv	s6,a1
    800038f4:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    800038f6:	00054703          	lbu	a4,0(a0)
    800038fa:	02f00793          	li	a5,47
    800038fe:	00f70f63          	beq	a4,a5,8000391c <namex+0x48>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80003902:	862fe0ef          	jal	80001964 <myproc>
    80003906:	15053503          	ld	a0,336(a0)
    8000390a:	94fff0ef          	jal	80003258 <idup>
    8000390e:	8a2a                	mv	s4,a0
  while(*path == '/')
    80003910:	02f00993          	li	s3,47
  if(len >= DIRSIZ)
    80003914:	4c35                	li	s8,13
    memmove(name, s, DIRSIZ);
    80003916:	4cb9                	li	s9,14

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80003918:	4b85                	li	s7,1
    8000391a:	a879                	j	800039b8 <namex+0xe4>
    ip = iget(ROOTDEV, ROOTINO);
    8000391c:	4585                	li	a1,1
    8000391e:	852e                	mv	a0,a1
    80003920:	efcff0ef          	jal	8000301c <iget>
    80003924:	8a2a                	mv	s4,a0
    80003926:	b7ed                	j	80003910 <namex+0x3c>
      iunlockput(ip);
    80003928:	8552                	mv	a0,s4
    8000392a:	b71ff0ef          	jal	8000349a <iunlockput>
      return 0;
    8000392e:	4a01                	li	s4,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80003930:	8552                	mv	a0,s4
    80003932:	60e6                	ld	ra,88(sp)
    80003934:	6446                	ld	s0,80(sp)
    80003936:	64a6                	ld	s1,72(sp)
    80003938:	6906                	ld	s2,64(sp)
    8000393a:	79e2                	ld	s3,56(sp)
    8000393c:	7a42                	ld	s4,48(sp)
    8000393e:	7aa2                	ld	s5,40(sp)
    80003940:	7b02                	ld	s6,32(sp)
    80003942:	6be2                	ld	s7,24(sp)
    80003944:	6c42                	ld	s8,16(sp)
    80003946:	6ca2                	ld	s9,8(sp)
    80003948:	6d02                	ld	s10,0(sp)
    8000394a:	6125                	addi	sp,sp,96
    8000394c:	8082                	ret
      iunlock(ip);
    8000394e:	8552                	mv	a0,s4
    80003950:	9edff0ef          	jal	8000333c <iunlock>
      return ip;
    80003954:	bff1                	j	80003930 <namex+0x5c>
      iunlockput(ip);
    80003956:	8552                	mv	a0,s4
    80003958:	b43ff0ef          	jal	8000349a <iunlockput>
      return 0;
    8000395c:	8a4a                	mv	s4,s2
    8000395e:	bfc9                	j	80003930 <namex+0x5c>
  len = path - s;
    80003960:	40990633          	sub	a2,s2,s1
    80003964:	00060d1b          	sext.w	s10,a2
  if(len >= DIRSIZ)
    80003968:	09ac5463          	bge	s8,s10,800039f0 <namex+0x11c>
    memmove(name, s, DIRSIZ);
    8000396c:	8666                	mv	a2,s9
    8000396e:	85a6                	mv	a1,s1
    80003970:	8556                	mv	a0,s5
    80003972:	c18fd0ef          	jal	80000d8a <memmove>
    80003976:	84ca                	mv	s1,s2
  while(*path == '/')
    80003978:	0004c783          	lbu	a5,0(s1)
    8000397c:	01379763          	bne	a5,s3,8000398a <namex+0xb6>
    path++;
    80003980:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003982:	0004c783          	lbu	a5,0(s1)
    80003986:	ff378de3          	beq	a5,s3,80003980 <namex+0xac>
    ilock(ip);
    8000398a:	8552                	mv	a0,s4
    8000398c:	903ff0ef          	jal	8000328e <ilock>
    if(ip->type != T_DIR){
    80003990:	044a1783          	lh	a5,68(s4)
    80003994:	f9779ae3          	bne	a5,s7,80003928 <namex+0x54>
    if(nameiparent && *path == '\0'){
    80003998:	000b0563          	beqz	s6,800039a2 <namex+0xce>
    8000399c:	0004c783          	lbu	a5,0(s1)
    800039a0:	d7dd                	beqz	a5,8000394e <namex+0x7a>
    if((next = dirlookup(ip, name, 0)) == 0){
    800039a2:	4601                	li	a2,0
    800039a4:	85d6                	mv	a1,s5
    800039a6:	8552                	mv	a0,s4
    800039a8:	e81ff0ef          	jal	80003828 <dirlookup>
    800039ac:	892a                	mv	s2,a0
    800039ae:	d545                	beqz	a0,80003956 <namex+0x82>
    iunlockput(ip);
    800039b0:	8552                	mv	a0,s4
    800039b2:	ae9ff0ef          	jal	8000349a <iunlockput>
    ip = next;
    800039b6:	8a4a                	mv	s4,s2
  while(*path == '/')
    800039b8:	0004c783          	lbu	a5,0(s1)
    800039bc:	01379763          	bne	a5,s3,800039ca <namex+0xf6>
    path++;
    800039c0:	0485                	addi	s1,s1,1
  while(*path == '/')
    800039c2:	0004c783          	lbu	a5,0(s1)
    800039c6:	ff378de3          	beq	a5,s3,800039c0 <namex+0xec>
  if(*path == 0)
    800039ca:	cf8d                	beqz	a5,80003a04 <namex+0x130>
  while(*path != '/' && *path != 0)
    800039cc:	0004c783          	lbu	a5,0(s1)
    800039d0:	fd178713          	addi	a4,a5,-47
    800039d4:	cb19                	beqz	a4,800039ea <namex+0x116>
    800039d6:	cb91                	beqz	a5,800039ea <namex+0x116>
    800039d8:	8926                	mv	s2,s1
    path++;
    800039da:	0905                	addi	s2,s2,1
  while(*path != '/' && *path != 0)
    800039dc:	00094783          	lbu	a5,0(s2)
    800039e0:	fd178713          	addi	a4,a5,-47
    800039e4:	df35                	beqz	a4,80003960 <namex+0x8c>
    800039e6:	fbf5                	bnez	a5,800039da <namex+0x106>
    800039e8:	bfa5                	j	80003960 <namex+0x8c>
    800039ea:	8926                	mv	s2,s1
  len = path - s;
    800039ec:	4d01                	li	s10,0
    800039ee:	4601                	li	a2,0
    memmove(name, s, len);
    800039f0:	2601                	sext.w	a2,a2
    800039f2:	85a6                	mv	a1,s1
    800039f4:	8556                	mv	a0,s5
    800039f6:	b94fd0ef          	jal	80000d8a <memmove>
    name[len] = 0;
    800039fa:	9d56                	add	s10,s10,s5
    800039fc:	000d0023          	sb	zero,0(s10) # fffffffffffff000 <end+0xffffffff7ffcb6e8>
    80003a00:	84ca                	mv	s1,s2
    80003a02:	bf9d                	j	80003978 <namex+0xa4>
  if(nameiparent){
    80003a04:	f20b06e3          	beqz	s6,80003930 <namex+0x5c>
    iput(ip);
    80003a08:	8552                	mv	a0,s4
    80003a0a:	a07ff0ef          	jal	80003410 <iput>
    return 0;
    80003a0e:	4a01                	li	s4,0
    80003a10:	b705                	j	80003930 <namex+0x5c>

0000000080003a12 <dirlink>:
{
    80003a12:	715d                	addi	sp,sp,-80
    80003a14:	e486                	sd	ra,72(sp)
    80003a16:	e0a2                	sd	s0,64(sp)
    80003a18:	f84a                	sd	s2,48(sp)
    80003a1a:	ec56                	sd	s5,24(sp)
    80003a1c:	e85a                	sd	s6,16(sp)
    80003a1e:	0880                	addi	s0,sp,80
    80003a20:	892a                	mv	s2,a0
    80003a22:	8aae                	mv	s5,a1
    80003a24:	8b32                	mv	s6,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80003a26:	4601                	li	a2,0
    80003a28:	e01ff0ef          	jal	80003828 <dirlookup>
    80003a2c:	ed1d                	bnez	a0,80003a6a <dirlink+0x58>
    80003a2e:	fc26                	sd	s1,56(sp)
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003a30:	04c92483          	lw	s1,76(s2)
    80003a34:	c4b9                	beqz	s1,80003a82 <dirlink+0x70>
    80003a36:	f44e                	sd	s3,40(sp)
    80003a38:	f052                	sd	s4,32(sp)
    80003a3a:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003a3c:	fb040a13          	addi	s4,s0,-80
    80003a40:	49c1                	li	s3,16
    80003a42:	874e                	mv	a4,s3
    80003a44:	86a6                	mv	a3,s1
    80003a46:	8652                	mv	a2,s4
    80003a48:	4581                	li	a1,0
    80003a4a:	854a                	mv	a0,s2
    80003a4c:	bd5ff0ef          	jal	80003620 <readi>
    80003a50:	03351163          	bne	a0,s3,80003a72 <dirlink+0x60>
    if(de.inum == 0)
    80003a54:	fb045783          	lhu	a5,-80(s0)
    80003a58:	c39d                	beqz	a5,80003a7e <dirlink+0x6c>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003a5a:	24c1                	addiw	s1,s1,16
    80003a5c:	04c92783          	lw	a5,76(s2)
    80003a60:	fef4e1e3          	bltu	s1,a5,80003a42 <dirlink+0x30>
    80003a64:	79a2                	ld	s3,40(sp)
    80003a66:	7a02                	ld	s4,32(sp)
    80003a68:	a829                	j	80003a82 <dirlink+0x70>
    iput(ip);
    80003a6a:	9a7ff0ef          	jal	80003410 <iput>
    return -1;
    80003a6e:	557d                	li	a0,-1
    80003a70:	a83d                	j	80003aae <dirlink+0x9c>
      panic("dirlink read");
    80003a72:	00004517          	auipc	a0,0x4
    80003a76:	a6650513          	addi	a0,a0,-1434 # 800074d8 <etext+0x4d8>
    80003a7a:	dddfc0ef          	jal	80000856 <panic>
    80003a7e:	79a2                	ld	s3,40(sp)
    80003a80:	7a02                	ld	s4,32(sp)
  strncpy(de.name, name, DIRSIZ);
    80003a82:	4639                	li	a2,14
    80003a84:	85d6                	mv	a1,s5
    80003a86:	fb240513          	addi	a0,s0,-78
    80003a8a:	baefd0ef          	jal	80000e38 <strncpy>
  de.inum = inum;
    80003a8e:	fb641823          	sh	s6,-80(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003a92:	4741                	li	a4,16
    80003a94:	86a6                	mv	a3,s1
    80003a96:	fb040613          	addi	a2,s0,-80
    80003a9a:	4581                	li	a1,0
    80003a9c:	854a                	mv	a0,s2
    80003a9e:	c75ff0ef          	jal	80003712 <writei>
    80003aa2:	1541                	addi	a0,a0,-16
    80003aa4:	00a03533          	snez	a0,a0
    80003aa8:	40a0053b          	negw	a0,a0
    80003aac:	74e2                	ld	s1,56(sp)
}
    80003aae:	60a6                	ld	ra,72(sp)
    80003ab0:	6406                	ld	s0,64(sp)
    80003ab2:	7942                	ld	s2,48(sp)
    80003ab4:	6ae2                	ld	s5,24(sp)
    80003ab6:	6b42                	ld	s6,16(sp)
    80003ab8:	6161                	addi	sp,sp,80
    80003aba:	8082                	ret

0000000080003abc <namei>:

struct inode*
namei(char *path)
{
    80003abc:	1101                	addi	sp,sp,-32
    80003abe:	ec06                	sd	ra,24(sp)
    80003ac0:	e822                	sd	s0,16(sp)
    80003ac2:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80003ac4:	fe040613          	addi	a2,s0,-32
    80003ac8:	4581                	li	a1,0
    80003aca:	e0bff0ef          	jal	800038d4 <namex>
}
    80003ace:	60e2                	ld	ra,24(sp)
    80003ad0:	6442                	ld	s0,16(sp)
    80003ad2:	6105                	addi	sp,sp,32
    80003ad4:	8082                	ret

0000000080003ad6 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    80003ad6:	1141                	addi	sp,sp,-16
    80003ad8:	e406                	sd	ra,8(sp)
    80003ada:	e022                	sd	s0,0(sp)
    80003adc:	0800                	addi	s0,sp,16
    80003ade:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80003ae0:	4585                	li	a1,1
    80003ae2:	df3ff0ef          	jal	800038d4 <namex>
}
    80003ae6:	60a2                	ld	ra,8(sp)
    80003ae8:	6402                	ld	s0,0(sp)
    80003aea:	0141                	addi	sp,sp,16
    80003aec:	8082                	ret

0000000080003aee <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80003aee:	1101                	addi	sp,sp,-32
    80003af0:	ec06                	sd	ra,24(sp)
    80003af2:	e822                	sd	s0,16(sp)
    80003af4:	e426                	sd	s1,8(sp)
    80003af6:	e04a                	sd	s2,0(sp)
    80003af8:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80003afa:	0001f917          	auipc	s2,0x1f
    80003afe:	b7e90913          	addi	s2,s2,-1154 # 80022678 <log>
    80003b02:	01892583          	lw	a1,24(s2)
    80003b06:	02492503          	lw	a0,36(s2)
    80003b0a:	8aeff0ef          	jal	80002bb8 <bread>
    80003b0e:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    80003b10:	02892603          	lw	a2,40(s2)
    80003b14:	cd30                	sw	a2,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80003b16:	00c05f63          	blez	a2,80003b34 <write_head+0x46>
    80003b1a:	0001f717          	auipc	a4,0x1f
    80003b1e:	b8a70713          	addi	a4,a4,-1142 # 800226a4 <log+0x2c>
    80003b22:	87aa                	mv	a5,a0
    80003b24:	060a                	slli	a2,a2,0x2
    80003b26:	962a                	add	a2,a2,a0
    hb->block[i] = log.lh.block[i];
    80003b28:	4314                	lw	a3,0(a4)
    80003b2a:	cff4                	sw	a3,92(a5)
  for (i = 0; i < log.lh.n; i++) {
    80003b2c:	0711                	addi	a4,a4,4
    80003b2e:	0791                	addi	a5,a5,4
    80003b30:	fec79ce3          	bne	a5,a2,80003b28 <write_head+0x3a>
  }
  bwrite(buf);
    80003b34:	8526                	mv	a0,s1
    80003b36:	980ff0ef          	jal	80002cb6 <bwrite>
  brelse(buf);
    80003b3a:	8526                	mv	a0,s1
    80003b3c:	9acff0ef          	jal	80002ce8 <brelse>
}
    80003b40:	60e2                	ld	ra,24(sp)
    80003b42:	6442                	ld	s0,16(sp)
    80003b44:	64a2                	ld	s1,8(sp)
    80003b46:	6902                	ld	s2,0(sp)
    80003b48:	6105                	addi	sp,sp,32
    80003b4a:	8082                	ret

0000000080003b4c <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80003b4c:	0001f797          	auipc	a5,0x1f
    80003b50:	b547a783          	lw	a5,-1196(a5) # 800226a0 <log+0x28>
    80003b54:	0cf05163          	blez	a5,80003c16 <install_trans+0xca>
{
    80003b58:	715d                	addi	sp,sp,-80
    80003b5a:	e486                	sd	ra,72(sp)
    80003b5c:	e0a2                	sd	s0,64(sp)
    80003b5e:	fc26                	sd	s1,56(sp)
    80003b60:	f84a                	sd	s2,48(sp)
    80003b62:	f44e                	sd	s3,40(sp)
    80003b64:	f052                	sd	s4,32(sp)
    80003b66:	ec56                	sd	s5,24(sp)
    80003b68:	e85a                	sd	s6,16(sp)
    80003b6a:	e45e                	sd	s7,8(sp)
    80003b6c:	e062                	sd	s8,0(sp)
    80003b6e:	0880                	addi	s0,sp,80
    80003b70:	8b2a                	mv	s6,a0
    80003b72:	0001fa97          	auipc	s5,0x1f
    80003b76:	b32a8a93          	addi	s5,s5,-1230 # 800226a4 <log+0x2c>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003b7a:	4981                	li	s3,0
      printf("recovering tail %d dst %d\n", tail, log.lh.block[tail]);
    80003b7c:	00004c17          	auipc	s8,0x4
    80003b80:	96cc0c13          	addi	s8,s8,-1684 # 800074e8 <etext+0x4e8>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80003b84:	0001fa17          	auipc	s4,0x1f
    80003b88:	af4a0a13          	addi	s4,s4,-1292 # 80022678 <log>
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80003b8c:	40000b93          	li	s7,1024
    80003b90:	a025                	j	80003bb8 <install_trans+0x6c>
      printf("recovering tail %d dst %d\n", tail, log.lh.block[tail]);
    80003b92:	000aa603          	lw	a2,0(s5)
    80003b96:	85ce                	mv	a1,s3
    80003b98:	8562                	mv	a0,s8
    80003b9a:	993fc0ef          	jal	8000052c <printf>
    80003b9e:	a839                	j	80003bbc <install_trans+0x70>
    brelse(lbuf);
    80003ba0:	854a                	mv	a0,s2
    80003ba2:	946ff0ef          	jal	80002ce8 <brelse>
    brelse(dbuf);
    80003ba6:	8526                	mv	a0,s1
    80003ba8:	940ff0ef          	jal	80002ce8 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003bac:	2985                	addiw	s3,s3,1
    80003bae:	0a91                	addi	s5,s5,4
    80003bb0:	028a2783          	lw	a5,40(s4)
    80003bb4:	04f9d563          	bge	s3,a5,80003bfe <install_trans+0xb2>
    if(recovering) {
    80003bb8:	fc0b1de3          	bnez	s6,80003b92 <install_trans+0x46>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80003bbc:	018a2583          	lw	a1,24(s4)
    80003bc0:	013585bb          	addw	a1,a1,s3
    80003bc4:	2585                	addiw	a1,a1,1
    80003bc6:	024a2503          	lw	a0,36(s4)
    80003bca:	feffe0ef          	jal	80002bb8 <bread>
    80003bce:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    80003bd0:	000aa583          	lw	a1,0(s5)
    80003bd4:	024a2503          	lw	a0,36(s4)
    80003bd8:	fe1fe0ef          	jal	80002bb8 <bread>
    80003bdc:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80003bde:	865e                	mv	a2,s7
    80003be0:	05890593          	addi	a1,s2,88
    80003be4:	05850513          	addi	a0,a0,88
    80003be8:	9a2fd0ef          	jal	80000d8a <memmove>
    bwrite(dbuf);  // write dst to disk
    80003bec:	8526                	mv	a0,s1
    80003bee:	8c8ff0ef          	jal	80002cb6 <bwrite>
    if(recovering == 0)
    80003bf2:	fa0b17e3          	bnez	s6,80003ba0 <install_trans+0x54>
      bunpin(dbuf);
    80003bf6:	8526                	mv	a0,s1
    80003bf8:	9beff0ef          	jal	80002db6 <bunpin>
    80003bfc:	b755                	j	80003ba0 <install_trans+0x54>
}
    80003bfe:	60a6                	ld	ra,72(sp)
    80003c00:	6406                	ld	s0,64(sp)
    80003c02:	74e2                	ld	s1,56(sp)
    80003c04:	7942                	ld	s2,48(sp)
    80003c06:	79a2                	ld	s3,40(sp)
    80003c08:	7a02                	ld	s4,32(sp)
    80003c0a:	6ae2                	ld	s5,24(sp)
    80003c0c:	6b42                	ld	s6,16(sp)
    80003c0e:	6ba2                	ld	s7,8(sp)
    80003c10:	6c02                	ld	s8,0(sp)
    80003c12:	6161                	addi	sp,sp,80
    80003c14:	8082                	ret
    80003c16:	8082                	ret

0000000080003c18 <initlog>:
{
    80003c18:	7179                	addi	sp,sp,-48
    80003c1a:	f406                	sd	ra,40(sp)
    80003c1c:	f022                	sd	s0,32(sp)
    80003c1e:	ec26                	sd	s1,24(sp)
    80003c20:	e84a                	sd	s2,16(sp)
    80003c22:	e44e                	sd	s3,8(sp)
    80003c24:	1800                	addi	s0,sp,48
    80003c26:	84aa                	mv	s1,a0
    80003c28:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    80003c2a:	0001f917          	auipc	s2,0x1f
    80003c2e:	a4e90913          	addi	s2,s2,-1458 # 80022678 <log>
    80003c32:	00004597          	auipc	a1,0x4
    80003c36:	8d658593          	addi	a1,a1,-1834 # 80007508 <etext+0x508>
    80003c3a:	854a                	mv	a0,s2
    80003c3c:	f95fc0ef          	jal	80000bd0 <initlock>
  log.start = sb->logstart;
    80003c40:	0149a583          	lw	a1,20(s3)
    80003c44:	00b92c23          	sw	a1,24(s2)
  log.dev = dev;
    80003c48:	02992223          	sw	s1,36(s2)
  struct buf *buf = bread(log.dev, log.start);
    80003c4c:	8526                	mv	a0,s1
    80003c4e:	f6bfe0ef          	jal	80002bb8 <bread>
  log.lh.n = lh->n;
    80003c52:	4d30                	lw	a2,88(a0)
    80003c54:	02c92423          	sw	a2,40(s2)
  for (i = 0; i < log.lh.n; i++) {
    80003c58:	00c05f63          	blez	a2,80003c76 <initlog+0x5e>
    80003c5c:	87aa                	mv	a5,a0
    80003c5e:	0001f717          	auipc	a4,0x1f
    80003c62:	a4670713          	addi	a4,a4,-1466 # 800226a4 <log+0x2c>
    80003c66:	060a                	slli	a2,a2,0x2
    80003c68:	962a                	add	a2,a2,a0
    log.lh.block[i] = lh->block[i];
    80003c6a:	4ff4                	lw	a3,92(a5)
    80003c6c:	c314                	sw	a3,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80003c6e:	0791                	addi	a5,a5,4
    80003c70:	0711                	addi	a4,a4,4
    80003c72:	fec79ce3          	bne	a5,a2,80003c6a <initlog+0x52>
  brelse(buf);
    80003c76:	872ff0ef          	jal	80002ce8 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    80003c7a:	4505                	li	a0,1
    80003c7c:	ed1ff0ef          	jal	80003b4c <install_trans>
  log.lh.n = 0;
    80003c80:	0001f797          	auipc	a5,0x1f
    80003c84:	a207a023          	sw	zero,-1504(a5) # 800226a0 <log+0x28>
  write_head(); // clear the log
    80003c88:	e67ff0ef          	jal	80003aee <write_head>
}
    80003c8c:	70a2                	ld	ra,40(sp)
    80003c8e:	7402                	ld	s0,32(sp)
    80003c90:	64e2                	ld	s1,24(sp)
    80003c92:	6942                	ld	s2,16(sp)
    80003c94:	69a2                	ld	s3,8(sp)
    80003c96:	6145                	addi	sp,sp,48
    80003c98:	8082                	ret

0000000080003c9a <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    80003c9a:	1101                	addi	sp,sp,-32
    80003c9c:	ec06                	sd	ra,24(sp)
    80003c9e:	e822                	sd	s0,16(sp)
    80003ca0:	e426                	sd	s1,8(sp)
    80003ca2:	e04a                	sd	s2,0(sp)
    80003ca4:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    80003ca6:	0001f517          	auipc	a0,0x1f
    80003caa:	9d250513          	addi	a0,a0,-1582 # 80022678 <log>
    80003cae:	fadfc0ef          	jal	80000c5a <acquire>
  while(1){
    if(log.committing){
    80003cb2:	0001f497          	auipc	s1,0x1f
    80003cb6:	9c648493          	addi	s1,s1,-1594 # 80022678 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGBLOCKS){
    80003cba:	4979                	li	s2,30
    80003cbc:	a029                	j	80003cc6 <begin_op+0x2c>
      sleep(&log, &log.lock);
    80003cbe:	85a6                	mv	a1,s1
    80003cc0:	8526                	mv	a0,s1
    80003cc2:	ab8fe0ef          	jal	80001f7a <sleep>
    if(log.committing){
    80003cc6:	509c                	lw	a5,32(s1)
    80003cc8:	fbfd                	bnez	a5,80003cbe <begin_op+0x24>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGBLOCKS){
    80003cca:	4cd8                	lw	a4,28(s1)
    80003ccc:	2705                	addiw	a4,a4,1
    80003cce:	0027179b          	slliw	a5,a4,0x2
    80003cd2:	9fb9                	addw	a5,a5,a4
    80003cd4:	0017979b          	slliw	a5,a5,0x1
    80003cd8:	5494                	lw	a3,40(s1)
    80003cda:	9fb5                	addw	a5,a5,a3
    80003cdc:	00f95763          	bge	s2,a5,80003cea <begin_op+0x50>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    80003ce0:	85a6                	mv	a1,s1
    80003ce2:	8526                	mv	a0,s1
    80003ce4:	a96fe0ef          	jal	80001f7a <sleep>
    80003ce8:	bff9                	j	80003cc6 <begin_op+0x2c>
    } else {
      log.outstanding += 1;
    80003cea:	0001f797          	auipc	a5,0x1f
    80003cee:	9ae7a523          	sw	a4,-1622(a5) # 80022694 <log+0x1c>
      release(&log.lock);
    80003cf2:	0001f517          	auipc	a0,0x1f
    80003cf6:	98650513          	addi	a0,a0,-1658 # 80022678 <log>
    80003cfa:	ff5fc0ef          	jal	80000cee <release>
      break;
    }
  }
}
    80003cfe:	60e2                	ld	ra,24(sp)
    80003d00:	6442                	ld	s0,16(sp)
    80003d02:	64a2                	ld	s1,8(sp)
    80003d04:	6902                	ld	s2,0(sp)
    80003d06:	6105                	addi	sp,sp,32
    80003d08:	8082                	ret

0000000080003d0a <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    80003d0a:	7139                	addi	sp,sp,-64
    80003d0c:	fc06                	sd	ra,56(sp)
    80003d0e:	f822                	sd	s0,48(sp)
    80003d10:	f426                	sd	s1,40(sp)
    80003d12:	f04a                	sd	s2,32(sp)
    80003d14:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    80003d16:	0001f497          	auipc	s1,0x1f
    80003d1a:	96248493          	addi	s1,s1,-1694 # 80022678 <log>
    80003d1e:	8526                	mv	a0,s1
    80003d20:	f3bfc0ef          	jal	80000c5a <acquire>
  log.outstanding -= 1;
    80003d24:	4cdc                	lw	a5,28(s1)
    80003d26:	37fd                	addiw	a5,a5,-1
    80003d28:	893e                	mv	s2,a5
    80003d2a:	ccdc                	sw	a5,28(s1)
  if(log.committing)
    80003d2c:	509c                	lw	a5,32(s1)
    80003d2e:	e7b1                	bnez	a5,80003d7a <end_op+0x70>
    panic("log.committing");
  if(log.outstanding == 0){
    80003d30:	04091e63          	bnez	s2,80003d8c <end_op+0x82>
    do_commit = 1;
    log.committing = 1;
    80003d34:	0001f497          	auipc	s1,0x1f
    80003d38:	94448493          	addi	s1,s1,-1724 # 80022678 <log>
    80003d3c:	4785                	li	a5,1
    80003d3e:	d09c                	sw	a5,32(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    80003d40:	8526                	mv	a0,s1
    80003d42:	fadfc0ef          	jal	80000cee <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    80003d46:	549c                	lw	a5,40(s1)
    80003d48:	06f04463          	bgtz	a5,80003db0 <end_op+0xa6>
    acquire(&log.lock);
    80003d4c:	0001f517          	auipc	a0,0x1f
    80003d50:	92c50513          	addi	a0,a0,-1748 # 80022678 <log>
    80003d54:	f07fc0ef          	jal	80000c5a <acquire>
    log.committing = 0;
    80003d58:	0001f797          	auipc	a5,0x1f
    80003d5c:	9407a023          	sw	zero,-1728(a5) # 80022698 <log+0x20>
    wakeup(&log);
    80003d60:	0001f517          	auipc	a0,0x1f
    80003d64:	91850513          	addi	a0,a0,-1768 # 80022678 <log>
    80003d68:	a5efe0ef          	jal	80001fc6 <wakeup>
    release(&log.lock);
    80003d6c:	0001f517          	auipc	a0,0x1f
    80003d70:	90c50513          	addi	a0,a0,-1780 # 80022678 <log>
    80003d74:	f7bfc0ef          	jal	80000cee <release>
}
    80003d78:	a035                	j	80003da4 <end_op+0x9a>
    80003d7a:	ec4e                	sd	s3,24(sp)
    80003d7c:	e852                	sd	s4,16(sp)
    80003d7e:	e456                	sd	s5,8(sp)
    panic("log.committing");
    80003d80:	00003517          	auipc	a0,0x3
    80003d84:	79050513          	addi	a0,a0,1936 # 80007510 <etext+0x510>
    80003d88:	acffc0ef          	jal	80000856 <panic>
    wakeup(&log);
    80003d8c:	0001f517          	auipc	a0,0x1f
    80003d90:	8ec50513          	addi	a0,a0,-1812 # 80022678 <log>
    80003d94:	a32fe0ef          	jal	80001fc6 <wakeup>
  release(&log.lock);
    80003d98:	0001f517          	auipc	a0,0x1f
    80003d9c:	8e050513          	addi	a0,a0,-1824 # 80022678 <log>
    80003da0:	f4ffc0ef          	jal	80000cee <release>
}
    80003da4:	70e2                	ld	ra,56(sp)
    80003da6:	7442                	ld	s0,48(sp)
    80003da8:	74a2                	ld	s1,40(sp)
    80003daa:	7902                	ld	s2,32(sp)
    80003dac:	6121                	addi	sp,sp,64
    80003dae:	8082                	ret
    80003db0:	ec4e                	sd	s3,24(sp)
    80003db2:	e852                	sd	s4,16(sp)
    80003db4:	e456                	sd	s5,8(sp)
  for (tail = 0; tail < log.lh.n; tail++) {
    80003db6:	0001fa97          	auipc	s5,0x1f
    80003dba:	8eea8a93          	addi	s5,s5,-1810 # 800226a4 <log+0x2c>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    80003dbe:	0001fa17          	auipc	s4,0x1f
    80003dc2:	8baa0a13          	addi	s4,s4,-1862 # 80022678 <log>
    80003dc6:	018a2583          	lw	a1,24(s4)
    80003dca:	012585bb          	addw	a1,a1,s2
    80003dce:	2585                	addiw	a1,a1,1
    80003dd0:	024a2503          	lw	a0,36(s4)
    80003dd4:	de5fe0ef          	jal	80002bb8 <bread>
    80003dd8:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    80003dda:	000aa583          	lw	a1,0(s5)
    80003dde:	024a2503          	lw	a0,36(s4)
    80003de2:	dd7fe0ef          	jal	80002bb8 <bread>
    80003de6:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    80003de8:	40000613          	li	a2,1024
    80003dec:	05850593          	addi	a1,a0,88
    80003df0:	05848513          	addi	a0,s1,88
    80003df4:	f97fc0ef          	jal	80000d8a <memmove>
    bwrite(to);  // write the log
    80003df8:	8526                	mv	a0,s1
    80003dfa:	ebdfe0ef          	jal	80002cb6 <bwrite>
    brelse(from);
    80003dfe:	854e                	mv	a0,s3
    80003e00:	ee9fe0ef          	jal	80002ce8 <brelse>
    brelse(to);
    80003e04:	8526                	mv	a0,s1
    80003e06:	ee3fe0ef          	jal	80002ce8 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003e0a:	2905                	addiw	s2,s2,1
    80003e0c:	0a91                	addi	s5,s5,4
    80003e0e:	028a2783          	lw	a5,40(s4)
    80003e12:	faf94ae3          	blt	s2,a5,80003dc6 <end_op+0xbc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    80003e16:	cd9ff0ef          	jal	80003aee <write_head>
    install_trans(0); // Now install writes to home locations
    80003e1a:	4501                	li	a0,0
    80003e1c:	d31ff0ef          	jal	80003b4c <install_trans>
    log.lh.n = 0;
    80003e20:	0001f797          	auipc	a5,0x1f
    80003e24:	8807a023          	sw	zero,-1920(a5) # 800226a0 <log+0x28>
    write_head();    // Erase the transaction from the log
    80003e28:	cc7ff0ef          	jal	80003aee <write_head>
    80003e2c:	69e2                	ld	s3,24(sp)
    80003e2e:	6a42                	ld	s4,16(sp)
    80003e30:	6aa2                	ld	s5,8(sp)
    80003e32:	bf29                	j	80003d4c <end_op+0x42>

0000000080003e34 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    80003e34:	1101                	addi	sp,sp,-32
    80003e36:	ec06                	sd	ra,24(sp)
    80003e38:	e822                	sd	s0,16(sp)
    80003e3a:	e426                	sd	s1,8(sp)
    80003e3c:	1000                	addi	s0,sp,32
    80003e3e:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    80003e40:	0001f517          	auipc	a0,0x1f
    80003e44:	83850513          	addi	a0,a0,-1992 # 80022678 <log>
    80003e48:	e13fc0ef          	jal	80000c5a <acquire>
  if (log.lh.n >= LOGBLOCKS)
    80003e4c:	0001f617          	auipc	a2,0x1f
    80003e50:	85462603          	lw	a2,-1964(a2) # 800226a0 <log+0x28>
    80003e54:	47f5                	li	a5,29
    80003e56:	04c7cd63          	blt	a5,a2,80003eb0 <log_write+0x7c>
    panic("too big a transaction");
  if (log.outstanding < 1)
    80003e5a:	0001f797          	auipc	a5,0x1f
    80003e5e:	83a7a783          	lw	a5,-1990(a5) # 80022694 <log+0x1c>
    80003e62:	04f05d63          	blez	a5,80003ebc <log_write+0x88>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    80003e66:	4781                	li	a5,0
    80003e68:	06c05063          	blez	a2,80003ec8 <log_write+0x94>
    if (log.lh.block[i] == b->blockno)   // log absorption
    80003e6c:	44cc                	lw	a1,12(s1)
    80003e6e:	0001f717          	auipc	a4,0x1f
    80003e72:	83670713          	addi	a4,a4,-1994 # 800226a4 <log+0x2c>
  for (i = 0; i < log.lh.n; i++) {
    80003e76:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    80003e78:	4314                	lw	a3,0(a4)
    80003e7a:	04b68763          	beq	a3,a1,80003ec8 <log_write+0x94>
  for (i = 0; i < log.lh.n; i++) {
    80003e7e:	2785                	addiw	a5,a5,1
    80003e80:	0711                	addi	a4,a4,4
    80003e82:	fef61be3          	bne	a2,a5,80003e78 <log_write+0x44>
      break;
  }
  log.lh.block[i] = b->blockno;
    80003e86:	060a                	slli	a2,a2,0x2
    80003e88:	02060613          	addi	a2,a2,32
    80003e8c:	0001e797          	auipc	a5,0x1e
    80003e90:	7ec78793          	addi	a5,a5,2028 # 80022678 <log>
    80003e94:	97b2                	add	a5,a5,a2
    80003e96:	44d8                	lw	a4,12(s1)
    80003e98:	c7d8                	sw	a4,12(a5)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    80003e9a:	8526                	mv	a0,s1
    80003e9c:	ee7fe0ef          	jal	80002d82 <bpin>
    log.lh.n++;
    80003ea0:	0001e717          	auipc	a4,0x1e
    80003ea4:	7d870713          	addi	a4,a4,2008 # 80022678 <log>
    80003ea8:	571c                	lw	a5,40(a4)
    80003eaa:	2785                	addiw	a5,a5,1
    80003eac:	d71c                	sw	a5,40(a4)
    80003eae:	a815                	j	80003ee2 <log_write+0xae>
    panic("too big a transaction");
    80003eb0:	00003517          	auipc	a0,0x3
    80003eb4:	67050513          	addi	a0,a0,1648 # 80007520 <etext+0x520>
    80003eb8:	99ffc0ef          	jal	80000856 <panic>
    panic("log_write outside of trans");
    80003ebc:	00003517          	auipc	a0,0x3
    80003ec0:	67c50513          	addi	a0,a0,1660 # 80007538 <etext+0x538>
    80003ec4:	993fc0ef          	jal	80000856 <panic>
  log.lh.block[i] = b->blockno;
    80003ec8:	00279693          	slli	a3,a5,0x2
    80003ecc:	02068693          	addi	a3,a3,32
    80003ed0:	0001e717          	auipc	a4,0x1e
    80003ed4:	7a870713          	addi	a4,a4,1960 # 80022678 <log>
    80003ed8:	9736                	add	a4,a4,a3
    80003eda:	44d4                	lw	a3,12(s1)
    80003edc:	c754                	sw	a3,12(a4)
  if (i == log.lh.n) {  // Add new block to log?
    80003ede:	faf60ee3          	beq	a2,a5,80003e9a <log_write+0x66>
  }
  release(&log.lock);
    80003ee2:	0001e517          	auipc	a0,0x1e
    80003ee6:	79650513          	addi	a0,a0,1942 # 80022678 <log>
    80003eea:	e05fc0ef          	jal	80000cee <release>
}
    80003eee:	60e2                	ld	ra,24(sp)
    80003ef0:	6442                	ld	s0,16(sp)
    80003ef2:	64a2                	ld	s1,8(sp)
    80003ef4:	6105                	addi	sp,sp,32
    80003ef6:	8082                	ret

0000000080003ef8 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    80003ef8:	1101                	addi	sp,sp,-32
    80003efa:	ec06                	sd	ra,24(sp)
    80003efc:	e822                	sd	s0,16(sp)
    80003efe:	e426                	sd	s1,8(sp)
    80003f00:	e04a                	sd	s2,0(sp)
    80003f02:	1000                	addi	s0,sp,32
    80003f04:	84aa                	mv	s1,a0
    80003f06:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    80003f08:	00003597          	auipc	a1,0x3
    80003f0c:	65058593          	addi	a1,a1,1616 # 80007558 <etext+0x558>
    80003f10:	0521                	addi	a0,a0,8
    80003f12:	cbffc0ef          	jal	80000bd0 <initlock>
  lk->name = name;
    80003f16:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    80003f1a:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80003f1e:	0204a423          	sw	zero,40(s1)
}
    80003f22:	60e2                	ld	ra,24(sp)
    80003f24:	6442                	ld	s0,16(sp)
    80003f26:	64a2                	ld	s1,8(sp)
    80003f28:	6902                	ld	s2,0(sp)
    80003f2a:	6105                	addi	sp,sp,32
    80003f2c:	8082                	ret

0000000080003f2e <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    80003f2e:	1101                	addi	sp,sp,-32
    80003f30:	ec06                	sd	ra,24(sp)
    80003f32:	e822                	sd	s0,16(sp)
    80003f34:	e426                	sd	s1,8(sp)
    80003f36:	e04a                	sd	s2,0(sp)
    80003f38:	1000                	addi	s0,sp,32
    80003f3a:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80003f3c:	00850913          	addi	s2,a0,8
    80003f40:	854a                	mv	a0,s2
    80003f42:	d19fc0ef          	jal	80000c5a <acquire>
  while (lk->locked) {
    80003f46:	409c                	lw	a5,0(s1)
    80003f48:	c799                	beqz	a5,80003f56 <acquiresleep+0x28>
    sleep(lk, &lk->lk);
    80003f4a:	85ca                	mv	a1,s2
    80003f4c:	8526                	mv	a0,s1
    80003f4e:	82cfe0ef          	jal	80001f7a <sleep>
  while (lk->locked) {
    80003f52:	409c                	lw	a5,0(s1)
    80003f54:	fbfd                	bnez	a5,80003f4a <acquiresleep+0x1c>
  }
  lk->locked = 1;
    80003f56:	4785                	li	a5,1
    80003f58:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    80003f5a:	a0bfd0ef          	jal	80001964 <myproc>
    80003f5e:	591c                	lw	a5,48(a0)
    80003f60:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    80003f62:	854a                	mv	a0,s2
    80003f64:	d8bfc0ef          	jal	80000cee <release>
}
    80003f68:	60e2                	ld	ra,24(sp)
    80003f6a:	6442                	ld	s0,16(sp)
    80003f6c:	64a2                	ld	s1,8(sp)
    80003f6e:	6902                	ld	s2,0(sp)
    80003f70:	6105                	addi	sp,sp,32
    80003f72:	8082                	ret

0000000080003f74 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    80003f74:	1101                	addi	sp,sp,-32
    80003f76:	ec06                	sd	ra,24(sp)
    80003f78:	e822                	sd	s0,16(sp)
    80003f7a:	e426                	sd	s1,8(sp)
    80003f7c:	e04a                	sd	s2,0(sp)
    80003f7e:	1000                	addi	s0,sp,32
    80003f80:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80003f82:	00850913          	addi	s2,a0,8
    80003f86:	854a                	mv	a0,s2
    80003f88:	cd3fc0ef          	jal	80000c5a <acquire>
  lk->locked = 0;
    80003f8c:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80003f90:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    80003f94:	8526                	mv	a0,s1
    80003f96:	830fe0ef          	jal	80001fc6 <wakeup>
  release(&lk->lk);
    80003f9a:	854a                	mv	a0,s2
    80003f9c:	d53fc0ef          	jal	80000cee <release>
}
    80003fa0:	60e2                	ld	ra,24(sp)
    80003fa2:	6442                	ld	s0,16(sp)
    80003fa4:	64a2                	ld	s1,8(sp)
    80003fa6:	6902                	ld	s2,0(sp)
    80003fa8:	6105                	addi	sp,sp,32
    80003faa:	8082                	ret

0000000080003fac <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    80003fac:	7179                	addi	sp,sp,-48
    80003fae:	f406                	sd	ra,40(sp)
    80003fb0:	f022                	sd	s0,32(sp)
    80003fb2:	ec26                	sd	s1,24(sp)
    80003fb4:	e84a                	sd	s2,16(sp)
    80003fb6:	1800                	addi	s0,sp,48
    80003fb8:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    80003fba:	00850913          	addi	s2,a0,8
    80003fbe:	854a                	mv	a0,s2
    80003fc0:	c9bfc0ef          	jal	80000c5a <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    80003fc4:	409c                	lw	a5,0(s1)
    80003fc6:	ef81                	bnez	a5,80003fde <holdingsleep+0x32>
    80003fc8:	4481                	li	s1,0
  release(&lk->lk);
    80003fca:	854a                	mv	a0,s2
    80003fcc:	d23fc0ef          	jal	80000cee <release>
  return r;
}
    80003fd0:	8526                	mv	a0,s1
    80003fd2:	70a2                	ld	ra,40(sp)
    80003fd4:	7402                	ld	s0,32(sp)
    80003fd6:	64e2                	ld	s1,24(sp)
    80003fd8:	6942                	ld	s2,16(sp)
    80003fda:	6145                	addi	sp,sp,48
    80003fdc:	8082                	ret
    80003fde:	e44e                	sd	s3,8(sp)
  r = lk->locked && (lk->pid == myproc()->pid);
    80003fe0:	0284a983          	lw	s3,40(s1)
    80003fe4:	981fd0ef          	jal	80001964 <myproc>
    80003fe8:	5904                	lw	s1,48(a0)
    80003fea:	413484b3          	sub	s1,s1,s3
    80003fee:	0014b493          	seqz	s1,s1
    80003ff2:	69a2                	ld	s3,8(sp)
    80003ff4:	bfd9                	j	80003fca <holdingsleep+0x1e>

0000000080003ff6 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    80003ff6:	1141                	addi	sp,sp,-16
    80003ff8:	e406                	sd	ra,8(sp)
    80003ffa:	e022                	sd	s0,0(sp)
    80003ffc:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    80003ffe:	00003597          	auipc	a1,0x3
    80004002:	56a58593          	addi	a1,a1,1386 # 80007568 <etext+0x568>
    80004006:	0001e517          	auipc	a0,0x1e
    8000400a:	7ba50513          	addi	a0,a0,1978 # 800227c0 <ftable>
    8000400e:	bc3fc0ef          	jal	80000bd0 <initlock>
}
    80004012:	60a2                	ld	ra,8(sp)
    80004014:	6402                	ld	s0,0(sp)
    80004016:	0141                	addi	sp,sp,16
    80004018:	8082                	ret

000000008000401a <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    8000401a:	1101                	addi	sp,sp,-32
    8000401c:	ec06                	sd	ra,24(sp)
    8000401e:	e822                	sd	s0,16(sp)
    80004020:	e426                	sd	s1,8(sp)
    80004022:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    80004024:	0001e517          	auipc	a0,0x1e
    80004028:	79c50513          	addi	a0,a0,1948 # 800227c0 <ftable>
    8000402c:	c2ffc0ef          	jal	80000c5a <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004030:	0001e497          	auipc	s1,0x1e
    80004034:	7a848493          	addi	s1,s1,1960 # 800227d8 <ftable+0x18>
    80004038:	0001f717          	auipc	a4,0x1f
    8000403c:	74070713          	addi	a4,a4,1856 # 80023778 <disk>
    if(f->ref == 0){
    80004040:	40dc                	lw	a5,4(s1)
    80004042:	cf89                	beqz	a5,8000405c <filealloc+0x42>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004044:	02848493          	addi	s1,s1,40
    80004048:	fee49ce3          	bne	s1,a4,80004040 <filealloc+0x26>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    8000404c:	0001e517          	auipc	a0,0x1e
    80004050:	77450513          	addi	a0,a0,1908 # 800227c0 <ftable>
    80004054:	c9bfc0ef          	jal	80000cee <release>
  return 0;
    80004058:	4481                	li	s1,0
    8000405a:	a809                	j	8000406c <filealloc+0x52>
      f->ref = 1;
    8000405c:	4785                	li	a5,1
    8000405e:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    80004060:	0001e517          	auipc	a0,0x1e
    80004064:	76050513          	addi	a0,a0,1888 # 800227c0 <ftable>
    80004068:	c87fc0ef          	jal	80000cee <release>
}
    8000406c:	8526                	mv	a0,s1
    8000406e:	60e2                	ld	ra,24(sp)
    80004070:	6442                	ld	s0,16(sp)
    80004072:	64a2                	ld	s1,8(sp)
    80004074:	6105                	addi	sp,sp,32
    80004076:	8082                	ret

0000000080004078 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    80004078:	1101                	addi	sp,sp,-32
    8000407a:	ec06                	sd	ra,24(sp)
    8000407c:	e822                	sd	s0,16(sp)
    8000407e:	e426                	sd	s1,8(sp)
    80004080:	1000                	addi	s0,sp,32
    80004082:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80004084:	0001e517          	auipc	a0,0x1e
    80004088:	73c50513          	addi	a0,a0,1852 # 800227c0 <ftable>
    8000408c:	bcffc0ef          	jal	80000c5a <acquire>
  if(f->ref < 1)
    80004090:	40dc                	lw	a5,4(s1)
    80004092:	02f05063          	blez	a5,800040b2 <filedup+0x3a>
    panic("filedup");
  f->ref++;
    80004096:	2785                	addiw	a5,a5,1
    80004098:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    8000409a:	0001e517          	auipc	a0,0x1e
    8000409e:	72650513          	addi	a0,a0,1830 # 800227c0 <ftable>
    800040a2:	c4dfc0ef          	jal	80000cee <release>
  return f;
}
    800040a6:	8526                	mv	a0,s1
    800040a8:	60e2                	ld	ra,24(sp)
    800040aa:	6442                	ld	s0,16(sp)
    800040ac:	64a2                	ld	s1,8(sp)
    800040ae:	6105                	addi	sp,sp,32
    800040b0:	8082                	ret
    panic("filedup");
    800040b2:	00003517          	auipc	a0,0x3
    800040b6:	4be50513          	addi	a0,a0,1214 # 80007570 <etext+0x570>
    800040ba:	f9cfc0ef          	jal	80000856 <panic>

00000000800040be <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    800040be:	7139                	addi	sp,sp,-64
    800040c0:	fc06                	sd	ra,56(sp)
    800040c2:	f822                	sd	s0,48(sp)
    800040c4:	f426                	sd	s1,40(sp)
    800040c6:	0080                	addi	s0,sp,64
    800040c8:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    800040ca:	0001e517          	auipc	a0,0x1e
    800040ce:	6f650513          	addi	a0,a0,1782 # 800227c0 <ftable>
    800040d2:	b89fc0ef          	jal	80000c5a <acquire>
  if(f->ref < 1)
    800040d6:	40dc                	lw	a5,4(s1)
    800040d8:	04f05a63          	blez	a5,8000412c <fileclose+0x6e>
    panic("fileclose");
  if(--f->ref > 0){
    800040dc:	37fd                	addiw	a5,a5,-1
    800040de:	c0dc                	sw	a5,4(s1)
    800040e0:	06f04063          	bgtz	a5,80004140 <fileclose+0x82>
    800040e4:	f04a                	sd	s2,32(sp)
    800040e6:	ec4e                	sd	s3,24(sp)
    800040e8:	e852                	sd	s4,16(sp)
    800040ea:	e456                	sd	s5,8(sp)
    release(&ftable.lock);
    return;
  }
  ff = *f;
    800040ec:	0004a903          	lw	s2,0(s1)
    800040f0:	0094c783          	lbu	a5,9(s1)
    800040f4:	89be                	mv	s3,a5
    800040f6:	689c                	ld	a5,16(s1)
    800040f8:	8a3e                	mv	s4,a5
    800040fa:	6c9c                	ld	a5,24(s1)
    800040fc:	8abe                	mv	s5,a5
  f->ref = 0;
    800040fe:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    80004102:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    80004106:	0001e517          	auipc	a0,0x1e
    8000410a:	6ba50513          	addi	a0,a0,1722 # 800227c0 <ftable>
    8000410e:	be1fc0ef          	jal	80000cee <release>

  if(ff.type == FD_PIPE){
    80004112:	4785                	li	a5,1
    80004114:	04f90163          	beq	s2,a5,80004156 <fileclose+0x98>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    80004118:	ffe9079b          	addiw	a5,s2,-2
    8000411c:	4705                	li	a4,1
    8000411e:	04f77563          	bgeu	a4,a5,80004168 <fileclose+0xaa>
    80004122:	7902                	ld	s2,32(sp)
    80004124:	69e2                	ld	s3,24(sp)
    80004126:	6a42                	ld	s4,16(sp)
    80004128:	6aa2                	ld	s5,8(sp)
    8000412a:	a00d                	j	8000414c <fileclose+0x8e>
    8000412c:	f04a                	sd	s2,32(sp)
    8000412e:	ec4e                	sd	s3,24(sp)
    80004130:	e852                	sd	s4,16(sp)
    80004132:	e456                	sd	s5,8(sp)
    panic("fileclose");
    80004134:	00003517          	auipc	a0,0x3
    80004138:	44450513          	addi	a0,a0,1092 # 80007578 <etext+0x578>
    8000413c:	f1afc0ef          	jal	80000856 <panic>
    release(&ftable.lock);
    80004140:	0001e517          	auipc	a0,0x1e
    80004144:	68050513          	addi	a0,a0,1664 # 800227c0 <ftable>
    80004148:	ba7fc0ef          	jal	80000cee <release>
    begin_op();
    iput(ff.ip);
    end_op();
  }
}
    8000414c:	70e2                	ld	ra,56(sp)
    8000414e:	7442                	ld	s0,48(sp)
    80004150:	74a2                	ld	s1,40(sp)
    80004152:	6121                	addi	sp,sp,64
    80004154:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80004156:	85ce                	mv	a1,s3
    80004158:	8552                	mv	a0,s4
    8000415a:	348000ef          	jal	800044a2 <pipeclose>
    8000415e:	7902                	ld	s2,32(sp)
    80004160:	69e2                	ld	s3,24(sp)
    80004162:	6a42                	ld	s4,16(sp)
    80004164:	6aa2                	ld	s5,8(sp)
    80004166:	b7dd                	j	8000414c <fileclose+0x8e>
    begin_op();
    80004168:	b33ff0ef          	jal	80003c9a <begin_op>
    iput(ff.ip);
    8000416c:	8556                	mv	a0,s5
    8000416e:	aa2ff0ef          	jal	80003410 <iput>
    end_op();
    80004172:	b99ff0ef          	jal	80003d0a <end_op>
    80004176:	7902                	ld	s2,32(sp)
    80004178:	69e2                	ld	s3,24(sp)
    8000417a:	6a42                	ld	s4,16(sp)
    8000417c:	6aa2                	ld	s5,8(sp)
    8000417e:	b7f9                	j	8000414c <fileclose+0x8e>

0000000080004180 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    80004180:	715d                	addi	sp,sp,-80
    80004182:	e486                	sd	ra,72(sp)
    80004184:	e0a2                	sd	s0,64(sp)
    80004186:	fc26                	sd	s1,56(sp)
    80004188:	f052                	sd	s4,32(sp)
    8000418a:	0880                	addi	s0,sp,80
    8000418c:	84aa                	mv	s1,a0
    8000418e:	8a2e                	mv	s4,a1
  struct proc *p = myproc();
    80004190:	fd4fd0ef          	jal	80001964 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    80004194:	409c                	lw	a5,0(s1)
    80004196:	37f9                	addiw	a5,a5,-2
    80004198:	4705                	li	a4,1
    8000419a:	04f76263          	bltu	a4,a5,800041de <filestat+0x5e>
    8000419e:	f84a                	sd	s2,48(sp)
    800041a0:	f44e                	sd	s3,40(sp)
    800041a2:	89aa                	mv	s3,a0
    ilock(f->ip);
    800041a4:	6c88                	ld	a0,24(s1)
    800041a6:	8e8ff0ef          	jal	8000328e <ilock>
    stati(f->ip, &st);
    800041aa:	fb840913          	addi	s2,s0,-72
    800041ae:	85ca                	mv	a1,s2
    800041b0:	6c88                	ld	a0,24(s1)
    800041b2:	c40ff0ef          	jal	800035f2 <stati>
    iunlock(f->ip);
    800041b6:	6c88                	ld	a0,24(s1)
    800041b8:	984ff0ef          	jal	8000333c <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    800041bc:	46e1                	li	a3,24
    800041be:	864a                	mv	a2,s2
    800041c0:	85d2                	mv	a1,s4
    800041c2:	0509b503          	ld	a0,80(s3)
    800041c6:	cc4fd0ef          	jal	8000168a <copyout>
    800041ca:	41f5551b          	sraiw	a0,a0,0x1f
    800041ce:	7942                	ld	s2,48(sp)
    800041d0:	79a2                	ld	s3,40(sp)
      return -1;
    return 0;
  }
  return -1;
}
    800041d2:	60a6                	ld	ra,72(sp)
    800041d4:	6406                	ld	s0,64(sp)
    800041d6:	74e2                	ld	s1,56(sp)
    800041d8:	7a02                	ld	s4,32(sp)
    800041da:	6161                	addi	sp,sp,80
    800041dc:	8082                	ret
  return -1;
    800041de:	557d                	li	a0,-1
    800041e0:	bfcd                	j	800041d2 <filestat+0x52>

00000000800041e2 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    800041e2:	7179                	addi	sp,sp,-48
    800041e4:	f406                	sd	ra,40(sp)
    800041e6:	f022                	sd	s0,32(sp)
    800041e8:	e84a                	sd	s2,16(sp)
    800041ea:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    800041ec:	00854783          	lbu	a5,8(a0)
    800041f0:	cfd1                	beqz	a5,8000428c <fileread+0xaa>
    800041f2:	ec26                	sd	s1,24(sp)
    800041f4:	e44e                	sd	s3,8(sp)
    800041f6:	84aa                	mv	s1,a0
    800041f8:	892e                	mv	s2,a1
    800041fa:	89b2                	mv	s3,a2
    return -1;

  if(f->type == FD_PIPE){
    800041fc:	411c                	lw	a5,0(a0)
    800041fe:	4705                	li	a4,1
    80004200:	04e78363          	beq	a5,a4,80004246 <fileread+0x64>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004204:	470d                	li	a4,3
    80004206:	04e78763          	beq	a5,a4,80004254 <fileread+0x72>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    8000420a:	4709                	li	a4,2
    8000420c:	06e79a63          	bne	a5,a4,80004280 <fileread+0x9e>
    ilock(f->ip);
    80004210:	6d08                	ld	a0,24(a0)
    80004212:	87cff0ef          	jal	8000328e <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    80004216:	874e                	mv	a4,s3
    80004218:	5094                	lw	a3,32(s1)
    8000421a:	864a                	mv	a2,s2
    8000421c:	4585                	li	a1,1
    8000421e:	6c88                	ld	a0,24(s1)
    80004220:	c00ff0ef          	jal	80003620 <readi>
    80004224:	892a                	mv	s2,a0
    80004226:	00a05563          	blez	a0,80004230 <fileread+0x4e>
      f->off += r;
    8000422a:	509c                	lw	a5,32(s1)
    8000422c:	9fa9                	addw	a5,a5,a0
    8000422e:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80004230:	6c88                	ld	a0,24(s1)
    80004232:	90aff0ef          	jal	8000333c <iunlock>
    80004236:	64e2                	ld	s1,24(sp)
    80004238:	69a2                	ld	s3,8(sp)
  } else {
    panic("fileread");
  }

  return r;
}
    8000423a:	854a                	mv	a0,s2
    8000423c:	70a2                	ld	ra,40(sp)
    8000423e:	7402                	ld	s0,32(sp)
    80004240:	6942                	ld	s2,16(sp)
    80004242:	6145                	addi	sp,sp,48
    80004244:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80004246:	6908                	ld	a0,16(a0)
    80004248:	3b0000ef          	jal	800045f8 <piperead>
    8000424c:	892a                	mv	s2,a0
    8000424e:	64e2                	ld	s1,24(sp)
    80004250:	69a2                	ld	s3,8(sp)
    80004252:	b7e5                	j	8000423a <fileread+0x58>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80004254:	02451783          	lh	a5,36(a0)
    80004258:	03079693          	slli	a3,a5,0x30
    8000425c:	92c1                	srli	a3,a3,0x30
    8000425e:	4725                	li	a4,9
    80004260:	02d76963          	bltu	a4,a3,80004292 <fileread+0xb0>
    80004264:	0792                	slli	a5,a5,0x4
    80004266:	0001e717          	auipc	a4,0x1e
    8000426a:	4ba70713          	addi	a4,a4,1210 # 80022720 <devsw>
    8000426e:	97ba                	add	a5,a5,a4
    80004270:	639c                	ld	a5,0(a5)
    80004272:	c78d                	beqz	a5,8000429c <fileread+0xba>
    r = devsw[f->major].read(1, addr, n);
    80004274:	4505                	li	a0,1
    80004276:	9782                	jalr	a5
    80004278:	892a                	mv	s2,a0
    8000427a:	64e2                	ld	s1,24(sp)
    8000427c:	69a2                	ld	s3,8(sp)
    8000427e:	bf75                	j	8000423a <fileread+0x58>
    panic("fileread");
    80004280:	00003517          	auipc	a0,0x3
    80004284:	30850513          	addi	a0,a0,776 # 80007588 <etext+0x588>
    80004288:	dcefc0ef          	jal	80000856 <panic>
    return -1;
    8000428c:	57fd                	li	a5,-1
    8000428e:	893e                	mv	s2,a5
    80004290:	b76d                	j	8000423a <fileread+0x58>
      return -1;
    80004292:	57fd                	li	a5,-1
    80004294:	893e                	mv	s2,a5
    80004296:	64e2                	ld	s1,24(sp)
    80004298:	69a2                	ld	s3,8(sp)
    8000429a:	b745                	j	8000423a <fileread+0x58>
    8000429c:	57fd                	li	a5,-1
    8000429e:	893e                	mv	s2,a5
    800042a0:	64e2                	ld	s1,24(sp)
    800042a2:	69a2                	ld	s3,8(sp)
    800042a4:	bf59                	j	8000423a <fileread+0x58>

00000000800042a6 <filewrite>:
int
filewrite(struct file *f, uint64 addr, int n)
{
  int r, ret = 0;

  if(f->writable == 0)
    800042a6:	00954783          	lbu	a5,9(a0)
    800042aa:	10078f63          	beqz	a5,800043c8 <filewrite+0x122>
{
    800042ae:	711d                	addi	sp,sp,-96
    800042b0:	ec86                	sd	ra,88(sp)
    800042b2:	e8a2                	sd	s0,80(sp)
    800042b4:	e0ca                	sd	s2,64(sp)
    800042b6:	f456                	sd	s5,40(sp)
    800042b8:	f05a                	sd	s6,32(sp)
    800042ba:	1080                	addi	s0,sp,96
    800042bc:	892a                	mv	s2,a0
    800042be:	8b2e                	mv	s6,a1
    800042c0:	8ab2                	mv	s5,a2
    return -1;

  if(f->type == FD_PIPE){
    800042c2:	411c                	lw	a5,0(a0)
    800042c4:	4705                	li	a4,1
    800042c6:	02e78a63          	beq	a5,a4,800042fa <filewrite+0x54>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    800042ca:	470d                	li	a4,3
    800042cc:	02e78b63          	beq	a5,a4,80004302 <filewrite+0x5c>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    800042d0:	4709                	li	a4,2
    800042d2:	0ce79f63          	bne	a5,a4,800043b0 <filewrite+0x10a>
    800042d6:	f852                	sd	s4,48(sp)
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    800042d8:	0ac05a63          	blez	a2,8000438c <filewrite+0xe6>
    800042dc:	e4a6                	sd	s1,72(sp)
    800042de:	fc4e                	sd	s3,56(sp)
    800042e0:	ec5e                	sd	s7,24(sp)
    800042e2:	e862                	sd	s8,16(sp)
    800042e4:	e466                	sd	s9,8(sp)
    int i = 0;
    800042e6:	4a01                	li	s4,0
      int n1 = n - i;
      if(n1 > max)
    800042e8:	6b85                	lui	s7,0x1
    800042ea:	c00b8b93          	addi	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    800042ee:	6785                	lui	a5,0x1
    800042f0:	c007879b          	addiw	a5,a5,-1024 # c00 <_entry-0x7ffff400>
    800042f4:	8cbe                	mv	s9,a5
        n1 = max;

      begin_op();
      ilock(f->ip);
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    800042f6:	4c05                	li	s8,1
    800042f8:	a8ad                	j	80004372 <filewrite+0xcc>
    ret = pipewrite(f->pipe, addr, n);
    800042fa:	6908                	ld	a0,16(a0)
    800042fc:	204000ef          	jal	80004500 <pipewrite>
    80004300:	a04d                	j	800043a2 <filewrite+0xfc>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80004302:	02451783          	lh	a5,36(a0)
    80004306:	03079693          	slli	a3,a5,0x30
    8000430a:	92c1                	srli	a3,a3,0x30
    8000430c:	4725                	li	a4,9
    8000430e:	0ad76f63          	bltu	a4,a3,800043cc <filewrite+0x126>
    80004312:	0792                	slli	a5,a5,0x4
    80004314:	0001e717          	auipc	a4,0x1e
    80004318:	40c70713          	addi	a4,a4,1036 # 80022720 <devsw>
    8000431c:	97ba                	add	a5,a5,a4
    8000431e:	679c                	ld	a5,8(a5)
    80004320:	cbc5                	beqz	a5,800043d0 <filewrite+0x12a>
    ret = devsw[f->major].write(1, addr, n);
    80004322:	4505                	li	a0,1
    80004324:	9782                	jalr	a5
    80004326:	a8b5                	j	800043a2 <filewrite+0xfc>
      if(n1 > max)
    80004328:	2981                	sext.w	s3,s3
      begin_op();
    8000432a:	971ff0ef          	jal	80003c9a <begin_op>
      ilock(f->ip);
    8000432e:	01893503          	ld	a0,24(s2)
    80004332:	f5dfe0ef          	jal	8000328e <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80004336:	874e                	mv	a4,s3
    80004338:	02092683          	lw	a3,32(s2)
    8000433c:	016a0633          	add	a2,s4,s6
    80004340:	85e2                	mv	a1,s8
    80004342:	01893503          	ld	a0,24(s2)
    80004346:	bccff0ef          	jal	80003712 <writei>
    8000434a:	84aa                	mv	s1,a0
    8000434c:	00a05763          	blez	a0,8000435a <filewrite+0xb4>
        f->off += r;
    80004350:	02092783          	lw	a5,32(s2)
    80004354:	9fa9                	addw	a5,a5,a0
    80004356:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    8000435a:	01893503          	ld	a0,24(s2)
    8000435e:	fdffe0ef          	jal	8000333c <iunlock>
      end_op();
    80004362:	9a9ff0ef          	jal	80003d0a <end_op>

      if(r != n1){
    80004366:	02999563          	bne	s3,s1,80004390 <filewrite+0xea>
        // error from writei
        break;
      }
      i += r;
    8000436a:	01448a3b          	addw	s4,s1,s4
    while(i < n){
    8000436e:	015a5963          	bge	s4,s5,80004380 <filewrite+0xda>
      int n1 = n - i;
    80004372:	414a87bb          	subw	a5,s5,s4
    80004376:	89be                	mv	s3,a5
      if(n1 > max)
    80004378:	fafbd8e3          	bge	s7,a5,80004328 <filewrite+0x82>
    8000437c:	89e6                	mv	s3,s9
    8000437e:	b76d                	j	80004328 <filewrite+0x82>
    80004380:	64a6                	ld	s1,72(sp)
    80004382:	79e2                	ld	s3,56(sp)
    80004384:	6be2                	ld	s7,24(sp)
    80004386:	6c42                	ld	s8,16(sp)
    80004388:	6ca2                	ld	s9,8(sp)
    8000438a:	a801                	j	8000439a <filewrite+0xf4>
    int i = 0;
    8000438c:	4a01                	li	s4,0
    8000438e:	a031                	j	8000439a <filewrite+0xf4>
    80004390:	64a6                	ld	s1,72(sp)
    80004392:	79e2                	ld	s3,56(sp)
    80004394:	6be2                	ld	s7,24(sp)
    80004396:	6c42                	ld	s8,16(sp)
    80004398:	6ca2                	ld	s9,8(sp)
    }
    ret = (i == n ? n : -1);
    8000439a:	034a9d63          	bne	s5,s4,800043d4 <filewrite+0x12e>
    8000439e:	8556                	mv	a0,s5
    800043a0:	7a42                	ld	s4,48(sp)
  } else {
    panic("filewrite");
  }

  return ret;
}
    800043a2:	60e6                	ld	ra,88(sp)
    800043a4:	6446                	ld	s0,80(sp)
    800043a6:	6906                	ld	s2,64(sp)
    800043a8:	7aa2                	ld	s5,40(sp)
    800043aa:	7b02                	ld	s6,32(sp)
    800043ac:	6125                	addi	sp,sp,96
    800043ae:	8082                	ret
    800043b0:	e4a6                	sd	s1,72(sp)
    800043b2:	fc4e                	sd	s3,56(sp)
    800043b4:	f852                	sd	s4,48(sp)
    800043b6:	ec5e                	sd	s7,24(sp)
    800043b8:	e862                	sd	s8,16(sp)
    800043ba:	e466                	sd	s9,8(sp)
    panic("filewrite");
    800043bc:	00003517          	auipc	a0,0x3
    800043c0:	1dc50513          	addi	a0,a0,476 # 80007598 <etext+0x598>
    800043c4:	c92fc0ef          	jal	80000856 <panic>
    return -1;
    800043c8:	557d                	li	a0,-1
}
    800043ca:	8082                	ret
      return -1;
    800043cc:	557d                	li	a0,-1
    800043ce:	bfd1                	j	800043a2 <filewrite+0xfc>
    800043d0:	557d                	li	a0,-1
    800043d2:	bfc1                	j	800043a2 <filewrite+0xfc>
    ret = (i == n ? n : -1);
    800043d4:	557d                	li	a0,-1
    800043d6:	7a42                	ld	s4,48(sp)
    800043d8:	b7e9                	j	800043a2 <filewrite+0xfc>

00000000800043da <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    800043da:	7179                	addi	sp,sp,-48
    800043dc:	f406                	sd	ra,40(sp)
    800043de:	f022                	sd	s0,32(sp)
    800043e0:	ec26                	sd	s1,24(sp)
    800043e2:	e052                	sd	s4,0(sp)
    800043e4:	1800                	addi	s0,sp,48
    800043e6:	84aa                	mv	s1,a0
    800043e8:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    800043ea:	0005b023          	sd	zero,0(a1)
    800043ee:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    800043f2:	c29ff0ef          	jal	8000401a <filealloc>
    800043f6:	e088                	sd	a0,0(s1)
    800043f8:	c549                	beqz	a0,80004482 <pipealloc+0xa8>
    800043fa:	c21ff0ef          	jal	8000401a <filealloc>
    800043fe:	00aa3023          	sd	a0,0(s4)
    80004402:	cd25                	beqz	a0,8000447a <pipealloc+0xa0>
    80004404:	e84a                	sd	s2,16(sp)
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80004406:	f70fc0ef          	jal	80000b76 <kalloc>
    8000440a:	892a                	mv	s2,a0
    8000440c:	c12d                	beqz	a0,8000446e <pipealloc+0x94>
    8000440e:	e44e                	sd	s3,8(sp)
    goto bad;
  pi->readopen = 1;
    80004410:	4985                	li	s3,1
    80004412:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    80004416:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    8000441a:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    8000441e:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80004422:	00003597          	auipc	a1,0x3
    80004426:	18658593          	addi	a1,a1,390 # 800075a8 <etext+0x5a8>
    8000442a:	fa6fc0ef          	jal	80000bd0 <initlock>
  (*f0)->type = FD_PIPE;
    8000442e:	609c                	ld	a5,0(s1)
    80004430:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80004434:	609c                	ld	a5,0(s1)
    80004436:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    8000443a:	609c                	ld	a5,0(s1)
    8000443c:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80004440:	609c                	ld	a5,0(s1)
    80004442:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80004446:	000a3783          	ld	a5,0(s4)
    8000444a:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    8000444e:	000a3783          	ld	a5,0(s4)
    80004452:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80004456:	000a3783          	ld	a5,0(s4)
    8000445a:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    8000445e:	000a3783          	ld	a5,0(s4)
    80004462:	0127b823          	sd	s2,16(a5)
  return 0;
    80004466:	4501                	li	a0,0
    80004468:	6942                	ld	s2,16(sp)
    8000446a:	69a2                	ld	s3,8(sp)
    8000446c:	a01d                	j	80004492 <pipealloc+0xb8>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    8000446e:	6088                	ld	a0,0(s1)
    80004470:	c119                	beqz	a0,80004476 <pipealloc+0x9c>
    80004472:	6942                	ld	s2,16(sp)
    80004474:	a029                	j	8000447e <pipealloc+0xa4>
    80004476:	6942                	ld	s2,16(sp)
    80004478:	a029                	j	80004482 <pipealloc+0xa8>
    8000447a:	6088                	ld	a0,0(s1)
    8000447c:	c10d                	beqz	a0,8000449e <pipealloc+0xc4>
    fileclose(*f0);
    8000447e:	c41ff0ef          	jal	800040be <fileclose>
  if(*f1)
    80004482:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80004486:	557d                	li	a0,-1
  if(*f1)
    80004488:	c789                	beqz	a5,80004492 <pipealloc+0xb8>
    fileclose(*f1);
    8000448a:	853e                	mv	a0,a5
    8000448c:	c33ff0ef          	jal	800040be <fileclose>
  return -1;
    80004490:	557d                	li	a0,-1
}
    80004492:	70a2                	ld	ra,40(sp)
    80004494:	7402                	ld	s0,32(sp)
    80004496:	64e2                	ld	s1,24(sp)
    80004498:	6a02                	ld	s4,0(sp)
    8000449a:	6145                	addi	sp,sp,48
    8000449c:	8082                	ret
  return -1;
    8000449e:	557d                	li	a0,-1
    800044a0:	bfcd                	j	80004492 <pipealloc+0xb8>

00000000800044a2 <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    800044a2:	1101                	addi	sp,sp,-32
    800044a4:	ec06                	sd	ra,24(sp)
    800044a6:	e822                	sd	s0,16(sp)
    800044a8:	e426                	sd	s1,8(sp)
    800044aa:	e04a                	sd	s2,0(sp)
    800044ac:	1000                	addi	s0,sp,32
    800044ae:	84aa                	mv	s1,a0
    800044b0:	892e                	mv	s2,a1
  acquire(&pi->lock);
    800044b2:	fa8fc0ef          	jal	80000c5a <acquire>
  if(writable){
    800044b6:	02090763          	beqz	s2,800044e4 <pipeclose+0x42>
    pi->writeopen = 0;
    800044ba:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    800044be:	21848513          	addi	a0,s1,536
    800044c2:	b05fd0ef          	jal	80001fc6 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    800044c6:	2204a783          	lw	a5,544(s1)
    800044ca:	e781                	bnez	a5,800044d2 <pipeclose+0x30>
    800044cc:	2244a783          	lw	a5,548(s1)
    800044d0:	c38d                	beqz	a5,800044f2 <pipeclose+0x50>
    release(&pi->lock);
    kfree((char*)pi);
  } else
    release(&pi->lock);
    800044d2:	8526                	mv	a0,s1
    800044d4:	81bfc0ef          	jal	80000cee <release>
}
    800044d8:	60e2                	ld	ra,24(sp)
    800044da:	6442                	ld	s0,16(sp)
    800044dc:	64a2                	ld	s1,8(sp)
    800044de:	6902                	ld	s2,0(sp)
    800044e0:	6105                	addi	sp,sp,32
    800044e2:	8082                	ret
    pi->readopen = 0;
    800044e4:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    800044e8:	21c48513          	addi	a0,s1,540
    800044ec:	adbfd0ef          	jal	80001fc6 <wakeup>
    800044f0:	bfd9                	j	800044c6 <pipeclose+0x24>
    release(&pi->lock);
    800044f2:	8526                	mv	a0,s1
    800044f4:	ffafc0ef          	jal	80000cee <release>
    kfree((char*)pi);
    800044f8:	8526                	mv	a0,s1
    800044fa:	d94fc0ef          	jal	80000a8e <kfree>
    800044fe:	bfe9                	j	800044d8 <pipeclose+0x36>

0000000080004500 <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80004500:	7159                	addi	sp,sp,-112
    80004502:	f486                	sd	ra,104(sp)
    80004504:	f0a2                	sd	s0,96(sp)
    80004506:	eca6                	sd	s1,88(sp)
    80004508:	e8ca                	sd	s2,80(sp)
    8000450a:	e4ce                	sd	s3,72(sp)
    8000450c:	e0d2                	sd	s4,64(sp)
    8000450e:	fc56                	sd	s5,56(sp)
    80004510:	1880                	addi	s0,sp,112
    80004512:	84aa                	mv	s1,a0
    80004514:	8aae                	mv	s5,a1
    80004516:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    80004518:	c4cfd0ef          	jal	80001964 <myproc>
    8000451c:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    8000451e:	8526                	mv	a0,s1
    80004520:	f3afc0ef          	jal	80000c5a <acquire>
  while(i < n){
    80004524:	0d405263          	blez	s4,800045e8 <pipewrite+0xe8>
    80004528:	f85a                	sd	s6,48(sp)
    8000452a:	f45e                	sd	s7,40(sp)
    8000452c:	f062                	sd	s8,32(sp)
    8000452e:	ec66                	sd	s9,24(sp)
    80004530:	e86a                	sd	s10,16(sp)
  int i = 0;
    80004532:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004534:	f9f40c13          	addi	s8,s0,-97
    80004538:	4b85                	li	s7,1
    8000453a:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    8000453c:	21848d13          	addi	s10,s1,536
      sleep(&pi->nwrite, &pi->lock);
    80004540:	21c48c93          	addi	s9,s1,540
    80004544:	a82d                	j	8000457e <pipewrite+0x7e>
      release(&pi->lock);
    80004546:	8526                	mv	a0,s1
    80004548:	fa6fc0ef          	jal	80000cee <release>
      return -1;
    8000454c:	597d                	li	s2,-1
    8000454e:	7b42                	ld	s6,48(sp)
    80004550:	7ba2                	ld	s7,40(sp)
    80004552:	7c02                	ld	s8,32(sp)
    80004554:	6ce2                	ld	s9,24(sp)
    80004556:	6d42                	ld	s10,16(sp)
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    80004558:	854a                	mv	a0,s2
    8000455a:	70a6                	ld	ra,104(sp)
    8000455c:	7406                	ld	s0,96(sp)
    8000455e:	64e6                	ld	s1,88(sp)
    80004560:	6946                	ld	s2,80(sp)
    80004562:	69a6                	ld	s3,72(sp)
    80004564:	6a06                	ld	s4,64(sp)
    80004566:	7ae2                	ld	s5,56(sp)
    80004568:	6165                	addi	sp,sp,112
    8000456a:	8082                	ret
      wakeup(&pi->nread);
    8000456c:	856a                	mv	a0,s10
    8000456e:	a59fd0ef          	jal	80001fc6 <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80004572:	85a6                	mv	a1,s1
    80004574:	8566                	mv	a0,s9
    80004576:	a05fd0ef          	jal	80001f7a <sleep>
  while(i < n){
    8000457a:	05495a63          	bge	s2,s4,800045ce <pipewrite+0xce>
    if(pi->readopen == 0 || killed(pr)){
    8000457e:	2204a783          	lw	a5,544(s1)
    80004582:	d3f1                	beqz	a5,80004546 <pipewrite+0x46>
    80004584:	854e                	mv	a0,s3
    80004586:	c31fd0ef          	jal	800021b6 <killed>
    8000458a:	fd55                	bnez	a0,80004546 <pipewrite+0x46>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    8000458c:	2184a783          	lw	a5,536(s1)
    80004590:	21c4a703          	lw	a4,540(s1)
    80004594:	2007879b          	addiw	a5,a5,512
    80004598:	fcf70ae3          	beq	a4,a5,8000456c <pipewrite+0x6c>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    8000459c:	86de                	mv	a3,s7
    8000459e:	01590633          	add	a2,s2,s5
    800045a2:	85e2                	mv	a1,s8
    800045a4:	0509b503          	ld	a0,80(s3)
    800045a8:	9a0fd0ef          	jal	80001748 <copyin>
    800045ac:	05650063          	beq	a0,s6,800045ec <pipewrite+0xec>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    800045b0:	21c4a783          	lw	a5,540(s1)
    800045b4:	0017871b          	addiw	a4,a5,1
    800045b8:	20e4ae23          	sw	a4,540(s1)
    800045bc:	1ff7f793          	andi	a5,a5,511
    800045c0:	97a6                	add	a5,a5,s1
    800045c2:	f9f44703          	lbu	a4,-97(s0)
    800045c6:	00e78c23          	sb	a4,24(a5)
      i++;
    800045ca:	2905                	addiw	s2,s2,1
    800045cc:	b77d                	j	8000457a <pipewrite+0x7a>
    800045ce:	7b42                	ld	s6,48(sp)
    800045d0:	7ba2                	ld	s7,40(sp)
    800045d2:	7c02                	ld	s8,32(sp)
    800045d4:	6ce2                	ld	s9,24(sp)
    800045d6:	6d42                	ld	s10,16(sp)
  wakeup(&pi->nread);
    800045d8:	21848513          	addi	a0,s1,536
    800045dc:	9ebfd0ef          	jal	80001fc6 <wakeup>
  release(&pi->lock);
    800045e0:	8526                	mv	a0,s1
    800045e2:	f0cfc0ef          	jal	80000cee <release>
  return i;
    800045e6:	bf8d                	j	80004558 <pipewrite+0x58>
  int i = 0;
    800045e8:	4901                	li	s2,0
    800045ea:	b7fd                	j	800045d8 <pipewrite+0xd8>
    800045ec:	7b42                	ld	s6,48(sp)
    800045ee:	7ba2                	ld	s7,40(sp)
    800045f0:	7c02                	ld	s8,32(sp)
    800045f2:	6ce2                	ld	s9,24(sp)
    800045f4:	6d42                	ld	s10,16(sp)
    800045f6:	b7cd                	j	800045d8 <pipewrite+0xd8>

00000000800045f8 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    800045f8:	711d                	addi	sp,sp,-96
    800045fa:	ec86                	sd	ra,88(sp)
    800045fc:	e8a2                	sd	s0,80(sp)
    800045fe:	e4a6                	sd	s1,72(sp)
    80004600:	e0ca                	sd	s2,64(sp)
    80004602:	fc4e                	sd	s3,56(sp)
    80004604:	f852                	sd	s4,48(sp)
    80004606:	f456                	sd	s5,40(sp)
    80004608:	1080                	addi	s0,sp,96
    8000460a:	84aa                	mv	s1,a0
    8000460c:	892e                	mv	s2,a1
    8000460e:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80004610:	b54fd0ef          	jal	80001964 <myproc>
    80004614:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80004616:	8526                	mv	a0,s1
    80004618:	e42fc0ef          	jal	80000c5a <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    8000461c:	2184a703          	lw	a4,536(s1)
    80004620:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004624:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004628:	02f71763          	bne	a4,a5,80004656 <piperead+0x5e>
    8000462c:	2244a783          	lw	a5,548(s1)
    80004630:	cf85                	beqz	a5,80004668 <piperead+0x70>
    if(killed(pr)){
    80004632:	8552                	mv	a0,s4
    80004634:	b83fd0ef          	jal	800021b6 <killed>
    80004638:	e11d                	bnez	a0,8000465e <piperead+0x66>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    8000463a:	85a6                	mv	a1,s1
    8000463c:	854e                	mv	a0,s3
    8000463e:	93dfd0ef          	jal	80001f7a <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004642:	2184a703          	lw	a4,536(s1)
    80004646:	21c4a783          	lw	a5,540(s1)
    8000464a:	fef701e3          	beq	a4,a5,8000462c <piperead+0x34>
    8000464e:	f05a                	sd	s6,32(sp)
    80004650:	ec5e                	sd	s7,24(sp)
    80004652:	e862                	sd	s8,16(sp)
    80004654:	a829                	j	8000466e <piperead+0x76>
    80004656:	f05a                	sd	s6,32(sp)
    80004658:	ec5e                	sd	s7,24(sp)
    8000465a:	e862                	sd	s8,16(sp)
    8000465c:	a809                	j	8000466e <piperead+0x76>
      release(&pi->lock);
    8000465e:	8526                	mv	a0,s1
    80004660:	e8efc0ef          	jal	80000cee <release>
      return -1;
    80004664:	59fd                	li	s3,-1
    80004666:	a0a5                	j	800046ce <piperead+0xd6>
    80004668:	f05a                	sd	s6,32(sp)
    8000466a:	ec5e                	sd	s7,24(sp)
    8000466c:	e862                	sd	s8,16(sp)
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    8000466e:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1) {
    80004670:	faf40c13          	addi	s8,s0,-81
    80004674:	4b85                	li	s7,1
    80004676:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004678:	05505163          	blez	s5,800046ba <piperead+0xc2>
    if(pi->nread == pi->nwrite)
    8000467c:	2184a783          	lw	a5,536(s1)
    80004680:	21c4a703          	lw	a4,540(s1)
    80004684:	02f70b63          	beq	a4,a5,800046ba <piperead+0xc2>
    ch = pi->data[pi->nread % PIPESIZE];
    80004688:	1ff7f793          	andi	a5,a5,511
    8000468c:	97a6                	add	a5,a5,s1
    8000468e:	0187c783          	lbu	a5,24(a5)
    80004692:	faf407a3          	sb	a5,-81(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1) {
    80004696:	86de                	mv	a3,s7
    80004698:	8662                	mv	a2,s8
    8000469a:	85ca                	mv	a1,s2
    8000469c:	050a3503          	ld	a0,80(s4)
    800046a0:	febfc0ef          	jal	8000168a <copyout>
    800046a4:	03650f63          	beq	a0,s6,800046e2 <piperead+0xea>
      if(i == 0)
        i = -1;
      break;
    }
    pi->nread++;
    800046a8:	2184a783          	lw	a5,536(s1)
    800046ac:	2785                	addiw	a5,a5,1
    800046ae:	20f4ac23          	sw	a5,536(s1)
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    800046b2:	2985                	addiw	s3,s3,1
    800046b4:	0905                	addi	s2,s2,1
    800046b6:	fd3a93e3          	bne	s5,s3,8000467c <piperead+0x84>
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    800046ba:	21c48513          	addi	a0,s1,540
    800046be:	909fd0ef          	jal	80001fc6 <wakeup>
  release(&pi->lock);
    800046c2:	8526                	mv	a0,s1
    800046c4:	e2afc0ef          	jal	80000cee <release>
    800046c8:	7b02                	ld	s6,32(sp)
    800046ca:	6be2                	ld	s7,24(sp)
    800046cc:	6c42                	ld	s8,16(sp)
  return i;
}
    800046ce:	854e                	mv	a0,s3
    800046d0:	60e6                	ld	ra,88(sp)
    800046d2:	6446                	ld	s0,80(sp)
    800046d4:	64a6                	ld	s1,72(sp)
    800046d6:	6906                	ld	s2,64(sp)
    800046d8:	79e2                	ld	s3,56(sp)
    800046da:	7a42                	ld	s4,48(sp)
    800046dc:	7aa2                	ld	s5,40(sp)
    800046de:	6125                	addi	sp,sp,96
    800046e0:	8082                	ret
      if(i == 0)
    800046e2:	fc099ce3          	bnez	s3,800046ba <piperead+0xc2>
        i = -1;
    800046e6:	89aa                	mv	s3,a0
    800046e8:	bfc9                	j	800046ba <piperead+0xc2>

00000000800046ea <flags2perm>:

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

// map ELF permissions to PTE permission bits.
int flags2perm(int flags)
{
    800046ea:	1141                	addi	sp,sp,-16
    800046ec:	e406                	sd	ra,8(sp)
    800046ee:	e022                	sd	s0,0(sp)
    800046f0:	0800                	addi	s0,sp,16
    800046f2:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    800046f4:	0035151b          	slliw	a0,a0,0x3
    800046f8:	8921                	andi	a0,a0,8
      perm = PTE_X;
    if(flags & 0x2)
    800046fa:	8b89                	andi	a5,a5,2
    800046fc:	c399                	beqz	a5,80004702 <flags2perm+0x18>
      perm |= PTE_W;
    800046fe:	00456513          	ori	a0,a0,4
    return perm;
}
    80004702:	60a2                	ld	ra,8(sp)
    80004704:	6402                	ld	s0,0(sp)
    80004706:	0141                	addi	sp,sp,16
    80004708:	8082                	ret

000000008000470a <kexec>:
//
// the implementation of the exec() system call
//
int
kexec(char *path, char **argv)
{
    8000470a:	de010113          	addi	sp,sp,-544
    8000470e:	20113c23          	sd	ra,536(sp)
    80004712:	20813823          	sd	s0,528(sp)
    80004716:	20913423          	sd	s1,520(sp)
    8000471a:	21213023          	sd	s2,512(sp)
    8000471e:	1400                	addi	s0,sp,544
    80004720:	892a                	mv	s2,a0
    80004722:	dea43823          	sd	a0,-528(s0)
    80004726:	e0b43023          	sd	a1,-512(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    8000472a:	a3afd0ef          	jal	80001964 <myproc>
    8000472e:	84aa                	mv	s1,a0

  begin_op();
    80004730:	d6aff0ef          	jal	80003c9a <begin_op>

  // Open the executable file.
  if((ip = namei(path)) == 0){
    80004734:	854a                	mv	a0,s2
    80004736:	b86ff0ef          	jal	80003abc <namei>
    8000473a:	cd21                	beqz	a0,80004792 <kexec+0x88>
    8000473c:	fbd2                	sd	s4,496(sp)
    8000473e:	8a2a                	mv	s4,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80004740:	b4ffe0ef          	jal	8000328e <ilock>

  // Read the ELF header.
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80004744:	04000713          	li	a4,64
    80004748:	4681                	li	a3,0
    8000474a:	e5040613          	addi	a2,s0,-432
    8000474e:	4581                	li	a1,0
    80004750:	8552                	mv	a0,s4
    80004752:	ecffe0ef          	jal	80003620 <readi>
    80004756:	04000793          	li	a5,64
    8000475a:	00f51a63          	bne	a0,a5,8000476e <kexec+0x64>
    goto bad;

  // Is this really an ELF file?
  if(elf.magic != ELF_MAGIC)
    8000475e:	e5042703          	lw	a4,-432(s0)
    80004762:	464c47b7          	lui	a5,0x464c4
    80004766:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    8000476a:	02f70863          	beq	a4,a5,8000479a <kexec+0x90>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    8000476e:	8552                	mv	a0,s4
    80004770:	d2bfe0ef          	jal	8000349a <iunlockput>
    end_op();
    80004774:	d96ff0ef          	jal	80003d0a <end_op>
  }
  return -1;
    80004778:	557d                	li	a0,-1
    8000477a:	7a5e                	ld	s4,496(sp)
}
    8000477c:	21813083          	ld	ra,536(sp)
    80004780:	21013403          	ld	s0,528(sp)
    80004784:	20813483          	ld	s1,520(sp)
    80004788:	20013903          	ld	s2,512(sp)
    8000478c:	22010113          	addi	sp,sp,544
    80004790:	8082                	ret
    end_op();
    80004792:	d78ff0ef          	jal	80003d0a <end_op>
    return -1;
    80004796:	557d                	li	a0,-1
    80004798:	b7d5                	j	8000477c <kexec+0x72>
    8000479a:	f3da                	sd	s6,480(sp)
  if((pagetable = proc_pagetable(p)) == 0)
    8000479c:	8526                	mv	a0,s1
    8000479e:	ad0fd0ef          	jal	80001a6e <proc_pagetable>
    800047a2:	8b2a                	mv	s6,a0
    800047a4:	26050f63          	beqz	a0,80004a22 <kexec+0x318>
    800047a8:	ffce                	sd	s3,504(sp)
    800047aa:	f7d6                	sd	s5,488(sp)
    800047ac:	efde                	sd	s7,472(sp)
    800047ae:	ebe2                	sd	s8,464(sp)
    800047b0:	e7e6                	sd	s9,456(sp)
    800047b2:	e3ea                	sd	s10,448(sp)
    800047b4:	ff6e                	sd	s11,440(sp)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800047b6:	e8845783          	lhu	a5,-376(s0)
    800047ba:	0e078963          	beqz	a5,800048ac <kexec+0x1a2>
    800047be:	e7042683          	lw	a3,-400(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    800047c2:	4901                	li	s2,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800047c4:	4d01                	li	s10,0
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    800047c6:	03800d93          	li	s11,56
    if(ph.vaddr % PGSIZE != 0)
    800047ca:	6c85                	lui	s9,0x1
    800047cc:	fffc8793          	addi	a5,s9,-1 # fff <_entry-0x7ffff001>
    800047d0:	def43423          	sd	a5,-536(s0)

  for(i = 0; i < sz; i += PGSIZE){
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    if(sz - i < PGSIZE)
    800047d4:	6a85                	lui	s5,0x1
    800047d6:	a085                	j	80004836 <kexec+0x12c>
      panic("loadseg: address should exist");
    800047d8:	00003517          	auipc	a0,0x3
    800047dc:	dd850513          	addi	a0,a0,-552 # 800075b0 <etext+0x5b0>
    800047e0:	876fc0ef          	jal	80000856 <panic>
    if(sz - i < PGSIZE)
    800047e4:	2901                	sext.w	s2,s2
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    800047e6:	874a                	mv	a4,s2
    800047e8:	009b86bb          	addw	a3,s7,s1
    800047ec:	4581                	li	a1,0
    800047ee:	8552                	mv	a0,s4
    800047f0:	e31fe0ef          	jal	80003620 <readi>
    800047f4:	22a91b63          	bne	s2,a0,80004a2a <kexec+0x320>
  for(i = 0; i < sz; i += PGSIZE){
    800047f8:	009a84bb          	addw	s1,s5,s1
    800047fc:	0334f263          	bgeu	s1,s3,80004820 <kexec+0x116>
    pa = walkaddr(pagetable, va + i);
    80004800:	02049593          	slli	a1,s1,0x20
    80004804:	9181                	srli	a1,a1,0x20
    80004806:	95e2                	add	a1,a1,s8
    80004808:	855a                	mv	a0,s6
    8000480a:	853fc0ef          	jal	8000105c <walkaddr>
    8000480e:	862a                	mv	a2,a0
    if(pa == 0)
    80004810:	d561                	beqz	a0,800047d8 <kexec+0xce>
    if(sz - i < PGSIZE)
    80004812:	409987bb          	subw	a5,s3,s1
    80004816:	893e                	mv	s2,a5
    80004818:	fcfcf6e3          	bgeu	s9,a5,800047e4 <kexec+0xda>
    8000481c:	8956                	mv	s2,s5
    8000481e:	b7d9                	j	800047e4 <kexec+0xda>
    sz = sz1;
    80004820:	df843903          	ld	s2,-520(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004824:	2d05                	addiw	s10,s10,1
    80004826:	e0843783          	ld	a5,-504(s0)
    8000482a:	0387869b          	addiw	a3,a5,56
    8000482e:	e8845783          	lhu	a5,-376(s0)
    80004832:	06fd5e63          	bge	s10,a5,800048ae <kexec+0x1a4>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80004836:	e0d43423          	sd	a3,-504(s0)
    8000483a:	876e                	mv	a4,s11
    8000483c:	e1840613          	addi	a2,s0,-488
    80004840:	4581                	li	a1,0
    80004842:	8552                	mv	a0,s4
    80004844:	dddfe0ef          	jal	80003620 <readi>
    80004848:	1db51f63          	bne	a0,s11,80004a26 <kexec+0x31c>
    if(ph.type != ELF_PROG_LOAD)
    8000484c:	e1842783          	lw	a5,-488(s0)
    80004850:	4705                	li	a4,1
    80004852:	fce799e3          	bne	a5,a4,80004824 <kexec+0x11a>
    if(ph.memsz < ph.filesz)
    80004856:	e4043483          	ld	s1,-448(s0)
    8000485a:	e3843783          	ld	a5,-456(s0)
    8000485e:	1ef4e463          	bltu	s1,a5,80004a46 <kexec+0x33c>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    80004862:	e2843783          	ld	a5,-472(s0)
    80004866:	94be                	add	s1,s1,a5
    80004868:	1ef4e263          	bltu	s1,a5,80004a4c <kexec+0x342>
    if(ph.vaddr % PGSIZE != 0)
    8000486c:	de843703          	ld	a4,-536(s0)
    80004870:	8ff9                	and	a5,a5,a4
    80004872:	1e079063          	bnez	a5,80004a52 <kexec+0x348>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80004876:	e1c42503          	lw	a0,-484(s0)
    8000487a:	e71ff0ef          	jal	800046ea <flags2perm>
    8000487e:	86aa                	mv	a3,a0
    80004880:	8626                	mv	a2,s1
    80004882:	85ca                	mv	a1,s2
    80004884:	855a                	mv	a0,s6
    80004886:	aadfc0ef          	jal	80001332 <uvmalloc>
    8000488a:	dea43c23          	sd	a0,-520(s0)
    8000488e:	1c050563          	beqz	a0,80004a58 <kexec+0x34e>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80004892:	e3842983          	lw	s3,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    80004896:	00098863          	beqz	s3,800048a6 <kexec+0x19c>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    8000489a:	e2843c03          	ld	s8,-472(s0)
    8000489e:	e2042b83          	lw	s7,-480(s0)
  for(i = 0; i < sz; i += PGSIZE){
    800048a2:	4481                	li	s1,0
    800048a4:	bfb1                	j	80004800 <kexec+0xf6>
    sz = sz1;
    800048a6:	df843903          	ld	s2,-520(s0)
    800048aa:	bfad                	j	80004824 <kexec+0x11a>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    800048ac:	4901                	li	s2,0
  iunlockput(ip);
    800048ae:	8552                	mv	a0,s4
    800048b0:	bebfe0ef          	jal	8000349a <iunlockput>
  end_op();
    800048b4:	c56ff0ef          	jal	80003d0a <end_op>
  p = myproc();
    800048b8:	8acfd0ef          	jal	80001964 <myproc>
    800048bc:	8aaa                	mv	s5,a0
  uint64 oldsz = p->sz;
    800048be:	04853d03          	ld	s10,72(a0)
  sz = PGROUNDUP(sz);
    800048c2:	6985                	lui	s3,0x1
    800048c4:	19fd                	addi	s3,s3,-1 # fff <_entry-0x7ffff001>
    800048c6:	99ca                	add	s3,s3,s2
    800048c8:	77fd                	lui	a5,0xfffff
    800048ca:	00f9f9b3          	and	s3,s3,a5
  if((sz1 = uvmalloc(pagetable, sz, sz + (USERSTACK+1)*PGSIZE, PTE_W)) == 0)
    800048ce:	4691                	li	a3,4
    800048d0:	6609                	lui	a2,0x2
    800048d2:	964e                	add	a2,a2,s3
    800048d4:	85ce                	mv	a1,s3
    800048d6:	855a                	mv	a0,s6
    800048d8:	a5bfc0ef          	jal	80001332 <uvmalloc>
    800048dc:	8a2a                	mv	s4,a0
    800048de:	e105                	bnez	a0,800048fe <kexec+0x1f4>
    proc_freepagetable(pagetable, sz);
    800048e0:	85ce                	mv	a1,s3
    800048e2:	855a                	mv	a0,s6
    800048e4:	a0efd0ef          	jal	80001af2 <proc_freepagetable>
  return -1;
    800048e8:	557d                	li	a0,-1
    800048ea:	79fe                	ld	s3,504(sp)
    800048ec:	7a5e                	ld	s4,496(sp)
    800048ee:	7abe                	ld	s5,488(sp)
    800048f0:	7b1e                	ld	s6,480(sp)
    800048f2:	6bfe                	ld	s7,472(sp)
    800048f4:	6c5e                	ld	s8,464(sp)
    800048f6:	6cbe                	ld	s9,456(sp)
    800048f8:	6d1e                	ld	s10,448(sp)
    800048fa:	7dfa                	ld	s11,440(sp)
    800048fc:	b541                	j	8000477c <kexec+0x72>
  uvmclear(pagetable, sz-(USERSTACK+1)*PGSIZE);
    800048fe:	75f9                	lui	a1,0xffffe
    80004900:	95aa                	add	a1,a1,a0
    80004902:	855a                	mv	a0,s6
    80004904:	c01fc0ef          	jal	80001504 <uvmclear>
  stackbase = sp - USERSTACK*PGSIZE;
    80004908:	800a0b93          	addi	s7,s4,-2048
    8000490c:	800b8b93          	addi	s7,s7,-2048
  for(argc = 0; argv[argc]; argc++) {
    80004910:	e0043783          	ld	a5,-512(s0)
    80004914:	6388                	ld	a0,0(a5)
  sp = sz;
    80004916:	8952                	mv	s2,s4
  for(argc = 0; argv[argc]; argc++) {
    80004918:	4481                	li	s1,0
    ustack[argc] = sp;
    8000491a:	e9040c93          	addi	s9,s0,-368
    if(argc >= MAXARG)
    8000491e:	02000c13          	li	s8,32
  for(argc = 0; argv[argc]; argc++) {
    80004922:	cd21                	beqz	a0,8000497a <kexec+0x270>
    sp -= strlen(argv[argc]) + 1;
    80004924:	d90fc0ef          	jal	80000eb4 <strlen>
    80004928:	0015079b          	addiw	a5,a0,1
    8000492c:	40f907b3          	sub	a5,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80004930:	ff07f913          	andi	s2,a5,-16
    if(sp < stackbase)
    80004934:	13796563          	bltu	s2,s7,80004a5e <kexec+0x354>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80004938:	e0043d83          	ld	s11,-512(s0)
    8000493c:	000db983          	ld	s3,0(s11)
    80004940:	854e                	mv	a0,s3
    80004942:	d72fc0ef          	jal	80000eb4 <strlen>
    80004946:	0015069b          	addiw	a3,a0,1
    8000494a:	864e                	mv	a2,s3
    8000494c:	85ca                	mv	a1,s2
    8000494e:	855a                	mv	a0,s6
    80004950:	d3bfc0ef          	jal	8000168a <copyout>
    80004954:	10054763          	bltz	a0,80004a62 <kexec+0x358>
    ustack[argc] = sp;
    80004958:	00349793          	slli	a5,s1,0x3
    8000495c:	97e6                	add	a5,a5,s9
    8000495e:	0127b023          	sd	s2,0(a5) # fffffffffffff000 <end+0xffffffff7ffcb6e8>
  for(argc = 0; argv[argc]; argc++) {
    80004962:	0485                	addi	s1,s1,1
    80004964:	008d8793          	addi	a5,s11,8
    80004968:	e0f43023          	sd	a5,-512(s0)
    8000496c:	008db503          	ld	a0,8(s11)
    80004970:	c509                	beqz	a0,8000497a <kexec+0x270>
    if(argc >= MAXARG)
    80004972:	fb8499e3          	bne	s1,s8,80004924 <kexec+0x21a>
  sz = sz1;
    80004976:	89d2                	mv	s3,s4
    80004978:	b7a5                	j	800048e0 <kexec+0x1d6>
  ustack[argc] = 0;
    8000497a:	00349793          	slli	a5,s1,0x3
    8000497e:	f9078793          	addi	a5,a5,-112
    80004982:	97a2                	add	a5,a5,s0
    80004984:	f007b023          	sd	zero,-256(a5)
  sp -= (argc+1) * sizeof(uint64);
    80004988:	00349693          	slli	a3,s1,0x3
    8000498c:	06a1                	addi	a3,a3,8
    8000498e:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    80004992:	ff097913          	andi	s2,s2,-16
  sz = sz1;
    80004996:	89d2                	mv	s3,s4
  if(sp < stackbase)
    80004998:	f57964e3          	bltu	s2,s7,800048e0 <kexec+0x1d6>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    8000499c:	e9040613          	addi	a2,s0,-368
    800049a0:	85ca                	mv	a1,s2
    800049a2:	855a                	mv	a0,s6
    800049a4:	ce7fc0ef          	jal	8000168a <copyout>
    800049a8:	f2054ce3          	bltz	a0,800048e0 <kexec+0x1d6>
  p->trapframe->a1 = sp;
    800049ac:	058ab783          	ld	a5,88(s5) # 1058 <_entry-0x7fffefa8>
    800049b0:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    800049b4:	df043783          	ld	a5,-528(s0)
    800049b8:	0007c703          	lbu	a4,0(a5)
    800049bc:	cf11                	beqz	a4,800049d8 <kexec+0x2ce>
    800049be:	0785                	addi	a5,a5,1
    if(*s == '/')
    800049c0:	02f00693          	li	a3,47
    800049c4:	a029                	j	800049ce <kexec+0x2c4>
  for(last=s=path; *s; s++)
    800049c6:	0785                	addi	a5,a5,1
    800049c8:	fff7c703          	lbu	a4,-1(a5)
    800049cc:	c711                	beqz	a4,800049d8 <kexec+0x2ce>
    if(*s == '/')
    800049ce:	fed71ce3          	bne	a4,a3,800049c6 <kexec+0x2bc>
      last = s+1;
    800049d2:	def43823          	sd	a5,-528(s0)
    800049d6:	bfc5                	j	800049c6 <kexec+0x2bc>
  safestrcpy(p->name, last, sizeof(p->name));
    800049d8:	4641                	li	a2,16
    800049da:	df043583          	ld	a1,-528(s0)
    800049de:	158a8513          	addi	a0,s5,344
    800049e2:	c9cfc0ef          	jal	80000e7e <safestrcpy>
  oldpagetable = p->pagetable;
    800049e6:	050ab503          	ld	a0,80(s5)
  p->pagetable = pagetable;
    800049ea:	056ab823          	sd	s6,80(s5)
  p->sz = sz;
    800049ee:	054ab423          	sd	s4,72(s5)
  p->trapframe->epc = elf.entry;  // initial program counter = ulib.c:start()
    800049f2:	058ab783          	ld	a5,88(s5)
    800049f6:	e6843703          	ld	a4,-408(s0)
    800049fa:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    800049fc:	058ab783          	ld	a5,88(s5)
    80004a00:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    80004a04:	85ea                	mv	a1,s10
    80004a06:	8ecfd0ef          	jal	80001af2 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80004a0a:	0004851b          	sext.w	a0,s1
    80004a0e:	79fe                	ld	s3,504(sp)
    80004a10:	7a5e                	ld	s4,496(sp)
    80004a12:	7abe                	ld	s5,488(sp)
    80004a14:	7b1e                	ld	s6,480(sp)
    80004a16:	6bfe                	ld	s7,472(sp)
    80004a18:	6c5e                	ld	s8,464(sp)
    80004a1a:	6cbe                	ld	s9,456(sp)
    80004a1c:	6d1e                	ld	s10,448(sp)
    80004a1e:	7dfa                	ld	s11,440(sp)
    80004a20:	bbb1                	j	8000477c <kexec+0x72>
    80004a22:	7b1e                	ld	s6,480(sp)
    80004a24:	b3a9                	j	8000476e <kexec+0x64>
    80004a26:	df243c23          	sd	s2,-520(s0)
    proc_freepagetable(pagetable, sz);
    80004a2a:	df843583          	ld	a1,-520(s0)
    80004a2e:	855a                	mv	a0,s6
    80004a30:	8c2fd0ef          	jal	80001af2 <proc_freepagetable>
  if(ip){
    80004a34:	79fe                	ld	s3,504(sp)
    80004a36:	7abe                	ld	s5,488(sp)
    80004a38:	7b1e                	ld	s6,480(sp)
    80004a3a:	6bfe                	ld	s7,472(sp)
    80004a3c:	6c5e                	ld	s8,464(sp)
    80004a3e:	6cbe                	ld	s9,456(sp)
    80004a40:	6d1e                	ld	s10,448(sp)
    80004a42:	7dfa                	ld	s11,440(sp)
    80004a44:	b32d                	j	8000476e <kexec+0x64>
    80004a46:	df243c23          	sd	s2,-520(s0)
    80004a4a:	b7c5                	j	80004a2a <kexec+0x320>
    80004a4c:	df243c23          	sd	s2,-520(s0)
    80004a50:	bfe9                	j	80004a2a <kexec+0x320>
    80004a52:	df243c23          	sd	s2,-520(s0)
    80004a56:	bfd1                	j	80004a2a <kexec+0x320>
    80004a58:	df243c23          	sd	s2,-520(s0)
    80004a5c:	b7f9                	j	80004a2a <kexec+0x320>
  sz = sz1;
    80004a5e:	89d2                	mv	s3,s4
    80004a60:	b541                	j	800048e0 <kexec+0x1d6>
    80004a62:	89d2                	mv	s3,s4
    80004a64:	bdb5                	j	800048e0 <kexec+0x1d6>

0000000080004a66 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80004a66:	7179                	addi	sp,sp,-48
    80004a68:	f406                	sd	ra,40(sp)
    80004a6a:	f022                	sd	s0,32(sp)
    80004a6c:	ec26                	sd	s1,24(sp)
    80004a6e:	e84a                	sd	s2,16(sp)
    80004a70:	1800                	addi	s0,sp,48
    80004a72:	892e                	mv	s2,a1
    80004a74:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    80004a76:	fdc40593          	addi	a1,s0,-36
    80004a7a:	e0dfd0ef          	jal	80002886 <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    80004a7e:	fdc42703          	lw	a4,-36(s0)
    80004a82:	47bd                	li	a5,15
    80004a84:	02e7ea63          	bltu	a5,a4,80004ab8 <argfd+0x52>
    80004a88:	eddfc0ef          	jal	80001964 <myproc>
    80004a8c:	fdc42703          	lw	a4,-36(s0)
    80004a90:	00371793          	slli	a5,a4,0x3
    80004a94:	0d078793          	addi	a5,a5,208
    80004a98:	953e                	add	a0,a0,a5
    80004a9a:	611c                	ld	a5,0(a0)
    80004a9c:	c385                	beqz	a5,80004abc <argfd+0x56>
    return -1;
  if(pfd)
    80004a9e:	00090463          	beqz	s2,80004aa6 <argfd+0x40>
    *pfd = fd;
    80004aa2:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    80004aa6:	4501                	li	a0,0
  if(pf)
    80004aa8:	c091                	beqz	s1,80004aac <argfd+0x46>
    *pf = f;
    80004aaa:	e09c                	sd	a5,0(s1)
}
    80004aac:	70a2                	ld	ra,40(sp)
    80004aae:	7402                	ld	s0,32(sp)
    80004ab0:	64e2                	ld	s1,24(sp)
    80004ab2:	6942                	ld	s2,16(sp)
    80004ab4:	6145                	addi	sp,sp,48
    80004ab6:	8082                	ret
    return -1;
    80004ab8:	557d                	li	a0,-1
    80004aba:	bfcd                	j	80004aac <argfd+0x46>
    80004abc:	557d                	li	a0,-1
    80004abe:	b7fd                	j	80004aac <argfd+0x46>

0000000080004ac0 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    80004ac0:	1101                	addi	sp,sp,-32
    80004ac2:	ec06                	sd	ra,24(sp)
    80004ac4:	e822                	sd	s0,16(sp)
    80004ac6:	e426                	sd	s1,8(sp)
    80004ac8:	1000                	addi	s0,sp,32
    80004aca:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    80004acc:	e99fc0ef          	jal	80001964 <myproc>
    80004ad0:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    80004ad2:	0d050793          	addi	a5,a0,208
    80004ad6:	4501                	li	a0,0
    80004ad8:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    80004ada:	6398                	ld	a4,0(a5)
    80004adc:	cb19                	beqz	a4,80004af2 <fdalloc+0x32>
  for(fd = 0; fd < NOFILE; fd++){
    80004ade:	2505                	addiw	a0,a0,1
    80004ae0:	07a1                	addi	a5,a5,8
    80004ae2:	fed51ce3          	bne	a0,a3,80004ada <fdalloc+0x1a>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80004ae6:	557d                	li	a0,-1
}
    80004ae8:	60e2                	ld	ra,24(sp)
    80004aea:	6442                	ld	s0,16(sp)
    80004aec:	64a2                	ld	s1,8(sp)
    80004aee:	6105                	addi	sp,sp,32
    80004af0:	8082                	ret
      p->ofile[fd] = f;
    80004af2:	00351793          	slli	a5,a0,0x3
    80004af6:	0d078793          	addi	a5,a5,208
    80004afa:	963e                	add	a2,a2,a5
    80004afc:	e204                	sd	s1,0(a2)
      return fd;
    80004afe:	b7ed                	j	80004ae8 <fdalloc+0x28>

0000000080004b00 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    80004b00:	715d                	addi	sp,sp,-80
    80004b02:	e486                	sd	ra,72(sp)
    80004b04:	e0a2                	sd	s0,64(sp)
    80004b06:	fc26                	sd	s1,56(sp)
    80004b08:	f84a                	sd	s2,48(sp)
    80004b0a:	f44e                	sd	s3,40(sp)
    80004b0c:	f052                	sd	s4,32(sp)
    80004b0e:	ec56                	sd	s5,24(sp)
    80004b10:	e85a                	sd	s6,16(sp)
    80004b12:	0880                	addi	s0,sp,80
    80004b14:	892e                	mv	s2,a1
    80004b16:	8a2e                	mv	s4,a1
    80004b18:	8ab2                	mv	s5,a2
    80004b1a:	8b36                	mv	s6,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    80004b1c:	fb040593          	addi	a1,s0,-80
    80004b20:	fb7fe0ef          	jal	80003ad6 <nameiparent>
    80004b24:	84aa                	mv	s1,a0
    80004b26:	10050763          	beqz	a0,80004c34 <create+0x134>
    return 0;

  ilock(dp);
    80004b2a:	f64fe0ef          	jal	8000328e <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    80004b2e:	4601                	li	a2,0
    80004b30:	fb040593          	addi	a1,s0,-80
    80004b34:	8526                	mv	a0,s1
    80004b36:	cf3fe0ef          	jal	80003828 <dirlookup>
    80004b3a:	89aa                	mv	s3,a0
    80004b3c:	c131                	beqz	a0,80004b80 <create+0x80>
    iunlockput(dp);
    80004b3e:	8526                	mv	a0,s1
    80004b40:	95bfe0ef          	jal	8000349a <iunlockput>
    ilock(ip);
    80004b44:	854e                	mv	a0,s3
    80004b46:	f48fe0ef          	jal	8000328e <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80004b4a:	4789                	li	a5,2
    80004b4c:	02f91563          	bne	s2,a5,80004b76 <create+0x76>
    80004b50:	0449d783          	lhu	a5,68(s3)
    80004b54:	37f9                	addiw	a5,a5,-2
    80004b56:	17c2                	slli	a5,a5,0x30
    80004b58:	93c1                	srli	a5,a5,0x30
    80004b5a:	4705                	li	a4,1
    80004b5c:	00f76d63          	bltu	a4,a5,80004b76 <create+0x76>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    80004b60:	854e                	mv	a0,s3
    80004b62:	60a6                	ld	ra,72(sp)
    80004b64:	6406                	ld	s0,64(sp)
    80004b66:	74e2                	ld	s1,56(sp)
    80004b68:	7942                	ld	s2,48(sp)
    80004b6a:	79a2                	ld	s3,40(sp)
    80004b6c:	7a02                	ld	s4,32(sp)
    80004b6e:	6ae2                	ld	s5,24(sp)
    80004b70:	6b42                	ld	s6,16(sp)
    80004b72:	6161                	addi	sp,sp,80
    80004b74:	8082                	ret
    iunlockput(ip);
    80004b76:	854e                	mv	a0,s3
    80004b78:	923fe0ef          	jal	8000349a <iunlockput>
    return 0;
    80004b7c:	4981                	li	s3,0
    80004b7e:	b7cd                	j	80004b60 <create+0x60>
  if((ip = ialloc(dp->dev, type)) == 0){
    80004b80:	85ca                	mv	a1,s2
    80004b82:	4088                	lw	a0,0(s1)
    80004b84:	d9afe0ef          	jal	8000311e <ialloc>
    80004b88:	892a                	mv	s2,a0
    80004b8a:	cd15                	beqz	a0,80004bc6 <create+0xc6>
  ilock(ip);
    80004b8c:	f02fe0ef          	jal	8000328e <ilock>
  ip->major = major;
    80004b90:	05591323          	sh	s5,70(s2)
  ip->minor = minor;
    80004b94:	05691423          	sh	s6,72(s2)
  ip->nlink = 1;
    80004b98:	4785                	li	a5,1
    80004b9a:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80004b9e:	854a                	mv	a0,s2
    80004ba0:	e3afe0ef          	jal	800031da <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    80004ba4:	4705                	li	a4,1
    80004ba6:	02ea0463          	beq	s4,a4,80004bce <create+0xce>
  if(dirlink(dp, name, ip->inum) < 0)
    80004baa:	00492603          	lw	a2,4(s2)
    80004bae:	fb040593          	addi	a1,s0,-80
    80004bb2:	8526                	mv	a0,s1
    80004bb4:	e5ffe0ef          	jal	80003a12 <dirlink>
    80004bb8:	06054263          	bltz	a0,80004c1c <create+0x11c>
  iunlockput(dp);
    80004bbc:	8526                	mv	a0,s1
    80004bbe:	8ddfe0ef          	jal	8000349a <iunlockput>
  return ip;
    80004bc2:	89ca                	mv	s3,s2
    80004bc4:	bf71                	j	80004b60 <create+0x60>
    iunlockput(dp);
    80004bc6:	8526                	mv	a0,s1
    80004bc8:	8d3fe0ef          	jal	8000349a <iunlockput>
    return 0;
    80004bcc:	bf51                	j	80004b60 <create+0x60>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    80004bce:	00492603          	lw	a2,4(s2)
    80004bd2:	00003597          	auipc	a1,0x3
    80004bd6:	9fe58593          	addi	a1,a1,-1538 # 800075d0 <etext+0x5d0>
    80004bda:	854a                	mv	a0,s2
    80004bdc:	e37fe0ef          	jal	80003a12 <dirlink>
    80004be0:	02054e63          	bltz	a0,80004c1c <create+0x11c>
    80004be4:	40d0                	lw	a2,4(s1)
    80004be6:	00003597          	auipc	a1,0x3
    80004bea:	9f258593          	addi	a1,a1,-1550 # 800075d8 <etext+0x5d8>
    80004bee:	854a                	mv	a0,s2
    80004bf0:	e23fe0ef          	jal	80003a12 <dirlink>
    80004bf4:	02054463          	bltz	a0,80004c1c <create+0x11c>
  if(dirlink(dp, name, ip->inum) < 0)
    80004bf8:	00492603          	lw	a2,4(s2)
    80004bfc:	fb040593          	addi	a1,s0,-80
    80004c00:	8526                	mv	a0,s1
    80004c02:	e11fe0ef          	jal	80003a12 <dirlink>
    80004c06:	00054b63          	bltz	a0,80004c1c <create+0x11c>
    dp->nlink++;  // for ".."
    80004c0a:	04a4d783          	lhu	a5,74(s1)
    80004c0e:	2785                	addiw	a5,a5,1
    80004c10:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80004c14:	8526                	mv	a0,s1
    80004c16:	dc4fe0ef          	jal	800031da <iupdate>
    80004c1a:	b74d                	j	80004bbc <create+0xbc>
  ip->nlink = 0;
    80004c1c:	04091523          	sh	zero,74(s2)
  iupdate(ip);
    80004c20:	854a                	mv	a0,s2
    80004c22:	db8fe0ef          	jal	800031da <iupdate>
  iunlockput(ip);
    80004c26:	854a                	mv	a0,s2
    80004c28:	873fe0ef          	jal	8000349a <iunlockput>
  iunlockput(dp);
    80004c2c:	8526                	mv	a0,s1
    80004c2e:	86dfe0ef          	jal	8000349a <iunlockput>
  return 0;
    80004c32:	b73d                	j	80004b60 <create+0x60>
    return 0;
    80004c34:	89aa                	mv	s3,a0
    80004c36:	b72d                	j	80004b60 <create+0x60>

0000000080004c38 <sys_dup>:
{
    80004c38:	7179                	addi	sp,sp,-48
    80004c3a:	f406                	sd	ra,40(sp)
    80004c3c:	f022                	sd	s0,32(sp)
    80004c3e:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    80004c40:	fd840613          	addi	a2,s0,-40
    80004c44:	4581                	li	a1,0
    80004c46:	4501                	li	a0,0
    80004c48:	e1fff0ef          	jal	80004a66 <argfd>
    return -1;
    80004c4c:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    80004c4e:	02054363          	bltz	a0,80004c74 <sys_dup+0x3c>
    80004c52:	ec26                	sd	s1,24(sp)
    80004c54:	e84a                	sd	s2,16(sp)
  if((fd=fdalloc(f)) < 0)
    80004c56:	fd843483          	ld	s1,-40(s0)
    80004c5a:	8526                	mv	a0,s1
    80004c5c:	e65ff0ef          	jal	80004ac0 <fdalloc>
    80004c60:	892a                	mv	s2,a0
    return -1;
    80004c62:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    80004c64:	00054d63          	bltz	a0,80004c7e <sys_dup+0x46>
  filedup(f);
    80004c68:	8526                	mv	a0,s1
    80004c6a:	c0eff0ef          	jal	80004078 <filedup>
  return fd;
    80004c6e:	87ca                	mv	a5,s2
    80004c70:	64e2                	ld	s1,24(sp)
    80004c72:	6942                	ld	s2,16(sp)
}
    80004c74:	853e                	mv	a0,a5
    80004c76:	70a2                	ld	ra,40(sp)
    80004c78:	7402                	ld	s0,32(sp)
    80004c7a:	6145                	addi	sp,sp,48
    80004c7c:	8082                	ret
    80004c7e:	64e2                	ld	s1,24(sp)
    80004c80:	6942                	ld	s2,16(sp)
    80004c82:	bfcd                	j	80004c74 <sys_dup+0x3c>

0000000080004c84 <sys_read>:
{
    80004c84:	7179                	addi	sp,sp,-48
    80004c86:	f406                	sd	ra,40(sp)
    80004c88:	f022                	sd	s0,32(sp)
    80004c8a:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80004c8c:	fd840593          	addi	a1,s0,-40
    80004c90:	4505                	li	a0,1
    80004c92:	c11fd0ef          	jal	800028a2 <argaddr>
  argint(2, &n);
    80004c96:	fe440593          	addi	a1,s0,-28
    80004c9a:	4509                	li	a0,2
    80004c9c:	bebfd0ef          	jal	80002886 <argint>
  if(argfd(0, 0, &f) < 0)
    80004ca0:	fe840613          	addi	a2,s0,-24
    80004ca4:	4581                	li	a1,0
    80004ca6:	4501                	li	a0,0
    80004ca8:	dbfff0ef          	jal	80004a66 <argfd>
    80004cac:	87aa                	mv	a5,a0
    return -1;
    80004cae:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80004cb0:	0007ca63          	bltz	a5,80004cc4 <sys_read+0x40>
  return fileread(f, p, n);
    80004cb4:	fe442603          	lw	a2,-28(s0)
    80004cb8:	fd843583          	ld	a1,-40(s0)
    80004cbc:	fe843503          	ld	a0,-24(s0)
    80004cc0:	d22ff0ef          	jal	800041e2 <fileread>
}
    80004cc4:	70a2                	ld	ra,40(sp)
    80004cc6:	7402                	ld	s0,32(sp)
    80004cc8:	6145                	addi	sp,sp,48
    80004cca:	8082                	ret

0000000080004ccc <sys_write>:
{
    80004ccc:	7179                	addi	sp,sp,-48
    80004cce:	f406                	sd	ra,40(sp)
    80004cd0:	f022                	sd	s0,32(sp)
    80004cd2:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80004cd4:	fd840593          	addi	a1,s0,-40
    80004cd8:	4505                	li	a0,1
    80004cda:	bc9fd0ef          	jal	800028a2 <argaddr>
  argint(2, &n);
    80004cde:	fe440593          	addi	a1,s0,-28
    80004ce2:	4509                	li	a0,2
    80004ce4:	ba3fd0ef          	jal	80002886 <argint>
  if(argfd(0, 0, &f) < 0)
    80004ce8:	fe840613          	addi	a2,s0,-24
    80004cec:	4581                	li	a1,0
    80004cee:	4501                	li	a0,0
    80004cf0:	d77ff0ef          	jal	80004a66 <argfd>
    80004cf4:	87aa                	mv	a5,a0
    return -1;
    80004cf6:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80004cf8:	0007ca63          	bltz	a5,80004d0c <sys_write+0x40>
  return filewrite(f, p, n);
    80004cfc:	fe442603          	lw	a2,-28(s0)
    80004d00:	fd843583          	ld	a1,-40(s0)
    80004d04:	fe843503          	ld	a0,-24(s0)
    80004d08:	d9eff0ef          	jal	800042a6 <filewrite>
}
    80004d0c:	70a2                	ld	ra,40(sp)
    80004d0e:	7402                	ld	s0,32(sp)
    80004d10:	6145                	addi	sp,sp,48
    80004d12:	8082                	ret

0000000080004d14 <sys_close>:
{
    80004d14:	1101                	addi	sp,sp,-32
    80004d16:	ec06                	sd	ra,24(sp)
    80004d18:	e822                	sd	s0,16(sp)
    80004d1a:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    80004d1c:	fe040613          	addi	a2,s0,-32
    80004d20:	fec40593          	addi	a1,s0,-20
    80004d24:	4501                	li	a0,0
    80004d26:	d41ff0ef          	jal	80004a66 <argfd>
    return -1;
    80004d2a:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    80004d2c:	02054163          	bltz	a0,80004d4e <sys_close+0x3a>
  myproc()->ofile[fd] = 0;
    80004d30:	c35fc0ef          	jal	80001964 <myproc>
    80004d34:	fec42783          	lw	a5,-20(s0)
    80004d38:	078e                	slli	a5,a5,0x3
    80004d3a:	0d078793          	addi	a5,a5,208
    80004d3e:	953e                	add	a0,a0,a5
    80004d40:	00053023          	sd	zero,0(a0)
  fileclose(f);
    80004d44:	fe043503          	ld	a0,-32(s0)
    80004d48:	b76ff0ef          	jal	800040be <fileclose>
  return 0;
    80004d4c:	4781                	li	a5,0
}
    80004d4e:	853e                	mv	a0,a5
    80004d50:	60e2                	ld	ra,24(sp)
    80004d52:	6442                	ld	s0,16(sp)
    80004d54:	6105                	addi	sp,sp,32
    80004d56:	8082                	ret

0000000080004d58 <sys_fstat>:
{
    80004d58:	1101                	addi	sp,sp,-32
    80004d5a:	ec06                	sd	ra,24(sp)
    80004d5c:	e822                	sd	s0,16(sp)
    80004d5e:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    80004d60:	fe040593          	addi	a1,s0,-32
    80004d64:	4505                	li	a0,1
    80004d66:	b3dfd0ef          	jal	800028a2 <argaddr>
  if(argfd(0, 0, &f) < 0)
    80004d6a:	fe840613          	addi	a2,s0,-24
    80004d6e:	4581                	li	a1,0
    80004d70:	4501                	li	a0,0
    80004d72:	cf5ff0ef          	jal	80004a66 <argfd>
    80004d76:	87aa                	mv	a5,a0
    return -1;
    80004d78:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80004d7a:	0007c863          	bltz	a5,80004d8a <sys_fstat+0x32>
  return filestat(f, st);
    80004d7e:	fe043583          	ld	a1,-32(s0)
    80004d82:	fe843503          	ld	a0,-24(s0)
    80004d86:	bfaff0ef          	jal	80004180 <filestat>
}
    80004d8a:	60e2                	ld	ra,24(sp)
    80004d8c:	6442                	ld	s0,16(sp)
    80004d8e:	6105                	addi	sp,sp,32
    80004d90:	8082                	ret

0000000080004d92 <sys_link>:
{
    80004d92:	7169                	addi	sp,sp,-304
    80004d94:	f606                	sd	ra,296(sp)
    80004d96:	f222                	sd	s0,288(sp)
    80004d98:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80004d9a:	08000613          	li	a2,128
    80004d9e:	ed040593          	addi	a1,s0,-304
    80004da2:	4501                	li	a0,0
    80004da4:	b1bfd0ef          	jal	800028be <argstr>
    return -1;
    80004da8:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80004daa:	0c054e63          	bltz	a0,80004e86 <sys_link+0xf4>
    80004dae:	08000613          	li	a2,128
    80004db2:	f5040593          	addi	a1,s0,-176
    80004db6:	4505                	li	a0,1
    80004db8:	b07fd0ef          	jal	800028be <argstr>
    return -1;
    80004dbc:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80004dbe:	0c054463          	bltz	a0,80004e86 <sys_link+0xf4>
    80004dc2:	ee26                	sd	s1,280(sp)
  begin_op();
    80004dc4:	ed7fe0ef          	jal	80003c9a <begin_op>
  if((ip = namei(old)) == 0){
    80004dc8:	ed040513          	addi	a0,s0,-304
    80004dcc:	cf1fe0ef          	jal	80003abc <namei>
    80004dd0:	84aa                	mv	s1,a0
    80004dd2:	c53d                	beqz	a0,80004e40 <sys_link+0xae>
  ilock(ip);
    80004dd4:	cbafe0ef          	jal	8000328e <ilock>
  if(ip->type == T_DIR){
    80004dd8:	04449703          	lh	a4,68(s1)
    80004ddc:	4785                	li	a5,1
    80004dde:	06f70663          	beq	a4,a5,80004e4a <sys_link+0xb8>
    80004de2:	ea4a                	sd	s2,272(sp)
  ip->nlink++;
    80004de4:	04a4d783          	lhu	a5,74(s1)
    80004de8:	2785                	addiw	a5,a5,1
    80004dea:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80004dee:	8526                	mv	a0,s1
    80004df0:	beafe0ef          	jal	800031da <iupdate>
  iunlock(ip);
    80004df4:	8526                	mv	a0,s1
    80004df6:	d46fe0ef          	jal	8000333c <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    80004dfa:	fd040593          	addi	a1,s0,-48
    80004dfe:	f5040513          	addi	a0,s0,-176
    80004e02:	cd5fe0ef          	jal	80003ad6 <nameiparent>
    80004e06:	892a                	mv	s2,a0
    80004e08:	cd21                	beqz	a0,80004e60 <sys_link+0xce>
  ilock(dp);
    80004e0a:	c84fe0ef          	jal	8000328e <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    80004e0e:	854a                	mv	a0,s2
    80004e10:	00092703          	lw	a4,0(s2)
    80004e14:	409c                	lw	a5,0(s1)
    80004e16:	04f71263          	bne	a4,a5,80004e5a <sys_link+0xc8>
    80004e1a:	40d0                	lw	a2,4(s1)
    80004e1c:	fd040593          	addi	a1,s0,-48
    80004e20:	bf3fe0ef          	jal	80003a12 <dirlink>
    80004e24:	02054b63          	bltz	a0,80004e5a <sys_link+0xc8>
  iunlockput(dp);
    80004e28:	854a                	mv	a0,s2
    80004e2a:	e70fe0ef          	jal	8000349a <iunlockput>
  iput(ip);
    80004e2e:	8526                	mv	a0,s1
    80004e30:	de0fe0ef          	jal	80003410 <iput>
  end_op();
    80004e34:	ed7fe0ef          	jal	80003d0a <end_op>
  return 0;
    80004e38:	4781                	li	a5,0
    80004e3a:	64f2                	ld	s1,280(sp)
    80004e3c:	6952                	ld	s2,272(sp)
    80004e3e:	a0a1                	j	80004e86 <sys_link+0xf4>
    end_op();
    80004e40:	ecbfe0ef          	jal	80003d0a <end_op>
    return -1;
    80004e44:	57fd                	li	a5,-1
    80004e46:	64f2                	ld	s1,280(sp)
    80004e48:	a83d                	j	80004e86 <sys_link+0xf4>
    iunlockput(ip);
    80004e4a:	8526                	mv	a0,s1
    80004e4c:	e4efe0ef          	jal	8000349a <iunlockput>
    end_op();
    80004e50:	ebbfe0ef          	jal	80003d0a <end_op>
    return -1;
    80004e54:	57fd                	li	a5,-1
    80004e56:	64f2                	ld	s1,280(sp)
    80004e58:	a03d                	j	80004e86 <sys_link+0xf4>
    iunlockput(dp);
    80004e5a:	854a                	mv	a0,s2
    80004e5c:	e3efe0ef          	jal	8000349a <iunlockput>
  ilock(ip);
    80004e60:	8526                	mv	a0,s1
    80004e62:	c2cfe0ef          	jal	8000328e <ilock>
  ip->nlink--;
    80004e66:	04a4d783          	lhu	a5,74(s1)
    80004e6a:	37fd                	addiw	a5,a5,-1
    80004e6c:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80004e70:	8526                	mv	a0,s1
    80004e72:	b68fe0ef          	jal	800031da <iupdate>
  iunlockput(ip);
    80004e76:	8526                	mv	a0,s1
    80004e78:	e22fe0ef          	jal	8000349a <iunlockput>
  end_op();
    80004e7c:	e8ffe0ef          	jal	80003d0a <end_op>
  return -1;
    80004e80:	57fd                	li	a5,-1
    80004e82:	64f2                	ld	s1,280(sp)
    80004e84:	6952                	ld	s2,272(sp)
}
    80004e86:	853e                	mv	a0,a5
    80004e88:	70b2                	ld	ra,296(sp)
    80004e8a:	7412                	ld	s0,288(sp)
    80004e8c:	6155                	addi	sp,sp,304
    80004e8e:	8082                	ret

0000000080004e90 <sys_unlink>:
{
    80004e90:	7151                	addi	sp,sp,-240
    80004e92:	f586                	sd	ra,232(sp)
    80004e94:	f1a2                	sd	s0,224(sp)
    80004e96:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    80004e98:	08000613          	li	a2,128
    80004e9c:	f3040593          	addi	a1,s0,-208
    80004ea0:	4501                	li	a0,0
    80004ea2:	a1dfd0ef          	jal	800028be <argstr>
    80004ea6:	14054d63          	bltz	a0,80005000 <sys_unlink+0x170>
    80004eaa:	eda6                	sd	s1,216(sp)
  begin_op();
    80004eac:	deffe0ef          	jal	80003c9a <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    80004eb0:	fb040593          	addi	a1,s0,-80
    80004eb4:	f3040513          	addi	a0,s0,-208
    80004eb8:	c1ffe0ef          	jal	80003ad6 <nameiparent>
    80004ebc:	84aa                	mv	s1,a0
    80004ebe:	c955                	beqz	a0,80004f72 <sys_unlink+0xe2>
  ilock(dp);
    80004ec0:	bcefe0ef          	jal	8000328e <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80004ec4:	00002597          	auipc	a1,0x2
    80004ec8:	70c58593          	addi	a1,a1,1804 # 800075d0 <etext+0x5d0>
    80004ecc:	fb040513          	addi	a0,s0,-80
    80004ed0:	943fe0ef          	jal	80003812 <namecmp>
    80004ed4:	10050b63          	beqz	a0,80004fea <sys_unlink+0x15a>
    80004ed8:	00002597          	auipc	a1,0x2
    80004edc:	70058593          	addi	a1,a1,1792 # 800075d8 <etext+0x5d8>
    80004ee0:	fb040513          	addi	a0,s0,-80
    80004ee4:	92ffe0ef          	jal	80003812 <namecmp>
    80004ee8:	10050163          	beqz	a0,80004fea <sys_unlink+0x15a>
    80004eec:	e9ca                	sd	s2,208(sp)
  if((ip = dirlookup(dp, name, &off)) == 0)
    80004eee:	f2c40613          	addi	a2,s0,-212
    80004ef2:	fb040593          	addi	a1,s0,-80
    80004ef6:	8526                	mv	a0,s1
    80004ef8:	931fe0ef          	jal	80003828 <dirlookup>
    80004efc:	892a                	mv	s2,a0
    80004efe:	0e050563          	beqz	a0,80004fe8 <sys_unlink+0x158>
    80004f02:	e5ce                	sd	s3,200(sp)
  ilock(ip);
    80004f04:	b8afe0ef          	jal	8000328e <ilock>
  if(ip->nlink < 1)
    80004f08:	04a91783          	lh	a5,74(s2)
    80004f0c:	06f05863          	blez	a5,80004f7c <sys_unlink+0xec>
  if(ip->type == T_DIR && !isdirempty(ip)){
    80004f10:	04491703          	lh	a4,68(s2)
    80004f14:	4785                	li	a5,1
    80004f16:	06f70963          	beq	a4,a5,80004f88 <sys_unlink+0xf8>
  memset(&de, 0, sizeof(de));
    80004f1a:	fc040993          	addi	s3,s0,-64
    80004f1e:	4641                	li	a2,16
    80004f20:	4581                	li	a1,0
    80004f22:	854e                	mv	a0,s3
    80004f24:	e07fb0ef          	jal	80000d2a <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004f28:	4741                	li	a4,16
    80004f2a:	f2c42683          	lw	a3,-212(s0)
    80004f2e:	864e                	mv	a2,s3
    80004f30:	4581                	li	a1,0
    80004f32:	8526                	mv	a0,s1
    80004f34:	fdefe0ef          	jal	80003712 <writei>
    80004f38:	47c1                	li	a5,16
    80004f3a:	08f51863          	bne	a0,a5,80004fca <sys_unlink+0x13a>
  if(ip->type == T_DIR){
    80004f3e:	04491703          	lh	a4,68(s2)
    80004f42:	4785                	li	a5,1
    80004f44:	08f70963          	beq	a4,a5,80004fd6 <sys_unlink+0x146>
  iunlockput(dp);
    80004f48:	8526                	mv	a0,s1
    80004f4a:	d50fe0ef          	jal	8000349a <iunlockput>
  ip->nlink--;
    80004f4e:	04a95783          	lhu	a5,74(s2)
    80004f52:	37fd                	addiw	a5,a5,-1
    80004f54:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80004f58:	854a                	mv	a0,s2
    80004f5a:	a80fe0ef          	jal	800031da <iupdate>
  iunlockput(ip);
    80004f5e:	854a                	mv	a0,s2
    80004f60:	d3afe0ef          	jal	8000349a <iunlockput>
  end_op();
    80004f64:	da7fe0ef          	jal	80003d0a <end_op>
  return 0;
    80004f68:	4501                	li	a0,0
    80004f6a:	64ee                	ld	s1,216(sp)
    80004f6c:	694e                	ld	s2,208(sp)
    80004f6e:	69ae                	ld	s3,200(sp)
    80004f70:	a061                	j	80004ff8 <sys_unlink+0x168>
    end_op();
    80004f72:	d99fe0ef          	jal	80003d0a <end_op>
    return -1;
    80004f76:	557d                	li	a0,-1
    80004f78:	64ee                	ld	s1,216(sp)
    80004f7a:	a8bd                	j	80004ff8 <sys_unlink+0x168>
    panic("unlink: nlink < 1");
    80004f7c:	00002517          	auipc	a0,0x2
    80004f80:	66450513          	addi	a0,a0,1636 # 800075e0 <etext+0x5e0>
    80004f84:	8d3fb0ef          	jal	80000856 <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80004f88:	04c92703          	lw	a4,76(s2)
    80004f8c:	02000793          	li	a5,32
    80004f90:	f8e7f5e3          	bgeu	a5,a4,80004f1a <sys_unlink+0x8a>
    80004f94:	89be                	mv	s3,a5
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004f96:	4741                	li	a4,16
    80004f98:	86ce                	mv	a3,s3
    80004f9a:	f1840613          	addi	a2,s0,-232
    80004f9e:	4581                	li	a1,0
    80004fa0:	854a                	mv	a0,s2
    80004fa2:	e7efe0ef          	jal	80003620 <readi>
    80004fa6:	47c1                	li	a5,16
    80004fa8:	00f51b63          	bne	a0,a5,80004fbe <sys_unlink+0x12e>
    if(de.inum != 0)
    80004fac:	f1845783          	lhu	a5,-232(s0)
    80004fb0:	ebb1                	bnez	a5,80005004 <sys_unlink+0x174>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80004fb2:	29c1                	addiw	s3,s3,16
    80004fb4:	04c92783          	lw	a5,76(s2)
    80004fb8:	fcf9efe3          	bltu	s3,a5,80004f96 <sys_unlink+0x106>
    80004fbc:	bfb9                	j	80004f1a <sys_unlink+0x8a>
      panic("isdirempty: readi");
    80004fbe:	00002517          	auipc	a0,0x2
    80004fc2:	63a50513          	addi	a0,a0,1594 # 800075f8 <etext+0x5f8>
    80004fc6:	891fb0ef          	jal	80000856 <panic>
    panic("unlink: writei");
    80004fca:	00002517          	auipc	a0,0x2
    80004fce:	64650513          	addi	a0,a0,1606 # 80007610 <etext+0x610>
    80004fd2:	885fb0ef          	jal	80000856 <panic>
    dp->nlink--;
    80004fd6:	04a4d783          	lhu	a5,74(s1)
    80004fda:	37fd                	addiw	a5,a5,-1
    80004fdc:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80004fe0:	8526                	mv	a0,s1
    80004fe2:	9f8fe0ef          	jal	800031da <iupdate>
    80004fe6:	b78d                	j	80004f48 <sys_unlink+0xb8>
    80004fe8:	694e                	ld	s2,208(sp)
  iunlockput(dp);
    80004fea:	8526                	mv	a0,s1
    80004fec:	caefe0ef          	jal	8000349a <iunlockput>
  end_op();
    80004ff0:	d1bfe0ef          	jal	80003d0a <end_op>
  return -1;
    80004ff4:	557d                	li	a0,-1
    80004ff6:	64ee                	ld	s1,216(sp)
}
    80004ff8:	70ae                	ld	ra,232(sp)
    80004ffa:	740e                	ld	s0,224(sp)
    80004ffc:	616d                	addi	sp,sp,240
    80004ffe:	8082                	ret
    return -1;
    80005000:	557d                	li	a0,-1
    80005002:	bfdd                	j	80004ff8 <sys_unlink+0x168>
    iunlockput(ip);
    80005004:	854a                	mv	a0,s2
    80005006:	c94fe0ef          	jal	8000349a <iunlockput>
    goto bad;
    8000500a:	694e                	ld	s2,208(sp)
    8000500c:	69ae                	ld	s3,200(sp)
    8000500e:	bff1                	j	80004fea <sys_unlink+0x15a>

0000000080005010 <sys_open>:

uint64
sys_open(void)
{
    80005010:	7131                	addi	sp,sp,-192
    80005012:	fd06                	sd	ra,184(sp)
    80005014:	f922                	sd	s0,176(sp)
    80005016:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    80005018:	f4c40593          	addi	a1,s0,-180
    8000501c:	4505                	li	a0,1
    8000501e:	869fd0ef          	jal	80002886 <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    80005022:	08000613          	li	a2,128
    80005026:	f5040593          	addi	a1,s0,-176
    8000502a:	4501                	li	a0,0
    8000502c:	893fd0ef          	jal	800028be <argstr>
    80005030:	87aa                	mv	a5,a0
    return -1;
    80005032:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    80005034:	0a07c363          	bltz	a5,800050da <sys_open+0xca>
    80005038:	f526                	sd	s1,168(sp)

  begin_op();
    8000503a:	c61fe0ef          	jal	80003c9a <begin_op>

  if(omode & O_CREATE){
    8000503e:	f4c42783          	lw	a5,-180(s0)
    80005042:	2007f793          	andi	a5,a5,512
    80005046:	c3dd                	beqz	a5,800050ec <sys_open+0xdc>
    ip = create(path, T_FILE, 0, 0);
    80005048:	4681                	li	a3,0
    8000504a:	4601                	li	a2,0
    8000504c:	4589                	li	a1,2
    8000504e:	f5040513          	addi	a0,s0,-176
    80005052:	aafff0ef          	jal	80004b00 <create>
    80005056:	84aa                	mv	s1,a0
    if(ip == 0){
    80005058:	c549                	beqz	a0,800050e2 <sys_open+0xd2>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    8000505a:	04449703          	lh	a4,68(s1)
    8000505e:	478d                	li	a5,3
    80005060:	00f71763          	bne	a4,a5,8000506e <sys_open+0x5e>
    80005064:	0464d703          	lhu	a4,70(s1)
    80005068:	47a5                	li	a5,9
    8000506a:	0ae7ee63          	bltu	a5,a4,80005126 <sys_open+0x116>
    8000506e:	f14a                	sd	s2,160(sp)
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    80005070:	fabfe0ef          	jal	8000401a <filealloc>
    80005074:	892a                	mv	s2,a0
    80005076:	c561                	beqz	a0,8000513e <sys_open+0x12e>
    80005078:	ed4e                	sd	s3,152(sp)
    8000507a:	a47ff0ef          	jal	80004ac0 <fdalloc>
    8000507e:	89aa                	mv	s3,a0
    80005080:	0a054b63          	bltz	a0,80005136 <sys_open+0x126>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    80005084:	04449703          	lh	a4,68(s1)
    80005088:	478d                	li	a5,3
    8000508a:	0cf70363          	beq	a4,a5,80005150 <sys_open+0x140>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    8000508e:	4789                	li	a5,2
    80005090:	00f92023          	sw	a5,0(s2)
    f->off = 0;
    80005094:	02092023          	sw	zero,32(s2)
  }
  f->ip = ip;
    80005098:	00993c23          	sd	s1,24(s2)
  f->readable = !(omode & O_WRONLY);
    8000509c:	f4c42783          	lw	a5,-180(s0)
    800050a0:	0017f713          	andi	a4,a5,1
    800050a4:	00174713          	xori	a4,a4,1
    800050a8:	00e90423          	sb	a4,8(s2)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    800050ac:	0037f713          	andi	a4,a5,3
    800050b0:	00e03733          	snez	a4,a4
    800050b4:	00e904a3          	sb	a4,9(s2)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    800050b8:	4007f793          	andi	a5,a5,1024
    800050bc:	c791                	beqz	a5,800050c8 <sys_open+0xb8>
    800050be:	04449703          	lh	a4,68(s1)
    800050c2:	4789                	li	a5,2
    800050c4:	08f70d63          	beq	a4,a5,8000515e <sys_open+0x14e>
    itrunc(ip);
  }

  iunlock(ip);
    800050c8:	8526                	mv	a0,s1
    800050ca:	a72fe0ef          	jal	8000333c <iunlock>
  end_op();
    800050ce:	c3dfe0ef          	jal	80003d0a <end_op>

  return fd;
    800050d2:	854e                	mv	a0,s3
    800050d4:	74aa                	ld	s1,168(sp)
    800050d6:	790a                	ld	s2,160(sp)
    800050d8:	69ea                	ld	s3,152(sp)
}
    800050da:	70ea                	ld	ra,184(sp)
    800050dc:	744a                	ld	s0,176(sp)
    800050de:	6129                	addi	sp,sp,192
    800050e0:	8082                	ret
      end_op();
    800050e2:	c29fe0ef          	jal	80003d0a <end_op>
      return -1;
    800050e6:	557d                	li	a0,-1
    800050e8:	74aa                	ld	s1,168(sp)
    800050ea:	bfc5                	j	800050da <sys_open+0xca>
    if((ip = namei(path)) == 0){
    800050ec:	f5040513          	addi	a0,s0,-176
    800050f0:	9cdfe0ef          	jal	80003abc <namei>
    800050f4:	84aa                	mv	s1,a0
    800050f6:	c11d                	beqz	a0,8000511c <sys_open+0x10c>
    ilock(ip);
    800050f8:	996fe0ef          	jal	8000328e <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    800050fc:	04449703          	lh	a4,68(s1)
    80005100:	4785                	li	a5,1
    80005102:	f4f71ce3          	bne	a4,a5,8000505a <sys_open+0x4a>
    80005106:	f4c42783          	lw	a5,-180(s0)
    8000510a:	d3b5                	beqz	a5,8000506e <sys_open+0x5e>
      iunlockput(ip);
    8000510c:	8526                	mv	a0,s1
    8000510e:	b8cfe0ef          	jal	8000349a <iunlockput>
      end_op();
    80005112:	bf9fe0ef          	jal	80003d0a <end_op>
      return -1;
    80005116:	557d                	li	a0,-1
    80005118:	74aa                	ld	s1,168(sp)
    8000511a:	b7c1                	j	800050da <sys_open+0xca>
      end_op();
    8000511c:	beffe0ef          	jal	80003d0a <end_op>
      return -1;
    80005120:	557d                	li	a0,-1
    80005122:	74aa                	ld	s1,168(sp)
    80005124:	bf5d                	j	800050da <sys_open+0xca>
    iunlockput(ip);
    80005126:	8526                	mv	a0,s1
    80005128:	b72fe0ef          	jal	8000349a <iunlockput>
    end_op();
    8000512c:	bdffe0ef          	jal	80003d0a <end_op>
    return -1;
    80005130:	557d                	li	a0,-1
    80005132:	74aa                	ld	s1,168(sp)
    80005134:	b75d                	j	800050da <sys_open+0xca>
      fileclose(f);
    80005136:	854a                	mv	a0,s2
    80005138:	f87fe0ef          	jal	800040be <fileclose>
    8000513c:	69ea                	ld	s3,152(sp)
    iunlockput(ip);
    8000513e:	8526                	mv	a0,s1
    80005140:	b5afe0ef          	jal	8000349a <iunlockput>
    end_op();
    80005144:	bc7fe0ef          	jal	80003d0a <end_op>
    return -1;
    80005148:	557d                	li	a0,-1
    8000514a:	74aa                	ld	s1,168(sp)
    8000514c:	790a                	ld	s2,160(sp)
    8000514e:	b771                	j	800050da <sys_open+0xca>
    f->type = FD_DEVICE;
    80005150:	00e92023          	sw	a4,0(s2)
    f->major = ip->major;
    80005154:	04649783          	lh	a5,70(s1)
    80005158:	02f91223          	sh	a5,36(s2)
    8000515c:	bf35                	j	80005098 <sys_open+0x88>
    itrunc(ip);
    8000515e:	8526                	mv	a0,s1
    80005160:	a1cfe0ef          	jal	8000337c <itrunc>
    80005164:	b795                	j	800050c8 <sys_open+0xb8>

0000000080005166 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80005166:	7175                	addi	sp,sp,-144
    80005168:	e506                	sd	ra,136(sp)
    8000516a:	e122                	sd	s0,128(sp)
    8000516c:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    8000516e:	b2dfe0ef          	jal	80003c9a <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80005172:	08000613          	li	a2,128
    80005176:	f7040593          	addi	a1,s0,-144
    8000517a:	4501                	li	a0,0
    8000517c:	f42fd0ef          	jal	800028be <argstr>
    80005180:	02054363          	bltz	a0,800051a6 <sys_mkdir+0x40>
    80005184:	4681                	li	a3,0
    80005186:	4601                	li	a2,0
    80005188:	4585                	li	a1,1
    8000518a:	f7040513          	addi	a0,s0,-144
    8000518e:	973ff0ef          	jal	80004b00 <create>
    80005192:	c911                	beqz	a0,800051a6 <sys_mkdir+0x40>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005194:	b06fe0ef          	jal	8000349a <iunlockput>
  end_op();
    80005198:	b73fe0ef          	jal	80003d0a <end_op>
  return 0;
    8000519c:	4501                	li	a0,0
}
    8000519e:	60aa                	ld	ra,136(sp)
    800051a0:	640a                	ld	s0,128(sp)
    800051a2:	6149                	addi	sp,sp,144
    800051a4:	8082                	ret
    end_op();
    800051a6:	b65fe0ef          	jal	80003d0a <end_op>
    return -1;
    800051aa:	557d                	li	a0,-1
    800051ac:	bfcd                	j	8000519e <sys_mkdir+0x38>

00000000800051ae <sys_mknod>:

uint64
sys_mknod(void)
{
    800051ae:	7135                	addi	sp,sp,-160
    800051b0:	ed06                	sd	ra,152(sp)
    800051b2:	e922                	sd	s0,144(sp)
    800051b4:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    800051b6:	ae5fe0ef          	jal	80003c9a <begin_op>
  argint(1, &major);
    800051ba:	f6c40593          	addi	a1,s0,-148
    800051be:	4505                	li	a0,1
    800051c0:	ec6fd0ef          	jal	80002886 <argint>
  argint(2, &minor);
    800051c4:	f6840593          	addi	a1,s0,-152
    800051c8:	4509                	li	a0,2
    800051ca:	ebcfd0ef          	jal	80002886 <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    800051ce:	08000613          	li	a2,128
    800051d2:	f7040593          	addi	a1,s0,-144
    800051d6:	4501                	li	a0,0
    800051d8:	ee6fd0ef          	jal	800028be <argstr>
    800051dc:	02054563          	bltz	a0,80005206 <sys_mknod+0x58>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    800051e0:	f6841683          	lh	a3,-152(s0)
    800051e4:	f6c41603          	lh	a2,-148(s0)
    800051e8:	458d                	li	a1,3
    800051ea:	f7040513          	addi	a0,s0,-144
    800051ee:	913ff0ef          	jal	80004b00 <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    800051f2:	c911                	beqz	a0,80005206 <sys_mknod+0x58>
    end_op();
    return -1;
  }
  iunlockput(ip);
    800051f4:	aa6fe0ef          	jal	8000349a <iunlockput>
  end_op();
    800051f8:	b13fe0ef          	jal	80003d0a <end_op>
  return 0;
    800051fc:	4501                	li	a0,0
}
    800051fe:	60ea                	ld	ra,152(sp)
    80005200:	644a                	ld	s0,144(sp)
    80005202:	610d                	addi	sp,sp,160
    80005204:	8082                	ret
    end_op();
    80005206:	b05fe0ef          	jal	80003d0a <end_op>
    return -1;
    8000520a:	557d                	li	a0,-1
    8000520c:	bfcd                	j	800051fe <sys_mknod+0x50>

000000008000520e <sys_chdir>:

uint64
sys_chdir(void)
{
    8000520e:	7135                	addi	sp,sp,-160
    80005210:	ed06                	sd	ra,152(sp)
    80005212:	e922                	sd	s0,144(sp)
    80005214:	e14a                	sd	s2,128(sp)
    80005216:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80005218:	f4cfc0ef          	jal	80001964 <myproc>
    8000521c:	892a                	mv	s2,a0
  
  begin_op();
    8000521e:	a7dfe0ef          	jal	80003c9a <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80005222:	08000613          	li	a2,128
    80005226:	f6040593          	addi	a1,s0,-160
    8000522a:	4501                	li	a0,0
    8000522c:	e92fd0ef          	jal	800028be <argstr>
    80005230:	04054363          	bltz	a0,80005276 <sys_chdir+0x68>
    80005234:	e526                	sd	s1,136(sp)
    80005236:	f6040513          	addi	a0,s0,-160
    8000523a:	883fe0ef          	jal	80003abc <namei>
    8000523e:	84aa                	mv	s1,a0
    80005240:	c915                	beqz	a0,80005274 <sys_chdir+0x66>
    end_op();
    return -1;
  }
  ilock(ip);
    80005242:	84cfe0ef          	jal	8000328e <ilock>
  if(ip->type != T_DIR){
    80005246:	04449703          	lh	a4,68(s1)
    8000524a:	4785                	li	a5,1
    8000524c:	02f71963          	bne	a4,a5,8000527e <sys_chdir+0x70>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80005250:	8526                	mv	a0,s1
    80005252:	8eafe0ef          	jal	8000333c <iunlock>
  iput(p->cwd);
    80005256:	15093503          	ld	a0,336(s2)
    8000525a:	9b6fe0ef          	jal	80003410 <iput>
  end_op();
    8000525e:	aadfe0ef          	jal	80003d0a <end_op>
  p->cwd = ip;
    80005262:	14993823          	sd	s1,336(s2)
  return 0;
    80005266:	4501                	li	a0,0
    80005268:	64aa                	ld	s1,136(sp)
}
    8000526a:	60ea                	ld	ra,152(sp)
    8000526c:	644a                	ld	s0,144(sp)
    8000526e:	690a                	ld	s2,128(sp)
    80005270:	610d                	addi	sp,sp,160
    80005272:	8082                	ret
    80005274:	64aa                	ld	s1,136(sp)
    end_op();
    80005276:	a95fe0ef          	jal	80003d0a <end_op>
    return -1;
    8000527a:	557d                	li	a0,-1
    8000527c:	b7fd                	j	8000526a <sys_chdir+0x5c>
    iunlockput(ip);
    8000527e:	8526                	mv	a0,s1
    80005280:	a1afe0ef          	jal	8000349a <iunlockput>
    end_op();
    80005284:	a87fe0ef          	jal	80003d0a <end_op>
    return -1;
    80005288:	557d                	li	a0,-1
    8000528a:	64aa                	ld	s1,136(sp)
    8000528c:	bff9                	j	8000526a <sys_chdir+0x5c>

000000008000528e <sys_exec>:

uint64
sys_exec(void)
{
    8000528e:	7105                	addi	sp,sp,-480
    80005290:	ef86                	sd	ra,472(sp)
    80005292:	eba2                	sd	s0,464(sp)
    80005294:	1380                	addi	s0,sp,480
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    80005296:	e2840593          	addi	a1,s0,-472
    8000529a:	4505                	li	a0,1
    8000529c:	e06fd0ef          	jal	800028a2 <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    800052a0:	08000613          	li	a2,128
    800052a4:	f3040593          	addi	a1,s0,-208
    800052a8:	4501                	li	a0,0
    800052aa:	e14fd0ef          	jal	800028be <argstr>
    800052ae:	87aa                	mv	a5,a0
    return -1;
    800052b0:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    800052b2:	0e07c063          	bltz	a5,80005392 <sys_exec+0x104>
    800052b6:	e7a6                	sd	s1,456(sp)
    800052b8:	e3ca                	sd	s2,448(sp)
    800052ba:	ff4e                	sd	s3,440(sp)
    800052bc:	fb52                	sd	s4,432(sp)
    800052be:	f756                	sd	s5,424(sp)
    800052c0:	f35a                	sd	s6,416(sp)
    800052c2:	ef5e                	sd	s7,408(sp)
  }
  memset(argv, 0, sizeof(argv));
    800052c4:	e3040a13          	addi	s4,s0,-464
    800052c8:	10000613          	li	a2,256
    800052cc:	4581                	li	a1,0
    800052ce:	8552                	mv	a0,s4
    800052d0:	a5bfb0ef          	jal	80000d2a <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    800052d4:	84d2                	mv	s1,s4
  memset(argv, 0, sizeof(argv));
    800052d6:	89d2                	mv	s3,s4
    800052d8:	4901                	li	s2,0
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    800052da:	e2040a93          	addi	s5,s0,-480
      break;
    }
    argv[i] = kalloc();
    if(argv[i] == 0)
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    800052de:	6b05                	lui	s6,0x1
    if(i >= NELEM(argv)){
    800052e0:	02000b93          	li	s7,32
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    800052e4:	00391513          	slli	a0,s2,0x3
    800052e8:	85d6                	mv	a1,s5
    800052ea:	e2843783          	ld	a5,-472(s0)
    800052ee:	953e                	add	a0,a0,a5
    800052f0:	d0cfd0ef          	jal	800027fc <fetchaddr>
    800052f4:	02054663          	bltz	a0,80005320 <sys_exec+0x92>
    if(uarg == 0){
    800052f8:	e2043783          	ld	a5,-480(s0)
    800052fc:	c7a1                	beqz	a5,80005344 <sys_exec+0xb6>
    argv[i] = kalloc();
    800052fe:	879fb0ef          	jal	80000b76 <kalloc>
    80005302:	85aa                	mv	a1,a0
    80005304:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80005308:	cd01                	beqz	a0,80005320 <sys_exec+0x92>
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    8000530a:	865a                	mv	a2,s6
    8000530c:	e2043503          	ld	a0,-480(s0)
    80005310:	d36fd0ef          	jal	80002846 <fetchstr>
    80005314:	00054663          	bltz	a0,80005320 <sys_exec+0x92>
    if(i >= NELEM(argv)){
    80005318:	0905                	addi	s2,s2,1
    8000531a:	09a1                	addi	s3,s3,8
    8000531c:	fd7914e3          	bne	s2,s7,800052e4 <sys_exec+0x56>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005320:	100a0a13          	addi	s4,s4,256
    80005324:	6088                	ld	a0,0(s1)
    80005326:	cd31                	beqz	a0,80005382 <sys_exec+0xf4>
    kfree(argv[i]);
    80005328:	f66fb0ef          	jal	80000a8e <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    8000532c:	04a1                	addi	s1,s1,8
    8000532e:	ff449be3          	bne	s1,s4,80005324 <sys_exec+0x96>
  return -1;
    80005332:	557d                	li	a0,-1
    80005334:	64be                	ld	s1,456(sp)
    80005336:	691e                	ld	s2,448(sp)
    80005338:	79fa                	ld	s3,440(sp)
    8000533a:	7a5a                	ld	s4,432(sp)
    8000533c:	7aba                	ld	s5,424(sp)
    8000533e:	7b1a                	ld	s6,416(sp)
    80005340:	6bfa                	ld	s7,408(sp)
    80005342:	a881                	j	80005392 <sys_exec+0x104>
      argv[i] = 0;
    80005344:	0009079b          	sext.w	a5,s2
    80005348:	e3040593          	addi	a1,s0,-464
    8000534c:	078e                	slli	a5,a5,0x3
    8000534e:	97ae                	add	a5,a5,a1
    80005350:	0007b023          	sd	zero,0(a5)
  int ret = kexec(path, argv);
    80005354:	f3040513          	addi	a0,s0,-208
    80005358:	bb2ff0ef          	jal	8000470a <kexec>
    8000535c:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    8000535e:	100a0a13          	addi	s4,s4,256
    80005362:	6088                	ld	a0,0(s1)
    80005364:	c511                	beqz	a0,80005370 <sys_exec+0xe2>
    kfree(argv[i]);
    80005366:	f28fb0ef          	jal	80000a8e <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    8000536a:	04a1                	addi	s1,s1,8
    8000536c:	ff449be3          	bne	s1,s4,80005362 <sys_exec+0xd4>
  return ret;
    80005370:	854a                	mv	a0,s2
    80005372:	64be                	ld	s1,456(sp)
    80005374:	691e                	ld	s2,448(sp)
    80005376:	79fa                	ld	s3,440(sp)
    80005378:	7a5a                	ld	s4,432(sp)
    8000537a:	7aba                	ld	s5,424(sp)
    8000537c:	7b1a                	ld	s6,416(sp)
    8000537e:	6bfa                	ld	s7,408(sp)
    80005380:	a809                	j	80005392 <sys_exec+0x104>
  return -1;
    80005382:	557d                	li	a0,-1
    80005384:	64be                	ld	s1,456(sp)
    80005386:	691e                	ld	s2,448(sp)
    80005388:	79fa                	ld	s3,440(sp)
    8000538a:	7a5a                	ld	s4,432(sp)
    8000538c:	7aba                	ld	s5,424(sp)
    8000538e:	7b1a                	ld	s6,416(sp)
    80005390:	6bfa                	ld	s7,408(sp)
}
    80005392:	60fe                	ld	ra,472(sp)
    80005394:	645e                	ld	s0,464(sp)
    80005396:	613d                	addi	sp,sp,480
    80005398:	8082                	ret

000000008000539a <sys_pipe>:

uint64
sys_pipe(void)
{
    8000539a:	7139                	addi	sp,sp,-64
    8000539c:	fc06                	sd	ra,56(sp)
    8000539e:	f822                	sd	s0,48(sp)
    800053a0:	f426                	sd	s1,40(sp)
    800053a2:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    800053a4:	dc0fc0ef          	jal	80001964 <myproc>
    800053a8:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    800053aa:	fd840593          	addi	a1,s0,-40
    800053ae:	4501                	li	a0,0
    800053b0:	cf2fd0ef          	jal	800028a2 <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    800053b4:	fc840593          	addi	a1,s0,-56
    800053b8:	fd040513          	addi	a0,s0,-48
    800053bc:	81eff0ef          	jal	800043da <pipealloc>
    return -1;
    800053c0:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    800053c2:	0a054763          	bltz	a0,80005470 <sys_pipe+0xd6>
  fd0 = -1;
    800053c6:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    800053ca:	fd043503          	ld	a0,-48(s0)
    800053ce:	ef2ff0ef          	jal	80004ac0 <fdalloc>
    800053d2:	fca42223          	sw	a0,-60(s0)
    800053d6:	08054463          	bltz	a0,8000545e <sys_pipe+0xc4>
    800053da:	fc843503          	ld	a0,-56(s0)
    800053de:	ee2ff0ef          	jal	80004ac0 <fdalloc>
    800053e2:	fca42023          	sw	a0,-64(s0)
    800053e6:	06054263          	bltz	a0,8000544a <sys_pipe+0xb0>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    800053ea:	4691                	li	a3,4
    800053ec:	fc440613          	addi	a2,s0,-60
    800053f0:	fd843583          	ld	a1,-40(s0)
    800053f4:	68a8                	ld	a0,80(s1)
    800053f6:	a94fc0ef          	jal	8000168a <copyout>
    800053fa:	00054e63          	bltz	a0,80005416 <sys_pipe+0x7c>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    800053fe:	4691                	li	a3,4
    80005400:	fc040613          	addi	a2,s0,-64
    80005404:	fd843583          	ld	a1,-40(s0)
    80005408:	95b6                	add	a1,a1,a3
    8000540a:	68a8                	ld	a0,80(s1)
    8000540c:	a7efc0ef          	jal	8000168a <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80005410:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005412:	04055f63          	bgez	a0,80005470 <sys_pipe+0xd6>
    p->ofile[fd0] = 0;
    80005416:	fc442783          	lw	a5,-60(s0)
    8000541a:	078e                	slli	a5,a5,0x3
    8000541c:	0d078793          	addi	a5,a5,208
    80005420:	97a6                	add	a5,a5,s1
    80005422:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    80005426:	fc042783          	lw	a5,-64(s0)
    8000542a:	078e                	slli	a5,a5,0x3
    8000542c:	0d078793          	addi	a5,a5,208
    80005430:	97a6                	add	a5,a5,s1
    80005432:	0007b023          	sd	zero,0(a5)
    fileclose(rf);
    80005436:	fd043503          	ld	a0,-48(s0)
    8000543a:	c85fe0ef          	jal	800040be <fileclose>
    fileclose(wf);
    8000543e:	fc843503          	ld	a0,-56(s0)
    80005442:	c7dfe0ef          	jal	800040be <fileclose>
    return -1;
    80005446:	57fd                	li	a5,-1
    80005448:	a025                	j	80005470 <sys_pipe+0xd6>
    if(fd0 >= 0)
    8000544a:	fc442783          	lw	a5,-60(s0)
    8000544e:	0007c863          	bltz	a5,8000545e <sys_pipe+0xc4>
      p->ofile[fd0] = 0;
    80005452:	078e                	slli	a5,a5,0x3
    80005454:	0d078793          	addi	a5,a5,208
    80005458:	97a6                	add	a5,a5,s1
    8000545a:	0007b023          	sd	zero,0(a5)
    fileclose(rf);
    8000545e:	fd043503          	ld	a0,-48(s0)
    80005462:	c5dfe0ef          	jal	800040be <fileclose>
    fileclose(wf);
    80005466:	fc843503          	ld	a0,-56(s0)
    8000546a:	c55fe0ef          	jal	800040be <fileclose>
    return -1;
    8000546e:	57fd                	li	a5,-1
}
    80005470:	853e                	mv	a0,a5
    80005472:	70e2                	ld	ra,56(sp)
    80005474:	7442                	ld	s0,48(sp)
    80005476:	74a2                	ld	s1,40(sp)
    80005478:	6121                	addi	sp,sp,64
    8000547a:	8082                	ret

000000008000547c <sys_fsread>:
uint64
sys_fsread(void)
{
    8000547c:	1101                	addi	sp,sp,-32
    8000547e:	ec06                	sd	ra,24(sp)
    80005480:	e822                	sd	s0,16(sp)
    80005482:	1000                	addi	s0,sp,32
  uint64 addr;
  int n;

  // استدعاء الدوال بدون مقارنتها بـ < 0 لأنها تعيد void
  argaddr(0, &addr); 
    80005484:	fe840593          	addi	a1,s0,-24
    80005488:	4501                	li	a0,0
    8000548a:	c18fd0ef          	jal	800028a2 <argaddr>
  argint(1, &n);
    8000548e:	fe440593          	addi	a1,s0,-28
    80005492:	4505                	li	a0,1
    80005494:	bf2fd0ef          	jal	80002886 <argint>

  // استدعاء الوظيفة الحقيقية وإعادة نتيجتها
  return fslog_read_many((struct fs_event *)addr, n);
    80005498:	fe442583          	lw	a1,-28(s0)
    8000549c:	fe843503          	ld	a0,-24(s0)
    800054a0:	1fd000ef          	jal	80005e9c <fslog_read_many>
    800054a4:	60e2                	ld	ra,24(sp)
    800054a6:	6442                	ld	s0,16(sp)
    800054a8:	6105                	addi	sp,sp,32
    800054aa:	8082                	ret
    800054ac:	0000                	unimp
	...

00000000800054b0 <kernelvec>:
.globl kerneltrap
.globl kernelvec
.align 4
kernelvec:
        # make room to save registers.
        addi sp, sp, -256
    800054b0:	7111                	addi	sp,sp,-256

        # save caller-saved registers.
        sd ra, 0(sp)
    800054b2:	e006                	sd	ra,0(sp)
        # sd sp, 8(sp)
        sd gp, 16(sp)
    800054b4:	e80e                	sd	gp,16(sp)
        sd tp, 24(sp)
    800054b6:	ec12                	sd	tp,24(sp)
        sd t0, 32(sp)
    800054b8:	f016                	sd	t0,32(sp)
        sd t1, 40(sp)
    800054ba:	f41a                	sd	t1,40(sp)
        sd t2, 48(sp)
    800054bc:	f81e                	sd	t2,48(sp)
        sd a0, 72(sp)
    800054be:	e4aa                	sd	a0,72(sp)
        sd a1, 80(sp)
    800054c0:	e8ae                	sd	a1,80(sp)
        sd a2, 88(sp)
    800054c2:	ecb2                	sd	a2,88(sp)
        sd a3, 96(sp)
    800054c4:	f0b6                	sd	a3,96(sp)
        sd a4, 104(sp)
    800054c6:	f4ba                	sd	a4,104(sp)
        sd a5, 112(sp)
    800054c8:	f8be                	sd	a5,112(sp)
        sd a6, 120(sp)
    800054ca:	fcc2                	sd	a6,120(sp)
        sd a7, 128(sp)
    800054cc:	e146                	sd	a7,128(sp)
        sd t3, 216(sp)
    800054ce:	edf2                	sd	t3,216(sp)
        sd t4, 224(sp)
    800054d0:	f1f6                	sd	t4,224(sp)
        sd t5, 232(sp)
    800054d2:	f5fa                	sd	t5,232(sp)
        sd t6, 240(sp)
    800054d4:	f9fe                	sd	t6,240(sp)

        # call the C trap handler in trap.c
        call kerneltrap
    800054d6:	a34fd0ef          	jal	8000270a <kerneltrap>

        # restore registers.
        ld ra, 0(sp)
    800054da:	6082                	ld	ra,0(sp)
        # ld sp, 8(sp)
        ld gp, 16(sp)
    800054dc:	61c2                	ld	gp,16(sp)
        # not tp (contains hartid), in case we moved CPUs
        ld t0, 32(sp)
    800054de:	7282                	ld	t0,32(sp)
        ld t1, 40(sp)
    800054e0:	7322                	ld	t1,40(sp)
        ld t2, 48(sp)
    800054e2:	73c2                	ld	t2,48(sp)
        ld a0, 72(sp)
    800054e4:	6526                	ld	a0,72(sp)
        ld a1, 80(sp)
    800054e6:	65c6                	ld	a1,80(sp)
        ld a2, 88(sp)
    800054e8:	6666                	ld	a2,88(sp)
        ld a3, 96(sp)
    800054ea:	7686                	ld	a3,96(sp)
        ld a4, 104(sp)
    800054ec:	7726                	ld	a4,104(sp)
        ld a5, 112(sp)
    800054ee:	77c6                	ld	a5,112(sp)
        ld a6, 120(sp)
    800054f0:	7866                	ld	a6,120(sp)
        ld a7, 128(sp)
    800054f2:	688a                	ld	a7,128(sp)
        ld t3, 216(sp)
    800054f4:	6e6e                	ld	t3,216(sp)
        ld t4, 224(sp)
    800054f6:	7e8e                	ld	t4,224(sp)
        ld t5, 232(sp)
    800054f8:	7f2e                	ld	t5,232(sp)
        ld t6, 240(sp)
    800054fa:	7fce                	ld	t6,240(sp)

        addi sp, sp, 256
    800054fc:	6111                	addi	sp,sp,256

        # return to whatever we were doing in the kernel.
        sret
    800054fe:	10200073          	sret
    80005502:	00000013          	nop
    80005506:	00000013          	nop
    8000550a:	00000013          	nop

000000008000550e <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    8000550e:	1141                	addi	sp,sp,-16
    80005510:	e406                	sd	ra,8(sp)
    80005512:	e022                	sd	s0,0(sp)
    80005514:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80005516:	0c000737          	lui	a4,0xc000
    8000551a:	4785                	li	a5,1
    8000551c:	d71c                	sw	a5,40(a4)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    8000551e:	c35c                	sw	a5,4(a4)
}
    80005520:	60a2                	ld	ra,8(sp)
    80005522:	6402                	ld	s0,0(sp)
    80005524:	0141                	addi	sp,sp,16
    80005526:	8082                	ret

0000000080005528 <plicinithart>:

void
plicinithart(void)
{
    80005528:	1141                	addi	sp,sp,-16
    8000552a:	e406                	sd	ra,8(sp)
    8000552c:	e022                	sd	s0,0(sp)
    8000552e:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005530:	c00fc0ef          	jal	80001930 <cpuid>
  
  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80005534:	0085171b          	slliw	a4,a0,0x8
    80005538:	0c0027b7          	lui	a5,0xc002
    8000553c:	97ba                	add	a5,a5,a4
    8000553e:	40200713          	li	a4,1026
    80005542:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80005546:	00d5151b          	slliw	a0,a0,0xd
    8000554a:	0c2017b7          	lui	a5,0xc201
    8000554e:	97aa                	add	a5,a5,a0
    80005550:	0007a023          	sw	zero,0(a5) # c201000 <_entry-0x73dff000>
}
    80005554:	60a2                	ld	ra,8(sp)
    80005556:	6402                	ld	s0,0(sp)
    80005558:	0141                	addi	sp,sp,16
    8000555a:	8082                	ret

000000008000555c <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    8000555c:	1141                	addi	sp,sp,-16
    8000555e:	e406                	sd	ra,8(sp)
    80005560:	e022                	sd	s0,0(sp)
    80005562:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005564:	bccfc0ef          	jal	80001930 <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80005568:	00d5151b          	slliw	a0,a0,0xd
    8000556c:	0c2017b7          	lui	a5,0xc201
    80005570:	97aa                	add	a5,a5,a0
  return irq;
}
    80005572:	43c8                	lw	a0,4(a5)
    80005574:	60a2                	ld	ra,8(sp)
    80005576:	6402                	ld	s0,0(sp)
    80005578:	0141                	addi	sp,sp,16
    8000557a:	8082                	ret

000000008000557c <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    8000557c:	1101                	addi	sp,sp,-32
    8000557e:	ec06                	sd	ra,24(sp)
    80005580:	e822                	sd	s0,16(sp)
    80005582:	e426                	sd	s1,8(sp)
    80005584:	1000                	addi	s0,sp,32
    80005586:	84aa                	mv	s1,a0
  int hart = cpuid();
    80005588:	ba8fc0ef          	jal	80001930 <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    8000558c:	00d5179b          	slliw	a5,a0,0xd
    80005590:	0c201737          	lui	a4,0xc201
    80005594:	97ba                	add	a5,a5,a4
    80005596:	c3c4                	sw	s1,4(a5)
}
    80005598:	60e2                	ld	ra,24(sp)
    8000559a:	6442                	ld	s0,16(sp)
    8000559c:	64a2                	ld	s1,8(sp)
    8000559e:	6105                	addi	sp,sp,32
    800055a0:	8082                	ret

00000000800055a2 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    800055a2:	1141                	addi	sp,sp,-16
    800055a4:	e406                	sd	ra,8(sp)
    800055a6:	e022                	sd	s0,0(sp)
    800055a8:	0800                	addi	s0,sp,16
  if(i >= NUM)
    800055aa:	479d                	li	a5,7
    800055ac:	04a7ca63          	blt	a5,a0,80005600 <free_desc+0x5e>
    panic("free_desc 1");
  if(disk.free[i])
    800055b0:	0001e797          	auipc	a5,0x1e
    800055b4:	1c878793          	addi	a5,a5,456 # 80023778 <disk>
    800055b8:	97aa                	add	a5,a5,a0
    800055ba:	0187c783          	lbu	a5,24(a5)
    800055be:	e7b9                	bnez	a5,8000560c <free_desc+0x6a>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    800055c0:	00451693          	slli	a3,a0,0x4
    800055c4:	0001e797          	auipc	a5,0x1e
    800055c8:	1b478793          	addi	a5,a5,436 # 80023778 <disk>
    800055cc:	6398                	ld	a4,0(a5)
    800055ce:	9736                	add	a4,a4,a3
    800055d0:	00073023          	sd	zero,0(a4) # c201000 <_entry-0x73dff000>
  disk.desc[i].len = 0;
    800055d4:	6398                	ld	a4,0(a5)
    800055d6:	9736                	add	a4,a4,a3
    800055d8:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    800055dc:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    800055e0:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    800055e4:	97aa                	add	a5,a5,a0
    800055e6:	4705                	li	a4,1
    800055e8:	00e78c23          	sb	a4,24(a5)
  wakeup(&disk.free[0]);
    800055ec:	0001e517          	auipc	a0,0x1e
    800055f0:	1a450513          	addi	a0,a0,420 # 80023790 <disk+0x18>
    800055f4:	9d3fc0ef          	jal	80001fc6 <wakeup>
}
    800055f8:	60a2                	ld	ra,8(sp)
    800055fa:	6402                	ld	s0,0(sp)
    800055fc:	0141                	addi	sp,sp,16
    800055fe:	8082                	ret
    panic("free_desc 1");
    80005600:	00002517          	auipc	a0,0x2
    80005604:	02050513          	addi	a0,a0,32 # 80007620 <etext+0x620>
    80005608:	a4efb0ef          	jal	80000856 <panic>
    panic("free_desc 2");
    8000560c:	00002517          	auipc	a0,0x2
    80005610:	02450513          	addi	a0,a0,36 # 80007630 <etext+0x630>
    80005614:	a42fb0ef          	jal	80000856 <panic>

0000000080005618 <virtio_disk_init>:
{
    80005618:	1101                	addi	sp,sp,-32
    8000561a:	ec06                	sd	ra,24(sp)
    8000561c:	e822                	sd	s0,16(sp)
    8000561e:	e426                	sd	s1,8(sp)
    80005620:	e04a                	sd	s2,0(sp)
    80005622:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80005624:	00002597          	auipc	a1,0x2
    80005628:	01c58593          	addi	a1,a1,28 # 80007640 <etext+0x640>
    8000562c:	0001e517          	auipc	a0,0x1e
    80005630:	27450513          	addi	a0,a0,628 # 800238a0 <disk+0x128>
    80005634:	d9cfb0ef          	jal	80000bd0 <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005638:	100017b7          	lui	a5,0x10001
    8000563c:	4398                	lw	a4,0(a5)
    8000563e:	2701                	sext.w	a4,a4
    80005640:	747277b7          	lui	a5,0x74727
    80005644:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    80005648:	14f71863          	bne	a4,a5,80005798 <virtio_disk_init+0x180>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    8000564c:	100017b7          	lui	a5,0x10001
    80005650:	43dc                	lw	a5,4(a5)
    80005652:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005654:	4709                	li	a4,2
    80005656:	14e79163          	bne	a5,a4,80005798 <virtio_disk_init+0x180>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    8000565a:	100017b7          	lui	a5,0x10001
    8000565e:	479c                	lw	a5,8(a5)
    80005660:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80005662:	12e79b63          	bne	a5,a4,80005798 <virtio_disk_init+0x180>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    80005666:	100017b7          	lui	a5,0x10001
    8000566a:	47d8                	lw	a4,12(a5)
    8000566c:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    8000566e:	554d47b7          	lui	a5,0x554d4
    80005672:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    80005676:	12f71163          	bne	a4,a5,80005798 <virtio_disk_init+0x180>
  *R(VIRTIO_MMIO_STATUS) = status;
    8000567a:	100017b7          	lui	a5,0x10001
    8000567e:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    80005682:	4705                	li	a4,1
    80005684:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005686:	470d                	li	a4,3
    80005688:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    8000568a:	10001737          	lui	a4,0x10001
    8000568e:	4b18                	lw	a4,16(a4)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    80005690:	c7ffe6b7          	lui	a3,0xc7ffe
    80005694:	75f68693          	addi	a3,a3,1887 # ffffffffc7ffe75f <end+0xffffffff47fcae47>
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80005698:	8f75                	and	a4,a4,a3
    8000569a:	100016b7          	lui	a3,0x10001
    8000569e:	d298                	sw	a4,32(a3)
  *R(VIRTIO_MMIO_STATUS) = status;
    800056a0:	472d                	li	a4,11
    800056a2:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    800056a4:	07078793          	addi	a5,a5,112
  status = *R(VIRTIO_MMIO_STATUS);
    800056a8:	439c                	lw	a5,0(a5)
    800056aa:	0007891b          	sext.w	s2,a5
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    800056ae:	8ba1                	andi	a5,a5,8
    800056b0:	0e078a63          	beqz	a5,800057a4 <virtio_disk_init+0x18c>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    800056b4:	100017b7          	lui	a5,0x10001
    800056b8:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    800056bc:	43fc                	lw	a5,68(a5)
    800056be:	2781                	sext.w	a5,a5
    800056c0:	0e079863          	bnez	a5,800057b0 <virtio_disk_init+0x198>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    800056c4:	100017b7          	lui	a5,0x10001
    800056c8:	5bdc                	lw	a5,52(a5)
    800056ca:	2781                	sext.w	a5,a5
  if(max == 0)
    800056cc:	0e078863          	beqz	a5,800057bc <virtio_disk_init+0x1a4>
  if(max < NUM)
    800056d0:	471d                	li	a4,7
    800056d2:	0ef77b63          	bgeu	a4,a5,800057c8 <virtio_disk_init+0x1b0>
  disk.desc = kalloc();
    800056d6:	ca0fb0ef          	jal	80000b76 <kalloc>
    800056da:	0001e497          	auipc	s1,0x1e
    800056de:	09e48493          	addi	s1,s1,158 # 80023778 <disk>
    800056e2:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    800056e4:	c92fb0ef          	jal	80000b76 <kalloc>
    800056e8:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    800056ea:	c8cfb0ef          	jal	80000b76 <kalloc>
    800056ee:	87aa                	mv	a5,a0
    800056f0:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    800056f2:	6088                	ld	a0,0(s1)
    800056f4:	0e050063          	beqz	a0,800057d4 <virtio_disk_init+0x1bc>
    800056f8:	0001e717          	auipc	a4,0x1e
    800056fc:	08873703          	ld	a4,136(a4) # 80023780 <disk+0x8>
    80005700:	cb71                	beqz	a4,800057d4 <virtio_disk_init+0x1bc>
    80005702:	cbe9                	beqz	a5,800057d4 <virtio_disk_init+0x1bc>
  memset(disk.desc, 0, PGSIZE);
    80005704:	6605                	lui	a2,0x1
    80005706:	4581                	li	a1,0
    80005708:	e22fb0ef          	jal	80000d2a <memset>
  memset(disk.avail, 0, PGSIZE);
    8000570c:	0001e497          	auipc	s1,0x1e
    80005710:	06c48493          	addi	s1,s1,108 # 80023778 <disk>
    80005714:	6605                	lui	a2,0x1
    80005716:	4581                	li	a1,0
    80005718:	6488                	ld	a0,8(s1)
    8000571a:	e10fb0ef          	jal	80000d2a <memset>
  memset(disk.used, 0, PGSIZE);
    8000571e:	6605                	lui	a2,0x1
    80005720:	4581                	li	a1,0
    80005722:	6888                	ld	a0,16(s1)
    80005724:	e06fb0ef          	jal	80000d2a <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    80005728:	100017b7          	lui	a5,0x10001
    8000572c:	4721                	li	a4,8
    8000572e:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    80005730:	4098                	lw	a4,0(s1)
    80005732:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    80005736:	40d8                	lw	a4,4(s1)
    80005738:	08e7a223          	sw	a4,132(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    8000573c:	649c                	ld	a5,8(s1)
    8000573e:	0007869b          	sext.w	a3,a5
    80005742:	10001737          	lui	a4,0x10001
    80005746:	08d72823          	sw	a3,144(a4) # 10001090 <_entry-0x6fffef70>
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    8000574a:	9781                	srai	a5,a5,0x20
    8000574c:	08f72a23          	sw	a5,148(a4)
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    80005750:	689c                	ld	a5,16(s1)
    80005752:	0007869b          	sext.w	a3,a5
    80005756:	0ad72023          	sw	a3,160(a4)
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    8000575a:	9781                	srai	a5,a5,0x20
    8000575c:	0af72223          	sw	a5,164(a4)
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    80005760:	4785                	li	a5,1
    80005762:	c37c                	sw	a5,68(a4)
    disk.free[i] = 1;
    80005764:	00f48c23          	sb	a5,24(s1)
    80005768:	00f48ca3          	sb	a5,25(s1)
    8000576c:	00f48d23          	sb	a5,26(s1)
    80005770:	00f48da3          	sb	a5,27(s1)
    80005774:	00f48e23          	sb	a5,28(s1)
    80005778:	00f48ea3          	sb	a5,29(s1)
    8000577c:	00f48f23          	sb	a5,30(s1)
    80005780:	00f48fa3          	sb	a5,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    80005784:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    80005788:	07272823          	sw	s2,112(a4)
}
    8000578c:	60e2                	ld	ra,24(sp)
    8000578e:	6442                	ld	s0,16(sp)
    80005790:	64a2                	ld	s1,8(sp)
    80005792:	6902                	ld	s2,0(sp)
    80005794:	6105                	addi	sp,sp,32
    80005796:	8082                	ret
    panic("could not find virtio disk");
    80005798:	00002517          	auipc	a0,0x2
    8000579c:	eb850513          	addi	a0,a0,-328 # 80007650 <etext+0x650>
    800057a0:	8b6fb0ef          	jal	80000856 <panic>
    panic("virtio disk FEATURES_OK unset");
    800057a4:	00002517          	auipc	a0,0x2
    800057a8:	ecc50513          	addi	a0,a0,-308 # 80007670 <etext+0x670>
    800057ac:	8aafb0ef          	jal	80000856 <panic>
    panic("virtio disk should not be ready");
    800057b0:	00002517          	auipc	a0,0x2
    800057b4:	ee050513          	addi	a0,a0,-288 # 80007690 <etext+0x690>
    800057b8:	89efb0ef          	jal	80000856 <panic>
    panic("virtio disk has no queue 0");
    800057bc:	00002517          	auipc	a0,0x2
    800057c0:	ef450513          	addi	a0,a0,-268 # 800076b0 <etext+0x6b0>
    800057c4:	892fb0ef          	jal	80000856 <panic>
    panic("virtio disk max queue too short");
    800057c8:	00002517          	auipc	a0,0x2
    800057cc:	f0850513          	addi	a0,a0,-248 # 800076d0 <etext+0x6d0>
    800057d0:	886fb0ef          	jal	80000856 <panic>
    panic("virtio disk kalloc");
    800057d4:	00002517          	auipc	a0,0x2
    800057d8:	f1c50513          	addi	a0,a0,-228 # 800076f0 <etext+0x6f0>
    800057dc:	87afb0ef          	jal	80000856 <panic>

00000000800057e0 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    800057e0:	711d                	addi	sp,sp,-96
    800057e2:	ec86                	sd	ra,88(sp)
    800057e4:	e8a2                	sd	s0,80(sp)
    800057e6:	e4a6                	sd	s1,72(sp)
    800057e8:	e0ca                	sd	s2,64(sp)
    800057ea:	fc4e                	sd	s3,56(sp)
    800057ec:	f852                	sd	s4,48(sp)
    800057ee:	f456                	sd	s5,40(sp)
    800057f0:	f05a                	sd	s6,32(sp)
    800057f2:	ec5e                	sd	s7,24(sp)
    800057f4:	e862                	sd	s8,16(sp)
    800057f6:	1080                	addi	s0,sp,96
    800057f8:	89aa                	mv	s3,a0
    800057fa:	8b2e                	mv	s6,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    800057fc:	00c52b83          	lw	s7,12(a0)
    80005800:	001b9b9b          	slliw	s7,s7,0x1
    80005804:	1b82                	slli	s7,s7,0x20
    80005806:	020bdb93          	srli	s7,s7,0x20

  acquire(&disk.vdisk_lock);
    8000580a:	0001e517          	auipc	a0,0x1e
    8000580e:	09650513          	addi	a0,a0,150 # 800238a0 <disk+0x128>
    80005812:	c48fb0ef          	jal	80000c5a <acquire>
  for(int i = 0; i < NUM; i++){
    80005816:	44a1                	li	s1,8
      disk.free[i] = 0;
    80005818:	0001ea97          	auipc	s5,0x1e
    8000581c:	f60a8a93          	addi	s5,s5,-160 # 80023778 <disk>
  for(int i = 0; i < 3; i++){
    80005820:	4a0d                	li	s4,3
    idx[i] = alloc_desc();
    80005822:	5c7d                	li	s8,-1
    80005824:	a095                	j	80005888 <virtio_disk_rw+0xa8>
      disk.free[i] = 0;
    80005826:	00fa8733          	add	a4,s5,a5
    8000582a:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    8000582e:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    80005830:	0207c563          	bltz	a5,8000585a <virtio_disk_rw+0x7a>
  for(int i = 0; i < 3; i++){
    80005834:	2905                	addiw	s2,s2,1
    80005836:	0611                	addi	a2,a2,4 # 1004 <_entry-0x7fffeffc>
    80005838:	05490c63          	beq	s2,s4,80005890 <virtio_disk_rw+0xb0>
    idx[i] = alloc_desc();
    8000583c:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    8000583e:	0001e717          	auipc	a4,0x1e
    80005842:	f3a70713          	addi	a4,a4,-198 # 80023778 <disk>
    80005846:	4781                	li	a5,0
    if(disk.free[i]){
    80005848:	01874683          	lbu	a3,24(a4)
    8000584c:	fee9                	bnez	a3,80005826 <virtio_disk_rw+0x46>
  for(int i = 0; i < NUM; i++){
    8000584e:	2785                	addiw	a5,a5,1
    80005850:	0705                	addi	a4,a4,1
    80005852:	fe979be3          	bne	a5,s1,80005848 <virtio_disk_rw+0x68>
    idx[i] = alloc_desc();
    80005856:	0185a023          	sw	s8,0(a1)
      for(int j = 0; j < i; j++)
    8000585a:	01205d63          	blez	s2,80005874 <virtio_disk_rw+0x94>
        free_desc(idx[j]);
    8000585e:	fa042503          	lw	a0,-96(s0)
    80005862:	d41ff0ef          	jal	800055a2 <free_desc>
      for(int j = 0; j < i; j++)
    80005866:	4785                	li	a5,1
    80005868:	0127d663          	bge	a5,s2,80005874 <virtio_disk_rw+0x94>
        free_desc(idx[j]);
    8000586c:	fa442503          	lw	a0,-92(s0)
    80005870:	d33ff0ef          	jal	800055a2 <free_desc>
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80005874:	0001e597          	auipc	a1,0x1e
    80005878:	02c58593          	addi	a1,a1,44 # 800238a0 <disk+0x128>
    8000587c:	0001e517          	auipc	a0,0x1e
    80005880:	f1450513          	addi	a0,a0,-236 # 80023790 <disk+0x18>
    80005884:	ef6fc0ef          	jal	80001f7a <sleep>
  for(int i = 0; i < 3; i++){
    80005888:	fa040613          	addi	a2,s0,-96
    8000588c:	4901                	li	s2,0
    8000588e:	b77d                	j	8000583c <virtio_disk_rw+0x5c>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80005890:	fa042503          	lw	a0,-96(s0)
    80005894:	00451693          	slli	a3,a0,0x4

  if(write)
    80005898:	0001e797          	auipc	a5,0x1e
    8000589c:	ee078793          	addi	a5,a5,-288 # 80023778 <disk>
    800058a0:	00451713          	slli	a4,a0,0x4
    800058a4:	0a070713          	addi	a4,a4,160
    800058a8:	973e                	add	a4,a4,a5
    800058aa:	01603633          	snez	a2,s6
    800058ae:	c710                	sw	a2,8(a4)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    800058b0:	00072623          	sw	zero,12(a4)
  buf0->sector = sector;
    800058b4:	01773823          	sd	s7,16(a4)

  disk.desc[idx[0]].addr = (uint64) buf0;
    800058b8:	6398                	ld	a4,0(a5)
    800058ba:	9736                	add	a4,a4,a3
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    800058bc:	0a868613          	addi	a2,a3,168 # 100010a8 <_entry-0x6fffef58>
    800058c0:	963e                	add	a2,a2,a5
  disk.desc[idx[0]].addr = (uint64) buf0;
    800058c2:	e310                	sd	a2,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    800058c4:	6390                	ld	a2,0(a5)
    800058c6:	00d60833          	add	a6,a2,a3
    800058ca:	4741                	li	a4,16
    800058cc:	00e82423          	sw	a4,8(a6)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    800058d0:	4585                	li	a1,1
    800058d2:	00b81623          	sh	a1,12(a6)
  disk.desc[idx[0]].next = idx[1];
    800058d6:	fa442703          	lw	a4,-92(s0)
    800058da:	00e81723          	sh	a4,14(a6)

  disk.desc[idx[1]].addr = (uint64) b->data;
    800058de:	0712                	slli	a4,a4,0x4
    800058e0:	963a                	add	a2,a2,a4
    800058e2:	05898813          	addi	a6,s3,88
    800058e6:	01063023          	sd	a6,0(a2)
  disk.desc[idx[1]].len = BSIZE;
    800058ea:	0007b883          	ld	a7,0(a5)
    800058ee:	9746                	add	a4,a4,a7
    800058f0:	40000613          	li	a2,1024
    800058f4:	c710                	sw	a2,8(a4)
  if(write)
    800058f6:	001b3613          	seqz	a2,s6
    800058fa:	0016161b          	slliw	a2,a2,0x1
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    800058fe:	8e4d                	or	a2,a2,a1
    80005900:	00c71623          	sh	a2,12(a4)
  disk.desc[idx[1]].next = idx[2];
    80005904:	fa842603          	lw	a2,-88(s0)
    80005908:	00c71723          	sh	a2,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    8000590c:	00451813          	slli	a6,a0,0x4
    80005910:	02080813          	addi	a6,a6,32
    80005914:	983e                	add	a6,a6,a5
    80005916:	577d                	li	a4,-1
    80005918:	00e80823          	sb	a4,16(a6)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    8000591c:	0612                	slli	a2,a2,0x4
    8000591e:	98b2                	add	a7,a7,a2
    80005920:	03068713          	addi	a4,a3,48
    80005924:	973e                	add	a4,a4,a5
    80005926:	00e8b023          	sd	a4,0(a7)
  disk.desc[idx[2]].len = 1;
    8000592a:	6398                	ld	a4,0(a5)
    8000592c:	9732                	add	a4,a4,a2
    8000592e:	c70c                	sw	a1,8(a4)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    80005930:	4689                	li	a3,2
    80005932:	00d71623          	sh	a3,12(a4)
  disk.desc[idx[2]].next = 0;
    80005936:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    8000593a:	00b9a223          	sw	a1,4(s3)
  disk.info[idx[0]].b = b;
    8000593e:	01383423          	sd	s3,8(a6)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    80005942:	6794                	ld	a3,8(a5)
    80005944:	0026d703          	lhu	a4,2(a3)
    80005948:	8b1d                	andi	a4,a4,7
    8000594a:	0706                	slli	a4,a4,0x1
    8000594c:	96ba                	add	a3,a3,a4
    8000594e:	00a69223          	sh	a0,4(a3)

  __sync_synchronize();
    80005952:	0330000f          	fence	rw,rw

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    80005956:	6798                	ld	a4,8(a5)
    80005958:	00275783          	lhu	a5,2(a4)
    8000595c:	2785                	addiw	a5,a5,1
    8000595e:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    80005962:	0330000f          	fence	rw,rw

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80005966:	100017b7          	lui	a5,0x10001
    8000596a:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    8000596e:	0049a783          	lw	a5,4(s3)
    sleep(b, &disk.vdisk_lock);
    80005972:	0001e917          	auipc	s2,0x1e
    80005976:	f2e90913          	addi	s2,s2,-210 # 800238a0 <disk+0x128>
  while(b->disk == 1) {
    8000597a:	84ae                	mv	s1,a1
    8000597c:	00b79a63          	bne	a5,a1,80005990 <virtio_disk_rw+0x1b0>
    sleep(b, &disk.vdisk_lock);
    80005980:	85ca                	mv	a1,s2
    80005982:	854e                	mv	a0,s3
    80005984:	df6fc0ef          	jal	80001f7a <sleep>
  while(b->disk == 1) {
    80005988:	0049a783          	lw	a5,4(s3)
    8000598c:	fe978ae3          	beq	a5,s1,80005980 <virtio_disk_rw+0x1a0>
  }

  disk.info[idx[0]].b = 0;
    80005990:	fa042903          	lw	s2,-96(s0)
    80005994:	00491713          	slli	a4,s2,0x4
    80005998:	02070713          	addi	a4,a4,32
    8000599c:	0001e797          	auipc	a5,0x1e
    800059a0:	ddc78793          	addi	a5,a5,-548 # 80023778 <disk>
    800059a4:	97ba                	add	a5,a5,a4
    800059a6:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    800059aa:	0001e997          	auipc	s3,0x1e
    800059ae:	dce98993          	addi	s3,s3,-562 # 80023778 <disk>
    800059b2:	00491713          	slli	a4,s2,0x4
    800059b6:	0009b783          	ld	a5,0(s3)
    800059ba:	97ba                	add	a5,a5,a4
    800059bc:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    800059c0:	854a                	mv	a0,s2
    800059c2:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    800059c6:	bddff0ef          	jal	800055a2 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    800059ca:	8885                	andi	s1,s1,1
    800059cc:	f0fd                	bnez	s1,800059b2 <virtio_disk_rw+0x1d2>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    800059ce:	0001e517          	auipc	a0,0x1e
    800059d2:	ed250513          	addi	a0,a0,-302 # 800238a0 <disk+0x128>
    800059d6:	b18fb0ef          	jal	80000cee <release>
}
    800059da:	60e6                	ld	ra,88(sp)
    800059dc:	6446                	ld	s0,80(sp)
    800059de:	64a6                	ld	s1,72(sp)
    800059e0:	6906                	ld	s2,64(sp)
    800059e2:	79e2                	ld	s3,56(sp)
    800059e4:	7a42                	ld	s4,48(sp)
    800059e6:	7aa2                	ld	s5,40(sp)
    800059e8:	7b02                	ld	s6,32(sp)
    800059ea:	6be2                	ld	s7,24(sp)
    800059ec:	6c42                	ld	s8,16(sp)
    800059ee:	6125                	addi	sp,sp,96
    800059f0:	8082                	ret

00000000800059f2 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    800059f2:	1101                	addi	sp,sp,-32
    800059f4:	ec06                	sd	ra,24(sp)
    800059f6:	e822                	sd	s0,16(sp)
    800059f8:	e426                	sd	s1,8(sp)
    800059fa:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    800059fc:	0001e497          	auipc	s1,0x1e
    80005a00:	d7c48493          	addi	s1,s1,-644 # 80023778 <disk>
    80005a04:	0001e517          	auipc	a0,0x1e
    80005a08:	e9c50513          	addi	a0,a0,-356 # 800238a0 <disk+0x128>
    80005a0c:	a4efb0ef          	jal	80000c5a <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    80005a10:	100017b7          	lui	a5,0x10001
    80005a14:	53bc                	lw	a5,96(a5)
    80005a16:	8b8d                	andi	a5,a5,3
    80005a18:	10001737          	lui	a4,0x10001
    80005a1c:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    80005a1e:	0330000f          	fence	rw,rw

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    80005a22:	689c                	ld	a5,16(s1)
    80005a24:	0204d703          	lhu	a4,32(s1)
    80005a28:	0027d783          	lhu	a5,2(a5) # 10001002 <_entry-0x6fffeffe>
    80005a2c:	04f70863          	beq	a4,a5,80005a7c <virtio_disk_intr+0x8a>
    __sync_synchronize();
    80005a30:	0330000f          	fence	rw,rw
    int id = disk.used->ring[disk.used_idx % NUM].id;
    80005a34:	6898                	ld	a4,16(s1)
    80005a36:	0204d783          	lhu	a5,32(s1)
    80005a3a:	8b9d                	andi	a5,a5,7
    80005a3c:	078e                	slli	a5,a5,0x3
    80005a3e:	97ba                	add	a5,a5,a4
    80005a40:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    80005a42:	00479713          	slli	a4,a5,0x4
    80005a46:	02070713          	addi	a4,a4,32 # 10001020 <_entry-0x6fffefe0>
    80005a4a:	9726                	add	a4,a4,s1
    80005a4c:	01074703          	lbu	a4,16(a4)
    80005a50:	e329                	bnez	a4,80005a92 <virtio_disk_intr+0xa0>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    80005a52:	0792                	slli	a5,a5,0x4
    80005a54:	02078793          	addi	a5,a5,32
    80005a58:	97a6                	add	a5,a5,s1
    80005a5a:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    80005a5c:	00052223          	sw	zero,4(a0)
    wakeup(b);
    80005a60:	d66fc0ef          	jal	80001fc6 <wakeup>

    disk.used_idx += 1;
    80005a64:	0204d783          	lhu	a5,32(s1)
    80005a68:	2785                	addiw	a5,a5,1
    80005a6a:	17c2                	slli	a5,a5,0x30
    80005a6c:	93c1                	srli	a5,a5,0x30
    80005a6e:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    80005a72:	6898                	ld	a4,16(s1)
    80005a74:	00275703          	lhu	a4,2(a4)
    80005a78:	faf71ce3          	bne	a4,a5,80005a30 <virtio_disk_intr+0x3e>
  }

  release(&disk.vdisk_lock);
    80005a7c:	0001e517          	auipc	a0,0x1e
    80005a80:	e2450513          	addi	a0,a0,-476 # 800238a0 <disk+0x128>
    80005a84:	a6afb0ef          	jal	80000cee <release>
}
    80005a88:	60e2                	ld	ra,24(sp)
    80005a8a:	6442                	ld	s0,16(sp)
    80005a8c:	64a2                	ld	s1,8(sp)
    80005a8e:	6105                	addi	sp,sp,32
    80005a90:	8082                	ret
      panic("virtio_disk_intr status");
    80005a92:	00002517          	auipc	a0,0x2
    80005a96:	c7650513          	addi	a0,a0,-906 # 80007708 <etext+0x708>
    80005a9a:	dbdfa0ef          	jal	80000856 <panic>

0000000080005a9e <cslog_init>:
  safestrcpy(e->name, p->name, CS_NM);
}

void
cslog_init(void)
{
    80005a9e:	1141                	addi	sp,sp,-16
    80005aa0:	e406                	sd	ra,8(sp)
    80005aa2:	e022                	sd	s0,0(sp)
    80005aa4:	0800                	addi	s0,sp,16
  ringbuf_init(&cs_rb, "cslog", sizeof(struct cs_event));
    80005aa6:	03000613          	li	a2,48
    80005aaa:	00002597          	auipc	a1,0x2
    80005aae:	c7658593          	addi	a1,a1,-906 # 80007720 <etext+0x720>
    80005ab2:	0001e517          	auipc	a0,0x1e
    80005ab6:	e0650513          	addi	a0,a0,-506 # 800238b8 <cs_rb>
    80005aba:	1a2000ef          	jal	80005c5c <ringbuf_init>
}
    80005abe:	60a2                	ld	ra,8(sp)
    80005ac0:	6402                	ld	s0,0(sp)
    80005ac2:	0141                	addi	sp,sp,16
    80005ac4:	8082                	ret

0000000080005ac6 <cslog_push>:

void
cslog_push(struct cs_event *e)
{
    80005ac6:	1141                	addi	sp,sp,-16
    80005ac8:	e406                	sd	ra,8(sp)
    80005aca:	e022                	sd	s0,0(sp)
    80005acc:	0800                	addi	s0,sp,16
    80005ace:	85aa                	mv	a1,a0
  e->seq = ++cs_seq;
    80005ad0:	00005717          	auipc	a4,0x5
    80005ad4:	aa070713          	addi	a4,a4,-1376 # 8000a570 <cs_seq>
    80005ad8:	631c                	ld	a5,0(a4)
    80005ada:	0785                	addi	a5,a5,1
    80005adc:	e31c                	sd	a5,0(a4)
    80005ade:	e11c                	sd	a5,0(a0)
  ringbuf_push(&cs_rb, e);
    80005ae0:	0001e517          	auipc	a0,0x1e
    80005ae4:	dd850513          	addi	a0,a0,-552 # 800238b8 <cs_rb>
    80005ae8:	1a8000ef          	jal	80005c90 <ringbuf_push>
}
    80005aec:	60a2                	ld	ra,8(sp)
    80005aee:	6402                	ld	s0,0(sp)
    80005af0:	0141                	addi	sp,sp,16
    80005af2:	8082                	ret

0000000080005af4 <cslog_read_many>:

int
cslog_read_many(struct cs_event *out, int max)
{
    80005af4:	1141                	addi	sp,sp,-16
    80005af6:	e406                	sd	ra,8(sp)
    80005af8:	e022                	sd	s0,0(sp)
    80005afa:	0800                	addi	s0,sp,16
    80005afc:	862e                	mv	a2,a1
  return ringbuf_read_many(&cs_rb, out, max);
    80005afe:	85aa                	mv	a1,a0
    80005b00:	0001e517          	auipc	a0,0x1e
    80005b04:	db850513          	addi	a0,a0,-584 # 800238b8 <cs_rb>
    80005b08:	1f4000ef          	jal	80005cfc <ringbuf_read_many>
}
    80005b0c:	60a2                	ld	ra,8(sp)
    80005b0e:	6402                	ld	s0,0(sp)
    80005b10:	0141                	addi	sp,sp,16
    80005b12:	8082                	ret

0000000080005b14 <cslog_run_start>:

void
cslog_run_start(struct proc *p)
{
  if(p == 0) return;
    80005b14:	c14d                	beqz	a0,80005bb6 <cslog_run_start+0xa2>
{
    80005b16:	715d                	addi	sp,sp,-80
    80005b18:	e486                	sd	ra,72(sp)
    80005b1a:	e0a2                	sd	s0,64(sp)
    80005b1c:	fc26                	sd	s1,56(sp)
    80005b1e:	0880                	addi	s0,sp,80
    80005b20:	84aa                	mv	s1,a0
  if(p->pid <= 0) return;
    80005b22:	591c                	lw	a5,48(a0)
    80005b24:	00f05563          	blez	a5,80005b2e <cslog_run_start+0x1a>
  if(p->name[0] == 0) return;
    80005b28:	15854783          	lbu	a5,344(a0)
    80005b2c:	e791                	bnez	a5,80005b38 <cslog_run_start+0x24>

  struct cs_event e;
  fill_from_proc(&e, p);
  e.type = CS_RUN_START;
  cslog_push(&e);
    80005b2e:	60a6                	ld	ra,72(sp)
    80005b30:	6406                	ld	s0,64(sp)
    80005b32:	74e2                	ld	s1,56(sp)
    80005b34:	6161                	addi	sp,sp,80
    80005b36:	8082                	ret
    80005b38:	f84a                	sd	s2,48(sp)
  if(strncmp(p->name, "cscat", 5) == 0) return;
    80005b3a:	15850913          	addi	s2,a0,344
    80005b3e:	4615                	li	a2,5
    80005b40:	00002597          	auipc	a1,0x2
    80005b44:	be858593          	addi	a1,a1,-1048 # 80007728 <etext+0x728>
    80005b48:	854a                	mv	a0,s2
    80005b4a:	ab4fb0ef          	jal	80000dfe <strncmp>
    80005b4e:	e119                	bnez	a0,80005b54 <cslog_run_start+0x40>
    80005b50:	7942                	ld	s2,48(sp)
    80005b52:	bff1                	j	80005b2e <cslog_run_start+0x1a>
  if(strncmp(p->name, "csexport", 8) == 0) return;
    80005b54:	4621                	li	a2,8
    80005b56:	00002597          	auipc	a1,0x2
    80005b5a:	bda58593          	addi	a1,a1,-1062 # 80007730 <etext+0x730>
    80005b5e:	854a                	mv	a0,s2
    80005b60:	a9efb0ef          	jal	80000dfe <strncmp>
    80005b64:	e119                	bnez	a0,80005b6a <cslog_run_start+0x56>
    80005b66:	7942                	ld	s2,48(sp)
    80005b68:	b7d9                	j	80005b2e <cslog_run_start+0x1a>
  memset(e, 0, sizeof(*e));
    80005b6a:	03000613          	li	a2,48
    80005b6e:	4581                	li	a1,0
    80005b70:	fb040513          	addi	a0,s0,-80
    80005b74:	9b6fb0ef          	jal	80000d2a <memset>
  e->ticks = ticks;
    80005b78:	00005797          	auipc	a5,0x5
    80005b7c:	9f07a783          	lw	a5,-1552(a5) # 8000a568 <ticks>
    80005b80:	faf42c23          	sw	a5,-72(s0)
  e->cpu   = cpuid();
    80005b84:	dadfb0ef          	jal	80001930 <cpuid>
    80005b88:	faa42e23          	sw	a0,-68(s0)
  e->pid   = p->pid;
    80005b8c:	589c                	lw	a5,48(s1)
    80005b8e:	fcf42223          	sw	a5,-60(s0)
  e->state = p->state;
    80005b92:	4c9c                	lw	a5,24(s1)
    80005b94:	fcf42423          	sw	a5,-56(s0)
  safestrcpy(e->name, p->name, CS_NM);
    80005b98:	4641                	li	a2,16
    80005b9a:	85ca                	mv	a1,s2
    80005b9c:	fcc40513          	addi	a0,s0,-52
    80005ba0:	adefb0ef          	jal	80000e7e <safestrcpy>
  e.type = CS_RUN_START;
    80005ba4:	4785                	li	a5,1
    80005ba6:	fcf42023          	sw	a5,-64(s0)
  cslog_push(&e);
    80005baa:	fb040513          	addi	a0,s0,-80
    80005bae:	f19ff0ef          	jal	80005ac6 <cslog_push>
    80005bb2:	7942                	ld	s2,48(sp)
    80005bb4:	bfad                	j	80005b2e <cslog_run_start+0x1a>
    80005bb6:	8082                	ret

0000000080005bb8 <sys_csread>:
#include "cslog.h"


uint64
sys_csread(void)
{
    80005bb8:	81010113          	addi	sp,sp,-2032
    80005bbc:	7e113423          	sd	ra,2024(sp)
    80005bc0:	7e813023          	sd	s0,2016(sp)
    80005bc4:	7c913c23          	sd	s1,2008(sp)
    80005bc8:	7d213823          	sd	s2,2000(sp)
    80005bcc:	7f010413          	addi	s0,sp,2032
    80005bd0:	bc010113          	addi	sp,sp,-1088
  uint64 uaddr = 0;
    80005bd4:	fc043c23          	sd	zero,-40(s0)
  int max = 0;
    80005bd8:	fc042a23          	sw	zero,-44(s0)

  // ✅ عندك argaddr/argint void، فبنستدعيهم بدون if
  argaddr(0, &uaddr);
    80005bdc:	fd840593          	addi	a1,s0,-40
    80005be0:	4501                	li	a0,0
    80005be2:	cc1fc0ef          	jal	800028a2 <argaddr>
  argint(1, &max);
    80005be6:	fd440593          	addi	a1,s0,-44
    80005bea:	4505                	li	a0,1
    80005bec:	c9bfc0ef          	jal	80002886 <argint>

  if(max <= 0) return 0;
    80005bf0:	fd442783          	lw	a5,-44(s0)
    80005bf4:	4501                	li	a0,0
    80005bf6:	04f05463          	blez	a5,80005c3e <sys_csread+0x86>
  if(max > 64) max = 64;
    80005bfa:	04000713          	li	a4,64
    80005bfe:	00f75463          	bge	a4,a5,80005c06 <sys_csread+0x4e>
    80005c02:	fce42a23          	sw	a4,-44(s0)

  struct cs_event tmp[64];
  int n = cslog_read_many(tmp, max);
    80005c06:	80040493          	addi	s1,s0,-2048
    80005c0a:	1481                	addi	s1,s1,-32
    80005c0c:	bf048493          	addi	s1,s1,-1040
    80005c10:	fd442583          	lw	a1,-44(s0)
    80005c14:	8526                	mv	a0,s1
    80005c16:	edfff0ef          	jal	80005af4 <cslog_read_many>
    80005c1a:	892a                	mv	s2,a0

  int bytes = n * (int)sizeof(struct cs_event);
  if(copyout(myproc()->pagetable, uaddr, (char*)tmp, bytes) < 0)
    80005c1c:	d49fb0ef          	jal	80001964 <myproc>
  int bytes = n * (int)sizeof(struct cs_event);
    80005c20:	0019169b          	slliw	a3,s2,0x1
    80005c24:	012686bb          	addw	a3,a3,s2
  if(copyout(myproc()->pagetable, uaddr, (char*)tmp, bytes) < 0)
    80005c28:	0046969b          	slliw	a3,a3,0x4
    80005c2c:	8626                	mv	a2,s1
    80005c2e:	fd843583          	ld	a1,-40(s0)
    80005c32:	6928                	ld	a0,80(a0)
    80005c34:	a57fb0ef          	jal	8000168a <copyout>
    80005c38:	02054063          	bltz	a0,80005c58 <sys_csread+0xa0>
    return -1;

  return n;
    80005c3c:	854a                	mv	a0,s2
}
    80005c3e:	44010113          	addi	sp,sp,1088
    80005c42:	7e813083          	ld	ra,2024(sp)
    80005c46:	7e013403          	ld	s0,2016(sp)
    80005c4a:	7d813483          	ld	s1,2008(sp)
    80005c4e:	7d013903          	ld	s2,2000(sp)
    80005c52:	7f010113          	addi	sp,sp,2032
    80005c56:	8082                	ret
    return -1;
    80005c58:	557d                	li	a0,-1
    80005c5a:	b7d5                	j	80005c3e <sys_csread+0x86>

0000000080005c5c <ringbuf_init>:
  return (void *)(rb->buf + idx * rb->elem_size);
}

void
ringbuf_init(struct ringbuf *rb, char *name, uint elem_size)
{
    80005c5c:	1101                	addi	sp,sp,-32
    80005c5e:	ec06                	sd	ra,24(sp)
    80005c60:	e822                	sd	s0,16(sp)
    80005c62:	e426                	sd	s1,8(sp)
    80005c64:	e04a                	sd	s2,0(sp)
    80005c66:	1000                	addi	s0,sp,32
    80005c68:	84aa                	mv	s1,a0
    80005c6a:	8932                	mv	s2,a2
  initlock(&rb->lock, name);
    80005c6c:	f65fa0ef          	jal	80000bd0 <initlock>
  rb->head = 0;
    80005c70:	0004ac23          	sw	zero,24(s1)
  rb->tail = 0;
    80005c74:	0004ae23          	sw	zero,28(s1)
  rb->count = 0;
    80005c78:	0204a023          	sw	zero,32(s1)
  rb->seq = 0;
    80005c7c:	0204b423          	sd	zero,40(s1)
  rb->elem_size = elem_size;
    80005c80:	0324a223          	sw	s2,36(s1)
}
    80005c84:	60e2                	ld	ra,24(sp)
    80005c86:	6442                	ld	s0,16(sp)
    80005c88:	64a2                	ld	s1,8(sp)
    80005c8a:	6902                	ld	s2,0(sp)
    80005c8c:	6105                	addi	sp,sp,32
    80005c8e:	8082                	ret

0000000080005c90 <ringbuf_push>:

int
ringbuf_push(struct ringbuf *rb, void *elem)
{
    80005c90:	1101                	addi	sp,sp,-32
    80005c92:	ec06                	sd	ra,24(sp)
    80005c94:	e822                	sd	s0,16(sp)
    80005c96:	e426                	sd	s1,8(sp)
    80005c98:	e04a                	sd	s2,0(sp)
    80005c9a:	1000                	addi	s0,sp,32
    80005c9c:	84aa                	mv	s1,a0
    80005c9e:	892e                	mv	s2,a1
  acquire(&rb->lock);
    80005ca0:	fbbfa0ef          	jal	80000c5a <acquire>

  if(rb->count == RB_CAP){
    80005ca4:	5098                	lw	a4,32(s1)
    80005ca6:	20000793          	li	a5,512
    80005caa:	04f70063          	beq	a4,a5,80005cea <ringbuf_push+0x5a>
  return (void *)(rb->buf + idx * rb->elem_size);
    80005cae:	50d0                	lw	a2,36(s1)
    80005cb0:	03048513          	addi	a0,s1,48
    80005cb4:	4c9c                	lw	a5,24(s1)
    80005cb6:	02c787bb          	mulw	a5,a5,a2
    80005cba:	1782                	slli	a5,a5,0x20
    80005cbc:	9381                	srli	a5,a5,0x20
    rb->tail = (rb->tail + 1) % RB_CAP;
    rb->count--;
  }

  memmove(slot_ptr(rb, rb->head), elem, rb->elem_size);
    80005cbe:	85ca                	mv	a1,s2
    80005cc0:	953e                	add	a0,a0,a5
    80005cc2:	8c8fb0ef          	jal	80000d8a <memmove>
  rb->head = (rb->head + 1) % RB_CAP;
    80005cc6:	4c9c                	lw	a5,24(s1)
    80005cc8:	2785                	addiw	a5,a5,1
    80005cca:	1ff7f793          	andi	a5,a5,511
    80005cce:	cc9c                	sw	a5,24(s1)
  rb->count++;
    80005cd0:	509c                	lw	a5,32(s1)
    80005cd2:	2785                	addiw	a5,a5,1
    80005cd4:	d09c                	sw	a5,32(s1)

  release(&rb->lock);
    80005cd6:	8526                	mv	a0,s1
    80005cd8:	816fb0ef          	jal	80000cee <release>
  return 0;
}
    80005cdc:	4501                	li	a0,0
    80005cde:	60e2                	ld	ra,24(sp)
    80005ce0:	6442                	ld	s0,16(sp)
    80005ce2:	64a2                	ld	s1,8(sp)
    80005ce4:	6902                	ld	s2,0(sp)
    80005ce6:	6105                	addi	sp,sp,32
    80005ce8:	8082                	ret
    rb->tail = (rb->tail + 1) % RB_CAP;
    80005cea:	4cdc                	lw	a5,28(s1)
    80005cec:	2785                	addiw	a5,a5,1
    80005cee:	1ff7f793          	andi	a5,a5,511
    80005cf2:	ccdc                	sw	a5,28(s1)
    rb->count--;
    80005cf4:	1ff00793          	li	a5,511
    80005cf8:	d09c                	sw	a5,32(s1)
    80005cfa:	bf55                	j	80005cae <ringbuf_push+0x1e>

0000000080005cfc <ringbuf_read_many>:
ringbuf_read_many(struct ringbuf *rb, void *out, int max)
{
  int n = 0;
  char *dst = (char *)out;

  if(max <= 0)
    80005cfc:	06c05d63          	blez	a2,80005d76 <ringbuf_read_many+0x7a>
{
    80005d00:	7139                	addi	sp,sp,-64
    80005d02:	fc06                	sd	ra,56(sp)
    80005d04:	f822                	sd	s0,48(sp)
    80005d06:	f426                	sd	s1,40(sp)
    80005d08:	f04a                	sd	s2,32(sp)
    80005d0a:	ec4e                	sd	s3,24(sp)
    80005d0c:	e852                	sd	s4,16(sp)
    80005d0e:	e456                	sd	s5,8(sp)
    80005d10:	0080                	addi	s0,sp,64
    80005d12:	84aa                	mv	s1,a0
    80005d14:	8a2e                	mv	s4,a1
    80005d16:	89b2                	mv	s3,a2
    return 0;

  acquire(&rb->lock);
    80005d18:	f43fa0ef          	jal	80000c5a <acquire>
  int n = 0;
    80005d1c:	4901                	li	s2,0
  return (void *)(rb->buf + idx * rb->elem_size);
    80005d1e:	03048a93          	addi	s5,s1,48
  while(n < max && rb->count > 0){
    80005d22:	509c                	lw	a5,32(s1)
    80005d24:	c7b9                	beqz	a5,80005d72 <ringbuf_read_many+0x76>
    memmove(dst + n * rb->elem_size, slot_ptr(rb, rb->tail), rb->elem_size);
    80005d26:	50d0                	lw	a2,36(s1)
  return (void *)(rb->buf + idx * rb->elem_size);
    80005d28:	4ccc                	lw	a1,28(s1)
    80005d2a:	02c585bb          	mulw	a1,a1,a2
    80005d2e:	1582                	slli	a1,a1,0x20
    80005d30:	9181                	srli	a1,a1,0x20
    memmove(dst + n * rb->elem_size, slot_ptr(rb, rb->tail), rb->elem_size);
    80005d32:	02c9053b          	mulw	a0,s2,a2
    80005d36:	1502                	slli	a0,a0,0x20
    80005d38:	9101                	srli	a0,a0,0x20
    80005d3a:	95d6                	add	a1,a1,s5
    80005d3c:	9552                	add	a0,a0,s4
    80005d3e:	84cfb0ef          	jal	80000d8a <memmove>
    rb->tail = (rb->tail + 1) % RB_CAP;
    80005d42:	4cdc                	lw	a5,28(s1)
    80005d44:	2785                	addiw	a5,a5,1
    80005d46:	1ff7f793          	andi	a5,a5,511
    80005d4a:	ccdc                	sw	a5,28(s1)
    rb->count--;
    80005d4c:	509c                	lw	a5,32(s1)
    80005d4e:	37fd                	addiw	a5,a5,-1
    80005d50:	d09c                	sw	a5,32(s1)
    n++;
    80005d52:	2905                	addiw	s2,s2,1
  while(n < max && rb->count > 0){
    80005d54:	fd2997e3          	bne	s3,s2,80005d22 <ringbuf_read_many+0x26>
  }
  release(&rb->lock);
    80005d58:	8526                	mv	a0,s1
    80005d5a:	f95fa0ef          	jal	80000cee <release>

  return n;
    80005d5e:	854e                	mv	a0,s3
}
    80005d60:	70e2                	ld	ra,56(sp)
    80005d62:	7442                	ld	s0,48(sp)
    80005d64:	74a2                	ld	s1,40(sp)
    80005d66:	7902                	ld	s2,32(sp)
    80005d68:	69e2                	ld	s3,24(sp)
    80005d6a:	6a42                	ld	s4,16(sp)
    80005d6c:	6aa2                	ld	s5,8(sp)
    80005d6e:	6121                	addi	sp,sp,64
    80005d70:	8082                	ret
    80005d72:	89ca                	mv	s3,s2
    80005d74:	b7d5                	j	80005d58 <ringbuf_read_many+0x5c>
    return 0;
    80005d76:	4501                	li	a0,0
}
    80005d78:	8082                	ret

0000000080005d7a <ringbuf_pop>:
int
ringbuf_pop(struct ringbuf *rb, void *dst)
{
    80005d7a:	1101                	addi	sp,sp,-32
    80005d7c:	ec06                	sd	ra,24(sp)
    80005d7e:	e822                	sd	s0,16(sp)
    80005d80:	e426                	sd	s1,8(sp)
    80005d82:	e04a                	sd	s2,0(sp)
    80005d84:	1000                	addi	s0,sp,32
    80005d86:	84aa                	mv	s1,a0
    80005d88:	892e                	mv	s2,a1
  acquire(&rb->lock);
    80005d8a:	ed1fa0ef          	jal	80000c5a <acquire>
  
  if(rb->count == 0){ // البفر فارغ تماماً
    80005d8e:	509c                	lw	a5,32(s1)
    80005d90:	cf9d                	beqz	a5,80005dce <ringbuf_pop+0x54>
  return (void *)(rb->buf + idx * rb->elem_size);
    80005d92:	50d0                	lw	a2,36(s1)
    80005d94:	03048593          	addi	a1,s1,48
    80005d98:	4cdc                	lw	a5,28(s1)
    80005d9a:	02c787bb          	mulw	a5,a5,a2
    80005d9e:	1782                	slli	a5,a5,0x20
    80005da0:	9381                	srli	a5,a5,0x20
    return -1;
  }

  // استخدام الدالة المساعدة slot_ptr الموجودة عندك أصلاً
  void *src = slot_ptr(rb, rb->tail);
  memmove(dst, src, rb->elem_size);
    80005da2:	95be                	add	a1,a1,a5
    80005da4:	854a                	mv	a0,s2
    80005da6:	fe5fa0ef          	jal	80000d8a <memmove>
  
  // تحديث المؤشرات بنفس منطق المشروع
  rb->tail = (rb->tail + 1) % RB_CAP;
    80005daa:	4cdc                	lw	a5,28(s1)
    80005dac:	2785                	addiw	a5,a5,1
    80005dae:	1ff7f793          	andi	a5,a5,511
    80005db2:	ccdc                	sw	a5,28(s1)
  rb->count--;
    80005db4:	509c                	lw	a5,32(s1)
    80005db6:	37fd                	addiw	a5,a5,-1
    80005db8:	d09c                	sw	a5,32(s1)
  
  release(&rb->lock);
    80005dba:	8526                	mv	a0,s1
    80005dbc:	f33fa0ef          	jal	80000cee <release>
  return 0;
    80005dc0:	4501                	li	a0,0
} 
    80005dc2:	60e2                	ld	ra,24(sp)
    80005dc4:	6442                	ld	s0,16(sp)
    80005dc6:	64a2                	ld	s1,8(sp)
    80005dc8:	6902                	ld	s2,0(sp)
    80005dca:	6105                	addi	sp,sp,32
    80005dcc:	8082                	ret
    release(&rb->lock);
    80005dce:	8526                	mv	a0,s1
    80005dd0:	f1ffa0ef          	jal	80000cee <release>
    return -1;
    80005dd4:	557d                	li	a0,-1
    80005dd6:	b7f5                	j	80005dc2 <ringbuf_pop+0x48>

0000000080005dd8 <fslog_init>:
#include "defs.h"

static struct ringbuf fs_rb;
static uint64 fs_seq = 0;

void fslog_init(void) {
    80005dd8:	1141                	addi	sp,sp,-16
    80005dda:	e406                	sd	ra,8(sp)
    80005ddc:	e022                	sd	s0,0(sp)
    80005dde:	0800                	addi	s0,sp,16
  ringbuf_init(&fs_rb, "fslog", sizeof(struct fs_event));
    80005de0:	03000613          	li	a2,48
    80005de4:	00002597          	auipc	a1,0x2
    80005de8:	95c58593          	addi	a1,a1,-1700 # 80007740 <etext+0x740>
    80005dec:	00026517          	auipc	a0,0x26
    80005df0:	afc50513          	addi	a0,a0,-1284 # 8002b8e8 <fs_rb>
    80005df4:	e69ff0ef          	jal	80005c5c <ringbuf_init>
}
    80005df8:	60a2                	ld	ra,8(sp)
    80005dfa:	6402                	ld	s0,0(sp)
    80005dfc:	0141                	addi	sp,sp,16
    80005dfe:	8082                	ret

0000000080005e00 <fslog_push>:

void fslog_push(int type, int inum, int bno, uint size, char* name) {
    80005e00:	7159                	addi	sp,sp,-112
    80005e02:	f486                	sd	ra,104(sp)
    80005e04:	f0a2                	sd	s0,96(sp)
    80005e06:	eca6                	sd	s1,88(sp)
    80005e08:	e8ca                	sd	s2,80(sp)
    80005e0a:	e4ce                	sd	s3,72(sp)
    80005e0c:	e0d2                	sd	s4,64(sp)
    80005e0e:	fc56                	sd	s5,56(sp)
    80005e10:	1880                	addi	s0,sp,112
    80005e12:	84aa                	mv	s1,a0
    80005e14:	892e                	mv	s2,a1
    80005e16:	89b2                	mv	s3,a2
    80005e18:	8a36                	mv	s4,a3
    80005e1a:	8aba                	mv	s5,a4
  struct fs_event e;
  memset(&e, 0, sizeof(e));
    80005e1c:	03000613          	li	a2,48
    80005e20:	4581                	li	a1,0
    80005e22:	f9040513          	addi	a0,s0,-112
    80005e26:	f05fa0ef          	jal	80000d2a <memset>
  e.seq = ++fs_seq;
    80005e2a:	00004717          	auipc	a4,0x4
    80005e2e:	74e70713          	addi	a4,a4,1870 # 8000a578 <fs_seq>
    80005e32:	631c                	ld	a5,0(a4)
    80005e34:	0785                	addi	a5,a5,1
    80005e36:	e31c                	sd	a5,0(a4)
    80005e38:	f8f43823          	sd	a5,-112(s0)
  e.ticks = ticks;
    80005e3c:	00004797          	auipc	a5,0x4
    80005e40:	72c7a783          	lw	a5,1836(a5) # 8000a568 <ticks>
    80005e44:	f8f42c23          	sw	a5,-104(s0)
  e.type = type;
    80005e48:	f8942e23          	sw	s1,-100(s0)
  e.pid = myproc() ? myproc()->pid : 0;
    80005e4c:	b19fb0ef          	jal	80001964 <myproc>
    80005e50:	4781                	li	a5,0
    80005e52:	c501                	beqz	a0,80005e5a <fslog_push+0x5a>
    80005e54:	b11fb0ef          	jal	80001964 <myproc>
    80005e58:	591c                	lw	a5,48(a0)
    80005e5a:	faf42023          	sw	a5,-96(s0)
  e.inum = inum;
    80005e5e:	fb242223          	sw	s2,-92(s0)
  e.blockno = bno;
    80005e62:	fb342423          	sw	s3,-88(s0)
  e.size = size;
    80005e66:	fb442623          	sw	s4,-84(s0)
  if(name) safestrcpy(e.name, name, FS_NM);
    80005e6a:	000a8863          	beqz	s5,80005e7a <fslog_push+0x7a>
    80005e6e:	4641                	li	a2,16
    80005e70:	85d6                	mv	a1,s5
    80005e72:	fb040513          	addi	a0,s0,-80
    80005e76:	808fb0ef          	jal	80000e7e <safestrcpy>
  ringbuf_push(&fs_rb, &e);
    80005e7a:	f9040593          	addi	a1,s0,-112
    80005e7e:	00026517          	auipc	a0,0x26
    80005e82:	a6a50513          	addi	a0,a0,-1430 # 8002b8e8 <fs_rb>
    80005e86:	e0bff0ef          	jal	80005c90 <ringbuf_push>
}
    80005e8a:	70a6                	ld	ra,104(sp)
    80005e8c:	7406                	ld	s0,96(sp)
    80005e8e:	64e6                	ld	s1,88(sp)
    80005e90:	6946                	ld	s2,80(sp)
    80005e92:	69a6                	ld	s3,72(sp)
    80005e94:	6a06                	ld	s4,64(sp)
    80005e96:	7ae2                	ld	s5,56(sp)
    80005e98:	6165                	addi	sp,sp,112
    80005e9a:	8082                	ret

0000000080005e9c <fslog_read_many>:
// لا تنسي إضافة fslog_read_many أيضاً هنا

int
fslog_read_many(struct fs_event *out, int max)
{
    80005e9c:	7119                	addi	sp,sp,-128
    80005e9e:	fc86                	sd	ra,120(sp)
    80005ea0:	f8a2                	sd	s0,112(sp)
    80005ea2:	f4a6                	sd	s1,104(sp)
    80005ea4:	f0ca                	sd	s2,96(sp)
    80005ea6:	e8d2                	sd	s4,80(sp)
    80005ea8:	0100                	addi	s0,sp,128
    80005eaa:	84aa                	mv	s1,a0
    80005eac:	8a2e                	mv	s4,a1
  struct fs_event e;
  int count = 0;
  struct proc *p = myproc();
    80005eae:	ab7fb0ef          	jal	80001964 <myproc>

  while(count < max){
    80005eb2:	05405863          	blez	s4,80005f02 <fslog_read_many+0x66>
    80005eb6:	ecce                	sd	s3,88(sp)
    80005eb8:	e4d6                	sd	s5,72(sp)
    80005eba:	e0da                	sd	s6,64(sp)
    80005ebc:	fc5e                	sd	s7,56(sp)
    80005ebe:	8aaa                	mv	s5,a0
  int count = 0;
    80005ec0:	4901                	li	s2,0
    // سحب حدث واحد من الرينغ بفر (موجود في ذاكرة الكيرنل)
    if(ringbuf_pop(&fs_rb, &e) != 0)
    80005ec2:	f8040993          	addi	s3,s0,-128
    80005ec6:	00026b17          	auipc	s6,0x26
    80005eca:	a22b0b13          	addi	s6,s6,-1502 # 8002b8e8 <fs_rb>
      break;

    // 🔥 النسخ الآمن لذاكرة المستخدم باستخدام copyout
    // العنوان الهدف: out + (count * حجم الـ struct)
    uint64 dst_addr = (uint64)out + (count * sizeof(struct fs_event));
    if(copyout(p->pagetable, dst_addr, (char *)&e, sizeof(struct fs_event)) < 0)
    80005ece:	03000b93          	li	s7,48
    if(ringbuf_pop(&fs_rb, &e) != 0)
    80005ed2:	85ce                	mv	a1,s3
    80005ed4:	855a                	mv	a0,s6
    80005ed6:	ea5ff0ef          	jal	80005d7a <ringbuf_pop>
    80005eda:	e515                	bnez	a0,80005f06 <fslog_read_many+0x6a>
    if(copyout(p->pagetable, dst_addr, (char *)&e, sizeof(struct fs_event)) < 0)
    80005edc:	86de                	mv	a3,s7
    80005ede:	864e                	mv	a2,s3
    80005ee0:	85a6                	mv	a1,s1
    80005ee2:	050ab503          	ld	a0,80(s5)
    80005ee6:	fa4fb0ef          	jal	8000168a <copyout>
    80005eea:	02054a63          	bltz	a0,80005f1e <fslog_read_many+0x82>
      break;

    count++;
    80005eee:	2905                	addiw	s2,s2,1
  while(count < max){
    80005ef0:	03048493          	addi	s1,s1,48
    80005ef4:	fd2a1fe3          	bne	s4,s2,80005ed2 <fslog_read_many+0x36>
    80005ef8:	69e6                	ld	s3,88(sp)
    80005efa:	6aa6                	ld	s5,72(sp)
    80005efc:	6b06                	ld	s6,64(sp)
    80005efe:	7be2                	ld	s7,56(sp)
    80005f00:	a039                	j	80005f0e <fslog_read_many+0x72>
  int count = 0;
    80005f02:	4901                	li	s2,0
    80005f04:	a029                	j	80005f0e <fslog_read_many+0x72>
    80005f06:	69e6                	ld	s3,88(sp)
    80005f08:	6aa6                	ld	s5,72(sp)
    80005f0a:	6b06                	ld	s6,64(sp)
    80005f0c:	7be2                	ld	s7,56(sp)
  }
  return count;
    80005f0e:	854a                	mv	a0,s2
    80005f10:	70e6                	ld	ra,120(sp)
    80005f12:	7446                	ld	s0,112(sp)
    80005f14:	74a6                	ld	s1,104(sp)
    80005f16:	7906                	ld	s2,96(sp)
    80005f18:	6a46                	ld	s4,80(sp)
    80005f1a:	6109                	addi	sp,sp,128
    80005f1c:	8082                	ret
    80005f1e:	69e6                	ld	s3,88(sp)
    80005f20:	6aa6                	ld	s5,72(sp)
    80005f22:	6b06                	ld	s6,64(sp)
    80005f24:	7be2                	ld	s7,56(sp)
    80005f26:	b7e5                	j	80005f0e <fslog_read_many+0x72>
	...

0000000080006000 <_trampoline>:
    80006000:	14051073          	csrw	sscratch,a0
    80006004:	02000537          	lui	a0,0x2000
    80006008:	357d                	addiw	a0,a0,-1 # 1ffffff <_entry-0x7e000001>
    8000600a:	0536                	slli	a0,a0,0xd
    8000600c:	02153423          	sd	ra,40(a0)
    80006010:	02253823          	sd	sp,48(a0)
    80006014:	02353c23          	sd	gp,56(a0)
    80006018:	04453023          	sd	tp,64(a0)
    8000601c:	04553423          	sd	t0,72(a0)
    80006020:	04653823          	sd	t1,80(a0)
    80006024:	04753c23          	sd	t2,88(a0)
    80006028:	f120                	sd	s0,96(a0)
    8000602a:	f524                	sd	s1,104(a0)
    8000602c:	fd2c                	sd	a1,120(a0)
    8000602e:	e150                	sd	a2,128(a0)
    80006030:	e554                	sd	a3,136(a0)
    80006032:	e958                	sd	a4,144(a0)
    80006034:	ed5c                	sd	a5,152(a0)
    80006036:	0b053023          	sd	a6,160(a0)
    8000603a:	0b153423          	sd	a7,168(a0)
    8000603e:	0b253823          	sd	s2,176(a0)
    80006042:	0b353c23          	sd	s3,184(a0)
    80006046:	0d453023          	sd	s4,192(a0)
    8000604a:	0d553423          	sd	s5,200(a0)
    8000604e:	0d653823          	sd	s6,208(a0)
    80006052:	0d753c23          	sd	s7,216(a0)
    80006056:	0f853023          	sd	s8,224(a0)
    8000605a:	0f953423          	sd	s9,232(a0)
    8000605e:	0fa53823          	sd	s10,240(a0)
    80006062:	0fb53c23          	sd	s11,248(a0)
    80006066:	11c53023          	sd	t3,256(a0)
    8000606a:	11d53423          	sd	t4,264(a0)
    8000606e:	11e53823          	sd	t5,272(a0)
    80006072:	11f53c23          	sd	t6,280(a0)
    80006076:	140022f3          	csrr	t0,sscratch
    8000607a:	06553823          	sd	t0,112(a0)
    8000607e:	00853103          	ld	sp,8(a0)
    80006082:	02053203          	ld	tp,32(a0)
    80006086:	01053283          	ld	t0,16(a0)
    8000608a:	00053303          	ld	t1,0(a0)
    8000608e:	12000073          	sfence.vma
    80006092:	18031073          	csrw	satp,t1
    80006096:	12000073          	sfence.vma
    8000609a:	9282                	jalr	t0

000000008000609c <userret>:
    8000609c:	12000073          	sfence.vma
    800060a0:	18051073          	csrw	satp,a0
    800060a4:	12000073          	sfence.vma
    800060a8:	02000537          	lui	a0,0x2000
    800060ac:	357d                	addiw	a0,a0,-1 # 1ffffff <_entry-0x7e000001>
    800060ae:	0536                	slli	a0,a0,0xd
    800060b0:	02853083          	ld	ra,40(a0)
    800060b4:	03053103          	ld	sp,48(a0)
    800060b8:	03853183          	ld	gp,56(a0)
    800060bc:	04053203          	ld	tp,64(a0)
    800060c0:	04853283          	ld	t0,72(a0)
    800060c4:	05053303          	ld	t1,80(a0)
    800060c8:	05853383          	ld	t2,88(a0)
    800060cc:	7120                	ld	s0,96(a0)
    800060ce:	7524                	ld	s1,104(a0)
    800060d0:	7d2c                	ld	a1,120(a0)
    800060d2:	6150                	ld	a2,128(a0)
    800060d4:	6554                	ld	a3,136(a0)
    800060d6:	6958                	ld	a4,144(a0)
    800060d8:	6d5c                	ld	a5,152(a0)
    800060da:	0a053803          	ld	a6,160(a0)
    800060de:	0a853883          	ld	a7,168(a0)
    800060e2:	0b053903          	ld	s2,176(a0)
    800060e6:	0b853983          	ld	s3,184(a0)
    800060ea:	0c053a03          	ld	s4,192(a0)
    800060ee:	0c853a83          	ld	s5,200(a0)
    800060f2:	0d053b03          	ld	s6,208(a0)
    800060f6:	0d853b83          	ld	s7,216(a0)
    800060fa:	0e053c03          	ld	s8,224(a0)
    800060fe:	0e853c83          	ld	s9,232(a0)
    80006102:	0f053d03          	ld	s10,240(a0)
    80006106:	0f853d83          	ld	s11,248(a0)
    8000610a:	10053e03          	ld	t3,256(a0)
    8000610e:	10853e83          	ld	t4,264(a0)
    80006112:	11053f03          	ld	t5,272(a0)
    80006116:	11853f83          	ld	t6,280(a0)
    8000611a:	7928                	ld	a0,112(a0)
    8000611c:	10200073          	sret
	...
