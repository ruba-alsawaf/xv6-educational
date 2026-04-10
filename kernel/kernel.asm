
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
    80000004:	74813103          	ld	sp,1864(sp) # 8000b748 <_GLOBAL_OFFSET_TABLE_+0x8>
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
    80000072:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffb4c47>
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
    800000ea:	00013517          	auipc	a0,0x13
    800000ee:	6d650513          	addi	a0,a0,1750 # 800137c0 <conswlock>
    800000f2:	3aa040ef          	jal	8000449c <acquiresleep>

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
    80000126:	6d2020ef          	jal	800027f8 <either_copyin>
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
    8000016e:	65650513          	addi	a0,a0,1622 # 800137c0 <conswlock>
    80000172:	370040ef          	jal	800044e2 <releasesleep>
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
    800001aa:	64a50513          	addi	a0,a0,1610 # 800137f0 <cons>
    800001ae:	369000ef          	jal	80000d16 <acquire>

  while(n > 0){
    while(cons.r == cons.w){
    800001b2:	00013497          	auipc	s1,0x13
    800001b6:	60e48493          	addi	s1,s1,1550 # 800137c0 <conswlock>
      if(killed(myproc())){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    800001ba:	00013997          	auipc	s3,0x13
    800001be:	63698993          	addi	s3,s3,1590 # 800137f0 <cons>
    800001c2:	00013917          	auipc	s2,0x13
    800001c6:	6c690913          	addi	s2,s2,1734 # 80013888 <cons+0x98>
  while(n > 0){
    800001ca:	0b405c63          	blez	s4,80000282 <consoleread+0xfa>
    while(cons.r == cons.w){
    800001ce:	0c84a783          	lw	a5,200(s1)
    800001d2:	0cc4a703          	lw	a4,204(s1)
    800001d6:	0af71163          	bne	a4,a5,80000278 <consoleread+0xf0>
      if(killed(myproc())){
    800001da:	24f010ef          	jal	80001c28 <myproc>
    800001de:	4b2020ef          	jal	80002690 <killed>
    800001e2:	e12d                	bnez	a0,80000244 <consoleread+0xbc>
      sleep(&cons.r, &cons.lock);
    800001e4:	85ce                	mv	a1,s3
    800001e6:	854a                	mv	a0,s2
    800001e8:	26c020ef          	jal	80002454 <sleep>
    while(cons.r == cons.w){
    800001ec:	0c84a783          	lw	a5,200(s1)
    800001f0:	0cc4a703          	lw	a4,204(s1)
    800001f4:	fef703e3          	beq	a4,a5,800001da <consoleread+0x52>
    800001f8:	f05a                	sd	s6,32(sp)
    }

    c = cons.buf[cons.r++ % INPUT_BUF_SIZE];
    800001fa:	00013717          	auipc	a4,0x13
    800001fe:	5c670713          	addi	a4,a4,1478 # 800137c0 <conswlock>
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
    8000022c:	582020ef          	jal	800027ae <either_copyout>
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
    80000248:	5ac50513          	addi	a0,a0,1452 # 800137f0 <cons>
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
    8000026c:	00013717          	auipc	a4,0x13
    80000270:	60f72e23          	sw	a5,1564(a4) # 80013888 <cons+0x98>
    80000274:	7b02                	ld	s6,32(sp)
    80000276:	a031                	j	80000282 <consoleread+0xfa>
    80000278:	f05a                	sd	s6,32(sp)
    8000027a:	b741                	j	800001fa <consoleread+0x72>
    8000027c:	7b02                	ld	s6,32(sp)
    8000027e:	a011                	j	80000282 <consoleread+0xfa>
    80000280:	7b02                	ld	s6,32(sp)
  release(&cons.lock);
    80000282:	00013517          	auipc	a0,0x13
    80000286:	56e50513          	addi	a0,a0,1390 # 800137f0 <cons>
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
    800002d6:	00013517          	auipc	a0,0x13
    800002da:	51a50513          	addi	a0,a0,1306 # 800137f0 <cons>
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
    800002f8:	54a020ef          	jal	80002842 <procdump>
      }
    }
    break;
  }

  release(&cons.lock);
    800002fc:	00013517          	auipc	a0,0x13
    80000300:	4f450513          	addi	a0,a0,1268 # 800137f0 <cons>
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
    8000031a:	00013717          	auipc	a4,0x13
    8000031e:	4a670713          	addi	a4,a4,1190 # 800137c0 <conswlock>
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
    80000344:	48070713          	addi	a4,a4,1152 # 800137c0 <conswlock>
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
    8000036e:	51e72703          	lw	a4,1310(a4) # 80013888 <cons+0x98>
    80000372:	9f99                	subw	a5,a5,a4
    80000374:	08000713          	li	a4,128
    80000378:	f8e792e3          	bne	a5,a4,800002fc <consoleintr+0x32>
    8000037c:	a075                	j	80000428 <consoleintr+0x15e>
    8000037e:	e04a                	sd	s2,0(sp)
    while(cons.e != cons.w &&
    80000380:	00013717          	auipc	a4,0x13
    80000384:	44070713          	addi	a4,a4,1088 # 800137c0 <conswlock>
    80000388:	0d072783          	lw	a5,208(a4)
    8000038c:	0cc72703          	lw	a4,204(a4)
          cons.buf[(cons.e - 1) % INPUT_BUF_SIZE] != '\n'){
    80000390:	00013497          	auipc	s1,0x13
    80000394:	43048493          	addi	s1,s1,1072 # 800137c0 <conswlock>
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
    800003d6:	3ee70713          	addi	a4,a4,1006 # 800137c0 <conswlock>
    800003da:	0d072783          	lw	a5,208(a4)
    800003de:	0cc72703          	lw	a4,204(a4)
    800003e2:	f0f70de3          	beq	a4,a5,800002fc <consoleintr+0x32>
      cons.e--;
    800003e6:	37fd                	addiw	a5,a5,-1
    800003e8:	00013717          	auipc	a4,0x13
    800003ec:	4af72423          	sw	a5,1192(a4) # 80013890 <cons+0xa0>
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
    8000040a:	3ba78793          	addi	a5,a5,954 # 800137c0 <conswlock>
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
    8000042c:	46c7a223          	sw	a2,1124(a5) # 8001388c <cons+0x9c>
        wakeup(&cons.r);
    80000430:	00013517          	auipc	a0,0x13
    80000434:	45850513          	addi	a0,a0,1112 # 80013888 <cons+0x98>
    80000438:	068020ef          	jal	800024a0 <wakeup>
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
    80000452:	3a250513          	addi	a0,a0,930 # 800137f0 <cons>
    80000456:	037000ef          	jal	80000c8c <initlock>
  initsleeplock(&conswlock, "consw");
    8000045a:	00008597          	auipc	a1,0x8
    8000045e:	bb658593          	addi	a1,a1,-1098 # 80008010 <etext+0x10>
    80000462:	00013517          	auipc	a0,0x13
    80000466:	35e50513          	addi	a0,a0,862 # 800137c0 <conswlock>
    8000046a:	7fd030ef          	jal	80004466 <initsleeplock>

  uartinit();
    8000046e:	448000ef          	jal	800008b6 <uartinit>

  devsw[CONSOLE].read = consoleread;
    80000472:	00023797          	auipc	a5,0x23
    80000476:	50678793          	addi	a5,a5,1286 # 80023978 <devsw>
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
    8000054a:	0000b797          	auipc	a5,0xb
    8000054e:	21a7a783          	lw	a5,538(a5) # 8000b764 <panicking>
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
    80000594:	30850513          	addi	a0,a0,776 # 80013898 <pr>
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
    8000078c:	0000b797          	auipc	a5,0xb
    80000790:	fd87a783          	lw	a5,-40(a5) # 8000b764 <panicking>
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
    800007ba:	0e250513          	addi	a0,a0,226 # 80013898 <pr>
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
    80000866:	0000b797          	auipc	a5,0xb
    8000086a:	ee97af23          	sw	s1,-258(a5) # 8000b764 <panicking>
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
    8000088c:	ec97ac23          	sw	s1,-296(a5) # 8000b760 <panicked>
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
    800008a6:	ff650513          	addi	a0,a0,-10 # 80013898 <pr>
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
    800008f8:	00013517          	auipc	a0,0x13
    800008fc:	fb850513          	addi	a0,a0,-72 # 800138b0 <tx_lock>
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
    8000091c:	00013517          	auipc	a0,0x13
    80000920:	f9450513          	addi	a0,a0,-108 # 800138b0 <tx_lock>
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
    8000093a:	0000b497          	auipc	s1,0xb
    8000093e:	e3248493          	addi	s1,s1,-462 # 8000b76c <tx_busy>
      // wait for a UART transmit-complete interrupt
      // to set tx_busy to 0.
      sleep(&tx_chan, &tx_lock);
    80000942:	00013997          	auipc	s3,0x13
    80000946:	f6e98993          	addi	s3,s3,-146 # 800138b0 <tx_lock>
    8000094a:	0000b917          	auipc	s2,0xb
    8000094e:	e1e90913          	addi	s2,s2,-482 # 8000b768 <tx_chan>
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
    8000095e:	2f7010ef          	jal	80002454 <sleep>
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
    8000098c:	f2850513          	addi	a0,a0,-216 # 800138b0 <tx_lock>
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
    800009ac:	0000b797          	auipc	a5,0xb
    800009b0:	db87a783          	lw	a5,-584(a5) # 8000b764 <panicking>
    800009b4:	cf95                	beqz	a5,800009f0 <uartputc_sync+0x50>
    push_off();

  if(panicked){
    800009b6:	0000b797          	auipc	a5,0xb
    800009ba:	daa7a783          	lw	a5,-598(a5) # 8000b760 <panicked>
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
    800009e0:	d887a783          	lw	a5,-632(a5) # 8000b764 <panicking>
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
    80000a38:	00013517          	auipc	a0,0x13
    80000a3c:	e7850513          	addi	a0,a0,-392 # 800138b0 <tx_lock>
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
    80000a52:	00013517          	auipc	a0,0x13
    80000a56:	e5e50513          	addi	a0,a0,-418 # 800138b0 <tx_lock>
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
    80000a6e:	0000b797          	auipc	a5,0xb
    80000a72:	ce07af23          	sw	zero,-770(a5) # 8000b76c <tx_busy>
    wakeup(&tx_chan);
    80000a76:	0000b517          	auipc	a0,0xb
    80000a7a:	cf250513          	addi	a0,a0,-782 # 8000b768 <tx_chan>
    80000a7e:	223010ef          	jal	800024a0 <wakeup>
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
    80000a9a:	00049797          	auipc	a5,0x49
    80000a9e:	11e78793          	addi	a5,a5,286 # 80049bb8 <end>
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
    80000ac4:	00013917          	auipc	s2,0x13
    80000ac8:	e0490913          	addi	s2,s2,-508 # 800138c8 <kmem>
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
    80000af0:	0000b797          	auipc	a5,0xb
    80000af4:	ca07a783          	lw	a5,-864(a5) # 8000b790 <ticks>
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
    80000b3c:	1a1050ef          	jal	800064dc <memlog_push>
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
    80000bb0:	00013517          	auipc	a0,0x13
    80000bb4:	d1850513          	addi	a0,a0,-744 # 800138c8 <kmem>
    80000bb8:	0d4000ef          	jal	80000c8c <initlock>
  freerange(end, (void*)PHYSTOP);
    80000bbc:	45c5                	li	a1,17
    80000bbe:	05ee                	slli	a1,a1,0x1b
    80000bc0:	00049517          	auipc	a0,0x49
    80000bc4:	ff850513          	addi	a0,a0,-8 # 80049bb8 <end>
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
    80000bde:	00013517          	auipc	a0,0x13
    80000be2:	cea50513          	addi	a0,a0,-790 # 800138c8 <kmem>
    80000be6:	130000ef          	jal	80000d16 <acquire>
  r = kmem.freelist;
    80000bea:	00013497          	auipc	s1,0x13
    80000bee:	cf64b483          	ld	s1,-778(s1) # 800138e0 <kmem+0x18>
  if(r)
    80000bf2:	c4d1                	beqz	s1,80000c7e <kalloc+0xaa>
    kmem.freelist = r->next;
    80000bf4:	609c                	ld	a5,0(s1)
    80000bf6:	00013717          	auipc	a4,0x13
    80000bfa:	cef73523          	sd	a5,-790(a4) # 800138e0 <kmem+0x18>
  release(&kmem.lock);
    80000bfe:	00013517          	auipc	a0,0x13
    80000c02:	cca50513          	addi	a0,a0,-822 # 800138c8 <kmem>
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
    80000c22:	0000b797          	auipc	a5,0xb
    80000c26:	b6e7a783          	lw	a5,-1170(a5) # 8000b790 <ticks>
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
    80000c6e:	06f050ef          	jal	800064dc <memlog_push>
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
    80000c7e:	00013517          	auipc	a0,0x13
    80000c82:	c4a50513          	addi	a0,a0,-950 # 800138c8 <kmem>
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
    80000fa8:	0000a717          	auipc	a4,0xa
    80000fac:	7c870713          	addi	a4,a4,1992 # 8000b770 <started>
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
    80000fd2:	1a3010ef          	jal	80002974 <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000fd6:	2c3040ef          	jal	80005a98 <plicinithart>
  }

  scheduler();        
    80000fda:	130010ef          	jal	8000210a <scheduler>
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
    8000101a:	6fc050ef          	jal	80006716 <schedlog_init>
    trapinit();      // trap vectors
    8000101e:	133010ef          	jal	80002950 <trapinit>
    trapinithart();  // install kernel trap vector
    80001022:	153010ef          	jal	80002974 <trapinithart>
    plicinit();      // set up interrupt controller
    80001026:	259040ef          	jal	80005a7e <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    8000102a:	26f040ef          	jal	80005a98 <plicinithart>
    binit();         // buffer cache
    8000102e:	072020ef          	jal	800030a0 <binit>
    iinit();         // inode table
    80001032:	602020ef          	jal	80003634 <iinit>
    fileinit();      // file table
    80001036:	52e030ef          	jal	80004564 <fileinit>
    virtio_disk_init(); // emulated hard disk
    8000103a:	34f040ef          	jal	80005b88 <virtio_disk_init>
    cslog_init();
    8000103e:	7d1040ef          	jal	8000600e <cslog_init>
    memlog_init();
    80001042:	456050ef          	jal	80006498 <memlog_init>
    userinit();      // first user process
    80001046:	6ad000ef          	jal	80001ef2 <userinit>
    __sync_synchronize();
    8000104a:	0330000f          	fence	rw,rw
    started = 1;
    8000104e:	4785                	li	a5,1
    80001050:	0000a717          	auipc	a4,0xa
    80001054:	72f72023          	sw	a5,1824(a4) # 8000b770 <started>
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
    80001066:	0000a797          	auipc	a5,0xa
    8000106a:	7127b783          	ld	a5,1810(a5) # 8000b778 <kernel_pagetable>
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
    800011a2:	0000ad97          	auipc	s11,0xa
    800011a6:	5eed8d93          	addi	s11,s11,1518 # 8000b790 <ticks>
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
    80001266:	276050ef          	jal	800064dc <memlog_push>
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
    80001372:	0000a797          	auipc	a5,0xa
    80001376:	40a7b323          	sd	a0,1030(a5) # 8000b778 <kernel_pagetable>
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
    800013e0:	0000ad97          	auipc	s11,0xa
    800013e4:	3b0d8d93          	addi	s11,s11,944 # 8000b790 <ticks>
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
    8000149c:	040050ef          	jal	800064dc <memlog_push>
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
    80001552:	0000a797          	auipc	a5,0xa
    80001556:	23e7a783          	lw	a5,574(a5) # 8000b790 <ticks>
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
    8000159e:	73f040ef          	jal	800064dc <memlog_push>
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
    80001818:	00074703          	lbu	a4,0(a4) # fffffffffffff000 <end+0xffffffff7ffb5448>
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
    800018b8:	0000a797          	auipc	a5,0xa
    800018bc:	ed87a783          	lw	a5,-296(a5) # 8000b790 <ticks>
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
    80001900:	3dd040ef          	jal	800064dc <memlog_push>
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
    80001aa0:	00012497          	auipc	s1,0x12
    80001aa4:	29048493          	addi	s1,s1,656 # 80013d30 <proc>
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
    80001ad0:	00018a97          	auipc	s5,0x18
    80001ad4:	c60a8a93          	addi	s5,s5,-928 # 80019730 <tickslock>
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
    80001b46:	00012517          	auipc	a0,0x12
    80001b4a:	da250513          	addi	a0,a0,-606 # 800138e8 <pid_lock>
    80001b4e:	93eff0ef          	jal	80000c8c <initlock>
  initlock(&wait_lock, "wait_lock");
    80001b52:	00006597          	auipc	a1,0x6
    80001b56:	61e58593          	addi	a1,a1,1566 # 80008170 <etext+0x170>
    80001b5a:	00012517          	auipc	a0,0x12
    80001b5e:	da650513          	addi	a0,a0,-602 # 80013900 <wait_lock>
    80001b62:	92aff0ef          	jal	80000c8c <initlock>
  initlock(&schedinfo_lock, "schedinfo");
    80001b66:	00006597          	auipc	a1,0x6
    80001b6a:	61a58593          	addi	a1,a1,1562 # 80008180 <etext+0x180>
    80001b6e:	00012517          	auipc	a0,0x12
    80001b72:	daa50513          	addi	a0,a0,-598 # 80013918 <schedinfo_lock>
    80001b76:	916ff0ef          	jal	80000c8c <initlock>
  for (p = proc; p < &proc[NPROC]; p++) {
    80001b7a:	00012497          	auipc	s1,0x12
    80001b7e:	1b648493          	addi	s1,s1,438 # 80013d30 <proc>
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
    80001bae:	00018a17          	auipc	s4,0x18
    80001bb2:	b82a0a13          	addi	s4,s4,-1150 # 80019730 <tickslock>
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
    80001c16:	00012517          	auipc	a0,0x12
    80001c1a:	d1a50513          	addi	a0,a0,-742 # 80013930 <cpus>
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
    80001c3c:	00012717          	auipc	a4,0x12
    80001c40:	cac70713          	addi	a4,a4,-852 # 800138e8 <pid_lock>
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
    80001c6e:	0000a797          	auipc	a5,0xa
    80001c72:	ac27a783          	lw	a5,-1342(a5) # 8000b730 <first.1>
    80001c76:	cf95                	beqz	a5,80001cb2 <forkret+0x58>
    // File system initialization must be run in the context of a
    // regular process (e.g., because it calls sleep), and thus cannot
    // be run from main().
    fsinit(ROOTDEV);
    80001c78:	4505                	li	a0,1
    80001c7a:	677010ef          	jal	80003af0 <fsinit>

    first = 0;
    80001c7e:	0000a797          	auipc	a5,0xa
    80001c82:	aa07a923          	sw	zero,-1358(a5) # 8000b730 <first.1>
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
    80001ca0:	7d9020ef          	jal	80004c78 <kexec>
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
    80001cb2:	4df000ef          	jal	80002990 <prepare_return>
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
    80001cfe:	00012517          	auipc	a0,0x12
    80001d02:	bea50513          	addi	a0,a0,-1046 # 800138e8 <pid_lock>
    80001d06:	810ff0ef          	jal	80000d16 <acquire>
  pid = nextpid;
    80001d0a:	0000a797          	auipc	a5,0xa
    80001d0e:	a2a78793          	addi	a5,a5,-1494 # 8000b734 <nextpid>
    80001d12:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80001d14:	0014871b          	addiw	a4,s1,1
    80001d18:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001d1a:	00012517          	auipc	a0,0x12
    80001d1e:	bce50513          	addi	a0,a0,-1074 # 800138e8 <pid_lock>
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
    80001e58:	00012497          	auipc	s1,0x12
    80001e5c:	ed848493          	addi	s1,s1,-296 # 80013d30 <proc>
    80001e60:	00018917          	auipc	s2,0x18
    80001e64:	8d090913          	addi	s2,s2,-1840 # 80019730 <tickslock>
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
    80001f02:	0000a797          	auipc	a5,0xa
    80001f06:	88a7b323          	sd	a0,-1914(a5) # 8000b788 <initproc>
  p->cwd = namei("/");
    80001f0a:	00006517          	auipc	a0,0x6
    80001f0e:	29e50513          	addi	a0,a0,670 # 800081a8 <etext+0x1a8>
    80001f12:	118020ef          	jal	8000402a <namei>
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
    80001f58:	08c7ee63          	bltu	a5,a2,80001ff4 <growproc+0xc6>
    if ((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0) {
    80001f5c:	4691                	li	a3,4
    80001f5e:	85ca                	mv	a1,s2
    80001f60:	6928                	ld	a0,80(a0)
    80001f62:	daaff0ef          	jal	8000150c <uvmalloc>
    80001f66:	892a                	mv	s2,a0
    80001f68:	c941                	beqz	a0,80001ff8 <growproc+0xca>
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
  memset(&e, 0, sizeof(e));
    80001f82:	06800613          	li	a2,104
    80001f86:	4581                	li	a1,0
    80001f88:	f6840513          	addi	a0,s0,-152
    80001f8c:	e5bfe0ef          	jal	80000de6 <memset>
  e.ticks  = ticks;
    80001f90:	0000a797          	auipc	a5,0xa
    80001f94:	8007a783          	lw	a5,-2048(a5) # 8000b790 <ticks>
    80001f98:	f6f42823          	sw	a5,-144(s0)
    80001f9c:	8792                	mv	a5,tp
  int id = r_tp();
    80001f9e:	f6f42a23          	sw	a5,-140(s0)
  e.type   = MEM_SHRINK;
    80001fa2:	4789                	li	a5,2
    80001fa4:	f6f42c23          	sw	a5,-136(s0)
  e.pid    = p->pid;
    80001fa8:	0309a783          	lw	a5,48(s3)
    80001fac:	f6f42e23          	sw	a5,-132(s0)
  e.state  = p->state;
    80001fb0:	0189a783          	lw	a5,24(s3)
    80001fb4:	f8f42023          	sw	a5,-128(s0)
  e.oldsz  = sz;
    80001fb8:	fb243423          	sd	s2,-88(s0)
  e.newsz  = sz + n;
    80001fbc:	94ca                	add	s1,s1,s2
    80001fbe:	fa943823          	sd	s1,-80(s0)
  e.source = SRC_UVMDEALLOC;
    80001fc2:	4799                	li	a5,6
    80001fc4:	fcf42223          	sw	a5,-60(s0)
  e.kind   = PAGE_USER;
    80001fc8:	4785                	li	a5,1
    80001fca:	fcf42423          	sw	a5,-56(s0)
  safestrcpy(e.name, p->name, MEM_NM);
    80001fce:	4641                	li	a2,16
    80001fd0:	15898593          	addi	a1,s3,344
    80001fd4:	f8440513          	addi	a0,s0,-124
    80001fd8:	f63fe0ef          	jal	80000f3a <safestrcpy>
  memlog_push(&e);
    80001fdc:	f6840513          	addi	a0,s0,-152
    80001fe0:	4fc040ef          	jal	800064dc <memlog_push>
  sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001fe4:	8626                	mv	a2,s1
    80001fe6:	85ca                	mv	a1,s2
    80001fe8:	0509b503          	ld	a0,80(s3)
    80001fec:	cdcff0ef          	jal	800014c8 <uvmdealloc>
    80001ff0:	892a                	mv	s2,a0
    80001ff2:	bfa5                	j	80001f6a <growproc+0x3c>
      return -1;
    80001ff4:	557d                	li	a0,-1
    80001ff6:	bfad                	j	80001f70 <growproc+0x42>
      return -1;
    80001ff8:	557d                	li	a0,-1
    80001ffa:	bf9d                	j	80001f70 <growproc+0x42>

0000000080001ffc <kfork>:
int kfork(void) {
    80001ffc:	7139                	addi	sp,sp,-64
    80001ffe:	fc06                	sd	ra,56(sp)
    80002000:	f822                	sd	s0,48(sp)
    80002002:	f426                	sd	s1,40(sp)
    80002004:	e456                	sd	s5,8(sp)
    80002006:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    80002008:	c21ff0ef          	jal	80001c28 <myproc>
    8000200c:	8aaa                	mv	s5,a0
  if ((np = allocproc()) == 0) {
    8000200e:	e3fff0ef          	jal	80001e4c <allocproc>
    80002012:	0e050a63          	beqz	a0,80002106 <kfork+0x10a>
    80002016:	e852                	sd	s4,16(sp)
    80002018:	8a2a                	mv	s4,a0
  if (uvmcopy(p->pagetable, np->pagetable, p->sz) < 0) {
    8000201a:	048ab603          	ld	a2,72(s5)
    8000201e:	692c                	ld	a1,80(a0)
    80002020:	050ab503          	ld	a0,80(s5)
    80002024:	ea2ff0ef          	jal	800016c6 <uvmcopy>
    80002028:	04054863          	bltz	a0,80002078 <kfork+0x7c>
    8000202c:	f04a                	sd	s2,32(sp)
    8000202e:	ec4e                	sd	s3,24(sp)
  np->sz = p->sz;
    80002030:	048ab783          	ld	a5,72(s5)
    80002034:	04fa3423          	sd	a5,72(s4)
  *(np->trapframe) = *(p->trapframe);
    80002038:	058ab683          	ld	a3,88(s5)
    8000203c:	87b6                	mv	a5,a3
    8000203e:	058a3703          	ld	a4,88(s4)
    80002042:	12068693          	addi	a3,a3,288
    80002046:	6388                	ld	a0,0(a5)
    80002048:	678c                	ld	a1,8(a5)
    8000204a:	6b90                	ld	a2,16(a5)
    8000204c:	e308                	sd	a0,0(a4)
    8000204e:	e70c                	sd	a1,8(a4)
    80002050:	eb10                	sd	a2,16(a4)
    80002052:	6f90                	ld	a2,24(a5)
    80002054:	ef10                	sd	a2,24(a4)
    80002056:	02078793          	addi	a5,a5,32
    8000205a:	02070713          	addi	a4,a4,32 # 1020 <_entry-0x7fffefe0>
    8000205e:	fed794e3          	bne	a5,a3,80002046 <kfork+0x4a>
  np->trapframe->a0 = 0;
    80002062:	058a3783          	ld	a5,88(s4)
    80002066:	0607b823          	sd	zero,112(a5)
  for (i = 0; i < NOFILE; i++)
    8000206a:	0d0a8493          	addi	s1,s5,208
    8000206e:	0d0a0913          	addi	s2,s4,208
    80002072:	150a8993          	addi	s3,s5,336
    80002076:	a831                	j	80002092 <kfork+0x96>
    freeproc(np);
    80002078:	8552                	mv	a0,s4
    8000207a:	d83ff0ef          	jal	80001dfc <freeproc>
    release(&np->lock);
    8000207e:	8552                	mv	a0,s4
    80002080:	d2bfe0ef          	jal	80000daa <release>
    return -1;
    80002084:	54fd                	li	s1,-1
    80002086:	6a42                	ld	s4,16(sp)
    80002088:	a885                	j	800020f8 <kfork+0xfc>
  for (i = 0; i < NOFILE; i++)
    8000208a:	04a1                	addi	s1,s1,8
    8000208c:	0921                	addi	s2,s2,8
    8000208e:	01348963          	beq	s1,s3,800020a0 <kfork+0xa4>
    if (p->ofile[i])
    80002092:	6088                	ld	a0,0(s1)
    80002094:	d97d                	beqz	a0,8000208a <kfork+0x8e>
      np->ofile[i] = filedup(p->ofile[i]);
    80002096:	550020ef          	jal	800045e6 <filedup>
    8000209a:	00a93023          	sd	a0,0(s2)
    8000209e:	b7f5                	j	8000208a <kfork+0x8e>
  np->cwd = idup(p->cwd);
    800020a0:	150ab503          	ld	a0,336(s5)
    800020a4:	722010ef          	jal	800037c6 <idup>
    800020a8:	14aa3823          	sd	a0,336(s4)
  safestrcpy(np->name, p->name, sizeof(p->name));
    800020ac:	4641                	li	a2,16
    800020ae:	158a8593          	addi	a1,s5,344
    800020b2:	158a0513          	addi	a0,s4,344
    800020b6:	e85fe0ef          	jal	80000f3a <safestrcpy>
  pid = np->pid;
    800020ba:	030a2483          	lw	s1,48(s4)
  release(&np->lock);
    800020be:	8552                	mv	a0,s4
    800020c0:	cebfe0ef          	jal	80000daa <release>
  acquire(&wait_lock);
    800020c4:	00012517          	auipc	a0,0x12
    800020c8:	83c50513          	addi	a0,a0,-1988 # 80013900 <wait_lock>
    800020cc:	c4bfe0ef          	jal	80000d16 <acquire>
  np->parent = p;
    800020d0:	035a3c23          	sd	s5,56(s4)
  release(&wait_lock);
    800020d4:	00012517          	auipc	a0,0x12
    800020d8:	82c50513          	addi	a0,a0,-2004 # 80013900 <wait_lock>
    800020dc:	ccffe0ef          	jal	80000daa <release>
  acquire(&np->lock);
    800020e0:	8552                	mv	a0,s4
    800020e2:	c35fe0ef          	jal	80000d16 <acquire>
  np->state = RUNNABLE;
    800020e6:	478d                	li	a5,3
    800020e8:	00fa2c23          	sw	a5,24(s4)
  release(&np->lock);
    800020ec:	8552                	mv	a0,s4
    800020ee:	cbdfe0ef          	jal	80000daa <release>
  return pid;
    800020f2:	7902                	ld	s2,32(sp)
    800020f4:	69e2                	ld	s3,24(sp)
    800020f6:	6a42                	ld	s4,16(sp)
}
    800020f8:	8526                	mv	a0,s1
    800020fa:	70e2                	ld	ra,56(sp)
    800020fc:	7442                	ld	s0,48(sp)
    800020fe:	74a2                	ld	s1,40(sp)
    80002100:	6aa2                	ld	s5,8(sp)
    80002102:	6121                	addi	sp,sp,64
    80002104:	8082                	ret
    return -1;
    80002106:	54fd                	li	s1,-1
    80002108:	bfc5                	j	800020f8 <kfork+0xfc>

000000008000210a <scheduler>:
void scheduler(void) {
    8000210a:	7171                	addi	sp,sp,-176
    8000210c:	f506                	sd	ra,168(sp)
    8000210e:	f122                	sd	s0,160(sp)
    80002110:	ed26                	sd	s1,152(sp)
    80002112:	e94a                	sd	s2,144(sp)
    80002114:	e54e                	sd	s3,136(sp)
    80002116:	e152                	sd	s4,128(sp)
    80002118:	fcd6                	sd	s5,120(sp)
    8000211a:	f8da                	sd	s6,112(sp)
    8000211c:	f4de                	sd	s7,104(sp)
    8000211e:	f0e2                	sd	s8,96(sp)
    80002120:	ece6                	sd	s9,88(sp)
    80002122:	e8ea                	sd	s10,80(sp)
    80002124:	1900                	addi	s0,sp,176
    80002126:	8492                	mv	s1,tp
  int id = r_tp();
    80002128:	2481                	sext.w	s1,s1
    8000212a:	8792                	mv	a5,tp
    if(cpuid() == 0){
    8000212c:	2781                	sext.w	a5,a5
    8000212e:	c79d                	beqz	a5,8000215c <scheduler+0x52>
  c->proc = 0;
    80002130:	00749b93          	slli	s7,s1,0x7
    80002134:	00011797          	auipc	a5,0x11
    80002138:	7b478793          	addi	a5,a5,1972 # 800138e8 <pid_lock>
    8000213c:	97de                	add	a5,a5,s7
    8000213e:	0407b423          	sd	zero,72(a5)
        swtch(&c->context, &p->context);
    80002142:	00011797          	auipc	a5,0x11
    80002146:	7f678793          	addi	a5,a5,2038 # 80013938 <cpus+0x8>
    8000214a:	9bbe                	add	s7,s7,a5
        p->state = RUNNING;
    8000214c:	4b11                	li	s6,4
        c->proc = p;
    8000214e:	049e                	slli	s1,s1,0x7
    80002150:	00011a97          	auipc	s5,0x11
    80002154:	798a8a93          	addi	s5,s5,1944 # 800138e8 <pid_lock>
    80002158:	9aa6                	add	s5,s5,s1
    8000215a:	a2d5                	j	8000233e <scheduler+0x234>
      acquire(&schedinfo_lock);
    8000215c:	00011517          	auipc	a0,0x11
    80002160:	7bc50513          	addi	a0,a0,1980 # 80013918 <schedinfo_lock>
    80002164:	bb3fe0ef          	jal	80000d16 <acquire>
      if(sched_info_logged == 0){
    80002168:	00009797          	auipc	a5,0x9
    8000216c:	6187a783          	lw	a5,1560(a5) # 8000b780 <sched_info_logged>
    80002170:	cb81                	beqz	a5,80002180 <scheduler+0x76>
      release(&schedinfo_lock);
    80002172:	00011517          	auipc	a0,0x11
    80002176:	7a650513          	addi	a0,a0,1958 # 80013918 <schedinfo_lock>
    8000217a:	c31fe0ef          	jal	80000daa <release>
    8000217e:	bf4d                	j	80002130 <scheduler+0x26>
        sched_info_logged = 1;
    80002180:	4905                	li	s2,1
    80002182:	00009797          	auipc	a5,0x9
    80002186:	5f27af23          	sw	s2,1534(a5) # 8000b780 <sched_info_logged>
        memset(&e, 0, sizeof(e));
    8000218a:	f5840993          	addi	s3,s0,-168
    8000218e:	04400613          	li	a2,68
    80002192:	4581                	li	a1,0
    80002194:	854e                	mv	a0,s3
    80002196:	c51fe0ef          	jal	80000de6 <memset>
        e.ticks = ticks;
    8000219a:	00009797          	auipc	a5,0x9
    8000219e:	5f67a783          	lw	a5,1526(a5) # 8000b790 <ticks>
    800021a2:	f4f42e23          	sw	a5,-164(s0)
        e.event_type = SCHED_EV_INFO;
    800021a6:	f7242023          	sw	s2,-160(s0)
        safestrcpy(e.scheduler_name, "RR", sizeof(e.scheduler_name));
    800021aa:	4641                	li	a2,16
    800021ac:	00006597          	auipc	a1,0x6
    800021b0:	00458593          	addi	a1,a1,4 # 800081b0 <etext+0x1b0>
    800021b4:	f6440513          	addi	a0,s0,-156
    800021b8:	d83fe0ef          	jal	80000f3a <safestrcpy>
        e.num_cpus = 3;
    800021bc:	478d                	li	a5,3
    800021be:	f6f42a23          	sw	a5,-140(s0)
        e.time_slice = 1;
    800021c2:	f7242c23          	sw	s2,-136(s0)
        schedlog_emit(&e);
    800021c6:	854e                	mv	a0,s3
    800021c8:	576040ef          	jal	8000673e <schedlog_emit>
    800021cc:	b75d                	j	80002172 <scheduler+0x68>
        if(strncmp(p->name, "schedexport", 16) != 0){
    800021ce:	158c8c13          	addi	s8,s9,344
    800021d2:	864e                	mv	a2,s3
    800021d4:	85d2                	mv	a1,s4
    800021d6:	8562                	mv	a0,s8
    800021d8:	ce3fe0ef          	jal	80000eba <strncmp>
    800021dc:	e945                	bnez	a0,8000228c <scheduler+0x182>
        swtch(&c->context, &p->context);
    800021de:	060c8593          	addi	a1,s9,96
    800021e2:	855e                	mv	a0,s7
    800021e4:	702000ef          	jal	800028e6 <swtch>
        if(strncmp(p->name, "schedexport", 16) != 0){
    800021e8:	864e                	mv	a2,s3
    800021ea:	85d2                	mv	a1,s4
    800021ec:	8562                	mv	a0,s8
    800021ee:	ccdfe0ef          	jal	80000eba <strncmp>
    800021f2:	0e051163          	bnez	a0,800022d4 <scheduler+0x1ca>
        c->proc = 0;
    800021f6:	040ab423          	sd	zero,72(s5)
        found = 1;
    800021fa:	4c05                	li	s8,1
      release(&p->lock);
    800021fc:	8526                	mv	a0,s1
    800021fe:	badfe0ef          	jal	80000daa <release>
    for (p = proc; p < &proc[NPROC]; p++) {
    80002202:	16848493          	addi	s1,s1,360
    80002206:	00017797          	auipc	a5,0x17
    8000220a:	52a78793          	addi	a5,a5,1322 # 80019730 <tickslock>
    8000220e:	12f48463          	beq	s1,a5,80002336 <scheduler+0x22c>
      acquire(&p->lock);
    80002212:	8526                	mv	a0,s1
    80002214:	b03fe0ef          	jal	80000d16 <acquire>
      if (p->state == RUNNABLE) {
    80002218:	4c9c                	lw	a5,24(s1)
    8000221a:	ff2791e3          	bne	a5,s2,800021fc <scheduler+0xf2>
    8000221e:	8ca6                	mv	s9,s1
        p->state = RUNNING;
    80002220:	0164ac23          	sw	s6,24(s1)
        c->proc = p;
    80002224:	049ab423          	sd	s1,72(s5)
        cslog_run_start(p);
    80002228:	8526                	mv	a0,s1
    8000222a:	65b030ef          	jal	80006084 <cslog_run_start>
    8000222e:	8792                	mv	a5,tp
        if (cpuid() == 0 && sched_info_logged == 0) {
    80002230:	2781                	sext.w	a5,a5
    80002232:	ffd1                	bnez	a5,800021ce <scheduler+0xc4>
    80002234:	00009797          	auipc	a5,0x9
    80002238:	54c7a783          	lw	a5,1356(a5) # 8000b780 <sched_info_logged>
    8000223c:	fbc9                	bnez	a5,800021ce <scheduler+0xc4>
          sched_info_logged = 1;
    8000223e:	4c05                	li	s8,1
    80002240:	00009797          	auipc	a5,0x9
    80002244:	5587a023          	sw	s8,1344(a5) # 8000b780 <sched_info_logged>
          memset(&e, 0, sizeof(e));
    80002248:	f5840d13          	addi	s10,s0,-168
    8000224c:	04400613          	li	a2,68
    80002250:	4581                	li	a1,0
    80002252:	856a                	mv	a0,s10
    80002254:	b93fe0ef          	jal	80000de6 <memset>
          e.ticks = ticks;
    80002258:	00009797          	auipc	a5,0x9
    8000225c:	5387a783          	lw	a5,1336(a5) # 8000b790 <ticks>
    80002260:	f4f42e23          	sw	a5,-164(s0)
          e.event_type = SCHED_EV_INFO;
    80002264:	f7842023          	sw	s8,-160(s0)
          safestrcpy(e.scheduler_name, "RR", sizeof(e.scheduler_name));
    80002268:	864e                	mv	a2,s3
    8000226a:	00006597          	auipc	a1,0x6
    8000226e:	f4658593          	addi	a1,a1,-186 # 800081b0 <etext+0x1b0>
    80002272:	f6440513          	addi	a0,s0,-156
    80002276:	cc5fe0ef          	jal	80000f3a <safestrcpy>
          e.num_cpus = NCPU;
    8000227a:	47a1                	li	a5,8
    8000227c:	f6f42a23          	sw	a5,-140(s0)
          e.time_slice = 1;
    80002280:	f7842c23          	sw	s8,-136(s0)
          schedlog_emit(&e);
    80002284:	856a                	mv	a0,s10
    80002286:	4b8040ef          	jal	8000673e <schedlog_emit>
    8000228a:	b791                	j	800021ce <scheduler+0xc4>
          memset(&e, 0, sizeof(e));
    8000228c:	f5840d13          	addi	s10,s0,-168
    80002290:	04400613          	li	a2,68
    80002294:	4581                	li	a1,0
    80002296:	856a                	mv	a0,s10
    80002298:	b4ffe0ef          	jal	80000de6 <memset>
          e.ticks = ticks;
    8000229c:	00009797          	auipc	a5,0x9
    800022a0:	4f47a783          	lw	a5,1268(a5) # 8000b790 <ticks>
    800022a4:	f4f42e23          	sw	a5,-164(s0)
          e.event_type = SCHED_EV_ON_CPU;
    800022a8:	4789                	li	a5,2
    800022aa:	f6f42023          	sw	a5,-160(s0)
    800022ae:	8792                	mv	a5,tp
  int id = r_tp();
    800022b0:	f6f42e23          	sw	a5,-132(s0)
          e.pid = p->pid;
    800022b4:	589c                	lw	a5,48(s1)
    800022b6:	f8f42023          	sw	a5,-128(s0)
          safestrcpy(e.name, p->name, sizeof(e.name));
    800022ba:	864e                	mv	a2,s3
    800022bc:	85e2                	mv	a1,s8
    800022be:	f8440513          	addi	a0,s0,-124
    800022c2:	c79fe0ef          	jal	80000f3a <safestrcpy>
          e.state = p->state;
    800022c6:	4c9c                	lw	a5,24(s1)
    800022c8:	f8f42a23          	sw	a5,-108(s0)
          schedlog_emit(&e);
    800022cc:	856a                	mv	a0,s10
    800022ce:	470040ef          	jal	8000673e <schedlog_emit>
    800022d2:	b731                	j	800021de <scheduler+0xd4>
          memset(&e2, 0, sizeof(e2));
    800022d4:	04400613          	li	a2,68
    800022d8:	4581                	li	a1,0
    800022da:	f5840513          	addi	a0,s0,-168
    800022de:	b09fe0ef          	jal	80000de6 <memset>
          e2.ticks = ticks;
    800022e2:	00009797          	auipc	a5,0x9
    800022e6:	4ae7a783          	lw	a5,1198(a5) # 8000b790 <ticks>
    800022ea:	f4f42e23          	sw	a5,-164(s0)
          e2.event_type = SCHED_EV_OFF_CPU;
    800022ee:	f7242023          	sw	s2,-160(s0)
    800022f2:	8792                	mv	a5,tp
  int id = r_tp();
    800022f4:	f6f42e23          	sw	a5,-132(s0)
          e2.pid = p->pid;
    800022f8:	589c                	lw	a5,48(s1)
    800022fa:	f8f42023          	sw	a5,-128(s0)
          safestrcpy(e2.name, p->name, sizeof(e2.name));
    800022fe:	864e                	mv	a2,s3
    80002300:	85e2                	mv	a1,s8
    80002302:	f8440513          	addi	a0,s0,-124
    80002306:	c35fe0ef          	jal	80000f3a <safestrcpy>
          e2.state = p->state;
    8000230a:	4c9c                	lw	a5,24(s1)
          if(p->state == SLEEPING)
    8000230c:	4689                	li	a3,2
    8000230e:	8736                	mv	a4,a3
    80002310:	00d78a63          	beq	a5,a3,80002324 <scheduler+0x21a>
          else if(p->state == ZOMBIE)
    80002314:	4695                	li	a3,5
    80002316:	875a                	mv	a4,s6
    80002318:	00d78663          	beq	a5,a3,80002324 <scheduler+0x21a>
          else if(p->state == RUNNABLE)
    8000231c:	874a                	mv	a4,s2
    8000231e:	01278363          	beq	a5,s2,80002324 <scheduler+0x21a>
    80002322:	4701                	li	a4,0
          e2.state = p->state;
    80002324:	f8f42a23          	sw	a5,-108(s0)
            e2.reason = SCHED_OFF_SLEEP;
    80002328:	f8e42c23          	sw	a4,-104(s0)
          schedlog_emit(&e2);
    8000232c:	f5840513          	addi	a0,s0,-168
    80002330:	40e040ef          	jal	8000673e <schedlog_emit>
    80002334:	b5c9                	j	800021f6 <scheduler+0xec>
    if (found == 0) {
    80002336:	000c1563          	bnez	s8,80002340 <scheduler+0x236>
      asm volatile("wfi");
    8000233a:	10500073          	wfi
      if (p->state == RUNNABLE) {
    8000233e:	490d                	li	s2,3
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002340:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002344:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002348:	10079073          	csrw	sstatus,a5
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000234c:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80002350:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002352:	10079073          	csrw	sstatus,a5
    int found = 0;
    80002356:	4c01                	li	s8,0
    for (p = proc; p < &proc[NPROC]; p++) {
    80002358:	00012497          	auipc	s1,0x12
    8000235c:	9d848493          	addi	s1,s1,-1576 # 80013d30 <proc>
        if(strncmp(p->name, "schedexport", 16) != 0){
    80002360:	49c1                	li	s3,16
    80002362:	00006a17          	auipc	s4,0x6
    80002366:	e56a0a13          	addi	s4,s4,-426 # 800081b8 <etext+0x1b8>
    8000236a:	b565                	j	80002212 <scheduler+0x108>

000000008000236c <sched>:
void sched(void) {
    8000236c:	7179                	addi	sp,sp,-48
    8000236e:	f406                	sd	ra,40(sp)
    80002370:	f022                	sd	s0,32(sp)
    80002372:	ec26                	sd	s1,24(sp)
    80002374:	e84a                	sd	s2,16(sp)
    80002376:	e44e                	sd	s3,8(sp)
    80002378:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    8000237a:	8afff0ef          	jal	80001c28 <myproc>
    8000237e:	84aa                	mv	s1,a0
  if (!holding(&p->lock))
    80002380:	927fe0ef          	jal	80000ca6 <holding>
    80002384:	c935                	beqz	a0,800023f8 <sched+0x8c>
  asm volatile("mv %0, tp" : "=r" (x) );
    80002386:	8792                	mv	a5,tp
  if (mycpu()->noff != 1)
    80002388:	2781                	sext.w	a5,a5
    8000238a:	079e                	slli	a5,a5,0x7
    8000238c:	00011717          	auipc	a4,0x11
    80002390:	55c70713          	addi	a4,a4,1372 # 800138e8 <pid_lock>
    80002394:	97ba                	add	a5,a5,a4
    80002396:	0c07a703          	lw	a4,192(a5)
    8000239a:	4785                	li	a5,1
    8000239c:	06f71463          	bne	a4,a5,80002404 <sched+0x98>
  if (p->state == RUNNING)
    800023a0:	4c98                	lw	a4,24(s1)
    800023a2:	4791                	li	a5,4
    800023a4:	06f70663          	beq	a4,a5,80002410 <sched+0xa4>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800023a8:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    800023ac:	8b89                	andi	a5,a5,2
  if (intr_get())
    800023ae:	e7bd                	bnez	a5,8000241c <sched+0xb0>
  asm volatile("mv %0, tp" : "=r" (x) );
    800023b0:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    800023b2:	00011917          	auipc	s2,0x11
    800023b6:	53690913          	addi	s2,s2,1334 # 800138e8 <pid_lock>
    800023ba:	2781                	sext.w	a5,a5
    800023bc:	079e                	slli	a5,a5,0x7
    800023be:	97ca                	add	a5,a5,s2
    800023c0:	0c47a983          	lw	s3,196(a5)
    800023c4:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    800023c6:	2781                	sext.w	a5,a5
    800023c8:	079e                	slli	a5,a5,0x7
    800023ca:	07a1                	addi	a5,a5,8
    800023cc:	00011597          	auipc	a1,0x11
    800023d0:	56458593          	addi	a1,a1,1380 # 80013930 <cpus>
    800023d4:	95be                	add	a1,a1,a5
    800023d6:	06048513          	addi	a0,s1,96
    800023da:	50c000ef          	jal	800028e6 <swtch>
    800023de:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    800023e0:	2781                	sext.w	a5,a5
    800023e2:	079e                	slli	a5,a5,0x7
    800023e4:	993e                	add	s2,s2,a5
    800023e6:	0d392223          	sw	s3,196(s2)
}
    800023ea:	70a2                	ld	ra,40(sp)
    800023ec:	7402                	ld	s0,32(sp)
    800023ee:	64e2                	ld	s1,24(sp)
    800023f0:	6942                	ld	s2,16(sp)
    800023f2:	69a2                	ld	s3,8(sp)
    800023f4:	6145                	addi	sp,sp,48
    800023f6:	8082                	ret
    panic("sched p->lock");
    800023f8:	00006517          	auipc	a0,0x6
    800023fc:	dd050513          	addi	a0,a0,-560 # 800081c8 <etext+0x1c8>
    80002400:	c56fe0ef          	jal	80000856 <panic>
    panic("sched locks");
    80002404:	00006517          	auipc	a0,0x6
    80002408:	dd450513          	addi	a0,a0,-556 # 800081d8 <etext+0x1d8>
    8000240c:	c4afe0ef          	jal	80000856 <panic>
    panic("sched RUNNING");
    80002410:	00006517          	auipc	a0,0x6
    80002414:	dd850513          	addi	a0,a0,-552 # 800081e8 <etext+0x1e8>
    80002418:	c3efe0ef          	jal	80000856 <panic>
    panic("sched interruptible");
    8000241c:	00006517          	auipc	a0,0x6
    80002420:	ddc50513          	addi	a0,a0,-548 # 800081f8 <etext+0x1f8>
    80002424:	c32fe0ef          	jal	80000856 <panic>

0000000080002428 <yield>:
void yield(void) {
    80002428:	1101                	addi	sp,sp,-32
    8000242a:	ec06                	sd	ra,24(sp)
    8000242c:	e822                	sd	s0,16(sp)
    8000242e:	e426                	sd	s1,8(sp)
    80002430:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80002432:	ff6ff0ef          	jal	80001c28 <myproc>
    80002436:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80002438:	8dffe0ef          	jal	80000d16 <acquire>
  p->state = RUNNABLE;
    8000243c:	478d                	li	a5,3
    8000243e:	cc9c                	sw	a5,24(s1)
  sched();
    80002440:	f2dff0ef          	jal	8000236c <sched>
  release(&p->lock);
    80002444:	8526                	mv	a0,s1
    80002446:	965fe0ef          	jal	80000daa <release>
}
    8000244a:	60e2                	ld	ra,24(sp)
    8000244c:	6442                	ld	s0,16(sp)
    8000244e:	64a2                	ld	s1,8(sp)
    80002450:	6105                	addi	sp,sp,32
    80002452:	8082                	ret

0000000080002454 <sleep>:

// Sleep on channel chan, releasing condition lock lk.
// Re-acquires lk when awakened.
void sleep(void *chan, struct spinlock *lk) {
    80002454:	7179                	addi	sp,sp,-48
    80002456:	f406                	sd	ra,40(sp)
    80002458:	f022                	sd	s0,32(sp)
    8000245a:	ec26                	sd	s1,24(sp)
    8000245c:	e84a                	sd	s2,16(sp)
    8000245e:	e44e                	sd	s3,8(sp)
    80002460:	1800                	addi	s0,sp,48
    80002462:	89aa                	mv	s3,a0
    80002464:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002466:	fc2ff0ef          	jal	80001c28 <myproc>
    8000246a:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock); // DOC: sleeplock1
    8000246c:	8abfe0ef          	jal	80000d16 <acquire>
  release(lk);
    80002470:	854a                	mv	a0,s2
    80002472:	939fe0ef          	jal	80000daa <release>

  // Go to sleep.
  p->chan = chan;
    80002476:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    8000247a:	4789                	li	a5,2
    8000247c:	cc9c                	sw	a5,24(s1)

  sched();
    8000247e:	eefff0ef          	jal	8000236c <sched>

  // Tidy up.
  p->chan = 0;
    80002482:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    80002486:	8526                	mv	a0,s1
    80002488:	923fe0ef          	jal	80000daa <release>
  acquire(lk);
    8000248c:	854a                	mv	a0,s2
    8000248e:	889fe0ef          	jal	80000d16 <acquire>
}
    80002492:	70a2                	ld	ra,40(sp)
    80002494:	7402                	ld	s0,32(sp)
    80002496:	64e2                	ld	s1,24(sp)
    80002498:	6942                	ld	s2,16(sp)
    8000249a:	69a2                	ld	s3,8(sp)
    8000249c:	6145                	addi	sp,sp,48
    8000249e:	8082                	ret

00000000800024a0 <wakeup>:

// Wake up all processes sleeping on channel chan.
// Caller should hold the condition lock.
void wakeup(void *chan) {
    800024a0:	7139                	addi	sp,sp,-64
    800024a2:	fc06                	sd	ra,56(sp)
    800024a4:	f822                	sd	s0,48(sp)
    800024a6:	f426                	sd	s1,40(sp)
    800024a8:	f04a                	sd	s2,32(sp)
    800024aa:	ec4e                	sd	s3,24(sp)
    800024ac:	e852                	sd	s4,16(sp)
    800024ae:	e456                	sd	s5,8(sp)
    800024b0:	0080                	addi	s0,sp,64
    800024b2:	8a2a                	mv	s4,a0
  struct proc *p;

  for (p = proc; p < &proc[NPROC]; p++) {
    800024b4:	00012497          	auipc	s1,0x12
    800024b8:	87c48493          	addi	s1,s1,-1924 # 80013d30 <proc>
    if (p != myproc()) {
      acquire(&p->lock);
      if (p->state == SLEEPING && p->chan == chan) {
    800024bc:	4989                	li	s3,2
        p->state = RUNNABLE;
    800024be:	4a8d                	li	s5,3
  for (p = proc; p < &proc[NPROC]; p++) {
    800024c0:	00017917          	auipc	s2,0x17
    800024c4:	27090913          	addi	s2,s2,624 # 80019730 <tickslock>
    800024c8:	a801                	j	800024d8 <wakeup+0x38>
      }
      release(&p->lock);
    800024ca:	8526                	mv	a0,s1
    800024cc:	8dffe0ef          	jal	80000daa <release>
  for (p = proc; p < &proc[NPROC]; p++) {
    800024d0:	16848493          	addi	s1,s1,360
    800024d4:	03248263          	beq	s1,s2,800024f8 <wakeup+0x58>
    if (p != myproc()) {
    800024d8:	f50ff0ef          	jal	80001c28 <myproc>
    800024dc:	fe950ae3          	beq	a0,s1,800024d0 <wakeup+0x30>
      acquire(&p->lock);
    800024e0:	8526                	mv	a0,s1
    800024e2:	835fe0ef          	jal	80000d16 <acquire>
      if (p->state == SLEEPING && p->chan == chan) {
    800024e6:	4c9c                	lw	a5,24(s1)
    800024e8:	ff3791e3          	bne	a5,s3,800024ca <wakeup+0x2a>
    800024ec:	709c                	ld	a5,32(s1)
    800024ee:	fd479ee3          	bne	a5,s4,800024ca <wakeup+0x2a>
        p->state = RUNNABLE;
    800024f2:	0154ac23          	sw	s5,24(s1)
    800024f6:	bfd1                	j	800024ca <wakeup+0x2a>
    }
  }
}
    800024f8:	70e2                	ld	ra,56(sp)
    800024fa:	7442                	ld	s0,48(sp)
    800024fc:	74a2                	ld	s1,40(sp)
    800024fe:	7902                	ld	s2,32(sp)
    80002500:	69e2                	ld	s3,24(sp)
    80002502:	6a42                	ld	s4,16(sp)
    80002504:	6aa2                	ld	s5,8(sp)
    80002506:	6121                	addi	sp,sp,64
    80002508:	8082                	ret

000000008000250a <reparent>:
void reparent(struct proc *p) {
    8000250a:	7179                	addi	sp,sp,-48
    8000250c:	f406                	sd	ra,40(sp)
    8000250e:	f022                	sd	s0,32(sp)
    80002510:	ec26                	sd	s1,24(sp)
    80002512:	e84a                	sd	s2,16(sp)
    80002514:	e44e                	sd	s3,8(sp)
    80002516:	e052                	sd	s4,0(sp)
    80002518:	1800                	addi	s0,sp,48
    8000251a:	892a                	mv	s2,a0
  for (pp = proc; pp < &proc[NPROC]; pp++) {
    8000251c:	00012497          	auipc	s1,0x12
    80002520:	81448493          	addi	s1,s1,-2028 # 80013d30 <proc>
      pp->parent = initproc;
    80002524:	00009a17          	auipc	s4,0x9
    80002528:	264a0a13          	addi	s4,s4,612 # 8000b788 <initproc>
  for (pp = proc; pp < &proc[NPROC]; pp++) {
    8000252c:	00017997          	auipc	s3,0x17
    80002530:	20498993          	addi	s3,s3,516 # 80019730 <tickslock>
    80002534:	a029                	j	8000253e <reparent+0x34>
    80002536:	16848493          	addi	s1,s1,360
    8000253a:	01348b63          	beq	s1,s3,80002550 <reparent+0x46>
    if (pp->parent == p) {
    8000253e:	7c9c                	ld	a5,56(s1)
    80002540:	ff279be3          	bne	a5,s2,80002536 <reparent+0x2c>
      pp->parent = initproc;
    80002544:	000a3503          	ld	a0,0(s4)
    80002548:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    8000254a:	f57ff0ef          	jal	800024a0 <wakeup>
    8000254e:	b7e5                	j	80002536 <reparent+0x2c>
}
    80002550:	70a2                	ld	ra,40(sp)
    80002552:	7402                	ld	s0,32(sp)
    80002554:	64e2                	ld	s1,24(sp)
    80002556:	6942                	ld	s2,16(sp)
    80002558:	69a2                	ld	s3,8(sp)
    8000255a:	6a02                	ld	s4,0(sp)
    8000255c:	6145                	addi	sp,sp,48
    8000255e:	8082                	ret

0000000080002560 <kexit>:
void kexit(int status) {
    80002560:	7179                	addi	sp,sp,-48
    80002562:	f406                	sd	ra,40(sp)
    80002564:	f022                	sd	s0,32(sp)
    80002566:	ec26                	sd	s1,24(sp)
    80002568:	e84a                	sd	s2,16(sp)
    8000256a:	e44e                	sd	s3,8(sp)
    8000256c:	e052                	sd	s4,0(sp)
    8000256e:	1800                	addi	s0,sp,48
    80002570:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    80002572:	eb6ff0ef          	jal	80001c28 <myproc>
    80002576:	89aa                	mv	s3,a0
  if (p == initproc)
    80002578:	00009797          	auipc	a5,0x9
    8000257c:	2107b783          	ld	a5,528(a5) # 8000b788 <initproc>
    80002580:	0d050493          	addi	s1,a0,208
    80002584:	15050913          	addi	s2,a0,336
    80002588:	00a79b63          	bne	a5,a0,8000259e <kexit+0x3e>
    panic("init exiting");
    8000258c:	00006517          	auipc	a0,0x6
    80002590:	c8450513          	addi	a0,a0,-892 # 80008210 <etext+0x210>
    80002594:	ac2fe0ef          	jal	80000856 <panic>
  for (int fd = 0; fd < NOFILE; fd++) {
    80002598:	04a1                	addi	s1,s1,8
    8000259a:	01248963          	beq	s1,s2,800025ac <kexit+0x4c>
    if (p->ofile[fd]) {
    8000259e:	6088                	ld	a0,0(s1)
    800025a0:	dd65                	beqz	a0,80002598 <kexit+0x38>
      fileclose(f);
    800025a2:	08a020ef          	jal	8000462c <fileclose>
      p->ofile[fd] = 0;
    800025a6:	0004b023          	sd	zero,0(s1)
    800025aa:	b7fd                	j	80002598 <kexit+0x38>
  begin_op();
    800025ac:	45d010ef          	jal	80004208 <begin_op>
  iput(p->cwd);
    800025b0:	1509b503          	ld	a0,336(s3)
    800025b4:	3ca010ef          	jal	8000397e <iput>
  end_op();
    800025b8:	4c1010ef          	jal	80004278 <end_op>
  p->cwd = 0;
    800025bc:	1409b823          	sd	zero,336(s3)
  acquire(&wait_lock);
    800025c0:	00011517          	auipc	a0,0x11
    800025c4:	34050513          	addi	a0,a0,832 # 80013900 <wait_lock>
    800025c8:	f4efe0ef          	jal	80000d16 <acquire>
  reparent(p);
    800025cc:	854e                	mv	a0,s3
    800025ce:	f3dff0ef          	jal	8000250a <reparent>
  wakeup(p->parent);
    800025d2:	0389b503          	ld	a0,56(s3)
    800025d6:	ecbff0ef          	jal	800024a0 <wakeup>
  acquire(&p->lock);
    800025da:	854e                	mv	a0,s3
    800025dc:	f3afe0ef          	jal	80000d16 <acquire>
  p->xstate = status;
    800025e0:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    800025e4:	4795                	li	a5,5
    800025e6:	00f9ac23          	sw	a5,24(s3)
  release(&wait_lock);
    800025ea:	00011517          	auipc	a0,0x11
    800025ee:	31650513          	addi	a0,a0,790 # 80013900 <wait_lock>
    800025f2:	fb8fe0ef          	jal	80000daa <release>
  sched();
    800025f6:	d77ff0ef          	jal	8000236c <sched>
  panic("zombie exit");
    800025fa:	00006517          	auipc	a0,0x6
    800025fe:	c2650513          	addi	a0,a0,-986 # 80008220 <etext+0x220>
    80002602:	a54fe0ef          	jal	80000856 <panic>

0000000080002606 <kkill>:

// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int kkill(int pid) {
    80002606:	7179                	addi	sp,sp,-48
    80002608:	f406                	sd	ra,40(sp)
    8000260a:	f022                	sd	s0,32(sp)
    8000260c:	ec26                	sd	s1,24(sp)
    8000260e:	e84a                	sd	s2,16(sp)
    80002610:	e44e                	sd	s3,8(sp)
    80002612:	1800                	addi	s0,sp,48
    80002614:	892a                	mv	s2,a0
  struct proc *p;

  for (p = proc; p < &proc[NPROC]; p++) {
    80002616:	00011497          	auipc	s1,0x11
    8000261a:	71a48493          	addi	s1,s1,1818 # 80013d30 <proc>
    8000261e:	00017997          	auipc	s3,0x17
    80002622:	11298993          	addi	s3,s3,274 # 80019730 <tickslock>
    acquire(&p->lock);
    80002626:	8526                	mv	a0,s1
    80002628:	eeefe0ef          	jal	80000d16 <acquire>
    if (p->pid == pid) {
    8000262c:	589c                	lw	a5,48(s1)
    8000262e:	01278b63          	beq	a5,s2,80002644 <kkill+0x3e>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    80002632:	8526                	mv	a0,s1
    80002634:	f76fe0ef          	jal	80000daa <release>
  for (p = proc; p < &proc[NPROC]; p++) {
    80002638:	16848493          	addi	s1,s1,360
    8000263c:	ff3495e3          	bne	s1,s3,80002626 <kkill+0x20>
  }
  return -1;
    80002640:	557d                	li	a0,-1
    80002642:	a819                	j	80002658 <kkill+0x52>
      p->killed = 1;
    80002644:	4785                	li	a5,1
    80002646:	d49c                	sw	a5,40(s1)
      if (p->state == SLEEPING) {
    80002648:	4c98                	lw	a4,24(s1)
    8000264a:	4789                	li	a5,2
    8000264c:	00f70d63          	beq	a4,a5,80002666 <kkill+0x60>
      release(&p->lock);
    80002650:	8526                	mv	a0,s1
    80002652:	f58fe0ef          	jal	80000daa <release>
      return 0;
    80002656:	4501                	li	a0,0
}
    80002658:	70a2                	ld	ra,40(sp)
    8000265a:	7402                	ld	s0,32(sp)
    8000265c:	64e2                	ld	s1,24(sp)
    8000265e:	6942                	ld	s2,16(sp)
    80002660:	69a2                	ld	s3,8(sp)
    80002662:	6145                	addi	sp,sp,48
    80002664:	8082                	ret
        p->state = RUNNABLE;
    80002666:	478d                	li	a5,3
    80002668:	cc9c                	sw	a5,24(s1)
    8000266a:	b7dd                	j	80002650 <kkill+0x4a>

000000008000266c <setkilled>:

void setkilled(struct proc *p) {
    8000266c:	1101                	addi	sp,sp,-32
    8000266e:	ec06                	sd	ra,24(sp)
    80002670:	e822                	sd	s0,16(sp)
    80002672:	e426                	sd	s1,8(sp)
    80002674:	1000                	addi	s0,sp,32
    80002676:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80002678:	e9efe0ef          	jal	80000d16 <acquire>
  p->killed = 1;
    8000267c:	4785                	li	a5,1
    8000267e:	d49c                	sw	a5,40(s1)
  release(&p->lock);
    80002680:	8526                	mv	a0,s1
    80002682:	f28fe0ef          	jal	80000daa <release>
}
    80002686:	60e2                	ld	ra,24(sp)
    80002688:	6442                	ld	s0,16(sp)
    8000268a:	64a2                	ld	s1,8(sp)
    8000268c:	6105                	addi	sp,sp,32
    8000268e:	8082                	ret

0000000080002690 <killed>:

int killed(struct proc *p) {
    80002690:	1101                	addi	sp,sp,-32
    80002692:	ec06                	sd	ra,24(sp)
    80002694:	e822                	sd	s0,16(sp)
    80002696:	e426                	sd	s1,8(sp)
    80002698:	e04a                	sd	s2,0(sp)
    8000269a:	1000                	addi	s0,sp,32
    8000269c:	84aa                	mv	s1,a0
  int k;

  acquire(&p->lock);
    8000269e:	e78fe0ef          	jal	80000d16 <acquire>
  k = p->killed;
    800026a2:	549c                	lw	a5,40(s1)
    800026a4:	893e                	mv	s2,a5
  release(&p->lock);
    800026a6:	8526                	mv	a0,s1
    800026a8:	f02fe0ef          	jal	80000daa <release>
  return k;
}
    800026ac:	854a                	mv	a0,s2
    800026ae:	60e2                	ld	ra,24(sp)
    800026b0:	6442                	ld	s0,16(sp)
    800026b2:	64a2                	ld	s1,8(sp)
    800026b4:	6902                	ld	s2,0(sp)
    800026b6:	6105                	addi	sp,sp,32
    800026b8:	8082                	ret

00000000800026ba <kwait>:
int kwait(uint64 addr) {
    800026ba:	715d                	addi	sp,sp,-80
    800026bc:	e486                	sd	ra,72(sp)
    800026be:	e0a2                	sd	s0,64(sp)
    800026c0:	fc26                	sd	s1,56(sp)
    800026c2:	f84a                	sd	s2,48(sp)
    800026c4:	f44e                	sd	s3,40(sp)
    800026c6:	f052                	sd	s4,32(sp)
    800026c8:	ec56                	sd	s5,24(sp)
    800026ca:	e85a                	sd	s6,16(sp)
    800026cc:	e45e                	sd	s7,8(sp)
    800026ce:	0880                	addi	s0,sp,80
    800026d0:	8baa                	mv	s7,a0
  struct proc *p = myproc();
    800026d2:	d56ff0ef          	jal	80001c28 <myproc>
    800026d6:	892a                	mv	s2,a0
  acquire(&wait_lock);
    800026d8:	00011517          	auipc	a0,0x11
    800026dc:	22850513          	addi	a0,a0,552 # 80013900 <wait_lock>
    800026e0:	e36fe0ef          	jal	80000d16 <acquire>
        if (pp->state == ZOMBIE) {
    800026e4:	4a15                	li	s4,5
        havekids = 1;
    800026e6:	4a85                	li	s5,1
    for (pp = proc; pp < &proc[NPROC]; pp++) {
    800026e8:	00017997          	auipc	s3,0x17
    800026ec:	04898993          	addi	s3,s3,72 # 80019730 <tickslock>
    sleep(p, &wait_lock); // DOC: wait-sleep
    800026f0:	00011b17          	auipc	s6,0x11
    800026f4:	210b0b13          	addi	s6,s6,528 # 80013900 <wait_lock>
    800026f8:	a869                	j	80002792 <kwait+0xd8>
          pid = pp->pid;
    800026fa:	0304a983          	lw	s3,48(s1)
          if (addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    800026fe:	000b8c63          	beqz	s7,80002716 <kwait+0x5c>
    80002702:	4691                	li	a3,4
    80002704:	02c48613          	addi	a2,s1,44
    80002708:	85de                	mv	a1,s7
    8000270a:	05093503          	ld	a0,80(s2)
    8000270e:	a2cff0ef          	jal	8000193a <copyout>
    80002712:	02054a63          	bltz	a0,80002746 <kwait+0x8c>
          freeproc(pp);
    80002716:	8526                	mv	a0,s1
    80002718:	ee4ff0ef          	jal	80001dfc <freeproc>
          release(&pp->lock);
    8000271c:	8526                	mv	a0,s1
    8000271e:	e8cfe0ef          	jal	80000daa <release>
          release(&wait_lock);
    80002722:	00011517          	auipc	a0,0x11
    80002726:	1de50513          	addi	a0,a0,478 # 80013900 <wait_lock>
    8000272a:	e80fe0ef          	jal	80000daa <release>
}
    8000272e:	854e                	mv	a0,s3
    80002730:	60a6                	ld	ra,72(sp)
    80002732:	6406                	ld	s0,64(sp)
    80002734:	74e2                	ld	s1,56(sp)
    80002736:	7942                	ld	s2,48(sp)
    80002738:	79a2                	ld	s3,40(sp)
    8000273a:	7a02                	ld	s4,32(sp)
    8000273c:	6ae2                	ld	s5,24(sp)
    8000273e:	6b42                	ld	s6,16(sp)
    80002740:	6ba2                	ld	s7,8(sp)
    80002742:	6161                	addi	sp,sp,80
    80002744:	8082                	ret
            release(&pp->lock);
    80002746:	8526                	mv	a0,s1
    80002748:	e62fe0ef          	jal	80000daa <release>
            release(&wait_lock);
    8000274c:	00011517          	auipc	a0,0x11
    80002750:	1b450513          	addi	a0,a0,436 # 80013900 <wait_lock>
    80002754:	e56fe0ef          	jal	80000daa <release>
            return -1;
    80002758:	59fd                	li	s3,-1
    8000275a:	bfd1                	j	8000272e <kwait+0x74>
    for (pp = proc; pp < &proc[NPROC]; pp++) {
    8000275c:	16848493          	addi	s1,s1,360
    80002760:	03348063          	beq	s1,s3,80002780 <kwait+0xc6>
      if (pp->parent == p) {
    80002764:	7c9c                	ld	a5,56(s1)
    80002766:	ff279be3          	bne	a5,s2,8000275c <kwait+0xa2>
        acquire(&pp->lock);
    8000276a:	8526                	mv	a0,s1
    8000276c:	daafe0ef          	jal	80000d16 <acquire>
        if (pp->state == ZOMBIE) {
    80002770:	4c9c                	lw	a5,24(s1)
    80002772:	f94784e3          	beq	a5,s4,800026fa <kwait+0x40>
        release(&pp->lock);
    80002776:	8526                	mv	a0,s1
    80002778:	e32fe0ef          	jal	80000daa <release>
        havekids = 1;
    8000277c:	8756                	mv	a4,s5
    8000277e:	bff9                	j	8000275c <kwait+0xa2>
    if (!havekids || killed(p)) {
    80002780:	cf19                	beqz	a4,8000279e <kwait+0xe4>
    80002782:	854a                	mv	a0,s2
    80002784:	f0dff0ef          	jal	80002690 <killed>
    80002788:	e919                	bnez	a0,8000279e <kwait+0xe4>
    sleep(p, &wait_lock); // DOC: wait-sleep
    8000278a:	85da                	mv	a1,s6
    8000278c:	854a                	mv	a0,s2
    8000278e:	cc7ff0ef          	jal	80002454 <sleep>
    havekids = 0;
    80002792:	4701                	li	a4,0
    for (pp = proc; pp < &proc[NPROC]; pp++) {
    80002794:	00011497          	auipc	s1,0x11
    80002798:	59c48493          	addi	s1,s1,1436 # 80013d30 <proc>
    8000279c:	b7e1                	j	80002764 <kwait+0xaa>
      release(&wait_lock);
    8000279e:	00011517          	auipc	a0,0x11
    800027a2:	16250513          	addi	a0,a0,354 # 80013900 <wait_lock>
    800027a6:	e04fe0ef          	jal	80000daa <release>
      return -1;
    800027aa:	59fd                	li	s3,-1
    800027ac:	b749                	j	8000272e <kwait+0x74>

00000000800027ae <either_copyout>:

// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int either_copyout(int user_dst, uint64 dst, void *src, uint64 len) {
    800027ae:	7179                	addi	sp,sp,-48
    800027b0:	f406                	sd	ra,40(sp)
    800027b2:	f022                	sd	s0,32(sp)
    800027b4:	ec26                	sd	s1,24(sp)
    800027b6:	e84a                	sd	s2,16(sp)
    800027b8:	e44e                	sd	s3,8(sp)
    800027ba:	e052                	sd	s4,0(sp)
    800027bc:	1800                	addi	s0,sp,48
    800027be:	84aa                	mv	s1,a0
    800027c0:	8a2e                	mv	s4,a1
    800027c2:	89b2                	mv	s3,a2
    800027c4:	8936                	mv	s2,a3
  struct proc *p = myproc();
    800027c6:	c62ff0ef          	jal	80001c28 <myproc>
  if (user_dst) {
    800027ca:	cc99                	beqz	s1,800027e8 <either_copyout+0x3a>
    return copyout(p->pagetable, dst, src, len);
    800027cc:	86ca                	mv	a3,s2
    800027ce:	864e                	mv	a2,s3
    800027d0:	85d2                	mv	a1,s4
    800027d2:	6928                	ld	a0,80(a0)
    800027d4:	966ff0ef          	jal	8000193a <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    800027d8:	70a2                	ld	ra,40(sp)
    800027da:	7402                	ld	s0,32(sp)
    800027dc:	64e2                	ld	s1,24(sp)
    800027de:	6942                	ld	s2,16(sp)
    800027e0:	69a2                	ld	s3,8(sp)
    800027e2:	6a02                	ld	s4,0(sp)
    800027e4:	6145                	addi	sp,sp,48
    800027e6:	8082                	ret
    memmove((char *)dst, src, len);
    800027e8:	0009061b          	sext.w	a2,s2
    800027ec:	85ce                	mv	a1,s3
    800027ee:	8552                	mv	a0,s4
    800027f0:	e56fe0ef          	jal	80000e46 <memmove>
    return 0;
    800027f4:	8526                	mv	a0,s1
    800027f6:	b7cd                	j	800027d8 <either_copyout+0x2a>

00000000800027f8 <either_copyin>:

// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int either_copyin(void *dst, int user_src, uint64 src, uint64 len) {
    800027f8:	7179                	addi	sp,sp,-48
    800027fa:	f406                	sd	ra,40(sp)
    800027fc:	f022                	sd	s0,32(sp)
    800027fe:	ec26                	sd	s1,24(sp)
    80002800:	e84a                	sd	s2,16(sp)
    80002802:	e44e                	sd	s3,8(sp)
    80002804:	e052                	sd	s4,0(sp)
    80002806:	1800                	addi	s0,sp,48
    80002808:	8a2a                	mv	s4,a0
    8000280a:	84ae                	mv	s1,a1
    8000280c:	89b2                	mv	s3,a2
    8000280e:	8936                	mv	s2,a3
  struct proc *p = myproc();
    80002810:	c18ff0ef          	jal	80001c28 <myproc>
  if (user_src) {
    80002814:	cc99                	beqz	s1,80002832 <either_copyin+0x3a>
    return copyin(p->pagetable, dst, src, len);
    80002816:	86ca                	mv	a3,s2
    80002818:	864e                	mv	a2,s3
    8000281a:	85d2                	mv	a1,s4
    8000281c:	6928                	ld	a0,80(a0)
    8000281e:	9daff0ef          	jal	800019f8 <copyin>
  } else {
    memmove(dst, (char *)src, len);
    return 0;
  }
}
    80002822:	70a2                	ld	ra,40(sp)
    80002824:	7402                	ld	s0,32(sp)
    80002826:	64e2                	ld	s1,24(sp)
    80002828:	6942                	ld	s2,16(sp)
    8000282a:	69a2                	ld	s3,8(sp)
    8000282c:	6a02                	ld	s4,0(sp)
    8000282e:	6145                	addi	sp,sp,48
    80002830:	8082                	ret
    memmove(dst, (char *)src, len);
    80002832:	0009061b          	sext.w	a2,s2
    80002836:	85ce                	mv	a1,s3
    80002838:	8552                	mv	a0,s4
    8000283a:	e0cfe0ef          	jal	80000e46 <memmove>
    return 0;
    8000283e:	8526                	mv	a0,s1
    80002840:	b7cd                	j	80002822 <either_copyin+0x2a>

0000000080002842 <procdump>:

// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void procdump(void) {
    80002842:	715d                	addi	sp,sp,-80
    80002844:	e486                	sd	ra,72(sp)
    80002846:	e0a2                	sd	s0,64(sp)
    80002848:	fc26                	sd	s1,56(sp)
    8000284a:	f84a                	sd	s2,48(sp)
    8000284c:	f44e                	sd	s3,40(sp)
    8000284e:	f052                	sd	s4,32(sp)
    80002850:	ec56                	sd	s5,24(sp)
    80002852:	e85a                	sd	s6,16(sp)
    80002854:	e45e                	sd	s7,8(sp)
    80002856:	0880                	addi	s0,sp,80
      [UNUSED] "unused",   [USED] "used",      [SLEEPING] "sleep ",
      [RUNNABLE] "runble", [RUNNING] "run   ", [ZOMBIE] "zombie"};
  struct proc *p;
  char *state;

  printf("\n");
    80002858:	00006517          	auipc	a0,0x6
    8000285c:	82850513          	addi	a0,a0,-2008 # 80008080 <etext+0x80>
    80002860:	ccdfd0ef          	jal	8000052c <printf>
  for (p = proc; p < &proc[NPROC]; p++) {
    80002864:	00011497          	auipc	s1,0x11
    80002868:	62448493          	addi	s1,s1,1572 # 80013e88 <proc+0x158>
    8000286c:	00017917          	auipc	s2,0x17
    80002870:	01c90913          	addi	s2,s2,28 # 80019888 <bcache+0x140>
    if (p->state == UNUSED)
      continue;
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002874:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    80002876:	00006997          	auipc	s3,0x6
    8000287a:	9ba98993          	addi	s3,s3,-1606 # 80008230 <etext+0x230>
    printf("%d %s %s", p->pid, state, p->name);
    8000287e:	00006a97          	auipc	s5,0x6
    80002882:	9baa8a93          	addi	s5,s5,-1606 # 80008238 <etext+0x238>
    printf("\n");
    80002886:	00005a17          	auipc	s4,0x5
    8000288a:	7faa0a13          	addi	s4,s4,2042 # 80008080 <etext+0x80>
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000288e:	00006b97          	auipc	s7,0x6
    80002892:	f12b8b93          	addi	s7,s7,-238 # 800087a0 <states.0>
    80002896:	a829                	j	800028b0 <procdump+0x6e>
    printf("%d %s %s", p->pid, state, p->name);
    80002898:	ed86a583          	lw	a1,-296(a3)
    8000289c:	8556                	mv	a0,s5
    8000289e:	c8ffd0ef          	jal	8000052c <printf>
    printf("\n");
    800028a2:	8552                	mv	a0,s4
    800028a4:	c89fd0ef          	jal	8000052c <printf>
  for (p = proc; p < &proc[NPROC]; p++) {
    800028a8:	16848493          	addi	s1,s1,360
    800028ac:	03248263          	beq	s1,s2,800028d0 <procdump+0x8e>
    if (p->state == UNUSED)
    800028b0:	86a6                	mv	a3,s1
    800028b2:	ec04a783          	lw	a5,-320(s1)
    800028b6:	dbed                	beqz	a5,800028a8 <procdump+0x66>
      state = "???";
    800028b8:	864e                	mv	a2,s3
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800028ba:	fcfb6fe3          	bltu	s6,a5,80002898 <procdump+0x56>
    800028be:	02079713          	slli	a4,a5,0x20
    800028c2:	01d75793          	srli	a5,a4,0x1d
    800028c6:	97de                	add	a5,a5,s7
    800028c8:	6390                	ld	a2,0(a5)
    800028ca:	f679                	bnez	a2,80002898 <procdump+0x56>
      state = "???";
    800028cc:	864e                	mv	a2,s3
    800028ce:	b7e9                	j	80002898 <procdump+0x56>
  }
}
    800028d0:	60a6                	ld	ra,72(sp)
    800028d2:	6406                	ld	s0,64(sp)
    800028d4:	74e2                	ld	s1,56(sp)
    800028d6:	7942                	ld	s2,48(sp)
    800028d8:	79a2                	ld	s3,40(sp)
    800028da:	7a02                	ld	s4,32(sp)
    800028dc:	6ae2                	ld	s5,24(sp)
    800028de:	6b42                	ld	s6,16(sp)
    800028e0:	6ba2                	ld	s7,8(sp)
    800028e2:	6161                	addi	sp,sp,80
    800028e4:	8082                	ret

00000000800028e6 <swtch>:
# Save current registers in old. Load from new.	


.globl swtch
swtch:
        sd ra, 0(a0)
    800028e6:	00153023          	sd	ra,0(a0)
        sd sp, 8(a0)
    800028ea:	00253423          	sd	sp,8(a0)
        sd s0, 16(a0)
    800028ee:	e900                	sd	s0,16(a0)
        sd s1, 24(a0)
    800028f0:	ed04                	sd	s1,24(a0)
        sd s2, 32(a0)
    800028f2:	03253023          	sd	s2,32(a0)
        sd s3, 40(a0)
    800028f6:	03353423          	sd	s3,40(a0)
        sd s4, 48(a0)
    800028fa:	03453823          	sd	s4,48(a0)
        sd s5, 56(a0)
    800028fe:	03553c23          	sd	s5,56(a0)
        sd s6, 64(a0)
    80002902:	05653023          	sd	s6,64(a0)
        sd s7, 72(a0)
    80002906:	05753423          	sd	s7,72(a0)
        sd s8, 80(a0)
    8000290a:	05853823          	sd	s8,80(a0)
        sd s9, 88(a0)
    8000290e:	05953c23          	sd	s9,88(a0)
        sd s10, 96(a0)
    80002912:	07a53023          	sd	s10,96(a0)
        sd s11, 104(a0)
    80002916:	07b53423          	sd	s11,104(a0)

        ld ra, 0(a1)
    8000291a:	0005b083          	ld	ra,0(a1)
        ld sp, 8(a1)
    8000291e:	0085b103          	ld	sp,8(a1)
        ld s0, 16(a1)
    80002922:	6980                	ld	s0,16(a1)
        ld s1, 24(a1)
    80002924:	6d84                	ld	s1,24(a1)
        ld s2, 32(a1)
    80002926:	0205b903          	ld	s2,32(a1)
        ld s3, 40(a1)
    8000292a:	0285b983          	ld	s3,40(a1)
        ld s4, 48(a1)
    8000292e:	0305ba03          	ld	s4,48(a1)
        ld s5, 56(a1)
    80002932:	0385ba83          	ld	s5,56(a1)
        ld s6, 64(a1)
    80002936:	0405bb03          	ld	s6,64(a1)
        ld s7, 72(a1)
    8000293a:	0485bb83          	ld	s7,72(a1)
        ld s8, 80(a1)
    8000293e:	0505bc03          	ld	s8,80(a1)
        ld s9, 88(a1)
    80002942:	0585bc83          	ld	s9,88(a1)
        ld s10, 96(a1)
    80002946:	0605bd03          	ld	s10,96(a1)
        ld s11, 104(a1)
    8000294a:	0685bd83          	ld	s11,104(a1)
        
        ret
    8000294e:	8082                	ret

0000000080002950 <trapinit>:

extern int devintr();

void
trapinit(void)
{
    80002950:	1141                	addi	sp,sp,-16
    80002952:	e406                	sd	ra,8(sp)
    80002954:	e022                	sd	s0,0(sp)
    80002956:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    80002958:	00006597          	auipc	a1,0x6
    8000295c:	92058593          	addi	a1,a1,-1760 # 80008278 <etext+0x278>
    80002960:	00017517          	auipc	a0,0x17
    80002964:	dd050513          	addi	a0,a0,-560 # 80019730 <tickslock>
    80002968:	b24fe0ef          	jal	80000c8c <initlock>
}
    8000296c:	60a2                	ld	ra,8(sp)
    8000296e:	6402                	ld	s0,0(sp)
    80002970:	0141                	addi	sp,sp,16
    80002972:	8082                	ret

0000000080002974 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    80002974:	1141                	addi	sp,sp,-16
    80002976:	e406                	sd	ra,8(sp)
    80002978:	e022                	sd	s0,0(sp)
    8000297a:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    8000297c:	00003797          	auipc	a5,0x3
    80002980:	0a478793          	addi	a5,a5,164 # 80005a20 <kernelvec>
    80002984:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    80002988:	60a2                	ld	ra,8(sp)
    8000298a:	6402                	ld	s0,0(sp)
    8000298c:	0141                	addi	sp,sp,16
    8000298e:	8082                	ret

0000000080002990 <prepare_return>:
//
// set up trapframe and control registers for a return to user space
//
void
prepare_return(void)
{
    80002990:	1141                	addi	sp,sp,-16
    80002992:	e406                	sd	ra,8(sp)
    80002994:	e022                	sd	s0,0(sp)
    80002996:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    80002998:	a90ff0ef          	jal	80001c28 <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000299c:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    800029a0:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800029a2:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(). because a trap from kernel
  // code to usertrap would be a disaster, turn off interrupts.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    800029a6:	04000737          	lui	a4,0x4000
    800029aa:	177d                	addi	a4,a4,-1 # 3ffffff <_entry-0x7c000001>
    800029ac:	0732                	slli	a4,a4,0xc
    800029ae:	00004797          	auipc	a5,0x4
    800029b2:	65278793          	addi	a5,a5,1618 # 80007000 <_trampoline>
    800029b6:	00004697          	auipc	a3,0x4
    800029ba:	64a68693          	addi	a3,a3,1610 # 80007000 <_trampoline>
    800029be:	8f95                	sub	a5,a5,a3
    800029c0:	97ba                	add	a5,a5,a4
  asm volatile("csrw stvec, %0" : : "r" (x));
    800029c2:	10579073          	csrw	stvec,a5
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    800029c6:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    800029c8:	18002773          	csrr	a4,satp
    800029cc:	e398                	sd	a4,0(a5)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    800029ce:	6d38                	ld	a4,88(a0)
    800029d0:	613c                	ld	a5,64(a0)
    800029d2:	6685                	lui	a3,0x1
    800029d4:	97b6                	add	a5,a5,a3
    800029d6:	e71c                	sd	a5,8(a4)
  p->trapframe->kernel_trap = (uint64)usertrap;
    800029d8:	6d3c                	ld	a5,88(a0)
    800029da:	00000717          	auipc	a4,0x0
    800029de:	0fc70713          	addi	a4,a4,252 # 80002ad6 <usertrap>
    800029e2:	eb98                	sd	a4,16(a5)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    800029e4:	6d3c                	ld	a5,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    800029e6:	8712                	mv	a4,tp
    800029e8:	f398                	sd	a4,32(a5)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800029ea:	100027f3          	csrr	a5,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    800029ee:	eff7f793          	andi	a5,a5,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    800029f2:	0207e793          	ori	a5,a5,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800029f6:	10079073          	csrw	sstatus,a5
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    800029fa:	6d3c                	ld	a5,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    800029fc:	6f9c                	ld	a5,24(a5)
    800029fe:	14179073          	csrw	sepc,a5
}
    80002a02:	60a2                	ld	ra,8(sp)
    80002a04:	6402                	ld	s0,0(sp)
    80002a06:	0141                	addi	sp,sp,16
    80002a08:	8082                	ret

0000000080002a0a <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    80002a0a:	1141                	addi	sp,sp,-16
    80002a0c:	e406                	sd	ra,8(sp)
    80002a0e:	e022                	sd	s0,0(sp)
    80002a10:	0800                	addi	s0,sp,16
  if(cpuid() == 0){
    80002a12:	9e2ff0ef          	jal	80001bf4 <cpuid>
    80002a16:	cd11                	beqz	a0,80002a32 <clockintr+0x28>
  asm volatile("csrr %0, time" : "=r" (x) );
    80002a18:	c01027f3          	rdtime	a5
  }

  // ask for the next timer interrupt. this also clears
  // the interrupt request. 1000000 is about a tenth
  // of a second.
  w_stimecmp(r_time() + 1000000);
    80002a1c:	000f4737          	lui	a4,0xf4
    80002a20:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    80002a24:	97ba                	add	a5,a5,a4
  asm volatile("csrw 0x14d, %0" : : "r" (x));
    80002a26:	14d79073          	csrw	stimecmp,a5
}
    80002a2a:	60a2                	ld	ra,8(sp)
    80002a2c:	6402                	ld	s0,0(sp)
    80002a2e:	0141                	addi	sp,sp,16
    80002a30:	8082                	ret
    acquire(&tickslock);
    80002a32:	00017517          	auipc	a0,0x17
    80002a36:	cfe50513          	addi	a0,a0,-770 # 80019730 <tickslock>
    80002a3a:	adcfe0ef          	jal	80000d16 <acquire>
    ticks++;
    80002a3e:	00009717          	auipc	a4,0x9
    80002a42:	d5270713          	addi	a4,a4,-686 # 8000b790 <ticks>
    80002a46:	431c                	lw	a5,0(a4)
    80002a48:	2785                	addiw	a5,a5,1
    80002a4a:	c31c                	sw	a5,0(a4)
    wakeup(&ticks);
    80002a4c:	853a                	mv	a0,a4
    80002a4e:	a53ff0ef          	jal	800024a0 <wakeup>
    release(&tickslock);
    80002a52:	00017517          	auipc	a0,0x17
    80002a56:	cde50513          	addi	a0,a0,-802 # 80019730 <tickslock>
    80002a5a:	b50fe0ef          	jal	80000daa <release>
    80002a5e:	bf6d                	j	80002a18 <clockintr+0xe>

0000000080002a60 <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    80002a60:	1101                	addi	sp,sp,-32
    80002a62:	ec06                	sd	ra,24(sp)
    80002a64:	e822                	sd	s0,16(sp)
    80002a66:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002a68:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if(scause == 0x8000000000000009L){
    80002a6c:	57fd                	li	a5,-1
    80002a6e:	17fe                	slli	a5,a5,0x3f
    80002a70:	07a5                	addi	a5,a5,9
    80002a72:	00f70c63          	beq	a4,a5,80002a8a <devintr+0x2a>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000005L){
    80002a76:	57fd                	li	a5,-1
    80002a78:	17fe                	slli	a5,a5,0x3f
    80002a7a:	0795                	addi	a5,a5,5
    // timer interrupt.
    clockintr();
    return 2;
  } else {
    return 0;
    80002a7c:	4501                	li	a0,0
  } else if(scause == 0x8000000000000005L){
    80002a7e:	04f70863          	beq	a4,a5,80002ace <devintr+0x6e>
  }
}
    80002a82:	60e2                	ld	ra,24(sp)
    80002a84:	6442                	ld	s0,16(sp)
    80002a86:	6105                	addi	sp,sp,32
    80002a88:	8082                	ret
    80002a8a:	e426                	sd	s1,8(sp)
    int irq = plic_claim();
    80002a8c:	040030ef          	jal	80005acc <plic_claim>
    80002a90:	872a                	mv	a4,a0
    80002a92:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    80002a94:	47a9                	li	a5,10
    80002a96:	00f50963          	beq	a0,a5,80002aa8 <devintr+0x48>
    } else if(irq == VIRTIO0_IRQ){
    80002a9a:	4785                	li	a5,1
    80002a9c:	00f50963          	beq	a0,a5,80002aae <devintr+0x4e>
    return 1;
    80002aa0:	4505                	li	a0,1
    } else if(irq){
    80002aa2:	eb09                	bnez	a4,80002ab4 <devintr+0x54>
    80002aa4:	64a2                	ld	s1,8(sp)
    80002aa6:	bff1                	j	80002a82 <devintr+0x22>
      uartintr();
    80002aa8:	f7ffd0ef          	jal	80000a26 <uartintr>
    if(irq)
    80002aac:	a819                	j	80002ac2 <devintr+0x62>
      virtio_disk_intr();
    80002aae:	4b4030ef          	jal	80005f62 <virtio_disk_intr>
    if(irq)
    80002ab2:	a801                	j	80002ac2 <devintr+0x62>
      printf("unexpected interrupt irq=%d\n", irq);
    80002ab4:	85ba                	mv	a1,a4
    80002ab6:	00005517          	auipc	a0,0x5
    80002aba:	7ca50513          	addi	a0,a0,1994 # 80008280 <etext+0x280>
    80002abe:	a6ffd0ef          	jal	8000052c <printf>
      plic_complete(irq);
    80002ac2:	8526                	mv	a0,s1
    80002ac4:	028030ef          	jal	80005aec <plic_complete>
    return 1;
    80002ac8:	4505                	li	a0,1
    80002aca:	64a2                	ld	s1,8(sp)
    80002acc:	bf5d                	j	80002a82 <devintr+0x22>
    clockintr();
    80002ace:	f3dff0ef          	jal	80002a0a <clockintr>
    return 2;
    80002ad2:	4509                	li	a0,2
    80002ad4:	b77d                	j	80002a82 <devintr+0x22>

0000000080002ad6 <usertrap>:
{
    80002ad6:	1101                	addi	sp,sp,-32
    80002ad8:	ec06                	sd	ra,24(sp)
    80002ada:	e822                	sd	s0,16(sp)
    80002adc:	e426                	sd	s1,8(sp)
    80002ade:	e04a                	sd	s2,0(sp)
    80002ae0:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002ae2:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    80002ae6:	1007f793          	andi	a5,a5,256
    80002aea:	eba5                	bnez	a5,80002b5a <usertrap+0x84>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002aec:	00003797          	auipc	a5,0x3
    80002af0:	f3478793          	addi	a5,a5,-204 # 80005a20 <kernelvec>
    80002af4:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80002af8:	930ff0ef          	jal	80001c28 <myproc>
    80002afc:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    80002afe:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002b00:	14102773          	csrr	a4,sepc
    80002b04:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002b06:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    80002b0a:	47a1                	li	a5,8
    80002b0c:	04f70d63          	beq	a4,a5,80002b66 <usertrap+0x90>
  } else if((which_dev = devintr()) != 0){
    80002b10:	f51ff0ef          	jal	80002a60 <devintr>
    80002b14:	892a                	mv	s2,a0
    80002b16:	e945                	bnez	a0,80002bc6 <usertrap+0xf0>
    80002b18:	14202773          	csrr	a4,scause
  } else if((r_scause() == 15 || r_scause() == 13) &&
    80002b1c:	47bd                	li	a5,15
    80002b1e:	08f70863          	beq	a4,a5,80002bae <usertrap+0xd8>
    80002b22:	14202773          	csrr	a4,scause
    80002b26:	47b5                	li	a5,13
    80002b28:	08f70363          	beq	a4,a5,80002bae <usertrap+0xd8>
    80002b2c:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause 0x%lx pid=%d\n", r_scause(), p->pid);
    80002b30:	5890                	lw	a2,48(s1)
    80002b32:	00005517          	auipc	a0,0x5
    80002b36:	78e50513          	addi	a0,a0,1934 # 800082c0 <etext+0x2c0>
    80002b3a:	9f3fd0ef          	jal	8000052c <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002b3e:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002b42:	14302673          	csrr	a2,stval
    printf("            sepc=0x%lx stval=0x%lx\n", r_sepc(), r_stval());
    80002b46:	00005517          	auipc	a0,0x5
    80002b4a:	7aa50513          	addi	a0,a0,1962 # 800082f0 <etext+0x2f0>
    80002b4e:	9dffd0ef          	jal	8000052c <printf>
    setkilled(p);
    80002b52:	8526                	mv	a0,s1
    80002b54:	b19ff0ef          	jal	8000266c <setkilled>
    80002b58:	a035                	j	80002b84 <usertrap+0xae>
    panic("usertrap: not from user mode");
    80002b5a:	00005517          	auipc	a0,0x5
    80002b5e:	74650513          	addi	a0,a0,1862 # 800082a0 <etext+0x2a0>
    80002b62:	cf5fd0ef          	jal	80000856 <panic>
    if(killed(p))
    80002b66:	b2bff0ef          	jal	80002690 <killed>
    80002b6a:	ed15                	bnez	a0,80002ba6 <usertrap+0xd0>
    p->trapframe->epc += 4;
    80002b6c:	6cb8                	ld	a4,88(s1)
    80002b6e:	6f1c                	ld	a5,24(a4)
    80002b70:	0791                	addi	a5,a5,4
    80002b72:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002b74:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002b78:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002b7c:	10079073          	csrw	sstatus,a5
    syscall();
    80002b80:	240000ef          	jal	80002dc0 <syscall>
  if(killed(p))
    80002b84:	8526                	mv	a0,s1
    80002b86:	b0bff0ef          	jal	80002690 <killed>
    80002b8a:	e139                	bnez	a0,80002bd0 <usertrap+0xfa>
  prepare_return();
    80002b8c:	e05ff0ef          	jal	80002990 <prepare_return>
  uint64 satp = MAKE_SATP(p->pagetable);
    80002b90:	68a8                	ld	a0,80(s1)
    80002b92:	8131                	srli	a0,a0,0xc
    80002b94:	57fd                	li	a5,-1
    80002b96:	17fe                	slli	a5,a5,0x3f
    80002b98:	8d5d                	or	a0,a0,a5
}
    80002b9a:	60e2                	ld	ra,24(sp)
    80002b9c:	6442                	ld	s0,16(sp)
    80002b9e:	64a2                	ld	s1,8(sp)
    80002ba0:	6902                	ld	s2,0(sp)
    80002ba2:	6105                	addi	sp,sp,32
    80002ba4:	8082                	ret
      kexit(-1);
    80002ba6:	557d                	li	a0,-1
    80002ba8:	9b9ff0ef          	jal	80002560 <kexit>
    80002bac:	b7c1                	j	80002b6c <usertrap+0x96>
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002bae:	143025f3          	csrr	a1,stval
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002bb2:	14202673          	csrr	a2,scause
            vmfault(p->pagetable, r_stval(), (r_scause() == 13)? 1 : 0) != 0) {
    80002bb6:	164d                	addi	a2,a2,-13 # ff3 <_entry-0x7ffff00d>
    80002bb8:	00163613          	seqz	a2,a2
    80002bbc:	68a8                	ld	a0,80(s1)
    80002bbe:	ca5fe0ef          	jal	80001862 <vmfault>
  } else if((r_scause() == 15 || r_scause() == 13) &&
    80002bc2:	f169                	bnez	a0,80002b84 <usertrap+0xae>
    80002bc4:	b7a5                	j	80002b2c <usertrap+0x56>
  if(killed(p))
    80002bc6:	8526                	mv	a0,s1
    80002bc8:	ac9ff0ef          	jal	80002690 <killed>
    80002bcc:	c511                	beqz	a0,80002bd8 <usertrap+0x102>
    80002bce:	a011                	j	80002bd2 <usertrap+0xfc>
    80002bd0:	4901                	li	s2,0
    kexit(-1);
    80002bd2:	557d                	li	a0,-1
    80002bd4:	98dff0ef          	jal	80002560 <kexit>
  if(which_dev == 2)
    80002bd8:	4789                	li	a5,2
    80002bda:	faf919e3          	bne	s2,a5,80002b8c <usertrap+0xb6>
    yield();
    80002bde:	84bff0ef          	jal	80002428 <yield>
    80002be2:	b76d                	j	80002b8c <usertrap+0xb6>

0000000080002be4 <kerneltrap>:
{
    80002be4:	7179                	addi	sp,sp,-48
    80002be6:	f406                	sd	ra,40(sp)
    80002be8:	f022                	sd	s0,32(sp)
    80002bea:	ec26                	sd	s1,24(sp)
    80002bec:	e84a                	sd	s2,16(sp)
    80002bee:	e44e                	sd	s3,8(sp)
    80002bf0:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002bf2:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002bf6:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002bfa:	142027f3          	csrr	a5,scause
    80002bfe:	89be                	mv	s3,a5
  if((sstatus & SSTATUS_SPP) == 0)
    80002c00:	1004f793          	andi	a5,s1,256
    80002c04:	c795                	beqz	a5,80002c30 <kerneltrap+0x4c>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002c06:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002c0a:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    80002c0c:	eb85                	bnez	a5,80002c3c <kerneltrap+0x58>
  if((which_dev = devintr()) == 0){
    80002c0e:	e53ff0ef          	jal	80002a60 <devintr>
    80002c12:	c91d                	beqz	a0,80002c48 <kerneltrap+0x64>
  if(which_dev == 2 && myproc() != 0)
    80002c14:	4789                	li	a5,2
    80002c16:	04f50a63          	beq	a0,a5,80002c6a <kerneltrap+0x86>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002c1a:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002c1e:	10049073          	csrw	sstatus,s1
}
    80002c22:	70a2                	ld	ra,40(sp)
    80002c24:	7402                	ld	s0,32(sp)
    80002c26:	64e2                	ld	s1,24(sp)
    80002c28:	6942                	ld	s2,16(sp)
    80002c2a:	69a2                	ld	s3,8(sp)
    80002c2c:	6145                	addi	sp,sp,48
    80002c2e:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80002c30:	00005517          	auipc	a0,0x5
    80002c34:	6e850513          	addi	a0,a0,1768 # 80008318 <etext+0x318>
    80002c38:	c1ffd0ef          	jal	80000856 <panic>
    panic("kerneltrap: interrupts enabled");
    80002c3c:	00005517          	auipc	a0,0x5
    80002c40:	70450513          	addi	a0,a0,1796 # 80008340 <etext+0x340>
    80002c44:	c13fd0ef          	jal	80000856 <panic>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002c48:	14102673          	csrr	a2,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002c4c:	143026f3          	csrr	a3,stval
    printf("scause=0x%lx sepc=0x%lx stval=0x%lx\n", scause, r_sepc(), r_stval());
    80002c50:	85ce                	mv	a1,s3
    80002c52:	00005517          	auipc	a0,0x5
    80002c56:	70e50513          	addi	a0,a0,1806 # 80008360 <etext+0x360>
    80002c5a:	8d3fd0ef          	jal	8000052c <printf>
    panic("kerneltrap");
    80002c5e:	00005517          	auipc	a0,0x5
    80002c62:	72a50513          	addi	a0,a0,1834 # 80008388 <etext+0x388>
    80002c66:	bf1fd0ef          	jal	80000856 <panic>
  if(which_dev == 2 && myproc() != 0)
    80002c6a:	fbffe0ef          	jal	80001c28 <myproc>
    80002c6e:	d555                	beqz	a0,80002c1a <kerneltrap+0x36>
    yield();
    80002c70:	fb8ff0ef          	jal	80002428 <yield>
    80002c74:	b75d                	j	80002c1a <kerneltrap+0x36>

0000000080002c76 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80002c76:	1101                	addi	sp,sp,-32
    80002c78:	ec06                	sd	ra,24(sp)
    80002c7a:	e822                	sd	s0,16(sp)
    80002c7c:	e426                	sd	s1,8(sp)
    80002c7e:	1000                	addi	s0,sp,32
    80002c80:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002c82:	fa7fe0ef          	jal	80001c28 <myproc>
  switch (n) {
    80002c86:	4795                	li	a5,5
    80002c88:	0497e163          	bltu	a5,s1,80002cca <argraw+0x54>
    80002c8c:	048a                	slli	s1,s1,0x2
    80002c8e:	00006717          	auipc	a4,0x6
    80002c92:	b4270713          	addi	a4,a4,-1214 # 800087d0 <states.0+0x30>
    80002c96:	94ba                	add	s1,s1,a4
    80002c98:	409c                	lw	a5,0(s1)
    80002c9a:	97ba                	add	a5,a5,a4
    80002c9c:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    80002c9e:	6d3c                	ld	a5,88(a0)
    80002ca0:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80002ca2:	60e2                	ld	ra,24(sp)
    80002ca4:	6442                	ld	s0,16(sp)
    80002ca6:	64a2                	ld	s1,8(sp)
    80002ca8:	6105                	addi	sp,sp,32
    80002caa:	8082                	ret
    return p->trapframe->a1;
    80002cac:	6d3c                	ld	a5,88(a0)
    80002cae:	7fa8                	ld	a0,120(a5)
    80002cb0:	bfcd                	j	80002ca2 <argraw+0x2c>
    return p->trapframe->a2;
    80002cb2:	6d3c                	ld	a5,88(a0)
    80002cb4:	63c8                	ld	a0,128(a5)
    80002cb6:	b7f5                	j	80002ca2 <argraw+0x2c>
    return p->trapframe->a3;
    80002cb8:	6d3c                	ld	a5,88(a0)
    80002cba:	67c8                	ld	a0,136(a5)
    80002cbc:	b7dd                	j	80002ca2 <argraw+0x2c>
    return p->trapframe->a4;
    80002cbe:	6d3c                	ld	a5,88(a0)
    80002cc0:	6bc8                	ld	a0,144(a5)
    80002cc2:	b7c5                	j	80002ca2 <argraw+0x2c>
    return p->trapframe->a5;
    80002cc4:	6d3c                	ld	a5,88(a0)
    80002cc6:	6fc8                	ld	a0,152(a5)
    80002cc8:	bfe9                	j	80002ca2 <argraw+0x2c>
  panic("argraw");
    80002cca:	00005517          	auipc	a0,0x5
    80002cce:	6ce50513          	addi	a0,a0,1742 # 80008398 <etext+0x398>
    80002cd2:	b85fd0ef          	jal	80000856 <panic>

0000000080002cd6 <fetchaddr>:
{
    80002cd6:	1101                	addi	sp,sp,-32
    80002cd8:	ec06                	sd	ra,24(sp)
    80002cda:	e822                	sd	s0,16(sp)
    80002cdc:	e426                	sd	s1,8(sp)
    80002cde:	e04a                	sd	s2,0(sp)
    80002ce0:	1000                	addi	s0,sp,32
    80002ce2:	84aa                	mv	s1,a0
    80002ce4:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002ce6:	f43fe0ef          	jal	80001c28 <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    80002cea:	653c                	ld	a5,72(a0)
    80002cec:	02f4f663          	bgeu	s1,a5,80002d18 <fetchaddr+0x42>
    80002cf0:	00848713          	addi	a4,s1,8
    80002cf4:	02e7e463          	bltu	a5,a4,80002d1c <fetchaddr+0x46>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80002cf8:	46a1                	li	a3,8
    80002cfa:	8626                	mv	a2,s1
    80002cfc:	85ca                	mv	a1,s2
    80002cfe:	6928                	ld	a0,80(a0)
    80002d00:	cf9fe0ef          	jal	800019f8 <copyin>
    80002d04:	00a03533          	snez	a0,a0
    80002d08:	40a0053b          	negw	a0,a0
}
    80002d0c:	60e2                	ld	ra,24(sp)
    80002d0e:	6442                	ld	s0,16(sp)
    80002d10:	64a2                	ld	s1,8(sp)
    80002d12:	6902                	ld	s2,0(sp)
    80002d14:	6105                	addi	sp,sp,32
    80002d16:	8082                	ret
    return -1;
    80002d18:	557d                	li	a0,-1
    80002d1a:	bfcd                	j	80002d0c <fetchaddr+0x36>
    80002d1c:	557d                	li	a0,-1
    80002d1e:	b7fd                	j	80002d0c <fetchaddr+0x36>

0000000080002d20 <fetchstr>:
{
    80002d20:	7179                	addi	sp,sp,-48
    80002d22:	f406                	sd	ra,40(sp)
    80002d24:	f022                	sd	s0,32(sp)
    80002d26:	ec26                	sd	s1,24(sp)
    80002d28:	e84a                	sd	s2,16(sp)
    80002d2a:	e44e                	sd	s3,8(sp)
    80002d2c:	1800                	addi	s0,sp,48
    80002d2e:	89aa                	mv	s3,a0
    80002d30:	84ae                	mv	s1,a1
    80002d32:	8932                	mv	s2,a2
  struct proc *p = myproc();
    80002d34:	ef5fe0ef          	jal	80001c28 <myproc>
  if(copyinstr(p->pagetable, buf, addr, max) < 0)
    80002d38:	86ca                	mv	a3,s2
    80002d3a:	864e                	mv	a2,s3
    80002d3c:	85a6                	mv	a1,s1
    80002d3e:	6928                	ld	a0,80(a0)
    80002d40:	a4bfe0ef          	jal	8000178a <copyinstr>
    80002d44:	00054c63          	bltz	a0,80002d5c <fetchstr+0x3c>
  return strlen(buf);
    80002d48:	8526                	mv	a0,s1
    80002d4a:	a26fe0ef          	jal	80000f70 <strlen>
}
    80002d4e:	70a2                	ld	ra,40(sp)
    80002d50:	7402                	ld	s0,32(sp)
    80002d52:	64e2                	ld	s1,24(sp)
    80002d54:	6942                	ld	s2,16(sp)
    80002d56:	69a2                	ld	s3,8(sp)
    80002d58:	6145                	addi	sp,sp,48
    80002d5a:	8082                	ret
    return -1;
    80002d5c:	557d                	li	a0,-1
    80002d5e:	bfc5                	j	80002d4e <fetchstr+0x2e>

0000000080002d60 <argint>:

// Fetch the nth 32-bit system call argument.
void
argint(int n, int *ip)
{
    80002d60:	1101                	addi	sp,sp,-32
    80002d62:	ec06                	sd	ra,24(sp)
    80002d64:	e822                	sd	s0,16(sp)
    80002d66:	e426                	sd	s1,8(sp)
    80002d68:	1000                	addi	s0,sp,32
    80002d6a:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002d6c:	f0bff0ef          	jal	80002c76 <argraw>
    80002d70:	c088                	sw	a0,0(s1)
}
    80002d72:	60e2                	ld	ra,24(sp)
    80002d74:	6442                	ld	s0,16(sp)
    80002d76:	64a2                	ld	s1,8(sp)
    80002d78:	6105                	addi	sp,sp,32
    80002d7a:	8082                	ret

0000000080002d7c <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void
argaddr(int n, uint64 *ip)
{
    80002d7c:	1101                	addi	sp,sp,-32
    80002d7e:	ec06                	sd	ra,24(sp)
    80002d80:	e822                	sd	s0,16(sp)
    80002d82:	e426                	sd	s1,8(sp)
    80002d84:	1000                	addi	s0,sp,32
    80002d86:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002d88:	eefff0ef          	jal	80002c76 <argraw>
    80002d8c:	e088                	sd	a0,0(s1)
}
    80002d8e:	60e2                	ld	ra,24(sp)
    80002d90:	6442                	ld	s0,16(sp)
    80002d92:	64a2                	ld	s1,8(sp)
    80002d94:	6105                	addi	sp,sp,32
    80002d96:	8082                	ret

0000000080002d98 <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80002d98:	1101                	addi	sp,sp,-32
    80002d9a:	ec06                	sd	ra,24(sp)
    80002d9c:	e822                	sd	s0,16(sp)
    80002d9e:	e426                	sd	s1,8(sp)
    80002da0:	e04a                	sd	s2,0(sp)
    80002da2:	1000                	addi	s0,sp,32
    80002da4:	892e                	mv	s2,a1
    80002da6:	84b2                	mv	s1,a2
  *ip = argraw(n);
    80002da8:	ecfff0ef          	jal	80002c76 <argraw>
  uint64 addr;
  argaddr(n, &addr);
  return fetchstr(addr, buf, max);
    80002dac:	8626                	mv	a2,s1
    80002dae:	85ca                	mv	a1,s2
    80002db0:	f71ff0ef          	jal	80002d20 <fetchstr>
}
    80002db4:	60e2                	ld	ra,24(sp)
    80002db6:	6442                	ld	s0,16(sp)
    80002db8:	64a2                	ld	s1,8(sp)
    80002dba:	6902                	ld	s2,0(sp)
    80002dbc:	6105                	addi	sp,sp,32
    80002dbe:	8082                	ret

0000000080002dc0 <syscall>:

};

void
syscall(void)
{
    80002dc0:	1101                	addi	sp,sp,-32
    80002dc2:	ec06                	sd	ra,24(sp)
    80002dc4:	e822                	sd	s0,16(sp)
    80002dc6:	e426                	sd	s1,8(sp)
    80002dc8:	e04a                	sd	s2,0(sp)
    80002dca:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    80002dcc:	e5dfe0ef          	jal	80001c28 <myproc>
    80002dd0:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    80002dd2:	05853903          	ld	s2,88(a0)
    80002dd6:	0a893783          	ld	a5,168(s2)
    80002dda:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80002dde:	37fd                	addiw	a5,a5,-1
    80002de0:	4761                	li	a4,24
    80002de2:	00f76f63          	bltu	a4,a5,80002e00 <syscall+0x40>
    80002de6:	00369713          	slli	a4,a3,0x3
    80002dea:	00006797          	auipc	a5,0x6
    80002dee:	9fe78793          	addi	a5,a5,-1538 # 800087e8 <syscalls>
    80002df2:	97ba                	add	a5,a5,a4
    80002df4:	639c                	ld	a5,0(a5)
    80002df6:	c789                	beqz	a5,80002e00 <syscall+0x40>
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    p->trapframe->a0 = syscalls[num]();
    80002df8:	9782                	jalr	a5
    80002dfa:	06a93823          	sd	a0,112(s2)
    80002dfe:	a829                	j	80002e18 <syscall+0x58>
  } else {
    printf("%d %s: unknown sys call %d\n",
    80002e00:	15848613          	addi	a2,s1,344
    80002e04:	588c                	lw	a1,48(s1)
    80002e06:	00005517          	auipc	a0,0x5
    80002e0a:	59a50513          	addi	a0,a0,1434 # 800083a0 <etext+0x3a0>
    80002e0e:	f1efd0ef          	jal	8000052c <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80002e12:	6cbc                	ld	a5,88(s1)
    80002e14:	577d                	li	a4,-1
    80002e16:	fbb8                	sd	a4,112(a5)
  }
}
    80002e18:	60e2                	ld	ra,24(sp)
    80002e1a:	6442                	ld	s0,16(sp)
    80002e1c:	64a2                	ld	s1,8(sp)
    80002e1e:	6902                	ld	s2,0(sp)
    80002e20:	6105                	addi	sp,sp,32
    80002e22:	8082                	ret

0000000080002e24 <sys_exit>:
#include "vm.h"
#include "schedlog.h"

uint64
sys_exit(void)
{
    80002e24:	1101                	addi	sp,sp,-32
    80002e26:	ec06                	sd	ra,24(sp)
    80002e28:	e822                	sd	s0,16(sp)
    80002e2a:	1000                	addi	s0,sp,32
  int n;
  argint(0, &n);
    80002e2c:	fec40593          	addi	a1,s0,-20
    80002e30:	4501                	li	a0,0
    80002e32:	f2fff0ef          	jal	80002d60 <argint>
  kexit(n);
    80002e36:	fec42503          	lw	a0,-20(s0)
    80002e3a:	f26ff0ef          	jal	80002560 <kexit>
  return 0;  // not reached
}
    80002e3e:	4501                	li	a0,0
    80002e40:	60e2                	ld	ra,24(sp)
    80002e42:	6442                	ld	s0,16(sp)
    80002e44:	6105                	addi	sp,sp,32
    80002e46:	8082                	ret

0000000080002e48 <sys_getpid>:

uint64
sys_getpid(void)
{
    80002e48:	1141                	addi	sp,sp,-16
    80002e4a:	e406                	sd	ra,8(sp)
    80002e4c:	e022                	sd	s0,0(sp)
    80002e4e:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80002e50:	dd9fe0ef          	jal	80001c28 <myproc>
}
    80002e54:	5908                	lw	a0,48(a0)
    80002e56:	60a2                	ld	ra,8(sp)
    80002e58:	6402                	ld	s0,0(sp)
    80002e5a:	0141                	addi	sp,sp,16
    80002e5c:	8082                	ret

0000000080002e5e <sys_fork>:

uint64
sys_fork(void)
{
    80002e5e:	1141                	addi	sp,sp,-16
    80002e60:	e406                	sd	ra,8(sp)
    80002e62:	e022                	sd	s0,0(sp)
    80002e64:	0800                	addi	s0,sp,16
  return kfork();
    80002e66:	996ff0ef          	jal	80001ffc <kfork>
}
    80002e6a:	60a2                	ld	ra,8(sp)
    80002e6c:	6402                	ld	s0,0(sp)
    80002e6e:	0141                	addi	sp,sp,16
    80002e70:	8082                	ret

0000000080002e72 <sys_wait>:

uint64
sys_wait(void)
{
    80002e72:	1101                	addi	sp,sp,-32
    80002e74:	ec06                	sd	ra,24(sp)
    80002e76:	e822                	sd	s0,16(sp)
    80002e78:	1000                	addi	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    80002e7a:	fe840593          	addi	a1,s0,-24
    80002e7e:	4501                	li	a0,0
    80002e80:	efdff0ef          	jal	80002d7c <argaddr>
  return kwait(p);
    80002e84:	fe843503          	ld	a0,-24(s0)
    80002e88:	833ff0ef          	jal	800026ba <kwait>
}
    80002e8c:	60e2                	ld	ra,24(sp)
    80002e8e:	6442                	ld	s0,16(sp)
    80002e90:	6105                	addi	sp,sp,32
    80002e92:	8082                	ret

0000000080002e94 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80002e94:	7179                	addi	sp,sp,-48
    80002e96:	f406                	sd	ra,40(sp)
    80002e98:	f022                	sd	s0,32(sp)
    80002e9a:	ec26                	sd	s1,24(sp)
    80002e9c:	1800                	addi	s0,sp,48
  uint64 addr;
  int t;
  int n;

  argint(0, &n);
    80002e9e:	fd840593          	addi	a1,s0,-40
    80002ea2:	4501                	li	a0,0
    80002ea4:	ebdff0ef          	jal	80002d60 <argint>
  argint(1, &t);
    80002ea8:	fdc40593          	addi	a1,s0,-36
    80002eac:	4505                	li	a0,1
    80002eae:	eb3ff0ef          	jal	80002d60 <argint>
  addr = myproc()->sz;
    80002eb2:	d77fe0ef          	jal	80001c28 <myproc>
    80002eb6:	6524                	ld	s1,72(a0)

  if(t == SBRK_EAGER || n < 0) {
    80002eb8:	fdc42703          	lw	a4,-36(s0)
    80002ebc:	4785                	li	a5,1
    80002ebe:	02f70763          	beq	a4,a5,80002eec <sys_sbrk+0x58>
    80002ec2:	fd842783          	lw	a5,-40(s0)
    80002ec6:	0207c363          	bltz	a5,80002eec <sys_sbrk+0x58>
    }
  } else {
    // Lazily allocate memory for this process: increase its memory
    // size but don't allocate memory. If the processes uses the
    // memory, vmfault() will allocate it.
    if(addr + n < addr)
    80002eca:	97a6                	add	a5,a5,s1
      return -1;
    if(addr + n > TRAPFRAME)
    80002ecc:	02000737          	lui	a4,0x2000
    80002ed0:	177d                	addi	a4,a4,-1 # 1ffffff <_entry-0x7e000001>
    80002ed2:	0736                	slli	a4,a4,0xd
    80002ed4:	02f76a63          	bltu	a4,a5,80002f08 <sys_sbrk+0x74>
    80002ed8:	0297e863          	bltu	a5,s1,80002f08 <sys_sbrk+0x74>
      return -1;
    myproc()->sz += n;
    80002edc:	d4dfe0ef          	jal	80001c28 <myproc>
    80002ee0:	fd842703          	lw	a4,-40(s0)
    80002ee4:	653c                	ld	a5,72(a0)
    80002ee6:	97ba                	add	a5,a5,a4
    80002ee8:	e53c                	sd	a5,72(a0)
    80002eea:	a039                	j	80002ef8 <sys_sbrk+0x64>
    if(growproc(n) < 0) {
    80002eec:	fd842503          	lw	a0,-40(s0)
    80002ef0:	83eff0ef          	jal	80001f2e <growproc>
    80002ef4:	00054863          	bltz	a0,80002f04 <sys_sbrk+0x70>
  }
  return addr;
}
    80002ef8:	8526                	mv	a0,s1
    80002efa:	70a2                	ld	ra,40(sp)
    80002efc:	7402                	ld	s0,32(sp)
    80002efe:	64e2                	ld	s1,24(sp)
    80002f00:	6145                	addi	sp,sp,48
    80002f02:	8082                	ret
      return -1;
    80002f04:	54fd                	li	s1,-1
    80002f06:	bfcd                	j	80002ef8 <sys_sbrk+0x64>
      return -1;
    80002f08:	54fd                	li	s1,-1
    80002f0a:	b7fd                	j	80002ef8 <sys_sbrk+0x64>

0000000080002f0c <sys_pause>:

uint64
sys_pause(void)
{
    80002f0c:	7139                	addi	sp,sp,-64
    80002f0e:	fc06                	sd	ra,56(sp)
    80002f10:	f822                	sd	s0,48(sp)
    80002f12:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    80002f14:	fcc40593          	addi	a1,s0,-52
    80002f18:	4501                	li	a0,0
    80002f1a:	e47ff0ef          	jal	80002d60 <argint>
  if(n < 0)
    80002f1e:	fcc42783          	lw	a5,-52(s0)
    80002f22:	0607c863          	bltz	a5,80002f92 <sys_pause+0x86>
    n = 0;
  acquire(&tickslock);
    80002f26:	00017517          	auipc	a0,0x17
    80002f2a:	80a50513          	addi	a0,a0,-2038 # 80019730 <tickslock>
    80002f2e:	de9fd0ef          	jal	80000d16 <acquire>
  ticks0 = ticks;
  while(ticks - ticks0 < n){
    80002f32:	fcc42783          	lw	a5,-52(s0)
    80002f36:	c3b9                	beqz	a5,80002f7c <sys_pause+0x70>
    80002f38:	f426                	sd	s1,40(sp)
    80002f3a:	f04a                	sd	s2,32(sp)
    80002f3c:	ec4e                	sd	s3,24(sp)
  ticks0 = ticks;
    80002f3e:	00009997          	auipc	s3,0x9
    80002f42:	8529a983          	lw	s3,-1966(s3) # 8000b790 <ticks>
    if(killed(myproc())){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80002f46:	00016917          	auipc	s2,0x16
    80002f4a:	7ea90913          	addi	s2,s2,2026 # 80019730 <tickslock>
    80002f4e:	00009497          	auipc	s1,0x9
    80002f52:	84248493          	addi	s1,s1,-1982 # 8000b790 <ticks>
    if(killed(myproc())){
    80002f56:	cd3fe0ef          	jal	80001c28 <myproc>
    80002f5a:	f36ff0ef          	jal	80002690 <killed>
    80002f5e:	ed0d                	bnez	a0,80002f98 <sys_pause+0x8c>
    sleep(&ticks, &tickslock);
    80002f60:	85ca                	mv	a1,s2
    80002f62:	8526                	mv	a0,s1
    80002f64:	cf0ff0ef          	jal	80002454 <sleep>
  while(ticks - ticks0 < n){
    80002f68:	409c                	lw	a5,0(s1)
    80002f6a:	413787bb          	subw	a5,a5,s3
    80002f6e:	fcc42703          	lw	a4,-52(s0)
    80002f72:	fee7e2e3          	bltu	a5,a4,80002f56 <sys_pause+0x4a>
    80002f76:	74a2                	ld	s1,40(sp)
    80002f78:	7902                	ld	s2,32(sp)
    80002f7a:	69e2                	ld	s3,24(sp)
  }
  release(&tickslock);
    80002f7c:	00016517          	auipc	a0,0x16
    80002f80:	7b450513          	addi	a0,a0,1972 # 80019730 <tickslock>
    80002f84:	e27fd0ef          	jal	80000daa <release>
  return 0;
    80002f88:	4501                	li	a0,0
}
    80002f8a:	70e2                	ld	ra,56(sp)
    80002f8c:	7442                	ld	s0,48(sp)
    80002f8e:	6121                	addi	sp,sp,64
    80002f90:	8082                	ret
    n = 0;
    80002f92:	fc042623          	sw	zero,-52(s0)
    80002f96:	bf41                	j	80002f26 <sys_pause+0x1a>
      release(&tickslock);
    80002f98:	00016517          	auipc	a0,0x16
    80002f9c:	79850513          	addi	a0,a0,1944 # 80019730 <tickslock>
    80002fa0:	e0bfd0ef          	jal	80000daa <release>
      return -1;
    80002fa4:	557d                	li	a0,-1
    80002fa6:	74a2                	ld	s1,40(sp)
    80002fa8:	7902                	ld	s2,32(sp)
    80002faa:	69e2                	ld	s3,24(sp)
    80002fac:	bff9                	j	80002f8a <sys_pause+0x7e>

0000000080002fae <sys_kill>:

uint64
sys_kill(void)
{
    80002fae:	1101                	addi	sp,sp,-32
    80002fb0:	ec06                	sd	ra,24(sp)
    80002fb2:	e822                	sd	s0,16(sp)
    80002fb4:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    80002fb6:	fec40593          	addi	a1,s0,-20
    80002fba:	4501                	li	a0,0
    80002fbc:	da5ff0ef          	jal	80002d60 <argint>
  return kkill(pid);
    80002fc0:	fec42503          	lw	a0,-20(s0)
    80002fc4:	e42ff0ef          	jal	80002606 <kkill>
}
    80002fc8:	60e2                	ld	ra,24(sp)
    80002fca:	6442                	ld	s0,16(sp)
    80002fcc:	6105                	addi	sp,sp,32
    80002fce:	8082                	ret

0000000080002fd0 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80002fd0:	1101                	addi	sp,sp,-32
    80002fd2:	ec06                	sd	ra,24(sp)
    80002fd4:	e822                	sd	s0,16(sp)
    80002fd6:	e426                	sd	s1,8(sp)
    80002fd8:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80002fda:	00016517          	auipc	a0,0x16
    80002fde:	75650513          	addi	a0,a0,1878 # 80019730 <tickslock>
    80002fe2:	d35fd0ef          	jal	80000d16 <acquire>
  xticks = ticks;
    80002fe6:	00008797          	auipc	a5,0x8
    80002fea:	7aa7a783          	lw	a5,1962(a5) # 8000b790 <ticks>
    80002fee:	84be                	mv	s1,a5
  release(&tickslock);
    80002ff0:	00016517          	auipc	a0,0x16
    80002ff4:	74050513          	addi	a0,a0,1856 # 80019730 <tickslock>
    80002ff8:	db3fd0ef          	jal	80000daa <release>
  return xticks;
}
    80002ffc:	02049513          	slli	a0,s1,0x20
    80003000:	9101                	srli	a0,a0,0x20
    80003002:	60e2                	ld	ra,24(sp)
    80003004:	6442                	ld	s0,16(sp)
    80003006:	64a2                	ld	s1,8(sp)
    80003008:	6105                	addi	sp,sp,32
    8000300a:	8082                	ret

000000008000300c <sys_schedread>:

uint64
sys_schedread(void)
{
    8000300c:	7131                	addi	sp,sp,-192
    8000300e:	fd06                	sd	ra,184(sp)
    80003010:	f922                	sd	s0,176(sp)
    80003012:	f526                	sd	s1,168(sp)
    80003014:	f14a                	sd	s2,160(sp)
    80003016:	0180                	addi	s0,sp,192
    80003018:	81010113          	addi	sp,sp,-2032
  uint64 dst;
  int max;

  argaddr(0, &dst);
    8000301c:	fd840593          	addi	a1,s0,-40
    80003020:	4501                	li	a0,0
    80003022:	d5bff0ef          	jal	80002d7c <argaddr>
  argint(1, &max);
    80003026:	fd440593          	addi	a1,s0,-44
    8000302a:	4505                	li	a0,1
    8000302c:	d35ff0ef          	jal	80002d60 <argint>

  if(max <= 0)
    80003030:	fd442783          	lw	a5,-44(s0)
    return 0;
    80003034:	4901                	li	s2,0
  if(max <= 0)
    80003036:	04f05963          	blez	a5,80003088 <sys_schedread+0x7c>

  struct sched_event buf[32];
  if(max > 32)
    8000303a:	02000713          	li	a4,32
    8000303e:	00f75463          	bge	a4,a5,80003046 <sys_schedread+0x3a>
    max = 32;
    80003042:	fce42a23          	sw	a4,-44(s0)

  int n = schedread(buf, max);
    80003046:	fd442583          	lw	a1,-44(s0)
    8000304a:	80040513          	addi	a0,s0,-2048
    8000304e:	1501                	addi	a0,a0,-32
    80003050:	f7050513          	addi	a0,a0,-144
    80003054:	72a030ef          	jal	8000677e <schedread>
    80003058:	84aa                	mv	s1,a0
  if(n < 0)
    return -1;
    8000305a:	57fd                	li	a5,-1
    8000305c:	893e                	mv	s2,a5
  if(n < 0)
    8000305e:	02054563          	bltz	a0,80003088 <sys_schedread+0x7c>

  if(copyout(myproc()->pagetable, dst, (char *)buf, n * sizeof(struct sched_event)) < 0)
    80003062:	bc7fe0ef          	jal	80001c28 <myproc>
    80003066:	8926                	mv	s2,s1
    80003068:	00449693          	slli	a3,s1,0x4
    8000306c:	96a6                	add	a3,a3,s1
    8000306e:	068a                	slli	a3,a3,0x2
    80003070:	80040613          	addi	a2,s0,-2048
    80003074:	1601                	addi	a2,a2,-32
    80003076:	f7060613          	addi	a2,a2,-144
    8000307a:	fd843583          	ld	a1,-40(s0)
    8000307e:	6928                	ld	a0,80(a0)
    80003080:	8bbfe0ef          	jal	8000193a <copyout>
    80003084:	00054b63          	bltz	a0,8000309a <sys_schedread+0x8e>
    return -1;

  return n;
}
    80003088:	854a                	mv	a0,s2
    8000308a:	7f010113          	addi	sp,sp,2032
    8000308e:	70ea                	ld	ra,184(sp)
    80003090:	744a                	ld	s0,176(sp)
    80003092:	74aa                	ld	s1,168(sp)
    80003094:	790a                	ld	s2,160(sp)
    80003096:	6129                	addi	sp,sp,192
    80003098:	8082                	ret
    return -1;
    8000309a:	57fd                	li	a5,-1
    8000309c:	893e                	mv	s2,a5
    8000309e:	b7ed                	j	80003088 <sys_schedread+0x7c>

00000000800030a0 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    800030a0:	7179                	addi	sp,sp,-48
    800030a2:	f406                	sd	ra,40(sp)
    800030a4:	f022                	sd	s0,32(sp)
    800030a6:	ec26                	sd	s1,24(sp)
    800030a8:	e84a                	sd	s2,16(sp)
    800030aa:	e44e                	sd	s3,8(sp)
    800030ac:	e052                	sd	s4,0(sp)
    800030ae:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    800030b0:	00005597          	auipc	a1,0x5
    800030b4:	31058593          	addi	a1,a1,784 # 800083c0 <etext+0x3c0>
    800030b8:	00016517          	auipc	a0,0x16
    800030bc:	69050513          	addi	a0,a0,1680 # 80019748 <bcache>
    800030c0:	bcdfd0ef          	jal	80000c8c <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    800030c4:	0001e797          	auipc	a5,0x1e
    800030c8:	68478793          	addi	a5,a5,1668 # 80021748 <bcache+0x8000>
    800030cc:	0001f717          	auipc	a4,0x1f
    800030d0:	8e470713          	addi	a4,a4,-1820 # 800219b0 <bcache+0x8268>
    800030d4:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    800030d8:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    800030dc:	00016497          	auipc	s1,0x16
    800030e0:	68448493          	addi	s1,s1,1668 # 80019760 <bcache+0x18>
    b->next = bcache.head.next;
    800030e4:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    800030e6:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    800030e8:	00005a17          	auipc	s4,0x5
    800030ec:	2e0a0a13          	addi	s4,s4,736 # 800083c8 <etext+0x3c8>
    b->next = bcache.head.next;
    800030f0:	2b893783          	ld	a5,696(s2)
    800030f4:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    800030f6:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    800030fa:	85d2                	mv	a1,s4
    800030fc:	01048513          	addi	a0,s1,16
    80003100:	366010ef          	jal	80004466 <initsleeplock>
    bcache.head.next->prev = b;
    80003104:	2b893783          	ld	a5,696(s2)
    80003108:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    8000310a:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    8000310e:	45848493          	addi	s1,s1,1112
    80003112:	fd349fe3          	bne	s1,s3,800030f0 <binit+0x50>
  }
}
    80003116:	70a2                	ld	ra,40(sp)
    80003118:	7402                	ld	s0,32(sp)
    8000311a:	64e2                	ld	s1,24(sp)
    8000311c:	6942                	ld	s2,16(sp)
    8000311e:	69a2                	ld	s3,8(sp)
    80003120:	6a02                	ld	s4,0(sp)
    80003122:	6145                	addi	sp,sp,48
    80003124:	8082                	ret

0000000080003126 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    80003126:	7179                	addi	sp,sp,-48
    80003128:	f406                	sd	ra,40(sp)
    8000312a:	f022                	sd	s0,32(sp)
    8000312c:	ec26                	sd	s1,24(sp)
    8000312e:	e84a                	sd	s2,16(sp)
    80003130:	e44e                	sd	s3,8(sp)
    80003132:	1800                	addi	s0,sp,48
    80003134:	892a                	mv	s2,a0
    80003136:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    80003138:	00016517          	auipc	a0,0x16
    8000313c:	61050513          	addi	a0,a0,1552 # 80019748 <bcache>
    80003140:	bd7fd0ef          	jal	80000d16 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    80003144:	0001f497          	auipc	s1,0x1f
    80003148:	8bc4b483          	ld	s1,-1860(s1) # 80021a00 <bcache+0x82b8>
    8000314c:	0001f797          	auipc	a5,0x1f
    80003150:	86478793          	addi	a5,a5,-1948 # 800219b0 <bcache+0x8268>
    80003154:	04f48563          	beq	s1,a5,8000319e <bread+0x78>
    80003158:	873e                	mv	a4,a5
    8000315a:	a021                	j	80003162 <bread+0x3c>
    8000315c:	68a4                	ld	s1,80(s1)
    8000315e:	04e48063          	beq	s1,a4,8000319e <bread+0x78>
    if(b->dev == dev && b->blockno == blockno){
    80003162:	449c                	lw	a5,8(s1)
    80003164:	ff279ce3          	bne	a5,s2,8000315c <bread+0x36>
    80003168:	44dc                	lw	a5,12(s1)
    8000316a:	ff3799e3          	bne	a5,s3,8000315c <bread+0x36>
      b->refcnt++;
    8000316e:	40bc                	lw	a5,64(s1)
    80003170:	2785                	addiw	a5,a5,1
    80003172:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80003174:	00016517          	auipc	a0,0x16
    80003178:	5d450513          	addi	a0,a0,1492 # 80019748 <bcache>
    8000317c:	c2ffd0ef          	jal	80000daa <release>
      acquiresleep(&b->lock);
    80003180:	01048513          	addi	a0,s1,16
    80003184:	318010ef          	jal	8000449c <acquiresleep>
      fslog_push(FS_BGET_HIT, 0, blockno, 0, "BCACHE");
    80003188:	00005717          	auipc	a4,0x5
    8000318c:	24870713          	addi	a4,a4,584 # 800083d0 <etext+0x3d0>
    80003190:	4681                	li	a3,0
    80003192:	864e                	mv	a2,s3
    80003194:	4581                	li	a1,0
    80003196:	4519                	li	a0,6
    80003198:	1d8030ef          	jal	80006370 <fslog_push>
      return b;
    8000319c:	a09d                	j	80003202 <bread+0xdc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    8000319e:	0001f497          	auipc	s1,0x1f
    800031a2:	85a4b483          	ld	s1,-1958(s1) # 800219f8 <bcache+0x82b0>
    800031a6:	0001f797          	auipc	a5,0x1f
    800031aa:	80a78793          	addi	a5,a5,-2038 # 800219b0 <bcache+0x8268>
    800031ae:	00f48863          	beq	s1,a5,800031be <bread+0x98>
    800031b2:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    800031b4:	40bc                	lw	a5,64(s1)
    800031b6:	cb91                	beqz	a5,800031ca <bread+0xa4>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    800031b8:	64a4                	ld	s1,72(s1)
    800031ba:	fee49de3          	bne	s1,a4,800031b4 <bread+0x8e>
  panic("bget: no buffers");
    800031be:	00005517          	auipc	a0,0x5
    800031c2:	21a50513          	addi	a0,a0,538 # 800083d8 <etext+0x3d8>
    800031c6:	e90fd0ef          	jal	80000856 <panic>
      b->dev = dev;
    800031ca:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    800031ce:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    800031d2:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    800031d6:	4785                	li	a5,1
    800031d8:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    800031da:	00016517          	auipc	a0,0x16
    800031de:	56e50513          	addi	a0,a0,1390 # 80019748 <bcache>
    800031e2:	bc9fd0ef          	jal	80000daa <release>
      acquiresleep(&b->lock);
    800031e6:	01048513          	addi	a0,s1,16
    800031ea:	2b2010ef          	jal	8000449c <acquiresleep>
      fslog_push(FS_BGET_MISS, 0, blockno, 0, "BCACHE");
    800031ee:	00005717          	auipc	a4,0x5
    800031f2:	1e270713          	addi	a4,a4,482 # 800083d0 <etext+0x3d0>
    800031f6:	4681                	li	a3,0
    800031f8:	864e                	mv	a2,s3
    800031fa:	4581                	li	a1,0
    800031fc:	451d                	li	a0,7
    800031fe:	172030ef          	jal	80006370 <fslog_push>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    80003202:	409c                	lw	a5,0(s1)
    80003204:	cb89                	beqz	a5,80003216 <bread+0xf0>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80003206:	8526                	mv	a0,s1
    80003208:	70a2                	ld	ra,40(sp)
    8000320a:	7402                	ld	s0,32(sp)
    8000320c:	64e2                	ld	s1,24(sp)
    8000320e:	6942                	ld	s2,16(sp)
    80003210:	69a2                	ld	s3,8(sp)
    80003212:	6145                	addi	sp,sp,48
    80003214:	8082                	ret
    virtio_disk_rw(b, 0);
    80003216:	4581                	li	a1,0
    80003218:	8526                	mv	a0,s1
    8000321a:	337020ef          	jal	80005d50 <virtio_disk_rw>
    b->valid = 1;
    8000321e:	4785                	li	a5,1
    80003220:	c09c                	sw	a5,0(s1)
  return b;
    80003222:	b7d5                	j	80003206 <bread+0xe0>

0000000080003224 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    80003224:	1101                	addi	sp,sp,-32
    80003226:	ec06                	sd	ra,24(sp)
    80003228:	e822                	sd	s0,16(sp)
    8000322a:	e426                	sd	s1,8(sp)
    8000322c:	1000                	addi	s0,sp,32
    8000322e:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80003230:	0541                	addi	a0,a0,16
    80003232:	2e8010ef          	jal	8000451a <holdingsleep>
    80003236:	c911                	beqz	a0,8000324a <bwrite+0x26>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    80003238:	4585                	li	a1,1
    8000323a:	8526                	mv	a0,s1
    8000323c:	315020ef          	jal	80005d50 <virtio_disk_rw>
}
    80003240:	60e2                	ld	ra,24(sp)
    80003242:	6442                	ld	s0,16(sp)
    80003244:	64a2                	ld	s1,8(sp)
    80003246:	6105                	addi	sp,sp,32
    80003248:	8082                	ret
    panic("bwrite");
    8000324a:	00005517          	auipc	a0,0x5
    8000324e:	1a650513          	addi	a0,a0,422 # 800083f0 <etext+0x3f0>
    80003252:	e04fd0ef          	jal	80000856 <panic>

0000000080003256 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    80003256:	1101                	addi	sp,sp,-32
    80003258:	ec06                	sd	ra,24(sp)
    8000325a:	e822                	sd	s0,16(sp)
    8000325c:	e426                	sd	s1,8(sp)
    8000325e:	e04a                	sd	s2,0(sp)
    80003260:	1000                	addi	s0,sp,32
    80003262:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80003264:	01050913          	addi	s2,a0,16
    80003268:	854a                	mv	a0,s2
    8000326a:	2b0010ef          	jal	8000451a <holdingsleep>
    8000326e:	c915                	beqz	a0,800032a2 <brelse+0x4c>
    panic("brelse");

  releasesleep(&b->lock);
    80003270:	854a                	mv	a0,s2
    80003272:	270010ef          	jal	800044e2 <releasesleep>

  acquire(&bcache.lock);
    80003276:	00016517          	auipc	a0,0x16
    8000327a:	4d250513          	addi	a0,a0,1234 # 80019748 <bcache>
    8000327e:	a99fd0ef          	jal	80000d16 <acquire>
  b->refcnt--;
    80003282:	40bc                	lw	a5,64(s1)
    80003284:	37fd                	addiw	a5,a5,-1
    80003286:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    80003288:	c39d                	beqz	a5,800032ae <brelse+0x58>
    bcache.head.next->prev = b;
    bcache.head.next = b;
    fslog_push(FS_BRELEASE, 0, b->blockno, 0, "BCACHE");
  }
  
  release(&bcache.lock);
    8000328a:	00016517          	auipc	a0,0x16
    8000328e:	4be50513          	addi	a0,a0,1214 # 80019748 <bcache>
    80003292:	b19fd0ef          	jal	80000daa <release>
}
    80003296:	60e2                	ld	ra,24(sp)
    80003298:	6442                	ld	s0,16(sp)
    8000329a:	64a2                	ld	s1,8(sp)
    8000329c:	6902                	ld	s2,0(sp)
    8000329e:	6105                	addi	sp,sp,32
    800032a0:	8082                	ret
    panic("brelse");
    800032a2:	00005517          	auipc	a0,0x5
    800032a6:	15650513          	addi	a0,a0,342 # 800083f8 <etext+0x3f8>
    800032aa:	dacfd0ef          	jal	80000856 <panic>
    b->next->prev = b->prev;
    800032ae:	68b8                	ld	a4,80(s1)
    800032b0:	64bc                	ld	a5,72(s1)
    800032b2:	e73c                	sd	a5,72(a4)
    b->prev->next = b->next;
    800032b4:	68b8                	ld	a4,80(s1)
    800032b6:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    800032b8:	0001e797          	auipc	a5,0x1e
    800032bc:	49078793          	addi	a5,a5,1168 # 80021748 <bcache+0x8000>
    800032c0:	2b87b703          	ld	a4,696(a5)
    800032c4:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    800032c6:	0001e717          	auipc	a4,0x1e
    800032ca:	6ea70713          	addi	a4,a4,1770 # 800219b0 <bcache+0x8268>
    800032ce:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    800032d0:	2b87b703          	ld	a4,696(a5)
    800032d4:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    800032d6:	2a97bc23          	sd	s1,696(a5)
    fslog_push(FS_BRELEASE, 0, b->blockno, 0, "BCACHE");
    800032da:	00005717          	auipc	a4,0x5
    800032de:	0f670713          	addi	a4,a4,246 # 800083d0 <etext+0x3d0>
    800032e2:	4681                	li	a3,0
    800032e4:	44d0                	lw	a2,12(s1)
    800032e6:	4581                	li	a1,0
    800032e8:	4521                	li	a0,8
    800032ea:	086030ef          	jal	80006370 <fslog_push>
    800032ee:	bf71                	j	8000328a <brelse+0x34>

00000000800032f0 <bpin>:

void
bpin(struct buf *b) {
    800032f0:	1101                	addi	sp,sp,-32
    800032f2:	ec06                	sd	ra,24(sp)
    800032f4:	e822                	sd	s0,16(sp)
    800032f6:	e426                	sd	s1,8(sp)
    800032f8:	1000                	addi	s0,sp,32
    800032fa:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    800032fc:	00016517          	auipc	a0,0x16
    80003300:	44c50513          	addi	a0,a0,1100 # 80019748 <bcache>
    80003304:	a13fd0ef          	jal	80000d16 <acquire>
  b->refcnt++;
    80003308:	40bc                	lw	a5,64(s1)
    8000330a:	2785                	addiw	a5,a5,1
    8000330c:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    8000330e:	00016517          	auipc	a0,0x16
    80003312:	43a50513          	addi	a0,a0,1082 # 80019748 <bcache>
    80003316:	a95fd0ef          	jal	80000daa <release>
}
    8000331a:	60e2                	ld	ra,24(sp)
    8000331c:	6442                	ld	s0,16(sp)
    8000331e:	64a2                	ld	s1,8(sp)
    80003320:	6105                	addi	sp,sp,32
    80003322:	8082                	ret

0000000080003324 <bunpin>:

void
bunpin(struct buf *b) {
    80003324:	1101                	addi	sp,sp,-32
    80003326:	ec06                	sd	ra,24(sp)
    80003328:	e822                	sd	s0,16(sp)
    8000332a:	e426                	sd	s1,8(sp)
    8000332c:	1000                	addi	s0,sp,32
    8000332e:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80003330:	00016517          	auipc	a0,0x16
    80003334:	41850513          	addi	a0,a0,1048 # 80019748 <bcache>
    80003338:	9dffd0ef          	jal	80000d16 <acquire>
  b->refcnt--;
    8000333c:	40bc                	lw	a5,64(s1)
    8000333e:	37fd                	addiw	a5,a5,-1
    80003340:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80003342:	00016517          	auipc	a0,0x16
    80003346:	40650513          	addi	a0,a0,1030 # 80019748 <bcache>
    8000334a:	a61fd0ef          	jal	80000daa <release>
}
    8000334e:	60e2                	ld	ra,24(sp)
    80003350:	6442                	ld	s0,16(sp)
    80003352:	64a2                	ld	s1,8(sp)
    80003354:	6105                	addi	sp,sp,32
    80003356:	8082                	ret

0000000080003358 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    80003358:	1101                	addi	sp,sp,-32
    8000335a:	ec06                	sd	ra,24(sp)
    8000335c:	e822                	sd	s0,16(sp)
    8000335e:	e426                	sd	s1,8(sp)
    80003360:	e04a                	sd	s2,0(sp)
    80003362:	1000                	addi	s0,sp,32
    80003364:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    80003366:	00d5d79b          	srliw	a5,a1,0xd
    8000336a:	0001f597          	auipc	a1,0x1f
    8000336e:	aba5a583          	lw	a1,-1350(a1) # 80021e24 <sb+0x1c>
    80003372:	9dbd                	addw	a1,a1,a5
    80003374:	db3ff0ef          	jal	80003126 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    80003378:	0074f713          	andi	a4,s1,7
    8000337c:	4785                	li	a5,1
    8000337e:	00e797bb          	sllw	a5,a5,a4
  bi = b % BPB;
    80003382:	14ce                	slli	s1,s1,0x33
  if((bp->data[bi/8] & m) == 0)
    80003384:	90d9                	srli	s1,s1,0x36
    80003386:	00950733          	add	a4,a0,s1
    8000338a:	05874703          	lbu	a4,88(a4)
    8000338e:	00e7f6b3          	and	a3,a5,a4
    80003392:	c29d                	beqz	a3,800033b8 <bfree+0x60>
    80003394:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    80003396:	94aa                	add	s1,s1,a0
    80003398:	fff7c793          	not	a5,a5
    8000339c:	8f7d                	and	a4,a4,a5
    8000339e:	04e48c23          	sb	a4,88(s1)
  log_write(bp);
    800033a2:	000010ef          	jal	800043a2 <log_write>
  brelse(bp);
    800033a6:	854a                	mv	a0,s2
    800033a8:	eafff0ef          	jal	80003256 <brelse>
}
    800033ac:	60e2                	ld	ra,24(sp)
    800033ae:	6442                	ld	s0,16(sp)
    800033b0:	64a2                	ld	s1,8(sp)
    800033b2:	6902                	ld	s2,0(sp)
    800033b4:	6105                	addi	sp,sp,32
    800033b6:	8082                	ret
    panic("freeing free block");
    800033b8:	00005517          	auipc	a0,0x5
    800033bc:	04850513          	addi	a0,a0,72 # 80008400 <etext+0x400>
    800033c0:	c96fd0ef          	jal	80000856 <panic>

00000000800033c4 <balloc>:
{
    800033c4:	715d                	addi	sp,sp,-80
    800033c6:	e486                	sd	ra,72(sp)
    800033c8:	e0a2                	sd	s0,64(sp)
    800033ca:	fc26                	sd	s1,56(sp)
    800033cc:	0880                	addi	s0,sp,80
  for(b = 0; b < sb.size; b += BPB){
    800033ce:	0001f797          	auipc	a5,0x1f
    800033d2:	a3e7a783          	lw	a5,-1474(a5) # 80021e0c <sb+0x4>
    800033d6:	0e078263          	beqz	a5,800034ba <balloc+0xf6>
    800033da:	f84a                	sd	s2,48(sp)
    800033dc:	f44e                	sd	s3,40(sp)
    800033de:	f052                	sd	s4,32(sp)
    800033e0:	ec56                	sd	s5,24(sp)
    800033e2:	e85a                	sd	s6,16(sp)
    800033e4:	e45e                	sd	s7,8(sp)
    800033e6:	e062                	sd	s8,0(sp)
    800033e8:	8baa                	mv	s7,a0
    800033ea:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    800033ec:	0001fb17          	auipc	s6,0x1f
    800033f0:	a1cb0b13          	addi	s6,s6,-1508 # 80021e08 <sb>
      m = 1 << (bi % 8);
    800033f4:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800033f6:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    800033f8:	6c09                	lui	s8,0x2
    800033fa:	a09d                	j	80003460 <balloc+0x9c>
        bp->data[bi/8] |= m;  // Mark block in use.
    800033fc:	97ca                	add	a5,a5,s2
    800033fe:	8e55                	or	a2,a2,a3
    80003400:	04c78c23          	sb	a2,88(a5)
        log_write(bp);
    80003404:	854a                	mv	a0,s2
    80003406:	79d000ef          	jal	800043a2 <log_write>
        brelse(bp);
    8000340a:	854a                	mv	a0,s2
    8000340c:	e4bff0ef          	jal	80003256 <brelse>
  bp = bread(dev, bno);
    80003410:	85a6                	mv	a1,s1
    80003412:	855e                	mv	a0,s7
    80003414:	d13ff0ef          	jal	80003126 <bread>
    80003418:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    8000341a:	40000613          	li	a2,1024
    8000341e:	4581                	li	a1,0
    80003420:	05850513          	addi	a0,a0,88
    80003424:	9c3fd0ef          	jal	80000de6 <memset>
  log_write(bp);
    80003428:	854a                	mv	a0,s2
    8000342a:	779000ef          	jal	800043a2 <log_write>
  brelse(bp);
    8000342e:	854a                	mv	a0,s2
    80003430:	e27ff0ef          	jal	80003256 <brelse>
}
    80003434:	7942                	ld	s2,48(sp)
    80003436:	79a2                	ld	s3,40(sp)
    80003438:	7a02                	ld	s4,32(sp)
    8000343a:	6ae2                	ld	s5,24(sp)
    8000343c:	6b42                	ld	s6,16(sp)
    8000343e:	6ba2                	ld	s7,8(sp)
    80003440:	6c02                	ld	s8,0(sp)
}
    80003442:	8526                	mv	a0,s1
    80003444:	60a6                	ld	ra,72(sp)
    80003446:	6406                	ld	s0,64(sp)
    80003448:	74e2                	ld	s1,56(sp)
    8000344a:	6161                	addi	sp,sp,80
    8000344c:	8082                	ret
    brelse(bp);
    8000344e:	854a                	mv	a0,s2
    80003450:	e07ff0ef          	jal	80003256 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    80003454:	015c0abb          	addw	s5,s8,s5
    80003458:	004b2783          	lw	a5,4(s6)
    8000345c:	04faf863          	bgeu	s5,a5,800034ac <balloc+0xe8>
    bp = bread(dev, BBLOCK(b, sb));
    80003460:	40dad59b          	sraiw	a1,s5,0xd
    80003464:	01cb2783          	lw	a5,28(s6)
    80003468:	9dbd                	addw	a1,a1,a5
    8000346a:	855e                	mv	a0,s7
    8000346c:	cbbff0ef          	jal	80003126 <bread>
    80003470:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003472:	004b2503          	lw	a0,4(s6)
    80003476:	84d6                	mv	s1,s5
    80003478:	4701                	li	a4,0
    8000347a:	fca4fae3          	bgeu	s1,a0,8000344e <balloc+0x8a>
      m = 1 << (bi % 8);
    8000347e:	00777693          	andi	a3,a4,7
    80003482:	00d996bb          	sllw	a3,s3,a3
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    80003486:	41f7579b          	sraiw	a5,a4,0x1f
    8000348a:	01d7d79b          	srliw	a5,a5,0x1d
    8000348e:	9fb9                	addw	a5,a5,a4
    80003490:	4037d79b          	sraiw	a5,a5,0x3
    80003494:	00f90633          	add	a2,s2,a5
    80003498:	05864603          	lbu	a2,88(a2)
    8000349c:	00c6f5b3          	and	a1,a3,a2
    800034a0:	ddb1                	beqz	a1,800033fc <balloc+0x38>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800034a2:	2705                	addiw	a4,a4,1
    800034a4:	2485                	addiw	s1,s1,1
    800034a6:	fd471ae3          	bne	a4,s4,8000347a <balloc+0xb6>
    800034aa:	b755                	j	8000344e <balloc+0x8a>
    800034ac:	7942                	ld	s2,48(sp)
    800034ae:	79a2                	ld	s3,40(sp)
    800034b0:	7a02                	ld	s4,32(sp)
    800034b2:	6ae2                	ld	s5,24(sp)
    800034b4:	6b42                	ld	s6,16(sp)
    800034b6:	6ba2                	ld	s7,8(sp)
    800034b8:	6c02                	ld	s8,0(sp)
  printf("balloc: out of blocks\n");
    800034ba:	00005517          	auipc	a0,0x5
    800034be:	f5e50513          	addi	a0,a0,-162 # 80008418 <etext+0x418>
    800034c2:	86afd0ef          	jal	8000052c <printf>
  return 0;
    800034c6:	4481                	li	s1,0
    800034c8:	bfad                	j	80003442 <balloc+0x7e>

00000000800034ca <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    800034ca:	7179                	addi	sp,sp,-48
    800034cc:	f406                	sd	ra,40(sp)
    800034ce:	f022                	sd	s0,32(sp)
    800034d0:	ec26                	sd	s1,24(sp)
    800034d2:	e84a                	sd	s2,16(sp)
    800034d4:	e44e                	sd	s3,8(sp)
    800034d6:	1800                	addi	s0,sp,48
    800034d8:	892a                	mv	s2,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    800034da:	47ad                	li	a5,11
    800034dc:	02b7e363          	bltu	a5,a1,80003502 <bmap+0x38>
    if((addr = ip->addrs[bn]) == 0){
    800034e0:	02059793          	slli	a5,a1,0x20
    800034e4:	01e7d593          	srli	a1,a5,0x1e
    800034e8:	00b509b3          	add	s3,a0,a1
    800034ec:	0509a483          	lw	s1,80(s3)
    800034f0:	e0b5                	bnez	s1,80003554 <bmap+0x8a>
      addr = balloc(ip->dev);
    800034f2:	4108                	lw	a0,0(a0)
    800034f4:	ed1ff0ef          	jal	800033c4 <balloc>
    800034f8:	84aa                	mv	s1,a0
      if(addr == 0)
    800034fa:	cd29                	beqz	a0,80003554 <bmap+0x8a>
        return 0;
      ip->addrs[bn] = addr;
    800034fc:	04a9a823          	sw	a0,80(s3)
    80003500:	a891                	j	80003554 <bmap+0x8a>
    }
    return addr;
  }
  bn -= NDIRECT;
    80003502:	ff45879b          	addiw	a5,a1,-12
    80003506:	873e                	mv	a4,a5
    80003508:	89be                	mv	s3,a5

  if(bn < NINDIRECT){
    8000350a:	0ff00793          	li	a5,255
    8000350e:	06e7e763          	bltu	a5,a4,8000357c <bmap+0xb2>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    80003512:	08052483          	lw	s1,128(a0)
    80003516:	e891                	bnez	s1,8000352a <bmap+0x60>
      addr = balloc(ip->dev);
    80003518:	4108                	lw	a0,0(a0)
    8000351a:	eabff0ef          	jal	800033c4 <balloc>
    8000351e:	84aa                	mv	s1,a0
      if(addr == 0)
    80003520:	c915                	beqz	a0,80003554 <bmap+0x8a>
    80003522:	e052                	sd	s4,0(sp)
        return 0;
      ip->addrs[NDIRECT] = addr;
    80003524:	08a92023          	sw	a0,128(s2)
    80003528:	a011                	j	8000352c <bmap+0x62>
    8000352a:	e052                	sd	s4,0(sp)
    }
    bp = bread(ip->dev, addr);
    8000352c:	85a6                	mv	a1,s1
    8000352e:	00092503          	lw	a0,0(s2)
    80003532:	bf5ff0ef          	jal	80003126 <bread>
    80003536:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    80003538:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    8000353c:	02099713          	slli	a4,s3,0x20
    80003540:	01e75593          	srli	a1,a4,0x1e
    80003544:	97ae                	add	a5,a5,a1
    80003546:	89be                	mv	s3,a5
    80003548:	4384                	lw	s1,0(a5)
    8000354a:	cc89                	beqz	s1,80003564 <bmap+0x9a>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    8000354c:	8552                	mv	a0,s4
    8000354e:	d09ff0ef          	jal	80003256 <brelse>
    return addr;
    80003552:	6a02                	ld	s4,0(sp)
  }

  panic("bmap: out of range");
}
    80003554:	8526                	mv	a0,s1
    80003556:	70a2                	ld	ra,40(sp)
    80003558:	7402                	ld	s0,32(sp)
    8000355a:	64e2                	ld	s1,24(sp)
    8000355c:	6942                	ld	s2,16(sp)
    8000355e:	69a2                	ld	s3,8(sp)
    80003560:	6145                	addi	sp,sp,48
    80003562:	8082                	ret
      addr = balloc(ip->dev);
    80003564:	00092503          	lw	a0,0(s2)
    80003568:	e5dff0ef          	jal	800033c4 <balloc>
    8000356c:	84aa                	mv	s1,a0
      if(addr){
    8000356e:	dd79                	beqz	a0,8000354c <bmap+0x82>
        a[bn] = addr;
    80003570:	00a9a023          	sw	a0,0(s3)
        log_write(bp);
    80003574:	8552                	mv	a0,s4
    80003576:	62d000ef          	jal	800043a2 <log_write>
    8000357a:	bfc9                	j	8000354c <bmap+0x82>
    8000357c:	e052                	sd	s4,0(sp)
  panic("bmap: out of range");
    8000357e:	00005517          	auipc	a0,0x5
    80003582:	eb250513          	addi	a0,a0,-334 # 80008430 <etext+0x430>
    80003586:	ad0fd0ef          	jal	80000856 <panic>

000000008000358a <iget>:
{
    8000358a:	7179                	addi	sp,sp,-48
    8000358c:	f406                	sd	ra,40(sp)
    8000358e:	f022                	sd	s0,32(sp)
    80003590:	ec26                	sd	s1,24(sp)
    80003592:	e84a                	sd	s2,16(sp)
    80003594:	e44e                	sd	s3,8(sp)
    80003596:	e052                	sd	s4,0(sp)
    80003598:	1800                	addi	s0,sp,48
    8000359a:	892a                	mv	s2,a0
    8000359c:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    8000359e:	0001f517          	auipc	a0,0x1f
    800035a2:	88a50513          	addi	a0,a0,-1910 # 80021e28 <itable>
    800035a6:	f70fd0ef          	jal	80000d16 <acquire>
  empty = 0;
    800035aa:	4981                	li	s3,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    800035ac:	0001f497          	auipc	s1,0x1f
    800035b0:	89448493          	addi	s1,s1,-1900 # 80021e40 <itable+0x18>
    800035b4:	00020697          	auipc	a3,0x20
    800035b8:	31c68693          	addi	a3,a3,796 # 800238d0 <log>
    800035bc:	a809                	j	800035ce <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    800035be:	e781                	bnez	a5,800035c6 <iget+0x3c>
    800035c0:	00099363          	bnez	s3,800035c6 <iget+0x3c>
      empty = ip;
    800035c4:	89a6                	mv	s3,s1
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    800035c6:	08848493          	addi	s1,s1,136
    800035ca:	02d48563          	beq	s1,a3,800035f4 <iget+0x6a>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    800035ce:	449c                	lw	a5,8(s1)
    800035d0:	fef057e3          	blez	a5,800035be <iget+0x34>
    800035d4:	4098                	lw	a4,0(s1)
    800035d6:	ff2718e3          	bne	a4,s2,800035c6 <iget+0x3c>
    800035da:	40d8                	lw	a4,4(s1)
    800035dc:	ff4715e3          	bne	a4,s4,800035c6 <iget+0x3c>
      ip->ref++;
    800035e0:	2785                	addiw	a5,a5,1
    800035e2:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    800035e4:	0001f517          	auipc	a0,0x1f
    800035e8:	84450513          	addi	a0,a0,-1980 # 80021e28 <itable>
    800035ec:	fbefd0ef          	jal	80000daa <release>
      return ip;
    800035f0:	89a6                	mv	s3,s1
    800035f2:	a015                	j	80003616 <iget+0x8c>
  if(empty == 0)
    800035f4:	02098a63          	beqz	s3,80003628 <iget+0x9e>
  ip->dev = dev;
    800035f8:	0129a023          	sw	s2,0(s3)
  ip->inum = inum;
    800035fc:	0149a223          	sw	s4,4(s3)
  ip->ref = 1;
    80003600:	4785                	li	a5,1
    80003602:	00f9a423          	sw	a5,8(s3)
  ip->valid = 0;
    80003606:	0409a023          	sw	zero,64(s3)
  release(&itable.lock);
    8000360a:	0001f517          	auipc	a0,0x1f
    8000360e:	81e50513          	addi	a0,a0,-2018 # 80021e28 <itable>
    80003612:	f98fd0ef          	jal	80000daa <release>
}
    80003616:	854e                	mv	a0,s3
    80003618:	70a2                	ld	ra,40(sp)
    8000361a:	7402                	ld	s0,32(sp)
    8000361c:	64e2                	ld	s1,24(sp)
    8000361e:	6942                	ld	s2,16(sp)
    80003620:	69a2                	ld	s3,8(sp)
    80003622:	6a02                	ld	s4,0(sp)
    80003624:	6145                	addi	sp,sp,48
    80003626:	8082                	ret
    panic("iget: no inodes");
    80003628:	00005517          	auipc	a0,0x5
    8000362c:	e2050513          	addi	a0,a0,-480 # 80008448 <etext+0x448>
    80003630:	a26fd0ef          	jal	80000856 <panic>

0000000080003634 <iinit>:
{
    80003634:	7179                	addi	sp,sp,-48
    80003636:	f406                	sd	ra,40(sp)
    80003638:	f022                	sd	s0,32(sp)
    8000363a:	ec26                	sd	s1,24(sp)
    8000363c:	e84a                	sd	s2,16(sp)
    8000363e:	e44e                	sd	s3,8(sp)
    80003640:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    80003642:	00005597          	auipc	a1,0x5
    80003646:	e1658593          	addi	a1,a1,-490 # 80008458 <etext+0x458>
    8000364a:	0001e517          	auipc	a0,0x1e
    8000364e:	7de50513          	addi	a0,a0,2014 # 80021e28 <itable>
    80003652:	e3afd0ef          	jal	80000c8c <initlock>
  for(i = 0; i < NINODE; i++) {
    80003656:	0001e497          	auipc	s1,0x1e
    8000365a:	7fa48493          	addi	s1,s1,2042 # 80021e50 <itable+0x28>
    8000365e:	00020997          	auipc	s3,0x20
    80003662:	28298993          	addi	s3,s3,642 # 800238e0 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    80003666:	00005917          	auipc	s2,0x5
    8000366a:	dfa90913          	addi	s2,s2,-518 # 80008460 <etext+0x460>
    8000366e:	85ca                	mv	a1,s2
    80003670:	8526                	mv	a0,s1
    80003672:	5f5000ef          	jal	80004466 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    80003676:	08848493          	addi	s1,s1,136
    8000367a:	ff349ae3          	bne	s1,s3,8000366e <iinit+0x3a>
}
    8000367e:	70a2                	ld	ra,40(sp)
    80003680:	7402                	ld	s0,32(sp)
    80003682:	64e2                	ld	s1,24(sp)
    80003684:	6942                	ld	s2,16(sp)
    80003686:	69a2                	ld	s3,8(sp)
    80003688:	6145                	addi	sp,sp,48
    8000368a:	8082                	ret

000000008000368c <ialloc>:
{
    8000368c:	7139                	addi	sp,sp,-64
    8000368e:	fc06                	sd	ra,56(sp)
    80003690:	f822                	sd	s0,48(sp)
    80003692:	0080                	addi	s0,sp,64
  for(inum = 1; inum < sb.ninodes; inum++){
    80003694:	0001e717          	auipc	a4,0x1e
    80003698:	78072703          	lw	a4,1920(a4) # 80021e14 <sb+0xc>
    8000369c:	4785                	li	a5,1
    8000369e:	06e7f063          	bgeu	a5,a4,800036fe <ialloc+0x72>
    800036a2:	f426                	sd	s1,40(sp)
    800036a4:	f04a                	sd	s2,32(sp)
    800036a6:	ec4e                	sd	s3,24(sp)
    800036a8:	e852                	sd	s4,16(sp)
    800036aa:	e456                	sd	s5,8(sp)
    800036ac:	e05a                	sd	s6,0(sp)
    800036ae:	8aaa                	mv	s5,a0
    800036b0:	8b2e                	mv	s6,a1
    800036b2:	893e                	mv	s2,a5
    bp = bread(dev, IBLOCK(inum, sb));
    800036b4:	0001ea17          	auipc	s4,0x1e
    800036b8:	754a0a13          	addi	s4,s4,1876 # 80021e08 <sb>
    800036bc:	00495593          	srli	a1,s2,0x4
    800036c0:	018a2783          	lw	a5,24(s4)
    800036c4:	9dbd                	addw	a1,a1,a5
    800036c6:	8556                	mv	a0,s5
    800036c8:	a5fff0ef          	jal	80003126 <bread>
    800036cc:	84aa                	mv	s1,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    800036ce:	05850993          	addi	s3,a0,88
    800036d2:	00f97793          	andi	a5,s2,15
    800036d6:	079a                	slli	a5,a5,0x6
    800036d8:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    800036da:	00099783          	lh	a5,0(s3)
    800036de:	cb9d                	beqz	a5,80003714 <ialloc+0x88>
    brelse(bp);
    800036e0:	b77ff0ef          	jal	80003256 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    800036e4:	0905                	addi	s2,s2,1
    800036e6:	00ca2703          	lw	a4,12(s4)
    800036ea:	0009079b          	sext.w	a5,s2
    800036ee:	fce7e7e3          	bltu	a5,a4,800036bc <ialloc+0x30>
    800036f2:	74a2                	ld	s1,40(sp)
    800036f4:	7902                	ld	s2,32(sp)
    800036f6:	69e2                	ld	s3,24(sp)
    800036f8:	6a42                	ld	s4,16(sp)
    800036fa:	6aa2                	ld	s5,8(sp)
    800036fc:	6b02                	ld	s6,0(sp)
  printf("ialloc: no inodes\n");
    800036fe:	00005517          	auipc	a0,0x5
    80003702:	d6a50513          	addi	a0,a0,-662 # 80008468 <etext+0x468>
    80003706:	e27fc0ef          	jal	8000052c <printf>
  return 0;
    8000370a:	4501                	li	a0,0
}
    8000370c:	70e2                	ld	ra,56(sp)
    8000370e:	7442                	ld	s0,48(sp)
    80003710:	6121                	addi	sp,sp,64
    80003712:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    80003714:	04000613          	li	a2,64
    80003718:	4581                	li	a1,0
    8000371a:	854e                	mv	a0,s3
    8000371c:	ecafd0ef          	jal	80000de6 <memset>
      dip->type = type;
    80003720:	01699023          	sh	s6,0(s3)
      log_write(bp);   // mark it allocated on the disk
    80003724:	8526                	mv	a0,s1
    80003726:	47d000ef          	jal	800043a2 <log_write>
      brelse(bp);
    8000372a:	8526                	mv	a0,s1
    8000372c:	b2bff0ef          	jal	80003256 <brelse>
      return iget(dev, inum);
    80003730:	0009059b          	sext.w	a1,s2
    80003734:	8556                	mv	a0,s5
    80003736:	e55ff0ef          	jal	8000358a <iget>
    8000373a:	74a2                	ld	s1,40(sp)
    8000373c:	7902                	ld	s2,32(sp)
    8000373e:	69e2                	ld	s3,24(sp)
    80003740:	6a42                	ld	s4,16(sp)
    80003742:	6aa2                	ld	s5,8(sp)
    80003744:	6b02                	ld	s6,0(sp)
    80003746:	b7d9                	j	8000370c <ialloc+0x80>

0000000080003748 <iupdate>:
{
    80003748:	1101                	addi	sp,sp,-32
    8000374a:	ec06                	sd	ra,24(sp)
    8000374c:	e822                	sd	s0,16(sp)
    8000374e:	e426                	sd	s1,8(sp)
    80003750:	e04a                	sd	s2,0(sp)
    80003752:	1000                	addi	s0,sp,32
    80003754:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003756:	415c                	lw	a5,4(a0)
    80003758:	0047d79b          	srliw	a5,a5,0x4
    8000375c:	0001e597          	auipc	a1,0x1e
    80003760:	6c45a583          	lw	a1,1732(a1) # 80021e20 <sb+0x18>
    80003764:	9dbd                	addw	a1,a1,a5
    80003766:	4108                	lw	a0,0(a0)
    80003768:	9bfff0ef          	jal	80003126 <bread>
    8000376c:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    8000376e:	05850793          	addi	a5,a0,88
    80003772:	40d8                	lw	a4,4(s1)
    80003774:	8b3d                	andi	a4,a4,15
    80003776:	071a                	slli	a4,a4,0x6
    80003778:	97ba                	add	a5,a5,a4
  dip->type = ip->type;
    8000377a:	04449703          	lh	a4,68(s1)
    8000377e:	00e79023          	sh	a4,0(a5)
  dip->major = ip->major;
    80003782:	04649703          	lh	a4,70(s1)
    80003786:	00e79123          	sh	a4,2(a5)
  dip->minor = ip->minor;
    8000378a:	04849703          	lh	a4,72(s1)
    8000378e:	00e79223          	sh	a4,4(a5)
  dip->nlink = ip->nlink;
    80003792:	04a49703          	lh	a4,74(s1)
    80003796:	00e79323          	sh	a4,6(a5)
  dip->size = ip->size;
    8000379a:	44f8                	lw	a4,76(s1)
    8000379c:	c798                	sw	a4,8(a5)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    8000379e:	03400613          	li	a2,52
    800037a2:	05048593          	addi	a1,s1,80
    800037a6:	00c78513          	addi	a0,a5,12
    800037aa:	e9cfd0ef          	jal	80000e46 <memmove>
  log_write(bp);
    800037ae:	854a                	mv	a0,s2
    800037b0:	3f3000ef          	jal	800043a2 <log_write>
  brelse(bp);
    800037b4:	854a                	mv	a0,s2
    800037b6:	aa1ff0ef          	jal	80003256 <brelse>
}
    800037ba:	60e2                	ld	ra,24(sp)
    800037bc:	6442                	ld	s0,16(sp)
    800037be:	64a2                	ld	s1,8(sp)
    800037c0:	6902                	ld	s2,0(sp)
    800037c2:	6105                	addi	sp,sp,32
    800037c4:	8082                	ret

00000000800037c6 <idup>:
{
    800037c6:	1101                	addi	sp,sp,-32
    800037c8:	ec06                	sd	ra,24(sp)
    800037ca:	e822                	sd	s0,16(sp)
    800037cc:	e426                	sd	s1,8(sp)
    800037ce:	1000                	addi	s0,sp,32
    800037d0:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    800037d2:	0001e517          	auipc	a0,0x1e
    800037d6:	65650513          	addi	a0,a0,1622 # 80021e28 <itable>
    800037da:	d3cfd0ef          	jal	80000d16 <acquire>
  ip->ref++;
    800037de:	449c                	lw	a5,8(s1)
    800037e0:	2785                	addiw	a5,a5,1
    800037e2:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    800037e4:	0001e517          	auipc	a0,0x1e
    800037e8:	64450513          	addi	a0,a0,1604 # 80021e28 <itable>
    800037ec:	dbefd0ef          	jal	80000daa <release>
}
    800037f0:	8526                	mv	a0,s1
    800037f2:	60e2                	ld	ra,24(sp)
    800037f4:	6442                	ld	s0,16(sp)
    800037f6:	64a2                	ld	s1,8(sp)
    800037f8:	6105                	addi	sp,sp,32
    800037fa:	8082                	ret

00000000800037fc <ilock>:
{
    800037fc:	1101                	addi	sp,sp,-32
    800037fe:	ec06                	sd	ra,24(sp)
    80003800:	e822                	sd	s0,16(sp)
    80003802:	e426                	sd	s1,8(sp)
    80003804:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    80003806:	cd19                	beqz	a0,80003824 <ilock+0x28>
    80003808:	84aa                	mv	s1,a0
    8000380a:	451c                	lw	a5,8(a0)
    8000380c:	00f05c63          	blez	a5,80003824 <ilock+0x28>
  acquiresleep(&ip->lock);
    80003810:	0541                	addi	a0,a0,16
    80003812:	48b000ef          	jal	8000449c <acquiresleep>
  if(ip->valid == 0){
    80003816:	40bc                	lw	a5,64(s1)
    80003818:	cf89                	beqz	a5,80003832 <ilock+0x36>
}
    8000381a:	60e2                	ld	ra,24(sp)
    8000381c:	6442                	ld	s0,16(sp)
    8000381e:	64a2                	ld	s1,8(sp)
    80003820:	6105                	addi	sp,sp,32
    80003822:	8082                	ret
    80003824:	e04a                	sd	s2,0(sp)
    panic("ilock");
    80003826:	00005517          	auipc	a0,0x5
    8000382a:	c5a50513          	addi	a0,a0,-934 # 80008480 <etext+0x480>
    8000382e:	828fd0ef          	jal	80000856 <panic>
    80003832:	e04a                	sd	s2,0(sp)
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003834:	40dc                	lw	a5,4(s1)
    80003836:	0047d79b          	srliw	a5,a5,0x4
    8000383a:	0001e597          	auipc	a1,0x1e
    8000383e:	5e65a583          	lw	a1,1510(a1) # 80021e20 <sb+0x18>
    80003842:	9dbd                	addw	a1,a1,a5
    80003844:	4088                	lw	a0,0(s1)
    80003846:	8e1ff0ef          	jal	80003126 <bread>
    8000384a:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    8000384c:	05850593          	addi	a1,a0,88
    80003850:	40dc                	lw	a5,4(s1)
    80003852:	8bbd                	andi	a5,a5,15
    80003854:	079a                	slli	a5,a5,0x6
    80003856:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    80003858:	00059783          	lh	a5,0(a1)
    8000385c:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    80003860:	00259783          	lh	a5,2(a1)
    80003864:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    80003868:	00459783          	lh	a5,4(a1)
    8000386c:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80003870:	00659783          	lh	a5,6(a1)
    80003874:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    80003878:	459c                	lw	a5,8(a1)
    8000387a:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    8000387c:	03400613          	li	a2,52
    80003880:	05b1                	addi	a1,a1,12
    80003882:	05048513          	addi	a0,s1,80
    80003886:	dc0fd0ef          	jal	80000e46 <memmove>
    brelse(bp);
    8000388a:	854a                	mv	a0,s2
    8000388c:	9cbff0ef          	jal	80003256 <brelse>
    ip->valid = 1;
    80003890:	4785                	li	a5,1
    80003892:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    80003894:	04449783          	lh	a5,68(s1)
    80003898:	c399                	beqz	a5,8000389e <ilock+0xa2>
    8000389a:	6902                	ld	s2,0(sp)
    8000389c:	bfbd                	j	8000381a <ilock+0x1e>
      panic("ilock: no type");
    8000389e:	00005517          	auipc	a0,0x5
    800038a2:	bea50513          	addi	a0,a0,-1046 # 80008488 <etext+0x488>
    800038a6:	fb1fc0ef          	jal	80000856 <panic>

00000000800038aa <iunlock>:
{
    800038aa:	1101                	addi	sp,sp,-32
    800038ac:	ec06                	sd	ra,24(sp)
    800038ae:	e822                	sd	s0,16(sp)
    800038b0:	e426                	sd	s1,8(sp)
    800038b2:	e04a                	sd	s2,0(sp)
    800038b4:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    800038b6:	c505                	beqz	a0,800038de <iunlock+0x34>
    800038b8:	84aa                	mv	s1,a0
    800038ba:	01050913          	addi	s2,a0,16
    800038be:	854a                	mv	a0,s2
    800038c0:	45b000ef          	jal	8000451a <holdingsleep>
    800038c4:	cd09                	beqz	a0,800038de <iunlock+0x34>
    800038c6:	449c                	lw	a5,8(s1)
    800038c8:	00f05b63          	blez	a5,800038de <iunlock+0x34>
  releasesleep(&ip->lock);
    800038cc:	854a                	mv	a0,s2
    800038ce:	415000ef          	jal	800044e2 <releasesleep>
}
    800038d2:	60e2                	ld	ra,24(sp)
    800038d4:	6442                	ld	s0,16(sp)
    800038d6:	64a2                	ld	s1,8(sp)
    800038d8:	6902                	ld	s2,0(sp)
    800038da:	6105                	addi	sp,sp,32
    800038dc:	8082                	ret
    panic("iunlock");
    800038de:	00005517          	auipc	a0,0x5
    800038e2:	bba50513          	addi	a0,a0,-1094 # 80008498 <etext+0x498>
    800038e6:	f71fc0ef          	jal	80000856 <panic>

00000000800038ea <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    800038ea:	7179                	addi	sp,sp,-48
    800038ec:	f406                	sd	ra,40(sp)
    800038ee:	f022                	sd	s0,32(sp)
    800038f0:	ec26                	sd	s1,24(sp)
    800038f2:	e84a                	sd	s2,16(sp)
    800038f4:	e44e                	sd	s3,8(sp)
    800038f6:	1800                	addi	s0,sp,48
    800038f8:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    800038fa:	05050493          	addi	s1,a0,80
    800038fe:	08050913          	addi	s2,a0,128
    80003902:	a021                	j	8000390a <itrunc+0x20>
    80003904:	0491                	addi	s1,s1,4
    80003906:	01248b63          	beq	s1,s2,8000391c <itrunc+0x32>
    if(ip->addrs[i]){
    8000390a:	408c                	lw	a1,0(s1)
    8000390c:	dde5                	beqz	a1,80003904 <itrunc+0x1a>
      bfree(ip->dev, ip->addrs[i]);
    8000390e:	0009a503          	lw	a0,0(s3)
    80003912:	a47ff0ef          	jal	80003358 <bfree>
      ip->addrs[i] = 0;
    80003916:	0004a023          	sw	zero,0(s1)
    8000391a:	b7ed                	j	80003904 <itrunc+0x1a>
    }
  }

  if(ip->addrs[NDIRECT]){
    8000391c:	0809a583          	lw	a1,128(s3)
    80003920:	ed89                	bnez	a1,8000393a <itrunc+0x50>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80003922:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    80003926:	854e                	mv	a0,s3
    80003928:	e21ff0ef          	jal	80003748 <iupdate>
}
    8000392c:	70a2                	ld	ra,40(sp)
    8000392e:	7402                	ld	s0,32(sp)
    80003930:	64e2                	ld	s1,24(sp)
    80003932:	6942                	ld	s2,16(sp)
    80003934:	69a2                	ld	s3,8(sp)
    80003936:	6145                	addi	sp,sp,48
    80003938:	8082                	ret
    8000393a:	e052                	sd	s4,0(sp)
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    8000393c:	0009a503          	lw	a0,0(s3)
    80003940:	fe6ff0ef          	jal	80003126 <bread>
    80003944:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    80003946:	05850493          	addi	s1,a0,88
    8000394a:	45850913          	addi	s2,a0,1112
    8000394e:	a021                	j	80003956 <itrunc+0x6c>
    80003950:	0491                	addi	s1,s1,4
    80003952:	01248963          	beq	s1,s2,80003964 <itrunc+0x7a>
      if(a[j])
    80003956:	408c                	lw	a1,0(s1)
    80003958:	dde5                	beqz	a1,80003950 <itrunc+0x66>
        bfree(ip->dev, a[j]);
    8000395a:	0009a503          	lw	a0,0(s3)
    8000395e:	9fbff0ef          	jal	80003358 <bfree>
    80003962:	b7fd                	j	80003950 <itrunc+0x66>
    brelse(bp);
    80003964:	8552                	mv	a0,s4
    80003966:	8f1ff0ef          	jal	80003256 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    8000396a:	0809a583          	lw	a1,128(s3)
    8000396e:	0009a503          	lw	a0,0(s3)
    80003972:	9e7ff0ef          	jal	80003358 <bfree>
    ip->addrs[NDIRECT] = 0;
    80003976:	0809a023          	sw	zero,128(s3)
    8000397a:	6a02                	ld	s4,0(sp)
    8000397c:	b75d                	j	80003922 <itrunc+0x38>

000000008000397e <iput>:
{
    8000397e:	1101                	addi	sp,sp,-32
    80003980:	ec06                	sd	ra,24(sp)
    80003982:	e822                	sd	s0,16(sp)
    80003984:	e426                	sd	s1,8(sp)
    80003986:	1000                	addi	s0,sp,32
    80003988:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    8000398a:	0001e517          	auipc	a0,0x1e
    8000398e:	49e50513          	addi	a0,a0,1182 # 80021e28 <itable>
    80003992:	b84fd0ef          	jal	80000d16 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003996:	4498                	lw	a4,8(s1)
    80003998:	4785                	li	a5,1
    8000399a:	02f70063          	beq	a4,a5,800039ba <iput+0x3c>
  ip->ref--;
    8000399e:	449c                	lw	a5,8(s1)
    800039a0:	37fd                	addiw	a5,a5,-1
    800039a2:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    800039a4:	0001e517          	auipc	a0,0x1e
    800039a8:	48450513          	addi	a0,a0,1156 # 80021e28 <itable>
    800039ac:	bfefd0ef          	jal	80000daa <release>
}
    800039b0:	60e2                	ld	ra,24(sp)
    800039b2:	6442                	ld	s0,16(sp)
    800039b4:	64a2                	ld	s1,8(sp)
    800039b6:	6105                	addi	sp,sp,32
    800039b8:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    800039ba:	40bc                	lw	a5,64(s1)
    800039bc:	d3ed                	beqz	a5,8000399e <iput+0x20>
    800039be:	04a49783          	lh	a5,74(s1)
    800039c2:	fff1                	bnez	a5,8000399e <iput+0x20>
    800039c4:	e04a                	sd	s2,0(sp)
    acquiresleep(&ip->lock);
    800039c6:	01048793          	addi	a5,s1,16
    800039ca:	893e                	mv	s2,a5
    800039cc:	853e                	mv	a0,a5
    800039ce:	2cf000ef          	jal	8000449c <acquiresleep>
    release(&itable.lock);
    800039d2:	0001e517          	auipc	a0,0x1e
    800039d6:	45650513          	addi	a0,a0,1110 # 80021e28 <itable>
    800039da:	bd0fd0ef          	jal	80000daa <release>
    itrunc(ip);
    800039de:	8526                	mv	a0,s1
    800039e0:	f0bff0ef          	jal	800038ea <itrunc>
    ip->type = 0;
    800039e4:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    800039e8:	8526                	mv	a0,s1
    800039ea:	d5fff0ef          	jal	80003748 <iupdate>
    ip->valid = 0;
    800039ee:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    800039f2:	854a                	mv	a0,s2
    800039f4:	2ef000ef          	jal	800044e2 <releasesleep>
    acquire(&itable.lock);
    800039f8:	0001e517          	auipc	a0,0x1e
    800039fc:	43050513          	addi	a0,a0,1072 # 80021e28 <itable>
    80003a00:	b16fd0ef          	jal	80000d16 <acquire>
    80003a04:	6902                	ld	s2,0(sp)
    80003a06:	bf61                	j	8000399e <iput+0x20>

0000000080003a08 <iunlockput>:
{
    80003a08:	1101                	addi	sp,sp,-32
    80003a0a:	ec06                	sd	ra,24(sp)
    80003a0c:	e822                	sd	s0,16(sp)
    80003a0e:	e426                	sd	s1,8(sp)
    80003a10:	1000                	addi	s0,sp,32
    80003a12:	84aa                	mv	s1,a0
  iunlock(ip);
    80003a14:	e97ff0ef          	jal	800038aa <iunlock>
  iput(ip);
    80003a18:	8526                	mv	a0,s1
    80003a1a:	f65ff0ef          	jal	8000397e <iput>
}
    80003a1e:	60e2                	ld	ra,24(sp)
    80003a20:	6442                	ld	s0,16(sp)
    80003a22:	64a2                	ld	s1,8(sp)
    80003a24:	6105                	addi	sp,sp,32
    80003a26:	8082                	ret

0000000080003a28 <ireclaim>:
  for (int inum = 1; inum < sb.ninodes; inum++) {
    80003a28:	0001e717          	auipc	a4,0x1e
    80003a2c:	3ec72703          	lw	a4,1004(a4) # 80021e14 <sb+0xc>
    80003a30:	4785                	li	a5,1
    80003a32:	0ae7fe63          	bgeu	a5,a4,80003aee <ireclaim+0xc6>
{
    80003a36:	7139                	addi	sp,sp,-64
    80003a38:	fc06                	sd	ra,56(sp)
    80003a3a:	f822                	sd	s0,48(sp)
    80003a3c:	f426                	sd	s1,40(sp)
    80003a3e:	f04a                	sd	s2,32(sp)
    80003a40:	ec4e                	sd	s3,24(sp)
    80003a42:	e852                	sd	s4,16(sp)
    80003a44:	e456                	sd	s5,8(sp)
    80003a46:	e05a                	sd	s6,0(sp)
    80003a48:	0080                	addi	s0,sp,64
    80003a4a:	8aaa                	mv	s5,a0
  for (int inum = 1; inum < sb.ninodes; inum++) {
    80003a4c:	84be                	mv	s1,a5
    struct buf *bp = bread(dev, IBLOCK(inum, sb));
    80003a4e:	0001ea17          	auipc	s4,0x1e
    80003a52:	3baa0a13          	addi	s4,s4,954 # 80021e08 <sb>
      printf("ireclaim: orphaned inode %d\n", inum);
    80003a56:	00005b17          	auipc	s6,0x5
    80003a5a:	a4ab0b13          	addi	s6,s6,-1462 # 800084a0 <etext+0x4a0>
    80003a5e:	a099                	j	80003aa4 <ireclaim+0x7c>
    80003a60:	85ce                	mv	a1,s3
    80003a62:	855a                	mv	a0,s6
    80003a64:	ac9fc0ef          	jal	8000052c <printf>
      ip = iget(dev, inum);
    80003a68:	85ce                	mv	a1,s3
    80003a6a:	8556                	mv	a0,s5
    80003a6c:	b1fff0ef          	jal	8000358a <iget>
    80003a70:	89aa                	mv	s3,a0
    brelse(bp);
    80003a72:	854a                	mv	a0,s2
    80003a74:	fe2ff0ef          	jal	80003256 <brelse>
    if (ip) {
    80003a78:	00098f63          	beqz	s3,80003a96 <ireclaim+0x6e>
      begin_op();
    80003a7c:	78c000ef          	jal	80004208 <begin_op>
      ilock(ip);
    80003a80:	854e                	mv	a0,s3
    80003a82:	d7bff0ef          	jal	800037fc <ilock>
      iunlock(ip);
    80003a86:	854e                	mv	a0,s3
    80003a88:	e23ff0ef          	jal	800038aa <iunlock>
      iput(ip);
    80003a8c:	854e                	mv	a0,s3
    80003a8e:	ef1ff0ef          	jal	8000397e <iput>
      end_op();
    80003a92:	7e6000ef          	jal	80004278 <end_op>
  for (int inum = 1; inum < sb.ninodes; inum++) {
    80003a96:	0485                	addi	s1,s1,1
    80003a98:	00ca2703          	lw	a4,12(s4)
    80003a9c:	0004879b          	sext.w	a5,s1
    80003aa0:	02e7fd63          	bgeu	a5,a4,80003ada <ireclaim+0xb2>
    80003aa4:	0004899b          	sext.w	s3,s1
    struct buf *bp = bread(dev, IBLOCK(inum, sb));
    80003aa8:	0044d593          	srli	a1,s1,0x4
    80003aac:	018a2783          	lw	a5,24(s4)
    80003ab0:	9dbd                	addw	a1,a1,a5
    80003ab2:	8556                	mv	a0,s5
    80003ab4:	e72ff0ef          	jal	80003126 <bread>
    80003ab8:	892a                	mv	s2,a0
    struct dinode *dip = (struct dinode *)bp->data + inum % IPB;
    80003aba:	05850793          	addi	a5,a0,88
    80003abe:	00f9f713          	andi	a4,s3,15
    80003ac2:	071a                	slli	a4,a4,0x6
    80003ac4:	97ba                	add	a5,a5,a4
    if (dip->type != 0 && dip->nlink == 0) {  // is an orphaned inode
    80003ac6:	00079703          	lh	a4,0(a5)
    80003aca:	c701                	beqz	a4,80003ad2 <ireclaim+0xaa>
    80003acc:	00679783          	lh	a5,6(a5)
    80003ad0:	dbc1                	beqz	a5,80003a60 <ireclaim+0x38>
    brelse(bp);
    80003ad2:	854a                	mv	a0,s2
    80003ad4:	f82ff0ef          	jal	80003256 <brelse>
    if (ip) {
    80003ad8:	bf7d                	j	80003a96 <ireclaim+0x6e>
}
    80003ada:	70e2                	ld	ra,56(sp)
    80003adc:	7442                	ld	s0,48(sp)
    80003ade:	74a2                	ld	s1,40(sp)
    80003ae0:	7902                	ld	s2,32(sp)
    80003ae2:	69e2                	ld	s3,24(sp)
    80003ae4:	6a42                	ld	s4,16(sp)
    80003ae6:	6aa2                	ld	s5,8(sp)
    80003ae8:	6b02                	ld	s6,0(sp)
    80003aea:	6121                	addi	sp,sp,64
    80003aec:	8082                	ret
    80003aee:	8082                	ret

0000000080003af0 <fsinit>:
fsinit(int dev) {
    80003af0:	1101                	addi	sp,sp,-32
    80003af2:	ec06                	sd	ra,24(sp)
    80003af4:	e822                	sd	s0,16(sp)
    80003af6:	e426                	sd	s1,8(sp)
    80003af8:	e04a                	sd	s2,0(sp)
    80003afa:	1000                	addi	s0,sp,32
    80003afc:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    80003afe:	4585                	li	a1,1
    80003b00:	e26ff0ef          	jal	80003126 <bread>
    80003b04:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    80003b06:	02000613          	li	a2,32
    80003b0a:	05850593          	addi	a1,a0,88
    80003b0e:	0001e517          	auipc	a0,0x1e
    80003b12:	2fa50513          	addi	a0,a0,762 # 80021e08 <sb>
    80003b16:	b30fd0ef          	jal	80000e46 <memmove>
  brelse(bp);
    80003b1a:	8526                	mv	a0,s1
    80003b1c:	f3aff0ef          	jal	80003256 <brelse>
  if(sb.magic != FSMAGIC)
    80003b20:	0001e717          	auipc	a4,0x1e
    80003b24:	2e872703          	lw	a4,744(a4) # 80021e08 <sb>
    80003b28:	102037b7          	lui	a5,0x10203
    80003b2c:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    80003b30:	02f71263          	bne	a4,a5,80003b54 <fsinit+0x64>
  initlog(dev, &sb);
    80003b34:	0001e597          	auipc	a1,0x1e
    80003b38:	2d458593          	addi	a1,a1,724 # 80021e08 <sb>
    80003b3c:	854a                	mv	a0,s2
    80003b3e:	648000ef          	jal	80004186 <initlog>
  ireclaim(dev);
    80003b42:	854a                	mv	a0,s2
    80003b44:	ee5ff0ef          	jal	80003a28 <ireclaim>
}
    80003b48:	60e2                	ld	ra,24(sp)
    80003b4a:	6442                	ld	s0,16(sp)
    80003b4c:	64a2                	ld	s1,8(sp)
    80003b4e:	6902                	ld	s2,0(sp)
    80003b50:	6105                	addi	sp,sp,32
    80003b52:	8082                	ret
    panic("invalid file system");
    80003b54:	00005517          	auipc	a0,0x5
    80003b58:	96c50513          	addi	a0,a0,-1684 # 800084c0 <etext+0x4c0>
    80003b5c:	cfbfc0ef          	jal	80000856 <panic>

0000000080003b60 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80003b60:	1141                	addi	sp,sp,-16
    80003b62:	e406                	sd	ra,8(sp)
    80003b64:	e022                	sd	s0,0(sp)
    80003b66:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80003b68:	411c                	lw	a5,0(a0)
    80003b6a:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80003b6c:	415c                	lw	a5,4(a0)
    80003b6e:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80003b70:	04451783          	lh	a5,68(a0)
    80003b74:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80003b78:	04a51783          	lh	a5,74(a0)
    80003b7c:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80003b80:	04c56783          	lwu	a5,76(a0)
    80003b84:	e99c                	sd	a5,16(a1)
}
    80003b86:	60a2                	ld	ra,8(sp)
    80003b88:	6402                	ld	s0,0(sp)
    80003b8a:	0141                	addi	sp,sp,16
    80003b8c:	8082                	ret

0000000080003b8e <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003b8e:	457c                	lw	a5,76(a0)
    80003b90:	0ed7e663          	bltu	a5,a3,80003c7c <readi+0xee>
{
    80003b94:	7159                	addi	sp,sp,-112
    80003b96:	f486                	sd	ra,104(sp)
    80003b98:	f0a2                	sd	s0,96(sp)
    80003b9a:	eca6                	sd	s1,88(sp)
    80003b9c:	e0d2                	sd	s4,64(sp)
    80003b9e:	fc56                	sd	s5,56(sp)
    80003ba0:	f85a                	sd	s6,48(sp)
    80003ba2:	f45e                	sd	s7,40(sp)
    80003ba4:	1880                	addi	s0,sp,112
    80003ba6:	8b2a                	mv	s6,a0
    80003ba8:	8bae                	mv	s7,a1
    80003baa:	8a32                	mv	s4,a2
    80003bac:	84b6                	mv	s1,a3
    80003bae:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    80003bb0:	9f35                	addw	a4,a4,a3
    return 0;
    80003bb2:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80003bb4:	0ad76b63          	bltu	a4,a3,80003c6a <readi+0xdc>
    80003bb8:	e4ce                	sd	s3,72(sp)
  if(off + n > ip->size)
    80003bba:	00e7f463          	bgeu	a5,a4,80003bc2 <readi+0x34>
    n = ip->size - off;
    80003bbe:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003bc2:	080a8b63          	beqz	s5,80003c58 <readi+0xca>
    80003bc6:	e8ca                	sd	s2,80(sp)
    80003bc8:	f062                	sd	s8,32(sp)
    80003bca:	ec66                	sd	s9,24(sp)
    80003bcc:	e86a                	sd	s10,16(sp)
    80003bce:	e46e                	sd	s11,8(sp)
    80003bd0:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003bd2:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80003bd6:	5c7d                	li	s8,-1
    80003bd8:	a80d                	j	80003c0a <readi+0x7c>
    80003bda:	020d1d93          	slli	s11,s10,0x20
    80003bde:	020ddd93          	srli	s11,s11,0x20
    80003be2:	05890613          	addi	a2,s2,88
    80003be6:	86ee                	mv	a3,s11
    80003be8:	963e                	add	a2,a2,a5
    80003bea:	85d2                	mv	a1,s4
    80003bec:	855e                	mv	a0,s7
    80003bee:	bc1fe0ef          	jal	800027ae <either_copyout>
    80003bf2:	05850363          	beq	a0,s8,80003c38 <readi+0xaa>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80003bf6:	854a                	mv	a0,s2
    80003bf8:	e5eff0ef          	jal	80003256 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003bfc:	013d09bb          	addw	s3,s10,s3
    80003c00:	009d04bb          	addw	s1,s10,s1
    80003c04:	9a6e                	add	s4,s4,s11
    80003c06:	0559f363          	bgeu	s3,s5,80003c4c <readi+0xbe>
    uint addr = bmap(ip, off/BSIZE);
    80003c0a:	00a4d59b          	srliw	a1,s1,0xa
    80003c0e:	855a                	mv	a0,s6
    80003c10:	8bbff0ef          	jal	800034ca <bmap>
    80003c14:	85aa                	mv	a1,a0
    if(addr == 0)
    80003c16:	c139                	beqz	a0,80003c5c <readi+0xce>
    bp = bread(ip->dev, addr);
    80003c18:	000b2503          	lw	a0,0(s6)
    80003c1c:	d0aff0ef          	jal	80003126 <bread>
    80003c20:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003c22:	3ff4f793          	andi	a5,s1,1023
    80003c26:	40fc873b          	subw	a4,s9,a5
    80003c2a:	413a86bb          	subw	a3,s5,s3
    80003c2e:	8d3a                	mv	s10,a4
    80003c30:	fae6f5e3          	bgeu	a3,a4,80003bda <readi+0x4c>
    80003c34:	8d36                	mv	s10,a3
    80003c36:	b755                	j	80003bda <readi+0x4c>
      brelse(bp);
    80003c38:	854a                	mv	a0,s2
    80003c3a:	e1cff0ef          	jal	80003256 <brelse>
      tot = -1;
    80003c3e:	59fd                	li	s3,-1
      break;
    80003c40:	6946                	ld	s2,80(sp)
    80003c42:	7c02                	ld	s8,32(sp)
    80003c44:	6ce2                	ld	s9,24(sp)
    80003c46:	6d42                	ld	s10,16(sp)
    80003c48:	6da2                	ld	s11,8(sp)
    80003c4a:	a831                	j	80003c66 <readi+0xd8>
    80003c4c:	6946                	ld	s2,80(sp)
    80003c4e:	7c02                	ld	s8,32(sp)
    80003c50:	6ce2                	ld	s9,24(sp)
    80003c52:	6d42                	ld	s10,16(sp)
    80003c54:	6da2                	ld	s11,8(sp)
    80003c56:	a801                	j	80003c66 <readi+0xd8>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003c58:	89d6                	mv	s3,s5
    80003c5a:	a031                	j	80003c66 <readi+0xd8>
    80003c5c:	6946                	ld	s2,80(sp)
    80003c5e:	7c02                	ld	s8,32(sp)
    80003c60:	6ce2                	ld	s9,24(sp)
    80003c62:	6d42                	ld	s10,16(sp)
    80003c64:	6da2                	ld	s11,8(sp)
  }
  return tot;
    80003c66:	854e                	mv	a0,s3
    80003c68:	69a6                	ld	s3,72(sp)
}
    80003c6a:	70a6                	ld	ra,104(sp)
    80003c6c:	7406                	ld	s0,96(sp)
    80003c6e:	64e6                	ld	s1,88(sp)
    80003c70:	6a06                	ld	s4,64(sp)
    80003c72:	7ae2                	ld	s5,56(sp)
    80003c74:	7b42                	ld	s6,48(sp)
    80003c76:	7ba2                	ld	s7,40(sp)
    80003c78:	6165                	addi	sp,sp,112
    80003c7a:	8082                	ret
    return 0;
    80003c7c:	4501                	li	a0,0
}
    80003c7e:	8082                	ret

0000000080003c80 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003c80:	457c                	lw	a5,76(a0)
    80003c82:	0ed7eb63          	bltu	a5,a3,80003d78 <writei+0xf8>
{
    80003c86:	7159                	addi	sp,sp,-112
    80003c88:	f486                	sd	ra,104(sp)
    80003c8a:	f0a2                	sd	s0,96(sp)
    80003c8c:	e8ca                	sd	s2,80(sp)
    80003c8e:	e0d2                	sd	s4,64(sp)
    80003c90:	fc56                	sd	s5,56(sp)
    80003c92:	f85a                	sd	s6,48(sp)
    80003c94:	f45e                	sd	s7,40(sp)
    80003c96:	1880                	addi	s0,sp,112
    80003c98:	8aaa                	mv	s5,a0
    80003c9a:	8bae                	mv	s7,a1
    80003c9c:	8a32                	mv	s4,a2
    80003c9e:	8936                	mv	s2,a3
    80003ca0:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003ca2:	00e687bb          	addw	a5,a3,a4
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80003ca6:	00043737          	lui	a4,0x43
    80003caa:	0cf76963          	bltu	a4,a5,80003d7c <writei+0xfc>
    80003cae:	0cd7e763          	bltu	a5,a3,80003d7c <writei+0xfc>
    80003cb2:	e4ce                	sd	s3,72(sp)
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003cb4:	0a0b0a63          	beqz	s6,80003d68 <writei+0xe8>
    80003cb8:	eca6                	sd	s1,88(sp)
    80003cba:	f062                	sd	s8,32(sp)
    80003cbc:	ec66                	sd	s9,24(sp)
    80003cbe:	e86a                	sd	s10,16(sp)
    80003cc0:	e46e                	sd	s11,8(sp)
    80003cc2:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003cc4:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80003cc8:	5c7d                	li	s8,-1
    80003cca:	a825                	j	80003d02 <writei+0x82>
    80003ccc:	020d1d93          	slli	s11,s10,0x20
    80003cd0:	020ddd93          	srli	s11,s11,0x20
    80003cd4:	05848513          	addi	a0,s1,88
    80003cd8:	86ee                	mv	a3,s11
    80003cda:	8652                	mv	a2,s4
    80003cdc:	85de                	mv	a1,s7
    80003cde:	953e                	add	a0,a0,a5
    80003ce0:	b19fe0ef          	jal	800027f8 <either_copyin>
    80003ce4:	05850663          	beq	a0,s8,80003d30 <writei+0xb0>
      brelse(bp);
      break;
    }
    log_write(bp);
    80003ce8:	8526                	mv	a0,s1
    80003cea:	6b8000ef          	jal	800043a2 <log_write>
    brelse(bp);
    80003cee:	8526                	mv	a0,s1
    80003cf0:	d66ff0ef          	jal	80003256 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003cf4:	013d09bb          	addw	s3,s10,s3
    80003cf8:	012d093b          	addw	s2,s10,s2
    80003cfc:	9a6e                	add	s4,s4,s11
    80003cfe:	0369fc63          	bgeu	s3,s6,80003d36 <writei+0xb6>
    uint addr = bmap(ip, off/BSIZE);
    80003d02:	00a9559b          	srliw	a1,s2,0xa
    80003d06:	8556                	mv	a0,s5
    80003d08:	fc2ff0ef          	jal	800034ca <bmap>
    80003d0c:	85aa                	mv	a1,a0
    if(addr == 0)
    80003d0e:	c505                	beqz	a0,80003d36 <writei+0xb6>
    bp = bread(ip->dev, addr);
    80003d10:	000aa503          	lw	a0,0(s5)
    80003d14:	c12ff0ef          	jal	80003126 <bread>
    80003d18:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003d1a:	3ff97793          	andi	a5,s2,1023
    80003d1e:	40fc873b          	subw	a4,s9,a5
    80003d22:	413b06bb          	subw	a3,s6,s3
    80003d26:	8d3a                	mv	s10,a4
    80003d28:	fae6f2e3          	bgeu	a3,a4,80003ccc <writei+0x4c>
    80003d2c:	8d36                	mv	s10,a3
    80003d2e:	bf79                	j	80003ccc <writei+0x4c>
      brelse(bp);
    80003d30:	8526                	mv	a0,s1
    80003d32:	d24ff0ef          	jal	80003256 <brelse>
  }

  if(off > ip->size)
    80003d36:	04caa783          	lw	a5,76(s5)
    80003d3a:	0327f963          	bgeu	a5,s2,80003d6c <writei+0xec>
    ip->size = off;
    80003d3e:	052aa623          	sw	s2,76(s5)
    80003d42:	64e6                	ld	s1,88(sp)
    80003d44:	7c02                	ld	s8,32(sp)
    80003d46:	6ce2                	ld	s9,24(sp)
    80003d48:	6d42                	ld	s10,16(sp)
    80003d4a:	6da2                	ld	s11,8(sp)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80003d4c:	8556                	mv	a0,s5
    80003d4e:	9fbff0ef          	jal	80003748 <iupdate>

  return tot;
    80003d52:	854e                	mv	a0,s3
    80003d54:	69a6                	ld	s3,72(sp)
}
    80003d56:	70a6                	ld	ra,104(sp)
    80003d58:	7406                	ld	s0,96(sp)
    80003d5a:	6946                	ld	s2,80(sp)
    80003d5c:	6a06                	ld	s4,64(sp)
    80003d5e:	7ae2                	ld	s5,56(sp)
    80003d60:	7b42                	ld	s6,48(sp)
    80003d62:	7ba2                	ld	s7,40(sp)
    80003d64:	6165                	addi	sp,sp,112
    80003d66:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003d68:	89da                	mv	s3,s6
    80003d6a:	b7cd                	j	80003d4c <writei+0xcc>
    80003d6c:	64e6                	ld	s1,88(sp)
    80003d6e:	7c02                	ld	s8,32(sp)
    80003d70:	6ce2                	ld	s9,24(sp)
    80003d72:	6d42                	ld	s10,16(sp)
    80003d74:	6da2                	ld	s11,8(sp)
    80003d76:	bfd9                	j	80003d4c <writei+0xcc>
    return -1;
    80003d78:	557d                	li	a0,-1
}
    80003d7a:	8082                	ret
    return -1;
    80003d7c:	557d                	li	a0,-1
    80003d7e:	bfe1                	j	80003d56 <writei+0xd6>

0000000080003d80 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80003d80:	1141                	addi	sp,sp,-16
    80003d82:	e406                	sd	ra,8(sp)
    80003d84:	e022                	sd	s0,0(sp)
    80003d86:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80003d88:	4639                	li	a2,14
    80003d8a:	930fd0ef          	jal	80000eba <strncmp>
}
    80003d8e:	60a2                	ld	ra,8(sp)
    80003d90:	6402                	ld	s0,0(sp)
    80003d92:	0141                	addi	sp,sp,16
    80003d94:	8082                	ret

0000000080003d96 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80003d96:	711d                	addi	sp,sp,-96
    80003d98:	ec86                	sd	ra,88(sp)
    80003d9a:	e8a2                	sd	s0,80(sp)
    80003d9c:	e4a6                	sd	s1,72(sp)
    80003d9e:	e0ca                	sd	s2,64(sp)
    80003da0:	fc4e                	sd	s3,56(sp)
    80003da2:	f852                	sd	s4,48(sp)
    80003da4:	f456                	sd	s5,40(sp)
    80003da6:	f05a                	sd	s6,32(sp)
    80003da8:	ec5e                	sd	s7,24(sp)
    80003daa:	1080                	addi	s0,sp,96
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80003dac:	04451703          	lh	a4,68(a0)
    80003db0:	4785                	li	a5,1
    80003db2:	00f71f63          	bne	a4,a5,80003dd0 <dirlookup+0x3a>
    80003db6:	892a                	mv	s2,a0
    80003db8:	8aae                	mv	s5,a1
    80003dba:	8bb2                	mv	s7,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80003dbc:	457c                	lw	a5,76(a0)
    80003dbe:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003dc0:	fa040a13          	addi	s4,s0,-96
    80003dc4:	49c1                	li	s3,16
      panic("dirlookup read");
    if(de.inum == 0)
      continue;
    if(namecmp(name, de.name) == 0){
    80003dc6:	fa240b13          	addi	s6,s0,-94
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80003dca:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003dcc:	e39d                	bnez	a5,80003df2 <dirlookup+0x5c>
    80003dce:	a8b9                	j	80003e2c <dirlookup+0x96>
    panic("dirlookup not DIR");
    80003dd0:	00004517          	auipc	a0,0x4
    80003dd4:	70850513          	addi	a0,a0,1800 # 800084d8 <etext+0x4d8>
    80003dd8:	a7ffc0ef          	jal	80000856 <panic>
      panic("dirlookup read");
    80003ddc:	00004517          	auipc	a0,0x4
    80003de0:	71450513          	addi	a0,a0,1812 # 800084f0 <etext+0x4f0>
    80003de4:	a73fc0ef          	jal	80000856 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003de8:	24c1                	addiw	s1,s1,16
    80003dea:	04c92783          	lw	a5,76(s2)
    80003dee:	02f4fe63          	bgeu	s1,a5,80003e2a <dirlookup+0x94>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003df2:	874e                	mv	a4,s3
    80003df4:	86a6                	mv	a3,s1
    80003df6:	8652                	mv	a2,s4
    80003df8:	4581                	li	a1,0
    80003dfa:	854a                	mv	a0,s2
    80003dfc:	d93ff0ef          	jal	80003b8e <readi>
    80003e00:	fd351ee3          	bne	a0,s3,80003ddc <dirlookup+0x46>
    if(de.inum == 0)
    80003e04:	fa045783          	lhu	a5,-96(s0)
    80003e08:	d3e5                	beqz	a5,80003de8 <dirlookup+0x52>
    if(namecmp(name, de.name) == 0){
    80003e0a:	85da                	mv	a1,s6
    80003e0c:	8556                	mv	a0,s5
    80003e0e:	f73ff0ef          	jal	80003d80 <namecmp>
    80003e12:	f979                	bnez	a0,80003de8 <dirlookup+0x52>
      if(poff)
    80003e14:	000b8463          	beqz	s7,80003e1c <dirlookup+0x86>
        *poff = off;
    80003e18:	009ba023          	sw	s1,0(s7)
      return iget(dp->dev, inum);
    80003e1c:	fa045583          	lhu	a1,-96(s0)
    80003e20:	00092503          	lw	a0,0(s2)
    80003e24:	f66ff0ef          	jal	8000358a <iget>
    80003e28:	a011                	j	80003e2c <dirlookup+0x96>
  return 0;
    80003e2a:	4501                	li	a0,0
}
    80003e2c:	60e6                	ld	ra,88(sp)
    80003e2e:	6446                	ld	s0,80(sp)
    80003e30:	64a6                	ld	s1,72(sp)
    80003e32:	6906                	ld	s2,64(sp)
    80003e34:	79e2                	ld	s3,56(sp)
    80003e36:	7a42                	ld	s4,48(sp)
    80003e38:	7aa2                	ld	s5,40(sp)
    80003e3a:	7b02                	ld	s6,32(sp)
    80003e3c:	6be2                	ld	s7,24(sp)
    80003e3e:	6125                	addi	sp,sp,96
    80003e40:	8082                	ret

0000000080003e42 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80003e42:	711d                	addi	sp,sp,-96
    80003e44:	ec86                	sd	ra,88(sp)
    80003e46:	e8a2                	sd	s0,80(sp)
    80003e48:	e4a6                	sd	s1,72(sp)
    80003e4a:	e0ca                	sd	s2,64(sp)
    80003e4c:	fc4e                	sd	s3,56(sp)
    80003e4e:	f852                	sd	s4,48(sp)
    80003e50:	f456                	sd	s5,40(sp)
    80003e52:	f05a                	sd	s6,32(sp)
    80003e54:	ec5e                	sd	s7,24(sp)
    80003e56:	e862                	sd	s8,16(sp)
    80003e58:	e466                	sd	s9,8(sp)
    80003e5a:	e06a                	sd	s10,0(sp)
    80003e5c:	1080                	addi	s0,sp,96
    80003e5e:	84aa                	mv	s1,a0
    80003e60:	8b2e                	mv	s6,a1
    80003e62:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    80003e64:	00054703          	lbu	a4,0(a0)
    80003e68:	02f00793          	li	a5,47
    80003e6c:	00f70f63          	beq	a4,a5,80003e8a <namex+0x48>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80003e70:	db9fd0ef          	jal	80001c28 <myproc>
    80003e74:	15053503          	ld	a0,336(a0)
    80003e78:	94fff0ef          	jal	800037c6 <idup>
    80003e7c:	8a2a                	mv	s4,a0
  while(*path == '/')
    80003e7e:	02f00993          	li	s3,47
  if(len >= DIRSIZ)
    80003e82:	4c35                	li	s8,13
    memmove(name, s, DIRSIZ);
    80003e84:	4cb9                	li	s9,14

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80003e86:	4b85                	li	s7,1
    80003e88:	a879                	j	80003f26 <namex+0xe4>
    ip = iget(ROOTDEV, ROOTINO);
    80003e8a:	4585                	li	a1,1
    80003e8c:	852e                	mv	a0,a1
    80003e8e:	efcff0ef          	jal	8000358a <iget>
    80003e92:	8a2a                	mv	s4,a0
    80003e94:	b7ed                	j	80003e7e <namex+0x3c>
      iunlockput(ip);
    80003e96:	8552                	mv	a0,s4
    80003e98:	b71ff0ef          	jal	80003a08 <iunlockput>
      return 0;
    80003e9c:	4a01                	li	s4,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80003e9e:	8552                	mv	a0,s4
    80003ea0:	60e6                	ld	ra,88(sp)
    80003ea2:	6446                	ld	s0,80(sp)
    80003ea4:	64a6                	ld	s1,72(sp)
    80003ea6:	6906                	ld	s2,64(sp)
    80003ea8:	79e2                	ld	s3,56(sp)
    80003eaa:	7a42                	ld	s4,48(sp)
    80003eac:	7aa2                	ld	s5,40(sp)
    80003eae:	7b02                	ld	s6,32(sp)
    80003eb0:	6be2                	ld	s7,24(sp)
    80003eb2:	6c42                	ld	s8,16(sp)
    80003eb4:	6ca2                	ld	s9,8(sp)
    80003eb6:	6d02                	ld	s10,0(sp)
    80003eb8:	6125                	addi	sp,sp,96
    80003eba:	8082                	ret
      iunlock(ip);
    80003ebc:	8552                	mv	a0,s4
    80003ebe:	9edff0ef          	jal	800038aa <iunlock>
      return ip;
    80003ec2:	bff1                	j	80003e9e <namex+0x5c>
      iunlockput(ip);
    80003ec4:	8552                	mv	a0,s4
    80003ec6:	b43ff0ef          	jal	80003a08 <iunlockput>
      return 0;
    80003eca:	8a4a                	mv	s4,s2
    80003ecc:	bfc9                	j	80003e9e <namex+0x5c>
  len = path - s;
    80003ece:	40990633          	sub	a2,s2,s1
    80003ed2:	00060d1b          	sext.w	s10,a2
  if(len >= DIRSIZ)
    80003ed6:	09ac5463          	bge	s8,s10,80003f5e <namex+0x11c>
    memmove(name, s, DIRSIZ);
    80003eda:	8666                	mv	a2,s9
    80003edc:	85a6                	mv	a1,s1
    80003ede:	8556                	mv	a0,s5
    80003ee0:	f67fc0ef          	jal	80000e46 <memmove>
    80003ee4:	84ca                	mv	s1,s2
  while(*path == '/')
    80003ee6:	0004c783          	lbu	a5,0(s1)
    80003eea:	01379763          	bne	a5,s3,80003ef8 <namex+0xb6>
    path++;
    80003eee:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003ef0:	0004c783          	lbu	a5,0(s1)
    80003ef4:	ff378de3          	beq	a5,s3,80003eee <namex+0xac>
    ilock(ip);
    80003ef8:	8552                	mv	a0,s4
    80003efa:	903ff0ef          	jal	800037fc <ilock>
    if(ip->type != T_DIR){
    80003efe:	044a1783          	lh	a5,68(s4)
    80003f02:	f9779ae3          	bne	a5,s7,80003e96 <namex+0x54>
    if(nameiparent && *path == '\0'){
    80003f06:	000b0563          	beqz	s6,80003f10 <namex+0xce>
    80003f0a:	0004c783          	lbu	a5,0(s1)
    80003f0e:	d7dd                	beqz	a5,80003ebc <namex+0x7a>
    if((next = dirlookup(ip, name, 0)) == 0){
    80003f10:	4601                	li	a2,0
    80003f12:	85d6                	mv	a1,s5
    80003f14:	8552                	mv	a0,s4
    80003f16:	e81ff0ef          	jal	80003d96 <dirlookup>
    80003f1a:	892a                	mv	s2,a0
    80003f1c:	d545                	beqz	a0,80003ec4 <namex+0x82>
    iunlockput(ip);
    80003f1e:	8552                	mv	a0,s4
    80003f20:	ae9ff0ef          	jal	80003a08 <iunlockput>
    ip = next;
    80003f24:	8a4a                	mv	s4,s2
  while(*path == '/')
    80003f26:	0004c783          	lbu	a5,0(s1)
    80003f2a:	01379763          	bne	a5,s3,80003f38 <namex+0xf6>
    path++;
    80003f2e:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003f30:	0004c783          	lbu	a5,0(s1)
    80003f34:	ff378de3          	beq	a5,s3,80003f2e <namex+0xec>
  if(*path == 0)
    80003f38:	cf8d                	beqz	a5,80003f72 <namex+0x130>
  while(*path != '/' && *path != 0)
    80003f3a:	0004c783          	lbu	a5,0(s1)
    80003f3e:	fd178713          	addi	a4,a5,-47
    80003f42:	cb19                	beqz	a4,80003f58 <namex+0x116>
    80003f44:	cb91                	beqz	a5,80003f58 <namex+0x116>
    80003f46:	8926                	mv	s2,s1
    path++;
    80003f48:	0905                	addi	s2,s2,1
  while(*path != '/' && *path != 0)
    80003f4a:	00094783          	lbu	a5,0(s2)
    80003f4e:	fd178713          	addi	a4,a5,-47
    80003f52:	df35                	beqz	a4,80003ece <namex+0x8c>
    80003f54:	fbf5                	bnez	a5,80003f48 <namex+0x106>
    80003f56:	bfa5                	j	80003ece <namex+0x8c>
    80003f58:	8926                	mv	s2,s1
  len = path - s;
    80003f5a:	4d01                	li	s10,0
    80003f5c:	4601                	li	a2,0
    memmove(name, s, len);
    80003f5e:	2601                	sext.w	a2,a2
    80003f60:	85a6                	mv	a1,s1
    80003f62:	8556                	mv	a0,s5
    80003f64:	ee3fc0ef          	jal	80000e46 <memmove>
    name[len] = 0;
    80003f68:	9d56                	add	s10,s10,s5
    80003f6a:	000d0023          	sb	zero,0(s10) # fffffffffffff000 <end+0xffffffff7ffb5448>
    80003f6e:	84ca                	mv	s1,s2
    80003f70:	bf9d                	j	80003ee6 <namex+0xa4>
  if(nameiparent){
    80003f72:	f20b06e3          	beqz	s6,80003e9e <namex+0x5c>
    iput(ip);
    80003f76:	8552                	mv	a0,s4
    80003f78:	a07ff0ef          	jal	8000397e <iput>
    return 0;
    80003f7c:	4a01                	li	s4,0
    80003f7e:	b705                	j	80003e9e <namex+0x5c>

0000000080003f80 <dirlink>:
{
    80003f80:	715d                	addi	sp,sp,-80
    80003f82:	e486                	sd	ra,72(sp)
    80003f84:	e0a2                	sd	s0,64(sp)
    80003f86:	f84a                	sd	s2,48(sp)
    80003f88:	ec56                	sd	s5,24(sp)
    80003f8a:	e85a                	sd	s6,16(sp)
    80003f8c:	0880                	addi	s0,sp,80
    80003f8e:	892a                	mv	s2,a0
    80003f90:	8aae                	mv	s5,a1
    80003f92:	8b32                	mv	s6,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80003f94:	4601                	li	a2,0
    80003f96:	e01ff0ef          	jal	80003d96 <dirlookup>
    80003f9a:	ed1d                	bnez	a0,80003fd8 <dirlink+0x58>
    80003f9c:	fc26                	sd	s1,56(sp)
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003f9e:	04c92483          	lw	s1,76(s2)
    80003fa2:	c4b9                	beqz	s1,80003ff0 <dirlink+0x70>
    80003fa4:	f44e                	sd	s3,40(sp)
    80003fa6:	f052                	sd	s4,32(sp)
    80003fa8:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003faa:	fb040a13          	addi	s4,s0,-80
    80003fae:	49c1                	li	s3,16
    80003fb0:	874e                	mv	a4,s3
    80003fb2:	86a6                	mv	a3,s1
    80003fb4:	8652                	mv	a2,s4
    80003fb6:	4581                	li	a1,0
    80003fb8:	854a                	mv	a0,s2
    80003fba:	bd5ff0ef          	jal	80003b8e <readi>
    80003fbe:	03351163          	bne	a0,s3,80003fe0 <dirlink+0x60>
    if(de.inum == 0)
    80003fc2:	fb045783          	lhu	a5,-80(s0)
    80003fc6:	c39d                	beqz	a5,80003fec <dirlink+0x6c>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003fc8:	24c1                	addiw	s1,s1,16
    80003fca:	04c92783          	lw	a5,76(s2)
    80003fce:	fef4e1e3          	bltu	s1,a5,80003fb0 <dirlink+0x30>
    80003fd2:	79a2                	ld	s3,40(sp)
    80003fd4:	7a02                	ld	s4,32(sp)
    80003fd6:	a829                	j	80003ff0 <dirlink+0x70>
    iput(ip);
    80003fd8:	9a7ff0ef          	jal	8000397e <iput>
    return -1;
    80003fdc:	557d                	li	a0,-1
    80003fde:	a83d                	j	8000401c <dirlink+0x9c>
      panic("dirlink read");
    80003fe0:	00004517          	auipc	a0,0x4
    80003fe4:	52050513          	addi	a0,a0,1312 # 80008500 <etext+0x500>
    80003fe8:	86ffc0ef          	jal	80000856 <panic>
    80003fec:	79a2                	ld	s3,40(sp)
    80003fee:	7a02                	ld	s4,32(sp)
  strncpy(de.name, name, DIRSIZ);
    80003ff0:	4639                	li	a2,14
    80003ff2:	85d6                	mv	a1,s5
    80003ff4:	fb240513          	addi	a0,s0,-78
    80003ff8:	efdfc0ef          	jal	80000ef4 <strncpy>
  de.inum = inum;
    80003ffc:	fb641823          	sh	s6,-80(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004000:	4741                	li	a4,16
    80004002:	86a6                	mv	a3,s1
    80004004:	fb040613          	addi	a2,s0,-80
    80004008:	4581                	li	a1,0
    8000400a:	854a                	mv	a0,s2
    8000400c:	c75ff0ef          	jal	80003c80 <writei>
    80004010:	1541                	addi	a0,a0,-16
    80004012:	00a03533          	snez	a0,a0
    80004016:	40a0053b          	negw	a0,a0
    8000401a:	74e2                	ld	s1,56(sp)
}
    8000401c:	60a6                	ld	ra,72(sp)
    8000401e:	6406                	ld	s0,64(sp)
    80004020:	7942                	ld	s2,48(sp)
    80004022:	6ae2                	ld	s5,24(sp)
    80004024:	6b42                	ld	s6,16(sp)
    80004026:	6161                	addi	sp,sp,80
    80004028:	8082                	ret

000000008000402a <namei>:

struct inode*
namei(char *path)
{
    8000402a:	1101                	addi	sp,sp,-32
    8000402c:	ec06                	sd	ra,24(sp)
    8000402e:	e822                	sd	s0,16(sp)
    80004030:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80004032:	fe040613          	addi	a2,s0,-32
    80004036:	4581                	li	a1,0
    80004038:	e0bff0ef          	jal	80003e42 <namex>
}
    8000403c:	60e2                	ld	ra,24(sp)
    8000403e:	6442                	ld	s0,16(sp)
    80004040:	6105                	addi	sp,sp,32
    80004042:	8082                	ret

0000000080004044 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    80004044:	1141                	addi	sp,sp,-16
    80004046:	e406                	sd	ra,8(sp)
    80004048:	e022                	sd	s0,0(sp)
    8000404a:	0800                	addi	s0,sp,16
    8000404c:	862e                	mv	a2,a1
  return namex(path, 1, name);
    8000404e:	4585                	li	a1,1
    80004050:	df3ff0ef          	jal	80003e42 <namex>
}
    80004054:	60a2                	ld	ra,8(sp)
    80004056:	6402                	ld	s0,0(sp)
    80004058:	0141                	addi	sp,sp,16
    8000405a:	8082                	ret

000000008000405c <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    8000405c:	1101                	addi	sp,sp,-32
    8000405e:	ec06                	sd	ra,24(sp)
    80004060:	e822                	sd	s0,16(sp)
    80004062:	e426                	sd	s1,8(sp)
    80004064:	e04a                	sd	s2,0(sp)
    80004066:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80004068:	00020917          	auipc	s2,0x20
    8000406c:	86890913          	addi	s2,s2,-1944 # 800238d0 <log>
    80004070:	01892583          	lw	a1,24(s2)
    80004074:	02492503          	lw	a0,36(s2)
    80004078:	8aeff0ef          	jal	80003126 <bread>
    8000407c:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    8000407e:	02892603          	lw	a2,40(s2)
    80004082:	cd30                	sw	a2,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80004084:	00c05f63          	blez	a2,800040a2 <write_head+0x46>
    80004088:	00020717          	auipc	a4,0x20
    8000408c:	87470713          	addi	a4,a4,-1932 # 800238fc <log+0x2c>
    80004090:	87aa                	mv	a5,a0
    80004092:	060a                	slli	a2,a2,0x2
    80004094:	962a                	add	a2,a2,a0
    hb->block[i] = log.lh.block[i];
    80004096:	4314                	lw	a3,0(a4)
    80004098:	cff4                	sw	a3,92(a5)
  for (i = 0; i < log.lh.n; i++) {
    8000409a:	0711                	addi	a4,a4,4
    8000409c:	0791                	addi	a5,a5,4
    8000409e:	fec79ce3          	bne	a5,a2,80004096 <write_head+0x3a>
  }
  bwrite(buf);
    800040a2:	8526                	mv	a0,s1
    800040a4:	980ff0ef          	jal	80003224 <bwrite>
  brelse(buf);
    800040a8:	8526                	mv	a0,s1
    800040aa:	9acff0ef          	jal	80003256 <brelse>
}
    800040ae:	60e2                	ld	ra,24(sp)
    800040b0:	6442                	ld	s0,16(sp)
    800040b2:	64a2                	ld	s1,8(sp)
    800040b4:	6902                	ld	s2,0(sp)
    800040b6:	6105                	addi	sp,sp,32
    800040b8:	8082                	ret

00000000800040ba <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    800040ba:	00020797          	auipc	a5,0x20
    800040be:	83e7a783          	lw	a5,-1986(a5) # 800238f8 <log+0x28>
    800040c2:	0cf05163          	blez	a5,80004184 <install_trans+0xca>
{
    800040c6:	715d                	addi	sp,sp,-80
    800040c8:	e486                	sd	ra,72(sp)
    800040ca:	e0a2                	sd	s0,64(sp)
    800040cc:	fc26                	sd	s1,56(sp)
    800040ce:	f84a                	sd	s2,48(sp)
    800040d0:	f44e                	sd	s3,40(sp)
    800040d2:	f052                	sd	s4,32(sp)
    800040d4:	ec56                	sd	s5,24(sp)
    800040d6:	e85a                	sd	s6,16(sp)
    800040d8:	e45e                	sd	s7,8(sp)
    800040da:	e062                	sd	s8,0(sp)
    800040dc:	0880                	addi	s0,sp,80
    800040de:	8b2a                	mv	s6,a0
    800040e0:	00020a97          	auipc	s5,0x20
    800040e4:	81ca8a93          	addi	s5,s5,-2020 # 800238fc <log+0x2c>
  for (tail = 0; tail < log.lh.n; tail++) {
    800040e8:	4981                	li	s3,0
      printf("recovering tail %d dst %d\n", tail, log.lh.block[tail]);
    800040ea:	00004c17          	auipc	s8,0x4
    800040ee:	426c0c13          	addi	s8,s8,1062 # 80008510 <etext+0x510>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    800040f2:	0001fa17          	auipc	s4,0x1f
    800040f6:	7dea0a13          	addi	s4,s4,2014 # 800238d0 <log>
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    800040fa:	40000b93          	li	s7,1024
    800040fe:	a025                	j	80004126 <install_trans+0x6c>
      printf("recovering tail %d dst %d\n", tail, log.lh.block[tail]);
    80004100:	000aa603          	lw	a2,0(s5)
    80004104:	85ce                	mv	a1,s3
    80004106:	8562                	mv	a0,s8
    80004108:	c24fc0ef          	jal	8000052c <printf>
    8000410c:	a839                	j	8000412a <install_trans+0x70>
    brelse(lbuf);
    8000410e:	854a                	mv	a0,s2
    80004110:	946ff0ef          	jal	80003256 <brelse>
    brelse(dbuf);
    80004114:	8526                	mv	a0,s1
    80004116:	940ff0ef          	jal	80003256 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    8000411a:	2985                	addiw	s3,s3,1
    8000411c:	0a91                	addi	s5,s5,4
    8000411e:	028a2783          	lw	a5,40(s4)
    80004122:	04f9d563          	bge	s3,a5,8000416c <install_trans+0xb2>
    if(recovering) {
    80004126:	fc0b1de3          	bnez	s6,80004100 <install_trans+0x46>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    8000412a:	018a2583          	lw	a1,24(s4)
    8000412e:	013585bb          	addw	a1,a1,s3
    80004132:	2585                	addiw	a1,a1,1
    80004134:	024a2503          	lw	a0,36(s4)
    80004138:	feffe0ef          	jal	80003126 <bread>
    8000413c:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    8000413e:	000aa583          	lw	a1,0(s5)
    80004142:	024a2503          	lw	a0,36(s4)
    80004146:	fe1fe0ef          	jal	80003126 <bread>
    8000414a:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    8000414c:	865e                	mv	a2,s7
    8000414e:	05890593          	addi	a1,s2,88
    80004152:	05850513          	addi	a0,a0,88
    80004156:	cf1fc0ef          	jal	80000e46 <memmove>
    bwrite(dbuf);  // write dst to disk
    8000415a:	8526                	mv	a0,s1
    8000415c:	8c8ff0ef          	jal	80003224 <bwrite>
    if(recovering == 0)
    80004160:	fa0b17e3          	bnez	s6,8000410e <install_trans+0x54>
      bunpin(dbuf);
    80004164:	8526                	mv	a0,s1
    80004166:	9beff0ef          	jal	80003324 <bunpin>
    8000416a:	b755                	j	8000410e <install_trans+0x54>
}
    8000416c:	60a6                	ld	ra,72(sp)
    8000416e:	6406                	ld	s0,64(sp)
    80004170:	74e2                	ld	s1,56(sp)
    80004172:	7942                	ld	s2,48(sp)
    80004174:	79a2                	ld	s3,40(sp)
    80004176:	7a02                	ld	s4,32(sp)
    80004178:	6ae2                	ld	s5,24(sp)
    8000417a:	6b42                	ld	s6,16(sp)
    8000417c:	6ba2                	ld	s7,8(sp)
    8000417e:	6c02                	ld	s8,0(sp)
    80004180:	6161                	addi	sp,sp,80
    80004182:	8082                	ret
    80004184:	8082                	ret

0000000080004186 <initlog>:
{
    80004186:	7179                	addi	sp,sp,-48
    80004188:	f406                	sd	ra,40(sp)
    8000418a:	f022                	sd	s0,32(sp)
    8000418c:	ec26                	sd	s1,24(sp)
    8000418e:	e84a                	sd	s2,16(sp)
    80004190:	e44e                	sd	s3,8(sp)
    80004192:	1800                	addi	s0,sp,48
    80004194:	84aa                	mv	s1,a0
    80004196:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    80004198:	0001f917          	auipc	s2,0x1f
    8000419c:	73890913          	addi	s2,s2,1848 # 800238d0 <log>
    800041a0:	00004597          	auipc	a1,0x4
    800041a4:	39058593          	addi	a1,a1,912 # 80008530 <etext+0x530>
    800041a8:	854a                	mv	a0,s2
    800041aa:	ae3fc0ef          	jal	80000c8c <initlock>
  log.start = sb->logstart;
    800041ae:	0149a583          	lw	a1,20(s3)
    800041b2:	00b92c23          	sw	a1,24(s2)
  log.dev = dev;
    800041b6:	02992223          	sw	s1,36(s2)
  struct buf *buf = bread(log.dev, log.start);
    800041ba:	8526                	mv	a0,s1
    800041bc:	f6bfe0ef          	jal	80003126 <bread>
  log.lh.n = lh->n;
    800041c0:	4d30                	lw	a2,88(a0)
    800041c2:	02c92423          	sw	a2,40(s2)
  for (i = 0; i < log.lh.n; i++) {
    800041c6:	00c05f63          	blez	a2,800041e4 <initlog+0x5e>
    800041ca:	87aa                	mv	a5,a0
    800041cc:	0001f717          	auipc	a4,0x1f
    800041d0:	73070713          	addi	a4,a4,1840 # 800238fc <log+0x2c>
    800041d4:	060a                	slli	a2,a2,0x2
    800041d6:	962a                	add	a2,a2,a0
    log.lh.block[i] = lh->block[i];
    800041d8:	4ff4                	lw	a3,92(a5)
    800041da:	c314                	sw	a3,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    800041dc:	0791                	addi	a5,a5,4
    800041de:	0711                	addi	a4,a4,4
    800041e0:	fec79ce3          	bne	a5,a2,800041d8 <initlog+0x52>
  brelse(buf);
    800041e4:	872ff0ef          	jal	80003256 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    800041e8:	4505                	li	a0,1
    800041ea:	ed1ff0ef          	jal	800040ba <install_trans>
  log.lh.n = 0;
    800041ee:	0001f797          	auipc	a5,0x1f
    800041f2:	7007a523          	sw	zero,1802(a5) # 800238f8 <log+0x28>
  write_head(); // clear the log
    800041f6:	e67ff0ef          	jal	8000405c <write_head>
}
    800041fa:	70a2                	ld	ra,40(sp)
    800041fc:	7402                	ld	s0,32(sp)
    800041fe:	64e2                	ld	s1,24(sp)
    80004200:	6942                	ld	s2,16(sp)
    80004202:	69a2                	ld	s3,8(sp)
    80004204:	6145                	addi	sp,sp,48
    80004206:	8082                	ret

0000000080004208 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    80004208:	1101                	addi	sp,sp,-32
    8000420a:	ec06                	sd	ra,24(sp)
    8000420c:	e822                	sd	s0,16(sp)
    8000420e:	e426                	sd	s1,8(sp)
    80004210:	e04a                	sd	s2,0(sp)
    80004212:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    80004214:	0001f517          	auipc	a0,0x1f
    80004218:	6bc50513          	addi	a0,a0,1724 # 800238d0 <log>
    8000421c:	afbfc0ef          	jal	80000d16 <acquire>
  while(1){
    if(log.committing){
    80004220:	0001f497          	auipc	s1,0x1f
    80004224:	6b048493          	addi	s1,s1,1712 # 800238d0 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGBLOCKS){
    80004228:	4979                	li	s2,30
    8000422a:	a029                	j	80004234 <begin_op+0x2c>
      sleep(&log, &log.lock);
    8000422c:	85a6                	mv	a1,s1
    8000422e:	8526                	mv	a0,s1
    80004230:	a24fe0ef          	jal	80002454 <sleep>
    if(log.committing){
    80004234:	509c                	lw	a5,32(s1)
    80004236:	fbfd                	bnez	a5,8000422c <begin_op+0x24>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGBLOCKS){
    80004238:	4cd8                	lw	a4,28(s1)
    8000423a:	2705                	addiw	a4,a4,1
    8000423c:	0027179b          	slliw	a5,a4,0x2
    80004240:	9fb9                	addw	a5,a5,a4
    80004242:	0017979b          	slliw	a5,a5,0x1
    80004246:	5494                	lw	a3,40(s1)
    80004248:	9fb5                	addw	a5,a5,a3
    8000424a:	00f95763          	bge	s2,a5,80004258 <begin_op+0x50>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    8000424e:	85a6                	mv	a1,s1
    80004250:	8526                	mv	a0,s1
    80004252:	a02fe0ef          	jal	80002454 <sleep>
    80004256:	bff9                	j	80004234 <begin_op+0x2c>
    } else {
      log.outstanding += 1;
    80004258:	0001f797          	auipc	a5,0x1f
    8000425c:	68e7aa23          	sw	a4,1684(a5) # 800238ec <log+0x1c>
      release(&log.lock);
    80004260:	0001f517          	auipc	a0,0x1f
    80004264:	67050513          	addi	a0,a0,1648 # 800238d0 <log>
    80004268:	b43fc0ef          	jal	80000daa <release>
      break;
    }
  }
}
    8000426c:	60e2                	ld	ra,24(sp)
    8000426e:	6442                	ld	s0,16(sp)
    80004270:	64a2                	ld	s1,8(sp)
    80004272:	6902                	ld	s2,0(sp)
    80004274:	6105                	addi	sp,sp,32
    80004276:	8082                	ret

0000000080004278 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    80004278:	7139                	addi	sp,sp,-64
    8000427a:	fc06                	sd	ra,56(sp)
    8000427c:	f822                	sd	s0,48(sp)
    8000427e:	f426                	sd	s1,40(sp)
    80004280:	f04a                	sd	s2,32(sp)
    80004282:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    80004284:	0001f497          	auipc	s1,0x1f
    80004288:	64c48493          	addi	s1,s1,1612 # 800238d0 <log>
    8000428c:	8526                	mv	a0,s1
    8000428e:	a89fc0ef          	jal	80000d16 <acquire>
  log.outstanding -= 1;
    80004292:	4cdc                	lw	a5,28(s1)
    80004294:	37fd                	addiw	a5,a5,-1
    80004296:	893e                	mv	s2,a5
    80004298:	ccdc                	sw	a5,28(s1)
  if(log.committing)
    8000429a:	509c                	lw	a5,32(s1)
    8000429c:	e7b1                	bnez	a5,800042e8 <end_op+0x70>
    panic("log.committing");
  if(log.outstanding == 0){
    8000429e:	04091e63          	bnez	s2,800042fa <end_op+0x82>
    do_commit = 1;
    log.committing = 1;
    800042a2:	0001f497          	auipc	s1,0x1f
    800042a6:	62e48493          	addi	s1,s1,1582 # 800238d0 <log>
    800042aa:	4785                	li	a5,1
    800042ac:	d09c                	sw	a5,32(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    800042ae:	8526                	mv	a0,s1
    800042b0:	afbfc0ef          	jal	80000daa <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    800042b4:	549c                	lw	a5,40(s1)
    800042b6:	06f04463          	bgtz	a5,8000431e <end_op+0xa6>
    acquire(&log.lock);
    800042ba:	0001f517          	auipc	a0,0x1f
    800042be:	61650513          	addi	a0,a0,1558 # 800238d0 <log>
    800042c2:	a55fc0ef          	jal	80000d16 <acquire>
    log.committing = 0;
    800042c6:	0001f797          	auipc	a5,0x1f
    800042ca:	6207a523          	sw	zero,1578(a5) # 800238f0 <log+0x20>
    wakeup(&log);
    800042ce:	0001f517          	auipc	a0,0x1f
    800042d2:	60250513          	addi	a0,a0,1538 # 800238d0 <log>
    800042d6:	9cafe0ef          	jal	800024a0 <wakeup>
    release(&log.lock);
    800042da:	0001f517          	auipc	a0,0x1f
    800042de:	5f650513          	addi	a0,a0,1526 # 800238d0 <log>
    800042e2:	ac9fc0ef          	jal	80000daa <release>
}
    800042e6:	a035                	j	80004312 <end_op+0x9a>
    800042e8:	ec4e                	sd	s3,24(sp)
    800042ea:	e852                	sd	s4,16(sp)
    800042ec:	e456                	sd	s5,8(sp)
    panic("log.committing");
    800042ee:	00004517          	auipc	a0,0x4
    800042f2:	24a50513          	addi	a0,a0,586 # 80008538 <etext+0x538>
    800042f6:	d60fc0ef          	jal	80000856 <panic>
    wakeup(&log);
    800042fa:	0001f517          	auipc	a0,0x1f
    800042fe:	5d650513          	addi	a0,a0,1494 # 800238d0 <log>
    80004302:	99efe0ef          	jal	800024a0 <wakeup>
  release(&log.lock);
    80004306:	0001f517          	auipc	a0,0x1f
    8000430a:	5ca50513          	addi	a0,a0,1482 # 800238d0 <log>
    8000430e:	a9dfc0ef          	jal	80000daa <release>
}
    80004312:	70e2                	ld	ra,56(sp)
    80004314:	7442                	ld	s0,48(sp)
    80004316:	74a2                	ld	s1,40(sp)
    80004318:	7902                	ld	s2,32(sp)
    8000431a:	6121                	addi	sp,sp,64
    8000431c:	8082                	ret
    8000431e:	ec4e                	sd	s3,24(sp)
    80004320:	e852                	sd	s4,16(sp)
    80004322:	e456                	sd	s5,8(sp)
  for (tail = 0; tail < log.lh.n; tail++) {
    80004324:	0001fa97          	auipc	s5,0x1f
    80004328:	5d8a8a93          	addi	s5,s5,1496 # 800238fc <log+0x2c>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    8000432c:	0001fa17          	auipc	s4,0x1f
    80004330:	5a4a0a13          	addi	s4,s4,1444 # 800238d0 <log>
    80004334:	018a2583          	lw	a1,24(s4)
    80004338:	012585bb          	addw	a1,a1,s2
    8000433c:	2585                	addiw	a1,a1,1
    8000433e:	024a2503          	lw	a0,36(s4)
    80004342:	de5fe0ef          	jal	80003126 <bread>
    80004346:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    80004348:	000aa583          	lw	a1,0(s5)
    8000434c:	024a2503          	lw	a0,36(s4)
    80004350:	dd7fe0ef          	jal	80003126 <bread>
    80004354:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    80004356:	40000613          	li	a2,1024
    8000435a:	05850593          	addi	a1,a0,88
    8000435e:	05848513          	addi	a0,s1,88
    80004362:	ae5fc0ef          	jal	80000e46 <memmove>
    bwrite(to);  // write the log
    80004366:	8526                	mv	a0,s1
    80004368:	ebdfe0ef          	jal	80003224 <bwrite>
    brelse(from);
    8000436c:	854e                	mv	a0,s3
    8000436e:	ee9fe0ef          	jal	80003256 <brelse>
    brelse(to);
    80004372:	8526                	mv	a0,s1
    80004374:	ee3fe0ef          	jal	80003256 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004378:	2905                	addiw	s2,s2,1
    8000437a:	0a91                	addi	s5,s5,4
    8000437c:	028a2783          	lw	a5,40(s4)
    80004380:	faf94ae3          	blt	s2,a5,80004334 <end_op+0xbc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    80004384:	cd9ff0ef          	jal	8000405c <write_head>
    install_trans(0); // Now install writes to home locations
    80004388:	4501                	li	a0,0
    8000438a:	d31ff0ef          	jal	800040ba <install_trans>
    log.lh.n = 0;
    8000438e:	0001f797          	auipc	a5,0x1f
    80004392:	5607a523          	sw	zero,1386(a5) # 800238f8 <log+0x28>
    write_head();    // Erase the transaction from the log
    80004396:	cc7ff0ef          	jal	8000405c <write_head>
    8000439a:	69e2                	ld	s3,24(sp)
    8000439c:	6a42                	ld	s4,16(sp)
    8000439e:	6aa2                	ld	s5,8(sp)
    800043a0:	bf29                	j	800042ba <end_op+0x42>

00000000800043a2 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    800043a2:	1101                	addi	sp,sp,-32
    800043a4:	ec06                	sd	ra,24(sp)
    800043a6:	e822                	sd	s0,16(sp)
    800043a8:	e426                	sd	s1,8(sp)
    800043aa:	1000                	addi	s0,sp,32
    800043ac:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    800043ae:	0001f517          	auipc	a0,0x1f
    800043b2:	52250513          	addi	a0,a0,1314 # 800238d0 <log>
    800043b6:	961fc0ef          	jal	80000d16 <acquire>
  if (log.lh.n >= LOGBLOCKS)
    800043ba:	0001f617          	auipc	a2,0x1f
    800043be:	53e62603          	lw	a2,1342(a2) # 800238f8 <log+0x28>
    800043c2:	47f5                	li	a5,29
    800043c4:	04c7cd63          	blt	a5,a2,8000441e <log_write+0x7c>
    panic("too big a transaction");
  if (log.outstanding < 1)
    800043c8:	0001f797          	auipc	a5,0x1f
    800043cc:	5247a783          	lw	a5,1316(a5) # 800238ec <log+0x1c>
    800043d0:	04f05d63          	blez	a5,8000442a <log_write+0x88>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    800043d4:	4781                	li	a5,0
    800043d6:	06c05063          	blez	a2,80004436 <log_write+0x94>
    if (log.lh.block[i] == b->blockno)   // log absorption
    800043da:	44cc                	lw	a1,12(s1)
    800043dc:	0001f717          	auipc	a4,0x1f
    800043e0:	52070713          	addi	a4,a4,1312 # 800238fc <log+0x2c>
  for (i = 0; i < log.lh.n; i++) {
    800043e4:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    800043e6:	4314                	lw	a3,0(a4)
    800043e8:	04b68763          	beq	a3,a1,80004436 <log_write+0x94>
  for (i = 0; i < log.lh.n; i++) {
    800043ec:	2785                	addiw	a5,a5,1
    800043ee:	0711                	addi	a4,a4,4
    800043f0:	fef61be3          	bne	a2,a5,800043e6 <log_write+0x44>
      break;
  }
  log.lh.block[i] = b->blockno;
    800043f4:	060a                	slli	a2,a2,0x2
    800043f6:	02060613          	addi	a2,a2,32
    800043fa:	0001f797          	auipc	a5,0x1f
    800043fe:	4d678793          	addi	a5,a5,1238 # 800238d0 <log>
    80004402:	97b2                	add	a5,a5,a2
    80004404:	44d8                	lw	a4,12(s1)
    80004406:	c7d8                	sw	a4,12(a5)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    80004408:	8526                	mv	a0,s1
    8000440a:	ee7fe0ef          	jal	800032f0 <bpin>
    log.lh.n++;
    8000440e:	0001f717          	auipc	a4,0x1f
    80004412:	4c270713          	addi	a4,a4,1218 # 800238d0 <log>
    80004416:	571c                	lw	a5,40(a4)
    80004418:	2785                	addiw	a5,a5,1
    8000441a:	d71c                	sw	a5,40(a4)
    8000441c:	a815                	j	80004450 <log_write+0xae>
    panic("too big a transaction");
    8000441e:	00004517          	auipc	a0,0x4
    80004422:	12a50513          	addi	a0,a0,298 # 80008548 <etext+0x548>
    80004426:	c30fc0ef          	jal	80000856 <panic>
    panic("log_write outside of trans");
    8000442a:	00004517          	auipc	a0,0x4
    8000442e:	13650513          	addi	a0,a0,310 # 80008560 <etext+0x560>
    80004432:	c24fc0ef          	jal	80000856 <panic>
  log.lh.block[i] = b->blockno;
    80004436:	00279693          	slli	a3,a5,0x2
    8000443a:	02068693          	addi	a3,a3,32
    8000443e:	0001f717          	auipc	a4,0x1f
    80004442:	49270713          	addi	a4,a4,1170 # 800238d0 <log>
    80004446:	9736                	add	a4,a4,a3
    80004448:	44d4                	lw	a3,12(s1)
    8000444a:	c754                	sw	a3,12(a4)
  if (i == log.lh.n) {  // Add new block to log?
    8000444c:	faf60ee3          	beq	a2,a5,80004408 <log_write+0x66>
  }
  release(&log.lock);
    80004450:	0001f517          	auipc	a0,0x1f
    80004454:	48050513          	addi	a0,a0,1152 # 800238d0 <log>
    80004458:	953fc0ef          	jal	80000daa <release>
}
    8000445c:	60e2                	ld	ra,24(sp)
    8000445e:	6442                	ld	s0,16(sp)
    80004460:	64a2                	ld	s1,8(sp)
    80004462:	6105                	addi	sp,sp,32
    80004464:	8082                	ret

0000000080004466 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    80004466:	1101                	addi	sp,sp,-32
    80004468:	ec06                	sd	ra,24(sp)
    8000446a:	e822                	sd	s0,16(sp)
    8000446c:	e426                	sd	s1,8(sp)
    8000446e:	e04a                	sd	s2,0(sp)
    80004470:	1000                	addi	s0,sp,32
    80004472:	84aa                	mv	s1,a0
    80004474:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    80004476:	00004597          	auipc	a1,0x4
    8000447a:	10a58593          	addi	a1,a1,266 # 80008580 <etext+0x580>
    8000447e:	0521                	addi	a0,a0,8
    80004480:	80dfc0ef          	jal	80000c8c <initlock>
  lk->name = name;
    80004484:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    80004488:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    8000448c:	0204a423          	sw	zero,40(s1)
}
    80004490:	60e2                	ld	ra,24(sp)
    80004492:	6442                	ld	s0,16(sp)
    80004494:	64a2                	ld	s1,8(sp)
    80004496:	6902                	ld	s2,0(sp)
    80004498:	6105                	addi	sp,sp,32
    8000449a:	8082                	ret

000000008000449c <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    8000449c:	1101                	addi	sp,sp,-32
    8000449e:	ec06                	sd	ra,24(sp)
    800044a0:	e822                	sd	s0,16(sp)
    800044a2:	e426                	sd	s1,8(sp)
    800044a4:	e04a                	sd	s2,0(sp)
    800044a6:	1000                	addi	s0,sp,32
    800044a8:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    800044aa:	00850913          	addi	s2,a0,8
    800044ae:	854a                	mv	a0,s2
    800044b0:	867fc0ef          	jal	80000d16 <acquire>
  while (lk->locked) {
    800044b4:	409c                	lw	a5,0(s1)
    800044b6:	c799                	beqz	a5,800044c4 <acquiresleep+0x28>
    sleep(lk, &lk->lk);
    800044b8:	85ca                	mv	a1,s2
    800044ba:	8526                	mv	a0,s1
    800044bc:	f99fd0ef          	jal	80002454 <sleep>
  while (lk->locked) {
    800044c0:	409c                	lw	a5,0(s1)
    800044c2:	fbfd                	bnez	a5,800044b8 <acquiresleep+0x1c>
  }
  lk->locked = 1;
    800044c4:	4785                	li	a5,1
    800044c6:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    800044c8:	f60fd0ef          	jal	80001c28 <myproc>
    800044cc:	591c                	lw	a5,48(a0)
    800044ce:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    800044d0:	854a                	mv	a0,s2
    800044d2:	8d9fc0ef          	jal	80000daa <release>
}
    800044d6:	60e2                	ld	ra,24(sp)
    800044d8:	6442                	ld	s0,16(sp)
    800044da:	64a2                	ld	s1,8(sp)
    800044dc:	6902                	ld	s2,0(sp)
    800044de:	6105                	addi	sp,sp,32
    800044e0:	8082                	ret

00000000800044e2 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    800044e2:	1101                	addi	sp,sp,-32
    800044e4:	ec06                	sd	ra,24(sp)
    800044e6:	e822                	sd	s0,16(sp)
    800044e8:	e426                	sd	s1,8(sp)
    800044ea:	e04a                	sd	s2,0(sp)
    800044ec:	1000                	addi	s0,sp,32
    800044ee:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    800044f0:	00850913          	addi	s2,a0,8
    800044f4:	854a                	mv	a0,s2
    800044f6:	821fc0ef          	jal	80000d16 <acquire>
  lk->locked = 0;
    800044fa:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    800044fe:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    80004502:	8526                	mv	a0,s1
    80004504:	f9dfd0ef          	jal	800024a0 <wakeup>
  release(&lk->lk);
    80004508:	854a                	mv	a0,s2
    8000450a:	8a1fc0ef          	jal	80000daa <release>
}
    8000450e:	60e2                	ld	ra,24(sp)
    80004510:	6442                	ld	s0,16(sp)
    80004512:	64a2                	ld	s1,8(sp)
    80004514:	6902                	ld	s2,0(sp)
    80004516:	6105                	addi	sp,sp,32
    80004518:	8082                	ret

000000008000451a <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    8000451a:	7179                	addi	sp,sp,-48
    8000451c:	f406                	sd	ra,40(sp)
    8000451e:	f022                	sd	s0,32(sp)
    80004520:	ec26                	sd	s1,24(sp)
    80004522:	e84a                	sd	s2,16(sp)
    80004524:	1800                	addi	s0,sp,48
    80004526:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    80004528:	00850913          	addi	s2,a0,8
    8000452c:	854a                	mv	a0,s2
    8000452e:	fe8fc0ef          	jal	80000d16 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    80004532:	409c                	lw	a5,0(s1)
    80004534:	ef81                	bnez	a5,8000454c <holdingsleep+0x32>
    80004536:	4481                	li	s1,0
  release(&lk->lk);
    80004538:	854a                	mv	a0,s2
    8000453a:	871fc0ef          	jal	80000daa <release>
  return r;
}
    8000453e:	8526                	mv	a0,s1
    80004540:	70a2                	ld	ra,40(sp)
    80004542:	7402                	ld	s0,32(sp)
    80004544:	64e2                	ld	s1,24(sp)
    80004546:	6942                	ld	s2,16(sp)
    80004548:	6145                	addi	sp,sp,48
    8000454a:	8082                	ret
    8000454c:	e44e                	sd	s3,8(sp)
  r = lk->locked && (lk->pid == myproc()->pid);
    8000454e:	0284a983          	lw	s3,40(s1)
    80004552:	ed6fd0ef          	jal	80001c28 <myproc>
    80004556:	5904                	lw	s1,48(a0)
    80004558:	413484b3          	sub	s1,s1,s3
    8000455c:	0014b493          	seqz	s1,s1
    80004560:	69a2                	ld	s3,8(sp)
    80004562:	bfd9                	j	80004538 <holdingsleep+0x1e>

0000000080004564 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    80004564:	1141                	addi	sp,sp,-16
    80004566:	e406                	sd	ra,8(sp)
    80004568:	e022                	sd	s0,0(sp)
    8000456a:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    8000456c:	00004597          	auipc	a1,0x4
    80004570:	02458593          	addi	a1,a1,36 # 80008590 <etext+0x590>
    80004574:	0001f517          	auipc	a0,0x1f
    80004578:	4a450513          	addi	a0,a0,1188 # 80023a18 <ftable>
    8000457c:	f10fc0ef          	jal	80000c8c <initlock>
}
    80004580:	60a2                	ld	ra,8(sp)
    80004582:	6402                	ld	s0,0(sp)
    80004584:	0141                	addi	sp,sp,16
    80004586:	8082                	ret

0000000080004588 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    80004588:	1101                	addi	sp,sp,-32
    8000458a:	ec06                	sd	ra,24(sp)
    8000458c:	e822                	sd	s0,16(sp)
    8000458e:	e426                	sd	s1,8(sp)
    80004590:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    80004592:	0001f517          	auipc	a0,0x1f
    80004596:	48650513          	addi	a0,a0,1158 # 80023a18 <ftable>
    8000459a:	f7cfc0ef          	jal	80000d16 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    8000459e:	0001f497          	auipc	s1,0x1f
    800045a2:	49248493          	addi	s1,s1,1170 # 80023a30 <ftable+0x18>
    800045a6:	00020717          	auipc	a4,0x20
    800045aa:	42a70713          	addi	a4,a4,1066 # 800249d0 <disk>
    if(f->ref == 0){
    800045ae:	40dc                	lw	a5,4(s1)
    800045b0:	cf89                	beqz	a5,800045ca <filealloc+0x42>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    800045b2:	02848493          	addi	s1,s1,40
    800045b6:	fee49ce3          	bne	s1,a4,800045ae <filealloc+0x26>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    800045ba:	0001f517          	auipc	a0,0x1f
    800045be:	45e50513          	addi	a0,a0,1118 # 80023a18 <ftable>
    800045c2:	fe8fc0ef          	jal	80000daa <release>
  return 0;
    800045c6:	4481                	li	s1,0
    800045c8:	a809                	j	800045da <filealloc+0x52>
      f->ref = 1;
    800045ca:	4785                	li	a5,1
    800045cc:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    800045ce:	0001f517          	auipc	a0,0x1f
    800045d2:	44a50513          	addi	a0,a0,1098 # 80023a18 <ftable>
    800045d6:	fd4fc0ef          	jal	80000daa <release>
}
    800045da:	8526                	mv	a0,s1
    800045dc:	60e2                	ld	ra,24(sp)
    800045de:	6442                	ld	s0,16(sp)
    800045e0:	64a2                	ld	s1,8(sp)
    800045e2:	6105                	addi	sp,sp,32
    800045e4:	8082                	ret

00000000800045e6 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    800045e6:	1101                	addi	sp,sp,-32
    800045e8:	ec06                	sd	ra,24(sp)
    800045ea:	e822                	sd	s0,16(sp)
    800045ec:	e426                	sd	s1,8(sp)
    800045ee:	1000                	addi	s0,sp,32
    800045f0:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    800045f2:	0001f517          	auipc	a0,0x1f
    800045f6:	42650513          	addi	a0,a0,1062 # 80023a18 <ftable>
    800045fa:	f1cfc0ef          	jal	80000d16 <acquire>
  if(f->ref < 1)
    800045fe:	40dc                	lw	a5,4(s1)
    80004600:	02f05063          	blez	a5,80004620 <filedup+0x3a>
    panic("filedup");
  f->ref++;
    80004604:	2785                	addiw	a5,a5,1
    80004606:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80004608:	0001f517          	auipc	a0,0x1f
    8000460c:	41050513          	addi	a0,a0,1040 # 80023a18 <ftable>
    80004610:	f9afc0ef          	jal	80000daa <release>
  return f;
}
    80004614:	8526                	mv	a0,s1
    80004616:	60e2                	ld	ra,24(sp)
    80004618:	6442                	ld	s0,16(sp)
    8000461a:	64a2                	ld	s1,8(sp)
    8000461c:	6105                	addi	sp,sp,32
    8000461e:	8082                	ret
    panic("filedup");
    80004620:	00004517          	auipc	a0,0x4
    80004624:	f7850513          	addi	a0,a0,-136 # 80008598 <etext+0x598>
    80004628:	a2efc0ef          	jal	80000856 <panic>

000000008000462c <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    8000462c:	7139                	addi	sp,sp,-64
    8000462e:	fc06                	sd	ra,56(sp)
    80004630:	f822                	sd	s0,48(sp)
    80004632:	f426                	sd	s1,40(sp)
    80004634:	0080                	addi	s0,sp,64
    80004636:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    80004638:	0001f517          	auipc	a0,0x1f
    8000463c:	3e050513          	addi	a0,a0,992 # 80023a18 <ftable>
    80004640:	ed6fc0ef          	jal	80000d16 <acquire>
  if(f->ref < 1)
    80004644:	40dc                	lw	a5,4(s1)
    80004646:	04f05a63          	blez	a5,8000469a <fileclose+0x6e>
    panic("fileclose");
  if(--f->ref > 0){
    8000464a:	37fd                	addiw	a5,a5,-1
    8000464c:	c0dc                	sw	a5,4(s1)
    8000464e:	06f04063          	bgtz	a5,800046ae <fileclose+0x82>
    80004652:	f04a                	sd	s2,32(sp)
    80004654:	ec4e                	sd	s3,24(sp)
    80004656:	e852                	sd	s4,16(sp)
    80004658:	e456                	sd	s5,8(sp)
    release(&ftable.lock);
    return;
  }
  ff = *f;
    8000465a:	0004a903          	lw	s2,0(s1)
    8000465e:	0094c783          	lbu	a5,9(s1)
    80004662:	89be                	mv	s3,a5
    80004664:	689c                	ld	a5,16(s1)
    80004666:	8a3e                	mv	s4,a5
    80004668:	6c9c                	ld	a5,24(s1)
    8000466a:	8abe                	mv	s5,a5
  f->ref = 0;
    8000466c:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    80004670:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    80004674:	0001f517          	auipc	a0,0x1f
    80004678:	3a450513          	addi	a0,a0,932 # 80023a18 <ftable>
    8000467c:	f2efc0ef          	jal	80000daa <release>

  if(ff.type == FD_PIPE){
    80004680:	4785                	li	a5,1
    80004682:	04f90163          	beq	s2,a5,800046c4 <fileclose+0x98>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    80004686:	ffe9079b          	addiw	a5,s2,-2
    8000468a:	4705                	li	a4,1
    8000468c:	04f77563          	bgeu	a4,a5,800046d6 <fileclose+0xaa>
    80004690:	7902                	ld	s2,32(sp)
    80004692:	69e2                	ld	s3,24(sp)
    80004694:	6a42                	ld	s4,16(sp)
    80004696:	6aa2                	ld	s5,8(sp)
    80004698:	a00d                	j	800046ba <fileclose+0x8e>
    8000469a:	f04a                	sd	s2,32(sp)
    8000469c:	ec4e                	sd	s3,24(sp)
    8000469e:	e852                	sd	s4,16(sp)
    800046a0:	e456                	sd	s5,8(sp)
    panic("fileclose");
    800046a2:	00004517          	auipc	a0,0x4
    800046a6:	efe50513          	addi	a0,a0,-258 # 800085a0 <etext+0x5a0>
    800046aa:	9acfc0ef          	jal	80000856 <panic>
    release(&ftable.lock);
    800046ae:	0001f517          	auipc	a0,0x1f
    800046b2:	36a50513          	addi	a0,a0,874 # 80023a18 <ftable>
    800046b6:	ef4fc0ef          	jal	80000daa <release>
    begin_op();
    iput(ff.ip);
    end_op();
  }
}
    800046ba:	70e2                	ld	ra,56(sp)
    800046bc:	7442                	ld	s0,48(sp)
    800046be:	74a2                	ld	s1,40(sp)
    800046c0:	6121                	addi	sp,sp,64
    800046c2:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    800046c4:	85ce                	mv	a1,s3
    800046c6:	8552                	mv	a0,s4
    800046c8:	348000ef          	jal	80004a10 <pipeclose>
    800046cc:	7902                	ld	s2,32(sp)
    800046ce:	69e2                	ld	s3,24(sp)
    800046d0:	6a42                	ld	s4,16(sp)
    800046d2:	6aa2                	ld	s5,8(sp)
    800046d4:	b7dd                	j	800046ba <fileclose+0x8e>
    begin_op();
    800046d6:	b33ff0ef          	jal	80004208 <begin_op>
    iput(ff.ip);
    800046da:	8556                	mv	a0,s5
    800046dc:	aa2ff0ef          	jal	8000397e <iput>
    end_op();
    800046e0:	b99ff0ef          	jal	80004278 <end_op>
    800046e4:	7902                	ld	s2,32(sp)
    800046e6:	69e2                	ld	s3,24(sp)
    800046e8:	6a42                	ld	s4,16(sp)
    800046ea:	6aa2                	ld	s5,8(sp)
    800046ec:	b7f9                	j	800046ba <fileclose+0x8e>

00000000800046ee <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    800046ee:	715d                	addi	sp,sp,-80
    800046f0:	e486                	sd	ra,72(sp)
    800046f2:	e0a2                	sd	s0,64(sp)
    800046f4:	fc26                	sd	s1,56(sp)
    800046f6:	f052                	sd	s4,32(sp)
    800046f8:	0880                	addi	s0,sp,80
    800046fa:	84aa                	mv	s1,a0
    800046fc:	8a2e                	mv	s4,a1
  struct proc *p = myproc();
    800046fe:	d2afd0ef          	jal	80001c28 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    80004702:	409c                	lw	a5,0(s1)
    80004704:	37f9                	addiw	a5,a5,-2
    80004706:	4705                	li	a4,1
    80004708:	04f76263          	bltu	a4,a5,8000474c <filestat+0x5e>
    8000470c:	f84a                	sd	s2,48(sp)
    8000470e:	f44e                	sd	s3,40(sp)
    80004710:	89aa                	mv	s3,a0
    ilock(f->ip);
    80004712:	6c88                	ld	a0,24(s1)
    80004714:	8e8ff0ef          	jal	800037fc <ilock>
    stati(f->ip, &st);
    80004718:	fb840913          	addi	s2,s0,-72
    8000471c:	85ca                	mv	a1,s2
    8000471e:	6c88                	ld	a0,24(s1)
    80004720:	c40ff0ef          	jal	80003b60 <stati>
    iunlock(f->ip);
    80004724:	6c88                	ld	a0,24(s1)
    80004726:	984ff0ef          	jal	800038aa <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    8000472a:	46e1                	li	a3,24
    8000472c:	864a                	mv	a2,s2
    8000472e:	85d2                	mv	a1,s4
    80004730:	0509b503          	ld	a0,80(s3)
    80004734:	a06fd0ef          	jal	8000193a <copyout>
    80004738:	41f5551b          	sraiw	a0,a0,0x1f
    8000473c:	7942                	ld	s2,48(sp)
    8000473e:	79a2                	ld	s3,40(sp)
      return -1;
    return 0;
  }
  return -1;
}
    80004740:	60a6                	ld	ra,72(sp)
    80004742:	6406                	ld	s0,64(sp)
    80004744:	74e2                	ld	s1,56(sp)
    80004746:	7a02                	ld	s4,32(sp)
    80004748:	6161                	addi	sp,sp,80
    8000474a:	8082                	ret
  return -1;
    8000474c:	557d                	li	a0,-1
    8000474e:	bfcd                	j	80004740 <filestat+0x52>

0000000080004750 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    80004750:	7179                	addi	sp,sp,-48
    80004752:	f406                	sd	ra,40(sp)
    80004754:	f022                	sd	s0,32(sp)
    80004756:	e84a                	sd	s2,16(sp)
    80004758:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    8000475a:	00854783          	lbu	a5,8(a0)
    8000475e:	cfd1                	beqz	a5,800047fa <fileread+0xaa>
    80004760:	ec26                	sd	s1,24(sp)
    80004762:	e44e                	sd	s3,8(sp)
    80004764:	84aa                	mv	s1,a0
    80004766:	892e                	mv	s2,a1
    80004768:	89b2                	mv	s3,a2
    return -1;

  if(f->type == FD_PIPE){
    8000476a:	411c                	lw	a5,0(a0)
    8000476c:	4705                	li	a4,1
    8000476e:	04e78363          	beq	a5,a4,800047b4 <fileread+0x64>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004772:	470d                	li	a4,3
    80004774:	04e78763          	beq	a5,a4,800047c2 <fileread+0x72>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    80004778:	4709                	li	a4,2
    8000477a:	06e79a63          	bne	a5,a4,800047ee <fileread+0x9e>
    ilock(f->ip);
    8000477e:	6d08                	ld	a0,24(a0)
    80004780:	87cff0ef          	jal	800037fc <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    80004784:	874e                	mv	a4,s3
    80004786:	5094                	lw	a3,32(s1)
    80004788:	864a                	mv	a2,s2
    8000478a:	4585                	li	a1,1
    8000478c:	6c88                	ld	a0,24(s1)
    8000478e:	c00ff0ef          	jal	80003b8e <readi>
    80004792:	892a                	mv	s2,a0
    80004794:	00a05563          	blez	a0,8000479e <fileread+0x4e>
      f->off += r;
    80004798:	509c                	lw	a5,32(s1)
    8000479a:	9fa9                	addw	a5,a5,a0
    8000479c:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    8000479e:	6c88                	ld	a0,24(s1)
    800047a0:	90aff0ef          	jal	800038aa <iunlock>
    800047a4:	64e2                	ld	s1,24(sp)
    800047a6:	69a2                	ld	s3,8(sp)
  } else {
    panic("fileread");
  }

  return r;
}
    800047a8:	854a                	mv	a0,s2
    800047aa:	70a2                	ld	ra,40(sp)
    800047ac:	7402                	ld	s0,32(sp)
    800047ae:	6942                	ld	s2,16(sp)
    800047b0:	6145                	addi	sp,sp,48
    800047b2:	8082                	ret
    r = piperead(f->pipe, addr, n);
    800047b4:	6908                	ld	a0,16(a0)
    800047b6:	3b0000ef          	jal	80004b66 <piperead>
    800047ba:	892a                	mv	s2,a0
    800047bc:	64e2                	ld	s1,24(sp)
    800047be:	69a2                	ld	s3,8(sp)
    800047c0:	b7e5                	j	800047a8 <fileread+0x58>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    800047c2:	02451783          	lh	a5,36(a0)
    800047c6:	03079693          	slli	a3,a5,0x30
    800047ca:	92c1                	srli	a3,a3,0x30
    800047cc:	4725                	li	a4,9
    800047ce:	02d76963          	bltu	a4,a3,80004800 <fileread+0xb0>
    800047d2:	0792                	slli	a5,a5,0x4
    800047d4:	0001f717          	auipc	a4,0x1f
    800047d8:	1a470713          	addi	a4,a4,420 # 80023978 <devsw>
    800047dc:	97ba                	add	a5,a5,a4
    800047de:	639c                	ld	a5,0(a5)
    800047e0:	c78d                	beqz	a5,8000480a <fileread+0xba>
    r = devsw[f->major].read(1, addr, n);
    800047e2:	4505                	li	a0,1
    800047e4:	9782                	jalr	a5
    800047e6:	892a                	mv	s2,a0
    800047e8:	64e2                	ld	s1,24(sp)
    800047ea:	69a2                	ld	s3,8(sp)
    800047ec:	bf75                	j	800047a8 <fileread+0x58>
    panic("fileread");
    800047ee:	00004517          	auipc	a0,0x4
    800047f2:	dc250513          	addi	a0,a0,-574 # 800085b0 <etext+0x5b0>
    800047f6:	860fc0ef          	jal	80000856 <panic>
    return -1;
    800047fa:	57fd                	li	a5,-1
    800047fc:	893e                	mv	s2,a5
    800047fe:	b76d                	j	800047a8 <fileread+0x58>
      return -1;
    80004800:	57fd                	li	a5,-1
    80004802:	893e                	mv	s2,a5
    80004804:	64e2                	ld	s1,24(sp)
    80004806:	69a2                	ld	s3,8(sp)
    80004808:	b745                	j	800047a8 <fileread+0x58>
    8000480a:	57fd                	li	a5,-1
    8000480c:	893e                	mv	s2,a5
    8000480e:	64e2                	ld	s1,24(sp)
    80004810:	69a2                	ld	s3,8(sp)
    80004812:	bf59                	j	800047a8 <fileread+0x58>

0000000080004814 <filewrite>:
int
filewrite(struct file *f, uint64 addr, int n)
{
  int r, ret = 0;

  if(f->writable == 0)
    80004814:	00954783          	lbu	a5,9(a0)
    80004818:	10078f63          	beqz	a5,80004936 <filewrite+0x122>
{
    8000481c:	711d                	addi	sp,sp,-96
    8000481e:	ec86                	sd	ra,88(sp)
    80004820:	e8a2                	sd	s0,80(sp)
    80004822:	e0ca                	sd	s2,64(sp)
    80004824:	f456                	sd	s5,40(sp)
    80004826:	f05a                	sd	s6,32(sp)
    80004828:	1080                	addi	s0,sp,96
    8000482a:	892a                	mv	s2,a0
    8000482c:	8b2e                	mv	s6,a1
    8000482e:	8ab2                	mv	s5,a2
    return -1;

  if(f->type == FD_PIPE){
    80004830:	411c                	lw	a5,0(a0)
    80004832:	4705                	li	a4,1
    80004834:	02e78a63          	beq	a5,a4,80004868 <filewrite+0x54>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004838:	470d                	li	a4,3
    8000483a:	02e78b63          	beq	a5,a4,80004870 <filewrite+0x5c>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    8000483e:	4709                	li	a4,2
    80004840:	0ce79f63          	bne	a5,a4,8000491e <filewrite+0x10a>
    80004844:	f852                	sd	s4,48(sp)
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    80004846:	0ac05a63          	blez	a2,800048fa <filewrite+0xe6>
    8000484a:	e4a6                	sd	s1,72(sp)
    8000484c:	fc4e                	sd	s3,56(sp)
    8000484e:	ec5e                	sd	s7,24(sp)
    80004850:	e862                	sd	s8,16(sp)
    80004852:	e466                	sd	s9,8(sp)
    int i = 0;
    80004854:	4a01                	li	s4,0
      int n1 = n - i;
      if(n1 > max)
    80004856:	6b85                	lui	s7,0x1
    80004858:	c00b8b93          	addi	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    8000485c:	6785                	lui	a5,0x1
    8000485e:	c007879b          	addiw	a5,a5,-1024 # c00 <_entry-0x7ffff400>
    80004862:	8cbe                	mv	s9,a5
        n1 = max;

      begin_op();
      ilock(f->ip);
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80004864:	4c05                	li	s8,1
    80004866:	a8ad                	j	800048e0 <filewrite+0xcc>
    ret = pipewrite(f->pipe, addr, n);
    80004868:	6908                	ld	a0,16(a0)
    8000486a:	204000ef          	jal	80004a6e <pipewrite>
    8000486e:	a04d                	j	80004910 <filewrite+0xfc>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80004870:	02451783          	lh	a5,36(a0)
    80004874:	03079693          	slli	a3,a5,0x30
    80004878:	92c1                	srli	a3,a3,0x30
    8000487a:	4725                	li	a4,9
    8000487c:	0ad76f63          	bltu	a4,a3,8000493a <filewrite+0x126>
    80004880:	0792                	slli	a5,a5,0x4
    80004882:	0001f717          	auipc	a4,0x1f
    80004886:	0f670713          	addi	a4,a4,246 # 80023978 <devsw>
    8000488a:	97ba                	add	a5,a5,a4
    8000488c:	679c                	ld	a5,8(a5)
    8000488e:	cbc5                	beqz	a5,8000493e <filewrite+0x12a>
    ret = devsw[f->major].write(1, addr, n);
    80004890:	4505                	li	a0,1
    80004892:	9782                	jalr	a5
    80004894:	a8b5                	j	80004910 <filewrite+0xfc>
      if(n1 > max)
    80004896:	2981                	sext.w	s3,s3
      begin_op();
    80004898:	971ff0ef          	jal	80004208 <begin_op>
      ilock(f->ip);
    8000489c:	01893503          	ld	a0,24(s2)
    800048a0:	f5dfe0ef          	jal	800037fc <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    800048a4:	874e                	mv	a4,s3
    800048a6:	02092683          	lw	a3,32(s2)
    800048aa:	016a0633          	add	a2,s4,s6
    800048ae:	85e2                	mv	a1,s8
    800048b0:	01893503          	ld	a0,24(s2)
    800048b4:	bccff0ef          	jal	80003c80 <writei>
    800048b8:	84aa                	mv	s1,a0
    800048ba:	00a05763          	blez	a0,800048c8 <filewrite+0xb4>
        f->off += r;
    800048be:	02092783          	lw	a5,32(s2)
    800048c2:	9fa9                	addw	a5,a5,a0
    800048c4:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    800048c8:	01893503          	ld	a0,24(s2)
    800048cc:	fdffe0ef          	jal	800038aa <iunlock>
      end_op();
    800048d0:	9a9ff0ef          	jal	80004278 <end_op>

      if(r != n1){
    800048d4:	02999563          	bne	s3,s1,800048fe <filewrite+0xea>
        // error from writei
        break;
      }
      i += r;
    800048d8:	01448a3b          	addw	s4,s1,s4
    while(i < n){
    800048dc:	015a5963          	bge	s4,s5,800048ee <filewrite+0xda>
      int n1 = n - i;
    800048e0:	414a87bb          	subw	a5,s5,s4
    800048e4:	89be                	mv	s3,a5
      if(n1 > max)
    800048e6:	fafbd8e3          	bge	s7,a5,80004896 <filewrite+0x82>
    800048ea:	89e6                	mv	s3,s9
    800048ec:	b76d                	j	80004896 <filewrite+0x82>
    800048ee:	64a6                	ld	s1,72(sp)
    800048f0:	79e2                	ld	s3,56(sp)
    800048f2:	6be2                	ld	s7,24(sp)
    800048f4:	6c42                	ld	s8,16(sp)
    800048f6:	6ca2                	ld	s9,8(sp)
    800048f8:	a801                	j	80004908 <filewrite+0xf4>
    int i = 0;
    800048fa:	4a01                	li	s4,0
    800048fc:	a031                	j	80004908 <filewrite+0xf4>
    800048fe:	64a6                	ld	s1,72(sp)
    80004900:	79e2                	ld	s3,56(sp)
    80004902:	6be2                	ld	s7,24(sp)
    80004904:	6c42                	ld	s8,16(sp)
    80004906:	6ca2                	ld	s9,8(sp)
    }
    ret = (i == n ? n : -1);
    80004908:	034a9d63          	bne	s5,s4,80004942 <filewrite+0x12e>
    8000490c:	8556                	mv	a0,s5
    8000490e:	7a42                	ld	s4,48(sp)
  } else {
    panic("filewrite");
  }

  return ret;
}
    80004910:	60e6                	ld	ra,88(sp)
    80004912:	6446                	ld	s0,80(sp)
    80004914:	6906                	ld	s2,64(sp)
    80004916:	7aa2                	ld	s5,40(sp)
    80004918:	7b02                	ld	s6,32(sp)
    8000491a:	6125                	addi	sp,sp,96
    8000491c:	8082                	ret
    8000491e:	e4a6                	sd	s1,72(sp)
    80004920:	fc4e                	sd	s3,56(sp)
    80004922:	f852                	sd	s4,48(sp)
    80004924:	ec5e                	sd	s7,24(sp)
    80004926:	e862                	sd	s8,16(sp)
    80004928:	e466                	sd	s9,8(sp)
    panic("filewrite");
    8000492a:	00004517          	auipc	a0,0x4
    8000492e:	c9650513          	addi	a0,a0,-874 # 800085c0 <etext+0x5c0>
    80004932:	f25fb0ef          	jal	80000856 <panic>
    return -1;
    80004936:	557d                	li	a0,-1
}
    80004938:	8082                	ret
      return -1;
    8000493a:	557d                	li	a0,-1
    8000493c:	bfd1                	j	80004910 <filewrite+0xfc>
    8000493e:	557d                	li	a0,-1
    80004940:	bfc1                	j	80004910 <filewrite+0xfc>
    ret = (i == n ? n : -1);
    80004942:	557d                	li	a0,-1
    80004944:	7a42                	ld	s4,48(sp)
    80004946:	b7e9                	j	80004910 <filewrite+0xfc>

0000000080004948 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80004948:	7179                	addi	sp,sp,-48
    8000494a:	f406                	sd	ra,40(sp)
    8000494c:	f022                	sd	s0,32(sp)
    8000494e:	ec26                	sd	s1,24(sp)
    80004950:	e052                	sd	s4,0(sp)
    80004952:	1800                	addi	s0,sp,48
    80004954:	84aa                	mv	s1,a0
    80004956:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80004958:	0005b023          	sd	zero,0(a1)
    8000495c:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80004960:	c29ff0ef          	jal	80004588 <filealloc>
    80004964:	e088                	sd	a0,0(s1)
    80004966:	c549                	beqz	a0,800049f0 <pipealloc+0xa8>
    80004968:	c21ff0ef          	jal	80004588 <filealloc>
    8000496c:	00aa3023          	sd	a0,0(s4)
    80004970:	cd25                	beqz	a0,800049e8 <pipealloc+0xa0>
    80004972:	e84a                	sd	s2,16(sp)
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80004974:	a60fc0ef          	jal	80000bd4 <kalloc>
    80004978:	892a                	mv	s2,a0
    8000497a:	c12d                	beqz	a0,800049dc <pipealloc+0x94>
    8000497c:	e44e                	sd	s3,8(sp)
    goto bad;
  pi->readopen = 1;
    8000497e:	4985                	li	s3,1
    80004980:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    80004984:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    80004988:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    8000498c:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80004990:	00004597          	auipc	a1,0x4
    80004994:	c4058593          	addi	a1,a1,-960 # 800085d0 <etext+0x5d0>
    80004998:	af4fc0ef          	jal	80000c8c <initlock>
  (*f0)->type = FD_PIPE;
    8000499c:	609c                	ld	a5,0(s1)
    8000499e:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    800049a2:	609c                	ld	a5,0(s1)
    800049a4:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    800049a8:	609c                	ld	a5,0(s1)
    800049aa:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    800049ae:	609c                	ld	a5,0(s1)
    800049b0:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    800049b4:	000a3783          	ld	a5,0(s4)
    800049b8:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    800049bc:	000a3783          	ld	a5,0(s4)
    800049c0:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    800049c4:	000a3783          	ld	a5,0(s4)
    800049c8:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    800049cc:	000a3783          	ld	a5,0(s4)
    800049d0:	0127b823          	sd	s2,16(a5)
  return 0;
    800049d4:	4501                	li	a0,0
    800049d6:	6942                	ld	s2,16(sp)
    800049d8:	69a2                	ld	s3,8(sp)
    800049da:	a01d                	j	80004a00 <pipealloc+0xb8>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    800049dc:	6088                	ld	a0,0(s1)
    800049de:	c119                	beqz	a0,800049e4 <pipealloc+0x9c>
    800049e0:	6942                	ld	s2,16(sp)
    800049e2:	a029                	j	800049ec <pipealloc+0xa4>
    800049e4:	6942                	ld	s2,16(sp)
    800049e6:	a029                	j	800049f0 <pipealloc+0xa8>
    800049e8:	6088                	ld	a0,0(s1)
    800049ea:	c10d                	beqz	a0,80004a0c <pipealloc+0xc4>
    fileclose(*f0);
    800049ec:	c41ff0ef          	jal	8000462c <fileclose>
  if(*f1)
    800049f0:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    800049f4:	557d                	li	a0,-1
  if(*f1)
    800049f6:	c789                	beqz	a5,80004a00 <pipealloc+0xb8>
    fileclose(*f1);
    800049f8:	853e                	mv	a0,a5
    800049fa:	c33ff0ef          	jal	8000462c <fileclose>
  return -1;
    800049fe:	557d                	li	a0,-1
}
    80004a00:	70a2                	ld	ra,40(sp)
    80004a02:	7402                	ld	s0,32(sp)
    80004a04:	64e2                	ld	s1,24(sp)
    80004a06:	6a02                	ld	s4,0(sp)
    80004a08:	6145                	addi	sp,sp,48
    80004a0a:	8082                	ret
  return -1;
    80004a0c:	557d                	li	a0,-1
    80004a0e:	bfcd                	j	80004a00 <pipealloc+0xb8>

0000000080004a10 <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80004a10:	1101                	addi	sp,sp,-32
    80004a12:	ec06                	sd	ra,24(sp)
    80004a14:	e822                	sd	s0,16(sp)
    80004a16:	e426                	sd	s1,8(sp)
    80004a18:	e04a                	sd	s2,0(sp)
    80004a1a:	1000                	addi	s0,sp,32
    80004a1c:	84aa                	mv	s1,a0
    80004a1e:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80004a20:	af6fc0ef          	jal	80000d16 <acquire>
  if(writable){
    80004a24:	02090763          	beqz	s2,80004a52 <pipeclose+0x42>
    pi->writeopen = 0;
    80004a28:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80004a2c:	21848513          	addi	a0,s1,536
    80004a30:	a71fd0ef          	jal	800024a0 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80004a34:	2204a783          	lw	a5,544(s1)
    80004a38:	e781                	bnez	a5,80004a40 <pipeclose+0x30>
    80004a3a:	2244a783          	lw	a5,548(s1)
    80004a3e:	c38d                	beqz	a5,80004a60 <pipeclose+0x50>
    release(&pi->lock);
    kfree((char*)pi);
  } else
    release(&pi->lock);
    80004a40:	8526                	mv	a0,s1
    80004a42:	b68fc0ef          	jal	80000daa <release>
}
    80004a46:	60e2                	ld	ra,24(sp)
    80004a48:	6442                	ld	s0,16(sp)
    80004a4a:	64a2                	ld	s1,8(sp)
    80004a4c:	6902                	ld	s2,0(sp)
    80004a4e:	6105                	addi	sp,sp,32
    80004a50:	8082                	ret
    pi->readopen = 0;
    80004a52:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80004a56:	21c48513          	addi	a0,s1,540
    80004a5a:	a47fd0ef          	jal	800024a0 <wakeup>
    80004a5e:	bfd9                	j	80004a34 <pipeclose+0x24>
    release(&pi->lock);
    80004a60:	8526                	mv	a0,s1
    80004a62:	b48fc0ef          	jal	80000daa <release>
    kfree((char*)pi);
    80004a66:	8526                	mv	a0,s1
    80004a68:	826fc0ef          	jal	80000a8e <kfree>
    80004a6c:	bfe9                	j	80004a46 <pipeclose+0x36>

0000000080004a6e <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80004a6e:	7159                	addi	sp,sp,-112
    80004a70:	f486                	sd	ra,104(sp)
    80004a72:	f0a2                	sd	s0,96(sp)
    80004a74:	eca6                	sd	s1,88(sp)
    80004a76:	e8ca                	sd	s2,80(sp)
    80004a78:	e4ce                	sd	s3,72(sp)
    80004a7a:	e0d2                	sd	s4,64(sp)
    80004a7c:	fc56                	sd	s5,56(sp)
    80004a7e:	1880                	addi	s0,sp,112
    80004a80:	84aa                	mv	s1,a0
    80004a82:	8aae                	mv	s5,a1
    80004a84:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    80004a86:	9a2fd0ef          	jal	80001c28 <myproc>
    80004a8a:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    80004a8c:	8526                	mv	a0,s1
    80004a8e:	a88fc0ef          	jal	80000d16 <acquire>
  while(i < n){
    80004a92:	0d405263          	blez	s4,80004b56 <pipewrite+0xe8>
    80004a96:	f85a                	sd	s6,48(sp)
    80004a98:	f45e                	sd	s7,40(sp)
    80004a9a:	f062                	sd	s8,32(sp)
    80004a9c:	ec66                	sd	s9,24(sp)
    80004a9e:	e86a                	sd	s10,16(sp)
  int i = 0;
    80004aa0:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004aa2:	f9f40c13          	addi	s8,s0,-97
    80004aa6:	4b85                	li	s7,1
    80004aa8:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    80004aaa:	21848d13          	addi	s10,s1,536
      sleep(&pi->nwrite, &pi->lock);
    80004aae:	21c48c93          	addi	s9,s1,540
    80004ab2:	a82d                	j	80004aec <pipewrite+0x7e>
      release(&pi->lock);
    80004ab4:	8526                	mv	a0,s1
    80004ab6:	af4fc0ef          	jal	80000daa <release>
      return -1;
    80004aba:	597d                	li	s2,-1
    80004abc:	7b42                	ld	s6,48(sp)
    80004abe:	7ba2                	ld	s7,40(sp)
    80004ac0:	7c02                	ld	s8,32(sp)
    80004ac2:	6ce2                	ld	s9,24(sp)
    80004ac4:	6d42                	ld	s10,16(sp)
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    80004ac6:	854a                	mv	a0,s2
    80004ac8:	70a6                	ld	ra,104(sp)
    80004aca:	7406                	ld	s0,96(sp)
    80004acc:	64e6                	ld	s1,88(sp)
    80004ace:	6946                	ld	s2,80(sp)
    80004ad0:	69a6                	ld	s3,72(sp)
    80004ad2:	6a06                	ld	s4,64(sp)
    80004ad4:	7ae2                	ld	s5,56(sp)
    80004ad6:	6165                	addi	sp,sp,112
    80004ad8:	8082                	ret
      wakeup(&pi->nread);
    80004ada:	856a                	mv	a0,s10
    80004adc:	9c5fd0ef          	jal	800024a0 <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80004ae0:	85a6                	mv	a1,s1
    80004ae2:	8566                	mv	a0,s9
    80004ae4:	971fd0ef          	jal	80002454 <sleep>
  while(i < n){
    80004ae8:	05495a63          	bge	s2,s4,80004b3c <pipewrite+0xce>
    if(pi->readopen == 0 || killed(pr)){
    80004aec:	2204a783          	lw	a5,544(s1)
    80004af0:	d3f1                	beqz	a5,80004ab4 <pipewrite+0x46>
    80004af2:	854e                	mv	a0,s3
    80004af4:	b9dfd0ef          	jal	80002690 <killed>
    80004af8:	fd55                	bnez	a0,80004ab4 <pipewrite+0x46>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    80004afa:	2184a783          	lw	a5,536(s1)
    80004afe:	21c4a703          	lw	a4,540(s1)
    80004b02:	2007879b          	addiw	a5,a5,512
    80004b06:	fcf70ae3          	beq	a4,a5,80004ada <pipewrite+0x6c>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004b0a:	86de                	mv	a3,s7
    80004b0c:	01590633          	add	a2,s2,s5
    80004b10:	85e2                	mv	a1,s8
    80004b12:	0509b503          	ld	a0,80(s3)
    80004b16:	ee3fc0ef          	jal	800019f8 <copyin>
    80004b1a:	05650063          	beq	a0,s6,80004b5a <pipewrite+0xec>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80004b1e:	21c4a783          	lw	a5,540(s1)
    80004b22:	0017871b          	addiw	a4,a5,1
    80004b26:	20e4ae23          	sw	a4,540(s1)
    80004b2a:	1ff7f793          	andi	a5,a5,511
    80004b2e:	97a6                	add	a5,a5,s1
    80004b30:	f9f44703          	lbu	a4,-97(s0)
    80004b34:	00e78c23          	sb	a4,24(a5)
      i++;
    80004b38:	2905                	addiw	s2,s2,1
    80004b3a:	b77d                	j	80004ae8 <pipewrite+0x7a>
    80004b3c:	7b42                	ld	s6,48(sp)
    80004b3e:	7ba2                	ld	s7,40(sp)
    80004b40:	7c02                	ld	s8,32(sp)
    80004b42:	6ce2                	ld	s9,24(sp)
    80004b44:	6d42                	ld	s10,16(sp)
  wakeup(&pi->nread);
    80004b46:	21848513          	addi	a0,s1,536
    80004b4a:	957fd0ef          	jal	800024a0 <wakeup>
  release(&pi->lock);
    80004b4e:	8526                	mv	a0,s1
    80004b50:	a5afc0ef          	jal	80000daa <release>
  return i;
    80004b54:	bf8d                	j	80004ac6 <pipewrite+0x58>
  int i = 0;
    80004b56:	4901                	li	s2,0
    80004b58:	b7fd                	j	80004b46 <pipewrite+0xd8>
    80004b5a:	7b42                	ld	s6,48(sp)
    80004b5c:	7ba2                	ld	s7,40(sp)
    80004b5e:	7c02                	ld	s8,32(sp)
    80004b60:	6ce2                	ld	s9,24(sp)
    80004b62:	6d42                	ld	s10,16(sp)
    80004b64:	b7cd                	j	80004b46 <pipewrite+0xd8>

0000000080004b66 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80004b66:	711d                	addi	sp,sp,-96
    80004b68:	ec86                	sd	ra,88(sp)
    80004b6a:	e8a2                	sd	s0,80(sp)
    80004b6c:	e4a6                	sd	s1,72(sp)
    80004b6e:	e0ca                	sd	s2,64(sp)
    80004b70:	fc4e                	sd	s3,56(sp)
    80004b72:	f852                	sd	s4,48(sp)
    80004b74:	f456                	sd	s5,40(sp)
    80004b76:	1080                	addi	s0,sp,96
    80004b78:	84aa                	mv	s1,a0
    80004b7a:	892e                	mv	s2,a1
    80004b7c:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80004b7e:	8aafd0ef          	jal	80001c28 <myproc>
    80004b82:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80004b84:	8526                	mv	a0,s1
    80004b86:	990fc0ef          	jal	80000d16 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004b8a:	2184a703          	lw	a4,536(s1)
    80004b8e:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004b92:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004b96:	02f71763          	bne	a4,a5,80004bc4 <piperead+0x5e>
    80004b9a:	2244a783          	lw	a5,548(s1)
    80004b9e:	cf85                	beqz	a5,80004bd6 <piperead+0x70>
    if(killed(pr)){
    80004ba0:	8552                	mv	a0,s4
    80004ba2:	aeffd0ef          	jal	80002690 <killed>
    80004ba6:	e11d                	bnez	a0,80004bcc <piperead+0x66>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004ba8:	85a6                	mv	a1,s1
    80004baa:	854e                	mv	a0,s3
    80004bac:	8a9fd0ef          	jal	80002454 <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004bb0:	2184a703          	lw	a4,536(s1)
    80004bb4:	21c4a783          	lw	a5,540(s1)
    80004bb8:	fef701e3          	beq	a4,a5,80004b9a <piperead+0x34>
    80004bbc:	f05a                	sd	s6,32(sp)
    80004bbe:	ec5e                	sd	s7,24(sp)
    80004bc0:	e862                	sd	s8,16(sp)
    80004bc2:	a829                	j	80004bdc <piperead+0x76>
    80004bc4:	f05a                	sd	s6,32(sp)
    80004bc6:	ec5e                	sd	s7,24(sp)
    80004bc8:	e862                	sd	s8,16(sp)
    80004bca:	a809                	j	80004bdc <piperead+0x76>
      release(&pi->lock);
    80004bcc:	8526                	mv	a0,s1
    80004bce:	9dcfc0ef          	jal	80000daa <release>
      return -1;
    80004bd2:	59fd                	li	s3,-1
    80004bd4:	a0a5                	j	80004c3c <piperead+0xd6>
    80004bd6:	f05a                	sd	s6,32(sp)
    80004bd8:	ec5e                	sd	s7,24(sp)
    80004bda:	e862                	sd	s8,16(sp)
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004bdc:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1) {
    80004bde:	faf40c13          	addi	s8,s0,-81
    80004be2:	4b85                	li	s7,1
    80004be4:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004be6:	05505163          	blez	s5,80004c28 <piperead+0xc2>
    if(pi->nread == pi->nwrite)
    80004bea:	2184a783          	lw	a5,536(s1)
    80004bee:	21c4a703          	lw	a4,540(s1)
    80004bf2:	02f70b63          	beq	a4,a5,80004c28 <piperead+0xc2>
    ch = pi->data[pi->nread % PIPESIZE];
    80004bf6:	1ff7f793          	andi	a5,a5,511
    80004bfa:	97a6                	add	a5,a5,s1
    80004bfc:	0187c783          	lbu	a5,24(a5)
    80004c00:	faf407a3          	sb	a5,-81(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1) {
    80004c04:	86de                	mv	a3,s7
    80004c06:	8662                	mv	a2,s8
    80004c08:	85ca                	mv	a1,s2
    80004c0a:	050a3503          	ld	a0,80(s4)
    80004c0e:	d2dfc0ef          	jal	8000193a <copyout>
    80004c12:	03650f63          	beq	a0,s6,80004c50 <piperead+0xea>
      if(i == 0)
        i = -1;
      break;
    }
    pi->nread++;
    80004c16:	2184a783          	lw	a5,536(s1)
    80004c1a:	2785                	addiw	a5,a5,1
    80004c1c:	20f4ac23          	sw	a5,536(s1)
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004c20:	2985                	addiw	s3,s3,1
    80004c22:	0905                	addi	s2,s2,1
    80004c24:	fd3a93e3          	bne	s5,s3,80004bea <piperead+0x84>
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80004c28:	21c48513          	addi	a0,s1,540
    80004c2c:	875fd0ef          	jal	800024a0 <wakeup>
  release(&pi->lock);
    80004c30:	8526                	mv	a0,s1
    80004c32:	978fc0ef          	jal	80000daa <release>
    80004c36:	7b02                	ld	s6,32(sp)
    80004c38:	6be2                	ld	s7,24(sp)
    80004c3a:	6c42                	ld	s8,16(sp)
  return i;
}
    80004c3c:	854e                	mv	a0,s3
    80004c3e:	60e6                	ld	ra,88(sp)
    80004c40:	6446                	ld	s0,80(sp)
    80004c42:	64a6                	ld	s1,72(sp)
    80004c44:	6906                	ld	s2,64(sp)
    80004c46:	79e2                	ld	s3,56(sp)
    80004c48:	7a42                	ld	s4,48(sp)
    80004c4a:	7aa2                	ld	s5,40(sp)
    80004c4c:	6125                	addi	sp,sp,96
    80004c4e:	8082                	ret
      if(i == 0)
    80004c50:	fc099ce3          	bnez	s3,80004c28 <piperead+0xc2>
        i = -1;
    80004c54:	89aa                	mv	s3,a0
    80004c56:	bfc9                	j	80004c28 <piperead+0xc2>

0000000080004c58 <flags2perm>:

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

// map ELF permissions to PTE permission bits.
int flags2perm(int flags)
{
    80004c58:	1141                	addi	sp,sp,-16
    80004c5a:	e406                	sd	ra,8(sp)
    80004c5c:	e022                	sd	s0,0(sp)
    80004c5e:	0800                	addi	s0,sp,16
    80004c60:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    80004c62:	0035151b          	slliw	a0,a0,0x3
    80004c66:	8921                	andi	a0,a0,8
      perm = PTE_X;
    if(flags & 0x2)
    80004c68:	8b89                	andi	a5,a5,2
    80004c6a:	c399                	beqz	a5,80004c70 <flags2perm+0x18>
      perm |= PTE_W;
    80004c6c:	00456513          	ori	a0,a0,4
    return perm;
}
    80004c70:	60a2                	ld	ra,8(sp)
    80004c72:	6402                	ld	s0,0(sp)
    80004c74:	0141                	addi	sp,sp,16
    80004c76:	8082                	ret

0000000080004c78 <kexec>:
//
// the implementation of the exec() system call
//
int
kexec(char *path, char **argv)
{
    80004c78:	de010113          	addi	sp,sp,-544
    80004c7c:	20113c23          	sd	ra,536(sp)
    80004c80:	20813823          	sd	s0,528(sp)
    80004c84:	20913423          	sd	s1,520(sp)
    80004c88:	21213023          	sd	s2,512(sp)
    80004c8c:	1400                	addi	s0,sp,544
    80004c8e:	892a                	mv	s2,a0
    80004c90:	dea43823          	sd	a0,-528(s0)
    80004c94:	e0b43023          	sd	a1,-512(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80004c98:	f91fc0ef          	jal	80001c28 <myproc>
    80004c9c:	84aa                	mv	s1,a0

  begin_op();
    80004c9e:	d6aff0ef          	jal	80004208 <begin_op>

  // Open the executable file.
  if((ip = namei(path)) == 0){
    80004ca2:	854a                	mv	a0,s2
    80004ca4:	b86ff0ef          	jal	8000402a <namei>
    80004ca8:	cd21                	beqz	a0,80004d00 <kexec+0x88>
    80004caa:	fbd2                	sd	s4,496(sp)
    80004cac:	8a2a                	mv	s4,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80004cae:	b4ffe0ef          	jal	800037fc <ilock>

  // Read the ELF header.
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80004cb2:	04000713          	li	a4,64
    80004cb6:	4681                	li	a3,0
    80004cb8:	e5040613          	addi	a2,s0,-432
    80004cbc:	4581                	li	a1,0
    80004cbe:	8552                	mv	a0,s4
    80004cc0:	ecffe0ef          	jal	80003b8e <readi>
    80004cc4:	04000793          	li	a5,64
    80004cc8:	00f51a63          	bne	a0,a5,80004cdc <kexec+0x64>
    goto bad;

  // Is this really an ELF file?
  if(elf.magic != ELF_MAGIC)
    80004ccc:	e5042703          	lw	a4,-432(s0)
    80004cd0:	464c47b7          	lui	a5,0x464c4
    80004cd4:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80004cd8:	02f70863          	beq	a4,a5,80004d08 <kexec+0x90>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    80004cdc:	8552                	mv	a0,s4
    80004cde:	d2bfe0ef          	jal	80003a08 <iunlockput>
    end_op();
    80004ce2:	d96ff0ef          	jal	80004278 <end_op>
  }
  return -1;
    80004ce6:	557d                	li	a0,-1
    80004ce8:	7a5e                	ld	s4,496(sp)
}
    80004cea:	21813083          	ld	ra,536(sp)
    80004cee:	21013403          	ld	s0,528(sp)
    80004cf2:	20813483          	ld	s1,520(sp)
    80004cf6:	20013903          	ld	s2,512(sp)
    80004cfa:	22010113          	addi	sp,sp,544
    80004cfe:	8082                	ret
    end_op();
    80004d00:	d78ff0ef          	jal	80004278 <end_op>
    return -1;
    80004d04:	557d                	li	a0,-1
    80004d06:	b7d5                	j	80004cea <kexec+0x72>
    80004d08:	f3da                	sd	s6,480(sp)
  if((pagetable = proc_pagetable(p)) == 0)
    80004d0a:	8526                	mv	a0,s1
    80004d0c:	826fd0ef          	jal	80001d32 <proc_pagetable>
    80004d10:	8b2a                	mv	s6,a0
    80004d12:	26050f63          	beqz	a0,80004f90 <kexec+0x318>
    80004d16:	ffce                	sd	s3,504(sp)
    80004d18:	f7d6                	sd	s5,488(sp)
    80004d1a:	efde                	sd	s7,472(sp)
    80004d1c:	ebe2                	sd	s8,464(sp)
    80004d1e:	e7e6                	sd	s9,456(sp)
    80004d20:	e3ea                	sd	s10,448(sp)
    80004d22:	ff6e                	sd	s11,440(sp)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004d24:	e8845783          	lhu	a5,-376(s0)
    80004d28:	0e078963          	beqz	a5,80004e1a <kexec+0x1a2>
    80004d2c:	e7042683          	lw	a3,-400(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004d30:	4901                	li	s2,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004d32:	4d01                	li	s10,0
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80004d34:	03800d93          	li	s11,56
    if(ph.vaddr % PGSIZE != 0)
    80004d38:	6c85                	lui	s9,0x1
    80004d3a:	fffc8793          	addi	a5,s9,-1 # fff <_entry-0x7ffff001>
    80004d3e:	def43423          	sd	a5,-536(s0)

  for(i = 0; i < sz; i += PGSIZE){
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    if(sz - i < PGSIZE)
    80004d42:	6a85                	lui	s5,0x1
    80004d44:	a085                	j	80004da4 <kexec+0x12c>
      panic("loadseg: address should exist");
    80004d46:	00004517          	auipc	a0,0x4
    80004d4a:	89250513          	addi	a0,a0,-1902 # 800085d8 <etext+0x5d8>
    80004d4e:	b09fb0ef          	jal	80000856 <panic>
    if(sz - i < PGSIZE)
    80004d52:	2901                	sext.w	s2,s2
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80004d54:	874a                	mv	a4,s2
    80004d56:	009b86bb          	addw	a3,s7,s1
    80004d5a:	4581                	li	a1,0
    80004d5c:	8552                	mv	a0,s4
    80004d5e:	e31fe0ef          	jal	80003b8e <readi>
    80004d62:	22a91b63          	bne	s2,a0,80004f98 <kexec+0x320>
  for(i = 0; i < sz; i += PGSIZE){
    80004d66:	009a84bb          	addw	s1,s5,s1
    80004d6a:	0334f263          	bgeu	s1,s3,80004d8e <kexec+0x116>
    pa = walkaddr(pagetable, va + i);
    80004d6e:	02049593          	slli	a1,s1,0x20
    80004d72:	9181                	srli	a1,a1,0x20
    80004d74:	95e2                	add	a1,a1,s8
    80004d76:	855a                	mv	a0,s6
    80004d78:	ba8fc0ef          	jal	80001120 <walkaddr>
    80004d7c:	862a                	mv	a2,a0
    if(pa == 0)
    80004d7e:	d561                	beqz	a0,80004d46 <kexec+0xce>
    if(sz - i < PGSIZE)
    80004d80:	409987bb          	subw	a5,s3,s1
    80004d84:	893e                	mv	s2,a5
    80004d86:	fcfcf6e3          	bgeu	s9,a5,80004d52 <kexec+0xda>
    80004d8a:	8956                	mv	s2,s5
    80004d8c:	b7d9                	j	80004d52 <kexec+0xda>
    sz = sz1;
    80004d8e:	df843903          	ld	s2,-520(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004d92:	2d05                	addiw	s10,s10,1
    80004d94:	e0843783          	ld	a5,-504(s0)
    80004d98:	0387869b          	addiw	a3,a5,56
    80004d9c:	e8845783          	lhu	a5,-376(s0)
    80004da0:	06fd5e63          	bge	s10,a5,80004e1c <kexec+0x1a4>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80004da4:	e0d43423          	sd	a3,-504(s0)
    80004da8:	876e                	mv	a4,s11
    80004daa:	e1840613          	addi	a2,s0,-488
    80004dae:	4581                	li	a1,0
    80004db0:	8552                	mv	a0,s4
    80004db2:	dddfe0ef          	jal	80003b8e <readi>
    80004db6:	1db51f63          	bne	a0,s11,80004f94 <kexec+0x31c>
    if(ph.type != ELF_PROG_LOAD)
    80004dba:	e1842783          	lw	a5,-488(s0)
    80004dbe:	4705                	li	a4,1
    80004dc0:	fce799e3          	bne	a5,a4,80004d92 <kexec+0x11a>
    if(ph.memsz < ph.filesz)
    80004dc4:	e4043483          	ld	s1,-448(s0)
    80004dc8:	e3843783          	ld	a5,-456(s0)
    80004dcc:	1ef4e463          	bltu	s1,a5,80004fb4 <kexec+0x33c>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    80004dd0:	e2843783          	ld	a5,-472(s0)
    80004dd4:	94be                	add	s1,s1,a5
    80004dd6:	1ef4e263          	bltu	s1,a5,80004fba <kexec+0x342>
    if(ph.vaddr % PGSIZE != 0)
    80004dda:	de843703          	ld	a4,-536(s0)
    80004dde:	8ff9                	and	a5,a5,a4
    80004de0:	1e079063          	bnez	a5,80004fc0 <kexec+0x348>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80004de4:	e1c42503          	lw	a0,-484(s0)
    80004de8:	e71ff0ef          	jal	80004c58 <flags2perm>
    80004dec:	86aa                	mv	a3,a0
    80004dee:	8626                	mv	a2,s1
    80004df0:	85ca                	mv	a1,s2
    80004df2:	855a                	mv	a0,s6
    80004df4:	f18fc0ef          	jal	8000150c <uvmalloc>
    80004df8:	dea43c23          	sd	a0,-520(s0)
    80004dfc:	1c050563          	beqz	a0,80004fc6 <kexec+0x34e>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80004e00:	e3842983          	lw	s3,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    80004e04:	00098863          	beqz	s3,80004e14 <kexec+0x19c>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80004e08:	e2843c03          	ld	s8,-472(s0)
    80004e0c:	e2042b83          	lw	s7,-480(s0)
  for(i = 0; i < sz; i += PGSIZE){
    80004e10:	4481                	li	s1,0
    80004e12:	bfb1                	j	80004d6e <kexec+0xf6>
    sz = sz1;
    80004e14:	df843903          	ld	s2,-520(s0)
    80004e18:	bfad                	j	80004d92 <kexec+0x11a>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004e1a:	4901                	li	s2,0
  iunlockput(ip);
    80004e1c:	8552                	mv	a0,s4
    80004e1e:	bebfe0ef          	jal	80003a08 <iunlockput>
  end_op();
    80004e22:	c56ff0ef          	jal	80004278 <end_op>
  p = myproc();
    80004e26:	e03fc0ef          	jal	80001c28 <myproc>
    80004e2a:	8aaa                	mv	s5,a0
  uint64 oldsz = p->sz;
    80004e2c:	04853d03          	ld	s10,72(a0)
  sz = PGROUNDUP(sz);
    80004e30:	6985                	lui	s3,0x1
    80004e32:	19fd                	addi	s3,s3,-1 # fff <_entry-0x7ffff001>
    80004e34:	99ca                	add	s3,s3,s2
    80004e36:	77fd                	lui	a5,0xfffff
    80004e38:	00f9f9b3          	and	s3,s3,a5
  if((sz1 = uvmalloc(pagetable, sz, sz + (USERSTACK+1)*PGSIZE, PTE_W)) == 0)
    80004e3c:	4691                	li	a3,4
    80004e3e:	6609                	lui	a2,0x2
    80004e40:	964e                	add	a2,a2,s3
    80004e42:	85ce                	mv	a1,s3
    80004e44:	855a                	mv	a0,s6
    80004e46:	ec6fc0ef          	jal	8000150c <uvmalloc>
    80004e4a:	8a2a                	mv	s4,a0
    80004e4c:	e105                	bnez	a0,80004e6c <kexec+0x1f4>
    proc_freepagetable(pagetable, sz);
    80004e4e:	85ce                	mv	a1,s3
    80004e50:	855a                	mv	a0,s6
    80004e52:	f65fc0ef          	jal	80001db6 <proc_freepagetable>
  return -1;
    80004e56:	557d                	li	a0,-1
    80004e58:	79fe                	ld	s3,504(sp)
    80004e5a:	7a5e                	ld	s4,496(sp)
    80004e5c:	7abe                	ld	s5,488(sp)
    80004e5e:	7b1e                	ld	s6,480(sp)
    80004e60:	6bfe                	ld	s7,472(sp)
    80004e62:	6c5e                	ld	s8,464(sp)
    80004e64:	6cbe                	ld	s9,456(sp)
    80004e66:	6d1e                	ld	s10,448(sp)
    80004e68:	7dfa                	ld	s11,440(sp)
    80004e6a:	b541                	j	80004cea <kexec+0x72>
  uvmclear(pagetable, sz-(USERSTACK+1)*PGSIZE);
    80004e6c:	75f9                	lui	a1,0xffffe
    80004e6e:	95aa                	add	a1,a1,a0
    80004e70:	855a                	mv	a0,s6
    80004e72:	8effc0ef          	jal	80001760 <uvmclear>
  stackbase = sp - USERSTACK*PGSIZE;
    80004e76:	800a0b93          	addi	s7,s4,-2048
    80004e7a:	800b8b93          	addi	s7,s7,-2048
  for(argc = 0; argv[argc]; argc++) {
    80004e7e:	e0043783          	ld	a5,-512(s0)
    80004e82:	6388                	ld	a0,0(a5)
  sp = sz;
    80004e84:	8952                	mv	s2,s4
  for(argc = 0; argv[argc]; argc++) {
    80004e86:	4481                	li	s1,0
    ustack[argc] = sp;
    80004e88:	e9040c93          	addi	s9,s0,-368
    if(argc >= MAXARG)
    80004e8c:	02000c13          	li	s8,32
  for(argc = 0; argv[argc]; argc++) {
    80004e90:	cd21                	beqz	a0,80004ee8 <kexec+0x270>
    sp -= strlen(argv[argc]) + 1;
    80004e92:	8defc0ef          	jal	80000f70 <strlen>
    80004e96:	0015079b          	addiw	a5,a0,1
    80004e9a:	40f907b3          	sub	a5,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80004e9e:	ff07f913          	andi	s2,a5,-16
    if(sp < stackbase)
    80004ea2:	13796563          	bltu	s2,s7,80004fcc <kexec+0x354>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80004ea6:	e0043d83          	ld	s11,-512(s0)
    80004eaa:	000db983          	ld	s3,0(s11)
    80004eae:	854e                	mv	a0,s3
    80004eb0:	8c0fc0ef          	jal	80000f70 <strlen>
    80004eb4:	0015069b          	addiw	a3,a0,1
    80004eb8:	864e                	mv	a2,s3
    80004eba:	85ca                	mv	a1,s2
    80004ebc:	855a                	mv	a0,s6
    80004ebe:	a7dfc0ef          	jal	8000193a <copyout>
    80004ec2:	10054763          	bltz	a0,80004fd0 <kexec+0x358>
    ustack[argc] = sp;
    80004ec6:	00349793          	slli	a5,s1,0x3
    80004eca:	97e6                	add	a5,a5,s9
    80004ecc:	0127b023          	sd	s2,0(a5) # fffffffffffff000 <end+0xffffffff7ffb5448>
  for(argc = 0; argv[argc]; argc++) {
    80004ed0:	0485                	addi	s1,s1,1
    80004ed2:	008d8793          	addi	a5,s11,8
    80004ed6:	e0f43023          	sd	a5,-512(s0)
    80004eda:	008db503          	ld	a0,8(s11)
    80004ede:	c509                	beqz	a0,80004ee8 <kexec+0x270>
    if(argc >= MAXARG)
    80004ee0:	fb8499e3          	bne	s1,s8,80004e92 <kexec+0x21a>
  sz = sz1;
    80004ee4:	89d2                	mv	s3,s4
    80004ee6:	b7a5                	j	80004e4e <kexec+0x1d6>
  ustack[argc] = 0;
    80004ee8:	00349793          	slli	a5,s1,0x3
    80004eec:	f9078793          	addi	a5,a5,-112
    80004ef0:	97a2                	add	a5,a5,s0
    80004ef2:	f007b023          	sd	zero,-256(a5)
  sp -= (argc+1) * sizeof(uint64);
    80004ef6:	00349693          	slli	a3,s1,0x3
    80004efa:	06a1                	addi	a3,a3,8
    80004efc:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    80004f00:	ff097913          	andi	s2,s2,-16
  sz = sz1;
    80004f04:	89d2                	mv	s3,s4
  if(sp < stackbase)
    80004f06:	f57964e3          	bltu	s2,s7,80004e4e <kexec+0x1d6>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    80004f0a:	e9040613          	addi	a2,s0,-368
    80004f0e:	85ca                	mv	a1,s2
    80004f10:	855a                	mv	a0,s6
    80004f12:	a29fc0ef          	jal	8000193a <copyout>
    80004f16:	f2054ce3          	bltz	a0,80004e4e <kexec+0x1d6>
  p->trapframe->a1 = sp;
    80004f1a:	058ab783          	ld	a5,88(s5) # 1058 <_entry-0x7fffefa8>
    80004f1e:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    80004f22:	df043783          	ld	a5,-528(s0)
    80004f26:	0007c703          	lbu	a4,0(a5)
    80004f2a:	cf11                	beqz	a4,80004f46 <kexec+0x2ce>
    80004f2c:	0785                	addi	a5,a5,1
    if(*s == '/')
    80004f2e:	02f00693          	li	a3,47
    80004f32:	a029                	j	80004f3c <kexec+0x2c4>
  for(last=s=path; *s; s++)
    80004f34:	0785                	addi	a5,a5,1
    80004f36:	fff7c703          	lbu	a4,-1(a5)
    80004f3a:	c711                	beqz	a4,80004f46 <kexec+0x2ce>
    if(*s == '/')
    80004f3c:	fed71ce3          	bne	a4,a3,80004f34 <kexec+0x2bc>
      last = s+1;
    80004f40:	def43823          	sd	a5,-528(s0)
    80004f44:	bfc5                	j	80004f34 <kexec+0x2bc>
  safestrcpy(p->name, last, sizeof(p->name));
    80004f46:	4641                	li	a2,16
    80004f48:	df043583          	ld	a1,-528(s0)
    80004f4c:	158a8513          	addi	a0,s5,344
    80004f50:	febfb0ef          	jal	80000f3a <safestrcpy>
  oldpagetable = p->pagetable;
    80004f54:	050ab503          	ld	a0,80(s5)
  p->pagetable = pagetable;
    80004f58:	056ab823          	sd	s6,80(s5)
  p->sz = sz;
    80004f5c:	054ab423          	sd	s4,72(s5)
  p->trapframe->epc = elf.entry;  // initial program counter = ulib.c:start()
    80004f60:	058ab783          	ld	a5,88(s5)
    80004f64:	e6843703          	ld	a4,-408(s0)
    80004f68:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    80004f6a:	058ab783          	ld	a5,88(s5)
    80004f6e:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    80004f72:	85ea                	mv	a1,s10
    80004f74:	e43fc0ef          	jal	80001db6 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80004f78:	0004851b          	sext.w	a0,s1
    80004f7c:	79fe                	ld	s3,504(sp)
    80004f7e:	7a5e                	ld	s4,496(sp)
    80004f80:	7abe                	ld	s5,488(sp)
    80004f82:	7b1e                	ld	s6,480(sp)
    80004f84:	6bfe                	ld	s7,472(sp)
    80004f86:	6c5e                	ld	s8,464(sp)
    80004f88:	6cbe                	ld	s9,456(sp)
    80004f8a:	6d1e                	ld	s10,448(sp)
    80004f8c:	7dfa                	ld	s11,440(sp)
    80004f8e:	bbb1                	j	80004cea <kexec+0x72>
    80004f90:	7b1e                	ld	s6,480(sp)
    80004f92:	b3a9                	j	80004cdc <kexec+0x64>
    80004f94:	df243c23          	sd	s2,-520(s0)
    proc_freepagetable(pagetable, sz);
    80004f98:	df843583          	ld	a1,-520(s0)
    80004f9c:	855a                	mv	a0,s6
    80004f9e:	e19fc0ef          	jal	80001db6 <proc_freepagetable>
  if(ip){
    80004fa2:	79fe                	ld	s3,504(sp)
    80004fa4:	7abe                	ld	s5,488(sp)
    80004fa6:	7b1e                	ld	s6,480(sp)
    80004fa8:	6bfe                	ld	s7,472(sp)
    80004faa:	6c5e                	ld	s8,464(sp)
    80004fac:	6cbe                	ld	s9,456(sp)
    80004fae:	6d1e                	ld	s10,448(sp)
    80004fb0:	7dfa                	ld	s11,440(sp)
    80004fb2:	b32d                	j	80004cdc <kexec+0x64>
    80004fb4:	df243c23          	sd	s2,-520(s0)
    80004fb8:	b7c5                	j	80004f98 <kexec+0x320>
    80004fba:	df243c23          	sd	s2,-520(s0)
    80004fbe:	bfe9                	j	80004f98 <kexec+0x320>
    80004fc0:	df243c23          	sd	s2,-520(s0)
    80004fc4:	bfd1                	j	80004f98 <kexec+0x320>
    80004fc6:	df243c23          	sd	s2,-520(s0)
    80004fca:	b7f9                	j	80004f98 <kexec+0x320>
  sz = sz1;
    80004fcc:	89d2                	mv	s3,s4
    80004fce:	b541                	j	80004e4e <kexec+0x1d6>
    80004fd0:	89d2                	mv	s3,s4
    80004fd2:	bdb5                	j	80004e4e <kexec+0x1d6>

0000000080004fd4 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80004fd4:	7179                	addi	sp,sp,-48
    80004fd6:	f406                	sd	ra,40(sp)
    80004fd8:	f022                	sd	s0,32(sp)
    80004fda:	ec26                	sd	s1,24(sp)
    80004fdc:	e84a                	sd	s2,16(sp)
    80004fde:	1800                	addi	s0,sp,48
    80004fe0:	892e                	mv	s2,a1
    80004fe2:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    80004fe4:	fdc40593          	addi	a1,s0,-36
    80004fe8:	d79fd0ef          	jal	80002d60 <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    80004fec:	fdc42703          	lw	a4,-36(s0)
    80004ff0:	47bd                	li	a5,15
    80004ff2:	02e7ea63          	bltu	a5,a4,80005026 <argfd+0x52>
    80004ff6:	c33fc0ef          	jal	80001c28 <myproc>
    80004ffa:	fdc42703          	lw	a4,-36(s0)
    80004ffe:	00371793          	slli	a5,a4,0x3
    80005002:	0d078793          	addi	a5,a5,208
    80005006:	953e                	add	a0,a0,a5
    80005008:	611c                	ld	a5,0(a0)
    8000500a:	c385                	beqz	a5,8000502a <argfd+0x56>
    return -1;
  if(pfd)
    8000500c:	00090463          	beqz	s2,80005014 <argfd+0x40>
    *pfd = fd;
    80005010:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    80005014:	4501                	li	a0,0
  if(pf)
    80005016:	c091                	beqz	s1,8000501a <argfd+0x46>
    *pf = f;
    80005018:	e09c                	sd	a5,0(s1)
}
    8000501a:	70a2                	ld	ra,40(sp)
    8000501c:	7402                	ld	s0,32(sp)
    8000501e:	64e2                	ld	s1,24(sp)
    80005020:	6942                	ld	s2,16(sp)
    80005022:	6145                	addi	sp,sp,48
    80005024:	8082                	ret
    return -1;
    80005026:	557d                	li	a0,-1
    80005028:	bfcd                	j	8000501a <argfd+0x46>
    8000502a:	557d                	li	a0,-1
    8000502c:	b7fd                	j	8000501a <argfd+0x46>

000000008000502e <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    8000502e:	1101                	addi	sp,sp,-32
    80005030:	ec06                	sd	ra,24(sp)
    80005032:	e822                	sd	s0,16(sp)
    80005034:	e426                	sd	s1,8(sp)
    80005036:	1000                	addi	s0,sp,32
    80005038:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    8000503a:	beffc0ef          	jal	80001c28 <myproc>
    8000503e:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    80005040:	0d050793          	addi	a5,a0,208
    80005044:	4501                	li	a0,0
    80005046:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    80005048:	6398                	ld	a4,0(a5)
    8000504a:	cb19                	beqz	a4,80005060 <fdalloc+0x32>
  for(fd = 0; fd < NOFILE; fd++){
    8000504c:	2505                	addiw	a0,a0,1
    8000504e:	07a1                	addi	a5,a5,8
    80005050:	fed51ce3          	bne	a0,a3,80005048 <fdalloc+0x1a>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80005054:	557d                	li	a0,-1
}
    80005056:	60e2                	ld	ra,24(sp)
    80005058:	6442                	ld	s0,16(sp)
    8000505a:	64a2                	ld	s1,8(sp)
    8000505c:	6105                	addi	sp,sp,32
    8000505e:	8082                	ret
      p->ofile[fd] = f;
    80005060:	00351793          	slli	a5,a0,0x3
    80005064:	0d078793          	addi	a5,a5,208
    80005068:	963e                	add	a2,a2,a5
    8000506a:	e204                	sd	s1,0(a2)
      return fd;
    8000506c:	b7ed                	j	80005056 <fdalloc+0x28>

000000008000506e <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    8000506e:	715d                	addi	sp,sp,-80
    80005070:	e486                	sd	ra,72(sp)
    80005072:	e0a2                	sd	s0,64(sp)
    80005074:	fc26                	sd	s1,56(sp)
    80005076:	f84a                	sd	s2,48(sp)
    80005078:	f44e                	sd	s3,40(sp)
    8000507a:	f052                	sd	s4,32(sp)
    8000507c:	ec56                	sd	s5,24(sp)
    8000507e:	e85a                	sd	s6,16(sp)
    80005080:	0880                	addi	s0,sp,80
    80005082:	892e                	mv	s2,a1
    80005084:	8a2e                	mv	s4,a1
    80005086:	8ab2                	mv	s5,a2
    80005088:	8b36                	mv	s6,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    8000508a:	fb040593          	addi	a1,s0,-80
    8000508e:	fb7fe0ef          	jal	80004044 <nameiparent>
    80005092:	84aa                	mv	s1,a0
    80005094:	10050763          	beqz	a0,800051a2 <create+0x134>
    return 0;

  ilock(dp);
    80005098:	f64fe0ef          	jal	800037fc <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    8000509c:	4601                	li	a2,0
    8000509e:	fb040593          	addi	a1,s0,-80
    800050a2:	8526                	mv	a0,s1
    800050a4:	cf3fe0ef          	jal	80003d96 <dirlookup>
    800050a8:	89aa                	mv	s3,a0
    800050aa:	c131                	beqz	a0,800050ee <create+0x80>
    iunlockput(dp);
    800050ac:	8526                	mv	a0,s1
    800050ae:	95bfe0ef          	jal	80003a08 <iunlockput>
    ilock(ip);
    800050b2:	854e                	mv	a0,s3
    800050b4:	f48fe0ef          	jal	800037fc <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    800050b8:	4789                	li	a5,2
    800050ba:	02f91563          	bne	s2,a5,800050e4 <create+0x76>
    800050be:	0449d783          	lhu	a5,68(s3)
    800050c2:	37f9                	addiw	a5,a5,-2
    800050c4:	17c2                	slli	a5,a5,0x30
    800050c6:	93c1                	srli	a5,a5,0x30
    800050c8:	4705                	li	a4,1
    800050ca:	00f76d63          	bltu	a4,a5,800050e4 <create+0x76>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    800050ce:	854e                	mv	a0,s3
    800050d0:	60a6                	ld	ra,72(sp)
    800050d2:	6406                	ld	s0,64(sp)
    800050d4:	74e2                	ld	s1,56(sp)
    800050d6:	7942                	ld	s2,48(sp)
    800050d8:	79a2                	ld	s3,40(sp)
    800050da:	7a02                	ld	s4,32(sp)
    800050dc:	6ae2                	ld	s5,24(sp)
    800050de:	6b42                	ld	s6,16(sp)
    800050e0:	6161                	addi	sp,sp,80
    800050e2:	8082                	ret
    iunlockput(ip);
    800050e4:	854e                	mv	a0,s3
    800050e6:	923fe0ef          	jal	80003a08 <iunlockput>
    return 0;
    800050ea:	4981                	li	s3,0
    800050ec:	b7cd                	j	800050ce <create+0x60>
  if((ip = ialloc(dp->dev, type)) == 0){
    800050ee:	85ca                	mv	a1,s2
    800050f0:	4088                	lw	a0,0(s1)
    800050f2:	d9afe0ef          	jal	8000368c <ialloc>
    800050f6:	892a                	mv	s2,a0
    800050f8:	cd15                	beqz	a0,80005134 <create+0xc6>
  ilock(ip);
    800050fa:	f02fe0ef          	jal	800037fc <ilock>
  ip->major = major;
    800050fe:	05591323          	sh	s5,70(s2)
  ip->minor = minor;
    80005102:	05691423          	sh	s6,72(s2)
  ip->nlink = 1;
    80005106:	4785                	li	a5,1
    80005108:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    8000510c:	854a                	mv	a0,s2
    8000510e:	e3afe0ef          	jal	80003748 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    80005112:	4705                	li	a4,1
    80005114:	02ea0463          	beq	s4,a4,8000513c <create+0xce>
  if(dirlink(dp, name, ip->inum) < 0)
    80005118:	00492603          	lw	a2,4(s2)
    8000511c:	fb040593          	addi	a1,s0,-80
    80005120:	8526                	mv	a0,s1
    80005122:	e5ffe0ef          	jal	80003f80 <dirlink>
    80005126:	06054263          	bltz	a0,8000518a <create+0x11c>
  iunlockput(dp);
    8000512a:	8526                	mv	a0,s1
    8000512c:	8ddfe0ef          	jal	80003a08 <iunlockput>
  return ip;
    80005130:	89ca                	mv	s3,s2
    80005132:	bf71                	j	800050ce <create+0x60>
    iunlockput(dp);
    80005134:	8526                	mv	a0,s1
    80005136:	8d3fe0ef          	jal	80003a08 <iunlockput>
    return 0;
    8000513a:	bf51                	j	800050ce <create+0x60>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    8000513c:	00492603          	lw	a2,4(s2)
    80005140:	00003597          	auipc	a1,0x3
    80005144:	4b858593          	addi	a1,a1,1208 # 800085f8 <etext+0x5f8>
    80005148:	854a                	mv	a0,s2
    8000514a:	e37fe0ef          	jal	80003f80 <dirlink>
    8000514e:	02054e63          	bltz	a0,8000518a <create+0x11c>
    80005152:	40d0                	lw	a2,4(s1)
    80005154:	00003597          	auipc	a1,0x3
    80005158:	4ac58593          	addi	a1,a1,1196 # 80008600 <etext+0x600>
    8000515c:	854a                	mv	a0,s2
    8000515e:	e23fe0ef          	jal	80003f80 <dirlink>
    80005162:	02054463          	bltz	a0,8000518a <create+0x11c>
  if(dirlink(dp, name, ip->inum) < 0)
    80005166:	00492603          	lw	a2,4(s2)
    8000516a:	fb040593          	addi	a1,s0,-80
    8000516e:	8526                	mv	a0,s1
    80005170:	e11fe0ef          	jal	80003f80 <dirlink>
    80005174:	00054b63          	bltz	a0,8000518a <create+0x11c>
    dp->nlink++;  // for ".."
    80005178:	04a4d783          	lhu	a5,74(s1)
    8000517c:	2785                	addiw	a5,a5,1
    8000517e:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80005182:	8526                	mv	a0,s1
    80005184:	dc4fe0ef          	jal	80003748 <iupdate>
    80005188:	b74d                	j	8000512a <create+0xbc>
  ip->nlink = 0;
    8000518a:	04091523          	sh	zero,74(s2)
  iupdate(ip);
    8000518e:	854a                	mv	a0,s2
    80005190:	db8fe0ef          	jal	80003748 <iupdate>
  iunlockput(ip);
    80005194:	854a                	mv	a0,s2
    80005196:	873fe0ef          	jal	80003a08 <iunlockput>
  iunlockput(dp);
    8000519a:	8526                	mv	a0,s1
    8000519c:	86dfe0ef          	jal	80003a08 <iunlockput>
  return 0;
    800051a0:	b73d                	j	800050ce <create+0x60>
    return 0;
    800051a2:	89aa                	mv	s3,a0
    800051a4:	b72d                	j	800050ce <create+0x60>

00000000800051a6 <sys_dup>:
{
    800051a6:	7179                	addi	sp,sp,-48
    800051a8:	f406                	sd	ra,40(sp)
    800051aa:	f022                	sd	s0,32(sp)
    800051ac:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    800051ae:	fd840613          	addi	a2,s0,-40
    800051b2:	4581                	li	a1,0
    800051b4:	4501                	li	a0,0
    800051b6:	e1fff0ef          	jal	80004fd4 <argfd>
    return -1;
    800051ba:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    800051bc:	02054363          	bltz	a0,800051e2 <sys_dup+0x3c>
    800051c0:	ec26                	sd	s1,24(sp)
    800051c2:	e84a                	sd	s2,16(sp)
  if((fd=fdalloc(f)) < 0)
    800051c4:	fd843483          	ld	s1,-40(s0)
    800051c8:	8526                	mv	a0,s1
    800051ca:	e65ff0ef          	jal	8000502e <fdalloc>
    800051ce:	892a                	mv	s2,a0
    return -1;
    800051d0:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    800051d2:	00054d63          	bltz	a0,800051ec <sys_dup+0x46>
  filedup(f);
    800051d6:	8526                	mv	a0,s1
    800051d8:	c0eff0ef          	jal	800045e6 <filedup>
  return fd;
    800051dc:	87ca                	mv	a5,s2
    800051de:	64e2                	ld	s1,24(sp)
    800051e0:	6942                	ld	s2,16(sp)
}
    800051e2:	853e                	mv	a0,a5
    800051e4:	70a2                	ld	ra,40(sp)
    800051e6:	7402                	ld	s0,32(sp)
    800051e8:	6145                	addi	sp,sp,48
    800051ea:	8082                	ret
    800051ec:	64e2                	ld	s1,24(sp)
    800051ee:	6942                	ld	s2,16(sp)
    800051f0:	bfcd                	j	800051e2 <sys_dup+0x3c>

00000000800051f2 <sys_read>:
{
    800051f2:	7179                	addi	sp,sp,-48
    800051f4:	f406                	sd	ra,40(sp)
    800051f6:	f022                	sd	s0,32(sp)
    800051f8:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    800051fa:	fd840593          	addi	a1,s0,-40
    800051fe:	4505                	li	a0,1
    80005200:	b7dfd0ef          	jal	80002d7c <argaddr>
  argint(2, &n);
    80005204:	fe440593          	addi	a1,s0,-28
    80005208:	4509                	li	a0,2
    8000520a:	b57fd0ef          	jal	80002d60 <argint>
  if(argfd(0, 0, &f) < 0)
    8000520e:	fe840613          	addi	a2,s0,-24
    80005212:	4581                	li	a1,0
    80005214:	4501                	li	a0,0
    80005216:	dbfff0ef          	jal	80004fd4 <argfd>
    8000521a:	87aa                	mv	a5,a0
    return -1;
    8000521c:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    8000521e:	0007ca63          	bltz	a5,80005232 <sys_read+0x40>
  return fileread(f, p, n);
    80005222:	fe442603          	lw	a2,-28(s0)
    80005226:	fd843583          	ld	a1,-40(s0)
    8000522a:	fe843503          	ld	a0,-24(s0)
    8000522e:	d22ff0ef          	jal	80004750 <fileread>
}
    80005232:	70a2                	ld	ra,40(sp)
    80005234:	7402                	ld	s0,32(sp)
    80005236:	6145                	addi	sp,sp,48
    80005238:	8082                	ret

000000008000523a <sys_write>:
{
    8000523a:	7179                	addi	sp,sp,-48
    8000523c:	f406                	sd	ra,40(sp)
    8000523e:	f022                	sd	s0,32(sp)
    80005240:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80005242:	fd840593          	addi	a1,s0,-40
    80005246:	4505                	li	a0,1
    80005248:	b35fd0ef          	jal	80002d7c <argaddr>
  argint(2, &n);
    8000524c:	fe440593          	addi	a1,s0,-28
    80005250:	4509                	li	a0,2
    80005252:	b0ffd0ef          	jal	80002d60 <argint>
  if(argfd(0, 0, &f) < 0)
    80005256:	fe840613          	addi	a2,s0,-24
    8000525a:	4581                	li	a1,0
    8000525c:	4501                	li	a0,0
    8000525e:	d77ff0ef          	jal	80004fd4 <argfd>
    80005262:	87aa                	mv	a5,a0
    return -1;
    80005264:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80005266:	0007ca63          	bltz	a5,8000527a <sys_write+0x40>
  return filewrite(f, p, n);
    8000526a:	fe442603          	lw	a2,-28(s0)
    8000526e:	fd843583          	ld	a1,-40(s0)
    80005272:	fe843503          	ld	a0,-24(s0)
    80005276:	d9eff0ef          	jal	80004814 <filewrite>
}
    8000527a:	70a2                	ld	ra,40(sp)
    8000527c:	7402                	ld	s0,32(sp)
    8000527e:	6145                	addi	sp,sp,48
    80005280:	8082                	ret

0000000080005282 <sys_close>:
{
    80005282:	1101                	addi	sp,sp,-32
    80005284:	ec06                	sd	ra,24(sp)
    80005286:	e822                	sd	s0,16(sp)
    80005288:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    8000528a:	fe040613          	addi	a2,s0,-32
    8000528e:	fec40593          	addi	a1,s0,-20
    80005292:	4501                	li	a0,0
    80005294:	d41ff0ef          	jal	80004fd4 <argfd>
    return -1;
    80005298:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    8000529a:	02054163          	bltz	a0,800052bc <sys_close+0x3a>
  myproc()->ofile[fd] = 0;
    8000529e:	98bfc0ef          	jal	80001c28 <myproc>
    800052a2:	fec42783          	lw	a5,-20(s0)
    800052a6:	078e                	slli	a5,a5,0x3
    800052a8:	0d078793          	addi	a5,a5,208
    800052ac:	953e                	add	a0,a0,a5
    800052ae:	00053023          	sd	zero,0(a0)
  fileclose(f);
    800052b2:	fe043503          	ld	a0,-32(s0)
    800052b6:	b76ff0ef          	jal	8000462c <fileclose>
  return 0;
    800052ba:	4781                	li	a5,0
}
    800052bc:	853e                	mv	a0,a5
    800052be:	60e2                	ld	ra,24(sp)
    800052c0:	6442                	ld	s0,16(sp)
    800052c2:	6105                	addi	sp,sp,32
    800052c4:	8082                	ret

00000000800052c6 <sys_fstat>:
{
    800052c6:	1101                	addi	sp,sp,-32
    800052c8:	ec06                	sd	ra,24(sp)
    800052ca:	e822                	sd	s0,16(sp)
    800052cc:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    800052ce:	fe040593          	addi	a1,s0,-32
    800052d2:	4505                	li	a0,1
    800052d4:	aa9fd0ef          	jal	80002d7c <argaddr>
  if(argfd(0, 0, &f) < 0)
    800052d8:	fe840613          	addi	a2,s0,-24
    800052dc:	4581                	li	a1,0
    800052de:	4501                	li	a0,0
    800052e0:	cf5ff0ef          	jal	80004fd4 <argfd>
    800052e4:	87aa                	mv	a5,a0
    return -1;
    800052e6:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    800052e8:	0007c863          	bltz	a5,800052f8 <sys_fstat+0x32>
  return filestat(f, st);
    800052ec:	fe043583          	ld	a1,-32(s0)
    800052f0:	fe843503          	ld	a0,-24(s0)
    800052f4:	bfaff0ef          	jal	800046ee <filestat>
}
    800052f8:	60e2                	ld	ra,24(sp)
    800052fa:	6442                	ld	s0,16(sp)
    800052fc:	6105                	addi	sp,sp,32
    800052fe:	8082                	ret

0000000080005300 <sys_link>:
{
    80005300:	7169                	addi	sp,sp,-304
    80005302:	f606                	sd	ra,296(sp)
    80005304:	f222                	sd	s0,288(sp)
    80005306:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005308:	08000613          	li	a2,128
    8000530c:	ed040593          	addi	a1,s0,-304
    80005310:	4501                	li	a0,0
    80005312:	a87fd0ef          	jal	80002d98 <argstr>
    return -1;
    80005316:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005318:	0c054e63          	bltz	a0,800053f4 <sys_link+0xf4>
    8000531c:	08000613          	li	a2,128
    80005320:	f5040593          	addi	a1,s0,-176
    80005324:	4505                	li	a0,1
    80005326:	a73fd0ef          	jal	80002d98 <argstr>
    return -1;
    8000532a:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    8000532c:	0c054463          	bltz	a0,800053f4 <sys_link+0xf4>
    80005330:	ee26                	sd	s1,280(sp)
  begin_op();
    80005332:	ed7fe0ef          	jal	80004208 <begin_op>
  if((ip = namei(old)) == 0){
    80005336:	ed040513          	addi	a0,s0,-304
    8000533a:	cf1fe0ef          	jal	8000402a <namei>
    8000533e:	84aa                	mv	s1,a0
    80005340:	c53d                	beqz	a0,800053ae <sys_link+0xae>
  ilock(ip);
    80005342:	cbafe0ef          	jal	800037fc <ilock>
  if(ip->type == T_DIR){
    80005346:	04449703          	lh	a4,68(s1)
    8000534a:	4785                	li	a5,1
    8000534c:	06f70663          	beq	a4,a5,800053b8 <sys_link+0xb8>
    80005350:	ea4a                	sd	s2,272(sp)
  ip->nlink++;
    80005352:	04a4d783          	lhu	a5,74(s1)
    80005356:	2785                	addiw	a5,a5,1
    80005358:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    8000535c:	8526                	mv	a0,s1
    8000535e:	beafe0ef          	jal	80003748 <iupdate>
  iunlock(ip);
    80005362:	8526                	mv	a0,s1
    80005364:	d46fe0ef          	jal	800038aa <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    80005368:	fd040593          	addi	a1,s0,-48
    8000536c:	f5040513          	addi	a0,s0,-176
    80005370:	cd5fe0ef          	jal	80004044 <nameiparent>
    80005374:	892a                	mv	s2,a0
    80005376:	cd21                	beqz	a0,800053ce <sys_link+0xce>
  ilock(dp);
    80005378:	c84fe0ef          	jal	800037fc <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    8000537c:	854a                	mv	a0,s2
    8000537e:	00092703          	lw	a4,0(s2)
    80005382:	409c                	lw	a5,0(s1)
    80005384:	04f71263          	bne	a4,a5,800053c8 <sys_link+0xc8>
    80005388:	40d0                	lw	a2,4(s1)
    8000538a:	fd040593          	addi	a1,s0,-48
    8000538e:	bf3fe0ef          	jal	80003f80 <dirlink>
    80005392:	02054b63          	bltz	a0,800053c8 <sys_link+0xc8>
  iunlockput(dp);
    80005396:	854a                	mv	a0,s2
    80005398:	e70fe0ef          	jal	80003a08 <iunlockput>
  iput(ip);
    8000539c:	8526                	mv	a0,s1
    8000539e:	de0fe0ef          	jal	8000397e <iput>
  end_op();
    800053a2:	ed7fe0ef          	jal	80004278 <end_op>
  return 0;
    800053a6:	4781                	li	a5,0
    800053a8:	64f2                	ld	s1,280(sp)
    800053aa:	6952                	ld	s2,272(sp)
    800053ac:	a0a1                	j	800053f4 <sys_link+0xf4>
    end_op();
    800053ae:	ecbfe0ef          	jal	80004278 <end_op>
    return -1;
    800053b2:	57fd                	li	a5,-1
    800053b4:	64f2                	ld	s1,280(sp)
    800053b6:	a83d                	j	800053f4 <sys_link+0xf4>
    iunlockput(ip);
    800053b8:	8526                	mv	a0,s1
    800053ba:	e4efe0ef          	jal	80003a08 <iunlockput>
    end_op();
    800053be:	ebbfe0ef          	jal	80004278 <end_op>
    return -1;
    800053c2:	57fd                	li	a5,-1
    800053c4:	64f2                	ld	s1,280(sp)
    800053c6:	a03d                	j	800053f4 <sys_link+0xf4>
    iunlockput(dp);
    800053c8:	854a                	mv	a0,s2
    800053ca:	e3efe0ef          	jal	80003a08 <iunlockput>
  ilock(ip);
    800053ce:	8526                	mv	a0,s1
    800053d0:	c2cfe0ef          	jal	800037fc <ilock>
  ip->nlink--;
    800053d4:	04a4d783          	lhu	a5,74(s1)
    800053d8:	37fd                	addiw	a5,a5,-1
    800053da:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    800053de:	8526                	mv	a0,s1
    800053e0:	b68fe0ef          	jal	80003748 <iupdate>
  iunlockput(ip);
    800053e4:	8526                	mv	a0,s1
    800053e6:	e22fe0ef          	jal	80003a08 <iunlockput>
  end_op();
    800053ea:	e8ffe0ef          	jal	80004278 <end_op>
  return -1;
    800053ee:	57fd                	li	a5,-1
    800053f0:	64f2                	ld	s1,280(sp)
    800053f2:	6952                	ld	s2,272(sp)
}
    800053f4:	853e                	mv	a0,a5
    800053f6:	70b2                	ld	ra,296(sp)
    800053f8:	7412                	ld	s0,288(sp)
    800053fa:	6155                	addi	sp,sp,304
    800053fc:	8082                	ret

00000000800053fe <sys_unlink>:
{
    800053fe:	7151                	addi	sp,sp,-240
    80005400:	f586                	sd	ra,232(sp)
    80005402:	f1a2                	sd	s0,224(sp)
    80005404:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    80005406:	08000613          	li	a2,128
    8000540a:	f3040593          	addi	a1,s0,-208
    8000540e:	4501                	li	a0,0
    80005410:	989fd0ef          	jal	80002d98 <argstr>
    80005414:	14054d63          	bltz	a0,8000556e <sys_unlink+0x170>
    80005418:	eda6                	sd	s1,216(sp)
  begin_op();
    8000541a:	deffe0ef          	jal	80004208 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    8000541e:	fb040593          	addi	a1,s0,-80
    80005422:	f3040513          	addi	a0,s0,-208
    80005426:	c1ffe0ef          	jal	80004044 <nameiparent>
    8000542a:	84aa                	mv	s1,a0
    8000542c:	c955                	beqz	a0,800054e0 <sys_unlink+0xe2>
  ilock(dp);
    8000542e:	bcefe0ef          	jal	800037fc <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80005432:	00003597          	auipc	a1,0x3
    80005436:	1c658593          	addi	a1,a1,454 # 800085f8 <etext+0x5f8>
    8000543a:	fb040513          	addi	a0,s0,-80
    8000543e:	943fe0ef          	jal	80003d80 <namecmp>
    80005442:	10050b63          	beqz	a0,80005558 <sys_unlink+0x15a>
    80005446:	00003597          	auipc	a1,0x3
    8000544a:	1ba58593          	addi	a1,a1,442 # 80008600 <etext+0x600>
    8000544e:	fb040513          	addi	a0,s0,-80
    80005452:	92ffe0ef          	jal	80003d80 <namecmp>
    80005456:	10050163          	beqz	a0,80005558 <sys_unlink+0x15a>
    8000545a:	e9ca                	sd	s2,208(sp)
  if((ip = dirlookup(dp, name, &off)) == 0)
    8000545c:	f2c40613          	addi	a2,s0,-212
    80005460:	fb040593          	addi	a1,s0,-80
    80005464:	8526                	mv	a0,s1
    80005466:	931fe0ef          	jal	80003d96 <dirlookup>
    8000546a:	892a                	mv	s2,a0
    8000546c:	0e050563          	beqz	a0,80005556 <sys_unlink+0x158>
    80005470:	e5ce                	sd	s3,200(sp)
  ilock(ip);
    80005472:	b8afe0ef          	jal	800037fc <ilock>
  if(ip->nlink < 1)
    80005476:	04a91783          	lh	a5,74(s2)
    8000547a:	06f05863          	blez	a5,800054ea <sys_unlink+0xec>
  if(ip->type == T_DIR && !isdirempty(ip)){
    8000547e:	04491703          	lh	a4,68(s2)
    80005482:	4785                	li	a5,1
    80005484:	06f70963          	beq	a4,a5,800054f6 <sys_unlink+0xf8>
  memset(&de, 0, sizeof(de));
    80005488:	fc040993          	addi	s3,s0,-64
    8000548c:	4641                	li	a2,16
    8000548e:	4581                	li	a1,0
    80005490:	854e                	mv	a0,s3
    80005492:	955fb0ef          	jal	80000de6 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005496:	4741                	li	a4,16
    80005498:	f2c42683          	lw	a3,-212(s0)
    8000549c:	864e                	mv	a2,s3
    8000549e:	4581                	li	a1,0
    800054a0:	8526                	mv	a0,s1
    800054a2:	fdefe0ef          	jal	80003c80 <writei>
    800054a6:	47c1                	li	a5,16
    800054a8:	08f51863          	bne	a0,a5,80005538 <sys_unlink+0x13a>
  if(ip->type == T_DIR){
    800054ac:	04491703          	lh	a4,68(s2)
    800054b0:	4785                	li	a5,1
    800054b2:	08f70963          	beq	a4,a5,80005544 <sys_unlink+0x146>
  iunlockput(dp);
    800054b6:	8526                	mv	a0,s1
    800054b8:	d50fe0ef          	jal	80003a08 <iunlockput>
  ip->nlink--;
    800054bc:	04a95783          	lhu	a5,74(s2)
    800054c0:	37fd                	addiw	a5,a5,-1
    800054c2:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    800054c6:	854a                	mv	a0,s2
    800054c8:	a80fe0ef          	jal	80003748 <iupdate>
  iunlockput(ip);
    800054cc:	854a                	mv	a0,s2
    800054ce:	d3afe0ef          	jal	80003a08 <iunlockput>
  end_op();
    800054d2:	da7fe0ef          	jal	80004278 <end_op>
  return 0;
    800054d6:	4501                	li	a0,0
    800054d8:	64ee                	ld	s1,216(sp)
    800054da:	694e                	ld	s2,208(sp)
    800054dc:	69ae                	ld	s3,200(sp)
    800054de:	a061                	j	80005566 <sys_unlink+0x168>
    end_op();
    800054e0:	d99fe0ef          	jal	80004278 <end_op>
    return -1;
    800054e4:	557d                	li	a0,-1
    800054e6:	64ee                	ld	s1,216(sp)
    800054e8:	a8bd                	j	80005566 <sys_unlink+0x168>
    panic("unlink: nlink < 1");
    800054ea:	00003517          	auipc	a0,0x3
    800054ee:	11e50513          	addi	a0,a0,286 # 80008608 <etext+0x608>
    800054f2:	b64fb0ef          	jal	80000856 <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    800054f6:	04c92703          	lw	a4,76(s2)
    800054fa:	02000793          	li	a5,32
    800054fe:	f8e7f5e3          	bgeu	a5,a4,80005488 <sys_unlink+0x8a>
    80005502:	89be                	mv	s3,a5
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005504:	4741                	li	a4,16
    80005506:	86ce                	mv	a3,s3
    80005508:	f1840613          	addi	a2,s0,-232
    8000550c:	4581                	li	a1,0
    8000550e:	854a                	mv	a0,s2
    80005510:	e7efe0ef          	jal	80003b8e <readi>
    80005514:	47c1                	li	a5,16
    80005516:	00f51b63          	bne	a0,a5,8000552c <sys_unlink+0x12e>
    if(de.inum != 0)
    8000551a:	f1845783          	lhu	a5,-232(s0)
    8000551e:	ebb1                	bnez	a5,80005572 <sys_unlink+0x174>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005520:	29c1                	addiw	s3,s3,16
    80005522:	04c92783          	lw	a5,76(s2)
    80005526:	fcf9efe3          	bltu	s3,a5,80005504 <sys_unlink+0x106>
    8000552a:	bfb9                	j	80005488 <sys_unlink+0x8a>
      panic("isdirempty: readi");
    8000552c:	00003517          	auipc	a0,0x3
    80005530:	0f450513          	addi	a0,a0,244 # 80008620 <etext+0x620>
    80005534:	b22fb0ef          	jal	80000856 <panic>
    panic("unlink: writei");
    80005538:	00003517          	auipc	a0,0x3
    8000553c:	10050513          	addi	a0,a0,256 # 80008638 <etext+0x638>
    80005540:	b16fb0ef          	jal	80000856 <panic>
    dp->nlink--;
    80005544:	04a4d783          	lhu	a5,74(s1)
    80005548:	37fd                	addiw	a5,a5,-1
    8000554a:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    8000554e:	8526                	mv	a0,s1
    80005550:	9f8fe0ef          	jal	80003748 <iupdate>
    80005554:	b78d                	j	800054b6 <sys_unlink+0xb8>
    80005556:	694e                	ld	s2,208(sp)
  iunlockput(dp);
    80005558:	8526                	mv	a0,s1
    8000555a:	caefe0ef          	jal	80003a08 <iunlockput>
  end_op();
    8000555e:	d1bfe0ef          	jal	80004278 <end_op>
  return -1;
    80005562:	557d                	li	a0,-1
    80005564:	64ee                	ld	s1,216(sp)
}
    80005566:	70ae                	ld	ra,232(sp)
    80005568:	740e                	ld	s0,224(sp)
    8000556a:	616d                	addi	sp,sp,240
    8000556c:	8082                	ret
    return -1;
    8000556e:	557d                	li	a0,-1
    80005570:	bfdd                	j	80005566 <sys_unlink+0x168>
    iunlockput(ip);
    80005572:	854a                	mv	a0,s2
    80005574:	c94fe0ef          	jal	80003a08 <iunlockput>
    goto bad;
    80005578:	694e                	ld	s2,208(sp)
    8000557a:	69ae                	ld	s3,200(sp)
    8000557c:	bff1                	j	80005558 <sys_unlink+0x15a>

000000008000557e <sys_open>:

uint64
sys_open(void)
{
    8000557e:	7131                	addi	sp,sp,-192
    80005580:	fd06                	sd	ra,184(sp)
    80005582:	f922                	sd	s0,176(sp)
    80005584:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    80005586:	f4c40593          	addi	a1,s0,-180
    8000558a:	4505                	li	a0,1
    8000558c:	fd4fd0ef          	jal	80002d60 <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    80005590:	08000613          	li	a2,128
    80005594:	f5040593          	addi	a1,s0,-176
    80005598:	4501                	li	a0,0
    8000559a:	ffefd0ef          	jal	80002d98 <argstr>
    8000559e:	87aa                	mv	a5,a0
    return -1;
    800055a0:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    800055a2:	0a07c363          	bltz	a5,80005648 <sys_open+0xca>
    800055a6:	f526                	sd	s1,168(sp)

  begin_op();
    800055a8:	c61fe0ef          	jal	80004208 <begin_op>

  if(omode & O_CREATE){
    800055ac:	f4c42783          	lw	a5,-180(s0)
    800055b0:	2007f793          	andi	a5,a5,512
    800055b4:	c3dd                	beqz	a5,8000565a <sys_open+0xdc>
    ip = create(path, T_FILE, 0, 0);
    800055b6:	4681                	li	a3,0
    800055b8:	4601                	li	a2,0
    800055ba:	4589                	li	a1,2
    800055bc:	f5040513          	addi	a0,s0,-176
    800055c0:	aafff0ef          	jal	8000506e <create>
    800055c4:	84aa                	mv	s1,a0
    if(ip == 0){
    800055c6:	c549                	beqz	a0,80005650 <sys_open+0xd2>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    800055c8:	04449703          	lh	a4,68(s1)
    800055cc:	478d                	li	a5,3
    800055ce:	00f71763          	bne	a4,a5,800055dc <sys_open+0x5e>
    800055d2:	0464d703          	lhu	a4,70(s1)
    800055d6:	47a5                	li	a5,9
    800055d8:	0ae7ee63          	bltu	a5,a4,80005694 <sys_open+0x116>
    800055dc:	f14a                	sd	s2,160(sp)
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    800055de:	fabfe0ef          	jal	80004588 <filealloc>
    800055e2:	892a                	mv	s2,a0
    800055e4:	c561                	beqz	a0,800056ac <sys_open+0x12e>
    800055e6:	ed4e                	sd	s3,152(sp)
    800055e8:	a47ff0ef          	jal	8000502e <fdalloc>
    800055ec:	89aa                	mv	s3,a0
    800055ee:	0a054b63          	bltz	a0,800056a4 <sys_open+0x126>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    800055f2:	04449703          	lh	a4,68(s1)
    800055f6:	478d                	li	a5,3
    800055f8:	0cf70363          	beq	a4,a5,800056be <sys_open+0x140>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    800055fc:	4789                	li	a5,2
    800055fe:	00f92023          	sw	a5,0(s2)
    f->off = 0;
    80005602:	02092023          	sw	zero,32(s2)
  }
  f->ip = ip;
    80005606:	00993c23          	sd	s1,24(s2)
  f->readable = !(omode & O_WRONLY);
    8000560a:	f4c42783          	lw	a5,-180(s0)
    8000560e:	0017f713          	andi	a4,a5,1
    80005612:	00174713          	xori	a4,a4,1
    80005616:	00e90423          	sb	a4,8(s2)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    8000561a:	0037f713          	andi	a4,a5,3
    8000561e:	00e03733          	snez	a4,a4
    80005622:	00e904a3          	sb	a4,9(s2)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    80005626:	4007f793          	andi	a5,a5,1024
    8000562a:	c791                	beqz	a5,80005636 <sys_open+0xb8>
    8000562c:	04449703          	lh	a4,68(s1)
    80005630:	4789                	li	a5,2
    80005632:	08f70d63          	beq	a4,a5,800056cc <sys_open+0x14e>
    itrunc(ip);
  }

  iunlock(ip);
    80005636:	8526                	mv	a0,s1
    80005638:	a72fe0ef          	jal	800038aa <iunlock>
  end_op();
    8000563c:	c3dfe0ef          	jal	80004278 <end_op>

  return fd;
    80005640:	854e                	mv	a0,s3
    80005642:	74aa                	ld	s1,168(sp)
    80005644:	790a                	ld	s2,160(sp)
    80005646:	69ea                	ld	s3,152(sp)
}
    80005648:	70ea                	ld	ra,184(sp)
    8000564a:	744a                	ld	s0,176(sp)
    8000564c:	6129                	addi	sp,sp,192
    8000564e:	8082                	ret
      end_op();
    80005650:	c29fe0ef          	jal	80004278 <end_op>
      return -1;
    80005654:	557d                	li	a0,-1
    80005656:	74aa                	ld	s1,168(sp)
    80005658:	bfc5                	j	80005648 <sys_open+0xca>
    if((ip = namei(path)) == 0){
    8000565a:	f5040513          	addi	a0,s0,-176
    8000565e:	9cdfe0ef          	jal	8000402a <namei>
    80005662:	84aa                	mv	s1,a0
    80005664:	c11d                	beqz	a0,8000568a <sys_open+0x10c>
    ilock(ip);
    80005666:	996fe0ef          	jal	800037fc <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    8000566a:	04449703          	lh	a4,68(s1)
    8000566e:	4785                	li	a5,1
    80005670:	f4f71ce3          	bne	a4,a5,800055c8 <sys_open+0x4a>
    80005674:	f4c42783          	lw	a5,-180(s0)
    80005678:	d3b5                	beqz	a5,800055dc <sys_open+0x5e>
      iunlockput(ip);
    8000567a:	8526                	mv	a0,s1
    8000567c:	b8cfe0ef          	jal	80003a08 <iunlockput>
      end_op();
    80005680:	bf9fe0ef          	jal	80004278 <end_op>
      return -1;
    80005684:	557d                	li	a0,-1
    80005686:	74aa                	ld	s1,168(sp)
    80005688:	b7c1                	j	80005648 <sys_open+0xca>
      end_op();
    8000568a:	beffe0ef          	jal	80004278 <end_op>
      return -1;
    8000568e:	557d                	li	a0,-1
    80005690:	74aa                	ld	s1,168(sp)
    80005692:	bf5d                	j	80005648 <sys_open+0xca>
    iunlockput(ip);
    80005694:	8526                	mv	a0,s1
    80005696:	b72fe0ef          	jal	80003a08 <iunlockput>
    end_op();
    8000569a:	bdffe0ef          	jal	80004278 <end_op>
    return -1;
    8000569e:	557d                	li	a0,-1
    800056a0:	74aa                	ld	s1,168(sp)
    800056a2:	b75d                	j	80005648 <sys_open+0xca>
      fileclose(f);
    800056a4:	854a                	mv	a0,s2
    800056a6:	f87fe0ef          	jal	8000462c <fileclose>
    800056aa:	69ea                	ld	s3,152(sp)
    iunlockput(ip);
    800056ac:	8526                	mv	a0,s1
    800056ae:	b5afe0ef          	jal	80003a08 <iunlockput>
    end_op();
    800056b2:	bc7fe0ef          	jal	80004278 <end_op>
    return -1;
    800056b6:	557d                	li	a0,-1
    800056b8:	74aa                	ld	s1,168(sp)
    800056ba:	790a                	ld	s2,160(sp)
    800056bc:	b771                	j	80005648 <sys_open+0xca>
    f->type = FD_DEVICE;
    800056be:	00e92023          	sw	a4,0(s2)
    f->major = ip->major;
    800056c2:	04649783          	lh	a5,70(s1)
    800056c6:	02f91223          	sh	a5,36(s2)
    800056ca:	bf35                	j	80005606 <sys_open+0x88>
    itrunc(ip);
    800056cc:	8526                	mv	a0,s1
    800056ce:	a1cfe0ef          	jal	800038ea <itrunc>
    800056d2:	b795                	j	80005636 <sys_open+0xb8>

00000000800056d4 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    800056d4:	7175                	addi	sp,sp,-144
    800056d6:	e506                	sd	ra,136(sp)
    800056d8:	e122                	sd	s0,128(sp)
    800056da:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    800056dc:	b2dfe0ef          	jal	80004208 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    800056e0:	08000613          	li	a2,128
    800056e4:	f7040593          	addi	a1,s0,-144
    800056e8:	4501                	li	a0,0
    800056ea:	eaefd0ef          	jal	80002d98 <argstr>
    800056ee:	02054363          	bltz	a0,80005714 <sys_mkdir+0x40>
    800056f2:	4681                	li	a3,0
    800056f4:	4601                	li	a2,0
    800056f6:	4585                	li	a1,1
    800056f8:	f7040513          	addi	a0,s0,-144
    800056fc:	973ff0ef          	jal	8000506e <create>
    80005700:	c911                	beqz	a0,80005714 <sys_mkdir+0x40>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005702:	b06fe0ef          	jal	80003a08 <iunlockput>
  end_op();
    80005706:	b73fe0ef          	jal	80004278 <end_op>
  return 0;
    8000570a:	4501                	li	a0,0
}
    8000570c:	60aa                	ld	ra,136(sp)
    8000570e:	640a                	ld	s0,128(sp)
    80005710:	6149                	addi	sp,sp,144
    80005712:	8082                	ret
    end_op();
    80005714:	b65fe0ef          	jal	80004278 <end_op>
    return -1;
    80005718:	557d                	li	a0,-1
    8000571a:	bfcd                	j	8000570c <sys_mkdir+0x38>

000000008000571c <sys_mknod>:

uint64
sys_mknod(void)
{
    8000571c:	7135                	addi	sp,sp,-160
    8000571e:	ed06                	sd	ra,152(sp)
    80005720:	e922                	sd	s0,144(sp)
    80005722:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80005724:	ae5fe0ef          	jal	80004208 <begin_op>
  argint(1, &major);
    80005728:	f6c40593          	addi	a1,s0,-148
    8000572c:	4505                	li	a0,1
    8000572e:	e32fd0ef          	jal	80002d60 <argint>
  argint(2, &minor);
    80005732:	f6840593          	addi	a1,s0,-152
    80005736:	4509                	li	a0,2
    80005738:	e28fd0ef          	jal	80002d60 <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    8000573c:	08000613          	li	a2,128
    80005740:	f7040593          	addi	a1,s0,-144
    80005744:	4501                	li	a0,0
    80005746:	e52fd0ef          	jal	80002d98 <argstr>
    8000574a:	02054563          	bltz	a0,80005774 <sys_mknod+0x58>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    8000574e:	f6841683          	lh	a3,-152(s0)
    80005752:	f6c41603          	lh	a2,-148(s0)
    80005756:	458d                	li	a1,3
    80005758:	f7040513          	addi	a0,s0,-144
    8000575c:	913ff0ef          	jal	8000506e <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005760:	c911                	beqz	a0,80005774 <sys_mknod+0x58>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005762:	aa6fe0ef          	jal	80003a08 <iunlockput>
  end_op();
    80005766:	b13fe0ef          	jal	80004278 <end_op>
  return 0;
    8000576a:	4501                	li	a0,0
}
    8000576c:	60ea                	ld	ra,152(sp)
    8000576e:	644a                	ld	s0,144(sp)
    80005770:	610d                	addi	sp,sp,160
    80005772:	8082                	ret
    end_op();
    80005774:	b05fe0ef          	jal	80004278 <end_op>
    return -1;
    80005778:	557d                	li	a0,-1
    8000577a:	bfcd                	j	8000576c <sys_mknod+0x50>

000000008000577c <sys_chdir>:

uint64
sys_chdir(void)
{
    8000577c:	7135                	addi	sp,sp,-160
    8000577e:	ed06                	sd	ra,152(sp)
    80005780:	e922                	sd	s0,144(sp)
    80005782:	e14a                	sd	s2,128(sp)
    80005784:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80005786:	ca2fc0ef          	jal	80001c28 <myproc>
    8000578a:	892a                	mv	s2,a0
  
  begin_op();
    8000578c:	a7dfe0ef          	jal	80004208 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80005790:	08000613          	li	a2,128
    80005794:	f6040593          	addi	a1,s0,-160
    80005798:	4501                	li	a0,0
    8000579a:	dfefd0ef          	jal	80002d98 <argstr>
    8000579e:	04054363          	bltz	a0,800057e4 <sys_chdir+0x68>
    800057a2:	e526                	sd	s1,136(sp)
    800057a4:	f6040513          	addi	a0,s0,-160
    800057a8:	883fe0ef          	jal	8000402a <namei>
    800057ac:	84aa                	mv	s1,a0
    800057ae:	c915                	beqz	a0,800057e2 <sys_chdir+0x66>
    end_op();
    return -1;
  }
  ilock(ip);
    800057b0:	84cfe0ef          	jal	800037fc <ilock>
  if(ip->type != T_DIR){
    800057b4:	04449703          	lh	a4,68(s1)
    800057b8:	4785                	li	a5,1
    800057ba:	02f71963          	bne	a4,a5,800057ec <sys_chdir+0x70>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    800057be:	8526                	mv	a0,s1
    800057c0:	8eafe0ef          	jal	800038aa <iunlock>
  iput(p->cwd);
    800057c4:	15093503          	ld	a0,336(s2)
    800057c8:	9b6fe0ef          	jal	8000397e <iput>
  end_op();
    800057cc:	aadfe0ef          	jal	80004278 <end_op>
  p->cwd = ip;
    800057d0:	14993823          	sd	s1,336(s2)
  return 0;
    800057d4:	4501                	li	a0,0
    800057d6:	64aa                	ld	s1,136(sp)
}
    800057d8:	60ea                	ld	ra,152(sp)
    800057da:	644a                	ld	s0,144(sp)
    800057dc:	690a                	ld	s2,128(sp)
    800057de:	610d                	addi	sp,sp,160
    800057e0:	8082                	ret
    800057e2:	64aa                	ld	s1,136(sp)
    end_op();
    800057e4:	a95fe0ef          	jal	80004278 <end_op>
    return -1;
    800057e8:	557d                	li	a0,-1
    800057ea:	b7fd                	j	800057d8 <sys_chdir+0x5c>
    iunlockput(ip);
    800057ec:	8526                	mv	a0,s1
    800057ee:	a1afe0ef          	jal	80003a08 <iunlockput>
    end_op();
    800057f2:	a87fe0ef          	jal	80004278 <end_op>
    return -1;
    800057f6:	557d                	li	a0,-1
    800057f8:	64aa                	ld	s1,136(sp)
    800057fa:	bff9                	j	800057d8 <sys_chdir+0x5c>

00000000800057fc <sys_exec>:

uint64
sys_exec(void)
{
    800057fc:	7105                	addi	sp,sp,-480
    800057fe:	ef86                	sd	ra,472(sp)
    80005800:	eba2                	sd	s0,464(sp)
    80005802:	1380                	addi	s0,sp,480
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    80005804:	e2840593          	addi	a1,s0,-472
    80005808:	4505                	li	a0,1
    8000580a:	d72fd0ef          	jal	80002d7c <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    8000580e:	08000613          	li	a2,128
    80005812:	f3040593          	addi	a1,s0,-208
    80005816:	4501                	li	a0,0
    80005818:	d80fd0ef          	jal	80002d98 <argstr>
    8000581c:	87aa                	mv	a5,a0
    return -1;
    8000581e:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    80005820:	0e07c063          	bltz	a5,80005900 <sys_exec+0x104>
    80005824:	e7a6                	sd	s1,456(sp)
    80005826:	e3ca                	sd	s2,448(sp)
    80005828:	ff4e                	sd	s3,440(sp)
    8000582a:	fb52                	sd	s4,432(sp)
    8000582c:	f756                	sd	s5,424(sp)
    8000582e:	f35a                	sd	s6,416(sp)
    80005830:	ef5e                	sd	s7,408(sp)
  }
  memset(argv, 0, sizeof(argv));
    80005832:	e3040a13          	addi	s4,s0,-464
    80005836:	10000613          	li	a2,256
    8000583a:	4581                	li	a1,0
    8000583c:	8552                	mv	a0,s4
    8000583e:	da8fb0ef          	jal	80000de6 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80005842:	84d2                	mv	s1,s4
  memset(argv, 0, sizeof(argv));
    80005844:	89d2                	mv	s3,s4
    80005846:	4901                	li	s2,0
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80005848:	e2040a93          	addi	s5,s0,-480
      break;
    }
    argv[i] = kalloc();
    if(argv[i] == 0)
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    8000584c:	6b05                	lui	s6,0x1
    if(i >= NELEM(argv)){
    8000584e:	02000b93          	li	s7,32
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80005852:	00391513          	slli	a0,s2,0x3
    80005856:	85d6                	mv	a1,s5
    80005858:	e2843783          	ld	a5,-472(s0)
    8000585c:	953e                	add	a0,a0,a5
    8000585e:	c78fd0ef          	jal	80002cd6 <fetchaddr>
    80005862:	02054663          	bltz	a0,8000588e <sys_exec+0x92>
    if(uarg == 0){
    80005866:	e2043783          	ld	a5,-480(s0)
    8000586a:	c7a1                	beqz	a5,800058b2 <sys_exec+0xb6>
    argv[i] = kalloc();
    8000586c:	b68fb0ef          	jal	80000bd4 <kalloc>
    80005870:	85aa                	mv	a1,a0
    80005872:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80005876:	cd01                	beqz	a0,8000588e <sys_exec+0x92>
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80005878:	865a                	mv	a2,s6
    8000587a:	e2043503          	ld	a0,-480(s0)
    8000587e:	ca2fd0ef          	jal	80002d20 <fetchstr>
    80005882:	00054663          	bltz	a0,8000588e <sys_exec+0x92>
    if(i >= NELEM(argv)){
    80005886:	0905                	addi	s2,s2,1
    80005888:	09a1                	addi	s3,s3,8
    8000588a:	fd7914e3          	bne	s2,s7,80005852 <sys_exec+0x56>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    8000588e:	100a0a13          	addi	s4,s4,256
    80005892:	6088                	ld	a0,0(s1)
    80005894:	cd31                	beqz	a0,800058f0 <sys_exec+0xf4>
    kfree(argv[i]);
    80005896:	9f8fb0ef          	jal	80000a8e <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    8000589a:	04a1                	addi	s1,s1,8
    8000589c:	ff449be3          	bne	s1,s4,80005892 <sys_exec+0x96>
  return -1;
    800058a0:	557d                	li	a0,-1
    800058a2:	64be                	ld	s1,456(sp)
    800058a4:	691e                	ld	s2,448(sp)
    800058a6:	79fa                	ld	s3,440(sp)
    800058a8:	7a5a                	ld	s4,432(sp)
    800058aa:	7aba                	ld	s5,424(sp)
    800058ac:	7b1a                	ld	s6,416(sp)
    800058ae:	6bfa                	ld	s7,408(sp)
    800058b0:	a881                	j	80005900 <sys_exec+0x104>
      argv[i] = 0;
    800058b2:	0009079b          	sext.w	a5,s2
    800058b6:	e3040593          	addi	a1,s0,-464
    800058ba:	078e                	slli	a5,a5,0x3
    800058bc:	97ae                	add	a5,a5,a1
    800058be:	0007b023          	sd	zero,0(a5)
  int ret = kexec(path, argv);
    800058c2:	f3040513          	addi	a0,s0,-208
    800058c6:	bb2ff0ef          	jal	80004c78 <kexec>
    800058ca:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800058cc:	100a0a13          	addi	s4,s4,256
    800058d0:	6088                	ld	a0,0(s1)
    800058d2:	c511                	beqz	a0,800058de <sys_exec+0xe2>
    kfree(argv[i]);
    800058d4:	9bafb0ef          	jal	80000a8e <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800058d8:	04a1                	addi	s1,s1,8
    800058da:	ff449be3          	bne	s1,s4,800058d0 <sys_exec+0xd4>
  return ret;
    800058de:	854a                	mv	a0,s2
    800058e0:	64be                	ld	s1,456(sp)
    800058e2:	691e                	ld	s2,448(sp)
    800058e4:	79fa                	ld	s3,440(sp)
    800058e6:	7a5a                	ld	s4,432(sp)
    800058e8:	7aba                	ld	s5,424(sp)
    800058ea:	7b1a                	ld	s6,416(sp)
    800058ec:	6bfa                	ld	s7,408(sp)
    800058ee:	a809                	j	80005900 <sys_exec+0x104>
  return -1;
    800058f0:	557d                	li	a0,-1
    800058f2:	64be                	ld	s1,456(sp)
    800058f4:	691e                	ld	s2,448(sp)
    800058f6:	79fa                	ld	s3,440(sp)
    800058f8:	7a5a                	ld	s4,432(sp)
    800058fa:	7aba                	ld	s5,424(sp)
    800058fc:	7b1a                	ld	s6,416(sp)
    800058fe:	6bfa                	ld	s7,408(sp)
}
    80005900:	60fe                	ld	ra,472(sp)
    80005902:	645e                	ld	s0,464(sp)
    80005904:	613d                	addi	sp,sp,480
    80005906:	8082                	ret

0000000080005908 <sys_pipe>:

uint64
sys_pipe(void)
{
    80005908:	7139                	addi	sp,sp,-64
    8000590a:	fc06                	sd	ra,56(sp)
    8000590c:	f822                	sd	s0,48(sp)
    8000590e:	f426                	sd	s1,40(sp)
    80005910:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80005912:	b16fc0ef          	jal	80001c28 <myproc>
    80005916:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    80005918:	fd840593          	addi	a1,s0,-40
    8000591c:	4501                	li	a0,0
    8000591e:	c5efd0ef          	jal	80002d7c <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    80005922:	fc840593          	addi	a1,s0,-56
    80005926:	fd040513          	addi	a0,s0,-48
    8000592a:	81eff0ef          	jal	80004948 <pipealloc>
    return -1;
    8000592e:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80005930:	0a054763          	bltz	a0,800059de <sys_pipe+0xd6>
  fd0 = -1;
    80005934:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80005938:	fd043503          	ld	a0,-48(s0)
    8000593c:	ef2ff0ef          	jal	8000502e <fdalloc>
    80005940:	fca42223          	sw	a0,-60(s0)
    80005944:	08054463          	bltz	a0,800059cc <sys_pipe+0xc4>
    80005948:	fc843503          	ld	a0,-56(s0)
    8000594c:	ee2ff0ef          	jal	8000502e <fdalloc>
    80005950:	fca42023          	sw	a0,-64(s0)
    80005954:	06054263          	bltz	a0,800059b8 <sys_pipe+0xb0>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005958:	4691                	li	a3,4
    8000595a:	fc440613          	addi	a2,s0,-60
    8000595e:	fd843583          	ld	a1,-40(s0)
    80005962:	68a8                	ld	a0,80(s1)
    80005964:	fd7fb0ef          	jal	8000193a <copyout>
    80005968:	00054e63          	bltz	a0,80005984 <sys_pipe+0x7c>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    8000596c:	4691                	li	a3,4
    8000596e:	fc040613          	addi	a2,s0,-64
    80005972:	fd843583          	ld	a1,-40(s0)
    80005976:	95b6                	add	a1,a1,a3
    80005978:	68a8                	ld	a0,80(s1)
    8000597a:	fc1fb0ef          	jal	8000193a <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    8000597e:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005980:	04055f63          	bgez	a0,800059de <sys_pipe+0xd6>
    p->ofile[fd0] = 0;
    80005984:	fc442783          	lw	a5,-60(s0)
    80005988:	078e                	slli	a5,a5,0x3
    8000598a:	0d078793          	addi	a5,a5,208
    8000598e:	97a6                	add	a5,a5,s1
    80005990:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    80005994:	fc042783          	lw	a5,-64(s0)
    80005998:	078e                	slli	a5,a5,0x3
    8000599a:	0d078793          	addi	a5,a5,208
    8000599e:	97a6                	add	a5,a5,s1
    800059a0:	0007b023          	sd	zero,0(a5)
    fileclose(rf);
    800059a4:	fd043503          	ld	a0,-48(s0)
    800059a8:	c85fe0ef          	jal	8000462c <fileclose>
    fileclose(wf);
    800059ac:	fc843503          	ld	a0,-56(s0)
    800059b0:	c7dfe0ef          	jal	8000462c <fileclose>
    return -1;
    800059b4:	57fd                	li	a5,-1
    800059b6:	a025                	j	800059de <sys_pipe+0xd6>
    if(fd0 >= 0)
    800059b8:	fc442783          	lw	a5,-60(s0)
    800059bc:	0007c863          	bltz	a5,800059cc <sys_pipe+0xc4>
      p->ofile[fd0] = 0;
    800059c0:	078e                	slli	a5,a5,0x3
    800059c2:	0d078793          	addi	a5,a5,208
    800059c6:	97a6                	add	a5,a5,s1
    800059c8:	0007b023          	sd	zero,0(a5)
    fileclose(rf);
    800059cc:	fd043503          	ld	a0,-48(s0)
    800059d0:	c5dfe0ef          	jal	8000462c <fileclose>
    fileclose(wf);
    800059d4:	fc843503          	ld	a0,-56(s0)
    800059d8:	c55fe0ef          	jal	8000462c <fileclose>
    return -1;
    800059dc:	57fd                	li	a5,-1
}
    800059de:	853e                	mv	a0,a5
    800059e0:	70e2                	ld	ra,56(sp)
    800059e2:	7442                	ld	s0,48(sp)
    800059e4:	74a2                	ld	s1,40(sp)
    800059e6:	6121                	addi	sp,sp,64
    800059e8:	8082                	ret

00000000800059ea <sys_fsread>:
uint64
sys_fsread(void)
{
    800059ea:	1101                	addi	sp,sp,-32
    800059ec:	ec06                	sd	ra,24(sp)
    800059ee:	e822                	sd	s0,16(sp)
    800059f0:	1000                	addi	s0,sp,32
  uint64 addr;
  int n;

  // استدعاء الدوال بدون مقارنتها بـ < 0 لأنها تعيد void
  argaddr(0, &addr); 
    800059f2:	fe840593          	addi	a1,s0,-24
    800059f6:	4501                	li	a0,0
    800059f8:	b84fd0ef          	jal	80002d7c <argaddr>
  argint(1, &n);
    800059fc:	fe440593          	addi	a1,s0,-28
    80005a00:	4505                	li	a0,1
    80005a02:	b5efd0ef          	jal	80002d60 <argint>

  // استدعاء الوظيفة الحقيقية وإعادة نتيجتها
  return fslog_read_many((struct fs_event *)addr, n);
    80005a06:	fe442583          	lw	a1,-28(s0)
    80005a0a:	fe843503          	ld	a0,-24(s0)
    80005a0e:	1ff000ef          	jal	8000640c <fslog_read_many>
    80005a12:	60e2                	ld	ra,24(sp)
    80005a14:	6442                	ld	s0,16(sp)
    80005a16:	6105                	addi	sp,sp,32
    80005a18:	8082                	ret
    80005a1a:	0000                	unimp
    80005a1c:	0000                	unimp
	...

0000000080005a20 <kernelvec>:
.globl kerneltrap
.globl kernelvec
.align 4
kernelvec:
        # make room to save registers.
        addi sp, sp, -256
    80005a20:	7111                	addi	sp,sp,-256

        # save caller-saved registers.
        sd ra, 0(sp)
    80005a22:	e006                	sd	ra,0(sp)
        # sd sp, 8(sp)
        sd gp, 16(sp)
    80005a24:	e80e                	sd	gp,16(sp)
        sd tp, 24(sp)
    80005a26:	ec12                	sd	tp,24(sp)
        sd t0, 32(sp)
    80005a28:	f016                	sd	t0,32(sp)
        sd t1, 40(sp)
    80005a2a:	f41a                	sd	t1,40(sp)
        sd t2, 48(sp)
    80005a2c:	f81e                	sd	t2,48(sp)
        sd a0, 72(sp)
    80005a2e:	e4aa                	sd	a0,72(sp)
        sd a1, 80(sp)
    80005a30:	e8ae                	sd	a1,80(sp)
        sd a2, 88(sp)
    80005a32:	ecb2                	sd	a2,88(sp)
        sd a3, 96(sp)
    80005a34:	f0b6                	sd	a3,96(sp)
        sd a4, 104(sp)
    80005a36:	f4ba                	sd	a4,104(sp)
        sd a5, 112(sp)
    80005a38:	f8be                	sd	a5,112(sp)
        sd a6, 120(sp)
    80005a3a:	fcc2                	sd	a6,120(sp)
        sd a7, 128(sp)
    80005a3c:	e146                	sd	a7,128(sp)
        sd t3, 216(sp)
    80005a3e:	edf2                	sd	t3,216(sp)
        sd t4, 224(sp)
    80005a40:	f1f6                	sd	t4,224(sp)
        sd t5, 232(sp)
    80005a42:	f5fa                	sd	t5,232(sp)
        sd t6, 240(sp)
    80005a44:	f9fe                	sd	t6,240(sp)

        # call the C trap handler in trap.c
        call kerneltrap
    80005a46:	99efd0ef          	jal	80002be4 <kerneltrap>

        # restore registers.
        ld ra, 0(sp)
    80005a4a:	6082                	ld	ra,0(sp)
        # ld sp, 8(sp)
        ld gp, 16(sp)
    80005a4c:	61c2                	ld	gp,16(sp)
        # not tp (contains hartid), in case we moved CPUs
        ld t0, 32(sp)
    80005a4e:	7282                	ld	t0,32(sp)
        ld t1, 40(sp)
    80005a50:	7322                	ld	t1,40(sp)
        ld t2, 48(sp)
    80005a52:	73c2                	ld	t2,48(sp)
        ld a0, 72(sp)
    80005a54:	6526                	ld	a0,72(sp)
        ld a1, 80(sp)
    80005a56:	65c6                	ld	a1,80(sp)
        ld a2, 88(sp)
    80005a58:	6666                	ld	a2,88(sp)
        ld a3, 96(sp)
    80005a5a:	7686                	ld	a3,96(sp)
        ld a4, 104(sp)
    80005a5c:	7726                	ld	a4,104(sp)
        ld a5, 112(sp)
    80005a5e:	77c6                	ld	a5,112(sp)
        ld a6, 120(sp)
    80005a60:	7866                	ld	a6,120(sp)
        ld a7, 128(sp)
    80005a62:	688a                	ld	a7,128(sp)
        ld t3, 216(sp)
    80005a64:	6e6e                	ld	t3,216(sp)
        ld t4, 224(sp)
    80005a66:	7e8e                	ld	t4,224(sp)
        ld t5, 232(sp)
    80005a68:	7f2e                	ld	t5,232(sp)
        ld t6, 240(sp)
    80005a6a:	7fce                	ld	t6,240(sp)

        addi sp, sp, 256
    80005a6c:	6111                	addi	sp,sp,256

        # return to whatever we were doing in the kernel.
        sret
    80005a6e:	10200073          	sret
    80005a72:	00000013          	nop
    80005a76:	00000013          	nop
    80005a7a:	00000013          	nop

0000000080005a7e <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    80005a7e:	1141                	addi	sp,sp,-16
    80005a80:	e406                	sd	ra,8(sp)
    80005a82:	e022                	sd	s0,0(sp)
    80005a84:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80005a86:	0c000737          	lui	a4,0xc000
    80005a8a:	4785                	li	a5,1
    80005a8c:	d71c                	sw	a5,40(a4)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    80005a8e:	c35c                	sw	a5,4(a4)
}
    80005a90:	60a2                	ld	ra,8(sp)
    80005a92:	6402                	ld	s0,0(sp)
    80005a94:	0141                	addi	sp,sp,16
    80005a96:	8082                	ret

0000000080005a98 <plicinithart>:

void
plicinithart(void)
{
    80005a98:	1141                	addi	sp,sp,-16
    80005a9a:	e406                	sd	ra,8(sp)
    80005a9c:	e022                	sd	s0,0(sp)
    80005a9e:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005aa0:	954fc0ef          	jal	80001bf4 <cpuid>
  
  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80005aa4:	0085171b          	slliw	a4,a0,0x8
    80005aa8:	0c0027b7          	lui	a5,0xc002
    80005aac:	97ba                	add	a5,a5,a4
    80005aae:	40200713          	li	a4,1026
    80005ab2:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80005ab6:	00d5151b          	slliw	a0,a0,0xd
    80005aba:	0c2017b7          	lui	a5,0xc201
    80005abe:	97aa                	add	a5,a5,a0
    80005ac0:	0007a023          	sw	zero,0(a5) # c201000 <_entry-0x73dff000>
}
    80005ac4:	60a2                	ld	ra,8(sp)
    80005ac6:	6402                	ld	s0,0(sp)
    80005ac8:	0141                	addi	sp,sp,16
    80005aca:	8082                	ret

0000000080005acc <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    80005acc:	1141                	addi	sp,sp,-16
    80005ace:	e406                	sd	ra,8(sp)
    80005ad0:	e022                	sd	s0,0(sp)
    80005ad2:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005ad4:	920fc0ef          	jal	80001bf4 <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80005ad8:	00d5151b          	slliw	a0,a0,0xd
    80005adc:	0c2017b7          	lui	a5,0xc201
    80005ae0:	97aa                	add	a5,a5,a0
  return irq;
}
    80005ae2:	43c8                	lw	a0,4(a5)
    80005ae4:	60a2                	ld	ra,8(sp)
    80005ae6:	6402                	ld	s0,0(sp)
    80005ae8:	0141                	addi	sp,sp,16
    80005aea:	8082                	ret

0000000080005aec <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    80005aec:	1101                	addi	sp,sp,-32
    80005aee:	ec06                	sd	ra,24(sp)
    80005af0:	e822                	sd	s0,16(sp)
    80005af2:	e426                	sd	s1,8(sp)
    80005af4:	1000                	addi	s0,sp,32
    80005af6:	84aa                	mv	s1,a0
  int hart = cpuid();
    80005af8:	8fcfc0ef          	jal	80001bf4 <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    80005afc:	00d5179b          	slliw	a5,a0,0xd
    80005b00:	0c201737          	lui	a4,0xc201
    80005b04:	97ba                	add	a5,a5,a4
    80005b06:	c3c4                	sw	s1,4(a5)
}
    80005b08:	60e2                	ld	ra,24(sp)
    80005b0a:	6442                	ld	s0,16(sp)
    80005b0c:	64a2                	ld	s1,8(sp)
    80005b0e:	6105                	addi	sp,sp,32
    80005b10:	8082                	ret

0000000080005b12 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80005b12:	1141                	addi	sp,sp,-16
    80005b14:	e406                	sd	ra,8(sp)
    80005b16:	e022                	sd	s0,0(sp)
    80005b18:	0800                	addi	s0,sp,16
  if(i >= NUM)
    80005b1a:	479d                	li	a5,7
    80005b1c:	04a7ca63          	blt	a5,a0,80005b70 <free_desc+0x5e>
    panic("free_desc 1");
  if(disk.free[i])
    80005b20:	0001f797          	auipc	a5,0x1f
    80005b24:	eb078793          	addi	a5,a5,-336 # 800249d0 <disk>
    80005b28:	97aa                	add	a5,a5,a0
    80005b2a:	0187c783          	lbu	a5,24(a5)
    80005b2e:	e7b9                	bnez	a5,80005b7c <free_desc+0x6a>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    80005b30:	00451693          	slli	a3,a0,0x4
    80005b34:	0001f797          	auipc	a5,0x1f
    80005b38:	e9c78793          	addi	a5,a5,-356 # 800249d0 <disk>
    80005b3c:	6398                	ld	a4,0(a5)
    80005b3e:	9736                	add	a4,a4,a3
    80005b40:	00073023          	sd	zero,0(a4) # c201000 <_entry-0x73dff000>
  disk.desc[i].len = 0;
    80005b44:	6398                	ld	a4,0(a5)
    80005b46:	9736                	add	a4,a4,a3
    80005b48:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    80005b4c:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    80005b50:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    80005b54:	97aa                	add	a5,a5,a0
    80005b56:	4705                	li	a4,1
    80005b58:	00e78c23          	sb	a4,24(a5)
  wakeup(&disk.free[0]);
    80005b5c:	0001f517          	auipc	a0,0x1f
    80005b60:	e8c50513          	addi	a0,a0,-372 # 800249e8 <disk+0x18>
    80005b64:	93dfc0ef          	jal	800024a0 <wakeup>
}
    80005b68:	60a2                	ld	ra,8(sp)
    80005b6a:	6402                	ld	s0,0(sp)
    80005b6c:	0141                	addi	sp,sp,16
    80005b6e:	8082                	ret
    panic("free_desc 1");
    80005b70:	00003517          	auipc	a0,0x3
    80005b74:	ad850513          	addi	a0,a0,-1320 # 80008648 <etext+0x648>
    80005b78:	cdffa0ef          	jal	80000856 <panic>
    panic("free_desc 2");
    80005b7c:	00003517          	auipc	a0,0x3
    80005b80:	adc50513          	addi	a0,a0,-1316 # 80008658 <etext+0x658>
    80005b84:	cd3fa0ef          	jal	80000856 <panic>

0000000080005b88 <virtio_disk_init>:
{
    80005b88:	1101                	addi	sp,sp,-32
    80005b8a:	ec06                	sd	ra,24(sp)
    80005b8c:	e822                	sd	s0,16(sp)
    80005b8e:	e426                	sd	s1,8(sp)
    80005b90:	e04a                	sd	s2,0(sp)
    80005b92:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80005b94:	00003597          	auipc	a1,0x3
    80005b98:	ad458593          	addi	a1,a1,-1324 # 80008668 <etext+0x668>
    80005b9c:	0001f517          	auipc	a0,0x1f
    80005ba0:	f5c50513          	addi	a0,a0,-164 # 80024af8 <disk+0x128>
    80005ba4:	8e8fb0ef          	jal	80000c8c <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005ba8:	100017b7          	lui	a5,0x10001
    80005bac:	4398                	lw	a4,0(a5)
    80005bae:	2701                	sext.w	a4,a4
    80005bb0:	747277b7          	lui	a5,0x74727
    80005bb4:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    80005bb8:	14f71863          	bne	a4,a5,80005d08 <virtio_disk_init+0x180>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80005bbc:	100017b7          	lui	a5,0x10001
    80005bc0:	43dc                	lw	a5,4(a5)
    80005bc2:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005bc4:	4709                	li	a4,2
    80005bc6:	14e79163          	bne	a5,a4,80005d08 <virtio_disk_init+0x180>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005bca:	100017b7          	lui	a5,0x10001
    80005bce:	479c                	lw	a5,8(a5)
    80005bd0:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80005bd2:	12e79b63          	bne	a5,a4,80005d08 <virtio_disk_init+0x180>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    80005bd6:	100017b7          	lui	a5,0x10001
    80005bda:	47d8                	lw	a4,12(a5)
    80005bdc:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005bde:	554d47b7          	lui	a5,0x554d4
    80005be2:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    80005be6:	12f71163          	bne	a4,a5,80005d08 <virtio_disk_init+0x180>
  *R(VIRTIO_MMIO_STATUS) = status;
    80005bea:	100017b7          	lui	a5,0x10001
    80005bee:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    80005bf2:	4705                	li	a4,1
    80005bf4:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005bf6:	470d                	li	a4,3
    80005bf8:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    80005bfa:	10001737          	lui	a4,0x10001
    80005bfe:	4b18                	lw	a4,16(a4)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    80005c00:	c7ffe6b7          	lui	a3,0xc7ffe
    80005c04:	75f68693          	addi	a3,a3,1887 # ffffffffc7ffe75f <end+0xffffffff47fb4ba7>
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80005c08:	8f75                	and	a4,a4,a3
    80005c0a:	100016b7          	lui	a3,0x10001
    80005c0e:	d298                	sw	a4,32(a3)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005c10:	472d                	li	a4,11
    80005c12:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005c14:	07078793          	addi	a5,a5,112
  status = *R(VIRTIO_MMIO_STATUS);
    80005c18:	439c                	lw	a5,0(a5)
    80005c1a:	0007891b          	sext.w	s2,a5
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    80005c1e:	8ba1                	andi	a5,a5,8
    80005c20:	0e078a63          	beqz	a5,80005d14 <virtio_disk_init+0x18c>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80005c24:	100017b7          	lui	a5,0x10001
    80005c28:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    80005c2c:	43fc                	lw	a5,68(a5)
    80005c2e:	2781                	sext.w	a5,a5
    80005c30:	0e079863          	bnez	a5,80005d20 <virtio_disk_init+0x198>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    80005c34:	100017b7          	lui	a5,0x10001
    80005c38:	5bdc                	lw	a5,52(a5)
    80005c3a:	2781                	sext.w	a5,a5
  if(max == 0)
    80005c3c:	0e078863          	beqz	a5,80005d2c <virtio_disk_init+0x1a4>
  if(max < NUM)
    80005c40:	471d                	li	a4,7
    80005c42:	0ef77b63          	bgeu	a4,a5,80005d38 <virtio_disk_init+0x1b0>
  disk.desc = kalloc();
    80005c46:	f8ffa0ef          	jal	80000bd4 <kalloc>
    80005c4a:	0001f497          	auipc	s1,0x1f
    80005c4e:	d8648493          	addi	s1,s1,-634 # 800249d0 <disk>
    80005c52:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    80005c54:	f81fa0ef          	jal	80000bd4 <kalloc>
    80005c58:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    80005c5a:	f7bfa0ef          	jal	80000bd4 <kalloc>
    80005c5e:	87aa                	mv	a5,a0
    80005c60:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    80005c62:	6088                	ld	a0,0(s1)
    80005c64:	0e050063          	beqz	a0,80005d44 <virtio_disk_init+0x1bc>
    80005c68:	0001f717          	auipc	a4,0x1f
    80005c6c:	d7073703          	ld	a4,-656(a4) # 800249d8 <disk+0x8>
    80005c70:	cb71                	beqz	a4,80005d44 <virtio_disk_init+0x1bc>
    80005c72:	cbe9                	beqz	a5,80005d44 <virtio_disk_init+0x1bc>
  memset(disk.desc, 0, PGSIZE);
    80005c74:	6605                	lui	a2,0x1
    80005c76:	4581                	li	a1,0
    80005c78:	96efb0ef          	jal	80000de6 <memset>
  memset(disk.avail, 0, PGSIZE);
    80005c7c:	0001f497          	auipc	s1,0x1f
    80005c80:	d5448493          	addi	s1,s1,-684 # 800249d0 <disk>
    80005c84:	6605                	lui	a2,0x1
    80005c86:	4581                	li	a1,0
    80005c88:	6488                	ld	a0,8(s1)
    80005c8a:	95cfb0ef          	jal	80000de6 <memset>
  memset(disk.used, 0, PGSIZE);
    80005c8e:	6605                	lui	a2,0x1
    80005c90:	4581                	li	a1,0
    80005c92:	6888                	ld	a0,16(s1)
    80005c94:	952fb0ef          	jal	80000de6 <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    80005c98:	100017b7          	lui	a5,0x10001
    80005c9c:	4721                	li	a4,8
    80005c9e:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    80005ca0:	4098                	lw	a4,0(s1)
    80005ca2:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    80005ca6:	40d8                	lw	a4,4(s1)
    80005ca8:	08e7a223          	sw	a4,132(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    80005cac:	649c                	ld	a5,8(s1)
    80005cae:	0007869b          	sext.w	a3,a5
    80005cb2:	10001737          	lui	a4,0x10001
    80005cb6:	08d72823          	sw	a3,144(a4) # 10001090 <_entry-0x6fffef70>
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    80005cba:	9781                	srai	a5,a5,0x20
    80005cbc:	08f72a23          	sw	a5,148(a4)
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    80005cc0:	689c                	ld	a5,16(s1)
    80005cc2:	0007869b          	sext.w	a3,a5
    80005cc6:	0ad72023          	sw	a3,160(a4)
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    80005cca:	9781                	srai	a5,a5,0x20
    80005ccc:	0af72223          	sw	a5,164(a4)
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    80005cd0:	4785                	li	a5,1
    80005cd2:	c37c                	sw	a5,68(a4)
    disk.free[i] = 1;
    80005cd4:	00f48c23          	sb	a5,24(s1)
    80005cd8:	00f48ca3          	sb	a5,25(s1)
    80005cdc:	00f48d23          	sb	a5,26(s1)
    80005ce0:	00f48da3          	sb	a5,27(s1)
    80005ce4:	00f48e23          	sb	a5,28(s1)
    80005ce8:	00f48ea3          	sb	a5,29(s1)
    80005cec:	00f48f23          	sb	a5,30(s1)
    80005cf0:	00f48fa3          	sb	a5,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    80005cf4:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    80005cf8:	07272823          	sw	s2,112(a4)
}
    80005cfc:	60e2                	ld	ra,24(sp)
    80005cfe:	6442                	ld	s0,16(sp)
    80005d00:	64a2                	ld	s1,8(sp)
    80005d02:	6902                	ld	s2,0(sp)
    80005d04:	6105                	addi	sp,sp,32
    80005d06:	8082                	ret
    panic("could not find virtio disk");
    80005d08:	00003517          	auipc	a0,0x3
    80005d0c:	97050513          	addi	a0,a0,-1680 # 80008678 <etext+0x678>
    80005d10:	b47fa0ef          	jal	80000856 <panic>
    panic("virtio disk FEATURES_OK unset");
    80005d14:	00003517          	auipc	a0,0x3
    80005d18:	98450513          	addi	a0,a0,-1660 # 80008698 <etext+0x698>
    80005d1c:	b3bfa0ef          	jal	80000856 <panic>
    panic("virtio disk should not be ready");
    80005d20:	00003517          	auipc	a0,0x3
    80005d24:	99850513          	addi	a0,a0,-1640 # 800086b8 <etext+0x6b8>
    80005d28:	b2ffa0ef          	jal	80000856 <panic>
    panic("virtio disk has no queue 0");
    80005d2c:	00003517          	auipc	a0,0x3
    80005d30:	9ac50513          	addi	a0,a0,-1620 # 800086d8 <etext+0x6d8>
    80005d34:	b23fa0ef          	jal	80000856 <panic>
    panic("virtio disk max queue too short");
    80005d38:	00003517          	auipc	a0,0x3
    80005d3c:	9c050513          	addi	a0,a0,-1600 # 800086f8 <etext+0x6f8>
    80005d40:	b17fa0ef          	jal	80000856 <panic>
    panic("virtio disk kalloc");
    80005d44:	00003517          	auipc	a0,0x3
    80005d48:	9d450513          	addi	a0,a0,-1580 # 80008718 <etext+0x718>
    80005d4c:	b0bfa0ef          	jal	80000856 <panic>

0000000080005d50 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80005d50:	711d                	addi	sp,sp,-96
    80005d52:	ec86                	sd	ra,88(sp)
    80005d54:	e8a2                	sd	s0,80(sp)
    80005d56:	e4a6                	sd	s1,72(sp)
    80005d58:	e0ca                	sd	s2,64(sp)
    80005d5a:	fc4e                	sd	s3,56(sp)
    80005d5c:	f852                	sd	s4,48(sp)
    80005d5e:	f456                	sd	s5,40(sp)
    80005d60:	f05a                	sd	s6,32(sp)
    80005d62:	ec5e                	sd	s7,24(sp)
    80005d64:	e862                	sd	s8,16(sp)
    80005d66:	1080                	addi	s0,sp,96
    80005d68:	89aa                	mv	s3,a0
    80005d6a:	8b2e                	mv	s6,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    80005d6c:	00c52b83          	lw	s7,12(a0)
    80005d70:	001b9b9b          	slliw	s7,s7,0x1
    80005d74:	1b82                	slli	s7,s7,0x20
    80005d76:	020bdb93          	srli	s7,s7,0x20

  acquire(&disk.vdisk_lock);
    80005d7a:	0001f517          	auipc	a0,0x1f
    80005d7e:	d7e50513          	addi	a0,a0,-642 # 80024af8 <disk+0x128>
    80005d82:	f95fa0ef          	jal	80000d16 <acquire>
  for(int i = 0; i < NUM; i++){
    80005d86:	44a1                	li	s1,8
      disk.free[i] = 0;
    80005d88:	0001fa97          	auipc	s5,0x1f
    80005d8c:	c48a8a93          	addi	s5,s5,-952 # 800249d0 <disk>
  for(int i = 0; i < 3; i++){
    80005d90:	4a0d                	li	s4,3
    idx[i] = alloc_desc();
    80005d92:	5c7d                	li	s8,-1
    80005d94:	a095                	j	80005df8 <virtio_disk_rw+0xa8>
      disk.free[i] = 0;
    80005d96:	00fa8733          	add	a4,s5,a5
    80005d9a:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    80005d9e:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    80005da0:	0207c563          	bltz	a5,80005dca <virtio_disk_rw+0x7a>
  for(int i = 0; i < 3; i++){
    80005da4:	2905                	addiw	s2,s2,1
    80005da6:	0611                	addi	a2,a2,4 # 1004 <_entry-0x7fffeffc>
    80005da8:	05490c63          	beq	s2,s4,80005e00 <virtio_disk_rw+0xb0>
    idx[i] = alloc_desc();
    80005dac:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    80005dae:	0001f717          	auipc	a4,0x1f
    80005db2:	c2270713          	addi	a4,a4,-990 # 800249d0 <disk>
    80005db6:	4781                	li	a5,0
    if(disk.free[i]){
    80005db8:	01874683          	lbu	a3,24(a4)
    80005dbc:	fee9                	bnez	a3,80005d96 <virtio_disk_rw+0x46>
  for(int i = 0; i < NUM; i++){
    80005dbe:	2785                	addiw	a5,a5,1
    80005dc0:	0705                	addi	a4,a4,1
    80005dc2:	fe979be3          	bne	a5,s1,80005db8 <virtio_disk_rw+0x68>
    idx[i] = alloc_desc();
    80005dc6:	0185a023          	sw	s8,0(a1)
      for(int j = 0; j < i; j++)
    80005dca:	01205d63          	blez	s2,80005de4 <virtio_disk_rw+0x94>
        free_desc(idx[j]);
    80005dce:	fa042503          	lw	a0,-96(s0)
    80005dd2:	d41ff0ef          	jal	80005b12 <free_desc>
      for(int j = 0; j < i; j++)
    80005dd6:	4785                	li	a5,1
    80005dd8:	0127d663          	bge	a5,s2,80005de4 <virtio_disk_rw+0x94>
        free_desc(idx[j]);
    80005ddc:	fa442503          	lw	a0,-92(s0)
    80005de0:	d33ff0ef          	jal	80005b12 <free_desc>
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80005de4:	0001f597          	auipc	a1,0x1f
    80005de8:	d1458593          	addi	a1,a1,-748 # 80024af8 <disk+0x128>
    80005dec:	0001f517          	auipc	a0,0x1f
    80005df0:	bfc50513          	addi	a0,a0,-1028 # 800249e8 <disk+0x18>
    80005df4:	e60fc0ef          	jal	80002454 <sleep>
  for(int i = 0; i < 3; i++){
    80005df8:	fa040613          	addi	a2,s0,-96
    80005dfc:	4901                	li	s2,0
    80005dfe:	b77d                	j	80005dac <virtio_disk_rw+0x5c>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80005e00:	fa042503          	lw	a0,-96(s0)
    80005e04:	00451693          	slli	a3,a0,0x4

  if(write)
    80005e08:	0001f797          	auipc	a5,0x1f
    80005e0c:	bc878793          	addi	a5,a5,-1080 # 800249d0 <disk>
    80005e10:	00451713          	slli	a4,a0,0x4
    80005e14:	0a070713          	addi	a4,a4,160
    80005e18:	973e                	add	a4,a4,a5
    80005e1a:	01603633          	snez	a2,s6
    80005e1e:	c710                	sw	a2,8(a4)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    80005e20:	00072623          	sw	zero,12(a4)
  buf0->sector = sector;
    80005e24:	01773823          	sd	s7,16(a4)

  disk.desc[idx[0]].addr = (uint64) buf0;
    80005e28:	6398                	ld	a4,0(a5)
    80005e2a:	9736                	add	a4,a4,a3
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80005e2c:	0a868613          	addi	a2,a3,168 # 100010a8 <_entry-0x6fffef58>
    80005e30:	963e                	add	a2,a2,a5
  disk.desc[idx[0]].addr = (uint64) buf0;
    80005e32:	e310                	sd	a2,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    80005e34:	6390                	ld	a2,0(a5)
    80005e36:	00d60833          	add	a6,a2,a3
    80005e3a:	4741                	li	a4,16
    80005e3c:	00e82423          	sw	a4,8(a6)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    80005e40:	4585                	li	a1,1
    80005e42:	00b81623          	sh	a1,12(a6)
  disk.desc[idx[0]].next = idx[1];
    80005e46:	fa442703          	lw	a4,-92(s0)
    80005e4a:	00e81723          	sh	a4,14(a6)

  disk.desc[idx[1]].addr = (uint64) b->data;
    80005e4e:	0712                	slli	a4,a4,0x4
    80005e50:	963a                	add	a2,a2,a4
    80005e52:	05898813          	addi	a6,s3,88
    80005e56:	01063023          	sd	a6,0(a2)
  disk.desc[idx[1]].len = BSIZE;
    80005e5a:	0007b883          	ld	a7,0(a5)
    80005e5e:	9746                	add	a4,a4,a7
    80005e60:	40000613          	li	a2,1024
    80005e64:	c710                	sw	a2,8(a4)
  if(write)
    80005e66:	001b3613          	seqz	a2,s6
    80005e6a:	0016161b          	slliw	a2,a2,0x1
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    80005e6e:	8e4d                	or	a2,a2,a1
    80005e70:	00c71623          	sh	a2,12(a4)
  disk.desc[idx[1]].next = idx[2];
    80005e74:	fa842603          	lw	a2,-88(s0)
    80005e78:	00c71723          	sh	a2,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    80005e7c:	00451813          	slli	a6,a0,0x4
    80005e80:	02080813          	addi	a6,a6,32
    80005e84:	983e                	add	a6,a6,a5
    80005e86:	577d                	li	a4,-1
    80005e88:	00e80823          	sb	a4,16(a6)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    80005e8c:	0612                	slli	a2,a2,0x4
    80005e8e:	98b2                	add	a7,a7,a2
    80005e90:	03068713          	addi	a4,a3,48
    80005e94:	973e                	add	a4,a4,a5
    80005e96:	00e8b023          	sd	a4,0(a7)
  disk.desc[idx[2]].len = 1;
    80005e9a:	6398                	ld	a4,0(a5)
    80005e9c:	9732                	add	a4,a4,a2
    80005e9e:	c70c                	sw	a1,8(a4)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    80005ea0:	4689                	li	a3,2
    80005ea2:	00d71623          	sh	a3,12(a4)
  disk.desc[idx[2]].next = 0;
    80005ea6:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    80005eaa:	00b9a223          	sw	a1,4(s3)
  disk.info[idx[0]].b = b;
    80005eae:	01383423          	sd	s3,8(a6)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    80005eb2:	6794                	ld	a3,8(a5)
    80005eb4:	0026d703          	lhu	a4,2(a3)
    80005eb8:	8b1d                	andi	a4,a4,7
    80005eba:	0706                	slli	a4,a4,0x1
    80005ebc:	96ba                	add	a3,a3,a4
    80005ebe:	00a69223          	sh	a0,4(a3)

  __sync_synchronize();
    80005ec2:	0330000f          	fence	rw,rw

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    80005ec6:	6798                	ld	a4,8(a5)
    80005ec8:	00275783          	lhu	a5,2(a4)
    80005ecc:	2785                	addiw	a5,a5,1
    80005ece:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    80005ed2:	0330000f          	fence	rw,rw

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80005ed6:	100017b7          	lui	a5,0x10001
    80005eda:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    80005ede:	0049a783          	lw	a5,4(s3)
    sleep(b, &disk.vdisk_lock);
    80005ee2:	0001f917          	auipc	s2,0x1f
    80005ee6:	c1690913          	addi	s2,s2,-1002 # 80024af8 <disk+0x128>
  while(b->disk == 1) {
    80005eea:	84ae                	mv	s1,a1
    80005eec:	00b79a63          	bne	a5,a1,80005f00 <virtio_disk_rw+0x1b0>
    sleep(b, &disk.vdisk_lock);
    80005ef0:	85ca                	mv	a1,s2
    80005ef2:	854e                	mv	a0,s3
    80005ef4:	d60fc0ef          	jal	80002454 <sleep>
  while(b->disk == 1) {
    80005ef8:	0049a783          	lw	a5,4(s3)
    80005efc:	fe978ae3          	beq	a5,s1,80005ef0 <virtio_disk_rw+0x1a0>
  }

  disk.info[idx[0]].b = 0;
    80005f00:	fa042903          	lw	s2,-96(s0)
    80005f04:	00491713          	slli	a4,s2,0x4
    80005f08:	02070713          	addi	a4,a4,32
    80005f0c:	0001f797          	auipc	a5,0x1f
    80005f10:	ac478793          	addi	a5,a5,-1340 # 800249d0 <disk>
    80005f14:	97ba                	add	a5,a5,a4
    80005f16:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    80005f1a:	0001f997          	auipc	s3,0x1f
    80005f1e:	ab698993          	addi	s3,s3,-1354 # 800249d0 <disk>
    80005f22:	00491713          	slli	a4,s2,0x4
    80005f26:	0009b783          	ld	a5,0(s3)
    80005f2a:	97ba                	add	a5,a5,a4
    80005f2c:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    80005f30:	854a                	mv	a0,s2
    80005f32:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    80005f36:	bddff0ef          	jal	80005b12 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    80005f3a:	8885                	andi	s1,s1,1
    80005f3c:	f0fd                	bnez	s1,80005f22 <virtio_disk_rw+0x1d2>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    80005f3e:	0001f517          	auipc	a0,0x1f
    80005f42:	bba50513          	addi	a0,a0,-1094 # 80024af8 <disk+0x128>
    80005f46:	e65fa0ef          	jal	80000daa <release>
}
    80005f4a:	60e6                	ld	ra,88(sp)
    80005f4c:	6446                	ld	s0,80(sp)
    80005f4e:	64a6                	ld	s1,72(sp)
    80005f50:	6906                	ld	s2,64(sp)
    80005f52:	79e2                	ld	s3,56(sp)
    80005f54:	7a42                	ld	s4,48(sp)
    80005f56:	7aa2                	ld	s5,40(sp)
    80005f58:	7b02                	ld	s6,32(sp)
    80005f5a:	6be2                	ld	s7,24(sp)
    80005f5c:	6c42                	ld	s8,16(sp)
    80005f5e:	6125                	addi	sp,sp,96
    80005f60:	8082                	ret

0000000080005f62 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    80005f62:	1101                	addi	sp,sp,-32
    80005f64:	ec06                	sd	ra,24(sp)
    80005f66:	e822                	sd	s0,16(sp)
    80005f68:	e426                	sd	s1,8(sp)
    80005f6a:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    80005f6c:	0001f497          	auipc	s1,0x1f
    80005f70:	a6448493          	addi	s1,s1,-1436 # 800249d0 <disk>
    80005f74:	0001f517          	auipc	a0,0x1f
    80005f78:	b8450513          	addi	a0,a0,-1148 # 80024af8 <disk+0x128>
    80005f7c:	d9bfa0ef          	jal	80000d16 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    80005f80:	100017b7          	lui	a5,0x10001
    80005f84:	53bc                	lw	a5,96(a5)
    80005f86:	8b8d                	andi	a5,a5,3
    80005f88:	10001737          	lui	a4,0x10001
    80005f8c:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    80005f8e:	0330000f          	fence	rw,rw

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    80005f92:	689c                	ld	a5,16(s1)
    80005f94:	0204d703          	lhu	a4,32(s1)
    80005f98:	0027d783          	lhu	a5,2(a5) # 10001002 <_entry-0x6fffeffe>
    80005f9c:	04f70863          	beq	a4,a5,80005fec <virtio_disk_intr+0x8a>
    __sync_synchronize();
    80005fa0:	0330000f          	fence	rw,rw
    int id = disk.used->ring[disk.used_idx % NUM].id;
    80005fa4:	6898                	ld	a4,16(s1)
    80005fa6:	0204d783          	lhu	a5,32(s1)
    80005faa:	8b9d                	andi	a5,a5,7
    80005fac:	078e                	slli	a5,a5,0x3
    80005fae:	97ba                	add	a5,a5,a4
    80005fb0:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    80005fb2:	00479713          	slli	a4,a5,0x4
    80005fb6:	02070713          	addi	a4,a4,32 # 10001020 <_entry-0x6fffefe0>
    80005fba:	9726                	add	a4,a4,s1
    80005fbc:	01074703          	lbu	a4,16(a4)
    80005fc0:	e329                	bnez	a4,80006002 <virtio_disk_intr+0xa0>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    80005fc2:	0792                	slli	a5,a5,0x4
    80005fc4:	02078793          	addi	a5,a5,32
    80005fc8:	97a6                	add	a5,a5,s1
    80005fca:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    80005fcc:	00052223          	sw	zero,4(a0)
    wakeup(b);
    80005fd0:	cd0fc0ef          	jal	800024a0 <wakeup>

    disk.used_idx += 1;
    80005fd4:	0204d783          	lhu	a5,32(s1)
    80005fd8:	2785                	addiw	a5,a5,1
    80005fda:	17c2                	slli	a5,a5,0x30
    80005fdc:	93c1                	srli	a5,a5,0x30
    80005fde:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    80005fe2:	6898                	ld	a4,16(s1)
    80005fe4:	00275703          	lhu	a4,2(a4)
    80005fe8:	faf71ce3          	bne	a4,a5,80005fa0 <virtio_disk_intr+0x3e>
  }

  release(&disk.vdisk_lock);
    80005fec:	0001f517          	auipc	a0,0x1f
    80005ff0:	b0c50513          	addi	a0,a0,-1268 # 80024af8 <disk+0x128>
    80005ff4:	db7fa0ef          	jal	80000daa <release>
}
    80005ff8:	60e2                	ld	ra,24(sp)
    80005ffa:	6442                	ld	s0,16(sp)
    80005ffc:	64a2                	ld	s1,8(sp)
    80005ffe:	6105                	addi	sp,sp,32
    80006000:	8082                	ret
      panic("virtio_disk_intr status");
    80006002:	00002517          	auipc	a0,0x2
    80006006:	72e50513          	addi	a0,a0,1838 # 80008730 <etext+0x730>
    8000600a:	84dfa0ef          	jal	80000856 <panic>

000000008000600e <cslog_init>:
  safestrcpy(e->name, p->name, CS_NM);
}

void
cslog_init(void)
{
    8000600e:	1141                	addi	sp,sp,-16
    80006010:	e406                	sd	ra,8(sp)
    80006012:	e022                	sd	s0,0(sp)
    80006014:	0800                	addi	s0,sp,16
  ringbuf_init(&cs_rb, "cslog", sizeof(struct cs_event));
    80006016:	03000613          	li	a2,48
    8000601a:	00002597          	auipc	a1,0x2
    8000601e:	72e58593          	addi	a1,a1,1838 # 80008748 <etext+0x748>
    80006022:	0001f517          	auipc	a0,0x1f
    80006026:	aee50513          	addi	a0,a0,-1298 # 80024b10 <cs_rb>
    8000602a:	1a2000ef          	jal	800061cc <ringbuf_init>
}
    8000602e:	60a2                	ld	ra,8(sp)
    80006030:	6402                	ld	s0,0(sp)
    80006032:	0141                	addi	sp,sp,16
    80006034:	8082                	ret

0000000080006036 <cslog_push>:

void
cslog_push(struct cs_event *e)
{
    80006036:	1141                	addi	sp,sp,-16
    80006038:	e406                	sd	ra,8(sp)
    8000603a:	e022                	sd	s0,0(sp)
    8000603c:	0800                	addi	s0,sp,16
    8000603e:	85aa                	mv	a1,a0
  e->seq = ++cs_seq;
    80006040:	00005717          	auipc	a4,0x5
    80006044:	75870713          	addi	a4,a4,1880 # 8000b798 <cs_seq>
    80006048:	631c                	ld	a5,0(a4)
    8000604a:	0785                	addi	a5,a5,1
    8000604c:	e31c                	sd	a5,0(a4)
    8000604e:	e11c                	sd	a5,0(a0)
  ringbuf_push(&cs_rb, e);
    80006050:	0001f517          	auipc	a0,0x1f
    80006054:	ac050513          	addi	a0,a0,-1344 # 80024b10 <cs_rb>
    80006058:	1a8000ef          	jal	80006200 <ringbuf_push>
}
    8000605c:	60a2                	ld	ra,8(sp)
    8000605e:	6402                	ld	s0,0(sp)
    80006060:	0141                	addi	sp,sp,16
    80006062:	8082                	ret

0000000080006064 <cslog_read_many>:

int
cslog_read_many(struct cs_event *out, int max)
{
    80006064:	1141                	addi	sp,sp,-16
    80006066:	e406                	sd	ra,8(sp)
    80006068:	e022                	sd	s0,0(sp)
    8000606a:	0800                	addi	s0,sp,16
    8000606c:	862e                	mv	a2,a1
  return ringbuf_read_many(&cs_rb, out, max);
    8000606e:	85aa                	mv	a1,a0
    80006070:	0001f517          	auipc	a0,0x1f
    80006074:	aa050513          	addi	a0,a0,-1376 # 80024b10 <cs_rb>
    80006078:	1f4000ef          	jal	8000626c <ringbuf_read_many>
}
    8000607c:	60a2                	ld	ra,8(sp)
    8000607e:	6402                	ld	s0,0(sp)
    80006080:	0141                	addi	sp,sp,16
    80006082:	8082                	ret

0000000080006084 <cslog_run_start>:

void
cslog_run_start(struct proc *p)
{
  if(p == 0) return;
    80006084:	c14d                	beqz	a0,80006126 <cslog_run_start+0xa2>
{
    80006086:	715d                	addi	sp,sp,-80
    80006088:	e486                	sd	ra,72(sp)
    8000608a:	e0a2                	sd	s0,64(sp)
    8000608c:	fc26                	sd	s1,56(sp)
    8000608e:	0880                	addi	s0,sp,80
    80006090:	84aa                	mv	s1,a0
  if(p->pid <= 0) return;
    80006092:	591c                	lw	a5,48(a0)
    80006094:	00f05563          	blez	a5,8000609e <cslog_run_start+0x1a>
  if(p->name[0] == 0) return;
    80006098:	15854783          	lbu	a5,344(a0)
    8000609c:	e791                	bnez	a5,800060a8 <cslog_run_start+0x24>

  struct cs_event e;
  fill_from_proc(&e, p);
  e.type = CS_RUN_START;
  cslog_push(&e);
    8000609e:	60a6                	ld	ra,72(sp)
    800060a0:	6406                	ld	s0,64(sp)
    800060a2:	74e2                	ld	s1,56(sp)
    800060a4:	6161                	addi	sp,sp,80
    800060a6:	8082                	ret
    800060a8:	f84a                	sd	s2,48(sp)
  if(strncmp(p->name, "cscat", 5) == 0) return;
    800060aa:	15850913          	addi	s2,a0,344
    800060ae:	4615                	li	a2,5
    800060b0:	00002597          	auipc	a1,0x2
    800060b4:	6a058593          	addi	a1,a1,1696 # 80008750 <etext+0x750>
    800060b8:	854a                	mv	a0,s2
    800060ba:	e01fa0ef          	jal	80000eba <strncmp>
    800060be:	e119                	bnez	a0,800060c4 <cslog_run_start+0x40>
    800060c0:	7942                	ld	s2,48(sp)
    800060c2:	bff1                	j	8000609e <cslog_run_start+0x1a>
  if(strncmp(p->name, "csexport", 8) == 0) return;
    800060c4:	4621                	li	a2,8
    800060c6:	00002597          	auipc	a1,0x2
    800060ca:	69258593          	addi	a1,a1,1682 # 80008758 <etext+0x758>
    800060ce:	854a                	mv	a0,s2
    800060d0:	debfa0ef          	jal	80000eba <strncmp>
    800060d4:	e119                	bnez	a0,800060da <cslog_run_start+0x56>
    800060d6:	7942                	ld	s2,48(sp)
    800060d8:	b7d9                	j	8000609e <cslog_run_start+0x1a>
  memset(e, 0, sizeof(*e));
    800060da:	03000613          	li	a2,48
    800060de:	4581                	li	a1,0
    800060e0:	fb040513          	addi	a0,s0,-80
    800060e4:	d03fa0ef          	jal	80000de6 <memset>
  e->ticks = ticks;
    800060e8:	00005797          	auipc	a5,0x5
    800060ec:	6a87a783          	lw	a5,1704(a5) # 8000b790 <ticks>
    800060f0:	faf42c23          	sw	a5,-72(s0)
  e->cpu   = cpuid();
    800060f4:	b01fb0ef          	jal	80001bf4 <cpuid>
    800060f8:	faa42e23          	sw	a0,-68(s0)
  e->pid   = p->pid;
    800060fc:	589c                	lw	a5,48(s1)
    800060fe:	fcf42223          	sw	a5,-60(s0)
  e->state = p->state;
    80006102:	4c9c                	lw	a5,24(s1)
    80006104:	fcf42423          	sw	a5,-56(s0)
  safestrcpy(e->name, p->name, CS_NM);
    80006108:	4641                	li	a2,16
    8000610a:	85ca                	mv	a1,s2
    8000610c:	fcc40513          	addi	a0,s0,-52
    80006110:	e2bfa0ef          	jal	80000f3a <safestrcpy>
  e.type = CS_RUN_START;
    80006114:	4785                	li	a5,1
    80006116:	fcf42023          	sw	a5,-64(s0)
  cslog_push(&e);
    8000611a:	fb040513          	addi	a0,s0,-80
    8000611e:	f19ff0ef          	jal	80006036 <cslog_push>
    80006122:	7942                	ld	s2,48(sp)
    80006124:	bfad                	j	8000609e <cslog_run_start+0x1a>
    80006126:	8082                	ret

0000000080006128 <sys_csread>:
#include "cslog.h"


uint64
sys_csread(void)
{
    80006128:	81010113          	addi	sp,sp,-2032
    8000612c:	7e113423          	sd	ra,2024(sp)
    80006130:	7e813023          	sd	s0,2016(sp)
    80006134:	7c913c23          	sd	s1,2008(sp)
    80006138:	7d213823          	sd	s2,2000(sp)
    8000613c:	7f010413          	addi	s0,sp,2032
    80006140:	bc010113          	addi	sp,sp,-1088
  uint64 uaddr = 0;
    80006144:	fc043c23          	sd	zero,-40(s0)
  int max = 0;
    80006148:	fc042a23          	sw	zero,-44(s0)

  // ✅ عندك argaddr/argint void، فبنستدعيهم بدون if
  argaddr(0, &uaddr);
    8000614c:	fd840593          	addi	a1,s0,-40
    80006150:	4501                	li	a0,0
    80006152:	c2bfc0ef          	jal	80002d7c <argaddr>
  argint(1, &max);
    80006156:	fd440593          	addi	a1,s0,-44
    8000615a:	4505                	li	a0,1
    8000615c:	c05fc0ef          	jal	80002d60 <argint>

  if(max <= 0) return 0;
    80006160:	fd442783          	lw	a5,-44(s0)
    80006164:	4501                	li	a0,0
    80006166:	04f05463          	blez	a5,800061ae <sys_csread+0x86>
  if(max > 64) max = 64;
    8000616a:	04000713          	li	a4,64
    8000616e:	00f75463          	bge	a4,a5,80006176 <sys_csread+0x4e>
    80006172:	fce42a23          	sw	a4,-44(s0)

  struct cs_event tmp[64];
  int n = cslog_read_many(tmp, max);
    80006176:	80040493          	addi	s1,s0,-2048
    8000617a:	1481                	addi	s1,s1,-32
    8000617c:	bf048493          	addi	s1,s1,-1040
    80006180:	fd442583          	lw	a1,-44(s0)
    80006184:	8526                	mv	a0,s1
    80006186:	edfff0ef          	jal	80006064 <cslog_read_many>
    8000618a:	892a                	mv	s2,a0

  int bytes = n * (int)sizeof(struct cs_event);
  if(copyout(myproc()->pagetable, uaddr, (char*)tmp, bytes) < 0)
    8000618c:	a9dfb0ef          	jal	80001c28 <myproc>
  int bytes = n * (int)sizeof(struct cs_event);
    80006190:	0019169b          	slliw	a3,s2,0x1
    80006194:	012686bb          	addw	a3,a3,s2
  if(copyout(myproc()->pagetable, uaddr, (char*)tmp, bytes) < 0)
    80006198:	0046969b          	slliw	a3,a3,0x4
    8000619c:	8626                	mv	a2,s1
    8000619e:	fd843583          	ld	a1,-40(s0)
    800061a2:	6928                	ld	a0,80(a0)
    800061a4:	f96fb0ef          	jal	8000193a <copyout>
    800061a8:	02054063          	bltz	a0,800061c8 <sys_csread+0xa0>
    return -1;

  return n;
    800061ac:	854a                	mv	a0,s2
}
    800061ae:	44010113          	addi	sp,sp,1088
    800061b2:	7e813083          	ld	ra,2024(sp)
    800061b6:	7e013403          	ld	s0,2016(sp)
    800061ba:	7d813483          	ld	s1,2008(sp)
    800061be:	7d013903          	ld	s2,2000(sp)
    800061c2:	7f010113          	addi	sp,sp,2032
    800061c6:	8082                	ret
    return -1;
    800061c8:	557d                	li	a0,-1
    800061ca:	b7d5                	j	800061ae <sys_csread+0x86>

00000000800061cc <ringbuf_init>:
  return (void *)(rb->buf + idx * rb->elem_size);
}

void
ringbuf_init(struct ringbuf *rb, char *name, uint elem_size)
{
    800061cc:	1101                	addi	sp,sp,-32
    800061ce:	ec06                	sd	ra,24(sp)
    800061d0:	e822                	sd	s0,16(sp)
    800061d2:	e426                	sd	s1,8(sp)
    800061d4:	e04a                	sd	s2,0(sp)
    800061d6:	1000                	addi	s0,sp,32
    800061d8:	84aa                	mv	s1,a0
    800061da:	8932                	mv	s2,a2
  initlock(&rb->lock, name);
    800061dc:	ab1fa0ef          	jal	80000c8c <initlock>
  rb->head = 0;
    800061e0:	0004ac23          	sw	zero,24(s1)
  rb->tail = 0;
    800061e4:	0004ae23          	sw	zero,28(s1)
  rb->count = 0;
    800061e8:	0204a023          	sw	zero,32(s1)
  rb->seq = 0;
    800061ec:	0204b423          	sd	zero,40(s1)
  rb->elem_size = elem_size;
    800061f0:	0324a223          	sw	s2,36(s1)
}
    800061f4:	60e2                	ld	ra,24(sp)
    800061f6:	6442                	ld	s0,16(sp)
    800061f8:	64a2                	ld	s1,8(sp)
    800061fa:	6902                	ld	s2,0(sp)
    800061fc:	6105                	addi	sp,sp,32
    800061fe:	8082                	ret

0000000080006200 <ringbuf_push>:

int
ringbuf_push(struct ringbuf *rb, void *elem)
{
    80006200:	1101                	addi	sp,sp,-32
    80006202:	ec06                	sd	ra,24(sp)
    80006204:	e822                	sd	s0,16(sp)
    80006206:	e426                	sd	s1,8(sp)
    80006208:	e04a                	sd	s2,0(sp)
    8000620a:	1000                	addi	s0,sp,32
    8000620c:	84aa                	mv	s1,a0
    8000620e:	892e                	mv	s2,a1
  acquire(&rb->lock);
    80006210:	b07fa0ef          	jal	80000d16 <acquire>

  if(rb->count == RB_CAP){
    80006214:	5098                	lw	a4,32(s1)
    80006216:	20000793          	li	a5,512
    8000621a:	04f70063          	beq	a4,a5,8000625a <ringbuf_push+0x5a>
  return (void *)(rb->buf + idx * rb->elem_size);
    8000621e:	50d0                	lw	a2,36(s1)
    80006220:	03048513          	addi	a0,s1,48
    80006224:	4c9c                	lw	a5,24(s1)
    80006226:	02c787bb          	mulw	a5,a5,a2
    8000622a:	1782                	slli	a5,a5,0x20
    8000622c:	9381                	srli	a5,a5,0x20
    rb->tail = (rb->tail + 1) % RB_CAP;
    rb->count--;
  }

  memmove(slot_ptr(rb, rb->head), elem, rb->elem_size);
    8000622e:	85ca                	mv	a1,s2
    80006230:	953e                	add	a0,a0,a5
    80006232:	c15fa0ef          	jal	80000e46 <memmove>
  rb->head = (rb->head + 1) % RB_CAP;
    80006236:	4c9c                	lw	a5,24(s1)
    80006238:	2785                	addiw	a5,a5,1
    8000623a:	1ff7f793          	andi	a5,a5,511
    8000623e:	cc9c                	sw	a5,24(s1)
  rb->count++;
    80006240:	509c                	lw	a5,32(s1)
    80006242:	2785                	addiw	a5,a5,1
    80006244:	d09c                	sw	a5,32(s1)

  release(&rb->lock);
    80006246:	8526                	mv	a0,s1
    80006248:	b63fa0ef          	jal	80000daa <release>
  return 0;
}
    8000624c:	4501                	li	a0,0
    8000624e:	60e2                	ld	ra,24(sp)
    80006250:	6442                	ld	s0,16(sp)
    80006252:	64a2                	ld	s1,8(sp)
    80006254:	6902                	ld	s2,0(sp)
    80006256:	6105                	addi	sp,sp,32
    80006258:	8082                	ret
    rb->tail = (rb->tail + 1) % RB_CAP;
    8000625a:	4cdc                	lw	a5,28(s1)
    8000625c:	2785                	addiw	a5,a5,1
    8000625e:	1ff7f793          	andi	a5,a5,511
    80006262:	ccdc                	sw	a5,28(s1)
    rb->count--;
    80006264:	1ff00793          	li	a5,511
    80006268:	d09c                	sw	a5,32(s1)
    8000626a:	bf55                	j	8000621e <ringbuf_push+0x1e>

000000008000626c <ringbuf_read_many>:
ringbuf_read_many(struct ringbuf *rb, void *out, int max)
{
  int n = 0;
  char *dst = (char *)out;

  if(max <= 0)
    8000626c:	06c05d63          	blez	a2,800062e6 <ringbuf_read_many+0x7a>
{
    80006270:	7139                	addi	sp,sp,-64
    80006272:	fc06                	sd	ra,56(sp)
    80006274:	f822                	sd	s0,48(sp)
    80006276:	f426                	sd	s1,40(sp)
    80006278:	f04a                	sd	s2,32(sp)
    8000627a:	ec4e                	sd	s3,24(sp)
    8000627c:	e852                	sd	s4,16(sp)
    8000627e:	e456                	sd	s5,8(sp)
    80006280:	0080                	addi	s0,sp,64
    80006282:	84aa                	mv	s1,a0
    80006284:	8a2e                	mv	s4,a1
    80006286:	89b2                	mv	s3,a2
    return 0;

  acquire(&rb->lock);
    80006288:	a8ffa0ef          	jal	80000d16 <acquire>
  int n = 0;
    8000628c:	4901                	li	s2,0
  return (void *)(rb->buf + idx * rb->elem_size);
    8000628e:	03048a93          	addi	s5,s1,48
  while(n < max && rb->count > 0){
    80006292:	509c                	lw	a5,32(s1)
    80006294:	c7b9                	beqz	a5,800062e2 <ringbuf_read_many+0x76>
    memmove(dst + n * rb->elem_size, slot_ptr(rb, rb->tail), rb->elem_size);
    80006296:	50d0                	lw	a2,36(s1)
  return (void *)(rb->buf + idx * rb->elem_size);
    80006298:	4ccc                	lw	a1,28(s1)
    8000629a:	02c585bb          	mulw	a1,a1,a2
    8000629e:	1582                	slli	a1,a1,0x20
    800062a0:	9181                	srli	a1,a1,0x20
    memmove(dst + n * rb->elem_size, slot_ptr(rb, rb->tail), rb->elem_size);
    800062a2:	02c9053b          	mulw	a0,s2,a2
    800062a6:	1502                	slli	a0,a0,0x20
    800062a8:	9101                	srli	a0,a0,0x20
    800062aa:	95d6                	add	a1,a1,s5
    800062ac:	9552                	add	a0,a0,s4
    800062ae:	b99fa0ef          	jal	80000e46 <memmove>
    rb->tail = (rb->tail + 1) % RB_CAP;
    800062b2:	4cdc                	lw	a5,28(s1)
    800062b4:	2785                	addiw	a5,a5,1
    800062b6:	1ff7f793          	andi	a5,a5,511
    800062ba:	ccdc                	sw	a5,28(s1)
    rb->count--;
    800062bc:	509c                	lw	a5,32(s1)
    800062be:	37fd                	addiw	a5,a5,-1
    800062c0:	d09c                	sw	a5,32(s1)
    n++;
    800062c2:	2905                	addiw	s2,s2,1
  while(n < max && rb->count > 0){
    800062c4:	fd2997e3          	bne	s3,s2,80006292 <ringbuf_read_many+0x26>
  }
  release(&rb->lock);
    800062c8:	8526                	mv	a0,s1
    800062ca:	ae1fa0ef          	jal	80000daa <release>

  return n;
    800062ce:	854e                	mv	a0,s3
}
    800062d0:	70e2                	ld	ra,56(sp)
    800062d2:	7442                	ld	s0,48(sp)
    800062d4:	74a2                	ld	s1,40(sp)
    800062d6:	7902                	ld	s2,32(sp)
    800062d8:	69e2                	ld	s3,24(sp)
    800062da:	6a42                	ld	s4,16(sp)
    800062dc:	6aa2                	ld	s5,8(sp)
    800062de:	6121                	addi	sp,sp,64
    800062e0:	8082                	ret
    800062e2:	89ca                	mv	s3,s2
    800062e4:	b7d5                	j	800062c8 <ringbuf_read_many+0x5c>
    return 0;
    800062e6:	4501                	li	a0,0
}
    800062e8:	8082                	ret

00000000800062ea <ringbuf_pop>:
int
ringbuf_pop(struct ringbuf *rb, void *dst)
{
    800062ea:	1101                	addi	sp,sp,-32
    800062ec:	ec06                	sd	ra,24(sp)
    800062ee:	e822                	sd	s0,16(sp)
    800062f0:	e426                	sd	s1,8(sp)
    800062f2:	e04a                	sd	s2,0(sp)
    800062f4:	1000                	addi	s0,sp,32
    800062f6:	84aa                	mv	s1,a0
    800062f8:	892e                	mv	s2,a1
  acquire(&rb->lock);
    800062fa:	a1dfa0ef          	jal	80000d16 <acquire>
  
  if(rb->count == 0){ // البفر فارغ تماماً
    800062fe:	509c                	lw	a5,32(s1)
    80006300:	cf9d                	beqz	a5,8000633e <ringbuf_pop+0x54>
  return (void *)(rb->buf + idx * rb->elem_size);
    80006302:	50d0                	lw	a2,36(s1)
    80006304:	03048593          	addi	a1,s1,48
    80006308:	4cdc                	lw	a5,28(s1)
    8000630a:	02c787bb          	mulw	a5,a5,a2
    8000630e:	1782                	slli	a5,a5,0x20
    80006310:	9381                	srli	a5,a5,0x20
    return -1;
  }

  // استخدام الدالة المساعدة slot_ptr الموجودة عندك أصلاً
  void *src = slot_ptr(rb, rb->tail);
  memmove(dst, src, rb->elem_size);
    80006312:	95be                	add	a1,a1,a5
    80006314:	854a                	mv	a0,s2
    80006316:	b31fa0ef          	jal	80000e46 <memmove>
  
  // تحديث المؤشرات بنفس منطق المشروع
  rb->tail = (rb->tail + 1) % RB_CAP;
    8000631a:	4cdc                	lw	a5,28(s1)
    8000631c:	2785                	addiw	a5,a5,1
    8000631e:	1ff7f793          	andi	a5,a5,511
    80006322:	ccdc                	sw	a5,28(s1)
  rb->count--;
    80006324:	509c                	lw	a5,32(s1)
    80006326:	37fd                	addiw	a5,a5,-1
    80006328:	d09c                	sw	a5,32(s1)
  
  release(&rb->lock);
    8000632a:	8526                	mv	a0,s1
    8000632c:	a7ffa0ef          	jal	80000daa <release>
  return 0;
    80006330:	4501                	li	a0,0
} 
    80006332:	60e2                	ld	ra,24(sp)
    80006334:	6442                	ld	s0,16(sp)
    80006336:	64a2                	ld	s1,8(sp)
    80006338:	6902                	ld	s2,0(sp)
    8000633a:	6105                	addi	sp,sp,32
    8000633c:	8082                	ret
    release(&rb->lock);
    8000633e:	8526                	mv	a0,s1
    80006340:	a6bfa0ef          	jal	80000daa <release>
    return -1;
    80006344:	557d                	li	a0,-1
    80006346:	b7f5                	j	80006332 <ringbuf_pop+0x48>

0000000080006348 <fslog_init>:
#include "defs.h"

static struct ringbuf fs_rb;
static uint64 fs_seq = 0;

void fslog_init(void) {
    80006348:	1141                	addi	sp,sp,-16
    8000634a:	e406                	sd	ra,8(sp)
    8000634c:	e022                	sd	s0,0(sp)
    8000634e:	0800                	addi	s0,sp,16
  ringbuf_init(&fs_rb, "fslog", sizeof(struct fs_event));
    80006350:	03000613          	li	a2,48
    80006354:	00002597          	auipc	a1,0x2
    80006358:	41458593          	addi	a1,a1,1044 # 80008768 <etext+0x768>
    8000635c:	00026517          	auipc	a0,0x26
    80006360:	7e450513          	addi	a0,a0,2020 # 8002cb40 <fs_rb>
    80006364:	e69ff0ef          	jal	800061cc <ringbuf_init>
}
    80006368:	60a2                	ld	ra,8(sp)
    8000636a:	6402                	ld	s0,0(sp)
    8000636c:	0141                	addi	sp,sp,16
    8000636e:	8082                	ret

0000000080006370 <fslog_push>:

void fslog_push(int type, int inum, int bno, uint size, char* name) {
    80006370:	7159                	addi	sp,sp,-112
    80006372:	f486                	sd	ra,104(sp)
    80006374:	f0a2                	sd	s0,96(sp)
    80006376:	eca6                	sd	s1,88(sp)
    80006378:	e8ca                	sd	s2,80(sp)
    8000637a:	e4ce                	sd	s3,72(sp)
    8000637c:	e0d2                	sd	s4,64(sp)
    8000637e:	fc56                	sd	s5,56(sp)
    80006380:	1880                	addi	s0,sp,112
    80006382:	84aa                	mv	s1,a0
    80006384:	892e                	mv	s2,a1
    80006386:	89b2                	mv	s3,a2
    80006388:	8a36                	mv	s4,a3
    8000638a:	8aba                	mv	s5,a4
  struct fs_event e;
  memset(&e, 0, sizeof(e));
    8000638c:	03000613          	li	a2,48
    80006390:	4581                	li	a1,0
    80006392:	f9040513          	addi	a0,s0,-112
    80006396:	a51fa0ef          	jal	80000de6 <memset>
  e.seq = ++fs_seq;
    8000639a:	00005717          	auipc	a4,0x5
    8000639e:	40670713          	addi	a4,a4,1030 # 8000b7a0 <fs_seq>
    800063a2:	631c                	ld	a5,0(a4)
    800063a4:	0785                	addi	a5,a5,1
    800063a6:	e31c                	sd	a5,0(a4)
    800063a8:	f8f43823          	sd	a5,-112(s0)
  e.ticks = ticks;
    800063ac:	00005797          	auipc	a5,0x5
    800063b0:	3e47a783          	lw	a5,996(a5) # 8000b790 <ticks>
    800063b4:	f8f42c23          	sw	a5,-104(s0)
  e.type = type;
    800063b8:	f8942e23          	sw	s1,-100(s0)
  e.pid = myproc() ? myproc()->pid : 0;
    800063bc:	86dfb0ef          	jal	80001c28 <myproc>
    800063c0:	4781                	li	a5,0
    800063c2:	c501                	beqz	a0,800063ca <fslog_push+0x5a>
    800063c4:	865fb0ef          	jal	80001c28 <myproc>
    800063c8:	591c                	lw	a5,48(a0)
    800063ca:	faf42023          	sw	a5,-96(s0)
  e.inum = inum;
    800063ce:	fb242223          	sw	s2,-92(s0)
  e.blockno = bno;
    800063d2:	fb342423          	sw	s3,-88(s0)
  e.size = size;
    800063d6:	fb442623          	sw	s4,-84(s0)
  if(name) safestrcpy(e.name, name, FS_NM);
    800063da:	000a8863          	beqz	s5,800063ea <fslog_push+0x7a>
    800063de:	4641                	li	a2,16
    800063e0:	85d6                	mv	a1,s5
    800063e2:	fb040513          	addi	a0,s0,-80
    800063e6:	b55fa0ef          	jal	80000f3a <safestrcpy>
  ringbuf_push(&fs_rb, &e);
    800063ea:	f9040593          	addi	a1,s0,-112
    800063ee:	00026517          	auipc	a0,0x26
    800063f2:	75250513          	addi	a0,a0,1874 # 8002cb40 <fs_rb>
    800063f6:	e0bff0ef          	jal	80006200 <ringbuf_push>
}
    800063fa:	70a6                	ld	ra,104(sp)
    800063fc:	7406                	ld	s0,96(sp)
    800063fe:	64e6                	ld	s1,88(sp)
    80006400:	6946                	ld	s2,80(sp)
    80006402:	69a6                	ld	s3,72(sp)
    80006404:	6a06                	ld	s4,64(sp)
    80006406:	7ae2                	ld	s5,56(sp)
    80006408:	6165                	addi	sp,sp,112
    8000640a:	8082                	ret

000000008000640c <fslog_read_many>:
// لا تنسي إضافة fslog_read_many أيضاً هنا

int
fslog_read_many(struct fs_event *out, int max)
{
    8000640c:	7119                	addi	sp,sp,-128
    8000640e:	fc86                	sd	ra,120(sp)
    80006410:	f8a2                	sd	s0,112(sp)
    80006412:	f4a6                	sd	s1,104(sp)
    80006414:	f0ca                	sd	s2,96(sp)
    80006416:	e8d2                	sd	s4,80(sp)
    80006418:	0100                	addi	s0,sp,128
    8000641a:	84aa                	mv	s1,a0
    8000641c:	8a2e                	mv	s4,a1
  struct fs_event e;
  int count = 0;
  struct proc *p = myproc();
    8000641e:	80bfb0ef          	jal	80001c28 <myproc>

  while(count < max){
    80006422:	05405863          	blez	s4,80006472 <fslog_read_many+0x66>
    80006426:	ecce                	sd	s3,88(sp)
    80006428:	e4d6                	sd	s5,72(sp)
    8000642a:	e0da                	sd	s6,64(sp)
    8000642c:	fc5e                	sd	s7,56(sp)
    8000642e:	8aaa                	mv	s5,a0
  int count = 0;
    80006430:	4901                	li	s2,0
    // سحب حدث واحد من الرينغ بفر (موجود في ذاكرة الكيرنل)
    if(ringbuf_pop(&fs_rb, &e) != 0)
    80006432:	f8040993          	addi	s3,s0,-128
    80006436:	00026b17          	auipc	s6,0x26
    8000643a:	70ab0b13          	addi	s6,s6,1802 # 8002cb40 <fs_rb>
      break;

    // 🔥 النسخ الآمن لذاكرة المستخدم باستخدام copyout
    // العنوان الهدف: out + (count * حجم الـ struct)
    uint64 dst_addr = (uint64)out + (count * sizeof(struct fs_event));
    if(copyout(p->pagetable, dst_addr, (char *)&e, sizeof(struct fs_event)) < 0)
    8000643e:	03000b93          	li	s7,48
    if(ringbuf_pop(&fs_rb, &e) != 0)
    80006442:	85ce                	mv	a1,s3
    80006444:	855a                	mv	a0,s6
    80006446:	ea5ff0ef          	jal	800062ea <ringbuf_pop>
    8000644a:	e515                	bnez	a0,80006476 <fslog_read_many+0x6a>
    if(copyout(p->pagetable, dst_addr, (char *)&e, sizeof(struct fs_event)) < 0)
    8000644c:	86de                	mv	a3,s7
    8000644e:	864e                	mv	a2,s3
    80006450:	85a6                	mv	a1,s1
    80006452:	050ab503          	ld	a0,80(s5)
    80006456:	ce4fb0ef          	jal	8000193a <copyout>
    8000645a:	02054a63          	bltz	a0,8000648e <fslog_read_many+0x82>
      break;

    count++;
    8000645e:	2905                	addiw	s2,s2,1
  while(count < max){
    80006460:	03048493          	addi	s1,s1,48
    80006464:	fd2a1fe3          	bne	s4,s2,80006442 <fslog_read_many+0x36>
    80006468:	69e6                	ld	s3,88(sp)
    8000646a:	6aa6                	ld	s5,72(sp)
    8000646c:	6b06                	ld	s6,64(sp)
    8000646e:	7be2                	ld	s7,56(sp)
    80006470:	a039                	j	8000647e <fslog_read_many+0x72>
  int count = 0;
    80006472:	4901                	li	s2,0
    80006474:	a029                	j	8000647e <fslog_read_many+0x72>
    80006476:	69e6                	ld	s3,88(sp)
    80006478:	6aa6                	ld	s5,72(sp)
    8000647a:	6b06                	ld	s6,64(sp)
    8000647c:	7be2                	ld	s7,56(sp)
  }
  return count;
    8000647e:	854a                	mv	a0,s2
    80006480:	70e6                	ld	ra,120(sp)
    80006482:	7446                	ld	s0,112(sp)
    80006484:	74a6                	ld	s1,104(sp)
    80006486:	7906                	ld	s2,96(sp)
    80006488:	6a46                	ld	s4,80(sp)
    8000648a:	6109                	addi	sp,sp,128
    8000648c:	8082                	ret
    8000648e:	69e6                	ld	s3,88(sp)
    80006490:	6aa6                	ld	s5,72(sp)
    80006492:	6b06                	ld	s6,64(sp)
    80006494:	7be2                	ld	s7,56(sp)
    80006496:	b7e5                	j	8000647e <fslog_read_many+0x72>

0000000080006498 <memlog_init>:
static uint mem_count = 0;
static uint64 mem_seq = 0;

void
memlog_init(void)
{
    80006498:	1141                	addi	sp,sp,-16
    8000649a:	e406                	sd	ra,8(sp)
    8000649c:	e022                	sd	s0,0(sp)
    8000649e:	0800                	addi	s0,sp,16
  initlock(&mem_lock, "memlog");
    800064a0:	00002597          	auipc	a1,0x2
    800064a4:	2d058593          	addi	a1,a1,720 # 80008770 <etext+0x770>
    800064a8:	0002e517          	auipc	a0,0x2e
    800064ac:	6c850513          	addi	a0,a0,1736 # 80034b70 <mem_lock>
    800064b0:	fdcfa0ef          	jal	80000c8c <initlock>
  mem_head = 0;
    800064b4:	00005797          	auipc	a5,0x5
    800064b8:	3007a223          	sw	zero,772(a5) # 8000b7b8 <mem_head>
  mem_tail = 0;
    800064bc:	00005797          	auipc	a5,0x5
    800064c0:	2e07ac23          	sw	zero,760(a5) # 8000b7b4 <mem_tail>
  mem_count = 0;
    800064c4:	00005797          	auipc	a5,0x5
    800064c8:	2e07a623          	sw	zero,748(a5) # 8000b7b0 <mem_count>
  mem_seq = 0;
    800064cc:	00005797          	auipc	a5,0x5
    800064d0:	2c07be23          	sd	zero,732(a5) # 8000b7a8 <mem_seq>
}
    800064d4:	60a2                	ld	ra,8(sp)
    800064d6:	6402                	ld	s0,0(sp)
    800064d8:	0141                	addi	sp,sp,16
    800064da:	8082                	ret

00000000800064dc <memlog_push>:

void
memlog_push(struct mem_event *e)
{
    800064dc:	1101                	addi	sp,sp,-32
    800064de:	ec06                	sd	ra,24(sp)
    800064e0:	e822                	sd	s0,16(sp)
    800064e2:	e426                	sd	s1,8(sp)
    800064e4:	1000                	addi	s0,sp,32
    800064e6:	84aa                	mv	s1,a0
  acquire(&mem_lock);
    800064e8:	0002e517          	auipc	a0,0x2e
    800064ec:	68850513          	addi	a0,a0,1672 # 80034b70 <mem_lock>
    800064f0:	827fa0ef          	jal	80000d16 <acquire>

  e->seq = ++mem_seq;
    800064f4:	00005717          	auipc	a4,0x5
    800064f8:	2b470713          	addi	a4,a4,692 # 8000b7a8 <mem_seq>
    800064fc:	631c                	ld	a5,0(a4)
    800064fe:	0785                	addi	a5,a5,1
    80006500:	e31c                	sd	a5,0(a4)
    80006502:	e09c                	sd	a5,0(s1)

  if(mem_count == MEM_RB_CAP){
    80006504:	00005717          	auipc	a4,0x5
    80006508:	2ac72703          	lw	a4,684(a4) # 8000b7b0 <mem_count>
    8000650c:	20000793          	li	a5,512
    80006510:	06f70e63          	beq	a4,a5,8000658c <memlog_push+0xb0>
    mem_tail = (mem_tail + 1) % MEM_RB_CAP;
    mem_count--;
  }

  mem_buf[mem_head] = *e;
    80006514:	00005617          	auipc	a2,0x5
    80006518:	2a462603          	lw	a2,676(a2) # 8000b7b8 <mem_head>
    8000651c:	02061693          	slli	a3,a2,0x20
    80006520:	9281                	srli	a3,a3,0x20
    80006522:	06800793          	li	a5,104
    80006526:	02f686b3          	mul	a3,a3,a5
    8000652a:	8726                	mv	a4,s1
    8000652c:	0002e797          	auipc	a5,0x2e
    80006530:	65c78793          	addi	a5,a5,1628 # 80034b88 <mem_buf>
    80006534:	97b6                	add	a5,a5,a3
    80006536:	06048493          	addi	s1,s1,96
    8000653a:	6308                	ld	a0,0(a4)
    8000653c:	670c                	ld	a1,8(a4)
    8000653e:	6b14                	ld	a3,16(a4)
    80006540:	e388                	sd	a0,0(a5)
    80006542:	e78c                	sd	a1,8(a5)
    80006544:	eb94                	sd	a3,16(a5)
    80006546:	6f14                	ld	a3,24(a4)
    80006548:	ef94                	sd	a3,24(a5)
    8000654a:	02070713          	addi	a4,a4,32
    8000654e:	02078793          	addi	a5,a5,32
    80006552:	fe9714e3          	bne	a4,s1,8000653a <memlog_push+0x5e>
    80006556:	6318                	ld	a4,0(a4)
    80006558:	e398                	sd	a4,0(a5)
  mem_head = (mem_head + 1) % MEM_RB_CAP;
    8000655a:	2605                	addiw	a2,a2,1
    8000655c:	1ff67613          	andi	a2,a2,511
    80006560:	00005797          	auipc	a5,0x5
    80006564:	24c7ac23          	sw	a2,600(a5) # 8000b7b8 <mem_head>
  mem_count++;
    80006568:	00005717          	auipc	a4,0x5
    8000656c:	24870713          	addi	a4,a4,584 # 8000b7b0 <mem_count>
    80006570:	431c                	lw	a5,0(a4)
    80006572:	2785                	addiw	a5,a5,1
    80006574:	c31c                	sw	a5,0(a4)

  release(&mem_lock);
    80006576:	0002e517          	auipc	a0,0x2e
    8000657a:	5fa50513          	addi	a0,a0,1530 # 80034b70 <mem_lock>
    8000657e:	82dfa0ef          	jal	80000daa <release>
}
    80006582:	60e2                	ld	ra,24(sp)
    80006584:	6442                	ld	s0,16(sp)
    80006586:	64a2                	ld	s1,8(sp)
    80006588:	6105                	addi	sp,sp,32
    8000658a:	8082                	ret
    mem_tail = (mem_tail + 1) % MEM_RB_CAP;
    8000658c:	00005717          	auipc	a4,0x5
    80006590:	22870713          	addi	a4,a4,552 # 8000b7b4 <mem_tail>
    80006594:	431c                	lw	a5,0(a4)
    80006596:	2785                	addiw	a5,a5,1
    80006598:	1ff7f793          	andi	a5,a5,511
    8000659c:	c31c                	sw	a5,0(a4)
    mem_count--;
    8000659e:	1ff00793          	li	a5,511
    800065a2:	00005717          	auipc	a4,0x5
    800065a6:	20f72723          	sw	a5,526(a4) # 8000b7b0 <mem_count>
    800065aa:	b7ad                	j	80006514 <memlog_push+0x38>

00000000800065ac <memlog_read_many>:

int
memlog_read_many(struct mem_event *out, int max)
{
    800065ac:	1101                	addi	sp,sp,-32
    800065ae:	ec06                	sd	ra,24(sp)
    800065b0:	e822                	sd	s0,16(sp)
    800065b2:	e04a                	sd	s2,0(sp)
    800065b4:	1000                	addi	s0,sp,32
  int n = 0;

  if(max <= 0)
    return 0;
    800065b6:	4901                	li	s2,0
  if(max <= 0)
    800065b8:	0ab05963          	blez	a1,8000666a <memlog_read_many+0xbe>
    800065bc:	e426                	sd	s1,8(sp)
    800065be:	892a                	mv	s2,a0
    800065c0:	84ae                	mv	s1,a1

  acquire(&mem_lock);
    800065c2:	0002e517          	auipc	a0,0x2e
    800065c6:	5ae50513          	addi	a0,a0,1454 # 80034b70 <mem_lock>
    800065ca:	f4cfa0ef          	jal	80000d16 <acquire>
  while(n < max && mem_count > 0){
    800065ce:	00005697          	auipc	a3,0x5
    800065d2:	1e66a683          	lw	a3,486(a3) # 8000b7b4 <mem_tail>
    800065d6:	00005317          	auipc	t1,0x5
    800065da:	1da32303          	lw	t1,474(t1) # 8000b7b0 <mem_count>
    800065de:	854a                	mv	a0,s2
  acquire(&mem_lock);
    800065e0:	4701                	li	a4,0
  int n = 0;
    800065e2:	4901                	li	s2,0
    out[n] = mem_buf[mem_tail];
    800065e4:	0002ee97          	auipc	t4,0x2e
    800065e8:	5a4e8e93          	addi	t4,t4,1444 # 80034b88 <mem_buf>
    800065ec:	06800e13          	li	t3,104
    800065f0:	4f05                	li	t5,1
  while(n < max && mem_count > 0){
    800065f2:	08030263          	beqz	t1,80006676 <memlog_read_many+0xca>
    out[n] = mem_buf[mem_tail];
    800065f6:	02069793          	slli	a5,a3,0x20
    800065fa:	9381                	srli	a5,a5,0x20
    800065fc:	03c787b3          	mul	a5,a5,t3
    80006600:	97f6                	add	a5,a5,t4
    80006602:	872a                	mv	a4,a0
    80006604:	06078613          	addi	a2,a5,96
    80006608:	0007b883          	ld	a7,0(a5)
    8000660c:	0087b803          	ld	a6,8(a5)
    80006610:	6b8c                	ld	a1,16(a5)
    80006612:	01173023          	sd	a7,0(a4)
    80006616:	01073423          	sd	a6,8(a4)
    8000661a:	eb0c                	sd	a1,16(a4)
    8000661c:	0187b803          	ld	a6,24(a5)
    80006620:	01073c23          	sd	a6,24(a4)
    80006624:	02078793          	addi	a5,a5,32
    80006628:	02070713          	addi	a4,a4,32
    8000662c:	fcc79ee3          	bne	a5,a2,80006608 <memlog_read_many+0x5c>
    80006630:	639c                	ld	a5,0(a5)
    80006632:	e31c                	sd	a5,0(a4)
    mem_tail = (mem_tail + 1) % MEM_RB_CAP;
    80006634:	2685                	addiw	a3,a3,1
    80006636:	1ff6f693          	andi	a3,a3,511
    mem_count--;
    8000663a:	fff3079b          	addiw	a5,t1,-1
    8000663e:	833e                	mv	t1,a5
    n++;
    80006640:	2905                	addiw	s2,s2,1
  while(n < max && mem_count > 0){
    80006642:	06850513          	addi	a0,a0,104
    80006646:	877a                	mv	a4,t5
    80006648:	fb2495e3          	bne	s1,s2,800065f2 <memlog_read_many+0x46>
    8000664c:	00005717          	auipc	a4,0x5
    80006650:	16d72423          	sw	a3,360(a4) # 8000b7b4 <mem_tail>
    80006654:	00005717          	auipc	a4,0x5
    80006658:	14f72e23          	sw	a5,348(a4) # 8000b7b0 <mem_count>
  }
  release(&mem_lock);
    8000665c:	0002e517          	auipc	a0,0x2e
    80006660:	51450513          	addi	a0,a0,1300 # 80034b70 <mem_lock>
    80006664:	f46fa0ef          	jal	80000daa <release>

  return n;
    80006668:	64a2                	ld	s1,8(sp)
    8000666a:	854a                	mv	a0,s2
    8000666c:	60e2                	ld	ra,24(sp)
    8000666e:	6442                	ld	s0,16(sp)
    80006670:	6902                	ld	s2,0(sp)
    80006672:	6105                	addi	sp,sp,32
    80006674:	8082                	ret
    80006676:	d37d                	beqz	a4,8000665c <memlog_read_many+0xb0>
    80006678:	00005797          	auipc	a5,0x5
    8000667c:	12d7ae23          	sw	a3,316(a5) # 8000b7b4 <mem_tail>
    80006680:	00005797          	auipc	a5,0x5
    80006684:	1207a823          	sw	zero,304(a5) # 8000b7b0 <mem_count>
    80006688:	bfd1                	j	8000665c <memlog_read_many+0xb0>

000000008000668a <sys_memread>:
#include "memevent.h"
#include "memlog.h"

uint64
sys_memread(void)
{
    8000668a:	95010113          	addi	sp,sp,-1712
    8000668e:	6a113423          	sd	ra,1704(sp)
    80006692:	6a813023          	sd	s0,1696(sp)
    80006696:	6b010413          	addi	s0,sp,1712
  uint64 uaddr = 0;
    8000669a:	fc043c23          	sd	zero,-40(s0)
  int max = 0;
    8000669e:	fc042a23          	sw	zero,-44(s0)

  argaddr(0, &uaddr);
    800066a2:	fd840593          	addi	a1,s0,-40
    800066a6:	4501                	li	a0,0
    800066a8:	ed4fc0ef          	jal	80002d7c <argaddr>
  argint(1, &max);
    800066ac:	fd440593          	addi	a1,s0,-44
    800066b0:	4505                	li	a0,1
    800066b2:	eaefc0ef          	jal	80002d60 <argint>

  if(max <= 0)
    800066b6:	fd442783          	lw	a5,-44(s0)
    return 0;
    800066ba:	4501                	li	a0,0
  if(max <= 0)
    800066bc:	04f05263          	blez	a5,80006700 <sys_memread+0x76>
    800066c0:	68913c23          	sd	s1,1688(sp)
  if(max > 16)
    800066c4:	4741                	li	a4,16
    800066c6:	00f75463          	bge	a4,a5,800066ce <sys_memread+0x44>
    max = 16;
    800066ca:	fce42a23          	sw	a4,-44(s0)

  struct mem_event tmp[16];
  int n = memlog_read_many(tmp, max);
    800066ce:	fd442583          	lw	a1,-44(s0)
    800066d2:	95040513          	addi	a0,s0,-1712
    800066d6:	ed7ff0ef          	jal	800065ac <memlog_read_many>
    800066da:	84aa                	mv	s1,a0

  int bytes = n * (int)sizeof(struct mem_event);
  if(copyout(myproc()->pagetable, uaddr, (char *)tmp, bytes) < 0)
    800066dc:	d4cfb0ef          	jal	80001c28 <myproc>
    800066e0:	06800693          	li	a3,104
    800066e4:	029686bb          	mulw	a3,a3,s1
    800066e8:	95040613          	addi	a2,s0,-1712
    800066ec:	fd843583          	ld	a1,-40(s0)
    800066f0:	6928                	ld	a0,80(a0)
    800066f2:	a48fb0ef          	jal	8000193a <copyout>
    800066f6:	00054c63          	bltz	a0,8000670e <sys_memread+0x84>
    return -1;

  return n;
    800066fa:	8526                	mv	a0,s1
    800066fc:	69813483          	ld	s1,1688(sp)
    80006700:	6a813083          	ld	ra,1704(sp)
    80006704:	6a013403          	ld	s0,1696(sp)
    80006708:	6b010113          	addi	sp,sp,1712
    8000670c:	8082                	ret
    return -1;
    8000670e:	557d                	li	a0,-1
    80006710:	69813483          	ld	s1,1688(sp)
    80006714:	b7f5                	j	80006700 <sys_memread+0x76>

0000000080006716 <schedlog_init>:

static struct ringbuf sched_rb;

void
schedlog_init(void)
{
    80006716:	1141                	addi	sp,sp,-16
    80006718:	e406                	sd	ra,8(sp)
    8000671a:	e022                	sd	s0,0(sp)
    8000671c:	0800                	addi	s0,sp,16
  ringbuf_init(&sched_rb, "schedlog", sizeof(struct sched_event));
    8000671e:	04400613          	li	a2,68
    80006722:	00002597          	auipc	a1,0x2
    80006726:	05658593          	addi	a1,a1,86 # 80008778 <etext+0x778>
    8000672a:	0003b517          	auipc	a0,0x3b
    8000672e:	45e50513          	addi	a0,a0,1118 # 80041b88 <sched_rb>
    80006732:	a9bff0ef          	jal	800061cc <ringbuf_init>
}
    80006736:	60a2                	ld	ra,8(sp)
    80006738:	6402                	ld	s0,0(sp)
    8000673a:	0141                	addi	sp,sp,16
    8000673c:	8082                	ret

000000008000673e <schedlog_emit>:

void
schedlog_emit(struct sched_event *e)
{
    8000673e:	7159                	addi	sp,sp,-112
    80006740:	f486                	sd	ra,104(sp)
    80006742:	f0a2                	sd	s0,96(sp)
    80006744:	eca6                	sd	s1,88(sp)
    80006746:	1880                	addi	s0,sp,112
    80006748:	85aa                	mv	a1,a0
  struct sched_event copy;

  memmove(&copy, e, sizeof(copy));
    8000674a:	f9840493          	addi	s1,s0,-104
    8000674e:	04400613          	li	a2,68
    80006752:	8526                	mv	a0,s1
    80006754:	ef2fa0ef          	jal	80000e46 <memmove>
  copy.seq = sched_rb.seq++;
    80006758:	0003b717          	auipc	a4,0x3b
    8000675c:	43070713          	addi	a4,a4,1072 # 80041b88 <sched_rb>
    80006760:	771c                	ld	a5,40(a4)
    80006762:	00178693          	addi	a3,a5,1
    80006766:	f714                	sd	a3,40(a4)
    80006768:	f8f42c23          	sw	a5,-104(s0)
  ringbuf_push(&sched_rb, &copy);
    8000676c:	85a6                	mv	a1,s1
    8000676e:	853a                	mv	a0,a4
    80006770:	a91ff0ef          	jal	80006200 <ringbuf_push>
}
    80006774:	70a6                	ld	ra,104(sp)
    80006776:	7406                	ld	s0,96(sp)
    80006778:	64e6                	ld	s1,88(sp)
    8000677a:	6165                	addi	sp,sp,112
    8000677c:	8082                	ret

000000008000677e <schedread>:

int
schedread(struct sched_event *dst, int max)
{
    8000677e:	1141                	addi	sp,sp,-16
    80006780:	e406                	sd	ra,8(sp)
    80006782:	e022                	sd	s0,0(sp)
    80006784:	0800                	addi	s0,sp,16
    80006786:	862e                	mv	a2,a1
  return ringbuf_read_many(&sched_rb, dst, max);
    80006788:	85aa                	mv	a1,a0
    8000678a:	0003b517          	auipc	a0,0x3b
    8000678e:	3fe50513          	addi	a0,a0,1022 # 80041b88 <sched_rb>
    80006792:	adbff0ef          	jal	8000626c <ringbuf_read_many>
    80006796:	60a2                	ld	ra,8(sp)
    80006798:	6402                	ld	s0,0(sp)
    8000679a:	0141                	addi	sp,sp,16
    8000679c:	8082                	ret
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
