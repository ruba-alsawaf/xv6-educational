
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
    800000ee:	68c040ef          	jal	8000477a <acquiresleep>

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
    8000011e:	7d8020ef          	jal	800028f6 <either_copyin>
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
    8000016a:	656040ef          	jal	800047c0 <releasesleep>
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
    800001d4:	291010ef          	jal	80001c64 <myproc>
    800001d8:	5b0020ef          	jal	80002788 <killed>
    800001dc:	e12d                	bnez	a0,8000023e <consoleread+0xbe>
      sleep(&cons.r, &cons.lock);
    800001de:	85ce                	mv	a1,s3
    800001e0:	854a                	mv	a0,s2
    800001e2:	348020ef          	jal	8000252a <sleep>
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
    80000226:	686020ef          	jal	800028ac <either_copyout>
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
    800002f6:	64a020ef          	jal	80002940 <procdump>
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
    8000043c:	13e020ef          	jal	8000257a <wakeup>
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
    8000046e:	2d6040ef          	jal	80004744 <initsleeplock>

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
    8000091c:	40f010ef          	jal	8000252a <sleep>
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
    80000a32:	349010ef          	jal	8000257a <wakeup>
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
    80000ab6:	17c010ef          	jal	80001c32 <cpuid>
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
    80000ad2:	192010ef          	jal	80001c64 <myproc>
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
    80000af6:	49d050ef          	jal	80006792 <memlog_push>
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
    80000bde:	054010ef          	jal	80001c32 <cpuid>
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
    80000bfa:	06a010ef          	jal	80001c64 <myproc>
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
    80000c1e:	375050ef          	jal	80006792 <memlog_push>
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
    80000c66:	7dd000ef          	jal	80001c42 <mycpu>
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
    80000c94:	7af000ef          	jal	80001c42 <mycpu>
    80000c98:	5d3c                	lw	a5,120(a0)
    80000c9a:	cb99                	beqz	a5,80000cb0 <push_off+0x34>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000c9c:	7a7000ef          	jal	80001c42 <mycpu>
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
    80000cb0:	793000ef          	jal	80001c42 <mycpu>
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
    80000ce4:	75f000ef          	jal	80001c42 <mycpu>
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
    80000d08:	73b000ef          	jal	80001c42 <mycpu>
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
    80000f32:	501000ef          	jal	80001c32 <cpuid>
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
    80000f4a:	4e9000ef          	jal	80001c32 <cpuid>
    80000f4e:	85aa                	mv	a1,a0
    80000f50:	00007517          	auipc	a0,0x7
    80000f54:	15050513          	addi	a0,a0,336 # 800080a0 <etext+0xa0>
    80000f58:	dd4ff0ef          	jal	8000052c <printf>
    kvminithart();    // turn on paging
    80000f5c:	0a8000ef          	jal	80001004 <kvminithart>
    trapinithart();   // install kernel trap vector
    80000f60:	313010ef          	jal	80002a72 <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000f64:	5c5040ef          	jal	80005d28 <plicinithart>
  }

  cpus[cpuid()].active = 1;
    80000f68:	4cb000ef          	jal	80001c32 <cpuid>
    80000f6c:	0a800793          	li	a5,168
    80000f70:	02f50533          	mul	a0,a0,a5
    80000f74:	00010797          	auipc	a5,0x10
    80000f78:	ba478793          	addi	a5,a5,-1116 # 80010b18 <cpus>
    80000f7c:	97aa                	add	a5,a5,a0
    80000f7e:	4705                	li	a4,1
    80000f80:	08e7a023          	sw	a4,128(a5)
  scheduler();        
    80000f84:	1f4010ef          	jal	80002178 <scheduler>
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
    80000fc0:	391000ef          	jal	80001b50 <procinit>
    schedlog_init();
    80000fc4:	20f050ef          	jal	800069d2 <schedlog_init>
    trapinit();      // trap vectors
    80000fc8:	287010ef          	jal	80002a4e <trapinit>
    trapinithart();  // install kernel trap vector
    80000fcc:	2a7010ef          	jal	80002a72 <trapinithart>
    plicinit();      // set up interrupt controller
    80000fd0:	53f040ef          	jal	80005d0e <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000fd4:	555040ef          	jal	80005d28 <plicinithart>
    binit();         // buffer cache
    80000fd8:	3ac020ef          	jal	80003384 <binit>
    iinit();         // inode table
    80000fdc:	171020ef          	jal	8000394c <iinit>
    fileinit();      // file table
    80000fe0:	063030ef          	jal	80004842 <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000fe4:	635040ef          	jal	80005e18 <virtio_disk_init>
    cslog_init();
    80000fe8:	2e2050ef          	jal	800062ca <cslog_init>
    memlog_init();
    80000fec:	762050ef          	jal	8000674e <memlog_init>
    userinit();      // first user process
    80000ff0:	76b000ef          	jal	80001f5a <userinit>
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
    80001198:	29b000ef          	jal	80001c32 <cpuid>
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
    800011dc:	5b6050ef          	jal	80006792 <memlog_push>
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
    8000120c:	259000ef          	jal	80001c64 <myproc>
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
    80001302:	7b6000ef          	jal	80001ab8 <proc_mapstacks>
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
    800013e8:	07d000ef          	jal	80001c64 <myproc>
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
    80001406:	02d000ef          	jal	80001c32 <cpuid>
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
    8000144a:	348050ef          	jal	80006792 <memlog_push>
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
{
    800014ba:	7171                	addi	sp,sp,-176
    800014bc:	f506                	sd	ra,168(sp)
    800014be:	f122                	sd	s0,160(sp)
    800014c0:	ed26                	sd	s1,152(sp)
    800014c2:	1900                	addi	s0,sp,176
    800014c4:	84ae                	mv	s1,a1
  if(newsz < oldsz)
    800014c6:	00b67863          	bgeu	a2,a1,800014d6 <uvmalloc+0x1c>
}
    800014ca:	8526                	mv	a0,s1
    800014cc:	70aa                	ld	ra,168(sp)
    800014ce:	740a                	ld	s0,160(sp)
    800014d0:	64ea                	ld	s1,152(sp)
    800014d2:	614d                	addi	sp,sp,176
    800014d4:	8082                	ret
    800014d6:	e94a                	sd	s2,144(sp)
    800014d8:	e54e                	sd	s3,136(sp)
    800014da:	e152                	sd	s4,128(sp)
    800014dc:	fcd6                	sd	s5,120(sp)
    800014de:	f8da                	sd	s6,112(sp)
    800014e0:	8aaa                	mv	s5,a0
    800014e2:	89b2                	mv	s3,a2
    800014e4:	8a36                	mv	s4,a3
      struct proc *p = myproc();
    800014e6:	77e000ef          	jal	80001c64 <myproc>
    800014ea:	892a                	mv	s2,a0
  if(p){
    800014ec:	c12d                	beqz	a0,8000154e <uvmalloc+0x94>
    memset(&e, 0, sizeof(e));
    800014ee:	06800613          	li	a2,104
    800014f2:	4581                	li	a1,0
    800014f4:	f5840513          	addi	a0,s0,-168
    800014f8:	899ff0ef          	jal	80000d90 <memset>
    e.ticks  = ticks;
    800014fc:	00007797          	auipc	a5,0x7
    80001500:	4347a783          	lw	a5,1076(a5) # 80008930 <ticks>
    80001504:	f6f42023          	sw	a5,-160(s0)
    e.cpu    = cpuid();
    80001508:	72a000ef          	jal	80001c32 <cpuid>
    8000150c:	f6a42223          	sw	a0,-156(s0)
    e.type   = MEM_GROW;
    80001510:	4785                	li	a5,1
    80001512:	f6f42423          	sw	a5,-152(s0)
    e.pid    = p->pid;
    80001516:	03492703          	lw	a4,52(s2)
    8000151a:	f6e42623          	sw	a4,-148(s0)
    e.state  = p->state;
    8000151e:	01892703          	lw	a4,24(s2)
    80001522:	f6e42823          	sw	a4,-144(s0)
    e.oldsz  = oldsz;
    80001526:	f8943c23          	sd	s1,-104(s0)
    e.newsz  = newsz;
    8000152a:	fb343023          	sd	s3,-96(s0)
    e.source = SRC_UVMALLOC;
    8000152e:	4715                	li	a4,5
    80001530:	fae42a23          	sw	a4,-76(s0)
    e.kind   = PAGE_USER;
    80001534:	faf42c23          	sw	a5,-72(s0)
    safestrcpy(e.name, p->name, MEM_NM);
    80001538:	4641                	li	a2,16
    8000153a:	15890593          	addi	a1,s2,344
    8000153e:	f7440513          	addi	a0,s0,-140
    80001542:	98dff0ef          	jal	80000ece <safestrcpy>
    memlog_push(&e);
    80001546:	f5840513          	addi	a0,s0,-168
    8000154a:	248050ef          	jal	80006792 <memlog_push>
  oldsz = PGROUNDUP(oldsz);
    8000154e:	6b05                	lui	s6,0x1
    80001550:	1b7d                	addi	s6,s6,-1 # fff <_entry-0x7ffff001>
    80001552:	9b26                	add	s6,s6,s1
    80001554:	77fd                	lui	a5,0xfffff
    80001556:	00fb7b33          	and	s6,s6,a5
  for(a = oldsz; a < newsz; a += PGSIZE){
    8000155a:	073b7a63          	bgeu	s6,s3,800015ce <uvmalloc+0x114>
    8000155e:	895a                	mv	s2,s6
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    80001560:	012a6a13          	ori	s4,s4,18
    mem = kalloc();
    80001564:	e2aff0ef          	jal	80000b8e <kalloc>
    80001568:	84aa                	mv	s1,a0
    if(mem == 0){
    8000156a:	c905                	beqz	a0,8000159a <uvmalloc+0xe0>
    memset(mem, 0, PGSIZE);
    8000156c:	6605                	lui	a2,0x1
    8000156e:	4581                	li	a1,0
    80001570:	821ff0ef          	jal	80000d90 <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    80001574:	8752                	mv	a4,s4
    80001576:	86a6                	mv	a3,s1
    80001578:	6605                	lui	a2,0x1
    8000157a:	85ca                	mv	a1,s2
    8000157c:	8556                	mv	a0,s5
    8000157e:	b87ff0ef          	jal	80001104 <mappages>
    80001582:	e51d                	bnez	a0,800015b0 <uvmalloc+0xf6>
  for(a = oldsz; a < newsz; a += PGSIZE){
    80001584:	6785                	lui	a5,0x1
    80001586:	993e                	add	s2,s2,a5
    80001588:	fd396ee3          	bltu	s2,s3,80001564 <uvmalloc+0xaa>
  return newsz;
    8000158c:	84ce                	mv	s1,s3
    8000158e:	694a                	ld	s2,144(sp)
    80001590:	69aa                	ld	s3,136(sp)
    80001592:	6a0a                	ld	s4,128(sp)
    80001594:	7ae6                	ld	s5,120(sp)
    80001596:	7b46                	ld	s6,112(sp)
    80001598:	bf0d                	j	800014ca <uvmalloc+0x10>
      uvmdealloc(pagetable, a, oldsz);
    8000159a:	865a                	mv	a2,s6
    8000159c:	85ca                	mv	a1,s2
    8000159e:	8556                	mv	a0,s5
    800015a0:	ed7ff0ef          	jal	80001476 <uvmdealloc>
      return 0;
    800015a4:	694a                	ld	s2,144(sp)
    800015a6:	69aa                	ld	s3,136(sp)
    800015a8:	6a0a                	ld	s4,128(sp)
    800015aa:	7ae6                	ld	s5,120(sp)
    800015ac:	7b46                	ld	s6,112(sp)
    800015ae:	bf31                	j	800014ca <uvmalloc+0x10>
      kfree(mem);
    800015b0:	8526                	mv	a0,s1
    800015b2:	c9cff0ef          	jal	80000a4e <kfree>
      uvmdealloc(pagetable, a, oldsz);
    800015b6:	865a                	mv	a2,s6
    800015b8:	85ca                	mv	a1,s2
    800015ba:	8556                	mv	a0,s5
    800015bc:	ebbff0ef          	jal	80001476 <uvmdealloc>
      return 0;
    800015c0:	4481                	li	s1,0
    800015c2:	694a                	ld	s2,144(sp)
    800015c4:	69aa                	ld	s3,136(sp)
    800015c6:	6a0a                	ld	s4,128(sp)
    800015c8:	7ae6                	ld	s5,120(sp)
    800015ca:	7b46                	ld	s6,112(sp)
    800015cc:	bdfd                	j	800014ca <uvmalloc+0x10>
  return newsz;
    800015ce:	84ce                	mv	s1,s3
    800015d0:	694a                	ld	s2,144(sp)
    800015d2:	69aa                	ld	s3,136(sp)
    800015d4:	6a0a                	ld	s4,128(sp)
    800015d6:	7ae6                	ld	s5,120(sp)
    800015d8:	7b46                	ld	s6,112(sp)
    800015da:	bdc5                	j	800014ca <uvmalloc+0x10>

00000000800015dc <freewalk>:
// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    800015dc:	7179                	addi	sp,sp,-48
    800015de:	f406                	sd	ra,40(sp)
    800015e0:	f022                	sd	s0,32(sp)
    800015e2:	ec26                	sd	s1,24(sp)
    800015e4:	e84a                	sd	s2,16(sp)
    800015e6:	e44e                	sd	s3,8(sp)
    800015e8:	e052                	sd	s4,0(sp)
    800015ea:	1800                	addi	s0,sp,48
    800015ec:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    800015ee:	84aa                	mv	s1,a0
    800015f0:	6905                	lui	s2,0x1
    800015f2:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800015f4:	4985                	li	s3,1
    800015f6:	a819                	j	8000160c <freewalk+0x30>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    800015f8:	83a9                	srli	a5,a5,0xa
      freewalk((pagetable_t)child);
    800015fa:	00c79513          	slli	a0,a5,0xc
    800015fe:	fdfff0ef          	jal	800015dc <freewalk>
      pagetable[i] = 0;
    80001602:	0004b023          	sd	zero,0(s1)
  for(int i = 0; i < 512; i++){
    80001606:	04a1                	addi	s1,s1,8
    80001608:	01248f63          	beq	s1,s2,80001626 <freewalk+0x4a>
    pte_t pte = pagetable[i];
    8000160c:	609c                	ld	a5,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    8000160e:	00f7f713          	andi	a4,a5,15
    80001612:	ff3703e3          	beq	a4,s3,800015f8 <freewalk+0x1c>
    } else if(pte & PTE_V){
    80001616:	8b85                	andi	a5,a5,1
    80001618:	d7fd                	beqz	a5,80001606 <freewalk+0x2a>
      panic("freewalk: leaf");
    8000161a:	00007517          	auipc	a0,0x7
    8000161e:	b2650513          	addi	a0,a0,-1242 # 80008140 <etext+0x140>
    80001622:	9f0ff0ef          	jal	80000812 <panic>
    }
  }
  kfree((void*)pagetable);
    80001626:	8552                	mv	a0,s4
    80001628:	c26ff0ef          	jal	80000a4e <kfree>
}
    8000162c:	70a2                	ld	ra,40(sp)
    8000162e:	7402                	ld	s0,32(sp)
    80001630:	64e2                	ld	s1,24(sp)
    80001632:	6942                	ld	s2,16(sp)
    80001634:	69a2                	ld	s3,8(sp)
    80001636:	6a02                	ld	s4,0(sp)
    80001638:	6145                	addi	sp,sp,48
    8000163a:	8082                	ret

000000008000163c <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    8000163c:	1101                	addi	sp,sp,-32
    8000163e:	ec06                	sd	ra,24(sp)
    80001640:	e822                	sd	s0,16(sp)
    80001642:	e426                	sd	s1,8(sp)
    80001644:	1000                	addi	s0,sp,32
    80001646:	84aa                	mv	s1,a0
  if(sz > 0)
    80001648:	e989                	bnez	a1,8000165a <uvmfree+0x1e>
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
  freewalk(pagetable);
    8000164a:	8526                	mv	a0,s1
    8000164c:	f91ff0ef          	jal	800015dc <freewalk>
}
    80001650:	60e2                	ld	ra,24(sp)
    80001652:	6442                	ld	s0,16(sp)
    80001654:	64a2                	ld	s1,8(sp)
    80001656:	6105                	addi	sp,sp,32
    80001658:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
    8000165a:	6785                	lui	a5,0x1
    8000165c:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    8000165e:	95be                	add	a1,a1,a5
    80001660:	4685                	li	a3,1
    80001662:	00c5d613          	srli	a2,a1,0xc
    80001666:	4581                	li	a1,0
    80001668:	cefff0ef          	jal	80001356 <uvmunmap>
    8000166c:	bff9                	j	8000164a <uvmfree+0xe>

000000008000166e <uvmcopy>:
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for(i = 0; i < sz; i += PGSIZE){
    8000166e:	ce49                	beqz	a2,80001708 <uvmcopy+0x9a>
{
    80001670:	715d                	addi	sp,sp,-80
    80001672:	e486                	sd	ra,72(sp)
    80001674:	e0a2                	sd	s0,64(sp)
    80001676:	fc26                	sd	s1,56(sp)
    80001678:	f84a                	sd	s2,48(sp)
    8000167a:	f44e                	sd	s3,40(sp)
    8000167c:	f052                	sd	s4,32(sp)
    8000167e:	ec56                	sd	s5,24(sp)
    80001680:	e85a                	sd	s6,16(sp)
    80001682:	e45e                	sd	s7,8(sp)
    80001684:	0880                	addi	s0,sp,80
    80001686:	8aaa                	mv	s5,a0
    80001688:	8b2e                	mv	s6,a1
    8000168a:	8a32                	mv	s4,a2
  for(i = 0; i < sz; i += PGSIZE){
    8000168c:	4481                	li	s1,0
    8000168e:	a029                	j	80001698 <uvmcopy+0x2a>
    80001690:	6785                	lui	a5,0x1
    80001692:	94be                	add	s1,s1,a5
    80001694:	0544fe63          	bgeu	s1,s4,800016f0 <uvmcopy+0x82>
    if((pte = walk(old, i, 0)) == 0)
    80001698:	4601                	li	a2,0
    8000169a:	85a6                	mv	a1,s1
    8000169c:	8556                	mv	a0,s5
    8000169e:	98fff0ef          	jal	8000102c <walk>
    800016a2:	d57d                	beqz	a0,80001690 <uvmcopy+0x22>
      continue;   // page table entry hasn't been allocated
    if((*pte & PTE_V) == 0)
    800016a4:	6118                	ld	a4,0(a0)
    800016a6:	00177793          	andi	a5,a4,1
    800016aa:	d3fd                	beqz	a5,80001690 <uvmcopy+0x22>
      continue;   // physical page hasn't been allocated
    pa = PTE2PA(*pte);
    800016ac:	00a75593          	srli	a1,a4,0xa
    800016b0:	00c59b93          	slli	s7,a1,0xc
    flags = PTE_FLAGS(*pte);
    800016b4:	3ff77913          	andi	s2,a4,1023
    if((mem = kalloc()) == 0)
    800016b8:	cd6ff0ef          	jal	80000b8e <kalloc>
    800016bc:	89aa                	mv	s3,a0
    800016be:	c105                	beqz	a0,800016de <uvmcopy+0x70>
      goto err;
    memmove(mem, (char*)pa, PGSIZE);
    800016c0:	6605                	lui	a2,0x1
    800016c2:	85de                	mv	a1,s7
    800016c4:	f28ff0ef          	jal	80000dec <memmove>
    if(mappages(new, i, PGSIZE, (uint64)mem, flags) != 0){
    800016c8:	874a                	mv	a4,s2
    800016ca:	86ce                	mv	a3,s3
    800016cc:	6605                	lui	a2,0x1
    800016ce:	85a6                	mv	a1,s1
    800016d0:	855a                	mv	a0,s6
    800016d2:	a33ff0ef          	jal	80001104 <mappages>
    800016d6:	dd4d                	beqz	a0,80001690 <uvmcopy+0x22>
      kfree(mem);
    800016d8:	854e                	mv	a0,s3
    800016da:	b74ff0ef          	jal	80000a4e <kfree>
    }
  }
  return 0;

 err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    800016de:	4685                	li	a3,1
    800016e0:	00c4d613          	srli	a2,s1,0xc
    800016e4:	4581                	li	a1,0
    800016e6:	855a                	mv	a0,s6
    800016e8:	c6fff0ef          	jal	80001356 <uvmunmap>
  return -1;
    800016ec:	557d                	li	a0,-1
    800016ee:	a011                	j	800016f2 <uvmcopy+0x84>
  return 0;
    800016f0:	4501                	li	a0,0
}
    800016f2:	60a6                	ld	ra,72(sp)
    800016f4:	6406                	ld	s0,64(sp)
    800016f6:	74e2                	ld	s1,56(sp)
    800016f8:	7942                	ld	s2,48(sp)
    800016fa:	79a2                	ld	s3,40(sp)
    800016fc:	7a02                	ld	s4,32(sp)
    800016fe:	6ae2                	ld	s5,24(sp)
    80001700:	6b42                	ld	s6,16(sp)
    80001702:	6ba2                	ld	s7,8(sp)
    80001704:	6161                	addi	sp,sp,80
    80001706:	8082                	ret
  return 0;
    80001708:	4501                	li	a0,0
}
    8000170a:	8082                	ret

000000008000170c <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    8000170c:	1141                	addi	sp,sp,-16
    8000170e:	e406                	sd	ra,8(sp)
    80001710:	e022                	sd	s0,0(sp)
    80001712:	0800                	addi	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    80001714:	4601                	li	a2,0
    80001716:	917ff0ef          	jal	8000102c <walk>
  if(pte == 0)
    8000171a:	c901                	beqz	a0,8000172a <uvmclear+0x1e>
    panic("uvmclear");
  *pte &= ~PTE_U;
    8000171c:	611c                	ld	a5,0(a0)
    8000171e:	9bbd                	andi	a5,a5,-17
    80001720:	e11c                	sd	a5,0(a0)
}
    80001722:	60a2                	ld	ra,8(sp)
    80001724:	6402                	ld	s0,0(sp)
    80001726:	0141                	addi	sp,sp,16
    80001728:	8082                	ret
    panic("uvmclear");
    8000172a:	00007517          	auipc	a0,0x7
    8000172e:	a2650513          	addi	a0,a0,-1498 # 80008150 <etext+0x150>
    80001732:	8e0ff0ef          	jal	80000812 <panic>

0000000080001736 <copyinstr>:
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    80001736:	c6dd                	beqz	a3,800017e4 <copyinstr+0xae>
{
    80001738:	715d                	addi	sp,sp,-80
    8000173a:	e486                	sd	ra,72(sp)
    8000173c:	e0a2                	sd	s0,64(sp)
    8000173e:	fc26                	sd	s1,56(sp)
    80001740:	f84a                	sd	s2,48(sp)
    80001742:	f44e                	sd	s3,40(sp)
    80001744:	f052                	sd	s4,32(sp)
    80001746:	ec56                	sd	s5,24(sp)
    80001748:	e85a                	sd	s6,16(sp)
    8000174a:	e45e                	sd	s7,8(sp)
    8000174c:	0880                	addi	s0,sp,80
    8000174e:	8a2a                	mv	s4,a0
    80001750:	8b2e                	mv	s6,a1
    80001752:	8bb2                	mv	s7,a2
    80001754:	8936                	mv	s2,a3
    va0 = PGROUNDDOWN(srcva);
    80001756:	7afd                	lui	s5,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    80001758:	6985                	lui	s3,0x1
    8000175a:	a825                	j	80001792 <copyinstr+0x5c>
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
    8000175c:	00078023          	sb	zero,0(a5) # 1000 <_entry-0x7ffff000>
    80001760:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    80001762:	37fd                	addiw	a5,a5,-1
    80001764:	0007851b          	sext.w	a0,a5
    return 0;
  } else {
    return -1;
  }
}
    80001768:	60a6                	ld	ra,72(sp)
    8000176a:	6406                	ld	s0,64(sp)
    8000176c:	74e2                	ld	s1,56(sp)
    8000176e:	7942                	ld	s2,48(sp)
    80001770:	79a2                	ld	s3,40(sp)
    80001772:	7a02                	ld	s4,32(sp)
    80001774:	6ae2                	ld	s5,24(sp)
    80001776:	6b42                	ld	s6,16(sp)
    80001778:	6ba2                	ld	s7,8(sp)
    8000177a:	6161                	addi	sp,sp,80
    8000177c:	8082                	ret
    8000177e:	fff90713          	addi	a4,s2,-1 # fff <_entry-0x7ffff001>
    80001782:	9742                	add	a4,a4,a6
      --max;
    80001784:	40b70933          	sub	s2,a4,a1
    srcva = va0 + PGSIZE;
    80001788:	01348bb3          	add	s7,s1,s3
  while(got_null == 0 && max > 0){
    8000178c:	04e58463          	beq	a1,a4,800017d4 <copyinstr+0x9e>
{
    80001790:	8b3e                	mv	s6,a5
    va0 = PGROUNDDOWN(srcva);
    80001792:	015bf4b3          	and	s1,s7,s5
    pa0 = walkaddr(pagetable, va0);
    80001796:	85a6                	mv	a1,s1
    80001798:	8552                	mv	a0,s4
    8000179a:	92dff0ef          	jal	800010c6 <walkaddr>
    if(pa0 == 0)
    8000179e:	cd0d                	beqz	a0,800017d8 <copyinstr+0xa2>
    n = PGSIZE - (srcva - va0);
    800017a0:	417486b3          	sub	a3,s1,s7
    800017a4:	96ce                	add	a3,a3,s3
    if(n > max)
    800017a6:	00d97363          	bgeu	s2,a3,800017ac <copyinstr+0x76>
    800017aa:	86ca                	mv	a3,s2
    char *p = (char *) (pa0 + (srcva - va0));
    800017ac:	955e                	add	a0,a0,s7
    800017ae:	8d05                	sub	a0,a0,s1
    while(n > 0){
    800017b0:	c695                	beqz	a3,800017dc <copyinstr+0xa6>
    800017b2:	87da                	mv	a5,s6
    800017b4:	885a                	mv	a6,s6
      if(*p == '\0'){
    800017b6:	41650633          	sub	a2,a0,s6
    while(n > 0){
    800017ba:	96da                	add	a3,a3,s6
    800017bc:	85be                	mv	a1,a5
      if(*p == '\0'){
    800017be:	00f60733          	add	a4,a2,a5
    800017c2:	00074703          	lbu	a4,0(a4)
    800017c6:	db59                	beqz	a4,8000175c <copyinstr+0x26>
        *dst = *p;
    800017c8:	00e78023          	sb	a4,0(a5)
      dst++;
    800017cc:	0785                	addi	a5,a5,1
    while(n > 0){
    800017ce:	fed797e3          	bne	a5,a3,800017bc <copyinstr+0x86>
    800017d2:	b775                	j	8000177e <copyinstr+0x48>
    800017d4:	4781                	li	a5,0
    800017d6:	b771                	j	80001762 <copyinstr+0x2c>
      return -1;
    800017d8:	557d                	li	a0,-1
    800017da:	b779                	j	80001768 <copyinstr+0x32>
    srcva = va0 + PGSIZE;
    800017dc:	6b85                	lui	s7,0x1
    800017de:	9ba6                	add	s7,s7,s1
    800017e0:	87da                	mv	a5,s6
    800017e2:	b77d                	j	80001790 <copyinstr+0x5a>
  int got_null = 0;
    800017e4:	4781                	li	a5,0
  if(got_null){
    800017e6:	37fd                	addiw	a5,a5,-1
    800017e8:	0007851b          	sext.w	a0,a5
}
    800017ec:	8082                	ret

00000000800017ee <ismapped>:
  }
  return mem;
}
int
ismapped(pagetable_t pagetable, uint64 va)
{
    800017ee:	1141                	addi	sp,sp,-16
    800017f0:	e406                	sd	ra,8(sp)
    800017f2:	e022                	sd	s0,0(sp)
    800017f4:	0800                	addi	s0,sp,16
  pte_t *pte = walk(pagetable, va, 0);
    800017f6:	4601                	li	a2,0
    800017f8:	835ff0ef          	jal	8000102c <walk>
  if (pte == 0) {
    800017fc:	c519                	beqz	a0,8000180a <ismapped+0x1c>
    return 0;
  }
  if (*pte & PTE_V){
    800017fe:	6108                	ld	a0,0(a0)
    80001800:	8905                	andi	a0,a0,1
    return 1;
  }
  return 0;
}
    80001802:	60a2                	ld	ra,8(sp)
    80001804:	6402                	ld	s0,0(sp)
    80001806:	0141                	addi	sp,sp,16
    80001808:	8082                	ret
    return 0;
    8000180a:	4501                	li	a0,0
    8000180c:	bfdd                	j	80001802 <ismapped+0x14>

000000008000180e <vmfault>:
{
    8000180e:	7135                	addi	sp,sp,-160
    80001810:	ed06                	sd	ra,152(sp)
    80001812:	e922                	sd	s0,144(sp)
    80001814:	e526                	sd	s1,136(sp)
    80001816:	fcce                	sd	s3,120(sp)
    80001818:	1100                	addi	s0,sp,160
    8000181a:	89aa                	mv	s3,a0
    8000181c:	84ae                	mv	s1,a1
  struct proc *p = myproc();
    8000181e:	446000ef          	jal	80001c64 <myproc>
  if (va >= p->sz)
    80001822:	653c                	ld	a5,72(a0)
    80001824:	00f4ea63          	bltu	s1,a5,80001838 <vmfault+0x2a>
    return 0;
    80001828:	4981                	li	s3,0
}
    8000182a:	854e                	mv	a0,s3
    8000182c:	60ea                	ld	ra,152(sp)
    8000182e:	644a                	ld	s0,144(sp)
    80001830:	64aa                	ld	s1,136(sp)
    80001832:	79e6                	ld	s3,120(sp)
    80001834:	610d                	addi	sp,sp,160
    80001836:	8082                	ret
    80001838:	e14a                	sd	s2,128(sp)
    8000183a:	892a                	mv	s2,a0
  va = PGROUNDDOWN(va);
    8000183c:	77fd                	lui	a5,0xfffff
    8000183e:	8cfd                	and	s1,s1,a5
  if(ismapped(pagetable, va)) {
    80001840:	85a6                	mv	a1,s1
    80001842:	854e                	mv	a0,s3
    80001844:	fabff0ef          	jal	800017ee <ismapped>
    return 0;
    80001848:	4981                	li	s3,0
  if(ismapped(pagetable, va)) {
    8000184a:	c119                	beqz	a0,80001850 <vmfault+0x42>
    8000184c:	690a                	ld	s2,128(sp)
    8000184e:	bff1                	j	8000182a <vmfault+0x1c>
    80001850:	f8d2                	sd	s4,112(sp)
  memset(&e, 0, sizeof(e));
    80001852:	06800613          	li	a2,104
    80001856:	4581                	li	a1,0
    80001858:	f6840513          	addi	a0,s0,-152
    8000185c:	d34ff0ef          	jal	80000d90 <memset>
  e.ticks  = ticks;
    80001860:	00007797          	auipc	a5,0x7
    80001864:	0d07a783          	lw	a5,208(a5) # 80008930 <ticks>
    80001868:	f6f42823          	sw	a5,-144(s0)
  e.cpu    = cpuid();
    8000186c:	3c6000ef          	jal	80001c32 <cpuid>
    80001870:	f6a42a23          	sw	a0,-140(s0)
  e.type   = MEM_FAULT;
    80001874:	478d                	li	a5,3
    80001876:	f6f42c23          	sw	a5,-136(s0)
  e.pid    = p->pid;
    8000187a:	03492783          	lw	a5,52(s2)
    8000187e:	f6f42e23          	sw	a5,-132(s0)
  e.state  = p->state;
    80001882:	01892783          	lw	a5,24(s2)
    80001886:	f8f42023          	sw	a5,-128(s0)
  e.va     = va;
    8000188a:	f8943c23          	sd	s1,-104(s0)
  e.source = SRC_VMFAULT;
    8000188e:	479d                	li	a5,7
    80001890:	fcf42223          	sw	a5,-60(s0)
  e.kind   = PAGE_USER;
    80001894:	4785                	li	a5,1
    80001896:	fcf42423          	sw	a5,-56(s0)
  safestrcpy(e.name, p->name, MEM_NM);
    8000189a:	4641                	li	a2,16
    8000189c:	15890593          	addi	a1,s2,344
    800018a0:	f8440513          	addi	a0,s0,-124
    800018a4:	e2aff0ef          	jal	80000ece <safestrcpy>
  memlog_push(&e);
    800018a8:	f6840513          	addi	a0,s0,-152
    800018ac:	6e7040ef          	jal	80006792 <memlog_push>
  mem = (uint64) kalloc();
    800018b0:	adeff0ef          	jal	80000b8e <kalloc>
    800018b4:	8a2a                	mv	s4,a0
  if(mem == 0)
    800018b6:	c90d                	beqz	a0,800018e8 <vmfault+0xda>
  mem = (uint64) kalloc();
    800018b8:	89aa                	mv	s3,a0
  memset((void *) mem, 0, PGSIZE);
    800018ba:	6605                	lui	a2,0x1
    800018bc:	4581                	li	a1,0
    800018be:	cd2ff0ef          	jal	80000d90 <memset>
  if (mappages(p->pagetable, va, PGSIZE, mem, PTE_W|PTE_U|PTE_R) != 0) {
    800018c2:	4759                	li	a4,22
    800018c4:	86d2                	mv	a3,s4
    800018c6:	6605                	lui	a2,0x1
    800018c8:	85a6                	mv	a1,s1
    800018ca:	05093503          	ld	a0,80(s2)
    800018ce:	837ff0ef          	jal	80001104 <mappages>
    800018d2:	e501                	bnez	a0,800018da <vmfault+0xcc>
    800018d4:	690a                	ld	s2,128(sp)
    800018d6:	7a46                	ld	s4,112(sp)
    800018d8:	bf89                	j	8000182a <vmfault+0x1c>
    kfree((void *)mem);
    800018da:	8552                	mv	a0,s4
    800018dc:	972ff0ef          	jal	80000a4e <kfree>
    return 0;
    800018e0:	4981                	li	s3,0
    800018e2:	690a                	ld	s2,128(sp)
    800018e4:	7a46                	ld	s4,112(sp)
    800018e6:	b791                	j	8000182a <vmfault+0x1c>
    800018e8:	690a                	ld	s2,128(sp)
    800018ea:	7a46                	ld	s4,112(sp)
    800018ec:	bf3d                	j	8000182a <vmfault+0x1c>

00000000800018ee <copyout>:
  while(len > 0){
    800018ee:	c2cd                	beqz	a3,80001990 <copyout+0xa2>
{
    800018f0:	711d                	addi	sp,sp,-96
    800018f2:	ec86                	sd	ra,88(sp)
    800018f4:	e8a2                	sd	s0,80(sp)
    800018f6:	e4a6                	sd	s1,72(sp)
    800018f8:	f852                	sd	s4,48(sp)
    800018fa:	f05a                	sd	s6,32(sp)
    800018fc:	ec5e                	sd	s7,24(sp)
    800018fe:	e862                	sd	s8,16(sp)
    80001900:	1080                	addi	s0,sp,96
    80001902:	8c2a                	mv	s8,a0
    80001904:	8b2e                	mv	s6,a1
    80001906:	8bb2                	mv	s7,a2
    80001908:	8a36                	mv	s4,a3
    va0 = PGROUNDDOWN(dstva);
    8000190a:	74fd                	lui	s1,0xfffff
    8000190c:	8ced                	and	s1,s1,a1
    if(va0 >= MAXVA)
    8000190e:	57fd                	li	a5,-1
    80001910:	83e9                	srli	a5,a5,0x1a
    80001912:	0897e163          	bltu	a5,s1,80001994 <copyout+0xa6>
    80001916:	e0ca                	sd	s2,64(sp)
    80001918:	fc4e                	sd	s3,56(sp)
    8000191a:	f456                	sd	s5,40(sp)
    8000191c:	e466                	sd	s9,8(sp)
    8000191e:	e06a                	sd	s10,0(sp)
    80001920:	6d05                	lui	s10,0x1
    80001922:	8cbe                	mv	s9,a5
    80001924:	a015                	j	80001948 <copyout+0x5a>
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    80001926:	409b0533          	sub	a0,s6,s1
    8000192a:	0009861b          	sext.w	a2,s3
    8000192e:	85de                	mv	a1,s7
    80001930:	954a                	add	a0,a0,s2
    80001932:	cbaff0ef          	jal	80000dec <memmove>
    len -= n;
    80001936:	413a0a33          	sub	s4,s4,s3
    src += n;
    8000193a:	9bce                	add	s7,s7,s3
  while(len > 0){
    8000193c:	040a0363          	beqz	s4,80001982 <copyout+0x94>
    if(va0 >= MAXVA)
    80001940:	055cec63          	bltu	s9,s5,80001998 <copyout+0xaa>
    80001944:	84d6                	mv	s1,s5
    80001946:	8b56                	mv	s6,s5
    pa0 = walkaddr(pagetable, va0);
    80001948:	85a6                	mv	a1,s1
    8000194a:	8562                	mv	a0,s8
    8000194c:	f7aff0ef          	jal	800010c6 <walkaddr>
    80001950:	892a                	mv	s2,a0
    if(pa0 == 0) {
    80001952:	e901                	bnez	a0,80001962 <copyout+0x74>
      if((pa0 = vmfault(pagetable, va0, 0)) == 0) {
    80001954:	4601                	li	a2,0
    80001956:	85a6                	mv	a1,s1
    80001958:	8562                	mv	a0,s8
    8000195a:	eb5ff0ef          	jal	8000180e <vmfault>
    8000195e:	892a                	mv	s2,a0
    80001960:	c139                	beqz	a0,800019a6 <copyout+0xb8>
    pte = walk(pagetable, va0, 0);
    80001962:	4601                	li	a2,0
    80001964:	85a6                	mv	a1,s1
    80001966:	8562                	mv	a0,s8
    80001968:	ec4ff0ef          	jal	8000102c <walk>
    if((*pte & PTE_W) == 0)
    8000196c:	611c                	ld	a5,0(a0)
    8000196e:	8b91                	andi	a5,a5,4
    80001970:	c3b1                	beqz	a5,800019b4 <copyout+0xc6>
    n = PGSIZE - (dstva - va0);
    80001972:	01a48ab3          	add	s5,s1,s10
    80001976:	416a89b3          	sub	s3,s5,s6
    if(n > len)
    8000197a:	fb3a76e3          	bgeu	s4,s3,80001926 <copyout+0x38>
    8000197e:	89d2                	mv	s3,s4
    80001980:	b75d                	j	80001926 <copyout+0x38>
  return 0;
    80001982:	4501                	li	a0,0
    80001984:	6906                	ld	s2,64(sp)
    80001986:	79e2                	ld	s3,56(sp)
    80001988:	7aa2                	ld	s5,40(sp)
    8000198a:	6ca2                	ld	s9,8(sp)
    8000198c:	6d02                	ld	s10,0(sp)
    8000198e:	a80d                	j	800019c0 <copyout+0xd2>
    80001990:	4501                	li	a0,0
}
    80001992:	8082                	ret
      return -1;
    80001994:	557d                	li	a0,-1
    80001996:	a02d                	j	800019c0 <copyout+0xd2>
    80001998:	557d                	li	a0,-1
    8000199a:	6906                	ld	s2,64(sp)
    8000199c:	79e2                	ld	s3,56(sp)
    8000199e:	7aa2                	ld	s5,40(sp)
    800019a0:	6ca2                	ld	s9,8(sp)
    800019a2:	6d02                	ld	s10,0(sp)
    800019a4:	a831                	j	800019c0 <copyout+0xd2>
        return -1;
    800019a6:	557d                	li	a0,-1
    800019a8:	6906                	ld	s2,64(sp)
    800019aa:	79e2                	ld	s3,56(sp)
    800019ac:	7aa2                	ld	s5,40(sp)
    800019ae:	6ca2                	ld	s9,8(sp)
    800019b0:	6d02                	ld	s10,0(sp)
    800019b2:	a039                	j	800019c0 <copyout+0xd2>
      return -1;
    800019b4:	557d                	li	a0,-1
    800019b6:	6906                	ld	s2,64(sp)
    800019b8:	79e2                	ld	s3,56(sp)
    800019ba:	7aa2                	ld	s5,40(sp)
    800019bc:	6ca2                	ld	s9,8(sp)
    800019be:	6d02                	ld	s10,0(sp)
}
    800019c0:	60e6                	ld	ra,88(sp)
    800019c2:	6446                	ld	s0,80(sp)
    800019c4:	64a6                	ld	s1,72(sp)
    800019c6:	7a42                	ld	s4,48(sp)
    800019c8:	7b02                	ld	s6,32(sp)
    800019ca:	6be2                	ld	s7,24(sp)
    800019cc:	6c42                	ld	s8,16(sp)
    800019ce:	6125                	addi	sp,sp,96
    800019d0:	8082                	ret

00000000800019d2 <copyin>:
  while(len > 0){
    800019d2:	c6c9                	beqz	a3,80001a5c <copyin+0x8a>
{
    800019d4:	715d                	addi	sp,sp,-80
    800019d6:	e486                	sd	ra,72(sp)
    800019d8:	e0a2                	sd	s0,64(sp)
    800019da:	fc26                	sd	s1,56(sp)
    800019dc:	f84a                	sd	s2,48(sp)
    800019de:	f44e                	sd	s3,40(sp)
    800019e0:	f052                	sd	s4,32(sp)
    800019e2:	ec56                	sd	s5,24(sp)
    800019e4:	e85a                	sd	s6,16(sp)
    800019e6:	e45e                	sd	s7,8(sp)
    800019e8:	e062                	sd	s8,0(sp)
    800019ea:	0880                	addi	s0,sp,80
    800019ec:	8baa                	mv	s7,a0
    800019ee:	8aae                	mv	s5,a1
    800019f0:	8932                	mv	s2,a2
    800019f2:	8a36                	mv	s4,a3
    va0 = PGROUNDDOWN(srcva);
    800019f4:	7c7d                	lui	s8,0xfffff
    n = PGSIZE - (srcva - va0);
    800019f6:	6b05                	lui	s6,0x1
    800019f8:	a035                	j	80001a24 <copyin+0x52>
    800019fa:	412984b3          	sub	s1,s3,s2
    800019fe:	94da                	add	s1,s1,s6
    if(n > len)
    80001a00:	009a7363          	bgeu	s4,s1,80001a06 <copyin+0x34>
    80001a04:	84d2                	mv	s1,s4
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    80001a06:	413905b3          	sub	a1,s2,s3
    80001a0a:	0004861b          	sext.w	a2,s1
    80001a0e:	95aa                	add	a1,a1,a0
    80001a10:	8556                	mv	a0,s5
    80001a12:	bdaff0ef          	jal	80000dec <memmove>
    len -= n;
    80001a16:	409a0a33          	sub	s4,s4,s1
    dst += n;
    80001a1a:	9aa6                	add	s5,s5,s1
    srcva = va0 + PGSIZE;
    80001a1c:	01698933          	add	s2,s3,s6
  while(len > 0){
    80001a20:	020a0163          	beqz	s4,80001a42 <copyin+0x70>
    va0 = PGROUNDDOWN(srcva);
    80001a24:	018979b3          	and	s3,s2,s8
    pa0 = walkaddr(pagetable, va0);
    80001a28:	85ce                	mv	a1,s3
    80001a2a:	855e                	mv	a0,s7
    80001a2c:	e9aff0ef          	jal	800010c6 <walkaddr>
    if(pa0 == 0) {
    80001a30:	f569                	bnez	a0,800019fa <copyin+0x28>
      if((pa0 = vmfault(pagetable, va0, 0)) == 0) {
    80001a32:	4601                	li	a2,0
    80001a34:	85ce                	mv	a1,s3
    80001a36:	855e                	mv	a0,s7
    80001a38:	dd7ff0ef          	jal	8000180e <vmfault>
    80001a3c:	fd5d                	bnez	a0,800019fa <copyin+0x28>
        return -1;
    80001a3e:	557d                	li	a0,-1
    80001a40:	a011                	j	80001a44 <copyin+0x72>
  return 0;
    80001a42:	4501                	li	a0,0
}
    80001a44:	60a6                	ld	ra,72(sp)
    80001a46:	6406                	ld	s0,64(sp)
    80001a48:	74e2                	ld	s1,56(sp)
    80001a4a:	7942                	ld	s2,48(sp)
    80001a4c:	79a2                	ld	s3,40(sp)
    80001a4e:	7a02                	ld	s4,32(sp)
    80001a50:	6ae2                	ld	s5,24(sp)
    80001a52:	6b42                	ld	s6,16(sp)
    80001a54:	6ba2                	ld	s7,8(sp)
    80001a56:	6c02                	ld	s8,0(sp)
    80001a58:	6161                	addi	sp,sp,80
    80001a5a:	8082                	ret
  return 0;
    80001a5c:	4501                	li	a0,0
}
    80001a5e:	8082                	ret

0000000080001a60 <setprocstate>:
uint64 proc_total_created;
uint64 proc_total_exited;

static void
setprocstate(struct proc *p, enum procstate state)
{
    80001a60:	1101                	addi	sp,sp,-32
    80001a62:	ec06                	sd	ra,24(sp)
    80001a64:	e822                	sd	s0,16(sp)
    80001a66:	e426                	sd	s1,8(sp)
    80001a68:	1000                	addi	s0,sp,32
    80001a6a:	84ae                	mv	s1,a1
  int first = 0;
  if (!(p->state_history & (1u << state))) {
    80001a6c:	5554                	lw	a3,44(a0)
    80001a6e:	4785                	li	a5,1
    80001a70:	00b797bb          	sllw	a5,a5,a1
    80001a74:	00f6f733          	and	a4,a3,a5
    80001a78:	2701                	sext.w	a4,a4
    80001a7a:	c719                	beqz	a4,80001a88 <setprocstate+0x28>
    p->state_history |= 1u << state;
    first = 1;
  }
  p->state = state;
    80001a7c:	cd0c                	sw	a1,24(a0)
  if (first) {
    acquire(&procstat_lock);
    proc_state_unique[state]++;
    release(&procstat_lock);
  }
}
    80001a7e:	60e2                	ld	ra,24(sp)
    80001a80:	6442                	ld	s0,16(sp)
    80001a82:	64a2                	ld	s1,8(sp)
    80001a84:	6105                	addi	sp,sp,32
    80001a86:	8082                	ret
    80001a88:	e04a                	sd	s2,0(sp)
    p->state_history |= 1u << state;
    80001a8a:	8edd                	or	a3,a3,a5
    80001a8c:	d554                	sw	a3,44(a0)
  p->state = state;
    80001a8e:	cd0c                	sw	a1,24(a0)
    acquire(&procstat_lock);
    80001a90:	0000f917          	auipc	s2,0xf
    80001a94:	ff890913          	addi	s2,s2,-8 # 80010a88 <procstat_lock>
    80001a98:	854a                	mv	a0,s2
    80001a9a:	a22ff0ef          	jal	80000cbc <acquire>
    proc_state_unique[state]++;
    80001a9e:	02049793          	slli	a5,s1,0x20
    80001aa2:	01d7d493          	srli	s1,a5,0x1d
    80001aa6:	94ca                	add	s1,s1,s2
    80001aa8:	6c9c                	ld	a5,24(s1)
    80001aaa:	0785                	addi	a5,a5,1
    80001aac:	ec9c                	sd	a5,24(s1)
    release(&procstat_lock);
    80001aae:	854a                	mv	a0,s2
    80001ab0:	aa4ff0ef          	jal	80000d54 <release>
    80001ab4:	6902                	ld	s2,0(sp)
}
    80001ab6:	b7e1                	j	80001a7e <setprocstate+0x1e>

0000000080001ab8 <proc_mapstacks>:
struct spinlock wait_lock;

// Allocate a page for each process's kernel stack.
// Map it high in memory, followed by an invalid
// guard page.
void proc_mapstacks(pagetable_t kpgtbl) {
    80001ab8:	7139                	addi	sp,sp,-64
    80001aba:	fc06                	sd	ra,56(sp)
    80001abc:	f822                	sd	s0,48(sp)
    80001abe:	f426                	sd	s1,40(sp)
    80001ac0:	f04a                	sd	s2,32(sp)
    80001ac2:	ec4e                	sd	s3,24(sp)
    80001ac4:	e852                	sd	s4,16(sp)
    80001ac6:	e456                	sd	s5,8(sp)
    80001ac8:	e05a                	sd	s6,0(sp)
    80001aca:	0080                	addi	s0,sp,64
    80001acc:	8a2a                	mv	s4,a0
  struct proc *p;

  for (p = proc; p < &proc[NPROC]; p++) {
    80001ace:	0000f497          	auipc	s1,0xf
    80001ad2:	58a48493          	addi	s1,s1,1418 # 80011058 <proc>
    char *pa = kalloc();
    if (pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int)(p - proc));
    80001ad6:	8b26                	mv	s6,s1
    80001ad8:	04fa5937          	lui	s2,0x4fa5
    80001adc:	fa590913          	addi	s2,s2,-91 # 4fa4fa5 <_entry-0x7b05b05b>
    80001ae0:	0932                	slli	s2,s2,0xc
    80001ae2:	fa590913          	addi	s2,s2,-91
    80001ae6:	0932                	slli	s2,s2,0xc
    80001ae8:	fa590913          	addi	s2,s2,-91
    80001aec:	0932                	slli	s2,s2,0xc
    80001aee:	fa590913          	addi	s2,s2,-91
    80001af2:	040009b7          	lui	s3,0x4000
    80001af6:	19fd                	addi	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    80001af8:	09b2                	slli	s3,s3,0xc
  for (p = proc; p < &proc[NPROC]; p++) {
    80001afa:	00015a97          	auipc	s5,0x15
    80001afe:	f5ea8a93          	addi	s5,s5,-162 # 80016a58 <tickslock>
    char *pa = kalloc();
    80001b02:	88cff0ef          	jal	80000b8e <kalloc>
    80001b06:	862a                	mv	a2,a0
    if (pa == 0)
    80001b08:	cd15                	beqz	a0,80001b44 <proc_mapstacks+0x8c>
    uint64 va = KSTACK((int)(p - proc));
    80001b0a:	416485b3          	sub	a1,s1,s6
    80001b0e:	858d                	srai	a1,a1,0x3
    80001b10:	032585b3          	mul	a1,a1,s2
    80001b14:	2585                	addiw	a1,a1,1
    80001b16:	00d5959b          	slliw	a1,a1,0xd
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    80001b1a:	4719                	li	a4,6
    80001b1c:	6685                	lui	a3,0x1
    80001b1e:	40b985b3          	sub	a1,s3,a1
    80001b22:	8552                	mv	a0,s4
    80001b24:	f16ff0ef          	jal	8000123a <kvmmap>
  for (p = proc; p < &proc[NPROC]; p++) {
    80001b28:	16848493          	addi	s1,s1,360
    80001b2c:	fd549be3          	bne	s1,s5,80001b02 <proc_mapstacks+0x4a>
  }
}
    80001b30:	70e2                	ld	ra,56(sp)
    80001b32:	7442                	ld	s0,48(sp)
    80001b34:	74a2                	ld	s1,40(sp)
    80001b36:	7902                	ld	s2,32(sp)
    80001b38:	69e2                	ld	s3,24(sp)
    80001b3a:	6a42                	ld	s4,16(sp)
    80001b3c:	6aa2                	ld	s5,8(sp)
    80001b3e:	6b02                	ld	s6,0(sp)
    80001b40:	6121                	addi	sp,sp,64
    80001b42:	8082                	ret
      panic("kalloc");
    80001b44:	00006517          	auipc	a0,0x6
    80001b48:	61c50513          	addi	a0,a0,1564 # 80008160 <etext+0x160>
    80001b4c:	cc7fe0ef          	jal	80000812 <panic>

0000000080001b50 <procinit>:

// initialize the proc table.
void procinit(void) {
    80001b50:	7139                	addi	sp,sp,-64
    80001b52:	fc06                	sd	ra,56(sp)
    80001b54:	f822                	sd	s0,48(sp)
    80001b56:	f426                	sd	s1,40(sp)
    80001b58:	f04a                	sd	s2,32(sp)
    80001b5a:	ec4e                	sd	s3,24(sp)
    80001b5c:	e852                	sd	s4,16(sp)
    80001b5e:	e456                	sd	s5,8(sp)
    80001b60:	e05a                	sd	s6,0(sp)
    80001b62:	0080                	addi	s0,sp,64
  struct proc *p;

  initlock(&pid_lock, "nextpid");
    80001b64:	00006597          	auipc	a1,0x6
    80001b68:	60458593          	addi	a1,a1,1540 # 80008168 <etext+0x168>
    80001b6c:	0000f517          	auipc	a0,0xf
    80001b70:	f6450513          	addi	a0,a0,-156 # 80010ad0 <pid_lock>
    80001b74:	8c8ff0ef          	jal	80000c3c <initlock>
  initlock(&wait_lock, "wait_lock");
    80001b78:	00006597          	auipc	a1,0x6
    80001b7c:	5f858593          	addi	a1,a1,1528 # 80008170 <etext+0x170>
    80001b80:	0000f517          	auipc	a0,0xf
    80001b84:	f6850513          	addi	a0,a0,-152 # 80010ae8 <wait_lock>
    80001b88:	8b4ff0ef          	jal	80000c3c <initlock>
  initlock(&schedinfo_lock, "schedinfo");
    80001b8c:	00006597          	auipc	a1,0x6
    80001b90:	5f458593          	addi	a1,a1,1524 # 80008180 <etext+0x180>
    80001b94:	0000f517          	auipc	a0,0xf
    80001b98:	f6c50513          	addi	a0,a0,-148 # 80010b00 <schedinfo_lock>
    80001b9c:	8a0ff0ef          	jal	80000c3c <initlock>
  initlock(&procstat_lock, "procstats");
    80001ba0:	00006597          	auipc	a1,0x6
    80001ba4:	5f058593          	addi	a1,a1,1520 # 80008190 <etext+0x190>
    80001ba8:	0000f517          	auipc	a0,0xf
    80001bac:	ee050513          	addi	a0,a0,-288 # 80010a88 <procstat_lock>
    80001bb0:	88cff0ef          	jal	80000c3c <initlock>
  for (p = proc; p < &proc[NPROC]; p++) {
    80001bb4:	0000f497          	auipc	s1,0xf
    80001bb8:	4a448493          	addi	s1,s1,1188 # 80011058 <proc>
    initlock(&p->lock, "proc");
    80001bbc:	00006b17          	auipc	s6,0x6
    80001bc0:	5e4b0b13          	addi	s6,s6,1508 # 800081a0 <etext+0x1a0>
    p->state = UNUSED;
    p->state_history = 0;
    p->kstack = KSTACK((int)(p - proc));
    80001bc4:	8aa6                	mv	s5,s1
    80001bc6:	04fa5937          	lui	s2,0x4fa5
    80001bca:	fa590913          	addi	s2,s2,-91 # 4fa4fa5 <_entry-0x7b05b05b>
    80001bce:	0932                	slli	s2,s2,0xc
    80001bd0:	fa590913          	addi	s2,s2,-91
    80001bd4:	0932                	slli	s2,s2,0xc
    80001bd6:	fa590913          	addi	s2,s2,-91
    80001bda:	0932                	slli	s2,s2,0xc
    80001bdc:	fa590913          	addi	s2,s2,-91
    80001be0:	040009b7          	lui	s3,0x4000
    80001be4:	19fd                	addi	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    80001be6:	09b2                	slli	s3,s3,0xc
  for (p = proc; p < &proc[NPROC]; p++) {
    80001be8:	00015a17          	auipc	s4,0x15
    80001bec:	e70a0a13          	addi	s4,s4,-400 # 80016a58 <tickslock>
    initlock(&p->lock, "proc");
    80001bf0:	85da                	mv	a1,s6
    80001bf2:	8526                	mv	a0,s1
    80001bf4:	848ff0ef          	jal	80000c3c <initlock>
    p->state = UNUSED;
    80001bf8:	0004ac23          	sw	zero,24(s1)
    p->state_history = 0;
    80001bfc:	0204a623          	sw	zero,44(s1)
    p->kstack = KSTACK((int)(p - proc));
    80001c00:	415487b3          	sub	a5,s1,s5
    80001c04:	878d                	srai	a5,a5,0x3
    80001c06:	032787b3          	mul	a5,a5,s2
    80001c0a:	2785                	addiw	a5,a5,1
    80001c0c:	00d7979b          	slliw	a5,a5,0xd
    80001c10:	40f987b3          	sub	a5,s3,a5
    80001c14:	e0bc                	sd	a5,64(s1)
  for (p = proc; p < &proc[NPROC]; p++) {
    80001c16:	16848493          	addi	s1,s1,360
    80001c1a:	fd449be3          	bne	s1,s4,80001bf0 <procinit+0xa0>
  }
}
    80001c1e:	70e2                	ld	ra,56(sp)
    80001c20:	7442                	ld	s0,48(sp)
    80001c22:	74a2                	ld	s1,40(sp)
    80001c24:	7902                	ld	s2,32(sp)
    80001c26:	69e2                	ld	s3,24(sp)
    80001c28:	6a42                	ld	s4,16(sp)
    80001c2a:	6aa2                	ld	s5,8(sp)
    80001c2c:	6b02                	ld	s6,0(sp)
    80001c2e:	6121                	addi	sp,sp,64
    80001c30:	8082                	ret

0000000080001c32 <cpuid>:

// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int cpuid() {
    80001c32:	1141                	addi	sp,sp,-16
    80001c34:	e422                	sd	s0,8(sp)
    80001c36:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    80001c38:	8512                	mv	a0,tp
  int id = r_tp();
  return id;
}
    80001c3a:	2501                	sext.w	a0,a0
    80001c3c:	6422                	ld	s0,8(sp)
    80001c3e:	0141                	addi	sp,sp,16
    80001c40:	8082                	ret

0000000080001c42 <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu *mycpu(void) {
    80001c42:	1141                	addi	sp,sp,-16
    80001c44:	e422                	sd	s0,8(sp)
    80001c46:	0800                	addi	s0,sp,16
    80001c48:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    80001c4a:	2781                	sext.w	a5,a5
    80001c4c:	0a800713          	li	a4,168
    80001c50:	02e787b3          	mul	a5,a5,a4
  return c;
}
    80001c54:	0000f517          	auipc	a0,0xf
    80001c58:	ec450513          	addi	a0,a0,-316 # 80010b18 <cpus>
    80001c5c:	953e                	add	a0,a0,a5
    80001c5e:	6422                	ld	s0,8(sp)
    80001c60:	0141                	addi	sp,sp,16
    80001c62:	8082                	ret

0000000080001c64 <myproc>:

// Return the current struct proc *, or zero if none.
struct proc *myproc(void) {
    80001c64:	1101                	addi	sp,sp,-32
    80001c66:	ec06                	sd	ra,24(sp)
    80001c68:	e822                	sd	s0,16(sp)
    80001c6a:	e426                	sd	s1,8(sp)
    80001c6c:	1000                	addi	s0,sp,32
  push_off();
    80001c6e:	80eff0ef          	jal	80000c7c <push_off>
    80001c72:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    80001c74:	2781                	sext.w	a5,a5
    80001c76:	0a800713          	li	a4,168
    80001c7a:	02e787b3          	mul	a5,a5,a4
    80001c7e:	0000f717          	auipc	a4,0xf
    80001c82:	e0a70713          	addi	a4,a4,-502 # 80010a88 <procstat_lock>
    80001c86:	97ba                	add	a5,a5,a4
    80001c88:	6bc4                	ld	s1,144(a5)
  pop_off();
    80001c8a:	876ff0ef          	jal	80000d00 <pop_off>
  return p;
}
    80001c8e:	8526                	mv	a0,s1
    80001c90:	60e2                	ld	ra,24(sp)
    80001c92:	6442                	ld	s0,16(sp)
    80001c94:	64a2                	ld	s1,8(sp)
    80001c96:	6105                	addi	sp,sp,32
    80001c98:	8082                	ret

0000000080001c9a <forkret>:
  release(&p->lock);
}

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void forkret(void) {
    80001c9a:	7179                	addi	sp,sp,-48
    80001c9c:	f406                	sd	ra,40(sp)
    80001c9e:	f022                	sd	s0,32(sp)
    80001ca0:	ec26                	sd	s1,24(sp)
    80001ca2:	1800                	addi	s0,sp,48
  extern char userret[];
  static int first = 1;
  struct proc *p = myproc();
    80001ca4:	fc1ff0ef          	jal	80001c64 <myproc>
    80001ca8:	84aa                	mv	s1,a0

  // Still holding p->lock from scheduler.
  release(&p->lock);
    80001caa:	8aaff0ef          	jal	80000d54 <release>

  if (first) {
    80001cae:	00007797          	auipc	a5,0x7
    80001cb2:	c327a783          	lw	a5,-974(a5) # 800088e0 <first.1>
    80001cb6:	cf8d                	beqz	a5,80001cf0 <forkret+0x56>
    // File system initialization must be run in the context of a
    // regular process (e.g., because it calls sleep), and thus cannot
    // be run from main().
    fsinit(ROOTDEV);
    80001cb8:	4505                	li	a0,1
    80001cba:	14e020ef          	jal	80003e08 <fsinit>

    first = 0;
    80001cbe:	00007797          	auipc	a5,0x7
    80001cc2:	c207a123          	sw	zero,-990(a5) # 800088e0 <first.1>
    // ensure other cores see first=0.
    __sync_synchronize();
    80001cc6:	0ff0000f          	fence

    // We can invoke kexec() now that file system is initialized.
    // Put the return value (argc) of kexec into a0.
    p->trapframe->a0 = kexec("/init", (char *[]){"/init", 0});
    80001cca:	00006517          	auipc	a0,0x6
    80001cce:	4de50513          	addi	a0,a0,1246 # 800081a8 <etext+0x1a8>
    80001cd2:	fca43823          	sd	a0,-48(s0)
    80001cd6:	fc043c23          	sd	zero,-40(s0)
    80001cda:	fd040593          	addi	a1,s0,-48
    80001cde:	234030ef          	jal	80004f12 <kexec>
    80001ce2:	6cbc                	ld	a5,88(s1)
    80001ce4:	fba8                	sd	a0,112(a5)
    if (p->trapframe->a0 == -1) {
    80001ce6:	6cbc                	ld	a5,88(s1)
    80001ce8:	7bb8                	ld	a4,112(a5)
    80001cea:	57fd                	li	a5,-1
    80001cec:	02f70d63          	beq	a4,a5,80001d26 <forkret+0x8c>
      panic("exec");
    }
  }

  // return to user space, mimicing usertrap()'s return.
  prepare_return();
    80001cf0:	59b000ef          	jal	80002a8a <prepare_return>
  uint64 satp = MAKE_SATP(p->pagetable);
    80001cf4:	68a8                	ld	a0,80(s1)
    80001cf6:	8131                	srli	a0,a0,0xc
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    80001cf8:	04000737          	lui	a4,0x4000
    80001cfc:	177d                	addi	a4,a4,-1 # 3ffffff <_entry-0x7c000001>
    80001cfe:	0732                	slli	a4,a4,0xc
    80001d00:	00005797          	auipc	a5,0x5
    80001d04:	39c78793          	addi	a5,a5,924 # 8000709c <userret>
    80001d08:	00005697          	auipc	a3,0x5
    80001d0c:	2f868693          	addi	a3,a3,760 # 80007000 <_trampoline>
    80001d10:	8f95                	sub	a5,a5,a3
    80001d12:	97ba                	add	a5,a5,a4
  ((void (*)(uint64))trampoline_userret)(satp);
    80001d14:	577d                	li	a4,-1
    80001d16:	177e                	slli	a4,a4,0x3f
    80001d18:	8d59                	or	a0,a0,a4
    80001d1a:	9782                	jalr	a5
}
    80001d1c:	70a2                	ld	ra,40(sp)
    80001d1e:	7402                	ld	s0,32(sp)
    80001d20:	64e2                	ld	s1,24(sp)
    80001d22:	6145                	addi	sp,sp,48
    80001d24:	8082                	ret
      panic("exec");
    80001d26:	00006517          	auipc	a0,0x6
    80001d2a:	48a50513          	addi	a0,a0,1162 # 800081b0 <etext+0x1b0>
    80001d2e:	ae5fe0ef          	jal	80000812 <panic>

0000000080001d32 <allocpid>:
int allocpid() {
    80001d32:	1101                	addi	sp,sp,-32
    80001d34:	ec06                	sd	ra,24(sp)
    80001d36:	e822                	sd	s0,16(sp)
    80001d38:	e426                	sd	s1,8(sp)
    80001d3a:	e04a                	sd	s2,0(sp)
    80001d3c:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80001d3e:	0000f917          	auipc	s2,0xf
    80001d42:	d9290913          	addi	s2,s2,-622 # 80010ad0 <pid_lock>
    80001d46:	854a                	mv	a0,s2
    80001d48:	f75fe0ef          	jal	80000cbc <acquire>
  pid = nextpid;
    80001d4c:	00007797          	auipc	a5,0x7
    80001d50:	b9878793          	addi	a5,a5,-1128 # 800088e4 <nextpid>
    80001d54:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80001d56:	0014871b          	addiw	a4,s1,1
    80001d5a:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001d5c:	854a                	mv	a0,s2
    80001d5e:	ff7fe0ef          	jal	80000d54 <release>
}
    80001d62:	8526                	mv	a0,s1
    80001d64:	60e2                	ld	ra,24(sp)
    80001d66:	6442                	ld	s0,16(sp)
    80001d68:	64a2                	ld	s1,8(sp)
    80001d6a:	6902                	ld	s2,0(sp)
    80001d6c:	6105                	addi	sp,sp,32
    80001d6e:	8082                	ret

0000000080001d70 <proc_pagetable>:
pagetable_t proc_pagetable(struct proc *p) {
    80001d70:	1101                	addi	sp,sp,-32
    80001d72:	ec06                	sd	ra,24(sp)
    80001d74:	e822                	sd	s0,16(sp)
    80001d76:	e426                	sd	s1,8(sp)
    80001d78:	e04a                	sd	s2,0(sp)
    80001d7a:	1000                	addi	s0,sp,32
    80001d7c:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001d7e:	db2ff0ef          	jal	80001330 <uvmcreate>
    80001d82:	84aa                	mv	s1,a0
  if (pagetable == 0)
    80001d84:	cd05                	beqz	a0,80001dbc <proc_pagetable+0x4c>
  if (mappages(pagetable, TRAMPOLINE, PGSIZE, (uint64)trampoline,
    80001d86:	4729                	li	a4,10
    80001d88:	00005697          	auipc	a3,0x5
    80001d8c:	27868693          	addi	a3,a3,632 # 80007000 <_trampoline>
    80001d90:	6605                	lui	a2,0x1
    80001d92:	040005b7          	lui	a1,0x4000
    80001d96:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001d98:	05b2                	slli	a1,a1,0xc
    80001d9a:	b6aff0ef          	jal	80001104 <mappages>
    80001d9e:	02054663          	bltz	a0,80001dca <proc_pagetable+0x5a>
  if (mappages(pagetable, TRAPFRAME, PGSIZE, (uint64)(p->trapframe),
    80001da2:	4719                	li	a4,6
    80001da4:	05893683          	ld	a3,88(s2)
    80001da8:	6605                	lui	a2,0x1
    80001daa:	020005b7          	lui	a1,0x2000
    80001dae:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001db0:	05b6                	slli	a1,a1,0xd
    80001db2:	8526                	mv	a0,s1
    80001db4:	b50ff0ef          	jal	80001104 <mappages>
    80001db8:	00054f63          	bltz	a0,80001dd6 <proc_pagetable+0x66>
}
    80001dbc:	8526                	mv	a0,s1
    80001dbe:	60e2                	ld	ra,24(sp)
    80001dc0:	6442                	ld	s0,16(sp)
    80001dc2:	64a2                	ld	s1,8(sp)
    80001dc4:	6902                	ld	s2,0(sp)
    80001dc6:	6105                	addi	sp,sp,32
    80001dc8:	8082                	ret
    uvmfree(pagetable, 0);
    80001dca:	4581                	li	a1,0
    80001dcc:	8526                	mv	a0,s1
    80001dce:	86fff0ef          	jal	8000163c <uvmfree>
    return 0;
    80001dd2:	4481                	li	s1,0
    80001dd4:	b7e5                	j	80001dbc <proc_pagetable+0x4c>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001dd6:	4681                	li	a3,0
    80001dd8:	4605                	li	a2,1
    80001dda:	040005b7          	lui	a1,0x4000
    80001dde:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001de0:	05b2                	slli	a1,a1,0xc
    80001de2:	8526                	mv	a0,s1
    80001de4:	d72ff0ef          	jal	80001356 <uvmunmap>
    uvmfree(pagetable, 0);
    80001de8:	4581                	li	a1,0
    80001dea:	8526                	mv	a0,s1
    80001dec:	851ff0ef          	jal	8000163c <uvmfree>
    return 0;
    80001df0:	4481                	li	s1,0
    80001df2:	b7e9                	j	80001dbc <proc_pagetable+0x4c>

0000000080001df4 <proc_freepagetable>:
void proc_freepagetable(pagetable_t pagetable, uint64 sz) {
    80001df4:	1101                	addi	sp,sp,-32
    80001df6:	ec06                	sd	ra,24(sp)
    80001df8:	e822                	sd	s0,16(sp)
    80001dfa:	e426                	sd	s1,8(sp)
    80001dfc:	e04a                	sd	s2,0(sp)
    80001dfe:	1000                	addi	s0,sp,32
    80001e00:	84aa                	mv	s1,a0
    80001e02:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001e04:	4681                	li	a3,0
    80001e06:	4605                	li	a2,1
    80001e08:	040005b7          	lui	a1,0x4000
    80001e0c:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001e0e:	05b2                	slli	a1,a1,0xc
    80001e10:	d46ff0ef          	jal	80001356 <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001e14:	4681                	li	a3,0
    80001e16:	4605                	li	a2,1
    80001e18:	020005b7          	lui	a1,0x2000
    80001e1c:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001e1e:	05b6                	slli	a1,a1,0xd
    80001e20:	8526                	mv	a0,s1
    80001e22:	d34ff0ef          	jal	80001356 <uvmunmap>
  uvmfree(pagetable, sz);
    80001e26:	85ca                	mv	a1,s2
    80001e28:	8526                	mv	a0,s1
    80001e2a:	813ff0ef          	jal	8000163c <uvmfree>
}
    80001e2e:	60e2                	ld	ra,24(sp)
    80001e30:	6442                	ld	s0,16(sp)
    80001e32:	64a2                	ld	s1,8(sp)
    80001e34:	6902                	ld	s2,0(sp)
    80001e36:	6105                	addi	sp,sp,32
    80001e38:	8082                	ret

0000000080001e3a <freeproc>:
static void freeproc(struct proc *p) {
    80001e3a:	1101                	addi	sp,sp,-32
    80001e3c:	ec06                	sd	ra,24(sp)
    80001e3e:	e822                	sd	s0,16(sp)
    80001e40:	e426                	sd	s1,8(sp)
    80001e42:	1000                	addi	s0,sp,32
    80001e44:	84aa                	mv	s1,a0
  if (p->trapframe)
    80001e46:	6d28                	ld	a0,88(a0)
    80001e48:	c119                	beqz	a0,80001e4e <freeproc+0x14>
    kfree((void *)p->trapframe);
    80001e4a:	c05fe0ef          	jal	80000a4e <kfree>
  p->trapframe = 0;
    80001e4e:	0404bc23          	sd	zero,88(s1)
  if (p->pagetable)
    80001e52:	68a8                	ld	a0,80(s1)
    80001e54:	c501                	beqz	a0,80001e5c <freeproc+0x22>
    proc_freepagetable(p->pagetable, p->sz);
    80001e56:	64ac                	ld	a1,72(s1)
    80001e58:	f9dff0ef          	jal	80001df4 <proc_freepagetable>
  p->pagetable = 0;
    80001e5c:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    80001e60:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    80001e64:	0204aa23          	sw	zero,52(s1)
  p->parent = 0;
    80001e68:	0204bc23          	sd	zero,56(s1)
  p->name[0] = 0;
    80001e6c:	14048c23          	sb	zero,344(s1)
  p->chan = 0;
    80001e70:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    80001e74:	0204a423          	sw	zero,40(s1)
  p->xstate = 0;
    80001e78:	0204a823          	sw	zero,48(s1)
  p->state_history = 0;
    80001e7c:	0204a623          	sw	zero,44(s1)
  p->state = UNUSED;
    80001e80:	0004ac23          	sw	zero,24(s1)
}
    80001e84:	60e2                	ld	ra,24(sp)
    80001e86:	6442                	ld	s0,16(sp)
    80001e88:	64a2                	ld	s1,8(sp)
    80001e8a:	6105                	addi	sp,sp,32
    80001e8c:	8082                	ret

0000000080001e8e <allocproc>:
static struct proc *allocproc(void) {
    80001e8e:	1101                	addi	sp,sp,-32
    80001e90:	ec06                	sd	ra,24(sp)
    80001e92:	e822                	sd	s0,16(sp)
    80001e94:	e426                	sd	s1,8(sp)
    80001e96:	e04a                	sd	s2,0(sp)
    80001e98:	1000                	addi	s0,sp,32
  for (p = proc; p < &proc[NPROC]; p++) {
    80001e9a:	0000f497          	auipc	s1,0xf
    80001e9e:	1be48493          	addi	s1,s1,446 # 80011058 <proc>
    80001ea2:	00015917          	auipc	s2,0x15
    80001ea6:	bb690913          	addi	s2,s2,-1098 # 80016a58 <tickslock>
    acquire(&p->lock);
    80001eaa:	8526                	mv	a0,s1
    80001eac:	e11fe0ef          	jal	80000cbc <acquire>
    if (p->state == UNUSED) {
    80001eb0:	4c9c                	lw	a5,24(s1)
    80001eb2:	cb91                	beqz	a5,80001ec6 <allocproc+0x38>
      release(&p->lock);
    80001eb4:	8526                	mv	a0,s1
    80001eb6:	e9ffe0ef          	jal	80000d54 <release>
  for (p = proc; p < &proc[NPROC]; p++) {
    80001eba:	16848493          	addi	s1,s1,360
    80001ebe:	ff2496e3          	bne	s1,s2,80001eaa <allocproc+0x1c>
  return 0;
    80001ec2:	4481                	li	s1,0
    80001ec4:	a0a5                	j	80001f2c <allocproc+0x9e>
  p->pid = allocpid();
    80001ec6:	e6dff0ef          	jal	80001d32 <allocpid>
    80001eca:	d8c8                	sw	a0,52(s1)
  setprocstate(p, USED);
    80001ecc:	4585                	li	a1,1
    80001ece:	8526                	mv	a0,s1
    80001ed0:	b91ff0ef          	jal	80001a60 <setprocstate>
  if ((p->trapframe = (struct trapframe *)kalloc()) == 0) {
    80001ed4:	cbbfe0ef          	jal	80000b8e <kalloc>
    80001ed8:	892a                	mv	s2,a0
    80001eda:	eca8                	sd	a0,88(s1)
    80001edc:	cd39                	beqz	a0,80001f3a <allocproc+0xac>
  p->pagetable = proc_pagetable(p);
    80001ede:	8526                	mv	a0,s1
    80001ee0:	e91ff0ef          	jal	80001d70 <proc_pagetable>
    80001ee4:	892a                	mv	s2,a0
    80001ee6:	e8a8                	sd	a0,80(s1)
  if (p->pagetable == 0) {
    80001ee8:	c12d                	beqz	a0,80001f4a <allocproc+0xbc>
  memset(&p->context, 0, sizeof(p->context));
    80001eea:	07000613          	li	a2,112
    80001eee:	4581                	li	a1,0
    80001ef0:	06048513          	addi	a0,s1,96
    80001ef4:	e9dfe0ef          	jal	80000d90 <memset>
  p->context.ra = (uint64)forkret;
    80001ef8:	00000797          	auipc	a5,0x0
    80001efc:	da278793          	addi	a5,a5,-606 # 80001c9a <forkret>
    80001f00:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001f02:	60bc                	ld	a5,64(s1)
    80001f04:	6705                	lui	a4,0x1
    80001f06:	97ba                	add	a5,a5,a4
    80001f08:	f4bc                	sd	a5,104(s1)
  acquire(&procstat_lock);
    80001f0a:	0000f917          	auipc	s2,0xf
    80001f0e:	b7e90913          	addi	s2,s2,-1154 # 80010a88 <procstat_lock>
    80001f12:	854a                	mv	a0,s2
    80001f14:	da9fe0ef          	jal	80000cbc <acquire>
  proc_total_created++;
    80001f18:	00007717          	auipc	a4,0x7
    80001f1c:	a0070713          	addi	a4,a4,-1536 # 80008918 <proc_total_created>
    80001f20:	631c                	ld	a5,0(a4)
    80001f22:	0785                	addi	a5,a5,1
    80001f24:	e31c                	sd	a5,0(a4)
  release(&procstat_lock);
    80001f26:	854a                	mv	a0,s2
    80001f28:	e2dfe0ef          	jal	80000d54 <release>
}
    80001f2c:	8526                	mv	a0,s1
    80001f2e:	60e2                	ld	ra,24(sp)
    80001f30:	6442                	ld	s0,16(sp)
    80001f32:	64a2                	ld	s1,8(sp)
    80001f34:	6902                	ld	s2,0(sp)
    80001f36:	6105                	addi	sp,sp,32
    80001f38:	8082                	ret
    freeproc(p);
    80001f3a:	8526                	mv	a0,s1
    80001f3c:	effff0ef          	jal	80001e3a <freeproc>
    release(&p->lock);
    80001f40:	8526                	mv	a0,s1
    80001f42:	e13fe0ef          	jal	80000d54 <release>
    return 0;
    80001f46:	84ca                	mv	s1,s2
    80001f48:	b7d5                	j	80001f2c <allocproc+0x9e>
    freeproc(p);
    80001f4a:	8526                	mv	a0,s1
    80001f4c:	eefff0ef          	jal	80001e3a <freeproc>
    release(&p->lock);
    80001f50:	8526                	mv	a0,s1
    80001f52:	e03fe0ef          	jal	80000d54 <release>
    return 0;
    80001f56:	84ca                	mv	s1,s2
    80001f58:	bfd1                	j	80001f2c <allocproc+0x9e>

0000000080001f5a <userinit>:
void userinit(void) {
    80001f5a:	1101                	addi	sp,sp,-32
    80001f5c:	ec06                	sd	ra,24(sp)
    80001f5e:	e822                	sd	s0,16(sp)
    80001f60:	e426                	sd	s1,8(sp)
    80001f62:	1000                	addi	s0,sp,32
  p = allocproc();
    80001f64:	f2bff0ef          	jal	80001e8e <allocproc>
    80001f68:	84aa                	mv	s1,a0
  initproc = p;
    80001f6a:	00007797          	auipc	a5,0x7
    80001f6e:	9aa7bf23          	sd	a0,-1602(a5) # 80008928 <initproc>
  p->cwd = namei("/");
    80001f72:	00006517          	auipc	a0,0x6
    80001f76:	24650513          	addi	a0,a0,582 # 800081b8 <etext+0x1b8>
    80001f7a:	3b0020ef          	jal	8000432a <namei>
    80001f7e:	14a4b823          	sd	a0,336(s1)
  setprocstate(p, RUNNABLE);
    80001f82:	458d                	li	a1,3
    80001f84:	8526                	mv	a0,s1
    80001f86:	adbff0ef          	jal	80001a60 <setprocstate>
  release(&p->lock);
    80001f8a:	8526                	mv	a0,s1
    80001f8c:	dc9fe0ef          	jal	80000d54 <release>
}
    80001f90:	60e2                	ld	ra,24(sp)
    80001f92:	6442                	ld	s0,16(sp)
    80001f94:	64a2                	ld	s1,8(sp)
    80001f96:	6105                	addi	sp,sp,32
    80001f98:	8082                	ret

0000000080001f9a <growproc>:
int growproc(int n) {
    80001f9a:	7135                	addi	sp,sp,-160
    80001f9c:	ed06                	sd	ra,152(sp)
    80001f9e:	e922                	sd	s0,144(sp)
    80001fa0:	e526                	sd	s1,136(sp)
    80001fa2:	e14a                	sd	s2,128(sp)
    80001fa4:	fcce                	sd	s3,120(sp)
    80001fa6:	1100                	addi	s0,sp,160
    80001fa8:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80001faa:	cbbff0ef          	jal	80001c64 <myproc>
    80001fae:	89aa                	mv	s3,a0
  sz = p->sz;
    80001fb0:	04853903          	ld	s2,72(a0)
  if (n > 0) {
    80001fb4:	02905b63          	blez	s1,80001fea <growproc+0x50>
    if (sz + n > TRAPFRAME) {
    80001fb8:	01248633          	add	a2,s1,s2
    80001fbc:	020007b7          	lui	a5,0x2000
    80001fc0:	17fd                	addi	a5,a5,-1 # 1ffffff <_entry-0x7e000001>
    80001fc2:	07b6                	slli	a5,a5,0xd
    80001fc4:	08c7ee63          	bltu	a5,a2,80002060 <growproc+0xc6>
    if ((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0) {
    80001fc8:	4691                	li	a3,4
    80001fca:	85ca                	mv	a1,s2
    80001fcc:	6928                	ld	a0,80(a0)
    80001fce:	cecff0ef          	jal	800014ba <uvmalloc>
    80001fd2:	892a                	mv	s2,a0
    80001fd4:	c941                	beqz	a0,80002064 <growproc+0xca>
  p->sz = sz;
    80001fd6:	0529b423          	sd	s2,72(s3)
  return 0;
    80001fda:	4501                	li	a0,0
}
    80001fdc:	60ea                	ld	ra,152(sp)
    80001fde:	644a                	ld	s0,144(sp)
    80001fe0:	64aa                	ld	s1,136(sp)
    80001fe2:	690a                	ld	s2,128(sp)
    80001fe4:	79e6                	ld	s3,120(sp)
    80001fe6:	610d                	addi	sp,sp,160
    80001fe8:	8082                	ret
  } else if (n < 0) {
    80001fea:	fe04d6e3          	bgez	s1,80001fd6 <growproc+0x3c>
  memset(&e, 0, sizeof(e));
    80001fee:	06800613          	li	a2,104
    80001ff2:	4581                	li	a1,0
    80001ff4:	f6840513          	addi	a0,s0,-152
    80001ff8:	d99fe0ef          	jal	80000d90 <memset>
  e.ticks  = ticks;
    80001ffc:	00007797          	auipc	a5,0x7
    80002000:	9347a783          	lw	a5,-1740(a5) # 80008930 <ticks>
    80002004:	f6f42823          	sw	a5,-144(s0)
    80002008:	8792                	mv	a5,tp
  int id = r_tp();
    8000200a:	f6f42a23          	sw	a5,-140(s0)
  e.type   = MEM_SHRINK;
    8000200e:	4789                	li	a5,2
    80002010:	f6f42c23          	sw	a5,-136(s0)
  e.pid    = p->pid;
    80002014:	0349a783          	lw	a5,52(s3)
    80002018:	f6f42e23          	sw	a5,-132(s0)
  e.state  = p->state;
    8000201c:	0189a783          	lw	a5,24(s3)
    80002020:	f8f42023          	sw	a5,-128(s0)
  e.oldsz  = sz;
    80002024:	fb243423          	sd	s2,-88(s0)
  e.newsz  = sz + n;
    80002028:	94ca                	add	s1,s1,s2
    8000202a:	fa943823          	sd	s1,-80(s0)
  e.source = SRC_UVMDEALLOC;
    8000202e:	4799                	li	a5,6
    80002030:	fcf42223          	sw	a5,-60(s0)
  e.kind   = PAGE_USER;
    80002034:	4785                	li	a5,1
    80002036:	fcf42423          	sw	a5,-56(s0)
  safestrcpy(e.name, p->name, MEM_NM);
    8000203a:	4641                	li	a2,16
    8000203c:	15898593          	addi	a1,s3,344
    80002040:	f8440513          	addi	a0,s0,-124
    80002044:	e8bfe0ef          	jal	80000ece <safestrcpy>
  memlog_push(&e);
    80002048:	f6840513          	addi	a0,s0,-152
    8000204c:	746040ef          	jal	80006792 <memlog_push>
  sz = uvmdealloc(p->pagetable, sz, sz + n);
    80002050:	8626                	mv	a2,s1
    80002052:	85ca                	mv	a1,s2
    80002054:	0509b503          	ld	a0,80(s3)
    80002058:	c1eff0ef          	jal	80001476 <uvmdealloc>
    8000205c:	892a                	mv	s2,a0
    8000205e:	bfa5                	j	80001fd6 <growproc+0x3c>
      return -1;
    80002060:	557d                	li	a0,-1
    80002062:	bfad                	j	80001fdc <growproc+0x42>
      return -1;
    80002064:	557d                	li	a0,-1
    80002066:	bf9d                	j	80001fdc <growproc+0x42>

0000000080002068 <kfork>:
int kfork(void) {
    80002068:	7139                	addi	sp,sp,-64
    8000206a:	fc06                	sd	ra,56(sp)
    8000206c:	f822                	sd	s0,48(sp)
    8000206e:	f04a                	sd	s2,32(sp)
    80002070:	e456                	sd	s5,8(sp)
    80002072:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    80002074:	bf1ff0ef          	jal	80001c64 <myproc>
    80002078:	8aaa                	mv	s5,a0
  if ((np = allocproc()) == 0) {
    8000207a:	e15ff0ef          	jal	80001e8e <allocproc>
    8000207e:	0e050b63          	beqz	a0,80002174 <kfork+0x10c>
    80002082:	e852                	sd	s4,16(sp)
    80002084:	8a2a                	mv	s4,a0
  if (uvmcopy(p->pagetable, np->pagetable, p->sz) < 0) {
    80002086:	048ab603          	ld	a2,72(s5)
    8000208a:	692c                	ld	a1,80(a0)
    8000208c:	050ab503          	ld	a0,80(s5)
    80002090:	ddeff0ef          	jal	8000166e <uvmcopy>
    80002094:	04054a63          	bltz	a0,800020e8 <kfork+0x80>
    80002098:	f426                	sd	s1,40(sp)
    8000209a:	ec4e                	sd	s3,24(sp)
  np->sz = p->sz;
    8000209c:	048ab783          	ld	a5,72(s5)
    800020a0:	04fa3423          	sd	a5,72(s4)
  *(np->trapframe) = *(p->trapframe);
    800020a4:	058ab683          	ld	a3,88(s5)
    800020a8:	87b6                	mv	a5,a3
    800020aa:	058a3703          	ld	a4,88(s4)
    800020ae:	12068693          	addi	a3,a3,288
    800020b2:	0007b803          	ld	a6,0(a5)
    800020b6:	6788                	ld	a0,8(a5)
    800020b8:	6b8c                	ld	a1,16(a5)
    800020ba:	6f90                	ld	a2,24(a5)
    800020bc:	01073023          	sd	a6,0(a4)
    800020c0:	e708                	sd	a0,8(a4)
    800020c2:	eb0c                	sd	a1,16(a4)
    800020c4:	ef10                	sd	a2,24(a4)
    800020c6:	02078793          	addi	a5,a5,32
    800020ca:	02070713          	addi	a4,a4,32
    800020ce:	fed792e3          	bne	a5,a3,800020b2 <kfork+0x4a>
  np->trapframe->a0 = 0;
    800020d2:	058a3783          	ld	a5,88(s4)
    800020d6:	0607b823          	sd	zero,112(a5)
  for (i = 0; i < NOFILE; i++)
    800020da:	0d0a8493          	addi	s1,s5,208
    800020de:	0d0a0913          	addi	s2,s4,208
    800020e2:	150a8993          	addi	s3,s5,336
    800020e6:	a831                	j	80002102 <kfork+0x9a>
    freeproc(np);
    800020e8:	8552                	mv	a0,s4
    800020ea:	d51ff0ef          	jal	80001e3a <freeproc>
    release(&np->lock);
    800020ee:	8552                	mv	a0,s4
    800020f0:	c65fe0ef          	jal	80000d54 <release>
    return -1;
    800020f4:	597d                	li	s2,-1
    800020f6:	6a42                	ld	s4,16(sp)
    800020f8:	a0bd                	j	80002166 <kfork+0xfe>
  for (i = 0; i < NOFILE; i++)
    800020fa:	04a1                	addi	s1,s1,8
    800020fc:	0921                	addi	s2,s2,8
    800020fe:	01348963          	beq	s1,s3,80002110 <kfork+0xa8>
    if (p->ofile[i])
    80002102:	6088                	ld	a0,0(s1)
    80002104:	d97d                	beqz	a0,800020fa <kfork+0x92>
      np->ofile[i] = filedup(p->ofile[i]);
    80002106:	7be020ef          	jal	800048c4 <filedup>
    8000210a:	00a93023          	sd	a0,0(s2)
    8000210e:	b7f5                	j	800020fa <kfork+0x92>
  np->cwd = idup(p->cwd);
    80002110:	150ab503          	ld	a0,336(s5)
    80002114:	1cb010ef          	jal	80003ade <idup>
    80002118:	14aa3823          	sd	a0,336(s4)
  safestrcpy(np->name, p->name, sizeof(p->name));
    8000211c:	4641                	li	a2,16
    8000211e:	158a8593          	addi	a1,s5,344
    80002122:	158a0513          	addi	a0,s4,344
    80002126:	da9fe0ef          	jal	80000ece <safestrcpy>
  pid = np->pid;
    8000212a:	034a2903          	lw	s2,52(s4)
  release(&np->lock);
    8000212e:	8552                	mv	a0,s4
    80002130:	c25fe0ef          	jal	80000d54 <release>
  acquire(&wait_lock);
    80002134:	0000f497          	auipc	s1,0xf
    80002138:	9b448493          	addi	s1,s1,-1612 # 80010ae8 <wait_lock>
    8000213c:	8526                	mv	a0,s1
    8000213e:	b7ffe0ef          	jal	80000cbc <acquire>
  np->parent = p;
    80002142:	035a3c23          	sd	s5,56(s4)
  release(&wait_lock);
    80002146:	8526                	mv	a0,s1
    80002148:	c0dfe0ef          	jal	80000d54 <release>
  acquire(&np->lock);
    8000214c:	8552                	mv	a0,s4
    8000214e:	b6ffe0ef          	jal	80000cbc <acquire>
  setprocstate(np, RUNNABLE);
    80002152:	458d                	li	a1,3
    80002154:	8552                	mv	a0,s4
    80002156:	90bff0ef          	jal	80001a60 <setprocstate>
  release(&np->lock);
    8000215a:	8552                	mv	a0,s4
    8000215c:	bf9fe0ef          	jal	80000d54 <release>
  return pid;
    80002160:	74a2                	ld	s1,40(sp)
    80002162:	69e2                	ld	s3,24(sp)
    80002164:	6a42                	ld	s4,16(sp)
}
    80002166:	854a                	mv	a0,s2
    80002168:	70e2                	ld	ra,56(sp)
    8000216a:	7442                	ld	s0,48(sp)
    8000216c:	7902                	ld	s2,32(sp)
    8000216e:	6aa2                	ld	s5,8(sp)
    80002170:	6121                	addi	sp,sp,64
    80002172:	8082                	ret
    return -1;
    80002174:	597d                	li	s2,-1
    80002176:	bfc5                	j	80002166 <kfork+0xfe>

0000000080002178 <scheduler>:
void scheduler(void) {
    80002178:	7135                	addi	sp,sp,-160
    8000217a:	ed06                	sd	ra,152(sp)
    8000217c:	e922                	sd	s0,144(sp)
    8000217e:	e526                	sd	s1,136(sp)
    80002180:	e14a                	sd	s2,128(sp)
    80002182:	fcce                	sd	s3,120(sp)
    80002184:	f8d2                	sd	s4,112(sp)
    80002186:	f4d6                	sd	s5,104(sp)
    80002188:	f0da                	sd	s6,96(sp)
    8000218a:	ecde                	sd	s7,88(sp)
    8000218c:	1100                	addi	s0,sp,160
    8000218e:	8492                	mv	s1,tp
  int id = r_tp();
    80002190:	2481                	sext.w	s1,s1
    80002192:	8792                	mv	a5,tp
    if(cpuid() == 0){
    80002194:	2781                	sext.w	a5,a5
    80002196:	cf9d                	beqz	a5,800021d4 <scheduler+0x5c>
  c->proc = 0;
    80002198:	0a800a93          	li	s5,168
    8000219c:	03548ab3          	mul	s5,s1,s5
    800021a0:	0000f797          	auipc	a5,0xf
    800021a4:	8e878793          	addi	a5,a5,-1816 # 80010a88 <procstat_lock>
    800021a8:	97d6                	add	a5,a5,s5
    800021aa:	0807b823          	sd	zero,144(a5)
        swtch(&c->context, &p->context);
    800021ae:	0000f797          	auipc	a5,0xf
    800021b2:	97278793          	addi	a5,a5,-1678 # 80010b20 <cpus+0x8>
    800021b6:	9abe                	add	s5,s5,a5
        c->proc = p;
    800021b8:	0a800793          	li	a5,168
    800021bc:	02f484b3          	mul	s1,s1,a5
    800021c0:	0000f917          	auipc	s2,0xf
    800021c4:	8c890913          	addi	s2,s2,-1848 # 80010a88 <procstat_lock>
    800021c8:	9926                	add	s2,s2,s1
        c->run_start_ticks = ticks;
    800021ca:	00006a17          	auipc	s4,0x6
    800021ce:	766a0a13          	addi	s4,s4,1894 # 80008930 <ticks>
    800021d2:	ac05                	j	80002402 <scheduler+0x28a>
      acquire(&schedinfo_lock);
    800021d4:	0000f517          	auipc	a0,0xf
    800021d8:	92c50513          	addi	a0,a0,-1748 # 80010b00 <schedinfo_lock>
    800021dc:	ae1fe0ef          	jal	80000cbc <acquire>
      if(sched_info_logged == 0){
    800021e0:	00006797          	auipc	a5,0x6
    800021e4:	7407a783          	lw	a5,1856(a5) # 80008920 <sched_info_logged>
    800021e8:	cb81                	beqz	a5,800021f8 <scheduler+0x80>
      release(&schedinfo_lock);
    800021ea:	0000f517          	auipc	a0,0xf
    800021ee:	91650513          	addi	a0,a0,-1770 # 80010b00 <schedinfo_lock>
    800021f2:	b63fe0ef          	jal	80000d54 <release>
    800021f6:	b74d                	j	80002198 <scheduler+0x20>
        sched_info_logged = 1;
    800021f8:	4905                	li	s2,1
    800021fa:	00006797          	auipc	a5,0x6
    800021fe:	7327a323          	sw	s2,1830(a5) # 80008920 <sched_info_logged>
        memset(&e, 0, sizeof(e));
    80002202:	04400613          	li	a2,68
    80002206:	4581                	li	a1,0
    80002208:	f6840513          	addi	a0,s0,-152
    8000220c:	b85fe0ef          	jal	80000d90 <memset>
        e.ticks = ticks;
    80002210:	00006797          	auipc	a5,0x6
    80002214:	7207a783          	lw	a5,1824(a5) # 80008930 <ticks>
    80002218:	f6f42623          	sw	a5,-148(s0)
        e.event_type = SCHED_EV_INFO;
    8000221c:	f7242823          	sw	s2,-144(s0)
        safestrcpy(e.scheduler_name, "RR", sizeof(e.scheduler_name));
    80002220:	4641                	li	a2,16
    80002222:	00006597          	auipc	a1,0x6
    80002226:	f9e58593          	addi	a1,a1,-98 # 800081c0 <etext+0x1c0>
    8000222a:	f7440513          	addi	a0,s0,-140
    8000222e:	ca1fe0ef          	jal	80000ece <safestrcpy>
        e.num_cpus = 3;
    80002232:	478d                	li	a5,3
    80002234:	f8f42223          	sw	a5,-124(s0)
        e.time_slice = 1;
    80002238:	f9242423          	sw	s2,-120(s0)
        schedlog_emit(&e);
    8000223c:	f6840513          	addi	a0,s0,-152
    80002240:	7ba040ef          	jal	800069fa <schedlog_emit>
    80002244:	b75d                	j	800021ea <scheduler+0x72>
    80002246:	8ba6                	mv	s7,s1
        if(strncmp(p->name, "schedexport", 16) != 0){
    80002248:	15848993          	addi	s3,s1,344
    8000224c:	4641                	li	a2,16
    8000224e:	00006597          	auipc	a1,0x6
    80002252:	f7a58593          	addi	a1,a1,-134 # 800081c8 <etext+0x1c8>
    80002256:	854e                	mv	a0,s3
    80002258:	c05fe0ef          	jal	80000e5c <strncmp>
    8000225c:	0e051a63          	bnez	a0,80002350 <scheduler+0x1d8>
        swtch(&c->context, &p->context);
    80002260:	060b8593          	addi	a1,s7,96 # 1060 <_entry-0x7fffefa0>
    80002264:	8556                	mv	a0,s5
    80002266:	77e000ef          	jal	800029e4 <swtch>
        if(strncmp(p->name, "schedexport", 16) != 0){
    8000226a:	4641                	li	a2,16
    8000226c:	00006597          	auipc	a1,0x6
    80002270:	f5c58593          	addi	a1,a1,-164 # 800081c8 <etext+0x1c8>
    80002274:	854e                	mv	a0,s3
    80002276:	be7fe0ef          	jal	80000e5c <strncmp>
    8000227a:	10051d63          	bnez	a0,80002394 <scheduler+0x21c>
        if (c->run_start_ticks) {
    8000227e:	13093703          	ld	a4,304(s2)
    80002282:	cb19                	beqz	a4,80002298 <scheduler+0x120>
          c->active_ticks += ticks - c->run_start_ticks;
    80002284:	000a6783          	lwu	a5,0(s4)
    80002288:	12893683          	ld	a3,296(s2)
    8000228c:	97b6                	add	a5,a5,a3
    8000228e:	8f99                	sub	a5,a5,a4
    80002290:	12f93423          	sd	a5,296(s2)
          c->run_start_ticks = 0;
    80002294:	12093823          	sd	zero,304(s2)
        c->last_pid = p->pid;
    80002298:	58dc                	lw	a5,52(s1)
    8000229a:	10f92e23          	sw	a5,284(s2)
        c->last_state = p->state;
    8000229e:	4c9c                	lw	a5,24(s1)
    800022a0:	12f92023          	sw	a5,288(s2)
        c->current_pid = 0;
    800022a4:	10092a23          	sw	zero,276(s2)
        c->current_state = UNUSED;
    800022a8:	10092c23          	sw	zero,280(s2)
        c->proc = 0;
    800022ac:	08093823          	sd	zero,144(s2)
        found = 1;
    800022b0:	4985                	li	s3,1
      release(&p->lock);
    800022b2:	8526                	mv	a0,s1
    800022b4:	aa1fe0ef          	jal	80000d54 <release>
    for (p = proc; p < &proc[NPROC]; p++) {
    800022b8:	16848493          	addi	s1,s1,360
    800022bc:	00014797          	auipc	a5,0x14
    800022c0:	79c78793          	addi	a5,a5,1948 # 80016a58 <tickslock>
    800022c4:	12f48b63          	beq	s1,a5,800023fa <scheduler+0x282>
      acquire(&p->lock);
    800022c8:	8526                	mv	a0,s1
    800022ca:	9f3fe0ef          	jal	80000cbc <acquire>
      if (p->state == RUNNABLE) {
    800022ce:	4c98                	lw	a4,24(s1)
    800022d0:	478d                	li	a5,3
    800022d2:	fef710e3          	bne	a4,a5,800022b2 <scheduler+0x13a>
        setprocstate(p, RUNNING);
    800022d6:	4591                	li	a1,4
    800022d8:	8526                	mv	a0,s1
    800022da:	f86ff0ef          	jal	80001a60 <setprocstate>
        c->proc = p;
    800022de:	08993823          	sd	s1,144(s2)
        c->current_pid = p->pid;
    800022e2:	58dc                	lw	a5,52(s1)
    800022e4:	10f92a23          	sw	a5,276(s2)
        c->current_state = RUNNING;
    800022e8:	4791                	li	a5,4
    800022ea:	10f92c23          	sw	a5,280(s2)
        c->run_start_ticks = ticks;
    800022ee:	000a6783          	lwu	a5,0(s4)
    800022f2:	12f93823          	sd	a5,304(s2)
        cslog_run_start(p);
    800022f6:	8526                	mv	a0,s1
    800022f8:	048040ef          	jal	80006340 <cslog_run_start>
    800022fc:	8792                	mv	a5,tp
        if (cpuid() == 0 && sched_info_logged == 0) {
    800022fe:	2781                	sext.w	a5,a5
    80002300:	f3b9                	bnez	a5,80002246 <scheduler+0xce>
    80002302:	000b2783          	lw	a5,0(s6)
    80002306:	2781                	sext.w	a5,a5
    80002308:	ff9d                	bnez	a5,80002246 <scheduler+0xce>
          sched_info_logged = 1;
    8000230a:	4985                	li	s3,1
    8000230c:	013b2023          	sw	s3,0(s6)
          memset(&e, 0, sizeof(e));
    80002310:	04400613          	li	a2,68
    80002314:	4581                	li	a1,0
    80002316:	f6840513          	addi	a0,s0,-152
    8000231a:	a77fe0ef          	jal	80000d90 <memset>
          e.ticks = ticks;
    8000231e:	000a2783          	lw	a5,0(s4)
    80002322:	f6f42623          	sw	a5,-148(s0)
          e.event_type = SCHED_EV_INFO;
    80002326:	f7342823          	sw	s3,-144(s0)
          safestrcpy(e.scheduler_name, "RR", sizeof(e.scheduler_name));
    8000232a:	4641                	li	a2,16
    8000232c:	00006597          	auipc	a1,0x6
    80002330:	e9458593          	addi	a1,a1,-364 # 800081c0 <etext+0x1c0>
    80002334:	f7440513          	addi	a0,s0,-140
    80002338:	b97fe0ef          	jal	80000ece <safestrcpy>
          e.num_cpus = NCPU;
    8000233c:	47a1                	li	a5,8
    8000233e:	f8f42223          	sw	a5,-124(s0)
          e.time_slice = 1;
    80002342:	f9342423          	sw	s3,-120(s0)
          schedlog_emit(&e);
    80002346:	f6840513          	addi	a0,s0,-152
    8000234a:	6b0040ef          	jal	800069fa <schedlog_emit>
    8000234e:	bde5                	j	80002246 <scheduler+0xce>
          memset(&e, 0, sizeof(e));
    80002350:	04400613          	li	a2,68
    80002354:	4581                	li	a1,0
    80002356:	f6840513          	addi	a0,s0,-152
    8000235a:	a37fe0ef          	jal	80000d90 <memset>
          e.ticks = ticks;
    8000235e:	000a2783          	lw	a5,0(s4)
    80002362:	f6f42623          	sw	a5,-148(s0)
          e.event_type = SCHED_EV_ON_CPU;
    80002366:	4789                	li	a5,2
    80002368:	f6f42823          	sw	a5,-144(s0)
    8000236c:	8792                	mv	a5,tp
  int id = r_tp();
    8000236e:	f8f42623          	sw	a5,-116(s0)
          e.pid = p->pid;
    80002372:	58dc                	lw	a5,52(s1)
    80002374:	f8f42823          	sw	a5,-112(s0)
          safestrcpy(e.name, p->name, sizeof(e.name));
    80002378:	4641                	li	a2,16
    8000237a:	85ce                	mv	a1,s3
    8000237c:	f9440513          	addi	a0,s0,-108
    80002380:	b4ffe0ef          	jal	80000ece <safestrcpy>
          e.state = p->state;
    80002384:	4c9c                	lw	a5,24(s1)
    80002386:	faf42223          	sw	a5,-92(s0)
          schedlog_emit(&e);
    8000238a:	f6840513          	addi	a0,s0,-152
    8000238e:	66c040ef          	jal	800069fa <schedlog_emit>
    80002392:	b5f9                	j	80002260 <scheduler+0xe8>
          memset(&e2, 0, sizeof(e2));
    80002394:	04400613          	li	a2,68
    80002398:	4581                	li	a1,0
    8000239a:	f6840513          	addi	a0,s0,-152
    8000239e:	9f3fe0ef          	jal	80000d90 <memset>
          e2.ticks = ticks;
    800023a2:	000a2783          	lw	a5,0(s4)
    800023a6:	f6f42623          	sw	a5,-148(s0)
          e2.event_type = SCHED_EV_OFF_CPU;
    800023aa:	478d                	li	a5,3
    800023ac:	f6f42823          	sw	a5,-144(s0)
    800023b0:	8792                	mv	a5,tp
  int id = r_tp();
    800023b2:	f8f42623          	sw	a5,-116(s0)
          e2.pid = p->pid;
    800023b6:	58dc                	lw	a5,52(s1)
    800023b8:	f8f42823          	sw	a5,-112(s0)
          safestrcpy(e2.name, p->name, sizeof(e2.name));
    800023bc:	4641                	li	a2,16
    800023be:	85ce                	mv	a1,s3
    800023c0:	f9440513          	addi	a0,s0,-108
    800023c4:	b0bfe0ef          	jal	80000ece <safestrcpy>
          e2.state = p->state;
    800023c8:	4c9c                	lw	a5,24(s1)
    800023ca:	0007869b          	sext.w	a3,a5
          if(p->state == SLEEPING)
    800023ce:	4609                	li	a2,2
    800023d0:	4709                	li	a4,2
    800023d2:	00c78b63          	beq	a5,a2,800023e8 <scheduler+0x270>
          else if(p->state == ZOMBIE)
    800023d6:	4615                	li	a2,5
    800023d8:	4711                	li	a4,4
    800023da:	00c78763          	beq	a5,a2,800023e8 <scheduler+0x270>
          else if(p->state == RUNNABLE)
    800023de:	460d                	li	a2,3
    800023e0:	470d                	li	a4,3
    800023e2:	00c78363          	beq	a5,a2,800023e8 <scheduler+0x270>
    800023e6:	4701                	li	a4,0
          e2.state = p->state;
    800023e8:	fad42223          	sw	a3,-92(s0)
            e2.reason = SCHED_OFF_SLEEP;
    800023ec:	fae42423          	sw	a4,-88(s0)
          schedlog_emit(&e2);
    800023f0:	f6840513          	addi	a0,s0,-152
    800023f4:	606040ef          	jal	800069fa <schedlog_emit>
    800023f8:	b559                	j	8000227e <scheduler+0x106>
    if (found == 0) {
    800023fa:	00099463          	bnez	s3,80002402 <scheduler+0x28a>
      asm volatile("wfi");
    800023fe:	10500073          	wfi
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002402:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002406:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000240a:	10079073          	csrw	sstatus,a5
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000240e:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80002412:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002414:	10079073          	csrw	sstatus,a5
    int found = 0;
    80002418:	4981                	li	s3,0
    for (p = proc; p < &proc[NPROC]; p++) {
    8000241a:	0000f497          	auipc	s1,0xf
    8000241e:	c3e48493          	addi	s1,s1,-962 # 80011058 <proc>
        if (cpuid() == 0 && sched_info_logged == 0) {
    80002422:	00006b17          	auipc	s6,0x6
    80002426:	4feb0b13          	addi	s6,s6,1278 # 80008920 <sched_info_logged>
    8000242a:	bd79                	j	800022c8 <scheduler+0x150>

000000008000242c <sched>:
void sched(void) {
    8000242c:	7179                	addi	sp,sp,-48
    8000242e:	f406                	sd	ra,40(sp)
    80002430:	f022                	sd	s0,32(sp)
    80002432:	ec26                	sd	s1,24(sp)
    80002434:	e84a                	sd	s2,16(sp)
    80002436:	e44e                	sd	s3,8(sp)
    80002438:	e052                	sd	s4,0(sp)
    8000243a:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    8000243c:	829ff0ef          	jal	80001c64 <myproc>
    80002440:	84aa                	mv	s1,a0
  if (!holding(&p->lock))
    80002442:	811fe0ef          	jal	80000c52 <holding>
    80002446:	c151                	beqz	a0,800024ca <sched+0x9e>
  asm volatile("mv %0, tp" : "=r" (x) );
    80002448:	8792                	mv	a5,tp
  if (mycpu()->noff != 1)
    8000244a:	2781                	sext.w	a5,a5
    8000244c:	0a800713          	li	a4,168
    80002450:	02e787b3          	mul	a5,a5,a4
    80002454:	0000e717          	auipc	a4,0xe
    80002458:	63470713          	addi	a4,a4,1588 # 80010a88 <procstat_lock>
    8000245c:	97ba                	add	a5,a5,a4
    8000245e:	1087a703          	lw	a4,264(a5)
    80002462:	4785                	li	a5,1
    80002464:	06f71963          	bne	a4,a5,800024d6 <sched+0xaa>
  if (p->state == RUNNING)
    80002468:	4c98                	lw	a4,24(s1)
    8000246a:	4791                	li	a5,4
    8000246c:	06f70b63          	beq	a4,a5,800024e2 <sched+0xb6>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002470:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002474:	8b89                	andi	a5,a5,2
  if (intr_get())
    80002476:	efa5                	bnez	a5,800024ee <sched+0xc2>
  asm volatile("mv %0, tp" : "=r" (x) );
    80002478:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    8000247a:	0000e917          	auipc	s2,0xe
    8000247e:	60e90913          	addi	s2,s2,1550 # 80010a88 <procstat_lock>
    80002482:	2781                	sext.w	a5,a5
    80002484:	0a800993          	li	s3,168
    80002488:	033787b3          	mul	a5,a5,s3
    8000248c:	97ca                	add	a5,a5,s2
    8000248e:	10c7aa03          	lw	s4,268(a5)
    80002492:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    80002494:	2781                	sext.w	a5,a5
    80002496:	033787b3          	mul	a5,a5,s3
    8000249a:	0000e597          	auipc	a1,0xe
    8000249e:	68658593          	addi	a1,a1,1670 # 80010b20 <cpus+0x8>
    800024a2:	95be                	add	a1,a1,a5
    800024a4:	06048513          	addi	a0,s1,96
    800024a8:	53c000ef          	jal	800029e4 <swtch>
    800024ac:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    800024ae:	2781                	sext.w	a5,a5
    800024b0:	033787b3          	mul	a5,a5,s3
    800024b4:	993e                	add	s2,s2,a5
    800024b6:	11492623          	sw	s4,268(s2)
}
    800024ba:	70a2                	ld	ra,40(sp)
    800024bc:	7402                	ld	s0,32(sp)
    800024be:	64e2                	ld	s1,24(sp)
    800024c0:	6942                	ld	s2,16(sp)
    800024c2:	69a2                	ld	s3,8(sp)
    800024c4:	6a02                	ld	s4,0(sp)
    800024c6:	6145                	addi	sp,sp,48
    800024c8:	8082                	ret
    panic("sched p->lock");
    800024ca:	00006517          	auipc	a0,0x6
    800024ce:	d0e50513          	addi	a0,a0,-754 # 800081d8 <etext+0x1d8>
    800024d2:	b40fe0ef          	jal	80000812 <panic>
    panic("sched locks");
    800024d6:	00006517          	auipc	a0,0x6
    800024da:	d1250513          	addi	a0,a0,-750 # 800081e8 <etext+0x1e8>
    800024de:	b34fe0ef          	jal	80000812 <panic>
    panic("sched RUNNING");
    800024e2:	00006517          	auipc	a0,0x6
    800024e6:	d1650513          	addi	a0,a0,-746 # 800081f8 <etext+0x1f8>
    800024ea:	b28fe0ef          	jal	80000812 <panic>
    panic("sched interruptible");
    800024ee:	00006517          	auipc	a0,0x6
    800024f2:	d1a50513          	addi	a0,a0,-742 # 80008208 <etext+0x208>
    800024f6:	b1cfe0ef          	jal	80000812 <panic>

00000000800024fa <yield>:
void yield(void) {
    800024fa:	1101                	addi	sp,sp,-32
    800024fc:	ec06                	sd	ra,24(sp)
    800024fe:	e822                	sd	s0,16(sp)
    80002500:	e426                	sd	s1,8(sp)
    80002502:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80002504:	f60ff0ef          	jal	80001c64 <myproc>
    80002508:	84aa                	mv	s1,a0
  acquire(&p->lock);
    8000250a:	fb2fe0ef          	jal	80000cbc <acquire>
  setprocstate(p, RUNNABLE);
    8000250e:	458d                	li	a1,3
    80002510:	8526                	mv	a0,s1
    80002512:	d4eff0ef          	jal	80001a60 <setprocstate>
  sched();
    80002516:	f17ff0ef          	jal	8000242c <sched>
  release(&p->lock);
    8000251a:	8526                	mv	a0,s1
    8000251c:	839fe0ef          	jal	80000d54 <release>
}
    80002520:	60e2                	ld	ra,24(sp)
    80002522:	6442                	ld	s0,16(sp)
    80002524:	64a2                	ld	s1,8(sp)
    80002526:	6105                	addi	sp,sp,32
    80002528:	8082                	ret

000000008000252a <sleep>:

// Sleep on channel chan, releasing condition lock lk.
// Re-acquires lk when awakened.
void sleep(void *chan, struct spinlock *lk) {
    8000252a:	7179                	addi	sp,sp,-48
    8000252c:	f406                	sd	ra,40(sp)
    8000252e:	f022                	sd	s0,32(sp)
    80002530:	ec26                	sd	s1,24(sp)
    80002532:	e84a                	sd	s2,16(sp)
    80002534:	e44e                	sd	s3,8(sp)
    80002536:	1800                	addi	s0,sp,48
    80002538:	89aa                	mv	s3,a0
    8000253a:	892e                	mv	s2,a1
  struct proc *p = myproc();
    8000253c:	f28ff0ef          	jal	80001c64 <myproc>
    80002540:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock); // DOC: sleeplock1
    80002542:	f7afe0ef          	jal	80000cbc <acquire>
  release(lk);
    80002546:	854a                	mv	a0,s2
    80002548:	80dfe0ef          	jal	80000d54 <release>

  // Go to sleep.
  p->chan = chan;
    8000254c:	0334b023          	sd	s3,32(s1)
  setprocstate(p, SLEEPING);
    80002550:	4589                	li	a1,2
    80002552:	8526                	mv	a0,s1
    80002554:	d0cff0ef          	jal	80001a60 <setprocstate>

  sched();
    80002558:	ed5ff0ef          	jal	8000242c <sched>

  // Tidy up.
  p->chan = 0;
    8000255c:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    80002560:	8526                	mv	a0,s1
    80002562:	ff2fe0ef          	jal	80000d54 <release>
  acquire(lk);
    80002566:	854a                	mv	a0,s2
    80002568:	f54fe0ef          	jal	80000cbc <acquire>
}
    8000256c:	70a2                	ld	ra,40(sp)
    8000256e:	7402                	ld	s0,32(sp)
    80002570:	64e2                	ld	s1,24(sp)
    80002572:	6942                	ld	s2,16(sp)
    80002574:	69a2                	ld	s3,8(sp)
    80002576:	6145                	addi	sp,sp,48
    80002578:	8082                	ret

000000008000257a <wakeup>:

// Wake up all processes sleeping on channel chan.
// Caller should hold the condition lock.
void wakeup(void *chan) {
    8000257a:	7179                	addi	sp,sp,-48
    8000257c:	f406                	sd	ra,40(sp)
    8000257e:	f022                	sd	s0,32(sp)
    80002580:	ec26                	sd	s1,24(sp)
    80002582:	e84a                	sd	s2,16(sp)
    80002584:	e44e                	sd	s3,8(sp)
    80002586:	e052                	sd	s4,0(sp)
    80002588:	1800                	addi	s0,sp,48
    8000258a:	8a2a                	mv	s4,a0
  struct proc *p;

  for (p = proc; p < &proc[NPROC]; p++) {
    8000258c:	0000f497          	auipc	s1,0xf
    80002590:	acc48493          	addi	s1,s1,-1332 # 80011058 <proc>
    if (p != myproc()) {
      acquire(&p->lock);
      if (p->state == SLEEPING && p->chan == chan) {
    80002594:	4989                	li	s3,2
  for (p = proc; p < &proc[NPROC]; p++) {
    80002596:	00014917          	auipc	s2,0x14
    8000259a:	4c290913          	addi	s2,s2,1218 # 80016a58 <tickslock>
    8000259e:	a801                	j	800025ae <wakeup+0x34>
        setprocstate(p, RUNNABLE);
      }
      release(&p->lock);
    800025a0:	8526                	mv	a0,s1
    800025a2:	fb2fe0ef          	jal	80000d54 <release>
  for (p = proc; p < &proc[NPROC]; p++) {
    800025a6:	16848493          	addi	s1,s1,360
    800025aa:	03248463          	beq	s1,s2,800025d2 <wakeup+0x58>
    if (p != myproc()) {
    800025ae:	eb6ff0ef          	jal	80001c64 <myproc>
    800025b2:	fea48ae3          	beq	s1,a0,800025a6 <wakeup+0x2c>
      acquire(&p->lock);
    800025b6:	8526                	mv	a0,s1
    800025b8:	f04fe0ef          	jal	80000cbc <acquire>
      if (p->state == SLEEPING && p->chan == chan) {
    800025bc:	4c9c                	lw	a5,24(s1)
    800025be:	ff3791e3          	bne	a5,s3,800025a0 <wakeup+0x26>
    800025c2:	709c                	ld	a5,32(s1)
    800025c4:	fd479ee3          	bne	a5,s4,800025a0 <wakeup+0x26>
        setprocstate(p, RUNNABLE);
    800025c8:	458d                	li	a1,3
    800025ca:	8526                	mv	a0,s1
    800025cc:	c94ff0ef          	jal	80001a60 <setprocstate>
    800025d0:	bfc1                	j	800025a0 <wakeup+0x26>
    }
  }
}
    800025d2:	70a2                	ld	ra,40(sp)
    800025d4:	7402                	ld	s0,32(sp)
    800025d6:	64e2                	ld	s1,24(sp)
    800025d8:	6942                	ld	s2,16(sp)
    800025da:	69a2                	ld	s3,8(sp)
    800025dc:	6a02                	ld	s4,0(sp)
    800025de:	6145                	addi	sp,sp,48
    800025e0:	8082                	ret

00000000800025e2 <reparent>:
void reparent(struct proc *p) {
    800025e2:	7179                	addi	sp,sp,-48
    800025e4:	f406                	sd	ra,40(sp)
    800025e6:	f022                	sd	s0,32(sp)
    800025e8:	ec26                	sd	s1,24(sp)
    800025ea:	e84a                	sd	s2,16(sp)
    800025ec:	e44e                	sd	s3,8(sp)
    800025ee:	e052                	sd	s4,0(sp)
    800025f0:	1800                	addi	s0,sp,48
    800025f2:	892a                	mv	s2,a0
  for (pp = proc; pp < &proc[NPROC]; pp++) {
    800025f4:	0000f497          	auipc	s1,0xf
    800025f8:	a6448493          	addi	s1,s1,-1436 # 80011058 <proc>
      pp->parent = initproc;
    800025fc:	00006a17          	auipc	s4,0x6
    80002600:	32ca0a13          	addi	s4,s4,812 # 80008928 <initproc>
  for (pp = proc; pp < &proc[NPROC]; pp++) {
    80002604:	00014997          	auipc	s3,0x14
    80002608:	45498993          	addi	s3,s3,1108 # 80016a58 <tickslock>
    8000260c:	a029                	j	80002616 <reparent+0x34>
    8000260e:	16848493          	addi	s1,s1,360
    80002612:	01348b63          	beq	s1,s3,80002628 <reparent+0x46>
    if (pp->parent == p) {
    80002616:	7c9c                	ld	a5,56(s1)
    80002618:	ff279be3          	bne	a5,s2,8000260e <reparent+0x2c>
      pp->parent = initproc;
    8000261c:	000a3503          	ld	a0,0(s4)
    80002620:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    80002622:	f59ff0ef          	jal	8000257a <wakeup>
    80002626:	b7e5                	j	8000260e <reparent+0x2c>
}
    80002628:	70a2                	ld	ra,40(sp)
    8000262a:	7402                	ld	s0,32(sp)
    8000262c:	64e2                	ld	s1,24(sp)
    8000262e:	6942                	ld	s2,16(sp)
    80002630:	69a2                	ld	s3,8(sp)
    80002632:	6a02                	ld	s4,0(sp)
    80002634:	6145                	addi	sp,sp,48
    80002636:	8082                	ret

0000000080002638 <kexit>:
void kexit(int status) {
    80002638:	7179                	addi	sp,sp,-48
    8000263a:	f406                	sd	ra,40(sp)
    8000263c:	f022                	sd	s0,32(sp)
    8000263e:	ec26                	sd	s1,24(sp)
    80002640:	e84a                	sd	s2,16(sp)
    80002642:	e44e                	sd	s3,8(sp)
    80002644:	e052                	sd	s4,0(sp)
    80002646:	1800                	addi	s0,sp,48
    80002648:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    8000264a:	e1aff0ef          	jal	80001c64 <myproc>
    8000264e:	89aa                	mv	s3,a0
  if (p == initproc)
    80002650:	00006797          	auipc	a5,0x6
    80002654:	2d87b783          	ld	a5,728(a5) # 80008928 <initproc>
    80002658:	0d050493          	addi	s1,a0,208
    8000265c:	15050913          	addi	s2,a0,336
    80002660:	00a79f63          	bne	a5,a0,8000267e <kexit+0x46>
    panic("init exiting");
    80002664:	00006517          	auipc	a0,0x6
    80002668:	bbc50513          	addi	a0,a0,-1092 # 80008220 <etext+0x220>
    8000266c:	9a6fe0ef          	jal	80000812 <panic>
      fileclose(f);
    80002670:	29a020ef          	jal	8000490a <fileclose>
      p->ofile[fd] = 0;
    80002674:	0004b023          	sd	zero,0(s1)
  for (int fd = 0; fd < NOFILE; fd++) {
    80002678:	04a1                	addi	s1,s1,8
    8000267a:	01248563          	beq	s1,s2,80002684 <kexit+0x4c>
    if (p->ofile[fd]) {
    8000267e:	6088                	ld	a0,0(s1)
    80002680:	f965                	bnez	a0,80002670 <kexit+0x38>
    80002682:	bfdd                	j	80002678 <kexit+0x40>
  begin_op();
    80002684:	67b010ef          	jal	800044fe <begin_op>
  iput(p->cwd);
    80002688:	1509b503          	ld	a0,336(s3)
    8000268c:	60a010ef          	jal	80003c96 <iput>
  end_op();
    80002690:	6d9010ef          	jal	80004568 <end_op>
  p->cwd = 0;
    80002694:	1409b823          	sd	zero,336(s3)
  acquire(&wait_lock);
    80002698:	0000e917          	auipc	s2,0xe
    8000269c:	3f090913          	addi	s2,s2,1008 # 80010a88 <procstat_lock>
    800026a0:	0000e497          	auipc	s1,0xe
    800026a4:	44848493          	addi	s1,s1,1096 # 80010ae8 <wait_lock>
    800026a8:	8526                	mv	a0,s1
    800026aa:	e12fe0ef          	jal	80000cbc <acquire>
  reparent(p);
    800026ae:	854e                	mv	a0,s3
    800026b0:	f33ff0ef          	jal	800025e2 <reparent>
  wakeup(p->parent);
    800026b4:	0389b503          	ld	a0,56(s3)
    800026b8:	ec3ff0ef          	jal	8000257a <wakeup>
  acquire(&p->lock);
    800026bc:	854e                	mv	a0,s3
    800026be:	dfefe0ef          	jal	80000cbc <acquire>
  p->xstate = status;
    800026c2:	0349a823          	sw	s4,48(s3)
  setprocstate(p, ZOMBIE);
    800026c6:	4595                	li	a1,5
    800026c8:	854e                	mv	a0,s3
    800026ca:	b96ff0ef          	jal	80001a60 <setprocstate>
  acquire(&procstat_lock);
    800026ce:	854a                	mv	a0,s2
    800026d0:	decfe0ef          	jal	80000cbc <acquire>
  proc_total_exited++;
    800026d4:	00006717          	auipc	a4,0x6
    800026d8:	23c70713          	addi	a4,a4,572 # 80008910 <proc_total_exited>
    800026dc:	631c                	ld	a5,0(a4)
    800026de:	0785                	addi	a5,a5,1
    800026e0:	e31c                	sd	a5,0(a4)
  release(&procstat_lock);
    800026e2:	854a                	mv	a0,s2
    800026e4:	e70fe0ef          	jal	80000d54 <release>
  release(&wait_lock);
    800026e8:	8526                	mv	a0,s1
    800026ea:	e6afe0ef          	jal	80000d54 <release>
  sched();
    800026ee:	d3fff0ef          	jal	8000242c <sched>
  panic("zombie exit");
    800026f2:	00006517          	auipc	a0,0x6
    800026f6:	b3e50513          	addi	a0,a0,-1218 # 80008230 <etext+0x230>
    800026fa:	918fe0ef          	jal	80000812 <panic>

00000000800026fe <kkill>:

// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int kkill(int pid) {
    800026fe:	7179                	addi	sp,sp,-48
    80002700:	f406                	sd	ra,40(sp)
    80002702:	f022                	sd	s0,32(sp)
    80002704:	ec26                	sd	s1,24(sp)
    80002706:	e84a                	sd	s2,16(sp)
    80002708:	e44e                	sd	s3,8(sp)
    8000270a:	1800                	addi	s0,sp,48
    8000270c:	892a                	mv	s2,a0
  struct proc *p;

  for (p = proc; p < &proc[NPROC]; p++) {
    8000270e:	0000f497          	auipc	s1,0xf
    80002712:	94a48493          	addi	s1,s1,-1718 # 80011058 <proc>
    80002716:	00014997          	auipc	s3,0x14
    8000271a:	34298993          	addi	s3,s3,834 # 80016a58 <tickslock>
    acquire(&p->lock);
    8000271e:	8526                	mv	a0,s1
    80002720:	d9cfe0ef          	jal	80000cbc <acquire>
    if (p->pid == pid) {
    80002724:	58dc                	lw	a5,52(s1)
    80002726:	01278b63          	beq	a5,s2,8000273c <kkill+0x3e>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    8000272a:	8526                	mv	a0,s1
    8000272c:	e28fe0ef          	jal	80000d54 <release>
  for (p = proc; p < &proc[NPROC]; p++) {
    80002730:	16848493          	addi	s1,s1,360
    80002734:	ff3495e3          	bne	s1,s3,8000271e <kkill+0x20>
  }
  return -1;
    80002738:	557d                	li	a0,-1
    8000273a:	a819                	j	80002750 <kkill+0x52>
      p->killed = 1;
    8000273c:	4785                	li	a5,1
    8000273e:	d49c                	sw	a5,40(s1)
      if (p->state == SLEEPING) {
    80002740:	4c98                	lw	a4,24(s1)
    80002742:	4789                	li	a5,2
    80002744:	00f70d63          	beq	a4,a5,8000275e <kkill+0x60>
      release(&p->lock);
    80002748:	8526                	mv	a0,s1
    8000274a:	e0afe0ef          	jal	80000d54 <release>
      return 0;
    8000274e:	4501                	li	a0,0
}
    80002750:	70a2                	ld	ra,40(sp)
    80002752:	7402                	ld	s0,32(sp)
    80002754:	64e2                	ld	s1,24(sp)
    80002756:	6942                	ld	s2,16(sp)
    80002758:	69a2                	ld	s3,8(sp)
    8000275a:	6145                	addi	sp,sp,48
    8000275c:	8082                	ret
        p->state = RUNNABLE;
    8000275e:	478d                	li	a5,3
    80002760:	cc9c                	sw	a5,24(s1)
    80002762:	b7dd                	j	80002748 <kkill+0x4a>

0000000080002764 <setkilled>:

void setkilled(struct proc *p) {
    80002764:	1101                	addi	sp,sp,-32
    80002766:	ec06                	sd	ra,24(sp)
    80002768:	e822                	sd	s0,16(sp)
    8000276a:	e426                	sd	s1,8(sp)
    8000276c:	1000                	addi	s0,sp,32
    8000276e:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80002770:	d4cfe0ef          	jal	80000cbc <acquire>
  p->killed = 1;
    80002774:	4785                	li	a5,1
    80002776:	d49c                	sw	a5,40(s1)
  release(&p->lock);
    80002778:	8526                	mv	a0,s1
    8000277a:	ddafe0ef          	jal	80000d54 <release>
}
    8000277e:	60e2                	ld	ra,24(sp)
    80002780:	6442                	ld	s0,16(sp)
    80002782:	64a2                	ld	s1,8(sp)
    80002784:	6105                	addi	sp,sp,32
    80002786:	8082                	ret

0000000080002788 <killed>:

int killed(struct proc *p) {
    80002788:	1101                	addi	sp,sp,-32
    8000278a:	ec06                	sd	ra,24(sp)
    8000278c:	e822                	sd	s0,16(sp)
    8000278e:	e426                	sd	s1,8(sp)
    80002790:	e04a                	sd	s2,0(sp)
    80002792:	1000                	addi	s0,sp,32
    80002794:	84aa                	mv	s1,a0
  int k;

  acquire(&p->lock);
    80002796:	d26fe0ef          	jal	80000cbc <acquire>
  k = p->killed;
    8000279a:	0284a903          	lw	s2,40(s1)
  release(&p->lock);
    8000279e:	8526                	mv	a0,s1
    800027a0:	db4fe0ef          	jal	80000d54 <release>
  return k;
}
    800027a4:	854a                	mv	a0,s2
    800027a6:	60e2                	ld	ra,24(sp)
    800027a8:	6442                	ld	s0,16(sp)
    800027aa:	64a2                	ld	s1,8(sp)
    800027ac:	6902                	ld	s2,0(sp)
    800027ae:	6105                	addi	sp,sp,32
    800027b0:	8082                	ret

00000000800027b2 <kwait>:
int kwait(uint64 addr) {
    800027b2:	715d                	addi	sp,sp,-80
    800027b4:	e486                	sd	ra,72(sp)
    800027b6:	e0a2                	sd	s0,64(sp)
    800027b8:	fc26                	sd	s1,56(sp)
    800027ba:	f84a                	sd	s2,48(sp)
    800027bc:	f44e                	sd	s3,40(sp)
    800027be:	f052                	sd	s4,32(sp)
    800027c0:	ec56                	sd	s5,24(sp)
    800027c2:	e85a                	sd	s6,16(sp)
    800027c4:	e45e                	sd	s7,8(sp)
    800027c6:	e062                	sd	s8,0(sp)
    800027c8:	0880                	addi	s0,sp,80
    800027ca:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    800027cc:	c98ff0ef          	jal	80001c64 <myproc>
    800027d0:	892a                	mv	s2,a0
  acquire(&wait_lock);
    800027d2:	0000e517          	auipc	a0,0xe
    800027d6:	31650513          	addi	a0,a0,790 # 80010ae8 <wait_lock>
    800027da:	ce2fe0ef          	jal	80000cbc <acquire>
    havekids = 0;
    800027de:	4b81                	li	s7,0
        if (pp->state == ZOMBIE) {
    800027e0:	4a15                	li	s4,5
        havekids = 1;
    800027e2:	4a85                	li	s5,1
    for (pp = proc; pp < &proc[NPROC]; pp++) {
    800027e4:	00014997          	auipc	s3,0x14
    800027e8:	27498993          	addi	s3,s3,628 # 80016a58 <tickslock>
    sleep(p, &wait_lock); // DOC: wait-sleep
    800027ec:	0000ec17          	auipc	s8,0xe
    800027f0:	2fcc0c13          	addi	s8,s8,764 # 80010ae8 <wait_lock>
    800027f4:	a871                	j	80002890 <kwait+0xde>
          pid = pp->pid;
    800027f6:	0344a983          	lw	s3,52(s1)
          if (addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    800027fa:	000b0c63          	beqz	s6,80002812 <kwait+0x60>
    800027fe:	4691                	li	a3,4
    80002800:	03048613          	addi	a2,s1,48
    80002804:	85da                	mv	a1,s6
    80002806:	05093503          	ld	a0,80(s2)
    8000280a:	8e4ff0ef          	jal	800018ee <copyout>
    8000280e:	02054b63          	bltz	a0,80002844 <kwait+0x92>
          freeproc(pp);
    80002812:	8526                	mv	a0,s1
    80002814:	e26ff0ef          	jal	80001e3a <freeproc>
          release(&pp->lock);
    80002818:	8526                	mv	a0,s1
    8000281a:	d3afe0ef          	jal	80000d54 <release>
          release(&wait_lock);
    8000281e:	0000e517          	auipc	a0,0xe
    80002822:	2ca50513          	addi	a0,a0,714 # 80010ae8 <wait_lock>
    80002826:	d2efe0ef          	jal	80000d54 <release>
}
    8000282a:	854e                	mv	a0,s3
    8000282c:	60a6                	ld	ra,72(sp)
    8000282e:	6406                	ld	s0,64(sp)
    80002830:	74e2                	ld	s1,56(sp)
    80002832:	7942                	ld	s2,48(sp)
    80002834:	79a2                	ld	s3,40(sp)
    80002836:	7a02                	ld	s4,32(sp)
    80002838:	6ae2                	ld	s5,24(sp)
    8000283a:	6b42                	ld	s6,16(sp)
    8000283c:	6ba2                	ld	s7,8(sp)
    8000283e:	6c02                	ld	s8,0(sp)
    80002840:	6161                	addi	sp,sp,80
    80002842:	8082                	ret
            release(&pp->lock);
    80002844:	8526                	mv	a0,s1
    80002846:	d0efe0ef          	jal	80000d54 <release>
            release(&wait_lock);
    8000284a:	0000e517          	auipc	a0,0xe
    8000284e:	29e50513          	addi	a0,a0,670 # 80010ae8 <wait_lock>
    80002852:	d02fe0ef          	jal	80000d54 <release>
            return -1;
    80002856:	59fd                	li	s3,-1
    80002858:	bfc9                	j	8000282a <kwait+0x78>
    for (pp = proc; pp < &proc[NPROC]; pp++) {
    8000285a:	16848493          	addi	s1,s1,360
    8000285e:	03348063          	beq	s1,s3,8000287e <kwait+0xcc>
      if (pp->parent == p) {
    80002862:	7c9c                	ld	a5,56(s1)
    80002864:	ff279be3          	bne	a5,s2,8000285a <kwait+0xa8>
        acquire(&pp->lock);
    80002868:	8526                	mv	a0,s1
    8000286a:	c52fe0ef          	jal	80000cbc <acquire>
        if (pp->state == ZOMBIE) {
    8000286e:	4c9c                	lw	a5,24(s1)
    80002870:	f94783e3          	beq	a5,s4,800027f6 <kwait+0x44>
        release(&pp->lock);
    80002874:	8526                	mv	a0,s1
    80002876:	cdefe0ef          	jal	80000d54 <release>
        havekids = 1;
    8000287a:	8756                	mv	a4,s5
    8000287c:	bff9                	j	8000285a <kwait+0xa8>
    if (!havekids || killed(p)) {
    8000287e:	cf19                	beqz	a4,8000289c <kwait+0xea>
    80002880:	854a                	mv	a0,s2
    80002882:	f07ff0ef          	jal	80002788 <killed>
    80002886:	e919                	bnez	a0,8000289c <kwait+0xea>
    sleep(p, &wait_lock); // DOC: wait-sleep
    80002888:	85e2                	mv	a1,s8
    8000288a:	854a                	mv	a0,s2
    8000288c:	c9fff0ef          	jal	8000252a <sleep>
    havekids = 0;
    80002890:	875e                	mv	a4,s7
    for (pp = proc; pp < &proc[NPROC]; pp++) {
    80002892:	0000e497          	auipc	s1,0xe
    80002896:	7c648493          	addi	s1,s1,1990 # 80011058 <proc>
    8000289a:	b7e1                	j	80002862 <kwait+0xb0>
      release(&wait_lock);
    8000289c:	0000e517          	auipc	a0,0xe
    800028a0:	24c50513          	addi	a0,a0,588 # 80010ae8 <wait_lock>
    800028a4:	cb0fe0ef          	jal	80000d54 <release>
      return -1;
    800028a8:	59fd                	li	s3,-1
    800028aa:	b741                	j	8000282a <kwait+0x78>

00000000800028ac <either_copyout>:

// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int either_copyout(int user_dst, uint64 dst, void *src, uint64 len) {
    800028ac:	7179                	addi	sp,sp,-48
    800028ae:	f406                	sd	ra,40(sp)
    800028b0:	f022                	sd	s0,32(sp)
    800028b2:	ec26                	sd	s1,24(sp)
    800028b4:	e84a                	sd	s2,16(sp)
    800028b6:	e44e                	sd	s3,8(sp)
    800028b8:	e052                	sd	s4,0(sp)
    800028ba:	1800                	addi	s0,sp,48
    800028bc:	84aa                	mv	s1,a0
    800028be:	892e                	mv	s2,a1
    800028c0:	89b2                	mv	s3,a2
    800028c2:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    800028c4:	ba0ff0ef          	jal	80001c64 <myproc>
  if (user_dst) {
    800028c8:	cc99                	beqz	s1,800028e6 <either_copyout+0x3a>
    return copyout(p->pagetable, dst, src, len);
    800028ca:	86d2                	mv	a3,s4
    800028cc:	864e                	mv	a2,s3
    800028ce:	85ca                	mv	a1,s2
    800028d0:	6928                	ld	a0,80(a0)
    800028d2:	81cff0ef          	jal	800018ee <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    800028d6:	70a2                	ld	ra,40(sp)
    800028d8:	7402                	ld	s0,32(sp)
    800028da:	64e2                	ld	s1,24(sp)
    800028dc:	6942                	ld	s2,16(sp)
    800028de:	69a2                	ld	s3,8(sp)
    800028e0:	6a02                	ld	s4,0(sp)
    800028e2:	6145                	addi	sp,sp,48
    800028e4:	8082                	ret
    memmove((char *)dst, src, len);
    800028e6:	000a061b          	sext.w	a2,s4
    800028ea:	85ce                	mv	a1,s3
    800028ec:	854a                	mv	a0,s2
    800028ee:	cfefe0ef          	jal	80000dec <memmove>
    return 0;
    800028f2:	8526                	mv	a0,s1
    800028f4:	b7cd                	j	800028d6 <either_copyout+0x2a>

00000000800028f6 <either_copyin>:

// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int either_copyin(void *dst, int user_src, uint64 src, uint64 len) {
    800028f6:	7179                	addi	sp,sp,-48
    800028f8:	f406                	sd	ra,40(sp)
    800028fa:	f022                	sd	s0,32(sp)
    800028fc:	ec26                	sd	s1,24(sp)
    800028fe:	e84a                	sd	s2,16(sp)
    80002900:	e44e                	sd	s3,8(sp)
    80002902:	e052                	sd	s4,0(sp)
    80002904:	1800                	addi	s0,sp,48
    80002906:	892a                	mv	s2,a0
    80002908:	84ae                	mv	s1,a1
    8000290a:	89b2                	mv	s3,a2
    8000290c:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    8000290e:	b56ff0ef          	jal	80001c64 <myproc>
  if (user_src) {
    80002912:	cc99                	beqz	s1,80002930 <either_copyin+0x3a>
    return copyin(p->pagetable, dst, src, len);
    80002914:	86d2                	mv	a3,s4
    80002916:	864e                	mv	a2,s3
    80002918:	85ca                	mv	a1,s2
    8000291a:	6928                	ld	a0,80(a0)
    8000291c:	8b6ff0ef          	jal	800019d2 <copyin>
  } else {
    memmove(dst, (char *)src, len);
    return 0;
  }
}
    80002920:	70a2                	ld	ra,40(sp)
    80002922:	7402                	ld	s0,32(sp)
    80002924:	64e2                	ld	s1,24(sp)
    80002926:	6942                	ld	s2,16(sp)
    80002928:	69a2                	ld	s3,8(sp)
    8000292a:	6a02                	ld	s4,0(sp)
    8000292c:	6145                	addi	sp,sp,48
    8000292e:	8082                	ret
    memmove(dst, (char *)src, len);
    80002930:	000a061b          	sext.w	a2,s4
    80002934:	85ce                	mv	a1,s3
    80002936:	854a                	mv	a0,s2
    80002938:	cb4fe0ef          	jal	80000dec <memmove>
    return 0;
    8000293c:	8526                	mv	a0,s1
    8000293e:	b7cd                	j	80002920 <either_copyin+0x2a>

0000000080002940 <procdump>:

// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void procdump(void) {
    80002940:	715d                	addi	sp,sp,-80
    80002942:	e486                	sd	ra,72(sp)
    80002944:	e0a2                	sd	s0,64(sp)
    80002946:	fc26                	sd	s1,56(sp)
    80002948:	f84a                	sd	s2,48(sp)
    8000294a:	f44e                	sd	s3,40(sp)
    8000294c:	f052                	sd	s4,32(sp)
    8000294e:	ec56                	sd	s5,24(sp)
    80002950:	e85a                	sd	s6,16(sp)
    80002952:	e45e                	sd	s7,8(sp)
    80002954:	0880                	addi	s0,sp,80
      [UNUSED] "unused",   [USED] "used",      [SLEEPING] "sleep ",
      [RUNNABLE] "runble", [RUNNING] "run   ", [ZOMBIE] "zombie"};
  struct proc *p;
  char *state;

  printf("\n");
    80002956:	00005517          	auipc	a0,0x5
    8000295a:	72a50513          	addi	a0,a0,1834 # 80008080 <etext+0x80>
    8000295e:	bcffd0ef          	jal	8000052c <printf>
  for (p = proc; p < &proc[NPROC]; p++) {
    80002962:	0000f497          	auipc	s1,0xf
    80002966:	84e48493          	addi	s1,s1,-1970 # 800111b0 <proc+0x158>
    8000296a:	00014917          	auipc	s2,0x14
    8000296e:	24690913          	addi	s2,s2,582 # 80016bb0 <bcache+0x140>
    if (p->state == UNUSED)
      continue;
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002972:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    80002974:	00006997          	auipc	s3,0x6
    80002978:	8cc98993          	addi	s3,s3,-1844 # 80008240 <etext+0x240>
    printf("%d %s %s", p->pid, state, p->name);
    8000297c:	00006a97          	auipc	s5,0x6
    80002980:	8cca8a93          	addi	s5,s5,-1844 # 80008248 <etext+0x248>
    printf("\n");
    80002984:	00005a17          	auipc	s4,0x5
    80002988:	6fca0a13          	addi	s4,s4,1788 # 80008080 <etext+0x80>
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000298c:	00006b97          	auipc	s7,0x6
    80002990:	e24b8b93          	addi	s7,s7,-476 # 800087b0 <states.0>
    80002994:	a829                	j	800029ae <procdump+0x6e>
    printf("%d %s %s", p->pid, state, p->name);
    80002996:	edc6a583          	lw	a1,-292(a3)
    8000299a:	8556                	mv	a0,s5
    8000299c:	b91fd0ef          	jal	8000052c <printf>
    printf("\n");
    800029a0:	8552                	mv	a0,s4
    800029a2:	b8bfd0ef          	jal	8000052c <printf>
  for (p = proc; p < &proc[NPROC]; p++) {
    800029a6:	16848493          	addi	s1,s1,360
    800029aa:	03248263          	beq	s1,s2,800029ce <procdump+0x8e>
    if (p->state == UNUSED)
    800029ae:	86a6                	mv	a3,s1
    800029b0:	ec04a783          	lw	a5,-320(s1)
    800029b4:	dbed                	beqz	a5,800029a6 <procdump+0x66>
      state = "???";
    800029b6:	864e                	mv	a2,s3
    if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800029b8:	fcfb6fe3          	bltu	s6,a5,80002996 <procdump+0x56>
    800029bc:	02079713          	slli	a4,a5,0x20
    800029c0:	01d75793          	srli	a5,a4,0x1d
    800029c4:	97de                	add	a5,a5,s7
    800029c6:	6390                	ld	a2,0(a5)
    800029c8:	f679                	bnez	a2,80002996 <procdump+0x56>
      state = "???";
    800029ca:	864e                	mv	a2,s3
    800029cc:	b7e9                	j	80002996 <procdump+0x56>
  }
}
    800029ce:	60a6                	ld	ra,72(sp)
    800029d0:	6406                	ld	s0,64(sp)
    800029d2:	74e2                	ld	s1,56(sp)
    800029d4:	7942                	ld	s2,48(sp)
    800029d6:	79a2                	ld	s3,40(sp)
    800029d8:	7a02                	ld	s4,32(sp)
    800029da:	6ae2                	ld	s5,24(sp)
    800029dc:	6b42                	ld	s6,16(sp)
    800029de:	6ba2                	ld	s7,8(sp)
    800029e0:	6161                	addi	sp,sp,80
    800029e2:	8082                	ret

00000000800029e4 <swtch>:
# Save current registers in old. Load from new.	


.globl swtch
swtch:
        sd ra, 0(a0)
    800029e4:	00153023          	sd	ra,0(a0)
        sd sp, 8(a0)
    800029e8:	00253423          	sd	sp,8(a0)
        sd s0, 16(a0)
    800029ec:	e900                	sd	s0,16(a0)
        sd s1, 24(a0)
    800029ee:	ed04                	sd	s1,24(a0)
        sd s2, 32(a0)
    800029f0:	03253023          	sd	s2,32(a0)
        sd s3, 40(a0)
    800029f4:	03353423          	sd	s3,40(a0)
        sd s4, 48(a0)
    800029f8:	03453823          	sd	s4,48(a0)
        sd s5, 56(a0)
    800029fc:	03553c23          	sd	s5,56(a0)
        sd s6, 64(a0)
    80002a00:	05653023          	sd	s6,64(a0)
        sd s7, 72(a0)
    80002a04:	05753423          	sd	s7,72(a0)
        sd s8, 80(a0)
    80002a08:	05853823          	sd	s8,80(a0)
        sd s9, 88(a0)
    80002a0c:	05953c23          	sd	s9,88(a0)
        sd s10, 96(a0)
    80002a10:	07a53023          	sd	s10,96(a0)
        sd s11, 104(a0)
    80002a14:	07b53423          	sd	s11,104(a0)

        ld ra, 0(a1)
    80002a18:	0005b083          	ld	ra,0(a1)
        ld sp, 8(a1)
    80002a1c:	0085b103          	ld	sp,8(a1)
        ld s0, 16(a1)
    80002a20:	6980                	ld	s0,16(a1)
        ld s1, 24(a1)
    80002a22:	6d84                	ld	s1,24(a1)
        ld s2, 32(a1)
    80002a24:	0205b903          	ld	s2,32(a1)
        ld s3, 40(a1)
    80002a28:	0285b983          	ld	s3,40(a1)
        ld s4, 48(a1)
    80002a2c:	0305ba03          	ld	s4,48(a1)
        ld s5, 56(a1)
    80002a30:	0385ba83          	ld	s5,56(a1)
        ld s6, 64(a1)
    80002a34:	0405bb03          	ld	s6,64(a1)
        ld s7, 72(a1)
    80002a38:	0485bb83          	ld	s7,72(a1)
        ld s8, 80(a1)
    80002a3c:	0505bc03          	ld	s8,80(a1)
        ld s9, 88(a1)
    80002a40:	0585bc83          	ld	s9,88(a1)
        ld s10, 96(a1)
    80002a44:	0605bd03          	ld	s10,96(a1)
        ld s11, 104(a1)
    80002a48:	0685bd83          	ld	s11,104(a1)
        
        ret
    80002a4c:	8082                	ret

0000000080002a4e <trapinit>:

extern int devintr();

void
trapinit(void)
{
    80002a4e:	1141                	addi	sp,sp,-16
    80002a50:	e406                	sd	ra,8(sp)
    80002a52:	e022                	sd	s0,0(sp)
    80002a54:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    80002a56:	00006597          	auipc	a1,0x6
    80002a5a:	83258593          	addi	a1,a1,-1998 # 80008288 <etext+0x288>
    80002a5e:	00014517          	auipc	a0,0x14
    80002a62:	ffa50513          	addi	a0,a0,-6 # 80016a58 <tickslock>
    80002a66:	9d6fe0ef          	jal	80000c3c <initlock>
}
    80002a6a:	60a2                	ld	ra,8(sp)
    80002a6c:	6402                	ld	s0,0(sp)
    80002a6e:	0141                	addi	sp,sp,16
    80002a70:	8082                	ret

0000000080002a72 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    80002a72:	1141                	addi	sp,sp,-16
    80002a74:	e422                	sd	s0,8(sp)
    80002a76:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002a78:	00003797          	auipc	a5,0x3
    80002a7c:	23878793          	addi	a5,a5,568 # 80005cb0 <kernelvec>
    80002a80:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    80002a84:	6422                	ld	s0,8(sp)
    80002a86:	0141                	addi	sp,sp,16
    80002a88:	8082                	ret

0000000080002a8a <prepare_return>:
//
// set up trapframe and control registers for a return to user space
//
void
prepare_return(void)
{
    80002a8a:	1141                	addi	sp,sp,-16
    80002a8c:	e406                	sd	ra,8(sp)
    80002a8e:	e022                	sd	s0,0(sp)
    80002a90:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    80002a92:	9d2ff0ef          	jal	80001c64 <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002a96:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80002a9a:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002a9c:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(). because a trap from kernel
  // code to usertrap would be a disaster, turn off interrupts.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    80002aa0:	04000737          	lui	a4,0x4000
    80002aa4:	177d                	addi	a4,a4,-1 # 3ffffff <_entry-0x7c000001>
    80002aa6:	0732                	slli	a4,a4,0xc
    80002aa8:	00004797          	auipc	a5,0x4
    80002aac:	55878793          	addi	a5,a5,1368 # 80007000 <_trampoline>
    80002ab0:	00004697          	auipc	a3,0x4
    80002ab4:	55068693          	addi	a3,a3,1360 # 80007000 <_trampoline>
    80002ab8:	8f95                	sub	a5,a5,a3
    80002aba:	97ba                	add	a5,a5,a4
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002abc:	10579073          	csrw	stvec,a5
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    80002ac0:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    80002ac2:	18002773          	csrr	a4,satp
    80002ac6:	e398                	sd	a4,0(a5)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    80002ac8:	6d38                	ld	a4,88(a0)
    80002aca:	613c                	ld	a5,64(a0)
    80002acc:	6685                	lui	a3,0x1
    80002ace:	97b6                	add	a5,a5,a3
    80002ad0:	e71c                	sd	a5,8(a4)
  p->trapframe->kernel_trap = (uint64)usertrap;
    80002ad2:	6d3c                	ld	a5,88(a0)
    80002ad4:	00000717          	auipc	a4,0x0
    80002ad8:	0f870713          	addi	a4,a4,248 # 80002bcc <usertrap>
    80002adc:	eb98                	sd	a4,16(a5)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    80002ade:	6d3c                	ld	a5,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    80002ae0:	8712                	mv	a4,tp
    80002ae2:	f398                	sd	a4,32(a5)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002ae4:	100027f3          	csrr	a5,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    80002ae8:	eff7f793          	andi	a5,a5,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    80002aec:	0207e793          	ori	a5,a5,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002af0:	10079073          	csrw	sstatus,a5
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    80002af4:	6d3c                	ld	a5,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002af6:	6f9c                	ld	a5,24(a5)
    80002af8:	14179073          	csrw	sepc,a5
}
    80002afc:	60a2                	ld	ra,8(sp)
    80002afe:	6402                	ld	s0,0(sp)
    80002b00:	0141                	addi	sp,sp,16
    80002b02:	8082                	ret

0000000080002b04 <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    80002b04:	1101                	addi	sp,sp,-32
    80002b06:	ec06                	sd	ra,24(sp)
    80002b08:	e822                	sd	s0,16(sp)
    80002b0a:	1000                	addi	s0,sp,32
  if(cpuid() == 0){
    80002b0c:	926ff0ef          	jal	80001c32 <cpuid>
    80002b10:	cd11                	beqz	a0,80002b2c <clockintr+0x28>
  asm volatile("csrr %0, time" : "=r" (x) );
    80002b12:	c01027f3          	rdtime	a5
  }

  // ask for the next timer interrupt. this also clears
  // the interrupt request. 1000000 is about a tenth
  // of a second.
  w_stimecmp(r_time() + 1000000);
    80002b16:	000f4737          	lui	a4,0xf4
    80002b1a:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    80002b1e:	97ba                	add	a5,a5,a4
  asm volatile("csrw 0x14d, %0" : : "r" (x));
    80002b20:	14d79073          	csrw	stimecmp,a5
}
    80002b24:	60e2                	ld	ra,24(sp)
    80002b26:	6442                	ld	s0,16(sp)
    80002b28:	6105                	addi	sp,sp,32
    80002b2a:	8082                	ret
    80002b2c:	e426                	sd	s1,8(sp)
    acquire(&tickslock);
    80002b2e:	00014497          	auipc	s1,0x14
    80002b32:	f2a48493          	addi	s1,s1,-214 # 80016a58 <tickslock>
    80002b36:	8526                	mv	a0,s1
    80002b38:	984fe0ef          	jal	80000cbc <acquire>
    ticks++;
    80002b3c:	00006517          	auipc	a0,0x6
    80002b40:	df450513          	addi	a0,a0,-524 # 80008930 <ticks>
    80002b44:	411c                	lw	a5,0(a0)
    80002b46:	2785                	addiw	a5,a5,1
    80002b48:	c11c                	sw	a5,0(a0)
    wakeup(&ticks);
    80002b4a:	a31ff0ef          	jal	8000257a <wakeup>
    release(&tickslock);
    80002b4e:	8526                	mv	a0,s1
    80002b50:	a04fe0ef          	jal	80000d54 <release>
    80002b54:	64a2                	ld	s1,8(sp)
    80002b56:	bf75                	j	80002b12 <clockintr+0xe>

0000000080002b58 <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    80002b58:	1101                	addi	sp,sp,-32
    80002b5a:	ec06                	sd	ra,24(sp)
    80002b5c:	e822                	sd	s0,16(sp)
    80002b5e:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002b60:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if(scause == 0x8000000000000009L){
    80002b64:	57fd                	li	a5,-1
    80002b66:	17fe                	slli	a5,a5,0x3f
    80002b68:	07a5                	addi	a5,a5,9
    80002b6a:	00f70c63          	beq	a4,a5,80002b82 <devintr+0x2a>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000005L){
    80002b6e:	57fd                	li	a5,-1
    80002b70:	17fe                	slli	a5,a5,0x3f
    80002b72:	0795                	addi	a5,a5,5
    // timer interrupt.
    clockintr();
    return 2;
  } else {
    return 0;
    80002b74:	4501                	li	a0,0
  } else if(scause == 0x8000000000000005L){
    80002b76:	04f70763          	beq	a4,a5,80002bc4 <devintr+0x6c>
  }
}
    80002b7a:	60e2                	ld	ra,24(sp)
    80002b7c:	6442                	ld	s0,16(sp)
    80002b7e:	6105                	addi	sp,sp,32
    80002b80:	8082                	ret
    80002b82:	e426                	sd	s1,8(sp)
    int irq = plic_claim();
    80002b84:	1d8030ef          	jal	80005d5c <plic_claim>
    80002b88:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    80002b8a:	47a9                	li	a5,10
    80002b8c:	00f50963          	beq	a0,a5,80002b9e <devintr+0x46>
    } else if(irq == VIRTIO0_IRQ){
    80002b90:	4785                	li	a5,1
    80002b92:	00f50963          	beq	a0,a5,80002ba4 <devintr+0x4c>
    return 1;
    80002b96:	4505                	li	a0,1
    } else if(irq){
    80002b98:	e889                	bnez	s1,80002baa <devintr+0x52>
    80002b9a:	64a2                	ld	s1,8(sp)
    80002b9c:	bff9                	j	80002b7a <devintr+0x22>
      uartintr();
    80002b9e:	e45fd0ef          	jal	800009e2 <uartintr>
    if(irq)
    80002ba2:	a819                	j	80002bb8 <devintr+0x60>
      virtio_disk_intr();
    80002ba4:	67e030ef          	jal	80006222 <virtio_disk_intr>
    if(irq)
    80002ba8:	a801                	j	80002bb8 <devintr+0x60>
      printf("unexpected interrupt irq=%d\n", irq);
    80002baa:	85a6                	mv	a1,s1
    80002bac:	00005517          	auipc	a0,0x5
    80002bb0:	6e450513          	addi	a0,a0,1764 # 80008290 <etext+0x290>
    80002bb4:	979fd0ef          	jal	8000052c <printf>
      plic_complete(irq);
    80002bb8:	8526                	mv	a0,s1
    80002bba:	1c2030ef          	jal	80005d7c <plic_complete>
    return 1;
    80002bbe:	4505                	li	a0,1
    80002bc0:	64a2                	ld	s1,8(sp)
    80002bc2:	bf65                	j	80002b7a <devintr+0x22>
    clockintr();
    80002bc4:	f41ff0ef          	jal	80002b04 <clockintr>
    return 2;
    80002bc8:	4509                	li	a0,2
    80002bca:	bf45                	j	80002b7a <devintr+0x22>

0000000080002bcc <usertrap>:
{
    80002bcc:	1101                	addi	sp,sp,-32
    80002bce:	ec06                	sd	ra,24(sp)
    80002bd0:	e822                	sd	s0,16(sp)
    80002bd2:	e426                	sd	s1,8(sp)
    80002bd4:	e04a                	sd	s2,0(sp)
    80002bd6:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002bd8:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    80002bdc:	1007f793          	andi	a5,a5,256
    80002be0:	eba5                	bnez	a5,80002c50 <usertrap+0x84>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002be2:	00003797          	auipc	a5,0x3
    80002be6:	0ce78793          	addi	a5,a5,206 # 80005cb0 <kernelvec>
    80002bea:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80002bee:	876ff0ef          	jal	80001c64 <myproc>
    80002bf2:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    80002bf4:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002bf6:	14102773          	csrr	a4,sepc
    80002bfa:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002bfc:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    80002c00:	47a1                	li	a5,8
    80002c02:	04f70d63          	beq	a4,a5,80002c5c <usertrap+0x90>
  } else if((which_dev = devintr()) != 0){
    80002c06:	f53ff0ef          	jal	80002b58 <devintr>
    80002c0a:	892a                	mv	s2,a0
    80002c0c:	e945                	bnez	a0,80002cbc <usertrap+0xf0>
    80002c0e:	14202773          	csrr	a4,scause
  } else if((r_scause() == 15 || r_scause() == 13) &&
    80002c12:	47bd                	li	a5,15
    80002c14:	08f70863          	beq	a4,a5,80002ca4 <usertrap+0xd8>
    80002c18:	14202773          	csrr	a4,scause
    80002c1c:	47b5                	li	a5,13
    80002c1e:	08f70363          	beq	a4,a5,80002ca4 <usertrap+0xd8>
    80002c22:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause 0x%lx pid=%d\n", r_scause(), p->pid);
    80002c26:	58d0                	lw	a2,52(s1)
    80002c28:	00005517          	auipc	a0,0x5
    80002c2c:	6a850513          	addi	a0,a0,1704 # 800082d0 <etext+0x2d0>
    80002c30:	8fdfd0ef          	jal	8000052c <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002c34:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002c38:	14302673          	csrr	a2,stval
    printf("            sepc=0x%lx stval=0x%lx\n", r_sepc(), r_stval());
    80002c3c:	00005517          	auipc	a0,0x5
    80002c40:	6c450513          	addi	a0,a0,1732 # 80008300 <etext+0x300>
    80002c44:	8e9fd0ef          	jal	8000052c <printf>
    setkilled(p);
    80002c48:	8526                	mv	a0,s1
    80002c4a:	b1bff0ef          	jal	80002764 <setkilled>
    80002c4e:	a035                	j	80002c7a <usertrap+0xae>
    panic("usertrap: not from user mode");
    80002c50:	00005517          	auipc	a0,0x5
    80002c54:	66050513          	addi	a0,a0,1632 # 800082b0 <etext+0x2b0>
    80002c58:	bbbfd0ef          	jal	80000812 <panic>
    if(killed(p))
    80002c5c:	b2dff0ef          	jal	80002788 <killed>
    80002c60:	ed15                	bnez	a0,80002c9c <usertrap+0xd0>
    p->trapframe->epc += 4;
    80002c62:	6cb8                	ld	a4,88(s1)
    80002c64:	6f1c                	ld	a5,24(a4)
    80002c66:	0791                	addi	a5,a5,4
    80002c68:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002c6a:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002c6e:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002c72:	10079073          	csrw	sstatus,a5
    syscall();
    80002c76:	246000ef          	jal	80002ebc <syscall>
  if(killed(p))
    80002c7a:	8526                	mv	a0,s1
    80002c7c:	b0dff0ef          	jal	80002788 <killed>
    80002c80:	e139                	bnez	a0,80002cc6 <usertrap+0xfa>
  prepare_return();
    80002c82:	e09ff0ef          	jal	80002a8a <prepare_return>
  uint64 satp = MAKE_SATP(p->pagetable);
    80002c86:	68a8                	ld	a0,80(s1)
    80002c88:	8131                	srli	a0,a0,0xc
    80002c8a:	57fd                	li	a5,-1
    80002c8c:	17fe                	slli	a5,a5,0x3f
    80002c8e:	8d5d                	or	a0,a0,a5
}
    80002c90:	60e2                	ld	ra,24(sp)
    80002c92:	6442                	ld	s0,16(sp)
    80002c94:	64a2                	ld	s1,8(sp)
    80002c96:	6902                	ld	s2,0(sp)
    80002c98:	6105                	addi	sp,sp,32
    80002c9a:	8082                	ret
      kexit(-1);
    80002c9c:	557d                	li	a0,-1
    80002c9e:	99bff0ef          	jal	80002638 <kexit>
    80002ca2:	b7c1                	j	80002c62 <usertrap+0x96>
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002ca4:	143025f3          	csrr	a1,stval
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002ca8:	14202673          	csrr	a2,scause
            vmfault(p->pagetable, r_stval(), (r_scause() == 13)? 1 : 0) != 0) {
    80002cac:	164d                	addi	a2,a2,-13 # ff3 <_entry-0x7ffff00d>
    80002cae:	00163613          	seqz	a2,a2
    80002cb2:	68a8                	ld	a0,80(s1)
    80002cb4:	b5bfe0ef          	jal	8000180e <vmfault>
  } else if((r_scause() == 15 || r_scause() == 13) &&
    80002cb8:	f169                	bnez	a0,80002c7a <usertrap+0xae>
    80002cba:	b7a5                	j	80002c22 <usertrap+0x56>
  if(killed(p))
    80002cbc:	8526                	mv	a0,s1
    80002cbe:	acbff0ef          	jal	80002788 <killed>
    80002cc2:	c511                	beqz	a0,80002cce <usertrap+0x102>
    80002cc4:	a011                	j	80002cc8 <usertrap+0xfc>
    80002cc6:	4901                	li	s2,0
    kexit(-1);
    80002cc8:	557d                	li	a0,-1
    80002cca:	96fff0ef          	jal	80002638 <kexit>
  if(which_dev == 2)
    80002cce:	4789                	li	a5,2
    80002cd0:	faf919e3          	bne	s2,a5,80002c82 <usertrap+0xb6>
    yield();
    80002cd4:	827ff0ef          	jal	800024fa <yield>
    80002cd8:	b76d                	j	80002c82 <usertrap+0xb6>

0000000080002cda <kerneltrap>:
{
    80002cda:	7179                	addi	sp,sp,-48
    80002cdc:	f406                	sd	ra,40(sp)
    80002cde:	f022                	sd	s0,32(sp)
    80002ce0:	ec26                	sd	s1,24(sp)
    80002ce2:	e84a                	sd	s2,16(sp)
    80002ce4:	e44e                	sd	s3,8(sp)
    80002ce6:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002ce8:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002cec:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002cf0:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    80002cf4:	1004f793          	andi	a5,s1,256
    80002cf8:	c795                	beqz	a5,80002d24 <kerneltrap+0x4a>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002cfa:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002cfe:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    80002d00:	eb85                	bnez	a5,80002d30 <kerneltrap+0x56>
  if((which_dev = devintr()) == 0){
    80002d02:	e57ff0ef          	jal	80002b58 <devintr>
    80002d06:	c91d                	beqz	a0,80002d3c <kerneltrap+0x62>
  if(which_dev == 2 && myproc() != 0)
    80002d08:	4789                	li	a5,2
    80002d0a:	04f50a63          	beq	a0,a5,80002d5e <kerneltrap+0x84>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002d0e:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002d12:	10049073          	csrw	sstatus,s1
}
    80002d16:	70a2                	ld	ra,40(sp)
    80002d18:	7402                	ld	s0,32(sp)
    80002d1a:	64e2                	ld	s1,24(sp)
    80002d1c:	6942                	ld	s2,16(sp)
    80002d1e:	69a2                	ld	s3,8(sp)
    80002d20:	6145                	addi	sp,sp,48
    80002d22:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80002d24:	00005517          	auipc	a0,0x5
    80002d28:	60450513          	addi	a0,a0,1540 # 80008328 <etext+0x328>
    80002d2c:	ae7fd0ef          	jal	80000812 <panic>
    panic("kerneltrap: interrupts enabled");
    80002d30:	00005517          	auipc	a0,0x5
    80002d34:	62050513          	addi	a0,a0,1568 # 80008350 <etext+0x350>
    80002d38:	adbfd0ef          	jal	80000812 <panic>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002d3c:	14102673          	csrr	a2,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002d40:	143026f3          	csrr	a3,stval
    printf("scause=0x%lx sepc=0x%lx stval=0x%lx\n", scause, r_sepc(), r_stval());
    80002d44:	85ce                	mv	a1,s3
    80002d46:	00005517          	auipc	a0,0x5
    80002d4a:	62a50513          	addi	a0,a0,1578 # 80008370 <etext+0x370>
    80002d4e:	fdefd0ef          	jal	8000052c <printf>
    panic("kerneltrap");
    80002d52:	00005517          	auipc	a0,0x5
    80002d56:	64650513          	addi	a0,a0,1606 # 80008398 <etext+0x398>
    80002d5a:	ab9fd0ef          	jal	80000812 <panic>
  if(which_dev == 2 && myproc() != 0)
    80002d5e:	f07fe0ef          	jal	80001c64 <myproc>
    80002d62:	d555                	beqz	a0,80002d0e <kerneltrap+0x34>
    yield();
    80002d64:	f96ff0ef          	jal	800024fa <yield>
    80002d68:	b75d                	j	80002d0e <kerneltrap+0x34>

0000000080002d6a <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80002d6a:	1101                	addi	sp,sp,-32
    80002d6c:	ec06                	sd	ra,24(sp)
    80002d6e:	e822                	sd	s0,16(sp)
    80002d70:	e426                	sd	s1,8(sp)
    80002d72:	1000                	addi	s0,sp,32
    80002d74:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002d76:	eeffe0ef          	jal	80001c64 <myproc>
  switch (n) {
    80002d7a:	4795                	li	a5,5
    80002d7c:	0497e163          	bltu	a5,s1,80002dbe <argraw+0x54>
    80002d80:	048a                	slli	s1,s1,0x2
    80002d82:	00006717          	auipc	a4,0x6
    80002d86:	a5e70713          	addi	a4,a4,-1442 # 800087e0 <states.0+0x30>
    80002d8a:	94ba                	add	s1,s1,a4
    80002d8c:	409c                	lw	a5,0(s1)
    80002d8e:	97ba                	add	a5,a5,a4
    80002d90:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    80002d92:	6d3c                	ld	a5,88(a0)
    80002d94:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80002d96:	60e2                	ld	ra,24(sp)
    80002d98:	6442                	ld	s0,16(sp)
    80002d9a:	64a2                	ld	s1,8(sp)
    80002d9c:	6105                	addi	sp,sp,32
    80002d9e:	8082                	ret
    return p->trapframe->a1;
    80002da0:	6d3c                	ld	a5,88(a0)
    80002da2:	7fa8                	ld	a0,120(a5)
    80002da4:	bfcd                	j	80002d96 <argraw+0x2c>
    return p->trapframe->a2;
    80002da6:	6d3c                	ld	a5,88(a0)
    80002da8:	63c8                	ld	a0,128(a5)
    80002daa:	b7f5                	j	80002d96 <argraw+0x2c>
    return p->trapframe->a3;
    80002dac:	6d3c                	ld	a5,88(a0)
    80002dae:	67c8                	ld	a0,136(a5)
    80002db0:	b7dd                	j	80002d96 <argraw+0x2c>
    return p->trapframe->a4;
    80002db2:	6d3c                	ld	a5,88(a0)
    80002db4:	6bc8                	ld	a0,144(a5)
    80002db6:	b7c5                	j	80002d96 <argraw+0x2c>
    return p->trapframe->a5;
    80002db8:	6d3c                	ld	a5,88(a0)
    80002dba:	6fc8                	ld	a0,152(a5)
    80002dbc:	bfe9                	j	80002d96 <argraw+0x2c>
  panic("argraw");
    80002dbe:	00005517          	auipc	a0,0x5
    80002dc2:	5ea50513          	addi	a0,a0,1514 # 800083a8 <etext+0x3a8>
    80002dc6:	a4dfd0ef          	jal	80000812 <panic>

0000000080002dca <fetchaddr>:
{
    80002dca:	1101                	addi	sp,sp,-32
    80002dcc:	ec06                	sd	ra,24(sp)
    80002dce:	e822                	sd	s0,16(sp)
    80002dd0:	e426                	sd	s1,8(sp)
    80002dd2:	e04a                	sd	s2,0(sp)
    80002dd4:	1000                	addi	s0,sp,32
    80002dd6:	84aa                	mv	s1,a0
    80002dd8:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002dda:	e8bfe0ef          	jal	80001c64 <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    80002dde:	653c                	ld	a5,72(a0)
    80002de0:	02f4f663          	bgeu	s1,a5,80002e0c <fetchaddr+0x42>
    80002de4:	00848713          	addi	a4,s1,8
    80002de8:	02e7e463          	bltu	a5,a4,80002e10 <fetchaddr+0x46>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80002dec:	46a1                	li	a3,8
    80002dee:	8626                	mv	a2,s1
    80002df0:	85ca                	mv	a1,s2
    80002df2:	6928                	ld	a0,80(a0)
    80002df4:	bdffe0ef          	jal	800019d2 <copyin>
    80002df8:	00a03533          	snez	a0,a0
    80002dfc:	40a00533          	neg	a0,a0
}
    80002e00:	60e2                	ld	ra,24(sp)
    80002e02:	6442                	ld	s0,16(sp)
    80002e04:	64a2                	ld	s1,8(sp)
    80002e06:	6902                	ld	s2,0(sp)
    80002e08:	6105                	addi	sp,sp,32
    80002e0a:	8082                	ret
    return -1;
    80002e0c:	557d                	li	a0,-1
    80002e0e:	bfcd                	j	80002e00 <fetchaddr+0x36>
    80002e10:	557d                	li	a0,-1
    80002e12:	b7fd                	j	80002e00 <fetchaddr+0x36>

0000000080002e14 <fetchstr>:
{
    80002e14:	7179                	addi	sp,sp,-48
    80002e16:	f406                	sd	ra,40(sp)
    80002e18:	f022                	sd	s0,32(sp)
    80002e1a:	ec26                	sd	s1,24(sp)
    80002e1c:	e84a                	sd	s2,16(sp)
    80002e1e:	e44e                	sd	s3,8(sp)
    80002e20:	1800                	addi	s0,sp,48
    80002e22:	892a                	mv	s2,a0
    80002e24:	84ae                	mv	s1,a1
    80002e26:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80002e28:	e3dfe0ef          	jal	80001c64 <myproc>
  if(copyinstr(p->pagetable, buf, addr, max) < 0)
    80002e2c:	86ce                	mv	a3,s3
    80002e2e:	864a                	mv	a2,s2
    80002e30:	85a6                	mv	a1,s1
    80002e32:	6928                	ld	a0,80(a0)
    80002e34:	903fe0ef          	jal	80001736 <copyinstr>
    80002e38:	00054c63          	bltz	a0,80002e50 <fetchstr+0x3c>
  return strlen(buf);
    80002e3c:	8526                	mv	a0,s1
    80002e3e:	8c2fe0ef          	jal	80000f00 <strlen>
}
    80002e42:	70a2                	ld	ra,40(sp)
    80002e44:	7402                	ld	s0,32(sp)
    80002e46:	64e2                	ld	s1,24(sp)
    80002e48:	6942                	ld	s2,16(sp)
    80002e4a:	69a2                	ld	s3,8(sp)
    80002e4c:	6145                	addi	sp,sp,48
    80002e4e:	8082                	ret
    return -1;
    80002e50:	557d                	li	a0,-1
    80002e52:	bfc5                	j	80002e42 <fetchstr+0x2e>

0000000080002e54 <argint>:

// Fetch the nth 32-bit system call argument.
void
argint(int n, int *ip)
{
    80002e54:	1101                	addi	sp,sp,-32
    80002e56:	ec06                	sd	ra,24(sp)
    80002e58:	e822                	sd	s0,16(sp)
    80002e5a:	e426                	sd	s1,8(sp)
    80002e5c:	1000                	addi	s0,sp,32
    80002e5e:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002e60:	f0bff0ef          	jal	80002d6a <argraw>
    80002e64:	c088                	sw	a0,0(s1)
}
    80002e66:	60e2                	ld	ra,24(sp)
    80002e68:	6442                	ld	s0,16(sp)
    80002e6a:	64a2                	ld	s1,8(sp)
    80002e6c:	6105                	addi	sp,sp,32
    80002e6e:	8082                	ret

0000000080002e70 <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void
argaddr(int n, uint64 *ip)
{
    80002e70:	1101                	addi	sp,sp,-32
    80002e72:	ec06                	sd	ra,24(sp)
    80002e74:	e822                	sd	s0,16(sp)
    80002e76:	e426                	sd	s1,8(sp)
    80002e78:	1000                	addi	s0,sp,32
    80002e7a:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002e7c:	eefff0ef          	jal	80002d6a <argraw>
    80002e80:	e088                	sd	a0,0(s1)
}
    80002e82:	60e2                	ld	ra,24(sp)
    80002e84:	6442                	ld	s0,16(sp)
    80002e86:	64a2                	ld	s1,8(sp)
    80002e88:	6105                	addi	sp,sp,32
    80002e8a:	8082                	ret

0000000080002e8c <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80002e8c:	7179                	addi	sp,sp,-48
    80002e8e:	f406                	sd	ra,40(sp)
    80002e90:	f022                	sd	s0,32(sp)
    80002e92:	ec26                	sd	s1,24(sp)
    80002e94:	e84a                	sd	s2,16(sp)
    80002e96:	1800                	addi	s0,sp,48
    80002e98:	84ae                	mv	s1,a1
    80002e9a:	8932                	mv	s2,a2
  uint64 addr;
  argaddr(n, &addr);
    80002e9c:	fd840593          	addi	a1,s0,-40
    80002ea0:	fd1ff0ef          	jal	80002e70 <argaddr>
  return fetchstr(addr, buf, max);
    80002ea4:	864a                	mv	a2,s2
    80002ea6:	85a6                	mv	a1,s1
    80002ea8:	fd843503          	ld	a0,-40(s0)
    80002eac:	f69ff0ef          	jal	80002e14 <fetchstr>
}
    80002eb0:	70a2                	ld	ra,40(sp)
    80002eb2:	7402                	ld	s0,32(sp)
    80002eb4:	64e2                	ld	s1,24(sp)
    80002eb6:	6942                	ld	s2,16(sp)
    80002eb8:	6145                	addi	sp,sp,48
    80002eba:	8082                	ret

0000000080002ebc <syscall>:

};

void
syscall(void)
{
    80002ebc:	1101                	addi	sp,sp,-32
    80002ebe:	ec06                	sd	ra,24(sp)
    80002ec0:	e822                	sd	s0,16(sp)
    80002ec2:	e426                	sd	s1,8(sp)
    80002ec4:	e04a                	sd	s2,0(sp)
    80002ec6:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    80002ec8:	d9dfe0ef          	jal	80001c64 <myproc>
    80002ecc:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    80002ece:	05853903          	ld	s2,88(a0)
    80002ed2:	0a893783          	ld	a5,168(s2)
    80002ed6:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80002eda:	37fd                	addiw	a5,a5,-1
    80002edc:	4769                	li	a4,26
    80002ede:	00f76f63          	bltu	a4,a5,80002efc <syscall+0x40>
    80002ee2:	00369713          	slli	a4,a3,0x3
    80002ee6:	00006797          	auipc	a5,0x6
    80002eea:	91278793          	addi	a5,a5,-1774 # 800087f8 <syscalls>
    80002eee:	97ba                	add	a5,a5,a4
    80002ef0:	639c                	ld	a5,0(a5)
    80002ef2:	c789                	beqz	a5,80002efc <syscall+0x40>
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    p->trapframe->a0 = syscalls[num]();
    80002ef4:	9782                	jalr	a5
    80002ef6:	06a93823          	sd	a0,112(s2)
    80002efa:	a829                	j	80002f14 <syscall+0x58>
  } else {
    printf("%d %s: unknown sys call %d\n",
    80002efc:	15848613          	addi	a2,s1,344
    80002f00:	58cc                	lw	a1,52(s1)
    80002f02:	00005517          	auipc	a0,0x5
    80002f06:	4ae50513          	addi	a0,a0,1198 # 800083b0 <etext+0x3b0>
    80002f0a:	e22fd0ef          	jal	8000052c <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80002f0e:	6cbc                	ld	a5,88(s1)
    80002f10:	577d                	li	a4,-1
    80002f12:	fbb8                	sd	a4,112(a5)
  }
}
    80002f14:	60e2                	ld	ra,24(sp)
    80002f16:	6442                	ld	s0,16(sp)
    80002f18:	64a2                	ld	s1,8(sp)
    80002f1a:	6902                	ld	s2,0(sp)
    80002f1c:	6105                	addi	sp,sp,32
    80002f1e:	8082                	ret

0000000080002f20 <sys_exit>:
#include "vm.h"
#include "schedlog.h"

uint64
sys_exit(void)
{
    80002f20:	1101                	addi	sp,sp,-32
    80002f22:	ec06                	sd	ra,24(sp)
    80002f24:	e822                	sd	s0,16(sp)
    80002f26:	1000                	addi	s0,sp,32
  int n;
  argint(0, &n);
    80002f28:	fec40593          	addi	a1,s0,-20
    80002f2c:	4501                	li	a0,0
    80002f2e:	f27ff0ef          	jal	80002e54 <argint>
  kexit(n);
    80002f32:	fec42503          	lw	a0,-20(s0)
    80002f36:	f02ff0ef          	jal	80002638 <kexit>
  return 0;  // not reached
}
    80002f3a:	4501                	li	a0,0
    80002f3c:	60e2                	ld	ra,24(sp)
    80002f3e:	6442                	ld	s0,16(sp)
    80002f40:	6105                	addi	sp,sp,32
    80002f42:	8082                	ret

0000000080002f44 <sys_getpid>:

uint64
sys_getpid(void)
{
    80002f44:	1141                	addi	sp,sp,-16
    80002f46:	e406                	sd	ra,8(sp)
    80002f48:	e022                	sd	s0,0(sp)
    80002f4a:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80002f4c:	d19fe0ef          	jal	80001c64 <myproc>
}
    80002f50:	5948                	lw	a0,52(a0)
    80002f52:	60a2                	ld	ra,8(sp)
    80002f54:	6402                	ld	s0,0(sp)
    80002f56:	0141                	addi	sp,sp,16
    80002f58:	8082                	ret

0000000080002f5a <sys_fork>:

uint64
sys_fork(void)
{
    80002f5a:	1141                	addi	sp,sp,-16
    80002f5c:	e406                	sd	ra,8(sp)
    80002f5e:	e022                	sd	s0,0(sp)
    80002f60:	0800                	addi	s0,sp,16
  return kfork();
    80002f62:	906ff0ef          	jal	80002068 <kfork>
}
    80002f66:	60a2                	ld	ra,8(sp)
    80002f68:	6402                	ld	s0,0(sp)
    80002f6a:	0141                	addi	sp,sp,16
    80002f6c:	8082                	ret

0000000080002f6e <sys_wait>:

uint64
sys_wait(void)
{
    80002f6e:	1101                	addi	sp,sp,-32
    80002f70:	ec06                	sd	ra,24(sp)
    80002f72:	e822                	sd	s0,16(sp)
    80002f74:	1000                	addi	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    80002f76:	fe840593          	addi	a1,s0,-24
    80002f7a:	4501                	li	a0,0
    80002f7c:	ef5ff0ef          	jal	80002e70 <argaddr>
  return kwait(p);
    80002f80:	fe843503          	ld	a0,-24(s0)
    80002f84:	82fff0ef          	jal	800027b2 <kwait>
}
    80002f88:	60e2                	ld	ra,24(sp)
    80002f8a:	6442                	ld	s0,16(sp)
    80002f8c:	6105                	addi	sp,sp,32
    80002f8e:	8082                	ret

0000000080002f90 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80002f90:	7179                	addi	sp,sp,-48
    80002f92:	f406                	sd	ra,40(sp)
    80002f94:	f022                	sd	s0,32(sp)
    80002f96:	ec26                	sd	s1,24(sp)
    80002f98:	1800                	addi	s0,sp,48
  uint64 addr;
  int t;
  int n;

  argint(0, &n);
    80002f9a:	fd840593          	addi	a1,s0,-40
    80002f9e:	4501                	li	a0,0
    80002fa0:	eb5ff0ef          	jal	80002e54 <argint>
  argint(1, &t);
    80002fa4:	fdc40593          	addi	a1,s0,-36
    80002fa8:	4505                	li	a0,1
    80002faa:	eabff0ef          	jal	80002e54 <argint>
  addr = myproc()->sz;
    80002fae:	cb7fe0ef          	jal	80001c64 <myproc>
    80002fb2:	6524                	ld	s1,72(a0)

  if(t == SBRK_EAGER || n < 0) {
    80002fb4:	fdc42703          	lw	a4,-36(s0)
    80002fb8:	4785                	li	a5,1
    80002fba:	02f70763          	beq	a4,a5,80002fe8 <sys_sbrk+0x58>
    80002fbe:	fd842783          	lw	a5,-40(s0)
    80002fc2:	0207c363          	bltz	a5,80002fe8 <sys_sbrk+0x58>
    }
  } else {
    // Lazily allocate memory for this process: increase its memory
    // size but don't allocate memory. If the processes uses the
    // memory, vmfault() will allocate it.
    if(addr + n < addr)
    80002fc6:	97a6                	add	a5,a5,s1
    80002fc8:	0297ee63          	bltu	a5,s1,80003004 <sys_sbrk+0x74>
      return -1;
    if(addr + n > TRAPFRAME)
    80002fcc:	02000737          	lui	a4,0x2000
    80002fd0:	177d                	addi	a4,a4,-1 # 1ffffff <_entry-0x7e000001>
    80002fd2:	0736                	slli	a4,a4,0xd
    80002fd4:	02f76a63          	bltu	a4,a5,80003008 <sys_sbrk+0x78>
      return -1;
    myproc()->sz += n;
    80002fd8:	c8dfe0ef          	jal	80001c64 <myproc>
    80002fdc:	fd842703          	lw	a4,-40(s0)
    80002fe0:	653c                	ld	a5,72(a0)
    80002fe2:	97ba                	add	a5,a5,a4
    80002fe4:	e53c                	sd	a5,72(a0)
    80002fe6:	a039                	j	80002ff4 <sys_sbrk+0x64>
    if(growproc(n) < 0) {
    80002fe8:	fd842503          	lw	a0,-40(s0)
    80002fec:	faffe0ef          	jal	80001f9a <growproc>
    80002ff0:	00054863          	bltz	a0,80003000 <sys_sbrk+0x70>
  }
  return addr;
}
    80002ff4:	8526                	mv	a0,s1
    80002ff6:	70a2                	ld	ra,40(sp)
    80002ff8:	7402                	ld	s0,32(sp)
    80002ffa:	64e2                	ld	s1,24(sp)
    80002ffc:	6145                	addi	sp,sp,48
    80002ffe:	8082                	ret
      return -1;
    80003000:	54fd                	li	s1,-1
    80003002:	bfcd                	j	80002ff4 <sys_sbrk+0x64>
      return -1;
    80003004:	54fd                	li	s1,-1
    80003006:	b7fd                	j	80002ff4 <sys_sbrk+0x64>
      return -1;
    80003008:	54fd                	li	s1,-1
    8000300a:	b7ed                	j	80002ff4 <sys_sbrk+0x64>

000000008000300c <sys_pause>:

uint64
sys_pause(void)
{
    8000300c:	7139                	addi	sp,sp,-64
    8000300e:	fc06                	sd	ra,56(sp)
    80003010:	f822                	sd	s0,48(sp)
    80003012:	f04a                	sd	s2,32(sp)
    80003014:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    80003016:	fcc40593          	addi	a1,s0,-52
    8000301a:	4501                	li	a0,0
    8000301c:	e39ff0ef          	jal	80002e54 <argint>
  if(n < 0)
    80003020:	fcc42783          	lw	a5,-52(s0)
    80003024:	0607c763          	bltz	a5,80003092 <sys_pause+0x86>
    n = 0;
  acquire(&tickslock);
    80003028:	00014517          	auipc	a0,0x14
    8000302c:	a3050513          	addi	a0,a0,-1488 # 80016a58 <tickslock>
    80003030:	c8dfd0ef          	jal	80000cbc <acquire>
  ticks0 = ticks;
    80003034:	00006917          	auipc	s2,0x6
    80003038:	8fc92903          	lw	s2,-1796(s2) # 80008930 <ticks>
  while(ticks - ticks0 < n){
    8000303c:	fcc42783          	lw	a5,-52(s0)
    80003040:	cf8d                	beqz	a5,8000307a <sys_pause+0x6e>
    80003042:	f426                	sd	s1,40(sp)
    80003044:	ec4e                	sd	s3,24(sp)
    if(killed(myproc())){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80003046:	00014997          	auipc	s3,0x14
    8000304a:	a1298993          	addi	s3,s3,-1518 # 80016a58 <tickslock>
    8000304e:	00006497          	auipc	s1,0x6
    80003052:	8e248493          	addi	s1,s1,-1822 # 80008930 <ticks>
    if(killed(myproc())){
    80003056:	c0ffe0ef          	jal	80001c64 <myproc>
    8000305a:	f2eff0ef          	jal	80002788 <killed>
    8000305e:	ed0d                	bnez	a0,80003098 <sys_pause+0x8c>
    sleep(&ticks, &tickslock);
    80003060:	85ce                	mv	a1,s3
    80003062:	8526                	mv	a0,s1
    80003064:	cc6ff0ef          	jal	8000252a <sleep>
  while(ticks - ticks0 < n){
    80003068:	409c                	lw	a5,0(s1)
    8000306a:	412787bb          	subw	a5,a5,s2
    8000306e:	fcc42703          	lw	a4,-52(s0)
    80003072:	fee7e2e3          	bltu	a5,a4,80003056 <sys_pause+0x4a>
    80003076:	74a2                	ld	s1,40(sp)
    80003078:	69e2                	ld	s3,24(sp)
  }
  release(&tickslock);
    8000307a:	00014517          	auipc	a0,0x14
    8000307e:	9de50513          	addi	a0,a0,-1570 # 80016a58 <tickslock>
    80003082:	cd3fd0ef          	jal	80000d54 <release>
  return 0;
    80003086:	4501                	li	a0,0
}
    80003088:	70e2                	ld	ra,56(sp)
    8000308a:	7442                	ld	s0,48(sp)
    8000308c:	7902                	ld	s2,32(sp)
    8000308e:	6121                	addi	sp,sp,64
    80003090:	8082                	ret
    n = 0;
    80003092:	fc042623          	sw	zero,-52(s0)
    80003096:	bf49                	j	80003028 <sys_pause+0x1c>
      release(&tickslock);
    80003098:	00014517          	auipc	a0,0x14
    8000309c:	9c050513          	addi	a0,a0,-1600 # 80016a58 <tickslock>
    800030a0:	cb5fd0ef          	jal	80000d54 <release>
      return -1;
    800030a4:	557d                	li	a0,-1
    800030a6:	74a2                	ld	s1,40(sp)
    800030a8:	69e2                	ld	s3,24(sp)
    800030aa:	bff9                	j	80003088 <sys_pause+0x7c>

00000000800030ac <sys_kill>:

uint64
sys_kill(void)
{
    800030ac:	1101                	addi	sp,sp,-32
    800030ae:	ec06                	sd	ra,24(sp)
    800030b0:	e822                	sd	s0,16(sp)
    800030b2:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    800030b4:	fec40593          	addi	a1,s0,-20
    800030b8:	4501                	li	a0,0
    800030ba:	d9bff0ef          	jal	80002e54 <argint>
  return kkill(pid);
    800030be:	fec42503          	lw	a0,-20(s0)
    800030c2:	e3cff0ef          	jal	800026fe <kkill>
}
    800030c6:	60e2                	ld	ra,24(sp)
    800030c8:	6442                	ld	s0,16(sp)
    800030ca:	6105                	addi	sp,sp,32
    800030cc:	8082                	ret

00000000800030ce <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    800030ce:	1101                	addi	sp,sp,-32
    800030d0:	ec06                	sd	ra,24(sp)
    800030d2:	e822                	sd	s0,16(sp)
    800030d4:	e426                	sd	s1,8(sp)
    800030d6:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    800030d8:	00014517          	auipc	a0,0x14
    800030dc:	98050513          	addi	a0,a0,-1664 # 80016a58 <tickslock>
    800030e0:	bddfd0ef          	jal	80000cbc <acquire>
  xticks = ticks;
    800030e4:	00006497          	auipc	s1,0x6
    800030e8:	84c4a483          	lw	s1,-1972(s1) # 80008930 <ticks>
  release(&tickslock);
    800030ec:	00014517          	auipc	a0,0x14
    800030f0:	96c50513          	addi	a0,a0,-1684 # 80016a58 <tickslock>
    800030f4:	c61fd0ef          	jal	80000d54 <release>
  return xticks;
}
    800030f8:	02049513          	slli	a0,s1,0x20
    800030fc:	9101                	srli	a0,a0,0x20
    800030fe:	60e2                	ld	ra,24(sp)
    80003100:	6442                	ld	s0,16(sp)
    80003102:	64a2                	ld	s1,8(sp)
    80003104:	6105                	addi	sp,sp,32
    80003106:	8082                	ret

0000000080003108 <sys_schedread>:

uint64
sys_schedread(void)
{
    80003108:	7131                	addi	sp,sp,-192
    8000310a:	fd06                	sd	ra,184(sp)
    8000310c:	f922                	sd	s0,176(sp)
    8000310e:	f526                	sd	s1,168(sp)
    80003110:	f14a                	sd	s2,160(sp)
    80003112:	0180                	addi	s0,sp,192
    80003114:	81010113          	addi	sp,sp,-2032
  uint64 dst;
  int max;

  argaddr(0, &dst);
    80003118:	fd840593          	addi	a1,s0,-40
    8000311c:	4501                	li	a0,0
    8000311e:	d53ff0ef          	jal	80002e70 <argaddr>
  argint(1, &max);
    80003122:	fd440593          	addi	a1,s0,-44
    80003126:	4505                	li	a0,1
    80003128:	d2dff0ef          	jal	80002e54 <argint>

  if(max <= 0)
    8000312c:	fd442783          	lw	a5,-44(s0)
    return 0;
    80003130:	4901                	li	s2,0
  if(max <= 0)
    80003132:	04f05a63          	blez	a5,80003186 <sys_schedread+0x7e>

  struct sched_event buf[32];
  if(max > 32)
    80003136:	02000713          	li	a4,32
    8000313a:	00f75663          	bge	a4,a5,80003146 <sys_schedread+0x3e>
    max = 32;
    8000313e:	02000793          	li	a5,32
    80003142:	fcf42a23          	sw	a5,-44(s0)

  int n = schedread(buf, max);
    80003146:	757d                	lui	a0,0xfffff
    80003148:	fd442583          	lw	a1,-44(s0)
    8000314c:	75050793          	addi	a5,a0,1872 # fffffffffffff750 <end+0xffffffff7ffb8870>
    80003150:	00878533          	add	a0,a5,s0
    80003154:	0e1030ef          	jal	80006a34 <schedread>
    80003158:	84aa                	mv	s1,a0
  if(n < 0)
    return -1;
    8000315a:	597d                	li	s2,-1
  if(n < 0)
    8000315c:	02054563          	bltz	a0,80003186 <sys_schedread+0x7e>

  if(copyout(myproc()->pagetable, dst, (char *)buf, n * sizeof(struct sched_event)) < 0)
    80003160:	b05fe0ef          	jal	80001c64 <myproc>
    80003164:	8926                	mv	s2,s1
    80003166:	00449693          	slli	a3,s1,0x4
    8000316a:	96a6                	add	a3,a3,s1
    8000316c:	767d                	lui	a2,0xfffff
    8000316e:	068a                	slli	a3,a3,0x2
    80003170:	75060793          	addi	a5,a2,1872 # fffffffffffff750 <end+0xffffffff7ffb8870>
    80003174:	00878633          	add	a2,a5,s0
    80003178:	fd843583          	ld	a1,-40(s0)
    8000317c:	6928                	ld	a0,80(a0)
    8000317e:	f70fe0ef          	jal	800018ee <copyout>
    80003182:	00054b63          	bltz	a0,80003198 <sys_schedread+0x90>
    return -1;

  return n;
}
    80003186:	854a                	mv	a0,s2
    80003188:	7f010113          	addi	sp,sp,2032
    8000318c:	70ea                	ld	ra,184(sp)
    8000318e:	744a                	ld	s0,176(sp)
    80003190:	74aa                	ld	s1,168(sp)
    80003192:	790a                	ld	s2,160(sp)
    80003194:	6129                	addi	sp,sp,192
    80003196:	8082                	ret
    return -1;
    80003198:	597d                	li	s2,-1
    8000319a:	b7f5                	j	80003186 <sys_schedread+0x7e>

000000008000319c <sys_getcpuinfo>:

uint64
sys_getcpuinfo(void)
{
    8000319c:	7149                	addi	sp,sp,-368
    8000319e:	f686                	sd	ra,360(sp)
    800031a0:	f2a2                	sd	s0,352(sp)
    800031a2:	eaca                	sd	s2,336(sp)
    800031a4:	1a80                	addi	s0,sp,368
  uint64 dst;
  int max;
  argaddr(0, &dst);
    800031a6:	fd840593          	addi	a1,s0,-40
    800031aa:	4501                	li	a0,0
    800031ac:	cc5ff0ef          	jal	80002e70 <argaddr>
  argint(1, &max);
    800031b0:	fd440593          	addi	a1,s0,-44
    800031b4:	4505                	li	a0,1
    800031b6:	c9fff0ef          	jal	80002e54 <argint>

  if(max <= 0)
    800031ba:	fd442783          	lw	a5,-44(s0)
    return 0;
    800031be:	4901                	li	s2,0
  if(max <= 0)
    800031c0:	0af05d63          	blez	a5,8000327a <sys_getcpuinfo+0xde>
    800031c4:	eea6                	sd	s1,344(sp)

  struct cpu_info infos[NCPU];
  int count = 0;

  acquire(&tickslock);
    800031c6:	00014517          	auipc	a0,0x14
    800031ca:	89250513          	addi	a0,a0,-1902 # 80016a58 <tickslock>
    800031ce:	aeffd0ef          	jal	80000cbc <acquire>
  uint total_ticks = ticks;
    800031d2:	00005917          	auipc	s2,0x5
    800031d6:	75e92903          	lw	s2,1886(s2) # 80008930 <ticks>
  release(&tickslock);
    800031da:	00014517          	auipc	a0,0x14
    800031de:	87e50513          	addi	a0,a0,-1922 # 80016a58 <tickslock>
    800031e2:	b73fd0ef          	jal	80000d54 <release>

  for(int i = 0; i < NCPU && count < max; i++) {
    800031e6:	fd442503          	lw	a0,-44(s0)
    800031ea:	e9040793          	addi	a5,s0,-368
    800031ee:	0000e717          	auipc	a4,0xe
    800031f2:	92a70713          	addi	a4,a4,-1750 # 80010b18 <cpus>
  int count = 0;
    800031f6:	4481                	li	s1,0
    ci->current_pid = c->current_pid;
    ci->current_state = c->current_state;
    ci->last_pid = c->last_pid;
    ci->last_state = c->last_state;
    ci->active_ticks = c->active_ticks;
    ci->busy_percent = total_ticks > 0 ? (int)((c->active_ticks * 100) / total_ticks) : 0;
    800031f8:	4881                	li	a7,0
    800031fa:	06400e13          	li	t3,100
    800031fe:	02091313          	slli	t1,s2,0x20
    80003202:	02035313          	srli	t1,t1,0x20
  for(int i = 0; i < NCPU && count < max; i++) {
    80003206:	4821                	li	a6,8
    80003208:	a809                	j	8000321a <sys_getcpuinfo+0x7e>
    ci->busy_percent = total_ticks > 0 ? (int)((c->active_ticks * 100) / total_ticks) : 0;
    8000320a:	d190                	sw	a2,32(a1)
    count++;
    8000320c:	2485                	addiw	s1,s1,1
  for(int i = 0; i < NCPU && count < max; i++) {
    8000320e:	02878793          	addi	a5,a5,40
    80003212:	0a870713          	addi	a4,a4,168
    80003216:	05048163          	beq	s1,a6,80003258 <sys_getcpuinfo+0xbc>
    8000321a:	02a4df63          	bge	s1,a0,80003258 <sys_getcpuinfo+0xbc>
    ci->cpu = i;
    8000321e:	85be                	mv	a1,a5
    80003220:	c384                	sw	s1,0(a5)
    ci->active = c->active;
    80003222:	08072683          	lw	a3,128(a4)
    80003226:	c3d4                	sw	a3,4(a5)
    ci->current_pid = c->current_pid;
    80003228:	08472683          	lw	a3,132(a4)
    8000322c:	c794                	sw	a3,8(a5)
    ci->current_state = c->current_state;
    8000322e:	08872683          	lw	a3,136(a4)
    80003232:	c7d4                	sw	a3,12(a5)
    ci->last_pid = c->last_pid;
    80003234:	08c72683          	lw	a3,140(a4)
    80003238:	cb94                	sw	a3,16(a5)
    ci->last_state = c->last_state;
    8000323a:	09072683          	lw	a3,144(a4)
    8000323e:	cbd4                	sw	a3,20(a5)
    ci->active_ticks = c->active_ticks;
    80003240:	6f54                	ld	a3,152(a4)
    80003242:	ef94                	sd	a3,24(a5)
    ci->busy_percent = total_ticks > 0 ? (int)((c->active_ticks * 100) / total_ticks) : 0;
    80003244:	8646                	mv	a2,a7
    80003246:	fc0902e3          	beqz	s2,8000320a <sys_getcpuinfo+0x6e>
    8000324a:	03c686b3          	mul	a3,a3,t3
    8000324e:	0266d6b3          	divu	a3,a3,t1
    80003252:	0006861b          	sext.w	a2,a3
    80003256:	bf55                	j	8000320a <sys_getcpuinfo+0x6e>
  }

  if(copyout(myproc()->pagetable, dst, (char *)infos, count * sizeof(struct cpu_info)) < 0)
    80003258:	a0dfe0ef          	jal	80001c64 <myproc>
    8000325c:	8926                	mv	s2,s1
    8000325e:	00249693          	slli	a3,s1,0x2
    80003262:	96a6                	add	a3,a3,s1
    80003264:	068e                	slli	a3,a3,0x3
    80003266:	e9040613          	addi	a2,s0,-368
    8000326a:	fd843583          	ld	a1,-40(s0)
    8000326e:	6928                	ld	a0,80(a0)
    80003270:	e7efe0ef          	jal	800018ee <copyout>
    80003274:	00054963          	bltz	a0,80003286 <sys_getcpuinfo+0xea>
    80003278:	64f6                	ld	s1,344(sp)
    return -1;

  return count;
}
    8000327a:	854a                	mv	a0,s2
    8000327c:	70b6                	ld	ra,360(sp)
    8000327e:	7416                	ld	s0,352(sp)
    80003280:	6956                	ld	s2,336(sp)
    80003282:	6175                	addi	sp,sp,368
    80003284:	8082                	ret
    return -1;
    80003286:	597d                	li	s2,-1
    80003288:	64f6                	ld	s1,344(sp)
    8000328a:	bfc5                	j	8000327a <sys_getcpuinfo+0xde>

000000008000328c <sys_getprocstats>:

uint64
sys_getprocstats(void)
{
    8000328c:	7171                	addi	sp,sp,-176
    8000328e:	f506                	sd	ra,168(sp)
    80003290:	f122                	sd	s0,160(sp)
    80003292:	1900                	addi	s0,sp,176
  uint64 dst;
  argaddr(0, &dst);
    80003294:	fc840593          	addi	a1,s0,-56
    80003298:	4501                	li	a0,0
    8000329a:	bd7ff0ef          	jal	80002e70 <argaddr>
  if(dst == 0)
    8000329e:	fc843783          	ld	a5,-56(s0)
    return -1;
    800032a2:	557d                	li	a0,-1
  if(dst == 0)
    800032a4:	cfe1                	beqz	a5,8000337c <sys_getprocstats+0xf0>
    800032a6:	ed26                	sd	s1,152(sp)
    800032a8:	e94a                	sd	s2,144(sp)
    800032aa:	e54e                	sd	s3,136(sp)
    800032ac:	e152                	sd	s4,128(sp)
    800032ae:	f5840a13          	addi	s4,s0,-168
    800032b2:	f8840713          	addi	a4,s0,-120
    800032b6:	87d2                	mv	a5,s4

  struct proc_stats stats;
  for (int i = 0; i < PROC_STATE_COUNT; i++) {
    stats.current_count[i] = 0;
    800032b8:	0007b023          	sd	zero,0(a5)
    stats.unique_count[i] = 0;
    800032bc:	0207b823          	sd	zero,48(a5)
  for (int i = 0; i < PROC_STATE_COUNT; i++) {
    800032c0:	07a1                	addi	a5,a5,8
    800032c2:	fee79be3          	bne	a5,a4,800032b8 <sys_getprocstats+0x2c>
  }

  struct proc *p;
  for(p = proc; p < &proc[NPROC]; p++) {
    800032c6:	0000e497          	auipc	s1,0xe
    800032ca:	d9248493          	addi	s1,s1,-622 # 80011058 <proc>
    acquire(&p->lock);
    if(p->state >= 0 && p->state < PROC_STATE_COUNT)
    800032ce:	4995                	li	s3,5
  for(p = proc; p < &proc[NPROC]; p++) {
    800032d0:	00013917          	auipc	s2,0x13
    800032d4:	78890913          	addi	s2,s2,1928 # 80016a58 <tickslock>
    800032d8:	a801                	j	800032e8 <sys_getprocstats+0x5c>
      stats.current_count[p->state]++;
    release(&p->lock);
    800032da:	8526                	mv	a0,s1
    800032dc:	a79fd0ef          	jal	80000d54 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    800032e0:	16848493          	addi	s1,s1,360
    800032e4:	03248563          	beq	s1,s2,8000330e <sys_getprocstats+0x82>
    acquire(&p->lock);
    800032e8:	8526                	mv	a0,s1
    800032ea:	9d3fd0ef          	jal	80000cbc <acquire>
    if(p->state >= 0 && p->state < PROC_STATE_COUNT)
    800032ee:	4c9c                	lw	a5,24(s1)
    800032f0:	fef9e5e3          	bltu	s3,a5,800032da <sys_getprocstats+0x4e>
      stats.current_count[p->state]++;
    800032f4:	02079713          	slli	a4,a5,0x20
    800032f8:	01d75793          	srli	a5,a4,0x1d
    800032fc:	fd078793          	addi	a5,a5,-48
    80003300:	97a2                	add	a5,a5,s0
    80003302:	f887b703          	ld	a4,-120(a5)
    80003306:	0705                	addi	a4,a4,1
    80003308:	f8e7b423          	sd	a4,-120(a5)
    8000330c:	b7f9                	j	800032da <sys_getprocstats+0x4e>
  }

  acquire(&procstat_lock);
    8000330e:	0000d517          	auipc	a0,0xd
    80003312:	77a50513          	addi	a0,a0,1914 # 80010a88 <procstat_lock>
    80003316:	9a7fd0ef          	jal	80000cbc <acquire>
  for (int i = 0; i < PROC_STATE_COUNT; i++)
    8000331a:	0000d797          	auipc	a5,0xd
    8000331e:	78678793          	addi	a5,a5,1926 # 80010aa0 <proc_state_unique>
    80003322:	0000d697          	auipc	a3,0xd
    80003326:	7ae68693          	addi	a3,a3,1966 # 80010ad0 <pid_lock>
    stats.unique_count[i] = proc_state_unique[i];
    8000332a:	6398                	ld	a4,0(a5)
    8000332c:	02ea3823          	sd	a4,48(s4)
  for (int i = 0; i < PROC_STATE_COUNT; i++)
    80003330:	07a1                	addi	a5,a5,8
    80003332:	0a21                	addi	s4,s4,8
    80003334:	fed79be3          	bne	a5,a3,8000332a <sys_getprocstats+0x9e>
  stats.total_created = proc_total_created;
    80003338:	00005797          	auipc	a5,0x5
    8000333c:	5e07b783          	ld	a5,1504(a5) # 80008918 <proc_total_created>
    80003340:	faf43c23          	sd	a5,-72(s0)
  stats.total_exited = proc_total_exited;
    80003344:	00005797          	auipc	a5,0x5
    80003348:	5cc7b783          	ld	a5,1484(a5) # 80008910 <proc_total_exited>
    8000334c:	fcf43023          	sd	a5,-64(s0)
  release(&procstat_lock);
    80003350:	0000d517          	auipc	a0,0xd
    80003354:	73850513          	addi	a0,a0,1848 # 80010a88 <procstat_lock>
    80003358:	9fdfd0ef          	jal	80000d54 <release>

  if(copyout(myproc()->pagetable, dst, (char *)&stats, sizeof(stats)) < 0)
    8000335c:	909fe0ef          	jal	80001c64 <myproc>
    80003360:	07000693          	li	a3,112
    80003364:	f5840613          	addi	a2,s0,-168
    80003368:	fc843583          	ld	a1,-56(s0)
    8000336c:	6928                	ld	a0,80(a0)
    8000336e:	d80fe0ef          	jal	800018ee <copyout>
    80003372:	957d                	srai	a0,a0,0x3f
    80003374:	64ea                	ld	s1,152(sp)
    80003376:	694a                	ld	s2,144(sp)
    80003378:	69aa                	ld	s3,136(sp)
    8000337a:	6a0a                	ld	s4,128(sp)
    return -1;

  return 0;
}
    8000337c:	70aa                	ld	ra,168(sp)
    8000337e:	740a                	ld	s0,160(sp)
    80003380:	614d                	addi	sp,sp,176
    80003382:	8082                	ret

0000000080003384 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80003384:	7179                	addi	sp,sp,-48
    80003386:	f406                	sd	ra,40(sp)
    80003388:	f022                	sd	s0,32(sp)
    8000338a:	ec26                	sd	s1,24(sp)
    8000338c:	e84a                	sd	s2,16(sp)
    8000338e:	e44e                	sd	s3,8(sp)
    80003390:	e052                	sd	s4,0(sp)
    80003392:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80003394:	00005597          	auipc	a1,0x5
    80003398:	03c58593          	addi	a1,a1,60 # 800083d0 <etext+0x3d0>
    8000339c:	00013517          	auipc	a0,0x13
    800033a0:	6d450513          	addi	a0,a0,1748 # 80016a70 <bcache>
    800033a4:	899fd0ef          	jal	80000c3c <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    800033a8:	0001b797          	auipc	a5,0x1b
    800033ac:	6c878793          	addi	a5,a5,1736 # 8001ea70 <bcache+0x8000>
    800033b0:	0001c717          	auipc	a4,0x1c
    800033b4:	92870713          	addi	a4,a4,-1752 # 8001ecd8 <bcache+0x8268>
    800033b8:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    800033bc:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    800033c0:	00013497          	auipc	s1,0x13
    800033c4:	6c848493          	addi	s1,s1,1736 # 80016a88 <bcache+0x18>
    b->next = bcache.head.next;
    800033c8:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    800033ca:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    800033cc:	00005a17          	auipc	s4,0x5
    800033d0:	00ca0a13          	addi	s4,s4,12 # 800083d8 <etext+0x3d8>
    b->next = bcache.head.next;
    800033d4:	2b893783          	ld	a5,696(s2)
    800033d8:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    800033da:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    800033de:	85d2                	mv	a1,s4
    800033e0:	01048513          	addi	a0,s1,16
    800033e4:	360010ef          	jal	80004744 <initsleeplock>
    bcache.head.next->prev = b;
    800033e8:	2b893783          	ld	a5,696(s2)
    800033ec:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    800033ee:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    800033f2:	45848493          	addi	s1,s1,1112
    800033f6:	fd349fe3          	bne	s1,s3,800033d4 <binit+0x50>
  }
}
    800033fa:	70a2                	ld	ra,40(sp)
    800033fc:	7402                	ld	s0,32(sp)
    800033fe:	64e2                	ld	s1,24(sp)
    80003400:	6942                	ld	s2,16(sp)
    80003402:	69a2                	ld	s3,8(sp)
    80003404:	6a02                	ld	s4,0(sp)
    80003406:	6145                	addi	sp,sp,48
    80003408:	8082                	ret

000000008000340a <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    8000340a:	7179                	addi	sp,sp,-48
    8000340c:	f406                	sd	ra,40(sp)
    8000340e:	f022                	sd	s0,32(sp)
    80003410:	ec26                	sd	s1,24(sp)
    80003412:	e84a                	sd	s2,16(sp)
    80003414:	e44e                	sd	s3,8(sp)
    80003416:	1800                	addi	s0,sp,48
    80003418:	892a                	mv	s2,a0
    8000341a:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    8000341c:	00013517          	auipc	a0,0x13
    80003420:	65450513          	addi	a0,a0,1620 # 80016a70 <bcache>
    80003424:	899fd0ef          	jal	80000cbc <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    80003428:	0001c497          	auipc	s1,0x1c
    8000342c:	9004b483          	ld	s1,-1792(s1) # 8001ed28 <bcache+0x82b8>
    80003430:	0001c797          	auipc	a5,0x1c
    80003434:	8a878793          	addi	a5,a5,-1880 # 8001ecd8 <bcache+0x8268>
    80003438:	04f48563          	beq	s1,a5,80003482 <bread+0x78>
    8000343c:	873e                	mv	a4,a5
    8000343e:	a021                	j	80003446 <bread+0x3c>
    80003440:	68a4                	ld	s1,80(s1)
    80003442:	04e48063          	beq	s1,a4,80003482 <bread+0x78>
    if(b->dev == dev && b->blockno == blockno){
    80003446:	449c                	lw	a5,8(s1)
    80003448:	ff279ce3          	bne	a5,s2,80003440 <bread+0x36>
    8000344c:	44dc                	lw	a5,12(s1)
    8000344e:	ff3799e3          	bne	a5,s3,80003440 <bread+0x36>
      b->refcnt++;
    80003452:	40bc                	lw	a5,64(s1)
    80003454:	2785                	addiw	a5,a5,1
    80003456:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80003458:	00013517          	auipc	a0,0x13
    8000345c:	61850513          	addi	a0,a0,1560 # 80016a70 <bcache>
    80003460:	8f5fd0ef          	jal	80000d54 <release>
      acquiresleep(&b->lock);
    80003464:	01048513          	addi	a0,s1,16
    80003468:	312010ef          	jal	8000477a <acquiresleep>
      fslog_push(FS_BGET_HIT, 0, blockno, 0, "BCACHE");
    8000346c:	00005717          	auipc	a4,0x5
    80003470:	f7470713          	addi	a4,a4,-140 # 800083e0 <etext+0x3e0>
    80003474:	4681                	li	a3,0
    80003476:	864e                	mv	a2,s3
    80003478:	4581                	li	a1,0
    8000347a:	4519                	li	a0,6
    8000347c:	1bc030ef          	jal	80006638 <fslog_push>
      return b;
    80003480:	a09d                	j	800034e6 <bread+0xdc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80003482:	0001c497          	auipc	s1,0x1c
    80003486:	89e4b483          	ld	s1,-1890(s1) # 8001ed20 <bcache+0x82b0>
    8000348a:	0001c797          	auipc	a5,0x1c
    8000348e:	84e78793          	addi	a5,a5,-1970 # 8001ecd8 <bcache+0x8268>
    80003492:	00f48863          	beq	s1,a5,800034a2 <bread+0x98>
    80003496:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    80003498:	40bc                	lw	a5,64(s1)
    8000349a:	cb91                	beqz	a5,800034ae <bread+0xa4>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    8000349c:	64a4                	ld	s1,72(s1)
    8000349e:	fee49de3          	bne	s1,a4,80003498 <bread+0x8e>
  panic("bget: no buffers");
    800034a2:	00005517          	auipc	a0,0x5
    800034a6:	f4650513          	addi	a0,a0,-186 # 800083e8 <etext+0x3e8>
    800034aa:	b68fd0ef          	jal	80000812 <panic>
      b->dev = dev;
    800034ae:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    800034b2:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    800034b6:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    800034ba:	4785                	li	a5,1
    800034bc:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    800034be:	00013517          	auipc	a0,0x13
    800034c2:	5b250513          	addi	a0,a0,1458 # 80016a70 <bcache>
    800034c6:	88ffd0ef          	jal	80000d54 <release>
      acquiresleep(&b->lock);
    800034ca:	01048513          	addi	a0,s1,16
    800034ce:	2ac010ef          	jal	8000477a <acquiresleep>
      fslog_push(FS_BGET_MISS, 0, blockno, 0, "BCACHE");
    800034d2:	00005717          	auipc	a4,0x5
    800034d6:	f0e70713          	addi	a4,a4,-242 # 800083e0 <etext+0x3e0>
    800034da:	4681                	li	a3,0
    800034dc:	864e                	mv	a2,s3
    800034de:	4581                	li	a1,0
    800034e0:	451d                	li	a0,7
    800034e2:	156030ef          	jal	80006638 <fslog_push>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    800034e6:	409c                	lw	a5,0(s1)
    800034e8:	cb89                	beqz	a5,800034fa <bread+0xf0>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    800034ea:	8526                	mv	a0,s1
    800034ec:	70a2                	ld	ra,40(sp)
    800034ee:	7402                	ld	s0,32(sp)
    800034f0:	64e2                	ld	s1,24(sp)
    800034f2:	6942                	ld	s2,16(sp)
    800034f4:	69a2                	ld	s3,8(sp)
    800034f6:	6145                	addi	sp,sp,48
    800034f8:	8082                	ret
    virtio_disk_rw(b, 0);
    800034fa:	4581                	li	a1,0
    800034fc:	8526                	mv	a0,s1
    800034fe:	313020ef          	jal	80006010 <virtio_disk_rw>
    b->valid = 1;
    80003502:	4785                	li	a5,1
    80003504:	c09c                	sw	a5,0(s1)
  return b;
    80003506:	b7d5                	j	800034ea <bread+0xe0>

0000000080003508 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    80003508:	1101                	addi	sp,sp,-32
    8000350a:	ec06                	sd	ra,24(sp)
    8000350c:	e822                	sd	s0,16(sp)
    8000350e:	e426                	sd	s1,8(sp)
    80003510:	1000                	addi	s0,sp,32
    80003512:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80003514:	0541                	addi	a0,a0,16
    80003516:	2e2010ef          	jal	800047f8 <holdingsleep>
    8000351a:	c911                	beqz	a0,8000352e <bwrite+0x26>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    8000351c:	4585                	li	a1,1
    8000351e:	8526                	mv	a0,s1
    80003520:	2f1020ef          	jal	80006010 <virtio_disk_rw>
}
    80003524:	60e2                	ld	ra,24(sp)
    80003526:	6442                	ld	s0,16(sp)
    80003528:	64a2                	ld	s1,8(sp)
    8000352a:	6105                	addi	sp,sp,32
    8000352c:	8082                	ret
    panic("bwrite");
    8000352e:	00005517          	auipc	a0,0x5
    80003532:	ed250513          	addi	a0,a0,-302 # 80008400 <etext+0x400>
    80003536:	adcfd0ef          	jal	80000812 <panic>

000000008000353a <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    8000353a:	1101                	addi	sp,sp,-32
    8000353c:	ec06                	sd	ra,24(sp)
    8000353e:	e822                	sd	s0,16(sp)
    80003540:	e426                	sd	s1,8(sp)
    80003542:	e04a                	sd	s2,0(sp)
    80003544:	1000                	addi	s0,sp,32
    80003546:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80003548:	01050913          	addi	s2,a0,16
    8000354c:	854a                	mv	a0,s2
    8000354e:	2aa010ef          	jal	800047f8 <holdingsleep>
    80003552:	cd05                	beqz	a0,8000358a <brelse+0x50>
    panic("brelse");

  releasesleep(&b->lock);
    80003554:	854a                	mv	a0,s2
    80003556:	26a010ef          	jal	800047c0 <releasesleep>

  acquire(&bcache.lock);
    8000355a:	00013517          	auipc	a0,0x13
    8000355e:	51650513          	addi	a0,a0,1302 # 80016a70 <bcache>
    80003562:	f5afd0ef          	jal	80000cbc <acquire>
  b->refcnt--;
    80003566:	40bc                	lw	a5,64(s1)
    80003568:	37fd                	addiw	a5,a5,-1
    8000356a:	0007871b          	sext.w	a4,a5
    8000356e:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    80003570:	c31d                	beqz	a4,80003596 <brelse+0x5c>
    bcache.head.next->prev = b;
    bcache.head.next = b;
    fslog_push(FS_BRELEASE, 0, b->blockno, 0, "BCACHE");
  }
  
  release(&bcache.lock);
    80003572:	00013517          	auipc	a0,0x13
    80003576:	4fe50513          	addi	a0,a0,1278 # 80016a70 <bcache>
    8000357a:	fdafd0ef          	jal	80000d54 <release>
}
    8000357e:	60e2                	ld	ra,24(sp)
    80003580:	6442                	ld	s0,16(sp)
    80003582:	64a2                	ld	s1,8(sp)
    80003584:	6902                	ld	s2,0(sp)
    80003586:	6105                	addi	sp,sp,32
    80003588:	8082                	ret
    panic("brelse");
    8000358a:	00005517          	auipc	a0,0x5
    8000358e:	e7e50513          	addi	a0,a0,-386 # 80008408 <etext+0x408>
    80003592:	a80fd0ef          	jal	80000812 <panic>
    b->next->prev = b->prev;
    80003596:	68b8                	ld	a4,80(s1)
    80003598:	64bc                	ld	a5,72(s1)
    8000359a:	e73c                	sd	a5,72(a4)
    b->prev->next = b->next;
    8000359c:	68b8                	ld	a4,80(s1)
    8000359e:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    800035a0:	0001b797          	auipc	a5,0x1b
    800035a4:	4d078793          	addi	a5,a5,1232 # 8001ea70 <bcache+0x8000>
    800035a8:	2b87b703          	ld	a4,696(a5)
    800035ac:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    800035ae:	0001b717          	auipc	a4,0x1b
    800035b2:	72a70713          	addi	a4,a4,1834 # 8001ecd8 <bcache+0x8268>
    800035b6:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    800035b8:	2b87b703          	ld	a4,696(a5)
    800035bc:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    800035be:	2a97bc23          	sd	s1,696(a5)
    fslog_push(FS_BRELEASE, 0, b->blockno, 0, "BCACHE");
    800035c2:	00005717          	auipc	a4,0x5
    800035c6:	e1e70713          	addi	a4,a4,-482 # 800083e0 <etext+0x3e0>
    800035ca:	4681                	li	a3,0
    800035cc:	44d0                	lw	a2,12(s1)
    800035ce:	4581                	li	a1,0
    800035d0:	4521                	li	a0,8
    800035d2:	066030ef          	jal	80006638 <fslog_push>
    800035d6:	bf71                	j	80003572 <brelse+0x38>

00000000800035d8 <bpin>:

void
bpin(struct buf *b) {
    800035d8:	1101                	addi	sp,sp,-32
    800035da:	ec06                	sd	ra,24(sp)
    800035dc:	e822                	sd	s0,16(sp)
    800035de:	e426                	sd	s1,8(sp)
    800035e0:	1000                	addi	s0,sp,32
    800035e2:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    800035e4:	00013517          	auipc	a0,0x13
    800035e8:	48c50513          	addi	a0,a0,1164 # 80016a70 <bcache>
    800035ec:	ed0fd0ef          	jal	80000cbc <acquire>
  b->refcnt++;
    800035f0:	40bc                	lw	a5,64(s1)
    800035f2:	2785                	addiw	a5,a5,1
    800035f4:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    800035f6:	00013517          	auipc	a0,0x13
    800035fa:	47a50513          	addi	a0,a0,1146 # 80016a70 <bcache>
    800035fe:	f56fd0ef          	jal	80000d54 <release>
}
    80003602:	60e2                	ld	ra,24(sp)
    80003604:	6442                	ld	s0,16(sp)
    80003606:	64a2                	ld	s1,8(sp)
    80003608:	6105                	addi	sp,sp,32
    8000360a:	8082                	ret

000000008000360c <bunpin>:

void
bunpin(struct buf *b) {
    8000360c:	1101                	addi	sp,sp,-32
    8000360e:	ec06                	sd	ra,24(sp)
    80003610:	e822                	sd	s0,16(sp)
    80003612:	e426                	sd	s1,8(sp)
    80003614:	1000                	addi	s0,sp,32
    80003616:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80003618:	00013517          	auipc	a0,0x13
    8000361c:	45850513          	addi	a0,a0,1112 # 80016a70 <bcache>
    80003620:	e9cfd0ef          	jal	80000cbc <acquire>
  b->refcnt--;
    80003624:	40bc                	lw	a5,64(s1)
    80003626:	37fd                	addiw	a5,a5,-1
    80003628:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    8000362a:	00013517          	auipc	a0,0x13
    8000362e:	44650513          	addi	a0,a0,1094 # 80016a70 <bcache>
    80003632:	f22fd0ef          	jal	80000d54 <release>
}
    80003636:	60e2                	ld	ra,24(sp)
    80003638:	6442                	ld	s0,16(sp)
    8000363a:	64a2                	ld	s1,8(sp)
    8000363c:	6105                	addi	sp,sp,32
    8000363e:	8082                	ret

0000000080003640 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    80003640:	1101                	addi	sp,sp,-32
    80003642:	ec06                	sd	ra,24(sp)
    80003644:	e822                	sd	s0,16(sp)
    80003646:	e426                	sd	s1,8(sp)
    80003648:	e04a                	sd	s2,0(sp)
    8000364a:	1000                	addi	s0,sp,32
    8000364c:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    8000364e:	00d5d59b          	srliw	a1,a1,0xd
    80003652:	0001c797          	auipc	a5,0x1c
    80003656:	afa7a783          	lw	a5,-1286(a5) # 8001f14c <sb+0x1c>
    8000365a:	9dbd                	addw	a1,a1,a5
    8000365c:	dafff0ef          	jal	8000340a <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    80003660:	0074f713          	andi	a4,s1,7
    80003664:	4785                	li	a5,1
    80003666:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    8000366a:	14ce                	slli	s1,s1,0x33
    8000366c:	90d9                	srli	s1,s1,0x36
    8000366e:	00950733          	add	a4,a0,s1
    80003672:	05874703          	lbu	a4,88(a4)
    80003676:	00e7f6b3          	and	a3,a5,a4
    8000367a:	c29d                	beqz	a3,800036a0 <bfree+0x60>
    8000367c:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    8000367e:	94aa                	add	s1,s1,a0
    80003680:	fff7c793          	not	a5,a5
    80003684:	8f7d                	and	a4,a4,a5
    80003686:	04e48c23          	sb	a4,88(s1)
  log_write(bp);
    8000368a:	7f9000ef          	jal	80004682 <log_write>
  brelse(bp);
    8000368e:	854a                	mv	a0,s2
    80003690:	eabff0ef          	jal	8000353a <brelse>
}
    80003694:	60e2                	ld	ra,24(sp)
    80003696:	6442                	ld	s0,16(sp)
    80003698:	64a2                	ld	s1,8(sp)
    8000369a:	6902                	ld	s2,0(sp)
    8000369c:	6105                	addi	sp,sp,32
    8000369e:	8082                	ret
    panic("freeing free block");
    800036a0:	00005517          	auipc	a0,0x5
    800036a4:	d7050513          	addi	a0,a0,-656 # 80008410 <etext+0x410>
    800036a8:	96afd0ef          	jal	80000812 <panic>

00000000800036ac <balloc>:
{
    800036ac:	711d                	addi	sp,sp,-96
    800036ae:	ec86                	sd	ra,88(sp)
    800036b0:	e8a2                	sd	s0,80(sp)
    800036b2:	e4a6                	sd	s1,72(sp)
    800036b4:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    800036b6:	0001c797          	auipc	a5,0x1c
    800036ba:	a7e7a783          	lw	a5,-1410(a5) # 8001f134 <sb+0x4>
    800036be:	0e078f63          	beqz	a5,800037bc <balloc+0x110>
    800036c2:	e0ca                	sd	s2,64(sp)
    800036c4:	fc4e                	sd	s3,56(sp)
    800036c6:	f852                	sd	s4,48(sp)
    800036c8:	f456                	sd	s5,40(sp)
    800036ca:	f05a                	sd	s6,32(sp)
    800036cc:	ec5e                	sd	s7,24(sp)
    800036ce:	e862                	sd	s8,16(sp)
    800036d0:	e466                	sd	s9,8(sp)
    800036d2:	8baa                	mv	s7,a0
    800036d4:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    800036d6:	0001cb17          	auipc	s6,0x1c
    800036da:	a5ab0b13          	addi	s6,s6,-1446 # 8001f130 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800036de:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    800036e0:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800036e2:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    800036e4:	6c89                	lui	s9,0x2
    800036e6:	a0b5                	j	80003752 <balloc+0xa6>
        bp->data[bi/8] |= m;  // Mark block in use.
    800036e8:	97ca                	add	a5,a5,s2
    800036ea:	8e55                	or	a2,a2,a3
    800036ec:	04c78c23          	sb	a2,88(a5)
        log_write(bp);
    800036f0:	854a                	mv	a0,s2
    800036f2:	791000ef          	jal	80004682 <log_write>
        brelse(bp);
    800036f6:	854a                	mv	a0,s2
    800036f8:	e43ff0ef          	jal	8000353a <brelse>
  bp = bread(dev, bno);
    800036fc:	85a6                	mv	a1,s1
    800036fe:	855e                	mv	a0,s7
    80003700:	d0bff0ef          	jal	8000340a <bread>
    80003704:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    80003706:	40000613          	li	a2,1024
    8000370a:	4581                	li	a1,0
    8000370c:	05850513          	addi	a0,a0,88
    80003710:	e80fd0ef          	jal	80000d90 <memset>
  log_write(bp);
    80003714:	854a                	mv	a0,s2
    80003716:	76d000ef          	jal	80004682 <log_write>
  brelse(bp);
    8000371a:	854a                	mv	a0,s2
    8000371c:	e1fff0ef          	jal	8000353a <brelse>
}
    80003720:	6906                	ld	s2,64(sp)
    80003722:	79e2                	ld	s3,56(sp)
    80003724:	7a42                	ld	s4,48(sp)
    80003726:	7aa2                	ld	s5,40(sp)
    80003728:	7b02                	ld	s6,32(sp)
    8000372a:	6be2                	ld	s7,24(sp)
    8000372c:	6c42                	ld	s8,16(sp)
    8000372e:	6ca2                	ld	s9,8(sp)
}
    80003730:	8526                	mv	a0,s1
    80003732:	60e6                	ld	ra,88(sp)
    80003734:	6446                	ld	s0,80(sp)
    80003736:	64a6                	ld	s1,72(sp)
    80003738:	6125                	addi	sp,sp,96
    8000373a:	8082                	ret
    brelse(bp);
    8000373c:	854a                	mv	a0,s2
    8000373e:	dfdff0ef          	jal	8000353a <brelse>
  for(b = 0; b < sb.size; b += BPB){
    80003742:	015c87bb          	addw	a5,s9,s5
    80003746:	00078a9b          	sext.w	s5,a5
    8000374a:	004b2703          	lw	a4,4(s6)
    8000374e:	04eaff63          	bgeu	s5,a4,800037ac <balloc+0x100>
    bp = bread(dev, BBLOCK(b, sb));
    80003752:	41fad79b          	sraiw	a5,s5,0x1f
    80003756:	0137d79b          	srliw	a5,a5,0x13
    8000375a:	015787bb          	addw	a5,a5,s5
    8000375e:	40d7d79b          	sraiw	a5,a5,0xd
    80003762:	01cb2583          	lw	a1,28(s6)
    80003766:	9dbd                	addw	a1,a1,a5
    80003768:	855e                	mv	a0,s7
    8000376a:	ca1ff0ef          	jal	8000340a <bread>
    8000376e:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003770:	004b2503          	lw	a0,4(s6)
    80003774:	000a849b          	sext.w	s1,s5
    80003778:	8762                	mv	a4,s8
    8000377a:	fca4f1e3          	bgeu	s1,a0,8000373c <balloc+0x90>
      m = 1 << (bi % 8);
    8000377e:	00777693          	andi	a3,a4,7
    80003782:	00d996bb          	sllw	a3,s3,a3
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    80003786:	41f7579b          	sraiw	a5,a4,0x1f
    8000378a:	01d7d79b          	srliw	a5,a5,0x1d
    8000378e:	9fb9                	addw	a5,a5,a4
    80003790:	4037d79b          	sraiw	a5,a5,0x3
    80003794:	00f90633          	add	a2,s2,a5
    80003798:	05864603          	lbu	a2,88(a2)
    8000379c:	00c6f5b3          	and	a1,a3,a2
    800037a0:	d5a1                	beqz	a1,800036e8 <balloc+0x3c>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800037a2:	2705                	addiw	a4,a4,1
    800037a4:	2485                	addiw	s1,s1,1
    800037a6:	fd471ae3          	bne	a4,s4,8000377a <balloc+0xce>
    800037aa:	bf49                	j	8000373c <balloc+0x90>
    800037ac:	6906                	ld	s2,64(sp)
    800037ae:	79e2                	ld	s3,56(sp)
    800037b0:	7a42                	ld	s4,48(sp)
    800037b2:	7aa2                	ld	s5,40(sp)
    800037b4:	7b02                	ld	s6,32(sp)
    800037b6:	6be2                	ld	s7,24(sp)
    800037b8:	6c42                	ld	s8,16(sp)
    800037ba:	6ca2                	ld	s9,8(sp)
  printf("balloc: out of blocks\n");
    800037bc:	00005517          	auipc	a0,0x5
    800037c0:	c6c50513          	addi	a0,a0,-916 # 80008428 <etext+0x428>
    800037c4:	d69fc0ef          	jal	8000052c <printf>
  return 0;
    800037c8:	4481                	li	s1,0
    800037ca:	b79d                	j	80003730 <balloc+0x84>

00000000800037cc <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    800037cc:	7179                	addi	sp,sp,-48
    800037ce:	f406                	sd	ra,40(sp)
    800037d0:	f022                	sd	s0,32(sp)
    800037d2:	ec26                	sd	s1,24(sp)
    800037d4:	e84a                	sd	s2,16(sp)
    800037d6:	e44e                	sd	s3,8(sp)
    800037d8:	1800                	addi	s0,sp,48
    800037da:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    800037dc:	47ad                	li	a5,11
    800037de:	02b7e663          	bltu	a5,a1,8000380a <bmap+0x3e>
    if((addr = ip->addrs[bn]) == 0){
    800037e2:	02059793          	slli	a5,a1,0x20
    800037e6:	01e7d593          	srli	a1,a5,0x1e
    800037ea:	00b504b3          	add	s1,a0,a1
    800037ee:	0504a903          	lw	s2,80(s1)
    800037f2:	06091a63          	bnez	s2,80003866 <bmap+0x9a>
      addr = balloc(ip->dev);
    800037f6:	4108                	lw	a0,0(a0)
    800037f8:	eb5ff0ef          	jal	800036ac <balloc>
    800037fc:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    80003800:	06090363          	beqz	s2,80003866 <bmap+0x9a>
        return 0;
      ip->addrs[bn] = addr;
    80003804:	0524a823          	sw	s2,80(s1)
    80003808:	a8b9                	j	80003866 <bmap+0x9a>
    }
    return addr;
  }
  bn -= NDIRECT;
    8000380a:	ff45849b          	addiw	s1,a1,-12
    8000380e:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    80003812:	0ff00793          	li	a5,255
    80003816:	06e7ee63          	bltu	a5,a4,80003892 <bmap+0xc6>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    8000381a:	08052903          	lw	s2,128(a0)
    8000381e:	00091d63          	bnez	s2,80003838 <bmap+0x6c>
      addr = balloc(ip->dev);
    80003822:	4108                	lw	a0,0(a0)
    80003824:	e89ff0ef          	jal	800036ac <balloc>
    80003828:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    8000382c:	02090d63          	beqz	s2,80003866 <bmap+0x9a>
    80003830:	e052                	sd	s4,0(sp)
        return 0;
      ip->addrs[NDIRECT] = addr;
    80003832:	0929a023          	sw	s2,128(s3)
    80003836:	a011                	j	8000383a <bmap+0x6e>
    80003838:	e052                	sd	s4,0(sp)
    }
    bp = bread(ip->dev, addr);
    8000383a:	85ca                	mv	a1,s2
    8000383c:	0009a503          	lw	a0,0(s3)
    80003840:	bcbff0ef          	jal	8000340a <bread>
    80003844:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    80003846:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    8000384a:	02049713          	slli	a4,s1,0x20
    8000384e:	01e75593          	srli	a1,a4,0x1e
    80003852:	00b784b3          	add	s1,a5,a1
    80003856:	0004a903          	lw	s2,0(s1)
    8000385a:	00090e63          	beqz	s2,80003876 <bmap+0xaa>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    8000385e:	8552                	mv	a0,s4
    80003860:	cdbff0ef          	jal	8000353a <brelse>
    return addr;
    80003864:	6a02                	ld	s4,0(sp)
  }

  panic("bmap: out of range");
}
    80003866:	854a                	mv	a0,s2
    80003868:	70a2                	ld	ra,40(sp)
    8000386a:	7402                	ld	s0,32(sp)
    8000386c:	64e2                	ld	s1,24(sp)
    8000386e:	6942                	ld	s2,16(sp)
    80003870:	69a2                	ld	s3,8(sp)
    80003872:	6145                	addi	sp,sp,48
    80003874:	8082                	ret
      addr = balloc(ip->dev);
    80003876:	0009a503          	lw	a0,0(s3)
    8000387a:	e33ff0ef          	jal	800036ac <balloc>
    8000387e:	0005091b          	sext.w	s2,a0
      if(addr){
    80003882:	fc090ee3          	beqz	s2,8000385e <bmap+0x92>
        a[bn] = addr;
    80003886:	0124a023          	sw	s2,0(s1)
        log_write(bp);
    8000388a:	8552                	mv	a0,s4
    8000388c:	5f7000ef          	jal	80004682 <log_write>
    80003890:	b7f9                	j	8000385e <bmap+0x92>
    80003892:	e052                	sd	s4,0(sp)
  panic("bmap: out of range");
    80003894:	00005517          	auipc	a0,0x5
    80003898:	bac50513          	addi	a0,a0,-1108 # 80008440 <etext+0x440>
    8000389c:	f77fc0ef          	jal	80000812 <panic>

00000000800038a0 <iget>:
{
    800038a0:	7179                	addi	sp,sp,-48
    800038a2:	f406                	sd	ra,40(sp)
    800038a4:	f022                	sd	s0,32(sp)
    800038a6:	ec26                	sd	s1,24(sp)
    800038a8:	e84a                	sd	s2,16(sp)
    800038aa:	e44e                	sd	s3,8(sp)
    800038ac:	e052                	sd	s4,0(sp)
    800038ae:	1800                	addi	s0,sp,48
    800038b0:	89aa                	mv	s3,a0
    800038b2:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    800038b4:	0001c517          	auipc	a0,0x1c
    800038b8:	89c50513          	addi	a0,a0,-1892 # 8001f150 <itable>
    800038bc:	c00fd0ef          	jal	80000cbc <acquire>
  empty = 0;
    800038c0:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    800038c2:	0001c497          	auipc	s1,0x1c
    800038c6:	8a648493          	addi	s1,s1,-1882 # 8001f168 <itable+0x18>
    800038ca:	0001d697          	auipc	a3,0x1d
    800038ce:	32e68693          	addi	a3,a3,814 # 80020bf8 <log>
    800038d2:	a039                	j	800038e0 <iget+0x40>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    800038d4:	02090963          	beqz	s2,80003906 <iget+0x66>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    800038d8:	08848493          	addi	s1,s1,136
    800038dc:	02d48863          	beq	s1,a3,8000390c <iget+0x6c>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    800038e0:	449c                	lw	a5,8(s1)
    800038e2:	fef059e3          	blez	a5,800038d4 <iget+0x34>
    800038e6:	4098                	lw	a4,0(s1)
    800038e8:	ff3716e3          	bne	a4,s3,800038d4 <iget+0x34>
    800038ec:	40d8                	lw	a4,4(s1)
    800038ee:	ff4713e3          	bne	a4,s4,800038d4 <iget+0x34>
      ip->ref++;
    800038f2:	2785                	addiw	a5,a5,1
    800038f4:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    800038f6:	0001c517          	auipc	a0,0x1c
    800038fa:	85a50513          	addi	a0,a0,-1958 # 8001f150 <itable>
    800038fe:	c56fd0ef          	jal	80000d54 <release>
      return ip;
    80003902:	8926                	mv	s2,s1
    80003904:	a02d                	j	8000392e <iget+0x8e>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003906:	fbe9                	bnez	a5,800038d8 <iget+0x38>
      empty = ip;
    80003908:	8926                	mv	s2,s1
    8000390a:	b7f9                	j	800038d8 <iget+0x38>
  if(empty == 0)
    8000390c:	02090a63          	beqz	s2,80003940 <iget+0xa0>
  ip->dev = dev;
    80003910:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    80003914:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    80003918:	4785                	li	a5,1
    8000391a:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    8000391e:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    80003922:	0001c517          	auipc	a0,0x1c
    80003926:	82e50513          	addi	a0,a0,-2002 # 8001f150 <itable>
    8000392a:	c2afd0ef          	jal	80000d54 <release>
}
    8000392e:	854a                	mv	a0,s2
    80003930:	70a2                	ld	ra,40(sp)
    80003932:	7402                	ld	s0,32(sp)
    80003934:	64e2                	ld	s1,24(sp)
    80003936:	6942                	ld	s2,16(sp)
    80003938:	69a2                	ld	s3,8(sp)
    8000393a:	6a02                	ld	s4,0(sp)
    8000393c:	6145                	addi	sp,sp,48
    8000393e:	8082                	ret
    panic("iget: no inodes");
    80003940:	00005517          	auipc	a0,0x5
    80003944:	b1850513          	addi	a0,a0,-1256 # 80008458 <etext+0x458>
    80003948:	ecbfc0ef          	jal	80000812 <panic>

000000008000394c <iinit>:
{
    8000394c:	7179                	addi	sp,sp,-48
    8000394e:	f406                	sd	ra,40(sp)
    80003950:	f022                	sd	s0,32(sp)
    80003952:	ec26                	sd	s1,24(sp)
    80003954:	e84a                	sd	s2,16(sp)
    80003956:	e44e                	sd	s3,8(sp)
    80003958:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    8000395a:	00005597          	auipc	a1,0x5
    8000395e:	b0e58593          	addi	a1,a1,-1266 # 80008468 <etext+0x468>
    80003962:	0001b517          	auipc	a0,0x1b
    80003966:	7ee50513          	addi	a0,a0,2030 # 8001f150 <itable>
    8000396a:	ad2fd0ef          	jal	80000c3c <initlock>
  for(i = 0; i < NINODE; i++) {
    8000396e:	0001c497          	auipc	s1,0x1c
    80003972:	80a48493          	addi	s1,s1,-2038 # 8001f178 <itable+0x28>
    80003976:	0001d997          	auipc	s3,0x1d
    8000397a:	29298993          	addi	s3,s3,658 # 80020c08 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    8000397e:	00005917          	auipc	s2,0x5
    80003982:	af290913          	addi	s2,s2,-1294 # 80008470 <etext+0x470>
    80003986:	85ca                	mv	a1,s2
    80003988:	8526                	mv	a0,s1
    8000398a:	5bb000ef          	jal	80004744 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    8000398e:	08848493          	addi	s1,s1,136
    80003992:	ff349ae3          	bne	s1,s3,80003986 <iinit+0x3a>
}
    80003996:	70a2                	ld	ra,40(sp)
    80003998:	7402                	ld	s0,32(sp)
    8000399a:	64e2                	ld	s1,24(sp)
    8000399c:	6942                	ld	s2,16(sp)
    8000399e:	69a2                	ld	s3,8(sp)
    800039a0:	6145                	addi	sp,sp,48
    800039a2:	8082                	ret

00000000800039a4 <ialloc>:
{
    800039a4:	7139                	addi	sp,sp,-64
    800039a6:	fc06                	sd	ra,56(sp)
    800039a8:	f822                	sd	s0,48(sp)
    800039aa:	0080                	addi	s0,sp,64
  for(inum = 1; inum < sb.ninodes; inum++){
    800039ac:	0001b717          	auipc	a4,0x1b
    800039b0:	79072703          	lw	a4,1936(a4) # 8001f13c <sb+0xc>
    800039b4:	4785                	li	a5,1
    800039b6:	06e7f063          	bgeu	a5,a4,80003a16 <ialloc+0x72>
    800039ba:	f426                	sd	s1,40(sp)
    800039bc:	f04a                	sd	s2,32(sp)
    800039be:	ec4e                	sd	s3,24(sp)
    800039c0:	e852                	sd	s4,16(sp)
    800039c2:	e456                	sd	s5,8(sp)
    800039c4:	e05a                	sd	s6,0(sp)
    800039c6:	8aaa                	mv	s5,a0
    800039c8:	8b2e                	mv	s6,a1
    800039ca:	4905                	li	s2,1
    bp = bread(dev, IBLOCK(inum, sb));
    800039cc:	0001ba17          	auipc	s4,0x1b
    800039d0:	764a0a13          	addi	s4,s4,1892 # 8001f130 <sb>
    800039d4:	00495593          	srli	a1,s2,0x4
    800039d8:	018a2783          	lw	a5,24(s4)
    800039dc:	9dbd                	addw	a1,a1,a5
    800039de:	8556                	mv	a0,s5
    800039e0:	a2bff0ef          	jal	8000340a <bread>
    800039e4:	84aa                	mv	s1,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    800039e6:	05850993          	addi	s3,a0,88
    800039ea:	00f97793          	andi	a5,s2,15
    800039ee:	079a                	slli	a5,a5,0x6
    800039f0:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    800039f2:	00099783          	lh	a5,0(s3)
    800039f6:	cb9d                	beqz	a5,80003a2c <ialloc+0x88>
    brelse(bp);
    800039f8:	b43ff0ef          	jal	8000353a <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    800039fc:	0905                	addi	s2,s2,1
    800039fe:	00ca2703          	lw	a4,12(s4)
    80003a02:	0009079b          	sext.w	a5,s2
    80003a06:	fce7e7e3          	bltu	a5,a4,800039d4 <ialloc+0x30>
    80003a0a:	74a2                	ld	s1,40(sp)
    80003a0c:	7902                	ld	s2,32(sp)
    80003a0e:	69e2                	ld	s3,24(sp)
    80003a10:	6a42                	ld	s4,16(sp)
    80003a12:	6aa2                	ld	s5,8(sp)
    80003a14:	6b02                	ld	s6,0(sp)
  printf("ialloc: no inodes\n");
    80003a16:	00005517          	auipc	a0,0x5
    80003a1a:	a6250513          	addi	a0,a0,-1438 # 80008478 <etext+0x478>
    80003a1e:	b0ffc0ef          	jal	8000052c <printf>
  return 0;
    80003a22:	4501                	li	a0,0
}
    80003a24:	70e2                	ld	ra,56(sp)
    80003a26:	7442                	ld	s0,48(sp)
    80003a28:	6121                	addi	sp,sp,64
    80003a2a:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    80003a2c:	04000613          	li	a2,64
    80003a30:	4581                	li	a1,0
    80003a32:	854e                	mv	a0,s3
    80003a34:	b5cfd0ef          	jal	80000d90 <memset>
      dip->type = type;
    80003a38:	01699023          	sh	s6,0(s3)
      log_write(bp);   // mark it allocated on the disk
    80003a3c:	8526                	mv	a0,s1
    80003a3e:	445000ef          	jal	80004682 <log_write>
      brelse(bp);
    80003a42:	8526                	mv	a0,s1
    80003a44:	af7ff0ef          	jal	8000353a <brelse>
      return iget(dev, inum);
    80003a48:	0009059b          	sext.w	a1,s2
    80003a4c:	8556                	mv	a0,s5
    80003a4e:	e53ff0ef          	jal	800038a0 <iget>
    80003a52:	74a2                	ld	s1,40(sp)
    80003a54:	7902                	ld	s2,32(sp)
    80003a56:	69e2                	ld	s3,24(sp)
    80003a58:	6a42                	ld	s4,16(sp)
    80003a5a:	6aa2                	ld	s5,8(sp)
    80003a5c:	6b02                	ld	s6,0(sp)
    80003a5e:	b7d9                	j	80003a24 <ialloc+0x80>

0000000080003a60 <iupdate>:
{
    80003a60:	1101                	addi	sp,sp,-32
    80003a62:	ec06                	sd	ra,24(sp)
    80003a64:	e822                	sd	s0,16(sp)
    80003a66:	e426                	sd	s1,8(sp)
    80003a68:	e04a                	sd	s2,0(sp)
    80003a6a:	1000                	addi	s0,sp,32
    80003a6c:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003a6e:	415c                	lw	a5,4(a0)
    80003a70:	0047d79b          	srliw	a5,a5,0x4
    80003a74:	0001b597          	auipc	a1,0x1b
    80003a78:	6d45a583          	lw	a1,1748(a1) # 8001f148 <sb+0x18>
    80003a7c:	9dbd                	addw	a1,a1,a5
    80003a7e:	4108                	lw	a0,0(a0)
    80003a80:	98bff0ef          	jal	8000340a <bread>
    80003a84:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003a86:	05850793          	addi	a5,a0,88
    80003a8a:	40d8                	lw	a4,4(s1)
    80003a8c:	8b3d                	andi	a4,a4,15
    80003a8e:	071a                	slli	a4,a4,0x6
    80003a90:	97ba                	add	a5,a5,a4
  dip->type = ip->type;
    80003a92:	04449703          	lh	a4,68(s1)
    80003a96:	00e79023          	sh	a4,0(a5)
  dip->major = ip->major;
    80003a9a:	04649703          	lh	a4,70(s1)
    80003a9e:	00e79123          	sh	a4,2(a5)
  dip->minor = ip->minor;
    80003aa2:	04849703          	lh	a4,72(s1)
    80003aa6:	00e79223          	sh	a4,4(a5)
  dip->nlink = ip->nlink;
    80003aaa:	04a49703          	lh	a4,74(s1)
    80003aae:	00e79323          	sh	a4,6(a5)
  dip->size = ip->size;
    80003ab2:	44f8                	lw	a4,76(s1)
    80003ab4:	c798                	sw	a4,8(a5)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80003ab6:	03400613          	li	a2,52
    80003aba:	05048593          	addi	a1,s1,80
    80003abe:	00c78513          	addi	a0,a5,12
    80003ac2:	b2afd0ef          	jal	80000dec <memmove>
  log_write(bp);
    80003ac6:	854a                	mv	a0,s2
    80003ac8:	3bb000ef          	jal	80004682 <log_write>
  brelse(bp);
    80003acc:	854a                	mv	a0,s2
    80003ace:	a6dff0ef          	jal	8000353a <brelse>
}
    80003ad2:	60e2                	ld	ra,24(sp)
    80003ad4:	6442                	ld	s0,16(sp)
    80003ad6:	64a2                	ld	s1,8(sp)
    80003ad8:	6902                	ld	s2,0(sp)
    80003ada:	6105                	addi	sp,sp,32
    80003adc:	8082                	ret

0000000080003ade <idup>:
{
    80003ade:	1101                	addi	sp,sp,-32
    80003ae0:	ec06                	sd	ra,24(sp)
    80003ae2:	e822                	sd	s0,16(sp)
    80003ae4:	e426                	sd	s1,8(sp)
    80003ae6:	1000                	addi	s0,sp,32
    80003ae8:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003aea:	0001b517          	auipc	a0,0x1b
    80003aee:	66650513          	addi	a0,a0,1638 # 8001f150 <itable>
    80003af2:	9cafd0ef          	jal	80000cbc <acquire>
  ip->ref++;
    80003af6:	449c                	lw	a5,8(s1)
    80003af8:	2785                	addiw	a5,a5,1
    80003afa:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003afc:	0001b517          	auipc	a0,0x1b
    80003b00:	65450513          	addi	a0,a0,1620 # 8001f150 <itable>
    80003b04:	a50fd0ef          	jal	80000d54 <release>
}
    80003b08:	8526                	mv	a0,s1
    80003b0a:	60e2                	ld	ra,24(sp)
    80003b0c:	6442                	ld	s0,16(sp)
    80003b0e:	64a2                	ld	s1,8(sp)
    80003b10:	6105                	addi	sp,sp,32
    80003b12:	8082                	ret

0000000080003b14 <ilock>:
{
    80003b14:	1101                	addi	sp,sp,-32
    80003b16:	ec06                	sd	ra,24(sp)
    80003b18:	e822                	sd	s0,16(sp)
    80003b1a:	e426                	sd	s1,8(sp)
    80003b1c:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    80003b1e:	cd19                	beqz	a0,80003b3c <ilock+0x28>
    80003b20:	84aa                	mv	s1,a0
    80003b22:	451c                	lw	a5,8(a0)
    80003b24:	00f05c63          	blez	a5,80003b3c <ilock+0x28>
  acquiresleep(&ip->lock);
    80003b28:	0541                	addi	a0,a0,16
    80003b2a:	451000ef          	jal	8000477a <acquiresleep>
  if(ip->valid == 0){
    80003b2e:	40bc                	lw	a5,64(s1)
    80003b30:	cf89                	beqz	a5,80003b4a <ilock+0x36>
}
    80003b32:	60e2                	ld	ra,24(sp)
    80003b34:	6442                	ld	s0,16(sp)
    80003b36:	64a2                	ld	s1,8(sp)
    80003b38:	6105                	addi	sp,sp,32
    80003b3a:	8082                	ret
    80003b3c:	e04a                	sd	s2,0(sp)
    panic("ilock");
    80003b3e:	00005517          	auipc	a0,0x5
    80003b42:	95250513          	addi	a0,a0,-1710 # 80008490 <etext+0x490>
    80003b46:	ccdfc0ef          	jal	80000812 <panic>
    80003b4a:	e04a                	sd	s2,0(sp)
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003b4c:	40dc                	lw	a5,4(s1)
    80003b4e:	0047d79b          	srliw	a5,a5,0x4
    80003b52:	0001b597          	auipc	a1,0x1b
    80003b56:	5f65a583          	lw	a1,1526(a1) # 8001f148 <sb+0x18>
    80003b5a:	9dbd                	addw	a1,a1,a5
    80003b5c:	4088                	lw	a0,0(s1)
    80003b5e:	8adff0ef          	jal	8000340a <bread>
    80003b62:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003b64:	05850593          	addi	a1,a0,88
    80003b68:	40dc                	lw	a5,4(s1)
    80003b6a:	8bbd                	andi	a5,a5,15
    80003b6c:	079a                	slli	a5,a5,0x6
    80003b6e:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    80003b70:	00059783          	lh	a5,0(a1)
    80003b74:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    80003b78:	00259783          	lh	a5,2(a1)
    80003b7c:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    80003b80:	00459783          	lh	a5,4(a1)
    80003b84:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80003b88:	00659783          	lh	a5,6(a1)
    80003b8c:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    80003b90:	459c                	lw	a5,8(a1)
    80003b92:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80003b94:	03400613          	li	a2,52
    80003b98:	05b1                	addi	a1,a1,12
    80003b9a:	05048513          	addi	a0,s1,80
    80003b9e:	a4efd0ef          	jal	80000dec <memmove>
    brelse(bp);
    80003ba2:	854a                	mv	a0,s2
    80003ba4:	997ff0ef          	jal	8000353a <brelse>
    ip->valid = 1;
    80003ba8:	4785                	li	a5,1
    80003baa:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    80003bac:	04449783          	lh	a5,68(s1)
    80003bb0:	c399                	beqz	a5,80003bb6 <ilock+0xa2>
    80003bb2:	6902                	ld	s2,0(sp)
    80003bb4:	bfbd                	j	80003b32 <ilock+0x1e>
      panic("ilock: no type");
    80003bb6:	00005517          	auipc	a0,0x5
    80003bba:	8e250513          	addi	a0,a0,-1822 # 80008498 <etext+0x498>
    80003bbe:	c55fc0ef          	jal	80000812 <panic>

0000000080003bc2 <iunlock>:
{
    80003bc2:	1101                	addi	sp,sp,-32
    80003bc4:	ec06                	sd	ra,24(sp)
    80003bc6:	e822                	sd	s0,16(sp)
    80003bc8:	e426                	sd	s1,8(sp)
    80003bca:	e04a                	sd	s2,0(sp)
    80003bcc:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80003bce:	c505                	beqz	a0,80003bf6 <iunlock+0x34>
    80003bd0:	84aa                	mv	s1,a0
    80003bd2:	01050913          	addi	s2,a0,16
    80003bd6:	854a                	mv	a0,s2
    80003bd8:	421000ef          	jal	800047f8 <holdingsleep>
    80003bdc:	cd09                	beqz	a0,80003bf6 <iunlock+0x34>
    80003bde:	449c                	lw	a5,8(s1)
    80003be0:	00f05b63          	blez	a5,80003bf6 <iunlock+0x34>
  releasesleep(&ip->lock);
    80003be4:	854a                	mv	a0,s2
    80003be6:	3db000ef          	jal	800047c0 <releasesleep>
}
    80003bea:	60e2                	ld	ra,24(sp)
    80003bec:	6442                	ld	s0,16(sp)
    80003bee:	64a2                	ld	s1,8(sp)
    80003bf0:	6902                	ld	s2,0(sp)
    80003bf2:	6105                	addi	sp,sp,32
    80003bf4:	8082                	ret
    panic("iunlock");
    80003bf6:	00005517          	auipc	a0,0x5
    80003bfa:	8b250513          	addi	a0,a0,-1870 # 800084a8 <etext+0x4a8>
    80003bfe:	c15fc0ef          	jal	80000812 <panic>

0000000080003c02 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    80003c02:	7179                	addi	sp,sp,-48
    80003c04:	f406                	sd	ra,40(sp)
    80003c06:	f022                	sd	s0,32(sp)
    80003c08:	ec26                	sd	s1,24(sp)
    80003c0a:	e84a                	sd	s2,16(sp)
    80003c0c:	e44e                	sd	s3,8(sp)
    80003c0e:	1800                	addi	s0,sp,48
    80003c10:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    80003c12:	05050493          	addi	s1,a0,80
    80003c16:	08050913          	addi	s2,a0,128
    80003c1a:	a021                	j	80003c22 <itrunc+0x20>
    80003c1c:	0491                	addi	s1,s1,4
    80003c1e:	01248b63          	beq	s1,s2,80003c34 <itrunc+0x32>
    if(ip->addrs[i]){
    80003c22:	408c                	lw	a1,0(s1)
    80003c24:	dde5                	beqz	a1,80003c1c <itrunc+0x1a>
      bfree(ip->dev, ip->addrs[i]);
    80003c26:	0009a503          	lw	a0,0(s3)
    80003c2a:	a17ff0ef          	jal	80003640 <bfree>
      ip->addrs[i] = 0;
    80003c2e:	0004a023          	sw	zero,0(s1)
    80003c32:	b7ed                	j	80003c1c <itrunc+0x1a>
    }
  }

  if(ip->addrs[NDIRECT]){
    80003c34:	0809a583          	lw	a1,128(s3)
    80003c38:	ed89                	bnez	a1,80003c52 <itrunc+0x50>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80003c3a:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    80003c3e:	854e                	mv	a0,s3
    80003c40:	e21ff0ef          	jal	80003a60 <iupdate>
}
    80003c44:	70a2                	ld	ra,40(sp)
    80003c46:	7402                	ld	s0,32(sp)
    80003c48:	64e2                	ld	s1,24(sp)
    80003c4a:	6942                	ld	s2,16(sp)
    80003c4c:	69a2                	ld	s3,8(sp)
    80003c4e:	6145                	addi	sp,sp,48
    80003c50:	8082                	ret
    80003c52:	e052                	sd	s4,0(sp)
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80003c54:	0009a503          	lw	a0,0(s3)
    80003c58:	fb2ff0ef          	jal	8000340a <bread>
    80003c5c:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    80003c5e:	05850493          	addi	s1,a0,88
    80003c62:	45850913          	addi	s2,a0,1112
    80003c66:	a021                	j	80003c6e <itrunc+0x6c>
    80003c68:	0491                	addi	s1,s1,4
    80003c6a:	01248963          	beq	s1,s2,80003c7c <itrunc+0x7a>
      if(a[j])
    80003c6e:	408c                	lw	a1,0(s1)
    80003c70:	dde5                	beqz	a1,80003c68 <itrunc+0x66>
        bfree(ip->dev, a[j]);
    80003c72:	0009a503          	lw	a0,0(s3)
    80003c76:	9cbff0ef          	jal	80003640 <bfree>
    80003c7a:	b7fd                	j	80003c68 <itrunc+0x66>
    brelse(bp);
    80003c7c:	8552                	mv	a0,s4
    80003c7e:	8bdff0ef          	jal	8000353a <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80003c82:	0809a583          	lw	a1,128(s3)
    80003c86:	0009a503          	lw	a0,0(s3)
    80003c8a:	9b7ff0ef          	jal	80003640 <bfree>
    ip->addrs[NDIRECT] = 0;
    80003c8e:	0809a023          	sw	zero,128(s3)
    80003c92:	6a02                	ld	s4,0(sp)
    80003c94:	b75d                	j	80003c3a <itrunc+0x38>

0000000080003c96 <iput>:
{
    80003c96:	1101                	addi	sp,sp,-32
    80003c98:	ec06                	sd	ra,24(sp)
    80003c9a:	e822                	sd	s0,16(sp)
    80003c9c:	e426                	sd	s1,8(sp)
    80003c9e:	1000                	addi	s0,sp,32
    80003ca0:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003ca2:	0001b517          	auipc	a0,0x1b
    80003ca6:	4ae50513          	addi	a0,a0,1198 # 8001f150 <itable>
    80003caa:	812fd0ef          	jal	80000cbc <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003cae:	4498                	lw	a4,8(s1)
    80003cb0:	4785                	li	a5,1
    80003cb2:	02f70063          	beq	a4,a5,80003cd2 <iput+0x3c>
  ip->ref--;
    80003cb6:	449c                	lw	a5,8(s1)
    80003cb8:	37fd                	addiw	a5,a5,-1
    80003cba:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003cbc:	0001b517          	auipc	a0,0x1b
    80003cc0:	49450513          	addi	a0,a0,1172 # 8001f150 <itable>
    80003cc4:	890fd0ef          	jal	80000d54 <release>
}
    80003cc8:	60e2                	ld	ra,24(sp)
    80003cca:	6442                	ld	s0,16(sp)
    80003ccc:	64a2                	ld	s1,8(sp)
    80003cce:	6105                	addi	sp,sp,32
    80003cd0:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003cd2:	40bc                	lw	a5,64(s1)
    80003cd4:	d3ed                	beqz	a5,80003cb6 <iput+0x20>
    80003cd6:	04a49783          	lh	a5,74(s1)
    80003cda:	fff1                	bnez	a5,80003cb6 <iput+0x20>
    80003cdc:	e04a                	sd	s2,0(sp)
    acquiresleep(&ip->lock);
    80003cde:	01048913          	addi	s2,s1,16
    80003ce2:	854a                	mv	a0,s2
    80003ce4:	297000ef          	jal	8000477a <acquiresleep>
    release(&itable.lock);
    80003ce8:	0001b517          	auipc	a0,0x1b
    80003cec:	46850513          	addi	a0,a0,1128 # 8001f150 <itable>
    80003cf0:	864fd0ef          	jal	80000d54 <release>
    itrunc(ip);
    80003cf4:	8526                	mv	a0,s1
    80003cf6:	f0dff0ef          	jal	80003c02 <itrunc>
    ip->type = 0;
    80003cfa:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    80003cfe:	8526                	mv	a0,s1
    80003d00:	d61ff0ef          	jal	80003a60 <iupdate>
    ip->valid = 0;
    80003d04:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80003d08:	854a                	mv	a0,s2
    80003d0a:	2b7000ef          	jal	800047c0 <releasesleep>
    acquire(&itable.lock);
    80003d0e:	0001b517          	auipc	a0,0x1b
    80003d12:	44250513          	addi	a0,a0,1090 # 8001f150 <itable>
    80003d16:	fa7fc0ef          	jal	80000cbc <acquire>
    80003d1a:	6902                	ld	s2,0(sp)
    80003d1c:	bf69                	j	80003cb6 <iput+0x20>

0000000080003d1e <iunlockput>:
{
    80003d1e:	1101                	addi	sp,sp,-32
    80003d20:	ec06                	sd	ra,24(sp)
    80003d22:	e822                	sd	s0,16(sp)
    80003d24:	e426                	sd	s1,8(sp)
    80003d26:	1000                	addi	s0,sp,32
    80003d28:	84aa                	mv	s1,a0
  iunlock(ip);
    80003d2a:	e99ff0ef          	jal	80003bc2 <iunlock>
  iput(ip);
    80003d2e:	8526                	mv	a0,s1
    80003d30:	f67ff0ef          	jal	80003c96 <iput>
}
    80003d34:	60e2                	ld	ra,24(sp)
    80003d36:	6442                	ld	s0,16(sp)
    80003d38:	64a2                	ld	s1,8(sp)
    80003d3a:	6105                	addi	sp,sp,32
    80003d3c:	8082                	ret

0000000080003d3e <ireclaim>:
  for (int inum = 1; inum < sb.ninodes; inum++) {
    80003d3e:	0001b717          	auipc	a4,0x1b
    80003d42:	3fe72703          	lw	a4,1022(a4) # 8001f13c <sb+0xc>
    80003d46:	4785                	li	a5,1
    80003d48:	0ae7ff63          	bgeu	a5,a4,80003e06 <ireclaim+0xc8>
{
    80003d4c:	7139                	addi	sp,sp,-64
    80003d4e:	fc06                	sd	ra,56(sp)
    80003d50:	f822                	sd	s0,48(sp)
    80003d52:	f426                	sd	s1,40(sp)
    80003d54:	f04a                	sd	s2,32(sp)
    80003d56:	ec4e                	sd	s3,24(sp)
    80003d58:	e852                	sd	s4,16(sp)
    80003d5a:	e456                	sd	s5,8(sp)
    80003d5c:	e05a                	sd	s6,0(sp)
    80003d5e:	0080                	addi	s0,sp,64
  for (int inum = 1; inum < sb.ninodes; inum++) {
    80003d60:	4485                	li	s1,1
    struct buf *bp = bread(dev, IBLOCK(inum, sb));
    80003d62:	00050a1b          	sext.w	s4,a0
    80003d66:	0001ba97          	auipc	s5,0x1b
    80003d6a:	3caa8a93          	addi	s5,s5,970 # 8001f130 <sb>
      printf("ireclaim: orphaned inode %d\n", inum);
    80003d6e:	00004b17          	auipc	s6,0x4
    80003d72:	742b0b13          	addi	s6,s6,1858 # 800084b0 <etext+0x4b0>
    80003d76:	a099                	j	80003dbc <ireclaim+0x7e>
    80003d78:	85ce                	mv	a1,s3
    80003d7a:	855a                	mv	a0,s6
    80003d7c:	fb0fc0ef          	jal	8000052c <printf>
      ip = iget(dev, inum);
    80003d80:	85ce                	mv	a1,s3
    80003d82:	8552                	mv	a0,s4
    80003d84:	b1dff0ef          	jal	800038a0 <iget>
    80003d88:	89aa                	mv	s3,a0
    brelse(bp);
    80003d8a:	854a                	mv	a0,s2
    80003d8c:	faeff0ef          	jal	8000353a <brelse>
    if (ip) {
    80003d90:	00098f63          	beqz	s3,80003dae <ireclaim+0x70>
      begin_op();
    80003d94:	76a000ef          	jal	800044fe <begin_op>
      ilock(ip);
    80003d98:	854e                	mv	a0,s3
    80003d9a:	d7bff0ef          	jal	80003b14 <ilock>
      iunlock(ip);
    80003d9e:	854e                	mv	a0,s3
    80003da0:	e23ff0ef          	jal	80003bc2 <iunlock>
      iput(ip);
    80003da4:	854e                	mv	a0,s3
    80003da6:	ef1ff0ef          	jal	80003c96 <iput>
      end_op();
    80003daa:	7be000ef          	jal	80004568 <end_op>
  for (int inum = 1; inum < sb.ninodes; inum++) {
    80003dae:	0485                	addi	s1,s1,1
    80003db0:	00caa703          	lw	a4,12(s5)
    80003db4:	0004879b          	sext.w	a5,s1
    80003db8:	02e7fd63          	bgeu	a5,a4,80003df2 <ireclaim+0xb4>
    80003dbc:	0004899b          	sext.w	s3,s1
    struct buf *bp = bread(dev, IBLOCK(inum, sb));
    80003dc0:	0044d593          	srli	a1,s1,0x4
    80003dc4:	018aa783          	lw	a5,24(s5)
    80003dc8:	9dbd                	addw	a1,a1,a5
    80003dca:	8552                	mv	a0,s4
    80003dcc:	e3eff0ef          	jal	8000340a <bread>
    80003dd0:	892a                	mv	s2,a0
    struct dinode *dip = (struct dinode *)bp->data + inum % IPB;
    80003dd2:	05850793          	addi	a5,a0,88
    80003dd6:	00f9f713          	andi	a4,s3,15
    80003dda:	071a                	slli	a4,a4,0x6
    80003ddc:	97ba                	add	a5,a5,a4
    if (dip->type != 0 && dip->nlink == 0) {  // is an orphaned inode
    80003dde:	00079703          	lh	a4,0(a5)
    80003de2:	c701                	beqz	a4,80003dea <ireclaim+0xac>
    80003de4:	00679783          	lh	a5,6(a5)
    80003de8:	dbc1                	beqz	a5,80003d78 <ireclaim+0x3a>
    brelse(bp);
    80003dea:	854a                	mv	a0,s2
    80003dec:	f4eff0ef          	jal	8000353a <brelse>
    if (ip) {
    80003df0:	bf7d                	j	80003dae <ireclaim+0x70>
}
    80003df2:	70e2                	ld	ra,56(sp)
    80003df4:	7442                	ld	s0,48(sp)
    80003df6:	74a2                	ld	s1,40(sp)
    80003df8:	7902                	ld	s2,32(sp)
    80003dfa:	69e2                	ld	s3,24(sp)
    80003dfc:	6a42                	ld	s4,16(sp)
    80003dfe:	6aa2                	ld	s5,8(sp)
    80003e00:	6b02                	ld	s6,0(sp)
    80003e02:	6121                	addi	sp,sp,64
    80003e04:	8082                	ret
    80003e06:	8082                	ret

0000000080003e08 <fsinit>:
fsinit(int dev) {
    80003e08:	7179                	addi	sp,sp,-48
    80003e0a:	f406                	sd	ra,40(sp)
    80003e0c:	f022                	sd	s0,32(sp)
    80003e0e:	ec26                	sd	s1,24(sp)
    80003e10:	e84a                	sd	s2,16(sp)
    80003e12:	e44e                	sd	s3,8(sp)
    80003e14:	1800                	addi	s0,sp,48
    80003e16:	84aa                	mv	s1,a0
  bp = bread(dev, 1);
    80003e18:	4585                	li	a1,1
    80003e1a:	df0ff0ef          	jal	8000340a <bread>
    80003e1e:	892a                	mv	s2,a0
  memmove(sb, bp->data, sizeof(*sb));
    80003e20:	0001b997          	auipc	s3,0x1b
    80003e24:	31098993          	addi	s3,s3,784 # 8001f130 <sb>
    80003e28:	02000613          	li	a2,32
    80003e2c:	05850593          	addi	a1,a0,88
    80003e30:	854e                	mv	a0,s3
    80003e32:	fbbfc0ef          	jal	80000dec <memmove>
  brelse(bp);
    80003e36:	854a                	mv	a0,s2
    80003e38:	f02ff0ef          	jal	8000353a <brelse>
  if(sb.magic != FSMAGIC)
    80003e3c:	0009a703          	lw	a4,0(s3)
    80003e40:	102037b7          	lui	a5,0x10203
    80003e44:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    80003e48:	02f71363          	bne	a4,a5,80003e6e <fsinit+0x66>
  initlog(dev, &sb);
    80003e4c:	0001b597          	auipc	a1,0x1b
    80003e50:	2e458593          	addi	a1,a1,740 # 8001f130 <sb>
    80003e54:	8526                	mv	a0,s1
    80003e56:	62a000ef          	jal	80004480 <initlog>
  ireclaim(dev);
    80003e5a:	8526                	mv	a0,s1
    80003e5c:	ee3ff0ef          	jal	80003d3e <ireclaim>
}
    80003e60:	70a2                	ld	ra,40(sp)
    80003e62:	7402                	ld	s0,32(sp)
    80003e64:	64e2                	ld	s1,24(sp)
    80003e66:	6942                	ld	s2,16(sp)
    80003e68:	69a2                	ld	s3,8(sp)
    80003e6a:	6145                	addi	sp,sp,48
    80003e6c:	8082                	ret
    panic("invalid file system");
    80003e6e:	00004517          	auipc	a0,0x4
    80003e72:	66250513          	addi	a0,a0,1634 # 800084d0 <etext+0x4d0>
    80003e76:	99dfc0ef          	jal	80000812 <panic>

0000000080003e7a <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80003e7a:	1141                	addi	sp,sp,-16
    80003e7c:	e422                	sd	s0,8(sp)
    80003e7e:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80003e80:	411c                	lw	a5,0(a0)
    80003e82:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80003e84:	415c                	lw	a5,4(a0)
    80003e86:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80003e88:	04451783          	lh	a5,68(a0)
    80003e8c:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80003e90:	04a51783          	lh	a5,74(a0)
    80003e94:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80003e98:	04c56783          	lwu	a5,76(a0)
    80003e9c:	e99c                	sd	a5,16(a1)
}
    80003e9e:	6422                	ld	s0,8(sp)
    80003ea0:	0141                	addi	sp,sp,16
    80003ea2:	8082                	ret

0000000080003ea4 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003ea4:	457c                	lw	a5,76(a0)
    80003ea6:	0ed7eb63          	bltu	a5,a3,80003f9c <readi+0xf8>
{
    80003eaa:	7159                	addi	sp,sp,-112
    80003eac:	f486                	sd	ra,104(sp)
    80003eae:	f0a2                	sd	s0,96(sp)
    80003eb0:	eca6                	sd	s1,88(sp)
    80003eb2:	e0d2                	sd	s4,64(sp)
    80003eb4:	fc56                	sd	s5,56(sp)
    80003eb6:	f85a                	sd	s6,48(sp)
    80003eb8:	f45e                	sd	s7,40(sp)
    80003eba:	1880                	addi	s0,sp,112
    80003ebc:	8b2a                	mv	s6,a0
    80003ebe:	8bae                	mv	s7,a1
    80003ec0:	8a32                	mv	s4,a2
    80003ec2:	84b6                	mv	s1,a3
    80003ec4:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    80003ec6:	9f35                	addw	a4,a4,a3
    return 0;
    80003ec8:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80003eca:	0cd76063          	bltu	a4,a3,80003f8a <readi+0xe6>
    80003ece:	e4ce                	sd	s3,72(sp)
  if(off + n > ip->size)
    80003ed0:	00e7f463          	bgeu	a5,a4,80003ed8 <readi+0x34>
    n = ip->size - off;
    80003ed4:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003ed8:	080a8f63          	beqz	s5,80003f76 <readi+0xd2>
    80003edc:	e8ca                	sd	s2,80(sp)
    80003ede:	f062                	sd	s8,32(sp)
    80003ee0:	ec66                	sd	s9,24(sp)
    80003ee2:	e86a                	sd	s10,16(sp)
    80003ee4:	e46e                	sd	s11,8(sp)
    80003ee6:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003ee8:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80003eec:	5c7d                	li	s8,-1
    80003eee:	a80d                	j	80003f20 <readi+0x7c>
    80003ef0:	020d1d93          	slli	s11,s10,0x20
    80003ef4:	020ddd93          	srli	s11,s11,0x20
    80003ef8:	05890613          	addi	a2,s2,88
    80003efc:	86ee                	mv	a3,s11
    80003efe:	963a                	add	a2,a2,a4
    80003f00:	85d2                	mv	a1,s4
    80003f02:	855e                	mv	a0,s7
    80003f04:	9a9fe0ef          	jal	800028ac <either_copyout>
    80003f08:	05850763          	beq	a0,s8,80003f56 <readi+0xb2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80003f0c:	854a                	mv	a0,s2
    80003f0e:	e2cff0ef          	jal	8000353a <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003f12:	013d09bb          	addw	s3,s10,s3
    80003f16:	009d04bb          	addw	s1,s10,s1
    80003f1a:	9a6e                	add	s4,s4,s11
    80003f1c:	0559f763          	bgeu	s3,s5,80003f6a <readi+0xc6>
    uint addr = bmap(ip, off/BSIZE);
    80003f20:	00a4d59b          	srliw	a1,s1,0xa
    80003f24:	855a                	mv	a0,s6
    80003f26:	8a7ff0ef          	jal	800037cc <bmap>
    80003f2a:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80003f2e:	c5b1                	beqz	a1,80003f7a <readi+0xd6>
    bp = bread(ip->dev, addr);
    80003f30:	000b2503          	lw	a0,0(s6)
    80003f34:	cd6ff0ef          	jal	8000340a <bread>
    80003f38:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003f3a:	3ff4f713          	andi	a4,s1,1023
    80003f3e:	40ec87bb          	subw	a5,s9,a4
    80003f42:	413a86bb          	subw	a3,s5,s3
    80003f46:	8d3e                	mv	s10,a5
    80003f48:	2781                	sext.w	a5,a5
    80003f4a:	0006861b          	sext.w	a2,a3
    80003f4e:	faf671e3          	bgeu	a2,a5,80003ef0 <readi+0x4c>
    80003f52:	8d36                	mv	s10,a3
    80003f54:	bf71                	j	80003ef0 <readi+0x4c>
      brelse(bp);
    80003f56:	854a                	mv	a0,s2
    80003f58:	de2ff0ef          	jal	8000353a <brelse>
      tot = -1;
    80003f5c:	59fd                	li	s3,-1
      break;
    80003f5e:	6946                	ld	s2,80(sp)
    80003f60:	7c02                	ld	s8,32(sp)
    80003f62:	6ce2                	ld	s9,24(sp)
    80003f64:	6d42                	ld	s10,16(sp)
    80003f66:	6da2                	ld	s11,8(sp)
    80003f68:	a831                	j	80003f84 <readi+0xe0>
    80003f6a:	6946                	ld	s2,80(sp)
    80003f6c:	7c02                	ld	s8,32(sp)
    80003f6e:	6ce2                	ld	s9,24(sp)
    80003f70:	6d42                	ld	s10,16(sp)
    80003f72:	6da2                	ld	s11,8(sp)
    80003f74:	a801                	j	80003f84 <readi+0xe0>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003f76:	89d6                	mv	s3,s5
    80003f78:	a031                	j	80003f84 <readi+0xe0>
    80003f7a:	6946                	ld	s2,80(sp)
    80003f7c:	7c02                	ld	s8,32(sp)
    80003f7e:	6ce2                	ld	s9,24(sp)
    80003f80:	6d42                	ld	s10,16(sp)
    80003f82:	6da2                	ld	s11,8(sp)
  }
  return tot;
    80003f84:	0009851b          	sext.w	a0,s3
    80003f88:	69a6                	ld	s3,72(sp)
}
    80003f8a:	70a6                	ld	ra,104(sp)
    80003f8c:	7406                	ld	s0,96(sp)
    80003f8e:	64e6                	ld	s1,88(sp)
    80003f90:	6a06                	ld	s4,64(sp)
    80003f92:	7ae2                	ld	s5,56(sp)
    80003f94:	7b42                	ld	s6,48(sp)
    80003f96:	7ba2                	ld	s7,40(sp)
    80003f98:	6165                	addi	sp,sp,112
    80003f9a:	8082                	ret
    return 0;
    80003f9c:	4501                	li	a0,0
}
    80003f9e:	8082                	ret

0000000080003fa0 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003fa0:	457c                	lw	a5,76(a0)
    80003fa2:	10d7e063          	bltu	a5,a3,800040a2 <writei+0x102>
{
    80003fa6:	7159                	addi	sp,sp,-112
    80003fa8:	f486                	sd	ra,104(sp)
    80003faa:	f0a2                	sd	s0,96(sp)
    80003fac:	e8ca                	sd	s2,80(sp)
    80003fae:	e0d2                	sd	s4,64(sp)
    80003fb0:	fc56                	sd	s5,56(sp)
    80003fb2:	f85a                	sd	s6,48(sp)
    80003fb4:	f45e                	sd	s7,40(sp)
    80003fb6:	1880                	addi	s0,sp,112
    80003fb8:	8aaa                	mv	s5,a0
    80003fba:	8bae                	mv	s7,a1
    80003fbc:	8a32                	mv	s4,a2
    80003fbe:	8936                	mv	s2,a3
    80003fc0:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003fc2:	00e687bb          	addw	a5,a3,a4
    80003fc6:	0ed7e063          	bltu	a5,a3,800040a6 <writei+0x106>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80003fca:	00043737          	lui	a4,0x43
    80003fce:	0cf76e63          	bltu	a4,a5,800040aa <writei+0x10a>
    80003fd2:	e4ce                	sd	s3,72(sp)
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003fd4:	0a0b0f63          	beqz	s6,80004092 <writei+0xf2>
    80003fd8:	eca6                	sd	s1,88(sp)
    80003fda:	f062                	sd	s8,32(sp)
    80003fdc:	ec66                	sd	s9,24(sp)
    80003fde:	e86a                	sd	s10,16(sp)
    80003fe0:	e46e                	sd	s11,8(sp)
    80003fe2:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003fe4:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80003fe8:	5c7d                	li	s8,-1
    80003fea:	a825                	j	80004022 <writei+0x82>
    80003fec:	020d1d93          	slli	s11,s10,0x20
    80003ff0:	020ddd93          	srli	s11,s11,0x20
    80003ff4:	05848513          	addi	a0,s1,88
    80003ff8:	86ee                	mv	a3,s11
    80003ffa:	8652                	mv	a2,s4
    80003ffc:	85de                	mv	a1,s7
    80003ffe:	953a                	add	a0,a0,a4
    80004000:	8f7fe0ef          	jal	800028f6 <either_copyin>
    80004004:	05850a63          	beq	a0,s8,80004058 <writei+0xb8>
      brelse(bp);
      break;
    }
    log_write(bp);
    80004008:	8526                	mv	a0,s1
    8000400a:	678000ef          	jal	80004682 <log_write>
    brelse(bp);
    8000400e:	8526                	mv	a0,s1
    80004010:	d2aff0ef          	jal	8000353a <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80004014:	013d09bb          	addw	s3,s10,s3
    80004018:	012d093b          	addw	s2,s10,s2
    8000401c:	9a6e                	add	s4,s4,s11
    8000401e:	0569f063          	bgeu	s3,s6,8000405e <writei+0xbe>
    uint addr = bmap(ip, off/BSIZE);
    80004022:	00a9559b          	srliw	a1,s2,0xa
    80004026:	8556                	mv	a0,s5
    80004028:	fa4ff0ef          	jal	800037cc <bmap>
    8000402c:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80004030:	c59d                	beqz	a1,8000405e <writei+0xbe>
    bp = bread(ip->dev, addr);
    80004032:	000aa503          	lw	a0,0(s5)
    80004036:	bd4ff0ef          	jal	8000340a <bread>
    8000403a:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    8000403c:	3ff97713          	andi	a4,s2,1023
    80004040:	40ec87bb          	subw	a5,s9,a4
    80004044:	413b06bb          	subw	a3,s6,s3
    80004048:	8d3e                	mv	s10,a5
    8000404a:	2781                	sext.w	a5,a5
    8000404c:	0006861b          	sext.w	a2,a3
    80004050:	f8f67ee3          	bgeu	a2,a5,80003fec <writei+0x4c>
    80004054:	8d36                	mv	s10,a3
    80004056:	bf59                	j	80003fec <writei+0x4c>
      brelse(bp);
    80004058:	8526                	mv	a0,s1
    8000405a:	ce0ff0ef          	jal	8000353a <brelse>
  }

  if(off > ip->size)
    8000405e:	04caa783          	lw	a5,76(s5)
    80004062:	0327fa63          	bgeu	a5,s2,80004096 <writei+0xf6>
    ip->size = off;
    80004066:	052aa623          	sw	s2,76(s5)
    8000406a:	64e6                	ld	s1,88(sp)
    8000406c:	7c02                	ld	s8,32(sp)
    8000406e:	6ce2                	ld	s9,24(sp)
    80004070:	6d42                	ld	s10,16(sp)
    80004072:	6da2                	ld	s11,8(sp)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80004074:	8556                	mv	a0,s5
    80004076:	9ebff0ef          	jal	80003a60 <iupdate>

  return tot;
    8000407a:	0009851b          	sext.w	a0,s3
    8000407e:	69a6                	ld	s3,72(sp)
}
    80004080:	70a6                	ld	ra,104(sp)
    80004082:	7406                	ld	s0,96(sp)
    80004084:	6946                	ld	s2,80(sp)
    80004086:	6a06                	ld	s4,64(sp)
    80004088:	7ae2                	ld	s5,56(sp)
    8000408a:	7b42                	ld	s6,48(sp)
    8000408c:	7ba2                	ld	s7,40(sp)
    8000408e:	6165                	addi	sp,sp,112
    80004090:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80004092:	89da                	mv	s3,s6
    80004094:	b7c5                	j	80004074 <writei+0xd4>
    80004096:	64e6                	ld	s1,88(sp)
    80004098:	7c02                	ld	s8,32(sp)
    8000409a:	6ce2                	ld	s9,24(sp)
    8000409c:	6d42                	ld	s10,16(sp)
    8000409e:	6da2                	ld	s11,8(sp)
    800040a0:	bfd1                	j	80004074 <writei+0xd4>
    return -1;
    800040a2:	557d                	li	a0,-1
}
    800040a4:	8082                	ret
    return -1;
    800040a6:	557d                	li	a0,-1
    800040a8:	bfe1                	j	80004080 <writei+0xe0>
    return -1;
    800040aa:	557d                	li	a0,-1
    800040ac:	bfd1                	j	80004080 <writei+0xe0>

00000000800040ae <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    800040ae:	1141                	addi	sp,sp,-16
    800040b0:	e406                	sd	ra,8(sp)
    800040b2:	e022                	sd	s0,0(sp)
    800040b4:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    800040b6:	4639                	li	a2,14
    800040b8:	da5fc0ef          	jal	80000e5c <strncmp>
}
    800040bc:	60a2                	ld	ra,8(sp)
    800040be:	6402                	ld	s0,0(sp)
    800040c0:	0141                	addi	sp,sp,16
    800040c2:	8082                	ret

00000000800040c4 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    800040c4:	7139                	addi	sp,sp,-64
    800040c6:	fc06                	sd	ra,56(sp)
    800040c8:	f822                	sd	s0,48(sp)
    800040ca:	f426                	sd	s1,40(sp)
    800040cc:	f04a                	sd	s2,32(sp)
    800040ce:	ec4e                	sd	s3,24(sp)
    800040d0:	e852                	sd	s4,16(sp)
    800040d2:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    800040d4:	04451703          	lh	a4,68(a0)
    800040d8:	4785                	li	a5,1
    800040da:	00f71a63          	bne	a4,a5,800040ee <dirlookup+0x2a>
    800040de:	892a                	mv	s2,a0
    800040e0:	89ae                	mv	s3,a1
    800040e2:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    800040e4:	457c                	lw	a5,76(a0)
    800040e6:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    800040e8:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    800040ea:	e39d                	bnez	a5,80004110 <dirlookup+0x4c>
    800040ec:	a095                	j	80004150 <dirlookup+0x8c>
    panic("dirlookup not DIR");
    800040ee:	00004517          	auipc	a0,0x4
    800040f2:	3fa50513          	addi	a0,a0,1018 # 800084e8 <etext+0x4e8>
    800040f6:	f1cfc0ef          	jal	80000812 <panic>
      panic("dirlookup read");
    800040fa:	00004517          	auipc	a0,0x4
    800040fe:	40650513          	addi	a0,a0,1030 # 80008500 <etext+0x500>
    80004102:	f10fc0ef          	jal	80000812 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004106:	24c1                	addiw	s1,s1,16
    80004108:	04c92783          	lw	a5,76(s2)
    8000410c:	04f4f163          	bgeu	s1,a5,8000414e <dirlookup+0x8a>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004110:	4741                	li	a4,16
    80004112:	86a6                	mv	a3,s1
    80004114:	fc040613          	addi	a2,s0,-64
    80004118:	4581                	li	a1,0
    8000411a:	854a                	mv	a0,s2
    8000411c:	d89ff0ef          	jal	80003ea4 <readi>
    80004120:	47c1                	li	a5,16
    80004122:	fcf51ce3          	bne	a0,a5,800040fa <dirlookup+0x36>
    if(de.inum == 0)
    80004126:	fc045783          	lhu	a5,-64(s0)
    8000412a:	dff1                	beqz	a5,80004106 <dirlookup+0x42>
    if(namecmp(name, de.name) == 0){
    8000412c:	fc240593          	addi	a1,s0,-62
    80004130:	854e                	mv	a0,s3
    80004132:	f7dff0ef          	jal	800040ae <namecmp>
    80004136:	f961                	bnez	a0,80004106 <dirlookup+0x42>
      if(poff)
    80004138:	000a0463          	beqz	s4,80004140 <dirlookup+0x7c>
        *poff = off;
    8000413c:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    80004140:	fc045583          	lhu	a1,-64(s0)
    80004144:	00092503          	lw	a0,0(s2)
    80004148:	f58ff0ef          	jal	800038a0 <iget>
    8000414c:	a011                	j	80004150 <dirlookup+0x8c>
  return 0;
    8000414e:	4501                	li	a0,0
}
    80004150:	70e2                	ld	ra,56(sp)
    80004152:	7442                	ld	s0,48(sp)
    80004154:	74a2                	ld	s1,40(sp)
    80004156:	7902                	ld	s2,32(sp)
    80004158:	69e2                	ld	s3,24(sp)
    8000415a:	6a42                	ld	s4,16(sp)
    8000415c:	6121                	addi	sp,sp,64
    8000415e:	8082                	ret

0000000080004160 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80004160:	711d                	addi	sp,sp,-96
    80004162:	ec86                	sd	ra,88(sp)
    80004164:	e8a2                	sd	s0,80(sp)
    80004166:	e4a6                	sd	s1,72(sp)
    80004168:	e0ca                	sd	s2,64(sp)
    8000416a:	fc4e                	sd	s3,56(sp)
    8000416c:	f852                	sd	s4,48(sp)
    8000416e:	f456                	sd	s5,40(sp)
    80004170:	f05a                	sd	s6,32(sp)
    80004172:	ec5e                	sd	s7,24(sp)
    80004174:	e862                	sd	s8,16(sp)
    80004176:	e466                	sd	s9,8(sp)
    80004178:	1080                	addi	s0,sp,96
    8000417a:	84aa                	mv	s1,a0
    8000417c:	8b2e                	mv	s6,a1
    8000417e:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    80004180:	00054703          	lbu	a4,0(a0)
    80004184:	02f00793          	li	a5,47
    80004188:	00f70e63          	beq	a4,a5,800041a4 <namex+0x44>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    8000418c:	ad9fd0ef          	jal	80001c64 <myproc>
    80004190:	15053503          	ld	a0,336(a0)
    80004194:	94bff0ef          	jal	80003ade <idup>
    80004198:	8a2a                	mv	s4,a0
  while(*path == '/')
    8000419a:	02f00913          	li	s2,47
  if(len >= DIRSIZ)
    8000419e:	4c35                	li	s8,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    800041a0:	4b85                	li	s7,1
    800041a2:	a871                	j	8000423e <namex+0xde>
    ip = iget(ROOTDEV, ROOTINO);
    800041a4:	4585                	li	a1,1
    800041a6:	4505                	li	a0,1
    800041a8:	ef8ff0ef          	jal	800038a0 <iget>
    800041ac:	8a2a                	mv	s4,a0
    800041ae:	b7f5                	j	8000419a <namex+0x3a>
      iunlockput(ip);
    800041b0:	8552                	mv	a0,s4
    800041b2:	b6dff0ef          	jal	80003d1e <iunlockput>
      return 0;
    800041b6:	4a01                	li	s4,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    800041b8:	8552                	mv	a0,s4
    800041ba:	60e6                	ld	ra,88(sp)
    800041bc:	6446                	ld	s0,80(sp)
    800041be:	64a6                	ld	s1,72(sp)
    800041c0:	6906                	ld	s2,64(sp)
    800041c2:	79e2                	ld	s3,56(sp)
    800041c4:	7a42                	ld	s4,48(sp)
    800041c6:	7aa2                	ld	s5,40(sp)
    800041c8:	7b02                	ld	s6,32(sp)
    800041ca:	6be2                	ld	s7,24(sp)
    800041cc:	6c42                	ld	s8,16(sp)
    800041ce:	6ca2                	ld	s9,8(sp)
    800041d0:	6125                	addi	sp,sp,96
    800041d2:	8082                	ret
      iunlock(ip);
    800041d4:	8552                	mv	a0,s4
    800041d6:	9edff0ef          	jal	80003bc2 <iunlock>
      return ip;
    800041da:	bff9                	j	800041b8 <namex+0x58>
      iunlockput(ip);
    800041dc:	8552                	mv	a0,s4
    800041de:	b41ff0ef          	jal	80003d1e <iunlockput>
      return 0;
    800041e2:	8a4e                	mv	s4,s3
    800041e4:	bfd1                	j	800041b8 <namex+0x58>
  len = path - s;
    800041e6:	40998633          	sub	a2,s3,s1
    800041ea:	00060c9b          	sext.w	s9,a2
  if(len >= DIRSIZ)
    800041ee:	099c5063          	bge	s8,s9,8000426e <namex+0x10e>
    memmove(name, s, DIRSIZ);
    800041f2:	4639                	li	a2,14
    800041f4:	85a6                	mv	a1,s1
    800041f6:	8556                	mv	a0,s5
    800041f8:	bf5fc0ef          	jal	80000dec <memmove>
    800041fc:	84ce                	mv	s1,s3
  while(*path == '/')
    800041fe:	0004c783          	lbu	a5,0(s1)
    80004202:	01279763          	bne	a5,s2,80004210 <namex+0xb0>
    path++;
    80004206:	0485                	addi	s1,s1,1
  while(*path == '/')
    80004208:	0004c783          	lbu	a5,0(s1)
    8000420c:	ff278de3          	beq	a5,s2,80004206 <namex+0xa6>
    ilock(ip);
    80004210:	8552                	mv	a0,s4
    80004212:	903ff0ef          	jal	80003b14 <ilock>
    if(ip->type != T_DIR){
    80004216:	044a1783          	lh	a5,68(s4)
    8000421a:	f9779be3          	bne	a5,s7,800041b0 <namex+0x50>
    if(nameiparent && *path == '\0'){
    8000421e:	000b0563          	beqz	s6,80004228 <namex+0xc8>
    80004222:	0004c783          	lbu	a5,0(s1)
    80004226:	d7dd                	beqz	a5,800041d4 <namex+0x74>
    if((next = dirlookup(ip, name, 0)) == 0){
    80004228:	4601                	li	a2,0
    8000422a:	85d6                	mv	a1,s5
    8000422c:	8552                	mv	a0,s4
    8000422e:	e97ff0ef          	jal	800040c4 <dirlookup>
    80004232:	89aa                	mv	s3,a0
    80004234:	d545                	beqz	a0,800041dc <namex+0x7c>
    iunlockput(ip);
    80004236:	8552                	mv	a0,s4
    80004238:	ae7ff0ef          	jal	80003d1e <iunlockput>
    ip = next;
    8000423c:	8a4e                	mv	s4,s3
  while(*path == '/')
    8000423e:	0004c783          	lbu	a5,0(s1)
    80004242:	01279763          	bne	a5,s2,80004250 <namex+0xf0>
    path++;
    80004246:	0485                	addi	s1,s1,1
  while(*path == '/')
    80004248:	0004c783          	lbu	a5,0(s1)
    8000424c:	ff278de3          	beq	a5,s2,80004246 <namex+0xe6>
  if(*path == 0)
    80004250:	cb8d                	beqz	a5,80004282 <namex+0x122>
  while(*path != '/' && *path != 0)
    80004252:	0004c783          	lbu	a5,0(s1)
    80004256:	89a6                	mv	s3,s1
  len = path - s;
    80004258:	4c81                	li	s9,0
    8000425a:	4601                	li	a2,0
  while(*path != '/' && *path != 0)
    8000425c:	01278963          	beq	a5,s2,8000426e <namex+0x10e>
    80004260:	d3d9                	beqz	a5,800041e6 <namex+0x86>
    path++;
    80004262:	0985                	addi	s3,s3,1
  while(*path != '/' && *path != 0)
    80004264:	0009c783          	lbu	a5,0(s3)
    80004268:	ff279ce3          	bne	a5,s2,80004260 <namex+0x100>
    8000426c:	bfad                	j	800041e6 <namex+0x86>
    memmove(name, s, len);
    8000426e:	2601                	sext.w	a2,a2
    80004270:	85a6                	mv	a1,s1
    80004272:	8556                	mv	a0,s5
    80004274:	b79fc0ef          	jal	80000dec <memmove>
    name[len] = 0;
    80004278:	9cd6                	add	s9,s9,s5
    8000427a:	000c8023          	sb	zero,0(s9) # 2000 <_entry-0x7fffe000>
    8000427e:	84ce                	mv	s1,s3
    80004280:	bfbd                	j	800041fe <namex+0x9e>
  if(nameiparent){
    80004282:	f20b0be3          	beqz	s6,800041b8 <namex+0x58>
    iput(ip);
    80004286:	8552                	mv	a0,s4
    80004288:	a0fff0ef          	jal	80003c96 <iput>
    return 0;
    8000428c:	4a01                	li	s4,0
    8000428e:	b72d                	j	800041b8 <namex+0x58>

0000000080004290 <dirlink>:
{
    80004290:	7139                	addi	sp,sp,-64
    80004292:	fc06                	sd	ra,56(sp)
    80004294:	f822                	sd	s0,48(sp)
    80004296:	f04a                	sd	s2,32(sp)
    80004298:	ec4e                	sd	s3,24(sp)
    8000429a:	e852                	sd	s4,16(sp)
    8000429c:	0080                	addi	s0,sp,64
    8000429e:	892a                	mv	s2,a0
    800042a0:	8a2e                	mv	s4,a1
    800042a2:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    800042a4:	4601                	li	a2,0
    800042a6:	e1fff0ef          	jal	800040c4 <dirlookup>
    800042aa:	e535                	bnez	a0,80004316 <dirlink+0x86>
    800042ac:	f426                	sd	s1,40(sp)
  for(off = 0; off < dp->size; off += sizeof(de)){
    800042ae:	04c92483          	lw	s1,76(s2)
    800042b2:	c48d                	beqz	s1,800042dc <dirlink+0x4c>
    800042b4:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800042b6:	4741                	li	a4,16
    800042b8:	86a6                	mv	a3,s1
    800042ba:	fc040613          	addi	a2,s0,-64
    800042be:	4581                	li	a1,0
    800042c0:	854a                	mv	a0,s2
    800042c2:	be3ff0ef          	jal	80003ea4 <readi>
    800042c6:	47c1                	li	a5,16
    800042c8:	04f51b63          	bne	a0,a5,8000431e <dirlink+0x8e>
    if(de.inum == 0)
    800042cc:	fc045783          	lhu	a5,-64(s0)
    800042d0:	c791                	beqz	a5,800042dc <dirlink+0x4c>
  for(off = 0; off < dp->size; off += sizeof(de)){
    800042d2:	24c1                	addiw	s1,s1,16
    800042d4:	04c92783          	lw	a5,76(s2)
    800042d8:	fcf4efe3          	bltu	s1,a5,800042b6 <dirlink+0x26>
  strncpy(de.name, name, DIRSIZ);
    800042dc:	4639                	li	a2,14
    800042de:	85d2                	mv	a1,s4
    800042e0:	fc240513          	addi	a0,s0,-62
    800042e4:	baffc0ef          	jal	80000e92 <strncpy>
  de.inum = inum;
    800042e8:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800042ec:	4741                	li	a4,16
    800042ee:	86a6                	mv	a3,s1
    800042f0:	fc040613          	addi	a2,s0,-64
    800042f4:	4581                	li	a1,0
    800042f6:	854a                	mv	a0,s2
    800042f8:	ca9ff0ef          	jal	80003fa0 <writei>
    800042fc:	1541                	addi	a0,a0,-16
    800042fe:	00a03533          	snez	a0,a0
    80004302:	40a00533          	neg	a0,a0
    80004306:	74a2                	ld	s1,40(sp)
}
    80004308:	70e2                	ld	ra,56(sp)
    8000430a:	7442                	ld	s0,48(sp)
    8000430c:	7902                	ld	s2,32(sp)
    8000430e:	69e2                	ld	s3,24(sp)
    80004310:	6a42                	ld	s4,16(sp)
    80004312:	6121                	addi	sp,sp,64
    80004314:	8082                	ret
    iput(ip);
    80004316:	981ff0ef          	jal	80003c96 <iput>
    return -1;
    8000431a:	557d                	li	a0,-1
    8000431c:	b7f5                	j	80004308 <dirlink+0x78>
      panic("dirlink read");
    8000431e:	00004517          	auipc	a0,0x4
    80004322:	1f250513          	addi	a0,a0,498 # 80008510 <etext+0x510>
    80004326:	cecfc0ef          	jal	80000812 <panic>

000000008000432a <namei>:

struct inode*
namei(char *path)
{
    8000432a:	1101                	addi	sp,sp,-32
    8000432c:	ec06                	sd	ra,24(sp)
    8000432e:	e822                	sd	s0,16(sp)
    80004330:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80004332:	fe040613          	addi	a2,s0,-32
    80004336:	4581                	li	a1,0
    80004338:	e29ff0ef          	jal	80004160 <namex>
}
    8000433c:	60e2                	ld	ra,24(sp)
    8000433e:	6442                	ld	s0,16(sp)
    80004340:	6105                	addi	sp,sp,32
    80004342:	8082                	ret

0000000080004344 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    80004344:	1141                	addi	sp,sp,-16
    80004346:	e406                	sd	ra,8(sp)
    80004348:	e022                	sd	s0,0(sp)
    8000434a:	0800                	addi	s0,sp,16
    8000434c:	862e                	mv	a2,a1
  return namex(path, 1, name);
    8000434e:	4585                	li	a1,1
    80004350:	e11ff0ef          	jal	80004160 <namex>
}
    80004354:	60a2                	ld	ra,8(sp)
    80004356:	6402                	ld	s0,0(sp)
    80004358:	0141                	addi	sp,sp,16
    8000435a:	8082                	ret

000000008000435c <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    8000435c:	1101                	addi	sp,sp,-32
    8000435e:	ec06                	sd	ra,24(sp)
    80004360:	e822                	sd	s0,16(sp)
    80004362:	e426                	sd	s1,8(sp)
    80004364:	e04a                	sd	s2,0(sp)
    80004366:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80004368:	0001d917          	auipc	s2,0x1d
    8000436c:	89090913          	addi	s2,s2,-1904 # 80020bf8 <log>
    80004370:	01892583          	lw	a1,24(s2)
    80004374:	02492503          	lw	a0,36(s2)
    80004378:	892ff0ef          	jal	8000340a <bread>
    8000437c:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    8000437e:	02892603          	lw	a2,40(s2)
    80004382:	cd30                	sw	a2,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80004384:	00c05f63          	blez	a2,800043a2 <write_head+0x46>
    80004388:	0001d717          	auipc	a4,0x1d
    8000438c:	89c70713          	addi	a4,a4,-1892 # 80020c24 <log+0x2c>
    80004390:	87aa                	mv	a5,a0
    80004392:	060a                	slli	a2,a2,0x2
    80004394:	962a                	add	a2,a2,a0
    hb->block[i] = log.lh.block[i];
    80004396:	4314                	lw	a3,0(a4)
    80004398:	cff4                	sw	a3,92(a5)
  for (i = 0; i < log.lh.n; i++) {
    8000439a:	0711                	addi	a4,a4,4
    8000439c:	0791                	addi	a5,a5,4
    8000439e:	fec79ce3          	bne	a5,a2,80004396 <write_head+0x3a>
  }
  bwrite(buf);
    800043a2:	8526                	mv	a0,s1
    800043a4:	964ff0ef          	jal	80003508 <bwrite>
  brelse(buf);
    800043a8:	8526                	mv	a0,s1
    800043aa:	990ff0ef          	jal	8000353a <brelse>
}
    800043ae:	60e2                	ld	ra,24(sp)
    800043b0:	6442                	ld	s0,16(sp)
    800043b2:	64a2                	ld	s1,8(sp)
    800043b4:	6902                	ld	s2,0(sp)
    800043b6:	6105                	addi	sp,sp,32
    800043b8:	8082                	ret

00000000800043ba <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    800043ba:	0001d797          	auipc	a5,0x1d
    800043be:	8667a783          	lw	a5,-1946(a5) # 80020c20 <log+0x28>
    800043c2:	0af05e63          	blez	a5,8000447e <install_trans+0xc4>
{
    800043c6:	715d                	addi	sp,sp,-80
    800043c8:	e486                	sd	ra,72(sp)
    800043ca:	e0a2                	sd	s0,64(sp)
    800043cc:	fc26                	sd	s1,56(sp)
    800043ce:	f84a                	sd	s2,48(sp)
    800043d0:	f44e                	sd	s3,40(sp)
    800043d2:	f052                	sd	s4,32(sp)
    800043d4:	ec56                	sd	s5,24(sp)
    800043d6:	e85a                	sd	s6,16(sp)
    800043d8:	e45e                	sd	s7,8(sp)
    800043da:	0880                	addi	s0,sp,80
    800043dc:	8b2a                	mv	s6,a0
    800043de:	0001da97          	auipc	s5,0x1d
    800043e2:	846a8a93          	addi	s5,s5,-1978 # 80020c24 <log+0x2c>
  for (tail = 0; tail < log.lh.n; tail++) {
    800043e6:	4981                	li	s3,0
      printf("recovering tail %d dst %d\n", tail, log.lh.block[tail]);
    800043e8:	00004b97          	auipc	s7,0x4
    800043ec:	138b8b93          	addi	s7,s7,312 # 80008520 <etext+0x520>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    800043f0:	0001da17          	auipc	s4,0x1d
    800043f4:	808a0a13          	addi	s4,s4,-2040 # 80020bf8 <log>
    800043f8:	a025                	j	80004420 <install_trans+0x66>
      printf("recovering tail %d dst %d\n", tail, log.lh.block[tail]);
    800043fa:	000aa603          	lw	a2,0(s5)
    800043fe:	85ce                	mv	a1,s3
    80004400:	855e                	mv	a0,s7
    80004402:	92afc0ef          	jal	8000052c <printf>
    80004406:	a839                	j	80004424 <install_trans+0x6a>
    brelse(lbuf);
    80004408:	854a                	mv	a0,s2
    8000440a:	930ff0ef          	jal	8000353a <brelse>
    brelse(dbuf);
    8000440e:	8526                	mv	a0,s1
    80004410:	92aff0ef          	jal	8000353a <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004414:	2985                	addiw	s3,s3,1
    80004416:	0a91                	addi	s5,s5,4
    80004418:	028a2783          	lw	a5,40(s4)
    8000441c:	04f9d663          	bge	s3,a5,80004468 <install_trans+0xae>
    if(recovering) {
    80004420:	fc0b1de3          	bnez	s6,800043fa <install_trans+0x40>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80004424:	018a2583          	lw	a1,24(s4)
    80004428:	013585bb          	addw	a1,a1,s3
    8000442c:	2585                	addiw	a1,a1,1
    8000442e:	024a2503          	lw	a0,36(s4)
    80004432:	fd9fe0ef          	jal	8000340a <bread>
    80004436:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    80004438:	000aa583          	lw	a1,0(s5)
    8000443c:	024a2503          	lw	a0,36(s4)
    80004440:	fcbfe0ef          	jal	8000340a <bread>
    80004444:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80004446:	40000613          	li	a2,1024
    8000444a:	05890593          	addi	a1,s2,88
    8000444e:	05850513          	addi	a0,a0,88
    80004452:	99bfc0ef          	jal	80000dec <memmove>
    bwrite(dbuf);  // write dst to disk
    80004456:	8526                	mv	a0,s1
    80004458:	8b0ff0ef          	jal	80003508 <bwrite>
    if(recovering == 0)
    8000445c:	fa0b16e3          	bnez	s6,80004408 <install_trans+0x4e>
      bunpin(dbuf);
    80004460:	8526                	mv	a0,s1
    80004462:	9aaff0ef          	jal	8000360c <bunpin>
    80004466:	b74d                	j	80004408 <install_trans+0x4e>
}
    80004468:	60a6                	ld	ra,72(sp)
    8000446a:	6406                	ld	s0,64(sp)
    8000446c:	74e2                	ld	s1,56(sp)
    8000446e:	7942                	ld	s2,48(sp)
    80004470:	79a2                	ld	s3,40(sp)
    80004472:	7a02                	ld	s4,32(sp)
    80004474:	6ae2                	ld	s5,24(sp)
    80004476:	6b42                	ld	s6,16(sp)
    80004478:	6ba2                	ld	s7,8(sp)
    8000447a:	6161                	addi	sp,sp,80
    8000447c:	8082                	ret
    8000447e:	8082                	ret

0000000080004480 <initlog>:
{
    80004480:	7179                	addi	sp,sp,-48
    80004482:	f406                	sd	ra,40(sp)
    80004484:	f022                	sd	s0,32(sp)
    80004486:	ec26                	sd	s1,24(sp)
    80004488:	e84a                	sd	s2,16(sp)
    8000448a:	e44e                	sd	s3,8(sp)
    8000448c:	1800                	addi	s0,sp,48
    8000448e:	892a                	mv	s2,a0
    80004490:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    80004492:	0001c497          	auipc	s1,0x1c
    80004496:	76648493          	addi	s1,s1,1894 # 80020bf8 <log>
    8000449a:	00004597          	auipc	a1,0x4
    8000449e:	0a658593          	addi	a1,a1,166 # 80008540 <etext+0x540>
    800044a2:	8526                	mv	a0,s1
    800044a4:	f98fc0ef          	jal	80000c3c <initlock>
  log.start = sb->logstart;
    800044a8:	0149a583          	lw	a1,20(s3)
    800044ac:	cc8c                	sw	a1,24(s1)
  log.dev = dev;
    800044ae:	0324a223          	sw	s2,36(s1)
  struct buf *buf = bread(log.dev, log.start);
    800044b2:	854a                	mv	a0,s2
    800044b4:	f57fe0ef          	jal	8000340a <bread>
  log.lh.n = lh->n;
    800044b8:	4d30                	lw	a2,88(a0)
    800044ba:	d490                	sw	a2,40(s1)
  for (i = 0; i < log.lh.n; i++) {
    800044bc:	00c05f63          	blez	a2,800044da <initlog+0x5a>
    800044c0:	87aa                	mv	a5,a0
    800044c2:	0001c717          	auipc	a4,0x1c
    800044c6:	76270713          	addi	a4,a4,1890 # 80020c24 <log+0x2c>
    800044ca:	060a                	slli	a2,a2,0x2
    800044cc:	962a                	add	a2,a2,a0
    log.lh.block[i] = lh->block[i];
    800044ce:	4ff4                	lw	a3,92(a5)
    800044d0:	c314                	sw	a3,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    800044d2:	0791                	addi	a5,a5,4
    800044d4:	0711                	addi	a4,a4,4
    800044d6:	fec79ce3          	bne	a5,a2,800044ce <initlog+0x4e>
  brelse(buf);
    800044da:	860ff0ef          	jal	8000353a <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    800044de:	4505                	li	a0,1
    800044e0:	edbff0ef          	jal	800043ba <install_trans>
  log.lh.n = 0;
    800044e4:	0001c797          	auipc	a5,0x1c
    800044e8:	7207ae23          	sw	zero,1852(a5) # 80020c20 <log+0x28>
  write_head(); // clear the log
    800044ec:	e71ff0ef          	jal	8000435c <write_head>
}
    800044f0:	70a2                	ld	ra,40(sp)
    800044f2:	7402                	ld	s0,32(sp)
    800044f4:	64e2                	ld	s1,24(sp)
    800044f6:	6942                	ld	s2,16(sp)
    800044f8:	69a2                	ld	s3,8(sp)
    800044fa:	6145                	addi	sp,sp,48
    800044fc:	8082                	ret

00000000800044fe <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    800044fe:	1101                	addi	sp,sp,-32
    80004500:	ec06                	sd	ra,24(sp)
    80004502:	e822                	sd	s0,16(sp)
    80004504:	e426                	sd	s1,8(sp)
    80004506:	e04a                	sd	s2,0(sp)
    80004508:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    8000450a:	0001c517          	auipc	a0,0x1c
    8000450e:	6ee50513          	addi	a0,a0,1774 # 80020bf8 <log>
    80004512:	faafc0ef          	jal	80000cbc <acquire>
  while(1){
    if(log.committing){
    80004516:	0001c497          	auipc	s1,0x1c
    8000451a:	6e248493          	addi	s1,s1,1762 # 80020bf8 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGBLOCKS){
    8000451e:	4979                	li	s2,30
    80004520:	a029                	j	8000452a <begin_op+0x2c>
      sleep(&log, &log.lock);
    80004522:	85a6                	mv	a1,s1
    80004524:	8526                	mv	a0,s1
    80004526:	804fe0ef          	jal	8000252a <sleep>
    if(log.committing){
    8000452a:	509c                	lw	a5,32(s1)
    8000452c:	fbfd                	bnez	a5,80004522 <begin_op+0x24>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGBLOCKS){
    8000452e:	4cd8                	lw	a4,28(s1)
    80004530:	2705                	addiw	a4,a4,1
    80004532:	0027179b          	slliw	a5,a4,0x2
    80004536:	9fb9                	addw	a5,a5,a4
    80004538:	0017979b          	slliw	a5,a5,0x1
    8000453c:	5494                	lw	a3,40(s1)
    8000453e:	9fb5                	addw	a5,a5,a3
    80004540:	00f95763          	bge	s2,a5,8000454e <begin_op+0x50>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    80004544:	85a6                	mv	a1,s1
    80004546:	8526                	mv	a0,s1
    80004548:	fe3fd0ef          	jal	8000252a <sleep>
    8000454c:	bff9                	j	8000452a <begin_op+0x2c>
    } else {
      log.outstanding += 1;
    8000454e:	0001c517          	auipc	a0,0x1c
    80004552:	6aa50513          	addi	a0,a0,1706 # 80020bf8 <log>
    80004556:	cd58                	sw	a4,28(a0)
      release(&log.lock);
    80004558:	ffcfc0ef          	jal	80000d54 <release>
      break;
    }
  }
}
    8000455c:	60e2                	ld	ra,24(sp)
    8000455e:	6442                	ld	s0,16(sp)
    80004560:	64a2                	ld	s1,8(sp)
    80004562:	6902                	ld	s2,0(sp)
    80004564:	6105                	addi	sp,sp,32
    80004566:	8082                	ret

0000000080004568 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    80004568:	7139                	addi	sp,sp,-64
    8000456a:	fc06                	sd	ra,56(sp)
    8000456c:	f822                	sd	s0,48(sp)
    8000456e:	f426                	sd	s1,40(sp)
    80004570:	f04a                	sd	s2,32(sp)
    80004572:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    80004574:	0001c497          	auipc	s1,0x1c
    80004578:	68448493          	addi	s1,s1,1668 # 80020bf8 <log>
    8000457c:	8526                	mv	a0,s1
    8000457e:	f3efc0ef          	jal	80000cbc <acquire>
  log.outstanding -= 1;
    80004582:	4cdc                	lw	a5,28(s1)
    80004584:	37fd                	addiw	a5,a5,-1
    80004586:	0007891b          	sext.w	s2,a5
    8000458a:	ccdc                	sw	a5,28(s1)
  if(log.committing)
    8000458c:	509c                	lw	a5,32(s1)
    8000458e:	ef9d                	bnez	a5,800045cc <end_op+0x64>
    panic("log.committing");
  if(log.outstanding == 0){
    80004590:	04091763          	bnez	s2,800045de <end_op+0x76>
    do_commit = 1;
    log.committing = 1;
    80004594:	0001c497          	auipc	s1,0x1c
    80004598:	66448493          	addi	s1,s1,1636 # 80020bf8 <log>
    8000459c:	4785                	li	a5,1
    8000459e:	d09c                	sw	a5,32(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    800045a0:	8526                	mv	a0,s1
    800045a2:	fb2fc0ef          	jal	80000d54 <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    800045a6:	549c                	lw	a5,40(s1)
    800045a8:	04f04b63          	bgtz	a5,800045fe <end_op+0x96>
    acquire(&log.lock);
    800045ac:	0001c497          	auipc	s1,0x1c
    800045b0:	64c48493          	addi	s1,s1,1612 # 80020bf8 <log>
    800045b4:	8526                	mv	a0,s1
    800045b6:	f06fc0ef          	jal	80000cbc <acquire>
    log.committing = 0;
    800045ba:	0204a023          	sw	zero,32(s1)
    wakeup(&log);
    800045be:	8526                	mv	a0,s1
    800045c0:	fbbfd0ef          	jal	8000257a <wakeup>
    release(&log.lock);
    800045c4:	8526                	mv	a0,s1
    800045c6:	f8efc0ef          	jal	80000d54 <release>
}
    800045ca:	a025                	j	800045f2 <end_op+0x8a>
    800045cc:	ec4e                	sd	s3,24(sp)
    800045ce:	e852                	sd	s4,16(sp)
    800045d0:	e456                	sd	s5,8(sp)
    panic("log.committing");
    800045d2:	00004517          	auipc	a0,0x4
    800045d6:	f7650513          	addi	a0,a0,-138 # 80008548 <etext+0x548>
    800045da:	a38fc0ef          	jal	80000812 <panic>
    wakeup(&log);
    800045de:	0001c497          	auipc	s1,0x1c
    800045e2:	61a48493          	addi	s1,s1,1562 # 80020bf8 <log>
    800045e6:	8526                	mv	a0,s1
    800045e8:	f93fd0ef          	jal	8000257a <wakeup>
  release(&log.lock);
    800045ec:	8526                	mv	a0,s1
    800045ee:	f66fc0ef          	jal	80000d54 <release>
}
    800045f2:	70e2                	ld	ra,56(sp)
    800045f4:	7442                	ld	s0,48(sp)
    800045f6:	74a2                	ld	s1,40(sp)
    800045f8:	7902                	ld	s2,32(sp)
    800045fa:	6121                	addi	sp,sp,64
    800045fc:	8082                	ret
    800045fe:	ec4e                	sd	s3,24(sp)
    80004600:	e852                	sd	s4,16(sp)
    80004602:	e456                	sd	s5,8(sp)
  for (tail = 0; tail < log.lh.n; tail++) {
    80004604:	0001ca97          	auipc	s5,0x1c
    80004608:	620a8a93          	addi	s5,s5,1568 # 80020c24 <log+0x2c>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    8000460c:	0001ca17          	auipc	s4,0x1c
    80004610:	5eca0a13          	addi	s4,s4,1516 # 80020bf8 <log>
    80004614:	018a2583          	lw	a1,24(s4)
    80004618:	012585bb          	addw	a1,a1,s2
    8000461c:	2585                	addiw	a1,a1,1
    8000461e:	024a2503          	lw	a0,36(s4)
    80004622:	de9fe0ef          	jal	8000340a <bread>
    80004626:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    80004628:	000aa583          	lw	a1,0(s5)
    8000462c:	024a2503          	lw	a0,36(s4)
    80004630:	ddbfe0ef          	jal	8000340a <bread>
    80004634:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    80004636:	40000613          	li	a2,1024
    8000463a:	05850593          	addi	a1,a0,88
    8000463e:	05848513          	addi	a0,s1,88
    80004642:	faafc0ef          	jal	80000dec <memmove>
    bwrite(to);  // write the log
    80004646:	8526                	mv	a0,s1
    80004648:	ec1fe0ef          	jal	80003508 <bwrite>
    brelse(from);
    8000464c:	854e                	mv	a0,s3
    8000464e:	eedfe0ef          	jal	8000353a <brelse>
    brelse(to);
    80004652:	8526                	mv	a0,s1
    80004654:	ee7fe0ef          	jal	8000353a <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004658:	2905                	addiw	s2,s2,1
    8000465a:	0a91                	addi	s5,s5,4
    8000465c:	028a2783          	lw	a5,40(s4)
    80004660:	faf94ae3          	blt	s2,a5,80004614 <end_op+0xac>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    80004664:	cf9ff0ef          	jal	8000435c <write_head>
    install_trans(0); // Now install writes to home locations
    80004668:	4501                	li	a0,0
    8000466a:	d51ff0ef          	jal	800043ba <install_trans>
    log.lh.n = 0;
    8000466e:	0001c797          	auipc	a5,0x1c
    80004672:	5a07a923          	sw	zero,1458(a5) # 80020c20 <log+0x28>
    write_head();    // Erase the transaction from the log
    80004676:	ce7ff0ef          	jal	8000435c <write_head>
    8000467a:	69e2                	ld	s3,24(sp)
    8000467c:	6a42                	ld	s4,16(sp)
    8000467e:	6aa2                	ld	s5,8(sp)
    80004680:	b735                	j	800045ac <end_op+0x44>

0000000080004682 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    80004682:	1101                	addi	sp,sp,-32
    80004684:	ec06                	sd	ra,24(sp)
    80004686:	e822                	sd	s0,16(sp)
    80004688:	e426                	sd	s1,8(sp)
    8000468a:	e04a                	sd	s2,0(sp)
    8000468c:	1000                	addi	s0,sp,32
    8000468e:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    80004690:	0001c917          	auipc	s2,0x1c
    80004694:	56890913          	addi	s2,s2,1384 # 80020bf8 <log>
    80004698:	854a                	mv	a0,s2
    8000469a:	e22fc0ef          	jal	80000cbc <acquire>
  if (log.lh.n >= LOGBLOCKS)
    8000469e:	02892603          	lw	a2,40(s2)
    800046a2:	47f5                	li	a5,29
    800046a4:	04c7cc63          	blt	a5,a2,800046fc <log_write+0x7a>
    panic("too big a transaction");
  if (log.outstanding < 1)
    800046a8:	0001c797          	auipc	a5,0x1c
    800046ac:	56c7a783          	lw	a5,1388(a5) # 80020c14 <log+0x1c>
    800046b0:	04f05c63          	blez	a5,80004708 <log_write+0x86>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    800046b4:	4781                	li	a5,0
    800046b6:	04c05f63          	blez	a2,80004714 <log_write+0x92>
    if (log.lh.block[i] == b->blockno)   // log absorption
    800046ba:	44cc                	lw	a1,12(s1)
    800046bc:	0001c717          	auipc	a4,0x1c
    800046c0:	56870713          	addi	a4,a4,1384 # 80020c24 <log+0x2c>
  for (i = 0; i < log.lh.n; i++) {
    800046c4:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    800046c6:	4314                	lw	a3,0(a4)
    800046c8:	04b68663          	beq	a3,a1,80004714 <log_write+0x92>
  for (i = 0; i < log.lh.n; i++) {
    800046cc:	2785                	addiw	a5,a5,1
    800046ce:	0711                	addi	a4,a4,4
    800046d0:	fef61be3          	bne	a2,a5,800046c6 <log_write+0x44>
      break;
  }
  log.lh.block[i] = b->blockno;
    800046d4:	0621                	addi	a2,a2,8
    800046d6:	060a                	slli	a2,a2,0x2
    800046d8:	0001c797          	auipc	a5,0x1c
    800046dc:	52078793          	addi	a5,a5,1312 # 80020bf8 <log>
    800046e0:	97b2                	add	a5,a5,a2
    800046e2:	44d8                	lw	a4,12(s1)
    800046e4:	c7d8                	sw	a4,12(a5)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    800046e6:	8526                	mv	a0,s1
    800046e8:	ef1fe0ef          	jal	800035d8 <bpin>
    log.lh.n++;
    800046ec:	0001c717          	auipc	a4,0x1c
    800046f0:	50c70713          	addi	a4,a4,1292 # 80020bf8 <log>
    800046f4:	571c                	lw	a5,40(a4)
    800046f6:	2785                	addiw	a5,a5,1
    800046f8:	d71c                	sw	a5,40(a4)
    800046fa:	a80d                	j	8000472c <log_write+0xaa>
    panic("too big a transaction");
    800046fc:	00004517          	auipc	a0,0x4
    80004700:	e5c50513          	addi	a0,a0,-420 # 80008558 <etext+0x558>
    80004704:	90efc0ef          	jal	80000812 <panic>
    panic("log_write outside of trans");
    80004708:	00004517          	auipc	a0,0x4
    8000470c:	e6850513          	addi	a0,a0,-408 # 80008570 <etext+0x570>
    80004710:	902fc0ef          	jal	80000812 <panic>
  log.lh.block[i] = b->blockno;
    80004714:	00878693          	addi	a3,a5,8
    80004718:	068a                	slli	a3,a3,0x2
    8000471a:	0001c717          	auipc	a4,0x1c
    8000471e:	4de70713          	addi	a4,a4,1246 # 80020bf8 <log>
    80004722:	9736                	add	a4,a4,a3
    80004724:	44d4                	lw	a3,12(s1)
    80004726:	c754                	sw	a3,12(a4)
  if (i == log.lh.n) {  // Add new block to log?
    80004728:	faf60fe3          	beq	a2,a5,800046e6 <log_write+0x64>
  }
  release(&log.lock);
    8000472c:	0001c517          	auipc	a0,0x1c
    80004730:	4cc50513          	addi	a0,a0,1228 # 80020bf8 <log>
    80004734:	e20fc0ef          	jal	80000d54 <release>
}
    80004738:	60e2                	ld	ra,24(sp)
    8000473a:	6442                	ld	s0,16(sp)
    8000473c:	64a2                	ld	s1,8(sp)
    8000473e:	6902                	ld	s2,0(sp)
    80004740:	6105                	addi	sp,sp,32
    80004742:	8082                	ret

0000000080004744 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    80004744:	1101                	addi	sp,sp,-32
    80004746:	ec06                	sd	ra,24(sp)
    80004748:	e822                	sd	s0,16(sp)
    8000474a:	e426                	sd	s1,8(sp)
    8000474c:	e04a                	sd	s2,0(sp)
    8000474e:	1000                	addi	s0,sp,32
    80004750:	84aa                	mv	s1,a0
    80004752:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    80004754:	00004597          	auipc	a1,0x4
    80004758:	e3c58593          	addi	a1,a1,-452 # 80008590 <etext+0x590>
    8000475c:	0521                	addi	a0,a0,8
    8000475e:	cdefc0ef          	jal	80000c3c <initlock>
  lk->name = name;
    80004762:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    80004766:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    8000476a:	0204a423          	sw	zero,40(s1)
}
    8000476e:	60e2                	ld	ra,24(sp)
    80004770:	6442                	ld	s0,16(sp)
    80004772:	64a2                	ld	s1,8(sp)
    80004774:	6902                	ld	s2,0(sp)
    80004776:	6105                	addi	sp,sp,32
    80004778:	8082                	ret

000000008000477a <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    8000477a:	1101                	addi	sp,sp,-32
    8000477c:	ec06                	sd	ra,24(sp)
    8000477e:	e822                	sd	s0,16(sp)
    80004780:	e426                	sd	s1,8(sp)
    80004782:	e04a                	sd	s2,0(sp)
    80004784:	1000                	addi	s0,sp,32
    80004786:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004788:	00850913          	addi	s2,a0,8
    8000478c:	854a                	mv	a0,s2
    8000478e:	d2efc0ef          	jal	80000cbc <acquire>
  while (lk->locked) {
    80004792:	409c                	lw	a5,0(s1)
    80004794:	c799                	beqz	a5,800047a2 <acquiresleep+0x28>
    sleep(lk, &lk->lk);
    80004796:	85ca                	mv	a1,s2
    80004798:	8526                	mv	a0,s1
    8000479a:	d91fd0ef          	jal	8000252a <sleep>
  while (lk->locked) {
    8000479e:	409c                	lw	a5,0(s1)
    800047a0:	fbfd                	bnez	a5,80004796 <acquiresleep+0x1c>
  }
  lk->locked = 1;
    800047a2:	4785                	li	a5,1
    800047a4:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    800047a6:	cbefd0ef          	jal	80001c64 <myproc>
    800047aa:	595c                	lw	a5,52(a0)
    800047ac:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    800047ae:	854a                	mv	a0,s2
    800047b0:	da4fc0ef          	jal	80000d54 <release>
}
    800047b4:	60e2                	ld	ra,24(sp)
    800047b6:	6442                	ld	s0,16(sp)
    800047b8:	64a2                	ld	s1,8(sp)
    800047ba:	6902                	ld	s2,0(sp)
    800047bc:	6105                	addi	sp,sp,32
    800047be:	8082                	ret

00000000800047c0 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    800047c0:	1101                	addi	sp,sp,-32
    800047c2:	ec06                	sd	ra,24(sp)
    800047c4:	e822                	sd	s0,16(sp)
    800047c6:	e426                	sd	s1,8(sp)
    800047c8:	e04a                	sd	s2,0(sp)
    800047ca:	1000                	addi	s0,sp,32
    800047cc:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    800047ce:	00850913          	addi	s2,a0,8
    800047d2:	854a                	mv	a0,s2
    800047d4:	ce8fc0ef          	jal	80000cbc <acquire>
  lk->locked = 0;
    800047d8:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    800047dc:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    800047e0:	8526                	mv	a0,s1
    800047e2:	d99fd0ef          	jal	8000257a <wakeup>
  release(&lk->lk);
    800047e6:	854a                	mv	a0,s2
    800047e8:	d6cfc0ef          	jal	80000d54 <release>
}
    800047ec:	60e2                	ld	ra,24(sp)
    800047ee:	6442                	ld	s0,16(sp)
    800047f0:	64a2                	ld	s1,8(sp)
    800047f2:	6902                	ld	s2,0(sp)
    800047f4:	6105                	addi	sp,sp,32
    800047f6:	8082                	ret

00000000800047f8 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    800047f8:	7179                	addi	sp,sp,-48
    800047fa:	f406                	sd	ra,40(sp)
    800047fc:	f022                	sd	s0,32(sp)
    800047fe:	ec26                	sd	s1,24(sp)
    80004800:	e84a                	sd	s2,16(sp)
    80004802:	1800                	addi	s0,sp,48
    80004804:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    80004806:	00850913          	addi	s2,a0,8
    8000480a:	854a                	mv	a0,s2
    8000480c:	cb0fc0ef          	jal	80000cbc <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    80004810:	409c                	lw	a5,0(s1)
    80004812:	ef81                	bnez	a5,8000482a <holdingsleep+0x32>
    80004814:	4481                	li	s1,0
  release(&lk->lk);
    80004816:	854a                	mv	a0,s2
    80004818:	d3cfc0ef          	jal	80000d54 <release>
  return r;
}
    8000481c:	8526                	mv	a0,s1
    8000481e:	70a2                	ld	ra,40(sp)
    80004820:	7402                	ld	s0,32(sp)
    80004822:	64e2                	ld	s1,24(sp)
    80004824:	6942                	ld	s2,16(sp)
    80004826:	6145                	addi	sp,sp,48
    80004828:	8082                	ret
    8000482a:	e44e                	sd	s3,8(sp)
  r = lk->locked && (lk->pid == myproc()->pid);
    8000482c:	0284a983          	lw	s3,40(s1)
    80004830:	c34fd0ef          	jal	80001c64 <myproc>
    80004834:	5944                	lw	s1,52(a0)
    80004836:	413484b3          	sub	s1,s1,s3
    8000483a:	0014b493          	seqz	s1,s1
    8000483e:	69a2                	ld	s3,8(sp)
    80004840:	bfd9                	j	80004816 <holdingsleep+0x1e>

0000000080004842 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    80004842:	1141                	addi	sp,sp,-16
    80004844:	e406                	sd	ra,8(sp)
    80004846:	e022                	sd	s0,0(sp)
    80004848:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    8000484a:	00004597          	auipc	a1,0x4
    8000484e:	d5658593          	addi	a1,a1,-682 # 800085a0 <etext+0x5a0>
    80004852:	0001c517          	auipc	a0,0x1c
    80004856:	4ee50513          	addi	a0,a0,1262 # 80020d40 <ftable>
    8000485a:	be2fc0ef          	jal	80000c3c <initlock>
}
    8000485e:	60a2                	ld	ra,8(sp)
    80004860:	6402                	ld	s0,0(sp)
    80004862:	0141                	addi	sp,sp,16
    80004864:	8082                	ret

0000000080004866 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    80004866:	1101                	addi	sp,sp,-32
    80004868:	ec06                	sd	ra,24(sp)
    8000486a:	e822                	sd	s0,16(sp)
    8000486c:	e426                	sd	s1,8(sp)
    8000486e:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    80004870:	0001c517          	auipc	a0,0x1c
    80004874:	4d050513          	addi	a0,a0,1232 # 80020d40 <ftable>
    80004878:	c44fc0ef          	jal	80000cbc <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    8000487c:	0001c497          	auipc	s1,0x1c
    80004880:	4dc48493          	addi	s1,s1,1244 # 80020d58 <ftable+0x18>
    80004884:	0001d717          	auipc	a4,0x1d
    80004888:	47470713          	addi	a4,a4,1140 # 80021cf8 <disk>
    if(f->ref == 0){
    8000488c:	40dc                	lw	a5,4(s1)
    8000488e:	cf89                	beqz	a5,800048a8 <filealloc+0x42>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004890:	02848493          	addi	s1,s1,40
    80004894:	fee49ce3          	bne	s1,a4,8000488c <filealloc+0x26>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    80004898:	0001c517          	auipc	a0,0x1c
    8000489c:	4a850513          	addi	a0,a0,1192 # 80020d40 <ftable>
    800048a0:	cb4fc0ef          	jal	80000d54 <release>
  return 0;
    800048a4:	4481                	li	s1,0
    800048a6:	a809                	j	800048b8 <filealloc+0x52>
      f->ref = 1;
    800048a8:	4785                	li	a5,1
    800048aa:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    800048ac:	0001c517          	auipc	a0,0x1c
    800048b0:	49450513          	addi	a0,a0,1172 # 80020d40 <ftable>
    800048b4:	ca0fc0ef          	jal	80000d54 <release>
}
    800048b8:	8526                	mv	a0,s1
    800048ba:	60e2                	ld	ra,24(sp)
    800048bc:	6442                	ld	s0,16(sp)
    800048be:	64a2                	ld	s1,8(sp)
    800048c0:	6105                	addi	sp,sp,32
    800048c2:	8082                	ret

00000000800048c4 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    800048c4:	1101                	addi	sp,sp,-32
    800048c6:	ec06                	sd	ra,24(sp)
    800048c8:	e822                	sd	s0,16(sp)
    800048ca:	e426                	sd	s1,8(sp)
    800048cc:	1000                	addi	s0,sp,32
    800048ce:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    800048d0:	0001c517          	auipc	a0,0x1c
    800048d4:	47050513          	addi	a0,a0,1136 # 80020d40 <ftable>
    800048d8:	be4fc0ef          	jal	80000cbc <acquire>
  if(f->ref < 1)
    800048dc:	40dc                	lw	a5,4(s1)
    800048de:	02f05063          	blez	a5,800048fe <filedup+0x3a>
    panic("filedup");
  f->ref++;
    800048e2:	2785                	addiw	a5,a5,1
    800048e4:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    800048e6:	0001c517          	auipc	a0,0x1c
    800048ea:	45a50513          	addi	a0,a0,1114 # 80020d40 <ftable>
    800048ee:	c66fc0ef          	jal	80000d54 <release>
  return f;
}
    800048f2:	8526                	mv	a0,s1
    800048f4:	60e2                	ld	ra,24(sp)
    800048f6:	6442                	ld	s0,16(sp)
    800048f8:	64a2                	ld	s1,8(sp)
    800048fa:	6105                	addi	sp,sp,32
    800048fc:	8082                	ret
    panic("filedup");
    800048fe:	00004517          	auipc	a0,0x4
    80004902:	caa50513          	addi	a0,a0,-854 # 800085a8 <etext+0x5a8>
    80004906:	f0dfb0ef          	jal	80000812 <panic>

000000008000490a <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    8000490a:	7139                	addi	sp,sp,-64
    8000490c:	fc06                	sd	ra,56(sp)
    8000490e:	f822                	sd	s0,48(sp)
    80004910:	f426                	sd	s1,40(sp)
    80004912:	0080                	addi	s0,sp,64
    80004914:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    80004916:	0001c517          	auipc	a0,0x1c
    8000491a:	42a50513          	addi	a0,a0,1066 # 80020d40 <ftable>
    8000491e:	b9efc0ef          	jal	80000cbc <acquire>
  if(f->ref < 1)
    80004922:	40dc                	lw	a5,4(s1)
    80004924:	04f05a63          	blez	a5,80004978 <fileclose+0x6e>
    panic("fileclose");
  if(--f->ref > 0){
    80004928:	37fd                	addiw	a5,a5,-1
    8000492a:	0007871b          	sext.w	a4,a5
    8000492e:	c0dc                	sw	a5,4(s1)
    80004930:	04e04e63          	bgtz	a4,8000498c <fileclose+0x82>
    80004934:	f04a                	sd	s2,32(sp)
    80004936:	ec4e                	sd	s3,24(sp)
    80004938:	e852                	sd	s4,16(sp)
    8000493a:	e456                	sd	s5,8(sp)
    release(&ftable.lock);
    return;
  }
  ff = *f;
    8000493c:	0004a903          	lw	s2,0(s1)
    80004940:	0094ca83          	lbu	s5,9(s1)
    80004944:	0104ba03          	ld	s4,16(s1)
    80004948:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    8000494c:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    80004950:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    80004954:	0001c517          	auipc	a0,0x1c
    80004958:	3ec50513          	addi	a0,a0,1004 # 80020d40 <ftable>
    8000495c:	bf8fc0ef          	jal	80000d54 <release>

  if(ff.type == FD_PIPE){
    80004960:	4785                	li	a5,1
    80004962:	04f90063          	beq	s2,a5,800049a2 <fileclose+0x98>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    80004966:	3979                	addiw	s2,s2,-2
    80004968:	4785                	li	a5,1
    8000496a:	0527f563          	bgeu	a5,s2,800049b4 <fileclose+0xaa>
    8000496e:	7902                	ld	s2,32(sp)
    80004970:	69e2                	ld	s3,24(sp)
    80004972:	6a42                	ld	s4,16(sp)
    80004974:	6aa2                	ld	s5,8(sp)
    80004976:	a00d                	j	80004998 <fileclose+0x8e>
    80004978:	f04a                	sd	s2,32(sp)
    8000497a:	ec4e                	sd	s3,24(sp)
    8000497c:	e852                	sd	s4,16(sp)
    8000497e:	e456                	sd	s5,8(sp)
    panic("fileclose");
    80004980:	00004517          	auipc	a0,0x4
    80004984:	c3050513          	addi	a0,a0,-976 # 800085b0 <etext+0x5b0>
    80004988:	e8bfb0ef          	jal	80000812 <panic>
    release(&ftable.lock);
    8000498c:	0001c517          	auipc	a0,0x1c
    80004990:	3b450513          	addi	a0,a0,948 # 80020d40 <ftable>
    80004994:	bc0fc0ef          	jal	80000d54 <release>
    begin_op();
    iput(ff.ip);
    end_op();
  }
}
    80004998:	70e2                	ld	ra,56(sp)
    8000499a:	7442                	ld	s0,48(sp)
    8000499c:	74a2                	ld	s1,40(sp)
    8000499e:	6121                	addi	sp,sp,64
    800049a0:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    800049a2:	85d6                	mv	a1,s5
    800049a4:	8552                	mv	a0,s4
    800049a6:	336000ef          	jal	80004cdc <pipeclose>
    800049aa:	7902                	ld	s2,32(sp)
    800049ac:	69e2                	ld	s3,24(sp)
    800049ae:	6a42                	ld	s4,16(sp)
    800049b0:	6aa2                	ld	s5,8(sp)
    800049b2:	b7dd                	j	80004998 <fileclose+0x8e>
    begin_op();
    800049b4:	b4bff0ef          	jal	800044fe <begin_op>
    iput(ff.ip);
    800049b8:	854e                	mv	a0,s3
    800049ba:	adcff0ef          	jal	80003c96 <iput>
    end_op();
    800049be:	babff0ef          	jal	80004568 <end_op>
    800049c2:	7902                	ld	s2,32(sp)
    800049c4:	69e2                	ld	s3,24(sp)
    800049c6:	6a42                	ld	s4,16(sp)
    800049c8:	6aa2                	ld	s5,8(sp)
    800049ca:	b7f9                	j	80004998 <fileclose+0x8e>

00000000800049cc <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    800049cc:	715d                	addi	sp,sp,-80
    800049ce:	e486                	sd	ra,72(sp)
    800049d0:	e0a2                	sd	s0,64(sp)
    800049d2:	fc26                	sd	s1,56(sp)
    800049d4:	f44e                	sd	s3,40(sp)
    800049d6:	0880                	addi	s0,sp,80
    800049d8:	84aa                	mv	s1,a0
    800049da:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    800049dc:	a88fd0ef          	jal	80001c64 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    800049e0:	409c                	lw	a5,0(s1)
    800049e2:	37f9                	addiw	a5,a5,-2
    800049e4:	4705                	li	a4,1
    800049e6:	04f76063          	bltu	a4,a5,80004a26 <filestat+0x5a>
    800049ea:	f84a                	sd	s2,48(sp)
    800049ec:	892a                	mv	s2,a0
    ilock(f->ip);
    800049ee:	6c88                	ld	a0,24(s1)
    800049f0:	924ff0ef          	jal	80003b14 <ilock>
    stati(f->ip, &st);
    800049f4:	fb840593          	addi	a1,s0,-72
    800049f8:	6c88                	ld	a0,24(s1)
    800049fa:	c80ff0ef          	jal	80003e7a <stati>
    iunlock(f->ip);
    800049fe:	6c88                	ld	a0,24(s1)
    80004a00:	9c2ff0ef          	jal	80003bc2 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    80004a04:	46e1                	li	a3,24
    80004a06:	fb840613          	addi	a2,s0,-72
    80004a0a:	85ce                	mv	a1,s3
    80004a0c:	05093503          	ld	a0,80(s2)
    80004a10:	edffc0ef          	jal	800018ee <copyout>
    80004a14:	41f5551b          	sraiw	a0,a0,0x1f
    80004a18:	7942                	ld	s2,48(sp)
      return -1;
    return 0;
  }
  return -1;
}
    80004a1a:	60a6                	ld	ra,72(sp)
    80004a1c:	6406                	ld	s0,64(sp)
    80004a1e:	74e2                	ld	s1,56(sp)
    80004a20:	79a2                	ld	s3,40(sp)
    80004a22:	6161                	addi	sp,sp,80
    80004a24:	8082                	ret
  return -1;
    80004a26:	557d                	li	a0,-1
    80004a28:	bfcd                	j	80004a1a <filestat+0x4e>

0000000080004a2a <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    80004a2a:	7179                	addi	sp,sp,-48
    80004a2c:	f406                	sd	ra,40(sp)
    80004a2e:	f022                	sd	s0,32(sp)
    80004a30:	e84a                	sd	s2,16(sp)
    80004a32:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    80004a34:	00854783          	lbu	a5,8(a0)
    80004a38:	cfd1                	beqz	a5,80004ad4 <fileread+0xaa>
    80004a3a:	ec26                	sd	s1,24(sp)
    80004a3c:	e44e                	sd	s3,8(sp)
    80004a3e:	84aa                	mv	s1,a0
    80004a40:	89ae                	mv	s3,a1
    80004a42:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    80004a44:	411c                	lw	a5,0(a0)
    80004a46:	4705                	li	a4,1
    80004a48:	04e78363          	beq	a5,a4,80004a8e <fileread+0x64>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004a4c:	470d                	li	a4,3
    80004a4e:	04e78763          	beq	a5,a4,80004a9c <fileread+0x72>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    80004a52:	4709                	li	a4,2
    80004a54:	06e79a63          	bne	a5,a4,80004ac8 <fileread+0x9e>
    ilock(f->ip);
    80004a58:	6d08                	ld	a0,24(a0)
    80004a5a:	8baff0ef          	jal	80003b14 <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    80004a5e:	874a                	mv	a4,s2
    80004a60:	5094                	lw	a3,32(s1)
    80004a62:	864e                	mv	a2,s3
    80004a64:	4585                	li	a1,1
    80004a66:	6c88                	ld	a0,24(s1)
    80004a68:	c3cff0ef          	jal	80003ea4 <readi>
    80004a6c:	892a                	mv	s2,a0
    80004a6e:	00a05563          	blez	a0,80004a78 <fileread+0x4e>
      f->off += r;
    80004a72:	509c                	lw	a5,32(s1)
    80004a74:	9fa9                	addw	a5,a5,a0
    80004a76:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80004a78:	6c88                	ld	a0,24(s1)
    80004a7a:	948ff0ef          	jal	80003bc2 <iunlock>
    80004a7e:	64e2                	ld	s1,24(sp)
    80004a80:	69a2                	ld	s3,8(sp)
  } else {
    panic("fileread");
  }

  return r;
}
    80004a82:	854a                	mv	a0,s2
    80004a84:	70a2                	ld	ra,40(sp)
    80004a86:	7402                	ld	s0,32(sp)
    80004a88:	6942                	ld	s2,16(sp)
    80004a8a:	6145                	addi	sp,sp,48
    80004a8c:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80004a8e:	6908                	ld	a0,16(a0)
    80004a90:	388000ef          	jal	80004e18 <piperead>
    80004a94:	892a                	mv	s2,a0
    80004a96:	64e2                	ld	s1,24(sp)
    80004a98:	69a2                	ld	s3,8(sp)
    80004a9a:	b7e5                	j	80004a82 <fileread+0x58>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80004a9c:	02451783          	lh	a5,36(a0)
    80004aa0:	03079693          	slli	a3,a5,0x30
    80004aa4:	92c1                	srli	a3,a3,0x30
    80004aa6:	4725                	li	a4,9
    80004aa8:	02d76863          	bltu	a4,a3,80004ad8 <fileread+0xae>
    80004aac:	0792                	slli	a5,a5,0x4
    80004aae:	0001c717          	auipc	a4,0x1c
    80004ab2:	1f270713          	addi	a4,a4,498 # 80020ca0 <devsw>
    80004ab6:	97ba                	add	a5,a5,a4
    80004ab8:	639c                	ld	a5,0(a5)
    80004aba:	c39d                	beqz	a5,80004ae0 <fileread+0xb6>
    r = devsw[f->major].read(1, addr, n);
    80004abc:	4505                	li	a0,1
    80004abe:	9782                	jalr	a5
    80004ac0:	892a                	mv	s2,a0
    80004ac2:	64e2                	ld	s1,24(sp)
    80004ac4:	69a2                	ld	s3,8(sp)
    80004ac6:	bf75                	j	80004a82 <fileread+0x58>
    panic("fileread");
    80004ac8:	00004517          	auipc	a0,0x4
    80004acc:	af850513          	addi	a0,a0,-1288 # 800085c0 <etext+0x5c0>
    80004ad0:	d43fb0ef          	jal	80000812 <panic>
    return -1;
    80004ad4:	597d                	li	s2,-1
    80004ad6:	b775                	j	80004a82 <fileread+0x58>
      return -1;
    80004ad8:	597d                	li	s2,-1
    80004ada:	64e2                	ld	s1,24(sp)
    80004adc:	69a2                	ld	s3,8(sp)
    80004ade:	b755                	j	80004a82 <fileread+0x58>
    80004ae0:	597d                	li	s2,-1
    80004ae2:	64e2                	ld	s1,24(sp)
    80004ae4:	69a2                	ld	s3,8(sp)
    80004ae6:	bf71                	j	80004a82 <fileread+0x58>

0000000080004ae8 <filewrite>:
int
filewrite(struct file *f, uint64 addr, int n)
{
  int r, ret = 0;

  if(f->writable == 0)
    80004ae8:	00954783          	lbu	a5,9(a0)
    80004aec:	10078b63          	beqz	a5,80004c02 <filewrite+0x11a>
{
    80004af0:	715d                	addi	sp,sp,-80
    80004af2:	e486                	sd	ra,72(sp)
    80004af4:	e0a2                	sd	s0,64(sp)
    80004af6:	f84a                	sd	s2,48(sp)
    80004af8:	f052                	sd	s4,32(sp)
    80004afa:	e85a                	sd	s6,16(sp)
    80004afc:	0880                	addi	s0,sp,80
    80004afe:	892a                	mv	s2,a0
    80004b00:	8b2e                	mv	s6,a1
    80004b02:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    80004b04:	411c                	lw	a5,0(a0)
    80004b06:	4705                	li	a4,1
    80004b08:	02e78763          	beq	a5,a4,80004b36 <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004b0c:	470d                	li	a4,3
    80004b0e:	02e78863          	beq	a5,a4,80004b3e <filewrite+0x56>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    80004b12:	4709                	li	a4,2
    80004b14:	0ce79c63          	bne	a5,a4,80004bec <filewrite+0x104>
    80004b18:	f44e                	sd	s3,40(sp)
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    80004b1a:	0ac05863          	blez	a2,80004bca <filewrite+0xe2>
    80004b1e:	fc26                	sd	s1,56(sp)
    80004b20:	ec56                	sd	s5,24(sp)
    80004b22:	e45e                	sd	s7,8(sp)
    80004b24:	e062                	sd	s8,0(sp)
    int i = 0;
    80004b26:	4981                	li	s3,0
      int n1 = n - i;
      if(n1 > max)
    80004b28:	6b85                	lui	s7,0x1
    80004b2a:	c00b8b93          	addi	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    80004b2e:	6c05                	lui	s8,0x1
    80004b30:	c00c0c1b          	addiw	s8,s8,-1024 # c00 <_entry-0x7ffff400>
    80004b34:	a8b5                	j	80004bb0 <filewrite+0xc8>
    ret = pipewrite(f->pipe, addr, n);
    80004b36:	6908                	ld	a0,16(a0)
    80004b38:	1fc000ef          	jal	80004d34 <pipewrite>
    80004b3c:	a04d                	j	80004bde <filewrite+0xf6>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80004b3e:	02451783          	lh	a5,36(a0)
    80004b42:	03079693          	slli	a3,a5,0x30
    80004b46:	92c1                	srli	a3,a3,0x30
    80004b48:	4725                	li	a4,9
    80004b4a:	0ad76e63          	bltu	a4,a3,80004c06 <filewrite+0x11e>
    80004b4e:	0792                	slli	a5,a5,0x4
    80004b50:	0001c717          	auipc	a4,0x1c
    80004b54:	15070713          	addi	a4,a4,336 # 80020ca0 <devsw>
    80004b58:	97ba                	add	a5,a5,a4
    80004b5a:	679c                	ld	a5,8(a5)
    80004b5c:	c7dd                	beqz	a5,80004c0a <filewrite+0x122>
    ret = devsw[f->major].write(1, addr, n);
    80004b5e:	4505                	li	a0,1
    80004b60:	9782                	jalr	a5
    80004b62:	a8b5                	j	80004bde <filewrite+0xf6>
      if(n1 > max)
    80004b64:	00048a9b          	sext.w	s5,s1
        n1 = max;

      begin_op();
    80004b68:	997ff0ef          	jal	800044fe <begin_op>
      ilock(f->ip);
    80004b6c:	01893503          	ld	a0,24(s2)
    80004b70:	fa5fe0ef          	jal	80003b14 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80004b74:	8756                	mv	a4,s5
    80004b76:	02092683          	lw	a3,32(s2)
    80004b7a:	01698633          	add	a2,s3,s6
    80004b7e:	4585                	li	a1,1
    80004b80:	01893503          	ld	a0,24(s2)
    80004b84:	c1cff0ef          	jal	80003fa0 <writei>
    80004b88:	84aa                	mv	s1,a0
    80004b8a:	00a05763          	blez	a0,80004b98 <filewrite+0xb0>
        f->off += r;
    80004b8e:	02092783          	lw	a5,32(s2)
    80004b92:	9fa9                	addw	a5,a5,a0
    80004b94:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80004b98:	01893503          	ld	a0,24(s2)
    80004b9c:	826ff0ef          	jal	80003bc2 <iunlock>
      end_op();
    80004ba0:	9c9ff0ef          	jal	80004568 <end_op>

      if(r != n1){
    80004ba4:	029a9563          	bne	s5,s1,80004bce <filewrite+0xe6>
        // error from writei
        break;
      }
      i += r;
    80004ba8:	013489bb          	addw	s3,s1,s3
    while(i < n){
    80004bac:	0149da63          	bge	s3,s4,80004bc0 <filewrite+0xd8>
      int n1 = n - i;
    80004bb0:	413a04bb          	subw	s1,s4,s3
      if(n1 > max)
    80004bb4:	0004879b          	sext.w	a5,s1
    80004bb8:	fafbd6e3          	bge	s7,a5,80004b64 <filewrite+0x7c>
    80004bbc:	84e2                	mv	s1,s8
    80004bbe:	b75d                	j	80004b64 <filewrite+0x7c>
    80004bc0:	74e2                	ld	s1,56(sp)
    80004bc2:	6ae2                	ld	s5,24(sp)
    80004bc4:	6ba2                	ld	s7,8(sp)
    80004bc6:	6c02                	ld	s8,0(sp)
    80004bc8:	a039                	j	80004bd6 <filewrite+0xee>
    int i = 0;
    80004bca:	4981                	li	s3,0
    80004bcc:	a029                	j	80004bd6 <filewrite+0xee>
    80004bce:	74e2                	ld	s1,56(sp)
    80004bd0:	6ae2                	ld	s5,24(sp)
    80004bd2:	6ba2                	ld	s7,8(sp)
    80004bd4:	6c02                	ld	s8,0(sp)
    }
    ret = (i == n ? n : -1);
    80004bd6:	033a1c63          	bne	s4,s3,80004c0e <filewrite+0x126>
    80004bda:	8552                	mv	a0,s4
    80004bdc:	79a2                	ld	s3,40(sp)
  } else {
    panic("filewrite");
  }

  return ret;
}
    80004bde:	60a6                	ld	ra,72(sp)
    80004be0:	6406                	ld	s0,64(sp)
    80004be2:	7942                	ld	s2,48(sp)
    80004be4:	7a02                	ld	s4,32(sp)
    80004be6:	6b42                	ld	s6,16(sp)
    80004be8:	6161                	addi	sp,sp,80
    80004bea:	8082                	ret
    80004bec:	fc26                	sd	s1,56(sp)
    80004bee:	f44e                	sd	s3,40(sp)
    80004bf0:	ec56                	sd	s5,24(sp)
    80004bf2:	e45e                	sd	s7,8(sp)
    80004bf4:	e062                	sd	s8,0(sp)
    panic("filewrite");
    80004bf6:	00004517          	auipc	a0,0x4
    80004bfa:	9da50513          	addi	a0,a0,-1574 # 800085d0 <etext+0x5d0>
    80004bfe:	c15fb0ef          	jal	80000812 <panic>
    return -1;
    80004c02:	557d                	li	a0,-1
}
    80004c04:	8082                	ret
      return -1;
    80004c06:	557d                	li	a0,-1
    80004c08:	bfd9                	j	80004bde <filewrite+0xf6>
    80004c0a:	557d                	li	a0,-1
    80004c0c:	bfc9                	j	80004bde <filewrite+0xf6>
    ret = (i == n ? n : -1);
    80004c0e:	557d                	li	a0,-1
    80004c10:	79a2                	ld	s3,40(sp)
    80004c12:	b7f1                	j	80004bde <filewrite+0xf6>

0000000080004c14 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80004c14:	7179                	addi	sp,sp,-48
    80004c16:	f406                	sd	ra,40(sp)
    80004c18:	f022                	sd	s0,32(sp)
    80004c1a:	ec26                	sd	s1,24(sp)
    80004c1c:	e052                	sd	s4,0(sp)
    80004c1e:	1800                	addi	s0,sp,48
    80004c20:	84aa                	mv	s1,a0
    80004c22:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80004c24:	0005b023          	sd	zero,0(a1)
    80004c28:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80004c2c:	c3bff0ef          	jal	80004866 <filealloc>
    80004c30:	e088                	sd	a0,0(s1)
    80004c32:	c549                	beqz	a0,80004cbc <pipealloc+0xa8>
    80004c34:	c33ff0ef          	jal	80004866 <filealloc>
    80004c38:	00aa3023          	sd	a0,0(s4)
    80004c3c:	cd25                	beqz	a0,80004cb4 <pipealloc+0xa0>
    80004c3e:	e84a                	sd	s2,16(sp)
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80004c40:	f4ffb0ef          	jal	80000b8e <kalloc>
    80004c44:	892a                	mv	s2,a0
    80004c46:	c12d                	beqz	a0,80004ca8 <pipealloc+0x94>
    80004c48:	e44e                	sd	s3,8(sp)
    goto bad;
  pi->readopen = 1;
    80004c4a:	4985                	li	s3,1
    80004c4c:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    80004c50:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    80004c54:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80004c58:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80004c5c:	00004597          	auipc	a1,0x4
    80004c60:	98458593          	addi	a1,a1,-1660 # 800085e0 <etext+0x5e0>
    80004c64:	fd9fb0ef          	jal	80000c3c <initlock>
  (*f0)->type = FD_PIPE;
    80004c68:	609c                	ld	a5,0(s1)
    80004c6a:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80004c6e:	609c                	ld	a5,0(s1)
    80004c70:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80004c74:	609c                	ld	a5,0(s1)
    80004c76:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80004c7a:	609c                	ld	a5,0(s1)
    80004c7c:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80004c80:	000a3783          	ld	a5,0(s4)
    80004c84:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80004c88:	000a3783          	ld	a5,0(s4)
    80004c8c:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80004c90:	000a3783          	ld	a5,0(s4)
    80004c94:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80004c98:	000a3783          	ld	a5,0(s4)
    80004c9c:	0127b823          	sd	s2,16(a5)
  return 0;
    80004ca0:	4501                	li	a0,0
    80004ca2:	6942                	ld	s2,16(sp)
    80004ca4:	69a2                	ld	s3,8(sp)
    80004ca6:	a01d                	j	80004ccc <pipealloc+0xb8>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80004ca8:	6088                	ld	a0,0(s1)
    80004caa:	c119                	beqz	a0,80004cb0 <pipealloc+0x9c>
    80004cac:	6942                	ld	s2,16(sp)
    80004cae:	a029                	j	80004cb8 <pipealloc+0xa4>
    80004cb0:	6942                	ld	s2,16(sp)
    80004cb2:	a029                	j	80004cbc <pipealloc+0xa8>
    80004cb4:	6088                	ld	a0,0(s1)
    80004cb6:	c10d                	beqz	a0,80004cd8 <pipealloc+0xc4>
    fileclose(*f0);
    80004cb8:	c53ff0ef          	jal	8000490a <fileclose>
  if(*f1)
    80004cbc:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80004cc0:	557d                	li	a0,-1
  if(*f1)
    80004cc2:	c789                	beqz	a5,80004ccc <pipealloc+0xb8>
    fileclose(*f1);
    80004cc4:	853e                	mv	a0,a5
    80004cc6:	c45ff0ef          	jal	8000490a <fileclose>
  return -1;
    80004cca:	557d                	li	a0,-1
}
    80004ccc:	70a2                	ld	ra,40(sp)
    80004cce:	7402                	ld	s0,32(sp)
    80004cd0:	64e2                	ld	s1,24(sp)
    80004cd2:	6a02                	ld	s4,0(sp)
    80004cd4:	6145                	addi	sp,sp,48
    80004cd6:	8082                	ret
  return -1;
    80004cd8:	557d                	li	a0,-1
    80004cda:	bfcd                	j	80004ccc <pipealloc+0xb8>

0000000080004cdc <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80004cdc:	1101                	addi	sp,sp,-32
    80004cde:	ec06                	sd	ra,24(sp)
    80004ce0:	e822                	sd	s0,16(sp)
    80004ce2:	e426                	sd	s1,8(sp)
    80004ce4:	e04a                	sd	s2,0(sp)
    80004ce6:	1000                	addi	s0,sp,32
    80004ce8:	84aa                	mv	s1,a0
    80004cea:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80004cec:	fd1fb0ef          	jal	80000cbc <acquire>
  if(writable){
    80004cf0:	02090763          	beqz	s2,80004d1e <pipeclose+0x42>
    pi->writeopen = 0;
    80004cf4:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80004cf8:	21848513          	addi	a0,s1,536
    80004cfc:	87ffd0ef          	jal	8000257a <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80004d00:	2204b783          	ld	a5,544(s1)
    80004d04:	e785                	bnez	a5,80004d2c <pipeclose+0x50>
    release(&pi->lock);
    80004d06:	8526                	mv	a0,s1
    80004d08:	84cfc0ef          	jal	80000d54 <release>
    kfree((char*)pi);
    80004d0c:	8526                	mv	a0,s1
    80004d0e:	d41fb0ef          	jal	80000a4e <kfree>
  } else
    release(&pi->lock);
}
    80004d12:	60e2                	ld	ra,24(sp)
    80004d14:	6442                	ld	s0,16(sp)
    80004d16:	64a2                	ld	s1,8(sp)
    80004d18:	6902                	ld	s2,0(sp)
    80004d1a:	6105                	addi	sp,sp,32
    80004d1c:	8082                	ret
    pi->readopen = 0;
    80004d1e:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80004d22:	21c48513          	addi	a0,s1,540
    80004d26:	855fd0ef          	jal	8000257a <wakeup>
    80004d2a:	bfd9                	j	80004d00 <pipeclose+0x24>
    release(&pi->lock);
    80004d2c:	8526                	mv	a0,s1
    80004d2e:	826fc0ef          	jal	80000d54 <release>
}
    80004d32:	b7c5                	j	80004d12 <pipeclose+0x36>

0000000080004d34 <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80004d34:	711d                	addi	sp,sp,-96
    80004d36:	ec86                	sd	ra,88(sp)
    80004d38:	e8a2                	sd	s0,80(sp)
    80004d3a:	e4a6                	sd	s1,72(sp)
    80004d3c:	e0ca                	sd	s2,64(sp)
    80004d3e:	fc4e                	sd	s3,56(sp)
    80004d40:	f852                	sd	s4,48(sp)
    80004d42:	f456                	sd	s5,40(sp)
    80004d44:	1080                	addi	s0,sp,96
    80004d46:	84aa                	mv	s1,a0
    80004d48:	8aae                	mv	s5,a1
    80004d4a:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    80004d4c:	f19fc0ef          	jal	80001c64 <myproc>
    80004d50:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    80004d52:	8526                	mv	a0,s1
    80004d54:	f69fb0ef          	jal	80000cbc <acquire>
  while(i < n){
    80004d58:	0b405a63          	blez	s4,80004e0c <pipewrite+0xd8>
    80004d5c:	f05a                	sd	s6,32(sp)
    80004d5e:	ec5e                	sd	s7,24(sp)
    80004d60:	e862                	sd	s8,16(sp)
  int i = 0;
    80004d62:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004d64:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    80004d66:	21848c13          	addi	s8,s1,536
      sleep(&pi->nwrite, &pi->lock);
    80004d6a:	21c48b93          	addi	s7,s1,540
    80004d6e:	a81d                	j	80004da4 <pipewrite+0x70>
      release(&pi->lock);
    80004d70:	8526                	mv	a0,s1
    80004d72:	fe3fb0ef          	jal	80000d54 <release>
      return -1;
    80004d76:	597d                	li	s2,-1
    80004d78:	7b02                	ld	s6,32(sp)
    80004d7a:	6be2                	ld	s7,24(sp)
    80004d7c:	6c42                	ld	s8,16(sp)
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    80004d7e:	854a                	mv	a0,s2
    80004d80:	60e6                	ld	ra,88(sp)
    80004d82:	6446                	ld	s0,80(sp)
    80004d84:	64a6                	ld	s1,72(sp)
    80004d86:	6906                	ld	s2,64(sp)
    80004d88:	79e2                	ld	s3,56(sp)
    80004d8a:	7a42                	ld	s4,48(sp)
    80004d8c:	7aa2                	ld	s5,40(sp)
    80004d8e:	6125                	addi	sp,sp,96
    80004d90:	8082                	ret
      wakeup(&pi->nread);
    80004d92:	8562                	mv	a0,s8
    80004d94:	fe6fd0ef          	jal	8000257a <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80004d98:	85a6                	mv	a1,s1
    80004d9a:	855e                	mv	a0,s7
    80004d9c:	f8efd0ef          	jal	8000252a <sleep>
  while(i < n){
    80004da0:	05495b63          	bge	s2,s4,80004df6 <pipewrite+0xc2>
    if(pi->readopen == 0 || killed(pr)){
    80004da4:	2204a783          	lw	a5,544(s1)
    80004da8:	d7e1                	beqz	a5,80004d70 <pipewrite+0x3c>
    80004daa:	854e                	mv	a0,s3
    80004dac:	9ddfd0ef          	jal	80002788 <killed>
    80004db0:	f161                	bnez	a0,80004d70 <pipewrite+0x3c>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    80004db2:	2184a783          	lw	a5,536(s1)
    80004db6:	21c4a703          	lw	a4,540(s1)
    80004dba:	2007879b          	addiw	a5,a5,512
    80004dbe:	fcf70ae3          	beq	a4,a5,80004d92 <pipewrite+0x5e>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004dc2:	4685                	li	a3,1
    80004dc4:	01590633          	add	a2,s2,s5
    80004dc8:	faf40593          	addi	a1,s0,-81
    80004dcc:	0509b503          	ld	a0,80(s3)
    80004dd0:	c03fc0ef          	jal	800019d2 <copyin>
    80004dd4:	03650e63          	beq	a0,s6,80004e10 <pipewrite+0xdc>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80004dd8:	21c4a783          	lw	a5,540(s1)
    80004ddc:	0017871b          	addiw	a4,a5,1
    80004de0:	20e4ae23          	sw	a4,540(s1)
    80004de4:	1ff7f793          	andi	a5,a5,511
    80004de8:	97a6                	add	a5,a5,s1
    80004dea:	faf44703          	lbu	a4,-81(s0)
    80004dee:	00e78c23          	sb	a4,24(a5)
      i++;
    80004df2:	2905                	addiw	s2,s2,1
    80004df4:	b775                	j	80004da0 <pipewrite+0x6c>
    80004df6:	7b02                	ld	s6,32(sp)
    80004df8:	6be2                	ld	s7,24(sp)
    80004dfa:	6c42                	ld	s8,16(sp)
  wakeup(&pi->nread);
    80004dfc:	21848513          	addi	a0,s1,536
    80004e00:	f7afd0ef          	jal	8000257a <wakeup>
  release(&pi->lock);
    80004e04:	8526                	mv	a0,s1
    80004e06:	f4ffb0ef          	jal	80000d54 <release>
  return i;
    80004e0a:	bf95                	j	80004d7e <pipewrite+0x4a>
  int i = 0;
    80004e0c:	4901                	li	s2,0
    80004e0e:	b7fd                	j	80004dfc <pipewrite+0xc8>
    80004e10:	7b02                	ld	s6,32(sp)
    80004e12:	6be2                	ld	s7,24(sp)
    80004e14:	6c42                	ld	s8,16(sp)
    80004e16:	b7dd                	j	80004dfc <pipewrite+0xc8>

0000000080004e18 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80004e18:	715d                	addi	sp,sp,-80
    80004e1a:	e486                	sd	ra,72(sp)
    80004e1c:	e0a2                	sd	s0,64(sp)
    80004e1e:	fc26                	sd	s1,56(sp)
    80004e20:	f84a                	sd	s2,48(sp)
    80004e22:	f44e                	sd	s3,40(sp)
    80004e24:	f052                	sd	s4,32(sp)
    80004e26:	ec56                	sd	s5,24(sp)
    80004e28:	0880                	addi	s0,sp,80
    80004e2a:	84aa                	mv	s1,a0
    80004e2c:	892e                	mv	s2,a1
    80004e2e:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80004e30:	e35fc0ef          	jal	80001c64 <myproc>
    80004e34:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80004e36:	8526                	mv	a0,s1
    80004e38:	e85fb0ef          	jal	80000cbc <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004e3c:	2184a703          	lw	a4,536(s1)
    80004e40:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004e44:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004e48:	02f71563          	bne	a4,a5,80004e72 <piperead+0x5a>
    80004e4c:	2244a783          	lw	a5,548(s1)
    80004e50:	cb85                	beqz	a5,80004e80 <piperead+0x68>
    if(killed(pr)){
    80004e52:	8552                	mv	a0,s4
    80004e54:	935fd0ef          	jal	80002788 <killed>
    80004e58:	ed19                	bnez	a0,80004e76 <piperead+0x5e>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004e5a:	85a6                	mv	a1,s1
    80004e5c:	854e                	mv	a0,s3
    80004e5e:	eccfd0ef          	jal	8000252a <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004e62:	2184a703          	lw	a4,536(s1)
    80004e66:	21c4a783          	lw	a5,540(s1)
    80004e6a:	fef701e3          	beq	a4,a5,80004e4c <piperead+0x34>
    80004e6e:	e85a                	sd	s6,16(sp)
    80004e70:	a809                	j	80004e82 <piperead+0x6a>
    80004e72:	e85a                	sd	s6,16(sp)
    80004e74:	a039                	j	80004e82 <piperead+0x6a>
      release(&pi->lock);
    80004e76:	8526                	mv	a0,s1
    80004e78:	eddfb0ef          	jal	80000d54 <release>
      return -1;
    80004e7c:	59fd                	li	s3,-1
    80004e7e:	a8b9                	j	80004edc <piperead+0xc4>
    80004e80:	e85a                	sd	s6,16(sp)
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004e82:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1) {
    80004e84:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004e86:	05505363          	blez	s5,80004ecc <piperead+0xb4>
    if(pi->nread == pi->nwrite)
    80004e8a:	2184a783          	lw	a5,536(s1)
    80004e8e:	21c4a703          	lw	a4,540(s1)
    80004e92:	02f70d63          	beq	a4,a5,80004ecc <piperead+0xb4>
    ch = pi->data[pi->nread % PIPESIZE];
    80004e96:	1ff7f793          	andi	a5,a5,511
    80004e9a:	97a6                	add	a5,a5,s1
    80004e9c:	0187c783          	lbu	a5,24(a5)
    80004ea0:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1) {
    80004ea4:	4685                	li	a3,1
    80004ea6:	fbf40613          	addi	a2,s0,-65
    80004eaa:	85ca                	mv	a1,s2
    80004eac:	050a3503          	ld	a0,80(s4)
    80004eb0:	a3ffc0ef          	jal	800018ee <copyout>
    80004eb4:	03650e63          	beq	a0,s6,80004ef0 <piperead+0xd8>
      if(i == 0)
        i = -1;
      break;
    }
    pi->nread++;
    80004eb8:	2184a783          	lw	a5,536(s1)
    80004ebc:	2785                	addiw	a5,a5,1
    80004ebe:	20f4ac23          	sw	a5,536(s1)
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004ec2:	2985                	addiw	s3,s3,1
    80004ec4:	0905                	addi	s2,s2,1
    80004ec6:	fd3a92e3          	bne	s5,s3,80004e8a <piperead+0x72>
    80004eca:	89d6                	mv	s3,s5
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80004ecc:	21c48513          	addi	a0,s1,540
    80004ed0:	eaafd0ef          	jal	8000257a <wakeup>
  release(&pi->lock);
    80004ed4:	8526                	mv	a0,s1
    80004ed6:	e7ffb0ef          	jal	80000d54 <release>
    80004eda:	6b42                	ld	s6,16(sp)
  return i;
}
    80004edc:	854e                	mv	a0,s3
    80004ede:	60a6                	ld	ra,72(sp)
    80004ee0:	6406                	ld	s0,64(sp)
    80004ee2:	74e2                	ld	s1,56(sp)
    80004ee4:	7942                	ld	s2,48(sp)
    80004ee6:	79a2                	ld	s3,40(sp)
    80004ee8:	7a02                	ld	s4,32(sp)
    80004eea:	6ae2                	ld	s5,24(sp)
    80004eec:	6161                	addi	sp,sp,80
    80004eee:	8082                	ret
      if(i == 0)
    80004ef0:	fc099ee3          	bnez	s3,80004ecc <piperead+0xb4>
        i = -1;
    80004ef4:	89aa                	mv	s3,a0
    80004ef6:	bfd9                	j	80004ecc <piperead+0xb4>

0000000080004ef8 <flags2perm>:

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

// map ELF permissions to PTE permission bits.
int flags2perm(int flags)
{
    80004ef8:	1141                	addi	sp,sp,-16
    80004efa:	e422                	sd	s0,8(sp)
    80004efc:	0800                	addi	s0,sp,16
    80004efe:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    80004f00:	8905                	andi	a0,a0,1
    80004f02:	050e                	slli	a0,a0,0x3
      perm = PTE_X;
    if(flags & 0x2)
    80004f04:	8b89                	andi	a5,a5,2
    80004f06:	c399                	beqz	a5,80004f0c <flags2perm+0x14>
      perm |= PTE_W;
    80004f08:	00456513          	ori	a0,a0,4
    return perm;
}
    80004f0c:	6422                	ld	s0,8(sp)
    80004f0e:	0141                	addi	sp,sp,16
    80004f10:	8082                	ret

0000000080004f12 <kexec>:
//
// the implementation of the exec() system call
//
int
kexec(char *path, char **argv)
{
    80004f12:	df010113          	addi	sp,sp,-528
    80004f16:	20113423          	sd	ra,520(sp)
    80004f1a:	20813023          	sd	s0,512(sp)
    80004f1e:	ffa6                	sd	s1,504(sp)
    80004f20:	fbca                	sd	s2,496(sp)
    80004f22:	0c00                	addi	s0,sp,528
    80004f24:	892a                	mv	s2,a0
    80004f26:	dea43c23          	sd	a0,-520(s0)
    80004f2a:	e0b43023          	sd	a1,-512(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80004f2e:	d37fc0ef          	jal	80001c64 <myproc>
    80004f32:	84aa                	mv	s1,a0

  begin_op();
    80004f34:	dcaff0ef          	jal	800044fe <begin_op>

  // Open the executable file.
  if((ip = namei(path)) == 0){
    80004f38:	854a                	mv	a0,s2
    80004f3a:	bf0ff0ef          	jal	8000432a <namei>
    80004f3e:	c931                	beqz	a0,80004f92 <kexec+0x80>
    80004f40:	f3d2                	sd	s4,480(sp)
    80004f42:	8a2a                	mv	s4,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80004f44:	bd1fe0ef          	jal	80003b14 <ilock>

  // Read the ELF header.
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80004f48:	04000713          	li	a4,64
    80004f4c:	4681                	li	a3,0
    80004f4e:	e5040613          	addi	a2,s0,-432
    80004f52:	4581                	li	a1,0
    80004f54:	8552                	mv	a0,s4
    80004f56:	f4ffe0ef          	jal	80003ea4 <readi>
    80004f5a:	04000793          	li	a5,64
    80004f5e:	00f51a63          	bne	a0,a5,80004f72 <kexec+0x60>
    goto bad;

  // Is this really an ELF file?
  if(elf.magic != ELF_MAGIC)
    80004f62:	e5042703          	lw	a4,-432(s0)
    80004f66:	464c47b7          	lui	a5,0x464c4
    80004f6a:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80004f6e:	02f70663          	beq	a4,a5,80004f9a <kexec+0x88>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    80004f72:	8552                	mv	a0,s4
    80004f74:	dabfe0ef          	jal	80003d1e <iunlockput>
    end_op();
    80004f78:	df0ff0ef          	jal	80004568 <end_op>
  }
  return -1;
    80004f7c:	557d                	li	a0,-1
    80004f7e:	7a1e                	ld	s4,480(sp)
}
    80004f80:	20813083          	ld	ra,520(sp)
    80004f84:	20013403          	ld	s0,512(sp)
    80004f88:	74fe                	ld	s1,504(sp)
    80004f8a:	795e                	ld	s2,496(sp)
    80004f8c:	21010113          	addi	sp,sp,528
    80004f90:	8082                	ret
    end_op();
    80004f92:	dd6ff0ef          	jal	80004568 <end_op>
    return -1;
    80004f96:	557d                	li	a0,-1
    80004f98:	b7e5                	j	80004f80 <kexec+0x6e>
    80004f9a:	ebda                	sd	s6,464(sp)
  if((pagetable = proc_pagetable(p)) == 0)
    80004f9c:	8526                	mv	a0,s1
    80004f9e:	dd3fc0ef          	jal	80001d70 <proc_pagetable>
    80004fa2:	8b2a                	mv	s6,a0
    80004fa4:	2c050b63          	beqz	a0,8000527a <kexec+0x368>
    80004fa8:	f7ce                	sd	s3,488(sp)
    80004faa:	efd6                	sd	s5,472(sp)
    80004fac:	e7de                	sd	s7,456(sp)
    80004fae:	e3e2                	sd	s8,448(sp)
    80004fb0:	ff66                	sd	s9,440(sp)
    80004fb2:	fb6a                	sd	s10,432(sp)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004fb4:	e7042d03          	lw	s10,-400(s0)
    80004fb8:	e8845783          	lhu	a5,-376(s0)
    80004fbc:	12078963          	beqz	a5,800050ee <kexec+0x1dc>
    80004fc0:	f76e                	sd	s11,424(sp)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004fc2:	4901                	li	s2,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004fc4:	4d81                	li	s11,0
    if(ph.vaddr % PGSIZE != 0)
    80004fc6:	6c85                	lui	s9,0x1
    80004fc8:	fffc8793          	addi	a5,s9,-1 # fff <_entry-0x7ffff001>
    80004fcc:	def43823          	sd	a5,-528(s0)

  for(i = 0; i < sz; i += PGSIZE){
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    if(sz - i < PGSIZE)
    80004fd0:	6a85                	lui	s5,0x1
    80004fd2:	a085                	j	80005032 <kexec+0x120>
      panic("loadseg: address should exist");
    80004fd4:	00003517          	auipc	a0,0x3
    80004fd8:	61450513          	addi	a0,a0,1556 # 800085e8 <etext+0x5e8>
    80004fdc:	837fb0ef          	jal	80000812 <panic>
    if(sz - i < PGSIZE)
    80004fe0:	2481                	sext.w	s1,s1
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80004fe2:	8726                	mv	a4,s1
    80004fe4:	012c06bb          	addw	a3,s8,s2
    80004fe8:	4581                	li	a1,0
    80004fea:	8552                	mv	a0,s4
    80004fec:	eb9fe0ef          	jal	80003ea4 <readi>
    80004ff0:	2501                	sext.w	a0,a0
    80004ff2:	24a49a63          	bne	s1,a0,80005246 <kexec+0x334>
  for(i = 0; i < sz; i += PGSIZE){
    80004ff6:	012a893b          	addw	s2,s5,s2
    80004ffa:	03397363          	bgeu	s2,s3,80005020 <kexec+0x10e>
    pa = walkaddr(pagetable, va + i);
    80004ffe:	02091593          	slli	a1,s2,0x20
    80005002:	9181                	srli	a1,a1,0x20
    80005004:	95de                	add	a1,a1,s7
    80005006:	855a                	mv	a0,s6
    80005008:	8befc0ef          	jal	800010c6 <walkaddr>
    8000500c:	862a                	mv	a2,a0
    if(pa == 0)
    8000500e:	d179                	beqz	a0,80004fd4 <kexec+0xc2>
    if(sz - i < PGSIZE)
    80005010:	412984bb          	subw	s1,s3,s2
    80005014:	0004879b          	sext.w	a5,s1
    80005018:	fcfcf4e3          	bgeu	s9,a5,80004fe0 <kexec+0xce>
    8000501c:	84d6                	mv	s1,s5
    8000501e:	b7c9                	j	80004fe0 <kexec+0xce>
    sz = sz1;
    80005020:	e0843903          	ld	s2,-504(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80005024:	2d85                	addiw	s11,s11,1
    80005026:	038d0d1b          	addiw	s10,s10,56 # 1038 <_entry-0x7fffefc8>
    8000502a:	e8845783          	lhu	a5,-376(s0)
    8000502e:	08fdd063          	bge	s11,a5,800050ae <kexec+0x19c>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80005032:	2d01                	sext.w	s10,s10
    80005034:	03800713          	li	a4,56
    80005038:	86ea                	mv	a3,s10
    8000503a:	e1840613          	addi	a2,s0,-488
    8000503e:	4581                	li	a1,0
    80005040:	8552                	mv	a0,s4
    80005042:	e63fe0ef          	jal	80003ea4 <readi>
    80005046:	03800793          	li	a5,56
    8000504a:	1cf51663          	bne	a0,a5,80005216 <kexec+0x304>
    if(ph.type != ELF_PROG_LOAD)
    8000504e:	e1842783          	lw	a5,-488(s0)
    80005052:	4705                	li	a4,1
    80005054:	fce798e3          	bne	a5,a4,80005024 <kexec+0x112>
    if(ph.memsz < ph.filesz)
    80005058:	e4043483          	ld	s1,-448(s0)
    8000505c:	e3843783          	ld	a5,-456(s0)
    80005060:	1af4ef63          	bltu	s1,a5,8000521e <kexec+0x30c>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    80005064:	e2843783          	ld	a5,-472(s0)
    80005068:	94be                	add	s1,s1,a5
    8000506a:	1af4ee63          	bltu	s1,a5,80005226 <kexec+0x314>
    if(ph.vaddr % PGSIZE != 0)
    8000506e:	df043703          	ld	a4,-528(s0)
    80005072:	8ff9                	and	a5,a5,a4
    80005074:	1a079d63          	bnez	a5,8000522e <kexec+0x31c>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80005078:	e1c42503          	lw	a0,-484(s0)
    8000507c:	e7dff0ef          	jal	80004ef8 <flags2perm>
    80005080:	86aa                	mv	a3,a0
    80005082:	8626                	mv	a2,s1
    80005084:	85ca                	mv	a1,s2
    80005086:	855a                	mv	a0,s6
    80005088:	c32fc0ef          	jal	800014ba <uvmalloc>
    8000508c:	e0a43423          	sd	a0,-504(s0)
    80005090:	1a050363          	beqz	a0,80005236 <kexec+0x324>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80005094:	e2843b83          	ld	s7,-472(s0)
    80005098:	e2042c03          	lw	s8,-480(s0)
    8000509c:	e3842983          	lw	s3,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    800050a0:	00098463          	beqz	s3,800050a8 <kexec+0x196>
    800050a4:	4901                	li	s2,0
    800050a6:	bfa1                	j	80004ffe <kexec+0xec>
    sz = sz1;
    800050a8:	e0843903          	ld	s2,-504(s0)
    800050ac:	bfa5                	j	80005024 <kexec+0x112>
    800050ae:	7dba                	ld	s11,424(sp)
  iunlockput(ip);
    800050b0:	8552                	mv	a0,s4
    800050b2:	c6dfe0ef          	jal	80003d1e <iunlockput>
  end_op();
    800050b6:	cb2ff0ef          	jal	80004568 <end_op>
  p = myproc();
    800050ba:	babfc0ef          	jal	80001c64 <myproc>
    800050be:	8aaa                	mv	s5,a0
  uint64 oldsz = p->sz;
    800050c0:	04853c83          	ld	s9,72(a0)
  sz = PGROUNDUP(sz);
    800050c4:	6985                	lui	s3,0x1
    800050c6:	19fd                	addi	s3,s3,-1 # fff <_entry-0x7ffff001>
    800050c8:	99ca                	add	s3,s3,s2
    800050ca:	77fd                	lui	a5,0xfffff
    800050cc:	00f9f9b3          	and	s3,s3,a5
  if((sz1 = uvmalloc(pagetable, sz, sz + (USERSTACK+1)*PGSIZE, PTE_W)) == 0)
    800050d0:	4691                	li	a3,4
    800050d2:	6609                	lui	a2,0x2
    800050d4:	964e                	add	a2,a2,s3
    800050d6:	85ce                	mv	a1,s3
    800050d8:	855a                	mv	a0,s6
    800050da:	be0fc0ef          	jal	800014ba <uvmalloc>
    800050de:	892a                	mv	s2,a0
    800050e0:	e0a43423          	sd	a0,-504(s0)
    800050e4:	e519                	bnez	a0,800050f2 <kexec+0x1e0>
  if(pagetable)
    800050e6:	e1343423          	sd	s3,-504(s0)
    800050ea:	4a01                	li	s4,0
    800050ec:	aab1                	j	80005248 <kexec+0x336>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    800050ee:	4901                	li	s2,0
    800050f0:	b7c1                	j	800050b0 <kexec+0x19e>
  uvmclear(pagetable, sz-(USERSTACK+1)*PGSIZE);
    800050f2:	75f9                	lui	a1,0xffffe
    800050f4:	95aa                	add	a1,a1,a0
    800050f6:	855a                	mv	a0,s6
    800050f8:	e14fc0ef          	jal	8000170c <uvmclear>
  stackbase = sp - USERSTACK*PGSIZE;
    800050fc:	7bfd                	lui	s7,0xfffff
    800050fe:	9bca                	add	s7,s7,s2
  for(argc = 0; argv[argc]; argc++) {
    80005100:	e0043783          	ld	a5,-512(s0)
    80005104:	6388                	ld	a0,0(a5)
    80005106:	cd39                	beqz	a0,80005164 <kexec+0x252>
    80005108:	e9040993          	addi	s3,s0,-368
    8000510c:	f9040c13          	addi	s8,s0,-112
    80005110:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    80005112:	deffb0ef          	jal	80000f00 <strlen>
    80005116:	0015079b          	addiw	a5,a0,1
    8000511a:	40f907b3          	sub	a5,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    8000511e:	ff07f913          	andi	s2,a5,-16
    if(sp < stackbase)
    80005122:	11796e63          	bltu	s2,s7,8000523e <kexec+0x32c>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80005126:	e0043d03          	ld	s10,-512(s0)
    8000512a:	000d3a03          	ld	s4,0(s10)
    8000512e:	8552                	mv	a0,s4
    80005130:	dd1fb0ef          	jal	80000f00 <strlen>
    80005134:	0015069b          	addiw	a3,a0,1
    80005138:	8652                	mv	a2,s4
    8000513a:	85ca                	mv	a1,s2
    8000513c:	855a                	mv	a0,s6
    8000513e:	fb0fc0ef          	jal	800018ee <copyout>
    80005142:	10054063          	bltz	a0,80005242 <kexec+0x330>
    ustack[argc] = sp;
    80005146:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    8000514a:	0485                	addi	s1,s1,1
    8000514c:	008d0793          	addi	a5,s10,8
    80005150:	e0f43023          	sd	a5,-512(s0)
    80005154:	008d3503          	ld	a0,8(s10)
    80005158:	c909                	beqz	a0,8000516a <kexec+0x258>
    if(argc >= MAXARG)
    8000515a:	09a1                	addi	s3,s3,8
    8000515c:	fb899be3          	bne	s3,s8,80005112 <kexec+0x200>
  ip = 0;
    80005160:	4a01                	li	s4,0
    80005162:	a0dd                	j	80005248 <kexec+0x336>
  sp = sz;
    80005164:	e0843903          	ld	s2,-504(s0)
  for(argc = 0; argv[argc]; argc++) {
    80005168:	4481                	li	s1,0
  ustack[argc] = 0;
    8000516a:	00349793          	slli	a5,s1,0x3
    8000516e:	f9078793          	addi	a5,a5,-112 # ffffffffffffef90 <end+0xffffffff7ffb80b0>
    80005172:	97a2                	add	a5,a5,s0
    80005174:	f007b023          	sd	zero,-256(a5)
  sp -= (argc+1) * sizeof(uint64);
    80005178:	00148693          	addi	a3,s1,1
    8000517c:	068e                	slli	a3,a3,0x3
    8000517e:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    80005182:	ff097913          	andi	s2,s2,-16
  sz = sz1;
    80005186:	e0843983          	ld	s3,-504(s0)
  if(sp < stackbase)
    8000518a:	f5796ee3          	bltu	s2,s7,800050e6 <kexec+0x1d4>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    8000518e:	e9040613          	addi	a2,s0,-368
    80005192:	85ca                	mv	a1,s2
    80005194:	855a                	mv	a0,s6
    80005196:	f58fc0ef          	jal	800018ee <copyout>
    8000519a:	0e054263          	bltz	a0,8000527e <kexec+0x36c>
  p->trapframe->a1 = sp;
    8000519e:	058ab783          	ld	a5,88(s5) # 1058 <_entry-0x7fffefa8>
    800051a2:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    800051a6:	df843783          	ld	a5,-520(s0)
    800051aa:	0007c703          	lbu	a4,0(a5)
    800051ae:	cf11                	beqz	a4,800051ca <kexec+0x2b8>
    800051b0:	0785                	addi	a5,a5,1
    if(*s == '/')
    800051b2:	02f00693          	li	a3,47
    800051b6:	a039                	j	800051c4 <kexec+0x2b2>
      last = s+1;
    800051b8:	def43c23          	sd	a5,-520(s0)
  for(last=s=path; *s; s++)
    800051bc:	0785                	addi	a5,a5,1
    800051be:	fff7c703          	lbu	a4,-1(a5)
    800051c2:	c701                	beqz	a4,800051ca <kexec+0x2b8>
    if(*s == '/')
    800051c4:	fed71ce3          	bne	a4,a3,800051bc <kexec+0x2aa>
    800051c8:	bfc5                	j	800051b8 <kexec+0x2a6>
  safestrcpy(p->name, last, sizeof(p->name));
    800051ca:	4641                	li	a2,16
    800051cc:	df843583          	ld	a1,-520(s0)
    800051d0:	158a8513          	addi	a0,s5,344
    800051d4:	cfbfb0ef          	jal	80000ece <safestrcpy>
  oldpagetable = p->pagetable;
    800051d8:	050ab503          	ld	a0,80(s5)
  p->pagetable = pagetable;
    800051dc:	056ab823          	sd	s6,80(s5)
  p->sz = sz;
    800051e0:	e0843783          	ld	a5,-504(s0)
    800051e4:	04fab423          	sd	a5,72(s5)
  p->trapframe->epc = elf.entry;  // initial program counter = ulib.c:start()
    800051e8:	058ab783          	ld	a5,88(s5)
    800051ec:	e6843703          	ld	a4,-408(s0)
    800051f0:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    800051f2:	058ab783          	ld	a5,88(s5)
    800051f6:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    800051fa:	85e6                	mv	a1,s9
    800051fc:	bf9fc0ef          	jal	80001df4 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80005200:	0004851b          	sext.w	a0,s1
    80005204:	79be                	ld	s3,488(sp)
    80005206:	7a1e                	ld	s4,480(sp)
    80005208:	6afe                	ld	s5,472(sp)
    8000520a:	6b5e                	ld	s6,464(sp)
    8000520c:	6bbe                	ld	s7,456(sp)
    8000520e:	6c1e                	ld	s8,448(sp)
    80005210:	7cfa                	ld	s9,440(sp)
    80005212:	7d5a                	ld	s10,432(sp)
    80005214:	b3b5                	j	80004f80 <kexec+0x6e>
    80005216:	e1243423          	sd	s2,-504(s0)
    8000521a:	7dba                	ld	s11,424(sp)
    8000521c:	a035                	j	80005248 <kexec+0x336>
    8000521e:	e1243423          	sd	s2,-504(s0)
    80005222:	7dba                	ld	s11,424(sp)
    80005224:	a015                	j	80005248 <kexec+0x336>
    80005226:	e1243423          	sd	s2,-504(s0)
    8000522a:	7dba                	ld	s11,424(sp)
    8000522c:	a831                	j	80005248 <kexec+0x336>
    8000522e:	e1243423          	sd	s2,-504(s0)
    80005232:	7dba                	ld	s11,424(sp)
    80005234:	a811                	j	80005248 <kexec+0x336>
    80005236:	e1243423          	sd	s2,-504(s0)
    8000523a:	7dba                	ld	s11,424(sp)
    8000523c:	a031                	j	80005248 <kexec+0x336>
  ip = 0;
    8000523e:	4a01                	li	s4,0
    80005240:	a021                	j	80005248 <kexec+0x336>
    80005242:	4a01                	li	s4,0
  if(pagetable)
    80005244:	a011                	j	80005248 <kexec+0x336>
    80005246:	7dba                	ld	s11,424(sp)
    proc_freepagetable(pagetable, sz);
    80005248:	e0843583          	ld	a1,-504(s0)
    8000524c:	855a                	mv	a0,s6
    8000524e:	ba7fc0ef          	jal	80001df4 <proc_freepagetable>
  return -1;
    80005252:	557d                	li	a0,-1
  if(ip){
    80005254:	000a1b63          	bnez	s4,8000526a <kexec+0x358>
    80005258:	79be                	ld	s3,488(sp)
    8000525a:	7a1e                	ld	s4,480(sp)
    8000525c:	6afe                	ld	s5,472(sp)
    8000525e:	6b5e                	ld	s6,464(sp)
    80005260:	6bbe                	ld	s7,456(sp)
    80005262:	6c1e                	ld	s8,448(sp)
    80005264:	7cfa                	ld	s9,440(sp)
    80005266:	7d5a                	ld	s10,432(sp)
    80005268:	bb21                	j	80004f80 <kexec+0x6e>
    8000526a:	79be                	ld	s3,488(sp)
    8000526c:	6afe                	ld	s5,472(sp)
    8000526e:	6b5e                	ld	s6,464(sp)
    80005270:	6bbe                	ld	s7,456(sp)
    80005272:	6c1e                	ld	s8,448(sp)
    80005274:	7cfa                	ld	s9,440(sp)
    80005276:	7d5a                	ld	s10,432(sp)
    80005278:	b9ed                	j	80004f72 <kexec+0x60>
    8000527a:	6b5e                	ld	s6,464(sp)
    8000527c:	b9dd                	j	80004f72 <kexec+0x60>
  sz = sz1;
    8000527e:	e0843983          	ld	s3,-504(s0)
    80005282:	b595                	j	800050e6 <kexec+0x1d4>

0000000080005284 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80005284:	7179                	addi	sp,sp,-48
    80005286:	f406                	sd	ra,40(sp)
    80005288:	f022                	sd	s0,32(sp)
    8000528a:	ec26                	sd	s1,24(sp)
    8000528c:	e84a                	sd	s2,16(sp)
    8000528e:	1800                	addi	s0,sp,48
    80005290:	892e                	mv	s2,a1
    80005292:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    80005294:	fdc40593          	addi	a1,s0,-36
    80005298:	bbdfd0ef          	jal	80002e54 <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    8000529c:	fdc42703          	lw	a4,-36(s0)
    800052a0:	47bd                	li	a5,15
    800052a2:	02e7e963          	bltu	a5,a4,800052d4 <argfd+0x50>
    800052a6:	9bffc0ef          	jal	80001c64 <myproc>
    800052aa:	fdc42703          	lw	a4,-36(s0)
    800052ae:	01a70793          	addi	a5,a4,26
    800052b2:	078e                	slli	a5,a5,0x3
    800052b4:	953e                	add	a0,a0,a5
    800052b6:	611c                	ld	a5,0(a0)
    800052b8:	c385                	beqz	a5,800052d8 <argfd+0x54>
    return -1;
  if(pfd)
    800052ba:	00090463          	beqz	s2,800052c2 <argfd+0x3e>
    *pfd = fd;
    800052be:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    800052c2:	4501                	li	a0,0
  if(pf)
    800052c4:	c091                	beqz	s1,800052c8 <argfd+0x44>
    *pf = f;
    800052c6:	e09c                	sd	a5,0(s1)
}
    800052c8:	70a2                	ld	ra,40(sp)
    800052ca:	7402                	ld	s0,32(sp)
    800052cc:	64e2                	ld	s1,24(sp)
    800052ce:	6942                	ld	s2,16(sp)
    800052d0:	6145                	addi	sp,sp,48
    800052d2:	8082                	ret
    return -1;
    800052d4:	557d                	li	a0,-1
    800052d6:	bfcd                	j	800052c8 <argfd+0x44>
    800052d8:	557d                	li	a0,-1
    800052da:	b7fd                	j	800052c8 <argfd+0x44>

00000000800052dc <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    800052dc:	1101                	addi	sp,sp,-32
    800052de:	ec06                	sd	ra,24(sp)
    800052e0:	e822                	sd	s0,16(sp)
    800052e2:	e426                	sd	s1,8(sp)
    800052e4:	1000                	addi	s0,sp,32
    800052e6:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    800052e8:	97dfc0ef          	jal	80001c64 <myproc>
    800052ec:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    800052ee:	0d050793          	addi	a5,a0,208
    800052f2:	4501                	li	a0,0
    800052f4:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    800052f6:	6398                	ld	a4,0(a5)
    800052f8:	cb19                	beqz	a4,8000530e <fdalloc+0x32>
  for(fd = 0; fd < NOFILE; fd++){
    800052fa:	2505                	addiw	a0,a0,1
    800052fc:	07a1                	addi	a5,a5,8
    800052fe:	fed51ce3          	bne	a0,a3,800052f6 <fdalloc+0x1a>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80005302:	557d                	li	a0,-1
}
    80005304:	60e2                	ld	ra,24(sp)
    80005306:	6442                	ld	s0,16(sp)
    80005308:	64a2                	ld	s1,8(sp)
    8000530a:	6105                	addi	sp,sp,32
    8000530c:	8082                	ret
      p->ofile[fd] = f;
    8000530e:	01a50793          	addi	a5,a0,26
    80005312:	078e                	slli	a5,a5,0x3
    80005314:	963e                	add	a2,a2,a5
    80005316:	e204                	sd	s1,0(a2)
      return fd;
    80005318:	b7f5                	j	80005304 <fdalloc+0x28>

000000008000531a <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    8000531a:	715d                	addi	sp,sp,-80
    8000531c:	e486                	sd	ra,72(sp)
    8000531e:	e0a2                	sd	s0,64(sp)
    80005320:	fc26                	sd	s1,56(sp)
    80005322:	f84a                	sd	s2,48(sp)
    80005324:	f44e                	sd	s3,40(sp)
    80005326:	ec56                	sd	s5,24(sp)
    80005328:	e85a                	sd	s6,16(sp)
    8000532a:	0880                	addi	s0,sp,80
    8000532c:	8b2e                	mv	s6,a1
    8000532e:	89b2                	mv	s3,a2
    80005330:	8936                	mv	s2,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    80005332:	fb040593          	addi	a1,s0,-80
    80005336:	80eff0ef          	jal	80004344 <nameiparent>
    8000533a:	84aa                	mv	s1,a0
    8000533c:	10050a63          	beqz	a0,80005450 <create+0x136>
    return 0;

  ilock(dp);
    80005340:	fd4fe0ef          	jal	80003b14 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    80005344:	4601                	li	a2,0
    80005346:	fb040593          	addi	a1,s0,-80
    8000534a:	8526                	mv	a0,s1
    8000534c:	d79fe0ef          	jal	800040c4 <dirlookup>
    80005350:	8aaa                	mv	s5,a0
    80005352:	c129                	beqz	a0,80005394 <create+0x7a>
    iunlockput(dp);
    80005354:	8526                	mv	a0,s1
    80005356:	9c9fe0ef          	jal	80003d1e <iunlockput>
    ilock(ip);
    8000535a:	8556                	mv	a0,s5
    8000535c:	fb8fe0ef          	jal	80003b14 <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80005360:	4789                	li	a5,2
    80005362:	02fb1463          	bne	s6,a5,8000538a <create+0x70>
    80005366:	044ad783          	lhu	a5,68(s5)
    8000536a:	37f9                	addiw	a5,a5,-2
    8000536c:	17c2                	slli	a5,a5,0x30
    8000536e:	93c1                	srli	a5,a5,0x30
    80005370:	4705                	li	a4,1
    80005372:	00f76c63          	bltu	a4,a5,8000538a <create+0x70>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    80005376:	8556                	mv	a0,s5
    80005378:	60a6                	ld	ra,72(sp)
    8000537a:	6406                	ld	s0,64(sp)
    8000537c:	74e2                	ld	s1,56(sp)
    8000537e:	7942                	ld	s2,48(sp)
    80005380:	79a2                	ld	s3,40(sp)
    80005382:	6ae2                	ld	s5,24(sp)
    80005384:	6b42                	ld	s6,16(sp)
    80005386:	6161                	addi	sp,sp,80
    80005388:	8082                	ret
    iunlockput(ip);
    8000538a:	8556                	mv	a0,s5
    8000538c:	993fe0ef          	jal	80003d1e <iunlockput>
    return 0;
    80005390:	4a81                	li	s5,0
    80005392:	b7d5                	j	80005376 <create+0x5c>
    80005394:	f052                	sd	s4,32(sp)
  if((ip = ialloc(dp->dev, type)) == 0){
    80005396:	85da                	mv	a1,s6
    80005398:	4088                	lw	a0,0(s1)
    8000539a:	e0afe0ef          	jal	800039a4 <ialloc>
    8000539e:	8a2a                	mv	s4,a0
    800053a0:	cd15                	beqz	a0,800053dc <create+0xc2>
  ilock(ip);
    800053a2:	f72fe0ef          	jal	80003b14 <ilock>
  ip->major = major;
    800053a6:	053a1323          	sh	s3,70(s4)
  ip->minor = minor;
    800053aa:	052a1423          	sh	s2,72(s4)
  ip->nlink = 1;
    800053ae:	4905                	li	s2,1
    800053b0:	052a1523          	sh	s2,74(s4)
  iupdate(ip);
    800053b4:	8552                	mv	a0,s4
    800053b6:	eaafe0ef          	jal	80003a60 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    800053ba:	032b0763          	beq	s6,s2,800053e8 <create+0xce>
  if(dirlink(dp, name, ip->inum) < 0)
    800053be:	004a2603          	lw	a2,4(s4)
    800053c2:	fb040593          	addi	a1,s0,-80
    800053c6:	8526                	mv	a0,s1
    800053c8:	ec9fe0ef          	jal	80004290 <dirlink>
    800053cc:	06054563          	bltz	a0,80005436 <create+0x11c>
  iunlockput(dp);
    800053d0:	8526                	mv	a0,s1
    800053d2:	94dfe0ef          	jal	80003d1e <iunlockput>
  return ip;
    800053d6:	8ad2                	mv	s5,s4
    800053d8:	7a02                	ld	s4,32(sp)
    800053da:	bf71                	j	80005376 <create+0x5c>
    iunlockput(dp);
    800053dc:	8526                	mv	a0,s1
    800053de:	941fe0ef          	jal	80003d1e <iunlockput>
    return 0;
    800053e2:	8ad2                	mv	s5,s4
    800053e4:	7a02                	ld	s4,32(sp)
    800053e6:	bf41                	j	80005376 <create+0x5c>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    800053e8:	004a2603          	lw	a2,4(s4)
    800053ec:	00003597          	auipc	a1,0x3
    800053f0:	21c58593          	addi	a1,a1,540 # 80008608 <etext+0x608>
    800053f4:	8552                	mv	a0,s4
    800053f6:	e9bfe0ef          	jal	80004290 <dirlink>
    800053fa:	02054e63          	bltz	a0,80005436 <create+0x11c>
    800053fe:	40d0                	lw	a2,4(s1)
    80005400:	00003597          	auipc	a1,0x3
    80005404:	21058593          	addi	a1,a1,528 # 80008610 <etext+0x610>
    80005408:	8552                	mv	a0,s4
    8000540a:	e87fe0ef          	jal	80004290 <dirlink>
    8000540e:	02054463          	bltz	a0,80005436 <create+0x11c>
  if(dirlink(dp, name, ip->inum) < 0)
    80005412:	004a2603          	lw	a2,4(s4)
    80005416:	fb040593          	addi	a1,s0,-80
    8000541a:	8526                	mv	a0,s1
    8000541c:	e75fe0ef          	jal	80004290 <dirlink>
    80005420:	00054b63          	bltz	a0,80005436 <create+0x11c>
    dp->nlink++;  // for ".."
    80005424:	04a4d783          	lhu	a5,74(s1)
    80005428:	2785                	addiw	a5,a5,1
    8000542a:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    8000542e:	8526                	mv	a0,s1
    80005430:	e30fe0ef          	jal	80003a60 <iupdate>
    80005434:	bf71                	j	800053d0 <create+0xb6>
  ip->nlink = 0;
    80005436:	040a1523          	sh	zero,74(s4)
  iupdate(ip);
    8000543a:	8552                	mv	a0,s4
    8000543c:	e24fe0ef          	jal	80003a60 <iupdate>
  iunlockput(ip);
    80005440:	8552                	mv	a0,s4
    80005442:	8ddfe0ef          	jal	80003d1e <iunlockput>
  iunlockput(dp);
    80005446:	8526                	mv	a0,s1
    80005448:	8d7fe0ef          	jal	80003d1e <iunlockput>
  return 0;
    8000544c:	7a02                	ld	s4,32(sp)
    8000544e:	b725                	j	80005376 <create+0x5c>
    return 0;
    80005450:	8aaa                	mv	s5,a0
    80005452:	b715                	j	80005376 <create+0x5c>

0000000080005454 <sys_dup>:
{
    80005454:	7179                	addi	sp,sp,-48
    80005456:	f406                	sd	ra,40(sp)
    80005458:	f022                	sd	s0,32(sp)
    8000545a:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    8000545c:	fd840613          	addi	a2,s0,-40
    80005460:	4581                	li	a1,0
    80005462:	4501                	li	a0,0
    80005464:	e21ff0ef          	jal	80005284 <argfd>
    return -1;
    80005468:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    8000546a:	02054363          	bltz	a0,80005490 <sys_dup+0x3c>
    8000546e:	ec26                	sd	s1,24(sp)
    80005470:	e84a                	sd	s2,16(sp)
  if((fd=fdalloc(f)) < 0)
    80005472:	fd843903          	ld	s2,-40(s0)
    80005476:	854a                	mv	a0,s2
    80005478:	e65ff0ef          	jal	800052dc <fdalloc>
    8000547c:	84aa                	mv	s1,a0
    return -1;
    8000547e:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    80005480:	00054d63          	bltz	a0,8000549a <sys_dup+0x46>
  filedup(f);
    80005484:	854a                	mv	a0,s2
    80005486:	c3eff0ef          	jal	800048c4 <filedup>
  return fd;
    8000548a:	87a6                	mv	a5,s1
    8000548c:	64e2                	ld	s1,24(sp)
    8000548e:	6942                	ld	s2,16(sp)
}
    80005490:	853e                	mv	a0,a5
    80005492:	70a2                	ld	ra,40(sp)
    80005494:	7402                	ld	s0,32(sp)
    80005496:	6145                	addi	sp,sp,48
    80005498:	8082                	ret
    8000549a:	64e2                	ld	s1,24(sp)
    8000549c:	6942                	ld	s2,16(sp)
    8000549e:	bfcd                	j	80005490 <sys_dup+0x3c>

00000000800054a0 <sys_read>:
{
    800054a0:	7179                	addi	sp,sp,-48
    800054a2:	f406                	sd	ra,40(sp)
    800054a4:	f022                	sd	s0,32(sp)
    800054a6:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    800054a8:	fd840593          	addi	a1,s0,-40
    800054ac:	4505                	li	a0,1
    800054ae:	9c3fd0ef          	jal	80002e70 <argaddr>
  argint(2, &n);
    800054b2:	fe440593          	addi	a1,s0,-28
    800054b6:	4509                	li	a0,2
    800054b8:	99dfd0ef          	jal	80002e54 <argint>
  if(argfd(0, 0, &f) < 0)
    800054bc:	fe840613          	addi	a2,s0,-24
    800054c0:	4581                	li	a1,0
    800054c2:	4501                	li	a0,0
    800054c4:	dc1ff0ef          	jal	80005284 <argfd>
    800054c8:	87aa                	mv	a5,a0
    return -1;
    800054ca:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    800054cc:	0007ca63          	bltz	a5,800054e0 <sys_read+0x40>
  return fileread(f, p, n);
    800054d0:	fe442603          	lw	a2,-28(s0)
    800054d4:	fd843583          	ld	a1,-40(s0)
    800054d8:	fe843503          	ld	a0,-24(s0)
    800054dc:	d4eff0ef          	jal	80004a2a <fileread>
}
    800054e0:	70a2                	ld	ra,40(sp)
    800054e2:	7402                	ld	s0,32(sp)
    800054e4:	6145                	addi	sp,sp,48
    800054e6:	8082                	ret

00000000800054e8 <sys_write>:
{
    800054e8:	7179                	addi	sp,sp,-48
    800054ea:	f406                	sd	ra,40(sp)
    800054ec:	f022                	sd	s0,32(sp)
    800054ee:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    800054f0:	fd840593          	addi	a1,s0,-40
    800054f4:	4505                	li	a0,1
    800054f6:	97bfd0ef          	jal	80002e70 <argaddr>
  argint(2, &n);
    800054fa:	fe440593          	addi	a1,s0,-28
    800054fe:	4509                	li	a0,2
    80005500:	955fd0ef          	jal	80002e54 <argint>
  if(argfd(0, 0, &f) < 0)
    80005504:	fe840613          	addi	a2,s0,-24
    80005508:	4581                	li	a1,0
    8000550a:	4501                	li	a0,0
    8000550c:	d79ff0ef          	jal	80005284 <argfd>
    80005510:	87aa                	mv	a5,a0
    return -1;
    80005512:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80005514:	0007ca63          	bltz	a5,80005528 <sys_write+0x40>
  return filewrite(f, p, n);
    80005518:	fe442603          	lw	a2,-28(s0)
    8000551c:	fd843583          	ld	a1,-40(s0)
    80005520:	fe843503          	ld	a0,-24(s0)
    80005524:	dc4ff0ef          	jal	80004ae8 <filewrite>
}
    80005528:	70a2                	ld	ra,40(sp)
    8000552a:	7402                	ld	s0,32(sp)
    8000552c:	6145                	addi	sp,sp,48
    8000552e:	8082                	ret

0000000080005530 <sys_close>:
{
    80005530:	1101                	addi	sp,sp,-32
    80005532:	ec06                	sd	ra,24(sp)
    80005534:	e822                	sd	s0,16(sp)
    80005536:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    80005538:	fe040613          	addi	a2,s0,-32
    8000553c:	fec40593          	addi	a1,s0,-20
    80005540:	4501                	li	a0,0
    80005542:	d43ff0ef          	jal	80005284 <argfd>
    return -1;
    80005546:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    80005548:	02054063          	bltz	a0,80005568 <sys_close+0x38>
  myproc()->ofile[fd] = 0;
    8000554c:	f18fc0ef          	jal	80001c64 <myproc>
    80005550:	fec42783          	lw	a5,-20(s0)
    80005554:	07e9                	addi	a5,a5,26
    80005556:	078e                	slli	a5,a5,0x3
    80005558:	953e                	add	a0,a0,a5
    8000555a:	00053023          	sd	zero,0(a0)
  fileclose(f);
    8000555e:	fe043503          	ld	a0,-32(s0)
    80005562:	ba8ff0ef          	jal	8000490a <fileclose>
  return 0;
    80005566:	4781                	li	a5,0
}
    80005568:	853e                	mv	a0,a5
    8000556a:	60e2                	ld	ra,24(sp)
    8000556c:	6442                	ld	s0,16(sp)
    8000556e:	6105                	addi	sp,sp,32
    80005570:	8082                	ret

0000000080005572 <sys_fstat>:
{
    80005572:	1101                	addi	sp,sp,-32
    80005574:	ec06                	sd	ra,24(sp)
    80005576:	e822                	sd	s0,16(sp)
    80005578:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    8000557a:	fe040593          	addi	a1,s0,-32
    8000557e:	4505                	li	a0,1
    80005580:	8f1fd0ef          	jal	80002e70 <argaddr>
  if(argfd(0, 0, &f) < 0)
    80005584:	fe840613          	addi	a2,s0,-24
    80005588:	4581                	li	a1,0
    8000558a:	4501                	li	a0,0
    8000558c:	cf9ff0ef          	jal	80005284 <argfd>
    80005590:	87aa                	mv	a5,a0
    return -1;
    80005592:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80005594:	0007c863          	bltz	a5,800055a4 <sys_fstat+0x32>
  return filestat(f, st);
    80005598:	fe043583          	ld	a1,-32(s0)
    8000559c:	fe843503          	ld	a0,-24(s0)
    800055a0:	c2cff0ef          	jal	800049cc <filestat>
}
    800055a4:	60e2                	ld	ra,24(sp)
    800055a6:	6442                	ld	s0,16(sp)
    800055a8:	6105                	addi	sp,sp,32
    800055aa:	8082                	ret

00000000800055ac <sys_link>:
{
    800055ac:	7169                	addi	sp,sp,-304
    800055ae:	f606                	sd	ra,296(sp)
    800055b0:	f222                	sd	s0,288(sp)
    800055b2:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800055b4:	08000613          	li	a2,128
    800055b8:	ed040593          	addi	a1,s0,-304
    800055bc:	4501                	li	a0,0
    800055be:	8cffd0ef          	jal	80002e8c <argstr>
    return -1;
    800055c2:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800055c4:	0c054e63          	bltz	a0,800056a0 <sys_link+0xf4>
    800055c8:	08000613          	li	a2,128
    800055cc:	f5040593          	addi	a1,s0,-176
    800055d0:	4505                	li	a0,1
    800055d2:	8bbfd0ef          	jal	80002e8c <argstr>
    return -1;
    800055d6:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800055d8:	0c054463          	bltz	a0,800056a0 <sys_link+0xf4>
    800055dc:	ee26                	sd	s1,280(sp)
  begin_op();
    800055de:	f21fe0ef          	jal	800044fe <begin_op>
  if((ip = namei(old)) == 0){
    800055e2:	ed040513          	addi	a0,s0,-304
    800055e6:	d45fe0ef          	jal	8000432a <namei>
    800055ea:	84aa                	mv	s1,a0
    800055ec:	c53d                	beqz	a0,8000565a <sys_link+0xae>
  ilock(ip);
    800055ee:	d26fe0ef          	jal	80003b14 <ilock>
  if(ip->type == T_DIR){
    800055f2:	04449703          	lh	a4,68(s1)
    800055f6:	4785                	li	a5,1
    800055f8:	06f70663          	beq	a4,a5,80005664 <sys_link+0xb8>
    800055fc:	ea4a                	sd	s2,272(sp)
  ip->nlink++;
    800055fe:	04a4d783          	lhu	a5,74(s1)
    80005602:	2785                	addiw	a5,a5,1
    80005604:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005608:	8526                	mv	a0,s1
    8000560a:	c56fe0ef          	jal	80003a60 <iupdate>
  iunlock(ip);
    8000560e:	8526                	mv	a0,s1
    80005610:	db2fe0ef          	jal	80003bc2 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    80005614:	fd040593          	addi	a1,s0,-48
    80005618:	f5040513          	addi	a0,s0,-176
    8000561c:	d29fe0ef          	jal	80004344 <nameiparent>
    80005620:	892a                	mv	s2,a0
    80005622:	cd21                	beqz	a0,8000567a <sys_link+0xce>
  ilock(dp);
    80005624:	cf0fe0ef          	jal	80003b14 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    80005628:	00092703          	lw	a4,0(s2)
    8000562c:	409c                	lw	a5,0(s1)
    8000562e:	04f71363          	bne	a4,a5,80005674 <sys_link+0xc8>
    80005632:	40d0                	lw	a2,4(s1)
    80005634:	fd040593          	addi	a1,s0,-48
    80005638:	854a                	mv	a0,s2
    8000563a:	c57fe0ef          	jal	80004290 <dirlink>
    8000563e:	02054b63          	bltz	a0,80005674 <sys_link+0xc8>
  iunlockput(dp);
    80005642:	854a                	mv	a0,s2
    80005644:	edafe0ef          	jal	80003d1e <iunlockput>
  iput(ip);
    80005648:	8526                	mv	a0,s1
    8000564a:	e4cfe0ef          	jal	80003c96 <iput>
  end_op();
    8000564e:	f1bfe0ef          	jal	80004568 <end_op>
  return 0;
    80005652:	4781                	li	a5,0
    80005654:	64f2                	ld	s1,280(sp)
    80005656:	6952                	ld	s2,272(sp)
    80005658:	a0a1                	j	800056a0 <sys_link+0xf4>
    end_op();
    8000565a:	f0ffe0ef          	jal	80004568 <end_op>
    return -1;
    8000565e:	57fd                	li	a5,-1
    80005660:	64f2                	ld	s1,280(sp)
    80005662:	a83d                	j	800056a0 <sys_link+0xf4>
    iunlockput(ip);
    80005664:	8526                	mv	a0,s1
    80005666:	eb8fe0ef          	jal	80003d1e <iunlockput>
    end_op();
    8000566a:	efffe0ef          	jal	80004568 <end_op>
    return -1;
    8000566e:	57fd                	li	a5,-1
    80005670:	64f2                	ld	s1,280(sp)
    80005672:	a03d                	j	800056a0 <sys_link+0xf4>
    iunlockput(dp);
    80005674:	854a                	mv	a0,s2
    80005676:	ea8fe0ef          	jal	80003d1e <iunlockput>
  ilock(ip);
    8000567a:	8526                	mv	a0,s1
    8000567c:	c98fe0ef          	jal	80003b14 <ilock>
  ip->nlink--;
    80005680:	04a4d783          	lhu	a5,74(s1)
    80005684:	37fd                	addiw	a5,a5,-1
    80005686:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    8000568a:	8526                	mv	a0,s1
    8000568c:	bd4fe0ef          	jal	80003a60 <iupdate>
  iunlockput(ip);
    80005690:	8526                	mv	a0,s1
    80005692:	e8cfe0ef          	jal	80003d1e <iunlockput>
  end_op();
    80005696:	ed3fe0ef          	jal	80004568 <end_op>
  return -1;
    8000569a:	57fd                	li	a5,-1
    8000569c:	64f2                	ld	s1,280(sp)
    8000569e:	6952                	ld	s2,272(sp)
}
    800056a0:	853e                	mv	a0,a5
    800056a2:	70b2                	ld	ra,296(sp)
    800056a4:	7412                	ld	s0,288(sp)
    800056a6:	6155                	addi	sp,sp,304
    800056a8:	8082                	ret

00000000800056aa <sys_unlink>:
{
    800056aa:	7151                	addi	sp,sp,-240
    800056ac:	f586                	sd	ra,232(sp)
    800056ae:	f1a2                	sd	s0,224(sp)
    800056b0:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    800056b2:	08000613          	li	a2,128
    800056b6:	f3040593          	addi	a1,s0,-208
    800056ba:	4501                	li	a0,0
    800056bc:	fd0fd0ef          	jal	80002e8c <argstr>
    800056c0:	16054063          	bltz	a0,80005820 <sys_unlink+0x176>
    800056c4:	eda6                	sd	s1,216(sp)
  begin_op();
    800056c6:	e39fe0ef          	jal	800044fe <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    800056ca:	fb040593          	addi	a1,s0,-80
    800056ce:	f3040513          	addi	a0,s0,-208
    800056d2:	c73fe0ef          	jal	80004344 <nameiparent>
    800056d6:	84aa                	mv	s1,a0
    800056d8:	c945                	beqz	a0,80005788 <sys_unlink+0xde>
  ilock(dp);
    800056da:	c3afe0ef          	jal	80003b14 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    800056de:	00003597          	auipc	a1,0x3
    800056e2:	f2a58593          	addi	a1,a1,-214 # 80008608 <etext+0x608>
    800056e6:	fb040513          	addi	a0,s0,-80
    800056ea:	9c5fe0ef          	jal	800040ae <namecmp>
    800056ee:	10050e63          	beqz	a0,8000580a <sys_unlink+0x160>
    800056f2:	00003597          	auipc	a1,0x3
    800056f6:	f1e58593          	addi	a1,a1,-226 # 80008610 <etext+0x610>
    800056fa:	fb040513          	addi	a0,s0,-80
    800056fe:	9b1fe0ef          	jal	800040ae <namecmp>
    80005702:	10050463          	beqz	a0,8000580a <sys_unlink+0x160>
    80005706:	e9ca                	sd	s2,208(sp)
  if((ip = dirlookup(dp, name, &off)) == 0)
    80005708:	f2c40613          	addi	a2,s0,-212
    8000570c:	fb040593          	addi	a1,s0,-80
    80005710:	8526                	mv	a0,s1
    80005712:	9b3fe0ef          	jal	800040c4 <dirlookup>
    80005716:	892a                	mv	s2,a0
    80005718:	0e050863          	beqz	a0,80005808 <sys_unlink+0x15e>
  ilock(ip);
    8000571c:	bf8fe0ef          	jal	80003b14 <ilock>
  if(ip->nlink < 1)
    80005720:	04a91783          	lh	a5,74(s2)
    80005724:	06f05763          	blez	a5,80005792 <sys_unlink+0xe8>
  if(ip->type == T_DIR && !isdirempty(ip)){
    80005728:	04491703          	lh	a4,68(s2)
    8000572c:	4785                	li	a5,1
    8000572e:	06f70963          	beq	a4,a5,800057a0 <sys_unlink+0xf6>
  memset(&de, 0, sizeof(de));
    80005732:	4641                	li	a2,16
    80005734:	4581                	li	a1,0
    80005736:	fc040513          	addi	a0,s0,-64
    8000573a:	e56fb0ef          	jal	80000d90 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000573e:	4741                	li	a4,16
    80005740:	f2c42683          	lw	a3,-212(s0)
    80005744:	fc040613          	addi	a2,s0,-64
    80005748:	4581                	li	a1,0
    8000574a:	8526                	mv	a0,s1
    8000574c:	855fe0ef          	jal	80003fa0 <writei>
    80005750:	47c1                	li	a5,16
    80005752:	08f51b63          	bne	a0,a5,800057e8 <sys_unlink+0x13e>
  if(ip->type == T_DIR){
    80005756:	04491703          	lh	a4,68(s2)
    8000575a:	4785                	li	a5,1
    8000575c:	08f70d63          	beq	a4,a5,800057f6 <sys_unlink+0x14c>
  iunlockput(dp);
    80005760:	8526                	mv	a0,s1
    80005762:	dbcfe0ef          	jal	80003d1e <iunlockput>
  ip->nlink--;
    80005766:	04a95783          	lhu	a5,74(s2)
    8000576a:	37fd                	addiw	a5,a5,-1
    8000576c:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80005770:	854a                	mv	a0,s2
    80005772:	aeefe0ef          	jal	80003a60 <iupdate>
  iunlockput(ip);
    80005776:	854a                	mv	a0,s2
    80005778:	da6fe0ef          	jal	80003d1e <iunlockput>
  end_op();
    8000577c:	dedfe0ef          	jal	80004568 <end_op>
  return 0;
    80005780:	4501                	li	a0,0
    80005782:	64ee                	ld	s1,216(sp)
    80005784:	694e                	ld	s2,208(sp)
    80005786:	a849                	j	80005818 <sys_unlink+0x16e>
    end_op();
    80005788:	de1fe0ef          	jal	80004568 <end_op>
    return -1;
    8000578c:	557d                	li	a0,-1
    8000578e:	64ee                	ld	s1,216(sp)
    80005790:	a061                	j	80005818 <sys_unlink+0x16e>
    80005792:	e5ce                	sd	s3,200(sp)
    panic("unlink: nlink < 1");
    80005794:	00003517          	auipc	a0,0x3
    80005798:	e8450513          	addi	a0,a0,-380 # 80008618 <etext+0x618>
    8000579c:	876fb0ef          	jal	80000812 <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    800057a0:	04c92703          	lw	a4,76(s2)
    800057a4:	02000793          	li	a5,32
    800057a8:	f8e7f5e3          	bgeu	a5,a4,80005732 <sys_unlink+0x88>
    800057ac:	e5ce                	sd	s3,200(sp)
    800057ae:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800057b2:	4741                	li	a4,16
    800057b4:	86ce                	mv	a3,s3
    800057b6:	f1840613          	addi	a2,s0,-232
    800057ba:	4581                	li	a1,0
    800057bc:	854a                	mv	a0,s2
    800057be:	ee6fe0ef          	jal	80003ea4 <readi>
    800057c2:	47c1                	li	a5,16
    800057c4:	00f51c63          	bne	a0,a5,800057dc <sys_unlink+0x132>
    if(de.inum != 0)
    800057c8:	f1845783          	lhu	a5,-232(s0)
    800057cc:	efa1                	bnez	a5,80005824 <sys_unlink+0x17a>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    800057ce:	29c1                	addiw	s3,s3,16
    800057d0:	04c92783          	lw	a5,76(s2)
    800057d4:	fcf9efe3          	bltu	s3,a5,800057b2 <sys_unlink+0x108>
    800057d8:	69ae                	ld	s3,200(sp)
    800057da:	bfa1                	j	80005732 <sys_unlink+0x88>
      panic("isdirempty: readi");
    800057dc:	00003517          	auipc	a0,0x3
    800057e0:	e5450513          	addi	a0,a0,-428 # 80008630 <etext+0x630>
    800057e4:	82efb0ef          	jal	80000812 <panic>
    800057e8:	e5ce                	sd	s3,200(sp)
    panic("unlink: writei");
    800057ea:	00003517          	auipc	a0,0x3
    800057ee:	e5e50513          	addi	a0,a0,-418 # 80008648 <etext+0x648>
    800057f2:	820fb0ef          	jal	80000812 <panic>
    dp->nlink--;
    800057f6:	04a4d783          	lhu	a5,74(s1)
    800057fa:	37fd                	addiw	a5,a5,-1
    800057fc:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80005800:	8526                	mv	a0,s1
    80005802:	a5efe0ef          	jal	80003a60 <iupdate>
    80005806:	bfa9                	j	80005760 <sys_unlink+0xb6>
    80005808:	694e                	ld	s2,208(sp)
  iunlockput(dp);
    8000580a:	8526                	mv	a0,s1
    8000580c:	d12fe0ef          	jal	80003d1e <iunlockput>
  end_op();
    80005810:	d59fe0ef          	jal	80004568 <end_op>
  return -1;
    80005814:	557d                	li	a0,-1
    80005816:	64ee                	ld	s1,216(sp)
}
    80005818:	70ae                	ld	ra,232(sp)
    8000581a:	740e                	ld	s0,224(sp)
    8000581c:	616d                	addi	sp,sp,240
    8000581e:	8082                	ret
    return -1;
    80005820:	557d                	li	a0,-1
    80005822:	bfdd                	j	80005818 <sys_unlink+0x16e>
    iunlockput(ip);
    80005824:	854a                	mv	a0,s2
    80005826:	cf8fe0ef          	jal	80003d1e <iunlockput>
    goto bad;
    8000582a:	694e                	ld	s2,208(sp)
    8000582c:	69ae                	ld	s3,200(sp)
    8000582e:	bff1                	j	8000580a <sys_unlink+0x160>

0000000080005830 <sys_open>:

uint64
sys_open(void)
{
    80005830:	7131                	addi	sp,sp,-192
    80005832:	fd06                	sd	ra,184(sp)
    80005834:	f922                	sd	s0,176(sp)
    80005836:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    80005838:	f4c40593          	addi	a1,s0,-180
    8000583c:	4505                	li	a0,1
    8000583e:	e16fd0ef          	jal	80002e54 <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    80005842:	08000613          	li	a2,128
    80005846:	f5040593          	addi	a1,s0,-176
    8000584a:	4501                	li	a0,0
    8000584c:	e40fd0ef          	jal	80002e8c <argstr>
    80005850:	87aa                	mv	a5,a0
    return -1;
    80005852:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    80005854:	0a07c263          	bltz	a5,800058f8 <sys_open+0xc8>
    80005858:	f526                	sd	s1,168(sp)

  begin_op();
    8000585a:	ca5fe0ef          	jal	800044fe <begin_op>

  if(omode & O_CREATE){
    8000585e:	f4c42783          	lw	a5,-180(s0)
    80005862:	2007f793          	andi	a5,a5,512
    80005866:	c3d5                	beqz	a5,8000590a <sys_open+0xda>
    ip = create(path, T_FILE, 0, 0);
    80005868:	4681                	li	a3,0
    8000586a:	4601                	li	a2,0
    8000586c:	4589                	li	a1,2
    8000586e:	f5040513          	addi	a0,s0,-176
    80005872:	aa9ff0ef          	jal	8000531a <create>
    80005876:	84aa                	mv	s1,a0
    if(ip == 0){
    80005878:	c541                	beqz	a0,80005900 <sys_open+0xd0>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    8000587a:	04449703          	lh	a4,68(s1)
    8000587e:	478d                	li	a5,3
    80005880:	00f71763          	bne	a4,a5,8000588e <sys_open+0x5e>
    80005884:	0464d703          	lhu	a4,70(s1)
    80005888:	47a5                	li	a5,9
    8000588a:	0ae7ed63          	bltu	a5,a4,80005944 <sys_open+0x114>
    8000588e:	f14a                	sd	s2,160(sp)
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    80005890:	fd7fe0ef          	jal	80004866 <filealloc>
    80005894:	892a                	mv	s2,a0
    80005896:	c179                	beqz	a0,8000595c <sys_open+0x12c>
    80005898:	ed4e                	sd	s3,152(sp)
    8000589a:	a43ff0ef          	jal	800052dc <fdalloc>
    8000589e:	89aa                	mv	s3,a0
    800058a0:	0a054a63          	bltz	a0,80005954 <sys_open+0x124>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    800058a4:	04449703          	lh	a4,68(s1)
    800058a8:	478d                	li	a5,3
    800058aa:	0cf70263          	beq	a4,a5,8000596e <sys_open+0x13e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    800058ae:	4789                	li	a5,2
    800058b0:	00f92023          	sw	a5,0(s2)
    f->off = 0;
    800058b4:	02092023          	sw	zero,32(s2)
  }
  f->ip = ip;
    800058b8:	00993c23          	sd	s1,24(s2)
  f->readable = !(omode & O_WRONLY);
    800058bc:	f4c42783          	lw	a5,-180(s0)
    800058c0:	0017c713          	xori	a4,a5,1
    800058c4:	8b05                	andi	a4,a4,1
    800058c6:	00e90423          	sb	a4,8(s2)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    800058ca:	0037f713          	andi	a4,a5,3
    800058ce:	00e03733          	snez	a4,a4
    800058d2:	00e904a3          	sb	a4,9(s2)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    800058d6:	4007f793          	andi	a5,a5,1024
    800058da:	c791                	beqz	a5,800058e6 <sys_open+0xb6>
    800058dc:	04449703          	lh	a4,68(s1)
    800058e0:	4789                	li	a5,2
    800058e2:	08f70d63          	beq	a4,a5,8000597c <sys_open+0x14c>
    itrunc(ip);
  }

  iunlock(ip);
    800058e6:	8526                	mv	a0,s1
    800058e8:	adafe0ef          	jal	80003bc2 <iunlock>
  end_op();
    800058ec:	c7dfe0ef          	jal	80004568 <end_op>

  return fd;
    800058f0:	854e                	mv	a0,s3
    800058f2:	74aa                	ld	s1,168(sp)
    800058f4:	790a                	ld	s2,160(sp)
    800058f6:	69ea                	ld	s3,152(sp)
}
    800058f8:	70ea                	ld	ra,184(sp)
    800058fa:	744a                	ld	s0,176(sp)
    800058fc:	6129                	addi	sp,sp,192
    800058fe:	8082                	ret
      end_op();
    80005900:	c69fe0ef          	jal	80004568 <end_op>
      return -1;
    80005904:	557d                	li	a0,-1
    80005906:	74aa                	ld	s1,168(sp)
    80005908:	bfc5                	j	800058f8 <sys_open+0xc8>
    if((ip = namei(path)) == 0){
    8000590a:	f5040513          	addi	a0,s0,-176
    8000590e:	a1dfe0ef          	jal	8000432a <namei>
    80005912:	84aa                	mv	s1,a0
    80005914:	c11d                	beqz	a0,8000593a <sys_open+0x10a>
    ilock(ip);
    80005916:	9fefe0ef          	jal	80003b14 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    8000591a:	04449703          	lh	a4,68(s1)
    8000591e:	4785                	li	a5,1
    80005920:	f4f71de3          	bne	a4,a5,8000587a <sys_open+0x4a>
    80005924:	f4c42783          	lw	a5,-180(s0)
    80005928:	d3bd                	beqz	a5,8000588e <sys_open+0x5e>
      iunlockput(ip);
    8000592a:	8526                	mv	a0,s1
    8000592c:	bf2fe0ef          	jal	80003d1e <iunlockput>
      end_op();
    80005930:	c39fe0ef          	jal	80004568 <end_op>
      return -1;
    80005934:	557d                	li	a0,-1
    80005936:	74aa                	ld	s1,168(sp)
    80005938:	b7c1                	j	800058f8 <sys_open+0xc8>
      end_op();
    8000593a:	c2ffe0ef          	jal	80004568 <end_op>
      return -1;
    8000593e:	557d                	li	a0,-1
    80005940:	74aa                	ld	s1,168(sp)
    80005942:	bf5d                	j	800058f8 <sys_open+0xc8>
    iunlockput(ip);
    80005944:	8526                	mv	a0,s1
    80005946:	bd8fe0ef          	jal	80003d1e <iunlockput>
    end_op();
    8000594a:	c1ffe0ef          	jal	80004568 <end_op>
    return -1;
    8000594e:	557d                	li	a0,-1
    80005950:	74aa                	ld	s1,168(sp)
    80005952:	b75d                	j	800058f8 <sys_open+0xc8>
      fileclose(f);
    80005954:	854a                	mv	a0,s2
    80005956:	fb5fe0ef          	jal	8000490a <fileclose>
    8000595a:	69ea                	ld	s3,152(sp)
    iunlockput(ip);
    8000595c:	8526                	mv	a0,s1
    8000595e:	bc0fe0ef          	jal	80003d1e <iunlockput>
    end_op();
    80005962:	c07fe0ef          	jal	80004568 <end_op>
    return -1;
    80005966:	557d                	li	a0,-1
    80005968:	74aa                	ld	s1,168(sp)
    8000596a:	790a                	ld	s2,160(sp)
    8000596c:	b771                	j	800058f8 <sys_open+0xc8>
    f->type = FD_DEVICE;
    8000596e:	00f92023          	sw	a5,0(s2)
    f->major = ip->major;
    80005972:	04649783          	lh	a5,70(s1)
    80005976:	02f91223          	sh	a5,36(s2)
    8000597a:	bf3d                	j	800058b8 <sys_open+0x88>
    itrunc(ip);
    8000597c:	8526                	mv	a0,s1
    8000597e:	a84fe0ef          	jal	80003c02 <itrunc>
    80005982:	b795                	j	800058e6 <sys_open+0xb6>

0000000080005984 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80005984:	7175                	addi	sp,sp,-144
    80005986:	e506                	sd	ra,136(sp)
    80005988:	e122                	sd	s0,128(sp)
    8000598a:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    8000598c:	b73fe0ef          	jal	800044fe <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80005990:	08000613          	li	a2,128
    80005994:	f7040593          	addi	a1,s0,-144
    80005998:	4501                	li	a0,0
    8000599a:	cf2fd0ef          	jal	80002e8c <argstr>
    8000599e:	02054363          	bltz	a0,800059c4 <sys_mkdir+0x40>
    800059a2:	4681                	li	a3,0
    800059a4:	4601                	li	a2,0
    800059a6:	4585                	li	a1,1
    800059a8:	f7040513          	addi	a0,s0,-144
    800059ac:	96fff0ef          	jal	8000531a <create>
    800059b0:	c911                	beqz	a0,800059c4 <sys_mkdir+0x40>
    end_op();
    return -1;
  }
  iunlockput(ip);
    800059b2:	b6cfe0ef          	jal	80003d1e <iunlockput>
  end_op();
    800059b6:	bb3fe0ef          	jal	80004568 <end_op>
  return 0;
    800059ba:	4501                	li	a0,0
}
    800059bc:	60aa                	ld	ra,136(sp)
    800059be:	640a                	ld	s0,128(sp)
    800059c0:	6149                	addi	sp,sp,144
    800059c2:	8082                	ret
    end_op();
    800059c4:	ba5fe0ef          	jal	80004568 <end_op>
    return -1;
    800059c8:	557d                	li	a0,-1
    800059ca:	bfcd                	j	800059bc <sys_mkdir+0x38>

00000000800059cc <sys_mknod>:

uint64
sys_mknod(void)
{
    800059cc:	7135                	addi	sp,sp,-160
    800059ce:	ed06                	sd	ra,152(sp)
    800059d0:	e922                	sd	s0,144(sp)
    800059d2:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    800059d4:	b2bfe0ef          	jal	800044fe <begin_op>
  argint(1, &major);
    800059d8:	f6c40593          	addi	a1,s0,-148
    800059dc:	4505                	li	a0,1
    800059de:	c76fd0ef          	jal	80002e54 <argint>
  argint(2, &minor);
    800059e2:	f6840593          	addi	a1,s0,-152
    800059e6:	4509                	li	a0,2
    800059e8:	c6cfd0ef          	jal	80002e54 <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    800059ec:	08000613          	li	a2,128
    800059f0:	f7040593          	addi	a1,s0,-144
    800059f4:	4501                	li	a0,0
    800059f6:	c96fd0ef          	jal	80002e8c <argstr>
    800059fa:	02054563          	bltz	a0,80005a24 <sys_mknod+0x58>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    800059fe:	f6841683          	lh	a3,-152(s0)
    80005a02:	f6c41603          	lh	a2,-148(s0)
    80005a06:	458d                	li	a1,3
    80005a08:	f7040513          	addi	a0,s0,-144
    80005a0c:	90fff0ef          	jal	8000531a <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005a10:	c911                	beqz	a0,80005a24 <sys_mknod+0x58>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005a12:	b0cfe0ef          	jal	80003d1e <iunlockput>
  end_op();
    80005a16:	b53fe0ef          	jal	80004568 <end_op>
  return 0;
    80005a1a:	4501                	li	a0,0
}
    80005a1c:	60ea                	ld	ra,152(sp)
    80005a1e:	644a                	ld	s0,144(sp)
    80005a20:	610d                	addi	sp,sp,160
    80005a22:	8082                	ret
    end_op();
    80005a24:	b45fe0ef          	jal	80004568 <end_op>
    return -1;
    80005a28:	557d                	li	a0,-1
    80005a2a:	bfcd                	j	80005a1c <sys_mknod+0x50>

0000000080005a2c <sys_chdir>:

uint64
sys_chdir(void)
{
    80005a2c:	7135                	addi	sp,sp,-160
    80005a2e:	ed06                	sd	ra,152(sp)
    80005a30:	e922                	sd	s0,144(sp)
    80005a32:	e14a                	sd	s2,128(sp)
    80005a34:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80005a36:	a2efc0ef          	jal	80001c64 <myproc>
    80005a3a:	892a                	mv	s2,a0
  
  begin_op();
    80005a3c:	ac3fe0ef          	jal	800044fe <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80005a40:	08000613          	li	a2,128
    80005a44:	f6040593          	addi	a1,s0,-160
    80005a48:	4501                	li	a0,0
    80005a4a:	c42fd0ef          	jal	80002e8c <argstr>
    80005a4e:	04054363          	bltz	a0,80005a94 <sys_chdir+0x68>
    80005a52:	e526                	sd	s1,136(sp)
    80005a54:	f6040513          	addi	a0,s0,-160
    80005a58:	8d3fe0ef          	jal	8000432a <namei>
    80005a5c:	84aa                	mv	s1,a0
    80005a5e:	c915                	beqz	a0,80005a92 <sys_chdir+0x66>
    end_op();
    return -1;
  }
  ilock(ip);
    80005a60:	8b4fe0ef          	jal	80003b14 <ilock>
  if(ip->type != T_DIR){
    80005a64:	04449703          	lh	a4,68(s1)
    80005a68:	4785                	li	a5,1
    80005a6a:	02f71963          	bne	a4,a5,80005a9c <sys_chdir+0x70>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80005a6e:	8526                	mv	a0,s1
    80005a70:	952fe0ef          	jal	80003bc2 <iunlock>
  iput(p->cwd);
    80005a74:	15093503          	ld	a0,336(s2)
    80005a78:	a1efe0ef          	jal	80003c96 <iput>
  end_op();
    80005a7c:	aedfe0ef          	jal	80004568 <end_op>
  p->cwd = ip;
    80005a80:	14993823          	sd	s1,336(s2)
  return 0;
    80005a84:	4501                	li	a0,0
    80005a86:	64aa                	ld	s1,136(sp)
}
    80005a88:	60ea                	ld	ra,152(sp)
    80005a8a:	644a                	ld	s0,144(sp)
    80005a8c:	690a                	ld	s2,128(sp)
    80005a8e:	610d                	addi	sp,sp,160
    80005a90:	8082                	ret
    80005a92:	64aa                	ld	s1,136(sp)
    end_op();
    80005a94:	ad5fe0ef          	jal	80004568 <end_op>
    return -1;
    80005a98:	557d                	li	a0,-1
    80005a9a:	b7fd                	j	80005a88 <sys_chdir+0x5c>
    iunlockput(ip);
    80005a9c:	8526                	mv	a0,s1
    80005a9e:	a80fe0ef          	jal	80003d1e <iunlockput>
    end_op();
    80005aa2:	ac7fe0ef          	jal	80004568 <end_op>
    return -1;
    80005aa6:	557d                	li	a0,-1
    80005aa8:	64aa                	ld	s1,136(sp)
    80005aaa:	bff9                	j	80005a88 <sys_chdir+0x5c>

0000000080005aac <sys_exec>:

uint64
sys_exec(void)
{
    80005aac:	7121                	addi	sp,sp,-448
    80005aae:	ff06                	sd	ra,440(sp)
    80005ab0:	fb22                	sd	s0,432(sp)
    80005ab2:	0380                	addi	s0,sp,448
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    80005ab4:	e4840593          	addi	a1,s0,-440
    80005ab8:	4505                	li	a0,1
    80005aba:	bb6fd0ef          	jal	80002e70 <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    80005abe:	08000613          	li	a2,128
    80005ac2:	f5040593          	addi	a1,s0,-176
    80005ac6:	4501                	li	a0,0
    80005ac8:	bc4fd0ef          	jal	80002e8c <argstr>
    80005acc:	87aa                	mv	a5,a0
    return -1;
    80005ace:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    80005ad0:	0c07c463          	bltz	a5,80005b98 <sys_exec+0xec>
    80005ad4:	f726                	sd	s1,424(sp)
    80005ad6:	f34a                	sd	s2,416(sp)
    80005ad8:	ef4e                	sd	s3,408(sp)
    80005ada:	eb52                	sd	s4,400(sp)
  }
  memset(argv, 0, sizeof(argv));
    80005adc:	10000613          	li	a2,256
    80005ae0:	4581                	li	a1,0
    80005ae2:	e5040513          	addi	a0,s0,-432
    80005ae6:	aaafb0ef          	jal	80000d90 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80005aea:	e5040493          	addi	s1,s0,-432
  memset(argv, 0, sizeof(argv));
    80005aee:	89a6                	mv	s3,s1
    80005af0:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    80005af2:	02000a13          	li	s4,32
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80005af6:	00391513          	slli	a0,s2,0x3
    80005afa:	e4040593          	addi	a1,s0,-448
    80005afe:	e4843783          	ld	a5,-440(s0)
    80005b02:	953e                	add	a0,a0,a5
    80005b04:	ac6fd0ef          	jal	80002dca <fetchaddr>
    80005b08:	02054663          	bltz	a0,80005b34 <sys_exec+0x88>
      goto bad;
    }
    if(uarg == 0){
    80005b0c:	e4043783          	ld	a5,-448(s0)
    80005b10:	c3a9                	beqz	a5,80005b52 <sys_exec+0xa6>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80005b12:	87cfb0ef          	jal	80000b8e <kalloc>
    80005b16:	85aa                	mv	a1,a0
    80005b18:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80005b1c:	cd01                	beqz	a0,80005b34 <sys_exec+0x88>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80005b1e:	6605                	lui	a2,0x1
    80005b20:	e4043503          	ld	a0,-448(s0)
    80005b24:	af0fd0ef          	jal	80002e14 <fetchstr>
    80005b28:	00054663          	bltz	a0,80005b34 <sys_exec+0x88>
    if(i >= NELEM(argv)){
    80005b2c:	0905                	addi	s2,s2,1
    80005b2e:	09a1                	addi	s3,s3,8
    80005b30:	fd4913e3          	bne	s2,s4,80005af6 <sys_exec+0x4a>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005b34:	f5040913          	addi	s2,s0,-176
    80005b38:	6088                	ld	a0,0(s1)
    80005b3a:	c931                	beqz	a0,80005b8e <sys_exec+0xe2>
    kfree(argv[i]);
    80005b3c:	f13fa0ef          	jal	80000a4e <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005b40:	04a1                	addi	s1,s1,8
    80005b42:	ff249be3          	bne	s1,s2,80005b38 <sys_exec+0x8c>
  return -1;
    80005b46:	557d                	li	a0,-1
    80005b48:	74ba                	ld	s1,424(sp)
    80005b4a:	791a                	ld	s2,416(sp)
    80005b4c:	69fa                	ld	s3,408(sp)
    80005b4e:	6a5a                	ld	s4,400(sp)
    80005b50:	a0a1                	j	80005b98 <sys_exec+0xec>
      argv[i] = 0;
    80005b52:	0009079b          	sext.w	a5,s2
    80005b56:	078e                	slli	a5,a5,0x3
    80005b58:	fd078793          	addi	a5,a5,-48
    80005b5c:	97a2                	add	a5,a5,s0
    80005b5e:	e807b023          	sd	zero,-384(a5)
  int ret = kexec(path, argv);
    80005b62:	e5040593          	addi	a1,s0,-432
    80005b66:	f5040513          	addi	a0,s0,-176
    80005b6a:	ba8ff0ef          	jal	80004f12 <kexec>
    80005b6e:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005b70:	f5040993          	addi	s3,s0,-176
    80005b74:	6088                	ld	a0,0(s1)
    80005b76:	c511                	beqz	a0,80005b82 <sys_exec+0xd6>
    kfree(argv[i]);
    80005b78:	ed7fa0ef          	jal	80000a4e <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005b7c:	04a1                	addi	s1,s1,8
    80005b7e:	ff349be3          	bne	s1,s3,80005b74 <sys_exec+0xc8>
  return ret;
    80005b82:	854a                	mv	a0,s2
    80005b84:	74ba                	ld	s1,424(sp)
    80005b86:	791a                	ld	s2,416(sp)
    80005b88:	69fa                	ld	s3,408(sp)
    80005b8a:	6a5a                	ld	s4,400(sp)
    80005b8c:	a031                	j	80005b98 <sys_exec+0xec>
  return -1;
    80005b8e:	557d                	li	a0,-1
    80005b90:	74ba                	ld	s1,424(sp)
    80005b92:	791a                	ld	s2,416(sp)
    80005b94:	69fa                	ld	s3,408(sp)
    80005b96:	6a5a                	ld	s4,400(sp)
}
    80005b98:	70fa                	ld	ra,440(sp)
    80005b9a:	745a                	ld	s0,432(sp)
    80005b9c:	6139                	addi	sp,sp,448
    80005b9e:	8082                	ret

0000000080005ba0 <sys_pipe>:

uint64
sys_pipe(void)
{
    80005ba0:	7139                	addi	sp,sp,-64
    80005ba2:	fc06                	sd	ra,56(sp)
    80005ba4:	f822                	sd	s0,48(sp)
    80005ba6:	f426                	sd	s1,40(sp)
    80005ba8:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80005baa:	8bafc0ef          	jal	80001c64 <myproc>
    80005bae:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    80005bb0:	fd840593          	addi	a1,s0,-40
    80005bb4:	4501                	li	a0,0
    80005bb6:	abafd0ef          	jal	80002e70 <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    80005bba:	fc840593          	addi	a1,s0,-56
    80005bbe:	fd040513          	addi	a0,s0,-48
    80005bc2:	852ff0ef          	jal	80004c14 <pipealloc>
    return -1;
    80005bc6:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80005bc8:	0a054463          	bltz	a0,80005c70 <sys_pipe+0xd0>
  fd0 = -1;
    80005bcc:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80005bd0:	fd043503          	ld	a0,-48(s0)
    80005bd4:	f08ff0ef          	jal	800052dc <fdalloc>
    80005bd8:	fca42223          	sw	a0,-60(s0)
    80005bdc:	08054163          	bltz	a0,80005c5e <sys_pipe+0xbe>
    80005be0:	fc843503          	ld	a0,-56(s0)
    80005be4:	ef8ff0ef          	jal	800052dc <fdalloc>
    80005be8:	fca42023          	sw	a0,-64(s0)
    80005bec:	06054063          	bltz	a0,80005c4c <sys_pipe+0xac>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005bf0:	4691                	li	a3,4
    80005bf2:	fc440613          	addi	a2,s0,-60
    80005bf6:	fd843583          	ld	a1,-40(s0)
    80005bfa:	68a8                	ld	a0,80(s1)
    80005bfc:	cf3fb0ef          	jal	800018ee <copyout>
    80005c00:	00054e63          	bltz	a0,80005c1c <sys_pipe+0x7c>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80005c04:	4691                	li	a3,4
    80005c06:	fc040613          	addi	a2,s0,-64
    80005c0a:	fd843583          	ld	a1,-40(s0)
    80005c0e:	0591                	addi	a1,a1,4
    80005c10:	68a8                	ld	a0,80(s1)
    80005c12:	cddfb0ef          	jal	800018ee <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80005c16:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005c18:	04055c63          	bgez	a0,80005c70 <sys_pipe+0xd0>
    p->ofile[fd0] = 0;
    80005c1c:	fc442783          	lw	a5,-60(s0)
    80005c20:	07e9                	addi	a5,a5,26
    80005c22:	078e                	slli	a5,a5,0x3
    80005c24:	97a6                	add	a5,a5,s1
    80005c26:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    80005c2a:	fc042783          	lw	a5,-64(s0)
    80005c2e:	07e9                	addi	a5,a5,26
    80005c30:	078e                	slli	a5,a5,0x3
    80005c32:	94be                	add	s1,s1,a5
    80005c34:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    80005c38:	fd043503          	ld	a0,-48(s0)
    80005c3c:	ccffe0ef          	jal	8000490a <fileclose>
    fileclose(wf);
    80005c40:	fc843503          	ld	a0,-56(s0)
    80005c44:	cc7fe0ef          	jal	8000490a <fileclose>
    return -1;
    80005c48:	57fd                	li	a5,-1
    80005c4a:	a01d                	j	80005c70 <sys_pipe+0xd0>
    if(fd0 >= 0)
    80005c4c:	fc442783          	lw	a5,-60(s0)
    80005c50:	0007c763          	bltz	a5,80005c5e <sys_pipe+0xbe>
      p->ofile[fd0] = 0;
    80005c54:	07e9                	addi	a5,a5,26
    80005c56:	078e                	slli	a5,a5,0x3
    80005c58:	97a6                	add	a5,a5,s1
    80005c5a:	0007b023          	sd	zero,0(a5)
    fileclose(rf);
    80005c5e:	fd043503          	ld	a0,-48(s0)
    80005c62:	ca9fe0ef          	jal	8000490a <fileclose>
    fileclose(wf);
    80005c66:	fc843503          	ld	a0,-56(s0)
    80005c6a:	ca1fe0ef          	jal	8000490a <fileclose>
    return -1;
    80005c6e:	57fd                	li	a5,-1
}
    80005c70:	853e                	mv	a0,a5
    80005c72:	70e2                	ld	ra,56(sp)
    80005c74:	7442                	ld	s0,48(sp)
    80005c76:	74a2                	ld	s1,40(sp)
    80005c78:	6121                	addi	sp,sp,64
    80005c7a:	8082                	ret

0000000080005c7c <sys_fsread>:
uint64
sys_fsread(void)
{
    80005c7c:	1101                	addi	sp,sp,-32
    80005c7e:	ec06                	sd	ra,24(sp)
    80005c80:	e822                	sd	s0,16(sp)
    80005c82:	1000                	addi	s0,sp,32
  uint64 addr;
  int n;

  // استدعاء الدوال بدون مقارنتها بـ < 0 لأنها تعيد void
  argaddr(0, &addr); 
    80005c84:	fe840593          	addi	a1,s0,-24
    80005c88:	4501                	li	a0,0
    80005c8a:	9e6fd0ef          	jal	80002e70 <argaddr>
  argint(1, &n);
    80005c8e:	fe440593          	addi	a1,s0,-28
    80005c92:	4505                	li	a0,1
    80005c94:	9c0fd0ef          	jal	80002e54 <argint>

  // استدعاء الوظيفة الحقيقية وإعادة نتيجتها
  return fslog_read_many((struct fs_event *)addr, n);
    80005c98:	fe442583          	lw	a1,-28(s0)
    80005c9c:	fe843503          	ld	a0,-24(s0)
    80005ca0:	233000ef          	jal	800066d2 <fslog_read_many>
    80005ca4:	60e2                	ld	ra,24(sp)
    80005ca6:	6442                	ld	s0,16(sp)
    80005ca8:	6105                	addi	sp,sp,32
    80005caa:	8082                	ret
    80005cac:	0000                	unimp
	...

0000000080005cb0 <kernelvec>:
.globl kerneltrap
.globl kernelvec
.align 4
kernelvec:
        # make room to save registers.
        addi sp, sp, -256
    80005cb0:	7111                	addi	sp,sp,-256

        # save caller-saved registers.
        sd ra, 0(sp)
    80005cb2:	e006                	sd	ra,0(sp)
        # sd sp, 8(sp)
        sd gp, 16(sp)
    80005cb4:	e80e                	sd	gp,16(sp)
        sd tp, 24(sp)
    80005cb6:	ec12                	sd	tp,24(sp)
        sd t0, 32(sp)
    80005cb8:	f016                	sd	t0,32(sp)
        sd t1, 40(sp)
    80005cba:	f41a                	sd	t1,40(sp)
        sd t2, 48(sp)
    80005cbc:	f81e                	sd	t2,48(sp)
        sd a0, 72(sp)
    80005cbe:	e4aa                	sd	a0,72(sp)
        sd a1, 80(sp)
    80005cc0:	e8ae                	sd	a1,80(sp)
        sd a2, 88(sp)
    80005cc2:	ecb2                	sd	a2,88(sp)
        sd a3, 96(sp)
    80005cc4:	f0b6                	sd	a3,96(sp)
        sd a4, 104(sp)
    80005cc6:	f4ba                	sd	a4,104(sp)
        sd a5, 112(sp)
    80005cc8:	f8be                	sd	a5,112(sp)
        sd a6, 120(sp)
    80005cca:	fcc2                	sd	a6,120(sp)
        sd a7, 128(sp)
    80005ccc:	e146                	sd	a7,128(sp)
        sd t3, 216(sp)
    80005cce:	edf2                	sd	t3,216(sp)
        sd t4, 224(sp)
    80005cd0:	f1f6                	sd	t4,224(sp)
        sd t5, 232(sp)
    80005cd2:	f5fa                	sd	t5,232(sp)
        sd t6, 240(sp)
    80005cd4:	f9fe                	sd	t6,240(sp)

        # call the C trap handler in trap.c
        call kerneltrap
    80005cd6:	804fd0ef          	jal	80002cda <kerneltrap>

        # restore registers.
        ld ra, 0(sp)
    80005cda:	6082                	ld	ra,0(sp)
        # ld sp, 8(sp)
        ld gp, 16(sp)
    80005cdc:	61c2                	ld	gp,16(sp)
        # not tp (contains hartid), in case we moved CPUs
        ld t0, 32(sp)
    80005cde:	7282                	ld	t0,32(sp)
        ld t1, 40(sp)
    80005ce0:	7322                	ld	t1,40(sp)
        ld t2, 48(sp)
    80005ce2:	73c2                	ld	t2,48(sp)
        ld a0, 72(sp)
    80005ce4:	6526                	ld	a0,72(sp)
        ld a1, 80(sp)
    80005ce6:	65c6                	ld	a1,80(sp)
        ld a2, 88(sp)
    80005ce8:	6666                	ld	a2,88(sp)
        ld a3, 96(sp)
    80005cea:	7686                	ld	a3,96(sp)
        ld a4, 104(sp)
    80005cec:	7726                	ld	a4,104(sp)
        ld a5, 112(sp)
    80005cee:	77c6                	ld	a5,112(sp)
        ld a6, 120(sp)
    80005cf0:	7866                	ld	a6,120(sp)
        ld a7, 128(sp)
    80005cf2:	688a                	ld	a7,128(sp)
        ld t3, 216(sp)
    80005cf4:	6e6e                	ld	t3,216(sp)
        ld t4, 224(sp)
    80005cf6:	7e8e                	ld	t4,224(sp)
        ld t5, 232(sp)
    80005cf8:	7f2e                	ld	t5,232(sp)
        ld t6, 240(sp)
    80005cfa:	7fce                	ld	t6,240(sp)

        addi sp, sp, 256
    80005cfc:	6111                	addi	sp,sp,256

        # return to whatever we were doing in the kernel.
        sret
    80005cfe:	10200073          	sret
	...

0000000080005d0e <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    80005d0e:	1141                	addi	sp,sp,-16
    80005d10:	e422                	sd	s0,8(sp)
    80005d12:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80005d14:	0c0007b7          	lui	a5,0xc000
    80005d18:	4705                	li	a4,1
    80005d1a:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    80005d1c:	0c0007b7          	lui	a5,0xc000
    80005d20:	c3d8                	sw	a4,4(a5)
}
    80005d22:	6422                	ld	s0,8(sp)
    80005d24:	0141                	addi	sp,sp,16
    80005d26:	8082                	ret

0000000080005d28 <plicinithart>:

void
plicinithart(void)
{
    80005d28:	1141                	addi	sp,sp,-16
    80005d2a:	e406                	sd	ra,8(sp)
    80005d2c:	e022                	sd	s0,0(sp)
    80005d2e:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005d30:	f03fb0ef          	jal	80001c32 <cpuid>
  
  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80005d34:	0085171b          	slliw	a4,a0,0x8
    80005d38:	0c0027b7          	lui	a5,0xc002
    80005d3c:	97ba                	add	a5,a5,a4
    80005d3e:	40200713          	li	a4,1026
    80005d42:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80005d46:	00d5151b          	slliw	a0,a0,0xd
    80005d4a:	0c2017b7          	lui	a5,0xc201
    80005d4e:	97aa                	add	a5,a5,a0
    80005d50:	0007a023          	sw	zero,0(a5) # c201000 <_entry-0x73dff000>
}
    80005d54:	60a2                	ld	ra,8(sp)
    80005d56:	6402                	ld	s0,0(sp)
    80005d58:	0141                	addi	sp,sp,16
    80005d5a:	8082                	ret

0000000080005d5c <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    80005d5c:	1141                	addi	sp,sp,-16
    80005d5e:	e406                	sd	ra,8(sp)
    80005d60:	e022                	sd	s0,0(sp)
    80005d62:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005d64:	ecffb0ef          	jal	80001c32 <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80005d68:	00d5151b          	slliw	a0,a0,0xd
    80005d6c:	0c2017b7          	lui	a5,0xc201
    80005d70:	97aa                	add	a5,a5,a0
  return irq;
}
    80005d72:	43c8                	lw	a0,4(a5)
    80005d74:	60a2                	ld	ra,8(sp)
    80005d76:	6402                	ld	s0,0(sp)
    80005d78:	0141                	addi	sp,sp,16
    80005d7a:	8082                	ret

0000000080005d7c <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    80005d7c:	1101                	addi	sp,sp,-32
    80005d7e:	ec06                	sd	ra,24(sp)
    80005d80:	e822                	sd	s0,16(sp)
    80005d82:	e426                	sd	s1,8(sp)
    80005d84:	1000                	addi	s0,sp,32
    80005d86:	84aa                	mv	s1,a0
  int hart = cpuid();
    80005d88:	eabfb0ef          	jal	80001c32 <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    80005d8c:	00d5151b          	slliw	a0,a0,0xd
    80005d90:	0c2017b7          	lui	a5,0xc201
    80005d94:	97aa                	add	a5,a5,a0
    80005d96:	c3c4                	sw	s1,4(a5)
}
    80005d98:	60e2                	ld	ra,24(sp)
    80005d9a:	6442                	ld	s0,16(sp)
    80005d9c:	64a2                	ld	s1,8(sp)
    80005d9e:	6105                	addi	sp,sp,32
    80005da0:	8082                	ret

0000000080005da2 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80005da2:	1141                	addi	sp,sp,-16
    80005da4:	e406                	sd	ra,8(sp)
    80005da6:	e022                	sd	s0,0(sp)
    80005da8:	0800                	addi	s0,sp,16
  if(i >= NUM)
    80005daa:	479d                	li	a5,7
    80005dac:	04a7ca63          	blt	a5,a0,80005e00 <free_desc+0x5e>
    panic("free_desc 1");
  if(disk.free[i])
    80005db0:	0001c797          	auipc	a5,0x1c
    80005db4:	f4878793          	addi	a5,a5,-184 # 80021cf8 <disk>
    80005db8:	97aa                	add	a5,a5,a0
    80005dba:	0187c783          	lbu	a5,24(a5)
    80005dbe:	e7b9                	bnez	a5,80005e0c <free_desc+0x6a>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    80005dc0:	00451693          	slli	a3,a0,0x4
    80005dc4:	0001c797          	auipc	a5,0x1c
    80005dc8:	f3478793          	addi	a5,a5,-204 # 80021cf8 <disk>
    80005dcc:	6398                	ld	a4,0(a5)
    80005dce:	9736                	add	a4,a4,a3
    80005dd0:	00073023          	sd	zero,0(a4)
  disk.desc[i].len = 0;
    80005dd4:	6398                	ld	a4,0(a5)
    80005dd6:	9736                	add	a4,a4,a3
    80005dd8:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    80005ddc:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    80005de0:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    80005de4:	97aa                	add	a5,a5,a0
    80005de6:	4705                	li	a4,1
    80005de8:	00e78c23          	sb	a4,24(a5)
  wakeup(&disk.free[0]);
    80005dec:	0001c517          	auipc	a0,0x1c
    80005df0:	f2450513          	addi	a0,a0,-220 # 80021d10 <disk+0x18>
    80005df4:	f86fc0ef          	jal	8000257a <wakeup>
}
    80005df8:	60a2                	ld	ra,8(sp)
    80005dfa:	6402                	ld	s0,0(sp)
    80005dfc:	0141                	addi	sp,sp,16
    80005dfe:	8082                	ret
    panic("free_desc 1");
    80005e00:	00003517          	auipc	a0,0x3
    80005e04:	85850513          	addi	a0,a0,-1960 # 80008658 <etext+0x658>
    80005e08:	a0bfa0ef          	jal	80000812 <panic>
    panic("free_desc 2");
    80005e0c:	00003517          	auipc	a0,0x3
    80005e10:	85c50513          	addi	a0,a0,-1956 # 80008668 <etext+0x668>
    80005e14:	9fffa0ef          	jal	80000812 <panic>

0000000080005e18 <virtio_disk_init>:
{
    80005e18:	1101                	addi	sp,sp,-32
    80005e1a:	ec06                	sd	ra,24(sp)
    80005e1c:	e822                	sd	s0,16(sp)
    80005e1e:	e426                	sd	s1,8(sp)
    80005e20:	e04a                	sd	s2,0(sp)
    80005e22:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80005e24:	00003597          	auipc	a1,0x3
    80005e28:	85458593          	addi	a1,a1,-1964 # 80008678 <etext+0x678>
    80005e2c:	0001c517          	auipc	a0,0x1c
    80005e30:	ff450513          	addi	a0,a0,-12 # 80021e20 <disk+0x128>
    80005e34:	e09fa0ef          	jal	80000c3c <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005e38:	100017b7          	lui	a5,0x10001
    80005e3c:	4398                	lw	a4,0(a5)
    80005e3e:	2701                	sext.w	a4,a4
    80005e40:	747277b7          	lui	a5,0x74727
    80005e44:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    80005e48:	18f71063          	bne	a4,a5,80005fc8 <virtio_disk_init+0x1b0>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80005e4c:	100017b7          	lui	a5,0x10001
    80005e50:	0791                	addi	a5,a5,4 # 10001004 <_entry-0x6fffeffc>
    80005e52:	439c                	lw	a5,0(a5)
    80005e54:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005e56:	4709                	li	a4,2
    80005e58:	16e79863          	bne	a5,a4,80005fc8 <virtio_disk_init+0x1b0>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005e5c:	100017b7          	lui	a5,0x10001
    80005e60:	07a1                	addi	a5,a5,8 # 10001008 <_entry-0x6fffeff8>
    80005e62:	439c                	lw	a5,0(a5)
    80005e64:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80005e66:	16e79163          	bne	a5,a4,80005fc8 <virtio_disk_init+0x1b0>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    80005e6a:	100017b7          	lui	a5,0x10001
    80005e6e:	47d8                	lw	a4,12(a5)
    80005e70:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005e72:	554d47b7          	lui	a5,0x554d4
    80005e76:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    80005e7a:	14f71763          	bne	a4,a5,80005fc8 <virtio_disk_init+0x1b0>
  *R(VIRTIO_MMIO_STATUS) = status;
    80005e7e:	100017b7          	lui	a5,0x10001
    80005e82:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    80005e86:	4705                	li	a4,1
    80005e88:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005e8a:	470d                	li	a4,3
    80005e8c:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    80005e8e:	10001737          	lui	a4,0x10001
    80005e92:	4b14                	lw	a3,16(a4)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    80005e94:	c7ffe737          	lui	a4,0xc7ffe
    80005e98:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47fb787f>
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80005e9c:	8ef9                	and	a3,a3,a4
    80005e9e:	10001737          	lui	a4,0x10001
    80005ea2:	d314                	sw	a3,32(a4)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005ea4:	472d                	li	a4,11
    80005ea6:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005ea8:	07078793          	addi	a5,a5,112
  status = *R(VIRTIO_MMIO_STATUS);
    80005eac:	439c                	lw	a5,0(a5)
    80005eae:	0007891b          	sext.w	s2,a5
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    80005eb2:	8ba1                	andi	a5,a5,8
    80005eb4:	12078063          	beqz	a5,80005fd4 <virtio_disk_init+0x1bc>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80005eb8:	100017b7          	lui	a5,0x10001
    80005ebc:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    80005ec0:	100017b7          	lui	a5,0x10001
    80005ec4:	04478793          	addi	a5,a5,68 # 10001044 <_entry-0x6fffefbc>
    80005ec8:	439c                	lw	a5,0(a5)
    80005eca:	2781                	sext.w	a5,a5
    80005ecc:	10079a63          	bnez	a5,80005fe0 <virtio_disk_init+0x1c8>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    80005ed0:	100017b7          	lui	a5,0x10001
    80005ed4:	03478793          	addi	a5,a5,52 # 10001034 <_entry-0x6fffefcc>
    80005ed8:	439c                	lw	a5,0(a5)
    80005eda:	2781                	sext.w	a5,a5
  if(max == 0)
    80005edc:	10078863          	beqz	a5,80005fec <virtio_disk_init+0x1d4>
  if(max < NUM)
    80005ee0:	471d                	li	a4,7
    80005ee2:	10f77b63          	bgeu	a4,a5,80005ff8 <virtio_disk_init+0x1e0>
  disk.desc = kalloc();
    80005ee6:	ca9fa0ef          	jal	80000b8e <kalloc>
    80005eea:	0001c497          	auipc	s1,0x1c
    80005eee:	e0e48493          	addi	s1,s1,-498 # 80021cf8 <disk>
    80005ef2:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    80005ef4:	c9bfa0ef          	jal	80000b8e <kalloc>
    80005ef8:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    80005efa:	c95fa0ef          	jal	80000b8e <kalloc>
    80005efe:	87aa                	mv	a5,a0
    80005f00:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    80005f02:	6088                	ld	a0,0(s1)
    80005f04:	10050063          	beqz	a0,80006004 <virtio_disk_init+0x1ec>
    80005f08:	0001c717          	auipc	a4,0x1c
    80005f0c:	df873703          	ld	a4,-520(a4) # 80021d00 <disk+0x8>
    80005f10:	0e070a63          	beqz	a4,80006004 <virtio_disk_init+0x1ec>
    80005f14:	0e078863          	beqz	a5,80006004 <virtio_disk_init+0x1ec>
  memset(disk.desc, 0, PGSIZE);
    80005f18:	6605                	lui	a2,0x1
    80005f1a:	4581                	li	a1,0
    80005f1c:	e75fa0ef          	jal	80000d90 <memset>
  memset(disk.avail, 0, PGSIZE);
    80005f20:	0001c497          	auipc	s1,0x1c
    80005f24:	dd848493          	addi	s1,s1,-552 # 80021cf8 <disk>
    80005f28:	6605                	lui	a2,0x1
    80005f2a:	4581                	li	a1,0
    80005f2c:	6488                	ld	a0,8(s1)
    80005f2e:	e63fa0ef          	jal	80000d90 <memset>
  memset(disk.used, 0, PGSIZE);
    80005f32:	6605                	lui	a2,0x1
    80005f34:	4581                	li	a1,0
    80005f36:	6888                	ld	a0,16(s1)
    80005f38:	e59fa0ef          	jal	80000d90 <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    80005f3c:	100017b7          	lui	a5,0x10001
    80005f40:	4721                	li	a4,8
    80005f42:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    80005f44:	4098                	lw	a4,0(s1)
    80005f46:	100017b7          	lui	a5,0x10001
    80005f4a:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    80005f4e:	40d8                	lw	a4,4(s1)
    80005f50:	100017b7          	lui	a5,0x10001
    80005f54:	08e7a223          	sw	a4,132(a5) # 10001084 <_entry-0x6fffef7c>
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    80005f58:	649c                	ld	a5,8(s1)
    80005f5a:	0007869b          	sext.w	a3,a5
    80005f5e:	10001737          	lui	a4,0x10001
    80005f62:	08d72823          	sw	a3,144(a4) # 10001090 <_entry-0x6fffef70>
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    80005f66:	9781                	srai	a5,a5,0x20
    80005f68:	10001737          	lui	a4,0x10001
    80005f6c:	08f72a23          	sw	a5,148(a4) # 10001094 <_entry-0x6fffef6c>
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    80005f70:	689c                	ld	a5,16(s1)
    80005f72:	0007869b          	sext.w	a3,a5
    80005f76:	10001737          	lui	a4,0x10001
    80005f7a:	0ad72023          	sw	a3,160(a4) # 100010a0 <_entry-0x6fffef60>
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    80005f7e:	9781                	srai	a5,a5,0x20
    80005f80:	10001737          	lui	a4,0x10001
    80005f84:	0af72223          	sw	a5,164(a4) # 100010a4 <_entry-0x6fffef5c>
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    80005f88:	10001737          	lui	a4,0x10001
    80005f8c:	4785                	li	a5,1
    80005f8e:	c37c                	sw	a5,68(a4)
    disk.free[i] = 1;
    80005f90:	00f48c23          	sb	a5,24(s1)
    80005f94:	00f48ca3          	sb	a5,25(s1)
    80005f98:	00f48d23          	sb	a5,26(s1)
    80005f9c:	00f48da3          	sb	a5,27(s1)
    80005fa0:	00f48e23          	sb	a5,28(s1)
    80005fa4:	00f48ea3          	sb	a5,29(s1)
    80005fa8:	00f48f23          	sb	a5,30(s1)
    80005fac:	00f48fa3          	sb	a5,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    80005fb0:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    80005fb4:	100017b7          	lui	a5,0x10001
    80005fb8:	0727a823          	sw	s2,112(a5) # 10001070 <_entry-0x6fffef90>
}
    80005fbc:	60e2                	ld	ra,24(sp)
    80005fbe:	6442                	ld	s0,16(sp)
    80005fc0:	64a2                	ld	s1,8(sp)
    80005fc2:	6902                	ld	s2,0(sp)
    80005fc4:	6105                	addi	sp,sp,32
    80005fc6:	8082                	ret
    panic("could not find virtio disk");
    80005fc8:	00002517          	auipc	a0,0x2
    80005fcc:	6c050513          	addi	a0,a0,1728 # 80008688 <etext+0x688>
    80005fd0:	843fa0ef          	jal	80000812 <panic>
    panic("virtio disk FEATURES_OK unset");
    80005fd4:	00002517          	auipc	a0,0x2
    80005fd8:	6d450513          	addi	a0,a0,1748 # 800086a8 <etext+0x6a8>
    80005fdc:	837fa0ef          	jal	80000812 <panic>
    panic("virtio disk should not be ready");
    80005fe0:	00002517          	auipc	a0,0x2
    80005fe4:	6e850513          	addi	a0,a0,1768 # 800086c8 <etext+0x6c8>
    80005fe8:	82bfa0ef          	jal	80000812 <panic>
    panic("virtio disk has no queue 0");
    80005fec:	00002517          	auipc	a0,0x2
    80005ff0:	6fc50513          	addi	a0,a0,1788 # 800086e8 <etext+0x6e8>
    80005ff4:	81ffa0ef          	jal	80000812 <panic>
    panic("virtio disk max queue too short");
    80005ff8:	00002517          	auipc	a0,0x2
    80005ffc:	71050513          	addi	a0,a0,1808 # 80008708 <etext+0x708>
    80006000:	813fa0ef          	jal	80000812 <panic>
    panic("virtio disk kalloc");
    80006004:	00002517          	auipc	a0,0x2
    80006008:	72450513          	addi	a0,a0,1828 # 80008728 <etext+0x728>
    8000600c:	807fa0ef          	jal	80000812 <panic>

0000000080006010 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80006010:	7159                	addi	sp,sp,-112
    80006012:	f486                	sd	ra,104(sp)
    80006014:	f0a2                	sd	s0,96(sp)
    80006016:	eca6                	sd	s1,88(sp)
    80006018:	e8ca                	sd	s2,80(sp)
    8000601a:	e4ce                	sd	s3,72(sp)
    8000601c:	e0d2                	sd	s4,64(sp)
    8000601e:	fc56                	sd	s5,56(sp)
    80006020:	f85a                	sd	s6,48(sp)
    80006022:	f45e                	sd	s7,40(sp)
    80006024:	f062                	sd	s8,32(sp)
    80006026:	ec66                	sd	s9,24(sp)
    80006028:	1880                	addi	s0,sp,112
    8000602a:	8a2a                	mv	s4,a0
    8000602c:	8bae                	mv	s7,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    8000602e:	00c52c83          	lw	s9,12(a0)
    80006032:	001c9c9b          	slliw	s9,s9,0x1
    80006036:	1c82                	slli	s9,s9,0x20
    80006038:	020cdc93          	srli	s9,s9,0x20

  acquire(&disk.vdisk_lock);
    8000603c:	0001c517          	auipc	a0,0x1c
    80006040:	de450513          	addi	a0,a0,-540 # 80021e20 <disk+0x128>
    80006044:	c79fa0ef          	jal	80000cbc <acquire>
  for(int i = 0; i < 3; i++){
    80006048:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    8000604a:	44a1                	li	s1,8
      disk.free[i] = 0;
    8000604c:	0001cb17          	auipc	s6,0x1c
    80006050:	cacb0b13          	addi	s6,s6,-852 # 80021cf8 <disk>
  for(int i = 0; i < 3; i++){
    80006054:	4a8d                	li	s5,3
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80006056:	0001cc17          	auipc	s8,0x1c
    8000605a:	dcac0c13          	addi	s8,s8,-566 # 80021e20 <disk+0x128>
    8000605e:	a8b9                	j	800060bc <virtio_disk_rw+0xac>
      disk.free[i] = 0;
    80006060:	00fb0733          	add	a4,s6,a5
    80006064:	00070c23          	sb	zero,24(a4) # 10001018 <_entry-0x6fffefe8>
    idx[i] = alloc_desc();
    80006068:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    8000606a:	0207c563          	bltz	a5,80006094 <virtio_disk_rw+0x84>
  for(int i = 0; i < 3; i++){
    8000606e:	2905                	addiw	s2,s2,1
    80006070:	0611                	addi	a2,a2,4 # 1004 <_entry-0x7fffeffc>
    80006072:	05590963          	beq	s2,s5,800060c4 <virtio_disk_rw+0xb4>
    idx[i] = alloc_desc();
    80006076:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    80006078:	0001c717          	auipc	a4,0x1c
    8000607c:	c8070713          	addi	a4,a4,-896 # 80021cf8 <disk>
    80006080:	87ce                	mv	a5,s3
    if(disk.free[i]){
    80006082:	01874683          	lbu	a3,24(a4)
    80006086:	fee9                	bnez	a3,80006060 <virtio_disk_rw+0x50>
  for(int i = 0; i < NUM; i++){
    80006088:	2785                	addiw	a5,a5,1
    8000608a:	0705                	addi	a4,a4,1
    8000608c:	fe979be3          	bne	a5,s1,80006082 <virtio_disk_rw+0x72>
    idx[i] = alloc_desc();
    80006090:	57fd                	li	a5,-1
    80006092:	c19c                	sw	a5,0(a1)
      for(int j = 0; j < i; j++)
    80006094:	01205d63          	blez	s2,800060ae <virtio_disk_rw+0x9e>
        free_desc(idx[j]);
    80006098:	f9042503          	lw	a0,-112(s0)
    8000609c:	d07ff0ef          	jal	80005da2 <free_desc>
      for(int j = 0; j < i; j++)
    800060a0:	4785                	li	a5,1
    800060a2:	0127d663          	bge	a5,s2,800060ae <virtio_disk_rw+0x9e>
        free_desc(idx[j]);
    800060a6:	f9442503          	lw	a0,-108(s0)
    800060aa:	cf9ff0ef          	jal	80005da2 <free_desc>
    sleep(&disk.free[0], &disk.vdisk_lock);
    800060ae:	85e2                	mv	a1,s8
    800060b0:	0001c517          	auipc	a0,0x1c
    800060b4:	c6050513          	addi	a0,a0,-928 # 80021d10 <disk+0x18>
    800060b8:	c72fc0ef          	jal	8000252a <sleep>
  for(int i = 0; i < 3; i++){
    800060bc:	f9040613          	addi	a2,s0,-112
    800060c0:	894e                	mv	s2,s3
    800060c2:	bf55                	j	80006076 <virtio_disk_rw+0x66>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    800060c4:	f9042503          	lw	a0,-112(s0)
    800060c8:	00451693          	slli	a3,a0,0x4

  if(write)
    800060cc:	0001c797          	auipc	a5,0x1c
    800060d0:	c2c78793          	addi	a5,a5,-980 # 80021cf8 <disk>
    800060d4:	00a50713          	addi	a4,a0,10
    800060d8:	0712                	slli	a4,a4,0x4
    800060da:	973e                	add	a4,a4,a5
    800060dc:	01703633          	snez	a2,s7
    800060e0:	c710                	sw	a2,8(a4)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    800060e2:	00072623          	sw	zero,12(a4)
  buf0->sector = sector;
    800060e6:	01973823          	sd	s9,16(a4)

  disk.desc[idx[0]].addr = (uint64) buf0;
    800060ea:	6398                	ld	a4,0(a5)
    800060ec:	9736                	add	a4,a4,a3
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    800060ee:	0a868613          	addi	a2,a3,168
    800060f2:	963e                	add	a2,a2,a5
  disk.desc[idx[0]].addr = (uint64) buf0;
    800060f4:	e310                	sd	a2,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    800060f6:	6390                	ld	a2,0(a5)
    800060f8:	00d605b3          	add	a1,a2,a3
    800060fc:	4741                	li	a4,16
    800060fe:	c598                	sw	a4,8(a1)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    80006100:	4805                	li	a6,1
    80006102:	01059623          	sh	a6,12(a1)
  disk.desc[idx[0]].next = idx[1];
    80006106:	f9442703          	lw	a4,-108(s0)
    8000610a:	00e59723          	sh	a4,14(a1)

  disk.desc[idx[1]].addr = (uint64) b->data;
    8000610e:	0712                	slli	a4,a4,0x4
    80006110:	963a                	add	a2,a2,a4
    80006112:	058a0593          	addi	a1,s4,88
    80006116:	e20c                	sd	a1,0(a2)
  disk.desc[idx[1]].len = BSIZE;
    80006118:	0007b883          	ld	a7,0(a5)
    8000611c:	9746                	add	a4,a4,a7
    8000611e:	40000613          	li	a2,1024
    80006122:	c710                	sw	a2,8(a4)
  if(write)
    80006124:	001bb613          	seqz	a2,s7
    80006128:	0016161b          	slliw	a2,a2,0x1
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    8000612c:	00166613          	ori	a2,a2,1
    80006130:	00c71623          	sh	a2,12(a4)
  disk.desc[idx[1]].next = idx[2];
    80006134:	f9842583          	lw	a1,-104(s0)
    80006138:	00b71723          	sh	a1,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    8000613c:	00250613          	addi	a2,a0,2
    80006140:	0612                	slli	a2,a2,0x4
    80006142:	963e                	add	a2,a2,a5
    80006144:	577d                	li	a4,-1
    80006146:	00e60823          	sb	a4,16(a2)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    8000614a:	0592                	slli	a1,a1,0x4
    8000614c:	98ae                	add	a7,a7,a1
    8000614e:	03068713          	addi	a4,a3,48
    80006152:	973e                	add	a4,a4,a5
    80006154:	00e8b023          	sd	a4,0(a7)
  disk.desc[idx[2]].len = 1;
    80006158:	6398                	ld	a4,0(a5)
    8000615a:	972e                	add	a4,a4,a1
    8000615c:	01072423          	sw	a6,8(a4)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    80006160:	4689                	li	a3,2
    80006162:	00d71623          	sh	a3,12(a4)
  disk.desc[idx[2]].next = 0;
    80006166:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    8000616a:	010a2223          	sw	a6,4(s4)
  disk.info[idx[0]].b = b;
    8000616e:	01463423          	sd	s4,8(a2)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    80006172:	6794                	ld	a3,8(a5)
    80006174:	0026d703          	lhu	a4,2(a3)
    80006178:	8b1d                	andi	a4,a4,7
    8000617a:	0706                	slli	a4,a4,0x1
    8000617c:	96ba                	add	a3,a3,a4
    8000617e:	00a69223          	sh	a0,4(a3)

  __sync_synchronize();
    80006182:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    80006186:	6798                	ld	a4,8(a5)
    80006188:	00275783          	lhu	a5,2(a4)
    8000618c:	2785                	addiw	a5,a5,1
    8000618e:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    80006192:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80006196:	100017b7          	lui	a5,0x10001
    8000619a:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    8000619e:	004a2783          	lw	a5,4(s4)
    sleep(b, &disk.vdisk_lock);
    800061a2:	0001c917          	auipc	s2,0x1c
    800061a6:	c7e90913          	addi	s2,s2,-898 # 80021e20 <disk+0x128>
  while(b->disk == 1) {
    800061aa:	4485                	li	s1,1
    800061ac:	01079a63          	bne	a5,a6,800061c0 <virtio_disk_rw+0x1b0>
    sleep(b, &disk.vdisk_lock);
    800061b0:	85ca                	mv	a1,s2
    800061b2:	8552                	mv	a0,s4
    800061b4:	b76fc0ef          	jal	8000252a <sleep>
  while(b->disk == 1) {
    800061b8:	004a2783          	lw	a5,4(s4)
    800061bc:	fe978ae3          	beq	a5,s1,800061b0 <virtio_disk_rw+0x1a0>
  }

  disk.info[idx[0]].b = 0;
    800061c0:	f9042903          	lw	s2,-112(s0)
    800061c4:	00290713          	addi	a4,s2,2
    800061c8:	0712                	slli	a4,a4,0x4
    800061ca:	0001c797          	auipc	a5,0x1c
    800061ce:	b2e78793          	addi	a5,a5,-1234 # 80021cf8 <disk>
    800061d2:	97ba                	add	a5,a5,a4
    800061d4:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    800061d8:	0001c997          	auipc	s3,0x1c
    800061dc:	b2098993          	addi	s3,s3,-1248 # 80021cf8 <disk>
    800061e0:	00491713          	slli	a4,s2,0x4
    800061e4:	0009b783          	ld	a5,0(s3)
    800061e8:	97ba                	add	a5,a5,a4
    800061ea:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    800061ee:	854a                	mv	a0,s2
    800061f0:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    800061f4:	bafff0ef          	jal	80005da2 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    800061f8:	8885                	andi	s1,s1,1
    800061fa:	f0fd                	bnez	s1,800061e0 <virtio_disk_rw+0x1d0>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    800061fc:	0001c517          	auipc	a0,0x1c
    80006200:	c2450513          	addi	a0,a0,-988 # 80021e20 <disk+0x128>
    80006204:	b51fa0ef          	jal	80000d54 <release>
}
    80006208:	70a6                	ld	ra,104(sp)
    8000620a:	7406                	ld	s0,96(sp)
    8000620c:	64e6                	ld	s1,88(sp)
    8000620e:	6946                	ld	s2,80(sp)
    80006210:	69a6                	ld	s3,72(sp)
    80006212:	6a06                	ld	s4,64(sp)
    80006214:	7ae2                	ld	s5,56(sp)
    80006216:	7b42                	ld	s6,48(sp)
    80006218:	7ba2                	ld	s7,40(sp)
    8000621a:	7c02                	ld	s8,32(sp)
    8000621c:	6ce2                	ld	s9,24(sp)
    8000621e:	6165                	addi	sp,sp,112
    80006220:	8082                	ret

0000000080006222 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    80006222:	1101                	addi	sp,sp,-32
    80006224:	ec06                	sd	ra,24(sp)
    80006226:	e822                	sd	s0,16(sp)
    80006228:	e426                	sd	s1,8(sp)
    8000622a:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    8000622c:	0001c497          	auipc	s1,0x1c
    80006230:	acc48493          	addi	s1,s1,-1332 # 80021cf8 <disk>
    80006234:	0001c517          	auipc	a0,0x1c
    80006238:	bec50513          	addi	a0,a0,-1044 # 80021e20 <disk+0x128>
    8000623c:	a81fa0ef          	jal	80000cbc <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    80006240:	100017b7          	lui	a5,0x10001
    80006244:	53b8                	lw	a4,96(a5)
    80006246:	8b0d                	andi	a4,a4,3
    80006248:	100017b7          	lui	a5,0x10001
    8000624c:	d3f8                	sw	a4,100(a5)

  __sync_synchronize();
    8000624e:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    80006252:	689c                	ld	a5,16(s1)
    80006254:	0204d703          	lhu	a4,32(s1)
    80006258:	0027d783          	lhu	a5,2(a5) # 10001002 <_entry-0x6fffeffe>
    8000625c:	04f70663          	beq	a4,a5,800062a8 <virtio_disk_intr+0x86>
    __sync_synchronize();
    80006260:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    80006264:	6898                	ld	a4,16(s1)
    80006266:	0204d783          	lhu	a5,32(s1)
    8000626a:	8b9d                	andi	a5,a5,7
    8000626c:	078e                	slli	a5,a5,0x3
    8000626e:	97ba                	add	a5,a5,a4
    80006270:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    80006272:	00278713          	addi	a4,a5,2
    80006276:	0712                	slli	a4,a4,0x4
    80006278:	9726                	add	a4,a4,s1
    8000627a:	01074703          	lbu	a4,16(a4)
    8000627e:	e321                	bnez	a4,800062be <virtio_disk_intr+0x9c>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    80006280:	0789                	addi	a5,a5,2
    80006282:	0792                	slli	a5,a5,0x4
    80006284:	97a6                	add	a5,a5,s1
    80006286:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    80006288:	00052223          	sw	zero,4(a0)
    wakeup(b);
    8000628c:	aeefc0ef          	jal	8000257a <wakeup>

    disk.used_idx += 1;
    80006290:	0204d783          	lhu	a5,32(s1)
    80006294:	2785                	addiw	a5,a5,1
    80006296:	17c2                	slli	a5,a5,0x30
    80006298:	93c1                	srli	a5,a5,0x30
    8000629a:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    8000629e:	6898                	ld	a4,16(s1)
    800062a0:	00275703          	lhu	a4,2(a4)
    800062a4:	faf71ee3          	bne	a4,a5,80006260 <virtio_disk_intr+0x3e>
  }

  release(&disk.vdisk_lock);
    800062a8:	0001c517          	auipc	a0,0x1c
    800062ac:	b7850513          	addi	a0,a0,-1160 # 80021e20 <disk+0x128>
    800062b0:	aa5fa0ef          	jal	80000d54 <release>
}
    800062b4:	60e2                	ld	ra,24(sp)
    800062b6:	6442                	ld	s0,16(sp)
    800062b8:	64a2                	ld	s1,8(sp)
    800062ba:	6105                	addi	sp,sp,32
    800062bc:	8082                	ret
      panic("virtio_disk_intr status");
    800062be:	00002517          	auipc	a0,0x2
    800062c2:	48250513          	addi	a0,a0,1154 # 80008740 <etext+0x740>
    800062c6:	d4cfa0ef          	jal	80000812 <panic>

00000000800062ca <cslog_init>:
  safestrcpy(e->name, p->name, CS_NM);
}

void
cslog_init(void)
{
    800062ca:	1141                	addi	sp,sp,-16
    800062cc:	e406                	sd	ra,8(sp)
    800062ce:	e022                	sd	s0,0(sp)
    800062d0:	0800                	addi	s0,sp,16
  ringbuf_init(&cs_rb, "cslog", sizeof(struct cs_event));
    800062d2:	03000613          	li	a2,48
    800062d6:	00002597          	auipc	a1,0x2
    800062da:	48258593          	addi	a1,a1,1154 # 80008758 <etext+0x758>
    800062de:	0001c517          	auipc	a0,0x1c
    800062e2:	b5a50513          	addi	a0,a0,-1190 # 80021e38 <cs_rb>
    800062e6:	1b2000ef          	jal	80006498 <ringbuf_init>
}
    800062ea:	60a2                	ld	ra,8(sp)
    800062ec:	6402                	ld	s0,0(sp)
    800062ee:	0141                	addi	sp,sp,16
    800062f0:	8082                	ret

00000000800062f2 <cslog_push>:

void
cslog_push(struct cs_event *e)
{
    800062f2:	1141                	addi	sp,sp,-16
    800062f4:	e406                	sd	ra,8(sp)
    800062f6:	e022                	sd	s0,0(sp)
    800062f8:	0800                	addi	s0,sp,16
    800062fa:	85aa                	mv	a1,a0
  e->seq = ++cs_seq;
    800062fc:	00002717          	auipc	a4,0x2
    80006300:	63c70713          	addi	a4,a4,1596 # 80008938 <cs_seq>
    80006304:	631c                	ld	a5,0(a4)
    80006306:	0785                	addi	a5,a5,1
    80006308:	e31c                	sd	a5,0(a4)
    8000630a:	e11c                	sd	a5,0(a0)
  ringbuf_push(&cs_rb, e);
    8000630c:	0001c517          	auipc	a0,0x1c
    80006310:	b2c50513          	addi	a0,a0,-1236 # 80021e38 <cs_rb>
    80006314:	1b8000ef          	jal	800064cc <ringbuf_push>
}
    80006318:	60a2                	ld	ra,8(sp)
    8000631a:	6402                	ld	s0,0(sp)
    8000631c:	0141                	addi	sp,sp,16
    8000631e:	8082                	ret

0000000080006320 <cslog_read_many>:

int
cslog_read_many(struct cs_event *out, int max)
{
    80006320:	1141                	addi	sp,sp,-16
    80006322:	e406                	sd	ra,8(sp)
    80006324:	e022                	sd	s0,0(sp)
    80006326:	0800                	addi	s0,sp,16
    80006328:	862e                	mv	a2,a1
  return ringbuf_read_many(&cs_rb, out, max);
    8000632a:	85aa                	mv	a1,a0
    8000632c:	0001c517          	auipc	a0,0x1c
    80006330:	b0c50513          	addi	a0,a0,-1268 # 80021e38 <cs_rb>
    80006334:	204000ef          	jal	80006538 <ringbuf_read_many>
}
    80006338:	60a2                	ld	ra,8(sp)
    8000633a:	6402                	ld	s0,0(sp)
    8000633c:	0141                	addi	sp,sp,16
    8000633e:	8082                	ret

0000000080006340 <cslog_run_start>:

void
cslog_run_start(struct proc *p)
{
  if(p == 0) return;
    80006340:	c14d                	beqz	a0,800063e2 <cslog_run_start+0xa2>
{
    80006342:	715d                	addi	sp,sp,-80
    80006344:	e486                	sd	ra,72(sp)
    80006346:	e0a2                	sd	s0,64(sp)
    80006348:	fc26                	sd	s1,56(sp)
    8000634a:	0880                	addi	s0,sp,80
    8000634c:	84aa                	mv	s1,a0
  if(p->pid <= 0) return;
    8000634e:	595c                	lw	a5,52(a0)
    80006350:	00f05563          	blez	a5,8000635a <cslog_run_start+0x1a>
  if(p->name[0] == 0) return;
    80006354:	15854783          	lbu	a5,344(a0)
    80006358:	e791                	bnez	a5,80006364 <cslog_run_start+0x24>

  struct cs_event e;
  fill_from_proc(&e, p);
  e.type = CS_RUN_START;
  cslog_push(&e);
    8000635a:	60a6                	ld	ra,72(sp)
    8000635c:	6406                	ld	s0,64(sp)
    8000635e:	74e2                	ld	s1,56(sp)
    80006360:	6161                	addi	sp,sp,80
    80006362:	8082                	ret
    80006364:	f84a                	sd	s2,48(sp)
  if(strncmp(p->name, "cscat", 5) == 0) return;
    80006366:	15850913          	addi	s2,a0,344
    8000636a:	4615                	li	a2,5
    8000636c:	00002597          	auipc	a1,0x2
    80006370:	3f458593          	addi	a1,a1,1012 # 80008760 <etext+0x760>
    80006374:	854a                	mv	a0,s2
    80006376:	ae7fa0ef          	jal	80000e5c <strncmp>
    8000637a:	e119                	bnez	a0,80006380 <cslog_run_start+0x40>
    8000637c:	7942                	ld	s2,48(sp)
    8000637e:	bff1                	j	8000635a <cslog_run_start+0x1a>
  if(strncmp(p->name, "csexport", 8) == 0) return;
    80006380:	4621                	li	a2,8
    80006382:	00002597          	auipc	a1,0x2
    80006386:	3e658593          	addi	a1,a1,998 # 80008768 <etext+0x768>
    8000638a:	854a                	mv	a0,s2
    8000638c:	ad1fa0ef          	jal	80000e5c <strncmp>
    80006390:	e119                	bnez	a0,80006396 <cslog_run_start+0x56>
    80006392:	7942                	ld	s2,48(sp)
    80006394:	b7d9                	j	8000635a <cslog_run_start+0x1a>
  memset(e, 0, sizeof(*e));
    80006396:	03000613          	li	a2,48
    8000639a:	4581                	li	a1,0
    8000639c:	fb040513          	addi	a0,s0,-80
    800063a0:	9f1fa0ef          	jal	80000d90 <memset>
  e->ticks = ticks;
    800063a4:	00002797          	auipc	a5,0x2
    800063a8:	58c7a783          	lw	a5,1420(a5) # 80008930 <ticks>
    800063ac:	faf42c23          	sw	a5,-72(s0)
  e->cpu   = cpuid();
    800063b0:	883fb0ef          	jal	80001c32 <cpuid>
    800063b4:	faa42e23          	sw	a0,-68(s0)
  e->pid   = p->pid;
    800063b8:	58dc                	lw	a5,52(s1)
    800063ba:	fcf42223          	sw	a5,-60(s0)
  e->state = p->state;
    800063be:	4c9c                	lw	a5,24(s1)
    800063c0:	fcf42423          	sw	a5,-56(s0)
  safestrcpy(e->name, p->name, CS_NM);
    800063c4:	4641                	li	a2,16
    800063c6:	85ca                	mv	a1,s2
    800063c8:	fcc40513          	addi	a0,s0,-52
    800063cc:	b03fa0ef          	jal	80000ece <safestrcpy>
  e.type = CS_RUN_START;
    800063d0:	4785                	li	a5,1
    800063d2:	fcf42023          	sw	a5,-64(s0)
  cslog_push(&e);
    800063d6:	fb040513          	addi	a0,s0,-80
    800063da:	f19ff0ef          	jal	800062f2 <cslog_push>
    800063de:	7942                	ld	s2,48(sp)
    800063e0:	bfad                	j	8000635a <cslog_run_start+0x1a>
    800063e2:	8082                	ret

00000000800063e4 <sys_csread>:
#include "cslog.h"


uint64
sys_csread(void)
{
    800063e4:	81010113          	addi	sp,sp,-2032
    800063e8:	7e113423          	sd	ra,2024(sp)
    800063ec:	7e813023          	sd	s0,2016(sp)
    800063f0:	7c913c23          	sd	s1,2008(sp)
    800063f4:	7d213823          	sd	s2,2000(sp)
    800063f8:	7f010413          	addi	s0,sp,2032
    800063fc:	bb010113          	addi	sp,sp,-1104
  uint64 uaddr = 0;
    80006400:	fc043c23          	sd	zero,-40(s0)
  int max = 0;
    80006404:	fc042a23          	sw	zero,-44(s0)

  // ✅ عندك argaddr/argint void، فبنستدعيهم بدون if
  argaddr(0, &uaddr);
    80006408:	fd840593          	addi	a1,s0,-40
    8000640c:	4501                	li	a0,0
    8000640e:	a63fc0ef          	jal	80002e70 <argaddr>
  argint(1, &max);
    80006412:	fd440593          	addi	a1,s0,-44
    80006416:	4505                	li	a0,1
    80006418:	a3dfc0ef          	jal	80002e54 <argint>

  if(max <= 0) return 0;
    8000641c:	fd442783          	lw	a5,-44(s0)
    80006420:	4501                	li	a0,0
    80006422:	04f05c63          	blez	a5,8000647a <sys_csread+0x96>
  if(max > 64) max = 64;
    80006426:	04000713          	li	a4,64
    8000642a:	00f75663          	bge	a4,a5,80006436 <sys_csread+0x52>
    8000642e:	04000793          	li	a5,64
    80006432:	fcf42a23          	sw	a5,-44(s0)

  struct cs_event tmp[64];
  int n = cslog_read_many(tmp, max);
    80006436:	77fd                	lui	a5,0xfffff
    80006438:	3d078793          	addi	a5,a5,976 # fffffffffffff3d0 <end+0xffffffff7ffb84f0>
    8000643c:	97a2                	add	a5,a5,s0
    8000643e:	797d                	lui	s2,0xfffff
    80006440:	3c890713          	addi	a4,s2,968 # fffffffffffff3c8 <end+0xffffffff7ffb84e8>
    80006444:	9722                	add	a4,a4,s0
    80006446:	e31c                	sd	a5,0(a4)
    80006448:	fd442583          	lw	a1,-44(s0)
    8000644c:	6308                	ld	a0,0(a4)
    8000644e:	ed3ff0ef          	jal	80006320 <cslog_read_many>
    80006452:	84aa                	mv	s1,a0

  int bytes = n * (int)sizeof(struct cs_event);
  if(copyout(myproc()->pagetable, uaddr, (char*)tmp, bytes) < 0)
    80006454:	811fb0ef          	jal	80001c64 <myproc>
  int bytes = n * (int)sizeof(struct cs_event);
    80006458:	0014969b          	slliw	a3,s1,0x1
    8000645c:	9ea5                	addw	a3,a3,s1
  if(copyout(myproc()->pagetable, uaddr, (char*)tmp, bytes) < 0)
    8000645e:	0046969b          	slliw	a3,a3,0x4
    80006462:	3c890793          	addi	a5,s2,968
    80006466:	97a2                	add	a5,a5,s0
    80006468:	6390                	ld	a2,0(a5)
    8000646a:	fd843583          	ld	a1,-40(s0)
    8000646e:	6928                	ld	a0,80(a0)
    80006470:	c7efb0ef          	jal	800018ee <copyout>
    80006474:	02054063          	bltz	a0,80006494 <sys_csread+0xb0>
    return -1;

  return n;
    80006478:	8526                	mv	a0,s1
}
    8000647a:	45010113          	addi	sp,sp,1104
    8000647e:	7e813083          	ld	ra,2024(sp)
    80006482:	7e013403          	ld	s0,2016(sp)
    80006486:	7d813483          	ld	s1,2008(sp)
    8000648a:	7d013903          	ld	s2,2000(sp)
    8000648e:	7f010113          	addi	sp,sp,2032
    80006492:	8082                	ret
    return -1;
    80006494:	557d                	li	a0,-1
    80006496:	b7d5                	j	8000647a <sys_csread+0x96>

0000000080006498 <ringbuf_init>:
  return (void *)(rb->buf + idx * rb->elem_size);
}

void
ringbuf_init(struct ringbuf *rb, char *name, uint elem_size)
{
    80006498:	1101                	addi	sp,sp,-32
    8000649a:	ec06                	sd	ra,24(sp)
    8000649c:	e822                	sd	s0,16(sp)
    8000649e:	e426                	sd	s1,8(sp)
    800064a0:	e04a                	sd	s2,0(sp)
    800064a2:	1000                	addi	s0,sp,32
    800064a4:	84aa                	mv	s1,a0
    800064a6:	8932                	mv	s2,a2
  initlock(&rb->lock, name);
    800064a8:	f94fa0ef          	jal	80000c3c <initlock>
  rb->head = 0;
    800064ac:	0004ac23          	sw	zero,24(s1)
  rb->tail = 0;
    800064b0:	0004ae23          	sw	zero,28(s1)
  rb->count = 0;
    800064b4:	0204a023          	sw	zero,32(s1)
  rb->seq = 0;
    800064b8:	0204b423          	sd	zero,40(s1)
  rb->elem_size = elem_size;
    800064bc:	0324a223          	sw	s2,36(s1)
}
    800064c0:	60e2                	ld	ra,24(sp)
    800064c2:	6442                	ld	s0,16(sp)
    800064c4:	64a2                	ld	s1,8(sp)
    800064c6:	6902                	ld	s2,0(sp)
    800064c8:	6105                	addi	sp,sp,32
    800064ca:	8082                	ret

00000000800064cc <ringbuf_push>:

int
ringbuf_push(struct ringbuf *rb, void *elem)
{
    800064cc:	1101                	addi	sp,sp,-32
    800064ce:	ec06                	sd	ra,24(sp)
    800064d0:	e822                	sd	s0,16(sp)
    800064d2:	e426                	sd	s1,8(sp)
    800064d4:	e04a                	sd	s2,0(sp)
    800064d6:	1000                	addi	s0,sp,32
    800064d8:	84aa                	mv	s1,a0
    800064da:	892e                	mv	s2,a1
  acquire(&rb->lock);
    800064dc:	fe0fa0ef          	jal	80000cbc <acquire>

  if(rb->count == RB_CAP){
    800064e0:	5098                	lw	a4,32(s1)
    800064e2:	20000793          	li	a5,512
    800064e6:	04f70063          	beq	a4,a5,80006526 <ringbuf_push+0x5a>
  return (void *)(rb->buf + idx * rb->elem_size);
    800064ea:	50d0                	lw	a2,36(s1)
    800064ec:	03048513          	addi	a0,s1,48
    800064f0:	4c9c                	lw	a5,24(s1)
    800064f2:	02c787bb          	mulw	a5,a5,a2
    800064f6:	1782                	slli	a5,a5,0x20
    800064f8:	9381                	srli	a5,a5,0x20
    rb->tail = (rb->tail + 1) % RB_CAP;
    rb->count--;
  }

  memmove(slot_ptr(rb, rb->head), elem, rb->elem_size);
    800064fa:	85ca                	mv	a1,s2
    800064fc:	953e                	add	a0,a0,a5
    800064fe:	8effa0ef          	jal	80000dec <memmove>
  rb->head = (rb->head + 1) % RB_CAP;
    80006502:	4c9c                	lw	a5,24(s1)
    80006504:	2785                	addiw	a5,a5,1
    80006506:	1ff7f793          	andi	a5,a5,511
    8000650a:	cc9c                	sw	a5,24(s1)
  rb->count++;
    8000650c:	509c                	lw	a5,32(s1)
    8000650e:	2785                	addiw	a5,a5,1
    80006510:	d09c                	sw	a5,32(s1)

  release(&rb->lock);
    80006512:	8526                	mv	a0,s1
    80006514:	841fa0ef          	jal	80000d54 <release>
  return 0;
}
    80006518:	4501                	li	a0,0
    8000651a:	60e2                	ld	ra,24(sp)
    8000651c:	6442                	ld	s0,16(sp)
    8000651e:	64a2                	ld	s1,8(sp)
    80006520:	6902                	ld	s2,0(sp)
    80006522:	6105                	addi	sp,sp,32
    80006524:	8082                	ret
    rb->tail = (rb->tail + 1) % RB_CAP;
    80006526:	4cdc                	lw	a5,28(s1)
    80006528:	2785                	addiw	a5,a5,1
    8000652a:	1ff7f793          	andi	a5,a5,511
    8000652e:	ccdc                	sw	a5,28(s1)
    rb->count--;
    80006530:	1ff00793          	li	a5,511
    80006534:	d09c                	sw	a5,32(s1)
    80006536:	bf55                	j	800064ea <ringbuf_push+0x1e>

0000000080006538 <ringbuf_read_many>:

int
ringbuf_read_many(struct ringbuf *rb, void *out, int max)
{
    80006538:	7139                	addi	sp,sp,-64
    8000653a:	fc06                	sd	ra,56(sp)
    8000653c:	f822                	sd	s0,48(sp)
    8000653e:	f04a                	sd	s2,32(sp)
    80006540:	0080                	addi	s0,sp,64
  int n = 0;
  char *dst = (char *)out;

  if(max <= 0)
    return 0;
    80006542:	4901                	li	s2,0
  if(max <= 0)
    80006544:	06c05163          	blez	a2,800065a6 <ringbuf_read_many+0x6e>
    80006548:	f426                	sd	s1,40(sp)
    8000654a:	ec4e                	sd	s3,24(sp)
    8000654c:	e852                	sd	s4,16(sp)
    8000654e:	e456                	sd	s5,8(sp)
    80006550:	84aa                	mv	s1,a0
    80006552:	8a2e                	mv	s4,a1
    80006554:	89b2                	mv	s3,a2

  acquire(&rb->lock);
    80006556:	f66fa0ef          	jal	80000cbc <acquire>
  int n = 0;
    8000655a:	4901                	li	s2,0
  return (void *)(rb->buf + idx * rb->elem_size);
    8000655c:	03048a93          	addi	s5,s1,48
  while(n < max && rb->count > 0){
    80006560:	509c                	lw	a5,32(s1)
    80006562:	cb9d                	beqz	a5,80006598 <ringbuf_read_many+0x60>
    memmove(dst + n * rb->elem_size, slot_ptr(rb, rb->tail), rb->elem_size);
    80006564:	50d0                	lw	a2,36(s1)
  return (void *)(rb->buf + idx * rb->elem_size);
    80006566:	4ccc                	lw	a1,28(s1)
    80006568:	02c585bb          	mulw	a1,a1,a2
    8000656c:	1582                	slli	a1,a1,0x20
    8000656e:	9181                	srli	a1,a1,0x20
    memmove(dst + n * rb->elem_size, slot_ptr(rb, rb->tail), rb->elem_size);
    80006570:	02c9053b          	mulw	a0,s2,a2
    80006574:	1502                	slli	a0,a0,0x20
    80006576:	9101                	srli	a0,a0,0x20
    80006578:	95d6                	add	a1,a1,s5
    8000657a:	9552                	add	a0,a0,s4
    8000657c:	871fa0ef          	jal	80000dec <memmove>
    rb->tail = (rb->tail + 1) % RB_CAP;
    80006580:	4cdc                	lw	a5,28(s1)
    80006582:	2785                	addiw	a5,a5,1
    80006584:	1ff7f793          	andi	a5,a5,511
    80006588:	ccdc                	sw	a5,28(s1)
    rb->count--;
    8000658a:	509c                	lw	a5,32(s1)
    8000658c:	37fd                	addiw	a5,a5,-1
    8000658e:	d09c                	sw	a5,32(s1)
    n++;
    80006590:	2905                	addiw	s2,s2,1
  while(n < max && rb->count > 0){
    80006592:	fd2997e3          	bne	s3,s2,80006560 <ringbuf_read_many+0x28>
    80006596:	894e                	mv	s2,s3
  }
  release(&rb->lock);
    80006598:	8526                	mv	a0,s1
    8000659a:	fbafa0ef          	jal	80000d54 <release>

  return n;
    8000659e:	74a2                	ld	s1,40(sp)
    800065a0:	69e2                	ld	s3,24(sp)
    800065a2:	6a42                	ld	s4,16(sp)
    800065a4:	6aa2                	ld	s5,8(sp)
}
    800065a6:	854a                	mv	a0,s2
    800065a8:	70e2                	ld	ra,56(sp)
    800065aa:	7442                	ld	s0,48(sp)
    800065ac:	7902                	ld	s2,32(sp)
    800065ae:	6121                	addi	sp,sp,64
    800065b0:	8082                	ret

00000000800065b2 <ringbuf_pop>:
int
ringbuf_pop(struct ringbuf *rb, void *dst)
{
    800065b2:	1101                	addi	sp,sp,-32
    800065b4:	ec06                	sd	ra,24(sp)
    800065b6:	e822                	sd	s0,16(sp)
    800065b8:	e426                	sd	s1,8(sp)
    800065ba:	e04a                	sd	s2,0(sp)
    800065bc:	1000                	addi	s0,sp,32
    800065be:	84aa                	mv	s1,a0
    800065c0:	892e                	mv	s2,a1
  acquire(&rb->lock);
    800065c2:	efafa0ef          	jal	80000cbc <acquire>
  
  if(rb->count == 0){ // البفر فارغ تماماً
    800065c6:	509c                	lw	a5,32(s1)
    800065c8:	cf9d                	beqz	a5,80006606 <ringbuf_pop+0x54>
  return (void *)(rb->buf + idx * rb->elem_size);
    800065ca:	50d0                	lw	a2,36(s1)
    800065cc:	03048593          	addi	a1,s1,48
    800065d0:	4cdc                	lw	a5,28(s1)
    800065d2:	02c787bb          	mulw	a5,a5,a2
    800065d6:	1782                	slli	a5,a5,0x20
    800065d8:	9381                	srli	a5,a5,0x20
    return -1;
  }

  // استخدام الدالة المساعدة slot_ptr الموجودة عندك أصلاً
  void *src = slot_ptr(rb, rb->tail);
  memmove(dst, src, rb->elem_size);
    800065da:	95be                	add	a1,a1,a5
    800065dc:	854a                	mv	a0,s2
    800065de:	80ffa0ef          	jal	80000dec <memmove>
  
  // تحديث المؤشرات بنفس منطق المشروع
  rb->tail = (rb->tail + 1) % RB_CAP;
    800065e2:	4cdc                	lw	a5,28(s1)
    800065e4:	2785                	addiw	a5,a5,1
    800065e6:	1ff7f793          	andi	a5,a5,511
    800065ea:	ccdc                	sw	a5,28(s1)
  rb->count--;
    800065ec:	509c                	lw	a5,32(s1)
    800065ee:	37fd                	addiw	a5,a5,-1
    800065f0:	d09c                	sw	a5,32(s1)
  
  release(&rb->lock);
    800065f2:	8526                	mv	a0,s1
    800065f4:	f60fa0ef          	jal	80000d54 <release>
  return 0;
    800065f8:	4501                	li	a0,0
} 
    800065fa:	60e2                	ld	ra,24(sp)
    800065fc:	6442                	ld	s0,16(sp)
    800065fe:	64a2                	ld	s1,8(sp)
    80006600:	6902                	ld	s2,0(sp)
    80006602:	6105                	addi	sp,sp,32
    80006604:	8082                	ret
    release(&rb->lock);
    80006606:	8526                	mv	a0,s1
    80006608:	f4cfa0ef          	jal	80000d54 <release>
    return -1;
    8000660c:	557d                	li	a0,-1
    8000660e:	b7f5                	j	800065fa <ringbuf_pop+0x48>

0000000080006610 <fslog_init>:
#include "defs.h"

static struct ringbuf fs_rb;
static uint64 fs_seq = 0;

void fslog_init(void) {
    80006610:	1141                	addi	sp,sp,-16
    80006612:	e406                	sd	ra,8(sp)
    80006614:	e022                	sd	s0,0(sp)
    80006616:	0800                	addi	s0,sp,16
  ringbuf_init(&fs_rb, "fslog", sizeof(struct fs_event));
    80006618:	03000613          	li	a2,48
    8000661c:	00002597          	auipc	a1,0x2
    80006620:	15c58593          	addi	a1,a1,348 # 80008778 <etext+0x778>
    80006624:	00024517          	auipc	a0,0x24
    80006628:	84450513          	addi	a0,a0,-1980 # 80029e68 <fs_rb>
    8000662c:	e6dff0ef          	jal	80006498 <ringbuf_init>
}
    80006630:	60a2                	ld	ra,8(sp)
    80006632:	6402                	ld	s0,0(sp)
    80006634:	0141                	addi	sp,sp,16
    80006636:	8082                	ret

0000000080006638 <fslog_push>:

void fslog_push(int type, int inum, int bno, uint size, char* name) {
    80006638:	7159                	addi	sp,sp,-112
    8000663a:	f486                	sd	ra,104(sp)
    8000663c:	f0a2                	sd	s0,96(sp)
    8000663e:	eca6                	sd	s1,88(sp)
    80006640:	e8ca                	sd	s2,80(sp)
    80006642:	e4ce                	sd	s3,72(sp)
    80006644:	e0d2                	sd	s4,64(sp)
    80006646:	fc56                	sd	s5,56(sp)
    80006648:	1880                	addi	s0,sp,112
    8000664a:	8aaa                	mv	s5,a0
    8000664c:	8a2e                	mv	s4,a1
    8000664e:	89b2                	mv	s3,a2
    80006650:	8936                	mv	s2,a3
    80006652:	84ba                	mv	s1,a4
  struct fs_event e;
  memset(&e, 0, sizeof(e));
    80006654:	03000613          	li	a2,48
    80006658:	4581                	li	a1,0
    8000665a:	f9040513          	addi	a0,s0,-112
    8000665e:	f32fa0ef          	jal	80000d90 <memset>
  e.seq = ++fs_seq;
    80006662:	00002717          	auipc	a4,0x2
    80006666:	2de70713          	addi	a4,a4,734 # 80008940 <fs_seq>
    8000666a:	631c                	ld	a5,0(a4)
    8000666c:	0785                	addi	a5,a5,1
    8000666e:	e31c                	sd	a5,0(a4)
    80006670:	f8f43823          	sd	a5,-112(s0)
  e.ticks = ticks;
    80006674:	00002797          	auipc	a5,0x2
    80006678:	2bc7a783          	lw	a5,700(a5) # 80008930 <ticks>
    8000667c:	f8f42c23          	sw	a5,-104(s0)
  e.type = type;
    80006680:	f9542e23          	sw	s5,-100(s0)
  e.pid = myproc() ? myproc()->pid : 0;
    80006684:	de0fb0ef          	jal	80001c64 <myproc>
    80006688:	4781                	li	a5,0
    8000668a:	c501                	beqz	a0,80006692 <fslog_push+0x5a>
    8000668c:	dd8fb0ef          	jal	80001c64 <myproc>
    80006690:	595c                	lw	a5,52(a0)
    80006692:	faf42023          	sw	a5,-96(s0)
  e.inum = inum;
    80006696:	fb442223          	sw	s4,-92(s0)
  e.blockno = bno;
    8000669a:	fb342423          	sw	s3,-88(s0)
  e.size = size;
    8000669e:	fb242623          	sw	s2,-84(s0)
  if(name) safestrcpy(e.name, name, FS_NM);
    800066a2:	c499                	beqz	s1,800066b0 <fslog_push+0x78>
    800066a4:	4641                	li	a2,16
    800066a6:	85a6                	mv	a1,s1
    800066a8:	fb040513          	addi	a0,s0,-80
    800066ac:	823fa0ef          	jal	80000ece <safestrcpy>
  ringbuf_push(&fs_rb, &e);
    800066b0:	f9040593          	addi	a1,s0,-112
    800066b4:	00023517          	auipc	a0,0x23
    800066b8:	7b450513          	addi	a0,a0,1972 # 80029e68 <fs_rb>
    800066bc:	e11ff0ef          	jal	800064cc <ringbuf_push>
}
    800066c0:	70a6                	ld	ra,104(sp)
    800066c2:	7406                	ld	s0,96(sp)
    800066c4:	64e6                	ld	s1,88(sp)
    800066c6:	6946                	ld	s2,80(sp)
    800066c8:	69a6                	ld	s3,72(sp)
    800066ca:	6a06                	ld	s4,64(sp)
    800066cc:	7ae2                	ld	s5,56(sp)
    800066ce:	6165                	addi	sp,sp,112
    800066d0:	8082                	ret

00000000800066d2 <fslog_read_many>:
// لا تنسي إضافة fslog_read_many أيضاً هنا

int
fslog_read_many(struct fs_event *out, int max)
{
    800066d2:	7159                	addi	sp,sp,-112
    800066d4:	f486                	sd	ra,104(sp)
    800066d6:	f0a2                	sd	s0,96(sp)
    800066d8:	eca6                	sd	s1,88(sp)
    800066da:	e8ca                	sd	s2,80(sp)
    800066dc:	e4ce                	sd	s3,72(sp)
    800066de:	1880                	addi	s0,sp,112
    800066e0:	84aa                	mv	s1,a0
    800066e2:	89ae                	mv	s3,a1
  struct fs_event e;
  int count = 0;
  struct proc *p = myproc();
    800066e4:	d80fb0ef          	jal	80001c64 <myproc>

  while(count < max){
    800066e8:	05305463          	blez	s3,80006730 <fslog_read_many+0x5e>
    800066ec:	e0d2                	sd	s4,64(sp)
    800066ee:	fc56                	sd	s5,56(sp)
    800066f0:	8a2a                	mv	s4,a0
  int count = 0;
    800066f2:	4901                	li	s2,0
    // سحب حدث واحد من الرينغ بفر (موجود في ذاكرة الكيرنل)
    if(ringbuf_pop(&fs_rb, &e) != 0)
    800066f4:	00023a97          	auipc	s5,0x23
    800066f8:	774a8a93          	addi	s5,s5,1908 # 80029e68 <fs_rb>
    800066fc:	f9040593          	addi	a1,s0,-112
    80006700:	8556                	mv	a0,s5
    80006702:	eb1ff0ef          	jal	800065b2 <ringbuf_pop>
    80006706:	e51d                	bnez	a0,80006734 <fslog_read_many+0x62>
      break;

    // 🔥 النسخ الآمن لذاكرة المستخدم باستخدام copyout
    // العنوان الهدف: out + (count * حجم الـ struct)
    uint64 dst_addr = (uint64)out + (count * sizeof(struct fs_event));
    if(copyout(p->pagetable, dst_addr, (char *)&e, sizeof(struct fs_event)) < 0)
    80006708:	03000693          	li	a3,48
    8000670c:	f9040613          	addi	a2,s0,-112
    80006710:	85a6                	mv	a1,s1
    80006712:	050a3503          	ld	a0,80(s4)
    80006716:	9d8fb0ef          	jal	800018ee <copyout>
    8000671a:	02054763          	bltz	a0,80006748 <fslog_read_many+0x76>
      break;

    count++;
    8000671e:	2905                	addiw	s2,s2,1
  while(count < max){
    80006720:	03048493          	addi	s1,s1,48
    80006724:	fd299ce3          	bne	s3,s2,800066fc <fslog_read_many+0x2a>
    80006728:	894e                	mv	s2,s3
    8000672a:	6a06                	ld	s4,64(sp)
    8000672c:	7ae2                	ld	s5,56(sp)
    8000672e:	a029                	j	80006738 <fslog_read_many+0x66>
  int count = 0;
    80006730:	4901                	li	s2,0
    80006732:	a019                	j	80006738 <fslog_read_many+0x66>
    80006734:	6a06                	ld	s4,64(sp)
    80006736:	7ae2                	ld	s5,56(sp)
  }
  return count;
    80006738:	854a                	mv	a0,s2
    8000673a:	70a6                	ld	ra,104(sp)
    8000673c:	7406                	ld	s0,96(sp)
    8000673e:	64e6                	ld	s1,88(sp)
    80006740:	6946                	ld	s2,80(sp)
    80006742:	69a6                	ld	s3,72(sp)
    80006744:	6165                	addi	sp,sp,112
    80006746:	8082                	ret
    80006748:	6a06                	ld	s4,64(sp)
    8000674a:	7ae2                	ld	s5,56(sp)
    8000674c:	b7f5                	j	80006738 <fslog_read_many+0x66>

000000008000674e <memlog_init>:
static uint mem_count = 0;
static uint64 mem_seq = 0;

void
memlog_init(void)
{
    8000674e:	1141                	addi	sp,sp,-16
    80006750:	e406                	sd	ra,8(sp)
    80006752:	e022                	sd	s0,0(sp)
    80006754:	0800                	addi	s0,sp,16
  initlock(&mem_lock, "memlog");
    80006756:	00002597          	auipc	a1,0x2
    8000675a:	02a58593          	addi	a1,a1,42 # 80008780 <etext+0x780>
    8000675e:	0002b517          	auipc	a0,0x2b
    80006762:	73a50513          	addi	a0,a0,1850 # 80031e98 <mem_lock>
    80006766:	cd6fa0ef          	jal	80000c3c <initlock>
  mem_head = 0;
    8000676a:	00002797          	auipc	a5,0x2
    8000676e:	1e07a723          	sw	zero,494(a5) # 80008958 <mem_head>
  mem_tail = 0;
    80006772:	00002797          	auipc	a5,0x2
    80006776:	1e07a123          	sw	zero,482(a5) # 80008954 <mem_tail>
  mem_count = 0;
    8000677a:	00002797          	auipc	a5,0x2
    8000677e:	1c07ab23          	sw	zero,470(a5) # 80008950 <mem_count>
  mem_seq = 0;
    80006782:	00002797          	auipc	a5,0x2
    80006786:	1c07b323          	sd	zero,454(a5) # 80008948 <mem_seq>
}
    8000678a:	60a2                	ld	ra,8(sp)
    8000678c:	6402                	ld	s0,0(sp)
    8000678e:	0141                	addi	sp,sp,16
    80006790:	8082                	ret

0000000080006792 <memlog_push>:

void
memlog_push(struct mem_event *e)
{
    80006792:	1101                	addi	sp,sp,-32
    80006794:	ec06                	sd	ra,24(sp)
    80006796:	e822                	sd	s0,16(sp)
    80006798:	e426                	sd	s1,8(sp)
    8000679a:	1000                	addi	s0,sp,32
    8000679c:	84aa                	mv	s1,a0
  acquire(&mem_lock);
    8000679e:	0002b517          	auipc	a0,0x2b
    800067a2:	6fa50513          	addi	a0,a0,1786 # 80031e98 <mem_lock>
    800067a6:	d16fa0ef          	jal	80000cbc <acquire>

  e->seq = ++mem_seq;
    800067aa:	00002717          	auipc	a4,0x2
    800067ae:	19e70713          	addi	a4,a4,414 # 80008948 <mem_seq>
    800067b2:	631c                	ld	a5,0(a4)
    800067b4:	0785                	addi	a5,a5,1
    800067b6:	e31c                	sd	a5,0(a4)
    800067b8:	e09c                	sd	a5,0(s1)

  if(mem_count == MEM_RB_CAP){
    800067ba:	00002717          	auipc	a4,0x2
    800067be:	19672703          	lw	a4,406(a4) # 80008950 <mem_count>
    800067c2:	20000793          	li	a5,512
    800067c6:	08f70063          	beq	a4,a5,80006846 <memlog_push+0xb4>
    mem_tail = (mem_tail + 1) % MEM_RB_CAP;
    mem_count--;
  }

  mem_buf[mem_head] = *e;
    800067ca:	00002697          	auipc	a3,0x2
    800067ce:	18e6a683          	lw	a3,398(a3) # 80008958 <mem_head>
    800067d2:	02069613          	slli	a2,a3,0x20
    800067d6:	9201                	srli	a2,a2,0x20
    800067d8:	06800793          	li	a5,104
    800067dc:	02f60633          	mul	a2,a2,a5
    800067e0:	8726                	mv	a4,s1
    800067e2:	0002b797          	auipc	a5,0x2b
    800067e6:	6ce78793          	addi	a5,a5,1742 # 80031eb0 <mem_buf>
    800067ea:	97b2                	add	a5,a5,a2
    800067ec:	06048493          	addi	s1,s1,96
    800067f0:	00073803          	ld	a6,0(a4)
    800067f4:	6708                	ld	a0,8(a4)
    800067f6:	6b0c                	ld	a1,16(a4)
    800067f8:	6f10                	ld	a2,24(a4)
    800067fa:	0107b023          	sd	a6,0(a5)
    800067fe:	e788                	sd	a0,8(a5)
    80006800:	eb8c                	sd	a1,16(a5)
    80006802:	ef90                	sd	a2,24(a5)
    80006804:	02070713          	addi	a4,a4,32
    80006808:	02078793          	addi	a5,a5,32
    8000680c:	fe9712e3          	bne	a4,s1,800067f0 <memlog_push+0x5e>
    80006810:	6318                	ld	a4,0(a4)
    80006812:	e398                	sd	a4,0(a5)
  mem_head = (mem_head + 1) % MEM_RB_CAP;
    80006814:	2685                	addiw	a3,a3,1
    80006816:	1ff6f693          	andi	a3,a3,511
    8000681a:	00002797          	auipc	a5,0x2
    8000681e:	12d7af23          	sw	a3,318(a5) # 80008958 <mem_head>
  mem_count++;
    80006822:	00002717          	auipc	a4,0x2
    80006826:	12e70713          	addi	a4,a4,302 # 80008950 <mem_count>
    8000682a:	431c                	lw	a5,0(a4)
    8000682c:	2785                	addiw	a5,a5,1
    8000682e:	c31c                	sw	a5,0(a4)

  release(&mem_lock);
    80006830:	0002b517          	auipc	a0,0x2b
    80006834:	66850513          	addi	a0,a0,1640 # 80031e98 <mem_lock>
    80006838:	d1cfa0ef          	jal	80000d54 <release>
}
    8000683c:	60e2                	ld	ra,24(sp)
    8000683e:	6442                	ld	s0,16(sp)
    80006840:	64a2                	ld	s1,8(sp)
    80006842:	6105                	addi	sp,sp,32
    80006844:	8082                	ret
    mem_tail = (mem_tail + 1) % MEM_RB_CAP;
    80006846:	00002717          	auipc	a4,0x2
    8000684a:	10e70713          	addi	a4,a4,270 # 80008954 <mem_tail>
    8000684e:	431c                	lw	a5,0(a4)
    80006850:	2785                	addiw	a5,a5,1
    80006852:	1ff7f793          	andi	a5,a5,511
    80006856:	c31c                	sw	a5,0(a4)
    mem_count--;
    80006858:	1ff00793          	li	a5,511
    8000685c:	00002717          	auipc	a4,0x2
    80006860:	0ef72a23          	sw	a5,244(a4) # 80008950 <mem_count>
    80006864:	b79d                	j	800067ca <memlog_push+0x38>

0000000080006866 <memlog_read_many>:

int
memlog_read_many(struct mem_event *out, int max)
{
    80006866:	1101                	addi	sp,sp,-32
    80006868:	ec06                	sd	ra,24(sp)
    8000686a:	e822                	sd	s0,16(sp)
    8000686c:	e426                	sd	s1,8(sp)
    8000686e:	1000                	addi	s0,sp,32
  int n = 0;

  if(max <= 0)
    return 0;
    80006870:	4481                	li	s1,0
  if(max <= 0)
    80006872:	0ab05963          	blez	a1,80006924 <memlog_read_many+0xbe>
    80006876:	e04a                	sd	s2,0(sp)
    80006878:	84aa                	mv	s1,a0
    8000687a:	892e                	mv	s2,a1

  acquire(&mem_lock);
    8000687c:	0002b517          	auipc	a0,0x2b
    80006880:	61c50513          	addi	a0,a0,1564 # 80031e98 <mem_lock>
    80006884:	c38fa0ef          	jal	80000cbc <acquire>
  while(n < max && mem_count > 0){
    80006888:	00002697          	auipc	a3,0x2
    8000688c:	0cc6a683          	lw	a3,204(a3) # 80008954 <mem_tail>
    80006890:	00002617          	auipc	a2,0x2
    80006894:	0c062603          	lw	a2,192(a2) # 80008950 <mem_count>
    80006898:	8526                	mv	a0,s1
  acquire(&mem_lock);
    8000689a:	4701                	li	a4,0
  int n = 0;
    8000689c:	4481                	li	s1,0
    out[n] = mem_buf[mem_tail];
    8000689e:	0002bf97          	auipc	t6,0x2b
    800068a2:	612f8f93          	addi	t6,t6,1554 # 80031eb0 <mem_buf>
    800068a6:	06800f13          	li	t5,104
    800068aa:	4e85                	li	t4,1
  while(n < max && mem_count > 0){
    800068ac:	c251                	beqz	a2,80006930 <memlog_read_many+0xca>
    out[n] = mem_buf[mem_tail];
    800068ae:	02069793          	slli	a5,a3,0x20
    800068b2:	9381                	srli	a5,a5,0x20
    800068b4:	03e787b3          	mul	a5,a5,t5
    800068b8:	97fe                	add	a5,a5,t6
    800068ba:	872a                	mv	a4,a0
    800068bc:	06078e13          	addi	t3,a5,96
    800068c0:	0007b303          	ld	t1,0(a5)
    800068c4:	0087b883          	ld	a7,8(a5)
    800068c8:	0107b803          	ld	a6,16(a5)
    800068cc:	6f8c                	ld	a1,24(a5)
    800068ce:	00673023          	sd	t1,0(a4)
    800068d2:	01173423          	sd	a7,8(a4)
    800068d6:	01073823          	sd	a6,16(a4)
    800068da:	ef0c                	sd	a1,24(a4)
    800068dc:	02078793          	addi	a5,a5,32
    800068e0:	02070713          	addi	a4,a4,32
    800068e4:	fdc79ee3          	bne	a5,t3,800068c0 <memlog_read_many+0x5a>
    800068e8:	639c                	ld	a5,0(a5)
    800068ea:	e31c                	sd	a5,0(a4)
    mem_tail = (mem_tail + 1) % MEM_RB_CAP;
    800068ec:	2685                	addiw	a3,a3,1
    800068ee:	1ff6f693          	andi	a3,a3,511
    mem_count--;
    800068f2:	fff6079b          	addiw	a5,a2,-1
    800068f6:	0007861b          	sext.w	a2,a5
    n++;
    800068fa:	2485                	addiw	s1,s1,1
  while(n < max && mem_count > 0){
    800068fc:	06850513          	addi	a0,a0,104
    80006900:	8776                	mv	a4,t4
    80006902:	fa9915e3          	bne	s2,s1,800068ac <memlog_read_many+0x46>
    80006906:	00002717          	auipc	a4,0x2
    8000690a:	04d72723          	sw	a3,78(a4) # 80008954 <mem_tail>
    8000690e:	00002717          	auipc	a4,0x2
    80006912:	04f72123          	sw	a5,66(a4) # 80008950 <mem_count>
  }
  release(&mem_lock);
    80006916:	0002b517          	auipc	a0,0x2b
    8000691a:	58250513          	addi	a0,a0,1410 # 80031e98 <mem_lock>
    8000691e:	c36fa0ef          	jal	80000d54 <release>

  return n;
    80006922:	6902                	ld	s2,0(sp)
    80006924:	8526                	mv	a0,s1
    80006926:	60e2                	ld	ra,24(sp)
    80006928:	6442                	ld	s0,16(sp)
    8000692a:	64a2                	ld	s1,8(sp)
    8000692c:	6105                	addi	sp,sp,32
    8000692e:	8082                	ret
    80006930:	d37d                	beqz	a4,80006916 <memlog_read_many+0xb0>
    80006932:	00002797          	auipc	a5,0x2
    80006936:	02d7a123          	sw	a3,34(a5) # 80008954 <mem_tail>
    8000693a:	00002797          	auipc	a5,0x2
    8000693e:	0007ab23          	sw	zero,22(a5) # 80008950 <mem_count>
    80006942:	bfd1                	j	80006916 <memlog_read_many+0xb0>

0000000080006944 <sys_memread>:
#include "memevent.h"
#include "memlog.h"

uint64
sys_memread(void)
{
    80006944:	95010113          	addi	sp,sp,-1712
    80006948:	6a113423          	sd	ra,1704(sp)
    8000694c:	6a813023          	sd	s0,1696(sp)
    80006950:	6b010413          	addi	s0,sp,1712
  uint64 uaddr = 0;
    80006954:	fc043c23          	sd	zero,-40(s0)
  int max = 0;
    80006958:	fc042a23          	sw	zero,-44(s0)

  argaddr(0, &uaddr);
    8000695c:	fd840593          	addi	a1,s0,-40
    80006960:	4501                	li	a0,0
    80006962:	d0efc0ef          	jal	80002e70 <argaddr>
  argint(1, &max);
    80006966:	fd440593          	addi	a1,s0,-44
    8000696a:	4505                	li	a0,1
    8000696c:	ce8fc0ef          	jal	80002e54 <argint>

  if(max <= 0)
    80006970:	fd442783          	lw	a5,-44(s0)
    return 0;
    80006974:	4501                	li	a0,0
  if(max <= 0)
    80006976:	04f05363          	blez	a5,800069bc <sys_memread+0x78>
    8000697a:	68913c23          	sd	s1,1688(sp)
  if(max > 16)
    8000697e:	4741                	li	a4,16
    80006980:	00f75563          	bge	a4,a5,8000698a <sys_memread+0x46>
    max = 16;
    80006984:	47c1                	li	a5,16
    80006986:	fcf42a23          	sw	a5,-44(s0)

  struct mem_event tmp[16];
  int n = memlog_read_many(tmp, max);
    8000698a:	fd442583          	lw	a1,-44(s0)
    8000698e:	95040513          	addi	a0,s0,-1712
    80006992:	ed5ff0ef          	jal	80006866 <memlog_read_many>
    80006996:	84aa                	mv	s1,a0

  int bytes = n * (int)sizeof(struct mem_event);
  if(copyout(myproc()->pagetable, uaddr, (char *)tmp, bytes) < 0)
    80006998:	accfb0ef          	jal	80001c64 <myproc>
    8000699c:	06800693          	li	a3,104
    800069a0:	029686bb          	mulw	a3,a3,s1
    800069a4:	95040613          	addi	a2,s0,-1712
    800069a8:	fd843583          	ld	a1,-40(s0)
    800069ac:	6928                	ld	a0,80(a0)
    800069ae:	f41fa0ef          	jal	800018ee <copyout>
    800069b2:	00054c63          	bltz	a0,800069ca <sys_memread+0x86>
    return -1;

  return n;
    800069b6:	8526                	mv	a0,s1
    800069b8:	69813483          	ld	s1,1688(sp)
    800069bc:	6a813083          	ld	ra,1704(sp)
    800069c0:	6a013403          	ld	s0,1696(sp)
    800069c4:	6b010113          	addi	sp,sp,1712
    800069c8:	8082                	ret
    return -1;
    800069ca:	557d                	li	a0,-1
    800069cc:	69813483          	ld	s1,1688(sp)
    800069d0:	b7f5                	j	800069bc <sys_memread+0x78>

00000000800069d2 <schedlog_init>:

static struct ringbuf sched_rb;

void
schedlog_init(void)
{
    800069d2:	1141                	addi	sp,sp,-16
    800069d4:	e406                	sd	ra,8(sp)
    800069d6:	e022                	sd	s0,0(sp)
    800069d8:	0800                	addi	s0,sp,16
  ringbuf_init(&sched_rb, "schedlog", sizeof(struct sched_event));
    800069da:	04400613          	li	a2,68
    800069de:	00002597          	auipc	a1,0x2
    800069e2:	daa58593          	addi	a1,a1,-598 # 80008788 <etext+0x788>
    800069e6:	00038517          	auipc	a0,0x38
    800069ea:	4ca50513          	addi	a0,a0,1226 # 8003eeb0 <sched_rb>
    800069ee:	aabff0ef          	jal	80006498 <ringbuf_init>
}
    800069f2:	60a2                	ld	ra,8(sp)
    800069f4:	6402                	ld	s0,0(sp)
    800069f6:	0141                	addi	sp,sp,16
    800069f8:	8082                	ret

00000000800069fa <schedlog_emit>:

void
schedlog_emit(struct sched_event *e)
{
    800069fa:	711d                	addi	sp,sp,-96
    800069fc:	ec86                	sd	ra,88(sp)
    800069fe:	e8a2                	sd	s0,80(sp)
    80006a00:	1080                	addi	s0,sp,96
    80006a02:	85aa                	mv	a1,a0
  struct sched_event copy;

  memmove(&copy, e, sizeof(copy));
    80006a04:	04400613          	li	a2,68
    80006a08:	fa840513          	addi	a0,s0,-88
    80006a0c:	be0fa0ef          	jal	80000dec <memmove>
  copy.seq = sched_rb.seq++;
    80006a10:	00038517          	auipc	a0,0x38
    80006a14:	4a050513          	addi	a0,a0,1184 # 8003eeb0 <sched_rb>
    80006a18:	751c                	ld	a5,40(a0)
    80006a1a:	00178713          	addi	a4,a5,1
    80006a1e:	f518                	sd	a4,40(a0)
    80006a20:	faf42423          	sw	a5,-88(s0)
  ringbuf_push(&sched_rb, &copy);
    80006a24:	fa840593          	addi	a1,s0,-88
    80006a28:	aa5ff0ef          	jal	800064cc <ringbuf_push>
}
    80006a2c:	60e6                	ld	ra,88(sp)
    80006a2e:	6446                	ld	s0,80(sp)
    80006a30:	6125                	addi	sp,sp,96
    80006a32:	8082                	ret

0000000080006a34 <schedread>:

int
schedread(struct sched_event *dst, int max)
{
    80006a34:	1141                	addi	sp,sp,-16
    80006a36:	e406                	sd	ra,8(sp)
    80006a38:	e022                	sd	s0,0(sp)
    80006a3a:	0800                	addi	s0,sp,16
    80006a3c:	862e                	mv	a2,a1
  return ringbuf_read_many(&sched_rb, dst, max);
    80006a3e:	85aa                	mv	a1,a0
    80006a40:	00038517          	auipc	a0,0x38
    80006a44:	47050513          	addi	a0,a0,1136 # 8003eeb0 <sched_rb>
    80006a48:	af1ff0ef          	jal	80006538 <ringbuf_read_many>
    80006a4c:	60a2                	ld	ra,8(sp)
    80006a4e:	6402                	ld	s0,0(sp)
    80006a50:	0141                	addi	sp,sp,16
    80006a52:	8082                	ret
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
