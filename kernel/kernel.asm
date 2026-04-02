
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
_entry:
        # set up a stack for C.
        # stack0 is declared in start.c,
        # with a 4096-byte stack per CPU.
        # sp = stack0 + ((hartid + 1) * 4096)
        la sp, stack0
    80000000:	0000b117          	auipc	sp,0xb
    80000004:	62813103          	ld	sp,1576(sp) # 8000b628 <_GLOBAL_OFFSET_TABLE_+0x8>
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
    80000072:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffc1d8f>
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
    800000ea:	00013517          	auipc	a0,0x13
    800000ee:	5a650513          	addi	a0,a0,1446 # 80013690 <conswlock>
    800000f2:	092040ef          	jal	80004184 <acquiresleep>

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
    80000126:	3ba020ef          	jal	800024e0 <either_copyin>
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
    8000016a:	00013517          	auipc	a0,0x13
    8000016e:	52650513          	addi	a0,a0,1318 # 80013690 <conswlock>
    80000172:	058040ef          	jal	800041ca <releasesleep>
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
    800001a6:	00013517          	auipc	a0,0x13
    800001aa:	51a50513          	addi	a0,a0,1306 # 800136c0 <cons>
    800001ae:	2ad000ef          	jal	80000c5a <acquire>

  while(n > 0){
    while(cons.r == cons.w){
    800001b2:	00013497          	auipc	s1,0x13
    800001b6:	4de48493          	addi	s1,s1,1246 # 80013690 <conswlock>
      if(killed(myproc())){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    800001ba:	00013997          	auipc	s3,0x13
    800001be:	50698993          	addi	s3,s3,1286 # 800136c0 <cons>
    800001c2:	00013917          	auipc	s2,0x13
    800001c6:	59690913          	addi	s2,s2,1430 # 80013758 <cons+0x98>
  while(n > 0){
    800001ca:	0b405c63          	blez	s4,80000282 <consoleread+0xfa>
    while(cons.r == cons.w){
    800001ce:	0c84a783          	lw	a5,200(s1)
    800001d2:	0cc4a703          	lw	a4,204(s1)
    800001d6:	0af71163          	bne	a4,a5,80000278 <consoleread+0xf0>
      if(killed(myproc())){
    800001da:	7a2010ef          	jal	8000197c <myproc>
    800001de:	19a020ef          	jal	80002378 <killed>
    800001e2:	e12d                	bnez	a0,80000244 <consoleread+0xbc>
      sleep(&cons.r, &cons.lock);
    800001e4:	85ce                	mv	a1,s3
    800001e6:	854a                	mv	a0,s2
    800001e8:	755010ef          	jal	8000213c <sleep>
    while(cons.r == cons.w){
    800001ec:	0c84a783          	lw	a5,200(s1)
    800001f0:	0cc4a703          	lw	a4,204(s1)
    800001f4:	fef703e3          	beq	a4,a5,800001da <consoleread+0x52>
    800001f8:	f05a                	sd	s6,32(sp)
    }

    c = cons.buf[cons.r++ % INPUT_BUF_SIZE];
    800001fa:	00013717          	auipc	a4,0x13
    800001fe:	49670713          	addi	a4,a4,1174 # 80013690 <conswlock>
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
    8000022c:	26a020ef          	jal	80002496 <either_copyout>
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
    80000244:	00013517          	auipc	a0,0x13
    80000248:	47c50513          	addi	a0,a0,1148 # 800136c0 <cons>
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
    8000026c:	00013717          	auipc	a4,0x13
    80000270:	4ef72623          	sw	a5,1260(a4) # 80013758 <cons+0x98>
    80000274:	7b02                	ld	s6,32(sp)
    80000276:	a031                	j	80000282 <consoleread+0xfa>
    80000278:	f05a                	sd	s6,32(sp)
    8000027a:	b741                	j	800001fa <consoleread+0x72>
    8000027c:	7b02                	ld	s6,32(sp)
    8000027e:	a011                	j	80000282 <consoleread+0xfa>
    80000280:	7b02                	ld	s6,32(sp)
  release(&cons.lock);
    80000282:	00013517          	auipc	a0,0x13
    80000286:	43e50513          	addi	a0,a0,1086 # 800136c0 <cons>
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
    800002d6:	00013517          	auipc	a0,0x13
    800002da:	3ea50513          	addi	a0,a0,1002 # 800136c0 <cons>
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
    800002f8:	232020ef          	jal	8000252a <procdump>
      }
    }
    break;
  }

  release(&cons.lock);
    800002fc:	00013517          	auipc	a0,0x13
    80000300:	3c450513          	addi	a0,a0,964 # 800136c0 <cons>
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
    8000031a:	00013717          	auipc	a4,0x13
    8000031e:	37670713          	addi	a4,a4,886 # 80013690 <conswlock>
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
    80000340:	00013717          	auipc	a4,0x13
    80000344:	35070713          	addi	a4,a4,848 # 80013690 <conswlock>
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
    8000036a:	00013717          	auipc	a4,0x13
    8000036e:	3ee72703          	lw	a4,1006(a4) # 80013758 <cons+0x98>
    80000372:	9f99                	subw	a5,a5,a4
    80000374:	08000713          	li	a4,128
    80000378:	f8e792e3          	bne	a5,a4,800002fc <consoleintr+0x32>
    8000037c:	a075                	j	80000428 <consoleintr+0x15e>
    8000037e:	e04a                	sd	s2,0(sp)
    while(cons.e != cons.w &&
    80000380:	00013717          	auipc	a4,0x13
    80000384:	31070713          	addi	a4,a4,784 # 80013690 <conswlock>
    80000388:	0d072783          	lw	a5,208(a4)
    8000038c:	0cc72703          	lw	a4,204(a4)
          cons.buf[(cons.e - 1) % INPUT_BUF_SIZE] != '\n'){
    80000390:	00013497          	auipc	s1,0x13
    80000394:	30048493          	addi	s1,s1,768 # 80013690 <conswlock>
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
    800003d2:	00013717          	auipc	a4,0x13
    800003d6:	2be70713          	addi	a4,a4,702 # 80013690 <conswlock>
    800003da:	0d072783          	lw	a5,208(a4)
    800003de:	0cc72703          	lw	a4,204(a4)
    800003e2:	f0f70de3          	beq	a4,a5,800002fc <consoleintr+0x32>
      cons.e--;
    800003e6:	37fd                	addiw	a5,a5,-1
    800003e8:	00013717          	auipc	a4,0x13
    800003ec:	36f72c23          	sw	a5,888(a4) # 80013760 <cons+0xa0>
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
    80000406:	00013797          	auipc	a5,0x13
    8000040a:	28a78793          	addi	a5,a5,650 # 80013690 <conswlock>
    8000040e:	0d07a703          	lw	a4,208(a5)
    80000412:	0017069b          	addiw	a3,a4,1
    80000416:	8636                	mv	a2,a3
    80000418:	0cd7a823          	sw	a3,208(a5)
    8000041c:	07f77713          	andi	a4,a4,127
    80000420:	97ba                	add	a5,a5,a4
    80000422:	4729                	li	a4,10
    80000424:	04e78423          	sb	a4,72(a5)
        cons.w = cons.e;
    80000428:	00013797          	auipc	a5,0x13
    8000042c:	32c7aa23          	sw	a2,820(a5) # 8001375c <cons+0x9c>
        wakeup(&cons.r);
    80000430:	00013517          	auipc	a0,0x13
    80000434:	32850513          	addi	a0,a0,808 # 80013758 <cons+0x98>
    80000438:	551010ef          	jal	80002188 <wakeup>
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
    8000044e:	00013517          	auipc	a0,0x13
    80000452:	27250513          	addi	a0,a0,626 # 800136c0 <cons>
    80000456:	77a000ef          	jal	80000bd0 <initlock>
  initsleeplock(&conswlock, "consw");
    8000045a:	00008597          	auipc	a1,0x8
    8000045e:	bb658593          	addi	a1,a1,-1098 # 80008010 <etext+0x10>
    80000462:	00013517          	auipc	a0,0x13
    80000466:	22e50513          	addi	a0,a0,558 # 80013690 <conswlock>
    8000046a:	4e5030ef          	jal	8000414e <initsleeplock>

  uartinit();
    8000046e:	448000ef          	jal	800008b6 <uartinit>

  devsw[CONSOLE].read = consoleread;
    80000472:	00023797          	auipc	a5,0x23
    80000476:	3d678793          	addi	a5,a5,982 # 80023848 <devsw>
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
    800004b4:	2d080813          	addi	a6,a6,720 # 80008780 <digits>
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
    8000054a:	0000b797          	auipc	a5,0xb
    8000054e:	0fa7a783          	lw	a5,250(a5) # 8000b644 <panicking>
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
    80000590:	00013517          	auipc	a0,0x13
    80000594:	1d850513          	addi	a0,a0,472 # 80013768 <pr>
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
    80000704:	00008c97          	auipc	s9,0x8
    80000708:	07cc8c93          	addi	s9,s9,124 # 80008780 <digits>
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
    8000078c:	0000b797          	auipc	a5,0xb
    80000790:	eb87a783          	lw	a5,-328(a5) # 8000b644 <panicking>
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
    800007b6:	00013517          	auipc	a0,0x13
    800007ba:	fb250513          	addi	a0,a0,-78 # 80013768 <pr>
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
    80000866:	0000b797          	auipc	a5,0xb
    8000086a:	dc97af23          	sw	s1,-546(a5) # 8000b644 <panicking>
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
    80000888:	0000b797          	auipc	a5,0xb
    8000088c:	da97ac23          	sw	s1,-584(a5) # 8000b640 <panicked>
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
    800008a2:	00013517          	auipc	a0,0x13
    800008a6:	ec650513          	addi	a0,a0,-314 # 80013768 <pr>
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
    800008f0:	00007597          	auipc	a1,0x7
    800008f4:	74858593          	addi	a1,a1,1864 # 80008038 <etext+0x38>
    800008f8:	00013517          	auipc	a0,0x13
    800008fc:	e8850513          	addi	a0,a0,-376 # 80013780 <tx_lock>
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
    8000091c:	00013517          	auipc	a0,0x13
    80000920:	e6450513          	addi	a0,a0,-412 # 80013780 <tx_lock>
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
    8000093a:	0000b497          	auipc	s1,0xb
    8000093e:	d1248493          	addi	s1,s1,-750 # 8000b64c <tx_busy>
      // wait for a UART transmit-complete interrupt
      // to set tx_busy to 0.
      sleep(&tx_chan, &tx_lock);
    80000942:	00013997          	auipc	s3,0x13
    80000946:	e3e98993          	addi	s3,s3,-450 # 80013780 <tx_lock>
    8000094a:	0000b917          	auipc	s2,0xb
    8000094e:	cfe90913          	addi	s2,s2,-770 # 8000b648 <tx_chan>
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
    8000095e:	7de010ef          	jal	8000213c <sleep>
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
    80000988:	00013517          	auipc	a0,0x13
    8000098c:	df850513          	addi	a0,a0,-520 # 80013780 <tx_lock>
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
    800009ac:	0000b797          	auipc	a5,0xb
    800009b0:	c987a783          	lw	a5,-872(a5) # 8000b644 <panicking>
    800009b4:	cf95                	beqz	a5,800009f0 <uartputc_sync+0x50>
    push_off();

  if(panicked){
    800009b6:	0000b797          	auipc	a5,0xb
    800009ba:	c8a7a783          	lw	a5,-886(a5) # 8000b640 <panicked>
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
    800009dc:	0000b797          	auipc	a5,0xb
    800009e0:	c687a783          	lw	a5,-920(a5) # 8000b644 <panicking>
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
    80000a38:	00013517          	auipc	a0,0x13
    80000a3c:	d4850513          	addi	a0,a0,-696 # 80013780 <tx_lock>
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
    80000a52:	00013517          	auipc	a0,0x13
    80000a56:	d2e50513          	addi	a0,a0,-722 # 80013780 <tx_lock>
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
    80000a6e:	0000b797          	auipc	a5,0xb
    80000a72:	bc07af23          	sw	zero,-1058(a5) # 8000b64c <tx_busy>
    wakeup(&tx_chan);
    80000a76:	0000b517          	auipc	a0,0xb
    80000a7a:	bd250513          	addi	a0,a0,-1070 # 8000b648 <tx_chan>
    80000a7e:	70a010ef          	jal	80002188 <wakeup>
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
    80000a9a:	0003c797          	auipc	a5,0x3c
    80000a9e:	fd678793          	addi	a5,a5,-42 # 8003ca70 <end>
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
    80000ac4:	00013917          	auipc	s2,0x13
    80000ac8:	cd490913          	addi	s2,s2,-812 # 80013798 <kmem>
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
    80000aee:	00007517          	auipc	a0,0x7
    80000af2:	55250513          	addi	a0,a0,1362 # 80008040 <etext+0x40>
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
    80000b4a:	00007597          	auipc	a1,0x7
    80000b4e:	4fe58593          	addi	a1,a1,1278 # 80008048 <etext+0x48>
    80000b52:	00013517          	auipc	a0,0x13
    80000b56:	c4650513          	addi	a0,a0,-954 # 80013798 <kmem>
    80000b5a:	076000ef          	jal	80000bd0 <initlock>
  freerange(end, (void*)PHYSTOP);
    80000b5e:	45c5                	li	a1,17
    80000b60:	05ee                	slli	a1,a1,0x1b
    80000b62:	0003c517          	auipc	a0,0x3c
    80000b66:	f0e50513          	addi	a0,a0,-242 # 8003ca70 <end>
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
    80000b80:	00013517          	auipc	a0,0x13
    80000b84:	c1850513          	addi	a0,a0,-1000 # 80013798 <kmem>
    80000b88:	0d2000ef          	jal	80000c5a <acquire>
  r = kmem.freelist;
    80000b8c:	00013497          	auipc	s1,0x13
    80000b90:	c244b483          	ld	s1,-988(s1) # 800137b0 <kmem+0x18>
  if(r)
    80000b94:	c49d                	beqz	s1,80000bc2 <kalloc+0x4c>
    kmem.freelist = r->next;
    80000b96:	609c                	ld	a5,0(s1)
    80000b98:	00013717          	auipc	a4,0x13
    80000b9c:	c0f73c23          	sd	a5,-1000(a4) # 800137b0 <kmem+0x18>
  release(&kmem.lock);
    80000ba0:	00013517          	auipc	a0,0x13
    80000ba4:	bf850513          	addi	a0,a0,-1032 # 80013798 <kmem>
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
    80000bc2:	00013517          	auipc	a0,0x13
    80000bc6:	bd650513          	addi	a0,a0,-1066 # 80013798 <kmem>
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
    80000c00:	55d000ef          	jal	8000195c <mycpu>
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
    80000c30:	52d000ef          	jal	8000195c <mycpu>
    80000c34:	5d3c                	lw	a5,120(a0)
    80000c36:	cb99                	beqz	a5,80000c4c <push_off+0x36>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000c38:	525000ef          	jal	8000195c <mycpu>
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
    80000c4c:	511000ef          	jal	8000195c <mycpu>
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
    80000c82:	4db000ef          	jal	8000195c <mycpu>
    80000c86:	e888                	sd	a0,16(s1)
}
    80000c88:	60e2                	ld	ra,24(sp)
    80000c8a:	6442                	ld	s0,16(sp)
    80000c8c:	64a2                	ld	s1,8(sp)
    80000c8e:	6105                	addi	sp,sp,32
    80000c90:	8082                	ret
    panic("acquire");
    80000c92:	00007517          	auipc	a0,0x7
    80000c96:	3be50513          	addi	a0,a0,958 # 80008050 <etext+0x50>
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
    80000ca6:	4b7000ef          	jal	8000195c <mycpu>
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
    80000cd6:	00007517          	auipc	a0,0x7
    80000cda:	38250513          	addi	a0,a0,898 # 80008058 <etext+0x58>
    80000cde:	b79ff0ef          	jal	80000856 <panic>
    panic("pop_off");
    80000ce2:	00007517          	auipc	a0,0x7
    80000ce6:	38e50513          	addi	a0,a0,910 # 80008070 <etext+0x70>
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
    80000d1e:	00007517          	auipc	a0,0x7
    80000d22:	35a50513          	addi	a0,a0,858 # 80008078 <etext+0x78>
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
    80000ee8:	261000ef          	jal	80001948 <cpuid>
    cslog_init();
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    80000eec:	0000a717          	auipc	a4,0xa
    80000ef0:	76470713          	addi	a4,a4,1892 # 8000b650 <started>
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
    80000f00:	249000ef          	jal	80001948 <cpuid>
    80000f04:	85aa                	mv	a1,a0
    80000f06:	00007517          	auipc	a0,0x7
    80000f0a:	19a50513          	addi	a0,a0,410 # 800080a0 <etext+0xa0>
    80000f0e:	e1eff0ef          	jal	8000052c <printf>
    kvminithart();    // turn on paging
    80000f12:	088000ef          	jal	80000f9a <kvminithart>
    trapinithart();   // install kernel trap vector
    80000f16:	746010ef          	jal	8000265c <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000f1a:	06f040ef          	jal	80005788 <plicinithart>
  }

  scheduler();        
    80000f1e:	6d5000ef          	jal	80001df2 <scheduler>
    consoleinit();
    80000f22:	d1cff0ef          	jal	8000043e <consoleinit>
    printfinit();
    80000f26:	96dff0ef          	jal	80000892 <printfinit>
    printf("\n");
    80000f2a:	00007517          	auipc	a0,0x7
    80000f2e:	15650513          	addi	a0,a0,342 # 80008080 <etext+0x80>
    80000f32:	dfaff0ef          	jal	8000052c <printf>
    printf("xv6 kernel is booting\n");
    80000f36:	00007517          	auipc	a0,0x7
    80000f3a:	15250513          	addi	a0,a0,338 # 80008088 <etext+0x88>
    80000f3e:	deeff0ef          	jal	8000052c <printf>
    printf("\n");
    80000f42:	00007517          	auipc	a0,0x7
    80000f46:	13e50513          	addi	a0,a0,318 # 80008080 <etext+0x80>
    80000f4a:	de2ff0ef          	jal	8000052c <printf>
    kinit();         // physical page allocator
    80000f4e:	bf5ff0ef          	jal	80000b42 <kinit>
    kvminit();       // create kernel page table
    80000f52:	2d4000ef          	jal	80001226 <kvminit>
    kvminithart();   // turn on paging
    80000f56:	044000ef          	jal	80000f9a <kvminithart>
    procinit();      // process table
    80000f5a:	125000ef          	jal	8000187e <procinit>
    schedlog_init();
    80000f5e:	22a050ef          	jal	80006188 <schedlog_init>
    trapinit();      // trap vectors
    80000f62:	6d6010ef          	jal	80002638 <trapinit>
    trapinithart();  // install kernel trap vector
    80000f66:	6f6010ef          	jal	8000265c <trapinithart>
    plicinit();      // set up interrupt controller
    80000f6a:	005040ef          	jal	8000576e <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000f6e:	01b040ef          	jal	80005788 <plicinithart>
    binit();         // buffer cache
    80000f72:	617010ef          	jal	80002d88 <binit>
    iinit();         // inode table
    80000f76:	3a6020ef          	jal	8000331c <iinit>
    fileinit();      // file table
    80000f7a:	2d2030ef          	jal	8000424c <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000f7e:	0fb040ef          	jal	80005878 <virtio_disk_init>
    cslog_init();
    80000f82:	57d040ef          	jal	80005cfe <cslog_init>
    userinit();      // first user process
    80000f86:	4c1000ef          	jal	80001c46 <userinit>
    __sync_synchronize();
    80000f8a:	0330000f          	fence	rw,rw
    started = 1;
    80000f8e:	4785                	li	a5,1
    80000f90:	0000a717          	auipc	a4,0xa
    80000f94:	6cf72023          	sw	a5,1728(a4) # 8000b650 <started>
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
    80000fa6:	0000a797          	auipc	a5,0xa
    80000faa:	6b27b783          	ld	a5,1714(a5) # 8000b658 <kernel_pagetable>
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
    8000102c:	00007517          	auipc	a0,0x7
    80001030:	08c50513          	addi	a0,a0,140 # 800080b8 <etext+0xb8>
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
    80001104:	00007517          	auipc	a0,0x7
    80001108:	fbc50513          	addi	a0,a0,-68 # 800080c0 <etext+0xc0>
    8000110c:	f4aff0ef          	jal	80000856 <panic>
    panic("mappages: size not aligned");
    80001110:	00007517          	auipc	a0,0x7
    80001114:	fd050513          	addi	a0,a0,-48 # 800080e0 <etext+0xe0>
    80001118:	f3eff0ef          	jal	80000856 <panic>
    panic("mappages: size");
    8000111c:	00007517          	auipc	a0,0x7
    80001120:	fe450513          	addi	a0,a0,-28 # 80008100 <etext+0x100>
    80001124:	f32ff0ef          	jal	80000856 <panic>
      panic("mappages: remap");
    80001128:	00007517          	auipc	a0,0x7
    8000112c:	fe850513          	addi	a0,a0,-24 # 80008110 <etext+0x110>
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
    8000116c:	00007517          	auipc	a0,0x7
    80001170:	fb450513          	addi	a0,a0,-76 # 80008120 <etext+0x120>
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
    800011c4:	80007697          	auipc	a3,0x80007
    800011c8:	e3c68693          	addi	a3,a3,-452 # 8000 <_entry-0x7fff8000>
    800011cc:	4605                	li	a2,1
    800011ce:	067e                	slli	a2,a2,0x1f
    800011d0:	85b2                	mv	a1,a2
    800011d2:	8526                	mv	a0,s1
    800011d4:	f7dff0ef          	jal	80001150 <kvmmap>
  kvmmap(kpgtbl, (uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    800011d8:	4719                	li	a4,6
    800011da:	00007697          	auipc	a3,0x7
    800011de:	e2668693          	addi	a3,a3,-474 # 80008000 <etext>
    800011e2:	47c5                	li	a5,17
    800011e4:	07ee                	slli	a5,a5,0x1b
    800011e6:	40d786b3          	sub	a3,a5,a3
    800011ea:	00007617          	auipc	a2,0x7
    800011ee:	e1660613          	addi	a2,a2,-490 # 80008000 <etext>
    800011f2:	85b2                	mv	a1,a2
    800011f4:	8526                	mv	a0,s1
    800011f6:	f5bff0ef          	jal	80001150 <kvmmap>
  kvmmap(kpgtbl, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    800011fa:	4729                	li	a4,10
    800011fc:	6685                	lui	a3,0x1
    800011fe:	00006617          	auipc	a2,0x6
    80001202:	e0260613          	addi	a2,a2,-510 # 80007000 <_trampoline>
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
    80001232:	0000a797          	auipc	a5,0xa
    80001236:	42a7b323          	sd	a0,1062(a5) # 8000b658 <kernel_pagetable>
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
    800012a2:	00007517          	auipc	a0,0x7
    800012a6:	e8650513          	addi	a0,a0,-378 # 80008128 <etext+0x128>
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
    800013f8:	00007517          	auipc	a0,0x7
    800013fc:	d4850513          	addi	a0,a0,-696 # 80008140 <etext+0x140>
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
    80001526:	00007517          	auipc	a0,0x7
    8000152a:	c2a50513          	addi	a0,a0,-982 # 80008150 <etext+0x150>
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
    8000161a:	362000ef          	jal	8000197c <myproc>
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
    800017f4:	00012497          	auipc	s1,0x12
    800017f8:	40c48493          	addi	s1,s1,1036 # 80013c00 <proc>
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
    80001824:	00018a97          	auipc	s5,0x18
    80001828:	ddca8a93          	addi	s5,s5,-548 # 80019600 <tickslock>
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
    80001872:	00007517          	auipc	a0,0x7
    80001876:	8ee50513          	addi	a0,a0,-1810 # 80008160 <etext+0x160>
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
    80001892:	00007597          	auipc	a1,0x7
    80001896:	8d658593          	addi	a1,a1,-1834 # 80008168 <etext+0x168>
    8000189a:	00012517          	auipc	a0,0x12
    8000189e:	f1e50513          	addi	a0,a0,-226 # 800137b8 <pid_lock>
    800018a2:	b2eff0ef          	jal	80000bd0 <initlock>
  initlock(&wait_lock, "wait_lock");
    800018a6:	00007597          	auipc	a1,0x7
    800018aa:	8ca58593          	addi	a1,a1,-1846 # 80008170 <etext+0x170>
    800018ae:	00012517          	auipc	a0,0x12
    800018b2:	f2250513          	addi	a0,a0,-222 # 800137d0 <wait_lock>
    800018b6:	b1aff0ef          	jal	80000bd0 <initlock>
  initlock(&schedinfo_lock, "schedinfo");
    800018ba:	00007597          	auipc	a1,0x7
    800018be:	8c658593          	addi	a1,a1,-1850 # 80008180 <etext+0x180>
    800018c2:	00012517          	auipc	a0,0x12
    800018c6:	f2650513          	addi	a0,a0,-218 # 800137e8 <schedinfo_lock>
    800018ca:	b06ff0ef          	jal	80000bd0 <initlock>
  for (p = proc; p < &proc[NPROC]; p++) {
    800018ce:	00012497          	auipc	s1,0x12
    800018d2:	33248493          	addi	s1,s1,818 # 80013c00 <proc>
    initlock(&p->lock, "proc");
    800018d6:	00007b17          	auipc	s6,0x7
    800018da:	8bab0b13          	addi	s6,s6,-1862 # 80008190 <etext+0x190>
    p->state = UNUSED;
    p->kstack = KSTACK((int)(p - proc));
    800018de:	8aa6                	mv	s5,s1
    800018e0:	000a57b7          	lui	a5,0xa5
    800018e4:	fa578793          	addi	a5,a5,-91 # a4fa5 <_entry-0x7ff5b05b>
    800018e8:	07b2                	slli	a5,a5,0xc
    800018ea:	fa578793          	addi	a5,a5,-91
    800018ee:	4fa50937          	lui	s2,0x4fa50
    800018f2:	a4f90913          	addi	s2,s2,-1457 # 4fa4fa4f <_entry-0x305b05b1>
    800018f6:	1902                	slli	s2,s2,0x20
    800018f8:	993e                	add	s2,s2,a5
    800018fa:	040009b7          	lui	s3,0x4000
    800018fe:	19fd                	addi	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    80001900:	09b2                	slli	s3,s3,0xc
  for (p = proc; p < &proc[NPROC]; p++) {
    80001902:	00018a17          	auipc	s4,0x18
    80001906:	cfea0a13          	addi	s4,s4,-770 # 80019600 <tickslock>
    initlock(&p->lock, "proc");
    8000190a:	85da                	mv	a1,s6
    8000190c:	8526                	mv	a0,s1
    8000190e:	ac2ff0ef          	jal	80000bd0 <initlock>
    p->state = UNUSED;
    80001912:	0004ac23          	sw	zero,24(s1)
    p->kstack = KSTACK((int)(p - proc));
    80001916:	415487b3          	sub	a5,s1,s5
    8000191a:	878d                	srai	a5,a5,0x3
    8000191c:	032787b3          	mul	a5,a5,s2
    80001920:	07b6                	slli	a5,a5,0xd
    80001922:	6709                	lui	a4,0x2
    80001924:	9fb9                	addw	a5,a5,a4
    80001926:	40f987b3          	sub	a5,s3,a5
    8000192a:	e0bc                	sd	a5,64(s1)
  for (p = proc; p < &proc[NPROC]; p++) {
    8000192c:	16848493          	addi	s1,s1,360
    80001930:	fd449de3          	bne	s1,s4,8000190a <procinit+0x8c>
  }
}
    80001934:	70e2                	ld	ra,56(sp)
    80001936:	7442                	ld	s0,48(sp)
    80001938:	74a2                	ld	s1,40(sp)
    8000193a:	7902                	ld	s2,32(sp)
    8000193c:	69e2                	ld	s3,24(sp)
    8000193e:	6a42                	ld	s4,16(sp)
    80001940:	6aa2                	ld	s5,8(sp)
    80001942:	6b02                	ld	s6,0(sp)
    80001944:	6121                	addi	sp,sp,64
    80001946:	8082                	ret

0000000080001948 <cpuid>:

// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int cpuid() {
    80001948:	1141                	addi	sp,sp,-16
    8000194a:	e406                	sd	ra,8(sp)
    8000194c:	e022                	sd	s0,0(sp)
    8000194e:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    80001950:	8512                	mv	a0,tp
  int id = r_tp();
  return id;
}
    80001952:	2501                	sext.w	a0,a0
    80001954:	60a2                	ld	ra,8(sp)
    80001956:	6402                	ld	s0,0(sp)
    80001958:	0141                	addi	sp,sp,16
    8000195a:	8082                	ret

000000008000195c <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu *mycpu(void) {
    8000195c:	1141                	addi	sp,sp,-16
    8000195e:	e406                	sd	ra,8(sp)
    80001960:	e022                	sd	s0,0(sp)
    80001962:	0800                	addi	s0,sp,16
    80001964:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    80001966:	2781                	sext.w	a5,a5
    80001968:	079e                	slli	a5,a5,0x7
  return c;
}
    8000196a:	00012517          	auipc	a0,0x12
    8000196e:	e9650513          	addi	a0,a0,-362 # 80013800 <cpus>
    80001972:	953e                	add	a0,a0,a5
    80001974:	60a2                	ld	ra,8(sp)
    80001976:	6402                	ld	s0,0(sp)
    80001978:	0141                	addi	sp,sp,16
    8000197a:	8082                	ret

000000008000197c <myproc>:

// Return the current struct proc *, or zero if none.
struct proc *myproc(void) {
    8000197c:	1101                	addi	sp,sp,-32
    8000197e:	ec06                	sd	ra,24(sp)
    80001980:	e822                	sd	s0,16(sp)
    80001982:	e426                	sd	s1,8(sp)
    80001984:	1000                	addi	s0,sp,32
  push_off();
    80001986:	a90ff0ef          	jal	80000c16 <push_off>
    8000198a:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    8000198c:	2781                	sext.w	a5,a5
    8000198e:	079e                	slli	a5,a5,0x7
    80001990:	00012717          	auipc	a4,0x12
    80001994:	e2870713          	addi	a4,a4,-472 # 800137b8 <pid_lock>
    80001998:	97ba                	add	a5,a5,a4
    8000199a:	67bc                	ld	a5,72(a5)
    8000199c:	84be                	mv	s1,a5
  pop_off();
    8000199e:	b00ff0ef          	jal	80000c9e <pop_off>
  return p;
}
    800019a2:	8526                	mv	a0,s1
    800019a4:	60e2                	ld	ra,24(sp)
    800019a6:	6442                	ld	s0,16(sp)
    800019a8:	64a2                	ld	s1,8(sp)
    800019aa:	6105                	addi	sp,sp,32
    800019ac:	8082                	ret

00000000800019ae <forkret>:
  release(&p->lock);
}

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void forkret(void) {
    800019ae:	7179                	addi	sp,sp,-48
    800019b0:	f406                	sd	ra,40(sp)
    800019b2:	f022                	sd	s0,32(sp)
    800019b4:	ec26                	sd	s1,24(sp)
    800019b6:	1800                	addi	s0,sp,48
  extern char userret[];
  static int first = 1;
  struct proc *p = myproc();
    800019b8:	fc5ff0ef          	jal	8000197c <myproc>
    800019bc:	84aa                	mv	s1,a0

  // Still holding p->lock from scheduler.
  release(&p->lock);
    800019be:	b30ff0ef          	jal	80000cee <release>

  if (first) {
    800019c2:	0000a797          	auipc	a5,0xa
    800019c6:	c4e7a783          	lw	a5,-946(a5) # 8000b610 <first.1>
    800019ca:	cf95                	beqz	a5,80001a06 <forkret+0x58>
    // File system initialization must be run in the context of a
    // regular process (e.g., because it calls sleep), and thus cannot
    // be run from main().
    fsinit(ROOTDEV);
    800019cc:	4505                	li	a0,1
    800019ce:	60b010ef          	jal	800037d8 <fsinit>

    first = 0;
    800019d2:	0000a797          	auipc	a5,0xa
    800019d6:	c207af23          	sw	zero,-962(a5) # 8000b610 <first.1>
    // ensure other cores see first=0.
    __sync_synchronize();
    800019da:	0330000f          	fence	rw,rw

    // We can invoke kexec() now that file system is initialized.
    // Put the return value (argc) of kexec into a0.
    p->trapframe->a0 = kexec("/init", (char *[]){"/init", 0});
    800019de:	00006797          	auipc	a5,0x6
    800019e2:	7ba78793          	addi	a5,a5,1978 # 80008198 <etext+0x198>
    800019e6:	fcf43823          	sd	a5,-48(s0)
    800019ea:	fc043c23          	sd	zero,-40(s0)
    800019ee:	fd040593          	addi	a1,s0,-48
    800019f2:	853e                	mv	a0,a5
    800019f4:	76d020ef          	jal	80004960 <kexec>
    800019f8:	6cbc                	ld	a5,88(s1)
    800019fa:	fba8                	sd	a0,112(a5)
    if (p->trapframe->a0 == -1) {
    800019fc:	6cbc                	ld	a5,88(s1)
    800019fe:	7bb8                	ld	a4,112(a5)
    80001a00:	57fd                	li	a5,-1
    80001a02:	02f70d63          	beq	a4,a5,80001a3c <forkret+0x8e>
      panic("exec");
    }
  }

  // return to user space, mimicing usertrap()'s return.
  prepare_return();
    80001a06:	473000ef          	jal	80002678 <prepare_return>
  uint64 satp = MAKE_SATP(p->pagetable);
    80001a0a:	68a8                	ld	a0,80(s1)
    80001a0c:	8131                	srli	a0,a0,0xc
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    80001a0e:	04000737          	lui	a4,0x4000
    80001a12:	177d                	addi	a4,a4,-1 # 3ffffff <_entry-0x7c000001>
    80001a14:	0732                	slli	a4,a4,0xc
    80001a16:	00005797          	auipc	a5,0x5
    80001a1a:	68678793          	addi	a5,a5,1670 # 8000709c <userret>
    80001a1e:	00005697          	auipc	a3,0x5
    80001a22:	5e268693          	addi	a3,a3,1506 # 80007000 <_trampoline>
    80001a26:	8f95                	sub	a5,a5,a3
    80001a28:	97ba                	add	a5,a5,a4
  ((void (*)(uint64))trampoline_userret)(satp);
    80001a2a:	577d                	li	a4,-1
    80001a2c:	177e                	slli	a4,a4,0x3f
    80001a2e:	8d59                	or	a0,a0,a4
    80001a30:	9782                	jalr	a5
}
    80001a32:	70a2                	ld	ra,40(sp)
    80001a34:	7402                	ld	s0,32(sp)
    80001a36:	64e2                	ld	s1,24(sp)
    80001a38:	6145                	addi	sp,sp,48
    80001a3a:	8082                	ret
      panic("exec");
    80001a3c:	00006517          	auipc	a0,0x6
    80001a40:	76450513          	addi	a0,a0,1892 # 800081a0 <etext+0x1a0>
    80001a44:	e13fe0ef          	jal	80000856 <panic>

0000000080001a48 <allocpid>:
int allocpid() {
    80001a48:	1101                	addi	sp,sp,-32
    80001a4a:	ec06                	sd	ra,24(sp)
    80001a4c:	e822                	sd	s0,16(sp)
    80001a4e:	e426                	sd	s1,8(sp)
    80001a50:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80001a52:	00012517          	auipc	a0,0x12
    80001a56:	d6650513          	addi	a0,a0,-666 # 800137b8 <pid_lock>
    80001a5a:	a00ff0ef          	jal	80000c5a <acquire>
  pid = nextpid;
    80001a5e:	0000a797          	auipc	a5,0xa
    80001a62:	bb678793          	addi	a5,a5,-1098 # 8000b614 <nextpid>
    80001a66:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80001a68:	0014871b          	addiw	a4,s1,1
    80001a6c:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001a6e:	00012517          	auipc	a0,0x12
    80001a72:	d4a50513          	addi	a0,a0,-694 # 800137b8 <pid_lock>
    80001a76:	a78ff0ef          	jal	80000cee <release>
}
    80001a7a:	8526                	mv	a0,s1
    80001a7c:	60e2                	ld	ra,24(sp)
    80001a7e:	6442                	ld	s0,16(sp)
    80001a80:	64a2                	ld	s1,8(sp)
    80001a82:	6105                	addi	sp,sp,32
    80001a84:	8082                	ret

0000000080001a86 <proc_pagetable>:
pagetable_t proc_pagetable(struct proc *p) {
    80001a86:	1101                	addi	sp,sp,-32
    80001a88:	ec06                	sd	ra,24(sp)
    80001a8a:	e822                	sd	s0,16(sp)
    80001a8c:	e426                	sd	s1,8(sp)
    80001a8e:	e04a                	sd	s2,0(sp)
    80001a90:	1000                	addi	s0,sp,32
    80001a92:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001a94:	faeff0ef          	jal	80001242 <uvmcreate>
    80001a98:	84aa                	mv	s1,a0
  if (pagetable == 0)
    80001a9a:	cd05                	beqz	a0,80001ad2 <proc_pagetable+0x4c>
  if (mappages(pagetable, TRAMPOLINE, PGSIZE, (uint64)trampoline,
    80001a9c:	4729                	li	a4,10
    80001a9e:	00005697          	auipc	a3,0x5
    80001aa2:	56268693          	addi	a3,a3,1378 # 80007000 <_trampoline>
    80001aa6:	6605                	lui	a2,0x1
    80001aa8:	040005b7          	lui	a1,0x4000
    80001aac:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001aae:	05b2                	slli	a1,a1,0xc
    80001ab0:	deaff0ef          	jal	8000109a <mappages>
    80001ab4:	02054663          	bltz	a0,80001ae0 <proc_pagetable+0x5a>
  if (mappages(pagetable, TRAPFRAME, PGSIZE, (uint64)(p->trapframe),
    80001ab8:	4719                	li	a4,6
    80001aba:	05893683          	ld	a3,88(s2)
    80001abe:	6605                	lui	a2,0x1
    80001ac0:	020005b7          	lui	a1,0x2000
    80001ac4:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001ac6:	05b6                	slli	a1,a1,0xd
    80001ac8:	8526                	mv	a0,s1
    80001aca:	dd0ff0ef          	jal	8000109a <mappages>
    80001ace:	00054f63          	bltz	a0,80001aec <proc_pagetable+0x66>
}
    80001ad2:	8526                	mv	a0,s1
    80001ad4:	60e2                	ld	ra,24(sp)
    80001ad6:	6442                	ld	s0,16(sp)
    80001ad8:	64a2                	ld	s1,8(sp)
    80001ada:	6902                	ld	s2,0(sp)
    80001adc:	6105                	addi	sp,sp,32
    80001ade:	8082                	ret
    uvmfree(pagetable, 0);
    80001ae0:	4581                	li	a1,0
    80001ae2:	8526                	mv	a0,s1
    80001ae4:	959ff0ef          	jal	8000143c <uvmfree>
    return 0;
    80001ae8:	4481                	li	s1,0
    80001aea:	b7e5                	j	80001ad2 <proc_pagetable+0x4c>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001aec:	4681                	li	a3,0
    80001aee:	4605                	li	a2,1
    80001af0:	040005b7          	lui	a1,0x4000
    80001af4:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001af6:	05b2                	slli	a1,a1,0xc
    80001af8:	8526                	mv	a0,s1
    80001afa:	f6eff0ef          	jal	80001268 <uvmunmap>
    uvmfree(pagetable, 0);
    80001afe:	4581                	li	a1,0
    80001b00:	8526                	mv	a0,s1
    80001b02:	93bff0ef          	jal	8000143c <uvmfree>
    return 0;
    80001b06:	4481                	li	s1,0
    80001b08:	b7e9                	j	80001ad2 <proc_pagetable+0x4c>

0000000080001b0a <proc_freepagetable>:
void proc_freepagetable(pagetable_t pagetable, uint64 sz) {
    80001b0a:	1101                	addi	sp,sp,-32
    80001b0c:	ec06                	sd	ra,24(sp)
    80001b0e:	e822                	sd	s0,16(sp)
    80001b10:	e426                	sd	s1,8(sp)
    80001b12:	e04a                	sd	s2,0(sp)
    80001b14:	1000                	addi	s0,sp,32
    80001b16:	84aa                	mv	s1,a0
    80001b18:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001b1a:	4681                	li	a3,0
    80001b1c:	4605                	li	a2,1
    80001b1e:	040005b7          	lui	a1,0x4000
    80001b22:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001b24:	05b2                	slli	a1,a1,0xc
    80001b26:	f42ff0ef          	jal	80001268 <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001b2a:	4681                	li	a3,0
    80001b2c:	4605                	li	a2,1
    80001b2e:	020005b7          	lui	a1,0x2000
    80001b32:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001b34:	05b6                	slli	a1,a1,0xd
    80001b36:	8526                	mv	a0,s1
    80001b38:	f30ff0ef          	jal	80001268 <uvmunmap>
  uvmfree(pagetable, sz);
    80001b3c:	85ca                	mv	a1,s2
    80001b3e:	8526                	mv	a0,s1
    80001b40:	8fdff0ef          	jal	8000143c <uvmfree>
}
    80001b44:	60e2                	ld	ra,24(sp)
    80001b46:	6442                	ld	s0,16(sp)
    80001b48:	64a2                	ld	s1,8(sp)
    80001b4a:	6902                	ld	s2,0(sp)
    80001b4c:	6105                	addi	sp,sp,32
    80001b4e:	8082                	ret

0000000080001b50 <freeproc>:
static void freeproc(struct proc *p) {
    80001b50:	1101                	addi	sp,sp,-32
    80001b52:	ec06                	sd	ra,24(sp)
    80001b54:	e822                	sd	s0,16(sp)
    80001b56:	e426                	sd	s1,8(sp)
    80001b58:	1000                	addi	s0,sp,32
    80001b5a:	84aa                	mv	s1,a0
  if (p->trapframe)
    80001b5c:	6d28                	ld	a0,88(a0)
    80001b5e:	c119                	beqz	a0,80001b64 <freeproc+0x14>
    kfree((void *)p->trapframe);
    80001b60:	f2ffe0ef          	jal	80000a8e <kfree>
  p->trapframe = 0;
    80001b64:	0404bc23          	sd	zero,88(s1)
  if (p->pagetable)
    80001b68:	68a8                	ld	a0,80(s1)
    80001b6a:	c501                	beqz	a0,80001b72 <freeproc+0x22>
    proc_freepagetable(p->pagetable, p->sz);
    80001b6c:	64ac                	ld	a1,72(s1)
    80001b6e:	f9dff0ef          	jal	80001b0a <proc_freepagetable>
  p->pagetable = 0;
    80001b72:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    80001b76:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    80001b7a:	0204a823          	sw	zero,48(s1)
  p->parent = 0;
    80001b7e:	0204bc23          	sd	zero,56(s1)
  p->name[0] = 0;
    80001b82:	14048c23          	sb	zero,344(s1)
  p->chan = 0;
    80001b86:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    80001b8a:	0204a423          	sw	zero,40(s1)
  p->xstate = 0;
    80001b8e:	0204a623          	sw	zero,44(s1)
  p->state = UNUSED;
    80001b92:	0004ac23          	sw	zero,24(s1)
}
    80001b96:	60e2                	ld	ra,24(sp)
    80001b98:	6442                	ld	s0,16(sp)
    80001b9a:	64a2                	ld	s1,8(sp)
    80001b9c:	6105                	addi	sp,sp,32
    80001b9e:	8082                	ret

0000000080001ba0 <allocproc>:
static struct proc *allocproc(void) {
    80001ba0:	1101                	addi	sp,sp,-32
    80001ba2:	ec06                	sd	ra,24(sp)
    80001ba4:	e822                	sd	s0,16(sp)
    80001ba6:	e426                	sd	s1,8(sp)
    80001ba8:	e04a                	sd	s2,0(sp)
    80001baa:	1000                	addi	s0,sp,32
  for (p = proc; p < &proc[NPROC]; p++) {
    80001bac:	00012497          	auipc	s1,0x12
    80001bb0:	05448493          	addi	s1,s1,84 # 80013c00 <proc>
    80001bb4:	00018917          	auipc	s2,0x18
    80001bb8:	a4c90913          	addi	s2,s2,-1460 # 80019600 <tickslock>
    acquire(&p->lock);
    80001bbc:	8526                	mv	a0,s1
    80001bbe:	89cff0ef          	jal	80000c5a <acquire>
    if (p->state == UNUSED) {
    80001bc2:	4c9c                	lw	a5,24(s1)
    80001bc4:	cb91                	beqz	a5,80001bd8 <allocproc+0x38>
      release(&p->lock);
    80001bc6:	8526                	mv	a0,s1
    80001bc8:	926ff0ef          	jal	80000cee <release>
  for (p = proc; p < &proc[NPROC]; p++) {
    80001bcc:	16848493          	addi	s1,s1,360
    80001bd0:	ff2496e3          	bne	s1,s2,80001bbc <allocproc+0x1c>
  return 0;
    80001bd4:	4481                	li	s1,0
    80001bd6:	a089                	j	80001c18 <allocproc+0x78>
  p->pid = allocpid();
    80001bd8:	e71ff0ef          	jal	80001a48 <allocpid>
    80001bdc:	d888                	sw	a0,48(s1)
  p->state = USED;
    80001bde:	4785                	li	a5,1
    80001be0:	cc9c                	sw	a5,24(s1)
  if ((p->trapframe = (struct trapframe *)kalloc()) == 0) {
    80001be2:	f95fe0ef          	jal	80000b76 <kalloc>
    80001be6:	892a                	mv	s2,a0
    80001be8:	eca8                	sd	a0,88(s1)
    80001bea:	cd15                	beqz	a0,80001c26 <allocproc+0x86>
  p->pagetable = proc_pagetable(p);
    80001bec:	8526                	mv	a0,s1
    80001bee:	e99ff0ef          	jal	80001a86 <proc_pagetable>
    80001bf2:	892a                	mv	s2,a0
    80001bf4:	e8a8                	sd	a0,80(s1)
  if (p->pagetable == 0) {
    80001bf6:	c121                	beqz	a0,80001c36 <allocproc+0x96>
  memset(&p->context, 0, sizeof(p->context));
    80001bf8:	07000613          	li	a2,112
    80001bfc:	4581                	li	a1,0
    80001bfe:	06048513          	addi	a0,s1,96
    80001c02:	928ff0ef          	jal	80000d2a <memset>
  p->context.ra = (uint64)forkret;
    80001c06:	00000797          	auipc	a5,0x0
    80001c0a:	da878793          	addi	a5,a5,-600 # 800019ae <forkret>
    80001c0e:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001c10:	60bc                	ld	a5,64(s1)
    80001c12:	6705                	lui	a4,0x1
    80001c14:	97ba                	add	a5,a5,a4
    80001c16:	f4bc                	sd	a5,104(s1)
}
    80001c18:	8526                	mv	a0,s1
    80001c1a:	60e2                	ld	ra,24(sp)
    80001c1c:	6442                	ld	s0,16(sp)
    80001c1e:	64a2                	ld	s1,8(sp)
    80001c20:	6902                	ld	s2,0(sp)
    80001c22:	6105                	addi	sp,sp,32
    80001c24:	8082                	ret
    freeproc(p);
    80001c26:	8526                	mv	a0,s1
    80001c28:	f29ff0ef          	jal	80001b50 <freeproc>
    release(&p->lock);
    80001c2c:	8526                	mv	a0,s1
    80001c2e:	8c0ff0ef          	jal	80000cee <release>
    return 0;
    80001c32:	84ca                	mv	s1,s2
    80001c34:	b7d5                	j	80001c18 <allocproc+0x78>
    freeproc(p);
    80001c36:	8526                	mv	a0,s1
    80001c38:	f19ff0ef          	jal	80001b50 <freeproc>
    release(&p->lock);
    80001c3c:	8526                	mv	a0,s1
    80001c3e:	8b0ff0ef          	jal	80000cee <release>
    return 0;
    80001c42:	84ca                	mv	s1,s2
    80001c44:	bfd1                	j	80001c18 <allocproc+0x78>

0000000080001c46 <userinit>:
void userinit(void) {
    80001c46:	1101                	addi	sp,sp,-32
    80001c48:	ec06                	sd	ra,24(sp)
    80001c4a:	e822                	sd	s0,16(sp)
    80001c4c:	e426                	sd	s1,8(sp)
    80001c4e:	1000                	addi	s0,sp,32
  p = allocproc();
    80001c50:	f51ff0ef          	jal	80001ba0 <allocproc>
    80001c54:	84aa                	mv	s1,a0
  initproc = p;
    80001c56:	0000a797          	auipc	a5,0xa
    80001c5a:	a0a7b923          	sd	a0,-1518(a5) # 8000b668 <initproc>
  p->cwd = namei("/");
    80001c5e:	00006517          	auipc	a0,0x6
    80001c62:	54a50513          	addi	a0,a0,1354 # 800081a8 <etext+0x1a8>
    80001c66:	0ac020ef          	jal	80003d12 <namei>
    80001c6a:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    80001c6e:	478d                	li	a5,3
    80001c70:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001c72:	8526                	mv	a0,s1
    80001c74:	87aff0ef          	jal	80000cee <release>
}
    80001c78:	60e2                	ld	ra,24(sp)
    80001c7a:	6442                	ld	s0,16(sp)
    80001c7c:	64a2                	ld	s1,8(sp)
    80001c7e:	6105                	addi	sp,sp,32
    80001c80:	8082                	ret

0000000080001c82 <growproc>:
int growproc(int n) {
    80001c82:	1101                	addi	sp,sp,-32
    80001c84:	ec06                	sd	ra,24(sp)
    80001c86:	e822                	sd	s0,16(sp)
    80001c88:	e426                	sd	s1,8(sp)
    80001c8a:	e04a                	sd	s2,0(sp)
    80001c8c:	1000                	addi	s0,sp,32
    80001c8e:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80001c90:	cedff0ef          	jal	8000197c <myproc>
    80001c94:	892a                	mv	s2,a0
  sz = p->sz;
    80001c96:	652c                	ld	a1,72(a0)
  if (n > 0) {
    80001c98:	02905963          	blez	s1,80001cca <growproc+0x48>
    if (sz + n > TRAPFRAME) {
    80001c9c:	00b48633          	add	a2,s1,a1
    80001ca0:	020007b7          	lui	a5,0x2000
    80001ca4:	17fd                	addi	a5,a5,-1 # 1ffffff <_entry-0x7e000001>
    80001ca6:	07b6                	slli	a5,a5,0xd
    80001ca8:	02c7ea63          	bltu	a5,a2,80001cdc <growproc+0x5a>
    if ((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0) {
    80001cac:	4691                	li	a3,4
    80001cae:	6928                	ld	a0,80(a0)
    80001cb0:	e86ff0ef          	jal	80001336 <uvmalloc>
    80001cb4:	85aa                	mv	a1,a0
    80001cb6:	c50d                	beqz	a0,80001ce0 <growproc+0x5e>
  p->sz = sz;
    80001cb8:	04b93423          	sd	a1,72(s2)
  return 0;
    80001cbc:	4501                	li	a0,0
}
    80001cbe:	60e2                	ld	ra,24(sp)
    80001cc0:	6442                	ld	s0,16(sp)
    80001cc2:	64a2                	ld	s1,8(sp)
    80001cc4:	6902                	ld	s2,0(sp)
    80001cc6:	6105                	addi	sp,sp,32
    80001cc8:	8082                	ret
  } else if (n < 0) {
    80001cca:	fe04d7e3          	bgez	s1,80001cb8 <growproc+0x36>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001cce:	00b48633          	add	a2,s1,a1
    80001cd2:	6928                	ld	a0,80(a0)
    80001cd4:	e1eff0ef          	jal	800012f2 <uvmdealloc>
    80001cd8:	85aa                	mv	a1,a0
    80001cda:	bff9                	j	80001cb8 <growproc+0x36>
      return -1;
    80001cdc:	557d                	li	a0,-1
    80001cde:	b7c5                	j	80001cbe <growproc+0x3c>
      return -1;
    80001ce0:	557d                	li	a0,-1
    80001ce2:	bff1                	j	80001cbe <growproc+0x3c>

0000000080001ce4 <kfork>:
int kfork(void) {
    80001ce4:	7139                	addi	sp,sp,-64
    80001ce6:	fc06                	sd	ra,56(sp)
    80001ce8:	f822                	sd	s0,48(sp)
    80001cea:	f426                	sd	s1,40(sp)
    80001cec:	e456                	sd	s5,8(sp)
    80001cee:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    80001cf0:	c8dff0ef          	jal	8000197c <myproc>
    80001cf4:	8aaa                	mv	s5,a0
  if ((np = allocproc()) == 0) {
    80001cf6:	eabff0ef          	jal	80001ba0 <allocproc>
    80001cfa:	0e050a63          	beqz	a0,80001dee <kfork+0x10a>
    80001cfe:	e852                	sd	s4,16(sp)
    80001d00:	8a2a                	mv	s4,a0
  if (uvmcopy(p->pagetable, np->pagetable, p->sz) < 0) {
    80001d02:	048ab603          	ld	a2,72(s5)
    80001d06:	692c                	ld	a1,80(a0)
    80001d08:	050ab503          	ld	a0,80(s5)
    80001d0c:	f62ff0ef          	jal	8000146e <uvmcopy>
    80001d10:	04054863          	bltz	a0,80001d60 <kfork+0x7c>
    80001d14:	f04a                	sd	s2,32(sp)
    80001d16:	ec4e                	sd	s3,24(sp)
  np->sz = p->sz;
    80001d18:	048ab783          	ld	a5,72(s5)
    80001d1c:	04fa3423          	sd	a5,72(s4)
  *(np->trapframe) = *(p->trapframe);
    80001d20:	058ab683          	ld	a3,88(s5)
    80001d24:	87b6                	mv	a5,a3
    80001d26:	058a3703          	ld	a4,88(s4)
    80001d2a:	12068693          	addi	a3,a3,288
    80001d2e:	6388                	ld	a0,0(a5)
    80001d30:	678c                	ld	a1,8(a5)
    80001d32:	6b90                	ld	a2,16(a5)
    80001d34:	e308                	sd	a0,0(a4)
    80001d36:	e70c                	sd	a1,8(a4)
    80001d38:	eb10                	sd	a2,16(a4)
    80001d3a:	6f90                	ld	a2,24(a5)
    80001d3c:	ef10                	sd	a2,24(a4)
    80001d3e:	02078793          	addi	a5,a5,32
    80001d42:	02070713          	addi	a4,a4,32 # 1020 <_entry-0x7fffefe0>
    80001d46:	fed794e3          	bne	a5,a3,80001d2e <kfork+0x4a>
  np->trapframe->a0 = 0;
    80001d4a:	058a3783          	ld	a5,88(s4)
    80001d4e:	0607b823          	sd	zero,112(a5)
  for (i = 0; i < NOFILE; i++)
    80001d52:	0d0a8493          	addi	s1,s5,208
    80001d56:	0d0a0913          	addi	s2,s4,208
    80001d5a:	150a8993          	addi	s3,s5,336
    80001d5e:	a831                	j	80001d7a <kfork+0x96>
    freeproc(np);
    80001d60:	8552                	mv	a0,s4
    80001d62:	defff0ef          	jal	80001b50 <freeproc>
    release(&np->lock);
    80001d66:	8552                	mv	a0,s4
    80001d68:	f87fe0ef          	jal	80000cee <release>
    return -1;
    80001d6c:	54fd                	li	s1,-1
    80001d6e:	6a42                	ld	s4,16(sp)
    80001d70:	a885                	j	80001de0 <kfork+0xfc>
  for (i = 0; i < NOFILE; i++)
    80001d72:	04a1                	addi	s1,s1,8
    80001d74:	0921                	addi	s2,s2,8
    80001d76:	01348963          	beq	s1,s3,80001d88 <kfork+0xa4>
    if (p->ofile[i])
    80001d7a:	6088                	ld	a0,0(s1)
    80001d7c:	d97d                	beqz	a0,80001d72 <kfork+0x8e>
      np->ofile[i] = filedup(p->ofile[i]);
    80001d7e:	550020ef          	jal	800042ce <filedup>
    80001d82:	00a93023          	sd	a0,0(s2)
    80001d86:	b7f5                	j	80001d72 <kfork+0x8e>
  np->cwd = idup(p->cwd);
    80001d88:	150ab503          	ld	a0,336(s5)
    80001d8c:	722010ef          	jal	800034ae <idup>
    80001d90:	14aa3823          	sd	a0,336(s4)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001d94:	4641                	li	a2,16
    80001d96:	158a8593          	addi	a1,s5,344
    80001d9a:	158a0513          	addi	a0,s4,344
    80001d9e:	8e0ff0ef          	jal	80000e7e <safestrcpy>
  pid = np->pid;
    80001da2:	030a2483          	lw	s1,48(s4)
  release(&np->lock);
    80001da6:	8552                	mv	a0,s4
    80001da8:	f47fe0ef          	jal	80000cee <release>
  acquire(&wait_lock);
    80001dac:	00012517          	auipc	a0,0x12
    80001db0:	a2450513          	addi	a0,a0,-1500 # 800137d0 <wait_lock>
    80001db4:	ea7fe0ef          	jal	80000c5a <acquire>
  np->parent = p;
    80001db8:	035a3c23          	sd	s5,56(s4)
  release(&wait_lock);
    80001dbc:	00012517          	auipc	a0,0x12
    80001dc0:	a1450513          	addi	a0,a0,-1516 # 800137d0 <wait_lock>
    80001dc4:	f2bfe0ef          	jal	80000cee <release>
  acquire(&np->lock);
    80001dc8:	8552                	mv	a0,s4
    80001dca:	e91fe0ef          	jal	80000c5a <acquire>
  np->state = RUNNABLE;
    80001dce:	478d                	li	a5,3
    80001dd0:	00fa2c23          	sw	a5,24(s4)
  release(&np->lock);
    80001dd4:	8552                	mv	a0,s4
    80001dd6:	f19fe0ef          	jal	80000cee <release>
  return pid;
    80001dda:	7902                	ld	s2,32(sp)
    80001ddc:	69e2                	ld	s3,24(sp)
    80001dde:	6a42                	ld	s4,16(sp)
}
    80001de0:	8526                	mv	a0,s1
    80001de2:	70e2                	ld	ra,56(sp)
    80001de4:	7442                	ld	s0,48(sp)
    80001de6:	74a2                	ld	s1,40(sp)
    80001de8:	6aa2                	ld	s5,8(sp)
    80001dea:	6121                	addi	sp,sp,64
    80001dec:	8082                	ret
    return -1;
    80001dee:	54fd                	li	s1,-1
    80001df0:	bfc5                	j	80001de0 <kfork+0xfc>

0000000080001df2 <scheduler>:
void scheduler(void) {
    80001df2:	7171                	addi	sp,sp,-176
    80001df4:	f506                	sd	ra,168(sp)
    80001df6:	f122                	sd	s0,160(sp)
    80001df8:	ed26                	sd	s1,152(sp)
    80001dfa:	e94a                	sd	s2,144(sp)
    80001dfc:	e54e                	sd	s3,136(sp)
    80001dfe:	e152                	sd	s4,128(sp)
    80001e00:	fcd6                	sd	s5,120(sp)
    80001e02:	f8da                	sd	s6,112(sp)
    80001e04:	f4de                	sd	s7,104(sp)
    80001e06:	f0e2                	sd	s8,96(sp)
    80001e08:	ece6                	sd	s9,88(sp)
    80001e0a:	e8ea                	sd	s10,80(sp)
    80001e0c:	1900                	addi	s0,sp,176
    80001e0e:	8492                	mv	s1,tp
  int id = r_tp();
    80001e10:	2481                	sext.w	s1,s1
    80001e12:	8792                	mv	a5,tp
    if(cpuid() == 0){
    80001e14:	2781                	sext.w	a5,a5
    80001e16:	c79d                	beqz	a5,80001e44 <scheduler+0x52>
  c->proc = 0;
    80001e18:	00749b93          	slli	s7,s1,0x7
    80001e1c:	00012797          	auipc	a5,0x12
    80001e20:	99c78793          	addi	a5,a5,-1636 # 800137b8 <pid_lock>
    80001e24:	97de                	add	a5,a5,s7
    80001e26:	0407b423          	sd	zero,72(a5)
        swtch(&c->context, &p->context);
    80001e2a:	00012797          	auipc	a5,0x12
    80001e2e:	9de78793          	addi	a5,a5,-1570 # 80013808 <cpus+0x8>
    80001e32:	9bbe                	add	s7,s7,a5
        p->state = RUNNING;
    80001e34:	4b11                	li	s6,4
        c->proc = p;
    80001e36:	049e                	slli	s1,s1,0x7
    80001e38:	00012a97          	auipc	s5,0x12
    80001e3c:	980a8a93          	addi	s5,s5,-1664 # 800137b8 <pid_lock>
    80001e40:	9aa6                	add	s5,s5,s1
    80001e42:	a2d5                	j	80002026 <scheduler+0x234>
      acquire(&schedinfo_lock);
    80001e44:	00012517          	auipc	a0,0x12
    80001e48:	9a450513          	addi	a0,a0,-1628 # 800137e8 <schedinfo_lock>
    80001e4c:	e0ffe0ef          	jal	80000c5a <acquire>
      if(sched_info_logged == 0){
    80001e50:	0000a797          	auipc	a5,0xa
    80001e54:	8107a783          	lw	a5,-2032(a5) # 8000b660 <sched_info_logged>
    80001e58:	cb81                	beqz	a5,80001e68 <scheduler+0x76>
      release(&schedinfo_lock);
    80001e5a:	00012517          	auipc	a0,0x12
    80001e5e:	98e50513          	addi	a0,a0,-1650 # 800137e8 <schedinfo_lock>
    80001e62:	e8dfe0ef          	jal	80000cee <release>
    80001e66:	bf4d                	j	80001e18 <scheduler+0x26>
        sched_info_logged = 1;
    80001e68:	4905                	li	s2,1
    80001e6a:	00009797          	auipc	a5,0x9
    80001e6e:	7f27ab23          	sw	s2,2038(a5) # 8000b660 <sched_info_logged>
        memset(&e, 0, sizeof(e));
    80001e72:	f5840993          	addi	s3,s0,-168
    80001e76:	04400613          	li	a2,68
    80001e7a:	4581                	li	a1,0
    80001e7c:	854e                	mv	a0,s3
    80001e7e:	eadfe0ef          	jal	80000d2a <memset>
        e.ticks = ticks;
    80001e82:	00009797          	auipc	a5,0x9
    80001e86:	7ee7a783          	lw	a5,2030(a5) # 8000b670 <ticks>
    80001e8a:	f4f42e23          	sw	a5,-164(s0)
        e.event_type = SCHED_EV_INFO;
    80001e8e:	f7242023          	sw	s2,-160(s0)
        safestrcpy(e.scheduler_name, "RR", sizeof(e.scheduler_name));
    80001e92:	4641                	li	a2,16
    80001e94:	00006597          	auipc	a1,0x6
    80001e98:	31c58593          	addi	a1,a1,796 # 800081b0 <etext+0x1b0>
    80001e9c:	f6440513          	addi	a0,s0,-156
    80001ea0:	fdffe0ef          	jal	80000e7e <safestrcpy>
        e.num_cpus = 3;
    80001ea4:	478d                	li	a5,3
    80001ea6:	f6f42a23          	sw	a5,-140(s0)
        e.time_slice = 1;
    80001eaa:	f7242c23          	sw	s2,-136(s0)
        schedlog_emit(&e);
    80001eae:	854e                	mv	a0,s3
    80001eb0:	300040ef          	jal	800061b0 <schedlog_emit>
    80001eb4:	b75d                	j	80001e5a <scheduler+0x68>
        if(strncmp(p->name, "schedexport", 16) != 0){
    80001eb6:	158c8c13          	addi	s8,s9,344
    80001eba:	864e                	mv	a2,s3
    80001ebc:	85d2                	mv	a1,s4
    80001ebe:	8562                	mv	a0,s8
    80001ec0:	f3ffe0ef          	jal	80000dfe <strncmp>
    80001ec4:	e945                	bnez	a0,80001f74 <scheduler+0x182>
        swtch(&c->context, &p->context);
    80001ec6:	060c8593          	addi	a1,s9,96
    80001eca:	855e                	mv	a0,s7
    80001ecc:	702000ef          	jal	800025ce <swtch>
        if(strncmp(p->name, "schedexport", 16) != 0){
    80001ed0:	864e                	mv	a2,s3
    80001ed2:	85d2                	mv	a1,s4
    80001ed4:	8562                	mv	a0,s8
    80001ed6:	f29fe0ef          	jal	80000dfe <strncmp>
    80001eda:	0e051163          	bnez	a0,80001fbc <scheduler+0x1ca>
        c->proc = 0;
    80001ede:	040ab423          	sd	zero,72(s5)
        found = 1;
    80001ee2:	4c05                	li	s8,1
      release(&p->lock);
    80001ee4:	8526                	mv	a0,s1
    80001ee6:	e09fe0ef          	jal	80000cee <release>
    for (p = proc; p < &proc[NPROC]; p++) {
    80001eea:	16848493          	addi	s1,s1,360
    80001eee:	00017797          	auipc	a5,0x17
    80001ef2:	71278793          	addi	a5,a5,1810 # 80019600 <tickslock>
    80001ef6:	12f48463          	beq	s1,a5,8000201e <scheduler+0x22c>
      acquire(&p->lock);
    80001efa:	8526                	mv	a0,s1
    80001efc:	d5ffe0ef          	jal	80000c5a <acquire>
      if (p->state == RUNNABLE) {
    80001f00:	4c9c                	lw	a5,24(s1)
    80001f02:	ff2791e3          	bne	a5,s2,80001ee4 <scheduler+0xf2>
    80001f06:	8ca6                	mv	s9,s1
        p->state = RUNNING;
    80001f08:	0164ac23          	sw	s6,24(s1)
        c->proc = p;
    80001f0c:	049ab423          	sd	s1,72(s5)
        cslog_run_start(p);
    80001f10:	8526                	mv	a0,s1
    80001f12:	663030ef          	jal	80005d74 <cslog_run_start>
    80001f16:	8792                	mv	a5,tp
        if (cpuid() == 0 && sched_info_logged == 0) {
    80001f18:	2781                	sext.w	a5,a5
    80001f1a:	ffd1                	bnez	a5,80001eb6 <scheduler+0xc4>
    80001f1c:	00009797          	auipc	a5,0x9
    80001f20:	7447a783          	lw	a5,1860(a5) # 8000b660 <sched_info_logged>
    80001f24:	fbc9                	bnez	a5,80001eb6 <scheduler+0xc4>
          sched_info_logged = 1;
    80001f26:	4c05                	li	s8,1
    80001f28:	00009797          	auipc	a5,0x9
    80001f2c:	7387ac23          	sw	s8,1848(a5) # 8000b660 <sched_info_logged>
          memset(&e, 0, sizeof(e));
    80001f30:	f5840d13          	addi	s10,s0,-168
    80001f34:	04400613          	li	a2,68
    80001f38:	4581                	li	a1,0
    80001f3a:	856a                	mv	a0,s10
    80001f3c:	deffe0ef          	jal	80000d2a <memset>
          e.ticks = ticks;
    80001f40:	00009797          	auipc	a5,0x9
    80001f44:	7307a783          	lw	a5,1840(a5) # 8000b670 <ticks>
    80001f48:	f4f42e23          	sw	a5,-164(s0)
          e.event_type = SCHED_EV_INFO;
    80001f4c:	f7842023          	sw	s8,-160(s0)
          safestrcpy(e.scheduler_name, "RR", sizeof(e.scheduler_name));
    80001f50:	864e                	mv	a2,s3
    80001f52:	00006597          	auipc	a1,0x6
    80001f56:	25e58593          	addi	a1,a1,606 # 800081b0 <etext+0x1b0>
    80001f5a:	f6440513          	addi	a0,s0,-156
    80001f5e:	f21fe0ef          	jal	80000e7e <safestrcpy>
          e.num_cpus = NCPU;
    80001f62:	47a1                	li	a5,8
    80001f64:	f6f42a23          	sw	a5,-140(s0)
          e.time_slice = 1;
    80001f68:	f7842c23          	sw	s8,-136(s0)
          schedlog_emit(&e);
    80001f6c:	856a                	mv	a0,s10
    80001f6e:	242040ef          	jal	800061b0 <schedlog_emit>
    80001f72:	b791                	j	80001eb6 <scheduler+0xc4>
          memset(&e, 0, sizeof(e));
    80001f74:	f5840d13          	addi	s10,s0,-168
    80001f78:	04400613          	li	a2,68
    80001f7c:	4581                	li	a1,0
    80001f7e:	856a                	mv	a0,s10
    80001f80:	dabfe0ef          	jal	80000d2a <memset>
          e.ticks = ticks;
    80001f84:	00009797          	auipc	a5,0x9
    80001f88:	6ec7a783          	lw	a5,1772(a5) # 8000b670 <ticks>
    80001f8c:	f4f42e23          	sw	a5,-164(s0)
          e.event_type = SCHED_EV_ON_CPU;
    80001f90:	4789                	li	a5,2
    80001f92:	f6f42023          	sw	a5,-160(s0)
    80001f96:	8792                	mv	a5,tp
  int id = r_tp();
    80001f98:	f6f42e23          	sw	a5,-132(s0)
          e.pid = p->pid;
    80001f9c:	589c                	lw	a5,48(s1)
    80001f9e:	f8f42023          	sw	a5,-128(s0)
          safestrcpy(e.name, p->name, sizeof(e.name));
    80001fa2:	864e                	mv	a2,s3
    80001fa4:	85e2                	mv	a1,s8
    80001fa6:	f8440513          	addi	a0,s0,-124
    80001faa:	ed5fe0ef          	jal	80000e7e <safestrcpy>
          e.state = p->state;
    80001fae:	4c9c                	lw	a5,24(s1)
    80001fb0:	f8f42a23          	sw	a5,-108(s0)
          schedlog_emit(&e);
    80001fb4:	856a                	mv	a0,s10
    80001fb6:	1fa040ef          	jal	800061b0 <schedlog_emit>
    80001fba:	b731                	j	80001ec6 <scheduler+0xd4>
          memset(&e2, 0, sizeof(e2));
    80001fbc:	04400613          	li	a2,68
    80001fc0:	4581                	li	a1,0
    80001fc2:	f5840513          	addi	a0,s0,-168
    80001fc6:	d65fe0ef          	jal	80000d2a <memset>
          e2.ticks = ticks;
    80001fca:	00009797          	auipc	a5,0x9
    80001fce:	6a67a783          	lw	a5,1702(a5) # 8000b670 <ticks>
    80001fd2:	f4f42e23          	sw	a5,-164(s0)
          e2.event_type = SCHED_EV_OFF_CPU;
    80001fd6:	f7242023          	sw	s2,-160(s0)
    80001fda:	8792                	mv	a5,tp
  int id = r_tp();
    80001fdc:	f6f42e23          	sw	a5,-132(s0)
          e2.pid = p->pid;
    80001fe0:	589c                	lw	a5,48(s1)
    80001fe2:	f8f42023          	sw	a5,-128(s0)
          safestrcpy(e2.name, p->name, sizeof(e2.name));
    80001fe6:	864e                	mv	a2,s3
    80001fe8:	85e2                	mv	a1,s8
    80001fea:	f8440513          	addi	a0,s0,-124
    80001fee:	e91fe0ef          	jal	80000e7e <safestrcpy>
          e2.state = p->state;
    80001ff2:	4c9c                	lw	a5,24(s1)
          if(p->state == SLEEPING)
    80001ff4:	4689                	li	a3,2
    80001ff6:	8736                	mv	a4,a3
    80001ff8:	00d78a63          	beq	a5,a3,8000200c <scheduler+0x21a>
          else if(p->state == ZOMBIE)
    80001ffc:	4695                	li	a3,5
    80001ffe:	875a                	mv	a4,s6
    80002000:	00d78663          	beq	a5,a3,8000200c <scheduler+0x21a>
          else if(p->state == RUNNABLE)
    80002004:	874a                	mv	a4,s2
    80002006:	01278363          	beq	a5,s2,8000200c <scheduler+0x21a>
    8000200a:	4701                	li	a4,0
          e2.state = p->state;
    8000200c:	f8f42a23          	sw	a5,-108(s0)
            e2.reason = SCHED_OFF_SLEEP;
    80002010:	f8e42c23          	sw	a4,-104(s0)
          schedlog_emit(&e2);
    80002014:	f5840513          	addi	a0,s0,-168
    80002018:	198040ef          	jal	800061b0 <schedlog_emit>
    8000201c:	b5c9                	j	80001ede <scheduler+0xec>
    if (found == 0) {
    8000201e:	000c1563          	bnez	s8,80002028 <scheduler+0x236>
      asm volatile("wfi");
    80002022:	10500073          	wfi
      if (p->state == RUNNABLE) {
    80002026:	490d                	li	s2,3
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002028:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    8000202c:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002030:	10079073          	csrw	sstatus,a5
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002034:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80002038:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000203a:	10079073          	csrw	sstatus,a5
    int found = 0;
    8000203e:	4c01                	li	s8,0
    for (p = proc; p < &proc[NPROC]; p++) {
    80002040:	00012497          	auipc	s1,0x12
    80002044:	bc048493          	addi	s1,s1,-1088 # 80013c00 <proc>
        if(strncmp(p->name, "schedexport", 16) != 0){
    80002048:	49c1                	li	s3,16
    8000204a:	00006a17          	auipc	s4,0x6
    8000204e:	16ea0a13          	addi	s4,s4,366 # 800081b8 <etext+0x1b8>
    80002052:	b565                	j	80001efa <scheduler+0x108>

0000000080002054 <sched>:
void sched(void) {
    80002054:	7179                	addi	sp,sp,-48
    80002056:	f406                	sd	ra,40(sp)
    80002058:	f022                	sd	s0,32(sp)
    8000205a:	ec26                	sd	s1,24(sp)
    8000205c:	e84a                	sd	s2,16(sp)
    8000205e:	e44e                	sd	s3,8(sp)
    80002060:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80002062:	91bff0ef          	jal	8000197c <myproc>
    80002066:	84aa                	mv	s1,a0
  if (!holding(&p->lock))
    80002068:	b83fe0ef          	jal	80000bea <holding>
    8000206c:	c935                	beqz	a0,800020e0 <sched+0x8c>
  asm volatile("mv %0, tp" : "=r" (x) );
    8000206e:	8792                	mv	a5,tp
  if (mycpu()->noff != 1)
    80002070:	2781                	sext.w	a5,a5
    80002072:	079e                	slli	a5,a5,0x7
    80002074:	00011717          	auipc	a4,0x11
    80002078:	74470713          	addi	a4,a4,1860 # 800137b8 <pid_lock>
    8000207c:	97ba                	add	a5,a5,a4
    8000207e:	0c07a703          	lw	a4,192(a5)
    80002082:	4785                	li	a5,1
    80002084:	06f71463          	bne	a4,a5,800020ec <sched+0x98>
  if (p->state == RUNNING)
    80002088:	4c98                	lw	a4,24(s1)
    8000208a:	4791                	li	a5,4
    8000208c:	06f70663          	beq	a4,a5,800020f8 <sched+0xa4>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002090:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002094:	8b89                	andi	a5,a5,2
  if (intr_get())
    80002096:	e7bd                	bnez	a5,80002104 <sched+0xb0>
  asm volatile("mv %0, tp" : "=r" (x) );
    80002098:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    8000209a:	00011917          	auipc	s2,0x11
    8000209e:	71e90913          	addi	s2,s2,1822 # 800137b8 <pid_lock>
    800020a2:	2781                	sext.w	a5,a5
    800020a4:	079e                	slli	a5,a5,0x7
    800020a6:	97ca                	add	a5,a5,s2
    800020a8:	0c47a983          	lw	s3,196(a5)
    800020ac:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    800020ae:	2781                	sext.w	a5,a5
    800020b0:	079e                	slli	a5,a5,0x7
    800020b2:	07a1                	addi	a5,a5,8
    800020b4:	00011597          	auipc	a1,0x11
    800020b8:	74c58593          	addi	a1,a1,1868 # 80013800 <cpus>
    800020bc:	95be                	add	a1,a1,a5
    800020be:	06048513          	addi	a0,s1,96
    800020c2:	50c000ef          	jal	800025ce <swtch>
    800020c6:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    800020c8:	2781                	sext.w	a5,a5
    800020ca:	079e                	slli	a5,a5,0x7
    800020cc:	993e                	add	s2,s2,a5
    800020ce:	0d392223          	sw	s3,196(s2)
}
    800020d2:	70a2                	ld	ra,40(sp)
    800020d4:	7402                	ld	s0,32(sp)
    800020d6:	64e2                	ld	s1,24(sp)
    800020d8:	6942                	ld	s2,16(sp)
    800020da:	69a2                	ld	s3,8(sp)
    800020dc:	6145                	addi	sp,sp,48
    800020de:	8082                	ret
    panic("sched p->lock");
    800020e0:	00006517          	auipc	a0,0x6
    800020e4:	0e850513          	addi	a0,a0,232 # 800081c8 <etext+0x1c8>
    800020e8:	f6efe0ef          	jal	80000856 <panic>
    panic("sched locks");
    800020ec:	00006517          	auipc	a0,0x6
    800020f0:	0ec50513          	addi	a0,a0,236 # 800081d8 <etext+0x1d8>
    800020f4:	f62fe0ef          	jal	80000856 <panic>
    panic("sched RUNNING");
    800020f8:	00006517          	auipc	a0,0x6
    800020fc:	0f050513          	addi	a0,a0,240 # 800081e8 <etext+0x1e8>
    80002100:	f56fe0ef          	jal	80000856 <panic>
    panic("sched interruptible");
    80002104:	00006517          	auipc	a0,0x6
    80002108:	0f450513          	addi	a0,a0,244 # 800081f8 <etext+0x1f8>
    8000210c:	f4afe0ef          	jal	80000856 <panic>

0000000080002110 <yield>:
void yield(void) {
    80002110:	1101                	addi	sp,sp,-32
    80002112:	ec06                	sd	ra,24(sp)
    80002114:	e822                	sd	s0,16(sp)
    80002116:	e426                	sd	s1,8(sp)
    80002118:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    8000211a:	863ff0ef          	jal	8000197c <myproc>
    8000211e:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80002120:	b3bfe0ef          	jal	80000c5a <acquire>
  p->state = RUNNABLE;
    80002124:	478d                	li	a5,3
    80002126:	cc9c                	sw	a5,24(s1)
  sched();
    80002128:	f2dff0ef          	jal	80002054 <sched>
  release(&p->lock);
    8000212c:	8526                	mv	a0,s1
    8000212e:	bc1fe0ef          	jal	80000cee <release>
}
    80002132:	60e2                	ld	ra,24(sp)
    80002134:	6442                	ld	s0,16(sp)
    80002136:	64a2                	ld	s1,8(sp)
    80002138:	6105                	addi	sp,sp,32
    8000213a:	8082                	ret

000000008000213c <sleep>:

// Sleep on channel chan, releasing condition lock lk.
// Re-acquires lk when awakened.
void sleep(void *chan, struct spinlock *lk) {
    8000213c:	7179                	addi	sp,sp,-48
    8000213e:	f406                	sd	ra,40(sp)
    80002140:	f022                	sd	s0,32(sp)
    80002142:	ec26                	sd	s1,24(sp)
    80002144:	e84a                	sd	s2,16(sp)
    80002146:	e44e                	sd	s3,8(sp)
    80002148:	1800                	addi	s0,sp,48
    8000214a:	89aa                	mv	s3,a0
    8000214c:	892e                	mv	s2,a1
  struct proc *p = myproc();
    8000214e:	82fff0ef          	jal	8000197c <myproc>
    80002152:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock); // DOC: sleeplock1
    80002154:	b07fe0ef          	jal	80000c5a <acquire>
  release(lk);
    80002158:	854a                	mv	a0,s2
    8000215a:	b95fe0ef          	jal	80000cee <release>

  // Go to sleep.
  p->chan = chan;
    8000215e:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    80002162:	4789                	li	a5,2
    80002164:	cc9c                	sw	a5,24(s1)

  sched();
    80002166:	eefff0ef          	jal	80002054 <sched>

  // Tidy up.
  p->chan = 0;
    8000216a:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    8000216e:	8526                	mv	a0,s1
    80002170:	b7ffe0ef          	jal	80000cee <release>
  acquire(lk);
    80002174:	854a                	mv	a0,s2
    80002176:	ae5fe0ef          	jal	80000c5a <acquire>
}
    8000217a:	70a2                	ld	ra,40(sp)
    8000217c:	7402                	ld	s0,32(sp)
    8000217e:	64e2                	ld	s1,24(sp)
    80002180:	6942                	ld	s2,16(sp)
    80002182:	69a2                	ld	s3,8(sp)
    80002184:	6145                	addi	sp,sp,48
    80002186:	8082                	ret

0000000080002188 <wakeup>:

// Wake up all processes sleeping on channel chan.
// Caller should hold the condition lock.
void wakeup(void *chan) {
    80002188:	7139                	addi	sp,sp,-64
    8000218a:	fc06                	sd	ra,56(sp)
    8000218c:	f822                	sd	s0,48(sp)
    8000218e:	f426                	sd	s1,40(sp)
    80002190:	f04a                	sd	s2,32(sp)
    80002192:	ec4e                	sd	s3,24(sp)
    80002194:	e852                	sd	s4,16(sp)
    80002196:	e456                	sd	s5,8(sp)
    80002198:	0080                	addi	s0,sp,64
    8000219a:	8a2a                	mv	s4,a0
  struct proc *p;

  for (p = proc; p < &proc[NPROC]; p++) {
    8000219c:	00012497          	auipc	s1,0x12
    800021a0:	a6448493          	addi	s1,s1,-1436 # 80013c00 <proc>
    if (p != myproc()) {
      acquire(&p->lock);
      if (p->state == SLEEPING && p->chan == chan) {
    800021a4:	4989                	li	s3,2
        p->state = RUNNABLE;
    800021a6:	4a8d                	li	s5,3
  for (p = proc; p < &proc[NPROC]; p++) {
    800021a8:	00017917          	auipc	s2,0x17
    800021ac:	45890913          	addi	s2,s2,1112 # 80019600 <tickslock>
    800021b0:	a801                	j	800021c0 <wakeup+0x38>
      }
      release(&p->lock);
    800021b2:	8526                	mv	a0,s1
    800021b4:	b3bfe0ef          	jal	80000cee <release>
  for (p = proc; p < &proc[NPROC]; p++) {
    800021b8:	16848493          	addi	s1,s1,360
    800021bc:	03248263          	beq	s1,s2,800021e0 <wakeup+0x58>
    if (p != myproc()) {
    800021c0:	fbcff0ef          	jal	8000197c <myproc>
    800021c4:	fe950ae3          	beq	a0,s1,800021b8 <wakeup+0x30>
      acquire(&p->lock);
    800021c8:	8526                	mv	a0,s1
    800021ca:	a91fe0ef          	jal	80000c5a <acquire>
      if (p->state == SLEEPING && p->chan == chan) {
    800021ce:	4c9c                	lw	a5,24(s1)
    800021d0:	ff3791e3          	bne	a5,s3,800021b2 <wakeup+0x2a>
    800021d4:	709c                	ld	a5,32(s1)
    800021d6:	fd479ee3          	bne	a5,s4,800021b2 <wakeup+0x2a>
        p->state = RUNNABLE;
    800021da:	0154ac23          	sw	s5,24(s1)
    800021de:	bfd1                	j	800021b2 <wakeup+0x2a>
    }
  }
}
    800021e0:	70e2                	ld	ra,56(sp)
    800021e2:	7442                	ld	s0,48(sp)
    800021e4:	74a2                	ld	s1,40(sp)
    800021e6:	7902                	ld	s2,32(sp)
    800021e8:	69e2                	ld	s3,24(sp)
    800021ea:	6a42                	ld	s4,16(sp)
    800021ec:	6aa2                	ld	s5,8(sp)
    800021ee:	6121                	addi	sp,sp,64
    800021f0:	8082                	ret

00000000800021f2 <reparent>:
void reparent(struct proc *p) {
    800021f2:	7179                	addi	sp,sp,-48
    800021f4:	f406                	sd	ra,40(sp)
    800021f6:	f022                	sd	s0,32(sp)
    800021f8:	ec26                	sd	s1,24(sp)
    800021fa:	e84a                	sd	s2,16(sp)
    800021fc:	e44e                	sd	s3,8(sp)
    800021fe:	e052                	sd	s4,0(sp)
    80002200:	1800                	addi	s0,sp,48
    80002202:	892a                	mv	s2,a0
  for (pp = proc; pp < &proc[NPROC]; pp++) {
    80002204:	00012497          	auipc	s1,0x12
    80002208:	9fc48493          	addi	s1,s1,-1540 # 80013c00 <proc>
      pp->parent = initproc;
    8000220c:	00009a17          	auipc	s4,0x9
    80002210:	45ca0a13          	addi	s4,s4,1116 # 8000b668 <initproc>
  for (pp = proc; pp < &proc[NPROC]; pp++) {
    80002214:	00017997          	auipc	s3,0x17
    80002218:	3ec98993          	addi	s3,s3,1004 # 80019600 <tickslock>
    8000221c:	a029                	j	80002226 <reparent+0x34>
    8000221e:	16848493          	addi	s1,s1,360
    80002222:	01348b63          	beq	s1,s3,80002238 <reparent+0x46>
    if (pp->parent == p) {
    80002226:	7c9c                	ld	a5,56(s1)
    80002228:	ff279be3          	bne	a5,s2,8000221e <reparent+0x2c>
      pp->parent = initproc;
    8000222c:	000a3503          	ld	a0,0(s4)
    80002230:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    80002232:	f57ff0ef          	jal	80002188 <wakeup>
    80002236:	b7e5                	j	8000221e <reparent+0x2c>
}
    80002238:	70a2                	ld	ra,40(sp)
    8000223a:	7402                	ld	s0,32(sp)
    8000223c:	64e2                	ld	s1,24(sp)
    8000223e:	6942                	ld	s2,16(sp)
    80002240:	69a2                	ld	s3,8(sp)
    80002242:	6a02                	ld	s4,0(sp)
    80002244:	6145                	addi	sp,sp,48
    80002246:	8082                	ret

0000000080002248 <kexit>:
void kexit(int status) {
    80002248:	7179                	addi	sp,sp,-48
    8000224a:	f406                	sd	ra,40(sp)
    8000224c:	f022                	sd	s0,32(sp)
    8000224e:	ec26                	sd	s1,24(sp)
    80002250:	e84a                	sd	s2,16(sp)
    80002252:	e44e                	sd	s3,8(sp)
    80002254:	e052                	sd	s4,0(sp)
    80002256:	1800                	addi	s0,sp,48
    80002258:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    8000225a:	f22ff0ef          	jal	8000197c <myproc>
    8000225e:	89aa                	mv	s3,a0
  if (p == initproc)
    80002260:	00009797          	auipc	a5,0x9
    80002264:	4087b783          	ld	a5,1032(a5) # 8000b668 <initproc>
    80002268:	0d050493          	addi	s1,a0,208
    8000226c:	15050913          	addi	s2,a0,336
    80002270:	00a79b63          	bne	a5,a0,80002286 <kexit+0x3e>
    panic("init exiting");
    80002274:	00006517          	auipc	a0,0x6
    80002278:	f9c50513          	addi	a0,a0,-100 # 80008210 <etext+0x210>
    8000227c:	ddafe0ef          	jal	80000856 <panic>
  for (int fd = 0; fd < NOFILE; fd++) {
    80002280:	04a1                	addi	s1,s1,8
    80002282:	01248963          	beq	s1,s2,80002294 <kexit+0x4c>
    if (p->ofile[fd]) {
    80002286:	6088                	ld	a0,0(s1)
    80002288:	dd65                	beqz	a0,80002280 <kexit+0x38>
      fileclose(f);
    8000228a:	08a020ef          	jal	80004314 <fileclose>
      p->ofile[fd] = 0;
    8000228e:	0004b023          	sd	zero,0(s1)
    80002292:	b7fd                	j	80002280 <kexit+0x38>
  begin_op();
    80002294:	45d010ef          	jal	80003ef0 <begin_op>
  iput(p->cwd);
    80002298:	1509b503          	ld	a0,336(s3)
    8000229c:	3ca010ef          	jal	80003666 <iput>
  end_op();
    800022a0:	4c1010ef          	jal	80003f60 <end_op>
  p->cwd = 0;
    800022a4:	1409b823          	sd	zero,336(s3)
  acquire(&wait_lock);
    800022a8:	00011517          	auipc	a0,0x11
    800022ac:	52850513          	addi	a0,a0,1320 # 800137d0 <wait_lock>
    800022b0:	9abfe0ef          	jal	80000c5a <acquire>
  reparent(p);
    800022b4:	854e                	mv	a0,s3
    800022b6:	f3dff0ef          	jal	800021f2 <reparent>
  wakeup(p->parent);
    800022ba:	0389b503          	ld	a0,56(s3)
    800022be:	ecbff0ef          	jal	80002188 <wakeup>
  acquire(&p->lock);
    800022c2:	854e                	mv	a0,s3
    800022c4:	997fe0ef          	jal	80000c5a <acquire>
  p->xstate = status;
    800022c8:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    800022cc:	4795                	li	a5,5
    800022ce:	00f9ac23          	sw	a5,24(s3)
  release(&wait_lock);
    800022d2:	00011517          	auipc	a0,0x11
    800022d6:	4fe50513          	addi	a0,a0,1278 # 800137d0 <wait_lock>
    800022da:	a15fe0ef          	jal	80000cee <release>
  sched();
    800022de:	d77ff0ef          	jal	80002054 <sched>
  panic("zombie exit");
    800022e2:	00006517          	auipc	a0,0x6
    800022e6:	f3e50513          	addi	a0,a0,-194 # 80008220 <etext+0x220>
    800022ea:	d6cfe0ef          	jal	80000856 <panic>

00000000800022ee <kkill>:

// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int kkill(int pid) {
    800022ee:	7179                	addi	sp,sp,-48
    800022f0:	f406                	sd	ra,40(sp)
    800022f2:	f022                	sd	s0,32(sp)
    800022f4:	ec26                	sd	s1,24(sp)
    800022f6:	e84a                	sd	s2,16(sp)
    800022f8:	e44e                	sd	s3,8(sp)
    800022fa:	1800                	addi	s0,sp,48
    800022fc:	892a                	mv	s2,a0
  struct proc *p;

  for (p = proc; p < &proc[NPROC]; p++) {
    800022fe:	00012497          	auipc	s1,0x12
    80002302:	90248493          	addi	s1,s1,-1790 # 80013c00 <proc>
    80002306:	00017997          	auipc	s3,0x17
    8000230a:	2fa98993          	addi	s3,s3,762 # 80019600 <tickslock>
    acquire(&p->lock);
    8000230e:	8526                	mv	a0,s1
    80002310:	94bfe0ef          	jal	80000c5a <acquire>
    if (p->pid == pid) {
    80002314:	589c                	lw	a5,48(s1)
    80002316:	01278b63          	beq	a5,s2,8000232c <kkill+0x3e>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    8000231a:	8526                	mv	a0,s1
    8000231c:	9d3fe0ef          	jal	80000cee <release>
  for (p = proc; p < &proc[NPROC]; p++) {
    80002320:	16848493          	addi	s1,s1,360
    80002324:	ff3495e3          	bne	s1,s3,8000230e <kkill+0x20>
  }
  return -1;
    80002328:	557d                	li	a0,-1
    8000232a:	a819                	j	80002340 <kkill+0x52>
      p->killed = 1;
    8000232c:	4785                	li	a5,1
    8000232e:	d49c                	sw	a5,40(s1)
      if (p->state == SLEEPING) {
    80002330:	4c98                	lw	a4,24(s1)
    80002332:	4789                	li	a5,2
    80002334:	00f70d63          	beq	a4,a5,8000234e <kkill+0x60>
      release(&p->lock);
    80002338:	8526                	mv	a0,s1
    8000233a:	9b5fe0ef          	jal	80000cee <release>
      return 0;
    8000233e:	4501                	li	a0,0
}
    80002340:	70a2                	ld	ra,40(sp)
    80002342:	7402                	ld	s0,32(sp)
    80002344:	64e2                	ld	s1,24(sp)
    80002346:	6942                	ld	s2,16(sp)
    80002348:	69a2                	ld	s3,8(sp)
    8000234a:	6145                	addi	sp,sp,48
    8000234c:	8082                	ret
        p->state = RUNNABLE;
    8000234e:	478d                	li	a5,3
    80002350:	cc9c                	sw	a5,24(s1)
    80002352:	b7dd                	j	80002338 <kkill+0x4a>

0000000080002354 <setkilled>:

void setkilled(struct proc *p) {
    80002354:	1101                	addi	sp,sp,-32
    80002356:	ec06                	sd	ra,24(sp)
    80002358:	e822                	sd	s0,16(sp)
    8000235a:	e426                	sd	s1,8(sp)
    8000235c:	1000                	addi	s0,sp,32
    8000235e:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80002360:	8fbfe0ef          	jal	80000c5a <acquire>
  p->killed = 1;
    80002364:	4785                	li	a5,1
    80002366:	d49c                	sw	a5,40(s1)
  release(&p->lock);
    80002368:	8526                	mv	a0,s1
    8000236a:	985fe0ef          	jal	80000cee <release>
}
    8000236e:	60e2                	ld	ra,24(sp)
    80002370:	6442                	ld	s0,16(sp)
    80002372:	64a2                	ld	s1,8(sp)
    80002374:	6105                	addi	sp,sp,32
    80002376:	8082                	ret

0000000080002378 <killed>:

int killed(struct proc *p) {
    80002378:	1101                	addi	sp,sp,-32
    8000237a:	ec06                	sd	ra,24(sp)
    8000237c:	e822                	sd	s0,16(sp)
    8000237e:	e426                	sd	s1,8(sp)
    80002380:	e04a                	sd	s2,0(sp)
    80002382:	1000                	addi	s0,sp,32
    80002384:	84aa                	mv	s1,a0
  int k;

  acquire(&p->lock);
    80002386:	8d5fe0ef          	jal	80000c5a <acquire>
  k = p->killed;
    8000238a:	549c                	lw	a5,40(s1)
    8000238c:	893e                	mv	s2,a5
  release(&p->lock);
    8000238e:	8526                	mv	a0,s1
    80002390:	95ffe0ef          	jal	80000cee <release>
  return k;
}
    80002394:	854a                	mv	a0,s2
    80002396:	60e2                	ld	ra,24(sp)
    80002398:	6442                	ld	s0,16(sp)
    8000239a:	64a2                	ld	s1,8(sp)
    8000239c:	6902                	ld	s2,0(sp)
    8000239e:	6105                	addi	sp,sp,32
    800023a0:	8082                	ret

00000000800023a2 <kwait>:
int kwait(uint64 addr) {
    800023a2:	715d                	addi	sp,sp,-80
    800023a4:	e486                	sd	ra,72(sp)
    800023a6:	e0a2                	sd	s0,64(sp)
    800023a8:	fc26                	sd	s1,56(sp)
    800023aa:	f84a                	sd	s2,48(sp)
    800023ac:	f44e                	sd	s3,40(sp)
    800023ae:	f052                	sd	s4,32(sp)
    800023b0:	ec56                	sd	s5,24(sp)
    800023b2:	e85a                	sd	s6,16(sp)
    800023b4:	e45e                	sd	s7,8(sp)
    800023b6:	0880                	addi	s0,sp,80
    800023b8:	8baa                	mv	s7,a0
  struct proc *p = myproc();
    800023ba:	dc2ff0ef          	jal	8000197c <myproc>
    800023be:	892a                	mv	s2,a0
  acquire(&wait_lock);
    800023c0:	00011517          	auipc	a0,0x11
    800023c4:	41050513          	addi	a0,a0,1040 # 800137d0 <wait_lock>
    800023c8:	893fe0ef          	jal	80000c5a <acquire>
        if (pp->state == ZOMBIE) {
    800023cc:	4a15                	li	s4,5
        havekids = 1;
    800023ce:	4a85                	li	s5,1
    for (pp = proc; pp < &proc[NPROC]; pp++) {
    800023d0:	00017997          	auipc	s3,0x17
    800023d4:	23098993          	addi	s3,s3,560 # 80019600 <tickslock>
    sleep(p, &wait_lock); // DOC: wait-sleep
    800023d8:	00011b17          	auipc	s6,0x11
    800023dc:	3f8b0b13          	addi	s6,s6,1016 # 800137d0 <wait_lock>
    800023e0:	a869                	j	8000247a <kwait+0xd8>
          pid = pp->pid;
    800023e2:	0304a983          	lw	s3,48(s1)
          if (addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    800023e6:	000b8c63          	beqz	s7,800023fe <kwait+0x5c>
    800023ea:	4691                	li	a3,4
    800023ec:	02c48613          	addi	a2,s1,44
    800023f0:	85de                	mv	a1,s7
    800023f2:	05093503          	ld	a0,80(s2)
    800023f6:	a98ff0ef          	jal	8000168e <copyout>
    800023fa:	02054a63          	bltz	a0,8000242e <kwait+0x8c>
          freeproc(pp);
    800023fe:	8526                	mv	a0,s1
    80002400:	f50ff0ef          	jal	80001b50 <freeproc>
          release(&pp->lock);
    80002404:	8526                	mv	a0,s1
    80002406:	8e9fe0ef          	jal	80000cee <release>
          release(&wait_lock);
    8000240a:	00011517          	auipc	a0,0x11
    8000240e:	3c650513          	addi	a0,a0,966 # 800137d0 <wait_lock>
    80002412:	8ddfe0ef          	jal	80000cee <release>
}
    80002416:	854e                	mv	a0,s3
    80002418:	60a6                	ld	ra,72(sp)
    8000241a:	6406                	ld	s0,64(sp)
    8000241c:	74e2                	ld	s1,56(sp)
    8000241e:	7942                	ld	s2,48(sp)
    80002420:	79a2                	ld	s3,40(sp)
    80002422:	7a02                	ld	s4,32(sp)
    80002424:	6ae2                	ld	s5,24(sp)
    80002426:	6b42                	ld	s6,16(sp)
    80002428:	6ba2                	ld	s7,8(sp)
    8000242a:	6161                	addi	sp,sp,80
    8000242c:	8082                	ret
            release(&pp->lock);
    8000242e:	8526                	mv	a0,s1
    80002430:	8bffe0ef          	jal	80000cee <release>
            release(&wait_lock);
    80002434:	00011517          	auipc	a0,0x11
    80002438:	39c50513          	addi	a0,a0,924 # 800137d0 <wait_lock>
    8000243c:	8b3fe0ef          	jal	80000cee <release>
            return -1;
    80002440:	59fd                	li	s3,-1
    80002442:	bfd1                	j	80002416 <kwait+0x74>
    for (pp = proc; pp < &proc[NPROC]; pp++) {
    80002444:	16848493          	addi	s1,s1,360
    80002448:	03348063          	beq	s1,s3,80002468 <kwait+0xc6>
      if (pp->parent == p) {
    8000244c:	7c9c                	ld	a5,56(s1)
    8000244e:	ff279be3          	bne	a5,s2,80002444 <kwait+0xa2>
        acquire(&pp->lock);
    80002452:	8526                	mv	a0,s1
    80002454:	807fe0ef          	jal	80000c5a <acquire>
        if (pp->state == ZOMBIE) {
    80002458:	4c9c                	lw	a5,24(s1)
    8000245a:	f94784e3          	beq	a5,s4,800023e2 <kwait+0x40>
        release(&pp->lock);
    8000245e:	8526                	mv	a0,s1
    80002460:	88ffe0ef          	jal	80000cee <release>
        havekids = 1;
    80002464:	8756                	mv	a4,s5
    80002466:	bff9                	j	80002444 <kwait+0xa2>
    if (!havekids || killed(p)) {
    80002468:	cf19                	beqz	a4,80002486 <kwait+0xe4>
    8000246a:	854a                	mv	a0,s2
    8000246c:	f0dff0ef          	jal	80002378 <killed>
    80002470:	e919                	bnez	a0,80002486 <kwait+0xe4>
    sleep(p, &wait_lock); // DOC: wait-sleep
    80002472:	85da                	mv	a1,s6
    80002474:	854a                	mv	a0,s2
    80002476:	cc7ff0ef          	jal	8000213c <sleep>
    havekids = 0;
    8000247a:	4701                	li	a4,0
    for (pp = proc; pp < &proc[NPROC]; pp++) {
    8000247c:	00011497          	auipc	s1,0x11
    80002480:	78448493          	addi	s1,s1,1924 # 80013c00 <proc>
    80002484:	b7e1                	j	8000244c <kwait+0xaa>
      release(&wait_lock);
    80002486:	00011517          	auipc	a0,0x11
    8000248a:	34a50513          	addi	a0,a0,842 # 800137d0 <wait_lock>
    8000248e:	861fe0ef          	jal	80000cee <release>
      return -1;
    80002492:	59fd                	li	s3,-1
    80002494:	b749                	j	80002416 <kwait+0x74>

0000000080002496 <either_copyout>:

// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int either_copyout(int user_dst, uint64 dst, void *src, uint64 len) {
    80002496:	7179                	addi	sp,sp,-48
    80002498:	f406                	sd	ra,40(sp)
    8000249a:	f022                	sd	s0,32(sp)
    8000249c:	ec26                	sd	s1,24(sp)
    8000249e:	e84a                	sd	s2,16(sp)
    800024a0:	e44e                	sd	s3,8(sp)
    800024a2:	e052                	sd	s4,0(sp)
    800024a4:	1800                	addi	s0,sp,48
    800024a6:	84aa                	mv	s1,a0
    800024a8:	8a2e                	mv	s4,a1
    800024aa:	89b2                	mv	s3,a2
    800024ac:	8936                	mv	s2,a3
  struct proc *p = myproc();
    800024ae:	cceff0ef          	jal	8000197c <myproc>
  if (user_dst) {
    800024b2:	cc99                	beqz	s1,800024d0 <either_copyout+0x3a>
    return copyout(p->pagetable, dst, src, len);
    800024b4:	86ca                	mv	a3,s2
    800024b6:	864e                	mv	a2,s3
    800024b8:	85d2                	mv	a1,s4
    800024ba:	6928                	ld	a0,80(a0)
    800024bc:	9d2ff0ef          	jal	8000168e <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    800024c0:	70a2                	ld	ra,40(sp)
    800024c2:	7402                	ld	s0,32(sp)
    800024c4:	64e2                	ld	s1,24(sp)
    800024c6:	6942                	ld	s2,16(sp)
    800024c8:	69a2                	ld	s3,8(sp)
    800024ca:	6a02                	ld	s4,0(sp)
    800024cc:	6145                	addi	sp,sp,48
    800024ce:	8082                	ret
    memmove((char *)dst, src, len);
    800024d0:	0009061b          	sext.w	a2,s2
    800024d4:	85ce                	mv	a1,s3
    800024d6:	8552                	mv	a0,s4
    800024d8:	8b3fe0ef          	jal	80000d8a <memmove>
    return 0;
    800024dc:	8526                	mv	a0,s1
    800024de:	b7cd                	j	800024c0 <either_copyout+0x2a>

00000000800024e0 <either_copyin>:

// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int either_copyin(void *dst, int user_src, uint64 src, uint64 len) {
    800024e0:	7179                	addi	sp,sp,-48
    800024e2:	f406                	sd	ra,40(sp)
    800024e4:	f022                	sd	s0,32(sp)
    800024e6:	ec26                	sd	s1,24(sp)
    800024e8:	e84a                	sd	s2,16(sp)
    800024ea:	e44e                	sd	s3,8(sp)
    800024ec:	e052                	sd	s4,0(sp)
    800024ee:	1800                	addi	s0,sp,48
    800024f0:	8a2a                	mv	s4,a0
    800024f2:	84ae                	mv	s1,a1
    800024f4:	89b2                	mv	s3,a2
    800024f6:	8936                	mv	s2,a3
  struct proc *p = myproc();
    800024f8:	c84ff0ef          	jal	8000197c <myproc>
  if (user_src) {
    800024fc:	cc99                	beqz	s1,8000251a <either_copyin+0x3a>
    return copyin(p->pagetable, dst, src, len);
    800024fe:	86ca                	mv	a3,s2
    80002500:	864e                	mv	a2,s3
    80002502:	85d2                	mv	a1,s4
    80002504:	6928                	ld	a0,80(a0)
    80002506:	a46ff0ef          	jal	8000174c <copyin>
  } else {
    memmove(dst, (char *)src, len);
    return 0;
  }
}
    8000250a:	70a2                	ld	ra,40(sp)
    8000250c:	7402                	ld	s0,32(sp)
    8000250e:	64e2                	ld	s1,24(sp)
    80002510:	6942                	ld	s2,16(sp)
    80002512:	69a2                	ld	s3,8(sp)
    80002514:	6a02                	ld	s4,0(sp)
    80002516:	6145                	addi	sp,sp,48
    80002518:	8082                	ret
    memmove(dst, (char *)src, len);
    8000251a:	0009061b          	sext.w	a2,s2
    8000251e:	85ce                	mv	a1,s3
    80002520:	8552                	mv	a0,s4
    80002522:	869fe0ef          	jal	80000d8a <memmove>
    return 0;
    80002526:	8526                	mv	a0,s1
    80002528:	b7cd                	j	8000250a <either_copyin+0x2a>

000000008000252a <procdump>:

// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void procdump(void) {
    8000252a:	715d                	addi	sp,sp,-80
    8000252c:	e486                	sd	ra,72(sp)
    8000252e:	e0a2                	sd	s0,64(sp)
    80002530:	fc26                	sd	s1,56(sp)
    80002532:	f84a                	sd	s2,48(sp)
    80002534:	f44e                	sd	s3,40(sp)
    80002536:	f052                	sd	s4,32(sp)
    80002538:	ec56                	sd	s5,24(sp)
    8000253a:	e85a                	sd	s6,16(sp)
    8000253c:	e45e                	sd	s7,8(sp)
    8000253e:	0880                	addi	s0,sp,80
      [UNUSED] "unused",   [USED] "used",      [SLEEPING] "sleep ",
      [RUNNABLE] "runble", [RUNNING] "run   ", [ZOMBIE] "zombie"};
  struct proc *p;
  char *state;

  printf("\n");
    80002540:	00006517          	auipc	a0,0x6
    80002544:	b4050513          	addi	a0,a0,-1216 # 80008080 <etext+0x80>
    80002548:	fe5fd0ef          	jal	8000052c <printf>
  for (p = proc; p < &proc[NPROC]; p++) {
    8000254c:	00012497          	auipc	s1,0x12
    80002550:	80c48493          	addi	s1,s1,-2036 # 80013d58 <proc+0x158>
    80002554:	00017917          	auipc	s2,0x17
    80002558:	20490913          	addi	s2,s2,516 # 80019758 <bcache+0x140>
    if (p->state == UNUSED)
      continue;
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000255c:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    8000255e:	00006997          	auipc	s3,0x6
    80002562:	cd298993          	addi	s3,s3,-814 # 80008230 <etext+0x230>
    printf("%d %s %s", p->pid, state, p->name);
    80002566:	00006a97          	auipc	s5,0x6
    8000256a:	cd2a8a93          	addi	s5,s5,-814 # 80008238 <etext+0x238>
    printf("\n");
    8000256e:	00006a17          	auipc	s4,0x6
    80002572:	b12a0a13          	addi	s4,s4,-1262 # 80008080 <etext+0x80>
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002576:	00006b97          	auipc	s7,0x6
    8000257a:	222b8b93          	addi	s7,s7,546 # 80008798 <states.0>
    8000257e:	a829                	j	80002598 <procdump+0x6e>
    printf("%d %s %s", p->pid, state, p->name);
    80002580:	ed86a583          	lw	a1,-296(a3)
    80002584:	8556                	mv	a0,s5
    80002586:	fa7fd0ef          	jal	8000052c <printf>
    printf("\n");
    8000258a:	8552                	mv	a0,s4
    8000258c:	fa1fd0ef          	jal	8000052c <printf>
  for (p = proc; p < &proc[NPROC]; p++) {
    80002590:	16848493          	addi	s1,s1,360
    80002594:	03248263          	beq	s1,s2,800025b8 <procdump+0x8e>
    if (p->state == UNUSED)
    80002598:	86a6                	mv	a3,s1
    8000259a:	ec04a783          	lw	a5,-320(s1)
    8000259e:	dbed                	beqz	a5,80002590 <procdump+0x66>
      state = "???";
    800025a0:	864e                	mv	a2,s3
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800025a2:	fcfb6fe3          	bltu	s6,a5,80002580 <procdump+0x56>
    800025a6:	02079713          	slli	a4,a5,0x20
    800025aa:	01d75793          	srli	a5,a4,0x1d
    800025ae:	97de                	add	a5,a5,s7
    800025b0:	6390                	ld	a2,0(a5)
    800025b2:	f679                	bnez	a2,80002580 <procdump+0x56>
      state = "???";
    800025b4:	864e                	mv	a2,s3
    800025b6:	b7e9                	j	80002580 <procdump+0x56>
  }
}
    800025b8:	60a6                	ld	ra,72(sp)
    800025ba:	6406                	ld	s0,64(sp)
    800025bc:	74e2                	ld	s1,56(sp)
    800025be:	7942                	ld	s2,48(sp)
    800025c0:	79a2                	ld	s3,40(sp)
    800025c2:	7a02                	ld	s4,32(sp)
    800025c4:	6ae2                	ld	s5,24(sp)
    800025c6:	6b42                	ld	s6,16(sp)
    800025c8:	6ba2                	ld	s7,8(sp)
    800025ca:	6161                	addi	sp,sp,80
    800025cc:	8082                	ret

00000000800025ce <swtch>:
# Save current registers in old. Load from new.	


.globl swtch
swtch:
        sd ra, 0(a0)
    800025ce:	00153023          	sd	ra,0(a0)
        sd sp, 8(a0)
    800025d2:	00253423          	sd	sp,8(a0)
        sd s0, 16(a0)
    800025d6:	e900                	sd	s0,16(a0)
        sd s1, 24(a0)
    800025d8:	ed04                	sd	s1,24(a0)
        sd s2, 32(a0)
    800025da:	03253023          	sd	s2,32(a0)
        sd s3, 40(a0)
    800025de:	03353423          	sd	s3,40(a0)
        sd s4, 48(a0)
    800025e2:	03453823          	sd	s4,48(a0)
        sd s5, 56(a0)
    800025e6:	03553c23          	sd	s5,56(a0)
        sd s6, 64(a0)
    800025ea:	05653023          	sd	s6,64(a0)
        sd s7, 72(a0)
    800025ee:	05753423          	sd	s7,72(a0)
        sd s8, 80(a0)
    800025f2:	05853823          	sd	s8,80(a0)
        sd s9, 88(a0)
    800025f6:	05953c23          	sd	s9,88(a0)
        sd s10, 96(a0)
    800025fa:	07a53023          	sd	s10,96(a0)
        sd s11, 104(a0)
    800025fe:	07b53423          	sd	s11,104(a0)

        ld ra, 0(a1)
    80002602:	0005b083          	ld	ra,0(a1)
        ld sp, 8(a1)
    80002606:	0085b103          	ld	sp,8(a1)
        ld s0, 16(a1)
    8000260a:	6980                	ld	s0,16(a1)
        ld s1, 24(a1)
    8000260c:	6d84                	ld	s1,24(a1)
        ld s2, 32(a1)
    8000260e:	0205b903          	ld	s2,32(a1)
        ld s3, 40(a1)
    80002612:	0285b983          	ld	s3,40(a1)
        ld s4, 48(a1)
    80002616:	0305ba03          	ld	s4,48(a1)
        ld s5, 56(a1)
    8000261a:	0385ba83          	ld	s5,56(a1)
        ld s6, 64(a1)
    8000261e:	0405bb03          	ld	s6,64(a1)
        ld s7, 72(a1)
    80002622:	0485bb83          	ld	s7,72(a1)
        ld s8, 80(a1)
    80002626:	0505bc03          	ld	s8,80(a1)
        ld s9, 88(a1)
    8000262a:	0585bc83          	ld	s9,88(a1)
        ld s10, 96(a1)
    8000262e:	0605bd03          	ld	s10,96(a1)
        ld s11, 104(a1)
    80002632:	0685bd83          	ld	s11,104(a1)
        
        ret
    80002636:	8082                	ret

0000000080002638 <trapinit>:

extern int devintr();

void
trapinit(void)
{
    80002638:	1141                	addi	sp,sp,-16
    8000263a:	e406                	sd	ra,8(sp)
    8000263c:	e022                	sd	s0,0(sp)
    8000263e:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    80002640:	00006597          	auipc	a1,0x6
    80002644:	c3858593          	addi	a1,a1,-968 # 80008278 <etext+0x278>
    80002648:	00017517          	auipc	a0,0x17
    8000264c:	fb850513          	addi	a0,a0,-72 # 80019600 <tickslock>
    80002650:	d80fe0ef          	jal	80000bd0 <initlock>
}
    80002654:	60a2                	ld	ra,8(sp)
    80002656:	6402                	ld	s0,0(sp)
    80002658:	0141                	addi	sp,sp,16
    8000265a:	8082                	ret

000000008000265c <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    8000265c:	1141                	addi	sp,sp,-16
    8000265e:	e406                	sd	ra,8(sp)
    80002660:	e022                	sd	s0,0(sp)
    80002662:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002664:	00003797          	auipc	a5,0x3
    80002668:	0ac78793          	addi	a5,a5,172 # 80005710 <kernelvec>
    8000266c:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    80002670:	60a2                	ld	ra,8(sp)
    80002672:	6402                	ld	s0,0(sp)
    80002674:	0141                	addi	sp,sp,16
    80002676:	8082                	ret

0000000080002678 <prepare_return>:
//
// set up trapframe and control registers for a return to user space
//
void
prepare_return(void)
{
    80002678:	1141                	addi	sp,sp,-16
    8000267a:	e406                	sd	ra,8(sp)
    8000267c:	e022                	sd	s0,0(sp)
    8000267e:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    80002680:	afcff0ef          	jal	8000197c <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002684:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80002688:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000268a:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(). because a trap from kernel
  // code to usertrap would be a disaster, turn off interrupts.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    8000268e:	04000737          	lui	a4,0x4000
    80002692:	177d                	addi	a4,a4,-1 # 3ffffff <_entry-0x7c000001>
    80002694:	0732                	slli	a4,a4,0xc
    80002696:	00005797          	auipc	a5,0x5
    8000269a:	96a78793          	addi	a5,a5,-1686 # 80007000 <_trampoline>
    8000269e:	00005697          	auipc	a3,0x5
    800026a2:	96268693          	addi	a3,a3,-1694 # 80007000 <_trampoline>
    800026a6:	8f95                	sub	a5,a5,a3
    800026a8:	97ba                	add	a5,a5,a4
  asm volatile("csrw stvec, %0" : : "r" (x));
    800026aa:	10579073          	csrw	stvec,a5
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    800026ae:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    800026b0:	18002773          	csrr	a4,satp
    800026b4:	e398                	sd	a4,0(a5)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    800026b6:	6d38                	ld	a4,88(a0)
    800026b8:	613c                	ld	a5,64(a0)
    800026ba:	6685                	lui	a3,0x1
    800026bc:	97b6                	add	a5,a5,a3
    800026be:	e71c                	sd	a5,8(a4)
  p->trapframe->kernel_trap = (uint64)usertrap;
    800026c0:	6d3c                	ld	a5,88(a0)
    800026c2:	00000717          	auipc	a4,0x0
    800026c6:	0fc70713          	addi	a4,a4,252 # 800027be <usertrap>
    800026ca:	eb98                	sd	a4,16(a5)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    800026cc:	6d3c                	ld	a5,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    800026ce:	8712                	mv	a4,tp
    800026d0:	f398                	sd	a4,32(a5)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800026d2:	100027f3          	csrr	a5,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    800026d6:	eff7f793          	andi	a5,a5,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    800026da:	0207e793          	ori	a5,a5,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800026de:	10079073          	csrw	sstatus,a5
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    800026e2:	6d3c                	ld	a5,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    800026e4:	6f9c                	ld	a5,24(a5)
    800026e6:	14179073          	csrw	sepc,a5
}
    800026ea:	60a2                	ld	ra,8(sp)
    800026ec:	6402                	ld	s0,0(sp)
    800026ee:	0141                	addi	sp,sp,16
    800026f0:	8082                	ret

00000000800026f2 <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    800026f2:	1141                	addi	sp,sp,-16
    800026f4:	e406                	sd	ra,8(sp)
    800026f6:	e022                	sd	s0,0(sp)
    800026f8:	0800                	addi	s0,sp,16
  if(cpuid() == 0){
    800026fa:	a4eff0ef          	jal	80001948 <cpuid>
    800026fe:	cd11                	beqz	a0,8000271a <clockintr+0x28>
  asm volatile("csrr %0, time" : "=r" (x) );
    80002700:	c01027f3          	rdtime	a5
  }

  // ask for the next timer interrupt. this also clears
  // the interrupt request. 1000000 is about a tenth
  // of a second.
  w_stimecmp(r_time() + 1000000);
    80002704:	000f4737          	lui	a4,0xf4
    80002708:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    8000270c:	97ba                	add	a5,a5,a4
  asm volatile("csrw 0x14d, %0" : : "r" (x));
    8000270e:	14d79073          	csrw	stimecmp,a5
}
    80002712:	60a2                	ld	ra,8(sp)
    80002714:	6402                	ld	s0,0(sp)
    80002716:	0141                	addi	sp,sp,16
    80002718:	8082                	ret
    acquire(&tickslock);
    8000271a:	00017517          	auipc	a0,0x17
    8000271e:	ee650513          	addi	a0,a0,-282 # 80019600 <tickslock>
    80002722:	d38fe0ef          	jal	80000c5a <acquire>
    ticks++;
    80002726:	00009717          	auipc	a4,0x9
    8000272a:	f4a70713          	addi	a4,a4,-182 # 8000b670 <ticks>
    8000272e:	431c                	lw	a5,0(a4)
    80002730:	2785                	addiw	a5,a5,1
    80002732:	c31c                	sw	a5,0(a4)
    wakeup(&ticks);
    80002734:	853a                	mv	a0,a4
    80002736:	a53ff0ef          	jal	80002188 <wakeup>
    release(&tickslock);
    8000273a:	00017517          	auipc	a0,0x17
    8000273e:	ec650513          	addi	a0,a0,-314 # 80019600 <tickslock>
    80002742:	dacfe0ef          	jal	80000cee <release>
    80002746:	bf6d                	j	80002700 <clockintr+0xe>

0000000080002748 <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    80002748:	1101                	addi	sp,sp,-32
    8000274a:	ec06                	sd	ra,24(sp)
    8000274c:	e822                	sd	s0,16(sp)
    8000274e:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002750:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if(scause == 0x8000000000000009L){
    80002754:	57fd                	li	a5,-1
    80002756:	17fe                	slli	a5,a5,0x3f
    80002758:	07a5                	addi	a5,a5,9
    8000275a:	00f70c63          	beq	a4,a5,80002772 <devintr+0x2a>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000005L){
    8000275e:	57fd                	li	a5,-1
    80002760:	17fe                	slli	a5,a5,0x3f
    80002762:	0795                	addi	a5,a5,5
    // timer interrupt.
    clockintr();
    return 2;
  } else {
    return 0;
    80002764:	4501                	li	a0,0
  } else if(scause == 0x8000000000000005L){
    80002766:	04f70863          	beq	a4,a5,800027b6 <devintr+0x6e>
  }
}
    8000276a:	60e2                	ld	ra,24(sp)
    8000276c:	6442                	ld	s0,16(sp)
    8000276e:	6105                	addi	sp,sp,32
    80002770:	8082                	ret
    80002772:	e426                	sd	s1,8(sp)
    int irq = plic_claim();
    80002774:	048030ef          	jal	800057bc <plic_claim>
    80002778:	872a                	mv	a4,a0
    8000277a:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    8000277c:	47a9                	li	a5,10
    8000277e:	00f50963          	beq	a0,a5,80002790 <devintr+0x48>
    } else if(irq == VIRTIO0_IRQ){
    80002782:	4785                	li	a5,1
    80002784:	00f50963          	beq	a0,a5,80002796 <devintr+0x4e>
    return 1;
    80002788:	4505                	li	a0,1
    } else if(irq){
    8000278a:	eb09                	bnez	a4,8000279c <devintr+0x54>
    8000278c:	64a2                	ld	s1,8(sp)
    8000278e:	bff1                	j	8000276a <devintr+0x22>
      uartintr();
    80002790:	a96fe0ef          	jal	80000a26 <uartintr>
    if(irq)
    80002794:	a819                	j	800027aa <devintr+0x62>
      virtio_disk_intr();
    80002796:	4bc030ef          	jal	80005c52 <virtio_disk_intr>
    if(irq)
    8000279a:	a801                	j	800027aa <devintr+0x62>
      printf("unexpected interrupt irq=%d\n", irq);
    8000279c:	85ba                	mv	a1,a4
    8000279e:	00006517          	auipc	a0,0x6
    800027a2:	ae250513          	addi	a0,a0,-1310 # 80008280 <etext+0x280>
    800027a6:	d87fd0ef          	jal	8000052c <printf>
      plic_complete(irq);
    800027aa:	8526                	mv	a0,s1
    800027ac:	030030ef          	jal	800057dc <plic_complete>
    return 1;
    800027b0:	4505                	li	a0,1
    800027b2:	64a2                	ld	s1,8(sp)
    800027b4:	bf5d                	j	8000276a <devintr+0x22>
    clockintr();
    800027b6:	f3dff0ef          	jal	800026f2 <clockintr>
    return 2;
    800027ba:	4509                	li	a0,2
    800027bc:	b77d                	j	8000276a <devintr+0x22>

00000000800027be <usertrap>:
{
    800027be:	1101                	addi	sp,sp,-32
    800027c0:	ec06                	sd	ra,24(sp)
    800027c2:	e822                	sd	s0,16(sp)
    800027c4:	e426                	sd	s1,8(sp)
    800027c6:	e04a                	sd	s2,0(sp)
    800027c8:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800027ca:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    800027ce:	1007f793          	andi	a5,a5,256
    800027d2:	eba5                	bnez	a5,80002842 <usertrap+0x84>
  asm volatile("csrw stvec, %0" : : "r" (x));
    800027d4:	00003797          	auipc	a5,0x3
    800027d8:	f3c78793          	addi	a5,a5,-196 # 80005710 <kernelvec>
    800027dc:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    800027e0:	99cff0ef          	jal	8000197c <myproc>
    800027e4:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    800027e6:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800027e8:	14102773          	csrr	a4,sepc
    800027ec:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    800027ee:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    800027f2:	47a1                	li	a5,8
    800027f4:	04f70d63          	beq	a4,a5,8000284e <usertrap+0x90>
  } else if((which_dev = devintr()) != 0){
    800027f8:	f51ff0ef          	jal	80002748 <devintr>
    800027fc:	892a                	mv	s2,a0
    800027fe:	e945                	bnez	a0,800028ae <usertrap+0xf0>
    80002800:	14202773          	csrr	a4,scause
  } else if((r_scause() == 15 || r_scause() == 13) &&
    80002804:	47bd                	li	a5,15
    80002806:	08f70863          	beq	a4,a5,80002896 <usertrap+0xd8>
    8000280a:	14202773          	csrr	a4,scause
    8000280e:	47b5                	li	a5,13
    80002810:	08f70363          	beq	a4,a5,80002896 <usertrap+0xd8>
    80002814:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause 0x%lx pid=%d\n", r_scause(), p->pid);
    80002818:	5890                	lw	a2,48(s1)
    8000281a:	00006517          	auipc	a0,0x6
    8000281e:	aa650513          	addi	a0,a0,-1370 # 800082c0 <etext+0x2c0>
    80002822:	d0bfd0ef          	jal	8000052c <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002826:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    8000282a:	14302673          	csrr	a2,stval
    printf("            sepc=0x%lx stval=0x%lx\n", r_sepc(), r_stval());
    8000282e:	00006517          	auipc	a0,0x6
    80002832:	ac250513          	addi	a0,a0,-1342 # 800082f0 <etext+0x2f0>
    80002836:	cf7fd0ef          	jal	8000052c <printf>
    setkilled(p);
    8000283a:	8526                	mv	a0,s1
    8000283c:	b19ff0ef          	jal	80002354 <setkilled>
    80002840:	a035                	j	8000286c <usertrap+0xae>
    panic("usertrap: not from user mode");
    80002842:	00006517          	auipc	a0,0x6
    80002846:	a5e50513          	addi	a0,a0,-1442 # 800082a0 <etext+0x2a0>
    8000284a:	80cfe0ef          	jal	80000856 <panic>
    if(killed(p))
    8000284e:	b2bff0ef          	jal	80002378 <killed>
    80002852:	ed15                	bnez	a0,8000288e <usertrap+0xd0>
    p->trapframe->epc += 4;
    80002854:	6cb8                	ld	a4,88(s1)
    80002856:	6f1c                	ld	a5,24(a4)
    80002858:	0791                	addi	a5,a5,4
    8000285a:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000285c:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002860:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002864:	10079073          	csrw	sstatus,a5
    syscall();
    80002868:	240000ef          	jal	80002aa8 <syscall>
  if(killed(p))
    8000286c:	8526                	mv	a0,s1
    8000286e:	b0bff0ef          	jal	80002378 <killed>
    80002872:	e139                	bnez	a0,800028b8 <usertrap+0xfa>
  prepare_return();
    80002874:	e05ff0ef          	jal	80002678 <prepare_return>
  uint64 satp = MAKE_SATP(p->pagetable);
    80002878:	68a8                	ld	a0,80(s1)
    8000287a:	8131                	srli	a0,a0,0xc
    8000287c:	57fd                	li	a5,-1
    8000287e:	17fe                	slli	a5,a5,0x3f
    80002880:	8d5d                	or	a0,a0,a5
}
    80002882:	60e2                	ld	ra,24(sp)
    80002884:	6442                	ld	s0,16(sp)
    80002886:	64a2                	ld	s1,8(sp)
    80002888:	6902                	ld	s2,0(sp)
    8000288a:	6105                	addi	sp,sp,32
    8000288c:	8082                	ret
      kexit(-1);
    8000288e:	557d                	li	a0,-1
    80002890:	9b9ff0ef          	jal	80002248 <kexit>
    80002894:	b7c1                	j	80002854 <usertrap+0x96>
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002896:	143025f3          	csrr	a1,stval
  asm volatile("csrr %0, scause" : "=r" (x) );
    8000289a:	14202673          	csrr	a2,scause
            vmfault(p->pagetable, r_stval(), (r_scause() == 13)? 1 : 0) != 0) {
    8000289e:	164d                	addi	a2,a2,-13 # ff3 <_entry-0x7ffff00d>
    800028a0:	00163613          	seqz	a2,a2
    800028a4:	68a8                	ld	a0,80(s1)
    800028a6:	d65fe0ef          	jal	8000160a <vmfault>
  } else if((r_scause() == 15 || r_scause() == 13) &&
    800028aa:	f169                	bnez	a0,8000286c <usertrap+0xae>
    800028ac:	b7a5                	j	80002814 <usertrap+0x56>
  if(killed(p))
    800028ae:	8526                	mv	a0,s1
    800028b0:	ac9ff0ef          	jal	80002378 <killed>
    800028b4:	c511                	beqz	a0,800028c0 <usertrap+0x102>
    800028b6:	a011                	j	800028ba <usertrap+0xfc>
    800028b8:	4901                	li	s2,0
    kexit(-1);
    800028ba:	557d                	li	a0,-1
    800028bc:	98dff0ef          	jal	80002248 <kexit>
  if(which_dev == 2)
    800028c0:	4789                	li	a5,2
    800028c2:	faf919e3          	bne	s2,a5,80002874 <usertrap+0xb6>
    yield();
    800028c6:	84bff0ef          	jal	80002110 <yield>
    800028ca:	b76d                	j	80002874 <usertrap+0xb6>

00000000800028cc <kerneltrap>:
{
    800028cc:	7179                	addi	sp,sp,-48
    800028ce:	f406                	sd	ra,40(sp)
    800028d0:	f022                	sd	s0,32(sp)
    800028d2:	ec26                	sd	s1,24(sp)
    800028d4:	e84a                	sd	s2,16(sp)
    800028d6:	e44e                	sd	s3,8(sp)
    800028d8:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800028da:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800028de:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    800028e2:	142027f3          	csrr	a5,scause
    800028e6:	89be                	mv	s3,a5
  if((sstatus & SSTATUS_SPP) == 0)
    800028e8:	1004f793          	andi	a5,s1,256
    800028ec:	c795                	beqz	a5,80002918 <kerneltrap+0x4c>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800028ee:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    800028f2:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    800028f4:	eb85                	bnez	a5,80002924 <kerneltrap+0x58>
  if((which_dev = devintr()) == 0){
    800028f6:	e53ff0ef          	jal	80002748 <devintr>
    800028fa:	c91d                	beqz	a0,80002930 <kerneltrap+0x64>
  if(which_dev == 2 && myproc() != 0)
    800028fc:	4789                	li	a5,2
    800028fe:	04f50a63          	beq	a0,a5,80002952 <kerneltrap+0x86>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002902:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002906:	10049073          	csrw	sstatus,s1
}
    8000290a:	70a2                	ld	ra,40(sp)
    8000290c:	7402                	ld	s0,32(sp)
    8000290e:	64e2                	ld	s1,24(sp)
    80002910:	6942                	ld	s2,16(sp)
    80002912:	69a2                	ld	s3,8(sp)
    80002914:	6145                	addi	sp,sp,48
    80002916:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80002918:	00006517          	auipc	a0,0x6
    8000291c:	a0050513          	addi	a0,a0,-1536 # 80008318 <etext+0x318>
    80002920:	f37fd0ef          	jal	80000856 <panic>
    panic("kerneltrap: interrupts enabled");
    80002924:	00006517          	auipc	a0,0x6
    80002928:	a1c50513          	addi	a0,a0,-1508 # 80008340 <etext+0x340>
    8000292c:	f2bfd0ef          	jal	80000856 <panic>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002930:	14102673          	csrr	a2,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002934:	143026f3          	csrr	a3,stval
    printf("scause=0x%lx sepc=0x%lx stval=0x%lx\n", scause, r_sepc(), r_stval());
    80002938:	85ce                	mv	a1,s3
    8000293a:	00006517          	auipc	a0,0x6
    8000293e:	a2650513          	addi	a0,a0,-1498 # 80008360 <etext+0x360>
    80002942:	bebfd0ef          	jal	8000052c <printf>
    panic("kerneltrap");
    80002946:	00006517          	auipc	a0,0x6
    8000294a:	a4250513          	addi	a0,a0,-1470 # 80008388 <etext+0x388>
    8000294e:	f09fd0ef          	jal	80000856 <panic>
  if(which_dev == 2 && myproc() != 0)
    80002952:	82aff0ef          	jal	8000197c <myproc>
    80002956:	d555                	beqz	a0,80002902 <kerneltrap+0x36>
    yield();
    80002958:	fb8ff0ef          	jal	80002110 <yield>
    8000295c:	b75d                	j	80002902 <kerneltrap+0x36>

000000008000295e <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    8000295e:	1101                	addi	sp,sp,-32
    80002960:	ec06                	sd	ra,24(sp)
    80002962:	e822                	sd	s0,16(sp)
    80002964:	e426                	sd	s1,8(sp)
    80002966:	1000                	addi	s0,sp,32
    80002968:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    8000296a:	812ff0ef          	jal	8000197c <myproc>
  switch (n) {
    8000296e:	4795                	li	a5,5
    80002970:	0497e163          	bltu	a5,s1,800029b2 <argraw+0x54>
    80002974:	048a                	slli	s1,s1,0x2
    80002976:	00006717          	auipc	a4,0x6
    8000297a:	e5270713          	addi	a4,a4,-430 # 800087c8 <states.0+0x30>
    8000297e:	94ba                	add	s1,s1,a4
    80002980:	409c                	lw	a5,0(s1)
    80002982:	97ba                	add	a5,a5,a4
    80002984:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    80002986:	6d3c                	ld	a5,88(a0)
    80002988:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    8000298a:	60e2                	ld	ra,24(sp)
    8000298c:	6442                	ld	s0,16(sp)
    8000298e:	64a2                	ld	s1,8(sp)
    80002990:	6105                	addi	sp,sp,32
    80002992:	8082                	ret
    return p->trapframe->a1;
    80002994:	6d3c                	ld	a5,88(a0)
    80002996:	7fa8                	ld	a0,120(a5)
    80002998:	bfcd                	j	8000298a <argraw+0x2c>
    return p->trapframe->a2;
    8000299a:	6d3c                	ld	a5,88(a0)
    8000299c:	63c8                	ld	a0,128(a5)
    8000299e:	b7f5                	j	8000298a <argraw+0x2c>
    return p->trapframe->a3;
    800029a0:	6d3c                	ld	a5,88(a0)
    800029a2:	67c8                	ld	a0,136(a5)
    800029a4:	b7dd                	j	8000298a <argraw+0x2c>
    return p->trapframe->a4;
    800029a6:	6d3c                	ld	a5,88(a0)
    800029a8:	6bc8                	ld	a0,144(a5)
    800029aa:	b7c5                	j	8000298a <argraw+0x2c>
    return p->trapframe->a5;
    800029ac:	6d3c                	ld	a5,88(a0)
    800029ae:	6fc8                	ld	a0,152(a5)
    800029b0:	bfe9                	j	8000298a <argraw+0x2c>
  panic("argraw");
    800029b2:	00006517          	auipc	a0,0x6
    800029b6:	9e650513          	addi	a0,a0,-1562 # 80008398 <etext+0x398>
    800029ba:	e9dfd0ef          	jal	80000856 <panic>

00000000800029be <fetchaddr>:
{
    800029be:	1101                	addi	sp,sp,-32
    800029c0:	ec06                	sd	ra,24(sp)
    800029c2:	e822                	sd	s0,16(sp)
    800029c4:	e426                	sd	s1,8(sp)
    800029c6:	e04a                	sd	s2,0(sp)
    800029c8:	1000                	addi	s0,sp,32
    800029ca:	84aa                	mv	s1,a0
    800029cc:	892e                	mv	s2,a1
  struct proc *p = myproc();
    800029ce:	faffe0ef          	jal	8000197c <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    800029d2:	653c                	ld	a5,72(a0)
    800029d4:	02f4f663          	bgeu	s1,a5,80002a00 <fetchaddr+0x42>
    800029d8:	00848713          	addi	a4,s1,8
    800029dc:	02e7e463          	bltu	a5,a4,80002a04 <fetchaddr+0x46>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    800029e0:	46a1                	li	a3,8
    800029e2:	8626                	mv	a2,s1
    800029e4:	85ca                	mv	a1,s2
    800029e6:	6928                	ld	a0,80(a0)
    800029e8:	d65fe0ef          	jal	8000174c <copyin>
    800029ec:	00a03533          	snez	a0,a0
    800029f0:	40a0053b          	negw	a0,a0
}
    800029f4:	60e2                	ld	ra,24(sp)
    800029f6:	6442                	ld	s0,16(sp)
    800029f8:	64a2                	ld	s1,8(sp)
    800029fa:	6902                	ld	s2,0(sp)
    800029fc:	6105                	addi	sp,sp,32
    800029fe:	8082                	ret
    return -1;
    80002a00:	557d                	li	a0,-1
    80002a02:	bfcd                	j	800029f4 <fetchaddr+0x36>
    80002a04:	557d                	li	a0,-1
    80002a06:	b7fd                	j	800029f4 <fetchaddr+0x36>

0000000080002a08 <fetchstr>:
{
    80002a08:	7179                	addi	sp,sp,-48
    80002a0a:	f406                	sd	ra,40(sp)
    80002a0c:	f022                	sd	s0,32(sp)
    80002a0e:	ec26                	sd	s1,24(sp)
    80002a10:	e84a                	sd	s2,16(sp)
    80002a12:	e44e                	sd	s3,8(sp)
    80002a14:	1800                	addi	s0,sp,48
    80002a16:	89aa                	mv	s3,a0
    80002a18:	84ae                	mv	s1,a1
    80002a1a:	8932                	mv	s2,a2
  struct proc *p = myproc();
    80002a1c:	f61fe0ef          	jal	8000197c <myproc>
  if(copyinstr(p->pagetable, buf, addr, max) < 0)
    80002a20:	86ca                	mv	a3,s2
    80002a22:	864e                	mv	a2,s3
    80002a24:	85a6                	mv	a1,s1
    80002a26:	6928                	ld	a0,80(a0)
    80002a28:	b0bfe0ef          	jal	80001532 <copyinstr>
    80002a2c:	00054c63          	bltz	a0,80002a44 <fetchstr+0x3c>
  return strlen(buf);
    80002a30:	8526                	mv	a0,s1
    80002a32:	c82fe0ef          	jal	80000eb4 <strlen>
}
    80002a36:	70a2                	ld	ra,40(sp)
    80002a38:	7402                	ld	s0,32(sp)
    80002a3a:	64e2                	ld	s1,24(sp)
    80002a3c:	6942                	ld	s2,16(sp)
    80002a3e:	69a2                	ld	s3,8(sp)
    80002a40:	6145                	addi	sp,sp,48
    80002a42:	8082                	ret
    return -1;
    80002a44:	557d                	li	a0,-1
    80002a46:	bfc5                	j	80002a36 <fetchstr+0x2e>

0000000080002a48 <argint>:

// Fetch the nth 32-bit system call argument.
void
argint(int n, int *ip)
{
    80002a48:	1101                	addi	sp,sp,-32
    80002a4a:	ec06                	sd	ra,24(sp)
    80002a4c:	e822                	sd	s0,16(sp)
    80002a4e:	e426                	sd	s1,8(sp)
    80002a50:	1000                	addi	s0,sp,32
    80002a52:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002a54:	f0bff0ef          	jal	8000295e <argraw>
    80002a58:	c088                	sw	a0,0(s1)
}
    80002a5a:	60e2                	ld	ra,24(sp)
    80002a5c:	6442                	ld	s0,16(sp)
    80002a5e:	64a2                	ld	s1,8(sp)
    80002a60:	6105                	addi	sp,sp,32
    80002a62:	8082                	ret

0000000080002a64 <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void
argaddr(int n, uint64 *ip)
{
    80002a64:	1101                	addi	sp,sp,-32
    80002a66:	ec06                	sd	ra,24(sp)
    80002a68:	e822                	sd	s0,16(sp)
    80002a6a:	e426                	sd	s1,8(sp)
    80002a6c:	1000                	addi	s0,sp,32
    80002a6e:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002a70:	eefff0ef          	jal	8000295e <argraw>
    80002a74:	e088                	sd	a0,0(s1)
}
    80002a76:	60e2                	ld	ra,24(sp)
    80002a78:	6442                	ld	s0,16(sp)
    80002a7a:	64a2                	ld	s1,8(sp)
    80002a7c:	6105                	addi	sp,sp,32
    80002a7e:	8082                	ret

0000000080002a80 <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80002a80:	1101                	addi	sp,sp,-32
    80002a82:	ec06                	sd	ra,24(sp)
    80002a84:	e822                	sd	s0,16(sp)
    80002a86:	e426                	sd	s1,8(sp)
    80002a88:	e04a                	sd	s2,0(sp)
    80002a8a:	1000                	addi	s0,sp,32
    80002a8c:	892e                	mv	s2,a1
    80002a8e:	84b2                	mv	s1,a2
  *ip = argraw(n);
    80002a90:	ecfff0ef          	jal	8000295e <argraw>
  uint64 addr;
  argaddr(n, &addr);
  return fetchstr(addr, buf, max);
    80002a94:	8626                	mv	a2,s1
    80002a96:	85ca                	mv	a1,s2
    80002a98:	f71ff0ef          	jal	80002a08 <fetchstr>
}
    80002a9c:	60e2                	ld	ra,24(sp)
    80002a9e:	6442                	ld	s0,16(sp)
    80002aa0:	64a2                	ld	s1,8(sp)
    80002aa2:	6902                	ld	s2,0(sp)
    80002aa4:	6105                	addi	sp,sp,32
    80002aa6:	8082                	ret

0000000080002aa8 <syscall>:

};

void
syscall(void)
{
    80002aa8:	1101                	addi	sp,sp,-32
    80002aaa:	ec06                	sd	ra,24(sp)
    80002aac:	e822                	sd	s0,16(sp)
    80002aae:	e426                	sd	s1,8(sp)
    80002ab0:	e04a                	sd	s2,0(sp)
    80002ab2:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    80002ab4:	ec9fe0ef          	jal	8000197c <myproc>
    80002ab8:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    80002aba:	05853903          	ld	s2,88(a0)
    80002abe:	0a893783          	ld	a5,168(s2)
    80002ac2:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80002ac6:	37fd                	addiw	a5,a5,-1
    80002ac8:	475d                	li	a4,23
    80002aca:	00f76f63          	bltu	a4,a5,80002ae8 <syscall+0x40>
    80002ace:	00369713          	slli	a4,a3,0x3
    80002ad2:	00006797          	auipc	a5,0x6
    80002ad6:	d0e78793          	addi	a5,a5,-754 # 800087e0 <syscalls>
    80002ada:	97ba                	add	a5,a5,a4
    80002adc:	639c                	ld	a5,0(a5)
    80002ade:	c789                	beqz	a5,80002ae8 <syscall+0x40>
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    p->trapframe->a0 = syscalls[num]();
    80002ae0:	9782                	jalr	a5
    80002ae2:	06a93823          	sd	a0,112(s2)
    80002ae6:	a829                	j	80002b00 <syscall+0x58>
  } else {
    printf("%d %s: unknown sys call %d\n",
    80002ae8:	15848613          	addi	a2,s1,344
    80002aec:	588c                	lw	a1,48(s1)
    80002aee:	00006517          	auipc	a0,0x6
    80002af2:	8b250513          	addi	a0,a0,-1870 # 800083a0 <etext+0x3a0>
    80002af6:	a37fd0ef          	jal	8000052c <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80002afa:	6cbc                	ld	a5,88(s1)
    80002afc:	577d                	li	a4,-1
    80002afe:	fbb8                	sd	a4,112(a5)
  }
}
    80002b00:	60e2                	ld	ra,24(sp)
    80002b02:	6442                	ld	s0,16(sp)
    80002b04:	64a2                	ld	s1,8(sp)
    80002b06:	6902                	ld	s2,0(sp)
    80002b08:	6105                	addi	sp,sp,32
    80002b0a:	8082                	ret

0000000080002b0c <sys_exit>:
#include "vm.h"
#include "schedlog.h"

uint64
sys_exit(void)
{
    80002b0c:	1101                	addi	sp,sp,-32
    80002b0e:	ec06                	sd	ra,24(sp)
    80002b10:	e822                	sd	s0,16(sp)
    80002b12:	1000                	addi	s0,sp,32
  int n;
  argint(0, &n);
    80002b14:	fec40593          	addi	a1,s0,-20
    80002b18:	4501                	li	a0,0
    80002b1a:	f2fff0ef          	jal	80002a48 <argint>
  kexit(n);
    80002b1e:	fec42503          	lw	a0,-20(s0)
    80002b22:	f26ff0ef          	jal	80002248 <kexit>
  return 0;  // not reached
}
    80002b26:	4501                	li	a0,0
    80002b28:	60e2                	ld	ra,24(sp)
    80002b2a:	6442                	ld	s0,16(sp)
    80002b2c:	6105                	addi	sp,sp,32
    80002b2e:	8082                	ret

0000000080002b30 <sys_getpid>:

uint64
sys_getpid(void)
{
    80002b30:	1141                	addi	sp,sp,-16
    80002b32:	e406                	sd	ra,8(sp)
    80002b34:	e022                	sd	s0,0(sp)
    80002b36:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80002b38:	e45fe0ef          	jal	8000197c <myproc>
}
    80002b3c:	5908                	lw	a0,48(a0)
    80002b3e:	60a2                	ld	ra,8(sp)
    80002b40:	6402                	ld	s0,0(sp)
    80002b42:	0141                	addi	sp,sp,16
    80002b44:	8082                	ret

0000000080002b46 <sys_fork>:

uint64
sys_fork(void)
{
    80002b46:	1141                	addi	sp,sp,-16
    80002b48:	e406                	sd	ra,8(sp)
    80002b4a:	e022                	sd	s0,0(sp)
    80002b4c:	0800                	addi	s0,sp,16
  return kfork();
    80002b4e:	996ff0ef          	jal	80001ce4 <kfork>
}
    80002b52:	60a2                	ld	ra,8(sp)
    80002b54:	6402                	ld	s0,0(sp)
    80002b56:	0141                	addi	sp,sp,16
    80002b58:	8082                	ret

0000000080002b5a <sys_wait>:

uint64
sys_wait(void)
{
    80002b5a:	1101                	addi	sp,sp,-32
    80002b5c:	ec06                	sd	ra,24(sp)
    80002b5e:	e822                	sd	s0,16(sp)
    80002b60:	1000                	addi	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    80002b62:	fe840593          	addi	a1,s0,-24
    80002b66:	4501                	li	a0,0
    80002b68:	efdff0ef          	jal	80002a64 <argaddr>
  return kwait(p);
    80002b6c:	fe843503          	ld	a0,-24(s0)
    80002b70:	833ff0ef          	jal	800023a2 <kwait>
}
    80002b74:	60e2                	ld	ra,24(sp)
    80002b76:	6442                	ld	s0,16(sp)
    80002b78:	6105                	addi	sp,sp,32
    80002b7a:	8082                	ret

0000000080002b7c <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80002b7c:	7179                	addi	sp,sp,-48
    80002b7e:	f406                	sd	ra,40(sp)
    80002b80:	f022                	sd	s0,32(sp)
    80002b82:	ec26                	sd	s1,24(sp)
    80002b84:	1800                	addi	s0,sp,48
  uint64 addr;
  int t;
  int n;

  argint(0, &n);
    80002b86:	fd840593          	addi	a1,s0,-40
    80002b8a:	4501                	li	a0,0
    80002b8c:	ebdff0ef          	jal	80002a48 <argint>
  argint(1, &t);
    80002b90:	fdc40593          	addi	a1,s0,-36
    80002b94:	4505                	li	a0,1
    80002b96:	eb3ff0ef          	jal	80002a48 <argint>
  addr = myproc()->sz;
    80002b9a:	de3fe0ef          	jal	8000197c <myproc>
    80002b9e:	6524                	ld	s1,72(a0)

  if(t == SBRK_EAGER || n < 0) {
    80002ba0:	fdc42703          	lw	a4,-36(s0)
    80002ba4:	4785                	li	a5,1
    80002ba6:	02f70763          	beq	a4,a5,80002bd4 <sys_sbrk+0x58>
    80002baa:	fd842783          	lw	a5,-40(s0)
    80002bae:	0207c363          	bltz	a5,80002bd4 <sys_sbrk+0x58>
    }
  } else {
    // Lazily allocate memory for this process: increase its memory
    // size but don't allocate memory. If the processes uses the
    // memory, vmfault() will allocate it.
    if(addr + n < addr)
    80002bb2:	97a6                	add	a5,a5,s1
      return -1;
    if(addr + n > TRAPFRAME)
    80002bb4:	02000737          	lui	a4,0x2000
    80002bb8:	177d                	addi	a4,a4,-1 # 1ffffff <_entry-0x7e000001>
    80002bba:	0736                	slli	a4,a4,0xd
    80002bbc:	02f76a63          	bltu	a4,a5,80002bf0 <sys_sbrk+0x74>
    80002bc0:	0297e863          	bltu	a5,s1,80002bf0 <sys_sbrk+0x74>
      return -1;
    myproc()->sz += n;
    80002bc4:	db9fe0ef          	jal	8000197c <myproc>
    80002bc8:	fd842703          	lw	a4,-40(s0)
    80002bcc:	653c                	ld	a5,72(a0)
    80002bce:	97ba                	add	a5,a5,a4
    80002bd0:	e53c                	sd	a5,72(a0)
    80002bd2:	a039                	j	80002be0 <sys_sbrk+0x64>
    if(growproc(n) < 0) {
    80002bd4:	fd842503          	lw	a0,-40(s0)
    80002bd8:	8aaff0ef          	jal	80001c82 <growproc>
    80002bdc:	00054863          	bltz	a0,80002bec <sys_sbrk+0x70>
  }
  return addr;
}
    80002be0:	8526                	mv	a0,s1
    80002be2:	70a2                	ld	ra,40(sp)
    80002be4:	7402                	ld	s0,32(sp)
    80002be6:	64e2                	ld	s1,24(sp)
    80002be8:	6145                	addi	sp,sp,48
    80002bea:	8082                	ret
      return -1;
    80002bec:	54fd                	li	s1,-1
    80002bee:	bfcd                	j	80002be0 <sys_sbrk+0x64>
      return -1;
    80002bf0:	54fd                	li	s1,-1
    80002bf2:	b7fd                	j	80002be0 <sys_sbrk+0x64>

0000000080002bf4 <sys_pause>:

uint64
sys_pause(void)
{
    80002bf4:	7139                	addi	sp,sp,-64
    80002bf6:	fc06                	sd	ra,56(sp)
    80002bf8:	f822                	sd	s0,48(sp)
    80002bfa:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    80002bfc:	fcc40593          	addi	a1,s0,-52
    80002c00:	4501                	li	a0,0
    80002c02:	e47ff0ef          	jal	80002a48 <argint>
  if(n < 0)
    80002c06:	fcc42783          	lw	a5,-52(s0)
    80002c0a:	0607c863          	bltz	a5,80002c7a <sys_pause+0x86>
    n = 0;
  acquire(&tickslock);
    80002c0e:	00017517          	auipc	a0,0x17
    80002c12:	9f250513          	addi	a0,a0,-1550 # 80019600 <tickslock>
    80002c16:	844fe0ef          	jal	80000c5a <acquire>
  ticks0 = ticks;
  while(ticks - ticks0 < n){
    80002c1a:	fcc42783          	lw	a5,-52(s0)
    80002c1e:	c3b9                	beqz	a5,80002c64 <sys_pause+0x70>
    80002c20:	f426                	sd	s1,40(sp)
    80002c22:	f04a                	sd	s2,32(sp)
    80002c24:	ec4e                	sd	s3,24(sp)
  ticks0 = ticks;
    80002c26:	00009997          	auipc	s3,0x9
    80002c2a:	a4a9a983          	lw	s3,-1462(s3) # 8000b670 <ticks>
    if(killed(myproc())){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80002c2e:	00017917          	auipc	s2,0x17
    80002c32:	9d290913          	addi	s2,s2,-1582 # 80019600 <tickslock>
    80002c36:	00009497          	auipc	s1,0x9
    80002c3a:	a3a48493          	addi	s1,s1,-1478 # 8000b670 <ticks>
    if(killed(myproc())){
    80002c3e:	d3ffe0ef          	jal	8000197c <myproc>
    80002c42:	f36ff0ef          	jal	80002378 <killed>
    80002c46:	ed0d                	bnez	a0,80002c80 <sys_pause+0x8c>
    sleep(&ticks, &tickslock);
    80002c48:	85ca                	mv	a1,s2
    80002c4a:	8526                	mv	a0,s1
    80002c4c:	cf0ff0ef          	jal	8000213c <sleep>
  while(ticks - ticks0 < n){
    80002c50:	409c                	lw	a5,0(s1)
    80002c52:	413787bb          	subw	a5,a5,s3
    80002c56:	fcc42703          	lw	a4,-52(s0)
    80002c5a:	fee7e2e3          	bltu	a5,a4,80002c3e <sys_pause+0x4a>
    80002c5e:	74a2                	ld	s1,40(sp)
    80002c60:	7902                	ld	s2,32(sp)
    80002c62:	69e2                	ld	s3,24(sp)
  }
  release(&tickslock);
    80002c64:	00017517          	auipc	a0,0x17
    80002c68:	99c50513          	addi	a0,a0,-1636 # 80019600 <tickslock>
    80002c6c:	882fe0ef          	jal	80000cee <release>
  return 0;
    80002c70:	4501                	li	a0,0
}
    80002c72:	70e2                	ld	ra,56(sp)
    80002c74:	7442                	ld	s0,48(sp)
    80002c76:	6121                	addi	sp,sp,64
    80002c78:	8082                	ret
    n = 0;
    80002c7a:	fc042623          	sw	zero,-52(s0)
    80002c7e:	bf41                	j	80002c0e <sys_pause+0x1a>
      release(&tickslock);
    80002c80:	00017517          	auipc	a0,0x17
    80002c84:	98050513          	addi	a0,a0,-1664 # 80019600 <tickslock>
    80002c88:	866fe0ef          	jal	80000cee <release>
      return -1;
    80002c8c:	557d                	li	a0,-1
    80002c8e:	74a2                	ld	s1,40(sp)
    80002c90:	7902                	ld	s2,32(sp)
    80002c92:	69e2                	ld	s3,24(sp)
    80002c94:	bff9                	j	80002c72 <sys_pause+0x7e>

0000000080002c96 <sys_kill>:

uint64
sys_kill(void)
{
    80002c96:	1101                	addi	sp,sp,-32
    80002c98:	ec06                	sd	ra,24(sp)
    80002c9a:	e822                	sd	s0,16(sp)
    80002c9c:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    80002c9e:	fec40593          	addi	a1,s0,-20
    80002ca2:	4501                	li	a0,0
    80002ca4:	da5ff0ef          	jal	80002a48 <argint>
  return kkill(pid);
    80002ca8:	fec42503          	lw	a0,-20(s0)
    80002cac:	e42ff0ef          	jal	800022ee <kkill>
}
    80002cb0:	60e2                	ld	ra,24(sp)
    80002cb2:	6442                	ld	s0,16(sp)
    80002cb4:	6105                	addi	sp,sp,32
    80002cb6:	8082                	ret

0000000080002cb8 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80002cb8:	1101                	addi	sp,sp,-32
    80002cba:	ec06                	sd	ra,24(sp)
    80002cbc:	e822                	sd	s0,16(sp)
    80002cbe:	e426                	sd	s1,8(sp)
    80002cc0:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80002cc2:	00017517          	auipc	a0,0x17
    80002cc6:	93e50513          	addi	a0,a0,-1730 # 80019600 <tickslock>
    80002cca:	f91fd0ef          	jal	80000c5a <acquire>
  xticks = ticks;
    80002cce:	00009797          	auipc	a5,0x9
    80002cd2:	9a27a783          	lw	a5,-1630(a5) # 8000b670 <ticks>
    80002cd6:	84be                	mv	s1,a5
  release(&tickslock);
    80002cd8:	00017517          	auipc	a0,0x17
    80002cdc:	92850513          	addi	a0,a0,-1752 # 80019600 <tickslock>
    80002ce0:	80efe0ef          	jal	80000cee <release>
  return xticks;
}
    80002ce4:	02049513          	slli	a0,s1,0x20
    80002ce8:	9101                	srli	a0,a0,0x20
    80002cea:	60e2                	ld	ra,24(sp)
    80002cec:	6442                	ld	s0,16(sp)
    80002cee:	64a2                	ld	s1,8(sp)
    80002cf0:	6105                	addi	sp,sp,32
    80002cf2:	8082                	ret

0000000080002cf4 <sys_schedread>:

uint64
sys_schedread(void)
{
    80002cf4:	7131                	addi	sp,sp,-192
    80002cf6:	fd06                	sd	ra,184(sp)
    80002cf8:	f922                	sd	s0,176(sp)
    80002cfa:	f526                	sd	s1,168(sp)
    80002cfc:	f14a                	sd	s2,160(sp)
    80002cfe:	0180                	addi	s0,sp,192
    80002d00:	81010113          	addi	sp,sp,-2032
  uint64 dst;
  int max;

  argaddr(0, &dst);
    80002d04:	fd840593          	addi	a1,s0,-40
    80002d08:	4501                	li	a0,0
    80002d0a:	d5bff0ef          	jal	80002a64 <argaddr>
  argint(1, &max);
    80002d0e:	fd440593          	addi	a1,s0,-44
    80002d12:	4505                	li	a0,1
    80002d14:	d35ff0ef          	jal	80002a48 <argint>

  if(max <= 0)
    80002d18:	fd442783          	lw	a5,-44(s0)
    return 0;
    80002d1c:	4901                	li	s2,0
  if(max <= 0)
    80002d1e:	04f05963          	blez	a5,80002d70 <sys_schedread+0x7c>

  struct sched_event buf[32];
  if(max > 32)
    80002d22:	02000713          	li	a4,32
    80002d26:	00f75463          	bge	a4,a5,80002d2e <sys_schedread+0x3a>
    max = 32;
    80002d2a:	fce42a23          	sw	a4,-44(s0)

  int n = schedread(buf, max);
    80002d2e:	fd442583          	lw	a1,-44(s0)
    80002d32:	80040513          	addi	a0,s0,-2048
    80002d36:	1501                	addi	a0,a0,-32
    80002d38:	f7050513          	addi	a0,a0,-144
    80002d3c:	4b4030ef          	jal	800061f0 <schedread>
    80002d40:	84aa                	mv	s1,a0
  if(n < 0)
    return -1;
    80002d42:	57fd                	li	a5,-1
    80002d44:	893e                	mv	s2,a5
  if(n < 0)
    80002d46:	02054563          	bltz	a0,80002d70 <sys_schedread+0x7c>

  if(copyout(myproc()->pagetable, dst, (char *)buf, n * sizeof(struct sched_event)) < 0)
    80002d4a:	c33fe0ef          	jal	8000197c <myproc>
    80002d4e:	8926                	mv	s2,s1
    80002d50:	00449693          	slli	a3,s1,0x4
    80002d54:	96a6                	add	a3,a3,s1
    80002d56:	068a                	slli	a3,a3,0x2
    80002d58:	80040613          	addi	a2,s0,-2048
    80002d5c:	1601                	addi	a2,a2,-32
    80002d5e:	f7060613          	addi	a2,a2,-144
    80002d62:	fd843583          	ld	a1,-40(s0)
    80002d66:	6928                	ld	a0,80(a0)
    80002d68:	927fe0ef          	jal	8000168e <copyout>
    80002d6c:	00054b63          	bltz	a0,80002d82 <sys_schedread+0x8e>
    return -1;

  return n;
}
    80002d70:	854a                	mv	a0,s2
    80002d72:	7f010113          	addi	sp,sp,2032
    80002d76:	70ea                	ld	ra,184(sp)
    80002d78:	744a                	ld	s0,176(sp)
    80002d7a:	74aa                	ld	s1,168(sp)
    80002d7c:	790a                	ld	s2,160(sp)
    80002d7e:	6129                	addi	sp,sp,192
    80002d80:	8082                	ret
    return -1;
    80002d82:	57fd                	li	a5,-1
    80002d84:	893e                	mv	s2,a5
    80002d86:	b7ed                	j	80002d70 <sys_schedread+0x7c>

0000000080002d88 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80002d88:	7179                	addi	sp,sp,-48
    80002d8a:	f406                	sd	ra,40(sp)
    80002d8c:	f022                	sd	s0,32(sp)
    80002d8e:	ec26                	sd	s1,24(sp)
    80002d90:	e84a                	sd	s2,16(sp)
    80002d92:	e44e                	sd	s3,8(sp)
    80002d94:	e052                	sd	s4,0(sp)
    80002d96:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80002d98:	00005597          	auipc	a1,0x5
    80002d9c:	62858593          	addi	a1,a1,1576 # 800083c0 <etext+0x3c0>
    80002da0:	00017517          	auipc	a0,0x17
    80002da4:	87850513          	addi	a0,a0,-1928 # 80019618 <bcache>
    80002da8:	e29fd0ef          	jal	80000bd0 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80002dac:	0001f797          	auipc	a5,0x1f
    80002db0:	86c78793          	addi	a5,a5,-1940 # 80021618 <bcache+0x8000>
    80002db4:	0001f717          	auipc	a4,0x1f
    80002db8:	acc70713          	addi	a4,a4,-1332 # 80021880 <bcache+0x8268>
    80002dbc:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80002dc0:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002dc4:	00017497          	auipc	s1,0x17
    80002dc8:	86c48493          	addi	s1,s1,-1940 # 80019630 <bcache+0x18>
    b->next = bcache.head.next;
    80002dcc:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80002dce:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80002dd0:	00005a17          	auipc	s4,0x5
    80002dd4:	5f8a0a13          	addi	s4,s4,1528 # 800083c8 <etext+0x3c8>
    b->next = bcache.head.next;
    80002dd8:	2b893783          	ld	a5,696(s2)
    80002ddc:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80002dde:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80002de2:	85d2                	mv	a1,s4
    80002de4:	01048513          	addi	a0,s1,16
    80002de8:	366010ef          	jal	8000414e <initsleeplock>
    bcache.head.next->prev = b;
    80002dec:	2b893783          	ld	a5,696(s2)
    80002df0:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80002df2:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002df6:	45848493          	addi	s1,s1,1112
    80002dfa:	fd349fe3          	bne	s1,s3,80002dd8 <binit+0x50>
  }
}
    80002dfe:	70a2                	ld	ra,40(sp)
    80002e00:	7402                	ld	s0,32(sp)
    80002e02:	64e2                	ld	s1,24(sp)
    80002e04:	6942                	ld	s2,16(sp)
    80002e06:	69a2                	ld	s3,8(sp)
    80002e08:	6a02                	ld	s4,0(sp)
    80002e0a:	6145                	addi	sp,sp,48
    80002e0c:	8082                	ret

0000000080002e0e <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    80002e0e:	7179                	addi	sp,sp,-48
    80002e10:	f406                	sd	ra,40(sp)
    80002e12:	f022                	sd	s0,32(sp)
    80002e14:	ec26                	sd	s1,24(sp)
    80002e16:	e84a                	sd	s2,16(sp)
    80002e18:	e44e                	sd	s3,8(sp)
    80002e1a:	1800                	addi	s0,sp,48
    80002e1c:	892a                	mv	s2,a0
    80002e1e:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    80002e20:	00016517          	auipc	a0,0x16
    80002e24:	7f850513          	addi	a0,a0,2040 # 80019618 <bcache>
    80002e28:	e33fd0ef          	jal	80000c5a <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    80002e2c:	0001f497          	auipc	s1,0x1f
    80002e30:	aa44b483          	ld	s1,-1372(s1) # 800218d0 <bcache+0x82b8>
    80002e34:	0001f797          	auipc	a5,0x1f
    80002e38:	a4c78793          	addi	a5,a5,-1460 # 80021880 <bcache+0x8268>
    80002e3c:	04f48563          	beq	s1,a5,80002e86 <bread+0x78>
    80002e40:	873e                	mv	a4,a5
    80002e42:	a021                	j	80002e4a <bread+0x3c>
    80002e44:	68a4                	ld	s1,80(s1)
    80002e46:	04e48063          	beq	s1,a4,80002e86 <bread+0x78>
    if(b->dev == dev && b->blockno == blockno){
    80002e4a:	449c                	lw	a5,8(s1)
    80002e4c:	ff279ce3          	bne	a5,s2,80002e44 <bread+0x36>
    80002e50:	44dc                	lw	a5,12(s1)
    80002e52:	ff3799e3          	bne	a5,s3,80002e44 <bread+0x36>
      b->refcnt++;
    80002e56:	40bc                	lw	a5,64(s1)
    80002e58:	2785                	addiw	a5,a5,1
    80002e5a:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002e5c:	00016517          	auipc	a0,0x16
    80002e60:	7bc50513          	addi	a0,a0,1980 # 80019618 <bcache>
    80002e64:	e8bfd0ef          	jal	80000cee <release>
      acquiresleep(&b->lock);
    80002e68:	01048513          	addi	a0,s1,16
    80002e6c:	318010ef          	jal	80004184 <acquiresleep>
      fslog_push(FS_BGET_HIT, 0, blockno, 0, "BCACHE");
    80002e70:	00005717          	auipc	a4,0x5
    80002e74:	56070713          	addi	a4,a4,1376 # 800083d0 <etext+0x3d0>
    80002e78:	4681                	li	a3,0
    80002e7a:	864e                	mv	a2,s3
    80002e7c:	4581                	li	a1,0
    80002e7e:	4519                	li	a0,6
    80002e80:	1e0030ef          	jal	80006060 <fslog_push>
      return b;
    80002e84:	a09d                	j	80002eea <bread+0xdc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002e86:	0001f497          	auipc	s1,0x1f
    80002e8a:	a424b483          	ld	s1,-1470(s1) # 800218c8 <bcache+0x82b0>
    80002e8e:	0001f797          	auipc	a5,0x1f
    80002e92:	9f278793          	addi	a5,a5,-1550 # 80021880 <bcache+0x8268>
    80002e96:	00f48863          	beq	s1,a5,80002ea6 <bread+0x98>
    80002e9a:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    80002e9c:	40bc                	lw	a5,64(s1)
    80002e9e:	cb91                	beqz	a5,80002eb2 <bread+0xa4>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002ea0:	64a4                	ld	s1,72(s1)
    80002ea2:	fee49de3          	bne	s1,a4,80002e9c <bread+0x8e>
  panic("bget: no buffers");
    80002ea6:	00005517          	auipc	a0,0x5
    80002eaa:	53250513          	addi	a0,a0,1330 # 800083d8 <etext+0x3d8>
    80002eae:	9a9fd0ef          	jal	80000856 <panic>
      b->dev = dev;
    80002eb2:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    80002eb6:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    80002eba:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80002ebe:	4785                	li	a5,1
    80002ec0:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002ec2:	00016517          	auipc	a0,0x16
    80002ec6:	75650513          	addi	a0,a0,1878 # 80019618 <bcache>
    80002eca:	e25fd0ef          	jal	80000cee <release>
      acquiresleep(&b->lock);
    80002ece:	01048513          	addi	a0,s1,16
    80002ed2:	2b2010ef          	jal	80004184 <acquiresleep>
      fslog_push(FS_BGET_MISS, 0, blockno, 0, "BCACHE");
    80002ed6:	00005717          	auipc	a4,0x5
    80002eda:	4fa70713          	addi	a4,a4,1274 # 800083d0 <etext+0x3d0>
    80002ede:	4681                	li	a3,0
    80002ee0:	864e                	mv	a2,s3
    80002ee2:	4581                	li	a1,0
    80002ee4:	451d                	li	a0,7
    80002ee6:	17a030ef          	jal	80006060 <fslog_push>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    80002eea:	409c                	lw	a5,0(s1)
    80002eec:	cb89                	beqz	a5,80002efe <bread+0xf0>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80002eee:	8526                	mv	a0,s1
    80002ef0:	70a2                	ld	ra,40(sp)
    80002ef2:	7402                	ld	s0,32(sp)
    80002ef4:	64e2                	ld	s1,24(sp)
    80002ef6:	6942                	ld	s2,16(sp)
    80002ef8:	69a2                	ld	s3,8(sp)
    80002efa:	6145                	addi	sp,sp,48
    80002efc:	8082                	ret
    virtio_disk_rw(b, 0);
    80002efe:	4581                	li	a1,0
    80002f00:	8526                	mv	a0,s1
    80002f02:	33f020ef          	jal	80005a40 <virtio_disk_rw>
    b->valid = 1;
    80002f06:	4785                	li	a5,1
    80002f08:	c09c                	sw	a5,0(s1)
  return b;
    80002f0a:	b7d5                	j	80002eee <bread+0xe0>

0000000080002f0c <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    80002f0c:	1101                	addi	sp,sp,-32
    80002f0e:	ec06                	sd	ra,24(sp)
    80002f10:	e822                	sd	s0,16(sp)
    80002f12:	e426                	sd	s1,8(sp)
    80002f14:	1000                	addi	s0,sp,32
    80002f16:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80002f18:	0541                	addi	a0,a0,16
    80002f1a:	2e8010ef          	jal	80004202 <holdingsleep>
    80002f1e:	c911                	beqz	a0,80002f32 <bwrite+0x26>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    80002f20:	4585                	li	a1,1
    80002f22:	8526                	mv	a0,s1
    80002f24:	31d020ef          	jal	80005a40 <virtio_disk_rw>
}
    80002f28:	60e2                	ld	ra,24(sp)
    80002f2a:	6442                	ld	s0,16(sp)
    80002f2c:	64a2                	ld	s1,8(sp)
    80002f2e:	6105                	addi	sp,sp,32
    80002f30:	8082                	ret
    panic("bwrite");
    80002f32:	00005517          	auipc	a0,0x5
    80002f36:	4be50513          	addi	a0,a0,1214 # 800083f0 <etext+0x3f0>
    80002f3a:	91dfd0ef          	jal	80000856 <panic>

0000000080002f3e <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    80002f3e:	1101                	addi	sp,sp,-32
    80002f40:	ec06                	sd	ra,24(sp)
    80002f42:	e822                	sd	s0,16(sp)
    80002f44:	e426                	sd	s1,8(sp)
    80002f46:	e04a                	sd	s2,0(sp)
    80002f48:	1000                	addi	s0,sp,32
    80002f4a:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80002f4c:	01050913          	addi	s2,a0,16
    80002f50:	854a                	mv	a0,s2
    80002f52:	2b0010ef          	jal	80004202 <holdingsleep>
    80002f56:	c915                	beqz	a0,80002f8a <brelse+0x4c>
    panic("brelse");

  releasesleep(&b->lock);
    80002f58:	854a                	mv	a0,s2
    80002f5a:	270010ef          	jal	800041ca <releasesleep>

  acquire(&bcache.lock);
    80002f5e:	00016517          	auipc	a0,0x16
    80002f62:	6ba50513          	addi	a0,a0,1722 # 80019618 <bcache>
    80002f66:	cf5fd0ef          	jal	80000c5a <acquire>
  b->refcnt--;
    80002f6a:	40bc                	lw	a5,64(s1)
    80002f6c:	37fd                	addiw	a5,a5,-1
    80002f6e:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    80002f70:	c39d                	beqz	a5,80002f96 <brelse+0x58>
    bcache.head.next->prev = b;
    bcache.head.next = b;
    fslog_push(FS_BRELEASE, 0, b->blockno, 0, "BCACHE");
  }
  
  release(&bcache.lock);
    80002f72:	00016517          	auipc	a0,0x16
    80002f76:	6a650513          	addi	a0,a0,1702 # 80019618 <bcache>
    80002f7a:	d75fd0ef          	jal	80000cee <release>
}
    80002f7e:	60e2                	ld	ra,24(sp)
    80002f80:	6442                	ld	s0,16(sp)
    80002f82:	64a2                	ld	s1,8(sp)
    80002f84:	6902                	ld	s2,0(sp)
    80002f86:	6105                	addi	sp,sp,32
    80002f88:	8082                	ret
    panic("brelse");
    80002f8a:	00005517          	auipc	a0,0x5
    80002f8e:	46e50513          	addi	a0,a0,1134 # 800083f8 <etext+0x3f8>
    80002f92:	8c5fd0ef          	jal	80000856 <panic>
    b->next->prev = b->prev;
    80002f96:	68b8                	ld	a4,80(s1)
    80002f98:	64bc                	ld	a5,72(s1)
    80002f9a:	e73c                	sd	a5,72(a4)
    b->prev->next = b->next;
    80002f9c:	68b8                	ld	a4,80(s1)
    80002f9e:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    80002fa0:	0001e797          	auipc	a5,0x1e
    80002fa4:	67878793          	addi	a5,a5,1656 # 80021618 <bcache+0x8000>
    80002fa8:	2b87b703          	ld	a4,696(a5)
    80002fac:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    80002fae:	0001f717          	auipc	a4,0x1f
    80002fb2:	8d270713          	addi	a4,a4,-1838 # 80021880 <bcache+0x8268>
    80002fb6:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    80002fb8:	2b87b703          	ld	a4,696(a5)
    80002fbc:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80002fbe:	2a97bc23          	sd	s1,696(a5)
    fslog_push(FS_BRELEASE, 0, b->blockno, 0, "BCACHE");
    80002fc2:	00005717          	auipc	a4,0x5
    80002fc6:	40e70713          	addi	a4,a4,1038 # 800083d0 <etext+0x3d0>
    80002fca:	4681                	li	a3,0
    80002fcc:	44d0                	lw	a2,12(s1)
    80002fce:	4581                	li	a1,0
    80002fd0:	4521                	li	a0,8
    80002fd2:	08e030ef          	jal	80006060 <fslog_push>
    80002fd6:	bf71                	j	80002f72 <brelse+0x34>

0000000080002fd8 <bpin>:

void
bpin(struct buf *b) {
    80002fd8:	1101                	addi	sp,sp,-32
    80002fda:	ec06                	sd	ra,24(sp)
    80002fdc:	e822                	sd	s0,16(sp)
    80002fde:	e426                	sd	s1,8(sp)
    80002fe0:	1000                	addi	s0,sp,32
    80002fe2:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80002fe4:	00016517          	auipc	a0,0x16
    80002fe8:	63450513          	addi	a0,a0,1588 # 80019618 <bcache>
    80002fec:	c6ffd0ef          	jal	80000c5a <acquire>
  b->refcnt++;
    80002ff0:	40bc                	lw	a5,64(s1)
    80002ff2:	2785                	addiw	a5,a5,1
    80002ff4:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80002ff6:	00016517          	auipc	a0,0x16
    80002ffa:	62250513          	addi	a0,a0,1570 # 80019618 <bcache>
    80002ffe:	cf1fd0ef          	jal	80000cee <release>
}
    80003002:	60e2                	ld	ra,24(sp)
    80003004:	6442                	ld	s0,16(sp)
    80003006:	64a2                	ld	s1,8(sp)
    80003008:	6105                	addi	sp,sp,32
    8000300a:	8082                	ret

000000008000300c <bunpin>:

void
bunpin(struct buf *b) {
    8000300c:	1101                	addi	sp,sp,-32
    8000300e:	ec06                	sd	ra,24(sp)
    80003010:	e822                	sd	s0,16(sp)
    80003012:	e426                	sd	s1,8(sp)
    80003014:	1000                	addi	s0,sp,32
    80003016:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80003018:	00016517          	auipc	a0,0x16
    8000301c:	60050513          	addi	a0,a0,1536 # 80019618 <bcache>
    80003020:	c3bfd0ef          	jal	80000c5a <acquire>
  b->refcnt--;
    80003024:	40bc                	lw	a5,64(s1)
    80003026:	37fd                	addiw	a5,a5,-1
    80003028:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    8000302a:	00016517          	auipc	a0,0x16
    8000302e:	5ee50513          	addi	a0,a0,1518 # 80019618 <bcache>
    80003032:	cbdfd0ef          	jal	80000cee <release>
}
    80003036:	60e2                	ld	ra,24(sp)
    80003038:	6442                	ld	s0,16(sp)
    8000303a:	64a2                	ld	s1,8(sp)
    8000303c:	6105                	addi	sp,sp,32
    8000303e:	8082                	ret

0000000080003040 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    80003040:	1101                	addi	sp,sp,-32
    80003042:	ec06                	sd	ra,24(sp)
    80003044:	e822                	sd	s0,16(sp)
    80003046:	e426                	sd	s1,8(sp)
    80003048:	e04a                	sd	s2,0(sp)
    8000304a:	1000                	addi	s0,sp,32
    8000304c:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    8000304e:	00d5d79b          	srliw	a5,a1,0xd
    80003052:	0001f597          	auipc	a1,0x1f
    80003056:	ca25a583          	lw	a1,-862(a1) # 80021cf4 <sb+0x1c>
    8000305a:	9dbd                	addw	a1,a1,a5
    8000305c:	db3ff0ef          	jal	80002e0e <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    80003060:	0074f713          	andi	a4,s1,7
    80003064:	4785                	li	a5,1
    80003066:	00e797bb          	sllw	a5,a5,a4
  bi = b % BPB;
    8000306a:	14ce                	slli	s1,s1,0x33
  if((bp->data[bi/8] & m) == 0)
    8000306c:	90d9                	srli	s1,s1,0x36
    8000306e:	00950733          	add	a4,a0,s1
    80003072:	05874703          	lbu	a4,88(a4)
    80003076:	00e7f6b3          	and	a3,a5,a4
    8000307a:	c29d                	beqz	a3,800030a0 <bfree+0x60>
    8000307c:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    8000307e:	94aa                	add	s1,s1,a0
    80003080:	fff7c793          	not	a5,a5
    80003084:	8f7d                	and	a4,a4,a5
    80003086:	04e48c23          	sb	a4,88(s1)
  log_write(bp);
    8000308a:	000010ef          	jal	8000408a <log_write>
  brelse(bp);
    8000308e:	854a                	mv	a0,s2
    80003090:	eafff0ef          	jal	80002f3e <brelse>
}
    80003094:	60e2                	ld	ra,24(sp)
    80003096:	6442                	ld	s0,16(sp)
    80003098:	64a2                	ld	s1,8(sp)
    8000309a:	6902                	ld	s2,0(sp)
    8000309c:	6105                	addi	sp,sp,32
    8000309e:	8082                	ret
    panic("freeing free block");
    800030a0:	00005517          	auipc	a0,0x5
    800030a4:	36050513          	addi	a0,a0,864 # 80008400 <etext+0x400>
    800030a8:	faefd0ef          	jal	80000856 <panic>

00000000800030ac <balloc>:
{
    800030ac:	715d                	addi	sp,sp,-80
    800030ae:	e486                	sd	ra,72(sp)
    800030b0:	e0a2                	sd	s0,64(sp)
    800030b2:	fc26                	sd	s1,56(sp)
    800030b4:	0880                	addi	s0,sp,80
  for(b = 0; b < sb.size; b += BPB){
    800030b6:	0001f797          	auipc	a5,0x1f
    800030ba:	c267a783          	lw	a5,-986(a5) # 80021cdc <sb+0x4>
    800030be:	0e078263          	beqz	a5,800031a2 <balloc+0xf6>
    800030c2:	f84a                	sd	s2,48(sp)
    800030c4:	f44e                	sd	s3,40(sp)
    800030c6:	f052                	sd	s4,32(sp)
    800030c8:	ec56                	sd	s5,24(sp)
    800030ca:	e85a                	sd	s6,16(sp)
    800030cc:	e45e                	sd	s7,8(sp)
    800030ce:	e062                	sd	s8,0(sp)
    800030d0:	8baa                	mv	s7,a0
    800030d2:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    800030d4:	0001fb17          	auipc	s6,0x1f
    800030d8:	c04b0b13          	addi	s6,s6,-1020 # 80021cd8 <sb>
      m = 1 << (bi % 8);
    800030dc:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800030de:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    800030e0:	6c09                	lui	s8,0x2
    800030e2:	a09d                	j	80003148 <balloc+0x9c>
        bp->data[bi/8] |= m;  // Mark block in use.
    800030e4:	97ca                	add	a5,a5,s2
    800030e6:	8e55                	or	a2,a2,a3
    800030e8:	04c78c23          	sb	a2,88(a5)
        log_write(bp);
    800030ec:	854a                	mv	a0,s2
    800030ee:	79d000ef          	jal	8000408a <log_write>
        brelse(bp);
    800030f2:	854a                	mv	a0,s2
    800030f4:	e4bff0ef          	jal	80002f3e <brelse>
  bp = bread(dev, bno);
    800030f8:	85a6                	mv	a1,s1
    800030fa:	855e                	mv	a0,s7
    800030fc:	d13ff0ef          	jal	80002e0e <bread>
    80003100:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    80003102:	40000613          	li	a2,1024
    80003106:	4581                	li	a1,0
    80003108:	05850513          	addi	a0,a0,88
    8000310c:	c1ffd0ef          	jal	80000d2a <memset>
  log_write(bp);
    80003110:	854a                	mv	a0,s2
    80003112:	779000ef          	jal	8000408a <log_write>
  brelse(bp);
    80003116:	854a                	mv	a0,s2
    80003118:	e27ff0ef          	jal	80002f3e <brelse>
}
    8000311c:	7942                	ld	s2,48(sp)
    8000311e:	79a2                	ld	s3,40(sp)
    80003120:	7a02                	ld	s4,32(sp)
    80003122:	6ae2                	ld	s5,24(sp)
    80003124:	6b42                	ld	s6,16(sp)
    80003126:	6ba2                	ld	s7,8(sp)
    80003128:	6c02                	ld	s8,0(sp)
}
    8000312a:	8526                	mv	a0,s1
    8000312c:	60a6                	ld	ra,72(sp)
    8000312e:	6406                	ld	s0,64(sp)
    80003130:	74e2                	ld	s1,56(sp)
    80003132:	6161                	addi	sp,sp,80
    80003134:	8082                	ret
    brelse(bp);
    80003136:	854a                	mv	a0,s2
    80003138:	e07ff0ef          	jal	80002f3e <brelse>
  for(b = 0; b < sb.size; b += BPB){
    8000313c:	015c0abb          	addw	s5,s8,s5
    80003140:	004b2783          	lw	a5,4(s6)
    80003144:	04faf863          	bgeu	s5,a5,80003194 <balloc+0xe8>
    bp = bread(dev, BBLOCK(b, sb));
    80003148:	40dad59b          	sraiw	a1,s5,0xd
    8000314c:	01cb2783          	lw	a5,28(s6)
    80003150:	9dbd                	addw	a1,a1,a5
    80003152:	855e                	mv	a0,s7
    80003154:	cbbff0ef          	jal	80002e0e <bread>
    80003158:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000315a:	004b2503          	lw	a0,4(s6)
    8000315e:	84d6                	mv	s1,s5
    80003160:	4701                	li	a4,0
    80003162:	fca4fae3          	bgeu	s1,a0,80003136 <balloc+0x8a>
      m = 1 << (bi % 8);
    80003166:	00777693          	andi	a3,a4,7
    8000316a:	00d996bb          	sllw	a3,s3,a3
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    8000316e:	41f7579b          	sraiw	a5,a4,0x1f
    80003172:	01d7d79b          	srliw	a5,a5,0x1d
    80003176:	9fb9                	addw	a5,a5,a4
    80003178:	4037d79b          	sraiw	a5,a5,0x3
    8000317c:	00f90633          	add	a2,s2,a5
    80003180:	05864603          	lbu	a2,88(a2)
    80003184:	00c6f5b3          	and	a1,a3,a2
    80003188:	ddb1                	beqz	a1,800030e4 <balloc+0x38>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000318a:	2705                	addiw	a4,a4,1
    8000318c:	2485                	addiw	s1,s1,1
    8000318e:	fd471ae3          	bne	a4,s4,80003162 <balloc+0xb6>
    80003192:	b755                	j	80003136 <balloc+0x8a>
    80003194:	7942                	ld	s2,48(sp)
    80003196:	79a2                	ld	s3,40(sp)
    80003198:	7a02                	ld	s4,32(sp)
    8000319a:	6ae2                	ld	s5,24(sp)
    8000319c:	6b42                	ld	s6,16(sp)
    8000319e:	6ba2                	ld	s7,8(sp)
    800031a0:	6c02                	ld	s8,0(sp)
  printf("balloc: out of blocks\n");
    800031a2:	00005517          	auipc	a0,0x5
    800031a6:	27650513          	addi	a0,a0,630 # 80008418 <etext+0x418>
    800031aa:	b82fd0ef          	jal	8000052c <printf>
  return 0;
    800031ae:	4481                	li	s1,0
    800031b0:	bfad                	j	8000312a <balloc+0x7e>

00000000800031b2 <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    800031b2:	7179                	addi	sp,sp,-48
    800031b4:	f406                	sd	ra,40(sp)
    800031b6:	f022                	sd	s0,32(sp)
    800031b8:	ec26                	sd	s1,24(sp)
    800031ba:	e84a                	sd	s2,16(sp)
    800031bc:	e44e                	sd	s3,8(sp)
    800031be:	1800                	addi	s0,sp,48
    800031c0:	892a                	mv	s2,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    800031c2:	47ad                	li	a5,11
    800031c4:	02b7e363          	bltu	a5,a1,800031ea <bmap+0x38>
    if((addr = ip->addrs[bn]) == 0){
    800031c8:	02059793          	slli	a5,a1,0x20
    800031cc:	01e7d593          	srli	a1,a5,0x1e
    800031d0:	00b509b3          	add	s3,a0,a1
    800031d4:	0509a483          	lw	s1,80(s3)
    800031d8:	e0b5                	bnez	s1,8000323c <bmap+0x8a>
      addr = balloc(ip->dev);
    800031da:	4108                	lw	a0,0(a0)
    800031dc:	ed1ff0ef          	jal	800030ac <balloc>
    800031e0:	84aa                	mv	s1,a0
      if(addr == 0)
    800031e2:	cd29                	beqz	a0,8000323c <bmap+0x8a>
        return 0;
      ip->addrs[bn] = addr;
    800031e4:	04a9a823          	sw	a0,80(s3)
    800031e8:	a891                	j	8000323c <bmap+0x8a>
    }
    return addr;
  }
  bn -= NDIRECT;
    800031ea:	ff45879b          	addiw	a5,a1,-12
    800031ee:	873e                	mv	a4,a5
    800031f0:	89be                	mv	s3,a5

  if(bn < NINDIRECT){
    800031f2:	0ff00793          	li	a5,255
    800031f6:	06e7e763          	bltu	a5,a4,80003264 <bmap+0xb2>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    800031fa:	08052483          	lw	s1,128(a0)
    800031fe:	e891                	bnez	s1,80003212 <bmap+0x60>
      addr = balloc(ip->dev);
    80003200:	4108                	lw	a0,0(a0)
    80003202:	eabff0ef          	jal	800030ac <balloc>
    80003206:	84aa                	mv	s1,a0
      if(addr == 0)
    80003208:	c915                	beqz	a0,8000323c <bmap+0x8a>
    8000320a:	e052                	sd	s4,0(sp)
        return 0;
      ip->addrs[NDIRECT] = addr;
    8000320c:	08a92023          	sw	a0,128(s2)
    80003210:	a011                	j	80003214 <bmap+0x62>
    80003212:	e052                	sd	s4,0(sp)
    }
    bp = bread(ip->dev, addr);
    80003214:	85a6                	mv	a1,s1
    80003216:	00092503          	lw	a0,0(s2)
    8000321a:	bf5ff0ef          	jal	80002e0e <bread>
    8000321e:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    80003220:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    80003224:	02099713          	slli	a4,s3,0x20
    80003228:	01e75593          	srli	a1,a4,0x1e
    8000322c:	97ae                	add	a5,a5,a1
    8000322e:	89be                	mv	s3,a5
    80003230:	4384                	lw	s1,0(a5)
    80003232:	cc89                	beqz	s1,8000324c <bmap+0x9a>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    80003234:	8552                	mv	a0,s4
    80003236:	d09ff0ef          	jal	80002f3e <brelse>
    return addr;
    8000323a:	6a02                	ld	s4,0(sp)
  }

  panic("bmap: out of range");
}
    8000323c:	8526                	mv	a0,s1
    8000323e:	70a2                	ld	ra,40(sp)
    80003240:	7402                	ld	s0,32(sp)
    80003242:	64e2                	ld	s1,24(sp)
    80003244:	6942                	ld	s2,16(sp)
    80003246:	69a2                	ld	s3,8(sp)
    80003248:	6145                	addi	sp,sp,48
    8000324a:	8082                	ret
      addr = balloc(ip->dev);
    8000324c:	00092503          	lw	a0,0(s2)
    80003250:	e5dff0ef          	jal	800030ac <balloc>
    80003254:	84aa                	mv	s1,a0
      if(addr){
    80003256:	dd79                	beqz	a0,80003234 <bmap+0x82>
        a[bn] = addr;
    80003258:	00a9a023          	sw	a0,0(s3)
        log_write(bp);
    8000325c:	8552                	mv	a0,s4
    8000325e:	62d000ef          	jal	8000408a <log_write>
    80003262:	bfc9                	j	80003234 <bmap+0x82>
    80003264:	e052                	sd	s4,0(sp)
  panic("bmap: out of range");
    80003266:	00005517          	auipc	a0,0x5
    8000326a:	1ca50513          	addi	a0,a0,458 # 80008430 <etext+0x430>
    8000326e:	de8fd0ef          	jal	80000856 <panic>

0000000080003272 <iget>:
{
    80003272:	7179                	addi	sp,sp,-48
    80003274:	f406                	sd	ra,40(sp)
    80003276:	f022                	sd	s0,32(sp)
    80003278:	ec26                	sd	s1,24(sp)
    8000327a:	e84a                	sd	s2,16(sp)
    8000327c:	e44e                	sd	s3,8(sp)
    8000327e:	e052                	sd	s4,0(sp)
    80003280:	1800                	addi	s0,sp,48
    80003282:	892a                	mv	s2,a0
    80003284:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    80003286:	0001f517          	auipc	a0,0x1f
    8000328a:	a7250513          	addi	a0,a0,-1422 # 80021cf8 <itable>
    8000328e:	9cdfd0ef          	jal	80000c5a <acquire>
  empty = 0;
    80003292:	4981                	li	s3,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003294:	0001f497          	auipc	s1,0x1f
    80003298:	a7c48493          	addi	s1,s1,-1412 # 80021d10 <itable+0x18>
    8000329c:	00020697          	auipc	a3,0x20
    800032a0:	50468693          	addi	a3,a3,1284 # 800237a0 <log>
    800032a4:	a809                	j	800032b6 <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    800032a6:	e781                	bnez	a5,800032ae <iget+0x3c>
    800032a8:	00099363          	bnez	s3,800032ae <iget+0x3c>
      empty = ip;
    800032ac:	89a6                	mv	s3,s1
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    800032ae:	08848493          	addi	s1,s1,136
    800032b2:	02d48563          	beq	s1,a3,800032dc <iget+0x6a>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    800032b6:	449c                	lw	a5,8(s1)
    800032b8:	fef057e3          	blez	a5,800032a6 <iget+0x34>
    800032bc:	4098                	lw	a4,0(s1)
    800032be:	ff2718e3          	bne	a4,s2,800032ae <iget+0x3c>
    800032c2:	40d8                	lw	a4,4(s1)
    800032c4:	ff4715e3          	bne	a4,s4,800032ae <iget+0x3c>
      ip->ref++;
    800032c8:	2785                	addiw	a5,a5,1
    800032ca:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    800032cc:	0001f517          	auipc	a0,0x1f
    800032d0:	a2c50513          	addi	a0,a0,-1492 # 80021cf8 <itable>
    800032d4:	a1bfd0ef          	jal	80000cee <release>
      return ip;
    800032d8:	89a6                	mv	s3,s1
    800032da:	a015                	j	800032fe <iget+0x8c>
  if(empty == 0)
    800032dc:	02098a63          	beqz	s3,80003310 <iget+0x9e>
  ip->dev = dev;
    800032e0:	0129a023          	sw	s2,0(s3)
  ip->inum = inum;
    800032e4:	0149a223          	sw	s4,4(s3)
  ip->ref = 1;
    800032e8:	4785                	li	a5,1
    800032ea:	00f9a423          	sw	a5,8(s3)
  ip->valid = 0;
    800032ee:	0409a023          	sw	zero,64(s3)
  release(&itable.lock);
    800032f2:	0001f517          	auipc	a0,0x1f
    800032f6:	a0650513          	addi	a0,a0,-1530 # 80021cf8 <itable>
    800032fa:	9f5fd0ef          	jal	80000cee <release>
}
    800032fe:	854e                	mv	a0,s3
    80003300:	70a2                	ld	ra,40(sp)
    80003302:	7402                	ld	s0,32(sp)
    80003304:	64e2                	ld	s1,24(sp)
    80003306:	6942                	ld	s2,16(sp)
    80003308:	69a2                	ld	s3,8(sp)
    8000330a:	6a02                	ld	s4,0(sp)
    8000330c:	6145                	addi	sp,sp,48
    8000330e:	8082                	ret
    panic("iget: no inodes");
    80003310:	00005517          	auipc	a0,0x5
    80003314:	13850513          	addi	a0,a0,312 # 80008448 <etext+0x448>
    80003318:	d3efd0ef          	jal	80000856 <panic>

000000008000331c <iinit>:
{
    8000331c:	7179                	addi	sp,sp,-48
    8000331e:	f406                	sd	ra,40(sp)
    80003320:	f022                	sd	s0,32(sp)
    80003322:	ec26                	sd	s1,24(sp)
    80003324:	e84a                	sd	s2,16(sp)
    80003326:	e44e                	sd	s3,8(sp)
    80003328:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    8000332a:	00005597          	auipc	a1,0x5
    8000332e:	12e58593          	addi	a1,a1,302 # 80008458 <etext+0x458>
    80003332:	0001f517          	auipc	a0,0x1f
    80003336:	9c650513          	addi	a0,a0,-1594 # 80021cf8 <itable>
    8000333a:	897fd0ef          	jal	80000bd0 <initlock>
  for(i = 0; i < NINODE; i++) {
    8000333e:	0001f497          	auipc	s1,0x1f
    80003342:	9e248493          	addi	s1,s1,-1566 # 80021d20 <itable+0x28>
    80003346:	00020997          	auipc	s3,0x20
    8000334a:	46a98993          	addi	s3,s3,1130 # 800237b0 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    8000334e:	00005917          	auipc	s2,0x5
    80003352:	11290913          	addi	s2,s2,274 # 80008460 <etext+0x460>
    80003356:	85ca                	mv	a1,s2
    80003358:	8526                	mv	a0,s1
    8000335a:	5f5000ef          	jal	8000414e <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    8000335e:	08848493          	addi	s1,s1,136
    80003362:	ff349ae3          	bne	s1,s3,80003356 <iinit+0x3a>
}
    80003366:	70a2                	ld	ra,40(sp)
    80003368:	7402                	ld	s0,32(sp)
    8000336a:	64e2                	ld	s1,24(sp)
    8000336c:	6942                	ld	s2,16(sp)
    8000336e:	69a2                	ld	s3,8(sp)
    80003370:	6145                	addi	sp,sp,48
    80003372:	8082                	ret

0000000080003374 <ialloc>:
{
    80003374:	7139                	addi	sp,sp,-64
    80003376:	fc06                	sd	ra,56(sp)
    80003378:	f822                	sd	s0,48(sp)
    8000337a:	0080                	addi	s0,sp,64
  for(inum = 1; inum < sb.ninodes; inum++){
    8000337c:	0001f717          	auipc	a4,0x1f
    80003380:	96872703          	lw	a4,-1688(a4) # 80021ce4 <sb+0xc>
    80003384:	4785                	li	a5,1
    80003386:	06e7f063          	bgeu	a5,a4,800033e6 <ialloc+0x72>
    8000338a:	f426                	sd	s1,40(sp)
    8000338c:	f04a                	sd	s2,32(sp)
    8000338e:	ec4e                	sd	s3,24(sp)
    80003390:	e852                	sd	s4,16(sp)
    80003392:	e456                	sd	s5,8(sp)
    80003394:	e05a                	sd	s6,0(sp)
    80003396:	8aaa                	mv	s5,a0
    80003398:	8b2e                	mv	s6,a1
    8000339a:	893e                	mv	s2,a5
    bp = bread(dev, IBLOCK(inum, sb));
    8000339c:	0001fa17          	auipc	s4,0x1f
    800033a0:	93ca0a13          	addi	s4,s4,-1732 # 80021cd8 <sb>
    800033a4:	00495593          	srli	a1,s2,0x4
    800033a8:	018a2783          	lw	a5,24(s4)
    800033ac:	9dbd                	addw	a1,a1,a5
    800033ae:	8556                	mv	a0,s5
    800033b0:	a5fff0ef          	jal	80002e0e <bread>
    800033b4:	84aa                	mv	s1,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    800033b6:	05850993          	addi	s3,a0,88
    800033ba:	00f97793          	andi	a5,s2,15
    800033be:	079a                	slli	a5,a5,0x6
    800033c0:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    800033c2:	00099783          	lh	a5,0(s3)
    800033c6:	cb9d                	beqz	a5,800033fc <ialloc+0x88>
    brelse(bp);
    800033c8:	b77ff0ef          	jal	80002f3e <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    800033cc:	0905                	addi	s2,s2,1
    800033ce:	00ca2703          	lw	a4,12(s4)
    800033d2:	0009079b          	sext.w	a5,s2
    800033d6:	fce7e7e3          	bltu	a5,a4,800033a4 <ialloc+0x30>
    800033da:	74a2                	ld	s1,40(sp)
    800033dc:	7902                	ld	s2,32(sp)
    800033de:	69e2                	ld	s3,24(sp)
    800033e0:	6a42                	ld	s4,16(sp)
    800033e2:	6aa2                	ld	s5,8(sp)
    800033e4:	6b02                	ld	s6,0(sp)
  printf("ialloc: no inodes\n");
    800033e6:	00005517          	auipc	a0,0x5
    800033ea:	08250513          	addi	a0,a0,130 # 80008468 <etext+0x468>
    800033ee:	93efd0ef          	jal	8000052c <printf>
  return 0;
    800033f2:	4501                	li	a0,0
}
    800033f4:	70e2                	ld	ra,56(sp)
    800033f6:	7442                	ld	s0,48(sp)
    800033f8:	6121                	addi	sp,sp,64
    800033fa:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    800033fc:	04000613          	li	a2,64
    80003400:	4581                	li	a1,0
    80003402:	854e                	mv	a0,s3
    80003404:	927fd0ef          	jal	80000d2a <memset>
      dip->type = type;
    80003408:	01699023          	sh	s6,0(s3)
      log_write(bp);   // mark it allocated on the disk
    8000340c:	8526                	mv	a0,s1
    8000340e:	47d000ef          	jal	8000408a <log_write>
      brelse(bp);
    80003412:	8526                	mv	a0,s1
    80003414:	b2bff0ef          	jal	80002f3e <brelse>
      return iget(dev, inum);
    80003418:	0009059b          	sext.w	a1,s2
    8000341c:	8556                	mv	a0,s5
    8000341e:	e55ff0ef          	jal	80003272 <iget>
    80003422:	74a2                	ld	s1,40(sp)
    80003424:	7902                	ld	s2,32(sp)
    80003426:	69e2                	ld	s3,24(sp)
    80003428:	6a42                	ld	s4,16(sp)
    8000342a:	6aa2                	ld	s5,8(sp)
    8000342c:	6b02                	ld	s6,0(sp)
    8000342e:	b7d9                	j	800033f4 <ialloc+0x80>

0000000080003430 <iupdate>:
{
    80003430:	1101                	addi	sp,sp,-32
    80003432:	ec06                	sd	ra,24(sp)
    80003434:	e822                	sd	s0,16(sp)
    80003436:	e426                	sd	s1,8(sp)
    80003438:	e04a                	sd	s2,0(sp)
    8000343a:	1000                	addi	s0,sp,32
    8000343c:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    8000343e:	415c                	lw	a5,4(a0)
    80003440:	0047d79b          	srliw	a5,a5,0x4
    80003444:	0001f597          	auipc	a1,0x1f
    80003448:	8ac5a583          	lw	a1,-1876(a1) # 80021cf0 <sb+0x18>
    8000344c:	9dbd                	addw	a1,a1,a5
    8000344e:	4108                	lw	a0,0(a0)
    80003450:	9bfff0ef          	jal	80002e0e <bread>
    80003454:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003456:	05850793          	addi	a5,a0,88
    8000345a:	40d8                	lw	a4,4(s1)
    8000345c:	8b3d                	andi	a4,a4,15
    8000345e:	071a                	slli	a4,a4,0x6
    80003460:	97ba                	add	a5,a5,a4
  dip->type = ip->type;
    80003462:	04449703          	lh	a4,68(s1)
    80003466:	00e79023          	sh	a4,0(a5)
  dip->major = ip->major;
    8000346a:	04649703          	lh	a4,70(s1)
    8000346e:	00e79123          	sh	a4,2(a5)
  dip->minor = ip->minor;
    80003472:	04849703          	lh	a4,72(s1)
    80003476:	00e79223          	sh	a4,4(a5)
  dip->nlink = ip->nlink;
    8000347a:	04a49703          	lh	a4,74(s1)
    8000347e:	00e79323          	sh	a4,6(a5)
  dip->size = ip->size;
    80003482:	44f8                	lw	a4,76(s1)
    80003484:	c798                	sw	a4,8(a5)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80003486:	03400613          	li	a2,52
    8000348a:	05048593          	addi	a1,s1,80
    8000348e:	00c78513          	addi	a0,a5,12
    80003492:	8f9fd0ef          	jal	80000d8a <memmove>
  log_write(bp);
    80003496:	854a                	mv	a0,s2
    80003498:	3f3000ef          	jal	8000408a <log_write>
  brelse(bp);
    8000349c:	854a                	mv	a0,s2
    8000349e:	aa1ff0ef          	jal	80002f3e <brelse>
}
    800034a2:	60e2                	ld	ra,24(sp)
    800034a4:	6442                	ld	s0,16(sp)
    800034a6:	64a2                	ld	s1,8(sp)
    800034a8:	6902                	ld	s2,0(sp)
    800034aa:	6105                	addi	sp,sp,32
    800034ac:	8082                	ret

00000000800034ae <idup>:
{
    800034ae:	1101                	addi	sp,sp,-32
    800034b0:	ec06                	sd	ra,24(sp)
    800034b2:	e822                	sd	s0,16(sp)
    800034b4:	e426                	sd	s1,8(sp)
    800034b6:	1000                	addi	s0,sp,32
    800034b8:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    800034ba:	0001f517          	auipc	a0,0x1f
    800034be:	83e50513          	addi	a0,a0,-1986 # 80021cf8 <itable>
    800034c2:	f98fd0ef          	jal	80000c5a <acquire>
  ip->ref++;
    800034c6:	449c                	lw	a5,8(s1)
    800034c8:	2785                	addiw	a5,a5,1
    800034ca:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    800034cc:	0001f517          	auipc	a0,0x1f
    800034d0:	82c50513          	addi	a0,a0,-2004 # 80021cf8 <itable>
    800034d4:	81bfd0ef          	jal	80000cee <release>
}
    800034d8:	8526                	mv	a0,s1
    800034da:	60e2                	ld	ra,24(sp)
    800034dc:	6442                	ld	s0,16(sp)
    800034de:	64a2                	ld	s1,8(sp)
    800034e0:	6105                	addi	sp,sp,32
    800034e2:	8082                	ret

00000000800034e4 <ilock>:
{
    800034e4:	1101                	addi	sp,sp,-32
    800034e6:	ec06                	sd	ra,24(sp)
    800034e8:	e822                	sd	s0,16(sp)
    800034ea:	e426                	sd	s1,8(sp)
    800034ec:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    800034ee:	cd19                	beqz	a0,8000350c <ilock+0x28>
    800034f0:	84aa                	mv	s1,a0
    800034f2:	451c                	lw	a5,8(a0)
    800034f4:	00f05c63          	blez	a5,8000350c <ilock+0x28>
  acquiresleep(&ip->lock);
    800034f8:	0541                	addi	a0,a0,16
    800034fa:	48b000ef          	jal	80004184 <acquiresleep>
  if(ip->valid == 0){
    800034fe:	40bc                	lw	a5,64(s1)
    80003500:	cf89                	beqz	a5,8000351a <ilock+0x36>
}
    80003502:	60e2                	ld	ra,24(sp)
    80003504:	6442                	ld	s0,16(sp)
    80003506:	64a2                	ld	s1,8(sp)
    80003508:	6105                	addi	sp,sp,32
    8000350a:	8082                	ret
    8000350c:	e04a                	sd	s2,0(sp)
    panic("ilock");
    8000350e:	00005517          	auipc	a0,0x5
    80003512:	f7250513          	addi	a0,a0,-142 # 80008480 <etext+0x480>
    80003516:	b40fd0ef          	jal	80000856 <panic>
    8000351a:	e04a                	sd	s2,0(sp)
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    8000351c:	40dc                	lw	a5,4(s1)
    8000351e:	0047d79b          	srliw	a5,a5,0x4
    80003522:	0001e597          	auipc	a1,0x1e
    80003526:	7ce5a583          	lw	a1,1998(a1) # 80021cf0 <sb+0x18>
    8000352a:	9dbd                	addw	a1,a1,a5
    8000352c:	4088                	lw	a0,0(s1)
    8000352e:	8e1ff0ef          	jal	80002e0e <bread>
    80003532:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003534:	05850593          	addi	a1,a0,88
    80003538:	40dc                	lw	a5,4(s1)
    8000353a:	8bbd                	andi	a5,a5,15
    8000353c:	079a                	slli	a5,a5,0x6
    8000353e:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    80003540:	00059783          	lh	a5,0(a1)
    80003544:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    80003548:	00259783          	lh	a5,2(a1)
    8000354c:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    80003550:	00459783          	lh	a5,4(a1)
    80003554:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80003558:	00659783          	lh	a5,6(a1)
    8000355c:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    80003560:	459c                	lw	a5,8(a1)
    80003562:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80003564:	03400613          	li	a2,52
    80003568:	05b1                	addi	a1,a1,12
    8000356a:	05048513          	addi	a0,s1,80
    8000356e:	81dfd0ef          	jal	80000d8a <memmove>
    brelse(bp);
    80003572:	854a                	mv	a0,s2
    80003574:	9cbff0ef          	jal	80002f3e <brelse>
    ip->valid = 1;
    80003578:	4785                	li	a5,1
    8000357a:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    8000357c:	04449783          	lh	a5,68(s1)
    80003580:	c399                	beqz	a5,80003586 <ilock+0xa2>
    80003582:	6902                	ld	s2,0(sp)
    80003584:	bfbd                	j	80003502 <ilock+0x1e>
      panic("ilock: no type");
    80003586:	00005517          	auipc	a0,0x5
    8000358a:	f0250513          	addi	a0,a0,-254 # 80008488 <etext+0x488>
    8000358e:	ac8fd0ef          	jal	80000856 <panic>

0000000080003592 <iunlock>:
{
    80003592:	1101                	addi	sp,sp,-32
    80003594:	ec06                	sd	ra,24(sp)
    80003596:	e822                	sd	s0,16(sp)
    80003598:	e426                	sd	s1,8(sp)
    8000359a:	e04a                	sd	s2,0(sp)
    8000359c:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    8000359e:	c505                	beqz	a0,800035c6 <iunlock+0x34>
    800035a0:	84aa                	mv	s1,a0
    800035a2:	01050913          	addi	s2,a0,16
    800035a6:	854a                	mv	a0,s2
    800035a8:	45b000ef          	jal	80004202 <holdingsleep>
    800035ac:	cd09                	beqz	a0,800035c6 <iunlock+0x34>
    800035ae:	449c                	lw	a5,8(s1)
    800035b0:	00f05b63          	blez	a5,800035c6 <iunlock+0x34>
  releasesleep(&ip->lock);
    800035b4:	854a                	mv	a0,s2
    800035b6:	415000ef          	jal	800041ca <releasesleep>
}
    800035ba:	60e2                	ld	ra,24(sp)
    800035bc:	6442                	ld	s0,16(sp)
    800035be:	64a2                	ld	s1,8(sp)
    800035c0:	6902                	ld	s2,0(sp)
    800035c2:	6105                	addi	sp,sp,32
    800035c4:	8082                	ret
    panic("iunlock");
    800035c6:	00005517          	auipc	a0,0x5
    800035ca:	ed250513          	addi	a0,a0,-302 # 80008498 <etext+0x498>
    800035ce:	a88fd0ef          	jal	80000856 <panic>

00000000800035d2 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    800035d2:	7179                	addi	sp,sp,-48
    800035d4:	f406                	sd	ra,40(sp)
    800035d6:	f022                	sd	s0,32(sp)
    800035d8:	ec26                	sd	s1,24(sp)
    800035da:	e84a                	sd	s2,16(sp)
    800035dc:	e44e                	sd	s3,8(sp)
    800035de:	1800                	addi	s0,sp,48
    800035e0:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    800035e2:	05050493          	addi	s1,a0,80
    800035e6:	08050913          	addi	s2,a0,128
    800035ea:	a021                	j	800035f2 <itrunc+0x20>
    800035ec:	0491                	addi	s1,s1,4
    800035ee:	01248b63          	beq	s1,s2,80003604 <itrunc+0x32>
    if(ip->addrs[i]){
    800035f2:	408c                	lw	a1,0(s1)
    800035f4:	dde5                	beqz	a1,800035ec <itrunc+0x1a>
      bfree(ip->dev, ip->addrs[i]);
    800035f6:	0009a503          	lw	a0,0(s3)
    800035fa:	a47ff0ef          	jal	80003040 <bfree>
      ip->addrs[i] = 0;
    800035fe:	0004a023          	sw	zero,0(s1)
    80003602:	b7ed                	j	800035ec <itrunc+0x1a>
    }
  }

  if(ip->addrs[NDIRECT]){
    80003604:	0809a583          	lw	a1,128(s3)
    80003608:	ed89                	bnez	a1,80003622 <itrunc+0x50>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    8000360a:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    8000360e:	854e                	mv	a0,s3
    80003610:	e21ff0ef          	jal	80003430 <iupdate>
}
    80003614:	70a2                	ld	ra,40(sp)
    80003616:	7402                	ld	s0,32(sp)
    80003618:	64e2                	ld	s1,24(sp)
    8000361a:	6942                	ld	s2,16(sp)
    8000361c:	69a2                	ld	s3,8(sp)
    8000361e:	6145                	addi	sp,sp,48
    80003620:	8082                	ret
    80003622:	e052                	sd	s4,0(sp)
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80003624:	0009a503          	lw	a0,0(s3)
    80003628:	fe6ff0ef          	jal	80002e0e <bread>
    8000362c:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    8000362e:	05850493          	addi	s1,a0,88
    80003632:	45850913          	addi	s2,a0,1112
    80003636:	a021                	j	8000363e <itrunc+0x6c>
    80003638:	0491                	addi	s1,s1,4
    8000363a:	01248963          	beq	s1,s2,8000364c <itrunc+0x7a>
      if(a[j])
    8000363e:	408c                	lw	a1,0(s1)
    80003640:	dde5                	beqz	a1,80003638 <itrunc+0x66>
        bfree(ip->dev, a[j]);
    80003642:	0009a503          	lw	a0,0(s3)
    80003646:	9fbff0ef          	jal	80003040 <bfree>
    8000364a:	b7fd                	j	80003638 <itrunc+0x66>
    brelse(bp);
    8000364c:	8552                	mv	a0,s4
    8000364e:	8f1ff0ef          	jal	80002f3e <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80003652:	0809a583          	lw	a1,128(s3)
    80003656:	0009a503          	lw	a0,0(s3)
    8000365a:	9e7ff0ef          	jal	80003040 <bfree>
    ip->addrs[NDIRECT] = 0;
    8000365e:	0809a023          	sw	zero,128(s3)
    80003662:	6a02                	ld	s4,0(sp)
    80003664:	b75d                	j	8000360a <itrunc+0x38>

0000000080003666 <iput>:
{
    80003666:	1101                	addi	sp,sp,-32
    80003668:	ec06                	sd	ra,24(sp)
    8000366a:	e822                	sd	s0,16(sp)
    8000366c:	e426                	sd	s1,8(sp)
    8000366e:	1000                	addi	s0,sp,32
    80003670:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003672:	0001e517          	auipc	a0,0x1e
    80003676:	68650513          	addi	a0,a0,1670 # 80021cf8 <itable>
    8000367a:	de0fd0ef          	jal	80000c5a <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    8000367e:	4498                	lw	a4,8(s1)
    80003680:	4785                	li	a5,1
    80003682:	02f70063          	beq	a4,a5,800036a2 <iput+0x3c>
  ip->ref--;
    80003686:	449c                	lw	a5,8(s1)
    80003688:	37fd                	addiw	a5,a5,-1
    8000368a:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    8000368c:	0001e517          	auipc	a0,0x1e
    80003690:	66c50513          	addi	a0,a0,1644 # 80021cf8 <itable>
    80003694:	e5afd0ef          	jal	80000cee <release>
}
    80003698:	60e2                	ld	ra,24(sp)
    8000369a:	6442                	ld	s0,16(sp)
    8000369c:	64a2                	ld	s1,8(sp)
    8000369e:	6105                	addi	sp,sp,32
    800036a0:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    800036a2:	40bc                	lw	a5,64(s1)
    800036a4:	d3ed                	beqz	a5,80003686 <iput+0x20>
    800036a6:	04a49783          	lh	a5,74(s1)
    800036aa:	fff1                	bnez	a5,80003686 <iput+0x20>
    800036ac:	e04a                	sd	s2,0(sp)
    acquiresleep(&ip->lock);
    800036ae:	01048793          	addi	a5,s1,16
    800036b2:	893e                	mv	s2,a5
    800036b4:	853e                	mv	a0,a5
    800036b6:	2cf000ef          	jal	80004184 <acquiresleep>
    release(&itable.lock);
    800036ba:	0001e517          	auipc	a0,0x1e
    800036be:	63e50513          	addi	a0,a0,1598 # 80021cf8 <itable>
    800036c2:	e2cfd0ef          	jal	80000cee <release>
    itrunc(ip);
    800036c6:	8526                	mv	a0,s1
    800036c8:	f0bff0ef          	jal	800035d2 <itrunc>
    ip->type = 0;
    800036cc:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    800036d0:	8526                	mv	a0,s1
    800036d2:	d5fff0ef          	jal	80003430 <iupdate>
    ip->valid = 0;
    800036d6:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    800036da:	854a                	mv	a0,s2
    800036dc:	2ef000ef          	jal	800041ca <releasesleep>
    acquire(&itable.lock);
    800036e0:	0001e517          	auipc	a0,0x1e
    800036e4:	61850513          	addi	a0,a0,1560 # 80021cf8 <itable>
    800036e8:	d72fd0ef          	jal	80000c5a <acquire>
    800036ec:	6902                	ld	s2,0(sp)
    800036ee:	bf61                	j	80003686 <iput+0x20>

00000000800036f0 <iunlockput>:
{
    800036f0:	1101                	addi	sp,sp,-32
    800036f2:	ec06                	sd	ra,24(sp)
    800036f4:	e822                	sd	s0,16(sp)
    800036f6:	e426                	sd	s1,8(sp)
    800036f8:	1000                	addi	s0,sp,32
    800036fa:	84aa                	mv	s1,a0
  iunlock(ip);
    800036fc:	e97ff0ef          	jal	80003592 <iunlock>
  iput(ip);
    80003700:	8526                	mv	a0,s1
    80003702:	f65ff0ef          	jal	80003666 <iput>
}
    80003706:	60e2                	ld	ra,24(sp)
    80003708:	6442                	ld	s0,16(sp)
    8000370a:	64a2                	ld	s1,8(sp)
    8000370c:	6105                	addi	sp,sp,32
    8000370e:	8082                	ret

0000000080003710 <ireclaim>:
  for (int inum = 1; inum < sb.ninodes; inum++) {
    80003710:	0001e717          	auipc	a4,0x1e
    80003714:	5d472703          	lw	a4,1492(a4) # 80021ce4 <sb+0xc>
    80003718:	4785                	li	a5,1
    8000371a:	0ae7fe63          	bgeu	a5,a4,800037d6 <ireclaim+0xc6>
{
    8000371e:	7139                	addi	sp,sp,-64
    80003720:	fc06                	sd	ra,56(sp)
    80003722:	f822                	sd	s0,48(sp)
    80003724:	f426                	sd	s1,40(sp)
    80003726:	f04a                	sd	s2,32(sp)
    80003728:	ec4e                	sd	s3,24(sp)
    8000372a:	e852                	sd	s4,16(sp)
    8000372c:	e456                	sd	s5,8(sp)
    8000372e:	e05a                	sd	s6,0(sp)
    80003730:	0080                	addi	s0,sp,64
    80003732:	8aaa                	mv	s5,a0
  for (int inum = 1; inum < sb.ninodes; inum++) {
    80003734:	84be                	mv	s1,a5
    struct buf *bp = bread(dev, IBLOCK(inum, sb));
    80003736:	0001ea17          	auipc	s4,0x1e
    8000373a:	5a2a0a13          	addi	s4,s4,1442 # 80021cd8 <sb>
      printf("ireclaim: orphaned inode %d\n", inum);
    8000373e:	00005b17          	auipc	s6,0x5
    80003742:	d62b0b13          	addi	s6,s6,-670 # 800084a0 <etext+0x4a0>
    80003746:	a099                	j	8000378c <ireclaim+0x7c>
    80003748:	85ce                	mv	a1,s3
    8000374a:	855a                	mv	a0,s6
    8000374c:	de1fc0ef          	jal	8000052c <printf>
      ip = iget(dev, inum);
    80003750:	85ce                	mv	a1,s3
    80003752:	8556                	mv	a0,s5
    80003754:	b1fff0ef          	jal	80003272 <iget>
    80003758:	89aa                	mv	s3,a0
    brelse(bp);
    8000375a:	854a                	mv	a0,s2
    8000375c:	fe2ff0ef          	jal	80002f3e <brelse>
    if (ip) {
    80003760:	00098f63          	beqz	s3,8000377e <ireclaim+0x6e>
      begin_op();
    80003764:	78c000ef          	jal	80003ef0 <begin_op>
      ilock(ip);
    80003768:	854e                	mv	a0,s3
    8000376a:	d7bff0ef          	jal	800034e4 <ilock>
      iunlock(ip);
    8000376e:	854e                	mv	a0,s3
    80003770:	e23ff0ef          	jal	80003592 <iunlock>
      iput(ip);
    80003774:	854e                	mv	a0,s3
    80003776:	ef1ff0ef          	jal	80003666 <iput>
      end_op();
    8000377a:	7e6000ef          	jal	80003f60 <end_op>
  for (int inum = 1; inum < sb.ninodes; inum++) {
    8000377e:	0485                	addi	s1,s1,1
    80003780:	00ca2703          	lw	a4,12(s4)
    80003784:	0004879b          	sext.w	a5,s1
    80003788:	02e7fd63          	bgeu	a5,a4,800037c2 <ireclaim+0xb2>
    8000378c:	0004899b          	sext.w	s3,s1
    struct buf *bp = bread(dev, IBLOCK(inum, sb));
    80003790:	0044d593          	srli	a1,s1,0x4
    80003794:	018a2783          	lw	a5,24(s4)
    80003798:	9dbd                	addw	a1,a1,a5
    8000379a:	8556                	mv	a0,s5
    8000379c:	e72ff0ef          	jal	80002e0e <bread>
    800037a0:	892a                	mv	s2,a0
    struct dinode *dip = (struct dinode *)bp->data + inum % IPB;
    800037a2:	05850793          	addi	a5,a0,88
    800037a6:	00f9f713          	andi	a4,s3,15
    800037aa:	071a                	slli	a4,a4,0x6
    800037ac:	97ba                	add	a5,a5,a4
    if (dip->type != 0 && dip->nlink == 0) {  // is an orphaned inode
    800037ae:	00079703          	lh	a4,0(a5)
    800037b2:	c701                	beqz	a4,800037ba <ireclaim+0xaa>
    800037b4:	00679783          	lh	a5,6(a5)
    800037b8:	dbc1                	beqz	a5,80003748 <ireclaim+0x38>
    brelse(bp);
    800037ba:	854a                	mv	a0,s2
    800037bc:	f82ff0ef          	jal	80002f3e <brelse>
    if (ip) {
    800037c0:	bf7d                	j	8000377e <ireclaim+0x6e>
}
    800037c2:	70e2                	ld	ra,56(sp)
    800037c4:	7442                	ld	s0,48(sp)
    800037c6:	74a2                	ld	s1,40(sp)
    800037c8:	7902                	ld	s2,32(sp)
    800037ca:	69e2                	ld	s3,24(sp)
    800037cc:	6a42                	ld	s4,16(sp)
    800037ce:	6aa2                	ld	s5,8(sp)
    800037d0:	6b02                	ld	s6,0(sp)
    800037d2:	6121                	addi	sp,sp,64
    800037d4:	8082                	ret
    800037d6:	8082                	ret

00000000800037d8 <fsinit>:
fsinit(int dev) {
    800037d8:	1101                	addi	sp,sp,-32
    800037da:	ec06                	sd	ra,24(sp)
    800037dc:	e822                	sd	s0,16(sp)
    800037de:	e426                	sd	s1,8(sp)
    800037e0:	e04a                	sd	s2,0(sp)
    800037e2:	1000                	addi	s0,sp,32
    800037e4:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    800037e6:	4585                	li	a1,1
    800037e8:	e26ff0ef          	jal	80002e0e <bread>
    800037ec:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    800037ee:	02000613          	li	a2,32
    800037f2:	05850593          	addi	a1,a0,88
    800037f6:	0001e517          	auipc	a0,0x1e
    800037fa:	4e250513          	addi	a0,a0,1250 # 80021cd8 <sb>
    800037fe:	d8cfd0ef          	jal	80000d8a <memmove>
  brelse(bp);
    80003802:	8526                	mv	a0,s1
    80003804:	f3aff0ef          	jal	80002f3e <brelse>
  if(sb.magic != FSMAGIC)
    80003808:	0001e717          	auipc	a4,0x1e
    8000380c:	4d072703          	lw	a4,1232(a4) # 80021cd8 <sb>
    80003810:	102037b7          	lui	a5,0x10203
    80003814:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    80003818:	02f71263          	bne	a4,a5,8000383c <fsinit+0x64>
  initlog(dev, &sb);
    8000381c:	0001e597          	auipc	a1,0x1e
    80003820:	4bc58593          	addi	a1,a1,1212 # 80021cd8 <sb>
    80003824:	854a                	mv	a0,s2
    80003826:	648000ef          	jal	80003e6e <initlog>
  ireclaim(dev);
    8000382a:	854a                	mv	a0,s2
    8000382c:	ee5ff0ef          	jal	80003710 <ireclaim>
}
    80003830:	60e2                	ld	ra,24(sp)
    80003832:	6442                	ld	s0,16(sp)
    80003834:	64a2                	ld	s1,8(sp)
    80003836:	6902                	ld	s2,0(sp)
    80003838:	6105                	addi	sp,sp,32
    8000383a:	8082                	ret
    panic("invalid file system");
    8000383c:	00005517          	auipc	a0,0x5
    80003840:	c8450513          	addi	a0,a0,-892 # 800084c0 <etext+0x4c0>
    80003844:	812fd0ef          	jal	80000856 <panic>

0000000080003848 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80003848:	1141                	addi	sp,sp,-16
    8000384a:	e406                	sd	ra,8(sp)
    8000384c:	e022                	sd	s0,0(sp)
    8000384e:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80003850:	411c                	lw	a5,0(a0)
    80003852:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80003854:	415c                	lw	a5,4(a0)
    80003856:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80003858:	04451783          	lh	a5,68(a0)
    8000385c:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80003860:	04a51783          	lh	a5,74(a0)
    80003864:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80003868:	04c56783          	lwu	a5,76(a0)
    8000386c:	e99c                	sd	a5,16(a1)
}
    8000386e:	60a2                	ld	ra,8(sp)
    80003870:	6402                	ld	s0,0(sp)
    80003872:	0141                	addi	sp,sp,16
    80003874:	8082                	ret

0000000080003876 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003876:	457c                	lw	a5,76(a0)
    80003878:	0ed7e663          	bltu	a5,a3,80003964 <readi+0xee>
{
    8000387c:	7159                	addi	sp,sp,-112
    8000387e:	f486                	sd	ra,104(sp)
    80003880:	f0a2                	sd	s0,96(sp)
    80003882:	eca6                	sd	s1,88(sp)
    80003884:	e0d2                	sd	s4,64(sp)
    80003886:	fc56                	sd	s5,56(sp)
    80003888:	f85a                	sd	s6,48(sp)
    8000388a:	f45e                	sd	s7,40(sp)
    8000388c:	1880                	addi	s0,sp,112
    8000388e:	8b2a                	mv	s6,a0
    80003890:	8bae                	mv	s7,a1
    80003892:	8a32                	mv	s4,a2
    80003894:	84b6                	mv	s1,a3
    80003896:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    80003898:	9f35                	addw	a4,a4,a3
    return 0;
    8000389a:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    8000389c:	0ad76b63          	bltu	a4,a3,80003952 <readi+0xdc>
    800038a0:	e4ce                	sd	s3,72(sp)
  if(off + n > ip->size)
    800038a2:	00e7f463          	bgeu	a5,a4,800038aa <readi+0x34>
    n = ip->size - off;
    800038a6:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    800038aa:	080a8b63          	beqz	s5,80003940 <readi+0xca>
    800038ae:	e8ca                	sd	s2,80(sp)
    800038b0:	f062                	sd	s8,32(sp)
    800038b2:	ec66                	sd	s9,24(sp)
    800038b4:	e86a                	sd	s10,16(sp)
    800038b6:	e46e                	sd	s11,8(sp)
    800038b8:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    800038ba:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    800038be:	5c7d                	li	s8,-1
    800038c0:	a80d                	j	800038f2 <readi+0x7c>
    800038c2:	020d1d93          	slli	s11,s10,0x20
    800038c6:	020ddd93          	srli	s11,s11,0x20
    800038ca:	05890613          	addi	a2,s2,88
    800038ce:	86ee                	mv	a3,s11
    800038d0:	963e                	add	a2,a2,a5
    800038d2:	85d2                	mv	a1,s4
    800038d4:	855e                	mv	a0,s7
    800038d6:	bc1fe0ef          	jal	80002496 <either_copyout>
    800038da:	05850363          	beq	a0,s8,80003920 <readi+0xaa>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    800038de:	854a                	mv	a0,s2
    800038e0:	e5eff0ef          	jal	80002f3e <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    800038e4:	013d09bb          	addw	s3,s10,s3
    800038e8:	009d04bb          	addw	s1,s10,s1
    800038ec:	9a6e                	add	s4,s4,s11
    800038ee:	0559f363          	bgeu	s3,s5,80003934 <readi+0xbe>
    uint addr = bmap(ip, off/BSIZE);
    800038f2:	00a4d59b          	srliw	a1,s1,0xa
    800038f6:	855a                	mv	a0,s6
    800038f8:	8bbff0ef          	jal	800031b2 <bmap>
    800038fc:	85aa                	mv	a1,a0
    if(addr == 0)
    800038fe:	c139                	beqz	a0,80003944 <readi+0xce>
    bp = bread(ip->dev, addr);
    80003900:	000b2503          	lw	a0,0(s6)
    80003904:	d0aff0ef          	jal	80002e0e <bread>
    80003908:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    8000390a:	3ff4f793          	andi	a5,s1,1023
    8000390e:	40fc873b          	subw	a4,s9,a5
    80003912:	413a86bb          	subw	a3,s5,s3
    80003916:	8d3a                	mv	s10,a4
    80003918:	fae6f5e3          	bgeu	a3,a4,800038c2 <readi+0x4c>
    8000391c:	8d36                	mv	s10,a3
    8000391e:	b755                	j	800038c2 <readi+0x4c>
      brelse(bp);
    80003920:	854a                	mv	a0,s2
    80003922:	e1cff0ef          	jal	80002f3e <brelse>
      tot = -1;
    80003926:	59fd                	li	s3,-1
      break;
    80003928:	6946                	ld	s2,80(sp)
    8000392a:	7c02                	ld	s8,32(sp)
    8000392c:	6ce2                	ld	s9,24(sp)
    8000392e:	6d42                	ld	s10,16(sp)
    80003930:	6da2                	ld	s11,8(sp)
    80003932:	a831                	j	8000394e <readi+0xd8>
    80003934:	6946                	ld	s2,80(sp)
    80003936:	7c02                	ld	s8,32(sp)
    80003938:	6ce2                	ld	s9,24(sp)
    8000393a:	6d42                	ld	s10,16(sp)
    8000393c:	6da2                	ld	s11,8(sp)
    8000393e:	a801                	j	8000394e <readi+0xd8>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003940:	89d6                	mv	s3,s5
    80003942:	a031                	j	8000394e <readi+0xd8>
    80003944:	6946                	ld	s2,80(sp)
    80003946:	7c02                	ld	s8,32(sp)
    80003948:	6ce2                	ld	s9,24(sp)
    8000394a:	6d42                	ld	s10,16(sp)
    8000394c:	6da2                	ld	s11,8(sp)
  }
  return tot;
    8000394e:	854e                	mv	a0,s3
    80003950:	69a6                	ld	s3,72(sp)
}
    80003952:	70a6                	ld	ra,104(sp)
    80003954:	7406                	ld	s0,96(sp)
    80003956:	64e6                	ld	s1,88(sp)
    80003958:	6a06                	ld	s4,64(sp)
    8000395a:	7ae2                	ld	s5,56(sp)
    8000395c:	7b42                	ld	s6,48(sp)
    8000395e:	7ba2                	ld	s7,40(sp)
    80003960:	6165                	addi	sp,sp,112
    80003962:	8082                	ret
    return 0;
    80003964:	4501                	li	a0,0
}
    80003966:	8082                	ret

0000000080003968 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003968:	457c                	lw	a5,76(a0)
    8000396a:	0ed7eb63          	bltu	a5,a3,80003a60 <writei+0xf8>
{
    8000396e:	7159                	addi	sp,sp,-112
    80003970:	f486                	sd	ra,104(sp)
    80003972:	f0a2                	sd	s0,96(sp)
    80003974:	e8ca                	sd	s2,80(sp)
    80003976:	e0d2                	sd	s4,64(sp)
    80003978:	fc56                	sd	s5,56(sp)
    8000397a:	f85a                	sd	s6,48(sp)
    8000397c:	f45e                	sd	s7,40(sp)
    8000397e:	1880                	addi	s0,sp,112
    80003980:	8aaa                	mv	s5,a0
    80003982:	8bae                	mv	s7,a1
    80003984:	8a32                	mv	s4,a2
    80003986:	8936                	mv	s2,a3
    80003988:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    8000398a:	00e687bb          	addw	a5,a3,a4
    return -1;
  if(off + n > MAXFILE*BSIZE)
    8000398e:	00043737          	lui	a4,0x43
    80003992:	0cf76963          	bltu	a4,a5,80003a64 <writei+0xfc>
    80003996:	0cd7e763          	bltu	a5,a3,80003a64 <writei+0xfc>
    8000399a:	e4ce                	sd	s3,72(sp)
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    8000399c:	0a0b0a63          	beqz	s6,80003a50 <writei+0xe8>
    800039a0:	eca6                	sd	s1,88(sp)
    800039a2:	f062                	sd	s8,32(sp)
    800039a4:	ec66                	sd	s9,24(sp)
    800039a6:	e86a                	sd	s10,16(sp)
    800039a8:	e46e                	sd	s11,8(sp)
    800039aa:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    800039ac:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    800039b0:	5c7d                	li	s8,-1
    800039b2:	a825                	j	800039ea <writei+0x82>
    800039b4:	020d1d93          	slli	s11,s10,0x20
    800039b8:	020ddd93          	srli	s11,s11,0x20
    800039bc:	05848513          	addi	a0,s1,88
    800039c0:	86ee                	mv	a3,s11
    800039c2:	8652                	mv	a2,s4
    800039c4:	85de                	mv	a1,s7
    800039c6:	953e                	add	a0,a0,a5
    800039c8:	b19fe0ef          	jal	800024e0 <either_copyin>
    800039cc:	05850663          	beq	a0,s8,80003a18 <writei+0xb0>
      brelse(bp);
      break;
    }
    log_write(bp);
    800039d0:	8526                	mv	a0,s1
    800039d2:	6b8000ef          	jal	8000408a <log_write>
    brelse(bp);
    800039d6:	8526                	mv	a0,s1
    800039d8:	d66ff0ef          	jal	80002f3e <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    800039dc:	013d09bb          	addw	s3,s10,s3
    800039e0:	012d093b          	addw	s2,s10,s2
    800039e4:	9a6e                	add	s4,s4,s11
    800039e6:	0369fc63          	bgeu	s3,s6,80003a1e <writei+0xb6>
    uint addr = bmap(ip, off/BSIZE);
    800039ea:	00a9559b          	srliw	a1,s2,0xa
    800039ee:	8556                	mv	a0,s5
    800039f0:	fc2ff0ef          	jal	800031b2 <bmap>
    800039f4:	85aa                	mv	a1,a0
    if(addr == 0)
    800039f6:	c505                	beqz	a0,80003a1e <writei+0xb6>
    bp = bread(ip->dev, addr);
    800039f8:	000aa503          	lw	a0,0(s5)
    800039fc:	c12ff0ef          	jal	80002e0e <bread>
    80003a00:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003a02:	3ff97793          	andi	a5,s2,1023
    80003a06:	40fc873b          	subw	a4,s9,a5
    80003a0a:	413b06bb          	subw	a3,s6,s3
    80003a0e:	8d3a                	mv	s10,a4
    80003a10:	fae6f2e3          	bgeu	a3,a4,800039b4 <writei+0x4c>
    80003a14:	8d36                	mv	s10,a3
    80003a16:	bf79                	j	800039b4 <writei+0x4c>
      brelse(bp);
    80003a18:	8526                	mv	a0,s1
    80003a1a:	d24ff0ef          	jal	80002f3e <brelse>
  }

  if(off > ip->size)
    80003a1e:	04caa783          	lw	a5,76(s5)
    80003a22:	0327f963          	bgeu	a5,s2,80003a54 <writei+0xec>
    ip->size = off;
    80003a26:	052aa623          	sw	s2,76(s5)
    80003a2a:	64e6                	ld	s1,88(sp)
    80003a2c:	7c02                	ld	s8,32(sp)
    80003a2e:	6ce2                	ld	s9,24(sp)
    80003a30:	6d42                	ld	s10,16(sp)
    80003a32:	6da2                	ld	s11,8(sp)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80003a34:	8556                	mv	a0,s5
    80003a36:	9fbff0ef          	jal	80003430 <iupdate>

  return tot;
    80003a3a:	854e                	mv	a0,s3
    80003a3c:	69a6                	ld	s3,72(sp)
}
    80003a3e:	70a6                	ld	ra,104(sp)
    80003a40:	7406                	ld	s0,96(sp)
    80003a42:	6946                	ld	s2,80(sp)
    80003a44:	6a06                	ld	s4,64(sp)
    80003a46:	7ae2                	ld	s5,56(sp)
    80003a48:	7b42                	ld	s6,48(sp)
    80003a4a:	7ba2                	ld	s7,40(sp)
    80003a4c:	6165                	addi	sp,sp,112
    80003a4e:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003a50:	89da                	mv	s3,s6
    80003a52:	b7cd                	j	80003a34 <writei+0xcc>
    80003a54:	64e6                	ld	s1,88(sp)
    80003a56:	7c02                	ld	s8,32(sp)
    80003a58:	6ce2                	ld	s9,24(sp)
    80003a5a:	6d42                	ld	s10,16(sp)
    80003a5c:	6da2                	ld	s11,8(sp)
    80003a5e:	bfd9                	j	80003a34 <writei+0xcc>
    return -1;
    80003a60:	557d                	li	a0,-1
}
    80003a62:	8082                	ret
    return -1;
    80003a64:	557d                	li	a0,-1
    80003a66:	bfe1                	j	80003a3e <writei+0xd6>

0000000080003a68 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80003a68:	1141                	addi	sp,sp,-16
    80003a6a:	e406                	sd	ra,8(sp)
    80003a6c:	e022                	sd	s0,0(sp)
    80003a6e:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80003a70:	4639                	li	a2,14
    80003a72:	b8cfd0ef          	jal	80000dfe <strncmp>
}
    80003a76:	60a2                	ld	ra,8(sp)
    80003a78:	6402                	ld	s0,0(sp)
    80003a7a:	0141                	addi	sp,sp,16
    80003a7c:	8082                	ret

0000000080003a7e <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80003a7e:	711d                	addi	sp,sp,-96
    80003a80:	ec86                	sd	ra,88(sp)
    80003a82:	e8a2                	sd	s0,80(sp)
    80003a84:	e4a6                	sd	s1,72(sp)
    80003a86:	e0ca                	sd	s2,64(sp)
    80003a88:	fc4e                	sd	s3,56(sp)
    80003a8a:	f852                	sd	s4,48(sp)
    80003a8c:	f456                	sd	s5,40(sp)
    80003a8e:	f05a                	sd	s6,32(sp)
    80003a90:	ec5e                	sd	s7,24(sp)
    80003a92:	1080                	addi	s0,sp,96
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80003a94:	04451703          	lh	a4,68(a0)
    80003a98:	4785                	li	a5,1
    80003a9a:	00f71f63          	bne	a4,a5,80003ab8 <dirlookup+0x3a>
    80003a9e:	892a                	mv	s2,a0
    80003aa0:	8aae                	mv	s5,a1
    80003aa2:	8bb2                	mv	s7,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80003aa4:	457c                	lw	a5,76(a0)
    80003aa6:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003aa8:	fa040a13          	addi	s4,s0,-96
    80003aac:	49c1                	li	s3,16
      panic("dirlookup read");
    if(de.inum == 0)
      continue;
    if(namecmp(name, de.name) == 0){
    80003aae:	fa240b13          	addi	s6,s0,-94
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80003ab2:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003ab4:	e39d                	bnez	a5,80003ada <dirlookup+0x5c>
    80003ab6:	a8b9                	j	80003b14 <dirlookup+0x96>
    panic("dirlookup not DIR");
    80003ab8:	00005517          	auipc	a0,0x5
    80003abc:	a2050513          	addi	a0,a0,-1504 # 800084d8 <etext+0x4d8>
    80003ac0:	d97fc0ef          	jal	80000856 <panic>
      panic("dirlookup read");
    80003ac4:	00005517          	auipc	a0,0x5
    80003ac8:	a2c50513          	addi	a0,a0,-1492 # 800084f0 <etext+0x4f0>
    80003acc:	d8bfc0ef          	jal	80000856 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003ad0:	24c1                	addiw	s1,s1,16
    80003ad2:	04c92783          	lw	a5,76(s2)
    80003ad6:	02f4fe63          	bgeu	s1,a5,80003b12 <dirlookup+0x94>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003ada:	874e                	mv	a4,s3
    80003adc:	86a6                	mv	a3,s1
    80003ade:	8652                	mv	a2,s4
    80003ae0:	4581                	li	a1,0
    80003ae2:	854a                	mv	a0,s2
    80003ae4:	d93ff0ef          	jal	80003876 <readi>
    80003ae8:	fd351ee3          	bne	a0,s3,80003ac4 <dirlookup+0x46>
    if(de.inum == 0)
    80003aec:	fa045783          	lhu	a5,-96(s0)
    80003af0:	d3e5                	beqz	a5,80003ad0 <dirlookup+0x52>
    if(namecmp(name, de.name) == 0){
    80003af2:	85da                	mv	a1,s6
    80003af4:	8556                	mv	a0,s5
    80003af6:	f73ff0ef          	jal	80003a68 <namecmp>
    80003afa:	f979                	bnez	a0,80003ad0 <dirlookup+0x52>
      if(poff)
    80003afc:	000b8463          	beqz	s7,80003b04 <dirlookup+0x86>
        *poff = off;
    80003b00:	009ba023          	sw	s1,0(s7)
      return iget(dp->dev, inum);
    80003b04:	fa045583          	lhu	a1,-96(s0)
    80003b08:	00092503          	lw	a0,0(s2)
    80003b0c:	f66ff0ef          	jal	80003272 <iget>
    80003b10:	a011                	j	80003b14 <dirlookup+0x96>
  return 0;
    80003b12:	4501                	li	a0,0
}
    80003b14:	60e6                	ld	ra,88(sp)
    80003b16:	6446                	ld	s0,80(sp)
    80003b18:	64a6                	ld	s1,72(sp)
    80003b1a:	6906                	ld	s2,64(sp)
    80003b1c:	79e2                	ld	s3,56(sp)
    80003b1e:	7a42                	ld	s4,48(sp)
    80003b20:	7aa2                	ld	s5,40(sp)
    80003b22:	7b02                	ld	s6,32(sp)
    80003b24:	6be2                	ld	s7,24(sp)
    80003b26:	6125                	addi	sp,sp,96
    80003b28:	8082                	ret

0000000080003b2a <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80003b2a:	711d                	addi	sp,sp,-96
    80003b2c:	ec86                	sd	ra,88(sp)
    80003b2e:	e8a2                	sd	s0,80(sp)
    80003b30:	e4a6                	sd	s1,72(sp)
    80003b32:	e0ca                	sd	s2,64(sp)
    80003b34:	fc4e                	sd	s3,56(sp)
    80003b36:	f852                	sd	s4,48(sp)
    80003b38:	f456                	sd	s5,40(sp)
    80003b3a:	f05a                	sd	s6,32(sp)
    80003b3c:	ec5e                	sd	s7,24(sp)
    80003b3e:	e862                	sd	s8,16(sp)
    80003b40:	e466                	sd	s9,8(sp)
    80003b42:	e06a                	sd	s10,0(sp)
    80003b44:	1080                	addi	s0,sp,96
    80003b46:	84aa                	mv	s1,a0
    80003b48:	8b2e                	mv	s6,a1
    80003b4a:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    80003b4c:	00054703          	lbu	a4,0(a0)
    80003b50:	02f00793          	li	a5,47
    80003b54:	00f70f63          	beq	a4,a5,80003b72 <namex+0x48>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80003b58:	e25fd0ef          	jal	8000197c <myproc>
    80003b5c:	15053503          	ld	a0,336(a0)
    80003b60:	94fff0ef          	jal	800034ae <idup>
    80003b64:	8a2a                	mv	s4,a0
  while(*path == '/')
    80003b66:	02f00993          	li	s3,47
  if(len >= DIRSIZ)
    80003b6a:	4c35                	li	s8,13
    memmove(name, s, DIRSIZ);
    80003b6c:	4cb9                	li	s9,14

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80003b6e:	4b85                	li	s7,1
    80003b70:	a879                	j	80003c0e <namex+0xe4>
    ip = iget(ROOTDEV, ROOTINO);
    80003b72:	4585                	li	a1,1
    80003b74:	852e                	mv	a0,a1
    80003b76:	efcff0ef          	jal	80003272 <iget>
    80003b7a:	8a2a                	mv	s4,a0
    80003b7c:	b7ed                	j	80003b66 <namex+0x3c>
      iunlockput(ip);
    80003b7e:	8552                	mv	a0,s4
    80003b80:	b71ff0ef          	jal	800036f0 <iunlockput>
      return 0;
    80003b84:	4a01                	li	s4,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80003b86:	8552                	mv	a0,s4
    80003b88:	60e6                	ld	ra,88(sp)
    80003b8a:	6446                	ld	s0,80(sp)
    80003b8c:	64a6                	ld	s1,72(sp)
    80003b8e:	6906                	ld	s2,64(sp)
    80003b90:	79e2                	ld	s3,56(sp)
    80003b92:	7a42                	ld	s4,48(sp)
    80003b94:	7aa2                	ld	s5,40(sp)
    80003b96:	7b02                	ld	s6,32(sp)
    80003b98:	6be2                	ld	s7,24(sp)
    80003b9a:	6c42                	ld	s8,16(sp)
    80003b9c:	6ca2                	ld	s9,8(sp)
    80003b9e:	6d02                	ld	s10,0(sp)
    80003ba0:	6125                	addi	sp,sp,96
    80003ba2:	8082                	ret
      iunlock(ip);
    80003ba4:	8552                	mv	a0,s4
    80003ba6:	9edff0ef          	jal	80003592 <iunlock>
      return ip;
    80003baa:	bff1                	j	80003b86 <namex+0x5c>
      iunlockput(ip);
    80003bac:	8552                	mv	a0,s4
    80003bae:	b43ff0ef          	jal	800036f0 <iunlockput>
      return 0;
    80003bb2:	8a4a                	mv	s4,s2
    80003bb4:	bfc9                	j	80003b86 <namex+0x5c>
  len = path - s;
    80003bb6:	40990633          	sub	a2,s2,s1
    80003bba:	00060d1b          	sext.w	s10,a2
  if(len >= DIRSIZ)
    80003bbe:	09ac5463          	bge	s8,s10,80003c46 <namex+0x11c>
    memmove(name, s, DIRSIZ);
    80003bc2:	8666                	mv	a2,s9
    80003bc4:	85a6                	mv	a1,s1
    80003bc6:	8556                	mv	a0,s5
    80003bc8:	9c2fd0ef          	jal	80000d8a <memmove>
    80003bcc:	84ca                	mv	s1,s2
  while(*path == '/')
    80003bce:	0004c783          	lbu	a5,0(s1)
    80003bd2:	01379763          	bne	a5,s3,80003be0 <namex+0xb6>
    path++;
    80003bd6:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003bd8:	0004c783          	lbu	a5,0(s1)
    80003bdc:	ff378de3          	beq	a5,s3,80003bd6 <namex+0xac>
    ilock(ip);
    80003be0:	8552                	mv	a0,s4
    80003be2:	903ff0ef          	jal	800034e4 <ilock>
    if(ip->type != T_DIR){
    80003be6:	044a1783          	lh	a5,68(s4)
    80003bea:	f9779ae3          	bne	a5,s7,80003b7e <namex+0x54>
    if(nameiparent && *path == '\0'){
    80003bee:	000b0563          	beqz	s6,80003bf8 <namex+0xce>
    80003bf2:	0004c783          	lbu	a5,0(s1)
    80003bf6:	d7dd                	beqz	a5,80003ba4 <namex+0x7a>
    if((next = dirlookup(ip, name, 0)) == 0){
    80003bf8:	4601                	li	a2,0
    80003bfa:	85d6                	mv	a1,s5
    80003bfc:	8552                	mv	a0,s4
    80003bfe:	e81ff0ef          	jal	80003a7e <dirlookup>
    80003c02:	892a                	mv	s2,a0
    80003c04:	d545                	beqz	a0,80003bac <namex+0x82>
    iunlockput(ip);
    80003c06:	8552                	mv	a0,s4
    80003c08:	ae9ff0ef          	jal	800036f0 <iunlockput>
    ip = next;
    80003c0c:	8a4a                	mv	s4,s2
  while(*path == '/')
    80003c0e:	0004c783          	lbu	a5,0(s1)
    80003c12:	01379763          	bne	a5,s3,80003c20 <namex+0xf6>
    path++;
    80003c16:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003c18:	0004c783          	lbu	a5,0(s1)
    80003c1c:	ff378de3          	beq	a5,s3,80003c16 <namex+0xec>
  if(*path == 0)
    80003c20:	cf8d                	beqz	a5,80003c5a <namex+0x130>
  while(*path != '/' && *path != 0)
    80003c22:	0004c783          	lbu	a5,0(s1)
    80003c26:	fd178713          	addi	a4,a5,-47
    80003c2a:	cb19                	beqz	a4,80003c40 <namex+0x116>
    80003c2c:	cb91                	beqz	a5,80003c40 <namex+0x116>
    80003c2e:	8926                	mv	s2,s1
    path++;
    80003c30:	0905                	addi	s2,s2,1
  while(*path != '/' && *path != 0)
    80003c32:	00094783          	lbu	a5,0(s2)
    80003c36:	fd178713          	addi	a4,a5,-47
    80003c3a:	df35                	beqz	a4,80003bb6 <namex+0x8c>
    80003c3c:	fbf5                	bnez	a5,80003c30 <namex+0x106>
    80003c3e:	bfa5                	j	80003bb6 <namex+0x8c>
    80003c40:	8926                	mv	s2,s1
  len = path - s;
    80003c42:	4d01                	li	s10,0
    80003c44:	4601                	li	a2,0
    memmove(name, s, len);
    80003c46:	2601                	sext.w	a2,a2
    80003c48:	85a6                	mv	a1,s1
    80003c4a:	8556                	mv	a0,s5
    80003c4c:	93efd0ef          	jal	80000d8a <memmove>
    name[len] = 0;
    80003c50:	9d56                	add	s10,s10,s5
    80003c52:	000d0023          	sb	zero,0(s10) # fffffffffffff000 <end+0xffffffff7ffc2590>
    80003c56:	84ca                	mv	s1,s2
    80003c58:	bf9d                	j	80003bce <namex+0xa4>
  if(nameiparent){
    80003c5a:	f20b06e3          	beqz	s6,80003b86 <namex+0x5c>
    iput(ip);
    80003c5e:	8552                	mv	a0,s4
    80003c60:	a07ff0ef          	jal	80003666 <iput>
    return 0;
    80003c64:	4a01                	li	s4,0
    80003c66:	b705                	j	80003b86 <namex+0x5c>

0000000080003c68 <dirlink>:
{
    80003c68:	715d                	addi	sp,sp,-80
    80003c6a:	e486                	sd	ra,72(sp)
    80003c6c:	e0a2                	sd	s0,64(sp)
    80003c6e:	f84a                	sd	s2,48(sp)
    80003c70:	ec56                	sd	s5,24(sp)
    80003c72:	e85a                	sd	s6,16(sp)
    80003c74:	0880                	addi	s0,sp,80
    80003c76:	892a                	mv	s2,a0
    80003c78:	8aae                	mv	s5,a1
    80003c7a:	8b32                	mv	s6,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80003c7c:	4601                	li	a2,0
    80003c7e:	e01ff0ef          	jal	80003a7e <dirlookup>
    80003c82:	ed1d                	bnez	a0,80003cc0 <dirlink+0x58>
    80003c84:	fc26                	sd	s1,56(sp)
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003c86:	04c92483          	lw	s1,76(s2)
    80003c8a:	c4b9                	beqz	s1,80003cd8 <dirlink+0x70>
    80003c8c:	f44e                	sd	s3,40(sp)
    80003c8e:	f052                	sd	s4,32(sp)
    80003c90:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003c92:	fb040a13          	addi	s4,s0,-80
    80003c96:	49c1                	li	s3,16
    80003c98:	874e                	mv	a4,s3
    80003c9a:	86a6                	mv	a3,s1
    80003c9c:	8652                	mv	a2,s4
    80003c9e:	4581                	li	a1,0
    80003ca0:	854a                	mv	a0,s2
    80003ca2:	bd5ff0ef          	jal	80003876 <readi>
    80003ca6:	03351163          	bne	a0,s3,80003cc8 <dirlink+0x60>
    if(de.inum == 0)
    80003caa:	fb045783          	lhu	a5,-80(s0)
    80003cae:	c39d                	beqz	a5,80003cd4 <dirlink+0x6c>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003cb0:	24c1                	addiw	s1,s1,16
    80003cb2:	04c92783          	lw	a5,76(s2)
    80003cb6:	fef4e1e3          	bltu	s1,a5,80003c98 <dirlink+0x30>
    80003cba:	79a2                	ld	s3,40(sp)
    80003cbc:	7a02                	ld	s4,32(sp)
    80003cbe:	a829                	j	80003cd8 <dirlink+0x70>
    iput(ip);
    80003cc0:	9a7ff0ef          	jal	80003666 <iput>
    return -1;
    80003cc4:	557d                	li	a0,-1
    80003cc6:	a83d                	j	80003d04 <dirlink+0x9c>
      panic("dirlink read");
    80003cc8:	00005517          	auipc	a0,0x5
    80003ccc:	83850513          	addi	a0,a0,-1992 # 80008500 <etext+0x500>
    80003cd0:	b87fc0ef          	jal	80000856 <panic>
    80003cd4:	79a2                	ld	s3,40(sp)
    80003cd6:	7a02                	ld	s4,32(sp)
  strncpy(de.name, name, DIRSIZ);
    80003cd8:	4639                	li	a2,14
    80003cda:	85d6                	mv	a1,s5
    80003cdc:	fb240513          	addi	a0,s0,-78
    80003ce0:	958fd0ef          	jal	80000e38 <strncpy>
  de.inum = inum;
    80003ce4:	fb641823          	sh	s6,-80(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003ce8:	4741                	li	a4,16
    80003cea:	86a6                	mv	a3,s1
    80003cec:	fb040613          	addi	a2,s0,-80
    80003cf0:	4581                	li	a1,0
    80003cf2:	854a                	mv	a0,s2
    80003cf4:	c75ff0ef          	jal	80003968 <writei>
    80003cf8:	1541                	addi	a0,a0,-16
    80003cfa:	00a03533          	snez	a0,a0
    80003cfe:	40a0053b          	negw	a0,a0
    80003d02:	74e2                	ld	s1,56(sp)
}
    80003d04:	60a6                	ld	ra,72(sp)
    80003d06:	6406                	ld	s0,64(sp)
    80003d08:	7942                	ld	s2,48(sp)
    80003d0a:	6ae2                	ld	s5,24(sp)
    80003d0c:	6b42                	ld	s6,16(sp)
    80003d0e:	6161                	addi	sp,sp,80
    80003d10:	8082                	ret

0000000080003d12 <namei>:

struct inode*
namei(char *path)
{
    80003d12:	1101                	addi	sp,sp,-32
    80003d14:	ec06                	sd	ra,24(sp)
    80003d16:	e822                	sd	s0,16(sp)
    80003d18:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80003d1a:	fe040613          	addi	a2,s0,-32
    80003d1e:	4581                	li	a1,0
    80003d20:	e0bff0ef          	jal	80003b2a <namex>
}
    80003d24:	60e2                	ld	ra,24(sp)
    80003d26:	6442                	ld	s0,16(sp)
    80003d28:	6105                	addi	sp,sp,32
    80003d2a:	8082                	ret

0000000080003d2c <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    80003d2c:	1141                	addi	sp,sp,-16
    80003d2e:	e406                	sd	ra,8(sp)
    80003d30:	e022                	sd	s0,0(sp)
    80003d32:	0800                	addi	s0,sp,16
    80003d34:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80003d36:	4585                	li	a1,1
    80003d38:	df3ff0ef          	jal	80003b2a <namex>
}
    80003d3c:	60a2                	ld	ra,8(sp)
    80003d3e:	6402                	ld	s0,0(sp)
    80003d40:	0141                	addi	sp,sp,16
    80003d42:	8082                	ret

0000000080003d44 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80003d44:	1101                	addi	sp,sp,-32
    80003d46:	ec06                	sd	ra,24(sp)
    80003d48:	e822                	sd	s0,16(sp)
    80003d4a:	e426                	sd	s1,8(sp)
    80003d4c:	e04a                	sd	s2,0(sp)
    80003d4e:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80003d50:	00020917          	auipc	s2,0x20
    80003d54:	a5090913          	addi	s2,s2,-1456 # 800237a0 <log>
    80003d58:	01892583          	lw	a1,24(s2)
    80003d5c:	02492503          	lw	a0,36(s2)
    80003d60:	8aeff0ef          	jal	80002e0e <bread>
    80003d64:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    80003d66:	02892603          	lw	a2,40(s2)
    80003d6a:	cd30                	sw	a2,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80003d6c:	00c05f63          	blez	a2,80003d8a <write_head+0x46>
    80003d70:	00020717          	auipc	a4,0x20
    80003d74:	a5c70713          	addi	a4,a4,-1444 # 800237cc <log+0x2c>
    80003d78:	87aa                	mv	a5,a0
    80003d7a:	060a                	slli	a2,a2,0x2
    80003d7c:	962a                	add	a2,a2,a0
    hb->block[i] = log.lh.block[i];
    80003d7e:	4314                	lw	a3,0(a4)
    80003d80:	cff4                	sw	a3,92(a5)
  for (i = 0; i < log.lh.n; i++) {
    80003d82:	0711                	addi	a4,a4,4
    80003d84:	0791                	addi	a5,a5,4
    80003d86:	fec79ce3          	bne	a5,a2,80003d7e <write_head+0x3a>
  }
  bwrite(buf);
    80003d8a:	8526                	mv	a0,s1
    80003d8c:	980ff0ef          	jal	80002f0c <bwrite>
  brelse(buf);
    80003d90:	8526                	mv	a0,s1
    80003d92:	9acff0ef          	jal	80002f3e <brelse>
}
    80003d96:	60e2                	ld	ra,24(sp)
    80003d98:	6442                	ld	s0,16(sp)
    80003d9a:	64a2                	ld	s1,8(sp)
    80003d9c:	6902                	ld	s2,0(sp)
    80003d9e:	6105                	addi	sp,sp,32
    80003da0:	8082                	ret

0000000080003da2 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80003da2:	00020797          	auipc	a5,0x20
    80003da6:	a267a783          	lw	a5,-1498(a5) # 800237c8 <log+0x28>
    80003daa:	0cf05163          	blez	a5,80003e6c <install_trans+0xca>
{
    80003dae:	715d                	addi	sp,sp,-80
    80003db0:	e486                	sd	ra,72(sp)
    80003db2:	e0a2                	sd	s0,64(sp)
    80003db4:	fc26                	sd	s1,56(sp)
    80003db6:	f84a                	sd	s2,48(sp)
    80003db8:	f44e                	sd	s3,40(sp)
    80003dba:	f052                	sd	s4,32(sp)
    80003dbc:	ec56                	sd	s5,24(sp)
    80003dbe:	e85a                	sd	s6,16(sp)
    80003dc0:	e45e                	sd	s7,8(sp)
    80003dc2:	e062                	sd	s8,0(sp)
    80003dc4:	0880                	addi	s0,sp,80
    80003dc6:	8b2a                	mv	s6,a0
    80003dc8:	00020a97          	auipc	s5,0x20
    80003dcc:	a04a8a93          	addi	s5,s5,-1532 # 800237cc <log+0x2c>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003dd0:	4981                	li	s3,0
      printf("recovering tail %d dst %d\n", tail, log.lh.block[tail]);
    80003dd2:	00004c17          	auipc	s8,0x4
    80003dd6:	73ec0c13          	addi	s8,s8,1854 # 80008510 <etext+0x510>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80003dda:	00020a17          	auipc	s4,0x20
    80003dde:	9c6a0a13          	addi	s4,s4,-1594 # 800237a0 <log>
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80003de2:	40000b93          	li	s7,1024
    80003de6:	a025                	j	80003e0e <install_trans+0x6c>
      printf("recovering tail %d dst %d\n", tail, log.lh.block[tail]);
    80003de8:	000aa603          	lw	a2,0(s5)
    80003dec:	85ce                	mv	a1,s3
    80003dee:	8562                	mv	a0,s8
    80003df0:	f3cfc0ef          	jal	8000052c <printf>
    80003df4:	a839                	j	80003e12 <install_trans+0x70>
    brelse(lbuf);
    80003df6:	854a                	mv	a0,s2
    80003df8:	946ff0ef          	jal	80002f3e <brelse>
    brelse(dbuf);
    80003dfc:	8526                	mv	a0,s1
    80003dfe:	940ff0ef          	jal	80002f3e <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003e02:	2985                	addiw	s3,s3,1
    80003e04:	0a91                	addi	s5,s5,4
    80003e06:	028a2783          	lw	a5,40(s4)
    80003e0a:	04f9d563          	bge	s3,a5,80003e54 <install_trans+0xb2>
    if(recovering) {
    80003e0e:	fc0b1de3          	bnez	s6,80003de8 <install_trans+0x46>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80003e12:	018a2583          	lw	a1,24(s4)
    80003e16:	013585bb          	addw	a1,a1,s3
    80003e1a:	2585                	addiw	a1,a1,1
    80003e1c:	024a2503          	lw	a0,36(s4)
    80003e20:	feffe0ef          	jal	80002e0e <bread>
    80003e24:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    80003e26:	000aa583          	lw	a1,0(s5)
    80003e2a:	024a2503          	lw	a0,36(s4)
    80003e2e:	fe1fe0ef          	jal	80002e0e <bread>
    80003e32:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80003e34:	865e                	mv	a2,s7
    80003e36:	05890593          	addi	a1,s2,88
    80003e3a:	05850513          	addi	a0,a0,88
    80003e3e:	f4dfc0ef          	jal	80000d8a <memmove>
    bwrite(dbuf);  // write dst to disk
    80003e42:	8526                	mv	a0,s1
    80003e44:	8c8ff0ef          	jal	80002f0c <bwrite>
    if(recovering == 0)
    80003e48:	fa0b17e3          	bnez	s6,80003df6 <install_trans+0x54>
      bunpin(dbuf);
    80003e4c:	8526                	mv	a0,s1
    80003e4e:	9beff0ef          	jal	8000300c <bunpin>
    80003e52:	b755                	j	80003df6 <install_trans+0x54>
}
    80003e54:	60a6                	ld	ra,72(sp)
    80003e56:	6406                	ld	s0,64(sp)
    80003e58:	74e2                	ld	s1,56(sp)
    80003e5a:	7942                	ld	s2,48(sp)
    80003e5c:	79a2                	ld	s3,40(sp)
    80003e5e:	7a02                	ld	s4,32(sp)
    80003e60:	6ae2                	ld	s5,24(sp)
    80003e62:	6b42                	ld	s6,16(sp)
    80003e64:	6ba2                	ld	s7,8(sp)
    80003e66:	6c02                	ld	s8,0(sp)
    80003e68:	6161                	addi	sp,sp,80
    80003e6a:	8082                	ret
    80003e6c:	8082                	ret

0000000080003e6e <initlog>:
{
    80003e6e:	7179                	addi	sp,sp,-48
    80003e70:	f406                	sd	ra,40(sp)
    80003e72:	f022                	sd	s0,32(sp)
    80003e74:	ec26                	sd	s1,24(sp)
    80003e76:	e84a                	sd	s2,16(sp)
    80003e78:	e44e                	sd	s3,8(sp)
    80003e7a:	1800                	addi	s0,sp,48
    80003e7c:	84aa                	mv	s1,a0
    80003e7e:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    80003e80:	00020917          	auipc	s2,0x20
    80003e84:	92090913          	addi	s2,s2,-1760 # 800237a0 <log>
    80003e88:	00004597          	auipc	a1,0x4
    80003e8c:	6a858593          	addi	a1,a1,1704 # 80008530 <etext+0x530>
    80003e90:	854a                	mv	a0,s2
    80003e92:	d3ffc0ef          	jal	80000bd0 <initlock>
  log.start = sb->logstart;
    80003e96:	0149a583          	lw	a1,20(s3)
    80003e9a:	00b92c23          	sw	a1,24(s2)
  log.dev = dev;
    80003e9e:	02992223          	sw	s1,36(s2)
  struct buf *buf = bread(log.dev, log.start);
    80003ea2:	8526                	mv	a0,s1
    80003ea4:	f6bfe0ef          	jal	80002e0e <bread>
  log.lh.n = lh->n;
    80003ea8:	4d30                	lw	a2,88(a0)
    80003eaa:	02c92423          	sw	a2,40(s2)
  for (i = 0; i < log.lh.n; i++) {
    80003eae:	00c05f63          	blez	a2,80003ecc <initlog+0x5e>
    80003eb2:	87aa                	mv	a5,a0
    80003eb4:	00020717          	auipc	a4,0x20
    80003eb8:	91870713          	addi	a4,a4,-1768 # 800237cc <log+0x2c>
    80003ebc:	060a                	slli	a2,a2,0x2
    80003ebe:	962a                	add	a2,a2,a0
    log.lh.block[i] = lh->block[i];
    80003ec0:	4ff4                	lw	a3,92(a5)
    80003ec2:	c314                	sw	a3,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80003ec4:	0791                	addi	a5,a5,4
    80003ec6:	0711                	addi	a4,a4,4
    80003ec8:	fec79ce3          	bne	a5,a2,80003ec0 <initlog+0x52>
  brelse(buf);
    80003ecc:	872ff0ef          	jal	80002f3e <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    80003ed0:	4505                	li	a0,1
    80003ed2:	ed1ff0ef          	jal	80003da2 <install_trans>
  log.lh.n = 0;
    80003ed6:	00020797          	auipc	a5,0x20
    80003eda:	8e07a923          	sw	zero,-1806(a5) # 800237c8 <log+0x28>
  write_head(); // clear the log
    80003ede:	e67ff0ef          	jal	80003d44 <write_head>
}
    80003ee2:	70a2                	ld	ra,40(sp)
    80003ee4:	7402                	ld	s0,32(sp)
    80003ee6:	64e2                	ld	s1,24(sp)
    80003ee8:	6942                	ld	s2,16(sp)
    80003eea:	69a2                	ld	s3,8(sp)
    80003eec:	6145                	addi	sp,sp,48
    80003eee:	8082                	ret

0000000080003ef0 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    80003ef0:	1101                	addi	sp,sp,-32
    80003ef2:	ec06                	sd	ra,24(sp)
    80003ef4:	e822                	sd	s0,16(sp)
    80003ef6:	e426                	sd	s1,8(sp)
    80003ef8:	e04a                	sd	s2,0(sp)
    80003efa:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    80003efc:	00020517          	auipc	a0,0x20
    80003f00:	8a450513          	addi	a0,a0,-1884 # 800237a0 <log>
    80003f04:	d57fc0ef          	jal	80000c5a <acquire>
  while(1){
    if(log.committing){
    80003f08:	00020497          	auipc	s1,0x20
    80003f0c:	89848493          	addi	s1,s1,-1896 # 800237a0 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGBLOCKS){
    80003f10:	4979                	li	s2,30
    80003f12:	a029                	j	80003f1c <begin_op+0x2c>
      sleep(&log, &log.lock);
    80003f14:	85a6                	mv	a1,s1
    80003f16:	8526                	mv	a0,s1
    80003f18:	a24fe0ef          	jal	8000213c <sleep>
    if(log.committing){
    80003f1c:	509c                	lw	a5,32(s1)
    80003f1e:	fbfd                	bnez	a5,80003f14 <begin_op+0x24>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGBLOCKS){
    80003f20:	4cd8                	lw	a4,28(s1)
    80003f22:	2705                	addiw	a4,a4,1
    80003f24:	0027179b          	slliw	a5,a4,0x2
    80003f28:	9fb9                	addw	a5,a5,a4
    80003f2a:	0017979b          	slliw	a5,a5,0x1
    80003f2e:	5494                	lw	a3,40(s1)
    80003f30:	9fb5                	addw	a5,a5,a3
    80003f32:	00f95763          	bge	s2,a5,80003f40 <begin_op+0x50>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    80003f36:	85a6                	mv	a1,s1
    80003f38:	8526                	mv	a0,s1
    80003f3a:	a02fe0ef          	jal	8000213c <sleep>
    80003f3e:	bff9                	j	80003f1c <begin_op+0x2c>
    } else {
      log.outstanding += 1;
    80003f40:	00020797          	auipc	a5,0x20
    80003f44:	86e7ae23          	sw	a4,-1924(a5) # 800237bc <log+0x1c>
      release(&log.lock);
    80003f48:	00020517          	auipc	a0,0x20
    80003f4c:	85850513          	addi	a0,a0,-1960 # 800237a0 <log>
    80003f50:	d9ffc0ef          	jal	80000cee <release>
      break;
    }
  }
}
    80003f54:	60e2                	ld	ra,24(sp)
    80003f56:	6442                	ld	s0,16(sp)
    80003f58:	64a2                	ld	s1,8(sp)
    80003f5a:	6902                	ld	s2,0(sp)
    80003f5c:	6105                	addi	sp,sp,32
    80003f5e:	8082                	ret

0000000080003f60 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    80003f60:	7139                	addi	sp,sp,-64
    80003f62:	fc06                	sd	ra,56(sp)
    80003f64:	f822                	sd	s0,48(sp)
    80003f66:	f426                	sd	s1,40(sp)
    80003f68:	f04a                	sd	s2,32(sp)
    80003f6a:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    80003f6c:	00020497          	auipc	s1,0x20
    80003f70:	83448493          	addi	s1,s1,-1996 # 800237a0 <log>
    80003f74:	8526                	mv	a0,s1
    80003f76:	ce5fc0ef          	jal	80000c5a <acquire>
  log.outstanding -= 1;
    80003f7a:	4cdc                	lw	a5,28(s1)
    80003f7c:	37fd                	addiw	a5,a5,-1
    80003f7e:	893e                	mv	s2,a5
    80003f80:	ccdc                	sw	a5,28(s1)
  if(log.committing)
    80003f82:	509c                	lw	a5,32(s1)
    80003f84:	e7b1                	bnez	a5,80003fd0 <end_op+0x70>
    panic("log.committing");
  if(log.outstanding == 0){
    80003f86:	04091e63          	bnez	s2,80003fe2 <end_op+0x82>
    do_commit = 1;
    log.committing = 1;
    80003f8a:	00020497          	auipc	s1,0x20
    80003f8e:	81648493          	addi	s1,s1,-2026 # 800237a0 <log>
    80003f92:	4785                	li	a5,1
    80003f94:	d09c                	sw	a5,32(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    80003f96:	8526                	mv	a0,s1
    80003f98:	d57fc0ef          	jal	80000cee <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    80003f9c:	549c                	lw	a5,40(s1)
    80003f9e:	06f04463          	bgtz	a5,80004006 <end_op+0xa6>
    acquire(&log.lock);
    80003fa2:	0001f517          	auipc	a0,0x1f
    80003fa6:	7fe50513          	addi	a0,a0,2046 # 800237a0 <log>
    80003faa:	cb1fc0ef          	jal	80000c5a <acquire>
    log.committing = 0;
    80003fae:	00020797          	auipc	a5,0x20
    80003fb2:	8007a923          	sw	zero,-2030(a5) # 800237c0 <log+0x20>
    wakeup(&log);
    80003fb6:	0001f517          	auipc	a0,0x1f
    80003fba:	7ea50513          	addi	a0,a0,2026 # 800237a0 <log>
    80003fbe:	9cafe0ef          	jal	80002188 <wakeup>
    release(&log.lock);
    80003fc2:	0001f517          	auipc	a0,0x1f
    80003fc6:	7de50513          	addi	a0,a0,2014 # 800237a0 <log>
    80003fca:	d25fc0ef          	jal	80000cee <release>
}
    80003fce:	a035                	j	80003ffa <end_op+0x9a>
    80003fd0:	ec4e                	sd	s3,24(sp)
    80003fd2:	e852                	sd	s4,16(sp)
    80003fd4:	e456                	sd	s5,8(sp)
    panic("log.committing");
    80003fd6:	00004517          	auipc	a0,0x4
    80003fda:	56250513          	addi	a0,a0,1378 # 80008538 <etext+0x538>
    80003fde:	879fc0ef          	jal	80000856 <panic>
    wakeup(&log);
    80003fe2:	0001f517          	auipc	a0,0x1f
    80003fe6:	7be50513          	addi	a0,a0,1982 # 800237a0 <log>
    80003fea:	99efe0ef          	jal	80002188 <wakeup>
  release(&log.lock);
    80003fee:	0001f517          	auipc	a0,0x1f
    80003ff2:	7b250513          	addi	a0,a0,1970 # 800237a0 <log>
    80003ff6:	cf9fc0ef          	jal	80000cee <release>
}
    80003ffa:	70e2                	ld	ra,56(sp)
    80003ffc:	7442                	ld	s0,48(sp)
    80003ffe:	74a2                	ld	s1,40(sp)
    80004000:	7902                	ld	s2,32(sp)
    80004002:	6121                	addi	sp,sp,64
    80004004:	8082                	ret
    80004006:	ec4e                	sd	s3,24(sp)
    80004008:	e852                	sd	s4,16(sp)
    8000400a:	e456                	sd	s5,8(sp)
  for (tail = 0; tail < log.lh.n; tail++) {
    8000400c:	0001fa97          	auipc	s5,0x1f
    80004010:	7c0a8a93          	addi	s5,s5,1984 # 800237cc <log+0x2c>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    80004014:	0001fa17          	auipc	s4,0x1f
    80004018:	78ca0a13          	addi	s4,s4,1932 # 800237a0 <log>
    8000401c:	018a2583          	lw	a1,24(s4)
    80004020:	012585bb          	addw	a1,a1,s2
    80004024:	2585                	addiw	a1,a1,1
    80004026:	024a2503          	lw	a0,36(s4)
    8000402a:	de5fe0ef          	jal	80002e0e <bread>
    8000402e:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    80004030:	000aa583          	lw	a1,0(s5)
    80004034:	024a2503          	lw	a0,36(s4)
    80004038:	dd7fe0ef          	jal	80002e0e <bread>
    8000403c:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    8000403e:	40000613          	li	a2,1024
    80004042:	05850593          	addi	a1,a0,88
    80004046:	05848513          	addi	a0,s1,88
    8000404a:	d41fc0ef          	jal	80000d8a <memmove>
    bwrite(to);  // write the log
    8000404e:	8526                	mv	a0,s1
    80004050:	ebdfe0ef          	jal	80002f0c <bwrite>
    brelse(from);
    80004054:	854e                	mv	a0,s3
    80004056:	ee9fe0ef          	jal	80002f3e <brelse>
    brelse(to);
    8000405a:	8526                	mv	a0,s1
    8000405c:	ee3fe0ef          	jal	80002f3e <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004060:	2905                	addiw	s2,s2,1
    80004062:	0a91                	addi	s5,s5,4
    80004064:	028a2783          	lw	a5,40(s4)
    80004068:	faf94ae3          	blt	s2,a5,8000401c <end_op+0xbc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    8000406c:	cd9ff0ef          	jal	80003d44 <write_head>
    install_trans(0); // Now install writes to home locations
    80004070:	4501                	li	a0,0
    80004072:	d31ff0ef          	jal	80003da2 <install_trans>
    log.lh.n = 0;
    80004076:	0001f797          	auipc	a5,0x1f
    8000407a:	7407a923          	sw	zero,1874(a5) # 800237c8 <log+0x28>
    write_head();    // Erase the transaction from the log
    8000407e:	cc7ff0ef          	jal	80003d44 <write_head>
    80004082:	69e2                	ld	s3,24(sp)
    80004084:	6a42                	ld	s4,16(sp)
    80004086:	6aa2                	ld	s5,8(sp)
    80004088:	bf29                	j	80003fa2 <end_op+0x42>

000000008000408a <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    8000408a:	1101                	addi	sp,sp,-32
    8000408c:	ec06                	sd	ra,24(sp)
    8000408e:	e822                	sd	s0,16(sp)
    80004090:	e426                	sd	s1,8(sp)
    80004092:	1000                	addi	s0,sp,32
    80004094:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    80004096:	0001f517          	auipc	a0,0x1f
    8000409a:	70a50513          	addi	a0,a0,1802 # 800237a0 <log>
    8000409e:	bbdfc0ef          	jal	80000c5a <acquire>
  if (log.lh.n >= LOGBLOCKS)
    800040a2:	0001f617          	auipc	a2,0x1f
    800040a6:	72662603          	lw	a2,1830(a2) # 800237c8 <log+0x28>
    800040aa:	47f5                	li	a5,29
    800040ac:	04c7cd63          	blt	a5,a2,80004106 <log_write+0x7c>
    panic("too big a transaction");
  if (log.outstanding < 1)
    800040b0:	0001f797          	auipc	a5,0x1f
    800040b4:	70c7a783          	lw	a5,1804(a5) # 800237bc <log+0x1c>
    800040b8:	04f05d63          	blez	a5,80004112 <log_write+0x88>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    800040bc:	4781                	li	a5,0
    800040be:	06c05063          	blez	a2,8000411e <log_write+0x94>
    if (log.lh.block[i] == b->blockno)   // log absorption
    800040c2:	44cc                	lw	a1,12(s1)
    800040c4:	0001f717          	auipc	a4,0x1f
    800040c8:	70870713          	addi	a4,a4,1800 # 800237cc <log+0x2c>
  for (i = 0; i < log.lh.n; i++) {
    800040cc:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    800040ce:	4314                	lw	a3,0(a4)
    800040d0:	04b68763          	beq	a3,a1,8000411e <log_write+0x94>
  for (i = 0; i < log.lh.n; i++) {
    800040d4:	2785                	addiw	a5,a5,1
    800040d6:	0711                	addi	a4,a4,4
    800040d8:	fef61be3          	bne	a2,a5,800040ce <log_write+0x44>
      break;
  }
  log.lh.block[i] = b->blockno;
    800040dc:	060a                	slli	a2,a2,0x2
    800040de:	02060613          	addi	a2,a2,32
    800040e2:	0001f797          	auipc	a5,0x1f
    800040e6:	6be78793          	addi	a5,a5,1726 # 800237a0 <log>
    800040ea:	97b2                	add	a5,a5,a2
    800040ec:	44d8                	lw	a4,12(s1)
    800040ee:	c7d8                	sw	a4,12(a5)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    800040f0:	8526                	mv	a0,s1
    800040f2:	ee7fe0ef          	jal	80002fd8 <bpin>
    log.lh.n++;
    800040f6:	0001f717          	auipc	a4,0x1f
    800040fa:	6aa70713          	addi	a4,a4,1706 # 800237a0 <log>
    800040fe:	571c                	lw	a5,40(a4)
    80004100:	2785                	addiw	a5,a5,1
    80004102:	d71c                	sw	a5,40(a4)
    80004104:	a815                	j	80004138 <log_write+0xae>
    panic("too big a transaction");
    80004106:	00004517          	auipc	a0,0x4
    8000410a:	44250513          	addi	a0,a0,1090 # 80008548 <etext+0x548>
    8000410e:	f48fc0ef          	jal	80000856 <panic>
    panic("log_write outside of trans");
    80004112:	00004517          	auipc	a0,0x4
    80004116:	44e50513          	addi	a0,a0,1102 # 80008560 <etext+0x560>
    8000411a:	f3cfc0ef          	jal	80000856 <panic>
  log.lh.block[i] = b->blockno;
    8000411e:	00279693          	slli	a3,a5,0x2
    80004122:	02068693          	addi	a3,a3,32
    80004126:	0001f717          	auipc	a4,0x1f
    8000412a:	67a70713          	addi	a4,a4,1658 # 800237a0 <log>
    8000412e:	9736                	add	a4,a4,a3
    80004130:	44d4                	lw	a3,12(s1)
    80004132:	c754                	sw	a3,12(a4)
  if (i == log.lh.n) {  // Add new block to log?
    80004134:	faf60ee3          	beq	a2,a5,800040f0 <log_write+0x66>
  }
  release(&log.lock);
    80004138:	0001f517          	auipc	a0,0x1f
    8000413c:	66850513          	addi	a0,a0,1640 # 800237a0 <log>
    80004140:	baffc0ef          	jal	80000cee <release>
}
    80004144:	60e2                	ld	ra,24(sp)
    80004146:	6442                	ld	s0,16(sp)
    80004148:	64a2                	ld	s1,8(sp)
    8000414a:	6105                	addi	sp,sp,32
    8000414c:	8082                	ret

000000008000414e <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    8000414e:	1101                	addi	sp,sp,-32
    80004150:	ec06                	sd	ra,24(sp)
    80004152:	e822                	sd	s0,16(sp)
    80004154:	e426                	sd	s1,8(sp)
    80004156:	e04a                	sd	s2,0(sp)
    80004158:	1000                	addi	s0,sp,32
    8000415a:	84aa                	mv	s1,a0
    8000415c:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    8000415e:	00004597          	auipc	a1,0x4
    80004162:	42258593          	addi	a1,a1,1058 # 80008580 <etext+0x580>
    80004166:	0521                	addi	a0,a0,8
    80004168:	a69fc0ef          	jal	80000bd0 <initlock>
  lk->name = name;
    8000416c:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    80004170:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004174:	0204a423          	sw	zero,40(s1)
}
    80004178:	60e2                	ld	ra,24(sp)
    8000417a:	6442                	ld	s0,16(sp)
    8000417c:	64a2                	ld	s1,8(sp)
    8000417e:	6902                	ld	s2,0(sp)
    80004180:	6105                	addi	sp,sp,32
    80004182:	8082                	ret

0000000080004184 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    80004184:	1101                	addi	sp,sp,-32
    80004186:	ec06                	sd	ra,24(sp)
    80004188:	e822                	sd	s0,16(sp)
    8000418a:	e426                	sd	s1,8(sp)
    8000418c:	e04a                	sd	s2,0(sp)
    8000418e:	1000                	addi	s0,sp,32
    80004190:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004192:	00850913          	addi	s2,a0,8
    80004196:	854a                	mv	a0,s2
    80004198:	ac3fc0ef          	jal	80000c5a <acquire>
  while (lk->locked) {
    8000419c:	409c                	lw	a5,0(s1)
    8000419e:	c799                	beqz	a5,800041ac <acquiresleep+0x28>
    sleep(lk, &lk->lk);
    800041a0:	85ca                	mv	a1,s2
    800041a2:	8526                	mv	a0,s1
    800041a4:	f99fd0ef          	jal	8000213c <sleep>
  while (lk->locked) {
    800041a8:	409c                	lw	a5,0(s1)
    800041aa:	fbfd                	bnez	a5,800041a0 <acquiresleep+0x1c>
  }
  lk->locked = 1;
    800041ac:	4785                	li	a5,1
    800041ae:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    800041b0:	fccfd0ef          	jal	8000197c <myproc>
    800041b4:	591c                	lw	a5,48(a0)
    800041b6:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    800041b8:	854a                	mv	a0,s2
    800041ba:	b35fc0ef          	jal	80000cee <release>
}
    800041be:	60e2                	ld	ra,24(sp)
    800041c0:	6442                	ld	s0,16(sp)
    800041c2:	64a2                	ld	s1,8(sp)
    800041c4:	6902                	ld	s2,0(sp)
    800041c6:	6105                	addi	sp,sp,32
    800041c8:	8082                	ret

00000000800041ca <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    800041ca:	1101                	addi	sp,sp,-32
    800041cc:	ec06                	sd	ra,24(sp)
    800041ce:	e822                	sd	s0,16(sp)
    800041d0:	e426                	sd	s1,8(sp)
    800041d2:	e04a                	sd	s2,0(sp)
    800041d4:	1000                	addi	s0,sp,32
    800041d6:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    800041d8:	00850913          	addi	s2,a0,8
    800041dc:	854a                	mv	a0,s2
    800041de:	a7dfc0ef          	jal	80000c5a <acquire>
  lk->locked = 0;
    800041e2:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    800041e6:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    800041ea:	8526                	mv	a0,s1
    800041ec:	f9dfd0ef          	jal	80002188 <wakeup>
  release(&lk->lk);
    800041f0:	854a                	mv	a0,s2
    800041f2:	afdfc0ef          	jal	80000cee <release>
}
    800041f6:	60e2                	ld	ra,24(sp)
    800041f8:	6442                	ld	s0,16(sp)
    800041fa:	64a2                	ld	s1,8(sp)
    800041fc:	6902                	ld	s2,0(sp)
    800041fe:	6105                	addi	sp,sp,32
    80004200:	8082                	ret

0000000080004202 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    80004202:	7179                	addi	sp,sp,-48
    80004204:	f406                	sd	ra,40(sp)
    80004206:	f022                	sd	s0,32(sp)
    80004208:	ec26                	sd	s1,24(sp)
    8000420a:	e84a                	sd	s2,16(sp)
    8000420c:	1800                	addi	s0,sp,48
    8000420e:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    80004210:	00850913          	addi	s2,a0,8
    80004214:	854a                	mv	a0,s2
    80004216:	a45fc0ef          	jal	80000c5a <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    8000421a:	409c                	lw	a5,0(s1)
    8000421c:	ef81                	bnez	a5,80004234 <holdingsleep+0x32>
    8000421e:	4481                	li	s1,0
  release(&lk->lk);
    80004220:	854a                	mv	a0,s2
    80004222:	acdfc0ef          	jal	80000cee <release>
  return r;
}
    80004226:	8526                	mv	a0,s1
    80004228:	70a2                	ld	ra,40(sp)
    8000422a:	7402                	ld	s0,32(sp)
    8000422c:	64e2                	ld	s1,24(sp)
    8000422e:	6942                	ld	s2,16(sp)
    80004230:	6145                	addi	sp,sp,48
    80004232:	8082                	ret
    80004234:	e44e                	sd	s3,8(sp)
  r = lk->locked && (lk->pid == myproc()->pid);
    80004236:	0284a983          	lw	s3,40(s1)
    8000423a:	f42fd0ef          	jal	8000197c <myproc>
    8000423e:	5904                	lw	s1,48(a0)
    80004240:	413484b3          	sub	s1,s1,s3
    80004244:	0014b493          	seqz	s1,s1
    80004248:	69a2                	ld	s3,8(sp)
    8000424a:	bfd9                	j	80004220 <holdingsleep+0x1e>

000000008000424c <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    8000424c:	1141                	addi	sp,sp,-16
    8000424e:	e406                	sd	ra,8(sp)
    80004250:	e022                	sd	s0,0(sp)
    80004252:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    80004254:	00004597          	auipc	a1,0x4
    80004258:	33c58593          	addi	a1,a1,828 # 80008590 <etext+0x590>
    8000425c:	0001f517          	auipc	a0,0x1f
    80004260:	68c50513          	addi	a0,a0,1676 # 800238e8 <ftable>
    80004264:	96dfc0ef          	jal	80000bd0 <initlock>
}
    80004268:	60a2                	ld	ra,8(sp)
    8000426a:	6402                	ld	s0,0(sp)
    8000426c:	0141                	addi	sp,sp,16
    8000426e:	8082                	ret

0000000080004270 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    80004270:	1101                	addi	sp,sp,-32
    80004272:	ec06                	sd	ra,24(sp)
    80004274:	e822                	sd	s0,16(sp)
    80004276:	e426                	sd	s1,8(sp)
    80004278:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    8000427a:	0001f517          	auipc	a0,0x1f
    8000427e:	66e50513          	addi	a0,a0,1646 # 800238e8 <ftable>
    80004282:	9d9fc0ef          	jal	80000c5a <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004286:	0001f497          	auipc	s1,0x1f
    8000428a:	67a48493          	addi	s1,s1,1658 # 80023900 <ftable+0x18>
    8000428e:	00020717          	auipc	a4,0x20
    80004292:	61270713          	addi	a4,a4,1554 # 800248a0 <disk>
    if(f->ref == 0){
    80004296:	40dc                	lw	a5,4(s1)
    80004298:	cf89                	beqz	a5,800042b2 <filealloc+0x42>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    8000429a:	02848493          	addi	s1,s1,40
    8000429e:	fee49ce3          	bne	s1,a4,80004296 <filealloc+0x26>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    800042a2:	0001f517          	auipc	a0,0x1f
    800042a6:	64650513          	addi	a0,a0,1606 # 800238e8 <ftable>
    800042aa:	a45fc0ef          	jal	80000cee <release>
  return 0;
    800042ae:	4481                	li	s1,0
    800042b0:	a809                	j	800042c2 <filealloc+0x52>
      f->ref = 1;
    800042b2:	4785                	li	a5,1
    800042b4:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    800042b6:	0001f517          	auipc	a0,0x1f
    800042ba:	63250513          	addi	a0,a0,1586 # 800238e8 <ftable>
    800042be:	a31fc0ef          	jal	80000cee <release>
}
    800042c2:	8526                	mv	a0,s1
    800042c4:	60e2                	ld	ra,24(sp)
    800042c6:	6442                	ld	s0,16(sp)
    800042c8:	64a2                	ld	s1,8(sp)
    800042ca:	6105                	addi	sp,sp,32
    800042cc:	8082                	ret

00000000800042ce <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    800042ce:	1101                	addi	sp,sp,-32
    800042d0:	ec06                	sd	ra,24(sp)
    800042d2:	e822                	sd	s0,16(sp)
    800042d4:	e426                	sd	s1,8(sp)
    800042d6:	1000                	addi	s0,sp,32
    800042d8:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    800042da:	0001f517          	auipc	a0,0x1f
    800042de:	60e50513          	addi	a0,a0,1550 # 800238e8 <ftable>
    800042e2:	979fc0ef          	jal	80000c5a <acquire>
  if(f->ref < 1)
    800042e6:	40dc                	lw	a5,4(s1)
    800042e8:	02f05063          	blez	a5,80004308 <filedup+0x3a>
    panic("filedup");
  f->ref++;
    800042ec:	2785                	addiw	a5,a5,1
    800042ee:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    800042f0:	0001f517          	auipc	a0,0x1f
    800042f4:	5f850513          	addi	a0,a0,1528 # 800238e8 <ftable>
    800042f8:	9f7fc0ef          	jal	80000cee <release>
  return f;
}
    800042fc:	8526                	mv	a0,s1
    800042fe:	60e2                	ld	ra,24(sp)
    80004300:	6442                	ld	s0,16(sp)
    80004302:	64a2                	ld	s1,8(sp)
    80004304:	6105                	addi	sp,sp,32
    80004306:	8082                	ret
    panic("filedup");
    80004308:	00004517          	auipc	a0,0x4
    8000430c:	29050513          	addi	a0,a0,656 # 80008598 <etext+0x598>
    80004310:	d46fc0ef          	jal	80000856 <panic>

0000000080004314 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    80004314:	7139                	addi	sp,sp,-64
    80004316:	fc06                	sd	ra,56(sp)
    80004318:	f822                	sd	s0,48(sp)
    8000431a:	f426                	sd	s1,40(sp)
    8000431c:	0080                	addi	s0,sp,64
    8000431e:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    80004320:	0001f517          	auipc	a0,0x1f
    80004324:	5c850513          	addi	a0,a0,1480 # 800238e8 <ftable>
    80004328:	933fc0ef          	jal	80000c5a <acquire>
  if(f->ref < 1)
    8000432c:	40dc                	lw	a5,4(s1)
    8000432e:	04f05a63          	blez	a5,80004382 <fileclose+0x6e>
    panic("fileclose");
  if(--f->ref > 0){
    80004332:	37fd                	addiw	a5,a5,-1
    80004334:	c0dc                	sw	a5,4(s1)
    80004336:	06f04063          	bgtz	a5,80004396 <fileclose+0x82>
    8000433a:	f04a                	sd	s2,32(sp)
    8000433c:	ec4e                	sd	s3,24(sp)
    8000433e:	e852                	sd	s4,16(sp)
    80004340:	e456                	sd	s5,8(sp)
    release(&ftable.lock);
    return;
  }
  ff = *f;
    80004342:	0004a903          	lw	s2,0(s1)
    80004346:	0094c783          	lbu	a5,9(s1)
    8000434a:	89be                	mv	s3,a5
    8000434c:	689c                	ld	a5,16(s1)
    8000434e:	8a3e                	mv	s4,a5
    80004350:	6c9c                	ld	a5,24(s1)
    80004352:	8abe                	mv	s5,a5
  f->ref = 0;
    80004354:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    80004358:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    8000435c:	0001f517          	auipc	a0,0x1f
    80004360:	58c50513          	addi	a0,a0,1420 # 800238e8 <ftable>
    80004364:	98bfc0ef          	jal	80000cee <release>

  if(ff.type == FD_PIPE){
    80004368:	4785                	li	a5,1
    8000436a:	04f90163          	beq	s2,a5,800043ac <fileclose+0x98>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    8000436e:	ffe9079b          	addiw	a5,s2,-2
    80004372:	4705                	li	a4,1
    80004374:	04f77563          	bgeu	a4,a5,800043be <fileclose+0xaa>
    80004378:	7902                	ld	s2,32(sp)
    8000437a:	69e2                	ld	s3,24(sp)
    8000437c:	6a42                	ld	s4,16(sp)
    8000437e:	6aa2                	ld	s5,8(sp)
    80004380:	a00d                	j	800043a2 <fileclose+0x8e>
    80004382:	f04a                	sd	s2,32(sp)
    80004384:	ec4e                	sd	s3,24(sp)
    80004386:	e852                	sd	s4,16(sp)
    80004388:	e456                	sd	s5,8(sp)
    panic("fileclose");
    8000438a:	00004517          	auipc	a0,0x4
    8000438e:	21650513          	addi	a0,a0,534 # 800085a0 <etext+0x5a0>
    80004392:	cc4fc0ef          	jal	80000856 <panic>
    release(&ftable.lock);
    80004396:	0001f517          	auipc	a0,0x1f
    8000439a:	55250513          	addi	a0,a0,1362 # 800238e8 <ftable>
    8000439e:	951fc0ef          	jal	80000cee <release>
    begin_op();
    iput(ff.ip);
    end_op();
  }
}
    800043a2:	70e2                	ld	ra,56(sp)
    800043a4:	7442                	ld	s0,48(sp)
    800043a6:	74a2                	ld	s1,40(sp)
    800043a8:	6121                	addi	sp,sp,64
    800043aa:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    800043ac:	85ce                	mv	a1,s3
    800043ae:	8552                	mv	a0,s4
    800043b0:	348000ef          	jal	800046f8 <pipeclose>
    800043b4:	7902                	ld	s2,32(sp)
    800043b6:	69e2                	ld	s3,24(sp)
    800043b8:	6a42                	ld	s4,16(sp)
    800043ba:	6aa2                	ld	s5,8(sp)
    800043bc:	b7dd                	j	800043a2 <fileclose+0x8e>
    begin_op();
    800043be:	b33ff0ef          	jal	80003ef0 <begin_op>
    iput(ff.ip);
    800043c2:	8556                	mv	a0,s5
    800043c4:	aa2ff0ef          	jal	80003666 <iput>
    end_op();
    800043c8:	b99ff0ef          	jal	80003f60 <end_op>
    800043cc:	7902                	ld	s2,32(sp)
    800043ce:	69e2                	ld	s3,24(sp)
    800043d0:	6a42                	ld	s4,16(sp)
    800043d2:	6aa2                	ld	s5,8(sp)
    800043d4:	b7f9                	j	800043a2 <fileclose+0x8e>

00000000800043d6 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    800043d6:	715d                	addi	sp,sp,-80
    800043d8:	e486                	sd	ra,72(sp)
    800043da:	e0a2                	sd	s0,64(sp)
    800043dc:	fc26                	sd	s1,56(sp)
    800043de:	f052                	sd	s4,32(sp)
    800043e0:	0880                	addi	s0,sp,80
    800043e2:	84aa                	mv	s1,a0
    800043e4:	8a2e                	mv	s4,a1
  struct proc *p = myproc();
    800043e6:	d96fd0ef          	jal	8000197c <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    800043ea:	409c                	lw	a5,0(s1)
    800043ec:	37f9                	addiw	a5,a5,-2
    800043ee:	4705                	li	a4,1
    800043f0:	04f76263          	bltu	a4,a5,80004434 <filestat+0x5e>
    800043f4:	f84a                	sd	s2,48(sp)
    800043f6:	f44e                	sd	s3,40(sp)
    800043f8:	89aa                	mv	s3,a0
    ilock(f->ip);
    800043fa:	6c88                	ld	a0,24(s1)
    800043fc:	8e8ff0ef          	jal	800034e4 <ilock>
    stati(f->ip, &st);
    80004400:	fb840913          	addi	s2,s0,-72
    80004404:	85ca                	mv	a1,s2
    80004406:	6c88                	ld	a0,24(s1)
    80004408:	c40ff0ef          	jal	80003848 <stati>
    iunlock(f->ip);
    8000440c:	6c88                	ld	a0,24(s1)
    8000440e:	984ff0ef          	jal	80003592 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    80004412:	46e1                	li	a3,24
    80004414:	864a                	mv	a2,s2
    80004416:	85d2                	mv	a1,s4
    80004418:	0509b503          	ld	a0,80(s3)
    8000441c:	a72fd0ef          	jal	8000168e <copyout>
    80004420:	41f5551b          	sraiw	a0,a0,0x1f
    80004424:	7942                	ld	s2,48(sp)
    80004426:	79a2                	ld	s3,40(sp)
      return -1;
    return 0;
  }
  return -1;
}
    80004428:	60a6                	ld	ra,72(sp)
    8000442a:	6406                	ld	s0,64(sp)
    8000442c:	74e2                	ld	s1,56(sp)
    8000442e:	7a02                	ld	s4,32(sp)
    80004430:	6161                	addi	sp,sp,80
    80004432:	8082                	ret
  return -1;
    80004434:	557d                	li	a0,-1
    80004436:	bfcd                	j	80004428 <filestat+0x52>

0000000080004438 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    80004438:	7179                	addi	sp,sp,-48
    8000443a:	f406                	sd	ra,40(sp)
    8000443c:	f022                	sd	s0,32(sp)
    8000443e:	e84a                	sd	s2,16(sp)
    80004440:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    80004442:	00854783          	lbu	a5,8(a0)
    80004446:	cfd1                	beqz	a5,800044e2 <fileread+0xaa>
    80004448:	ec26                	sd	s1,24(sp)
    8000444a:	e44e                	sd	s3,8(sp)
    8000444c:	84aa                	mv	s1,a0
    8000444e:	892e                	mv	s2,a1
    80004450:	89b2                	mv	s3,a2
    return -1;

  if(f->type == FD_PIPE){
    80004452:	411c                	lw	a5,0(a0)
    80004454:	4705                	li	a4,1
    80004456:	04e78363          	beq	a5,a4,8000449c <fileread+0x64>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    8000445a:	470d                	li	a4,3
    8000445c:	04e78763          	beq	a5,a4,800044aa <fileread+0x72>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    80004460:	4709                	li	a4,2
    80004462:	06e79a63          	bne	a5,a4,800044d6 <fileread+0x9e>
    ilock(f->ip);
    80004466:	6d08                	ld	a0,24(a0)
    80004468:	87cff0ef          	jal	800034e4 <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    8000446c:	874e                	mv	a4,s3
    8000446e:	5094                	lw	a3,32(s1)
    80004470:	864a                	mv	a2,s2
    80004472:	4585                	li	a1,1
    80004474:	6c88                	ld	a0,24(s1)
    80004476:	c00ff0ef          	jal	80003876 <readi>
    8000447a:	892a                	mv	s2,a0
    8000447c:	00a05563          	blez	a0,80004486 <fileread+0x4e>
      f->off += r;
    80004480:	509c                	lw	a5,32(s1)
    80004482:	9fa9                	addw	a5,a5,a0
    80004484:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80004486:	6c88                	ld	a0,24(s1)
    80004488:	90aff0ef          	jal	80003592 <iunlock>
    8000448c:	64e2                	ld	s1,24(sp)
    8000448e:	69a2                	ld	s3,8(sp)
  } else {
    panic("fileread");
  }

  return r;
}
    80004490:	854a                	mv	a0,s2
    80004492:	70a2                	ld	ra,40(sp)
    80004494:	7402                	ld	s0,32(sp)
    80004496:	6942                	ld	s2,16(sp)
    80004498:	6145                	addi	sp,sp,48
    8000449a:	8082                	ret
    r = piperead(f->pipe, addr, n);
    8000449c:	6908                	ld	a0,16(a0)
    8000449e:	3b0000ef          	jal	8000484e <piperead>
    800044a2:	892a                	mv	s2,a0
    800044a4:	64e2                	ld	s1,24(sp)
    800044a6:	69a2                	ld	s3,8(sp)
    800044a8:	b7e5                	j	80004490 <fileread+0x58>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    800044aa:	02451783          	lh	a5,36(a0)
    800044ae:	03079693          	slli	a3,a5,0x30
    800044b2:	92c1                	srli	a3,a3,0x30
    800044b4:	4725                	li	a4,9
    800044b6:	02d76963          	bltu	a4,a3,800044e8 <fileread+0xb0>
    800044ba:	0792                	slli	a5,a5,0x4
    800044bc:	0001f717          	auipc	a4,0x1f
    800044c0:	38c70713          	addi	a4,a4,908 # 80023848 <devsw>
    800044c4:	97ba                	add	a5,a5,a4
    800044c6:	639c                	ld	a5,0(a5)
    800044c8:	c78d                	beqz	a5,800044f2 <fileread+0xba>
    r = devsw[f->major].read(1, addr, n);
    800044ca:	4505                	li	a0,1
    800044cc:	9782                	jalr	a5
    800044ce:	892a                	mv	s2,a0
    800044d0:	64e2                	ld	s1,24(sp)
    800044d2:	69a2                	ld	s3,8(sp)
    800044d4:	bf75                	j	80004490 <fileread+0x58>
    panic("fileread");
    800044d6:	00004517          	auipc	a0,0x4
    800044da:	0da50513          	addi	a0,a0,218 # 800085b0 <etext+0x5b0>
    800044de:	b78fc0ef          	jal	80000856 <panic>
    return -1;
    800044e2:	57fd                	li	a5,-1
    800044e4:	893e                	mv	s2,a5
    800044e6:	b76d                	j	80004490 <fileread+0x58>
      return -1;
    800044e8:	57fd                	li	a5,-1
    800044ea:	893e                	mv	s2,a5
    800044ec:	64e2                	ld	s1,24(sp)
    800044ee:	69a2                	ld	s3,8(sp)
    800044f0:	b745                	j	80004490 <fileread+0x58>
    800044f2:	57fd                	li	a5,-1
    800044f4:	893e                	mv	s2,a5
    800044f6:	64e2                	ld	s1,24(sp)
    800044f8:	69a2                	ld	s3,8(sp)
    800044fa:	bf59                	j	80004490 <fileread+0x58>

00000000800044fc <filewrite>:
int
filewrite(struct file *f, uint64 addr, int n)
{
  int r, ret = 0;

  if(f->writable == 0)
    800044fc:	00954783          	lbu	a5,9(a0)
    80004500:	10078f63          	beqz	a5,8000461e <filewrite+0x122>
{
    80004504:	711d                	addi	sp,sp,-96
    80004506:	ec86                	sd	ra,88(sp)
    80004508:	e8a2                	sd	s0,80(sp)
    8000450a:	e0ca                	sd	s2,64(sp)
    8000450c:	f456                	sd	s5,40(sp)
    8000450e:	f05a                	sd	s6,32(sp)
    80004510:	1080                	addi	s0,sp,96
    80004512:	892a                	mv	s2,a0
    80004514:	8b2e                	mv	s6,a1
    80004516:	8ab2                	mv	s5,a2
    return -1;

  if(f->type == FD_PIPE){
    80004518:	411c                	lw	a5,0(a0)
    8000451a:	4705                	li	a4,1
    8000451c:	02e78a63          	beq	a5,a4,80004550 <filewrite+0x54>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004520:	470d                	li	a4,3
    80004522:	02e78b63          	beq	a5,a4,80004558 <filewrite+0x5c>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    80004526:	4709                	li	a4,2
    80004528:	0ce79f63          	bne	a5,a4,80004606 <filewrite+0x10a>
    8000452c:	f852                	sd	s4,48(sp)
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    8000452e:	0ac05a63          	blez	a2,800045e2 <filewrite+0xe6>
    80004532:	e4a6                	sd	s1,72(sp)
    80004534:	fc4e                	sd	s3,56(sp)
    80004536:	ec5e                	sd	s7,24(sp)
    80004538:	e862                	sd	s8,16(sp)
    8000453a:	e466                	sd	s9,8(sp)
    int i = 0;
    8000453c:	4a01                	li	s4,0
      int n1 = n - i;
      if(n1 > max)
    8000453e:	6b85                	lui	s7,0x1
    80004540:	c00b8b93          	addi	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    80004544:	6785                	lui	a5,0x1
    80004546:	c007879b          	addiw	a5,a5,-1024 # c00 <_entry-0x7ffff400>
    8000454a:	8cbe                	mv	s9,a5
        n1 = max;

      begin_op();
      ilock(f->ip);
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    8000454c:	4c05                	li	s8,1
    8000454e:	a8ad                	j	800045c8 <filewrite+0xcc>
    ret = pipewrite(f->pipe, addr, n);
    80004550:	6908                	ld	a0,16(a0)
    80004552:	204000ef          	jal	80004756 <pipewrite>
    80004556:	a04d                	j	800045f8 <filewrite+0xfc>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80004558:	02451783          	lh	a5,36(a0)
    8000455c:	03079693          	slli	a3,a5,0x30
    80004560:	92c1                	srli	a3,a3,0x30
    80004562:	4725                	li	a4,9
    80004564:	0ad76f63          	bltu	a4,a3,80004622 <filewrite+0x126>
    80004568:	0792                	slli	a5,a5,0x4
    8000456a:	0001f717          	auipc	a4,0x1f
    8000456e:	2de70713          	addi	a4,a4,734 # 80023848 <devsw>
    80004572:	97ba                	add	a5,a5,a4
    80004574:	679c                	ld	a5,8(a5)
    80004576:	cbc5                	beqz	a5,80004626 <filewrite+0x12a>
    ret = devsw[f->major].write(1, addr, n);
    80004578:	4505                	li	a0,1
    8000457a:	9782                	jalr	a5
    8000457c:	a8b5                	j	800045f8 <filewrite+0xfc>
      if(n1 > max)
    8000457e:	2981                	sext.w	s3,s3
      begin_op();
    80004580:	971ff0ef          	jal	80003ef0 <begin_op>
      ilock(f->ip);
    80004584:	01893503          	ld	a0,24(s2)
    80004588:	f5dfe0ef          	jal	800034e4 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    8000458c:	874e                	mv	a4,s3
    8000458e:	02092683          	lw	a3,32(s2)
    80004592:	016a0633          	add	a2,s4,s6
    80004596:	85e2                	mv	a1,s8
    80004598:	01893503          	ld	a0,24(s2)
    8000459c:	bccff0ef          	jal	80003968 <writei>
    800045a0:	84aa                	mv	s1,a0
    800045a2:	00a05763          	blez	a0,800045b0 <filewrite+0xb4>
        f->off += r;
    800045a6:	02092783          	lw	a5,32(s2)
    800045aa:	9fa9                	addw	a5,a5,a0
    800045ac:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    800045b0:	01893503          	ld	a0,24(s2)
    800045b4:	fdffe0ef          	jal	80003592 <iunlock>
      end_op();
    800045b8:	9a9ff0ef          	jal	80003f60 <end_op>

      if(r != n1){
    800045bc:	02999563          	bne	s3,s1,800045e6 <filewrite+0xea>
        // error from writei
        break;
      }
      i += r;
    800045c0:	01448a3b          	addw	s4,s1,s4
    while(i < n){
    800045c4:	015a5963          	bge	s4,s5,800045d6 <filewrite+0xda>
      int n1 = n - i;
    800045c8:	414a87bb          	subw	a5,s5,s4
    800045cc:	89be                	mv	s3,a5
      if(n1 > max)
    800045ce:	fafbd8e3          	bge	s7,a5,8000457e <filewrite+0x82>
    800045d2:	89e6                	mv	s3,s9
    800045d4:	b76d                	j	8000457e <filewrite+0x82>
    800045d6:	64a6                	ld	s1,72(sp)
    800045d8:	79e2                	ld	s3,56(sp)
    800045da:	6be2                	ld	s7,24(sp)
    800045dc:	6c42                	ld	s8,16(sp)
    800045de:	6ca2                	ld	s9,8(sp)
    800045e0:	a801                	j	800045f0 <filewrite+0xf4>
    int i = 0;
    800045e2:	4a01                	li	s4,0
    800045e4:	a031                	j	800045f0 <filewrite+0xf4>
    800045e6:	64a6                	ld	s1,72(sp)
    800045e8:	79e2                	ld	s3,56(sp)
    800045ea:	6be2                	ld	s7,24(sp)
    800045ec:	6c42                	ld	s8,16(sp)
    800045ee:	6ca2                	ld	s9,8(sp)
    }
    ret = (i == n ? n : -1);
    800045f0:	034a9d63          	bne	s5,s4,8000462a <filewrite+0x12e>
    800045f4:	8556                	mv	a0,s5
    800045f6:	7a42                	ld	s4,48(sp)
  } else {
    panic("filewrite");
  }

  return ret;
}
    800045f8:	60e6                	ld	ra,88(sp)
    800045fa:	6446                	ld	s0,80(sp)
    800045fc:	6906                	ld	s2,64(sp)
    800045fe:	7aa2                	ld	s5,40(sp)
    80004600:	7b02                	ld	s6,32(sp)
    80004602:	6125                	addi	sp,sp,96
    80004604:	8082                	ret
    80004606:	e4a6                	sd	s1,72(sp)
    80004608:	fc4e                	sd	s3,56(sp)
    8000460a:	f852                	sd	s4,48(sp)
    8000460c:	ec5e                	sd	s7,24(sp)
    8000460e:	e862                	sd	s8,16(sp)
    80004610:	e466                	sd	s9,8(sp)
    panic("filewrite");
    80004612:	00004517          	auipc	a0,0x4
    80004616:	fae50513          	addi	a0,a0,-82 # 800085c0 <etext+0x5c0>
    8000461a:	a3cfc0ef          	jal	80000856 <panic>
    return -1;
    8000461e:	557d                	li	a0,-1
}
    80004620:	8082                	ret
      return -1;
    80004622:	557d                	li	a0,-1
    80004624:	bfd1                	j	800045f8 <filewrite+0xfc>
    80004626:	557d                	li	a0,-1
    80004628:	bfc1                	j	800045f8 <filewrite+0xfc>
    ret = (i == n ? n : -1);
    8000462a:	557d                	li	a0,-1
    8000462c:	7a42                	ld	s4,48(sp)
    8000462e:	b7e9                	j	800045f8 <filewrite+0xfc>

0000000080004630 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80004630:	7179                	addi	sp,sp,-48
    80004632:	f406                	sd	ra,40(sp)
    80004634:	f022                	sd	s0,32(sp)
    80004636:	ec26                	sd	s1,24(sp)
    80004638:	e052                	sd	s4,0(sp)
    8000463a:	1800                	addi	s0,sp,48
    8000463c:	84aa                	mv	s1,a0
    8000463e:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80004640:	0005b023          	sd	zero,0(a1)
    80004644:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80004648:	c29ff0ef          	jal	80004270 <filealloc>
    8000464c:	e088                	sd	a0,0(s1)
    8000464e:	c549                	beqz	a0,800046d8 <pipealloc+0xa8>
    80004650:	c21ff0ef          	jal	80004270 <filealloc>
    80004654:	00aa3023          	sd	a0,0(s4)
    80004658:	cd25                	beqz	a0,800046d0 <pipealloc+0xa0>
    8000465a:	e84a                	sd	s2,16(sp)
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    8000465c:	d1afc0ef          	jal	80000b76 <kalloc>
    80004660:	892a                	mv	s2,a0
    80004662:	c12d                	beqz	a0,800046c4 <pipealloc+0x94>
    80004664:	e44e                	sd	s3,8(sp)
    goto bad;
  pi->readopen = 1;
    80004666:	4985                	li	s3,1
    80004668:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    8000466c:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    80004670:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80004674:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80004678:	00004597          	auipc	a1,0x4
    8000467c:	f5858593          	addi	a1,a1,-168 # 800085d0 <etext+0x5d0>
    80004680:	d50fc0ef          	jal	80000bd0 <initlock>
  (*f0)->type = FD_PIPE;
    80004684:	609c                	ld	a5,0(s1)
    80004686:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    8000468a:	609c                	ld	a5,0(s1)
    8000468c:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80004690:	609c                	ld	a5,0(s1)
    80004692:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80004696:	609c                	ld	a5,0(s1)
    80004698:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    8000469c:	000a3783          	ld	a5,0(s4)
    800046a0:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    800046a4:	000a3783          	ld	a5,0(s4)
    800046a8:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    800046ac:	000a3783          	ld	a5,0(s4)
    800046b0:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    800046b4:	000a3783          	ld	a5,0(s4)
    800046b8:	0127b823          	sd	s2,16(a5)
  return 0;
    800046bc:	4501                	li	a0,0
    800046be:	6942                	ld	s2,16(sp)
    800046c0:	69a2                	ld	s3,8(sp)
    800046c2:	a01d                	j	800046e8 <pipealloc+0xb8>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    800046c4:	6088                	ld	a0,0(s1)
    800046c6:	c119                	beqz	a0,800046cc <pipealloc+0x9c>
    800046c8:	6942                	ld	s2,16(sp)
    800046ca:	a029                	j	800046d4 <pipealloc+0xa4>
    800046cc:	6942                	ld	s2,16(sp)
    800046ce:	a029                	j	800046d8 <pipealloc+0xa8>
    800046d0:	6088                	ld	a0,0(s1)
    800046d2:	c10d                	beqz	a0,800046f4 <pipealloc+0xc4>
    fileclose(*f0);
    800046d4:	c41ff0ef          	jal	80004314 <fileclose>
  if(*f1)
    800046d8:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    800046dc:	557d                	li	a0,-1
  if(*f1)
    800046de:	c789                	beqz	a5,800046e8 <pipealloc+0xb8>
    fileclose(*f1);
    800046e0:	853e                	mv	a0,a5
    800046e2:	c33ff0ef          	jal	80004314 <fileclose>
  return -1;
    800046e6:	557d                	li	a0,-1
}
    800046e8:	70a2                	ld	ra,40(sp)
    800046ea:	7402                	ld	s0,32(sp)
    800046ec:	64e2                	ld	s1,24(sp)
    800046ee:	6a02                	ld	s4,0(sp)
    800046f0:	6145                	addi	sp,sp,48
    800046f2:	8082                	ret
  return -1;
    800046f4:	557d                	li	a0,-1
    800046f6:	bfcd                	j	800046e8 <pipealloc+0xb8>

00000000800046f8 <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    800046f8:	1101                	addi	sp,sp,-32
    800046fa:	ec06                	sd	ra,24(sp)
    800046fc:	e822                	sd	s0,16(sp)
    800046fe:	e426                	sd	s1,8(sp)
    80004700:	e04a                	sd	s2,0(sp)
    80004702:	1000                	addi	s0,sp,32
    80004704:	84aa                	mv	s1,a0
    80004706:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80004708:	d52fc0ef          	jal	80000c5a <acquire>
  if(writable){
    8000470c:	02090763          	beqz	s2,8000473a <pipeclose+0x42>
    pi->writeopen = 0;
    80004710:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80004714:	21848513          	addi	a0,s1,536
    80004718:	a71fd0ef          	jal	80002188 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    8000471c:	2204a783          	lw	a5,544(s1)
    80004720:	e781                	bnez	a5,80004728 <pipeclose+0x30>
    80004722:	2244a783          	lw	a5,548(s1)
    80004726:	c38d                	beqz	a5,80004748 <pipeclose+0x50>
    release(&pi->lock);
    kfree((char*)pi);
  } else
    release(&pi->lock);
    80004728:	8526                	mv	a0,s1
    8000472a:	dc4fc0ef          	jal	80000cee <release>
}
    8000472e:	60e2                	ld	ra,24(sp)
    80004730:	6442                	ld	s0,16(sp)
    80004732:	64a2                	ld	s1,8(sp)
    80004734:	6902                	ld	s2,0(sp)
    80004736:	6105                	addi	sp,sp,32
    80004738:	8082                	ret
    pi->readopen = 0;
    8000473a:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    8000473e:	21c48513          	addi	a0,s1,540
    80004742:	a47fd0ef          	jal	80002188 <wakeup>
    80004746:	bfd9                	j	8000471c <pipeclose+0x24>
    release(&pi->lock);
    80004748:	8526                	mv	a0,s1
    8000474a:	da4fc0ef          	jal	80000cee <release>
    kfree((char*)pi);
    8000474e:	8526                	mv	a0,s1
    80004750:	b3efc0ef          	jal	80000a8e <kfree>
    80004754:	bfe9                	j	8000472e <pipeclose+0x36>

0000000080004756 <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80004756:	7159                	addi	sp,sp,-112
    80004758:	f486                	sd	ra,104(sp)
    8000475a:	f0a2                	sd	s0,96(sp)
    8000475c:	eca6                	sd	s1,88(sp)
    8000475e:	e8ca                	sd	s2,80(sp)
    80004760:	e4ce                	sd	s3,72(sp)
    80004762:	e0d2                	sd	s4,64(sp)
    80004764:	fc56                	sd	s5,56(sp)
    80004766:	1880                	addi	s0,sp,112
    80004768:	84aa                	mv	s1,a0
    8000476a:	8aae                	mv	s5,a1
    8000476c:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    8000476e:	a0efd0ef          	jal	8000197c <myproc>
    80004772:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    80004774:	8526                	mv	a0,s1
    80004776:	ce4fc0ef          	jal	80000c5a <acquire>
  while(i < n){
    8000477a:	0d405263          	blez	s4,8000483e <pipewrite+0xe8>
    8000477e:	f85a                	sd	s6,48(sp)
    80004780:	f45e                	sd	s7,40(sp)
    80004782:	f062                	sd	s8,32(sp)
    80004784:	ec66                	sd	s9,24(sp)
    80004786:	e86a                	sd	s10,16(sp)
  int i = 0;
    80004788:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    8000478a:	f9f40c13          	addi	s8,s0,-97
    8000478e:	4b85                	li	s7,1
    80004790:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    80004792:	21848d13          	addi	s10,s1,536
      sleep(&pi->nwrite, &pi->lock);
    80004796:	21c48c93          	addi	s9,s1,540
    8000479a:	a82d                	j	800047d4 <pipewrite+0x7e>
      release(&pi->lock);
    8000479c:	8526                	mv	a0,s1
    8000479e:	d50fc0ef          	jal	80000cee <release>
      return -1;
    800047a2:	597d                	li	s2,-1
    800047a4:	7b42                	ld	s6,48(sp)
    800047a6:	7ba2                	ld	s7,40(sp)
    800047a8:	7c02                	ld	s8,32(sp)
    800047aa:	6ce2                	ld	s9,24(sp)
    800047ac:	6d42                	ld	s10,16(sp)
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    800047ae:	854a                	mv	a0,s2
    800047b0:	70a6                	ld	ra,104(sp)
    800047b2:	7406                	ld	s0,96(sp)
    800047b4:	64e6                	ld	s1,88(sp)
    800047b6:	6946                	ld	s2,80(sp)
    800047b8:	69a6                	ld	s3,72(sp)
    800047ba:	6a06                	ld	s4,64(sp)
    800047bc:	7ae2                	ld	s5,56(sp)
    800047be:	6165                	addi	sp,sp,112
    800047c0:	8082                	ret
      wakeup(&pi->nread);
    800047c2:	856a                	mv	a0,s10
    800047c4:	9c5fd0ef          	jal	80002188 <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    800047c8:	85a6                	mv	a1,s1
    800047ca:	8566                	mv	a0,s9
    800047cc:	971fd0ef          	jal	8000213c <sleep>
  while(i < n){
    800047d0:	05495a63          	bge	s2,s4,80004824 <pipewrite+0xce>
    if(pi->readopen == 0 || killed(pr)){
    800047d4:	2204a783          	lw	a5,544(s1)
    800047d8:	d3f1                	beqz	a5,8000479c <pipewrite+0x46>
    800047da:	854e                	mv	a0,s3
    800047dc:	b9dfd0ef          	jal	80002378 <killed>
    800047e0:	fd55                	bnez	a0,8000479c <pipewrite+0x46>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    800047e2:	2184a783          	lw	a5,536(s1)
    800047e6:	21c4a703          	lw	a4,540(s1)
    800047ea:	2007879b          	addiw	a5,a5,512
    800047ee:	fcf70ae3          	beq	a4,a5,800047c2 <pipewrite+0x6c>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    800047f2:	86de                	mv	a3,s7
    800047f4:	01590633          	add	a2,s2,s5
    800047f8:	85e2                	mv	a1,s8
    800047fa:	0509b503          	ld	a0,80(s3)
    800047fe:	f4ffc0ef          	jal	8000174c <copyin>
    80004802:	05650063          	beq	a0,s6,80004842 <pipewrite+0xec>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80004806:	21c4a783          	lw	a5,540(s1)
    8000480a:	0017871b          	addiw	a4,a5,1
    8000480e:	20e4ae23          	sw	a4,540(s1)
    80004812:	1ff7f793          	andi	a5,a5,511
    80004816:	97a6                	add	a5,a5,s1
    80004818:	f9f44703          	lbu	a4,-97(s0)
    8000481c:	00e78c23          	sb	a4,24(a5)
      i++;
    80004820:	2905                	addiw	s2,s2,1
    80004822:	b77d                	j	800047d0 <pipewrite+0x7a>
    80004824:	7b42                	ld	s6,48(sp)
    80004826:	7ba2                	ld	s7,40(sp)
    80004828:	7c02                	ld	s8,32(sp)
    8000482a:	6ce2                	ld	s9,24(sp)
    8000482c:	6d42                	ld	s10,16(sp)
  wakeup(&pi->nread);
    8000482e:	21848513          	addi	a0,s1,536
    80004832:	957fd0ef          	jal	80002188 <wakeup>
  release(&pi->lock);
    80004836:	8526                	mv	a0,s1
    80004838:	cb6fc0ef          	jal	80000cee <release>
  return i;
    8000483c:	bf8d                	j	800047ae <pipewrite+0x58>
  int i = 0;
    8000483e:	4901                	li	s2,0
    80004840:	b7fd                	j	8000482e <pipewrite+0xd8>
    80004842:	7b42                	ld	s6,48(sp)
    80004844:	7ba2                	ld	s7,40(sp)
    80004846:	7c02                	ld	s8,32(sp)
    80004848:	6ce2                	ld	s9,24(sp)
    8000484a:	6d42                	ld	s10,16(sp)
    8000484c:	b7cd                	j	8000482e <pipewrite+0xd8>

000000008000484e <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    8000484e:	711d                	addi	sp,sp,-96
    80004850:	ec86                	sd	ra,88(sp)
    80004852:	e8a2                	sd	s0,80(sp)
    80004854:	e4a6                	sd	s1,72(sp)
    80004856:	e0ca                	sd	s2,64(sp)
    80004858:	fc4e                	sd	s3,56(sp)
    8000485a:	f852                	sd	s4,48(sp)
    8000485c:	f456                	sd	s5,40(sp)
    8000485e:	1080                	addi	s0,sp,96
    80004860:	84aa                	mv	s1,a0
    80004862:	892e                	mv	s2,a1
    80004864:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80004866:	916fd0ef          	jal	8000197c <myproc>
    8000486a:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    8000486c:	8526                	mv	a0,s1
    8000486e:	becfc0ef          	jal	80000c5a <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004872:	2184a703          	lw	a4,536(s1)
    80004876:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    8000487a:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    8000487e:	02f71763          	bne	a4,a5,800048ac <piperead+0x5e>
    80004882:	2244a783          	lw	a5,548(s1)
    80004886:	cf85                	beqz	a5,800048be <piperead+0x70>
    if(killed(pr)){
    80004888:	8552                	mv	a0,s4
    8000488a:	aeffd0ef          	jal	80002378 <killed>
    8000488e:	e11d                	bnez	a0,800048b4 <piperead+0x66>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004890:	85a6                	mv	a1,s1
    80004892:	854e                	mv	a0,s3
    80004894:	8a9fd0ef          	jal	8000213c <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004898:	2184a703          	lw	a4,536(s1)
    8000489c:	21c4a783          	lw	a5,540(s1)
    800048a0:	fef701e3          	beq	a4,a5,80004882 <piperead+0x34>
    800048a4:	f05a                	sd	s6,32(sp)
    800048a6:	ec5e                	sd	s7,24(sp)
    800048a8:	e862                	sd	s8,16(sp)
    800048aa:	a829                	j	800048c4 <piperead+0x76>
    800048ac:	f05a                	sd	s6,32(sp)
    800048ae:	ec5e                	sd	s7,24(sp)
    800048b0:	e862                	sd	s8,16(sp)
    800048b2:	a809                	j	800048c4 <piperead+0x76>
      release(&pi->lock);
    800048b4:	8526                	mv	a0,s1
    800048b6:	c38fc0ef          	jal	80000cee <release>
      return -1;
    800048ba:	59fd                	li	s3,-1
    800048bc:	a0a5                	j	80004924 <piperead+0xd6>
    800048be:	f05a                	sd	s6,32(sp)
    800048c0:	ec5e                	sd	s7,24(sp)
    800048c2:	e862                	sd	s8,16(sp)
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    800048c4:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1) {
    800048c6:	faf40c13          	addi	s8,s0,-81
    800048ca:	4b85                	li	s7,1
    800048cc:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    800048ce:	05505163          	blez	s5,80004910 <piperead+0xc2>
    if(pi->nread == pi->nwrite)
    800048d2:	2184a783          	lw	a5,536(s1)
    800048d6:	21c4a703          	lw	a4,540(s1)
    800048da:	02f70b63          	beq	a4,a5,80004910 <piperead+0xc2>
    ch = pi->data[pi->nread % PIPESIZE];
    800048de:	1ff7f793          	andi	a5,a5,511
    800048e2:	97a6                	add	a5,a5,s1
    800048e4:	0187c783          	lbu	a5,24(a5)
    800048e8:	faf407a3          	sb	a5,-81(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1) {
    800048ec:	86de                	mv	a3,s7
    800048ee:	8662                	mv	a2,s8
    800048f0:	85ca                	mv	a1,s2
    800048f2:	050a3503          	ld	a0,80(s4)
    800048f6:	d99fc0ef          	jal	8000168e <copyout>
    800048fa:	03650f63          	beq	a0,s6,80004938 <piperead+0xea>
      if(i == 0)
        i = -1;
      break;
    }
    pi->nread++;
    800048fe:	2184a783          	lw	a5,536(s1)
    80004902:	2785                	addiw	a5,a5,1
    80004904:	20f4ac23          	sw	a5,536(s1)
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004908:	2985                	addiw	s3,s3,1
    8000490a:	0905                	addi	s2,s2,1
    8000490c:	fd3a93e3          	bne	s5,s3,800048d2 <piperead+0x84>
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80004910:	21c48513          	addi	a0,s1,540
    80004914:	875fd0ef          	jal	80002188 <wakeup>
  release(&pi->lock);
    80004918:	8526                	mv	a0,s1
    8000491a:	bd4fc0ef          	jal	80000cee <release>
    8000491e:	7b02                	ld	s6,32(sp)
    80004920:	6be2                	ld	s7,24(sp)
    80004922:	6c42                	ld	s8,16(sp)
  return i;
}
    80004924:	854e                	mv	a0,s3
    80004926:	60e6                	ld	ra,88(sp)
    80004928:	6446                	ld	s0,80(sp)
    8000492a:	64a6                	ld	s1,72(sp)
    8000492c:	6906                	ld	s2,64(sp)
    8000492e:	79e2                	ld	s3,56(sp)
    80004930:	7a42                	ld	s4,48(sp)
    80004932:	7aa2                	ld	s5,40(sp)
    80004934:	6125                	addi	sp,sp,96
    80004936:	8082                	ret
      if(i == 0)
    80004938:	fc099ce3          	bnez	s3,80004910 <piperead+0xc2>
        i = -1;
    8000493c:	89aa                	mv	s3,a0
    8000493e:	bfc9                	j	80004910 <piperead+0xc2>

0000000080004940 <flags2perm>:

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

// map ELF permissions to PTE permission bits.
int flags2perm(int flags)
{
    80004940:	1141                	addi	sp,sp,-16
    80004942:	e406                	sd	ra,8(sp)
    80004944:	e022                	sd	s0,0(sp)
    80004946:	0800                	addi	s0,sp,16
    80004948:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    8000494a:	0035151b          	slliw	a0,a0,0x3
    8000494e:	8921                	andi	a0,a0,8
      perm = PTE_X;
    if(flags & 0x2)
    80004950:	8b89                	andi	a5,a5,2
    80004952:	c399                	beqz	a5,80004958 <flags2perm+0x18>
      perm |= PTE_W;
    80004954:	00456513          	ori	a0,a0,4
    return perm;
}
    80004958:	60a2                	ld	ra,8(sp)
    8000495a:	6402                	ld	s0,0(sp)
    8000495c:	0141                	addi	sp,sp,16
    8000495e:	8082                	ret

0000000080004960 <kexec>:
//
// the implementation of the exec() system call
//
int
kexec(char *path, char **argv)
{
    80004960:	de010113          	addi	sp,sp,-544
    80004964:	20113c23          	sd	ra,536(sp)
    80004968:	20813823          	sd	s0,528(sp)
    8000496c:	20913423          	sd	s1,520(sp)
    80004970:	21213023          	sd	s2,512(sp)
    80004974:	1400                	addi	s0,sp,544
    80004976:	892a                	mv	s2,a0
    80004978:	dea43823          	sd	a0,-528(s0)
    8000497c:	e0b43023          	sd	a1,-512(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80004980:	ffdfc0ef          	jal	8000197c <myproc>
    80004984:	84aa                	mv	s1,a0

  begin_op();
    80004986:	d6aff0ef          	jal	80003ef0 <begin_op>

  // Open the executable file.
  if((ip = namei(path)) == 0){
    8000498a:	854a                	mv	a0,s2
    8000498c:	b86ff0ef          	jal	80003d12 <namei>
    80004990:	cd21                	beqz	a0,800049e8 <kexec+0x88>
    80004992:	fbd2                	sd	s4,496(sp)
    80004994:	8a2a                	mv	s4,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80004996:	b4ffe0ef          	jal	800034e4 <ilock>

  // Read the ELF header.
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    8000499a:	04000713          	li	a4,64
    8000499e:	4681                	li	a3,0
    800049a0:	e5040613          	addi	a2,s0,-432
    800049a4:	4581                	li	a1,0
    800049a6:	8552                	mv	a0,s4
    800049a8:	ecffe0ef          	jal	80003876 <readi>
    800049ac:	04000793          	li	a5,64
    800049b0:	00f51a63          	bne	a0,a5,800049c4 <kexec+0x64>
    goto bad;

  // Is this really an ELF file?
  if(elf.magic != ELF_MAGIC)
    800049b4:	e5042703          	lw	a4,-432(s0)
    800049b8:	464c47b7          	lui	a5,0x464c4
    800049bc:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    800049c0:	02f70863          	beq	a4,a5,800049f0 <kexec+0x90>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    800049c4:	8552                	mv	a0,s4
    800049c6:	d2bfe0ef          	jal	800036f0 <iunlockput>
    end_op();
    800049ca:	d96ff0ef          	jal	80003f60 <end_op>
  }
  return -1;
    800049ce:	557d                	li	a0,-1
    800049d0:	7a5e                	ld	s4,496(sp)
}
    800049d2:	21813083          	ld	ra,536(sp)
    800049d6:	21013403          	ld	s0,528(sp)
    800049da:	20813483          	ld	s1,520(sp)
    800049de:	20013903          	ld	s2,512(sp)
    800049e2:	22010113          	addi	sp,sp,544
    800049e6:	8082                	ret
    end_op();
    800049e8:	d78ff0ef          	jal	80003f60 <end_op>
    return -1;
    800049ec:	557d                	li	a0,-1
    800049ee:	b7d5                	j	800049d2 <kexec+0x72>
    800049f0:	f3da                	sd	s6,480(sp)
  if((pagetable = proc_pagetable(p)) == 0)
    800049f2:	8526                	mv	a0,s1
    800049f4:	892fd0ef          	jal	80001a86 <proc_pagetable>
    800049f8:	8b2a                	mv	s6,a0
    800049fa:	26050f63          	beqz	a0,80004c78 <kexec+0x318>
    800049fe:	ffce                	sd	s3,504(sp)
    80004a00:	f7d6                	sd	s5,488(sp)
    80004a02:	efde                	sd	s7,472(sp)
    80004a04:	ebe2                	sd	s8,464(sp)
    80004a06:	e7e6                	sd	s9,456(sp)
    80004a08:	e3ea                	sd	s10,448(sp)
    80004a0a:	ff6e                	sd	s11,440(sp)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004a0c:	e8845783          	lhu	a5,-376(s0)
    80004a10:	0e078963          	beqz	a5,80004b02 <kexec+0x1a2>
    80004a14:	e7042683          	lw	a3,-400(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004a18:	4901                	li	s2,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004a1a:	4d01                	li	s10,0
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80004a1c:	03800d93          	li	s11,56
    if(ph.vaddr % PGSIZE != 0)
    80004a20:	6c85                	lui	s9,0x1
    80004a22:	fffc8793          	addi	a5,s9,-1 # fff <_entry-0x7ffff001>
    80004a26:	def43423          	sd	a5,-536(s0)

  for(i = 0; i < sz; i += PGSIZE){
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    if(sz - i < PGSIZE)
    80004a2a:	6a85                	lui	s5,0x1
    80004a2c:	a085                	j	80004a8c <kexec+0x12c>
      panic("loadseg: address should exist");
    80004a2e:	00004517          	auipc	a0,0x4
    80004a32:	baa50513          	addi	a0,a0,-1110 # 800085d8 <etext+0x5d8>
    80004a36:	e21fb0ef          	jal	80000856 <panic>
    if(sz - i < PGSIZE)
    80004a3a:	2901                	sext.w	s2,s2
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80004a3c:	874a                	mv	a4,s2
    80004a3e:	009b86bb          	addw	a3,s7,s1
    80004a42:	4581                	li	a1,0
    80004a44:	8552                	mv	a0,s4
    80004a46:	e31fe0ef          	jal	80003876 <readi>
    80004a4a:	22a91b63          	bne	s2,a0,80004c80 <kexec+0x320>
  for(i = 0; i < sz; i += PGSIZE){
    80004a4e:	009a84bb          	addw	s1,s5,s1
    80004a52:	0334f263          	bgeu	s1,s3,80004a76 <kexec+0x116>
    pa = walkaddr(pagetable, va + i);
    80004a56:	02049593          	slli	a1,s1,0x20
    80004a5a:	9181                	srli	a1,a1,0x20
    80004a5c:	95e2                	add	a1,a1,s8
    80004a5e:	855a                	mv	a0,s6
    80004a60:	e00fc0ef          	jal	80001060 <walkaddr>
    80004a64:	862a                	mv	a2,a0
    if(pa == 0)
    80004a66:	d561                	beqz	a0,80004a2e <kexec+0xce>
    if(sz - i < PGSIZE)
    80004a68:	409987bb          	subw	a5,s3,s1
    80004a6c:	893e                	mv	s2,a5
    80004a6e:	fcfcf6e3          	bgeu	s9,a5,80004a3a <kexec+0xda>
    80004a72:	8956                	mv	s2,s5
    80004a74:	b7d9                	j	80004a3a <kexec+0xda>
    sz = sz1;
    80004a76:	df843903          	ld	s2,-520(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004a7a:	2d05                	addiw	s10,s10,1
    80004a7c:	e0843783          	ld	a5,-504(s0)
    80004a80:	0387869b          	addiw	a3,a5,56
    80004a84:	e8845783          	lhu	a5,-376(s0)
    80004a88:	06fd5e63          	bge	s10,a5,80004b04 <kexec+0x1a4>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80004a8c:	e0d43423          	sd	a3,-504(s0)
    80004a90:	876e                	mv	a4,s11
    80004a92:	e1840613          	addi	a2,s0,-488
    80004a96:	4581                	li	a1,0
    80004a98:	8552                	mv	a0,s4
    80004a9a:	dddfe0ef          	jal	80003876 <readi>
    80004a9e:	1db51f63          	bne	a0,s11,80004c7c <kexec+0x31c>
    if(ph.type != ELF_PROG_LOAD)
    80004aa2:	e1842783          	lw	a5,-488(s0)
    80004aa6:	4705                	li	a4,1
    80004aa8:	fce799e3          	bne	a5,a4,80004a7a <kexec+0x11a>
    if(ph.memsz < ph.filesz)
    80004aac:	e4043483          	ld	s1,-448(s0)
    80004ab0:	e3843783          	ld	a5,-456(s0)
    80004ab4:	1ef4e463          	bltu	s1,a5,80004c9c <kexec+0x33c>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    80004ab8:	e2843783          	ld	a5,-472(s0)
    80004abc:	94be                	add	s1,s1,a5
    80004abe:	1ef4e263          	bltu	s1,a5,80004ca2 <kexec+0x342>
    if(ph.vaddr % PGSIZE != 0)
    80004ac2:	de843703          	ld	a4,-536(s0)
    80004ac6:	8ff9                	and	a5,a5,a4
    80004ac8:	1e079063          	bnez	a5,80004ca8 <kexec+0x348>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80004acc:	e1c42503          	lw	a0,-484(s0)
    80004ad0:	e71ff0ef          	jal	80004940 <flags2perm>
    80004ad4:	86aa                	mv	a3,a0
    80004ad6:	8626                	mv	a2,s1
    80004ad8:	85ca                	mv	a1,s2
    80004ada:	855a                	mv	a0,s6
    80004adc:	85bfc0ef          	jal	80001336 <uvmalloc>
    80004ae0:	dea43c23          	sd	a0,-520(s0)
    80004ae4:	1c050563          	beqz	a0,80004cae <kexec+0x34e>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80004ae8:	e3842983          	lw	s3,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    80004aec:	00098863          	beqz	s3,80004afc <kexec+0x19c>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80004af0:	e2843c03          	ld	s8,-472(s0)
    80004af4:	e2042b83          	lw	s7,-480(s0)
  for(i = 0; i < sz; i += PGSIZE){
    80004af8:	4481                	li	s1,0
    80004afa:	bfb1                	j	80004a56 <kexec+0xf6>
    sz = sz1;
    80004afc:	df843903          	ld	s2,-520(s0)
    80004b00:	bfad                	j	80004a7a <kexec+0x11a>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004b02:	4901                	li	s2,0
  iunlockput(ip);
    80004b04:	8552                	mv	a0,s4
    80004b06:	bebfe0ef          	jal	800036f0 <iunlockput>
  end_op();
    80004b0a:	c56ff0ef          	jal	80003f60 <end_op>
  p = myproc();
    80004b0e:	e6ffc0ef          	jal	8000197c <myproc>
    80004b12:	8aaa                	mv	s5,a0
  uint64 oldsz = p->sz;
    80004b14:	04853d03          	ld	s10,72(a0)
  sz = PGROUNDUP(sz);
    80004b18:	6985                	lui	s3,0x1
    80004b1a:	19fd                	addi	s3,s3,-1 # fff <_entry-0x7ffff001>
    80004b1c:	99ca                	add	s3,s3,s2
    80004b1e:	77fd                	lui	a5,0xfffff
    80004b20:	00f9f9b3          	and	s3,s3,a5
  if((sz1 = uvmalloc(pagetable, sz, sz + (USERSTACK+1)*PGSIZE, PTE_W)) == 0)
    80004b24:	4691                	li	a3,4
    80004b26:	6609                	lui	a2,0x2
    80004b28:	964e                	add	a2,a2,s3
    80004b2a:	85ce                	mv	a1,s3
    80004b2c:	855a                	mv	a0,s6
    80004b2e:	809fc0ef          	jal	80001336 <uvmalloc>
    80004b32:	8a2a                	mv	s4,a0
    80004b34:	e105                	bnez	a0,80004b54 <kexec+0x1f4>
    proc_freepagetable(pagetable, sz);
    80004b36:	85ce                	mv	a1,s3
    80004b38:	855a                	mv	a0,s6
    80004b3a:	fd1fc0ef          	jal	80001b0a <proc_freepagetable>
  return -1;
    80004b3e:	557d                	li	a0,-1
    80004b40:	79fe                	ld	s3,504(sp)
    80004b42:	7a5e                	ld	s4,496(sp)
    80004b44:	7abe                	ld	s5,488(sp)
    80004b46:	7b1e                	ld	s6,480(sp)
    80004b48:	6bfe                	ld	s7,472(sp)
    80004b4a:	6c5e                	ld	s8,464(sp)
    80004b4c:	6cbe                	ld	s9,456(sp)
    80004b4e:	6d1e                	ld	s10,448(sp)
    80004b50:	7dfa                	ld	s11,440(sp)
    80004b52:	b541                	j	800049d2 <kexec+0x72>
  uvmclear(pagetable, sz-(USERSTACK+1)*PGSIZE);
    80004b54:	75f9                	lui	a1,0xffffe
    80004b56:	95aa                	add	a1,a1,a0
    80004b58:	855a                	mv	a0,s6
    80004b5a:	9affc0ef          	jal	80001508 <uvmclear>
  stackbase = sp - USERSTACK*PGSIZE;
    80004b5e:	800a0b93          	addi	s7,s4,-2048
    80004b62:	800b8b93          	addi	s7,s7,-2048
  for(argc = 0; argv[argc]; argc++) {
    80004b66:	e0043783          	ld	a5,-512(s0)
    80004b6a:	6388                	ld	a0,0(a5)
  sp = sz;
    80004b6c:	8952                	mv	s2,s4
  for(argc = 0; argv[argc]; argc++) {
    80004b6e:	4481                	li	s1,0
    ustack[argc] = sp;
    80004b70:	e9040c93          	addi	s9,s0,-368
    if(argc >= MAXARG)
    80004b74:	02000c13          	li	s8,32
  for(argc = 0; argv[argc]; argc++) {
    80004b78:	cd21                	beqz	a0,80004bd0 <kexec+0x270>
    sp -= strlen(argv[argc]) + 1;
    80004b7a:	b3afc0ef          	jal	80000eb4 <strlen>
    80004b7e:	0015079b          	addiw	a5,a0,1
    80004b82:	40f907b3          	sub	a5,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80004b86:	ff07f913          	andi	s2,a5,-16
    if(sp < stackbase)
    80004b8a:	13796563          	bltu	s2,s7,80004cb4 <kexec+0x354>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80004b8e:	e0043d83          	ld	s11,-512(s0)
    80004b92:	000db983          	ld	s3,0(s11)
    80004b96:	854e                	mv	a0,s3
    80004b98:	b1cfc0ef          	jal	80000eb4 <strlen>
    80004b9c:	0015069b          	addiw	a3,a0,1
    80004ba0:	864e                	mv	a2,s3
    80004ba2:	85ca                	mv	a1,s2
    80004ba4:	855a                	mv	a0,s6
    80004ba6:	ae9fc0ef          	jal	8000168e <copyout>
    80004baa:	10054763          	bltz	a0,80004cb8 <kexec+0x358>
    ustack[argc] = sp;
    80004bae:	00349793          	slli	a5,s1,0x3
    80004bb2:	97e6                	add	a5,a5,s9
    80004bb4:	0127b023          	sd	s2,0(a5) # fffffffffffff000 <end+0xffffffff7ffc2590>
  for(argc = 0; argv[argc]; argc++) {
    80004bb8:	0485                	addi	s1,s1,1
    80004bba:	008d8793          	addi	a5,s11,8
    80004bbe:	e0f43023          	sd	a5,-512(s0)
    80004bc2:	008db503          	ld	a0,8(s11)
    80004bc6:	c509                	beqz	a0,80004bd0 <kexec+0x270>
    if(argc >= MAXARG)
    80004bc8:	fb8499e3          	bne	s1,s8,80004b7a <kexec+0x21a>
  sz = sz1;
    80004bcc:	89d2                	mv	s3,s4
    80004bce:	b7a5                	j	80004b36 <kexec+0x1d6>
  ustack[argc] = 0;
    80004bd0:	00349793          	slli	a5,s1,0x3
    80004bd4:	f9078793          	addi	a5,a5,-112
    80004bd8:	97a2                	add	a5,a5,s0
    80004bda:	f007b023          	sd	zero,-256(a5)
  sp -= (argc+1) * sizeof(uint64);
    80004bde:	00349693          	slli	a3,s1,0x3
    80004be2:	06a1                	addi	a3,a3,8
    80004be4:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    80004be8:	ff097913          	andi	s2,s2,-16
  sz = sz1;
    80004bec:	89d2                	mv	s3,s4
  if(sp < stackbase)
    80004bee:	f57964e3          	bltu	s2,s7,80004b36 <kexec+0x1d6>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    80004bf2:	e9040613          	addi	a2,s0,-368
    80004bf6:	85ca                	mv	a1,s2
    80004bf8:	855a                	mv	a0,s6
    80004bfa:	a95fc0ef          	jal	8000168e <copyout>
    80004bfe:	f2054ce3          	bltz	a0,80004b36 <kexec+0x1d6>
  p->trapframe->a1 = sp;
    80004c02:	058ab783          	ld	a5,88(s5) # 1058 <_entry-0x7fffefa8>
    80004c06:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    80004c0a:	df043783          	ld	a5,-528(s0)
    80004c0e:	0007c703          	lbu	a4,0(a5)
    80004c12:	cf11                	beqz	a4,80004c2e <kexec+0x2ce>
    80004c14:	0785                	addi	a5,a5,1
    if(*s == '/')
    80004c16:	02f00693          	li	a3,47
    80004c1a:	a029                	j	80004c24 <kexec+0x2c4>
  for(last=s=path; *s; s++)
    80004c1c:	0785                	addi	a5,a5,1
    80004c1e:	fff7c703          	lbu	a4,-1(a5)
    80004c22:	c711                	beqz	a4,80004c2e <kexec+0x2ce>
    if(*s == '/')
    80004c24:	fed71ce3          	bne	a4,a3,80004c1c <kexec+0x2bc>
      last = s+1;
    80004c28:	def43823          	sd	a5,-528(s0)
    80004c2c:	bfc5                	j	80004c1c <kexec+0x2bc>
  safestrcpy(p->name, last, sizeof(p->name));
    80004c2e:	4641                	li	a2,16
    80004c30:	df043583          	ld	a1,-528(s0)
    80004c34:	158a8513          	addi	a0,s5,344
    80004c38:	a46fc0ef          	jal	80000e7e <safestrcpy>
  oldpagetable = p->pagetable;
    80004c3c:	050ab503          	ld	a0,80(s5)
  p->pagetable = pagetable;
    80004c40:	056ab823          	sd	s6,80(s5)
  p->sz = sz;
    80004c44:	054ab423          	sd	s4,72(s5)
  p->trapframe->epc = elf.entry;  // initial program counter = ulib.c:start()
    80004c48:	058ab783          	ld	a5,88(s5)
    80004c4c:	e6843703          	ld	a4,-408(s0)
    80004c50:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    80004c52:	058ab783          	ld	a5,88(s5)
    80004c56:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    80004c5a:	85ea                	mv	a1,s10
    80004c5c:	eaffc0ef          	jal	80001b0a <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80004c60:	0004851b          	sext.w	a0,s1
    80004c64:	79fe                	ld	s3,504(sp)
    80004c66:	7a5e                	ld	s4,496(sp)
    80004c68:	7abe                	ld	s5,488(sp)
    80004c6a:	7b1e                	ld	s6,480(sp)
    80004c6c:	6bfe                	ld	s7,472(sp)
    80004c6e:	6c5e                	ld	s8,464(sp)
    80004c70:	6cbe                	ld	s9,456(sp)
    80004c72:	6d1e                	ld	s10,448(sp)
    80004c74:	7dfa                	ld	s11,440(sp)
    80004c76:	bbb1                	j	800049d2 <kexec+0x72>
    80004c78:	7b1e                	ld	s6,480(sp)
    80004c7a:	b3a9                	j	800049c4 <kexec+0x64>
    80004c7c:	df243c23          	sd	s2,-520(s0)
    proc_freepagetable(pagetable, sz);
    80004c80:	df843583          	ld	a1,-520(s0)
    80004c84:	855a                	mv	a0,s6
    80004c86:	e85fc0ef          	jal	80001b0a <proc_freepagetable>
  if(ip){
    80004c8a:	79fe                	ld	s3,504(sp)
    80004c8c:	7abe                	ld	s5,488(sp)
    80004c8e:	7b1e                	ld	s6,480(sp)
    80004c90:	6bfe                	ld	s7,472(sp)
    80004c92:	6c5e                	ld	s8,464(sp)
    80004c94:	6cbe                	ld	s9,456(sp)
    80004c96:	6d1e                	ld	s10,448(sp)
    80004c98:	7dfa                	ld	s11,440(sp)
    80004c9a:	b32d                	j	800049c4 <kexec+0x64>
    80004c9c:	df243c23          	sd	s2,-520(s0)
    80004ca0:	b7c5                	j	80004c80 <kexec+0x320>
    80004ca2:	df243c23          	sd	s2,-520(s0)
    80004ca6:	bfe9                	j	80004c80 <kexec+0x320>
    80004ca8:	df243c23          	sd	s2,-520(s0)
    80004cac:	bfd1                	j	80004c80 <kexec+0x320>
    80004cae:	df243c23          	sd	s2,-520(s0)
    80004cb2:	b7f9                	j	80004c80 <kexec+0x320>
  sz = sz1;
    80004cb4:	89d2                	mv	s3,s4
    80004cb6:	b541                	j	80004b36 <kexec+0x1d6>
    80004cb8:	89d2                	mv	s3,s4
    80004cba:	bdb5                	j	80004b36 <kexec+0x1d6>

0000000080004cbc <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80004cbc:	7179                	addi	sp,sp,-48
    80004cbe:	f406                	sd	ra,40(sp)
    80004cc0:	f022                	sd	s0,32(sp)
    80004cc2:	ec26                	sd	s1,24(sp)
    80004cc4:	e84a                	sd	s2,16(sp)
    80004cc6:	1800                	addi	s0,sp,48
    80004cc8:	892e                	mv	s2,a1
    80004cca:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    80004ccc:	fdc40593          	addi	a1,s0,-36
    80004cd0:	d79fd0ef          	jal	80002a48 <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    80004cd4:	fdc42703          	lw	a4,-36(s0)
    80004cd8:	47bd                	li	a5,15
    80004cda:	02e7ea63          	bltu	a5,a4,80004d0e <argfd+0x52>
    80004cde:	c9ffc0ef          	jal	8000197c <myproc>
    80004ce2:	fdc42703          	lw	a4,-36(s0)
    80004ce6:	00371793          	slli	a5,a4,0x3
    80004cea:	0d078793          	addi	a5,a5,208
    80004cee:	953e                	add	a0,a0,a5
    80004cf0:	611c                	ld	a5,0(a0)
    80004cf2:	c385                	beqz	a5,80004d12 <argfd+0x56>
    return -1;
  if(pfd)
    80004cf4:	00090463          	beqz	s2,80004cfc <argfd+0x40>
    *pfd = fd;
    80004cf8:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    80004cfc:	4501                	li	a0,0
  if(pf)
    80004cfe:	c091                	beqz	s1,80004d02 <argfd+0x46>
    *pf = f;
    80004d00:	e09c                	sd	a5,0(s1)
}
    80004d02:	70a2                	ld	ra,40(sp)
    80004d04:	7402                	ld	s0,32(sp)
    80004d06:	64e2                	ld	s1,24(sp)
    80004d08:	6942                	ld	s2,16(sp)
    80004d0a:	6145                	addi	sp,sp,48
    80004d0c:	8082                	ret
    return -1;
    80004d0e:	557d                	li	a0,-1
    80004d10:	bfcd                	j	80004d02 <argfd+0x46>
    80004d12:	557d                	li	a0,-1
    80004d14:	b7fd                	j	80004d02 <argfd+0x46>

0000000080004d16 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    80004d16:	1101                	addi	sp,sp,-32
    80004d18:	ec06                	sd	ra,24(sp)
    80004d1a:	e822                	sd	s0,16(sp)
    80004d1c:	e426                	sd	s1,8(sp)
    80004d1e:	1000                	addi	s0,sp,32
    80004d20:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    80004d22:	c5bfc0ef          	jal	8000197c <myproc>
    80004d26:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    80004d28:	0d050793          	addi	a5,a0,208
    80004d2c:	4501                	li	a0,0
    80004d2e:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    80004d30:	6398                	ld	a4,0(a5)
    80004d32:	cb19                	beqz	a4,80004d48 <fdalloc+0x32>
  for(fd = 0; fd < NOFILE; fd++){
    80004d34:	2505                	addiw	a0,a0,1
    80004d36:	07a1                	addi	a5,a5,8
    80004d38:	fed51ce3          	bne	a0,a3,80004d30 <fdalloc+0x1a>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80004d3c:	557d                	li	a0,-1
}
    80004d3e:	60e2                	ld	ra,24(sp)
    80004d40:	6442                	ld	s0,16(sp)
    80004d42:	64a2                	ld	s1,8(sp)
    80004d44:	6105                	addi	sp,sp,32
    80004d46:	8082                	ret
      p->ofile[fd] = f;
    80004d48:	00351793          	slli	a5,a0,0x3
    80004d4c:	0d078793          	addi	a5,a5,208
    80004d50:	963e                	add	a2,a2,a5
    80004d52:	e204                	sd	s1,0(a2)
      return fd;
    80004d54:	b7ed                	j	80004d3e <fdalloc+0x28>

0000000080004d56 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    80004d56:	715d                	addi	sp,sp,-80
    80004d58:	e486                	sd	ra,72(sp)
    80004d5a:	e0a2                	sd	s0,64(sp)
    80004d5c:	fc26                	sd	s1,56(sp)
    80004d5e:	f84a                	sd	s2,48(sp)
    80004d60:	f44e                	sd	s3,40(sp)
    80004d62:	f052                	sd	s4,32(sp)
    80004d64:	ec56                	sd	s5,24(sp)
    80004d66:	e85a                	sd	s6,16(sp)
    80004d68:	0880                	addi	s0,sp,80
    80004d6a:	892e                	mv	s2,a1
    80004d6c:	8a2e                	mv	s4,a1
    80004d6e:	8ab2                	mv	s5,a2
    80004d70:	8b36                	mv	s6,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    80004d72:	fb040593          	addi	a1,s0,-80
    80004d76:	fb7fe0ef          	jal	80003d2c <nameiparent>
    80004d7a:	84aa                	mv	s1,a0
    80004d7c:	10050763          	beqz	a0,80004e8a <create+0x134>
    return 0;

  ilock(dp);
    80004d80:	f64fe0ef          	jal	800034e4 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    80004d84:	4601                	li	a2,0
    80004d86:	fb040593          	addi	a1,s0,-80
    80004d8a:	8526                	mv	a0,s1
    80004d8c:	cf3fe0ef          	jal	80003a7e <dirlookup>
    80004d90:	89aa                	mv	s3,a0
    80004d92:	c131                	beqz	a0,80004dd6 <create+0x80>
    iunlockput(dp);
    80004d94:	8526                	mv	a0,s1
    80004d96:	95bfe0ef          	jal	800036f0 <iunlockput>
    ilock(ip);
    80004d9a:	854e                	mv	a0,s3
    80004d9c:	f48fe0ef          	jal	800034e4 <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80004da0:	4789                	li	a5,2
    80004da2:	02f91563          	bne	s2,a5,80004dcc <create+0x76>
    80004da6:	0449d783          	lhu	a5,68(s3)
    80004daa:	37f9                	addiw	a5,a5,-2
    80004dac:	17c2                	slli	a5,a5,0x30
    80004dae:	93c1                	srli	a5,a5,0x30
    80004db0:	4705                	li	a4,1
    80004db2:	00f76d63          	bltu	a4,a5,80004dcc <create+0x76>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    80004db6:	854e                	mv	a0,s3
    80004db8:	60a6                	ld	ra,72(sp)
    80004dba:	6406                	ld	s0,64(sp)
    80004dbc:	74e2                	ld	s1,56(sp)
    80004dbe:	7942                	ld	s2,48(sp)
    80004dc0:	79a2                	ld	s3,40(sp)
    80004dc2:	7a02                	ld	s4,32(sp)
    80004dc4:	6ae2                	ld	s5,24(sp)
    80004dc6:	6b42                	ld	s6,16(sp)
    80004dc8:	6161                	addi	sp,sp,80
    80004dca:	8082                	ret
    iunlockput(ip);
    80004dcc:	854e                	mv	a0,s3
    80004dce:	923fe0ef          	jal	800036f0 <iunlockput>
    return 0;
    80004dd2:	4981                	li	s3,0
    80004dd4:	b7cd                	j	80004db6 <create+0x60>
  if((ip = ialloc(dp->dev, type)) == 0){
    80004dd6:	85ca                	mv	a1,s2
    80004dd8:	4088                	lw	a0,0(s1)
    80004dda:	d9afe0ef          	jal	80003374 <ialloc>
    80004dde:	892a                	mv	s2,a0
    80004de0:	cd15                	beqz	a0,80004e1c <create+0xc6>
  ilock(ip);
    80004de2:	f02fe0ef          	jal	800034e4 <ilock>
  ip->major = major;
    80004de6:	05591323          	sh	s5,70(s2)
  ip->minor = minor;
    80004dea:	05691423          	sh	s6,72(s2)
  ip->nlink = 1;
    80004dee:	4785                	li	a5,1
    80004df0:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80004df4:	854a                	mv	a0,s2
    80004df6:	e3afe0ef          	jal	80003430 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    80004dfa:	4705                	li	a4,1
    80004dfc:	02ea0463          	beq	s4,a4,80004e24 <create+0xce>
  if(dirlink(dp, name, ip->inum) < 0)
    80004e00:	00492603          	lw	a2,4(s2)
    80004e04:	fb040593          	addi	a1,s0,-80
    80004e08:	8526                	mv	a0,s1
    80004e0a:	e5ffe0ef          	jal	80003c68 <dirlink>
    80004e0e:	06054263          	bltz	a0,80004e72 <create+0x11c>
  iunlockput(dp);
    80004e12:	8526                	mv	a0,s1
    80004e14:	8ddfe0ef          	jal	800036f0 <iunlockput>
  return ip;
    80004e18:	89ca                	mv	s3,s2
    80004e1a:	bf71                	j	80004db6 <create+0x60>
    iunlockput(dp);
    80004e1c:	8526                	mv	a0,s1
    80004e1e:	8d3fe0ef          	jal	800036f0 <iunlockput>
    return 0;
    80004e22:	bf51                	j	80004db6 <create+0x60>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    80004e24:	00492603          	lw	a2,4(s2)
    80004e28:	00003597          	auipc	a1,0x3
    80004e2c:	7d058593          	addi	a1,a1,2000 # 800085f8 <etext+0x5f8>
    80004e30:	854a                	mv	a0,s2
    80004e32:	e37fe0ef          	jal	80003c68 <dirlink>
    80004e36:	02054e63          	bltz	a0,80004e72 <create+0x11c>
    80004e3a:	40d0                	lw	a2,4(s1)
    80004e3c:	00003597          	auipc	a1,0x3
    80004e40:	7c458593          	addi	a1,a1,1988 # 80008600 <etext+0x600>
    80004e44:	854a                	mv	a0,s2
    80004e46:	e23fe0ef          	jal	80003c68 <dirlink>
    80004e4a:	02054463          	bltz	a0,80004e72 <create+0x11c>
  if(dirlink(dp, name, ip->inum) < 0)
    80004e4e:	00492603          	lw	a2,4(s2)
    80004e52:	fb040593          	addi	a1,s0,-80
    80004e56:	8526                	mv	a0,s1
    80004e58:	e11fe0ef          	jal	80003c68 <dirlink>
    80004e5c:	00054b63          	bltz	a0,80004e72 <create+0x11c>
    dp->nlink++;  // for ".."
    80004e60:	04a4d783          	lhu	a5,74(s1)
    80004e64:	2785                	addiw	a5,a5,1
    80004e66:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80004e6a:	8526                	mv	a0,s1
    80004e6c:	dc4fe0ef          	jal	80003430 <iupdate>
    80004e70:	b74d                	j	80004e12 <create+0xbc>
  ip->nlink = 0;
    80004e72:	04091523          	sh	zero,74(s2)
  iupdate(ip);
    80004e76:	854a                	mv	a0,s2
    80004e78:	db8fe0ef          	jal	80003430 <iupdate>
  iunlockput(ip);
    80004e7c:	854a                	mv	a0,s2
    80004e7e:	873fe0ef          	jal	800036f0 <iunlockput>
  iunlockput(dp);
    80004e82:	8526                	mv	a0,s1
    80004e84:	86dfe0ef          	jal	800036f0 <iunlockput>
  return 0;
    80004e88:	b73d                	j	80004db6 <create+0x60>
    return 0;
    80004e8a:	89aa                	mv	s3,a0
    80004e8c:	b72d                	j	80004db6 <create+0x60>

0000000080004e8e <sys_dup>:
{
    80004e8e:	7179                	addi	sp,sp,-48
    80004e90:	f406                	sd	ra,40(sp)
    80004e92:	f022                	sd	s0,32(sp)
    80004e94:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    80004e96:	fd840613          	addi	a2,s0,-40
    80004e9a:	4581                	li	a1,0
    80004e9c:	4501                	li	a0,0
    80004e9e:	e1fff0ef          	jal	80004cbc <argfd>
    return -1;
    80004ea2:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    80004ea4:	02054363          	bltz	a0,80004eca <sys_dup+0x3c>
    80004ea8:	ec26                	sd	s1,24(sp)
    80004eaa:	e84a                	sd	s2,16(sp)
  if((fd=fdalloc(f)) < 0)
    80004eac:	fd843483          	ld	s1,-40(s0)
    80004eb0:	8526                	mv	a0,s1
    80004eb2:	e65ff0ef          	jal	80004d16 <fdalloc>
    80004eb6:	892a                	mv	s2,a0
    return -1;
    80004eb8:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    80004eba:	00054d63          	bltz	a0,80004ed4 <sys_dup+0x46>
  filedup(f);
    80004ebe:	8526                	mv	a0,s1
    80004ec0:	c0eff0ef          	jal	800042ce <filedup>
  return fd;
    80004ec4:	87ca                	mv	a5,s2
    80004ec6:	64e2                	ld	s1,24(sp)
    80004ec8:	6942                	ld	s2,16(sp)
}
    80004eca:	853e                	mv	a0,a5
    80004ecc:	70a2                	ld	ra,40(sp)
    80004ece:	7402                	ld	s0,32(sp)
    80004ed0:	6145                	addi	sp,sp,48
    80004ed2:	8082                	ret
    80004ed4:	64e2                	ld	s1,24(sp)
    80004ed6:	6942                	ld	s2,16(sp)
    80004ed8:	bfcd                	j	80004eca <sys_dup+0x3c>

0000000080004eda <sys_read>:
{
    80004eda:	7179                	addi	sp,sp,-48
    80004edc:	f406                	sd	ra,40(sp)
    80004ede:	f022                	sd	s0,32(sp)
    80004ee0:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80004ee2:	fd840593          	addi	a1,s0,-40
    80004ee6:	4505                	li	a0,1
    80004ee8:	b7dfd0ef          	jal	80002a64 <argaddr>
  argint(2, &n);
    80004eec:	fe440593          	addi	a1,s0,-28
    80004ef0:	4509                	li	a0,2
    80004ef2:	b57fd0ef          	jal	80002a48 <argint>
  if(argfd(0, 0, &f) < 0)
    80004ef6:	fe840613          	addi	a2,s0,-24
    80004efa:	4581                	li	a1,0
    80004efc:	4501                	li	a0,0
    80004efe:	dbfff0ef          	jal	80004cbc <argfd>
    80004f02:	87aa                	mv	a5,a0
    return -1;
    80004f04:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80004f06:	0007ca63          	bltz	a5,80004f1a <sys_read+0x40>
  return fileread(f, p, n);
    80004f0a:	fe442603          	lw	a2,-28(s0)
    80004f0e:	fd843583          	ld	a1,-40(s0)
    80004f12:	fe843503          	ld	a0,-24(s0)
    80004f16:	d22ff0ef          	jal	80004438 <fileread>
}
    80004f1a:	70a2                	ld	ra,40(sp)
    80004f1c:	7402                	ld	s0,32(sp)
    80004f1e:	6145                	addi	sp,sp,48
    80004f20:	8082                	ret

0000000080004f22 <sys_write>:
{
    80004f22:	7179                	addi	sp,sp,-48
    80004f24:	f406                	sd	ra,40(sp)
    80004f26:	f022                	sd	s0,32(sp)
    80004f28:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80004f2a:	fd840593          	addi	a1,s0,-40
    80004f2e:	4505                	li	a0,1
    80004f30:	b35fd0ef          	jal	80002a64 <argaddr>
  argint(2, &n);
    80004f34:	fe440593          	addi	a1,s0,-28
    80004f38:	4509                	li	a0,2
    80004f3a:	b0ffd0ef          	jal	80002a48 <argint>
  if(argfd(0, 0, &f) < 0)
    80004f3e:	fe840613          	addi	a2,s0,-24
    80004f42:	4581                	li	a1,0
    80004f44:	4501                	li	a0,0
    80004f46:	d77ff0ef          	jal	80004cbc <argfd>
    80004f4a:	87aa                	mv	a5,a0
    return -1;
    80004f4c:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80004f4e:	0007ca63          	bltz	a5,80004f62 <sys_write+0x40>
  return filewrite(f, p, n);
    80004f52:	fe442603          	lw	a2,-28(s0)
    80004f56:	fd843583          	ld	a1,-40(s0)
    80004f5a:	fe843503          	ld	a0,-24(s0)
    80004f5e:	d9eff0ef          	jal	800044fc <filewrite>
}
    80004f62:	70a2                	ld	ra,40(sp)
    80004f64:	7402                	ld	s0,32(sp)
    80004f66:	6145                	addi	sp,sp,48
    80004f68:	8082                	ret

0000000080004f6a <sys_close>:
{
    80004f6a:	1101                	addi	sp,sp,-32
    80004f6c:	ec06                	sd	ra,24(sp)
    80004f6e:	e822                	sd	s0,16(sp)
    80004f70:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    80004f72:	fe040613          	addi	a2,s0,-32
    80004f76:	fec40593          	addi	a1,s0,-20
    80004f7a:	4501                	li	a0,0
    80004f7c:	d41ff0ef          	jal	80004cbc <argfd>
    return -1;
    80004f80:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    80004f82:	02054163          	bltz	a0,80004fa4 <sys_close+0x3a>
  myproc()->ofile[fd] = 0;
    80004f86:	9f7fc0ef          	jal	8000197c <myproc>
    80004f8a:	fec42783          	lw	a5,-20(s0)
    80004f8e:	078e                	slli	a5,a5,0x3
    80004f90:	0d078793          	addi	a5,a5,208
    80004f94:	953e                	add	a0,a0,a5
    80004f96:	00053023          	sd	zero,0(a0)
  fileclose(f);
    80004f9a:	fe043503          	ld	a0,-32(s0)
    80004f9e:	b76ff0ef          	jal	80004314 <fileclose>
  return 0;
    80004fa2:	4781                	li	a5,0
}
    80004fa4:	853e                	mv	a0,a5
    80004fa6:	60e2                	ld	ra,24(sp)
    80004fa8:	6442                	ld	s0,16(sp)
    80004faa:	6105                	addi	sp,sp,32
    80004fac:	8082                	ret

0000000080004fae <sys_fstat>:
{
    80004fae:	1101                	addi	sp,sp,-32
    80004fb0:	ec06                	sd	ra,24(sp)
    80004fb2:	e822                	sd	s0,16(sp)
    80004fb4:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    80004fb6:	fe040593          	addi	a1,s0,-32
    80004fba:	4505                	li	a0,1
    80004fbc:	aa9fd0ef          	jal	80002a64 <argaddr>
  if(argfd(0, 0, &f) < 0)
    80004fc0:	fe840613          	addi	a2,s0,-24
    80004fc4:	4581                	li	a1,0
    80004fc6:	4501                	li	a0,0
    80004fc8:	cf5ff0ef          	jal	80004cbc <argfd>
    80004fcc:	87aa                	mv	a5,a0
    return -1;
    80004fce:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80004fd0:	0007c863          	bltz	a5,80004fe0 <sys_fstat+0x32>
  return filestat(f, st);
    80004fd4:	fe043583          	ld	a1,-32(s0)
    80004fd8:	fe843503          	ld	a0,-24(s0)
    80004fdc:	bfaff0ef          	jal	800043d6 <filestat>
}
    80004fe0:	60e2                	ld	ra,24(sp)
    80004fe2:	6442                	ld	s0,16(sp)
    80004fe4:	6105                	addi	sp,sp,32
    80004fe6:	8082                	ret

0000000080004fe8 <sys_link>:
{
    80004fe8:	7169                	addi	sp,sp,-304
    80004fea:	f606                	sd	ra,296(sp)
    80004fec:	f222                	sd	s0,288(sp)
    80004fee:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80004ff0:	08000613          	li	a2,128
    80004ff4:	ed040593          	addi	a1,s0,-304
    80004ff8:	4501                	li	a0,0
    80004ffa:	a87fd0ef          	jal	80002a80 <argstr>
    return -1;
    80004ffe:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005000:	0c054e63          	bltz	a0,800050dc <sys_link+0xf4>
    80005004:	08000613          	li	a2,128
    80005008:	f5040593          	addi	a1,s0,-176
    8000500c:	4505                	li	a0,1
    8000500e:	a73fd0ef          	jal	80002a80 <argstr>
    return -1;
    80005012:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005014:	0c054463          	bltz	a0,800050dc <sys_link+0xf4>
    80005018:	ee26                	sd	s1,280(sp)
  begin_op();
    8000501a:	ed7fe0ef          	jal	80003ef0 <begin_op>
  if((ip = namei(old)) == 0){
    8000501e:	ed040513          	addi	a0,s0,-304
    80005022:	cf1fe0ef          	jal	80003d12 <namei>
    80005026:	84aa                	mv	s1,a0
    80005028:	c53d                	beqz	a0,80005096 <sys_link+0xae>
  ilock(ip);
    8000502a:	cbafe0ef          	jal	800034e4 <ilock>
  if(ip->type == T_DIR){
    8000502e:	04449703          	lh	a4,68(s1)
    80005032:	4785                	li	a5,1
    80005034:	06f70663          	beq	a4,a5,800050a0 <sys_link+0xb8>
    80005038:	ea4a                	sd	s2,272(sp)
  ip->nlink++;
    8000503a:	04a4d783          	lhu	a5,74(s1)
    8000503e:	2785                	addiw	a5,a5,1
    80005040:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005044:	8526                	mv	a0,s1
    80005046:	beafe0ef          	jal	80003430 <iupdate>
  iunlock(ip);
    8000504a:	8526                	mv	a0,s1
    8000504c:	d46fe0ef          	jal	80003592 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    80005050:	fd040593          	addi	a1,s0,-48
    80005054:	f5040513          	addi	a0,s0,-176
    80005058:	cd5fe0ef          	jal	80003d2c <nameiparent>
    8000505c:	892a                	mv	s2,a0
    8000505e:	cd21                	beqz	a0,800050b6 <sys_link+0xce>
  ilock(dp);
    80005060:	c84fe0ef          	jal	800034e4 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    80005064:	854a                	mv	a0,s2
    80005066:	00092703          	lw	a4,0(s2)
    8000506a:	409c                	lw	a5,0(s1)
    8000506c:	04f71263          	bne	a4,a5,800050b0 <sys_link+0xc8>
    80005070:	40d0                	lw	a2,4(s1)
    80005072:	fd040593          	addi	a1,s0,-48
    80005076:	bf3fe0ef          	jal	80003c68 <dirlink>
    8000507a:	02054b63          	bltz	a0,800050b0 <sys_link+0xc8>
  iunlockput(dp);
    8000507e:	854a                	mv	a0,s2
    80005080:	e70fe0ef          	jal	800036f0 <iunlockput>
  iput(ip);
    80005084:	8526                	mv	a0,s1
    80005086:	de0fe0ef          	jal	80003666 <iput>
  end_op();
    8000508a:	ed7fe0ef          	jal	80003f60 <end_op>
  return 0;
    8000508e:	4781                	li	a5,0
    80005090:	64f2                	ld	s1,280(sp)
    80005092:	6952                	ld	s2,272(sp)
    80005094:	a0a1                	j	800050dc <sys_link+0xf4>
    end_op();
    80005096:	ecbfe0ef          	jal	80003f60 <end_op>
    return -1;
    8000509a:	57fd                	li	a5,-1
    8000509c:	64f2                	ld	s1,280(sp)
    8000509e:	a83d                	j	800050dc <sys_link+0xf4>
    iunlockput(ip);
    800050a0:	8526                	mv	a0,s1
    800050a2:	e4efe0ef          	jal	800036f0 <iunlockput>
    end_op();
    800050a6:	ebbfe0ef          	jal	80003f60 <end_op>
    return -1;
    800050aa:	57fd                	li	a5,-1
    800050ac:	64f2                	ld	s1,280(sp)
    800050ae:	a03d                	j	800050dc <sys_link+0xf4>
    iunlockput(dp);
    800050b0:	854a                	mv	a0,s2
    800050b2:	e3efe0ef          	jal	800036f0 <iunlockput>
  ilock(ip);
    800050b6:	8526                	mv	a0,s1
    800050b8:	c2cfe0ef          	jal	800034e4 <ilock>
  ip->nlink--;
    800050bc:	04a4d783          	lhu	a5,74(s1)
    800050c0:	37fd                	addiw	a5,a5,-1
    800050c2:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    800050c6:	8526                	mv	a0,s1
    800050c8:	b68fe0ef          	jal	80003430 <iupdate>
  iunlockput(ip);
    800050cc:	8526                	mv	a0,s1
    800050ce:	e22fe0ef          	jal	800036f0 <iunlockput>
  end_op();
    800050d2:	e8ffe0ef          	jal	80003f60 <end_op>
  return -1;
    800050d6:	57fd                	li	a5,-1
    800050d8:	64f2                	ld	s1,280(sp)
    800050da:	6952                	ld	s2,272(sp)
}
    800050dc:	853e                	mv	a0,a5
    800050de:	70b2                	ld	ra,296(sp)
    800050e0:	7412                	ld	s0,288(sp)
    800050e2:	6155                	addi	sp,sp,304
    800050e4:	8082                	ret

00000000800050e6 <sys_unlink>:
{
    800050e6:	7151                	addi	sp,sp,-240
    800050e8:	f586                	sd	ra,232(sp)
    800050ea:	f1a2                	sd	s0,224(sp)
    800050ec:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    800050ee:	08000613          	li	a2,128
    800050f2:	f3040593          	addi	a1,s0,-208
    800050f6:	4501                	li	a0,0
    800050f8:	989fd0ef          	jal	80002a80 <argstr>
    800050fc:	14054d63          	bltz	a0,80005256 <sys_unlink+0x170>
    80005100:	eda6                	sd	s1,216(sp)
  begin_op();
    80005102:	deffe0ef          	jal	80003ef0 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    80005106:	fb040593          	addi	a1,s0,-80
    8000510a:	f3040513          	addi	a0,s0,-208
    8000510e:	c1ffe0ef          	jal	80003d2c <nameiparent>
    80005112:	84aa                	mv	s1,a0
    80005114:	c955                	beqz	a0,800051c8 <sys_unlink+0xe2>
  ilock(dp);
    80005116:	bcefe0ef          	jal	800034e4 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    8000511a:	00003597          	auipc	a1,0x3
    8000511e:	4de58593          	addi	a1,a1,1246 # 800085f8 <etext+0x5f8>
    80005122:	fb040513          	addi	a0,s0,-80
    80005126:	943fe0ef          	jal	80003a68 <namecmp>
    8000512a:	10050b63          	beqz	a0,80005240 <sys_unlink+0x15a>
    8000512e:	00003597          	auipc	a1,0x3
    80005132:	4d258593          	addi	a1,a1,1234 # 80008600 <etext+0x600>
    80005136:	fb040513          	addi	a0,s0,-80
    8000513a:	92ffe0ef          	jal	80003a68 <namecmp>
    8000513e:	10050163          	beqz	a0,80005240 <sys_unlink+0x15a>
    80005142:	e9ca                	sd	s2,208(sp)
  if((ip = dirlookup(dp, name, &off)) == 0)
    80005144:	f2c40613          	addi	a2,s0,-212
    80005148:	fb040593          	addi	a1,s0,-80
    8000514c:	8526                	mv	a0,s1
    8000514e:	931fe0ef          	jal	80003a7e <dirlookup>
    80005152:	892a                	mv	s2,a0
    80005154:	0e050563          	beqz	a0,8000523e <sys_unlink+0x158>
    80005158:	e5ce                	sd	s3,200(sp)
  ilock(ip);
    8000515a:	b8afe0ef          	jal	800034e4 <ilock>
  if(ip->nlink < 1)
    8000515e:	04a91783          	lh	a5,74(s2)
    80005162:	06f05863          	blez	a5,800051d2 <sys_unlink+0xec>
  if(ip->type == T_DIR && !isdirempty(ip)){
    80005166:	04491703          	lh	a4,68(s2)
    8000516a:	4785                	li	a5,1
    8000516c:	06f70963          	beq	a4,a5,800051de <sys_unlink+0xf8>
  memset(&de, 0, sizeof(de));
    80005170:	fc040993          	addi	s3,s0,-64
    80005174:	4641                	li	a2,16
    80005176:	4581                	li	a1,0
    80005178:	854e                	mv	a0,s3
    8000517a:	bb1fb0ef          	jal	80000d2a <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000517e:	4741                	li	a4,16
    80005180:	f2c42683          	lw	a3,-212(s0)
    80005184:	864e                	mv	a2,s3
    80005186:	4581                	li	a1,0
    80005188:	8526                	mv	a0,s1
    8000518a:	fdefe0ef          	jal	80003968 <writei>
    8000518e:	47c1                	li	a5,16
    80005190:	08f51863          	bne	a0,a5,80005220 <sys_unlink+0x13a>
  if(ip->type == T_DIR){
    80005194:	04491703          	lh	a4,68(s2)
    80005198:	4785                	li	a5,1
    8000519a:	08f70963          	beq	a4,a5,8000522c <sys_unlink+0x146>
  iunlockput(dp);
    8000519e:	8526                	mv	a0,s1
    800051a0:	d50fe0ef          	jal	800036f0 <iunlockput>
  ip->nlink--;
    800051a4:	04a95783          	lhu	a5,74(s2)
    800051a8:	37fd                	addiw	a5,a5,-1
    800051aa:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    800051ae:	854a                	mv	a0,s2
    800051b0:	a80fe0ef          	jal	80003430 <iupdate>
  iunlockput(ip);
    800051b4:	854a                	mv	a0,s2
    800051b6:	d3afe0ef          	jal	800036f0 <iunlockput>
  end_op();
    800051ba:	da7fe0ef          	jal	80003f60 <end_op>
  return 0;
    800051be:	4501                	li	a0,0
    800051c0:	64ee                	ld	s1,216(sp)
    800051c2:	694e                	ld	s2,208(sp)
    800051c4:	69ae                	ld	s3,200(sp)
    800051c6:	a061                	j	8000524e <sys_unlink+0x168>
    end_op();
    800051c8:	d99fe0ef          	jal	80003f60 <end_op>
    return -1;
    800051cc:	557d                	li	a0,-1
    800051ce:	64ee                	ld	s1,216(sp)
    800051d0:	a8bd                	j	8000524e <sys_unlink+0x168>
    panic("unlink: nlink < 1");
    800051d2:	00003517          	auipc	a0,0x3
    800051d6:	43650513          	addi	a0,a0,1078 # 80008608 <etext+0x608>
    800051da:	e7cfb0ef          	jal	80000856 <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    800051de:	04c92703          	lw	a4,76(s2)
    800051e2:	02000793          	li	a5,32
    800051e6:	f8e7f5e3          	bgeu	a5,a4,80005170 <sys_unlink+0x8a>
    800051ea:	89be                	mv	s3,a5
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800051ec:	4741                	li	a4,16
    800051ee:	86ce                	mv	a3,s3
    800051f0:	f1840613          	addi	a2,s0,-232
    800051f4:	4581                	li	a1,0
    800051f6:	854a                	mv	a0,s2
    800051f8:	e7efe0ef          	jal	80003876 <readi>
    800051fc:	47c1                	li	a5,16
    800051fe:	00f51b63          	bne	a0,a5,80005214 <sys_unlink+0x12e>
    if(de.inum != 0)
    80005202:	f1845783          	lhu	a5,-232(s0)
    80005206:	ebb1                	bnez	a5,8000525a <sys_unlink+0x174>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005208:	29c1                	addiw	s3,s3,16
    8000520a:	04c92783          	lw	a5,76(s2)
    8000520e:	fcf9efe3          	bltu	s3,a5,800051ec <sys_unlink+0x106>
    80005212:	bfb9                	j	80005170 <sys_unlink+0x8a>
      panic("isdirempty: readi");
    80005214:	00003517          	auipc	a0,0x3
    80005218:	40c50513          	addi	a0,a0,1036 # 80008620 <etext+0x620>
    8000521c:	e3afb0ef          	jal	80000856 <panic>
    panic("unlink: writei");
    80005220:	00003517          	auipc	a0,0x3
    80005224:	41850513          	addi	a0,a0,1048 # 80008638 <etext+0x638>
    80005228:	e2efb0ef          	jal	80000856 <panic>
    dp->nlink--;
    8000522c:	04a4d783          	lhu	a5,74(s1)
    80005230:	37fd                	addiw	a5,a5,-1
    80005232:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80005236:	8526                	mv	a0,s1
    80005238:	9f8fe0ef          	jal	80003430 <iupdate>
    8000523c:	b78d                	j	8000519e <sys_unlink+0xb8>
    8000523e:	694e                	ld	s2,208(sp)
  iunlockput(dp);
    80005240:	8526                	mv	a0,s1
    80005242:	caefe0ef          	jal	800036f0 <iunlockput>
  end_op();
    80005246:	d1bfe0ef          	jal	80003f60 <end_op>
  return -1;
    8000524a:	557d                	li	a0,-1
    8000524c:	64ee                	ld	s1,216(sp)
}
    8000524e:	70ae                	ld	ra,232(sp)
    80005250:	740e                	ld	s0,224(sp)
    80005252:	616d                	addi	sp,sp,240
    80005254:	8082                	ret
    return -1;
    80005256:	557d                	li	a0,-1
    80005258:	bfdd                	j	8000524e <sys_unlink+0x168>
    iunlockput(ip);
    8000525a:	854a                	mv	a0,s2
    8000525c:	c94fe0ef          	jal	800036f0 <iunlockput>
    goto bad;
    80005260:	694e                	ld	s2,208(sp)
    80005262:	69ae                	ld	s3,200(sp)
    80005264:	bff1                	j	80005240 <sys_unlink+0x15a>

0000000080005266 <sys_open>:

uint64
sys_open(void)
{
    80005266:	7131                	addi	sp,sp,-192
    80005268:	fd06                	sd	ra,184(sp)
    8000526a:	f922                	sd	s0,176(sp)
    8000526c:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    8000526e:	f4c40593          	addi	a1,s0,-180
    80005272:	4505                	li	a0,1
    80005274:	fd4fd0ef          	jal	80002a48 <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    80005278:	08000613          	li	a2,128
    8000527c:	f5040593          	addi	a1,s0,-176
    80005280:	4501                	li	a0,0
    80005282:	ffefd0ef          	jal	80002a80 <argstr>
    80005286:	87aa                	mv	a5,a0
    return -1;
    80005288:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    8000528a:	0a07c363          	bltz	a5,80005330 <sys_open+0xca>
    8000528e:	f526                	sd	s1,168(sp)

  begin_op();
    80005290:	c61fe0ef          	jal	80003ef0 <begin_op>

  if(omode & O_CREATE){
    80005294:	f4c42783          	lw	a5,-180(s0)
    80005298:	2007f793          	andi	a5,a5,512
    8000529c:	c3dd                	beqz	a5,80005342 <sys_open+0xdc>
    ip = create(path, T_FILE, 0, 0);
    8000529e:	4681                	li	a3,0
    800052a0:	4601                	li	a2,0
    800052a2:	4589                	li	a1,2
    800052a4:	f5040513          	addi	a0,s0,-176
    800052a8:	aafff0ef          	jal	80004d56 <create>
    800052ac:	84aa                	mv	s1,a0
    if(ip == 0){
    800052ae:	c549                	beqz	a0,80005338 <sys_open+0xd2>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    800052b0:	04449703          	lh	a4,68(s1)
    800052b4:	478d                	li	a5,3
    800052b6:	00f71763          	bne	a4,a5,800052c4 <sys_open+0x5e>
    800052ba:	0464d703          	lhu	a4,70(s1)
    800052be:	47a5                	li	a5,9
    800052c0:	0ae7ee63          	bltu	a5,a4,8000537c <sys_open+0x116>
    800052c4:	f14a                	sd	s2,160(sp)
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    800052c6:	fabfe0ef          	jal	80004270 <filealloc>
    800052ca:	892a                	mv	s2,a0
    800052cc:	c561                	beqz	a0,80005394 <sys_open+0x12e>
    800052ce:	ed4e                	sd	s3,152(sp)
    800052d0:	a47ff0ef          	jal	80004d16 <fdalloc>
    800052d4:	89aa                	mv	s3,a0
    800052d6:	0a054b63          	bltz	a0,8000538c <sys_open+0x126>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    800052da:	04449703          	lh	a4,68(s1)
    800052de:	478d                	li	a5,3
    800052e0:	0cf70363          	beq	a4,a5,800053a6 <sys_open+0x140>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    800052e4:	4789                	li	a5,2
    800052e6:	00f92023          	sw	a5,0(s2)
    f->off = 0;
    800052ea:	02092023          	sw	zero,32(s2)
  }
  f->ip = ip;
    800052ee:	00993c23          	sd	s1,24(s2)
  f->readable = !(omode & O_WRONLY);
    800052f2:	f4c42783          	lw	a5,-180(s0)
    800052f6:	0017f713          	andi	a4,a5,1
    800052fa:	00174713          	xori	a4,a4,1
    800052fe:	00e90423          	sb	a4,8(s2)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80005302:	0037f713          	andi	a4,a5,3
    80005306:	00e03733          	snez	a4,a4
    8000530a:	00e904a3          	sb	a4,9(s2)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    8000530e:	4007f793          	andi	a5,a5,1024
    80005312:	c791                	beqz	a5,8000531e <sys_open+0xb8>
    80005314:	04449703          	lh	a4,68(s1)
    80005318:	4789                	li	a5,2
    8000531a:	08f70d63          	beq	a4,a5,800053b4 <sys_open+0x14e>
    itrunc(ip);
  }

  iunlock(ip);
    8000531e:	8526                	mv	a0,s1
    80005320:	a72fe0ef          	jal	80003592 <iunlock>
  end_op();
    80005324:	c3dfe0ef          	jal	80003f60 <end_op>

  return fd;
    80005328:	854e                	mv	a0,s3
    8000532a:	74aa                	ld	s1,168(sp)
    8000532c:	790a                	ld	s2,160(sp)
    8000532e:	69ea                	ld	s3,152(sp)
}
    80005330:	70ea                	ld	ra,184(sp)
    80005332:	744a                	ld	s0,176(sp)
    80005334:	6129                	addi	sp,sp,192
    80005336:	8082                	ret
      end_op();
    80005338:	c29fe0ef          	jal	80003f60 <end_op>
      return -1;
    8000533c:	557d                	li	a0,-1
    8000533e:	74aa                	ld	s1,168(sp)
    80005340:	bfc5                	j	80005330 <sys_open+0xca>
    if((ip = namei(path)) == 0){
    80005342:	f5040513          	addi	a0,s0,-176
    80005346:	9cdfe0ef          	jal	80003d12 <namei>
    8000534a:	84aa                	mv	s1,a0
    8000534c:	c11d                	beqz	a0,80005372 <sys_open+0x10c>
    ilock(ip);
    8000534e:	996fe0ef          	jal	800034e4 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80005352:	04449703          	lh	a4,68(s1)
    80005356:	4785                	li	a5,1
    80005358:	f4f71ce3          	bne	a4,a5,800052b0 <sys_open+0x4a>
    8000535c:	f4c42783          	lw	a5,-180(s0)
    80005360:	d3b5                	beqz	a5,800052c4 <sys_open+0x5e>
      iunlockput(ip);
    80005362:	8526                	mv	a0,s1
    80005364:	b8cfe0ef          	jal	800036f0 <iunlockput>
      end_op();
    80005368:	bf9fe0ef          	jal	80003f60 <end_op>
      return -1;
    8000536c:	557d                	li	a0,-1
    8000536e:	74aa                	ld	s1,168(sp)
    80005370:	b7c1                	j	80005330 <sys_open+0xca>
      end_op();
    80005372:	beffe0ef          	jal	80003f60 <end_op>
      return -1;
    80005376:	557d                	li	a0,-1
    80005378:	74aa                	ld	s1,168(sp)
    8000537a:	bf5d                	j	80005330 <sys_open+0xca>
    iunlockput(ip);
    8000537c:	8526                	mv	a0,s1
    8000537e:	b72fe0ef          	jal	800036f0 <iunlockput>
    end_op();
    80005382:	bdffe0ef          	jal	80003f60 <end_op>
    return -1;
    80005386:	557d                	li	a0,-1
    80005388:	74aa                	ld	s1,168(sp)
    8000538a:	b75d                	j	80005330 <sys_open+0xca>
      fileclose(f);
    8000538c:	854a                	mv	a0,s2
    8000538e:	f87fe0ef          	jal	80004314 <fileclose>
    80005392:	69ea                	ld	s3,152(sp)
    iunlockput(ip);
    80005394:	8526                	mv	a0,s1
    80005396:	b5afe0ef          	jal	800036f0 <iunlockput>
    end_op();
    8000539a:	bc7fe0ef          	jal	80003f60 <end_op>
    return -1;
    8000539e:	557d                	li	a0,-1
    800053a0:	74aa                	ld	s1,168(sp)
    800053a2:	790a                	ld	s2,160(sp)
    800053a4:	b771                	j	80005330 <sys_open+0xca>
    f->type = FD_DEVICE;
    800053a6:	00e92023          	sw	a4,0(s2)
    f->major = ip->major;
    800053aa:	04649783          	lh	a5,70(s1)
    800053ae:	02f91223          	sh	a5,36(s2)
    800053b2:	bf35                	j	800052ee <sys_open+0x88>
    itrunc(ip);
    800053b4:	8526                	mv	a0,s1
    800053b6:	a1cfe0ef          	jal	800035d2 <itrunc>
    800053ba:	b795                	j	8000531e <sys_open+0xb8>

00000000800053bc <sys_mkdir>:

uint64
sys_mkdir(void)
{
    800053bc:	7175                	addi	sp,sp,-144
    800053be:	e506                	sd	ra,136(sp)
    800053c0:	e122                	sd	s0,128(sp)
    800053c2:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    800053c4:	b2dfe0ef          	jal	80003ef0 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    800053c8:	08000613          	li	a2,128
    800053cc:	f7040593          	addi	a1,s0,-144
    800053d0:	4501                	li	a0,0
    800053d2:	eaefd0ef          	jal	80002a80 <argstr>
    800053d6:	02054363          	bltz	a0,800053fc <sys_mkdir+0x40>
    800053da:	4681                	li	a3,0
    800053dc:	4601                	li	a2,0
    800053de:	4585                	li	a1,1
    800053e0:	f7040513          	addi	a0,s0,-144
    800053e4:	973ff0ef          	jal	80004d56 <create>
    800053e8:	c911                	beqz	a0,800053fc <sys_mkdir+0x40>
    end_op();
    return -1;
  }
  iunlockput(ip);
    800053ea:	b06fe0ef          	jal	800036f0 <iunlockput>
  end_op();
    800053ee:	b73fe0ef          	jal	80003f60 <end_op>
  return 0;
    800053f2:	4501                	li	a0,0
}
    800053f4:	60aa                	ld	ra,136(sp)
    800053f6:	640a                	ld	s0,128(sp)
    800053f8:	6149                	addi	sp,sp,144
    800053fa:	8082                	ret
    end_op();
    800053fc:	b65fe0ef          	jal	80003f60 <end_op>
    return -1;
    80005400:	557d                	li	a0,-1
    80005402:	bfcd                	j	800053f4 <sys_mkdir+0x38>

0000000080005404 <sys_mknod>:

uint64
sys_mknod(void)
{
    80005404:	7135                	addi	sp,sp,-160
    80005406:	ed06                	sd	ra,152(sp)
    80005408:	e922                	sd	s0,144(sp)
    8000540a:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    8000540c:	ae5fe0ef          	jal	80003ef0 <begin_op>
  argint(1, &major);
    80005410:	f6c40593          	addi	a1,s0,-148
    80005414:	4505                	li	a0,1
    80005416:	e32fd0ef          	jal	80002a48 <argint>
  argint(2, &minor);
    8000541a:	f6840593          	addi	a1,s0,-152
    8000541e:	4509                	li	a0,2
    80005420:	e28fd0ef          	jal	80002a48 <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005424:	08000613          	li	a2,128
    80005428:	f7040593          	addi	a1,s0,-144
    8000542c:	4501                	li	a0,0
    8000542e:	e52fd0ef          	jal	80002a80 <argstr>
    80005432:	02054563          	bltz	a0,8000545c <sys_mknod+0x58>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80005436:	f6841683          	lh	a3,-152(s0)
    8000543a:	f6c41603          	lh	a2,-148(s0)
    8000543e:	458d                	li	a1,3
    80005440:	f7040513          	addi	a0,s0,-144
    80005444:	913ff0ef          	jal	80004d56 <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005448:	c911                	beqz	a0,8000545c <sys_mknod+0x58>
    end_op();
    return -1;
  }
  iunlockput(ip);
    8000544a:	aa6fe0ef          	jal	800036f0 <iunlockput>
  end_op();
    8000544e:	b13fe0ef          	jal	80003f60 <end_op>
  return 0;
    80005452:	4501                	li	a0,0
}
    80005454:	60ea                	ld	ra,152(sp)
    80005456:	644a                	ld	s0,144(sp)
    80005458:	610d                	addi	sp,sp,160
    8000545a:	8082                	ret
    end_op();
    8000545c:	b05fe0ef          	jal	80003f60 <end_op>
    return -1;
    80005460:	557d                	li	a0,-1
    80005462:	bfcd                	j	80005454 <sys_mknod+0x50>

0000000080005464 <sys_chdir>:

uint64
sys_chdir(void)
{
    80005464:	7135                	addi	sp,sp,-160
    80005466:	ed06                	sd	ra,152(sp)
    80005468:	e922                	sd	s0,144(sp)
    8000546a:	e14a                	sd	s2,128(sp)
    8000546c:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    8000546e:	d0efc0ef          	jal	8000197c <myproc>
    80005472:	892a                	mv	s2,a0
  
  begin_op();
    80005474:	a7dfe0ef          	jal	80003ef0 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80005478:	08000613          	li	a2,128
    8000547c:	f6040593          	addi	a1,s0,-160
    80005480:	4501                	li	a0,0
    80005482:	dfefd0ef          	jal	80002a80 <argstr>
    80005486:	04054363          	bltz	a0,800054cc <sys_chdir+0x68>
    8000548a:	e526                	sd	s1,136(sp)
    8000548c:	f6040513          	addi	a0,s0,-160
    80005490:	883fe0ef          	jal	80003d12 <namei>
    80005494:	84aa                	mv	s1,a0
    80005496:	c915                	beqz	a0,800054ca <sys_chdir+0x66>
    end_op();
    return -1;
  }
  ilock(ip);
    80005498:	84cfe0ef          	jal	800034e4 <ilock>
  if(ip->type != T_DIR){
    8000549c:	04449703          	lh	a4,68(s1)
    800054a0:	4785                	li	a5,1
    800054a2:	02f71963          	bne	a4,a5,800054d4 <sys_chdir+0x70>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    800054a6:	8526                	mv	a0,s1
    800054a8:	8eafe0ef          	jal	80003592 <iunlock>
  iput(p->cwd);
    800054ac:	15093503          	ld	a0,336(s2)
    800054b0:	9b6fe0ef          	jal	80003666 <iput>
  end_op();
    800054b4:	aadfe0ef          	jal	80003f60 <end_op>
  p->cwd = ip;
    800054b8:	14993823          	sd	s1,336(s2)
  return 0;
    800054bc:	4501                	li	a0,0
    800054be:	64aa                	ld	s1,136(sp)
}
    800054c0:	60ea                	ld	ra,152(sp)
    800054c2:	644a                	ld	s0,144(sp)
    800054c4:	690a                	ld	s2,128(sp)
    800054c6:	610d                	addi	sp,sp,160
    800054c8:	8082                	ret
    800054ca:	64aa                	ld	s1,136(sp)
    end_op();
    800054cc:	a95fe0ef          	jal	80003f60 <end_op>
    return -1;
    800054d0:	557d                	li	a0,-1
    800054d2:	b7fd                	j	800054c0 <sys_chdir+0x5c>
    iunlockput(ip);
    800054d4:	8526                	mv	a0,s1
    800054d6:	a1afe0ef          	jal	800036f0 <iunlockput>
    end_op();
    800054da:	a87fe0ef          	jal	80003f60 <end_op>
    return -1;
    800054de:	557d                	li	a0,-1
    800054e0:	64aa                	ld	s1,136(sp)
    800054e2:	bff9                	j	800054c0 <sys_chdir+0x5c>

00000000800054e4 <sys_exec>:

uint64
sys_exec(void)
{
    800054e4:	7105                	addi	sp,sp,-480
    800054e6:	ef86                	sd	ra,472(sp)
    800054e8:	eba2                	sd	s0,464(sp)
    800054ea:	1380                	addi	s0,sp,480
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    800054ec:	e2840593          	addi	a1,s0,-472
    800054f0:	4505                	li	a0,1
    800054f2:	d72fd0ef          	jal	80002a64 <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    800054f6:	08000613          	li	a2,128
    800054fa:	f3040593          	addi	a1,s0,-208
    800054fe:	4501                	li	a0,0
    80005500:	d80fd0ef          	jal	80002a80 <argstr>
    80005504:	87aa                	mv	a5,a0
    return -1;
    80005506:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    80005508:	0e07c063          	bltz	a5,800055e8 <sys_exec+0x104>
    8000550c:	e7a6                	sd	s1,456(sp)
    8000550e:	e3ca                	sd	s2,448(sp)
    80005510:	ff4e                	sd	s3,440(sp)
    80005512:	fb52                	sd	s4,432(sp)
    80005514:	f756                	sd	s5,424(sp)
    80005516:	f35a                	sd	s6,416(sp)
    80005518:	ef5e                	sd	s7,408(sp)
  }
  memset(argv, 0, sizeof(argv));
    8000551a:	e3040a13          	addi	s4,s0,-464
    8000551e:	10000613          	li	a2,256
    80005522:	4581                	li	a1,0
    80005524:	8552                	mv	a0,s4
    80005526:	805fb0ef          	jal	80000d2a <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    8000552a:	84d2                	mv	s1,s4
  memset(argv, 0, sizeof(argv));
    8000552c:	89d2                	mv	s3,s4
    8000552e:	4901                	li	s2,0
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80005530:	e2040a93          	addi	s5,s0,-480
      break;
    }
    argv[i] = kalloc();
    if(argv[i] == 0)
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80005534:	6b05                	lui	s6,0x1
    if(i >= NELEM(argv)){
    80005536:	02000b93          	li	s7,32
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    8000553a:	00391513          	slli	a0,s2,0x3
    8000553e:	85d6                	mv	a1,s5
    80005540:	e2843783          	ld	a5,-472(s0)
    80005544:	953e                	add	a0,a0,a5
    80005546:	c78fd0ef          	jal	800029be <fetchaddr>
    8000554a:	02054663          	bltz	a0,80005576 <sys_exec+0x92>
    if(uarg == 0){
    8000554e:	e2043783          	ld	a5,-480(s0)
    80005552:	c7a1                	beqz	a5,8000559a <sys_exec+0xb6>
    argv[i] = kalloc();
    80005554:	e22fb0ef          	jal	80000b76 <kalloc>
    80005558:	85aa                	mv	a1,a0
    8000555a:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    8000555e:	cd01                	beqz	a0,80005576 <sys_exec+0x92>
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80005560:	865a                	mv	a2,s6
    80005562:	e2043503          	ld	a0,-480(s0)
    80005566:	ca2fd0ef          	jal	80002a08 <fetchstr>
    8000556a:	00054663          	bltz	a0,80005576 <sys_exec+0x92>
    if(i >= NELEM(argv)){
    8000556e:	0905                	addi	s2,s2,1
    80005570:	09a1                	addi	s3,s3,8
    80005572:	fd7914e3          	bne	s2,s7,8000553a <sys_exec+0x56>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005576:	100a0a13          	addi	s4,s4,256
    8000557a:	6088                	ld	a0,0(s1)
    8000557c:	cd31                	beqz	a0,800055d8 <sys_exec+0xf4>
    kfree(argv[i]);
    8000557e:	d10fb0ef          	jal	80000a8e <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005582:	04a1                	addi	s1,s1,8
    80005584:	ff449be3          	bne	s1,s4,8000557a <sys_exec+0x96>
  return -1;
    80005588:	557d                	li	a0,-1
    8000558a:	64be                	ld	s1,456(sp)
    8000558c:	691e                	ld	s2,448(sp)
    8000558e:	79fa                	ld	s3,440(sp)
    80005590:	7a5a                	ld	s4,432(sp)
    80005592:	7aba                	ld	s5,424(sp)
    80005594:	7b1a                	ld	s6,416(sp)
    80005596:	6bfa                	ld	s7,408(sp)
    80005598:	a881                	j	800055e8 <sys_exec+0x104>
      argv[i] = 0;
    8000559a:	0009079b          	sext.w	a5,s2
    8000559e:	e3040593          	addi	a1,s0,-464
    800055a2:	078e                	slli	a5,a5,0x3
    800055a4:	97ae                	add	a5,a5,a1
    800055a6:	0007b023          	sd	zero,0(a5)
  int ret = kexec(path, argv);
    800055aa:	f3040513          	addi	a0,s0,-208
    800055ae:	bb2ff0ef          	jal	80004960 <kexec>
    800055b2:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800055b4:	100a0a13          	addi	s4,s4,256
    800055b8:	6088                	ld	a0,0(s1)
    800055ba:	c511                	beqz	a0,800055c6 <sys_exec+0xe2>
    kfree(argv[i]);
    800055bc:	cd2fb0ef          	jal	80000a8e <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800055c0:	04a1                	addi	s1,s1,8
    800055c2:	ff449be3          	bne	s1,s4,800055b8 <sys_exec+0xd4>
  return ret;
    800055c6:	854a                	mv	a0,s2
    800055c8:	64be                	ld	s1,456(sp)
    800055ca:	691e                	ld	s2,448(sp)
    800055cc:	79fa                	ld	s3,440(sp)
    800055ce:	7a5a                	ld	s4,432(sp)
    800055d0:	7aba                	ld	s5,424(sp)
    800055d2:	7b1a                	ld	s6,416(sp)
    800055d4:	6bfa                	ld	s7,408(sp)
    800055d6:	a809                	j	800055e8 <sys_exec+0x104>
  return -1;
    800055d8:	557d                	li	a0,-1
    800055da:	64be                	ld	s1,456(sp)
    800055dc:	691e                	ld	s2,448(sp)
    800055de:	79fa                	ld	s3,440(sp)
    800055e0:	7a5a                	ld	s4,432(sp)
    800055e2:	7aba                	ld	s5,424(sp)
    800055e4:	7b1a                	ld	s6,416(sp)
    800055e6:	6bfa                	ld	s7,408(sp)
}
    800055e8:	60fe                	ld	ra,472(sp)
    800055ea:	645e                	ld	s0,464(sp)
    800055ec:	613d                	addi	sp,sp,480
    800055ee:	8082                	ret

00000000800055f0 <sys_pipe>:

uint64
sys_pipe(void)
{
    800055f0:	7139                	addi	sp,sp,-64
    800055f2:	fc06                	sd	ra,56(sp)
    800055f4:	f822                	sd	s0,48(sp)
    800055f6:	f426                	sd	s1,40(sp)
    800055f8:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    800055fa:	b82fc0ef          	jal	8000197c <myproc>
    800055fe:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    80005600:	fd840593          	addi	a1,s0,-40
    80005604:	4501                	li	a0,0
    80005606:	c5efd0ef          	jal	80002a64 <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    8000560a:	fc840593          	addi	a1,s0,-56
    8000560e:	fd040513          	addi	a0,s0,-48
    80005612:	81eff0ef          	jal	80004630 <pipealloc>
    return -1;
    80005616:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80005618:	0a054763          	bltz	a0,800056c6 <sys_pipe+0xd6>
  fd0 = -1;
    8000561c:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80005620:	fd043503          	ld	a0,-48(s0)
    80005624:	ef2ff0ef          	jal	80004d16 <fdalloc>
    80005628:	fca42223          	sw	a0,-60(s0)
    8000562c:	08054463          	bltz	a0,800056b4 <sys_pipe+0xc4>
    80005630:	fc843503          	ld	a0,-56(s0)
    80005634:	ee2ff0ef          	jal	80004d16 <fdalloc>
    80005638:	fca42023          	sw	a0,-64(s0)
    8000563c:	06054263          	bltz	a0,800056a0 <sys_pipe+0xb0>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005640:	4691                	li	a3,4
    80005642:	fc440613          	addi	a2,s0,-60
    80005646:	fd843583          	ld	a1,-40(s0)
    8000564a:	68a8                	ld	a0,80(s1)
    8000564c:	842fc0ef          	jal	8000168e <copyout>
    80005650:	00054e63          	bltz	a0,8000566c <sys_pipe+0x7c>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80005654:	4691                	li	a3,4
    80005656:	fc040613          	addi	a2,s0,-64
    8000565a:	fd843583          	ld	a1,-40(s0)
    8000565e:	95b6                	add	a1,a1,a3
    80005660:	68a8                	ld	a0,80(s1)
    80005662:	82cfc0ef          	jal	8000168e <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80005666:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005668:	04055f63          	bgez	a0,800056c6 <sys_pipe+0xd6>
    p->ofile[fd0] = 0;
    8000566c:	fc442783          	lw	a5,-60(s0)
    80005670:	078e                	slli	a5,a5,0x3
    80005672:	0d078793          	addi	a5,a5,208
    80005676:	97a6                	add	a5,a5,s1
    80005678:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    8000567c:	fc042783          	lw	a5,-64(s0)
    80005680:	078e                	slli	a5,a5,0x3
    80005682:	0d078793          	addi	a5,a5,208
    80005686:	97a6                	add	a5,a5,s1
    80005688:	0007b023          	sd	zero,0(a5)
    fileclose(rf);
    8000568c:	fd043503          	ld	a0,-48(s0)
    80005690:	c85fe0ef          	jal	80004314 <fileclose>
    fileclose(wf);
    80005694:	fc843503          	ld	a0,-56(s0)
    80005698:	c7dfe0ef          	jal	80004314 <fileclose>
    return -1;
    8000569c:	57fd                	li	a5,-1
    8000569e:	a025                	j	800056c6 <sys_pipe+0xd6>
    if(fd0 >= 0)
    800056a0:	fc442783          	lw	a5,-60(s0)
    800056a4:	0007c863          	bltz	a5,800056b4 <sys_pipe+0xc4>
      p->ofile[fd0] = 0;
    800056a8:	078e                	slli	a5,a5,0x3
    800056aa:	0d078793          	addi	a5,a5,208
    800056ae:	97a6                	add	a5,a5,s1
    800056b0:	0007b023          	sd	zero,0(a5)
    fileclose(rf);
    800056b4:	fd043503          	ld	a0,-48(s0)
    800056b8:	c5dfe0ef          	jal	80004314 <fileclose>
    fileclose(wf);
    800056bc:	fc843503          	ld	a0,-56(s0)
    800056c0:	c55fe0ef          	jal	80004314 <fileclose>
    return -1;
    800056c4:	57fd                	li	a5,-1
}
    800056c6:	853e                	mv	a0,a5
    800056c8:	70e2                	ld	ra,56(sp)
    800056ca:	7442                	ld	s0,48(sp)
    800056cc:	74a2                	ld	s1,40(sp)
    800056ce:	6121                	addi	sp,sp,64
    800056d0:	8082                	ret

00000000800056d2 <sys_fsread>:
uint64
sys_fsread(void)
{
    800056d2:	1101                	addi	sp,sp,-32
    800056d4:	ec06                	sd	ra,24(sp)
    800056d6:	e822                	sd	s0,16(sp)
    800056d8:	1000                	addi	s0,sp,32
  uint64 addr;
  int n;

  // استدعاء الدوال بدون مقارنتها بـ < 0 لأنها تعيد void
  argaddr(0, &addr); 
    800056da:	fe840593          	addi	a1,s0,-24
    800056de:	4501                	li	a0,0
    800056e0:	b84fd0ef          	jal	80002a64 <argaddr>
  argint(1, &n);
    800056e4:	fe440593          	addi	a1,s0,-28
    800056e8:	4505                	li	a0,1
    800056ea:	b5efd0ef          	jal	80002a48 <argint>

  // استدعاء الوظيفة الحقيقية وإعادة نتيجتها
  return fslog_read_many((struct fs_event *)addr, n);
    800056ee:	fe442583          	lw	a1,-28(s0)
    800056f2:	fe843503          	ld	a0,-24(s0)
    800056f6:	207000ef          	jal	800060fc <fslog_read_many>
    800056fa:	60e2                	ld	ra,24(sp)
    800056fc:	6442                	ld	s0,16(sp)
    800056fe:	6105                	addi	sp,sp,32
    80005700:	8082                	ret
	...

0000000080005710 <kernelvec>:
.globl kerneltrap
.globl kernelvec
.align 4
kernelvec:
        # make room to save registers.
        addi sp, sp, -256
    80005710:	7111                	addi	sp,sp,-256

        # save caller-saved registers.
        sd ra, 0(sp)
    80005712:	e006                	sd	ra,0(sp)
        # sd sp, 8(sp)
        sd gp, 16(sp)
    80005714:	e80e                	sd	gp,16(sp)
        sd tp, 24(sp)
    80005716:	ec12                	sd	tp,24(sp)
        sd t0, 32(sp)
    80005718:	f016                	sd	t0,32(sp)
        sd t1, 40(sp)
    8000571a:	f41a                	sd	t1,40(sp)
        sd t2, 48(sp)
    8000571c:	f81e                	sd	t2,48(sp)
        sd a0, 72(sp)
    8000571e:	e4aa                	sd	a0,72(sp)
        sd a1, 80(sp)
    80005720:	e8ae                	sd	a1,80(sp)
        sd a2, 88(sp)
    80005722:	ecb2                	sd	a2,88(sp)
        sd a3, 96(sp)
    80005724:	f0b6                	sd	a3,96(sp)
        sd a4, 104(sp)
    80005726:	f4ba                	sd	a4,104(sp)
        sd a5, 112(sp)
    80005728:	f8be                	sd	a5,112(sp)
        sd a6, 120(sp)
    8000572a:	fcc2                	sd	a6,120(sp)
        sd a7, 128(sp)
    8000572c:	e146                	sd	a7,128(sp)
        sd t3, 216(sp)
    8000572e:	edf2                	sd	t3,216(sp)
        sd t4, 224(sp)
    80005730:	f1f6                	sd	t4,224(sp)
        sd t5, 232(sp)
    80005732:	f5fa                	sd	t5,232(sp)
        sd t6, 240(sp)
    80005734:	f9fe                	sd	t6,240(sp)

        # call the C trap handler in trap.c
        call kerneltrap
    80005736:	996fd0ef          	jal	800028cc <kerneltrap>

        # restore registers.
        ld ra, 0(sp)
    8000573a:	6082                	ld	ra,0(sp)
        # ld sp, 8(sp)
        ld gp, 16(sp)
    8000573c:	61c2                	ld	gp,16(sp)
        # not tp (contains hartid), in case we moved CPUs
        ld t0, 32(sp)
    8000573e:	7282                	ld	t0,32(sp)
        ld t1, 40(sp)
    80005740:	7322                	ld	t1,40(sp)
        ld t2, 48(sp)
    80005742:	73c2                	ld	t2,48(sp)
        ld a0, 72(sp)
    80005744:	6526                	ld	a0,72(sp)
        ld a1, 80(sp)
    80005746:	65c6                	ld	a1,80(sp)
        ld a2, 88(sp)
    80005748:	6666                	ld	a2,88(sp)
        ld a3, 96(sp)
    8000574a:	7686                	ld	a3,96(sp)
        ld a4, 104(sp)
    8000574c:	7726                	ld	a4,104(sp)
        ld a5, 112(sp)
    8000574e:	77c6                	ld	a5,112(sp)
        ld a6, 120(sp)
    80005750:	7866                	ld	a6,120(sp)
        ld a7, 128(sp)
    80005752:	688a                	ld	a7,128(sp)
        ld t3, 216(sp)
    80005754:	6e6e                	ld	t3,216(sp)
        ld t4, 224(sp)
    80005756:	7e8e                	ld	t4,224(sp)
        ld t5, 232(sp)
    80005758:	7f2e                	ld	t5,232(sp)
        ld t6, 240(sp)
    8000575a:	7fce                	ld	t6,240(sp)

        addi sp, sp, 256
    8000575c:	6111                	addi	sp,sp,256

        # return to whatever we were doing in the kernel.
        sret
    8000575e:	10200073          	sret
    80005762:	00000013          	nop
    80005766:	00000013          	nop
    8000576a:	00000013          	nop

000000008000576e <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    8000576e:	1141                	addi	sp,sp,-16
    80005770:	e406                	sd	ra,8(sp)
    80005772:	e022                	sd	s0,0(sp)
    80005774:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80005776:	0c000737          	lui	a4,0xc000
    8000577a:	4785                	li	a5,1
    8000577c:	d71c                	sw	a5,40(a4)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    8000577e:	c35c                	sw	a5,4(a4)
}
    80005780:	60a2                	ld	ra,8(sp)
    80005782:	6402                	ld	s0,0(sp)
    80005784:	0141                	addi	sp,sp,16
    80005786:	8082                	ret

0000000080005788 <plicinithart>:

void
plicinithart(void)
{
    80005788:	1141                	addi	sp,sp,-16
    8000578a:	e406                	sd	ra,8(sp)
    8000578c:	e022                	sd	s0,0(sp)
    8000578e:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005790:	9b8fc0ef          	jal	80001948 <cpuid>
  
  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80005794:	0085171b          	slliw	a4,a0,0x8
    80005798:	0c0027b7          	lui	a5,0xc002
    8000579c:	97ba                	add	a5,a5,a4
    8000579e:	40200713          	li	a4,1026
    800057a2:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    800057a6:	00d5151b          	slliw	a0,a0,0xd
    800057aa:	0c2017b7          	lui	a5,0xc201
    800057ae:	97aa                	add	a5,a5,a0
    800057b0:	0007a023          	sw	zero,0(a5) # c201000 <_entry-0x73dff000>
}
    800057b4:	60a2                	ld	ra,8(sp)
    800057b6:	6402                	ld	s0,0(sp)
    800057b8:	0141                	addi	sp,sp,16
    800057ba:	8082                	ret

00000000800057bc <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    800057bc:	1141                	addi	sp,sp,-16
    800057be:	e406                	sd	ra,8(sp)
    800057c0:	e022                	sd	s0,0(sp)
    800057c2:	0800                	addi	s0,sp,16
  int hart = cpuid();
    800057c4:	984fc0ef          	jal	80001948 <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    800057c8:	00d5151b          	slliw	a0,a0,0xd
    800057cc:	0c2017b7          	lui	a5,0xc201
    800057d0:	97aa                	add	a5,a5,a0
  return irq;
}
    800057d2:	43c8                	lw	a0,4(a5)
    800057d4:	60a2                	ld	ra,8(sp)
    800057d6:	6402                	ld	s0,0(sp)
    800057d8:	0141                	addi	sp,sp,16
    800057da:	8082                	ret

00000000800057dc <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    800057dc:	1101                	addi	sp,sp,-32
    800057de:	ec06                	sd	ra,24(sp)
    800057e0:	e822                	sd	s0,16(sp)
    800057e2:	e426                	sd	s1,8(sp)
    800057e4:	1000                	addi	s0,sp,32
    800057e6:	84aa                	mv	s1,a0
  int hart = cpuid();
    800057e8:	960fc0ef          	jal	80001948 <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    800057ec:	00d5179b          	slliw	a5,a0,0xd
    800057f0:	0c201737          	lui	a4,0xc201
    800057f4:	97ba                	add	a5,a5,a4
    800057f6:	c3c4                	sw	s1,4(a5)
}
    800057f8:	60e2                	ld	ra,24(sp)
    800057fa:	6442                	ld	s0,16(sp)
    800057fc:	64a2                	ld	s1,8(sp)
    800057fe:	6105                	addi	sp,sp,32
    80005800:	8082                	ret

0000000080005802 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80005802:	1141                	addi	sp,sp,-16
    80005804:	e406                	sd	ra,8(sp)
    80005806:	e022                	sd	s0,0(sp)
    80005808:	0800                	addi	s0,sp,16
  if(i >= NUM)
    8000580a:	479d                	li	a5,7
    8000580c:	04a7ca63          	blt	a5,a0,80005860 <free_desc+0x5e>
    panic("free_desc 1");
  if(disk.free[i])
    80005810:	0001f797          	auipc	a5,0x1f
    80005814:	09078793          	addi	a5,a5,144 # 800248a0 <disk>
    80005818:	97aa                	add	a5,a5,a0
    8000581a:	0187c783          	lbu	a5,24(a5)
    8000581e:	e7b9                	bnez	a5,8000586c <free_desc+0x6a>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    80005820:	00451693          	slli	a3,a0,0x4
    80005824:	0001f797          	auipc	a5,0x1f
    80005828:	07c78793          	addi	a5,a5,124 # 800248a0 <disk>
    8000582c:	6398                	ld	a4,0(a5)
    8000582e:	9736                	add	a4,a4,a3
    80005830:	00073023          	sd	zero,0(a4) # c201000 <_entry-0x73dff000>
  disk.desc[i].len = 0;
    80005834:	6398                	ld	a4,0(a5)
    80005836:	9736                	add	a4,a4,a3
    80005838:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    8000583c:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    80005840:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    80005844:	97aa                	add	a5,a5,a0
    80005846:	4705                	li	a4,1
    80005848:	00e78c23          	sb	a4,24(a5)
  wakeup(&disk.free[0]);
    8000584c:	0001f517          	auipc	a0,0x1f
    80005850:	06c50513          	addi	a0,a0,108 # 800248b8 <disk+0x18>
    80005854:	935fc0ef          	jal	80002188 <wakeup>
}
    80005858:	60a2                	ld	ra,8(sp)
    8000585a:	6402                	ld	s0,0(sp)
    8000585c:	0141                	addi	sp,sp,16
    8000585e:	8082                	ret
    panic("free_desc 1");
    80005860:	00003517          	auipc	a0,0x3
    80005864:	de850513          	addi	a0,a0,-536 # 80008648 <etext+0x648>
    80005868:	feffa0ef          	jal	80000856 <panic>
    panic("free_desc 2");
    8000586c:	00003517          	auipc	a0,0x3
    80005870:	dec50513          	addi	a0,a0,-532 # 80008658 <etext+0x658>
    80005874:	fe3fa0ef          	jal	80000856 <panic>

0000000080005878 <virtio_disk_init>:
{
    80005878:	1101                	addi	sp,sp,-32
    8000587a:	ec06                	sd	ra,24(sp)
    8000587c:	e822                	sd	s0,16(sp)
    8000587e:	e426                	sd	s1,8(sp)
    80005880:	e04a                	sd	s2,0(sp)
    80005882:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80005884:	00003597          	auipc	a1,0x3
    80005888:	de458593          	addi	a1,a1,-540 # 80008668 <etext+0x668>
    8000588c:	0001f517          	auipc	a0,0x1f
    80005890:	13c50513          	addi	a0,a0,316 # 800249c8 <disk+0x128>
    80005894:	b3cfb0ef          	jal	80000bd0 <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005898:	100017b7          	lui	a5,0x10001
    8000589c:	4398                	lw	a4,0(a5)
    8000589e:	2701                	sext.w	a4,a4
    800058a0:	747277b7          	lui	a5,0x74727
    800058a4:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    800058a8:	14f71863          	bne	a4,a5,800059f8 <virtio_disk_init+0x180>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    800058ac:	100017b7          	lui	a5,0x10001
    800058b0:	43dc                	lw	a5,4(a5)
    800058b2:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    800058b4:	4709                	li	a4,2
    800058b6:	14e79163          	bne	a5,a4,800059f8 <virtio_disk_init+0x180>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    800058ba:	100017b7          	lui	a5,0x10001
    800058be:	479c                	lw	a5,8(a5)
    800058c0:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    800058c2:	12e79b63          	bne	a5,a4,800059f8 <virtio_disk_init+0x180>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    800058c6:	100017b7          	lui	a5,0x10001
    800058ca:	47d8                	lw	a4,12(a5)
    800058cc:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    800058ce:	554d47b7          	lui	a5,0x554d4
    800058d2:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    800058d6:	12f71163          	bne	a4,a5,800059f8 <virtio_disk_init+0x180>
  *R(VIRTIO_MMIO_STATUS) = status;
    800058da:	100017b7          	lui	a5,0x10001
    800058de:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    800058e2:	4705                	li	a4,1
    800058e4:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    800058e6:	470d                	li	a4,3
    800058e8:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    800058ea:	10001737          	lui	a4,0x10001
    800058ee:	4b18                	lw	a4,16(a4)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    800058f0:	c7ffe6b7          	lui	a3,0xc7ffe
    800058f4:	75f68693          	addi	a3,a3,1887 # ffffffffc7ffe75f <end+0xffffffff47fc1cef>
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    800058f8:	8f75                	and	a4,a4,a3
    800058fa:	100016b7          	lui	a3,0x10001
    800058fe:	d298                	sw	a4,32(a3)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005900:	472d                	li	a4,11
    80005902:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005904:	07078793          	addi	a5,a5,112
  status = *R(VIRTIO_MMIO_STATUS);
    80005908:	439c                	lw	a5,0(a5)
    8000590a:	0007891b          	sext.w	s2,a5
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    8000590e:	8ba1                	andi	a5,a5,8
    80005910:	0e078a63          	beqz	a5,80005a04 <virtio_disk_init+0x18c>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80005914:	100017b7          	lui	a5,0x10001
    80005918:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    8000591c:	43fc                	lw	a5,68(a5)
    8000591e:	2781                	sext.w	a5,a5
    80005920:	0e079863          	bnez	a5,80005a10 <virtio_disk_init+0x198>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    80005924:	100017b7          	lui	a5,0x10001
    80005928:	5bdc                	lw	a5,52(a5)
    8000592a:	2781                	sext.w	a5,a5
  if(max == 0)
    8000592c:	0e078863          	beqz	a5,80005a1c <virtio_disk_init+0x1a4>
  if(max < NUM)
    80005930:	471d                	li	a4,7
    80005932:	0ef77b63          	bgeu	a4,a5,80005a28 <virtio_disk_init+0x1b0>
  disk.desc = kalloc();
    80005936:	a40fb0ef          	jal	80000b76 <kalloc>
    8000593a:	0001f497          	auipc	s1,0x1f
    8000593e:	f6648493          	addi	s1,s1,-154 # 800248a0 <disk>
    80005942:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    80005944:	a32fb0ef          	jal	80000b76 <kalloc>
    80005948:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    8000594a:	a2cfb0ef          	jal	80000b76 <kalloc>
    8000594e:	87aa                	mv	a5,a0
    80005950:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    80005952:	6088                	ld	a0,0(s1)
    80005954:	0e050063          	beqz	a0,80005a34 <virtio_disk_init+0x1bc>
    80005958:	0001f717          	auipc	a4,0x1f
    8000595c:	f5073703          	ld	a4,-176(a4) # 800248a8 <disk+0x8>
    80005960:	cb71                	beqz	a4,80005a34 <virtio_disk_init+0x1bc>
    80005962:	cbe9                	beqz	a5,80005a34 <virtio_disk_init+0x1bc>
  memset(disk.desc, 0, PGSIZE);
    80005964:	6605                	lui	a2,0x1
    80005966:	4581                	li	a1,0
    80005968:	bc2fb0ef          	jal	80000d2a <memset>
  memset(disk.avail, 0, PGSIZE);
    8000596c:	0001f497          	auipc	s1,0x1f
    80005970:	f3448493          	addi	s1,s1,-204 # 800248a0 <disk>
    80005974:	6605                	lui	a2,0x1
    80005976:	4581                	li	a1,0
    80005978:	6488                	ld	a0,8(s1)
    8000597a:	bb0fb0ef          	jal	80000d2a <memset>
  memset(disk.used, 0, PGSIZE);
    8000597e:	6605                	lui	a2,0x1
    80005980:	4581                	li	a1,0
    80005982:	6888                	ld	a0,16(s1)
    80005984:	ba6fb0ef          	jal	80000d2a <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    80005988:	100017b7          	lui	a5,0x10001
    8000598c:	4721                	li	a4,8
    8000598e:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    80005990:	4098                	lw	a4,0(s1)
    80005992:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    80005996:	40d8                	lw	a4,4(s1)
    80005998:	08e7a223          	sw	a4,132(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    8000599c:	649c                	ld	a5,8(s1)
    8000599e:	0007869b          	sext.w	a3,a5
    800059a2:	10001737          	lui	a4,0x10001
    800059a6:	08d72823          	sw	a3,144(a4) # 10001090 <_entry-0x6fffef70>
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    800059aa:	9781                	srai	a5,a5,0x20
    800059ac:	08f72a23          	sw	a5,148(a4)
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    800059b0:	689c                	ld	a5,16(s1)
    800059b2:	0007869b          	sext.w	a3,a5
    800059b6:	0ad72023          	sw	a3,160(a4)
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    800059ba:	9781                	srai	a5,a5,0x20
    800059bc:	0af72223          	sw	a5,164(a4)
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    800059c0:	4785                	li	a5,1
    800059c2:	c37c                	sw	a5,68(a4)
    disk.free[i] = 1;
    800059c4:	00f48c23          	sb	a5,24(s1)
    800059c8:	00f48ca3          	sb	a5,25(s1)
    800059cc:	00f48d23          	sb	a5,26(s1)
    800059d0:	00f48da3          	sb	a5,27(s1)
    800059d4:	00f48e23          	sb	a5,28(s1)
    800059d8:	00f48ea3          	sb	a5,29(s1)
    800059dc:	00f48f23          	sb	a5,30(s1)
    800059e0:	00f48fa3          	sb	a5,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    800059e4:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    800059e8:	07272823          	sw	s2,112(a4)
}
    800059ec:	60e2                	ld	ra,24(sp)
    800059ee:	6442                	ld	s0,16(sp)
    800059f0:	64a2                	ld	s1,8(sp)
    800059f2:	6902                	ld	s2,0(sp)
    800059f4:	6105                	addi	sp,sp,32
    800059f6:	8082                	ret
    panic("could not find virtio disk");
    800059f8:	00003517          	auipc	a0,0x3
    800059fc:	c8050513          	addi	a0,a0,-896 # 80008678 <etext+0x678>
    80005a00:	e57fa0ef          	jal	80000856 <panic>
    panic("virtio disk FEATURES_OK unset");
    80005a04:	00003517          	auipc	a0,0x3
    80005a08:	c9450513          	addi	a0,a0,-876 # 80008698 <etext+0x698>
    80005a0c:	e4bfa0ef          	jal	80000856 <panic>
    panic("virtio disk should not be ready");
    80005a10:	00003517          	auipc	a0,0x3
    80005a14:	ca850513          	addi	a0,a0,-856 # 800086b8 <etext+0x6b8>
    80005a18:	e3ffa0ef          	jal	80000856 <panic>
    panic("virtio disk has no queue 0");
    80005a1c:	00003517          	auipc	a0,0x3
    80005a20:	cbc50513          	addi	a0,a0,-836 # 800086d8 <etext+0x6d8>
    80005a24:	e33fa0ef          	jal	80000856 <panic>
    panic("virtio disk max queue too short");
    80005a28:	00003517          	auipc	a0,0x3
    80005a2c:	cd050513          	addi	a0,a0,-816 # 800086f8 <etext+0x6f8>
    80005a30:	e27fa0ef          	jal	80000856 <panic>
    panic("virtio disk kalloc");
    80005a34:	00003517          	auipc	a0,0x3
    80005a38:	ce450513          	addi	a0,a0,-796 # 80008718 <etext+0x718>
    80005a3c:	e1bfa0ef          	jal	80000856 <panic>

0000000080005a40 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80005a40:	711d                	addi	sp,sp,-96
    80005a42:	ec86                	sd	ra,88(sp)
    80005a44:	e8a2                	sd	s0,80(sp)
    80005a46:	e4a6                	sd	s1,72(sp)
    80005a48:	e0ca                	sd	s2,64(sp)
    80005a4a:	fc4e                	sd	s3,56(sp)
    80005a4c:	f852                	sd	s4,48(sp)
    80005a4e:	f456                	sd	s5,40(sp)
    80005a50:	f05a                	sd	s6,32(sp)
    80005a52:	ec5e                	sd	s7,24(sp)
    80005a54:	e862                	sd	s8,16(sp)
    80005a56:	1080                	addi	s0,sp,96
    80005a58:	89aa                	mv	s3,a0
    80005a5a:	8b2e                	mv	s6,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    80005a5c:	00c52b83          	lw	s7,12(a0)
    80005a60:	001b9b9b          	slliw	s7,s7,0x1
    80005a64:	1b82                	slli	s7,s7,0x20
    80005a66:	020bdb93          	srli	s7,s7,0x20

  acquire(&disk.vdisk_lock);
    80005a6a:	0001f517          	auipc	a0,0x1f
    80005a6e:	f5e50513          	addi	a0,a0,-162 # 800249c8 <disk+0x128>
    80005a72:	9e8fb0ef          	jal	80000c5a <acquire>
  for(int i = 0; i < NUM; i++){
    80005a76:	44a1                	li	s1,8
      disk.free[i] = 0;
    80005a78:	0001fa97          	auipc	s5,0x1f
    80005a7c:	e28a8a93          	addi	s5,s5,-472 # 800248a0 <disk>
  for(int i = 0; i < 3; i++){
    80005a80:	4a0d                	li	s4,3
    idx[i] = alloc_desc();
    80005a82:	5c7d                	li	s8,-1
    80005a84:	a095                	j	80005ae8 <virtio_disk_rw+0xa8>
      disk.free[i] = 0;
    80005a86:	00fa8733          	add	a4,s5,a5
    80005a8a:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    80005a8e:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    80005a90:	0207c563          	bltz	a5,80005aba <virtio_disk_rw+0x7a>
  for(int i = 0; i < 3; i++){
    80005a94:	2905                	addiw	s2,s2,1
    80005a96:	0611                	addi	a2,a2,4 # 1004 <_entry-0x7fffeffc>
    80005a98:	05490c63          	beq	s2,s4,80005af0 <virtio_disk_rw+0xb0>
    idx[i] = alloc_desc();
    80005a9c:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    80005a9e:	0001f717          	auipc	a4,0x1f
    80005aa2:	e0270713          	addi	a4,a4,-510 # 800248a0 <disk>
    80005aa6:	4781                	li	a5,0
    if(disk.free[i]){
    80005aa8:	01874683          	lbu	a3,24(a4)
    80005aac:	fee9                	bnez	a3,80005a86 <virtio_disk_rw+0x46>
  for(int i = 0; i < NUM; i++){
    80005aae:	2785                	addiw	a5,a5,1
    80005ab0:	0705                	addi	a4,a4,1
    80005ab2:	fe979be3          	bne	a5,s1,80005aa8 <virtio_disk_rw+0x68>
    idx[i] = alloc_desc();
    80005ab6:	0185a023          	sw	s8,0(a1)
      for(int j = 0; j < i; j++)
    80005aba:	01205d63          	blez	s2,80005ad4 <virtio_disk_rw+0x94>
        free_desc(idx[j]);
    80005abe:	fa042503          	lw	a0,-96(s0)
    80005ac2:	d41ff0ef          	jal	80005802 <free_desc>
      for(int j = 0; j < i; j++)
    80005ac6:	4785                	li	a5,1
    80005ac8:	0127d663          	bge	a5,s2,80005ad4 <virtio_disk_rw+0x94>
        free_desc(idx[j]);
    80005acc:	fa442503          	lw	a0,-92(s0)
    80005ad0:	d33ff0ef          	jal	80005802 <free_desc>
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80005ad4:	0001f597          	auipc	a1,0x1f
    80005ad8:	ef458593          	addi	a1,a1,-268 # 800249c8 <disk+0x128>
    80005adc:	0001f517          	auipc	a0,0x1f
    80005ae0:	ddc50513          	addi	a0,a0,-548 # 800248b8 <disk+0x18>
    80005ae4:	e58fc0ef          	jal	8000213c <sleep>
  for(int i = 0; i < 3; i++){
    80005ae8:	fa040613          	addi	a2,s0,-96
    80005aec:	4901                	li	s2,0
    80005aee:	b77d                	j	80005a9c <virtio_disk_rw+0x5c>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80005af0:	fa042503          	lw	a0,-96(s0)
    80005af4:	00451693          	slli	a3,a0,0x4

  if(write)
    80005af8:	0001f797          	auipc	a5,0x1f
    80005afc:	da878793          	addi	a5,a5,-600 # 800248a0 <disk>
    80005b00:	00451713          	slli	a4,a0,0x4
    80005b04:	0a070713          	addi	a4,a4,160
    80005b08:	973e                	add	a4,a4,a5
    80005b0a:	01603633          	snez	a2,s6
    80005b0e:	c710                	sw	a2,8(a4)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    80005b10:	00072623          	sw	zero,12(a4)
  buf0->sector = sector;
    80005b14:	01773823          	sd	s7,16(a4)

  disk.desc[idx[0]].addr = (uint64) buf0;
    80005b18:	6398                	ld	a4,0(a5)
    80005b1a:	9736                	add	a4,a4,a3
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80005b1c:	0a868613          	addi	a2,a3,168 # 100010a8 <_entry-0x6fffef58>
    80005b20:	963e                	add	a2,a2,a5
  disk.desc[idx[0]].addr = (uint64) buf0;
    80005b22:	e310                	sd	a2,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    80005b24:	6390                	ld	a2,0(a5)
    80005b26:	00d60833          	add	a6,a2,a3
    80005b2a:	4741                	li	a4,16
    80005b2c:	00e82423          	sw	a4,8(a6)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    80005b30:	4585                	li	a1,1
    80005b32:	00b81623          	sh	a1,12(a6)
  disk.desc[idx[0]].next = idx[1];
    80005b36:	fa442703          	lw	a4,-92(s0)
    80005b3a:	00e81723          	sh	a4,14(a6)

  disk.desc[idx[1]].addr = (uint64) b->data;
    80005b3e:	0712                	slli	a4,a4,0x4
    80005b40:	963a                	add	a2,a2,a4
    80005b42:	05898813          	addi	a6,s3,88
    80005b46:	01063023          	sd	a6,0(a2)
  disk.desc[idx[1]].len = BSIZE;
    80005b4a:	0007b883          	ld	a7,0(a5)
    80005b4e:	9746                	add	a4,a4,a7
    80005b50:	40000613          	li	a2,1024
    80005b54:	c710                	sw	a2,8(a4)
  if(write)
    80005b56:	001b3613          	seqz	a2,s6
    80005b5a:	0016161b          	slliw	a2,a2,0x1
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    80005b5e:	8e4d                	or	a2,a2,a1
    80005b60:	00c71623          	sh	a2,12(a4)
  disk.desc[idx[1]].next = idx[2];
    80005b64:	fa842603          	lw	a2,-88(s0)
    80005b68:	00c71723          	sh	a2,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    80005b6c:	00451813          	slli	a6,a0,0x4
    80005b70:	02080813          	addi	a6,a6,32
    80005b74:	983e                	add	a6,a6,a5
    80005b76:	577d                	li	a4,-1
    80005b78:	00e80823          	sb	a4,16(a6)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    80005b7c:	0612                	slli	a2,a2,0x4
    80005b7e:	98b2                	add	a7,a7,a2
    80005b80:	03068713          	addi	a4,a3,48
    80005b84:	973e                	add	a4,a4,a5
    80005b86:	00e8b023          	sd	a4,0(a7)
  disk.desc[idx[2]].len = 1;
    80005b8a:	6398                	ld	a4,0(a5)
    80005b8c:	9732                	add	a4,a4,a2
    80005b8e:	c70c                	sw	a1,8(a4)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    80005b90:	4689                	li	a3,2
    80005b92:	00d71623          	sh	a3,12(a4)
  disk.desc[idx[2]].next = 0;
    80005b96:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    80005b9a:	00b9a223          	sw	a1,4(s3)
  disk.info[idx[0]].b = b;
    80005b9e:	01383423          	sd	s3,8(a6)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    80005ba2:	6794                	ld	a3,8(a5)
    80005ba4:	0026d703          	lhu	a4,2(a3)
    80005ba8:	8b1d                	andi	a4,a4,7
    80005baa:	0706                	slli	a4,a4,0x1
    80005bac:	96ba                	add	a3,a3,a4
    80005bae:	00a69223          	sh	a0,4(a3)

  __sync_synchronize();
    80005bb2:	0330000f          	fence	rw,rw

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    80005bb6:	6798                	ld	a4,8(a5)
    80005bb8:	00275783          	lhu	a5,2(a4)
    80005bbc:	2785                	addiw	a5,a5,1
    80005bbe:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    80005bc2:	0330000f          	fence	rw,rw

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80005bc6:	100017b7          	lui	a5,0x10001
    80005bca:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    80005bce:	0049a783          	lw	a5,4(s3)
    sleep(b, &disk.vdisk_lock);
    80005bd2:	0001f917          	auipc	s2,0x1f
    80005bd6:	df690913          	addi	s2,s2,-522 # 800249c8 <disk+0x128>
  while(b->disk == 1) {
    80005bda:	84ae                	mv	s1,a1
    80005bdc:	00b79a63          	bne	a5,a1,80005bf0 <virtio_disk_rw+0x1b0>
    sleep(b, &disk.vdisk_lock);
    80005be0:	85ca                	mv	a1,s2
    80005be2:	854e                	mv	a0,s3
    80005be4:	d58fc0ef          	jal	8000213c <sleep>
  while(b->disk == 1) {
    80005be8:	0049a783          	lw	a5,4(s3)
    80005bec:	fe978ae3          	beq	a5,s1,80005be0 <virtio_disk_rw+0x1a0>
  }

  disk.info[idx[0]].b = 0;
    80005bf0:	fa042903          	lw	s2,-96(s0)
    80005bf4:	00491713          	slli	a4,s2,0x4
    80005bf8:	02070713          	addi	a4,a4,32
    80005bfc:	0001f797          	auipc	a5,0x1f
    80005c00:	ca478793          	addi	a5,a5,-860 # 800248a0 <disk>
    80005c04:	97ba                	add	a5,a5,a4
    80005c06:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    80005c0a:	0001f997          	auipc	s3,0x1f
    80005c0e:	c9698993          	addi	s3,s3,-874 # 800248a0 <disk>
    80005c12:	00491713          	slli	a4,s2,0x4
    80005c16:	0009b783          	ld	a5,0(s3)
    80005c1a:	97ba                	add	a5,a5,a4
    80005c1c:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    80005c20:	854a                	mv	a0,s2
    80005c22:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    80005c26:	bddff0ef          	jal	80005802 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    80005c2a:	8885                	andi	s1,s1,1
    80005c2c:	f0fd                	bnez	s1,80005c12 <virtio_disk_rw+0x1d2>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    80005c2e:	0001f517          	auipc	a0,0x1f
    80005c32:	d9a50513          	addi	a0,a0,-614 # 800249c8 <disk+0x128>
    80005c36:	8b8fb0ef          	jal	80000cee <release>
}
    80005c3a:	60e6                	ld	ra,88(sp)
    80005c3c:	6446                	ld	s0,80(sp)
    80005c3e:	64a6                	ld	s1,72(sp)
    80005c40:	6906                	ld	s2,64(sp)
    80005c42:	79e2                	ld	s3,56(sp)
    80005c44:	7a42                	ld	s4,48(sp)
    80005c46:	7aa2                	ld	s5,40(sp)
    80005c48:	7b02                	ld	s6,32(sp)
    80005c4a:	6be2                	ld	s7,24(sp)
    80005c4c:	6c42                	ld	s8,16(sp)
    80005c4e:	6125                	addi	sp,sp,96
    80005c50:	8082                	ret

0000000080005c52 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    80005c52:	1101                	addi	sp,sp,-32
    80005c54:	ec06                	sd	ra,24(sp)
    80005c56:	e822                	sd	s0,16(sp)
    80005c58:	e426                	sd	s1,8(sp)
    80005c5a:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    80005c5c:	0001f497          	auipc	s1,0x1f
    80005c60:	c4448493          	addi	s1,s1,-956 # 800248a0 <disk>
    80005c64:	0001f517          	auipc	a0,0x1f
    80005c68:	d6450513          	addi	a0,a0,-668 # 800249c8 <disk+0x128>
    80005c6c:	feffa0ef          	jal	80000c5a <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    80005c70:	100017b7          	lui	a5,0x10001
    80005c74:	53bc                	lw	a5,96(a5)
    80005c76:	8b8d                	andi	a5,a5,3
    80005c78:	10001737          	lui	a4,0x10001
    80005c7c:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    80005c7e:	0330000f          	fence	rw,rw

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    80005c82:	689c                	ld	a5,16(s1)
    80005c84:	0204d703          	lhu	a4,32(s1)
    80005c88:	0027d783          	lhu	a5,2(a5) # 10001002 <_entry-0x6fffeffe>
    80005c8c:	04f70863          	beq	a4,a5,80005cdc <virtio_disk_intr+0x8a>
    __sync_synchronize();
    80005c90:	0330000f          	fence	rw,rw
    int id = disk.used->ring[disk.used_idx % NUM].id;
    80005c94:	6898                	ld	a4,16(s1)
    80005c96:	0204d783          	lhu	a5,32(s1)
    80005c9a:	8b9d                	andi	a5,a5,7
    80005c9c:	078e                	slli	a5,a5,0x3
    80005c9e:	97ba                	add	a5,a5,a4
    80005ca0:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    80005ca2:	00479713          	slli	a4,a5,0x4
    80005ca6:	02070713          	addi	a4,a4,32 # 10001020 <_entry-0x6fffefe0>
    80005caa:	9726                	add	a4,a4,s1
    80005cac:	01074703          	lbu	a4,16(a4)
    80005cb0:	e329                	bnez	a4,80005cf2 <virtio_disk_intr+0xa0>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    80005cb2:	0792                	slli	a5,a5,0x4
    80005cb4:	02078793          	addi	a5,a5,32
    80005cb8:	97a6                	add	a5,a5,s1
    80005cba:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    80005cbc:	00052223          	sw	zero,4(a0)
    wakeup(b);
    80005cc0:	cc8fc0ef          	jal	80002188 <wakeup>

    disk.used_idx += 1;
    80005cc4:	0204d783          	lhu	a5,32(s1)
    80005cc8:	2785                	addiw	a5,a5,1
    80005cca:	17c2                	slli	a5,a5,0x30
    80005ccc:	93c1                	srli	a5,a5,0x30
    80005cce:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    80005cd2:	6898                	ld	a4,16(s1)
    80005cd4:	00275703          	lhu	a4,2(a4)
    80005cd8:	faf71ce3          	bne	a4,a5,80005c90 <virtio_disk_intr+0x3e>
  }

  release(&disk.vdisk_lock);
    80005cdc:	0001f517          	auipc	a0,0x1f
    80005ce0:	cec50513          	addi	a0,a0,-788 # 800249c8 <disk+0x128>
    80005ce4:	80afb0ef          	jal	80000cee <release>
}
    80005ce8:	60e2                	ld	ra,24(sp)
    80005cea:	6442                	ld	s0,16(sp)
    80005cec:	64a2                	ld	s1,8(sp)
    80005cee:	6105                	addi	sp,sp,32
    80005cf0:	8082                	ret
      panic("virtio_disk_intr status");
    80005cf2:	00003517          	auipc	a0,0x3
    80005cf6:	a3e50513          	addi	a0,a0,-1474 # 80008730 <etext+0x730>
    80005cfa:	b5dfa0ef          	jal	80000856 <panic>

0000000080005cfe <cslog_init>:
  safestrcpy(e->name, p->name, CS_NM);
}

void
cslog_init(void)
{
    80005cfe:	1141                	addi	sp,sp,-16
    80005d00:	e406                	sd	ra,8(sp)
    80005d02:	e022                	sd	s0,0(sp)
    80005d04:	0800                	addi	s0,sp,16
  ringbuf_init(&cs_rb, "cslog", sizeof(struct cs_event));
    80005d06:	03000613          	li	a2,48
    80005d0a:	00003597          	auipc	a1,0x3
    80005d0e:	a3e58593          	addi	a1,a1,-1474 # 80008748 <etext+0x748>
    80005d12:	0001f517          	auipc	a0,0x1f
    80005d16:	cce50513          	addi	a0,a0,-818 # 800249e0 <cs_rb>
    80005d1a:	1a2000ef          	jal	80005ebc <ringbuf_init>
}
    80005d1e:	60a2                	ld	ra,8(sp)
    80005d20:	6402                	ld	s0,0(sp)
    80005d22:	0141                	addi	sp,sp,16
    80005d24:	8082                	ret

0000000080005d26 <cslog_push>:

void
cslog_push(struct cs_event *e)
{
    80005d26:	1141                	addi	sp,sp,-16
    80005d28:	e406                	sd	ra,8(sp)
    80005d2a:	e022                	sd	s0,0(sp)
    80005d2c:	0800                	addi	s0,sp,16
    80005d2e:	85aa                	mv	a1,a0
  e->seq = ++cs_seq;
    80005d30:	00006717          	auipc	a4,0x6
    80005d34:	94870713          	addi	a4,a4,-1720 # 8000b678 <cs_seq>
    80005d38:	631c                	ld	a5,0(a4)
    80005d3a:	0785                	addi	a5,a5,1
    80005d3c:	e31c                	sd	a5,0(a4)
    80005d3e:	e11c                	sd	a5,0(a0)
  ringbuf_push(&cs_rb, e);
    80005d40:	0001f517          	auipc	a0,0x1f
    80005d44:	ca050513          	addi	a0,a0,-864 # 800249e0 <cs_rb>
    80005d48:	1a8000ef          	jal	80005ef0 <ringbuf_push>
}
    80005d4c:	60a2                	ld	ra,8(sp)
    80005d4e:	6402                	ld	s0,0(sp)
    80005d50:	0141                	addi	sp,sp,16
    80005d52:	8082                	ret

0000000080005d54 <cslog_read_many>:

int
cslog_read_many(struct cs_event *out, int max)
{
    80005d54:	1141                	addi	sp,sp,-16
    80005d56:	e406                	sd	ra,8(sp)
    80005d58:	e022                	sd	s0,0(sp)
    80005d5a:	0800                	addi	s0,sp,16
    80005d5c:	862e                	mv	a2,a1
  return ringbuf_read_many(&cs_rb, out, max);
    80005d5e:	85aa                	mv	a1,a0
    80005d60:	0001f517          	auipc	a0,0x1f
    80005d64:	c8050513          	addi	a0,a0,-896 # 800249e0 <cs_rb>
    80005d68:	1f4000ef          	jal	80005f5c <ringbuf_read_many>
}
    80005d6c:	60a2                	ld	ra,8(sp)
    80005d6e:	6402                	ld	s0,0(sp)
    80005d70:	0141                	addi	sp,sp,16
    80005d72:	8082                	ret

0000000080005d74 <cslog_run_start>:

void
cslog_run_start(struct proc *p)
{
  if(p == 0) return;
    80005d74:	c14d                	beqz	a0,80005e16 <cslog_run_start+0xa2>
{
    80005d76:	715d                	addi	sp,sp,-80
    80005d78:	e486                	sd	ra,72(sp)
    80005d7a:	e0a2                	sd	s0,64(sp)
    80005d7c:	fc26                	sd	s1,56(sp)
    80005d7e:	0880                	addi	s0,sp,80
    80005d80:	84aa                	mv	s1,a0
  if(p->pid <= 0) return;
    80005d82:	591c                	lw	a5,48(a0)
    80005d84:	00f05563          	blez	a5,80005d8e <cslog_run_start+0x1a>
  if(p->name[0] == 0) return;
    80005d88:	15854783          	lbu	a5,344(a0)
    80005d8c:	e791                	bnez	a5,80005d98 <cslog_run_start+0x24>

  struct cs_event e;
  fill_from_proc(&e, p);
  e.type = CS_RUN_START;
  cslog_push(&e);
    80005d8e:	60a6                	ld	ra,72(sp)
    80005d90:	6406                	ld	s0,64(sp)
    80005d92:	74e2                	ld	s1,56(sp)
    80005d94:	6161                	addi	sp,sp,80
    80005d96:	8082                	ret
    80005d98:	f84a                	sd	s2,48(sp)
  if(strncmp(p->name, "cscat", 5) == 0) return;
    80005d9a:	15850913          	addi	s2,a0,344
    80005d9e:	4615                	li	a2,5
    80005da0:	00003597          	auipc	a1,0x3
    80005da4:	9b058593          	addi	a1,a1,-1616 # 80008750 <etext+0x750>
    80005da8:	854a                	mv	a0,s2
    80005daa:	854fb0ef          	jal	80000dfe <strncmp>
    80005dae:	e119                	bnez	a0,80005db4 <cslog_run_start+0x40>
    80005db0:	7942                	ld	s2,48(sp)
    80005db2:	bff1                	j	80005d8e <cslog_run_start+0x1a>
  if(strncmp(p->name, "csexport", 8) == 0) return;
    80005db4:	4621                	li	a2,8
    80005db6:	00003597          	auipc	a1,0x3
    80005dba:	9a258593          	addi	a1,a1,-1630 # 80008758 <etext+0x758>
    80005dbe:	854a                	mv	a0,s2
    80005dc0:	83efb0ef          	jal	80000dfe <strncmp>
    80005dc4:	e119                	bnez	a0,80005dca <cslog_run_start+0x56>
    80005dc6:	7942                	ld	s2,48(sp)
    80005dc8:	b7d9                	j	80005d8e <cslog_run_start+0x1a>
  memset(e, 0, sizeof(*e));
    80005dca:	03000613          	li	a2,48
    80005dce:	4581                	li	a1,0
    80005dd0:	fb040513          	addi	a0,s0,-80
    80005dd4:	f57fa0ef          	jal	80000d2a <memset>
  e->ticks = ticks;
    80005dd8:	00006797          	auipc	a5,0x6
    80005ddc:	8987a783          	lw	a5,-1896(a5) # 8000b670 <ticks>
    80005de0:	faf42c23          	sw	a5,-72(s0)
  e->cpu   = cpuid();
    80005de4:	b65fb0ef          	jal	80001948 <cpuid>
    80005de8:	faa42e23          	sw	a0,-68(s0)
  e->pid   = p->pid;
    80005dec:	589c                	lw	a5,48(s1)
    80005dee:	fcf42223          	sw	a5,-60(s0)
  e->state = p->state;
    80005df2:	4c9c                	lw	a5,24(s1)
    80005df4:	fcf42423          	sw	a5,-56(s0)
  safestrcpy(e->name, p->name, CS_NM);
    80005df8:	4641                	li	a2,16
    80005dfa:	85ca                	mv	a1,s2
    80005dfc:	fcc40513          	addi	a0,s0,-52
    80005e00:	87efb0ef          	jal	80000e7e <safestrcpy>
  e.type = CS_RUN_START;
    80005e04:	4785                	li	a5,1
    80005e06:	fcf42023          	sw	a5,-64(s0)
  cslog_push(&e);
    80005e0a:	fb040513          	addi	a0,s0,-80
    80005e0e:	f19ff0ef          	jal	80005d26 <cslog_push>
    80005e12:	7942                	ld	s2,48(sp)
    80005e14:	bfad                	j	80005d8e <cslog_run_start+0x1a>
    80005e16:	8082                	ret

0000000080005e18 <sys_csread>:
#include "cslog.h"


uint64
sys_csread(void)
{
    80005e18:	81010113          	addi	sp,sp,-2032
    80005e1c:	7e113423          	sd	ra,2024(sp)
    80005e20:	7e813023          	sd	s0,2016(sp)
    80005e24:	7c913c23          	sd	s1,2008(sp)
    80005e28:	7d213823          	sd	s2,2000(sp)
    80005e2c:	7f010413          	addi	s0,sp,2032
    80005e30:	bc010113          	addi	sp,sp,-1088
  uint64 uaddr = 0;
    80005e34:	fc043c23          	sd	zero,-40(s0)
  int max = 0;
    80005e38:	fc042a23          	sw	zero,-44(s0)

  // ✅ عندك argaddr/argint void، فبنستدعيهم بدون if
  argaddr(0, &uaddr);
    80005e3c:	fd840593          	addi	a1,s0,-40
    80005e40:	4501                	li	a0,0
    80005e42:	c23fc0ef          	jal	80002a64 <argaddr>
  argint(1, &max);
    80005e46:	fd440593          	addi	a1,s0,-44
    80005e4a:	4505                	li	a0,1
    80005e4c:	bfdfc0ef          	jal	80002a48 <argint>

  if(max <= 0) return 0;
    80005e50:	fd442783          	lw	a5,-44(s0)
    80005e54:	4501                	li	a0,0
    80005e56:	04f05463          	blez	a5,80005e9e <sys_csread+0x86>
  if(max > 64) max = 64;
    80005e5a:	04000713          	li	a4,64
    80005e5e:	00f75463          	bge	a4,a5,80005e66 <sys_csread+0x4e>
    80005e62:	fce42a23          	sw	a4,-44(s0)

  struct cs_event tmp[64];
  int n = cslog_read_many(tmp, max);
    80005e66:	80040493          	addi	s1,s0,-2048
    80005e6a:	1481                	addi	s1,s1,-32
    80005e6c:	bf048493          	addi	s1,s1,-1040
    80005e70:	fd442583          	lw	a1,-44(s0)
    80005e74:	8526                	mv	a0,s1
    80005e76:	edfff0ef          	jal	80005d54 <cslog_read_many>
    80005e7a:	892a                	mv	s2,a0

  int bytes = n * (int)sizeof(struct cs_event);
  if(copyout(myproc()->pagetable, uaddr, (char*)tmp, bytes) < 0)
    80005e7c:	b01fb0ef          	jal	8000197c <myproc>
  int bytes = n * (int)sizeof(struct cs_event);
    80005e80:	0019169b          	slliw	a3,s2,0x1
    80005e84:	012686bb          	addw	a3,a3,s2
  if(copyout(myproc()->pagetable, uaddr, (char*)tmp, bytes) < 0)
    80005e88:	0046969b          	slliw	a3,a3,0x4
    80005e8c:	8626                	mv	a2,s1
    80005e8e:	fd843583          	ld	a1,-40(s0)
    80005e92:	6928                	ld	a0,80(a0)
    80005e94:	ffafb0ef          	jal	8000168e <copyout>
    80005e98:	02054063          	bltz	a0,80005eb8 <sys_csread+0xa0>
    return -1;

  return n;
    80005e9c:	854a                	mv	a0,s2
}
    80005e9e:	44010113          	addi	sp,sp,1088
    80005ea2:	7e813083          	ld	ra,2024(sp)
    80005ea6:	7e013403          	ld	s0,2016(sp)
    80005eaa:	7d813483          	ld	s1,2008(sp)
    80005eae:	7d013903          	ld	s2,2000(sp)
    80005eb2:	7f010113          	addi	sp,sp,2032
    80005eb6:	8082                	ret
    return -1;
    80005eb8:	557d                	li	a0,-1
    80005eba:	b7d5                	j	80005e9e <sys_csread+0x86>

0000000080005ebc <ringbuf_init>:
  return (void *)(rb->buf + idx * rb->elem_size);
}

void
ringbuf_init(struct ringbuf *rb, char *name, uint elem_size)
{
    80005ebc:	1101                	addi	sp,sp,-32
    80005ebe:	ec06                	sd	ra,24(sp)
    80005ec0:	e822                	sd	s0,16(sp)
    80005ec2:	e426                	sd	s1,8(sp)
    80005ec4:	e04a                	sd	s2,0(sp)
    80005ec6:	1000                	addi	s0,sp,32
    80005ec8:	84aa                	mv	s1,a0
    80005eca:	8932                	mv	s2,a2
  initlock(&rb->lock, name);
    80005ecc:	d05fa0ef          	jal	80000bd0 <initlock>
  rb->head = 0;
    80005ed0:	0004ac23          	sw	zero,24(s1)
  rb->tail = 0;
    80005ed4:	0004ae23          	sw	zero,28(s1)
  rb->count = 0;
    80005ed8:	0204a023          	sw	zero,32(s1)
  rb->seq = 0;
    80005edc:	0204b423          	sd	zero,40(s1)
  rb->elem_size = elem_size;
    80005ee0:	0324a223          	sw	s2,36(s1)
}
    80005ee4:	60e2                	ld	ra,24(sp)
    80005ee6:	6442                	ld	s0,16(sp)
    80005ee8:	64a2                	ld	s1,8(sp)
    80005eea:	6902                	ld	s2,0(sp)
    80005eec:	6105                	addi	sp,sp,32
    80005eee:	8082                	ret

0000000080005ef0 <ringbuf_push>:

int
ringbuf_push(struct ringbuf *rb, void *elem)
{
    80005ef0:	1101                	addi	sp,sp,-32
    80005ef2:	ec06                	sd	ra,24(sp)
    80005ef4:	e822                	sd	s0,16(sp)
    80005ef6:	e426                	sd	s1,8(sp)
    80005ef8:	e04a                	sd	s2,0(sp)
    80005efa:	1000                	addi	s0,sp,32
    80005efc:	84aa                	mv	s1,a0
    80005efe:	892e                	mv	s2,a1
  acquire(&rb->lock);
    80005f00:	d5bfa0ef          	jal	80000c5a <acquire>

  if(rb->count == RB_CAP){
    80005f04:	5098                	lw	a4,32(s1)
    80005f06:	20000793          	li	a5,512
    80005f0a:	04f70063          	beq	a4,a5,80005f4a <ringbuf_push+0x5a>
  return (void *)(rb->buf + idx * rb->elem_size);
    80005f0e:	50d0                	lw	a2,36(s1)
    80005f10:	03048513          	addi	a0,s1,48
    80005f14:	4c9c                	lw	a5,24(s1)
    80005f16:	02c787bb          	mulw	a5,a5,a2
    80005f1a:	1782                	slli	a5,a5,0x20
    80005f1c:	9381                	srli	a5,a5,0x20
    rb->tail = (rb->tail + 1) % RB_CAP;
    rb->count--;
  }

  memmove(slot_ptr(rb, rb->head), elem, rb->elem_size);
    80005f1e:	85ca                	mv	a1,s2
    80005f20:	953e                	add	a0,a0,a5
    80005f22:	e69fa0ef          	jal	80000d8a <memmove>
  rb->head = (rb->head + 1) % RB_CAP;
    80005f26:	4c9c                	lw	a5,24(s1)
    80005f28:	2785                	addiw	a5,a5,1
    80005f2a:	1ff7f793          	andi	a5,a5,511
    80005f2e:	cc9c                	sw	a5,24(s1)
  rb->count++;
    80005f30:	509c                	lw	a5,32(s1)
    80005f32:	2785                	addiw	a5,a5,1
    80005f34:	d09c                	sw	a5,32(s1)

  release(&rb->lock);
    80005f36:	8526                	mv	a0,s1
    80005f38:	db7fa0ef          	jal	80000cee <release>
  return 0;
}
    80005f3c:	4501                	li	a0,0
    80005f3e:	60e2                	ld	ra,24(sp)
    80005f40:	6442                	ld	s0,16(sp)
    80005f42:	64a2                	ld	s1,8(sp)
    80005f44:	6902                	ld	s2,0(sp)
    80005f46:	6105                	addi	sp,sp,32
    80005f48:	8082                	ret
    rb->tail = (rb->tail + 1) % RB_CAP;
    80005f4a:	4cdc                	lw	a5,28(s1)
    80005f4c:	2785                	addiw	a5,a5,1
    80005f4e:	1ff7f793          	andi	a5,a5,511
    80005f52:	ccdc                	sw	a5,28(s1)
    rb->count--;
    80005f54:	1ff00793          	li	a5,511
    80005f58:	d09c                	sw	a5,32(s1)
    80005f5a:	bf55                	j	80005f0e <ringbuf_push+0x1e>

0000000080005f5c <ringbuf_read_many>:
ringbuf_read_many(struct ringbuf *rb, void *out, int max)
{
  int n = 0;
  char *dst = (char *)out;

  if(max <= 0)
    80005f5c:	06c05d63          	blez	a2,80005fd6 <ringbuf_read_many+0x7a>
{
    80005f60:	7139                	addi	sp,sp,-64
    80005f62:	fc06                	sd	ra,56(sp)
    80005f64:	f822                	sd	s0,48(sp)
    80005f66:	f426                	sd	s1,40(sp)
    80005f68:	f04a                	sd	s2,32(sp)
    80005f6a:	ec4e                	sd	s3,24(sp)
    80005f6c:	e852                	sd	s4,16(sp)
    80005f6e:	e456                	sd	s5,8(sp)
    80005f70:	0080                	addi	s0,sp,64
    80005f72:	84aa                	mv	s1,a0
    80005f74:	8a2e                	mv	s4,a1
    80005f76:	89b2                	mv	s3,a2
    return 0;

  acquire(&rb->lock);
    80005f78:	ce3fa0ef          	jal	80000c5a <acquire>
  int n = 0;
    80005f7c:	4901                	li	s2,0
  return (void *)(rb->buf + idx * rb->elem_size);
    80005f7e:	03048a93          	addi	s5,s1,48
  while(n < max && rb->count > 0){
    80005f82:	509c                	lw	a5,32(s1)
    80005f84:	c7b9                	beqz	a5,80005fd2 <ringbuf_read_many+0x76>
    memmove(dst + n * rb->elem_size, slot_ptr(rb, rb->tail), rb->elem_size);
    80005f86:	50d0                	lw	a2,36(s1)
  return (void *)(rb->buf + idx * rb->elem_size);
    80005f88:	4ccc                	lw	a1,28(s1)
    80005f8a:	02c585bb          	mulw	a1,a1,a2
    80005f8e:	1582                	slli	a1,a1,0x20
    80005f90:	9181                	srli	a1,a1,0x20
    memmove(dst + n * rb->elem_size, slot_ptr(rb, rb->tail), rb->elem_size);
    80005f92:	02c9053b          	mulw	a0,s2,a2
    80005f96:	1502                	slli	a0,a0,0x20
    80005f98:	9101                	srli	a0,a0,0x20
    80005f9a:	95d6                	add	a1,a1,s5
    80005f9c:	9552                	add	a0,a0,s4
    80005f9e:	dedfa0ef          	jal	80000d8a <memmove>
    rb->tail = (rb->tail + 1) % RB_CAP;
    80005fa2:	4cdc                	lw	a5,28(s1)
    80005fa4:	2785                	addiw	a5,a5,1
    80005fa6:	1ff7f793          	andi	a5,a5,511
    80005faa:	ccdc                	sw	a5,28(s1)
    rb->count--;
    80005fac:	509c                	lw	a5,32(s1)
    80005fae:	37fd                	addiw	a5,a5,-1
    80005fb0:	d09c                	sw	a5,32(s1)
    n++;
    80005fb2:	2905                	addiw	s2,s2,1
  while(n < max && rb->count > 0){
    80005fb4:	fd2997e3          	bne	s3,s2,80005f82 <ringbuf_read_many+0x26>
  }
  release(&rb->lock);
    80005fb8:	8526                	mv	a0,s1
    80005fba:	d35fa0ef          	jal	80000cee <release>

  return n;
    80005fbe:	854e                	mv	a0,s3
}
    80005fc0:	70e2                	ld	ra,56(sp)
    80005fc2:	7442                	ld	s0,48(sp)
    80005fc4:	74a2                	ld	s1,40(sp)
    80005fc6:	7902                	ld	s2,32(sp)
    80005fc8:	69e2                	ld	s3,24(sp)
    80005fca:	6a42                	ld	s4,16(sp)
    80005fcc:	6aa2                	ld	s5,8(sp)
    80005fce:	6121                	addi	sp,sp,64
    80005fd0:	8082                	ret
    80005fd2:	89ca                	mv	s3,s2
    80005fd4:	b7d5                	j	80005fb8 <ringbuf_read_many+0x5c>
    return 0;
    80005fd6:	4501                	li	a0,0
}
    80005fd8:	8082                	ret

0000000080005fda <ringbuf_pop>:
int
ringbuf_pop(struct ringbuf *rb, void *dst)
{
    80005fda:	1101                	addi	sp,sp,-32
    80005fdc:	ec06                	sd	ra,24(sp)
    80005fde:	e822                	sd	s0,16(sp)
    80005fe0:	e426                	sd	s1,8(sp)
    80005fe2:	e04a                	sd	s2,0(sp)
    80005fe4:	1000                	addi	s0,sp,32
    80005fe6:	84aa                	mv	s1,a0
    80005fe8:	892e                	mv	s2,a1
  acquire(&rb->lock);
    80005fea:	c71fa0ef          	jal	80000c5a <acquire>
  
  if(rb->count == 0){ // البفر فارغ تماماً
    80005fee:	509c                	lw	a5,32(s1)
    80005ff0:	cf9d                	beqz	a5,8000602e <ringbuf_pop+0x54>
  return (void *)(rb->buf + idx * rb->elem_size);
    80005ff2:	50d0                	lw	a2,36(s1)
    80005ff4:	03048593          	addi	a1,s1,48
    80005ff8:	4cdc                	lw	a5,28(s1)
    80005ffa:	02c787bb          	mulw	a5,a5,a2
    80005ffe:	1782                	slli	a5,a5,0x20
    80006000:	9381                	srli	a5,a5,0x20
    return -1;
  }

  // استخدام الدالة المساعدة slot_ptr الموجودة عندك أصلاً
  void *src = slot_ptr(rb, rb->tail);
  memmove(dst, src, rb->elem_size);
    80006002:	95be                	add	a1,a1,a5
    80006004:	854a                	mv	a0,s2
    80006006:	d85fa0ef          	jal	80000d8a <memmove>
  
  // تحديث المؤشرات بنفس منطق المشروع
  rb->tail = (rb->tail + 1) % RB_CAP;
    8000600a:	4cdc                	lw	a5,28(s1)
    8000600c:	2785                	addiw	a5,a5,1
    8000600e:	1ff7f793          	andi	a5,a5,511
    80006012:	ccdc                	sw	a5,28(s1)
  rb->count--;
    80006014:	509c                	lw	a5,32(s1)
    80006016:	37fd                	addiw	a5,a5,-1
    80006018:	d09c                	sw	a5,32(s1)
  
  release(&rb->lock);
    8000601a:	8526                	mv	a0,s1
    8000601c:	cd3fa0ef          	jal	80000cee <release>
  return 0;
    80006020:	4501                	li	a0,0
} 
    80006022:	60e2                	ld	ra,24(sp)
    80006024:	6442                	ld	s0,16(sp)
    80006026:	64a2                	ld	s1,8(sp)
    80006028:	6902                	ld	s2,0(sp)
    8000602a:	6105                	addi	sp,sp,32
    8000602c:	8082                	ret
    release(&rb->lock);
    8000602e:	8526                	mv	a0,s1
    80006030:	cbffa0ef          	jal	80000cee <release>
    return -1;
    80006034:	557d                	li	a0,-1
    80006036:	b7f5                	j	80006022 <ringbuf_pop+0x48>

0000000080006038 <fslog_init>:
#include "defs.h"

static struct ringbuf fs_rb;
static uint64 fs_seq = 0;

void fslog_init(void) {
    80006038:	1141                	addi	sp,sp,-16
    8000603a:	e406                	sd	ra,8(sp)
    8000603c:	e022                	sd	s0,0(sp)
    8000603e:	0800                	addi	s0,sp,16
  ringbuf_init(&fs_rb, "fslog", sizeof(struct fs_event));
    80006040:	03000613          	li	a2,48
    80006044:	00002597          	auipc	a1,0x2
    80006048:	72458593          	addi	a1,a1,1828 # 80008768 <etext+0x768>
    8000604c:	00027517          	auipc	a0,0x27
    80006050:	9c450513          	addi	a0,a0,-1596 # 8002ca10 <fs_rb>
    80006054:	e69ff0ef          	jal	80005ebc <ringbuf_init>
}
    80006058:	60a2                	ld	ra,8(sp)
    8000605a:	6402                	ld	s0,0(sp)
    8000605c:	0141                	addi	sp,sp,16
    8000605e:	8082                	ret

0000000080006060 <fslog_push>:

void fslog_push(int type, int inum, int bno, uint size, char* name) {
    80006060:	7159                	addi	sp,sp,-112
    80006062:	f486                	sd	ra,104(sp)
    80006064:	f0a2                	sd	s0,96(sp)
    80006066:	eca6                	sd	s1,88(sp)
    80006068:	e8ca                	sd	s2,80(sp)
    8000606a:	e4ce                	sd	s3,72(sp)
    8000606c:	e0d2                	sd	s4,64(sp)
    8000606e:	fc56                	sd	s5,56(sp)
    80006070:	1880                	addi	s0,sp,112
    80006072:	84aa                	mv	s1,a0
    80006074:	892e                	mv	s2,a1
    80006076:	89b2                	mv	s3,a2
    80006078:	8a36                	mv	s4,a3
    8000607a:	8aba                	mv	s5,a4
  struct fs_event e;
  memset(&e, 0, sizeof(e));
    8000607c:	03000613          	li	a2,48
    80006080:	4581                	li	a1,0
    80006082:	f9040513          	addi	a0,s0,-112
    80006086:	ca5fa0ef          	jal	80000d2a <memset>
  e.seq = ++fs_seq;
    8000608a:	00005717          	auipc	a4,0x5
    8000608e:	5f670713          	addi	a4,a4,1526 # 8000b680 <fs_seq>
    80006092:	631c                	ld	a5,0(a4)
    80006094:	0785                	addi	a5,a5,1
    80006096:	e31c                	sd	a5,0(a4)
    80006098:	f8f43823          	sd	a5,-112(s0)
  e.ticks = ticks;
    8000609c:	00005797          	auipc	a5,0x5
    800060a0:	5d47a783          	lw	a5,1492(a5) # 8000b670 <ticks>
    800060a4:	f8f42c23          	sw	a5,-104(s0)
  e.type = type;
    800060a8:	f8942e23          	sw	s1,-100(s0)
  e.pid = myproc() ? myproc()->pid : 0;
    800060ac:	8d1fb0ef          	jal	8000197c <myproc>
    800060b0:	4781                	li	a5,0
    800060b2:	c501                	beqz	a0,800060ba <fslog_push+0x5a>
    800060b4:	8c9fb0ef          	jal	8000197c <myproc>
    800060b8:	591c                	lw	a5,48(a0)
    800060ba:	faf42023          	sw	a5,-96(s0)
  e.inum = inum;
    800060be:	fb242223          	sw	s2,-92(s0)
  e.blockno = bno;
    800060c2:	fb342423          	sw	s3,-88(s0)
  e.size = size;
    800060c6:	fb442623          	sw	s4,-84(s0)
  if(name) safestrcpy(e.name, name, FS_NM);
    800060ca:	000a8863          	beqz	s5,800060da <fslog_push+0x7a>
    800060ce:	4641                	li	a2,16
    800060d0:	85d6                	mv	a1,s5
    800060d2:	fb040513          	addi	a0,s0,-80
    800060d6:	da9fa0ef          	jal	80000e7e <safestrcpy>
  ringbuf_push(&fs_rb, &e);
    800060da:	f9040593          	addi	a1,s0,-112
    800060de:	00027517          	auipc	a0,0x27
    800060e2:	93250513          	addi	a0,a0,-1742 # 8002ca10 <fs_rb>
    800060e6:	e0bff0ef          	jal	80005ef0 <ringbuf_push>
}
    800060ea:	70a6                	ld	ra,104(sp)
    800060ec:	7406                	ld	s0,96(sp)
    800060ee:	64e6                	ld	s1,88(sp)
    800060f0:	6946                	ld	s2,80(sp)
    800060f2:	69a6                	ld	s3,72(sp)
    800060f4:	6a06                	ld	s4,64(sp)
    800060f6:	7ae2                	ld	s5,56(sp)
    800060f8:	6165                	addi	sp,sp,112
    800060fa:	8082                	ret

00000000800060fc <fslog_read_many>:
// لا تنسي إضافة fslog_read_many أيضاً هنا

int
fslog_read_many(struct fs_event *out, int max)
{
    800060fc:	7119                	addi	sp,sp,-128
    800060fe:	fc86                	sd	ra,120(sp)
    80006100:	f8a2                	sd	s0,112(sp)
    80006102:	f4a6                	sd	s1,104(sp)
    80006104:	f0ca                	sd	s2,96(sp)
    80006106:	e8d2                	sd	s4,80(sp)
    80006108:	0100                	addi	s0,sp,128
    8000610a:	84aa                	mv	s1,a0
    8000610c:	8a2e                	mv	s4,a1
  struct fs_event e;
  int count = 0;
  struct proc *p = myproc();
    8000610e:	86ffb0ef          	jal	8000197c <myproc>

  while(count < max){
    80006112:	05405863          	blez	s4,80006162 <fslog_read_many+0x66>
    80006116:	ecce                	sd	s3,88(sp)
    80006118:	e4d6                	sd	s5,72(sp)
    8000611a:	e0da                	sd	s6,64(sp)
    8000611c:	fc5e                	sd	s7,56(sp)
    8000611e:	8aaa                	mv	s5,a0
  int count = 0;
    80006120:	4901                	li	s2,0
    // سحب حدث واحد من الرينغ بفر (موجود في ذاكرة الكيرنل)
    if(ringbuf_pop(&fs_rb, &e) != 0)
    80006122:	f8040993          	addi	s3,s0,-128
    80006126:	00027b17          	auipc	s6,0x27
    8000612a:	8eab0b13          	addi	s6,s6,-1814 # 8002ca10 <fs_rb>
      break;

    // 🔥 النسخ الآمن لذاكرة المستخدم باستخدام copyout
    // العنوان الهدف: out + (count * حجم الـ struct)
    uint64 dst_addr = (uint64)out + (count * sizeof(struct fs_event));
    if(copyout(p->pagetable, dst_addr, (char *)&e, sizeof(struct fs_event)) < 0)
    8000612e:	03000b93          	li	s7,48
    if(ringbuf_pop(&fs_rb, &e) != 0)
    80006132:	85ce                	mv	a1,s3
    80006134:	855a                	mv	a0,s6
    80006136:	ea5ff0ef          	jal	80005fda <ringbuf_pop>
    8000613a:	e515                	bnez	a0,80006166 <fslog_read_many+0x6a>
    if(copyout(p->pagetable, dst_addr, (char *)&e, sizeof(struct fs_event)) < 0)
    8000613c:	86de                	mv	a3,s7
    8000613e:	864e                	mv	a2,s3
    80006140:	85a6                	mv	a1,s1
    80006142:	050ab503          	ld	a0,80(s5)
    80006146:	d48fb0ef          	jal	8000168e <copyout>
    8000614a:	02054a63          	bltz	a0,8000617e <fslog_read_many+0x82>
      break;

    count++;
    8000614e:	2905                	addiw	s2,s2,1
  while(count < max){
    80006150:	03048493          	addi	s1,s1,48
    80006154:	fd2a1fe3          	bne	s4,s2,80006132 <fslog_read_many+0x36>
    80006158:	69e6                	ld	s3,88(sp)
    8000615a:	6aa6                	ld	s5,72(sp)
    8000615c:	6b06                	ld	s6,64(sp)
    8000615e:	7be2                	ld	s7,56(sp)
    80006160:	a039                	j	8000616e <fslog_read_many+0x72>
  int count = 0;
    80006162:	4901                	li	s2,0
    80006164:	a029                	j	8000616e <fslog_read_many+0x72>
    80006166:	69e6                	ld	s3,88(sp)
    80006168:	6aa6                	ld	s5,72(sp)
    8000616a:	6b06                	ld	s6,64(sp)
    8000616c:	7be2                	ld	s7,56(sp)
  }
  return count;
    8000616e:	854a                	mv	a0,s2
    80006170:	70e6                	ld	ra,120(sp)
    80006172:	7446                	ld	s0,112(sp)
    80006174:	74a6                	ld	s1,104(sp)
    80006176:	7906                	ld	s2,96(sp)
    80006178:	6a46                	ld	s4,80(sp)
    8000617a:	6109                	addi	sp,sp,128
    8000617c:	8082                	ret
    8000617e:	69e6                	ld	s3,88(sp)
    80006180:	6aa6                	ld	s5,72(sp)
    80006182:	6b06                	ld	s6,64(sp)
    80006184:	7be2                	ld	s7,56(sp)
    80006186:	b7e5                	j	8000616e <fslog_read_many+0x72>

0000000080006188 <schedlog_init>:

static struct ringbuf sched_rb;

void
schedlog_init(void)
{
    80006188:	1141                	addi	sp,sp,-16
    8000618a:	e406                	sd	ra,8(sp)
    8000618c:	e022                	sd	s0,0(sp)
    8000618e:	0800                	addi	s0,sp,16
  ringbuf_init(&sched_rb, "schedlog", sizeof(struct sched_event));
    80006190:	04400613          	li	a2,68
    80006194:	00002597          	auipc	a1,0x2
    80006198:	5dc58593          	addi	a1,a1,1500 # 80008770 <etext+0x770>
    8000619c:	0002f517          	auipc	a0,0x2f
    800061a0:	8a450513          	addi	a0,a0,-1884 # 80034a40 <sched_rb>
    800061a4:	d19ff0ef          	jal	80005ebc <ringbuf_init>
}
    800061a8:	60a2                	ld	ra,8(sp)
    800061aa:	6402                	ld	s0,0(sp)
    800061ac:	0141                	addi	sp,sp,16
    800061ae:	8082                	ret

00000000800061b0 <schedlog_emit>:

void
schedlog_emit(struct sched_event *e)
{
    800061b0:	7159                	addi	sp,sp,-112
    800061b2:	f486                	sd	ra,104(sp)
    800061b4:	f0a2                	sd	s0,96(sp)
    800061b6:	eca6                	sd	s1,88(sp)
    800061b8:	1880                	addi	s0,sp,112
    800061ba:	85aa                	mv	a1,a0
  struct sched_event copy;

  memmove(&copy, e, sizeof(copy));
    800061bc:	f9840493          	addi	s1,s0,-104
    800061c0:	04400613          	li	a2,68
    800061c4:	8526                	mv	a0,s1
    800061c6:	bc5fa0ef          	jal	80000d8a <memmove>
  copy.seq = sched_rb.seq++;
    800061ca:	0002f717          	auipc	a4,0x2f
    800061ce:	87670713          	addi	a4,a4,-1930 # 80034a40 <sched_rb>
    800061d2:	771c                	ld	a5,40(a4)
    800061d4:	00178693          	addi	a3,a5,1
    800061d8:	f714                	sd	a3,40(a4)
    800061da:	f8f42c23          	sw	a5,-104(s0)
  ringbuf_push(&sched_rb, &copy);
    800061de:	85a6                	mv	a1,s1
    800061e0:	853a                	mv	a0,a4
    800061e2:	d0fff0ef          	jal	80005ef0 <ringbuf_push>
}
    800061e6:	70a6                	ld	ra,104(sp)
    800061e8:	7406                	ld	s0,96(sp)
    800061ea:	64e6                	ld	s1,88(sp)
    800061ec:	6165                	addi	sp,sp,112
    800061ee:	8082                	ret

00000000800061f0 <schedread>:

int
schedread(struct sched_event *dst, int max)
{
    800061f0:	1141                	addi	sp,sp,-16
    800061f2:	e406                	sd	ra,8(sp)
    800061f4:	e022                	sd	s0,0(sp)
    800061f6:	0800                	addi	s0,sp,16
    800061f8:	862e                	mv	a2,a1
  return ringbuf_read_many(&sched_rb, dst, max);
    800061fa:	85aa                	mv	a1,a0
    800061fc:	0002f517          	auipc	a0,0x2f
    80006200:	84450513          	addi	a0,a0,-1980 # 80034a40 <sched_rb>
    80006204:	d59ff0ef          	jal	80005f5c <ringbuf_read_many>
    80006208:	60a2                	ld	ra,8(sp)
    8000620a:	6402                	ld	s0,0(sp)
    8000620c:	0141                	addi	sp,sp,16
    8000620e:	8082                	ret
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
