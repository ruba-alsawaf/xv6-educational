
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
    80000004:	68813103          	ld	sp,1672(sp) # 8000b688 <_GLOBAL_OFFSET_TABLE_+0x8>
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
    80000016:	04a000ef          	jal	80000060 <start>

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
    8000001e:	e422                	sd	s0,8(sp)
    80000020:	0800                	addi	s0,sp,16
#define MIE_STIE (1L << 5)  // supervisor timer
static inline uint64
r_mie()
{
  uint64 x;
  asm volatile("csrr %0, mie" : "=r" (x) );
    80000022:	304027f3          	csrr	a5,mie
  // enable supervisor-mode timer interrupts.
  w_mie(r_mie() | MIE_STIE);
    80000026:	0207e793          	ori	a5,a5,32
}

static inline void 
w_mie(uint64 x)
{
  asm volatile("csrw mie, %0" : : "r" (x));
    8000002a:	30479073          	csrw	mie,a5
static inline uint64
r_menvcfg()
{
  uint64 x;
  // asm volatile("csrr %0, menvcfg" : "=r" (x) );
  asm volatile("csrr %0, 0x30a" : "=r" (x) );
    8000002e:	30a027f3          	csrr	a5,0x30a
  
  // enable the sstc extension (i.e. stimecmp).
  w_menvcfg(r_menvcfg() | (1L << 63)); 
    80000032:	577d                	li	a4,-1
    80000034:	177e                	slli	a4,a4,0x3f
    80000036:	8fd9                	or	a5,a5,a4

static inline void 
w_menvcfg(uint64 x)
{
  // asm volatile("csrw menvcfg, %0" : : "r" (x));
  asm volatile("csrw 0x30a, %0" : : "r" (x));
    80000038:	30a79073          	csrw	0x30a,a5

static inline uint64
r_mcounteren()
{
  uint64 x;
  asm volatile("csrr %0, mcounteren" : "=r" (x) );
    8000003c:	306027f3          	csrr	a5,mcounteren
  
  // allow supervisor to use stimecmp and time.
  w_mcounteren(r_mcounteren() | 2);
    80000040:	0027e793          	ori	a5,a5,2
  asm volatile("csrw mcounteren, %0" : : "r" (x));
    80000044:	30679073          	csrw	mcounteren,a5
// machine-mode cycle counter
static inline uint64
r_time()
{
  uint64 x;
  asm volatile("csrr %0, time" : "=r" (x) );
    80000048:	c01027f3          	rdtime	a5
  
  // ask for the very first timer interrupt.
  w_stimecmp(r_time() + 1000000);
    8000004c:	000f4737          	lui	a4,0xf4
    80000050:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    80000054:	97ba                	add	a5,a5,a4
  asm volatile("csrw 0x14d, %0" : : "r" (x));
    80000056:	14d79073          	csrw	stimecmp,a5
}
    8000005a:	6422                	ld	s0,8(sp)
    8000005c:	0141                	addi	sp,sp,16
    8000005e:	8082                	ret

0000000080000060 <start>:
{
    80000060:	1141                	addi	sp,sp,-16
    80000062:	e406                	sd	ra,8(sp)
    80000064:	e022                	sd	s0,0(sp)
    80000066:	0800                	addi	s0,sp,16
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    80000068:	300027f3          	csrr	a5,mstatus
  x &= ~MSTATUS_MPP_MASK;
    8000006c:	7779                	lui	a4,0xffffe
    8000006e:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffb4d07>
    80000072:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    80000074:	6705                	lui	a4,0x1
    80000076:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    8000007a:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r" (x));
    8000007c:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r" (x));
    80000080:	00001797          	auipc	a5,0x1
    80000084:	eaa78793          	addi	a5,a5,-342 # 80000f2a <main>
    80000088:	34179073          	csrw	mepc,a5
  asm volatile("csrw satp, %0" : : "r" (x));
    8000008c:	4781                	li	a5,0
    8000008e:	18079073          	csrw	satp,a5
  asm volatile("csrw medeleg, %0" : : "r" (x));
    80000092:	67c1                	lui	a5,0x10
    80000094:	17fd                	addi	a5,a5,-1 # ffff <_entry-0x7fff0001>
    80000096:	30279073          	csrw	medeleg,a5
  asm volatile("csrw mideleg, %0" : : "r" (x));
    8000009a:	30379073          	csrw	mideleg,a5
  asm volatile("csrr %0, sie" : "=r" (x) );
    8000009e:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE);
    800000a2:	2207e793          	ori	a5,a5,544
  asm volatile("csrw sie, %0" : : "r" (x));
    800000a6:	10479073          	csrw	sie,a5
  asm volatile("csrw pmpaddr0, %0" : : "r" (x));
    800000aa:	57fd                	li	a5,-1
    800000ac:	83a9                	srli	a5,a5,0xa
    800000ae:	3b079073          	csrw	pmpaddr0,a5
  asm volatile("csrw pmpcfg0, %0" : : "r" (x));
    800000b2:	47bd                	li	a5,15
    800000b4:	3a079073          	csrw	pmpcfg0,a5
  timerinit();
    800000b8:	f65ff0ef          	jal	8000001c <timerinit>
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    800000bc:	f14027f3          	csrr	a5,mhartid
  w_tp(id);
    800000c0:	2781                	sext.w	a5,a5
}

static inline void 
w_tp(uint64 x)
{
  asm volatile("mv tp, %0" : : "r" (x));
    800000c2:	823e                	mv	tp,a5
  asm volatile("mret");
    800000c4:	30200073          	mret
}
    800000c8:	60a2                	ld	ra,8(sp)
    800000ca:	6402                	ld	s0,0(sp)
    800000cc:	0141                	addi	sp,sp,16
    800000ce:	8082                	ret

00000000800000d0 <consolewrite>:

static struct sleeplock conswlock;

int
consolewrite(int user_src, uint64 src, int n)
{
    800000d0:	7115                	addi	sp,sp,-224
    800000d2:	ed86                	sd	ra,216(sp)
    800000d4:	e9a2                	sd	s0,208(sp)
    800000d6:	e5a6                	sd	s1,200(sp)
    800000d8:	f952                	sd	s4,176(sp)
    800000da:	f556                	sd	s5,168(sp)
    800000dc:	f15a                	sd	s6,160(sp)
    800000de:	1180                	addi	s0,sp,224
    800000e0:	8aaa                	mv	s5,a0
    800000e2:	8b2e                	mv	s6,a1
    800000e4:	8a32                	mv	s4,a2
  char buf[128];
  int i = 0;

  acquiresleep(&conswlock);
    800000e6:	00013517          	auipc	a0,0x13
    800000ea:	61a50513          	addi	a0,a0,1562 # 80013700 <conswlock>
    800000ee:	34a040ef          	jal	80004438 <acquiresleep>

  while(i < n){
    800000f2:	07405163          	blez	s4,80000154 <consolewrite+0x84>
    800000f6:	e1ca                	sd	s2,192(sp)
    800000f8:	fd4e                	sd	s3,184(sp)
    800000fa:	ed5e                	sd	s7,152(sp)
    800000fc:	e962                	sd	s8,144(sp)
    800000fe:	e566                	sd	s9,136(sp)
  int i = 0;
    80000100:	4481                	li	s1,0
    int nn = sizeof(buf);
    if(nn > n - i)
    80000102:	08000c13          	li	s8,128
    80000106:	08000c93          	li	s9,128
      nn = n - i;

    if(either_copyin(buf, user_src, src + i, nn) == -1)
    8000010a:	5bfd                	li	s7,-1
    8000010c:	a035                	j	80000138 <consolewrite+0x68>
    if(nn > n - i)
    8000010e:	0009099b          	sext.w	s3,s2
    if(either_copyin(buf, user_src, src + i, nn) == -1)
    80000112:	86ce                	mv	a3,s3
    80000114:	01648633          	add	a2,s1,s6
    80000118:	85d6                	mv	a1,s5
    8000011a:	f2040513          	addi	a0,s0,-224
    8000011e:	67e020ef          	jal	8000279c <either_copyin>
    80000122:	03750b63          	beq	a0,s7,80000158 <consolewrite+0x88>
      break;

    uartwrite(buf, nn);
    80000126:	85ce                	mv	a1,s3
    80000128:	f2040513          	addi	a0,s0,-224
    8000012c:	79e000ef          	jal	800008ca <uartwrite>
    i += nn;
    80000130:	009904bb          	addw	s1,s2,s1
  while(i < n){
    80000134:	0144da63          	bge	s1,s4,80000148 <consolewrite+0x78>
    if(nn > n - i)
    80000138:	409a093b          	subw	s2,s4,s1
    8000013c:	0009079b          	sext.w	a5,s2
    80000140:	fcfc57e3          	bge	s8,a5,8000010e <consolewrite+0x3e>
    80000144:	8966                	mv	s2,s9
    80000146:	b7e1                	j	8000010e <consolewrite+0x3e>
    80000148:	690e                	ld	s2,192(sp)
    8000014a:	79ea                	ld	s3,184(sp)
    8000014c:	6bea                	ld	s7,152(sp)
    8000014e:	6c4a                	ld	s8,144(sp)
    80000150:	6caa                	ld	s9,136(sp)
    80000152:	a801                	j	80000162 <consolewrite+0x92>
  int i = 0;
    80000154:	4481                	li	s1,0
    80000156:	a031                	j	80000162 <consolewrite+0x92>
    80000158:	690e                	ld	s2,192(sp)
    8000015a:	79ea                	ld	s3,184(sp)
    8000015c:	6bea                	ld	s7,152(sp)
    8000015e:	6c4a                	ld	s8,144(sp)
    80000160:	6caa                	ld	s9,136(sp)
  }

  releasesleep(&conswlock);
    80000162:	00013517          	auipc	a0,0x13
    80000166:	59e50513          	addi	a0,a0,1438 # 80013700 <conswlock>
    8000016a:	314040ef          	jal	8000447e <releasesleep>
  return i;
}
    8000016e:	8526                	mv	a0,s1
    80000170:	60ee                	ld	ra,216(sp)
    80000172:	644e                	ld	s0,208(sp)
    80000174:	64ae                	ld	s1,200(sp)
    80000176:	7a4a                	ld	s4,176(sp)
    80000178:	7aaa                	ld	s5,168(sp)
    8000017a:	7b0a                	ld	s6,160(sp)
    8000017c:	612d                	addi	sp,sp,224
    8000017e:	8082                	ret

0000000080000180 <consoleread>:

int
consoleread(int user_dst, uint64 dst, int n)
{
    80000180:	711d                	addi	sp,sp,-96
    80000182:	ec86                	sd	ra,88(sp)
    80000184:	e8a2                	sd	s0,80(sp)
    80000186:	e4a6                	sd	s1,72(sp)
    80000188:	e0ca                	sd	s2,64(sp)
    8000018a:	fc4e                	sd	s3,56(sp)
    8000018c:	f852                	sd	s4,48(sp)
    8000018e:	f456                	sd	s5,40(sp)
    80000190:	f05a                	sd	s6,32(sp)
    80000192:	ec5e                	sd	s7,24(sp)
    80000194:	1080                	addi	s0,sp,96
    80000196:	8b2a                	mv	s6,a0
    80000198:	8aae                	mv	s5,a1
    8000019a:	8a32                	mv	s4,a2
  uint target;
  int c;
  char cbuf;

  target = n;
    8000019c:	00060b9b          	sext.w	s7,a2
  acquire(&cons.lock);
    800001a0:	00013517          	auipc	a0,0x13
    800001a4:	59050513          	addi	a0,a0,1424 # 80013730 <cons>
    800001a8:	315000ef          	jal	80000cbc <acquire>

  while(n > 0){
    while(cons.r == cons.w){
    800001ac:	00013497          	auipc	s1,0x13
    800001b0:	55448493          	addi	s1,s1,1364 # 80013700 <conswlock>
      if(killed(myproc())){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    800001b4:	00013997          	auipc	s3,0x13
    800001b8:	57c98993          	addi	s3,s3,1404 # 80013730 <cons>
    800001bc:	00013917          	auipc	s2,0x13
    800001c0:	60c90913          	addi	s2,s2,1548 # 800137c8 <cons+0x98>
  while(n > 0){
    800001c4:	0b405e63          	blez	s4,80000280 <consoleread+0x100>
    while(cons.r == cons.w){
    800001c8:	0c84a783          	lw	a5,200(s1)
    800001cc:	0cc4a703          	lw	a4,204(s1)
    800001d0:	0af71363          	bne	a4,a5,80000276 <consoleread+0xf6>
      if(killed(myproc())){
    800001d4:	1ff010ef          	jal	80001bd2 <myproc>
    800001d8:	456020ef          	jal	8000262e <killed>
    800001dc:	e12d                	bnez	a0,8000023e <consoleread+0xbe>
      sleep(&cons.r, &cons.lock);
    800001de:	85ce                	mv	a1,s3
    800001e0:	854a                	mv	a0,s2
    800001e2:	214020ef          	jal	800023f6 <sleep>
    while(cons.r == cons.w){
    800001e6:	0c84a783          	lw	a5,200(s1)
    800001ea:	0cc4a703          	lw	a4,204(s1)
    800001ee:	fef703e3          	beq	a4,a5,800001d4 <consoleread+0x54>
    800001f2:	e862                	sd	s8,16(sp)
    }

    c = cons.buf[cons.r++ % INPUT_BUF_SIZE];
    800001f4:	00013717          	auipc	a4,0x13
    800001f8:	50c70713          	addi	a4,a4,1292 # 80013700 <conswlock>
    800001fc:	0017869b          	addiw	a3,a5,1
    80000200:	0cd72423          	sw	a3,200(a4)
    80000204:	07f7f693          	andi	a3,a5,127
    80000208:	9736                	add	a4,a4,a3
    8000020a:	04874703          	lbu	a4,72(a4)
    8000020e:	00070c1b          	sext.w	s8,a4

    if(c == C('D')){
    80000212:	4691                	li	a3,4
    80000214:	04dc0763          	beq	s8,a3,80000262 <consoleread+0xe2>
        cons.r--;
      }
      break;
    }

    cbuf = c;
    80000218:	fae407a3          	sb	a4,-81(s0)
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    8000021c:	4685                	li	a3,1
    8000021e:	faf40613          	addi	a2,s0,-81
    80000222:	85d6                	mv	a1,s5
    80000224:	855a                	mv	a0,s6
    80000226:	52c020ef          	jal	80002752 <either_copyout>
    8000022a:	57fd                	li	a5,-1
    8000022c:	04f50963          	beq	a0,a5,8000027e <consoleread+0xfe>
      break;

    dst++;
    80000230:	0a85                	addi	s5,s5,1
    --n;
    80000232:	3a7d                	addiw	s4,s4,-1

    if(c == '\n'){
    80000234:	47a9                	li	a5,10
    80000236:	04fc0e63          	beq	s8,a5,80000292 <consoleread+0x112>
    8000023a:	6c42                	ld	s8,16(sp)
    8000023c:	b761                	j	800001c4 <consoleread+0x44>
        release(&cons.lock);
    8000023e:	00013517          	auipc	a0,0x13
    80000242:	4f250513          	addi	a0,a0,1266 # 80013730 <cons>
    80000246:	30f000ef          	jal	80000d54 <release>
        return -1;
    8000024a:	557d                	li	a0,-1
    }
  }

  release(&cons.lock);
  return target - n;
}
    8000024c:	60e6                	ld	ra,88(sp)
    8000024e:	6446                	ld	s0,80(sp)
    80000250:	64a6                	ld	s1,72(sp)
    80000252:	6906                	ld	s2,64(sp)
    80000254:	79e2                	ld	s3,56(sp)
    80000256:	7a42                	ld	s4,48(sp)
    80000258:	7aa2                	ld	s5,40(sp)
    8000025a:	7b02                	ld	s6,32(sp)
    8000025c:	6be2                	ld	s7,24(sp)
    8000025e:	6125                	addi	sp,sp,96
    80000260:	8082                	ret
      if(n < target){
    80000262:	000a071b          	sext.w	a4,s4
    80000266:	01777a63          	bgeu	a4,s7,8000027a <consoleread+0xfa>
        cons.r--;
    8000026a:	00013717          	auipc	a4,0x13
    8000026e:	54f72f23          	sw	a5,1374(a4) # 800137c8 <cons+0x98>
    80000272:	6c42                	ld	s8,16(sp)
    80000274:	a031                	j	80000280 <consoleread+0x100>
    80000276:	e862                	sd	s8,16(sp)
    80000278:	bfb5                	j	800001f4 <consoleread+0x74>
    8000027a:	6c42                	ld	s8,16(sp)
    8000027c:	a011                	j	80000280 <consoleread+0x100>
    8000027e:	6c42                	ld	s8,16(sp)
  release(&cons.lock);
    80000280:	00013517          	auipc	a0,0x13
    80000284:	4b050513          	addi	a0,a0,1200 # 80013730 <cons>
    80000288:	2cd000ef          	jal	80000d54 <release>
  return target - n;
    8000028c:	414b853b          	subw	a0,s7,s4
    80000290:	bf75                	j	8000024c <consoleread+0xcc>
    80000292:	6c42                	ld	s8,16(sp)
    80000294:	b7f5                	j	80000280 <consoleread+0x100>

0000000080000296 <consputc>:
{
    80000296:	1141                	addi	sp,sp,-16
    80000298:	e406                	sd	ra,8(sp)
    8000029a:	e022                	sd	s0,0(sp)
    8000029c:	0800                	addi	s0,sp,16
  if(c == BACKSPACE){
    8000029e:	10000793          	li	a5,256
    800002a2:	00f50863          	beq	a0,a5,800002b2 <consputc+0x1c>
    uartputc_sync(c);
    800002a6:	6b8000ef          	jal	8000095e <uartputc_sync>
}
    800002aa:	60a2                	ld	ra,8(sp)
    800002ac:	6402                	ld	s0,0(sp)
    800002ae:	0141                	addi	sp,sp,16
    800002b0:	8082                	ret
    uartputc_sync('\b');
    800002b2:	4521                	li	a0,8
    800002b4:	6aa000ef          	jal	8000095e <uartputc_sync>
    uartputc_sync(' ');
    800002b8:	02000513          	li	a0,32
    800002bc:	6a2000ef          	jal	8000095e <uartputc_sync>
    uartputc_sync('\b');
    800002c0:	4521                	li	a0,8
    800002c2:	69c000ef          	jal	8000095e <uartputc_sync>
    800002c6:	b7d5                	j	800002aa <consputc+0x14>

00000000800002c8 <consoleintr>:

void
consoleintr(int c)
{
    800002c8:	1101                	addi	sp,sp,-32
    800002ca:	ec06                	sd	ra,24(sp)
    800002cc:	e822                	sd	s0,16(sp)
    800002ce:	e426                	sd	s1,8(sp)
    800002d0:	1000                	addi	s0,sp,32
    800002d2:	84aa                	mv	s1,a0
  acquire(&cons.lock);
    800002d4:	00013517          	auipc	a0,0x13
    800002d8:	45c50513          	addi	a0,a0,1116 # 80013730 <cons>
    800002dc:	1e1000ef          	jal	80000cbc <acquire>

  switch(c){
    800002e0:	47d5                	li	a5,21
    800002e2:	08f48f63          	beq	s1,a5,80000380 <consoleintr+0xb8>
    800002e6:	0297c563          	blt	a5,s1,80000310 <consoleintr+0x48>
    800002ea:	47a1                	li	a5,8
    800002ec:	0ef48463          	beq	s1,a5,800003d4 <consoleintr+0x10c>
    800002f0:	47c1                	li	a5,16
    800002f2:	10f49563          	bne	s1,a5,800003fc <consoleintr+0x134>
  case C('P'):
    procdump();
    800002f6:	4f0020ef          	jal	800027e6 <procdump>
      }
    }
    break;
  }

  release(&cons.lock);
    800002fa:	00013517          	auipc	a0,0x13
    800002fe:	43650513          	addi	a0,a0,1078 # 80013730 <cons>
    80000302:	253000ef          	jal	80000d54 <release>
}
    80000306:	60e2                	ld	ra,24(sp)
    80000308:	6442                	ld	s0,16(sp)
    8000030a:	64a2                	ld	s1,8(sp)
    8000030c:	6105                	addi	sp,sp,32
    8000030e:	8082                	ret
  switch(c){
    80000310:	07f00793          	li	a5,127
    80000314:	0cf48063          	beq	s1,a5,800003d4 <consoleintr+0x10c>
    if(c != 0 && cons.e - cons.r < INPUT_BUF_SIZE){
    80000318:	00013717          	auipc	a4,0x13
    8000031c:	3e870713          	addi	a4,a4,1000 # 80013700 <conswlock>
    80000320:	0d072783          	lw	a5,208(a4)
    80000324:	0c872703          	lw	a4,200(a4)
    80000328:	9f99                	subw	a5,a5,a4
    8000032a:	07f00713          	li	a4,127
    8000032e:	fcf766e3          	bltu	a4,a5,800002fa <consoleintr+0x32>
      c = (c == '\r') ? '\n' : c;
    80000332:	47b5                	li	a5,13
    80000334:	0cf48763          	beq	s1,a5,80000402 <consoleintr+0x13a>
      consputc(c);
    80000338:	8526                	mv	a0,s1
    8000033a:	f5dff0ef          	jal	80000296 <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    8000033e:	00013797          	auipc	a5,0x13
    80000342:	3c278793          	addi	a5,a5,962 # 80013700 <conswlock>
    80000346:	0d07a683          	lw	a3,208(a5)
    8000034a:	0016871b          	addiw	a4,a3,1
    8000034e:	0007061b          	sext.w	a2,a4
    80000352:	0ce7a823          	sw	a4,208(a5)
    80000356:	07f6f693          	andi	a3,a3,127
    8000035a:	97b6                	add	a5,a5,a3
    8000035c:	04978423          	sb	s1,72(a5)
      if(c == '\n' || c == C('D') || cons.e - cons.r == INPUT_BUF_SIZE){
    80000360:	47a9                	li	a5,10
    80000362:	0cf48563          	beq	s1,a5,8000042c <consoleintr+0x164>
    80000366:	4791                	li	a5,4
    80000368:	0cf48263          	beq	s1,a5,8000042c <consoleintr+0x164>
    8000036c:	00013797          	auipc	a5,0x13
    80000370:	45c7a783          	lw	a5,1116(a5) # 800137c8 <cons+0x98>
    80000374:	9f1d                	subw	a4,a4,a5
    80000376:	08000793          	li	a5,128
    8000037a:	f8f710e3          	bne	a4,a5,800002fa <consoleintr+0x32>
    8000037e:	a07d                	j	8000042c <consoleintr+0x164>
    80000380:	e04a                	sd	s2,0(sp)
    while(cons.e != cons.w &&
    80000382:	00013717          	auipc	a4,0x13
    80000386:	37e70713          	addi	a4,a4,894 # 80013700 <conswlock>
    8000038a:	0d072783          	lw	a5,208(a4)
    8000038e:	0cc72703          	lw	a4,204(a4)
          cons.buf[(cons.e - 1) % INPUT_BUF_SIZE] != '\n'){
    80000392:	00013497          	auipc	s1,0x13
    80000396:	36e48493          	addi	s1,s1,878 # 80013700 <conswlock>
    while(cons.e != cons.w &&
    8000039a:	4929                	li	s2,10
    8000039c:	02f70863          	beq	a4,a5,800003cc <consoleintr+0x104>
          cons.buf[(cons.e - 1) % INPUT_BUF_SIZE] != '\n'){
    800003a0:	37fd                	addiw	a5,a5,-1
    800003a2:	07f7f713          	andi	a4,a5,127
    800003a6:	9726                	add	a4,a4,s1
    while(cons.e != cons.w &&
    800003a8:	04874703          	lbu	a4,72(a4)
    800003ac:	03270263          	beq	a4,s2,800003d0 <consoleintr+0x108>
      cons.e--;
    800003b0:	0cf4a823          	sw	a5,208(s1)
      consputc(BACKSPACE);
    800003b4:	10000513          	li	a0,256
    800003b8:	edfff0ef          	jal	80000296 <consputc>
    while(cons.e != cons.w &&
    800003bc:	0d04a783          	lw	a5,208(s1)
    800003c0:	0cc4a703          	lw	a4,204(s1)
    800003c4:	fcf71ee3          	bne	a4,a5,800003a0 <consoleintr+0xd8>
    800003c8:	6902                	ld	s2,0(sp)
    800003ca:	bf05                	j	800002fa <consoleintr+0x32>
    800003cc:	6902                	ld	s2,0(sp)
    800003ce:	b735                	j	800002fa <consoleintr+0x32>
    800003d0:	6902                	ld	s2,0(sp)
    800003d2:	b725                	j	800002fa <consoleintr+0x32>
    if(cons.e != cons.w){
    800003d4:	00013717          	auipc	a4,0x13
    800003d8:	32c70713          	addi	a4,a4,812 # 80013700 <conswlock>
    800003dc:	0d072783          	lw	a5,208(a4)
    800003e0:	0cc72703          	lw	a4,204(a4)
    800003e4:	f0f70be3          	beq	a4,a5,800002fa <consoleintr+0x32>
      cons.e--;
    800003e8:	37fd                	addiw	a5,a5,-1
    800003ea:	00013717          	auipc	a4,0x13
    800003ee:	3ef72323          	sw	a5,998(a4) # 800137d0 <cons+0xa0>
      consputc(BACKSPACE);
    800003f2:	10000513          	li	a0,256
    800003f6:	ea1ff0ef          	jal	80000296 <consputc>
    800003fa:	b701                	j	800002fa <consoleintr+0x32>
    if(c != 0 && cons.e - cons.r < INPUT_BUF_SIZE){
    800003fc:	ee048fe3          	beqz	s1,800002fa <consoleintr+0x32>
    80000400:	bf21                	j	80000318 <consoleintr+0x50>
      consputc(c);
    80000402:	4529                	li	a0,10
    80000404:	e93ff0ef          	jal	80000296 <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    80000408:	00013797          	auipc	a5,0x13
    8000040c:	2f878793          	addi	a5,a5,760 # 80013700 <conswlock>
    80000410:	0d07a703          	lw	a4,208(a5)
    80000414:	0017069b          	addiw	a3,a4,1
    80000418:	0006861b          	sext.w	a2,a3
    8000041c:	0cd7a823          	sw	a3,208(a5)
    80000420:	07f77713          	andi	a4,a4,127
    80000424:	97ba                	add	a5,a5,a4
    80000426:	4729                	li	a4,10
    80000428:	04e78423          	sb	a4,72(a5)
        cons.w = cons.e;
    8000042c:	00013797          	auipc	a5,0x13
    80000430:	3ac7a023          	sw	a2,928(a5) # 800137cc <cons+0x9c>
        wakeup(&cons.r);
    80000434:	00013517          	auipc	a0,0x13
    80000438:	39450513          	addi	a0,a0,916 # 800137c8 <cons+0x98>
    8000043c:	006020ef          	jal	80002442 <wakeup>
    80000440:	bd6d                	j	800002fa <consoleintr+0x32>

0000000080000442 <consoleinit>:

void
consoleinit(void)
{
    80000442:	1141                	addi	sp,sp,-16
    80000444:	e406                	sd	ra,8(sp)
    80000446:	e022                	sd	s0,0(sp)
    80000448:	0800                	addi	s0,sp,16
  initlock(&cons.lock, "cons");
    8000044a:	00008597          	auipc	a1,0x8
    8000044e:	bb658593          	addi	a1,a1,-1098 # 80008000 <etext>
    80000452:	00013517          	auipc	a0,0x13
    80000456:	2de50513          	addi	a0,a0,734 # 80013730 <cons>
    8000045a:	7e2000ef          	jal	80000c3c <initlock>
  initsleeplock(&conswlock, "consw");
    8000045e:	00008597          	auipc	a1,0x8
    80000462:	bb258593          	addi	a1,a1,-1102 # 80008010 <etext+0x10>
    80000466:	00013517          	auipc	a0,0x13
    8000046a:	29a50513          	addi	a0,a0,666 # 80013700 <conswlock>
    8000046e:	795030ef          	jal	80004402 <initsleeplock>

  uartinit();
    80000472:	400000ef          	jal	80000872 <uartinit>

  devsw[CONSOLE].read = consoleread;
    80000476:	00023797          	auipc	a5,0x23
    8000047a:	44278793          	addi	a5,a5,1090 # 800238b8 <devsw>
    8000047e:	00000717          	auipc	a4,0x0
    80000482:	d0270713          	addi	a4,a4,-766 # 80000180 <consoleread>
    80000486:	eb98                	sd	a4,16(a5)
  devsw[CONSOLE].write = consolewrite;
    80000488:	00000717          	auipc	a4,0x0
    8000048c:	c4870713          	addi	a4,a4,-952 # 800000d0 <consolewrite>
    80000490:	ef98                	sd	a4,24(a5)
    80000492:	60a2                	ld	ra,8(sp)
    80000494:	6402                	ld	s0,0(sp)
    80000496:	0141                	addi	sp,sp,16
    80000498:	8082                	ret

000000008000049a <printint>:

static char digits[] = "0123456789abcdef";

static void
printint(long long xx, int base, int sign)
{
    8000049a:	7139                	addi	sp,sp,-64
    8000049c:	fc06                	sd	ra,56(sp)
    8000049e:	f822                	sd	s0,48(sp)
    800004a0:	0080                	addi	s0,sp,64
  char buf[20];
  int i;
  unsigned long long x;

  if(sign && (sign = (xx < 0)))
    800004a2:	c219                	beqz	a2,800004a8 <printint+0xe>
    800004a4:	08054063          	bltz	a0,80000524 <printint+0x8a>
    x = -xx;
  else
    x = xx;
    800004a8:	4881                	li	a7,0
    800004aa:	fc840693          	addi	a3,s0,-56

  i = 0;
    800004ae:	4781                	li	a5,0
  do {
    buf[i++] = digits[x % base];
    800004b0:	00008617          	auipc	a2,0x8
    800004b4:	2d860613          	addi	a2,a2,728 # 80008788 <digits>
    800004b8:	883e                	mv	a6,a5
    800004ba:	2785                	addiw	a5,a5,1
    800004bc:	02b57733          	remu	a4,a0,a1
    800004c0:	9732                	add	a4,a4,a2
    800004c2:	00074703          	lbu	a4,0(a4)
    800004c6:	00e68023          	sb	a4,0(a3)
  } while((x /= base) != 0);
    800004ca:	872a                	mv	a4,a0
    800004cc:	02b55533          	divu	a0,a0,a1
    800004d0:	0685                	addi	a3,a3,1
    800004d2:	feb773e3          	bgeu	a4,a1,800004b8 <printint+0x1e>

  if(sign)
    800004d6:	00088a63          	beqz	a7,800004ea <printint+0x50>
    buf[i++] = '-';
    800004da:	1781                	addi	a5,a5,-32
    800004dc:	97a2                	add	a5,a5,s0
    800004de:	02d00713          	li	a4,45
    800004e2:	fee78423          	sb	a4,-24(a5)
    800004e6:	0028079b          	addiw	a5,a6,2

  while(--i >= 0)
    800004ea:	02f05963          	blez	a5,8000051c <printint+0x82>
    800004ee:	f426                	sd	s1,40(sp)
    800004f0:	f04a                	sd	s2,32(sp)
    800004f2:	fc840713          	addi	a4,s0,-56
    800004f6:	00f704b3          	add	s1,a4,a5
    800004fa:	fff70913          	addi	s2,a4,-1
    800004fe:	993e                	add	s2,s2,a5
    80000500:	37fd                	addiw	a5,a5,-1
    80000502:	1782                	slli	a5,a5,0x20
    80000504:	9381                	srli	a5,a5,0x20
    80000506:	40f90933          	sub	s2,s2,a5
    consputc(buf[i]);
    8000050a:	fff4c503          	lbu	a0,-1(s1)
    8000050e:	d89ff0ef          	jal	80000296 <consputc>
  while(--i >= 0)
    80000512:	14fd                	addi	s1,s1,-1
    80000514:	ff249be3          	bne	s1,s2,8000050a <printint+0x70>
    80000518:	74a2                	ld	s1,40(sp)
    8000051a:	7902                	ld	s2,32(sp)
}
    8000051c:	70e2                	ld	ra,56(sp)
    8000051e:	7442                	ld	s0,48(sp)
    80000520:	6121                	addi	sp,sp,64
    80000522:	8082                	ret
    x = -xx;
    80000524:	40a00533          	neg	a0,a0
  if(sign && (sign = (xx < 0)))
    80000528:	4885                	li	a7,1
    x = -xx;
    8000052a:	b741                	j	800004aa <printint+0x10>

000000008000052c <printf>:
}

// Print to the console.
int
printf(char *fmt, ...)
{
    8000052c:	7131                	addi	sp,sp,-192
    8000052e:	fc86                	sd	ra,120(sp)
    80000530:	f8a2                	sd	s0,112(sp)
    80000532:	e8d2                	sd	s4,80(sp)
    80000534:	0100                	addi	s0,sp,128
    80000536:	8a2a                	mv	s4,a0
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
    8000054e:	15a7a783          	lw	a5,346(a5) # 8000b6a4 <panicking>
    80000552:	c3a1                	beqz	a5,80000592 <printf+0x66>
    acquire(&pr.lock);

  va_start(ap, fmt);
    80000554:	00840793          	addi	a5,s0,8
    80000558:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; (cx = fmt[i] & 0xff) != 0; i++){
    8000055c:	000a4503          	lbu	a0,0(s4)
    80000560:	28050763          	beqz	a0,800007ee <printf+0x2c2>
    80000564:	f4a6                	sd	s1,104(sp)
    80000566:	f0ca                	sd	s2,96(sp)
    80000568:	ecce                	sd	s3,88(sp)
    8000056a:	e4d6                	sd	s5,72(sp)
    8000056c:	e0da                	sd	s6,64(sp)
    8000056e:	f862                	sd	s8,48(sp)
    80000570:	f466                	sd	s9,40(sp)
    80000572:	f06a                	sd	s10,32(sp)
    80000574:	ec6e                	sd	s11,24(sp)
    80000576:	4981                	li	s3,0
    if(cx != '%'){
    80000578:	02500a93          	li	s5,37
    i++;
    c0 = fmt[i+0] & 0xff;
    c1 = c2 = 0;
    if(c0) c1 = fmt[i+1] & 0xff;
    if(c1) c2 = fmt[i+2] & 0xff;
    if(c0 == 'd'){
    8000057c:	06400b13          	li	s6,100
      printint(va_arg(ap, int), 10, 1);
    } else if(c0 == 'l' && c1 == 'd'){
    80000580:	06c00c13          	li	s8,108
      printint(va_arg(ap, uint64), 10, 1);
      i += 1;
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
      printint(va_arg(ap, uint64), 10, 1);
      i += 2;
    } else if(c0 == 'u'){
    80000584:	07500c93          	li	s9,117
      printint(va_arg(ap, uint64), 10, 0);
      i += 1;
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
      printint(va_arg(ap, uint64), 10, 0);
      i += 2;
    } else if(c0 == 'x'){
    80000588:	07800d13          	li	s10,120
      printint(va_arg(ap, uint64), 16, 0);
      i += 1;
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
      printint(va_arg(ap, uint64), 16, 0);
      i += 2;
    } else if(c0 == 'p'){
    8000058c:	07000d93          	li	s11,112
    80000590:	a01d                	j	800005b6 <printf+0x8a>
    acquire(&pr.lock);
    80000592:	00013517          	auipc	a0,0x13
    80000596:	24650513          	addi	a0,a0,582 # 800137d8 <pr>
    8000059a:	722000ef          	jal	80000cbc <acquire>
    8000059e:	bf5d                	j	80000554 <printf+0x28>
      consputc(cx);
    800005a0:	cf7ff0ef          	jal	80000296 <consputc>
      continue;
    800005a4:	84ce                	mv	s1,s3
  for(i = 0; (cx = fmt[i] & 0xff) != 0; i++){
    800005a6:	0014899b          	addiw	s3,s1,1
    800005aa:	013a07b3          	add	a5,s4,s3
    800005ae:	0007c503          	lbu	a0,0(a5)
    800005b2:	20050b63          	beqz	a0,800007c8 <printf+0x29c>
    if(cx != '%'){
    800005b6:	ff5515e3          	bne	a0,s5,800005a0 <printf+0x74>
    i++;
    800005ba:	0019849b          	addiw	s1,s3,1
    c0 = fmt[i+0] & 0xff;
    800005be:	009a07b3          	add	a5,s4,s1
    800005c2:	0007c903          	lbu	s2,0(a5)
    if(c0) c1 = fmt[i+1] & 0xff;
    800005c6:	20090b63          	beqz	s2,800007dc <printf+0x2b0>
    800005ca:	0017c783          	lbu	a5,1(a5)
    c1 = c2 = 0;
    800005ce:	86be                	mv	a3,a5
    if(c1) c2 = fmt[i+2] & 0xff;
    800005d0:	c789                	beqz	a5,800005da <printf+0xae>
    800005d2:	009a0733          	add	a4,s4,s1
    800005d6:	00274683          	lbu	a3,2(a4)
    if(c0 == 'd'){
    800005da:	03690963          	beq	s2,s6,8000060c <printf+0xe0>
    } else if(c0 == 'l' && c1 == 'd'){
    800005de:	05890363          	beq	s2,s8,80000624 <printf+0xf8>
    } else if(c0 == 'u'){
    800005e2:	0d990663          	beq	s2,s9,800006ae <printf+0x182>
    } else if(c0 == 'x'){
    800005e6:	11a90d63          	beq	s2,s10,80000700 <printf+0x1d4>
    } else if(c0 == 'p'){
    800005ea:	15b90663          	beq	s2,s11,80000736 <printf+0x20a>
      printptr(va_arg(ap, uint64));
    } else if(c0 == 'c'){
    800005ee:	06300793          	li	a5,99
    800005f2:	18f90563          	beq	s2,a5,8000077c <printf+0x250>
      consputc(va_arg(ap, uint));
    } else if(c0 == 's'){
    800005f6:	07300793          	li	a5,115
    800005fa:	18f90b63          	beq	s2,a5,80000790 <printf+0x264>
      if((s = va_arg(ap, char*)) == 0)
        s = "(null)";
      for(; *s; s++)
        consputc(*s);
    } else if(c0 == '%'){
    800005fe:	03591b63          	bne	s2,s5,80000634 <printf+0x108>
      consputc('%');
    80000602:	02500513          	li	a0,37
    80000606:	c91ff0ef          	jal	80000296 <consputc>
    8000060a:	bf71                	j	800005a6 <printf+0x7a>
      printint(va_arg(ap, int), 10, 1);
    8000060c:	f8843783          	ld	a5,-120(s0)
    80000610:	00878713          	addi	a4,a5,8
    80000614:	f8e43423          	sd	a4,-120(s0)
    80000618:	4605                	li	a2,1
    8000061a:	45a9                	li	a1,10
    8000061c:	4388                	lw	a0,0(a5)
    8000061e:	e7dff0ef          	jal	8000049a <printint>
    80000622:	b751                	j	800005a6 <printf+0x7a>
    } else if(c0 == 'l' && c1 == 'd'){
    80000624:	01678f63          	beq	a5,s6,80000642 <printf+0x116>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
    80000628:	03878b63          	beq	a5,s8,8000065e <printf+0x132>
    } else if(c0 == 'l' && c1 == 'u'){
    8000062c:	09978e63          	beq	a5,s9,800006c8 <printf+0x19c>
    } else if(c0 == 'l' && c1 == 'x'){
    80000630:	0fa78563          	beq	a5,s10,8000071a <printf+0x1ee>
    } else if(c0 == 0){
      break;
    } else {
      // Print unknown % sequence to draw attention.
      consputc('%');
    80000634:	8556                	mv	a0,s5
    80000636:	c61ff0ef          	jal	80000296 <consputc>
      consputc(c0);
    8000063a:	854a                	mv	a0,s2
    8000063c:	c5bff0ef          	jal	80000296 <consputc>
    80000640:	b79d                	j	800005a6 <printf+0x7a>
      printint(va_arg(ap, uint64), 10, 1);
    80000642:	f8843783          	ld	a5,-120(s0)
    80000646:	00878713          	addi	a4,a5,8
    8000064a:	f8e43423          	sd	a4,-120(s0)
    8000064e:	4605                	li	a2,1
    80000650:	45a9                	li	a1,10
    80000652:	6388                	ld	a0,0(a5)
    80000654:	e47ff0ef          	jal	8000049a <printint>
      i += 1;
    80000658:	0029849b          	addiw	s1,s3,2
    8000065c:	b7a9                	j	800005a6 <printf+0x7a>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
    8000065e:	06400793          	li	a5,100
    80000662:	02f68863          	beq	a3,a5,80000692 <printf+0x166>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
    80000666:	07500793          	li	a5,117
    8000066a:	06f68d63          	beq	a3,a5,800006e4 <printf+0x1b8>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
    8000066e:	07800793          	li	a5,120
    80000672:	fcf691e3          	bne	a3,a5,80000634 <printf+0x108>
      printint(va_arg(ap, uint64), 16, 0);
    80000676:	f8843783          	ld	a5,-120(s0)
    8000067a:	00878713          	addi	a4,a5,8
    8000067e:	f8e43423          	sd	a4,-120(s0)
    80000682:	4601                	li	a2,0
    80000684:	45c1                	li	a1,16
    80000686:	6388                	ld	a0,0(a5)
    80000688:	e13ff0ef          	jal	8000049a <printint>
      i += 2;
    8000068c:	0039849b          	addiw	s1,s3,3
    80000690:	bf19                	j	800005a6 <printf+0x7a>
      printint(va_arg(ap, uint64), 10, 1);
    80000692:	f8843783          	ld	a5,-120(s0)
    80000696:	00878713          	addi	a4,a5,8
    8000069a:	f8e43423          	sd	a4,-120(s0)
    8000069e:	4605                	li	a2,1
    800006a0:	45a9                	li	a1,10
    800006a2:	6388                	ld	a0,0(a5)
    800006a4:	df7ff0ef          	jal	8000049a <printint>
      i += 2;
    800006a8:	0039849b          	addiw	s1,s3,3
    800006ac:	bded                	j	800005a6 <printf+0x7a>
      printint(va_arg(ap, uint32), 10, 0);
    800006ae:	f8843783          	ld	a5,-120(s0)
    800006b2:	00878713          	addi	a4,a5,8
    800006b6:	f8e43423          	sd	a4,-120(s0)
    800006ba:	4601                	li	a2,0
    800006bc:	45a9                	li	a1,10
    800006be:	0007e503          	lwu	a0,0(a5)
    800006c2:	dd9ff0ef          	jal	8000049a <printint>
    800006c6:	b5c5                	j	800005a6 <printf+0x7a>
      printint(va_arg(ap, uint64), 10, 0);
    800006c8:	f8843783          	ld	a5,-120(s0)
    800006cc:	00878713          	addi	a4,a5,8
    800006d0:	f8e43423          	sd	a4,-120(s0)
    800006d4:	4601                	li	a2,0
    800006d6:	45a9                	li	a1,10
    800006d8:	6388                	ld	a0,0(a5)
    800006da:	dc1ff0ef          	jal	8000049a <printint>
      i += 1;
    800006de:	0029849b          	addiw	s1,s3,2
    800006e2:	b5d1                	j	800005a6 <printf+0x7a>
      printint(va_arg(ap, uint64), 10, 0);
    800006e4:	f8843783          	ld	a5,-120(s0)
    800006e8:	00878713          	addi	a4,a5,8
    800006ec:	f8e43423          	sd	a4,-120(s0)
    800006f0:	4601                	li	a2,0
    800006f2:	45a9                	li	a1,10
    800006f4:	6388                	ld	a0,0(a5)
    800006f6:	da5ff0ef          	jal	8000049a <printint>
      i += 2;
    800006fa:	0039849b          	addiw	s1,s3,3
    800006fe:	b565                	j	800005a6 <printf+0x7a>
      printint(va_arg(ap, uint32), 16, 0);
    80000700:	f8843783          	ld	a5,-120(s0)
    80000704:	00878713          	addi	a4,a5,8
    80000708:	f8e43423          	sd	a4,-120(s0)
    8000070c:	4601                	li	a2,0
    8000070e:	45c1                	li	a1,16
    80000710:	0007e503          	lwu	a0,0(a5)
    80000714:	d87ff0ef          	jal	8000049a <printint>
    80000718:	b579                	j	800005a6 <printf+0x7a>
      printint(va_arg(ap, uint64), 16, 0);
    8000071a:	f8843783          	ld	a5,-120(s0)
    8000071e:	00878713          	addi	a4,a5,8
    80000722:	f8e43423          	sd	a4,-120(s0)
    80000726:	4601                	li	a2,0
    80000728:	45c1                	li	a1,16
    8000072a:	6388                	ld	a0,0(a5)
    8000072c:	d6fff0ef          	jal	8000049a <printint>
      i += 1;
    80000730:	0029849b          	addiw	s1,s3,2
    80000734:	bd8d                	j	800005a6 <printf+0x7a>
    80000736:	fc5e                	sd	s7,56(sp)
      printptr(va_arg(ap, uint64));
    80000738:	f8843783          	ld	a5,-120(s0)
    8000073c:	00878713          	addi	a4,a5,8
    80000740:	f8e43423          	sd	a4,-120(s0)
    80000744:	0007b983          	ld	s3,0(a5)
  consputc('0');
    80000748:	03000513          	li	a0,48
    8000074c:	b4bff0ef          	jal	80000296 <consputc>
  consputc('x');
    80000750:	07800513          	li	a0,120
    80000754:	b43ff0ef          	jal	80000296 <consputc>
    80000758:	4941                	li	s2,16
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    8000075a:	00008b97          	auipc	s7,0x8
    8000075e:	02eb8b93          	addi	s7,s7,46 # 80008788 <digits>
    80000762:	03c9d793          	srli	a5,s3,0x3c
    80000766:	97de                	add	a5,a5,s7
    80000768:	0007c503          	lbu	a0,0(a5)
    8000076c:	b2bff0ef          	jal	80000296 <consputc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    80000770:	0992                	slli	s3,s3,0x4
    80000772:	397d                	addiw	s2,s2,-1
    80000774:	fe0917e3          	bnez	s2,80000762 <printf+0x236>
    80000778:	7be2                	ld	s7,56(sp)
    8000077a:	b535                	j	800005a6 <printf+0x7a>
      consputc(va_arg(ap, uint));
    8000077c:	f8843783          	ld	a5,-120(s0)
    80000780:	00878713          	addi	a4,a5,8
    80000784:	f8e43423          	sd	a4,-120(s0)
    80000788:	4388                	lw	a0,0(a5)
    8000078a:	b0dff0ef          	jal	80000296 <consputc>
    8000078e:	bd21                	j	800005a6 <printf+0x7a>
      if((s = va_arg(ap, char*)) == 0)
    80000790:	f8843783          	ld	a5,-120(s0)
    80000794:	00878713          	addi	a4,a5,8
    80000798:	f8e43423          	sd	a4,-120(s0)
    8000079c:	0007b903          	ld	s2,0(a5)
    800007a0:	00090d63          	beqz	s2,800007ba <printf+0x28e>
      for(; *s; s++)
    800007a4:	00094503          	lbu	a0,0(s2)
    800007a8:	de050fe3          	beqz	a0,800005a6 <printf+0x7a>
        consputc(*s);
    800007ac:	aebff0ef          	jal	80000296 <consputc>
      for(; *s; s++)
    800007b0:	0905                	addi	s2,s2,1
    800007b2:	00094503          	lbu	a0,0(s2)
    800007b6:	f97d                	bnez	a0,800007ac <printf+0x280>
    800007b8:	b3fd                	j	800005a6 <printf+0x7a>
        s = "(null)";
    800007ba:	00008917          	auipc	s2,0x8
    800007be:	85e90913          	addi	s2,s2,-1954 # 80008018 <etext+0x18>
      for(; *s; s++)
    800007c2:	02800513          	li	a0,40
    800007c6:	b7dd                	j	800007ac <printf+0x280>
    800007c8:	74a6                	ld	s1,104(sp)
    800007ca:	7906                	ld	s2,96(sp)
    800007cc:	69e6                	ld	s3,88(sp)
    800007ce:	6aa6                	ld	s5,72(sp)
    800007d0:	6b06                	ld	s6,64(sp)
    800007d2:	7c42                	ld	s8,48(sp)
    800007d4:	7ca2                	ld	s9,40(sp)
    800007d6:	7d02                	ld	s10,32(sp)
    800007d8:	6de2                	ld	s11,24(sp)
    800007da:	a811                	j	800007ee <printf+0x2c2>
    800007dc:	74a6                	ld	s1,104(sp)
    800007de:	7906                	ld	s2,96(sp)
    800007e0:	69e6                	ld	s3,88(sp)
    800007e2:	6aa6                	ld	s5,72(sp)
    800007e4:	6b06                	ld	s6,64(sp)
    800007e6:	7c42                	ld	s8,48(sp)
    800007e8:	7ca2                	ld	s9,40(sp)
    800007ea:	7d02                	ld	s10,32(sp)
    800007ec:	6de2                	ld	s11,24(sp)
    }

  }
  va_end(ap);

  if(panicking == 0)
    800007ee:	0000b797          	auipc	a5,0xb
    800007f2:	eb67a783          	lw	a5,-330(a5) # 8000b6a4 <panicking>
    800007f6:	c799                	beqz	a5,80000804 <printf+0x2d8>
    release(&pr.lock);

  return 0;
}
    800007f8:	4501                	li	a0,0
    800007fa:	70e6                	ld	ra,120(sp)
    800007fc:	7446                	ld	s0,112(sp)
    800007fe:	6a46                	ld	s4,80(sp)
    80000800:	6129                	addi	sp,sp,192
    80000802:	8082                	ret
    release(&pr.lock);
    80000804:	00013517          	auipc	a0,0x13
    80000808:	fd450513          	addi	a0,a0,-44 # 800137d8 <pr>
    8000080c:	548000ef          	jal	80000d54 <release>
  return 0;
    80000810:	b7e5                	j	800007f8 <printf+0x2cc>

0000000080000812 <panic>:

void
panic(char *s)
{
    80000812:	1101                	addi	sp,sp,-32
    80000814:	ec06                	sd	ra,24(sp)
    80000816:	e822                	sd	s0,16(sp)
    80000818:	e426                	sd	s1,8(sp)
    8000081a:	e04a                	sd	s2,0(sp)
    8000081c:	1000                	addi	s0,sp,32
    8000081e:	84aa                	mv	s1,a0
  panicking = 1;
    80000820:	4905                	li	s2,1
    80000822:	0000b797          	auipc	a5,0xb
    80000826:	e927a123          	sw	s2,-382(a5) # 8000b6a4 <panicking>
  printf("panic: ");
    8000082a:	00007517          	auipc	a0,0x7
    8000082e:	7f650513          	addi	a0,a0,2038 # 80008020 <etext+0x20>
    80000832:	cfbff0ef          	jal	8000052c <printf>
  printf("%s\n", s);
    80000836:	85a6                	mv	a1,s1
    80000838:	00007517          	auipc	a0,0x7
    8000083c:	7f050513          	addi	a0,a0,2032 # 80008028 <etext+0x28>
    80000840:	cedff0ef          	jal	8000052c <printf>
  panicked = 1; // freeze uart output from other CPUs
    80000844:	0000b797          	auipc	a5,0xb
    80000848:	e527ae23          	sw	s2,-420(a5) # 8000b6a0 <panicked>
  for(;;)
    8000084c:	a001                	j	8000084c <panic+0x3a>

000000008000084e <printfinit>:
    ;
}

void
printfinit(void)
{
    8000084e:	1141                	addi	sp,sp,-16
    80000850:	e406                	sd	ra,8(sp)
    80000852:	e022                	sd	s0,0(sp)
    80000854:	0800                	addi	s0,sp,16
  initlock(&pr.lock, "pr");
    80000856:	00007597          	auipc	a1,0x7
    8000085a:	7da58593          	addi	a1,a1,2010 # 80008030 <etext+0x30>
    8000085e:	00013517          	auipc	a0,0x13
    80000862:	f7a50513          	addi	a0,a0,-134 # 800137d8 <pr>
    80000866:	3d6000ef          	jal	80000c3c <initlock>
}
    8000086a:	60a2                	ld	ra,8(sp)
    8000086c:	6402                	ld	s0,0(sp)
    8000086e:	0141                	addi	sp,sp,16
    80000870:	8082                	ret

0000000080000872 <uartinit>:
extern volatile int panicking; // from printf.c
extern volatile int panicked; // from printf.c

void
uartinit(void)
{
    80000872:	1141                	addi	sp,sp,-16
    80000874:	e406                	sd	ra,8(sp)
    80000876:	e022                	sd	s0,0(sp)
    80000878:	0800                	addi	s0,sp,16
  // disable interrupts.
  WriteReg(IER, 0x00);
    8000087a:	100007b7          	lui	a5,0x10000
    8000087e:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>

  // special mode to set baud rate.
  WriteReg(LCR, LCR_BAUD_LATCH);
    80000882:	10000737          	lui	a4,0x10000
    80000886:	f8000693          	li	a3,-128
    8000088a:	00d701a3          	sb	a3,3(a4) # 10000003 <_entry-0x6ffffffd>

  // LSB for baud rate of 38.4K.
  WriteReg(0, 0x03);
    8000088e:	468d                	li	a3,3
    80000890:	10000637          	lui	a2,0x10000
    80000894:	00d60023          	sb	a3,0(a2) # 10000000 <_entry-0x70000000>

  // MSB for baud rate of 38.4K.
  WriteReg(1, 0x00);
    80000898:	000780a3          	sb	zero,1(a5)

  // leave set-baud mode,
  // and set word length to 8 bits, no parity.
  WriteReg(LCR, LCR_EIGHT_BITS);
    8000089c:	00d701a3          	sb	a3,3(a4)

  // reset and enable FIFOs.
  WriteReg(FCR, FCR_FIFO_ENABLE | FCR_FIFO_CLEAR);
    800008a0:	10000737          	lui	a4,0x10000
    800008a4:	461d                	li	a2,7
    800008a6:	00c70123          	sb	a2,2(a4) # 10000002 <_entry-0x6ffffffe>

  // enable transmit and receive interrupts.
  WriteReg(IER, IER_TX_ENABLE | IER_RX_ENABLE);
    800008aa:	00d780a3          	sb	a3,1(a5)

  initlock(&tx_lock, "uart");
    800008ae:	00007597          	auipc	a1,0x7
    800008b2:	78a58593          	addi	a1,a1,1930 # 80008038 <etext+0x38>
    800008b6:	00013517          	auipc	a0,0x13
    800008ba:	f3a50513          	addi	a0,a0,-198 # 800137f0 <tx_lock>
    800008be:	37e000ef          	jal	80000c3c <initlock>
}
    800008c2:	60a2                	ld	ra,8(sp)
    800008c4:	6402                	ld	s0,0(sp)
    800008c6:	0141                	addi	sp,sp,16
    800008c8:	8082                	ret

00000000800008ca <uartwrite>:
// transmit buf[] to the uart. it blocks if the
// uart is busy, so it cannot be called from
// interrupts, only from write() system calls.
void
uartwrite(char buf[], int n)
{
    800008ca:	715d                	addi	sp,sp,-80
    800008cc:	e486                	sd	ra,72(sp)
    800008ce:	e0a2                	sd	s0,64(sp)
    800008d0:	fc26                	sd	s1,56(sp)
    800008d2:	ec56                	sd	s5,24(sp)
    800008d4:	0880                	addi	s0,sp,80
    800008d6:	8aaa                	mv	s5,a0
    800008d8:	84ae                	mv	s1,a1
  acquire(&tx_lock);
    800008da:	00013517          	auipc	a0,0x13
    800008de:	f1650513          	addi	a0,a0,-234 # 800137f0 <tx_lock>
    800008e2:	3da000ef          	jal	80000cbc <acquire>

  int i = 0;
  while(i < n){ 
    800008e6:	06905063          	blez	s1,80000946 <uartwrite+0x7c>
    800008ea:	f84a                	sd	s2,48(sp)
    800008ec:	f44e                	sd	s3,40(sp)
    800008ee:	f052                	sd	s4,32(sp)
    800008f0:	e85a                	sd	s6,16(sp)
    800008f2:	e45e                	sd	s7,8(sp)
    800008f4:	8a56                	mv	s4,s5
    800008f6:	9aa6                	add	s5,s5,s1
    while(tx_busy != 0){
    800008f8:	0000b497          	auipc	s1,0xb
    800008fc:	db448493          	addi	s1,s1,-588 # 8000b6ac <tx_busy>
      // wait for a UART transmit-complete interrupt
      // to set tx_busy to 0.
      sleep(&tx_chan, &tx_lock);
    80000900:	00013997          	auipc	s3,0x13
    80000904:	ef098993          	addi	s3,s3,-272 # 800137f0 <tx_lock>
    80000908:	0000b917          	auipc	s2,0xb
    8000090c:	da090913          	addi	s2,s2,-608 # 8000b6a8 <tx_chan>
    }   
      
    WriteReg(THR, buf[i]);
    80000910:	10000bb7          	lui	s7,0x10000
    i += 1;
    tx_busy = 1;
    80000914:	4b05                	li	s6,1
    80000916:	a005                	j	80000936 <uartwrite+0x6c>
      sleep(&tx_chan, &tx_lock);
    80000918:	85ce                	mv	a1,s3
    8000091a:	854a                	mv	a0,s2
    8000091c:	2db010ef          	jal	800023f6 <sleep>
    while(tx_busy != 0){
    80000920:	409c                	lw	a5,0(s1)
    80000922:	fbfd                	bnez	a5,80000918 <uartwrite+0x4e>
    WriteReg(THR, buf[i]);
    80000924:	000a4783          	lbu	a5,0(s4)
    80000928:	00fb8023          	sb	a5,0(s7) # 10000000 <_entry-0x70000000>
    tx_busy = 1;
    8000092c:	0164a023          	sw	s6,0(s1)
  while(i < n){ 
    80000930:	0a05                	addi	s4,s4,1
    80000932:	015a0563          	beq	s4,s5,8000093c <uartwrite+0x72>
    while(tx_busy != 0){
    80000936:	409c                	lw	a5,0(s1)
    80000938:	f3e5                	bnez	a5,80000918 <uartwrite+0x4e>
    8000093a:	b7ed                	j	80000924 <uartwrite+0x5a>
    8000093c:	7942                	ld	s2,48(sp)
    8000093e:	79a2                	ld	s3,40(sp)
    80000940:	7a02                	ld	s4,32(sp)
    80000942:	6b42                	ld	s6,16(sp)
    80000944:	6ba2                	ld	s7,8(sp)
  }

  release(&tx_lock);
    80000946:	00013517          	auipc	a0,0x13
    8000094a:	eaa50513          	addi	a0,a0,-342 # 800137f0 <tx_lock>
    8000094e:	406000ef          	jal	80000d54 <release>
}
    80000952:	60a6                	ld	ra,72(sp)
    80000954:	6406                	ld	s0,64(sp)
    80000956:	74e2                	ld	s1,56(sp)
    80000958:	6ae2                	ld	s5,24(sp)
    8000095a:	6161                	addi	sp,sp,80
    8000095c:	8082                	ret

000000008000095e <uartputc_sync>:
// interrupts, for use by kernel printf() and
// to echo characters. it spins waiting for the uart's
// output register to be empty.
void
uartputc_sync(int c)
{
    8000095e:	1101                	addi	sp,sp,-32
    80000960:	ec06                	sd	ra,24(sp)
    80000962:	e822                	sd	s0,16(sp)
    80000964:	e426                	sd	s1,8(sp)
    80000966:	1000                	addi	s0,sp,32
    80000968:	84aa                	mv	s1,a0
  if(panicking == 0)
    8000096a:	0000b797          	auipc	a5,0xb
    8000096e:	d3a7a783          	lw	a5,-710(a5) # 8000b6a4 <panicking>
    80000972:	cf95                	beqz	a5,800009ae <uartputc_sync+0x50>
    push_off();

  if(panicked){
    80000974:	0000b797          	auipc	a5,0xb
    80000978:	d2c7a783          	lw	a5,-724(a5) # 8000b6a0 <panicked>
    8000097c:	ef85                	bnez	a5,800009b4 <uartputc_sync+0x56>
    for(;;)
      ;
  }

  // wait for UART to set Transmit Holding Empty in LSR.
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    8000097e:	10000737          	lui	a4,0x10000
    80000982:	0715                	addi	a4,a4,5 # 10000005 <_entry-0x6ffffffb>
    80000984:	00074783          	lbu	a5,0(a4)
    80000988:	0207f793          	andi	a5,a5,32
    8000098c:	dfe5                	beqz	a5,80000984 <uartputc_sync+0x26>
    ;
  WriteReg(THR, c);
    8000098e:	0ff4f513          	zext.b	a0,s1
    80000992:	100007b7          	lui	a5,0x10000
    80000996:	00a78023          	sb	a0,0(a5) # 10000000 <_entry-0x70000000>

  if(panicking == 0)
    8000099a:	0000b797          	auipc	a5,0xb
    8000099e:	d0a7a783          	lw	a5,-758(a5) # 8000b6a4 <panicking>
    800009a2:	cb91                	beqz	a5,800009b6 <uartputc_sync+0x58>
    pop_off();
}
    800009a4:	60e2                	ld	ra,24(sp)
    800009a6:	6442                	ld	s0,16(sp)
    800009a8:	64a2                	ld	s1,8(sp)
    800009aa:	6105                	addi	sp,sp,32
    800009ac:	8082                	ret
    push_off();
    800009ae:	2ce000ef          	jal	80000c7c <push_off>
    800009b2:	b7c9                	j	80000974 <uartputc_sync+0x16>
    for(;;)
    800009b4:	a001                	j	800009b4 <uartputc_sync+0x56>
    pop_off();
    800009b6:	34a000ef          	jal	80000d00 <pop_off>
}
    800009ba:	b7ed                	j	800009a4 <uartputc_sync+0x46>

00000000800009bc <uartgetc>:

// try to read one input character from the UART.
// return -1 if none is waiting.
int
uartgetc(void)
{
    800009bc:	1141                	addi	sp,sp,-16
    800009be:	e422                	sd	s0,8(sp)
    800009c0:	0800                	addi	s0,sp,16
  if(ReadReg(LSR) & LSR_RX_READY){
    800009c2:	100007b7          	lui	a5,0x10000
    800009c6:	0795                	addi	a5,a5,5 # 10000005 <_entry-0x6ffffffb>
    800009c8:	0007c783          	lbu	a5,0(a5)
    800009cc:	8b85                	andi	a5,a5,1
    800009ce:	cb81                	beqz	a5,800009de <uartgetc+0x22>
    // input data is ready.
    return ReadReg(RHR);
    800009d0:	100007b7          	lui	a5,0x10000
    800009d4:	0007c503          	lbu	a0,0(a5) # 10000000 <_entry-0x70000000>
  } else {
    return -1;
  }
}
    800009d8:	6422                	ld	s0,8(sp)
    800009da:	0141                	addi	sp,sp,16
    800009dc:	8082                	ret
    return -1;
    800009de:	557d                	li	a0,-1
    800009e0:	bfe5                	j	800009d8 <uartgetc+0x1c>

00000000800009e2 <uartintr>:
// handle a uart interrupt, raised because input has
// arrived, or the uart is ready for more output, or
// both. called from devintr().
void
uartintr(void)
{
    800009e2:	1101                	addi	sp,sp,-32
    800009e4:	ec06                	sd	ra,24(sp)
    800009e6:	e822                	sd	s0,16(sp)
    800009e8:	e426                	sd	s1,8(sp)
    800009ea:	1000                	addi	s0,sp,32
  ReadReg(ISR); // acknowledge the interrupt
    800009ec:	100007b7          	lui	a5,0x10000
    800009f0:	0789                	addi	a5,a5,2 # 10000002 <_entry-0x6ffffffe>
    800009f2:	0007c783          	lbu	a5,0(a5)

  acquire(&tx_lock);
    800009f6:	00013517          	auipc	a0,0x13
    800009fa:	dfa50513          	addi	a0,a0,-518 # 800137f0 <tx_lock>
    800009fe:	2be000ef          	jal	80000cbc <acquire>
  if(ReadReg(LSR) & LSR_TX_IDLE){
    80000a02:	100007b7          	lui	a5,0x10000
    80000a06:	0795                	addi	a5,a5,5 # 10000005 <_entry-0x6ffffffb>
    80000a08:	0007c783          	lbu	a5,0(a5)
    80000a0c:	0207f793          	andi	a5,a5,32
    80000a10:	eb89                	bnez	a5,80000a22 <uartintr+0x40>
    // UART finished transmitting; wake up sending thread.
    tx_busy = 0;
    wakeup(&tx_chan);
  }
  release(&tx_lock);
    80000a12:	00013517          	auipc	a0,0x13
    80000a16:	dde50513          	addi	a0,a0,-546 # 800137f0 <tx_lock>
    80000a1a:	33a000ef          	jal	80000d54 <release>

  // read and process incoming characters, if any.
  while(1){
    int c = uartgetc();
    if(c == -1)
    80000a1e:	54fd                	li	s1,-1
    80000a20:	a831                	j	80000a3c <uartintr+0x5a>
    tx_busy = 0;
    80000a22:	0000b797          	auipc	a5,0xb
    80000a26:	c807a523          	sw	zero,-886(a5) # 8000b6ac <tx_busy>
    wakeup(&tx_chan);
    80000a2a:	0000b517          	auipc	a0,0xb
    80000a2e:	c7e50513          	addi	a0,a0,-898 # 8000b6a8 <tx_chan>
    80000a32:	211010ef          	jal	80002442 <wakeup>
    80000a36:	bff1                	j	80000a12 <uartintr+0x30>
      break;
    consoleintr(c);
    80000a38:	891ff0ef          	jal	800002c8 <consoleintr>
    int c = uartgetc();
    80000a3c:	f81ff0ef          	jal	800009bc <uartgetc>
    if(c == -1)
    80000a40:	fe951ce3          	bne	a0,s1,80000a38 <uartintr+0x56>
  }
}
    80000a44:	60e2                	ld	ra,24(sp)
    80000a46:	6442                	ld	s0,16(sp)
    80000a48:	64a2                	ld	s1,8(sp)
    80000a4a:	6105                	addi	sp,sp,32
    80000a4c:	8082                	ret

0000000080000a4e <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(void *pa)
{
    80000a4e:	7175                	addi	sp,sp,-144
    80000a50:	e506                	sd	ra,136(sp)
    80000a52:	e122                	sd	s0,128(sp)
    80000a54:	fca6                	sd	s1,120(sp)
    80000a56:	f8ca                	sd	s2,112(sp)
    80000a58:	0900                	addi	s0,sp,144
  struct run *r;

  if(((uint64)pa % PGSIZE) != 0 || (char*)pa < end || (uint64)pa >= PHYSTOP)
    80000a5a:	03451793          	slli	a5,a0,0x34
    80000a5e:	e7c5                	bnez	a5,80000b06 <kfree+0xb8>
    80000a60:	84aa                	mv	s1,a0
    80000a62:	00049797          	auipc	a5,0x49
    80000a66:	09678793          	addi	a5,a5,150 # 80049af8 <end>
    80000a6a:	08f56e63          	bltu	a0,a5,80000b06 <kfree+0xb8>
    80000a6e:	47c5                	li	a5,17
    80000a70:	07ee                	slli	a5,a5,0x1b
    80000a72:	08f57a63          	bgeu	a0,a5,80000b06 <kfree+0xb8>
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(pa, 1, PGSIZE);
    80000a76:	6605                	lui	a2,0x1
    80000a78:	4585                	li	a1,1
    80000a7a:	316000ef          	jal	80000d90 <memset>

  r = (struct run*)pa;

  acquire(&kmem.lock);
    80000a7e:	00013917          	auipc	s2,0x13
    80000a82:	d8a90913          	addi	s2,s2,-630 # 80013808 <kmem>
    80000a86:	854a                	mv	a0,s2
    80000a88:	234000ef          	jal	80000cbc <acquire>
  r->next = kmem.freelist;
    80000a8c:	01893783          	ld	a5,24(s2)
    80000a90:	e09c                	sd	a5,0(s1)
  kmem.freelist = r;
    80000a92:	00993c23          	sd	s1,24(s2)
  release(&kmem.lock);
    80000a96:	854a                	mv	a0,s2
    80000a98:	2bc000ef          	jal	80000d54 <release>

  struct mem_event e;
  memset(&e, 0, sizeof(e));
    80000a9c:	06800613          	li	a2,104
    80000aa0:	4581                	li	a1,0
    80000aa2:	f7840513          	addi	a0,s0,-136
    80000aa6:	2ea000ef          	jal	80000d90 <memset>

  e.ticks  = ticks;
    80000aaa:	0000b797          	auipc	a5,0xb
    80000aae:	c267a783          	lw	a5,-986(a5) # 8000b6d0 <ticks>
    80000ab2:	f8f42023          	sw	a5,-128(s0)
  e.cpu    = cpuid();
    80000ab6:	0f0010ef          	jal	80001ba6 <cpuid>
    80000aba:	f8a42223          	sw	a0,-124(s0)
  e.type   = MEM_FREE;
    80000abe:	479d                	li	a5,7
    80000ac0:	f8f42423          	sw	a5,-120(s0)
  e.pa     = (uint64)pa;
    80000ac4:	fa943823          	sd	s1,-80(s0)
  e.source = SRC_KFREE;
    80000ac8:	4789                	li	a5,2
    80000aca:	fcf42a23          	sw	a5,-44(s0)
  e.kind   = PAGE_UNKNOWN;
    80000ace:	fc042c23          	sw	zero,-40(s0)

  struct proc *p = myproc();
    80000ad2:	100010ef          	jal	80001bd2 <myproc>
  if(p){
    80000ad6:	cd11                	beqz	a0,80000af2 <kfree+0xa4>
    e.pid = p->pid;
    80000ad8:	591c                	lw	a5,48(a0)
    80000ada:	f8f42623          	sw	a5,-116(s0)
    e.state = p->state;
    80000ade:	4d1c                	lw	a5,24(a0)
    80000ae0:	f8f42823          	sw	a5,-112(s0)
    safestrcpy(e.name, p->name, MEM_NM);
    80000ae4:	4641                	li	a2,16
    80000ae6:	15850593          	addi	a1,a0,344
    80000aea:	f9440513          	addi	a0,s0,-108
    80000aee:	3e0000ef          	jal	80000ece <safestrcpy>
  }

  memlog_push(&e);
    80000af2:	f7840513          	addi	a0,s0,-136
    80000af6:	15d050ef          	jal	80006452 <memlog_push>
}
    80000afa:	60aa                	ld	ra,136(sp)
    80000afc:	640a                	ld	s0,128(sp)
    80000afe:	74e6                	ld	s1,120(sp)
    80000b00:	7946                	ld	s2,112(sp)
    80000b02:	6149                	addi	sp,sp,144
    80000b04:	8082                	ret
    panic("kfree");
    80000b06:	00007517          	auipc	a0,0x7
    80000b0a:	53a50513          	addi	a0,a0,1338 # 80008040 <etext+0x40>
    80000b0e:	d05ff0ef          	jal	80000812 <panic>

0000000080000b12 <freerange>:
{
    80000b12:	7179                	addi	sp,sp,-48
    80000b14:	f406                	sd	ra,40(sp)
    80000b16:	f022                	sd	s0,32(sp)
    80000b18:	ec26                	sd	s1,24(sp)
    80000b1a:	1800                	addi	s0,sp,48
  p = (char*)PGROUNDUP((uint64)pa_start);
    80000b1c:	6785                	lui	a5,0x1
    80000b1e:	fff78713          	addi	a4,a5,-1 # fff <_entry-0x7ffff001>
    80000b22:	00e504b3          	add	s1,a0,a4
    80000b26:	777d                	lui	a4,0xfffff
    80000b28:	8cf9                	and	s1,s1,a4
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000b2a:	94be                	add	s1,s1,a5
    80000b2c:	0295e263          	bltu	a1,s1,80000b50 <freerange+0x3e>
    80000b30:	e84a                	sd	s2,16(sp)
    80000b32:	e44e                	sd	s3,8(sp)
    80000b34:	e052                	sd	s4,0(sp)
    80000b36:	892e                	mv	s2,a1
    kfree(p);
    80000b38:	7a7d                	lui	s4,0xfffff
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000b3a:	6985                	lui	s3,0x1
    kfree(p);
    80000b3c:	01448533          	add	a0,s1,s4
    80000b40:	f0fff0ef          	jal	80000a4e <kfree>
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000b44:	94ce                	add	s1,s1,s3
    80000b46:	fe997be3          	bgeu	s2,s1,80000b3c <freerange+0x2a>
    80000b4a:	6942                	ld	s2,16(sp)
    80000b4c:	69a2                	ld	s3,8(sp)
    80000b4e:	6a02                	ld	s4,0(sp)
}
    80000b50:	70a2                	ld	ra,40(sp)
    80000b52:	7402                	ld	s0,32(sp)
    80000b54:	64e2                	ld	s1,24(sp)
    80000b56:	6145                	addi	sp,sp,48
    80000b58:	8082                	ret

0000000080000b5a <kinit>:
{
    80000b5a:	1141                	addi	sp,sp,-16
    80000b5c:	e406                	sd	ra,8(sp)
    80000b5e:	e022                	sd	s0,0(sp)
    80000b60:	0800                	addi	s0,sp,16
  initlock(&kmem.lock, "kmem");
    80000b62:	00007597          	auipc	a1,0x7
    80000b66:	4e658593          	addi	a1,a1,1254 # 80008048 <etext+0x48>
    80000b6a:	00013517          	auipc	a0,0x13
    80000b6e:	c9e50513          	addi	a0,a0,-866 # 80013808 <kmem>
    80000b72:	0ca000ef          	jal	80000c3c <initlock>
  freerange(end, (void*)PHYSTOP);
    80000b76:	45c5                	li	a1,17
    80000b78:	05ee                	slli	a1,a1,0x1b
    80000b7a:	00049517          	auipc	a0,0x49
    80000b7e:	f7e50513          	addi	a0,a0,-130 # 80049af8 <end>
    80000b82:	f91ff0ef          	jal	80000b12 <freerange>
}
    80000b86:	60a2                	ld	ra,8(sp)
    80000b88:	6402                	ld	s0,0(sp)
    80000b8a:	0141                	addi	sp,sp,16
    80000b8c:	8082                	ret

0000000080000b8e <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
    80000b8e:	7175                	addi	sp,sp,-144
    80000b90:	e506                	sd	ra,136(sp)
    80000b92:	e122                	sd	s0,128(sp)
    80000b94:	fca6                	sd	s1,120(sp)
    80000b96:	0900                	addi	s0,sp,144
  struct run *r;

  acquire(&kmem.lock);
    80000b98:	00013497          	auipc	s1,0x13
    80000b9c:	c7048493          	addi	s1,s1,-912 # 80013808 <kmem>
    80000ba0:	8526                	mv	a0,s1
    80000ba2:	11a000ef          	jal	80000cbc <acquire>
  r = kmem.freelist;
    80000ba6:	6c84                	ld	s1,24(s1)
  if(r)
    80000ba8:	c0d9                	beqz	s1,80000c2e <kalloc+0xa0>
    kmem.freelist = r->next;
    80000baa:	609c                	ld	a5,0(s1)
    80000bac:	00013517          	auipc	a0,0x13
    80000bb0:	c5c50513          	addi	a0,a0,-932 # 80013808 <kmem>
    80000bb4:	ed1c                	sd	a5,24(a0)
  release(&kmem.lock);
    80000bb6:	19e000ef          	jal	80000d54 <release>

  if(r)
    memset((char*)r, 5, PGSIZE); // fill with junk
    80000bba:	6605                	lui	a2,0x1
    80000bbc:	4595                	li	a1,5
    80000bbe:	8526                	mv	a0,s1
    80000bc0:	1d0000ef          	jal	80000d90 <memset>

  if(r){
    struct mem_event e;
    memset(&e, 0, sizeof(e));
    80000bc4:	06800613          	li	a2,104
    80000bc8:	4581                	li	a1,0
    80000bca:	f7840513          	addi	a0,s0,-136
    80000bce:	1c2000ef          	jal	80000d90 <memset>

    e.ticks  = ticks;
    80000bd2:	0000b797          	auipc	a5,0xb
    80000bd6:	afe7a783          	lw	a5,-1282(a5) # 8000b6d0 <ticks>
    80000bda:	f8f42023          	sw	a5,-128(s0)
    e.cpu    = cpuid();
    80000bde:	7c9000ef          	jal	80001ba6 <cpuid>
    80000be2:	f8a42223          	sw	a0,-124(s0)
    e.type   = MEM_ALLOC;
    80000be6:	4799                	li	a5,6
    80000be8:	f8f42423          	sw	a5,-120(s0)
    e.pa     = (uint64)r;
    80000bec:	fa943823          	sd	s1,-80(s0)
    e.source = SRC_KALLOC;
    80000bf0:	4785                	li	a5,1
    80000bf2:	fcf42a23          	sw	a5,-44(s0)
    e.kind   = PAGE_UNKNOWN;
    80000bf6:	fc042c23          	sw	zero,-40(s0)

    struct proc *p = myproc();
    80000bfa:	7d9000ef          	jal	80001bd2 <myproc>
    if(p){
    80000bfe:	cd11                	beqz	a0,80000c1a <kalloc+0x8c>
      e.pid = p->pid;
    80000c00:	591c                	lw	a5,48(a0)
    80000c02:	f8f42623          	sw	a5,-116(s0)
      e.state = p->state;
    80000c06:	4d1c                	lw	a5,24(a0)
    80000c08:	f8f42823          	sw	a5,-112(s0)
      safestrcpy(e.name, p->name, MEM_NM);
    80000c0c:	4641                	li	a2,16
    80000c0e:	15850593          	addi	a1,a0,344
    80000c12:	f9440513          	addi	a0,s0,-108
    80000c16:	2b8000ef          	jal	80000ece <safestrcpy>
    }

    memlog_push(&e);
    80000c1a:	f7840513          	addi	a0,s0,-136
    80000c1e:	035050ef          	jal	80006452 <memlog_push>
  }

  return (void*)r;
}
    80000c22:	8526                	mv	a0,s1
    80000c24:	60aa                	ld	ra,136(sp)
    80000c26:	640a                	ld	s0,128(sp)
    80000c28:	74e6                	ld	s1,120(sp)
    80000c2a:	6149                	addi	sp,sp,144
    80000c2c:	8082                	ret
  release(&kmem.lock);
    80000c2e:	00013517          	auipc	a0,0x13
    80000c32:	bda50513          	addi	a0,a0,-1062 # 80013808 <kmem>
    80000c36:	11e000ef          	jal	80000d54 <release>
  if(r)
    80000c3a:	b7e5                	j	80000c22 <kalloc+0x94>

0000000080000c3c <initlock>:
#include "proc.h"
#include "defs.h"

void
initlock(struct spinlock *lk, char *name)
{
    80000c3c:	1141                	addi	sp,sp,-16
    80000c3e:	e422                	sd	s0,8(sp)
    80000c40:	0800                	addi	s0,sp,16
  lk->name = name;
    80000c42:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    80000c44:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    80000c48:	00053823          	sd	zero,16(a0)
}
    80000c4c:	6422                	ld	s0,8(sp)
    80000c4e:	0141                	addi	sp,sp,16
    80000c50:	8082                	ret

0000000080000c52 <holding>:
// Interrupts must be off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    80000c52:	411c                	lw	a5,0(a0)
    80000c54:	e399                	bnez	a5,80000c5a <holding+0x8>
    80000c56:	4501                	li	a0,0
  return r;
}
    80000c58:	8082                	ret
{
    80000c5a:	1101                	addi	sp,sp,-32
    80000c5c:	ec06                	sd	ra,24(sp)
    80000c5e:	e822                	sd	s0,16(sp)
    80000c60:	e426                	sd	s1,8(sp)
    80000c62:	1000                	addi	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    80000c64:	6904                	ld	s1,16(a0)
    80000c66:	751000ef          	jal	80001bb6 <mycpu>
    80000c6a:	40a48533          	sub	a0,s1,a0
    80000c6e:	00153513          	seqz	a0,a0
}
    80000c72:	60e2                	ld	ra,24(sp)
    80000c74:	6442                	ld	s0,16(sp)
    80000c76:	64a2                	ld	s1,8(sp)
    80000c78:	6105                	addi	sp,sp,32
    80000c7a:	8082                	ret

0000000080000c7c <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    80000c7c:	1101                	addi	sp,sp,-32
    80000c7e:	ec06                	sd	ra,24(sp)
    80000c80:	e822                	sd	s0,16(sp)
    80000c82:	e426                	sd	s1,8(sp)
    80000c84:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c86:	100024f3          	csrr	s1,sstatus
    80000c8a:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80000c8e:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000c90:	10079073          	csrw	sstatus,a5

  // disable interrupts to prevent an involuntary context
  // switch while using mycpu().
  intr_off();

  if(mycpu()->noff == 0)
    80000c94:	723000ef          	jal	80001bb6 <mycpu>
    80000c98:	5d3c                	lw	a5,120(a0)
    80000c9a:	cb99                	beqz	a5,80000cb0 <push_off+0x34>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000c9c:	71b000ef          	jal	80001bb6 <mycpu>
    80000ca0:	5d3c                	lw	a5,120(a0)
    80000ca2:	2785                	addiw	a5,a5,1
    80000ca4:	dd3c                	sw	a5,120(a0)
}
    80000ca6:	60e2                	ld	ra,24(sp)
    80000ca8:	6442                	ld	s0,16(sp)
    80000caa:	64a2                	ld	s1,8(sp)
    80000cac:	6105                	addi	sp,sp,32
    80000cae:	8082                	ret
    mycpu()->intena = old;
    80000cb0:	707000ef          	jal	80001bb6 <mycpu>
  return (x & SSTATUS_SIE) != 0;
    80000cb4:	8085                	srli	s1,s1,0x1
    80000cb6:	8885                	andi	s1,s1,1
    80000cb8:	dd64                	sw	s1,124(a0)
    80000cba:	b7cd                	j	80000c9c <push_off+0x20>

0000000080000cbc <acquire>:
{
    80000cbc:	1101                	addi	sp,sp,-32
    80000cbe:	ec06                	sd	ra,24(sp)
    80000cc0:	e822                	sd	s0,16(sp)
    80000cc2:	e426                	sd	s1,8(sp)
    80000cc4:	1000                	addi	s0,sp,32
    80000cc6:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    80000cc8:	fb5ff0ef          	jal	80000c7c <push_off>
  if(holding(lk))
    80000ccc:	8526                	mv	a0,s1
    80000cce:	f85ff0ef          	jal	80000c52 <holding>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000cd2:	4705                	li	a4,1
  if(holding(lk))
    80000cd4:	e105                	bnez	a0,80000cf4 <acquire+0x38>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000cd6:	87ba                	mv	a5,a4
    80000cd8:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80000cdc:	2781                	sext.w	a5,a5
    80000cde:	ffe5                	bnez	a5,80000cd6 <acquire+0x1a>
  __sync_synchronize();
    80000ce0:	0330000f          	fence	rw,rw
  lk->cpu = mycpu();
    80000ce4:	6d3000ef          	jal	80001bb6 <mycpu>
    80000ce8:	e888                	sd	a0,16(s1)
}
    80000cea:	60e2                	ld	ra,24(sp)
    80000cec:	6442                	ld	s0,16(sp)
    80000cee:	64a2                	ld	s1,8(sp)
    80000cf0:	6105                	addi	sp,sp,32
    80000cf2:	8082                	ret
    panic("acquire");
    80000cf4:	00007517          	auipc	a0,0x7
    80000cf8:	35c50513          	addi	a0,a0,860 # 80008050 <etext+0x50>
    80000cfc:	b17ff0ef          	jal	80000812 <panic>

0000000080000d00 <pop_off>:

void
pop_off(void)
{
    80000d00:	1141                	addi	sp,sp,-16
    80000d02:	e406                	sd	ra,8(sp)
    80000d04:	e022                	sd	s0,0(sp)
    80000d06:	0800                	addi	s0,sp,16
  struct cpu *c = mycpu();
    80000d08:	6af000ef          	jal	80001bb6 <mycpu>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000d0c:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80000d10:	8b89                	andi	a5,a5,2
  if(intr_get())
    80000d12:	e78d                	bnez	a5,80000d3c <pop_off+0x3c>
    panic("pop_off - interruptible");
  if(c->noff < 1)
    80000d14:	5d3c                	lw	a5,120(a0)
    80000d16:	02f05963          	blez	a5,80000d48 <pop_off+0x48>
    panic("pop_off");
  c->noff -= 1;
    80000d1a:	37fd                	addiw	a5,a5,-1
    80000d1c:	0007871b          	sext.w	a4,a5
    80000d20:	dd3c                	sw	a5,120(a0)
  if(c->noff == 0 && c->intena)
    80000d22:	eb09                	bnez	a4,80000d34 <pop_off+0x34>
    80000d24:	5d7c                	lw	a5,124(a0)
    80000d26:	c799                	beqz	a5,80000d34 <pop_off+0x34>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000d28:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80000d2c:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000d30:	10079073          	csrw	sstatus,a5
    intr_on();
}
    80000d34:	60a2                	ld	ra,8(sp)
    80000d36:	6402                	ld	s0,0(sp)
    80000d38:	0141                	addi	sp,sp,16
    80000d3a:	8082                	ret
    panic("pop_off - interruptible");
    80000d3c:	00007517          	auipc	a0,0x7
    80000d40:	31c50513          	addi	a0,a0,796 # 80008058 <etext+0x58>
    80000d44:	acfff0ef          	jal	80000812 <panic>
    panic("pop_off");
    80000d48:	00007517          	auipc	a0,0x7
    80000d4c:	32850513          	addi	a0,a0,808 # 80008070 <etext+0x70>
    80000d50:	ac3ff0ef          	jal	80000812 <panic>

0000000080000d54 <release>:
{
    80000d54:	1101                	addi	sp,sp,-32
    80000d56:	ec06                	sd	ra,24(sp)
    80000d58:	e822                	sd	s0,16(sp)
    80000d5a:	e426                	sd	s1,8(sp)
    80000d5c:	1000                	addi	s0,sp,32
    80000d5e:	84aa                	mv	s1,a0
  if(!holding(lk))
    80000d60:	ef3ff0ef          	jal	80000c52 <holding>
    80000d64:	c105                	beqz	a0,80000d84 <release+0x30>
  lk->cpu = 0;
    80000d66:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    80000d6a:	0330000f          	fence	rw,rw
  __sync_lock_release(&lk->locked);
    80000d6e:	0310000f          	fence	rw,w
    80000d72:	0004a023          	sw	zero,0(s1)
  pop_off();
    80000d76:	f8bff0ef          	jal	80000d00 <pop_off>
}
    80000d7a:	60e2                	ld	ra,24(sp)
    80000d7c:	6442                	ld	s0,16(sp)
    80000d7e:	64a2                	ld	s1,8(sp)
    80000d80:	6105                	addi	sp,sp,32
    80000d82:	8082                	ret
    panic("release");
    80000d84:	00007517          	auipc	a0,0x7
    80000d88:	2f450513          	addi	a0,a0,756 # 80008078 <etext+0x78>
    80000d8c:	a87ff0ef          	jal	80000812 <panic>

0000000080000d90 <memset>:
#include "types.h"

void*
memset(void *dst, int c, uint n)
{
    80000d90:	1141                	addi	sp,sp,-16
    80000d92:	e422                	sd	s0,8(sp)
    80000d94:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    80000d96:	ca19                	beqz	a2,80000dac <memset+0x1c>
    80000d98:	87aa                	mv	a5,a0
    80000d9a:	1602                	slli	a2,a2,0x20
    80000d9c:	9201                	srli	a2,a2,0x20
    80000d9e:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
    80000da2:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    80000da6:	0785                	addi	a5,a5,1
    80000da8:	fee79de3          	bne	a5,a4,80000da2 <memset+0x12>
  }
  return dst;
}
    80000dac:	6422                	ld	s0,8(sp)
    80000dae:	0141                	addi	sp,sp,16
    80000db0:	8082                	ret

0000000080000db2 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    80000db2:	1141                	addi	sp,sp,-16
    80000db4:	e422                	sd	s0,8(sp)
    80000db6:	0800                	addi	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    80000db8:	ca05                	beqz	a2,80000de8 <memcmp+0x36>
    80000dba:	fff6069b          	addiw	a3,a2,-1 # fff <_entry-0x7ffff001>
    80000dbe:	1682                	slli	a3,a3,0x20
    80000dc0:	9281                	srli	a3,a3,0x20
    80000dc2:	0685                	addi	a3,a3,1
    80000dc4:	96aa                	add	a3,a3,a0
    if(*s1 != *s2)
    80000dc6:	00054783          	lbu	a5,0(a0)
    80000dca:	0005c703          	lbu	a4,0(a1)
    80000dce:	00e79863          	bne	a5,a4,80000dde <memcmp+0x2c>
      return *s1 - *s2;
    s1++, s2++;
    80000dd2:	0505                	addi	a0,a0,1
    80000dd4:	0585                	addi	a1,a1,1
  while(n-- > 0){
    80000dd6:	fed518e3          	bne	a0,a3,80000dc6 <memcmp+0x14>
  }

  return 0;
    80000dda:	4501                	li	a0,0
    80000ddc:	a019                	j	80000de2 <memcmp+0x30>
      return *s1 - *s2;
    80000dde:	40e7853b          	subw	a0,a5,a4
}
    80000de2:	6422                	ld	s0,8(sp)
    80000de4:	0141                	addi	sp,sp,16
    80000de6:	8082                	ret
  return 0;
    80000de8:	4501                	li	a0,0
    80000dea:	bfe5                	j	80000de2 <memcmp+0x30>

0000000080000dec <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
    80000dec:	1141                	addi	sp,sp,-16
    80000dee:	e422                	sd	s0,8(sp)
    80000df0:	0800                	addi	s0,sp,16
  const char *s;
  char *d;

  if(n == 0)
    80000df2:	c205                	beqz	a2,80000e12 <memmove+0x26>
    return dst;
  
  s = src;
  d = dst;
  if(s < d && s + n > d){
    80000df4:	02a5e263          	bltu	a1,a0,80000e18 <memmove+0x2c>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
    80000df8:	1602                	slli	a2,a2,0x20
    80000dfa:	9201                	srli	a2,a2,0x20
    80000dfc:	00c587b3          	add	a5,a1,a2
{
    80000e00:	872a                	mv	a4,a0
      *d++ = *s++;
    80000e02:	0585                	addi	a1,a1,1
    80000e04:	0705                	addi	a4,a4,1 # fffffffffffff001 <end+0xffffffff7ffb5509>
    80000e06:	fff5c683          	lbu	a3,-1(a1)
    80000e0a:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
    80000e0e:	feb79ae3          	bne	a5,a1,80000e02 <memmove+0x16>

  return dst;
}
    80000e12:	6422                	ld	s0,8(sp)
    80000e14:	0141                	addi	sp,sp,16
    80000e16:	8082                	ret
  if(s < d && s + n > d){
    80000e18:	02061693          	slli	a3,a2,0x20
    80000e1c:	9281                	srli	a3,a3,0x20
    80000e1e:	00d58733          	add	a4,a1,a3
    80000e22:	fce57be3          	bgeu	a0,a4,80000df8 <memmove+0xc>
    d += n;
    80000e26:	96aa                	add	a3,a3,a0
    while(n-- > 0)
    80000e28:	fff6079b          	addiw	a5,a2,-1
    80000e2c:	1782                	slli	a5,a5,0x20
    80000e2e:	9381                	srli	a5,a5,0x20
    80000e30:	fff7c793          	not	a5,a5
    80000e34:	97ba                	add	a5,a5,a4
      *--d = *--s;
    80000e36:	177d                	addi	a4,a4,-1
    80000e38:	16fd                	addi	a3,a3,-1
    80000e3a:	00074603          	lbu	a2,0(a4)
    80000e3e:	00c68023          	sb	a2,0(a3)
    while(n-- > 0)
    80000e42:	fef71ae3          	bne	a4,a5,80000e36 <memmove+0x4a>
    80000e46:	b7f1                	j	80000e12 <memmove+0x26>

0000000080000e48 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
    80000e48:	1141                	addi	sp,sp,-16
    80000e4a:	e406                	sd	ra,8(sp)
    80000e4c:	e022                	sd	s0,0(sp)
    80000e4e:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    80000e50:	f9dff0ef          	jal	80000dec <memmove>
}
    80000e54:	60a2                	ld	ra,8(sp)
    80000e56:	6402                	ld	s0,0(sp)
    80000e58:	0141                	addi	sp,sp,16
    80000e5a:	8082                	ret

0000000080000e5c <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    80000e5c:	1141                	addi	sp,sp,-16
    80000e5e:	e422                	sd	s0,8(sp)
    80000e60:	0800                	addi	s0,sp,16
  while(n > 0 && *p && *p == *q)
    80000e62:	ce11                	beqz	a2,80000e7e <strncmp+0x22>
    80000e64:	00054783          	lbu	a5,0(a0)
    80000e68:	cf89                	beqz	a5,80000e82 <strncmp+0x26>
    80000e6a:	0005c703          	lbu	a4,0(a1)
    80000e6e:	00f71a63          	bne	a4,a5,80000e82 <strncmp+0x26>
    n--, p++, q++;
    80000e72:	367d                	addiw	a2,a2,-1
    80000e74:	0505                	addi	a0,a0,1
    80000e76:	0585                	addi	a1,a1,1
  while(n > 0 && *p && *p == *q)
    80000e78:	f675                	bnez	a2,80000e64 <strncmp+0x8>
  if(n == 0)
    return 0;
    80000e7a:	4501                	li	a0,0
    80000e7c:	a801                	j	80000e8c <strncmp+0x30>
    80000e7e:	4501                	li	a0,0
    80000e80:	a031                	j	80000e8c <strncmp+0x30>
  return (uchar)*p - (uchar)*q;
    80000e82:	00054503          	lbu	a0,0(a0)
    80000e86:	0005c783          	lbu	a5,0(a1)
    80000e8a:	9d1d                	subw	a0,a0,a5
}
    80000e8c:	6422                	ld	s0,8(sp)
    80000e8e:	0141                	addi	sp,sp,16
    80000e90:	8082                	ret

0000000080000e92 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    80000e92:	1141                	addi	sp,sp,-16
    80000e94:	e422                	sd	s0,8(sp)
    80000e96:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    80000e98:	87aa                	mv	a5,a0
    80000e9a:	86b2                	mv	a3,a2
    80000e9c:	367d                	addiw	a2,a2,-1
    80000e9e:	02d05563          	blez	a3,80000ec8 <strncpy+0x36>
    80000ea2:	0785                	addi	a5,a5,1
    80000ea4:	0005c703          	lbu	a4,0(a1)
    80000ea8:	fee78fa3          	sb	a4,-1(a5)
    80000eac:	0585                	addi	a1,a1,1
    80000eae:	f775                	bnez	a4,80000e9a <strncpy+0x8>
    ;
  while(n-- > 0)
    80000eb0:	873e                	mv	a4,a5
    80000eb2:	9fb5                	addw	a5,a5,a3
    80000eb4:	37fd                	addiw	a5,a5,-1
    80000eb6:	00c05963          	blez	a2,80000ec8 <strncpy+0x36>
    *s++ = 0;
    80000eba:	0705                	addi	a4,a4,1
    80000ebc:	fe070fa3          	sb	zero,-1(a4)
  while(n-- > 0)
    80000ec0:	40e786bb          	subw	a3,a5,a4
    80000ec4:	fed04be3          	bgtz	a3,80000eba <strncpy+0x28>
  return os;
}
    80000ec8:	6422                	ld	s0,8(sp)
    80000eca:	0141                	addi	sp,sp,16
    80000ecc:	8082                	ret

0000000080000ece <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
    80000ece:	1141                	addi	sp,sp,-16
    80000ed0:	e422                	sd	s0,8(sp)
    80000ed2:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  if(n <= 0)
    80000ed4:	02c05363          	blez	a2,80000efa <safestrcpy+0x2c>
    80000ed8:	fff6069b          	addiw	a3,a2,-1
    80000edc:	1682                	slli	a3,a3,0x20
    80000ede:	9281                	srli	a3,a3,0x20
    80000ee0:	96ae                	add	a3,a3,a1
    80000ee2:	87aa                	mv	a5,a0
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
    80000ee4:	00d58963          	beq	a1,a3,80000ef6 <safestrcpy+0x28>
    80000ee8:	0585                	addi	a1,a1,1
    80000eea:	0785                	addi	a5,a5,1
    80000eec:	fff5c703          	lbu	a4,-1(a1)
    80000ef0:	fee78fa3          	sb	a4,-1(a5)
    80000ef4:	fb65                	bnez	a4,80000ee4 <safestrcpy+0x16>
    ;
  *s = 0;
    80000ef6:	00078023          	sb	zero,0(a5)
  return os;
}
    80000efa:	6422                	ld	s0,8(sp)
    80000efc:	0141                	addi	sp,sp,16
    80000efe:	8082                	ret

0000000080000f00 <strlen>:

int
strlen(const char *s)
{
    80000f00:	1141                	addi	sp,sp,-16
    80000f02:	e422                	sd	s0,8(sp)
    80000f04:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    80000f06:	00054783          	lbu	a5,0(a0)
    80000f0a:	cf91                	beqz	a5,80000f26 <strlen+0x26>
    80000f0c:	0505                	addi	a0,a0,1
    80000f0e:	87aa                	mv	a5,a0
    80000f10:	86be                	mv	a3,a5
    80000f12:	0785                	addi	a5,a5,1
    80000f14:	fff7c703          	lbu	a4,-1(a5)
    80000f18:	ff65                	bnez	a4,80000f10 <strlen+0x10>
    80000f1a:	40a6853b          	subw	a0,a3,a0
    80000f1e:	2505                	addiw	a0,a0,1
    ;
  return n;
}
    80000f20:	6422                	ld	s0,8(sp)
    80000f22:	0141                	addi	sp,sp,16
    80000f24:	8082                	ret
  for(n = 0; s[n]; n++)
    80000f26:	4501                	li	a0,0
    80000f28:	bfe5                	j	80000f20 <strlen+0x20>

0000000080000f2a <main>:
volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    80000f2a:	1141                	addi	sp,sp,-16
    80000f2c:	e406                	sd	ra,8(sp)
    80000f2e:	e022                	sd	s0,0(sp)
    80000f30:	0800                	addi	s0,sp,16
  if(cpuid() == 0){
    80000f32:	475000ef          	jal	80001ba6 <cpuid>
    memlog_init();
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    80000f36:	0000a717          	auipc	a4,0xa
    80000f3a:	77a70713          	addi	a4,a4,1914 # 8000b6b0 <started>
  if(cpuid() == 0){
    80000f3e:	c51d                	beqz	a0,80000f6c <main+0x42>
    while(started == 0)
    80000f40:	431c                	lw	a5,0(a4)
    80000f42:	2781                	sext.w	a5,a5
    80000f44:	dff5                	beqz	a5,80000f40 <main+0x16>
      ;
    __sync_synchronize();
    80000f46:	0330000f          	fence	rw,rw
    printf("hart %d starting\n", cpuid());
    80000f4a:	45d000ef          	jal	80001ba6 <cpuid>
    80000f4e:	85aa                	mv	a1,a0
    80000f50:	00007517          	auipc	a0,0x7
    80000f54:	15050513          	addi	a0,a0,336 # 800080a0 <etext+0xa0>
    80000f58:	dd4ff0ef          	jal	8000052c <printf>
    kvminithart();    // turn on paging
    80000f5c:	08c000ef          	jal	80000fe8 <kvminithart>
    trapinithart();   // install kernel trap vector
    80000f60:	1b9010ef          	jal	80002918 <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000f64:	285040ef          	jal	800059e8 <plicinithart>
  }

  scheduler();        
    80000f68:	148010ef          	jal	800020b0 <scheduler>
    consoleinit();
    80000f6c:	cd6ff0ef          	jal	80000442 <consoleinit>
    printfinit();
    80000f70:	8dfff0ef          	jal	8000084e <printfinit>
    printf("\n");
    80000f74:	00007517          	auipc	a0,0x7
    80000f78:	10c50513          	addi	a0,a0,268 # 80008080 <etext+0x80>
    80000f7c:	db0ff0ef          	jal	8000052c <printf>
    printf("xv6 kernel is booting\n");
    80000f80:	00007517          	auipc	a0,0x7
    80000f84:	10850513          	addi	a0,a0,264 # 80008088 <etext+0x88>
    80000f88:	da4ff0ef          	jal	8000052c <printf>
    printf("\n");
    80000f8c:	00007517          	auipc	a0,0x7
    80000f90:	0f450513          	addi	a0,a0,244 # 80008080 <etext+0x80>
    80000f94:	d98ff0ef          	jal	8000052c <printf>
    kinit();         // physical page allocator
    80000f98:	bc3ff0ef          	jal	80000b5a <kinit>
    kvminit();       // create kernel page table
    80000f9c:	35c000ef          	jal	800012f8 <kvminit>
    kvminithart();   // turn on paging
    80000fa0:	048000ef          	jal	80000fe8 <kvminithart>
    procinit();      // process table
    80000fa4:	339000ef          	jal	80001adc <procinit>
    schedlog_init();
    80000fa8:	6ea050ef          	jal	80006692 <schedlog_init>
    trapinit();      // trap vectors
    80000fac:	149010ef          	jal	800028f4 <trapinit>
    trapinithart();  // install kernel trap vector
    80000fb0:	169010ef          	jal	80002918 <trapinithart>
    plicinit();      // set up interrupt controller
    80000fb4:	21b040ef          	jal	800059ce <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000fb8:	231040ef          	jal	800059e8 <plicinithart>
    binit();         // buffer cache
    80000fbc:	086020ef          	jal	80003042 <binit>
    iinit();         // inode table
    80000fc0:	64a020ef          	jal	8000360a <iinit>
    fileinit();      // file table
    80000fc4:	53c030ef          	jal	80004500 <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000fc8:	311040ef          	jal	80005ad8 <virtio_disk_init>
    cslog_init();
    80000fcc:	7bf040ef          	jal	80005f8a <cslog_init>
    memlog_init();
    80000fd0:	43e050ef          	jal	8000640e <memlog_init>
    userinit();      // first user process
    80000fd4:	6c5000ef          	jal	80001e98 <userinit>
    __sync_synchronize();
    80000fd8:	0330000f          	fence	rw,rw
    started = 1;
    80000fdc:	4785                	li	a5,1
    80000fde:	0000a717          	auipc	a4,0xa
    80000fe2:	6cf72923          	sw	a5,1746(a4) # 8000b6b0 <started>
    80000fe6:	b749                	j	80000f68 <main+0x3e>

0000000080000fe8 <kvminithart>:

// Switch the current CPU's h/w page table register to
// the kernel's page table, and enable paging.
void
kvminithart()
{
    80000fe8:	1141                	addi	sp,sp,-16
    80000fea:	e422                	sd	s0,8(sp)
    80000fec:	0800                	addi	s0,sp,16
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero");
    80000fee:	12000073          	sfence.vma
  // wait for any previous writes to the page table memory to finish.
  sfence_vma();

  w_satp(MAKE_SATP(kernel_pagetable));
    80000ff2:	0000a797          	auipc	a5,0xa
    80000ff6:	6c67b783          	ld	a5,1734(a5) # 8000b6b8 <kernel_pagetable>
    80000ffa:	83b1                	srli	a5,a5,0xc
    80000ffc:	577d                	li	a4,-1
    80000ffe:	177e                	slli	a4,a4,0x3f
    80001000:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r" (x));
    80001002:	18079073          	csrw	satp,a5
  asm volatile("sfence.vma zero, zero");
    80001006:	12000073          	sfence.vma

  // flush stale entries from the TLB.
  sfence_vma();
}
    8000100a:	6422                	ld	s0,8(sp)
    8000100c:	0141                	addi	sp,sp,16
    8000100e:	8082                	ret

0000000080001010 <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    80001010:	7139                	addi	sp,sp,-64
    80001012:	fc06                	sd	ra,56(sp)
    80001014:	f822                	sd	s0,48(sp)
    80001016:	f426                	sd	s1,40(sp)
    80001018:	f04a                	sd	s2,32(sp)
    8000101a:	ec4e                	sd	s3,24(sp)
    8000101c:	e852                	sd	s4,16(sp)
    8000101e:	e456                	sd	s5,8(sp)
    80001020:	e05a                	sd	s6,0(sp)
    80001022:	0080                	addi	s0,sp,64
    80001024:	84aa                	mv	s1,a0
    80001026:	89ae                	mv	s3,a1
    80001028:	8ab2                	mv	s5,a2
  if(va >= MAXVA)
    8000102a:	57fd                	li	a5,-1
    8000102c:	83e9                	srli	a5,a5,0x1a
    8000102e:	4a79                	li	s4,30
    panic("walk");

  for(int level = 2; level > 0; level--) {
    80001030:	4b31                	li	s6,12
  if(va >= MAXVA)
    80001032:	02b7fc63          	bgeu	a5,a1,8000106a <walk+0x5a>
    panic("walk");
    80001036:	00007517          	auipc	a0,0x7
    8000103a:	08250513          	addi	a0,a0,130 # 800080b8 <etext+0xb8>
    8000103e:	fd4ff0ef          	jal	80000812 <panic>
    pte_t *pte = &pagetable[PX(level, va)];
    if(*pte & PTE_V) {
      pagetable = (pagetable_t)PTE2PA(*pte);
    } else {
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    80001042:	060a8263          	beqz	s5,800010a6 <walk+0x96>
    80001046:	b49ff0ef          	jal	80000b8e <kalloc>
    8000104a:	84aa                	mv	s1,a0
    8000104c:	c139                	beqz	a0,80001092 <walk+0x82>
        return 0;
      memset(pagetable, 0, PGSIZE);
    8000104e:	6605                	lui	a2,0x1
    80001050:	4581                	li	a1,0
    80001052:	d3fff0ef          	jal	80000d90 <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    80001056:	00c4d793          	srli	a5,s1,0xc
    8000105a:	07aa                	slli	a5,a5,0xa
    8000105c:	0017e793          	ori	a5,a5,1
    80001060:	00f93023          	sd	a5,0(s2)
  for(int level = 2; level > 0; level--) {
    80001064:	3a5d                	addiw	s4,s4,-9 # ffffffffffffeff7 <end+0xffffffff7ffb54ff>
    80001066:	036a0063          	beq	s4,s6,80001086 <walk+0x76>
    pte_t *pte = &pagetable[PX(level, va)];
    8000106a:	0149d933          	srl	s2,s3,s4
    8000106e:	1ff97913          	andi	s2,s2,511
    80001072:	090e                	slli	s2,s2,0x3
    80001074:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) {
    80001076:	00093483          	ld	s1,0(s2)
    8000107a:	0014f793          	andi	a5,s1,1
    8000107e:	d3f1                	beqz	a5,80001042 <walk+0x32>
      pagetable = (pagetable_t)PTE2PA(*pte);
    80001080:	80a9                	srli	s1,s1,0xa
    80001082:	04b2                	slli	s1,s1,0xc
    80001084:	b7c5                	j	80001064 <walk+0x54>
    }
  }
  return &pagetable[PX(0, va)];
    80001086:	00c9d513          	srli	a0,s3,0xc
    8000108a:	1ff57513          	andi	a0,a0,511
    8000108e:	050e                	slli	a0,a0,0x3
    80001090:	9526                	add	a0,a0,s1
}
    80001092:	70e2                	ld	ra,56(sp)
    80001094:	7442                	ld	s0,48(sp)
    80001096:	74a2                	ld	s1,40(sp)
    80001098:	7902                	ld	s2,32(sp)
    8000109a:	69e2                	ld	s3,24(sp)
    8000109c:	6a42                	ld	s4,16(sp)
    8000109e:	6aa2                	ld	s5,8(sp)
    800010a0:	6b02                	ld	s6,0(sp)
    800010a2:	6121                	addi	sp,sp,64
    800010a4:	8082                	ret
        return 0;
    800010a6:	4501                	li	a0,0
    800010a8:	b7ed                	j	80001092 <walk+0x82>

00000000800010aa <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if(va >= MAXVA)
    800010aa:	57fd                	li	a5,-1
    800010ac:	83e9                	srli	a5,a5,0x1a
    800010ae:	00b7f463          	bgeu	a5,a1,800010b6 <walkaddr+0xc>
    return 0;
    800010b2:	4501                	li	a0,0
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}
    800010b4:	8082                	ret
{
    800010b6:	1141                	addi	sp,sp,-16
    800010b8:	e406                	sd	ra,8(sp)
    800010ba:	e022                	sd	s0,0(sp)
    800010bc:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    800010be:	4601                	li	a2,0
    800010c0:	f51ff0ef          	jal	80001010 <walk>
  if(pte == 0)
    800010c4:	c105                	beqz	a0,800010e4 <walkaddr+0x3a>
  if((*pte & PTE_V) == 0)
    800010c6:	611c                	ld	a5,0(a0)
  if((*pte & PTE_U) == 0)
    800010c8:	0117f693          	andi	a3,a5,17
    800010cc:	4745                	li	a4,17
    return 0;
    800010ce:	4501                	li	a0,0
  if((*pte & PTE_U) == 0)
    800010d0:	00e68663          	beq	a3,a4,800010dc <walkaddr+0x32>
}
    800010d4:	60a2                	ld	ra,8(sp)
    800010d6:	6402                	ld	s0,0(sp)
    800010d8:	0141                	addi	sp,sp,16
    800010da:	8082                	ret
  pa = PTE2PA(*pte);
    800010dc:	83a9                	srli	a5,a5,0xa
    800010de:	00c79513          	slli	a0,a5,0xc
  return pa;
    800010e2:	bfcd                	j	800010d4 <walkaddr+0x2a>
    return 0;
    800010e4:	4501                	li	a0,0
    800010e6:	b7fd                	j	800010d4 <walkaddr+0x2a>

00000000800010e8 <mappages>:
// va and size MUST be page-aligned.
// Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    800010e8:	7115                	addi	sp,sp,-224
    800010ea:	ed86                	sd	ra,216(sp)
    800010ec:	e9a2                	sd	s0,208(sp)
    800010ee:	e5a6                	sd	s1,200(sp)
    800010f0:	e1ca                	sd	s2,192(sp)
    800010f2:	fd4e                	sd	s3,184(sp)
    800010f4:	f952                	sd	s4,176(sp)
    800010f6:	f556                	sd	s5,168(sp)
    800010f8:	f15a                	sd	s6,160(sp)
    800010fa:	ed5e                	sd	s7,152(sp)
    800010fc:	e962                	sd	s8,144(sp)
    800010fe:	e566                	sd	s9,136(sp)
    80001100:	e16a                	sd	s10,128(sp)
    80001102:	fcee                	sd	s11,120(sp)
    80001104:	1180                	addi	s0,sp,224
  uint64 a, last;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    80001106:	03459793          	slli	a5,a1,0x34
    8000110a:	e795                	bnez	a5,80001136 <mappages+0x4e>
    8000110c:	8b2a                	mv	s6,a0
    8000110e:	89ba                	mv	s3,a4
    panic("mappages: va not aligned");

  if((size % PGSIZE) != 0)
    80001110:	03461793          	slli	a5,a2,0x34
    80001114:	e79d                	bnez	a5,80001142 <mappages+0x5a>
    panic("mappages: size not aligned");

  if(size == 0)
    80001116:	ce05                	beqz	a2,8000114e <mappages+0x66>
    panic("mappages: size");
  
  a = va;
  last = va + size - PGSIZE;
    80001118:	77fd                	lui	a5,0xfffff
    8000111a:	963e                	add	a2,a2,a5
    8000111c:	00b60a33          	add	s4,a2,a1
  a = va;
    80001120:	84ae                	mv	s1,a1
    80001122:	40b68ab3          	sub	s5,a3,a1

    struct proc *p = myproc();
    if(p){
      struct mem_event e;
      memset(&e, 0, sizeof(e));
      e.ticks  = ticks;
    80001126:	0000ad17          	auipc	s10,0xa
    8000112a:	5aad0d13          	addi	s10,s10,1450 # 8000b6d0 <ticks>
      e.cpu    = cpuid();
      e.type   = MEM_MAP;
    8000112e:	4c91                	li	s9,4
      e.pid    = p->pid;
      e.state  = p->state;
      e.va     = a;
      e.pa     = pa;
      e.perm   = perm;
      e.source = SRC_MAPPAGES;
    80001130:	4c0d                	li	s8,3
      memlog_push(&e);
    }

    if(a == last)
      break;
    a += PGSIZE;
    80001132:	6b85                	lui	s7,0x1
    80001134:	a859                	j	800011ca <mappages+0xe2>
    panic("mappages: va not aligned");
    80001136:	00007517          	auipc	a0,0x7
    8000113a:	f8a50513          	addi	a0,a0,-118 # 800080c0 <etext+0xc0>
    8000113e:	ed4ff0ef          	jal	80000812 <panic>
    panic("mappages: size not aligned");
    80001142:	00007517          	auipc	a0,0x7
    80001146:	f9e50513          	addi	a0,a0,-98 # 800080e0 <etext+0xe0>
    8000114a:	ec8ff0ef          	jal	80000812 <panic>
    panic("mappages: size");
    8000114e:	00007517          	auipc	a0,0x7
    80001152:	fb250513          	addi	a0,a0,-78 # 80008100 <etext+0x100>
    80001156:	ebcff0ef          	jal	80000812 <panic>
      panic("mappages: remap");
    8000115a:	00007517          	auipc	a0,0x7
    8000115e:	fb650513          	addi	a0,a0,-74 # 80008110 <etext+0x110>
    80001162:	eb0ff0ef          	jal	80000812 <panic>
      memset(&e, 0, sizeof(e));
    80001166:	06800613          	li	a2,104
    8000116a:	4581                	li	a1,0
    8000116c:	f2840513          	addi	a0,s0,-216
    80001170:	c21ff0ef          	jal	80000d90 <memset>
      e.ticks  = ticks;
    80001174:	000d2783          	lw	a5,0(s10)
    80001178:	f2f42823          	sw	a5,-208(s0)
      e.cpu    = cpuid();
    8000117c:	22b000ef          	jal	80001ba6 <cpuid>
    80001180:	f2a42a23          	sw	a0,-204(s0)
      e.type   = MEM_MAP;
    80001184:	f3942c23          	sw	s9,-200(s0)
      e.pid    = p->pid;
    80001188:	030da783          	lw	a5,48(s11)
    8000118c:	f2f42e23          	sw	a5,-196(s0)
      e.state  = p->state;
    80001190:	018da783          	lw	a5,24(s11)
    80001194:	f4f42023          	sw	a5,-192(s0)
      e.va     = a;
    80001198:	f4943c23          	sd	s1,-168(s0)
      e.pa     = pa;
    8000119c:	f7243023          	sd	s2,-160(s0)
      e.perm   = perm;
    800011a0:	f9342023          	sw	s3,-128(s0)
      e.source = SRC_MAPPAGES;
    800011a4:	f9842223          	sw	s8,-124(s0)
      e.kind   = PAGE_USER;
    800011a8:	4785                	li	a5,1
    800011aa:	f8f42423          	sw	a5,-120(s0)
      safestrcpy(e.name, p->name, MEM_NM);
    800011ae:	4641                	li	a2,16
    800011b0:	158d8593          	addi	a1,s11,344
    800011b4:	f4440513          	addi	a0,s0,-188
    800011b8:	d17ff0ef          	jal	80000ece <safestrcpy>
      memlog_push(&e);
    800011bc:	f2840513          	addi	a0,s0,-216
    800011c0:	292050ef          	jal	80006452 <memlog_push>
    if(a == last)
    800011c4:	05448b63          	beq	s1,s4,8000121a <mappages+0x132>
    a += PGSIZE;
    800011c8:	94de                	add	s1,s1,s7
  for(;;){
    800011ca:	01548933          	add	s2,s1,s5
       if((pte = walk(pagetable, a, 1)) == 0)
    800011ce:	4605                	li	a2,1
    800011d0:	85a6                	mv	a1,s1
    800011d2:	855a                	mv	a0,s6
    800011d4:	e3dff0ef          	jal	80001010 <walk>
    800011d8:	c10d                	beqz	a0,800011fa <mappages+0x112>
    if(*pte & PTE_V)
    800011da:	611c                	ld	a5,0(a0)
    800011dc:	8b85                	andi	a5,a5,1
    800011de:	ffb5                	bnez	a5,8000115a <mappages+0x72>
    *pte = PA2PTE(pa) | perm | PTE_V;
    800011e0:	00c95793          	srli	a5,s2,0xc
    800011e4:	07aa                	slli	a5,a5,0xa
    800011e6:	0137e7b3          	or	a5,a5,s3
    800011ea:	0017e793          	ori	a5,a5,1
    800011ee:	e11c                	sd	a5,0(a0)
    struct proc *p = myproc();
    800011f0:	1e3000ef          	jal	80001bd2 <myproc>
    800011f4:	8daa                	mv	s11,a0
    if(p){
    800011f6:	f925                	bnez	a0,80001166 <mappages+0x7e>
    800011f8:	b7f1                	j	800011c4 <mappages+0xdc>
      return -1;
    800011fa:	557d                	li	a0,-1
    pa += PGSIZE;
  }
  return 0;
}
    800011fc:	60ee                	ld	ra,216(sp)
    800011fe:	644e                	ld	s0,208(sp)
    80001200:	64ae                	ld	s1,200(sp)
    80001202:	690e                	ld	s2,192(sp)
    80001204:	79ea                	ld	s3,184(sp)
    80001206:	7a4a                	ld	s4,176(sp)
    80001208:	7aaa                	ld	s5,168(sp)
    8000120a:	7b0a                	ld	s6,160(sp)
    8000120c:	6bea                	ld	s7,152(sp)
    8000120e:	6c4a                	ld	s8,144(sp)
    80001210:	6caa                	ld	s9,136(sp)
    80001212:	6d0a                	ld	s10,128(sp)
    80001214:	7de6                	ld	s11,120(sp)
    80001216:	612d                	addi	sp,sp,224
    80001218:	8082                	ret
  return 0;
    8000121a:	4501                	li	a0,0
    8000121c:	b7c5                	j	800011fc <mappages+0x114>

000000008000121e <kvmmap>:
{
    8000121e:	1141                	addi	sp,sp,-16
    80001220:	e406                	sd	ra,8(sp)
    80001222:	e022                	sd	s0,0(sp)
    80001224:	0800                	addi	s0,sp,16
    80001226:	87b6                	mv	a5,a3
  if(mappages(kpgtbl, va, sz, pa, perm) != 0)
    80001228:	86b2                	mv	a3,a2
    8000122a:	863e                	mv	a2,a5
    8000122c:	ebdff0ef          	jal	800010e8 <mappages>
    80001230:	e509                	bnez	a0,8000123a <kvmmap+0x1c>
}
    80001232:	60a2                	ld	ra,8(sp)
    80001234:	6402                	ld	s0,0(sp)
    80001236:	0141                	addi	sp,sp,16
    80001238:	8082                	ret
    panic("kvmmap");
    8000123a:	00007517          	auipc	a0,0x7
    8000123e:	ee650513          	addi	a0,a0,-282 # 80008120 <etext+0x120>
    80001242:	dd0ff0ef          	jal	80000812 <panic>

0000000080001246 <kvmmake>:
{
    80001246:	1101                	addi	sp,sp,-32
    80001248:	ec06                	sd	ra,24(sp)
    8000124a:	e822                	sd	s0,16(sp)
    8000124c:	e426                	sd	s1,8(sp)
    8000124e:	e04a                	sd	s2,0(sp)
    80001250:	1000                	addi	s0,sp,32
  kpgtbl = (pagetable_t) kalloc();
    80001252:	93dff0ef          	jal	80000b8e <kalloc>
    80001256:	84aa                	mv	s1,a0
  memset(kpgtbl, 0, PGSIZE);
    80001258:	6605                	lui	a2,0x1
    8000125a:	4581                	li	a1,0
    8000125c:	b35ff0ef          	jal	80000d90 <memset>
  kvmmap(kpgtbl, UART0, UART0, PGSIZE, PTE_R | PTE_W);
    80001260:	4719                	li	a4,6
    80001262:	6685                	lui	a3,0x1
    80001264:	10000637          	lui	a2,0x10000
    80001268:	100005b7          	lui	a1,0x10000
    8000126c:	8526                	mv	a0,s1
    8000126e:	fb1ff0ef          	jal	8000121e <kvmmap>
  kvmmap(kpgtbl, VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    80001272:	4719                	li	a4,6
    80001274:	6685                	lui	a3,0x1
    80001276:	10001637          	lui	a2,0x10001
    8000127a:	100015b7          	lui	a1,0x10001
    8000127e:	8526                	mv	a0,s1
    80001280:	f9fff0ef          	jal	8000121e <kvmmap>
  kvmmap(kpgtbl, PLIC, PLIC, 0x4000000, PTE_R | PTE_W);
    80001284:	4719                	li	a4,6
    80001286:	040006b7          	lui	a3,0x4000
    8000128a:	0c000637          	lui	a2,0xc000
    8000128e:	0c0005b7          	lui	a1,0xc000
    80001292:	8526                	mv	a0,s1
    80001294:	f8bff0ef          	jal	8000121e <kvmmap>
  kvmmap(kpgtbl, KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    80001298:	00007917          	auipc	s2,0x7
    8000129c:	d6890913          	addi	s2,s2,-664 # 80008000 <etext>
    800012a0:	4729                	li	a4,10
    800012a2:	80007697          	auipc	a3,0x80007
    800012a6:	d5e68693          	addi	a3,a3,-674 # 8000 <_entry-0x7fff8000>
    800012aa:	4605                	li	a2,1
    800012ac:	067e                	slli	a2,a2,0x1f
    800012ae:	85b2                	mv	a1,a2
    800012b0:	8526                	mv	a0,s1
    800012b2:	f6dff0ef          	jal	8000121e <kvmmap>
  kvmmap(kpgtbl, (uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    800012b6:	46c5                	li	a3,17
    800012b8:	06ee                	slli	a3,a3,0x1b
    800012ba:	4719                	li	a4,6
    800012bc:	412686b3          	sub	a3,a3,s2
    800012c0:	864a                	mv	a2,s2
    800012c2:	85ca                	mv	a1,s2
    800012c4:	8526                	mv	a0,s1
    800012c6:	f59ff0ef          	jal	8000121e <kvmmap>
  kvmmap(kpgtbl, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    800012ca:	4729                	li	a4,10
    800012cc:	6685                	lui	a3,0x1
    800012ce:	00006617          	auipc	a2,0x6
    800012d2:	d3260613          	addi	a2,a2,-718 # 80007000 <_trampoline>
    800012d6:	040005b7          	lui	a1,0x4000
    800012da:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    800012dc:	05b2                	slli	a1,a1,0xc
    800012de:	8526                	mv	a0,s1
    800012e0:	f3fff0ef          	jal	8000121e <kvmmap>
  proc_mapstacks(kpgtbl);
    800012e4:	8526                	mv	a0,s1
    800012e6:	75e000ef          	jal	80001a44 <proc_mapstacks>
}
    800012ea:	8526                	mv	a0,s1
    800012ec:	60e2                	ld	ra,24(sp)
    800012ee:	6442                	ld	s0,16(sp)
    800012f0:	64a2                	ld	s1,8(sp)
    800012f2:	6902                	ld	s2,0(sp)
    800012f4:	6105                	addi	sp,sp,32
    800012f6:	8082                	ret

00000000800012f8 <kvminit>:
{
    800012f8:	1141                	addi	sp,sp,-16
    800012fa:	e406                	sd	ra,8(sp)
    800012fc:	e022                	sd	s0,0(sp)
    800012fe:	0800                	addi	s0,sp,16
  kernel_pagetable = kvmmake();
    80001300:	f47ff0ef          	jal	80001246 <kvmmake>
    80001304:	0000a797          	auipc	a5,0xa
    80001308:	3aa7ba23          	sd	a0,948(a5) # 8000b6b8 <kernel_pagetable>
}
    8000130c:	60a2                	ld	ra,8(sp)
    8000130e:	6402                	ld	s0,0(sp)
    80001310:	0141                	addi	sp,sp,16
    80001312:	8082                	ret

0000000080001314 <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    80001314:	1101                	addi	sp,sp,-32
    80001316:	ec06                	sd	ra,24(sp)
    80001318:	e822                	sd	s0,16(sp)
    8000131a:	e426                	sd	s1,8(sp)
    8000131c:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t) kalloc();
    8000131e:	871ff0ef          	jal	80000b8e <kalloc>
    80001322:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001324:	c509                	beqz	a0,8000132e <uvmcreate+0x1a>
    return 0;
  memset(pagetable, 0, PGSIZE);
    80001326:	6605                	lui	a2,0x1
    80001328:	4581                	li	a1,0
    8000132a:	a67ff0ef          	jal	80000d90 <memset>
  return pagetable;
}
    8000132e:	8526                	mv	a0,s1
    80001330:	60e2                	ld	ra,24(sp)
    80001332:	6442                	ld	s0,16(sp)
    80001334:	64a2                	ld	s1,8(sp)
    80001336:	6105                	addi	sp,sp,32
    80001338:	8082                	ret

000000008000133a <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. It's OK if the mappings don't exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    8000133a:	7115                	addi	sp,sp,-224
    8000133c:	ed86                	sd	ra,216(sp)
    8000133e:	e9a2                	sd	s0,208(sp)
    80001340:	1180                	addi	s0,sp,224
  uint64 a;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    80001342:	03459793          	slli	a5,a1,0x34
    80001346:	ef85                	bnez	a5,8000137e <uvmunmap+0x44>
    80001348:	e1ca                	sd	s2,192(sp)
    8000134a:	f556                	sd	s5,168(sp)
    8000134c:	f15a                	sd	s6,160(sp)
    8000134e:	e962                	sd	s8,144(sp)
    80001350:	8b2a                	mv	s6,a0
    80001352:	892e                	mv	s2,a1
    80001354:	8c36                	mv	s8,a3
    panic("uvmunmap: not aligned");

  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80001356:	0632                	slli	a2,a2,0xc
    80001358:	00b60ab3          	add	s5,a2,a1
    8000135c:	0f55f763          	bgeu	a1,s5,8000144a <uvmunmap+0x110>
    80001360:	e5a6                	sd	s1,200(sp)
    80001362:	fd4e                	sd	s3,184(sp)
    80001364:	f952                	sd	s4,176(sp)
    80001366:	ed5e                	sd	s7,152(sp)
    80001368:	e566                	sd	s9,136(sp)
    8000136a:	e16a                	sd	s10,128(sp)
    8000136c:	fcee                	sd	s11,120(sp)

    struct proc *p = myproc();
    if(p){
      struct mem_event e;
      memset(&e, 0, sizeof(e));
      e.ticks  = ticks;
    8000136e:	0000ad97          	auipc	s11,0xa
    80001372:	362d8d93          	addi	s11,s11,866 # 8000b6d0 <ticks>
      e.cpu    = cpuid();
      e.type   = MEM_UNMAP;
    80001376:	4d15                	li	s10,5
      e.pid    = p->pid;
      e.state  = p->state;
      e.va     = a;
      e.pa     = pa;
      e.len    = PGSIZE;
    80001378:	6b85                	lui	s7,0x1
      e.source = SRC_UVMUNMAP;
    8000137a:	4c91                	li	s9,4
    8000137c:	a80d                	j	800013ae <uvmunmap+0x74>
    8000137e:	e5a6                	sd	s1,200(sp)
    80001380:	e1ca                	sd	s2,192(sp)
    80001382:	fd4e                	sd	s3,184(sp)
    80001384:	f952                	sd	s4,176(sp)
    80001386:	f556                	sd	s5,168(sp)
    80001388:	f15a                	sd	s6,160(sp)
    8000138a:	ed5e                	sd	s7,152(sp)
    8000138c:	e962                	sd	s8,144(sp)
    8000138e:	e566                	sd	s9,136(sp)
    80001390:	e16a                	sd	s10,128(sp)
    80001392:	fcee                	sd	s11,120(sp)
    panic("uvmunmap: not aligned");
    80001394:	00007517          	auipc	a0,0x7
    80001398:	d9450513          	addi	a0,a0,-620 # 80008128 <etext+0x128>
    8000139c:	c76ff0ef          	jal	80000812 <panic>
      e.kind   = PAGE_USER;
      safestrcpy(e.name, p->name, MEM_NM);
      memlog_push(&e);
    }

    if(do_free){
    800013a0:	080c1a63          	bnez	s8,80001434 <uvmunmap+0xfa>
      kfree((void*)pa);
    }
    *pte = 0;
    800013a4:	0004b023          	sd	zero,0(s1)
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800013a8:	995e                	add	s2,s2,s7
    800013aa:	09597963          	bgeu	s2,s5,8000143c <uvmunmap+0x102>
    if((pte = walk(pagetable, a, 0)) == 0)
    800013ae:	4601                	li	a2,0
    800013b0:	85ca                	mv	a1,s2
    800013b2:	855a                	mv	a0,s6
    800013b4:	c5dff0ef          	jal	80001010 <walk>
    800013b8:	84aa                	mv	s1,a0
    800013ba:	d57d                	beqz	a0,800013a8 <uvmunmap+0x6e>
    if((*pte & PTE_V) == 0)
    800013bc:	00053983          	ld	s3,0(a0)
    800013c0:	0019f793          	andi	a5,s3,1
    800013c4:	d3f5                	beqz	a5,800013a8 <uvmunmap+0x6e>
    uint64 pa = PTE2PA(*pte);
    800013c6:	00a9d993          	srli	s3,s3,0xa
    800013ca:	09b2                	slli	s3,s3,0xc
    struct proc *p = myproc();
    800013cc:	007000ef          	jal	80001bd2 <myproc>
    800013d0:	8a2a                	mv	s4,a0
    if(p){
    800013d2:	d579                	beqz	a0,800013a0 <uvmunmap+0x66>
      memset(&e, 0, sizeof(e));
    800013d4:	06800613          	li	a2,104
    800013d8:	4581                	li	a1,0
    800013da:	f2840513          	addi	a0,s0,-216
    800013de:	9b3ff0ef          	jal	80000d90 <memset>
      e.ticks  = ticks;
    800013e2:	000da783          	lw	a5,0(s11)
    800013e6:	f2f42823          	sw	a5,-208(s0)
      e.cpu    = cpuid();
    800013ea:	7bc000ef          	jal	80001ba6 <cpuid>
    800013ee:	f2a42a23          	sw	a0,-204(s0)
      e.type   = MEM_UNMAP;
    800013f2:	f3a42c23          	sw	s10,-200(s0)
      e.pid    = p->pid;
    800013f6:	030a2783          	lw	a5,48(s4)
    800013fa:	f2f42e23          	sw	a5,-196(s0)
      e.state  = p->state;
    800013fe:	018a2783          	lw	a5,24(s4)
    80001402:	f4f42023          	sw	a5,-192(s0)
      e.va     = a;
    80001406:	f5243c23          	sd	s2,-168(s0)
      e.pa     = pa;
    8000140a:	f7343023          	sd	s3,-160(s0)
      e.len    = PGSIZE;
    8000140e:	f7743c23          	sd	s7,-136(s0)
      e.source = SRC_UVMUNMAP;
    80001412:	f9942223          	sw	s9,-124(s0)
      e.kind   = PAGE_USER;
    80001416:	4785                	li	a5,1
    80001418:	f8f42423          	sw	a5,-120(s0)
      safestrcpy(e.name, p->name, MEM_NM);
    8000141c:	4641                	li	a2,16
    8000141e:	158a0593          	addi	a1,s4,344
    80001422:	f4440513          	addi	a0,s0,-188
    80001426:	aa9ff0ef          	jal	80000ece <safestrcpy>
      memlog_push(&e);
    8000142a:	f2840513          	addi	a0,s0,-216
    8000142e:	024050ef          	jal	80006452 <memlog_push>
    80001432:	b7bd                	j	800013a0 <uvmunmap+0x66>
      kfree((void*)pa);
    80001434:	854e                	mv	a0,s3
    80001436:	e18ff0ef          	jal	80000a4e <kfree>
    8000143a:	b7ad                	j	800013a4 <uvmunmap+0x6a>
    8000143c:	64ae                	ld	s1,200(sp)
    8000143e:	79ea                	ld	s3,184(sp)
    80001440:	7a4a                	ld	s4,176(sp)
    80001442:	6bea                	ld	s7,152(sp)
    80001444:	6caa                	ld	s9,136(sp)
    80001446:	6d0a                	ld	s10,128(sp)
    80001448:	7de6                	ld	s11,120(sp)
    8000144a:	690e                	ld	s2,192(sp)
    8000144c:	7aaa                	ld	s5,168(sp)
    8000144e:	7b0a                	ld	s6,160(sp)
    80001450:	6c4a                	ld	s8,144(sp)
  }
}
    80001452:	60ee                	ld	ra,216(sp)
    80001454:	644e                	ld	s0,208(sp)
    80001456:	612d                	addi	sp,sp,224
    80001458:	8082                	ret

000000008000145a <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    8000145a:	1101                	addi	sp,sp,-32
    8000145c:	ec06                	sd	ra,24(sp)
    8000145e:	e822                	sd	s0,16(sp)
    80001460:	e426                	sd	s1,8(sp)
    80001462:	1000                	addi	s0,sp,32
  if(newsz >= oldsz)
    return oldsz;
    80001464:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    80001466:	00b67d63          	bgeu	a2,a1,80001480 <uvmdealloc+0x26>
    8000146a:	84b2                	mv	s1,a2

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    8000146c:	6785                	lui	a5,0x1
    8000146e:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80001470:	00f60733          	add	a4,a2,a5
    80001474:	76fd                	lui	a3,0xfffff
    80001476:	8f75                	and	a4,a4,a3
    80001478:	97ae                	add	a5,a5,a1
    8000147a:	8ff5                	and	a5,a5,a3
    8000147c:	00f76863          	bltu	a4,a5,8000148c <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    80001480:	8526                	mv	a0,s1
    80001482:	60e2                	ld	ra,24(sp)
    80001484:	6442                	ld	s0,16(sp)
    80001486:	64a2                	ld	s1,8(sp)
    80001488:	6105                	addi	sp,sp,32
    8000148a:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    8000148c:	8f99                	sub	a5,a5,a4
    8000148e:	83b1                	srli	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    80001490:	4685                	li	a3,1
    80001492:	0007861b          	sext.w	a2,a5
    80001496:	85ba                	mv	a1,a4
    80001498:	ea3ff0ef          	jal	8000133a <uvmunmap>
    8000149c:	b7d5                	j	80001480 <uvmdealloc+0x26>

000000008000149e <uvmalloc>:
{
    8000149e:	7171                	addi	sp,sp,-176
    800014a0:	f506                	sd	ra,168(sp)
    800014a2:	f122                	sd	s0,160(sp)
    800014a4:	ed26                	sd	s1,152(sp)
    800014a6:	1900                	addi	s0,sp,176
    800014a8:	84ae                	mv	s1,a1
  if(newsz < oldsz)
    800014aa:	00b67863          	bgeu	a2,a1,800014ba <uvmalloc+0x1c>
}
    800014ae:	8526                	mv	a0,s1
    800014b0:	70aa                	ld	ra,168(sp)
    800014b2:	740a                	ld	s0,160(sp)
    800014b4:	64ea                	ld	s1,152(sp)
    800014b6:	614d                	addi	sp,sp,176
    800014b8:	8082                	ret
    800014ba:	e94a                	sd	s2,144(sp)
    800014bc:	e54e                	sd	s3,136(sp)
    800014be:	e152                	sd	s4,128(sp)
    800014c0:	fcd6                	sd	s5,120(sp)
    800014c2:	f8da                	sd	s6,112(sp)
    800014c4:	8aaa                	mv	s5,a0
    800014c6:	89b2                	mv	s3,a2
    800014c8:	8a36                	mv	s4,a3
      struct proc *p = myproc();
    800014ca:	708000ef          	jal	80001bd2 <myproc>
    800014ce:	892a                	mv	s2,a0
  if(p){
    800014d0:	c12d                	beqz	a0,80001532 <uvmalloc+0x94>
    memset(&e, 0, sizeof(e));
    800014d2:	06800613          	li	a2,104
    800014d6:	4581                	li	a1,0
    800014d8:	f5840513          	addi	a0,s0,-168
    800014dc:	8b5ff0ef          	jal	80000d90 <memset>
    e.ticks  = ticks;
    800014e0:	0000a797          	auipc	a5,0xa
    800014e4:	1f07a783          	lw	a5,496(a5) # 8000b6d0 <ticks>
    800014e8:	f6f42023          	sw	a5,-160(s0)
    e.cpu    = cpuid();
    800014ec:	6ba000ef          	jal	80001ba6 <cpuid>
    800014f0:	f6a42223          	sw	a0,-156(s0)
    e.type   = MEM_GROW;
    800014f4:	4785                	li	a5,1
    800014f6:	f6f42423          	sw	a5,-152(s0)
    e.pid    = p->pid;
    800014fa:	03092703          	lw	a4,48(s2)
    800014fe:	f6e42623          	sw	a4,-148(s0)
    e.state  = p->state;
    80001502:	01892703          	lw	a4,24(s2)
    80001506:	f6e42823          	sw	a4,-144(s0)
    e.oldsz  = oldsz;
    8000150a:	f8943c23          	sd	s1,-104(s0)
    e.newsz  = newsz;
    8000150e:	fb343023          	sd	s3,-96(s0)
    e.source = SRC_UVMALLOC;
    80001512:	4715                	li	a4,5
    80001514:	fae42a23          	sw	a4,-76(s0)
    e.kind   = PAGE_USER;
    80001518:	faf42c23          	sw	a5,-72(s0)
    safestrcpy(e.name, p->name, MEM_NM);
    8000151c:	4641                	li	a2,16
    8000151e:	15890593          	addi	a1,s2,344
    80001522:	f7440513          	addi	a0,s0,-140
    80001526:	9a9ff0ef          	jal	80000ece <safestrcpy>
    memlog_push(&e);
    8000152a:	f5840513          	addi	a0,s0,-168
    8000152e:	725040ef          	jal	80006452 <memlog_push>
  oldsz = PGROUNDUP(oldsz);
    80001532:	6b05                	lui	s6,0x1
    80001534:	1b7d                	addi	s6,s6,-1 # fff <_entry-0x7ffff001>
    80001536:	9b26                	add	s6,s6,s1
    80001538:	77fd                	lui	a5,0xfffff
    8000153a:	00fb7b33          	and	s6,s6,a5
  for(a = oldsz; a < newsz; a += PGSIZE){
    8000153e:	073b7a63          	bgeu	s6,s3,800015b2 <uvmalloc+0x114>
    80001542:	895a                	mv	s2,s6
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    80001544:	012a6a13          	ori	s4,s4,18
    mem = kalloc();
    80001548:	e46ff0ef          	jal	80000b8e <kalloc>
    8000154c:	84aa                	mv	s1,a0
    if(mem == 0){
    8000154e:	c905                	beqz	a0,8000157e <uvmalloc+0xe0>
    memset(mem, 0, PGSIZE);
    80001550:	6605                	lui	a2,0x1
    80001552:	4581                	li	a1,0
    80001554:	83dff0ef          	jal	80000d90 <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    80001558:	8752                	mv	a4,s4
    8000155a:	86a6                	mv	a3,s1
    8000155c:	6605                	lui	a2,0x1
    8000155e:	85ca                	mv	a1,s2
    80001560:	8556                	mv	a0,s5
    80001562:	b87ff0ef          	jal	800010e8 <mappages>
    80001566:	e51d                	bnez	a0,80001594 <uvmalloc+0xf6>
  for(a = oldsz; a < newsz; a += PGSIZE){
    80001568:	6785                	lui	a5,0x1
    8000156a:	993e                	add	s2,s2,a5
    8000156c:	fd396ee3          	bltu	s2,s3,80001548 <uvmalloc+0xaa>
  return newsz;
    80001570:	84ce                	mv	s1,s3
    80001572:	694a                	ld	s2,144(sp)
    80001574:	69aa                	ld	s3,136(sp)
    80001576:	6a0a                	ld	s4,128(sp)
    80001578:	7ae6                	ld	s5,120(sp)
    8000157a:	7b46                	ld	s6,112(sp)
    8000157c:	bf0d                	j	800014ae <uvmalloc+0x10>
      uvmdealloc(pagetable, a, oldsz);
    8000157e:	865a                	mv	a2,s6
    80001580:	85ca                	mv	a1,s2
    80001582:	8556                	mv	a0,s5
    80001584:	ed7ff0ef          	jal	8000145a <uvmdealloc>
      return 0;
    80001588:	694a                	ld	s2,144(sp)
    8000158a:	69aa                	ld	s3,136(sp)
    8000158c:	6a0a                	ld	s4,128(sp)
    8000158e:	7ae6                	ld	s5,120(sp)
    80001590:	7b46                	ld	s6,112(sp)
    80001592:	bf31                	j	800014ae <uvmalloc+0x10>
      kfree(mem);
    80001594:	8526                	mv	a0,s1
    80001596:	cb8ff0ef          	jal	80000a4e <kfree>
      uvmdealloc(pagetable, a, oldsz);
    8000159a:	865a                	mv	a2,s6
    8000159c:	85ca                	mv	a1,s2
    8000159e:	8556                	mv	a0,s5
    800015a0:	ebbff0ef          	jal	8000145a <uvmdealloc>
      return 0;
    800015a4:	4481                	li	s1,0
    800015a6:	694a                	ld	s2,144(sp)
    800015a8:	69aa                	ld	s3,136(sp)
    800015aa:	6a0a                	ld	s4,128(sp)
    800015ac:	7ae6                	ld	s5,120(sp)
    800015ae:	7b46                	ld	s6,112(sp)
    800015b0:	bdfd                	j	800014ae <uvmalloc+0x10>
  return newsz;
    800015b2:	84ce                	mv	s1,s3
    800015b4:	694a                	ld	s2,144(sp)
    800015b6:	69aa                	ld	s3,136(sp)
    800015b8:	6a0a                	ld	s4,128(sp)
    800015ba:	7ae6                	ld	s5,120(sp)
    800015bc:	7b46                	ld	s6,112(sp)
    800015be:	bdc5                	j	800014ae <uvmalloc+0x10>

00000000800015c0 <freewalk>:
// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    800015c0:	7179                	addi	sp,sp,-48
    800015c2:	f406                	sd	ra,40(sp)
    800015c4:	f022                	sd	s0,32(sp)
    800015c6:	ec26                	sd	s1,24(sp)
    800015c8:	e84a                	sd	s2,16(sp)
    800015ca:	e44e                	sd	s3,8(sp)
    800015cc:	e052                	sd	s4,0(sp)
    800015ce:	1800                	addi	s0,sp,48
    800015d0:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    800015d2:	84aa                	mv	s1,a0
    800015d4:	6905                	lui	s2,0x1
    800015d6:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800015d8:	4985                	li	s3,1
    800015da:	a819                	j	800015f0 <freewalk+0x30>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    800015dc:	83a9                	srli	a5,a5,0xa
      freewalk((pagetable_t)child);
    800015de:	00c79513          	slli	a0,a5,0xc
    800015e2:	fdfff0ef          	jal	800015c0 <freewalk>
      pagetable[i] = 0;
    800015e6:	0004b023          	sd	zero,0(s1)
  for(int i = 0; i < 512; i++){
    800015ea:	04a1                	addi	s1,s1,8
    800015ec:	01248f63          	beq	s1,s2,8000160a <freewalk+0x4a>
    pte_t pte = pagetable[i];
    800015f0:	609c                	ld	a5,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800015f2:	00f7f713          	andi	a4,a5,15
    800015f6:	ff3703e3          	beq	a4,s3,800015dc <freewalk+0x1c>
    } else if(pte & PTE_V){
    800015fa:	8b85                	andi	a5,a5,1
    800015fc:	d7fd                	beqz	a5,800015ea <freewalk+0x2a>
      panic("freewalk: leaf");
    800015fe:	00007517          	auipc	a0,0x7
    80001602:	b4250513          	addi	a0,a0,-1214 # 80008140 <etext+0x140>
    80001606:	a0cff0ef          	jal	80000812 <panic>
    }
  }
  kfree((void*)pagetable);
    8000160a:	8552                	mv	a0,s4
    8000160c:	c42ff0ef          	jal	80000a4e <kfree>
}
    80001610:	70a2                	ld	ra,40(sp)
    80001612:	7402                	ld	s0,32(sp)
    80001614:	64e2                	ld	s1,24(sp)
    80001616:	6942                	ld	s2,16(sp)
    80001618:	69a2                	ld	s3,8(sp)
    8000161a:	6a02                	ld	s4,0(sp)
    8000161c:	6145                	addi	sp,sp,48
    8000161e:	8082                	ret

0000000080001620 <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    80001620:	1101                	addi	sp,sp,-32
    80001622:	ec06                	sd	ra,24(sp)
    80001624:	e822                	sd	s0,16(sp)
    80001626:	e426                	sd	s1,8(sp)
    80001628:	1000                	addi	s0,sp,32
    8000162a:	84aa                	mv	s1,a0
  if(sz > 0)
    8000162c:	e989                	bnez	a1,8000163e <uvmfree+0x1e>
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
  freewalk(pagetable);
    8000162e:	8526                	mv	a0,s1
    80001630:	f91ff0ef          	jal	800015c0 <freewalk>
}
    80001634:	60e2                	ld	ra,24(sp)
    80001636:	6442                	ld	s0,16(sp)
    80001638:	64a2                	ld	s1,8(sp)
    8000163a:	6105                	addi	sp,sp,32
    8000163c:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
    8000163e:	6785                	lui	a5,0x1
    80001640:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80001642:	95be                	add	a1,a1,a5
    80001644:	4685                	li	a3,1
    80001646:	00c5d613          	srli	a2,a1,0xc
    8000164a:	4581                	li	a1,0
    8000164c:	cefff0ef          	jal	8000133a <uvmunmap>
    80001650:	bff9                	j	8000162e <uvmfree+0xe>

0000000080001652 <uvmcopy>:
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for(i = 0; i < sz; i += PGSIZE){
    80001652:	ce49                	beqz	a2,800016ec <uvmcopy+0x9a>
{
    80001654:	715d                	addi	sp,sp,-80
    80001656:	e486                	sd	ra,72(sp)
    80001658:	e0a2                	sd	s0,64(sp)
    8000165a:	fc26                	sd	s1,56(sp)
    8000165c:	f84a                	sd	s2,48(sp)
    8000165e:	f44e                	sd	s3,40(sp)
    80001660:	f052                	sd	s4,32(sp)
    80001662:	ec56                	sd	s5,24(sp)
    80001664:	e85a                	sd	s6,16(sp)
    80001666:	e45e                	sd	s7,8(sp)
    80001668:	0880                	addi	s0,sp,80
    8000166a:	8aaa                	mv	s5,a0
    8000166c:	8b2e                	mv	s6,a1
    8000166e:	8a32                	mv	s4,a2
  for(i = 0; i < sz; i += PGSIZE){
    80001670:	4481                	li	s1,0
    80001672:	a029                	j	8000167c <uvmcopy+0x2a>
    80001674:	6785                	lui	a5,0x1
    80001676:	94be                	add	s1,s1,a5
    80001678:	0544fe63          	bgeu	s1,s4,800016d4 <uvmcopy+0x82>
    if((pte = walk(old, i, 0)) == 0)
    8000167c:	4601                	li	a2,0
    8000167e:	85a6                	mv	a1,s1
    80001680:	8556                	mv	a0,s5
    80001682:	98fff0ef          	jal	80001010 <walk>
    80001686:	d57d                	beqz	a0,80001674 <uvmcopy+0x22>
      continue;   // page table entry hasn't been allocated
    if((*pte & PTE_V) == 0)
    80001688:	6118                	ld	a4,0(a0)
    8000168a:	00177793          	andi	a5,a4,1
    8000168e:	d3fd                	beqz	a5,80001674 <uvmcopy+0x22>
      continue;   // physical page hasn't been allocated
    pa = PTE2PA(*pte);
    80001690:	00a75593          	srli	a1,a4,0xa
    80001694:	00c59b93          	slli	s7,a1,0xc
    flags = PTE_FLAGS(*pte);
    80001698:	3ff77913          	andi	s2,a4,1023
    if((mem = kalloc()) == 0)
    8000169c:	cf2ff0ef          	jal	80000b8e <kalloc>
    800016a0:	89aa                	mv	s3,a0
    800016a2:	c105                	beqz	a0,800016c2 <uvmcopy+0x70>
      goto err;
    memmove(mem, (char*)pa, PGSIZE);
    800016a4:	6605                	lui	a2,0x1
    800016a6:	85de                	mv	a1,s7
    800016a8:	f44ff0ef          	jal	80000dec <memmove>
    if(mappages(new, i, PGSIZE, (uint64)mem, flags) != 0){
    800016ac:	874a                	mv	a4,s2
    800016ae:	86ce                	mv	a3,s3
    800016b0:	6605                	lui	a2,0x1
    800016b2:	85a6                	mv	a1,s1
    800016b4:	855a                	mv	a0,s6
    800016b6:	a33ff0ef          	jal	800010e8 <mappages>
    800016ba:	dd4d                	beqz	a0,80001674 <uvmcopy+0x22>
      kfree(mem);
    800016bc:	854e                	mv	a0,s3
    800016be:	b90ff0ef          	jal	80000a4e <kfree>
    }
  }
  return 0;

 err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    800016c2:	4685                	li	a3,1
    800016c4:	00c4d613          	srli	a2,s1,0xc
    800016c8:	4581                	li	a1,0
    800016ca:	855a                	mv	a0,s6
    800016cc:	c6fff0ef          	jal	8000133a <uvmunmap>
  return -1;
    800016d0:	557d                	li	a0,-1
    800016d2:	a011                	j	800016d6 <uvmcopy+0x84>
  return 0;
    800016d4:	4501                	li	a0,0
}
    800016d6:	60a6                	ld	ra,72(sp)
    800016d8:	6406                	ld	s0,64(sp)
    800016da:	74e2                	ld	s1,56(sp)
    800016dc:	7942                	ld	s2,48(sp)
    800016de:	79a2                	ld	s3,40(sp)
    800016e0:	7a02                	ld	s4,32(sp)
    800016e2:	6ae2                	ld	s5,24(sp)
    800016e4:	6b42                	ld	s6,16(sp)
    800016e6:	6ba2                	ld	s7,8(sp)
    800016e8:	6161                	addi	sp,sp,80
    800016ea:	8082                	ret
  return 0;
    800016ec:	4501                	li	a0,0
}
    800016ee:	8082                	ret

00000000800016f0 <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    800016f0:	1141                	addi	sp,sp,-16
    800016f2:	e406                	sd	ra,8(sp)
    800016f4:	e022                	sd	s0,0(sp)
    800016f6:	0800                	addi	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    800016f8:	4601                	li	a2,0
    800016fa:	917ff0ef          	jal	80001010 <walk>
  if(pte == 0)
    800016fe:	c901                	beqz	a0,8000170e <uvmclear+0x1e>
    panic("uvmclear");
  *pte &= ~PTE_U;
    80001700:	611c                	ld	a5,0(a0)
    80001702:	9bbd                	andi	a5,a5,-17
    80001704:	e11c                	sd	a5,0(a0)
}
    80001706:	60a2                	ld	ra,8(sp)
    80001708:	6402                	ld	s0,0(sp)
    8000170a:	0141                	addi	sp,sp,16
    8000170c:	8082                	ret
    panic("uvmclear");
    8000170e:	00007517          	auipc	a0,0x7
    80001712:	a4250513          	addi	a0,a0,-1470 # 80008150 <etext+0x150>
    80001716:	8fcff0ef          	jal	80000812 <panic>

000000008000171a <copyinstr>:
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    8000171a:	c6dd                	beqz	a3,800017c8 <copyinstr+0xae>
{
    8000171c:	715d                	addi	sp,sp,-80
    8000171e:	e486                	sd	ra,72(sp)
    80001720:	e0a2                	sd	s0,64(sp)
    80001722:	fc26                	sd	s1,56(sp)
    80001724:	f84a                	sd	s2,48(sp)
    80001726:	f44e                	sd	s3,40(sp)
    80001728:	f052                	sd	s4,32(sp)
    8000172a:	ec56                	sd	s5,24(sp)
    8000172c:	e85a                	sd	s6,16(sp)
    8000172e:	e45e                	sd	s7,8(sp)
    80001730:	0880                	addi	s0,sp,80
    80001732:	8a2a                	mv	s4,a0
    80001734:	8b2e                	mv	s6,a1
    80001736:	8bb2                	mv	s7,a2
    80001738:	8936                	mv	s2,a3
    va0 = PGROUNDDOWN(srcva);
    8000173a:	7afd                	lui	s5,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    8000173c:	6985                	lui	s3,0x1
    8000173e:	a825                	j	80001776 <copyinstr+0x5c>
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
    80001740:	00078023          	sb	zero,0(a5) # 1000 <_entry-0x7ffff000>
    80001744:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    80001746:	37fd                	addiw	a5,a5,-1
    80001748:	0007851b          	sext.w	a0,a5
    return 0;
  } else {
    return -1;
  }
}
    8000174c:	60a6                	ld	ra,72(sp)
    8000174e:	6406                	ld	s0,64(sp)
    80001750:	74e2                	ld	s1,56(sp)
    80001752:	7942                	ld	s2,48(sp)
    80001754:	79a2                	ld	s3,40(sp)
    80001756:	7a02                	ld	s4,32(sp)
    80001758:	6ae2                	ld	s5,24(sp)
    8000175a:	6b42                	ld	s6,16(sp)
    8000175c:	6ba2                	ld	s7,8(sp)
    8000175e:	6161                	addi	sp,sp,80
    80001760:	8082                	ret
    80001762:	fff90713          	addi	a4,s2,-1 # fff <_entry-0x7ffff001>
    80001766:	9742                	add	a4,a4,a6
      --max;
    80001768:	40b70933          	sub	s2,a4,a1
    srcva = va0 + PGSIZE;
    8000176c:	01348bb3          	add	s7,s1,s3
  while(got_null == 0 && max > 0){
    80001770:	04e58463          	beq	a1,a4,800017b8 <copyinstr+0x9e>
{
    80001774:	8b3e                	mv	s6,a5
    va0 = PGROUNDDOWN(srcva);
    80001776:	015bf4b3          	and	s1,s7,s5
    pa0 = walkaddr(pagetable, va0);
    8000177a:	85a6                	mv	a1,s1
    8000177c:	8552                	mv	a0,s4
    8000177e:	92dff0ef          	jal	800010aa <walkaddr>
    if(pa0 == 0)
    80001782:	cd0d                	beqz	a0,800017bc <copyinstr+0xa2>
    n = PGSIZE - (srcva - va0);
    80001784:	417486b3          	sub	a3,s1,s7
    80001788:	96ce                	add	a3,a3,s3
    if(n > max)
    8000178a:	00d97363          	bgeu	s2,a3,80001790 <copyinstr+0x76>
    8000178e:	86ca                	mv	a3,s2
    char *p = (char *) (pa0 + (srcva - va0));
    80001790:	955e                	add	a0,a0,s7
    80001792:	8d05                	sub	a0,a0,s1
    while(n > 0){
    80001794:	c695                	beqz	a3,800017c0 <copyinstr+0xa6>
    80001796:	87da                	mv	a5,s6
    80001798:	885a                	mv	a6,s6
      if(*p == '\0'){
    8000179a:	41650633          	sub	a2,a0,s6
    while(n > 0){
    8000179e:	96da                	add	a3,a3,s6
    800017a0:	85be                	mv	a1,a5
      if(*p == '\0'){
    800017a2:	00f60733          	add	a4,a2,a5
    800017a6:	00074703          	lbu	a4,0(a4)
    800017aa:	db59                	beqz	a4,80001740 <copyinstr+0x26>
        *dst = *p;
    800017ac:	00e78023          	sb	a4,0(a5)
      dst++;
    800017b0:	0785                	addi	a5,a5,1
    while(n > 0){
    800017b2:	fed797e3          	bne	a5,a3,800017a0 <copyinstr+0x86>
    800017b6:	b775                	j	80001762 <copyinstr+0x48>
    800017b8:	4781                	li	a5,0
    800017ba:	b771                	j	80001746 <copyinstr+0x2c>
      return -1;
    800017bc:	557d                	li	a0,-1
    800017be:	b779                	j	8000174c <copyinstr+0x32>
    srcva = va0 + PGSIZE;
    800017c0:	6b85                	lui	s7,0x1
    800017c2:	9ba6                	add	s7,s7,s1
    800017c4:	87da                	mv	a5,s6
    800017c6:	b77d                	j	80001774 <copyinstr+0x5a>
  int got_null = 0;
    800017c8:	4781                	li	a5,0
  if(got_null){
    800017ca:	37fd                	addiw	a5,a5,-1
    800017cc:	0007851b          	sext.w	a0,a5
}
    800017d0:	8082                	ret

00000000800017d2 <ismapped>:
  }
  return mem;
}
int
ismapped(pagetable_t pagetable, uint64 va)
{
    800017d2:	1141                	addi	sp,sp,-16
    800017d4:	e406                	sd	ra,8(sp)
    800017d6:	e022                	sd	s0,0(sp)
    800017d8:	0800                	addi	s0,sp,16
  pte_t *pte = walk(pagetable, va, 0);
    800017da:	4601                	li	a2,0
    800017dc:	835ff0ef          	jal	80001010 <walk>
  if (pte == 0) {
    800017e0:	c519                	beqz	a0,800017ee <ismapped+0x1c>
    return 0;
  }
  if (*pte & PTE_V){
    800017e2:	6108                	ld	a0,0(a0)
    800017e4:	8905                	andi	a0,a0,1
    return 1;
  }
  return 0;
}
    800017e6:	60a2                	ld	ra,8(sp)
    800017e8:	6402                	ld	s0,0(sp)
    800017ea:	0141                	addi	sp,sp,16
    800017ec:	8082                	ret
    return 0;
    800017ee:	4501                	li	a0,0
    800017f0:	bfdd                	j	800017e6 <ismapped+0x14>

00000000800017f2 <vmfault>:
{
    800017f2:	7135                	addi	sp,sp,-160
    800017f4:	ed06                	sd	ra,152(sp)
    800017f6:	e922                	sd	s0,144(sp)
    800017f8:	e526                	sd	s1,136(sp)
    800017fa:	fcce                	sd	s3,120(sp)
    800017fc:	1100                	addi	s0,sp,160
    800017fe:	89aa                	mv	s3,a0
    80001800:	84ae                	mv	s1,a1
  struct proc *p = myproc();
    80001802:	3d0000ef          	jal	80001bd2 <myproc>
  if (va >= p->sz)
    80001806:	653c                	ld	a5,72(a0)
    80001808:	00f4ea63          	bltu	s1,a5,8000181c <vmfault+0x2a>
    return 0;
    8000180c:	4981                	li	s3,0
}
    8000180e:	854e                	mv	a0,s3
    80001810:	60ea                	ld	ra,152(sp)
    80001812:	644a                	ld	s0,144(sp)
    80001814:	64aa                	ld	s1,136(sp)
    80001816:	79e6                	ld	s3,120(sp)
    80001818:	610d                	addi	sp,sp,160
    8000181a:	8082                	ret
    8000181c:	e14a                	sd	s2,128(sp)
    8000181e:	892a                	mv	s2,a0
  va = PGROUNDDOWN(va);
    80001820:	77fd                	lui	a5,0xfffff
    80001822:	8cfd                	and	s1,s1,a5
  if(ismapped(pagetable, va)) {
    80001824:	85a6                	mv	a1,s1
    80001826:	854e                	mv	a0,s3
    80001828:	fabff0ef          	jal	800017d2 <ismapped>
    return 0;
    8000182c:	4981                	li	s3,0
  if(ismapped(pagetable, va)) {
    8000182e:	c119                	beqz	a0,80001834 <vmfault+0x42>
    80001830:	690a                	ld	s2,128(sp)
    80001832:	bff1                	j	8000180e <vmfault+0x1c>
    80001834:	f8d2                	sd	s4,112(sp)
  memset(&e, 0, sizeof(e));
    80001836:	06800613          	li	a2,104
    8000183a:	4581                	li	a1,0
    8000183c:	f6840513          	addi	a0,s0,-152
    80001840:	d50ff0ef          	jal	80000d90 <memset>
  e.ticks  = ticks;
    80001844:	0000a797          	auipc	a5,0xa
    80001848:	e8c7a783          	lw	a5,-372(a5) # 8000b6d0 <ticks>
    8000184c:	f6f42823          	sw	a5,-144(s0)
  e.cpu    = cpuid();
    80001850:	356000ef          	jal	80001ba6 <cpuid>
    80001854:	f6a42a23          	sw	a0,-140(s0)
  e.type   = MEM_FAULT;
    80001858:	478d                	li	a5,3
    8000185a:	f6f42c23          	sw	a5,-136(s0)
  e.pid    = p->pid;
    8000185e:	03092783          	lw	a5,48(s2)
    80001862:	f6f42e23          	sw	a5,-132(s0)
  e.state  = p->state;
    80001866:	01892783          	lw	a5,24(s2)
    8000186a:	f8f42023          	sw	a5,-128(s0)
  e.va     = va;
    8000186e:	f8943c23          	sd	s1,-104(s0)
  e.source = SRC_VMFAULT;
    80001872:	479d                	li	a5,7
    80001874:	fcf42223          	sw	a5,-60(s0)
  e.kind   = PAGE_USER;
    80001878:	4785                	li	a5,1
    8000187a:	fcf42423          	sw	a5,-56(s0)
  safestrcpy(e.name, p->name, MEM_NM);
    8000187e:	4641                	li	a2,16
    80001880:	15890593          	addi	a1,s2,344
    80001884:	f8440513          	addi	a0,s0,-124
    80001888:	e46ff0ef          	jal	80000ece <safestrcpy>
  memlog_push(&e);
    8000188c:	f6840513          	addi	a0,s0,-152
    80001890:	3c3040ef          	jal	80006452 <memlog_push>
  mem = (uint64) kalloc();
    80001894:	afaff0ef          	jal	80000b8e <kalloc>
    80001898:	8a2a                	mv	s4,a0
  if(mem == 0)
    8000189a:	c90d                	beqz	a0,800018cc <vmfault+0xda>
  mem = (uint64) kalloc();
    8000189c:	89aa                	mv	s3,a0
  memset((void *) mem, 0, PGSIZE);
    8000189e:	6605                	lui	a2,0x1
    800018a0:	4581                	li	a1,0
    800018a2:	ceeff0ef          	jal	80000d90 <memset>
  if (mappages(p->pagetable, va, PGSIZE, mem, PTE_W|PTE_U|PTE_R) != 0) {
    800018a6:	4759                	li	a4,22
    800018a8:	86d2                	mv	a3,s4
    800018aa:	6605                	lui	a2,0x1
    800018ac:	85a6                	mv	a1,s1
    800018ae:	05093503          	ld	a0,80(s2)
    800018b2:	837ff0ef          	jal	800010e8 <mappages>
    800018b6:	e501                	bnez	a0,800018be <vmfault+0xcc>
    800018b8:	690a                	ld	s2,128(sp)
    800018ba:	7a46                	ld	s4,112(sp)
    800018bc:	bf89                	j	8000180e <vmfault+0x1c>
    kfree((void *)mem);
    800018be:	8552                	mv	a0,s4
    800018c0:	98eff0ef          	jal	80000a4e <kfree>
    return 0;
    800018c4:	4981                	li	s3,0
    800018c6:	690a                	ld	s2,128(sp)
    800018c8:	7a46                	ld	s4,112(sp)
    800018ca:	b791                	j	8000180e <vmfault+0x1c>
    800018cc:	690a                	ld	s2,128(sp)
    800018ce:	7a46                	ld	s4,112(sp)
    800018d0:	bf3d                	j	8000180e <vmfault+0x1c>

00000000800018d2 <copyout>:
  while(len > 0){
    800018d2:	c2cd                	beqz	a3,80001974 <copyout+0xa2>
{
    800018d4:	711d                	addi	sp,sp,-96
    800018d6:	ec86                	sd	ra,88(sp)
    800018d8:	e8a2                	sd	s0,80(sp)
    800018da:	e4a6                	sd	s1,72(sp)
    800018dc:	f852                	sd	s4,48(sp)
    800018de:	f05a                	sd	s6,32(sp)
    800018e0:	ec5e                	sd	s7,24(sp)
    800018e2:	e862                	sd	s8,16(sp)
    800018e4:	1080                	addi	s0,sp,96
    800018e6:	8c2a                	mv	s8,a0
    800018e8:	8b2e                	mv	s6,a1
    800018ea:	8bb2                	mv	s7,a2
    800018ec:	8a36                	mv	s4,a3
    va0 = PGROUNDDOWN(dstva);
    800018ee:	74fd                	lui	s1,0xfffff
    800018f0:	8ced                	and	s1,s1,a1
    if(va0 >= MAXVA)
    800018f2:	57fd                	li	a5,-1
    800018f4:	83e9                	srli	a5,a5,0x1a
    800018f6:	0897e163          	bltu	a5,s1,80001978 <copyout+0xa6>
    800018fa:	e0ca                	sd	s2,64(sp)
    800018fc:	fc4e                	sd	s3,56(sp)
    800018fe:	f456                	sd	s5,40(sp)
    80001900:	e466                	sd	s9,8(sp)
    80001902:	e06a                	sd	s10,0(sp)
    80001904:	6d05                	lui	s10,0x1
    80001906:	8cbe                	mv	s9,a5
    80001908:	a015                	j	8000192c <copyout+0x5a>
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    8000190a:	409b0533          	sub	a0,s6,s1
    8000190e:	0009861b          	sext.w	a2,s3
    80001912:	85de                	mv	a1,s7
    80001914:	954a                	add	a0,a0,s2
    80001916:	cd6ff0ef          	jal	80000dec <memmove>
    len -= n;
    8000191a:	413a0a33          	sub	s4,s4,s3
    src += n;
    8000191e:	9bce                	add	s7,s7,s3
  while(len > 0){
    80001920:	040a0363          	beqz	s4,80001966 <copyout+0x94>
    if(va0 >= MAXVA)
    80001924:	055cec63          	bltu	s9,s5,8000197c <copyout+0xaa>
    80001928:	84d6                	mv	s1,s5
    8000192a:	8b56                	mv	s6,s5
    pa0 = walkaddr(pagetable, va0);
    8000192c:	85a6                	mv	a1,s1
    8000192e:	8562                	mv	a0,s8
    80001930:	f7aff0ef          	jal	800010aa <walkaddr>
    80001934:	892a                	mv	s2,a0
    if(pa0 == 0) {
    80001936:	e901                	bnez	a0,80001946 <copyout+0x74>
      if((pa0 = vmfault(pagetable, va0, 0)) == 0) {
    80001938:	4601                	li	a2,0
    8000193a:	85a6                	mv	a1,s1
    8000193c:	8562                	mv	a0,s8
    8000193e:	eb5ff0ef          	jal	800017f2 <vmfault>
    80001942:	892a                	mv	s2,a0
    80001944:	c139                	beqz	a0,8000198a <copyout+0xb8>
    pte = walk(pagetable, va0, 0);
    80001946:	4601                	li	a2,0
    80001948:	85a6                	mv	a1,s1
    8000194a:	8562                	mv	a0,s8
    8000194c:	ec4ff0ef          	jal	80001010 <walk>
    if((*pte & PTE_W) == 0)
    80001950:	611c                	ld	a5,0(a0)
    80001952:	8b91                	andi	a5,a5,4
    80001954:	c3b1                	beqz	a5,80001998 <copyout+0xc6>
    n = PGSIZE - (dstva - va0);
    80001956:	01a48ab3          	add	s5,s1,s10
    8000195a:	416a89b3          	sub	s3,s5,s6
    if(n > len)
    8000195e:	fb3a76e3          	bgeu	s4,s3,8000190a <copyout+0x38>
    80001962:	89d2                	mv	s3,s4
    80001964:	b75d                	j	8000190a <copyout+0x38>
  return 0;
    80001966:	4501                	li	a0,0
    80001968:	6906                	ld	s2,64(sp)
    8000196a:	79e2                	ld	s3,56(sp)
    8000196c:	7aa2                	ld	s5,40(sp)
    8000196e:	6ca2                	ld	s9,8(sp)
    80001970:	6d02                	ld	s10,0(sp)
    80001972:	a80d                	j	800019a4 <copyout+0xd2>
    80001974:	4501                	li	a0,0
}
    80001976:	8082                	ret
      return -1;
    80001978:	557d                	li	a0,-1
    8000197a:	a02d                	j	800019a4 <copyout+0xd2>
    8000197c:	557d                	li	a0,-1
    8000197e:	6906                	ld	s2,64(sp)
    80001980:	79e2                	ld	s3,56(sp)
    80001982:	7aa2                	ld	s5,40(sp)
    80001984:	6ca2                	ld	s9,8(sp)
    80001986:	6d02                	ld	s10,0(sp)
    80001988:	a831                	j	800019a4 <copyout+0xd2>
        return -1;
    8000198a:	557d                	li	a0,-1
    8000198c:	6906                	ld	s2,64(sp)
    8000198e:	79e2                	ld	s3,56(sp)
    80001990:	7aa2                	ld	s5,40(sp)
    80001992:	6ca2                	ld	s9,8(sp)
    80001994:	6d02                	ld	s10,0(sp)
    80001996:	a039                	j	800019a4 <copyout+0xd2>
      return -1;
    80001998:	557d                	li	a0,-1
    8000199a:	6906                	ld	s2,64(sp)
    8000199c:	79e2                	ld	s3,56(sp)
    8000199e:	7aa2                	ld	s5,40(sp)
    800019a0:	6ca2                	ld	s9,8(sp)
    800019a2:	6d02                	ld	s10,0(sp)
}
    800019a4:	60e6                	ld	ra,88(sp)
    800019a6:	6446                	ld	s0,80(sp)
    800019a8:	64a6                	ld	s1,72(sp)
    800019aa:	7a42                	ld	s4,48(sp)
    800019ac:	7b02                	ld	s6,32(sp)
    800019ae:	6be2                	ld	s7,24(sp)
    800019b0:	6c42                	ld	s8,16(sp)
    800019b2:	6125                	addi	sp,sp,96
    800019b4:	8082                	ret

00000000800019b6 <copyin>:
  while(len > 0){
    800019b6:	c6c9                	beqz	a3,80001a40 <copyin+0x8a>
{
    800019b8:	715d                	addi	sp,sp,-80
    800019ba:	e486                	sd	ra,72(sp)
    800019bc:	e0a2                	sd	s0,64(sp)
    800019be:	fc26                	sd	s1,56(sp)
    800019c0:	f84a                	sd	s2,48(sp)
    800019c2:	f44e                	sd	s3,40(sp)
    800019c4:	f052                	sd	s4,32(sp)
    800019c6:	ec56                	sd	s5,24(sp)
    800019c8:	e85a                	sd	s6,16(sp)
    800019ca:	e45e                	sd	s7,8(sp)
    800019cc:	e062                	sd	s8,0(sp)
    800019ce:	0880                	addi	s0,sp,80
    800019d0:	8baa                	mv	s7,a0
    800019d2:	8aae                	mv	s5,a1
    800019d4:	8932                	mv	s2,a2
    800019d6:	8a36                	mv	s4,a3
    va0 = PGROUNDDOWN(srcva);
    800019d8:	7c7d                	lui	s8,0xfffff
    n = PGSIZE - (srcva - va0);
    800019da:	6b05                	lui	s6,0x1
    800019dc:	a035                	j	80001a08 <copyin+0x52>
    800019de:	412984b3          	sub	s1,s3,s2
    800019e2:	94da                	add	s1,s1,s6
    if(n > len)
    800019e4:	009a7363          	bgeu	s4,s1,800019ea <copyin+0x34>
    800019e8:	84d2                	mv	s1,s4
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    800019ea:	413905b3          	sub	a1,s2,s3
    800019ee:	0004861b          	sext.w	a2,s1
    800019f2:	95aa                	add	a1,a1,a0
    800019f4:	8556                	mv	a0,s5
    800019f6:	bf6ff0ef          	jal	80000dec <memmove>
    len -= n;
    800019fa:	409a0a33          	sub	s4,s4,s1
    dst += n;
    800019fe:	9aa6                	add	s5,s5,s1
    srcva = va0 + PGSIZE;
    80001a00:	01698933          	add	s2,s3,s6
  while(len > 0){
    80001a04:	020a0163          	beqz	s4,80001a26 <copyin+0x70>
    va0 = PGROUNDDOWN(srcva);
    80001a08:	018979b3          	and	s3,s2,s8
    pa0 = walkaddr(pagetable, va0);
    80001a0c:	85ce                	mv	a1,s3
    80001a0e:	855e                	mv	a0,s7
    80001a10:	e9aff0ef          	jal	800010aa <walkaddr>
    if(pa0 == 0) {
    80001a14:	f569                	bnez	a0,800019de <copyin+0x28>
      if((pa0 = vmfault(pagetable, va0, 0)) == 0) {
    80001a16:	4601                	li	a2,0
    80001a18:	85ce                	mv	a1,s3
    80001a1a:	855e                	mv	a0,s7
    80001a1c:	dd7ff0ef          	jal	800017f2 <vmfault>
    80001a20:	fd5d                	bnez	a0,800019de <copyin+0x28>
        return -1;
    80001a22:	557d                	li	a0,-1
    80001a24:	a011                	j	80001a28 <copyin+0x72>
  return 0;
    80001a26:	4501                	li	a0,0
}
    80001a28:	60a6                	ld	ra,72(sp)
    80001a2a:	6406                	ld	s0,64(sp)
    80001a2c:	74e2                	ld	s1,56(sp)
    80001a2e:	7942                	ld	s2,48(sp)
    80001a30:	79a2                	ld	s3,40(sp)
    80001a32:	7a02                	ld	s4,32(sp)
    80001a34:	6ae2                	ld	s5,24(sp)
    80001a36:	6b42                	ld	s6,16(sp)
    80001a38:	6ba2                	ld	s7,8(sp)
    80001a3a:	6c02                	ld	s8,0(sp)
    80001a3c:	6161                	addi	sp,sp,80
    80001a3e:	8082                	ret
  return 0;
    80001a40:	4501                	li	a0,0
}
    80001a42:	8082                	ret

0000000080001a44 <proc_mapstacks>:
struct spinlock wait_lock;

// Allocate a page for each process's kernel stack.
// Map it high in memory, followed by an invalid
// guard page.
void proc_mapstacks(pagetable_t kpgtbl) {
    80001a44:	7139                	addi	sp,sp,-64
    80001a46:	fc06                	sd	ra,56(sp)
    80001a48:	f822                	sd	s0,48(sp)
    80001a4a:	f426                	sd	s1,40(sp)
    80001a4c:	f04a                	sd	s2,32(sp)
    80001a4e:	ec4e                	sd	s3,24(sp)
    80001a50:	e852                	sd	s4,16(sp)
    80001a52:	e456                	sd	s5,8(sp)
    80001a54:	e05a                	sd	s6,0(sp)
    80001a56:	0080                	addi	s0,sp,64
    80001a58:	8a2a                	mv	s4,a0
  struct proc *p;

  for (p = proc; p < &proc[NPROC]; p++) {
    80001a5a:	00012497          	auipc	s1,0x12
    80001a5e:	21648493          	addi	s1,s1,534 # 80013c70 <proc>
    char *pa = kalloc();
    if (pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int)(p - proc));
    80001a62:	8b26                	mv	s6,s1
    80001a64:	04fa5937          	lui	s2,0x4fa5
    80001a68:	fa590913          	addi	s2,s2,-91 # 4fa4fa5 <_entry-0x7b05b05b>
    80001a6c:	0932                	slli	s2,s2,0xc
    80001a6e:	fa590913          	addi	s2,s2,-91
    80001a72:	0932                	slli	s2,s2,0xc
    80001a74:	fa590913          	addi	s2,s2,-91
    80001a78:	0932                	slli	s2,s2,0xc
    80001a7a:	fa590913          	addi	s2,s2,-91
    80001a7e:	040009b7          	lui	s3,0x4000
    80001a82:	19fd                	addi	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    80001a84:	09b2                	slli	s3,s3,0xc
  for (p = proc; p < &proc[NPROC]; p++) {
    80001a86:	00018a97          	auipc	s5,0x18
    80001a8a:	beaa8a93          	addi	s5,s5,-1046 # 80019670 <tickslock>
    char *pa = kalloc();
    80001a8e:	900ff0ef          	jal	80000b8e <kalloc>
    80001a92:	862a                	mv	a2,a0
    if (pa == 0)
    80001a94:	cd15                	beqz	a0,80001ad0 <proc_mapstacks+0x8c>
    uint64 va = KSTACK((int)(p - proc));
    80001a96:	416485b3          	sub	a1,s1,s6
    80001a9a:	858d                	srai	a1,a1,0x3
    80001a9c:	032585b3          	mul	a1,a1,s2
    80001aa0:	2585                	addiw	a1,a1,1
    80001aa2:	00d5959b          	slliw	a1,a1,0xd
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    80001aa6:	4719                	li	a4,6
    80001aa8:	6685                	lui	a3,0x1
    80001aaa:	40b985b3          	sub	a1,s3,a1
    80001aae:	8552                	mv	a0,s4
    80001ab0:	f6eff0ef          	jal	8000121e <kvmmap>
  for (p = proc; p < &proc[NPROC]; p++) {
    80001ab4:	16848493          	addi	s1,s1,360
    80001ab8:	fd549be3          	bne	s1,s5,80001a8e <proc_mapstacks+0x4a>
  }
}
    80001abc:	70e2                	ld	ra,56(sp)
    80001abe:	7442                	ld	s0,48(sp)
    80001ac0:	74a2                	ld	s1,40(sp)
    80001ac2:	7902                	ld	s2,32(sp)
    80001ac4:	69e2                	ld	s3,24(sp)
    80001ac6:	6a42                	ld	s4,16(sp)
    80001ac8:	6aa2                	ld	s5,8(sp)
    80001aca:	6b02                	ld	s6,0(sp)
    80001acc:	6121                	addi	sp,sp,64
    80001ace:	8082                	ret
      panic("kalloc");
    80001ad0:	00006517          	auipc	a0,0x6
    80001ad4:	69050513          	addi	a0,a0,1680 # 80008160 <etext+0x160>
    80001ad8:	d3bfe0ef          	jal	80000812 <panic>

0000000080001adc <procinit>:

// initialize the proc table.
void procinit(void) {
    80001adc:	7139                	addi	sp,sp,-64
    80001ade:	fc06                	sd	ra,56(sp)
    80001ae0:	f822                	sd	s0,48(sp)
    80001ae2:	f426                	sd	s1,40(sp)
    80001ae4:	f04a                	sd	s2,32(sp)
    80001ae6:	ec4e                	sd	s3,24(sp)
    80001ae8:	e852                	sd	s4,16(sp)
    80001aea:	e456                	sd	s5,8(sp)
    80001aec:	e05a                	sd	s6,0(sp)
    80001aee:	0080                	addi	s0,sp,64
  struct proc *p;

  initlock(&pid_lock, "nextpid");
    80001af0:	00006597          	auipc	a1,0x6
    80001af4:	67858593          	addi	a1,a1,1656 # 80008168 <etext+0x168>
    80001af8:	00012517          	auipc	a0,0x12
    80001afc:	d3050513          	addi	a0,a0,-720 # 80013828 <pid_lock>
    80001b00:	93cff0ef          	jal	80000c3c <initlock>
  initlock(&wait_lock, "wait_lock");
    80001b04:	00006597          	auipc	a1,0x6
    80001b08:	66c58593          	addi	a1,a1,1644 # 80008170 <etext+0x170>
    80001b0c:	00012517          	auipc	a0,0x12
    80001b10:	d3450513          	addi	a0,a0,-716 # 80013840 <wait_lock>
    80001b14:	928ff0ef          	jal	80000c3c <initlock>
  initlock(&schedinfo_lock, "schedinfo");
    80001b18:	00006597          	auipc	a1,0x6
    80001b1c:	66858593          	addi	a1,a1,1640 # 80008180 <etext+0x180>
    80001b20:	00012517          	auipc	a0,0x12
    80001b24:	d3850513          	addi	a0,a0,-712 # 80013858 <schedinfo_lock>
    80001b28:	914ff0ef          	jal	80000c3c <initlock>
  for (p = proc; p < &proc[NPROC]; p++) {
    80001b2c:	00012497          	auipc	s1,0x12
    80001b30:	14448493          	addi	s1,s1,324 # 80013c70 <proc>
    initlock(&p->lock, "proc");
    80001b34:	00006b17          	auipc	s6,0x6
    80001b38:	65cb0b13          	addi	s6,s6,1628 # 80008190 <etext+0x190>
    p->state = UNUSED;
    p->kstack = KSTACK((int)(p - proc));
    80001b3c:	8aa6                	mv	s5,s1
    80001b3e:	04fa5937          	lui	s2,0x4fa5
    80001b42:	fa590913          	addi	s2,s2,-91 # 4fa4fa5 <_entry-0x7b05b05b>
    80001b46:	0932                	slli	s2,s2,0xc
    80001b48:	fa590913          	addi	s2,s2,-91
    80001b4c:	0932                	slli	s2,s2,0xc
    80001b4e:	fa590913          	addi	s2,s2,-91
    80001b52:	0932                	slli	s2,s2,0xc
    80001b54:	fa590913          	addi	s2,s2,-91
    80001b58:	040009b7          	lui	s3,0x4000
    80001b5c:	19fd                	addi	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    80001b5e:	09b2                	slli	s3,s3,0xc
  for (p = proc; p < &proc[NPROC]; p++) {
    80001b60:	00018a17          	auipc	s4,0x18
    80001b64:	b10a0a13          	addi	s4,s4,-1264 # 80019670 <tickslock>
    initlock(&p->lock, "proc");
    80001b68:	85da                	mv	a1,s6
    80001b6a:	8526                	mv	a0,s1
    80001b6c:	8d0ff0ef          	jal	80000c3c <initlock>
    p->state = UNUSED;
    80001b70:	0004ac23          	sw	zero,24(s1)
    p->kstack = KSTACK((int)(p - proc));
    80001b74:	415487b3          	sub	a5,s1,s5
    80001b78:	878d                	srai	a5,a5,0x3
    80001b7a:	032787b3          	mul	a5,a5,s2
    80001b7e:	2785                	addiw	a5,a5,1
    80001b80:	00d7979b          	slliw	a5,a5,0xd
    80001b84:	40f987b3          	sub	a5,s3,a5
    80001b88:	e0bc                	sd	a5,64(s1)
  for (p = proc; p < &proc[NPROC]; p++) {
    80001b8a:	16848493          	addi	s1,s1,360
    80001b8e:	fd449de3          	bne	s1,s4,80001b68 <procinit+0x8c>
  }
}
    80001b92:	70e2                	ld	ra,56(sp)
    80001b94:	7442                	ld	s0,48(sp)
    80001b96:	74a2                	ld	s1,40(sp)
    80001b98:	7902                	ld	s2,32(sp)
    80001b9a:	69e2                	ld	s3,24(sp)
    80001b9c:	6a42                	ld	s4,16(sp)
    80001b9e:	6aa2                	ld	s5,8(sp)
    80001ba0:	6b02                	ld	s6,0(sp)
    80001ba2:	6121                	addi	sp,sp,64
    80001ba4:	8082                	ret

0000000080001ba6 <cpuid>:

// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int cpuid() {
    80001ba6:	1141                	addi	sp,sp,-16
    80001ba8:	e422                	sd	s0,8(sp)
    80001baa:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    80001bac:	8512                	mv	a0,tp
  int id = r_tp();
  return id;
}
    80001bae:	2501                	sext.w	a0,a0
    80001bb0:	6422                	ld	s0,8(sp)
    80001bb2:	0141                	addi	sp,sp,16
    80001bb4:	8082                	ret

0000000080001bb6 <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu *mycpu(void) {
    80001bb6:	1141                	addi	sp,sp,-16
    80001bb8:	e422                	sd	s0,8(sp)
    80001bba:	0800                	addi	s0,sp,16
    80001bbc:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    80001bbe:	2781                	sext.w	a5,a5
    80001bc0:	079e                	slli	a5,a5,0x7
  return c;
}
    80001bc2:	00012517          	auipc	a0,0x12
    80001bc6:	cae50513          	addi	a0,a0,-850 # 80013870 <cpus>
    80001bca:	953e                	add	a0,a0,a5
    80001bcc:	6422                	ld	s0,8(sp)
    80001bce:	0141                	addi	sp,sp,16
    80001bd0:	8082                	ret

0000000080001bd2 <myproc>:

// Return the current struct proc *, or zero if none.
struct proc *myproc(void) {
    80001bd2:	1101                	addi	sp,sp,-32
    80001bd4:	ec06                	sd	ra,24(sp)
    80001bd6:	e822                	sd	s0,16(sp)
    80001bd8:	e426                	sd	s1,8(sp)
    80001bda:	1000                	addi	s0,sp,32
  push_off();
    80001bdc:	8a0ff0ef          	jal	80000c7c <push_off>
    80001be0:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    80001be2:	2781                	sext.w	a5,a5
    80001be4:	079e                	slli	a5,a5,0x7
    80001be6:	00012717          	auipc	a4,0x12
    80001bea:	c4270713          	addi	a4,a4,-958 # 80013828 <pid_lock>
    80001bee:	97ba                	add	a5,a5,a4
    80001bf0:	67a4                	ld	s1,72(a5)
  pop_off();
    80001bf2:	90eff0ef          	jal	80000d00 <pop_off>
  return p;
}
    80001bf6:	8526                	mv	a0,s1
    80001bf8:	60e2                	ld	ra,24(sp)
    80001bfa:	6442                	ld	s0,16(sp)
    80001bfc:	64a2                	ld	s1,8(sp)
    80001bfe:	6105                	addi	sp,sp,32
    80001c00:	8082                	ret

0000000080001c02 <forkret>:
  release(&p->lock);
}

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void forkret(void) {
    80001c02:	7179                	addi	sp,sp,-48
    80001c04:	f406                	sd	ra,40(sp)
    80001c06:	f022                	sd	s0,32(sp)
    80001c08:	ec26                	sd	s1,24(sp)
    80001c0a:	1800                	addi	s0,sp,48
  extern char userret[];
  static int first = 1;
  struct proc *p = myproc();
    80001c0c:	fc7ff0ef          	jal	80001bd2 <myproc>
    80001c10:	84aa                	mv	s1,a0

  // Still holding p->lock from scheduler.
  release(&p->lock);
    80001c12:	942ff0ef          	jal	80000d54 <release>

  if (first) {
    80001c16:	0000a797          	auipc	a5,0xa
    80001c1a:	a5a7a783          	lw	a5,-1446(a5) # 8000b670 <first.1>
    80001c1e:	cf8d                	beqz	a5,80001c58 <forkret+0x56>
    // File system initialization must be run in the context of a
    // regular process (e.g., because it calls sleep), and thus cannot
    // be run from main().
    fsinit(ROOTDEV);
    80001c20:	4505                	li	a0,1
    80001c22:	6a5010ef          	jal	80003ac6 <fsinit>

    first = 0;
    80001c26:	0000a797          	auipc	a5,0xa
    80001c2a:	a407a523          	sw	zero,-1462(a5) # 8000b670 <first.1>
    // ensure other cores see first=0.
    __sync_synchronize();
    80001c2e:	0330000f          	fence	rw,rw

    // We can invoke kexec() now that file system is initialized.
    // Put the return value (argc) of kexec into a0.
    p->trapframe->a0 = kexec("/init", (char *[]){"/init", 0});
    80001c32:	00006517          	auipc	a0,0x6
    80001c36:	56650513          	addi	a0,a0,1382 # 80008198 <etext+0x198>
    80001c3a:	fca43823          	sd	a0,-48(s0)
    80001c3e:	fc043c23          	sd	zero,-40(s0)
    80001c42:	fd040593          	addi	a1,s0,-48
    80001c46:	78b020ef          	jal	80004bd0 <kexec>
    80001c4a:	6cbc                	ld	a5,88(s1)
    80001c4c:	fba8                	sd	a0,112(a5)
    if (p->trapframe->a0 == -1) {
    80001c4e:	6cbc                	ld	a5,88(s1)
    80001c50:	7bb8                	ld	a4,112(a5)
    80001c52:	57fd                	li	a5,-1
    80001c54:	02f70d63          	beq	a4,a5,80001c8e <forkret+0x8c>
      panic("exec");
    }
  }

  // return to user space, mimicing usertrap()'s return.
  prepare_return();
    80001c58:	4d9000ef          	jal	80002930 <prepare_return>
  uint64 satp = MAKE_SATP(p->pagetable);
    80001c5c:	68a8                	ld	a0,80(s1)
    80001c5e:	8131                	srli	a0,a0,0xc
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    80001c60:	04000737          	lui	a4,0x4000
    80001c64:	177d                	addi	a4,a4,-1 # 3ffffff <_entry-0x7c000001>
    80001c66:	0732                	slli	a4,a4,0xc
    80001c68:	00005797          	auipc	a5,0x5
    80001c6c:	43478793          	addi	a5,a5,1076 # 8000709c <userret>
    80001c70:	00005697          	auipc	a3,0x5
    80001c74:	39068693          	addi	a3,a3,912 # 80007000 <_trampoline>
    80001c78:	8f95                	sub	a5,a5,a3
    80001c7a:	97ba                	add	a5,a5,a4
  ((void (*)(uint64))trampoline_userret)(satp);
    80001c7c:	577d                	li	a4,-1
    80001c7e:	177e                	slli	a4,a4,0x3f
    80001c80:	8d59                	or	a0,a0,a4
    80001c82:	9782                	jalr	a5
}
    80001c84:	70a2                	ld	ra,40(sp)
    80001c86:	7402                	ld	s0,32(sp)
    80001c88:	64e2                	ld	s1,24(sp)
    80001c8a:	6145                	addi	sp,sp,48
    80001c8c:	8082                	ret
      panic("exec");
    80001c8e:	00006517          	auipc	a0,0x6
    80001c92:	51250513          	addi	a0,a0,1298 # 800081a0 <etext+0x1a0>
    80001c96:	b7dfe0ef          	jal	80000812 <panic>

0000000080001c9a <allocpid>:
int allocpid() {
    80001c9a:	1101                	addi	sp,sp,-32
    80001c9c:	ec06                	sd	ra,24(sp)
    80001c9e:	e822                	sd	s0,16(sp)
    80001ca0:	e426                	sd	s1,8(sp)
    80001ca2:	e04a                	sd	s2,0(sp)
    80001ca4:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80001ca6:	00012917          	auipc	s2,0x12
    80001caa:	b8290913          	addi	s2,s2,-1150 # 80013828 <pid_lock>
    80001cae:	854a                	mv	a0,s2
    80001cb0:	80cff0ef          	jal	80000cbc <acquire>
  pid = nextpid;
    80001cb4:	0000a797          	auipc	a5,0xa
    80001cb8:	9c078793          	addi	a5,a5,-1600 # 8000b674 <nextpid>
    80001cbc:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80001cbe:	0014871b          	addiw	a4,s1,1
    80001cc2:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001cc4:	854a                	mv	a0,s2
    80001cc6:	88eff0ef          	jal	80000d54 <release>
}
    80001cca:	8526                	mv	a0,s1
    80001ccc:	60e2                	ld	ra,24(sp)
    80001cce:	6442                	ld	s0,16(sp)
    80001cd0:	64a2                	ld	s1,8(sp)
    80001cd2:	6902                	ld	s2,0(sp)
    80001cd4:	6105                	addi	sp,sp,32
    80001cd6:	8082                	ret

0000000080001cd8 <proc_pagetable>:
pagetable_t proc_pagetable(struct proc *p) {
    80001cd8:	1101                	addi	sp,sp,-32
    80001cda:	ec06                	sd	ra,24(sp)
    80001cdc:	e822                	sd	s0,16(sp)
    80001cde:	e426                	sd	s1,8(sp)
    80001ce0:	e04a                	sd	s2,0(sp)
    80001ce2:	1000                	addi	s0,sp,32
    80001ce4:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001ce6:	e2eff0ef          	jal	80001314 <uvmcreate>
    80001cea:	84aa                	mv	s1,a0
  if (pagetable == 0)
    80001cec:	cd05                	beqz	a0,80001d24 <proc_pagetable+0x4c>
  if (mappages(pagetable, TRAMPOLINE, PGSIZE, (uint64)trampoline,
    80001cee:	4729                	li	a4,10
    80001cf0:	00005697          	auipc	a3,0x5
    80001cf4:	31068693          	addi	a3,a3,784 # 80007000 <_trampoline>
    80001cf8:	6605                	lui	a2,0x1
    80001cfa:	040005b7          	lui	a1,0x4000
    80001cfe:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001d00:	05b2                	slli	a1,a1,0xc
    80001d02:	be6ff0ef          	jal	800010e8 <mappages>
    80001d06:	02054663          	bltz	a0,80001d32 <proc_pagetable+0x5a>
  if (mappages(pagetable, TRAPFRAME, PGSIZE, (uint64)(p->trapframe),
    80001d0a:	4719                	li	a4,6
    80001d0c:	05893683          	ld	a3,88(s2)
    80001d10:	6605                	lui	a2,0x1
    80001d12:	020005b7          	lui	a1,0x2000
    80001d16:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001d18:	05b6                	slli	a1,a1,0xd
    80001d1a:	8526                	mv	a0,s1
    80001d1c:	bccff0ef          	jal	800010e8 <mappages>
    80001d20:	00054f63          	bltz	a0,80001d3e <proc_pagetable+0x66>
}
    80001d24:	8526                	mv	a0,s1
    80001d26:	60e2                	ld	ra,24(sp)
    80001d28:	6442                	ld	s0,16(sp)
    80001d2a:	64a2                	ld	s1,8(sp)
    80001d2c:	6902                	ld	s2,0(sp)
    80001d2e:	6105                	addi	sp,sp,32
    80001d30:	8082                	ret
    uvmfree(pagetable, 0);
    80001d32:	4581                	li	a1,0
    80001d34:	8526                	mv	a0,s1
    80001d36:	8ebff0ef          	jal	80001620 <uvmfree>
    return 0;
    80001d3a:	4481                	li	s1,0
    80001d3c:	b7e5                	j	80001d24 <proc_pagetable+0x4c>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001d3e:	4681                	li	a3,0
    80001d40:	4605                	li	a2,1
    80001d42:	040005b7          	lui	a1,0x4000
    80001d46:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001d48:	05b2                	slli	a1,a1,0xc
    80001d4a:	8526                	mv	a0,s1
    80001d4c:	deeff0ef          	jal	8000133a <uvmunmap>
    uvmfree(pagetable, 0);
    80001d50:	4581                	li	a1,0
    80001d52:	8526                	mv	a0,s1
    80001d54:	8cdff0ef          	jal	80001620 <uvmfree>
    return 0;
    80001d58:	4481                	li	s1,0
    80001d5a:	b7e9                	j	80001d24 <proc_pagetable+0x4c>

0000000080001d5c <proc_freepagetable>:
void proc_freepagetable(pagetable_t pagetable, uint64 sz) {
    80001d5c:	1101                	addi	sp,sp,-32
    80001d5e:	ec06                	sd	ra,24(sp)
    80001d60:	e822                	sd	s0,16(sp)
    80001d62:	e426                	sd	s1,8(sp)
    80001d64:	e04a                	sd	s2,0(sp)
    80001d66:	1000                	addi	s0,sp,32
    80001d68:	84aa                	mv	s1,a0
    80001d6a:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001d6c:	4681                	li	a3,0
    80001d6e:	4605                	li	a2,1
    80001d70:	040005b7          	lui	a1,0x4000
    80001d74:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001d76:	05b2                	slli	a1,a1,0xc
    80001d78:	dc2ff0ef          	jal	8000133a <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001d7c:	4681                	li	a3,0
    80001d7e:	4605                	li	a2,1
    80001d80:	020005b7          	lui	a1,0x2000
    80001d84:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001d86:	05b6                	slli	a1,a1,0xd
    80001d88:	8526                	mv	a0,s1
    80001d8a:	db0ff0ef          	jal	8000133a <uvmunmap>
  uvmfree(pagetable, sz);
    80001d8e:	85ca                	mv	a1,s2
    80001d90:	8526                	mv	a0,s1
    80001d92:	88fff0ef          	jal	80001620 <uvmfree>
}
    80001d96:	60e2                	ld	ra,24(sp)
    80001d98:	6442                	ld	s0,16(sp)
    80001d9a:	64a2                	ld	s1,8(sp)
    80001d9c:	6902                	ld	s2,0(sp)
    80001d9e:	6105                	addi	sp,sp,32
    80001da0:	8082                	ret

0000000080001da2 <freeproc>:
static void freeproc(struct proc *p) {
    80001da2:	1101                	addi	sp,sp,-32
    80001da4:	ec06                	sd	ra,24(sp)
    80001da6:	e822                	sd	s0,16(sp)
    80001da8:	e426                	sd	s1,8(sp)
    80001daa:	1000                	addi	s0,sp,32
    80001dac:	84aa                	mv	s1,a0
  if (p->trapframe)
    80001dae:	6d28                	ld	a0,88(a0)
    80001db0:	c119                	beqz	a0,80001db6 <freeproc+0x14>
    kfree((void *)p->trapframe);
    80001db2:	c9dfe0ef          	jal	80000a4e <kfree>
  p->trapframe = 0;
    80001db6:	0404bc23          	sd	zero,88(s1)
  if (p->pagetable)
    80001dba:	68a8                	ld	a0,80(s1)
    80001dbc:	c501                	beqz	a0,80001dc4 <freeproc+0x22>
    proc_freepagetable(p->pagetable, p->sz);
    80001dbe:	64ac                	ld	a1,72(s1)
    80001dc0:	f9dff0ef          	jal	80001d5c <proc_freepagetable>
  p->pagetable = 0;
    80001dc4:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    80001dc8:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    80001dcc:	0204a823          	sw	zero,48(s1)
  p->parent = 0;
    80001dd0:	0204bc23          	sd	zero,56(s1)
  p->name[0] = 0;
    80001dd4:	14048c23          	sb	zero,344(s1)
  p->chan = 0;
    80001dd8:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    80001ddc:	0204a423          	sw	zero,40(s1)
  p->xstate = 0;
    80001de0:	0204a623          	sw	zero,44(s1)
  p->state = UNUSED;
    80001de4:	0004ac23          	sw	zero,24(s1)
}
    80001de8:	60e2                	ld	ra,24(sp)
    80001dea:	6442                	ld	s0,16(sp)
    80001dec:	64a2                	ld	s1,8(sp)
    80001dee:	6105                	addi	sp,sp,32
    80001df0:	8082                	ret

0000000080001df2 <allocproc>:
static struct proc *allocproc(void) {
    80001df2:	1101                	addi	sp,sp,-32
    80001df4:	ec06                	sd	ra,24(sp)
    80001df6:	e822                	sd	s0,16(sp)
    80001df8:	e426                	sd	s1,8(sp)
    80001dfa:	e04a                	sd	s2,0(sp)
    80001dfc:	1000                	addi	s0,sp,32
  for (p = proc; p < &proc[NPROC]; p++) {
    80001dfe:	00012497          	auipc	s1,0x12
    80001e02:	e7248493          	addi	s1,s1,-398 # 80013c70 <proc>
    80001e06:	00018917          	auipc	s2,0x18
    80001e0a:	86a90913          	addi	s2,s2,-1942 # 80019670 <tickslock>
    acquire(&p->lock);
    80001e0e:	8526                	mv	a0,s1
    80001e10:	eadfe0ef          	jal	80000cbc <acquire>
    if (p->state == UNUSED) {
    80001e14:	4c9c                	lw	a5,24(s1)
    80001e16:	cb91                	beqz	a5,80001e2a <allocproc+0x38>
      release(&p->lock);
    80001e18:	8526                	mv	a0,s1
    80001e1a:	f3bfe0ef          	jal	80000d54 <release>
  for (p = proc; p < &proc[NPROC]; p++) {
    80001e1e:	16848493          	addi	s1,s1,360
    80001e22:	ff2496e3          	bne	s1,s2,80001e0e <allocproc+0x1c>
  return 0;
    80001e26:	4481                	li	s1,0
    80001e28:	a089                	j	80001e6a <allocproc+0x78>
  p->pid = allocpid();
    80001e2a:	e71ff0ef          	jal	80001c9a <allocpid>
    80001e2e:	d888                	sw	a0,48(s1)
  p->state = USED;
    80001e30:	4785                	li	a5,1
    80001e32:	cc9c                	sw	a5,24(s1)
  if ((p->trapframe = (struct trapframe *)kalloc()) == 0) {
    80001e34:	d5bfe0ef          	jal	80000b8e <kalloc>
    80001e38:	892a                	mv	s2,a0
    80001e3a:	eca8                	sd	a0,88(s1)
    80001e3c:	cd15                	beqz	a0,80001e78 <allocproc+0x86>
  p->pagetable = proc_pagetable(p);
    80001e3e:	8526                	mv	a0,s1
    80001e40:	e99ff0ef          	jal	80001cd8 <proc_pagetable>
    80001e44:	892a                	mv	s2,a0
    80001e46:	e8a8                	sd	a0,80(s1)
  if (p->pagetable == 0) {
    80001e48:	c121                	beqz	a0,80001e88 <allocproc+0x96>
  memset(&p->context, 0, sizeof(p->context));
    80001e4a:	07000613          	li	a2,112
    80001e4e:	4581                	li	a1,0
    80001e50:	06048513          	addi	a0,s1,96
    80001e54:	f3dfe0ef          	jal	80000d90 <memset>
  p->context.ra = (uint64)forkret;
    80001e58:	00000797          	auipc	a5,0x0
    80001e5c:	daa78793          	addi	a5,a5,-598 # 80001c02 <forkret>
    80001e60:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001e62:	60bc                	ld	a5,64(s1)
    80001e64:	6705                	lui	a4,0x1
    80001e66:	97ba                	add	a5,a5,a4
    80001e68:	f4bc                	sd	a5,104(s1)
}
    80001e6a:	8526                	mv	a0,s1
    80001e6c:	60e2                	ld	ra,24(sp)
    80001e6e:	6442                	ld	s0,16(sp)
    80001e70:	64a2                	ld	s1,8(sp)
    80001e72:	6902                	ld	s2,0(sp)
    80001e74:	6105                	addi	sp,sp,32
    80001e76:	8082                	ret
    freeproc(p);
    80001e78:	8526                	mv	a0,s1
    80001e7a:	f29ff0ef          	jal	80001da2 <freeproc>
    release(&p->lock);
    80001e7e:	8526                	mv	a0,s1
    80001e80:	ed5fe0ef          	jal	80000d54 <release>
    return 0;
    80001e84:	84ca                	mv	s1,s2
    80001e86:	b7d5                	j	80001e6a <allocproc+0x78>
    freeproc(p);
    80001e88:	8526                	mv	a0,s1
    80001e8a:	f19ff0ef          	jal	80001da2 <freeproc>
    release(&p->lock);
    80001e8e:	8526                	mv	a0,s1
    80001e90:	ec5fe0ef          	jal	80000d54 <release>
    return 0;
    80001e94:	84ca                	mv	s1,s2
    80001e96:	bfd1                	j	80001e6a <allocproc+0x78>

0000000080001e98 <userinit>:
void userinit(void) {
    80001e98:	1101                	addi	sp,sp,-32
    80001e9a:	ec06                	sd	ra,24(sp)
    80001e9c:	e822                	sd	s0,16(sp)
    80001e9e:	e426                	sd	s1,8(sp)
    80001ea0:	1000                	addi	s0,sp,32
  p = allocproc();
    80001ea2:	f51ff0ef          	jal	80001df2 <allocproc>
    80001ea6:	84aa                	mv	s1,a0
  initproc = p;
    80001ea8:	0000a797          	auipc	a5,0xa
    80001eac:	82a7b023          	sd	a0,-2016(a5) # 8000b6c8 <initproc>
  p->cwd = namei("/");
    80001eb0:	00006517          	auipc	a0,0x6
    80001eb4:	2f850513          	addi	a0,a0,760 # 800081a8 <etext+0x1a8>
    80001eb8:	130020ef          	jal	80003fe8 <namei>
    80001ebc:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    80001ec0:	478d                	li	a5,3
    80001ec2:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001ec4:	8526                	mv	a0,s1
    80001ec6:	e8ffe0ef          	jal	80000d54 <release>
}
    80001eca:	60e2                	ld	ra,24(sp)
    80001ecc:	6442                	ld	s0,16(sp)
    80001ece:	64a2                	ld	s1,8(sp)
    80001ed0:	6105                	addi	sp,sp,32
    80001ed2:	8082                	ret

0000000080001ed4 <growproc>:
int growproc(int n) {
    80001ed4:	7135                	addi	sp,sp,-160
    80001ed6:	ed06                	sd	ra,152(sp)
    80001ed8:	e922                	sd	s0,144(sp)
    80001eda:	e526                	sd	s1,136(sp)
    80001edc:	e14a                	sd	s2,128(sp)
    80001ede:	fcce                	sd	s3,120(sp)
    80001ee0:	1100                	addi	s0,sp,160
    80001ee2:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80001ee4:	cefff0ef          	jal	80001bd2 <myproc>
    80001ee8:	89aa                	mv	s3,a0
  sz = p->sz;
    80001eea:	04853903          	ld	s2,72(a0)
  if (n > 0) {
    80001eee:	02905b63          	blez	s1,80001f24 <growproc+0x50>
    if (sz + n > TRAPFRAME) {
    80001ef2:	01248633          	add	a2,s1,s2
    80001ef6:	020007b7          	lui	a5,0x2000
    80001efa:	17fd                	addi	a5,a5,-1 # 1ffffff <_entry-0x7e000001>
    80001efc:	07b6                	slli	a5,a5,0xd
    80001efe:	08c7ee63          	bltu	a5,a2,80001f9a <growproc+0xc6>
    if ((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0) {
    80001f02:	4691                	li	a3,4
    80001f04:	85ca                	mv	a1,s2
    80001f06:	6928                	ld	a0,80(a0)
    80001f08:	d96ff0ef          	jal	8000149e <uvmalloc>
    80001f0c:	892a                	mv	s2,a0
    80001f0e:	c941                	beqz	a0,80001f9e <growproc+0xca>
  p->sz = sz;
    80001f10:	0529b423          	sd	s2,72(s3)
  return 0;
    80001f14:	4501                	li	a0,0
}
    80001f16:	60ea                	ld	ra,152(sp)
    80001f18:	644a                	ld	s0,144(sp)
    80001f1a:	64aa                	ld	s1,136(sp)
    80001f1c:	690a                	ld	s2,128(sp)
    80001f1e:	79e6                	ld	s3,120(sp)
    80001f20:	610d                	addi	sp,sp,160
    80001f22:	8082                	ret
  } else if (n < 0) {
    80001f24:	fe04d6e3          	bgez	s1,80001f10 <growproc+0x3c>
  memset(&e, 0, sizeof(e));
    80001f28:	06800613          	li	a2,104
    80001f2c:	4581                	li	a1,0
    80001f2e:	f6840513          	addi	a0,s0,-152
    80001f32:	e5ffe0ef          	jal	80000d90 <memset>
  e.ticks  = ticks;
    80001f36:	00009797          	auipc	a5,0x9
    80001f3a:	79a7a783          	lw	a5,1946(a5) # 8000b6d0 <ticks>
    80001f3e:	f6f42823          	sw	a5,-144(s0)
    80001f42:	8792                	mv	a5,tp
  int id = r_tp();
    80001f44:	f6f42a23          	sw	a5,-140(s0)
  e.type   = MEM_SHRINK;
    80001f48:	4789                	li	a5,2
    80001f4a:	f6f42c23          	sw	a5,-136(s0)
  e.pid    = p->pid;
    80001f4e:	0309a783          	lw	a5,48(s3)
    80001f52:	f6f42e23          	sw	a5,-132(s0)
  e.state  = p->state;
    80001f56:	0189a783          	lw	a5,24(s3)
    80001f5a:	f8f42023          	sw	a5,-128(s0)
  e.oldsz  = sz;
    80001f5e:	fb243423          	sd	s2,-88(s0)
  e.newsz  = sz + n;
    80001f62:	94ca                	add	s1,s1,s2
    80001f64:	fa943823          	sd	s1,-80(s0)
  e.source = SRC_UVMDEALLOC;
    80001f68:	4799                	li	a5,6
    80001f6a:	fcf42223          	sw	a5,-60(s0)
  e.kind   = PAGE_USER;
    80001f6e:	4785                	li	a5,1
    80001f70:	fcf42423          	sw	a5,-56(s0)
  safestrcpy(e.name, p->name, MEM_NM);
    80001f74:	4641                	li	a2,16
    80001f76:	15898593          	addi	a1,s3,344
    80001f7a:	f8440513          	addi	a0,s0,-124
    80001f7e:	f51fe0ef          	jal	80000ece <safestrcpy>
  memlog_push(&e);
    80001f82:	f6840513          	addi	a0,s0,-152
    80001f86:	4cc040ef          	jal	80006452 <memlog_push>
  sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001f8a:	8626                	mv	a2,s1
    80001f8c:	85ca                	mv	a1,s2
    80001f8e:	0509b503          	ld	a0,80(s3)
    80001f92:	cc8ff0ef          	jal	8000145a <uvmdealloc>
    80001f96:	892a                	mv	s2,a0
    80001f98:	bfa5                	j	80001f10 <growproc+0x3c>
      return -1;
    80001f9a:	557d                	li	a0,-1
    80001f9c:	bfad                	j	80001f16 <growproc+0x42>
      return -1;
    80001f9e:	557d                	li	a0,-1
    80001fa0:	bf9d                	j	80001f16 <growproc+0x42>

0000000080001fa2 <kfork>:
int kfork(void) {
    80001fa2:	7139                	addi	sp,sp,-64
    80001fa4:	fc06                	sd	ra,56(sp)
    80001fa6:	f822                	sd	s0,48(sp)
    80001fa8:	f04a                	sd	s2,32(sp)
    80001faa:	e456                	sd	s5,8(sp)
    80001fac:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    80001fae:	c25ff0ef          	jal	80001bd2 <myproc>
    80001fb2:	8aaa                	mv	s5,a0
  if ((np = allocproc()) == 0) {
    80001fb4:	e3fff0ef          	jal	80001df2 <allocproc>
    80001fb8:	0e050a63          	beqz	a0,800020ac <kfork+0x10a>
    80001fbc:	e852                	sd	s4,16(sp)
    80001fbe:	8a2a                	mv	s4,a0
  if (uvmcopy(p->pagetable, np->pagetable, p->sz) < 0) {
    80001fc0:	048ab603          	ld	a2,72(s5)
    80001fc4:	692c                	ld	a1,80(a0)
    80001fc6:	050ab503          	ld	a0,80(s5)
    80001fca:	e88ff0ef          	jal	80001652 <uvmcopy>
    80001fce:	04054a63          	bltz	a0,80002022 <kfork+0x80>
    80001fd2:	f426                	sd	s1,40(sp)
    80001fd4:	ec4e                	sd	s3,24(sp)
  np->sz = p->sz;
    80001fd6:	048ab783          	ld	a5,72(s5)
    80001fda:	04fa3423          	sd	a5,72(s4)
  *(np->trapframe) = *(p->trapframe);
    80001fde:	058ab683          	ld	a3,88(s5)
    80001fe2:	87b6                	mv	a5,a3
    80001fe4:	058a3703          	ld	a4,88(s4)
    80001fe8:	12068693          	addi	a3,a3,288
    80001fec:	0007b803          	ld	a6,0(a5)
    80001ff0:	6788                	ld	a0,8(a5)
    80001ff2:	6b8c                	ld	a1,16(a5)
    80001ff4:	6f90                	ld	a2,24(a5)
    80001ff6:	01073023          	sd	a6,0(a4) # 1000 <_entry-0x7ffff000>
    80001ffa:	e708                	sd	a0,8(a4)
    80001ffc:	eb0c                	sd	a1,16(a4)
    80001ffe:	ef10                	sd	a2,24(a4)
    80002000:	02078793          	addi	a5,a5,32
    80002004:	02070713          	addi	a4,a4,32
    80002008:	fed792e3          	bne	a5,a3,80001fec <kfork+0x4a>
  np->trapframe->a0 = 0;
    8000200c:	058a3783          	ld	a5,88(s4)
    80002010:	0607b823          	sd	zero,112(a5)
  for (i = 0; i < NOFILE; i++)
    80002014:	0d0a8493          	addi	s1,s5,208
    80002018:	0d0a0913          	addi	s2,s4,208
    8000201c:	150a8993          	addi	s3,s5,336
    80002020:	a831                	j	8000203c <kfork+0x9a>
    freeproc(np);
    80002022:	8552                	mv	a0,s4
    80002024:	d7fff0ef          	jal	80001da2 <freeproc>
    release(&np->lock);
    80002028:	8552                	mv	a0,s4
    8000202a:	d2bfe0ef          	jal	80000d54 <release>
    return -1;
    8000202e:	597d                	li	s2,-1
    80002030:	6a42                	ld	s4,16(sp)
    80002032:	a0b5                	j	8000209e <kfork+0xfc>
  for (i = 0; i < NOFILE; i++)
    80002034:	04a1                	addi	s1,s1,8
    80002036:	0921                	addi	s2,s2,8
    80002038:	01348963          	beq	s1,s3,8000204a <kfork+0xa8>
    if (p->ofile[i])
    8000203c:	6088                	ld	a0,0(s1)
    8000203e:	d97d                	beqz	a0,80002034 <kfork+0x92>
      np->ofile[i] = filedup(p->ofile[i]);
    80002040:	542020ef          	jal	80004582 <filedup>
    80002044:	00a93023          	sd	a0,0(s2)
    80002048:	b7f5                	j	80002034 <kfork+0x92>
  np->cwd = idup(p->cwd);
    8000204a:	150ab503          	ld	a0,336(s5)
    8000204e:	74e010ef          	jal	8000379c <idup>
    80002052:	14aa3823          	sd	a0,336(s4)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80002056:	4641                	li	a2,16
    80002058:	158a8593          	addi	a1,s5,344
    8000205c:	158a0513          	addi	a0,s4,344
    80002060:	e6ffe0ef          	jal	80000ece <safestrcpy>
  pid = np->pid;
    80002064:	030a2903          	lw	s2,48(s4)
  release(&np->lock);
    80002068:	8552                	mv	a0,s4
    8000206a:	cebfe0ef          	jal	80000d54 <release>
  acquire(&wait_lock);
    8000206e:	00011497          	auipc	s1,0x11
    80002072:	7d248493          	addi	s1,s1,2002 # 80013840 <wait_lock>
    80002076:	8526                	mv	a0,s1
    80002078:	c45fe0ef          	jal	80000cbc <acquire>
  np->parent = p;
    8000207c:	035a3c23          	sd	s5,56(s4)
  release(&wait_lock);
    80002080:	8526                	mv	a0,s1
    80002082:	cd3fe0ef          	jal	80000d54 <release>
  acquire(&np->lock);
    80002086:	8552                	mv	a0,s4
    80002088:	c35fe0ef          	jal	80000cbc <acquire>
  np->state = RUNNABLE;
    8000208c:	478d                	li	a5,3
    8000208e:	00fa2c23          	sw	a5,24(s4)
  release(&np->lock);
    80002092:	8552                	mv	a0,s4
    80002094:	cc1fe0ef          	jal	80000d54 <release>
  return pid;
    80002098:	74a2                	ld	s1,40(sp)
    8000209a:	69e2                	ld	s3,24(sp)
    8000209c:	6a42                	ld	s4,16(sp)
}
    8000209e:	854a                	mv	a0,s2
    800020a0:	70e2                	ld	ra,56(sp)
    800020a2:	7442                	ld	s0,48(sp)
    800020a4:	7902                	ld	s2,32(sp)
    800020a6:	6aa2                	ld	s5,8(sp)
    800020a8:	6121                	addi	sp,sp,64
    800020aa:	8082                	ret
    return -1;
    800020ac:	597d                	li	s2,-1
    800020ae:	bfc5                	j	8000209e <kfork+0xfc>

00000000800020b0 <scheduler>:
void scheduler(void) {
    800020b0:	7135                	addi	sp,sp,-160
    800020b2:	ed06                	sd	ra,152(sp)
    800020b4:	e922                	sd	s0,144(sp)
    800020b6:	e526                	sd	s1,136(sp)
    800020b8:	e14a                	sd	s2,128(sp)
    800020ba:	fcce                	sd	s3,120(sp)
    800020bc:	f8d2                	sd	s4,112(sp)
    800020be:	f4d6                	sd	s5,104(sp)
    800020c0:	f0da                	sd	s6,96(sp)
    800020c2:	ecde                	sd	s7,88(sp)
    800020c4:	1100                	addi	s0,sp,160
    800020c6:	8492                	mv	s1,tp
  int id = r_tp();
    800020c8:	2481                	sext.w	s1,s1
    800020ca:	8792                	mv	a5,tp
    if(cpuid() == 0){
    800020cc:	2781                	sext.w	a5,a5
    800020ce:	cb95                	beqz	a5,80002102 <scheduler+0x52>
  c->proc = 0;
    800020d0:	00749a13          	slli	s4,s1,0x7
    800020d4:	00011797          	auipc	a5,0x11
    800020d8:	75478793          	addi	a5,a5,1876 # 80013828 <pid_lock>
    800020dc:	97d2                	add	a5,a5,s4
    800020de:	0407b423          	sd	zero,72(a5)
        swtch(&c->context, &p->context);
    800020e2:	00011797          	auipc	a5,0x11
    800020e6:	79678793          	addi	a5,a5,1942 # 80013878 <cpus+0x8>
    800020ea:	9a3e                	add	s4,s4,a5
        c->proc = p;
    800020ec:	049e                	slli	s1,s1,0x7
    800020ee:	00011997          	auipc	s3,0x11
    800020f2:	73a98993          	addi	s3,s3,1850 # 80013828 <pid_lock>
    800020f6:	99a6                	add	s3,s3,s1
          e2.ticks = ticks;
    800020f8:	00009a97          	auipc	s5,0x9
    800020fc:	5d8a8a93          	addi	s5,s5,1496 # 8000b6d0 <ticks>
    80002100:	a2dd                	j	800022e6 <scheduler+0x236>
      acquire(&schedinfo_lock);
    80002102:	00011517          	auipc	a0,0x11
    80002106:	75650513          	addi	a0,a0,1878 # 80013858 <schedinfo_lock>
    8000210a:	bb3fe0ef          	jal	80000cbc <acquire>
      if(sched_info_logged == 0){
    8000210e:	00009797          	auipc	a5,0x9
    80002112:	5b27a783          	lw	a5,1458(a5) # 8000b6c0 <sched_info_logged>
    80002116:	cb81                	beqz	a5,80002126 <scheduler+0x76>
      release(&schedinfo_lock);
    80002118:	00011517          	auipc	a0,0x11
    8000211c:	74050513          	addi	a0,a0,1856 # 80013858 <schedinfo_lock>
    80002120:	c35fe0ef          	jal	80000d54 <release>
    80002124:	b775                	j	800020d0 <scheduler+0x20>
        sched_info_logged = 1;
    80002126:	4905                	li	s2,1
    80002128:	00009797          	auipc	a5,0x9
    8000212c:	5927ac23          	sw	s2,1432(a5) # 8000b6c0 <sched_info_logged>
        memset(&e, 0, sizeof(e));
    80002130:	04400613          	li	a2,68
    80002134:	4581                	li	a1,0
    80002136:	f6840513          	addi	a0,s0,-152
    8000213a:	c57fe0ef          	jal	80000d90 <memset>
        e.ticks = ticks;
    8000213e:	00009797          	auipc	a5,0x9
    80002142:	5927a783          	lw	a5,1426(a5) # 8000b6d0 <ticks>
    80002146:	f6f42623          	sw	a5,-148(s0)
        e.event_type = SCHED_EV_INFO;
    8000214a:	f7242823          	sw	s2,-144(s0)
        safestrcpy(e.scheduler_name, "RR", sizeof(e.scheduler_name));
    8000214e:	4641                	li	a2,16
    80002150:	00006597          	auipc	a1,0x6
    80002154:	06058593          	addi	a1,a1,96 # 800081b0 <etext+0x1b0>
    80002158:	f7440513          	addi	a0,s0,-140
    8000215c:	d73fe0ef          	jal	80000ece <safestrcpy>
        e.num_cpus = 3;
    80002160:	478d                	li	a5,3
    80002162:	f8f42223          	sw	a5,-124(s0)
        e.time_slice = 1;
    80002166:	f9242423          	sw	s2,-120(s0)
        schedlog_emit(&e);
    8000216a:	f6840513          	addi	a0,s0,-152
    8000216e:	54c040ef          	jal	800066ba <schedlog_emit>
    80002172:	b75d                	j	80002118 <scheduler+0x68>
    80002174:	8ba6                	mv	s7,s1
        if(strncmp(p->name, "schedexport", 16) != 0){
    80002176:	15848913          	addi	s2,s1,344
    8000217a:	4641                	li	a2,16
    8000217c:	00006597          	auipc	a1,0x6
    80002180:	03c58593          	addi	a1,a1,60 # 800081b8 <etext+0x1b8>
    80002184:	854a                	mv	a0,s2
    80002186:	cd7fe0ef          	jal	80000e5c <strncmp>
    8000218a:	e54d                	bnez	a0,80002234 <scheduler+0x184>
        swtch(&c->context, &p->context);
    8000218c:	060b8593          	addi	a1,s7,96 # 1060 <_entry-0x7fffefa0>
    80002190:	8552                	mv	a0,s4
    80002192:	6f8000ef          	jal	8000288a <swtch>
        if(strncmp(p->name, "schedexport", 16) != 0){
    80002196:	4641                	li	a2,16
    80002198:	00006597          	auipc	a1,0x6
    8000219c:	02058593          	addi	a1,a1,32 # 800081b8 <etext+0x1b8>
    800021a0:	854a                	mv	a0,s2
    800021a2:	cbbfe0ef          	jal	80000e5c <strncmp>
    800021a6:	e969                	bnez	a0,80002278 <scheduler+0x1c8>
        c->proc = 0;
    800021a8:	0409b423          	sd	zero,72(s3)
        found = 1;
    800021ac:	4905                	li	s2,1
      release(&p->lock);
    800021ae:	8526                	mv	a0,s1
    800021b0:	ba5fe0ef          	jal	80000d54 <release>
    for (p = proc; p < &proc[NPROC]; p++) {
    800021b4:	16848493          	addi	s1,s1,360
    800021b8:	00017797          	auipc	a5,0x17
    800021bc:	4b878793          	addi	a5,a5,1208 # 80019670 <tickslock>
    800021c0:	10f48f63          	beq	s1,a5,800022de <scheduler+0x22e>
      acquire(&p->lock);
    800021c4:	8526                	mv	a0,s1
    800021c6:	af7fe0ef          	jal	80000cbc <acquire>
      if (p->state == RUNNABLE) {
    800021ca:	4c98                	lw	a4,24(s1)
    800021cc:	478d                	li	a5,3
    800021ce:	fef710e3          	bne	a4,a5,800021ae <scheduler+0xfe>
        p->state = RUNNING;
    800021d2:	4791                	li	a5,4
    800021d4:	cc9c                	sw	a5,24(s1)
        c->proc = p;
    800021d6:	0499b423          	sd	s1,72(s3)
        cslog_run_start(p);
    800021da:	8526                	mv	a0,s1
    800021dc:	625030ef          	jal	80006000 <cslog_run_start>
    800021e0:	8792                	mv	a5,tp
        if (cpuid() == 0 && sched_info_logged == 0) {
    800021e2:	2781                	sext.w	a5,a5
    800021e4:	fbc1                	bnez	a5,80002174 <scheduler+0xc4>
    800021e6:	000b2783          	lw	a5,0(s6)
    800021ea:	2781                	sext.w	a5,a5
    800021ec:	f7c1                	bnez	a5,80002174 <scheduler+0xc4>
          sched_info_logged = 1;
    800021ee:	4905                	li	s2,1
    800021f0:	012b2023          	sw	s2,0(s6)
          memset(&e, 0, sizeof(e));
    800021f4:	04400613          	li	a2,68
    800021f8:	4581                	li	a1,0
    800021fa:	f6840513          	addi	a0,s0,-152
    800021fe:	b93fe0ef          	jal	80000d90 <memset>
          e.ticks = ticks;
    80002202:	000aa783          	lw	a5,0(s5)
    80002206:	f6f42623          	sw	a5,-148(s0)
          e.event_type = SCHED_EV_INFO;
    8000220a:	f7242823          	sw	s2,-144(s0)
          safestrcpy(e.scheduler_name, "RR", sizeof(e.scheduler_name));
    8000220e:	4641                	li	a2,16
    80002210:	00006597          	auipc	a1,0x6
    80002214:	fa058593          	addi	a1,a1,-96 # 800081b0 <etext+0x1b0>
    80002218:	f7440513          	addi	a0,s0,-140
    8000221c:	cb3fe0ef          	jal	80000ece <safestrcpy>
          e.num_cpus = NCPU;
    80002220:	47a1                	li	a5,8
    80002222:	f8f42223          	sw	a5,-124(s0)
          e.time_slice = 1;
    80002226:	f9242423          	sw	s2,-120(s0)
          schedlog_emit(&e);
    8000222a:	f6840513          	addi	a0,s0,-152
    8000222e:	48c040ef          	jal	800066ba <schedlog_emit>
    80002232:	b789                	j	80002174 <scheduler+0xc4>
          memset(&e, 0, sizeof(e));
    80002234:	04400613          	li	a2,68
    80002238:	4581                	li	a1,0
    8000223a:	f6840513          	addi	a0,s0,-152
    8000223e:	b53fe0ef          	jal	80000d90 <memset>
          e.ticks = ticks;
    80002242:	000aa783          	lw	a5,0(s5)
    80002246:	f6f42623          	sw	a5,-148(s0)
          e.event_type = SCHED_EV_ON_CPU;
    8000224a:	4789                	li	a5,2
    8000224c:	f6f42823          	sw	a5,-144(s0)
    80002250:	8792                	mv	a5,tp
  int id = r_tp();
    80002252:	f8f42623          	sw	a5,-116(s0)
          e.pid = p->pid;
    80002256:	589c                	lw	a5,48(s1)
    80002258:	f8f42823          	sw	a5,-112(s0)
          safestrcpy(e.name, p->name, sizeof(e.name));
    8000225c:	4641                	li	a2,16
    8000225e:	85ca                	mv	a1,s2
    80002260:	f9440513          	addi	a0,s0,-108
    80002264:	c6bfe0ef          	jal	80000ece <safestrcpy>
          e.state = p->state;
    80002268:	4c9c                	lw	a5,24(s1)
    8000226a:	faf42223          	sw	a5,-92(s0)
          schedlog_emit(&e);
    8000226e:	f6840513          	addi	a0,s0,-152
    80002272:	448040ef          	jal	800066ba <schedlog_emit>
    80002276:	bf19                	j	8000218c <scheduler+0xdc>
          memset(&e2, 0, sizeof(e2));
    80002278:	04400613          	li	a2,68
    8000227c:	4581                	li	a1,0
    8000227e:	f6840513          	addi	a0,s0,-152
    80002282:	b0ffe0ef          	jal	80000d90 <memset>
          e2.ticks = ticks;
    80002286:	000aa783          	lw	a5,0(s5)
    8000228a:	f6f42623          	sw	a5,-148(s0)
          e2.event_type = SCHED_EV_OFF_CPU;
    8000228e:	478d                	li	a5,3
    80002290:	f6f42823          	sw	a5,-144(s0)
    80002294:	8792                	mv	a5,tp
  int id = r_tp();
    80002296:	f8f42623          	sw	a5,-116(s0)
          e2.pid = p->pid;
    8000229a:	589c                	lw	a5,48(s1)
    8000229c:	f8f42823          	sw	a5,-112(s0)
          safestrcpy(e2.name, p->name, sizeof(e2.name));
    800022a0:	4641                	li	a2,16
    800022a2:	85ca                	mv	a1,s2
    800022a4:	f9440513          	addi	a0,s0,-108
    800022a8:	c27fe0ef          	jal	80000ece <safestrcpy>
          e2.state = p->state;
    800022ac:	4c9c                	lw	a5,24(s1)
    800022ae:	0007869b          	sext.w	a3,a5
          if(p->state == SLEEPING)
    800022b2:	4609                	li	a2,2
    800022b4:	4709                	li	a4,2
    800022b6:	00c78b63          	beq	a5,a2,800022cc <scheduler+0x21c>
          else if(p->state == ZOMBIE)
    800022ba:	4615                	li	a2,5
    800022bc:	4711                	li	a4,4
    800022be:	00c78763          	beq	a5,a2,800022cc <scheduler+0x21c>
          else if(p->state == RUNNABLE)
    800022c2:	460d                	li	a2,3
    800022c4:	470d                	li	a4,3
    800022c6:	00c78363          	beq	a5,a2,800022cc <scheduler+0x21c>
    800022ca:	4701                	li	a4,0
          e2.state = p->state;
    800022cc:	fad42223          	sw	a3,-92(s0)
            e2.reason = SCHED_OFF_SLEEP;
    800022d0:	fae42423          	sw	a4,-88(s0)
          schedlog_emit(&e2);
    800022d4:	f6840513          	addi	a0,s0,-152
    800022d8:	3e2040ef          	jal	800066ba <schedlog_emit>
    800022dc:	b5f1                	j	800021a8 <scheduler+0xf8>
    if (found == 0) {
    800022de:	00091463          	bnez	s2,800022e6 <scheduler+0x236>
      asm volatile("wfi");
    800022e2:	10500073          	wfi
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800022e6:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    800022ea:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800022ee:	10079073          	csrw	sstatus,a5
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800022f2:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    800022f6:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800022f8:	10079073          	csrw	sstatus,a5
    int found = 0;
    800022fc:	4901                	li	s2,0
    for (p = proc; p < &proc[NPROC]; p++) {
    800022fe:	00012497          	auipc	s1,0x12
    80002302:	97248493          	addi	s1,s1,-1678 # 80013c70 <proc>
        if (cpuid() == 0 && sched_info_logged == 0) {
    80002306:	00009b17          	auipc	s6,0x9
    8000230a:	3bab0b13          	addi	s6,s6,954 # 8000b6c0 <sched_info_logged>
    8000230e:	bd5d                	j	800021c4 <scheduler+0x114>

0000000080002310 <sched>:
void sched(void) {
    80002310:	7179                	addi	sp,sp,-48
    80002312:	f406                	sd	ra,40(sp)
    80002314:	f022                	sd	s0,32(sp)
    80002316:	ec26                	sd	s1,24(sp)
    80002318:	e84a                	sd	s2,16(sp)
    8000231a:	e44e                	sd	s3,8(sp)
    8000231c:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    8000231e:	8b5ff0ef          	jal	80001bd2 <myproc>
    80002322:	84aa                	mv	s1,a0
  if (!holding(&p->lock))
    80002324:	92ffe0ef          	jal	80000c52 <holding>
    80002328:	c92d                	beqz	a0,8000239a <sched+0x8a>
  asm volatile("mv %0, tp" : "=r" (x) );
    8000232a:	8792                	mv	a5,tp
  if (mycpu()->noff != 1)
    8000232c:	2781                	sext.w	a5,a5
    8000232e:	079e                	slli	a5,a5,0x7
    80002330:	00011717          	auipc	a4,0x11
    80002334:	4f870713          	addi	a4,a4,1272 # 80013828 <pid_lock>
    80002338:	97ba                	add	a5,a5,a4
    8000233a:	0c07a703          	lw	a4,192(a5)
    8000233e:	4785                	li	a5,1
    80002340:	06f71363          	bne	a4,a5,800023a6 <sched+0x96>
  if (p->state == RUNNING)
    80002344:	4c98                	lw	a4,24(s1)
    80002346:	4791                	li	a5,4
    80002348:	06f70563          	beq	a4,a5,800023b2 <sched+0xa2>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000234c:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002350:	8b89                	andi	a5,a5,2
  if (intr_get())
    80002352:	e7b5                	bnez	a5,800023be <sched+0xae>
  asm volatile("mv %0, tp" : "=r" (x) );
    80002354:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    80002356:	00011917          	auipc	s2,0x11
    8000235a:	4d290913          	addi	s2,s2,1234 # 80013828 <pid_lock>
    8000235e:	2781                	sext.w	a5,a5
    80002360:	079e                	slli	a5,a5,0x7
    80002362:	97ca                	add	a5,a5,s2
    80002364:	0c47a983          	lw	s3,196(a5)
    80002368:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    8000236a:	2781                	sext.w	a5,a5
    8000236c:	079e                	slli	a5,a5,0x7
    8000236e:	00011597          	auipc	a1,0x11
    80002372:	50a58593          	addi	a1,a1,1290 # 80013878 <cpus+0x8>
    80002376:	95be                	add	a1,a1,a5
    80002378:	06048513          	addi	a0,s1,96
    8000237c:	50e000ef          	jal	8000288a <swtch>
    80002380:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    80002382:	2781                	sext.w	a5,a5
    80002384:	079e                	slli	a5,a5,0x7
    80002386:	993e                	add	s2,s2,a5
    80002388:	0d392223          	sw	s3,196(s2)
}
    8000238c:	70a2                	ld	ra,40(sp)
    8000238e:	7402                	ld	s0,32(sp)
    80002390:	64e2                	ld	s1,24(sp)
    80002392:	6942                	ld	s2,16(sp)
    80002394:	69a2                	ld	s3,8(sp)
    80002396:	6145                	addi	sp,sp,48
    80002398:	8082                	ret
    panic("sched p->lock");
    8000239a:	00006517          	auipc	a0,0x6
    8000239e:	e2e50513          	addi	a0,a0,-466 # 800081c8 <etext+0x1c8>
    800023a2:	c70fe0ef          	jal	80000812 <panic>
    panic("sched locks");
    800023a6:	00006517          	auipc	a0,0x6
    800023aa:	e3250513          	addi	a0,a0,-462 # 800081d8 <etext+0x1d8>
    800023ae:	c64fe0ef          	jal	80000812 <panic>
    panic("sched RUNNING");
    800023b2:	00006517          	auipc	a0,0x6
    800023b6:	e3650513          	addi	a0,a0,-458 # 800081e8 <etext+0x1e8>
    800023ba:	c58fe0ef          	jal	80000812 <panic>
    panic("sched interruptible");
    800023be:	00006517          	auipc	a0,0x6
    800023c2:	e3a50513          	addi	a0,a0,-454 # 800081f8 <etext+0x1f8>
    800023c6:	c4cfe0ef          	jal	80000812 <panic>

00000000800023ca <yield>:
void yield(void) {
    800023ca:	1101                	addi	sp,sp,-32
    800023cc:	ec06                	sd	ra,24(sp)
    800023ce:	e822                	sd	s0,16(sp)
    800023d0:	e426                	sd	s1,8(sp)
    800023d2:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    800023d4:	ffeff0ef          	jal	80001bd2 <myproc>
    800023d8:	84aa                	mv	s1,a0
  acquire(&p->lock);
    800023da:	8e3fe0ef          	jal	80000cbc <acquire>
  p->state = RUNNABLE;
    800023de:	478d                	li	a5,3
    800023e0:	cc9c                	sw	a5,24(s1)
  sched();
    800023e2:	f2fff0ef          	jal	80002310 <sched>
  release(&p->lock);
    800023e6:	8526                	mv	a0,s1
    800023e8:	96dfe0ef          	jal	80000d54 <release>
}
    800023ec:	60e2                	ld	ra,24(sp)
    800023ee:	6442                	ld	s0,16(sp)
    800023f0:	64a2                	ld	s1,8(sp)
    800023f2:	6105                	addi	sp,sp,32
    800023f4:	8082                	ret

00000000800023f6 <sleep>:

// Sleep on channel chan, releasing condition lock lk.
// Re-acquires lk when awakened.
void sleep(void *chan, struct spinlock *lk) {
    800023f6:	7179                	addi	sp,sp,-48
    800023f8:	f406                	sd	ra,40(sp)
    800023fa:	f022                	sd	s0,32(sp)
    800023fc:	ec26                	sd	s1,24(sp)
    800023fe:	e84a                	sd	s2,16(sp)
    80002400:	e44e                	sd	s3,8(sp)
    80002402:	1800                	addi	s0,sp,48
    80002404:	89aa                	mv	s3,a0
    80002406:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002408:	fcaff0ef          	jal	80001bd2 <myproc>
    8000240c:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock); // DOC: sleeplock1
    8000240e:	8affe0ef          	jal	80000cbc <acquire>
  release(lk);
    80002412:	854a                	mv	a0,s2
    80002414:	941fe0ef          	jal	80000d54 <release>

  // Go to sleep.
  p->chan = chan;
    80002418:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    8000241c:	4789                	li	a5,2
    8000241e:	cc9c                	sw	a5,24(s1)

  sched();
    80002420:	ef1ff0ef          	jal	80002310 <sched>

  // Tidy up.
  p->chan = 0;
    80002424:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    80002428:	8526                	mv	a0,s1
    8000242a:	92bfe0ef          	jal	80000d54 <release>
  acquire(lk);
    8000242e:	854a                	mv	a0,s2
    80002430:	88dfe0ef          	jal	80000cbc <acquire>
}
    80002434:	70a2                	ld	ra,40(sp)
    80002436:	7402                	ld	s0,32(sp)
    80002438:	64e2                	ld	s1,24(sp)
    8000243a:	6942                	ld	s2,16(sp)
    8000243c:	69a2                	ld	s3,8(sp)
    8000243e:	6145                	addi	sp,sp,48
    80002440:	8082                	ret

0000000080002442 <wakeup>:

// Wake up all processes sleeping on channel chan.
// Caller should hold the condition lock.
void wakeup(void *chan) {
    80002442:	7139                	addi	sp,sp,-64
    80002444:	fc06                	sd	ra,56(sp)
    80002446:	f822                	sd	s0,48(sp)
    80002448:	f426                	sd	s1,40(sp)
    8000244a:	f04a                	sd	s2,32(sp)
    8000244c:	ec4e                	sd	s3,24(sp)
    8000244e:	e852                	sd	s4,16(sp)
    80002450:	e456                	sd	s5,8(sp)
    80002452:	0080                	addi	s0,sp,64
    80002454:	8a2a                	mv	s4,a0
  struct proc *p;

  for (p = proc; p < &proc[NPROC]; p++) {
    80002456:	00012497          	auipc	s1,0x12
    8000245a:	81a48493          	addi	s1,s1,-2022 # 80013c70 <proc>
    if (p != myproc()) {
      acquire(&p->lock);
      if (p->state == SLEEPING && p->chan == chan) {
    8000245e:	4989                	li	s3,2
        p->state = RUNNABLE;
    80002460:	4a8d                	li	s5,3
  for (p = proc; p < &proc[NPROC]; p++) {
    80002462:	00017917          	auipc	s2,0x17
    80002466:	20e90913          	addi	s2,s2,526 # 80019670 <tickslock>
    8000246a:	a801                	j	8000247a <wakeup+0x38>
      }
      release(&p->lock);
    8000246c:	8526                	mv	a0,s1
    8000246e:	8e7fe0ef          	jal	80000d54 <release>
  for (p = proc; p < &proc[NPROC]; p++) {
    80002472:	16848493          	addi	s1,s1,360
    80002476:	03248263          	beq	s1,s2,8000249a <wakeup+0x58>
    if (p != myproc()) {
    8000247a:	f58ff0ef          	jal	80001bd2 <myproc>
    8000247e:	fea48ae3          	beq	s1,a0,80002472 <wakeup+0x30>
      acquire(&p->lock);
    80002482:	8526                	mv	a0,s1
    80002484:	839fe0ef          	jal	80000cbc <acquire>
      if (p->state == SLEEPING && p->chan == chan) {
    80002488:	4c9c                	lw	a5,24(s1)
    8000248a:	ff3791e3          	bne	a5,s3,8000246c <wakeup+0x2a>
    8000248e:	709c                	ld	a5,32(s1)
    80002490:	fd479ee3          	bne	a5,s4,8000246c <wakeup+0x2a>
        p->state = RUNNABLE;
    80002494:	0154ac23          	sw	s5,24(s1)
    80002498:	bfd1                	j	8000246c <wakeup+0x2a>
    }
  }
}
    8000249a:	70e2                	ld	ra,56(sp)
    8000249c:	7442                	ld	s0,48(sp)
    8000249e:	74a2                	ld	s1,40(sp)
    800024a0:	7902                	ld	s2,32(sp)
    800024a2:	69e2                	ld	s3,24(sp)
    800024a4:	6a42                	ld	s4,16(sp)
    800024a6:	6aa2                	ld	s5,8(sp)
    800024a8:	6121                	addi	sp,sp,64
    800024aa:	8082                	ret

00000000800024ac <reparent>:
void reparent(struct proc *p) {
    800024ac:	7179                	addi	sp,sp,-48
    800024ae:	f406                	sd	ra,40(sp)
    800024b0:	f022                	sd	s0,32(sp)
    800024b2:	ec26                	sd	s1,24(sp)
    800024b4:	e84a                	sd	s2,16(sp)
    800024b6:	e44e                	sd	s3,8(sp)
    800024b8:	e052                	sd	s4,0(sp)
    800024ba:	1800                	addi	s0,sp,48
    800024bc:	892a                	mv	s2,a0
  for (pp = proc; pp < &proc[NPROC]; pp++) {
    800024be:	00011497          	auipc	s1,0x11
    800024c2:	7b248493          	addi	s1,s1,1970 # 80013c70 <proc>
      pp->parent = initproc;
    800024c6:	00009a17          	auipc	s4,0x9
    800024ca:	202a0a13          	addi	s4,s4,514 # 8000b6c8 <initproc>
  for (pp = proc; pp < &proc[NPROC]; pp++) {
    800024ce:	00017997          	auipc	s3,0x17
    800024d2:	1a298993          	addi	s3,s3,418 # 80019670 <tickslock>
    800024d6:	a029                	j	800024e0 <reparent+0x34>
    800024d8:	16848493          	addi	s1,s1,360
    800024dc:	01348b63          	beq	s1,s3,800024f2 <reparent+0x46>
    if (pp->parent == p) {
    800024e0:	7c9c                	ld	a5,56(s1)
    800024e2:	ff279be3          	bne	a5,s2,800024d8 <reparent+0x2c>
      pp->parent = initproc;
    800024e6:	000a3503          	ld	a0,0(s4)
    800024ea:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    800024ec:	f57ff0ef          	jal	80002442 <wakeup>
    800024f0:	b7e5                	j	800024d8 <reparent+0x2c>
}
    800024f2:	70a2                	ld	ra,40(sp)
    800024f4:	7402                	ld	s0,32(sp)
    800024f6:	64e2                	ld	s1,24(sp)
    800024f8:	6942                	ld	s2,16(sp)
    800024fa:	69a2                	ld	s3,8(sp)
    800024fc:	6a02                	ld	s4,0(sp)
    800024fe:	6145                	addi	sp,sp,48
    80002500:	8082                	ret

0000000080002502 <kexit>:
void kexit(int status) {
    80002502:	7179                	addi	sp,sp,-48
    80002504:	f406                	sd	ra,40(sp)
    80002506:	f022                	sd	s0,32(sp)
    80002508:	ec26                	sd	s1,24(sp)
    8000250a:	e84a                	sd	s2,16(sp)
    8000250c:	e44e                	sd	s3,8(sp)
    8000250e:	e052                	sd	s4,0(sp)
    80002510:	1800                	addi	s0,sp,48
    80002512:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    80002514:	ebeff0ef          	jal	80001bd2 <myproc>
    80002518:	89aa                	mv	s3,a0
  if (p == initproc)
    8000251a:	00009797          	auipc	a5,0x9
    8000251e:	1ae7b783          	ld	a5,430(a5) # 8000b6c8 <initproc>
    80002522:	0d050493          	addi	s1,a0,208
    80002526:	15050913          	addi	s2,a0,336
    8000252a:	00a79f63          	bne	a5,a0,80002548 <kexit+0x46>
    panic("init exiting");
    8000252e:	00006517          	auipc	a0,0x6
    80002532:	ce250513          	addi	a0,a0,-798 # 80008210 <etext+0x210>
    80002536:	adcfe0ef          	jal	80000812 <panic>
      fileclose(f);
    8000253a:	08e020ef          	jal	800045c8 <fileclose>
      p->ofile[fd] = 0;
    8000253e:	0004b023          	sd	zero,0(s1)
  for (int fd = 0; fd < NOFILE; fd++) {
    80002542:	04a1                	addi	s1,s1,8
    80002544:	01248563          	beq	s1,s2,8000254e <kexit+0x4c>
    if (p->ofile[fd]) {
    80002548:	6088                	ld	a0,0(s1)
    8000254a:	f965                	bnez	a0,8000253a <kexit+0x38>
    8000254c:	bfdd                	j	80002542 <kexit+0x40>
  begin_op();
    8000254e:	46f010ef          	jal	800041bc <begin_op>
  iput(p->cwd);
    80002552:	1509b503          	ld	a0,336(s3)
    80002556:	3fe010ef          	jal	80003954 <iput>
  end_op();
    8000255a:	4cd010ef          	jal	80004226 <end_op>
  p->cwd = 0;
    8000255e:	1409b823          	sd	zero,336(s3)
  acquire(&wait_lock);
    80002562:	00011497          	auipc	s1,0x11
    80002566:	2de48493          	addi	s1,s1,734 # 80013840 <wait_lock>
    8000256a:	8526                	mv	a0,s1
    8000256c:	f50fe0ef          	jal	80000cbc <acquire>
  reparent(p);
    80002570:	854e                	mv	a0,s3
    80002572:	f3bff0ef          	jal	800024ac <reparent>
  wakeup(p->parent);
    80002576:	0389b503          	ld	a0,56(s3)
    8000257a:	ec9ff0ef          	jal	80002442 <wakeup>
  acquire(&p->lock);
    8000257e:	854e                	mv	a0,s3
    80002580:	f3cfe0ef          	jal	80000cbc <acquire>
  p->xstate = status;
    80002584:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    80002588:	4795                	li	a5,5
    8000258a:	00f9ac23          	sw	a5,24(s3)
  release(&wait_lock);
    8000258e:	8526                	mv	a0,s1
    80002590:	fc4fe0ef          	jal	80000d54 <release>
  sched();
    80002594:	d7dff0ef          	jal	80002310 <sched>
  panic("zombie exit");
    80002598:	00006517          	auipc	a0,0x6
    8000259c:	c8850513          	addi	a0,a0,-888 # 80008220 <etext+0x220>
    800025a0:	a72fe0ef          	jal	80000812 <panic>

00000000800025a4 <kkill>:

// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int kkill(int pid) {
    800025a4:	7179                	addi	sp,sp,-48
    800025a6:	f406                	sd	ra,40(sp)
    800025a8:	f022                	sd	s0,32(sp)
    800025aa:	ec26                	sd	s1,24(sp)
    800025ac:	e84a                	sd	s2,16(sp)
    800025ae:	e44e                	sd	s3,8(sp)
    800025b0:	1800                	addi	s0,sp,48
    800025b2:	892a                	mv	s2,a0
  struct proc *p;

  for (p = proc; p < &proc[NPROC]; p++) {
    800025b4:	00011497          	auipc	s1,0x11
    800025b8:	6bc48493          	addi	s1,s1,1724 # 80013c70 <proc>
    800025bc:	00017997          	auipc	s3,0x17
    800025c0:	0b498993          	addi	s3,s3,180 # 80019670 <tickslock>
    acquire(&p->lock);
    800025c4:	8526                	mv	a0,s1
    800025c6:	ef6fe0ef          	jal	80000cbc <acquire>
    if (p->pid == pid) {
    800025ca:	589c                	lw	a5,48(s1)
    800025cc:	01278b63          	beq	a5,s2,800025e2 <kkill+0x3e>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    800025d0:	8526                	mv	a0,s1
    800025d2:	f82fe0ef          	jal	80000d54 <release>
  for (p = proc; p < &proc[NPROC]; p++) {
    800025d6:	16848493          	addi	s1,s1,360
    800025da:	ff3495e3          	bne	s1,s3,800025c4 <kkill+0x20>
  }
  return -1;
    800025de:	557d                	li	a0,-1
    800025e0:	a819                	j	800025f6 <kkill+0x52>
      p->killed = 1;
    800025e2:	4785                	li	a5,1
    800025e4:	d49c                	sw	a5,40(s1)
      if (p->state == SLEEPING) {
    800025e6:	4c98                	lw	a4,24(s1)
    800025e8:	4789                	li	a5,2
    800025ea:	00f70d63          	beq	a4,a5,80002604 <kkill+0x60>
      release(&p->lock);
    800025ee:	8526                	mv	a0,s1
    800025f0:	f64fe0ef          	jal	80000d54 <release>
      return 0;
    800025f4:	4501                	li	a0,0
}
    800025f6:	70a2                	ld	ra,40(sp)
    800025f8:	7402                	ld	s0,32(sp)
    800025fa:	64e2                	ld	s1,24(sp)
    800025fc:	6942                	ld	s2,16(sp)
    800025fe:	69a2                	ld	s3,8(sp)
    80002600:	6145                	addi	sp,sp,48
    80002602:	8082                	ret
        p->state = RUNNABLE;
    80002604:	478d                	li	a5,3
    80002606:	cc9c                	sw	a5,24(s1)
    80002608:	b7dd                	j	800025ee <kkill+0x4a>

000000008000260a <setkilled>:

void setkilled(struct proc *p) {
    8000260a:	1101                	addi	sp,sp,-32
    8000260c:	ec06                	sd	ra,24(sp)
    8000260e:	e822                	sd	s0,16(sp)
    80002610:	e426                	sd	s1,8(sp)
    80002612:	1000                	addi	s0,sp,32
    80002614:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80002616:	ea6fe0ef          	jal	80000cbc <acquire>
  p->killed = 1;
    8000261a:	4785                	li	a5,1
    8000261c:	d49c                	sw	a5,40(s1)
  release(&p->lock);
    8000261e:	8526                	mv	a0,s1
    80002620:	f34fe0ef          	jal	80000d54 <release>
}
    80002624:	60e2                	ld	ra,24(sp)
    80002626:	6442                	ld	s0,16(sp)
    80002628:	64a2                	ld	s1,8(sp)
    8000262a:	6105                	addi	sp,sp,32
    8000262c:	8082                	ret

000000008000262e <killed>:

int killed(struct proc *p) {
    8000262e:	1101                	addi	sp,sp,-32
    80002630:	ec06                	sd	ra,24(sp)
    80002632:	e822                	sd	s0,16(sp)
    80002634:	e426                	sd	s1,8(sp)
    80002636:	e04a                	sd	s2,0(sp)
    80002638:	1000                	addi	s0,sp,32
    8000263a:	84aa                	mv	s1,a0
  int k;

  acquire(&p->lock);
    8000263c:	e80fe0ef          	jal	80000cbc <acquire>
  k = p->killed;
    80002640:	0284a903          	lw	s2,40(s1)
  release(&p->lock);
    80002644:	8526                	mv	a0,s1
    80002646:	f0efe0ef          	jal	80000d54 <release>
  return k;
}
    8000264a:	854a                	mv	a0,s2
    8000264c:	60e2                	ld	ra,24(sp)
    8000264e:	6442                	ld	s0,16(sp)
    80002650:	64a2                	ld	s1,8(sp)
    80002652:	6902                	ld	s2,0(sp)
    80002654:	6105                	addi	sp,sp,32
    80002656:	8082                	ret

0000000080002658 <kwait>:
int kwait(uint64 addr) {
    80002658:	715d                	addi	sp,sp,-80
    8000265a:	e486                	sd	ra,72(sp)
    8000265c:	e0a2                	sd	s0,64(sp)
    8000265e:	fc26                	sd	s1,56(sp)
    80002660:	f84a                	sd	s2,48(sp)
    80002662:	f44e                	sd	s3,40(sp)
    80002664:	f052                	sd	s4,32(sp)
    80002666:	ec56                	sd	s5,24(sp)
    80002668:	e85a                	sd	s6,16(sp)
    8000266a:	e45e                	sd	s7,8(sp)
    8000266c:	e062                	sd	s8,0(sp)
    8000266e:	0880                	addi	s0,sp,80
    80002670:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    80002672:	d60ff0ef          	jal	80001bd2 <myproc>
    80002676:	892a                	mv	s2,a0
  acquire(&wait_lock);
    80002678:	00011517          	auipc	a0,0x11
    8000267c:	1c850513          	addi	a0,a0,456 # 80013840 <wait_lock>
    80002680:	e3cfe0ef          	jal	80000cbc <acquire>
    havekids = 0;
    80002684:	4b81                	li	s7,0
        if (pp->state == ZOMBIE) {
    80002686:	4a15                	li	s4,5
        havekids = 1;
    80002688:	4a85                	li	s5,1
    for (pp = proc; pp < &proc[NPROC]; pp++) {
    8000268a:	00017997          	auipc	s3,0x17
    8000268e:	fe698993          	addi	s3,s3,-26 # 80019670 <tickslock>
    sleep(p, &wait_lock); // DOC: wait-sleep
    80002692:	00011c17          	auipc	s8,0x11
    80002696:	1aec0c13          	addi	s8,s8,430 # 80013840 <wait_lock>
    8000269a:	a871                	j	80002736 <kwait+0xde>
          pid = pp->pid;
    8000269c:	0304a983          	lw	s3,48(s1)
          if (addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    800026a0:	000b0c63          	beqz	s6,800026b8 <kwait+0x60>
    800026a4:	4691                	li	a3,4
    800026a6:	02c48613          	addi	a2,s1,44
    800026aa:	85da                	mv	a1,s6
    800026ac:	05093503          	ld	a0,80(s2)
    800026b0:	a22ff0ef          	jal	800018d2 <copyout>
    800026b4:	02054b63          	bltz	a0,800026ea <kwait+0x92>
          freeproc(pp);
    800026b8:	8526                	mv	a0,s1
    800026ba:	ee8ff0ef          	jal	80001da2 <freeproc>
          release(&pp->lock);
    800026be:	8526                	mv	a0,s1
    800026c0:	e94fe0ef          	jal	80000d54 <release>
          release(&wait_lock);
    800026c4:	00011517          	auipc	a0,0x11
    800026c8:	17c50513          	addi	a0,a0,380 # 80013840 <wait_lock>
    800026cc:	e88fe0ef          	jal	80000d54 <release>
}
    800026d0:	854e                	mv	a0,s3
    800026d2:	60a6                	ld	ra,72(sp)
    800026d4:	6406                	ld	s0,64(sp)
    800026d6:	74e2                	ld	s1,56(sp)
    800026d8:	7942                	ld	s2,48(sp)
    800026da:	79a2                	ld	s3,40(sp)
    800026dc:	7a02                	ld	s4,32(sp)
    800026de:	6ae2                	ld	s5,24(sp)
    800026e0:	6b42                	ld	s6,16(sp)
    800026e2:	6ba2                	ld	s7,8(sp)
    800026e4:	6c02                	ld	s8,0(sp)
    800026e6:	6161                	addi	sp,sp,80
    800026e8:	8082                	ret
            release(&pp->lock);
    800026ea:	8526                	mv	a0,s1
    800026ec:	e68fe0ef          	jal	80000d54 <release>
            release(&wait_lock);
    800026f0:	00011517          	auipc	a0,0x11
    800026f4:	15050513          	addi	a0,a0,336 # 80013840 <wait_lock>
    800026f8:	e5cfe0ef          	jal	80000d54 <release>
            return -1;
    800026fc:	59fd                	li	s3,-1
    800026fe:	bfc9                	j	800026d0 <kwait+0x78>
    for (pp = proc; pp < &proc[NPROC]; pp++) {
    80002700:	16848493          	addi	s1,s1,360
    80002704:	03348063          	beq	s1,s3,80002724 <kwait+0xcc>
      if (pp->parent == p) {
    80002708:	7c9c                	ld	a5,56(s1)
    8000270a:	ff279be3          	bne	a5,s2,80002700 <kwait+0xa8>
        acquire(&pp->lock);
    8000270e:	8526                	mv	a0,s1
    80002710:	dacfe0ef          	jal	80000cbc <acquire>
        if (pp->state == ZOMBIE) {
    80002714:	4c9c                	lw	a5,24(s1)
    80002716:	f94783e3          	beq	a5,s4,8000269c <kwait+0x44>
        release(&pp->lock);
    8000271a:	8526                	mv	a0,s1
    8000271c:	e38fe0ef          	jal	80000d54 <release>
        havekids = 1;
    80002720:	8756                	mv	a4,s5
    80002722:	bff9                	j	80002700 <kwait+0xa8>
    if (!havekids || killed(p)) {
    80002724:	cf19                	beqz	a4,80002742 <kwait+0xea>
    80002726:	854a                	mv	a0,s2
    80002728:	f07ff0ef          	jal	8000262e <killed>
    8000272c:	e919                	bnez	a0,80002742 <kwait+0xea>
    sleep(p, &wait_lock); // DOC: wait-sleep
    8000272e:	85e2                	mv	a1,s8
    80002730:	854a                	mv	a0,s2
    80002732:	cc5ff0ef          	jal	800023f6 <sleep>
    havekids = 0;
    80002736:	875e                	mv	a4,s7
    for (pp = proc; pp < &proc[NPROC]; pp++) {
    80002738:	00011497          	auipc	s1,0x11
    8000273c:	53848493          	addi	s1,s1,1336 # 80013c70 <proc>
    80002740:	b7e1                	j	80002708 <kwait+0xb0>
      release(&wait_lock);
    80002742:	00011517          	auipc	a0,0x11
    80002746:	0fe50513          	addi	a0,a0,254 # 80013840 <wait_lock>
    8000274a:	e0afe0ef          	jal	80000d54 <release>
      return -1;
    8000274e:	59fd                	li	s3,-1
    80002750:	b741                	j	800026d0 <kwait+0x78>

0000000080002752 <either_copyout>:

// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int either_copyout(int user_dst, uint64 dst, void *src, uint64 len) {
    80002752:	7179                	addi	sp,sp,-48
    80002754:	f406                	sd	ra,40(sp)
    80002756:	f022                	sd	s0,32(sp)
    80002758:	ec26                	sd	s1,24(sp)
    8000275a:	e84a                	sd	s2,16(sp)
    8000275c:	e44e                	sd	s3,8(sp)
    8000275e:	e052                	sd	s4,0(sp)
    80002760:	1800                	addi	s0,sp,48
    80002762:	84aa                	mv	s1,a0
    80002764:	892e                	mv	s2,a1
    80002766:	89b2                	mv	s3,a2
    80002768:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    8000276a:	c68ff0ef          	jal	80001bd2 <myproc>
  if (user_dst) {
    8000276e:	cc99                	beqz	s1,8000278c <either_copyout+0x3a>
    return copyout(p->pagetable, dst, src, len);
    80002770:	86d2                	mv	a3,s4
    80002772:	864e                	mv	a2,s3
    80002774:	85ca                	mv	a1,s2
    80002776:	6928                	ld	a0,80(a0)
    80002778:	95aff0ef          	jal	800018d2 <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    8000277c:	70a2                	ld	ra,40(sp)
    8000277e:	7402                	ld	s0,32(sp)
    80002780:	64e2                	ld	s1,24(sp)
    80002782:	6942                	ld	s2,16(sp)
    80002784:	69a2                	ld	s3,8(sp)
    80002786:	6a02                	ld	s4,0(sp)
    80002788:	6145                	addi	sp,sp,48
    8000278a:	8082                	ret
    memmove((char *)dst, src, len);
    8000278c:	000a061b          	sext.w	a2,s4
    80002790:	85ce                	mv	a1,s3
    80002792:	854a                	mv	a0,s2
    80002794:	e58fe0ef          	jal	80000dec <memmove>
    return 0;
    80002798:	8526                	mv	a0,s1
    8000279a:	b7cd                	j	8000277c <either_copyout+0x2a>

000000008000279c <either_copyin>:

// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int either_copyin(void *dst, int user_src, uint64 src, uint64 len) {
    8000279c:	7179                	addi	sp,sp,-48
    8000279e:	f406                	sd	ra,40(sp)
    800027a0:	f022                	sd	s0,32(sp)
    800027a2:	ec26                	sd	s1,24(sp)
    800027a4:	e84a                	sd	s2,16(sp)
    800027a6:	e44e                	sd	s3,8(sp)
    800027a8:	e052                	sd	s4,0(sp)
    800027aa:	1800                	addi	s0,sp,48
    800027ac:	892a                	mv	s2,a0
    800027ae:	84ae                	mv	s1,a1
    800027b0:	89b2                	mv	s3,a2
    800027b2:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    800027b4:	c1eff0ef          	jal	80001bd2 <myproc>
  if (user_src) {
    800027b8:	cc99                	beqz	s1,800027d6 <either_copyin+0x3a>
    return copyin(p->pagetable, dst, src, len);
    800027ba:	86d2                	mv	a3,s4
    800027bc:	864e                	mv	a2,s3
    800027be:	85ca                	mv	a1,s2
    800027c0:	6928                	ld	a0,80(a0)
    800027c2:	9f4ff0ef          	jal	800019b6 <copyin>
  } else {
    memmove(dst, (char *)src, len);
    return 0;
  }
}
    800027c6:	70a2                	ld	ra,40(sp)
    800027c8:	7402                	ld	s0,32(sp)
    800027ca:	64e2                	ld	s1,24(sp)
    800027cc:	6942                	ld	s2,16(sp)
    800027ce:	69a2                	ld	s3,8(sp)
    800027d0:	6a02                	ld	s4,0(sp)
    800027d2:	6145                	addi	sp,sp,48
    800027d4:	8082                	ret
    memmove(dst, (char *)src, len);
    800027d6:	000a061b          	sext.w	a2,s4
    800027da:	85ce                	mv	a1,s3
    800027dc:	854a                	mv	a0,s2
    800027de:	e0efe0ef          	jal	80000dec <memmove>
    return 0;
    800027e2:	8526                	mv	a0,s1
    800027e4:	b7cd                	j	800027c6 <either_copyin+0x2a>

00000000800027e6 <procdump>:

// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void procdump(void) {
    800027e6:	715d                	addi	sp,sp,-80
    800027e8:	e486                	sd	ra,72(sp)
    800027ea:	e0a2                	sd	s0,64(sp)
    800027ec:	fc26                	sd	s1,56(sp)
    800027ee:	f84a                	sd	s2,48(sp)
    800027f0:	f44e                	sd	s3,40(sp)
    800027f2:	f052                	sd	s4,32(sp)
    800027f4:	ec56                	sd	s5,24(sp)
    800027f6:	e85a                	sd	s6,16(sp)
    800027f8:	e45e                	sd	s7,8(sp)
    800027fa:	0880                	addi	s0,sp,80
      [UNUSED] "unused",   [USED] "used",      [SLEEPING] "sleep ",
      [RUNNABLE] "runble", [RUNNING] "run   ", [ZOMBIE] "zombie"};
  struct proc *p;
  char *state;

  printf("\n");
    800027fc:	00006517          	auipc	a0,0x6
    80002800:	88450513          	addi	a0,a0,-1916 # 80008080 <etext+0x80>
    80002804:	d29fd0ef          	jal	8000052c <printf>
  for (p = proc; p < &proc[NPROC]; p++) {
    80002808:	00011497          	auipc	s1,0x11
    8000280c:	5c048493          	addi	s1,s1,1472 # 80013dc8 <proc+0x158>
    80002810:	00017917          	auipc	s2,0x17
    80002814:	fb890913          	addi	s2,s2,-72 # 800197c8 <bcache+0x140>
    if (p->state == UNUSED)
      continue;
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002818:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    8000281a:	00006997          	auipc	s3,0x6
    8000281e:	a1698993          	addi	s3,s3,-1514 # 80008230 <etext+0x230>
    printf("%d %s %s", p->pid, state, p->name);
    80002822:	00006a97          	auipc	s5,0x6
    80002826:	a16a8a93          	addi	s5,s5,-1514 # 80008238 <etext+0x238>
    printf("\n");
    8000282a:	00006a17          	auipc	s4,0x6
    8000282e:	856a0a13          	addi	s4,s4,-1962 # 80008080 <etext+0x80>
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002832:	00006b97          	auipc	s7,0x6
    80002836:	f6eb8b93          	addi	s7,s7,-146 # 800087a0 <states.0>
    8000283a:	a829                	j	80002854 <procdump+0x6e>
    printf("%d %s %s", p->pid, state, p->name);
    8000283c:	ed86a583          	lw	a1,-296(a3)
    80002840:	8556                	mv	a0,s5
    80002842:	cebfd0ef          	jal	8000052c <printf>
    printf("\n");
    80002846:	8552                	mv	a0,s4
    80002848:	ce5fd0ef          	jal	8000052c <printf>
  for (p = proc; p < &proc[NPROC]; p++) {
    8000284c:	16848493          	addi	s1,s1,360
    80002850:	03248263          	beq	s1,s2,80002874 <procdump+0x8e>
    if (p->state == UNUSED)
    80002854:	86a6                	mv	a3,s1
    80002856:	ec04a783          	lw	a5,-320(s1)
    8000285a:	dbed                	beqz	a5,8000284c <procdump+0x66>
      state = "???";
    8000285c:	864e                	mv	a2,s3
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000285e:	fcfb6fe3          	bltu	s6,a5,8000283c <procdump+0x56>
    80002862:	02079713          	slli	a4,a5,0x20
    80002866:	01d75793          	srli	a5,a4,0x1d
    8000286a:	97de                	add	a5,a5,s7
    8000286c:	6390                	ld	a2,0(a5)
    8000286e:	f679                	bnez	a2,8000283c <procdump+0x56>
      state = "???";
    80002870:	864e                	mv	a2,s3
    80002872:	b7e9                	j	8000283c <procdump+0x56>
  }
}
    80002874:	60a6                	ld	ra,72(sp)
    80002876:	6406                	ld	s0,64(sp)
    80002878:	74e2                	ld	s1,56(sp)
    8000287a:	7942                	ld	s2,48(sp)
    8000287c:	79a2                	ld	s3,40(sp)
    8000287e:	7a02                	ld	s4,32(sp)
    80002880:	6ae2                	ld	s5,24(sp)
    80002882:	6b42                	ld	s6,16(sp)
    80002884:	6ba2                	ld	s7,8(sp)
    80002886:	6161                	addi	sp,sp,80
    80002888:	8082                	ret

000000008000288a <swtch>:
# Save current registers in old. Load from new.	


.globl swtch
swtch:
        sd ra, 0(a0)
    8000288a:	00153023          	sd	ra,0(a0)
        sd sp, 8(a0)
    8000288e:	00253423          	sd	sp,8(a0)
        sd s0, 16(a0)
    80002892:	e900                	sd	s0,16(a0)
        sd s1, 24(a0)
    80002894:	ed04                	sd	s1,24(a0)
        sd s2, 32(a0)
    80002896:	03253023          	sd	s2,32(a0)
        sd s3, 40(a0)
    8000289a:	03353423          	sd	s3,40(a0)
        sd s4, 48(a0)
    8000289e:	03453823          	sd	s4,48(a0)
        sd s5, 56(a0)
    800028a2:	03553c23          	sd	s5,56(a0)
        sd s6, 64(a0)
    800028a6:	05653023          	sd	s6,64(a0)
        sd s7, 72(a0)
    800028aa:	05753423          	sd	s7,72(a0)
        sd s8, 80(a0)
    800028ae:	05853823          	sd	s8,80(a0)
        sd s9, 88(a0)
    800028b2:	05953c23          	sd	s9,88(a0)
        sd s10, 96(a0)
    800028b6:	07a53023          	sd	s10,96(a0)
        sd s11, 104(a0)
    800028ba:	07b53423          	sd	s11,104(a0)

        ld ra, 0(a1)
    800028be:	0005b083          	ld	ra,0(a1)
        ld sp, 8(a1)
    800028c2:	0085b103          	ld	sp,8(a1)
        ld s0, 16(a1)
    800028c6:	6980                	ld	s0,16(a1)
        ld s1, 24(a1)
    800028c8:	6d84                	ld	s1,24(a1)
        ld s2, 32(a1)
    800028ca:	0205b903          	ld	s2,32(a1)
        ld s3, 40(a1)
    800028ce:	0285b983          	ld	s3,40(a1)
        ld s4, 48(a1)
    800028d2:	0305ba03          	ld	s4,48(a1)
        ld s5, 56(a1)
    800028d6:	0385ba83          	ld	s5,56(a1)
        ld s6, 64(a1)
    800028da:	0405bb03          	ld	s6,64(a1)
        ld s7, 72(a1)
    800028de:	0485bb83          	ld	s7,72(a1)
        ld s8, 80(a1)
    800028e2:	0505bc03          	ld	s8,80(a1)
        ld s9, 88(a1)
    800028e6:	0585bc83          	ld	s9,88(a1)
        ld s10, 96(a1)
    800028ea:	0605bd03          	ld	s10,96(a1)
        ld s11, 104(a1)
    800028ee:	0685bd83          	ld	s11,104(a1)
        
        ret
    800028f2:	8082                	ret

00000000800028f4 <trapinit>:

extern int devintr();

void
trapinit(void)
{
    800028f4:	1141                	addi	sp,sp,-16
    800028f6:	e406                	sd	ra,8(sp)
    800028f8:	e022                	sd	s0,0(sp)
    800028fa:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    800028fc:	00006597          	auipc	a1,0x6
    80002900:	97c58593          	addi	a1,a1,-1668 # 80008278 <etext+0x278>
    80002904:	00017517          	auipc	a0,0x17
    80002908:	d6c50513          	addi	a0,a0,-660 # 80019670 <tickslock>
    8000290c:	b30fe0ef          	jal	80000c3c <initlock>
}
    80002910:	60a2                	ld	ra,8(sp)
    80002912:	6402                	ld	s0,0(sp)
    80002914:	0141                	addi	sp,sp,16
    80002916:	8082                	ret

0000000080002918 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    80002918:	1141                	addi	sp,sp,-16
    8000291a:	e422                	sd	s0,8(sp)
    8000291c:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    8000291e:	00003797          	auipc	a5,0x3
    80002922:	05278793          	addi	a5,a5,82 # 80005970 <kernelvec>
    80002926:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    8000292a:	6422                	ld	s0,8(sp)
    8000292c:	0141                	addi	sp,sp,16
    8000292e:	8082                	ret

0000000080002930 <prepare_return>:
//
// set up trapframe and control registers for a return to user space
//
void
prepare_return(void)
{
    80002930:	1141                	addi	sp,sp,-16
    80002932:	e406                	sd	ra,8(sp)
    80002934:	e022                	sd	s0,0(sp)
    80002936:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    80002938:	a9aff0ef          	jal	80001bd2 <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000293c:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80002940:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002942:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(). because a trap from kernel
  // code to usertrap would be a disaster, turn off interrupts.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    80002946:	04000737          	lui	a4,0x4000
    8000294a:	177d                	addi	a4,a4,-1 # 3ffffff <_entry-0x7c000001>
    8000294c:	0732                	slli	a4,a4,0xc
    8000294e:	00004797          	auipc	a5,0x4
    80002952:	6b278793          	addi	a5,a5,1714 # 80007000 <_trampoline>
    80002956:	00004697          	auipc	a3,0x4
    8000295a:	6aa68693          	addi	a3,a3,1706 # 80007000 <_trampoline>
    8000295e:	8f95                	sub	a5,a5,a3
    80002960:	97ba                	add	a5,a5,a4
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002962:	10579073          	csrw	stvec,a5
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    80002966:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    80002968:	18002773          	csrr	a4,satp
    8000296c:	e398                	sd	a4,0(a5)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    8000296e:	6d38                	ld	a4,88(a0)
    80002970:	613c                	ld	a5,64(a0)
    80002972:	6685                	lui	a3,0x1
    80002974:	97b6                	add	a5,a5,a3
    80002976:	e71c                	sd	a5,8(a4)
  p->trapframe->kernel_trap = (uint64)usertrap;
    80002978:	6d3c                	ld	a5,88(a0)
    8000297a:	00000717          	auipc	a4,0x0
    8000297e:	0f870713          	addi	a4,a4,248 # 80002a72 <usertrap>
    80002982:	eb98                	sd	a4,16(a5)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    80002984:	6d3c                	ld	a5,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    80002986:	8712                	mv	a4,tp
    80002988:	f398                	sd	a4,32(a5)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000298a:	100027f3          	csrr	a5,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    8000298e:	eff7f793          	andi	a5,a5,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    80002992:	0207e793          	ori	a5,a5,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002996:	10079073          	csrw	sstatus,a5
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    8000299a:	6d3c                	ld	a5,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    8000299c:	6f9c                	ld	a5,24(a5)
    8000299e:	14179073          	csrw	sepc,a5
}
    800029a2:	60a2                	ld	ra,8(sp)
    800029a4:	6402                	ld	s0,0(sp)
    800029a6:	0141                	addi	sp,sp,16
    800029a8:	8082                	ret

00000000800029aa <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    800029aa:	1101                	addi	sp,sp,-32
    800029ac:	ec06                	sd	ra,24(sp)
    800029ae:	e822                	sd	s0,16(sp)
    800029b0:	1000                	addi	s0,sp,32
  if(cpuid() == 0){
    800029b2:	9f4ff0ef          	jal	80001ba6 <cpuid>
    800029b6:	cd11                	beqz	a0,800029d2 <clockintr+0x28>
  asm volatile("csrr %0, time" : "=r" (x) );
    800029b8:	c01027f3          	rdtime	a5
  }

  // ask for the next timer interrupt. this also clears
  // the interrupt request. 1000000 is about a tenth
  // of a second.
  w_stimecmp(r_time() + 1000000);
    800029bc:	000f4737          	lui	a4,0xf4
    800029c0:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    800029c4:	97ba                	add	a5,a5,a4
  asm volatile("csrw 0x14d, %0" : : "r" (x));
    800029c6:	14d79073          	csrw	stimecmp,a5
}
    800029ca:	60e2                	ld	ra,24(sp)
    800029cc:	6442                	ld	s0,16(sp)
    800029ce:	6105                	addi	sp,sp,32
    800029d0:	8082                	ret
    800029d2:	e426                	sd	s1,8(sp)
    acquire(&tickslock);
    800029d4:	00017497          	auipc	s1,0x17
    800029d8:	c9c48493          	addi	s1,s1,-868 # 80019670 <tickslock>
    800029dc:	8526                	mv	a0,s1
    800029de:	adefe0ef          	jal	80000cbc <acquire>
    ticks++;
    800029e2:	00009517          	auipc	a0,0x9
    800029e6:	cee50513          	addi	a0,a0,-786 # 8000b6d0 <ticks>
    800029ea:	411c                	lw	a5,0(a0)
    800029ec:	2785                	addiw	a5,a5,1
    800029ee:	c11c                	sw	a5,0(a0)
    wakeup(&ticks);
    800029f0:	a53ff0ef          	jal	80002442 <wakeup>
    release(&tickslock);
    800029f4:	8526                	mv	a0,s1
    800029f6:	b5efe0ef          	jal	80000d54 <release>
    800029fa:	64a2                	ld	s1,8(sp)
    800029fc:	bf75                	j	800029b8 <clockintr+0xe>

00000000800029fe <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    800029fe:	1101                	addi	sp,sp,-32
    80002a00:	ec06                	sd	ra,24(sp)
    80002a02:	e822                	sd	s0,16(sp)
    80002a04:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002a06:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if(scause == 0x8000000000000009L){
    80002a0a:	57fd                	li	a5,-1
    80002a0c:	17fe                	slli	a5,a5,0x3f
    80002a0e:	07a5                	addi	a5,a5,9
    80002a10:	00f70c63          	beq	a4,a5,80002a28 <devintr+0x2a>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000005L){
    80002a14:	57fd                	li	a5,-1
    80002a16:	17fe                	slli	a5,a5,0x3f
    80002a18:	0795                	addi	a5,a5,5
    // timer interrupt.
    clockintr();
    return 2;
  } else {
    return 0;
    80002a1a:	4501                	li	a0,0
  } else if(scause == 0x8000000000000005L){
    80002a1c:	04f70763          	beq	a4,a5,80002a6a <devintr+0x6c>
  }
}
    80002a20:	60e2                	ld	ra,24(sp)
    80002a22:	6442                	ld	s0,16(sp)
    80002a24:	6105                	addi	sp,sp,32
    80002a26:	8082                	ret
    80002a28:	e426                	sd	s1,8(sp)
    int irq = plic_claim();
    80002a2a:	7f3020ef          	jal	80005a1c <plic_claim>
    80002a2e:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    80002a30:	47a9                	li	a5,10
    80002a32:	00f50963          	beq	a0,a5,80002a44 <devintr+0x46>
    } else if(irq == VIRTIO0_IRQ){
    80002a36:	4785                	li	a5,1
    80002a38:	00f50963          	beq	a0,a5,80002a4a <devintr+0x4c>
    return 1;
    80002a3c:	4505                	li	a0,1
    } else if(irq){
    80002a3e:	e889                	bnez	s1,80002a50 <devintr+0x52>
    80002a40:	64a2                	ld	s1,8(sp)
    80002a42:	bff9                	j	80002a20 <devintr+0x22>
      uartintr();
    80002a44:	f9ffd0ef          	jal	800009e2 <uartintr>
    if(irq)
    80002a48:	a819                	j	80002a5e <devintr+0x60>
      virtio_disk_intr();
    80002a4a:	498030ef          	jal	80005ee2 <virtio_disk_intr>
    if(irq)
    80002a4e:	a801                	j	80002a5e <devintr+0x60>
      printf("unexpected interrupt irq=%d\n", irq);
    80002a50:	85a6                	mv	a1,s1
    80002a52:	00006517          	auipc	a0,0x6
    80002a56:	82e50513          	addi	a0,a0,-2002 # 80008280 <etext+0x280>
    80002a5a:	ad3fd0ef          	jal	8000052c <printf>
      plic_complete(irq);
    80002a5e:	8526                	mv	a0,s1
    80002a60:	7dd020ef          	jal	80005a3c <plic_complete>
    return 1;
    80002a64:	4505                	li	a0,1
    80002a66:	64a2                	ld	s1,8(sp)
    80002a68:	bf65                	j	80002a20 <devintr+0x22>
    clockintr();
    80002a6a:	f41ff0ef          	jal	800029aa <clockintr>
    return 2;
    80002a6e:	4509                	li	a0,2
    80002a70:	bf45                	j	80002a20 <devintr+0x22>

0000000080002a72 <usertrap>:
{
    80002a72:	1101                	addi	sp,sp,-32
    80002a74:	ec06                	sd	ra,24(sp)
    80002a76:	e822                	sd	s0,16(sp)
    80002a78:	e426                	sd	s1,8(sp)
    80002a7a:	e04a                	sd	s2,0(sp)
    80002a7c:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002a7e:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    80002a82:	1007f793          	andi	a5,a5,256
    80002a86:	eba5                	bnez	a5,80002af6 <usertrap+0x84>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002a88:	00003797          	auipc	a5,0x3
    80002a8c:	ee878793          	addi	a5,a5,-280 # 80005970 <kernelvec>
    80002a90:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80002a94:	93eff0ef          	jal	80001bd2 <myproc>
    80002a98:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    80002a9a:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002a9c:	14102773          	csrr	a4,sepc
    80002aa0:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002aa2:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    80002aa6:	47a1                	li	a5,8
    80002aa8:	04f70d63          	beq	a4,a5,80002b02 <usertrap+0x90>
  } else if((which_dev = devintr()) != 0){
    80002aac:	f53ff0ef          	jal	800029fe <devintr>
    80002ab0:	892a                	mv	s2,a0
    80002ab2:	e945                	bnez	a0,80002b62 <usertrap+0xf0>
    80002ab4:	14202773          	csrr	a4,scause
  } else if((r_scause() == 15 || r_scause() == 13) &&
    80002ab8:	47bd                	li	a5,15
    80002aba:	08f70863          	beq	a4,a5,80002b4a <usertrap+0xd8>
    80002abe:	14202773          	csrr	a4,scause
    80002ac2:	47b5                	li	a5,13
    80002ac4:	08f70363          	beq	a4,a5,80002b4a <usertrap+0xd8>
    80002ac8:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause 0x%lx pid=%d\n", r_scause(), p->pid);
    80002acc:	5890                	lw	a2,48(s1)
    80002ace:	00005517          	auipc	a0,0x5
    80002ad2:	7f250513          	addi	a0,a0,2034 # 800082c0 <etext+0x2c0>
    80002ad6:	a57fd0ef          	jal	8000052c <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002ada:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002ade:	14302673          	csrr	a2,stval
    printf("            sepc=0x%lx stval=0x%lx\n", r_sepc(), r_stval());
    80002ae2:	00006517          	auipc	a0,0x6
    80002ae6:	80e50513          	addi	a0,a0,-2034 # 800082f0 <etext+0x2f0>
    80002aea:	a43fd0ef          	jal	8000052c <printf>
    setkilled(p);
    80002aee:	8526                	mv	a0,s1
    80002af0:	b1bff0ef          	jal	8000260a <setkilled>
    80002af4:	a035                	j	80002b20 <usertrap+0xae>
    panic("usertrap: not from user mode");
    80002af6:	00005517          	auipc	a0,0x5
    80002afa:	7aa50513          	addi	a0,a0,1962 # 800082a0 <etext+0x2a0>
    80002afe:	d15fd0ef          	jal	80000812 <panic>
    if(killed(p))
    80002b02:	b2dff0ef          	jal	8000262e <killed>
    80002b06:	ed15                	bnez	a0,80002b42 <usertrap+0xd0>
    p->trapframe->epc += 4;
    80002b08:	6cb8                	ld	a4,88(s1)
    80002b0a:	6f1c                	ld	a5,24(a4)
    80002b0c:	0791                	addi	a5,a5,4
    80002b0e:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002b10:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002b14:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002b18:	10079073          	csrw	sstatus,a5
    syscall();
    80002b1c:	246000ef          	jal	80002d62 <syscall>
  if(killed(p))
    80002b20:	8526                	mv	a0,s1
    80002b22:	b0dff0ef          	jal	8000262e <killed>
    80002b26:	e139                	bnez	a0,80002b6c <usertrap+0xfa>
  prepare_return();
    80002b28:	e09ff0ef          	jal	80002930 <prepare_return>
  uint64 satp = MAKE_SATP(p->pagetable);
    80002b2c:	68a8                	ld	a0,80(s1)
    80002b2e:	8131                	srli	a0,a0,0xc
    80002b30:	57fd                	li	a5,-1
    80002b32:	17fe                	slli	a5,a5,0x3f
    80002b34:	8d5d                	or	a0,a0,a5
}
    80002b36:	60e2                	ld	ra,24(sp)
    80002b38:	6442                	ld	s0,16(sp)
    80002b3a:	64a2                	ld	s1,8(sp)
    80002b3c:	6902                	ld	s2,0(sp)
    80002b3e:	6105                	addi	sp,sp,32
    80002b40:	8082                	ret
      kexit(-1);
    80002b42:	557d                	li	a0,-1
    80002b44:	9bfff0ef          	jal	80002502 <kexit>
    80002b48:	b7c1                	j	80002b08 <usertrap+0x96>
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002b4a:	143025f3          	csrr	a1,stval
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002b4e:	14202673          	csrr	a2,scause
            vmfault(p->pagetable, r_stval(), (r_scause() == 13)? 1 : 0) != 0) {
    80002b52:	164d                	addi	a2,a2,-13 # ff3 <_entry-0x7ffff00d>
    80002b54:	00163613          	seqz	a2,a2
    80002b58:	68a8                	ld	a0,80(s1)
    80002b5a:	c99fe0ef          	jal	800017f2 <vmfault>
  } else if((r_scause() == 15 || r_scause() == 13) &&
    80002b5e:	f169                	bnez	a0,80002b20 <usertrap+0xae>
    80002b60:	b7a5                	j	80002ac8 <usertrap+0x56>
  if(killed(p))
    80002b62:	8526                	mv	a0,s1
    80002b64:	acbff0ef          	jal	8000262e <killed>
    80002b68:	c511                	beqz	a0,80002b74 <usertrap+0x102>
    80002b6a:	a011                	j	80002b6e <usertrap+0xfc>
    80002b6c:	4901                	li	s2,0
    kexit(-1);
    80002b6e:	557d                	li	a0,-1
    80002b70:	993ff0ef          	jal	80002502 <kexit>
  if(which_dev == 2)
    80002b74:	4789                	li	a5,2
    80002b76:	faf919e3          	bne	s2,a5,80002b28 <usertrap+0xb6>
    yield();
    80002b7a:	851ff0ef          	jal	800023ca <yield>
    80002b7e:	b76d                	j	80002b28 <usertrap+0xb6>

0000000080002b80 <kerneltrap>:
{
    80002b80:	7179                	addi	sp,sp,-48
    80002b82:	f406                	sd	ra,40(sp)
    80002b84:	f022                	sd	s0,32(sp)
    80002b86:	ec26                	sd	s1,24(sp)
    80002b88:	e84a                	sd	s2,16(sp)
    80002b8a:	e44e                	sd	s3,8(sp)
    80002b8c:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002b8e:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002b92:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002b96:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    80002b9a:	1004f793          	andi	a5,s1,256
    80002b9e:	c795                	beqz	a5,80002bca <kerneltrap+0x4a>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002ba0:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002ba4:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    80002ba6:	eb85                	bnez	a5,80002bd6 <kerneltrap+0x56>
  if((which_dev = devintr()) == 0){
    80002ba8:	e57ff0ef          	jal	800029fe <devintr>
    80002bac:	c91d                	beqz	a0,80002be2 <kerneltrap+0x62>
  if(which_dev == 2 && myproc() != 0)
    80002bae:	4789                	li	a5,2
    80002bb0:	04f50a63          	beq	a0,a5,80002c04 <kerneltrap+0x84>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002bb4:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002bb8:	10049073          	csrw	sstatus,s1
}
    80002bbc:	70a2                	ld	ra,40(sp)
    80002bbe:	7402                	ld	s0,32(sp)
    80002bc0:	64e2                	ld	s1,24(sp)
    80002bc2:	6942                	ld	s2,16(sp)
    80002bc4:	69a2                	ld	s3,8(sp)
    80002bc6:	6145                	addi	sp,sp,48
    80002bc8:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80002bca:	00005517          	auipc	a0,0x5
    80002bce:	74e50513          	addi	a0,a0,1870 # 80008318 <etext+0x318>
    80002bd2:	c41fd0ef          	jal	80000812 <panic>
    panic("kerneltrap: interrupts enabled");
    80002bd6:	00005517          	auipc	a0,0x5
    80002bda:	76a50513          	addi	a0,a0,1898 # 80008340 <etext+0x340>
    80002bde:	c35fd0ef          	jal	80000812 <panic>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002be2:	14102673          	csrr	a2,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002be6:	143026f3          	csrr	a3,stval
    printf("scause=0x%lx sepc=0x%lx stval=0x%lx\n", scause, r_sepc(), r_stval());
    80002bea:	85ce                	mv	a1,s3
    80002bec:	00005517          	auipc	a0,0x5
    80002bf0:	77450513          	addi	a0,a0,1908 # 80008360 <etext+0x360>
    80002bf4:	939fd0ef          	jal	8000052c <printf>
    panic("kerneltrap");
    80002bf8:	00005517          	auipc	a0,0x5
    80002bfc:	79050513          	addi	a0,a0,1936 # 80008388 <etext+0x388>
    80002c00:	c13fd0ef          	jal	80000812 <panic>
  if(which_dev == 2 && myproc() != 0)
    80002c04:	fcffe0ef          	jal	80001bd2 <myproc>
    80002c08:	d555                	beqz	a0,80002bb4 <kerneltrap+0x34>
    yield();
    80002c0a:	fc0ff0ef          	jal	800023ca <yield>
    80002c0e:	b75d                	j	80002bb4 <kerneltrap+0x34>

0000000080002c10 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80002c10:	1101                	addi	sp,sp,-32
    80002c12:	ec06                	sd	ra,24(sp)
    80002c14:	e822                	sd	s0,16(sp)
    80002c16:	e426                	sd	s1,8(sp)
    80002c18:	1000                	addi	s0,sp,32
    80002c1a:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002c1c:	fb7fe0ef          	jal	80001bd2 <myproc>
  switch (n) {
    80002c20:	4795                	li	a5,5
    80002c22:	0497e163          	bltu	a5,s1,80002c64 <argraw+0x54>
    80002c26:	048a                	slli	s1,s1,0x2
    80002c28:	00006717          	auipc	a4,0x6
    80002c2c:	ba870713          	addi	a4,a4,-1112 # 800087d0 <states.0+0x30>
    80002c30:	94ba                	add	s1,s1,a4
    80002c32:	409c                	lw	a5,0(s1)
    80002c34:	97ba                	add	a5,a5,a4
    80002c36:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    80002c38:	6d3c                	ld	a5,88(a0)
    80002c3a:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80002c3c:	60e2                	ld	ra,24(sp)
    80002c3e:	6442                	ld	s0,16(sp)
    80002c40:	64a2                	ld	s1,8(sp)
    80002c42:	6105                	addi	sp,sp,32
    80002c44:	8082                	ret
    return p->trapframe->a1;
    80002c46:	6d3c                	ld	a5,88(a0)
    80002c48:	7fa8                	ld	a0,120(a5)
    80002c4a:	bfcd                	j	80002c3c <argraw+0x2c>
    return p->trapframe->a2;
    80002c4c:	6d3c                	ld	a5,88(a0)
    80002c4e:	63c8                	ld	a0,128(a5)
    80002c50:	b7f5                	j	80002c3c <argraw+0x2c>
    return p->trapframe->a3;
    80002c52:	6d3c                	ld	a5,88(a0)
    80002c54:	67c8                	ld	a0,136(a5)
    80002c56:	b7dd                	j	80002c3c <argraw+0x2c>
    return p->trapframe->a4;
    80002c58:	6d3c                	ld	a5,88(a0)
    80002c5a:	6bc8                	ld	a0,144(a5)
    80002c5c:	b7c5                	j	80002c3c <argraw+0x2c>
    return p->trapframe->a5;
    80002c5e:	6d3c                	ld	a5,88(a0)
    80002c60:	6fc8                	ld	a0,152(a5)
    80002c62:	bfe9                	j	80002c3c <argraw+0x2c>
  panic("argraw");
    80002c64:	00005517          	auipc	a0,0x5
    80002c68:	73450513          	addi	a0,a0,1844 # 80008398 <etext+0x398>
    80002c6c:	ba7fd0ef          	jal	80000812 <panic>

0000000080002c70 <fetchaddr>:
{
    80002c70:	1101                	addi	sp,sp,-32
    80002c72:	ec06                	sd	ra,24(sp)
    80002c74:	e822                	sd	s0,16(sp)
    80002c76:	e426                	sd	s1,8(sp)
    80002c78:	e04a                	sd	s2,0(sp)
    80002c7a:	1000                	addi	s0,sp,32
    80002c7c:	84aa                	mv	s1,a0
    80002c7e:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002c80:	f53fe0ef          	jal	80001bd2 <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    80002c84:	653c                	ld	a5,72(a0)
    80002c86:	02f4f663          	bgeu	s1,a5,80002cb2 <fetchaddr+0x42>
    80002c8a:	00848713          	addi	a4,s1,8
    80002c8e:	02e7e463          	bltu	a5,a4,80002cb6 <fetchaddr+0x46>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80002c92:	46a1                	li	a3,8
    80002c94:	8626                	mv	a2,s1
    80002c96:	85ca                	mv	a1,s2
    80002c98:	6928                	ld	a0,80(a0)
    80002c9a:	d1dfe0ef          	jal	800019b6 <copyin>
    80002c9e:	00a03533          	snez	a0,a0
    80002ca2:	40a00533          	neg	a0,a0
}
    80002ca6:	60e2                	ld	ra,24(sp)
    80002ca8:	6442                	ld	s0,16(sp)
    80002caa:	64a2                	ld	s1,8(sp)
    80002cac:	6902                	ld	s2,0(sp)
    80002cae:	6105                	addi	sp,sp,32
    80002cb0:	8082                	ret
    return -1;
    80002cb2:	557d                	li	a0,-1
    80002cb4:	bfcd                	j	80002ca6 <fetchaddr+0x36>
    80002cb6:	557d                	li	a0,-1
    80002cb8:	b7fd                	j	80002ca6 <fetchaddr+0x36>

0000000080002cba <fetchstr>:
{
    80002cba:	7179                	addi	sp,sp,-48
    80002cbc:	f406                	sd	ra,40(sp)
    80002cbe:	f022                	sd	s0,32(sp)
    80002cc0:	ec26                	sd	s1,24(sp)
    80002cc2:	e84a                	sd	s2,16(sp)
    80002cc4:	e44e                	sd	s3,8(sp)
    80002cc6:	1800                	addi	s0,sp,48
    80002cc8:	892a                	mv	s2,a0
    80002cca:	84ae                	mv	s1,a1
    80002ccc:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80002cce:	f05fe0ef          	jal	80001bd2 <myproc>
  if(copyinstr(p->pagetable, buf, addr, max) < 0)
    80002cd2:	86ce                	mv	a3,s3
    80002cd4:	864a                	mv	a2,s2
    80002cd6:	85a6                	mv	a1,s1
    80002cd8:	6928                	ld	a0,80(a0)
    80002cda:	a41fe0ef          	jal	8000171a <copyinstr>
    80002cde:	00054c63          	bltz	a0,80002cf6 <fetchstr+0x3c>
  return strlen(buf);
    80002ce2:	8526                	mv	a0,s1
    80002ce4:	a1cfe0ef          	jal	80000f00 <strlen>
}
    80002ce8:	70a2                	ld	ra,40(sp)
    80002cea:	7402                	ld	s0,32(sp)
    80002cec:	64e2                	ld	s1,24(sp)
    80002cee:	6942                	ld	s2,16(sp)
    80002cf0:	69a2                	ld	s3,8(sp)
    80002cf2:	6145                	addi	sp,sp,48
    80002cf4:	8082                	ret
    return -1;
    80002cf6:	557d                	li	a0,-1
    80002cf8:	bfc5                	j	80002ce8 <fetchstr+0x2e>

0000000080002cfa <argint>:

// Fetch the nth 32-bit system call argument.
void
argint(int n, int *ip)
{
    80002cfa:	1101                	addi	sp,sp,-32
    80002cfc:	ec06                	sd	ra,24(sp)
    80002cfe:	e822                	sd	s0,16(sp)
    80002d00:	e426                	sd	s1,8(sp)
    80002d02:	1000                	addi	s0,sp,32
    80002d04:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002d06:	f0bff0ef          	jal	80002c10 <argraw>
    80002d0a:	c088                	sw	a0,0(s1)
}
    80002d0c:	60e2                	ld	ra,24(sp)
    80002d0e:	6442                	ld	s0,16(sp)
    80002d10:	64a2                	ld	s1,8(sp)
    80002d12:	6105                	addi	sp,sp,32
    80002d14:	8082                	ret

0000000080002d16 <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void
argaddr(int n, uint64 *ip)
{
    80002d16:	1101                	addi	sp,sp,-32
    80002d18:	ec06                	sd	ra,24(sp)
    80002d1a:	e822                	sd	s0,16(sp)
    80002d1c:	e426                	sd	s1,8(sp)
    80002d1e:	1000                	addi	s0,sp,32
    80002d20:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002d22:	eefff0ef          	jal	80002c10 <argraw>
    80002d26:	e088                	sd	a0,0(s1)
}
    80002d28:	60e2                	ld	ra,24(sp)
    80002d2a:	6442                	ld	s0,16(sp)
    80002d2c:	64a2                	ld	s1,8(sp)
    80002d2e:	6105                	addi	sp,sp,32
    80002d30:	8082                	ret

0000000080002d32 <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80002d32:	7179                	addi	sp,sp,-48
    80002d34:	f406                	sd	ra,40(sp)
    80002d36:	f022                	sd	s0,32(sp)
    80002d38:	ec26                	sd	s1,24(sp)
    80002d3a:	e84a                	sd	s2,16(sp)
    80002d3c:	1800                	addi	s0,sp,48
    80002d3e:	84ae                	mv	s1,a1
    80002d40:	8932                	mv	s2,a2
  uint64 addr;
  argaddr(n, &addr);
    80002d42:	fd840593          	addi	a1,s0,-40
    80002d46:	fd1ff0ef          	jal	80002d16 <argaddr>
  return fetchstr(addr, buf, max);
    80002d4a:	864a                	mv	a2,s2
    80002d4c:	85a6                	mv	a1,s1
    80002d4e:	fd843503          	ld	a0,-40(s0)
    80002d52:	f69ff0ef          	jal	80002cba <fetchstr>
}
    80002d56:	70a2                	ld	ra,40(sp)
    80002d58:	7402                	ld	s0,32(sp)
    80002d5a:	64e2                	ld	s1,24(sp)
    80002d5c:	6942                	ld	s2,16(sp)
    80002d5e:	6145                	addi	sp,sp,48
    80002d60:	8082                	ret

0000000080002d62 <syscall>:

};

void
syscall(void)
{
    80002d62:	1101                	addi	sp,sp,-32
    80002d64:	ec06                	sd	ra,24(sp)
    80002d66:	e822                	sd	s0,16(sp)
    80002d68:	e426                	sd	s1,8(sp)
    80002d6a:	e04a                	sd	s2,0(sp)
    80002d6c:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    80002d6e:	e65fe0ef          	jal	80001bd2 <myproc>
    80002d72:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    80002d74:	05853903          	ld	s2,88(a0)
    80002d78:	0a893783          	ld	a5,168(s2)
    80002d7c:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80002d80:	37fd                	addiw	a5,a5,-1
    80002d82:	4761                	li	a4,24
    80002d84:	00f76f63          	bltu	a4,a5,80002da2 <syscall+0x40>
    80002d88:	00369713          	slli	a4,a3,0x3
    80002d8c:	00006797          	auipc	a5,0x6
    80002d90:	a5c78793          	addi	a5,a5,-1444 # 800087e8 <syscalls>
    80002d94:	97ba                	add	a5,a5,a4
    80002d96:	639c                	ld	a5,0(a5)
    80002d98:	c789                	beqz	a5,80002da2 <syscall+0x40>
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    p->trapframe->a0 = syscalls[num]();
    80002d9a:	9782                	jalr	a5
    80002d9c:	06a93823          	sd	a0,112(s2)
    80002da0:	a829                	j	80002dba <syscall+0x58>
  } else {
    printf("%d %s: unknown sys call %d\n",
    80002da2:	15848613          	addi	a2,s1,344
    80002da6:	588c                	lw	a1,48(s1)
    80002da8:	00005517          	auipc	a0,0x5
    80002dac:	5f850513          	addi	a0,a0,1528 # 800083a0 <etext+0x3a0>
    80002db0:	f7cfd0ef          	jal	8000052c <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80002db4:	6cbc                	ld	a5,88(s1)
    80002db6:	577d                	li	a4,-1
    80002db8:	fbb8                	sd	a4,112(a5)
  }
}
    80002dba:	60e2                	ld	ra,24(sp)
    80002dbc:	6442                	ld	s0,16(sp)
    80002dbe:	64a2                	ld	s1,8(sp)
    80002dc0:	6902                	ld	s2,0(sp)
    80002dc2:	6105                	addi	sp,sp,32
    80002dc4:	8082                	ret

0000000080002dc6 <sys_exit>:
#include "vm.h"
#include "schedlog.h"

uint64
sys_exit(void)
{
    80002dc6:	1101                	addi	sp,sp,-32
    80002dc8:	ec06                	sd	ra,24(sp)
    80002dca:	e822                	sd	s0,16(sp)
    80002dcc:	1000                	addi	s0,sp,32
  int n;
  argint(0, &n);
    80002dce:	fec40593          	addi	a1,s0,-20
    80002dd2:	4501                	li	a0,0
    80002dd4:	f27ff0ef          	jal	80002cfa <argint>
  kexit(n);
    80002dd8:	fec42503          	lw	a0,-20(s0)
    80002ddc:	f26ff0ef          	jal	80002502 <kexit>
  return 0;  // not reached
}
    80002de0:	4501                	li	a0,0
    80002de2:	60e2                	ld	ra,24(sp)
    80002de4:	6442                	ld	s0,16(sp)
    80002de6:	6105                	addi	sp,sp,32
    80002de8:	8082                	ret

0000000080002dea <sys_getpid>:

uint64
sys_getpid(void)
{
    80002dea:	1141                	addi	sp,sp,-16
    80002dec:	e406                	sd	ra,8(sp)
    80002dee:	e022                	sd	s0,0(sp)
    80002df0:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80002df2:	de1fe0ef          	jal	80001bd2 <myproc>
}
    80002df6:	5908                	lw	a0,48(a0)
    80002df8:	60a2                	ld	ra,8(sp)
    80002dfa:	6402                	ld	s0,0(sp)
    80002dfc:	0141                	addi	sp,sp,16
    80002dfe:	8082                	ret

0000000080002e00 <sys_fork>:

uint64
sys_fork(void)
{
    80002e00:	1141                	addi	sp,sp,-16
    80002e02:	e406                	sd	ra,8(sp)
    80002e04:	e022                	sd	s0,0(sp)
    80002e06:	0800                	addi	s0,sp,16
  return kfork();
    80002e08:	99aff0ef          	jal	80001fa2 <kfork>
}
    80002e0c:	60a2                	ld	ra,8(sp)
    80002e0e:	6402                	ld	s0,0(sp)
    80002e10:	0141                	addi	sp,sp,16
    80002e12:	8082                	ret

0000000080002e14 <sys_wait>:

uint64
sys_wait(void)
{
    80002e14:	1101                	addi	sp,sp,-32
    80002e16:	ec06                	sd	ra,24(sp)
    80002e18:	e822                	sd	s0,16(sp)
    80002e1a:	1000                	addi	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    80002e1c:	fe840593          	addi	a1,s0,-24
    80002e20:	4501                	li	a0,0
    80002e22:	ef5ff0ef          	jal	80002d16 <argaddr>
  return kwait(p);
    80002e26:	fe843503          	ld	a0,-24(s0)
    80002e2a:	82fff0ef          	jal	80002658 <kwait>
}
    80002e2e:	60e2                	ld	ra,24(sp)
    80002e30:	6442                	ld	s0,16(sp)
    80002e32:	6105                	addi	sp,sp,32
    80002e34:	8082                	ret

0000000080002e36 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80002e36:	7179                	addi	sp,sp,-48
    80002e38:	f406                	sd	ra,40(sp)
    80002e3a:	f022                	sd	s0,32(sp)
    80002e3c:	ec26                	sd	s1,24(sp)
    80002e3e:	1800                	addi	s0,sp,48
  uint64 addr;
  int t;
  int n;

  argint(0, &n);
    80002e40:	fd840593          	addi	a1,s0,-40
    80002e44:	4501                	li	a0,0
    80002e46:	eb5ff0ef          	jal	80002cfa <argint>
  argint(1, &t);
    80002e4a:	fdc40593          	addi	a1,s0,-36
    80002e4e:	4505                	li	a0,1
    80002e50:	eabff0ef          	jal	80002cfa <argint>
  addr = myproc()->sz;
    80002e54:	d7ffe0ef          	jal	80001bd2 <myproc>
    80002e58:	6524                	ld	s1,72(a0)

  if(t == SBRK_EAGER || n < 0) {
    80002e5a:	fdc42703          	lw	a4,-36(s0)
    80002e5e:	4785                	li	a5,1
    80002e60:	02f70763          	beq	a4,a5,80002e8e <sys_sbrk+0x58>
    80002e64:	fd842783          	lw	a5,-40(s0)
    80002e68:	0207c363          	bltz	a5,80002e8e <sys_sbrk+0x58>
    }
  } else {
    // Lazily allocate memory for this process: increase its memory
    // size but don't allocate memory. If the processes uses the
    // memory, vmfault() will allocate it.
    if(addr + n < addr)
    80002e6c:	97a6                	add	a5,a5,s1
    80002e6e:	0297ee63          	bltu	a5,s1,80002eaa <sys_sbrk+0x74>
      return -1;
    if(addr + n > TRAPFRAME)
    80002e72:	02000737          	lui	a4,0x2000
    80002e76:	177d                	addi	a4,a4,-1 # 1ffffff <_entry-0x7e000001>
    80002e78:	0736                	slli	a4,a4,0xd
    80002e7a:	02f76a63          	bltu	a4,a5,80002eae <sys_sbrk+0x78>
      return -1;
    myproc()->sz += n;
    80002e7e:	d55fe0ef          	jal	80001bd2 <myproc>
    80002e82:	fd842703          	lw	a4,-40(s0)
    80002e86:	653c                	ld	a5,72(a0)
    80002e88:	97ba                	add	a5,a5,a4
    80002e8a:	e53c                	sd	a5,72(a0)
    80002e8c:	a039                	j	80002e9a <sys_sbrk+0x64>
    if(growproc(n) < 0) {
    80002e8e:	fd842503          	lw	a0,-40(s0)
    80002e92:	842ff0ef          	jal	80001ed4 <growproc>
    80002e96:	00054863          	bltz	a0,80002ea6 <sys_sbrk+0x70>
  }
  return addr;
}
    80002e9a:	8526                	mv	a0,s1
    80002e9c:	70a2                	ld	ra,40(sp)
    80002e9e:	7402                	ld	s0,32(sp)
    80002ea0:	64e2                	ld	s1,24(sp)
    80002ea2:	6145                	addi	sp,sp,48
    80002ea4:	8082                	ret
      return -1;
    80002ea6:	54fd                	li	s1,-1
    80002ea8:	bfcd                	j	80002e9a <sys_sbrk+0x64>
      return -1;
    80002eaa:	54fd                	li	s1,-1
    80002eac:	b7fd                	j	80002e9a <sys_sbrk+0x64>
      return -1;
    80002eae:	54fd                	li	s1,-1
    80002eb0:	b7ed                	j	80002e9a <sys_sbrk+0x64>

0000000080002eb2 <sys_pause>:

uint64
sys_pause(void)
{
    80002eb2:	7139                	addi	sp,sp,-64
    80002eb4:	fc06                	sd	ra,56(sp)
    80002eb6:	f822                	sd	s0,48(sp)
    80002eb8:	f04a                	sd	s2,32(sp)
    80002eba:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    80002ebc:	fcc40593          	addi	a1,s0,-52
    80002ec0:	4501                	li	a0,0
    80002ec2:	e39ff0ef          	jal	80002cfa <argint>
  if(n < 0)
    80002ec6:	fcc42783          	lw	a5,-52(s0)
    80002eca:	0607c763          	bltz	a5,80002f38 <sys_pause+0x86>
    n = 0;
  acquire(&tickslock);
    80002ece:	00016517          	auipc	a0,0x16
    80002ed2:	7a250513          	addi	a0,a0,1954 # 80019670 <tickslock>
    80002ed6:	de7fd0ef          	jal	80000cbc <acquire>
  ticks0 = ticks;
    80002eda:	00008917          	auipc	s2,0x8
    80002ede:	7f692903          	lw	s2,2038(s2) # 8000b6d0 <ticks>
  while(ticks - ticks0 < n){
    80002ee2:	fcc42783          	lw	a5,-52(s0)
    80002ee6:	cf8d                	beqz	a5,80002f20 <sys_pause+0x6e>
    80002ee8:	f426                	sd	s1,40(sp)
    80002eea:	ec4e                	sd	s3,24(sp)
    if(killed(myproc())){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80002eec:	00016997          	auipc	s3,0x16
    80002ef0:	78498993          	addi	s3,s3,1924 # 80019670 <tickslock>
    80002ef4:	00008497          	auipc	s1,0x8
    80002ef8:	7dc48493          	addi	s1,s1,2012 # 8000b6d0 <ticks>
    if(killed(myproc())){
    80002efc:	cd7fe0ef          	jal	80001bd2 <myproc>
    80002f00:	f2eff0ef          	jal	8000262e <killed>
    80002f04:	ed0d                	bnez	a0,80002f3e <sys_pause+0x8c>
    sleep(&ticks, &tickslock);
    80002f06:	85ce                	mv	a1,s3
    80002f08:	8526                	mv	a0,s1
    80002f0a:	cecff0ef          	jal	800023f6 <sleep>
  while(ticks - ticks0 < n){
    80002f0e:	409c                	lw	a5,0(s1)
    80002f10:	412787bb          	subw	a5,a5,s2
    80002f14:	fcc42703          	lw	a4,-52(s0)
    80002f18:	fee7e2e3          	bltu	a5,a4,80002efc <sys_pause+0x4a>
    80002f1c:	74a2                	ld	s1,40(sp)
    80002f1e:	69e2                	ld	s3,24(sp)
  }
  release(&tickslock);
    80002f20:	00016517          	auipc	a0,0x16
    80002f24:	75050513          	addi	a0,a0,1872 # 80019670 <tickslock>
    80002f28:	e2dfd0ef          	jal	80000d54 <release>
  return 0;
    80002f2c:	4501                	li	a0,0
}
    80002f2e:	70e2                	ld	ra,56(sp)
    80002f30:	7442                	ld	s0,48(sp)
    80002f32:	7902                	ld	s2,32(sp)
    80002f34:	6121                	addi	sp,sp,64
    80002f36:	8082                	ret
    n = 0;
    80002f38:	fc042623          	sw	zero,-52(s0)
    80002f3c:	bf49                	j	80002ece <sys_pause+0x1c>
      release(&tickslock);
    80002f3e:	00016517          	auipc	a0,0x16
    80002f42:	73250513          	addi	a0,a0,1842 # 80019670 <tickslock>
    80002f46:	e0ffd0ef          	jal	80000d54 <release>
      return -1;
    80002f4a:	557d                	li	a0,-1
    80002f4c:	74a2                	ld	s1,40(sp)
    80002f4e:	69e2                	ld	s3,24(sp)
    80002f50:	bff9                	j	80002f2e <sys_pause+0x7c>

0000000080002f52 <sys_kill>:

uint64
sys_kill(void)
{
    80002f52:	1101                	addi	sp,sp,-32
    80002f54:	ec06                	sd	ra,24(sp)
    80002f56:	e822                	sd	s0,16(sp)
    80002f58:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    80002f5a:	fec40593          	addi	a1,s0,-20
    80002f5e:	4501                	li	a0,0
    80002f60:	d9bff0ef          	jal	80002cfa <argint>
  return kkill(pid);
    80002f64:	fec42503          	lw	a0,-20(s0)
    80002f68:	e3cff0ef          	jal	800025a4 <kkill>
}
    80002f6c:	60e2                	ld	ra,24(sp)
    80002f6e:	6442                	ld	s0,16(sp)
    80002f70:	6105                	addi	sp,sp,32
    80002f72:	8082                	ret

0000000080002f74 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80002f74:	1101                	addi	sp,sp,-32
    80002f76:	ec06                	sd	ra,24(sp)
    80002f78:	e822                	sd	s0,16(sp)
    80002f7a:	e426                	sd	s1,8(sp)
    80002f7c:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80002f7e:	00016517          	auipc	a0,0x16
    80002f82:	6f250513          	addi	a0,a0,1778 # 80019670 <tickslock>
    80002f86:	d37fd0ef          	jal	80000cbc <acquire>
  xticks = ticks;
    80002f8a:	00008497          	auipc	s1,0x8
    80002f8e:	7464a483          	lw	s1,1862(s1) # 8000b6d0 <ticks>
  release(&tickslock);
    80002f92:	00016517          	auipc	a0,0x16
    80002f96:	6de50513          	addi	a0,a0,1758 # 80019670 <tickslock>
    80002f9a:	dbbfd0ef          	jal	80000d54 <release>
  return xticks;
}
    80002f9e:	02049513          	slli	a0,s1,0x20
    80002fa2:	9101                	srli	a0,a0,0x20
    80002fa4:	60e2                	ld	ra,24(sp)
    80002fa6:	6442                	ld	s0,16(sp)
    80002fa8:	64a2                	ld	s1,8(sp)
    80002faa:	6105                	addi	sp,sp,32
    80002fac:	8082                	ret

0000000080002fae <sys_schedread>:

uint64
sys_schedread(void)
{
    80002fae:	7131                	addi	sp,sp,-192
    80002fb0:	fd06                	sd	ra,184(sp)
    80002fb2:	f922                	sd	s0,176(sp)
    80002fb4:	f526                	sd	s1,168(sp)
    80002fb6:	f14a                	sd	s2,160(sp)
    80002fb8:	0180                	addi	s0,sp,192
    80002fba:	81010113          	addi	sp,sp,-2032
  uint64 dst;
  int max;

  argaddr(0, &dst);
    80002fbe:	fd840593          	addi	a1,s0,-40
    80002fc2:	4501                	li	a0,0
    80002fc4:	d53ff0ef          	jal	80002d16 <argaddr>
  argint(1, &max);
    80002fc8:	fd440593          	addi	a1,s0,-44
    80002fcc:	4505                	li	a0,1
    80002fce:	d2dff0ef          	jal	80002cfa <argint>

  if(max <= 0)
    80002fd2:	fd442783          	lw	a5,-44(s0)
    return 0;
    80002fd6:	4901                	li	s2,0
  if(max <= 0)
    80002fd8:	04f05a63          	blez	a5,8000302c <sys_schedread+0x7e>

  struct sched_event buf[32];
  if(max > 32)
    80002fdc:	02000713          	li	a4,32
    80002fe0:	00f75663          	bge	a4,a5,80002fec <sys_schedread+0x3e>
    max = 32;
    80002fe4:	02000793          	li	a5,32
    80002fe8:	fcf42a23          	sw	a5,-44(s0)

  int n = schedread(buf, max);
    80002fec:	757d                	lui	a0,0xfffff
    80002fee:	fd442583          	lw	a1,-44(s0)
    80002ff2:	75050793          	addi	a5,a0,1872 # fffffffffffff750 <end+0xffffffff7ffb5c58>
    80002ff6:	00878533          	add	a0,a5,s0
    80002ffa:	6fa030ef          	jal	800066f4 <schedread>
    80002ffe:	84aa                	mv	s1,a0
  if(n < 0)
    return -1;
    80003000:	597d                	li	s2,-1
  if(n < 0)
    80003002:	02054563          	bltz	a0,8000302c <sys_schedread+0x7e>

  if(copyout(myproc()->pagetable, dst, (char *)buf, n * sizeof(struct sched_event)) < 0)
    80003006:	bcdfe0ef          	jal	80001bd2 <myproc>
    8000300a:	8926                	mv	s2,s1
    8000300c:	00449693          	slli	a3,s1,0x4
    80003010:	96a6                	add	a3,a3,s1
    80003012:	767d                	lui	a2,0xfffff
    80003014:	068a                	slli	a3,a3,0x2
    80003016:	75060793          	addi	a5,a2,1872 # fffffffffffff750 <end+0xffffffff7ffb5c58>
    8000301a:	00878633          	add	a2,a5,s0
    8000301e:	fd843583          	ld	a1,-40(s0)
    80003022:	6928                	ld	a0,80(a0)
    80003024:	8affe0ef          	jal	800018d2 <copyout>
    80003028:	00054b63          	bltz	a0,8000303e <sys_schedread+0x90>
    return -1;

  return n;
}
    8000302c:	854a                	mv	a0,s2
    8000302e:	7f010113          	addi	sp,sp,2032
    80003032:	70ea                	ld	ra,184(sp)
    80003034:	744a                	ld	s0,176(sp)
    80003036:	74aa                	ld	s1,168(sp)
    80003038:	790a                	ld	s2,160(sp)
    8000303a:	6129                	addi	sp,sp,192
    8000303c:	8082                	ret
    return -1;
    8000303e:	597d                	li	s2,-1
    80003040:	b7f5                	j	8000302c <sys_schedread+0x7e>

0000000080003042 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80003042:	7179                	addi	sp,sp,-48
    80003044:	f406                	sd	ra,40(sp)
    80003046:	f022                	sd	s0,32(sp)
    80003048:	ec26                	sd	s1,24(sp)
    8000304a:	e84a                	sd	s2,16(sp)
    8000304c:	e44e                	sd	s3,8(sp)
    8000304e:	e052                	sd	s4,0(sp)
    80003050:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80003052:	00005597          	auipc	a1,0x5
    80003056:	36e58593          	addi	a1,a1,878 # 800083c0 <etext+0x3c0>
    8000305a:	00016517          	auipc	a0,0x16
    8000305e:	62e50513          	addi	a0,a0,1582 # 80019688 <bcache>
    80003062:	bdbfd0ef          	jal	80000c3c <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80003066:	0001e797          	auipc	a5,0x1e
    8000306a:	62278793          	addi	a5,a5,1570 # 80021688 <bcache+0x8000>
    8000306e:	0001f717          	auipc	a4,0x1f
    80003072:	88270713          	addi	a4,a4,-1918 # 800218f0 <bcache+0x8268>
    80003076:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    8000307a:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    8000307e:	00016497          	auipc	s1,0x16
    80003082:	62248493          	addi	s1,s1,1570 # 800196a0 <bcache+0x18>
    b->next = bcache.head.next;
    80003086:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80003088:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    8000308a:	00005a17          	auipc	s4,0x5
    8000308e:	33ea0a13          	addi	s4,s4,830 # 800083c8 <etext+0x3c8>
    b->next = bcache.head.next;
    80003092:	2b893783          	ld	a5,696(s2)
    80003096:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80003098:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    8000309c:	85d2                	mv	a1,s4
    8000309e:	01048513          	addi	a0,s1,16
    800030a2:	360010ef          	jal	80004402 <initsleeplock>
    bcache.head.next->prev = b;
    800030a6:	2b893783          	ld	a5,696(s2)
    800030aa:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    800030ac:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    800030b0:	45848493          	addi	s1,s1,1112
    800030b4:	fd349fe3          	bne	s1,s3,80003092 <binit+0x50>
  }
}
    800030b8:	70a2                	ld	ra,40(sp)
    800030ba:	7402                	ld	s0,32(sp)
    800030bc:	64e2                	ld	s1,24(sp)
    800030be:	6942                	ld	s2,16(sp)
    800030c0:	69a2                	ld	s3,8(sp)
    800030c2:	6a02                	ld	s4,0(sp)
    800030c4:	6145                	addi	sp,sp,48
    800030c6:	8082                	ret

00000000800030c8 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    800030c8:	7179                	addi	sp,sp,-48
    800030ca:	f406                	sd	ra,40(sp)
    800030cc:	f022                	sd	s0,32(sp)
    800030ce:	ec26                	sd	s1,24(sp)
    800030d0:	e84a                	sd	s2,16(sp)
    800030d2:	e44e                	sd	s3,8(sp)
    800030d4:	1800                	addi	s0,sp,48
    800030d6:	892a                	mv	s2,a0
    800030d8:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    800030da:	00016517          	auipc	a0,0x16
    800030de:	5ae50513          	addi	a0,a0,1454 # 80019688 <bcache>
    800030e2:	bdbfd0ef          	jal	80000cbc <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    800030e6:	0001f497          	auipc	s1,0x1f
    800030ea:	85a4b483          	ld	s1,-1958(s1) # 80021940 <bcache+0x82b8>
    800030ee:	0001f797          	auipc	a5,0x1f
    800030f2:	80278793          	addi	a5,a5,-2046 # 800218f0 <bcache+0x8268>
    800030f6:	04f48563          	beq	s1,a5,80003140 <bread+0x78>
    800030fa:	873e                	mv	a4,a5
    800030fc:	a021                	j	80003104 <bread+0x3c>
    800030fe:	68a4                	ld	s1,80(s1)
    80003100:	04e48063          	beq	s1,a4,80003140 <bread+0x78>
    if(b->dev == dev && b->blockno == blockno){
    80003104:	449c                	lw	a5,8(s1)
    80003106:	ff279ce3          	bne	a5,s2,800030fe <bread+0x36>
    8000310a:	44dc                	lw	a5,12(s1)
    8000310c:	ff3799e3          	bne	a5,s3,800030fe <bread+0x36>
      b->refcnt++;
    80003110:	40bc                	lw	a5,64(s1)
    80003112:	2785                	addiw	a5,a5,1
    80003114:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80003116:	00016517          	auipc	a0,0x16
    8000311a:	57250513          	addi	a0,a0,1394 # 80019688 <bcache>
    8000311e:	c37fd0ef          	jal	80000d54 <release>
      acquiresleep(&b->lock);
    80003122:	01048513          	addi	a0,s1,16
    80003126:	312010ef          	jal	80004438 <acquiresleep>
      fslog_push(FS_BGET_HIT, 0, blockno, 0, "BCACHE");
    8000312a:	00005717          	auipc	a4,0x5
    8000312e:	2a670713          	addi	a4,a4,678 # 800083d0 <etext+0x3d0>
    80003132:	4681                	li	a3,0
    80003134:	864e                	mv	a2,s3
    80003136:	4581                	li	a1,0
    80003138:	4519                	li	a0,6
    8000313a:	1be030ef          	jal	800062f8 <fslog_push>
      return b;
    8000313e:	a09d                	j	800031a4 <bread+0xdc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80003140:	0001e497          	auipc	s1,0x1e
    80003144:	7f84b483          	ld	s1,2040(s1) # 80021938 <bcache+0x82b0>
    80003148:	0001e797          	auipc	a5,0x1e
    8000314c:	7a878793          	addi	a5,a5,1960 # 800218f0 <bcache+0x8268>
    80003150:	00f48863          	beq	s1,a5,80003160 <bread+0x98>
    80003154:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    80003156:	40bc                	lw	a5,64(s1)
    80003158:	cb91                	beqz	a5,8000316c <bread+0xa4>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    8000315a:	64a4                	ld	s1,72(s1)
    8000315c:	fee49de3          	bne	s1,a4,80003156 <bread+0x8e>
  panic("bget: no buffers");
    80003160:	00005517          	auipc	a0,0x5
    80003164:	27850513          	addi	a0,a0,632 # 800083d8 <etext+0x3d8>
    80003168:	eaafd0ef          	jal	80000812 <panic>
      b->dev = dev;
    8000316c:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    80003170:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    80003174:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80003178:	4785                	li	a5,1
    8000317a:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    8000317c:	00016517          	auipc	a0,0x16
    80003180:	50c50513          	addi	a0,a0,1292 # 80019688 <bcache>
    80003184:	bd1fd0ef          	jal	80000d54 <release>
      acquiresleep(&b->lock);
    80003188:	01048513          	addi	a0,s1,16
    8000318c:	2ac010ef          	jal	80004438 <acquiresleep>
      fslog_push(FS_BGET_MISS, 0, blockno, 0, "BCACHE");
    80003190:	00005717          	auipc	a4,0x5
    80003194:	24070713          	addi	a4,a4,576 # 800083d0 <etext+0x3d0>
    80003198:	4681                	li	a3,0
    8000319a:	864e                	mv	a2,s3
    8000319c:	4581                	li	a1,0
    8000319e:	451d                	li	a0,7
    800031a0:	158030ef          	jal	800062f8 <fslog_push>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    800031a4:	409c                	lw	a5,0(s1)
    800031a6:	cb89                	beqz	a5,800031b8 <bread+0xf0>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    800031a8:	8526                	mv	a0,s1
    800031aa:	70a2                	ld	ra,40(sp)
    800031ac:	7402                	ld	s0,32(sp)
    800031ae:	64e2                	ld	s1,24(sp)
    800031b0:	6942                	ld	s2,16(sp)
    800031b2:	69a2                	ld	s3,8(sp)
    800031b4:	6145                	addi	sp,sp,48
    800031b6:	8082                	ret
    virtio_disk_rw(b, 0);
    800031b8:	4581                	li	a1,0
    800031ba:	8526                	mv	a0,s1
    800031bc:	315020ef          	jal	80005cd0 <virtio_disk_rw>
    b->valid = 1;
    800031c0:	4785                	li	a5,1
    800031c2:	c09c                	sw	a5,0(s1)
  return b;
    800031c4:	b7d5                	j	800031a8 <bread+0xe0>

00000000800031c6 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    800031c6:	1101                	addi	sp,sp,-32
    800031c8:	ec06                	sd	ra,24(sp)
    800031ca:	e822                	sd	s0,16(sp)
    800031cc:	e426                	sd	s1,8(sp)
    800031ce:	1000                	addi	s0,sp,32
    800031d0:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    800031d2:	0541                	addi	a0,a0,16
    800031d4:	2e2010ef          	jal	800044b6 <holdingsleep>
    800031d8:	c911                	beqz	a0,800031ec <bwrite+0x26>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    800031da:	4585                	li	a1,1
    800031dc:	8526                	mv	a0,s1
    800031de:	2f3020ef          	jal	80005cd0 <virtio_disk_rw>
}
    800031e2:	60e2                	ld	ra,24(sp)
    800031e4:	6442                	ld	s0,16(sp)
    800031e6:	64a2                	ld	s1,8(sp)
    800031e8:	6105                	addi	sp,sp,32
    800031ea:	8082                	ret
    panic("bwrite");
    800031ec:	00005517          	auipc	a0,0x5
    800031f0:	20450513          	addi	a0,a0,516 # 800083f0 <etext+0x3f0>
    800031f4:	e1efd0ef          	jal	80000812 <panic>

00000000800031f8 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    800031f8:	1101                	addi	sp,sp,-32
    800031fa:	ec06                	sd	ra,24(sp)
    800031fc:	e822                	sd	s0,16(sp)
    800031fe:	e426                	sd	s1,8(sp)
    80003200:	e04a                	sd	s2,0(sp)
    80003202:	1000                	addi	s0,sp,32
    80003204:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80003206:	01050913          	addi	s2,a0,16
    8000320a:	854a                	mv	a0,s2
    8000320c:	2aa010ef          	jal	800044b6 <holdingsleep>
    80003210:	cd05                	beqz	a0,80003248 <brelse+0x50>
    panic("brelse");

  releasesleep(&b->lock);
    80003212:	854a                	mv	a0,s2
    80003214:	26a010ef          	jal	8000447e <releasesleep>

  acquire(&bcache.lock);
    80003218:	00016517          	auipc	a0,0x16
    8000321c:	47050513          	addi	a0,a0,1136 # 80019688 <bcache>
    80003220:	a9dfd0ef          	jal	80000cbc <acquire>
  b->refcnt--;
    80003224:	40bc                	lw	a5,64(s1)
    80003226:	37fd                	addiw	a5,a5,-1
    80003228:	0007871b          	sext.w	a4,a5
    8000322c:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    8000322e:	c31d                	beqz	a4,80003254 <brelse+0x5c>
    bcache.head.next->prev = b;
    bcache.head.next = b;
    fslog_push(FS_BRELEASE, 0, b->blockno, 0, "BCACHE");
  }
  
  release(&bcache.lock);
    80003230:	00016517          	auipc	a0,0x16
    80003234:	45850513          	addi	a0,a0,1112 # 80019688 <bcache>
    80003238:	b1dfd0ef          	jal	80000d54 <release>
}
    8000323c:	60e2                	ld	ra,24(sp)
    8000323e:	6442                	ld	s0,16(sp)
    80003240:	64a2                	ld	s1,8(sp)
    80003242:	6902                	ld	s2,0(sp)
    80003244:	6105                	addi	sp,sp,32
    80003246:	8082                	ret
    panic("brelse");
    80003248:	00005517          	auipc	a0,0x5
    8000324c:	1b050513          	addi	a0,a0,432 # 800083f8 <etext+0x3f8>
    80003250:	dc2fd0ef          	jal	80000812 <panic>
    b->next->prev = b->prev;
    80003254:	68b8                	ld	a4,80(s1)
    80003256:	64bc                	ld	a5,72(s1)
    80003258:	e73c                	sd	a5,72(a4)
    b->prev->next = b->next;
    8000325a:	68b8                	ld	a4,80(s1)
    8000325c:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    8000325e:	0001e797          	auipc	a5,0x1e
    80003262:	42a78793          	addi	a5,a5,1066 # 80021688 <bcache+0x8000>
    80003266:	2b87b703          	ld	a4,696(a5)
    8000326a:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    8000326c:	0001e717          	auipc	a4,0x1e
    80003270:	68470713          	addi	a4,a4,1668 # 800218f0 <bcache+0x8268>
    80003274:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    80003276:	2b87b703          	ld	a4,696(a5)
    8000327a:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    8000327c:	2a97bc23          	sd	s1,696(a5)
    fslog_push(FS_BRELEASE, 0, b->blockno, 0, "BCACHE");
    80003280:	00005717          	auipc	a4,0x5
    80003284:	15070713          	addi	a4,a4,336 # 800083d0 <etext+0x3d0>
    80003288:	4681                	li	a3,0
    8000328a:	44d0                	lw	a2,12(s1)
    8000328c:	4581                	li	a1,0
    8000328e:	4521                	li	a0,8
    80003290:	068030ef          	jal	800062f8 <fslog_push>
    80003294:	bf71                	j	80003230 <brelse+0x38>

0000000080003296 <bpin>:

void
bpin(struct buf *b) {
    80003296:	1101                	addi	sp,sp,-32
    80003298:	ec06                	sd	ra,24(sp)
    8000329a:	e822                	sd	s0,16(sp)
    8000329c:	e426                	sd	s1,8(sp)
    8000329e:	1000                	addi	s0,sp,32
    800032a0:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    800032a2:	00016517          	auipc	a0,0x16
    800032a6:	3e650513          	addi	a0,a0,998 # 80019688 <bcache>
    800032aa:	a13fd0ef          	jal	80000cbc <acquire>
  b->refcnt++;
    800032ae:	40bc                	lw	a5,64(s1)
    800032b0:	2785                	addiw	a5,a5,1
    800032b2:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    800032b4:	00016517          	auipc	a0,0x16
    800032b8:	3d450513          	addi	a0,a0,980 # 80019688 <bcache>
    800032bc:	a99fd0ef          	jal	80000d54 <release>
}
    800032c0:	60e2                	ld	ra,24(sp)
    800032c2:	6442                	ld	s0,16(sp)
    800032c4:	64a2                	ld	s1,8(sp)
    800032c6:	6105                	addi	sp,sp,32
    800032c8:	8082                	ret

00000000800032ca <bunpin>:

void
bunpin(struct buf *b) {
    800032ca:	1101                	addi	sp,sp,-32
    800032cc:	ec06                	sd	ra,24(sp)
    800032ce:	e822                	sd	s0,16(sp)
    800032d0:	e426                	sd	s1,8(sp)
    800032d2:	1000                	addi	s0,sp,32
    800032d4:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    800032d6:	00016517          	auipc	a0,0x16
    800032da:	3b250513          	addi	a0,a0,946 # 80019688 <bcache>
    800032de:	9dffd0ef          	jal	80000cbc <acquire>
  b->refcnt--;
    800032e2:	40bc                	lw	a5,64(s1)
    800032e4:	37fd                	addiw	a5,a5,-1
    800032e6:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    800032e8:	00016517          	auipc	a0,0x16
    800032ec:	3a050513          	addi	a0,a0,928 # 80019688 <bcache>
    800032f0:	a65fd0ef          	jal	80000d54 <release>
}
    800032f4:	60e2                	ld	ra,24(sp)
    800032f6:	6442                	ld	s0,16(sp)
    800032f8:	64a2                	ld	s1,8(sp)
    800032fa:	6105                	addi	sp,sp,32
    800032fc:	8082                	ret

00000000800032fe <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    800032fe:	1101                	addi	sp,sp,-32
    80003300:	ec06                	sd	ra,24(sp)
    80003302:	e822                	sd	s0,16(sp)
    80003304:	e426                	sd	s1,8(sp)
    80003306:	e04a                	sd	s2,0(sp)
    80003308:	1000                	addi	s0,sp,32
    8000330a:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    8000330c:	00d5d59b          	srliw	a1,a1,0xd
    80003310:	0001f797          	auipc	a5,0x1f
    80003314:	a547a783          	lw	a5,-1452(a5) # 80021d64 <sb+0x1c>
    80003318:	9dbd                	addw	a1,a1,a5
    8000331a:	dafff0ef          	jal	800030c8 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    8000331e:	0074f713          	andi	a4,s1,7
    80003322:	4785                	li	a5,1
    80003324:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    80003328:	14ce                	slli	s1,s1,0x33
    8000332a:	90d9                	srli	s1,s1,0x36
    8000332c:	00950733          	add	a4,a0,s1
    80003330:	05874703          	lbu	a4,88(a4)
    80003334:	00e7f6b3          	and	a3,a5,a4
    80003338:	c29d                	beqz	a3,8000335e <bfree+0x60>
    8000333a:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    8000333c:	94aa                	add	s1,s1,a0
    8000333e:	fff7c793          	not	a5,a5
    80003342:	8f7d                	and	a4,a4,a5
    80003344:	04e48c23          	sb	a4,88(s1)
  log_write(bp);
    80003348:	7f9000ef          	jal	80004340 <log_write>
  brelse(bp);
    8000334c:	854a                	mv	a0,s2
    8000334e:	eabff0ef          	jal	800031f8 <brelse>
}
    80003352:	60e2                	ld	ra,24(sp)
    80003354:	6442                	ld	s0,16(sp)
    80003356:	64a2                	ld	s1,8(sp)
    80003358:	6902                	ld	s2,0(sp)
    8000335a:	6105                	addi	sp,sp,32
    8000335c:	8082                	ret
    panic("freeing free block");
    8000335e:	00005517          	auipc	a0,0x5
    80003362:	0a250513          	addi	a0,a0,162 # 80008400 <etext+0x400>
    80003366:	cacfd0ef          	jal	80000812 <panic>

000000008000336a <balloc>:
{
    8000336a:	711d                	addi	sp,sp,-96
    8000336c:	ec86                	sd	ra,88(sp)
    8000336e:	e8a2                	sd	s0,80(sp)
    80003370:	e4a6                	sd	s1,72(sp)
    80003372:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    80003374:	0001f797          	auipc	a5,0x1f
    80003378:	9d87a783          	lw	a5,-1576(a5) # 80021d4c <sb+0x4>
    8000337c:	0e078f63          	beqz	a5,8000347a <balloc+0x110>
    80003380:	e0ca                	sd	s2,64(sp)
    80003382:	fc4e                	sd	s3,56(sp)
    80003384:	f852                	sd	s4,48(sp)
    80003386:	f456                	sd	s5,40(sp)
    80003388:	f05a                	sd	s6,32(sp)
    8000338a:	ec5e                	sd	s7,24(sp)
    8000338c:	e862                	sd	s8,16(sp)
    8000338e:	e466                	sd	s9,8(sp)
    80003390:	8baa                	mv	s7,a0
    80003392:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    80003394:	0001fb17          	auipc	s6,0x1f
    80003398:	9b4b0b13          	addi	s6,s6,-1612 # 80021d48 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000339c:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    8000339e:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800033a0:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    800033a2:	6c89                	lui	s9,0x2
    800033a4:	a0b5                	j	80003410 <balloc+0xa6>
        bp->data[bi/8] |= m;  // Mark block in use.
    800033a6:	97ca                	add	a5,a5,s2
    800033a8:	8e55                	or	a2,a2,a3
    800033aa:	04c78c23          	sb	a2,88(a5)
        log_write(bp);
    800033ae:	854a                	mv	a0,s2
    800033b0:	791000ef          	jal	80004340 <log_write>
        brelse(bp);
    800033b4:	854a                	mv	a0,s2
    800033b6:	e43ff0ef          	jal	800031f8 <brelse>
  bp = bread(dev, bno);
    800033ba:	85a6                	mv	a1,s1
    800033bc:	855e                	mv	a0,s7
    800033be:	d0bff0ef          	jal	800030c8 <bread>
    800033c2:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    800033c4:	40000613          	li	a2,1024
    800033c8:	4581                	li	a1,0
    800033ca:	05850513          	addi	a0,a0,88
    800033ce:	9c3fd0ef          	jal	80000d90 <memset>
  log_write(bp);
    800033d2:	854a                	mv	a0,s2
    800033d4:	76d000ef          	jal	80004340 <log_write>
  brelse(bp);
    800033d8:	854a                	mv	a0,s2
    800033da:	e1fff0ef          	jal	800031f8 <brelse>
}
    800033de:	6906                	ld	s2,64(sp)
    800033e0:	79e2                	ld	s3,56(sp)
    800033e2:	7a42                	ld	s4,48(sp)
    800033e4:	7aa2                	ld	s5,40(sp)
    800033e6:	7b02                	ld	s6,32(sp)
    800033e8:	6be2                	ld	s7,24(sp)
    800033ea:	6c42                	ld	s8,16(sp)
    800033ec:	6ca2                	ld	s9,8(sp)
}
    800033ee:	8526                	mv	a0,s1
    800033f0:	60e6                	ld	ra,88(sp)
    800033f2:	6446                	ld	s0,80(sp)
    800033f4:	64a6                	ld	s1,72(sp)
    800033f6:	6125                	addi	sp,sp,96
    800033f8:	8082                	ret
    brelse(bp);
    800033fa:	854a                	mv	a0,s2
    800033fc:	dfdff0ef          	jal	800031f8 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    80003400:	015c87bb          	addw	a5,s9,s5
    80003404:	00078a9b          	sext.w	s5,a5
    80003408:	004b2703          	lw	a4,4(s6)
    8000340c:	04eaff63          	bgeu	s5,a4,8000346a <balloc+0x100>
    bp = bread(dev, BBLOCK(b, sb));
    80003410:	41fad79b          	sraiw	a5,s5,0x1f
    80003414:	0137d79b          	srliw	a5,a5,0x13
    80003418:	015787bb          	addw	a5,a5,s5
    8000341c:	40d7d79b          	sraiw	a5,a5,0xd
    80003420:	01cb2583          	lw	a1,28(s6)
    80003424:	9dbd                	addw	a1,a1,a5
    80003426:	855e                	mv	a0,s7
    80003428:	ca1ff0ef          	jal	800030c8 <bread>
    8000342c:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000342e:	004b2503          	lw	a0,4(s6)
    80003432:	000a849b          	sext.w	s1,s5
    80003436:	8762                	mv	a4,s8
    80003438:	fca4f1e3          	bgeu	s1,a0,800033fa <balloc+0x90>
      m = 1 << (bi % 8);
    8000343c:	00777693          	andi	a3,a4,7
    80003440:	00d996bb          	sllw	a3,s3,a3
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    80003444:	41f7579b          	sraiw	a5,a4,0x1f
    80003448:	01d7d79b          	srliw	a5,a5,0x1d
    8000344c:	9fb9                	addw	a5,a5,a4
    8000344e:	4037d79b          	sraiw	a5,a5,0x3
    80003452:	00f90633          	add	a2,s2,a5
    80003456:	05864603          	lbu	a2,88(a2)
    8000345a:	00c6f5b3          	and	a1,a3,a2
    8000345e:	d5a1                	beqz	a1,800033a6 <balloc+0x3c>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003460:	2705                	addiw	a4,a4,1
    80003462:	2485                	addiw	s1,s1,1
    80003464:	fd471ae3          	bne	a4,s4,80003438 <balloc+0xce>
    80003468:	bf49                	j	800033fa <balloc+0x90>
    8000346a:	6906                	ld	s2,64(sp)
    8000346c:	79e2                	ld	s3,56(sp)
    8000346e:	7a42                	ld	s4,48(sp)
    80003470:	7aa2                	ld	s5,40(sp)
    80003472:	7b02                	ld	s6,32(sp)
    80003474:	6be2                	ld	s7,24(sp)
    80003476:	6c42                	ld	s8,16(sp)
    80003478:	6ca2                	ld	s9,8(sp)
  printf("balloc: out of blocks\n");
    8000347a:	00005517          	auipc	a0,0x5
    8000347e:	f9e50513          	addi	a0,a0,-98 # 80008418 <etext+0x418>
    80003482:	8aafd0ef          	jal	8000052c <printf>
  return 0;
    80003486:	4481                	li	s1,0
    80003488:	b79d                	j	800033ee <balloc+0x84>

000000008000348a <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    8000348a:	7179                	addi	sp,sp,-48
    8000348c:	f406                	sd	ra,40(sp)
    8000348e:	f022                	sd	s0,32(sp)
    80003490:	ec26                	sd	s1,24(sp)
    80003492:	e84a                	sd	s2,16(sp)
    80003494:	e44e                	sd	s3,8(sp)
    80003496:	1800                	addi	s0,sp,48
    80003498:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    8000349a:	47ad                	li	a5,11
    8000349c:	02b7e663          	bltu	a5,a1,800034c8 <bmap+0x3e>
    if((addr = ip->addrs[bn]) == 0){
    800034a0:	02059793          	slli	a5,a1,0x20
    800034a4:	01e7d593          	srli	a1,a5,0x1e
    800034a8:	00b504b3          	add	s1,a0,a1
    800034ac:	0504a903          	lw	s2,80(s1)
    800034b0:	06091a63          	bnez	s2,80003524 <bmap+0x9a>
      addr = balloc(ip->dev);
    800034b4:	4108                	lw	a0,0(a0)
    800034b6:	eb5ff0ef          	jal	8000336a <balloc>
    800034ba:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    800034be:	06090363          	beqz	s2,80003524 <bmap+0x9a>
        return 0;
      ip->addrs[bn] = addr;
    800034c2:	0524a823          	sw	s2,80(s1)
    800034c6:	a8b9                	j	80003524 <bmap+0x9a>
    }
    return addr;
  }
  bn -= NDIRECT;
    800034c8:	ff45849b          	addiw	s1,a1,-12
    800034cc:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    800034d0:	0ff00793          	li	a5,255
    800034d4:	06e7ee63          	bltu	a5,a4,80003550 <bmap+0xc6>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    800034d8:	08052903          	lw	s2,128(a0)
    800034dc:	00091d63          	bnez	s2,800034f6 <bmap+0x6c>
      addr = balloc(ip->dev);
    800034e0:	4108                	lw	a0,0(a0)
    800034e2:	e89ff0ef          	jal	8000336a <balloc>
    800034e6:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    800034ea:	02090d63          	beqz	s2,80003524 <bmap+0x9a>
    800034ee:	e052                	sd	s4,0(sp)
        return 0;
      ip->addrs[NDIRECT] = addr;
    800034f0:	0929a023          	sw	s2,128(s3)
    800034f4:	a011                	j	800034f8 <bmap+0x6e>
    800034f6:	e052                	sd	s4,0(sp)
    }
    bp = bread(ip->dev, addr);
    800034f8:	85ca                	mv	a1,s2
    800034fa:	0009a503          	lw	a0,0(s3)
    800034fe:	bcbff0ef          	jal	800030c8 <bread>
    80003502:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    80003504:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    80003508:	02049713          	slli	a4,s1,0x20
    8000350c:	01e75593          	srli	a1,a4,0x1e
    80003510:	00b784b3          	add	s1,a5,a1
    80003514:	0004a903          	lw	s2,0(s1)
    80003518:	00090e63          	beqz	s2,80003534 <bmap+0xaa>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    8000351c:	8552                	mv	a0,s4
    8000351e:	cdbff0ef          	jal	800031f8 <brelse>
    return addr;
    80003522:	6a02                	ld	s4,0(sp)
  }

  panic("bmap: out of range");
}
    80003524:	854a                	mv	a0,s2
    80003526:	70a2                	ld	ra,40(sp)
    80003528:	7402                	ld	s0,32(sp)
    8000352a:	64e2                	ld	s1,24(sp)
    8000352c:	6942                	ld	s2,16(sp)
    8000352e:	69a2                	ld	s3,8(sp)
    80003530:	6145                	addi	sp,sp,48
    80003532:	8082                	ret
      addr = balloc(ip->dev);
    80003534:	0009a503          	lw	a0,0(s3)
    80003538:	e33ff0ef          	jal	8000336a <balloc>
    8000353c:	0005091b          	sext.w	s2,a0
      if(addr){
    80003540:	fc090ee3          	beqz	s2,8000351c <bmap+0x92>
        a[bn] = addr;
    80003544:	0124a023          	sw	s2,0(s1)
        log_write(bp);
    80003548:	8552                	mv	a0,s4
    8000354a:	5f7000ef          	jal	80004340 <log_write>
    8000354e:	b7f9                	j	8000351c <bmap+0x92>
    80003550:	e052                	sd	s4,0(sp)
  panic("bmap: out of range");
    80003552:	00005517          	auipc	a0,0x5
    80003556:	ede50513          	addi	a0,a0,-290 # 80008430 <etext+0x430>
    8000355a:	ab8fd0ef          	jal	80000812 <panic>

000000008000355e <iget>:
{
    8000355e:	7179                	addi	sp,sp,-48
    80003560:	f406                	sd	ra,40(sp)
    80003562:	f022                	sd	s0,32(sp)
    80003564:	ec26                	sd	s1,24(sp)
    80003566:	e84a                	sd	s2,16(sp)
    80003568:	e44e                	sd	s3,8(sp)
    8000356a:	e052                	sd	s4,0(sp)
    8000356c:	1800                	addi	s0,sp,48
    8000356e:	89aa                	mv	s3,a0
    80003570:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    80003572:	0001e517          	auipc	a0,0x1e
    80003576:	7f650513          	addi	a0,a0,2038 # 80021d68 <itable>
    8000357a:	f42fd0ef          	jal	80000cbc <acquire>
  empty = 0;
    8000357e:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003580:	0001f497          	auipc	s1,0x1f
    80003584:	80048493          	addi	s1,s1,-2048 # 80021d80 <itable+0x18>
    80003588:	00020697          	auipc	a3,0x20
    8000358c:	28868693          	addi	a3,a3,648 # 80023810 <log>
    80003590:	a039                	j	8000359e <iget+0x40>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003592:	02090963          	beqz	s2,800035c4 <iget+0x66>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003596:	08848493          	addi	s1,s1,136
    8000359a:	02d48863          	beq	s1,a3,800035ca <iget+0x6c>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    8000359e:	449c                	lw	a5,8(s1)
    800035a0:	fef059e3          	blez	a5,80003592 <iget+0x34>
    800035a4:	4098                	lw	a4,0(s1)
    800035a6:	ff3716e3          	bne	a4,s3,80003592 <iget+0x34>
    800035aa:	40d8                	lw	a4,4(s1)
    800035ac:	ff4713e3          	bne	a4,s4,80003592 <iget+0x34>
      ip->ref++;
    800035b0:	2785                	addiw	a5,a5,1
    800035b2:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    800035b4:	0001e517          	auipc	a0,0x1e
    800035b8:	7b450513          	addi	a0,a0,1972 # 80021d68 <itable>
    800035bc:	f98fd0ef          	jal	80000d54 <release>
      return ip;
    800035c0:	8926                	mv	s2,s1
    800035c2:	a02d                	j	800035ec <iget+0x8e>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    800035c4:	fbe9                	bnez	a5,80003596 <iget+0x38>
      empty = ip;
    800035c6:	8926                	mv	s2,s1
    800035c8:	b7f9                	j	80003596 <iget+0x38>
  if(empty == 0)
    800035ca:	02090a63          	beqz	s2,800035fe <iget+0xa0>
  ip->dev = dev;
    800035ce:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    800035d2:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    800035d6:	4785                	li	a5,1
    800035d8:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    800035dc:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    800035e0:	0001e517          	auipc	a0,0x1e
    800035e4:	78850513          	addi	a0,a0,1928 # 80021d68 <itable>
    800035e8:	f6cfd0ef          	jal	80000d54 <release>
}
    800035ec:	854a                	mv	a0,s2
    800035ee:	70a2                	ld	ra,40(sp)
    800035f0:	7402                	ld	s0,32(sp)
    800035f2:	64e2                	ld	s1,24(sp)
    800035f4:	6942                	ld	s2,16(sp)
    800035f6:	69a2                	ld	s3,8(sp)
    800035f8:	6a02                	ld	s4,0(sp)
    800035fa:	6145                	addi	sp,sp,48
    800035fc:	8082                	ret
    panic("iget: no inodes");
    800035fe:	00005517          	auipc	a0,0x5
    80003602:	e4a50513          	addi	a0,a0,-438 # 80008448 <etext+0x448>
    80003606:	a0cfd0ef          	jal	80000812 <panic>

000000008000360a <iinit>:
{
    8000360a:	7179                	addi	sp,sp,-48
    8000360c:	f406                	sd	ra,40(sp)
    8000360e:	f022                	sd	s0,32(sp)
    80003610:	ec26                	sd	s1,24(sp)
    80003612:	e84a                	sd	s2,16(sp)
    80003614:	e44e                	sd	s3,8(sp)
    80003616:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    80003618:	00005597          	auipc	a1,0x5
    8000361c:	e4058593          	addi	a1,a1,-448 # 80008458 <etext+0x458>
    80003620:	0001e517          	auipc	a0,0x1e
    80003624:	74850513          	addi	a0,a0,1864 # 80021d68 <itable>
    80003628:	e14fd0ef          	jal	80000c3c <initlock>
  for(i = 0; i < NINODE; i++) {
    8000362c:	0001e497          	auipc	s1,0x1e
    80003630:	76448493          	addi	s1,s1,1892 # 80021d90 <itable+0x28>
    80003634:	00020997          	auipc	s3,0x20
    80003638:	1ec98993          	addi	s3,s3,492 # 80023820 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    8000363c:	00005917          	auipc	s2,0x5
    80003640:	e2490913          	addi	s2,s2,-476 # 80008460 <etext+0x460>
    80003644:	85ca                	mv	a1,s2
    80003646:	8526                	mv	a0,s1
    80003648:	5bb000ef          	jal	80004402 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    8000364c:	08848493          	addi	s1,s1,136
    80003650:	ff349ae3          	bne	s1,s3,80003644 <iinit+0x3a>
}
    80003654:	70a2                	ld	ra,40(sp)
    80003656:	7402                	ld	s0,32(sp)
    80003658:	64e2                	ld	s1,24(sp)
    8000365a:	6942                	ld	s2,16(sp)
    8000365c:	69a2                	ld	s3,8(sp)
    8000365e:	6145                	addi	sp,sp,48
    80003660:	8082                	ret

0000000080003662 <ialloc>:
{
    80003662:	7139                	addi	sp,sp,-64
    80003664:	fc06                	sd	ra,56(sp)
    80003666:	f822                	sd	s0,48(sp)
    80003668:	0080                	addi	s0,sp,64
  for(inum = 1; inum < sb.ninodes; inum++){
    8000366a:	0001e717          	auipc	a4,0x1e
    8000366e:	6ea72703          	lw	a4,1770(a4) # 80021d54 <sb+0xc>
    80003672:	4785                	li	a5,1
    80003674:	06e7f063          	bgeu	a5,a4,800036d4 <ialloc+0x72>
    80003678:	f426                	sd	s1,40(sp)
    8000367a:	f04a                	sd	s2,32(sp)
    8000367c:	ec4e                	sd	s3,24(sp)
    8000367e:	e852                	sd	s4,16(sp)
    80003680:	e456                	sd	s5,8(sp)
    80003682:	e05a                	sd	s6,0(sp)
    80003684:	8aaa                	mv	s5,a0
    80003686:	8b2e                	mv	s6,a1
    80003688:	4905                	li	s2,1
    bp = bread(dev, IBLOCK(inum, sb));
    8000368a:	0001ea17          	auipc	s4,0x1e
    8000368e:	6bea0a13          	addi	s4,s4,1726 # 80021d48 <sb>
    80003692:	00495593          	srli	a1,s2,0x4
    80003696:	018a2783          	lw	a5,24(s4)
    8000369a:	9dbd                	addw	a1,a1,a5
    8000369c:	8556                	mv	a0,s5
    8000369e:	a2bff0ef          	jal	800030c8 <bread>
    800036a2:	84aa                	mv	s1,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    800036a4:	05850993          	addi	s3,a0,88
    800036a8:	00f97793          	andi	a5,s2,15
    800036ac:	079a                	slli	a5,a5,0x6
    800036ae:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    800036b0:	00099783          	lh	a5,0(s3)
    800036b4:	cb9d                	beqz	a5,800036ea <ialloc+0x88>
    brelse(bp);
    800036b6:	b43ff0ef          	jal	800031f8 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    800036ba:	0905                	addi	s2,s2,1
    800036bc:	00ca2703          	lw	a4,12(s4)
    800036c0:	0009079b          	sext.w	a5,s2
    800036c4:	fce7e7e3          	bltu	a5,a4,80003692 <ialloc+0x30>
    800036c8:	74a2                	ld	s1,40(sp)
    800036ca:	7902                	ld	s2,32(sp)
    800036cc:	69e2                	ld	s3,24(sp)
    800036ce:	6a42                	ld	s4,16(sp)
    800036d0:	6aa2                	ld	s5,8(sp)
    800036d2:	6b02                	ld	s6,0(sp)
  printf("ialloc: no inodes\n");
    800036d4:	00005517          	auipc	a0,0x5
    800036d8:	d9450513          	addi	a0,a0,-620 # 80008468 <etext+0x468>
    800036dc:	e51fc0ef          	jal	8000052c <printf>
  return 0;
    800036e0:	4501                	li	a0,0
}
    800036e2:	70e2                	ld	ra,56(sp)
    800036e4:	7442                	ld	s0,48(sp)
    800036e6:	6121                	addi	sp,sp,64
    800036e8:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    800036ea:	04000613          	li	a2,64
    800036ee:	4581                	li	a1,0
    800036f0:	854e                	mv	a0,s3
    800036f2:	e9efd0ef          	jal	80000d90 <memset>
      dip->type = type;
    800036f6:	01699023          	sh	s6,0(s3)
      log_write(bp);   // mark it allocated on the disk
    800036fa:	8526                	mv	a0,s1
    800036fc:	445000ef          	jal	80004340 <log_write>
      brelse(bp);
    80003700:	8526                	mv	a0,s1
    80003702:	af7ff0ef          	jal	800031f8 <brelse>
      return iget(dev, inum);
    80003706:	0009059b          	sext.w	a1,s2
    8000370a:	8556                	mv	a0,s5
    8000370c:	e53ff0ef          	jal	8000355e <iget>
    80003710:	74a2                	ld	s1,40(sp)
    80003712:	7902                	ld	s2,32(sp)
    80003714:	69e2                	ld	s3,24(sp)
    80003716:	6a42                	ld	s4,16(sp)
    80003718:	6aa2                	ld	s5,8(sp)
    8000371a:	6b02                	ld	s6,0(sp)
    8000371c:	b7d9                	j	800036e2 <ialloc+0x80>

000000008000371e <iupdate>:
{
    8000371e:	1101                	addi	sp,sp,-32
    80003720:	ec06                	sd	ra,24(sp)
    80003722:	e822                	sd	s0,16(sp)
    80003724:	e426                	sd	s1,8(sp)
    80003726:	e04a                	sd	s2,0(sp)
    80003728:	1000                	addi	s0,sp,32
    8000372a:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    8000372c:	415c                	lw	a5,4(a0)
    8000372e:	0047d79b          	srliw	a5,a5,0x4
    80003732:	0001e597          	auipc	a1,0x1e
    80003736:	62e5a583          	lw	a1,1582(a1) # 80021d60 <sb+0x18>
    8000373a:	9dbd                	addw	a1,a1,a5
    8000373c:	4108                	lw	a0,0(a0)
    8000373e:	98bff0ef          	jal	800030c8 <bread>
    80003742:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003744:	05850793          	addi	a5,a0,88
    80003748:	40d8                	lw	a4,4(s1)
    8000374a:	8b3d                	andi	a4,a4,15
    8000374c:	071a                	slli	a4,a4,0x6
    8000374e:	97ba                	add	a5,a5,a4
  dip->type = ip->type;
    80003750:	04449703          	lh	a4,68(s1)
    80003754:	00e79023          	sh	a4,0(a5)
  dip->major = ip->major;
    80003758:	04649703          	lh	a4,70(s1)
    8000375c:	00e79123          	sh	a4,2(a5)
  dip->minor = ip->minor;
    80003760:	04849703          	lh	a4,72(s1)
    80003764:	00e79223          	sh	a4,4(a5)
  dip->nlink = ip->nlink;
    80003768:	04a49703          	lh	a4,74(s1)
    8000376c:	00e79323          	sh	a4,6(a5)
  dip->size = ip->size;
    80003770:	44f8                	lw	a4,76(s1)
    80003772:	c798                	sw	a4,8(a5)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80003774:	03400613          	li	a2,52
    80003778:	05048593          	addi	a1,s1,80
    8000377c:	00c78513          	addi	a0,a5,12
    80003780:	e6cfd0ef          	jal	80000dec <memmove>
  log_write(bp);
    80003784:	854a                	mv	a0,s2
    80003786:	3bb000ef          	jal	80004340 <log_write>
  brelse(bp);
    8000378a:	854a                	mv	a0,s2
    8000378c:	a6dff0ef          	jal	800031f8 <brelse>
}
    80003790:	60e2                	ld	ra,24(sp)
    80003792:	6442                	ld	s0,16(sp)
    80003794:	64a2                	ld	s1,8(sp)
    80003796:	6902                	ld	s2,0(sp)
    80003798:	6105                	addi	sp,sp,32
    8000379a:	8082                	ret

000000008000379c <idup>:
{
    8000379c:	1101                	addi	sp,sp,-32
    8000379e:	ec06                	sd	ra,24(sp)
    800037a0:	e822                	sd	s0,16(sp)
    800037a2:	e426                	sd	s1,8(sp)
    800037a4:	1000                	addi	s0,sp,32
    800037a6:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    800037a8:	0001e517          	auipc	a0,0x1e
    800037ac:	5c050513          	addi	a0,a0,1472 # 80021d68 <itable>
    800037b0:	d0cfd0ef          	jal	80000cbc <acquire>
  ip->ref++;
    800037b4:	449c                	lw	a5,8(s1)
    800037b6:	2785                	addiw	a5,a5,1
    800037b8:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    800037ba:	0001e517          	auipc	a0,0x1e
    800037be:	5ae50513          	addi	a0,a0,1454 # 80021d68 <itable>
    800037c2:	d92fd0ef          	jal	80000d54 <release>
}
    800037c6:	8526                	mv	a0,s1
    800037c8:	60e2                	ld	ra,24(sp)
    800037ca:	6442                	ld	s0,16(sp)
    800037cc:	64a2                	ld	s1,8(sp)
    800037ce:	6105                	addi	sp,sp,32
    800037d0:	8082                	ret

00000000800037d2 <ilock>:
{
    800037d2:	1101                	addi	sp,sp,-32
    800037d4:	ec06                	sd	ra,24(sp)
    800037d6:	e822                	sd	s0,16(sp)
    800037d8:	e426                	sd	s1,8(sp)
    800037da:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    800037dc:	cd19                	beqz	a0,800037fa <ilock+0x28>
    800037de:	84aa                	mv	s1,a0
    800037e0:	451c                	lw	a5,8(a0)
    800037e2:	00f05c63          	blez	a5,800037fa <ilock+0x28>
  acquiresleep(&ip->lock);
    800037e6:	0541                	addi	a0,a0,16
    800037e8:	451000ef          	jal	80004438 <acquiresleep>
  if(ip->valid == 0){
    800037ec:	40bc                	lw	a5,64(s1)
    800037ee:	cf89                	beqz	a5,80003808 <ilock+0x36>
}
    800037f0:	60e2                	ld	ra,24(sp)
    800037f2:	6442                	ld	s0,16(sp)
    800037f4:	64a2                	ld	s1,8(sp)
    800037f6:	6105                	addi	sp,sp,32
    800037f8:	8082                	ret
    800037fa:	e04a                	sd	s2,0(sp)
    panic("ilock");
    800037fc:	00005517          	auipc	a0,0x5
    80003800:	c8450513          	addi	a0,a0,-892 # 80008480 <etext+0x480>
    80003804:	80efd0ef          	jal	80000812 <panic>
    80003808:	e04a                	sd	s2,0(sp)
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    8000380a:	40dc                	lw	a5,4(s1)
    8000380c:	0047d79b          	srliw	a5,a5,0x4
    80003810:	0001e597          	auipc	a1,0x1e
    80003814:	5505a583          	lw	a1,1360(a1) # 80021d60 <sb+0x18>
    80003818:	9dbd                	addw	a1,a1,a5
    8000381a:	4088                	lw	a0,0(s1)
    8000381c:	8adff0ef          	jal	800030c8 <bread>
    80003820:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003822:	05850593          	addi	a1,a0,88
    80003826:	40dc                	lw	a5,4(s1)
    80003828:	8bbd                	andi	a5,a5,15
    8000382a:	079a                	slli	a5,a5,0x6
    8000382c:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    8000382e:	00059783          	lh	a5,0(a1)
    80003832:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    80003836:	00259783          	lh	a5,2(a1)
    8000383a:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    8000383e:	00459783          	lh	a5,4(a1)
    80003842:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80003846:	00659783          	lh	a5,6(a1)
    8000384a:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    8000384e:	459c                	lw	a5,8(a1)
    80003850:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80003852:	03400613          	li	a2,52
    80003856:	05b1                	addi	a1,a1,12
    80003858:	05048513          	addi	a0,s1,80
    8000385c:	d90fd0ef          	jal	80000dec <memmove>
    brelse(bp);
    80003860:	854a                	mv	a0,s2
    80003862:	997ff0ef          	jal	800031f8 <brelse>
    ip->valid = 1;
    80003866:	4785                	li	a5,1
    80003868:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    8000386a:	04449783          	lh	a5,68(s1)
    8000386e:	c399                	beqz	a5,80003874 <ilock+0xa2>
    80003870:	6902                	ld	s2,0(sp)
    80003872:	bfbd                	j	800037f0 <ilock+0x1e>
      panic("ilock: no type");
    80003874:	00005517          	auipc	a0,0x5
    80003878:	c1450513          	addi	a0,a0,-1004 # 80008488 <etext+0x488>
    8000387c:	f97fc0ef          	jal	80000812 <panic>

0000000080003880 <iunlock>:
{
    80003880:	1101                	addi	sp,sp,-32
    80003882:	ec06                	sd	ra,24(sp)
    80003884:	e822                	sd	s0,16(sp)
    80003886:	e426                	sd	s1,8(sp)
    80003888:	e04a                	sd	s2,0(sp)
    8000388a:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    8000388c:	c505                	beqz	a0,800038b4 <iunlock+0x34>
    8000388e:	84aa                	mv	s1,a0
    80003890:	01050913          	addi	s2,a0,16
    80003894:	854a                	mv	a0,s2
    80003896:	421000ef          	jal	800044b6 <holdingsleep>
    8000389a:	cd09                	beqz	a0,800038b4 <iunlock+0x34>
    8000389c:	449c                	lw	a5,8(s1)
    8000389e:	00f05b63          	blez	a5,800038b4 <iunlock+0x34>
  releasesleep(&ip->lock);
    800038a2:	854a                	mv	a0,s2
    800038a4:	3db000ef          	jal	8000447e <releasesleep>
}
    800038a8:	60e2                	ld	ra,24(sp)
    800038aa:	6442                	ld	s0,16(sp)
    800038ac:	64a2                	ld	s1,8(sp)
    800038ae:	6902                	ld	s2,0(sp)
    800038b0:	6105                	addi	sp,sp,32
    800038b2:	8082                	ret
    panic("iunlock");
    800038b4:	00005517          	auipc	a0,0x5
    800038b8:	be450513          	addi	a0,a0,-1052 # 80008498 <etext+0x498>
    800038bc:	f57fc0ef          	jal	80000812 <panic>

00000000800038c0 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    800038c0:	7179                	addi	sp,sp,-48
    800038c2:	f406                	sd	ra,40(sp)
    800038c4:	f022                	sd	s0,32(sp)
    800038c6:	ec26                	sd	s1,24(sp)
    800038c8:	e84a                	sd	s2,16(sp)
    800038ca:	e44e                	sd	s3,8(sp)
    800038cc:	1800                	addi	s0,sp,48
    800038ce:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    800038d0:	05050493          	addi	s1,a0,80
    800038d4:	08050913          	addi	s2,a0,128
    800038d8:	a021                	j	800038e0 <itrunc+0x20>
    800038da:	0491                	addi	s1,s1,4
    800038dc:	01248b63          	beq	s1,s2,800038f2 <itrunc+0x32>
    if(ip->addrs[i]){
    800038e0:	408c                	lw	a1,0(s1)
    800038e2:	dde5                	beqz	a1,800038da <itrunc+0x1a>
      bfree(ip->dev, ip->addrs[i]);
    800038e4:	0009a503          	lw	a0,0(s3)
    800038e8:	a17ff0ef          	jal	800032fe <bfree>
      ip->addrs[i] = 0;
    800038ec:	0004a023          	sw	zero,0(s1)
    800038f0:	b7ed                	j	800038da <itrunc+0x1a>
    }
  }

  if(ip->addrs[NDIRECT]){
    800038f2:	0809a583          	lw	a1,128(s3)
    800038f6:	ed89                	bnez	a1,80003910 <itrunc+0x50>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    800038f8:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    800038fc:	854e                	mv	a0,s3
    800038fe:	e21ff0ef          	jal	8000371e <iupdate>
}
    80003902:	70a2                	ld	ra,40(sp)
    80003904:	7402                	ld	s0,32(sp)
    80003906:	64e2                	ld	s1,24(sp)
    80003908:	6942                	ld	s2,16(sp)
    8000390a:	69a2                	ld	s3,8(sp)
    8000390c:	6145                	addi	sp,sp,48
    8000390e:	8082                	ret
    80003910:	e052                	sd	s4,0(sp)
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80003912:	0009a503          	lw	a0,0(s3)
    80003916:	fb2ff0ef          	jal	800030c8 <bread>
    8000391a:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    8000391c:	05850493          	addi	s1,a0,88
    80003920:	45850913          	addi	s2,a0,1112
    80003924:	a021                	j	8000392c <itrunc+0x6c>
    80003926:	0491                	addi	s1,s1,4
    80003928:	01248963          	beq	s1,s2,8000393a <itrunc+0x7a>
      if(a[j])
    8000392c:	408c                	lw	a1,0(s1)
    8000392e:	dde5                	beqz	a1,80003926 <itrunc+0x66>
        bfree(ip->dev, a[j]);
    80003930:	0009a503          	lw	a0,0(s3)
    80003934:	9cbff0ef          	jal	800032fe <bfree>
    80003938:	b7fd                	j	80003926 <itrunc+0x66>
    brelse(bp);
    8000393a:	8552                	mv	a0,s4
    8000393c:	8bdff0ef          	jal	800031f8 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80003940:	0809a583          	lw	a1,128(s3)
    80003944:	0009a503          	lw	a0,0(s3)
    80003948:	9b7ff0ef          	jal	800032fe <bfree>
    ip->addrs[NDIRECT] = 0;
    8000394c:	0809a023          	sw	zero,128(s3)
    80003950:	6a02                	ld	s4,0(sp)
    80003952:	b75d                	j	800038f8 <itrunc+0x38>

0000000080003954 <iput>:
{
    80003954:	1101                	addi	sp,sp,-32
    80003956:	ec06                	sd	ra,24(sp)
    80003958:	e822                	sd	s0,16(sp)
    8000395a:	e426                	sd	s1,8(sp)
    8000395c:	1000                	addi	s0,sp,32
    8000395e:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003960:	0001e517          	auipc	a0,0x1e
    80003964:	40850513          	addi	a0,a0,1032 # 80021d68 <itable>
    80003968:	b54fd0ef          	jal	80000cbc <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    8000396c:	4498                	lw	a4,8(s1)
    8000396e:	4785                	li	a5,1
    80003970:	02f70063          	beq	a4,a5,80003990 <iput+0x3c>
  ip->ref--;
    80003974:	449c                	lw	a5,8(s1)
    80003976:	37fd                	addiw	a5,a5,-1
    80003978:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    8000397a:	0001e517          	auipc	a0,0x1e
    8000397e:	3ee50513          	addi	a0,a0,1006 # 80021d68 <itable>
    80003982:	bd2fd0ef          	jal	80000d54 <release>
}
    80003986:	60e2                	ld	ra,24(sp)
    80003988:	6442                	ld	s0,16(sp)
    8000398a:	64a2                	ld	s1,8(sp)
    8000398c:	6105                	addi	sp,sp,32
    8000398e:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003990:	40bc                	lw	a5,64(s1)
    80003992:	d3ed                	beqz	a5,80003974 <iput+0x20>
    80003994:	04a49783          	lh	a5,74(s1)
    80003998:	fff1                	bnez	a5,80003974 <iput+0x20>
    8000399a:	e04a                	sd	s2,0(sp)
    acquiresleep(&ip->lock);
    8000399c:	01048913          	addi	s2,s1,16
    800039a0:	854a                	mv	a0,s2
    800039a2:	297000ef          	jal	80004438 <acquiresleep>
    release(&itable.lock);
    800039a6:	0001e517          	auipc	a0,0x1e
    800039aa:	3c250513          	addi	a0,a0,962 # 80021d68 <itable>
    800039ae:	ba6fd0ef          	jal	80000d54 <release>
    itrunc(ip);
    800039b2:	8526                	mv	a0,s1
    800039b4:	f0dff0ef          	jal	800038c0 <itrunc>
    ip->type = 0;
    800039b8:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    800039bc:	8526                	mv	a0,s1
    800039be:	d61ff0ef          	jal	8000371e <iupdate>
    ip->valid = 0;
    800039c2:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    800039c6:	854a                	mv	a0,s2
    800039c8:	2b7000ef          	jal	8000447e <releasesleep>
    acquire(&itable.lock);
    800039cc:	0001e517          	auipc	a0,0x1e
    800039d0:	39c50513          	addi	a0,a0,924 # 80021d68 <itable>
    800039d4:	ae8fd0ef          	jal	80000cbc <acquire>
    800039d8:	6902                	ld	s2,0(sp)
    800039da:	bf69                	j	80003974 <iput+0x20>

00000000800039dc <iunlockput>:
{
    800039dc:	1101                	addi	sp,sp,-32
    800039de:	ec06                	sd	ra,24(sp)
    800039e0:	e822                	sd	s0,16(sp)
    800039e2:	e426                	sd	s1,8(sp)
    800039e4:	1000                	addi	s0,sp,32
    800039e6:	84aa                	mv	s1,a0
  iunlock(ip);
    800039e8:	e99ff0ef          	jal	80003880 <iunlock>
  iput(ip);
    800039ec:	8526                	mv	a0,s1
    800039ee:	f67ff0ef          	jal	80003954 <iput>
}
    800039f2:	60e2                	ld	ra,24(sp)
    800039f4:	6442                	ld	s0,16(sp)
    800039f6:	64a2                	ld	s1,8(sp)
    800039f8:	6105                	addi	sp,sp,32
    800039fa:	8082                	ret

00000000800039fc <ireclaim>:
  for (int inum = 1; inum < sb.ninodes; inum++) {
    800039fc:	0001e717          	auipc	a4,0x1e
    80003a00:	35872703          	lw	a4,856(a4) # 80021d54 <sb+0xc>
    80003a04:	4785                	li	a5,1
    80003a06:	0ae7ff63          	bgeu	a5,a4,80003ac4 <ireclaim+0xc8>
{
    80003a0a:	7139                	addi	sp,sp,-64
    80003a0c:	fc06                	sd	ra,56(sp)
    80003a0e:	f822                	sd	s0,48(sp)
    80003a10:	f426                	sd	s1,40(sp)
    80003a12:	f04a                	sd	s2,32(sp)
    80003a14:	ec4e                	sd	s3,24(sp)
    80003a16:	e852                	sd	s4,16(sp)
    80003a18:	e456                	sd	s5,8(sp)
    80003a1a:	e05a                	sd	s6,0(sp)
    80003a1c:	0080                	addi	s0,sp,64
  for (int inum = 1; inum < sb.ninodes; inum++) {
    80003a1e:	4485                	li	s1,1
    struct buf *bp = bread(dev, IBLOCK(inum, sb));
    80003a20:	00050a1b          	sext.w	s4,a0
    80003a24:	0001ea97          	auipc	s5,0x1e
    80003a28:	324a8a93          	addi	s5,s5,804 # 80021d48 <sb>
      printf("ireclaim: orphaned inode %d\n", inum);
    80003a2c:	00005b17          	auipc	s6,0x5
    80003a30:	a74b0b13          	addi	s6,s6,-1420 # 800084a0 <etext+0x4a0>
    80003a34:	a099                	j	80003a7a <ireclaim+0x7e>
    80003a36:	85ce                	mv	a1,s3
    80003a38:	855a                	mv	a0,s6
    80003a3a:	af3fc0ef          	jal	8000052c <printf>
      ip = iget(dev, inum);
    80003a3e:	85ce                	mv	a1,s3
    80003a40:	8552                	mv	a0,s4
    80003a42:	b1dff0ef          	jal	8000355e <iget>
    80003a46:	89aa                	mv	s3,a0
    brelse(bp);
    80003a48:	854a                	mv	a0,s2
    80003a4a:	faeff0ef          	jal	800031f8 <brelse>
    if (ip) {
    80003a4e:	00098f63          	beqz	s3,80003a6c <ireclaim+0x70>
      begin_op();
    80003a52:	76a000ef          	jal	800041bc <begin_op>
      ilock(ip);
    80003a56:	854e                	mv	a0,s3
    80003a58:	d7bff0ef          	jal	800037d2 <ilock>
      iunlock(ip);
    80003a5c:	854e                	mv	a0,s3
    80003a5e:	e23ff0ef          	jal	80003880 <iunlock>
      iput(ip);
    80003a62:	854e                	mv	a0,s3
    80003a64:	ef1ff0ef          	jal	80003954 <iput>
      end_op();
    80003a68:	7be000ef          	jal	80004226 <end_op>
  for (int inum = 1; inum < sb.ninodes; inum++) {
    80003a6c:	0485                	addi	s1,s1,1
    80003a6e:	00caa703          	lw	a4,12(s5)
    80003a72:	0004879b          	sext.w	a5,s1
    80003a76:	02e7fd63          	bgeu	a5,a4,80003ab0 <ireclaim+0xb4>
    80003a7a:	0004899b          	sext.w	s3,s1
    struct buf *bp = bread(dev, IBLOCK(inum, sb));
    80003a7e:	0044d593          	srli	a1,s1,0x4
    80003a82:	018aa783          	lw	a5,24(s5)
    80003a86:	9dbd                	addw	a1,a1,a5
    80003a88:	8552                	mv	a0,s4
    80003a8a:	e3eff0ef          	jal	800030c8 <bread>
    80003a8e:	892a                	mv	s2,a0
    struct dinode *dip = (struct dinode *)bp->data + inum % IPB;
    80003a90:	05850793          	addi	a5,a0,88
    80003a94:	00f9f713          	andi	a4,s3,15
    80003a98:	071a                	slli	a4,a4,0x6
    80003a9a:	97ba                	add	a5,a5,a4
    if (dip->type != 0 && dip->nlink == 0) {  // is an orphaned inode
    80003a9c:	00079703          	lh	a4,0(a5)
    80003aa0:	c701                	beqz	a4,80003aa8 <ireclaim+0xac>
    80003aa2:	00679783          	lh	a5,6(a5)
    80003aa6:	dbc1                	beqz	a5,80003a36 <ireclaim+0x3a>
    brelse(bp);
    80003aa8:	854a                	mv	a0,s2
    80003aaa:	f4eff0ef          	jal	800031f8 <brelse>
    if (ip) {
    80003aae:	bf7d                	j	80003a6c <ireclaim+0x70>
}
    80003ab0:	70e2                	ld	ra,56(sp)
    80003ab2:	7442                	ld	s0,48(sp)
    80003ab4:	74a2                	ld	s1,40(sp)
    80003ab6:	7902                	ld	s2,32(sp)
    80003ab8:	69e2                	ld	s3,24(sp)
    80003aba:	6a42                	ld	s4,16(sp)
    80003abc:	6aa2                	ld	s5,8(sp)
    80003abe:	6b02                	ld	s6,0(sp)
    80003ac0:	6121                	addi	sp,sp,64
    80003ac2:	8082                	ret
    80003ac4:	8082                	ret

0000000080003ac6 <fsinit>:
fsinit(int dev) {
    80003ac6:	7179                	addi	sp,sp,-48
    80003ac8:	f406                	sd	ra,40(sp)
    80003aca:	f022                	sd	s0,32(sp)
    80003acc:	ec26                	sd	s1,24(sp)
    80003ace:	e84a                	sd	s2,16(sp)
    80003ad0:	e44e                	sd	s3,8(sp)
    80003ad2:	1800                	addi	s0,sp,48
    80003ad4:	84aa                	mv	s1,a0
  bp = bread(dev, 1);
    80003ad6:	4585                	li	a1,1
    80003ad8:	df0ff0ef          	jal	800030c8 <bread>
    80003adc:	892a                	mv	s2,a0
  memmove(sb, bp->data, sizeof(*sb));
    80003ade:	0001e997          	auipc	s3,0x1e
    80003ae2:	26a98993          	addi	s3,s3,618 # 80021d48 <sb>
    80003ae6:	02000613          	li	a2,32
    80003aea:	05850593          	addi	a1,a0,88
    80003aee:	854e                	mv	a0,s3
    80003af0:	afcfd0ef          	jal	80000dec <memmove>
  brelse(bp);
    80003af4:	854a                	mv	a0,s2
    80003af6:	f02ff0ef          	jal	800031f8 <brelse>
  if(sb.magic != FSMAGIC)
    80003afa:	0009a703          	lw	a4,0(s3)
    80003afe:	102037b7          	lui	a5,0x10203
    80003b02:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    80003b06:	02f71363          	bne	a4,a5,80003b2c <fsinit+0x66>
  initlog(dev, &sb);
    80003b0a:	0001e597          	auipc	a1,0x1e
    80003b0e:	23e58593          	addi	a1,a1,574 # 80021d48 <sb>
    80003b12:	8526                	mv	a0,s1
    80003b14:	62a000ef          	jal	8000413e <initlog>
  ireclaim(dev);
    80003b18:	8526                	mv	a0,s1
    80003b1a:	ee3ff0ef          	jal	800039fc <ireclaim>
}
    80003b1e:	70a2                	ld	ra,40(sp)
    80003b20:	7402                	ld	s0,32(sp)
    80003b22:	64e2                	ld	s1,24(sp)
    80003b24:	6942                	ld	s2,16(sp)
    80003b26:	69a2                	ld	s3,8(sp)
    80003b28:	6145                	addi	sp,sp,48
    80003b2a:	8082                	ret
    panic("invalid file system");
    80003b2c:	00005517          	auipc	a0,0x5
    80003b30:	99450513          	addi	a0,a0,-1644 # 800084c0 <etext+0x4c0>
    80003b34:	cdffc0ef          	jal	80000812 <panic>

0000000080003b38 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80003b38:	1141                	addi	sp,sp,-16
    80003b3a:	e422                	sd	s0,8(sp)
    80003b3c:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80003b3e:	411c                	lw	a5,0(a0)
    80003b40:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80003b42:	415c                	lw	a5,4(a0)
    80003b44:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80003b46:	04451783          	lh	a5,68(a0)
    80003b4a:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80003b4e:	04a51783          	lh	a5,74(a0)
    80003b52:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80003b56:	04c56783          	lwu	a5,76(a0)
    80003b5a:	e99c                	sd	a5,16(a1)
}
    80003b5c:	6422                	ld	s0,8(sp)
    80003b5e:	0141                	addi	sp,sp,16
    80003b60:	8082                	ret

0000000080003b62 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003b62:	457c                	lw	a5,76(a0)
    80003b64:	0ed7eb63          	bltu	a5,a3,80003c5a <readi+0xf8>
{
    80003b68:	7159                	addi	sp,sp,-112
    80003b6a:	f486                	sd	ra,104(sp)
    80003b6c:	f0a2                	sd	s0,96(sp)
    80003b6e:	eca6                	sd	s1,88(sp)
    80003b70:	e0d2                	sd	s4,64(sp)
    80003b72:	fc56                	sd	s5,56(sp)
    80003b74:	f85a                	sd	s6,48(sp)
    80003b76:	f45e                	sd	s7,40(sp)
    80003b78:	1880                	addi	s0,sp,112
    80003b7a:	8b2a                	mv	s6,a0
    80003b7c:	8bae                	mv	s7,a1
    80003b7e:	8a32                	mv	s4,a2
    80003b80:	84b6                	mv	s1,a3
    80003b82:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    80003b84:	9f35                	addw	a4,a4,a3
    return 0;
    80003b86:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80003b88:	0cd76063          	bltu	a4,a3,80003c48 <readi+0xe6>
    80003b8c:	e4ce                	sd	s3,72(sp)
  if(off + n > ip->size)
    80003b8e:	00e7f463          	bgeu	a5,a4,80003b96 <readi+0x34>
    n = ip->size - off;
    80003b92:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003b96:	080a8f63          	beqz	s5,80003c34 <readi+0xd2>
    80003b9a:	e8ca                	sd	s2,80(sp)
    80003b9c:	f062                	sd	s8,32(sp)
    80003b9e:	ec66                	sd	s9,24(sp)
    80003ba0:	e86a                	sd	s10,16(sp)
    80003ba2:	e46e                	sd	s11,8(sp)
    80003ba4:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003ba6:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80003baa:	5c7d                	li	s8,-1
    80003bac:	a80d                	j	80003bde <readi+0x7c>
    80003bae:	020d1d93          	slli	s11,s10,0x20
    80003bb2:	020ddd93          	srli	s11,s11,0x20
    80003bb6:	05890613          	addi	a2,s2,88
    80003bba:	86ee                	mv	a3,s11
    80003bbc:	963a                	add	a2,a2,a4
    80003bbe:	85d2                	mv	a1,s4
    80003bc0:	855e                	mv	a0,s7
    80003bc2:	b91fe0ef          	jal	80002752 <either_copyout>
    80003bc6:	05850763          	beq	a0,s8,80003c14 <readi+0xb2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80003bca:	854a                	mv	a0,s2
    80003bcc:	e2cff0ef          	jal	800031f8 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003bd0:	013d09bb          	addw	s3,s10,s3
    80003bd4:	009d04bb          	addw	s1,s10,s1
    80003bd8:	9a6e                	add	s4,s4,s11
    80003bda:	0559f763          	bgeu	s3,s5,80003c28 <readi+0xc6>
    uint addr = bmap(ip, off/BSIZE);
    80003bde:	00a4d59b          	srliw	a1,s1,0xa
    80003be2:	855a                	mv	a0,s6
    80003be4:	8a7ff0ef          	jal	8000348a <bmap>
    80003be8:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80003bec:	c5b1                	beqz	a1,80003c38 <readi+0xd6>
    bp = bread(ip->dev, addr);
    80003bee:	000b2503          	lw	a0,0(s6)
    80003bf2:	cd6ff0ef          	jal	800030c8 <bread>
    80003bf6:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003bf8:	3ff4f713          	andi	a4,s1,1023
    80003bfc:	40ec87bb          	subw	a5,s9,a4
    80003c00:	413a86bb          	subw	a3,s5,s3
    80003c04:	8d3e                	mv	s10,a5
    80003c06:	2781                	sext.w	a5,a5
    80003c08:	0006861b          	sext.w	a2,a3
    80003c0c:	faf671e3          	bgeu	a2,a5,80003bae <readi+0x4c>
    80003c10:	8d36                	mv	s10,a3
    80003c12:	bf71                	j	80003bae <readi+0x4c>
      brelse(bp);
    80003c14:	854a                	mv	a0,s2
    80003c16:	de2ff0ef          	jal	800031f8 <brelse>
      tot = -1;
    80003c1a:	59fd                	li	s3,-1
      break;
    80003c1c:	6946                	ld	s2,80(sp)
    80003c1e:	7c02                	ld	s8,32(sp)
    80003c20:	6ce2                	ld	s9,24(sp)
    80003c22:	6d42                	ld	s10,16(sp)
    80003c24:	6da2                	ld	s11,8(sp)
    80003c26:	a831                	j	80003c42 <readi+0xe0>
    80003c28:	6946                	ld	s2,80(sp)
    80003c2a:	7c02                	ld	s8,32(sp)
    80003c2c:	6ce2                	ld	s9,24(sp)
    80003c2e:	6d42                	ld	s10,16(sp)
    80003c30:	6da2                	ld	s11,8(sp)
    80003c32:	a801                	j	80003c42 <readi+0xe0>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003c34:	89d6                	mv	s3,s5
    80003c36:	a031                	j	80003c42 <readi+0xe0>
    80003c38:	6946                	ld	s2,80(sp)
    80003c3a:	7c02                	ld	s8,32(sp)
    80003c3c:	6ce2                	ld	s9,24(sp)
    80003c3e:	6d42                	ld	s10,16(sp)
    80003c40:	6da2                	ld	s11,8(sp)
  }
  return tot;
    80003c42:	0009851b          	sext.w	a0,s3
    80003c46:	69a6                	ld	s3,72(sp)
}
    80003c48:	70a6                	ld	ra,104(sp)
    80003c4a:	7406                	ld	s0,96(sp)
    80003c4c:	64e6                	ld	s1,88(sp)
    80003c4e:	6a06                	ld	s4,64(sp)
    80003c50:	7ae2                	ld	s5,56(sp)
    80003c52:	7b42                	ld	s6,48(sp)
    80003c54:	7ba2                	ld	s7,40(sp)
    80003c56:	6165                	addi	sp,sp,112
    80003c58:	8082                	ret
    return 0;
    80003c5a:	4501                	li	a0,0
}
    80003c5c:	8082                	ret

0000000080003c5e <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003c5e:	457c                	lw	a5,76(a0)
    80003c60:	10d7e063          	bltu	a5,a3,80003d60 <writei+0x102>
{
    80003c64:	7159                	addi	sp,sp,-112
    80003c66:	f486                	sd	ra,104(sp)
    80003c68:	f0a2                	sd	s0,96(sp)
    80003c6a:	e8ca                	sd	s2,80(sp)
    80003c6c:	e0d2                	sd	s4,64(sp)
    80003c6e:	fc56                	sd	s5,56(sp)
    80003c70:	f85a                	sd	s6,48(sp)
    80003c72:	f45e                	sd	s7,40(sp)
    80003c74:	1880                	addi	s0,sp,112
    80003c76:	8aaa                	mv	s5,a0
    80003c78:	8bae                	mv	s7,a1
    80003c7a:	8a32                	mv	s4,a2
    80003c7c:	8936                	mv	s2,a3
    80003c7e:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003c80:	00e687bb          	addw	a5,a3,a4
    80003c84:	0ed7e063          	bltu	a5,a3,80003d64 <writei+0x106>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80003c88:	00043737          	lui	a4,0x43
    80003c8c:	0cf76e63          	bltu	a4,a5,80003d68 <writei+0x10a>
    80003c90:	e4ce                	sd	s3,72(sp)
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003c92:	0a0b0f63          	beqz	s6,80003d50 <writei+0xf2>
    80003c96:	eca6                	sd	s1,88(sp)
    80003c98:	f062                	sd	s8,32(sp)
    80003c9a:	ec66                	sd	s9,24(sp)
    80003c9c:	e86a                	sd	s10,16(sp)
    80003c9e:	e46e                	sd	s11,8(sp)
    80003ca0:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003ca2:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80003ca6:	5c7d                	li	s8,-1
    80003ca8:	a825                	j	80003ce0 <writei+0x82>
    80003caa:	020d1d93          	slli	s11,s10,0x20
    80003cae:	020ddd93          	srli	s11,s11,0x20
    80003cb2:	05848513          	addi	a0,s1,88
    80003cb6:	86ee                	mv	a3,s11
    80003cb8:	8652                	mv	a2,s4
    80003cba:	85de                	mv	a1,s7
    80003cbc:	953a                	add	a0,a0,a4
    80003cbe:	adffe0ef          	jal	8000279c <either_copyin>
    80003cc2:	05850a63          	beq	a0,s8,80003d16 <writei+0xb8>
      brelse(bp);
      break;
    }
    log_write(bp);
    80003cc6:	8526                	mv	a0,s1
    80003cc8:	678000ef          	jal	80004340 <log_write>
    brelse(bp);
    80003ccc:	8526                	mv	a0,s1
    80003cce:	d2aff0ef          	jal	800031f8 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003cd2:	013d09bb          	addw	s3,s10,s3
    80003cd6:	012d093b          	addw	s2,s10,s2
    80003cda:	9a6e                	add	s4,s4,s11
    80003cdc:	0569f063          	bgeu	s3,s6,80003d1c <writei+0xbe>
    uint addr = bmap(ip, off/BSIZE);
    80003ce0:	00a9559b          	srliw	a1,s2,0xa
    80003ce4:	8556                	mv	a0,s5
    80003ce6:	fa4ff0ef          	jal	8000348a <bmap>
    80003cea:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80003cee:	c59d                	beqz	a1,80003d1c <writei+0xbe>
    bp = bread(ip->dev, addr);
    80003cf0:	000aa503          	lw	a0,0(s5)
    80003cf4:	bd4ff0ef          	jal	800030c8 <bread>
    80003cf8:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003cfa:	3ff97713          	andi	a4,s2,1023
    80003cfe:	40ec87bb          	subw	a5,s9,a4
    80003d02:	413b06bb          	subw	a3,s6,s3
    80003d06:	8d3e                	mv	s10,a5
    80003d08:	2781                	sext.w	a5,a5
    80003d0a:	0006861b          	sext.w	a2,a3
    80003d0e:	f8f67ee3          	bgeu	a2,a5,80003caa <writei+0x4c>
    80003d12:	8d36                	mv	s10,a3
    80003d14:	bf59                	j	80003caa <writei+0x4c>
      brelse(bp);
    80003d16:	8526                	mv	a0,s1
    80003d18:	ce0ff0ef          	jal	800031f8 <brelse>
  }

  if(off > ip->size)
    80003d1c:	04caa783          	lw	a5,76(s5)
    80003d20:	0327fa63          	bgeu	a5,s2,80003d54 <writei+0xf6>
    ip->size = off;
    80003d24:	052aa623          	sw	s2,76(s5)
    80003d28:	64e6                	ld	s1,88(sp)
    80003d2a:	7c02                	ld	s8,32(sp)
    80003d2c:	6ce2                	ld	s9,24(sp)
    80003d2e:	6d42                	ld	s10,16(sp)
    80003d30:	6da2                	ld	s11,8(sp)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80003d32:	8556                	mv	a0,s5
    80003d34:	9ebff0ef          	jal	8000371e <iupdate>

  return tot;
    80003d38:	0009851b          	sext.w	a0,s3
    80003d3c:	69a6                	ld	s3,72(sp)
}
    80003d3e:	70a6                	ld	ra,104(sp)
    80003d40:	7406                	ld	s0,96(sp)
    80003d42:	6946                	ld	s2,80(sp)
    80003d44:	6a06                	ld	s4,64(sp)
    80003d46:	7ae2                	ld	s5,56(sp)
    80003d48:	7b42                	ld	s6,48(sp)
    80003d4a:	7ba2                	ld	s7,40(sp)
    80003d4c:	6165                	addi	sp,sp,112
    80003d4e:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003d50:	89da                	mv	s3,s6
    80003d52:	b7c5                	j	80003d32 <writei+0xd4>
    80003d54:	64e6                	ld	s1,88(sp)
    80003d56:	7c02                	ld	s8,32(sp)
    80003d58:	6ce2                	ld	s9,24(sp)
    80003d5a:	6d42                	ld	s10,16(sp)
    80003d5c:	6da2                	ld	s11,8(sp)
    80003d5e:	bfd1                	j	80003d32 <writei+0xd4>
    return -1;
    80003d60:	557d                	li	a0,-1
}
    80003d62:	8082                	ret
    return -1;
    80003d64:	557d                	li	a0,-1
    80003d66:	bfe1                	j	80003d3e <writei+0xe0>
    return -1;
    80003d68:	557d                	li	a0,-1
    80003d6a:	bfd1                	j	80003d3e <writei+0xe0>

0000000080003d6c <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80003d6c:	1141                	addi	sp,sp,-16
    80003d6e:	e406                	sd	ra,8(sp)
    80003d70:	e022                	sd	s0,0(sp)
    80003d72:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80003d74:	4639                	li	a2,14
    80003d76:	8e6fd0ef          	jal	80000e5c <strncmp>
}
    80003d7a:	60a2                	ld	ra,8(sp)
    80003d7c:	6402                	ld	s0,0(sp)
    80003d7e:	0141                	addi	sp,sp,16
    80003d80:	8082                	ret

0000000080003d82 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80003d82:	7139                	addi	sp,sp,-64
    80003d84:	fc06                	sd	ra,56(sp)
    80003d86:	f822                	sd	s0,48(sp)
    80003d88:	f426                	sd	s1,40(sp)
    80003d8a:	f04a                	sd	s2,32(sp)
    80003d8c:	ec4e                	sd	s3,24(sp)
    80003d8e:	e852                	sd	s4,16(sp)
    80003d90:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80003d92:	04451703          	lh	a4,68(a0)
    80003d96:	4785                	li	a5,1
    80003d98:	00f71a63          	bne	a4,a5,80003dac <dirlookup+0x2a>
    80003d9c:	892a                	mv	s2,a0
    80003d9e:	89ae                	mv	s3,a1
    80003da0:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80003da2:	457c                	lw	a5,76(a0)
    80003da4:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80003da6:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003da8:	e39d                	bnez	a5,80003dce <dirlookup+0x4c>
    80003daa:	a095                	j	80003e0e <dirlookup+0x8c>
    panic("dirlookup not DIR");
    80003dac:	00004517          	auipc	a0,0x4
    80003db0:	72c50513          	addi	a0,a0,1836 # 800084d8 <etext+0x4d8>
    80003db4:	a5ffc0ef          	jal	80000812 <panic>
      panic("dirlookup read");
    80003db8:	00004517          	auipc	a0,0x4
    80003dbc:	73850513          	addi	a0,a0,1848 # 800084f0 <etext+0x4f0>
    80003dc0:	a53fc0ef          	jal	80000812 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003dc4:	24c1                	addiw	s1,s1,16
    80003dc6:	04c92783          	lw	a5,76(s2)
    80003dca:	04f4f163          	bgeu	s1,a5,80003e0c <dirlookup+0x8a>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003dce:	4741                	li	a4,16
    80003dd0:	86a6                	mv	a3,s1
    80003dd2:	fc040613          	addi	a2,s0,-64
    80003dd6:	4581                	li	a1,0
    80003dd8:	854a                	mv	a0,s2
    80003dda:	d89ff0ef          	jal	80003b62 <readi>
    80003dde:	47c1                	li	a5,16
    80003de0:	fcf51ce3          	bne	a0,a5,80003db8 <dirlookup+0x36>
    if(de.inum == 0)
    80003de4:	fc045783          	lhu	a5,-64(s0)
    80003de8:	dff1                	beqz	a5,80003dc4 <dirlookup+0x42>
    if(namecmp(name, de.name) == 0){
    80003dea:	fc240593          	addi	a1,s0,-62
    80003dee:	854e                	mv	a0,s3
    80003df0:	f7dff0ef          	jal	80003d6c <namecmp>
    80003df4:	f961                	bnez	a0,80003dc4 <dirlookup+0x42>
      if(poff)
    80003df6:	000a0463          	beqz	s4,80003dfe <dirlookup+0x7c>
        *poff = off;
    80003dfa:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    80003dfe:	fc045583          	lhu	a1,-64(s0)
    80003e02:	00092503          	lw	a0,0(s2)
    80003e06:	f58ff0ef          	jal	8000355e <iget>
    80003e0a:	a011                	j	80003e0e <dirlookup+0x8c>
  return 0;
    80003e0c:	4501                	li	a0,0
}
    80003e0e:	70e2                	ld	ra,56(sp)
    80003e10:	7442                	ld	s0,48(sp)
    80003e12:	74a2                	ld	s1,40(sp)
    80003e14:	7902                	ld	s2,32(sp)
    80003e16:	69e2                	ld	s3,24(sp)
    80003e18:	6a42                	ld	s4,16(sp)
    80003e1a:	6121                	addi	sp,sp,64
    80003e1c:	8082                	ret

0000000080003e1e <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80003e1e:	711d                	addi	sp,sp,-96
    80003e20:	ec86                	sd	ra,88(sp)
    80003e22:	e8a2                	sd	s0,80(sp)
    80003e24:	e4a6                	sd	s1,72(sp)
    80003e26:	e0ca                	sd	s2,64(sp)
    80003e28:	fc4e                	sd	s3,56(sp)
    80003e2a:	f852                	sd	s4,48(sp)
    80003e2c:	f456                	sd	s5,40(sp)
    80003e2e:	f05a                	sd	s6,32(sp)
    80003e30:	ec5e                	sd	s7,24(sp)
    80003e32:	e862                	sd	s8,16(sp)
    80003e34:	e466                	sd	s9,8(sp)
    80003e36:	1080                	addi	s0,sp,96
    80003e38:	84aa                	mv	s1,a0
    80003e3a:	8b2e                	mv	s6,a1
    80003e3c:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    80003e3e:	00054703          	lbu	a4,0(a0)
    80003e42:	02f00793          	li	a5,47
    80003e46:	00f70e63          	beq	a4,a5,80003e62 <namex+0x44>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80003e4a:	d89fd0ef          	jal	80001bd2 <myproc>
    80003e4e:	15053503          	ld	a0,336(a0)
    80003e52:	94bff0ef          	jal	8000379c <idup>
    80003e56:	8a2a                	mv	s4,a0
  while(*path == '/')
    80003e58:	02f00913          	li	s2,47
  if(len >= DIRSIZ)
    80003e5c:	4c35                	li	s8,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80003e5e:	4b85                	li	s7,1
    80003e60:	a871                	j	80003efc <namex+0xde>
    ip = iget(ROOTDEV, ROOTINO);
    80003e62:	4585                	li	a1,1
    80003e64:	4505                	li	a0,1
    80003e66:	ef8ff0ef          	jal	8000355e <iget>
    80003e6a:	8a2a                	mv	s4,a0
    80003e6c:	b7f5                	j	80003e58 <namex+0x3a>
      iunlockput(ip);
    80003e6e:	8552                	mv	a0,s4
    80003e70:	b6dff0ef          	jal	800039dc <iunlockput>
      return 0;
    80003e74:	4a01                	li	s4,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80003e76:	8552                	mv	a0,s4
    80003e78:	60e6                	ld	ra,88(sp)
    80003e7a:	6446                	ld	s0,80(sp)
    80003e7c:	64a6                	ld	s1,72(sp)
    80003e7e:	6906                	ld	s2,64(sp)
    80003e80:	79e2                	ld	s3,56(sp)
    80003e82:	7a42                	ld	s4,48(sp)
    80003e84:	7aa2                	ld	s5,40(sp)
    80003e86:	7b02                	ld	s6,32(sp)
    80003e88:	6be2                	ld	s7,24(sp)
    80003e8a:	6c42                	ld	s8,16(sp)
    80003e8c:	6ca2                	ld	s9,8(sp)
    80003e8e:	6125                	addi	sp,sp,96
    80003e90:	8082                	ret
      iunlock(ip);
    80003e92:	8552                	mv	a0,s4
    80003e94:	9edff0ef          	jal	80003880 <iunlock>
      return ip;
    80003e98:	bff9                	j	80003e76 <namex+0x58>
      iunlockput(ip);
    80003e9a:	8552                	mv	a0,s4
    80003e9c:	b41ff0ef          	jal	800039dc <iunlockput>
      return 0;
    80003ea0:	8a4e                	mv	s4,s3
    80003ea2:	bfd1                	j	80003e76 <namex+0x58>
  len = path - s;
    80003ea4:	40998633          	sub	a2,s3,s1
    80003ea8:	00060c9b          	sext.w	s9,a2
  if(len >= DIRSIZ)
    80003eac:	099c5063          	bge	s8,s9,80003f2c <namex+0x10e>
    memmove(name, s, DIRSIZ);
    80003eb0:	4639                	li	a2,14
    80003eb2:	85a6                	mv	a1,s1
    80003eb4:	8556                	mv	a0,s5
    80003eb6:	f37fc0ef          	jal	80000dec <memmove>
    80003eba:	84ce                	mv	s1,s3
  while(*path == '/')
    80003ebc:	0004c783          	lbu	a5,0(s1)
    80003ec0:	01279763          	bne	a5,s2,80003ece <namex+0xb0>
    path++;
    80003ec4:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003ec6:	0004c783          	lbu	a5,0(s1)
    80003eca:	ff278de3          	beq	a5,s2,80003ec4 <namex+0xa6>
    ilock(ip);
    80003ece:	8552                	mv	a0,s4
    80003ed0:	903ff0ef          	jal	800037d2 <ilock>
    if(ip->type != T_DIR){
    80003ed4:	044a1783          	lh	a5,68(s4)
    80003ed8:	f9779be3          	bne	a5,s7,80003e6e <namex+0x50>
    if(nameiparent && *path == '\0'){
    80003edc:	000b0563          	beqz	s6,80003ee6 <namex+0xc8>
    80003ee0:	0004c783          	lbu	a5,0(s1)
    80003ee4:	d7dd                	beqz	a5,80003e92 <namex+0x74>
    if((next = dirlookup(ip, name, 0)) == 0){
    80003ee6:	4601                	li	a2,0
    80003ee8:	85d6                	mv	a1,s5
    80003eea:	8552                	mv	a0,s4
    80003eec:	e97ff0ef          	jal	80003d82 <dirlookup>
    80003ef0:	89aa                	mv	s3,a0
    80003ef2:	d545                	beqz	a0,80003e9a <namex+0x7c>
    iunlockput(ip);
    80003ef4:	8552                	mv	a0,s4
    80003ef6:	ae7ff0ef          	jal	800039dc <iunlockput>
    ip = next;
    80003efa:	8a4e                	mv	s4,s3
  while(*path == '/')
    80003efc:	0004c783          	lbu	a5,0(s1)
    80003f00:	01279763          	bne	a5,s2,80003f0e <namex+0xf0>
    path++;
    80003f04:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003f06:	0004c783          	lbu	a5,0(s1)
    80003f0a:	ff278de3          	beq	a5,s2,80003f04 <namex+0xe6>
  if(*path == 0)
    80003f0e:	cb8d                	beqz	a5,80003f40 <namex+0x122>
  while(*path != '/' && *path != 0)
    80003f10:	0004c783          	lbu	a5,0(s1)
    80003f14:	89a6                	mv	s3,s1
  len = path - s;
    80003f16:	4c81                	li	s9,0
    80003f18:	4601                	li	a2,0
  while(*path != '/' && *path != 0)
    80003f1a:	01278963          	beq	a5,s2,80003f2c <namex+0x10e>
    80003f1e:	d3d9                	beqz	a5,80003ea4 <namex+0x86>
    path++;
    80003f20:	0985                	addi	s3,s3,1
  while(*path != '/' && *path != 0)
    80003f22:	0009c783          	lbu	a5,0(s3)
    80003f26:	ff279ce3          	bne	a5,s2,80003f1e <namex+0x100>
    80003f2a:	bfad                	j	80003ea4 <namex+0x86>
    memmove(name, s, len);
    80003f2c:	2601                	sext.w	a2,a2
    80003f2e:	85a6                	mv	a1,s1
    80003f30:	8556                	mv	a0,s5
    80003f32:	ebbfc0ef          	jal	80000dec <memmove>
    name[len] = 0;
    80003f36:	9cd6                	add	s9,s9,s5
    80003f38:	000c8023          	sb	zero,0(s9) # 2000 <_entry-0x7fffe000>
    80003f3c:	84ce                	mv	s1,s3
    80003f3e:	bfbd                	j	80003ebc <namex+0x9e>
  if(nameiparent){
    80003f40:	f20b0be3          	beqz	s6,80003e76 <namex+0x58>
    iput(ip);
    80003f44:	8552                	mv	a0,s4
    80003f46:	a0fff0ef          	jal	80003954 <iput>
    return 0;
    80003f4a:	4a01                	li	s4,0
    80003f4c:	b72d                	j	80003e76 <namex+0x58>

0000000080003f4e <dirlink>:
{
    80003f4e:	7139                	addi	sp,sp,-64
    80003f50:	fc06                	sd	ra,56(sp)
    80003f52:	f822                	sd	s0,48(sp)
    80003f54:	f04a                	sd	s2,32(sp)
    80003f56:	ec4e                	sd	s3,24(sp)
    80003f58:	e852                	sd	s4,16(sp)
    80003f5a:	0080                	addi	s0,sp,64
    80003f5c:	892a                	mv	s2,a0
    80003f5e:	8a2e                	mv	s4,a1
    80003f60:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80003f62:	4601                	li	a2,0
    80003f64:	e1fff0ef          	jal	80003d82 <dirlookup>
    80003f68:	e535                	bnez	a0,80003fd4 <dirlink+0x86>
    80003f6a:	f426                	sd	s1,40(sp)
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003f6c:	04c92483          	lw	s1,76(s2)
    80003f70:	c48d                	beqz	s1,80003f9a <dirlink+0x4c>
    80003f72:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003f74:	4741                	li	a4,16
    80003f76:	86a6                	mv	a3,s1
    80003f78:	fc040613          	addi	a2,s0,-64
    80003f7c:	4581                	li	a1,0
    80003f7e:	854a                	mv	a0,s2
    80003f80:	be3ff0ef          	jal	80003b62 <readi>
    80003f84:	47c1                	li	a5,16
    80003f86:	04f51b63          	bne	a0,a5,80003fdc <dirlink+0x8e>
    if(de.inum == 0)
    80003f8a:	fc045783          	lhu	a5,-64(s0)
    80003f8e:	c791                	beqz	a5,80003f9a <dirlink+0x4c>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003f90:	24c1                	addiw	s1,s1,16
    80003f92:	04c92783          	lw	a5,76(s2)
    80003f96:	fcf4efe3          	bltu	s1,a5,80003f74 <dirlink+0x26>
  strncpy(de.name, name, DIRSIZ);
    80003f9a:	4639                	li	a2,14
    80003f9c:	85d2                	mv	a1,s4
    80003f9e:	fc240513          	addi	a0,s0,-62
    80003fa2:	ef1fc0ef          	jal	80000e92 <strncpy>
  de.inum = inum;
    80003fa6:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003faa:	4741                	li	a4,16
    80003fac:	86a6                	mv	a3,s1
    80003fae:	fc040613          	addi	a2,s0,-64
    80003fb2:	4581                	li	a1,0
    80003fb4:	854a                	mv	a0,s2
    80003fb6:	ca9ff0ef          	jal	80003c5e <writei>
    80003fba:	1541                	addi	a0,a0,-16
    80003fbc:	00a03533          	snez	a0,a0
    80003fc0:	40a00533          	neg	a0,a0
    80003fc4:	74a2                	ld	s1,40(sp)
}
    80003fc6:	70e2                	ld	ra,56(sp)
    80003fc8:	7442                	ld	s0,48(sp)
    80003fca:	7902                	ld	s2,32(sp)
    80003fcc:	69e2                	ld	s3,24(sp)
    80003fce:	6a42                	ld	s4,16(sp)
    80003fd0:	6121                	addi	sp,sp,64
    80003fd2:	8082                	ret
    iput(ip);
    80003fd4:	981ff0ef          	jal	80003954 <iput>
    return -1;
    80003fd8:	557d                	li	a0,-1
    80003fda:	b7f5                	j	80003fc6 <dirlink+0x78>
      panic("dirlink read");
    80003fdc:	00004517          	auipc	a0,0x4
    80003fe0:	52450513          	addi	a0,a0,1316 # 80008500 <etext+0x500>
    80003fe4:	82ffc0ef          	jal	80000812 <panic>

0000000080003fe8 <namei>:

struct inode*
namei(char *path)
{
    80003fe8:	1101                	addi	sp,sp,-32
    80003fea:	ec06                	sd	ra,24(sp)
    80003fec:	e822                	sd	s0,16(sp)
    80003fee:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80003ff0:	fe040613          	addi	a2,s0,-32
    80003ff4:	4581                	li	a1,0
    80003ff6:	e29ff0ef          	jal	80003e1e <namex>
}
    80003ffa:	60e2                	ld	ra,24(sp)
    80003ffc:	6442                	ld	s0,16(sp)
    80003ffe:	6105                	addi	sp,sp,32
    80004000:	8082                	ret

0000000080004002 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    80004002:	1141                	addi	sp,sp,-16
    80004004:	e406                	sd	ra,8(sp)
    80004006:	e022                	sd	s0,0(sp)
    80004008:	0800                	addi	s0,sp,16
    8000400a:	862e                	mv	a2,a1
  return namex(path, 1, name);
    8000400c:	4585                	li	a1,1
    8000400e:	e11ff0ef          	jal	80003e1e <namex>
}
    80004012:	60a2                	ld	ra,8(sp)
    80004014:	6402                	ld	s0,0(sp)
    80004016:	0141                	addi	sp,sp,16
    80004018:	8082                	ret

000000008000401a <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    8000401a:	1101                	addi	sp,sp,-32
    8000401c:	ec06                	sd	ra,24(sp)
    8000401e:	e822                	sd	s0,16(sp)
    80004020:	e426                	sd	s1,8(sp)
    80004022:	e04a                	sd	s2,0(sp)
    80004024:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80004026:	0001f917          	auipc	s2,0x1f
    8000402a:	7ea90913          	addi	s2,s2,2026 # 80023810 <log>
    8000402e:	01892583          	lw	a1,24(s2)
    80004032:	02492503          	lw	a0,36(s2)
    80004036:	892ff0ef          	jal	800030c8 <bread>
    8000403a:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    8000403c:	02892603          	lw	a2,40(s2)
    80004040:	cd30                	sw	a2,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80004042:	00c05f63          	blez	a2,80004060 <write_head+0x46>
    80004046:	0001f717          	auipc	a4,0x1f
    8000404a:	7f670713          	addi	a4,a4,2038 # 8002383c <log+0x2c>
    8000404e:	87aa                	mv	a5,a0
    80004050:	060a                	slli	a2,a2,0x2
    80004052:	962a                	add	a2,a2,a0
    hb->block[i] = log.lh.block[i];
    80004054:	4314                	lw	a3,0(a4)
    80004056:	cff4                	sw	a3,92(a5)
  for (i = 0; i < log.lh.n; i++) {
    80004058:	0711                	addi	a4,a4,4
    8000405a:	0791                	addi	a5,a5,4
    8000405c:	fec79ce3          	bne	a5,a2,80004054 <write_head+0x3a>
  }
  bwrite(buf);
    80004060:	8526                	mv	a0,s1
    80004062:	964ff0ef          	jal	800031c6 <bwrite>
  brelse(buf);
    80004066:	8526                	mv	a0,s1
    80004068:	990ff0ef          	jal	800031f8 <brelse>
}
    8000406c:	60e2                	ld	ra,24(sp)
    8000406e:	6442                	ld	s0,16(sp)
    80004070:	64a2                	ld	s1,8(sp)
    80004072:	6902                	ld	s2,0(sp)
    80004074:	6105                	addi	sp,sp,32
    80004076:	8082                	ret

0000000080004078 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80004078:	0001f797          	auipc	a5,0x1f
    8000407c:	7c07a783          	lw	a5,1984(a5) # 80023838 <log+0x28>
    80004080:	0af05e63          	blez	a5,8000413c <install_trans+0xc4>
{
    80004084:	715d                	addi	sp,sp,-80
    80004086:	e486                	sd	ra,72(sp)
    80004088:	e0a2                	sd	s0,64(sp)
    8000408a:	fc26                	sd	s1,56(sp)
    8000408c:	f84a                	sd	s2,48(sp)
    8000408e:	f44e                	sd	s3,40(sp)
    80004090:	f052                	sd	s4,32(sp)
    80004092:	ec56                	sd	s5,24(sp)
    80004094:	e85a                	sd	s6,16(sp)
    80004096:	e45e                	sd	s7,8(sp)
    80004098:	0880                	addi	s0,sp,80
    8000409a:	8b2a                	mv	s6,a0
    8000409c:	0001fa97          	auipc	s5,0x1f
    800040a0:	7a0a8a93          	addi	s5,s5,1952 # 8002383c <log+0x2c>
  for (tail = 0; tail < log.lh.n; tail++) {
    800040a4:	4981                	li	s3,0
      printf("recovering tail %d dst %d\n", tail, log.lh.block[tail]);
    800040a6:	00004b97          	auipc	s7,0x4
    800040aa:	46ab8b93          	addi	s7,s7,1130 # 80008510 <etext+0x510>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    800040ae:	0001fa17          	auipc	s4,0x1f
    800040b2:	762a0a13          	addi	s4,s4,1890 # 80023810 <log>
    800040b6:	a025                	j	800040de <install_trans+0x66>
      printf("recovering tail %d dst %d\n", tail, log.lh.block[tail]);
    800040b8:	000aa603          	lw	a2,0(s5)
    800040bc:	85ce                	mv	a1,s3
    800040be:	855e                	mv	a0,s7
    800040c0:	c6cfc0ef          	jal	8000052c <printf>
    800040c4:	a839                	j	800040e2 <install_trans+0x6a>
    brelse(lbuf);
    800040c6:	854a                	mv	a0,s2
    800040c8:	930ff0ef          	jal	800031f8 <brelse>
    brelse(dbuf);
    800040cc:	8526                	mv	a0,s1
    800040ce:	92aff0ef          	jal	800031f8 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    800040d2:	2985                	addiw	s3,s3,1
    800040d4:	0a91                	addi	s5,s5,4
    800040d6:	028a2783          	lw	a5,40(s4)
    800040da:	04f9d663          	bge	s3,a5,80004126 <install_trans+0xae>
    if(recovering) {
    800040de:	fc0b1de3          	bnez	s6,800040b8 <install_trans+0x40>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    800040e2:	018a2583          	lw	a1,24(s4)
    800040e6:	013585bb          	addw	a1,a1,s3
    800040ea:	2585                	addiw	a1,a1,1
    800040ec:	024a2503          	lw	a0,36(s4)
    800040f0:	fd9fe0ef          	jal	800030c8 <bread>
    800040f4:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    800040f6:	000aa583          	lw	a1,0(s5)
    800040fa:	024a2503          	lw	a0,36(s4)
    800040fe:	fcbfe0ef          	jal	800030c8 <bread>
    80004102:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80004104:	40000613          	li	a2,1024
    80004108:	05890593          	addi	a1,s2,88
    8000410c:	05850513          	addi	a0,a0,88
    80004110:	cddfc0ef          	jal	80000dec <memmove>
    bwrite(dbuf);  // write dst to disk
    80004114:	8526                	mv	a0,s1
    80004116:	8b0ff0ef          	jal	800031c6 <bwrite>
    if(recovering == 0)
    8000411a:	fa0b16e3          	bnez	s6,800040c6 <install_trans+0x4e>
      bunpin(dbuf);
    8000411e:	8526                	mv	a0,s1
    80004120:	9aaff0ef          	jal	800032ca <bunpin>
    80004124:	b74d                	j	800040c6 <install_trans+0x4e>
}
    80004126:	60a6                	ld	ra,72(sp)
    80004128:	6406                	ld	s0,64(sp)
    8000412a:	74e2                	ld	s1,56(sp)
    8000412c:	7942                	ld	s2,48(sp)
    8000412e:	79a2                	ld	s3,40(sp)
    80004130:	7a02                	ld	s4,32(sp)
    80004132:	6ae2                	ld	s5,24(sp)
    80004134:	6b42                	ld	s6,16(sp)
    80004136:	6ba2                	ld	s7,8(sp)
    80004138:	6161                	addi	sp,sp,80
    8000413a:	8082                	ret
    8000413c:	8082                	ret

000000008000413e <initlog>:
{
    8000413e:	7179                	addi	sp,sp,-48
    80004140:	f406                	sd	ra,40(sp)
    80004142:	f022                	sd	s0,32(sp)
    80004144:	ec26                	sd	s1,24(sp)
    80004146:	e84a                	sd	s2,16(sp)
    80004148:	e44e                	sd	s3,8(sp)
    8000414a:	1800                	addi	s0,sp,48
    8000414c:	892a                	mv	s2,a0
    8000414e:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    80004150:	0001f497          	auipc	s1,0x1f
    80004154:	6c048493          	addi	s1,s1,1728 # 80023810 <log>
    80004158:	00004597          	auipc	a1,0x4
    8000415c:	3d858593          	addi	a1,a1,984 # 80008530 <etext+0x530>
    80004160:	8526                	mv	a0,s1
    80004162:	adbfc0ef          	jal	80000c3c <initlock>
  log.start = sb->logstart;
    80004166:	0149a583          	lw	a1,20(s3)
    8000416a:	cc8c                	sw	a1,24(s1)
  log.dev = dev;
    8000416c:	0324a223          	sw	s2,36(s1)
  struct buf *buf = bread(log.dev, log.start);
    80004170:	854a                	mv	a0,s2
    80004172:	f57fe0ef          	jal	800030c8 <bread>
  log.lh.n = lh->n;
    80004176:	4d30                	lw	a2,88(a0)
    80004178:	d490                	sw	a2,40(s1)
  for (i = 0; i < log.lh.n; i++) {
    8000417a:	00c05f63          	blez	a2,80004198 <initlog+0x5a>
    8000417e:	87aa                	mv	a5,a0
    80004180:	0001f717          	auipc	a4,0x1f
    80004184:	6bc70713          	addi	a4,a4,1724 # 8002383c <log+0x2c>
    80004188:	060a                	slli	a2,a2,0x2
    8000418a:	962a                	add	a2,a2,a0
    log.lh.block[i] = lh->block[i];
    8000418c:	4ff4                	lw	a3,92(a5)
    8000418e:	c314                	sw	a3,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80004190:	0791                	addi	a5,a5,4
    80004192:	0711                	addi	a4,a4,4
    80004194:	fec79ce3          	bne	a5,a2,8000418c <initlog+0x4e>
  brelse(buf);
    80004198:	860ff0ef          	jal	800031f8 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    8000419c:	4505                	li	a0,1
    8000419e:	edbff0ef          	jal	80004078 <install_trans>
  log.lh.n = 0;
    800041a2:	0001f797          	auipc	a5,0x1f
    800041a6:	6807ab23          	sw	zero,1686(a5) # 80023838 <log+0x28>
  write_head(); // clear the log
    800041aa:	e71ff0ef          	jal	8000401a <write_head>
}
    800041ae:	70a2                	ld	ra,40(sp)
    800041b0:	7402                	ld	s0,32(sp)
    800041b2:	64e2                	ld	s1,24(sp)
    800041b4:	6942                	ld	s2,16(sp)
    800041b6:	69a2                	ld	s3,8(sp)
    800041b8:	6145                	addi	sp,sp,48
    800041ba:	8082                	ret

00000000800041bc <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    800041bc:	1101                	addi	sp,sp,-32
    800041be:	ec06                	sd	ra,24(sp)
    800041c0:	e822                	sd	s0,16(sp)
    800041c2:	e426                	sd	s1,8(sp)
    800041c4:	e04a                	sd	s2,0(sp)
    800041c6:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    800041c8:	0001f517          	auipc	a0,0x1f
    800041cc:	64850513          	addi	a0,a0,1608 # 80023810 <log>
    800041d0:	aedfc0ef          	jal	80000cbc <acquire>
  while(1){
    if(log.committing){
    800041d4:	0001f497          	auipc	s1,0x1f
    800041d8:	63c48493          	addi	s1,s1,1596 # 80023810 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGBLOCKS){
    800041dc:	4979                	li	s2,30
    800041de:	a029                	j	800041e8 <begin_op+0x2c>
      sleep(&log, &log.lock);
    800041e0:	85a6                	mv	a1,s1
    800041e2:	8526                	mv	a0,s1
    800041e4:	a12fe0ef          	jal	800023f6 <sleep>
    if(log.committing){
    800041e8:	509c                	lw	a5,32(s1)
    800041ea:	fbfd                	bnez	a5,800041e0 <begin_op+0x24>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGBLOCKS){
    800041ec:	4cd8                	lw	a4,28(s1)
    800041ee:	2705                	addiw	a4,a4,1
    800041f0:	0027179b          	slliw	a5,a4,0x2
    800041f4:	9fb9                	addw	a5,a5,a4
    800041f6:	0017979b          	slliw	a5,a5,0x1
    800041fa:	5494                	lw	a3,40(s1)
    800041fc:	9fb5                	addw	a5,a5,a3
    800041fe:	00f95763          	bge	s2,a5,8000420c <begin_op+0x50>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    80004202:	85a6                	mv	a1,s1
    80004204:	8526                	mv	a0,s1
    80004206:	9f0fe0ef          	jal	800023f6 <sleep>
    8000420a:	bff9                	j	800041e8 <begin_op+0x2c>
    } else {
      log.outstanding += 1;
    8000420c:	0001f517          	auipc	a0,0x1f
    80004210:	60450513          	addi	a0,a0,1540 # 80023810 <log>
    80004214:	cd58                	sw	a4,28(a0)
      release(&log.lock);
    80004216:	b3ffc0ef          	jal	80000d54 <release>
      break;
    }
  }
}
    8000421a:	60e2                	ld	ra,24(sp)
    8000421c:	6442                	ld	s0,16(sp)
    8000421e:	64a2                	ld	s1,8(sp)
    80004220:	6902                	ld	s2,0(sp)
    80004222:	6105                	addi	sp,sp,32
    80004224:	8082                	ret

0000000080004226 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    80004226:	7139                	addi	sp,sp,-64
    80004228:	fc06                	sd	ra,56(sp)
    8000422a:	f822                	sd	s0,48(sp)
    8000422c:	f426                	sd	s1,40(sp)
    8000422e:	f04a                	sd	s2,32(sp)
    80004230:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    80004232:	0001f497          	auipc	s1,0x1f
    80004236:	5de48493          	addi	s1,s1,1502 # 80023810 <log>
    8000423a:	8526                	mv	a0,s1
    8000423c:	a81fc0ef          	jal	80000cbc <acquire>
  log.outstanding -= 1;
    80004240:	4cdc                	lw	a5,28(s1)
    80004242:	37fd                	addiw	a5,a5,-1
    80004244:	0007891b          	sext.w	s2,a5
    80004248:	ccdc                	sw	a5,28(s1)
  if(log.committing)
    8000424a:	509c                	lw	a5,32(s1)
    8000424c:	ef9d                	bnez	a5,8000428a <end_op+0x64>
    panic("log.committing");
  if(log.outstanding == 0){
    8000424e:	04091763          	bnez	s2,8000429c <end_op+0x76>
    do_commit = 1;
    log.committing = 1;
    80004252:	0001f497          	auipc	s1,0x1f
    80004256:	5be48493          	addi	s1,s1,1470 # 80023810 <log>
    8000425a:	4785                	li	a5,1
    8000425c:	d09c                	sw	a5,32(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    8000425e:	8526                	mv	a0,s1
    80004260:	af5fc0ef          	jal	80000d54 <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    80004264:	549c                	lw	a5,40(s1)
    80004266:	04f04b63          	bgtz	a5,800042bc <end_op+0x96>
    acquire(&log.lock);
    8000426a:	0001f497          	auipc	s1,0x1f
    8000426e:	5a648493          	addi	s1,s1,1446 # 80023810 <log>
    80004272:	8526                	mv	a0,s1
    80004274:	a49fc0ef          	jal	80000cbc <acquire>
    log.committing = 0;
    80004278:	0204a023          	sw	zero,32(s1)
    wakeup(&log);
    8000427c:	8526                	mv	a0,s1
    8000427e:	9c4fe0ef          	jal	80002442 <wakeup>
    release(&log.lock);
    80004282:	8526                	mv	a0,s1
    80004284:	ad1fc0ef          	jal	80000d54 <release>
}
    80004288:	a025                	j	800042b0 <end_op+0x8a>
    8000428a:	ec4e                	sd	s3,24(sp)
    8000428c:	e852                	sd	s4,16(sp)
    8000428e:	e456                	sd	s5,8(sp)
    panic("log.committing");
    80004290:	00004517          	auipc	a0,0x4
    80004294:	2a850513          	addi	a0,a0,680 # 80008538 <etext+0x538>
    80004298:	d7afc0ef          	jal	80000812 <panic>
    wakeup(&log);
    8000429c:	0001f497          	auipc	s1,0x1f
    800042a0:	57448493          	addi	s1,s1,1396 # 80023810 <log>
    800042a4:	8526                	mv	a0,s1
    800042a6:	99cfe0ef          	jal	80002442 <wakeup>
  release(&log.lock);
    800042aa:	8526                	mv	a0,s1
    800042ac:	aa9fc0ef          	jal	80000d54 <release>
}
    800042b0:	70e2                	ld	ra,56(sp)
    800042b2:	7442                	ld	s0,48(sp)
    800042b4:	74a2                	ld	s1,40(sp)
    800042b6:	7902                	ld	s2,32(sp)
    800042b8:	6121                	addi	sp,sp,64
    800042ba:	8082                	ret
    800042bc:	ec4e                	sd	s3,24(sp)
    800042be:	e852                	sd	s4,16(sp)
    800042c0:	e456                	sd	s5,8(sp)
  for (tail = 0; tail < log.lh.n; tail++) {
    800042c2:	0001fa97          	auipc	s5,0x1f
    800042c6:	57aa8a93          	addi	s5,s5,1402 # 8002383c <log+0x2c>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    800042ca:	0001fa17          	auipc	s4,0x1f
    800042ce:	546a0a13          	addi	s4,s4,1350 # 80023810 <log>
    800042d2:	018a2583          	lw	a1,24(s4)
    800042d6:	012585bb          	addw	a1,a1,s2
    800042da:	2585                	addiw	a1,a1,1
    800042dc:	024a2503          	lw	a0,36(s4)
    800042e0:	de9fe0ef          	jal	800030c8 <bread>
    800042e4:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    800042e6:	000aa583          	lw	a1,0(s5)
    800042ea:	024a2503          	lw	a0,36(s4)
    800042ee:	ddbfe0ef          	jal	800030c8 <bread>
    800042f2:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    800042f4:	40000613          	li	a2,1024
    800042f8:	05850593          	addi	a1,a0,88
    800042fc:	05848513          	addi	a0,s1,88
    80004300:	aedfc0ef          	jal	80000dec <memmove>
    bwrite(to);  // write the log
    80004304:	8526                	mv	a0,s1
    80004306:	ec1fe0ef          	jal	800031c6 <bwrite>
    brelse(from);
    8000430a:	854e                	mv	a0,s3
    8000430c:	eedfe0ef          	jal	800031f8 <brelse>
    brelse(to);
    80004310:	8526                	mv	a0,s1
    80004312:	ee7fe0ef          	jal	800031f8 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004316:	2905                	addiw	s2,s2,1
    80004318:	0a91                	addi	s5,s5,4
    8000431a:	028a2783          	lw	a5,40(s4)
    8000431e:	faf94ae3          	blt	s2,a5,800042d2 <end_op+0xac>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    80004322:	cf9ff0ef          	jal	8000401a <write_head>
    install_trans(0); // Now install writes to home locations
    80004326:	4501                	li	a0,0
    80004328:	d51ff0ef          	jal	80004078 <install_trans>
    log.lh.n = 0;
    8000432c:	0001f797          	auipc	a5,0x1f
    80004330:	5007a623          	sw	zero,1292(a5) # 80023838 <log+0x28>
    write_head();    // Erase the transaction from the log
    80004334:	ce7ff0ef          	jal	8000401a <write_head>
    80004338:	69e2                	ld	s3,24(sp)
    8000433a:	6a42                	ld	s4,16(sp)
    8000433c:	6aa2                	ld	s5,8(sp)
    8000433e:	b735                	j	8000426a <end_op+0x44>

0000000080004340 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    80004340:	1101                	addi	sp,sp,-32
    80004342:	ec06                	sd	ra,24(sp)
    80004344:	e822                	sd	s0,16(sp)
    80004346:	e426                	sd	s1,8(sp)
    80004348:	e04a                	sd	s2,0(sp)
    8000434a:	1000                	addi	s0,sp,32
    8000434c:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    8000434e:	0001f917          	auipc	s2,0x1f
    80004352:	4c290913          	addi	s2,s2,1218 # 80023810 <log>
    80004356:	854a                	mv	a0,s2
    80004358:	965fc0ef          	jal	80000cbc <acquire>
  if (log.lh.n >= LOGBLOCKS)
    8000435c:	02892603          	lw	a2,40(s2)
    80004360:	47f5                	li	a5,29
    80004362:	04c7cc63          	blt	a5,a2,800043ba <log_write+0x7a>
    panic("too big a transaction");
  if (log.outstanding < 1)
    80004366:	0001f797          	auipc	a5,0x1f
    8000436a:	4c67a783          	lw	a5,1222(a5) # 8002382c <log+0x1c>
    8000436e:	04f05c63          	blez	a5,800043c6 <log_write+0x86>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    80004372:	4781                	li	a5,0
    80004374:	04c05f63          	blez	a2,800043d2 <log_write+0x92>
    if (log.lh.block[i] == b->blockno)   // log absorption
    80004378:	44cc                	lw	a1,12(s1)
    8000437a:	0001f717          	auipc	a4,0x1f
    8000437e:	4c270713          	addi	a4,a4,1218 # 8002383c <log+0x2c>
  for (i = 0; i < log.lh.n; i++) {
    80004382:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    80004384:	4314                	lw	a3,0(a4)
    80004386:	04b68663          	beq	a3,a1,800043d2 <log_write+0x92>
  for (i = 0; i < log.lh.n; i++) {
    8000438a:	2785                	addiw	a5,a5,1
    8000438c:	0711                	addi	a4,a4,4
    8000438e:	fef61be3          	bne	a2,a5,80004384 <log_write+0x44>
      break;
  }
  log.lh.block[i] = b->blockno;
    80004392:	0621                	addi	a2,a2,8
    80004394:	060a                	slli	a2,a2,0x2
    80004396:	0001f797          	auipc	a5,0x1f
    8000439a:	47a78793          	addi	a5,a5,1146 # 80023810 <log>
    8000439e:	97b2                	add	a5,a5,a2
    800043a0:	44d8                	lw	a4,12(s1)
    800043a2:	c7d8                	sw	a4,12(a5)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    800043a4:	8526                	mv	a0,s1
    800043a6:	ef1fe0ef          	jal	80003296 <bpin>
    log.lh.n++;
    800043aa:	0001f717          	auipc	a4,0x1f
    800043ae:	46670713          	addi	a4,a4,1126 # 80023810 <log>
    800043b2:	571c                	lw	a5,40(a4)
    800043b4:	2785                	addiw	a5,a5,1
    800043b6:	d71c                	sw	a5,40(a4)
    800043b8:	a80d                	j	800043ea <log_write+0xaa>
    panic("too big a transaction");
    800043ba:	00004517          	auipc	a0,0x4
    800043be:	18e50513          	addi	a0,a0,398 # 80008548 <etext+0x548>
    800043c2:	c50fc0ef          	jal	80000812 <panic>
    panic("log_write outside of trans");
    800043c6:	00004517          	auipc	a0,0x4
    800043ca:	19a50513          	addi	a0,a0,410 # 80008560 <etext+0x560>
    800043ce:	c44fc0ef          	jal	80000812 <panic>
  log.lh.block[i] = b->blockno;
    800043d2:	00878693          	addi	a3,a5,8
    800043d6:	068a                	slli	a3,a3,0x2
    800043d8:	0001f717          	auipc	a4,0x1f
    800043dc:	43870713          	addi	a4,a4,1080 # 80023810 <log>
    800043e0:	9736                	add	a4,a4,a3
    800043e2:	44d4                	lw	a3,12(s1)
    800043e4:	c754                	sw	a3,12(a4)
  if (i == log.lh.n) {  // Add new block to log?
    800043e6:	faf60fe3          	beq	a2,a5,800043a4 <log_write+0x64>
  }
  release(&log.lock);
    800043ea:	0001f517          	auipc	a0,0x1f
    800043ee:	42650513          	addi	a0,a0,1062 # 80023810 <log>
    800043f2:	963fc0ef          	jal	80000d54 <release>
}
    800043f6:	60e2                	ld	ra,24(sp)
    800043f8:	6442                	ld	s0,16(sp)
    800043fa:	64a2                	ld	s1,8(sp)
    800043fc:	6902                	ld	s2,0(sp)
    800043fe:	6105                	addi	sp,sp,32
    80004400:	8082                	ret

0000000080004402 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    80004402:	1101                	addi	sp,sp,-32
    80004404:	ec06                	sd	ra,24(sp)
    80004406:	e822                	sd	s0,16(sp)
    80004408:	e426                	sd	s1,8(sp)
    8000440a:	e04a                	sd	s2,0(sp)
    8000440c:	1000                	addi	s0,sp,32
    8000440e:	84aa                	mv	s1,a0
    80004410:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    80004412:	00004597          	auipc	a1,0x4
    80004416:	16e58593          	addi	a1,a1,366 # 80008580 <etext+0x580>
    8000441a:	0521                	addi	a0,a0,8
    8000441c:	821fc0ef          	jal	80000c3c <initlock>
  lk->name = name;
    80004420:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    80004424:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004428:	0204a423          	sw	zero,40(s1)
}
    8000442c:	60e2                	ld	ra,24(sp)
    8000442e:	6442                	ld	s0,16(sp)
    80004430:	64a2                	ld	s1,8(sp)
    80004432:	6902                	ld	s2,0(sp)
    80004434:	6105                	addi	sp,sp,32
    80004436:	8082                	ret

0000000080004438 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    80004438:	1101                	addi	sp,sp,-32
    8000443a:	ec06                	sd	ra,24(sp)
    8000443c:	e822                	sd	s0,16(sp)
    8000443e:	e426                	sd	s1,8(sp)
    80004440:	e04a                	sd	s2,0(sp)
    80004442:	1000                	addi	s0,sp,32
    80004444:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004446:	00850913          	addi	s2,a0,8
    8000444a:	854a                	mv	a0,s2
    8000444c:	871fc0ef          	jal	80000cbc <acquire>
  while (lk->locked) {
    80004450:	409c                	lw	a5,0(s1)
    80004452:	c799                	beqz	a5,80004460 <acquiresleep+0x28>
    sleep(lk, &lk->lk);
    80004454:	85ca                	mv	a1,s2
    80004456:	8526                	mv	a0,s1
    80004458:	f9ffd0ef          	jal	800023f6 <sleep>
  while (lk->locked) {
    8000445c:	409c                	lw	a5,0(s1)
    8000445e:	fbfd                	bnez	a5,80004454 <acquiresleep+0x1c>
  }
  lk->locked = 1;
    80004460:	4785                	li	a5,1
    80004462:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    80004464:	f6efd0ef          	jal	80001bd2 <myproc>
    80004468:	591c                	lw	a5,48(a0)
    8000446a:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    8000446c:	854a                	mv	a0,s2
    8000446e:	8e7fc0ef          	jal	80000d54 <release>
}
    80004472:	60e2                	ld	ra,24(sp)
    80004474:	6442                	ld	s0,16(sp)
    80004476:	64a2                	ld	s1,8(sp)
    80004478:	6902                	ld	s2,0(sp)
    8000447a:	6105                	addi	sp,sp,32
    8000447c:	8082                	ret

000000008000447e <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    8000447e:	1101                	addi	sp,sp,-32
    80004480:	ec06                	sd	ra,24(sp)
    80004482:	e822                	sd	s0,16(sp)
    80004484:	e426                	sd	s1,8(sp)
    80004486:	e04a                	sd	s2,0(sp)
    80004488:	1000                	addi	s0,sp,32
    8000448a:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    8000448c:	00850913          	addi	s2,a0,8
    80004490:	854a                	mv	a0,s2
    80004492:	82bfc0ef          	jal	80000cbc <acquire>
  lk->locked = 0;
    80004496:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    8000449a:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    8000449e:	8526                	mv	a0,s1
    800044a0:	fa3fd0ef          	jal	80002442 <wakeup>
  release(&lk->lk);
    800044a4:	854a                	mv	a0,s2
    800044a6:	8affc0ef          	jal	80000d54 <release>
}
    800044aa:	60e2                	ld	ra,24(sp)
    800044ac:	6442                	ld	s0,16(sp)
    800044ae:	64a2                	ld	s1,8(sp)
    800044b0:	6902                	ld	s2,0(sp)
    800044b2:	6105                	addi	sp,sp,32
    800044b4:	8082                	ret

00000000800044b6 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    800044b6:	7179                	addi	sp,sp,-48
    800044b8:	f406                	sd	ra,40(sp)
    800044ba:	f022                	sd	s0,32(sp)
    800044bc:	ec26                	sd	s1,24(sp)
    800044be:	e84a                	sd	s2,16(sp)
    800044c0:	1800                	addi	s0,sp,48
    800044c2:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    800044c4:	00850913          	addi	s2,a0,8
    800044c8:	854a                	mv	a0,s2
    800044ca:	ff2fc0ef          	jal	80000cbc <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    800044ce:	409c                	lw	a5,0(s1)
    800044d0:	ef81                	bnez	a5,800044e8 <holdingsleep+0x32>
    800044d2:	4481                	li	s1,0
  release(&lk->lk);
    800044d4:	854a                	mv	a0,s2
    800044d6:	87ffc0ef          	jal	80000d54 <release>
  return r;
}
    800044da:	8526                	mv	a0,s1
    800044dc:	70a2                	ld	ra,40(sp)
    800044de:	7402                	ld	s0,32(sp)
    800044e0:	64e2                	ld	s1,24(sp)
    800044e2:	6942                	ld	s2,16(sp)
    800044e4:	6145                	addi	sp,sp,48
    800044e6:	8082                	ret
    800044e8:	e44e                	sd	s3,8(sp)
  r = lk->locked && (lk->pid == myproc()->pid);
    800044ea:	0284a983          	lw	s3,40(s1)
    800044ee:	ee4fd0ef          	jal	80001bd2 <myproc>
    800044f2:	5904                	lw	s1,48(a0)
    800044f4:	413484b3          	sub	s1,s1,s3
    800044f8:	0014b493          	seqz	s1,s1
    800044fc:	69a2                	ld	s3,8(sp)
    800044fe:	bfd9                	j	800044d4 <holdingsleep+0x1e>

0000000080004500 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    80004500:	1141                	addi	sp,sp,-16
    80004502:	e406                	sd	ra,8(sp)
    80004504:	e022                	sd	s0,0(sp)
    80004506:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    80004508:	00004597          	auipc	a1,0x4
    8000450c:	08858593          	addi	a1,a1,136 # 80008590 <etext+0x590>
    80004510:	0001f517          	auipc	a0,0x1f
    80004514:	44850513          	addi	a0,a0,1096 # 80023958 <ftable>
    80004518:	f24fc0ef          	jal	80000c3c <initlock>
}
    8000451c:	60a2                	ld	ra,8(sp)
    8000451e:	6402                	ld	s0,0(sp)
    80004520:	0141                	addi	sp,sp,16
    80004522:	8082                	ret

0000000080004524 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    80004524:	1101                	addi	sp,sp,-32
    80004526:	ec06                	sd	ra,24(sp)
    80004528:	e822                	sd	s0,16(sp)
    8000452a:	e426                	sd	s1,8(sp)
    8000452c:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    8000452e:	0001f517          	auipc	a0,0x1f
    80004532:	42a50513          	addi	a0,a0,1066 # 80023958 <ftable>
    80004536:	f86fc0ef          	jal	80000cbc <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    8000453a:	0001f497          	auipc	s1,0x1f
    8000453e:	43648493          	addi	s1,s1,1078 # 80023970 <ftable+0x18>
    80004542:	00020717          	auipc	a4,0x20
    80004546:	3ce70713          	addi	a4,a4,974 # 80024910 <disk>
    if(f->ref == 0){
    8000454a:	40dc                	lw	a5,4(s1)
    8000454c:	cf89                	beqz	a5,80004566 <filealloc+0x42>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    8000454e:	02848493          	addi	s1,s1,40
    80004552:	fee49ce3          	bne	s1,a4,8000454a <filealloc+0x26>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    80004556:	0001f517          	auipc	a0,0x1f
    8000455a:	40250513          	addi	a0,a0,1026 # 80023958 <ftable>
    8000455e:	ff6fc0ef          	jal	80000d54 <release>
  return 0;
    80004562:	4481                	li	s1,0
    80004564:	a809                	j	80004576 <filealloc+0x52>
      f->ref = 1;
    80004566:	4785                	li	a5,1
    80004568:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    8000456a:	0001f517          	auipc	a0,0x1f
    8000456e:	3ee50513          	addi	a0,a0,1006 # 80023958 <ftable>
    80004572:	fe2fc0ef          	jal	80000d54 <release>
}
    80004576:	8526                	mv	a0,s1
    80004578:	60e2                	ld	ra,24(sp)
    8000457a:	6442                	ld	s0,16(sp)
    8000457c:	64a2                	ld	s1,8(sp)
    8000457e:	6105                	addi	sp,sp,32
    80004580:	8082                	ret

0000000080004582 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    80004582:	1101                	addi	sp,sp,-32
    80004584:	ec06                	sd	ra,24(sp)
    80004586:	e822                	sd	s0,16(sp)
    80004588:	e426                	sd	s1,8(sp)
    8000458a:	1000                	addi	s0,sp,32
    8000458c:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    8000458e:	0001f517          	auipc	a0,0x1f
    80004592:	3ca50513          	addi	a0,a0,970 # 80023958 <ftable>
    80004596:	f26fc0ef          	jal	80000cbc <acquire>
  if(f->ref < 1)
    8000459a:	40dc                	lw	a5,4(s1)
    8000459c:	02f05063          	blez	a5,800045bc <filedup+0x3a>
    panic("filedup");
  f->ref++;
    800045a0:	2785                	addiw	a5,a5,1
    800045a2:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    800045a4:	0001f517          	auipc	a0,0x1f
    800045a8:	3b450513          	addi	a0,a0,948 # 80023958 <ftable>
    800045ac:	fa8fc0ef          	jal	80000d54 <release>
  return f;
}
    800045b0:	8526                	mv	a0,s1
    800045b2:	60e2                	ld	ra,24(sp)
    800045b4:	6442                	ld	s0,16(sp)
    800045b6:	64a2                	ld	s1,8(sp)
    800045b8:	6105                	addi	sp,sp,32
    800045ba:	8082                	ret
    panic("filedup");
    800045bc:	00004517          	auipc	a0,0x4
    800045c0:	fdc50513          	addi	a0,a0,-36 # 80008598 <etext+0x598>
    800045c4:	a4efc0ef          	jal	80000812 <panic>

00000000800045c8 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    800045c8:	7139                	addi	sp,sp,-64
    800045ca:	fc06                	sd	ra,56(sp)
    800045cc:	f822                	sd	s0,48(sp)
    800045ce:	f426                	sd	s1,40(sp)
    800045d0:	0080                	addi	s0,sp,64
    800045d2:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    800045d4:	0001f517          	auipc	a0,0x1f
    800045d8:	38450513          	addi	a0,a0,900 # 80023958 <ftable>
    800045dc:	ee0fc0ef          	jal	80000cbc <acquire>
  if(f->ref < 1)
    800045e0:	40dc                	lw	a5,4(s1)
    800045e2:	04f05a63          	blez	a5,80004636 <fileclose+0x6e>
    panic("fileclose");
  if(--f->ref > 0){
    800045e6:	37fd                	addiw	a5,a5,-1
    800045e8:	0007871b          	sext.w	a4,a5
    800045ec:	c0dc                	sw	a5,4(s1)
    800045ee:	04e04e63          	bgtz	a4,8000464a <fileclose+0x82>
    800045f2:	f04a                	sd	s2,32(sp)
    800045f4:	ec4e                	sd	s3,24(sp)
    800045f6:	e852                	sd	s4,16(sp)
    800045f8:	e456                	sd	s5,8(sp)
    release(&ftable.lock);
    return;
  }
  ff = *f;
    800045fa:	0004a903          	lw	s2,0(s1)
    800045fe:	0094ca83          	lbu	s5,9(s1)
    80004602:	0104ba03          	ld	s4,16(s1)
    80004606:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    8000460a:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    8000460e:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    80004612:	0001f517          	auipc	a0,0x1f
    80004616:	34650513          	addi	a0,a0,838 # 80023958 <ftable>
    8000461a:	f3afc0ef          	jal	80000d54 <release>

  if(ff.type == FD_PIPE){
    8000461e:	4785                	li	a5,1
    80004620:	04f90063          	beq	s2,a5,80004660 <fileclose+0x98>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    80004624:	3979                	addiw	s2,s2,-2
    80004626:	4785                	li	a5,1
    80004628:	0527f563          	bgeu	a5,s2,80004672 <fileclose+0xaa>
    8000462c:	7902                	ld	s2,32(sp)
    8000462e:	69e2                	ld	s3,24(sp)
    80004630:	6a42                	ld	s4,16(sp)
    80004632:	6aa2                	ld	s5,8(sp)
    80004634:	a00d                	j	80004656 <fileclose+0x8e>
    80004636:	f04a                	sd	s2,32(sp)
    80004638:	ec4e                	sd	s3,24(sp)
    8000463a:	e852                	sd	s4,16(sp)
    8000463c:	e456                	sd	s5,8(sp)
    panic("fileclose");
    8000463e:	00004517          	auipc	a0,0x4
    80004642:	f6250513          	addi	a0,a0,-158 # 800085a0 <etext+0x5a0>
    80004646:	9ccfc0ef          	jal	80000812 <panic>
    release(&ftable.lock);
    8000464a:	0001f517          	auipc	a0,0x1f
    8000464e:	30e50513          	addi	a0,a0,782 # 80023958 <ftable>
    80004652:	f02fc0ef          	jal	80000d54 <release>
    begin_op();
    iput(ff.ip);
    end_op();
  }
}
    80004656:	70e2                	ld	ra,56(sp)
    80004658:	7442                	ld	s0,48(sp)
    8000465a:	74a2                	ld	s1,40(sp)
    8000465c:	6121                	addi	sp,sp,64
    8000465e:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80004660:	85d6                	mv	a1,s5
    80004662:	8552                	mv	a0,s4
    80004664:	336000ef          	jal	8000499a <pipeclose>
    80004668:	7902                	ld	s2,32(sp)
    8000466a:	69e2                	ld	s3,24(sp)
    8000466c:	6a42                	ld	s4,16(sp)
    8000466e:	6aa2                	ld	s5,8(sp)
    80004670:	b7dd                	j	80004656 <fileclose+0x8e>
    begin_op();
    80004672:	b4bff0ef          	jal	800041bc <begin_op>
    iput(ff.ip);
    80004676:	854e                	mv	a0,s3
    80004678:	adcff0ef          	jal	80003954 <iput>
    end_op();
    8000467c:	babff0ef          	jal	80004226 <end_op>
    80004680:	7902                	ld	s2,32(sp)
    80004682:	69e2                	ld	s3,24(sp)
    80004684:	6a42                	ld	s4,16(sp)
    80004686:	6aa2                	ld	s5,8(sp)
    80004688:	b7f9                	j	80004656 <fileclose+0x8e>

000000008000468a <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    8000468a:	715d                	addi	sp,sp,-80
    8000468c:	e486                	sd	ra,72(sp)
    8000468e:	e0a2                	sd	s0,64(sp)
    80004690:	fc26                	sd	s1,56(sp)
    80004692:	f44e                	sd	s3,40(sp)
    80004694:	0880                	addi	s0,sp,80
    80004696:	84aa                	mv	s1,a0
    80004698:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    8000469a:	d38fd0ef          	jal	80001bd2 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    8000469e:	409c                	lw	a5,0(s1)
    800046a0:	37f9                	addiw	a5,a5,-2
    800046a2:	4705                	li	a4,1
    800046a4:	04f76063          	bltu	a4,a5,800046e4 <filestat+0x5a>
    800046a8:	f84a                	sd	s2,48(sp)
    800046aa:	892a                	mv	s2,a0
    ilock(f->ip);
    800046ac:	6c88                	ld	a0,24(s1)
    800046ae:	924ff0ef          	jal	800037d2 <ilock>
    stati(f->ip, &st);
    800046b2:	fb840593          	addi	a1,s0,-72
    800046b6:	6c88                	ld	a0,24(s1)
    800046b8:	c80ff0ef          	jal	80003b38 <stati>
    iunlock(f->ip);
    800046bc:	6c88                	ld	a0,24(s1)
    800046be:	9c2ff0ef          	jal	80003880 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    800046c2:	46e1                	li	a3,24
    800046c4:	fb840613          	addi	a2,s0,-72
    800046c8:	85ce                	mv	a1,s3
    800046ca:	05093503          	ld	a0,80(s2)
    800046ce:	a04fd0ef          	jal	800018d2 <copyout>
    800046d2:	41f5551b          	sraiw	a0,a0,0x1f
    800046d6:	7942                	ld	s2,48(sp)
      return -1;
    return 0;
  }
  return -1;
}
    800046d8:	60a6                	ld	ra,72(sp)
    800046da:	6406                	ld	s0,64(sp)
    800046dc:	74e2                	ld	s1,56(sp)
    800046de:	79a2                	ld	s3,40(sp)
    800046e0:	6161                	addi	sp,sp,80
    800046e2:	8082                	ret
  return -1;
    800046e4:	557d                	li	a0,-1
    800046e6:	bfcd                	j	800046d8 <filestat+0x4e>

00000000800046e8 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    800046e8:	7179                	addi	sp,sp,-48
    800046ea:	f406                	sd	ra,40(sp)
    800046ec:	f022                	sd	s0,32(sp)
    800046ee:	e84a                	sd	s2,16(sp)
    800046f0:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    800046f2:	00854783          	lbu	a5,8(a0)
    800046f6:	cfd1                	beqz	a5,80004792 <fileread+0xaa>
    800046f8:	ec26                	sd	s1,24(sp)
    800046fa:	e44e                	sd	s3,8(sp)
    800046fc:	84aa                	mv	s1,a0
    800046fe:	89ae                	mv	s3,a1
    80004700:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    80004702:	411c                	lw	a5,0(a0)
    80004704:	4705                	li	a4,1
    80004706:	04e78363          	beq	a5,a4,8000474c <fileread+0x64>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    8000470a:	470d                	li	a4,3
    8000470c:	04e78763          	beq	a5,a4,8000475a <fileread+0x72>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    80004710:	4709                	li	a4,2
    80004712:	06e79a63          	bne	a5,a4,80004786 <fileread+0x9e>
    ilock(f->ip);
    80004716:	6d08                	ld	a0,24(a0)
    80004718:	8baff0ef          	jal	800037d2 <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    8000471c:	874a                	mv	a4,s2
    8000471e:	5094                	lw	a3,32(s1)
    80004720:	864e                	mv	a2,s3
    80004722:	4585                	li	a1,1
    80004724:	6c88                	ld	a0,24(s1)
    80004726:	c3cff0ef          	jal	80003b62 <readi>
    8000472a:	892a                	mv	s2,a0
    8000472c:	00a05563          	blez	a0,80004736 <fileread+0x4e>
      f->off += r;
    80004730:	509c                	lw	a5,32(s1)
    80004732:	9fa9                	addw	a5,a5,a0
    80004734:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80004736:	6c88                	ld	a0,24(s1)
    80004738:	948ff0ef          	jal	80003880 <iunlock>
    8000473c:	64e2                	ld	s1,24(sp)
    8000473e:	69a2                	ld	s3,8(sp)
  } else {
    panic("fileread");
  }

  return r;
}
    80004740:	854a                	mv	a0,s2
    80004742:	70a2                	ld	ra,40(sp)
    80004744:	7402                	ld	s0,32(sp)
    80004746:	6942                	ld	s2,16(sp)
    80004748:	6145                	addi	sp,sp,48
    8000474a:	8082                	ret
    r = piperead(f->pipe, addr, n);
    8000474c:	6908                	ld	a0,16(a0)
    8000474e:	388000ef          	jal	80004ad6 <piperead>
    80004752:	892a                	mv	s2,a0
    80004754:	64e2                	ld	s1,24(sp)
    80004756:	69a2                	ld	s3,8(sp)
    80004758:	b7e5                	j	80004740 <fileread+0x58>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    8000475a:	02451783          	lh	a5,36(a0)
    8000475e:	03079693          	slli	a3,a5,0x30
    80004762:	92c1                	srli	a3,a3,0x30
    80004764:	4725                	li	a4,9
    80004766:	02d76863          	bltu	a4,a3,80004796 <fileread+0xae>
    8000476a:	0792                	slli	a5,a5,0x4
    8000476c:	0001f717          	auipc	a4,0x1f
    80004770:	14c70713          	addi	a4,a4,332 # 800238b8 <devsw>
    80004774:	97ba                	add	a5,a5,a4
    80004776:	639c                	ld	a5,0(a5)
    80004778:	c39d                	beqz	a5,8000479e <fileread+0xb6>
    r = devsw[f->major].read(1, addr, n);
    8000477a:	4505                	li	a0,1
    8000477c:	9782                	jalr	a5
    8000477e:	892a                	mv	s2,a0
    80004780:	64e2                	ld	s1,24(sp)
    80004782:	69a2                	ld	s3,8(sp)
    80004784:	bf75                	j	80004740 <fileread+0x58>
    panic("fileread");
    80004786:	00004517          	auipc	a0,0x4
    8000478a:	e2a50513          	addi	a0,a0,-470 # 800085b0 <etext+0x5b0>
    8000478e:	884fc0ef          	jal	80000812 <panic>
    return -1;
    80004792:	597d                	li	s2,-1
    80004794:	b775                	j	80004740 <fileread+0x58>
      return -1;
    80004796:	597d                	li	s2,-1
    80004798:	64e2                	ld	s1,24(sp)
    8000479a:	69a2                	ld	s3,8(sp)
    8000479c:	b755                	j	80004740 <fileread+0x58>
    8000479e:	597d                	li	s2,-1
    800047a0:	64e2                	ld	s1,24(sp)
    800047a2:	69a2                	ld	s3,8(sp)
    800047a4:	bf71                	j	80004740 <fileread+0x58>

00000000800047a6 <filewrite>:
int
filewrite(struct file *f, uint64 addr, int n)
{
  int r, ret = 0;

  if(f->writable == 0)
    800047a6:	00954783          	lbu	a5,9(a0)
    800047aa:	10078b63          	beqz	a5,800048c0 <filewrite+0x11a>
{
    800047ae:	715d                	addi	sp,sp,-80
    800047b0:	e486                	sd	ra,72(sp)
    800047b2:	e0a2                	sd	s0,64(sp)
    800047b4:	f84a                	sd	s2,48(sp)
    800047b6:	f052                	sd	s4,32(sp)
    800047b8:	e85a                	sd	s6,16(sp)
    800047ba:	0880                	addi	s0,sp,80
    800047bc:	892a                	mv	s2,a0
    800047be:	8b2e                	mv	s6,a1
    800047c0:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    800047c2:	411c                	lw	a5,0(a0)
    800047c4:	4705                	li	a4,1
    800047c6:	02e78763          	beq	a5,a4,800047f4 <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    800047ca:	470d                	li	a4,3
    800047cc:	02e78863          	beq	a5,a4,800047fc <filewrite+0x56>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    800047d0:	4709                	li	a4,2
    800047d2:	0ce79c63          	bne	a5,a4,800048aa <filewrite+0x104>
    800047d6:	f44e                	sd	s3,40(sp)
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    800047d8:	0ac05863          	blez	a2,80004888 <filewrite+0xe2>
    800047dc:	fc26                	sd	s1,56(sp)
    800047de:	ec56                	sd	s5,24(sp)
    800047e0:	e45e                	sd	s7,8(sp)
    800047e2:	e062                	sd	s8,0(sp)
    int i = 0;
    800047e4:	4981                	li	s3,0
      int n1 = n - i;
      if(n1 > max)
    800047e6:	6b85                	lui	s7,0x1
    800047e8:	c00b8b93          	addi	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    800047ec:	6c05                	lui	s8,0x1
    800047ee:	c00c0c1b          	addiw	s8,s8,-1024 # c00 <_entry-0x7ffff400>
    800047f2:	a8b5                	j	8000486e <filewrite+0xc8>
    ret = pipewrite(f->pipe, addr, n);
    800047f4:	6908                	ld	a0,16(a0)
    800047f6:	1fc000ef          	jal	800049f2 <pipewrite>
    800047fa:	a04d                	j	8000489c <filewrite+0xf6>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    800047fc:	02451783          	lh	a5,36(a0)
    80004800:	03079693          	slli	a3,a5,0x30
    80004804:	92c1                	srli	a3,a3,0x30
    80004806:	4725                	li	a4,9
    80004808:	0ad76e63          	bltu	a4,a3,800048c4 <filewrite+0x11e>
    8000480c:	0792                	slli	a5,a5,0x4
    8000480e:	0001f717          	auipc	a4,0x1f
    80004812:	0aa70713          	addi	a4,a4,170 # 800238b8 <devsw>
    80004816:	97ba                	add	a5,a5,a4
    80004818:	679c                	ld	a5,8(a5)
    8000481a:	c7dd                	beqz	a5,800048c8 <filewrite+0x122>
    ret = devsw[f->major].write(1, addr, n);
    8000481c:	4505                	li	a0,1
    8000481e:	9782                	jalr	a5
    80004820:	a8b5                	j	8000489c <filewrite+0xf6>
      if(n1 > max)
    80004822:	00048a9b          	sext.w	s5,s1
        n1 = max;

      begin_op();
    80004826:	997ff0ef          	jal	800041bc <begin_op>
      ilock(f->ip);
    8000482a:	01893503          	ld	a0,24(s2)
    8000482e:	fa5fe0ef          	jal	800037d2 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80004832:	8756                	mv	a4,s5
    80004834:	02092683          	lw	a3,32(s2)
    80004838:	01698633          	add	a2,s3,s6
    8000483c:	4585                	li	a1,1
    8000483e:	01893503          	ld	a0,24(s2)
    80004842:	c1cff0ef          	jal	80003c5e <writei>
    80004846:	84aa                	mv	s1,a0
    80004848:	00a05763          	blez	a0,80004856 <filewrite+0xb0>
        f->off += r;
    8000484c:	02092783          	lw	a5,32(s2)
    80004850:	9fa9                	addw	a5,a5,a0
    80004852:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80004856:	01893503          	ld	a0,24(s2)
    8000485a:	826ff0ef          	jal	80003880 <iunlock>
      end_op();
    8000485e:	9c9ff0ef          	jal	80004226 <end_op>

      if(r != n1){
    80004862:	029a9563          	bne	s5,s1,8000488c <filewrite+0xe6>
        // error from writei
        break;
      }
      i += r;
    80004866:	013489bb          	addw	s3,s1,s3
    while(i < n){
    8000486a:	0149da63          	bge	s3,s4,8000487e <filewrite+0xd8>
      int n1 = n - i;
    8000486e:	413a04bb          	subw	s1,s4,s3
      if(n1 > max)
    80004872:	0004879b          	sext.w	a5,s1
    80004876:	fafbd6e3          	bge	s7,a5,80004822 <filewrite+0x7c>
    8000487a:	84e2                	mv	s1,s8
    8000487c:	b75d                	j	80004822 <filewrite+0x7c>
    8000487e:	74e2                	ld	s1,56(sp)
    80004880:	6ae2                	ld	s5,24(sp)
    80004882:	6ba2                	ld	s7,8(sp)
    80004884:	6c02                	ld	s8,0(sp)
    80004886:	a039                	j	80004894 <filewrite+0xee>
    int i = 0;
    80004888:	4981                	li	s3,0
    8000488a:	a029                	j	80004894 <filewrite+0xee>
    8000488c:	74e2                	ld	s1,56(sp)
    8000488e:	6ae2                	ld	s5,24(sp)
    80004890:	6ba2                	ld	s7,8(sp)
    80004892:	6c02                	ld	s8,0(sp)
    }
    ret = (i == n ? n : -1);
    80004894:	033a1c63          	bne	s4,s3,800048cc <filewrite+0x126>
    80004898:	8552                	mv	a0,s4
    8000489a:	79a2                	ld	s3,40(sp)
  } else {
    panic("filewrite");
  }

  return ret;
}
    8000489c:	60a6                	ld	ra,72(sp)
    8000489e:	6406                	ld	s0,64(sp)
    800048a0:	7942                	ld	s2,48(sp)
    800048a2:	7a02                	ld	s4,32(sp)
    800048a4:	6b42                	ld	s6,16(sp)
    800048a6:	6161                	addi	sp,sp,80
    800048a8:	8082                	ret
    800048aa:	fc26                	sd	s1,56(sp)
    800048ac:	f44e                	sd	s3,40(sp)
    800048ae:	ec56                	sd	s5,24(sp)
    800048b0:	e45e                	sd	s7,8(sp)
    800048b2:	e062                	sd	s8,0(sp)
    panic("filewrite");
    800048b4:	00004517          	auipc	a0,0x4
    800048b8:	d0c50513          	addi	a0,a0,-756 # 800085c0 <etext+0x5c0>
    800048bc:	f57fb0ef          	jal	80000812 <panic>
    return -1;
    800048c0:	557d                	li	a0,-1
}
    800048c2:	8082                	ret
      return -1;
    800048c4:	557d                	li	a0,-1
    800048c6:	bfd9                	j	8000489c <filewrite+0xf6>
    800048c8:	557d                	li	a0,-1
    800048ca:	bfc9                	j	8000489c <filewrite+0xf6>
    ret = (i == n ? n : -1);
    800048cc:	557d                	li	a0,-1
    800048ce:	79a2                	ld	s3,40(sp)
    800048d0:	b7f1                	j	8000489c <filewrite+0xf6>

00000000800048d2 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    800048d2:	7179                	addi	sp,sp,-48
    800048d4:	f406                	sd	ra,40(sp)
    800048d6:	f022                	sd	s0,32(sp)
    800048d8:	ec26                	sd	s1,24(sp)
    800048da:	e052                	sd	s4,0(sp)
    800048dc:	1800                	addi	s0,sp,48
    800048de:	84aa                	mv	s1,a0
    800048e0:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    800048e2:	0005b023          	sd	zero,0(a1)
    800048e6:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    800048ea:	c3bff0ef          	jal	80004524 <filealloc>
    800048ee:	e088                	sd	a0,0(s1)
    800048f0:	c549                	beqz	a0,8000497a <pipealloc+0xa8>
    800048f2:	c33ff0ef          	jal	80004524 <filealloc>
    800048f6:	00aa3023          	sd	a0,0(s4)
    800048fa:	cd25                	beqz	a0,80004972 <pipealloc+0xa0>
    800048fc:	e84a                	sd	s2,16(sp)
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    800048fe:	a90fc0ef          	jal	80000b8e <kalloc>
    80004902:	892a                	mv	s2,a0
    80004904:	c12d                	beqz	a0,80004966 <pipealloc+0x94>
    80004906:	e44e                	sd	s3,8(sp)
    goto bad;
  pi->readopen = 1;
    80004908:	4985                	li	s3,1
    8000490a:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    8000490e:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    80004912:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80004916:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    8000491a:	00004597          	auipc	a1,0x4
    8000491e:	cb658593          	addi	a1,a1,-842 # 800085d0 <etext+0x5d0>
    80004922:	b1afc0ef          	jal	80000c3c <initlock>
  (*f0)->type = FD_PIPE;
    80004926:	609c                	ld	a5,0(s1)
    80004928:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    8000492c:	609c                	ld	a5,0(s1)
    8000492e:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80004932:	609c                	ld	a5,0(s1)
    80004934:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80004938:	609c                	ld	a5,0(s1)
    8000493a:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    8000493e:	000a3783          	ld	a5,0(s4)
    80004942:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80004946:	000a3783          	ld	a5,0(s4)
    8000494a:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    8000494e:	000a3783          	ld	a5,0(s4)
    80004952:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80004956:	000a3783          	ld	a5,0(s4)
    8000495a:	0127b823          	sd	s2,16(a5)
  return 0;
    8000495e:	4501                	li	a0,0
    80004960:	6942                	ld	s2,16(sp)
    80004962:	69a2                	ld	s3,8(sp)
    80004964:	a01d                	j	8000498a <pipealloc+0xb8>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80004966:	6088                	ld	a0,0(s1)
    80004968:	c119                	beqz	a0,8000496e <pipealloc+0x9c>
    8000496a:	6942                	ld	s2,16(sp)
    8000496c:	a029                	j	80004976 <pipealloc+0xa4>
    8000496e:	6942                	ld	s2,16(sp)
    80004970:	a029                	j	8000497a <pipealloc+0xa8>
    80004972:	6088                	ld	a0,0(s1)
    80004974:	c10d                	beqz	a0,80004996 <pipealloc+0xc4>
    fileclose(*f0);
    80004976:	c53ff0ef          	jal	800045c8 <fileclose>
  if(*f1)
    8000497a:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    8000497e:	557d                	li	a0,-1
  if(*f1)
    80004980:	c789                	beqz	a5,8000498a <pipealloc+0xb8>
    fileclose(*f1);
    80004982:	853e                	mv	a0,a5
    80004984:	c45ff0ef          	jal	800045c8 <fileclose>
  return -1;
    80004988:	557d                	li	a0,-1
}
    8000498a:	70a2                	ld	ra,40(sp)
    8000498c:	7402                	ld	s0,32(sp)
    8000498e:	64e2                	ld	s1,24(sp)
    80004990:	6a02                	ld	s4,0(sp)
    80004992:	6145                	addi	sp,sp,48
    80004994:	8082                	ret
  return -1;
    80004996:	557d                	li	a0,-1
    80004998:	bfcd                	j	8000498a <pipealloc+0xb8>

000000008000499a <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    8000499a:	1101                	addi	sp,sp,-32
    8000499c:	ec06                	sd	ra,24(sp)
    8000499e:	e822                	sd	s0,16(sp)
    800049a0:	e426                	sd	s1,8(sp)
    800049a2:	e04a                	sd	s2,0(sp)
    800049a4:	1000                	addi	s0,sp,32
    800049a6:	84aa                	mv	s1,a0
    800049a8:	892e                	mv	s2,a1
  acquire(&pi->lock);
    800049aa:	b12fc0ef          	jal	80000cbc <acquire>
  if(writable){
    800049ae:	02090763          	beqz	s2,800049dc <pipeclose+0x42>
    pi->writeopen = 0;
    800049b2:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    800049b6:	21848513          	addi	a0,s1,536
    800049ba:	a89fd0ef          	jal	80002442 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    800049be:	2204b783          	ld	a5,544(s1)
    800049c2:	e785                	bnez	a5,800049ea <pipeclose+0x50>
    release(&pi->lock);
    800049c4:	8526                	mv	a0,s1
    800049c6:	b8efc0ef          	jal	80000d54 <release>
    kfree((char*)pi);
    800049ca:	8526                	mv	a0,s1
    800049cc:	882fc0ef          	jal	80000a4e <kfree>
  } else
    release(&pi->lock);
}
    800049d0:	60e2                	ld	ra,24(sp)
    800049d2:	6442                	ld	s0,16(sp)
    800049d4:	64a2                	ld	s1,8(sp)
    800049d6:	6902                	ld	s2,0(sp)
    800049d8:	6105                	addi	sp,sp,32
    800049da:	8082                	ret
    pi->readopen = 0;
    800049dc:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    800049e0:	21c48513          	addi	a0,s1,540
    800049e4:	a5ffd0ef          	jal	80002442 <wakeup>
    800049e8:	bfd9                	j	800049be <pipeclose+0x24>
    release(&pi->lock);
    800049ea:	8526                	mv	a0,s1
    800049ec:	b68fc0ef          	jal	80000d54 <release>
}
    800049f0:	b7c5                	j	800049d0 <pipeclose+0x36>

00000000800049f2 <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    800049f2:	711d                	addi	sp,sp,-96
    800049f4:	ec86                	sd	ra,88(sp)
    800049f6:	e8a2                	sd	s0,80(sp)
    800049f8:	e4a6                	sd	s1,72(sp)
    800049fa:	e0ca                	sd	s2,64(sp)
    800049fc:	fc4e                	sd	s3,56(sp)
    800049fe:	f852                	sd	s4,48(sp)
    80004a00:	f456                	sd	s5,40(sp)
    80004a02:	1080                	addi	s0,sp,96
    80004a04:	84aa                	mv	s1,a0
    80004a06:	8aae                	mv	s5,a1
    80004a08:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    80004a0a:	9c8fd0ef          	jal	80001bd2 <myproc>
    80004a0e:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    80004a10:	8526                	mv	a0,s1
    80004a12:	aaafc0ef          	jal	80000cbc <acquire>
  while(i < n){
    80004a16:	0b405a63          	blez	s4,80004aca <pipewrite+0xd8>
    80004a1a:	f05a                	sd	s6,32(sp)
    80004a1c:	ec5e                	sd	s7,24(sp)
    80004a1e:	e862                	sd	s8,16(sp)
  int i = 0;
    80004a20:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004a22:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    80004a24:	21848c13          	addi	s8,s1,536
      sleep(&pi->nwrite, &pi->lock);
    80004a28:	21c48b93          	addi	s7,s1,540
    80004a2c:	a81d                	j	80004a62 <pipewrite+0x70>
      release(&pi->lock);
    80004a2e:	8526                	mv	a0,s1
    80004a30:	b24fc0ef          	jal	80000d54 <release>
      return -1;
    80004a34:	597d                	li	s2,-1
    80004a36:	7b02                	ld	s6,32(sp)
    80004a38:	6be2                	ld	s7,24(sp)
    80004a3a:	6c42                	ld	s8,16(sp)
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    80004a3c:	854a                	mv	a0,s2
    80004a3e:	60e6                	ld	ra,88(sp)
    80004a40:	6446                	ld	s0,80(sp)
    80004a42:	64a6                	ld	s1,72(sp)
    80004a44:	6906                	ld	s2,64(sp)
    80004a46:	79e2                	ld	s3,56(sp)
    80004a48:	7a42                	ld	s4,48(sp)
    80004a4a:	7aa2                	ld	s5,40(sp)
    80004a4c:	6125                	addi	sp,sp,96
    80004a4e:	8082                	ret
      wakeup(&pi->nread);
    80004a50:	8562                	mv	a0,s8
    80004a52:	9f1fd0ef          	jal	80002442 <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80004a56:	85a6                	mv	a1,s1
    80004a58:	855e                	mv	a0,s7
    80004a5a:	99dfd0ef          	jal	800023f6 <sleep>
  while(i < n){
    80004a5e:	05495b63          	bge	s2,s4,80004ab4 <pipewrite+0xc2>
    if(pi->readopen == 0 || killed(pr)){
    80004a62:	2204a783          	lw	a5,544(s1)
    80004a66:	d7e1                	beqz	a5,80004a2e <pipewrite+0x3c>
    80004a68:	854e                	mv	a0,s3
    80004a6a:	bc5fd0ef          	jal	8000262e <killed>
    80004a6e:	f161                	bnez	a0,80004a2e <pipewrite+0x3c>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    80004a70:	2184a783          	lw	a5,536(s1)
    80004a74:	21c4a703          	lw	a4,540(s1)
    80004a78:	2007879b          	addiw	a5,a5,512
    80004a7c:	fcf70ae3          	beq	a4,a5,80004a50 <pipewrite+0x5e>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004a80:	4685                	li	a3,1
    80004a82:	01590633          	add	a2,s2,s5
    80004a86:	faf40593          	addi	a1,s0,-81
    80004a8a:	0509b503          	ld	a0,80(s3)
    80004a8e:	f29fc0ef          	jal	800019b6 <copyin>
    80004a92:	03650e63          	beq	a0,s6,80004ace <pipewrite+0xdc>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80004a96:	21c4a783          	lw	a5,540(s1)
    80004a9a:	0017871b          	addiw	a4,a5,1
    80004a9e:	20e4ae23          	sw	a4,540(s1)
    80004aa2:	1ff7f793          	andi	a5,a5,511
    80004aa6:	97a6                	add	a5,a5,s1
    80004aa8:	faf44703          	lbu	a4,-81(s0)
    80004aac:	00e78c23          	sb	a4,24(a5)
      i++;
    80004ab0:	2905                	addiw	s2,s2,1
    80004ab2:	b775                	j	80004a5e <pipewrite+0x6c>
    80004ab4:	7b02                	ld	s6,32(sp)
    80004ab6:	6be2                	ld	s7,24(sp)
    80004ab8:	6c42                	ld	s8,16(sp)
  wakeup(&pi->nread);
    80004aba:	21848513          	addi	a0,s1,536
    80004abe:	985fd0ef          	jal	80002442 <wakeup>
  release(&pi->lock);
    80004ac2:	8526                	mv	a0,s1
    80004ac4:	a90fc0ef          	jal	80000d54 <release>
  return i;
    80004ac8:	bf95                	j	80004a3c <pipewrite+0x4a>
  int i = 0;
    80004aca:	4901                	li	s2,0
    80004acc:	b7fd                	j	80004aba <pipewrite+0xc8>
    80004ace:	7b02                	ld	s6,32(sp)
    80004ad0:	6be2                	ld	s7,24(sp)
    80004ad2:	6c42                	ld	s8,16(sp)
    80004ad4:	b7dd                	j	80004aba <pipewrite+0xc8>

0000000080004ad6 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80004ad6:	715d                	addi	sp,sp,-80
    80004ad8:	e486                	sd	ra,72(sp)
    80004ada:	e0a2                	sd	s0,64(sp)
    80004adc:	fc26                	sd	s1,56(sp)
    80004ade:	f84a                	sd	s2,48(sp)
    80004ae0:	f44e                	sd	s3,40(sp)
    80004ae2:	f052                	sd	s4,32(sp)
    80004ae4:	ec56                	sd	s5,24(sp)
    80004ae6:	0880                	addi	s0,sp,80
    80004ae8:	84aa                	mv	s1,a0
    80004aea:	892e                	mv	s2,a1
    80004aec:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80004aee:	8e4fd0ef          	jal	80001bd2 <myproc>
    80004af2:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80004af4:	8526                	mv	a0,s1
    80004af6:	9c6fc0ef          	jal	80000cbc <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004afa:	2184a703          	lw	a4,536(s1)
    80004afe:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004b02:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004b06:	02f71563          	bne	a4,a5,80004b30 <piperead+0x5a>
    80004b0a:	2244a783          	lw	a5,548(s1)
    80004b0e:	cb85                	beqz	a5,80004b3e <piperead+0x68>
    if(killed(pr)){
    80004b10:	8552                	mv	a0,s4
    80004b12:	b1dfd0ef          	jal	8000262e <killed>
    80004b16:	ed19                	bnez	a0,80004b34 <piperead+0x5e>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004b18:	85a6                	mv	a1,s1
    80004b1a:	854e                	mv	a0,s3
    80004b1c:	8dbfd0ef          	jal	800023f6 <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004b20:	2184a703          	lw	a4,536(s1)
    80004b24:	21c4a783          	lw	a5,540(s1)
    80004b28:	fef701e3          	beq	a4,a5,80004b0a <piperead+0x34>
    80004b2c:	e85a                	sd	s6,16(sp)
    80004b2e:	a809                	j	80004b40 <piperead+0x6a>
    80004b30:	e85a                	sd	s6,16(sp)
    80004b32:	a039                	j	80004b40 <piperead+0x6a>
      release(&pi->lock);
    80004b34:	8526                	mv	a0,s1
    80004b36:	a1efc0ef          	jal	80000d54 <release>
      return -1;
    80004b3a:	59fd                	li	s3,-1
    80004b3c:	a8b9                	j	80004b9a <piperead+0xc4>
    80004b3e:	e85a                	sd	s6,16(sp)
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004b40:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1) {
    80004b42:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004b44:	05505363          	blez	s5,80004b8a <piperead+0xb4>
    if(pi->nread == pi->nwrite)
    80004b48:	2184a783          	lw	a5,536(s1)
    80004b4c:	21c4a703          	lw	a4,540(s1)
    80004b50:	02f70d63          	beq	a4,a5,80004b8a <piperead+0xb4>
    ch = pi->data[pi->nread % PIPESIZE];
    80004b54:	1ff7f793          	andi	a5,a5,511
    80004b58:	97a6                	add	a5,a5,s1
    80004b5a:	0187c783          	lbu	a5,24(a5)
    80004b5e:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1) {
    80004b62:	4685                	li	a3,1
    80004b64:	fbf40613          	addi	a2,s0,-65
    80004b68:	85ca                	mv	a1,s2
    80004b6a:	050a3503          	ld	a0,80(s4)
    80004b6e:	d65fc0ef          	jal	800018d2 <copyout>
    80004b72:	03650e63          	beq	a0,s6,80004bae <piperead+0xd8>
      if(i == 0)
        i = -1;
      break;
    }
    pi->nread++;
    80004b76:	2184a783          	lw	a5,536(s1)
    80004b7a:	2785                	addiw	a5,a5,1
    80004b7c:	20f4ac23          	sw	a5,536(s1)
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004b80:	2985                	addiw	s3,s3,1
    80004b82:	0905                	addi	s2,s2,1
    80004b84:	fd3a92e3          	bne	s5,s3,80004b48 <piperead+0x72>
    80004b88:	89d6                	mv	s3,s5
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80004b8a:	21c48513          	addi	a0,s1,540
    80004b8e:	8b5fd0ef          	jal	80002442 <wakeup>
  release(&pi->lock);
    80004b92:	8526                	mv	a0,s1
    80004b94:	9c0fc0ef          	jal	80000d54 <release>
    80004b98:	6b42                	ld	s6,16(sp)
  return i;
}
    80004b9a:	854e                	mv	a0,s3
    80004b9c:	60a6                	ld	ra,72(sp)
    80004b9e:	6406                	ld	s0,64(sp)
    80004ba0:	74e2                	ld	s1,56(sp)
    80004ba2:	7942                	ld	s2,48(sp)
    80004ba4:	79a2                	ld	s3,40(sp)
    80004ba6:	7a02                	ld	s4,32(sp)
    80004ba8:	6ae2                	ld	s5,24(sp)
    80004baa:	6161                	addi	sp,sp,80
    80004bac:	8082                	ret
      if(i == 0)
    80004bae:	fc099ee3          	bnez	s3,80004b8a <piperead+0xb4>
        i = -1;
    80004bb2:	89aa                	mv	s3,a0
    80004bb4:	bfd9                	j	80004b8a <piperead+0xb4>

0000000080004bb6 <flags2perm>:

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

// map ELF permissions to PTE permission bits.
int flags2perm(int flags)
{
    80004bb6:	1141                	addi	sp,sp,-16
    80004bb8:	e422                	sd	s0,8(sp)
    80004bba:	0800                	addi	s0,sp,16
    80004bbc:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    80004bbe:	8905                	andi	a0,a0,1
    80004bc0:	050e                	slli	a0,a0,0x3
      perm = PTE_X;
    if(flags & 0x2)
    80004bc2:	8b89                	andi	a5,a5,2
    80004bc4:	c399                	beqz	a5,80004bca <flags2perm+0x14>
      perm |= PTE_W;
    80004bc6:	00456513          	ori	a0,a0,4
    return perm;
}
    80004bca:	6422                	ld	s0,8(sp)
    80004bcc:	0141                	addi	sp,sp,16
    80004bce:	8082                	ret

0000000080004bd0 <kexec>:
//
// the implementation of the exec() system call
//
int
kexec(char *path, char **argv)
{
    80004bd0:	df010113          	addi	sp,sp,-528
    80004bd4:	20113423          	sd	ra,520(sp)
    80004bd8:	20813023          	sd	s0,512(sp)
    80004bdc:	ffa6                	sd	s1,504(sp)
    80004bde:	fbca                	sd	s2,496(sp)
    80004be0:	0c00                	addi	s0,sp,528
    80004be2:	892a                	mv	s2,a0
    80004be4:	dea43c23          	sd	a0,-520(s0)
    80004be8:	e0b43023          	sd	a1,-512(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80004bec:	fe7fc0ef          	jal	80001bd2 <myproc>
    80004bf0:	84aa                	mv	s1,a0

  begin_op();
    80004bf2:	dcaff0ef          	jal	800041bc <begin_op>

  // Open the executable file.
  if((ip = namei(path)) == 0){
    80004bf6:	854a                	mv	a0,s2
    80004bf8:	bf0ff0ef          	jal	80003fe8 <namei>
    80004bfc:	c931                	beqz	a0,80004c50 <kexec+0x80>
    80004bfe:	f3d2                	sd	s4,480(sp)
    80004c00:	8a2a                	mv	s4,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80004c02:	bd1fe0ef          	jal	800037d2 <ilock>

  // Read the ELF header.
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80004c06:	04000713          	li	a4,64
    80004c0a:	4681                	li	a3,0
    80004c0c:	e5040613          	addi	a2,s0,-432
    80004c10:	4581                	li	a1,0
    80004c12:	8552                	mv	a0,s4
    80004c14:	f4ffe0ef          	jal	80003b62 <readi>
    80004c18:	04000793          	li	a5,64
    80004c1c:	00f51a63          	bne	a0,a5,80004c30 <kexec+0x60>
    goto bad;

  // Is this really an ELF file?
  if(elf.magic != ELF_MAGIC)
    80004c20:	e5042703          	lw	a4,-432(s0)
    80004c24:	464c47b7          	lui	a5,0x464c4
    80004c28:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80004c2c:	02f70663          	beq	a4,a5,80004c58 <kexec+0x88>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    80004c30:	8552                	mv	a0,s4
    80004c32:	dabfe0ef          	jal	800039dc <iunlockput>
    end_op();
    80004c36:	df0ff0ef          	jal	80004226 <end_op>
  }
  return -1;
    80004c3a:	557d                	li	a0,-1
    80004c3c:	7a1e                	ld	s4,480(sp)
}
    80004c3e:	20813083          	ld	ra,520(sp)
    80004c42:	20013403          	ld	s0,512(sp)
    80004c46:	74fe                	ld	s1,504(sp)
    80004c48:	795e                	ld	s2,496(sp)
    80004c4a:	21010113          	addi	sp,sp,528
    80004c4e:	8082                	ret
    end_op();
    80004c50:	dd6ff0ef          	jal	80004226 <end_op>
    return -1;
    80004c54:	557d                	li	a0,-1
    80004c56:	b7e5                	j	80004c3e <kexec+0x6e>
    80004c58:	ebda                	sd	s6,464(sp)
  if((pagetable = proc_pagetable(p)) == 0)
    80004c5a:	8526                	mv	a0,s1
    80004c5c:	87cfd0ef          	jal	80001cd8 <proc_pagetable>
    80004c60:	8b2a                	mv	s6,a0
    80004c62:	2c050b63          	beqz	a0,80004f38 <kexec+0x368>
    80004c66:	f7ce                	sd	s3,488(sp)
    80004c68:	efd6                	sd	s5,472(sp)
    80004c6a:	e7de                	sd	s7,456(sp)
    80004c6c:	e3e2                	sd	s8,448(sp)
    80004c6e:	ff66                	sd	s9,440(sp)
    80004c70:	fb6a                	sd	s10,432(sp)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004c72:	e7042d03          	lw	s10,-400(s0)
    80004c76:	e8845783          	lhu	a5,-376(s0)
    80004c7a:	12078963          	beqz	a5,80004dac <kexec+0x1dc>
    80004c7e:	f76e                	sd	s11,424(sp)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004c80:	4901                	li	s2,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004c82:	4d81                	li	s11,0
    if(ph.vaddr % PGSIZE != 0)
    80004c84:	6c85                	lui	s9,0x1
    80004c86:	fffc8793          	addi	a5,s9,-1 # fff <_entry-0x7ffff001>
    80004c8a:	def43823          	sd	a5,-528(s0)

  for(i = 0; i < sz; i += PGSIZE){
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    if(sz - i < PGSIZE)
    80004c8e:	6a85                	lui	s5,0x1
    80004c90:	a085                	j	80004cf0 <kexec+0x120>
      panic("loadseg: address should exist");
    80004c92:	00004517          	auipc	a0,0x4
    80004c96:	94650513          	addi	a0,a0,-1722 # 800085d8 <etext+0x5d8>
    80004c9a:	b79fb0ef          	jal	80000812 <panic>
    if(sz - i < PGSIZE)
    80004c9e:	2481                	sext.w	s1,s1
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80004ca0:	8726                	mv	a4,s1
    80004ca2:	012c06bb          	addw	a3,s8,s2
    80004ca6:	4581                	li	a1,0
    80004ca8:	8552                	mv	a0,s4
    80004caa:	eb9fe0ef          	jal	80003b62 <readi>
    80004cae:	2501                	sext.w	a0,a0
    80004cb0:	24a49a63          	bne	s1,a0,80004f04 <kexec+0x334>
  for(i = 0; i < sz; i += PGSIZE){
    80004cb4:	012a893b          	addw	s2,s5,s2
    80004cb8:	03397363          	bgeu	s2,s3,80004cde <kexec+0x10e>
    pa = walkaddr(pagetable, va + i);
    80004cbc:	02091593          	slli	a1,s2,0x20
    80004cc0:	9181                	srli	a1,a1,0x20
    80004cc2:	95de                	add	a1,a1,s7
    80004cc4:	855a                	mv	a0,s6
    80004cc6:	be4fc0ef          	jal	800010aa <walkaddr>
    80004cca:	862a                	mv	a2,a0
    if(pa == 0)
    80004ccc:	d179                	beqz	a0,80004c92 <kexec+0xc2>
    if(sz - i < PGSIZE)
    80004cce:	412984bb          	subw	s1,s3,s2
    80004cd2:	0004879b          	sext.w	a5,s1
    80004cd6:	fcfcf4e3          	bgeu	s9,a5,80004c9e <kexec+0xce>
    80004cda:	84d6                	mv	s1,s5
    80004cdc:	b7c9                	j	80004c9e <kexec+0xce>
    sz = sz1;
    80004cde:	e0843903          	ld	s2,-504(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004ce2:	2d85                	addiw	s11,s11,1
    80004ce4:	038d0d1b          	addiw	s10,s10,56 # 1038 <_entry-0x7fffefc8>
    80004ce8:	e8845783          	lhu	a5,-376(s0)
    80004cec:	08fdd063          	bge	s11,a5,80004d6c <kexec+0x19c>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80004cf0:	2d01                	sext.w	s10,s10
    80004cf2:	03800713          	li	a4,56
    80004cf6:	86ea                	mv	a3,s10
    80004cf8:	e1840613          	addi	a2,s0,-488
    80004cfc:	4581                	li	a1,0
    80004cfe:	8552                	mv	a0,s4
    80004d00:	e63fe0ef          	jal	80003b62 <readi>
    80004d04:	03800793          	li	a5,56
    80004d08:	1cf51663          	bne	a0,a5,80004ed4 <kexec+0x304>
    if(ph.type != ELF_PROG_LOAD)
    80004d0c:	e1842783          	lw	a5,-488(s0)
    80004d10:	4705                	li	a4,1
    80004d12:	fce798e3          	bne	a5,a4,80004ce2 <kexec+0x112>
    if(ph.memsz < ph.filesz)
    80004d16:	e4043483          	ld	s1,-448(s0)
    80004d1a:	e3843783          	ld	a5,-456(s0)
    80004d1e:	1af4ef63          	bltu	s1,a5,80004edc <kexec+0x30c>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    80004d22:	e2843783          	ld	a5,-472(s0)
    80004d26:	94be                	add	s1,s1,a5
    80004d28:	1af4ee63          	bltu	s1,a5,80004ee4 <kexec+0x314>
    if(ph.vaddr % PGSIZE != 0)
    80004d2c:	df043703          	ld	a4,-528(s0)
    80004d30:	8ff9                	and	a5,a5,a4
    80004d32:	1a079d63          	bnez	a5,80004eec <kexec+0x31c>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80004d36:	e1c42503          	lw	a0,-484(s0)
    80004d3a:	e7dff0ef          	jal	80004bb6 <flags2perm>
    80004d3e:	86aa                	mv	a3,a0
    80004d40:	8626                	mv	a2,s1
    80004d42:	85ca                	mv	a1,s2
    80004d44:	855a                	mv	a0,s6
    80004d46:	f58fc0ef          	jal	8000149e <uvmalloc>
    80004d4a:	e0a43423          	sd	a0,-504(s0)
    80004d4e:	1a050363          	beqz	a0,80004ef4 <kexec+0x324>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80004d52:	e2843b83          	ld	s7,-472(s0)
    80004d56:	e2042c03          	lw	s8,-480(s0)
    80004d5a:	e3842983          	lw	s3,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    80004d5e:	00098463          	beqz	s3,80004d66 <kexec+0x196>
    80004d62:	4901                	li	s2,0
    80004d64:	bfa1                	j	80004cbc <kexec+0xec>
    sz = sz1;
    80004d66:	e0843903          	ld	s2,-504(s0)
    80004d6a:	bfa5                	j	80004ce2 <kexec+0x112>
    80004d6c:	7dba                	ld	s11,424(sp)
  iunlockput(ip);
    80004d6e:	8552                	mv	a0,s4
    80004d70:	c6dfe0ef          	jal	800039dc <iunlockput>
  end_op();
    80004d74:	cb2ff0ef          	jal	80004226 <end_op>
  p = myproc();
    80004d78:	e5bfc0ef          	jal	80001bd2 <myproc>
    80004d7c:	8aaa                	mv	s5,a0
  uint64 oldsz = p->sz;
    80004d7e:	04853c83          	ld	s9,72(a0)
  sz = PGROUNDUP(sz);
    80004d82:	6985                	lui	s3,0x1
    80004d84:	19fd                	addi	s3,s3,-1 # fff <_entry-0x7ffff001>
    80004d86:	99ca                	add	s3,s3,s2
    80004d88:	77fd                	lui	a5,0xfffff
    80004d8a:	00f9f9b3          	and	s3,s3,a5
  if((sz1 = uvmalloc(pagetable, sz, sz + (USERSTACK+1)*PGSIZE, PTE_W)) == 0)
    80004d8e:	4691                	li	a3,4
    80004d90:	6609                	lui	a2,0x2
    80004d92:	964e                	add	a2,a2,s3
    80004d94:	85ce                	mv	a1,s3
    80004d96:	855a                	mv	a0,s6
    80004d98:	f06fc0ef          	jal	8000149e <uvmalloc>
    80004d9c:	892a                	mv	s2,a0
    80004d9e:	e0a43423          	sd	a0,-504(s0)
    80004da2:	e519                	bnez	a0,80004db0 <kexec+0x1e0>
  if(pagetable)
    80004da4:	e1343423          	sd	s3,-504(s0)
    80004da8:	4a01                	li	s4,0
    80004daa:	aab1                	j	80004f06 <kexec+0x336>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004dac:	4901                	li	s2,0
    80004dae:	b7c1                	j	80004d6e <kexec+0x19e>
  uvmclear(pagetable, sz-(USERSTACK+1)*PGSIZE);
    80004db0:	75f9                	lui	a1,0xffffe
    80004db2:	95aa                	add	a1,a1,a0
    80004db4:	855a                	mv	a0,s6
    80004db6:	93bfc0ef          	jal	800016f0 <uvmclear>
  stackbase = sp - USERSTACK*PGSIZE;
    80004dba:	7bfd                	lui	s7,0xfffff
    80004dbc:	9bca                	add	s7,s7,s2
  for(argc = 0; argv[argc]; argc++) {
    80004dbe:	e0043783          	ld	a5,-512(s0)
    80004dc2:	6388                	ld	a0,0(a5)
    80004dc4:	cd39                	beqz	a0,80004e22 <kexec+0x252>
    80004dc6:	e9040993          	addi	s3,s0,-368
    80004dca:	f9040c13          	addi	s8,s0,-112
    80004dce:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    80004dd0:	930fc0ef          	jal	80000f00 <strlen>
    80004dd4:	0015079b          	addiw	a5,a0,1
    80004dd8:	40f907b3          	sub	a5,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80004ddc:	ff07f913          	andi	s2,a5,-16
    if(sp < stackbase)
    80004de0:	11796e63          	bltu	s2,s7,80004efc <kexec+0x32c>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80004de4:	e0043d03          	ld	s10,-512(s0)
    80004de8:	000d3a03          	ld	s4,0(s10)
    80004dec:	8552                	mv	a0,s4
    80004dee:	912fc0ef          	jal	80000f00 <strlen>
    80004df2:	0015069b          	addiw	a3,a0,1
    80004df6:	8652                	mv	a2,s4
    80004df8:	85ca                	mv	a1,s2
    80004dfa:	855a                	mv	a0,s6
    80004dfc:	ad7fc0ef          	jal	800018d2 <copyout>
    80004e00:	10054063          	bltz	a0,80004f00 <kexec+0x330>
    ustack[argc] = sp;
    80004e04:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    80004e08:	0485                	addi	s1,s1,1
    80004e0a:	008d0793          	addi	a5,s10,8
    80004e0e:	e0f43023          	sd	a5,-512(s0)
    80004e12:	008d3503          	ld	a0,8(s10)
    80004e16:	c909                	beqz	a0,80004e28 <kexec+0x258>
    if(argc >= MAXARG)
    80004e18:	09a1                	addi	s3,s3,8
    80004e1a:	fb899be3          	bne	s3,s8,80004dd0 <kexec+0x200>
  ip = 0;
    80004e1e:	4a01                	li	s4,0
    80004e20:	a0dd                	j	80004f06 <kexec+0x336>
  sp = sz;
    80004e22:	e0843903          	ld	s2,-504(s0)
  for(argc = 0; argv[argc]; argc++) {
    80004e26:	4481                	li	s1,0
  ustack[argc] = 0;
    80004e28:	00349793          	slli	a5,s1,0x3
    80004e2c:	f9078793          	addi	a5,a5,-112 # ffffffffffffef90 <end+0xffffffff7ffb5498>
    80004e30:	97a2                	add	a5,a5,s0
    80004e32:	f007b023          	sd	zero,-256(a5)
  sp -= (argc+1) * sizeof(uint64);
    80004e36:	00148693          	addi	a3,s1,1
    80004e3a:	068e                	slli	a3,a3,0x3
    80004e3c:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    80004e40:	ff097913          	andi	s2,s2,-16
  sz = sz1;
    80004e44:	e0843983          	ld	s3,-504(s0)
  if(sp < stackbase)
    80004e48:	f5796ee3          	bltu	s2,s7,80004da4 <kexec+0x1d4>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    80004e4c:	e9040613          	addi	a2,s0,-368
    80004e50:	85ca                	mv	a1,s2
    80004e52:	855a                	mv	a0,s6
    80004e54:	a7ffc0ef          	jal	800018d2 <copyout>
    80004e58:	0e054263          	bltz	a0,80004f3c <kexec+0x36c>
  p->trapframe->a1 = sp;
    80004e5c:	058ab783          	ld	a5,88(s5) # 1058 <_entry-0x7fffefa8>
    80004e60:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    80004e64:	df843783          	ld	a5,-520(s0)
    80004e68:	0007c703          	lbu	a4,0(a5)
    80004e6c:	cf11                	beqz	a4,80004e88 <kexec+0x2b8>
    80004e6e:	0785                	addi	a5,a5,1
    if(*s == '/')
    80004e70:	02f00693          	li	a3,47
    80004e74:	a039                	j	80004e82 <kexec+0x2b2>
      last = s+1;
    80004e76:	def43c23          	sd	a5,-520(s0)
  for(last=s=path; *s; s++)
    80004e7a:	0785                	addi	a5,a5,1
    80004e7c:	fff7c703          	lbu	a4,-1(a5)
    80004e80:	c701                	beqz	a4,80004e88 <kexec+0x2b8>
    if(*s == '/')
    80004e82:	fed71ce3          	bne	a4,a3,80004e7a <kexec+0x2aa>
    80004e86:	bfc5                	j	80004e76 <kexec+0x2a6>
  safestrcpy(p->name, last, sizeof(p->name));
    80004e88:	4641                	li	a2,16
    80004e8a:	df843583          	ld	a1,-520(s0)
    80004e8e:	158a8513          	addi	a0,s5,344
    80004e92:	83cfc0ef          	jal	80000ece <safestrcpy>
  oldpagetable = p->pagetable;
    80004e96:	050ab503          	ld	a0,80(s5)
  p->pagetable = pagetable;
    80004e9a:	056ab823          	sd	s6,80(s5)
  p->sz = sz;
    80004e9e:	e0843783          	ld	a5,-504(s0)
    80004ea2:	04fab423          	sd	a5,72(s5)
  p->trapframe->epc = elf.entry;  // initial program counter = ulib.c:start()
    80004ea6:	058ab783          	ld	a5,88(s5)
    80004eaa:	e6843703          	ld	a4,-408(s0)
    80004eae:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    80004eb0:	058ab783          	ld	a5,88(s5)
    80004eb4:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    80004eb8:	85e6                	mv	a1,s9
    80004eba:	ea3fc0ef          	jal	80001d5c <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80004ebe:	0004851b          	sext.w	a0,s1
    80004ec2:	79be                	ld	s3,488(sp)
    80004ec4:	7a1e                	ld	s4,480(sp)
    80004ec6:	6afe                	ld	s5,472(sp)
    80004ec8:	6b5e                	ld	s6,464(sp)
    80004eca:	6bbe                	ld	s7,456(sp)
    80004ecc:	6c1e                	ld	s8,448(sp)
    80004ece:	7cfa                	ld	s9,440(sp)
    80004ed0:	7d5a                	ld	s10,432(sp)
    80004ed2:	b3b5                	j	80004c3e <kexec+0x6e>
    80004ed4:	e1243423          	sd	s2,-504(s0)
    80004ed8:	7dba                	ld	s11,424(sp)
    80004eda:	a035                	j	80004f06 <kexec+0x336>
    80004edc:	e1243423          	sd	s2,-504(s0)
    80004ee0:	7dba                	ld	s11,424(sp)
    80004ee2:	a015                	j	80004f06 <kexec+0x336>
    80004ee4:	e1243423          	sd	s2,-504(s0)
    80004ee8:	7dba                	ld	s11,424(sp)
    80004eea:	a831                	j	80004f06 <kexec+0x336>
    80004eec:	e1243423          	sd	s2,-504(s0)
    80004ef0:	7dba                	ld	s11,424(sp)
    80004ef2:	a811                	j	80004f06 <kexec+0x336>
    80004ef4:	e1243423          	sd	s2,-504(s0)
    80004ef8:	7dba                	ld	s11,424(sp)
    80004efa:	a031                	j	80004f06 <kexec+0x336>
  ip = 0;
    80004efc:	4a01                	li	s4,0
    80004efe:	a021                	j	80004f06 <kexec+0x336>
    80004f00:	4a01                	li	s4,0
  if(pagetable)
    80004f02:	a011                	j	80004f06 <kexec+0x336>
    80004f04:	7dba                	ld	s11,424(sp)
    proc_freepagetable(pagetable, sz);
    80004f06:	e0843583          	ld	a1,-504(s0)
    80004f0a:	855a                	mv	a0,s6
    80004f0c:	e51fc0ef          	jal	80001d5c <proc_freepagetable>
  return -1;
    80004f10:	557d                	li	a0,-1
  if(ip){
    80004f12:	000a1b63          	bnez	s4,80004f28 <kexec+0x358>
    80004f16:	79be                	ld	s3,488(sp)
    80004f18:	7a1e                	ld	s4,480(sp)
    80004f1a:	6afe                	ld	s5,472(sp)
    80004f1c:	6b5e                	ld	s6,464(sp)
    80004f1e:	6bbe                	ld	s7,456(sp)
    80004f20:	6c1e                	ld	s8,448(sp)
    80004f22:	7cfa                	ld	s9,440(sp)
    80004f24:	7d5a                	ld	s10,432(sp)
    80004f26:	bb21                	j	80004c3e <kexec+0x6e>
    80004f28:	79be                	ld	s3,488(sp)
    80004f2a:	6afe                	ld	s5,472(sp)
    80004f2c:	6b5e                	ld	s6,464(sp)
    80004f2e:	6bbe                	ld	s7,456(sp)
    80004f30:	6c1e                	ld	s8,448(sp)
    80004f32:	7cfa                	ld	s9,440(sp)
    80004f34:	7d5a                	ld	s10,432(sp)
    80004f36:	b9ed                	j	80004c30 <kexec+0x60>
    80004f38:	6b5e                	ld	s6,464(sp)
    80004f3a:	b9dd                	j	80004c30 <kexec+0x60>
  sz = sz1;
    80004f3c:	e0843983          	ld	s3,-504(s0)
    80004f40:	b595                	j	80004da4 <kexec+0x1d4>

0000000080004f42 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80004f42:	7179                	addi	sp,sp,-48
    80004f44:	f406                	sd	ra,40(sp)
    80004f46:	f022                	sd	s0,32(sp)
    80004f48:	ec26                	sd	s1,24(sp)
    80004f4a:	e84a                	sd	s2,16(sp)
    80004f4c:	1800                	addi	s0,sp,48
    80004f4e:	892e                	mv	s2,a1
    80004f50:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    80004f52:	fdc40593          	addi	a1,s0,-36
    80004f56:	da5fd0ef          	jal	80002cfa <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    80004f5a:	fdc42703          	lw	a4,-36(s0)
    80004f5e:	47bd                	li	a5,15
    80004f60:	02e7e963          	bltu	a5,a4,80004f92 <argfd+0x50>
    80004f64:	c6ffc0ef          	jal	80001bd2 <myproc>
    80004f68:	fdc42703          	lw	a4,-36(s0)
    80004f6c:	01a70793          	addi	a5,a4,26
    80004f70:	078e                	slli	a5,a5,0x3
    80004f72:	953e                	add	a0,a0,a5
    80004f74:	611c                	ld	a5,0(a0)
    80004f76:	c385                	beqz	a5,80004f96 <argfd+0x54>
    return -1;
  if(pfd)
    80004f78:	00090463          	beqz	s2,80004f80 <argfd+0x3e>
    *pfd = fd;
    80004f7c:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    80004f80:	4501                	li	a0,0
  if(pf)
    80004f82:	c091                	beqz	s1,80004f86 <argfd+0x44>
    *pf = f;
    80004f84:	e09c                	sd	a5,0(s1)
}
    80004f86:	70a2                	ld	ra,40(sp)
    80004f88:	7402                	ld	s0,32(sp)
    80004f8a:	64e2                	ld	s1,24(sp)
    80004f8c:	6942                	ld	s2,16(sp)
    80004f8e:	6145                	addi	sp,sp,48
    80004f90:	8082                	ret
    return -1;
    80004f92:	557d                	li	a0,-1
    80004f94:	bfcd                	j	80004f86 <argfd+0x44>
    80004f96:	557d                	li	a0,-1
    80004f98:	b7fd                	j	80004f86 <argfd+0x44>

0000000080004f9a <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    80004f9a:	1101                	addi	sp,sp,-32
    80004f9c:	ec06                	sd	ra,24(sp)
    80004f9e:	e822                	sd	s0,16(sp)
    80004fa0:	e426                	sd	s1,8(sp)
    80004fa2:	1000                	addi	s0,sp,32
    80004fa4:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    80004fa6:	c2dfc0ef          	jal	80001bd2 <myproc>
    80004faa:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    80004fac:	0d050793          	addi	a5,a0,208
    80004fb0:	4501                	li	a0,0
    80004fb2:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    80004fb4:	6398                	ld	a4,0(a5)
    80004fb6:	cb19                	beqz	a4,80004fcc <fdalloc+0x32>
  for(fd = 0; fd < NOFILE; fd++){
    80004fb8:	2505                	addiw	a0,a0,1
    80004fba:	07a1                	addi	a5,a5,8
    80004fbc:	fed51ce3          	bne	a0,a3,80004fb4 <fdalloc+0x1a>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80004fc0:	557d                	li	a0,-1
}
    80004fc2:	60e2                	ld	ra,24(sp)
    80004fc4:	6442                	ld	s0,16(sp)
    80004fc6:	64a2                	ld	s1,8(sp)
    80004fc8:	6105                	addi	sp,sp,32
    80004fca:	8082                	ret
      p->ofile[fd] = f;
    80004fcc:	01a50793          	addi	a5,a0,26
    80004fd0:	078e                	slli	a5,a5,0x3
    80004fd2:	963e                	add	a2,a2,a5
    80004fd4:	e204                	sd	s1,0(a2)
      return fd;
    80004fd6:	b7f5                	j	80004fc2 <fdalloc+0x28>

0000000080004fd8 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    80004fd8:	715d                	addi	sp,sp,-80
    80004fda:	e486                	sd	ra,72(sp)
    80004fdc:	e0a2                	sd	s0,64(sp)
    80004fde:	fc26                	sd	s1,56(sp)
    80004fe0:	f84a                	sd	s2,48(sp)
    80004fe2:	f44e                	sd	s3,40(sp)
    80004fe4:	ec56                	sd	s5,24(sp)
    80004fe6:	e85a                	sd	s6,16(sp)
    80004fe8:	0880                	addi	s0,sp,80
    80004fea:	8b2e                	mv	s6,a1
    80004fec:	89b2                	mv	s3,a2
    80004fee:	8936                	mv	s2,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    80004ff0:	fb040593          	addi	a1,s0,-80
    80004ff4:	80eff0ef          	jal	80004002 <nameiparent>
    80004ff8:	84aa                	mv	s1,a0
    80004ffa:	10050a63          	beqz	a0,8000510e <create+0x136>
    return 0;

  ilock(dp);
    80004ffe:	fd4fe0ef          	jal	800037d2 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    80005002:	4601                	li	a2,0
    80005004:	fb040593          	addi	a1,s0,-80
    80005008:	8526                	mv	a0,s1
    8000500a:	d79fe0ef          	jal	80003d82 <dirlookup>
    8000500e:	8aaa                	mv	s5,a0
    80005010:	c129                	beqz	a0,80005052 <create+0x7a>
    iunlockput(dp);
    80005012:	8526                	mv	a0,s1
    80005014:	9c9fe0ef          	jal	800039dc <iunlockput>
    ilock(ip);
    80005018:	8556                	mv	a0,s5
    8000501a:	fb8fe0ef          	jal	800037d2 <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    8000501e:	4789                	li	a5,2
    80005020:	02fb1463          	bne	s6,a5,80005048 <create+0x70>
    80005024:	044ad783          	lhu	a5,68(s5)
    80005028:	37f9                	addiw	a5,a5,-2
    8000502a:	17c2                	slli	a5,a5,0x30
    8000502c:	93c1                	srli	a5,a5,0x30
    8000502e:	4705                	li	a4,1
    80005030:	00f76c63          	bltu	a4,a5,80005048 <create+0x70>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    80005034:	8556                	mv	a0,s5
    80005036:	60a6                	ld	ra,72(sp)
    80005038:	6406                	ld	s0,64(sp)
    8000503a:	74e2                	ld	s1,56(sp)
    8000503c:	7942                	ld	s2,48(sp)
    8000503e:	79a2                	ld	s3,40(sp)
    80005040:	6ae2                	ld	s5,24(sp)
    80005042:	6b42                	ld	s6,16(sp)
    80005044:	6161                	addi	sp,sp,80
    80005046:	8082                	ret
    iunlockput(ip);
    80005048:	8556                	mv	a0,s5
    8000504a:	993fe0ef          	jal	800039dc <iunlockput>
    return 0;
    8000504e:	4a81                	li	s5,0
    80005050:	b7d5                	j	80005034 <create+0x5c>
    80005052:	f052                	sd	s4,32(sp)
  if((ip = ialloc(dp->dev, type)) == 0){
    80005054:	85da                	mv	a1,s6
    80005056:	4088                	lw	a0,0(s1)
    80005058:	e0afe0ef          	jal	80003662 <ialloc>
    8000505c:	8a2a                	mv	s4,a0
    8000505e:	cd15                	beqz	a0,8000509a <create+0xc2>
  ilock(ip);
    80005060:	f72fe0ef          	jal	800037d2 <ilock>
  ip->major = major;
    80005064:	053a1323          	sh	s3,70(s4)
  ip->minor = minor;
    80005068:	052a1423          	sh	s2,72(s4)
  ip->nlink = 1;
    8000506c:	4905                	li	s2,1
    8000506e:	052a1523          	sh	s2,74(s4)
  iupdate(ip);
    80005072:	8552                	mv	a0,s4
    80005074:	eaafe0ef          	jal	8000371e <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    80005078:	032b0763          	beq	s6,s2,800050a6 <create+0xce>
  if(dirlink(dp, name, ip->inum) < 0)
    8000507c:	004a2603          	lw	a2,4(s4)
    80005080:	fb040593          	addi	a1,s0,-80
    80005084:	8526                	mv	a0,s1
    80005086:	ec9fe0ef          	jal	80003f4e <dirlink>
    8000508a:	06054563          	bltz	a0,800050f4 <create+0x11c>
  iunlockput(dp);
    8000508e:	8526                	mv	a0,s1
    80005090:	94dfe0ef          	jal	800039dc <iunlockput>
  return ip;
    80005094:	8ad2                	mv	s5,s4
    80005096:	7a02                	ld	s4,32(sp)
    80005098:	bf71                	j	80005034 <create+0x5c>
    iunlockput(dp);
    8000509a:	8526                	mv	a0,s1
    8000509c:	941fe0ef          	jal	800039dc <iunlockput>
    return 0;
    800050a0:	8ad2                	mv	s5,s4
    800050a2:	7a02                	ld	s4,32(sp)
    800050a4:	bf41                	j	80005034 <create+0x5c>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    800050a6:	004a2603          	lw	a2,4(s4)
    800050aa:	00003597          	auipc	a1,0x3
    800050ae:	54e58593          	addi	a1,a1,1358 # 800085f8 <etext+0x5f8>
    800050b2:	8552                	mv	a0,s4
    800050b4:	e9bfe0ef          	jal	80003f4e <dirlink>
    800050b8:	02054e63          	bltz	a0,800050f4 <create+0x11c>
    800050bc:	40d0                	lw	a2,4(s1)
    800050be:	00003597          	auipc	a1,0x3
    800050c2:	54258593          	addi	a1,a1,1346 # 80008600 <etext+0x600>
    800050c6:	8552                	mv	a0,s4
    800050c8:	e87fe0ef          	jal	80003f4e <dirlink>
    800050cc:	02054463          	bltz	a0,800050f4 <create+0x11c>
  if(dirlink(dp, name, ip->inum) < 0)
    800050d0:	004a2603          	lw	a2,4(s4)
    800050d4:	fb040593          	addi	a1,s0,-80
    800050d8:	8526                	mv	a0,s1
    800050da:	e75fe0ef          	jal	80003f4e <dirlink>
    800050de:	00054b63          	bltz	a0,800050f4 <create+0x11c>
    dp->nlink++;  // for ".."
    800050e2:	04a4d783          	lhu	a5,74(s1)
    800050e6:	2785                	addiw	a5,a5,1
    800050e8:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    800050ec:	8526                	mv	a0,s1
    800050ee:	e30fe0ef          	jal	8000371e <iupdate>
    800050f2:	bf71                	j	8000508e <create+0xb6>
  ip->nlink = 0;
    800050f4:	040a1523          	sh	zero,74(s4)
  iupdate(ip);
    800050f8:	8552                	mv	a0,s4
    800050fa:	e24fe0ef          	jal	8000371e <iupdate>
  iunlockput(ip);
    800050fe:	8552                	mv	a0,s4
    80005100:	8ddfe0ef          	jal	800039dc <iunlockput>
  iunlockput(dp);
    80005104:	8526                	mv	a0,s1
    80005106:	8d7fe0ef          	jal	800039dc <iunlockput>
  return 0;
    8000510a:	7a02                	ld	s4,32(sp)
    8000510c:	b725                	j	80005034 <create+0x5c>
    return 0;
    8000510e:	8aaa                	mv	s5,a0
    80005110:	b715                	j	80005034 <create+0x5c>

0000000080005112 <sys_dup>:
{
    80005112:	7179                	addi	sp,sp,-48
    80005114:	f406                	sd	ra,40(sp)
    80005116:	f022                	sd	s0,32(sp)
    80005118:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    8000511a:	fd840613          	addi	a2,s0,-40
    8000511e:	4581                	li	a1,0
    80005120:	4501                	li	a0,0
    80005122:	e21ff0ef          	jal	80004f42 <argfd>
    return -1;
    80005126:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    80005128:	02054363          	bltz	a0,8000514e <sys_dup+0x3c>
    8000512c:	ec26                	sd	s1,24(sp)
    8000512e:	e84a                	sd	s2,16(sp)
  if((fd=fdalloc(f)) < 0)
    80005130:	fd843903          	ld	s2,-40(s0)
    80005134:	854a                	mv	a0,s2
    80005136:	e65ff0ef          	jal	80004f9a <fdalloc>
    8000513a:	84aa                	mv	s1,a0
    return -1;
    8000513c:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    8000513e:	00054d63          	bltz	a0,80005158 <sys_dup+0x46>
  filedup(f);
    80005142:	854a                	mv	a0,s2
    80005144:	c3eff0ef          	jal	80004582 <filedup>
  return fd;
    80005148:	87a6                	mv	a5,s1
    8000514a:	64e2                	ld	s1,24(sp)
    8000514c:	6942                	ld	s2,16(sp)
}
    8000514e:	853e                	mv	a0,a5
    80005150:	70a2                	ld	ra,40(sp)
    80005152:	7402                	ld	s0,32(sp)
    80005154:	6145                	addi	sp,sp,48
    80005156:	8082                	ret
    80005158:	64e2                	ld	s1,24(sp)
    8000515a:	6942                	ld	s2,16(sp)
    8000515c:	bfcd                	j	8000514e <sys_dup+0x3c>

000000008000515e <sys_read>:
{
    8000515e:	7179                	addi	sp,sp,-48
    80005160:	f406                	sd	ra,40(sp)
    80005162:	f022                	sd	s0,32(sp)
    80005164:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80005166:	fd840593          	addi	a1,s0,-40
    8000516a:	4505                	li	a0,1
    8000516c:	babfd0ef          	jal	80002d16 <argaddr>
  argint(2, &n);
    80005170:	fe440593          	addi	a1,s0,-28
    80005174:	4509                	li	a0,2
    80005176:	b85fd0ef          	jal	80002cfa <argint>
  if(argfd(0, 0, &f) < 0)
    8000517a:	fe840613          	addi	a2,s0,-24
    8000517e:	4581                	li	a1,0
    80005180:	4501                	li	a0,0
    80005182:	dc1ff0ef          	jal	80004f42 <argfd>
    80005186:	87aa                	mv	a5,a0
    return -1;
    80005188:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    8000518a:	0007ca63          	bltz	a5,8000519e <sys_read+0x40>
  return fileread(f, p, n);
    8000518e:	fe442603          	lw	a2,-28(s0)
    80005192:	fd843583          	ld	a1,-40(s0)
    80005196:	fe843503          	ld	a0,-24(s0)
    8000519a:	d4eff0ef          	jal	800046e8 <fileread>
}
    8000519e:	70a2                	ld	ra,40(sp)
    800051a0:	7402                	ld	s0,32(sp)
    800051a2:	6145                	addi	sp,sp,48
    800051a4:	8082                	ret

00000000800051a6 <sys_write>:
{
    800051a6:	7179                	addi	sp,sp,-48
    800051a8:	f406                	sd	ra,40(sp)
    800051aa:	f022                	sd	s0,32(sp)
    800051ac:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    800051ae:	fd840593          	addi	a1,s0,-40
    800051b2:	4505                	li	a0,1
    800051b4:	b63fd0ef          	jal	80002d16 <argaddr>
  argint(2, &n);
    800051b8:	fe440593          	addi	a1,s0,-28
    800051bc:	4509                	li	a0,2
    800051be:	b3dfd0ef          	jal	80002cfa <argint>
  if(argfd(0, 0, &f) < 0)
    800051c2:	fe840613          	addi	a2,s0,-24
    800051c6:	4581                	li	a1,0
    800051c8:	4501                	li	a0,0
    800051ca:	d79ff0ef          	jal	80004f42 <argfd>
    800051ce:	87aa                	mv	a5,a0
    return -1;
    800051d0:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    800051d2:	0007ca63          	bltz	a5,800051e6 <sys_write+0x40>
  return filewrite(f, p, n);
    800051d6:	fe442603          	lw	a2,-28(s0)
    800051da:	fd843583          	ld	a1,-40(s0)
    800051de:	fe843503          	ld	a0,-24(s0)
    800051e2:	dc4ff0ef          	jal	800047a6 <filewrite>
}
    800051e6:	70a2                	ld	ra,40(sp)
    800051e8:	7402                	ld	s0,32(sp)
    800051ea:	6145                	addi	sp,sp,48
    800051ec:	8082                	ret

00000000800051ee <sys_close>:
{
    800051ee:	1101                	addi	sp,sp,-32
    800051f0:	ec06                	sd	ra,24(sp)
    800051f2:	e822                	sd	s0,16(sp)
    800051f4:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    800051f6:	fe040613          	addi	a2,s0,-32
    800051fa:	fec40593          	addi	a1,s0,-20
    800051fe:	4501                	li	a0,0
    80005200:	d43ff0ef          	jal	80004f42 <argfd>
    return -1;
    80005204:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    80005206:	02054063          	bltz	a0,80005226 <sys_close+0x38>
  myproc()->ofile[fd] = 0;
    8000520a:	9c9fc0ef          	jal	80001bd2 <myproc>
    8000520e:	fec42783          	lw	a5,-20(s0)
    80005212:	07e9                	addi	a5,a5,26
    80005214:	078e                	slli	a5,a5,0x3
    80005216:	953e                	add	a0,a0,a5
    80005218:	00053023          	sd	zero,0(a0)
  fileclose(f);
    8000521c:	fe043503          	ld	a0,-32(s0)
    80005220:	ba8ff0ef          	jal	800045c8 <fileclose>
  return 0;
    80005224:	4781                	li	a5,0
}
    80005226:	853e                	mv	a0,a5
    80005228:	60e2                	ld	ra,24(sp)
    8000522a:	6442                	ld	s0,16(sp)
    8000522c:	6105                	addi	sp,sp,32
    8000522e:	8082                	ret

0000000080005230 <sys_fstat>:
{
    80005230:	1101                	addi	sp,sp,-32
    80005232:	ec06                	sd	ra,24(sp)
    80005234:	e822                	sd	s0,16(sp)
    80005236:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    80005238:	fe040593          	addi	a1,s0,-32
    8000523c:	4505                	li	a0,1
    8000523e:	ad9fd0ef          	jal	80002d16 <argaddr>
  if(argfd(0, 0, &f) < 0)
    80005242:	fe840613          	addi	a2,s0,-24
    80005246:	4581                	li	a1,0
    80005248:	4501                	li	a0,0
    8000524a:	cf9ff0ef          	jal	80004f42 <argfd>
    8000524e:	87aa                	mv	a5,a0
    return -1;
    80005250:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80005252:	0007c863          	bltz	a5,80005262 <sys_fstat+0x32>
  return filestat(f, st);
    80005256:	fe043583          	ld	a1,-32(s0)
    8000525a:	fe843503          	ld	a0,-24(s0)
    8000525e:	c2cff0ef          	jal	8000468a <filestat>
}
    80005262:	60e2                	ld	ra,24(sp)
    80005264:	6442                	ld	s0,16(sp)
    80005266:	6105                	addi	sp,sp,32
    80005268:	8082                	ret

000000008000526a <sys_link>:
{
    8000526a:	7169                	addi	sp,sp,-304
    8000526c:	f606                	sd	ra,296(sp)
    8000526e:	f222                	sd	s0,288(sp)
    80005270:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005272:	08000613          	li	a2,128
    80005276:	ed040593          	addi	a1,s0,-304
    8000527a:	4501                	li	a0,0
    8000527c:	ab7fd0ef          	jal	80002d32 <argstr>
    return -1;
    80005280:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005282:	0c054e63          	bltz	a0,8000535e <sys_link+0xf4>
    80005286:	08000613          	li	a2,128
    8000528a:	f5040593          	addi	a1,s0,-176
    8000528e:	4505                	li	a0,1
    80005290:	aa3fd0ef          	jal	80002d32 <argstr>
    return -1;
    80005294:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005296:	0c054463          	bltz	a0,8000535e <sys_link+0xf4>
    8000529a:	ee26                	sd	s1,280(sp)
  begin_op();
    8000529c:	f21fe0ef          	jal	800041bc <begin_op>
  if((ip = namei(old)) == 0){
    800052a0:	ed040513          	addi	a0,s0,-304
    800052a4:	d45fe0ef          	jal	80003fe8 <namei>
    800052a8:	84aa                	mv	s1,a0
    800052aa:	c53d                	beqz	a0,80005318 <sys_link+0xae>
  ilock(ip);
    800052ac:	d26fe0ef          	jal	800037d2 <ilock>
  if(ip->type == T_DIR){
    800052b0:	04449703          	lh	a4,68(s1)
    800052b4:	4785                	li	a5,1
    800052b6:	06f70663          	beq	a4,a5,80005322 <sys_link+0xb8>
    800052ba:	ea4a                	sd	s2,272(sp)
  ip->nlink++;
    800052bc:	04a4d783          	lhu	a5,74(s1)
    800052c0:	2785                	addiw	a5,a5,1
    800052c2:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    800052c6:	8526                	mv	a0,s1
    800052c8:	c56fe0ef          	jal	8000371e <iupdate>
  iunlock(ip);
    800052cc:	8526                	mv	a0,s1
    800052ce:	db2fe0ef          	jal	80003880 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    800052d2:	fd040593          	addi	a1,s0,-48
    800052d6:	f5040513          	addi	a0,s0,-176
    800052da:	d29fe0ef          	jal	80004002 <nameiparent>
    800052de:	892a                	mv	s2,a0
    800052e0:	cd21                	beqz	a0,80005338 <sys_link+0xce>
  ilock(dp);
    800052e2:	cf0fe0ef          	jal	800037d2 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    800052e6:	00092703          	lw	a4,0(s2)
    800052ea:	409c                	lw	a5,0(s1)
    800052ec:	04f71363          	bne	a4,a5,80005332 <sys_link+0xc8>
    800052f0:	40d0                	lw	a2,4(s1)
    800052f2:	fd040593          	addi	a1,s0,-48
    800052f6:	854a                	mv	a0,s2
    800052f8:	c57fe0ef          	jal	80003f4e <dirlink>
    800052fc:	02054b63          	bltz	a0,80005332 <sys_link+0xc8>
  iunlockput(dp);
    80005300:	854a                	mv	a0,s2
    80005302:	edafe0ef          	jal	800039dc <iunlockput>
  iput(ip);
    80005306:	8526                	mv	a0,s1
    80005308:	e4cfe0ef          	jal	80003954 <iput>
  end_op();
    8000530c:	f1bfe0ef          	jal	80004226 <end_op>
  return 0;
    80005310:	4781                	li	a5,0
    80005312:	64f2                	ld	s1,280(sp)
    80005314:	6952                	ld	s2,272(sp)
    80005316:	a0a1                	j	8000535e <sys_link+0xf4>
    end_op();
    80005318:	f0ffe0ef          	jal	80004226 <end_op>
    return -1;
    8000531c:	57fd                	li	a5,-1
    8000531e:	64f2                	ld	s1,280(sp)
    80005320:	a83d                	j	8000535e <sys_link+0xf4>
    iunlockput(ip);
    80005322:	8526                	mv	a0,s1
    80005324:	eb8fe0ef          	jal	800039dc <iunlockput>
    end_op();
    80005328:	efffe0ef          	jal	80004226 <end_op>
    return -1;
    8000532c:	57fd                	li	a5,-1
    8000532e:	64f2                	ld	s1,280(sp)
    80005330:	a03d                	j	8000535e <sys_link+0xf4>
    iunlockput(dp);
    80005332:	854a                	mv	a0,s2
    80005334:	ea8fe0ef          	jal	800039dc <iunlockput>
  ilock(ip);
    80005338:	8526                	mv	a0,s1
    8000533a:	c98fe0ef          	jal	800037d2 <ilock>
  ip->nlink--;
    8000533e:	04a4d783          	lhu	a5,74(s1)
    80005342:	37fd                	addiw	a5,a5,-1
    80005344:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005348:	8526                	mv	a0,s1
    8000534a:	bd4fe0ef          	jal	8000371e <iupdate>
  iunlockput(ip);
    8000534e:	8526                	mv	a0,s1
    80005350:	e8cfe0ef          	jal	800039dc <iunlockput>
  end_op();
    80005354:	ed3fe0ef          	jal	80004226 <end_op>
  return -1;
    80005358:	57fd                	li	a5,-1
    8000535a:	64f2                	ld	s1,280(sp)
    8000535c:	6952                	ld	s2,272(sp)
}
    8000535e:	853e                	mv	a0,a5
    80005360:	70b2                	ld	ra,296(sp)
    80005362:	7412                	ld	s0,288(sp)
    80005364:	6155                	addi	sp,sp,304
    80005366:	8082                	ret

0000000080005368 <sys_unlink>:
{
    80005368:	7151                	addi	sp,sp,-240
    8000536a:	f586                	sd	ra,232(sp)
    8000536c:	f1a2                	sd	s0,224(sp)
    8000536e:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    80005370:	08000613          	li	a2,128
    80005374:	f3040593          	addi	a1,s0,-208
    80005378:	4501                	li	a0,0
    8000537a:	9b9fd0ef          	jal	80002d32 <argstr>
    8000537e:	16054063          	bltz	a0,800054de <sys_unlink+0x176>
    80005382:	eda6                	sd	s1,216(sp)
  begin_op();
    80005384:	e39fe0ef          	jal	800041bc <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    80005388:	fb040593          	addi	a1,s0,-80
    8000538c:	f3040513          	addi	a0,s0,-208
    80005390:	c73fe0ef          	jal	80004002 <nameiparent>
    80005394:	84aa                	mv	s1,a0
    80005396:	c945                	beqz	a0,80005446 <sys_unlink+0xde>
  ilock(dp);
    80005398:	c3afe0ef          	jal	800037d2 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    8000539c:	00003597          	auipc	a1,0x3
    800053a0:	25c58593          	addi	a1,a1,604 # 800085f8 <etext+0x5f8>
    800053a4:	fb040513          	addi	a0,s0,-80
    800053a8:	9c5fe0ef          	jal	80003d6c <namecmp>
    800053ac:	10050e63          	beqz	a0,800054c8 <sys_unlink+0x160>
    800053b0:	00003597          	auipc	a1,0x3
    800053b4:	25058593          	addi	a1,a1,592 # 80008600 <etext+0x600>
    800053b8:	fb040513          	addi	a0,s0,-80
    800053bc:	9b1fe0ef          	jal	80003d6c <namecmp>
    800053c0:	10050463          	beqz	a0,800054c8 <sys_unlink+0x160>
    800053c4:	e9ca                	sd	s2,208(sp)
  if((ip = dirlookup(dp, name, &off)) == 0)
    800053c6:	f2c40613          	addi	a2,s0,-212
    800053ca:	fb040593          	addi	a1,s0,-80
    800053ce:	8526                	mv	a0,s1
    800053d0:	9b3fe0ef          	jal	80003d82 <dirlookup>
    800053d4:	892a                	mv	s2,a0
    800053d6:	0e050863          	beqz	a0,800054c6 <sys_unlink+0x15e>
  ilock(ip);
    800053da:	bf8fe0ef          	jal	800037d2 <ilock>
  if(ip->nlink < 1)
    800053de:	04a91783          	lh	a5,74(s2)
    800053e2:	06f05763          	blez	a5,80005450 <sys_unlink+0xe8>
  if(ip->type == T_DIR && !isdirempty(ip)){
    800053e6:	04491703          	lh	a4,68(s2)
    800053ea:	4785                	li	a5,1
    800053ec:	06f70963          	beq	a4,a5,8000545e <sys_unlink+0xf6>
  memset(&de, 0, sizeof(de));
    800053f0:	4641                	li	a2,16
    800053f2:	4581                	li	a1,0
    800053f4:	fc040513          	addi	a0,s0,-64
    800053f8:	999fb0ef          	jal	80000d90 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800053fc:	4741                	li	a4,16
    800053fe:	f2c42683          	lw	a3,-212(s0)
    80005402:	fc040613          	addi	a2,s0,-64
    80005406:	4581                	li	a1,0
    80005408:	8526                	mv	a0,s1
    8000540a:	855fe0ef          	jal	80003c5e <writei>
    8000540e:	47c1                	li	a5,16
    80005410:	08f51b63          	bne	a0,a5,800054a6 <sys_unlink+0x13e>
  if(ip->type == T_DIR){
    80005414:	04491703          	lh	a4,68(s2)
    80005418:	4785                	li	a5,1
    8000541a:	08f70d63          	beq	a4,a5,800054b4 <sys_unlink+0x14c>
  iunlockput(dp);
    8000541e:	8526                	mv	a0,s1
    80005420:	dbcfe0ef          	jal	800039dc <iunlockput>
  ip->nlink--;
    80005424:	04a95783          	lhu	a5,74(s2)
    80005428:	37fd                	addiw	a5,a5,-1
    8000542a:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    8000542e:	854a                	mv	a0,s2
    80005430:	aeefe0ef          	jal	8000371e <iupdate>
  iunlockput(ip);
    80005434:	854a                	mv	a0,s2
    80005436:	da6fe0ef          	jal	800039dc <iunlockput>
  end_op();
    8000543a:	dedfe0ef          	jal	80004226 <end_op>
  return 0;
    8000543e:	4501                	li	a0,0
    80005440:	64ee                	ld	s1,216(sp)
    80005442:	694e                	ld	s2,208(sp)
    80005444:	a849                	j	800054d6 <sys_unlink+0x16e>
    end_op();
    80005446:	de1fe0ef          	jal	80004226 <end_op>
    return -1;
    8000544a:	557d                	li	a0,-1
    8000544c:	64ee                	ld	s1,216(sp)
    8000544e:	a061                	j	800054d6 <sys_unlink+0x16e>
    80005450:	e5ce                	sd	s3,200(sp)
    panic("unlink: nlink < 1");
    80005452:	00003517          	auipc	a0,0x3
    80005456:	1b650513          	addi	a0,a0,438 # 80008608 <etext+0x608>
    8000545a:	bb8fb0ef          	jal	80000812 <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    8000545e:	04c92703          	lw	a4,76(s2)
    80005462:	02000793          	li	a5,32
    80005466:	f8e7f5e3          	bgeu	a5,a4,800053f0 <sys_unlink+0x88>
    8000546a:	e5ce                	sd	s3,200(sp)
    8000546c:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005470:	4741                	li	a4,16
    80005472:	86ce                	mv	a3,s3
    80005474:	f1840613          	addi	a2,s0,-232
    80005478:	4581                	li	a1,0
    8000547a:	854a                	mv	a0,s2
    8000547c:	ee6fe0ef          	jal	80003b62 <readi>
    80005480:	47c1                	li	a5,16
    80005482:	00f51c63          	bne	a0,a5,8000549a <sys_unlink+0x132>
    if(de.inum != 0)
    80005486:	f1845783          	lhu	a5,-232(s0)
    8000548a:	efa1                	bnez	a5,800054e2 <sys_unlink+0x17a>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    8000548c:	29c1                	addiw	s3,s3,16
    8000548e:	04c92783          	lw	a5,76(s2)
    80005492:	fcf9efe3          	bltu	s3,a5,80005470 <sys_unlink+0x108>
    80005496:	69ae                	ld	s3,200(sp)
    80005498:	bfa1                	j	800053f0 <sys_unlink+0x88>
      panic("isdirempty: readi");
    8000549a:	00003517          	auipc	a0,0x3
    8000549e:	18650513          	addi	a0,a0,390 # 80008620 <etext+0x620>
    800054a2:	b70fb0ef          	jal	80000812 <panic>
    800054a6:	e5ce                	sd	s3,200(sp)
    panic("unlink: writei");
    800054a8:	00003517          	auipc	a0,0x3
    800054ac:	19050513          	addi	a0,a0,400 # 80008638 <etext+0x638>
    800054b0:	b62fb0ef          	jal	80000812 <panic>
    dp->nlink--;
    800054b4:	04a4d783          	lhu	a5,74(s1)
    800054b8:	37fd                	addiw	a5,a5,-1
    800054ba:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    800054be:	8526                	mv	a0,s1
    800054c0:	a5efe0ef          	jal	8000371e <iupdate>
    800054c4:	bfa9                	j	8000541e <sys_unlink+0xb6>
    800054c6:	694e                	ld	s2,208(sp)
  iunlockput(dp);
    800054c8:	8526                	mv	a0,s1
    800054ca:	d12fe0ef          	jal	800039dc <iunlockput>
  end_op();
    800054ce:	d59fe0ef          	jal	80004226 <end_op>
  return -1;
    800054d2:	557d                	li	a0,-1
    800054d4:	64ee                	ld	s1,216(sp)
}
    800054d6:	70ae                	ld	ra,232(sp)
    800054d8:	740e                	ld	s0,224(sp)
    800054da:	616d                	addi	sp,sp,240
    800054dc:	8082                	ret
    return -1;
    800054de:	557d                	li	a0,-1
    800054e0:	bfdd                	j	800054d6 <sys_unlink+0x16e>
    iunlockput(ip);
    800054e2:	854a                	mv	a0,s2
    800054e4:	cf8fe0ef          	jal	800039dc <iunlockput>
    goto bad;
    800054e8:	694e                	ld	s2,208(sp)
    800054ea:	69ae                	ld	s3,200(sp)
    800054ec:	bff1                	j	800054c8 <sys_unlink+0x160>

00000000800054ee <sys_open>:

uint64
sys_open(void)
{
    800054ee:	7131                	addi	sp,sp,-192
    800054f0:	fd06                	sd	ra,184(sp)
    800054f2:	f922                	sd	s0,176(sp)
    800054f4:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    800054f6:	f4c40593          	addi	a1,s0,-180
    800054fa:	4505                	li	a0,1
    800054fc:	ffefd0ef          	jal	80002cfa <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    80005500:	08000613          	li	a2,128
    80005504:	f5040593          	addi	a1,s0,-176
    80005508:	4501                	li	a0,0
    8000550a:	829fd0ef          	jal	80002d32 <argstr>
    8000550e:	87aa                	mv	a5,a0
    return -1;
    80005510:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    80005512:	0a07c263          	bltz	a5,800055b6 <sys_open+0xc8>
    80005516:	f526                	sd	s1,168(sp)

  begin_op();
    80005518:	ca5fe0ef          	jal	800041bc <begin_op>

  if(omode & O_CREATE){
    8000551c:	f4c42783          	lw	a5,-180(s0)
    80005520:	2007f793          	andi	a5,a5,512
    80005524:	c3d5                	beqz	a5,800055c8 <sys_open+0xda>
    ip = create(path, T_FILE, 0, 0);
    80005526:	4681                	li	a3,0
    80005528:	4601                	li	a2,0
    8000552a:	4589                	li	a1,2
    8000552c:	f5040513          	addi	a0,s0,-176
    80005530:	aa9ff0ef          	jal	80004fd8 <create>
    80005534:	84aa                	mv	s1,a0
    if(ip == 0){
    80005536:	c541                	beqz	a0,800055be <sys_open+0xd0>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    80005538:	04449703          	lh	a4,68(s1)
    8000553c:	478d                	li	a5,3
    8000553e:	00f71763          	bne	a4,a5,8000554c <sys_open+0x5e>
    80005542:	0464d703          	lhu	a4,70(s1)
    80005546:	47a5                	li	a5,9
    80005548:	0ae7ed63          	bltu	a5,a4,80005602 <sys_open+0x114>
    8000554c:	f14a                	sd	s2,160(sp)
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    8000554e:	fd7fe0ef          	jal	80004524 <filealloc>
    80005552:	892a                	mv	s2,a0
    80005554:	c179                	beqz	a0,8000561a <sys_open+0x12c>
    80005556:	ed4e                	sd	s3,152(sp)
    80005558:	a43ff0ef          	jal	80004f9a <fdalloc>
    8000555c:	89aa                	mv	s3,a0
    8000555e:	0a054a63          	bltz	a0,80005612 <sys_open+0x124>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    80005562:	04449703          	lh	a4,68(s1)
    80005566:	478d                	li	a5,3
    80005568:	0cf70263          	beq	a4,a5,8000562c <sys_open+0x13e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    8000556c:	4789                	li	a5,2
    8000556e:	00f92023          	sw	a5,0(s2)
    f->off = 0;
    80005572:	02092023          	sw	zero,32(s2)
  }
  f->ip = ip;
    80005576:	00993c23          	sd	s1,24(s2)
  f->readable = !(omode & O_WRONLY);
    8000557a:	f4c42783          	lw	a5,-180(s0)
    8000557e:	0017c713          	xori	a4,a5,1
    80005582:	8b05                	andi	a4,a4,1
    80005584:	00e90423          	sb	a4,8(s2)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80005588:	0037f713          	andi	a4,a5,3
    8000558c:	00e03733          	snez	a4,a4
    80005590:	00e904a3          	sb	a4,9(s2)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    80005594:	4007f793          	andi	a5,a5,1024
    80005598:	c791                	beqz	a5,800055a4 <sys_open+0xb6>
    8000559a:	04449703          	lh	a4,68(s1)
    8000559e:	4789                	li	a5,2
    800055a0:	08f70d63          	beq	a4,a5,8000563a <sys_open+0x14c>
    itrunc(ip);
  }

  iunlock(ip);
    800055a4:	8526                	mv	a0,s1
    800055a6:	adafe0ef          	jal	80003880 <iunlock>
  end_op();
    800055aa:	c7dfe0ef          	jal	80004226 <end_op>

  return fd;
    800055ae:	854e                	mv	a0,s3
    800055b0:	74aa                	ld	s1,168(sp)
    800055b2:	790a                	ld	s2,160(sp)
    800055b4:	69ea                	ld	s3,152(sp)
}
    800055b6:	70ea                	ld	ra,184(sp)
    800055b8:	744a                	ld	s0,176(sp)
    800055ba:	6129                	addi	sp,sp,192
    800055bc:	8082                	ret
      end_op();
    800055be:	c69fe0ef          	jal	80004226 <end_op>
      return -1;
    800055c2:	557d                	li	a0,-1
    800055c4:	74aa                	ld	s1,168(sp)
    800055c6:	bfc5                	j	800055b6 <sys_open+0xc8>
    if((ip = namei(path)) == 0){
    800055c8:	f5040513          	addi	a0,s0,-176
    800055cc:	a1dfe0ef          	jal	80003fe8 <namei>
    800055d0:	84aa                	mv	s1,a0
    800055d2:	c11d                	beqz	a0,800055f8 <sys_open+0x10a>
    ilock(ip);
    800055d4:	9fefe0ef          	jal	800037d2 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    800055d8:	04449703          	lh	a4,68(s1)
    800055dc:	4785                	li	a5,1
    800055de:	f4f71de3          	bne	a4,a5,80005538 <sys_open+0x4a>
    800055e2:	f4c42783          	lw	a5,-180(s0)
    800055e6:	d3bd                	beqz	a5,8000554c <sys_open+0x5e>
      iunlockput(ip);
    800055e8:	8526                	mv	a0,s1
    800055ea:	bf2fe0ef          	jal	800039dc <iunlockput>
      end_op();
    800055ee:	c39fe0ef          	jal	80004226 <end_op>
      return -1;
    800055f2:	557d                	li	a0,-1
    800055f4:	74aa                	ld	s1,168(sp)
    800055f6:	b7c1                	j	800055b6 <sys_open+0xc8>
      end_op();
    800055f8:	c2ffe0ef          	jal	80004226 <end_op>
      return -1;
    800055fc:	557d                	li	a0,-1
    800055fe:	74aa                	ld	s1,168(sp)
    80005600:	bf5d                	j	800055b6 <sys_open+0xc8>
    iunlockput(ip);
    80005602:	8526                	mv	a0,s1
    80005604:	bd8fe0ef          	jal	800039dc <iunlockput>
    end_op();
    80005608:	c1ffe0ef          	jal	80004226 <end_op>
    return -1;
    8000560c:	557d                	li	a0,-1
    8000560e:	74aa                	ld	s1,168(sp)
    80005610:	b75d                	j	800055b6 <sys_open+0xc8>
      fileclose(f);
    80005612:	854a                	mv	a0,s2
    80005614:	fb5fe0ef          	jal	800045c8 <fileclose>
    80005618:	69ea                	ld	s3,152(sp)
    iunlockput(ip);
    8000561a:	8526                	mv	a0,s1
    8000561c:	bc0fe0ef          	jal	800039dc <iunlockput>
    end_op();
    80005620:	c07fe0ef          	jal	80004226 <end_op>
    return -1;
    80005624:	557d                	li	a0,-1
    80005626:	74aa                	ld	s1,168(sp)
    80005628:	790a                	ld	s2,160(sp)
    8000562a:	b771                	j	800055b6 <sys_open+0xc8>
    f->type = FD_DEVICE;
    8000562c:	00f92023          	sw	a5,0(s2)
    f->major = ip->major;
    80005630:	04649783          	lh	a5,70(s1)
    80005634:	02f91223          	sh	a5,36(s2)
    80005638:	bf3d                	j	80005576 <sys_open+0x88>
    itrunc(ip);
    8000563a:	8526                	mv	a0,s1
    8000563c:	a84fe0ef          	jal	800038c0 <itrunc>
    80005640:	b795                	j	800055a4 <sys_open+0xb6>

0000000080005642 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80005642:	7175                	addi	sp,sp,-144
    80005644:	e506                	sd	ra,136(sp)
    80005646:	e122                	sd	s0,128(sp)
    80005648:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    8000564a:	b73fe0ef          	jal	800041bc <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    8000564e:	08000613          	li	a2,128
    80005652:	f7040593          	addi	a1,s0,-144
    80005656:	4501                	li	a0,0
    80005658:	edafd0ef          	jal	80002d32 <argstr>
    8000565c:	02054363          	bltz	a0,80005682 <sys_mkdir+0x40>
    80005660:	4681                	li	a3,0
    80005662:	4601                	li	a2,0
    80005664:	4585                	li	a1,1
    80005666:	f7040513          	addi	a0,s0,-144
    8000566a:	96fff0ef          	jal	80004fd8 <create>
    8000566e:	c911                	beqz	a0,80005682 <sys_mkdir+0x40>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005670:	b6cfe0ef          	jal	800039dc <iunlockput>
  end_op();
    80005674:	bb3fe0ef          	jal	80004226 <end_op>
  return 0;
    80005678:	4501                	li	a0,0
}
    8000567a:	60aa                	ld	ra,136(sp)
    8000567c:	640a                	ld	s0,128(sp)
    8000567e:	6149                	addi	sp,sp,144
    80005680:	8082                	ret
    end_op();
    80005682:	ba5fe0ef          	jal	80004226 <end_op>
    return -1;
    80005686:	557d                	li	a0,-1
    80005688:	bfcd                	j	8000567a <sys_mkdir+0x38>

000000008000568a <sys_mknod>:

uint64
sys_mknod(void)
{
    8000568a:	7135                	addi	sp,sp,-160
    8000568c:	ed06                	sd	ra,152(sp)
    8000568e:	e922                	sd	s0,144(sp)
    80005690:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80005692:	b2bfe0ef          	jal	800041bc <begin_op>
  argint(1, &major);
    80005696:	f6c40593          	addi	a1,s0,-148
    8000569a:	4505                	li	a0,1
    8000569c:	e5efd0ef          	jal	80002cfa <argint>
  argint(2, &minor);
    800056a0:	f6840593          	addi	a1,s0,-152
    800056a4:	4509                	li	a0,2
    800056a6:	e54fd0ef          	jal	80002cfa <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    800056aa:	08000613          	li	a2,128
    800056ae:	f7040593          	addi	a1,s0,-144
    800056b2:	4501                	li	a0,0
    800056b4:	e7efd0ef          	jal	80002d32 <argstr>
    800056b8:	02054563          	bltz	a0,800056e2 <sys_mknod+0x58>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    800056bc:	f6841683          	lh	a3,-152(s0)
    800056c0:	f6c41603          	lh	a2,-148(s0)
    800056c4:	458d                	li	a1,3
    800056c6:	f7040513          	addi	a0,s0,-144
    800056ca:	90fff0ef          	jal	80004fd8 <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    800056ce:	c911                	beqz	a0,800056e2 <sys_mknod+0x58>
    end_op();
    return -1;
  }
  iunlockput(ip);
    800056d0:	b0cfe0ef          	jal	800039dc <iunlockput>
  end_op();
    800056d4:	b53fe0ef          	jal	80004226 <end_op>
  return 0;
    800056d8:	4501                	li	a0,0
}
    800056da:	60ea                	ld	ra,152(sp)
    800056dc:	644a                	ld	s0,144(sp)
    800056de:	610d                	addi	sp,sp,160
    800056e0:	8082                	ret
    end_op();
    800056e2:	b45fe0ef          	jal	80004226 <end_op>
    return -1;
    800056e6:	557d                	li	a0,-1
    800056e8:	bfcd                	j	800056da <sys_mknod+0x50>

00000000800056ea <sys_chdir>:

uint64
sys_chdir(void)
{
    800056ea:	7135                	addi	sp,sp,-160
    800056ec:	ed06                	sd	ra,152(sp)
    800056ee:	e922                	sd	s0,144(sp)
    800056f0:	e14a                	sd	s2,128(sp)
    800056f2:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    800056f4:	cdefc0ef          	jal	80001bd2 <myproc>
    800056f8:	892a                	mv	s2,a0
  
  begin_op();
    800056fa:	ac3fe0ef          	jal	800041bc <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    800056fe:	08000613          	li	a2,128
    80005702:	f6040593          	addi	a1,s0,-160
    80005706:	4501                	li	a0,0
    80005708:	e2afd0ef          	jal	80002d32 <argstr>
    8000570c:	04054363          	bltz	a0,80005752 <sys_chdir+0x68>
    80005710:	e526                	sd	s1,136(sp)
    80005712:	f6040513          	addi	a0,s0,-160
    80005716:	8d3fe0ef          	jal	80003fe8 <namei>
    8000571a:	84aa                	mv	s1,a0
    8000571c:	c915                	beqz	a0,80005750 <sys_chdir+0x66>
    end_op();
    return -1;
  }
  ilock(ip);
    8000571e:	8b4fe0ef          	jal	800037d2 <ilock>
  if(ip->type != T_DIR){
    80005722:	04449703          	lh	a4,68(s1)
    80005726:	4785                	li	a5,1
    80005728:	02f71963          	bne	a4,a5,8000575a <sys_chdir+0x70>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    8000572c:	8526                	mv	a0,s1
    8000572e:	952fe0ef          	jal	80003880 <iunlock>
  iput(p->cwd);
    80005732:	15093503          	ld	a0,336(s2)
    80005736:	a1efe0ef          	jal	80003954 <iput>
  end_op();
    8000573a:	aedfe0ef          	jal	80004226 <end_op>
  p->cwd = ip;
    8000573e:	14993823          	sd	s1,336(s2)
  return 0;
    80005742:	4501                	li	a0,0
    80005744:	64aa                	ld	s1,136(sp)
}
    80005746:	60ea                	ld	ra,152(sp)
    80005748:	644a                	ld	s0,144(sp)
    8000574a:	690a                	ld	s2,128(sp)
    8000574c:	610d                	addi	sp,sp,160
    8000574e:	8082                	ret
    80005750:	64aa                	ld	s1,136(sp)
    end_op();
    80005752:	ad5fe0ef          	jal	80004226 <end_op>
    return -1;
    80005756:	557d                	li	a0,-1
    80005758:	b7fd                	j	80005746 <sys_chdir+0x5c>
    iunlockput(ip);
    8000575a:	8526                	mv	a0,s1
    8000575c:	a80fe0ef          	jal	800039dc <iunlockput>
    end_op();
    80005760:	ac7fe0ef          	jal	80004226 <end_op>
    return -1;
    80005764:	557d                	li	a0,-1
    80005766:	64aa                	ld	s1,136(sp)
    80005768:	bff9                	j	80005746 <sys_chdir+0x5c>

000000008000576a <sys_exec>:

uint64
sys_exec(void)
{
    8000576a:	7121                	addi	sp,sp,-448
    8000576c:	ff06                	sd	ra,440(sp)
    8000576e:	fb22                	sd	s0,432(sp)
    80005770:	0380                	addi	s0,sp,448
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    80005772:	e4840593          	addi	a1,s0,-440
    80005776:	4505                	li	a0,1
    80005778:	d9efd0ef          	jal	80002d16 <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    8000577c:	08000613          	li	a2,128
    80005780:	f5040593          	addi	a1,s0,-176
    80005784:	4501                	li	a0,0
    80005786:	dacfd0ef          	jal	80002d32 <argstr>
    8000578a:	87aa                	mv	a5,a0
    return -1;
    8000578c:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    8000578e:	0c07c463          	bltz	a5,80005856 <sys_exec+0xec>
    80005792:	f726                	sd	s1,424(sp)
    80005794:	f34a                	sd	s2,416(sp)
    80005796:	ef4e                	sd	s3,408(sp)
    80005798:	eb52                	sd	s4,400(sp)
  }
  memset(argv, 0, sizeof(argv));
    8000579a:	10000613          	li	a2,256
    8000579e:	4581                	li	a1,0
    800057a0:	e5040513          	addi	a0,s0,-432
    800057a4:	decfb0ef          	jal	80000d90 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    800057a8:	e5040493          	addi	s1,s0,-432
  memset(argv, 0, sizeof(argv));
    800057ac:	89a6                	mv	s3,s1
    800057ae:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    800057b0:	02000a13          	li	s4,32
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    800057b4:	00391513          	slli	a0,s2,0x3
    800057b8:	e4040593          	addi	a1,s0,-448
    800057bc:	e4843783          	ld	a5,-440(s0)
    800057c0:	953e                	add	a0,a0,a5
    800057c2:	caefd0ef          	jal	80002c70 <fetchaddr>
    800057c6:	02054663          	bltz	a0,800057f2 <sys_exec+0x88>
      goto bad;
    }
    if(uarg == 0){
    800057ca:	e4043783          	ld	a5,-448(s0)
    800057ce:	c3a9                	beqz	a5,80005810 <sys_exec+0xa6>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    800057d0:	bbefb0ef          	jal	80000b8e <kalloc>
    800057d4:	85aa                	mv	a1,a0
    800057d6:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    800057da:	cd01                	beqz	a0,800057f2 <sys_exec+0x88>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    800057dc:	6605                	lui	a2,0x1
    800057de:	e4043503          	ld	a0,-448(s0)
    800057e2:	cd8fd0ef          	jal	80002cba <fetchstr>
    800057e6:	00054663          	bltz	a0,800057f2 <sys_exec+0x88>
    if(i >= NELEM(argv)){
    800057ea:	0905                	addi	s2,s2,1
    800057ec:	09a1                	addi	s3,s3,8
    800057ee:	fd4913e3          	bne	s2,s4,800057b4 <sys_exec+0x4a>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800057f2:	f5040913          	addi	s2,s0,-176
    800057f6:	6088                	ld	a0,0(s1)
    800057f8:	c931                	beqz	a0,8000584c <sys_exec+0xe2>
    kfree(argv[i]);
    800057fa:	a54fb0ef          	jal	80000a4e <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800057fe:	04a1                	addi	s1,s1,8
    80005800:	ff249be3          	bne	s1,s2,800057f6 <sys_exec+0x8c>
  return -1;
    80005804:	557d                	li	a0,-1
    80005806:	74ba                	ld	s1,424(sp)
    80005808:	791a                	ld	s2,416(sp)
    8000580a:	69fa                	ld	s3,408(sp)
    8000580c:	6a5a                	ld	s4,400(sp)
    8000580e:	a0a1                	j	80005856 <sys_exec+0xec>
      argv[i] = 0;
    80005810:	0009079b          	sext.w	a5,s2
    80005814:	078e                	slli	a5,a5,0x3
    80005816:	fd078793          	addi	a5,a5,-48
    8000581a:	97a2                	add	a5,a5,s0
    8000581c:	e807b023          	sd	zero,-384(a5)
  int ret = kexec(path, argv);
    80005820:	e5040593          	addi	a1,s0,-432
    80005824:	f5040513          	addi	a0,s0,-176
    80005828:	ba8ff0ef          	jal	80004bd0 <kexec>
    8000582c:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    8000582e:	f5040993          	addi	s3,s0,-176
    80005832:	6088                	ld	a0,0(s1)
    80005834:	c511                	beqz	a0,80005840 <sys_exec+0xd6>
    kfree(argv[i]);
    80005836:	a18fb0ef          	jal	80000a4e <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    8000583a:	04a1                	addi	s1,s1,8
    8000583c:	ff349be3          	bne	s1,s3,80005832 <sys_exec+0xc8>
  return ret;
    80005840:	854a                	mv	a0,s2
    80005842:	74ba                	ld	s1,424(sp)
    80005844:	791a                	ld	s2,416(sp)
    80005846:	69fa                	ld	s3,408(sp)
    80005848:	6a5a                	ld	s4,400(sp)
    8000584a:	a031                	j	80005856 <sys_exec+0xec>
  return -1;
    8000584c:	557d                	li	a0,-1
    8000584e:	74ba                	ld	s1,424(sp)
    80005850:	791a                	ld	s2,416(sp)
    80005852:	69fa                	ld	s3,408(sp)
    80005854:	6a5a                	ld	s4,400(sp)
}
    80005856:	70fa                	ld	ra,440(sp)
    80005858:	745a                	ld	s0,432(sp)
    8000585a:	6139                	addi	sp,sp,448
    8000585c:	8082                	ret

000000008000585e <sys_pipe>:

uint64
sys_pipe(void)
{
    8000585e:	7139                	addi	sp,sp,-64
    80005860:	fc06                	sd	ra,56(sp)
    80005862:	f822                	sd	s0,48(sp)
    80005864:	f426                	sd	s1,40(sp)
    80005866:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80005868:	b6afc0ef          	jal	80001bd2 <myproc>
    8000586c:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    8000586e:	fd840593          	addi	a1,s0,-40
    80005872:	4501                	li	a0,0
    80005874:	ca2fd0ef          	jal	80002d16 <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    80005878:	fc840593          	addi	a1,s0,-56
    8000587c:	fd040513          	addi	a0,s0,-48
    80005880:	852ff0ef          	jal	800048d2 <pipealloc>
    return -1;
    80005884:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80005886:	0a054463          	bltz	a0,8000592e <sys_pipe+0xd0>
  fd0 = -1;
    8000588a:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    8000588e:	fd043503          	ld	a0,-48(s0)
    80005892:	f08ff0ef          	jal	80004f9a <fdalloc>
    80005896:	fca42223          	sw	a0,-60(s0)
    8000589a:	08054163          	bltz	a0,8000591c <sys_pipe+0xbe>
    8000589e:	fc843503          	ld	a0,-56(s0)
    800058a2:	ef8ff0ef          	jal	80004f9a <fdalloc>
    800058a6:	fca42023          	sw	a0,-64(s0)
    800058aa:	06054063          	bltz	a0,8000590a <sys_pipe+0xac>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    800058ae:	4691                	li	a3,4
    800058b0:	fc440613          	addi	a2,s0,-60
    800058b4:	fd843583          	ld	a1,-40(s0)
    800058b8:	68a8                	ld	a0,80(s1)
    800058ba:	818fc0ef          	jal	800018d2 <copyout>
    800058be:	00054e63          	bltz	a0,800058da <sys_pipe+0x7c>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    800058c2:	4691                	li	a3,4
    800058c4:	fc040613          	addi	a2,s0,-64
    800058c8:	fd843583          	ld	a1,-40(s0)
    800058cc:	0591                	addi	a1,a1,4
    800058ce:	68a8                	ld	a0,80(s1)
    800058d0:	802fc0ef          	jal	800018d2 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    800058d4:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    800058d6:	04055c63          	bgez	a0,8000592e <sys_pipe+0xd0>
    p->ofile[fd0] = 0;
    800058da:	fc442783          	lw	a5,-60(s0)
    800058de:	07e9                	addi	a5,a5,26
    800058e0:	078e                	slli	a5,a5,0x3
    800058e2:	97a6                	add	a5,a5,s1
    800058e4:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    800058e8:	fc042783          	lw	a5,-64(s0)
    800058ec:	07e9                	addi	a5,a5,26
    800058ee:	078e                	slli	a5,a5,0x3
    800058f0:	94be                	add	s1,s1,a5
    800058f2:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    800058f6:	fd043503          	ld	a0,-48(s0)
    800058fa:	ccffe0ef          	jal	800045c8 <fileclose>
    fileclose(wf);
    800058fe:	fc843503          	ld	a0,-56(s0)
    80005902:	cc7fe0ef          	jal	800045c8 <fileclose>
    return -1;
    80005906:	57fd                	li	a5,-1
    80005908:	a01d                	j	8000592e <sys_pipe+0xd0>
    if(fd0 >= 0)
    8000590a:	fc442783          	lw	a5,-60(s0)
    8000590e:	0007c763          	bltz	a5,8000591c <sys_pipe+0xbe>
      p->ofile[fd0] = 0;
    80005912:	07e9                	addi	a5,a5,26
    80005914:	078e                	slli	a5,a5,0x3
    80005916:	97a6                	add	a5,a5,s1
    80005918:	0007b023          	sd	zero,0(a5)
    fileclose(rf);
    8000591c:	fd043503          	ld	a0,-48(s0)
    80005920:	ca9fe0ef          	jal	800045c8 <fileclose>
    fileclose(wf);
    80005924:	fc843503          	ld	a0,-56(s0)
    80005928:	ca1fe0ef          	jal	800045c8 <fileclose>
    return -1;
    8000592c:	57fd                	li	a5,-1
}
    8000592e:	853e                	mv	a0,a5
    80005930:	70e2                	ld	ra,56(sp)
    80005932:	7442                	ld	s0,48(sp)
    80005934:	74a2                	ld	s1,40(sp)
    80005936:	6121                	addi	sp,sp,64
    80005938:	8082                	ret

000000008000593a <sys_fsread>:
uint64
sys_fsread(void)
{
    8000593a:	1101                	addi	sp,sp,-32
    8000593c:	ec06                	sd	ra,24(sp)
    8000593e:	e822                	sd	s0,16(sp)
    80005940:	1000                	addi	s0,sp,32
  uint64 addr;
  int n;

  // استدعاء الدوال بدون مقارنتها بـ < 0 لأنها تعيد void
  argaddr(0, &addr); 
    80005942:	fe840593          	addi	a1,s0,-24
    80005946:	4501                	li	a0,0
    80005948:	bcefd0ef          	jal	80002d16 <argaddr>
  argint(1, &n);
    8000594c:	fe440593          	addi	a1,s0,-28
    80005950:	4505                	li	a0,1
    80005952:	ba8fd0ef          	jal	80002cfa <argint>

  // استدعاء الوظيفة الحقيقية وإعادة نتيجتها
  return fslog_read_many((struct fs_event *)addr, n);
    80005956:	fe442583          	lw	a1,-28(s0)
    8000595a:	fe843503          	ld	a0,-24(s0)
    8000595e:	235000ef          	jal	80006392 <fslog_read_many>
    80005962:	60e2                	ld	ra,24(sp)
    80005964:	6442                	ld	s0,16(sp)
    80005966:	6105                	addi	sp,sp,32
    80005968:	8082                	ret
    8000596a:	0000                	unimp
    8000596c:	0000                	unimp
	...

0000000080005970 <kernelvec>:
.globl kerneltrap
.globl kernelvec
.align 4
kernelvec:
        # make room to save registers.
        addi sp, sp, -256
    80005970:	7111                	addi	sp,sp,-256

        # save caller-saved registers.
        sd ra, 0(sp)
    80005972:	e006                	sd	ra,0(sp)
        # sd sp, 8(sp)
        sd gp, 16(sp)
    80005974:	e80e                	sd	gp,16(sp)
        sd tp, 24(sp)
    80005976:	ec12                	sd	tp,24(sp)
        sd t0, 32(sp)
    80005978:	f016                	sd	t0,32(sp)
        sd t1, 40(sp)
    8000597a:	f41a                	sd	t1,40(sp)
        sd t2, 48(sp)
    8000597c:	f81e                	sd	t2,48(sp)
        sd a0, 72(sp)
    8000597e:	e4aa                	sd	a0,72(sp)
        sd a1, 80(sp)
    80005980:	e8ae                	sd	a1,80(sp)
        sd a2, 88(sp)
    80005982:	ecb2                	sd	a2,88(sp)
        sd a3, 96(sp)
    80005984:	f0b6                	sd	a3,96(sp)
        sd a4, 104(sp)
    80005986:	f4ba                	sd	a4,104(sp)
        sd a5, 112(sp)
    80005988:	f8be                	sd	a5,112(sp)
        sd a6, 120(sp)
    8000598a:	fcc2                	sd	a6,120(sp)
        sd a7, 128(sp)
    8000598c:	e146                	sd	a7,128(sp)
        sd t3, 216(sp)
    8000598e:	edf2                	sd	t3,216(sp)
        sd t4, 224(sp)
    80005990:	f1f6                	sd	t4,224(sp)
        sd t5, 232(sp)
    80005992:	f5fa                	sd	t5,232(sp)
        sd t6, 240(sp)
    80005994:	f9fe                	sd	t6,240(sp)

        # call the C trap handler in trap.c
        call kerneltrap
    80005996:	9eafd0ef          	jal	80002b80 <kerneltrap>

        # restore registers.
        ld ra, 0(sp)
    8000599a:	6082                	ld	ra,0(sp)
        # ld sp, 8(sp)
        ld gp, 16(sp)
    8000599c:	61c2                	ld	gp,16(sp)
        # not tp (contains hartid), in case we moved CPUs
        ld t0, 32(sp)
    8000599e:	7282                	ld	t0,32(sp)
        ld t1, 40(sp)
    800059a0:	7322                	ld	t1,40(sp)
        ld t2, 48(sp)
    800059a2:	73c2                	ld	t2,48(sp)
        ld a0, 72(sp)
    800059a4:	6526                	ld	a0,72(sp)
        ld a1, 80(sp)
    800059a6:	65c6                	ld	a1,80(sp)
        ld a2, 88(sp)
    800059a8:	6666                	ld	a2,88(sp)
        ld a3, 96(sp)
    800059aa:	7686                	ld	a3,96(sp)
        ld a4, 104(sp)
    800059ac:	7726                	ld	a4,104(sp)
        ld a5, 112(sp)
    800059ae:	77c6                	ld	a5,112(sp)
        ld a6, 120(sp)
    800059b0:	7866                	ld	a6,120(sp)
        ld a7, 128(sp)
    800059b2:	688a                	ld	a7,128(sp)
        ld t3, 216(sp)
    800059b4:	6e6e                	ld	t3,216(sp)
        ld t4, 224(sp)
    800059b6:	7e8e                	ld	t4,224(sp)
        ld t5, 232(sp)
    800059b8:	7f2e                	ld	t5,232(sp)
        ld t6, 240(sp)
    800059ba:	7fce                	ld	t6,240(sp)

        addi sp, sp, 256
    800059bc:	6111                	addi	sp,sp,256

        # return to whatever we were doing in the kernel.
        sret
    800059be:	10200073          	sret
	...

00000000800059ce <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    800059ce:	1141                	addi	sp,sp,-16
    800059d0:	e422                	sd	s0,8(sp)
    800059d2:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    800059d4:	0c0007b7          	lui	a5,0xc000
    800059d8:	4705                	li	a4,1
    800059da:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    800059dc:	0c0007b7          	lui	a5,0xc000
    800059e0:	c3d8                	sw	a4,4(a5)
}
    800059e2:	6422                	ld	s0,8(sp)
    800059e4:	0141                	addi	sp,sp,16
    800059e6:	8082                	ret

00000000800059e8 <plicinithart>:

void
plicinithart(void)
{
    800059e8:	1141                	addi	sp,sp,-16
    800059ea:	e406                	sd	ra,8(sp)
    800059ec:	e022                	sd	s0,0(sp)
    800059ee:	0800                	addi	s0,sp,16
  int hart = cpuid();
    800059f0:	9b6fc0ef          	jal	80001ba6 <cpuid>
  
  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    800059f4:	0085171b          	slliw	a4,a0,0x8
    800059f8:	0c0027b7          	lui	a5,0xc002
    800059fc:	97ba                	add	a5,a5,a4
    800059fe:	40200713          	li	a4,1026
    80005a02:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80005a06:	00d5151b          	slliw	a0,a0,0xd
    80005a0a:	0c2017b7          	lui	a5,0xc201
    80005a0e:	97aa                	add	a5,a5,a0
    80005a10:	0007a023          	sw	zero,0(a5) # c201000 <_entry-0x73dff000>
}
    80005a14:	60a2                	ld	ra,8(sp)
    80005a16:	6402                	ld	s0,0(sp)
    80005a18:	0141                	addi	sp,sp,16
    80005a1a:	8082                	ret

0000000080005a1c <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    80005a1c:	1141                	addi	sp,sp,-16
    80005a1e:	e406                	sd	ra,8(sp)
    80005a20:	e022                	sd	s0,0(sp)
    80005a22:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005a24:	982fc0ef          	jal	80001ba6 <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80005a28:	00d5151b          	slliw	a0,a0,0xd
    80005a2c:	0c2017b7          	lui	a5,0xc201
    80005a30:	97aa                	add	a5,a5,a0
  return irq;
}
    80005a32:	43c8                	lw	a0,4(a5)
    80005a34:	60a2                	ld	ra,8(sp)
    80005a36:	6402                	ld	s0,0(sp)
    80005a38:	0141                	addi	sp,sp,16
    80005a3a:	8082                	ret

0000000080005a3c <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    80005a3c:	1101                	addi	sp,sp,-32
    80005a3e:	ec06                	sd	ra,24(sp)
    80005a40:	e822                	sd	s0,16(sp)
    80005a42:	e426                	sd	s1,8(sp)
    80005a44:	1000                	addi	s0,sp,32
    80005a46:	84aa                	mv	s1,a0
  int hart = cpuid();
    80005a48:	95efc0ef          	jal	80001ba6 <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    80005a4c:	00d5151b          	slliw	a0,a0,0xd
    80005a50:	0c2017b7          	lui	a5,0xc201
    80005a54:	97aa                	add	a5,a5,a0
    80005a56:	c3c4                	sw	s1,4(a5)
}
    80005a58:	60e2                	ld	ra,24(sp)
    80005a5a:	6442                	ld	s0,16(sp)
    80005a5c:	64a2                	ld	s1,8(sp)
    80005a5e:	6105                	addi	sp,sp,32
    80005a60:	8082                	ret

0000000080005a62 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80005a62:	1141                	addi	sp,sp,-16
    80005a64:	e406                	sd	ra,8(sp)
    80005a66:	e022                	sd	s0,0(sp)
    80005a68:	0800                	addi	s0,sp,16
  if(i >= NUM)
    80005a6a:	479d                	li	a5,7
    80005a6c:	04a7ca63          	blt	a5,a0,80005ac0 <free_desc+0x5e>
    panic("free_desc 1");
  if(disk.free[i])
    80005a70:	0001f797          	auipc	a5,0x1f
    80005a74:	ea078793          	addi	a5,a5,-352 # 80024910 <disk>
    80005a78:	97aa                	add	a5,a5,a0
    80005a7a:	0187c783          	lbu	a5,24(a5)
    80005a7e:	e7b9                	bnez	a5,80005acc <free_desc+0x6a>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    80005a80:	00451693          	slli	a3,a0,0x4
    80005a84:	0001f797          	auipc	a5,0x1f
    80005a88:	e8c78793          	addi	a5,a5,-372 # 80024910 <disk>
    80005a8c:	6398                	ld	a4,0(a5)
    80005a8e:	9736                	add	a4,a4,a3
    80005a90:	00073023          	sd	zero,0(a4)
  disk.desc[i].len = 0;
    80005a94:	6398                	ld	a4,0(a5)
    80005a96:	9736                	add	a4,a4,a3
    80005a98:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    80005a9c:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    80005aa0:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    80005aa4:	97aa                	add	a5,a5,a0
    80005aa6:	4705                	li	a4,1
    80005aa8:	00e78c23          	sb	a4,24(a5)
  wakeup(&disk.free[0]);
    80005aac:	0001f517          	auipc	a0,0x1f
    80005ab0:	e7c50513          	addi	a0,a0,-388 # 80024928 <disk+0x18>
    80005ab4:	98ffc0ef          	jal	80002442 <wakeup>
}
    80005ab8:	60a2                	ld	ra,8(sp)
    80005aba:	6402                	ld	s0,0(sp)
    80005abc:	0141                	addi	sp,sp,16
    80005abe:	8082                	ret
    panic("free_desc 1");
    80005ac0:	00003517          	auipc	a0,0x3
    80005ac4:	b8850513          	addi	a0,a0,-1144 # 80008648 <etext+0x648>
    80005ac8:	d4bfa0ef          	jal	80000812 <panic>
    panic("free_desc 2");
    80005acc:	00003517          	auipc	a0,0x3
    80005ad0:	b8c50513          	addi	a0,a0,-1140 # 80008658 <etext+0x658>
    80005ad4:	d3ffa0ef          	jal	80000812 <panic>

0000000080005ad8 <virtio_disk_init>:
{
    80005ad8:	1101                	addi	sp,sp,-32
    80005ada:	ec06                	sd	ra,24(sp)
    80005adc:	e822                	sd	s0,16(sp)
    80005ade:	e426                	sd	s1,8(sp)
    80005ae0:	e04a                	sd	s2,0(sp)
    80005ae2:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80005ae4:	00003597          	auipc	a1,0x3
    80005ae8:	b8458593          	addi	a1,a1,-1148 # 80008668 <etext+0x668>
    80005aec:	0001f517          	auipc	a0,0x1f
    80005af0:	f4c50513          	addi	a0,a0,-180 # 80024a38 <disk+0x128>
    80005af4:	948fb0ef          	jal	80000c3c <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005af8:	100017b7          	lui	a5,0x10001
    80005afc:	4398                	lw	a4,0(a5)
    80005afe:	2701                	sext.w	a4,a4
    80005b00:	747277b7          	lui	a5,0x74727
    80005b04:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    80005b08:	18f71063          	bne	a4,a5,80005c88 <virtio_disk_init+0x1b0>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80005b0c:	100017b7          	lui	a5,0x10001
    80005b10:	0791                	addi	a5,a5,4 # 10001004 <_entry-0x6fffeffc>
    80005b12:	439c                	lw	a5,0(a5)
    80005b14:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005b16:	4709                	li	a4,2
    80005b18:	16e79863          	bne	a5,a4,80005c88 <virtio_disk_init+0x1b0>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005b1c:	100017b7          	lui	a5,0x10001
    80005b20:	07a1                	addi	a5,a5,8 # 10001008 <_entry-0x6fffeff8>
    80005b22:	439c                	lw	a5,0(a5)
    80005b24:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80005b26:	16e79163          	bne	a5,a4,80005c88 <virtio_disk_init+0x1b0>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    80005b2a:	100017b7          	lui	a5,0x10001
    80005b2e:	47d8                	lw	a4,12(a5)
    80005b30:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005b32:	554d47b7          	lui	a5,0x554d4
    80005b36:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    80005b3a:	14f71763          	bne	a4,a5,80005c88 <virtio_disk_init+0x1b0>
  *R(VIRTIO_MMIO_STATUS) = status;
    80005b3e:	100017b7          	lui	a5,0x10001
    80005b42:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    80005b46:	4705                	li	a4,1
    80005b48:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005b4a:	470d                	li	a4,3
    80005b4c:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    80005b4e:	10001737          	lui	a4,0x10001
    80005b52:	4b14                	lw	a3,16(a4)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    80005b54:	c7ffe737          	lui	a4,0xc7ffe
    80005b58:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47fb4c67>
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80005b5c:	8ef9                	and	a3,a3,a4
    80005b5e:	10001737          	lui	a4,0x10001
    80005b62:	d314                	sw	a3,32(a4)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005b64:	472d                	li	a4,11
    80005b66:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005b68:	07078793          	addi	a5,a5,112
  status = *R(VIRTIO_MMIO_STATUS);
    80005b6c:	439c                	lw	a5,0(a5)
    80005b6e:	0007891b          	sext.w	s2,a5
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    80005b72:	8ba1                	andi	a5,a5,8
    80005b74:	12078063          	beqz	a5,80005c94 <virtio_disk_init+0x1bc>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80005b78:	100017b7          	lui	a5,0x10001
    80005b7c:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    80005b80:	100017b7          	lui	a5,0x10001
    80005b84:	04478793          	addi	a5,a5,68 # 10001044 <_entry-0x6fffefbc>
    80005b88:	439c                	lw	a5,0(a5)
    80005b8a:	2781                	sext.w	a5,a5
    80005b8c:	10079a63          	bnez	a5,80005ca0 <virtio_disk_init+0x1c8>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    80005b90:	100017b7          	lui	a5,0x10001
    80005b94:	03478793          	addi	a5,a5,52 # 10001034 <_entry-0x6fffefcc>
    80005b98:	439c                	lw	a5,0(a5)
    80005b9a:	2781                	sext.w	a5,a5
  if(max == 0)
    80005b9c:	10078863          	beqz	a5,80005cac <virtio_disk_init+0x1d4>
  if(max < NUM)
    80005ba0:	471d                	li	a4,7
    80005ba2:	10f77b63          	bgeu	a4,a5,80005cb8 <virtio_disk_init+0x1e0>
  disk.desc = kalloc();
    80005ba6:	fe9fa0ef          	jal	80000b8e <kalloc>
    80005baa:	0001f497          	auipc	s1,0x1f
    80005bae:	d6648493          	addi	s1,s1,-666 # 80024910 <disk>
    80005bb2:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    80005bb4:	fdbfa0ef          	jal	80000b8e <kalloc>
    80005bb8:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    80005bba:	fd5fa0ef          	jal	80000b8e <kalloc>
    80005bbe:	87aa                	mv	a5,a0
    80005bc0:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    80005bc2:	6088                	ld	a0,0(s1)
    80005bc4:	10050063          	beqz	a0,80005cc4 <virtio_disk_init+0x1ec>
    80005bc8:	0001f717          	auipc	a4,0x1f
    80005bcc:	d5073703          	ld	a4,-688(a4) # 80024918 <disk+0x8>
    80005bd0:	0e070a63          	beqz	a4,80005cc4 <virtio_disk_init+0x1ec>
    80005bd4:	0e078863          	beqz	a5,80005cc4 <virtio_disk_init+0x1ec>
  memset(disk.desc, 0, PGSIZE);
    80005bd8:	6605                	lui	a2,0x1
    80005bda:	4581                	li	a1,0
    80005bdc:	9b4fb0ef          	jal	80000d90 <memset>
  memset(disk.avail, 0, PGSIZE);
    80005be0:	0001f497          	auipc	s1,0x1f
    80005be4:	d3048493          	addi	s1,s1,-720 # 80024910 <disk>
    80005be8:	6605                	lui	a2,0x1
    80005bea:	4581                	li	a1,0
    80005bec:	6488                	ld	a0,8(s1)
    80005bee:	9a2fb0ef          	jal	80000d90 <memset>
  memset(disk.used, 0, PGSIZE);
    80005bf2:	6605                	lui	a2,0x1
    80005bf4:	4581                	li	a1,0
    80005bf6:	6888                	ld	a0,16(s1)
    80005bf8:	998fb0ef          	jal	80000d90 <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    80005bfc:	100017b7          	lui	a5,0x10001
    80005c00:	4721                	li	a4,8
    80005c02:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    80005c04:	4098                	lw	a4,0(s1)
    80005c06:	100017b7          	lui	a5,0x10001
    80005c0a:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    80005c0e:	40d8                	lw	a4,4(s1)
    80005c10:	100017b7          	lui	a5,0x10001
    80005c14:	08e7a223          	sw	a4,132(a5) # 10001084 <_entry-0x6fffef7c>
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    80005c18:	649c                	ld	a5,8(s1)
    80005c1a:	0007869b          	sext.w	a3,a5
    80005c1e:	10001737          	lui	a4,0x10001
    80005c22:	08d72823          	sw	a3,144(a4) # 10001090 <_entry-0x6fffef70>
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    80005c26:	9781                	srai	a5,a5,0x20
    80005c28:	10001737          	lui	a4,0x10001
    80005c2c:	08f72a23          	sw	a5,148(a4) # 10001094 <_entry-0x6fffef6c>
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    80005c30:	689c                	ld	a5,16(s1)
    80005c32:	0007869b          	sext.w	a3,a5
    80005c36:	10001737          	lui	a4,0x10001
    80005c3a:	0ad72023          	sw	a3,160(a4) # 100010a0 <_entry-0x6fffef60>
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    80005c3e:	9781                	srai	a5,a5,0x20
    80005c40:	10001737          	lui	a4,0x10001
    80005c44:	0af72223          	sw	a5,164(a4) # 100010a4 <_entry-0x6fffef5c>
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    80005c48:	10001737          	lui	a4,0x10001
    80005c4c:	4785                	li	a5,1
    80005c4e:	c37c                	sw	a5,68(a4)
    disk.free[i] = 1;
    80005c50:	00f48c23          	sb	a5,24(s1)
    80005c54:	00f48ca3          	sb	a5,25(s1)
    80005c58:	00f48d23          	sb	a5,26(s1)
    80005c5c:	00f48da3          	sb	a5,27(s1)
    80005c60:	00f48e23          	sb	a5,28(s1)
    80005c64:	00f48ea3          	sb	a5,29(s1)
    80005c68:	00f48f23          	sb	a5,30(s1)
    80005c6c:	00f48fa3          	sb	a5,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    80005c70:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    80005c74:	100017b7          	lui	a5,0x10001
    80005c78:	0727a823          	sw	s2,112(a5) # 10001070 <_entry-0x6fffef90>
}
    80005c7c:	60e2                	ld	ra,24(sp)
    80005c7e:	6442                	ld	s0,16(sp)
    80005c80:	64a2                	ld	s1,8(sp)
    80005c82:	6902                	ld	s2,0(sp)
    80005c84:	6105                	addi	sp,sp,32
    80005c86:	8082                	ret
    panic("could not find virtio disk");
    80005c88:	00003517          	auipc	a0,0x3
    80005c8c:	9f050513          	addi	a0,a0,-1552 # 80008678 <etext+0x678>
    80005c90:	b83fa0ef          	jal	80000812 <panic>
    panic("virtio disk FEATURES_OK unset");
    80005c94:	00003517          	auipc	a0,0x3
    80005c98:	a0450513          	addi	a0,a0,-1532 # 80008698 <etext+0x698>
    80005c9c:	b77fa0ef          	jal	80000812 <panic>
    panic("virtio disk should not be ready");
    80005ca0:	00003517          	auipc	a0,0x3
    80005ca4:	a1850513          	addi	a0,a0,-1512 # 800086b8 <etext+0x6b8>
    80005ca8:	b6bfa0ef          	jal	80000812 <panic>
    panic("virtio disk has no queue 0");
    80005cac:	00003517          	auipc	a0,0x3
    80005cb0:	a2c50513          	addi	a0,a0,-1492 # 800086d8 <etext+0x6d8>
    80005cb4:	b5ffa0ef          	jal	80000812 <panic>
    panic("virtio disk max queue too short");
    80005cb8:	00003517          	auipc	a0,0x3
    80005cbc:	a4050513          	addi	a0,a0,-1472 # 800086f8 <etext+0x6f8>
    80005cc0:	b53fa0ef          	jal	80000812 <panic>
    panic("virtio disk kalloc");
    80005cc4:	00003517          	auipc	a0,0x3
    80005cc8:	a5450513          	addi	a0,a0,-1452 # 80008718 <etext+0x718>
    80005ccc:	b47fa0ef          	jal	80000812 <panic>

0000000080005cd0 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80005cd0:	7159                	addi	sp,sp,-112
    80005cd2:	f486                	sd	ra,104(sp)
    80005cd4:	f0a2                	sd	s0,96(sp)
    80005cd6:	eca6                	sd	s1,88(sp)
    80005cd8:	e8ca                	sd	s2,80(sp)
    80005cda:	e4ce                	sd	s3,72(sp)
    80005cdc:	e0d2                	sd	s4,64(sp)
    80005cde:	fc56                	sd	s5,56(sp)
    80005ce0:	f85a                	sd	s6,48(sp)
    80005ce2:	f45e                	sd	s7,40(sp)
    80005ce4:	f062                	sd	s8,32(sp)
    80005ce6:	ec66                	sd	s9,24(sp)
    80005ce8:	1880                	addi	s0,sp,112
    80005cea:	8a2a                	mv	s4,a0
    80005cec:	8bae                	mv	s7,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    80005cee:	00c52c83          	lw	s9,12(a0)
    80005cf2:	001c9c9b          	slliw	s9,s9,0x1
    80005cf6:	1c82                	slli	s9,s9,0x20
    80005cf8:	020cdc93          	srli	s9,s9,0x20

  acquire(&disk.vdisk_lock);
    80005cfc:	0001f517          	auipc	a0,0x1f
    80005d00:	d3c50513          	addi	a0,a0,-708 # 80024a38 <disk+0x128>
    80005d04:	fb9fa0ef          	jal	80000cbc <acquire>
  for(int i = 0; i < 3; i++){
    80005d08:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    80005d0a:	44a1                	li	s1,8
      disk.free[i] = 0;
    80005d0c:	0001fb17          	auipc	s6,0x1f
    80005d10:	c04b0b13          	addi	s6,s6,-1020 # 80024910 <disk>
  for(int i = 0; i < 3; i++){
    80005d14:	4a8d                	li	s5,3
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80005d16:	0001fc17          	auipc	s8,0x1f
    80005d1a:	d22c0c13          	addi	s8,s8,-734 # 80024a38 <disk+0x128>
    80005d1e:	a8b9                	j	80005d7c <virtio_disk_rw+0xac>
      disk.free[i] = 0;
    80005d20:	00fb0733          	add	a4,s6,a5
    80005d24:	00070c23          	sb	zero,24(a4) # 10001018 <_entry-0x6fffefe8>
    idx[i] = alloc_desc();
    80005d28:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    80005d2a:	0207c563          	bltz	a5,80005d54 <virtio_disk_rw+0x84>
  for(int i = 0; i < 3; i++){
    80005d2e:	2905                	addiw	s2,s2,1
    80005d30:	0611                	addi	a2,a2,4 # 1004 <_entry-0x7fffeffc>
    80005d32:	05590963          	beq	s2,s5,80005d84 <virtio_disk_rw+0xb4>
    idx[i] = alloc_desc();
    80005d36:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    80005d38:	0001f717          	auipc	a4,0x1f
    80005d3c:	bd870713          	addi	a4,a4,-1064 # 80024910 <disk>
    80005d40:	87ce                	mv	a5,s3
    if(disk.free[i]){
    80005d42:	01874683          	lbu	a3,24(a4)
    80005d46:	fee9                	bnez	a3,80005d20 <virtio_disk_rw+0x50>
  for(int i = 0; i < NUM; i++){
    80005d48:	2785                	addiw	a5,a5,1
    80005d4a:	0705                	addi	a4,a4,1
    80005d4c:	fe979be3          	bne	a5,s1,80005d42 <virtio_disk_rw+0x72>
    idx[i] = alloc_desc();
    80005d50:	57fd                	li	a5,-1
    80005d52:	c19c                	sw	a5,0(a1)
      for(int j = 0; j < i; j++)
    80005d54:	01205d63          	blez	s2,80005d6e <virtio_disk_rw+0x9e>
        free_desc(idx[j]);
    80005d58:	f9042503          	lw	a0,-112(s0)
    80005d5c:	d07ff0ef          	jal	80005a62 <free_desc>
      for(int j = 0; j < i; j++)
    80005d60:	4785                	li	a5,1
    80005d62:	0127d663          	bge	a5,s2,80005d6e <virtio_disk_rw+0x9e>
        free_desc(idx[j]);
    80005d66:	f9442503          	lw	a0,-108(s0)
    80005d6a:	cf9ff0ef          	jal	80005a62 <free_desc>
    sleep(&disk.free[0], &disk.vdisk_lock);
    80005d6e:	85e2                	mv	a1,s8
    80005d70:	0001f517          	auipc	a0,0x1f
    80005d74:	bb850513          	addi	a0,a0,-1096 # 80024928 <disk+0x18>
    80005d78:	e7efc0ef          	jal	800023f6 <sleep>
  for(int i = 0; i < 3; i++){
    80005d7c:	f9040613          	addi	a2,s0,-112
    80005d80:	894e                	mv	s2,s3
    80005d82:	bf55                	j	80005d36 <virtio_disk_rw+0x66>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80005d84:	f9042503          	lw	a0,-112(s0)
    80005d88:	00451693          	slli	a3,a0,0x4

  if(write)
    80005d8c:	0001f797          	auipc	a5,0x1f
    80005d90:	b8478793          	addi	a5,a5,-1148 # 80024910 <disk>
    80005d94:	00a50713          	addi	a4,a0,10
    80005d98:	0712                	slli	a4,a4,0x4
    80005d9a:	973e                	add	a4,a4,a5
    80005d9c:	01703633          	snez	a2,s7
    80005da0:	c710                	sw	a2,8(a4)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    80005da2:	00072623          	sw	zero,12(a4)
  buf0->sector = sector;
    80005da6:	01973823          	sd	s9,16(a4)

  disk.desc[idx[0]].addr = (uint64) buf0;
    80005daa:	6398                	ld	a4,0(a5)
    80005dac:	9736                	add	a4,a4,a3
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80005dae:	0a868613          	addi	a2,a3,168
    80005db2:	963e                	add	a2,a2,a5
  disk.desc[idx[0]].addr = (uint64) buf0;
    80005db4:	e310                	sd	a2,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    80005db6:	6390                	ld	a2,0(a5)
    80005db8:	00d605b3          	add	a1,a2,a3
    80005dbc:	4741                	li	a4,16
    80005dbe:	c598                	sw	a4,8(a1)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    80005dc0:	4805                	li	a6,1
    80005dc2:	01059623          	sh	a6,12(a1)
  disk.desc[idx[0]].next = idx[1];
    80005dc6:	f9442703          	lw	a4,-108(s0)
    80005dca:	00e59723          	sh	a4,14(a1)

  disk.desc[idx[1]].addr = (uint64) b->data;
    80005dce:	0712                	slli	a4,a4,0x4
    80005dd0:	963a                	add	a2,a2,a4
    80005dd2:	058a0593          	addi	a1,s4,88
    80005dd6:	e20c                	sd	a1,0(a2)
  disk.desc[idx[1]].len = BSIZE;
    80005dd8:	0007b883          	ld	a7,0(a5)
    80005ddc:	9746                	add	a4,a4,a7
    80005dde:	40000613          	li	a2,1024
    80005de2:	c710                	sw	a2,8(a4)
  if(write)
    80005de4:	001bb613          	seqz	a2,s7
    80005de8:	0016161b          	slliw	a2,a2,0x1
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    80005dec:	00166613          	ori	a2,a2,1
    80005df0:	00c71623          	sh	a2,12(a4)
  disk.desc[idx[1]].next = idx[2];
    80005df4:	f9842583          	lw	a1,-104(s0)
    80005df8:	00b71723          	sh	a1,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    80005dfc:	00250613          	addi	a2,a0,2
    80005e00:	0612                	slli	a2,a2,0x4
    80005e02:	963e                	add	a2,a2,a5
    80005e04:	577d                	li	a4,-1
    80005e06:	00e60823          	sb	a4,16(a2)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    80005e0a:	0592                	slli	a1,a1,0x4
    80005e0c:	98ae                	add	a7,a7,a1
    80005e0e:	03068713          	addi	a4,a3,48
    80005e12:	973e                	add	a4,a4,a5
    80005e14:	00e8b023          	sd	a4,0(a7)
  disk.desc[idx[2]].len = 1;
    80005e18:	6398                	ld	a4,0(a5)
    80005e1a:	972e                	add	a4,a4,a1
    80005e1c:	01072423          	sw	a6,8(a4)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    80005e20:	4689                	li	a3,2
    80005e22:	00d71623          	sh	a3,12(a4)
  disk.desc[idx[2]].next = 0;
    80005e26:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    80005e2a:	010a2223          	sw	a6,4(s4)
  disk.info[idx[0]].b = b;
    80005e2e:	01463423          	sd	s4,8(a2)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    80005e32:	6794                	ld	a3,8(a5)
    80005e34:	0026d703          	lhu	a4,2(a3)
    80005e38:	8b1d                	andi	a4,a4,7
    80005e3a:	0706                	slli	a4,a4,0x1
    80005e3c:	96ba                	add	a3,a3,a4
    80005e3e:	00a69223          	sh	a0,4(a3)

  __sync_synchronize();
    80005e42:	0330000f          	fence	rw,rw

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    80005e46:	6798                	ld	a4,8(a5)
    80005e48:	00275783          	lhu	a5,2(a4)
    80005e4c:	2785                	addiw	a5,a5,1
    80005e4e:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    80005e52:	0330000f          	fence	rw,rw

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80005e56:	100017b7          	lui	a5,0x10001
    80005e5a:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    80005e5e:	004a2783          	lw	a5,4(s4)
    sleep(b, &disk.vdisk_lock);
    80005e62:	0001f917          	auipc	s2,0x1f
    80005e66:	bd690913          	addi	s2,s2,-1066 # 80024a38 <disk+0x128>
  while(b->disk == 1) {
    80005e6a:	4485                	li	s1,1
    80005e6c:	01079a63          	bne	a5,a6,80005e80 <virtio_disk_rw+0x1b0>
    sleep(b, &disk.vdisk_lock);
    80005e70:	85ca                	mv	a1,s2
    80005e72:	8552                	mv	a0,s4
    80005e74:	d82fc0ef          	jal	800023f6 <sleep>
  while(b->disk == 1) {
    80005e78:	004a2783          	lw	a5,4(s4)
    80005e7c:	fe978ae3          	beq	a5,s1,80005e70 <virtio_disk_rw+0x1a0>
  }

  disk.info[idx[0]].b = 0;
    80005e80:	f9042903          	lw	s2,-112(s0)
    80005e84:	00290713          	addi	a4,s2,2
    80005e88:	0712                	slli	a4,a4,0x4
    80005e8a:	0001f797          	auipc	a5,0x1f
    80005e8e:	a8678793          	addi	a5,a5,-1402 # 80024910 <disk>
    80005e92:	97ba                	add	a5,a5,a4
    80005e94:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    80005e98:	0001f997          	auipc	s3,0x1f
    80005e9c:	a7898993          	addi	s3,s3,-1416 # 80024910 <disk>
    80005ea0:	00491713          	slli	a4,s2,0x4
    80005ea4:	0009b783          	ld	a5,0(s3)
    80005ea8:	97ba                	add	a5,a5,a4
    80005eaa:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    80005eae:	854a                	mv	a0,s2
    80005eb0:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    80005eb4:	bafff0ef          	jal	80005a62 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    80005eb8:	8885                	andi	s1,s1,1
    80005eba:	f0fd                	bnez	s1,80005ea0 <virtio_disk_rw+0x1d0>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    80005ebc:	0001f517          	auipc	a0,0x1f
    80005ec0:	b7c50513          	addi	a0,a0,-1156 # 80024a38 <disk+0x128>
    80005ec4:	e91fa0ef          	jal	80000d54 <release>
}
    80005ec8:	70a6                	ld	ra,104(sp)
    80005eca:	7406                	ld	s0,96(sp)
    80005ecc:	64e6                	ld	s1,88(sp)
    80005ece:	6946                	ld	s2,80(sp)
    80005ed0:	69a6                	ld	s3,72(sp)
    80005ed2:	6a06                	ld	s4,64(sp)
    80005ed4:	7ae2                	ld	s5,56(sp)
    80005ed6:	7b42                	ld	s6,48(sp)
    80005ed8:	7ba2                	ld	s7,40(sp)
    80005eda:	7c02                	ld	s8,32(sp)
    80005edc:	6ce2                	ld	s9,24(sp)
    80005ede:	6165                	addi	sp,sp,112
    80005ee0:	8082                	ret

0000000080005ee2 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    80005ee2:	1101                	addi	sp,sp,-32
    80005ee4:	ec06                	sd	ra,24(sp)
    80005ee6:	e822                	sd	s0,16(sp)
    80005ee8:	e426                	sd	s1,8(sp)
    80005eea:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    80005eec:	0001f497          	auipc	s1,0x1f
    80005ef0:	a2448493          	addi	s1,s1,-1500 # 80024910 <disk>
    80005ef4:	0001f517          	auipc	a0,0x1f
    80005ef8:	b4450513          	addi	a0,a0,-1212 # 80024a38 <disk+0x128>
    80005efc:	dc1fa0ef          	jal	80000cbc <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    80005f00:	100017b7          	lui	a5,0x10001
    80005f04:	53b8                	lw	a4,96(a5)
    80005f06:	8b0d                	andi	a4,a4,3
    80005f08:	100017b7          	lui	a5,0x10001
    80005f0c:	d3f8                	sw	a4,100(a5)

  __sync_synchronize();
    80005f0e:	0330000f          	fence	rw,rw

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    80005f12:	689c                	ld	a5,16(s1)
    80005f14:	0204d703          	lhu	a4,32(s1)
    80005f18:	0027d783          	lhu	a5,2(a5) # 10001002 <_entry-0x6fffeffe>
    80005f1c:	04f70663          	beq	a4,a5,80005f68 <virtio_disk_intr+0x86>
    __sync_synchronize();
    80005f20:	0330000f          	fence	rw,rw
    int id = disk.used->ring[disk.used_idx % NUM].id;
    80005f24:	6898                	ld	a4,16(s1)
    80005f26:	0204d783          	lhu	a5,32(s1)
    80005f2a:	8b9d                	andi	a5,a5,7
    80005f2c:	078e                	slli	a5,a5,0x3
    80005f2e:	97ba                	add	a5,a5,a4
    80005f30:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    80005f32:	00278713          	addi	a4,a5,2
    80005f36:	0712                	slli	a4,a4,0x4
    80005f38:	9726                	add	a4,a4,s1
    80005f3a:	01074703          	lbu	a4,16(a4)
    80005f3e:	e321                	bnez	a4,80005f7e <virtio_disk_intr+0x9c>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    80005f40:	0789                	addi	a5,a5,2
    80005f42:	0792                	slli	a5,a5,0x4
    80005f44:	97a6                	add	a5,a5,s1
    80005f46:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    80005f48:	00052223          	sw	zero,4(a0)
    wakeup(b);
    80005f4c:	cf6fc0ef          	jal	80002442 <wakeup>

    disk.used_idx += 1;
    80005f50:	0204d783          	lhu	a5,32(s1)
    80005f54:	2785                	addiw	a5,a5,1
    80005f56:	17c2                	slli	a5,a5,0x30
    80005f58:	93c1                	srli	a5,a5,0x30
    80005f5a:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    80005f5e:	6898                	ld	a4,16(s1)
    80005f60:	00275703          	lhu	a4,2(a4)
    80005f64:	faf71ee3          	bne	a4,a5,80005f20 <virtio_disk_intr+0x3e>
  }

  release(&disk.vdisk_lock);
    80005f68:	0001f517          	auipc	a0,0x1f
    80005f6c:	ad050513          	addi	a0,a0,-1328 # 80024a38 <disk+0x128>
    80005f70:	de5fa0ef          	jal	80000d54 <release>
}
    80005f74:	60e2                	ld	ra,24(sp)
    80005f76:	6442                	ld	s0,16(sp)
    80005f78:	64a2                	ld	s1,8(sp)
    80005f7a:	6105                	addi	sp,sp,32
    80005f7c:	8082                	ret
      panic("virtio_disk_intr status");
    80005f7e:	00002517          	auipc	a0,0x2
    80005f82:	7b250513          	addi	a0,a0,1970 # 80008730 <etext+0x730>
    80005f86:	88dfa0ef          	jal	80000812 <panic>

0000000080005f8a <cslog_init>:
  safestrcpy(e->name, p->name, CS_NM);
}

void
cslog_init(void)
{
    80005f8a:	1141                	addi	sp,sp,-16
    80005f8c:	e406                	sd	ra,8(sp)
    80005f8e:	e022                	sd	s0,0(sp)
    80005f90:	0800                	addi	s0,sp,16
  ringbuf_init(&cs_rb, "cslog", sizeof(struct cs_event));
    80005f92:	03000613          	li	a2,48
    80005f96:	00002597          	auipc	a1,0x2
    80005f9a:	7b258593          	addi	a1,a1,1970 # 80008748 <etext+0x748>
    80005f9e:	0001f517          	auipc	a0,0x1f
    80005fa2:	ab250513          	addi	a0,a0,-1358 # 80024a50 <cs_rb>
    80005fa6:	1b2000ef          	jal	80006158 <ringbuf_init>
}
    80005faa:	60a2                	ld	ra,8(sp)
    80005fac:	6402                	ld	s0,0(sp)
    80005fae:	0141                	addi	sp,sp,16
    80005fb0:	8082                	ret

0000000080005fb2 <cslog_push>:

void
cslog_push(struct cs_event *e)
{
    80005fb2:	1141                	addi	sp,sp,-16
    80005fb4:	e406                	sd	ra,8(sp)
    80005fb6:	e022                	sd	s0,0(sp)
    80005fb8:	0800                	addi	s0,sp,16
    80005fba:	85aa                	mv	a1,a0
  e->seq = ++cs_seq;
    80005fbc:	00005717          	auipc	a4,0x5
    80005fc0:	71c70713          	addi	a4,a4,1820 # 8000b6d8 <cs_seq>
    80005fc4:	631c                	ld	a5,0(a4)
    80005fc6:	0785                	addi	a5,a5,1
    80005fc8:	e31c                	sd	a5,0(a4)
    80005fca:	e11c                	sd	a5,0(a0)
  ringbuf_push(&cs_rb, e);
    80005fcc:	0001f517          	auipc	a0,0x1f
    80005fd0:	a8450513          	addi	a0,a0,-1404 # 80024a50 <cs_rb>
    80005fd4:	1b8000ef          	jal	8000618c <ringbuf_push>
}
    80005fd8:	60a2                	ld	ra,8(sp)
    80005fda:	6402                	ld	s0,0(sp)
    80005fdc:	0141                	addi	sp,sp,16
    80005fde:	8082                	ret

0000000080005fe0 <cslog_read_many>:

int
cslog_read_many(struct cs_event *out, int max)
{
    80005fe0:	1141                	addi	sp,sp,-16
    80005fe2:	e406                	sd	ra,8(sp)
    80005fe4:	e022                	sd	s0,0(sp)
    80005fe6:	0800                	addi	s0,sp,16
    80005fe8:	862e                	mv	a2,a1
  return ringbuf_read_many(&cs_rb, out, max);
    80005fea:	85aa                	mv	a1,a0
    80005fec:	0001f517          	auipc	a0,0x1f
    80005ff0:	a6450513          	addi	a0,a0,-1436 # 80024a50 <cs_rb>
    80005ff4:	204000ef          	jal	800061f8 <ringbuf_read_many>
}
    80005ff8:	60a2                	ld	ra,8(sp)
    80005ffa:	6402                	ld	s0,0(sp)
    80005ffc:	0141                	addi	sp,sp,16
    80005ffe:	8082                	ret

0000000080006000 <cslog_run_start>:

void
cslog_run_start(struct proc *p)
{
  if(p == 0) return;
    80006000:	c14d                	beqz	a0,800060a2 <cslog_run_start+0xa2>
{
    80006002:	715d                	addi	sp,sp,-80
    80006004:	e486                	sd	ra,72(sp)
    80006006:	e0a2                	sd	s0,64(sp)
    80006008:	fc26                	sd	s1,56(sp)
    8000600a:	0880                	addi	s0,sp,80
    8000600c:	84aa                	mv	s1,a0
  if(p->pid <= 0) return;
    8000600e:	591c                	lw	a5,48(a0)
    80006010:	00f05563          	blez	a5,8000601a <cslog_run_start+0x1a>
  if(p->name[0] == 0) return;
    80006014:	15854783          	lbu	a5,344(a0)
    80006018:	e791                	bnez	a5,80006024 <cslog_run_start+0x24>

  struct cs_event e;
  fill_from_proc(&e, p);
  e.type = CS_RUN_START;
  cslog_push(&e);
    8000601a:	60a6                	ld	ra,72(sp)
    8000601c:	6406                	ld	s0,64(sp)
    8000601e:	74e2                	ld	s1,56(sp)
    80006020:	6161                	addi	sp,sp,80
    80006022:	8082                	ret
    80006024:	f84a                	sd	s2,48(sp)
  if(strncmp(p->name, "cscat", 5) == 0) return;
    80006026:	15850913          	addi	s2,a0,344
    8000602a:	4615                	li	a2,5
    8000602c:	00002597          	auipc	a1,0x2
    80006030:	72458593          	addi	a1,a1,1828 # 80008750 <etext+0x750>
    80006034:	854a                	mv	a0,s2
    80006036:	e27fa0ef          	jal	80000e5c <strncmp>
    8000603a:	e119                	bnez	a0,80006040 <cslog_run_start+0x40>
    8000603c:	7942                	ld	s2,48(sp)
    8000603e:	bff1                	j	8000601a <cslog_run_start+0x1a>
  if(strncmp(p->name, "csexport", 8) == 0) return;
    80006040:	4621                	li	a2,8
    80006042:	00002597          	auipc	a1,0x2
    80006046:	71658593          	addi	a1,a1,1814 # 80008758 <etext+0x758>
    8000604a:	854a                	mv	a0,s2
    8000604c:	e11fa0ef          	jal	80000e5c <strncmp>
    80006050:	e119                	bnez	a0,80006056 <cslog_run_start+0x56>
    80006052:	7942                	ld	s2,48(sp)
    80006054:	b7d9                	j	8000601a <cslog_run_start+0x1a>
  memset(e, 0, sizeof(*e));
    80006056:	03000613          	li	a2,48
    8000605a:	4581                	li	a1,0
    8000605c:	fb040513          	addi	a0,s0,-80
    80006060:	d31fa0ef          	jal	80000d90 <memset>
  e->ticks = ticks;
    80006064:	00005797          	auipc	a5,0x5
    80006068:	66c7a783          	lw	a5,1644(a5) # 8000b6d0 <ticks>
    8000606c:	faf42c23          	sw	a5,-72(s0)
  e->cpu   = cpuid();
    80006070:	b37fb0ef          	jal	80001ba6 <cpuid>
    80006074:	faa42e23          	sw	a0,-68(s0)
  e->pid   = p->pid;
    80006078:	589c                	lw	a5,48(s1)
    8000607a:	fcf42223          	sw	a5,-60(s0)
  e->state = p->state;
    8000607e:	4c9c                	lw	a5,24(s1)
    80006080:	fcf42423          	sw	a5,-56(s0)
  safestrcpy(e->name, p->name, CS_NM);
    80006084:	4641                	li	a2,16
    80006086:	85ca                	mv	a1,s2
    80006088:	fcc40513          	addi	a0,s0,-52
    8000608c:	e43fa0ef          	jal	80000ece <safestrcpy>
  e.type = CS_RUN_START;
    80006090:	4785                	li	a5,1
    80006092:	fcf42023          	sw	a5,-64(s0)
  cslog_push(&e);
    80006096:	fb040513          	addi	a0,s0,-80
    8000609a:	f19ff0ef          	jal	80005fb2 <cslog_push>
    8000609e:	7942                	ld	s2,48(sp)
    800060a0:	bfad                	j	8000601a <cslog_run_start+0x1a>
    800060a2:	8082                	ret

00000000800060a4 <sys_csread>:
#include "cslog.h"


uint64
sys_csread(void)
{
    800060a4:	81010113          	addi	sp,sp,-2032
    800060a8:	7e113423          	sd	ra,2024(sp)
    800060ac:	7e813023          	sd	s0,2016(sp)
    800060b0:	7c913c23          	sd	s1,2008(sp)
    800060b4:	7d213823          	sd	s2,2000(sp)
    800060b8:	7f010413          	addi	s0,sp,2032
    800060bc:	bb010113          	addi	sp,sp,-1104
  uint64 uaddr = 0;
    800060c0:	fc043c23          	sd	zero,-40(s0)
  int max = 0;
    800060c4:	fc042a23          	sw	zero,-44(s0)

  // ✅ عندك argaddr/argint void، فبنستدعيهم بدون if
  argaddr(0, &uaddr);
    800060c8:	fd840593          	addi	a1,s0,-40
    800060cc:	4501                	li	a0,0
    800060ce:	c49fc0ef          	jal	80002d16 <argaddr>
  argint(1, &max);
    800060d2:	fd440593          	addi	a1,s0,-44
    800060d6:	4505                	li	a0,1
    800060d8:	c23fc0ef          	jal	80002cfa <argint>

  if(max <= 0) return 0;
    800060dc:	fd442783          	lw	a5,-44(s0)
    800060e0:	4501                	li	a0,0
    800060e2:	04f05c63          	blez	a5,8000613a <sys_csread+0x96>
  if(max > 64) max = 64;
    800060e6:	04000713          	li	a4,64
    800060ea:	00f75663          	bge	a4,a5,800060f6 <sys_csread+0x52>
    800060ee:	04000793          	li	a5,64
    800060f2:	fcf42a23          	sw	a5,-44(s0)

  struct cs_event tmp[64];
  int n = cslog_read_many(tmp, max);
    800060f6:	77fd                	lui	a5,0xfffff
    800060f8:	3d078793          	addi	a5,a5,976 # fffffffffffff3d0 <end+0xffffffff7ffb58d8>
    800060fc:	97a2                	add	a5,a5,s0
    800060fe:	797d                	lui	s2,0xfffff
    80006100:	3c890713          	addi	a4,s2,968 # fffffffffffff3c8 <end+0xffffffff7ffb58d0>
    80006104:	9722                	add	a4,a4,s0
    80006106:	e31c                	sd	a5,0(a4)
    80006108:	fd442583          	lw	a1,-44(s0)
    8000610c:	6308                	ld	a0,0(a4)
    8000610e:	ed3ff0ef          	jal	80005fe0 <cslog_read_many>
    80006112:	84aa                	mv	s1,a0

  int bytes = n * (int)sizeof(struct cs_event);
  if(copyout(myproc()->pagetable, uaddr, (char*)tmp, bytes) < 0)
    80006114:	abffb0ef          	jal	80001bd2 <myproc>
  int bytes = n * (int)sizeof(struct cs_event);
    80006118:	0014969b          	slliw	a3,s1,0x1
    8000611c:	9ea5                	addw	a3,a3,s1
  if(copyout(myproc()->pagetable, uaddr, (char*)tmp, bytes) < 0)
    8000611e:	0046969b          	slliw	a3,a3,0x4
    80006122:	3c890793          	addi	a5,s2,968
    80006126:	97a2                	add	a5,a5,s0
    80006128:	6390                	ld	a2,0(a5)
    8000612a:	fd843583          	ld	a1,-40(s0)
    8000612e:	6928                	ld	a0,80(a0)
    80006130:	fa2fb0ef          	jal	800018d2 <copyout>
    80006134:	02054063          	bltz	a0,80006154 <sys_csread+0xb0>
    return -1;

  return n;
    80006138:	8526                	mv	a0,s1
}
    8000613a:	45010113          	addi	sp,sp,1104
    8000613e:	7e813083          	ld	ra,2024(sp)
    80006142:	7e013403          	ld	s0,2016(sp)
    80006146:	7d813483          	ld	s1,2008(sp)
    8000614a:	7d013903          	ld	s2,2000(sp)
    8000614e:	7f010113          	addi	sp,sp,2032
    80006152:	8082                	ret
    return -1;
    80006154:	557d                	li	a0,-1
    80006156:	b7d5                	j	8000613a <sys_csread+0x96>

0000000080006158 <ringbuf_init>:
  return (void *)(rb->buf + idx * rb->elem_size);
}

void
ringbuf_init(struct ringbuf *rb, char *name, uint elem_size)
{
    80006158:	1101                	addi	sp,sp,-32
    8000615a:	ec06                	sd	ra,24(sp)
    8000615c:	e822                	sd	s0,16(sp)
    8000615e:	e426                	sd	s1,8(sp)
    80006160:	e04a                	sd	s2,0(sp)
    80006162:	1000                	addi	s0,sp,32
    80006164:	84aa                	mv	s1,a0
    80006166:	8932                	mv	s2,a2
  initlock(&rb->lock, name);
    80006168:	ad5fa0ef          	jal	80000c3c <initlock>
  rb->head = 0;
    8000616c:	0004ac23          	sw	zero,24(s1)
  rb->tail = 0;
    80006170:	0004ae23          	sw	zero,28(s1)
  rb->count = 0;
    80006174:	0204a023          	sw	zero,32(s1)
  rb->seq = 0;
    80006178:	0204b423          	sd	zero,40(s1)
  rb->elem_size = elem_size;
    8000617c:	0324a223          	sw	s2,36(s1)
}
    80006180:	60e2                	ld	ra,24(sp)
    80006182:	6442                	ld	s0,16(sp)
    80006184:	64a2                	ld	s1,8(sp)
    80006186:	6902                	ld	s2,0(sp)
    80006188:	6105                	addi	sp,sp,32
    8000618a:	8082                	ret

000000008000618c <ringbuf_push>:

int
ringbuf_push(struct ringbuf *rb, void *elem)
{
    8000618c:	1101                	addi	sp,sp,-32
    8000618e:	ec06                	sd	ra,24(sp)
    80006190:	e822                	sd	s0,16(sp)
    80006192:	e426                	sd	s1,8(sp)
    80006194:	e04a                	sd	s2,0(sp)
    80006196:	1000                	addi	s0,sp,32
    80006198:	84aa                	mv	s1,a0
    8000619a:	892e                	mv	s2,a1
  acquire(&rb->lock);
    8000619c:	b21fa0ef          	jal	80000cbc <acquire>

  if(rb->count == RB_CAP){
    800061a0:	5098                	lw	a4,32(s1)
    800061a2:	20000793          	li	a5,512
    800061a6:	04f70063          	beq	a4,a5,800061e6 <ringbuf_push+0x5a>
  return (void *)(rb->buf + idx * rb->elem_size);
    800061aa:	50d0                	lw	a2,36(s1)
    800061ac:	03048513          	addi	a0,s1,48
    800061b0:	4c9c                	lw	a5,24(s1)
    800061b2:	02c787bb          	mulw	a5,a5,a2
    800061b6:	1782                	slli	a5,a5,0x20
    800061b8:	9381                	srli	a5,a5,0x20
    rb->tail = (rb->tail + 1) % RB_CAP;
    rb->count--;
  }

  memmove(slot_ptr(rb, rb->head), elem, rb->elem_size);
    800061ba:	85ca                	mv	a1,s2
    800061bc:	953e                	add	a0,a0,a5
    800061be:	c2ffa0ef          	jal	80000dec <memmove>
  rb->head = (rb->head + 1) % RB_CAP;
    800061c2:	4c9c                	lw	a5,24(s1)
    800061c4:	2785                	addiw	a5,a5,1
    800061c6:	1ff7f793          	andi	a5,a5,511
    800061ca:	cc9c                	sw	a5,24(s1)
  rb->count++;
    800061cc:	509c                	lw	a5,32(s1)
    800061ce:	2785                	addiw	a5,a5,1
    800061d0:	d09c                	sw	a5,32(s1)

  release(&rb->lock);
    800061d2:	8526                	mv	a0,s1
    800061d4:	b81fa0ef          	jal	80000d54 <release>
  return 0;
}
    800061d8:	4501                	li	a0,0
    800061da:	60e2                	ld	ra,24(sp)
    800061dc:	6442                	ld	s0,16(sp)
    800061de:	64a2                	ld	s1,8(sp)
    800061e0:	6902                	ld	s2,0(sp)
    800061e2:	6105                	addi	sp,sp,32
    800061e4:	8082                	ret
    rb->tail = (rb->tail + 1) % RB_CAP;
    800061e6:	4cdc                	lw	a5,28(s1)
    800061e8:	2785                	addiw	a5,a5,1
    800061ea:	1ff7f793          	andi	a5,a5,511
    800061ee:	ccdc                	sw	a5,28(s1)
    rb->count--;
    800061f0:	1ff00793          	li	a5,511
    800061f4:	d09c                	sw	a5,32(s1)
    800061f6:	bf55                	j	800061aa <ringbuf_push+0x1e>

00000000800061f8 <ringbuf_read_many>:

int
ringbuf_read_many(struct ringbuf *rb, void *out, int max)
{
    800061f8:	7139                	addi	sp,sp,-64
    800061fa:	fc06                	sd	ra,56(sp)
    800061fc:	f822                	sd	s0,48(sp)
    800061fe:	f04a                	sd	s2,32(sp)
    80006200:	0080                	addi	s0,sp,64
  int n = 0;
  char *dst = (char *)out;

  if(max <= 0)
    return 0;
    80006202:	4901                	li	s2,0
  if(max <= 0)
    80006204:	06c05163          	blez	a2,80006266 <ringbuf_read_many+0x6e>
    80006208:	f426                	sd	s1,40(sp)
    8000620a:	ec4e                	sd	s3,24(sp)
    8000620c:	e852                	sd	s4,16(sp)
    8000620e:	e456                	sd	s5,8(sp)
    80006210:	84aa                	mv	s1,a0
    80006212:	8a2e                	mv	s4,a1
    80006214:	89b2                	mv	s3,a2

  acquire(&rb->lock);
    80006216:	aa7fa0ef          	jal	80000cbc <acquire>
  int n = 0;
    8000621a:	4901                	li	s2,0
  return (void *)(rb->buf + idx * rb->elem_size);
    8000621c:	03048a93          	addi	s5,s1,48
  while(n < max && rb->count > 0){
    80006220:	509c                	lw	a5,32(s1)
    80006222:	cb9d                	beqz	a5,80006258 <ringbuf_read_many+0x60>
    memmove(dst + n * rb->elem_size, slot_ptr(rb, rb->tail), rb->elem_size);
    80006224:	50d0                	lw	a2,36(s1)
  return (void *)(rb->buf + idx * rb->elem_size);
    80006226:	4ccc                	lw	a1,28(s1)
    80006228:	02c585bb          	mulw	a1,a1,a2
    8000622c:	1582                	slli	a1,a1,0x20
    8000622e:	9181                	srli	a1,a1,0x20
    memmove(dst + n * rb->elem_size, slot_ptr(rb, rb->tail), rb->elem_size);
    80006230:	02c9053b          	mulw	a0,s2,a2
    80006234:	1502                	slli	a0,a0,0x20
    80006236:	9101                	srli	a0,a0,0x20
    80006238:	95d6                	add	a1,a1,s5
    8000623a:	9552                	add	a0,a0,s4
    8000623c:	bb1fa0ef          	jal	80000dec <memmove>
    rb->tail = (rb->tail + 1) % RB_CAP;
    80006240:	4cdc                	lw	a5,28(s1)
    80006242:	2785                	addiw	a5,a5,1
    80006244:	1ff7f793          	andi	a5,a5,511
    80006248:	ccdc                	sw	a5,28(s1)
    rb->count--;
    8000624a:	509c                	lw	a5,32(s1)
    8000624c:	37fd                	addiw	a5,a5,-1
    8000624e:	d09c                	sw	a5,32(s1)
    n++;
    80006250:	2905                	addiw	s2,s2,1
  while(n < max && rb->count > 0){
    80006252:	fd2997e3          	bne	s3,s2,80006220 <ringbuf_read_many+0x28>
    80006256:	894e                	mv	s2,s3
  }
  release(&rb->lock);
    80006258:	8526                	mv	a0,s1
    8000625a:	afbfa0ef          	jal	80000d54 <release>

  return n;
    8000625e:	74a2                	ld	s1,40(sp)
    80006260:	69e2                	ld	s3,24(sp)
    80006262:	6a42                	ld	s4,16(sp)
    80006264:	6aa2                	ld	s5,8(sp)
}
    80006266:	854a                	mv	a0,s2
    80006268:	70e2                	ld	ra,56(sp)
    8000626a:	7442                	ld	s0,48(sp)
    8000626c:	7902                	ld	s2,32(sp)
    8000626e:	6121                	addi	sp,sp,64
    80006270:	8082                	ret

0000000080006272 <ringbuf_pop>:
int
ringbuf_pop(struct ringbuf *rb, void *dst)
{
    80006272:	1101                	addi	sp,sp,-32
    80006274:	ec06                	sd	ra,24(sp)
    80006276:	e822                	sd	s0,16(sp)
    80006278:	e426                	sd	s1,8(sp)
    8000627a:	e04a                	sd	s2,0(sp)
    8000627c:	1000                	addi	s0,sp,32
    8000627e:	84aa                	mv	s1,a0
    80006280:	892e                	mv	s2,a1
  acquire(&rb->lock);
    80006282:	a3bfa0ef          	jal	80000cbc <acquire>
  
  if(rb->count == 0){ // البفر فارغ تماماً
    80006286:	509c                	lw	a5,32(s1)
    80006288:	cf9d                	beqz	a5,800062c6 <ringbuf_pop+0x54>
  return (void *)(rb->buf + idx * rb->elem_size);
    8000628a:	50d0                	lw	a2,36(s1)
    8000628c:	03048593          	addi	a1,s1,48
    80006290:	4cdc                	lw	a5,28(s1)
    80006292:	02c787bb          	mulw	a5,a5,a2
    80006296:	1782                	slli	a5,a5,0x20
    80006298:	9381                	srli	a5,a5,0x20
    return -1;
  }

  // استخدام الدالة المساعدة slot_ptr الموجودة عندك أصلاً
  void *src = slot_ptr(rb, rb->tail);
  memmove(dst, src, rb->elem_size);
    8000629a:	95be                	add	a1,a1,a5
    8000629c:	854a                	mv	a0,s2
    8000629e:	b4ffa0ef          	jal	80000dec <memmove>
  
  // تحديث المؤشرات بنفس منطق المشروع
  rb->tail = (rb->tail + 1) % RB_CAP;
    800062a2:	4cdc                	lw	a5,28(s1)
    800062a4:	2785                	addiw	a5,a5,1
    800062a6:	1ff7f793          	andi	a5,a5,511
    800062aa:	ccdc                	sw	a5,28(s1)
  rb->count--;
    800062ac:	509c                	lw	a5,32(s1)
    800062ae:	37fd                	addiw	a5,a5,-1
    800062b0:	d09c                	sw	a5,32(s1)
  
  release(&rb->lock);
    800062b2:	8526                	mv	a0,s1
    800062b4:	aa1fa0ef          	jal	80000d54 <release>
  return 0;
    800062b8:	4501                	li	a0,0
} 
    800062ba:	60e2                	ld	ra,24(sp)
    800062bc:	6442                	ld	s0,16(sp)
    800062be:	64a2                	ld	s1,8(sp)
    800062c0:	6902                	ld	s2,0(sp)
    800062c2:	6105                	addi	sp,sp,32
    800062c4:	8082                	ret
    release(&rb->lock);
    800062c6:	8526                	mv	a0,s1
    800062c8:	a8dfa0ef          	jal	80000d54 <release>
    return -1;
    800062cc:	557d                	li	a0,-1
    800062ce:	b7f5                	j	800062ba <ringbuf_pop+0x48>

00000000800062d0 <fslog_init>:
#include "defs.h"

static struct ringbuf fs_rb;
static uint64 fs_seq = 0;

void fslog_init(void) {
    800062d0:	1141                	addi	sp,sp,-16
    800062d2:	e406                	sd	ra,8(sp)
    800062d4:	e022                	sd	s0,0(sp)
    800062d6:	0800                	addi	s0,sp,16
  ringbuf_init(&fs_rb, "fslog", sizeof(struct fs_event));
    800062d8:	03000613          	li	a2,48
    800062dc:	00002597          	auipc	a1,0x2
    800062e0:	48c58593          	addi	a1,a1,1164 # 80008768 <etext+0x768>
    800062e4:	00026517          	auipc	a0,0x26
    800062e8:	79c50513          	addi	a0,a0,1948 # 8002ca80 <fs_rb>
    800062ec:	e6dff0ef          	jal	80006158 <ringbuf_init>
}
    800062f0:	60a2                	ld	ra,8(sp)
    800062f2:	6402                	ld	s0,0(sp)
    800062f4:	0141                	addi	sp,sp,16
    800062f6:	8082                	ret

00000000800062f8 <fslog_push>:

void fslog_push(int type, int inum, int bno, uint size, char* name) {
    800062f8:	7159                	addi	sp,sp,-112
    800062fa:	f486                	sd	ra,104(sp)
    800062fc:	f0a2                	sd	s0,96(sp)
    800062fe:	eca6                	sd	s1,88(sp)
    80006300:	e8ca                	sd	s2,80(sp)
    80006302:	e4ce                	sd	s3,72(sp)
    80006304:	e0d2                	sd	s4,64(sp)
    80006306:	fc56                	sd	s5,56(sp)
    80006308:	1880                	addi	s0,sp,112
    8000630a:	8aaa                	mv	s5,a0
    8000630c:	8a2e                	mv	s4,a1
    8000630e:	89b2                	mv	s3,a2
    80006310:	8936                	mv	s2,a3
    80006312:	84ba                	mv	s1,a4
  struct fs_event e;
  memset(&e, 0, sizeof(e));
    80006314:	03000613          	li	a2,48
    80006318:	4581                	li	a1,0
    8000631a:	f9040513          	addi	a0,s0,-112
    8000631e:	a73fa0ef          	jal	80000d90 <memset>
  e.seq = ++fs_seq;
    80006322:	00005717          	auipc	a4,0x5
    80006326:	3be70713          	addi	a4,a4,958 # 8000b6e0 <fs_seq>
    8000632a:	631c                	ld	a5,0(a4)
    8000632c:	0785                	addi	a5,a5,1
    8000632e:	e31c                	sd	a5,0(a4)
    80006330:	f8f43823          	sd	a5,-112(s0)
  e.ticks = ticks;
    80006334:	00005797          	auipc	a5,0x5
    80006338:	39c7a783          	lw	a5,924(a5) # 8000b6d0 <ticks>
    8000633c:	f8f42c23          	sw	a5,-104(s0)
  e.type = type;
    80006340:	f9542e23          	sw	s5,-100(s0)
  e.pid = myproc() ? myproc()->pid : 0;
    80006344:	88ffb0ef          	jal	80001bd2 <myproc>
    80006348:	4781                	li	a5,0
    8000634a:	c501                	beqz	a0,80006352 <fslog_push+0x5a>
    8000634c:	887fb0ef          	jal	80001bd2 <myproc>
    80006350:	591c                	lw	a5,48(a0)
    80006352:	faf42023          	sw	a5,-96(s0)
  e.inum = inum;
    80006356:	fb442223          	sw	s4,-92(s0)
  e.blockno = bno;
    8000635a:	fb342423          	sw	s3,-88(s0)
  e.size = size;
    8000635e:	fb242623          	sw	s2,-84(s0)
  if(name) safestrcpy(e.name, name, FS_NM);
    80006362:	c499                	beqz	s1,80006370 <fslog_push+0x78>
    80006364:	4641                	li	a2,16
    80006366:	85a6                	mv	a1,s1
    80006368:	fb040513          	addi	a0,s0,-80
    8000636c:	b63fa0ef          	jal	80000ece <safestrcpy>
  ringbuf_push(&fs_rb, &e);
    80006370:	f9040593          	addi	a1,s0,-112
    80006374:	00026517          	auipc	a0,0x26
    80006378:	70c50513          	addi	a0,a0,1804 # 8002ca80 <fs_rb>
    8000637c:	e11ff0ef          	jal	8000618c <ringbuf_push>
}
    80006380:	70a6                	ld	ra,104(sp)
    80006382:	7406                	ld	s0,96(sp)
    80006384:	64e6                	ld	s1,88(sp)
    80006386:	6946                	ld	s2,80(sp)
    80006388:	69a6                	ld	s3,72(sp)
    8000638a:	6a06                	ld	s4,64(sp)
    8000638c:	7ae2                	ld	s5,56(sp)
    8000638e:	6165                	addi	sp,sp,112
    80006390:	8082                	ret

0000000080006392 <fslog_read_many>:
// لا تنسي إضافة fslog_read_many أيضاً هنا

int
fslog_read_many(struct fs_event *out, int max)
{
    80006392:	7159                	addi	sp,sp,-112
    80006394:	f486                	sd	ra,104(sp)
    80006396:	f0a2                	sd	s0,96(sp)
    80006398:	eca6                	sd	s1,88(sp)
    8000639a:	e8ca                	sd	s2,80(sp)
    8000639c:	e4ce                	sd	s3,72(sp)
    8000639e:	1880                	addi	s0,sp,112
    800063a0:	84aa                	mv	s1,a0
    800063a2:	89ae                	mv	s3,a1
  struct fs_event e;
  int count = 0;
  struct proc *p = myproc();
    800063a4:	82ffb0ef          	jal	80001bd2 <myproc>

  while(count < max){
    800063a8:	05305463          	blez	s3,800063f0 <fslog_read_many+0x5e>
    800063ac:	e0d2                	sd	s4,64(sp)
    800063ae:	fc56                	sd	s5,56(sp)
    800063b0:	8a2a                	mv	s4,a0
  int count = 0;
    800063b2:	4901                	li	s2,0
    // سحب حدث واحد من الرينغ بفر (موجود في ذاكرة الكيرنل)
    if(ringbuf_pop(&fs_rb, &e) != 0)
    800063b4:	00026a97          	auipc	s5,0x26
    800063b8:	6cca8a93          	addi	s5,s5,1740 # 8002ca80 <fs_rb>
    800063bc:	f9040593          	addi	a1,s0,-112
    800063c0:	8556                	mv	a0,s5
    800063c2:	eb1ff0ef          	jal	80006272 <ringbuf_pop>
    800063c6:	e51d                	bnez	a0,800063f4 <fslog_read_many+0x62>
      break;

    // 🔥 النسخ الآمن لذاكرة المستخدم باستخدام copyout
    // العنوان الهدف: out + (count * حجم الـ struct)
    uint64 dst_addr = (uint64)out + (count * sizeof(struct fs_event));
    if(copyout(p->pagetable, dst_addr, (char *)&e, sizeof(struct fs_event)) < 0)
    800063c8:	03000693          	li	a3,48
    800063cc:	f9040613          	addi	a2,s0,-112
    800063d0:	85a6                	mv	a1,s1
    800063d2:	050a3503          	ld	a0,80(s4)
    800063d6:	cfcfb0ef          	jal	800018d2 <copyout>
    800063da:	02054763          	bltz	a0,80006408 <fslog_read_many+0x76>
      break;

    count++;
    800063de:	2905                	addiw	s2,s2,1
  while(count < max){
    800063e0:	03048493          	addi	s1,s1,48
    800063e4:	fd299ce3          	bne	s3,s2,800063bc <fslog_read_many+0x2a>
    800063e8:	894e                	mv	s2,s3
    800063ea:	6a06                	ld	s4,64(sp)
    800063ec:	7ae2                	ld	s5,56(sp)
    800063ee:	a029                	j	800063f8 <fslog_read_many+0x66>
  int count = 0;
    800063f0:	4901                	li	s2,0
    800063f2:	a019                	j	800063f8 <fslog_read_many+0x66>
    800063f4:	6a06                	ld	s4,64(sp)
    800063f6:	7ae2                	ld	s5,56(sp)
  }
  return count;
    800063f8:	854a                	mv	a0,s2
    800063fa:	70a6                	ld	ra,104(sp)
    800063fc:	7406                	ld	s0,96(sp)
    800063fe:	64e6                	ld	s1,88(sp)
    80006400:	6946                	ld	s2,80(sp)
    80006402:	69a6                	ld	s3,72(sp)
    80006404:	6165                	addi	sp,sp,112
    80006406:	8082                	ret
    80006408:	6a06                	ld	s4,64(sp)
    8000640a:	7ae2                	ld	s5,56(sp)
    8000640c:	b7f5                	j	800063f8 <fslog_read_many+0x66>

000000008000640e <memlog_init>:
static uint mem_count = 0;
static uint64 mem_seq = 0;

void
memlog_init(void)
{
    8000640e:	1141                	addi	sp,sp,-16
    80006410:	e406                	sd	ra,8(sp)
    80006412:	e022                	sd	s0,0(sp)
    80006414:	0800                	addi	s0,sp,16
  initlock(&mem_lock, "memlog");
    80006416:	00002597          	auipc	a1,0x2
    8000641a:	35a58593          	addi	a1,a1,858 # 80008770 <etext+0x770>
    8000641e:	0002e517          	auipc	a0,0x2e
    80006422:	69250513          	addi	a0,a0,1682 # 80034ab0 <mem_lock>
    80006426:	817fa0ef          	jal	80000c3c <initlock>
  mem_head = 0;
    8000642a:	00005797          	auipc	a5,0x5
    8000642e:	2c07a723          	sw	zero,718(a5) # 8000b6f8 <mem_head>
  mem_tail = 0;
    80006432:	00005797          	auipc	a5,0x5
    80006436:	2c07a123          	sw	zero,706(a5) # 8000b6f4 <mem_tail>
  mem_count = 0;
    8000643a:	00005797          	auipc	a5,0x5
    8000643e:	2a07ab23          	sw	zero,694(a5) # 8000b6f0 <mem_count>
  mem_seq = 0;
    80006442:	00005797          	auipc	a5,0x5
    80006446:	2a07b323          	sd	zero,678(a5) # 8000b6e8 <mem_seq>
}
    8000644a:	60a2                	ld	ra,8(sp)
    8000644c:	6402                	ld	s0,0(sp)
    8000644e:	0141                	addi	sp,sp,16
    80006450:	8082                	ret

0000000080006452 <memlog_push>:

void
memlog_push(struct mem_event *e)
{
    80006452:	1101                	addi	sp,sp,-32
    80006454:	ec06                	sd	ra,24(sp)
    80006456:	e822                	sd	s0,16(sp)
    80006458:	e426                	sd	s1,8(sp)
    8000645a:	1000                	addi	s0,sp,32
    8000645c:	84aa                	mv	s1,a0
  acquire(&mem_lock);
    8000645e:	0002e517          	auipc	a0,0x2e
    80006462:	65250513          	addi	a0,a0,1618 # 80034ab0 <mem_lock>
    80006466:	857fa0ef          	jal	80000cbc <acquire>

  e->seq = ++mem_seq;
    8000646a:	00005717          	auipc	a4,0x5
    8000646e:	27e70713          	addi	a4,a4,638 # 8000b6e8 <mem_seq>
    80006472:	631c                	ld	a5,0(a4)
    80006474:	0785                	addi	a5,a5,1
    80006476:	e31c                	sd	a5,0(a4)
    80006478:	e09c                	sd	a5,0(s1)

  if(mem_count == MEM_RB_CAP){
    8000647a:	00005717          	auipc	a4,0x5
    8000647e:	27672703          	lw	a4,630(a4) # 8000b6f0 <mem_count>
    80006482:	20000793          	li	a5,512
    80006486:	08f70063          	beq	a4,a5,80006506 <memlog_push+0xb4>
    mem_tail = (mem_tail + 1) % MEM_RB_CAP;
    mem_count--;
  }

  mem_buf[mem_head] = *e;
    8000648a:	00005697          	auipc	a3,0x5
    8000648e:	26e6a683          	lw	a3,622(a3) # 8000b6f8 <mem_head>
    80006492:	02069613          	slli	a2,a3,0x20
    80006496:	9201                	srli	a2,a2,0x20
    80006498:	06800793          	li	a5,104
    8000649c:	02f60633          	mul	a2,a2,a5
    800064a0:	8726                	mv	a4,s1
    800064a2:	0002e797          	auipc	a5,0x2e
    800064a6:	62678793          	addi	a5,a5,1574 # 80034ac8 <mem_buf>
    800064aa:	97b2                	add	a5,a5,a2
    800064ac:	06048493          	addi	s1,s1,96
    800064b0:	00073803          	ld	a6,0(a4)
    800064b4:	6708                	ld	a0,8(a4)
    800064b6:	6b0c                	ld	a1,16(a4)
    800064b8:	6f10                	ld	a2,24(a4)
    800064ba:	0107b023          	sd	a6,0(a5)
    800064be:	e788                	sd	a0,8(a5)
    800064c0:	eb8c                	sd	a1,16(a5)
    800064c2:	ef90                	sd	a2,24(a5)
    800064c4:	02070713          	addi	a4,a4,32
    800064c8:	02078793          	addi	a5,a5,32
    800064cc:	fe9712e3          	bne	a4,s1,800064b0 <memlog_push+0x5e>
    800064d0:	6318                	ld	a4,0(a4)
    800064d2:	e398                	sd	a4,0(a5)
  mem_head = (mem_head + 1) % MEM_RB_CAP;
    800064d4:	2685                	addiw	a3,a3,1
    800064d6:	1ff6f693          	andi	a3,a3,511
    800064da:	00005797          	auipc	a5,0x5
    800064de:	20d7af23          	sw	a3,542(a5) # 8000b6f8 <mem_head>
  mem_count++;
    800064e2:	00005717          	auipc	a4,0x5
    800064e6:	20e70713          	addi	a4,a4,526 # 8000b6f0 <mem_count>
    800064ea:	431c                	lw	a5,0(a4)
    800064ec:	2785                	addiw	a5,a5,1
    800064ee:	c31c                	sw	a5,0(a4)

  release(&mem_lock);
    800064f0:	0002e517          	auipc	a0,0x2e
    800064f4:	5c050513          	addi	a0,a0,1472 # 80034ab0 <mem_lock>
    800064f8:	85dfa0ef          	jal	80000d54 <release>
}
    800064fc:	60e2                	ld	ra,24(sp)
    800064fe:	6442                	ld	s0,16(sp)
    80006500:	64a2                	ld	s1,8(sp)
    80006502:	6105                	addi	sp,sp,32
    80006504:	8082                	ret
    mem_tail = (mem_tail + 1) % MEM_RB_CAP;
    80006506:	00005717          	auipc	a4,0x5
    8000650a:	1ee70713          	addi	a4,a4,494 # 8000b6f4 <mem_tail>
    8000650e:	431c                	lw	a5,0(a4)
    80006510:	2785                	addiw	a5,a5,1
    80006512:	1ff7f793          	andi	a5,a5,511
    80006516:	c31c                	sw	a5,0(a4)
    mem_count--;
    80006518:	1ff00793          	li	a5,511
    8000651c:	00005717          	auipc	a4,0x5
    80006520:	1cf72a23          	sw	a5,468(a4) # 8000b6f0 <mem_count>
    80006524:	b79d                	j	8000648a <memlog_push+0x38>

0000000080006526 <memlog_read_many>:

int
memlog_read_many(struct mem_event *out, int max)
{
    80006526:	1101                	addi	sp,sp,-32
    80006528:	ec06                	sd	ra,24(sp)
    8000652a:	e822                	sd	s0,16(sp)
    8000652c:	e426                	sd	s1,8(sp)
    8000652e:	1000                	addi	s0,sp,32
  int n = 0;

  if(max <= 0)
    return 0;
    80006530:	4481                	li	s1,0
  if(max <= 0)
    80006532:	0ab05963          	blez	a1,800065e4 <memlog_read_many+0xbe>
    80006536:	e04a                	sd	s2,0(sp)
    80006538:	84aa                	mv	s1,a0
    8000653a:	892e                	mv	s2,a1

  acquire(&mem_lock);
    8000653c:	0002e517          	auipc	a0,0x2e
    80006540:	57450513          	addi	a0,a0,1396 # 80034ab0 <mem_lock>
    80006544:	f78fa0ef          	jal	80000cbc <acquire>
  while(n < max && mem_count > 0){
    80006548:	00005697          	auipc	a3,0x5
    8000654c:	1ac6a683          	lw	a3,428(a3) # 8000b6f4 <mem_tail>
    80006550:	00005617          	auipc	a2,0x5
    80006554:	1a062603          	lw	a2,416(a2) # 8000b6f0 <mem_count>
    80006558:	8526                	mv	a0,s1
  acquire(&mem_lock);
    8000655a:	4701                	li	a4,0
  int n = 0;
    8000655c:	4481                	li	s1,0
    out[n] = mem_buf[mem_tail];
    8000655e:	0002ef97          	auipc	t6,0x2e
    80006562:	56af8f93          	addi	t6,t6,1386 # 80034ac8 <mem_buf>
    80006566:	06800f13          	li	t5,104
    8000656a:	4e85                	li	t4,1
  while(n < max && mem_count > 0){
    8000656c:	c251                	beqz	a2,800065f0 <memlog_read_many+0xca>
    out[n] = mem_buf[mem_tail];
    8000656e:	02069793          	slli	a5,a3,0x20
    80006572:	9381                	srli	a5,a5,0x20
    80006574:	03e787b3          	mul	a5,a5,t5
    80006578:	97fe                	add	a5,a5,t6
    8000657a:	872a                	mv	a4,a0
    8000657c:	06078e13          	addi	t3,a5,96
    80006580:	0007b303          	ld	t1,0(a5)
    80006584:	0087b883          	ld	a7,8(a5)
    80006588:	0107b803          	ld	a6,16(a5)
    8000658c:	6f8c                	ld	a1,24(a5)
    8000658e:	00673023          	sd	t1,0(a4)
    80006592:	01173423          	sd	a7,8(a4)
    80006596:	01073823          	sd	a6,16(a4)
    8000659a:	ef0c                	sd	a1,24(a4)
    8000659c:	02078793          	addi	a5,a5,32
    800065a0:	02070713          	addi	a4,a4,32
    800065a4:	fdc79ee3          	bne	a5,t3,80006580 <memlog_read_many+0x5a>
    800065a8:	639c                	ld	a5,0(a5)
    800065aa:	e31c                	sd	a5,0(a4)
    mem_tail = (mem_tail + 1) % MEM_RB_CAP;
    800065ac:	2685                	addiw	a3,a3,1
    800065ae:	1ff6f693          	andi	a3,a3,511
    mem_count--;
    800065b2:	fff6079b          	addiw	a5,a2,-1
    800065b6:	0007861b          	sext.w	a2,a5
    n++;
    800065ba:	2485                	addiw	s1,s1,1
  while(n < max && mem_count > 0){
    800065bc:	06850513          	addi	a0,a0,104
    800065c0:	8776                	mv	a4,t4
    800065c2:	fa9915e3          	bne	s2,s1,8000656c <memlog_read_many+0x46>
    800065c6:	00005717          	auipc	a4,0x5
    800065ca:	12d72723          	sw	a3,302(a4) # 8000b6f4 <mem_tail>
    800065ce:	00005717          	auipc	a4,0x5
    800065d2:	12f72123          	sw	a5,290(a4) # 8000b6f0 <mem_count>
  }
  release(&mem_lock);
    800065d6:	0002e517          	auipc	a0,0x2e
    800065da:	4da50513          	addi	a0,a0,1242 # 80034ab0 <mem_lock>
    800065de:	f76fa0ef          	jal	80000d54 <release>

  return n;
    800065e2:	6902                	ld	s2,0(sp)
    800065e4:	8526                	mv	a0,s1
    800065e6:	60e2                	ld	ra,24(sp)
    800065e8:	6442                	ld	s0,16(sp)
    800065ea:	64a2                	ld	s1,8(sp)
    800065ec:	6105                	addi	sp,sp,32
    800065ee:	8082                	ret
    800065f0:	d37d                	beqz	a4,800065d6 <memlog_read_many+0xb0>
    800065f2:	00005797          	auipc	a5,0x5
    800065f6:	10d7a123          	sw	a3,258(a5) # 8000b6f4 <mem_tail>
    800065fa:	00005797          	auipc	a5,0x5
    800065fe:	0e07ab23          	sw	zero,246(a5) # 8000b6f0 <mem_count>
    80006602:	bfd1                	j	800065d6 <memlog_read_many+0xb0>

0000000080006604 <sys_memread>:
#include "memevent.h"
#include "memlog.h"

uint64
sys_memread(void)
{
    80006604:	95010113          	addi	sp,sp,-1712
    80006608:	6a113423          	sd	ra,1704(sp)
    8000660c:	6a813023          	sd	s0,1696(sp)
    80006610:	6b010413          	addi	s0,sp,1712
  uint64 uaddr = 0;
    80006614:	fc043c23          	sd	zero,-40(s0)
  int max = 0;
    80006618:	fc042a23          	sw	zero,-44(s0)

  argaddr(0, &uaddr);
    8000661c:	fd840593          	addi	a1,s0,-40
    80006620:	4501                	li	a0,0
    80006622:	ef4fc0ef          	jal	80002d16 <argaddr>
  argint(1, &max);
    80006626:	fd440593          	addi	a1,s0,-44
    8000662a:	4505                	li	a0,1
    8000662c:	ecefc0ef          	jal	80002cfa <argint>

  if(max <= 0)
    80006630:	fd442783          	lw	a5,-44(s0)
    return 0;
    80006634:	4501                	li	a0,0
  if(max <= 0)
    80006636:	04f05363          	blez	a5,8000667c <sys_memread+0x78>
    8000663a:	68913c23          	sd	s1,1688(sp)
  if(max > 16)
    8000663e:	4741                	li	a4,16
    80006640:	00f75563          	bge	a4,a5,8000664a <sys_memread+0x46>
    max = 16;
    80006644:	47c1                	li	a5,16
    80006646:	fcf42a23          	sw	a5,-44(s0)

  struct mem_event tmp[16];
  int n = memlog_read_many(tmp, max);
    8000664a:	fd442583          	lw	a1,-44(s0)
    8000664e:	95040513          	addi	a0,s0,-1712
    80006652:	ed5ff0ef          	jal	80006526 <memlog_read_many>
    80006656:	84aa                	mv	s1,a0

  int bytes = n * (int)sizeof(struct mem_event);
  if(copyout(myproc()->pagetable, uaddr, (char *)tmp, bytes) < 0)
    80006658:	d7afb0ef          	jal	80001bd2 <myproc>
    8000665c:	06800693          	li	a3,104
    80006660:	029686bb          	mulw	a3,a3,s1
    80006664:	95040613          	addi	a2,s0,-1712
    80006668:	fd843583          	ld	a1,-40(s0)
    8000666c:	6928                	ld	a0,80(a0)
    8000666e:	a64fb0ef          	jal	800018d2 <copyout>
    80006672:	00054c63          	bltz	a0,8000668a <sys_memread+0x86>
    return -1;

  return n;
    80006676:	8526                	mv	a0,s1
    80006678:	69813483          	ld	s1,1688(sp)
    8000667c:	6a813083          	ld	ra,1704(sp)
    80006680:	6a013403          	ld	s0,1696(sp)
    80006684:	6b010113          	addi	sp,sp,1712
    80006688:	8082                	ret
    return -1;
    8000668a:	557d                	li	a0,-1
    8000668c:	69813483          	ld	s1,1688(sp)
    80006690:	b7f5                	j	8000667c <sys_memread+0x78>

0000000080006692 <schedlog_init>:

static struct ringbuf sched_rb;

void
schedlog_init(void)
{
    80006692:	1141                	addi	sp,sp,-16
    80006694:	e406                	sd	ra,8(sp)
    80006696:	e022                	sd	s0,0(sp)
    80006698:	0800                	addi	s0,sp,16
  ringbuf_init(&sched_rb, "schedlog", sizeof(struct sched_event));
    8000669a:	04400613          	li	a2,68
    8000669e:	00002597          	auipc	a1,0x2
    800066a2:	0da58593          	addi	a1,a1,218 # 80008778 <etext+0x778>
    800066a6:	0003b517          	auipc	a0,0x3b
    800066aa:	42250513          	addi	a0,a0,1058 # 80041ac8 <sched_rb>
    800066ae:	aabff0ef          	jal	80006158 <ringbuf_init>
}
    800066b2:	60a2                	ld	ra,8(sp)
    800066b4:	6402                	ld	s0,0(sp)
    800066b6:	0141                	addi	sp,sp,16
    800066b8:	8082                	ret

00000000800066ba <schedlog_emit>:

void
schedlog_emit(struct sched_event *e)
{
    800066ba:	711d                	addi	sp,sp,-96
    800066bc:	ec86                	sd	ra,88(sp)
    800066be:	e8a2                	sd	s0,80(sp)
    800066c0:	1080                	addi	s0,sp,96
    800066c2:	85aa                	mv	a1,a0
  struct sched_event copy;

  memmove(&copy, e, sizeof(copy));
    800066c4:	04400613          	li	a2,68
    800066c8:	fa840513          	addi	a0,s0,-88
    800066cc:	f20fa0ef          	jal	80000dec <memmove>
  copy.seq = sched_rb.seq++;
    800066d0:	0003b517          	auipc	a0,0x3b
    800066d4:	3f850513          	addi	a0,a0,1016 # 80041ac8 <sched_rb>
    800066d8:	751c                	ld	a5,40(a0)
    800066da:	00178713          	addi	a4,a5,1
    800066de:	f518                	sd	a4,40(a0)
    800066e0:	faf42423          	sw	a5,-88(s0)
  ringbuf_push(&sched_rb, &copy);
    800066e4:	fa840593          	addi	a1,s0,-88
    800066e8:	aa5ff0ef          	jal	8000618c <ringbuf_push>
}
    800066ec:	60e6                	ld	ra,88(sp)
    800066ee:	6446                	ld	s0,80(sp)
    800066f0:	6125                	addi	sp,sp,96
    800066f2:	8082                	ret

00000000800066f4 <schedread>:

int
schedread(struct sched_event *dst, int max)
{
    800066f4:	1141                	addi	sp,sp,-16
    800066f6:	e406                	sd	ra,8(sp)
    800066f8:	e022                	sd	s0,0(sp)
    800066fa:	0800                	addi	s0,sp,16
    800066fc:	862e                	mv	a2,a1
  return ringbuf_read_many(&sched_rb, dst, max);
    800066fe:	85aa                	mv	a1,a0
    80006700:	0003b517          	auipc	a0,0x3b
    80006704:	3c850513          	addi	a0,a0,968 # 80041ac8 <sched_rb>
    80006708:	af1ff0ef          	jal	800061f8 <ringbuf_read_many>
    8000670c:	60a2                	ld	ra,8(sp)
    8000670e:	6402                	ld	s0,0(sp)
    80006710:	0141                	addi	sp,sp,16
    80006712:	8082                	ret
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
