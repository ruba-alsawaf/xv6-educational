
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
    8000006e:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffb791f>
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
    800000e6:	00011517          	auipc	a0,0x11
    800000ea:	87a50513          	addi	a0,a0,-1926 # 80010960 <conswlock>
    800000ee:	6ae040ef          	jal	8000479c <acquiresleep>

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
    8000011e:	7fa020ef          	jal	80002918 <either_copyin>
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
    80000162:	00010517          	auipc	a0,0x10
    80000166:	7fe50513          	addi	a0,a0,2046 # 80010960 <conswlock>
    8000016a:	678040ef          	jal	800047e2 <releasesleep>
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
    800001a0:	00010517          	auipc	a0,0x10
    800001a4:	7f050513          	addi	a0,a0,2032 # 80010990 <cons>
    800001a8:	315000ef          	jal	80000cbc <acquire>

  while(n > 0){
    while(cons.r == cons.w){
    800001ac:	00010497          	auipc	s1,0x10
    800001b0:	7b448493          	addi	s1,s1,1972 # 80010960 <conswlock>
      if(killed(myproc())){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    800001b4:	00010997          	auipc	s3,0x10
    800001b8:	7dc98993          	addi	s3,s3,2012 # 80010990 <cons>
    800001bc:	00011917          	auipc	s2,0x11
    800001c0:	86c90913          	addi	s2,s2,-1940 # 80010a28 <cons+0x98>
  while(n > 0){
    800001c4:	0b405e63          	blez	s4,80000280 <consoleread+0x100>
    while(cons.r == cons.w){
    800001c8:	0c84a783          	lw	a5,200(s1)
    800001cc:	0cc4a703          	lw	a4,204(s1)
    800001d0:	0af71363          	bne	a4,a5,80000276 <consoleread+0xf6>
      if(killed(myproc())){
    800001d4:	2b3010ef          	jal	80001c86 <myproc>
    800001d8:	5d2020ef          	jal	800027aa <killed>
    800001dc:	e12d                	bnez	a0,8000023e <consoleread+0xbe>
      sleep(&cons.r, &cons.lock);
    800001de:	85ce                	mv	a1,s3
    800001e0:	854a                	mv	a0,s2
    800001e2:	36a020ef          	jal	8000254c <sleep>
    while(cons.r == cons.w){
    800001e6:	0c84a783          	lw	a5,200(s1)
    800001ea:	0cc4a703          	lw	a4,204(s1)
    800001ee:	fef703e3          	beq	a4,a5,800001d4 <consoleread+0x54>
    800001f2:	e862                	sd	s8,16(sp)
    }

    c = cons.buf[cons.r++ % INPUT_BUF_SIZE];
    800001f4:	00010717          	auipc	a4,0x10
    800001f8:	76c70713          	addi	a4,a4,1900 # 80010960 <conswlock>
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
    80000226:	6a8020ef          	jal	800028ce <either_copyout>
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
    8000023e:	00010517          	auipc	a0,0x10
    80000242:	75250513          	addi	a0,a0,1874 # 80010990 <cons>
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
    8000026a:	00010717          	auipc	a4,0x10
    8000026e:	7af72f23          	sw	a5,1982(a4) # 80010a28 <cons+0x98>
    80000272:	6c42                	ld	s8,16(sp)
    80000274:	a031                	j	80000280 <consoleread+0x100>
    80000276:	e862                	sd	s8,16(sp)
    80000278:	bfb5                	j	800001f4 <consoleread+0x74>
    8000027a:	6c42                	ld	s8,16(sp)
    8000027c:	a011                	j	80000280 <consoleread+0x100>
    8000027e:	6c42                	ld	s8,16(sp)
  release(&cons.lock);
    80000280:	00010517          	auipc	a0,0x10
    80000284:	71050513          	addi	a0,a0,1808 # 80010990 <cons>
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
    800002d4:	00010517          	auipc	a0,0x10
    800002d8:	6bc50513          	addi	a0,a0,1724 # 80010990 <cons>
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
    800002f6:	66c020ef          	jal	80002962 <procdump>
      }
    }
    break;
  }

  release(&cons.lock);
    800002fa:	00010517          	auipc	a0,0x10
    800002fe:	69650513          	addi	a0,a0,1686 # 80010990 <cons>
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
    80000318:	00010717          	auipc	a4,0x10
    8000031c:	64870713          	addi	a4,a4,1608 # 80010960 <conswlock>
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
    8000033e:	00010797          	auipc	a5,0x10
    80000342:	62278793          	addi	a5,a5,1570 # 80010960 <conswlock>
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
    8000036c:	00010797          	auipc	a5,0x10
    80000370:	6bc7a783          	lw	a5,1724(a5) # 80010a28 <cons+0x98>
    80000374:	9f1d                	subw	a4,a4,a5
    80000376:	08000793          	li	a5,128
    8000037a:	f8f710e3          	bne	a4,a5,800002fa <consoleintr+0x32>
    8000037e:	a07d                	j	8000042c <consoleintr+0x164>
    80000380:	e04a                	sd	s2,0(sp)
    while(cons.e != cons.w &&
    80000382:	00010717          	auipc	a4,0x10
    80000386:	5de70713          	addi	a4,a4,1502 # 80010960 <conswlock>
    8000038a:	0d072783          	lw	a5,208(a4)
    8000038e:	0cc72703          	lw	a4,204(a4)
          cons.buf[(cons.e - 1) % INPUT_BUF_SIZE] != '\n'){
    80000392:	00010497          	auipc	s1,0x10
    80000396:	5ce48493          	addi	s1,s1,1486 # 80010960 <conswlock>
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
    800003d4:	00010717          	auipc	a4,0x10
    800003d8:	58c70713          	addi	a4,a4,1420 # 80010960 <conswlock>
    800003dc:	0d072783          	lw	a5,208(a4)
    800003e0:	0cc72703          	lw	a4,204(a4)
    800003e4:	f0f70be3          	beq	a4,a5,800002fa <consoleintr+0x32>
      cons.e--;
    800003e8:	37fd                	addiw	a5,a5,-1
    800003ea:	00010717          	auipc	a4,0x10
    800003ee:	64f72323          	sw	a5,1606(a4) # 80010a30 <cons+0xa0>
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
    80000408:	00010797          	auipc	a5,0x10
    8000040c:	55878793          	addi	a5,a5,1368 # 80010960 <conswlock>
    80000410:	0d07a703          	lw	a4,208(a5)
    80000414:	0017069b          	addiw	a3,a4,1
    80000418:	0006861b          	sext.w	a2,a3
    8000041c:	0cd7a823          	sw	a3,208(a5)
    80000420:	07f77713          	andi	a4,a4,127
    80000424:	97ba                	add	a5,a5,a4
    80000426:	4729                	li	a4,10
    80000428:	04e78423          	sb	a4,72(a5)
        cons.w = cons.e;
    8000042c:	00010797          	auipc	a5,0x10
    80000430:	60c7a023          	sw	a2,1536(a5) # 80010a2c <cons+0x9c>
        wakeup(&cons.r);
    80000434:	00010517          	auipc	a0,0x10
    80000438:	5f450513          	addi	a0,a0,1524 # 80010a28 <cons+0x98>
    8000043c:	160020ef          	jal	8000259c <wakeup>
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
    80000452:	00010517          	auipc	a0,0x10
    80000456:	53e50513          	addi	a0,a0,1342 # 80010990 <cons>
    8000045a:	7e2000ef          	jal	80000c3c <initlock>
  initsleeplock(&conswlock, "consw");
    8000045e:	00008597          	auipc	a1,0x8
    80000462:	bb258593          	addi	a1,a1,-1102 # 80008010 <etext+0x10>
    80000466:	00010517          	auipc	a0,0x10
    8000046a:	4fa50513          	addi	a0,a0,1274 # 80010960 <conswlock>
    8000046e:	2f8040ef          	jal	80004766 <initsleeplock>

  uartinit();
    80000472:	400000ef          	jal	80000872 <uartinit>

  devsw[CONSOLE].read = consoleread;
    80000476:	00021797          	auipc	a5,0x21
    8000047a:	82a78793          	addi	a5,a5,-2006 # 80020ca0 <devsw>
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
    800004b4:	2e860613          	addi	a2,a2,744 # 80008798 <digits>
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
    8000054a:	00008797          	auipc	a5,0x8
    8000054e:	3aa7a783          	lw	a5,938(a5) # 800088f4 <panicking>
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
    80000592:	00010517          	auipc	a0,0x10
    80000596:	4a650513          	addi	a0,a0,1190 # 80010a38 <pr>
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
    8000075e:	03eb8b93          	addi	s7,s7,62 # 80008798 <digits>
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
    800007ee:	00008797          	auipc	a5,0x8
    800007f2:	1067a783          	lw	a5,262(a5) # 800088f4 <panicking>
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
    80000804:	00010517          	auipc	a0,0x10
    80000808:	23450513          	addi	a0,a0,564 # 80010a38 <pr>
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
    80000822:	00008797          	auipc	a5,0x8
    80000826:	0d27a923          	sw	s2,210(a5) # 800088f4 <panicking>
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
    80000844:	00008797          	auipc	a5,0x8
    80000848:	0b27a623          	sw	s2,172(a5) # 800088f0 <panicked>
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
    8000085e:	00010517          	auipc	a0,0x10
    80000862:	1da50513          	addi	a0,a0,474 # 80010a38 <pr>
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
    800008b6:	00010517          	auipc	a0,0x10
    800008ba:	19a50513          	addi	a0,a0,410 # 80010a50 <tx_lock>
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
    800008da:	00010517          	auipc	a0,0x10
    800008de:	17650513          	addi	a0,a0,374 # 80010a50 <tx_lock>
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
    800008f8:	00008497          	auipc	s1,0x8
    800008fc:	00448493          	addi	s1,s1,4 # 800088fc <tx_busy>
      // wait for a UART transmit-complete interrupt
      // to set tx_busy to 0.
      sleep(&tx_chan, &tx_lock);
    80000900:	00010997          	auipc	s3,0x10
    80000904:	15098993          	addi	s3,s3,336 # 80010a50 <tx_lock>
    80000908:	00008917          	auipc	s2,0x8
    8000090c:	ff090913          	addi	s2,s2,-16 # 800088f8 <tx_chan>
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
    8000091c:	431010ef          	jal	8000254c <sleep>
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
    80000946:	00010517          	auipc	a0,0x10
    8000094a:	10a50513          	addi	a0,a0,266 # 80010a50 <tx_lock>
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
    8000096a:	00008797          	auipc	a5,0x8
    8000096e:	f8a7a783          	lw	a5,-118(a5) # 800088f4 <panicking>
    80000972:	cf95                	beqz	a5,800009ae <uartputc_sync+0x50>
    push_off();

  if(panicked){
    80000974:	00008797          	auipc	a5,0x8
    80000978:	f7c7a783          	lw	a5,-132(a5) # 800088f0 <panicked>
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
    8000099a:	00008797          	auipc	a5,0x8
    8000099e:	f5a7a783          	lw	a5,-166(a5) # 800088f4 <panicking>
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
    800009f6:	00010517          	auipc	a0,0x10
    800009fa:	05a50513          	addi	a0,a0,90 # 80010a50 <tx_lock>
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
    80000a12:	00010517          	auipc	a0,0x10
    80000a16:	03e50513          	addi	a0,a0,62 # 80010a50 <tx_lock>
    80000a1a:	33a000ef          	jal	80000d54 <release>

  // read and process incoming characters, if any.
  while(1){
    int c = uartgetc();
    if(c == -1)
    80000a1e:	54fd                	li	s1,-1
    80000a20:	a831                	j	80000a3c <uartintr+0x5a>
    tx_busy = 0;
    80000a22:	00008797          	auipc	a5,0x8
    80000a26:	ec07ad23          	sw	zero,-294(a5) # 800088fc <tx_busy>
    wakeup(&tx_chan);
    80000a2a:	00008517          	auipc	a0,0x8
    80000a2e:	ece50513          	addi	a0,a0,-306 # 800088f8 <tx_chan>
    80000a32:	36b010ef          	jal	8000259c <wakeup>
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
    80000a62:	00046797          	auipc	a5,0x46
    80000a66:	47e78793          	addi	a5,a5,1150 # 80046ee0 <end>
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
    80000a7e:	00010917          	auipc	s2,0x10
    80000a82:	fea90913          	addi	s2,s2,-22 # 80010a68 <kmem>
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
    80000aaa:	00008797          	auipc	a5,0x8
    80000aae:	e867a783          	lw	a5,-378(a5) # 80008930 <ticks>
    80000ab2:	f8f42023          	sw	a5,-128(s0)
  e.cpu    = cpuid();
    80000ab6:	19e010ef          	jal	80001c54 <cpuid>
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
    80000ad2:	1b4010ef          	jal	80001c86 <myproc>
  if(p){
    80000ad6:	cd11                	beqz	a0,80000af2 <kfree+0xa4>
    e.pid = p->pid;
    80000ad8:	595c                	lw	a5,52(a0)
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
    80000af6:	50b050ef          	jal	80006800 <memlog_push>
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
    80000b6a:	00010517          	auipc	a0,0x10
    80000b6e:	efe50513          	addi	a0,a0,-258 # 80010a68 <kmem>
    80000b72:	0ca000ef          	jal	80000c3c <initlock>
  freerange(end, (void*)PHYSTOP);
    80000b76:	45c5                	li	a1,17
    80000b78:	05ee                	slli	a1,a1,0x1b
    80000b7a:	00046517          	auipc	a0,0x46
    80000b7e:	36650513          	addi	a0,a0,870 # 80046ee0 <end>
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
    80000b98:	00010497          	auipc	s1,0x10
    80000b9c:	ed048493          	addi	s1,s1,-304 # 80010a68 <kmem>
    80000ba0:	8526                	mv	a0,s1
    80000ba2:	11a000ef          	jal	80000cbc <acquire>
  r = kmem.freelist;
    80000ba6:	6c84                	ld	s1,24(s1)
  if(r)
    80000ba8:	c0d9                	beqz	s1,80000c2e <kalloc+0xa0>
    kmem.freelist = r->next;
    80000baa:	609c                	ld	a5,0(s1)
    80000bac:	00010517          	auipc	a0,0x10
    80000bb0:	ebc50513          	addi	a0,a0,-324 # 80010a68 <kmem>
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
    80000bd2:	00008797          	auipc	a5,0x8
    80000bd6:	d5e7a783          	lw	a5,-674(a5) # 80008930 <ticks>
    80000bda:	f8f42023          	sw	a5,-128(s0)
    e.cpu    = cpuid();
    80000bde:	076010ef          	jal	80001c54 <cpuid>
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
    80000bfa:	08c010ef          	jal	80001c86 <myproc>
    if(p){
    80000bfe:	cd11                	beqz	a0,80000c1a <kalloc+0x8c>
      e.pid = p->pid;
    80000c00:	595c                	lw	a5,52(a0)
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
    80000c1e:	3e3050ef          	jal	80006800 <memlog_push>
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
    80000c2e:	00010517          	auipc	a0,0x10
    80000c32:	e3a50513          	addi	a0,a0,-454 # 80010a68 <kmem>
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
    80000c66:	7ff000ef          	jal	80001c64 <mycpu>
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
    80000c94:	7d1000ef          	jal	80001c64 <mycpu>
    80000c98:	5d3c                	lw	a5,120(a0)
    80000c9a:	cb99                	beqz	a5,80000cb0 <push_off+0x34>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000c9c:	7c9000ef          	jal	80001c64 <mycpu>
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
    80000cb0:	7b5000ef          	jal	80001c64 <mycpu>
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
    80000ce0:	0ff0000f          	fence
  lk->cpu = mycpu();
    80000ce4:	781000ef          	jal	80001c64 <mycpu>
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
    80000d08:	75d000ef          	jal	80001c64 <mycpu>
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
    80000d6a:	0ff0000f          	fence
  __sync_lock_release(&lk->locked);
    80000d6e:	0f50000f          	fence	iorw,ow
    80000d72:	0804a02f          	amoswap.w	zero,zero,(s1)
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
    80000e04:	0705                	addi	a4,a4,1 # fffffffffffff001 <end+0xffffffff7ffb8121>
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
    80000f32:	523000ef          	jal	80001c54 <cpuid>
    memlog_init();
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    80000f36:	00008717          	auipc	a4,0x8
    80000f3a:	9ca70713          	addi	a4,a4,-1590 # 80008900 <started>
  if(cpuid() == 0){
    80000f3e:	c529                	beqz	a0,80000f88 <main+0x5e>
    while(started == 0)
    80000f40:	431c                	lw	a5,0(a4)
    80000f42:	2781                	sext.w	a5,a5
    80000f44:	dff5                	beqz	a5,80000f40 <main+0x16>
      ;
    __sync_synchronize();
    80000f46:	0ff0000f          	fence
    printf("hart %d starting\n", cpuid());
    80000f4a:	50b000ef          	jal	80001c54 <cpuid>
    80000f4e:	85aa                	mv	a1,a0
    80000f50:	00007517          	auipc	a0,0x7
    80000f54:	15050513          	addi	a0,a0,336 # 800080a0 <etext+0xa0>
    80000f58:	dd4ff0ef          	jal	8000052c <printf>
    kvminithart();    // turn on paging
    80000f5c:	0a8000ef          	jal	80001004 <kvminithart>
    trapinithart();   // install kernel trap vector
    80000f60:	335010ef          	jal	80002a94 <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000f64:	605040ef          	jal	80005d68 <plicinithart>
  }

  cpus[cpuid()].active = 1;
    80000f68:	4ed000ef          	jal	80001c54 <cpuid>
    80000f6c:	0a800793          	li	a5,168
    80000f70:	02f50533          	mul	a0,a0,a5
    80000f74:	00010797          	auipc	a5,0x10
    80000f78:	ba478793          	addi	a5,a5,-1116 # 80010b18 <cpus>
    80000f7c:	97aa                	add	a5,a5,a0
    80000f7e:	4705                	li	a4,1
    80000f80:	08e7a023          	sw	a4,128(a5)
  scheduler();        
    80000f84:	216010ef          	jal	8000219a <scheduler>
    consoleinit();
    80000f88:	cbaff0ef          	jal	80000442 <consoleinit>
    printfinit();
    80000f8c:	8c3ff0ef          	jal	8000084e <printfinit>
    printf("\n");
    80000f90:	00007517          	auipc	a0,0x7
    80000f94:	0f050513          	addi	a0,a0,240 # 80008080 <etext+0x80>
    80000f98:	d94ff0ef          	jal	8000052c <printf>
    printf("xv6 kernel is booting\n");
    80000f9c:	00007517          	auipc	a0,0x7
    80000fa0:	0ec50513          	addi	a0,a0,236 # 80008088 <etext+0x88>
    80000fa4:	d88ff0ef          	jal	8000052c <printf>
    printf("\n");
    80000fa8:	00007517          	auipc	a0,0x7
    80000fac:	0d850513          	addi	a0,a0,216 # 80008080 <etext+0x80>
    80000fb0:	d7cff0ef          	jal	8000052c <printf>
    kinit();         // physical page allocator
    80000fb4:	ba7ff0ef          	jal	80000b5a <kinit>
    kvminit();       // create kernel page table
    80000fb8:	35c000ef          	jal	80001314 <kvminit>
    kvminithart();   // turn on paging
    80000fbc:	048000ef          	jal	80001004 <kvminithart>
    procinit();      // process table
    80000fc0:	3b3000ef          	jal	80001b72 <procinit>
    schedlog_init();
    80000fc4:	27d050ef          	jal	80006a40 <schedlog_init>
    trapinit();      // trap vectors
    80000fc8:	2a9010ef          	jal	80002a70 <trapinit>
    trapinithart();  // install kernel trap vector
    80000fcc:	2c9010ef          	jal	80002a94 <trapinithart>
    plicinit();      // set up interrupt controller
    80000fd0:	57f040ef          	jal	80005d4e <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000fd4:	595040ef          	jal	80005d68 <plicinithart>
    binit();         // buffer cache
    80000fd8:	3ce020ef          	jal	800033a6 <binit>
    iinit();         // inode table
    80000fdc:	193020ef          	jal	8000396e <iinit>
    fileinit();      // file table
    80000fe0:	085030ef          	jal	80004864 <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000fe4:	675040ef          	jal	80005e58 <virtio_disk_init>
    cslog_init();
    80000fe8:	322050ef          	jal	8000630a <cslog_init>
    memlog_init();
    80000fec:	7d0050ef          	jal	800067bc <memlog_init>
    userinit();      // first user process
    80000ff0:	78d000ef          	jal	80001f7c <userinit>
    __sync_synchronize();
    80000ff4:	0ff0000f          	fence
    started = 1;
    80000ff8:	4785                	li	a5,1
    80000ffa:	00008717          	auipc	a4,0x8
    80000ffe:	90f72323          	sw	a5,-1786(a4) # 80008900 <started>
    80001002:	b79d                	j	80000f68 <main+0x3e>

0000000080001004 <kvminithart>:

// Switch the current CPU's h/w page table register to
// the kernel's page table, and enable paging.
void
kvminithart()
{
    80001004:	1141                	addi	sp,sp,-16
    80001006:	e422                	sd	s0,8(sp)
    80001008:	0800                	addi	s0,sp,16
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero");
    8000100a:	12000073          	sfence.vma
  // wait for any previous writes to the page table memory to finish.
  sfence_vma();

  w_satp(MAKE_SATP(kernel_pagetable));
    8000100e:	00008797          	auipc	a5,0x8
    80001012:	8fa7b783          	ld	a5,-1798(a5) # 80008908 <kernel_pagetable>
    80001016:	83b1                	srli	a5,a5,0xc
    80001018:	577d                	li	a4,-1
    8000101a:	177e                	slli	a4,a4,0x3f
    8000101c:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r" (x));
    8000101e:	18079073          	csrw	satp,a5
  asm volatile("sfence.vma zero, zero");
    80001022:	12000073          	sfence.vma

  // flush stale entries from the TLB.
  sfence_vma();
}
    80001026:	6422                	ld	s0,8(sp)
    80001028:	0141                	addi	sp,sp,16
    8000102a:	8082                	ret

000000008000102c <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    8000102c:	7139                	addi	sp,sp,-64
    8000102e:	fc06                	sd	ra,56(sp)
    80001030:	f822                	sd	s0,48(sp)
    80001032:	f426                	sd	s1,40(sp)
    80001034:	f04a                	sd	s2,32(sp)
    80001036:	ec4e                	sd	s3,24(sp)
    80001038:	e852                	sd	s4,16(sp)
    8000103a:	e456                	sd	s5,8(sp)
    8000103c:	e05a                	sd	s6,0(sp)
    8000103e:	0080                	addi	s0,sp,64
    80001040:	84aa                	mv	s1,a0
    80001042:	89ae                	mv	s3,a1
    80001044:	8ab2                	mv	s5,a2
  if(va >= MAXVA)
    80001046:	57fd                	li	a5,-1
    80001048:	83e9                	srli	a5,a5,0x1a
    8000104a:	4a79                	li	s4,30
    panic("walk");

  for(int level = 2; level > 0; level--) {
    8000104c:	4b31                	li	s6,12
  if(va >= MAXVA)
    8000104e:	02b7fc63          	bgeu	a5,a1,80001086 <walk+0x5a>
    panic("walk");
    80001052:	00007517          	auipc	a0,0x7
    80001056:	06650513          	addi	a0,a0,102 # 800080b8 <etext+0xb8>
    8000105a:	fb8ff0ef          	jal	80000812 <panic>
    pte_t *pte = &pagetable[PX(level, va)];
    if(*pte & PTE_V) {
      pagetable = (pagetable_t)PTE2PA(*pte);
    } else {
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    8000105e:	060a8263          	beqz	s5,800010c2 <walk+0x96>
    80001062:	b2dff0ef          	jal	80000b8e <kalloc>
    80001066:	84aa                	mv	s1,a0
    80001068:	c139                	beqz	a0,800010ae <walk+0x82>
        return 0;
      memset(pagetable, 0, PGSIZE);
    8000106a:	6605                	lui	a2,0x1
    8000106c:	4581                	li	a1,0
    8000106e:	d23ff0ef          	jal	80000d90 <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    80001072:	00c4d793          	srli	a5,s1,0xc
    80001076:	07aa                	slli	a5,a5,0xa
    80001078:	0017e793          	ori	a5,a5,1
    8000107c:	00f93023          	sd	a5,0(s2)
  for(int level = 2; level > 0; level--) {
    80001080:	3a5d                	addiw	s4,s4,-9 # ffffffffffffeff7 <end+0xffffffff7ffb8117>
    80001082:	036a0063          	beq	s4,s6,800010a2 <walk+0x76>
    pte_t *pte = &pagetable[PX(level, va)];
    80001086:	0149d933          	srl	s2,s3,s4
    8000108a:	1ff97913          	andi	s2,s2,511
    8000108e:	090e                	slli	s2,s2,0x3
    80001090:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) {
    80001092:	00093483          	ld	s1,0(s2)
    80001096:	0014f793          	andi	a5,s1,1
    8000109a:	d3f1                	beqz	a5,8000105e <walk+0x32>
      pagetable = (pagetable_t)PTE2PA(*pte);
    8000109c:	80a9                	srli	s1,s1,0xa
    8000109e:	04b2                	slli	s1,s1,0xc
    800010a0:	b7c5                	j	80001080 <walk+0x54>
    }
  }
  return &pagetable[PX(0, va)];
    800010a2:	00c9d513          	srli	a0,s3,0xc
    800010a6:	1ff57513          	andi	a0,a0,511
    800010aa:	050e                	slli	a0,a0,0x3
    800010ac:	9526                	add	a0,a0,s1
}
    800010ae:	70e2                	ld	ra,56(sp)
    800010b0:	7442                	ld	s0,48(sp)
    800010b2:	74a2                	ld	s1,40(sp)
    800010b4:	7902                	ld	s2,32(sp)
    800010b6:	69e2                	ld	s3,24(sp)
    800010b8:	6a42                	ld	s4,16(sp)
    800010ba:	6aa2                	ld	s5,8(sp)
    800010bc:	6b02                	ld	s6,0(sp)
    800010be:	6121                	addi	sp,sp,64
    800010c0:	8082                	ret
        return 0;
    800010c2:	4501                	li	a0,0
    800010c4:	b7ed                	j	800010ae <walk+0x82>

00000000800010c6 <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if(va >= MAXVA)
    800010c6:	57fd                	li	a5,-1
    800010c8:	83e9                	srli	a5,a5,0x1a
    800010ca:	00b7f463          	bgeu	a5,a1,800010d2 <walkaddr+0xc>
    return 0;
    800010ce:	4501                	li	a0,0
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}
    800010d0:	8082                	ret
{
    800010d2:	1141                	addi	sp,sp,-16
    800010d4:	e406                	sd	ra,8(sp)
    800010d6:	e022                	sd	s0,0(sp)
    800010d8:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    800010da:	4601                	li	a2,0
    800010dc:	f51ff0ef          	jal	8000102c <walk>
  if(pte == 0)
    800010e0:	c105                	beqz	a0,80001100 <walkaddr+0x3a>
  if((*pte & PTE_V) == 0)
    800010e2:	611c                	ld	a5,0(a0)
  if((*pte & PTE_U) == 0)
    800010e4:	0117f693          	andi	a3,a5,17
    800010e8:	4745                	li	a4,17
    return 0;
    800010ea:	4501                	li	a0,0
  if((*pte & PTE_U) == 0)
    800010ec:	00e68663          	beq	a3,a4,800010f8 <walkaddr+0x32>
}
    800010f0:	60a2                	ld	ra,8(sp)
    800010f2:	6402                	ld	s0,0(sp)
    800010f4:	0141                	addi	sp,sp,16
    800010f6:	8082                	ret
  pa = PTE2PA(*pte);
    800010f8:	83a9                	srli	a5,a5,0xa
    800010fa:	00c79513          	slli	a0,a5,0xc
  return pa;
    800010fe:	bfcd                	j	800010f0 <walkaddr+0x2a>
    return 0;
    80001100:	4501                	li	a0,0
    80001102:	b7fd                	j	800010f0 <walkaddr+0x2a>

0000000080001104 <mappages>:
// va and size MUST be page-aligned.
// Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    80001104:	7115                	addi	sp,sp,-224
    80001106:	ed86                	sd	ra,216(sp)
    80001108:	e9a2                	sd	s0,208(sp)
    8000110a:	e5a6                	sd	s1,200(sp)
    8000110c:	e1ca                	sd	s2,192(sp)
    8000110e:	fd4e                	sd	s3,184(sp)
    80001110:	f952                	sd	s4,176(sp)
    80001112:	f556                	sd	s5,168(sp)
    80001114:	f15a                	sd	s6,160(sp)
    80001116:	ed5e                	sd	s7,152(sp)
    80001118:	e962                	sd	s8,144(sp)
    8000111a:	e566                	sd	s9,136(sp)
    8000111c:	e16a                	sd	s10,128(sp)
    8000111e:	fcee                	sd	s11,120(sp)
    80001120:	1180                	addi	s0,sp,224
  uint64 a, last;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    80001122:	03459793          	slli	a5,a1,0x34
    80001126:	e795                	bnez	a5,80001152 <mappages+0x4e>
    80001128:	8b2a                	mv	s6,a0
    8000112a:	89ba                	mv	s3,a4
    panic("mappages: va not aligned");

  if((size % PGSIZE) != 0)
    8000112c:	03461793          	slli	a5,a2,0x34
    80001130:	e79d                	bnez	a5,8000115e <mappages+0x5a>
    panic("mappages: size not aligned");

  if(size == 0)
    80001132:	ce05                	beqz	a2,8000116a <mappages+0x66>
    panic("mappages: size");
  
  a = va;
  last = va + size - PGSIZE;
    80001134:	77fd                	lui	a5,0xfffff
    80001136:	963e                	add	a2,a2,a5
    80001138:	00b60a33          	add	s4,a2,a1
  a = va;
    8000113c:	84ae                	mv	s1,a1
    8000113e:	40b68ab3          	sub	s5,a3,a1

    struct proc *p = myproc();
    if(p){
      struct mem_event e;
      memset(&e, 0, sizeof(e));
      e.ticks  = ticks;
    80001142:	00007d17          	auipc	s10,0x7
    80001146:	7eed0d13          	addi	s10,s10,2030 # 80008930 <ticks>
      e.cpu    = cpuid();
      e.type   = MEM_MAP;
    8000114a:	4c91                	li	s9,4
      e.pid    = p->pid;
      e.state  = p->state;
      e.va     = a;
      e.pa     = pa;
      e.perm   = perm;
      e.source = SRC_MAPPAGES;
    8000114c:	4c0d                	li	s8,3
      memlog_push(&e);
    }

    if(a == last)
      break;
    a += PGSIZE;
    8000114e:	6b85                	lui	s7,0x1
    80001150:	a859                	j	800011e6 <mappages+0xe2>
    panic("mappages: va not aligned");
    80001152:	00007517          	auipc	a0,0x7
    80001156:	f6e50513          	addi	a0,a0,-146 # 800080c0 <etext+0xc0>
    8000115a:	eb8ff0ef          	jal	80000812 <panic>
    panic("mappages: size not aligned");
    8000115e:	00007517          	auipc	a0,0x7
    80001162:	f8250513          	addi	a0,a0,-126 # 800080e0 <etext+0xe0>
    80001166:	eacff0ef          	jal	80000812 <panic>
    panic("mappages: size");
    8000116a:	00007517          	auipc	a0,0x7
    8000116e:	f9650513          	addi	a0,a0,-106 # 80008100 <etext+0x100>
    80001172:	ea0ff0ef          	jal	80000812 <panic>
      panic("mappages: remap");
    80001176:	00007517          	auipc	a0,0x7
    8000117a:	f9a50513          	addi	a0,a0,-102 # 80008110 <etext+0x110>
    8000117e:	e94ff0ef          	jal	80000812 <panic>
      memset(&e, 0, sizeof(e));
    80001182:	06800613          	li	a2,104
    80001186:	4581                	li	a1,0
    80001188:	f2840513          	addi	a0,s0,-216
    8000118c:	c05ff0ef          	jal	80000d90 <memset>
      e.ticks  = ticks;
    80001190:	000d2783          	lw	a5,0(s10)
    80001194:	f2f42823          	sw	a5,-208(s0)
      e.cpu    = cpuid();
    80001198:	2bd000ef          	jal	80001c54 <cpuid>
    8000119c:	f2a42a23          	sw	a0,-204(s0)
      e.type   = MEM_MAP;
    800011a0:	f3942c23          	sw	s9,-200(s0)
      e.pid    = p->pid;
    800011a4:	034da783          	lw	a5,52(s11)
    800011a8:	f2f42e23          	sw	a5,-196(s0)
      e.state  = p->state;
    800011ac:	018da783          	lw	a5,24(s11)
    800011b0:	f4f42023          	sw	a5,-192(s0)
      e.va     = a;
    800011b4:	f4943c23          	sd	s1,-168(s0)
      e.pa     = pa;
    800011b8:	f7243023          	sd	s2,-160(s0)
      e.perm   = perm;
    800011bc:	f9342023          	sw	s3,-128(s0)
      e.source = SRC_MAPPAGES;
    800011c0:	f9842223          	sw	s8,-124(s0)
      e.kind   = PAGE_USER;
    800011c4:	4785                	li	a5,1
    800011c6:	f8f42423          	sw	a5,-120(s0)
      safestrcpy(e.name, p->name, MEM_NM);
    800011ca:	4641                	li	a2,16
    800011cc:	158d8593          	addi	a1,s11,344
    800011d0:	f4440513          	addi	a0,s0,-188
    800011d4:	cfbff0ef          	jal	80000ece <safestrcpy>
      memlog_push(&e);
    800011d8:	f2840513          	addi	a0,s0,-216
    800011dc:	624050ef          	jal	80006800 <memlog_push>
    if(a == last)
    800011e0:	05448b63          	beq	s1,s4,80001236 <mappages+0x132>
    a += PGSIZE;
    800011e4:	94de                	add	s1,s1,s7
  for(;;){
    800011e6:	01548933          	add	s2,s1,s5
       if((pte = walk(pagetable, a, 1)) == 0)
    800011ea:	4605                	li	a2,1
    800011ec:	85a6                	mv	a1,s1
    800011ee:	855a                	mv	a0,s6
    800011f0:	e3dff0ef          	jal	8000102c <walk>
    800011f4:	c10d                	beqz	a0,80001216 <mappages+0x112>
    if(*pte & PTE_V)
    800011f6:	611c                	ld	a5,0(a0)
    800011f8:	8b85                	andi	a5,a5,1
    800011fa:	ffb5                	bnez	a5,80001176 <mappages+0x72>
    *pte = PA2PTE(pa) | perm | PTE_V;
    800011fc:	00c95793          	srli	a5,s2,0xc
    80001200:	07aa                	slli	a5,a5,0xa
    80001202:	0137e7b3          	or	a5,a5,s3
    80001206:	0017e793          	ori	a5,a5,1
    8000120a:	e11c                	sd	a5,0(a0)
    struct proc *p = myproc();
    8000120c:	27b000ef          	jal	80001c86 <myproc>
    80001210:	8daa                	mv	s11,a0
    if(p){
    80001212:	f925                	bnez	a0,80001182 <mappages+0x7e>
    80001214:	b7f1                	j	800011e0 <mappages+0xdc>
      return -1;
    80001216:	557d                	li	a0,-1
    pa += PGSIZE;
  }
  return 0;
}
    80001218:	60ee                	ld	ra,216(sp)
    8000121a:	644e                	ld	s0,208(sp)
    8000121c:	64ae                	ld	s1,200(sp)
    8000121e:	690e                	ld	s2,192(sp)
    80001220:	79ea                	ld	s3,184(sp)
    80001222:	7a4a                	ld	s4,176(sp)
    80001224:	7aaa                	ld	s5,168(sp)
    80001226:	7b0a                	ld	s6,160(sp)
    80001228:	6bea                	ld	s7,152(sp)
    8000122a:	6c4a                	ld	s8,144(sp)
    8000122c:	6caa                	ld	s9,136(sp)
    8000122e:	6d0a                	ld	s10,128(sp)
    80001230:	7de6                	ld	s11,120(sp)
    80001232:	612d                	addi	sp,sp,224
    80001234:	8082                	ret
  return 0;
    80001236:	4501                	li	a0,0
    80001238:	b7c5                	j	80001218 <mappages+0x114>

000000008000123a <kvmmap>:
{
    8000123a:	1141                	addi	sp,sp,-16
    8000123c:	e406                	sd	ra,8(sp)
    8000123e:	e022                	sd	s0,0(sp)
    80001240:	0800                	addi	s0,sp,16
    80001242:	87b6                	mv	a5,a3
  if(mappages(kpgtbl, va, sz, pa, perm) != 0)
    80001244:	86b2                	mv	a3,a2
    80001246:	863e                	mv	a2,a5
    80001248:	ebdff0ef          	jal	80001104 <mappages>
    8000124c:	e509                	bnez	a0,80001256 <kvmmap+0x1c>
}
    8000124e:	60a2                	ld	ra,8(sp)
    80001250:	6402                	ld	s0,0(sp)
    80001252:	0141                	addi	sp,sp,16
    80001254:	8082                	ret
    panic("kvmmap");
    80001256:	00007517          	auipc	a0,0x7
    8000125a:	eca50513          	addi	a0,a0,-310 # 80008120 <etext+0x120>
    8000125e:	db4ff0ef          	jal	80000812 <panic>

0000000080001262 <kvmmake>:
{
    80001262:	1101                	addi	sp,sp,-32
    80001264:	ec06                	sd	ra,24(sp)
    80001266:	e822                	sd	s0,16(sp)
    80001268:	e426                	sd	s1,8(sp)
    8000126a:	e04a                	sd	s2,0(sp)
    8000126c:	1000                	addi	s0,sp,32
  kpgtbl = (pagetable_t) kalloc();
    8000126e:	921ff0ef          	jal	80000b8e <kalloc>
    80001272:	84aa                	mv	s1,a0
  memset(kpgtbl, 0, PGSIZE);
    80001274:	6605                	lui	a2,0x1
    80001276:	4581                	li	a1,0
    80001278:	b19ff0ef          	jal	80000d90 <memset>
  kvmmap(kpgtbl, UART0, UART0, PGSIZE, PTE_R | PTE_W);
    8000127c:	4719                	li	a4,6
    8000127e:	6685                	lui	a3,0x1
    80001280:	10000637          	lui	a2,0x10000
    80001284:	100005b7          	lui	a1,0x10000
    80001288:	8526                	mv	a0,s1
    8000128a:	fb1ff0ef          	jal	8000123a <kvmmap>
  kvmmap(kpgtbl, VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    8000128e:	4719                	li	a4,6
    80001290:	6685                	lui	a3,0x1
    80001292:	10001637          	lui	a2,0x10001
    80001296:	100015b7          	lui	a1,0x10001
    8000129a:	8526                	mv	a0,s1
    8000129c:	f9fff0ef          	jal	8000123a <kvmmap>
  kvmmap(kpgtbl, PLIC, PLIC, 0x4000000, PTE_R | PTE_W);
    800012a0:	4719                	li	a4,6
    800012a2:	040006b7          	lui	a3,0x4000
    800012a6:	0c000637          	lui	a2,0xc000
    800012aa:	0c0005b7          	lui	a1,0xc000
    800012ae:	8526                	mv	a0,s1
    800012b0:	f8bff0ef          	jal	8000123a <kvmmap>
  kvmmap(kpgtbl, KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    800012b4:	00007917          	auipc	s2,0x7
    800012b8:	d4c90913          	addi	s2,s2,-692 # 80008000 <etext>
    800012bc:	4729                	li	a4,10
    800012be:	80007697          	auipc	a3,0x80007
    800012c2:	d4268693          	addi	a3,a3,-702 # 8000 <_entry-0x7fff8000>
    800012c6:	4605                	li	a2,1
    800012c8:	067e                	slli	a2,a2,0x1f
    800012ca:	85b2                	mv	a1,a2
    800012cc:	8526                	mv	a0,s1
    800012ce:	f6dff0ef          	jal	8000123a <kvmmap>
  kvmmap(kpgtbl, (uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    800012d2:	46c5                	li	a3,17
    800012d4:	06ee                	slli	a3,a3,0x1b
    800012d6:	4719                	li	a4,6
    800012d8:	412686b3          	sub	a3,a3,s2
    800012dc:	864a                	mv	a2,s2
    800012de:	85ca                	mv	a1,s2
    800012e0:	8526                	mv	a0,s1
    800012e2:	f59ff0ef          	jal	8000123a <kvmmap>
  kvmmap(kpgtbl, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    800012e6:	4729                	li	a4,10
    800012e8:	6685                	lui	a3,0x1
    800012ea:	00006617          	auipc	a2,0x6
    800012ee:	d1660613          	addi	a2,a2,-746 # 80007000 <_trampoline>
    800012f2:	040005b7          	lui	a1,0x4000
    800012f6:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    800012f8:	05b2                	slli	a1,a1,0xc
    800012fa:	8526                	mv	a0,s1
    800012fc:	f3fff0ef          	jal	8000123a <kvmmap>
  proc_mapstacks(kpgtbl);
    80001300:	8526                	mv	a0,s1
    80001302:	7d8000ef          	jal	80001ada <proc_mapstacks>
}
    80001306:	8526                	mv	a0,s1
    80001308:	60e2                	ld	ra,24(sp)
    8000130a:	6442                	ld	s0,16(sp)
    8000130c:	64a2                	ld	s1,8(sp)
    8000130e:	6902                	ld	s2,0(sp)
    80001310:	6105                	addi	sp,sp,32
    80001312:	8082                	ret

0000000080001314 <kvminit>:
{
    80001314:	1141                	addi	sp,sp,-16
    80001316:	e406                	sd	ra,8(sp)
    80001318:	e022                	sd	s0,0(sp)
    8000131a:	0800                	addi	s0,sp,16
  kernel_pagetable = kvmmake();
    8000131c:	f47ff0ef          	jal	80001262 <kvmmake>
    80001320:	00007797          	auipc	a5,0x7
    80001324:	5ea7b423          	sd	a0,1512(a5) # 80008908 <kernel_pagetable>
}
    80001328:	60a2                	ld	ra,8(sp)
    8000132a:	6402                	ld	s0,0(sp)
    8000132c:	0141                	addi	sp,sp,16
    8000132e:	8082                	ret

0000000080001330 <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    80001330:	1101                	addi	sp,sp,-32
    80001332:	ec06                	sd	ra,24(sp)
    80001334:	e822                	sd	s0,16(sp)
    80001336:	e426                	sd	s1,8(sp)
    80001338:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t) kalloc();
    8000133a:	855ff0ef          	jal	80000b8e <kalloc>
    8000133e:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001340:	c509                	beqz	a0,8000134a <uvmcreate+0x1a>
    return 0;
  memset(pagetable, 0, PGSIZE);
    80001342:	6605                	lui	a2,0x1
    80001344:	4581                	li	a1,0
    80001346:	a4bff0ef          	jal	80000d90 <memset>
  return pagetable;
}
    8000134a:	8526                	mv	a0,s1
    8000134c:	60e2                	ld	ra,24(sp)
    8000134e:	6442                	ld	s0,16(sp)
    80001350:	64a2                	ld	s1,8(sp)
    80001352:	6105                	addi	sp,sp,32
    80001354:	8082                	ret

0000000080001356 <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. It's OK if the mappings don't exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    80001356:	7115                	addi	sp,sp,-224
    80001358:	ed86                	sd	ra,216(sp)
    8000135a:	e9a2                	sd	s0,208(sp)
    8000135c:	1180                	addi	s0,sp,224
  uint64 a;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    8000135e:	03459793          	slli	a5,a1,0x34
    80001362:	ef85                	bnez	a5,8000139a <uvmunmap+0x44>
    80001364:	e1ca                	sd	s2,192(sp)
    80001366:	f556                	sd	s5,168(sp)
    80001368:	f15a                	sd	s6,160(sp)
    8000136a:	e962                	sd	s8,144(sp)
    8000136c:	8b2a                	mv	s6,a0
    8000136e:	892e                	mv	s2,a1
    80001370:	8c36                	mv	s8,a3
    panic("uvmunmap: not aligned");

  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80001372:	0632                	slli	a2,a2,0xc
    80001374:	00b60ab3          	add	s5,a2,a1
    80001378:	0f55f763          	bgeu	a1,s5,80001466 <uvmunmap+0x110>
    8000137c:	e5a6                	sd	s1,200(sp)
    8000137e:	fd4e                	sd	s3,184(sp)
    80001380:	f952                	sd	s4,176(sp)
    80001382:	ed5e                	sd	s7,152(sp)
    80001384:	e566                	sd	s9,136(sp)
    80001386:	e16a                	sd	s10,128(sp)
    80001388:	fcee                	sd	s11,120(sp)

    struct proc *p = myproc();
    if(p){
      struct mem_event e;
      memset(&e, 0, sizeof(e));
      e.ticks  = ticks;
    8000138a:	00007d97          	auipc	s11,0x7
    8000138e:	5a6d8d93          	addi	s11,s11,1446 # 80008930 <ticks>
      e.cpu    = cpuid();
      e.type   = MEM_UNMAP;
    80001392:	4d15                	li	s10,5
      e.pid    = p->pid;
      e.state  = p->state;
      e.va     = a;
      e.pa     = pa;
      e.len    = PGSIZE;
    80001394:	6b85                	lui	s7,0x1
      e.source = SRC_UVMUNMAP;
    80001396:	4c91                	li	s9,4
    80001398:	a80d                	j	800013ca <uvmunmap+0x74>
    8000139a:	e5a6                	sd	s1,200(sp)
    8000139c:	e1ca                	sd	s2,192(sp)
    8000139e:	fd4e                	sd	s3,184(sp)
    800013a0:	f952                	sd	s4,176(sp)
    800013a2:	f556                	sd	s5,168(sp)
    800013a4:	f15a                	sd	s6,160(sp)
    800013a6:	ed5e                	sd	s7,152(sp)
    800013a8:	e962                	sd	s8,144(sp)
    800013aa:	e566                	sd	s9,136(sp)
    800013ac:	e16a                	sd	s10,128(sp)
    800013ae:	fcee                	sd	s11,120(sp)
    panic("uvmunmap: not aligned");
    800013b0:	00007517          	auipc	a0,0x7
    800013b4:	d7850513          	addi	a0,a0,-648 # 80008128 <etext+0x128>
    800013b8:	c5aff0ef          	jal	80000812 <panic>
      e.kind   = PAGE_USER;
      safestrcpy(e.name, p->name, MEM_NM);
      memlog_push(&e);
    }

    if(do_free){
    800013bc:	080c1a63          	bnez	s8,80001450 <uvmunmap+0xfa>
      kfree((void*)pa);
    }
    *pte = 0;
    800013c0:	0004b023          	sd	zero,0(s1)
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800013c4:	995e                	add	s2,s2,s7
    800013c6:	09597963          	bgeu	s2,s5,80001458 <uvmunmap+0x102>
    if((pte = walk(pagetable, a, 0)) == 0)
    800013ca:	4601                	li	a2,0
    800013cc:	85ca                	mv	a1,s2
    800013ce:	855a                	mv	a0,s6
    800013d0:	c5dff0ef          	jal	8000102c <walk>
    800013d4:	84aa                	mv	s1,a0
    800013d6:	d57d                	beqz	a0,800013c4 <uvmunmap+0x6e>
    if((*pte & PTE_V) == 0)
    800013d8:	00053983          	ld	s3,0(a0)
    800013dc:	0019f793          	andi	a5,s3,1
    800013e0:	d3f5                	beqz	a5,800013c4 <uvmunmap+0x6e>
    uint64 pa = PTE2PA(*pte);
    800013e2:	00a9d993          	srli	s3,s3,0xa
    800013e6:	09b2                	slli	s3,s3,0xc
    struct proc *p = myproc();
    800013e8:	09f000ef          	jal	80001c86 <myproc>
    800013ec:	8a2a                	mv	s4,a0
    if(p){
    800013ee:	d579                	beqz	a0,800013bc <uvmunmap+0x66>
      memset(&e, 0, sizeof(e));
    800013f0:	06800613          	li	a2,104
    800013f4:	4581                	li	a1,0
    800013f6:	f2840513          	addi	a0,s0,-216
    800013fa:	997ff0ef          	jal	80000d90 <memset>
      e.ticks  = ticks;
    800013fe:	000da783          	lw	a5,0(s11)
    80001402:	f2f42823          	sw	a5,-208(s0)
      e.cpu    = cpuid();
    80001406:	04f000ef          	jal	80001c54 <cpuid>
    8000140a:	f2a42a23          	sw	a0,-204(s0)
      e.type   = MEM_UNMAP;
    8000140e:	f3a42c23          	sw	s10,-200(s0)
      e.pid    = p->pid;
    80001412:	034a2783          	lw	a5,52(s4)
    80001416:	f2f42e23          	sw	a5,-196(s0)
      e.state  = p->state;
    8000141a:	018a2783          	lw	a5,24(s4)
    8000141e:	f4f42023          	sw	a5,-192(s0)
      e.va     = a;
    80001422:	f5243c23          	sd	s2,-168(s0)
      e.pa     = pa;
    80001426:	f7343023          	sd	s3,-160(s0)
      e.len    = PGSIZE;
    8000142a:	f7743c23          	sd	s7,-136(s0)
      e.source = SRC_UVMUNMAP;
    8000142e:	f9942223          	sw	s9,-124(s0)
      e.kind   = PAGE_USER;
    80001432:	4785                	li	a5,1
    80001434:	f8f42423          	sw	a5,-120(s0)
      safestrcpy(e.name, p->name, MEM_NM);
    80001438:	4641                	li	a2,16
    8000143a:	158a0593          	addi	a1,s4,344
    8000143e:	f4440513          	addi	a0,s0,-188
    80001442:	a8dff0ef          	jal	80000ece <safestrcpy>
      memlog_push(&e);
    80001446:	f2840513          	addi	a0,s0,-216
    8000144a:	3b6050ef          	jal	80006800 <memlog_push>
    8000144e:	b7bd                	j	800013bc <uvmunmap+0x66>
      kfree((void*)pa);
    80001450:	854e                	mv	a0,s3
    80001452:	dfcff0ef          	jal	80000a4e <kfree>
    80001456:	b7ad                	j	800013c0 <uvmunmap+0x6a>
    80001458:	64ae                	ld	s1,200(sp)
    8000145a:	79ea                	ld	s3,184(sp)
    8000145c:	7a4a                	ld	s4,176(sp)
    8000145e:	6bea                	ld	s7,152(sp)
    80001460:	6caa                	ld	s9,136(sp)
    80001462:	6d0a                	ld	s10,128(sp)
    80001464:	7de6                	ld	s11,120(sp)
    80001466:	690e                	ld	s2,192(sp)
    80001468:	7aaa                	ld	s5,168(sp)
    8000146a:	7b0a                	ld	s6,160(sp)
    8000146c:	6c4a                	ld	s8,144(sp)
  }
}
    8000146e:	60ee                	ld	ra,216(sp)
    80001470:	644e                	ld	s0,208(sp)
    80001472:	612d                	addi	sp,sp,224
    80001474:	8082                	ret

0000000080001476 <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    80001476:	1101                	addi	sp,sp,-32
    80001478:	ec06                	sd	ra,24(sp)
    8000147a:	e822                	sd	s0,16(sp)
    8000147c:	e426                	sd	s1,8(sp)
    8000147e:	1000                	addi	s0,sp,32
  if(newsz >= oldsz)
    return oldsz;
    80001480:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    80001482:	00b67d63          	bgeu	a2,a1,8000149c <uvmdealloc+0x26>
    80001486:	84b2                	mv	s1,a2

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    80001488:	6785                	lui	a5,0x1
    8000148a:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    8000148c:	00f60733          	add	a4,a2,a5
    80001490:	76fd                	lui	a3,0xfffff
    80001492:	8f75                	and	a4,a4,a3
    80001494:	97ae                	add	a5,a5,a1
    80001496:	8ff5                	and	a5,a5,a3
    80001498:	00f76863          	bltu	a4,a5,800014a8 <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    8000149c:	8526                	mv	a0,s1
    8000149e:	60e2                	ld	ra,24(sp)
    800014a0:	6442                	ld	s0,16(sp)
    800014a2:	64a2                	ld	s1,8(sp)
    800014a4:	6105                	addi	sp,sp,32
    800014a6:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    800014a8:	8f99                	sub	a5,a5,a4
    800014aa:	83b1                	srli	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    800014ac:	4685                	li	a3,1
    800014ae:	0007861b          	sext.w	a2,a5
    800014b2:	85ba                	mv	a1,a4
    800014b4:	ea3ff0ef          	jal	80001356 <uvmunmap>
    800014b8:	b7d5                	j	8000149c <uvmdealloc+0x26>

00000000800014ba <uvmalloc>:
  if(newsz < oldsz)
    800014ba:	12b66a63          	bltu	a2,a1,800015ee <uvmalloc+0x134>
{
    800014be:	7131                	addi	sp,sp,-192
    800014c0:	fd06                	sd	ra,184(sp)
    800014c2:	f922                	sd	s0,176(sp)
    800014c4:	f526                	sd	s1,168(sp)
    800014c6:	ed4e                	sd	s3,152(sp)
    800014c8:	e952                	sd	s4,144(sp)
    800014ca:	e556                	sd	s5,136(sp)
    800014cc:	e15a                	sd	s6,128(sp)
    800014ce:	fcde                	sd	s7,120(sp)
    800014d0:	0180                	addi	s0,sp,192
    800014d2:	8a2a                	mv	s4,a0
    800014d4:	89b2                	mv	s3,a2
    800014d6:	8b36                	mv	s6,a3
  oldsz = PGROUNDUP(oldsz);
    800014d8:	6785                	lui	a5,0x1
    800014da:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    800014dc:	95be                	add	a1,a1,a5
    800014de:	7bfd                	lui	s7,0xfffff
    800014e0:	0175fbb3          	and	s7,a1,s7
  for(a = oldsz; a < newsz; a += PGSIZE){
    800014e4:	10cbf363          	bgeu	s7,a2,800015ea <uvmalloc+0x130>
    800014e8:	f14a                	sd	s2,160(sp)
    800014ea:	f8e2                	sd	s8,112(sp)
    800014ec:	895e                	mv	s2,s7
  uint64 first_pa = 0;
    800014ee:	4a81                	li	s5,0
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    800014f0:	0126ec13          	ori	s8,a3,18
    800014f4:	a099                	j	8000153a <uvmalloc+0x80>
      uvmdealloc(pagetable, a, oldsz);
    800014f6:	865e                	mv	a2,s7
    800014f8:	85ca                	mv	a1,s2
    800014fa:	8552                	mv	a0,s4
    800014fc:	f7bff0ef          	jal	80001476 <uvmdealloc>
      return 0;
    80001500:	4501                	li	a0,0
    80001502:	790a                	ld	s2,160(sp)
    80001504:	7c46                	ld	s8,112(sp)
}
    80001506:	70ea                	ld	ra,184(sp)
    80001508:	744a                	ld	s0,176(sp)
    8000150a:	74aa                	ld	s1,168(sp)
    8000150c:	69ea                	ld	s3,152(sp)
    8000150e:	6a4a                	ld	s4,144(sp)
    80001510:	6aaa                	ld	s5,136(sp)
    80001512:	6b0a                	ld	s6,128(sp)
    80001514:	7be6                	ld	s7,120(sp)
    80001516:	6129                	addi	sp,sp,192
    80001518:	8082                	ret
      kfree(mem);
    8000151a:	8526                	mv	a0,s1
    8000151c:	d32ff0ef          	jal	80000a4e <kfree>
      uvmdealloc(pagetable, a, oldsz);
    80001520:	865e                	mv	a2,s7
    80001522:	85ca                	mv	a1,s2
    80001524:	8552                	mv	a0,s4
    80001526:	f51ff0ef          	jal	80001476 <uvmdealloc>
      return 0;
    8000152a:	4501                	li	a0,0
    8000152c:	790a                	ld	s2,160(sp)
    8000152e:	7c46                	ld	s8,112(sp)
    80001530:	bfd9                	j	80001506 <uvmalloc+0x4c>
  for(a = oldsz; a < newsz; a += PGSIZE){
    80001532:	6785                	lui	a5,0x1
    80001534:	993e                	add	s2,s2,a5
    80001536:	03397663          	bgeu	s2,s3,80001562 <uvmalloc+0xa8>
    mem = kalloc();
    8000153a:	e54ff0ef          	jal	80000b8e <kalloc>
    8000153e:	84aa                	mv	s1,a0
    if(mem == 0){
    80001540:	d95d                	beqz	a0,800014f6 <uvmalloc+0x3c>
    memset(mem, 0, PGSIZE);
    80001542:	6605                	lui	a2,0x1
    80001544:	4581                	li	a1,0
    80001546:	84bff0ef          	jal	80000d90 <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    8000154a:	8762                	mv	a4,s8
    8000154c:	86a6                	mv	a3,s1
    8000154e:	6605                	lui	a2,0x1
    80001550:	85ca                	mv	a1,s2
    80001552:	8552                	mv	a0,s4
    80001554:	bb1ff0ef          	jal	80001104 <mappages>
    80001558:	f169                	bnez	a0,8000151a <uvmalloc+0x60>
    if(first_pa == 0)
    8000155a:	fc0a9ce3          	bnez	s5,80001532 <uvmalloc+0x78>
      first_pa = (uint64)mem;
    8000155e:	8aa6                	mv	s5,s1
    80001560:	bfc9                	j	80001532 <uvmalloc+0x78>
    80001562:	790a                	ld	s2,160(sp)
    80001564:	7c46                	ld	s8,112(sp)
  struct proc *p = myproc();
    80001566:	720000ef          	jal	80001c86 <myproc>
    8000156a:	84aa                	mv	s1,a0
  return newsz;
    8000156c:	854e                	mv	a0,s3
  if(p){
    8000156e:	dcc1                	beqz	s1,80001506 <uvmalloc+0x4c>
    memset(&e, 0, sizeof(e));
    80001570:	06800613          	li	a2,104
    80001574:	4581                	li	a1,0
    80001576:	f4840513          	addi	a0,s0,-184
    8000157a:	817ff0ef          	jal	80000d90 <memset>
    e.ticks  = ticks;
    8000157e:	00007797          	auipc	a5,0x7
    80001582:	3b27a783          	lw	a5,946(a5) # 80008930 <ticks>
    80001586:	f4f42823          	sw	a5,-176(s0)
    e.cpu    = cpuid();
    8000158a:	6ca000ef          	jal	80001c54 <cpuid>
    8000158e:	f4a42a23          	sw	a0,-172(s0)
    e.type   = MEM_GROW;
    80001592:	4705                	li	a4,1
    80001594:	f4e42c23          	sw	a4,-168(s0)
    e.pid    = p->pid;
    80001598:	58dc                	lw	a5,52(s1)
    8000159a:	f4f42e23          	sw	a5,-164(s0)
    e.state  = p->state;
    8000159e:	4c9c                	lw	a5,24(s1)
    800015a0:	f6f42023          	sw	a5,-160(s0)
    e.va     = PGROUNDUP(oldsz);
    800015a4:	6785                	lui	a5,0x1
    800015a6:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    800015a8:	97de                	add	a5,a5,s7
    800015aa:	76fd                	lui	a3,0xfffff
    800015ac:	8ff5                	and	a5,a5,a3
    800015ae:	f6f43c23          	sd	a5,-136(s0)
    e.pa     = first_pa;
    800015b2:	f9543023          	sd	s5,-128(s0)
    e.perm   = PTE_R | PTE_U | xperm;
    800015b6:	012b6b13          	ori	s6,s6,18
    800015ba:	fb642023          	sw	s6,-96(s0)
    e.oldsz  = oldsz;
    800015be:	f9743423          	sd	s7,-120(s0)
    e.newsz  = newsz;
    800015c2:	f9343823          	sd	s3,-112(s0)
    e.source = SRC_UVMALLOC;
    800015c6:	4795                	li	a5,5
    800015c8:	faf42223          	sw	a5,-92(s0)
    e.kind   = PAGE_USER;
    800015cc:	fae42423          	sw	a4,-88(s0)
    safestrcpy(e.name, p->name, MEM_NM);
    800015d0:	4641                	li	a2,16
    800015d2:	15848593          	addi	a1,s1,344
    800015d6:	f6440513          	addi	a0,s0,-156
    800015da:	8f5ff0ef          	jal	80000ece <safestrcpy>
    memlog_push(&e);
    800015de:	f4840513          	addi	a0,s0,-184
    800015e2:	21e050ef          	jal	80006800 <memlog_push>
  return newsz;
    800015e6:	854e                	mv	a0,s3
    800015e8:	bf39                	j	80001506 <uvmalloc+0x4c>
  uint64 first_pa = 0;
    800015ea:	4a81                	li	s5,0
    800015ec:	bfad                	j	80001566 <uvmalloc+0xac>
    return oldsz;
    800015ee:	852e                	mv	a0,a1
}
    800015f0:	8082                	ret

00000000800015f2 <freewalk>:
// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    800015f2:	7179                	addi	sp,sp,-48
    800015f4:	f406                	sd	ra,40(sp)
    800015f6:	f022                	sd	s0,32(sp)
    800015f8:	ec26                	sd	s1,24(sp)
    800015fa:	e84a                	sd	s2,16(sp)
    800015fc:	e44e                	sd	s3,8(sp)
    800015fe:	e052                	sd	s4,0(sp)
    80001600:	1800                	addi	s0,sp,48
    80001602:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    80001604:	84aa                	mv	s1,a0
    80001606:	6905                	lui	s2,0x1
    80001608:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    8000160a:	4985                	li	s3,1
    8000160c:	a819                	j	80001622 <freewalk+0x30>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    8000160e:	83a9                	srli	a5,a5,0xa
      freewalk((pagetable_t)child);
    80001610:	00c79513          	slli	a0,a5,0xc
    80001614:	fdfff0ef          	jal	800015f2 <freewalk>
      pagetable[i] = 0;
    80001618:	0004b023          	sd	zero,0(s1)
  for(int i = 0; i < 512; i++){
    8000161c:	04a1                	addi	s1,s1,8
    8000161e:	01248f63          	beq	s1,s2,8000163c <freewalk+0x4a>
    pte_t pte = pagetable[i];
    80001622:	609c                	ld	a5,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    80001624:	00f7f713          	andi	a4,a5,15
    80001628:	ff3703e3          	beq	a4,s3,8000160e <freewalk+0x1c>
    } else if(pte & PTE_V){
    8000162c:	8b85                	andi	a5,a5,1
    8000162e:	d7fd                	beqz	a5,8000161c <freewalk+0x2a>
      panic("freewalk: leaf");
    80001630:	00007517          	auipc	a0,0x7
    80001634:	b1050513          	addi	a0,a0,-1264 # 80008140 <etext+0x140>
    80001638:	9daff0ef          	jal	80000812 <panic>
    }
  }
  kfree((void*)pagetable);
    8000163c:	8552                	mv	a0,s4
    8000163e:	c10ff0ef          	jal	80000a4e <kfree>
}
    80001642:	70a2                	ld	ra,40(sp)
    80001644:	7402                	ld	s0,32(sp)
    80001646:	64e2                	ld	s1,24(sp)
    80001648:	6942                	ld	s2,16(sp)
    8000164a:	69a2                	ld	s3,8(sp)
    8000164c:	6a02                	ld	s4,0(sp)
    8000164e:	6145                	addi	sp,sp,48
    80001650:	8082                	ret

0000000080001652 <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    80001652:	1101                	addi	sp,sp,-32
    80001654:	ec06                	sd	ra,24(sp)
    80001656:	e822                	sd	s0,16(sp)
    80001658:	e426                	sd	s1,8(sp)
    8000165a:	1000                	addi	s0,sp,32
    8000165c:	84aa                	mv	s1,a0
  if(sz > 0)
    8000165e:	e989                	bnez	a1,80001670 <uvmfree+0x1e>
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
  freewalk(pagetable);
    80001660:	8526                	mv	a0,s1
    80001662:	f91ff0ef          	jal	800015f2 <freewalk>
}
    80001666:	60e2                	ld	ra,24(sp)
    80001668:	6442                	ld	s0,16(sp)
    8000166a:	64a2                	ld	s1,8(sp)
    8000166c:	6105                	addi	sp,sp,32
    8000166e:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
    80001670:	6785                	lui	a5,0x1
    80001672:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80001674:	95be                	add	a1,a1,a5
    80001676:	4685                	li	a3,1
    80001678:	00c5d613          	srli	a2,a1,0xc
    8000167c:	4581                	li	a1,0
    8000167e:	cd9ff0ef          	jal	80001356 <uvmunmap>
    80001682:	bff9                	j	80001660 <uvmfree+0xe>

0000000080001684 <uvmcopy>:
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for(i = 0; i < sz; i += PGSIZE){
    80001684:	ce49                	beqz	a2,8000171e <uvmcopy+0x9a>
{
    80001686:	715d                	addi	sp,sp,-80
    80001688:	e486                	sd	ra,72(sp)
    8000168a:	e0a2                	sd	s0,64(sp)
    8000168c:	fc26                	sd	s1,56(sp)
    8000168e:	f84a                	sd	s2,48(sp)
    80001690:	f44e                	sd	s3,40(sp)
    80001692:	f052                	sd	s4,32(sp)
    80001694:	ec56                	sd	s5,24(sp)
    80001696:	e85a                	sd	s6,16(sp)
    80001698:	e45e                	sd	s7,8(sp)
    8000169a:	0880                	addi	s0,sp,80
    8000169c:	8aaa                	mv	s5,a0
    8000169e:	8b2e                	mv	s6,a1
    800016a0:	8a32                	mv	s4,a2
  for(i = 0; i < sz; i += PGSIZE){
    800016a2:	4481                	li	s1,0
    800016a4:	a029                	j	800016ae <uvmcopy+0x2a>
    800016a6:	6785                	lui	a5,0x1
    800016a8:	94be                	add	s1,s1,a5
    800016aa:	0544fe63          	bgeu	s1,s4,80001706 <uvmcopy+0x82>
    if((pte = walk(old, i, 0)) == 0)
    800016ae:	4601                	li	a2,0
    800016b0:	85a6                	mv	a1,s1
    800016b2:	8556                	mv	a0,s5
    800016b4:	979ff0ef          	jal	8000102c <walk>
    800016b8:	d57d                	beqz	a0,800016a6 <uvmcopy+0x22>
      continue;   // page table entry hasn't been allocated
    if((*pte & PTE_V) == 0)
    800016ba:	6118                	ld	a4,0(a0)
    800016bc:	00177793          	andi	a5,a4,1
    800016c0:	d3fd                	beqz	a5,800016a6 <uvmcopy+0x22>
      continue;   // physical page hasn't been allocated
    pa = PTE2PA(*pte);
    800016c2:	00a75593          	srli	a1,a4,0xa
    800016c6:	00c59b93          	slli	s7,a1,0xc
    flags = PTE_FLAGS(*pte);
    800016ca:	3ff77913          	andi	s2,a4,1023
    if((mem = kalloc()) == 0)
    800016ce:	cc0ff0ef          	jal	80000b8e <kalloc>
    800016d2:	89aa                	mv	s3,a0
    800016d4:	c105                	beqz	a0,800016f4 <uvmcopy+0x70>
      goto err;
    memmove(mem, (char*)pa, PGSIZE);
    800016d6:	6605                	lui	a2,0x1
    800016d8:	85de                	mv	a1,s7
    800016da:	f12ff0ef          	jal	80000dec <memmove>
    if(mappages(new, i, PGSIZE, (uint64)mem, flags) != 0){
    800016de:	874a                	mv	a4,s2
    800016e0:	86ce                	mv	a3,s3
    800016e2:	6605                	lui	a2,0x1
    800016e4:	85a6                	mv	a1,s1
    800016e6:	855a                	mv	a0,s6
    800016e8:	a1dff0ef          	jal	80001104 <mappages>
    800016ec:	dd4d                	beqz	a0,800016a6 <uvmcopy+0x22>
      kfree(mem);
    800016ee:	854e                	mv	a0,s3
    800016f0:	b5eff0ef          	jal	80000a4e <kfree>
    }
  }
  return 0;

 err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    800016f4:	4685                	li	a3,1
    800016f6:	00c4d613          	srli	a2,s1,0xc
    800016fa:	4581                	li	a1,0
    800016fc:	855a                	mv	a0,s6
    800016fe:	c59ff0ef          	jal	80001356 <uvmunmap>
  return -1;
    80001702:	557d                	li	a0,-1
    80001704:	a011                	j	80001708 <uvmcopy+0x84>
  return 0;
    80001706:	4501                	li	a0,0
}
    80001708:	60a6                	ld	ra,72(sp)
    8000170a:	6406                	ld	s0,64(sp)
    8000170c:	74e2                	ld	s1,56(sp)
    8000170e:	7942                	ld	s2,48(sp)
    80001710:	79a2                	ld	s3,40(sp)
    80001712:	7a02                	ld	s4,32(sp)
    80001714:	6ae2                	ld	s5,24(sp)
    80001716:	6b42                	ld	s6,16(sp)
    80001718:	6ba2                	ld	s7,8(sp)
    8000171a:	6161                	addi	sp,sp,80
    8000171c:	8082                	ret
  return 0;
    8000171e:	4501                	li	a0,0
}
    80001720:	8082                	ret

0000000080001722 <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    80001722:	1141                	addi	sp,sp,-16
    80001724:	e406                	sd	ra,8(sp)
    80001726:	e022                	sd	s0,0(sp)
    80001728:	0800                	addi	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    8000172a:	4601                	li	a2,0
    8000172c:	901ff0ef          	jal	8000102c <walk>
  if(pte == 0)
    80001730:	c901                	beqz	a0,80001740 <uvmclear+0x1e>
    panic("uvmclear");
  *pte &= ~PTE_U;
    80001732:	611c                	ld	a5,0(a0)
    80001734:	9bbd                	andi	a5,a5,-17
    80001736:	e11c                	sd	a5,0(a0)
}
    80001738:	60a2                	ld	ra,8(sp)
    8000173a:	6402                	ld	s0,0(sp)
    8000173c:	0141                	addi	sp,sp,16
    8000173e:	8082                	ret
    panic("uvmclear");
    80001740:	00007517          	auipc	a0,0x7
    80001744:	a1050513          	addi	a0,a0,-1520 # 80008150 <etext+0x150>
    80001748:	8caff0ef          	jal	80000812 <panic>

000000008000174c <copyinstr>:
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    8000174c:	c6dd                	beqz	a3,800017fa <copyinstr+0xae>
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
    80001762:	0880                	addi	s0,sp,80
    80001764:	8a2a                	mv	s4,a0
    80001766:	8b2e                	mv	s6,a1
    80001768:	8bb2                	mv	s7,a2
    8000176a:	8936                	mv	s2,a3
    va0 = PGROUNDDOWN(srcva);
    8000176c:	7afd                	lui	s5,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    8000176e:	6985                	lui	s3,0x1
    80001770:	a825                	j	800017a8 <copyinstr+0x5c>
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
    80001772:	00078023          	sb	zero,0(a5) # 1000 <_entry-0x7ffff000>
    80001776:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    80001778:	37fd                	addiw	a5,a5,-1
    8000177a:	0007851b          	sext.w	a0,a5
    return 0;
  } else {
    return -1;
  }
}
    8000177e:	60a6                	ld	ra,72(sp)
    80001780:	6406                	ld	s0,64(sp)
    80001782:	74e2                	ld	s1,56(sp)
    80001784:	7942                	ld	s2,48(sp)
    80001786:	79a2                	ld	s3,40(sp)
    80001788:	7a02                	ld	s4,32(sp)
    8000178a:	6ae2                	ld	s5,24(sp)
    8000178c:	6b42                	ld	s6,16(sp)
    8000178e:	6ba2                	ld	s7,8(sp)
    80001790:	6161                	addi	sp,sp,80
    80001792:	8082                	ret
    80001794:	fff90713          	addi	a4,s2,-1 # fff <_entry-0x7ffff001>
    80001798:	9742                	add	a4,a4,a6
      --max;
    8000179a:	40b70933          	sub	s2,a4,a1
    srcva = va0 + PGSIZE;
    8000179e:	01348bb3          	add	s7,s1,s3
  while(got_null == 0 && max > 0){
    800017a2:	04e58463          	beq	a1,a4,800017ea <copyinstr+0x9e>
{
    800017a6:	8b3e                	mv	s6,a5
    va0 = PGROUNDDOWN(srcva);
    800017a8:	015bf4b3          	and	s1,s7,s5
    pa0 = walkaddr(pagetable, va0);
    800017ac:	85a6                	mv	a1,s1
    800017ae:	8552                	mv	a0,s4
    800017b0:	917ff0ef          	jal	800010c6 <walkaddr>
    if(pa0 == 0)
    800017b4:	cd0d                	beqz	a0,800017ee <copyinstr+0xa2>
    n = PGSIZE - (srcva - va0);
    800017b6:	417486b3          	sub	a3,s1,s7
    800017ba:	96ce                	add	a3,a3,s3
    if(n > max)
    800017bc:	00d97363          	bgeu	s2,a3,800017c2 <copyinstr+0x76>
    800017c0:	86ca                	mv	a3,s2
    char *p = (char *) (pa0 + (srcva - va0));
    800017c2:	955e                	add	a0,a0,s7
    800017c4:	8d05                	sub	a0,a0,s1
    while(n > 0){
    800017c6:	c695                	beqz	a3,800017f2 <copyinstr+0xa6>
    800017c8:	87da                	mv	a5,s6
    800017ca:	885a                	mv	a6,s6
      if(*p == '\0'){
    800017cc:	41650633          	sub	a2,a0,s6
    while(n > 0){
    800017d0:	96da                	add	a3,a3,s6
    800017d2:	85be                	mv	a1,a5
      if(*p == '\0'){
    800017d4:	00f60733          	add	a4,a2,a5
    800017d8:	00074703          	lbu	a4,0(a4)
    800017dc:	db59                	beqz	a4,80001772 <copyinstr+0x26>
        *dst = *p;
    800017de:	00e78023          	sb	a4,0(a5)
      dst++;
    800017e2:	0785                	addi	a5,a5,1
    while(n > 0){
    800017e4:	fed797e3          	bne	a5,a3,800017d2 <copyinstr+0x86>
    800017e8:	b775                	j	80001794 <copyinstr+0x48>
    800017ea:	4781                	li	a5,0
    800017ec:	b771                	j	80001778 <copyinstr+0x2c>
      return -1;
    800017ee:	557d                	li	a0,-1
    800017f0:	b779                	j	8000177e <copyinstr+0x32>
    srcva = va0 + PGSIZE;
    800017f2:	6b85                	lui	s7,0x1
    800017f4:	9ba6                	add	s7,s7,s1
    800017f6:	87da                	mv	a5,s6
    800017f8:	b77d                	j	800017a6 <copyinstr+0x5a>
  int got_null = 0;
    800017fa:	4781                	li	a5,0
  if(got_null){
    800017fc:	37fd                	addiw	a5,a5,-1
    800017fe:	0007851b          	sext.w	a0,a5
}
    80001802:	8082                	ret

0000000080001804 <ismapped>:
  }
  return mem;
}
int
ismapped(pagetable_t pagetable, uint64 va)
{
    80001804:	1141                	addi	sp,sp,-16
    80001806:	e406                	sd	ra,8(sp)
    80001808:	e022                	sd	s0,0(sp)
    8000180a:	0800                	addi	s0,sp,16
  pte_t *pte = walk(pagetable, va, 0);
    8000180c:	4601                	li	a2,0
    8000180e:	81fff0ef          	jal	8000102c <walk>
  if (pte == 0) {
    80001812:	c519                	beqz	a0,80001820 <ismapped+0x1c>
    return 0;
  }
  if (*pte & PTE_V){
    80001814:	6108                	ld	a0,0(a0)
    80001816:	8905                	andi	a0,a0,1
    return 1;
  }
  return 0;
}
    80001818:	60a2                	ld	ra,8(sp)
    8000181a:	6402                	ld	s0,0(sp)
    8000181c:	0141                	addi	sp,sp,16
    8000181e:	8082                	ret
    return 0;
    80001820:	4501                	li	a0,0
    80001822:	bfdd                	j	80001818 <ismapped+0x14>

0000000080001824 <vmfault>:
{
    80001824:	7135                	addi	sp,sp,-160
    80001826:	ed06                	sd	ra,152(sp)
    80001828:	e922                	sd	s0,144(sp)
    8000182a:	e526                	sd	s1,136(sp)
    8000182c:	fcce                	sd	s3,120(sp)
    8000182e:	1100                	addi	s0,sp,160
    80001830:	89aa                	mv	s3,a0
    80001832:	84ae                	mv	s1,a1
  struct proc *p = myproc();
    80001834:	452000ef          	jal	80001c86 <myproc>
  if (va >= p->sz)
    80001838:	653c                	ld	a5,72(a0)
    8000183a:	00f4ea63          	bltu	s1,a5,8000184e <vmfault+0x2a>
    return 0;
    8000183e:	4981                	li	s3,0
}
    80001840:	854e                	mv	a0,s3
    80001842:	60ea                	ld	ra,152(sp)
    80001844:	644a                	ld	s0,144(sp)
    80001846:	64aa                	ld	s1,136(sp)
    80001848:	79e6                	ld	s3,120(sp)
    8000184a:	610d                	addi	sp,sp,160
    8000184c:	8082                	ret
    8000184e:	e14a                	sd	s2,128(sp)
    80001850:	892a                	mv	s2,a0
  va = PGROUNDDOWN(va);
    80001852:	77fd                	lui	a5,0xfffff
    80001854:	8cfd                	and	s1,s1,a5
  if(ismapped(pagetable, va)) {
    80001856:	85a6                	mv	a1,s1
    80001858:	854e                	mv	a0,s3
    8000185a:	fabff0ef          	jal	80001804 <ismapped>
    return 0;
    8000185e:	4981                	li	s3,0
  if(ismapped(pagetable, va)) {
    80001860:	c119                	beqz	a0,80001866 <vmfault+0x42>
    80001862:	690a                	ld	s2,128(sp)
    80001864:	bff1                	j	80001840 <vmfault+0x1c>
    80001866:	f8d2                	sd	s4,112(sp)
  mem = (uint64) kalloc();
    80001868:	b26ff0ef          	jal	80000b8e <kalloc>
    8000186c:	8a2a                	mv	s4,a0
  if(mem == 0)
    8000186e:	cd51                	beqz	a0,8000190a <vmfault+0xe6>
  mem = (uint64) kalloc();
    80001870:	89aa                	mv	s3,a0
  memset(&e, 0, sizeof(e));
    80001872:	06800613          	li	a2,104
    80001876:	4581                	li	a1,0
    80001878:	f6840513          	addi	a0,s0,-152
    8000187c:	d14ff0ef          	jal	80000d90 <memset>
  e.ticks  = ticks;
    80001880:	00007797          	auipc	a5,0x7
    80001884:	0b07a783          	lw	a5,176(a5) # 80008930 <ticks>
    80001888:	f6f42823          	sw	a5,-144(s0)
  e.cpu    = cpuid();
    8000188c:	3c8000ef          	jal	80001c54 <cpuid>
    80001890:	f6a42a23          	sw	a0,-140(s0)
  e.type   = MEM_FAULT;
    80001894:	478d                	li	a5,3
    80001896:	f6f42c23          	sw	a5,-136(s0)
  e.pid    = p->pid;
    8000189a:	03492783          	lw	a5,52(s2)
    8000189e:	f6f42e23          	sw	a5,-132(s0)
  e.state  = p->state;
    800018a2:	01892783          	lw	a5,24(s2)
    800018a6:	f8f42023          	sw	a5,-128(s0)
  e.va     = va;
    800018aa:	f8943c23          	sd	s1,-104(s0)
  e.pa     = mem;
    800018ae:	fb443023          	sd	s4,-96(s0)
  e.perm   = PTE_W | PTE_U | PTE_R;
    800018b2:	47d9                	li	a5,22
    800018b4:	fcf42023          	sw	a5,-64(s0)
  e.source = SRC_VMFAULT;
    800018b8:	479d                	li	a5,7
    800018ba:	fcf42223          	sw	a5,-60(s0)
  e.kind   = PAGE_USER;
    800018be:	4785                	li	a5,1
    800018c0:	fcf42423          	sw	a5,-56(s0)
  safestrcpy(e.name, p->name, MEM_NM);
    800018c4:	4641                	li	a2,16
    800018c6:	15890593          	addi	a1,s2,344
    800018ca:	f8440513          	addi	a0,s0,-124
    800018ce:	e00ff0ef          	jal	80000ece <safestrcpy>
  memlog_push(&e);
    800018d2:	f6840513          	addi	a0,s0,-152
    800018d6:	72b040ef          	jal	80006800 <memlog_push>
  memset((void *) mem, 0, PGSIZE);
    800018da:	6605                	lui	a2,0x1
    800018dc:	4581                	li	a1,0
    800018de:	8552                	mv	a0,s4
    800018e0:	cb0ff0ef          	jal	80000d90 <memset>
  if (mappages(p->pagetable, va, PGSIZE, mem, PTE_W|PTE_U|PTE_R) != 0) {
    800018e4:	4759                	li	a4,22
    800018e6:	86d2                	mv	a3,s4
    800018e8:	6605                	lui	a2,0x1
    800018ea:	85a6                	mv	a1,s1
    800018ec:	05093503          	ld	a0,80(s2)
    800018f0:	815ff0ef          	jal	80001104 <mappages>
    800018f4:	e501                	bnez	a0,800018fc <vmfault+0xd8>
    800018f6:	690a                	ld	s2,128(sp)
    800018f8:	7a46                	ld	s4,112(sp)
    800018fa:	b799                	j	80001840 <vmfault+0x1c>
    kfree((void *)mem);
    800018fc:	8552                	mv	a0,s4
    800018fe:	950ff0ef          	jal	80000a4e <kfree>
    return 0;
    80001902:	4981                	li	s3,0
    80001904:	690a                	ld	s2,128(sp)
    80001906:	7a46                	ld	s4,112(sp)
    80001908:	bf25                	j	80001840 <vmfault+0x1c>
    8000190a:	690a                	ld	s2,128(sp)
    8000190c:	7a46                	ld	s4,112(sp)
    8000190e:	bf0d                	j	80001840 <vmfault+0x1c>

0000000080001910 <copyout>:
  while(len > 0){
    80001910:	c2cd                	beqz	a3,800019b2 <copyout+0xa2>
{
    80001912:	711d                	addi	sp,sp,-96
    80001914:	ec86                	sd	ra,88(sp)
    80001916:	e8a2                	sd	s0,80(sp)
    80001918:	e4a6                	sd	s1,72(sp)
    8000191a:	f852                	sd	s4,48(sp)
    8000191c:	f05a                	sd	s6,32(sp)
    8000191e:	ec5e                	sd	s7,24(sp)
    80001920:	e862                	sd	s8,16(sp)
    80001922:	1080                	addi	s0,sp,96
    80001924:	8c2a                	mv	s8,a0
    80001926:	8b2e                	mv	s6,a1
    80001928:	8bb2                	mv	s7,a2
    8000192a:	8a36                	mv	s4,a3
    va0 = PGROUNDDOWN(dstva);
    8000192c:	74fd                	lui	s1,0xfffff
    8000192e:	8ced                	and	s1,s1,a1
    if(va0 >= MAXVA)
    80001930:	57fd                	li	a5,-1
    80001932:	83e9                	srli	a5,a5,0x1a
    80001934:	0897e163          	bltu	a5,s1,800019b6 <copyout+0xa6>
    80001938:	e0ca                	sd	s2,64(sp)
    8000193a:	fc4e                	sd	s3,56(sp)
    8000193c:	f456                	sd	s5,40(sp)
    8000193e:	e466                	sd	s9,8(sp)
    80001940:	e06a                	sd	s10,0(sp)
    80001942:	6d05                	lui	s10,0x1
    80001944:	8cbe                	mv	s9,a5
    80001946:	a015                	j	8000196a <copyout+0x5a>
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    80001948:	409b0533          	sub	a0,s6,s1
    8000194c:	0009861b          	sext.w	a2,s3
    80001950:	85de                	mv	a1,s7
    80001952:	954a                	add	a0,a0,s2
    80001954:	c98ff0ef          	jal	80000dec <memmove>
    len -= n;
    80001958:	413a0a33          	sub	s4,s4,s3
    src += n;
    8000195c:	9bce                	add	s7,s7,s3
  while(len > 0){
    8000195e:	040a0363          	beqz	s4,800019a4 <copyout+0x94>
    if(va0 >= MAXVA)
    80001962:	055cec63          	bltu	s9,s5,800019ba <copyout+0xaa>
    80001966:	84d6                	mv	s1,s5
    80001968:	8b56                	mv	s6,s5
    pa0 = walkaddr(pagetable, va0);
    8000196a:	85a6                	mv	a1,s1
    8000196c:	8562                	mv	a0,s8
    8000196e:	f58ff0ef          	jal	800010c6 <walkaddr>
    80001972:	892a                	mv	s2,a0
    if(pa0 == 0) {
    80001974:	e901                	bnez	a0,80001984 <copyout+0x74>
      if((pa0 = vmfault(pagetable, va0, 0)) == 0) {
    80001976:	4601                	li	a2,0
    80001978:	85a6                	mv	a1,s1
    8000197a:	8562                	mv	a0,s8
    8000197c:	ea9ff0ef          	jal	80001824 <vmfault>
    80001980:	892a                	mv	s2,a0
    80001982:	c139                	beqz	a0,800019c8 <copyout+0xb8>
    pte = walk(pagetable, va0, 0);
    80001984:	4601                	li	a2,0
    80001986:	85a6                	mv	a1,s1
    80001988:	8562                	mv	a0,s8
    8000198a:	ea2ff0ef          	jal	8000102c <walk>
    if((*pte & PTE_W) == 0)
    8000198e:	611c                	ld	a5,0(a0)
    80001990:	8b91                	andi	a5,a5,4
    80001992:	c3b1                	beqz	a5,800019d6 <copyout+0xc6>
    n = PGSIZE - (dstva - va0);
    80001994:	01a48ab3          	add	s5,s1,s10
    80001998:	416a89b3          	sub	s3,s5,s6
    if(n > len)
    8000199c:	fb3a76e3          	bgeu	s4,s3,80001948 <copyout+0x38>
    800019a0:	89d2                	mv	s3,s4
    800019a2:	b75d                	j	80001948 <copyout+0x38>
  return 0;
    800019a4:	4501                	li	a0,0
    800019a6:	6906                	ld	s2,64(sp)
    800019a8:	79e2                	ld	s3,56(sp)
    800019aa:	7aa2                	ld	s5,40(sp)
    800019ac:	6ca2                	ld	s9,8(sp)
    800019ae:	6d02                	ld	s10,0(sp)
    800019b0:	a80d                	j	800019e2 <copyout+0xd2>
    800019b2:	4501                	li	a0,0
}
    800019b4:	8082                	ret
      return -1;
    800019b6:	557d                	li	a0,-1
    800019b8:	a02d                	j	800019e2 <copyout+0xd2>
    800019ba:	557d                	li	a0,-1
    800019bc:	6906                	ld	s2,64(sp)
    800019be:	79e2                	ld	s3,56(sp)
    800019c0:	7aa2                	ld	s5,40(sp)
    800019c2:	6ca2                	ld	s9,8(sp)
    800019c4:	6d02                	ld	s10,0(sp)
    800019c6:	a831                	j	800019e2 <copyout+0xd2>
        return -1;
    800019c8:	557d                	li	a0,-1
    800019ca:	6906                	ld	s2,64(sp)
    800019cc:	79e2                	ld	s3,56(sp)
    800019ce:	7aa2                	ld	s5,40(sp)
    800019d0:	6ca2                	ld	s9,8(sp)
    800019d2:	6d02                	ld	s10,0(sp)
    800019d4:	a039                	j	800019e2 <copyout+0xd2>
      return -1;
    800019d6:	557d                	li	a0,-1
    800019d8:	6906                	ld	s2,64(sp)
    800019da:	79e2                	ld	s3,56(sp)
    800019dc:	7aa2                	ld	s5,40(sp)
    800019de:	6ca2                	ld	s9,8(sp)
    800019e0:	6d02                	ld	s10,0(sp)
}
    800019e2:	60e6                	ld	ra,88(sp)
    800019e4:	6446                	ld	s0,80(sp)
    800019e6:	64a6                	ld	s1,72(sp)
    800019e8:	7a42                	ld	s4,48(sp)
    800019ea:	7b02                	ld	s6,32(sp)
    800019ec:	6be2                	ld	s7,24(sp)
    800019ee:	6c42                	ld	s8,16(sp)
    800019f0:	6125                	addi	sp,sp,96
    800019f2:	8082                	ret

00000000800019f4 <copyin>:
  while(len > 0){
    800019f4:	c6c9                	beqz	a3,80001a7e <copyin+0x8a>
{
    800019f6:	715d                	addi	sp,sp,-80
    800019f8:	e486                	sd	ra,72(sp)
    800019fa:	e0a2                	sd	s0,64(sp)
    800019fc:	fc26                	sd	s1,56(sp)
    800019fe:	f84a                	sd	s2,48(sp)
    80001a00:	f44e                	sd	s3,40(sp)
    80001a02:	f052                	sd	s4,32(sp)
    80001a04:	ec56                	sd	s5,24(sp)
    80001a06:	e85a                	sd	s6,16(sp)
    80001a08:	e45e                	sd	s7,8(sp)
    80001a0a:	e062                	sd	s8,0(sp)
    80001a0c:	0880                	addi	s0,sp,80
    80001a0e:	8baa                	mv	s7,a0
    80001a10:	8aae                	mv	s5,a1
    80001a12:	8932                	mv	s2,a2
    80001a14:	8a36                	mv	s4,a3
    va0 = PGROUNDDOWN(srcva);
    80001a16:	7c7d                	lui	s8,0xfffff
    n = PGSIZE - (srcva - va0);
    80001a18:	6b05                	lui	s6,0x1
    80001a1a:	a035                	j	80001a46 <copyin+0x52>
    80001a1c:	412984b3          	sub	s1,s3,s2
    80001a20:	94da                	add	s1,s1,s6
    if(n > len)
    80001a22:	009a7363          	bgeu	s4,s1,80001a28 <copyin+0x34>
    80001a26:	84d2                	mv	s1,s4
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    80001a28:	413905b3          	sub	a1,s2,s3
    80001a2c:	0004861b          	sext.w	a2,s1
    80001a30:	95aa                	add	a1,a1,a0
    80001a32:	8556                	mv	a0,s5
    80001a34:	bb8ff0ef          	jal	80000dec <memmove>
    len -= n;
    80001a38:	409a0a33          	sub	s4,s4,s1
    dst += n;
    80001a3c:	9aa6                	add	s5,s5,s1
    srcva = va0 + PGSIZE;
    80001a3e:	01698933          	add	s2,s3,s6
  while(len > 0){
    80001a42:	020a0163          	beqz	s4,80001a64 <copyin+0x70>
    va0 = PGROUNDDOWN(srcva);
    80001a46:	018979b3          	and	s3,s2,s8
    pa0 = walkaddr(pagetable, va0);
    80001a4a:	85ce                	mv	a1,s3
    80001a4c:	855e                	mv	a0,s7
    80001a4e:	e78ff0ef          	jal	800010c6 <walkaddr>
    if(pa0 == 0) {
    80001a52:	f569                	bnez	a0,80001a1c <copyin+0x28>
      if((pa0 = vmfault(pagetable, va0, 0)) == 0) {
    80001a54:	4601                	li	a2,0
    80001a56:	85ce                	mv	a1,s3
    80001a58:	855e                	mv	a0,s7
    80001a5a:	dcbff0ef          	jal	80001824 <vmfault>
    80001a5e:	fd5d                	bnez	a0,80001a1c <copyin+0x28>
        return -1;
    80001a60:	557d                	li	a0,-1
    80001a62:	a011                	j	80001a66 <copyin+0x72>
  return 0;
    80001a64:	4501                	li	a0,0
}
    80001a66:	60a6                	ld	ra,72(sp)
    80001a68:	6406                	ld	s0,64(sp)
    80001a6a:	74e2                	ld	s1,56(sp)
    80001a6c:	7942                	ld	s2,48(sp)
    80001a6e:	79a2                	ld	s3,40(sp)
    80001a70:	7a02                	ld	s4,32(sp)
    80001a72:	6ae2                	ld	s5,24(sp)
    80001a74:	6b42                	ld	s6,16(sp)
    80001a76:	6ba2                	ld	s7,8(sp)
    80001a78:	6c02                	ld	s8,0(sp)
    80001a7a:	6161                	addi	sp,sp,80
    80001a7c:	8082                	ret
  return 0;
    80001a7e:	4501                	li	a0,0
}
    80001a80:	8082                	ret

0000000080001a82 <setprocstate>:
uint64 proc_total_created;
uint64 proc_total_exited;

static void
setprocstate(struct proc *p, enum procstate state)
{
    80001a82:	1101                	addi	sp,sp,-32
    80001a84:	ec06                	sd	ra,24(sp)
    80001a86:	e822                	sd	s0,16(sp)
    80001a88:	e426                	sd	s1,8(sp)
    80001a8a:	1000                	addi	s0,sp,32
    80001a8c:	84ae                	mv	s1,a1
  int first = 0;
  if (!(p->state_history & (1u << state))) {
    80001a8e:	5554                	lw	a3,44(a0)
    80001a90:	4785                	li	a5,1
    80001a92:	00b797bb          	sllw	a5,a5,a1
    80001a96:	00f6f733          	and	a4,a3,a5
    80001a9a:	2701                	sext.w	a4,a4
    80001a9c:	c719                	beqz	a4,80001aaa <setprocstate+0x28>
    p->state_history |= 1u << state;
    first = 1;
  }
  p->state = state;
    80001a9e:	cd0c                	sw	a1,24(a0)
  if (first) {
    acquire(&procstat_lock);
    proc_state_unique[state]++;
    release(&procstat_lock);
  }
}
    80001aa0:	60e2                	ld	ra,24(sp)
    80001aa2:	6442                	ld	s0,16(sp)
    80001aa4:	64a2                	ld	s1,8(sp)
    80001aa6:	6105                	addi	sp,sp,32
    80001aa8:	8082                	ret
    80001aaa:	e04a                	sd	s2,0(sp)
    p->state_history |= 1u << state;
    80001aac:	8edd                	or	a3,a3,a5
    80001aae:	d554                	sw	a3,44(a0)
  p->state = state;
    80001ab0:	cd0c                	sw	a1,24(a0)
    acquire(&procstat_lock);
    80001ab2:	0000f917          	auipc	s2,0xf
    80001ab6:	fd690913          	addi	s2,s2,-42 # 80010a88 <procstat_lock>
    80001aba:	854a                	mv	a0,s2
    80001abc:	a00ff0ef          	jal	80000cbc <acquire>
    proc_state_unique[state]++;
    80001ac0:	02049793          	slli	a5,s1,0x20
    80001ac4:	01d7d493          	srli	s1,a5,0x1d
    80001ac8:	94ca                	add	s1,s1,s2
    80001aca:	6c9c                	ld	a5,24(s1)
    80001acc:	0785                	addi	a5,a5,1
    80001ace:	ec9c                	sd	a5,24(s1)
    release(&procstat_lock);
    80001ad0:	854a                	mv	a0,s2
    80001ad2:	a82ff0ef          	jal	80000d54 <release>
    80001ad6:	6902                	ld	s2,0(sp)
}
    80001ad8:	b7e1                	j	80001aa0 <setprocstate+0x1e>

0000000080001ada <proc_mapstacks>:
struct spinlock wait_lock;

// Allocate a page for each process's kernel stack.
// Map it high in memory, followed by an invalid
// guard page.
void proc_mapstacks(pagetable_t kpgtbl) {
    80001ada:	7139                	addi	sp,sp,-64
    80001adc:	fc06                	sd	ra,56(sp)
    80001ade:	f822                	sd	s0,48(sp)
    80001ae0:	f426                	sd	s1,40(sp)
    80001ae2:	f04a                	sd	s2,32(sp)
    80001ae4:	ec4e                	sd	s3,24(sp)
    80001ae6:	e852                	sd	s4,16(sp)
    80001ae8:	e456                	sd	s5,8(sp)
    80001aea:	e05a                	sd	s6,0(sp)
    80001aec:	0080                	addi	s0,sp,64
    80001aee:	8a2a                	mv	s4,a0
  struct proc *p;

  for (p = proc; p < &proc[NPROC]; p++) {
    80001af0:	0000f497          	auipc	s1,0xf
    80001af4:	56848493          	addi	s1,s1,1384 # 80011058 <proc>
    char *pa = kalloc();
    if (pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int)(p - proc));
    80001af8:	8b26                	mv	s6,s1
    80001afa:	04fa5937          	lui	s2,0x4fa5
    80001afe:	fa590913          	addi	s2,s2,-91 # 4fa4fa5 <_entry-0x7b05b05b>
    80001b02:	0932                	slli	s2,s2,0xc
    80001b04:	fa590913          	addi	s2,s2,-91
    80001b08:	0932                	slli	s2,s2,0xc
    80001b0a:	fa590913          	addi	s2,s2,-91
    80001b0e:	0932                	slli	s2,s2,0xc
    80001b10:	fa590913          	addi	s2,s2,-91
    80001b14:	040009b7          	lui	s3,0x4000
    80001b18:	19fd                	addi	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    80001b1a:	09b2                	slli	s3,s3,0xc
  for (p = proc; p < &proc[NPROC]; p++) {
    80001b1c:	00015a97          	auipc	s5,0x15
    80001b20:	f3ca8a93          	addi	s5,s5,-196 # 80016a58 <tickslock>
    char *pa = kalloc();
    80001b24:	86aff0ef          	jal	80000b8e <kalloc>
    80001b28:	862a                	mv	a2,a0
    if (pa == 0)
    80001b2a:	cd15                	beqz	a0,80001b66 <proc_mapstacks+0x8c>
    uint64 va = KSTACK((int)(p - proc));
    80001b2c:	416485b3          	sub	a1,s1,s6
    80001b30:	858d                	srai	a1,a1,0x3
    80001b32:	032585b3          	mul	a1,a1,s2
    80001b36:	2585                	addiw	a1,a1,1
    80001b38:	00d5959b          	slliw	a1,a1,0xd
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    80001b3c:	4719                	li	a4,6
    80001b3e:	6685                	lui	a3,0x1
    80001b40:	40b985b3          	sub	a1,s3,a1
    80001b44:	8552                	mv	a0,s4
    80001b46:	ef4ff0ef          	jal	8000123a <kvmmap>
  for (p = proc; p < &proc[NPROC]; p++) {
    80001b4a:	16848493          	addi	s1,s1,360
    80001b4e:	fd549be3          	bne	s1,s5,80001b24 <proc_mapstacks+0x4a>
  }
}
    80001b52:	70e2                	ld	ra,56(sp)
    80001b54:	7442                	ld	s0,48(sp)
    80001b56:	74a2                	ld	s1,40(sp)
    80001b58:	7902                	ld	s2,32(sp)
    80001b5a:	69e2                	ld	s3,24(sp)
    80001b5c:	6a42                	ld	s4,16(sp)
    80001b5e:	6aa2                	ld	s5,8(sp)
    80001b60:	6b02                	ld	s6,0(sp)
    80001b62:	6121                	addi	sp,sp,64
    80001b64:	8082                	ret
      panic("kalloc");
    80001b66:	00006517          	auipc	a0,0x6
    80001b6a:	5fa50513          	addi	a0,a0,1530 # 80008160 <etext+0x160>
    80001b6e:	ca5fe0ef          	jal	80000812 <panic>

0000000080001b72 <procinit>:

// initialize the proc table.
void procinit(void) {
    80001b72:	7139                	addi	sp,sp,-64
    80001b74:	fc06                	sd	ra,56(sp)
    80001b76:	f822                	sd	s0,48(sp)
    80001b78:	f426                	sd	s1,40(sp)
    80001b7a:	f04a                	sd	s2,32(sp)
    80001b7c:	ec4e                	sd	s3,24(sp)
    80001b7e:	e852                	sd	s4,16(sp)
    80001b80:	e456                	sd	s5,8(sp)
    80001b82:	e05a                	sd	s6,0(sp)
    80001b84:	0080                	addi	s0,sp,64
  struct proc *p;

  initlock(&pid_lock, "nextpid");
    80001b86:	00006597          	auipc	a1,0x6
    80001b8a:	5e258593          	addi	a1,a1,1506 # 80008168 <etext+0x168>
    80001b8e:	0000f517          	auipc	a0,0xf
    80001b92:	f4250513          	addi	a0,a0,-190 # 80010ad0 <pid_lock>
    80001b96:	8a6ff0ef          	jal	80000c3c <initlock>
  initlock(&wait_lock, "wait_lock");
    80001b9a:	00006597          	auipc	a1,0x6
    80001b9e:	5d658593          	addi	a1,a1,1494 # 80008170 <etext+0x170>
    80001ba2:	0000f517          	auipc	a0,0xf
    80001ba6:	f4650513          	addi	a0,a0,-186 # 80010ae8 <wait_lock>
    80001baa:	892ff0ef          	jal	80000c3c <initlock>
  initlock(&schedinfo_lock, "schedinfo");
    80001bae:	00006597          	auipc	a1,0x6
    80001bb2:	5d258593          	addi	a1,a1,1490 # 80008180 <etext+0x180>
    80001bb6:	0000f517          	auipc	a0,0xf
    80001bba:	f4a50513          	addi	a0,a0,-182 # 80010b00 <schedinfo_lock>
    80001bbe:	87eff0ef          	jal	80000c3c <initlock>
  initlock(&procstat_lock, "procstats");
    80001bc2:	00006597          	auipc	a1,0x6
    80001bc6:	5ce58593          	addi	a1,a1,1486 # 80008190 <etext+0x190>
    80001bca:	0000f517          	auipc	a0,0xf
    80001bce:	ebe50513          	addi	a0,a0,-322 # 80010a88 <procstat_lock>
    80001bd2:	86aff0ef          	jal	80000c3c <initlock>
  for (p = proc; p < &proc[NPROC]; p++) {
    80001bd6:	0000f497          	auipc	s1,0xf
    80001bda:	48248493          	addi	s1,s1,1154 # 80011058 <proc>
    initlock(&p->lock, "proc");
    80001bde:	00006b17          	auipc	s6,0x6
    80001be2:	5c2b0b13          	addi	s6,s6,1474 # 800081a0 <etext+0x1a0>
    p->state = UNUSED;
    p->state_history = 0;
    p->kstack = KSTACK((int)(p - proc));
    80001be6:	8aa6                	mv	s5,s1
    80001be8:	04fa5937          	lui	s2,0x4fa5
    80001bec:	fa590913          	addi	s2,s2,-91 # 4fa4fa5 <_entry-0x7b05b05b>
    80001bf0:	0932                	slli	s2,s2,0xc
    80001bf2:	fa590913          	addi	s2,s2,-91
    80001bf6:	0932                	slli	s2,s2,0xc
    80001bf8:	fa590913          	addi	s2,s2,-91
    80001bfc:	0932                	slli	s2,s2,0xc
    80001bfe:	fa590913          	addi	s2,s2,-91
    80001c02:	040009b7          	lui	s3,0x4000
    80001c06:	19fd                	addi	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    80001c08:	09b2                	slli	s3,s3,0xc
  for (p = proc; p < &proc[NPROC]; p++) {
    80001c0a:	00015a17          	auipc	s4,0x15
    80001c0e:	e4ea0a13          	addi	s4,s4,-434 # 80016a58 <tickslock>
    initlock(&p->lock, "proc");
    80001c12:	85da                	mv	a1,s6
    80001c14:	8526                	mv	a0,s1
    80001c16:	826ff0ef          	jal	80000c3c <initlock>
    p->state = UNUSED;
    80001c1a:	0004ac23          	sw	zero,24(s1)
    p->state_history = 0;
    80001c1e:	0204a623          	sw	zero,44(s1)
    p->kstack = KSTACK((int)(p - proc));
    80001c22:	415487b3          	sub	a5,s1,s5
    80001c26:	878d                	srai	a5,a5,0x3
    80001c28:	032787b3          	mul	a5,a5,s2
    80001c2c:	2785                	addiw	a5,a5,1
    80001c2e:	00d7979b          	slliw	a5,a5,0xd
    80001c32:	40f987b3          	sub	a5,s3,a5
    80001c36:	e0bc                	sd	a5,64(s1)
  for (p = proc; p < &proc[NPROC]; p++) {
    80001c38:	16848493          	addi	s1,s1,360
    80001c3c:	fd449be3          	bne	s1,s4,80001c12 <procinit+0xa0>
  }
}
    80001c40:	70e2                	ld	ra,56(sp)
    80001c42:	7442                	ld	s0,48(sp)
    80001c44:	74a2                	ld	s1,40(sp)
    80001c46:	7902                	ld	s2,32(sp)
    80001c48:	69e2                	ld	s3,24(sp)
    80001c4a:	6a42                	ld	s4,16(sp)
    80001c4c:	6aa2                	ld	s5,8(sp)
    80001c4e:	6b02                	ld	s6,0(sp)
    80001c50:	6121                	addi	sp,sp,64
    80001c52:	8082                	ret

0000000080001c54 <cpuid>:

// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int cpuid() {
    80001c54:	1141                	addi	sp,sp,-16
    80001c56:	e422                	sd	s0,8(sp)
    80001c58:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    80001c5a:	8512                	mv	a0,tp
  int id = r_tp();
  return id;
}
    80001c5c:	2501                	sext.w	a0,a0
    80001c5e:	6422                	ld	s0,8(sp)
    80001c60:	0141                	addi	sp,sp,16
    80001c62:	8082                	ret

0000000080001c64 <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu *mycpu(void) {
    80001c64:	1141                	addi	sp,sp,-16
    80001c66:	e422                	sd	s0,8(sp)
    80001c68:	0800                	addi	s0,sp,16
    80001c6a:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    80001c6c:	2781                	sext.w	a5,a5
    80001c6e:	0a800713          	li	a4,168
    80001c72:	02e787b3          	mul	a5,a5,a4
  return c;
}
    80001c76:	0000f517          	auipc	a0,0xf
    80001c7a:	ea250513          	addi	a0,a0,-350 # 80010b18 <cpus>
    80001c7e:	953e                	add	a0,a0,a5
    80001c80:	6422                	ld	s0,8(sp)
    80001c82:	0141                	addi	sp,sp,16
    80001c84:	8082                	ret

0000000080001c86 <myproc>:

// Return the current struct proc *, or zero if none.
struct proc *myproc(void) {
    80001c86:	1101                	addi	sp,sp,-32
    80001c88:	ec06                	sd	ra,24(sp)
    80001c8a:	e822                	sd	s0,16(sp)
    80001c8c:	e426                	sd	s1,8(sp)
    80001c8e:	1000                	addi	s0,sp,32
  push_off();
    80001c90:	fedfe0ef          	jal	80000c7c <push_off>
    80001c94:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    80001c96:	2781                	sext.w	a5,a5
    80001c98:	0a800713          	li	a4,168
    80001c9c:	02e787b3          	mul	a5,a5,a4
    80001ca0:	0000f717          	auipc	a4,0xf
    80001ca4:	de870713          	addi	a4,a4,-536 # 80010a88 <procstat_lock>
    80001ca8:	97ba                	add	a5,a5,a4
    80001caa:	6bc4                	ld	s1,144(a5)
  pop_off();
    80001cac:	854ff0ef          	jal	80000d00 <pop_off>
  return p;
}
    80001cb0:	8526                	mv	a0,s1
    80001cb2:	60e2                	ld	ra,24(sp)
    80001cb4:	6442                	ld	s0,16(sp)
    80001cb6:	64a2                	ld	s1,8(sp)
    80001cb8:	6105                	addi	sp,sp,32
    80001cba:	8082                	ret

0000000080001cbc <forkret>:
  release(&p->lock);
}

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void forkret(void) {
    80001cbc:	7179                	addi	sp,sp,-48
    80001cbe:	f406                	sd	ra,40(sp)
    80001cc0:	f022                	sd	s0,32(sp)
    80001cc2:	ec26                	sd	s1,24(sp)
    80001cc4:	1800                	addi	s0,sp,48
  extern char userret[];
  static int first = 1;
  struct proc *p = myproc();
    80001cc6:	fc1ff0ef          	jal	80001c86 <myproc>
    80001cca:	84aa                	mv	s1,a0

  // Still holding p->lock from scheduler.
  release(&p->lock);
    80001ccc:	888ff0ef          	jal	80000d54 <release>

  if (first) {
    80001cd0:	00007797          	auipc	a5,0x7
    80001cd4:	c107a783          	lw	a5,-1008(a5) # 800088e0 <first.1>
    80001cd8:	cf8d                	beqz	a5,80001d12 <forkret+0x56>
    // File system initialization must be run in the context of a
    // regular process (e.g., because it calls sleep), and thus cannot
    // be run from main().
    fsinit(ROOTDEV);
    80001cda:	4505                	li	a0,1
    80001cdc:	14e020ef          	jal	80003e2a <fsinit>

    first = 0;
    80001ce0:	00007797          	auipc	a5,0x7
    80001ce4:	c007a023          	sw	zero,-1024(a5) # 800088e0 <first.1>
    // ensure other cores see first=0.
    __sync_synchronize();
    80001ce8:	0ff0000f          	fence

    // We can invoke kexec() now that file system is initialized.
    // Put the return value (argc) of kexec into a0.
    p->trapframe->a0 = kexec("/init", (char *[]){"/init", 0});
    80001cec:	00006517          	auipc	a0,0x6
    80001cf0:	4bc50513          	addi	a0,a0,1212 # 800081a8 <etext+0x1a8>
    80001cf4:	fca43823          	sd	a0,-48(s0)
    80001cf8:	fc043c23          	sd	zero,-40(s0)
    80001cfc:	fd040593          	addi	a1,s0,-48
    80001d00:	234030ef          	jal	80004f34 <kexec>
    80001d04:	6cbc                	ld	a5,88(s1)
    80001d06:	fba8                	sd	a0,112(a5)
    if (p->trapframe->a0 == -1) {
    80001d08:	6cbc                	ld	a5,88(s1)
    80001d0a:	7bb8                	ld	a4,112(a5)
    80001d0c:	57fd                	li	a5,-1
    80001d0e:	02f70d63          	beq	a4,a5,80001d48 <forkret+0x8c>
      panic("exec");
    }
  }

  // return to user space, mimicing usertrap()'s return.
  prepare_return();
    80001d12:	59b000ef          	jal	80002aac <prepare_return>
  uint64 satp = MAKE_SATP(p->pagetable);
    80001d16:	68a8                	ld	a0,80(s1)
    80001d18:	8131                	srli	a0,a0,0xc
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    80001d1a:	04000737          	lui	a4,0x4000
    80001d1e:	177d                	addi	a4,a4,-1 # 3ffffff <_entry-0x7c000001>
    80001d20:	0732                	slli	a4,a4,0xc
    80001d22:	00005797          	auipc	a5,0x5
    80001d26:	37a78793          	addi	a5,a5,890 # 8000709c <userret>
    80001d2a:	00005697          	auipc	a3,0x5
    80001d2e:	2d668693          	addi	a3,a3,726 # 80007000 <_trampoline>
    80001d32:	8f95                	sub	a5,a5,a3
    80001d34:	97ba                	add	a5,a5,a4
  ((void (*)(uint64))trampoline_userret)(satp);
    80001d36:	577d                	li	a4,-1
    80001d38:	177e                	slli	a4,a4,0x3f
    80001d3a:	8d59                	or	a0,a0,a4
    80001d3c:	9782                	jalr	a5
}
    80001d3e:	70a2                	ld	ra,40(sp)
    80001d40:	7402                	ld	s0,32(sp)
    80001d42:	64e2                	ld	s1,24(sp)
    80001d44:	6145                	addi	sp,sp,48
    80001d46:	8082                	ret
      panic("exec");
    80001d48:	00006517          	auipc	a0,0x6
    80001d4c:	46850513          	addi	a0,a0,1128 # 800081b0 <etext+0x1b0>
    80001d50:	ac3fe0ef          	jal	80000812 <panic>

0000000080001d54 <allocpid>:
int allocpid() {
    80001d54:	1101                	addi	sp,sp,-32
    80001d56:	ec06                	sd	ra,24(sp)
    80001d58:	e822                	sd	s0,16(sp)
    80001d5a:	e426                	sd	s1,8(sp)
    80001d5c:	e04a                	sd	s2,0(sp)
    80001d5e:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80001d60:	0000f917          	auipc	s2,0xf
    80001d64:	d7090913          	addi	s2,s2,-656 # 80010ad0 <pid_lock>
    80001d68:	854a                	mv	a0,s2
    80001d6a:	f53fe0ef          	jal	80000cbc <acquire>
  pid = nextpid;
    80001d6e:	00007797          	auipc	a5,0x7
    80001d72:	b7678793          	addi	a5,a5,-1162 # 800088e4 <nextpid>
    80001d76:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80001d78:	0014871b          	addiw	a4,s1,1
    80001d7c:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001d7e:	854a                	mv	a0,s2
    80001d80:	fd5fe0ef          	jal	80000d54 <release>
}
    80001d84:	8526                	mv	a0,s1
    80001d86:	60e2                	ld	ra,24(sp)
    80001d88:	6442                	ld	s0,16(sp)
    80001d8a:	64a2                	ld	s1,8(sp)
    80001d8c:	6902                	ld	s2,0(sp)
    80001d8e:	6105                	addi	sp,sp,32
    80001d90:	8082                	ret

0000000080001d92 <proc_pagetable>:
pagetable_t proc_pagetable(struct proc *p) {
    80001d92:	1101                	addi	sp,sp,-32
    80001d94:	ec06                	sd	ra,24(sp)
    80001d96:	e822                	sd	s0,16(sp)
    80001d98:	e426                	sd	s1,8(sp)
    80001d9a:	e04a                	sd	s2,0(sp)
    80001d9c:	1000                	addi	s0,sp,32
    80001d9e:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001da0:	d90ff0ef          	jal	80001330 <uvmcreate>
    80001da4:	84aa                	mv	s1,a0
  if (pagetable == 0)
    80001da6:	cd05                	beqz	a0,80001dde <proc_pagetable+0x4c>
  if (mappages(pagetable, TRAMPOLINE, PGSIZE, (uint64)trampoline,
    80001da8:	4729                	li	a4,10
    80001daa:	00005697          	auipc	a3,0x5
    80001dae:	25668693          	addi	a3,a3,598 # 80007000 <_trampoline>
    80001db2:	6605                	lui	a2,0x1
    80001db4:	040005b7          	lui	a1,0x4000
    80001db8:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001dba:	05b2                	slli	a1,a1,0xc
    80001dbc:	b48ff0ef          	jal	80001104 <mappages>
    80001dc0:	02054663          	bltz	a0,80001dec <proc_pagetable+0x5a>
  if (mappages(pagetable, TRAPFRAME, PGSIZE, (uint64)(p->trapframe),
    80001dc4:	4719                	li	a4,6
    80001dc6:	05893683          	ld	a3,88(s2)
    80001dca:	6605                	lui	a2,0x1
    80001dcc:	020005b7          	lui	a1,0x2000
    80001dd0:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001dd2:	05b6                	slli	a1,a1,0xd
    80001dd4:	8526                	mv	a0,s1
    80001dd6:	b2eff0ef          	jal	80001104 <mappages>
    80001dda:	00054f63          	bltz	a0,80001df8 <proc_pagetable+0x66>
}
    80001dde:	8526                	mv	a0,s1
    80001de0:	60e2                	ld	ra,24(sp)
    80001de2:	6442                	ld	s0,16(sp)
    80001de4:	64a2                	ld	s1,8(sp)
    80001de6:	6902                	ld	s2,0(sp)
    80001de8:	6105                	addi	sp,sp,32
    80001dea:	8082                	ret
    uvmfree(pagetable, 0);
    80001dec:	4581                	li	a1,0
    80001dee:	8526                	mv	a0,s1
    80001df0:	863ff0ef          	jal	80001652 <uvmfree>
    return 0;
    80001df4:	4481                	li	s1,0
    80001df6:	b7e5                	j	80001dde <proc_pagetable+0x4c>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001df8:	4681                	li	a3,0
    80001dfa:	4605                	li	a2,1
    80001dfc:	040005b7          	lui	a1,0x4000
    80001e00:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001e02:	05b2                	slli	a1,a1,0xc
    80001e04:	8526                	mv	a0,s1
    80001e06:	d50ff0ef          	jal	80001356 <uvmunmap>
    uvmfree(pagetable, 0);
    80001e0a:	4581                	li	a1,0
    80001e0c:	8526                	mv	a0,s1
    80001e0e:	845ff0ef          	jal	80001652 <uvmfree>
    return 0;
    80001e12:	4481                	li	s1,0
    80001e14:	b7e9                	j	80001dde <proc_pagetable+0x4c>

0000000080001e16 <proc_freepagetable>:
void proc_freepagetable(pagetable_t pagetable, uint64 sz) {
    80001e16:	1101                	addi	sp,sp,-32
    80001e18:	ec06                	sd	ra,24(sp)
    80001e1a:	e822                	sd	s0,16(sp)
    80001e1c:	e426                	sd	s1,8(sp)
    80001e1e:	e04a                	sd	s2,0(sp)
    80001e20:	1000                	addi	s0,sp,32
    80001e22:	84aa                	mv	s1,a0
    80001e24:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001e26:	4681                	li	a3,0
    80001e28:	4605                	li	a2,1
    80001e2a:	040005b7          	lui	a1,0x4000
    80001e2e:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001e30:	05b2                	slli	a1,a1,0xc
    80001e32:	d24ff0ef          	jal	80001356 <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001e36:	4681                	li	a3,0
    80001e38:	4605                	li	a2,1
    80001e3a:	020005b7          	lui	a1,0x2000
    80001e3e:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001e40:	05b6                	slli	a1,a1,0xd
    80001e42:	8526                	mv	a0,s1
    80001e44:	d12ff0ef          	jal	80001356 <uvmunmap>
  uvmfree(pagetable, sz);
    80001e48:	85ca                	mv	a1,s2
    80001e4a:	8526                	mv	a0,s1
    80001e4c:	807ff0ef          	jal	80001652 <uvmfree>
}
    80001e50:	60e2                	ld	ra,24(sp)
    80001e52:	6442                	ld	s0,16(sp)
    80001e54:	64a2                	ld	s1,8(sp)
    80001e56:	6902                	ld	s2,0(sp)
    80001e58:	6105                	addi	sp,sp,32
    80001e5a:	8082                	ret

0000000080001e5c <freeproc>:
static void freeproc(struct proc *p) {
    80001e5c:	1101                	addi	sp,sp,-32
    80001e5e:	ec06                	sd	ra,24(sp)
    80001e60:	e822                	sd	s0,16(sp)
    80001e62:	e426                	sd	s1,8(sp)
    80001e64:	1000                	addi	s0,sp,32
    80001e66:	84aa                	mv	s1,a0
  if (p->trapframe)
    80001e68:	6d28                	ld	a0,88(a0)
    80001e6a:	c119                	beqz	a0,80001e70 <freeproc+0x14>
    kfree((void *)p->trapframe);
    80001e6c:	be3fe0ef          	jal	80000a4e <kfree>
  p->trapframe = 0;
    80001e70:	0404bc23          	sd	zero,88(s1)
  if (p->pagetable)
    80001e74:	68a8                	ld	a0,80(s1)
    80001e76:	c501                	beqz	a0,80001e7e <freeproc+0x22>
    proc_freepagetable(p->pagetable, p->sz);
    80001e78:	64ac                	ld	a1,72(s1)
    80001e7a:	f9dff0ef          	jal	80001e16 <proc_freepagetable>
  p->pagetable = 0;
    80001e7e:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    80001e82:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    80001e86:	0204aa23          	sw	zero,52(s1)
  p->parent = 0;
    80001e8a:	0204bc23          	sd	zero,56(s1)
  p->name[0] = 0;
    80001e8e:	14048c23          	sb	zero,344(s1)
  p->chan = 0;
    80001e92:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    80001e96:	0204a423          	sw	zero,40(s1)
  p->xstate = 0;
    80001e9a:	0204a823          	sw	zero,48(s1)
  p->state_history = 0;
    80001e9e:	0204a623          	sw	zero,44(s1)
  p->state = UNUSED;
    80001ea2:	0004ac23          	sw	zero,24(s1)
}
    80001ea6:	60e2                	ld	ra,24(sp)
    80001ea8:	6442                	ld	s0,16(sp)
    80001eaa:	64a2                	ld	s1,8(sp)
    80001eac:	6105                	addi	sp,sp,32
    80001eae:	8082                	ret

0000000080001eb0 <allocproc>:
static struct proc *allocproc(void) {
    80001eb0:	1101                	addi	sp,sp,-32
    80001eb2:	ec06                	sd	ra,24(sp)
    80001eb4:	e822                	sd	s0,16(sp)
    80001eb6:	e426                	sd	s1,8(sp)
    80001eb8:	e04a                	sd	s2,0(sp)
    80001eba:	1000                	addi	s0,sp,32
  for (p = proc; p < &proc[NPROC]; p++) {
    80001ebc:	0000f497          	auipc	s1,0xf
    80001ec0:	19c48493          	addi	s1,s1,412 # 80011058 <proc>
    80001ec4:	00015917          	auipc	s2,0x15
    80001ec8:	b9490913          	addi	s2,s2,-1132 # 80016a58 <tickslock>
    acquire(&p->lock);
    80001ecc:	8526                	mv	a0,s1
    80001ece:	deffe0ef          	jal	80000cbc <acquire>
    if (p->state == UNUSED) {
    80001ed2:	4c9c                	lw	a5,24(s1)
    80001ed4:	cb91                	beqz	a5,80001ee8 <allocproc+0x38>
      release(&p->lock);
    80001ed6:	8526                	mv	a0,s1
    80001ed8:	e7dfe0ef          	jal	80000d54 <release>
  for (p = proc; p < &proc[NPROC]; p++) {
    80001edc:	16848493          	addi	s1,s1,360
    80001ee0:	ff2496e3          	bne	s1,s2,80001ecc <allocproc+0x1c>
  return 0;
    80001ee4:	4481                	li	s1,0
    80001ee6:	a0a5                	j	80001f4e <allocproc+0x9e>
  p->pid = allocpid();
    80001ee8:	e6dff0ef          	jal	80001d54 <allocpid>
    80001eec:	d8c8                	sw	a0,52(s1)
  setprocstate(p, USED);
    80001eee:	4585                	li	a1,1
    80001ef0:	8526                	mv	a0,s1
    80001ef2:	b91ff0ef          	jal	80001a82 <setprocstate>
  if ((p->trapframe = (struct trapframe *)kalloc()) == 0) {
    80001ef6:	c99fe0ef          	jal	80000b8e <kalloc>
    80001efa:	892a                	mv	s2,a0
    80001efc:	eca8                	sd	a0,88(s1)
    80001efe:	cd39                	beqz	a0,80001f5c <allocproc+0xac>
  p->pagetable = proc_pagetable(p);
    80001f00:	8526                	mv	a0,s1
    80001f02:	e91ff0ef          	jal	80001d92 <proc_pagetable>
    80001f06:	892a                	mv	s2,a0
    80001f08:	e8a8                	sd	a0,80(s1)
  if (p->pagetable == 0) {
    80001f0a:	c12d                	beqz	a0,80001f6c <allocproc+0xbc>
  memset(&p->context, 0, sizeof(p->context));
    80001f0c:	07000613          	li	a2,112
    80001f10:	4581                	li	a1,0
    80001f12:	06048513          	addi	a0,s1,96
    80001f16:	e7bfe0ef          	jal	80000d90 <memset>
  p->context.ra = (uint64)forkret;
    80001f1a:	00000797          	auipc	a5,0x0
    80001f1e:	da278793          	addi	a5,a5,-606 # 80001cbc <forkret>
    80001f22:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001f24:	60bc                	ld	a5,64(s1)
    80001f26:	6705                	lui	a4,0x1
    80001f28:	97ba                	add	a5,a5,a4
    80001f2a:	f4bc                	sd	a5,104(s1)
  acquire(&procstat_lock);
    80001f2c:	0000f917          	auipc	s2,0xf
    80001f30:	b5c90913          	addi	s2,s2,-1188 # 80010a88 <procstat_lock>
    80001f34:	854a                	mv	a0,s2
    80001f36:	d87fe0ef          	jal	80000cbc <acquire>
  proc_total_created++;
    80001f3a:	00007717          	auipc	a4,0x7
    80001f3e:	9de70713          	addi	a4,a4,-1570 # 80008918 <proc_total_created>
    80001f42:	631c                	ld	a5,0(a4)
    80001f44:	0785                	addi	a5,a5,1
    80001f46:	e31c                	sd	a5,0(a4)
  release(&procstat_lock);
    80001f48:	854a                	mv	a0,s2
    80001f4a:	e0bfe0ef          	jal	80000d54 <release>
}
    80001f4e:	8526                	mv	a0,s1
    80001f50:	60e2                	ld	ra,24(sp)
    80001f52:	6442                	ld	s0,16(sp)
    80001f54:	64a2                	ld	s1,8(sp)
    80001f56:	6902                	ld	s2,0(sp)
    80001f58:	6105                	addi	sp,sp,32
    80001f5a:	8082                	ret
    freeproc(p);
    80001f5c:	8526                	mv	a0,s1
    80001f5e:	effff0ef          	jal	80001e5c <freeproc>
    release(&p->lock);
    80001f62:	8526                	mv	a0,s1
    80001f64:	df1fe0ef          	jal	80000d54 <release>
    return 0;
    80001f68:	84ca                	mv	s1,s2
    80001f6a:	b7d5                	j	80001f4e <allocproc+0x9e>
    freeproc(p);
    80001f6c:	8526                	mv	a0,s1
    80001f6e:	eefff0ef          	jal	80001e5c <freeproc>
    release(&p->lock);
    80001f72:	8526                	mv	a0,s1
    80001f74:	de1fe0ef          	jal	80000d54 <release>
    return 0;
    80001f78:	84ca                	mv	s1,s2
    80001f7a:	bfd1                	j	80001f4e <allocproc+0x9e>

0000000080001f7c <userinit>:
void userinit(void) {
    80001f7c:	1101                	addi	sp,sp,-32
    80001f7e:	ec06                	sd	ra,24(sp)
    80001f80:	e822                	sd	s0,16(sp)
    80001f82:	e426                	sd	s1,8(sp)
    80001f84:	1000                	addi	s0,sp,32
  p = allocproc();
    80001f86:	f2bff0ef          	jal	80001eb0 <allocproc>
    80001f8a:	84aa                	mv	s1,a0
  initproc = p;
    80001f8c:	00007797          	auipc	a5,0x7
    80001f90:	98a7be23          	sd	a0,-1636(a5) # 80008928 <initproc>
  p->cwd = namei("/");
    80001f94:	00006517          	auipc	a0,0x6
    80001f98:	22450513          	addi	a0,a0,548 # 800081b8 <etext+0x1b8>
    80001f9c:	3b0020ef          	jal	8000434c <namei>
    80001fa0:	14a4b823          	sd	a0,336(s1)
  setprocstate(p, RUNNABLE);
    80001fa4:	458d                	li	a1,3
    80001fa6:	8526                	mv	a0,s1
    80001fa8:	adbff0ef          	jal	80001a82 <setprocstate>
  release(&p->lock);
    80001fac:	8526                	mv	a0,s1
    80001fae:	da7fe0ef          	jal	80000d54 <release>
}
    80001fb2:	60e2                	ld	ra,24(sp)
    80001fb4:	6442                	ld	s0,16(sp)
    80001fb6:	64a2                	ld	s1,8(sp)
    80001fb8:	6105                	addi	sp,sp,32
    80001fba:	8082                	ret

0000000080001fbc <growproc>:
int growproc(int n) {
    80001fbc:	7135                	addi	sp,sp,-160
    80001fbe:	ed06                	sd	ra,152(sp)
    80001fc0:	e922                	sd	s0,144(sp)
    80001fc2:	e526                	sd	s1,136(sp)
    80001fc4:	e14a                	sd	s2,128(sp)
    80001fc6:	fcce                	sd	s3,120(sp)
    80001fc8:	1100                	addi	s0,sp,160
    80001fca:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80001fcc:	cbbff0ef          	jal	80001c86 <myproc>
    80001fd0:	89aa                	mv	s3,a0
  sz = p->sz;
    80001fd2:	04853903          	ld	s2,72(a0)
  if (n > 0) {
    80001fd6:	02905b63          	blez	s1,8000200c <growproc+0x50>
    if (sz + n > TRAPFRAME) {
    80001fda:	01248633          	add	a2,s1,s2
    80001fde:	020007b7          	lui	a5,0x2000
    80001fe2:	17fd                	addi	a5,a5,-1 # 1ffffff <_entry-0x7e000001>
    80001fe4:	07b6                	slli	a5,a5,0xd
    80001fe6:	08c7ee63          	bltu	a5,a2,80002082 <growproc+0xc6>
    if ((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0) {
    80001fea:	4691                	li	a3,4
    80001fec:	85ca                	mv	a1,s2
    80001fee:	6928                	ld	a0,80(a0)
    80001ff0:	ccaff0ef          	jal	800014ba <uvmalloc>
    80001ff4:	892a                	mv	s2,a0
    80001ff6:	c941                	beqz	a0,80002086 <growproc+0xca>
  p->sz = sz;
    80001ff8:	0529b423          	sd	s2,72(s3)
  return 0;
    80001ffc:	4501                	li	a0,0
}
    80001ffe:	60ea                	ld	ra,152(sp)
    80002000:	644a                	ld	s0,144(sp)
    80002002:	64aa                	ld	s1,136(sp)
    80002004:	690a                	ld	s2,128(sp)
    80002006:	79e6                	ld	s3,120(sp)
    80002008:	610d                	addi	sp,sp,160
    8000200a:	8082                	ret
  } else if (n < 0) {
    8000200c:	fe04d6e3          	bgez	s1,80001ff8 <growproc+0x3c>
  memset(&e, 0, sizeof(e));
    80002010:	06800613          	li	a2,104
    80002014:	4581                	li	a1,0
    80002016:	f6840513          	addi	a0,s0,-152
    8000201a:	d77fe0ef          	jal	80000d90 <memset>
  e.ticks  = ticks;
    8000201e:	00007797          	auipc	a5,0x7
    80002022:	9127a783          	lw	a5,-1774(a5) # 80008930 <ticks>
    80002026:	f6f42823          	sw	a5,-144(s0)
    8000202a:	8792                	mv	a5,tp
  int id = r_tp();
    8000202c:	f6f42a23          	sw	a5,-140(s0)
  e.type   = MEM_SHRINK;
    80002030:	4789                	li	a5,2
    80002032:	f6f42c23          	sw	a5,-136(s0)
  e.pid    = p->pid;
    80002036:	0349a783          	lw	a5,52(s3)
    8000203a:	f6f42e23          	sw	a5,-132(s0)
  e.state  = p->state;
    8000203e:	0189a783          	lw	a5,24(s3)
    80002042:	f8f42023          	sw	a5,-128(s0)
  e.oldsz  = sz;
    80002046:	fb243423          	sd	s2,-88(s0)
  e.newsz  = sz + n;
    8000204a:	94ca                	add	s1,s1,s2
    8000204c:	fa943823          	sd	s1,-80(s0)
  e.source = SRC_UVMDEALLOC;
    80002050:	4799                	li	a5,6
    80002052:	fcf42223          	sw	a5,-60(s0)
  e.kind   = PAGE_USER;
    80002056:	4785                	li	a5,1
    80002058:	fcf42423          	sw	a5,-56(s0)
  safestrcpy(e.name, p->name, MEM_NM);
    8000205c:	4641                	li	a2,16
    8000205e:	15898593          	addi	a1,s3,344
    80002062:	f8440513          	addi	a0,s0,-124
    80002066:	e69fe0ef          	jal	80000ece <safestrcpy>
  memlog_push(&e);
    8000206a:	f6840513          	addi	a0,s0,-152
    8000206e:	792040ef          	jal	80006800 <memlog_push>
  sz = uvmdealloc(p->pagetable, sz, sz + n);
    80002072:	8626                	mv	a2,s1
    80002074:	85ca                	mv	a1,s2
    80002076:	0509b503          	ld	a0,80(s3)
    8000207a:	bfcff0ef          	jal	80001476 <uvmdealloc>
    8000207e:	892a                	mv	s2,a0
    80002080:	bfa5                	j	80001ff8 <growproc+0x3c>
      return -1;
    80002082:	557d                	li	a0,-1
    80002084:	bfad                	j	80001ffe <growproc+0x42>
      return -1;
    80002086:	557d                	li	a0,-1
    80002088:	bf9d                	j	80001ffe <growproc+0x42>

000000008000208a <kfork>:
int kfork(void) {
    8000208a:	7139                	addi	sp,sp,-64
    8000208c:	fc06                	sd	ra,56(sp)
    8000208e:	f822                	sd	s0,48(sp)
    80002090:	f04a                	sd	s2,32(sp)
    80002092:	e456                	sd	s5,8(sp)
    80002094:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    80002096:	bf1ff0ef          	jal	80001c86 <myproc>
    8000209a:	8aaa                	mv	s5,a0
  if ((np = allocproc()) == 0) {
    8000209c:	e15ff0ef          	jal	80001eb0 <allocproc>
    800020a0:	0e050b63          	beqz	a0,80002196 <kfork+0x10c>
    800020a4:	e852                	sd	s4,16(sp)
    800020a6:	8a2a                	mv	s4,a0
  if (uvmcopy(p->pagetable, np->pagetable, p->sz) < 0) {
    800020a8:	048ab603          	ld	a2,72(s5)
    800020ac:	692c                	ld	a1,80(a0)
    800020ae:	050ab503          	ld	a0,80(s5)
    800020b2:	dd2ff0ef          	jal	80001684 <uvmcopy>
    800020b6:	04054a63          	bltz	a0,8000210a <kfork+0x80>
    800020ba:	f426                	sd	s1,40(sp)
    800020bc:	ec4e                	sd	s3,24(sp)
  np->sz = p->sz;
    800020be:	048ab783          	ld	a5,72(s5)
    800020c2:	04fa3423          	sd	a5,72(s4)
  *(np->trapframe) = *(p->trapframe);
    800020c6:	058ab683          	ld	a3,88(s5)
    800020ca:	87b6                	mv	a5,a3
    800020cc:	058a3703          	ld	a4,88(s4)
    800020d0:	12068693          	addi	a3,a3,288
    800020d4:	0007b803          	ld	a6,0(a5)
    800020d8:	6788                	ld	a0,8(a5)
    800020da:	6b8c                	ld	a1,16(a5)
    800020dc:	6f90                	ld	a2,24(a5)
    800020de:	01073023          	sd	a6,0(a4)
    800020e2:	e708                	sd	a0,8(a4)
    800020e4:	eb0c                	sd	a1,16(a4)
    800020e6:	ef10                	sd	a2,24(a4)
    800020e8:	02078793          	addi	a5,a5,32
    800020ec:	02070713          	addi	a4,a4,32
    800020f0:	fed792e3          	bne	a5,a3,800020d4 <kfork+0x4a>
  np->trapframe->a0 = 0;
    800020f4:	058a3783          	ld	a5,88(s4)
    800020f8:	0607b823          	sd	zero,112(a5)
  for (i = 0; i < NOFILE; i++)
    800020fc:	0d0a8493          	addi	s1,s5,208
    80002100:	0d0a0913          	addi	s2,s4,208
    80002104:	150a8993          	addi	s3,s5,336
    80002108:	a831                	j	80002124 <kfork+0x9a>
    freeproc(np);
    8000210a:	8552                	mv	a0,s4
    8000210c:	d51ff0ef          	jal	80001e5c <freeproc>
    release(&np->lock);
    80002110:	8552                	mv	a0,s4
    80002112:	c43fe0ef          	jal	80000d54 <release>
    return -1;
    80002116:	597d                	li	s2,-1
    80002118:	6a42                	ld	s4,16(sp)
    8000211a:	a0bd                	j	80002188 <kfork+0xfe>
  for (i = 0; i < NOFILE; i++)
    8000211c:	04a1                	addi	s1,s1,8
    8000211e:	0921                	addi	s2,s2,8
    80002120:	01348963          	beq	s1,s3,80002132 <kfork+0xa8>
    if (p->ofile[i])
    80002124:	6088                	ld	a0,0(s1)
    80002126:	d97d                	beqz	a0,8000211c <kfork+0x92>
      np->ofile[i] = filedup(p->ofile[i]);
    80002128:	7be020ef          	jal	800048e6 <filedup>
    8000212c:	00a93023          	sd	a0,0(s2)
    80002130:	b7f5                	j	8000211c <kfork+0x92>
  np->cwd = idup(p->cwd);
    80002132:	150ab503          	ld	a0,336(s5)
    80002136:	1cb010ef          	jal	80003b00 <idup>
    8000213a:	14aa3823          	sd	a0,336(s4)
  safestrcpy(np->name, p->name, sizeof(p->name));
    8000213e:	4641                	li	a2,16
    80002140:	158a8593          	addi	a1,s5,344
    80002144:	158a0513          	addi	a0,s4,344
    80002148:	d87fe0ef          	jal	80000ece <safestrcpy>
  pid = np->pid;
    8000214c:	034a2903          	lw	s2,52(s4)
  release(&np->lock);
    80002150:	8552                	mv	a0,s4
    80002152:	c03fe0ef          	jal	80000d54 <release>
  acquire(&wait_lock);
    80002156:	0000f497          	auipc	s1,0xf
    8000215a:	99248493          	addi	s1,s1,-1646 # 80010ae8 <wait_lock>
    8000215e:	8526                	mv	a0,s1
    80002160:	b5dfe0ef          	jal	80000cbc <acquire>
  np->parent = p;
    80002164:	035a3c23          	sd	s5,56(s4)
  release(&wait_lock);
    80002168:	8526                	mv	a0,s1
    8000216a:	bebfe0ef          	jal	80000d54 <release>
  acquire(&np->lock);
    8000216e:	8552                	mv	a0,s4
    80002170:	b4dfe0ef          	jal	80000cbc <acquire>
  setprocstate(np, RUNNABLE);
    80002174:	458d                	li	a1,3
    80002176:	8552                	mv	a0,s4
    80002178:	90bff0ef          	jal	80001a82 <setprocstate>
  release(&np->lock);
    8000217c:	8552                	mv	a0,s4
    8000217e:	bd7fe0ef          	jal	80000d54 <release>
  return pid;
    80002182:	74a2                	ld	s1,40(sp)
    80002184:	69e2                	ld	s3,24(sp)
    80002186:	6a42                	ld	s4,16(sp)
}
    80002188:	854a                	mv	a0,s2
    8000218a:	70e2                	ld	ra,56(sp)
    8000218c:	7442                	ld	s0,48(sp)
    8000218e:	7902                	ld	s2,32(sp)
    80002190:	6aa2                	ld	s5,8(sp)
    80002192:	6121                	addi	sp,sp,64
    80002194:	8082                	ret
    return -1;
    80002196:	597d                	li	s2,-1
    80002198:	bfc5                	j	80002188 <kfork+0xfe>

000000008000219a <scheduler>:
void scheduler(void) {
    8000219a:	7135                	addi	sp,sp,-160
    8000219c:	ed06                	sd	ra,152(sp)
    8000219e:	e922                	sd	s0,144(sp)
    800021a0:	e526                	sd	s1,136(sp)
    800021a2:	e14a                	sd	s2,128(sp)
    800021a4:	fcce                	sd	s3,120(sp)
    800021a6:	f8d2                	sd	s4,112(sp)
    800021a8:	f4d6                	sd	s5,104(sp)
    800021aa:	f0da                	sd	s6,96(sp)
    800021ac:	ecde                	sd	s7,88(sp)
    800021ae:	1100                	addi	s0,sp,160
    800021b0:	8492                	mv	s1,tp
  int id = r_tp();
    800021b2:	2481                	sext.w	s1,s1
    800021b4:	8792                	mv	a5,tp
    if(cpuid() == 0){
    800021b6:	2781                	sext.w	a5,a5
    800021b8:	cf9d                	beqz	a5,800021f6 <scheduler+0x5c>
  c->proc = 0;
    800021ba:	0a800a93          	li	s5,168
    800021be:	03548ab3          	mul	s5,s1,s5
    800021c2:	0000f797          	auipc	a5,0xf
    800021c6:	8c678793          	addi	a5,a5,-1850 # 80010a88 <procstat_lock>
    800021ca:	97d6                	add	a5,a5,s5
    800021cc:	0807b823          	sd	zero,144(a5)
        swtch(&c->context, &p->context);
    800021d0:	0000f797          	auipc	a5,0xf
    800021d4:	95078793          	addi	a5,a5,-1712 # 80010b20 <cpus+0x8>
    800021d8:	9abe                	add	s5,s5,a5
        c->proc = p;
    800021da:	0a800793          	li	a5,168
    800021de:	02f484b3          	mul	s1,s1,a5
    800021e2:	0000f917          	auipc	s2,0xf
    800021e6:	8a690913          	addi	s2,s2,-1882 # 80010a88 <procstat_lock>
    800021ea:	9926                	add	s2,s2,s1
        c->run_start_ticks = ticks;
    800021ec:	00006a17          	auipc	s4,0x6
    800021f0:	744a0a13          	addi	s4,s4,1860 # 80008930 <ticks>
    800021f4:	ac05                	j	80002424 <scheduler+0x28a>
      acquire(&schedinfo_lock);
    800021f6:	0000f517          	auipc	a0,0xf
    800021fa:	90a50513          	addi	a0,a0,-1782 # 80010b00 <schedinfo_lock>
    800021fe:	abffe0ef          	jal	80000cbc <acquire>
      if(sched_info_logged == 0){
    80002202:	00006797          	auipc	a5,0x6
    80002206:	71e7a783          	lw	a5,1822(a5) # 80008920 <sched_info_logged>
    8000220a:	cb81                	beqz	a5,8000221a <scheduler+0x80>
      release(&schedinfo_lock);
    8000220c:	0000f517          	auipc	a0,0xf
    80002210:	8f450513          	addi	a0,a0,-1804 # 80010b00 <schedinfo_lock>
    80002214:	b41fe0ef          	jal	80000d54 <release>
    80002218:	b74d                	j	800021ba <scheduler+0x20>
        sched_info_logged = 1;
    8000221a:	4905                	li	s2,1
    8000221c:	00006797          	auipc	a5,0x6
    80002220:	7127a223          	sw	s2,1796(a5) # 80008920 <sched_info_logged>
        memset(&e, 0, sizeof(e));
    80002224:	04400613          	li	a2,68
    80002228:	4581                	li	a1,0
    8000222a:	f6840513          	addi	a0,s0,-152
    8000222e:	b63fe0ef          	jal	80000d90 <memset>
        e.ticks = ticks;
    80002232:	00006797          	auipc	a5,0x6
    80002236:	6fe7a783          	lw	a5,1790(a5) # 80008930 <ticks>
    8000223a:	f6f42623          	sw	a5,-148(s0)
        e.event_type = SCHED_EV_INFO;
    8000223e:	f7242823          	sw	s2,-144(s0)
        safestrcpy(e.scheduler_name, "RR", sizeof(e.scheduler_name));
    80002242:	4641                	li	a2,16
    80002244:	00006597          	auipc	a1,0x6
    80002248:	f7c58593          	addi	a1,a1,-132 # 800081c0 <etext+0x1c0>
    8000224c:	f7440513          	addi	a0,s0,-140
    80002250:	c7ffe0ef          	jal	80000ece <safestrcpy>
        e.num_cpus = 3;
    80002254:	478d                	li	a5,3
    80002256:	f8f42223          	sw	a5,-124(s0)
        e.time_slice = 1;
    8000225a:	f9242423          	sw	s2,-120(s0)
        schedlog_emit(&e);
    8000225e:	f6840513          	addi	a0,s0,-152
    80002262:	007040ef          	jal	80006a68 <schedlog_emit>
    80002266:	b75d                	j	8000220c <scheduler+0x72>
    80002268:	8ba6                	mv	s7,s1
        if(strncmp(p->name, "schedexport", 16) != 0){
    8000226a:	15848993          	addi	s3,s1,344
    8000226e:	4641                	li	a2,16
    80002270:	00006597          	auipc	a1,0x6
    80002274:	f5858593          	addi	a1,a1,-168 # 800081c8 <etext+0x1c8>
    80002278:	854e                	mv	a0,s3
    8000227a:	be3fe0ef          	jal	80000e5c <strncmp>
    8000227e:	0e051a63          	bnez	a0,80002372 <scheduler+0x1d8>
        swtch(&c->context, &p->context);
    80002282:	060b8593          	addi	a1,s7,96 # 1060 <_entry-0x7fffefa0>
    80002286:	8556                	mv	a0,s5
    80002288:	77e000ef          	jal	80002a06 <swtch>
        if(strncmp(p->name, "schedexport", 16) != 0){
    8000228c:	4641                	li	a2,16
    8000228e:	00006597          	auipc	a1,0x6
    80002292:	f3a58593          	addi	a1,a1,-198 # 800081c8 <etext+0x1c8>
    80002296:	854e                	mv	a0,s3
    80002298:	bc5fe0ef          	jal	80000e5c <strncmp>
    8000229c:	10051d63          	bnez	a0,800023b6 <scheduler+0x21c>
        if (c->run_start_ticks) {
    800022a0:	13093703          	ld	a4,304(s2)
    800022a4:	cb19                	beqz	a4,800022ba <scheduler+0x120>
          c->active_ticks += ticks - c->run_start_ticks;
    800022a6:	000a6783          	lwu	a5,0(s4)
    800022aa:	12893683          	ld	a3,296(s2)
    800022ae:	97b6                	add	a5,a5,a3
    800022b0:	8f99                	sub	a5,a5,a4
    800022b2:	12f93423          	sd	a5,296(s2)
          c->run_start_ticks = 0;
    800022b6:	12093823          	sd	zero,304(s2)
        c->last_pid = p->pid;
    800022ba:	58dc                	lw	a5,52(s1)
    800022bc:	10f92e23          	sw	a5,284(s2)
        c->last_state = p->state;
    800022c0:	4c9c                	lw	a5,24(s1)
    800022c2:	12f92023          	sw	a5,288(s2)
        c->current_pid = 0;
    800022c6:	10092a23          	sw	zero,276(s2)
        c->current_state = UNUSED;
    800022ca:	10092c23          	sw	zero,280(s2)
        c->proc = 0;
    800022ce:	08093823          	sd	zero,144(s2)
        found = 1;
    800022d2:	4985                	li	s3,1
      release(&p->lock);
    800022d4:	8526                	mv	a0,s1
    800022d6:	a7ffe0ef          	jal	80000d54 <release>
    for (p = proc; p < &proc[NPROC]; p++) {
    800022da:	16848493          	addi	s1,s1,360
    800022de:	00014797          	auipc	a5,0x14
    800022e2:	77a78793          	addi	a5,a5,1914 # 80016a58 <tickslock>
    800022e6:	12f48b63          	beq	s1,a5,8000241c <scheduler+0x282>
      acquire(&p->lock);
    800022ea:	8526                	mv	a0,s1
    800022ec:	9d1fe0ef          	jal	80000cbc <acquire>
      if (p->state == RUNNABLE) {
    800022f0:	4c98                	lw	a4,24(s1)
    800022f2:	478d                	li	a5,3
    800022f4:	fef710e3          	bne	a4,a5,800022d4 <scheduler+0x13a>
        setprocstate(p, RUNNING);
    800022f8:	4591                	li	a1,4
    800022fa:	8526                	mv	a0,s1
    800022fc:	f86ff0ef          	jal	80001a82 <setprocstate>
        c->proc = p;
    80002300:	08993823          	sd	s1,144(s2)
        c->current_pid = p->pid;
    80002304:	58dc                	lw	a5,52(s1)
    80002306:	10f92a23          	sw	a5,276(s2)
        c->current_state = RUNNING;
    8000230a:	4791                	li	a5,4
    8000230c:	10f92c23          	sw	a5,280(s2)
        c->run_start_ticks = ticks;
    80002310:	000a6783          	lwu	a5,0(s4)
    80002314:	12f93823          	sd	a5,304(s2)
        cslog_run_start(p);
    80002318:	8526                	mv	a0,s1
    8000231a:	066040ef          	jal	80006380 <cslog_run_start>
    8000231e:	8792                	mv	a5,tp
        if (cpuid() == 0 && sched_info_logged == 0) {
    80002320:	2781                	sext.w	a5,a5
    80002322:	f3b9                	bnez	a5,80002268 <scheduler+0xce>
    80002324:	000b2783          	lw	a5,0(s6)
    80002328:	2781                	sext.w	a5,a5
    8000232a:	ff9d                	bnez	a5,80002268 <scheduler+0xce>
          sched_info_logged = 1;
    8000232c:	4985                	li	s3,1
    8000232e:	013b2023          	sw	s3,0(s6)
          memset(&e, 0, sizeof(e));
    80002332:	04400613          	li	a2,68
    80002336:	4581                	li	a1,0
    80002338:	f6840513          	addi	a0,s0,-152
    8000233c:	a55fe0ef          	jal	80000d90 <memset>
          e.ticks = ticks;
    80002340:	000a2783          	lw	a5,0(s4)
    80002344:	f6f42623          	sw	a5,-148(s0)
          e.event_type = SCHED_EV_INFO;
    80002348:	f7342823          	sw	s3,-144(s0)
          safestrcpy(e.scheduler_name, "RR", sizeof(e.scheduler_name));
    8000234c:	4641                	li	a2,16
    8000234e:	00006597          	auipc	a1,0x6
    80002352:	e7258593          	addi	a1,a1,-398 # 800081c0 <etext+0x1c0>
    80002356:	f7440513          	addi	a0,s0,-140
    8000235a:	b75fe0ef          	jal	80000ece <safestrcpy>
          e.num_cpus = NCPU;
    8000235e:	47a1                	li	a5,8
    80002360:	f8f42223          	sw	a5,-124(s0)
          e.time_slice = 1;
    80002364:	f9342423          	sw	s3,-120(s0)
          schedlog_emit(&e);
    80002368:	f6840513          	addi	a0,s0,-152
    8000236c:	6fc040ef          	jal	80006a68 <schedlog_emit>
    80002370:	bde5                	j	80002268 <scheduler+0xce>
          memset(&e, 0, sizeof(e));
    80002372:	04400613          	li	a2,68
    80002376:	4581                	li	a1,0
    80002378:	f6840513          	addi	a0,s0,-152
    8000237c:	a15fe0ef          	jal	80000d90 <memset>
          e.ticks = ticks;
    80002380:	000a2783          	lw	a5,0(s4)
    80002384:	f6f42623          	sw	a5,-148(s0)
          e.event_type = SCHED_EV_ON_CPU;
    80002388:	4789                	li	a5,2
    8000238a:	f6f42823          	sw	a5,-144(s0)
    8000238e:	8792                	mv	a5,tp
  int id = r_tp();
    80002390:	f8f42623          	sw	a5,-116(s0)
          e.pid = p->pid;
    80002394:	58dc                	lw	a5,52(s1)
    80002396:	f8f42823          	sw	a5,-112(s0)
          safestrcpy(e.name, p->name, sizeof(e.name));
    8000239a:	4641                	li	a2,16
    8000239c:	85ce                	mv	a1,s3
    8000239e:	f9440513          	addi	a0,s0,-108
    800023a2:	b2dfe0ef          	jal	80000ece <safestrcpy>
          e.state = p->state;
    800023a6:	4c9c                	lw	a5,24(s1)
    800023a8:	faf42223          	sw	a5,-92(s0)
          schedlog_emit(&e);
    800023ac:	f6840513          	addi	a0,s0,-152
    800023b0:	6b8040ef          	jal	80006a68 <schedlog_emit>
    800023b4:	b5f9                	j	80002282 <scheduler+0xe8>
          memset(&e2, 0, sizeof(e2));
    800023b6:	04400613          	li	a2,68
    800023ba:	4581                	li	a1,0
    800023bc:	f6840513          	addi	a0,s0,-152
    800023c0:	9d1fe0ef          	jal	80000d90 <memset>
          e2.ticks = ticks;
    800023c4:	000a2783          	lw	a5,0(s4)
    800023c8:	f6f42623          	sw	a5,-148(s0)
          e2.event_type = SCHED_EV_OFF_CPU;
    800023cc:	478d                	li	a5,3
    800023ce:	f6f42823          	sw	a5,-144(s0)
    800023d2:	8792                	mv	a5,tp
  int id = r_tp();
    800023d4:	f8f42623          	sw	a5,-116(s0)
          e2.pid = p->pid;
    800023d8:	58dc                	lw	a5,52(s1)
    800023da:	f8f42823          	sw	a5,-112(s0)
          safestrcpy(e2.name, p->name, sizeof(e2.name));
    800023de:	4641                	li	a2,16
    800023e0:	85ce                	mv	a1,s3
    800023e2:	f9440513          	addi	a0,s0,-108
    800023e6:	ae9fe0ef          	jal	80000ece <safestrcpy>
          e2.state = p->state;
    800023ea:	4c9c                	lw	a5,24(s1)
    800023ec:	0007869b          	sext.w	a3,a5
          if(p->state == SLEEPING)
    800023f0:	4609                	li	a2,2
    800023f2:	4709                	li	a4,2
    800023f4:	00c78b63          	beq	a5,a2,8000240a <scheduler+0x270>
          else if(p->state == ZOMBIE)
    800023f8:	4615                	li	a2,5
    800023fa:	4711                	li	a4,4
    800023fc:	00c78763          	beq	a5,a2,8000240a <scheduler+0x270>
          else if(p->state == RUNNABLE)
    80002400:	460d                	li	a2,3
    80002402:	470d                	li	a4,3
    80002404:	00c78363          	beq	a5,a2,8000240a <scheduler+0x270>
    80002408:	4701                	li	a4,0
          e2.state = p->state;
    8000240a:	fad42223          	sw	a3,-92(s0)
            e2.reason = SCHED_OFF_SLEEP;
    8000240e:	fae42423          	sw	a4,-88(s0)
          schedlog_emit(&e2);
    80002412:	f6840513          	addi	a0,s0,-152
    80002416:	652040ef          	jal	80006a68 <schedlog_emit>
    8000241a:	b559                	j	800022a0 <scheduler+0x106>
    if (found == 0) {
    8000241c:	00099463          	bnez	s3,80002424 <scheduler+0x28a>
      asm volatile("wfi");
    80002420:	10500073          	wfi
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002424:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002428:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000242c:	10079073          	csrw	sstatus,a5
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002430:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80002434:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002436:	10079073          	csrw	sstatus,a5
    int found = 0;
    8000243a:	4981                	li	s3,0
    for (p = proc; p < &proc[NPROC]; p++) {
    8000243c:	0000f497          	auipc	s1,0xf
    80002440:	c1c48493          	addi	s1,s1,-996 # 80011058 <proc>
        if (cpuid() == 0 && sched_info_logged == 0) {
    80002444:	00006b17          	auipc	s6,0x6
    80002448:	4dcb0b13          	addi	s6,s6,1244 # 80008920 <sched_info_logged>
    8000244c:	bd79                	j	800022ea <scheduler+0x150>

000000008000244e <sched>:
void sched(void) {
    8000244e:	7179                	addi	sp,sp,-48
    80002450:	f406                	sd	ra,40(sp)
    80002452:	f022                	sd	s0,32(sp)
    80002454:	ec26                	sd	s1,24(sp)
    80002456:	e84a                	sd	s2,16(sp)
    80002458:	e44e                	sd	s3,8(sp)
    8000245a:	e052                	sd	s4,0(sp)
    8000245c:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    8000245e:	829ff0ef          	jal	80001c86 <myproc>
    80002462:	84aa                	mv	s1,a0
  if (!holding(&p->lock))
    80002464:	feefe0ef          	jal	80000c52 <holding>
    80002468:	c151                	beqz	a0,800024ec <sched+0x9e>
  asm volatile("mv %0, tp" : "=r" (x) );
    8000246a:	8792                	mv	a5,tp
  if (mycpu()->noff != 1)
    8000246c:	2781                	sext.w	a5,a5
    8000246e:	0a800713          	li	a4,168
    80002472:	02e787b3          	mul	a5,a5,a4
    80002476:	0000e717          	auipc	a4,0xe
    8000247a:	61270713          	addi	a4,a4,1554 # 80010a88 <procstat_lock>
    8000247e:	97ba                	add	a5,a5,a4
    80002480:	1087a703          	lw	a4,264(a5)
    80002484:	4785                	li	a5,1
    80002486:	06f71963          	bne	a4,a5,800024f8 <sched+0xaa>
  if (p->state == RUNNING)
    8000248a:	4c98                	lw	a4,24(s1)
    8000248c:	4791                	li	a5,4
    8000248e:	06f70b63          	beq	a4,a5,80002504 <sched+0xb6>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002492:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002496:	8b89                	andi	a5,a5,2
  if (intr_get())
    80002498:	efa5                	bnez	a5,80002510 <sched+0xc2>
  asm volatile("mv %0, tp" : "=r" (x) );
    8000249a:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    8000249c:	0000e917          	auipc	s2,0xe
    800024a0:	5ec90913          	addi	s2,s2,1516 # 80010a88 <procstat_lock>
    800024a4:	2781                	sext.w	a5,a5
    800024a6:	0a800993          	li	s3,168
    800024aa:	033787b3          	mul	a5,a5,s3
    800024ae:	97ca                	add	a5,a5,s2
    800024b0:	10c7aa03          	lw	s4,268(a5)
    800024b4:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    800024b6:	2781                	sext.w	a5,a5
    800024b8:	033787b3          	mul	a5,a5,s3
    800024bc:	0000e597          	auipc	a1,0xe
    800024c0:	66458593          	addi	a1,a1,1636 # 80010b20 <cpus+0x8>
    800024c4:	95be                	add	a1,a1,a5
    800024c6:	06048513          	addi	a0,s1,96
    800024ca:	53c000ef          	jal	80002a06 <swtch>
    800024ce:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    800024d0:	2781                	sext.w	a5,a5
    800024d2:	033787b3          	mul	a5,a5,s3
    800024d6:	993e                	add	s2,s2,a5
    800024d8:	11492623          	sw	s4,268(s2)
}
    800024dc:	70a2                	ld	ra,40(sp)
    800024de:	7402                	ld	s0,32(sp)
    800024e0:	64e2                	ld	s1,24(sp)
    800024e2:	6942                	ld	s2,16(sp)
    800024e4:	69a2                	ld	s3,8(sp)
    800024e6:	6a02                	ld	s4,0(sp)
    800024e8:	6145                	addi	sp,sp,48
    800024ea:	8082                	ret
    panic("sched p->lock");
    800024ec:	00006517          	auipc	a0,0x6
    800024f0:	cec50513          	addi	a0,a0,-788 # 800081d8 <etext+0x1d8>
    800024f4:	b1efe0ef          	jal	80000812 <panic>
    panic("sched locks");
    800024f8:	00006517          	auipc	a0,0x6
    800024fc:	cf050513          	addi	a0,a0,-784 # 800081e8 <etext+0x1e8>
    80002500:	b12fe0ef          	jal	80000812 <panic>
    panic("sched RUNNING");
    80002504:	00006517          	auipc	a0,0x6
    80002508:	cf450513          	addi	a0,a0,-780 # 800081f8 <etext+0x1f8>
    8000250c:	b06fe0ef          	jal	80000812 <panic>
    panic("sched interruptible");
    80002510:	00006517          	auipc	a0,0x6
    80002514:	cf850513          	addi	a0,a0,-776 # 80008208 <etext+0x208>
    80002518:	afafe0ef          	jal	80000812 <panic>

000000008000251c <yield>:
void yield(void) {
    8000251c:	1101                	addi	sp,sp,-32
    8000251e:	ec06                	sd	ra,24(sp)
    80002520:	e822                	sd	s0,16(sp)
    80002522:	e426                	sd	s1,8(sp)
    80002524:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80002526:	f60ff0ef          	jal	80001c86 <myproc>
    8000252a:	84aa                	mv	s1,a0
  acquire(&p->lock);
    8000252c:	f90fe0ef          	jal	80000cbc <acquire>
  setprocstate(p, RUNNABLE);
    80002530:	458d                	li	a1,3
    80002532:	8526                	mv	a0,s1
    80002534:	d4eff0ef          	jal	80001a82 <setprocstate>
  sched();
    80002538:	f17ff0ef          	jal	8000244e <sched>
  release(&p->lock);
    8000253c:	8526                	mv	a0,s1
    8000253e:	817fe0ef          	jal	80000d54 <release>
}
    80002542:	60e2                	ld	ra,24(sp)
    80002544:	6442                	ld	s0,16(sp)
    80002546:	64a2                	ld	s1,8(sp)
    80002548:	6105                	addi	sp,sp,32
    8000254a:	8082                	ret

000000008000254c <sleep>:

// Sleep on channel chan, releasing condition lock lk.
// Re-acquires lk when awakened.
void sleep(void *chan, struct spinlock *lk) {
    8000254c:	7179                	addi	sp,sp,-48
    8000254e:	f406                	sd	ra,40(sp)
    80002550:	f022                	sd	s0,32(sp)
    80002552:	ec26                	sd	s1,24(sp)
    80002554:	e84a                	sd	s2,16(sp)
    80002556:	e44e                	sd	s3,8(sp)
    80002558:	1800                	addi	s0,sp,48
    8000255a:	89aa                	mv	s3,a0
    8000255c:	892e                	mv	s2,a1
  struct proc *p = myproc();
    8000255e:	f28ff0ef          	jal	80001c86 <myproc>
    80002562:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock); // DOC: sleeplock1
    80002564:	f58fe0ef          	jal	80000cbc <acquire>
  release(lk);
    80002568:	854a                	mv	a0,s2
    8000256a:	feafe0ef          	jal	80000d54 <release>

  // Go to sleep.
  p->chan = chan;
    8000256e:	0334b023          	sd	s3,32(s1)
  setprocstate(p, SLEEPING);
    80002572:	4589                	li	a1,2
    80002574:	8526                	mv	a0,s1
    80002576:	d0cff0ef          	jal	80001a82 <setprocstate>

  sched();
    8000257a:	ed5ff0ef          	jal	8000244e <sched>

  // Tidy up.
  p->chan = 0;
    8000257e:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    80002582:	8526                	mv	a0,s1
    80002584:	fd0fe0ef          	jal	80000d54 <release>
  acquire(lk);
    80002588:	854a                	mv	a0,s2
    8000258a:	f32fe0ef          	jal	80000cbc <acquire>
}
    8000258e:	70a2                	ld	ra,40(sp)
    80002590:	7402                	ld	s0,32(sp)
    80002592:	64e2                	ld	s1,24(sp)
    80002594:	6942                	ld	s2,16(sp)
    80002596:	69a2                	ld	s3,8(sp)
    80002598:	6145                	addi	sp,sp,48
    8000259a:	8082                	ret

000000008000259c <wakeup>:

// Wake up all processes sleeping on channel chan.
// Caller should hold the condition lock.
void wakeup(void *chan) {
    8000259c:	7179                	addi	sp,sp,-48
    8000259e:	f406                	sd	ra,40(sp)
    800025a0:	f022                	sd	s0,32(sp)
    800025a2:	ec26                	sd	s1,24(sp)
    800025a4:	e84a                	sd	s2,16(sp)
    800025a6:	e44e                	sd	s3,8(sp)
    800025a8:	e052                	sd	s4,0(sp)
    800025aa:	1800                	addi	s0,sp,48
    800025ac:	8a2a                	mv	s4,a0
  struct proc *p;

  for (p = proc; p < &proc[NPROC]; p++) {
    800025ae:	0000f497          	auipc	s1,0xf
    800025b2:	aaa48493          	addi	s1,s1,-1366 # 80011058 <proc>
    if (p != myproc()) {
      acquire(&p->lock);
      if (p->state == SLEEPING && p->chan == chan) {
    800025b6:	4989                	li	s3,2
  for (p = proc; p < &proc[NPROC]; p++) {
    800025b8:	00014917          	auipc	s2,0x14
    800025bc:	4a090913          	addi	s2,s2,1184 # 80016a58 <tickslock>
    800025c0:	a801                	j	800025d0 <wakeup+0x34>
        setprocstate(p, RUNNABLE);
      }
      release(&p->lock);
    800025c2:	8526                	mv	a0,s1
    800025c4:	f90fe0ef          	jal	80000d54 <release>
  for (p = proc; p < &proc[NPROC]; p++) {
    800025c8:	16848493          	addi	s1,s1,360
    800025cc:	03248463          	beq	s1,s2,800025f4 <wakeup+0x58>
    if (p != myproc()) {
    800025d0:	eb6ff0ef          	jal	80001c86 <myproc>
    800025d4:	fea48ae3          	beq	s1,a0,800025c8 <wakeup+0x2c>
      acquire(&p->lock);
    800025d8:	8526                	mv	a0,s1
    800025da:	ee2fe0ef          	jal	80000cbc <acquire>
      if (p->state == SLEEPING && p->chan == chan) {
    800025de:	4c9c                	lw	a5,24(s1)
    800025e0:	ff3791e3          	bne	a5,s3,800025c2 <wakeup+0x26>
    800025e4:	709c                	ld	a5,32(s1)
    800025e6:	fd479ee3          	bne	a5,s4,800025c2 <wakeup+0x26>
        setprocstate(p, RUNNABLE);
    800025ea:	458d                	li	a1,3
    800025ec:	8526                	mv	a0,s1
    800025ee:	c94ff0ef          	jal	80001a82 <setprocstate>
    800025f2:	bfc1                	j	800025c2 <wakeup+0x26>
    }
  }
}
    800025f4:	70a2                	ld	ra,40(sp)
    800025f6:	7402                	ld	s0,32(sp)
    800025f8:	64e2                	ld	s1,24(sp)
    800025fa:	6942                	ld	s2,16(sp)
    800025fc:	69a2                	ld	s3,8(sp)
    800025fe:	6a02                	ld	s4,0(sp)
    80002600:	6145                	addi	sp,sp,48
    80002602:	8082                	ret

0000000080002604 <reparent>:
void reparent(struct proc *p) {
    80002604:	7179                	addi	sp,sp,-48
    80002606:	f406                	sd	ra,40(sp)
    80002608:	f022                	sd	s0,32(sp)
    8000260a:	ec26                	sd	s1,24(sp)
    8000260c:	e84a                	sd	s2,16(sp)
    8000260e:	e44e                	sd	s3,8(sp)
    80002610:	e052                	sd	s4,0(sp)
    80002612:	1800                	addi	s0,sp,48
    80002614:	892a                	mv	s2,a0
  for (pp = proc; pp < &proc[NPROC]; pp++) {
    80002616:	0000f497          	auipc	s1,0xf
    8000261a:	a4248493          	addi	s1,s1,-1470 # 80011058 <proc>
      pp->parent = initproc;
    8000261e:	00006a17          	auipc	s4,0x6
    80002622:	30aa0a13          	addi	s4,s4,778 # 80008928 <initproc>
  for (pp = proc; pp < &proc[NPROC]; pp++) {
    80002626:	00014997          	auipc	s3,0x14
    8000262a:	43298993          	addi	s3,s3,1074 # 80016a58 <tickslock>
    8000262e:	a029                	j	80002638 <reparent+0x34>
    80002630:	16848493          	addi	s1,s1,360
    80002634:	01348b63          	beq	s1,s3,8000264a <reparent+0x46>
    if (pp->parent == p) {
    80002638:	7c9c                	ld	a5,56(s1)
    8000263a:	ff279be3          	bne	a5,s2,80002630 <reparent+0x2c>
      pp->parent = initproc;
    8000263e:	000a3503          	ld	a0,0(s4)
    80002642:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    80002644:	f59ff0ef          	jal	8000259c <wakeup>
    80002648:	b7e5                	j	80002630 <reparent+0x2c>
}
    8000264a:	70a2                	ld	ra,40(sp)
    8000264c:	7402                	ld	s0,32(sp)
    8000264e:	64e2                	ld	s1,24(sp)
    80002650:	6942                	ld	s2,16(sp)
    80002652:	69a2                	ld	s3,8(sp)
    80002654:	6a02                	ld	s4,0(sp)
    80002656:	6145                	addi	sp,sp,48
    80002658:	8082                	ret

000000008000265a <kexit>:
void kexit(int status) {
    8000265a:	7179                	addi	sp,sp,-48
    8000265c:	f406                	sd	ra,40(sp)
    8000265e:	f022                	sd	s0,32(sp)
    80002660:	ec26                	sd	s1,24(sp)
    80002662:	e84a                	sd	s2,16(sp)
    80002664:	e44e                	sd	s3,8(sp)
    80002666:	e052                	sd	s4,0(sp)
    80002668:	1800                	addi	s0,sp,48
    8000266a:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    8000266c:	e1aff0ef          	jal	80001c86 <myproc>
    80002670:	89aa                	mv	s3,a0
  if (p == initproc)
    80002672:	00006797          	auipc	a5,0x6
    80002676:	2b67b783          	ld	a5,694(a5) # 80008928 <initproc>
    8000267a:	0d050493          	addi	s1,a0,208
    8000267e:	15050913          	addi	s2,a0,336
    80002682:	00a79f63          	bne	a5,a0,800026a0 <kexit+0x46>
    panic("init exiting");
    80002686:	00006517          	auipc	a0,0x6
    8000268a:	b9a50513          	addi	a0,a0,-1126 # 80008220 <etext+0x220>
    8000268e:	984fe0ef          	jal	80000812 <panic>
      fileclose(f);
    80002692:	29a020ef          	jal	8000492c <fileclose>
      p->ofile[fd] = 0;
    80002696:	0004b023          	sd	zero,0(s1)
  for (int fd = 0; fd < NOFILE; fd++) {
    8000269a:	04a1                	addi	s1,s1,8
    8000269c:	01248563          	beq	s1,s2,800026a6 <kexit+0x4c>
    if (p->ofile[fd]) {
    800026a0:	6088                	ld	a0,0(s1)
    800026a2:	f965                	bnez	a0,80002692 <kexit+0x38>
    800026a4:	bfdd                	j	8000269a <kexit+0x40>
  begin_op();
    800026a6:	67b010ef          	jal	80004520 <begin_op>
  iput(p->cwd);
    800026aa:	1509b503          	ld	a0,336(s3)
    800026ae:	60a010ef          	jal	80003cb8 <iput>
  end_op();
    800026b2:	6d9010ef          	jal	8000458a <end_op>
  p->cwd = 0;
    800026b6:	1409b823          	sd	zero,336(s3)
  acquire(&wait_lock);
    800026ba:	0000e917          	auipc	s2,0xe
    800026be:	3ce90913          	addi	s2,s2,974 # 80010a88 <procstat_lock>
    800026c2:	0000e497          	auipc	s1,0xe
    800026c6:	42648493          	addi	s1,s1,1062 # 80010ae8 <wait_lock>
    800026ca:	8526                	mv	a0,s1
    800026cc:	df0fe0ef          	jal	80000cbc <acquire>
  reparent(p);
    800026d0:	854e                	mv	a0,s3
    800026d2:	f33ff0ef          	jal	80002604 <reparent>
  wakeup(p->parent);
    800026d6:	0389b503          	ld	a0,56(s3)
    800026da:	ec3ff0ef          	jal	8000259c <wakeup>
  acquire(&p->lock);
    800026de:	854e                	mv	a0,s3
    800026e0:	ddcfe0ef          	jal	80000cbc <acquire>
  p->xstate = status;
    800026e4:	0349a823          	sw	s4,48(s3)
  setprocstate(p, ZOMBIE);
    800026e8:	4595                	li	a1,5
    800026ea:	854e                	mv	a0,s3
    800026ec:	b96ff0ef          	jal	80001a82 <setprocstate>
  acquire(&procstat_lock);
    800026f0:	854a                	mv	a0,s2
    800026f2:	dcafe0ef          	jal	80000cbc <acquire>
  proc_total_exited++;
    800026f6:	00006717          	auipc	a4,0x6
    800026fa:	21a70713          	addi	a4,a4,538 # 80008910 <proc_total_exited>
    800026fe:	631c                	ld	a5,0(a4)
    80002700:	0785                	addi	a5,a5,1
    80002702:	e31c                	sd	a5,0(a4)
  release(&procstat_lock);
    80002704:	854a                	mv	a0,s2
    80002706:	e4efe0ef          	jal	80000d54 <release>
  release(&wait_lock);
    8000270a:	8526                	mv	a0,s1
    8000270c:	e48fe0ef          	jal	80000d54 <release>
  sched();
    80002710:	d3fff0ef          	jal	8000244e <sched>
  panic("zombie exit");
    80002714:	00006517          	auipc	a0,0x6
    80002718:	b1c50513          	addi	a0,a0,-1252 # 80008230 <etext+0x230>
    8000271c:	8f6fe0ef          	jal	80000812 <panic>

0000000080002720 <kkill>:

// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int kkill(int pid) {
    80002720:	7179                	addi	sp,sp,-48
    80002722:	f406                	sd	ra,40(sp)
    80002724:	f022                	sd	s0,32(sp)
    80002726:	ec26                	sd	s1,24(sp)
    80002728:	e84a                	sd	s2,16(sp)
    8000272a:	e44e                	sd	s3,8(sp)
    8000272c:	1800                	addi	s0,sp,48
    8000272e:	892a                	mv	s2,a0
  struct proc *p;

  for (p = proc; p < &proc[NPROC]; p++) {
    80002730:	0000f497          	auipc	s1,0xf
    80002734:	92848493          	addi	s1,s1,-1752 # 80011058 <proc>
    80002738:	00014997          	auipc	s3,0x14
    8000273c:	32098993          	addi	s3,s3,800 # 80016a58 <tickslock>
    acquire(&p->lock);
    80002740:	8526                	mv	a0,s1
    80002742:	d7afe0ef          	jal	80000cbc <acquire>
    if (p->pid == pid) {
    80002746:	58dc                	lw	a5,52(s1)
    80002748:	01278b63          	beq	a5,s2,8000275e <kkill+0x3e>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    8000274c:	8526                	mv	a0,s1
    8000274e:	e06fe0ef          	jal	80000d54 <release>
  for (p = proc; p < &proc[NPROC]; p++) {
    80002752:	16848493          	addi	s1,s1,360
    80002756:	ff3495e3          	bne	s1,s3,80002740 <kkill+0x20>
  }
  return -1;
    8000275a:	557d                	li	a0,-1
    8000275c:	a819                	j	80002772 <kkill+0x52>
      p->killed = 1;
    8000275e:	4785                	li	a5,1
    80002760:	d49c                	sw	a5,40(s1)
      if (p->state == SLEEPING) {
    80002762:	4c98                	lw	a4,24(s1)
    80002764:	4789                	li	a5,2
    80002766:	00f70d63          	beq	a4,a5,80002780 <kkill+0x60>
      release(&p->lock);
    8000276a:	8526                	mv	a0,s1
    8000276c:	de8fe0ef          	jal	80000d54 <release>
      return 0;
    80002770:	4501                	li	a0,0
}
    80002772:	70a2                	ld	ra,40(sp)
    80002774:	7402                	ld	s0,32(sp)
    80002776:	64e2                	ld	s1,24(sp)
    80002778:	6942                	ld	s2,16(sp)
    8000277a:	69a2                	ld	s3,8(sp)
    8000277c:	6145                	addi	sp,sp,48
    8000277e:	8082                	ret
        p->state = RUNNABLE;
    80002780:	478d                	li	a5,3
    80002782:	cc9c                	sw	a5,24(s1)
    80002784:	b7dd                	j	8000276a <kkill+0x4a>

0000000080002786 <setkilled>:

void setkilled(struct proc *p) {
    80002786:	1101                	addi	sp,sp,-32
    80002788:	ec06                	sd	ra,24(sp)
    8000278a:	e822                	sd	s0,16(sp)
    8000278c:	e426                	sd	s1,8(sp)
    8000278e:	1000                	addi	s0,sp,32
    80002790:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80002792:	d2afe0ef          	jal	80000cbc <acquire>
  p->killed = 1;
    80002796:	4785                	li	a5,1
    80002798:	d49c                	sw	a5,40(s1)
  release(&p->lock);
    8000279a:	8526                	mv	a0,s1
    8000279c:	db8fe0ef          	jal	80000d54 <release>
}
    800027a0:	60e2                	ld	ra,24(sp)
    800027a2:	6442                	ld	s0,16(sp)
    800027a4:	64a2                	ld	s1,8(sp)
    800027a6:	6105                	addi	sp,sp,32
    800027a8:	8082                	ret

00000000800027aa <killed>:

int killed(struct proc *p) {
    800027aa:	1101                	addi	sp,sp,-32
    800027ac:	ec06                	sd	ra,24(sp)
    800027ae:	e822                	sd	s0,16(sp)
    800027b0:	e426                	sd	s1,8(sp)
    800027b2:	e04a                	sd	s2,0(sp)
    800027b4:	1000                	addi	s0,sp,32
    800027b6:	84aa                	mv	s1,a0
  int k;

  acquire(&p->lock);
    800027b8:	d04fe0ef          	jal	80000cbc <acquire>
  k = p->killed;
    800027bc:	0284a903          	lw	s2,40(s1)
  release(&p->lock);
    800027c0:	8526                	mv	a0,s1
    800027c2:	d92fe0ef          	jal	80000d54 <release>
  return k;
}
    800027c6:	854a                	mv	a0,s2
    800027c8:	60e2                	ld	ra,24(sp)
    800027ca:	6442                	ld	s0,16(sp)
    800027cc:	64a2                	ld	s1,8(sp)
    800027ce:	6902                	ld	s2,0(sp)
    800027d0:	6105                	addi	sp,sp,32
    800027d2:	8082                	ret

00000000800027d4 <kwait>:
int kwait(uint64 addr) {
    800027d4:	715d                	addi	sp,sp,-80
    800027d6:	e486                	sd	ra,72(sp)
    800027d8:	e0a2                	sd	s0,64(sp)
    800027da:	fc26                	sd	s1,56(sp)
    800027dc:	f84a                	sd	s2,48(sp)
    800027de:	f44e                	sd	s3,40(sp)
    800027e0:	f052                	sd	s4,32(sp)
    800027e2:	ec56                	sd	s5,24(sp)
    800027e4:	e85a                	sd	s6,16(sp)
    800027e6:	e45e                	sd	s7,8(sp)
    800027e8:	e062                	sd	s8,0(sp)
    800027ea:	0880                	addi	s0,sp,80
    800027ec:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    800027ee:	c98ff0ef          	jal	80001c86 <myproc>
    800027f2:	892a                	mv	s2,a0
  acquire(&wait_lock);
    800027f4:	0000e517          	auipc	a0,0xe
    800027f8:	2f450513          	addi	a0,a0,756 # 80010ae8 <wait_lock>
    800027fc:	cc0fe0ef          	jal	80000cbc <acquire>
    havekids = 0;
    80002800:	4b81                	li	s7,0
        if (pp->state == ZOMBIE) {
    80002802:	4a15                	li	s4,5
        havekids = 1;
    80002804:	4a85                	li	s5,1
    for (pp = proc; pp < &proc[NPROC]; pp++) {
    80002806:	00014997          	auipc	s3,0x14
    8000280a:	25298993          	addi	s3,s3,594 # 80016a58 <tickslock>
    sleep(p, &wait_lock); // DOC: wait-sleep
    8000280e:	0000ec17          	auipc	s8,0xe
    80002812:	2dac0c13          	addi	s8,s8,730 # 80010ae8 <wait_lock>
    80002816:	a871                	j	800028b2 <kwait+0xde>
          pid = pp->pid;
    80002818:	0344a983          	lw	s3,52(s1)
          if (addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    8000281c:	000b0c63          	beqz	s6,80002834 <kwait+0x60>
    80002820:	4691                	li	a3,4
    80002822:	03048613          	addi	a2,s1,48
    80002826:	85da                	mv	a1,s6
    80002828:	05093503          	ld	a0,80(s2)
    8000282c:	8e4ff0ef          	jal	80001910 <copyout>
    80002830:	02054b63          	bltz	a0,80002866 <kwait+0x92>
          freeproc(pp);
    80002834:	8526                	mv	a0,s1
    80002836:	e26ff0ef          	jal	80001e5c <freeproc>
          release(&pp->lock);
    8000283a:	8526                	mv	a0,s1
    8000283c:	d18fe0ef          	jal	80000d54 <release>
          release(&wait_lock);
    80002840:	0000e517          	auipc	a0,0xe
    80002844:	2a850513          	addi	a0,a0,680 # 80010ae8 <wait_lock>
    80002848:	d0cfe0ef          	jal	80000d54 <release>
}
    8000284c:	854e                	mv	a0,s3
    8000284e:	60a6                	ld	ra,72(sp)
    80002850:	6406                	ld	s0,64(sp)
    80002852:	74e2                	ld	s1,56(sp)
    80002854:	7942                	ld	s2,48(sp)
    80002856:	79a2                	ld	s3,40(sp)
    80002858:	7a02                	ld	s4,32(sp)
    8000285a:	6ae2                	ld	s5,24(sp)
    8000285c:	6b42                	ld	s6,16(sp)
    8000285e:	6ba2                	ld	s7,8(sp)
    80002860:	6c02                	ld	s8,0(sp)
    80002862:	6161                	addi	sp,sp,80
    80002864:	8082                	ret
            release(&pp->lock);
    80002866:	8526                	mv	a0,s1
    80002868:	cecfe0ef          	jal	80000d54 <release>
            release(&wait_lock);
    8000286c:	0000e517          	auipc	a0,0xe
    80002870:	27c50513          	addi	a0,a0,636 # 80010ae8 <wait_lock>
    80002874:	ce0fe0ef          	jal	80000d54 <release>
            return -1;
    80002878:	59fd                	li	s3,-1
    8000287a:	bfc9                	j	8000284c <kwait+0x78>
    for (pp = proc; pp < &proc[NPROC]; pp++) {
    8000287c:	16848493          	addi	s1,s1,360
    80002880:	03348063          	beq	s1,s3,800028a0 <kwait+0xcc>
      if (pp->parent == p) {
    80002884:	7c9c                	ld	a5,56(s1)
    80002886:	ff279be3          	bne	a5,s2,8000287c <kwait+0xa8>
        acquire(&pp->lock);
    8000288a:	8526                	mv	a0,s1
    8000288c:	c30fe0ef          	jal	80000cbc <acquire>
        if (pp->state == ZOMBIE) {
    80002890:	4c9c                	lw	a5,24(s1)
    80002892:	f94783e3          	beq	a5,s4,80002818 <kwait+0x44>
        release(&pp->lock);
    80002896:	8526                	mv	a0,s1
    80002898:	cbcfe0ef          	jal	80000d54 <release>
        havekids = 1;
    8000289c:	8756                	mv	a4,s5
    8000289e:	bff9                	j	8000287c <kwait+0xa8>
    if (!havekids || killed(p)) {
    800028a0:	cf19                	beqz	a4,800028be <kwait+0xea>
    800028a2:	854a                	mv	a0,s2
    800028a4:	f07ff0ef          	jal	800027aa <killed>
    800028a8:	e919                	bnez	a0,800028be <kwait+0xea>
    sleep(p, &wait_lock); // DOC: wait-sleep
    800028aa:	85e2                	mv	a1,s8
    800028ac:	854a                	mv	a0,s2
    800028ae:	c9fff0ef          	jal	8000254c <sleep>
    havekids = 0;
    800028b2:	875e                	mv	a4,s7
    for (pp = proc; pp < &proc[NPROC]; pp++) {
    800028b4:	0000e497          	auipc	s1,0xe
    800028b8:	7a448493          	addi	s1,s1,1956 # 80011058 <proc>
    800028bc:	b7e1                	j	80002884 <kwait+0xb0>
      release(&wait_lock);
    800028be:	0000e517          	auipc	a0,0xe
    800028c2:	22a50513          	addi	a0,a0,554 # 80010ae8 <wait_lock>
    800028c6:	c8efe0ef          	jal	80000d54 <release>
      return -1;
    800028ca:	59fd                	li	s3,-1
    800028cc:	b741                	j	8000284c <kwait+0x78>

00000000800028ce <either_copyout>:

// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int either_copyout(int user_dst, uint64 dst, void *src, uint64 len) {
    800028ce:	7179                	addi	sp,sp,-48
    800028d0:	f406                	sd	ra,40(sp)
    800028d2:	f022                	sd	s0,32(sp)
    800028d4:	ec26                	sd	s1,24(sp)
    800028d6:	e84a                	sd	s2,16(sp)
    800028d8:	e44e                	sd	s3,8(sp)
    800028da:	e052                	sd	s4,0(sp)
    800028dc:	1800                	addi	s0,sp,48
    800028de:	84aa                	mv	s1,a0
    800028e0:	892e                	mv	s2,a1
    800028e2:	89b2                	mv	s3,a2
    800028e4:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    800028e6:	ba0ff0ef          	jal	80001c86 <myproc>
  if (user_dst) {
    800028ea:	cc99                	beqz	s1,80002908 <either_copyout+0x3a>
    return copyout(p->pagetable, dst, src, len);
    800028ec:	86d2                	mv	a3,s4
    800028ee:	864e                	mv	a2,s3
    800028f0:	85ca                	mv	a1,s2
    800028f2:	6928                	ld	a0,80(a0)
    800028f4:	81cff0ef          	jal	80001910 <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    800028f8:	70a2                	ld	ra,40(sp)
    800028fa:	7402                	ld	s0,32(sp)
    800028fc:	64e2                	ld	s1,24(sp)
    800028fe:	6942                	ld	s2,16(sp)
    80002900:	69a2                	ld	s3,8(sp)
    80002902:	6a02                	ld	s4,0(sp)
    80002904:	6145                	addi	sp,sp,48
    80002906:	8082                	ret
    memmove((char *)dst, src, len);
    80002908:	000a061b          	sext.w	a2,s4
    8000290c:	85ce                	mv	a1,s3
    8000290e:	854a                	mv	a0,s2
    80002910:	cdcfe0ef          	jal	80000dec <memmove>
    return 0;
    80002914:	8526                	mv	a0,s1
    80002916:	b7cd                	j	800028f8 <either_copyout+0x2a>

0000000080002918 <either_copyin>:

// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int either_copyin(void *dst, int user_src, uint64 src, uint64 len) {
    80002918:	7179                	addi	sp,sp,-48
    8000291a:	f406                	sd	ra,40(sp)
    8000291c:	f022                	sd	s0,32(sp)
    8000291e:	ec26                	sd	s1,24(sp)
    80002920:	e84a                	sd	s2,16(sp)
    80002922:	e44e                	sd	s3,8(sp)
    80002924:	e052                	sd	s4,0(sp)
    80002926:	1800                	addi	s0,sp,48
    80002928:	892a                	mv	s2,a0
    8000292a:	84ae                	mv	s1,a1
    8000292c:	89b2                	mv	s3,a2
    8000292e:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002930:	b56ff0ef          	jal	80001c86 <myproc>
  if (user_src) {
    80002934:	cc99                	beqz	s1,80002952 <either_copyin+0x3a>
    return copyin(p->pagetable, dst, src, len);
    80002936:	86d2                	mv	a3,s4
    80002938:	864e                	mv	a2,s3
    8000293a:	85ca                	mv	a1,s2
    8000293c:	6928                	ld	a0,80(a0)
    8000293e:	8b6ff0ef          	jal	800019f4 <copyin>
  } else {
    memmove(dst, (char *)src, len);
    return 0;
  }
}
    80002942:	70a2                	ld	ra,40(sp)
    80002944:	7402                	ld	s0,32(sp)
    80002946:	64e2                	ld	s1,24(sp)
    80002948:	6942                	ld	s2,16(sp)
    8000294a:	69a2                	ld	s3,8(sp)
    8000294c:	6a02                	ld	s4,0(sp)
    8000294e:	6145                	addi	sp,sp,48
    80002950:	8082                	ret
    memmove(dst, (char *)src, len);
    80002952:	000a061b          	sext.w	a2,s4
    80002956:	85ce                	mv	a1,s3
    80002958:	854a                	mv	a0,s2
    8000295a:	c92fe0ef          	jal	80000dec <memmove>
    return 0;
    8000295e:	8526                	mv	a0,s1
    80002960:	b7cd                	j	80002942 <either_copyin+0x2a>

0000000080002962 <procdump>:

// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void procdump(void) {
    80002962:	715d                	addi	sp,sp,-80
    80002964:	e486                	sd	ra,72(sp)
    80002966:	e0a2                	sd	s0,64(sp)
    80002968:	fc26                	sd	s1,56(sp)
    8000296a:	f84a                	sd	s2,48(sp)
    8000296c:	f44e                	sd	s3,40(sp)
    8000296e:	f052                	sd	s4,32(sp)
    80002970:	ec56                	sd	s5,24(sp)
    80002972:	e85a                	sd	s6,16(sp)
    80002974:	e45e                	sd	s7,8(sp)
    80002976:	0880                	addi	s0,sp,80
      [UNUSED] "unused",   [USED] "used",      [SLEEPING] "sleep ",
      [RUNNABLE] "runble", [RUNNING] "run   ", [ZOMBIE] "zombie"};
  struct proc *p;
  char *state;

  printf("\n");
    80002978:	00005517          	auipc	a0,0x5
    8000297c:	70850513          	addi	a0,a0,1800 # 80008080 <etext+0x80>
    80002980:	badfd0ef          	jal	8000052c <printf>
  for (p = proc; p < &proc[NPROC]; p++) {
    80002984:	0000f497          	auipc	s1,0xf
    80002988:	82c48493          	addi	s1,s1,-2004 # 800111b0 <proc+0x158>
    8000298c:	00014917          	auipc	s2,0x14
    80002990:	22490913          	addi	s2,s2,548 # 80016bb0 <bcache+0x140>
    if (p->state == UNUSED)
      continue;
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002994:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    80002996:	00006997          	auipc	s3,0x6
    8000299a:	8aa98993          	addi	s3,s3,-1878 # 80008240 <etext+0x240>
    printf("%d %s %s", p->pid, state, p->name);
    8000299e:	00006a97          	auipc	s5,0x6
    800029a2:	8aaa8a93          	addi	s5,s5,-1878 # 80008248 <etext+0x248>
    printf("\n");
    800029a6:	00005a17          	auipc	s4,0x5
    800029aa:	6daa0a13          	addi	s4,s4,1754 # 80008080 <etext+0x80>
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800029ae:	00006b97          	auipc	s7,0x6
    800029b2:	e02b8b93          	addi	s7,s7,-510 # 800087b0 <states.0>
    800029b6:	a829                	j	800029d0 <procdump+0x6e>
    printf("%d %s %s", p->pid, state, p->name);
    800029b8:	edc6a583          	lw	a1,-292(a3)
    800029bc:	8556                	mv	a0,s5
    800029be:	b6ffd0ef          	jal	8000052c <printf>
    printf("\n");
    800029c2:	8552                	mv	a0,s4
    800029c4:	b69fd0ef          	jal	8000052c <printf>
  for (p = proc; p < &proc[NPROC]; p++) {
    800029c8:	16848493          	addi	s1,s1,360
    800029cc:	03248263          	beq	s1,s2,800029f0 <procdump+0x8e>
    if (p->state == UNUSED)
    800029d0:	86a6                	mv	a3,s1
    800029d2:	ec04a783          	lw	a5,-320(s1)
    800029d6:	dbed                	beqz	a5,800029c8 <procdump+0x66>
      state = "???";
    800029d8:	864e                	mv	a2,s3
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800029da:	fcfb6fe3          	bltu	s6,a5,800029b8 <procdump+0x56>
    800029de:	02079713          	slli	a4,a5,0x20
    800029e2:	01d75793          	srli	a5,a4,0x1d
    800029e6:	97de                	add	a5,a5,s7
    800029e8:	6390                	ld	a2,0(a5)
    800029ea:	f679                	bnez	a2,800029b8 <procdump+0x56>
      state = "???";
    800029ec:	864e                	mv	a2,s3
    800029ee:	b7e9                	j	800029b8 <procdump+0x56>
  }
}
    800029f0:	60a6                	ld	ra,72(sp)
    800029f2:	6406                	ld	s0,64(sp)
    800029f4:	74e2                	ld	s1,56(sp)
    800029f6:	7942                	ld	s2,48(sp)
    800029f8:	79a2                	ld	s3,40(sp)
    800029fa:	7a02                	ld	s4,32(sp)
    800029fc:	6ae2                	ld	s5,24(sp)
    800029fe:	6b42                	ld	s6,16(sp)
    80002a00:	6ba2                	ld	s7,8(sp)
    80002a02:	6161                	addi	sp,sp,80
    80002a04:	8082                	ret

0000000080002a06 <swtch>:
# Save current registers in old. Load from new.	


.globl swtch
swtch:
        sd ra, 0(a0)
    80002a06:	00153023          	sd	ra,0(a0)
        sd sp, 8(a0)
    80002a0a:	00253423          	sd	sp,8(a0)
        sd s0, 16(a0)
    80002a0e:	e900                	sd	s0,16(a0)
        sd s1, 24(a0)
    80002a10:	ed04                	sd	s1,24(a0)
        sd s2, 32(a0)
    80002a12:	03253023          	sd	s2,32(a0)
        sd s3, 40(a0)
    80002a16:	03353423          	sd	s3,40(a0)
        sd s4, 48(a0)
    80002a1a:	03453823          	sd	s4,48(a0)
        sd s5, 56(a0)
    80002a1e:	03553c23          	sd	s5,56(a0)
        sd s6, 64(a0)
    80002a22:	05653023          	sd	s6,64(a0)
        sd s7, 72(a0)
    80002a26:	05753423          	sd	s7,72(a0)
        sd s8, 80(a0)
    80002a2a:	05853823          	sd	s8,80(a0)
        sd s9, 88(a0)
    80002a2e:	05953c23          	sd	s9,88(a0)
        sd s10, 96(a0)
    80002a32:	07a53023          	sd	s10,96(a0)
        sd s11, 104(a0)
    80002a36:	07b53423          	sd	s11,104(a0)

        ld ra, 0(a1)
    80002a3a:	0005b083          	ld	ra,0(a1)
        ld sp, 8(a1)
    80002a3e:	0085b103          	ld	sp,8(a1)
        ld s0, 16(a1)
    80002a42:	6980                	ld	s0,16(a1)
        ld s1, 24(a1)
    80002a44:	6d84                	ld	s1,24(a1)
        ld s2, 32(a1)
    80002a46:	0205b903          	ld	s2,32(a1)
        ld s3, 40(a1)
    80002a4a:	0285b983          	ld	s3,40(a1)
        ld s4, 48(a1)
    80002a4e:	0305ba03          	ld	s4,48(a1)
        ld s5, 56(a1)
    80002a52:	0385ba83          	ld	s5,56(a1)
        ld s6, 64(a1)
    80002a56:	0405bb03          	ld	s6,64(a1)
        ld s7, 72(a1)
    80002a5a:	0485bb83          	ld	s7,72(a1)
        ld s8, 80(a1)
    80002a5e:	0505bc03          	ld	s8,80(a1)
        ld s9, 88(a1)
    80002a62:	0585bc83          	ld	s9,88(a1)
        ld s10, 96(a1)
    80002a66:	0605bd03          	ld	s10,96(a1)
        ld s11, 104(a1)
    80002a6a:	0685bd83          	ld	s11,104(a1)
        
        ret
    80002a6e:	8082                	ret

0000000080002a70 <trapinit>:

extern int devintr();

void
trapinit(void)
{
    80002a70:	1141                	addi	sp,sp,-16
    80002a72:	e406                	sd	ra,8(sp)
    80002a74:	e022                	sd	s0,0(sp)
    80002a76:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    80002a78:	00006597          	auipc	a1,0x6
    80002a7c:	81058593          	addi	a1,a1,-2032 # 80008288 <etext+0x288>
    80002a80:	00014517          	auipc	a0,0x14
    80002a84:	fd850513          	addi	a0,a0,-40 # 80016a58 <tickslock>
    80002a88:	9b4fe0ef          	jal	80000c3c <initlock>
}
    80002a8c:	60a2                	ld	ra,8(sp)
    80002a8e:	6402                	ld	s0,0(sp)
    80002a90:	0141                	addi	sp,sp,16
    80002a92:	8082                	ret

0000000080002a94 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    80002a94:	1141                	addi	sp,sp,-16
    80002a96:	e422                	sd	s0,8(sp)
    80002a98:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002a9a:	00003797          	auipc	a5,0x3
    80002a9e:	25678793          	addi	a5,a5,598 # 80005cf0 <kernelvec>
    80002aa2:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    80002aa6:	6422                	ld	s0,8(sp)
    80002aa8:	0141                	addi	sp,sp,16
    80002aaa:	8082                	ret

0000000080002aac <prepare_return>:
//
// set up trapframe and control registers for a return to user space
//
void
prepare_return(void)
{
    80002aac:	1141                	addi	sp,sp,-16
    80002aae:	e406                	sd	ra,8(sp)
    80002ab0:	e022                	sd	s0,0(sp)
    80002ab2:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    80002ab4:	9d2ff0ef          	jal	80001c86 <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002ab8:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80002abc:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002abe:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(). because a trap from kernel
  // code to usertrap would be a disaster, turn off interrupts.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    80002ac2:	04000737          	lui	a4,0x4000
    80002ac6:	177d                	addi	a4,a4,-1 # 3ffffff <_entry-0x7c000001>
    80002ac8:	0732                	slli	a4,a4,0xc
    80002aca:	00004797          	auipc	a5,0x4
    80002ace:	53678793          	addi	a5,a5,1334 # 80007000 <_trampoline>
    80002ad2:	00004697          	auipc	a3,0x4
    80002ad6:	52e68693          	addi	a3,a3,1326 # 80007000 <_trampoline>
    80002ada:	8f95                	sub	a5,a5,a3
    80002adc:	97ba                	add	a5,a5,a4
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002ade:	10579073          	csrw	stvec,a5
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    80002ae2:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    80002ae4:	18002773          	csrr	a4,satp
    80002ae8:	e398                	sd	a4,0(a5)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    80002aea:	6d38                	ld	a4,88(a0)
    80002aec:	613c                	ld	a5,64(a0)
    80002aee:	6685                	lui	a3,0x1
    80002af0:	97b6                	add	a5,a5,a3
    80002af2:	e71c                	sd	a5,8(a4)
  p->trapframe->kernel_trap = (uint64)usertrap;
    80002af4:	6d3c                	ld	a5,88(a0)
    80002af6:	00000717          	auipc	a4,0x0
    80002afa:	0f870713          	addi	a4,a4,248 # 80002bee <usertrap>
    80002afe:	eb98                	sd	a4,16(a5)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    80002b00:	6d3c                	ld	a5,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    80002b02:	8712                	mv	a4,tp
    80002b04:	f398                	sd	a4,32(a5)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002b06:	100027f3          	csrr	a5,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    80002b0a:	eff7f793          	andi	a5,a5,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    80002b0e:	0207e793          	ori	a5,a5,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002b12:	10079073          	csrw	sstatus,a5
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    80002b16:	6d3c                	ld	a5,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002b18:	6f9c                	ld	a5,24(a5)
    80002b1a:	14179073          	csrw	sepc,a5
}
    80002b1e:	60a2                	ld	ra,8(sp)
    80002b20:	6402                	ld	s0,0(sp)
    80002b22:	0141                	addi	sp,sp,16
    80002b24:	8082                	ret

0000000080002b26 <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    80002b26:	1101                	addi	sp,sp,-32
    80002b28:	ec06                	sd	ra,24(sp)
    80002b2a:	e822                	sd	s0,16(sp)
    80002b2c:	1000                	addi	s0,sp,32
  if(cpuid() == 0){
    80002b2e:	926ff0ef          	jal	80001c54 <cpuid>
    80002b32:	cd11                	beqz	a0,80002b4e <clockintr+0x28>
  asm volatile("csrr %0, time" : "=r" (x) );
    80002b34:	c01027f3          	rdtime	a5
  }

  // ask for the next timer interrupt. this also clears
  // the interrupt request. 1000000 is about a tenth
  // of a second.
  w_stimecmp(r_time() + 1000000);
    80002b38:	000f4737          	lui	a4,0xf4
    80002b3c:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    80002b40:	97ba                	add	a5,a5,a4
  asm volatile("csrw 0x14d, %0" : : "r" (x));
    80002b42:	14d79073          	csrw	stimecmp,a5
}
    80002b46:	60e2                	ld	ra,24(sp)
    80002b48:	6442                	ld	s0,16(sp)
    80002b4a:	6105                	addi	sp,sp,32
    80002b4c:	8082                	ret
    80002b4e:	e426                	sd	s1,8(sp)
    acquire(&tickslock);
    80002b50:	00014497          	auipc	s1,0x14
    80002b54:	f0848493          	addi	s1,s1,-248 # 80016a58 <tickslock>
    80002b58:	8526                	mv	a0,s1
    80002b5a:	962fe0ef          	jal	80000cbc <acquire>
    ticks++;
    80002b5e:	00006517          	auipc	a0,0x6
    80002b62:	dd250513          	addi	a0,a0,-558 # 80008930 <ticks>
    80002b66:	411c                	lw	a5,0(a0)
    80002b68:	2785                	addiw	a5,a5,1
    80002b6a:	c11c                	sw	a5,0(a0)
    wakeup(&ticks);
    80002b6c:	a31ff0ef          	jal	8000259c <wakeup>
    release(&tickslock);
    80002b70:	8526                	mv	a0,s1
    80002b72:	9e2fe0ef          	jal	80000d54 <release>
    80002b76:	64a2                	ld	s1,8(sp)
    80002b78:	bf75                	j	80002b34 <clockintr+0xe>

0000000080002b7a <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    80002b7a:	1101                	addi	sp,sp,-32
    80002b7c:	ec06                	sd	ra,24(sp)
    80002b7e:	e822                	sd	s0,16(sp)
    80002b80:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002b82:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if(scause == 0x8000000000000009L){
    80002b86:	57fd                	li	a5,-1
    80002b88:	17fe                	slli	a5,a5,0x3f
    80002b8a:	07a5                	addi	a5,a5,9
    80002b8c:	00f70c63          	beq	a4,a5,80002ba4 <devintr+0x2a>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000005L){
    80002b90:	57fd                	li	a5,-1
    80002b92:	17fe                	slli	a5,a5,0x3f
    80002b94:	0795                	addi	a5,a5,5
    // timer interrupt.
    clockintr();
    return 2;
  } else {
    return 0;
    80002b96:	4501                	li	a0,0
  } else if(scause == 0x8000000000000005L){
    80002b98:	04f70763          	beq	a4,a5,80002be6 <devintr+0x6c>
  }
}
    80002b9c:	60e2                	ld	ra,24(sp)
    80002b9e:	6442                	ld	s0,16(sp)
    80002ba0:	6105                	addi	sp,sp,32
    80002ba2:	8082                	ret
    80002ba4:	e426                	sd	s1,8(sp)
    int irq = plic_claim();
    80002ba6:	1f6030ef          	jal	80005d9c <plic_claim>
    80002baa:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    80002bac:	47a9                	li	a5,10
    80002bae:	00f50963          	beq	a0,a5,80002bc0 <devintr+0x46>
    } else if(irq == VIRTIO0_IRQ){
    80002bb2:	4785                	li	a5,1
    80002bb4:	00f50963          	beq	a0,a5,80002bc6 <devintr+0x4c>
    return 1;
    80002bb8:	4505                	li	a0,1
    } else if(irq){
    80002bba:	e889                	bnez	s1,80002bcc <devintr+0x52>
    80002bbc:	64a2                	ld	s1,8(sp)
    80002bbe:	bff9                	j	80002b9c <devintr+0x22>
      uartintr();
    80002bc0:	e23fd0ef          	jal	800009e2 <uartintr>
    if(irq)
    80002bc4:	a819                	j	80002bda <devintr+0x60>
      virtio_disk_intr();
    80002bc6:	69c030ef          	jal	80006262 <virtio_disk_intr>
    if(irq)
    80002bca:	a801                	j	80002bda <devintr+0x60>
      printf("unexpected interrupt irq=%d\n", irq);
    80002bcc:	85a6                	mv	a1,s1
    80002bce:	00005517          	auipc	a0,0x5
    80002bd2:	6c250513          	addi	a0,a0,1730 # 80008290 <etext+0x290>
    80002bd6:	957fd0ef          	jal	8000052c <printf>
      plic_complete(irq);
    80002bda:	8526                	mv	a0,s1
    80002bdc:	1e0030ef          	jal	80005dbc <plic_complete>
    return 1;
    80002be0:	4505                	li	a0,1
    80002be2:	64a2                	ld	s1,8(sp)
    80002be4:	bf65                	j	80002b9c <devintr+0x22>
    clockintr();
    80002be6:	f41ff0ef          	jal	80002b26 <clockintr>
    return 2;
    80002bea:	4509                	li	a0,2
    80002bec:	bf45                	j	80002b9c <devintr+0x22>

0000000080002bee <usertrap>:
{
    80002bee:	1101                	addi	sp,sp,-32
    80002bf0:	ec06                	sd	ra,24(sp)
    80002bf2:	e822                	sd	s0,16(sp)
    80002bf4:	e426                	sd	s1,8(sp)
    80002bf6:	e04a                	sd	s2,0(sp)
    80002bf8:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002bfa:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    80002bfe:	1007f793          	andi	a5,a5,256
    80002c02:	eba5                	bnez	a5,80002c72 <usertrap+0x84>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002c04:	00003797          	auipc	a5,0x3
    80002c08:	0ec78793          	addi	a5,a5,236 # 80005cf0 <kernelvec>
    80002c0c:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80002c10:	876ff0ef          	jal	80001c86 <myproc>
    80002c14:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    80002c16:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002c18:	14102773          	csrr	a4,sepc
    80002c1c:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002c1e:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    80002c22:	47a1                	li	a5,8
    80002c24:	04f70d63          	beq	a4,a5,80002c7e <usertrap+0x90>
  } else if((which_dev = devintr()) != 0){
    80002c28:	f53ff0ef          	jal	80002b7a <devintr>
    80002c2c:	892a                	mv	s2,a0
    80002c2e:	e945                	bnez	a0,80002cde <usertrap+0xf0>
    80002c30:	14202773          	csrr	a4,scause
  } else if((r_scause() == 15 || r_scause() == 13) &&
    80002c34:	47bd                	li	a5,15
    80002c36:	08f70863          	beq	a4,a5,80002cc6 <usertrap+0xd8>
    80002c3a:	14202773          	csrr	a4,scause
    80002c3e:	47b5                	li	a5,13
    80002c40:	08f70363          	beq	a4,a5,80002cc6 <usertrap+0xd8>
    80002c44:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause 0x%lx pid=%d\n", r_scause(), p->pid);
    80002c48:	58d0                	lw	a2,52(s1)
    80002c4a:	00005517          	auipc	a0,0x5
    80002c4e:	68650513          	addi	a0,a0,1670 # 800082d0 <etext+0x2d0>
    80002c52:	8dbfd0ef          	jal	8000052c <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002c56:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002c5a:	14302673          	csrr	a2,stval
    printf("            sepc=0x%lx stval=0x%lx\n", r_sepc(), r_stval());
    80002c5e:	00005517          	auipc	a0,0x5
    80002c62:	6a250513          	addi	a0,a0,1698 # 80008300 <etext+0x300>
    80002c66:	8c7fd0ef          	jal	8000052c <printf>
    setkilled(p);
    80002c6a:	8526                	mv	a0,s1
    80002c6c:	b1bff0ef          	jal	80002786 <setkilled>
    80002c70:	a035                	j	80002c9c <usertrap+0xae>
    panic("usertrap: not from user mode");
    80002c72:	00005517          	auipc	a0,0x5
    80002c76:	63e50513          	addi	a0,a0,1598 # 800082b0 <etext+0x2b0>
    80002c7a:	b99fd0ef          	jal	80000812 <panic>
    if(killed(p))
    80002c7e:	b2dff0ef          	jal	800027aa <killed>
    80002c82:	ed15                	bnez	a0,80002cbe <usertrap+0xd0>
    p->trapframe->epc += 4;
    80002c84:	6cb8                	ld	a4,88(s1)
    80002c86:	6f1c                	ld	a5,24(a4)
    80002c88:	0791                	addi	a5,a5,4
    80002c8a:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002c8c:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002c90:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002c94:	10079073          	csrw	sstatus,a5
    syscall();
    80002c98:	246000ef          	jal	80002ede <syscall>
  if(killed(p))
    80002c9c:	8526                	mv	a0,s1
    80002c9e:	b0dff0ef          	jal	800027aa <killed>
    80002ca2:	e139                	bnez	a0,80002ce8 <usertrap+0xfa>
  prepare_return();
    80002ca4:	e09ff0ef          	jal	80002aac <prepare_return>
  uint64 satp = MAKE_SATP(p->pagetable);
    80002ca8:	68a8                	ld	a0,80(s1)
    80002caa:	8131                	srli	a0,a0,0xc
    80002cac:	57fd                	li	a5,-1
    80002cae:	17fe                	slli	a5,a5,0x3f
    80002cb0:	8d5d                	or	a0,a0,a5
}
    80002cb2:	60e2                	ld	ra,24(sp)
    80002cb4:	6442                	ld	s0,16(sp)
    80002cb6:	64a2                	ld	s1,8(sp)
    80002cb8:	6902                	ld	s2,0(sp)
    80002cba:	6105                	addi	sp,sp,32
    80002cbc:	8082                	ret
      kexit(-1);
    80002cbe:	557d                	li	a0,-1
    80002cc0:	99bff0ef          	jal	8000265a <kexit>
    80002cc4:	b7c1                	j	80002c84 <usertrap+0x96>
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002cc6:	143025f3          	csrr	a1,stval
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002cca:	14202673          	csrr	a2,scause
            vmfault(p->pagetable, r_stval(), (r_scause() == 13)? 1 : 0) != 0) {
    80002cce:	164d                	addi	a2,a2,-13 # ff3 <_entry-0x7ffff00d>
    80002cd0:	00163613          	seqz	a2,a2
    80002cd4:	68a8                	ld	a0,80(s1)
    80002cd6:	b4ffe0ef          	jal	80001824 <vmfault>
  } else if((r_scause() == 15 || r_scause() == 13) &&
    80002cda:	f169                	bnez	a0,80002c9c <usertrap+0xae>
    80002cdc:	b7a5                	j	80002c44 <usertrap+0x56>
  if(killed(p))
    80002cde:	8526                	mv	a0,s1
    80002ce0:	acbff0ef          	jal	800027aa <killed>
    80002ce4:	c511                	beqz	a0,80002cf0 <usertrap+0x102>
    80002ce6:	a011                	j	80002cea <usertrap+0xfc>
    80002ce8:	4901                	li	s2,0
    kexit(-1);
    80002cea:	557d                	li	a0,-1
    80002cec:	96fff0ef          	jal	8000265a <kexit>
  if(which_dev == 2)
    80002cf0:	4789                	li	a5,2
    80002cf2:	faf919e3          	bne	s2,a5,80002ca4 <usertrap+0xb6>
    yield();
    80002cf6:	827ff0ef          	jal	8000251c <yield>
    80002cfa:	b76d                	j	80002ca4 <usertrap+0xb6>

0000000080002cfc <kerneltrap>:
{
    80002cfc:	7179                	addi	sp,sp,-48
    80002cfe:	f406                	sd	ra,40(sp)
    80002d00:	f022                	sd	s0,32(sp)
    80002d02:	ec26                	sd	s1,24(sp)
    80002d04:	e84a                	sd	s2,16(sp)
    80002d06:	e44e                	sd	s3,8(sp)
    80002d08:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002d0a:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002d0e:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002d12:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    80002d16:	1004f793          	andi	a5,s1,256
    80002d1a:	c795                	beqz	a5,80002d46 <kerneltrap+0x4a>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002d1c:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002d20:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    80002d22:	eb85                	bnez	a5,80002d52 <kerneltrap+0x56>
  if((which_dev = devintr()) == 0){
    80002d24:	e57ff0ef          	jal	80002b7a <devintr>
    80002d28:	c91d                	beqz	a0,80002d5e <kerneltrap+0x62>
  if(which_dev == 2 && myproc() != 0)
    80002d2a:	4789                	li	a5,2
    80002d2c:	04f50a63          	beq	a0,a5,80002d80 <kerneltrap+0x84>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002d30:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002d34:	10049073          	csrw	sstatus,s1
}
    80002d38:	70a2                	ld	ra,40(sp)
    80002d3a:	7402                	ld	s0,32(sp)
    80002d3c:	64e2                	ld	s1,24(sp)
    80002d3e:	6942                	ld	s2,16(sp)
    80002d40:	69a2                	ld	s3,8(sp)
    80002d42:	6145                	addi	sp,sp,48
    80002d44:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80002d46:	00005517          	auipc	a0,0x5
    80002d4a:	5e250513          	addi	a0,a0,1506 # 80008328 <etext+0x328>
    80002d4e:	ac5fd0ef          	jal	80000812 <panic>
    panic("kerneltrap: interrupts enabled");
    80002d52:	00005517          	auipc	a0,0x5
    80002d56:	5fe50513          	addi	a0,a0,1534 # 80008350 <etext+0x350>
    80002d5a:	ab9fd0ef          	jal	80000812 <panic>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002d5e:	14102673          	csrr	a2,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002d62:	143026f3          	csrr	a3,stval
    printf("scause=0x%lx sepc=0x%lx stval=0x%lx\n", scause, r_sepc(), r_stval());
    80002d66:	85ce                	mv	a1,s3
    80002d68:	00005517          	auipc	a0,0x5
    80002d6c:	60850513          	addi	a0,a0,1544 # 80008370 <etext+0x370>
    80002d70:	fbcfd0ef          	jal	8000052c <printf>
    panic("kerneltrap");
    80002d74:	00005517          	auipc	a0,0x5
    80002d78:	62450513          	addi	a0,a0,1572 # 80008398 <etext+0x398>
    80002d7c:	a97fd0ef          	jal	80000812 <panic>
  if(which_dev == 2 && myproc() != 0)
    80002d80:	f07fe0ef          	jal	80001c86 <myproc>
    80002d84:	d555                	beqz	a0,80002d30 <kerneltrap+0x34>
    yield();
    80002d86:	f96ff0ef          	jal	8000251c <yield>
    80002d8a:	b75d                	j	80002d30 <kerneltrap+0x34>

0000000080002d8c <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80002d8c:	1101                	addi	sp,sp,-32
    80002d8e:	ec06                	sd	ra,24(sp)
    80002d90:	e822                	sd	s0,16(sp)
    80002d92:	e426                	sd	s1,8(sp)
    80002d94:	1000                	addi	s0,sp,32
    80002d96:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002d98:	eeffe0ef          	jal	80001c86 <myproc>
  switch (n) {
    80002d9c:	4795                	li	a5,5
    80002d9e:	0497e163          	bltu	a5,s1,80002de0 <argraw+0x54>
    80002da2:	048a                	slli	s1,s1,0x2
    80002da4:	00006717          	auipc	a4,0x6
    80002da8:	a3c70713          	addi	a4,a4,-1476 # 800087e0 <states.0+0x30>
    80002dac:	94ba                	add	s1,s1,a4
    80002dae:	409c                	lw	a5,0(s1)
    80002db0:	97ba                	add	a5,a5,a4
    80002db2:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    80002db4:	6d3c                	ld	a5,88(a0)
    80002db6:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80002db8:	60e2                	ld	ra,24(sp)
    80002dba:	6442                	ld	s0,16(sp)
    80002dbc:	64a2                	ld	s1,8(sp)
    80002dbe:	6105                	addi	sp,sp,32
    80002dc0:	8082                	ret
    return p->trapframe->a1;
    80002dc2:	6d3c                	ld	a5,88(a0)
    80002dc4:	7fa8                	ld	a0,120(a5)
    80002dc6:	bfcd                	j	80002db8 <argraw+0x2c>
    return p->trapframe->a2;
    80002dc8:	6d3c                	ld	a5,88(a0)
    80002dca:	63c8                	ld	a0,128(a5)
    80002dcc:	b7f5                	j	80002db8 <argraw+0x2c>
    return p->trapframe->a3;
    80002dce:	6d3c                	ld	a5,88(a0)
    80002dd0:	67c8                	ld	a0,136(a5)
    80002dd2:	b7dd                	j	80002db8 <argraw+0x2c>
    return p->trapframe->a4;
    80002dd4:	6d3c                	ld	a5,88(a0)
    80002dd6:	6bc8                	ld	a0,144(a5)
    80002dd8:	b7c5                	j	80002db8 <argraw+0x2c>
    return p->trapframe->a5;
    80002dda:	6d3c                	ld	a5,88(a0)
    80002ddc:	6fc8                	ld	a0,152(a5)
    80002dde:	bfe9                	j	80002db8 <argraw+0x2c>
  panic("argraw");
    80002de0:	00005517          	auipc	a0,0x5
    80002de4:	5c850513          	addi	a0,a0,1480 # 800083a8 <etext+0x3a8>
    80002de8:	a2bfd0ef          	jal	80000812 <panic>

0000000080002dec <fetchaddr>:
{
    80002dec:	1101                	addi	sp,sp,-32
    80002dee:	ec06                	sd	ra,24(sp)
    80002df0:	e822                	sd	s0,16(sp)
    80002df2:	e426                	sd	s1,8(sp)
    80002df4:	e04a                	sd	s2,0(sp)
    80002df6:	1000                	addi	s0,sp,32
    80002df8:	84aa                	mv	s1,a0
    80002dfa:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002dfc:	e8bfe0ef          	jal	80001c86 <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    80002e00:	653c                	ld	a5,72(a0)
    80002e02:	02f4f663          	bgeu	s1,a5,80002e2e <fetchaddr+0x42>
    80002e06:	00848713          	addi	a4,s1,8
    80002e0a:	02e7e463          	bltu	a5,a4,80002e32 <fetchaddr+0x46>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80002e0e:	46a1                	li	a3,8
    80002e10:	8626                	mv	a2,s1
    80002e12:	85ca                	mv	a1,s2
    80002e14:	6928                	ld	a0,80(a0)
    80002e16:	bdffe0ef          	jal	800019f4 <copyin>
    80002e1a:	00a03533          	snez	a0,a0
    80002e1e:	40a00533          	neg	a0,a0
}
    80002e22:	60e2                	ld	ra,24(sp)
    80002e24:	6442                	ld	s0,16(sp)
    80002e26:	64a2                	ld	s1,8(sp)
    80002e28:	6902                	ld	s2,0(sp)
    80002e2a:	6105                	addi	sp,sp,32
    80002e2c:	8082                	ret
    return -1;
    80002e2e:	557d                	li	a0,-1
    80002e30:	bfcd                	j	80002e22 <fetchaddr+0x36>
    80002e32:	557d                	li	a0,-1
    80002e34:	b7fd                	j	80002e22 <fetchaddr+0x36>

0000000080002e36 <fetchstr>:
{
    80002e36:	7179                	addi	sp,sp,-48
    80002e38:	f406                	sd	ra,40(sp)
    80002e3a:	f022                	sd	s0,32(sp)
    80002e3c:	ec26                	sd	s1,24(sp)
    80002e3e:	e84a                	sd	s2,16(sp)
    80002e40:	e44e                	sd	s3,8(sp)
    80002e42:	1800                	addi	s0,sp,48
    80002e44:	892a                	mv	s2,a0
    80002e46:	84ae                	mv	s1,a1
    80002e48:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80002e4a:	e3dfe0ef          	jal	80001c86 <myproc>
  if(copyinstr(p->pagetable, buf, addr, max) < 0)
    80002e4e:	86ce                	mv	a3,s3
    80002e50:	864a                	mv	a2,s2
    80002e52:	85a6                	mv	a1,s1
    80002e54:	6928                	ld	a0,80(a0)
    80002e56:	8f7fe0ef          	jal	8000174c <copyinstr>
    80002e5a:	00054c63          	bltz	a0,80002e72 <fetchstr+0x3c>
  return strlen(buf);
    80002e5e:	8526                	mv	a0,s1
    80002e60:	8a0fe0ef          	jal	80000f00 <strlen>
}
    80002e64:	70a2                	ld	ra,40(sp)
    80002e66:	7402                	ld	s0,32(sp)
    80002e68:	64e2                	ld	s1,24(sp)
    80002e6a:	6942                	ld	s2,16(sp)
    80002e6c:	69a2                	ld	s3,8(sp)
    80002e6e:	6145                	addi	sp,sp,48
    80002e70:	8082                	ret
    return -1;
    80002e72:	557d                	li	a0,-1
    80002e74:	bfc5                	j	80002e64 <fetchstr+0x2e>

0000000080002e76 <argint>:

// Fetch the nth 32-bit system call argument.
void
argint(int n, int *ip)
{
    80002e76:	1101                	addi	sp,sp,-32
    80002e78:	ec06                	sd	ra,24(sp)
    80002e7a:	e822                	sd	s0,16(sp)
    80002e7c:	e426                	sd	s1,8(sp)
    80002e7e:	1000                	addi	s0,sp,32
    80002e80:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002e82:	f0bff0ef          	jal	80002d8c <argraw>
    80002e86:	c088                	sw	a0,0(s1)
}
    80002e88:	60e2                	ld	ra,24(sp)
    80002e8a:	6442                	ld	s0,16(sp)
    80002e8c:	64a2                	ld	s1,8(sp)
    80002e8e:	6105                	addi	sp,sp,32
    80002e90:	8082                	ret

0000000080002e92 <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void
argaddr(int n, uint64 *ip)
{
    80002e92:	1101                	addi	sp,sp,-32
    80002e94:	ec06                	sd	ra,24(sp)
    80002e96:	e822                	sd	s0,16(sp)
    80002e98:	e426                	sd	s1,8(sp)
    80002e9a:	1000                	addi	s0,sp,32
    80002e9c:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002e9e:	eefff0ef          	jal	80002d8c <argraw>
    80002ea2:	e088                	sd	a0,0(s1)
}
    80002ea4:	60e2                	ld	ra,24(sp)
    80002ea6:	6442                	ld	s0,16(sp)
    80002ea8:	64a2                	ld	s1,8(sp)
    80002eaa:	6105                	addi	sp,sp,32
    80002eac:	8082                	ret

0000000080002eae <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80002eae:	7179                	addi	sp,sp,-48
    80002eb0:	f406                	sd	ra,40(sp)
    80002eb2:	f022                	sd	s0,32(sp)
    80002eb4:	ec26                	sd	s1,24(sp)
    80002eb6:	e84a                	sd	s2,16(sp)
    80002eb8:	1800                	addi	s0,sp,48
    80002eba:	84ae                	mv	s1,a1
    80002ebc:	8932                	mv	s2,a2
  uint64 addr;
  argaddr(n, &addr);
    80002ebe:	fd840593          	addi	a1,s0,-40
    80002ec2:	fd1ff0ef          	jal	80002e92 <argaddr>
  return fetchstr(addr, buf, max);
    80002ec6:	864a                	mv	a2,s2
    80002ec8:	85a6                	mv	a1,s1
    80002eca:	fd843503          	ld	a0,-40(s0)
    80002ece:	f69ff0ef          	jal	80002e36 <fetchstr>
}
    80002ed2:	70a2                	ld	ra,40(sp)
    80002ed4:	7402                	ld	s0,32(sp)
    80002ed6:	64e2                	ld	s1,24(sp)
    80002ed8:	6942                	ld	s2,16(sp)
    80002eda:	6145                	addi	sp,sp,48
    80002edc:	8082                	ret

0000000080002ede <syscall>:

};

void
syscall(void)
{
    80002ede:	1101                	addi	sp,sp,-32
    80002ee0:	ec06                	sd	ra,24(sp)
    80002ee2:	e822                	sd	s0,16(sp)
    80002ee4:	e426                	sd	s1,8(sp)
    80002ee6:	e04a                	sd	s2,0(sp)
    80002ee8:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    80002eea:	d9dfe0ef          	jal	80001c86 <myproc>
    80002eee:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    80002ef0:	05853903          	ld	s2,88(a0)
    80002ef4:	0a893783          	ld	a5,168(s2)
    80002ef8:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80002efc:	37fd                	addiw	a5,a5,-1
    80002efe:	4769                	li	a4,26
    80002f00:	00f76f63          	bltu	a4,a5,80002f1e <syscall+0x40>
    80002f04:	00369713          	slli	a4,a3,0x3
    80002f08:	00006797          	auipc	a5,0x6
    80002f0c:	8f078793          	addi	a5,a5,-1808 # 800087f8 <syscalls>
    80002f10:	97ba                	add	a5,a5,a4
    80002f12:	639c                	ld	a5,0(a5)
    80002f14:	c789                	beqz	a5,80002f1e <syscall+0x40>
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    p->trapframe->a0 = syscalls[num]();
    80002f16:	9782                	jalr	a5
    80002f18:	06a93823          	sd	a0,112(s2)
    80002f1c:	a829                	j	80002f36 <syscall+0x58>
  } else {
    printf("%d %s: unknown sys call %d\n",
    80002f1e:	15848613          	addi	a2,s1,344
    80002f22:	58cc                	lw	a1,52(s1)
    80002f24:	00005517          	auipc	a0,0x5
    80002f28:	48c50513          	addi	a0,a0,1164 # 800083b0 <etext+0x3b0>
    80002f2c:	e00fd0ef          	jal	8000052c <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80002f30:	6cbc                	ld	a5,88(s1)
    80002f32:	577d                	li	a4,-1
    80002f34:	fbb8                	sd	a4,112(a5)
  }
}
    80002f36:	60e2                	ld	ra,24(sp)
    80002f38:	6442                	ld	s0,16(sp)
    80002f3a:	64a2                	ld	s1,8(sp)
    80002f3c:	6902                	ld	s2,0(sp)
    80002f3e:	6105                	addi	sp,sp,32
    80002f40:	8082                	ret

0000000080002f42 <sys_exit>:
#include "vm.h"
#include "schedlog.h"

uint64
sys_exit(void)
{
    80002f42:	1101                	addi	sp,sp,-32
    80002f44:	ec06                	sd	ra,24(sp)
    80002f46:	e822                	sd	s0,16(sp)
    80002f48:	1000                	addi	s0,sp,32
  int n;
  argint(0, &n);
    80002f4a:	fec40593          	addi	a1,s0,-20
    80002f4e:	4501                	li	a0,0
    80002f50:	f27ff0ef          	jal	80002e76 <argint>
  kexit(n);
    80002f54:	fec42503          	lw	a0,-20(s0)
    80002f58:	f02ff0ef          	jal	8000265a <kexit>
  return 0;  // not reached
}
    80002f5c:	4501                	li	a0,0
    80002f5e:	60e2                	ld	ra,24(sp)
    80002f60:	6442                	ld	s0,16(sp)
    80002f62:	6105                	addi	sp,sp,32
    80002f64:	8082                	ret

0000000080002f66 <sys_getpid>:

uint64
sys_getpid(void)
{
    80002f66:	1141                	addi	sp,sp,-16
    80002f68:	e406                	sd	ra,8(sp)
    80002f6a:	e022                	sd	s0,0(sp)
    80002f6c:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80002f6e:	d19fe0ef          	jal	80001c86 <myproc>
}
    80002f72:	5948                	lw	a0,52(a0)
    80002f74:	60a2                	ld	ra,8(sp)
    80002f76:	6402                	ld	s0,0(sp)
    80002f78:	0141                	addi	sp,sp,16
    80002f7a:	8082                	ret

0000000080002f7c <sys_fork>:

uint64
sys_fork(void)
{
    80002f7c:	1141                	addi	sp,sp,-16
    80002f7e:	e406                	sd	ra,8(sp)
    80002f80:	e022                	sd	s0,0(sp)
    80002f82:	0800                	addi	s0,sp,16
  return kfork();
    80002f84:	906ff0ef          	jal	8000208a <kfork>
}
    80002f88:	60a2                	ld	ra,8(sp)
    80002f8a:	6402                	ld	s0,0(sp)
    80002f8c:	0141                	addi	sp,sp,16
    80002f8e:	8082                	ret

0000000080002f90 <sys_wait>:

uint64
sys_wait(void)
{
    80002f90:	1101                	addi	sp,sp,-32
    80002f92:	ec06                	sd	ra,24(sp)
    80002f94:	e822                	sd	s0,16(sp)
    80002f96:	1000                	addi	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    80002f98:	fe840593          	addi	a1,s0,-24
    80002f9c:	4501                	li	a0,0
    80002f9e:	ef5ff0ef          	jal	80002e92 <argaddr>
  return kwait(p);
    80002fa2:	fe843503          	ld	a0,-24(s0)
    80002fa6:	82fff0ef          	jal	800027d4 <kwait>
}
    80002faa:	60e2                	ld	ra,24(sp)
    80002fac:	6442                	ld	s0,16(sp)
    80002fae:	6105                	addi	sp,sp,32
    80002fb0:	8082                	ret

0000000080002fb2 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80002fb2:	7179                	addi	sp,sp,-48
    80002fb4:	f406                	sd	ra,40(sp)
    80002fb6:	f022                	sd	s0,32(sp)
    80002fb8:	ec26                	sd	s1,24(sp)
    80002fba:	1800                	addi	s0,sp,48
  uint64 addr;
  int t;
  int n;

  argint(0, &n);
    80002fbc:	fd840593          	addi	a1,s0,-40
    80002fc0:	4501                	li	a0,0
    80002fc2:	eb5ff0ef          	jal	80002e76 <argint>
  argint(1, &t);
    80002fc6:	fdc40593          	addi	a1,s0,-36
    80002fca:	4505                	li	a0,1
    80002fcc:	eabff0ef          	jal	80002e76 <argint>
  addr = myproc()->sz;
    80002fd0:	cb7fe0ef          	jal	80001c86 <myproc>
    80002fd4:	6524                	ld	s1,72(a0)

  if(t == SBRK_EAGER || n < 0) {
    80002fd6:	fdc42703          	lw	a4,-36(s0)
    80002fda:	4785                	li	a5,1
    80002fdc:	02f70763          	beq	a4,a5,8000300a <sys_sbrk+0x58>
    80002fe0:	fd842783          	lw	a5,-40(s0)
    80002fe4:	0207c363          	bltz	a5,8000300a <sys_sbrk+0x58>
    }
  } else {
    // Lazily allocate memory for this process: increase its memory
    // size but don't allocate memory. If the processes uses the
    // memory, vmfault() will allocate it.
    if(addr + n < addr)
    80002fe8:	97a6                	add	a5,a5,s1
    80002fea:	0297ee63          	bltu	a5,s1,80003026 <sys_sbrk+0x74>
      return -1;
    if(addr + n > TRAPFRAME)
    80002fee:	02000737          	lui	a4,0x2000
    80002ff2:	177d                	addi	a4,a4,-1 # 1ffffff <_entry-0x7e000001>
    80002ff4:	0736                	slli	a4,a4,0xd
    80002ff6:	02f76a63          	bltu	a4,a5,8000302a <sys_sbrk+0x78>
      return -1;
    myproc()->sz += n;
    80002ffa:	c8dfe0ef          	jal	80001c86 <myproc>
    80002ffe:	fd842703          	lw	a4,-40(s0)
    80003002:	653c                	ld	a5,72(a0)
    80003004:	97ba                	add	a5,a5,a4
    80003006:	e53c                	sd	a5,72(a0)
    80003008:	a039                	j	80003016 <sys_sbrk+0x64>
    if(growproc(n) < 0) {
    8000300a:	fd842503          	lw	a0,-40(s0)
    8000300e:	faffe0ef          	jal	80001fbc <growproc>
    80003012:	00054863          	bltz	a0,80003022 <sys_sbrk+0x70>
  }
  return addr;
}
    80003016:	8526                	mv	a0,s1
    80003018:	70a2                	ld	ra,40(sp)
    8000301a:	7402                	ld	s0,32(sp)
    8000301c:	64e2                	ld	s1,24(sp)
    8000301e:	6145                	addi	sp,sp,48
    80003020:	8082                	ret
      return -1;
    80003022:	54fd                	li	s1,-1
    80003024:	bfcd                	j	80003016 <sys_sbrk+0x64>
      return -1;
    80003026:	54fd                	li	s1,-1
    80003028:	b7fd                	j	80003016 <sys_sbrk+0x64>
      return -1;
    8000302a:	54fd                	li	s1,-1
    8000302c:	b7ed                	j	80003016 <sys_sbrk+0x64>

000000008000302e <sys_pause>:

uint64
sys_pause(void)
{
    8000302e:	7139                	addi	sp,sp,-64
    80003030:	fc06                	sd	ra,56(sp)
    80003032:	f822                	sd	s0,48(sp)
    80003034:	f04a                	sd	s2,32(sp)
    80003036:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    80003038:	fcc40593          	addi	a1,s0,-52
    8000303c:	4501                	li	a0,0
    8000303e:	e39ff0ef          	jal	80002e76 <argint>
  if(n < 0)
    80003042:	fcc42783          	lw	a5,-52(s0)
    80003046:	0607c763          	bltz	a5,800030b4 <sys_pause+0x86>
    n = 0;
  acquire(&tickslock);
    8000304a:	00014517          	auipc	a0,0x14
    8000304e:	a0e50513          	addi	a0,a0,-1522 # 80016a58 <tickslock>
    80003052:	c6bfd0ef          	jal	80000cbc <acquire>
  ticks0 = ticks;
    80003056:	00006917          	auipc	s2,0x6
    8000305a:	8da92903          	lw	s2,-1830(s2) # 80008930 <ticks>
  while(ticks - ticks0 < n){
    8000305e:	fcc42783          	lw	a5,-52(s0)
    80003062:	cf8d                	beqz	a5,8000309c <sys_pause+0x6e>
    80003064:	f426                	sd	s1,40(sp)
    80003066:	ec4e                	sd	s3,24(sp)
    if(killed(myproc())){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80003068:	00014997          	auipc	s3,0x14
    8000306c:	9f098993          	addi	s3,s3,-1552 # 80016a58 <tickslock>
    80003070:	00006497          	auipc	s1,0x6
    80003074:	8c048493          	addi	s1,s1,-1856 # 80008930 <ticks>
    if(killed(myproc())){
    80003078:	c0ffe0ef          	jal	80001c86 <myproc>
    8000307c:	f2eff0ef          	jal	800027aa <killed>
    80003080:	ed0d                	bnez	a0,800030ba <sys_pause+0x8c>
    sleep(&ticks, &tickslock);
    80003082:	85ce                	mv	a1,s3
    80003084:	8526                	mv	a0,s1
    80003086:	cc6ff0ef          	jal	8000254c <sleep>
  while(ticks - ticks0 < n){
    8000308a:	409c                	lw	a5,0(s1)
    8000308c:	412787bb          	subw	a5,a5,s2
    80003090:	fcc42703          	lw	a4,-52(s0)
    80003094:	fee7e2e3          	bltu	a5,a4,80003078 <sys_pause+0x4a>
    80003098:	74a2                	ld	s1,40(sp)
    8000309a:	69e2                	ld	s3,24(sp)
  }
  release(&tickslock);
    8000309c:	00014517          	auipc	a0,0x14
    800030a0:	9bc50513          	addi	a0,a0,-1604 # 80016a58 <tickslock>
    800030a4:	cb1fd0ef          	jal	80000d54 <release>
  return 0;
    800030a8:	4501                	li	a0,0
}
    800030aa:	70e2                	ld	ra,56(sp)
    800030ac:	7442                	ld	s0,48(sp)
    800030ae:	7902                	ld	s2,32(sp)
    800030b0:	6121                	addi	sp,sp,64
    800030b2:	8082                	ret
    n = 0;
    800030b4:	fc042623          	sw	zero,-52(s0)
    800030b8:	bf49                	j	8000304a <sys_pause+0x1c>
      release(&tickslock);
    800030ba:	00014517          	auipc	a0,0x14
    800030be:	99e50513          	addi	a0,a0,-1634 # 80016a58 <tickslock>
    800030c2:	c93fd0ef          	jal	80000d54 <release>
      return -1;
    800030c6:	557d                	li	a0,-1
    800030c8:	74a2                	ld	s1,40(sp)
    800030ca:	69e2                	ld	s3,24(sp)
    800030cc:	bff9                	j	800030aa <sys_pause+0x7c>

00000000800030ce <sys_kill>:

uint64
sys_kill(void)
{
    800030ce:	1101                	addi	sp,sp,-32
    800030d0:	ec06                	sd	ra,24(sp)
    800030d2:	e822                	sd	s0,16(sp)
    800030d4:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    800030d6:	fec40593          	addi	a1,s0,-20
    800030da:	4501                	li	a0,0
    800030dc:	d9bff0ef          	jal	80002e76 <argint>
  return kkill(pid);
    800030e0:	fec42503          	lw	a0,-20(s0)
    800030e4:	e3cff0ef          	jal	80002720 <kkill>
}
    800030e8:	60e2                	ld	ra,24(sp)
    800030ea:	6442                	ld	s0,16(sp)
    800030ec:	6105                	addi	sp,sp,32
    800030ee:	8082                	ret

00000000800030f0 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    800030f0:	1101                	addi	sp,sp,-32
    800030f2:	ec06                	sd	ra,24(sp)
    800030f4:	e822                	sd	s0,16(sp)
    800030f6:	e426                	sd	s1,8(sp)
    800030f8:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    800030fa:	00014517          	auipc	a0,0x14
    800030fe:	95e50513          	addi	a0,a0,-1698 # 80016a58 <tickslock>
    80003102:	bbbfd0ef          	jal	80000cbc <acquire>
  xticks = ticks;
    80003106:	00006497          	auipc	s1,0x6
    8000310a:	82a4a483          	lw	s1,-2006(s1) # 80008930 <ticks>
  release(&tickslock);
    8000310e:	00014517          	auipc	a0,0x14
    80003112:	94a50513          	addi	a0,a0,-1718 # 80016a58 <tickslock>
    80003116:	c3ffd0ef          	jal	80000d54 <release>
  return xticks;
}
    8000311a:	02049513          	slli	a0,s1,0x20
    8000311e:	9101                	srli	a0,a0,0x20
    80003120:	60e2                	ld	ra,24(sp)
    80003122:	6442                	ld	s0,16(sp)
    80003124:	64a2                	ld	s1,8(sp)
    80003126:	6105                	addi	sp,sp,32
    80003128:	8082                	ret

000000008000312a <sys_schedread>:

uint64
sys_schedread(void)
{
    8000312a:	7131                	addi	sp,sp,-192
    8000312c:	fd06                	sd	ra,184(sp)
    8000312e:	f922                	sd	s0,176(sp)
    80003130:	f526                	sd	s1,168(sp)
    80003132:	f14a                	sd	s2,160(sp)
    80003134:	0180                	addi	s0,sp,192
    80003136:	81010113          	addi	sp,sp,-2032
  uint64 dst;
  int max;

  argaddr(0, &dst);
    8000313a:	fd840593          	addi	a1,s0,-40
    8000313e:	4501                	li	a0,0
    80003140:	d53ff0ef          	jal	80002e92 <argaddr>
  argint(1, &max);
    80003144:	fd440593          	addi	a1,s0,-44
    80003148:	4505                	li	a0,1
    8000314a:	d2dff0ef          	jal	80002e76 <argint>

  if(max <= 0)
    8000314e:	fd442783          	lw	a5,-44(s0)
    return 0;
    80003152:	4901                	li	s2,0
  if(max <= 0)
    80003154:	04f05a63          	blez	a5,800031a8 <sys_schedread+0x7e>

  struct sched_event buf[32];
  if(max > 32)
    80003158:	02000713          	li	a4,32
    8000315c:	00f75663          	bge	a4,a5,80003168 <sys_schedread+0x3e>
    max = 32;
    80003160:	02000793          	li	a5,32
    80003164:	fcf42a23          	sw	a5,-44(s0)

  int n = schedread(buf, max);
    80003168:	757d                	lui	a0,0xfffff
    8000316a:	fd442583          	lw	a1,-44(s0)
    8000316e:	75050793          	addi	a5,a0,1872 # fffffffffffff750 <end+0xffffffff7ffb8870>
    80003172:	00878533          	add	a0,a5,s0
    80003176:	12d030ef          	jal	80006aa2 <schedread>
    8000317a:	84aa                	mv	s1,a0
  if(n < 0)
    return -1;
    8000317c:	597d                	li	s2,-1
  if(n < 0)
    8000317e:	02054563          	bltz	a0,800031a8 <sys_schedread+0x7e>

  if(copyout(myproc()->pagetable, dst, (char *)buf, n * sizeof(struct sched_event)) < 0)
    80003182:	b05fe0ef          	jal	80001c86 <myproc>
    80003186:	8926                	mv	s2,s1
    80003188:	00449693          	slli	a3,s1,0x4
    8000318c:	96a6                	add	a3,a3,s1
    8000318e:	767d                	lui	a2,0xfffff
    80003190:	068a                	slli	a3,a3,0x2
    80003192:	75060793          	addi	a5,a2,1872 # fffffffffffff750 <end+0xffffffff7ffb8870>
    80003196:	00878633          	add	a2,a5,s0
    8000319a:	fd843583          	ld	a1,-40(s0)
    8000319e:	6928                	ld	a0,80(a0)
    800031a0:	f70fe0ef          	jal	80001910 <copyout>
    800031a4:	00054b63          	bltz	a0,800031ba <sys_schedread+0x90>
    return -1;

  return n;
}
    800031a8:	854a                	mv	a0,s2
    800031aa:	7f010113          	addi	sp,sp,2032
    800031ae:	70ea                	ld	ra,184(sp)
    800031b0:	744a                	ld	s0,176(sp)
    800031b2:	74aa                	ld	s1,168(sp)
    800031b4:	790a                	ld	s2,160(sp)
    800031b6:	6129                	addi	sp,sp,192
    800031b8:	8082                	ret
    return -1;
    800031ba:	597d                	li	s2,-1
    800031bc:	b7f5                	j	800031a8 <sys_schedread+0x7e>

00000000800031be <sys_getcpuinfo>:

uint64
sys_getcpuinfo(void)
{
    800031be:	7149                	addi	sp,sp,-368
    800031c0:	f686                	sd	ra,360(sp)
    800031c2:	f2a2                	sd	s0,352(sp)
    800031c4:	eaca                	sd	s2,336(sp)
    800031c6:	1a80                	addi	s0,sp,368
  uint64 dst;
  int max;
  argaddr(0, &dst);
    800031c8:	fd840593          	addi	a1,s0,-40
    800031cc:	4501                	li	a0,0
    800031ce:	cc5ff0ef          	jal	80002e92 <argaddr>
  argint(1, &max);
    800031d2:	fd440593          	addi	a1,s0,-44
    800031d6:	4505                	li	a0,1
    800031d8:	c9fff0ef          	jal	80002e76 <argint>

  if(max <= 0)
    800031dc:	fd442783          	lw	a5,-44(s0)
    return 0;
    800031e0:	4901                	li	s2,0
  if(max <= 0)
    800031e2:	0af05d63          	blez	a5,8000329c <sys_getcpuinfo+0xde>
    800031e6:	eea6                	sd	s1,344(sp)

  struct cpu_info infos[NCPU];
  int count = 0;

  acquire(&tickslock);
    800031e8:	00014517          	auipc	a0,0x14
    800031ec:	87050513          	addi	a0,a0,-1936 # 80016a58 <tickslock>
    800031f0:	acdfd0ef          	jal	80000cbc <acquire>
  uint total_ticks = ticks;
    800031f4:	00005917          	auipc	s2,0x5
    800031f8:	73c92903          	lw	s2,1852(s2) # 80008930 <ticks>
  release(&tickslock);
    800031fc:	00014517          	auipc	a0,0x14
    80003200:	85c50513          	addi	a0,a0,-1956 # 80016a58 <tickslock>
    80003204:	b51fd0ef          	jal	80000d54 <release>

  for(int i = 0; i < NCPU && count < max; i++) {
    80003208:	fd442503          	lw	a0,-44(s0)
    8000320c:	e9040793          	addi	a5,s0,-368
    80003210:	0000e717          	auipc	a4,0xe
    80003214:	90870713          	addi	a4,a4,-1784 # 80010b18 <cpus>
  int count = 0;
    80003218:	4481                	li	s1,0
    ci->current_pid = c->current_pid;
    ci->current_state = c->current_state;
    ci->last_pid = c->last_pid;
    ci->last_state = c->last_state;
    ci->active_ticks = c->active_ticks;
    ci->busy_percent = total_ticks > 0 ? (int)((c->active_ticks * 100) / total_ticks) : 0;
    8000321a:	4881                	li	a7,0
    8000321c:	06400e13          	li	t3,100
    80003220:	02091313          	slli	t1,s2,0x20
    80003224:	02035313          	srli	t1,t1,0x20
  for(int i = 0; i < NCPU && count < max; i++) {
    80003228:	4821                	li	a6,8
    8000322a:	a809                	j	8000323c <sys_getcpuinfo+0x7e>
    ci->busy_percent = total_ticks > 0 ? (int)((c->active_ticks * 100) / total_ticks) : 0;
    8000322c:	d190                	sw	a2,32(a1)
    count++;
    8000322e:	2485                	addiw	s1,s1,1
  for(int i = 0; i < NCPU && count < max; i++) {
    80003230:	02878793          	addi	a5,a5,40
    80003234:	0a870713          	addi	a4,a4,168
    80003238:	05048163          	beq	s1,a6,8000327a <sys_getcpuinfo+0xbc>
    8000323c:	02a4df63          	bge	s1,a0,8000327a <sys_getcpuinfo+0xbc>
    ci->cpu = i;
    80003240:	85be                	mv	a1,a5
    80003242:	c384                	sw	s1,0(a5)
    ci->active = c->active;
    80003244:	08072683          	lw	a3,128(a4)
    80003248:	c3d4                	sw	a3,4(a5)
    ci->current_pid = c->current_pid;
    8000324a:	08472683          	lw	a3,132(a4)
    8000324e:	c794                	sw	a3,8(a5)
    ci->current_state = c->current_state;
    80003250:	08872683          	lw	a3,136(a4)
    80003254:	c7d4                	sw	a3,12(a5)
    ci->last_pid = c->last_pid;
    80003256:	08c72683          	lw	a3,140(a4)
    8000325a:	cb94                	sw	a3,16(a5)
    ci->last_state = c->last_state;
    8000325c:	09072683          	lw	a3,144(a4)
    80003260:	cbd4                	sw	a3,20(a5)
    ci->active_ticks = c->active_ticks;
    80003262:	6f54                	ld	a3,152(a4)
    80003264:	ef94                	sd	a3,24(a5)
    ci->busy_percent = total_ticks > 0 ? (int)((c->active_ticks * 100) / total_ticks) : 0;
    80003266:	8646                	mv	a2,a7
    80003268:	fc0902e3          	beqz	s2,8000322c <sys_getcpuinfo+0x6e>
    8000326c:	03c686b3          	mul	a3,a3,t3
    80003270:	0266d6b3          	divu	a3,a3,t1
    80003274:	0006861b          	sext.w	a2,a3
    80003278:	bf55                	j	8000322c <sys_getcpuinfo+0x6e>
  }

  if(copyout(myproc()->pagetable, dst, (char *)infos, count * sizeof(struct cpu_info)) < 0)
    8000327a:	a0dfe0ef          	jal	80001c86 <myproc>
    8000327e:	8926                	mv	s2,s1
    80003280:	00249693          	slli	a3,s1,0x2
    80003284:	96a6                	add	a3,a3,s1
    80003286:	068e                	slli	a3,a3,0x3
    80003288:	e9040613          	addi	a2,s0,-368
    8000328c:	fd843583          	ld	a1,-40(s0)
    80003290:	6928                	ld	a0,80(a0)
    80003292:	e7efe0ef          	jal	80001910 <copyout>
    80003296:	00054963          	bltz	a0,800032a8 <sys_getcpuinfo+0xea>
    8000329a:	64f6                	ld	s1,344(sp)
    return -1;

  return count;
}
    8000329c:	854a                	mv	a0,s2
    8000329e:	70b6                	ld	ra,360(sp)
    800032a0:	7416                	ld	s0,352(sp)
    800032a2:	6956                	ld	s2,336(sp)
    800032a4:	6175                	addi	sp,sp,368
    800032a6:	8082                	ret
    return -1;
    800032a8:	597d                	li	s2,-1
    800032aa:	64f6                	ld	s1,344(sp)
    800032ac:	bfc5                	j	8000329c <sys_getcpuinfo+0xde>

00000000800032ae <sys_getprocstats>:

uint64
sys_getprocstats(void)
{
    800032ae:	7171                	addi	sp,sp,-176
    800032b0:	f506                	sd	ra,168(sp)
    800032b2:	f122                	sd	s0,160(sp)
    800032b4:	1900                	addi	s0,sp,176
  uint64 dst;
  argaddr(0, &dst);
    800032b6:	fc840593          	addi	a1,s0,-56
    800032ba:	4501                	li	a0,0
    800032bc:	bd7ff0ef          	jal	80002e92 <argaddr>
  if(dst == 0)
    800032c0:	fc843783          	ld	a5,-56(s0)
    return -1;
    800032c4:	557d                	li	a0,-1
  if(dst == 0)
    800032c6:	cfe1                	beqz	a5,8000339e <sys_getprocstats+0xf0>
    800032c8:	ed26                	sd	s1,152(sp)
    800032ca:	e94a                	sd	s2,144(sp)
    800032cc:	e54e                	sd	s3,136(sp)
    800032ce:	e152                	sd	s4,128(sp)
    800032d0:	f5840a13          	addi	s4,s0,-168
    800032d4:	f8840713          	addi	a4,s0,-120
    800032d8:	87d2                	mv	a5,s4

  struct proc_stats stats;
  for (int i = 0; i < PROC_STATE_COUNT; i++) {
    stats.current_count[i] = 0;
    800032da:	0007b023          	sd	zero,0(a5)
    stats.unique_count[i] = 0;
    800032de:	0207b823          	sd	zero,48(a5)
  for (int i = 0; i < PROC_STATE_COUNT; i++) {
    800032e2:	07a1                	addi	a5,a5,8
    800032e4:	fee79be3          	bne	a5,a4,800032da <sys_getprocstats+0x2c>
  }

  struct proc *p;
  for(p = proc; p < &proc[NPROC]; p++) {
    800032e8:	0000e497          	auipc	s1,0xe
    800032ec:	d7048493          	addi	s1,s1,-656 # 80011058 <proc>
    acquire(&p->lock);
    if(p->state >= 0 && p->state < PROC_STATE_COUNT)
    800032f0:	4995                	li	s3,5
  for(p = proc; p < &proc[NPROC]; p++) {
    800032f2:	00013917          	auipc	s2,0x13
    800032f6:	76690913          	addi	s2,s2,1894 # 80016a58 <tickslock>
    800032fa:	a801                	j	8000330a <sys_getprocstats+0x5c>
      stats.current_count[p->state]++;
    release(&p->lock);
    800032fc:	8526                	mv	a0,s1
    800032fe:	a57fd0ef          	jal	80000d54 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80003302:	16848493          	addi	s1,s1,360
    80003306:	03248563          	beq	s1,s2,80003330 <sys_getprocstats+0x82>
    acquire(&p->lock);
    8000330a:	8526                	mv	a0,s1
    8000330c:	9b1fd0ef          	jal	80000cbc <acquire>
    if(p->state >= 0 && p->state < PROC_STATE_COUNT)
    80003310:	4c9c                	lw	a5,24(s1)
    80003312:	fef9e5e3          	bltu	s3,a5,800032fc <sys_getprocstats+0x4e>
      stats.current_count[p->state]++;
    80003316:	02079713          	slli	a4,a5,0x20
    8000331a:	01d75793          	srli	a5,a4,0x1d
    8000331e:	fd078793          	addi	a5,a5,-48
    80003322:	97a2                	add	a5,a5,s0
    80003324:	f887b703          	ld	a4,-120(a5)
    80003328:	0705                	addi	a4,a4,1
    8000332a:	f8e7b423          	sd	a4,-120(a5)
    8000332e:	b7f9                	j	800032fc <sys_getprocstats+0x4e>
  }

  acquire(&procstat_lock);
    80003330:	0000d517          	auipc	a0,0xd
    80003334:	75850513          	addi	a0,a0,1880 # 80010a88 <procstat_lock>
    80003338:	985fd0ef          	jal	80000cbc <acquire>
  for (int i = 0; i < PROC_STATE_COUNT; i++)
    8000333c:	0000d797          	auipc	a5,0xd
    80003340:	76478793          	addi	a5,a5,1892 # 80010aa0 <proc_state_unique>
    80003344:	0000d697          	auipc	a3,0xd
    80003348:	78c68693          	addi	a3,a3,1932 # 80010ad0 <pid_lock>
    stats.unique_count[i] = proc_state_unique[i];
    8000334c:	6398                	ld	a4,0(a5)
    8000334e:	02ea3823          	sd	a4,48(s4)
  for (int i = 0; i < PROC_STATE_COUNT; i++)
    80003352:	07a1                	addi	a5,a5,8
    80003354:	0a21                	addi	s4,s4,8
    80003356:	fed79be3          	bne	a5,a3,8000334c <sys_getprocstats+0x9e>
  stats.total_created = proc_total_created;
    8000335a:	00005797          	auipc	a5,0x5
    8000335e:	5be7b783          	ld	a5,1470(a5) # 80008918 <proc_total_created>
    80003362:	faf43c23          	sd	a5,-72(s0)
  stats.total_exited = proc_total_exited;
    80003366:	00005797          	auipc	a5,0x5
    8000336a:	5aa7b783          	ld	a5,1450(a5) # 80008910 <proc_total_exited>
    8000336e:	fcf43023          	sd	a5,-64(s0)
  release(&procstat_lock);
    80003372:	0000d517          	auipc	a0,0xd
    80003376:	71650513          	addi	a0,a0,1814 # 80010a88 <procstat_lock>
    8000337a:	9dbfd0ef          	jal	80000d54 <release>

  if(copyout(myproc()->pagetable, dst, (char *)&stats, sizeof(stats)) < 0)
    8000337e:	909fe0ef          	jal	80001c86 <myproc>
    80003382:	07000693          	li	a3,112
    80003386:	f5840613          	addi	a2,s0,-168
    8000338a:	fc843583          	ld	a1,-56(s0)
    8000338e:	6928                	ld	a0,80(a0)
    80003390:	d80fe0ef          	jal	80001910 <copyout>
    80003394:	957d                	srai	a0,a0,0x3f
    80003396:	64ea                	ld	s1,152(sp)
    80003398:	694a                	ld	s2,144(sp)
    8000339a:	69aa                	ld	s3,136(sp)
    8000339c:	6a0a                	ld	s4,128(sp)
    return -1;

  return 0;
}
    8000339e:	70aa                	ld	ra,168(sp)
    800033a0:	740a                	ld	s0,160(sp)
    800033a2:	614d                	addi	sp,sp,176
    800033a4:	8082                	ret

00000000800033a6 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    800033a6:	7179                	addi	sp,sp,-48
    800033a8:	f406                	sd	ra,40(sp)
    800033aa:	f022                	sd	s0,32(sp)
    800033ac:	ec26                	sd	s1,24(sp)
    800033ae:	e84a                	sd	s2,16(sp)
    800033b0:	e44e                	sd	s3,8(sp)
    800033b2:	e052                	sd	s4,0(sp)
    800033b4:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    800033b6:	00005597          	auipc	a1,0x5
    800033ba:	01a58593          	addi	a1,a1,26 # 800083d0 <etext+0x3d0>
    800033be:	00013517          	auipc	a0,0x13
    800033c2:	6b250513          	addi	a0,a0,1714 # 80016a70 <bcache>
    800033c6:	877fd0ef          	jal	80000c3c <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    800033ca:	0001b797          	auipc	a5,0x1b
    800033ce:	6a678793          	addi	a5,a5,1702 # 8001ea70 <bcache+0x8000>
    800033d2:	0001c717          	auipc	a4,0x1c
    800033d6:	90670713          	addi	a4,a4,-1786 # 8001ecd8 <bcache+0x8268>
    800033da:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    800033de:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    800033e2:	00013497          	auipc	s1,0x13
    800033e6:	6a648493          	addi	s1,s1,1702 # 80016a88 <bcache+0x18>
    b->next = bcache.head.next;
    800033ea:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    800033ec:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    800033ee:	00005a17          	auipc	s4,0x5
    800033f2:	feaa0a13          	addi	s4,s4,-22 # 800083d8 <etext+0x3d8>
    b->next = bcache.head.next;
    800033f6:	2b893783          	ld	a5,696(s2)
    800033fa:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    800033fc:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80003400:	85d2                	mv	a1,s4
    80003402:	01048513          	addi	a0,s1,16
    80003406:	360010ef          	jal	80004766 <initsleeplock>
    bcache.head.next->prev = b;
    8000340a:	2b893783          	ld	a5,696(s2)
    8000340e:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80003410:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80003414:	45848493          	addi	s1,s1,1112
    80003418:	fd349fe3          	bne	s1,s3,800033f6 <binit+0x50>
  }
}
    8000341c:	70a2                	ld	ra,40(sp)
    8000341e:	7402                	ld	s0,32(sp)
    80003420:	64e2                	ld	s1,24(sp)
    80003422:	6942                	ld	s2,16(sp)
    80003424:	69a2                	ld	s3,8(sp)
    80003426:	6a02                	ld	s4,0(sp)
    80003428:	6145                	addi	sp,sp,48
    8000342a:	8082                	ret

000000008000342c <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    8000342c:	7179                	addi	sp,sp,-48
    8000342e:	f406                	sd	ra,40(sp)
    80003430:	f022                	sd	s0,32(sp)
    80003432:	ec26                	sd	s1,24(sp)
    80003434:	e84a                	sd	s2,16(sp)
    80003436:	e44e                	sd	s3,8(sp)
    80003438:	1800                	addi	s0,sp,48
    8000343a:	892a                	mv	s2,a0
    8000343c:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    8000343e:	00013517          	auipc	a0,0x13
    80003442:	63250513          	addi	a0,a0,1586 # 80016a70 <bcache>
    80003446:	877fd0ef          	jal	80000cbc <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    8000344a:	0001c497          	auipc	s1,0x1c
    8000344e:	8de4b483          	ld	s1,-1826(s1) # 8001ed28 <bcache+0x82b8>
    80003452:	0001c797          	auipc	a5,0x1c
    80003456:	88678793          	addi	a5,a5,-1914 # 8001ecd8 <bcache+0x8268>
    8000345a:	04f48563          	beq	s1,a5,800034a4 <bread+0x78>
    8000345e:	873e                	mv	a4,a5
    80003460:	a021                	j	80003468 <bread+0x3c>
    80003462:	68a4                	ld	s1,80(s1)
    80003464:	04e48063          	beq	s1,a4,800034a4 <bread+0x78>
    if(b->dev == dev && b->blockno == blockno){
    80003468:	449c                	lw	a5,8(s1)
    8000346a:	ff279ce3          	bne	a5,s2,80003462 <bread+0x36>
    8000346e:	44dc                	lw	a5,12(s1)
    80003470:	ff3799e3          	bne	a5,s3,80003462 <bread+0x36>
      b->refcnt++;
    80003474:	40bc                	lw	a5,64(s1)
    80003476:	2785                	addiw	a5,a5,1
    80003478:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    8000347a:	00013517          	auipc	a0,0x13
    8000347e:	5f650513          	addi	a0,a0,1526 # 80016a70 <bcache>
    80003482:	8d3fd0ef          	jal	80000d54 <release>
      acquiresleep(&b->lock);
    80003486:	01048513          	addi	a0,s1,16
    8000348a:	312010ef          	jal	8000479c <acquiresleep>
      fslog_push(FS_BGET_HIT, 0, blockno, 0, "BCACHE");
    8000348e:	00005717          	auipc	a4,0x5
    80003492:	f5270713          	addi	a4,a4,-174 # 800083e0 <etext+0x3e0>
    80003496:	4681                	li	a3,0
    80003498:	864e                	mv	a2,s3
    8000349a:	4581                	li	a1,0
    8000349c:	4519                	li	a0,6
    8000349e:	1da030ef          	jal	80006678 <fslog_push>
      return b;
    800034a2:	a09d                	j	80003508 <bread+0xdc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    800034a4:	0001c497          	auipc	s1,0x1c
    800034a8:	87c4b483          	ld	s1,-1924(s1) # 8001ed20 <bcache+0x82b0>
    800034ac:	0001c797          	auipc	a5,0x1c
    800034b0:	82c78793          	addi	a5,a5,-2004 # 8001ecd8 <bcache+0x8268>
    800034b4:	00f48863          	beq	s1,a5,800034c4 <bread+0x98>
    800034b8:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    800034ba:	40bc                	lw	a5,64(s1)
    800034bc:	cb91                	beqz	a5,800034d0 <bread+0xa4>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    800034be:	64a4                	ld	s1,72(s1)
    800034c0:	fee49de3          	bne	s1,a4,800034ba <bread+0x8e>
  panic("bget: no buffers");
    800034c4:	00005517          	auipc	a0,0x5
    800034c8:	f2450513          	addi	a0,a0,-220 # 800083e8 <etext+0x3e8>
    800034cc:	b46fd0ef          	jal	80000812 <panic>
      b->dev = dev;
    800034d0:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    800034d4:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    800034d8:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    800034dc:	4785                	li	a5,1
    800034de:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    800034e0:	00013517          	auipc	a0,0x13
    800034e4:	59050513          	addi	a0,a0,1424 # 80016a70 <bcache>
    800034e8:	86dfd0ef          	jal	80000d54 <release>
      acquiresleep(&b->lock);
    800034ec:	01048513          	addi	a0,s1,16
    800034f0:	2ac010ef          	jal	8000479c <acquiresleep>
      fslog_push(FS_BGET_MISS, 0, blockno, 0, "BCACHE");
    800034f4:	00005717          	auipc	a4,0x5
    800034f8:	eec70713          	addi	a4,a4,-276 # 800083e0 <etext+0x3e0>
    800034fc:	4681                	li	a3,0
    800034fe:	864e                	mv	a2,s3
    80003500:	4581                	li	a1,0
    80003502:	451d                	li	a0,7
    80003504:	174030ef          	jal	80006678 <fslog_push>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    80003508:	409c                	lw	a5,0(s1)
    8000350a:	cb89                	beqz	a5,8000351c <bread+0xf0>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    8000350c:	8526                	mv	a0,s1
    8000350e:	70a2                	ld	ra,40(sp)
    80003510:	7402                	ld	s0,32(sp)
    80003512:	64e2                	ld	s1,24(sp)
    80003514:	6942                	ld	s2,16(sp)
    80003516:	69a2                	ld	s3,8(sp)
    80003518:	6145                	addi	sp,sp,48
    8000351a:	8082                	ret
    virtio_disk_rw(b, 0);
    8000351c:	4581                	li	a1,0
    8000351e:	8526                	mv	a0,s1
    80003520:	331020ef          	jal	80006050 <virtio_disk_rw>
    b->valid = 1;
    80003524:	4785                	li	a5,1
    80003526:	c09c                	sw	a5,0(s1)
  return b;
    80003528:	b7d5                	j	8000350c <bread+0xe0>

000000008000352a <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    8000352a:	1101                	addi	sp,sp,-32
    8000352c:	ec06                	sd	ra,24(sp)
    8000352e:	e822                	sd	s0,16(sp)
    80003530:	e426                	sd	s1,8(sp)
    80003532:	1000                	addi	s0,sp,32
    80003534:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80003536:	0541                	addi	a0,a0,16
    80003538:	2e2010ef          	jal	8000481a <holdingsleep>
    8000353c:	c911                	beqz	a0,80003550 <bwrite+0x26>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    8000353e:	4585                	li	a1,1
    80003540:	8526                	mv	a0,s1
    80003542:	30f020ef          	jal	80006050 <virtio_disk_rw>
}
    80003546:	60e2                	ld	ra,24(sp)
    80003548:	6442                	ld	s0,16(sp)
    8000354a:	64a2                	ld	s1,8(sp)
    8000354c:	6105                	addi	sp,sp,32
    8000354e:	8082                	ret
    panic("bwrite");
    80003550:	00005517          	auipc	a0,0x5
    80003554:	eb050513          	addi	a0,a0,-336 # 80008400 <etext+0x400>
    80003558:	abafd0ef          	jal	80000812 <panic>

000000008000355c <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    8000355c:	1101                	addi	sp,sp,-32
    8000355e:	ec06                	sd	ra,24(sp)
    80003560:	e822                	sd	s0,16(sp)
    80003562:	e426                	sd	s1,8(sp)
    80003564:	e04a                	sd	s2,0(sp)
    80003566:	1000                	addi	s0,sp,32
    80003568:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    8000356a:	01050913          	addi	s2,a0,16
    8000356e:	854a                	mv	a0,s2
    80003570:	2aa010ef          	jal	8000481a <holdingsleep>
    80003574:	cd05                	beqz	a0,800035ac <brelse+0x50>
    panic("brelse");

  releasesleep(&b->lock);
    80003576:	854a                	mv	a0,s2
    80003578:	26a010ef          	jal	800047e2 <releasesleep>

  acquire(&bcache.lock);
    8000357c:	00013517          	auipc	a0,0x13
    80003580:	4f450513          	addi	a0,a0,1268 # 80016a70 <bcache>
    80003584:	f38fd0ef          	jal	80000cbc <acquire>
  b->refcnt--;
    80003588:	40bc                	lw	a5,64(s1)
    8000358a:	37fd                	addiw	a5,a5,-1
    8000358c:	0007871b          	sext.w	a4,a5
    80003590:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    80003592:	c31d                	beqz	a4,800035b8 <brelse+0x5c>
    bcache.head.next->prev = b;
    bcache.head.next = b;
    fslog_push(FS_BRELEASE, 0, b->blockno, 0, "BCACHE");
  }
  
  release(&bcache.lock);
    80003594:	00013517          	auipc	a0,0x13
    80003598:	4dc50513          	addi	a0,a0,1244 # 80016a70 <bcache>
    8000359c:	fb8fd0ef          	jal	80000d54 <release>
}
    800035a0:	60e2                	ld	ra,24(sp)
    800035a2:	6442                	ld	s0,16(sp)
    800035a4:	64a2                	ld	s1,8(sp)
    800035a6:	6902                	ld	s2,0(sp)
    800035a8:	6105                	addi	sp,sp,32
    800035aa:	8082                	ret
    panic("brelse");
    800035ac:	00005517          	auipc	a0,0x5
    800035b0:	e5c50513          	addi	a0,a0,-420 # 80008408 <etext+0x408>
    800035b4:	a5efd0ef          	jal	80000812 <panic>
    b->next->prev = b->prev;
    800035b8:	68b8                	ld	a4,80(s1)
    800035ba:	64bc                	ld	a5,72(s1)
    800035bc:	e73c                	sd	a5,72(a4)
    b->prev->next = b->next;
    800035be:	68b8                	ld	a4,80(s1)
    800035c0:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    800035c2:	0001b797          	auipc	a5,0x1b
    800035c6:	4ae78793          	addi	a5,a5,1198 # 8001ea70 <bcache+0x8000>
    800035ca:	2b87b703          	ld	a4,696(a5)
    800035ce:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    800035d0:	0001b717          	auipc	a4,0x1b
    800035d4:	70870713          	addi	a4,a4,1800 # 8001ecd8 <bcache+0x8268>
    800035d8:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    800035da:	2b87b703          	ld	a4,696(a5)
    800035de:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    800035e0:	2a97bc23          	sd	s1,696(a5)
    fslog_push(FS_BRELEASE, 0, b->blockno, 0, "BCACHE");
    800035e4:	00005717          	auipc	a4,0x5
    800035e8:	dfc70713          	addi	a4,a4,-516 # 800083e0 <etext+0x3e0>
    800035ec:	4681                	li	a3,0
    800035ee:	44d0                	lw	a2,12(s1)
    800035f0:	4581                	li	a1,0
    800035f2:	4521                	li	a0,8
    800035f4:	084030ef          	jal	80006678 <fslog_push>
    800035f8:	bf71                	j	80003594 <brelse+0x38>

00000000800035fa <bpin>:

void
bpin(struct buf *b) {
    800035fa:	1101                	addi	sp,sp,-32
    800035fc:	ec06                	sd	ra,24(sp)
    800035fe:	e822                	sd	s0,16(sp)
    80003600:	e426                	sd	s1,8(sp)
    80003602:	1000                	addi	s0,sp,32
    80003604:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80003606:	00013517          	auipc	a0,0x13
    8000360a:	46a50513          	addi	a0,a0,1130 # 80016a70 <bcache>
    8000360e:	eaefd0ef          	jal	80000cbc <acquire>
  b->refcnt++;
    80003612:	40bc                	lw	a5,64(s1)
    80003614:	2785                	addiw	a5,a5,1
    80003616:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80003618:	00013517          	auipc	a0,0x13
    8000361c:	45850513          	addi	a0,a0,1112 # 80016a70 <bcache>
    80003620:	f34fd0ef          	jal	80000d54 <release>
}
    80003624:	60e2                	ld	ra,24(sp)
    80003626:	6442                	ld	s0,16(sp)
    80003628:	64a2                	ld	s1,8(sp)
    8000362a:	6105                	addi	sp,sp,32
    8000362c:	8082                	ret

000000008000362e <bunpin>:

void
bunpin(struct buf *b) {
    8000362e:	1101                	addi	sp,sp,-32
    80003630:	ec06                	sd	ra,24(sp)
    80003632:	e822                	sd	s0,16(sp)
    80003634:	e426                	sd	s1,8(sp)
    80003636:	1000                	addi	s0,sp,32
    80003638:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    8000363a:	00013517          	auipc	a0,0x13
    8000363e:	43650513          	addi	a0,a0,1078 # 80016a70 <bcache>
    80003642:	e7afd0ef          	jal	80000cbc <acquire>
  b->refcnt--;
    80003646:	40bc                	lw	a5,64(s1)
    80003648:	37fd                	addiw	a5,a5,-1
    8000364a:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    8000364c:	00013517          	auipc	a0,0x13
    80003650:	42450513          	addi	a0,a0,1060 # 80016a70 <bcache>
    80003654:	f00fd0ef          	jal	80000d54 <release>
}
    80003658:	60e2                	ld	ra,24(sp)
    8000365a:	6442                	ld	s0,16(sp)
    8000365c:	64a2                	ld	s1,8(sp)
    8000365e:	6105                	addi	sp,sp,32
    80003660:	8082                	ret

0000000080003662 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    80003662:	1101                	addi	sp,sp,-32
    80003664:	ec06                	sd	ra,24(sp)
    80003666:	e822                	sd	s0,16(sp)
    80003668:	e426                	sd	s1,8(sp)
    8000366a:	e04a                	sd	s2,0(sp)
    8000366c:	1000                	addi	s0,sp,32
    8000366e:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    80003670:	00d5d59b          	srliw	a1,a1,0xd
    80003674:	0001c797          	auipc	a5,0x1c
    80003678:	ad87a783          	lw	a5,-1320(a5) # 8001f14c <sb+0x1c>
    8000367c:	9dbd                	addw	a1,a1,a5
    8000367e:	dafff0ef          	jal	8000342c <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    80003682:	0074f713          	andi	a4,s1,7
    80003686:	4785                	li	a5,1
    80003688:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    8000368c:	14ce                	slli	s1,s1,0x33
    8000368e:	90d9                	srli	s1,s1,0x36
    80003690:	00950733          	add	a4,a0,s1
    80003694:	05874703          	lbu	a4,88(a4)
    80003698:	00e7f6b3          	and	a3,a5,a4
    8000369c:	c29d                	beqz	a3,800036c2 <bfree+0x60>
    8000369e:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    800036a0:	94aa                	add	s1,s1,a0
    800036a2:	fff7c793          	not	a5,a5
    800036a6:	8f7d                	and	a4,a4,a5
    800036a8:	04e48c23          	sb	a4,88(s1)
  log_write(bp);
    800036ac:	7f9000ef          	jal	800046a4 <log_write>
  brelse(bp);
    800036b0:	854a                	mv	a0,s2
    800036b2:	eabff0ef          	jal	8000355c <brelse>
}
    800036b6:	60e2                	ld	ra,24(sp)
    800036b8:	6442                	ld	s0,16(sp)
    800036ba:	64a2                	ld	s1,8(sp)
    800036bc:	6902                	ld	s2,0(sp)
    800036be:	6105                	addi	sp,sp,32
    800036c0:	8082                	ret
    panic("freeing free block");
    800036c2:	00005517          	auipc	a0,0x5
    800036c6:	d4e50513          	addi	a0,a0,-690 # 80008410 <etext+0x410>
    800036ca:	948fd0ef          	jal	80000812 <panic>

00000000800036ce <balloc>:
{
    800036ce:	711d                	addi	sp,sp,-96
    800036d0:	ec86                	sd	ra,88(sp)
    800036d2:	e8a2                	sd	s0,80(sp)
    800036d4:	e4a6                	sd	s1,72(sp)
    800036d6:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    800036d8:	0001c797          	auipc	a5,0x1c
    800036dc:	a5c7a783          	lw	a5,-1444(a5) # 8001f134 <sb+0x4>
    800036e0:	0e078f63          	beqz	a5,800037de <balloc+0x110>
    800036e4:	e0ca                	sd	s2,64(sp)
    800036e6:	fc4e                	sd	s3,56(sp)
    800036e8:	f852                	sd	s4,48(sp)
    800036ea:	f456                	sd	s5,40(sp)
    800036ec:	f05a                	sd	s6,32(sp)
    800036ee:	ec5e                	sd	s7,24(sp)
    800036f0:	e862                	sd	s8,16(sp)
    800036f2:	e466                	sd	s9,8(sp)
    800036f4:	8baa                	mv	s7,a0
    800036f6:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    800036f8:	0001cb17          	auipc	s6,0x1c
    800036fc:	a38b0b13          	addi	s6,s6,-1480 # 8001f130 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003700:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    80003702:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003704:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    80003706:	6c89                	lui	s9,0x2
    80003708:	a0b5                	j	80003774 <balloc+0xa6>
        bp->data[bi/8] |= m;  // Mark block in use.
    8000370a:	97ca                	add	a5,a5,s2
    8000370c:	8e55                	or	a2,a2,a3
    8000370e:	04c78c23          	sb	a2,88(a5)
        log_write(bp);
    80003712:	854a                	mv	a0,s2
    80003714:	791000ef          	jal	800046a4 <log_write>
        brelse(bp);
    80003718:	854a                	mv	a0,s2
    8000371a:	e43ff0ef          	jal	8000355c <brelse>
  bp = bread(dev, bno);
    8000371e:	85a6                	mv	a1,s1
    80003720:	855e                	mv	a0,s7
    80003722:	d0bff0ef          	jal	8000342c <bread>
    80003726:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    80003728:	40000613          	li	a2,1024
    8000372c:	4581                	li	a1,0
    8000372e:	05850513          	addi	a0,a0,88
    80003732:	e5efd0ef          	jal	80000d90 <memset>
  log_write(bp);
    80003736:	854a                	mv	a0,s2
    80003738:	76d000ef          	jal	800046a4 <log_write>
  brelse(bp);
    8000373c:	854a                	mv	a0,s2
    8000373e:	e1fff0ef          	jal	8000355c <brelse>
}
    80003742:	6906                	ld	s2,64(sp)
    80003744:	79e2                	ld	s3,56(sp)
    80003746:	7a42                	ld	s4,48(sp)
    80003748:	7aa2                	ld	s5,40(sp)
    8000374a:	7b02                	ld	s6,32(sp)
    8000374c:	6be2                	ld	s7,24(sp)
    8000374e:	6c42                	ld	s8,16(sp)
    80003750:	6ca2                	ld	s9,8(sp)
}
    80003752:	8526                	mv	a0,s1
    80003754:	60e6                	ld	ra,88(sp)
    80003756:	6446                	ld	s0,80(sp)
    80003758:	64a6                	ld	s1,72(sp)
    8000375a:	6125                	addi	sp,sp,96
    8000375c:	8082                	ret
    brelse(bp);
    8000375e:	854a                	mv	a0,s2
    80003760:	dfdff0ef          	jal	8000355c <brelse>
  for(b = 0; b < sb.size; b += BPB){
    80003764:	015c87bb          	addw	a5,s9,s5
    80003768:	00078a9b          	sext.w	s5,a5
    8000376c:	004b2703          	lw	a4,4(s6)
    80003770:	04eaff63          	bgeu	s5,a4,800037ce <balloc+0x100>
    bp = bread(dev, BBLOCK(b, sb));
    80003774:	41fad79b          	sraiw	a5,s5,0x1f
    80003778:	0137d79b          	srliw	a5,a5,0x13
    8000377c:	015787bb          	addw	a5,a5,s5
    80003780:	40d7d79b          	sraiw	a5,a5,0xd
    80003784:	01cb2583          	lw	a1,28(s6)
    80003788:	9dbd                	addw	a1,a1,a5
    8000378a:	855e                	mv	a0,s7
    8000378c:	ca1ff0ef          	jal	8000342c <bread>
    80003790:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003792:	004b2503          	lw	a0,4(s6)
    80003796:	000a849b          	sext.w	s1,s5
    8000379a:	8762                	mv	a4,s8
    8000379c:	fca4f1e3          	bgeu	s1,a0,8000375e <balloc+0x90>
      m = 1 << (bi % 8);
    800037a0:	00777693          	andi	a3,a4,7
    800037a4:	00d996bb          	sllw	a3,s3,a3
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    800037a8:	41f7579b          	sraiw	a5,a4,0x1f
    800037ac:	01d7d79b          	srliw	a5,a5,0x1d
    800037b0:	9fb9                	addw	a5,a5,a4
    800037b2:	4037d79b          	sraiw	a5,a5,0x3
    800037b6:	00f90633          	add	a2,s2,a5
    800037ba:	05864603          	lbu	a2,88(a2)
    800037be:	00c6f5b3          	and	a1,a3,a2
    800037c2:	d5a1                	beqz	a1,8000370a <balloc+0x3c>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800037c4:	2705                	addiw	a4,a4,1
    800037c6:	2485                	addiw	s1,s1,1
    800037c8:	fd471ae3          	bne	a4,s4,8000379c <balloc+0xce>
    800037cc:	bf49                	j	8000375e <balloc+0x90>
    800037ce:	6906                	ld	s2,64(sp)
    800037d0:	79e2                	ld	s3,56(sp)
    800037d2:	7a42                	ld	s4,48(sp)
    800037d4:	7aa2                	ld	s5,40(sp)
    800037d6:	7b02                	ld	s6,32(sp)
    800037d8:	6be2                	ld	s7,24(sp)
    800037da:	6c42                	ld	s8,16(sp)
    800037dc:	6ca2                	ld	s9,8(sp)
  printf("balloc: out of blocks\n");
    800037de:	00005517          	auipc	a0,0x5
    800037e2:	c4a50513          	addi	a0,a0,-950 # 80008428 <etext+0x428>
    800037e6:	d47fc0ef          	jal	8000052c <printf>
  return 0;
    800037ea:	4481                	li	s1,0
    800037ec:	b79d                	j	80003752 <balloc+0x84>

00000000800037ee <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    800037ee:	7179                	addi	sp,sp,-48
    800037f0:	f406                	sd	ra,40(sp)
    800037f2:	f022                	sd	s0,32(sp)
    800037f4:	ec26                	sd	s1,24(sp)
    800037f6:	e84a                	sd	s2,16(sp)
    800037f8:	e44e                	sd	s3,8(sp)
    800037fa:	1800                	addi	s0,sp,48
    800037fc:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    800037fe:	47ad                	li	a5,11
    80003800:	02b7e663          	bltu	a5,a1,8000382c <bmap+0x3e>
    if((addr = ip->addrs[bn]) == 0){
    80003804:	02059793          	slli	a5,a1,0x20
    80003808:	01e7d593          	srli	a1,a5,0x1e
    8000380c:	00b504b3          	add	s1,a0,a1
    80003810:	0504a903          	lw	s2,80(s1)
    80003814:	06091a63          	bnez	s2,80003888 <bmap+0x9a>
      addr = balloc(ip->dev);
    80003818:	4108                	lw	a0,0(a0)
    8000381a:	eb5ff0ef          	jal	800036ce <balloc>
    8000381e:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    80003822:	06090363          	beqz	s2,80003888 <bmap+0x9a>
        return 0;
      ip->addrs[bn] = addr;
    80003826:	0524a823          	sw	s2,80(s1)
    8000382a:	a8b9                	j	80003888 <bmap+0x9a>
    }
    return addr;
  }
  bn -= NDIRECT;
    8000382c:	ff45849b          	addiw	s1,a1,-12
    80003830:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    80003834:	0ff00793          	li	a5,255
    80003838:	06e7ee63          	bltu	a5,a4,800038b4 <bmap+0xc6>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    8000383c:	08052903          	lw	s2,128(a0)
    80003840:	00091d63          	bnez	s2,8000385a <bmap+0x6c>
      addr = balloc(ip->dev);
    80003844:	4108                	lw	a0,0(a0)
    80003846:	e89ff0ef          	jal	800036ce <balloc>
    8000384a:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    8000384e:	02090d63          	beqz	s2,80003888 <bmap+0x9a>
    80003852:	e052                	sd	s4,0(sp)
        return 0;
      ip->addrs[NDIRECT] = addr;
    80003854:	0929a023          	sw	s2,128(s3)
    80003858:	a011                	j	8000385c <bmap+0x6e>
    8000385a:	e052                	sd	s4,0(sp)
    }
    bp = bread(ip->dev, addr);
    8000385c:	85ca                	mv	a1,s2
    8000385e:	0009a503          	lw	a0,0(s3)
    80003862:	bcbff0ef          	jal	8000342c <bread>
    80003866:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    80003868:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    8000386c:	02049713          	slli	a4,s1,0x20
    80003870:	01e75593          	srli	a1,a4,0x1e
    80003874:	00b784b3          	add	s1,a5,a1
    80003878:	0004a903          	lw	s2,0(s1)
    8000387c:	00090e63          	beqz	s2,80003898 <bmap+0xaa>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    80003880:	8552                	mv	a0,s4
    80003882:	cdbff0ef          	jal	8000355c <brelse>
    return addr;
    80003886:	6a02                	ld	s4,0(sp)
  }

  panic("bmap: out of range");
}
    80003888:	854a                	mv	a0,s2
    8000388a:	70a2                	ld	ra,40(sp)
    8000388c:	7402                	ld	s0,32(sp)
    8000388e:	64e2                	ld	s1,24(sp)
    80003890:	6942                	ld	s2,16(sp)
    80003892:	69a2                	ld	s3,8(sp)
    80003894:	6145                	addi	sp,sp,48
    80003896:	8082                	ret
      addr = balloc(ip->dev);
    80003898:	0009a503          	lw	a0,0(s3)
    8000389c:	e33ff0ef          	jal	800036ce <balloc>
    800038a0:	0005091b          	sext.w	s2,a0
      if(addr){
    800038a4:	fc090ee3          	beqz	s2,80003880 <bmap+0x92>
        a[bn] = addr;
    800038a8:	0124a023          	sw	s2,0(s1)
        log_write(bp);
    800038ac:	8552                	mv	a0,s4
    800038ae:	5f7000ef          	jal	800046a4 <log_write>
    800038b2:	b7f9                	j	80003880 <bmap+0x92>
    800038b4:	e052                	sd	s4,0(sp)
  panic("bmap: out of range");
    800038b6:	00005517          	auipc	a0,0x5
    800038ba:	b8a50513          	addi	a0,a0,-1142 # 80008440 <etext+0x440>
    800038be:	f55fc0ef          	jal	80000812 <panic>

00000000800038c2 <iget>:
{
    800038c2:	7179                	addi	sp,sp,-48
    800038c4:	f406                	sd	ra,40(sp)
    800038c6:	f022                	sd	s0,32(sp)
    800038c8:	ec26                	sd	s1,24(sp)
    800038ca:	e84a                	sd	s2,16(sp)
    800038cc:	e44e                	sd	s3,8(sp)
    800038ce:	e052                	sd	s4,0(sp)
    800038d0:	1800                	addi	s0,sp,48
    800038d2:	89aa                	mv	s3,a0
    800038d4:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    800038d6:	0001c517          	auipc	a0,0x1c
    800038da:	87a50513          	addi	a0,a0,-1926 # 8001f150 <itable>
    800038de:	bdefd0ef          	jal	80000cbc <acquire>
  empty = 0;
    800038e2:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    800038e4:	0001c497          	auipc	s1,0x1c
    800038e8:	88448493          	addi	s1,s1,-1916 # 8001f168 <itable+0x18>
    800038ec:	0001d697          	auipc	a3,0x1d
    800038f0:	30c68693          	addi	a3,a3,780 # 80020bf8 <log>
    800038f4:	a039                	j	80003902 <iget+0x40>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    800038f6:	02090963          	beqz	s2,80003928 <iget+0x66>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    800038fa:	08848493          	addi	s1,s1,136
    800038fe:	02d48863          	beq	s1,a3,8000392e <iget+0x6c>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    80003902:	449c                	lw	a5,8(s1)
    80003904:	fef059e3          	blez	a5,800038f6 <iget+0x34>
    80003908:	4098                	lw	a4,0(s1)
    8000390a:	ff3716e3          	bne	a4,s3,800038f6 <iget+0x34>
    8000390e:	40d8                	lw	a4,4(s1)
    80003910:	ff4713e3          	bne	a4,s4,800038f6 <iget+0x34>
      ip->ref++;
    80003914:	2785                	addiw	a5,a5,1
    80003916:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    80003918:	0001c517          	auipc	a0,0x1c
    8000391c:	83850513          	addi	a0,a0,-1992 # 8001f150 <itable>
    80003920:	c34fd0ef          	jal	80000d54 <release>
      return ip;
    80003924:	8926                	mv	s2,s1
    80003926:	a02d                	j	80003950 <iget+0x8e>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003928:	fbe9                	bnez	a5,800038fa <iget+0x38>
      empty = ip;
    8000392a:	8926                	mv	s2,s1
    8000392c:	b7f9                	j	800038fa <iget+0x38>
  if(empty == 0)
    8000392e:	02090a63          	beqz	s2,80003962 <iget+0xa0>
  ip->dev = dev;
    80003932:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    80003936:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    8000393a:	4785                	li	a5,1
    8000393c:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    80003940:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    80003944:	0001c517          	auipc	a0,0x1c
    80003948:	80c50513          	addi	a0,a0,-2036 # 8001f150 <itable>
    8000394c:	c08fd0ef          	jal	80000d54 <release>
}
    80003950:	854a                	mv	a0,s2
    80003952:	70a2                	ld	ra,40(sp)
    80003954:	7402                	ld	s0,32(sp)
    80003956:	64e2                	ld	s1,24(sp)
    80003958:	6942                	ld	s2,16(sp)
    8000395a:	69a2                	ld	s3,8(sp)
    8000395c:	6a02                	ld	s4,0(sp)
    8000395e:	6145                	addi	sp,sp,48
    80003960:	8082                	ret
    panic("iget: no inodes");
    80003962:	00005517          	auipc	a0,0x5
    80003966:	af650513          	addi	a0,a0,-1290 # 80008458 <etext+0x458>
    8000396a:	ea9fc0ef          	jal	80000812 <panic>

000000008000396e <iinit>:
{
    8000396e:	7179                	addi	sp,sp,-48
    80003970:	f406                	sd	ra,40(sp)
    80003972:	f022                	sd	s0,32(sp)
    80003974:	ec26                	sd	s1,24(sp)
    80003976:	e84a                	sd	s2,16(sp)
    80003978:	e44e                	sd	s3,8(sp)
    8000397a:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    8000397c:	00005597          	auipc	a1,0x5
    80003980:	aec58593          	addi	a1,a1,-1300 # 80008468 <etext+0x468>
    80003984:	0001b517          	auipc	a0,0x1b
    80003988:	7cc50513          	addi	a0,a0,1996 # 8001f150 <itable>
    8000398c:	ab0fd0ef          	jal	80000c3c <initlock>
  for(i = 0; i < NINODE; i++) {
    80003990:	0001b497          	auipc	s1,0x1b
    80003994:	7e848493          	addi	s1,s1,2024 # 8001f178 <itable+0x28>
    80003998:	0001d997          	auipc	s3,0x1d
    8000399c:	27098993          	addi	s3,s3,624 # 80020c08 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    800039a0:	00005917          	auipc	s2,0x5
    800039a4:	ad090913          	addi	s2,s2,-1328 # 80008470 <etext+0x470>
    800039a8:	85ca                	mv	a1,s2
    800039aa:	8526                	mv	a0,s1
    800039ac:	5bb000ef          	jal	80004766 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    800039b0:	08848493          	addi	s1,s1,136
    800039b4:	ff349ae3          	bne	s1,s3,800039a8 <iinit+0x3a>
}
    800039b8:	70a2                	ld	ra,40(sp)
    800039ba:	7402                	ld	s0,32(sp)
    800039bc:	64e2                	ld	s1,24(sp)
    800039be:	6942                	ld	s2,16(sp)
    800039c0:	69a2                	ld	s3,8(sp)
    800039c2:	6145                	addi	sp,sp,48
    800039c4:	8082                	ret

00000000800039c6 <ialloc>:
{
    800039c6:	7139                	addi	sp,sp,-64
    800039c8:	fc06                	sd	ra,56(sp)
    800039ca:	f822                	sd	s0,48(sp)
    800039cc:	0080                	addi	s0,sp,64
  for(inum = 1; inum < sb.ninodes; inum++){
    800039ce:	0001b717          	auipc	a4,0x1b
    800039d2:	76e72703          	lw	a4,1902(a4) # 8001f13c <sb+0xc>
    800039d6:	4785                	li	a5,1
    800039d8:	06e7f063          	bgeu	a5,a4,80003a38 <ialloc+0x72>
    800039dc:	f426                	sd	s1,40(sp)
    800039de:	f04a                	sd	s2,32(sp)
    800039e0:	ec4e                	sd	s3,24(sp)
    800039e2:	e852                	sd	s4,16(sp)
    800039e4:	e456                	sd	s5,8(sp)
    800039e6:	e05a                	sd	s6,0(sp)
    800039e8:	8aaa                	mv	s5,a0
    800039ea:	8b2e                	mv	s6,a1
    800039ec:	4905                	li	s2,1
    bp = bread(dev, IBLOCK(inum, sb));
    800039ee:	0001ba17          	auipc	s4,0x1b
    800039f2:	742a0a13          	addi	s4,s4,1858 # 8001f130 <sb>
    800039f6:	00495593          	srli	a1,s2,0x4
    800039fa:	018a2783          	lw	a5,24(s4)
    800039fe:	9dbd                	addw	a1,a1,a5
    80003a00:	8556                	mv	a0,s5
    80003a02:	a2bff0ef          	jal	8000342c <bread>
    80003a06:	84aa                	mv	s1,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    80003a08:	05850993          	addi	s3,a0,88
    80003a0c:	00f97793          	andi	a5,s2,15
    80003a10:	079a                	slli	a5,a5,0x6
    80003a12:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    80003a14:	00099783          	lh	a5,0(s3)
    80003a18:	cb9d                	beqz	a5,80003a4e <ialloc+0x88>
    brelse(bp);
    80003a1a:	b43ff0ef          	jal	8000355c <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    80003a1e:	0905                	addi	s2,s2,1
    80003a20:	00ca2703          	lw	a4,12(s4)
    80003a24:	0009079b          	sext.w	a5,s2
    80003a28:	fce7e7e3          	bltu	a5,a4,800039f6 <ialloc+0x30>
    80003a2c:	74a2                	ld	s1,40(sp)
    80003a2e:	7902                	ld	s2,32(sp)
    80003a30:	69e2                	ld	s3,24(sp)
    80003a32:	6a42                	ld	s4,16(sp)
    80003a34:	6aa2                	ld	s5,8(sp)
    80003a36:	6b02                	ld	s6,0(sp)
  printf("ialloc: no inodes\n");
    80003a38:	00005517          	auipc	a0,0x5
    80003a3c:	a4050513          	addi	a0,a0,-1472 # 80008478 <etext+0x478>
    80003a40:	aedfc0ef          	jal	8000052c <printf>
  return 0;
    80003a44:	4501                	li	a0,0
}
    80003a46:	70e2                	ld	ra,56(sp)
    80003a48:	7442                	ld	s0,48(sp)
    80003a4a:	6121                	addi	sp,sp,64
    80003a4c:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    80003a4e:	04000613          	li	a2,64
    80003a52:	4581                	li	a1,0
    80003a54:	854e                	mv	a0,s3
    80003a56:	b3afd0ef          	jal	80000d90 <memset>
      dip->type = type;
    80003a5a:	01699023          	sh	s6,0(s3)
      log_write(bp);   // mark it allocated on the disk
    80003a5e:	8526                	mv	a0,s1
    80003a60:	445000ef          	jal	800046a4 <log_write>
      brelse(bp);
    80003a64:	8526                	mv	a0,s1
    80003a66:	af7ff0ef          	jal	8000355c <brelse>
      return iget(dev, inum);
    80003a6a:	0009059b          	sext.w	a1,s2
    80003a6e:	8556                	mv	a0,s5
    80003a70:	e53ff0ef          	jal	800038c2 <iget>
    80003a74:	74a2                	ld	s1,40(sp)
    80003a76:	7902                	ld	s2,32(sp)
    80003a78:	69e2                	ld	s3,24(sp)
    80003a7a:	6a42                	ld	s4,16(sp)
    80003a7c:	6aa2                	ld	s5,8(sp)
    80003a7e:	6b02                	ld	s6,0(sp)
    80003a80:	b7d9                	j	80003a46 <ialloc+0x80>

0000000080003a82 <iupdate>:
{
    80003a82:	1101                	addi	sp,sp,-32
    80003a84:	ec06                	sd	ra,24(sp)
    80003a86:	e822                	sd	s0,16(sp)
    80003a88:	e426                	sd	s1,8(sp)
    80003a8a:	e04a                	sd	s2,0(sp)
    80003a8c:	1000                	addi	s0,sp,32
    80003a8e:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003a90:	415c                	lw	a5,4(a0)
    80003a92:	0047d79b          	srliw	a5,a5,0x4
    80003a96:	0001b597          	auipc	a1,0x1b
    80003a9a:	6b25a583          	lw	a1,1714(a1) # 8001f148 <sb+0x18>
    80003a9e:	9dbd                	addw	a1,a1,a5
    80003aa0:	4108                	lw	a0,0(a0)
    80003aa2:	98bff0ef          	jal	8000342c <bread>
    80003aa6:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003aa8:	05850793          	addi	a5,a0,88
    80003aac:	40d8                	lw	a4,4(s1)
    80003aae:	8b3d                	andi	a4,a4,15
    80003ab0:	071a                	slli	a4,a4,0x6
    80003ab2:	97ba                	add	a5,a5,a4
  dip->type = ip->type;
    80003ab4:	04449703          	lh	a4,68(s1)
    80003ab8:	00e79023          	sh	a4,0(a5)
  dip->major = ip->major;
    80003abc:	04649703          	lh	a4,70(s1)
    80003ac0:	00e79123          	sh	a4,2(a5)
  dip->minor = ip->minor;
    80003ac4:	04849703          	lh	a4,72(s1)
    80003ac8:	00e79223          	sh	a4,4(a5)
  dip->nlink = ip->nlink;
    80003acc:	04a49703          	lh	a4,74(s1)
    80003ad0:	00e79323          	sh	a4,6(a5)
  dip->size = ip->size;
    80003ad4:	44f8                	lw	a4,76(s1)
    80003ad6:	c798                	sw	a4,8(a5)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80003ad8:	03400613          	li	a2,52
    80003adc:	05048593          	addi	a1,s1,80
    80003ae0:	00c78513          	addi	a0,a5,12
    80003ae4:	b08fd0ef          	jal	80000dec <memmove>
  log_write(bp);
    80003ae8:	854a                	mv	a0,s2
    80003aea:	3bb000ef          	jal	800046a4 <log_write>
  brelse(bp);
    80003aee:	854a                	mv	a0,s2
    80003af0:	a6dff0ef          	jal	8000355c <brelse>
}
    80003af4:	60e2                	ld	ra,24(sp)
    80003af6:	6442                	ld	s0,16(sp)
    80003af8:	64a2                	ld	s1,8(sp)
    80003afa:	6902                	ld	s2,0(sp)
    80003afc:	6105                	addi	sp,sp,32
    80003afe:	8082                	ret

0000000080003b00 <idup>:
{
    80003b00:	1101                	addi	sp,sp,-32
    80003b02:	ec06                	sd	ra,24(sp)
    80003b04:	e822                	sd	s0,16(sp)
    80003b06:	e426                	sd	s1,8(sp)
    80003b08:	1000                	addi	s0,sp,32
    80003b0a:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003b0c:	0001b517          	auipc	a0,0x1b
    80003b10:	64450513          	addi	a0,a0,1604 # 8001f150 <itable>
    80003b14:	9a8fd0ef          	jal	80000cbc <acquire>
  ip->ref++;
    80003b18:	449c                	lw	a5,8(s1)
    80003b1a:	2785                	addiw	a5,a5,1
    80003b1c:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003b1e:	0001b517          	auipc	a0,0x1b
    80003b22:	63250513          	addi	a0,a0,1586 # 8001f150 <itable>
    80003b26:	a2efd0ef          	jal	80000d54 <release>
}
    80003b2a:	8526                	mv	a0,s1
    80003b2c:	60e2                	ld	ra,24(sp)
    80003b2e:	6442                	ld	s0,16(sp)
    80003b30:	64a2                	ld	s1,8(sp)
    80003b32:	6105                	addi	sp,sp,32
    80003b34:	8082                	ret

0000000080003b36 <ilock>:
{
    80003b36:	1101                	addi	sp,sp,-32
    80003b38:	ec06                	sd	ra,24(sp)
    80003b3a:	e822                	sd	s0,16(sp)
    80003b3c:	e426                	sd	s1,8(sp)
    80003b3e:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    80003b40:	cd19                	beqz	a0,80003b5e <ilock+0x28>
    80003b42:	84aa                	mv	s1,a0
    80003b44:	451c                	lw	a5,8(a0)
    80003b46:	00f05c63          	blez	a5,80003b5e <ilock+0x28>
  acquiresleep(&ip->lock);
    80003b4a:	0541                	addi	a0,a0,16
    80003b4c:	451000ef          	jal	8000479c <acquiresleep>
  if(ip->valid == 0){
    80003b50:	40bc                	lw	a5,64(s1)
    80003b52:	cf89                	beqz	a5,80003b6c <ilock+0x36>
}
    80003b54:	60e2                	ld	ra,24(sp)
    80003b56:	6442                	ld	s0,16(sp)
    80003b58:	64a2                	ld	s1,8(sp)
    80003b5a:	6105                	addi	sp,sp,32
    80003b5c:	8082                	ret
    80003b5e:	e04a                	sd	s2,0(sp)
    panic("ilock");
    80003b60:	00005517          	auipc	a0,0x5
    80003b64:	93050513          	addi	a0,a0,-1744 # 80008490 <etext+0x490>
    80003b68:	cabfc0ef          	jal	80000812 <panic>
    80003b6c:	e04a                	sd	s2,0(sp)
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003b6e:	40dc                	lw	a5,4(s1)
    80003b70:	0047d79b          	srliw	a5,a5,0x4
    80003b74:	0001b597          	auipc	a1,0x1b
    80003b78:	5d45a583          	lw	a1,1492(a1) # 8001f148 <sb+0x18>
    80003b7c:	9dbd                	addw	a1,a1,a5
    80003b7e:	4088                	lw	a0,0(s1)
    80003b80:	8adff0ef          	jal	8000342c <bread>
    80003b84:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003b86:	05850593          	addi	a1,a0,88
    80003b8a:	40dc                	lw	a5,4(s1)
    80003b8c:	8bbd                	andi	a5,a5,15
    80003b8e:	079a                	slli	a5,a5,0x6
    80003b90:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    80003b92:	00059783          	lh	a5,0(a1)
    80003b96:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    80003b9a:	00259783          	lh	a5,2(a1)
    80003b9e:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    80003ba2:	00459783          	lh	a5,4(a1)
    80003ba6:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80003baa:	00659783          	lh	a5,6(a1)
    80003bae:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    80003bb2:	459c                	lw	a5,8(a1)
    80003bb4:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80003bb6:	03400613          	li	a2,52
    80003bba:	05b1                	addi	a1,a1,12
    80003bbc:	05048513          	addi	a0,s1,80
    80003bc0:	a2cfd0ef          	jal	80000dec <memmove>
    brelse(bp);
    80003bc4:	854a                	mv	a0,s2
    80003bc6:	997ff0ef          	jal	8000355c <brelse>
    ip->valid = 1;
    80003bca:	4785                	li	a5,1
    80003bcc:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    80003bce:	04449783          	lh	a5,68(s1)
    80003bd2:	c399                	beqz	a5,80003bd8 <ilock+0xa2>
    80003bd4:	6902                	ld	s2,0(sp)
    80003bd6:	bfbd                	j	80003b54 <ilock+0x1e>
      panic("ilock: no type");
    80003bd8:	00005517          	auipc	a0,0x5
    80003bdc:	8c050513          	addi	a0,a0,-1856 # 80008498 <etext+0x498>
    80003be0:	c33fc0ef          	jal	80000812 <panic>

0000000080003be4 <iunlock>:
{
    80003be4:	1101                	addi	sp,sp,-32
    80003be6:	ec06                	sd	ra,24(sp)
    80003be8:	e822                	sd	s0,16(sp)
    80003bea:	e426                	sd	s1,8(sp)
    80003bec:	e04a                	sd	s2,0(sp)
    80003bee:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80003bf0:	c505                	beqz	a0,80003c18 <iunlock+0x34>
    80003bf2:	84aa                	mv	s1,a0
    80003bf4:	01050913          	addi	s2,a0,16
    80003bf8:	854a                	mv	a0,s2
    80003bfa:	421000ef          	jal	8000481a <holdingsleep>
    80003bfe:	cd09                	beqz	a0,80003c18 <iunlock+0x34>
    80003c00:	449c                	lw	a5,8(s1)
    80003c02:	00f05b63          	blez	a5,80003c18 <iunlock+0x34>
  releasesleep(&ip->lock);
    80003c06:	854a                	mv	a0,s2
    80003c08:	3db000ef          	jal	800047e2 <releasesleep>
}
    80003c0c:	60e2                	ld	ra,24(sp)
    80003c0e:	6442                	ld	s0,16(sp)
    80003c10:	64a2                	ld	s1,8(sp)
    80003c12:	6902                	ld	s2,0(sp)
    80003c14:	6105                	addi	sp,sp,32
    80003c16:	8082                	ret
    panic("iunlock");
    80003c18:	00005517          	auipc	a0,0x5
    80003c1c:	89050513          	addi	a0,a0,-1904 # 800084a8 <etext+0x4a8>
    80003c20:	bf3fc0ef          	jal	80000812 <panic>

0000000080003c24 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    80003c24:	7179                	addi	sp,sp,-48
    80003c26:	f406                	sd	ra,40(sp)
    80003c28:	f022                	sd	s0,32(sp)
    80003c2a:	ec26                	sd	s1,24(sp)
    80003c2c:	e84a                	sd	s2,16(sp)
    80003c2e:	e44e                	sd	s3,8(sp)
    80003c30:	1800                	addi	s0,sp,48
    80003c32:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    80003c34:	05050493          	addi	s1,a0,80
    80003c38:	08050913          	addi	s2,a0,128
    80003c3c:	a021                	j	80003c44 <itrunc+0x20>
    80003c3e:	0491                	addi	s1,s1,4
    80003c40:	01248b63          	beq	s1,s2,80003c56 <itrunc+0x32>
    if(ip->addrs[i]){
    80003c44:	408c                	lw	a1,0(s1)
    80003c46:	dde5                	beqz	a1,80003c3e <itrunc+0x1a>
      bfree(ip->dev, ip->addrs[i]);
    80003c48:	0009a503          	lw	a0,0(s3)
    80003c4c:	a17ff0ef          	jal	80003662 <bfree>
      ip->addrs[i] = 0;
    80003c50:	0004a023          	sw	zero,0(s1)
    80003c54:	b7ed                	j	80003c3e <itrunc+0x1a>
    }
  }

  if(ip->addrs[NDIRECT]){
    80003c56:	0809a583          	lw	a1,128(s3)
    80003c5a:	ed89                	bnez	a1,80003c74 <itrunc+0x50>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80003c5c:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    80003c60:	854e                	mv	a0,s3
    80003c62:	e21ff0ef          	jal	80003a82 <iupdate>
}
    80003c66:	70a2                	ld	ra,40(sp)
    80003c68:	7402                	ld	s0,32(sp)
    80003c6a:	64e2                	ld	s1,24(sp)
    80003c6c:	6942                	ld	s2,16(sp)
    80003c6e:	69a2                	ld	s3,8(sp)
    80003c70:	6145                	addi	sp,sp,48
    80003c72:	8082                	ret
    80003c74:	e052                	sd	s4,0(sp)
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80003c76:	0009a503          	lw	a0,0(s3)
    80003c7a:	fb2ff0ef          	jal	8000342c <bread>
    80003c7e:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    80003c80:	05850493          	addi	s1,a0,88
    80003c84:	45850913          	addi	s2,a0,1112
    80003c88:	a021                	j	80003c90 <itrunc+0x6c>
    80003c8a:	0491                	addi	s1,s1,4
    80003c8c:	01248963          	beq	s1,s2,80003c9e <itrunc+0x7a>
      if(a[j])
    80003c90:	408c                	lw	a1,0(s1)
    80003c92:	dde5                	beqz	a1,80003c8a <itrunc+0x66>
        bfree(ip->dev, a[j]);
    80003c94:	0009a503          	lw	a0,0(s3)
    80003c98:	9cbff0ef          	jal	80003662 <bfree>
    80003c9c:	b7fd                	j	80003c8a <itrunc+0x66>
    brelse(bp);
    80003c9e:	8552                	mv	a0,s4
    80003ca0:	8bdff0ef          	jal	8000355c <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80003ca4:	0809a583          	lw	a1,128(s3)
    80003ca8:	0009a503          	lw	a0,0(s3)
    80003cac:	9b7ff0ef          	jal	80003662 <bfree>
    ip->addrs[NDIRECT] = 0;
    80003cb0:	0809a023          	sw	zero,128(s3)
    80003cb4:	6a02                	ld	s4,0(sp)
    80003cb6:	b75d                	j	80003c5c <itrunc+0x38>

0000000080003cb8 <iput>:
{
    80003cb8:	1101                	addi	sp,sp,-32
    80003cba:	ec06                	sd	ra,24(sp)
    80003cbc:	e822                	sd	s0,16(sp)
    80003cbe:	e426                	sd	s1,8(sp)
    80003cc0:	1000                	addi	s0,sp,32
    80003cc2:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003cc4:	0001b517          	auipc	a0,0x1b
    80003cc8:	48c50513          	addi	a0,a0,1164 # 8001f150 <itable>
    80003ccc:	ff1fc0ef          	jal	80000cbc <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003cd0:	4498                	lw	a4,8(s1)
    80003cd2:	4785                	li	a5,1
    80003cd4:	02f70063          	beq	a4,a5,80003cf4 <iput+0x3c>
  ip->ref--;
    80003cd8:	449c                	lw	a5,8(s1)
    80003cda:	37fd                	addiw	a5,a5,-1
    80003cdc:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003cde:	0001b517          	auipc	a0,0x1b
    80003ce2:	47250513          	addi	a0,a0,1138 # 8001f150 <itable>
    80003ce6:	86efd0ef          	jal	80000d54 <release>
}
    80003cea:	60e2                	ld	ra,24(sp)
    80003cec:	6442                	ld	s0,16(sp)
    80003cee:	64a2                	ld	s1,8(sp)
    80003cf0:	6105                	addi	sp,sp,32
    80003cf2:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003cf4:	40bc                	lw	a5,64(s1)
    80003cf6:	d3ed                	beqz	a5,80003cd8 <iput+0x20>
    80003cf8:	04a49783          	lh	a5,74(s1)
    80003cfc:	fff1                	bnez	a5,80003cd8 <iput+0x20>
    80003cfe:	e04a                	sd	s2,0(sp)
    acquiresleep(&ip->lock);
    80003d00:	01048913          	addi	s2,s1,16
    80003d04:	854a                	mv	a0,s2
    80003d06:	297000ef          	jal	8000479c <acquiresleep>
    release(&itable.lock);
    80003d0a:	0001b517          	auipc	a0,0x1b
    80003d0e:	44650513          	addi	a0,a0,1094 # 8001f150 <itable>
    80003d12:	842fd0ef          	jal	80000d54 <release>
    itrunc(ip);
    80003d16:	8526                	mv	a0,s1
    80003d18:	f0dff0ef          	jal	80003c24 <itrunc>
    ip->type = 0;
    80003d1c:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    80003d20:	8526                	mv	a0,s1
    80003d22:	d61ff0ef          	jal	80003a82 <iupdate>
    ip->valid = 0;
    80003d26:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80003d2a:	854a                	mv	a0,s2
    80003d2c:	2b7000ef          	jal	800047e2 <releasesleep>
    acquire(&itable.lock);
    80003d30:	0001b517          	auipc	a0,0x1b
    80003d34:	42050513          	addi	a0,a0,1056 # 8001f150 <itable>
    80003d38:	f85fc0ef          	jal	80000cbc <acquire>
    80003d3c:	6902                	ld	s2,0(sp)
    80003d3e:	bf69                	j	80003cd8 <iput+0x20>

0000000080003d40 <iunlockput>:
{
    80003d40:	1101                	addi	sp,sp,-32
    80003d42:	ec06                	sd	ra,24(sp)
    80003d44:	e822                	sd	s0,16(sp)
    80003d46:	e426                	sd	s1,8(sp)
    80003d48:	1000                	addi	s0,sp,32
    80003d4a:	84aa                	mv	s1,a0
  iunlock(ip);
    80003d4c:	e99ff0ef          	jal	80003be4 <iunlock>
  iput(ip);
    80003d50:	8526                	mv	a0,s1
    80003d52:	f67ff0ef          	jal	80003cb8 <iput>
}
    80003d56:	60e2                	ld	ra,24(sp)
    80003d58:	6442                	ld	s0,16(sp)
    80003d5a:	64a2                	ld	s1,8(sp)
    80003d5c:	6105                	addi	sp,sp,32
    80003d5e:	8082                	ret

0000000080003d60 <ireclaim>:
  for (int inum = 1; inum < sb.ninodes; inum++) {
    80003d60:	0001b717          	auipc	a4,0x1b
    80003d64:	3dc72703          	lw	a4,988(a4) # 8001f13c <sb+0xc>
    80003d68:	4785                	li	a5,1
    80003d6a:	0ae7ff63          	bgeu	a5,a4,80003e28 <ireclaim+0xc8>
{
    80003d6e:	7139                	addi	sp,sp,-64
    80003d70:	fc06                	sd	ra,56(sp)
    80003d72:	f822                	sd	s0,48(sp)
    80003d74:	f426                	sd	s1,40(sp)
    80003d76:	f04a                	sd	s2,32(sp)
    80003d78:	ec4e                	sd	s3,24(sp)
    80003d7a:	e852                	sd	s4,16(sp)
    80003d7c:	e456                	sd	s5,8(sp)
    80003d7e:	e05a                	sd	s6,0(sp)
    80003d80:	0080                	addi	s0,sp,64
  for (int inum = 1; inum < sb.ninodes; inum++) {
    80003d82:	4485                	li	s1,1
    struct buf *bp = bread(dev, IBLOCK(inum, sb));
    80003d84:	00050a1b          	sext.w	s4,a0
    80003d88:	0001ba97          	auipc	s5,0x1b
    80003d8c:	3a8a8a93          	addi	s5,s5,936 # 8001f130 <sb>
      printf("ireclaim: orphaned inode %d\n", inum);
    80003d90:	00004b17          	auipc	s6,0x4
    80003d94:	720b0b13          	addi	s6,s6,1824 # 800084b0 <etext+0x4b0>
    80003d98:	a099                	j	80003dde <ireclaim+0x7e>
    80003d9a:	85ce                	mv	a1,s3
    80003d9c:	855a                	mv	a0,s6
    80003d9e:	f8efc0ef          	jal	8000052c <printf>
      ip = iget(dev, inum);
    80003da2:	85ce                	mv	a1,s3
    80003da4:	8552                	mv	a0,s4
    80003da6:	b1dff0ef          	jal	800038c2 <iget>
    80003daa:	89aa                	mv	s3,a0
    brelse(bp);
    80003dac:	854a                	mv	a0,s2
    80003dae:	faeff0ef          	jal	8000355c <brelse>
    if (ip) {
    80003db2:	00098f63          	beqz	s3,80003dd0 <ireclaim+0x70>
      begin_op();
    80003db6:	76a000ef          	jal	80004520 <begin_op>
      ilock(ip);
    80003dba:	854e                	mv	a0,s3
    80003dbc:	d7bff0ef          	jal	80003b36 <ilock>
      iunlock(ip);
    80003dc0:	854e                	mv	a0,s3
    80003dc2:	e23ff0ef          	jal	80003be4 <iunlock>
      iput(ip);
    80003dc6:	854e                	mv	a0,s3
    80003dc8:	ef1ff0ef          	jal	80003cb8 <iput>
      end_op();
    80003dcc:	7be000ef          	jal	8000458a <end_op>
  for (int inum = 1; inum < sb.ninodes; inum++) {
    80003dd0:	0485                	addi	s1,s1,1
    80003dd2:	00caa703          	lw	a4,12(s5)
    80003dd6:	0004879b          	sext.w	a5,s1
    80003dda:	02e7fd63          	bgeu	a5,a4,80003e14 <ireclaim+0xb4>
    80003dde:	0004899b          	sext.w	s3,s1
    struct buf *bp = bread(dev, IBLOCK(inum, sb));
    80003de2:	0044d593          	srli	a1,s1,0x4
    80003de6:	018aa783          	lw	a5,24(s5)
    80003dea:	9dbd                	addw	a1,a1,a5
    80003dec:	8552                	mv	a0,s4
    80003dee:	e3eff0ef          	jal	8000342c <bread>
    80003df2:	892a                	mv	s2,a0
    struct dinode *dip = (struct dinode *)bp->data + inum % IPB;
    80003df4:	05850793          	addi	a5,a0,88
    80003df8:	00f9f713          	andi	a4,s3,15
    80003dfc:	071a                	slli	a4,a4,0x6
    80003dfe:	97ba                	add	a5,a5,a4
    if (dip->type != 0 && dip->nlink == 0) {  // is an orphaned inode
    80003e00:	00079703          	lh	a4,0(a5)
    80003e04:	c701                	beqz	a4,80003e0c <ireclaim+0xac>
    80003e06:	00679783          	lh	a5,6(a5)
    80003e0a:	dbc1                	beqz	a5,80003d9a <ireclaim+0x3a>
    brelse(bp);
    80003e0c:	854a                	mv	a0,s2
    80003e0e:	f4eff0ef          	jal	8000355c <brelse>
    if (ip) {
    80003e12:	bf7d                	j	80003dd0 <ireclaim+0x70>
}
    80003e14:	70e2                	ld	ra,56(sp)
    80003e16:	7442                	ld	s0,48(sp)
    80003e18:	74a2                	ld	s1,40(sp)
    80003e1a:	7902                	ld	s2,32(sp)
    80003e1c:	69e2                	ld	s3,24(sp)
    80003e1e:	6a42                	ld	s4,16(sp)
    80003e20:	6aa2                	ld	s5,8(sp)
    80003e22:	6b02                	ld	s6,0(sp)
    80003e24:	6121                	addi	sp,sp,64
    80003e26:	8082                	ret
    80003e28:	8082                	ret

0000000080003e2a <fsinit>:
fsinit(int dev) {
    80003e2a:	7179                	addi	sp,sp,-48
    80003e2c:	f406                	sd	ra,40(sp)
    80003e2e:	f022                	sd	s0,32(sp)
    80003e30:	ec26                	sd	s1,24(sp)
    80003e32:	e84a                	sd	s2,16(sp)
    80003e34:	e44e                	sd	s3,8(sp)
    80003e36:	1800                	addi	s0,sp,48
    80003e38:	84aa                	mv	s1,a0
  bp = bread(dev, 1);
    80003e3a:	4585                	li	a1,1
    80003e3c:	df0ff0ef          	jal	8000342c <bread>
    80003e40:	892a                	mv	s2,a0
  memmove(sb, bp->data, sizeof(*sb));
    80003e42:	0001b997          	auipc	s3,0x1b
    80003e46:	2ee98993          	addi	s3,s3,750 # 8001f130 <sb>
    80003e4a:	02000613          	li	a2,32
    80003e4e:	05850593          	addi	a1,a0,88
    80003e52:	854e                	mv	a0,s3
    80003e54:	f99fc0ef          	jal	80000dec <memmove>
  brelse(bp);
    80003e58:	854a                	mv	a0,s2
    80003e5a:	f02ff0ef          	jal	8000355c <brelse>
  if(sb.magic != FSMAGIC)
    80003e5e:	0009a703          	lw	a4,0(s3)
    80003e62:	102037b7          	lui	a5,0x10203
    80003e66:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    80003e6a:	02f71363          	bne	a4,a5,80003e90 <fsinit+0x66>
  initlog(dev, &sb);
    80003e6e:	0001b597          	auipc	a1,0x1b
    80003e72:	2c258593          	addi	a1,a1,706 # 8001f130 <sb>
    80003e76:	8526                	mv	a0,s1
    80003e78:	62a000ef          	jal	800044a2 <initlog>
  ireclaim(dev);
    80003e7c:	8526                	mv	a0,s1
    80003e7e:	ee3ff0ef          	jal	80003d60 <ireclaim>
}
    80003e82:	70a2                	ld	ra,40(sp)
    80003e84:	7402                	ld	s0,32(sp)
    80003e86:	64e2                	ld	s1,24(sp)
    80003e88:	6942                	ld	s2,16(sp)
    80003e8a:	69a2                	ld	s3,8(sp)
    80003e8c:	6145                	addi	sp,sp,48
    80003e8e:	8082                	ret
    panic("invalid file system");
    80003e90:	00004517          	auipc	a0,0x4
    80003e94:	64050513          	addi	a0,a0,1600 # 800084d0 <etext+0x4d0>
    80003e98:	97bfc0ef          	jal	80000812 <panic>

0000000080003e9c <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80003e9c:	1141                	addi	sp,sp,-16
    80003e9e:	e422                	sd	s0,8(sp)
    80003ea0:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80003ea2:	411c                	lw	a5,0(a0)
    80003ea4:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80003ea6:	415c                	lw	a5,4(a0)
    80003ea8:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80003eaa:	04451783          	lh	a5,68(a0)
    80003eae:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80003eb2:	04a51783          	lh	a5,74(a0)
    80003eb6:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80003eba:	04c56783          	lwu	a5,76(a0)
    80003ebe:	e99c                	sd	a5,16(a1)
}
    80003ec0:	6422                	ld	s0,8(sp)
    80003ec2:	0141                	addi	sp,sp,16
    80003ec4:	8082                	ret

0000000080003ec6 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003ec6:	457c                	lw	a5,76(a0)
    80003ec8:	0ed7eb63          	bltu	a5,a3,80003fbe <readi+0xf8>
{
    80003ecc:	7159                	addi	sp,sp,-112
    80003ece:	f486                	sd	ra,104(sp)
    80003ed0:	f0a2                	sd	s0,96(sp)
    80003ed2:	eca6                	sd	s1,88(sp)
    80003ed4:	e0d2                	sd	s4,64(sp)
    80003ed6:	fc56                	sd	s5,56(sp)
    80003ed8:	f85a                	sd	s6,48(sp)
    80003eda:	f45e                	sd	s7,40(sp)
    80003edc:	1880                	addi	s0,sp,112
    80003ede:	8b2a                	mv	s6,a0
    80003ee0:	8bae                	mv	s7,a1
    80003ee2:	8a32                	mv	s4,a2
    80003ee4:	84b6                	mv	s1,a3
    80003ee6:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    80003ee8:	9f35                	addw	a4,a4,a3
    return 0;
    80003eea:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80003eec:	0cd76063          	bltu	a4,a3,80003fac <readi+0xe6>
    80003ef0:	e4ce                	sd	s3,72(sp)
  if(off + n > ip->size)
    80003ef2:	00e7f463          	bgeu	a5,a4,80003efa <readi+0x34>
    n = ip->size - off;
    80003ef6:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003efa:	080a8f63          	beqz	s5,80003f98 <readi+0xd2>
    80003efe:	e8ca                	sd	s2,80(sp)
    80003f00:	f062                	sd	s8,32(sp)
    80003f02:	ec66                	sd	s9,24(sp)
    80003f04:	e86a                	sd	s10,16(sp)
    80003f06:	e46e                	sd	s11,8(sp)
    80003f08:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003f0a:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80003f0e:	5c7d                	li	s8,-1
    80003f10:	a80d                	j	80003f42 <readi+0x7c>
    80003f12:	020d1d93          	slli	s11,s10,0x20
    80003f16:	020ddd93          	srli	s11,s11,0x20
    80003f1a:	05890613          	addi	a2,s2,88
    80003f1e:	86ee                	mv	a3,s11
    80003f20:	963a                	add	a2,a2,a4
    80003f22:	85d2                	mv	a1,s4
    80003f24:	855e                	mv	a0,s7
    80003f26:	9a9fe0ef          	jal	800028ce <either_copyout>
    80003f2a:	05850763          	beq	a0,s8,80003f78 <readi+0xb2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80003f2e:	854a                	mv	a0,s2
    80003f30:	e2cff0ef          	jal	8000355c <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003f34:	013d09bb          	addw	s3,s10,s3
    80003f38:	009d04bb          	addw	s1,s10,s1
    80003f3c:	9a6e                	add	s4,s4,s11
    80003f3e:	0559f763          	bgeu	s3,s5,80003f8c <readi+0xc6>
    uint addr = bmap(ip, off/BSIZE);
    80003f42:	00a4d59b          	srliw	a1,s1,0xa
    80003f46:	855a                	mv	a0,s6
    80003f48:	8a7ff0ef          	jal	800037ee <bmap>
    80003f4c:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80003f50:	c5b1                	beqz	a1,80003f9c <readi+0xd6>
    bp = bread(ip->dev, addr);
    80003f52:	000b2503          	lw	a0,0(s6)
    80003f56:	cd6ff0ef          	jal	8000342c <bread>
    80003f5a:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003f5c:	3ff4f713          	andi	a4,s1,1023
    80003f60:	40ec87bb          	subw	a5,s9,a4
    80003f64:	413a86bb          	subw	a3,s5,s3
    80003f68:	8d3e                	mv	s10,a5
    80003f6a:	2781                	sext.w	a5,a5
    80003f6c:	0006861b          	sext.w	a2,a3
    80003f70:	faf671e3          	bgeu	a2,a5,80003f12 <readi+0x4c>
    80003f74:	8d36                	mv	s10,a3
    80003f76:	bf71                	j	80003f12 <readi+0x4c>
      brelse(bp);
    80003f78:	854a                	mv	a0,s2
    80003f7a:	de2ff0ef          	jal	8000355c <brelse>
      tot = -1;
    80003f7e:	59fd                	li	s3,-1
      break;
    80003f80:	6946                	ld	s2,80(sp)
    80003f82:	7c02                	ld	s8,32(sp)
    80003f84:	6ce2                	ld	s9,24(sp)
    80003f86:	6d42                	ld	s10,16(sp)
    80003f88:	6da2                	ld	s11,8(sp)
    80003f8a:	a831                	j	80003fa6 <readi+0xe0>
    80003f8c:	6946                	ld	s2,80(sp)
    80003f8e:	7c02                	ld	s8,32(sp)
    80003f90:	6ce2                	ld	s9,24(sp)
    80003f92:	6d42                	ld	s10,16(sp)
    80003f94:	6da2                	ld	s11,8(sp)
    80003f96:	a801                	j	80003fa6 <readi+0xe0>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003f98:	89d6                	mv	s3,s5
    80003f9a:	a031                	j	80003fa6 <readi+0xe0>
    80003f9c:	6946                	ld	s2,80(sp)
    80003f9e:	7c02                	ld	s8,32(sp)
    80003fa0:	6ce2                	ld	s9,24(sp)
    80003fa2:	6d42                	ld	s10,16(sp)
    80003fa4:	6da2                	ld	s11,8(sp)
  }
  return tot;
    80003fa6:	0009851b          	sext.w	a0,s3
    80003faa:	69a6                	ld	s3,72(sp)
}
    80003fac:	70a6                	ld	ra,104(sp)
    80003fae:	7406                	ld	s0,96(sp)
    80003fb0:	64e6                	ld	s1,88(sp)
    80003fb2:	6a06                	ld	s4,64(sp)
    80003fb4:	7ae2                	ld	s5,56(sp)
    80003fb6:	7b42                	ld	s6,48(sp)
    80003fb8:	7ba2                	ld	s7,40(sp)
    80003fba:	6165                	addi	sp,sp,112
    80003fbc:	8082                	ret
    return 0;
    80003fbe:	4501                	li	a0,0
}
    80003fc0:	8082                	ret

0000000080003fc2 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003fc2:	457c                	lw	a5,76(a0)
    80003fc4:	10d7e063          	bltu	a5,a3,800040c4 <writei+0x102>
{
    80003fc8:	7159                	addi	sp,sp,-112
    80003fca:	f486                	sd	ra,104(sp)
    80003fcc:	f0a2                	sd	s0,96(sp)
    80003fce:	e8ca                	sd	s2,80(sp)
    80003fd0:	e0d2                	sd	s4,64(sp)
    80003fd2:	fc56                	sd	s5,56(sp)
    80003fd4:	f85a                	sd	s6,48(sp)
    80003fd6:	f45e                	sd	s7,40(sp)
    80003fd8:	1880                	addi	s0,sp,112
    80003fda:	8aaa                	mv	s5,a0
    80003fdc:	8bae                	mv	s7,a1
    80003fde:	8a32                	mv	s4,a2
    80003fe0:	8936                	mv	s2,a3
    80003fe2:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003fe4:	00e687bb          	addw	a5,a3,a4
    80003fe8:	0ed7e063          	bltu	a5,a3,800040c8 <writei+0x106>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80003fec:	00043737          	lui	a4,0x43
    80003ff0:	0cf76e63          	bltu	a4,a5,800040cc <writei+0x10a>
    80003ff4:	e4ce                	sd	s3,72(sp)
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003ff6:	0a0b0f63          	beqz	s6,800040b4 <writei+0xf2>
    80003ffa:	eca6                	sd	s1,88(sp)
    80003ffc:	f062                	sd	s8,32(sp)
    80003ffe:	ec66                	sd	s9,24(sp)
    80004000:	e86a                	sd	s10,16(sp)
    80004002:	e46e                	sd	s11,8(sp)
    80004004:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80004006:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    8000400a:	5c7d                	li	s8,-1
    8000400c:	a825                	j	80004044 <writei+0x82>
    8000400e:	020d1d93          	slli	s11,s10,0x20
    80004012:	020ddd93          	srli	s11,s11,0x20
    80004016:	05848513          	addi	a0,s1,88
    8000401a:	86ee                	mv	a3,s11
    8000401c:	8652                	mv	a2,s4
    8000401e:	85de                	mv	a1,s7
    80004020:	953a                	add	a0,a0,a4
    80004022:	8f7fe0ef          	jal	80002918 <either_copyin>
    80004026:	05850a63          	beq	a0,s8,8000407a <writei+0xb8>
      brelse(bp);
      break;
    }
    log_write(bp);
    8000402a:	8526                	mv	a0,s1
    8000402c:	678000ef          	jal	800046a4 <log_write>
    brelse(bp);
    80004030:	8526                	mv	a0,s1
    80004032:	d2aff0ef          	jal	8000355c <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80004036:	013d09bb          	addw	s3,s10,s3
    8000403a:	012d093b          	addw	s2,s10,s2
    8000403e:	9a6e                	add	s4,s4,s11
    80004040:	0569f063          	bgeu	s3,s6,80004080 <writei+0xbe>
    uint addr = bmap(ip, off/BSIZE);
    80004044:	00a9559b          	srliw	a1,s2,0xa
    80004048:	8556                	mv	a0,s5
    8000404a:	fa4ff0ef          	jal	800037ee <bmap>
    8000404e:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80004052:	c59d                	beqz	a1,80004080 <writei+0xbe>
    bp = bread(ip->dev, addr);
    80004054:	000aa503          	lw	a0,0(s5)
    80004058:	bd4ff0ef          	jal	8000342c <bread>
    8000405c:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    8000405e:	3ff97713          	andi	a4,s2,1023
    80004062:	40ec87bb          	subw	a5,s9,a4
    80004066:	413b06bb          	subw	a3,s6,s3
    8000406a:	8d3e                	mv	s10,a5
    8000406c:	2781                	sext.w	a5,a5
    8000406e:	0006861b          	sext.w	a2,a3
    80004072:	f8f67ee3          	bgeu	a2,a5,8000400e <writei+0x4c>
    80004076:	8d36                	mv	s10,a3
    80004078:	bf59                	j	8000400e <writei+0x4c>
      brelse(bp);
    8000407a:	8526                	mv	a0,s1
    8000407c:	ce0ff0ef          	jal	8000355c <brelse>
  }

  if(off > ip->size)
    80004080:	04caa783          	lw	a5,76(s5)
    80004084:	0327fa63          	bgeu	a5,s2,800040b8 <writei+0xf6>
    ip->size = off;
    80004088:	052aa623          	sw	s2,76(s5)
    8000408c:	64e6                	ld	s1,88(sp)
    8000408e:	7c02                	ld	s8,32(sp)
    80004090:	6ce2                	ld	s9,24(sp)
    80004092:	6d42                	ld	s10,16(sp)
    80004094:	6da2                	ld	s11,8(sp)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80004096:	8556                	mv	a0,s5
    80004098:	9ebff0ef          	jal	80003a82 <iupdate>

  return tot;
    8000409c:	0009851b          	sext.w	a0,s3
    800040a0:	69a6                	ld	s3,72(sp)
}
    800040a2:	70a6                	ld	ra,104(sp)
    800040a4:	7406                	ld	s0,96(sp)
    800040a6:	6946                	ld	s2,80(sp)
    800040a8:	6a06                	ld	s4,64(sp)
    800040aa:	7ae2                	ld	s5,56(sp)
    800040ac:	7b42                	ld	s6,48(sp)
    800040ae:	7ba2                	ld	s7,40(sp)
    800040b0:	6165                	addi	sp,sp,112
    800040b2:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    800040b4:	89da                	mv	s3,s6
    800040b6:	b7c5                	j	80004096 <writei+0xd4>
    800040b8:	64e6                	ld	s1,88(sp)
    800040ba:	7c02                	ld	s8,32(sp)
    800040bc:	6ce2                	ld	s9,24(sp)
    800040be:	6d42                	ld	s10,16(sp)
    800040c0:	6da2                	ld	s11,8(sp)
    800040c2:	bfd1                	j	80004096 <writei+0xd4>
    return -1;
    800040c4:	557d                	li	a0,-1
}
    800040c6:	8082                	ret
    return -1;
    800040c8:	557d                	li	a0,-1
    800040ca:	bfe1                	j	800040a2 <writei+0xe0>
    return -1;
    800040cc:	557d                	li	a0,-1
    800040ce:	bfd1                	j	800040a2 <writei+0xe0>

00000000800040d0 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    800040d0:	1141                	addi	sp,sp,-16
    800040d2:	e406                	sd	ra,8(sp)
    800040d4:	e022                	sd	s0,0(sp)
    800040d6:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    800040d8:	4639                	li	a2,14
    800040da:	d83fc0ef          	jal	80000e5c <strncmp>
}
    800040de:	60a2                	ld	ra,8(sp)
    800040e0:	6402                	ld	s0,0(sp)
    800040e2:	0141                	addi	sp,sp,16
    800040e4:	8082                	ret

00000000800040e6 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    800040e6:	7139                	addi	sp,sp,-64
    800040e8:	fc06                	sd	ra,56(sp)
    800040ea:	f822                	sd	s0,48(sp)
    800040ec:	f426                	sd	s1,40(sp)
    800040ee:	f04a                	sd	s2,32(sp)
    800040f0:	ec4e                	sd	s3,24(sp)
    800040f2:	e852                	sd	s4,16(sp)
    800040f4:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    800040f6:	04451703          	lh	a4,68(a0)
    800040fa:	4785                	li	a5,1
    800040fc:	00f71a63          	bne	a4,a5,80004110 <dirlookup+0x2a>
    80004100:	892a                	mv	s2,a0
    80004102:	89ae                	mv	s3,a1
    80004104:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80004106:	457c                	lw	a5,76(a0)
    80004108:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    8000410a:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    8000410c:	e39d                	bnez	a5,80004132 <dirlookup+0x4c>
    8000410e:	a095                	j	80004172 <dirlookup+0x8c>
    panic("dirlookup not DIR");
    80004110:	00004517          	auipc	a0,0x4
    80004114:	3d850513          	addi	a0,a0,984 # 800084e8 <etext+0x4e8>
    80004118:	efafc0ef          	jal	80000812 <panic>
      panic("dirlookup read");
    8000411c:	00004517          	auipc	a0,0x4
    80004120:	3e450513          	addi	a0,a0,996 # 80008500 <etext+0x500>
    80004124:	eeefc0ef          	jal	80000812 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004128:	24c1                	addiw	s1,s1,16
    8000412a:	04c92783          	lw	a5,76(s2)
    8000412e:	04f4f163          	bgeu	s1,a5,80004170 <dirlookup+0x8a>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004132:	4741                	li	a4,16
    80004134:	86a6                	mv	a3,s1
    80004136:	fc040613          	addi	a2,s0,-64
    8000413a:	4581                	li	a1,0
    8000413c:	854a                	mv	a0,s2
    8000413e:	d89ff0ef          	jal	80003ec6 <readi>
    80004142:	47c1                	li	a5,16
    80004144:	fcf51ce3          	bne	a0,a5,8000411c <dirlookup+0x36>
    if(de.inum == 0)
    80004148:	fc045783          	lhu	a5,-64(s0)
    8000414c:	dff1                	beqz	a5,80004128 <dirlookup+0x42>
    if(namecmp(name, de.name) == 0){
    8000414e:	fc240593          	addi	a1,s0,-62
    80004152:	854e                	mv	a0,s3
    80004154:	f7dff0ef          	jal	800040d0 <namecmp>
    80004158:	f961                	bnez	a0,80004128 <dirlookup+0x42>
      if(poff)
    8000415a:	000a0463          	beqz	s4,80004162 <dirlookup+0x7c>
        *poff = off;
    8000415e:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    80004162:	fc045583          	lhu	a1,-64(s0)
    80004166:	00092503          	lw	a0,0(s2)
    8000416a:	f58ff0ef          	jal	800038c2 <iget>
    8000416e:	a011                	j	80004172 <dirlookup+0x8c>
  return 0;
    80004170:	4501                	li	a0,0
}
    80004172:	70e2                	ld	ra,56(sp)
    80004174:	7442                	ld	s0,48(sp)
    80004176:	74a2                	ld	s1,40(sp)
    80004178:	7902                	ld	s2,32(sp)
    8000417a:	69e2                	ld	s3,24(sp)
    8000417c:	6a42                	ld	s4,16(sp)
    8000417e:	6121                	addi	sp,sp,64
    80004180:	8082                	ret

0000000080004182 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80004182:	711d                	addi	sp,sp,-96
    80004184:	ec86                	sd	ra,88(sp)
    80004186:	e8a2                	sd	s0,80(sp)
    80004188:	e4a6                	sd	s1,72(sp)
    8000418a:	e0ca                	sd	s2,64(sp)
    8000418c:	fc4e                	sd	s3,56(sp)
    8000418e:	f852                	sd	s4,48(sp)
    80004190:	f456                	sd	s5,40(sp)
    80004192:	f05a                	sd	s6,32(sp)
    80004194:	ec5e                	sd	s7,24(sp)
    80004196:	e862                	sd	s8,16(sp)
    80004198:	e466                	sd	s9,8(sp)
    8000419a:	1080                	addi	s0,sp,96
    8000419c:	84aa                	mv	s1,a0
    8000419e:	8b2e                	mv	s6,a1
    800041a0:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    800041a2:	00054703          	lbu	a4,0(a0)
    800041a6:	02f00793          	li	a5,47
    800041aa:	00f70e63          	beq	a4,a5,800041c6 <namex+0x44>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    800041ae:	ad9fd0ef          	jal	80001c86 <myproc>
    800041b2:	15053503          	ld	a0,336(a0)
    800041b6:	94bff0ef          	jal	80003b00 <idup>
    800041ba:	8a2a                	mv	s4,a0
  while(*path == '/')
    800041bc:	02f00913          	li	s2,47
  if(len >= DIRSIZ)
    800041c0:	4c35                	li	s8,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    800041c2:	4b85                	li	s7,1
    800041c4:	a871                	j	80004260 <namex+0xde>
    ip = iget(ROOTDEV, ROOTINO);
    800041c6:	4585                	li	a1,1
    800041c8:	4505                	li	a0,1
    800041ca:	ef8ff0ef          	jal	800038c2 <iget>
    800041ce:	8a2a                	mv	s4,a0
    800041d0:	b7f5                	j	800041bc <namex+0x3a>
      iunlockput(ip);
    800041d2:	8552                	mv	a0,s4
    800041d4:	b6dff0ef          	jal	80003d40 <iunlockput>
      return 0;
    800041d8:	4a01                	li	s4,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    800041da:	8552                	mv	a0,s4
    800041dc:	60e6                	ld	ra,88(sp)
    800041de:	6446                	ld	s0,80(sp)
    800041e0:	64a6                	ld	s1,72(sp)
    800041e2:	6906                	ld	s2,64(sp)
    800041e4:	79e2                	ld	s3,56(sp)
    800041e6:	7a42                	ld	s4,48(sp)
    800041e8:	7aa2                	ld	s5,40(sp)
    800041ea:	7b02                	ld	s6,32(sp)
    800041ec:	6be2                	ld	s7,24(sp)
    800041ee:	6c42                	ld	s8,16(sp)
    800041f0:	6ca2                	ld	s9,8(sp)
    800041f2:	6125                	addi	sp,sp,96
    800041f4:	8082                	ret
      iunlock(ip);
    800041f6:	8552                	mv	a0,s4
    800041f8:	9edff0ef          	jal	80003be4 <iunlock>
      return ip;
    800041fc:	bff9                	j	800041da <namex+0x58>
      iunlockput(ip);
    800041fe:	8552                	mv	a0,s4
    80004200:	b41ff0ef          	jal	80003d40 <iunlockput>
      return 0;
    80004204:	8a4e                	mv	s4,s3
    80004206:	bfd1                	j	800041da <namex+0x58>
  len = path - s;
    80004208:	40998633          	sub	a2,s3,s1
    8000420c:	00060c9b          	sext.w	s9,a2
  if(len >= DIRSIZ)
    80004210:	099c5063          	bge	s8,s9,80004290 <namex+0x10e>
    memmove(name, s, DIRSIZ);
    80004214:	4639                	li	a2,14
    80004216:	85a6                	mv	a1,s1
    80004218:	8556                	mv	a0,s5
    8000421a:	bd3fc0ef          	jal	80000dec <memmove>
    8000421e:	84ce                	mv	s1,s3
  while(*path == '/')
    80004220:	0004c783          	lbu	a5,0(s1)
    80004224:	01279763          	bne	a5,s2,80004232 <namex+0xb0>
    path++;
    80004228:	0485                	addi	s1,s1,1
  while(*path == '/')
    8000422a:	0004c783          	lbu	a5,0(s1)
    8000422e:	ff278de3          	beq	a5,s2,80004228 <namex+0xa6>
    ilock(ip);
    80004232:	8552                	mv	a0,s4
    80004234:	903ff0ef          	jal	80003b36 <ilock>
    if(ip->type != T_DIR){
    80004238:	044a1783          	lh	a5,68(s4)
    8000423c:	f9779be3          	bne	a5,s7,800041d2 <namex+0x50>
    if(nameiparent && *path == '\0'){
    80004240:	000b0563          	beqz	s6,8000424a <namex+0xc8>
    80004244:	0004c783          	lbu	a5,0(s1)
    80004248:	d7dd                	beqz	a5,800041f6 <namex+0x74>
    if((next = dirlookup(ip, name, 0)) == 0){
    8000424a:	4601                	li	a2,0
    8000424c:	85d6                	mv	a1,s5
    8000424e:	8552                	mv	a0,s4
    80004250:	e97ff0ef          	jal	800040e6 <dirlookup>
    80004254:	89aa                	mv	s3,a0
    80004256:	d545                	beqz	a0,800041fe <namex+0x7c>
    iunlockput(ip);
    80004258:	8552                	mv	a0,s4
    8000425a:	ae7ff0ef          	jal	80003d40 <iunlockput>
    ip = next;
    8000425e:	8a4e                	mv	s4,s3
  while(*path == '/')
    80004260:	0004c783          	lbu	a5,0(s1)
    80004264:	01279763          	bne	a5,s2,80004272 <namex+0xf0>
    path++;
    80004268:	0485                	addi	s1,s1,1
  while(*path == '/')
    8000426a:	0004c783          	lbu	a5,0(s1)
    8000426e:	ff278de3          	beq	a5,s2,80004268 <namex+0xe6>
  if(*path == 0)
    80004272:	cb8d                	beqz	a5,800042a4 <namex+0x122>
  while(*path != '/' && *path != 0)
    80004274:	0004c783          	lbu	a5,0(s1)
    80004278:	89a6                	mv	s3,s1
  len = path - s;
    8000427a:	4c81                	li	s9,0
    8000427c:	4601                	li	a2,0
  while(*path != '/' && *path != 0)
    8000427e:	01278963          	beq	a5,s2,80004290 <namex+0x10e>
    80004282:	d3d9                	beqz	a5,80004208 <namex+0x86>
    path++;
    80004284:	0985                	addi	s3,s3,1
  while(*path != '/' && *path != 0)
    80004286:	0009c783          	lbu	a5,0(s3)
    8000428a:	ff279ce3          	bne	a5,s2,80004282 <namex+0x100>
    8000428e:	bfad                	j	80004208 <namex+0x86>
    memmove(name, s, len);
    80004290:	2601                	sext.w	a2,a2
    80004292:	85a6                	mv	a1,s1
    80004294:	8556                	mv	a0,s5
    80004296:	b57fc0ef          	jal	80000dec <memmove>
    name[len] = 0;
    8000429a:	9cd6                	add	s9,s9,s5
    8000429c:	000c8023          	sb	zero,0(s9) # 2000 <_entry-0x7fffe000>
    800042a0:	84ce                	mv	s1,s3
    800042a2:	bfbd                	j	80004220 <namex+0x9e>
  if(nameiparent){
    800042a4:	f20b0be3          	beqz	s6,800041da <namex+0x58>
    iput(ip);
    800042a8:	8552                	mv	a0,s4
    800042aa:	a0fff0ef          	jal	80003cb8 <iput>
    return 0;
    800042ae:	4a01                	li	s4,0
    800042b0:	b72d                	j	800041da <namex+0x58>

00000000800042b2 <dirlink>:
{
    800042b2:	7139                	addi	sp,sp,-64
    800042b4:	fc06                	sd	ra,56(sp)
    800042b6:	f822                	sd	s0,48(sp)
    800042b8:	f04a                	sd	s2,32(sp)
    800042ba:	ec4e                	sd	s3,24(sp)
    800042bc:	e852                	sd	s4,16(sp)
    800042be:	0080                	addi	s0,sp,64
    800042c0:	892a                	mv	s2,a0
    800042c2:	8a2e                	mv	s4,a1
    800042c4:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    800042c6:	4601                	li	a2,0
    800042c8:	e1fff0ef          	jal	800040e6 <dirlookup>
    800042cc:	e535                	bnez	a0,80004338 <dirlink+0x86>
    800042ce:	f426                	sd	s1,40(sp)
  for(off = 0; off < dp->size; off += sizeof(de)){
    800042d0:	04c92483          	lw	s1,76(s2)
    800042d4:	c48d                	beqz	s1,800042fe <dirlink+0x4c>
    800042d6:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800042d8:	4741                	li	a4,16
    800042da:	86a6                	mv	a3,s1
    800042dc:	fc040613          	addi	a2,s0,-64
    800042e0:	4581                	li	a1,0
    800042e2:	854a                	mv	a0,s2
    800042e4:	be3ff0ef          	jal	80003ec6 <readi>
    800042e8:	47c1                	li	a5,16
    800042ea:	04f51b63          	bne	a0,a5,80004340 <dirlink+0x8e>
    if(de.inum == 0)
    800042ee:	fc045783          	lhu	a5,-64(s0)
    800042f2:	c791                	beqz	a5,800042fe <dirlink+0x4c>
  for(off = 0; off < dp->size; off += sizeof(de)){
    800042f4:	24c1                	addiw	s1,s1,16
    800042f6:	04c92783          	lw	a5,76(s2)
    800042fa:	fcf4efe3          	bltu	s1,a5,800042d8 <dirlink+0x26>
  strncpy(de.name, name, DIRSIZ);
    800042fe:	4639                	li	a2,14
    80004300:	85d2                	mv	a1,s4
    80004302:	fc240513          	addi	a0,s0,-62
    80004306:	b8dfc0ef          	jal	80000e92 <strncpy>
  de.inum = inum;
    8000430a:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000430e:	4741                	li	a4,16
    80004310:	86a6                	mv	a3,s1
    80004312:	fc040613          	addi	a2,s0,-64
    80004316:	4581                	li	a1,0
    80004318:	854a                	mv	a0,s2
    8000431a:	ca9ff0ef          	jal	80003fc2 <writei>
    8000431e:	1541                	addi	a0,a0,-16
    80004320:	00a03533          	snez	a0,a0
    80004324:	40a00533          	neg	a0,a0
    80004328:	74a2                	ld	s1,40(sp)
}
    8000432a:	70e2                	ld	ra,56(sp)
    8000432c:	7442                	ld	s0,48(sp)
    8000432e:	7902                	ld	s2,32(sp)
    80004330:	69e2                	ld	s3,24(sp)
    80004332:	6a42                	ld	s4,16(sp)
    80004334:	6121                	addi	sp,sp,64
    80004336:	8082                	ret
    iput(ip);
    80004338:	981ff0ef          	jal	80003cb8 <iput>
    return -1;
    8000433c:	557d                	li	a0,-1
    8000433e:	b7f5                	j	8000432a <dirlink+0x78>
      panic("dirlink read");
    80004340:	00004517          	auipc	a0,0x4
    80004344:	1d050513          	addi	a0,a0,464 # 80008510 <etext+0x510>
    80004348:	ccafc0ef          	jal	80000812 <panic>

000000008000434c <namei>:

struct inode*
namei(char *path)
{
    8000434c:	1101                	addi	sp,sp,-32
    8000434e:	ec06                	sd	ra,24(sp)
    80004350:	e822                	sd	s0,16(sp)
    80004352:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80004354:	fe040613          	addi	a2,s0,-32
    80004358:	4581                	li	a1,0
    8000435a:	e29ff0ef          	jal	80004182 <namex>
}
    8000435e:	60e2                	ld	ra,24(sp)
    80004360:	6442                	ld	s0,16(sp)
    80004362:	6105                	addi	sp,sp,32
    80004364:	8082                	ret

0000000080004366 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    80004366:	1141                	addi	sp,sp,-16
    80004368:	e406                	sd	ra,8(sp)
    8000436a:	e022                	sd	s0,0(sp)
    8000436c:	0800                	addi	s0,sp,16
    8000436e:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80004370:	4585                	li	a1,1
    80004372:	e11ff0ef          	jal	80004182 <namex>
}
    80004376:	60a2                	ld	ra,8(sp)
    80004378:	6402                	ld	s0,0(sp)
    8000437a:	0141                	addi	sp,sp,16
    8000437c:	8082                	ret

000000008000437e <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    8000437e:	1101                	addi	sp,sp,-32
    80004380:	ec06                	sd	ra,24(sp)
    80004382:	e822                	sd	s0,16(sp)
    80004384:	e426                	sd	s1,8(sp)
    80004386:	e04a                	sd	s2,0(sp)
    80004388:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    8000438a:	0001d917          	auipc	s2,0x1d
    8000438e:	86e90913          	addi	s2,s2,-1938 # 80020bf8 <log>
    80004392:	01892583          	lw	a1,24(s2)
    80004396:	02492503          	lw	a0,36(s2)
    8000439a:	892ff0ef          	jal	8000342c <bread>
    8000439e:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    800043a0:	02892603          	lw	a2,40(s2)
    800043a4:	cd30                	sw	a2,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    800043a6:	00c05f63          	blez	a2,800043c4 <write_head+0x46>
    800043aa:	0001d717          	auipc	a4,0x1d
    800043ae:	87a70713          	addi	a4,a4,-1926 # 80020c24 <log+0x2c>
    800043b2:	87aa                	mv	a5,a0
    800043b4:	060a                	slli	a2,a2,0x2
    800043b6:	962a                	add	a2,a2,a0
    hb->block[i] = log.lh.block[i];
    800043b8:	4314                	lw	a3,0(a4)
    800043ba:	cff4                	sw	a3,92(a5)
  for (i = 0; i < log.lh.n; i++) {
    800043bc:	0711                	addi	a4,a4,4
    800043be:	0791                	addi	a5,a5,4
    800043c0:	fec79ce3          	bne	a5,a2,800043b8 <write_head+0x3a>
  }
  bwrite(buf);
    800043c4:	8526                	mv	a0,s1
    800043c6:	964ff0ef          	jal	8000352a <bwrite>
  brelse(buf);
    800043ca:	8526                	mv	a0,s1
    800043cc:	990ff0ef          	jal	8000355c <brelse>
}
    800043d0:	60e2                	ld	ra,24(sp)
    800043d2:	6442                	ld	s0,16(sp)
    800043d4:	64a2                	ld	s1,8(sp)
    800043d6:	6902                	ld	s2,0(sp)
    800043d8:	6105                	addi	sp,sp,32
    800043da:	8082                	ret

00000000800043dc <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    800043dc:	0001d797          	auipc	a5,0x1d
    800043e0:	8447a783          	lw	a5,-1980(a5) # 80020c20 <log+0x28>
    800043e4:	0af05e63          	blez	a5,800044a0 <install_trans+0xc4>
{
    800043e8:	715d                	addi	sp,sp,-80
    800043ea:	e486                	sd	ra,72(sp)
    800043ec:	e0a2                	sd	s0,64(sp)
    800043ee:	fc26                	sd	s1,56(sp)
    800043f0:	f84a                	sd	s2,48(sp)
    800043f2:	f44e                	sd	s3,40(sp)
    800043f4:	f052                	sd	s4,32(sp)
    800043f6:	ec56                	sd	s5,24(sp)
    800043f8:	e85a                	sd	s6,16(sp)
    800043fa:	e45e                	sd	s7,8(sp)
    800043fc:	0880                	addi	s0,sp,80
    800043fe:	8b2a                	mv	s6,a0
    80004400:	0001da97          	auipc	s5,0x1d
    80004404:	824a8a93          	addi	s5,s5,-2012 # 80020c24 <log+0x2c>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004408:	4981                	li	s3,0
      printf("recovering tail %d dst %d\n", tail, log.lh.block[tail]);
    8000440a:	00004b97          	auipc	s7,0x4
    8000440e:	116b8b93          	addi	s7,s7,278 # 80008520 <etext+0x520>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80004412:	0001ca17          	auipc	s4,0x1c
    80004416:	7e6a0a13          	addi	s4,s4,2022 # 80020bf8 <log>
    8000441a:	a025                	j	80004442 <install_trans+0x66>
      printf("recovering tail %d dst %d\n", tail, log.lh.block[tail]);
    8000441c:	000aa603          	lw	a2,0(s5)
    80004420:	85ce                	mv	a1,s3
    80004422:	855e                	mv	a0,s7
    80004424:	908fc0ef          	jal	8000052c <printf>
    80004428:	a839                	j	80004446 <install_trans+0x6a>
    brelse(lbuf);
    8000442a:	854a                	mv	a0,s2
    8000442c:	930ff0ef          	jal	8000355c <brelse>
    brelse(dbuf);
    80004430:	8526                	mv	a0,s1
    80004432:	92aff0ef          	jal	8000355c <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004436:	2985                	addiw	s3,s3,1
    80004438:	0a91                	addi	s5,s5,4
    8000443a:	028a2783          	lw	a5,40(s4)
    8000443e:	04f9d663          	bge	s3,a5,8000448a <install_trans+0xae>
    if(recovering) {
    80004442:	fc0b1de3          	bnez	s6,8000441c <install_trans+0x40>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80004446:	018a2583          	lw	a1,24(s4)
    8000444a:	013585bb          	addw	a1,a1,s3
    8000444e:	2585                	addiw	a1,a1,1
    80004450:	024a2503          	lw	a0,36(s4)
    80004454:	fd9fe0ef          	jal	8000342c <bread>
    80004458:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    8000445a:	000aa583          	lw	a1,0(s5)
    8000445e:	024a2503          	lw	a0,36(s4)
    80004462:	fcbfe0ef          	jal	8000342c <bread>
    80004466:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80004468:	40000613          	li	a2,1024
    8000446c:	05890593          	addi	a1,s2,88
    80004470:	05850513          	addi	a0,a0,88
    80004474:	979fc0ef          	jal	80000dec <memmove>
    bwrite(dbuf);  // write dst to disk
    80004478:	8526                	mv	a0,s1
    8000447a:	8b0ff0ef          	jal	8000352a <bwrite>
    if(recovering == 0)
    8000447e:	fa0b16e3          	bnez	s6,8000442a <install_trans+0x4e>
      bunpin(dbuf);
    80004482:	8526                	mv	a0,s1
    80004484:	9aaff0ef          	jal	8000362e <bunpin>
    80004488:	b74d                	j	8000442a <install_trans+0x4e>
}
    8000448a:	60a6                	ld	ra,72(sp)
    8000448c:	6406                	ld	s0,64(sp)
    8000448e:	74e2                	ld	s1,56(sp)
    80004490:	7942                	ld	s2,48(sp)
    80004492:	79a2                	ld	s3,40(sp)
    80004494:	7a02                	ld	s4,32(sp)
    80004496:	6ae2                	ld	s5,24(sp)
    80004498:	6b42                	ld	s6,16(sp)
    8000449a:	6ba2                	ld	s7,8(sp)
    8000449c:	6161                	addi	sp,sp,80
    8000449e:	8082                	ret
    800044a0:	8082                	ret

00000000800044a2 <initlog>:
{
    800044a2:	7179                	addi	sp,sp,-48
    800044a4:	f406                	sd	ra,40(sp)
    800044a6:	f022                	sd	s0,32(sp)
    800044a8:	ec26                	sd	s1,24(sp)
    800044aa:	e84a                	sd	s2,16(sp)
    800044ac:	e44e                	sd	s3,8(sp)
    800044ae:	1800                	addi	s0,sp,48
    800044b0:	892a                	mv	s2,a0
    800044b2:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    800044b4:	0001c497          	auipc	s1,0x1c
    800044b8:	74448493          	addi	s1,s1,1860 # 80020bf8 <log>
    800044bc:	00004597          	auipc	a1,0x4
    800044c0:	08458593          	addi	a1,a1,132 # 80008540 <etext+0x540>
    800044c4:	8526                	mv	a0,s1
    800044c6:	f76fc0ef          	jal	80000c3c <initlock>
  log.start = sb->logstart;
    800044ca:	0149a583          	lw	a1,20(s3)
    800044ce:	cc8c                	sw	a1,24(s1)
  log.dev = dev;
    800044d0:	0324a223          	sw	s2,36(s1)
  struct buf *buf = bread(log.dev, log.start);
    800044d4:	854a                	mv	a0,s2
    800044d6:	f57fe0ef          	jal	8000342c <bread>
  log.lh.n = lh->n;
    800044da:	4d30                	lw	a2,88(a0)
    800044dc:	d490                	sw	a2,40(s1)
  for (i = 0; i < log.lh.n; i++) {
    800044de:	00c05f63          	blez	a2,800044fc <initlog+0x5a>
    800044e2:	87aa                	mv	a5,a0
    800044e4:	0001c717          	auipc	a4,0x1c
    800044e8:	74070713          	addi	a4,a4,1856 # 80020c24 <log+0x2c>
    800044ec:	060a                	slli	a2,a2,0x2
    800044ee:	962a                	add	a2,a2,a0
    log.lh.block[i] = lh->block[i];
    800044f0:	4ff4                	lw	a3,92(a5)
    800044f2:	c314                	sw	a3,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    800044f4:	0791                	addi	a5,a5,4
    800044f6:	0711                	addi	a4,a4,4
    800044f8:	fec79ce3          	bne	a5,a2,800044f0 <initlog+0x4e>
  brelse(buf);
    800044fc:	860ff0ef          	jal	8000355c <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    80004500:	4505                	li	a0,1
    80004502:	edbff0ef          	jal	800043dc <install_trans>
  log.lh.n = 0;
    80004506:	0001c797          	auipc	a5,0x1c
    8000450a:	7007ad23          	sw	zero,1818(a5) # 80020c20 <log+0x28>
  write_head(); // clear the log
    8000450e:	e71ff0ef          	jal	8000437e <write_head>
}
    80004512:	70a2                	ld	ra,40(sp)
    80004514:	7402                	ld	s0,32(sp)
    80004516:	64e2                	ld	s1,24(sp)
    80004518:	6942                	ld	s2,16(sp)
    8000451a:	69a2                	ld	s3,8(sp)
    8000451c:	6145                	addi	sp,sp,48
    8000451e:	8082                	ret

0000000080004520 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    80004520:	1101                	addi	sp,sp,-32
    80004522:	ec06                	sd	ra,24(sp)
    80004524:	e822                	sd	s0,16(sp)
    80004526:	e426                	sd	s1,8(sp)
    80004528:	e04a                	sd	s2,0(sp)
    8000452a:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    8000452c:	0001c517          	auipc	a0,0x1c
    80004530:	6cc50513          	addi	a0,a0,1740 # 80020bf8 <log>
    80004534:	f88fc0ef          	jal	80000cbc <acquire>
  while(1){
    if(log.committing){
    80004538:	0001c497          	auipc	s1,0x1c
    8000453c:	6c048493          	addi	s1,s1,1728 # 80020bf8 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGBLOCKS){
    80004540:	4979                	li	s2,30
    80004542:	a029                	j	8000454c <begin_op+0x2c>
      sleep(&log, &log.lock);
    80004544:	85a6                	mv	a1,s1
    80004546:	8526                	mv	a0,s1
    80004548:	804fe0ef          	jal	8000254c <sleep>
    if(log.committing){
    8000454c:	509c                	lw	a5,32(s1)
    8000454e:	fbfd                	bnez	a5,80004544 <begin_op+0x24>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGBLOCKS){
    80004550:	4cd8                	lw	a4,28(s1)
    80004552:	2705                	addiw	a4,a4,1
    80004554:	0027179b          	slliw	a5,a4,0x2
    80004558:	9fb9                	addw	a5,a5,a4
    8000455a:	0017979b          	slliw	a5,a5,0x1
    8000455e:	5494                	lw	a3,40(s1)
    80004560:	9fb5                	addw	a5,a5,a3
    80004562:	00f95763          	bge	s2,a5,80004570 <begin_op+0x50>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    80004566:	85a6                	mv	a1,s1
    80004568:	8526                	mv	a0,s1
    8000456a:	fe3fd0ef          	jal	8000254c <sleep>
    8000456e:	bff9                	j	8000454c <begin_op+0x2c>
    } else {
      log.outstanding += 1;
    80004570:	0001c517          	auipc	a0,0x1c
    80004574:	68850513          	addi	a0,a0,1672 # 80020bf8 <log>
    80004578:	cd58                	sw	a4,28(a0)
      release(&log.lock);
    8000457a:	fdafc0ef          	jal	80000d54 <release>
      break;
    }
  }
}
    8000457e:	60e2                	ld	ra,24(sp)
    80004580:	6442                	ld	s0,16(sp)
    80004582:	64a2                	ld	s1,8(sp)
    80004584:	6902                	ld	s2,0(sp)
    80004586:	6105                	addi	sp,sp,32
    80004588:	8082                	ret

000000008000458a <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    8000458a:	7139                	addi	sp,sp,-64
    8000458c:	fc06                	sd	ra,56(sp)
    8000458e:	f822                	sd	s0,48(sp)
    80004590:	f426                	sd	s1,40(sp)
    80004592:	f04a                	sd	s2,32(sp)
    80004594:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    80004596:	0001c497          	auipc	s1,0x1c
    8000459a:	66248493          	addi	s1,s1,1634 # 80020bf8 <log>
    8000459e:	8526                	mv	a0,s1
    800045a0:	f1cfc0ef          	jal	80000cbc <acquire>
  log.outstanding -= 1;
    800045a4:	4cdc                	lw	a5,28(s1)
    800045a6:	37fd                	addiw	a5,a5,-1
    800045a8:	0007891b          	sext.w	s2,a5
    800045ac:	ccdc                	sw	a5,28(s1)
  if(log.committing)
    800045ae:	509c                	lw	a5,32(s1)
    800045b0:	ef9d                	bnez	a5,800045ee <end_op+0x64>
    panic("log.committing");
  if(log.outstanding == 0){
    800045b2:	04091763          	bnez	s2,80004600 <end_op+0x76>
    do_commit = 1;
    log.committing = 1;
    800045b6:	0001c497          	auipc	s1,0x1c
    800045ba:	64248493          	addi	s1,s1,1602 # 80020bf8 <log>
    800045be:	4785                	li	a5,1
    800045c0:	d09c                	sw	a5,32(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    800045c2:	8526                	mv	a0,s1
    800045c4:	f90fc0ef          	jal	80000d54 <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    800045c8:	549c                	lw	a5,40(s1)
    800045ca:	04f04b63          	bgtz	a5,80004620 <end_op+0x96>
    acquire(&log.lock);
    800045ce:	0001c497          	auipc	s1,0x1c
    800045d2:	62a48493          	addi	s1,s1,1578 # 80020bf8 <log>
    800045d6:	8526                	mv	a0,s1
    800045d8:	ee4fc0ef          	jal	80000cbc <acquire>
    log.committing = 0;
    800045dc:	0204a023          	sw	zero,32(s1)
    wakeup(&log);
    800045e0:	8526                	mv	a0,s1
    800045e2:	fbbfd0ef          	jal	8000259c <wakeup>
    release(&log.lock);
    800045e6:	8526                	mv	a0,s1
    800045e8:	f6cfc0ef          	jal	80000d54 <release>
}
    800045ec:	a025                	j	80004614 <end_op+0x8a>
    800045ee:	ec4e                	sd	s3,24(sp)
    800045f0:	e852                	sd	s4,16(sp)
    800045f2:	e456                	sd	s5,8(sp)
    panic("log.committing");
    800045f4:	00004517          	auipc	a0,0x4
    800045f8:	f5450513          	addi	a0,a0,-172 # 80008548 <etext+0x548>
    800045fc:	a16fc0ef          	jal	80000812 <panic>
    wakeup(&log);
    80004600:	0001c497          	auipc	s1,0x1c
    80004604:	5f848493          	addi	s1,s1,1528 # 80020bf8 <log>
    80004608:	8526                	mv	a0,s1
    8000460a:	f93fd0ef          	jal	8000259c <wakeup>
  release(&log.lock);
    8000460e:	8526                	mv	a0,s1
    80004610:	f44fc0ef          	jal	80000d54 <release>
}
    80004614:	70e2                	ld	ra,56(sp)
    80004616:	7442                	ld	s0,48(sp)
    80004618:	74a2                	ld	s1,40(sp)
    8000461a:	7902                	ld	s2,32(sp)
    8000461c:	6121                	addi	sp,sp,64
    8000461e:	8082                	ret
    80004620:	ec4e                	sd	s3,24(sp)
    80004622:	e852                	sd	s4,16(sp)
    80004624:	e456                	sd	s5,8(sp)
  for (tail = 0; tail < log.lh.n; tail++) {
    80004626:	0001ca97          	auipc	s5,0x1c
    8000462a:	5fea8a93          	addi	s5,s5,1534 # 80020c24 <log+0x2c>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    8000462e:	0001ca17          	auipc	s4,0x1c
    80004632:	5caa0a13          	addi	s4,s4,1482 # 80020bf8 <log>
    80004636:	018a2583          	lw	a1,24(s4)
    8000463a:	012585bb          	addw	a1,a1,s2
    8000463e:	2585                	addiw	a1,a1,1
    80004640:	024a2503          	lw	a0,36(s4)
    80004644:	de9fe0ef          	jal	8000342c <bread>
    80004648:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    8000464a:	000aa583          	lw	a1,0(s5)
    8000464e:	024a2503          	lw	a0,36(s4)
    80004652:	ddbfe0ef          	jal	8000342c <bread>
    80004656:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    80004658:	40000613          	li	a2,1024
    8000465c:	05850593          	addi	a1,a0,88
    80004660:	05848513          	addi	a0,s1,88
    80004664:	f88fc0ef          	jal	80000dec <memmove>
    bwrite(to);  // write the log
    80004668:	8526                	mv	a0,s1
    8000466a:	ec1fe0ef          	jal	8000352a <bwrite>
    brelse(from);
    8000466e:	854e                	mv	a0,s3
    80004670:	eedfe0ef          	jal	8000355c <brelse>
    brelse(to);
    80004674:	8526                	mv	a0,s1
    80004676:	ee7fe0ef          	jal	8000355c <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    8000467a:	2905                	addiw	s2,s2,1
    8000467c:	0a91                	addi	s5,s5,4
    8000467e:	028a2783          	lw	a5,40(s4)
    80004682:	faf94ae3          	blt	s2,a5,80004636 <end_op+0xac>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    80004686:	cf9ff0ef          	jal	8000437e <write_head>
    install_trans(0); // Now install writes to home locations
    8000468a:	4501                	li	a0,0
    8000468c:	d51ff0ef          	jal	800043dc <install_trans>
    log.lh.n = 0;
    80004690:	0001c797          	auipc	a5,0x1c
    80004694:	5807a823          	sw	zero,1424(a5) # 80020c20 <log+0x28>
    write_head();    // Erase the transaction from the log
    80004698:	ce7ff0ef          	jal	8000437e <write_head>
    8000469c:	69e2                	ld	s3,24(sp)
    8000469e:	6a42                	ld	s4,16(sp)
    800046a0:	6aa2                	ld	s5,8(sp)
    800046a2:	b735                	j	800045ce <end_op+0x44>

00000000800046a4 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    800046a4:	1101                	addi	sp,sp,-32
    800046a6:	ec06                	sd	ra,24(sp)
    800046a8:	e822                	sd	s0,16(sp)
    800046aa:	e426                	sd	s1,8(sp)
    800046ac:	e04a                	sd	s2,0(sp)
    800046ae:	1000                	addi	s0,sp,32
    800046b0:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    800046b2:	0001c917          	auipc	s2,0x1c
    800046b6:	54690913          	addi	s2,s2,1350 # 80020bf8 <log>
    800046ba:	854a                	mv	a0,s2
    800046bc:	e00fc0ef          	jal	80000cbc <acquire>
  if (log.lh.n >= LOGBLOCKS)
    800046c0:	02892603          	lw	a2,40(s2)
    800046c4:	47f5                	li	a5,29
    800046c6:	04c7cc63          	blt	a5,a2,8000471e <log_write+0x7a>
    panic("too big a transaction");
  if (log.outstanding < 1)
    800046ca:	0001c797          	auipc	a5,0x1c
    800046ce:	54a7a783          	lw	a5,1354(a5) # 80020c14 <log+0x1c>
    800046d2:	04f05c63          	blez	a5,8000472a <log_write+0x86>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    800046d6:	4781                	li	a5,0
    800046d8:	04c05f63          	blez	a2,80004736 <log_write+0x92>
    if (log.lh.block[i] == b->blockno)   // log absorption
    800046dc:	44cc                	lw	a1,12(s1)
    800046de:	0001c717          	auipc	a4,0x1c
    800046e2:	54670713          	addi	a4,a4,1350 # 80020c24 <log+0x2c>
  for (i = 0; i < log.lh.n; i++) {
    800046e6:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    800046e8:	4314                	lw	a3,0(a4)
    800046ea:	04b68663          	beq	a3,a1,80004736 <log_write+0x92>
  for (i = 0; i < log.lh.n; i++) {
    800046ee:	2785                	addiw	a5,a5,1
    800046f0:	0711                	addi	a4,a4,4
    800046f2:	fef61be3          	bne	a2,a5,800046e8 <log_write+0x44>
      break;
  }
  log.lh.block[i] = b->blockno;
    800046f6:	0621                	addi	a2,a2,8
    800046f8:	060a                	slli	a2,a2,0x2
    800046fa:	0001c797          	auipc	a5,0x1c
    800046fe:	4fe78793          	addi	a5,a5,1278 # 80020bf8 <log>
    80004702:	97b2                	add	a5,a5,a2
    80004704:	44d8                	lw	a4,12(s1)
    80004706:	c7d8                	sw	a4,12(a5)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    80004708:	8526                	mv	a0,s1
    8000470a:	ef1fe0ef          	jal	800035fa <bpin>
    log.lh.n++;
    8000470e:	0001c717          	auipc	a4,0x1c
    80004712:	4ea70713          	addi	a4,a4,1258 # 80020bf8 <log>
    80004716:	571c                	lw	a5,40(a4)
    80004718:	2785                	addiw	a5,a5,1
    8000471a:	d71c                	sw	a5,40(a4)
    8000471c:	a80d                	j	8000474e <log_write+0xaa>
    panic("too big a transaction");
    8000471e:	00004517          	auipc	a0,0x4
    80004722:	e3a50513          	addi	a0,a0,-454 # 80008558 <etext+0x558>
    80004726:	8ecfc0ef          	jal	80000812 <panic>
    panic("log_write outside of trans");
    8000472a:	00004517          	auipc	a0,0x4
    8000472e:	e4650513          	addi	a0,a0,-442 # 80008570 <etext+0x570>
    80004732:	8e0fc0ef          	jal	80000812 <panic>
  log.lh.block[i] = b->blockno;
    80004736:	00878693          	addi	a3,a5,8
    8000473a:	068a                	slli	a3,a3,0x2
    8000473c:	0001c717          	auipc	a4,0x1c
    80004740:	4bc70713          	addi	a4,a4,1212 # 80020bf8 <log>
    80004744:	9736                	add	a4,a4,a3
    80004746:	44d4                	lw	a3,12(s1)
    80004748:	c754                	sw	a3,12(a4)
  if (i == log.lh.n) {  // Add new block to log?
    8000474a:	faf60fe3          	beq	a2,a5,80004708 <log_write+0x64>
  }
  release(&log.lock);
    8000474e:	0001c517          	auipc	a0,0x1c
    80004752:	4aa50513          	addi	a0,a0,1194 # 80020bf8 <log>
    80004756:	dfefc0ef          	jal	80000d54 <release>
}
    8000475a:	60e2                	ld	ra,24(sp)
    8000475c:	6442                	ld	s0,16(sp)
    8000475e:	64a2                	ld	s1,8(sp)
    80004760:	6902                	ld	s2,0(sp)
    80004762:	6105                	addi	sp,sp,32
    80004764:	8082                	ret

0000000080004766 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    80004766:	1101                	addi	sp,sp,-32
    80004768:	ec06                	sd	ra,24(sp)
    8000476a:	e822                	sd	s0,16(sp)
    8000476c:	e426                	sd	s1,8(sp)
    8000476e:	e04a                	sd	s2,0(sp)
    80004770:	1000                	addi	s0,sp,32
    80004772:	84aa                	mv	s1,a0
    80004774:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    80004776:	00004597          	auipc	a1,0x4
    8000477a:	e1a58593          	addi	a1,a1,-486 # 80008590 <etext+0x590>
    8000477e:	0521                	addi	a0,a0,8
    80004780:	cbcfc0ef          	jal	80000c3c <initlock>
  lk->name = name;
    80004784:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    80004788:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    8000478c:	0204a423          	sw	zero,40(s1)
}
    80004790:	60e2                	ld	ra,24(sp)
    80004792:	6442                	ld	s0,16(sp)
    80004794:	64a2                	ld	s1,8(sp)
    80004796:	6902                	ld	s2,0(sp)
    80004798:	6105                	addi	sp,sp,32
    8000479a:	8082                	ret

000000008000479c <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    8000479c:	1101                	addi	sp,sp,-32
    8000479e:	ec06                	sd	ra,24(sp)
    800047a0:	e822                	sd	s0,16(sp)
    800047a2:	e426                	sd	s1,8(sp)
    800047a4:	e04a                	sd	s2,0(sp)
    800047a6:	1000                	addi	s0,sp,32
    800047a8:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    800047aa:	00850913          	addi	s2,a0,8
    800047ae:	854a                	mv	a0,s2
    800047b0:	d0cfc0ef          	jal	80000cbc <acquire>
  while (lk->locked) {
    800047b4:	409c                	lw	a5,0(s1)
    800047b6:	c799                	beqz	a5,800047c4 <acquiresleep+0x28>
    sleep(lk, &lk->lk);
    800047b8:	85ca                	mv	a1,s2
    800047ba:	8526                	mv	a0,s1
    800047bc:	d91fd0ef          	jal	8000254c <sleep>
  while (lk->locked) {
    800047c0:	409c                	lw	a5,0(s1)
    800047c2:	fbfd                	bnez	a5,800047b8 <acquiresleep+0x1c>
  }
  lk->locked = 1;
    800047c4:	4785                	li	a5,1
    800047c6:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    800047c8:	cbefd0ef          	jal	80001c86 <myproc>
    800047cc:	595c                	lw	a5,52(a0)
    800047ce:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    800047d0:	854a                	mv	a0,s2
    800047d2:	d82fc0ef          	jal	80000d54 <release>
}
    800047d6:	60e2                	ld	ra,24(sp)
    800047d8:	6442                	ld	s0,16(sp)
    800047da:	64a2                	ld	s1,8(sp)
    800047dc:	6902                	ld	s2,0(sp)
    800047de:	6105                	addi	sp,sp,32
    800047e0:	8082                	ret

00000000800047e2 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    800047e2:	1101                	addi	sp,sp,-32
    800047e4:	ec06                	sd	ra,24(sp)
    800047e6:	e822                	sd	s0,16(sp)
    800047e8:	e426                	sd	s1,8(sp)
    800047ea:	e04a                	sd	s2,0(sp)
    800047ec:	1000                	addi	s0,sp,32
    800047ee:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    800047f0:	00850913          	addi	s2,a0,8
    800047f4:	854a                	mv	a0,s2
    800047f6:	cc6fc0ef          	jal	80000cbc <acquire>
  lk->locked = 0;
    800047fa:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    800047fe:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    80004802:	8526                	mv	a0,s1
    80004804:	d99fd0ef          	jal	8000259c <wakeup>
  release(&lk->lk);
    80004808:	854a                	mv	a0,s2
    8000480a:	d4afc0ef          	jal	80000d54 <release>
}
    8000480e:	60e2                	ld	ra,24(sp)
    80004810:	6442                	ld	s0,16(sp)
    80004812:	64a2                	ld	s1,8(sp)
    80004814:	6902                	ld	s2,0(sp)
    80004816:	6105                	addi	sp,sp,32
    80004818:	8082                	ret

000000008000481a <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    8000481a:	7179                	addi	sp,sp,-48
    8000481c:	f406                	sd	ra,40(sp)
    8000481e:	f022                	sd	s0,32(sp)
    80004820:	ec26                	sd	s1,24(sp)
    80004822:	e84a                	sd	s2,16(sp)
    80004824:	1800                	addi	s0,sp,48
    80004826:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    80004828:	00850913          	addi	s2,a0,8
    8000482c:	854a                	mv	a0,s2
    8000482e:	c8efc0ef          	jal	80000cbc <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    80004832:	409c                	lw	a5,0(s1)
    80004834:	ef81                	bnez	a5,8000484c <holdingsleep+0x32>
    80004836:	4481                	li	s1,0
  release(&lk->lk);
    80004838:	854a                	mv	a0,s2
    8000483a:	d1afc0ef          	jal	80000d54 <release>
  return r;
}
    8000483e:	8526                	mv	a0,s1
    80004840:	70a2                	ld	ra,40(sp)
    80004842:	7402                	ld	s0,32(sp)
    80004844:	64e2                	ld	s1,24(sp)
    80004846:	6942                	ld	s2,16(sp)
    80004848:	6145                	addi	sp,sp,48
    8000484a:	8082                	ret
    8000484c:	e44e                	sd	s3,8(sp)
  r = lk->locked && (lk->pid == myproc()->pid);
    8000484e:	0284a983          	lw	s3,40(s1)
    80004852:	c34fd0ef          	jal	80001c86 <myproc>
    80004856:	5944                	lw	s1,52(a0)
    80004858:	413484b3          	sub	s1,s1,s3
    8000485c:	0014b493          	seqz	s1,s1
    80004860:	69a2                	ld	s3,8(sp)
    80004862:	bfd9                	j	80004838 <holdingsleep+0x1e>

0000000080004864 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    80004864:	1141                	addi	sp,sp,-16
    80004866:	e406                	sd	ra,8(sp)
    80004868:	e022                	sd	s0,0(sp)
    8000486a:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    8000486c:	00004597          	auipc	a1,0x4
    80004870:	d3458593          	addi	a1,a1,-716 # 800085a0 <etext+0x5a0>
    80004874:	0001c517          	auipc	a0,0x1c
    80004878:	4cc50513          	addi	a0,a0,1228 # 80020d40 <ftable>
    8000487c:	bc0fc0ef          	jal	80000c3c <initlock>
}
    80004880:	60a2                	ld	ra,8(sp)
    80004882:	6402                	ld	s0,0(sp)
    80004884:	0141                	addi	sp,sp,16
    80004886:	8082                	ret

0000000080004888 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    80004888:	1101                	addi	sp,sp,-32
    8000488a:	ec06                	sd	ra,24(sp)
    8000488c:	e822                	sd	s0,16(sp)
    8000488e:	e426                	sd	s1,8(sp)
    80004890:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    80004892:	0001c517          	auipc	a0,0x1c
    80004896:	4ae50513          	addi	a0,a0,1198 # 80020d40 <ftable>
    8000489a:	c22fc0ef          	jal	80000cbc <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    8000489e:	0001c497          	auipc	s1,0x1c
    800048a2:	4ba48493          	addi	s1,s1,1210 # 80020d58 <ftable+0x18>
    800048a6:	0001d717          	auipc	a4,0x1d
    800048aa:	45270713          	addi	a4,a4,1106 # 80021cf8 <disk>
    if(f->ref == 0){
    800048ae:	40dc                	lw	a5,4(s1)
    800048b0:	cf89                	beqz	a5,800048ca <filealloc+0x42>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    800048b2:	02848493          	addi	s1,s1,40
    800048b6:	fee49ce3          	bne	s1,a4,800048ae <filealloc+0x26>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    800048ba:	0001c517          	auipc	a0,0x1c
    800048be:	48650513          	addi	a0,a0,1158 # 80020d40 <ftable>
    800048c2:	c92fc0ef          	jal	80000d54 <release>
  return 0;
    800048c6:	4481                	li	s1,0
    800048c8:	a809                	j	800048da <filealloc+0x52>
      f->ref = 1;
    800048ca:	4785                	li	a5,1
    800048cc:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    800048ce:	0001c517          	auipc	a0,0x1c
    800048d2:	47250513          	addi	a0,a0,1138 # 80020d40 <ftable>
    800048d6:	c7efc0ef          	jal	80000d54 <release>
}
    800048da:	8526                	mv	a0,s1
    800048dc:	60e2                	ld	ra,24(sp)
    800048de:	6442                	ld	s0,16(sp)
    800048e0:	64a2                	ld	s1,8(sp)
    800048e2:	6105                	addi	sp,sp,32
    800048e4:	8082                	ret

00000000800048e6 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    800048e6:	1101                	addi	sp,sp,-32
    800048e8:	ec06                	sd	ra,24(sp)
    800048ea:	e822                	sd	s0,16(sp)
    800048ec:	e426                	sd	s1,8(sp)
    800048ee:	1000                	addi	s0,sp,32
    800048f0:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    800048f2:	0001c517          	auipc	a0,0x1c
    800048f6:	44e50513          	addi	a0,a0,1102 # 80020d40 <ftable>
    800048fa:	bc2fc0ef          	jal	80000cbc <acquire>
  if(f->ref < 1)
    800048fe:	40dc                	lw	a5,4(s1)
    80004900:	02f05063          	blez	a5,80004920 <filedup+0x3a>
    panic("filedup");
  f->ref++;
    80004904:	2785                	addiw	a5,a5,1
    80004906:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80004908:	0001c517          	auipc	a0,0x1c
    8000490c:	43850513          	addi	a0,a0,1080 # 80020d40 <ftable>
    80004910:	c44fc0ef          	jal	80000d54 <release>
  return f;
}
    80004914:	8526                	mv	a0,s1
    80004916:	60e2                	ld	ra,24(sp)
    80004918:	6442                	ld	s0,16(sp)
    8000491a:	64a2                	ld	s1,8(sp)
    8000491c:	6105                	addi	sp,sp,32
    8000491e:	8082                	ret
    panic("filedup");
    80004920:	00004517          	auipc	a0,0x4
    80004924:	c8850513          	addi	a0,a0,-888 # 800085a8 <etext+0x5a8>
    80004928:	eebfb0ef          	jal	80000812 <panic>

000000008000492c <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    8000492c:	7139                	addi	sp,sp,-64
    8000492e:	fc06                	sd	ra,56(sp)
    80004930:	f822                	sd	s0,48(sp)
    80004932:	f426                	sd	s1,40(sp)
    80004934:	0080                	addi	s0,sp,64
    80004936:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    80004938:	0001c517          	auipc	a0,0x1c
    8000493c:	40850513          	addi	a0,a0,1032 # 80020d40 <ftable>
    80004940:	b7cfc0ef          	jal	80000cbc <acquire>
  if(f->ref < 1)
    80004944:	40dc                	lw	a5,4(s1)
    80004946:	04f05a63          	blez	a5,8000499a <fileclose+0x6e>
    panic("fileclose");
  if(--f->ref > 0){
    8000494a:	37fd                	addiw	a5,a5,-1
    8000494c:	0007871b          	sext.w	a4,a5
    80004950:	c0dc                	sw	a5,4(s1)
    80004952:	04e04e63          	bgtz	a4,800049ae <fileclose+0x82>
    80004956:	f04a                	sd	s2,32(sp)
    80004958:	ec4e                	sd	s3,24(sp)
    8000495a:	e852                	sd	s4,16(sp)
    8000495c:	e456                	sd	s5,8(sp)
    release(&ftable.lock);
    return;
  }
  ff = *f;
    8000495e:	0004a903          	lw	s2,0(s1)
    80004962:	0094ca83          	lbu	s5,9(s1)
    80004966:	0104ba03          	ld	s4,16(s1)
    8000496a:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    8000496e:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    80004972:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    80004976:	0001c517          	auipc	a0,0x1c
    8000497a:	3ca50513          	addi	a0,a0,970 # 80020d40 <ftable>
    8000497e:	bd6fc0ef          	jal	80000d54 <release>

  if(ff.type == FD_PIPE){
    80004982:	4785                	li	a5,1
    80004984:	04f90063          	beq	s2,a5,800049c4 <fileclose+0x98>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    80004988:	3979                	addiw	s2,s2,-2
    8000498a:	4785                	li	a5,1
    8000498c:	0527f563          	bgeu	a5,s2,800049d6 <fileclose+0xaa>
    80004990:	7902                	ld	s2,32(sp)
    80004992:	69e2                	ld	s3,24(sp)
    80004994:	6a42                	ld	s4,16(sp)
    80004996:	6aa2                	ld	s5,8(sp)
    80004998:	a00d                	j	800049ba <fileclose+0x8e>
    8000499a:	f04a                	sd	s2,32(sp)
    8000499c:	ec4e                	sd	s3,24(sp)
    8000499e:	e852                	sd	s4,16(sp)
    800049a0:	e456                	sd	s5,8(sp)
    panic("fileclose");
    800049a2:	00004517          	auipc	a0,0x4
    800049a6:	c0e50513          	addi	a0,a0,-1010 # 800085b0 <etext+0x5b0>
    800049aa:	e69fb0ef          	jal	80000812 <panic>
    release(&ftable.lock);
    800049ae:	0001c517          	auipc	a0,0x1c
    800049b2:	39250513          	addi	a0,a0,914 # 80020d40 <ftable>
    800049b6:	b9efc0ef          	jal	80000d54 <release>
    begin_op();
    iput(ff.ip);
    end_op();
  }
}
    800049ba:	70e2                	ld	ra,56(sp)
    800049bc:	7442                	ld	s0,48(sp)
    800049be:	74a2                	ld	s1,40(sp)
    800049c0:	6121                	addi	sp,sp,64
    800049c2:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    800049c4:	85d6                	mv	a1,s5
    800049c6:	8552                	mv	a0,s4
    800049c8:	336000ef          	jal	80004cfe <pipeclose>
    800049cc:	7902                	ld	s2,32(sp)
    800049ce:	69e2                	ld	s3,24(sp)
    800049d0:	6a42                	ld	s4,16(sp)
    800049d2:	6aa2                	ld	s5,8(sp)
    800049d4:	b7dd                	j	800049ba <fileclose+0x8e>
    begin_op();
    800049d6:	b4bff0ef          	jal	80004520 <begin_op>
    iput(ff.ip);
    800049da:	854e                	mv	a0,s3
    800049dc:	adcff0ef          	jal	80003cb8 <iput>
    end_op();
    800049e0:	babff0ef          	jal	8000458a <end_op>
    800049e4:	7902                	ld	s2,32(sp)
    800049e6:	69e2                	ld	s3,24(sp)
    800049e8:	6a42                	ld	s4,16(sp)
    800049ea:	6aa2                	ld	s5,8(sp)
    800049ec:	b7f9                	j	800049ba <fileclose+0x8e>

00000000800049ee <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    800049ee:	715d                	addi	sp,sp,-80
    800049f0:	e486                	sd	ra,72(sp)
    800049f2:	e0a2                	sd	s0,64(sp)
    800049f4:	fc26                	sd	s1,56(sp)
    800049f6:	f44e                	sd	s3,40(sp)
    800049f8:	0880                	addi	s0,sp,80
    800049fa:	84aa                	mv	s1,a0
    800049fc:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    800049fe:	a88fd0ef          	jal	80001c86 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    80004a02:	409c                	lw	a5,0(s1)
    80004a04:	37f9                	addiw	a5,a5,-2
    80004a06:	4705                	li	a4,1
    80004a08:	04f76063          	bltu	a4,a5,80004a48 <filestat+0x5a>
    80004a0c:	f84a                	sd	s2,48(sp)
    80004a0e:	892a                	mv	s2,a0
    ilock(f->ip);
    80004a10:	6c88                	ld	a0,24(s1)
    80004a12:	924ff0ef          	jal	80003b36 <ilock>
    stati(f->ip, &st);
    80004a16:	fb840593          	addi	a1,s0,-72
    80004a1a:	6c88                	ld	a0,24(s1)
    80004a1c:	c80ff0ef          	jal	80003e9c <stati>
    iunlock(f->ip);
    80004a20:	6c88                	ld	a0,24(s1)
    80004a22:	9c2ff0ef          	jal	80003be4 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    80004a26:	46e1                	li	a3,24
    80004a28:	fb840613          	addi	a2,s0,-72
    80004a2c:	85ce                	mv	a1,s3
    80004a2e:	05093503          	ld	a0,80(s2)
    80004a32:	edffc0ef          	jal	80001910 <copyout>
    80004a36:	41f5551b          	sraiw	a0,a0,0x1f
    80004a3a:	7942                	ld	s2,48(sp)
      return -1;
    return 0;
  }
  return -1;
}
    80004a3c:	60a6                	ld	ra,72(sp)
    80004a3e:	6406                	ld	s0,64(sp)
    80004a40:	74e2                	ld	s1,56(sp)
    80004a42:	79a2                	ld	s3,40(sp)
    80004a44:	6161                	addi	sp,sp,80
    80004a46:	8082                	ret
  return -1;
    80004a48:	557d                	li	a0,-1
    80004a4a:	bfcd                	j	80004a3c <filestat+0x4e>

0000000080004a4c <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    80004a4c:	7179                	addi	sp,sp,-48
    80004a4e:	f406                	sd	ra,40(sp)
    80004a50:	f022                	sd	s0,32(sp)
    80004a52:	e84a                	sd	s2,16(sp)
    80004a54:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    80004a56:	00854783          	lbu	a5,8(a0)
    80004a5a:	cfd1                	beqz	a5,80004af6 <fileread+0xaa>
    80004a5c:	ec26                	sd	s1,24(sp)
    80004a5e:	e44e                	sd	s3,8(sp)
    80004a60:	84aa                	mv	s1,a0
    80004a62:	89ae                	mv	s3,a1
    80004a64:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    80004a66:	411c                	lw	a5,0(a0)
    80004a68:	4705                	li	a4,1
    80004a6a:	04e78363          	beq	a5,a4,80004ab0 <fileread+0x64>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004a6e:	470d                	li	a4,3
    80004a70:	04e78763          	beq	a5,a4,80004abe <fileread+0x72>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    80004a74:	4709                	li	a4,2
    80004a76:	06e79a63          	bne	a5,a4,80004aea <fileread+0x9e>
    ilock(f->ip);
    80004a7a:	6d08                	ld	a0,24(a0)
    80004a7c:	8baff0ef          	jal	80003b36 <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    80004a80:	874a                	mv	a4,s2
    80004a82:	5094                	lw	a3,32(s1)
    80004a84:	864e                	mv	a2,s3
    80004a86:	4585                	li	a1,1
    80004a88:	6c88                	ld	a0,24(s1)
    80004a8a:	c3cff0ef          	jal	80003ec6 <readi>
    80004a8e:	892a                	mv	s2,a0
    80004a90:	00a05563          	blez	a0,80004a9a <fileread+0x4e>
      f->off += r;
    80004a94:	509c                	lw	a5,32(s1)
    80004a96:	9fa9                	addw	a5,a5,a0
    80004a98:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80004a9a:	6c88                	ld	a0,24(s1)
    80004a9c:	948ff0ef          	jal	80003be4 <iunlock>
    80004aa0:	64e2                	ld	s1,24(sp)
    80004aa2:	69a2                	ld	s3,8(sp)
  } else {
    panic("fileread");
  }

  return r;
}
    80004aa4:	854a                	mv	a0,s2
    80004aa6:	70a2                	ld	ra,40(sp)
    80004aa8:	7402                	ld	s0,32(sp)
    80004aaa:	6942                	ld	s2,16(sp)
    80004aac:	6145                	addi	sp,sp,48
    80004aae:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80004ab0:	6908                	ld	a0,16(a0)
    80004ab2:	388000ef          	jal	80004e3a <piperead>
    80004ab6:	892a                	mv	s2,a0
    80004ab8:	64e2                	ld	s1,24(sp)
    80004aba:	69a2                	ld	s3,8(sp)
    80004abc:	b7e5                	j	80004aa4 <fileread+0x58>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80004abe:	02451783          	lh	a5,36(a0)
    80004ac2:	03079693          	slli	a3,a5,0x30
    80004ac6:	92c1                	srli	a3,a3,0x30
    80004ac8:	4725                	li	a4,9
    80004aca:	02d76863          	bltu	a4,a3,80004afa <fileread+0xae>
    80004ace:	0792                	slli	a5,a5,0x4
    80004ad0:	0001c717          	auipc	a4,0x1c
    80004ad4:	1d070713          	addi	a4,a4,464 # 80020ca0 <devsw>
    80004ad8:	97ba                	add	a5,a5,a4
    80004ada:	639c                	ld	a5,0(a5)
    80004adc:	c39d                	beqz	a5,80004b02 <fileread+0xb6>
    r = devsw[f->major].read(1, addr, n);
    80004ade:	4505                	li	a0,1
    80004ae0:	9782                	jalr	a5
    80004ae2:	892a                	mv	s2,a0
    80004ae4:	64e2                	ld	s1,24(sp)
    80004ae6:	69a2                	ld	s3,8(sp)
    80004ae8:	bf75                	j	80004aa4 <fileread+0x58>
    panic("fileread");
    80004aea:	00004517          	auipc	a0,0x4
    80004aee:	ad650513          	addi	a0,a0,-1322 # 800085c0 <etext+0x5c0>
    80004af2:	d21fb0ef          	jal	80000812 <panic>
    return -1;
    80004af6:	597d                	li	s2,-1
    80004af8:	b775                	j	80004aa4 <fileread+0x58>
      return -1;
    80004afa:	597d                	li	s2,-1
    80004afc:	64e2                	ld	s1,24(sp)
    80004afe:	69a2                	ld	s3,8(sp)
    80004b00:	b755                	j	80004aa4 <fileread+0x58>
    80004b02:	597d                	li	s2,-1
    80004b04:	64e2                	ld	s1,24(sp)
    80004b06:	69a2                	ld	s3,8(sp)
    80004b08:	bf71                	j	80004aa4 <fileread+0x58>

0000000080004b0a <filewrite>:
int
filewrite(struct file *f, uint64 addr, int n)
{
  int r, ret = 0;

  if(f->writable == 0)
    80004b0a:	00954783          	lbu	a5,9(a0)
    80004b0e:	10078b63          	beqz	a5,80004c24 <filewrite+0x11a>
{
    80004b12:	715d                	addi	sp,sp,-80
    80004b14:	e486                	sd	ra,72(sp)
    80004b16:	e0a2                	sd	s0,64(sp)
    80004b18:	f84a                	sd	s2,48(sp)
    80004b1a:	f052                	sd	s4,32(sp)
    80004b1c:	e85a                	sd	s6,16(sp)
    80004b1e:	0880                	addi	s0,sp,80
    80004b20:	892a                	mv	s2,a0
    80004b22:	8b2e                	mv	s6,a1
    80004b24:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    80004b26:	411c                	lw	a5,0(a0)
    80004b28:	4705                	li	a4,1
    80004b2a:	02e78763          	beq	a5,a4,80004b58 <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004b2e:	470d                	li	a4,3
    80004b30:	02e78863          	beq	a5,a4,80004b60 <filewrite+0x56>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    80004b34:	4709                	li	a4,2
    80004b36:	0ce79c63          	bne	a5,a4,80004c0e <filewrite+0x104>
    80004b3a:	f44e                	sd	s3,40(sp)
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    80004b3c:	0ac05863          	blez	a2,80004bec <filewrite+0xe2>
    80004b40:	fc26                	sd	s1,56(sp)
    80004b42:	ec56                	sd	s5,24(sp)
    80004b44:	e45e                	sd	s7,8(sp)
    80004b46:	e062                	sd	s8,0(sp)
    int i = 0;
    80004b48:	4981                	li	s3,0
      int n1 = n - i;
      if(n1 > max)
    80004b4a:	6b85                	lui	s7,0x1
    80004b4c:	c00b8b93          	addi	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    80004b50:	6c05                	lui	s8,0x1
    80004b52:	c00c0c1b          	addiw	s8,s8,-1024 # c00 <_entry-0x7ffff400>
    80004b56:	a8b5                	j	80004bd2 <filewrite+0xc8>
    ret = pipewrite(f->pipe, addr, n);
    80004b58:	6908                	ld	a0,16(a0)
    80004b5a:	1fc000ef          	jal	80004d56 <pipewrite>
    80004b5e:	a04d                	j	80004c00 <filewrite+0xf6>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80004b60:	02451783          	lh	a5,36(a0)
    80004b64:	03079693          	slli	a3,a5,0x30
    80004b68:	92c1                	srli	a3,a3,0x30
    80004b6a:	4725                	li	a4,9
    80004b6c:	0ad76e63          	bltu	a4,a3,80004c28 <filewrite+0x11e>
    80004b70:	0792                	slli	a5,a5,0x4
    80004b72:	0001c717          	auipc	a4,0x1c
    80004b76:	12e70713          	addi	a4,a4,302 # 80020ca0 <devsw>
    80004b7a:	97ba                	add	a5,a5,a4
    80004b7c:	679c                	ld	a5,8(a5)
    80004b7e:	c7dd                	beqz	a5,80004c2c <filewrite+0x122>
    ret = devsw[f->major].write(1, addr, n);
    80004b80:	4505                	li	a0,1
    80004b82:	9782                	jalr	a5
    80004b84:	a8b5                	j	80004c00 <filewrite+0xf6>
      if(n1 > max)
    80004b86:	00048a9b          	sext.w	s5,s1
        n1 = max;

      begin_op();
    80004b8a:	997ff0ef          	jal	80004520 <begin_op>
      ilock(f->ip);
    80004b8e:	01893503          	ld	a0,24(s2)
    80004b92:	fa5fe0ef          	jal	80003b36 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80004b96:	8756                	mv	a4,s5
    80004b98:	02092683          	lw	a3,32(s2)
    80004b9c:	01698633          	add	a2,s3,s6
    80004ba0:	4585                	li	a1,1
    80004ba2:	01893503          	ld	a0,24(s2)
    80004ba6:	c1cff0ef          	jal	80003fc2 <writei>
    80004baa:	84aa                	mv	s1,a0
    80004bac:	00a05763          	blez	a0,80004bba <filewrite+0xb0>
        f->off += r;
    80004bb0:	02092783          	lw	a5,32(s2)
    80004bb4:	9fa9                	addw	a5,a5,a0
    80004bb6:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80004bba:	01893503          	ld	a0,24(s2)
    80004bbe:	826ff0ef          	jal	80003be4 <iunlock>
      end_op();
    80004bc2:	9c9ff0ef          	jal	8000458a <end_op>

      if(r != n1){
    80004bc6:	029a9563          	bne	s5,s1,80004bf0 <filewrite+0xe6>
        // error from writei
        break;
      }
      i += r;
    80004bca:	013489bb          	addw	s3,s1,s3
    while(i < n){
    80004bce:	0149da63          	bge	s3,s4,80004be2 <filewrite+0xd8>
      int n1 = n - i;
    80004bd2:	413a04bb          	subw	s1,s4,s3
      if(n1 > max)
    80004bd6:	0004879b          	sext.w	a5,s1
    80004bda:	fafbd6e3          	bge	s7,a5,80004b86 <filewrite+0x7c>
    80004bde:	84e2                	mv	s1,s8
    80004be0:	b75d                	j	80004b86 <filewrite+0x7c>
    80004be2:	74e2                	ld	s1,56(sp)
    80004be4:	6ae2                	ld	s5,24(sp)
    80004be6:	6ba2                	ld	s7,8(sp)
    80004be8:	6c02                	ld	s8,0(sp)
    80004bea:	a039                	j	80004bf8 <filewrite+0xee>
    int i = 0;
    80004bec:	4981                	li	s3,0
    80004bee:	a029                	j	80004bf8 <filewrite+0xee>
    80004bf0:	74e2                	ld	s1,56(sp)
    80004bf2:	6ae2                	ld	s5,24(sp)
    80004bf4:	6ba2                	ld	s7,8(sp)
    80004bf6:	6c02                	ld	s8,0(sp)
    }
    ret = (i == n ? n : -1);
    80004bf8:	033a1c63          	bne	s4,s3,80004c30 <filewrite+0x126>
    80004bfc:	8552                	mv	a0,s4
    80004bfe:	79a2                	ld	s3,40(sp)
  } else {
    panic("filewrite");
  }

  return ret;
}
    80004c00:	60a6                	ld	ra,72(sp)
    80004c02:	6406                	ld	s0,64(sp)
    80004c04:	7942                	ld	s2,48(sp)
    80004c06:	7a02                	ld	s4,32(sp)
    80004c08:	6b42                	ld	s6,16(sp)
    80004c0a:	6161                	addi	sp,sp,80
    80004c0c:	8082                	ret
    80004c0e:	fc26                	sd	s1,56(sp)
    80004c10:	f44e                	sd	s3,40(sp)
    80004c12:	ec56                	sd	s5,24(sp)
    80004c14:	e45e                	sd	s7,8(sp)
    80004c16:	e062                	sd	s8,0(sp)
    panic("filewrite");
    80004c18:	00004517          	auipc	a0,0x4
    80004c1c:	9b850513          	addi	a0,a0,-1608 # 800085d0 <etext+0x5d0>
    80004c20:	bf3fb0ef          	jal	80000812 <panic>
    return -1;
    80004c24:	557d                	li	a0,-1
}
    80004c26:	8082                	ret
      return -1;
    80004c28:	557d                	li	a0,-1
    80004c2a:	bfd9                	j	80004c00 <filewrite+0xf6>
    80004c2c:	557d                	li	a0,-1
    80004c2e:	bfc9                	j	80004c00 <filewrite+0xf6>
    ret = (i == n ? n : -1);
    80004c30:	557d                	li	a0,-1
    80004c32:	79a2                	ld	s3,40(sp)
    80004c34:	b7f1                	j	80004c00 <filewrite+0xf6>

0000000080004c36 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80004c36:	7179                	addi	sp,sp,-48
    80004c38:	f406                	sd	ra,40(sp)
    80004c3a:	f022                	sd	s0,32(sp)
    80004c3c:	ec26                	sd	s1,24(sp)
    80004c3e:	e052                	sd	s4,0(sp)
    80004c40:	1800                	addi	s0,sp,48
    80004c42:	84aa                	mv	s1,a0
    80004c44:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80004c46:	0005b023          	sd	zero,0(a1)
    80004c4a:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80004c4e:	c3bff0ef          	jal	80004888 <filealloc>
    80004c52:	e088                	sd	a0,0(s1)
    80004c54:	c549                	beqz	a0,80004cde <pipealloc+0xa8>
    80004c56:	c33ff0ef          	jal	80004888 <filealloc>
    80004c5a:	00aa3023          	sd	a0,0(s4)
    80004c5e:	cd25                	beqz	a0,80004cd6 <pipealloc+0xa0>
    80004c60:	e84a                	sd	s2,16(sp)
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80004c62:	f2dfb0ef          	jal	80000b8e <kalloc>
    80004c66:	892a                	mv	s2,a0
    80004c68:	c12d                	beqz	a0,80004cca <pipealloc+0x94>
    80004c6a:	e44e                	sd	s3,8(sp)
    goto bad;
  pi->readopen = 1;
    80004c6c:	4985                	li	s3,1
    80004c6e:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    80004c72:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    80004c76:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80004c7a:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80004c7e:	00004597          	auipc	a1,0x4
    80004c82:	96258593          	addi	a1,a1,-1694 # 800085e0 <etext+0x5e0>
    80004c86:	fb7fb0ef          	jal	80000c3c <initlock>
  (*f0)->type = FD_PIPE;
    80004c8a:	609c                	ld	a5,0(s1)
    80004c8c:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80004c90:	609c                	ld	a5,0(s1)
    80004c92:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80004c96:	609c                	ld	a5,0(s1)
    80004c98:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80004c9c:	609c                	ld	a5,0(s1)
    80004c9e:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80004ca2:	000a3783          	ld	a5,0(s4)
    80004ca6:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80004caa:	000a3783          	ld	a5,0(s4)
    80004cae:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80004cb2:	000a3783          	ld	a5,0(s4)
    80004cb6:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80004cba:	000a3783          	ld	a5,0(s4)
    80004cbe:	0127b823          	sd	s2,16(a5)
  return 0;
    80004cc2:	4501                	li	a0,0
    80004cc4:	6942                	ld	s2,16(sp)
    80004cc6:	69a2                	ld	s3,8(sp)
    80004cc8:	a01d                	j	80004cee <pipealloc+0xb8>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80004cca:	6088                	ld	a0,0(s1)
    80004ccc:	c119                	beqz	a0,80004cd2 <pipealloc+0x9c>
    80004cce:	6942                	ld	s2,16(sp)
    80004cd0:	a029                	j	80004cda <pipealloc+0xa4>
    80004cd2:	6942                	ld	s2,16(sp)
    80004cd4:	a029                	j	80004cde <pipealloc+0xa8>
    80004cd6:	6088                	ld	a0,0(s1)
    80004cd8:	c10d                	beqz	a0,80004cfa <pipealloc+0xc4>
    fileclose(*f0);
    80004cda:	c53ff0ef          	jal	8000492c <fileclose>
  if(*f1)
    80004cde:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80004ce2:	557d                	li	a0,-1
  if(*f1)
    80004ce4:	c789                	beqz	a5,80004cee <pipealloc+0xb8>
    fileclose(*f1);
    80004ce6:	853e                	mv	a0,a5
    80004ce8:	c45ff0ef          	jal	8000492c <fileclose>
  return -1;
    80004cec:	557d                	li	a0,-1
}
    80004cee:	70a2                	ld	ra,40(sp)
    80004cf0:	7402                	ld	s0,32(sp)
    80004cf2:	64e2                	ld	s1,24(sp)
    80004cf4:	6a02                	ld	s4,0(sp)
    80004cf6:	6145                	addi	sp,sp,48
    80004cf8:	8082                	ret
  return -1;
    80004cfa:	557d                	li	a0,-1
    80004cfc:	bfcd                	j	80004cee <pipealloc+0xb8>

0000000080004cfe <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80004cfe:	1101                	addi	sp,sp,-32
    80004d00:	ec06                	sd	ra,24(sp)
    80004d02:	e822                	sd	s0,16(sp)
    80004d04:	e426                	sd	s1,8(sp)
    80004d06:	e04a                	sd	s2,0(sp)
    80004d08:	1000                	addi	s0,sp,32
    80004d0a:	84aa                	mv	s1,a0
    80004d0c:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80004d0e:	faffb0ef          	jal	80000cbc <acquire>
  if(writable){
    80004d12:	02090763          	beqz	s2,80004d40 <pipeclose+0x42>
    pi->writeopen = 0;
    80004d16:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80004d1a:	21848513          	addi	a0,s1,536
    80004d1e:	87ffd0ef          	jal	8000259c <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80004d22:	2204b783          	ld	a5,544(s1)
    80004d26:	e785                	bnez	a5,80004d4e <pipeclose+0x50>
    release(&pi->lock);
    80004d28:	8526                	mv	a0,s1
    80004d2a:	82afc0ef          	jal	80000d54 <release>
    kfree((char*)pi);
    80004d2e:	8526                	mv	a0,s1
    80004d30:	d1ffb0ef          	jal	80000a4e <kfree>
  } else
    release(&pi->lock);
}
    80004d34:	60e2                	ld	ra,24(sp)
    80004d36:	6442                	ld	s0,16(sp)
    80004d38:	64a2                	ld	s1,8(sp)
    80004d3a:	6902                	ld	s2,0(sp)
    80004d3c:	6105                	addi	sp,sp,32
    80004d3e:	8082                	ret
    pi->readopen = 0;
    80004d40:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80004d44:	21c48513          	addi	a0,s1,540
    80004d48:	855fd0ef          	jal	8000259c <wakeup>
    80004d4c:	bfd9                	j	80004d22 <pipeclose+0x24>
    release(&pi->lock);
    80004d4e:	8526                	mv	a0,s1
    80004d50:	804fc0ef          	jal	80000d54 <release>
}
    80004d54:	b7c5                	j	80004d34 <pipeclose+0x36>

0000000080004d56 <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80004d56:	711d                	addi	sp,sp,-96
    80004d58:	ec86                	sd	ra,88(sp)
    80004d5a:	e8a2                	sd	s0,80(sp)
    80004d5c:	e4a6                	sd	s1,72(sp)
    80004d5e:	e0ca                	sd	s2,64(sp)
    80004d60:	fc4e                	sd	s3,56(sp)
    80004d62:	f852                	sd	s4,48(sp)
    80004d64:	f456                	sd	s5,40(sp)
    80004d66:	1080                	addi	s0,sp,96
    80004d68:	84aa                	mv	s1,a0
    80004d6a:	8aae                	mv	s5,a1
    80004d6c:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    80004d6e:	f19fc0ef          	jal	80001c86 <myproc>
    80004d72:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    80004d74:	8526                	mv	a0,s1
    80004d76:	f47fb0ef          	jal	80000cbc <acquire>
  while(i < n){
    80004d7a:	0b405a63          	blez	s4,80004e2e <pipewrite+0xd8>
    80004d7e:	f05a                	sd	s6,32(sp)
    80004d80:	ec5e                	sd	s7,24(sp)
    80004d82:	e862                	sd	s8,16(sp)
  int i = 0;
    80004d84:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004d86:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    80004d88:	21848c13          	addi	s8,s1,536
      sleep(&pi->nwrite, &pi->lock);
    80004d8c:	21c48b93          	addi	s7,s1,540
    80004d90:	a81d                	j	80004dc6 <pipewrite+0x70>
      release(&pi->lock);
    80004d92:	8526                	mv	a0,s1
    80004d94:	fc1fb0ef          	jal	80000d54 <release>
      return -1;
    80004d98:	597d                	li	s2,-1
    80004d9a:	7b02                	ld	s6,32(sp)
    80004d9c:	6be2                	ld	s7,24(sp)
    80004d9e:	6c42                	ld	s8,16(sp)
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    80004da0:	854a                	mv	a0,s2
    80004da2:	60e6                	ld	ra,88(sp)
    80004da4:	6446                	ld	s0,80(sp)
    80004da6:	64a6                	ld	s1,72(sp)
    80004da8:	6906                	ld	s2,64(sp)
    80004daa:	79e2                	ld	s3,56(sp)
    80004dac:	7a42                	ld	s4,48(sp)
    80004dae:	7aa2                	ld	s5,40(sp)
    80004db0:	6125                	addi	sp,sp,96
    80004db2:	8082                	ret
      wakeup(&pi->nread);
    80004db4:	8562                	mv	a0,s8
    80004db6:	fe6fd0ef          	jal	8000259c <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80004dba:	85a6                	mv	a1,s1
    80004dbc:	855e                	mv	a0,s7
    80004dbe:	f8efd0ef          	jal	8000254c <sleep>
  while(i < n){
    80004dc2:	05495b63          	bge	s2,s4,80004e18 <pipewrite+0xc2>
    if(pi->readopen == 0 || killed(pr)){
    80004dc6:	2204a783          	lw	a5,544(s1)
    80004dca:	d7e1                	beqz	a5,80004d92 <pipewrite+0x3c>
    80004dcc:	854e                	mv	a0,s3
    80004dce:	9ddfd0ef          	jal	800027aa <killed>
    80004dd2:	f161                	bnez	a0,80004d92 <pipewrite+0x3c>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    80004dd4:	2184a783          	lw	a5,536(s1)
    80004dd8:	21c4a703          	lw	a4,540(s1)
    80004ddc:	2007879b          	addiw	a5,a5,512
    80004de0:	fcf70ae3          	beq	a4,a5,80004db4 <pipewrite+0x5e>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004de4:	4685                	li	a3,1
    80004de6:	01590633          	add	a2,s2,s5
    80004dea:	faf40593          	addi	a1,s0,-81
    80004dee:	0509b503          	ld	a0,80(s3)
    80004df2:	c03fc0ef          	jal	800019f4 <copyin>
    80004df6:	03650e63          	beq	a0,s6,80004e32 <pipewrite+0xdc>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80004dfa:	21c4a783          	lw	a5,540(s1)
    80004dfe:	0017871b          	addiw	a4,a5,1
    80004e02:	20e4ae23          	sw	a4,540(s1)
    80004e06:	1ff7f793          	andi	a5,a5,511
    80004e0a:	97a6                	add	a5,a5,s1
    80004e0c:	faf44703          	lbu	a4,-81(s0)
    80004e10:	00e78c23          	sb	a4,24(a5)
      i++;
    80004e14:	2905                	addiw	s2,s2,1
    80004e16:	b775                	j	80004dc2 <pipewrite+0x6c>
    80004e18:	7b02                	ld	s6,32(sp)
    80004e1a:	6be2                	ld	s7,24(sp)
    80004e1c:	6c42                	ld	s8,16(sp)
  wakeup(&pi->nread);
    80004e1e:	21848513          	addi	a0,s1,536
    80004e22:	f7afd0ef          	jal	8000259c <wakeup>
  release(&pi->lock);
    80004e26:	8526                	mv	a0,s1
    80004e28:	f2dfb0ef          	jal	80000d54 <release>
  return i;
    80004e2c:	bf95                	j	80004da0 <pipewrite+0x4a>
  int i = 0;
    80004e2e:	4901                	li	s2,0
    80004e30:	b7fd                	j	80004e1e <pipewrite+0xc8>
    80004e32:	7b02                	ld	s6,32(sp)
    80004e34:	6be2                	ld	s7,24(sp)
    80004e36:	6c42                	ld	s8,16(sp)
    80004e38:	b7dd                	j	80004e1e <pipewrite+0xc8>

0000000080004e3a <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80004e3a:	715d                	addi	sp,sp,-80
    80004e3c:	e486                	sd	ra,72(sp)
    80004e3e:	e0a2                	sd	s0,64(sp)
    80004e40:	fc26                	sd	s1,56(sp)
    80004e42:	f84a                	sd	s2,48(sp)
    80004e44:	f44e                	sd	s3,40(sp)
    80004e46:	f052                	sd	s4,32(sp)
    80004e48:	ec56                	sd	s5,24(sp)
    80004e4a:	0880                	addi	s0,sp,80
    80004e4c:	84aa                	mv	s1,a0
    80004e4e:	892e                	mv	s2,a1
    80004e50:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80004e52:	e35fc0ef          	jal	80001c86 <myproc>
    80004e56:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80004e58:	8526                	mv	a0,s1
    80004e5a:	e63fb0ef          	jal	80000cbc <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004e5e:	2184a703          	lw	a4,536(s1)
    80004e62:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004e66:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004e6a:	02f71563          	bne	a4,a5,80004e94 <piperead+0x5a>
    80004e6e:	2244a783          	lw	a5,548(s1)
    80004e72:	cb85                	beqz	a5,80004ea2 <piperead+0x68>
    if(killed(pr)){
    80004e74:	8552                	mv	a0,s4
    80004e76:	935fd0ef          	jal	800027aa <killed>
    80004e7a:	ed19                	bnez	a0,80004e98 <piperead+0x5e>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004e7c:	85a6                	mv	a1,s1
    80004e7e:	854e                	mv	a0,s3
    80004e80:	eccfd0ef          	jal	8000254c <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004e84:	2184a703          	lw	a4,536(s1)
    80004e88:	21c4a783          	lw	a5,540(s1)
    80004e8c:	fef701e3          	beq	a4,a5,80004e6e <piperead+0x34>
    80004e90:	e85a                	sd	s6,16(sp)
    80004e92:	a809                	j	80004ea4 <piperead+0x6a>
    80004e94:	e85a                	sd	s6,16(sp)
    80004e96:	a039                	j	80004ea4 <piperead+0x6a>
      release(&pi->lock);
    80004e98:	8526                	mv	a0,s1
    80004e9a:	ebbfb0ef          	jal	80000d54 <release>
      return -1;
    80004e9e:	59fd                	li	s3,-1
    80004ea0:	a8b9                	j	80004efe <piperead+0xc4>
    80004ea2:	e85a                	sd	s6,16(sp)
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004ea4:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1) {
    80004ea6:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004ea8:	05505363          	blez	s5,80004eee <piperead+0xb4>
    if(pi->nread == pi->nwrite)
    80004eac:	2184a783          	lw	a5,536(s1)
    80004eb0:	21c4a703          	lw	a4,540(s1)
    80004eb4:	02f70d63          	beq	a4,a5,80004eee <piperead+0xb4>
    ch = pi->data[pi->nread % PIPESIZE];
    80004eb8:	1ff7f793          	andi	a5,a5,511
    80004ebc:	97a6                	add	a5,a5,s1
    80004ebe:	0187c783          	lbu	a5,24(a5)
    80004ec2:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1) {
    80004ec6:	4685                	li	a3,1
    80004ec8:	fbf40613          	addi	a2,s0,-65
    80004ecc:	85ca                	mv	a1,s2
    80004ece:	050a3503          	ld	a0,80(s4)
    80004ed2:	a3ffc0ef          	jal	80001910 <copyout>
    80004ed6:	03650e63          	beq	a0,s6,80004f12 <piperead+0xd8>
      if(i == 0)
        i = -1;
      break;
    }
    pi->nread++;
    80004eda:	2184a783          	lw	a5,536(s1)
    80004ede:	2785                	addiw	a5,a5,1
    80004ee0:	20f4ac23          	sw	a5,536(s1)
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004ee4:	2985                	addiw	s3,s3,1
    80004ee6:	0905                	addi	s2,s2,1
    80004ee8:	fd3a92e3          	bne	s5,s3,80004eac <piperead+0x72>
    80004eec:	89d6                	mv	s3,s5
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80004eee:	21c48513          	addi	a0,s1,540
    80004ef2:	eaafd0ef          	jal	8000259c <wakeup>
  release(&pi->lock);
    80004ef6:	8526                	mv	a0,s1
    80004ef8:	e5dfb0ef          	jal	80000d54 <release>
    80004efc:	6b42                	ld	s6,16(sp)
  return i;
}
    80004efe:	854e                	mv	a0,s3
    80004f00:	60a6                	ld	ra,72(sp)
    80004f02:	6406                	ld	s0,64(sp)
    80004f04:	74e2                	ld	s1,56(sp)
    80004f06:	7942                	ld	s2,48(sp)
    80004f08:	79a2                	ld	s3,40(sp)
    80004f0a:	7a02                	ld	s4,32(sp)
    80004f0c:	6ae2                	ld	s5,24(sp)
    80004f0e:	6161                	addi	sp,sp,80
    80004f10:	8082                	ret
      if(i == 0)
    80004f12:	fc099ee3          	bnez	s3,80004eee <piperead+0xb4>
        i = -1;
    80004f16:	89aa                	mv	s3,a0
    80004f18:	bfd9                	j	80004eee <piperead+0xb4>

0000000080004f1a <flags2perm>:

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

// map ELF permissions to PTE permission bits.
int flags2perm(int flags)
{
    80004f1a:	1141                	addi	sp,sp,-16
    80004f1c:	e422                	sd	s0,8(sp)
    80004f1e:	0800                	addi	s0,sp,16
    80004f20:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    80004f22:	8905                	andi	a0,a0,1
    80004f24:	050e                	slli	a0,a0,0x3
      perm = PTE_X;
    if(flags & 0x2)
    80004f26:	8b89                	andi	a5,a5,2
    80004f28:	c399                	beqz	a5,80004f2e <flags2perm+0x14>
      perm |= PTE_W;
    80004f2a:	00456513          	ori	a0,a0,4
    return perm;
}
    80004f2e:	6422                	ld	s0,8(sp)
    80004f30:	0141                	addi	sp,sp,16
    80004f32:	8082                	ret

0000000080004f34 <kexec>:
//
// the implementation of the exec() system call
//
int
kexec(char *path, char **argv)
{
    80004f34:	df010113          	addi	sp,sp,-528
    80004f38:	20113423          	sd	ra,520(sp)
    80004f3c:	20813023          	sd	s0,512(sp)
    80004f40:	ffa6                	sd	s1,504(sp)
    80004f42:	fbca                	sd	s2,496(sp)
    80004f44:	0c00                	addi	s0,sp,528
    80004f46:	892a                	mv	s2,a0
    80004f48:	dea43c23          	sd	a0,-520(s0)
    80004f4c:	e0b43023          	sd	a1,-512(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80004f50:	d37fc0ef          	jal	80001c86 <myproc>
    80004f54:	84aa                	mv	s1,a0

  begin_op();
    80004f56:	dcaff0ef          	jal	80004520 <begin_op>

  // Open the executable file.
  if((ip = namei(path)) == 0){
    80004f5a:	854a                	mv	a0,s2
    80004f5c:	bf0ff0ef          	jal	8000434c <namei>
    80004f60:	c931                	beqz	a0,80004fb4 <kexec+0x80>
    80004f62:	f3d2                	sd	s4,480(sp)
    80004f64:	8a2a                	mv	s4,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80004f66:	bd1fe0ef          	jal	80003b36 <ilock>

  // Read the ELF header.
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80004f6a:	04000713          	li	a4,64
    80004f6e:	4681                	li	a3,0
    80004f70:	e5040613          	addi	a2,s0,-432
    80004f74:	4581                	li	a1,0
    80004f76:	8552                	mv	a0,s4
    80004f78:	f4ffe0ef          	jal	80003ec6 <readi>
    80004f7c:	04000793          	li	a5,64
    80004f80:	00f51a63          	bne	a0,a5,80004f94 <kexec+0x60>
    goto bad;

  // Is this really an ELF file?
  if(elf.magic != ELF_MAGIC)
    80004f84:	e5042703          	lw	a4,-432(s0)
    80004f88:	464c47b7          	lui	a5,0x464c4
    80004f8c:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80004f90:	02f70663          	beq	a4,a5,80004fbc <kexec+0x88>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    80004f94:	8552                	mv	a0,s4
    80004f96:	dabfe0ef          	jal	80003d40 <iunlockput>
    end_op();
    80004f9a:	df0ff0ef          	jal	8000458a <end_op>
  }
  return -1;
    80004f9e:	557d                	li	a0,-1
    80004fa0:	7a1e                	ld	s4,480(sp)
}
    80004fa2:	20813083          	ld	ra,520(sp)
    80004fa6:	20013403          	ld	s0,512(sp)
    80004faa:	74fe                	ld	s1,504(sp)
    80004fac:	795e                	ld	s2,496(sp)
    80004fae:	21010113          	addi	sp,sp,528
    80004fb2:	8082                	ret
    end_op();
    80004fb4:	dd6ff0ef          	jal	8000458a <end_op>
    return -1;
    80004fb8:	557d                	li	a0,-1
    80004fba:	b7e5                	j	80004fa2 <kexec+0x6e>
    80004fbc:	ebda                	sd	s6,464(sp)
  if((pagetable = proc_pagetable(p)) == 0)
    80004fbe:	8526                	mv	a0,s1
    80004fc0:	dd3fc0ef          	jal	80001d92 <proc_pagetable>
    80004fc4:	8b2a                	mv	s6,a0
    80004fc6:	2c050b63          	beqz	a0,8000529c <kexec+0x368>
    80004fca:	f7ce                	sd	s3,488(sp)
    80004fcc:	efd6                	sd	s5,472(sp)
    80004fce:	e7de                	sd	s7,456(sp)
    80004fd0:	e3e2                	sd	s8,448(sp)
    80004fd2:	ff66                	sd	s9,440(sp)
    80004fd4:	fb6a                	sd	s10,432(sp)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004fd6:	e7042d03          	lw	s10,-400(s0)
    80004fda:	e8845783          	lhu	a5,-376(s0)
    80004fde:	12078963          	beqz	a5,80005110 <kexec+0x1dc>
    80004fe2:	f76e                	sd	s11,424(sp)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004fe4:	4901                	li	s2,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004fe6:	4d81                	li	s11,0
    if(ph.vaddr % PGSIZE != 0)
    80004fe8:	6c85                	lui	s9,0x1
    80004fea:	fffc8793          	addi	a5,s9,-1 # fff <_entry-0x7ffff001>
    80004fee:	def43823          	sd	a5,-528(s0)

  for(i = 0; i < sz; i += PGSIZE){
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    if(sz - i < PGSIZE)
    80004ff2:	6a85                	lui	s5,0x1
    80004ff4:	a085                	j	80005054 <kexec+0x120>
      panic("loadseg: address should exist");
    80004ff6:	00003517          	auipc	a0,0x3
    80004ffa:	5f250513          	addi	a0,a0,1522 # 800085e8 <etext+0x5e8>
    80004ffe:	815fb0ef          	jal	80000812 <panic>
    if(sz - i < PGSIZE)
    80005002:	2481                	sext.w	s1,s1
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80005004:	8726                	mv	a4,s1
    80005006:	012c06bb          	addw	a3,s8,s2
    8000500a:	4581                	li	a1,0
    8000500c:	8552                	mv	a0,s4
    8000500e:	eb9fe0ef          	jal	80003ec6 <readi>
    80005012:	2501                	sext.w	a0,a0
    80005014:	24a49a63          	bne	s1,a0,80005268 <kexec+0x334>
  for(i = 0; i < sz; i += PGSIZE){
    80005018:	012a893b          	addw	s2,s5,s2
    8000501c:	03397363          	bgeu	s2,s3,80005042 <kexec+0x10e>
    pa = walkaddr(pagetable, va + i);
    80005020:	02091593          	slli	a1,s2,0x20
    80005024:	9181                	srli	a1,a1,0x20
    80005026:	95de                	add	a1,a1,s7
    80005028:	855a                	mv	a0,s6
    8000502a:	89cfc0ef          	jal	800010c6 <walkaddr>
    8000502e:	862a                	mv	a2,a0
    if(pa == 0)
    80005030:	d179                	beqz	a0,80004ff6 <kexec+0xc2>
    if(sz - i < PGSIZE)
    80005032:	412984bb          	subw	s1,s3,s2
    80005036:	0004879b          	sext.w	a5,s1
    8000503a:	fcfcf4e3          	bgeu	s9,a5,80005002 <kexec+0xce>
    8000503e:	84d6                	mv	s1,s5
    80005040:	b7c9                	j	80005002 <kexec+0xce>
    sz = sz1;
    80005042:	e0843903          	ld	s2,-504(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80005046:	2d85                	addiw	s11,s11,1
    80005048:	038d0d1b          	addiw	s10,s10,56 # 1038 <_entry-0x7fffefc8>
    8000504c:	e8845783          	lhu	a5,-376(s0)
    80005050:	08fdd063          	bge	s11,a5,800050d0 <kexec+0x19c>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80005054:	2d01                	sext.w	s10,s10
    80005056:	03800713          	li	a4,56
    8000505a:	86ea                	mv	a3,s10
    8000505c:	e1840613          	addi	a2,s0,-488
    80005060:	4581                	li	a1,0
    80005062:	8552                	mv	a0,s4
    80005064:	e63fe0ef          	jal	80003ec6 <readi>
    80005068:	03800793          	li	a5,56
    8000506c:	1cf51663          	bne	a0,a5,80005238 <kexec+0x304>
    if(ph.type != ELF_PROG_LOAD)
    80005070:	e1842783          	lw	a5,-488(s0)
    80005074:	4705                	li	a4,1
    80005076:	fce798e3          	bne	a5,a4,80005046 <kexec+0x112>
    if(ph.memsz < ph.filesz)
    8000507a:	e4043483          	ld	s1,-448(s0)
    8000507e:	e3843783          	ld	a5,-456(s0)
    80005082:	1af4ef63          	bltu	s1,a5,80005240 <kexec+0x30c>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    80005086:	e2843783          	ld	a5,-472(s0)
    8000508a:	94be                	add	s1,s1,a5
    8000508c:	1af4ee63          	bltu	s1,a5,80005248 <kexec+0x314>
    if(ph.vaddr % PGSIZE != 0)
    80005090:	df043703          	ld	a4,-528(s0)
    80005094:	8ff9                	and	a5,a5,a4
    80005096:	1a079d63          	bnez	a5,80005250 <kexec+0x31c>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    8000509a:	e1c42503          	lw	a0,-484(s0)
    8000509e:	e7dff0ef          	jal	80004f1a <flags2perm>
    800050a2:	86aa                	mv	a3,a0
    800050a4:	8626                	mv	a2,s1
    800050a6:	85ca                	mv	a1,s2
    800050a8:	855a                	mv	a0,s6
    800050aa:	c10fc0ef          	jal	800014ba <uvmalloc>
    800050ae:	e0a43423          	sd	a0,-504(s0)
    800050b2:	1a050363          	beqz	a0,80005258 <kexec+0x324>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    800050b6:	e2843b83          	ld	s7,-472(s0)
    800050ba:	e2042c03          	lw	s8,-480(s0)
    800050be:	e3842983          	lw	s3,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    800050c2:	00098463          	beqz	s3,800050ca <kexec+0x196>
    800050c6:	4901                	li	s2,0
    800050c8:	bfa1                	j	80005020 <kexec+0xec>
    sz = sz1;
    800050ca:	e0843903          	ld	s2,-504(s0)
    800050ce:	bfa5                	j	80005046 <kexec+0x112>
    800050d0:	7dba                	ld	s11,424(sp)
  iunlockput(ip);
    800050d2:	8552                	mv	a0,s4
    800050d4:	c6dfe0ef          	jal	80003d40 <iunlockput>
  end_op();
    800050d8:	cb2ff0ef          	jal	8000458a <end_op>
  p = myproc();
    800050dc:	babfc0ef          	jal	80001c86 <myproc>
    800050e0:	8aaa                	mv	s5,a0
  uint64 oldsz = p->sz;
    800050e2:	04853c83          	ld	s9,72(a0)
  sz = PGROUNDUP(sz);
    800050e6:	6985                	lui	s3,0x1
    800050e8:	19fd                	addi	s3,s3,-1 # fff <_entry-0x7ffff001>
    800050ea:	99ca                	add	s3,s3,s2
    800050ec:	77fd                	lui	a5,0xfffff
    800050ee:	00f9f9b3          	and	s3,s3,a5
  if((sz1 = uvmalloc(pagetable, sz, sz + (USERSTACK+1)*PGSIZE, PTE_W)) == 0)
    800050f2:	4691                	li	a3,4
    800050f4:	6609                	lui	a2,0x2
    800050f6:	964e                	add	a2,a2,s3
    800050f8:	85ce                	mv	a1,s3
    800050fa:	855a                	mv	a0,s6
    800050fc:	bbefc0ef          	jal	800014ba <uvmalloc>
    80005100:	892a                	mv	s2,a0
    80005102:	e0a43423          	sd	a0,-504(s0)
    80005106:	e519                	bnez	a0,80005114 <kexec+0x1e0>
  if(pagetable)
    80005108:	e1343423          	sd	s3,-504(s0)
    8000510c:	4a01                	li	s4,0
    8000510e:	aab1                	j	8000526a <kexec+0x336>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80005110:	4901                	li	s2,0
    80005112:	b7c1                	j	800050d2 <kexec+0x19e>
  uvmclear(pagetable, sz-(USERSTACK+1)*PGSIZE);
    80005114:	75f9                	lui	a1,0xffffe
    80005116:	95aa                	add	a1,a1,a0
    80005118:	855a                	mv	a0,s6
    8000511a:	e08fc0ef          	jal	80001722 <uvmclear>
  stackbase = sp - USERSTACK*PGSIZE;
    8000511e:	7bfd                	lui	s7,0xfffff
    80005120:	9bca                	add	s7,s7,s2
  for(argc = 0; argv[argc]; argc++) {
    80005122:	e0043783          	ld	a5,-512(s0)
    80005126:	6388                	ld	a0,0(a5)
    80005128:	cd39                	beqz	a0,80005186 <kexec+0x252>
    8000512a:	e9040993          	addi	s3,s0,-368
    8000512e:	f9040c13          	addi	s8,s0,-112
    80005132:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    80005134:	dcdfb0ef          	jal	80000f00 <strlen>
    80005138:	0015079b          	addiw	a5,a0,1
    8000513c:	40f907b3          	sub	a5,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80005140:	ff07f913          	andi	s2,a5,-16
    if(sp < stackbase)
    80005144:	11796e63          	bltu	s2,s7,80005260 <kexec+0x32c>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80005148:	e0043d03          	ld	s10,-512(s0)
    8000514c:	000d3a03          	ld	s4,0(s10)
    80005150:	8552                	mv	a0,s4
    80005152:	daffb0ef          	jal	80000f00 <strlen>
    80005156:	0015069b          	addiw	a3,a0,1
    8000515a:	8652                	mv	a2,s4
    8000515c:	85ca                	mv	a1,s2
    8000515e:	855a                	mv	a0,s6
    80005160:	fb0fc0ef          	jal	80001910 <copyout>
    80005164:	10054063          	bltz	a0,80005264 <kexec+0x330>
    ustack[argc] = sp;
    80005168:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    8000516c:	0485                	addi	s1,s1,1
    8000516e:	008d0793          	addi	a5,s10,8
    80005172:	e0f43023          	sd	a5,-512(s0)
    80005176:	008d3503          	ld	a0,8(s10)
    8000517a:	c909                	beqz	a0,8000518c <kexec+0x258>
    if(argc >= MAXARG)
    8000517c:	09a1                	addi	s3,s3,8
    8000517e:	fb899be3          	bne	s3,s8,80005134 <kexec+0x200>
  ip = 0;
    80005182:	4a01                	li	s4,0
    80005184:	a0dd                	j	8000526a <kexec+0x336>
  sp = sz;
    80005186:	e0843903          	ld	s2,-504(s0)
  for(argc = 0; argv[argc]; argc++) {
    8000518a:	4481                	li	s1,0
  ustack[argc] = 0;
    8000518c:	00349793          	slli	a5,s1,0x3
    80005190:	f9078793          	addi	a5,a5,-112 # ffffffffffffef90 <end+0xffffffff7ffb80b0>
    80005194:	97a2                	add	a5,a5,s0
    80005196:	f007b023          	sd	zero,-256(a5)
  sp -= (argc+1) * sizeof(uint64);
    8000519a:	00148693          	addi	a3,s1,1
    8000519e:	068e                	slli	a3,a3,0x3
    800051a0:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    800051a4:	ff097913          	andi	s2,s2,-16
  sz = sz1;
    800051a8:	e0843983          	ld	s3,-504(s0)
  if(sp < stackbase)
    800051ac:	f5796ee3          	bltu	s2,s7,80005108 <kexec+0x1d4>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    800051b0:	e9040613          	addi	a2,s0,-368
    800051b4:	85ca                	mv	a1,s2
    800051b6:	855a                	mv	a0,s6
    800051b8:	f58fc0ef          	jal	80001910 <copyout>
    800051bc:	0e054263          	bltz	a0,800052a0 <kexec+0x36c>
  p->trapframe->a1 = sp;
    800051c0:	058ab783          	ld	a5,88(s5) # 1058 <_entry-0x7fffefa8>
    800051c4:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    800051c8:	df843783          	ld	a5,-520(s0)
    800051cc:	0007c703          	lbu	a4,0(a5)
    800051d0:	cf11                	beqz	a4,800051ec <kexec+0x2b8>
    800051d2:	0785                	addi	a5,a5,1
    if(*s == '/')
    800051d4:	02f00693          	li	a3,47
    800051d8:	a039                	j	800051e6 <kexec+0x2b2>
      last = s+1;
    800051da:	def43c23          	sd	a5,-520(s0)
  for(last=s=path; *s; s++)
    800051de:	0785                	addi	a5,a5,1
    800051e0:	fff7c703          	lbu	a4,-1(a5)
    800051e4:	c701                	beqz	a4,800051ec <kexec+0x2b8>
    if(*s == '/')
    800051e6:	fed71ce3          	bne	a4,a3,800051de <kexec+0x2aa>
    800051ea:	bfc5                	j	800051da <kexec+0x2a6>
  safestrcpy(p->name, last, sizeof(p->name));
    800051ec:	4641                	li	a2,16
    800051ee:	df843583          	ld	a1,-520(s0)
    800051f2:	158a8513          	addi	a0,s5,344
    800051f6:	cd9fb0ef          	jal	80000ece <safestrcpy>
  oldpagetable = p->pagetable;
    800051fa:	050ab503          	ld	a0,80(s5)
  p->pagetable = pagetable;
    800051fe:	056ab823          	sd	s6,80(s5)
  p->sz = sz;
    80005202:	e0843783          	ld	a5,-504(s0)
    80005206:	04fab423          	sd	a5,72(s5)
  p->trapframe->epc = elf.entry;  // initial program counter = ulib.c:start()
    8000520a:	058ab783          	ld	a5,88(s5)
    8000520e:	e6843703          	ld	a4,-408(s0)
    80005212:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    80005214:	058ab783          	ld	a5,88(s5)
    80005218:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    8000521c:	85e6                	mv	a1,s9
    8000521e:	bf9fc0ef          	jal	80001e16 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80005222:	0004851b          	sext.w	a0,s1
    80005226:	79be                	ld	s3,488(sp)
    80005228:	7a1e                	ld	s4,480(sp)
    8000522a:	6afe                	ld	s5,472(sp)
    8000522c:	6b5e                	ld	s6,464(sp)
    8000522e:	6bbe                	ld	s7,456(sp)
    80005230:	6c1e                	ld	s8,448(sp)
    80005232:	7cfa                	ld	s9,440(sp)
    80005234:	7d5a                	ld	s10,432(sp)
    80005236:	b3b5                	j	80004fa2 <kexec+0x6e>
    80005238:	e1243423          	sd	s2,-504(s0)
    8000523c:	7dba                	ld	s11,424(sp)
    8000523e:	a035                	j	8000526a <kexec+0x336>
    80005240:	e1243423          	sd	s2,-504(s0)
    80005244:	7dba                	ld	s11,424(sp)
    80005246:	a015                	j	8000526a <kexec+0x336>
    80005248:	e1243423          	sd	s2,-504(s0)
    8000524c:	7dba                	ld	s11,424(sp)
    8000524e:	a831                	j	8000526a <kexec+0x336>
    80005250:	e1243423          	sd	s2,-504(s0)
    80005254:	7dba                	ld	s11,424(sp)
    80005256:	a811                	j	8000526a <kexec+0x336>
    80005258:	e1243423          	sd	s2,-504(s0)
    8000525c:	7dba                	ld	s11,424(sp)
    8000525e:	a031                	j	8000526a <kexec+0x336>
  ip = 0;
    80005260:	4a01                	li	s4,0
    80005262:	a021                	j	8000526a <kexec+0x336>
    80005264:	4a01                	li	s4,0
  if(pagetable)
    80005266:	a011                	j	8000526a <kexec+0x336>
    80005268:	7dba                	ld	s11,424(sp)
    proc_freepagetable(pagetable, sz);
    8000526a:	e0843583          	ld	a1,-504(s0)
    8000526e:	855a                	mv	a0,s6
    80005270:	ba7fc0ef          	jal	80001e16 <proc_freepagetable>
  return -1;
    80005274:	557d                	li	a0,-1
  if(ip){
    80005276:	000a1b63          	bnez	s4,8000528c <kexec+0x358>
    8000527a:	79be                	ld	s3,488(sp)
    8000527c:	7a1e                	ld	s4,480(sp)
    8000527e:	6afe                	ld	s5,472(sp)
    80005280:	6b5e                	ld	s6,464(sp)
    80005282:	6bbe                	ld	s7,456(sp)
    80005284:	6c1e                	ld	s8,448(sp)
    80005286:	7cfa                	ld	s9,440(sp)
    80005288:	7d5a                	ld	s10,432(sp)
    8000528a:	bb21                	j	80004fa2 <kexec+0x6e>
    8000528c:	79be                	ld	s3,488(sp)
    8000528e:	6afe                	ld	s5,472(sp)
    80005290:	6b5e                	ld	s6,464(sp)
    80005292:	6bbe                	ld	s7,456(sp)
    80005294:	6c1e                	ld	s8,448(sp)
    80005296:	7cfa                	ld	s9,440(sp)
    80005298:	7d5a                	ld	s10,432(sp)
    8000529a:	b9ed                	j	80004f94 <kexec+0x60>
    8000529c:	6b5e                	ld	s6,464(sp)
    8000529e:	b9dd                	j	80004f94 <kexec+0x60>
  sz = sz1;
    800052a0:	e0843983          	ld	s3,-504(s0)
    800052a4:	b595                	j	80005108 <kexec+0x1d4>

00000000800052a6 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    800052a6:	7179                	addi	sp,sp,-48
    800052a8:	f406                	sd	ra,40(sp)
    800052aa:	f022                	sd	s0,32(sp)
    800052ac:	ec26                	sd	s1,24(sp)
    800052ae:	e84a                	sd	s2,16(sp)
    800052b0:	1800                	addi	s0,sp,48
    800052b2:	892e                	mv	s2,a1
    800052b4:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    800052b6:	fdc40593          	addi	a1,s0,-36
    800052ba:	bbdfd0ef          	jal	80002e76 <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    800052be:	fdc42703          	lw	a4,-36(s0)
    800052c2:	47bd                	li	a5,15
    800052c4:	02e7e963          	bltu	a5,a4,800052f6 <argfd+0x50>
    800052c8:	9bffc0ef          	jal	80001c86 <myproc>
    800052cc:	fdc42703          	lw	a4,-36(s0)
    800052d0:	01a70793          	addi	a5,a4,26
    800052d4:	078e                	slli	a5,a5,0x3
    800052d6:	953e                	add	a0,a0,a5
    800052d8:	611c                	ld	a5,0(a0)
    800052da:	c385                	beqz	a5,800052fa <argfd+0x54>
    return -1;
  if(pfd)
    800052dc:	00090463          	beqz	s2,800052e4 <argfd+0x3e>
    *pfd = fd;
    800052e0:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    800052e4:	4501                	li	a0,0
  if(pf)
    800052e6:	c091                	beqz	s1,800052ea <argfd+0x44>
    *pf = f;
    800052e8:	e09c                	sd	a5,0(s1)
}
    800052ea:	70a2                	ld	ra,40(sp)
    800052ec:	7402                	ld	s0,32(sp)
    800052ee:	64e2                	ld	s1,24(sp)
    800052f0:	6942                	ld	s2,16(sp)
    800052f2:	6145                	addi	sp,sp,48
    800052f4:	8082                	ret
    return -1;
    800052f6:	557d                	li	a0,-1
    800052f8:	bfcd                	j	800052ea <argfd+0x44>
    800052fa:	557d                	li	a0,-1
    800052fc:	b7fd                	j	800052ea <argfd+0x44>

00000000800052fe <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    800052fe:	1101                	addi	sp,sp,-32
    80005300:	ec06                	sd	ra,24(sp)
    80005302:	e822                	sd	s0,16(sp)
    80005304:	e426                	sd	s1,8(sp)
    80005306:	1000                	addi	s0,sp,32
    80005308:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    8000530a:	97dfc0ef          	jal	80001c86 <myproc>
    8000530e:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    80005310:	0d050793          	addi	a5,a0,208
    80005314:	4501                	li	a0,0
    80005316:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    80005318:	6398                	ld	a4,0(a5)
    8000531a:	cb19                	beqz	a4,80005330 <fdalloc+0x32>
  for(fd = 0; fd < NOFILE; fd++){
    8000531c:	2505                	addiw	a0,a0,1
    8000531e:	07a1                	addi	a5,a5,8
    80005320:	fed51ce3          	bne	a0,a3,80005318 <fdalloc+0x1a>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80005324:	557d                	li	a0,-1
}
    80005326:	60e2                	ld	ra,24(sp)
    80005328:	6442                	ld	s0,16(sp)
    8000532a:	64a2                	ld	s1,8(sp)
    8000532c:	6105                	addi	sp,sp,32
    8000532e:	8082                	ret
      p->ofile[fd] = f;
    80005330:	01a50793          	addi	a5,a0,26
    80005334:	078e                	slli	a5,a5,0x3
    80005336:	963e                	add	a2,a2,a5
    80005338:	e204                	sd	s1,0(a2)
      return fd;
    8000533a:	b7f5                	j	80005326 <fdalloc+0x28>

000000008000533c <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    8000533c:	715d                	addi	sp,sp,-80
    8000533e:	e486                	sd	ra,72(sp)
    80005340:	e0a2                	sd	s0,64(sp)
    80005342:	fc26                	sd	s1,56(sp)
    80005344:	f84a                	sd	s2,48(sp)
    80005346:	f44e                	sd	s3,40(sp)
    80005348:	ec56                	sd	s5,24(sp)
    8000534a:	e85a                	sd	s6,16(sp)
    8000534c:	0880                	addi	s0,sp,80
    8000534e:	8b2e                	mv	s6,a1
    80005350:	89b2                	mv	s3,a2
    80005352:	8936                	mv	s2,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    80005354:	fb040593          	addi	a1,s0,-80
    80005358:	80eff0ef          	jal	80004366 <nameiparent>
    8000535c:	84aa                	mv	s1,a0
    8000535e:	10050a63          	beqz	a0,80005472 <create+0x136>
    return 0;

  ilock(dp);
    80005362:	fd4fe0ef          	jal	80003b36 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    80005366:	4601                	li	a2,0
    80005368:	fb040593          	addi	a1,s0,-80
    8000536c:	8526                	mv	a0,s1
    8000536e:	d79fe0ef          	jal	800040e6 <dirlookup>
    80005372:	8aaa                	mv	s5,a0
    80005374:	c129                	beqz	a0,800053b6 <create+0x7a>
    iunlockput(dp);
    80005376:	8526                	mv	a0,s1
    80005378:	9c9fe0ef          	jal	80003d40 <iunlockput>
    ilock(ip);
    8000537c:	8556                	mv	a0,s5
    8000537e:	fb8fe0ef          	jal	80003b36 <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80005382:	4789                	li	a5,2
    80005384:	02fb1463          	bne	s6,a5,800053ac <create+0x70>
    80005388:	044ad783          	lhu	a5,68(s5)
    8000538c:	37f9                	addiw	a5,a5,-2
    8000538e:	17c2                	slli	a5,a5,0x30
    80005390:	93c1                	srli	a5,a5,0x30
    80005392:	4705                	li	a4,1
    80005394:	00f76c63          	bltu	a4,a5,800053ac <create+0x70>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    80005398:	8556                	mv	a0,s5
    8000539a:	60a6                	ld	ra,72(sp)
    8000539c:	6406                	ld	s0,64(sp)
    8000539e:	74e2                	ld	s1,56(sp)
    800053a0:	7942                	ld	s2,48(sp)
    800053a2:	79a2                	ld	s3,40(sp)
    800053a4:	6ae2                	ld	s5,24(sp)
    800053a6:	6b42                	ld	s6,16(sp)
    800053a8:	6161                	addi	sp,sp,80
    800053aa:	8082                	ret
    iunlockput(ip);
    800053ac:	8556                	mv	a0,s5
    800053ae:	993fe0ef          	jal	80003d40 <iunlockput>
    return 0;
    800053b2:	4a81                	li	s5,0
    800053b4:	b7d5                	j	80005398 <create+0x5c>
    800053b6:	f052                	sd	s4,32(sp)
  if((ip = ialloc(dp->dev, type)) == 0){
    800053b8:	85da                	mv	a1,s6
    800053ba:	4088                	lw	a0,0(s1)
    800053bc:	e0afe0ef          	jal	800039c6 <ialloc>
    800053c0:	8a2a                	mv	s4,a0
    800053c2:	cd15                	beqz	a0,800053fe <create+0xc2>
  ilock(ip);
    800053c4:	f72fe0ef          	jal	80003b36 <ilock>
  ip->major = major;
    800053c8:	053a1323          	sh	s3,70(s4)
  ip->minor = minor;
    800053cc:	052a1423          	sh	s2,72(s4)
  ip->nlink = 1;
    800053d0:	4905                	li	s2,1
    800053d2:	052a1523          	sh	s2,74(s4)
  iupdate(ip);
    800053d6:	8552                	mv	a0,s4
    800053d8:	eaafe0ef          	jal	80003a82 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    800053dc:	032b0763          	beq	s6,s2,8000540a <create+0xce>
  if(dirlink(dp, name, ip->inum) < 0)
    800053e0:	004a2603          	lw	a2,4(s4)
    800053e4:	fb040593          	addi	a1,s0,-80
    800053e8:	8526                	mv	a0,s1
    800053ea:	ec9fe0ef          	jal	800042b2 <dirlink>
    800053ee:	06054563          	bltz	a0,80005458 <create+0x11c>
  iunlockput(dp);
    800053f2:	8526                	mv	a0,s1
    800053f4:	94dfe0ef          	jal	80003d40 <iunlockput>
  return ip;
    800053f8:	8ad2                	mv	s5,s4
    800053fa:	7a02                	ld	s4,32(sp)
    800053fc:	bf71                	j	80005398 <create+0x5c>
    iunlockput(dp);
    800053fe:	8526                	mv	a0,s1
    80005400:	941fe0ef          	jal	80003d40 <iunlockput>
    return 0;
    80005404:	8ad2                	mv	s5,s4
    80005406:	7a02                	ld	s4,32(sp)
    80005408:	bf41                	j	80005398 <create+0x5c>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    8000540a:	004a2603          	lw	a2,4(s4)
    8000540e:	00003597          	auipc	a1,0x3
    80005412:	1fa58593          	addi	a1,a1,506 # 80008608 <etext+0x608>
    80005416:	8552                	mv	a0,s4
    80005418:	e9bfe0ef          	jal	800042b2 <dirlink>
    8000541c:	02054e63          	bltz	a0,80005458 <create+0x11c>
    80005420:	40d0                	lw	a2,4(s1)
    80005422:	00003597          	auipc	a1,0x3
    80005426:	1ee58593          	addi	a1,a1,494 # 80008610 <etext+0x610>
    8000542a:	8552                	mv	a0,s4
    8000542c:	e87fe0ef          	jal	800042b2 <dirlink>
    80005430:	02054463          	bltz	a0,80005458 <create+0x11c>
  if(dirlink(dp, name, ip->inum) < 0)
    80005434:	004a2603          	lw	a2,4(s4)
    80005438:	fb040593          	addi	a1,s0,-80
    8000543c:	8526                	mv	a0,s1
    8000543e:	e75fe0ef          	jal	800042b2 <dirlink>
    80005442:	00054b63          	bltz	a0,80005458 <create+0x11c>
    dp->nlink++;  // for ".."
    80005446:	04a4d783          	lhu	a5,74(s1)
    8000544a:	2785                	addiw	a5,a5,1
    8000544c:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80005450:	8526                	mv	a0,s1
    80005452:	e30fe0ef          	jal	80003a82 <iupdate>
    80005456:	bf71                	j	800053f2 <create+0xb6>
  ip->nlink = 0;
    80005458:	040a1523          	sh	zero,74(s4)
  iupdate(ip);
    8000545c:	8552                	mv	a0,s4
    8000545e:	e24fe0ef          	jal	80003a82 <iupdate>
  iunlockput(ip);
    80005462:	8552                	mv	a0,s4
    80005464:	8ddfe0ef          	jal	80003d40 <iunlockput>
  iunlockput(dp);
    80005468:	8526                	mv	a0,s1
    8000546a:	8d7fe0ef          	jal	80003d40 <iunlockput>
  return 0;
    8000546e:	7a02                	ld	s4,32(sp)
    80005470:	b725                	j	80005398 <create+0x5c>
    return 0;
    80005472:	8aaa                	mv	s5,a0
    80005474:	b715                	j	80005398 <create+0x5c>

0000000080005476 <sys_dup>:
{
    80005476:	7179                	addi	sp,sp,-48
    80005478:	f406                	sd	ra,40(sp)
    8000547a:	f022                	sd	s0,32(sp)
    8000547c:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    8000547e:	fd840613          	addi	a2,s0,-40
    80005482:	4581                	li	a1,0
    80005484:	4501                	li	a0,0
    80005486:	e21ff0ef          	jal	800052a6 <argfd>
    return -1;
    8000548a:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    8000548c:	02054363          	bltz	a0,800054b2 <sys_dup+0x3c>
    80005490:	ec26                	sd	s1,24(sp)
    80005492:	e84a                	sd	s2,16(sp)
  if((fd=fdalloc(f)) < 0)
    80005494:	fd843903          	ld	s2,-40(s0)
    80005498:	854a                	mv	a0,s2
    8000549a:	e65ff0ef          	jal	800052fe <fdalloc>
    8000549e:	84aa                	mv	s1,a0
    return -1;
    800054a0:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    800054a2:	00054d63          	bltz	a0,800054bc <sys_dup+0x46>
  filedup(f);
    800054a6:	854a                	mv	a0,s2
    800054a8:	c3eff0ef          	jal	800048e6 <filedup>
  return fd;
    800054ac:	87a6                	mv	a5,s1
    800054ae:	64e2                	ld	s1,24(sp)
    800054b0:	6942                	ld	s2,16(sp)
}
    800054b2:	853e                	mv	a0,a5
    800054b4:	70a2                	ld	ra,40(sp)
    800054b6:	7402                	ld	s0,32(sp)
    800054b8:	6145                	addi	sp,sp,48
    800054ba:	8082                	ret
    800054bc:	64e2                	ld	s1,24(sp)
    800054be:	6942                	ld	s2,16(sp)
    800054c0:	bfcd                	j	800054b2 <sys_dup+0x3c>

00000000800054c2 <sys_read>:
{
    800054c2:	7179                	addi	sp,sp,-48
    800054c4:	f406                	sd	ra,40(sp)
    800054c6:	f022                	sd	s0,32(sp)
    800054c8:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    800054ca:	fd840593          	addi	a1,s0,-40
    800054ce:	4505                	li	a0,1
    800054d0:	9c3fd0ef          	jal	80002e92 <argaddr>
  argint(2, &n);
    800054d4:	fe440593          	addi	a1,s0,-28
    800054d8:	4509                	li	a0,2
    800054da:	99dfd0ef          	jal	80002e76 <argint>
  if(argfd(0, 0, &f) < 0)
    800054de:	fe840613          	addi	a2,s0,-24
    800054e2:	4581                	li	a1,0
    800054e4:	4501                	li	a0,0
    800054e6:	dc1ff0ef          	jal	800052a6 <argfd>
    800054ea:	87aa                	mv	a5,a0
    return -1;
    800054ec:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    800054ee:	0007ca63          	bltz	a5,80005502 <sys_read+0x40>
  return fileread(f, p, n);
    800054f2:	fe442603          	lw	a2,-28(s0)
    800054f6:	fd843583          	ld	a1,-40(s0)
    800054fa:	fe843503          	ld	a0,-24(s0)
    800054fe:	d4eff0ef          	jal	80004a4c <fileread>
}
    80005502:	70a2                	ld	ra,40(sp)
    80005504:	7402                	ld	s0,32(sp)
    80005506:	6145                	addi	sp,sp,48
    80005508:	8082                	ret

000000008000550a <sys_write>:
{
    8000550a:	7179                	addi	sp,sp,-48
    8000550c:	f406                	sd	ra,40(sp)
    8000550e:	f022                	sd	s0,32(sp)
    80005510:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80005512:	fd840593          	addi	a1,s0,-40
    80005516:	4505                	li	a0,1
    80005518:	97bfd0ef          	jal	80002e92 <argaddr>
  argint(2, &n);
    8000551c:	fe440593          	addi	a1,s0,-28
    80005520:	4509                	li	a0,2
    80005522:	955fd0ef          	jal	80002e76 <argint>
  if(argfd(0, 0, &f) < 0)
    80005526:	fe840613          	addi	a2,s0,-24
    8000552a:	4581                	li	a1,0
    8000552c:	4501                	li	a0,0
    8000552e:	d79ff0ef          	jal	800052a6 <argfd>
    80005532:	87aa                	mv	a5,a0
    return -1;
    80005534:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80005536:	0007ca63          	bltz	a5,8000554a <sys_write+0x40>
  return filewrite(f, p, n);
    8000553a:	fe442603          	lw	a2,-28(s0)
    8000553e:	fd843583          	ld	a1,-40(s0)
    80005542:	fe843503          	ld	a0,-24(s0)
    80005546:	dc4ff0ef          	jal	80004b0a <filewrite>
}
    8000554a:	70a2                	ld	ra,40(sp)
    8000554c:	7402                	ld	s0,32(sp)
    8000554e:	6145                	addi	sp,sp,48
    80005550:	8082                	ret

0000000080005552 <sys_close>:
{
    80005552:	1101                	addi	sp,sp,-32
    80005554:	ec06                	sd	ra,24(sp)
    80005556:	e822                	sd	s0,16(sp)
    80005558:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    8000555a:	fe040613          	addi	a2,s0,-32
    8000555e:	fec40593          	addi	a1,s0,-20
    80005562:	4501                	li	a0,0
    80005564:	d43ff0ef          	jal	800052a6 <argfd>
    return -1;
    80005568:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    8000556a:	02054063          	bltz	a0,8000558a <sys_close+0x38>
  myproc()->ofile[fd] = 0;
    8000556e:	f18fc0ef          	jal	80001c86 <myproc>
    80005572:	fec42783          	lw	a5,-20(s0)
    80005576:	07e9                	addi	a5,a5,26
    80005578:	078e                	slli	a5,a5,0x3
    8000557a:	953e                	add	a0,a0,a5
    8000557c:	00053023          	sd	zero,0(a0)
  fileclose(f);
    80005580:	fe043503          	ld	a0,-32(s0)
    80005584:	ba8ff0ef          	jal	8000492c <fileclose>
  return 0;
    80005588:	4781                	li	a5,0
}
    8000558a:	853e                	mv	a0,a5
    8000558c:	60e2                	ld	ra,24(sp)
    8000558e:	6442                	ld	s0,16(sp)
    80005590:	6105                	addi	sp,sp,32
    80005592:	8082                	ret

0000000080005594 <sys_fstat>:
{
    80005594:	1101                	addi	sp,sp,-32
    80005596:	ec06                	sd	ra,24(sp)
    80005598:	e822                	sd	s0,16(sp)
    8000559a:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    8000559c:	fe040593          	addi	a1,s0,-32
    800055a0:	4505                	li	a0,1
    800055a2:	8f1fd0ef          	jal	80002e92 <argaddr>
  if(argfd(0, 0, &f) < 0)
    800055a6:	fe840613          	addi	a2,s0,-24
    800055aa:	4581                	li	a1,0
    800055ac:	4501                	li	a0,0
    800055ae:	cf9ff0ef          	jal	800052a6 <argfd>
    800055b2:	87aa                	mv	a5,a0
    return -1;
    800055b4:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    800055b6:	0007c863          	bltz	a5,800055c6 <sys_fstat+0x32>
  return filestat(f, st);
    800055ba:	fe043583          	ld	a1,-32(s0)
    800055be:	fe843503          	ld	a0,-24(s0)
    800055c2:	c2cff0ef          	jal	800049ee <filestat>
}
    800055c6:	60e2                	ld	ra,24(sp)
    800055c8:	6442                	ld	s0,16(sp)
    800055ca:	6105                	addi	sp,sp,32
    800055cc:	8082                	ret

00000000800055ce <sys_link>:
{
    800055ce:	7169                	addi	sp,sp,-304
    800055d0:	f606                	sd	ra,296(sp)
    800055d2:	f222                	sd	s0,288(sp)
    800055d4:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800055d6:	08000613          	li	a2,128
    800055da:	ed040593          	addi	a1,s0,-304
    800055de:	4501                	li	a0,0
    800055e0:	8cffd0ef          	jal	80002eae <argstr>
    return -1;
    800055e4:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800055e6:	0c054e63          	bltz	a0,800056c2 <sys_link+0xf4>
    800055ea:	08000613          	li	a2,128
    800055ee:	f5040593          	addi	a1,s0,-176
    800055f2:	4505                	li	a0,1
    800055f4:	8bbfd0ef          	jal	80002eae <argstr>
    return -1;
    800055f8:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800055fa:	0c054463          	bltz	a0,800056c2 <sys_link+0xf4>
    800055fe:	ee26                	sd	s1,280(sp)
  begin_op();
    80005600:	f21fe0ef          	jal	80004520 <begin_op>
  if((ip = namei(old)) == 0){
    80005604:	ed040513          	addi	a0,s0,-304
    80005608:	d45fe0ef          	jal	8000434c <namei>
    8000560c:	84aa                	mv	s1,a0
    8000560e:	c53d                	beqz	a0,8000567c <sys_link+0xae>
  ilock(ip);
    80005610:	d26fe0ef          	jal	80003b36 <ilock>
  if(ip->type == T_DIR){
    80005614:	04449703          	lh	a4,68(s1)
    80005618:	4785                	li	a5,1
    8000561a:	06f70663          	beq	a4,a5,80005686 <sys_link+0xb8>
    8000561e:	ea4a                	sd	s2,272(sp)
  ip->nlink++;
    80005620:	04a4d783          	lhu	a5,74(s1)
    80005624:	2785                	addiw	a5,a5,1
    80005626:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    8000562a:	8526                	mv	a0,s1
    8000562c:	c56fe0ef          	jal	80003a82 <iupdate>
  iunlock(ip);
    80005630:	8526                	mv	a0,s1
    80005632:	db2fe0ef          	jal	80003be4 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    80005636:	fd040593          	addi	a1,s0,-48
    8000563a:	f5040513          	addi	a0,s0,-176
    8000563e:	d29fe0ef          	jal	80004366 <nameiparent>
    80005642:	892a                	mv	s2,a0
    80005644:	cd21                	beqz	a0,8000569c <sys_link+0xce>
  ilock(dp);
    80005646:	cf0fe0ef          	jal	80003b36 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    8000564a:	00092703          	lw	a4,0(s2)
    8000564e:	409c                	lw	a5,0(s1)
    80005650:	04f71363          	bne	a4,a5,80005696 <sys_link+0xc8>
    80005654:	40d0                	lw	a2,4(s1)
    80005656:	fd040593          	addi	a1,s0,-48
    8000565a:	854a                	mv	a0,s2
    8000565c:	c57fe0ef          	jal	800042b2 <dirlink>
    80005660:	02054b63          	bltz	a0,80005696 <sys_link+0xc8>
  iunlockput(dp);
    80005664:	854a                	mv	a0,s2
    80005666:	edafe0ef          	jal	80003d40 <iunlockput>
  iput(ip);
    8000566a:	8526                	mv	a0,s1
    8000566c:	e4cfe0ef          	jal	80003cb8 <iput>
  end_op();
    80005670:	f1bfe0ef          	jal	8000458a <end_op>
  return 0;
    80005674:	4781                	li	a5,0
    80005676:	64f2                	ld	s1,280(sp)
    80005678:	6952                	ld	s2,272(sp)
    8000567a:	a0a1                	j	800056c2 <sys_link+0xf4>
    end_op();
    8000567c:	f0ffe0ef          	jal	8000458a <end_op>
    return -1;
    80005680:	57fd                	li	a5,-1
    80005682:	64f2                	ld	s1,280(sp)
    80005684:	a83d                	j	800056c2 <sys_link+0xf4>
    iunlockput(ip);
    80005686:	8526                	mv	a0,s1
    80005688:	eb8fe0ef          	jal	80003d40 <iunlockput>
    end_op();
    8000568c:	efffe0ef          	jal	8000458a <end_op>
    return -1;
    80005690:	57fd                	li	a5,-1
    80005692:	64f2                	ld	s1,280(sp)
    80005694:	a03d                	j	800056c2 <sys_link+0xf4>
    iunlockput(dp);
    80005696:	854a                	mv	a0,s2
    80005698:	ea8fe0ef          	jal	80003d40 <iunlockput>
  ilock(ip);
    8000569c:	8526                	mv	a0,s1
    8000569e:	c98fe0ef          	jal	80003b36 <ilock>
  ip->nlink--;
    800056a2:	04a4d783          	lhu	a5,74(s1)
    800056a6:	37fd                	addiw	a5,a5,-1
    800056a8:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    800056ac:	8526                	mv	a0,s1
    800056ae:	bd4fe0ef          	jal	80003a82 <iupdate>
  iunlockput(ip);
    800056b2:	8526                	mv	a0,s1
    800056b4:	e8cfe0ef          	jal	80003d40 <iunlockput>
  end_op();
    800056b8:	ed3fe0ef          	jal	8000458a <end_op>
  return -1;
    800056bc:	57fd                	li	a5,-1
    800056be:	64f2                	ld	s1,280(sp)
    800056c0:	6952                	ld	s2,272(sp)
}
    800056c2:	853e                	mv	a0,a5
    800056c4:	70b2                	ld	ra,296(sp)
    800056c6:	7412                	ld	s0,288(sp)
    800056c8:	6155                	addi	sp,sp,304
    800056ca:	8082                	ret

00000000800056cc <sys_unlink>:
{
    800056cc:	7151                	addi	sp,sp,-240
    800056ce:	f586                	sd	ra,232(sp)
    800056d0:	f1a2                	sd	s0,224(sp)
    800056d2:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    800056d4:	08000613          	li	a2,128
    800056d8:	f3040593          	addi	a1,s0,-208
    800056dc:	4501                	li	a0,0
    800056de:	fd0fd0ef          	jal	80002eae <argstr>
    800056e2:	16054063          	bltz	a0,80005842 <sys_unlink+0x176>
    800056e6:	eda6                	sd	s1,216(sp)
  begin_op();
    800056e8:	e39fe0ef          	jal	80004520 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    800056ec:	fb040593          	addi	a1,s0,-80
    800056f0:	f3040513          	addi	a0,s0,-208
    800056f4:	c73fe0ef          	jal	80004366 <nameiparent>
    800056f8:	84aa                	mv	s1,a0
    800056fa:	c945                	beqz	a0,800057aa <sys_unlink+0xde>
  ilock(dp);
    800056fc:	c3afe0ef          	jal	80003b36 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80005700:	00003597          	auipc	a1,0x3
    80005704:	f0858593          	addi	a1,a1,-248 # 80008608 <etext+0x608>
    80005708:	fb040513          	addi	a0,s0,-80
    8000570c:	9c5fe0ef          	jal	800040d0 <namecmp>
    80005710:	10050e63          	beqz	a0,8000582c <sys_unlink+0x160>
    80005714:	00003597          	auipc	a1,0x3
    80005718:	efc58593          	addi	a1,a1,-260 # 80008610 <etext+0x610>
    8000571c:	fb040513          	addi	a0,s0,-80
    80005720:	9b1fe0ef          	jal	800040d0 <namecmp>
    80005724:	10050463          	beqz	a0,8000582c <sys_unlink+0x160>
    80005728:	e9ca                	sd	s2,208(sp)
  if((ip = dirlookup(dp, name, &off)) == 0)
    8000572a:	f2c40613          	addi	a2,s0,-212
    8000572e:	fb040593          	addi	a1,s0,-80
    80005732:	8526                	mv	a0,s1
    80005734:	9b3fe0ef          	jal	800040e6 <dirlookup>
    80005738:	892a                	mv	s2,a0
    8000573a:	0e050863          	beqz	a0,8000582a <sys_unlink+0x15e>
  ilock(ip);
    8000573e:	bf8fe0ef          	jal	80003b36 <ilock>
  if(ip->nlink < 1)
    80005742:	04a91783          	lh	a5,74(s2)
    80005746:	06f05763          	blez	a5,800057b4 <sys_unlink+0xe8>
  if(ip->type == T_DIR && !isdirempty(ip)){
    8000574a:	04491703          	lh	a4,68(s2)
    8000574e:	4785                	li	a5,1
    80005750:	06f70963          	beq	a4,a5,800057c2 <sys_unlink+0xf6>
  memset(&de, 0, sizeof(de));
    80005754:	4641                	li	a2,16
    80005756:	4581                	li	a1,0
    80005758:	fc040513          	addi	a0,s0,-64
    8000575c:	e34fb0ef          	jal	80000d90 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005760:	4741                	li	a4,16
    80005762:	f2c42683          	lw	a3,-212(s0)
    80005766:	fc040613          	addi	a2,s0,-64
    8000576a:	4581                	li	a1,0
    8000576c:	8526                	mv	a0,s1
    8000576e:	855fe0ef          	jal	80003fc2 <writei>
    80005772:	47c1                	li	a5,16
    80005774:	08f51b63          	bne	a0,a5,8000580a <sys_unlink+0x13e>
  if(ip->type == T_DIR){
    80005778:	04491703          	lh	a4,68(s2)
    8000577c:	4785                	li	a5,1
    8000577e:	08f70d63          	beq	a4,a5,80005818 <sys_unlink+0x14c>
  iunlockput(dp);
    80005782:	8526                	mv	a0,s1
    80005784:	dbcfe0ef          	jal	80003d40 <iunlockput>
  ip->nlink--;
    80005788:	04a95783          	lhu	a5,74(s2)
    8000578c:	37fd                	addiw	a5,a5,-1
    8000578e:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80005792:	854a                	mv	a0,s2
    80005794:	aeefe0ef          	jal	80003a82 <iupdate>
  iunlockput(ip);
    80005798:	854a                	mv	a0,s2
    8000579a:	da6fe0ef          	jal	80003d40 <iunlockput>
  end_op();
    8000579e:	dedfe0ef          	jal	8000458a <end_op>
  return 0;
    800057a2:	4501                	li	a0,0
    800057a4:	64ee                	ld	s1,216(sp)
    800057a6:	694e                	ld	s2,208(sp)
    800057a8:	a849                	j	8000583a <sys_unlink+0x16e>
    end_op();
    800057aa:	de1fe0ef          	jal	8000458a <end_op>
    return -1;
    800057ae:	557d                	li	a0,-1
    800057b0:	64ee                	ld	s1,216(sp)
    800057b2:	a061                	j	8000583a <sys_unlink+0x16e>
    800057b4:	e5ce                	sd	s3,200(sp)
    panic("unlink: nlink < 1");
    800057b6:	00003517          	auipc	a0,0x3
    800057ba:	e6250513          	addi	a0,a0,-414 # 80008618 <etext+0x618>
    800057be:	854fb0ef          	jal	80000812 <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    800057c2:	04c92703          	lw	a4,76(s2)
    800057c6:	02000793          	li	a5,32
    800057ca:	f8e7f5e3          	bgeu	a5,a4,80005754 <sys_unlink+0x88>
    800057ce:	e5ce                	sd	s3,200(sp)
    800057d0:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800057d4:	4741                	li	a4,16
    800057d6:	86ce                	mv	a3,s3
    800057d8:	f1840613          	addi	a2,s0,-232
    800057dc:	4581                	li	a1,0
    800057de:	854a                	mv	a0,s2
    800057e0:	ee6fe0ef          	jal	80003ec6 <readi>
    800057e4:	47c1                	li	a5,16
    800057e6:	00f51c63          	bne	a0,a5,800057fe <sys_unlink+0x132>
    if(de.inum != 0)
    800057ea:	f1845783          	lhu	a5,-232(s0)
    800057ee:	efa1                	bnez	a5,80005846 <sys_unlink+0x17a>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    800057f0:	29c1                	addiw	s3,s3,16
    800057f2:	04c92783          	lw	a5,76(s2)
    800057f6:	fcf9efe3          	bltu	s3,a5,800057d4 <sys_unlink+0x108>
    800057fa:	69ae                	ld	s3,200(sp)
    800057fc:	bfa1                	j	80005754 <sys_unlink+0x88>
      panic("isdirempty: readi");
    800057fe:	00003517          	auipc	a0,0x3
    80005802:	e3250513          	addi	a0,a0,-462 # 80008630 <etext+0x630>
    80005806:	80cfb0ef          	jal	80000812 <panic>
    8000580a:	e5ce                	sd	s3,200(sp)
    panic("unlink: writei");
    8000580c:	00003517          	auipc	a0,0x3
    80005810:	e3c50513          	addi	a0,a0,-452 # 80008648 <etext+0x648>
    80005814:	ffffa0ef          	jal	80000812 <panic>
    dp->nlink--;
    80005818:	04a4d783          	lhu	a5,74(s1)
    8000581c:	37fd                	addiw	a5,a5,-1
    8000581e:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80005822:	8526                	mv	a0,s1
    80005824:	a5efe0ef          	jal	80003a82 <iupdate>
    80005828:	bfa9                	j	80005782 <sys_unlink+0xb6>
    8000582a:	694e                	ld	s2,208(sp)
  iunlockput(dp);
    8000582c:	8526                	mv	a0,s1
    8000582e:	d12fe0ef          	jal	80003d40 <iunlockput>
  end_op();
    80005832:	d59fe0ef          	jal	8000458a <end_op>
  return -1;
    80005836:	557d                	li	a0,-1
    80005838:	64ee                	ld	s1,216(sp)
}
    8000583a:	70ae                	ld	ra,232(sp)
    8000583c:	740e                	ld	s0,224(sp)
    8000583e:	616d                	addi	sp,sp,240
    80005840:	8082                	ret
    return -1;
    80005842:	557d                	li	a0,-1
    80005844:	bfdd                	j	8000583a <sys_unlink+0x16e>
    iunlockput(ip);
    80005846:	854a                	mv	a0,s2
    80005848:	cf8fe0ef          	jal	80003d40 <iunlockput>
    goto bad;
    8000584c:	694e                	ld	s2,208(sp)
    8000584e:	69ae                	ld	s3,200(sp)
    80005850:	bff1                	j	8000582c <sys_unlink+0x160>

0000000080005852 <sys_open>:

uint64
sys_open(void)
{
    80005852:	7131                	addi	sp,sp,-192
    80005854:	fd06                	sd	ra,184(sp)
    80005856:	f922                	sd	s0,176(sp)
    80005858:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    8000585a:	f4c40593          	addi	a1,s0,-180
    8000585e:	4505                	li	a0,1
    80005860:	e16fd0ef          	jal	80002e76 <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    80005864:	08000613          	li	a2,128
    80005868:	f5040593          	addi	a1,s0,-176
    8000586c:	4501                	li	a0,0
    8000586e:	e40fd0ef          	jal	80002eae <argstr>
    80005872:	87aa                	mv	a5,a0
    return -1;
    80005874:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    80005876:	0a07c263          	bltz	a5,8000591a <sys_open+0xc8>
    8000587a:	f526                	sd	s1,168(sp)

  begin_op();
    8000587c:	ca5fe0ef          	jal	80004520 <begin_op>

  if(omode & O_CREATE){
    80005880:	f4c42783          	lw	a5,-180(s0)
    80005884:	2007f793          	andi	a5,a5,512
    80005888:	c3d5                	beqz	a5,8000592c <sys_open+0xda>
    ip = create(path, T_FILE, 0, 0);
    8000588a:	4681                	li	a3,0
    8000588c:	4601                	li	a2,0
    8000588e:	4589                	li	a1,2
    80005890:	f5040513          	addi	a0,s0,-176
    80005894:	aa9ff0ef          	jal	8000533c <create>
    80005898:	84aa                	mv	s1,a0
    if(ip == 0){
    8000589a:	c541                	beqz	a0,80005922 <sys_open+0xd0>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    8000589c:	04449703          	lh	a4,68(s1)
    800058a0:	478d                	li	a5,3
    800058a2:	00f71763          	bne	a4,a5,800058b0 <sys_open+0x5e>
    800058a6:	0464d703          	lhu	a4,70(s1)
    800058aa:	47a5                	li	a5,9
    800058ac:	0ae7ed63          	bltu	a5,a4,80005966 <sys_open+0x114>
    800058b0:	f14a                	sd	s2,160(sp)
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    800058b2:	fd7fe0ef          	jal	80004888 <filealloc>
    800058b6:	892a                	mv	s2,a0
    800058b8:	c179                	beqz	a0,8000597e <sys_open+0x12c>
    800058ba:	ed4e                	sd	s3,152(sp)
    800058bc:	a43ff0ef          	jal	800052fe <fdalloc>
    800058c0:	89aa                	mv	s3,a0
    800058c2:	0a054a63          	bltz	a0,80005976 <sys_open+0x124>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    800058c6:	04449703          	lh	a4,68(s1)
    800058ca:	478d                	li	a5,3
    800058cc:	0cf70263          	beq	a4,a5,80005990 <sys_open+0x13e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    800058d0:	4789                	li	a5,2
    800058d2:	00f92023          	sw	a5,0(s2)
    f->off = 0;
    800058d6:	02092023          	sw	zero,32(s2)
  }
  f->ip = ip;
    800058da:	00993c23          	sd	s1,24(s2)
  f->readable = !(omode & O_WRONLY);
    800058de:	f4c42783          	lw	a5,-180(s0)
    800058e2:	0017c713          	xori	a4,a5,1
    800058e6:	8b05                	andi	a4,a4,1
    800058e8:	00e90423          	sb	a4,8(s2)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    800058ec:	0037f713          	andi	a4,a5,3
    800058f0:	00e03733          	snez	a4,a4
    800058f4:	00e904a3          	sb	a4,9(s2)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    800058f8:	4007f793          	andi	a5,a5,1024
    800058fc:	c791                	beqz	a5,80005908 <sys_open+0xb6>
    800058fe:	04449703          	lh	a4,68(s1)
    80005902:	4789                	li	a5,2
    80005904:	08f70d63          	beq	a4,a5,8000599e <sys_open+0x14c>
    itrunc(ip);
  }

  iunlock(ip);
    80005908:	8526                	mv	a0,s1
    8000590a:	adafe0ef          	jal	80003be4 <iunlock>
  end_op();
    8000590e:	c7dfe0ef          	jal	8000458a <end_op>

  return fd;
    80005912:	854e                	mv	a0,s3
    80005914:	74aa                	ld	s1,168(sp)
    80005916:	790a                	ld	s2,160(sp)
    80005918:	69ea                	ld	s3,152(sp)
}
    8000591a:	70ea                	ld	ra,184(sp)
    8000591c:	744a                	ld	s0,176(sp)
    8000591e:	6129                	addi	sp,sp,192
    80005920:	8082                	ret
      end_op();
    80005922:	c69fe0ef          	jal	8000458a <end_op>
      return -1;
    80005926:	557d                	li	a0,-1
    80005928:	74aa                	ld	s1,168(sp)
    8000592a:	bfc5                	j	8000591a <sys_open+0xc8>
    if((ip = namei(path)) == 0){
    8000592c:	f5040513          	addi	a0,s0,-176
    80005930:	a1dfe0ef          	jal	8000434c <namei>
    80005934:	84aa                	mv	s1,a0
    80005936:	c11d                	beqz	a0,8000595c <sys_open+0x10a>
    ilock(ip);
    80005938:	9fefe0ef          	jal	80003b36 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    8000593c:	04449703          	lh	a4,68(s1)
    80005940:	4785                	li	a5,1
    80005942:	f4f71de3          	bne	a4,a5,8000589c <sys_open+0x4a>
    80005946:	f4c42783          	lw	a5,-180(s0)
    8000594a:	d3bd                	beqz	a5,800058b0 <sys_open+0x5e>
      iunlockput(ip);
    8000594c:	8526                	mv	a0,s1
    8000594e:	bf2fe0ef          	jal	80003d40 <iunlockput>
      end_op();
    80005952:	c39fe0ef          	jal	8000458a <end_op>
      return -1;
    80005956:	557d                	li	a0,-1
    80005958:	74aa                	ld	s1,168(sp)
    8000595a:	b7c1                	j	8000591a <sys_open+0xc8>
      end_op();
    8000595c:	c2ffe0ef          	jal	8000458a <end_op>
      return -1;
    80005960:	557d                	li	a0,-1
    80005962:	74aa                	ld	s1,168(sp)
    80005964:	bf5d                	j	8000591a <sys_open+0xc8>
    iunlockput(ip);
    80005966:	8526                	mv	a0,s1
    80005968:	bd8fe0ef          	jal	80003d40 <iunlockput>
    end_op();
    8000596c:	c1ffe0ef          	jal	8000458a <end_op>
    return -1;
    80005970:	557d                	li	a0,-1
    80005972:	74aa                	ld	s1,168(sp)
    80005974:	b75d                	j	8000591a <sys_open+0xc8>
      fileclose(f);
    80005976:	854a                	mv	a0,s2
    80005978:	fb5fe0ef          	jal	8000492c <fileclose>
    8000597c:	69ea                	ld	s3,152(sp)
    iunlockput(ip);
    8000597e:	8526                	mv	a0,s1
    80005980:	bc0fe0ef          	jal	80003d40 <iunlockput>
    end_op();
    80005984:	c07fe0ef          	jal	8000458a <end_op>
    return -1;
    80005988:	557d                	li	a0,-1
    8000598a:	74aa                	ld	s1,168(sp)
    8000598c:	790a                	ld	s2,160(sp)
    8000598e:	b771                	j	8000591a <sys_open+0xc8>
    f->type = FD_DEVICE;
    80005990:	00f92023          	sw	a5,0(s2)
    f->major = ip->major;
    80005994:	04649783          	lh	a5,70(s1)
    80005998:	02f91223          	sh	a5,36(s2)
    8000599c:	bf3d                	j	800058da <sys_open+0x88>
    itrunc(ip);
    8000599e:	8526                	mv	a0,s1
    800059a0:	a84fe0ef          	jal	80003c24 <itrunc>
    800059a4:	b795                	j	80005908 <sys_open+0xb6>

00000000800059a6 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    800059a6:	7175                	addi	sp,sp,-144
    800059a8:	e506                	sd	ra,136(sp)
    800059aa:	e122                	sd	s0,128(sp)
    800059ac:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    800059ae:	b73fe0ef          	jal	80004520 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    800059b2:	08000613          	li	a2,128
    800059b6:	f7040593          	addi	a1,s0,-144
    800059ba:	4501                	li	a0,0
    800059bc:	cf2fd0ef          	jal	80002eae <argstr>
    800059c0:	02054363          	bltz	a0,800059e6 <sys_mkdir+0x40>
    800059c4:	4681                	li	a3,0
    800059c6:	4601                	li	a2,0
    800059c8:	4585                	li	a1,1
    800059ca:	f7040513          	addi	a0,s0,-144
    800059ce:	96fff0ef          	jal	8000533c <create>
    800059d2:	c911                	beqz	a0,800059e6 <sys_mkdir+0x40>
    end_op();
    return -1;
  }
  iunlockput(ip);
    800059d4:	b6cfe0ef          	jal	80003d40 <iunlockput>
  end_op();
    800059d8:	bb3fe0ef          	jal	8000458a <end_op>
  return 0;
    800059dc:	4501                	li	a0,0
}
    800059de:	60aa                	ld	ra,136(sp)
    800059e0:	640a                	ld	s0,128(sp)
    800059e2:	6149                	addi	sp,sp,144
    800059e4:	8082                	ret
    end_op();
    800059e6:	ba5fe0ef          	jal	8000458a <end_op>
    return -1;
    800059ea:	557d                	li	a0,-1
    800059ec:	bfcd                	j	800059de <sys_mkdir+0x38>

00000000800059ee <sys_mknod>:

uint64
sys_mknod(void)
{
    800059ee:	7135                	addi	sp,sp,-160
    800059f0:	ed06                	sd	ra,152(sp)
    800059f2:	e922                	sd	s0,144(sp)
    800059f4:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    800059f6:	b2bfe0ef          	jal	80004520 <begin_op>
  argint(1, &major);
    800059fa:	f6c40593          	addi	a1,s0,-148
    800059fe:	4505                	li	a0,1
    80005a00:	c76fd0ef          	jal	80002e76 <argint>
  argint(2, &minor);
    80005a04:	f6840593          	addi	a1,s0,-152
    80005a08:	4509                	li	a0,2
    80005a0a:	c6cfd0ef          	jal	80002e76 <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005a0e:	08000613          	li	a2,128
    80005a12:	f7040593          	addi	a1,s0,-144
    80005a16:	4501                	li	a0,0
    80005a18:	c96fd0ef          	jal	80002eae <argstr>
    80005a1c:	02054563          	bltz	a0,80005a46 <sys_mknod+0x58>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80005a20:	f6841683          	lh	a3,-152(s0)
    80005a24:	f6c41603          	lh	a2,-148(s0)
    80005a28:	458d                	li	a1,3
    80005a2a:	f7040513          	addi	a0,s0,-144
    80005a2e:	90fff0ef          	jal	8000533c <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005a32:	c911                	beqz	a0,80005a46 <sys_mknod+0x58>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005a34:	b0cfe0ef          	jal	80003d40 <iunlockput>
  end_op();
    80005a38:	b53fe0ef          	jal	8000458a <end_op>
  return 0;
    80005a3c:	4501                	li	a0,0
}
    80005a3e:	60ea                	ld	ra,152(sp)
    80005a40:	644a                	ld	s0,144(sp)
    80005a42:	610d                	addi	sp,sp,160
    80005a44:	8082                	ret
    end_op();
    80005a46:	b45fe0ef          	jal	8000458a <end_op>
    return -1;
    80005a4a:	557d                	li	a0,-1
    80005a4c:	bfcd                	j	80005a3e <sys_mknod+0x50>

0000000080005a4e <sys_chdir>:

uint64
sys_chdir(void)
{
    80005a4e:	7135                	addi	sp,sp,-160
    80005a50:	ed06                	sd	ra,152(sp)
    80005a52:	e922                	sd	s0,144(sp)
    80005a54:	e14a                	sd	s2,128(sp)
    80005a56:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80005a58:	a2efc0ef          	jal	80001c86 <myproc>
    80005a5c:	892a                	mv	s2,a0
  
  begin_op();
    80005a5e:	ac3fe0ef          	jal	80004520 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80005a62:	08000613          	li	a2,128
    80005a66:	f6040593          	addi	a1,s0,-160
    80005a6a:	4501                	li	a0,0
    80005a6c:	c42fd0ef          	jal	80002eae <argstr>
    80005a70:	04054363          	bltz	a0,80005ab6 <sys_chdir+0x68>
    80005a74:	e526                	sd	s1,136(sp)
    80005a76:	f6040513          	addi	a0,s0,-160
    80005a7a:	8d3fe0ef          	jal	8000434c <namei>
    80005a7e:	84aa                	mv	s1,a0
    80005a80:	c915                	beqz	a0,80005ab4 <sys_chdir+0x66>
    end_op();
    return -1;
  }
  ilock(ip);
    80005a82:	8b4fe0ef          	jal	80003b36 <ilock>
  if(ip->type != T_DIR){
    80005a86:	04449703          	lh	a4,68(s1)
    80005a8a:	4785                	li	a5,1
    80005a8c:	02f71963          	bne	a4,a5,80005abe <sys_chdir+0x70>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80005a90:	8526                	mv	a0,s1
    80005a92:	952fe0ef          	jal	80003be4 <iunlock>
  iput(p->cwd);
    80005a96:	15093503          	ld	a0,336(s2)
    80005a9a:	a1efe0ef          	jal	80003cb8 <iput>
  end_op();
    80005a9e:	aedfe0ef          	jal	8000458a <end_op>
  p->cwd = ip;
    80005aa2:	14993823          	sd	s1,336(s2)
  return 0;
    80005aa6:	4501                	li	a0,0
    80005aa8:	64aa                	ld	s1,136(sp)
}
    80005aaa:	60ea                	ld	ra,152(sp)
    80005aac:	644a                	ld	s0,144(sp)
    80005aae:	690a                	ld	s2,128(sp)
    80005ab0:	610d                	addi	sp,sp,160
    80005ab2:	8082                	ret
    80005ab4:	64aa                	ld	s1,136(sp)
    end_op();
    80005ab6:	ad5fe0ef          	jal	8000458a <end_op>
    return -1;
    80005aba:	557d                	li	a0,-1
    80005abc:	b7fd                	j	80005aaa <sys_chdir+0x5c>
    iunlockput(ip);
    80005abe:	8526                	mv	a0,s1
    80005ac0:	a80fe0ef          	jal	80003d40 <iunlockput>
    end_op();
    80005ac4:	ac7fe0ef          	jal	8000458a <end_op>
    return -1;
    80005ac8:	557d                	li	a0,-1
    80005aca:	64aa                	ld	s1,136(sp)
    80005acc:	bff9                	j	80005aaa <sys_chdir+0x5c>

0000000080005ace <sys_exec>:

uint64
sys_exec(void)
{
    80005ace:	7121                	addi	sp,sp,-448
    80005ad0:	ff06                	sd	ra,440(sp)
    80005ad2:	fb22                	sd	s0,432(sp)
    80005ad4:	0380                	addi	s0,sp,448
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    80005ad6:	e4840593          	addi	a1,s0,-440
    80005ada:	4505                	li	a0,1
    80005adc:	bb6fd0ef          	jal	80002e92 <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    80005ae0:	08000613          	li	a2,128
    80005ae4:	f5040593          	addi	a1,s0,-176
    80005ae8:	4501                	li	a0,0
    80005aea:	bc4fd0ef          	jal	80002eae <argstr>
    80005aee:	87aa                	mv	a5,a0
    return -1;
    80005af0:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    80005af2:	0c07c463          	bltz	a5,80005bba <sys_exec+0xec>
    80005af6:	f726                	sd	s1,424(sp)
    80005af8:	f34a                	sd	s2,416(sp)
    80005afa:	ef4e                	sd	s3,408(sp)
    80005afc:	eb52                	sd	s4,400(sp)
  }
  memset(argv, 0, sizeof(argv));
    80005afe:	10000613          	li	a2,256
    80005b02:	4581                	li	a1,0
    80005b04:	e5040513          	addi	a0,s0,-432
    80005b08:	a88fb0ef          	jal	80000d90 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80005b0c:	e5040493          	addi	s1,s0,-432
  memset(argv, 0, sizeof(argv));
    80005b10:	89a6                	mv	s3,s1
    80005b12:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    80005b14:	02000a13          	li	s4,32
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80005b18:	00391513          	slli	a0,s2,0x3
    80005b1c:	e4040593          	addi	a1,s0,-448
    80005b20:	e4843783          	ld	a5,-440(s0)
    80005b24:	953e                	add	a0,a0,a5
    80005b26:	ac6fd0ef          	jal	80002dec <fetchaddr>
    80005b2a:	02054663          	bltz	a0,80005b56 <sys_exec+0x88>
      goto bad;
    }
    if(uarg == 0){
    80005b2e:	e4043783          	ld	a5,-448(s0)
    80005b32:	c3a9                	beqz	a5,80005b74 <sys_exec+0xa6>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80005b34:	85afb0ef          	jal	80000b8e <kalloc>
    80005b38:	85aa                	mv	a1,a0
    80005b3a:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80005b3e:	cd01                	beqz	a0,80005b56 <sys_exec+0x88>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80005b40:	6605                	lui	a2,0x1
    80005b42:	e4043503          	ld	a0,-448(s0)
    80005b46:	af0fd0ef          	jal	80002e36 <fetchstr>
    80005b4a:	00054663          	bltz	a0,80005b56 <sys_exec+0x88>
    if(i >= NELEM(argv)){
    80005b4e:	0905                	addi	s2,s2,1
    80005b50:	09a1                	addi	s3,s3,8
    80005b52:	fd4913e3          	bne	s2,s4,80005b18 <sys_exec+0x4a>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005b56:	f5040913          	addi	s2,s0,-176
    80005b5a:	6088                	ld	a0,0(s1)
    80005b5c:	c931                	beqz	a0,80005bb0 <sys_exec+0xe2>
    kfree(argv[i]);
    80005b5e:	ef1fa0ef          	jal	80000a4e <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005b62:	04a1                	addi	s1,s1,8
    80005b64:	ff249be3          	bne	s1,s2,80005b5a <sys_exec+0x8c>
  return -1;
    80005b68:	557d                	li	a0,-1
    80005b6a:	74ba                	ld	s1,424(sp)
    80005b6c:	791a                	ld	s2,416(sp)
    80005b6e:	69fa                	ld	s3,408(sp)
    80005b70:	6a5a                	ld	s4,400(sp)
    80005b72:	a0a1                	j	80005bba <sys_exec+0xec>
      argv[i] = 0;
    80005b74:	0009079b          	sext.w	a5,s2
    80005b78:	078e                	slli	a5,a5,0x3
    80005b7a:	fd078793          	addi	a5,a5,-48
    80005b7e:	97a2                	add	a5,a5,s0
    80005b80:	e807b023          	sd	zero,-384(a5)
  int ret = kexec(path, argv);
    80005b84:	e5040593          	addi	a1,s0,-432
    80005b88:	f5040513          	addi	a0,s0,-176
    80005b8c:	ba8ff0ef          	jal	80004f34 <kexec>
    80005b90:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005b92:	f5040993          	addi	s3,s0,-176
    80005b96:	6088                	ld	a0,0(s1)
    80005b98:	c511                	beqz	a0,80005ba4 <sys_exec+0xd6>
    kfree(argv[i]);
    80005b9a:	eb5fa0ef          	jal	80000a4e <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005b9e:	04a1                	addi	s1,s1,8
    80005ba0:	ff349be3          	bne	s1,s3,80005b96 <sys_exec+0xc8>
  return ret;
    80005ba4:	854a                	mv	a0,s2
    80005ba6:	74ba                	ld	s1,424(sp)
    80005ba8:	791a                	ld	s2,416(sp)
    80005baa:	69fa                	ld	s3,408(sp)
    80005bac:	6a5a                	ld	s4,400(sp)
    80005bae:	a031                	j	80005bba <sys_exec+0xec>
  return -1;
    80005bb0:	557d                	li	a0,-1
    80005bb2:	74ba                	ld	s1,424(sp)
    80005bb4:	791a                	ld	s2,416(sp)
    80005bb6:	69fa                	ld	s3,408(sp)
    80005bb8:	6a5a                	ld	s4,400(sp)
}
    80005bba:	70fa                	ld	ra,440(sp)
    80005bbc:	745a                	ld	s0,432(sp)
    80005bbe:	6139                	addi	sp,sp,448
    80005bc0:	8082                	ret

0000000080005bc2 <sys_pipe>:

uint64
sys_pipe(void)
{
    80005bc2:	7139                	addi	sp,sp,-64
    80005bc4:	fc06                	sd	ra,56(sp)
    80005bc6:	f822                	sd	s0,48(sp)
    80005bc8:	f426                	sd	s1,40(sp)
    80005bca:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80005bcc:	8bafc0ef          	jal	80001c86 <myproc>
    80005bd0:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    80005bd2:	fd840593          	addi	a1,s0,-40
    80005bd6:	4501                	li	a0,0
    80005bd8:	abafd0ef          	jal	80002e92 <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    80005bdc:	fc840593          	addi	a1,s0,-56
    80005be0:	fd040513          	addi	a0,s0,-48
    80005be4:	852ff0ef          	jal	80004c36 <pipealloc>
    return -1;
    80005be8:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80005bea:	0a054463          	bltz	a0,80005c92 <sys_pipe+0xd0>
  fd0 = -1;
    80005bee:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80005bf2:	fd043503          	ld	a0,-48(s0)
    80005bf6:	f08ff0ef          	jal	800052fe <fdalloc>
    80005bfa:	fca42223          	sw	a0,-60(s0)
    80005bfe:	08054163          	bltz	a0,80005c80 <sys_pipe+0xbe>
    80005c02:	fc843503          	ld	a0,-56(s0)
    80005c06:	ef8ff0ef          	jal	800052fe <fdalloc>
    80005c0a:	fca42023          	sw	a0,-64(s0)
    80005c0e:	06054063          	bltz	a0,80005c6e <sys_pipe+0xac>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005c12:	4691                	li	a3,4
    80005c14:	fc440613          	addi	a2,s0,-60
    80005c18:	fd843583          	ld	a1,-40(s0)
    80005c1c:	68a8                	ld	a0,80(s1)
    80005c1e:	cf3fb0ef          	jal	80001910 <copyout>
    80005c22:	00054e63          	bltz	a0,80005c3e <sys_pipe+0x7c>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80005c26:	4691                	li	a3,4
    80005c28:	fc040613          	addi	a2,s0,-64
    80005c2c:	fd843583          	ld	a1,-40(s0)
    80005c30:	0591                	addi	a1,a1,4
    80005c32:	68a8                	ld	a0,80(s1)
    80005c34:	cddfb0ef          	jal	80001910 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80005c38:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005c3a:	04055c63          	bgez	a0,80005c92 <sys_pipe+0xd0>
    p->ofile[fd0] = 0;
    80005c3e:	fc442783          	lw	a5,-60(s0)
    80005c42:	07e9                	addi	a5,a5,26
    80005c44:	078e                	slli	a5,a5,0x3
    80005c46:	97a6                	add	a5,a5,s1
    80005c48:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    80005c4c:	fc042783          	lw	a5,-64(s0)
    80005c50:	07e9                	addi	a5,a5,26
    80005c52:	078e                	slli	a5,a5,0x3
    80005c54:	94be                	add	s1,s1,a5
    80005c56:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    80005c5a:	fd043503          	ld	a0,-48(s0)
    80005c5e:	ccffe0ef          	jal	8000492c <fileclose>
    fileclose(wf);
    80005c62:	fc843503          	ld	a0,-56(s0)
    80005c66:	cc7fe0ef          	jal	8000492c <fileclose>
    return -1;
    80005c6a:	57fd                	li	a5,-1
    80005c6c:	a01d                	j	80005c92 <sys_pipe+0xd0>
    if(fd0 >= 0)
    80005c6e:	fc442783          	lw	a5,-60(s0)
    80005c72:	0007c763          	bltz	a5,80005c80 <sys_pipe+0xbe>
      p->ofile[fd0] = 0;
    80005c76:	07e9                	addi	a5,a5,26
    80005c78:	078e                	slli	a5,a5,0x3
    80005c7a:	97a6                	add	a5,a5,s1
    80005c7c:	0007b023          	sd	zero,0(a5)
    fileclose(rf);
    80005c80:	fd043503          	ld	a0,-48(s0)
    80005c84:	ca9fe0ef          	jal	8000492c <fileclose>
    fileclose(wf);
    80005c88:	fc843503          	ld	a0,-56(s0)
    80005c8c:	ca1fe0ef          	jal	8000492c <fileclose>
    return -1;
    80005c90:	57fd                	li	a5,-1
}
    80005c92:	853e                	mv	a0,a5
    80005c94:	70e2                	ld	ra,56(sp)
    80005c96:	7442                	ld	s0,48(sp)
    80005c98:	74a2                	ld	s1,40(sp)
    80005c9a:	6121                	addi	sp,sp,64
    80005c9c:	8082                	ret

0000000080005c9e <sys_fsread>:
uint64
sys_fsread(void)
{
    80005c9e:	1101                	addi	sp,sp,-32
    80005ca0:	ec06                	sd	ra,24(sp)
    80005ca2:	e822                	sd	s0,16(sp)
    80005ca4:	1000                	addi	s0,sp,32
  uint64 addr;
  int n;

  // استدعاء الدوال مباشرة لأنها void في نسختك
  argaddr(0, &addr); 
    80005ca6:	fe840593          	addi	a1,s0,-24
    80005caa:	4501                	li	a0,0
    80005cac:	9e6fd0ef          	jal	80002e92 <argaddr>
  argint(1, &n);
    80005cb0:	fe440593          	addi	a1,s0,-28
    80005cb4:	4505                	li	a0,1
    80005cb6:	9c0fd0ef          	jal	80002e76 <argint>

  // شرط حماية صارم داخل الكيرنل: 
  // إذا كانت n سالبة، أو صفر، أو أكبر من الحد الأقصى للبفر (32)، قم بتصحيحها فوراً
  if(n <= 0)
    80005cba:	fe442783          	lw	a5,-28(s0)
    return 0;
    80005cbe:	4501                	li	a0,0
  if(n <= 0)
    80005cc0:	02f05063          	blez	a5,80005ce0 <sys_fsread+0x42>
  if(n > 32)
    80005cc4:	02000713          	li	a4,32
    80005cc8:	00f75663          	bge	a4,a5,80005cd4 <sys_fsread+0x36>
    n = 32;
    80005ccc:	02000793          	li	a5,32
    80005cd0:	fef42223          	sw	a5,-28(s0)

  // استدعاء الوظيفة الحقيقية وإعادة نتيجتها
  return fslog_read_many((struct fs_event *)addr, n);
    80005cd4:	fe442583          	lw	a1,-28(s0)
    80005cd8:	fe843503          	ld	a0,-24(s0)
    80005cdc:	237000ef          	jal	80006712 <fslog_read_many>
}
    80005ce0:	60e2                	ld	ra,24(sp)
    80005ce2:	6442                	ld	s0,16(sp)
    80005ce4:	6105                	addi	sp,sp,32
    80005ce6:	8082                	ret
	...

0000000080005cf0 <kernelvec>:
.globl kerneltrap
.globl kernelvec
.align 4
kernelvec:
        # make room to save registers.
        addi sp, sp, -256
    80005cf0:	7111                	addi	sp,sp,-256

        # save caller-saved registers.
        sd ra, 0(sp)
    80005cf2:	e006                	sd	ra,0(sp)
        # sd sp, 8(sp)
        sd gp, 16(sp)
    80005cf4:	e80e                	sd	gp,16(sp)
        sd tp, 24(sp)
    80005cf6:	ec12                	sd	tp,24(sp)
        sd t0, 32(sp)
    80005cf8:	f016                	sd	t0,32(sp)
        sd t1, 40(sp)
    80005cfa:	f41a                	sd	t1,40(sp)
        sd t2, 48(sp)
    80005cfc:	f81e                	sd	t2,48(sp)
        sd a0, 72(sp)
    80005cfe:	e4aa                	sd	a0,72(sp)
        sd a1, 80(sp)
    80005d00:	e8ae                	sd	a1,80(sp)
        sd a2, 88(sp)
    80005d02:	ecb2                	sd	a2,88(sp)
        sd a3, 96(sp)
    80005d04:	f0b6                	sd	a3,96(sp)
        sd a4, 104(sp)
    80005d06:	f4ba                	sd	a4,104(sp)
        sd a5, 112(sp)
    80005d08:	f8be                	sd	a5,112(sp)
        sd a6, 120(sp)
    80005d0a:	fcc2                	sd	a6,120(sp)
        sd a7, 128(sp)
    80005d0c:	e146                	sd	a7,128(sp)
        sd t3, 216(sp)
    80005d0e:	edf2                	sd	t3,216(sp)
        sd t4, 224(sp)
    80005d10:	f1f6                	sd	t4,224(sp)
        sd t5, 232(sp)
    80005d12:	f5fa                	sd	t5,232(sp)
        sd t6, 240(sp)
    80005d14:	f9fe                	sd	t6,240(sp)

        # call the C trap handler in trap.c
        call kerneltrap
    80005d16:	fe7fc0ef          	jal	80002cfc <kerneltrap>

        # restore registers.
        ld ra, 0(sp)
    80005d1a:	6082                	ld	ra,0(sp)
        # ld sp, 8(sp)
        ld gp, 16(sp)
    80005d1c:	61c2                	ld	gp,16(sp)
        # not tp (contains hartid), in case we moved CPUs
        ld t0, 32(sp)
    80005d1e:	7282                	ld	t0,32(sp)
        ld t1, 40(sp)
    80005d20:	7322                	ld	t1,40(sp)
        ld t2, 48(sp)
    80005d22:	73c2                	ld	t2,48(sp)
        ld a0, 72(sp)
    80005d24:	6526                	ld	a0,72(sp)
        ld a1, 80(sp)
    80005d26:	65c6                	ld	a1,80(sp)
        ld a2, 88(sp)
    80005d28:	6666                	ld	a2,88(sp)
        ld a3, 96(sp)
    80005d2a:	7686                	ld	a3,96(sp)
        ld a4, 104(sp)
    80005d2c:	7726                	ld	a4,104(sp)
        ld a5, 112(sp)
    80005d2e:	77c6                	ld	a5,112(sp)
        ld a6, 120(sp)
    80005d30:	7866                	ld	a6,120(sp)
        ld a7, 128(sp)
    80005d32:	688a                	ld	a7,128(sp)
        ld t3, 216(sp)
    80005d34:	6e6e                	ld	t3,216(sp)
        ld t4, 224(sp)
    80005d36:	7e8e                	ld	t4,224(sp)
        ld t5, 232(sp)
    80005d38:	7f2e                	ld	t5,232(sp)
        ld t6, 240(sp)
    80005d3a:	7fce                	ld	t6,240(sp)

        addi sp, sp, 256
    80005d3c:	6111                	addi	sp,sp,256

        # return to whatever we were doing in the kernel.
        sret
    80005d3e:	10200073          	sret
	...

0000000080005d4e <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    80005d4e:	1141                	addi	sp,sp,-16
    80005d50:	e422                	sd	s0,8(sp)
    80005d52:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80005d54:	0c0007b7          	lui	a5,0xc000
    80005d58:	4705                	li	a4,1
    80005d5a:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    80005d5c:	0c0007b7          	lui	a5,0xc000
    80005d60:	c3d8                	sw	a4,4(a5)
}
    80005d62:	6422                	ld	s0,8(sp)
    80005d64:	0141                	addi	sp,sp,16
    80005d66:	8082                	ret

0000000080005d68 <plicinithart>:

void
plicinithart(void)
{
    80005d68:	1141                	addi	sp,sp,-16
    80005d6a:	e406                	sd	ra,8(sp)
    80005d6c:	e022                	sd	s0,0(sp)
    80005d6e:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005d70:	ee5fb0ef          	jal	80001c54 <cpuid>
  
  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80005d74:	0085171b          	slliw	a4,a0,0x8
    80005d78:	0c0027b7          	lui	a5,0xc002
    80005d7c:	97ba                	add	a5,a5,a4
    80005d7e:	40200713          	li	a4,1026
    80005d82:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80005d86:	00d5151b          	slliw	a0,a0,0xd
    80005d8a:	0c2017b7          	lui	a5,0xc201
    80005d8e:	97aa                	add	a5,a5,a0
    80005d90:	0007a023          	sw	zero,0(a5) # c201000 <_entry-0x73dff000>
}
    80005d94:	60a2                	ld	ra,8(sp)
    80005d96:	6402                	ld	s0,0(sp)
    80005d98:	0141                	addi	sp,sp,16
    80005d9a:	8082                	ret

0000000080005d9c <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    80005d9c:	1141                	addi	sp,sp,-16
    80005d9e:	e406                	sd	ra,8(sp)
    80005da0:	e022                	sd	s0,0(sp)
    80005da2:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005da4:	eb1fb0ef          	jal	80001c54 <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80005da8:	00d5151b          	slliw	a0,a0,0xd
    80005dac:	0c2017b7          	lui	a5,0xc201
    80005db0:	97aa                	add	a5,a5,a0
  return irq;
}
    80005db2:	43c8                	lw	a0,4(a5)
    80005db4:	60a2                	ld	ra,8(sp)
    80005db6:	6402                	ld	s0,0(sp)
    80005db8:	0141                	addi	sp,sp,16
    80005dba:	8082                	ret

0000000080005dbc <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    80005dbc:	1101                	addi	sp,sp,-32
    80005dbe:	ec06                	sd	ra,24(sp)
    80005dc0:	e822                	sd	s0,16(sp)
    80005dc2:	e426                	sd	s1,8(sp)
    80005dc4:	1000                	addi	s0,sp,32
    80005dc6:	84aa                	mv	s1,a0
  int hart = cpuid();
    80005dc8:	e8dfb0ef          	jal	80001c54 <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    80005dcc:	00d5151b          	slliw	a0,a0,0xd
    80005dd0:	0c2017b7          	lui	a5,0xc201
    80005dd4:	97aa                	add	a5,a5,a0
    80005dd6:	c3c4                	sw	s1,4(a5)
}
    80005dd8:	60e2                	ld	ra,24(sp)
    80005dda:	6442                	ld	s0,16(sp)
    80005ddc:	64a2                	ld	s1,8(sp)
    80005dde:	6105                	addi	sp,sp,32
    80005de0:	8082                	ret

0000000080005de2 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80005de2:	1141                	addi	sp,sp,-16
    80005de4:	e406                	sd	ra,8(sp)
    80005de6:	e022                	sd	s0,0(sp)
    80005de8:	0800                	addi	s0,sp,16
  if(i >= NUM)
    80005dea:	479d                	li	a5,7
    80005dec:	04a7ca63          	blt	a5,a0,80005e40 <free_desc+0x5e>
    panic("free_desc 1");
  if(disk.free[i])
    80005df0:	0001c797          	auipc	a5,0x1c
    80005df4:	f0878793          	addi	a5,a5,-248 # 80021cf8 <disk>
    80005df8:	97aa                	add	a5,a5,a0
    80005dfa:	0187c783          	lbu	a5,24(a5)
    80005dfe:	e7b9                	bnez	a5,80005e4c <free_desc+0x6a>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    80005e00:	00451693          	slli	a3,a0,0x4
    80005e04:	0001c797          	auipc	a5,0x1c
    80005e08:	ef478793          	addi	a5,a5,-268 # 80021cf8 <disk>
    80005e0c:	6398                	ld	a4,0(a5)
    80005e0e:	9736                	add	a4,a4,a3
    80005e10:	00073023          	sd	zero,0(a4)
  disk.desc[i].len = 0;
    80005e14:	6398                	ld	a4,0(a5)
    80005e16:	9736                	add	a4,a4,a3
    80005e18:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    80005e1c:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    80005e20:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    80005e24:	97aa                	add	a5,a5,a0
    80005e26:	4705                	li	a4,1
    80005e28:	00e78c23          	sb	a4,24(a5)
  wakeup(&disk.free[0]);
    80005e2c:	0001c517          	auipc	a0,0x1c
    80005e30:	ee450513          	addi	a0,a0,-284 # 80021d10 <disk+0x18>
    80005e34:	f68fc0ef          	jal	8000259c <wakeup>
}
    80005e38:	60a2                	ld	ra,8(sp)
    80005e3a:	6402                	ld	s0,0(sp)
    80005e3c:	0141                	addi	sp,sp,16
    80005e3e:	8082                	ret
    panic("free_desc 1");
    80005e40:	00003517          	auipc	a0,0x3
    80005e44:	81850513          	addi	a0,a0,-2024 # 80008658 <etext+0x658>
    80005e48:	9cbfa0ef          	jal	80000812 <panic>
    panic("free_desc 2");
    80005e4c:	00003517          	auipc	a0,0x3
    80005e50:	81c50513          	addi	a0,a0,-2020 # 80008668 <etext+0x668>
    80005e54:	9bffa0ef          	jal	80000812 <panic>

0000000080005e58 <virtio_disk_init>:
{
    80005e58:	1101                	addi	sp,sp,-32
    80005e5a:	ec06                	sd	ra,24(sp)
    80005e5c:	e822                	sd	s0,16(sp)
    80005e5e:	e426                	sd	s1,8(sp)
    80005e60:	e04a                	sd	s2,0(sp)
    80005e62:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80005e64:	00003597          	auipc	a1,0x3
    80005e68:	81458593          	addi	a1,a1,-2028 # 80008678 <etext+0x678>
    80005e6c:	0001c517          	auipc	a0,0x1c
    80005e70:	fb450513          	addi	a0,a0,-76 # 80021e20 <disk+0x128>
    80005e74:	dc9fa0ef          	jal	80000c3c <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005e78:	100017b7          	lui	a5,0x10001
    80005e7c:	4398                	lw	a4,0(a5)
    80005e7e:	2701                	sext.w	a4,a4
    80005e80:	747277b7          	lui	a5,0x74727
    80005e84:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    80005e88:	18f71063          	bne	a4,a5,80006008 <virtio_disk_init+0x1b0>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80005e8c:	100017b7          	lui	a5,0x10001
    80005e90:	0791                	addi	a5,a5,4 # 10001004 <_entry-0x6fffeffc>
    80005e92:	439c                	lw	a5,0(a5)
    80005e94:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005e96:	4709                	li	a4,2
    80005e98:	16e79863          	bne	a5,a4,80006008 <virtio_disk_init+0x1b0>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005e9c:	100017b7          	lui	a5,0x10001
    80005ea0:	07a1                	addi	a5,a5,8 # 10001008 <_entry-0x6fffeff8>
    80005ea2:	439c                	lw	a5,0(a5)
    80005ea4:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80005ea6:	16e79163          	bne	a5,a4,80006008 <virtio_disk_init+0x1b0>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    80005eaa:	100017b7          	lui	a5,0x10001
    80005eae:	47d8                	lw	a4,12(a5)
    80005eb0:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005eb2:	554d47b7          	lui	a5,0x554d4
    80005eb6:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    80005eba:	14f71763          	bne	a4,a5,80006008 <virtio_disk_init+0x1b0>
  *R(VIRTIO_MMIO_STATUS) = status;
    80005ebe:	100017b7          	lui	a5,0x10001
    80005ec2:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    80005ec6:	4705                	li	a4,1
    80005ec8:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005eca:	470d                	li	a4,3
    80005ecc:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    80005ece:	10001737          	lui	a4,0x10001
    80005ed2:	4b14                	lw	a3,16(a4)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    80005ed4:	c7ffe737          	lui	a4,0xc7ffe
    80005ed8:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47fb787f>
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80005edc:	8ef9                	and	a3,a3,a4
    80005ede:	10001737          	lui	a4,0x10001
    80005ee2:	d314                	sw	a3,32(a4)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005ee4:	472d                	li	a4,11
    80005ee6:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005ee8:	07078793          	addi	a5,a5,112
  status = *R(VIRTIO_MMIO_STATUS);
    80005eec:	439c                	lw	a5,0(a5)
    80005eee:	0007891b          	sext.w	s2,a5
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    80005ef2:	8ba1                	andi	a5,a5,8
    80005ef4:	12078063          	beqz	a5,80006014 <virtio_disk_init+0x1bc>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80005ef8:	100017b7          	lui	a5,0x10001
    80005efc:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    80005f00:	100017b7          	lui	a5,0x10001
    80005f04:	04478793          	addi	a5,a5,68 # 10001044 <_entry-0x6fffefbc>
    80005f08:	439c                	lw	a5,0(a5)
    80005f0a:	2781                	sext.w	a5,a5
    80005f0c:	10079a63          	bnez	a5,80006020 <virtio_disk_init+0x1c8>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    80005f10:	100017b7          	lui	a5,0x10001
    80005f14:	03478793          	addi	a5,a5,52 # 10001034 <_entry-0x6fffefcc>
    80005f18:	439c                	lw	a5,0(a5)
    80005f1a:	2781                	sext.w	a5,a5
  if(max == 0)
    80005f1c:	10078863          	beqz	a5,8000602c <virtio_disk_init+0x1d4>
  if(max < NUM)
    80005f20:	471d                	li	a4,7
    80005f22:	10f77b63          	bgeu	a4,a5,80006038 <virtio_disk_init+0x1e0>
  disk.desc = kalloc();
    80005f26:	c69fa0ef          	jal	80000b8e <kalloc>
    80005f2a:	0001c497          	auipc	s1,0x1c
    80005f2e:	dce48493          	addi	s1,s1,-562 # 80021cf8 <disk>
    80005f32:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    80005f34:	c5bfa0ef          	jal	80000b8e <kalloc>
    80005f38:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    80005f3a:	c55fa0ef          	jal	80000b8e <kalloc>
    80005f3e:	87aa                	mv	a5,a0
    80005f40:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    80005f42:	6088                	ld	a0,0(s1)
    80005f44:	10050063          	beqz	a0,80006044 <virtio_disk_init+0x1ec>
    80005f48:	0001c717          	auipc	a4,0x1c
    80005f4c:	db873703          	ld	a4,-584(a4) # 80021d00 <disk+0x8>
    80005f50:	0e070a63          	beqz	a4,80006044 <virtio_disk_init+0x1ec>
    80005f54:	0e078863          	beqz	a5,80006044 <virtio_disk_init+0x1ec>
  memset(disk.desc, 0, PGSIZE);
    80005f58:	6605                	lui	a2,0x1
    80005f5a:	4581                	li	a1,0
    80005f5c:	e35fa0ef          	jal	80000d90 <memset>
  memset(disk.avail, 0, PGSIZE);
    80005f60:	0001c497          	auipc	s1,0x1c
    80005f64:	d9848493          	addi	s1,s1,-616 # 80021cf8 <disk>
    80005f68:	6605                	lui	a2,0x1
    80005f6a:	4581                	li	a1,0
    80005f6c:	6488                	ld	a0,8(s1)
    80005f6e:	e23fa0ef          	jal	80000d90 <memset>
  memset(disk.used, 0, PGSIZE);
    80005f72:	6605                	lui	a2,0x1
    80005f74:	4581                	li	a1,0
    80005f76:	6888                	ld	a0,16(s1)
    80005f78:	e19fa0ef          	jal	80000d90 <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    80005f7c:	100017b7          	lui	a5,0x10001
    80005f80:	4721                	li	a4,8
    80005f82:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    80005f84:	4098                	lw	a4,0(s1)
    80005f86:	100017b7          	lui	a5,0x10001
    80005f8a:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    80005f8e:	40d8                	lw	a4,4(s1)
    80005f90:	100017b7          	lui	a5,0x10001
    80005f94:	08e7a223          	sw	a4,132(a5) # 10001084 <_entry-0x6fffef7c>
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    80005f98:	649c                	ld	a5,8(s1)
    80005f9a:	0007869b          	sext.w	a3,a5
    80005f9e:	10001737          	lui	a4,0x10001
    80005fa2:	08d72823          	sw	a3,144(a4) # 10001090 <_entry-0x6fffef70>
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    80005fa6:	9781                	srai	a5,a5,0x20
    80005fa8:	10001737          	lui	a4,0x10001
    80005fac:	08f72a23          	sw	a5,148(a4) # 10001094 <_entry-0x6fffef6c>
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    80005fb0:	689c                	ld	a5,16(s1)
    80005fb2:	0007869b          	sext.w	a3,a5
    80005fb6:	10001737          	lui	a4,0x10001
    80005fba:	0ad72023          	sw	a3,160(a4) # 100010a0 <_entry-0x6fffef60>
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    80005fbe:	9781                	srai	a5,a5,0x20
    80005fc0:	10001737          	lui	a4,0x10001
    80005fc4:	0af72223          	sw	a5,164(a4) # 100010a4 <_entry-0x6fffef5c>
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    80005fc8:	10001737          	lui	a4,0x10001
    80005fcc:	4785                	li	a5,1
    80005fce:	c37c                	sw	a5,68(a4)
    disk.free[i] = 1;
    80005fd0:	00f48c23          	sb	a5,24(s1)
    80005fd4:	00f48ca3          	sb	a5,25(s1)
    80005fd8:	00f48d23          	sb	a5,26(s1)
    80005fdc:	00f48da3          	sb	a5,27(s1)
    80005fe0:	00f48e23          	sb	a5,28(s1)
    80005fe4:	00f48ea3          	sb	a5,29(s1)
    80005fe8:	00f48f23          	sb	a5,30(s1)
    80005fec:	00f48fa3          	sb	a5,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    80005ff0:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    80005ff4:	100017b7          	lui	a5,0x10001
    80005ff8:	0727a823          	sw	s2,112(a5) # 10001070 <_entry-0x6fffef90>
}
    80005ffc:	60e2                	ld	ra,24(sp)
    80005ffe:	6442                	ld	s0,16(sp)
    80006000:	64a2                	ld	s1,8(sp)
    80006002:	6902                	ld	s2,0(sp)
    80006004:	6105                	addi	sp,sp,32
    80006006:	8082                	ret
    panic("could not find virtio disk");
    80006008:	00002517          	auipc	a0,0x2
    8000600c:	68050513          	addi	a0,a0,1664 # 80008688 <etext+0x688>
    80006010:	803fa0ef          	jal	80000812 <panic>
    panic("virtio disk FEATURES_OK unset");
    80006014:	00002517          	auipc	a0,0x2
    80006018:	69450513          	addi	a0,a0,1684 # 800086a8 <etext+0x6a8>
    8000601c:	ff6fa0ef          	jal	80000812 <panic>
    panic("virtio disk should not be ready");
    80006020:	00002517          	auipc	a0,0x2
    80006024:	6a850513          	addi	a0,a0,1704 # 800086c8 <etext+0x6c8>
    80006028:	feafa0ef          	jal	80000812 <panic>
    panic("virtio disk has no queue 0");
    8000602c:	00002517          	auipc	a0,0x2
    80006030:	6bc50513          	addi	a0,a0,1724 # 800086e8 <etext+0x6e8>
    80006034:	fdefa0ef          	jal	80000812 <panic>
    panic("virtio disk max queue too short");
    80006038:	00002517          	auipc	a0,0x2
    8000603c:	6d050513          	addi	a0,a0,1744 # 80008708 <etext+0x708>
    80006040:	fd2fa0ef          	jal	80000812 <panic>
    panic("virtio disk kalloc");
    80006044:	00002517          	auipc	a0,0x2
    80006048:	6e450513          	addi	a0,a0,1764 # 80008728 <etext+0x728>
    8000604c:	fc6fa0ef          	jal	80000812 <panic>

0000000080006050 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80006050:	7159                	addi	sp,sp,-112
    80006052:	f486                	sd	ra,104(sp)
    80006054:	f0a2                	sd	s0,96(sp)
    80006056:	eca6                	sd	s1,88(sp)
    80006058:	e8ca                	sd	s2,80(sp)
    8000605a:	e4ce                	sd	s3,72(sp)
    8000605c:	e0d2                	sd	s4,64(sp)
    8000605e:	fc56                	sd	s5,56(sp)
    80006060:	f85a                	sd	s6,48(sp)
    80006062:	f45e                	sd	s7,40(sp)
    80006064:	f062                	sd	s8,32(sp)
    80006066:	ec66                	sd	s9,24(sp)
    80006068:	1880                	addi	s0,sp,112
    8000606a:	8a2a                	mv	s4,a0
    8000606c:	8bae                	mv	s7,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    8000606e:	00c52c83          	lw	s9,12(a0)
    80006072:	001c9c9b          	slliw	s9,s9,0x1
    80006076:	1c82                	slli	s9,s9,0x20
    80006078:	020cdc93          	srli	s9,s9,0x20

  acquire(&disk.vdisk_lock);
    8000607c:	0001c517          	auipc	a0,0x1c
    80006080:	da450513          	addi	a0,a0,-604 # 80021e20 <disk+0x128>
    80006084:	c39fa0ef          	jal	80000cbc <acquire>
  for(int i = 0; i < 3; i++){
    80006088:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    8000608a:	44a1                	li	s1,8
      disk.free[i] = 0;
    8000608c:	0001cb17          	auipc	s6,0x1c
    80006090:	c6cb0b13          	addi	s6,s6,-916 # 80021cf8 <disk>
  for(int i = 0; i < 3; i++){
    80006094:	4a8d                	li	s5,3
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80006096:	0001cc17          	auipc	s8,0x1c
    8000609a:	d8ac0c13          	addi	s8,s8,-630 # 80021e20 <disk+0x128>
    8000609e:	a8b9                	j	800060fc <virtio_disk_rw+0xac>
      disk.free[i] = 0;
    800060a0:	00fb0733          	add	a4,s6,a5
    800060a4:	00070c23          	sb	zero,24(a4) # 10001018 <_entry-0x6fffefe8>
    idx[i] = alloc_desc();
    800060a8:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    800060aa:	0207c563          	bltz	a5,800060d4 <virtio_disk_rw+0x84>
  for(int i = 0; i < 3; i++){
    800060ae:	2905                	addiw	s2,s2,1
    800060b0:	0611                	addi	a2,a2,4 # 1004 <_entry-0x7fffeffc>
    800060b2:	05590963          	beq	s2,s5,80006104 <virtio_disk_rw+0xb4>
    idx[i] = alloc_desc();
    800060b6:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    800060b8:	0001c717          	auipc	a4,0x1c
    800060bc:	c4070713          	addi	a4,a4,-960 # 80021cf8 <disk>
    800060c0:	87ce                	mv	a5,s3
    if(disk.free[i]){
    800060c2:	01874683          	lbu	a3,24(a4)
    800060c6:	fee9                	bnez	a3,800060a0 <virtio_disk_rw+0x50>
  for(int i = 0; i < NUM; i++){
    800060c8:	2785                	addiw	a5,a5,1
    800060ca:	0705                	addi	a4,a4,1
    800060cc:	fe979be3          	bne	a5,s1,800060c2 <virtio_disk_rw+0x72>
    idx[i] = alloc_desc();
    800060d0:	57fd                	li	a5,-1
    800060d2:	c19c                	sw	a5,0(a1)
      for(int j = 0; j < i; j++)
    800060d4:	01205d63          	blez	s2,800060ee <virtio_disk_rw+0x9e>
        free_desc(idx[j]);
    800060d8:	f9042503          	lw	a0,-112(s0)
    800060dc:	d07ff0ef          	jal	80005de2 <free_desc>
      for(int j = 0; j < i; j++)
    800060e0:	4785                	li	a5,1
    800060e2:	0127d663          	bge	a5,s2,800060ee <virtio_disk_rw+0x9e>
        free_desc(idx[j]);
    800060e6:	f9442503          	lw	a0,-108(s0)
    800060ea:	cf9ff0ef          	jal	80005de2 <free_desc>
    sleep(&disk.free[0], &disk.vdisk_lock);
    800060ee:	85e2                	mv	a1,s8
    800060f0:	0001c517          	auipc	a0,0x1c
    800060f4:	c2050513          	addi	a0,a0,-992 # 80021d10 <disk+0x18>
    800060f8:	c54fc0ef          	jal	8000254c <sleep>
  for(int i = 0; i < 3; i++){
    800060fc:	f9040613          	addi	a2,s0,-112
    80006100:	894e                	mv	s2,s3
    80006102:	bf55                	j	800060b6 <virtio_disk_rw+0x66>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80006104:	f9042503          	lw	a0,-112(s0)
    80006108:	00451693          	slli	a3,a0,0x4

  if(write)
    8000610c:	0001c797          	auipc	a5,0x1c
    80006110:	bec78793          	addi	a5,a5,-1044 # 80021cf8 <disk>
    80006114:	00a50713          	addi	a4,a0,10
    80006118:	0712                	slli	a4,a4,0x4
    8000611a:	973e                	add	a4,a4,a5
    8000611c:	01703633          	snez	a2,s7
    80006120:	c710                	sw	a2,8(a4)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    80006122:	00072623          	sw	zero,12(a4)
  buf0->sector = sector;
    80006126:	01973823          	sd	s9,16(a4)

  disk.desc[idx[0]].addr = (uint64) buf0;
    8000612a:	6398                	ld	a4,0(a5)
    8000612c:	9736                	add	a4,a4,a3
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    8000612e:	0a868613          	addi	a2,a3,168
    80006132:	963e                	add	a2,a2,a5
  disk.desc[idx[0]].addr = (uint64) buf0;
    80006134:	e310                	sd	a2,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    80006136:	6390                	ld	a2,0(a5)
    80006138:	00d605b3          	add	a1,a2,a3
    8000613c:	4741                	li	a4,16
    8000613e:	c598                	sw	a4,8(a1)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    80006140:	4805                	li	a6,1
    80006142:	01059623          	sh	a6,12(a1)
  disk.desc[idx[0]].next = idx[1];
    80006146:	f9442703          	lw	a4,-108(s0)
    8000614a:	00e59723          	sh	a4,14(a1)

  disk.desc[idx[1]].addr = (uint64) b->data;
    8000614e:	0712                	slli	a4,a4,0x4
    80006150:	963a                	add	a2,a2,a4
    80006152:	058a0593          	addi	a1,s4,88
    80006156:	e20c                	sd	a1,0(a2)
  disk.desc[idx[1]].len = BSIZE;
    80006158:	0007b883          	ld	a7,0(a5)
    8000615c:	9746                	add	a4,a4,a7
    8000615e:	40000613          	li	a2,1024
    80006162:	c710                	sw	a2,8(a4)
  if(write)
    80006164:	001bb613          	seqz	a2,s7
    80006168:	0016161b          	slliw	a2,a2,0x1
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    8000616c:	00166613          	ori	a2,a2,1
    80006170:	00c71623          	sh	a2,12(a4)
  disk.desc[idx[1]].next = idx[2];
    80006174:	f9842583          	lw	a1,-104(s0)
    80006178:	00b71723          	sh	a1,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    8000617c:	00250613          	addi	a2,a0,2
    80006180:	0612                	slli	a2,a2,0x4
    80006182:	963e                	add	a2,a2,a5
    80006184:	577d                	li	a4,-1
    80006186:	00e60823          	sb	a4,16(a2)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    8000618a:	0592                	slli	a1,a1,0x4
    8000618c:	98ae                	add	a7,a7,a1
    8000618e:	03068713          	addi	a4,a3,48
    80006192:	973e                	add	a4,a4,a5
    80006194:	00e8b023          	sd	a4,0(a7)
  disk.desc[idx[2]].len = 1;
    80006198:	6398                	ld	a4,0(a5)
    8000619a:	972e                	add	a4,a4,a1
    8000619c:	01072423          	sw	a6,8(a4)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    800061a0:	4689                	li	a3,2
    800061a2:	00d71623          	sh	a3,12(a4)
  disk.desc[idx[2]].next = 0;
    800061a6:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    800061aa:	010a2223          	sw	a6,4(s4)
  disk.info[idx[0]].b = b;
    800061ae:	01463423          	sd	s4,8(a2)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    800061b2:	6794                	ld	a3,8(a5)
    800061b4:	0026d703          	lhu	a4,2(a3)
    800061b8:	8b1d                	andi	a4,a4,7
    800061ba:	0706                	slli	a4,a4,0x1
    800061bc:	96ba                	add	a3,a3,a4
    800061be:	00a69223          	sh	a0,4(a3)

  __sync_synchronize();
    800061c2:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    800061c6:	6798                	ld	a4,8(a5)
    800061c8:	00275783          	lhu	a5,2(a4)
    800061cc:	2785                	addiw	a5,a5,1
    800061ce:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    800061d2:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    800061d6:	100017b7          	lui	a5,0x10001
    800061da:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    800061de:	004a2783          	lw	a5,4(s4)
    sleep(b, &disk.vdisk_lock);
    800061e2:	0001c917          	auipc	s2,0x1c
    800061e6:	c3e90913          	addi	s2,s2,-962 # 80021e20 <disk+0x128>
  while(b->disk == 1) {
    800061ea:	4485                	li	s1,1
    800061ec:	01079a63          	bne	a5,a6,80006200 <virtio_disk_rw+0x1b0>
    sleep(b, &disk.vdisk_lock);
    800061f0:	85ca                	mv	a1,s2
    800061f2:	8552                	mv	a0,s4
    800061f4:	b58fc0ef          	jal	8000254c <sleep>
  while(b->disk == 1) {
    800061f8:	004a2783          	lw	a5,4(s4)
    800061fc:	fe978ae3          	beq	a5,s1,800061f0 <virtio_disk_rw+0x1a0>
  }

  disk.info[idx[0]].b = 0;
    80006200:	f9042903          	lw	s2,-112(s0)
    80006204:	00290713          	addi	a4,s2,2
    80006208:	0712                	slli	a4,a4,0x4
    8000620a:	0001c797          	auipc	a5,0x1c
    8000620e:	aee78793          	addi	a5,a5,-1298 # 80021cf8 <disk>
    80006212:	97ba                	add	a5,a5,a4
    80006214:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    80006218:	0001c997          	auipc	s3,0x1c
    8000621c:	ae098993          	addi	s3,s3,-1312 # 80021cf8 <disk>
    80006220:	00491713          	slli	a4,s2,0x4
    80006224:	0009b783          	ld	a5,0(s3)
    80006228:	97ba                	add	a5,a5,a4
    8000622a:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    8000622e:	854a                	mv	a0,s2
    80006230:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    80006234:	bafff0ef          	jal	80005de2 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    80006238:	8885                	andi	s1,s1,1
    8000623a:	f0fd                	bnez	s1,80006220 <virtio_disk_rw+0x1d0>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    8000623c:	0001c517          	auipc	a0,0x1c
    80006240:	be450513          	addi	a0,a0,-1052 # 80021e20 <disk+0x128>
    80006244:	b11fa0ef          	jal	80000d54 <release>
}
    80006248:	70a6                	ld	ra,104(sp)
    8000624a:	7406                	ld	s0,96(sp)
    8000624c:	64e6                	ld	s1,88(sp)
    8000624e:	6946                	ld	s2,80(sp)
    80006250:	69a6                	ld	s3,72(sp)
    80006252:	6a06                	ld	s4,64(sp)
    80006254:	7ae2                	ld	s5,56(sp)
    80006256:	7b42                	ld	s6,48(sp)
    80006258:	7ba2                	ld	s7,40(sp)
    8000625a:	7c02                	ld	s8,32(sp)
    8000625c:	6ce2                	ld	s9,24(sp)
    8000625e:	6165                	addi	sp,sp,112
    80006260:	8082                	ret

0000000080006262 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    80006262:	1101                	addi	sp,sp,-32
    80006264:	ec06                	sd	ra,24(sp)
    80006266:	e822                	sd	s0,16(sp)
    80006268:	e426                	sd	s1,8(sp)
    8000626a:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    8000626c:	0001c497          	auipc	s1,0x1c
    80006270:	a8c48493          	addi	s1,s1,-1396 # 80021cf8 <disk>
    80006274:	0001c517          	auipc	a0,0x1c
    80006278:	bac50513          	addi	a0,a0,-1108 # 80021e20 <disk+0x128>
    8000627c:	a41fa0ef          	jal	80000cbc <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    80006280:	100017b7          	lui	a5,0x10001
    80006284:	53b8                	lw	a4,96(a5)
    80006286:	8b0d                	andi	a4,a4,3
    80006288:	100017b7          	lui	a5,0x10001
    8000628c:	d3f8                	sw	a4,100(a5)

  __sync_synchronize();
    8000628e:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    80006292:	689c                	ld	a5,16(s1)
    80006294:	0204d703          	lhu	a4,32(s1)
    80006298:	0027d783          	lhu	a5,2(a5) # 10001002 <_entry-0x6fffeffe>
    8000629c:	04f70663          	beq	a4,a5,800062e8 <virtio_disk_intr+0x86>
    __sync_synchronize();
    800062a0:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    800062a4:	6898                	ld	a4,16(s1)
    800062a6:	0204d783          	lhu	a5,32(s1)
    800062aa:	8b9d                	andi	a5,a5,7
    800062ac:	078e                	slli	a5,a5,0x3
    800062ae:	97ba                	add	a5,a5,a4
    800062b0:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    800062b2:	00278713          	addi	a4,a5,2
    800062b6:	0712                	slli	a4,a4,0x4
    800062b8:	9726                	add	a4,a4,s1
    800062ba:	01074703          	lbu	a4,16(a4)
    800062be:	e321                	bnez	a4,800062fe <virtio_disk_intr+0x9c>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    800062c0:	0789                	addi	a5,a5,2
    800062c2:	0792                	slli	a5,a5,0x4
    800062c4:	97a6                	add	a5,a5,s1
    800062c6:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    800062c8:	00052223          	sw	zero,4(a0)
    wakeup(b);
    800062cc:	ad0fc0ef          	jal	8000259c <wakeup>

    disk.used_idx += 1;
    800062d0:	0204d783          	lhu	a5,32(s1)
    800062d4:	2785                	addiw	a5,a5,1
    800062d6:	17c2                	slli	a5,a5,0x30
    800062d8:	93c1                	srli	a5,a5,0x30
    800062da:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    800062de:	6898                	ld	a4,16(s1)
    800062e0:	00275703          	lhu	a4,2(a4)
    800062e4:	faf71ee3          	bne	a4,a5,800062a0 <virtio_disk_intr+0x3e>
  }

  release(&disk.vdisk_lock);
    800062e8:	0001c517          	auipc	a0,0x1c
    800062ec:	b3850513          	addi	a0,a0,-1224 # 80021e20 <disk+0x128>
    800062f0:	a65fa0ef          	jal	80000d54 <release>
}
    800062f4:	60e2                	ld	ra,24(sp)
    800062f6:	6442                	ld	s0,16(sp)
    800062f8:	64a2                	ld	s1,8(sp)
    800062fa:	6105                	addi	sp,sp,32
    800062fc:	8082                	ret
      panic("virtio_disk_intr status");
    800062fe:	00002517          	auipc	a0,0x2
    80006302:	44250513          	addi	a0,a0,1090 # 80008740 <etext+0x740>
    80006306:	d0cfa0ef          	jal	80000812 <panic>

000000008000630a <cslog_init>:
  safestrcpy(e->name, p->name, CS_NM);
}

void
cslog_init(void)
{
    8000630a:	1141                	addi	sp,sp,-16
    8000630c:	e406                	sd	ra,8(sp)
    8000630e:	e022                	sd	s0,0(sp)
    80006310:	0800                	addi	s0,sp,16
  ringbuf_init(&cs_rb, "cslog", sizeof(struct cs_event));
    80006312:	03000613          	li	a2,48
    80006316:	00002597          	auipc	a1,0x2
    8000631a:	44258593          	addi	a1,a1,1090 # 80008758 <etext+0x758>
    8000631e:	0001c517          	auipc	a0,0x1c
    80006322:	b1a50513          	addi	a0,a0,-1254 # 80021e38 <cs_rb>
    80006326:	1b2000ef          	jal	800064d8 <ringbuf_init>
}
    8000632a:	60a2                	ld	ra,8(sp)
    8000632c:	6402                	ld	s0,0(sp)
    8000632e:	0141                	addi	sp,sp,16
    80006330:	8082                	ret

0000000080006332 <cslog_push>:

void
cslog_push(struct cs_event *e)
{
    80006332:	1141                	addi	sp,sp,-16
    80006334:	e406                	sd	ra,8(sp)
    80006336:	e022                	sd	s0,0(sp)
    80006338:	0800                	addi	s0,sp,16
    8000633a:	85aa                	mv	a1,a0
  e->seq = ++cs_seq;
    8000633c:	00002717          	auipc	a4,0x2
    80006340:	5fc70713          	addi	a4,a4,1532 # 80008938 <cs_seq>
    80006344:	631c                	ld	a5,0(a4)
    80006346:	0785                	addi	a5,a5,1
    80006348:	e31c                	sd	a5,0(a4)
    8000634a:	e11c                	sd	a5,0(a0)
  ringbuf_push(&cs_rb, e);
    8000634c:	0001c517          	auipc	a0,0x1c
    80006350:	aec50513          	addi	a0,a0,-1300 # 80021e38 <cs_rb>
    80006354:	1b8000ef          	jal	8000650c <ringbuf_push>
}
    80006358:	60a2                	ld	ra,8(sp)
    8000635a:	6402                	ld	s0,0(sp)
    8000635c:	0141                	addi	sp,sp,16
    8000635e:	8082                	ret

0000000080006360 <cslog_read_many>:

int
cslog_read_many(struct cs_event *out, int max)
{
    80006360:	1141                	addi	sp,sp,-16
    80006362:	e406                	sd	ra,8(sp)
    80006364:	e022                	sd	s0,0(sp)
    80006366:	0800                	addi	s0,sp,16
    80006368:	862e                	mv	a2,a1
  return ringbuf_read_many(&cs_rb, out, max);
    8000636a:	85aa                	mv	a1,a0
    8000636c:	0001c517          	auipc	a0,0x1c
    80006370:	acc50513          	addi	a0,a0,-1332 # 80021e38 <cs_rb>
    80006374:	204000ef          	jal	80006578 <ringbuf_read_many>
}
    80006378:	60a2                	ld	ra,8(sp)
    8000637a:	6402                	ld	s0,0(sp)
    8000637c:	0141                	addi	sp,sp,16
    8000637e:	8082                	ret

0000000080006380 <cslog_run_start>:

void
cslog_run_start(struct proc *p)
{
  if(p == 0) return;
    80006380:	c14d                	beqz	a0,80006422 <cslog_run_start+0xa2>
{
    80006382:	715d                	addi	sp,sp,-80
    80006384:	e486                	sd	ra,72(sp)
    80006386:	e0a2                	sd	s0,64(sp)
    80006388:	fc26                	sd	s1,56(sp)
    8000638a:	0880                	addi	s0,sp,80
    8000638c:	84aa                	mv	s1,a0
  if(p->pid <= 0) return;
    8000638e:	595c                	lw	a5,52(a0)
    80006390:	00f05563          	blez	a5,8000639a <cslog_run_start+0x1a>
  if(p->name[0] == 0) return;
    80006394:	15854783          	lbu	a5,344(a0)
    80006398:	e791                	bnez	a5,800063a4 <cslog_run_start+0x24>

  struct cs_event e;
  fill_from_proc(&e, p);
  e.type = CS_RUN_START;
  cslog_push(&e);
    8000639a:	60a6                	ld	ra,72(sp)
    8000639c:	6406                	ld	s0,64(sp)
    8000639e:	74e2                	ld	s1,56(sp)
    800063a0:	6161                	addi	sp,sp,80
    800063a2:	8082                	ret
    800063a4:	f84a                	sd	s2,48(sp)
  if(strncmp(p->name, "cscat", 5) == 0) return;
    800063a6:	15850913          	addi	s2,a0,344
    800063aa:	4615                	li	a2,5
    800063ac:	00002597          	auipc	a1,0x2
    800063b0:	3b458593          	addi	a1,a1,948 # 80008760 <etext+0x760>
    800063b4:	854a                	mv	a0,s2
    800063b6:	aa7fa0ef          	jal	80000e5c <strncmp>
    800063ba:	e119                	bnez	a0,800063c0 <cslog_run_start+0x40>
    800063bc:	7942                	ld	s2,48(sp)
    800063be:	bff1                	j	8000639a <cslog_run_start+0x1a>
  if(strncmp(p->name, "csexport", 8) == 0) return;
    800063c0:	4621                	li	a2,8
    800063c2:	00002597          	auipc	a1,0x2
    800063c6:	3a658593          	addi	a1,a1,934 # 80008768 <etext+0x768>
    800063ca:	854a                	mv	a0,s2
    800063cc:	a91fa0ef          	jal	80000e5c <strncmp>
    800063d0:	e119                	bnez	a0,800063d6 <cslog_run_start+0x56>
    800063d2:	7942                	ld	s2,48(sp)
    800063d4:	b7d9                	j	8000639a <cslog_run_start+0x1a>
  memset(e, 0, sizeof(*e));
    800063d6:	03000613          	li	a2,48
    800063da:	4581                	li	a1,0
    800063dc:	fb040513          	addi	a0,s0,-80
    800063e0:	9b1fa0ef          	jal	80000d90 <memset>
  e->ticks = ticks;
    800063e4:	00002797          	auipc	a5,0x2
    800063e8:	54c7a783          	lw	a5,1356(a5) # 80008930 <ticks>
    800063ec:	faf42c23          	sw	a5,-72(s0)
  e->cpu   = cpuid();
    800063f0:	865fb0ef          	jal	80001c54 <cpuid>
    800063f4:	faa42e23          	sw	a0,-68(s0)
  e->pid   = p->pid;
    800063f8:	58dc                	lw	a5,52(s1)
    800063fa:	fcf42223          	sw	a5,-60(s0)
  e->state = p->state;
    800063fe:	4c9c                	lw	a5,24(s1)
    80006400:	fcf42423          	sw	a5,-56(s0)
  safestrcpy(e->name, p->name, CS_NM);
    80006404:	4641                	li	a2,16
    80006406:	85ca                	mv	a1,s2
    80006408:	fcc40513          	addi	a0,s0,-52
    8000640c:	ac3fa0ef          	jal	80000ece <safestrcpy>
  e.type = CS_RUN_START;
    80006410:	4785                	li	a5,1
    80006412:	fcf42023          	sw	a5,-64(s0)
  cslog_push(&e);
    80006416:	fb040513          	addi	a0,s0,-80
    8000641a:	f19ff0ef          	jal	80006332 <cslog_push>
    8000641e:	7942                	ld	s2,48(sp)
    80006420:	bfad                	j	8000639a <cslog_run_start+0x1a>
    80006422:	8082                	ret

0000000080006424 <sys_csread>:
#include "cslog.h"


uint64
sys_csread(void)
{
    80006424:	81010113          	addi	sp,sp,-2032
    80006428:	7e113423          	sd	ra,2024(sp)
    8000642c:	7e813023          	sd	s0,2016(sp)
    80006430:	7c913c23          	sd	s1,2008(sp)
    80006434:	7d213823          	sd	s2,2000(sp)
    80006438:	7f010413          	addi	s0,sp,2032
    8000643c:	bb010113          	addi	sp,sp,-1104
  uint64 uaddr = 0;
    80006440:	fc043c23          	sd	zero,-40(s0)
  int max = 0;
    80006444:	fc042a23          	sw	zero,-44(s0)

  // ✅ عندك argaddr/argint void، فبنستدعيهم بدون if
  argaddr(0, &uaddr);
    80006448:	fd840593          	addi	a1,s0,-40
    8000644c:	4501                	li	a0,0
    8000644e:	a45fc0ef          	jal	80002e92 <argaddr>
  argint(1, &max);
    80006452:	fd440593          	addi	a1,s0,-44
    80006456:	4505                	li	a0,1
    80006458:	a1ffc0ef          	jal	80002e76 <argint>

  if(max <= 0) return 0;
    8000645c:	fd442783          	lw	a5,-44(s0)
    80006460:	4501                	li	a0,0
    80006462:	04f05c63          	blez	a5,800064ba <sys_csread+0x96>
  if(max > 64) max = 64;
    80006466:	04000713          	li	a4,64
    8000646a:	00f75663          	bge	a4,a5,80006476 <sys_csread+0x52>
    8000646e:	04000793          	li	a5,64
    80006472:	fcf42a23          	sw	a5,-44(s0)

  struct cs_event tmp[64];
  int n = cslog_read_many(tmp, max);
    80006476:	77fd                	lui	a5,0xfffff
    80006478:	3d078793          	addi	a5,a5,976 # fffffffffffff3d0 <end+0xffffffff7ffb84f0>
    8000647c:	97a2                	add	a5,a5,s0
    8000647e:	797d                	lui	s2,0xfffff
    80006480:	3c890713          	addi	a4,s2,968 # fffffffffffff3c8 <end+0xffffffff7ffb84e8>
    80006484:	9722                	add	a4,a4,s0
    80006486:	e31c                	sd	a5,0(a4)
    80006488:	fd442583          	lw	a1,-44(s0)
    8000648c:	6308                	ld	a0,0(a4)
    8000648e:	ed3ff0ef          	jal	80006360 <cslog_read_many>
    80006492:	84aa                	mv	s1,a0

  int bytes = n * (int)sizeof(struct cs_event);
  if(copyout(myproc()->pagetable, uaddr, (char*)tmp, bytes) < 0)
    80006494:	ff2fb0ef          	jal	80001c86 <myproc>
  int bytes = n * (int)sizeof(struct cs_event);
    80006498:	0014969b          	slliw	a3,s1,0x1
    8000649c:	9ea5                	addw	a3,a3,s1
  if(copyout(myproc()->pagetable, uaddr, (char*)tmp, bytes) < 0)
    8000649e:	0046969b          	slliw	a3,a3,0x4
    800064a2:	3c890793          	addi	a5,s2,968
    800064a6:	97a2                	add	a5,a5,s0
    800064a8:	6390                	ld	a2,0(a5)
    800064aa:	fd843583          	ld	a1,-40(s0)
    800064ae:	6928                	ld	a0,80(a0)
    800064b0:	c60fb0ef          	jal	80001910 <copyout>
    800064b4:	02054063          	bltz	a0,800064d4 <sys_csread+0xb0>
    return -1;

  return n;
    800064b8:	8526                	mv	a0,s1
}
    800064ba:	45010113          	addi	sp,sp,1104
    800064be:	7e813083          	ld	ra,2024(sp)
    800064c2:	7e013403          	ld	s0,2016(sp)
    800064c6:	7d813483          	ld	s1,2008(sp)
    800064ca:	7d013903          	ld	s2,2000(sp)
    800064ce:	7f010113          	addi	sp,sp,2032
    800064d2:	8082                	ret
    return -1;
    800064d4:	557d                	li	a0,-1
    800064d6:	b7d5                	j	800064ba <sys_csread+0x96>

00000000800064d8 <ringbuf_init>:
  return (void *)(rb->buf + idx * rb->elem_size);
}

void
ringbuf_init(struct ringbuf *rb, char *name, uint elem_size)
{
    800064d8:	1101                	addi	sp,sp,-32
    800064da:	ec06                	sd	ra,24(sp)
    800064dc:	e822                	sd	s0,16(sp)
    800064de:	e426                	sd	s1,8(sp)
    800064e0:	e04a                	sd	s2,0(sp)
    800064e2:	1000                	addi	s0,sp,32
    800064e4:	84aa                	mv	s1,a0
    800064e6:	8932                	mv	s2,a2
  initlock(&rb->lock, name);
    800064e8:	f54fa0ef          	jal	80000c3c <initlock>
  rb->head = 0;
    800064ec:	0004ac23          	sw	zero,24(s1)
  rb->tail = 0;
    800064f0:	0004ae23          	sw	zero,28(s1)
  rb->count = 0;
    800064f4:	0204a023          	sw	zero,32(s1)
  rb->seq = 0;
    800064f8:	0204b423          	sd	zero,40(s1)
  rb->elem_size = elem_size;
    800064fc:	0324a223          	sw	s2,36(s1)
}
    80006500:	60e2                	ld	ra,24(sp)
    80006502:	6442                	ld	s0,16(sp)
    80006504:	64a2                	ld	s1,8(sp)
    80006506:	6902                	ld	s2,0(sp)
    80006508:	6105                	addi	sp,sp,32
    8000650a:	8082                	ret

000000008000650c <ringbuf_push>:

int
ringbuf_push(struct ringbuf *rb, void *elem)
{
    8000650c:	1101                	addi	sp,sp,-32
    8000650e:	ec06                	sd	ra,24(sp)
    80006510:	e822                	sd	s0,16(sp)
    80006512:	e426                	sd	s1,8(sp)
    80006514:	e04a                	sd	s2,0(sp)
    80006516:	1000                	addi	s0,sp,32
    80006518:	84aa                	mv	s1,a0
    8000651a:	892e                	mv	s2,a1
  acquire(&rb->lock);
    8000651c:	fa0fa0ef          	jal	80000cbc <acquire>

  if(rb->count == RB_CAP){
    80006520:	5098                	lw	a4,32(s1)
    80006522:	20000793          	li	a5,512
    80006526:	04f70063          	beq	a4,a5,80006566 <ringbuf_push+0x5a>
  return (void *)(rb->buf + idx * rb->elem_size);
    8000652a:	50d0                	lw	a2,36(s1)
    8000652c:	03048513          	addi	a0,s1,48
    80006530:	4c9c                	lw	a5,24(s1)
    80006532:	02c787bb          	mulw	a5,a5,a2
    80006536:	1782                	slli	a5,a5,0x20
    80006538:	9381                	srli	a5,a5,0x20
    rb->tail = (rb->tail + 1) % RB_CAP;
    rb->count--;
  }

  memmove(slot_ptr(rb, rb->head), elem, rb->elem_size);
    8000653a:	85ca                	mv	a1,s2
    8000653c:	953e                	add	a0,a0,a5
    8000653e:	8affa0ef          	jal	80000dec <memmove>
  rb->head = (rb->head + 1) % RB_CAP;
    80006542:	4c9c                	lw	a5,24(s1)
    80006544:	2785                	addiw	a5,a5,1
    80006546:	1ff7f793          	andi	a5,a5,511
    8000654a:	cc9c                	sw	a5,24(s1)
  rb->count++;
    8000654c:	509c                	lw	a5,32(s1)
    8000654e:	2785                	addiw	a5,a5,1
    80006550:	d09c                	sw	a5,32(s1)

  release(&rb->lock);
    80006552:	8526                	mv	a0,s1
    80006554:	801fa0ef          	jal	80000d54 <release>
  return 0;
}
    80006558:	4501                	li	a0,0
    8000655a:	60e2                	ld	ra,24(sp)
    8000655c:	6442                	ld	s0,16(sp)
    8000655e:	64a2                	ld	s1,8(sp)
    80006560:	6902                	ld	s2,0(sp)
    80006562:	6105                	addi	sp,sp,32
    80006564:	8082                	ret
    rb->tail = (rb->tail + 1) % RB_CAP;
    80006566:	4cdc                	lw	a5,28(s1)
    80006568:	2785                	addiw	a5,a5,1
    8000656a:	1ff7f793          	andi	a5,a5,511
    8000656e:	ccdc                	sw	a5,28(s1)
    rb->count--;
    80006570:	1ff00793          	li	a5,511
    80006574:	d09c                	sw	a5,32(s1)
    80006576:	bf55                	j	8000652a <ringbuf_push+0x1e>

0000000080006578 <ringbuf_read_many>:

int
ringbuf_read_many(struct ringbuf *rb, void *out, int max)
{
    80006578:	7139                	addi	sp,sp,-64
    8000657a:	fc06                	sd	ra,56(sp)
    8000657c:	f822                	sd	s0,48(sp)
    8000657e:	f04a                	sd	s2,32(sp)
    80006580:	0080                	addi	s0,sp,64
  int n = 0;
  char *dst = (char *)out;

  if(max <= 0)
    return 0;
    80006582:	4901                	li	s2,0
  if(max <= 0)
    80006584:	06c05163          	blez	a2,800065e6 <ringbuf_read_many+0x6e>
    80006588:	f426                	sd	s1,40(sp)
    8000658a:	ec4e                	sd	s3,24(sp)
    8000658c:	e852                	sd	s4,16(sp)
    8000658e:	e456                	sd	s5,8(sp)
    80006590:	84aa                	mv	s1,a0
    80006592:	8a2e                	mv	s4,a1
    80006594:	89b2                	mv	s3,a2

  acquire(&rb->lock);
    80006596:	f26fa0ef          	jal	80000cbc <acquire>
  int n = 0;
    8000659a:	4901                	li	s2,0
  return (void *)(rb->buf + idx * rb->elem_size);
    8000659c:	03048a93          	addi	s5,s1,48
  while(n < max && rb->count > 0){
    800065a0:	509c                	lw	a5,32(s1)
    800065a2:	cb9d                	beqz	a5,800065d8 <ringbuf_read_many+0x60>
    memmove(dst + n * rb->elem_size, slot_ptr(rb, rb->tail), rb->elem_size);
    800065a4:	50d0                	lw	a2,36(s1)
  return (void *)(rb->buf + idx * rb->elem_size);
    800065a6:	4ccc                	lw	a1,28(s1)
    800065a8:	02c585bb          	mulw	a1,a1,a2
    800065ac:	1582                	slli	a1,a1,0x20
    800065ae:	9181                	srli	a1,a1,0x20
    memmove(dst + n * rb->elem_size, slot_ptr(rb, rb->tail), rb->elem_size);
    800065b0:	02c9053b          	mulw	a0,s2,a2
    800065b4:	1502                	slli	a0,a0,0x20
    800065b6:	9101                	srli	a0,a0,0x20
    800065b8:	95d6                	add	a1,a1,s5
    800065ba:	9552                	add	a0,a0,s4
    800065bc:	831fa0ef          	jal	80000dec <memmove>
    rb->tail = (rb->tail + 1) % RB_CAP;
    800065c0:	4cdc                	lw	a5,28(s1)
    800065c2:	2785                	addiw	a5,a5,1
    800065c4:	1ff7f793          	andi	a5,a5,511
    800065c8:	ccdc                	sw	a5,28(s1)
    rb->count--;
    800065ca:	509c                	lw	a5,32(s1)
    800065cc:	37fd                	addiw	a5,a5,-1
    800065ce:	d09c                	sw	a5,32(s1)
    n++;
    800065d0:	2905                	addiw	s2,s2,1
  while(n < max && rb->count > 0){
    800065d2:	fd2997e3          	bne	s3,s2,800065a0 <ringbuf_read_many+0x28>
    800065d6:	894e                	mv	s2,s3
  }
  release(&rb->lock);
    800065d8:	8526                	mv	a0,s1
    800065da:	f7afa0ef          	jal	80000d54 <release>

  return n;
    800065de:	74a2                	ld	s1,40(sp)
    800065e0:	69e2                	ld	s3,24(sp)
    800065e2:	6a42                	ld	s4,16(sp)
    800065e4:	6aa2                	ld	s5,8(sp)
}
    800065e6:	854a                	mv	a0,s2
    800065e8:	70e2                	ld	ra,56(sp)
    800065ea:	7442                	ld	s0,48(sp)
    800065ec:	7902                	ld	s2,32(sp)
    800065ee:	6121                	addi	sp,sp,64
    800065f0:	8082                	ret

00000000800065f2 <ringbuf_pop>:
int
ringbuf_pop(struct ringbuf *rb, void *dst)
{
    800065f2:	1101                	addi	sp,sp,-32
    800065f4:	ec06                	sd	ra,24(sp)
    800065f6:	e822                	sd	s0,16(sp)
    800065f8:	e426                	sd	s1,8(sp)
    800065fa:	e04a                	sd	s2,0(sp)
    800065fc:	1000                	addi	s0,sp,32
    800065fe:	84aa                	mv	s1,a0
    80006600:	892e                	mv	s2,a1
  acquire(&rb->lock);
    80006602:	ebafa0ef          	jal	80000cbc <acquire>
  
  if(rb->count == 0){ // البفر فارغ تماماً
    80006606:	509c                	lw	a5,32(s1)
    80006608:	cf9d                	beqz	a5,80006646 <ringbuf_pop+0x54>
  return (void *)(rb->buf + idx * rb->elem_size);
    8000660a:	50d0                	lw	a2,36(s1)
    8000660c:	03048593          	addi	a1,s1,48
    80006610:	4cdc                	lw	a5,28(s1)
    80006612:	02c787bb          	mulw	a5,a5,a2
    80006616:	1782                	slli	a5,a5,0x20
    80006618:	9381                	srli	a5,a5,0x20
    return -1;
  }

  // استخدام الدالة المساعدة slot_ptr الموجودة عندك أصلاً
  void *src = slot_ptr(rb, rb->tail);
  memmove(dst, src, rb->elem_size);
    8000661a:	95be                	add	a1,a1,a5
    8000661c:	854a                	mv	a0,s2
    8000661e:	fcefa0ef          	jal	80000dec <memmove>
  
  // تحديث المؤشرات بنفس منطق المشروع
  rb->tail = (rb->tail + 1) % RB_CAP;
    80006622:	4cdc                	lw	a5,28(s1)
    80006624:	2785                	addiw	a5,a5,1
    80006626:	1ff7f793          	andi	a5,a5,511
    8000662a:	ccdc                	sw	a5,28(s1)
  rb->count--;
    8000662c:	509c                	lw	a5,32(s1)
    8000662e:	37fd                	addiw	a5,a5,-1
    80006630:	d09c                	sw	a5,32(s1)
  
  release(&rb->lock);
    80006632:	8526                	mv	a0,s1
    80006634:	f20fa0ef          	jal	80000d54 <release>
  return 0;
    80006638:	4501                	li	a0,0
} 
    8000663a:	60e2                	ld	ra,24(sp)
    8000663c:	6442                	ld	s0,16(sp)
    8000663e:	64a2                	ld	s1,8(sp)
    80006640:	6902                	ld	s2,0(sp)
    80006642:	6105                	addi	sp,sp,32
    80006644:	8082                	ret
    release(&rb->lock);
    80006646:	8526                	mv	a0,s1
    80006648:	f0cfa0ef          	jal	80000d54 <release>
    return -1;
    8000664c:	557d                	li	a0,-1
    8000664e:	b7f5                	j	8000663a <ringbuf_pop+0x48>

0000000080006650 <fslog_init>:
#include "defs.h"

static struct ringbuf fs_rb;
static uint64 fs_seq = 0;

void fslog_init(void) {
    80006650:	1141                	addi	sp,sp,-16
    80006652:	e406                	sd	ra,8(sp)
    80006654:	e022                	sd	s0,0(sp)
    80006656:	0800                	addi	s0,sp,16
  ringbuf_init(&fs_rb, "fslog", sizeof(struct fs_event));
    80006658:	03000613          	li	a2,48
    8000665c:	00002597          	auipc	a1,0x2
    80006660:	11c58593          	addi	a1,a1,284 # 80008778 <etext+0x778>
    80006664:	00024517          	auipc	a0,0x24
    80006668:	80450513          	addi	a0,a0,-2044 # 80029e68 <fs_rb>
    8000666c:	e6dff0ef          	jal	800064d8 <ringbuf_init>
}
    80006670:	60a2                	ld	ra,8(sp)
    80006672:	6402                	ld	s0,0(sp)
    80006674:	0141                	addi	sp,sp,16
    80006676:	8082                	ret

0000000080006678 <fslog_push>:

void fslog_push(int type, int inum, int bno, uint size, char* name) {
    80006678:	7159                	addi	sp,sp,-112
    8000667a:	f486                	sd	ra,104(sp)
    8000667c:	f0a2                	sd	s0,96(sp)
    8000667e:	eca6                	sd	s1,88(sp)
    80006680:	e8ca                	sd	s2,80(sp)
    80006682:	e4ce                	sd	s3,72(sp)
    80006684:	e0d2                	sd	s4,64(sp)
    80006686:	fc56                	sd	s5,56(sp)
    80006688:	1880                	addi	s0,sp,112
    8000668a:	8aaa                	mv	s5,a0
    8000668c:	8a2e                	mv	s4,a1
    8000668e:	89b2                	mv	s3,a2
    80006690:	8936                	mv	s2,a3
    80006692:	84ba                	mv	s1,a4
  struct fs_event e;
  memset(&e, 0, sizeof(e));
    80006694:	03000613          	li	a2,48
    80006698:	4581                	li	a1,0
    8000669a:	f9040513          	addi	a0,s0,-112
    8000669e:	ef2fa0ef          	jal	80000d90 <memset>
  e.seq = ++fs_seq;
    800066a2:	00002717          	auipc	a4,0x2
    800066a6:	29e70713          	addi	a4,a4,670 # 80008940 <fs_seq>
    800066aa:	631c                	ld	a5,0(a4)
    800066ac:	0785                	addi	a5,a5,1
    800066ae:	e31c                	sd	a5,0(a4)
    800066b0:	f8f43823          	sd	a5,-112(s0)
  e.ticks = ticks;
    800066b4:	00002797          	auipc	a5,0x2
    800066b8:	27c7a783          	lw	a5,636(a5) # 80008930 <ticks>
    800066bc:	f8f42c23          	sw	a5,-104(s0)
  e.type = type;
    800066c0:	f9542e23          	sw	s5,-100(s0)
  e.pid = myproc() ? myproc()->pid : 0;
    800066c4:	dc2fb0ef          	jal	80001c86 <myproc>
    800066c8:	4781                	li	a5,0
    800066ca:	c501                	beqz	a0,800066d2 <fslog_push+0x5a>
    800066cc:	dbafb0ef          	jal	80001c86 <myproc>
    800066d0:	595c                	lw	a5,52(a0)
    800066d2:	faf42023          	sw	a5,-96(s0)
  e.inum = inum;
    800066d6:	fb442223          	sw	s4,-92(s0)
  e.blockno = bno;
    800066da:	fb342423          	sw	s3,-88(s0)
  e.size = size;
    800066de:	fb242623          	sw	s2,-84(s0)
  if(name) safestrcpy(e.name, name, FS_NM);
    800066e2:	c499                	beqz	s1,800066f0 <fslog_push+0x78>
    800066e4:	4641                	li	a2,16
    800066e6:	85a6                	mv	a1,s1
    800066e8:	fb040513          	addi	a0,s0,-80
    800066ec:	fe2fa0ef          	jal	80000ece <safestrcpy>
  ringbuf_push(&fs_rb, &e);
    800066f0:	f9040593          	addi	a1,s0,-112
    800066f4:	00023517          	auipc	a0,0x23
    800066f8:	77450513          	addi	a0,a0,1908 # 80029e68 <fs_rb>
    800066fc:	e11ff0ef          	jal	8000650c <ringbuf_push>
}
    80006700:	70a6                	ld	ra,104(sp)
    80006702:	7406                	ld	s0,96(sp)
    80006704:	64e6                	ld	s1,88(sp)
    80006706:	6946                	ld	s2,80(sp)
    80006708:	69a6                	ld	s3,72(sp)
    8000670a:	6a06                	ld	s4,64(sp)
    8000670c:	7ae2                	ld	s5,56(sp)
    8000670e:	6165                	addi	sp,sp,112
    80006710:	8082                	ret

0000000080006712 <fslog_read_many>:
int
fslog_read_many(struct fs_event *out, int max)
{
    80006712:	9d010113          	addi	sp,sp,-1584
    80006716:	62113423          	sd	ra,1576(sp)
    8000671a:	62813023          	sd	s0,1568(sp)
    8000671e:	60913c23          	sd	s1,1560(sp)
    80006722:	61213823          	sd	s2,1552(sp)
    80006726:	61413023          	sd	s4,1536(sp)
    8000672a:	63010413          	addi	s0,sp,1584
    8000672e:	84aa                	mv	s1,a0
    80006730:	892e                	mv	s2,a1
  // 1. تعريف بافر مؤقت في الكيرنل يتسع لـ max من الأحداث
  // تم وضع حد أقصى 32 للأمان التام وتجنب فيضان الذاكرة
  if (max > 32) max = 32;
  
  struct fs_event local_buf[32];
  memset(local_buf, 0, sizeof(local_buf));
    80006732:	60000613          	li	a2,1536
    80006736:	4581                	li	a1,0
    80006738:	9d040513          	addi	a0,s0,-1584
    8000673c:	e54fa0ef          	jal	80000d90 <memset>
  if (max > 32) max = 32;
    80006740:	864a                	mv	a2,s2
    80006742:	02000793          	li	a5,32
    80006746:	0127d463          	bge	a5,s2,8000674e <fslog_read_many+0x3c>
    8000674a:	02000613          	li	a2,32

  // 2. القراءة الآمنة والدفعية من الـ Ring Buffer تحت قفل واحد مستمر
  // الدالة تعيد العدد الحقيقي للأحداث التي نجحت قراءتها (مثلاً n)
  int n = ringbuf_read_many(&fs_rb, local_buf, max);
    8000674e:	2601                	sext.w	a2,a2
    80006750:	9d040593          	addi	a1,s0,-1584
    80006754:	00023517          	auipc	a0,0x23
    80006758:	71450513          	addi	a0,a0,1812 # 80029e68 <fs_rb>
    8000675c:	e1dff0ef          	jal	80006578 <ringbuf_read_many>
    80006760:	8a2a                	mv	s4,a0
  if (n <= 0) {
    return 0; // البافر فارغ تماماً، توقف فوراً ولا تطبع مخلفات
    80006762:	4901                	li	s2,0
  if (n <= 0) {
    80006764:	02a05e63          	blez	a0,800067a0 <fslog_read_many+0x8e>
    80006768:	61313423          	sd	s3,1544(sp)
    8000676c:	9d040993          	addi	s3,s0,-1584
  // 3. الآن نقوم بنسخ الأحداث الحقيقية فقط (الـ n حدث) إلى ذاكرة المستخدم (User space)
  int copied = 0;
  while (copied < n) {
    uint64 dst_addr = (uint64)out + (copied * sizeof(struct fs_event));
    
    if (copyout(myproc()->pagetable, dst_addr, (char *)&local_buf[copied], sizeof(struct fs_event)) < 0) {
    80006770:	d16fb0ef          	jal	80001c86 <myproc>
    80006774:	03000693          	li	a3,48
    80006778:	864e                	mv	a2,s3
    8000677a:	85a6                	mv	a1,s1
    8000677c:	6928                	ld	a0,80(a0)
    8000677e:	992fb0ef          	jal	80001910 <copyout>
    80006782:	00054d63          	bltz	a0,8000679c <fslog_read_many+0x8a>
      break; // توقف إذا فشل نسخ الذاكرة لليوزر
    }
    copied++;
    80006786:	2905                	addiw	s2,s2,1
  while (copied < n) {
    80006788:	03048493          	addi	s1,s1,48
    8000678c:	03098993          	addi	s3,s3,48
    80006790:	ff2a10e3          	bne	s4,s2,80006770 <fslog_read_many+0x5e>
  }

  return copied; // إرجاع عدد الأحداث السليمة والمكتوبة كلياً
    80006794:	8952                	mv	s2,s4
    80006796:	60813983          	ld	s3,1544(sp)
    8000679a:	a019                	j	800067a0 <fslog_read_many+0x8e>
    8000679c:	60813983          	ld	s3,1544(sp)
}
    800067a0:	854a                	mv	a0,s2
    800067a2:	62813083          	ld	ra,1576(sp)
    800067a6:	62013403          	ld	s0,1568(sp)
    800067aa:	61813483          	ld	s1,1560(sp)
    800067ae:	61013903          	ld	s2,1552(sp)
    800067b2:	60013a03          	ld	s4,1536(sp)
    800067b6:	63010113          	addi	sp,sp,1584
    800067ba:	8082                	ret

00000000800067bc <memlog_init>:
static uint mem_count = 0;
static uint64 mem_seq = 0;

void
memlog_init(void)
{
    800067bc:	1141                	addi	sp,sp,-16
    800067be:	e406                	sd	ra,8(sp)
    800067c0:	e022                	sd	s0,0(sp)
    800067c2:	0800                	addi	s0,sp,16
  initlock(&mem_lock, "memlog");
    800067c4:	00002597          	auipc	a1,0x2
    800067c8:	fbc58593          	addi	a1,a1,-68 # 80008780 <etext+0x780>
    800067cc:	0002b517          	auipc	a0,0x2b
    800067d0:	6cc50513          	addi	a0,a0,1740 # 80031e98 <mem_lock>
    800067d4:	c68fa0ef          	jal	80000c3c <initlock>
  mem_head = 0;
    800067d8:	00002797          	auipc	a5,0x2
    800067dc:	1807a023          	sw	zero,384(a5) # 80008958 <mem_head>
  mem_tail = 0;
    800067e0:	00002797          	auipc	a5,0x2
    800067e4:	1607aa23          	sw	zero,372(a5) # 80008954 <mem_tail>
  mem_count = 0;
    800067e8:	00002797          	auipc	a5,0x2
    800067ec:	1607a423          	sw	zero,360(a5) # 80008950 <mem_count>
  mem_seq = 0;
    800067f0:	00002797          	auipc	a5,0x2
    800067f4:	1407bc23          	sd	zero,344(a5) # 80008948 <mem_seq>
}
    800067f8:	60a2                	ld	ra,8(sp)
    800067fa:	6402                	ld	s0,0(sp)
    800067fc:	0141                	addi	sp,sp,16
    800067fe:	8082                	ret

0000000080006800 <memlog_push>:

void
memlog_push(struct mem_event *e)
{
    80006800:	1101                	addi	sp,sp,-32
    80006802:	ec06                	sd	ra,24(sp)
    80006804:	e822                	sd	s0,16(sp)
    80006806:	e426                	sd	s1,8(sp)
    80006808:	1000                	addi	s0,sp,32
    8000680a:	84aa                	mv	s1,a0
  acquire(&mem_lock);
    8000680c:	0002b517          	auipc	a0,0x2b
    80006810:	68c50513          	addi	a0,a0,1676 # 80031e98 <mem_lock>
    80006814:	ca8fa0ef          	jal	80000cbc <acquire>

  e->seq = ++mem_seq;
    80006818:	00002717          	auipc	a4,0x2
    8000681c:	13070713          	addi	a4,a4,304 # 80008948 <mem_seq>
    80006820:	631c                	ld	a5,0(a4)
    80006822:	0785                	addi	a5,a5,1
    80006824:	e31c                	sd	a5,0(a4)
    80006826:	e09c                	sd	a5,0(s1)

  if(mem_count == MEM_RB_CAP){
    80006828:	00002717          	auipc	a4,0x2
    8000682c:	12872703          	lw	a4,296(a4) # 80008950 <mem_count>
    80006830:	20000793          	li	a5,512
    80006834:	08f70063          	beq	a4,a5,800068b4 <memlog_push+0xb4>
    mem_tail = (mem_tail + 1) % MEM_RB_CAP;
    mem_count--;
  }

  mem_buf[mem_head] = *e;
    80006838:	00002697          	auipc	a3,0x2
    8000683c:	1206a683          	lw	a3,288(a3) # 80008958 <mem_head>
    80006840:	02069613          	slli	a2,a3,0x20
    80006844:	9201                	srli	a2,a2,0x20
    80006846:	06800793          	li	a5,104
    8000684a:	02f60633          	mul	a2,a2,a5
    8000684e:	8726                	mv	a4,s1
    80006850:	0002b797          	auipc	a5,0x2b
    80006854:	66078793          	addi	a5,a5,1632 # 80031eb0 <mem_buf>
    80006858:	97b2                	add	a5,a5,a2
    8000685a:	06048493          	addi	s1,s1,96
    8000685e:	00073803          	ld	a6,0(a4)
    80006862:	6708                	ld	a0,8(a4)
    80006864:	6b0c                	ld	a1,16(a4)
    80006866:	6f10                	ld	a2,24(a4)
    80006868:	0107b023          	sd	a6,0(a5)
    8000686c:	e788                	sd	a0,8(a5)
    8000686e:	eb8c                	sd	a1,16(a5)
    80006870:	ef90                	sd	a2,24(a5)
    80006872:	02070713          	addi	a4,a4,32
    80006876:	02078793          	addi	a5,a5,32
    8000687a:	fe9712e3          	bne	a4,s1,8000685e <memlog_push+0x5e>
    8000687e:	6318                	ld	a4,0(a4)
    80006880:	e398                	sd	a4,0(a5)
  mem_head = (mem_head + 1) % MEM_RB_CAP;
    80006882:	2685                	addiw	a3,a3,1
    80006884:	1ff6f693          	andi	a3,a3,511
    80006888:	00002797          	auipc	a5,0x2
    8000688c:	0cd7a823          	sw	a3,208(a5) # 80008958 <mem_head>
  mem_count++;
    80006890:	00002717          	auipc	a4,0x2
    80006894:	0c070713          	addi	a4,a4,192 # 80008950 <mem_count>
    80006898:	431c                	lw	a5,0(a4)
    8000689a:	2785                	addiw	a5,a5,1
    8000689c:	c31c                	sw	a5,0(a4)

  release(&mem_lock);
    8000689e:	0002b517          	auipc	a0,0x2b
    800068a2:	5fa50513          	addi	a0,a0,1530 # 80031e98 <mem_lock>
    800068a6:	caefa0ef          	jal	80000d54 <release>
}
    800068aa:	60e2                	ld	ra,24(sp)
    800068ac:	6442                	ld	s0,16(sp)
    800068ae:	64a2                	ld	s1,8(sp)
    800068b0:	6105                	addi	sp,sp,32
    800068b2:	8082                	ret
    mem_tail = (mem_tail + 1) % MEM_RB_CAP;
    800068b4:	00002717          	auipc	a4,0x2
    800068b8:	0a070713          	addi	a4,a4,160 # 80008954 <mem_tail>
    800068bc:	431c                	lw	a5,0(a4)
    800068be:	2785                	addiw	a5,a5,1
    800068c0:	1ff7f793          	andi	a5,a5,511
    800068c4:	c31c                	sw	a5,0(a4)
    mem_count--;
    800068c6:	1ff00793          	li	a5,511
    800068ca:	00002717          	auipc	a4,0x2
    800068ce:	08f72323          	sw	a5,134(a4) # 80008950 <mem_count>
    800068d2:	b79d                	j	80006838 <memlog_push+0x38>

00000000800068d4 <memlog_read_many>:

int
memlog_read_many(struct mem_event *out, int max)
{
    800068d4:	1101                	addi	sp,sp,-32
    800068d6:	ec06                	sd	ra,24(sp)
    800068d8:	e822                	sd	s0,16(sp)
    800068da:	e426                	sd	s1,8(sp)
    800068dc:	1000                	addi	s0,sp,32
  int n = 0;

  if(max <= 0)
    return 0;
    800068de:	4481                	li	s1,0
  if(max <= 0)
    800068e0:	0ab05963          	blez	a1,80006992 <memlog_read_many+0xbe>
    800068e4:	e04a                	sd	s2,0(sp)
    800068e6:	84aa                	mv	s1,a0
    800068e8:	892e                	mv	s2,a1

  acquire(&mem_lock);
    800068ea:	0002b517          	auipc	a0,0x2b
    800068ee:	5ae50513          	addi	a0,a0,1454 # 80031e98 <mem_lock>
    800068f2:	bcafa0ef          	jal	80000cbc <acquire>
  while(n < max && mem_count > 0){
    800068f6:	00002697          	auipc	a3,0x2
    800068fa:	05e6a683          	lw	a3,94(a3) # 80008954 <mem_tail>
    800068fe:	00002617          	auipc	a2,0x2
    80006902:	05262603          	lw	a2,82(a2) # 80008950 <mem_count>
    80006906:	8526                	mv	a0,s1
  acquire(&mem_lock);
    80006908:	4701                	li	a4,0
  int n = 0;
    8000690a:	4481                	li	s1,0
    out[n] = mem_buf[mem_tail];
    8000690c:	0002bf97          	auipc	t6,0x2b
    80006910:	5a4f8f93          	addi	t6,t6,1444 # 80031eb0 <mem_buf>
    80006914:	06800f13          	li	t5,104
    80006918:	4e85                	li	t4,1
  while(n < max && mem_count > 0){
    8000691a:	c251                	beqz	a2,8000699e <memlog_read_many+0xca>
    out[n] = mem_buf[mem_tail];
    8000691c:	02069793          	slli	a5,a3,0x20
    80006920:	9381                	srli	a5,a5,0x20
    80006922:	03e787b3          	mul	a5,a5,t5
    80006926:	97fe                	add	a5,a5,t6
    80006928:	872a                	mv	a4,a0
    8000692a:	06078e13          	addi	t3,a5,96
    8000692e:	0007b303          	ld	t1,0(a5)
    80006932:	0087b883          	ld	a7,8(a5)
    80006936:	0107b803          	ld	a6,16(a5)
    8000693a:	6f8c                	ld	a1,24(a5)
    8000693c:	00673023          	sd	t1,0(a4)
    80006940:	01173423          	sd	a7,8(a4)
    80006944:	01073823          	sd	a6,16(a4)
    80006948:	ef0c                	sd	a1,24(a4)
    8000694a:	02078793          	addi	a5,a5,32
    8000694e:	02070713          	addi	a4,a4,32
    80006952:	fdc79ee3          	bne	a5,t3,8000692e <memlog_read_many+0x5a>
    80006956:	639c                	ld	a5,0(a5)
    80006958:	e31c                	sd	a5,0(a4)
    mem_tail = (mem_tail + 1) % MEM_RB_CAP;
    8000695a:	2685                	addiw	a3,a3,1
    8000695c:	1ff6f693          	andi	a3,a3,511
    mem_count--;
    80006960:	fff6079b          	addiw	a5,a2,-1
    80006964:	0007861b          	sext.w	a2,a5
    n++;
    80006968:	2485                	addiw	s1,s1,1
  while(n < max && mem_count > 0){
    8000696a:	06850513          	addi	a0,a0,104
    8000696e:	8776                	mv	a4,t4
    80006970:	fa9915e3          	bne	s2,s1,8000691a <memlog_read_many+0x46>
    80006974:	00002717          	auipc	a4,0x2
    80006978:	fed72023          	sw	a3,-32(a4) # 80008954 <mem_tail>
    8000697c:	00002717          	auipc	a4,0x2
    80006980:	fcf72a23          	sw	a5,-44(a4) # 80008950 <mem_count>
  }
  release(&mem_lock);
    80006984:	0002b517          	auipc	a0,0x2b
    80006988:	51450513          	addi	a0,a0,1300 # 80031e98 <mem_lock>
    8000698c:	bc8fa0ef          	jal	80000d54 <release>

  return n;
    80006990:	6902                	ld	s2,0(sp)
    80006992:	8526                	mv	a0,s1
    80006994:	60e2                	ld	ra,24(sp)
    80006996:	6442                	ld	s0,16(sp)
    80006998:	64a2                	ld	s1,8(sp)
    8000699a:	6105                	addi	sp,sp,32
    8000699c:	8082                	ret
    8000699e:	d37d                	beqz	a4,80006984 <memlog_read_many+0xb0>
    800069a0:	00002797          	auipc	a5,0x2
    800069a4:	fad7aa23          	sw	a3,-76(a5) # 80008954 <mem_tail>
    800069a8:	00002797          	auipc	a5,0x2
    800069ac:	fa07a423          	sw	zero,-88(a5) # 80008950 <mem_count>
    800069b0:	bfd1                	j	80006984 <memlog_read_many+0xb0>

00000000800069b2 <sys_memread>:
#include "memevent.h"
#include "memlog.h"

uint64
sys_memread(void)
{
    800069b2:	95010113          	addi	sp,sp,-1712
    800069b6:	6a113423          	sd	ra,1704(sp)
    800069ba:	6a813023          	sd	s0,1696(sp)
    800069be:	6b010413          	addi	s0,sp,1712
  uint64 uaddr = 0;
    800069c2:	fc043c23          	sd	zero,-40(s0)
  int max = 0;
    800069c6:	fc042a23          	sw	zero,-44(s0)

  argaddr(0, &uaddr);
    800069ca:	fd840593          	addi	a1,s0,-40
    800069ce:	4501                	li	a0,0
    800069d0:	cc2fc0ef          	jal	80002e92 <argaddr>
  argint(1, &max);
    800069d4:	fd440593          	addi	a1,s0,-44
    800069d8:	4505                	li	a0,1
    800069da:	c9cfc0ef          	jal	80002e76 <argint>

  if(max <= 0)
    800069de:	fd442783          	lw	a5,-44(s0)
    return 0;
    800069e2:	4501                	li	a0,0
  if(max <= 0)
    800069e4:	04f05363          	blez	a5,80006a2a <sys_memread+0x78>
    800069e8:	68913c23          	sd	s1,1688(sp)
  if(max > 16)
    800069ec:	4741                	li	a4,16
    800069ee:	00f75563          	bge	a4,a5,800069f8 <sys_memread+0x46>
    max = 16;
    800069f2:	47c1                	li	a5,16
    800069f4:	fcf42a23          	sw	a5,-44(s0)

  struct mem_event tmp[16];
  int n = memlog_read_many(tmp, max);
    800069f8:	fd442583          	lw	a1,-44(s0)
    800069fc:	95040513          	addi	a0,s0,-1712
    80006a00:	ed5ff0ef          	jal	800068d4 <memlog_read_many>
    80006a04:	84aa                	mv	s1,a0

  int bytes = n * (int)sizeof(struct mem_event);
  if(copyout(myproc()->pagetable, uaddr, (char *)tmp, bytes) < 0)
    80006a06:	a80fb0ef          	jal	80001c86 <myproc>
    80006a0a:	06800693          	li	a3,104
    80006a0e:	029686bb          	mulw	a3,a3,s1
    80006a12:	95040613          	addi	a2,s0,-1712
    80006a16:	fd843583          	ld	a1,-40(s0)
    80006a1a:	6928                	ld	a0,80(a0)
    80006a1c:	ef5fa0ef          	jal	80001910 <copyout>
    80006a20:	00054c63          	bltz	a0,80006a38 <sys_memread+0x86>
    return -1;

  return n;
    80006a24:	8526                	mv	a0,s1
    80006a26:	69813483          	ld	s1,1688(sp)
    80006a2a:	6a813083          	ld	ra,1704(sp)
    80006a2e:	6a013403          	ld	s0,1696(sp)
    80006a32:	6b010113          	addi	sp,sp,1712
    80006a36:	8082                	ret
    return -1;
    80006a38:	557d                	li	a0,-1
    80006a3a:	69813483          	ld	s1,1688(sp)
    80006a3e:	b7f5                	j	80006a2a <sys_memread+0x78>

0000000080006a40 <schedlog_init>:

static struct ringbuf sched_rb;

void
schedlog_init(void)
{
    80006a40:	1141                	addi	sp,sp,-16
    80006a42:	e406                	sd	ra,8(sp)
    80006a44:	e022                	sd	s0,0(sp)
    80006a46:	0800                	addi	s0,sp,16
  ringbuf_init(&sched_rb, "schedlog", sizeof(struct sched_event));
    80006a48:	04400613          	li	a2,68
    80006a4c:	00002597          	auipc	a1,0x2
    80006a50:	d3c58593          	addi	a1,a1,-708 # 80008788 <etext+0x788>
    80006a54:	00038517          	auipc	a0,0x38
    80006a58:	45c50513          	addi	a0,a0,1116 # 8003eeb0 <sched_rb>
    80006a5c:	a7dff0ef          	jal	800064d8 <ringbuf_init>
}
    80006a60:	60a2                	ld	ra,8(sp)
    80006a62:	6402                	ld	s0,0(sp)
    80006a64:	0141                	addi	sp,sp,16
    80006a66:	8082                	ret

0000000080006a68 <schedlog_emit>:

void
schedlog_emit(struct sched_event *e)
{
    80006a68:	711d                	addi	sp,sp,-96
    80006a6a:	ec86                	sd	ra,88(sp)
    80006a6c:	e8a2                	sd	s0,80(sp)
    80006a6e:	1080                	addi	s0,sp,96
    80006a70:	85aa                	mv	a1,a0
  struct sched_event copy;

  memmove(&copy, e, sizeof(copy));
    80006a72:	04400613          	li	a2,68
    80006a76:	fa840513          	addi	a0,s0,-88
    80006a7a:	b72fa0ef          	jal	80000dec <memmove>
  copy.seq = sched_rb.seq++;
    80006a7e:	00038517          	auipc	a0,0x38
    80006a82:	43250513          	addi	a0,a0,1074 # 8003eeb0 <sched_rb>
    80006a86:	751c                	ld	a5,40(a0)
    80006a88:	00178713          	addi	a4,a5,1
    80006a8c:	f518                	sd	a4,40(a0)
    80006a8e:	faf42423          	sw	a5,-88(s0)
  ringbuf_push(&sched_rb, &copy);
    80006a92:	fa840593          	addi	a1,s0,-88
    80006a96:	a77ff0ef          	jal	8000650c <ringbuf_push>
}
    80006a9a:	60e6                	ld	ra,88(sp)
    80006a9c:	6446                	ld	s0,80(sp)
    80006a9e:	6125                	addi	sp,sp,96
    80006aa0:	8082                	ret

0000000080006aa2 <schedread>:

int
schedread(struct sched_event *dst, int max)
{
    80006aa2:	1141                	addi	sp,sp,-16
    80006aa4:	e406                	sd	ra,8(sp)
    80006aa6:	e022                	sd	s0,0(sp)
    80006aa8:	0800                	addi	s0,sp,16
    80006aaa:	862e                	mv	a2,a1
  return ringbuf_read_many(&sched_rb, dst, max);
    80006aac:	85aa                	mv	a1,a0
    80006aae:	00038517          	auipc	a0,0x38
    80006ab2:	40250513          	addi	a0,a0,1026 # 8003eeb0 <sched_rb>
    80006ab6:	ac3ff0ef          	jal	80006578 <ringbuf_read_many>
    80006aba:	60a2                	ld	ra,8(sp)
    80006abc:	6402                	ld	s0,0(sp)
    80006abe:	0141                	addi	sp,sp,16
    80006ac0:	8082                	ret
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
